Use ZOO


GO

CREATE PROCEDURE Insertar_Cargo
    @NombreC NVARCHAR(50),
    @DescripcionC NVARCHAR(MAX),
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	---VALIDAR QUE NO SEA NULO
	IF @NombreC IS NULL
	BEGIN
		SET @MENSAJE='No puede ser nulo';
		RETURN;
	END

    -- Validar si el nombre del cargo ya existe
    IF EXISTS (SELECT 1 FROM Cargo WHERE NombreCargo = @NombreC)
    BEGIN
        SET @MENSAJE = 'El nombre del cargo ya existe';
        RETURN;
    END

    -- Validar si la descripcion es NULL o vacia
	--LTRIM elimina espacios en blanco a la izquiera y RTRIM elimina espacios en blanco a la derecha
    IF @DescripcionC IS NULL OR LTRIM(RTRIM(@DescripcionC)) = ''
    BEGIN
        SET @MENSAJE = 'La descripcion no puede ser nula ni estar vacia';
        RETURN;
    END

    -- Insertar el nuevo cargo con estado activo (1)
    INSERT INTO Cargo (NombreCargo, DescripCargo)
    VALUES (@NombreC, @DescripcionC);

    -- Mensaje de �xito
    SET @MENSAJE = 'Insercion realizada con exito';
END;
GO

--------------------UPDATE CARGO------------------------
CREATE PROCEDURE UPDATE_CARGO
    @CDC UNIQUEIDENTIFIER,
    @NombreC NVARCHAR(50),
    @DescripcionC NVARCHAR(MAX),
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    IF @NombreC IS NULL OR LTRIM(RTRIM(@NombreC)) = '' OR @DescripcionC IS NULL OR LTRIM(RTRIM(@DescripcionC)) = ''
    BEGIN
        SET @MENSAJE = 'El nombre o la descripcion no pueden estar vacios';
        RETURN;
    END

    -- Buscamos el codigo del cargo
    DECLARE @cargo_exist AS BIT;
    SET @cargo_exist = (SELECT EstadoCargo FROM Cargo WHERE CodifoCargo = @CDC);

    -- Verificar si el cargo existe
    IF @cargo_exist IS NULL
    BEGIN
        SET @MENSAJE = 'El cargo no existe';
        RETURN;
    END

    -- Verificar si el cargo esta activo
    IF @cargo_exist = 0
    BEGIN
        SET @MENSAJE = 'El cargo se encuentra inactivo';
        RETURN;
    END

    -- Verificar si el nombre del cargo ya esta en uso
    IF EXISTS (SELECT 1 FROM Cargo WHERE NombreCargo = @NombreC AND CodifoCargo <> @CDC)
    BEGIN
        SET @MENSAJE = 'Nombre de cargo ya existente';
        RETURN;
    END

    -- Actualizar los datos del cargo
    UPDATE Cargo SET
        NombreCargo = @NombreC,
        DescripCargo = @DescripcionC
    WHERE CodifoCargo = @CDC;

    -- Mensaje de exito
    SET @MENSAJE = 'Update realizada con exito';
END;

GO

------------------------------------Eliminar CARGO-----------------------
CREATE PROCEDURE ELIMINAR_CARGO 
    @CDC UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Buscado el cargo
    DECLARE @cargo_exist AS BIT;
    SET @cargo_exist = (SELECT EstadoCargo FROM Cargo WHERE CodifoCargo = @CDC);

    -- Verificar si el cargo existe
    IF @cargo_exist IS NULL
    BEGIN
        SET @MENSAJE = 'El cargo no esta registrado';
        RETURN;
    END

    -- Verificar si el cargo ya esta inactivo
    IF @cargo_exist = 0
    BEGIN
        SET @MENSAJE = 'El cargo ya se encuentra inactivo';
        RETURN;
    END

    -- Desactivar el cargo
    UPDATE Cargo SET
        EstadoCargo = 0,
		DateDelete = GETDATE()
    WHERE CodifoCargo = @CDC;

    -- Mensaje de exito
    SET @MENSAJE = 'Eliminacion con exito';
END;
GO


-----------Activar CARGO--------------------
CREATE PROCEDURE ACTIVAR_CARGO 
    @CDC UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
   -- Buscado el cargo
    DECLARE @cargo_exist AS BIT;
    SET @cargo_exist = (SELECT EstadoCargo FROM Cargo WHERE CodifoCargo = @CDC);

    -- Verificar si el cargo existe
    IF @cargo_exist IS NULL
    BEGIN
        SET @MENSAJE = 'El cargo no esta registrado';
        RETURN;
    END

    -- Verificar si el cargo ya esta inactivo
    IF @cargo_exist = 0
    BEGIN
        SET @MENSAJE = 'El cargo ya se encuentra inactivo';
        RETURN;
    END

    -- Desactivar el cargo
    UPDATE Cargo SET
        EstadoCargo = 0,
		DateDelete = NULL
    WHERE CodifoCargo = @CDC;
    -- Mensaje de exito
    SET @MENSAJE = 'Activacion con exito';
END;
