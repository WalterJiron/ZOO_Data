USE ZOO

GO
------------------------------------Eliminar CARGO-----------------------

CREATE PROCEDURE ELIMINAR_CARGO 
    @CDC UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF (@CDC IS NULL)
		BEGIN
			SET @MENSAJE = 'El codigo no puede ser nulo';
			RETURN;
		END

		BEGIN TRANSACTION;
		-- Buscado el cargo
		DECLARE @cargo_exist AS BIT;
		SET @cargo_exist = (SELECT EstadoCargo FROM Cargo WITH (UPDLOCK,ROWLOCK)
							WHERE CodifoCargo = @CDC);

		-- Verificar si el cargo existe
		IF @cargo_exist IS NULL
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El cargo no esta registrado';
			RETURN;
		END

		-- Verificar si el cargo ya esta inactivo
		IF @cargo_exist = 0
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El cargo ya se encuentra inactivo';
			RETURN;
		END

		-- Desactivar el cargo
		UPDATE Cargo SET
			EstadoCargo = 0,
			DateDelete = GETDATE()
		WHERE CodifoCargo = @CDC;
		
		-- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al eliminar el cargo';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Eliminacion con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK TRANSACTION;

			SET @MENSAJE = 'Error al eliminar el cargo :' + ERROR_MESSAGE();
	END CATCH
END;