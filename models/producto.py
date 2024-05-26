#necesitamos un import para crear una clase
from pydantic import BaseModel, Field
#libreria para dejar campo opcional
from typing import Optional

class Producto(BaseModel):
    id: Optional[str] = None
    nombre: Optional[str] = Field(default=None, min_length=5, max_length=200)
    cod_marca: Optional[str] = None
    nombre_marca: Optional[str] = None
    precio: Optional[int] = None
    stock: Optional[int] = None
    imagen_url: Optional[str] = None