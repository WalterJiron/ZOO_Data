USE ZOO;

GO

CREATE PROC ProcInsertDetalleEmpleado
    @CodigoEmpleado UNIQUEIDENTIFIER,
    @Cedula NVARCHAR(16),
    @FechaNacimiento DATE,
    @Genero CHAR(1),
    @EstadoCivil NVARCHAR(20),
    @INSS NVARCHAR(9),
    @TelefonoEmergencia VARCHAR(8),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @CodigoEmpleado IS NULL OR @Cedula IS NULL OR @FechaNacimiento IS NULL OR
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

        BEGIN TRANSACTION;

        DECLARE @existEmpleado BIT;
        SET @existEmpleado = (SELECT EstadoEmpleado FROM Empleado WHERE CodigEmpleado = @CodigoEmpleado);

        IF @existEmpleado IS NULL
        BEGIN
            SET @Mensaje = 'El empleado no existe.';
            RETURN;
        END
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Mensaje = 'Error al ingresar el detalle del empleado: ' + ERROR_MESSAGE();
    END CATCH
END