USE ZOO;

GO

CREATE PROC ProcUpdateDetalleEmpleado
    @CodigoDetEmpleado UNIQUEIDENTIFIER,
    @Cedula NVARCHAR(16),
    @FechaNacimiento DATE,
    @Genero CHAR(1),
    @EstadoCivil NVARCHAR(20),
    @INSS NVARCHAR(9),
    @TelefonoEmergencia VARCHAR(8),
    @Mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @CodigoDetEmpleado IS NULL OR @Cedula IS NULL OR @FechaNacimiento IS NULL OR
           @Genero IS NULL OR @EstadoCivil IS NULL OR @INSS IS NULL OR @TelefonoEmergencia IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios.';
            RETURN;
        END

        IF @Genero NOT IN ('M', 'F', 'O')
        BEGIN
            SET @Mensaje = 'El genero debe ser M, F u O.';
            RETURN;
        END

        IF @EstadoCivil NOT IN ('Soltero', 'Casado', 'Divorciado', 'Viudo', 'Union Libre')
        BEGIN
            SET @Mensaje = 'El estado civil debe ser Soltero, Casado, Divorciado, Viudo o Union Libre.';
            RETURN;
        END

        IF @Cedula NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][A-Z]'
        BEGIN
            SET @Mensaje = 'La cedula no tiene el formato correcto: XXX-XXXXXX-XXXX.';
            RETURN;
        END

        IF LEN(@Cedula) <> 16
        BEGIN
            SET @Mensaje = 'La cedula debe tener 16 caracteres.';
            RETURN;
        END


        IF @INSS NOT LIKE '[0][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        BEGIN
            SET @Mensaje = 'El INSS no tiene el formato correcto: 000000000.';
            RETURN;
        END

        IF LEN(@INSS) <> 9
        BEGIN
            SET @Mensaje = 'El INSS debe tener 9 digitos.';
            RETURN;
        END

        IF @TelefonoEmergencia NOT LIKE '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        BEGIN
            SET @Mensaje = 'El telefono debe ser numerico (positivo) y empesar con 2,5,7 u 8.';
            RETURN;
        END

        IF LEN(@TelefonoEmergencia) <> 8
        BEGIN
            SET @Mensaje = 'El telefono debe tener 8 digitos.';
            RETURN;
        END

        IF @FechaNacimiento <= CAST(DATEADD(YEAR, -18, GETDATE()) AS DATE) 
        BEGIN
            SET @Mensaje = 'La fecha de nacimiento no es valida. (El empleado debe ser mayor de edad)';
            RETURN;
        END
        
        BEGIN TRANSACTION;

        DECLARE @EstadoDetalle BIT;
        SELECT @EstadoDetalle = EstadoDetalleEmpleado 
        FROM DetalleEmpleado 
        WHERE CodigoDetEmpleado = @CodigoDetEmpleado;

        IF @EstadoDetalle IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El detalle del empleado no existe.';
            RETURN;
        END

        IF @EstadoDetalle = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El detalle del empleado no esta activo.';
            RETURN;
        END

        SELECT @Mensaje = 
            CASE 
                WHEN EXISTS (SELECT 1 FROM DetalleEmpleado WHERE Cedula = @Cedula AND CodigoDetEmpleado <> @CodigoDetEmpleado)
                    THEN 'La cedula ya esta registrada para otro empleado.'
                WHEN EXISTS (SELECT 1 FROM DetalleEmpleado WHERE INSS = @INSS AND CodigoDetEmpleado <> @CodigoDetEmpleado)
                    THEN 'El INSS ya esta registrado para otro empleado.'
                WHEN EXISTS (SELECT 1 FROM DetalleEmpleado WHERE TelefonoEmergencia = @TelefonoEmergencia AND CodigoDetEmpleado <> @CodigoDetEmpleado)
                    THEN 'El telefono de emergencia ya esta registrado para otro empleado.'
                ELSE NULL
            END;

        IF @Mensaje IS NOT NULL
        BEGIN
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE DetalleEmpleado SET
            Cedula = @Cedula,
            FechaNacimiento = @FechaNacimiento,
            Genero = @Genero,
            EstadoCivil = @EstadoCivil,
            INSS = @INSS,
            TelefonoEmergencia = @TelefonoEmergencia
        WHERE CodigoDetEmpleado = @CodigoDetEmpleado;

        -- Verificar si la actualizacion fue exitosa
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error al actualizar el detalle del empleado.';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Detalle del empleado actualizado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Mensaje = 'Error al actualizar el detalle del empleado: ' + ERROR_MESSAGE();
    END CATCH
END