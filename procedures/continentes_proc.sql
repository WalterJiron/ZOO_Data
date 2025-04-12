---- PROC CONTINENTE ----   

--	Insertar continente --

CREATE PROCEDURE continente_proc
    @Accion VARCHAR(10),
    @CodigoCont UNIQUEIDENTIFIER = NULL,
    @NombreCont NVARCHAR(100) = NULL,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @Accion = 'insert'
    BEGIN
        IF @NombreCont IS NULL OR LEN(@NombreCont) < 3
        BEGIN
            SET @Mensaje = 'El nombre del continente debe tener al menos 3 caracteres';
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Continente WHERE NombreCont = @NombreCont AND Estado = 1)
        BEGIN
            SET @Mensaje = 'Ya existe un continente activo con ese nombre';
            RETURN;
        END

        INSERT INTO Continente (NombreCont)
        VALUES (@NombreCont);

        SET @Mensaje = 'Continente insertado correctamente';
    END

    ELSE IF @Accion = 'update'
    BEGIN
        IF @CodigoCont IS NULL
        BEGIN
            SET @Mensaje = 'Debe proporcionar el c�digo del continente';
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Continente WHERE CodigoCont = @CodigoCont)
        BEGIN
            SET @Mensaje = 'El continente no existe';
            RETURN;
        END

        IF @NombreCont IS NULL OR LEN(@NombreCont) < 3
        BEGIN
            SET @Mensaje = 'El nuevo nombre debe tener al menos 3 caracteres';
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM Continente 
            WHERE NombreCont = @NombreCont 
              AND CodigoCont != @CodigoCont 
              AND Estado = 1
        )
        BEGIN
            SET @Mensaje = 'Otro continente activo ya tiene ese nombre';
            RETURN;
        END

        UPDATE Continente
        SET NombreCont = @NombreCont
        WHERE CodigoCont = @CodigoCont;

        SET @Mensaje = 'Continente actualizado correctamente';
    END

    ELSE IF @Accion = 'delete'
    BEGIN
        IF @CodigoCont IS NULL
        BEGIN
            SET @Mensaje = 'Debe proporcionar el c�digo del continente a eliminar';
            RETURN;
        END

        UPDATE Continente
        SET Estado = 0, DateDelete = GETDATE()
        WHERE CodigoCont = @CodigoCont;

        SET @Mensaje = 'Continente eliminado correctamente';
    END

    ELSE IF @Accion = 'restore'
    BEGIN
        IF @CodigoCont IS NULL
        BEGIN
            SET @Mensaje = 'Debe proporcionar el c�digo del continente a restaurar';
            RETURN;
        END

        UPDATE Continente
        SET Estado = 1, DateDelete = NULL
        WHERE CodigoCont = @CodigoCont;

        SET @Mensaje = 'Continente restaurado correctamente';
    END

    ELSE
    BEGIN
        SET @Mensaje = 'Acci�n no v�lida';
    END
END;

-- Actualizar contienente --
CREATE PROC ProcUpdateContinente
    @CodigoContinente UNIQUEIDENTIFIER,
    @NuevoNombre NVARCHAR(100),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoContinente IS NULL OR @NuevoNombre IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF LEN(@NuevoNombre) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    DECLARE @EstadoContinente BIT;
    SET @EstadoContinente = (SELECT Estado FROM Continente WHERE CodigoContinente = @CodigoContinente);

    IF @EstadoContinente IS NULL
    BEGIN
        SET @Mensaje = 'El continente no existe';
        RETURN;
    END

    IF @EstadoContinente = 0
    BEGIN
        SET @Mensaje = 'El continente est� eliminado';
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM Continente
        WHERE Nombre = @NuevoNombre AND CodigoContinente != @CodigoContinente AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro continente activo con ese nombre';
        RETURN;
    END

    UPDATE Continente SET Nombre = @NuevoNombre
    WHERE CodigoContinente = @CodigoContinente;

    SET @Mensaje = 'Continente actualizado correctamente';
END;
GO

-- eliminar continente ---

CREATE PROC ProcDeleteContinente
    @CodigoContinente UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @CodigoContinente IS NULL
    BEGIN
        SET @Mensaje = 'El c�digo de continente es obligatorio';
        RETURN;
    END

    DECLARE @EstadoContinente BIT;
    SET @EstadoContinente = (SELECT Estado FROM Continente WHERE CodigoContinente = @CodigoContinente);

    IF @EstadoContinente IS NULL
    BEGIN
        SET @Mensaje = 'El continente no existe';
        RETURN;
    END

    IF @EstadoContinente = 0
    BEGIN
        SET @Mensaje = 'El continente ya est� eliminado';
        RETURN;
    END

    UPDATE Continente SET Estado = 0, DateDelete = GETDATE()
    WHERE CodigoContinente = @CodigoContinente;

    SET @Mensaje = 'Continente eliminado correctamente';
END;
GO

-- No hay una restauraci�n para continente, 
-- por l�gica puede tratarse como un registro cr�tico en la jerarqu�a geogr�fica. 
-- Una vez eliminado, solo podr�a insertarse nuevamente
