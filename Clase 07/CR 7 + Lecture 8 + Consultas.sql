-- HW 7 M3 FT 19

/*
COMPLETAR EL FORMULARIO DE FEEDBACK PARA HENRY
https://airtable.com/apphxqCmZrRKZawNL/shrRbVwOfluNnbHi4
*/

USE henry_m3;

SELECT * FROM venta;
SELECT * FROM sucursal;

SELECT p.Provincia, l.Localidad, SUM(v.Precio*v.Cantidad) 'Total Ventas'
FROM venta v JOIN sucursal s 
				ON (s.IdSucursal = v.IdSucursal) 
			 JOIN localidad l 
				ON (l.IdLocalidad = s.IdLocalidad) 
			JOIN provincia p 
				ON (p.IdProvincia = l.IdProvincia) 
WHERE v.Outlier = 0 
-- AND YEAR(v.Fecha) IN (2019,2020)
GROUP BY 1, 2
ORDER BY 1, 2;
-- Tiempo = 0.219 s
-- Tiempo2 = 0.265 s


SELECT
    precio AS mediana
FROM
    (    SELECT -- Una subconsulta con select
        precio, -- llamo a precio
        ROW_NUMBER() OVER (ORDER BY precio) AS row_num, -- Columna de numeros de 1 a la ultima(funcion ventana con ordenamiento)
        COUNT(*) OVER () AS total_rows -- contabilizo todas los registros
    FROM 
        venta ) b
WHERE
    row_num BETWEEN (total_rows + 1) / 2 AND (total_rows + 2) / 2;

-- tiempo = 0.219 s
-- Tiempo2 = 0.188 s

SELECT venta.SumaVenta - compra.SumaCompras, venta.producto
FROM (SELECT p.Concepto as Producto, SUM(v.Precio * v.Cantidad) AS SumaVenta
	FROM venta v JOIN producto p 
				ON (v.IdProducto = p.IdProducto) 
	WHERE v.Outlier = 0
	GROUP BY 1) AS Venta
JOIN
	(SELECT p.Concepto as Producto, SUM(c.Precio * c.Cantidad) AS SumaCompras
    FROM compra c JOIN producto p
					 ON (p.IdProducto = c.IdProducto)
	GROUP BY 1) compra
	ON (compra.Producto = venta.Producto) 

ORDER BY 1 DESC;
-- Tiempo = 0.422 s
-- Tiempo2 = 0.437 s

SELECT c.IdProveedor AS Proveedor, p.Nombre AS Nombre, c.IdProducto Producto, pr.Concepto, nombre_y_apellido AS 'Nombre y apellido', v.cantidad, v.precio
					
FROM compra c JOIN proveedor p
			  ON(c.IdProveedor = p. IdProveedor)
              JOIN producto pr
              ON(c.IdProducto = pr.IdProducto)
              JOIN Venta v
              ON( pr.IdProducto = v.IdProducto)
              JOIN Cliente cl
              ON(v.IdCliente = cl.IdCliente)
;
-- Tiempo = 2.140 s 
-- Tiempo2 = 0.094 s

-- 2) Valor unico, no nulo y que por cada fila se identifique con solamente un valor de este campo
 
SELECT * FROM venta; -- IdVenta

ALTER TABLE venta ADD PRIMARY KEY(IdVenta);

SELECT * FROM compra; -- IdCompra

ALTER TABLE compra ADD PRIMARY KEY(IdCompra);

SELECT * FROM gasto;  -- IdGasto

ALTER TABLE gasto ADD PRIMARY KEY(IdGasto);

SELECT * FROM sucursal; -- IdSucursal

ALTER TABLE sucursal ADD PRIMARY KEY(IdSucursal);

SELECT * FROM cliente; -- IdCliente

ALTER TABLE cliente ADD PRIMARY KEY(IdCliente);

SELECT * FROM proveedor; -- IdProveedor 

ALTER TABLE proveedor ADD PRIMARY KEY(IdProveedor);

SELECT * FROM canal_venta;

ALTER TABLE canal_venta ADD PRIMARY KEY(IdCanal);

SELECT * FROM tipo_Gasto;

ALTER TABLE tipo_gasto ADD PRIMARY KEY(IdTipoGasto);

SELECT * FROM producto;

ALTER TABLE producto ADD PRIMARY KEY(IdProducto);

SELECT * FROM empleado; -- IdEmpleado

ALTER TABLE empleado ADD PRIMARY KEY(IdEmpleado);

