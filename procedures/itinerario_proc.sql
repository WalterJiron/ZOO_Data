----itinerario-------
-------------------- Insertar itinerario -------------------------
CREATE PROC ProcInsertItinerario
    @Duracion TIME,
    @Longitud DECIMAL(10,2),
    @MaxVisitantes INT,
    @NumEspecies INT,
    @Fecha DATE,
    @Hora TIME,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF @Duracion IS NULL OR @Longitud IS NULL OR @MaxVisitantes IS NULL OR 
       @NumEspecies IS NULL OR @Fecha IS NULL OR @Hora IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    IF @Longitud <= 0
    BEGIN
        SET @Mensaje = 'La longitud debe ser mayor a 0';
        RETURN;
    END

    IF @MaxVisitantes <= 0
    BEGIN
        SET @Mensaje = 'El número máximo de visitantes debe ser mayor a 0';
        RETURN;
    END

    IF @NumEspecies < 0
    BEGIN
        SET @Mensaje = 'El número de especies no puede ser negativo';
        RETURN;
    END

    IF @Fecha < CAST(GETDATE() AS DATE)
    BEGIN
        SET @Mensaje = 'La fecha debe ser igual o posterior a hoy';
        RETURN;
    END

    INSERT INTO Itinerario (Duracion, Longitud, MaxVisitantes, NumEspecies, Fecha, Hora)
    VALUES (@Duracion, @Longitud, @MaxVisitantes, @NumEspecies, @Fecha, @Hora);

    SET @Mensaje = 'Itinerario insertado correctamente';
END;

------------------------------ actualizar itinerario --
CREATE PROC ProcUpdateItinerario
    @CodigoIti UNIQUEIDENTIFIER,
    @Duracion TIME,
    @Longitud DECIMAL(10,2),
    @MaxVisitantes INT,
    @NumEspecies INT,
    @Fecha DATE,
    @Hora TIME,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoIti = @CodigoIti AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El itinerario no existe o está inactivo';
        RETURN;
    END

    IF @Longitud <= 0
    BEGIN
        SET @Mensaje = 'La longitud debe ser mayor a 0';
        RETURN;
    END

    IF @MaxVisitantes <= 0
    BEGIN
        SET @Mensaje = 'El número máximo de visitantes debe ser mayor a 0';
        RETURN;
    END

    IF @NumEspecies < 0
    BEGIN
        SET @Mensaje = 'El número de especies no puede ser negativo';
        RETURN;
    END

    IF @Fecha < CAST(GETDATE() AS DATE)
    BEGIN
        SET @Mensaje = 'La fecha debe ser igual o posterior a hoy';
        RETURN;
    END

    UPDATE Itinerario
    SET Duracion = @Duracion,
        Longitud = @Longitud,
        MaxVisitantes = @MaxVisitantes,
        NumEspecies = @NumEspecies,
        Fecha = @Fecha,
        Hora = @Hora
    WHERE CodigoIti = @CodigoIti;

    SET @Mensaje = 'Itinerario actualizado correctamente';
END;

--------------------- eliminar itinerario --
CREATE PROC ProcDeleteItinerario
    @CodigoIti UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoIti = @CodigoIti AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El itinerario no existe o ya está eliminado';
        RETURN;
    END

    UPDATE Itinerario
    SET Estado = 0,
        DateDelete = GETDATE()
    WHERE CodigoIti = @CodigoIti;

    SET @Mensaje = 'Itinerario eliminado lógicamente';
END;

------recuperar itinerario--------------

CREATE PROC ProcRecoverItinerario
    @CodigoIti UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoIti = @CodigoIti AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El itinerario no existe o ya está eliminado';
        RETURN;
    END

    UPDATE Itinerario
    SET Estado = 1,
        DateDelete = GETDATE()
    WHERE CodigoIti = @CodigoIti;

    SET @Mensaje = 'Itinerario recuperado';
END;
