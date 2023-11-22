USE adventureworks; -- Cambiar a la base de datos 'adventureworks'

-- Crear un procedimiento que recibe como parámetro una fecha y muestre la cantidad de órdenes ingresadas en esa fecha

SELECT * FROM salesorderheader;
SELECT * FROM salesorderdetail; -- OrderQty CANTIDAD DE OBJETOS POR PEDIDO
SELECT * FROM shipmethod;



DROP PROCEDURE IF EXISTS totalOrdenes; 
DELIMITER $$
CREATE PROCEDURE totalOrdenes(IN fechaOrden DATE)
BEGIN
	SELECT COUNT(*)
	FROM salesorderheader
	WHERE DATE(OrderDate) = fechaOrden;
END $$

DELIMITER ;

CALL totalOrdenes('2002-01-01');




