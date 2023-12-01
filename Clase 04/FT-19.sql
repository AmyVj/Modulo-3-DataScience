-- HW 3 M3 FT19

USE adventureworks;

-- 1) Obtener un listado de cuál fue el volumen de ventas (cantidad) por año y método de envío mostrando para cada registro, qué porcentaje representa del total del año.

-- SUBCONSULTA
SELECT DISTINCT ShipMethodID FROM salesorderheader;

SELECT * FROM salesorderheader; -- OrderDate SalesOrderID
SELECT * FROM salesorderdetail; -- OrderQty SalesOrderID

SELECT YEAR(h.OrderDate) 'Año', SUM(d.OrderQty) 'CantidadTotalAño'
FROM salesorderheader h JOIN salesorderdetail d 
							ON (h.SalesOrderID = d.SalesOrderID) 
GROUP BY 1;

SELECT * FROM shipmethod; -- ShipMethodID Name

SELECT Year(h.OrderDate) AS 'Año', 
		s.Name AS 'MetodoEnvio',
        SUM(d.OrderQty) AS 'Cantidad',
        ROUND(SUM(d.OrderQty) / t.CantidadTotalAño * 100, 2) AS 'PorcentajeTotalAño'
FROM salesorderheader h JOIN salesorderdetail d ON (h.SalesOrderID = d.SalesOrderID) 
						JOIN shipmethod s ON (s.ShipMethodID = h.ShipMethodID) 
                        JOIN (SELECT YEAR(h.OrderDate) 'Año', SUM(d.OrderQty) 'CantidadTotalAño'
								FROM salesorderheader h JOIN salesorderdetail d 
														ON (h.SalesOrderID = d.SalesOrderID) 
								GROUP BY 1 ) t   ON (t.Año = YEAR(h.OrderDate)) 
GROUP BY YEAR(h.OrderDate), s.Name, t.CantidadTotalAño -- No deberiamos de agrupar por este ultimo
 ;
-- 1.797 sec

-- Error Code: 1055. Expression #4 of SELECT list is not in GROUP BY clause and contains nonaggregated column 't.CantidadTotalAño' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by

-- Error Code: 1056. Can't group on 'PorcentajeTotalAño'


SHOW VARIABLES LIKE 'sql_mode'; -- 'sql_mode', 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'


-- FUNCION VENTANA

SELECT Año, MetodoEnvio, Cantidad,
	ROUND(Cantidad / SUM(Cantidad) OVER (PARTITION BY Año) * 100, 2) AS PorcentajeTotalAño
FROM (SELECT YEAR(h.OrderDate) as Año,
		s.Name AS MetodoEnvio,
        SUM(d.OrderQty) AS Cantidad
		FROM salesorderheader h JOIN salesorderdetail d
							ON (h.SalesOrderID = d.SalesOrderID) 
						JOIN shipmethod s
							ON (s.ShipMethodID = h.ShipMethodID)
GROUP BY 1, 2
ORDER BY 1, 2) v
 ; -- 0.75 sec
 
 
 -- 2) Obtener un listado por categoría de productos, con el valor total de ventas y productos vendidos, mostrando para ambos, su porcentaje respecto del total.
 
 -- VENTA = SUM(PRECIO * CANTIDAD)                 VOLUMENES, CANTIDAD = SUM(CANTIDAD)
 
 SELECT * FROM productcategory;  -- ProductCategoryID
 SELECT * FROM productsubcategory; -- ProductCategoryID ProductSubcategoryID
 SELECT * FROM product; -- ProductSubcategoryID ProductID
 SELECT * FROM salesorderdetail; -- ProductID OrderQty LineTotal UnitPrice
 
 
 SELECT Categoria, Cantidad,
		ROUND(Cantidad / SUM(Cantidad) OVER () * 100, 2) AS PorcentajeCantidad,
        ROUND(TotalVenta,2),
        ROUND(TotalVenta / SUM(TotalVenta) OVER () * 100, 2) AS PorcentajeVenta
 FROM ( SELECT c.Name as 'Categoria',
		SUM(d.OrderQty) as 'Cantidad',
        SUM(d.OrderQty * d.UnitPrice) as 'TotalVenta'  -- SUM(LineTotal) 
FROM salesorderdetail d JOIN product p ON (p.ProductID = d.ProductID) 
						JOIN productsubcategory ps ON (ps.ProductSubcategoryID = p.ProductSubcategoryID) 
                        JOIN productcategory c ON (c.ProductCategoryID = ps.ProductCategoryID) 
GROUP BY 1
ORDER BY 1) v
;


