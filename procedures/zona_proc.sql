---------------------zona--------------


---------------------------------insertar zona -----------------------------
CREATE PROC ProcInsertZona
    @NameZona NVARCHAR(100),
    @Extension DECIMAL(10,2),
    @Mensaje VARCHAR(150) OUTPUT
AS
BEGIN
    IF @NameZona IS NULL OR @Extension IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacíos';
        RETURN;
    END

    IF LEN(@NameZona) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @Extension <= 0
    BEGIN
        SET @Mensaje = 'La extensión debe ser mayor a 0';
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

------------------------ actualizar zona -----------------------------------------------------
CREATE PROC ProcUpdateZona
    @CodigoZona UNIQUEIDENTIFIER,
    @NameZona NVARCHAR(100),
    @Extension DECIMAL(10,2),
    @Mensaje VARCHAR(150) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'La zona no existe o está eliminada';
        RETURN;
    END

    IF LEN(@NameZona) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @Extension <= 0
    BEGIN
        SET @Mensaje = 'La extensión debe ser mayor a 0';
        RETURN;
    END

    UPDATE Zona
    SET NameZona = @NameZona,
        Extension = @Extension
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona actualizada correctamente';
END;
GO

-------------------------------- eliminar zona ---------------------------------------
CREATE PROC ProcDeleteZona
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(150) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'La zona no existe o ya está eliminada';
        RETURN;
    END

    UPDATE Zona
    SET EstadoZona = 0,
        DateDelete = GETDATE()
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona eliminada correctamente';
END;
GO

-------------------------------- recuperar zona ---------------------------------------
CREATE PROC ProcRecoverZona
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(150) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona AND EstadoZona = 0)
    BEGIN
        SET @Mensaje = 'La zona no está eliminada o no existe';
        RETURN;
    END

    UPDATE Zona
    SET EstadoZona = 1,
        DateDelete = NULL
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona recuperada correctamente';
END;
GO