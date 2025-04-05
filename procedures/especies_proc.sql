----------------Especies-------------


-------------------- Insertar Especie ----------------
CREATE PROC ProcInsertEspecie
    @Nombre NVARCHAR(100),
    @NombreCientifico NVARCHAR(100),
    @Descripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @Nombre IS NULL OR @NombreCientifico IS NULL OR @Descripcion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@NombreCientifico) < 3
    BEGIN
        SET @Mensaje = 'El nombre científico debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@Descripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Especie WHERE Nombre = @Nombre AND Estado = 1)
    BEGIN
        SET @Mensaje = 'Ya existe una especie con ese nombre';
        RETURN;
    END

    INSERT INTO Especie (Nombre, NameCientifico, Descripcion)
    VALUES (@Nombre, @NombreCientifico, @Descripcion);

    SET @Mensaje = 'Especie insertada correctamente';
END;

--------------------------- actualizar especie ------------------------------
CREATE PROC ProcUpdateEspecie
    @CodigoEspecie UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevoCientifico NVARCHAR(100),
    @NuevaDescripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Especie WHERE CodigoEspecie = @CodigoEspecie AND Estado = 1)
    BEGIN
        SET @Mensaje = 'La especie no existe o está eliminada';
        RETURN;
    END

    IF @NuevoNombre IS NULL OR @NuevoCientifico IS NULL OR @NuevaDescripcion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3 OR LEN(@NuevoCientifico) < 3
    BEGIN
        SET @Mensaje = 'Los nombres deben tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@NuevaDescripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Especie
        WHERE Nombre = @NuevoNombre AND CodigoEspecie != @CodigoEspecie AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otra especie activa con ese nombre';
        RETURN;
    END

    UPDATE Especie
    SET Nombre = @NuevoNombre,
        NameCientifico = @NuevoCientifico,
        Descripcion = @NuevaDescripcion
    WHERE CodigoEspecie = @CodigoEspecie;

    SET @Mensaje = 'Especie actualizada correctamente';
END;

------------------------------ eliminar especie ------------------------
CREATE PROC ProcDeleteEspecie
    @CodigoEspecie UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Especie WHERE CodigoEspecie = @CodigoEspecie AND Estado = 1)
    BEGIN
        SET @Mensaje = 'La especie no existe o ya está eliminada';
        RETURN;
    END

    UPDATE Especie
    SET Estado = 0, DateDelete = GETDATE()
    WHERE CodigoEspecie = @CodigoEspecie;

    SET @Mensaje = 'Especie eliminada correctamente';
END;

------------------------------------- restauracion de especie eliminada --------------------------
CREATE PROC ProcRestoreEspecie
    @CodigoEspecie UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Especie WHERE CodigoEspecie = @CodigoEspecie AND Estado = 0)
    BEGIN
        SET @Mensaje = 'La especie no existe o ya está activa';
        RETURN;
    END

    UPDATE Especie
    SET Estado = 1, DateDelete = NULL
    WHERE CodigoEspecie = @CodigoEspecie;

    SET @Mensaje = 'Se restauro la especie correctamente';
END;
