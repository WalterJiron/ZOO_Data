

------------------------------------- ESTA MANLO MIRA BIEN LA DB zoo_database -------------------------------------




-------------------- Insertar itinerario -------------------------
CREATE PROC ProcInsertItinerario   -- Mirar bien los capos de la tabla
    @NameItinerario NVARCHAR(100),
    @Descripcion NVARCHAR(MAX),
    @Duracion TIME,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @NameItinerario IS NULL OR @Descripcion IS NULL OR @Duracion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NameItinerario) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@Descripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripci�n debe tener al menos 10 caracteres';
        RETURN;
    END

    -- No existe un NameItinerario en la tabla Itinerario
    IF EXISTS (SELECT 1 FROM Itinerario WHERE NameItinerario = @NameItinerario AND EstadoItinerario = 1)
    BEGIN
        SET @Mensaje = 'Ya existe un itinerario con ese nombre';
        RETURN;
    END

    INSERT INTO Itinerario (NameItinerario, Descripcion, Duracion)
    VALUES (@NameItinerario, @Descripcion, @Duracion);

    SET @Mensaje = 'Itinerario insertado correctamente';
END;
GO

------------------------------ actualizar itinerario --
CREATE PROC ProcUpdateItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevaDescripcion NVARCHAR(MAX),
    @NuevaDuracion TIME,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoItinerario IS NULL OR @NuevoNombre IS NULL OR @NuevaDescripcion IS NULL OR @NuevaDuracion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    DECLARE @estado BIT;
    SET @estado = (SELECT EstadoItinerario FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario);

    IF @estado IS NULL
    BEGIN
        SET @Mensaje = 'El itinerario no existe';
        RETURN;
    END

    IF @estado = 0
    BEGIN
        SET @Mensaje = 'El itinerario est� eliminado';
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@NuevaDescripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripci�n debe tener al menos 10 caracteres';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Itinerario
        WHERE NameItinerario = @NuevoNombre AND CodigoItinerario != @CodigoItinerario AND EstadoItinerario = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro itinerario activo con ese nombre';
        RETURN;
    END

    UPDATE Itinerario SET
        NameItinerario = @NuevoNombre,
        Descripcion = @NuevaDescripcion,
        Duracion = @NuevaDuracion
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
    IF @CodigoItinerario IS NULL
    BEGIN
        SET @Mensaje = 'El c�digo del itinerario es obligatorio';
        RETURN;
    END

    DECLARE @estado BIT;
    SET @estado = (SELECT EstadoItinerario FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario);

    IF @estado IS NULL
    BEGIN
        SET @Mensaje = 'El itinerario no existe';
        RETURN;
    END

    IF @estado = 0
    BEGIN
        SET @Mensaje = 'El itinerario ya est� eliminado';
        RETURN;
    END

    UPDATE Itinerario SET
        EstadoItinerario = 0,
        FechaEliminacion = GETDATE()
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
    IF @CodigoItinerario IS NULL
    BEGIN
        SET @Mensaje = 'El c�digo del itinerario es obligatorio';
        RETURN;
    END

    DECLARE @estado BIT;
    SET @estado = (SELECT EstadoItinerario FROM Itinerario WHERE CodigoItinerario = @CodigoItinerario);

    IF @estado IS NULL
    BEGIN
        SET @Mensaje = 'El itinerario no existe';
        RETURN;
    END

    IF @estado = 1
    BEGIN
        SET @Mensaje = 'El itinerario ya est� activo';
        RETURN;
    END

    UPDATE Itinerario SET
        EstadoItinerario = 1,
        FechaEliminacion = NULL
    WHERE CodigoItinerario = @CodigoItinerario;

    SET @Mensaje = 'Itinerario restaurado correctamente';
END;
GO