USE ZOO

GO

ALTER PROC ELIMINAR_GUIAITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE NVARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
		-----VER SI LOS PARAMETROS NO SON NULOS
		IF(@IdEmpleado IS NULL OR @IdItinerario IS NULL)
		BEGIN
			SET @MENSAJE='No pueden ser nulos';
			RETURN;
		END

		BEGIN TRANSACTION;
		----BUSQUEDA--------------
		DECLARE @EXISTENCIA AS BIT
		SET @EXISTENCIA=(SELECT EstadoGI FROM GuiaItinerario WITH (UPDLOCK,ROWLOCK) WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario );

		-- Verificar si la relacion existe
		IF (@EXISTENCIA IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion entre empleado e itinerario no existe';
			RETURN;
		END

		IF(@EXISTENCIA=0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='Ya esta desactivado';
			RETURN;
		END

		-- Desactivar la relacion
		UPDATE GuiaItinerario 
		SET EstadoGI = 0
		WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario;

		-- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al eliminar la tabla';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Desactivada correctamente';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al eliminar la tabla: ' + ERROR_MESSAGE();
	END CATCH
END
