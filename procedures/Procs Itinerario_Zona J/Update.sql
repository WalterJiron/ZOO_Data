USE ZOO

GO


---------------------Update itinerario zona---------------------------------
ALTER PROC ACTUALIZAR_ITINERARIO_ZONA
@IDITINERARIO_VIEJO UNIQUEIDENTIFIER,
@IDZONA_VIEJO UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@IDzona UNIQUEIDENTIFIER,
@MENSAJE NVARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		---verificar que los parametros no sean nulos
		IF(@IdItinerario IS NULL OR @IDzona IS NULL OR @IDITINERARIO_VIEJO IS NULL OR @IDZONA_VIEJO IS NULL)
		BEGIN
			SET @MENSAJE='No pueden haber parametros nulos';
			RETURN;
		END

		BEGIN TRANSACTION;

		DECLARE @EXISTENCIA_ITINERARIO AS BIT 
		SET @EXISTENCIA_ITINERARIO=(SELECT Estado FROM Itinerario WITH(UPDLOCK ,ROWLOCK) WHERE CodigoIti=@IDITINERARIO_VIEJO);

		----VERIFICAR SI EXISTE EL ITINERARIO
		IF (@EXISTENCIA_ITINERARIO IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='El itinerario no existe';
			RETURN;
		END

		IF(@EXISTENCIA_ITINERARIO=0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La habitad no existe';
			RETURN
		END

		DECLARE @EXISTENCIA_ZONA AS BIT 
		SET @EXISTENCIA_ZONA=(SELECT EstadoZona FROM Zona WITH(UPDLOCK ,ROWLOCK) WHERE CodigoZona=@IDZONA_VIEJO)

		----VERIFICAR SI EXISTE LA ZONA
		IF (@EXISTENCIA_ZONA IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La zona no existe';
			RETURN;
		END

		IF(@EXISTENCIA_ITINERARIO=0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='El itinerario se encuentra inactivo';
			RETURN;
		END
		----Ver si existe la relacion entre ambas tablas
		IF NOT EXISTS(SELECT 1 FROM ItinerarioZona WITH(UPDLOCK ,ROWLOCK) WHERE Itinerario=@IDITINERARIO_VIEJO AND Zona=@IDZONA_VIEJO)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='No existe una relacion entre el itinerario y la zona que quiere actualizar';
			RETURN;
		END

		IF  EXISTS(
			SELECT 1 FROM ItinerarioZona WITH(UPDLOCK ,ROWLOCK) 
			WHERE Itinerario=@IdItinerario AND Zona=@IDzona AND Itinerario <> @IDITINERARIO_VIEJO 
				AND Zona <> @IDZONA_VIEJO
			)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='Ya existe una relacion entre el itinerario y la zona que quiere actualizar';
			RETURN;
		END

		UPDATE ItinerarioZona SET 
			Itinerario=@IdItinerario,
			Zona=@IDzona
		WHERE Itinerario = @IDITINERARIO_VIEJO AND Zona = @IDZONA_VIEJO;

		-- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al actualizar la relacion';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE='Update realizada';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al actualizar la relacion: ' + ERROR_MESSAGE();
	END CATCH
END

