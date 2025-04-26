USE ZOO;

GO

CREATE PROC ProcRestorDetalleEmpleado
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

        IF @existDetalleEmpleado = 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El detalle del empleado ya esta activo.';
            RETURN;
        END

        -- Verificar si el empleado asociado esta activo
        DECLARE @EstadoEmpleado BIT;
        SELECT @EstadoEmpleado = E.EstadoEmpleado
        FROM DetalleEmpleado  AS DET
        JOIN Empleado AS E
        ON DET.CodigEmpleado = E.CodigEmpleado
        WHERE DET.CodigoDetEmpleado = @CodigoDetEmpleado;

        IF @EstadoEmpleado = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'No se puede reactivar el detalle porque el empleado asociado esta inactivo.';
            RETURN;
        END

        UPDATE DetalleEmpleado SET
            EstadoDetalleEmpleado = 1,
            DateDelete = NULL
        WHERE CodigoDetEmpleado = @CodigoDetEmpleado;

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error al reactivar el detalle del empleado.';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Detalle del empleado reactivado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Mensaje = 'Error al reactivar el detalle del empleado: ' + ERROR_MESSAGE();
    END CATCH
END