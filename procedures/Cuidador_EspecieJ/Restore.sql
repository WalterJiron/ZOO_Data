USE ZOO

GO

---------------------------activar---------------------------------
CREATE PROCEDURE Activar_CuidadorEspecie
@IdEmpleado UNIQUEIDENTIFIER,
@IdEspecie UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY 

				
		IF(@IdEmpleado IS NULL OR @IdEspecie IS NULL)
		BEGIN
			SET @MENSAJE = 'Los campos no pueden ser nulos';
			RETURN;
		END

		BEGIN TRANSACTION;
		-- Declarar una variable para almacenar el estado de la relacion
		DECLARE @EstadoActual BIT;

		-- Obtener el estado actual de la relacion
		SELECT @EstadoActual = EstadoCE FROM CuidadorEspecie WITH(UPDLOCK,ROWLOCK) 
		WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie;

		-- Validar si la relacion existe
		IF @EstadoActual IS NULL
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion no existe';
			RETURN;
		END

		-- Validar si ya est� activa
		IF @EstadoActual = 1
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion ya esta activa';
			RETURN;
		END

		-- Cambiar estado a activa
		UPDATE CuidadorEspecie
		SET EstadoCE = 1
		WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie;

		IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al actualizar al cuidador';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'La relacion ha sido activada con exito';

	END TRY 
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al activar al cuidador: ' + ERROR_MESSAGE();
	END CATCH
END



-------------------listo--------------