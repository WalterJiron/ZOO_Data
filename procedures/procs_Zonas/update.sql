USE ZOO;

GO

CREATE PROC ProcUpdateZona
    @CodigoZona UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevaExtension DECIMAL(10,2),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @CodigoZona IS NULL OR @NuevoNombre IS NULL OR @NuevaExtension IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios';
            RETURN;
        END

        IF LEN(TRIM(@NuevoNombre)) < 3 AND LEN(TRIM(@NuevoNombre)) > 100
        BEGIN
            SET @Mensaje = 'El nombre debe tener al menos 3 caracteres y maximo 100';
            RETURN;
        END

        -- Validacion de extension
        IF @NuevaExtension <= 0
        BEGIN
            SET @Mensaje = 'La extension debe ser mayor a cero';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Verificar existencia y estado 
        DECLARE @exist_Zona BIT;
        SET @exist_Zona = (
            SELECT EstadoZona FROM Zona WITH (UPDLOCK, ROWLOCK)
            WHERE CodigoZona = @CodigoZona
        )

        -- Validaciones de negocio
        IF @exist_Zona IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona no existe en la base de datos';
            RETURN;
        END

        IF @exist_Zona = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona esta inactiva (eliminada logicamente)';
            RETURN;
        END

        -- Verificar nombre unico con bloqueo (excluyendo la zona actual)
        IF EXISTS (
            SELECT 1 FROM Zona WITH (UPDLOCK)
            WHERE NameZona = TRIM(@NuevoNombre)
              AND CodigoZona <> @CodigoZona
              AND EstadoZona = 1
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Ya existe otra zona activa con ese nombre';
            RETURN;
        END

        UPDATE Zona SET
            NameZona = TRIM(@NuevoNombre),
            Extension = @NuevaExtension,
			DateUpdate = SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time'
        WHERE CodigoZona = @CodigoZona;

        -- Verificar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al actualizar la zona';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Zona actualizada correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
       
        SET @Mensaje = 'Error al actualizar zona: ' + ERROR_MESSAGE();
    END CATCH
END;