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

	DECLARE @EXISTSHABITAD AS BIT
	SET @EXISTSHABITAD=(SELECT EstadoHabitat FROM Habitat WHERE CodigoHabitat=@HABITAD);

	----validar que la especie existe
	IF(@EXISTSHABITAD IS NULL )
	BEGIN
		SET @MENSAJE='la habitad no existe ';
		RETURN;
	END

	IF(@EXISTSHABITAD = 0)
	BEGIN
		SET @MENSAJE='La habitad se encuentra inactiva';
		RETURN;
	END	
	
	DECLARE @EXISTESPECIE AS BIT 
	SET @EXISTESPECIE=(SELECT 1 FROM Especie WHERE CodigoEspecie=@ESPECIE);


	----validar que el habitad existe
	IF (@EXISTESPECIE IS NULL)
	BEGIN
		SET @MENSAJE='La especie no existe';
	END

	IF(@EXISTESPECIE = 0)
	BEGIN
		SET @MENSAJE='LA ESPECIE SE ENCUENTRA INACTIVA';
		RETURN
	END

	INSERT INTO EspecieHabitat(Especie,Habitat)
	VALUES(@HABITAD,@ESPECIE);

	SET @MENSAJE='Inserccion realizada';
END

GO

----------------------UPDATE ESPECIEHABITAD---------------------
CREATE PROC UPDATE_ESPECIEHABITAD
@ESPECIE UNIQUEIDENTIFIER,
@HABITAD UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	----VALIDAMOS QUE NO SEAN NULOS
	IF(@ESPECIE='' OR @HABITAD='')
	BEGIN
		SET @MENSAJE='Los parametros no pueden ser nulos';
		RETURN;
	END

	DECLARE @EXISTSHABITAD AS BIT
	SET @EXISTSHABITAD=(SELECT EstadoHabitat FROM Habitat WHERE CodigoHabitat=@HABITAD);

	----validar que la especie existe
	IF(@EXISTSHABITAD IS NULL )
	BEGIN
		SET @MENSAJE='la habitad no existe ';
		RETURN;
	END

	IF(@EXISTSHABITAD = 0)
	BEGIN
		SET @MENSAJE='La habitad se encuentra inactiva';
		RETURN;
	END	
	
	DECLARE @EXISTESPECIE AS BIT 
	SET @EXISTESPECIE=(SELECT 1 FROM Especie WHERE CodigoEspecie=@ESPECIE);


	----validar que el habitad existe
	IF (@EXISTESPECIE IS NULL)
	BEGIN
		SET @MENSAJE='La especie no existe';
	END

	IF(@EXISTESPECIE = 0)
	BEGIN
		SET @MENSAJE='LA ESPECIE SE ENCUENTRA INACTIVA';
		RETURN
	END

	---VER SI LA RELACION EXISTE
	IF EXISTS(SELECT 1 FROM EspecieHabitat WHERE Especie=@ESPECIE AND Habitat=@HABITAD)
	BEGIN
		SET @MENSAJE='La relacion ya existe en la base de datos';
		RETURN;
	END

	UPDATE EspecieHabitat SET
		Especie=@ESPECIE,
		Habitat=@HABITAD
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
   IF(@Especie IS NULL OR @Habitat IS NULL)
	BEGIN
		SET @MENSAJE='Los parametros no pueden ser nulos';
		RETURN;
	END

	DECLARE @EXISTENCIA AS BIT 
	SET @EXISTENCIA=(SELECT EstadoEH FROM EspecieHabitat WHERE Especie=@Especie AND Habitat=@Habitat);

    -- Validar si la especie existe
    IF (@EXISTENCIA IS NULL)
    BEGIN
        SET @MENSAJE = 'La union del habitad y la especie no existe';
        RETURN;
    END
	 
	IF(@EXISTENCIA = 0)
	BEGIN
		SET @MENSAJE='La union ya se encuentra inactiva';
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
   IF(@Especie IS NULL OR @Habitat IS NULL)
	BEGIN
		SET @MENSAJE='Los parametros no pueden ser nulos';
		RETURN;
	END

	DECLARE @EXISTENCIA AS BIT 
	SET @EXISTENCIA=(SELECT EstadoEH FROM EspecieHabitat WHERE Especie=@Especie AND Habitat=@Habitat);

    -- Validar si la especie existe
    IF (@EXISTENCIA IS NULL)
    BEGIN
        SET @MENSAJE = 'La union del habitad y la especie no existe';
        RETURN;
    END
	 
	IF(@EXISTENCIA = 1)
	BEGIN
		SET @MENSAJE='La union ya se encuentra activa';
		RETURN;
	END

    -- Actualizar la relacion a activa y establecer
    UPDATE EspecieHabitat SET 
        EstadoEH = 1,
		DateDelete = NULL
    WHERE Especie = @Especie AND Habitat = @Habitat;

    SET @MENSAJE = 'La relacion entre la especie y el habitat ha sido activada con exito';
END
GO
