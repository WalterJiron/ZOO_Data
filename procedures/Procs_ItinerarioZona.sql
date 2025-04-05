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

	----VERIFICAR SI EXISTE EL ITINERARIO
	IF NOT EXISTS(SELECT 1 FROM Itinerario WHERE CodigoIti=@IdItinerario)
	BEGIN
		SET @MENSAJE='El itinerario no existe';
		RETURN;
	END
	----VERIFICAR SI EXISTE LA ZONA
	IF NOT EXISTS(SELECT 1 FROM Zona WHERE CodigoZona=@IDzona)
	BEGIN
		SET @MENSAJE='La zona no existe';
		RETURN;
	END
	----Ver si existe la relacion entre ambas tablas
	IF EXISTS(SELECT 1 FROM ItinerarioZona WHERE Itinerario=@IdItinerario AND Zona=@IDzona)
	BEGIN
		SET @MENSAJE='La relacion si existe';
		RETURN
	END

	INSERT INTO ItinerarioZona(Itinerario,Zona,EstadoItZo)
	VALUES(@IdItinerario,@IDzona,1)

	SET @MENSAJE='Inserccion realizada';
END

GO

----------------------------ELIMINAR ITINERARIOZONA-----------------------------
CREATE PROC ELIMNAR_ITINERARIOZONA
@IdItinerario UNIQUEIDENTIFIER,
@IDzona UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100)OUTPUT
AS
BEGIN
	------------VERIFICAR SI EXISTE LA RELACION ENTRE AMBAS TABLAS
	IF NOT EXISTS(SELECT 1 FROM ItinerarioZona WHERE Itinerario=@IdItinerario AND Zona=@IDzona)
	BEGIN
		SET @MENSAJE='La relacion entre itinerario y zona no existe';
		RETURN;
	END
	-----VER SI ESTA INACTIVO
	IF EXISTS(SELECT 1 FROM ItinerarioZona WHERE Itinerario=@IdItinerario AND Zona=@IDzona AND EstadoItZo=0)
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
	------------VERIFICAR SI EXISTE LA RELACION ENTRE AMBAS TABLAS
	IF NOT EXISTS(SELECT 1 FROM ItinerarioZona WHERE Itinerario=@IdItinerario AND Zona=@IDzona)
	BEGIN
		SET @MENSAJE='La relacion entre itinerario y zona no existe';
		RETURN;
	END
	-----VER SI ESTA ACTIVO
	IF EXISTS(SELECT 1 FROM ItinerarioZona WHERE Itinerario=@IdItinerario AND Zona=@IDzona AND EstadoItZo=1)
	BEGIN
		SET @MENSAJE='Ya se encuentra activo';
		RETURN;
	END

	UPDATE ItinerarioZona SET 
		EstadoItZo=1
	WHERE Itinerario = @IdItinerario AND Zona = @IDzona;

    SET @MENSAJE = 'Activado  correctamente';
END