-- 3)

SELECT * FROM venta; -- Fecha Fecha_Entrega IdCanal IdCliente IdSucursal IdEmpleado IdProducto

ALTER TABLE venta ADD INDEX(Fecha_Entrega);

ALTER TABLE venta ADD INDEX(IdCanal);

ALTER TABLE venta ADD FOREIGN KEY(IdCanal) REFERENCES canal_venta(IdCanal);

ALTER TABLE venta ADD INDEX(IdCliente);
ALTER TABLE venta ADD FOREIGN KEY(IdCliente) REFERENCES cliente(IdCliente);

ALTER TABLE venta ADD INDEX(IdSucursal);
ALTER TABLE venta ADD FOREIGN KEY(IdSucursal) REFERENCES sucursal(IdSucursal);

ALTER TABLE venta ADD INDEX(IdEmpleado);
ALTER TABLE venta ADD FOREIGN KEY(IdEmpleado) REFERENCES empleado(IdEmpleado);

ALTER TABLE venta ADD INDEX(IdProducto);
ALTER TABLE venta ADD FOREIGN KEY(IdProducto) REFERENCES producto(IdProducto);


SELECT * FROM producto; -- IdTipoProducto

ALTER TABLE producto ADD INDEX(IdTipoProducto);

ALTER TABLE producto ADD FOREIGN KEY(IdTipoProducto) REFERENCES tipo_producto(IdTipoProducto);

SELECT * FROM tipo_producto;

SELECT * FROM sucursal; --  IdLocalidad

ALTER TABLE sucursal ADD CONSTRAINT sucursal_fk_localidad FOREIGN KEY(IdLocalidad) REFERENCES localidad(IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;

-- Esta query tambien añade claves foraneas

SELECT * FROM empleado; -- IdSucursal IdSector IdCargo

ALTER TABLE empleado ADD FOREIGN KEY(IdSucursal) REFERENCES sucursal(IdSucursal);
ALTER TABLE empleado ADD CONSTRAINT empleado_fk_cargo FOREIGN KEY(IdCargo) REFERENCES cargo(IdCargo) ON DELETE RESTRICT ON UPDATE RESTRICT;
ALTER TABLE empleado ADD FOREIGN KEY(IdSector) REFERENCES sector(IdSector);

SELECT * FROM localidad; -- IdProvincia

ALTER TABLE localidad ADD FOREIGN KEY(IdProvincia) REFERENCES provincia(IdProvincia);

SELECT * FROM proveedor; -- IdLocalidad

ALTER TABLE proveedor ADD CONSTRAINT proveedor_fk_localidad FOREIGN KEY(IdLocalidad) REFERENCES localidad(IdLocalidad) ON DELETE RESTRICT ON UPDATE RESTRICT;

SELECT * FROM gasto; -- Fecha IdSucursal IdTipoGasto

ALTER TABLE gasto ADD INDEX(Fecha);

ALTER TABLE gasto ADD FOREIGN KEY(IdSucursal) REFERENCES sucursal(IdSucursal);

ALTER TABLE gasto ADD FOREIGN KEY(IdTipoGasto) REFERENCES tipo_gasto(IdTipoGasto);

SELECT * FROM cliente; -- IdLocalidad  Fecha_Alta  Fecha_Ultima_Modificacion

ALTER TABLE cliente ADD INDEX(Fecha_Alta);

ALTER TABLE cliente ADD INDEX(Fecha_Ultima_Modificacion);

ALTER TABLE cliente ADD FOREIGN KEY(IdLocalidad) REFERENCES localidad(IdLocalidad);

SELECT * FROM compra; -- Fecah IdProducto IdProveedor

ALTER TABLE compra ADD FOREIGN KEY(IdProducto) REFERENCES producto (IdProducto);
ALTER TABLE compra ADD FOREIGN KEY(IdProveedor) REFERENCES proveedor (IdProveedor);
ALTER TABLE compra ADD INDEX(Fecha);

-- Clientes que nunca hicieron compras
SELECT IdCliente FROM cliente
WHERE IdCliente NOT IN (SELECT DISTINCT IdCliente FROM venta);

SELECT * FROM cliente
WHERE Idcliente IN(22,59,66,67,79,84,83)
;

DELETE FROM cliente WHERE IdCliente = 22; -- LO PUEDO ELIMINAR PORQUE NO EXISTE ESTE CLIENTE EN LA TABLA DE VENTAS

-- Todos los clientes que han hecho por lo menos una compra
SELECT IdCliente FROM cliente
WHERE IdCliente IN (SELECT DISTINCT IdCliente FROM venta);

SELECT * FROM cliente
WHERE IdCliente IN (1,2,3,4,5,6);

DELETE FROM cliente WHERE IdCliente = 1;  -- Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`henry_m3`.`venta`, CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`IdCliente`) REFERENCES `cliente` (`IdCliente`))


