Use ZOO

GO
--------------------------activar habitadContinente-----------------
CREATE PROC Activar_HabitatContinente
@Habitat UNIQUEIDENTIFIER,
@Cont INT,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
		---VERIFICAR SI NO SON NULOS
		IF(@Habitat IS NULL OR @Cont IS NULL)
		BEGIN
			SET @MENSAJE='No pueden ser nulos';
			RETURN;
		END

		BEGIN TRANSACTION;
	 		----------BUSQUEDA-------
		Declare @existencia AS BIT
		SET @existencia=(SELECT EstadoHC FROM HabitatContinente WHERE Habitat = @Habitat AND Cont = @Cont);

		-- Verificar si la relacion existe 
		IF(@existencia IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion no existe ';
			RETURN;
		END

		---VERIFICAR QUE ESTE ACTIVA
		IF(@existencia=1)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='Esta activa';
		END
	
		-- Cambiar estado a activo 
		UPDATE HabitatContinente SET
				EstadoHC = 1
		WHERE Habitat = @Habitat AND Cont = @Cont;

		-- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al activar la relacion';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'La relacion ha sido activada';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al activar la relacion: ' + ERROR_MESSAGE();
	END CATCH
END;
GO
