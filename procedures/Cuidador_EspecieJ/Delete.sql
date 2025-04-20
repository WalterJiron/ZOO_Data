USE ZOO

GO

---------------------------------ELIMINAR------------------------------------
ALTER PROCEDURE Eliminar_CuidadorEspecie
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
		SELECT @EstadoActual = EstadoCE FROM CuidadorEspecie WITH (UPDLOCK,ROWLOCK)
		WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie ;

		-- Validar si la relacion existe
		IF @EstadoActual IS NULL
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion no existe';
			RETURN;
		END

		-- Validar si ya esta inactiva
		IF @EstadoActual = 0
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion ya esta inactiva';
			RETURN;
		END

		-- Cambiar estado a inactiva
		UPDATE CuidadorEspecie
		SET EstadoCE = 0
		WHERE IdEmpleado = @IdEmpleado AND IdEspecie = @IdEspecie;

		IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al actualizar al cuidador';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'La relacion ha sido desactivada con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Mensaje = 'Error al eliminar al cuidador: ' + ERROR_MESSAGE();
	END CATCH
END