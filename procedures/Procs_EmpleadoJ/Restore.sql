use ZOO; 

GO

-------------------------------ACTIVAR EMPLEADO---------------------------
CREATE PROC ACTIVAREMPLEADO
    @CDE UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY 
		-- Validar si el codigo es nulo
		IF(@CDE IS NULL)
		BEGIN
			SET @MENSAJE = 'El codigo no puede ser nulo';
			RETURN;
		END

		BEGIN TRANSACTION;

		DECLARE @empleado_existe AS BIT;
		SET @empleado_existe = (SELECT EstadoEmpleado FROM Empleado WITH (UPDLOCK,ROWLOCK) WHERE CodigEmpleado = @CDE);

		-- Verificar si el empleado existe
		IF(@empleado_existe IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado no esta registrado';
			RETURN;
		END

		-- Verificar si el empleado ya esta activo
		IF(@empleado_existe = 1)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado ya esta activo';
			RETURN;
		END

		-- Actualizar el estado a activo
		UPDATE Empleado set
			EstadoEmpleado = 1,
			DateDelete= NULL
		WHERE CodigEmpleado = @CDE;

		IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al activar al empleado';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Activacion realizada con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al activar al empledo: ' + ERROR_MESSAGE();
	END CATCH
END;