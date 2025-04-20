USE ZOO

GO

------------------ELIMINACION HABITADCONTINENTE---------------------
CREATE PROC Eliminar_HabitatContinente
@Habitat UNIQUEIDENTIFIER,
@Cont INT,
@MENSAJE NVARCHAR(100) OUTPUT
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

		---VERIFICAR QUE ESTE INACTIVA
		IF(@existencia=0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='ya se encuentra activa';
			RETURN;
		END
		-- Cambiar estado a inactivo 
		UPDATE HabitatContinente SET
			EstadoHC = 0
		WHERE Habitat = @Habitat AND Cont = @Cont;

		-- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al eliminar la relacion';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'La relacion ha sido desactivada';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al eliminar la relacion: ' + ERROR_MESSAGE();
	END CATCH
END;