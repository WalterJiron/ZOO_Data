USE ZOO;

GO

CREATE PROCEDURE Insertar_Cargo
    @NombreC NVARCHAR(50),
    @DescripcionC NVARCHAR(MAX),
    @MENSAJE NVARCHAR(100) OUTPUT
AS
BEGIN
	BEGIN TRY
        ---VALIDAR QUE NO SEA NULO y validamos espacios en blanco
        IF @NombreC IS NULL OR LTRIM(RTRIM(@NombreC)) = '' OR @DescripcionC IS NULL OR LTRIM(RTRIM(@DescripcionC)) = ''
        BEGIN
            SET @MENSAJE = 'Los campos no pueden estar vacios';
            RETURN;
        END

        -- Miramos que el nombre no sea muy pequeño o muy grande
        IF LEN(@NombreC) < 3 OR LEN(@NombreC) > 100
        BEGIN
            SET @MENSAJE = 'El nombre tiene que tener al menos 3 caracteres minimo y 100 maximos.';
            RETURN;
        END

        -- Miramos que la decripcion no sea muy pequeño o muy grande
        IF LEN(@DescripcionC) < 15 OR LEN(@DescripcionC) > 250
        BEGIN
            SET @MENSAJE = 'La decripcion tiene que tener al menos 15 caracteres minimo y 250 maximos.';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Validar si el nombre del cargo ya existe
        IF EXISTS (SELECT 1 FROM Cargo WHERE NombreCargo = @NombreC)
        BEGIN
            ROLLBACK TRANSACTION;
            SET @MENSAJE = 'El nombre del cargo ya existe';
            RETURN;
        END

        -- Insertar el nuevo cargo con estado activo
        INSERT INTO Cargo (NombreCargo, DescripCargo)
        VALUES (@NombreC, @DescripcionC);

         -- Verificar que se inserto correctamente
        IF @@ROWCOUNT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Mensaje = 'Error al insertar el cargo';
            RETURN;
        END

        COMMIT TRANSACTION;
        SET @MENSAJE = 'Insercion realizada con exito';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @MENSAJE = 'Error al insertar el cargo: ' + ERROR_MESSAGE();
    END CATCH
END;