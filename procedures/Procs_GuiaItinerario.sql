USE ZOO

GO
--------------------------INSERCCION GUIAITINERARIO---------------------------
CREATE PROC INSERTAR_GUIAITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Verificar que los parametros no sean nulos
    IF @IdEmpleado IS NULL OR @IdItinerario IS NULL
    BEGIN
        SET @MENSAJE = 'No pueden haber parametros nulos';
        RETURN;
    END

	DECLARE @EXIST_EMPLEADO AS BIT 
	SET @EXIST_EMPLEADO =(SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @IdEmpleado);

    -- Verificar si existe el empleado
    IF (@EXIST_EMPLEADO IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no existe';
        RETURN;
    END

	IF(@EXIST_EMPLEADO = 0)
	BEGIN
		SET @MENSAJE='El empleado esta inactivo';
		RETURN;
	END

	DECLARE @EXIST_ITINERARIO AS BIT
	SET @EXIST_ITINERARIO=(SELECT Estado FROM Itinerario WHERE CodigoIti = @IdItinerario);

    -- Verificar si existe el itinerario
    IF (@EXIST_ITINERARIO IS NULL)
    BEGIN
        SET @MENSAJE = 'El itinerario no existe';
        RETURN;
    END

    IF(@EXIST_ITINERARIO = 0)
	BEGIN
		SET @MENSAJE='El itinerario esta inactivo';
		RETURN;
	END

    -- Insertar la relacion
    INSERT INTO GuiaItinerario (Empleado, Itinerario)
    VALUES (@IdEmpleado, @IdItinerario);

    SET @MENSAJE = 'Insercion realizada correctamente';
END


GO

---------------------------upadte GUIAITINERARIO---------------------------------
CREATE PROC UPDATE_GUIAITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
     -- Verificar que los parametros no sean nulos
    IF @IdEmpleado IS NULL OR @IdItinerario IS NULL
    BEGIN
        SET @MENSAJE = 'No pueden haber parametros nulos';
        RETURN;
    END

	DECLARE @EXIST_EMPLEADO AS BIT 
	SET @EXIST_EMPLEADO =(SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @IdEmpleado);

    -- Verificar si existe el empleado
    IF (@EXIST_EMPLEADO IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no existe';
        RETURN;
    END

	IF(@EXIST_EMPLEADO = 0)
	BEGIN
		SET @MENSAJE='El empleado esta inactivo';
		RETURN;
	END

	DECLARE @EXIST_ITINERARIO AS BIT
	SET @EXIST_ITINERARIO=(SELECT Estado FROM Itinerario WHERE CodigoIti = @IdItinerario);

    -- Verificar si existe el itinerario
    IF (@EXIST_ITINERARIO IS NULL)
    BEGIN
        SET @MENSAJE = 'El itinerario no existe';
        RETURN;
    END

    IF(@EXIST_ITINERARIO = 0)
	BEGIN
		SET @MENSAJE='El itinerario esta inactivo';
		RETURN;
	END

    -- Verificar si la relacion ya existe
    IF EXISTS(SELECT 1 FROM GuiaItinerario WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario)
    BEGIN
        SET @MENSAJE = 'La relacion ya existe';
        RETURN;
    END

	UPDATE GuiaItinerario SET 
		Empleado=@IdEmpleado,
		Itinerario=@IdItinerario
	WHERE Empleado=@IdEmpleado AND Itinerario=@IdItinerario

	SET @MENSAJE='Update con exito';

END

GO
-----------------ELIMINAR GUIAITINERARIO--------------------------
CREATE PROC ELIMINAR_GUIAITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	-----VER SI LOS PARAMETROS NO SON NULOS
	IF(@IdEmpleado IS NULL OR @IdItinerario IS NULL)
	BEGIN
		SET @MENSAJE='No pueden ser nulos';
		RETURN;
	END
	----BUSQUEDA--------------
	DECLARE @EXISTENCIA AS BIT
	SET @EXISTENCIA=(SELECT EstadoGI FROM GuiaItinerario WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario );

    -- Verificar si la relacion existe
    IF (@EXISTENCIA IS NULL)
    BEGIN
        SET @MENSAJE = 'La relacion entre empleado e itinerario no existe';
        RETURN;
    END

	IF(@EXISTENCIA=0)
	BEGIN
		SET @MENSAJE='Ya esta desactivado';
		RETURN;
	END

    -- Desactivar la relacion
    UPDATE GuiaItinerario 
    SET EstadoGI = 0
    WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario;

    SET @MENSAJE = 'Desactivada correctamente';
END

GO

------------------------------------ACTIVAR GUIITINERARIO----------------------------
CREATE PROC ACTIVAR_GUIAITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	-----VER SI LOS PARAMETROS NO SON NULOS
	IF(@IdEmpleado IS NULL OR @IdItinerario IS NULL)
	BEGIN
		SET @MENSAJE='No pueden ser nulos';
		RETURN;
	END
	----BUSQUEDA--------------
	DECLARE @EXISTENCIA AS BIT
	SET @EXISTENCIA=(SELECT EstadoGI FROM GuiaItinerario WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario );

    -- Verificar si la relacion existe
    IF (@EXISTENCIA IS NULL)
    BEGIN
        SET @MENSAJE = 'La relacion entre empleado e itinerario no existe';
        RETURN;
    END

	IF(@EXISTENCIA=1)
	BEGIN
		SET @MENSAJE='Ya esta activado';
		RETURN;
	END
    -- Desactivar la relacion
    UPDATE GuiaItinerario 
    SET EstadoGI = 1
    WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario;

    SET @MENSAJE = 'Desactivada correctamente';
END
