USE ZOO

GO

---------------------INSERCCION ITINERARIO ZONA--------------------
CREATE PROC INSERTAR_ITINERARIO_ZONA
	@IdItinerario UNIQUEIDENTIFIER,
	@IDzona UNIQUEIDENTIFIER,
	@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	---verificar que los parametros no sean nulos
	IF(@IdItinerario IS NULL OR @IDzona IS NULL)
	BEGIN
		SET @MENSAJE='No pueden haber parametros nulos';
		RETURN;
	END

	DECLARE @EXISTENCIA_ITINERARIO AS BIT 
	SET @EXISTENCIA_ITINERARIO=(SELECT Estado FROM Itinerario WHERE CodigoIti=@IdItinerario);

	----VERIFICAR SI EXISTE EL ITINERARIO
	IF (@EXISTENCIA_ITINERARIO IS NULL)
	BEGIN
		SET @MENSAJE='El itinerario no existe';
		RETURN;
	END

	IF(@EXISTENCIA_ITINERARIO=0)
	BEGIN
		SET @MENSAJE='La habitad no existe';
		RETURN
	END

	DECLARE @EXISTENCIA_ZONA AS BIT 
	SET @EXISTENCIA_ZONA=(SELECT EstadoZona FROM Zona WHERE CodigoZona=@IDzona)

	----VERIFICAR SI EXISTE LA ZONA
	IF (@EXISTENCIA_ZONA IS NULL)
	BEGIN
		SET @MENSAJE='La zona no existe';
		RETURN;
	END

	IF(@EXISTENCIA_ITINERARIO=0)
	BEGIN
		SET @MENSAJE='El itinerario se encuentra inactivo';
		RETURN;
	END

	INSERT INTO ItinerarioZona(Itinerario,Zona)
	VALUES(@IdItinerario,@IDzona)

	SET @MENSAJE='Inserccion realizada';
END

GO

---------------------Update itinerario zona---------------------------------
CREATE PROC ACTUALIZAR_ITINERARIO_ZONA
@IdItinerario UNIQUEIDENTIFIER,
@IDzona UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	---verificar que los parametros no sean nulos
	IF(@IdItinerario IS NULL OR @IDzona IS NULL)
	BEGIN
		SET @MENSAJE='No pueden haber parametros nulos';
		RETURN;
	END

	DECLARE @EXISTENCIA_ITINERARIO AS BIT 
	SET @EXISTENCIA_ITINERARIO=(SELECT Estado FROM Itinerario WHERE CodigoIti=@IdItinerario);

	----VERIFICAR SI EXISTE EL ITINERARIO
	IF (@EXISTENCIA_ITINERARIO IS NULL)
	BEGIN
		SET @MENSAJE='El itinerario no existe';
		RETURN;
	END

	IF(@EXISTENCIA_ITINERARIO=0)
	BEGIN
		SET @MENSAJE='La habitad no existe';
		RETURN
	END

	DECLARE @EXISTENCIA_ZONA AS BIT 
	SET @EXISTENCIA_ZONA=(SELECT EstadoZona FROM Zona WHERE CodigoZona=@IDzona)

	----VERIFICAR SI EXISTE LA ZONA
	IF (@EXISTENCIA_ZONA IS NULL)
	BEGIN
		SET @MENSAJE='La zona no existe';
		RETURN;
	END

	IF(@EXISTENCIA_ITINERARIO=0)
	BEGIN
		SET @MENSAJE='El itinerario se encuentra inactivo';
		RETURN;
	END
	----Ver si existe la relacion entre ambas tablas
	IF EXISTS(SELECT 1 FROM ItinerarioZona WHERE Itinerario=@IdItinerario AND Zona=@IDzona)
	BEGIN
		SET @MENSAJE='La relacion si existe';
		RETURN
	END

	UPDATE ItinerarioZona SET 
		Itinerario=@IdItinerario,
		Zona=@IDzona
	WHERE Itinerario = @IdItinerario AND Zona = @IDzona;

	SET @MENSAJE='Update realizada';
END


GO
----------------------------ELIMINAR ITINERARIOZONA-----------------------------
CREATE PROC ELIMINAR_ITINERARIOZONA
@IdItinerario UNIQUEIDENTIFIER,
@IDzona UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100)OUTPUT
AS
BEGIN

	-----VER QUE NO SEAN NULOS
	IF(@IdItinerario IS NULL OR @IDzona IS NULL)
	BEGIN
		SET @MENSAJE='No pueden ser nulos';
		RETURN;
	END
		---BUSQUEDA
	DECLARE @EXISTENCIA AS BIT
	SET @EXISTENCIA=(SELECT EstadoItZo FROM ItinerarioZona WHERE Itinerario=@IdItinerario AND Zona=@IDzona);

	IF(@EXISTENCIA IS NULL)
	BEGIN
		SET @MENSAJE='esta union no existe';
		RETURN;
	END

		-----VER SI ESTA INACTIVO
	IF (@EXISTENCIA=0)
	BEGIN
		SET @MENSAJE='Ya se encuentra inactivo';
		RETURN;
	END

	UPDATE ItinerarioZona SET 
		EstadoItZo=0
	WHERE Itinerario = @IdItinerario AND Zona = @IDzona;

    SET @MENSAJE = 'Eliminado  correctamente';
END

GO

----------------------------ACTIVAR ITINERARIOZONA-----------------------------
CREATE PROC ACTIVAR_ITINERARIOZONA
@IdItinerario UNIQUEIDENTIFIER,
@IDzona UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100)OUTPUT
AS
BEGIN

	-----VER QUE NO SEAN NULOS
	IF(@IdItinerario IS NULL OR @IDzona IS NULL)
	BEGIN
		SET @MENSAJE='No pueden ser nulos';
		RETURN;
	END
		---BUSQUEDA
	DECLARE @EXISTENCIA AS BIT
	SET @EXISTENCIA=(SELECT EstadoItZo FROM ItinerarioZona WHERE Itinerario=@IdItinerario AND Zona=@IDzona);

	IF(@EXISTENCIA IS NULL)
	BEGIN
		SET @MENSAJE='esta union no existe';
		RETURN;
	END

		-----VER SI ESTA ACTIVO
	IF (@EXISTENCIA=1)
	BEGIN
		SET @MENSAJE='Ya se encuentra activo';
		RETURN;
	END

	UPDATE ItinerarioZona SET 
		EstadoItZo=1
	WHERE Itinerario = @IdItinerario AND Zona = @IDzona;

    SET @MENSAJE = 'Activado  correctamente';
END
