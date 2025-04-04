USE ZOO;

GO

-- Insertar un usuario --
CREATE PROC ProcInsertUser
    @NameUser NVARCHAR(50),
    @Email NVARCHAR(100),
    @Clave NVARCHAR(100),
    @Rol UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT  
AS
BEGIN
    -- Miramos que los campos no sean nulos
    IF @NameUser IS NULL OR @Email IS NULL or @Clave IS NULL OR @Rol IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacios';
        RETURN;
    END

    -- Miramos que el nombre no sea muy corto
    IF LEN(@NameUser) < 3
    BEGIN
        SET @Mensaje = 'El nombre de usuario debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Verificamos que el correo este en un formato valido
    IF @Email NOT LIKE '%__@__%.__%' 
    BEGIN
        SET @Mensaje = 'El correo no es valido';
        RETURN;
    END

    -- Buscamos si el correo ya existe
    DECLARE @email_exis AS NVARCHAR(100);
    SET @email_exis = (SELECT Email FROM Users WHERE Email = @Email);

    IF @email_exis IS NOT NULL
    BEGIN
        SET @Mensaje = 'El correo ya existe en la base de datos';
        RETURN;
    END

    -- Buscamos si el rol exite
    DECLARE @rol_exis AS UNIQUEIDENTIFIER;
    SET @rol_exis = (SELECT CodigoRol FROM Rol WHERE CodigoRol = @Rol);

    IF @rol_exis IS NULL
    BEGIN
        SET @Mensaje = 'EL codigo de rol no existe en la base de datos';
        RETURN;
    END

    -------------- Validamos que la clave cumpla con los requisitos --------------
    IF @Clave NOT LIKE '%[0-9]%'  
    BEGIN
        SET @Mensaje = 'La clave debe contener al menos un numero';
        RETURN;
    END

    IF @Clave NOT LIKE '%[a-z]%'
    BEGIN
        SET @Mensaje = 'La clave debe contener al menos una letra minuscula';
        RETURN;
    END

    IF @Clave NOT LIKE '%[A-Z]%'
    BEGIN
        SET @Mensaje = 'La clave debe contener al menos una letra mayascula';
        RETURN;
    END

    IF @Clave NOT LIKE '%[^a-zA-Z0-9]%'
    BEGIN
        SET @Mensaje = 'La clave debe contener al menos un caracter especial';
        RETURN;
    END

    IF LEN(@Clave) < 8
    BEGIN
        SET @Mensaje = 'La clave debe tener al menos 8 caracteres';
        RETURN;
    END

    INSERT INTO Users (NameUser, Email, Clave, Rol)
    VALUES (@NameUser, @Email, HASHBYTES('SHA2_256', @Clave), @Rol);

    SET @Mensaje = 'Usuario insertado correctamente';
END;

GO

