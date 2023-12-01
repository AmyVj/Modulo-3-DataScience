USE adventureworks;


-- SUBCONSULTAS de cantidad total por Año

SELECT * FROM salesorderheader LIMIT 0, 500;
SELECT * FROM salesorderdetail LIMIT 0, 500;

SELECT YEAR(h.OrderDate) AS 'Año', SUM(d.OrderQty) AS 'CantidadTotalAño'
FROM salesorderheader h
JOIN salesorderdetail d ON h.SalesOrderID = d.SalesOrderID
GROUP BY YEAR(h.OrderDate)
LIMIT 0, 500;

                    
-- SUBCONSULTA de total de modo de envio con su porcentaje
SELECT
    YEAR(h.OrderDate) AS 'Año',
    e.Name AS 'ModoEnvío',
    SUM(d.OrderQty) AS 'CantidadTotalAño',
    SUM(d.OrderQty) / SUM(CASE WHEN e.Name IS NOT NULL THEN d.OrderQty ELSE 0 END) * 100 AS 'PorcentajeTotal'
FROM
    salesorderheader h
JOIN
    salesorderdetail d ON h.SalesOrderID = d.SalesOrderID
LEFT JOIN
    shipmethod e ON e.ShipMethodID = h.ShipMethodID
GROUP BY
    YEAR(h.OrderDate), e.Name
ORDER BY
    YEAR(h.OrderDate), e.Name
LIMIT
    0, 500;



-- Porcentaje total de del año en ventas
SELECT 
    YEAR(h.OrderDate) AS 'Año',
    SUM(d.OrderQty) AS 'CantidadTotalAño',
    SUM(d.OrderQty) / (SELECT SUM(OrderQty) FROM salesorderdetail) * 100 AS 'PorcentajeTotal'
FROM 
    salesorderheader h
JOIN 
    salesorderdetail d ON h.SalesOrderID = d.SalesOrderID
GROUP BY 
    YEAR(h.OrderDate)
LIMIT 
    0, 500;

--  2. Obtener un listado por categoría de productos, con el valor total de ventas y productos vendidos, mostrando para ambos, su porcentaje respecto del total

SELECT	Categoria,
		Cantidad,
        Total AS TotalCategoria,
        ROUND(Cantidad / SUM(Cantidad) OVER () * 100, 2) AS PorcentajeCantidad,
        ROUND(Total / SUM(Total) OVER () * 100, 2) AS PorcentajeVenta
FROM (
	SELECT 	c.Name AS Categoria, 
			SUM(d.OrderQty) as Cantidad, 
            SUM(d.LineTotal) as Total
	FROM salesorderheader h
		JOIN salesorderdetail d
			ON (h.SalesOrderID = d.SalesOrderID)
		JOIN product p
			ON (d.ProductID = p.ProductID)
		JOIN productsubcategory s
			ON (p.ProductSubcategoryID = s.ProductSubcategoryID)
		JOIN productcategory c
			ON (s.ProductCategoryID = c.ProductCategoryID)
	GROUP BY c.Name
	ORDER BY c.Name) v;

-- 3. Obtener un listado por país (según la dirección de envío), con el valor total de ventas y productos vendidos, mostrando para ambos, su porcentaje respecto del total. 
SELECT      
    Pais,     
    Cantidad,     
    Venta,     
    Cantidad / total_ventas.TotalVentas * 100 AS 'PorcentajeCantidad',     
    Venta / total_ventas.TotalVentas * 100 AS 'PorcentajeVenta' 
FROM (
    SELECT  
        cr.Name as Pais,     
        SUM(d.OrderQty) as Cantidad,     
        SUM(d.LineTotal) as Venta  
    FROM salesorderheader h   
    JOIN salesorderdetail d    
        ON (h.SalesOrderID = d.SalesOrderID)   
    JOIN address a    
        ON (h.ShipToAddressID = a.AddressID)   
    JOIN stateprovince sp    
        ON (a.StateProvinceID = sp.StateProvinceID)   
    JOIN countryregion cr    
        ON (sp.CountryRegionCode = cr.CountryRegionCode)  
    GROUP BY cr.Name  
) v 
CROSS JOIN (
    SELECT 
        SUM(d.OrderQty) AS 'TotalVentas', 
        SUM(d.LineTotal) AS 'TotalProductos'
    FROM salesorderdetail d
    JOIN salesorderheader h
        ON (h.SalesOrderID = d.SalesOrderID)
    JOIN address a    
        ON (h.ShipToAddressID = a.AddressID)   
    JOIN stateprovince sp    
        ON (a.StateProvinceID = sp.StateProvinceID)   
    JOIN countryregion cr    
        ON (sp.CountryRegionCode = cr.CountryRegionCode)  
) total_ventas
LIMIT 0, 500;

-- 4. Obtener por ProductID, los valores correspondientes a la mediana de las ventas (LineTotal), sobre las ordenes realizadas. Investigar las funciones FLOOR() y CEILING 

SELECT 
    ProductID,
    CASE
        WHEN COUNT(*) % 2 = 1 THEN 
            FLOOR((COUNT(*) + 1) / 2)
        ELSE 
            (FLOOR(COUNT(*) / 2) + CEILING(COUNT(*) / 2)) / 2
    END AS MedianPosition,
    (
        SELECT 
            sd1.LineTotal
        FROM 
            salesorderdetail sd1
        WHERE 
            sd1.ProductID = s.ProductID
        ORDER BY 
            sd1.LineTotal
        LIMIT 
            1 OFFSET MedianPosition - 1
    ) AS MedianValue
FROM 
    salesorderdetail s
GROUP BY 
    ProductID;

-- 4) Obtener por ProductID, los valores correspondientes a la mediana de las ventas (LineTotal), sobre las ordenes realizadas. Investigar las funciones FLOOR() y CEILING().

SELECT 
    ProductID,
    AVG(LineTotal) AS Mediana_Producto,
    COUNT(*) AS Cnt
FROM (
    SELECT 
        ProductID,
        LineTotal,
        NTILE(2) OVER (PARTITION BY ProductID ORDER BY LineTotal) AS ntile_value
    FROM 
        salesorderdetail
) AS subquery
WHERE 
    ntile_value = 2
GROUP BY 
    ProductID;




