USE ZOO;

GO

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
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Validaciones de NULL
        IF @CodigoItinerario IS NULL OR @Duracion IS NULL OR @Longitud IS NULL OR @MaxVisitantes IS NULL OR 
           @NumEspecies IS NULL OR @Fecha IS NULL OR @Hora IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios';
            RETURN;
        END

        DECLARE @existItinerario AS BIT;
        
        BEGIN TRANSACTION;
        
        -- Verificar existencia del itinerario dentro de la transacción
        SET @existItinerario = (SELECT Estado FROM Itinerario WITH (UPDLOCK) WHERE CodigoIti = @CodigoItinerario);

        IF @existItinerario IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El codigo del itinerario no se encuentra en la base de datos.';
            RETURN;
        END

        IF @existItinerario = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El itinerario esta inactivo.';
            RETURN;
        END

        IF @Duracion <= CAST('00:00:00' AS TIME)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La duracion debe ser un valor positivo';
            RETURN;
        END
        
        IF @Longitud <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La longitud debe ser mayor a cero';
            RETURN;
        END

        IF @MaxVisitantes <= 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El número maximo de visitantes debe ser mayor a cero';
            RETURN;
        END

        IF @NumEspecies < 0 OR @NumEspecies > 100  
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El numero de especies no puede ser negativo y el maximo permitido es de 100';
            RETURN;
        END

        IF @Fecha <= CAST(GETDATE() AS DATE) AND @Hora <= CAST(GETDATE() AS TIME)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La fecha y hora no puede ser en el pasado o de justo ahora';
            RETURN;
        END

        IF (DATEDIFF(MINUTE, 0, @Duracion) + DATEDIFF(MINUTE, 0, @Hora)) >= 1440
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La duracion excede el límite del día';
            RETURN;
        END

        -- Verificar disponibilidad de zonas dentro de la transaccion
        IF EXISTS (
            SELECT 1
            FROM Itinerario AS IT WITH (UPDLOCK)
            JOIN ItinerarioZona AS ITZO WITH (UPDLOCK) ON ITZO.Itinerario = IT.CodigoIti
            WHERE IT.Fecha = @Fecha AND IT.Hora = @Hora 
            AND IT.CodigoIti <> @CodigoItinerario 
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Las zonas ya estan ocupadas esa fecha y hora.';
            RETURN;
        END

        UPDATE Itinerario SET 
            Duracion = @Duracion,
            Longitud = @Longitud,
            MaxVisitantes = @MaxVisitantes,
            NumEspecies = @NumEspecies,
            Fecha = @Fecha,
            Hora = @Hora
        WHERE CodigoIti = @CodigoItinerario;

        -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al actualizar el itinerario';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Itinerario actualizado correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Mensaje = 'Error al actualizar el itinerario: ' + ERROR_MESSAGE();
    END CATCH
END;