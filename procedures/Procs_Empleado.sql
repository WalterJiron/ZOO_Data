use ZOO

------------------------------------INSERCCION EN LA TABLA EMPLEADO-------------------------------------
CREATE PROCEDURE INSERCCION_EMPLEADO
    @PrimerNE NVARCHAR(25),
    @SegundoNE NVARCHAR(25),
    @PrimerAE NVARCHAR(25),
    @SegundoAE NVARCHAR(25),
    @DIREMPLEADO NVARCHAR(200),
    @TELEFONO VARCHAR(8),
    @EMAIL NVARCHAR(100),
    @FECHAINGRE DATE,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Verificar si la direccion, telefono o email ya estan registrados
    IF EXISTS (SELECT 1 FROM Empleado WHERE DireccionE = @DIREMPLEADO)
    BEGIN
        SET @MENSAJE = 'La direccion ya esta registrada';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Empleado WHERE TelefonoE = @TELEFONO)
    BEGIN
        SET @MENSAJE = 'El telefono ya se encuentra registrado';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Empleado WHERE EmailE = @EMAIL)
    BEGIN
        SET @MENSAJE = 'El email ya esta registrado';
        RETURN;
    END

    -- Validar que los datos obligatorios no sean vacios o nulos
	--len sirve para ver la longitud
    IF (LEN(@PrimerNE) = 0 OR LEN(@SegundoNE) = 0 OR LEN(@PrimerAE) = 0 OR LEN(@SegundoAE) = 0 OR 
        LEN(@DIREMPLEADO) = 0 OR @TELEFONO IS NULL OR LEN(@EMAIL) = 0)
    BEGIN
        SET @MENSAJE = 'No pueden ser valores nulos';
        RETURN;
    END

    -- Validar que el telefono comience con 2, 5, 7 u 8
    IF (@TELEFONO NOT LIKE '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        SET @MENSAJE = 'El primer digito debe ser 2,5,7 u 8';
        RETURN;
    END

    -- Validar que la fecha de ingreso no sea mayor a la actual
    IF (@FECHAINGRE > GETDATE())
    BEGIN
        SET @MENSAJE = 'La fecha no puede ser superior a la actual';
        RETURN;
    END

    -- Insertar empleado
    INSERT INTO Empleado (PNE, SNE, PAE, SAE, DireccionE, TelefonoE, EmailE, FechaIngreso, EstadoEmpleado)
    VALUES (@PrimerNE, @SegundoNE, @PrimerAE, @SegundoAE, @DIREMPLEADO, @TELEFONO, @EMAIL, @FECHAINGRE, 1);

    SET @MENSAJE = 'Inserccion realizada con exito';
END;
GO


-------------------------------update empleado--------------------------------------
CREATE PROCEDURE UPDATE_EMPLEADO
@CDC UNIQUEIDENTIFIER,   
@PrimerNE NVARCHAR(25),
@SegundoNE NVARCHAR(25),
@PrimerAE NVARCHAR(25),
@SegundoAE NVARCHAR(25),
@DIREMPLEADO NVARCHAR(200),
@TELEFONO VARCHAR(8),
@EMAIL NVARCHAR(100),
@FECHAINGRE DATE,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Verificar si el empleado existe
    IF NOT EXISTS (SELECT 1 FROM Empleado WHERE CodigEmpleado = @CDC)
    BEGIN
        SET @MENSAJE = 'El empleado no existe';
        RETURN;
    END

    -- Validar valores unicos
    IF EXISTS (SELECT 1 FROM Empleado WHERE DireccionE = @DIREMPLEADO AND CodigEmpleado <> @CDC)
    BEGIN
        SET @MENSAJE = 'La direccion ya esta registrada';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Empleado WHERE TelefonoE = @TELEFONO AND CodigEmpleado <> @CDC)
    BEGIN
        SET @MENSAJE = 'El telefono ya este registrado';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Empleado WHERE EmailE = @EMAIL AND CodigEmpleado <> @CDC)
    BEGIN
        SET @MENSAJE = 'El correo electronico ya esta registrado';
        RETURN;
    END

    -- Validacion de datos vacios o nulos
    IF (@PrimerNE IS NULL OR @PrimerNE = '' OR 
        @SegundoNE IS NULL OR @SegundoNE = '' OR 
        @PrimerAE IS NULL OR @PrimerAE = '' OR 
        @SegundoAE IS NULL OR @SegundoAE = '' OR 
        @DIREMPLEADO IS NULL OR @DIREMPLEADO = '' OR 
        @TELEFONO IS NULL OR @TELEFONO = '' OR 
        @EMAIL IS NULL OR @EMAIL = '')
    BEGIN
        SET @MENSAJE = 'Ningun campo puede estar vacio o nulo';
        RETURN;
    END

    -- Validacion del formato de telefono
    IF(@TELEFONO NOT LIKE '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        SET @MENSAJE = 'El primer digito del telefono debe ser 2, 5, 7 o 8';
        RETURN;
    END

    -- Validacion de la fecha de ingreso
    IF(@FECHAINGRE > GETDATE() OR @FECHAINGRE < '1900-01-01')
    BEGIN
        SET @MENSAJE = 'La fecha de ingreso no es valida';
        RETURN;
    END

    -- Realizar la actualizacion
    UPDATE Empleado
    SET 
        PNE = @PrimerNE,
        SNE = @SegundoNE,
        PAE = @PrimerAE,
        SAE = @SegundoAE,
        DireccionE = @DIREMPLEADO,
        TelefonoE = @TELEFONO,
        EmailE = @EMAIL,
        FechaIngreso = @FECHAINGRE
    WHERE CodigEmpleado = @CDC;

    SET @MENSAJE = 'Actualizacion realizada con exito';
END
GO


-----------------------------ELIMINAR EMPLEADO----------------------------------
CREATE PROC ELIMINAR_EMPLEADO
@CDE UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @CodigoEmpleado AS UNIQUEIDENTIFIER
    SET @CodigoEmpleado = (SELECT CodigEmpleado FROM Empleado WHERE CodigEmpleado = @CDE);

    DECLARE @ESTADOE AS BIT
    SET @ESTADOE = (SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @CDE);

    -- Verificar si el empleado existe
    IF(@CodigoEmpleado IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no esta registrado';
        RETURN;
    END

    -- Validar si el codigo es nulo
    IF(@CDE IS NULL)
    BEGIN
        SET @MENSAJE = 'El codigo no puede ser nulo';
        RETURN;
    END

    -- Verificar si el empleado ya esta inactivo
    IF(@ESTADOE = 0)
    BEGIN
        SET @MENSAJE = 'El empleado ya esta inactivo';
        RETURN;
    END

    -- Actualizar el estado a inactivo
    UPDATE Empleado 
    SET EstadoEmpleado = 0,
		DateDelete=GETDATE()--ACTUALIZAMOS SU FECHA DE ELIMINACION
    WHERE CodigEmpleado = @CDE;

    SET @MENSAJE = 'Eliminacion realizada con exito';
END
GO


-------------------------------ACTIVAR EMPLEADO---------------------------
CREATE PROC ACTIVAREMPLEADO
@CDE UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    DECLARE @CodigoEmpleado AS UNIQUEIDENTIFIER
    SET @CodigoEmpleado = (SELECT CodigEmpleado FROM Empleado WHERE CodigEmpleado = @CDE);

    DECLARE @ESTADOE AS BIT
    SET @ESTADOE = (SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @CDE);

    -- Verificar si el empleado existe
    IF(@CodigoEmpleado IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no esta registrado';
        RETURN;
    END

    -- Validar si el codigo es nulo
    IF(@CDE IS NULL)
    BEGIN
        SET @MENSAJE = 'El codigo no puede ser nulo';
        RETURN;
    END

    -- Verificar si el empleado ya esta activo
    IF(@ESTADOE = 1)
    BEGIN
        SET @MENSAJE = 'El empleado ya esta activo';
        RETURN;
    END

    -- Actualizar el estado a activo
    UPDATE Empleado 
    SET EstadoEmpleado = 1
    WHERE CodigEmpleado = @CDE;

    SET @MENSAJE = 'Activacion realizada con exito';
END
GO



---------------SKIBIDIIIII-------