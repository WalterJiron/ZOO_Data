USE ZOO;

GO

CREATE PROC ProcDeleteHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @CodigoHabitat IS NULL
        BEGIN
            SET @Mensaje = 'El codigo de habitat es obligatorio';
            RETURN;
        END

        BEGIN TRANSACTION;

        DECLARE @existHabitad AS BIT;
        SET @existHabitad = (
            SELECT EstadoHabitat FROM Habitat WITH(UPDLOCK, ROWLOCK)
            WHERE CodigoHabitat = @CodigoHabitat);

        IF @existHabitad IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El habitat no existe en la base de datos';
            RETURN;
        END

        IF @existHabitad = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'El habitat ya se encuentra inactivo';
            RETURN;
        END

        -- Verificar si hay especies asociadas
        IF EXISTS (SELECT 1 FROM EspecieHabitat WITH (UPDLOCK) WHERE Habitat = @CodigoHabitat)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'No se puede eliminar, existen especies asociadas a este habitat';
            RETURN;
        END

        UPDATE Habitat SET 
            EstadoHabitat = 0, 
            DateDelete = SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time'
        WHERE CodigoHabitat = @CodigoHabitat;

        -- Validar que se actualizo exactamente 1 registro
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error inesperado al eliminar el habitat';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Habitat desactivado correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Mensaje = 'Error al desactivar habitat: ' + ERROR_MESSAGE();
    END CATCH
END;