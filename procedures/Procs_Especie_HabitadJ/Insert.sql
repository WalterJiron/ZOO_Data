USE ZOO

GO


-----------INSERTAR ESPECIEHABITAD------------------------
CREATE PROC INSERTAR_ESPECIEHABITAD
@ESPECIE UNIQUEIDENTIFIER,
@HABITAD UNIQUEIDENTIFIER,
@MENSAJE NVARCHAR(100)OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY 
		---validar que no sean nulos
		IF(@ESPECIE IS NULL OR @HABITAD IS NULL)
		BEGIN
			SET @MENSAJE='No puede ser parametros nulos';
			RETURN;
		END

		BEGIN TRANSACTION;

		DECLARE @EXISTSHABITAD AS BIT
		SET @EXISTSHABITAD=(SELECT EstadoHabitat FROM Habitat  WITH (UPDLOCK,ROWLOCK) WHERE CodigoHabitat=@HABITAD);

		----validar que la especie existe
		IF(@EXISTSHABITAD IS NULL )
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='la habitad no existe ';
			RETURN;
		END

		IF(@EXISTSHABITAD = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La habitad se encuentra inactiva';
			RETURN;
		END	
	
		DECLARE @EXISTESPECIE AS BIT 
		SET @EXISTESPECIE=(SELECT 1 FROM Especie  WITH (UPDLOCK,ROWLOCK) WHERE CodigoEspecie=@ESPECIE);


		----validar que el habitad existe
		IF (@EXISTESPECIE IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='La especie no existe';
		END

		IF(@EXISTESPECIE = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE='LA ESPECIE SE ENCUENTRA INACTIVA';
			RETURN
		END

		IF EXISTS (SELECT 1 FROM EspecieHabitat WITH(UPDLOCK,ROWLOCK) WHERE Especie = @ESPECIE AND Habitat = @HABITAD)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'La relacion especie-habitat ya existe';
			RETURN;
		END

		INSERT INTO EspecieHabitat(Especie,Habitat)
		VALUES(@ESPECIE,@HABITAD);

		-- Verificar que se inserto correctamente
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error al insertar';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE='Inserccion realizada';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @MENSAJE = 'Error al insertar el habitad o la especie: ' + ERROR_MESSAGE();
	END CATCH
END
