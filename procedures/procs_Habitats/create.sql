USE ZOO;

GO

CREATE PROC ProcInsertHabitat
    @Nombre VARCHAR(100),
    @Clima VARCHAR(100),
    @DescripHabitat VARCHAR(MAX),
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT,
    @IdHabitat UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF @Nombre IS NULL OR @Clima IS NULL OR @DescripHabitat IS NULL OR @CodigoZona IS NULL
        BEGIN
            SET @Mensaje = 'Todos los campos son obligatorios';
            RETURN;
        END

        IF LEN(TRIM(@Nombre)) < 3 OR LEN(TRIM(@Nombre)) > 100
        BEGIN
            SET @Mensaje = 'El nombre debe tener entre 3 y 100 caracteres';
            RETURN;
        END 

        IF LEN(TRIM(@Clima)) < 5 OR LEN(TRIM(@Clima)) > 100
        BEGIN
            SET @Mensaje = 'El clima debe tener entre 5 y 100 caracteres';
            RETURN;
        END 

        IF LEN(TRIM(@DescripHabitat)) < 10 
        BEGIN
            SET @Mensaje = 'La Descripcion debe tener al menos 10 caracteres'
        END
        
        BEGIN TRANSACTION;

        -- Buscamos la zona
        DECLARE @existZona AS BIT;
        SET @existZona = (SELECT EstadoZona FROM Zona WHERE @CodigoZona = CodigoZona);

        IF @existZona IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona no existe en la base de datos';
            RETURN;
        END

        IF @existZona = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'La zona se encuentra inactiva';
            RETURN;
        END

        -- Verificar si ya existe un habitat con ese nombre
        IF EXISTS (SELECT 1 FROM Habitat WITH (UPDLOCK) WHERE Nombre = TRIM(@Nombre) AND EstadoHabitat = 1)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Ya existe un habitat activo con ese nombre';
            RETURN;
        END


        SET @IdHabitat = NEWID();

        INSERT INTO Habitat (
            CodigoHabitat, Nombre, Clima, 
            DescripHabitat, CodigoZona
        )
        VALUES (
            @IdHabitat, TRIM(@Nombre), TRIM(@Clima), 
            TRIM(@DescripHabitat), @CodigoZona
        );

        -- Verificar que se inserto correctamente
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error al insertar el habitat';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @Mensaje = 'Habitat registrado correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @Mensaje = 'Error al registrar habitat: ' + ERROR_MESSAGE();
    END CATCH
END;