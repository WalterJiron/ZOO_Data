USE ZOO;

GO

CREATE PROC ProcDeleteDetalleEmpleado
    @CodigoDetEmpleado UNIQUEIDENTIFIER,
    @Mensaje NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @CodigoDetEmpleado IS NULL
        BEGIN
            SET @Mensaje = 'El código del detalle es obligatorio.';
            RETURN;
        END
        
        BEGIN TRANSACTION;

        DECLARE @existDetalleEmpleado BIT; 
        SET @existDetalleEmpleado = (SELECT EstadoDetalleEmpleado 
                FROM DetalleEmpleado WHERE CodigoDetEmpleado = @CodigoDetEmpleado);

        IF @existDetalleEmpleado IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El detalle del empleado no existe.';
            RETURN;
        END

        IF @existDetalleEmpleado = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El detalle del empleado ya esta inactivo.';
            RETURN;
        END

        UPDATE DetalleEmpleado SET
            EstadoDetalleEmpleado = 0,
            DateDelete = GETDATE()
        WHERE CodigoDetEmpleado = @CodigoDetEmpleado;

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error al desactivar el detalle del empleado.';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Detalle del empleado desactivado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Mensaje = 'Error al desactivar el detalle del empleado: ' + ERROR_MESSAGE();
    END CATCH
END