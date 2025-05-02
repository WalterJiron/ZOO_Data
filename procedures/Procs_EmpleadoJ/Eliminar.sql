USE ZOO

GO


-----------------------------ELIMINAR EMPLEADO----------------------------------
CREATE PROC ELIMINAR_EMPLEADO
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

		-- Verificar si el empleado ya esta inactivo
		IF(@empleado_existe = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado ya esta inactivo';
			RETURN;
		END

		-- Actualizar el estado a inactivo
		UPDATE Empleado set
			EstadoEmpleado = 0,
			DateDelete = SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time'--ACTUALIZAMOS SU FECHA DE ELIMINACION
		WHERE CodigEmpleado = @CDE;

		-- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al eliminar al empleado';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Eliminacion realizada con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al eliminar al empledo: ' + ERROR_MESSAGE();
	END CATCH
END;