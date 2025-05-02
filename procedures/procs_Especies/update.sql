USE ZOO;

GO

CREATE PROC ProcUpdateEspecie
    @CodigoEspecie UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevoCientifico NVARCHAR(100),
    @NuevaDescripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validaciones iniciales (sin acceso a BD)
        IF @CodigoEspecie IS NULL OR @NuevoNombre IS NULL OR 
           @NuevoCientifico IS NULL OR @NuevaDescripcion IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios';
            RETURN;
        END

        -- Validaciones de longitud con TRIM
        IF LEN(TRIM(@NuevoNombre)) < 3 
        BEGIN
            SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
            RETURN;
        END

        IF LEN(TRIM(@NuevoCientifico)) < 3
        BEGIN
            SET @Mensaje = 'El nombre cientifico debe tener al menos 3 caracteres';
            RETURN;
        END

        IF LEN(TRIM(@NuevaDescripcion)) < 10 
        BEGIN
            SET @Mensaje = 'La descripcion debe tener al menos 10 caracteres';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Verificar existencia
        DECLARE @codigo_exist AS BIT;
        SET @codigo_exist = (SELECT Estado FROM Especie WITH(UPDLOCK, ROWLOCK) WHERE CodigoEspecie = @CodigoEspecie);

        -- Validamsos que la especie existe
        IF @codigo_exist IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La especie no existe en la base de datos';
            RETURN;
        END

        -- Verificar si la especie esta activa
        IF @codigo_exist = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La especie esta inactiva';
            RETURN;
        END

        -- Verificar duplicados con bloqueo
        IF EXISTS (
            SELECT 1 FROM Especie WITH (UPDLOCK)
            WHERE Nombre = TRIM(@NuevoNombre) 
              AND CodigoEspecie != @CodigoEspecie 
              AND Estado = 1
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Ya existe otra especie activa con ese nombre';
            RETURN;
        END

        UPDATE Especie SET
            Nombre = TRIM(@NuevoNombre),
            NameCientifico = TRIM(@NuevoCientifico),
            Descripcion = TRIM(@NuevaDescripcion),
			DateUpdate = SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time'
        WHERE CodigoEspecie = @CodigoEspecie;

        -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al actualizar la especie';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Especie actualizada correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Mensaje = 'Error al actualizar especie: ' + ERROR_MESSAGE();
    END CATCH
END;