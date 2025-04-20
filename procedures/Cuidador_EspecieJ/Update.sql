USE ZOO

GO


------------------------------------update ---------------------------------
alter PROC Actualizar_Cuidador_Especie
@IDEMPLEADO_VIEJO UNIQUEIDENTIFIER,
@IDESPECIE_VIEJO UNIQUEIDENTIFIER,
@IdEmpleado UNIQUEIDENTIFIER,
@IdEspecie UNIQUEIDENTIFIER,
@FechaAsignacion DATE,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		-- Validar que los parametros no sean nulos
		IF (@IDEMPLEADO_VIEJO IS NULL OR @IDESPECIE_VIEJO IS NULL OR @IdEmpleado IS NULL OR @IdEspecie IS NULL OR @FechaAsignacion IS NULL)
		BEGIN
			SET @MENSAJE = 'No pueden haber parametros nulos';
			RETURN;
		END
	
		-- Validar que la fecha de asignacion no sea mayor a la fecha actual
		IF (@FechaAsignacion >DATEADD(MONTH,1,GETDATE()))
		BEGIN
			SET @MENSAJE = 'La fecha de asignacion no puede ser mayor a un mes ';
			RETURN;
		END


		BEGIN TRANSACTION;

		DECLARE @EXSITS_EMPLEADO AS BIT
		SET @EXSITS_EMPLEADO = (SELECT EstadoEmpleado FROM Empleado WITH (UPDLOCK,ROWLOCK) WHERE CodigEmpleado = @IDEMPLEADO_VIEJO);

		-- Validar que el empleado exista
		IF (@EXSITS_EMPLEADO IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado no existe';
			RETURN;
		END

		IF(@EXSITS_EMPLEADO = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado esta inactivo';
			RETURN;
		END

			--------Buscamos el cargo del empleado
		DECLARE @NOMBRE_CARGO AS NVARCHAR(50)
		SET @NOMBRE_CARGO = (
							SELECT c.NombreCargo FROM Empleado e WITH (UPDLOCK)join Cargo c 
							on e.IdCargo = c.CodifoCargo 
							WHERE e.CodigEmpleado = @IdEmpleado
							);
		------VALIDAR QUE EL GUIA NO SEA UN CUIDADOR
		IF (@NOMBRE_CARGO = 'Guia')
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El guia no puede ser un cuidador';
			RETURN;
		END

		DECLARE @EXIST_ESPECIE AS BIT
		SET @EXIST_ESPECIE = (SELECT Estado FROM Especie WITH(UPDLOCK,ROWLOCK) WHERE CodigoEspecie = @IDESPECIE_VIEJO);

		-- Validar que la especie exista
		IF (@EXIST_ESPECIE IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La especie no existe';
			RETURN;
		END

		IF(@EXIST_ESPECIE = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La especie se encuentra inactiva';
			RETURN;
		END

		--------------validar la existencia de la relacion
		IF NOT EXISTS (SELECT 1 FROM CuidadorEspecie WITH(UPDLOCK,ROWLOCK)
						WHERE IdEmpleado = @IDEMPLEADO_VIEJO AND IdEspecie = @IDESPECIE_VIEJO)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'No existe una relacion previa entre el cuidador y la especie';
			RETURN;
		END

		-- Actualizar la fecha de asignacion
		UPDATE CuidadorEspecie SET 
				IdEmpleado=@IdEmpleado,
				IdEspecie=@IdEspecie,
				FechaAsignacion = @FechaAsignacion
		WHERE IdEmpleado = @IDEMPLEADO_VIEJO AND IdEspecie = @IDESPECIE_VIEJO;

		 -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al actualizar al cuidador';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Actualizacion realizada con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al actualizar al cuidador: ' + ERROR_MESSAGE();
	END CATCH

END;