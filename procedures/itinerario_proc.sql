----itinerario-------
-------------------- Insertar itinerario -------------------------
CREATE PROC ProcInsertItinerario
    @Nombre NVARCHAR(100),
    @Duracion INT,
    @Descripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación: campos obligatorios
    IF @Nombre IS NULL OR @Descripcion IS NULL OR @Duracion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Validación: longitud mínima del nombre
    IF LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre del itinerario debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Validación: duración mínima
    IF @Duracion < 10
    BEGIN
        SET @Mensaje = 'La duración debe ser de al menos 10 minutos';
        RETURN;
    END

    -- Validación: longitud mínima de la descripción
    IF LEN(@Descripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    -- Validación: nombre duplicado
    IF EXISTS (SELECT 1 FROM Itinerario WHERE Nombre = @Nombre AND Estado = 1)
    BEGIN
        SET @Mensaje = 'Ya existe un itinerario activo con ese nombre';
        RETURN;
    END

    -- Inserción del itinerario
    INSERT INTO Itinerario (Nombre, Duracion, Descripcion)
    VALUES (@Nombre, @Duracion, @Descripcion);

    SET @Mensaje = 'Itinerario insertado correctamente';
END;
GO

------------------------------ actualizar itinerario --
CREATE PROC ProcUpdateItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevaDuracion INT,
    @NuevaDescripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación: existencia del itinerario activo
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El itinerario no existe o está eliminado';
        RETURN;
    END

    -- Validación: campos obligatorios
    IF @NuevoNombre IS NULL OR @NuevaDuracion IS NULL OR @NuevaDescripcion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Validación: longitud mínima del nombre
    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre del itinerario debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Validación: duración mínima
    IF @NuevaDuracion < 10
    BEGIN
        SET @Mensaje = 'La duración debe ser de al menos 10 minutos';
        RETURN;
    END

    -- Validación: longitud mínima de la descripción
    IF LEN(@NuevaDescripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    -- Validación: duplicado de nombre en otro itinerario activo
    IF EXISTS (
        SELECT 1 FROM Itinerario
        WHERE Nombre = @NuevoNombre AND CodigoItinerario != @CodigoItinerario AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro itinerario activo con ese nombre';
        RETURN;
    END

    -- Actualización del itinerario
    UPDATE Itinerario
    SET Nombre = @NuevoNombre,
        Duracion = @NuevaDuracion,
        Descripcion = @NuevaDescripcion
    WHERE CodigoItinerario = @CodigoItinerario;

    SET @Mensaje = 'Itinerario actualizado correctamente';
END;
GO

--------------------- eliminar itinerario --
CREATE PROC ProcDeleteItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación: existencia del itinerario activo
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El itinerario no existe o ya está eliminado';
        RETURN;
    END

    -- Eliminación lógica del itinerario (Estado = 0, se registra fecha)
    UPDATE Itinerario
    SET Estado = 0, DateDelete = GETDATE()
    WHERE CodigoItinerario = @CodigoItinerario;

    SET @Mensaje = 'Itinerario eliminado correctamente';
END;
GO

------recuperar itinerario--------------

CREATE PROC ProcRestoreItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación: existencia del itinerario eliminado
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario AND Estado = 0)
    BEGIN
        SET @Mensaje = 'El itinerario no existe o ya está activo';
        RETURN;
    END

    -- Restauración lógica (Estado = 1, se borra fecha de eliminación)
    UPDATE Itinerario
    SET Estado = 1, DateDelete = NULL
    WHERE CodigoItinerario = @CodigoItinerario;

    SET @Mensaje = 'Itinerario restaurado correctamente';
END;
GO