-- 5) 

CREATE TABLE IF NOT EXISTS fact_venta (
	IdVenta INT,
    Fecha DATE,
    Fecha_Entrega DATE,
    IdCanal INT,
    IdCliente INT,
    IdEmpleado INT,
    IdProducto INT,
    Precio DECIMAL(10,2),
    Cantidad INT
);


SELECT * FROM fact_venta;

INSERT INTO fact_venta
SELECT IdVenta, Fecha, Fecha_Entrega, IdCanal, IdCliente, IdEmpleado, IdProducto, Precio, Cantidad
FROM venta
WHERE outlier = 0 AND YEAR(Fecha) > 2018;

CREATE TABLE IF NOT EXISTS dim_producto (
	IdProducto INT,
    Concepto VARCHAR(130),
    IdTipoProducto INT,
    Precio DECIMAL(30,2)
);

SELECT * FROM dim_producto;

INSERT INTO dim_producto
SELECT IdProducto, Concepto, IdTipoProducto, Precio
FROM producto;

ALTER TABLE fact_venta ADD PRIMARY KEY(IdVenta);
ALTER TABLE dim_producto ADD PRIMARY KEY(IdProducto);
ALTER TABLE fact_venta ADD FOREIGN KEY (IdProducto) REFERENCES dim_producto(IdProducto);

/*
CREATE DATABASE venta; -- Modelo estrella nuevo

CREATE DATABASE compra; -- Modelo estrella con la tabla de hechos central de compras

CREATE DATABASE gasto; -- Modelo estrella con la tabla de hechos central de gastos
*/


-- LECTURE


SELECT * FROM cliente; -- Fecha_Ultima_Modificacion me da los datos necesarios para saber cuando fue la ultima carga/modificacion de datos

SELECT * FROM canal_venta;


SELECT * FROM venta; 
SELECT MAX(Fecha) FROM venta; 

-- A partir de la fecha maxima yo realizo la carga de datos nuevos


USE henry_m3;

SELECT * FROM aux_venta; -- GUARDAMOS REPORTE DE LOS DIFERENTES ERRORES EN LA TABLA DE VENTAS A LA HORA DE HACER TRANSFORMACIONES

USE henry;

SELECT * FROM alumnos;


CREATE TABLE IF NOT EXISTS auditoria_alumnos (
	IdAuditoria INT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Auditoria VARCHAR(80),
    Apellido_Auditoria VARCHAR(80),
    Fecha_Nacimiento_Auditoria DATE,
    Ciudad_Auditoria VARCHAR(80),
    Pais_Auditoria VARCHAR(80),
    CedulaIdentidad_Auditoria VARCHAR(80),
    Usuario_Auditoria VARCHAR(80),
    Fecha_Auditoria DATETIME,
    Tipo_Auditoria VARCHAR(30)
);

DROP TABLE auditoria_alumnos;
SELECT * FROM alumnos;
SELECT * FROM auditoria_alumnos;
SELECT CURRENT_USER(); -- ESTA FUNCION ME DEVUELVE EL USUARIO ACTUAL QUE ESTA EJECTUANDO
SELECT NOW();			-- ESTA FUNCION ME DEVUELVE EL DATETIME AL MOMENTO DE EJECUTAR EL CODIGO

-- TRIGGER PARA LOS INSERTS
CREATE TRIGGER auditoria AFTER INSERT ON alumnos
FOR EACH ROW -- POR CADA FILA QUE YO INSERTE EN ALUMNOS, EJECUTA EL SIGUIENTE CODIGO: 
INSERT INTO auditoria_alumnos(Nombre_Auditoria, Apellido_Auditoria, Fecha_Nacimiento_Auditoria, Ciudad_Auditoria, Pais_Auditoria, CedulaIdentidad_Auditoria, Usuario_Auditoria, Fecha_Auditoria, Tipo_Auditoria) 
VALUES (NEW.Nombre, NEW.Apellido, NEW.Fecha_Nacimiento, NEW.Ciudad, NEW.Pais, NEW.CedulaIdentidad, CURRENT_USER(), NOW(), 'Insert');

