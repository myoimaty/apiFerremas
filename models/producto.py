#necesitamos un import para crear una clase
from pydantic import BaseModel, Field
#libreria para dejar campo opcional
from typing import Optional

class Producto(BaseModel):
    id: Optional[str] = None
    nombre: str = Field(default="Nuevo Producto", min_length=5, max_length=200)
    cod_marca: str
    nombre_marca: str
    precio: int
    stock: int
    imagen_url: str