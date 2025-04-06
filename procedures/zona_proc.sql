---------------------zona--------------


---------------------------------insertar zona -----------------------------
-- Procedimiento para insertar una nueva zona
CREATE PROC ProcInsertZona
    @NameZona NVARCHAR(100),
    @Extension DECIMAL(10,2),
    @Mensaje VARCHAR(150) OUTPUT
AS
BEGIN
    -- Validar que los campos no sean nulos
    IF @NameZona IS NULL OR @Extension IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vac�os';
        RETURN;
    END

    -- Miramos que el nombre no contenga caracteres especiales 
    IF @NameZona LIKE '%[^a-zA-Z0-9 ]%'
    BEGIN
        SET @Mensaje = 'El nombre no puede contener caracteres especiales';
        RETURN;
    END

    -- Miramos que la extenxion no sea una letra
    IF @Extension LIKE '%[^0-9]%'
    BEGIN
        SET @Mensaje = 'La extensi�n no puede contener letras';
        RETURN;
    END

    -- Validar longitud m�nima del nombre
    IF LEN(@NameZona) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Validar que la extensi�n sea mayor a 0
    IF @Extension <= 0
    BEGIN
        SET @Mensaje = 'La extensi�n debe ser mayor a 0';
        RETURN;
    END

    -- Verificar si ya existe una zona activa con ese nombre
    IF EXISTS (SELECT 1 FROM Zona WHERE NameZona = @NameZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'Ya existe una zona activa con ese nombre';
        RETURN;
    END

    -- Insertar la nueva zona (EstadoZona tiene valor por defecto)
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
    -- Validar que la zona exista y est� activa
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'La zona no existe o est� eliminada';
        RETURN;
    END

    -- Validar longitud m�nima del nombre
    IF LEN(@NameZona) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Validar que la extensi�n sea mayor a 0
    IF @Extension <= 0
    BEGIN
        SET @Mensaje = 'La extensi�n debe ser mayor a 0';
        RETURN;
    END

    -- Actualizar los datos de la zona
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
    -- Validar existencia y estado de la zona
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'La zona no existe o ya est� eliminada';
        RETURN;
    END

    -- Marcar la zona como eliminada
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
    -- Validar si la zona est� eliminada
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona AND EstadoZona = 0)
    BEGIN
        SET @Mensaje = 'La zona no est� eliminada o no existe';
        RETURN;
    END

    -- Restaurar zona a estado activo
    UPDATE Zona
    SET EstadoZona = 1,
        DateDelete = NULL
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona recuperada correctamente';
END;
GO