USE ZOO;

GO

CREATE PROC ProcInsertItinerario
    @Duracion TIME,
    @Longitud DECIMAL(10,2),
    @MaxVisitantes INT,
    @NumEspecies INT,
    @Fecha DATE,
    @Hora TIME,
    @Mensaje VARCHAR(100) OUTPUT,        
    @NuevoIdItinerario UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validaciones iniciales
        IF @Duracion IS NULL OR @Longitud IS NULL OR @MaxVisitantes IS NULL OR 
           @NumEspecies IS NULL OR @Fecha IS NULL OR @Hora IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios';
            RETURN;
        END

        IF @Duracion <= CAST('00:00:00' AS TIME)
        BEGIN
            SET @Mensaje = 'La duración debe ser mayor a cero';
            RETURN;
        END

        IF @Longitud <= 0
        BEGIN
            SET @Mensaje = 'La longitud debe ser mayor a cero';
            RETURN;
        END

        IF @MaxVisitantes <= 0
        BEGIN
            SET @Mensaje = 'El número de visitantes debe ser mayor a cero';
            RETURN;
        END

        IF @NumEspecies < 0 OR @NumEspecies > 100
        BEGIN
            SET @Mensaje = 'Número de especies inválido (debe ser entre 0 y 100)';
            RETURN;
        END

        BEGIN TRANSACTION;
        
        -- Validaciones que requieren acceso a la base de datos
        IF @Fecha < CAST(GETDATE() AS DATE) OR 
          (@Fecha = CAST(GETDATE() AS DATE) AND @Hora <= CAST(GETDATE() AS TIME))
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Fecha y hora deben ser futuras';
            RETURN;
        END

        IF (DATEDIFF(MINUTE, 0, @Duracion) + DATEDIFF(MINUTE, 0, @Hora)) >= 1440
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La duración excede el límite de 24 horas';
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM Itinerario AS IT WITH (UPDLOCK)
            JOIN ItinerarioZona AS ITZO WITH (UPDLOCK) ON ITZO.Itinerario = IT.CodigoIti
            WHERE IT.Fecha = @Fecha AND IT.Hora = @Hora
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Las zonas ya están ocupadas para la fecha y hora especificadas';
            RETURN;
        END

        -- Generar nuevo ID
        SET @NuevoIdItinerario = NEWID();

        INSERT INTO Itinerario (
            CodigoIti, Duracion, Longitud, 
            MaxVisitantes, NumEspecies, Fecha, Hora
        )
        VALUES (
            @NuevoIdItinerario, @Duracion, @Longitud, 
            @MaxVisitantes, @NumEspecies, @Fecha, @Hora
        );

        COMMIT TRANSACTION;

        SET @Mensaje = 'Itinerario registrado correctamente';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
         SET @Mensaje = 'Error al insertar el itinerario: ' + ERROR_MESSAGE();

    END CATCH
END;