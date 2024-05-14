-- Eliminamos las tablas y procedimientos almacenados existentes
DROP TABLE producto CASCADE CONSTRAINTS;
DROP TABLE marca CASCADE CONSTRAINTS;

-- Creamos las nuevas tablas para "FERREMAS"
CREATE TABLE producto (
    codigo_producto VARCHAR2(20) PRIMARY KEY,
    nombre VARCHAR2(100) NOT NULL,
    cod_marca VARCHAR2(100) NOT NULL,
    precio NUMBER NOT NULL,
    stock NUMBER NOT NULL
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

    INSERT INTO producto VALUES('FER-12345','Martillo bkn','bkn-001',20000,150);
    INSERT INTO producto VALUES('FER-82521','Taladro sonico','BOS-002',150000,50);
    INSERT INTO producto VALUES('FER-45232','alicate etanli','eta-003',7000,150);


COMMIT;



CREATE OR REPLACE PROCEDURE sp_get_productos(p_out out NUMBER,
                                             p_cursor out SYS_REFCURSOR)
IS
BEGIN
    OPEN p_cursor FOR SELECT 
        p.codigo_producto, 
        p.nombre,
        p.cod_marca,
        (SELECT nombre_marca FROM marca m where p.cod_marca = m.cod_marca)as nom_marca,
        p.precio, 
        p.stock 
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
        p.codigo_producto, 
        p.nombre,
        p.cod_marca,
        (SELECT nombre_marca FROM marca m where p.cod_marca = m.cod_marca)as nom_marca,
        p.precio, 
        p.stock 
    FROM producto p
    WHERE p.codigo_producto = p_cod_pro;
    
    p_out := 1;
EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_get_producto;

CREATE OR REPLACE PROCEDURE sp_insertar_prod(p_codigo_producto VARCHAR2,
                                             p_nombre VARCHAR2,
                                             p_cod_marca VARCHAR2,
                                             p_precio NUMBER,
                                             p_stock NUMBER,
                                             p_out OUT NUMBER)
IS
BEGIN
    INSERT INTO producto VALUES (p_codigo_producto,p_nombre,
                                 p_cod_marca,p_precio,
                                 p_stock);
    p_out :=1;
    
    EXCEPTION   
    WHEN OTHERS THEN
        p_out :=0;
    END sp_insertar_prod;
    


CREATE OR REPLACE PROCEDURE sp_put_prod(p_codigo_producto VARCHAR2,
                                             p_nombre VARCHAR2,
                                             p_cod_marca VARCHAR2,
                                             p_precio NUMBER,
                                             p_stock NUMBER,
                                             p_out OUT NUMBER)
                                             
IS
BEGIN
    UPDATE producto
    SET nombre = p_nombre,
        cod_marca = p_cod_marca,
        precio = p_precio,
        stock = p_stock
    WHERE codigo_producto = p_codigo_producto;
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out:=0;
    END sp_put_prod;
    
CREATE OR REPLACE PROCEDURE sp_delete_prod (p_codigo_producto VARCHAR2,
                                            p_out OUT NUMBER)
IS
BEGIN
    DELETE FROM producto
    WHERE CODIGO_PRODUCTO = p_codigo_producto;
    
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
CREATE OR REPLACE PROCEDURE sp_patch_prod(p_codigo_producto VARCHAR2,
                                             p_nombre VARCHAR2,
                                             p_cod_marca VARCHAR2,
                                             p_precio NUMBER,
                                             p_stock NUMBER,
                                             p_out OUT NUMBER)
IS
BEGIN
    INSERT INTO producto VALUES(p_codigo_producto,p_nombre,
                                p_cod_marca,p_precio,p_stock);
    p_out:=1;
    
    EXCEPTION
    WHEN dup_val_on_index THEN
    UPDATE producto
        SET nombre = p_nombre,
            cod_marca = p_cod_marca,
            precio = p_precio,
            stock = p_stock
        WHERE codigo_producto = p_codigo_producto;
        p_out:=1;
END sp_patch_prod;
/
COMMIT;

VARIABLE p_out NUMBER;
VARIABLE p_cursor REFCURSOR;

EXEC SP_GET_PRODUCTO('FER-12345', :p_out, :p_cursor);

PRINT p_out;
PRINT p_cursor;
        
