CREATE DATABASE ZOO;

GO

USE ZOO;

GO

-- Tabla de Roles       
CREATE TABLE Rol(   --- El sistema solo nos habla del rol Admin 
    CodigoRol UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    NombreRol NVARCHAR(50) UNIQUE NOT NULL,
    DescripRol NVARCHAR(MAX) NOT NULL,
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,   -- Para ver la ultima vez que se actualizo
    DateDelete DATETIMEOFFSET,   -- Para mantener un registro de cuando se elimino
    EstadoRol BIT DEFAULT 1
);

GO

-- Tabla de Usuarios         
CREATE TABLE Users(
    CodigoUser UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    NameUser NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Clave VARBINARY(300) NOT NULL,   -- Para encriptar con HASHBYTES(SHA2_256, clave)
    Rol UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Rol(CodigoRol) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,   
    DateDelete DATETIME,
    EstadoUser BIT DEFAULT 1
); 

GO

-- Tabla control de login (Tabla de Auditoria)
CREATE TABLE Login(
    CodigoLogin UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    DateLogin DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
);

GO

-- Tabla de Zonas       
CREATE TABLE Zona (
    CodigoZona UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    NameZona NVARCHAR(100) NOT NULL,
    Extension DECIMAL(10,2) NOT NULL,
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,
    DateDelete DATETIME,
    EstadoZona BIT DEFAULT 1
);

GO

-- Tabla de Especies      
CREATE TABLE Especie (
    CodigoEspecie UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    NameCientifico NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(MAX) NOT NULL,
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,
    DateDelete DATETIMEOFFSET,
    Estado BIT DEFAULT 1
);

GO

-- Tabla de Continentes       
CREATE TABLE Continente (
    IdCont INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    Nombre NVARCHAR(50) NOT NULL
);

GO

-- Tabla de Hábitats  
CREATE TABLE Habitat (
    CodigoHabitat UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Clima VARCHAR(100) NOT NULL,
    DescripHabitat VARCHAR(MAX) NOT NULL,   -- La decripcion del habitat   
    CodigoZona UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Zona(CodigoZona) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,
    DateDelete DATETIMEOFFSET,
    EstadoHabitat BIT DEFAULT 1
);

GO

-- Tabla de Itinerarios   
CREATE TABLE Itinerario (
    CodigoIti UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    Duracion TIME CHECK(Duracion > CAST('00:00:00' AS TIME)) NOT NULL,
    Longitud DECIMAL(10,2) CHECK(Longitud > 0) NOT NULL,
    MaxVisitantes INT CHECK(MaxVisitantes > 0) NOT NULL,
    NumEspecies INT CHECK(NumEspecies > 0) NOT NULL,
    Fecha DATE NOT NULL,                --- La fecha en la que se realizara el itinerario
    Hora TIME NOT NULL CHECK(Hora > CAST('00:00:00' AS TIME)),                 --- La hora en la que se inicia
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,
    DateDelete DATETIME,
    Estado BIT DEFAULT 1
);

GO

-- Tabla de Cargos       
CREATE TABLE Cargo(
    CodifoCargo UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    NombreCargo NVARCHAR(50) NOT NULL,
    DescripCargo NVARCHAR(MAX) NOT NULL,
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,
    DateDelete DATETIMEOFFSET,
    EstadoCargo BIT DEFAULT 1
);

GO

-- Tabla de Empleados     
CREATE TABLE Empleado(
    CodigEmpleado UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    PNE NVARCHAR(25) NOT NULL,   -- Primer Nombre Empleado
    SNE NVARCHAR(25),            -- Segundo Nombre Empleado
    PAE NVARCHAR(25) NOT NULL,   -- Primer Apellido Empleado
    SAE NVARCHAR(25),            -- Segundo Apellido Empleado
    DireccionE NVARCHAR(200) NOT NULL,
    TelefonoE VARCHAR(8) CHECK(TelefonoE LIKE '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') UNIQUE NOT NULL,
    EmailE NVARCHAR(100) UNIQUE NOT NULL,
    FechaIngreso DATE NOT NULL,  -- Fecha de ingreso del empleado
    IdCargo UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Cargo(CodifoCargo) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,  
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,
    DateDelete DATETIMEOFFSET,
    EstadoEmpleado BIT DEFAULT 1
);

