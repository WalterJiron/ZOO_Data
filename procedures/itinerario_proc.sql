--- PROC ITINENRARIO ---

-- Insertar Itinerario --

CREATE PROC ProcInsertItinerario
    @Nombre NVARCHAR(100),
    @Duracion NVARCHAR(50),
    @Descripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @Nombre IS NULL OR @Duracion IS NULL OR @Descripcion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@Nombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@Descripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Itinerario WHERE Nombre = @Nombre AND Estado = 1)
    BEGIN
        SET @Mensaje = 'Ya existe un itinerario activo con ese nombre';
        RETURN;
    END

    INSERT INTO Itinerario (Nombre, Duracion, Descripcion)
    VALUES (@Nombre, @Duracion, @Descripcion);

    SET @Mensaje = 'Itinerario insertado correctamente';
END;
GO

-- Actualizar Itinerario --

CREATE PROC ProcUpdateItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevaDuracion NVARCHAR(50),
    @NuevaDescripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoItinerario IS NULL OR @NuevoNombre IS NULL OR @NuevaDuracion IS NULL OR @NuevaDescripcion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@NuevaDescripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    DECLARE @EstadoItin BIT;
    SET @EstadoItin = (SELECT Estado FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario);

    IF @EstadoItin IS NULL
    BEGIN
        SET @Mensaje = 'El itinerario no existe';
        RETURN;
    END

    IF @EstadoItin = 0
    BEGIN
        SET @Mensaje = 'El itinerario está eliminado';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Itinerario
        WHERE Nombre = @NuevoNombre AND CodigoItinerario != @CodigoItinerario AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro itinerario activo con ese nombre';
        RETURN;
    END

    UPDATE Itinerario SET
        Nombre = @NuevoNombre,
        Duracion = @NuevaDuracion,
        Descripcion = @NuevaDescripcion
    WHERE CodigoItinerario = @CodigoItinerario;

    SET @Mensaje = 'Itinerario actualizado correctamente';
END;
GO

--- eliminar itinerario --

CREATE PROC ProcDeleteItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoItinerario IS NULL
    BEGIN
        SET @Mensaje = 'El código de itinerario es obligatorio';
        RETURN;
    END

    DECLARE @EstadoItin BIT;
    SET @EstadoItin = (SELECT Estado FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario);

    IF @EstadoItin IS NULL
    BEGIN
        SET @Mensaje = 'El itinerario no existe';
        RETURN;
    END

    IF @EstadoItin = 0
    BEGIN
        SET @Mensaje = 'El itinerario ya está eliminado';
        RETURN;
    END

    UPDATE Itinerario SET Estado = 0, DateDelete = GETDATE()
    WHERE CodigoItinerario = @CodigoItinerario;

    SET @Mensaje = 'Itinerario eliminado correctamente';
END;
GO

-- recuperar itinerario --

CREATE PROC ProcRestoreItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoItinerario IS NULL
    BEGIN
        SET @Mensaje = 'El código de itinerario es obligatorio';
        RETURN;
    END

    DECLARE @EstadoItin BIT;
    SET @EstadoItin = (SELECT Estado FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario);

    IF @EstadoItin IS NULL
    BEGIN
        SET @Mensaje = 'El itinerario no existe';
        RETURN;
    END

    IF @EstadoItin = 1
    BEGIN
        SET @Mensaje = 'El itinerario ya está activo';
        RETURN;
    END

    UPDATE Itinerario SET Estado = 1, DateDelete = NULL
    WHERE CodigoItinerario = @CodigoItinerario;

    SET @Mensaje = 'Itinerario restaurado correctamente';
END;
GO