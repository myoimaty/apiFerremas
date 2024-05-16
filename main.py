import os
import platform
import oracledb
from fastapi import FastAPI, HTTPException
from models.producto import Producto


# Conexión a la base de datos
cone = oracledb.connect(user="ferremas1",
                        password="ferremas1",
                        host="127.0.0.1",
                        port=1521,
                        service_name="orcl")

app = FastAPI()

@app.get("/")
def mensaje_inicial():
    return {"mensaje": "Hola tilines"}

@app.get("/productos")
async def get_productos():
    try:
        cursor = cone.cursor()  # Conexión con Oracle
        out = cursor.var(int)
        cursor_productos = cursor.var(oracledb.CURSOR)
        cursor.callproc("SP_GET_PRODUCTOS", [out, cursor_productos])
        if out.getvalue() == 1:
            lista = []
            for fila in cursor_productos.getvalue():
                json = {
                    'codigo_producto': fila[0],
                    'nombre': fila[1],
                    'cod_marca': fila[2],
                    'nombre_marca': fila[3],
                    'precio': fila[4],
                    'stock': fila[5]
                }
                lista.append(json)
            return lista
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@app.get("/productos/{codigo_producto}")
async def get_producto(codigo_producto: str):
    try:
        cursor = cone.cursor()  # Conexión con Oracle
        out = cursor.var(int)
        cursor_productos = cursor.var(oracledb.CURSOR)
        cursor.callproc("SP_GET_PRODUCTO", [codigo_producto, out, cursor_productos])
        if out.getvalue() == 1:
            # Obtener el valor del cursor
            resultado_cursor = cursor_productos.getvalue()
            # Verificar que el cursor no esté vacío
            fila = resultado_cursor.fetchone()
            if fila:
                json = {
                    'codigo_producto': fila[0],
                    'nombre': fila[1],
                    'cod_marca': fila[2],
                    'nombre_marca': fila[3],
                    'precio': fila[4],
                    'stock': fila[5]
                }
                return json
            else:
                raise HTTPException(status_code=404, detail="Producto no encontrado")
        else:
            raise HTTPException(status_code=404, detail="Producto no encontrado")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()


@app.post("/productos")
async def post_producto(producto: Producto):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_INSERTAR_PROD", [
            producto.codigo_producto,
            producto.nombre,
            producto.cod_marca,
            producto.precio,
            producto.stock,
            out
        ])
        if out.getvalue() == 1:
            cone.commit()
            return producto
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@app.put("/productos/{codigo_producto}")
async def put_producto(codigo_producto: str, producto: Producto):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_PUT_PROD", [
            codigo_producto,
            producto.nombre,
            producto.cod_marca,
            producto.precio,
            producto.stock,
            out
        ])
        if out.getvalue() == 1:
            cone.commit()
            return producto
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@app.delete("/productos/{codigo_producto}")
async def delete_producto(codigo_producto: str):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_DELETE_PROD", [codigo_producto, out])
        if out.getvalue() == 1:
            cone.commit()
            return {"mensaje": "Producto eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@app.patch("/productos/{codigo_producto}")
async def patch_producto(codigo_producto: str, producto: Producto):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_PATCH_PROD", [
            producto.codigo_producto,
            producto.nombre,
            producto.cod_marca,
            producto.precio,
            producto.stock,
            out
        ])
        if out.getvalue() == 1:
            cone.commit()
            return producto
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
