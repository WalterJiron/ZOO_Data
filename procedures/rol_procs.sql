---ROL PROC------------

----------------- Agregar un rol ----------------------
CREATE PROC ProcInsertRol  
    @NombreRol VARCHAR(50),  
    @Descripcion VARCHAR(MAX), 
    @Mensaje VARCHAR(100) OUTPUT  
AS  
BEGIN  

    IF @NombreRol IS NULL OR @Descripcion IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacios';
        RETURN;
    END

    IF LEN(@NombreRol) < 2
    BEGIN
        SET @Mensaje = 'El nombre del rol debe tener al menos 2 caracteres';
        RETURN;
    END

    DECLARE @name_exis AS VARCHAR(50);
    SET @name_exis = (SELECT NombreRol FROM Rol WHERE NombreRol = @NombreRol);

    IF @name_exis IS NOT NULL
    BEGIN
        SET @Mensaje = 'El nombre del rol ya existe en la base de datos';
        RETURN;
    END

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

------------Actalizar rol ----------------------------------
CREATE PROC ProcUpdateRol  
    @CodigoRol UNIQUEIDENTIFIER,
    @NombreRol NVARCHAR(50),  
    @Descripcion NVARCHAR(MAX), 
    @Mensaje VARCHAR(100) OUTPUT  
AS  
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Rol WHERE CodigoRol = @CodigoRol AND EstadoRol = 1)
    BEGIN
        SET @Mensaje = 'El rol no existe o está eliminado';
        RETURN;
    END

    IF @NombreRol IS NULL OR @Descripcion IS NULL
    BEGIN
        SET @Mensaje = 'Los campos no pueden estar vacíos';
        RETURN;
    END

    IF LEN(@NombreRol) < 2
    BEGIN
        SET @Mensaje = 'El nombre del rol debe tener al menos 2 caracteres';
        RETURN;
    END

    IF LEN(@Descripcion) < 5
    BEGIN
        SET @Mensaje = 'La descripción debe tener al menos 5 caracteres';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Rol WHERE NombreRol = @NombreRol AND CodigoRol <> @CodigoRol)
    BEGIN
        SET @Mensaje = 'El nombre del rol ya está en uso por otro rol';
        RETURN;
    END

    UPDATE Rol
    SET NombreRol = @NombreRol,
        DescripRol = @Descripcion
    WHERE CodigoRol = @CodigoRol;

    SET @Mensaje = 'Rol actualizado correctamente';
END;
GO

----------------------------- Delete Rol ------------------------------
CREATE PROC ProcDeleteRol  
    @CodigoRol UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT  
AS  
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Rol WHERE CodigoRol = @CodigoRol AND EstadoRol = 1)
    BEGIN
        SET @Mensaje = 'El rol no existe o ya fue eliminado';
        RETURN;
    END

    UPDATE Rol
    SET EstadoRol = 0,
        DateDelete = GETDATE()
    WHERE CodigoRol = @CodigoRol;

    SET @Mensaje = 'Rol eliminado lógicamente';
END;
GO


------------------- Recuperar rol -----------------
CREATE PROC ProcRestoreRol  
    @CodigoRol UNIQUEIDENTIFIER,
    @Mensaje VARCHAR(100) OUTPUT  
AS  
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Rol WHERE CodigoRol = @CodigoRol AND EstadoRol = 0)
    BEGIN
        SET @Mensaje = 'El rol no existe o ya está activo';
        RETURN;
    END

    UPDATE Rol
    SET EstadoRol = 1,
        DateDelete = NULL
    WHERE CodigoRol = @CodigoRol;

    SET @Mensaje = 'Rol restaurado correctamente';
END;
GO