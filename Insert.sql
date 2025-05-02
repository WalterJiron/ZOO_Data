USE ZOO;

GO

-- Insertar datos en la tabla Rol
INSERT INTO Rol (NombreRol, DescripRol)
VALUES ('Administrador', 'Tiene acceso completo al sistema'),
('Usuario', 'Es un usuario normal');

GO

/* -- Insertar datos en la tabla Users (con contraseñas encriptadas)
INSERT INTO Users (NameUser, Email, Clave, Rol)
VALUES (
    'Admin Principal', 'admin@zoo.com', 
    HASHBYTES('SHA2_256', 'Admin123'),   -- Clave encriptad
    (SELECT CodigoRol FROM Rol WHERE NombreRol = 'Administrador')
),
(
    'Carlos Mendez', 'carlos@zoo.com', 
    HASHBYTES('SHA2_256', 'Carlos123'), 
    (SELECT CodigoRol FROM Rol WHERE NombreRol = 'Administrador')
);*/

DECLARE @Mensaje NVARCHAR(100), @Rol UNIQUEIDENTIFIER;
SELECT @Rol = CodigoRol FROM Rol WHERE NombreRol = 'Administrador';
EXEC ProcInsertUser
    @NameUser = 'Walter Jiron',
    @Email = 'Walter@zoo.com',
    @Clave = 'Walter.01',
    @Rol = @Rol,
    @Mensaje = @Mensaje OUTPUT;
SELECT @Mensaje AS message;

GO

-- 3. Tabla Zona
INSERT INTO Zona (NameZona, Extension, EstadoZona) VALUES
('Zona Africana', 5000.50, 1),
('Zona Asiatica', 4500.75, 1),
('Zona Australiana', 3000.25, 1),
('Zona Americana', 4000.00, 1),
('Zona Europea', 2500.30, 1),
('Zona Antarica', 2000.00, 1),
('Zona Infantil', 1000.00, 1),
('Zona de Aviario', 3500.00, 1);

GO

-- 4. Tabla Especie
INSERT INTO Especie (Nombre, NameCientifico, Descripcion, Estado) VALUES
('Leon', 'Panthera leo', 'Gran felino carnivoro de la sabana africana', 1),
('Tigre de Bengala', 'Panthera tigris tigris', 'El mayor felino asiatico con rayas caracteristicas', 1),
('Canguro Rojo', 'Macropus rufus', 'Marsupial australiano con bolsa para sus crias', 1),
('Oso Pardo', 'Ursus arctos', 'Gran oso de habitos solitarios de zonas boscosas', 1),
('Pinguino Emperador', 'Aptenodytes forsteri', 'El mas grande de los pinguinos, habita en la Antartida', 1),
('Aguila Real', 'Aquila chrysaetos', 'Gran ave rapaz de amplia distribucion', 1),
('Jirafa', 'Giraffa camelopardalis', 'Mamifero mas alto del mundo con cuello largo', 1),
('Elefante Africano', 'Loxodonta africana', 'El mayor mamifero terrestre actual', 1);

GO

-- 5. Tabla Continente
INSERT INTO Continente (Nombre) VALUES
('Africa'),
('America'),
('Asia'),
('Europa'),
('Oceania'),
('Antartida');

GO

