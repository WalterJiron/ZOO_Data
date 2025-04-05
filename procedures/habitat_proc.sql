--------------------habitad----------

--------------------------Insertar Habitat ------------------------
CREATE PROC ProcInsertHabitat
    @Nombre VARCHAR(100),
    @Clima VARCHAR(100),
    @DescripHabitat VARCHAR(MAX),
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @Nombre IS NULL OR LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @Clima IS NULL OR LEN(@Clima) < 3
    BEGIN
        SET @Mensaje = 'El clima debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @DescripHabitat IS NULL OR LEN(@DescripHabitat) < 5
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 5 caracteres';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona)
    BEGIN
        SET @Mensaje = 'La zona indicada no existe';
        RETURN;
    END

    INSERT INTO Habitat (Nombre, Clima, DescripHabitat, CodigoZona)
    VALUES (@Nombre, @Clima, @DescripHabitat, @CodigoZona);

    SET @Mensaje = 'Hábitat insertado correctamente';
END;

------------------- actualizar habitat ----------------------
CREATE PROC ProcUpdateHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @NuevoNombre VARCHAR(100),
    @NuevoClima VARCHAR(100),
    @NuevaDescripcion VARCHAR(MAX),
    @NuevaZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND EstadoHabitat = 1)
    BEGIN
        SET @Mensaje = 'El hábitat no existe o está inactivo';
        RETURN;
    END

    IF @NuevoNombre IS NULL OR LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @NuevoClima IS NULL OR LEN(@NuevoClima) < 3
    BEGIN
        SET @Mensaje = 'El clima debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @NuevaDescripcion IS NULL OR LEN(@NuevaDescripcion) < 5
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 5 caracteres';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @NuevaZona)
    BEGIN
        SET @Mensaje = 'La zona indicada no existe';
        RETURN;
    END

    UPDATE Habitat
    SET Nombre = @NuevoNombre,
        Clima = @NuevoClima,
        DescripHabitat = @NuevaDescripcion,
        CodigoZona = @NuevaZona
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat actualizado correctamente';
END;

------------------- eliminar habitat --------------------------
CREATE PROC ProcDeleteHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND EstadoHabitat = 1)
    BEGIN
        SET @Mensaje = 'El hábitat no existe o ya está eliminado';
        RETURN;
    END

    UPDATE Habitat
    SET EstadoHabitat = 0,
        DateDelete = GETDATE()
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat eliminado lógicamente';
END;

------------------- Recuperar habitat --------------------------
CREATE PROC ProcRecoverHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND EstadoHabitat = 1)
    BEGIN
        SET @Mensaje = 'El hábitat no existe o ya está eliminado';
        RETURN;
    END

    UPDATE Habitat
    SET EstadoHabitat = 1,
        DateDelete = GETDATE()
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat restaurado';
END;



