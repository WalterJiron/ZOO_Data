USE ZOO

GO
--------------------------INSERCCION GUIAITINERARIO---------------------------
CREATE PROC INSERTAR_GUIAITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Verificar que los parametros no sean nulos
    IF @IdEmpleado IS NULL OR @IdItinerario IS NULL
    BEGIN
        SET @MENSAJE = 'No pueden haber parametros nulos';
        RETURN;
    END

    -- Verificar si existe el empleado
    IF NOT EXISTS(SELECT 1 FROM Empleado WHERE CodigEmpleado = @IdEmpleado)
    BEGIN
        SET @MENSAJE = 'El empleado no existe';
        RETURN;
    END

    -- Verificar si existe el itinerario
    IF NOT EXISTS(SELECT 1 FROM Itinerario WHERE CodigoIti = @IdItinerario)
    BEGIN
        SET @MENSAJE = 'El itinerario no existe';
        RETURN;
    END

    -- Verificar si la relacion ya existe
    IF EXISTS(SELECT 1 FROM GuiaItinerario WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario)
    BEGIN
        SET @MENSAJE = 'La relacion ya existe';
        RETURN;
    END

    -- Insertar la relacion
    INSERT INTO GuiaItinerario (Empleado, Itinerario, EstadoGI)
    VALUES (@IdEmpleado, @IdItinerario, 1);

    SET @MENSAJE = 'Inserci�n realizada correctamente';
END


GO


-----------------ELIMINAR GUIAITINERARIO--------------------------
CREATE PROC ELIMINAR_GUIAITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Verificar si la relacion existe
    IF NOT EXISTS(SELECT 1 FROM GuiaItinerario WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario)
    BEGIN
        SET @MENSAJE = 'La relacion entre empleado e itinerario no existe';
        RETURN;
    END

    -- Verificar si ya esta inactivo
    IF EXISTS(SELECT 1 FROM GuiaItinerario WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario AND EstadoGI = 0)
    BEGIN
        SET @MENSAJE = 'La relacion ya esta inactiva';
        RETURN;
    END

    -- Desactivar la relacion
    UPDATE GuiaItinerario 
    SET EstadoGI = 0
    WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario;

    SET @MENSAJE = 'Desactivada correctamente';
END

GO

------------------------------------ACTIVAR GUIITINERARIO----------------------------
CREATE PROC ACTIVAR_GUIAITINERARIO
@IdEmpleado UNIQUEIDENTIFIER,
@IdItinerario UNIQUEIDENTIFIER,
@MENSAJE VARCHAR(100) OUTPUT
AS
BEGIN
    -- Verificar si la relacion existe
    IF NOT EXISTS(SELECT 1 FROM GuiaItinerario WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario)
    BEGIN
        SET @MENSAJE = 'La relacion entre empleado e itinerario no existe';
        RETURN;
    END

    -- Verificar si ya esta activo
    IF EXISTS(SELECT 1 FROM GuiaItinerario WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario AND EstadoGI = 1)
    BEGIN
        SET @MENSAJE = 'La relacion ya esta activa';
        RETURN;
    END

    -- Desactivar la relacion
    UPDATE GuiaItinerario 
    SET EstadoGI = 1
    WHERE Empleado = @IdEmpleado AND Itinerario = @IdItinerario;

    SET @MENSAJE = 'Desactivada correctamente';
END
