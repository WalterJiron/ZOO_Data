USE ZOO;

GO

CREATE PROC ProcUpdateHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Nombre VARCHAR(100),
    @Clima VARCHAR(100),
    @DescripHabitat VARCHAR(MAX),
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @CodigoHabitat IS NULL OR @Nombre IS NULL OR @Clima IS NULL OR 
           @DescripHabitat IS NULL OR @CodigoZona IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios';
            RETURN;
        END

        IF LEN(TRIM(@Nombre)) < 3 OR LEN(TRIM(@Nombre)) > 100
        BEGIN
            SET @Mensaje = 'El nombre debe tener entre 3 y 100 caracteres';
            RETURN;
        END 

        IF LEN(TRIM(@Clima)) < 5 OR LEN(TRIM(@Clima)) > 100
        BEGIN
            SET @Mensaje = 'El clima debe tener entre 5 y 100 caracteres';
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @existHabitad AS BIT;
        SET @existHabitad = (
            SELECT EstadoHabitat FROM Habitat WITH(UPDLOCK, ROWLOCK) 
            WHERE CodigoHabitat = @CodigoHabitat);
       
        IF @existHabitad IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El habitat no existe en la base de datos';
            RETURN;
        END

        IF @existHabitad = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El habitat se encuentra inactivo';
            RETURN;
        END

        DECLARE @existZona AS BIT;
        SET @existZona = (
            SELECT EstadoZona FROM Zona WITH(UPDLOCK, ROWLOCK) 
            WHERE @CodigoZona = CodigoZona);

        -- Validaciones de zona
        IF @existZona IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona no existe en la base de datos';
            RETURN;
        END

        IF @existZona = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona se encuentra inactiva';
            RETURN;
        END

        -- Verificar duplicados con bloqueo
        IF EXISTS (
            SELECT 1 FROM Habitat WITH (UPDLOCK)
            WHERE CodigoHabitat <> @CodigoHabitat 
                AND Nombre = TRIM(@Nombre) 
                AND EstadoHabitat = 1 
                AND CodigoZona = @CodigoZona
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Ya existe un habitat con ese nombre en esta zona';
            RETURN;
        END

        -- Actualizacion principal
        UPDATE Habitat SET
            Nombre = TRIM(@Nombre),
            Clima = TRIM(@Clima),
            DescripHabitat = TRIM(@DescripHabitat),
            CodigoZona = @CodigoZona
        WHERE CodigoHabitat = @CodigoHabitat;

        -- Verificar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al actualizar el habitat';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Habitat actualizado correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Mensaje = 'Error al actualizar habitat: ' + ERROR_MESSAGE();
    END CATCH
END;