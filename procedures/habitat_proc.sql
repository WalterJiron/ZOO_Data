--------------------habitad----------

--------------------------Insertar Habitat ------------------------
CREATE PROC ProcInsertHabitat
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(MAX),
    @Zona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validaci�n: campos obligatorios
    IF @Nombre IS NULL OR @Descripcion IS NULL OR @Zona IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Validaci�n: longitud m�nima del nombre
    IF LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Validaci�n: longitud m�nima de la descripci�n
    IF LEN(@Descripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripci�n debe tener al menos 10 caracteres';
        RETURN;
    END

    -- Validaci�n: existencia de la zona activa
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @Zona AND Estado = 1)
    BEGIN
        SET @Mensaje = 'La zona especificada no existe o est� eliminada';
        RETURN;
    END

    -- Validaci�n: nombre duplicado de h�bitat activo
    IF EXISTS (SELECT 1 FROM Habitat WHERE Nombre = @Nombre AND Estado = 1)
    BEGIN
        SET @Mensaje = 'Ya existe un h�bitat activo con ese nombre';
        RETURN;
    END

    -- Inserci�n de h�bitat
    INSERT INTO Habitat (Nombre, Descripcion, Zona)
    VALUES (@Nombre, @Descripcion, @Zona);

    SET @Mensaje = 'H�bitat insertado correctamente';
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
    -- Validaci�n: existencia del h�bitat activo
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El h�bitat no existe o est� eliminado';
        RETURN;
    END

    -- Validaci�n: campos obligatorios
    IF @NuevoNombre IS NULL OR @NuevaDescripcion IS NULL OR @NuevaZona IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Validaci�n: longitud m�nima del nombre
    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Validaci�n: longitud m�nima de la descripci�n
    IF LEN(@NuevaDescripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripci�n debe tener al menos 10 caracteres';
        RETURN;
    END

    -- Validaci�n: existencia de la nueva zona
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @NuevaZona AND Estado = 1)
    BEGIN
        SET @Mensaje = 'La zona especificada no existe o est� eliminada';
        RETURN;
    END

    -- Validaci�n: duplicado de nombre en otro h�bitat activo
    IF EXISTS (
        SELECT 1 FROM Habitat 
        WHERE Nombre = @NuevoNombre AND CodigoHabitat != @CodigoHabitat AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro h�bitat activo con ese nombre';
        RETURN;
    END

    -- Actualizaci�n del h�bitat
    UPDATE Habitat
    SET Nombre = @NuevoNombre,
        Descripcion = @NuevaDescripcion,
        Zona = @NuevaZona
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
    -- Validaci�n: existencia del h�bitat activo
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El h�bitat no existe o ya est� eliminado';
        RETURN;
    END

    -- Eliminaci�n l�gica del h�bitat (Estado = 0, se marca fecha)
    UPDATE Habitat
    SET Estado = 0, DateDelete = GETDATE()
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
    -- Validaci�n: existencia del h�bitat eliminado
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND Estado = 0)
    BEGIN
        SET @Mensaje = 'El h�bitat no existe o ya est� activo';
        RETURN;
    END

    -- Restauraci�n l�gica del h�bitat (Estado = 1, se borra la fecha de eliminaci�n)
    UPDATE Habitat
    SET Estado = 1, DateDelete = NULL
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'H�bitat restaurado correctamente';
END;
GO
