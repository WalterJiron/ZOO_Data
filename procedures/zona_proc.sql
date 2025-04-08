

------------------------------------- ESTA MANLO MIRA BIEN LA DB zoo_database -------------------------------------





---------------------------------insertar zona -----------------------------
-- Procedimiento para insertar una nueva zona
CREATE PROC ProcInsertZona   -- Los campos estan malos
    @NameZona NVARCHAR(100),
    @Descripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @NameZona IS NULL OR @Descripcion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NameZona) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF LEN(@Descripcion) < 10
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 10 caracteres';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Zona WHERE NameZona = @NameZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'Ya existe una zona con ese nombre';
        RETURN;
    END

    INSERT INTO Zona (NameZona, Descripcion)
    VALUES (@NameZona, @Descripcion);

    SET @Mensaje = 'Zona insertada correctamente';
END;
GO

------------------------ actualizar zona -----------------------------------------------------

CREATE PROC ProcUpdateZona
    @CodigoZona UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevaDescripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoZona IS NULL OR @NuevoNombre IS NULL OR @NuevaDescripcion IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    DECLARE @existe BIT;
    SET @existe = (SELECT EstadoZona FROM Zona WHERE CodigoZona = @CodigoZona);

    IF @existe IS NULL
    BEGIN
        SET @Mensaje = 'La zona no existe';
        RETURN;
    END

    IF @existe = 0
    BEGIN
        SET @Mensaje = 'La zona está eliminada';
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

    IF EXISTS (
        SELECT 1 FROM Zona
        WHERE NameZona = @NuevoNombre AND CodigoZona != @CodigoZona AND EstadoZona = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otra zona activa con ese nombre';
        RETURN;
    END

    UPDATE Zona SET
        NameZona = @NuevoNombre,
        Descripcion = @NuevaDescripcion
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona actualizada correctamente';
END;
GO

-------------------------------- eliminar zona ---------------------------------------

CREATE PROC ProcDeleteZona
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoZona IS NULL
    BEGIN
        SET @Mensaje = 'El código de la zona es obligatorio';
        RETURN;
    END

    DECLARE @estado BIT;
    SET @estado = (SELECT EstadoZona FROM Zona WHERE CodigoZona = @CodigoZona);

    IF @estado IS NULL
    BEGIN
        SET @Mensaje = 'La zona no existe';
        RETURN;
    END

    IF @estado = 0
    BEGIN
        SET @Mensaje = 'La zona ya está eliminada';
        RETURN;
    END

    UPDATE Zona SET
        EstadoZona = 0,
        FechaEliminacion = GETDATE()
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona eliminada correctamente';
END;
GO

-------------------------------- recuperar zona ---------------------------------------

CREATE PROC ProcRestoreZona
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoZona IS NULL
    BEGIN
        SET @Mensaje = 'El código de la zona es obligatorio';
        RETURN;
    END

    DECLARE @estado BIT;
    SET @estado = (SELECT EstadoZona FROM Zona WHERE CodigoZona = @CodigoZona);

    IF @estado IS NULL
    BEGIN
        SET @Mensaje = 'La zona no existe';
        RETURN;
    END

    IF @estado = 1
    BEGIN
        SET @Mensaje = 'La zona ya está activa';
        RETURN;
    END

    UPDATE Zona SET
        EstadoZona = 1,
        FechaEliminacion = NULL
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Se restauro la zona correctamente';
END;
GO