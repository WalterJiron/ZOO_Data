----- proc itinerario -----

------------------------------------------ Insertar Itinerario--------------------------------
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
    -- Validaciones de NULL
    IF @Duracion IS NULL OR @Longitud IS NULL OR @MaxVisitantes IS NULL OR 
       @NumEspecies IS NULL OR @Fecha IS NULL OR @Hora IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END

    -- Validaciones adicionales

    --si consideras que esta validacion es innecesaria entonces borrala -- ESTA BIEN 
    IF @Duracion <= CAST('00:00:00' AS TIME)
        BEGIN
            SET @Mensaje = 'La duración debe ser un valor positivo';
        RETURN;
    END
    
    IF @Longitud <= 0
    BEGIN
        SET @Mensaje = 'La longitud debe ser mayor a cero';
        RETURN;
    END

    IF @MaxVisitantes <= 0
    BEGIN
        SET @Mensaje = 'El número máximo de visitantes debe ser mayor a cero';
        RETURN;
    END

    --valide que un maximo de especies sea 100 porque imagina si llegan a poner 10,000 especies 
    --lo mismo pensaba para visitantes, pero eso ya depende del negocio, cuantos puede soportar, agregarlo si consideras necesario
    -- Hay que ver bien eso ya que podria ser mayor que 100 pero asi dejalo por el momento
    --puedes quitarlo si no te parece
    IF @NumEspecies < 0 OR @NumEspecies > 100
    BEGIN
        SET @Mensaje = 'El número de especies no puede ser negativo y el maximo permitido es de 100';
        RETURN;
    END

    IF @Fecha = CAST(GETDATE() AS DATE) AND @Hora < CAST(GETDATE() AS TIME)
    BEGIN
        SET @Mensaje = 'La hora no puede ser en el pasado para itinerarios hoy';
        RETURN;
    END

    -- Verificar que hora + duración no pase de 23:59:59  Esto tambie depnde ya que no sabemos si el zoo tiene para  hospedarse
    --esta validacion creo que se podria conbinar con la anterior para tener un solo bloque, pero no se vos que pensas. 
    --ASI ESTA BIEN PARA EVITAR LA REDUNDANCIA 10/10
    IF DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @Duracion), @Hora) >= CAST('23:59:59' AS TIME)
    BEGIN
        SET @Mensaje = 'La duración excede el límite del día';
    RETURN;
    END

    -- Verificar que no exista ya un itinerario con la misma fecha y hora TE FALTA EL LUGAR
    -- YA QUE DOS ITINERARIOS PUEDEN TENES LA MISMA FECHA Y HORA PERO DIFERENE ZONA
    -- No exactamente necesario. Si te parece, dejalo. Sino, quítalo
    IF EXISTS (
        SELECT 1 FROM Itinerario 
        WHERE Fecha = @Fecha AND Hora = @Hora AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe un itinerario activo con la misma fecha y hora';
        RETURN;
    END

    -- Inserción
    INSERT INTO Itinerario (Duracion, Longitud, MaxVisitantes, NumEspecies, Fecha, Hora)
    VALUES (@Duracion, @Longitud, @MaxVisitantes, @NumEspecies, @Fecha, @Hora);

    SET @Mensaje = 'Itinerario insertado correctamente';
END;
GO

----------------------------------------------- Actualizar Itinerario -----------------------------------------

CREATE PROC ProcUpdateItinerario
    @CodigoItinerario UNIQUEIDENTIFIER,
    @Duracion TIME,
    @Longitud DECIMAL(10,2),
    @MaxVisitantes INT,
    @NumEspecies INT,
    @Fecha DATE,
    @Hora TIME,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
     -- Validaciones de NULL ESTO SIEMPRE VA PRIMERO
    IF @CodigoItinerario IS NULL OR @Duracion IS NULL OR @Longitud IS NULL OR 
       @MaxVisitantes IS NULL OR @NumEspecies IS NULL OR @Fecha IS NULL OR @Hora IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios';
        RETURN;
    END


    -- validacion para ver si el estado existe o  esta eliminado
    ----------- ESTAS SIENDO REDONDANTE EN LOS DATOS
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoIti = @CodigoItinerario AND Estado = 1)
    BEGIN
        SET @Mensaje = 'El itinerario no existe o está eliminado';
        RETURN;
    END

    -- Validaciones adicionales
    IF @Duracion <= CAST('00:00:00' AS TIME)
    BEGIN
        SET @Mensaje = 'La duración debe ser un valor positivo';
        RETURN;
    END
    
    --como consideracion estaba pensando que tambien se puede validar una longitud maxima, si te parece lo agregas
    IF @Longitud <= 0
    BEGIN
        SET @Mensaje = 'La longitud debe ser mayor a cero';
        RETURN;
    END

    IF @MaxVisitantes <= 0
    BEGIN
        SET @Mensaje = 'El número máximo de visitantes debe ser mayor a cero';
        RETURN;
    END

    
    IF @NumEspecies < 0 OR @NumEspecies > 100
    BEGIN
        SET @Mensaje = 'El número de especies no puede ser negativo y el maximo permitido es de 100';
        RETURN;
    END

    IF @Fecha = CAST(GETDATE() AS DATE) AND @Hora < CAST(GETDATE() AS TIME)
    BEGIN
        SET @Mensaje = 'La hora no puede ser en el pasado para itinerarios hoy';
        RETURN;
    END

    
    -- Verificar que hora + duración no pase de 23:59:59
    IF DATEADD(MINUTE, DATEDIFF(MINUTE, 0, @Duracion), @Hora) >= CAST('23:59:59' AS TIME)
    BEGIN
        SET @Mensaje = 'La duración excede el límite del día';
    RETURN;
    END

    -- Verificar que no haya otro itinerario en la misma fecha y hora
	-- No exactamente necesario. Si te parece, dejalo. Sino, quítalo
    -- HAY QUE HACER LO MISMO QUE TE DIJE EN EL ANTERIOR
    IF EXISTS (
        SELECT 1 FROM Itinerario 
        WHERE Fecha = @Fecha AND Hora = @Hora 
        AND CodigoIti <> @CodigoItinerario AND Estado = 1
    )
    BEGIN
        SET @Mensaje = 'Ya existe otro itinerario activo con la misma fecha y hora';
        RETURN;
    END

    UPDATE Itinerario
    SET Duracion = @Duracion,
        Longitud = @Longitud,
        MaxVisitantes = @MaxVisitantes,
        NumEspecies = @NumEspecies,
        Fecha = @Fecha,
        Hora = @Hora
    WHERE CodigoIti = @CodigoItinerario;

    SET @Mensaje = 'Itinerario actualizado correctamente';
