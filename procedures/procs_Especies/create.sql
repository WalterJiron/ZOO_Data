USE ZOO;

GO

CREATE PROC ProcInsertEspecie
    @Nombre NVARCHAR(100),
    @NombreCientifico NVARCHAR(100),
    @Descripcion NVARCHAR(MAX),
    @Mensaje VARCHAR(100) OUTPUT,
    @IDEspecie UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @Nombre IS NULL OR @NombreCientifico IS NULL OR @Descripcion IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios';
            RETURN;
        END

        IF LEN(TRIM(@Nombre)) < 3 AND LEN(TRIM(@Nombre)) > 100
        BEGIN
            SET @Mensaje = 'El nombre debe tener al menos 3 caracteres y no exceder los 100';
            RETURN;
        END

        IF LEN(TRIM(@NombreCientifico)) < 3 AND LEN(TRIM(@NombreCientifico)) > 100
        BEGIN
            SET @Mensaje = 'El nombre cientifico debe tener al menos 3 caracteres y no exceder los 100';
            RETURN;
        END

        IF LEN(TRIM(@Descripcion)) < 10
        BEGIN
            SET @Mensaje = 'La descripcion debe tener al menos 10 caracteres';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Verificar existencia con bloqueo para evitar condiciones de carrera
        IF EXISTS (SELECT 1 FROM Especie WITH (UPDLOCK) WHERE Nombre = @Nombre AND Estado = 1)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Ya existe una especie activa con ese nombre';
            RETURN;
        END

        SET @IDEspecie = NEWID();

        INSERT INTO Especie (CodigoEspecie, Nombre, NameCientifico, Descripcion )
        VALUES ( @IDEspecie, TRIM(@Nombre), TRIM(@NombreCientifico), TRIM(@Descripcion) );

        COMMIT TRANSACTION;
        SET @Mensaje = 'Especie registrada correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        SET @Mensaje = 'Error al registrar especie: ' + ERROR_MESSAGE();
            
    END CATCH
END;