-- 3) Obtener un listado por país (según la dirección de envío), con el valor total de ventas y productos vendidos
--  mostrando para ambos, su porcentaje respecto del total.

SELECT * FROM salesorderheader; -- ShipToAddressID SalesOrderID 
SELECT * FROM address; -- AddressID StateProvinceID
SELECT * FROM stateprovince; -- StateProvinceID  CountryRegionCode
SELECT * FROM countryregion; -- CountryRegionCode Name 
SELECT * FROM salesorderdetail; -- SalesOrderID OrderQty LineTotal

SELECT cr.Name as 'Pais',
		SUM(d.OrderQty) AS 'Cantidad',
        SUM(d.LineTotal) AS 'TotalVenta'
FROM salesorderdetail d JOIN salesorderheader h ON (h.SalesOrderID = d.SalesOrderID) 
						JOIN address a ON (a.AddressID = h.ShipToAddressID) 
                        JOIN stateprovince sp ON (a.StateProvinceID = sp.StateProvinceID )
                        JOIN countryregion cr ON (cr.CountryRegionCode = sp.CountryRegionCode) 
GROUP BY 1
ORDER BY 1
;

SELECT cr.Name, SUM(d.OrderQty) AS Cantidad, 
				ROUND(SUM(d.OrderQty) / v.Cantidad * 100,2) AS 'PorcentajeTotalCantidad',
				SUM(d.LineTotal) AS TotalVentas,
                ROUND(SUM(d.LineTotal) / v.TotalVenta * 100,2) AS 'PontajeTotalVenta'
FROM salesorderdetail d JOIN salesorderheader h ON (h.SalesOrderID = d.SalesOrderID) 
						JOIN address a ON (a.AddressID = h.ShipToAddressID) 
                        JOIN stateprovince sp ON (sp.StateProvinceID = a.StateProvinceID )
                        JOIN countryregion cr ON (cr.CountryRegionCode = sp.CountryRegionCode) 
                        JOIN (SELECT cr.Name as 'Pais',
									SUM(d.OrderQty) AS 'Cantidad',
									SUM(d.LineTotal) AS 'TotalVenta'
									FROM salesorderdetail d JOIN salesorderheader h ON (h.SalesOrderID = d.SalesOrderID) 
									JOIN address a ON (a.AddressID = h.ShipToAddressID) 
									JOIN stateprovince sp ON (a.StateProvinceID = sp.StateProvinceID )
									JOIN countryregion cr ON (cr.CountryRegionCode = sp.CountryRegionCode) 
									GROUP BY 1) v ON (v.Pais = cr.Name) 
GROUP BY 1;

-- FUNCION VENTANA

SELECT Pais, Cantidad, ROUND(Cantidad / SUM(Cantidad) OVER () *100,2) AS 'PorcentajeCantidad',
			TotalVenta, ROUND(TotalVenta / SUM(TotalVenta) OVER () * 100, 2) AS 'PorcentajeVenta'
FROM (SELECT cr.Name as 'Pais',
		SUM(d.OrderQty) AS 'Cantidad',
        SUM(d.LineTotal) AS 'TotalVenta'
FROM salesorderdetail d JOIN salesorderheader h ON (h.SalesOrderID = d.SalesOrderID) 
						JOIN address a ON (a.AddressID = h.ShipToAddressID) 
                        JOIN stateprovince sp ON (a.StateProvinceID = sp.StateProvinceID )
                        JOIN countryregion cr ON (cr.CountryRegionCode = sp.CountryRegionCode) 
GROUP BY 1
ORDER BY 1)  V
;

