Use ZOO

--------Inserccion HabitadContinentes-------------------------
Create Proc Insertar_HabitadContinente
@Habitad UNIQUEIDENTIFIER,
@CONTINENTE INT,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	---VALIDAR QUE NO SEAN NULOS----------
	IF(@Habitad='' OR @CONTINENTE='')
	BEGIN
		SET @MENSAJE='No puede ser nulo';
		RETURN;
	END
	------Validar si existe el habitad de la tabla habitad
	IF NOT EXISTS(SELECT 1 FROM Habitat WHERE CodigoHabitat=@Habitad)
	BEGIN
		SET @MENSAJE='El habitad no existe';
		RETURN;
	END
	----Validar si el continente existe
	IF NOT EXISTS(SELECT 1 FROM Continente WHERE IdCont=@CONTINENTE)
	BEGIN
		SET @MENSAJE='El continente no existe';
		RETURN;
	END

	IF EXISTS(SELECT 1 FROM HabitatContinente WHERE Habitat=@Habitad AND Cont=@CONTINENTE)
	BEGIN
		SET @MENSAJE='La relacion entre las dos tablas si existe';
		RETURN;
	END

	INSERT INTO HabitatContinente (Habitat,Cont,EstadoHC)
	VALUES(@Habitad,@CONTINENTE,1);

	SET @MENSAJE='Inserccion con exito';
END

GO

------------------ELIMINACION HABITADCONTINENTE---------------------
CREATE PROC Eliminar_HabitatContinente
@Habitat UNIQUEIDENTIFIER,
@Cont INT,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	-- Verificar si la relacion existe y si essat inactiva
	IF NOT EXISTS (SELECT 1 FROM HabitatContinente WHERE Habitat = @Habitat AND Cont = @Cont AND EstadoHC=0)
	BEGIN
		SET @MENSAJE = 'La relacion no existe o ya esta inactiva';
		RETURN;
	END
	
	-- Cambiar estado a inactivo 
	UPDATE HabitatContinente
	SET EstadoHC = 0
	WHERE Habitat = @Habitat AND Cont = @Cont;

	SET @MENSAJE = 'La relacion ha sido desactivada';
END;
GO


--------------------------activar habitadContinente-----------------
CREATE PROC Activar_HabitatContinente
@Habitat UNIQUEIDENTIFIER,
@Cont INT,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	-- Verificar si la relacion existe o esta activa
	IF NOT EXISTS (SELECT 1 FROM HabitatContinente WHERE Habitat = @Habitat AND Cont = @Cont AND EstadoHC=1)
	BEGIN
		SET @MENSAJE = 'La relacion no existe';
		RETURN;
	END
	
	-- Cambiar estado a activo 
	UPDATE HabitatContinente
	SET EstadoHC = 1
	WHERE Habitat = @Habitat AND Cont = @Cont;

	SET @MENSAJE = 'La relacion ha sido activada';
END;
GO


-----------------es lo unico que pude ver es estos procs---------------
