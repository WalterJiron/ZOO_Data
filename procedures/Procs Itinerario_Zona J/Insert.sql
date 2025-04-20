USE ZOO

GO

---------------------INSERCCION ITINERARIO ZONA--------------------
ALTER PROC INSERTAR_ITINERARIO_ZONA
	@IdItinerario UNIQUEIDENTIFIER,
	@IDzona UNIQUEIDENTIFIER,
	@MENSAJE NVARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
		---verificar que los parametros no sean nulos
		IF(@IdItinerario IS NULL OR @IDzona IS NULL)
		BEGIN
			SET @MENSAJE='No pueden haber parametros nulos';
			RETURN;
		END

		BEGIN TRANSACTION;

		DECLARE @EXISTENCIA_ITINERARIO AS BIT 
		SET @EXISTENCIA_ITINERARIO=(SELECT Estado FROM Itinerario WITH(UPDLOCK ,ROWLOCK) WHERE CodigoIti=@IdItinerario);

		----VERIFICAR SI EXISTE EL ITINERARIO
		IF (@EXISTENCIA_ITINERARIO IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='El itinerario no existe';
			RETURN;
		END

		IF(@EXISTENCIA_ITINERARIO = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La habitad no existe';
			RETURN;
		END

		DECLARE @EXISTENCIA_ZONA AS BIT 
		SET @EXISTENCIA_ZONA=(SELECT EstadoZona FROM Zona WITH(UPDLOCK ,ROWLOCK) WHERE CodigoZona=@IDzona)

		----VERIFICAR SI EXISTE LA ZONA
		IF (@EXISTENCIA_ZONA IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La zona no existe en la bases de datos';
			RETURN;
		END

		IF(@EXISTENCIA_ITINERARIO=0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='El itinerario se encuentra inactivo';
			RETURN;
		END
		IF EXISTS (SELECT 1 FROM ItinerarioZona WITH(UPDLOCK,ROWLOCK) WHERE Itinerario=@IdItinerario AND Zona=@IDzona)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'Ya existe la relacion';
			RETURN;
		END

		INSERT INTO ItinerarioZona(Itinerario,Zona)
		VALUES(@IdItinerario,@IDzona)

	   -- Verificar que se inserto correctamente
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error al insertar en la relacion';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE='Inserccion realizada';
	END TRY 
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @MENSAJE = 'Error al insertar en la relacion: ' + ERROR_MESSAGE();
	END CATCH
END
