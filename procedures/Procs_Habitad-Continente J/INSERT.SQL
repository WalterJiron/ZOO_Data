USE ZOO

GO


--------Inserccion HabitadContinentes-------------------------
ALTER Proc Insertar_HabitadContinente
@Habitad UNIQUEIDENTIFIER,
@CONTINENTE INT,
@MENSAJE NVARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Validar que los parametros no sean nulos
		IF @Habitad IS NULL OR @CONTINENTE IS NULL
		BEGIN
			SET @MENSAJE = 'No pueden haber parametros nulos';
			RETURN;
		END;

		BEGIN TRANSACTION;

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
		IF EXISTS (SELECT 1 FROM HabitatContinente WITH (UPDLOCK,ROWLOCK)WHERE Habitat=@Habitad AND Cont = @CONTINENTE)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion ya existe';
			RETURN;
		END

		INSERT INTO HabitatContinente (Habitat,Cont)
		VALUES(@Habitad,@CONTINENTE);

				-- Verificar que se inserto correctamente
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error al insertar en la tabla';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE='Inserccion con exito';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @MENSAJE = 'Error al insertar el cuidador: ' + ERROR_MESSAGE();
	END CATCH
END