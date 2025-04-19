USE ZOO;

GO

CREATE PROC ProcInsertZona
    @NameZona NVARCHAR(100),
    @Extension DECIMAL(10,2),
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @NameZona IS NULL OR @Extension IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios';
            RETURN;
        END

        IF LEN(TRIM(@NameZona)) < 3 AND LEN(TRIM(@NameZona)) > 100
        BEGIN
            SET @Mensaje = 'El nombre debe tener al menos 3 caracteres y menos de 100';
            RETURN;
        END

        IF @Extension <= 0
        BEGIN
            SET @Mensaje = 'La extension debe ser mayor a cero';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Verificar nombre unico 
        IF EXISTS (
            SELECT 1 FROM Zona WITH (UPDLOCK)
            WHERE NameZona = TRIM(@NameZona)
              AND EstadoZona = 1
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Ya existe una zona activa con ese nombre';
            RETURN;
        END

        INSERT INTO Zona ( NameZona, EstadoZona )
        VALUES ( TRIM(@NameZona), @Extension );

        -- Verificar insercion exitosa
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error al insertar la zona';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Zona registrada correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        -- Manejo especifico de errores
        DECLARE @ErrorNumber INT = ERROR_NUMBER();
        
        IF @ErrorNumber = 2627 -- Violacion de clave unica
            SET @Mensaje = 'Error: Ya existe una zona con ese identificador';
        ELSE IF @ErrorNumber = 1205 -- Deadlock
            SET @Mensaje = 'Error: Intente nuevamente, el sistema estuvo ocupado';
        ELSE
            SET @Mensaje = 'Error al registrar zona: ' + ERROR_MESSAGE();
            
        -- EXEC usp_LogError; -- Opcional para registro de errores
    END CATCH
END;