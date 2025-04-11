USE ZOO


GO

-----------------------INSERTAR CUIDADOR ESPECIE------------------------------
CREATE PROC Insertar_CuidadorEspecie
@IdEmpleado UNIQUEIDENTIFIER,
@IdEspecie UNIQUEIDENTIFIER,
@FechaAsignacion DATE,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validar que los parametros no sean nulos
    IF (@IdEmpleado IS NULL OR @IdEspecie IS NULL OR @FechaAsignacion IS NULL)
    BEGIN
        SET @MENSAJE = 'No pueden haber parametros nulos';
        RETURN;
    END
	
    -- Validar que la fecha de asignacion no sea mayor a la fecha actual
    IF (@FechaAsignacion > GETDATE())
    BEGIN
        SET @MENSAJE = 'La fecha de asignacion no puede ser futura';
        RETURN;
    END

	DECLARE @EXSITS_EMPLEADO AS BIT
	SET @EXSITS_EMPLEADO = (SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @IdEmpleado);

    -- Validar que el empleado exista
    IF (@EXSITS_EMPLEADO IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no existe';
        RETURN;
    END

	IF(@EXSITS_EMPLEADO = 0)
	BEGIN
		SET @MENSAJE = 'El empleado esta inactivo';
		RETURN;
	END

	DECLARE @EXIST_ESPECIE AS BIT
	SET @EXIST_ESPECIE = (SELECT Estado FROM Especie WHERE CodigoEspecie = @IdEspecie);

    -- Validar que la especie exista
    IF (@EXIST_ESPECIE IS NULL)
    BEGIN
        SET @MENSAJE = 'La especie no existe';
        RETURN;
    END

	IF(@EXIST_ESPECIE = 0)
	BEGIN
		SET @MENSAJE='La especie se encuentra inactiva';
	END

    -- Insertar el registro
    INSERT INTO CuidadorEspecie (IdEmpleado, IdEspecie, FechaAsignacion)
    VALUES (@IdEmpleado, @IdEspecie, @FechaAsignacion);

    SET @MENSAJE = 'Insercion realizada con exito';
END;

GO

------------------------------------update ---------------------------------
CREATE PROC Actualizar_CuidadorEspecie
@IdEmpleado UNIQUEIDENTIFIER,
@IdEspecie UNIQUEIDENTIFIER,
@FechaAsignacion DATE,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validar que los parametros no sean nulos
    IF (@IdEmpleado IS NULL OR @IdEspecie IS NULL OR @FechaAsignacion IS NULL)
    BEGIN
        SET @MENSAJE = 'No pueden haber parametros nulos';
        RETURN;
    END
	
    -- Validar que la fecha de asignacion no sea mayor a la fecha actual
    IF (@FechaAsignacion > GETDATE())
    BEGIN
        SET @MENSAJE = 'La fecha de asignacion no puede ser futura';
        RETURN;
    END

	DECLARE @EXSITS_EMPLEADO AS BIT
	SET @EXSITS_EMPLEADO = (SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @IdEmpleado);

    -- Validar que el empleado exista
    IF (@EXSITS_EMPLEADO IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no existe';
        RETURN;
    END

	IF(@EXSITS_EMPLEADO = 0)
	BEGIN
		SET @MENSAJE = 'El empleado esta inactivo';
		RETURN;
	END

	DECLARE @EXIST_ESPECIE AS BIT
	SET @EXIST_ESPECIE = (SELECT Estado FROM Especie WHERE CodigoEspecie = @IdEspecie);

    -- Validar que la especie exista
    IF (@EXIST_ESPECIE IS NULL)
    BEGIN
        SET @MENSAJE = 'La especie no existe';
        RETURN;
    END

	IF(@EXIST_ESPECIE = 0)
	BEGIN
		SET @MENSAJE='La especie se encuentra inactiva';
	END

    -- Actualizar la fecha de asignacion
    UPDATE CuidadorEspecie SET 
			FechaAsignacion = @FechaAsignacion
    WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie AND FechaAsignacion = @FechaAsignacion;

    SET @MENSAJE = 'Actualizacion realizada con exito';
END;

GO
---------------------------------ELIMINAR------------------------------------
CREATE PROCEDURE Eliminar_CuidadorEspecie
@IdEmpleado UNIQUEIDENTIFIER,
@IdEspecie UNIQUEIDENTIFIER,
@FechaAsignacion DATE,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Declarar una variable para almacenar el estado de la relacion
    DECLARE @EstadoActual BIT;

    -- Obtener el estado actual de la relacion
    SELECT @EstadoActual = EstadoCE
    FROM CuidadorEspecie
    WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie AND FechaAsignacion = @FechaAsignacion;

    -- Validar si la relacion existe
    IF @EstadoActual IS NULL
    BEGIN
        SET @MENSAJE = 'La relacion no existe';
        RETURN;
    END

    -- Validar si ya esta inactiva
    IF @EstadoActual = 0
    BEGIN
        SET @MENSAJE = 'La relacion ya esta inactiva';
        RETURN;
    END

    -- Cambiar estado a inactiva
    UPDATE CuidadorEspecie
    SET EstadoCE = 0
    WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie AND FechaAsignacion = @FechaAsignacion;

    SET @MENSAJE = 'La relacion ha sido desactivada con exito';
END

GO

---------------------------activar---------------------------------
CREATE PROCEDURE Activar_CuidadorEspecie
@IdEmpleado UNIQUEIDENTIFIER,
@IdEspecie UNIQUEIDENTIFIER,
@FechaAsignacion DATE,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Declarar una variable para almacenar el estado de la relacion
    DECLARE @EstadoActual BIT;

    -- Obtener el estado actual de la relacion
    SELECT @EstadoActual = EstadoCE FROM CuidadorEspecie WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie AND FechaAsignacion = @FechaAsignacion;

    -- Validar si la relacion existe
    IF @EstadoActual IS NULL
    BEGIN
        SET @MENSAJE = 'La relacion no existe';
        RETURN;
    END

    -- Validar si ya está activa
    IF @EstadoActual = 1
    BEGIN
        SET @MENSAJE = 'La relacion ya esta activa';
        RETURN;
    END

    -- Cambiar estado a activa
    UPDATE CuidadorEspecie
    SET EstadoCE = 1
    WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie AND FechaAsignacion = @FechaAsignacion;

    SET @MENSAJE = 'La relacion ha sido activada con exito';
END




