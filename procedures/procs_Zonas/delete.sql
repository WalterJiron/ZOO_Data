USE ZOO;

GO

CREATE PROC ProcDeleteZona
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
        SET @exist_Zona =(
            SELECT EstadoZona FROM Zona WITH (UPDLOCK, ROWLOCK)
            WHERE CodigoZona = @CodigoZona
        ) 

        IF @exist_Zona IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona no existe en la base de datos';
            RETURN;
        END

        IF @exist_Zona = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona ya se encuentra inactiva';
            RETURN;
        END

        -- Verificar si hay habitats asociados a la zona
        IF EXISTS (
            SELECT 1 FROM Habitat WITH (UPDLOCK)
            WHERE CodigoZona = @CodigoZona
              AND EstadoHabitat = 1
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'No se puede eliminar, existen habitats activos en esta zona';
            RETURN;
        END

        UPDATE Zona SET 
            EstadoZona = 0, 
            DateDelete = GETDATE()
        WHERE CodigoZona = @CodigoZona;

        -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al eliminar la zona';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Zona desactivada correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
         
        SET @Mensaje = 'Error al desactivar zona: ' + ERROR_MESSAGE();
    END CATCH
END;