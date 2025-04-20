USE ZOO

GO


--------------------------INSERCCION GUIAITINERARIO---------------------------
CREATE PROC INSERTAR_GUIA_ITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		-- Verificar que los parametros no sean nulos
		IF @IdEmpleado IS NULL OR @IdItinerario IS NULL
		BEGIN
			SET @MENSAJE = 'No pueden haber parametros nulos';
			RETURN;
		END

		BEGIN TRANSACTION;

		DECLARE @EXIST_EMPLEADO AS BIT 
		SET @EXIST_EMPLEADO =(SELECT EstadoEmpleado FROM Empleado WITH (UPDLOCK,ROWLOCK) WHERE CodigEmpleado = @IdEmpleado);

		-- Verificar si existe el empleado
		IF (@EXIST_EMPLEADO IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado no existe';
			RETURN;
		END

		IF(@EXIST_EMPLEADO = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='El empleado esta inactivo';
			RETURN;
		END
		----------------Buscamos el cargo
		DECLARE @NOMBRE_CARGO AS NVARCHAR(50)
		SET @NOMBRE_CARGO = (
							SELECT c.NombreCargo FROM Empleado e WITH (UPDLOCK,ROWLOCK) join Cargo c 
							ON e.IdCargo = c.CodifoCargo
							WHERE e.CodigEmpleado = @IdEmpleado
							);
		------------Verficamos que el cuiador no sea un guia
		IF(LOWER(@NOMBRE_CARGO) = 'cuidador')
		BEGIN	
			ROLLBACK TRANSACTION;
			SET @MENSAJE ='El cuidador no puede ser un guia';
			RETURN;
		END

		DECLARE @EXIST_ITINERARIO AS BIT
		SET @EXIST_ITINERARIO=(SELECT Estado FROM  Itinerario WITH (UPDLOCK,ROWLOCK) WHERE CodigoIti = @IdItinerario);

		-- Verificar si existe el itinerario
		IF (@EXIST_ITINERARIO IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El itinerario no existe';
			RETURN;
		END

		IF(@EXIST_ITINERARIO = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='El itinerario esta inactivo';
			RETURN;
		END
		-----------------verificar si el guia esta asigando al itinerario
		IF EXISTS (SELECT 1 FROM GuiaItinerario WITH (UPDLOCK,ROWLOCK) WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado ya esta asignado a este itinerario';
			RETURN;
		END

		-- Insertar la relacion
		INSERT INTO GuiaItinerario (Empleado, Itinerario)
		VALUES (@IdEmpleado, @IdItinerario);

		-- Verificar que se inserto correctamente
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error al insertar en la tabla';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Insercion realizada correctamente';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @MENSAJE = 'Error al insertar en la relacion: ' + ERROR_MESSAGE();
	END CATCH
END