-- Actualizar un usuario --
CREATE PROC ProcUpdateUser
    @CodigoUser UNIQUEIDENTIFIER,
    @NameUser NVARCHAR(50),
    @Email NVARCHAR(100),
    @Clave NVARCHAR(100),
    @Rol UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Miramos que los campos no sean nulos
    IF @CodigoUser IS NULL OR @NameUser IS NULL OR @Email IS NULL OR @Clave IS NULL OR @Rol IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacios';
        RETURN;
    END

    -- Buscamos el usuario
    DECLARE @user_exis AS UNIQUEIDENTIFIER;
    SET @user_exis = (SELECT CodigoUser FROM Users WHERE CodigoUser = @CodigoUser AND EstadoUser = 1);

    IF @user_exis IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de usuario no existe en la base de datos';
        RETURN;
    END

    -- Miramos que el nombre no sea muy corto
    IF LEN(@NameUser) < 3
    BEGIN
        SET @Mensaje = 'El nombre de usuario debe tener al menos 3 caracteres';
        RETURN;
    END

    -- Verificamos que el correo este en un formato valido
    IF @Email NOT LIKE '%__@__%.__%' 
    BEGIN
        SET @Mensaje = 'El correo no es valido';
        RETURN;
    END

    -- Buscamos si el correo ya existe
    DECLARE @email_exis AS NVARCHAR(100);
    SET @email_exis = (SELECT Email FROM Users WHERE Email = @Email AND CodigoUser <> @CodigoUser);

    IF @email_exis IS NOT NULL
    BEGIN
        SET @Mensaje = 'El correo ya existe en la base de datos';
        RETURN;
    END

    -- Buscamos si el rol exite
    DECLARE @rol_exis AS UNIQUEIDENTIFIER;
    SET @rol_exis = (SELECT CodigoRol FROM Rol WHERE CodigoRol = @Rol);

    IF @rol_exis IS NULL
    BEGIN
        SET @Mensaje = 'EL codigo de rol no existe en la base de datos';
        RETURN;
    END

    -------------- Validamos que la clave cumpla con los requisitos --------------
    IF @Clave NOT LIKE '%[0-9]%'  
    BEGIN
        SET @Mensaje = 'La clave debe contener al menos un numero';
        RETURN;
    END

    IF @Clave NOT LIKE '%[a-z]%'
    BEGIN
        SET @Mensaje = 'La clave debe contener al menos una letra minuscula';
        RETURN;
    END

    IF @Clave NOT LIKE '%[A-Z]%'
    BEGIN
        SET @Mensaje = 'La clave debe contener al menos una letra mayascula';
        RETURN;
    END

    IF @Clave NOT LIKE '%[^a-zA-Z0-9]%'
    BEGIN
        SET @Mensaje = 'La clave debe contener al menos un caracter especial';
        RETURN;
    END

    IF LEN(@Clave) < 8
    BEGIN
        SET @Mensaje = 'La clave debe tener al menos 8 caracteres';
        RETURN;
    END

    UPDATE Users SET
        NameUser = @NameUser,
        Email = @Email,
        Clave = HASHBYTES('SHA2_256', @Clave),
        Rol = @Rol
    WHERE CodigoUser = @CodigoUser;

    SET @Mensaje = 'Usuario actualizado correctamente';
END;

GO

-- Eliminar un usuario --
CREATE PROC ProcDeleteUser
    @CodigoUser UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Miramos que el codigo no sea nulo
    IF @CodigoUser IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de usuario no puede estar vacio';
        RETURN;
    END

    -- Buscamos el usuario
    DECLARE @user_exis AS UNIQUEIDENTIFIER;
    SET @user_exis = (SELECT EstadoUser FROM Users WHERE CodigoUser = @CodigoUser);

    IF @user_exis IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de usuario no existe en la base de datos';
        RETURN;
    END

    -- Miramos que el usuario no este eliminado
    IF @user_exis = 0
    BEGIN
        SET @Mensaje = 'El usuario ya esta eliminado';
        RETURN;
    END

    UPDATE Users SET
        EstadoUser = 0,
        DateDelete = GETDATE()
    WHERE CodigoUser = @CodigoUser;

    SET @Mensaje = 'Usuario eliminado correctamente';
END;

GO

-- Recuperar un usuario --
CREATE PROC ProcRecoverUser
    @CodigoUser UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    -- Miramos que el codigo no sea nulo
    IF @CodigoUser IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de usuario no puede estar vacio';
        RETURN;
    END

    -- Buscamos el usuario
    DECLARE @user_exis AS UNIQUEIDENTIFIER;
    SET @user_exis = (SELECT EstadoUser FROM Users WHERE CodigoUser = @CodigoUser);

    IF @user_exis IS NULL
    BEGIN
        SET @Mensaje = 'El codigo de usuario no existe en la base de datos';
        RETURN;
    END

    -- Miramos que el usuario esta activo
    IF @user_exis = 1
    BEGIN
        SET @Mensaje = 'El usuario ya esta activo';
        RETURN;
    END

    UPDATE Users SET
        EstadoUser = 1,
        DateDelete = NULL
    WHERE CodigoUser = @CodigoUser;

    SET @Mensaje = 'Usuario recuperado correctamente';
END;