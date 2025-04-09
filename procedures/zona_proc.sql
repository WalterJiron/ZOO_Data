---- proc zona ----

CREATE PROC ProcInsertZona
    @NameZona NVARCHAR(100),
    @Extension DECIMAL(10,2),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @NameZona IS NULL OR @Extension IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NameZona) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @Extension <= 0
    BEGIN
        SET @Mensaje = 'La extensión debe ser mayor a cero';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Zona WHERE NameZona = @NameZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'Ya existe una zona activa con ese nombre';
        RETURN;
    END

    INSERT INTO Zona (NameZona, Extension)
    VALUES (@NameZona, @Extension);

    SET @Mensaje = 'Zona insertada correctamente';
END;
GO
-- Actualizar zona --

CREATE PROC ProcUpdateZona
    @CodigoZona UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @NuevaExtension DECIMAL(10,2),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoZona IS NULL OR @NuevoNombre IS NULL OR @NuevaExtension IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @NuevaExtension <= 0
    BEGIN
        SET @Mensaje = 'La extensión debe ser mayor a cero';
        RETURN;
    END

    DECLARE @EstadoZona BIT;
    SET @EstadoZona = (SELECT EstadoZona FROM Zona WHERE CodigoZona = @CodigoZona);

    IF @EstadoZona IS NULL
    BEGIN
        SET @Mensaje = 'La zona no existe';
        RETURN;
    END

    IF @EstadoZona = 0
    BEGIN
        SET @Mensaje = 'La zona está eliminada';
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

    UPDATE Zona
    SET NameZona = @NuevoNombre,
        Extension = @NuevaExtension
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona actualizada correctamente';
END;
GO

-- eliminar zona --

CREATE PROC ProcDeleteZona
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoZona IS NULL
    BEGIN
        SET @Mensaje = 'El código de zona es obligatorio';
        RETURN;
    END

    DECLARE @EstadoZona BIT;
    SET @EstadoZona = (SELECT EstadoZona FROM Zona WHERE CodigoZona = @CodigoZona);

    IF @EstadoZona IS NULL
    BEGIN
        SET @Mensaje = 'La zona no existe';
        RETURN;
    END

    IF @EstadoZona = 0
    BEGIN
        SET @Mensaje = 'La zona ya está eliminada';
        RETURN;
    END

    UPDATE Zona
    SET EstadoZona = 0, DateDelete = GETDATE()
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona eliminada correctamente';
END;
GO
--- Restaurar zona eliminada --
CREATE PROC ProcRestoreZona
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoZona IS NULL
    BEGIN
        SET @Mensaje = 'El código de zona es obligatorio';
        RETURN;
    END

    DECLARE @EstadoZona BIT;
    SET @EstadoZona = (SELECT EstadoZona FROM Zona WHERE CodigoZona = @CodigoZona);

    IF @EstadoZona IS NULL
    BEGIN
        SET @Mensaje = 'La zona no existe';
        RETURN;
    END

    IF @EstadoZona = 1
    BEGIN
        SET @Mensaje = 'La zona ya está activa';
        RETURN;
    END

    UPDATE Zona
    SET EstadoZona = 1, DateDelete = NULL
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona restaurada correctamente';
END;
GO