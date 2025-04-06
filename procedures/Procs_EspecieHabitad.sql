USE ZOO

GO

-----------INSERTAR ESPECIEHABITAD------------------------
CREATE PROC INSERTAR_ESPECIEHABITAD
@ESPECIE UNIQUEIDENTIFIER,
@HABITAD UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100)OUTPUT
AS
BEGIN
	---validar que no sean nulos
	IF(@ESPECIE='' OR @HABITAD='')
	BEGIN
		SET @MENSAJE='No puede ser parametros nulos';
		RETURN;
	END
	----validar que la especie existe
	IF NOT EXISTS(SELECT 1 FROM Habitat WHERE CodigoHabitat=@HABITAD)
	BEGIN
		SET @MENSAJE='El habitad no existe';
		RETURN;
	END
	----validar que el habitad existe
	IF NOT EXISTS(SELECT 1 FROM Especie WHERE CodigoEspecie=@ESPECIE)
	BEGIN
		SET @MENSAJE='La habitad no existe';
	END
	---ver si la relacion existe
	IF EXISTS(SELECT 1 FROM EspecieHabitat WHERE Especie=@ESPECIE AND Habitat=@HABITAD)
	BEGIN
		SET @MENSAJE='La relacion entre especie y habitad ya existe';
		RETURN;
	END

	INSERT INTO EspecieHabitat(Especie,Habitat,EstadoEH)
	VALUES(@HABITAD,@ESPECIE,1);

	SET @MENSAJE='Inserccion realizada';
END

GO

----------------------UPDATE ESPECIEHABITAD---------------------
CREATE PROC UPDATE_ESPECIEHABITAD
@ESPECIE UNIQUEIDENTIFIER,
@HABITAD UNIQUEIDENTIFIER,
@ESTADOEH BIT,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	----VALIDAMOS QUE NO SEAN NULOS
	IF(@ESPECIE='' OR @HABITAD='')
	BEGIN
		SET @MENSAJE='Los parametros no pueden ser nulos';
		RETURN;
	END
	--VALIDAMOS SI EXISTE EL HABITAD 
	IF NOT EXISTS(SELECT 1 FROM Habitat WHERE CodigoHabitat=@HABITAD)
	BEGIN
		SET @MENSAJE='El habitad no existe';
		RETURN;
	END
	--VALIDAMOS SI EXISTE LA ESPECIE
	IF NOT EXISTS(SELECT 1 FROM Especie WHERE CodigoEspecie=@ESPECIE)
	BEGIN
		SET @MENSAJE='El especie no existe';
		RETURN;
	END
	---VER SI LA RELACION EXISTE
	IF EXISTS(SELECT 1 FROM EspecieHabitat WHERE Especie=@ESPECIE AND Habitat=@HABITAD)
	BEGIN
		SET @MENSAJE='La relacion si existe';
		RETURN;
	END

	UPDATE EspecieHabitat SET
		EstadoEH=@ESTADOEH 
	WHERE Especie=@ESPECIE AND Habitat=@HABITAD;

	SET @MENSAJE='Se actualizo correctamente la relacion';
END

GO


-------------------ELIMINAR ESPECIE HABITAD------------------
CREATE PROC Desactivar_EspecieHabitat
@Especie UNIQUEIDENTIFIER,
@Habitat UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validar que los parametros no sean nulos
   IF(@Especie='' OR @Habitat='')
	BEGIN
		SET @MENSAJE='Los parametros no pueden ser nulos';
		RETURN;
	END

    -- Validar si la especie existe
    IF NOT EXISTS(SELECT 1 FROM Especie WHERE CodigoEspecie = @Especie)
    BEGIN
        SET @MENSAJE = 'La especie no existe';
        RETURN;
    END

    -- Validar si el habitat existe
    IF NOT EXISTS(SELECT 1 FROM Habitat WHERE CodigoHabitat = @Habitat)
    BEGIN
        SET @MENSAJE = 'El habitat no existe';
        RETURN;
    END

    -- Validar si la relacion existe y esta activa
    IF NOT EXISTS(SELECT 1 FROM EspecieHabitat WHERE Especie = @Especie AND Habitat = @Habitat AND EstadoEH = 1)
    BEGIN
        SET @MENSAJE = 'La relacion entre la especie y el habitat no existe o ya esta desactivada';
        RETURN;
    END

    -- Actualizar la relacion a inactiva y establecer la fecha de eliminacion
    UPDATE EspecieHabitat SET 
        EstadoEH = 0,
        DateDelete = GETDATE()  -- Asignamos la fecha de eliminacion actual
    WHERE Especie = @Especie AND Habitat = @Habitat;

    SET @MENSAJE = 'La relacion entre la especie y el habitat ha sido desactivada con exito';
END
GO

----------------------activar especiehabitad--------------------------
CREATE PROC Activar_EspecieHabitat
@Especie UNIQUEIDENTIFIER,
@Habitat UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validar que los parametros no sean nulos
   IF(@Especie='' OR @Habitat='')
	BEGIN
		SET @MENSAJE='Los parametros no pueden ser nulos';
		RETURN;
	END

    -- Validar si la especie existe
    IF NOT EXISTS(SELECT 1 FROM Especie WHERE CodigoEspecie = @Especie)
    BEGIN
        SET @MENSAJE = 'La especie no existe';
        RETURN;
    END

    -- Validar si el habitat existe
    IF NOT EXISTS(SELECT 1 FROM Habitat WHERE CodigoHabitat = @Habitat)
    BEGIN
        SET @MENSAJE = 'El habitat no existe';
        RETURN;
    END

    -- Validar si la relacion existe y esta inactiva
    IF NOT EXISTS(SELECT 1 FROM EspecieHabitat WHERE Especie = @Especie AND Habitat = @Habitat AND EstadoEH = 0)
    BEGIN
        SET @MENSAJE = 'La relacion entre la especie y el habitat ya existe o ya esta activada';
        RETURN;
    END

    -- Actualizar la relacion a inactiva y establecer la fecha de eliminacion
    UPDATE EspecieHabitat SET 
        EstadoEH = 0
    WHERE Especie = @Especie AND Habitat = @Habitat;

    SET @MENSAJE = 'La relacion entre la especie y el habitat ha sido desactivada con exito';
END
GO
