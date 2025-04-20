USE ZOO

GO

-----------------------------------UPDATE HABITADCONTINENTE
ALTER PROCEDURE Update_HabitatContinente
@Habitad UNIQUEIDENTIFIER,
@CONTINENTE INT,
@HabitadVieja UNIQUEIDENTIFIER,
@CONTINENTE_VIEJO INT,
@MENSAJE NVARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Validar que los parametros no sean nulos
		IF @Habitad IS NULL OR @CONTINENTE IS NULL OR @HabitadVieja IS NULL OR @CONTINENTE_VIEJO IS NULL 
		BEGIN
			SET @MENSAJE = 'No pueden haber parametros nulos';
			RETURN;
		END;

		BEGIN TRANSACTION;

		-- Validar si la relacion  existe
		IF NOT EXISTS (SELECT 1 FROM HabitatContinente WITH (UPDLOCK,ROWLOCK) WHERE Habitat = @HabitadVieja AND Cont = @CONTINENTE_VIEJO)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'No existe una relacion para actualizar';
			RETURN;
		END;

		DECLARE @EXIST_HABITAD AS BIT 
		SET @EXIST_HABITAD=(SELECT EstadoHabitat FROM Habitat WITH (UPDLOCK,ROWLOCK) WHERE CodigoHabitat = @Habitad);

		-- Validar si el habitat existe
		IF (@EXIST_HABITAD IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El habitat no existe';
			RETURN;
		END;

		IF(@EXIST_HABITAD = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='El habitad se encuentra inactiva';
			RETURN;
		END

	

		DECLARE @EXIST_CONTINENTE AS INT;
		SET @EXIST_CONTINENTE = (SELECT IdCont FROM Continente WITH (UPDLOCK,ROWLOCK) WHERE IdCont = @CONTINENTE);


		IF(@EXIST_CONTINENTE IS NULL)
		BEGIN 
			ROLLBACK TRANSACTION;
			SET @MENSAJE ='El id del continente proporcionado no existe';
			RETURN;
		END

		-- Actualizar la relacion
		UPDATE HabitatContinente SET
			Habitat=@Habitad,
			Cont=@CONTINENTE
		WHERE Habitat = @HabitadVieja AND Cont = @CONTINENTE_VIEJO;
		

		-- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al actualizar la tabla';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Actualizacion realizada con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al actualizar la relacion: ' + ERROR_MESSAGE();
	END CATCH
END;
GO