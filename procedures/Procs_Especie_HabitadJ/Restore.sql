USE ZOO

GO

USE ZOO

GO

----------------------activar especiehabitad--------------------------
CREATE PROC Activar_EspecieHabitat
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
	 
		IF(@EXISTENCIA = 1)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La union ya se encuentra activa';
			RETURN;
		END

		-- Actualizar la relacion a activa y establecer
		UPDATE EspecieHabitat SET 
			EstadoEH = 1,
			DateDelete = NULL
		WHERE Especie = @Especie AND Habitat = @Habitat;

				 -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al activar la tabla';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'La relacion entre la especie y el habitat ha sido activada con exito';
   END TRY
   BEGIN CATCH
   		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al actualizar la tabla: ' + ERROR_MESSAGE();
   END CATCH
END