-- 6. Tabla Habitat
INSERT INTO Habitat (Nombre, Clima, DescripHabitat, CodigoZona, EstadoHabitat) VALUES
('Sabana Africana', 'Tropical', 'Extensas llanuras con pastizales y arbustos dispersos', (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Africana'), 1),
('Selva Asiatica', 'Lluvioso tropical', 'Densa vegetacion con alta humedad y biodiversidad', (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Asiatica'), 1),
('Bosque Australiano', 'Templado', 'Areas boscosas con eucaliptos caracteristicos', (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Australiana'), 1),
('Montanas Rocosas', 'Templado frio', 'Zonas montanosas con bosques de coniferas', (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Americana'), 1),
('Tundra Artica', 'Polar', 'Llanuras sin arboles con subsuelo helado', (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Europea'), 1),
('Banquisa Antarica', 'Polar extremo', 'Plataformas de hielo flotante', (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Antarica'), 1),
('Aviario Tropical', 'Tropical humedo', 'Estructura cubierta que simula un bosque lluvioso para aves', (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona de Aviario'), 1),
('Granja Infantil', 'Templado', 'Area interactiva con animales domesticos', (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Infantil'), 1);

GO

-- 7. Tabla Itinerario
INSERT INTO Itinerario (Duracion, Longitud, MaxVisitantes, NumEspecies, Fecha, Hora, Estado) VALUES
('01:30:00', 2.5, 20, 5, '2023-06-15', '09:00:00', 1),
('02:00:00', 3.0, 25, 7, '2023-06-15', '11:00:00', 1),
('01:00:00', 1.5, 15, 3, '2023-06-16', '10:00:00', 1),
('01:45:00', 2.8, 18, 6, '2023-06-16', '14:00:00', 1),
('02:30:00', 3.5, 30, 8, '2023-06-17', '10:30:00', 1);

GO

-- 8. Tabla Cargo
INSERT INTO Cargo (NombreCargo, DescripCargo, EstadoCargo) VALUES
('Guia Principal', 'Encargado de realizar los recorridos principales', 1),
('Guia Auxiliar', 'Asistente en los recorridos con visitantes', 1),
('Cuidador Senior', 'Experto en cuidado de animales', 1),
('Cuidador Junior', 'Asistente en el cuidado de animales', 1),
('Veterinario Jefe', 'Responsable de la salud de todos los animales', 1),
('Veterinario Asistente', 'Ayudante del veterinario jefe', 1),
('Jefe de Mantenimiento', 'Supervisa el mantenimiento de instalaciones', 1),
('Tecnico de Mantenimiento', 'Realiza labores de mantenimiento', 1);

GO

-- 9. Tabla Empleado
INSERT INTO Empleado (PNE, SNE, PAE, SAE, DireccionE, TelefonoE, EmailE, FechaIngreso, IdCargo, EstadoEmpleado) VALUES
('Ana', 'Maria', 'Garcia', 'Lopez', 'Calle Principal 123, Managua', '22556677', 'ana.garcia@zoo.com', '2020-01-15', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Guia Principal'), 1),
('Jose', 'Antonio', 'Martinez', 'Perez', 'Avenida Central 456, Managua', '22778899', 'jose.martinez@zoo.com', '2021-03-10', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Guia Auxiliar'), 1),
('Pedro', NULL, 'Sanchez', 'Gomez', 'Barrio Norte 789, Managua', '22334455', 'pedro.sanchez@zoo.com', '2019-05-20', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Cuidador Senior'), 1),
('Luisa', 'Fernanda', 'Hernandez', NULL, 'Colonia Sur 321, Managua', '22445566', 'luisa.hernandez@zoo.com', '2022-02-18', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Cuidador Junior'), 1),
('Dr. Roberto', NULL, 'Diaz', 'Castillo', 'Residencial Los Robles 654, Managua', '22889900', 'roberto.diaz@zoo.com', '2018-07-05', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Veterinario Jefe'), 1),
('Dra. Sofia', 'Isabel', 'Ramirez', 'Vargas', 'Reparto San Juan 987, Managua', '22667788', 'sofia.ramirez@zoo.com', '2021-09-12', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Veterinario Asistente'), 1),
('Mario', 'Alberto', 'Torres', 'Mejia', 'Sector Este 147, Managua', '22558899', 'mario.torres@zoo.com', '2020-11-30', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Jefe de Mantenimiento'), 1),
('Carlos', 'Enrique', 'Flores', NULL, 'Barrio Oeste 258, Managua', '22775544', 'carlos.flores@zoo.com', '2022-04-22', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Tecnico de Mantenimiento'), 1);

GO

-- 10. Tabla DetalleEmpleado
INSERT INTO DetalleEmpleado (CodigEmpleado, Cedula, FechaNacimiento, Genero, EstadoCivil, INSS, TelefonoEmergencia, EstadoDetalleEmpleado) VALUES
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'ana.garcia@zoo.com'), '001-280586-0001X', '1985-08-28', 'F', 'Casado', '012345678', '88889999', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'jose.martinez@zoo.com'), '002-150392-0002X', '1992-03-15', 'M', 'Soltero', '023456789', '77776666', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'pedro.sanchez@zoo.com'), '003-201087-0003X', '1987-10-20', 'M', 'Union Libre', '034567890', '86665555', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'luisa.hernandez@zoo.com'), '004-050595-0004X', '1995-05-05', 'F', 'Soltero', '045678901', '85554444', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'roberto.diaz@zoo.com'), '005-121080-0005X', '1980-12-12', 'M', 'Casado', '056789012', '84443333', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'sofia.ramirez@zoo.com'), '006-220890-0006X', '1990-08-22', 'F', 'Divorciado', '067890123', '83332222', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'mario.torres@zoo.com'), '007-100385-0007X', '1985-03-10', 'M', 'Casado', '078901234', '82221111', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'carlos.flores@zoo.com'), '008-170797-0008X', '1997-07-17', 'M', 'Soltero', '089012345', '81110000', 1);

GO

-- 11. Tabla HabitatContinente
INSERT INTO HabitatContinente (Habitat, Cont, EstadoHC) VALUES
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Sabana Africana'), (SELECT IdCont FROM Continente WHERE Nombre = 'Africa'), 1),
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Selva Asiatica'), (SELECT IdCont FROM Continente WHERE Nombre = 'Asia'), 1),
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Bosque Australiano'), (SELECT IdCont FROM Continente WHERE Nombre = 'Oceania'), 1),
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Montanas Rocosas'), (SELECT IdCont FROM Continente WHERE Nombre = 'America'), 1),
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Tundra Artica'), (SELECT IdCont FROM Continente WHERE Nombre = 'Europa'), 1),
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Banquisa Antarica'), (SELECT IdCont FROM Continente WHERE Nombre = 'Antartida'), 1),
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Aviario Tropical'), (SELECT IdCont FROM Continente WHERE Nombre = 'America'), 1),
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Aviario Tropical'), (SELECT IdCont FROM Continente WHERE Nombre = 'Asia'), 1),
((SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Aviario Tropical'), (SELECT IdCont FROM Continente WHERE Nombre = 'Africa'), 1);

GO

-- 12. Tabla EspecieHabitat
INSERT INTO EspecieHabitat (Especie, Habitat, EstadoEH) VALUES
((SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Leon'), (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Sabana Africana'), 1),
((SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Tigre de Bengala'), (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Selva Asiatica'), 1),
((SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Canguro Rojo'), (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Bosque Australiano'), 1),
((SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Oso Pardo'), (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Montanas Rocosas'), 1),
((SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Pinguino Emperador'), (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Banquisa Antarica'), 1),
((SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Aguila Real'), (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Aviario Tropical'), 1),
((SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Jirafa'), (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Sabana Africana'), 1),
((SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Elefante Africano'), (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Sabana Africana'), 1);

GO

-- 13. Tabla ItinerarioZona
INSERT INTO ItinerarioZona (Itinerario, Zona, EstadoItZo) VALUES
((SELECT CodigoIti FROM Itinerario WHERE Duracion = '01:30:00'), (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Africana'), 1),
((SELECT CodigoIti FROM Itinerario WHERE Duracion = '01:30:00'), (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Asiatica'), 1),
((SELECT CodigoIti FROM Itinerario WHERE Duracion = '02:00:00'), (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Australiana'), 1),
((SELECT CodigoIti FROM Itinerario WHERE Duracion = '02:00:00'), (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Americana'), 1),
((SELECT CodigoIti FROM Itinerario WHERE Duracion = '01:00:00'), (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Antarica'), 1),
((SELECT CodigoIti FROM Itinerario WHERE Duracion = '01:45:00'), (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona de Aviario'), 1),
((SELECT CodigoIti FROM Itinerario WHERE Duracion = '02:30:00'), (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Infantil'), 1);

GO

-- 14. Tabla GuiaItinerario
INSERT INTO GuiaItinerario (Empleado, Itinerario, EstadoGI) VALUES
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'ana.garcia@zoo.com'), (SELECT CodigoIti FROM Itinerario WHERE Duracion = '01:30:00'), 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'jose.martinez@zoo.com'), (SELECT CodigoIti FROM Itinerario WHERE Duracion = '02:00:00'), 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'ana.garcia@zoo.com'), (SELECT CodigoIti FROM Itinerario WHERE Duracion = '01:45:00'), 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'jose.martinez@zoo.com'), (SELECT CodigoIti FROM Itinerario WHERE Duracion = '02:30:00'), 1);

GO

-- 15. Tabla CuidadorEspecie
INSERT INTO CuidadorEspecie (IdEmpleado, IdEspecie, FechaAsignacion, EstadoCE) VALUES
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'pedro.sanchez@zoo.com'), (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Leon'), '2022-01-10', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'luisa.hernandez@zoo.com'), (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Tigre de Bengala'), '2022-03-15', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'pedro.sanchez@zoo.com'), (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Elefante Africano'), '2021-11-20', 1),
((SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'luisa.hernandez@zoo.com'), (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Canguro Rojo'), '2022-05-05', 1);
