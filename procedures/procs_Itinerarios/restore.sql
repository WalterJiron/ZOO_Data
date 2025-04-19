USE ZOO;

GO

CREATE PROC ProcRestoreItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY

        -- Validacion inicial
        IF @CodigoItinerario IS NULL
        BEGIN
            SET @Mensaje = 'El codigo de itinerario es obligatorio';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Verificar existencia con bloqueo para evitar condiciones de carrera
        DECLARE @existItinerario AS BIT;
        SET @existItinerario = (SELECT Estado FROM Itinerario WHERE @CodigoItinerario = CodigoIti)

        IF @existItinerario IS NULL
        BEGIN
        ROLLBACK TRANSACTION;
            SET @Mensaje = 'El codigo del itinerario no se encuentra en la base de datos.';
            RETURN;
        END

        IF @existItinerario = 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El itinerario ya esta activo.';
            RETURN;
        END

        UPDATE Itinerario SET 
            Estado = 1, 
            DateDelete = NULL
        WHERE CodigoIti = @CodigoItinerario;

        -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al activar el itinerario';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Itinerario restaurado correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Mensaje = 'Error al desactivar itinerario: ' + ERROR_MESSAGE();
            
    END CATCH
END;