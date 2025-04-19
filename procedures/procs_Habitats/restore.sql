USE ZOO;

GO

CREATE PROC ProcRestoreHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @CodigoHabitat IS NULL
        BEGIN
            SET @Mensaje = 'El codigo de habitat es obligatorio';
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @existHabitad AS BIT;
        SET @existHabitad = (
            SELECT EstadoHabitat FROM Habitat WITH(UPDLOCK, ROWLOCK)
            WHERE CodigoHabitat = @CodigoHabitat);

        -- Validaciones de negocio
        IF @existHabitad IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El habitat no existe en la base de datos';
            RETURN;
        END

        IF @existHabitad = 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El habitat ya se encuentra activo';
            RETURN;
        END

        -- Verificar si la zona asociada esta activa
        DECLARE @exist_zona AS BIT;
        SET @exist_zona = (
            SELECT EstadoZona
            FROM Zona
            WHERE CodigoZona = (
                    SELECT CodigoZona
                    FROM Habitat WITH(UPDLOCK, ROWLOCK)
                    WHERE CodigoHabitat = @CodigoHabitat
                )
        )

        IF @exist_zona IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'No se puede restaurar, la zona asociada no se encuentra en la base de datos';
            RETURN;
        END

        IF @exist_zona = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'No se puede restaurar, la zona asociada esta inactiva';
            RETURN;
        END


        UPDATE Habitat SET 
            EstadoHabitat = 1, 
            DateDelete = NULL
        WHERE CodigoHabitat = @CodigoHabitat;

        -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al restaurar el habitat';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Habitat restaurado correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
       
        SET @Mensaje = 'Error al restaurar habitat: ' + ERROR_MESSAGE();
    END CATCH
END;