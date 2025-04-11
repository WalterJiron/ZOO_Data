--- proc habitat --
-- Nada te parece. Vlt, hacelo vos



------------------------------- Insertar Habitat --------------------------------
CREATE PROC ProcInsertHabitat
    @Nombre VARCHAR(100),
    @Clima VARCHAR(100),
    @DescripHabitat VARCHAR(MAX),
    @CodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN

    ----------- ESTAS SIENDO REDONDANTE EN LOS DATOS
    -- Validaciones de entrada
    --La cantidad de caracteres puede se cambiada. (Si no te parece cambialo vos)
    IF @Nombre IS NULL OR LEN(@Nombre) < 5 OR @Clima IS NULL OR LEN(@Clima) < 5 OR @DescripHabitat IS NULL OR @CodigoZona IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios y el nombre y clima deben tener al menos 5 caracteres';
        RETURN;
    END

    --estas validaciones si no te parecen puedes eliminarlas o cambiar el numero
    IF LEN(@Nombre) > 100
    BEGIN
        SET @Mensaje = 'El nombre no puede exceder los 100 caracteres'
        RETURN;
    END 

    IF LEN(@Clima) > 100
    BEGIN
        SET @Mensaje = 'El clima no puede exceder los 100 caracteres'
        RETURN;
    END 
    
    -- Validación de existencia de la zona
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @CodigoZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'La zona especificada no existe o está inactiva';
        RETURN;
    END

    -- Inserción en la tabla Habitat
    INSERT INTO Habitat (Nombre, Clima, DescripHabitat, CodigoZona)
    VALUES (@Nombre, @Clima, @DescripHabitat, @CodigoZona);

    SET @Mensaje = 'Hábitat insertado correctamente';
END;
GO

--------------------------------- Actualizar Habitat -------------------------------------

CREATE PROC ProcUpdateHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @NuevoNombre VARCHAR(100),
    @NuevoClima VARCHAR(100),
    @NuevaDescripcion VARCHAR(MAX),
    @NuevoCodigoZona UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN

    ----------- ESTAS SIENDO REDONDANTE EN LOS DATOS
    -- Validación de existencia del hábitat
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat AND EstadoHabitat = 1)
    BEGIN
        SET @Mensaje = 'El hábitat no existe o está eliminado';
        RETURN;
    END

    ----------- ESTAS SIENDO REDONDANTE EN LOS DATOS
    -- Validaciones de entrada
    IF @CodigoHabitat IS NULL OR @NuevoNombre IS NULL OR LEN(@NuevoNombre) < 5 OR @NuevoClima IS NULL OR LEN(@NuevoClima) < 5 OR @NuevaDescripcion IS NULL OR @NuevoCodigoZona IS NULL
    BEGIN
        SET @Mensaje = 'Todos los campos son obligatorios y el nombre y clima deben tener al menos 5 caracteres';
        RETURN;
    END


    --estas validaciones si no te parecen puedes eliminarlas o cambiar el numero
    IF LEN(@NuevoNombre) > 100
    BEGIN
        SET @Mensaje = 'El nombre no puede exceder los 100 caracteres'
        RETURN;
    END 

    IF LEN(@NuevoClima) > 100
    BEGIN
        SET @Mensaje = 'El clima no puede exceder los 100 caracteres'
        RETURN;
    END 
    
    
    ----------- ESTAS SIENDO REDONDANTE EN LOS DATOS
    -- Validación de existencia de la nueva zona
    IF NOT EXISTS (SELECT 1 FROM Zona WHERE CodigoZona = @NuevoCodigoZona AND EstadoZona = 1)
    BEGIN
        SET @Mensaje = 'La nueva zona especificada no existe o está inactiva';
        RETURN;
    END

    -- Actualización del hábitat
    UPDATE Habitat
    SET Nombre = @NuevoNombre,
        Clima = @NuevoClima,
        DescripHabitat = @NuevaDescripcion,
        CodigoZona = @NuevoCodigoZona
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat actualizado correctamente';
END;
GO


---------------------------------------------------- Eliminar Habitat ------------------------------------------

CREATE PROC ProcDeleteHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación de código de hábitat
    IF @CodigoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El código del hábitat es obligatorio';
        RETURN;
    END

    ------------------------------- MALA PRACTICA HAY QUE OPTIMISAR LOS RECURSOS -------------------------------
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat)
    BEGIN
        SET @Mensaje = 'El hábitat no existe';
        RETURN;
    END

    DECLARE @Estado BIT = (SELECT EstadoHabitat FROM Habitat WHERE CodigoHabitat = @CodigoHabitat);

    -- Validación de si el hábitat ya está eliminado
    IF @Estado = 0
    BEGIN
        SET @Mensaje = 'El hábitat ya está eliminado';
        RETURN;
    END

    -- Eliminación lógica del hábitat
    UPDATE Habitat
    SET EstadoHabitat = 0, DateDelete = GETDATE()
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat eliminado correctamente';
END;
GO

------------------------------------------- Recuperar habitat eliminado --------------------------------------------

CREATE PROC ProcRestoreHabitat
    @CodigoHabitat UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Validación de código de hábitat
    IF @CodigoHabitat IS NULL
    BEGIN
        SET @Mensaje = 'El código del hábitat es obligatorio';
        RETURN;
    END

    ------------------------------- MALA PRACTICA HAY QUE OPTIMISAR LOS RECURSOS -------------------------------
    IF NOT EXISTS (SELECT 1 FROM Habitat WHERE CodigoHabitat = @CodigoHabitat)
    BEGIN
        SET @Mensaje = 'El hábitat no existe';
        RETURN;
    END

    DECLARE @Estado BIT = (SELECT EstadoHabitat FROM Habitat WHERE CodigoHabitat = @CodigoHabitat);

    -- Validación de si el hábitat ya está activo
    IF @Estado = 1
    BEGIN
        SET @Mensaje = 'El hábitat ya está activo';
        RETURN;
    END

    -- Restauración del hábitat
    UPDATE Habitat
    SET EstadoHabitat = 1, DateDelete = NULL
    WHERE CodigoHabitat = @CodigoHabitat;

    SET @Mensaje = 'Hábitat restaurado correctamente';
END;
GO