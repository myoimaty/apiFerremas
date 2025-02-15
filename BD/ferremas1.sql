-- Eliminamos las tablas y procedimientos almacenados existentes
DROP TABLE producto CASCADE CONSTRAINTS;
DROP TABLE marca CASCADE CONSTRAINTS;

-- Creamos las nuevas tablas para "FERREMAS"
CREATE TABLE producto (
    id VARCHAR2(20) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    cod_marca VARCHAR2(100) NOT NULL,
    precio NUMBER NOT NULL,
    stock NUMBER NOT NULL
   -- imagen_url VARCHAR2(1000)
);

CREATE TABLE marca(
    cod_marca VARCHAR2(100) PRIMARY KEY,
    nombre_marca VARCHAR2(60) NOT NULL
    );
    
ALTER TABLE producto ADD(
 CONSTRAINT FK_producto_marca FOREIGN KEY(cod_marca)REFERENCES marca(cod_marca)
);

INSERT INTO marca VALUES('bkn-001','marca bkn');
INSERT INTO marca VALUES('BOS-002','bosch');
INSERT INTO marca VALUES('eta-003','etanli');

--INSERTAR prod

    INSERT INTO producto VALUES('FER-12345','Martillo bkn','bkn-001',10,150);
    INSERT INTO producto VALUES('FER-82521','Taladro sonico','BOS-002',22,50);
    INSERT INTO producto VALUES('FER-45232','martillo de acrilico','eta-003',40,150);

ALTER TABLE producto ADD imagen_url VARCHAR2(1000);
COMMIT;
--imagenes de los productos (en orden)
--https://easycl.vtexassets.com/arquivos/ids/222270/1277696-02.jpg?v=637528335261030000
--https://naturalenergy.cl/4636-large_default/martillo-de-nylon-101.jpg
--https://konstrumarket.cl/wp-content/uploads/2022/05/HBSTEGBM10-RE.jpg


CREATE OR REPLACE PROCEDURE sp_get_productos(p_out out NUMBER,
                                             p_cursor out SYS_REFCURSOR)
IS
BEGIN
    OPEN p_cursor FOR SELECT 
        p.id, 
        p.nombre,
        p.cod_marca,
        (SELECT nombre_marca FROM marca m where p.cod_marca = m.cod_marca)as nom_marca,
        p.precio, 
        p.stock,
        p.imagen_url
    FROM producto p;
    
    p_out := 1;
EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_get_productos;

CREATE OR REPLACE PROCEDURE sp_get_producto(p_cod_pro VARCHAR2,
                                            p_out out NUMBER,
                                            p_cursor out SYS_REFCURSOR)
IS
BEGIN
    OPEN p_cursor FOR SELECT 
        p.id, 
        p.nombre,
        p.cod_marca,
        (SELECT nombre_marca FROM marca m where p.cod_marca = m.cod_marca)as nom_marca,
        p.precio, 
        p.stock,
        p.imagen_url
    FROM producto p
    WHERE p.id = p_cod_pro;
    
    p_out := 1;
EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_get_producto;

    
CREATE OR REPLACE PROCEDURE sp_insertar_prod(p_id VARCHAR2,
                                             p_nombre VARCHAR2,
                                             p_cod_marca VARCHAR2,
                                             p_precio NUMBER,
                                             p_stock NUMBER,
                                             p_imagen_url VARCHAR2,
                                             p_out OUT NUMBER)
IS
BEGIN
    INSERT INTO producto VALUES (p_id, p_nombre, p_cod_marca, p_precio, p_stock, p_imagen_url);
    p_out := 1;
EXCEPTION   
    WHEN OTHERS THEN
        p_out := 0;
END sp_insertar_prod;
    


CREATE OR REPLACE PROCEDURE sp_put_prod(p_id VARCHAR2,
                                             p_nombre VARCHAR2,
                                             p_cod_marca VARCHAR2,
                                             p_precio NUMBER,
                                             p_stock NUMBER,
                                             p_imagen_url VARCHAR2,
                                             p_out OUT NUMBER)
                                             
IS
BEGIN
    UPDATE producto
    SET nombre = p_nombre,
        cod_marca = p_cod_marca,
        precio = p_precio,
        stock = p_stock,
        imagen_url = p_imagen_url
    WHERE id = p_id;
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out:=0;
    END sp_put_prod;
    
CREATE OR REPLACE PROCEDURE sp_delete_prod (p_id VARCHAR2,
                                            p_out OUT NUMBER)
IS
BEGIN
    DELETE FROM producto
    WHERE id = p_id;
    
    IF sql%ROWCOUNT >0 THEN
        p_out:=1;
    ELSE
        p_out:=0;
    END IF;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out:=0;
END sp_delete_prod;
/
CREATE OR REPLACE PROCEDURE sp_patch_prod(p_id VARCHAR2,
                                          p_stock NUMBER,
                                          p_out OUT NUMBER)
IS
BEGIN
    UPDATE producto
    SET stock = p_stock
    WHERE id = p_id;
    
    p_out := SQL%ROWCOUNT; -- Esto devolver? 1 si se realiz? una actualizaci?n y 0 si no se encontr? ning?n registro para actualizar.
EXCEPTION
    WHEN OTHERS THEN
        p_out := 0; -- Si ocurre alg?n error, establecer p_out en 0
END sp_patch_prod;
/

CREATE OR REPLACE PROCEDURE sp_update_stock(p_id VARCHAR2,
                                            p_stock NUMBER,
                                            p_out OUT NUMBER)
IS
BEGIN
    UPDATE producto
    SET stock = p_stock
    WHERE id = p_id;
    
    IF sql%ROWCOUNT > 0 THEN
        p_out := 1;
    ELSE
        p_out := 0;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_update_stock;
/

COMMIT;

VARIABLE p_out NUMBER;
VARIABLE p_cursor REFCURSOR;

EXEC SP_GET_PRODUCTO('FER-12345', :p_out, :p_cursor);

PRINT p_out;
PRINT p_cursor;


CREATE OR REPLACE PROCEDURE sp_get_productos_por_nombre(p_nombre VARCHAR2,
                                                        p_out out NUMBER,
                                                        p_cursor out SYS_REFCURSOR)
IS
BEGIN
    OPEN p_cursor FOR SELECT 
        p.id, 
        p.nombre,
        p.cod_marca,
        (SELECT nombre_marca FROM marca m where p.cod_marca = m.cod_marca) as nom_marca,
        p.precio, 
        p.stock,
        p.imagen_url
    FROM producto p
    WHERE LOWER(p.nombre) LIKE '%' || LOWER(p_nombre) || '%';
    
    p_out := 1;
EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_get_productos_por_nombre;



COMMIT;


COMMIT;
        
