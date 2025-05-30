drop database sistema_ventas;
Create database sistema_ventas;
use sistema_ventas;




CREATE TABLE `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) DEFAULT NULL,
  `codigo` varchar(50) not null unique,
  PRIMARY KEY (`id`)
  
) ENGINE=InnoDB;


CREATE TABLE `precio_producto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_producto` int(11) NOT NULL,
  `precio` decimal(18,2) NOT NULL,
  `fecha` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_id_producto` (`id_producto`),
  
  CONSTRAINT `fk_id_producto` 
  FOREIGN KEY (`id_producto`) REFERENCES 
  `productos` (`id`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ventas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fecha_hora` datetime NOT NULL,
   `concepto` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `ventas_producto` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
   `id_venta` int(11) NOT NULL,
  `id_producto` int(11) NOT NULL,
   `id_precio_producto` int(11) NOT NULL,
 
  PRIMARY KEY (`id`),
  KEY `fk_id_venta` (`id_venta`),
   KEY `fk_id_producto` (`id_producto`),
    KEY `fk_id_precio_producto` (`id_precio_producto`),
    
  CONSTRAINT `fk_id_producto2` 
  FOREIGN KEY (`id_producto`) REFERENCES 
  `productos` (`id`) ,
   CONSTRAINT `fk_id_precio_producto` 
  FOREIGN KEY (`id_precio_producto`) REFERENCES 
  `precio_producto` (`id`),
   CONSTRAINT `fk_id_venta` 
  FOREIGN KEY (`id_venta`) REFERENCES 
  `ventas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;







CREATE VIEW Vista_precios_productos_recientes AS
SELECT
    p.id AS producto_id,
    p.nombre AS nombre_producto,
    p.codigo AS codigo,
     pp.id AS id_precio_mas_reciente,
    pp.precio AS precio_mas_reciente,
    pp.fecha AS ultima_actualizacion
FROM
    productos p
JOIN
    precio_producto pp ON p.id = pp.id_producto
WHERE
    pp.fecha = (
        SELECT
            MAX(fecha)
        FROM
            precio_producto AS sub_pp
        WHERE
            sub_pp.id_producto = p.id
            
    );
    
    
    
    

DELIMITER //

CREATE PROCEDURE  InsertarProductoConPrecio(
    IN p_nombre VARCHAR(50),
    IN p_codigo VARCHAR(50),
    IN p_precio DECIMAL(18, 2),
    IN p_fecha DATE
)
BEGIN
    
    DECLARE v_producto_id INT;

   
    SELECT id INTO v_producto_id
    FROM productos
    WHERE codigo = p_codigo;
    IF v_producto_id IS NOT NULL THEN
        UPDATE productos
        SET nombre = p_nombre
        WHERE id = v_producto_id;
        INSERT INTO precio_producto (id_producto, precio, fecha)
        VALUES (v_producto_id, p_precio, p_fecha);
    ELSE
        INSERT INTO productos (nombre, codigo)
        VALUES (p_nombre, p_codigo);
        SET v_producto_id = LAST_INSERT_ID();
        INSERT INTO precio_producto (id_producto, precio, fecha)
        VALUES (v_producto_id, p_precio, p_fecha);

    END IF;

END //

DELIMITER ;


DELIMITER //

CREATE PROCEDURE ObtenerProductoConUltimoPrecioPorCodigo(
    IN p_codigo VARCHAR(50)
)
BEGIN
    SELECT
        *
    FROM
        sistema_ventas.vista_precios_productos_recientes
    WHERE codigo = p_codigo;
END //

DELIMITER ;



DELIMITER //

CREATE PROCEDURE InsertarVenta(
    IN p_concepto VARCHAR(50),
    OUT p_id_venta INT
)
BEGIN
    INSERT INTO sistema_ventas.ventas(
        fecha_hora,
        concepto
    )
    VALUES
    (NOW(), p_concepto);

    -- Asignar el último ID insertado al parámetro OUT
    SELECT LAST_INSERT_ID() INTO p_id_venta;

END //

DELIMITER ;



call InsertarProductoConPrecio('Laptop Gamer X1', 'LGX1-789', 2500000.99, CURDATE());
call InsertarProductoConPrecio('Teclado Mecánico RGB', 'TMRGB-012', 30000.99, CURDATE());
call InsertarProductoConPrecio('Monitor Curvo 27"', 'MC27-345', 450005.99, CURDATE());
call InsertarProductoConPrecio('Mouse Inalámbrico Pro', 'MIP-678', 25.99, CURDATE());
call InsertarProductoConPrecio('Auriculares Gaming 7.1', 'AG71-901', 167825.99, CURDATE());
call InsertarProductoConPrecio('Webcam Full HD', 'WFHD-234', 1000025.99, CURDATE());
call InsertarProductoConPrecio('Disco Duro SSD 1TB', 'SSD1T-567', 567925.99, CURDATE());
call InsertarProductoConPrecio('Router WiFi 6', 'RW6-890', 234825.99, CURDATE());
call InsertarProductoConPrecio('Impresora Multifunción', 'IM-123', 625000.99, CURDATE());


call InsertarProductoConPrecio('Tableta Gráfica Profesional', 'TGP-456', 6452589.99, '2025-05-29');


call InsertarProductoConPrecio('Tableta Gráfica Profesional', 'TGP-456', 952589.99, '2025-05-29');


call InsertarProductoConPrecio('Tableta Gráfica Profesional', 'TGP-456', 4589.99, CURDATE());

CALL InsertarVenta('Venta de productos electrónicos',@id);
select @id;




DELIMITER //

CREATE PROCEDURE InsertarVentaProducto(
    IN in_id_venta INT,
    IN in_codigo_producto VARCHAR(50) -- Ahora se recibe el código del producto
)
BEGIN
    -- Declarar variables para almacenar el ID del producto y el ID del precio más reciente
    DECLARE v_id_producto INT;
    DECLARE v_id_precio_producto INT;
    DECLARE v_precio_venta DECIMAL(18,2);

    -- Obtener el ID del producto usando el código proporcionado
    SELECT id INTO v_id_producto
    FROM sistema_ventas.productos
    WHERE codigo = in_codigo_producto;

    -- Verificar si el producto fue encontrado
    IF v_id_producto IS NULL THEN
        -- Opcional: Manejar el error si el producto no existe
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Producto no encontrado con el código proporcionado.';
    ELSE
        -- Obtener el ID del registro de precio más reciente y el precio para ese producto
        -- Es crucial obtener el ID del registro de precio de la tabla 'precio_producto'
        -- y no de la vista, ya que la vista no expone el ID del registro de precio.
        SELECT pp.id, pp.precio
        INTO v_id_precio_producto, v_precio_venta
        FROM sistema_ventas.precio_producto pp
        WHERE pp.id_producto = v_id_producto
        ORDER BY pp.fecha DESC, pp.id DESC -- Ordenar por fecha descendente y luego por ID para el caso de precios con la misma fecha
        LIMIT 1;

        -- Verificar si se encontró un precio para el producto
        IF v_id_precio_producto IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se encontró un precio para el producto.';
        ELSE
            -- Insertar el registro en ventas_producto
            INSERT INTO sistema_ventas.ventas_producto
            (
                id_venta,
                id_producto,
                id_precio_producto
            )
            VALUES
            (
                in_id_venta,
                v_id_producto,
                v_id_precio_producto
            );
        END IF;
    END IF;

END //

DELIMITER ;



CALL InsertarVentaProducto(1, 'LGX1-789');