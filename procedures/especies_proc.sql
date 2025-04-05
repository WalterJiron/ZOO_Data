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
        SET @Mensaje = 'El nombre cient�fico debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@Descripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripci�n debe tener al menos 10 caracteres';
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

GO

--------------------------- actualizar especie ------------------------------
CREATE PROC ProcUpdateEspecie
    @CodigoEspecie UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevoCientifico NVARCHAR(100),
    @NuevaDescripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoEspecie IS NULL OR @NuevoNombre IS NULL OR @NuevoCientifico IS NULL OR @NuevaDescripcion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Buscar el codigo
    DECLARE @codigo_exist AS UNIQUEIDENTIFIER;
    SET @codigo_exist = (SELECT Estado FROM Especie WHERE CodigoEspecie = @CodigoEspecie);
    

    IF @codigo_exist IS NULL
    BEGIN
        SET @Mensaje = 'La especie no existe';
        RETURN;
    END

    IF @codigo_exist = 0
    BEGIN
        SET @Mensaje = 'La especie esta eliminada.';
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3 
    BEGIN
        SET @Mensaje = 'Lo nombre deben tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@NuevoCientifico) < 3
    BEGIN
        SET @Mensaje = 'El nombre cientifico deben tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@NuevaDescripcion) < 10 
    BEGIN
        SET @Mensaje = 'La descripci�n debe tener al menos 10 caracteres';
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

    UPDATE Especie SET
        Nombre = @NuevoNombre,
        NameCientifico = @NuevoCientifico,
        Descripcion = @NuevaDescripcion
    WHERE CodigoEspecie = @CodigoEspecie;

    SET @Mensaje = 'Especie actualizada correctamente';
END;

GO

------------------------------ eliminar especie ------------------------
CREATE PROC ProcDeleteEspecie
    @CodigoEspecie UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoEspecie IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Buscar el codigo
    DECLARE @codigo_exist AS UNIQUEIDENTIFIER;
    SET @codigo_exist = (SELECT Estado FROM Especie WHERE CodigoEspecie = @CodigoEspecie);
    
    
    IF @codigo_exist IS NULL
    BEGIN
        SET @Mensaje = 'La especie no existe';
        RETURN;
    END

    IF @codigo_exist = 0
    BEGIN
        SET @Mensaje = 'La especie ya esta eliminada.';
        RETURN;
    END

    UPDATE Especie SET
        Estado = 0, 
        DateDelete = GETDATE()
    WHERE CodigoEspecie = @CodigoEspecie;

    SET @Mensaje = 'Especie eliminada correctamente';
END;

GO

------------------------------------- restauracion de especie eliminada --------------------------
CREATE PROC ProcRestoreEspecie
    @CodigoEspecie UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoEspecie IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Buscar el codigo
    DECLARE @codigo_exist AS UNIQUEIDENTIFIER;
    SET @codigo_exist = (SELECT Estado FROM Especie WHERE CodigoEspecie = @CodigoEspecie);
    
    
    IF @codigo_exist IS NULL
    BEGIN
        SET @Mensaje = 'La especie no existe';
        RETURN;
    END

    IF @codigo_exist = 1
    BEGIN
        SET @Mensaje = 'La especie ya esta activa.';
        RETURN;
    END

    UPDATE Especie SET
        Estado = 1, 
        DateDelete = NULL
    WHERE CodigoEspecie = @CodigoEspecie;

<<<<<<< HEAD
    SET @Mensaje = 'Especie eliminada correctamente';
=======
    SET @Mensaje = 'Se restauro la especie correctamente';
>>>>>>> 4721b142adafa9016a32b5546bf1fb2145f31462
END;
