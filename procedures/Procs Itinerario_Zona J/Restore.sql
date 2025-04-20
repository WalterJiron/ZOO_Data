USE ZOO

GO

----------------------------ACTIVAR ITINERARIOZONA-----------------------------
CREATE PROC ACTIVAR_ITINERARIOZONA
@IdItinerario UNIQUEIDENTIFIER,
@IDzona UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100)OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
		-----VER QUE NO SEAN NULOS
		IF(@IdItinerario IS NULL OR @IDzona IS NULL)
		BEGIN
			SET @MENSAJE='No pueden ser nulos';
			RETURN;
		END

		BEGIN TRANSACTION;
			---BUSQUEDA
		DECLARE @EXISTENCIA AS BIT
		SET @EXISTENCIA=(SELECT EstadoItZo FROM ItinerarioZona WITH(UPDLOCK ,ROWLOCK) 
		WHERE Itinerario=@IdItinerario AND Zona=@IDzona);

		IF(@EXISTENCIA IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='esta union no existe';
			RETURN;
		END

			-----VER SI ESTA ACTIVO
		IF (@EXISTENCIA=1)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='Ya se encuentra activo';
			RETURN;
		END

		UPDATE ItinerarioZona SET 
			EstadoItZo=1
		WHERE Itinerario = @IdItinerario AND Zona = @IDzona;

		-- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al activar la relacion';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Activado  correctamente';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al activar la relacion: ' + ERROR_MESSAGE();
	END CATCH
END


-------------------------------------------------------------------
