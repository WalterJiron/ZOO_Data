


------------------------------------- ESTA MANLO MIRA BIEN LA DB zoo_database -------------------------------------

--------------------------Insertar Habitat ------------------------
CREATE PROC ProcInsertHabitat   -- Mira los campos estan malos
    @Nombre NVARCHAR(100),
    @Clima NVARCHAR(100),
    @Vegetacion NVARCHAR(100),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @Nombre IS NULL OR @Clima IS NULL OR @Vegetacion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@Clima) < 3
    BEGIN
        SET @Mensaje = 'El clima debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@Vegetacion) < 3
    BEGIN
        SET @Mensaje = 'La vegetaci�n debe tener al menos 3 caracteres';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Habitat WHERE Nombre = @Nombre AND Estado = 1)
    BEGIN
        SET @Mensaje = 'Ya existe un h�bitat con ese nombre';
        RETURN;
    END

    INSERT INTO Habitat (Nombre, Clima, Vegetacion)
    VALUES (@Nombre, @Clima, @Vegetacion);

    SET @Mensaje = 'H�bitat insertado correctamente';
END;
GO
------------------- actualizar habitat ----------------------
CREATE PROC ProcUpdateHabitat    -- Mira los campos estan malos
    @CodigoHabitat UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevoClima NVARCHAR(100),
    @NuevaVegetacion NVARCHAR(100),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoHabitat IS NULL OR @NuevoNombre IS NULL OR @NuevoClima IS NULL OR @NuevaVegetacion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    DECLARE @estado BIT;
    SET @estado = (SELECT Estado FROM Habitat WHERE CodigoHabitat = @CodigoHabitat);   -- Revisa el campo

    IF @estado IS NULL
    BEGIN
        SET @Mensaje = 'El h�bitat no existe';
        RETURN;
    END

    IF @estado = 0
    BEGIN
        SET @Mensaje = 'El h�bitat est� eliminado';   -- inactivo en vez de eliminado
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@NuevoClima) < 3
    BEGIN
        SET @Mensaje = 'El clima debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@NuevaVegetacion) < 3
    BEGIN
        SET @Mensaje = 'La vegetaci�n debe tener al menos 3 caracteres';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Habitat
        WHERE Nombre = @NuevoNombre AND CodigoHabitat != @CodigoHabitat AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro h�bitat activo con ese nombre';
        RETURN;
    END

    UPDATE Habitat SET
        Nombre = @NuevoNombre,
        Clima = @NuevoClima,
        Vegetacion = @NuevaVegetacion
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'H�bitat actualizado correctamente';
END;
GO

------------------- eliminar habitat --------------------------
CREATE PROC ProcDeleteHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El c�digo del h�bitat es obligatorio';
        RETURN;
    END

    DECLARE @estado BIT;
    SET @estado = (SELECT Estado FROM Habitat WHERE CodigoHabitat = @CodigoHabitat);

    IF @estado IS NULL
    BEGIN
        SET @Mensaje = 'El h�bitat no existe';
        RETURN;
    END

    IF @estado = 0
    BEGIN
        SET @Mensaje = 'El h�bitat ya est� eliminado';
        RETURN;
    END

    UPDATE Habitat SET
        Estado = 0,
        FechaEliminacion = GETDATE()
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'H�bitat eliminado correctamente';
END;
GO

------------------- Recuperar habitat --------------------------
CREATE PROC ProcRestoreHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El c�digo del h�bitat es obligatorio';
        RETURN;
    END

    DECLARE @estado BIT;
    SET @estado = (SELECT Estado FROM Habitat WHERE CodigoHabitat = @CodigoHabitat);

    IF @estado IS NULL
    BEGIN
        SET @Mensaje = 'El h�bitat no existe';
        RETURN;
    END

    IF @estado = 1
    BEGIN
        SET @Mensaje = 'El h�bitat ya est� activo';
        RETURN;
    END

    UPDATE Habitat SET
        Estado = 1,
        FechaEliminacion = NULL
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'H�bitat restaurado correctamente';
END;
GO
