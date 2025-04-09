---- PROC HABITAT -----   Este campo no existe @TipoVegetacion

-- Insertar Habitat --

CREATE PROC ProcInsertHabitat
    @Nombre NVARCHAR(100),
    @Clima NVARCHAR(100),   -- No tiene validaciones
    @TipoVegetacion NVARCHAR(100),   -- No tiene validaciones
    @Zona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @Nombre IS NULL OR @Clima IS NULL OR @TipoVegetacion IS NULL OR @Zona IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Va de primero
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @Zona AND Estado = 1)
    BEGIN
        SET @Mensaje = 'La zona no existe o está inactiva';
        RETURN;
    END

    IF LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Habitat WHERE Nombre = @Nombre AND CodigoZona = @Zona AND Estado = 1)
    BEGIN
        SET @Mensaje = 'Ya existe un hábitat con ese nombre en la zona indicada';
        RETURN;
    END

    INSERT INTO Habitat (Nombre, Clima, TipoVegetacion, CodigoZona)
    VALUES (@Nombre, @Clima, @TipoVegetacion, @Zona);

    SET @Mensaje = 'Hábitat insertado correctamente';
END;
GO

-- Actualizar 

CREATE PROC ProcUpdateHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevoClima NVARCHAR(100),   -- No tiene validacion
    @NuevaVegetacion NVARCHAR(100),   -- No tiene validacion
    @Zona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoHabitat IS NULL OR @NuevoNombre IS NULL OR @NuevoClima IS NULL OR @NuevaVegetacion IS NULL OR @Zona IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @Zona AND Estado = 1)
    BEGIN
        SET @Mensaje = 'La zona no existe o está inactiva';
        RETURN;
    END

    DECLARE @EstadoHabitat BIT;
    SET @EstadoHabitat = (SELECT Estado FROM Habitat WHERE CodigoHabitat = @CodigoHabitat);

    IF @EstadoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El hábitat no existe';
        RETURN;
    END

    IF @EstadoHabitat = 0
    BEGIN
        SET @Mensaje = 'El hábitat está eliminado';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Habitat
        WHERE Nombre = @NuevoNombre AND CodigoZona = @Zona AND CodigoHabitat != @CodigoHabitat AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro hábitat activo con ese nombre en la misma zona';
        RETURN;
    END

    UPDATE Habitat SET
        Nombre = @NuevoNombre,
        Clima = @NuevoClima,
        TipoVegetacion = @NuevaVegetacion,
        CodigoZona = @Zona
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat actualizado correctamente';
END;
GO

-- Eliminar Habitat --

CREATE PROC ProcDeleteHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El código de hábitat es obligatorio';
        RETURN;
    END

    DECLARE @EstadoHabitat BIT;
    SET @EstadoHabitat = (SELECT Estado FROM Habitat WHERE CodigoHabitat = @CodigoHabitat);

    IF @EstadoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El hábitat no existe';
        RETURN;
    END

    IF @EstadoHabitat = 0
    BEGIN
        SET @Mensaje = 'El hábitat ya está eliminado';
        RETURN;
    END

    UPDATE Habitat SET Estado = 0, DateDelete = GETDATE()
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat eliminado correctamente';
END;
GO

-- Recuperar habitat eliminado --

CREATE PROC ProcRestoreHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El código de hábitat es obligatorio';
        RETURN;
    END

    DECLARE @EstadoHabitat BIT;
    SET @EstadoHabitat = (SELECT Estado FROM Habitat WHERE CodigoHabitat = @CodigoHabitat);

    IF @EstadoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El hábitat no existe';
        RETURN;
    END

    IF @EstadoHabitat = 1
    BEGIN
        SET @Mensaje = 'El hábitat ya está activo';
        RETURN;
    END

    UPDATE Habitat SET Estado = 1, DateDelete = NULL
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat restaurado correctamente';
END;
GO