Use ZOO

--------Inserccion HabitadContinentes-------------------------
Create Proc Insertar_HabitadContinente
@Habitad UNIQUEIDENTIFIER,
@CONTINENTE INT,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	-- Validar que los parametros no sean nulos
    IF @Habitad IS NULL OR @CONTINENTE IS NULL
    BEGIN
        SET @MENSAJE = 'No pueden haber parametros nulos';
        RETURN;
    END;

	DECLARE @EXIST_HABITAD AS BIT 
	SET @EXIST_HABITAD=(SELECT EstadoHabitat FROM Habitat WHERE CodigoHabitat = @Habitad);

    -- Validar si el habitat existe
    IF (@EXIST_HABITAD IS NULL)
    BEGIN
        SET @MENSAJE = 'El habitat no existe';
        RETURN;
    END;

	IF(@EXIST_HABITAD = 0)
	BEGIN
		SET @MENSAJE='El habitad se encuentra inactiva';
		RETURN;
	END

	INSERT INTO HabitatContinente (Habitat,Cont)
	VALUES(@Habitad,@CONTINENTE);

	SET @MENSAJE='Inserccion con exito';
END

GO
-----------------------------------UPDATE HABITADCONTINENTE
CREATE PROCEDURE Update_HabitatContinente
@Habitad UNIQUEIDENTIFIER,
@CONTINENTE INT,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validar que los parametros no sean nulos
    IF @Habitad IS NULL OR @CONTINENTE IS NULL
    BEGIN
        SET @MENSAJE = 'No pueden haber parametros nulos';
        RETURN;
    END;

	DECLARE @EXIST_HABITAD AS BIT 
	SET @EXIST_HABITAD=(SELECT EstadoHabitat FROM Habitat WHERE CodigoHabitat = @Habitad);

    -- Validar si el habitat existe
    IF (@EXIST_HABITAD IS NULL)
    BEGIN
        SET @MENSAJE = 'El habitat no existe';
        RETURN;
    END;

	IF(@EXIST_HABITAD = 0)
	BEGIN
		SET @MENSAJE='El habitad se encuentra inactiva';
		RETURN;
	END

    -- Validar si la relacion  existe
    IF NOT EXISTS (SELECT 1 FROM HabitatContinente WHERE Habitat = @Habitad AND Cont = @CONTINENTE)
    BEGIN
        SET @MENSAJE = 'No existe una relacion para actualizar';
        RETURN;
    END;

    -- Actualizar la relacion
    UPDATE HabitatContinente SET
		Habitat=@Habitad,
		Cont=@CONTINENTE
    WHERE Habitat = @Habitad AND Cont = @CONTINENTE;
		
    SET @MENSAJE = 'Actualizacion realizada con exito';
END;
GO

GO
------------------ELIMINACION HABITADCONTINENTE---------------------
CREATE PROC Eliminar_HabitatContinente
@Habitat UNIQUEIDENTIFIER,
@Cont INT,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	---VERIFICAR SI NO SON NULOS
	IF(@Habitat IS NULL OR @Cont IS NULL)
	BEGIN
		SET @MENSAJE='No pueden ser nulos';
		RETURN;
	END
	 	----------BUSQUEDA-------
	Declare @existencia AS BIT
	SET @existencia=(SELECT EstadoHC FROM HabitatContinente WHERE Habitat = @Habitat AND Cont = @Cont);

	-- Verificar si la relacion existe 
	IF(@existencia IS NULL)
	BEGIN
		SET @MENSAJE = 'La relacion no existe ';
		RETURN;
	END

	---VERIFICAR QUE ESTE INACTIVA
	IF(@existencia=0)
	BEGIN
		SET @MENSAJE='Esta inactiva';
	END
	-- Cambiar estado a inactivo 
	UPDATE HabitatContinente SET
		EstadoHC = 0
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
	---VERIFICAR SI NO SON NULOS
	IF(@Habitat IS NULL OR @Cont IS NULL)
	BEGIN
		SET @MENSAJE='No pueden ser nulos';
		RETURN;
	END
	 	----------BUSQUEDA-------
	Declare @existencia AS BIT
	SET @existencia=(SELECT EstadoHC FROM HabitatContinente WHERE Habitat = @Habitat AND Cont = @Cont);

	-- Verificar si la relacion existe 
	IF(@existencia IS NULL)
	BEGIN
		SET @MENSAJE = 'La relacion no existe ';
		RETURN;
	END

	---VERIFICAR QUE ESTE ACTIVA
	IF(@existencia=1)
	BEGIN
		SET @MENSAJE='Esta activa';
	END
	
	-- Cambiar estado a activo 
	UPDATE HabitatContinente SET
			EstadoHC = 1
	WHERE Habitat = @Habitat AND Cont = @Cont;

	SET @MENSAJE = 'La relacion ha sido activada';
END;
GO


-----------------es lo unico que pude ver es estos procs---------------