DROP TRIGGER auditoria; -- Esto sirve para eliminar un trigger
INSERT INTO alumnos
VALUES ('Nahuel', 'Bielsa', '1988-02-15', 'Medellin','Colombia',345987421);

SELECT * FROM alumnos;
DELETE FROM alumnos WHERE Apellido ='Bielsa';

SELECT * FROM auditoria_alumnos; -- AUTOMATIZAMOS LA INGESTA DE DATOS EN AUDITORIA_ALUMNOS

-- TRIGGER PARA LOS DELETE

CREATE TRIGGER auditoria_delete AFTER DELETE ON alumnos -- OBTENGO LOS VALORES REFENCIADOS EN VALUES A TRAVES DE ESTA TABLA, LA TABLA ALUMNOS
FOR EACH ROW  -- POR CADA FILA QUE ELIMINES, EJECUTA ESTE CODIGO: 
INSERT INTO auditoria_alumnos(Nombre_Auditoria, Apellido_Auditoria, Fecha_Nacimiento_Auditoria, Ciudad_Auditoria, Pais_Auditoria, CedulaIdentidad_Auditoria, Usuario_Auditoria, Fecha_Auditoria, Tipo_Auditoria) 
VALUES (OLD.Nombre, OLD.Apellido, OLD.Fecha_Nacimiento, OLD.Ciudad, OLD.Pais, OLD.CedulaIdentidad, CURRENT_USER(), NOW(), 'Delete')
;

DELETE FROM alumnos WHERE Apellido ='Bielsa';

SELECT * FROM alumnos;
SELECT * FROM auditoria_alumnos;


-- TABLA DE AUDITORIAS PARA LAS MODIFICACIONES EN LA TABLA DE CARRERA
SELECT * FROM carrera;

CREATE TABLE auditoria_carrera (
	IdAuditoria INT AUTO_INCREMENT PRIMARY KEY,
    IdCarrera_Viejo INT,
    IdCarrera_Nuevo INT,
    Carrera_Viejo VARCHAR(50),
    Carrera_Nuevo VARCHAR(50),
    Usuario_Auditoria VARCHAR(80),
    Fecha_Auditoria DATETIME,
    Tipo_Auditoria VARCHAR(30)
);

SELECT * FROM auditoria_carrera;

CREATE TRIGGER auditoria_carrera AFTER UPDATE ON carrera
FOR EACH ROW -- POR CADA FILA QUE VOS ESTES MODIFICANDO, REALIZA ESTE CODIGO: 
INSERT INTO auditoria_carrera (IdCarrera_Viejo, IdCarrera_Nuevo, Carrera_Viejo, Carrera_Nuevo, Usuario_Auditoria, Fecha_Auditoria, Tipo_Auditoria)
VALUES (OLD.IdCarrera, NEW.IdCarrera, OLD.Carrera, NEW.Carrera, CURRENT_USER(), NOW(), 'Update')
;

UPDATE carrera
SET Carrera = 'Data Science'
WHERE IdCarrera = 2;

SELECT * FROM carrera;
SELECT * FROM auditoria_carrera;

INSERT INTO carrera(carrera)
VALUES ('Prueba FT19');

UPDATE carrera
SET IdCarrera = 3
WHERE Carrera LIKE 'Prueba%';


-- CREAR UN TRIGGER PARA LA TABLA DE VENTAS QUE ME PERMITA GUARDAR EN UNA TABLA NUEVA LAS MODIFICACIONES AL CAMPO PRECIO DE OUTLIERS


-- LOAD DATA INFILE

SELECT @@secure_file_priv; -- LOS ARCHIVOS QUE NO ESTEN EN ESTA RUTA NO PODRAN SER CARGADOS EN TABLAS
-- C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\
select * from alumnos;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Alumnos.csv' -- alt+92 = \
INTO TABLE alumnos 
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY ''     -- -> FIELDS SIGNIFICA CAMPOS O COLUMNAS
LINES TERMINATED BY '\n'  -- LAS LINEAS SE SEPARAN CON UN SALTO DE LINEA \n
IGNORE 1 LINES 				-- IGNORA LA PRIMERA LINEA O PRIMERA FILA PORQUE CONTIENE EL NOMBRE DE LAS COLUMAS
(Nombre, Apellido, Fecha_Nacimiento, Ciudad, Pais, CedulaIdentidad) ;


USE henry_m3;

SELECT * FROM producto
ORDER BY Precio DESC;

