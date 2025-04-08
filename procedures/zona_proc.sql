---- PROC ZONA ----

-- Insertar zona --

CREATE PROCEDURE zona_proc
    @Accion VARCHAR(10),
    @CodigoZona UNIQUEIDENTIFIER = NULL,
    @NombreZona NVARCHAR(100) = NULL,
    @CodigoCont UNIQUEIDENTIFIER = NULL,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @Accion = 'insert'
    BEGIN
        IF @NombreZona IS NULL OR LEN(@NombreZona) < 3
        BEGIN
            SET @Mensaje = 'El nombre de la zona debe tener al menos 3 caracteres';
            RETURN;
        END

        IF @CodigoCont IS NULL
        BEGIN
            SET @Mensaje = 'Debe seleccionar un continente';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Continente WHERE CodigoCont = @CodigoCont AND Estado = 1)
        BEGIN
            SET @Mensaje = 'El continente seleccionado no existe o está inactivo';
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM Zona 
            WHERE NombreZona = @NombreZona 
              AND CodigoCont = @CodigoCont 
              AND Estado = 1
        )
        BEGIN
            SET @Mensaje = 'Ya existe una zona activa con ese nombre en ese continente';
            RETURN;
        END

        INSERT INTO Zona (NombreZona, CodigoCont)
        VALUES (@NombreZona, @CodigoCont);

        SET @Mensaje = 'Zona insertada correctamente';
    END

    ELSE IF @Accion = 'update'
    BEGIN
        IF @CodigoZona IS NULL
        BEGIN
            SET @Mensaje = 'Debe proporcionar el código de la zona';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona)
        BEGIN
            SET @Mensaje = 'La zona no existe';
            RETURN;
        END

        IF @NombreZona IS NULL OR LEN(@NombreZona) < 3
        BEGIN
            SET @Mensaje = 'El nuevo nombre de la zona debe tener al menos 3 caracteres';
            RETURN;
        END

        IF @CodigoCont IS NULL
        BEGIN
            SET @Mensaje = 'Debe seleccionar un continente';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Continente WHERE CodigoCont = @CodigoCont AND Estado = 1)
        BEGIN
            SET @Mensaje = 'El continente asignado no existe o está inactivo';
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM Zona
            WHERE NombreZona = @NombreZona 
              AND CodigoZona != @CodigoZona 
              AND CodigoCont = @CodigoCont 
              AND Estado = 1
        )
        BEGIN
            SET @Mensaje = 'Otra zona activa ya tiene ese nombre en ese continente';
            RETURN;
        END

        UPDATE Zona
        SET NombreZona = @NombreZona,
            CodigoCont = @CodigoCont
        WHERE CodigoZona = @CodigoZona;

        SET @Mensaje = 'Zona actualizada correctamente';
    END

    ELSE IF @Accion = 'delete'
    BEGIN
        IF @CodigoZona IS NULL
        BEGIN
            SET @Mensaje = 'Debe proporcionar el código de la zona a eliminar';
            RETURN;
        END

        UPDATE Zona
        SET Estado = 0, DateDelete = GETDATE()
        WHERE CodigoZona = @CodigoZona;

        SET @Mensaje = 'Zona eliminada correctamente';
    END

    ELSE IF @Accion = 'restore'
    BEGIN
        IF @CodigoZona IS NULL
        BEGIN
            SET @Mensaje = 'Debe proporcionar el código de la zona a restaurar';
            RETURN;
        END

        UPDATE Zona
        SET Estado = 1, DateDelete = NULL
        WHERE CodigoZona = @CodigoZona;

        SET @Mensaje = 'Zona restaurada correctamente';
    END

    ELSE
    BEGIN
        SET @Mensaje = 'Acción no válida';
    END
END;

-- Actualizar zona --

CREATE PROC ProcUpdateZona
    @CodigoZona UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @CodigoContinente UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoZona IS NULL OR @NuevoNombre IS NULL OR @CodigoContinente IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Continente WHERE CodigoContinente = @CodigoContinente AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El continente no existe o está inactivo';
        RETURN;
    END

    DECLARE @EstadoZona BIT;
    SET @EstadoZona = (SELECT Estado FROM Zona WHERE CodigoZona = @CodigoZona);

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
        WHERE Nombre = @NuevoNombre AND CodigoContinente = @CodigoContinente AND CodigoZona != @CodigoZona AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otra zona activa con ese nombre en el mismo continente';
        RETURN;
    END

    UPDATE Zona SET Nombre = @NuevoNombre, CodigoContinente = @CodigoContinente
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
    SET @EstadoZona = (SELECT Estado FROM Zona WHERE CodigoZona = @CodigoZona);

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

    UPDATE Zona SET Estado = 0, DateDelete = GETDATE()
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
    DECLARE @EstadoZona BIT;

    IF @CodigoZona IS NULL
    BEGIN
        SET @Mensaje = 'El código de zona es obligatorio';
        RETURN;
    END

    SET @EstadoZona = (SELECT Estado FROM Zona WHERE CodigoZona = @CodigoZona);

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

    UPDATE Zona SET Estado = 1, DateDelete = NULL
    WHERE CodigoZona = @CodigoZona;

    SET @Mensaje = 'Zona restaurada correctamente';
END;
GO