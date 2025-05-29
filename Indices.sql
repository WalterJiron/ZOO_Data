USE ZOO;
GO

-- Indices para Tablas Principales
CREATE NONCLUSTERED INDEX IX_Users_Email ON Users(Email);
CREATE NONCLUSTERED INDEX IX_Users_Rol ON Users(Rol);
CREATE NONCLUSTERED INDEX IX_Login_Email ON Login(Email);
CREATE NONCLUSTERED INDEX IX_Login_DateLogin ON Login(DateLogin);
CREATE NONCLUSTERED INDEX IX_Empleado_Nombre ON Empleado(PAE, PNE);
CREATE NONCLUSTERED INDEX IX_Empleado_Cargo ON Empleado(IdCargo);
CREATE NONCLUSTERED INDEX IX_Empleado_TelefonoEmail ON Empleado(TelefonoE, EmailE);
CREATE NONCLUSTERED INDEX IX_DetalleEmpleado_Cedula ON DetalleEmpleado(Cedula);
CREATE NONCLUSTERED INDEX IX_DetalleEmpleado_INSS ON DetalleEmpleado(INSS);
CREATE NONCLUSTERED INDEX IX_Especie_Nombre ON Especie(Nombre);
CREATE NONCLUSTERED INDEX IX_Especie_NombreCientifico ON Especie(NameCientifico);
CREATE NONCLUSTERED INDEX IX_Zona_Nombre ON Zona(NameZona);
CREATE NONCLUSTERED INDEX IX_Habitat_Zona ON Habitat(CodigoZona);
CREATE NONCLUSTERED INDEX IX_Habitat_Nombre ON Habitat(Nombre);
CREATE NONCLUSTERED INDEX IX_Itinerario_FechaHora ON Itinerario(Fecha, Hora);

-- Indices para Tablas de Relacion
CREATE NONCLUSTERED INDEX IX_EspecieHabitat_Habitat ON EspecieHabitat(Habitat);
CREATE NONCLUSTERED INDEX IX_HabitatContinente_Cont ON HabitatContinente(Cont);
CREATE NONCLUSTERED INDEX IX_ItinerarioZona_Zona ON ItinerarioZona(Zona);
CREATE NONCLUSTERED INDEX IX_GuiaItinerario_Itinerario ON GuiaItinerario(Itinerario);
CREATE NONCLUSTERED INDEX IX_CuidadorEspecie_Especie ON CuidadorEspecie(IdEspecie);

-- Indices Filtrados para registros activos
CREATE NONCLUSTERED INDEX IX_Users_Activos ON Users(CodigoUser) WHERE EstadoUser = 1;
CREATE NONCLUSTERED INDEX IX_Empleado_Activos ON Empleado(CodigEmpleado) WHERE EstadoEmpleado = 1;
CREATE NONCLUSTERED INDEX IX_Especie_Activas ON Especie(CodigoEspecie) WHERE Estado = 1;
CREATE NONCLUSTERED INDEX IX_Habitat_Activos ON Habitat(CodigoHabitat) WHERE EstadoHabitat = 1;

-- Indices con columnas incluidas
CREATE NONCLUSTERED INDEX IX_Especie_Nombre_Incl ON Especie(Nombre) INCLUDE (NameCientifico, Estado);
CREATE NONCLUSTERED INDEX IX_Itinerario_FechaRango ON Itinerario(Fecha) INCLUDE (Hora, Duracion, MaxVisitantes);
CREATE NONCLUSTERED INDEX IX_Empleado_NombreCompleto ON Empleado(PNE, PAE) INCLUDE (SNE, SAE, EmailE, TelefonoE);


-- Indices para fechas de auditoria (frecuentes)
CREATE NONCLUSTERED INDEX IX_Auditoria_DateCreate ON Users(DateCreate);
CREATE NONCLUSTERED INDEX IX_Auditoria_DateCreate_Empleado ON Empleado(DateCreate);
CREATE NONCLUSTERED INDEX IX_Auditoria_DateCreate_Especie ON Especie(DateCreate);

-- Indices para relaciones frecuentes en JOINs
CREATE NONCLUSTERED INDEX IX_DetalleEmpleado_Empleado ON DetalleEmpleado(CodigEmpleado);
CREATE NONCLUSTERED INDEX IX_EspecieHabitat_Especie ON EspecieHabitat(Especie);
CREATE NONCLUSTERED INDEX IX_HabitatContinente_Habitat ON HabitatContinente(Habitat);
CREATE NONCLUSTERED INDEX IX_ItinerarioZona_Itinerario ON ItinerarioZona(Itinerario);
CREATE NONCLUSTERED INDEX IX_GuiaItinerario_Empleado ON GuiaItinerario(Empleado);
CREATE NONCLUSTERED INDEX IX_CuidadorEspecie_Empleado ON CuidadorEspecie(IdEmpleado);

-- Indices para consultas de mantenimiento
CREATE NONCLUSTERED INDEX IX_EstadoGeneral ON Users(EstadoUser) INCLUDE (CodigoUser, NameUser, Email);
CREATE NONCLUSTERED INDEX IX_EstadoGeneral_Empleado ON Empleado(EstadoEmpleado) INCLUDE (CodigEmpleado, PNE, PAE, EmailE);
GO

-- Para los paneles de ejecucion eficiente
EXEC sp_autostats 'Users', 'ON';
EXEC sp_autostats 'Empleado', 'ON';
EXEC sp_autostats 'DetalleEmpleado', 'ON';
EXEC sp_autostats 'Especie', 'ON';
EXEC sp_autostats 'Itinerario', 'ON';