END;
GO

----------------------------------------------- Eliminar Itinerario -----------------------------------------------------

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

    ------------------------------- MALA PRACTICA HAY QUE OPTIMISAR LOS RECURSOS -------------------------------
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoIti = @CodigoItinerario)
    BEGIN
        SET @Mensaje = 'El itinerario no existe';
        RETURN;
    END

    DECLARE @Estado BIT = (SELECT Estado FROM Itinerario WHERE CodigoIti = @CodigoItinerario);

    IF @Estado = 0
    BEGIN
        SET @Mensaje = 'El itinerario ya está eliminado';
        RETURN;
    END

    UPDATE Itinerario
    SET Estado = 0, DateDelete = GETDATE()
    WHERE CodigoIti = @CodigoItinerario;

    SET @Mensaje = 'Itinerario eliminado correctamente';
END;
GO

----------------------------------------- Restaurar Itinerario ---------------------------------------

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

    ------------------------------- MALA PRACTICA HAY QUE OPTIMISAR LOS RECURSOS -------------------------------
    IF NOT EXISTS (SELECT 1 FROM Itinerario WHERE CodigoIti = @CodigoItinerario)
    BEGIN
        SET @Mensaje = 'El itinerario no existe';
        RETURN;
    END

    DECLARE @Estado BIT = (SELECT Estado FROM Itinerario WHERE CodigoIti = @CodigoItinerario);


    IF @Estado = 1
    BEGIN
        SET @Mensaje = 'El itinerario ya está activo';
        RETURN;
    END

    UPDATE Itinerario
    SET Estado = 1, DateDelete = NULL
    WHERE CodigoIti = @CodigoItinerario;

    SET @Mensaje = 'Itinerario restaurado correctamente';
END;
GO