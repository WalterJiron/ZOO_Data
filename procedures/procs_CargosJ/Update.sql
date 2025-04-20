USE ZOO

GO
--------------------UPDATE CARGO------------------------
CREATE PROCEDURE UPDATE_CARGO   
	@CDC_VIEJO UNIQUEIDENTIFIER,
    @CDC UNIQUEIDENTIFIER,
    @NombreC NVARCHAR(50),   
    @DescripcionC NVARCHAR(MAX),   
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON; 
	
    BEGIN TRY
		IF @NombreC IS NULL OR TRIM(@NombreC) = '' OR @DescripcionC IS NULL OR TRIM(@DescripcionC) = ''
		BEGIN
			SET @MENSAJE = 'Los campos no pueden estar vacios';
			RETURN;
		END

		IF LEN(@NombreC) < 3 OR LEN(@NombreC) > 100
		BEGIN
			SET @MENSAJE = 'El nombre tiene que tener al menos 3 caracteres minimo y 100 maximos.';
			RETURN;
		END

		IF LEN(@DescripcionC) < 15 OR LEN(@DescripcionC) > 250
		BEGIN
			SET @MENSAJE = 'La decripcion tiene que tener al menos 15 caracteres minimo y 250 maximos.';
			RETURN;
		END

		BEGIN TRANSACTION;
		-- Buscamos el codigo del cargo
		DECLARE @cargo_exist AS BIT;
		SET @cargo_exist = (SELECT EstadoCargo FROM Cargo WITH (UPDLOCK,ROWLOCK) WHERE CodifoCargo = @CDC_VIEJO);

		-- Verificar si el cargo existe
		IF @cargo_exist IS NULL
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El cargo no existe';
			RETURN;
		END

		-- Verificar si el cargo esta activo
		IF @cargo_exist = 0
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El cargo se encuentra inactivo';
			RETURN;
		END

		-- Verificar si el nombre del cargo ya esta en uso
		IF EXISTS (SELECT 1 FROM Cargo WITH (UPDLOCK,ROWLOCK) WHERE NombreCargo = @NombreC AND CodifoCargo <> @CDC_VIEJO)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'Nombre de cargo ya existente';
			RETURN;
		END

		-- Actualizar los datos del cargo
		UPDATE Cargo SET
			NombreCargo = TRIM(@NombreC),
			DescripCargo = TRIM(@DescripcionC)
		WHERE CodifoCargo = @CDC_VIEJO;

		-- Validar que se actualizo
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al actualizar el cargo';
            RETURN;
        END

		COMMIT TRANSACTION;
		-- Mensaje de exito
		SET @MENSAJE = 'Update realizada con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @MENSAJE = 'Error al actualizar el cargo :' + ERROR_MESSAGE();
	END CATCH
END;
