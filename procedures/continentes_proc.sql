-------------------Continentes--------------------------

--------------------------Insertar Continentes -----------------------------------
CREATE PROC ProcInsertContinente
    @Nombre NVARCHAR(50),
    @Mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    -- Miramos que el nombre no sea nulo o menor a 3 caracteres
    IF @Nombre IS NULL OR LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre del continente debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Miramos que el nombre no este en la DB
    IF EXISTS (SELECT 1 FROM Continente WHERE Nombre = @Nombre)
    BEGIN
        SET @Mensaje = 'Ya existe un continente con ese nombre';
        RETURN;
    END

    -- Miramos que el continente sea correcto
    IF @Nombre NOT IN ('Africa', 'America', 'Asia', 'Europa', 'Oceania')
    BEGIN
        SET @Mensaje = 'El continente no es correcto';
        RETURN;
    END

    INSERT INTO Continente (Nombre)
    VALUES (@Nombre);

    SET @Mensaje = 'Continente insertado correctamente';
END;

GO


