-----USUARIOS----------------


----------------------------- Procedimiento para insertar un nuevo usuario ---------------------------------------------
CREATE PROC ProcInsertUser
    @NameUser NVARCHAR(50),
    @Email NVARCHAR(100),
    @Clave NVARCHAR(100),
    @Rol UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT  
AS
BEGIN
    IF @NameUser IS NULL OR @Email IS NULL or @Clave IS NULL OR @Rol IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacios';
        RETURN;
    END

    IF LEN(@NameUser) < 3
    BEGIN
        SET @Mensaje = 'El nombre de usuario debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @Email NOT LIKE '%__@__%.__%' 
    BEGIN
        SET @Mensaje = 'El correo no es valido';
        RETURN;
    END

    DECLARE @email_exis AS NVARCHAR(100);
    SET @email_exis = (SELECT Email FROM Users WHERE Email = @Email);

    IF @email_exis IS NOT NULL
    BEGIN
        SET @Mensaje = 'El correo ya existe en la base de datos';
        RETURN;
    END

    DECLARE @rol_exis AS UNIQUEIDENTIFIER;
    SET @rol_exis = (SELECT CodigoRol FROM Rol WHERE CodigoRol = @Rol);

    IF @rol_exis IS NULL
    BEGIN
        SET @Mensaje = 'EL codigo de rol no existe en la base de datos';
        RETURN;
    END

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

---------------------------- Actualizar usuario --------------------------------
CREATE PROC ProcUpdateUser
    @CodigoUser UNIQUEIDENTIFIER,
    @NameUser NVARCHAR(50),
    @Email NVARCHAR(100),
    @Rol UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE CodigoUser = @CodigoUser AND EstadoUser = 1)
    BEGIN
        SET @Mensaje = 'El usuario no existe o está eliminado';
        RETURN;
    END

    IF @NameUser IS NULL OR @Email IS NULL OR @Rol IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacíos';
        RETURN;
    END

    IF LEN(@NameUser) < 3
    BEGIN
        SET @Mensaje = 'El nombre debe tener al menos 3 caracteres';
        RETURN;
    END

    IF @Email NOT LIKE '%@%.%' 
    BEGIN
        SET @Mensaje = 'El correo no es válido';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email AND CodigoUser <> @CodigoUser)
    BEGIN
        SET @Mensaje = 'El correo ya está en uso por otro usuario';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Rol WHERE CodigoRol = @Rol AND EstadoRol = 1)
    BEGIN
        SET @Mensaje = 'El rol no existe o está eliminado';
        RETURN;
    END

    UPDATE Users
    SET NameUser = @NameUser,
        Email = @Email,
        Rol = @Rol
    WHERE CodigoUser = @CodigoUser;

    SET @Mensaje = 'Usuario actualizado correctamente';
END;
GO

----------------------- eliminar usuario ---------------------
CREATE PROC ProcDeleteUser
    @CodigoUser UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE CodigoUser = @CodigoUser AND EstadoUser = 1)
    BEGIN
        SET @Mensaje = 'El usuario no existe o ya fue eliminado';
        RETURN;
    END

    UPDATE Users
    SET EstadoUser = 0,
        DateDelete = GETDATE()
    WHERE CodigoUser = @CodigoUser;

    SET @Mensaje = 'Usuario eliminado lógicamente';
END;
GO

------------------ recuperar usuario -------------------------------
CREATE PROC ProcRestoreUser
    @CodigoUser UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE CodigoUser = @CodigoUser AND EstadoUser = 0)
    BEGIN
        SET @Mensaje = 'El usuario no existe o ya está activo';
        RETURN;
    END

    UPDATE Users
    SET EstadoUser = 1,
        DateDelete = NULL
    WHERE CodigoUser = @CodigoUser;

    SET @Mensaje = 'Usuario restaurado correctamente';
END;
GO
