USE ZOO

GO


-------------------ELIMINAR ESPECIE HABITAD------------------
CREATE PROC Desactivar_EspecieHabitat
@Especie UNIQUEIDENTIFIER,
@Habitat UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

	BEGIN TRY
		-- Validar que los parametros no sean nulos
	   IF(@Especie IS NULL OR @Habitat IS NULL)
		BEGIN
			SET @MENSAJE='Los parametros no pueden ser nulos';
			RETURN;
		END

		BEGIN TRANSACTION;

		DECLARE @EXISTENCIA AS BIT 
		SET @EXISTENCIA=(SELECT EstadoEH FROM EspecieHabitat WITH (UPDLOCK,ROWLOCK) WHERE Especie=@Especie AND Habitat=@Habitat);

		-- Validar si la especie existe
		IF (@EXISTENCIA IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La union del habitad y la especie no existe';
			RETURN;
		END
	 
		IF(@EXISTENCIA = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La union ya se encuentra inactiva';
			RETURN;
		END

		-- Actualizar la relacion a inactiva y establecer la fecha de eliminacion
		UPDATE EspecieHabitat SET 
			EstadoEH = 0,
			DateDelete = GETDATE()  -- Asignamos la fecha de eliminacion actual
		WHERE Especie = @Especie AND Habitat = @Habitat;

		
		 -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al eliminar la tabla';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'La relacion entre la especie y el habitat ha sido desactivada con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al eliminar la tabla: ' + ERROR_MESSAGE();
	END CATCH
END
GO