CREATE VIEW procentaje_cantidad_ventas_pais AS
SELECT Pais, Cantidad, ROUND(Cantidad / SUM(Cantidad) OVER () *100,2) AS 'PorcentajeCantidad',
			TotalVenta, ROUND(TotalVenta / SUM(TotalVenta) OVER () * 100, 2) AS 'PorcentajeVenta'
FROM (SELECT cr.Name as 'Pais',
		SUM(d.OrderQty) AS 'Cantidad',
        SUM(d.LineTotal) AS 'TotalVenta'
FROM salesorderdetail d JOIN salesorderheader h ON (h.SalesOrderID = d.SalesOrderID) 
						JOIN address a ON (a.AddressID = h.ShipToAddressID) 
                        JOIN stateprovince sp ON (a.StateProvinceID = sp.StateProvinceID )
                        JOIN countryregion cr ON (cr.CountryRegionCode = sp.CountryRegionCode) 
GROUP BY 1
ORDER BY 1)  V
;

SELECT * FROM procentaje_cantidad_ventas_pais;


-- 4) Obtener por ProductID, los valores correspondientes a la mediana de las ventas (LineTotal), sobre las ordenes realizadas. 
-- Investigar las funciones FLOOR() y CEILING().

SELECT FLOOR(4.59); -- REDONDEA HACIA ABAJO
SELECT CEILING(4.59); -- REONDEA HACIA ARRIBA

SELECT ProductID, AVG(LineTotal) -- media
FROM salesorderdetail 
GROUP BY 1;

-- DEBEMOS APLICAR FLOOR() Y CEILING() PARA OBTENER LA MEDIANA
SELECT ProductID, LineTotal, 
		COUNT(*) OVER (PARTITION BY ProductID) AS Cnt,
        ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY LineTotal) AS RowNum
FROM salesorderdetail;

SELECT ProductID, AVG(LineTotal) AS Mediana_Producto, Cnt, RowNum
FROM (SELECT ProductID, LineTotal, 
		COUNT(*) OVER (PARTITION BY ProductID) AS Cnt,
        ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY LineTotal) AS RowNum
		FROM salesorderdetail) v
WHERE 	(FLOOR(Cnt/2) = CEILING(Cnt/2) AND (RowNum = FLOOR(Cnt/2) OR RowNum = FLOOR(Cnt/2)+1)) 
	OR
		(FLOOR(Cnt/2) <> CEILING(Cnt/2) AND RowNum = CEILING(Cnt/2))
GROUP BY 1;


-- LECTURE 


CREATE DATABASE henry_m3;

SELECT @@global.secure_file_priv; -- EN ESTA CARPETA DEBEN ARROJAR LOS ARCHIVOS .CSV


/*
CONDICIONES PARA LOAD DATA INFILE
-1) El archivo este almacenado correctamente
-2) La tabla tiene que existir
*/

/* ESTRUCTURA BASICA DE LA INSTRUCCION

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\{nombre_archivo.csv}'
INTO TABLE nombre_tabla
FIELDS TERMINATED BY ',' ENCLOSED BY '' ESCAPED BY ''
LINES TERMINATED BY '\n' 
IGNORE 1 LINES -- ESTO QUIERE DECIR QUE YO IGNORO LA CABECERA, LA PRIMERA LINEA CONTIENE LOS NOMBRES DE LAS COLUMNAS
(columna1,columna2,...);

ESTA INSTRUCCION TE CARGA TODO EL ARCHIVO DENTRO DE UNA TABLA
*/

-- DATA IMPORT WIZARD 
USE henry_m3;
select * from gasto;

ALTER TABLE gasto CHANGE Fecha Fecha DATE;
