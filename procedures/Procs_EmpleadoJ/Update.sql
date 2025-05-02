USE ZOO

GO

-------------------------------update empleado--------------------------------------
CREATE PROCEDURE UPDATE_EMPLEADO
    @CDE UNIQUEIDENTIFIER,
    @PrimerNE NVARCHAR(25),
    @SegundoNE NVARCHAR(25),
    @PrimerAE NVARCHAR(25),
    @SegundoAE NVARCHAR(25),
    @DIREMPLEADO NVARCHAR(200),
    @TELEFONO VARCHAR(8),
    @EMAIL NVARCHAR(100),
    @FECHAINGRE DATE,
    @IdCargo UNIQUEIDENTIFIER,
    @MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    BEGIN TRY
		-- Validamos que los datos obligatorios no sean vacios o nulos
		IF (LEN(@CDE)=0 OR LEN(@PrimerNE) = 0 OR LEN(@SegundoNE) = 0 OR LEN(@PrimerAE) = 0 OR LEN(@SegundoAE) = 0 OR
			LEN(@DIREMPLEADO) = 0 OR @TELEFONO IS NULL OR LEN(@EMAIL) = 0 OR @IdCargo IS NULL)
		BEGIN
			SET @MENSAJE = 'Los campos no pueden ser valores nulos';
			RETURN;
		END

		BEGIN TRANSACTION;

		-- Validamos que el empleado exista
		DECLARE @empleado_existe BIT;
		SET @empleado_existe = (SELECT EstadoEmpleado FROM Empleado WITH (UPDLOCK,ROWLOCK) WHERE CodigEmpleado = @CDE);

		-- Verificar si el empleado existe
		IF(@empleado_existe IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado no esta registrado';
			RETURN;
		END

		-- Miramos que este activo (Empleado)
		IF(@empleado_existe = 0)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El empleado ya esta inactivo';
			RETURN;
		END

		-- Validamos que el cargo exista
		IF LEN(@PrimerNE) < 3 OR LEN(@SegundoNE) < 3 OR LEN(@PrimerAE) < 3 OR LEN(@SegundoAE) < 3
		BEGIN
			SET @MENSAJE = 'Los nombres y apellidos deben tener al menos 3 caracteres';
			RETURN;
		END

		-- Validamos que el cargo exista
		IF LEN(@PrimerNE) > 25 OR LEN(@SegundoNE) > 25 OR LEN(@PrimerAE) > 25 OR LEN(@SegundoAE) > 25
		BEGIN
			SET @MENSAJE = 'Los nombres y apellidos no pueden tener mas de 25 caracteres';
			RETURN;
		END

		-- Validamos que el cargo exista
		IF LEN(@DIREMPLEADO) < 5
		BEGIN
			SET @MENSAJE = 'La direccion debe tener al menos 5 caracteres';
			RETURN;
		END

		-- Validamos que el cargo exista
		DECLARE @cargo_existe BIT;
		SET @cargo_existe = (SELECT EstadoCargo FROM Cargo WITH (UPDLOCK,ROWLOCK) WHERE CodifoCargo = @IdCargo);

		IF (@cargo_existe IS NULL)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @MENSAJE = 'El cargo no existe';
			RETURN;
		END

		-- Miramso que el cargo este activo
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
		WHERE TelefonoE = @TELEFONO OR EmailE = @EMAIL AND CodigEmpleado <> @CDE;

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

		-- Realizar la actualizacion
		UPDATE Empleado SET
			PNE = @PrimerNE,
			SNE = @SegundoNE,
			PAE = @PrimerAE,
			SAE = @SegundoAE,
			DireccionE = @DIREMPLEADO,
			TelefonoE = @TELEFONO,
			EmailE = @EMAIL,
			FechaIngreso = @FECHAINGRE,
			IdCargo = @IdCargo,
			DateUpdate = SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time'
		WHERE CodigEmpleado = @CDE;

		 -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'Error inesperado al actualizar al empleado';
            RETURN;
        END

        COMMIT TRANSACTION;
		SET @MENSAJE = 'Actualizacion realizada con exito';
	END TRY 
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @MENSAJE = 'Error al actualizar al empleado: ' + ERROR_MESSAGE();
	END CATCH
END;