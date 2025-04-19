USE ZOO;

GO

-- Insertar datos en la tabla Rol
INSERT INTO Rol (NombreRol, DescripRol)
VALUES ('Administrador', 'Tiene acceso completo al sistema'),
('Usuario', 'Es un usuario normal');

GO

-- Insertar datos en la tabla Users (con contraseñas encriptadas)
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
);

GO

-- Insertar datos en la tabla Continente
INSERT INTO Continente (Nombre)
VALUES ('Africa'), ('America'), ('Asia'), ('Europa'), ('Oceania'), ('Antartida');

GO

-- Insertar datos en la tabla Zona
INSERT INTO Zona (NameZona, Extension)
VALUES ('Sabana Africana', 5000.50), ('Selva Tropical', 3500.75), ('Desierto', 2000.25),
('Bosque Templado', 1800.00),
('Zona Polar', 2500.00),
('Aviario', 1200.50),
('Reptilario', 800.25);

GO

-- Insertar datos en la tabla Habitat
INSERT INTO Habitat (Nombre, Clima, DescripHabitat, CodigoZona)
VALUES (
    'Sabana', 'Calido y seco', 
    'Extensas llanuras con vegetacion dispersa y arboles resistentes a la sequia', 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Sabana Africana')
),
(
    'Selva Amazonica', 'Calido y humedo', 
    'Vegetacion densa con alta biodiversidad y precipitaciones frecuentes', 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Selva Tropical')
),
(
    'Desierto del Sahara', 'Arido', 
    'Extension de arena con temperaturas extremas y poca vegetacion', 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Desierto')
),
(
    'Bosque Europeo', 'Templado', 
    'Arboles caducifolios y coniferas con estaciones marcadas', 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Bosque Templado')
),
(
    'Artico', 'Polar', 
    'Temperaturas bajo cero con nieve y hielo la mayor parte del ano', 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Polar')
);

GO

-- Insertar datos en la tabla HabitatContinente
INSERT INTO HabitatContinente (Habitat, Cont)
VALUES (
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Sabana'), 
    (SELECT IdCont FROM Continente WHERE Nombre = 'Africa')
),
(
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Selva Amazonica'), 
    (SELECT IdCont FROM Continente WHERE Nombre = 'America')
),
(
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Desierto del Sahara'), 
    (SELECT IdCont FROM Continente WHERE Nombre = 'Africa')
),
(
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Bosque Europeo'), 
    (SELECT IdCont FROM Continente WHERE Nombre = 'Europa')
),
(
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Artico'), 
    (SELECT IdCont FROM Continente WHERE Nombre = 'Antartida')
);

GO

-- Insertar datos en la tabla Especie
INSERT INTO Especie (Nombre, NameCientifico, Descripcion)
VALUES ('Leon', 'Panthera leo', 'Gran felino carnivoro que vive en manadas en la sabana africana'),
('Tigre de Bengala', 'Panthera tigris tigris', 'El mayor felino del mundo, originario del subcontinente indio'),
('Elefante Africano', 'Loxodonta africana', 'El mayor mamifero terrestre, con grandes orejas y colmillos'),
('Pinguino Emperador', 'Aptenodytes forsteri', 'Pinguino mas grande, adaptado a las duras condiciones antarticas'),
('Cocodrilo del Nilo', 'Crocodylus niloticus', 'Gran reptil depredador que habita en rios africanos'),
('Aguila Real', 'Aquila chrysaetos', 'Una de las aves de presa mas conocidas y ampliamente distribuidas');

GO

-- Insertar datos en la tabla EspecieHabitat
INSERT INTO EspecieHabitat (Especie, Habitat)
VALUES (
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Leon'), 
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Sabana')
),
(
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Tigre de Bengala'), 
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Selva Amazonica')
),
(
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Elefante Africano'), 
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Sabana')
),
(
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Pinguino Emperador'), 
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Artico')
),
(
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Cocodrilo del Nilo'), 
    (SELECT CodigoHabitat FROM Habitat WHERE Nombre = 'Sabana')
);

GO

-- Insertar datos en la tabla Cargo
INSERT INTO Cargo (NombreCargo, DescripCargo)
VALUES ('Director', 'Responsable maximo del zoologico'), ('Veterinario', 'Encargado de la salud de los animales'),
('Guia', 'Encargado de realizar recorridos y explicar las exhibiciones'),
('Cuidador', 'Responsable del cuidado y alimentacion de los animales'),
('Mantenimiento', 'Responsable del mantenimiento de las instalaciones'),
('Recepcionista', 'Atencion al publico y venta de entradas');

