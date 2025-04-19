USE ZOO;

GO

CREATE PROC ProcRestoreZona
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @CodigoZona IS NULL
        BEGIN
            SET @Mensaje = 'El codigo de zona es obligatorio';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Verificar existencia y estado 
        DECLARE @exist_Zona BIT;
        SET @exist_Zona = (
            SELECT EstadoZona FROM Zona WITH (UPDLOCK, ROWLOCK)
            WHERE CodigoZona = @CodigoZona
        )

        -- Validaciones de negocio
        IF @exist_Zona IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona no existe en la base de datos';
            RETURN;
        END

        IF @exist_Zona = 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona ya se encuentra activa';
            RETURN;
        END

        -- Verificar que no existan conflictos con zonas activas
        DECLARE @NombreZona NVARCHAR(100);
        SELECT @NombreZona = NameZona
        FROM Zona WITH (UPDLOCK)
        WHERE CodigoZona = @CodigoZona;

        IF EXISTS (
            SELECT 1 FROM Zona WITH (UPDLOCK)
            WHERE NameZona = @NombreZona
              AND CodigoZona <> @CodigoZona
              AND EstadoZona = 1
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'No se puede restaurar, ya existe una zona activa con ese nombre';
            RETURN;
        END

        UPDATE Zona SET 
            EstadoZona = 1, 
            DateDelete = NULL
        WHERE CodigoZona = @CodigoZona;

        -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al restaurar la zona';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Zona restaurada correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
       
        SET @Mensaje = 'Error al restaurar zona: ' + ERROR_MESSAGE();
    END CATCH
END;