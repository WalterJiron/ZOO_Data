USE ZOO;

GO

CREATE PROC ProcRestoreEspecie
    @CodigoEspecie UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @CodigoEspecie IS NULL
        BEGIN
            SET @Mensaje = 'El codigo de especie es obligatorio';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Verificar existencia 
        DECLARE @codigo_exist AS BIT;
        SET @codigo_exist = (SELECT Estado FROM Especie WITH(UPDLOCK, ROWLOCK) WHERE CodigoEspecie = @CodigoEspecie);

        -- Validaciones de negocio
        IF @codigo_exist IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La especie no existe en la base de datos';
            RETURN;
        END

        IF @codigo_exist = 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La especie ya se encuentra activa';
            RETURN;
        END

        UPDATE Especie SET 
            Estado = 1, 
            DateDelete = NULL
        WHERE CodigoEspecie = @CodigoEspecie;

        -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al activar la especie';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Especie activada correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Mensaje = 'Error al activar especie: ' + ERROR_MESSAGE();         
    END CATCH 
END;