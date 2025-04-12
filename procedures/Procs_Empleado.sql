use ZOO; 

GO

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
    @IdCargo UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN 
    -- Validamos que los datos obligatorios no sean vacios o nulos
    IF (LEN(@PrimerNE) = 0 OR LEN(@SegundoNE) = 0 OR LEN(@PrimerAE) = 0 OR LEN(@SegundoAE) = 0 OR
        LEN(@DIREMPLEADO) = 0 OR @TELEFONO IS NULL OR LEN(@EMAIL) = 0 OR @IdCargo IS NULL)
    BEGIN
        SET @MENSAJE = 'Los campos no pueden ser valores nulos';
        RETURN;
    END

    -- Validamos que los nombre no sean muy cortos
    IF LEN(@PrimerNE) < 3 OR LEN(@SegundoNE) < 3 OR LEN(@PrimerAE) < 3 OR LEN(@SegundoAE) < 3
    BEGIN
        SET @MENSAJE = 'Los nombres y apellidos deben tener al menos 3 caracteres';
        RETURN;
    END

    -- Validamos que los nombre no sean muy largo
    IF LEN(@PrimerNE) > 25 OR LEN(@SegundoNE) > 25 OR LEN(@PrimerAE) > 25 OR LEN(@SegundoAE) > 25
    BEGIN
        SET @MENSAJE = 'Los nombres y apellidos no pueden tener mas de 25 caracteres';
        RETURN;
    END

    -- Validamos que la direccion no sea muy corta o muy larga
    IF LEN(@DIREMPLEADO) < 10 OR LEN(@DIREMPLEADO) < 10
    BEGIN
        SET @MENSAJE = 'La direccion debe tener al menos 10 caracteres y un maximo de 200 caracteres.';
        RETURN;
    END

    -- Validamos que el cargo exista
    DECLARE @cargo_existe BIT;
    SET @cargo_existe = (SELECT EstadoCargo FROM Cargo WHERE CodifoCargo = @IdCargo);

    IF (@cargo_existe IS NULL)
    BEGIN
        SET @MENSAJE = 'El cargo no existe';
        RETURN;
    END

    -- Miramso que el cargo este activo
    IF (@cargo_existe = 0)
    BEGIN
        SET @MENSAJE = 'El cargo no esta activo';
        RETURN;
    END

    ------------------------- Verificar si la telefono o email ya estan registrados -------------------------
    DECLARE @CampoDuplicado NVARCHAR(15);
    SELECT TOP 1
        @CampoDuplicado = 
            CASE 
                WHEN TelefonoE = @TELEFONO THEN 'telefono'
                WHEN EmailE = @EMAIL THEN 'email'
            END
    FROM Empleado
    WHERE TelefonoE = @TELEFONO OR EmailE = @EMAIL;

    IF @CampoDuplicado IS NOT NULL
    BEGIN
        SET @MENSAJE = 'El ' + @CampoDuplicado + ' ya está registrado';
        RETURN;
    END

    -- Validar que el telefono comience con 2, 5, 7 u 8
    IF (@TELEFONO NOT LIKE '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        SET @MENSAJE = 'El primer digito debe ser 2,5,7 u 8 y los demas numeros deben ser numericos.';
        RETURN;
    END

    -- Validamos que la fecha de ingreso no sea mayor que la fecha de inauguracion
    IF (@FECHAINGRE < TRY_CONVERT(DATE, '2000/05/18'))
    BEGIN
        SET @MENSAJE = 'La fecha de ingreso no puede ser inferior a la fecha de inauguracion';
        RETURN;
    END

    IF (@FECHAINGRE < TRY_CONVERT(DATE, DATEADD(MONTH, 1, GETDATE())))
    BEGIN
        SET @MENSAJE = 'La fecha de ingreso no puede ser superior a un mes.';
        RETURN;
    END

    -- Insertar empleado
    INSERT INTO Empleado
        (PNE, SNE, PAE, SAE, DireccionE, TelefonoE, EmailE, FechaIngreso, IdCargo)
    VALUES(
        @PrimerNE, @SegundoNE, @PrimerAE, @SegundoAE, @DIREMPLEADO,
        @TELEFONO, @EMAIL, @FECHAINGRE, @IdCargo
    );

    SET @MENSAJE = 'Inserccion realizada con exito';
END;

GO

-------------------------------update empleado--------------------------------------
CREATE PROCEDURE UPDATE_EMPLEADO
    @CDE UNIQUEIDENTIFIER,
    @PrimerNE NVARCHAR(25),
    @SegundoNE NVARCHAR(25),
    @PrimerAE NVARCHAR(25),
    @SegundoAE NVARCHAR(25),
    @DIREMPLEADO NVARCHAR(200),
    @TELEFONO VARCHAR(8),
    @EMAIL NVARCHAR(100),
    @FECHAINGRE DATE,
    @IdCargo UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validamos que los datos obligatorios no sean vacios o nulos
    --len sirve para ver la longitud
    IF (LEN(@CDE)=0 OR LEN(@PrimerNE) = 0 OR LEN(@SegundoNE) = 0 OR LEN(@PrimerAE) = 0 OR LEN(@SegundoAE) = 0 OR
        LEN(@DIREMPLEADO) = 0 OR @TELEFONO IS NULL OR LEN(@EMAIL) = 0 OR @IdCargo IS NULL)
    BEGIN
        SET @MENSAJE = 'Los campos no pueden ser valores nulos';
        RETURN;
    END

    -- Validamos que el empleado exista
    DECLARE @empleado_existe BIT;
    SET @empleado_existe = (SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @CDE);

    -- Verificar si el empleado existe
    IF(@empleado_existe IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no esta registrado';
        RETURN;
    END

    -- Miramos que este activo (Empleado)
    IF(@empleado_existe = 0)
    BEGIN
        SET @MENSAJE = 'El empleado ya esta inactivo';
        RETURN;
    END

    -- Validamos que el cargo exista
    IF LEN(@PrimerNE) < 3 OR LEN(@SegundoNE) < 3 OR LEN(@PrimerAE) < 3 OR LEN(@SegundoAE) < 3
    BEGIN
        SET @MENSAJE = 'Los nombres y apellidos deben tener al menos 3 caracteres';
        RETURN;
    END

    -- Validamos que el cargo exista
    IF LEN(@PrimerNE) > 25 OR LEN(@SegundoNE) > 25 OR LEN(@PrimerAE) > 25 OR LEN(@SegundoAE) > 25
    BEGIN
        SET @MENSAJE = 'Los nombres y apellidos no pueden tener mas de 25 caracteres';
        RETURN;
    END

    -- Validamos que el cargo exista
    IF LEN(@DIREMPLEADO) < 5
    BEGIN
        SET @MENSAJE = 'La direccion debe tener al menos 5 caracteres';
        RETURN;
    END

    -- Validamos que el cargo exista
    DECLARE @cargo_existe BIT;
    SET @cargo_existe = (SELECT EstadoCargo FROM Cargo WHERE CodifoCargo = @IdCargo);

    IF (@cargo_existe IS NULL)
    BEGIN
        SET @MENSAJE = 'El cargo no existe';
        RETURN;
    END

    -- Miramso que el cargo este activo
    IF (@cargo_existe = 0)
    BEGIN
        SET @MENSAJE = 'El cargo no esta activo';
        RETURN;
    END

    ------------------------- Verificar si la telefono o email ya estan registrados -------------------------
    DECLARE @CampoDuplicado NVARCHAR(15);
    SELECT TOP 1
        @CampoDuplicado = 
            CASE 
                WHEN TelefonoE = @TELEFONO THEN 'telefono'
                WHEN EmailE = @EMAIL THEN 'email'
            END
    FROM Empleado
    WHERE TelefonoE = @TELEFONO OR EmailE = @EMAIL AND CodigEmpleado <> @CDE;

    IF @CampoDuplicado IS NOT NULL
    BEGIN
        SET @MENSAJE = 'El ' + @CampoDuplicado + ' ya está registrado';
        RETURN;
    END

    -- Validar que el telefono comience con 2, 5, 7 u 8
    IF (@TELEFONO NOT LIKE '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        SET @MENSAJE = 'El primer digito debe ser 2,5,7 u 8 y los demas numeros deben ser numericos.';
        RETURN;
    END

    -- Validamos que la fecha de ingreso no sea mayor que la fecha de inauguracion
    IF (@FECHAINGRE < TRY_CONVERT(DATE, '2000/05/18'))
    BEGIN
        SET @MENSAJE = 'La fecha de ingreso no puede ser inferior a la fecha de inauguracion';
        RETURN;
    END

    IF (@FECHAINGRE < TRY_CONVERT(DATE, DATEADD(MONTH, 1, GETDATE())))
    BEGIN
        SET @MENSAJE = 'La fecha de ingreso no puede ser superior a un mes.';
        RETURN;
    END

    -- Realizar la actualizacion
    UPDATE Empleado SET
        PNE = @PrimerNE,
        SNE = @SegundoNE,
        PAE = @PrimerAE,
        SAE = @SegundoAE,
        DireccionE = @DIREMPLEADO,
        TelefonoE = @TELEFONO,
        EmailE = @EMAIL,
        FechaIngreso = @FECHAINGRE,
        IdCargo = @IdCargo
    WHERE CodigEmpleado = @CDE;

    SET @MENSAJE = 'Actualizacion realizada con exito';
END;

GO

-----------------------------ELIMINAR EMPLEADO----------------------------------
CREATE PROC ELIMINAR_EMPLEADO
    @CDE UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validar si el codigo es nulo
    IF(@CDE IS NULL)
    BEGIN
        SET @MENSAJE = 'El codigo no puede ser nulo';
        RETURN;
    END

    DECLARE @empleado_existe AS BIT;
    SET @empleado_existe = (SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @CDE);

    -- Verificar si el empleado existe
    IF(@empleado_existe IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no esta registrado';
        RETURN;
    END

    -- Verificar si el empleado ya esta inactivo
    IF(@empleado_existe = 0)
    BEGIN
        SET @MENSAJE = 'El empleado ya esta inactivo';
        RETURN;
    END

    -- Actualizar el estado a inactivo
    UPDATE Empleado set
        EstadoEmpleado = 0,
		DateDelete=GETDATE()--ACTUALIZAMOS SU FECHA DE ELIMINACION
    WHERE CodigEmpleado = @CDE;

    SET @MENSAJE = 'Eliminacion realizada con exito';
END;

GO

-------------------------------ACTIVAR EMPLEADO---------------------------
CREATE PROC ACTIVAREMPLEADO
    @CDE UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validar si el codigo es nulo
    IF(@CDE IS NULL)
    BEGIN
        SET @MENSAJE = 'El codigo no puede ser nulo';
        RETURN;
    END

    DECLARE @empleado_existe AS BIT;
    SET @empleado_existe = (SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @CDE);

    -- Verificar si el empleado existe
    IF(@empleado_existe IS NULL)
    BEGIN
        SET @MENSAJE = 'El empleado no esta registrado';
        RETURN;
    END

    -- Verificar si el empleado ya esta activo
    IF(@empleado_existe = 1)
    BEGIN
        SET @MENSAJE = 'El empleado ya esta activo';
        RETURN;
    END

    -- Actualizar el estado a activo
    UPDATE Empleado set
        EstadoEmpleado = 1,
		DateDelete= NULL
    WHERE CodigEmpleado = @CDE;

    SET @MENSAJE = 'Activacion realizada con exito';
END;