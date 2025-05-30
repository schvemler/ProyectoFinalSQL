drop database sistema_ventas;
Create database sistema_ventas;
use sistema_ventas;




CREATE TABLE `productos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) DEFAULT NULL,
  `codigo` varchar(50) DEFAULT NULL,
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
  `precio` decimal(18,2) NOT NULL,
  `fecha` date NOT NULL,
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
    pp.precio AS precio_mas_reciente
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
    
    
    
    
    -- Stored procedure para insertar datos en las tablas productos y precio_producto
DELIMITER //
CREATE PROCEDURE InsertarProductoConPrecio(
    IN p_nombre VARCHAR(50),
    IN p_codigo VARCHAR(50),
    IN p_precio DECIMAL(18, 2),
    IN p_fecha DATE
)
BEGIN
    -- Declarar variable para el ID del nuevo producto
    DECLARE v_producto_id INT;

    -- Insertar el nuevo producto en la tabla productos
    INSERT INTO productos (nombre, codigo)
    VALUES (p_nombre, p_codigo);

    -- Obtener el ID del producto recién insertado
    SET v_producto_id = LAST_INSERT_ID();

    -- Insertar el precio del producto en la tabla precio_producto
    INSERT INTO precio_producto (id_producto, precio, fecha)
    VALUES (v_producto_id, p_precio, p_fecha);

END //
DELIMITER ;

-- Ejemplo de cómo llamar al stored procedure
call InsertarProductoConPrecio('Nuevo Producto', 'NP001', 25.99, CURDATE());



INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Laptop Gamer X1', 'LGX1-789');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Teclado Mecánico RGB', 'TMRGB-012');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Monitor Curvo 27"', 'MC27-345');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Mouse Inalámbrico Pro', 'MIP-678');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Auriculares Gaming 7.1', 'AG71-901');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Webcam Full HD', 'WFHD-234');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Disco Duro SSD 1TB', 'SSD1T-567');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Router WiFi 6', 'RW6-890');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Impresora Multifunción', 'IM-123');
INSERT INTO `productos` (`nombre`, `codigo`) VALUES ('Tableta Gráfica Profesional', 'TGP-456');











CREATE TABLE `usuario_hora_dia` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_hora` int(11) NOT NULL,
  `id_dia` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `entrada` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_dia_semana_hora` (`id_hora`),
  KEY `fk_dia_semana_horas` (`id_dia`),
  KEY `id_user` (`id_user`),
  CONSTRAINT `fk_dia_semana_hora` FOREIGN KEY (`id_hora`) REFERENCES `hora` (`id`),
  CONSTRAINT `fk_dia_semana_horas` FOREIGN KEY (`id_dia`) REFERENCES `dia_semana` (`id`),
  CONSTRAINT `usuario_hora_dia_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `usuarios` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

