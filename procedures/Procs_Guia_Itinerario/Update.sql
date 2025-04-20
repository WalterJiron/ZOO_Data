USE ZOO

GO


---------------------------upadte GUIAITINERARIO---------------------------------
ALTER PROC UPDATE_GUIA_ITINERARIO
@IDEMPLEADO_VIEJO UNIQUEIDENTIFIER,
@IDITINERARIO_VIEJO UNIQUEIDENTIFIER,
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		 -- Verificar que los parametros no sean nulos
		IF @IdEmpleado IS NULL OR @IdItinerario IS NULL OR @IDEMPLEADO_VIEJO IS NULL OR @IDITINERARIO_VIEJO IS NULL
		BEGIN
			SET @MENSAJE = 'No pueden haber parametros nulos';
			RETURN;
		END

		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM GuiaItinerario WITH (UPDLOCK,ROWLOCK) 
		WHERE Empleado = @IDEMPLEADO_VIEJO AND Itinerario = @IDITINERARIO_VIEJO )
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion a la que intenta actualizar no existe';
			RETURN;
		END

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
			SET @MENSAJE ='El empleado no puede ser un cuidador';
			RETURN;
		END

		DECLARE @EXIST_ITINERARIO AS BIT
		SET @EXIST_ITINERARIO=(SELECT Estado FROM Itinerario WITH (UPDLOCK,ROWLOCK) WHERE CodigoIti = @IdItinerario);

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

		-- Verificar si la relacion ya existe
		IF EXISTS(SELECT 1 FROM GuiaItinerario WITH (UPDLOCK,ROWLOCK) WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion ya existe';
			RETURN;
		END

		UPDATE GuiaItinerario SET 
			Empleado=@IdEmpleado,
			Itinerario=@IdItinerario
		WHERE Empleado=@IDEMPLEADO_VIEJO AND Itinerario=@IDITINERARIO_VIEJO

	    -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al actualizar la tabla';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE='Update con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al actualizar la tabla: ' + ERROR_MESSAGE();
	END CATCH
END
