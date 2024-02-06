# basic-gallery

La aplicación permite a los usuarios acceder a su biblioteca de imágenes y seleccionar las que deseen visualizar en la aplicación. Una vez seleccionadas, las imágenes pueden ser vistas en detalle, con la capacidad de hacer zoom, además de poder acceder a información detallada sobre cada imagen.

La aplicación consta de dos módulos principales:

### Galería (Inicio):

Este módulo permite al usuario navegar por su biblioteca de imágenes y seleccionar las de su preferencia. Las imágenes seleccionadas se guardan en un directorio temporal, mientras que se almacena una referencia a ellas en UserDefaults. El módulo ofrece botones para eliminar todas las imágenes, agregar nuevas imágenes y, además, al mantener presionada una imagen, se despliega una opción para eliminarla individualmente.

![View empty](/Simulator Screenshot - iPhone 15 Pro Max - 2024-02-06 at 15.19.29.png)
![View add image](/Simulator Screenshot - iPhone 15 Pro Max - 2024-02-06 at 15.19.38.png)

### Vista Detallada:

Esta vista muestra la imagen seleccionada junto con su título, y ofrece dos botones adicionales: "Eliminar Imagen" e "Información de la Imagen". El botón de información despliega detalles acerca de la imagen actual. La vista detallada también permite hacer zoom mediante gestos y con doble toque.

![View image detail](/Simulator Screenshot - iPhone 15 Pro Max - 2024-02-06 at 15.19.48.png)
![View info](/Simulator Screenshot - iPhone 15 Pro Max - 2024-02-06 at 15.19.58.png)

Toda la aplicación está construida en Swift y UIKit, utilizando la arquitectura VIPER por sus beneficios en modularidad y escalabilidad.
