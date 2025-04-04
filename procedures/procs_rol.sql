USE ZOO;

GO

-- Insertar un rol --
CREATE PROC ProcInsertRol  
    @NombreRol VARCHAR(50),  
    @Descripcion VARCHAR(MAX), 
    @Mensaje VARCHAR(100) OUTPUT   -- Mensaje de salida para el usuario
AS  
BEGIN  
    -- Miramos que no sean nulos
    IF @NombreRol IS NULL OR @Descripcion IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacios';
        RETURN;
    END

    -- Miramos que el nombre de rol no sea muy corto
    IF LEN(@NombreRol) < 2
    BEGIN
        SET @Mensaje = 'El nombre del rol debe tener al menos 2 caracteres';
        RETURN;
    END

    -- Buscamos si el nombre de rol ya existe
    DECLARE @name_exis AS VARCHAR(50);
    SET @name_exis = (SELECT NombreRol FROM Rol WHERE NombreRol = @NombreRol AND EstadoRol = 1);

    IF @name_exis IS NOT NULL
    BEGIN
        SET @Mensaje = 'El nombre del rol ya existe en la base de datos';
        RETURN;
    END

    -- Miramos que la descripcion no sea muy corta
    IF LEN(@Descripcion) < 5
    BEGIN
        SET @Mensaje = 'La descripcion del rol debe tener al menos 5 caracteres';
        RETURN;
    END
    
    INSERT INTO Rol (NombreRol, DescripRol)  
    VALUES (@NombreRol, @Descripcion);  

    SET @Mensaje = 'Rol insertado correctamente';
END;

GO

CREATE PROC ProcUpdateRol
    @CodigoRol UNIQUEIDENTIFIER,
    @NombreRol VARCHAR(50),  
    @Descripcion VARCHAR(MAX), 
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Miramos que no sean nulos
    IF @CodigoRol IS NULL OR @NombreRol IS NULL OR @Descripcion IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacios';
        RETURN;
    END

    -- Buscamos el rol
    DECLARE @rol_exis AS UNIQUEIDENTIFIER;
    SET @rol_exis = (SELECT CodigoRol FROM Rol WHERE CodigoRol = @CodigoRol AND EstadoRol = 1);

    IF @rol_exis IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de rol no existe en la base de datos';
        RETURN;
    END

    -- Miramos que el nombre de rol no sea muy corto
    IF LEN(@NombreRol) < 2
    BEGIN
        SET @Mensaje = 'El nombre del rol debe tener al menos 2 caracteres';
        RETURN;
    END

    -- Buscamos si el nombre de rol ya existe
    DECLARE @name_exis AS VARCHAR(50);
    SET @name_exis = (SELECT NombreRol FROM Rol WHERE NombreRol = @NombreRol AND CodigoRol <> @CodigoRol AND EstadoRol = 1);

    IF @name_exis IS NOT NULL
    BEGIN
        SET @Mensaje = 'El nombre del rol ya existe en la base de datos';
        RETURN;
    END

    -- Miramos que la descripcion no sea muy corta
    IF LEN(@Descripcion) < 5
    BEGIN
        SET @Mensaje = 'La descripcion del rol debe tener al menos 5 caracteres';
        RETURN;
    END

    UPDATE Rol SET
        NombreRol = @NombreRol,
        DescripRol = @Descripcion
    WHERE CodigoRol = @CodigoRol;

    SET @Mensaje = 'Rol actualizado correctamente';
END;

GO

-- Eliminar un rol --
CREATE PROC ProcDeleteRol
    @CodigoRol UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Miramos que el codigo no sea nulo
    IF @CodigoRol IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de rol no puede estar vacio';
        RETURN;
    END

    -- Buscamos el rol
    DECLARE @rol_exis AS UNIQUEIDENTIFIER;
    SET @rol_exis = (SELECT EstadoRol FROM Rol WHERE CodigoRol = @CodigoRol);

    IF @rol_exis IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de rol no existe en la base de datos';
        RETURN;
    END

    -- Miramos que el rol no este eliminado
    IF @rol_exis = 0
    BEGIN
        SET @Mensaje = 'El rol ya esta eliminado';
        RETURN;
    END

    UPDATE Rol SET
        EstadoRol = 0,
        DateDelete = GETDATE()
    WHERE CodigoRol = @CodigoRol;

    SET @Mensaje = 'Rol eliminado correctamente';
END;

GO

-- Recuperar un rol --
CREATE PROC ProcRecoverRol
    @CodigoRol UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Miramos que el codigo no sea nulo
    IF @CodigoRol IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de rol no puede estar vacio';
        RETURN;
    END

    -- Buscamos el rol
    DECLARE @rol_exis AS UNIQUEIDENTIFIER;
    SET @rol_exis = (SELECT EstadoRol FROM Rol WHERE CodigoRol = @CodigoRol);

    IF @rol_exis IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de rol no existe en la base de datos';
        RETURN;
    END

    -- Miramos que el rol esta activo
    IF @rol_exis = 1
    BEGIN
        SET @Mensaje = 'El rol ya esta activo';
        RETURN;
    END

    UPDATE Rol SET
        EstadoRol = 1,
        DateDelete = NULL
    WHERE CodigoRol = @CodigoRol;

    SET @Mensaje = 'Rol recuperado correctamente';
END;