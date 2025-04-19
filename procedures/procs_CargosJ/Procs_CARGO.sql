Use ZOO


GO



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
        SET @MENSAJE = 'Los campos no pueden estar vacios';
        RETURN;
    END

    IF LEN(@NombreC) < 3 OR LEN(@NombreC) > 100
    BEGIN
        SET @MENSAJE = 'El nombre tiene que tener al menos 3 caracteres minimo y 100 maximos.';
        RETURN;
    END

    IF LEN(@DescripcionC) < 15 OR LEN(@DescripcionC) > 250
    BEGIN
        SET @MENSAJE = 'La decripcion tiene que tener al menos 15 caracteres minimo y 250 maximos.';
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
	IF (@CDC IS NULL)
	BEGIN
		SET @MENSAJE = 'El codigo no puede ser nulo';
		RETURN;
	END

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

	IF (@CDC IS NULL)
	BEGIN
		SET @MENSAJE = 'El codigo no puede ser nulo';
		RETURN;
	END

   -- Buscado el cargo
    DECLARE @cargo_exist AS BIT;
    SET @cargo_exist = (SELECT EstadoCargo FROM Cargo WHERE CodifoCargo = @CDC);

    -- Verificar si el cargo existe
    IF @cargo_exist IS NULL
    BEGIN
        SET @MENSAJE = 'El cargo no esta registrado';
        RETURN;
    END

    -- Verificar si el cargo ya esta activo
    IF @cargo_exist = 1
    BEGIN
        SET @MENSAJE = 'El cargo ya se encuentra activo';
        RETURN;
    END

    -- Desactivar el cargo
    UPDATE Cargo SET
        EstadoCargo = 1,
		DateDelete = NULL
    WHERE CodifoCargo = @CDC;

    -- Mensaje de exito
    SET @MENSAJE = 'Activacion con exito';
END;