GO

-- Tabla del detalle de los empleados 
CREATE TABLE DetalleEmpleado(
    CodigoDetEmpleado UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NOT NULL,
    CodigEmpleado UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Empleado(CodigEmpleado) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    Cedula NVARCHAR(16) CHECK(Cedula LIKE'[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][A-Z]') UNIQUE NOT NULL,
    FechaNacimiento DATE CHECK(FechaNacimiento <= CAST(DATEADD(YEAR, -18, GETDATE()) AS DATE)) NOT NULL,
    Genero CHAR(1) CHECK(Genero IN ('M', 'F', 'O')) NOT NULL,
    EstadoCivil NVARCHAR(20) CHECK(EstadoCivil IN ('Soltero', 'Casado', 'Divorciado', 'Viudo', 'Union Libre')) NOT NULL,  
    INSS NVARCHAR(9) CHECK(INSS LIKE'[0][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') UNIQUE NOT NULL,
    TelefonoEmergencia VARCHAR(8) CHECK(TelefonoEmergencia LIKE '[2|5|7|8][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') UNIQUE NOT NULL,
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateUpdate DATETIMEOFFSET,
    DateDelete DATETIMEOFFSET,
    EstadoDetalleEmpleado BIT DEFAULT 1
);

GO

------------------------------------------ Tablas de Relaciones ------------------------------------------

-- Relación entre Hábitats y Continentes (Muchos a Muchos) 
CREATE TABLE HabitatContinente (
    Habitat UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Habitat(CodigoHabitat) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    Cont INT FOREIGN KEY REFERENCES Continente(IdCont) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    PRIMARY KEY (Habitat, Cont),
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    EstadoHC BIT DEFAULT 1
);

GO

-- Relación entre Especies y Hábitats (Muchos a Muchos) 
CREATE TABLE EspecieHabitat (
    Especie UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Especie(CodigoEspecie) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    Habitat UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Habitat(CodigoHabitat) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    PRIMARY KEY (Especie, Habitat),
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    DateDelete DATETIMEOFFSET,
    EstadoEH BIT DEFAULT 1
);

GO

-- Relación entre Itinerarios y Zonas (Muchos a Muchos) 
CREATE TABLE ItinerarioZona (
    Itinerario UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Itinerario(CodigoIti) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    Zona UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Zona(CodigoZona) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    PRIMARY KEY (Itinerario, Zona),
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    EstadoItZo BIT DEFAULT 1
);

GO

-- Relación entre Guías e Itinerarios (Verificar que el empleado sea guía) Listo
CREATE TABLE GuiaItinerario (
    Empleado UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Empleado(CodigEmpleado) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,  
    Itinerario UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Itinerario(CodigoIti) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    PRIMARY KEY (Empleado, Itinerario),
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    EstadoGI BIT DEFAULT 1
);

GO

-- Relación entre Cuidadores y Especies (Verificar que el empleado sea cuidador) (SE REPARO)
CREATE TABLE CuidadorEspecie (
    IdEmpleado UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Empleado(CodigEmpleado) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    IdEspecie UNIQUEIDENTIFIER FOREIGN KEY REFERENCES Especie(CodigoEspecie) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
    FechaAsignacion DATE NOT NULL,
    PRIMARY KEY (IdEmpleado, IdEspecie),
    DateCreate DATETIMEOFFSET DEFAULT SYSDATETIMEOFFSET() AT TIME ZONE 'Central America Standard Time',
    EstadoCE BIT DEFAULT 1
);