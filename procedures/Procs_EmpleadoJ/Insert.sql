USE ZOO

GO


------------------------------------INSERCCION EN LA TABLA EMPLEADO-------------------------------------
CREATE PROCEDURE INSERCCION_EMPLEADO
    @PrimerNE NVARCHAR(25),
    @SegundoNE NVARCHAR(25),
    @PrimerAE NVARCHAR(25),
    @SegundoAE NVARCHAR(25),
    @DIREMPLEADO NVARCHAR(200),
    @TELEFONO VARCHAR(8),
    @EMAIL NVARCHAR(100),
    @FECHAINGRE DATE,
    @IdCargo UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT,
    @CodigoEmpleado UNIQUEIDENTIFIER OUTPUT
AS
BEGIN 
    SET NOCOUNT ON;

	BEGIN TRY 
		-- Validamos que los datos obligatorios no sean vacios o nulos
		IF (LEN(@PrimerNE) = 0 OR LEN(@SegundoNE) = 0 OR LEN(@PrimerAE) = 0 OR LEN(@SegundoAE) = 0 OR
			LEN(@DIREMPLEADO) = 0 OR @TELEFONO IS NULL OR LEN(@EMAIL) = 0 OR @IdCargo IS NULL)
		BEGIN
			SET @MENSAJE = 'Los campos no pueden ser valores nulos';
			RETURN;
		END

		-- Validamos que los nombre no sean muy cortos
		IF LEN(@PrimerNE) < 3 OR LEN(@SegundoNE) < 3 OR LEN(@PrimerAE) < 3 OR LEN(@SegundoAE) < 3
		BEGIN
			SET @MENSAJE = 'Los nombres y apellidos deben tener al menos 3 caracteres';
			RETURN;
		END

		-- Validamos que los nombre no sean muy largo
		IF LEN(@PrimerNE) > 25 OR LEN(@SegundoNE) > 25 OR LEN(@PrimerAE) > 25 OR LEN(@SegundoAE) > 25
		BEGIN
			SET @MENSAJE = 'Los nombres y apellidos no pueden tener mas de 25 caracteres';
			RETURN;
		END

		-- Validamos que la direccion no sea muy corta o muy larga
		IF LEN(@DIREMPLEADO) < 10 OR LEN(@DIREMPLEADO) < 10
		BEGIN
			SET @MENSAJE = 'La direccion debe tener al menos 10 caracteres y un maximo de 200 caracteres.';
			RETURN;
		END

		BEGIN TRANSACTION;

		-- Validamos que el cargo exista
		DECLARE @cargo_existe BIT;
		SET @cargo_existe = (SELECT EstadoCargo FROM Cargo WITH (UPDLOCK,ROWLOCK) WHERE CodifoCargo = @IdCargo);

		IF (@cargo_existe IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El cargo no existe';
			RETURN;
		END

		-- Miramos que el cargo este activo
		IF (@cargo_existe = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El cargo no esta activo';
			RETURN;
		END

		------------------------- Verificar si la telefono o email ya estan registrados -------------------------
		DECLARE @CampoDuplicado NVARCHAR(15);
		SELECT TOP 1
			@CampoDuplicado = 
				CASE 
					WHEN TelefonoE = @TELEFONO THEN 'telefono'
					WHEN EmailE = @EMAIL THEN 'email'
				END
		FROM Empleado WITH (UPDLOCK,ROWLOCK)
		WHERE TelefonoE = @TELEFONO OR EmailE = @EMAIL;

		IF @CampoDuplicado IS NOT NULL
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El ' + @CampoDuplicado + ' ya está registrado';
			RETURN;
		END

		-- Validar que el telefono comience con 2, 5, 7 u 8
		IF (@TELEFONO NOT LIKE '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
		BEGIN
			SET @MENSAJE = 'El primer digito debe ser 2,5,7 u 8 y los demas numeros deben ser numericos.';
			RETURN;
		END

		-- Validamos que la fecha de ingreso no sea mayor que la fecha de inauguracion
		IF (@FECHAINGRE < TRY_CONVERT(DATE, '2000/05/18'))
		BEGIN
			SET @MENSAJE = 'La fecha de ingreso no puede ser inferior a la fecha de inauguracion';
			RETURN;
		END

		IF (@FECHAINGRE < TRY_CONVERT(DATE, DATEADD(MONTH, 1, GETDATE())))
		BEGIN
			SET @MENSAJE = 'La fecha de ingreso no puede ser superior a un mes.';
			RETURN;
		END

		SET @CodigoEmpleado = NEWID();

		-- Insertar empleado
		INSERT INTO Empleado(
			CodigEmpleado, PNE, SNE, PAE, SAE, 
			DireccionE, TelefonoE, EmailE, FechaIngreso, IdCargo)
		VALUES(
			@CodigoEmpleado, @PrimerNE, @SegundoNE, @PrimerAE, @SegundoAE, @DIREMPLEADO,
			@TELEFONO, @EMAIL, @FECHAINGRE, @IdCargo
		);

		-- Verificar que se inserto correctamente
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error al insertar el empleado';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Inserccion realizada con exito';
	END TRY 
	BEGIN CATCH
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @MENSAJE = 'Error al insertar al empleado: ' + ERROR_MESSAGE();
	END CATCH
END;
