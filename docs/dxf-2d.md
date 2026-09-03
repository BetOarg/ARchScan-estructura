# Exportación DXF 2D / 2D DXF export

## Español

En el plano general: **Más opciones → Exportar DXF 2D (metros)**.
El archivo se genera localmente y se guarda o comparte con el menú del sistema.
Disponible en el plano común de Basic, ARCore y ARKit.

- Formato ASCII DXF AutoCAD 2000 (AC1015).
- Las unidades del DXF siguen el idioma activo de la app, independientemente
  del selector de unidades: español exporta metros (`$INSUNITS=6`);
  inglés exporta pulgadas (`$INSUNITS=1`) con medidas en pies y pulgadas.
  Si el CAD pregunta por las unidades, seleccionar las del archivo.
- Coordenadas, radios, símbolos y tamaños de texto se convierten juntos.
  Los proyectos guardados y el JSON no cambian: siguen usando metros.
- Coordenadas del escáner X/Z pasan a X/Y de CAD; elevación CAD cero.
- Capas estables: WALLS, DOORS, WINDOWS, ROOM_NAMES, MEASUREMENTS.
- Entidades editables LINE, ARC y TEXT. No contiene imágenes raster.
- Se recortan los huecos de aberturas y se deduplican tramos de paredes
  coincidentes, incluidos solapes parciales collineales.
- Las medidas son textos en metros o pies y pulgadas, según el idioma, **no cotas DIMENSION asociativas**:
  no se actualizan automáticamente al editar la geometría en CAD.
- La separación entre líneas del símbolo de ventana es gráfica; no es un
  espesor medido.
- Los nombres conservan caracteres mediante escapes Unicode; su apariencia
  depende de las fuentes del programa CAD receptor.

No es DWG, un modelo BIM ni un archivo georreferenciado. No conserva alturas,
antepechos, relaciones de conexión ni todos los metadatos del proyecto.
Para preservar y reimportar el proyecto completo, conservar también su JSON.
Esta versión no incorpora importación DXF.

### Verificación antes de usarlo profesionalmente

1. Abrir el archivo exportado en el CAD de destino y comprobar una pared conocida.
2. Revisar orientación, puertas y encuentros de paredes compartidas.
3. Revisar caracteres especiales y visibilidad de las capas.
4. Si se necesita DWG, guardar desde un programa que admita ese formato.

Las pruebas automatizadas del exportador no sustituyen la apertura real en CAD.

## English

Use **More options → Export DXF 2D (feet and inches)** in the general floor plan.
The drawing is generated locally and shared through the system menu.

AutoCAD 2000 ASCII DXF; scanner X/Z mapped to CAD X/Y. With the app in English,
model-space coordinates use inches and labels show feet and inches, rounded
to the nearest 1/16 inch. Coordinates retain their precision.
With the app in Spanish, coordinates and labels use meters.
This follows the app language, not the measurement-unit selector.
If the receiving CAD asks for English-export units, choose inches.
Both exports represent the same physical size; saved projects and JSON remain in meters.
Editable LINE, ARC and TEXT entities are separated into the layers listed above.
Measurements are non-associative text; window line spacing is symbolic.
Keep the JSON backup for complete project metadata and reimport.
DXF import is not included. Validate scale, orientation and layers in the target
CAD application before professional use or conversion to DWG.
