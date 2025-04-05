-------------------Continentes--------------------------

--------------------------Insertar Continentes -----------------------------------
CREATE PROC ProcInsertContinente
    @Nombre NVARCHAR(50),
    @Mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    IF @Nombre IS NULL OR LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre del continente debe tener al menos 3 caracteres';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Continente WHERE Nombre = @Nombre)
    BEGIN
        SET @Mensaje = 'Ya existe un continente con ese nombre';
        RETURN;
    END

    INSERT INTO Continente (Nombre)
    VALUES (@Nombre);

    SET @Mensaje = 'Continente insertado correctamente';
END;

--------------------------------- actualizar continente -------------------------------------
CREATE PROC ProcUpdateContinente
    @IdCont INT,
    @NuevoNombre NVARCHAR(50),
    @Mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    IF @NuevoNombre IS NULL OR LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Continente WHERE IdCont = @IdCont)
    BEGIN
        SET @Mensaje = 'No se encontró el continente con el ID especificado';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Continente WHERE Nombre = @NuevoNombre AND IdCont <> @IdCont)
    BEGIN
        SET @Mensaje = 'Ya existe otro continente con ese nombre';
        RETURN;
    END

    UPDATE Continente
    SET Nombre = @NuevoNombre
    WHERE IdCont = @IdCont;

    SET @Mensaje = 'Continente actualizado correctamente';
END;

-------------------------- eliminar continente -------------------------------
CREATE PROC ProcDeleteContinente
    @IdCont INT,
    @Mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Continente WHERE IdCont = @IdCont)
    BEGIN
        SET @Mensaje = 'No se encontró el continente con el ID especificado';
        RETURN;
    END

    DELETE FROM Continente
    WHERE IdCont = @IdCont;

    SET @Mensaje = 'Continente eliminado correctamente';
END;
GO