GO

-- Insertar datos en la tabla Empleado
INSERT INTO Empleado (PNE, SNE, PAE, SAE, DireccionE, TelefonoE, EmailE, FechaIngreso, IdCargo)
VALUES (
    'Juan', 'Carlos', 'Perez', 'Gomez', 'Calle Principal 123, Ciudad', '22223333', 
    'juan.perez@zoo.com', '2020-01-15', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Director')
),
(
    'Maria', 'Isabel', 'Lopez', 'Martinez', 'Avenida Central 456, Ciudad', '25556666', 
    'maria.lopez@zoo.com', '2021-03-10', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Guia')
),
(
    'Carlos', NULL, 'Mendez', 'Rodriguez', 'Boulevard Norte 789, Ciudad', '27778888', 
    'carlos.mendez@zoo.com', '2019-05-20', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Cuidador')
),
(
    'Laura', 'Patricia', 'Jimenez', NULL, 'Calle Sur 101, Ciudad', '28889999', 
    'laura.jimenez@zoo.com', '2022-02-01', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Veterinario')
),
(
    'Pedro', 'Antonio', 'Garcia', 'Hernandez', 'Avenida Este 202, Ciudad', '24445555', 
    'pedro.garcia@zoo.com', '2021-11-15', (SELECT CodifoCargo FROM Cargo WHERE NombreCargo = 'Mantenimiento')
);

GO

-- Insertar datos en la tabla Itinerario
INSERT INTO Itinerario (Duracion, Longitud, MaxVisitantes, NumEspecies, Fecha, Hora)
VALUES ('01:30:00', 2.5, 20, 5, '2023-06-15', '09:00:00'),('02:00:00', 3.0, 15, 7, '2023-06-15', '11:00:00'),
('01:00:00', 1.5, 25, 3, '2023-06-16', '10:00:00'), ('01:45:00', 2.8, 18, 6, '2023-06-16', '14:00:00');

GO

-- Insertar datos en la tabla ItinerarioZona
INSERT INTO ItinerarioZona (Itinerario, Zona)
VALUES (
    (SELECT CodigoIti FROM Itinerario WHERE Fecha = '2023-06-15' AND Hora = '09:00:00'), 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Sabana Africana')
),
(
    (SELECT CodigoIti FROM Itinerario WHERE Fecha = '2023-06-15' AND Hora = '11:00:00'), 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Selva Tropical')
),
(
    (SELECT CodigoIti FROM Itinerario WHERE Fecha = '2023-06-16' AND Hora = '10:00:00'), 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Zona Polar')
),
(
    (SELECT CodigoIti FROM Itinerario WHERE Fecha = '2023-06-16' AND Hora = '14:00:00'), 
    (SELECT CodigoZona FROM Zona WHERE NameZona = 'Bosque Templado')
);

GO

-- Insertar datos en la tabla GuiaItinerario
INSERT INTO GuiaItinerario (Empleado, Itinerario)
VALUES (
    (SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'maria.lopez@zoo.com'), 
    (SELECT CodigoIti FROM Itinerario WHERE Fecha = '2023-06-15' AND Hora = '09:00:00')
),
(
    (SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'maria.lopez@zoo.com'), 
    (SELECT CodigoIti FROM Itinerario WHERE Fecha = '2023-06-15' AND Hora = '11:00:00')
),
(
    (SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'juan.perez@zoo.com'), 
    (SELECT CodigoIti FROM Itinerario WHERE Fecha = '2023-06-16' AND Hora = '10:00:00')
);

GO

-- Insertar datos en la tabla CuidadorEspecie
INSERT INTO CuidadorEspecie (IdEmpleado, IdEspecie, FechaAsignacion)
VALUES (
    (SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'carlos.mendez@zoo.com'), 
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Leon'), '2023-01-10'
),
(
    (SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'carlos.mendez@zoo.com'), 
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Elefante Africano'), '2023-01-15'
),
(
    (SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'laura.jimenez@zoo.com'), 
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Pinguino Emperador'), '2023-02-01'
),
(
    (SELECT CodigEmpleado FROM Empleado WHERE EmailE = 'laura.jimenez@zoo.com'), 
    (SELECT CodigoEspecie FROM Especie WHERE Nombre = 'Tigre de Bengala'), '2023-02-05'
);
