--------------------habitad----------

--------------------------Insertar Habitat ------------------------
CREATE PROC ProcInsertHabitat
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(MAX),
    @Zona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación: campos obligatorios
    IF @Nombre IS NULL OR @Descripcion IS NULL OR @Zona IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Validación: longitud mínima del nombre
    IF LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Validación: longitud mínima de la descripción
    IF LEN(@Descripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    -- Validación: existencia de la zona activa
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @Zona AND Estado = 1)
    BEGIN
        SET @Mensaje = 'La zona especificada no existe o está eliminada';
        RETURN;
    END

    -- Validación: nombre duplicado de hábitat activo
    IF EXISTS (SELECT 1 FROM Habitat WHERE Nombre = @Nombre AND Estado = 1)
    BEGIN
        SET @Mensaje = 'Ya existe un hábitat activo con ese nombre';
        RETURN;
    END

    -- Inserción de hábitat
    INSERT INTO Habitat (Nombre, Descripcion, Zona)
    VALUES (@Nombre, @Descripcion, @Zona);

    SET @Mensaje = 'Hábitat insertado correctamente';
END;
GO
------------------- actualizar habitat ----------------------
CREATE PROC ProcUpdateHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevaDescripcion NVARCHAR(MAX),
    @NuevaZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación: existencia del hábitat activo
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El hábitat no existe o está eliminado';
        RETURN;
    END

    -- Validación: campos obligatorios
    IF @NuevoNombre IS NULL OR @NuevaDescripcion IS NULL OR @NuevaZona IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Validación: longitud mínima del nombre
    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Validación: longitud mínima de la descripción
    IF LEN(@NuevaDescripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    -- Validación: existencia de la nueva zona
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @NuevaZona AND Estado = 1)
    BEGIN
        SET @Mensaje = 'La zona especificada no existe o está eliminada';
        RETURN;
    END

    -- Validación: duplicado de nombre en otro hábitat activo
    IF EXISTS (
        SELECT 1 FROM Habitat 
        WHERE Nombre = @NuevoNombre AND CodigoHabitat != @CodigoHabitat AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro hábitat activo con ese nombre';
        RETURN;
    END

    -- Actualización del hábitat
    UPDATE Habitat
    SET Nombre = @NuevoNombre,
        Descripcion = @NuevaDescripcion,
        Zona = @NuevaZona
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat actualizado correctamente';
END;
GO

------------------- eliminar habitat --------------------------
CREATE PROC ProcDeleteHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación: existencia del hábitat activo
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El hábitat no existe o ya está eliminado';
        RETURN;
    END

    -- Eliminación lógica del hábitat (Estado = 0, se marca fecha)
    UPDATE Habitat
    SET Estado = 0, DateDelete = GETDATE()
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat eliminado correctamente';
END;
GO

------------------- Recuperar habitat --------------------------
CREATE PROC ProcRestoreHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación: existencia del hábitat eliminado
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND Estado = 0)
    BEGIN
        SET @Mensaje = 'El hábitat no existe o ya está activo';
        RETURN;
    END

    -- Restauración lógica del hábitat (Estado = 1, se borra la fecha de eliminación)
    UPDATE Habitat
    SET Estado = 1, DateDelete = NULL
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat restaurado correctamente';
END;
GO
