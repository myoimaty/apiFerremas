import os
import platform
import oracledb
from fastapi import FastAPI, HTTPException, Query
from models.producto import Producto
from typing import List, Optional

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
async def get_productos(nombre: Optional[str] = Query(None, min_length=3, max_length=50)):
    try:
        cursor = cone.cursor()
        productos = []
        
        if nombre:
            out = cursor.var(int)
            cursor_productos = cursor.var(oracledb.CURSOR)
            cursor.callproc("sp_get_productos_por_nombre", [nombre, out, cursor_productos])
            if out.getvalue() == 1:
                for fila in cursor_productos.getvalue():
                    json = {
                        'id': fila[0],
                        'nombre': fila[1],
                        'cod_marca': fila[2],
                        'nombre_marca': fila[3],
                        'precio': fila[4],
                        'stock': fila[5],
                        'imagen_url': fila[6]
                    }
                    productos.append(json)
        else:
            out = cursor.var(int)
            cursor_productos = cursor.var(oracledb.CURSOR)
            cursor.callproc("sp_get_productos", [out, cursor_productos])
            if out.getvalue() == 1:
                for fila in cursor_productos.getvalue():
                    json = {
                        'id': fila[0],
                        'nombre': fila[1],
                        'cod_marca': fila[2],
                        'nombre_marca': fila[3],
                        'precio': fila[4],
                        'stock': fila[5],
                        'imagen_url': fila[6]
                    }
                    productos.append(json)
        return productos
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@app.get("/productos/{id}")
async def get_producto(id: str):
    try:
        cursor = cone.cursor()  # Conexión con Oracle
        out = cursor.var(int)
        cursor_productos = cursor.var(oracledb.CURSOR)
        cursor.callproc("SP_GET_PRODUCTO", [id, out, cursor_productos])
        if out.getvalue() == 1:
            # Obtener el valor del cursor
            resultado_cursor = cursor_productos.getvalue()
            # Verificar que el cursor no esté vacío
            fila = resultado_cursor.fetchone()
            if fila:
                json = {
                    'id': fila[0],
                    'nombre': fila[1],
                    'cod_marca': fila[2],
                    'nombre_marca': fila[3],
                    'precio': fila[4],
                    'stock': fila[5],
                    'imagen_url': fila[6]
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
            producto.id,
            producto.nombre,
            producto.cod_marca,
            producto.precio,
            producto.stock,
            producto.imagen_url,
            out
        ])
        if out.getvalue() == 1:
            cone.commit()
            return producto
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@app.put("/productos/{id}")
async def put_producto(id: str, producto: Producto):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_PUT_PROD", [
            id,
            producto.nombre,
            producto.cod_marca,
            producto.precio,
            producto.stock,
            producto.imagen_url,
            out
        ])
        if out.getvalue() == 1:
            cone.commit()
            return producto
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@app.delete("/productos/{id}")
async def delete_producto(id: str):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_DELETE_PROD", [id, out])
        if out.getvalue() == 1:
            cone.commit()
            return {"mensaje": "Producto eliminado"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()

@app.patch("/productos/{id}")
async def patch_producto(id: str, stock: int):
    try:
        cursor = cone.cursor()
        out = cursor.var(int)
        cursor.callproc("SP_PATCH_PROD", [
            id,  # Pasar el ID del producto como parte de la lista de parámetros
            stock,  # Pasar el nuevo stock
            out
        ])
        if out.getvalue() == 1:
            cone.commit()
            return {"mensaje": "Stock actualizado correctamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        cursor.close()
