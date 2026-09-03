# Edición táctil del plano general

El editor del plano es compartido por Basic Scanner, ARCore y ARKit. No modifica
el esquema de proyectos históricos: conserva puntos ordenados, `isClosed` y
las aberturas existentes. Las coordenadas guardadas siguen expresadas en metros.

## Uso

- Basic, ARCore y ARKit no muestran botones Puerta/Ventana durante el escaneo.
  Primero se mide y cierra el contorno; después las aberturas se agregan desde
  el plano general para evitar dos flujos de colocación distintos.
- La barra inferior reúne Ambientes registrados, Agregar puerta, Agregar ventana,
  Deshacer y Rehacer. Se adapta al ancho disponible; en pantallas pequeñas puede
  desplazarse verticalmente sin cubrir el plano.
- Tocá una pared para seleccionarla. Si pertenece a varios ambientes, elegí cuál
  editar. La regla también activa la selección sobre el mismo plano.
- Arrastrá la pared seleccionada para desplazarla en paralelo, o tocá y arrastrá
  una esquina. Las esquinas se ajustan a puntos o paredes reales de otros
  ambientes dentro de un radio táctil de 16 píxeles.
- Editar medidas mantiene fija la esquina inicial de la pared seleccionada.
  El diálogo usa metros o pies/pulgadas según la configuración de unidades.
  La propuesta se muestra en el mismo plano antes de confirmar.
- Eliminar pared muestra el tramo en rojo antes de confirmar. Quita sus
  aberturas y deja el contorno abierto, sin inventar una pared de reemplazo.
  Si se corta un tramo intermedio de un contorno abierto, conserva ambos
  fragmentos con identificadores distintos.
- Eliminar ambiente está disponible al seleccionar una pared o esquina, y en
  **Ambientes registrados → menú de tres puntos → Eliminar ambiente**.
  Sirve también para restos sin paredes o sin puntos. Requiere confirmación y
  puede deshacerse durante la sesión; conserva las habitaciones vecinas y
  desconecta sus aberturas. Borrar paredes una por una no elimina por sí solo
  el registro del ambiente: usá esta acción para quitar también su nombre.
- Cerrar habitación propone el punto o la proyección sobre pared más cercanos
  que permitan un cierre válido. El trazado completo aparece en verde.
  Para apoyarse en una pared vecina debe existir un recorrido continuo por
  sus bordes hasta el inicio; no se agrega un puente invisible. Si ese recorrido
  no existe, puede proponerse el primer punto del contorno, siempre con vista
  previa. Se rechazan cruces, retornos degenerados y superposición de interiores.
- Agregar puerta/ventana permite tocar la pared destino y luego ajustar posición,
  ancho, altura y antepecho en el diálogo táctil existente.

## Protección de datos y conexiones

Las aberturas se trasladan con su pared conservando ancho, altura y orientación.
Se rechazan paredes demasiado cortas o aberturas que se superpongan tras editar.
Mover una abertura que conecta ambientes exige mover el grupo con la herramienta
existente o quitar primero esa conexión: el editor no descalza silenciosamente
su contraparte. Al borrar su pared, la abertura de la habitación vecina se
conserva y queda desconectada. Deshacer restaura ambas habitaciones.

Las modificaciones se guardan como instantáneas en el historial existente
(máximo 50 operaciones por sesión). Una propuesta antigua no se aplica si el
proyecto cambió entre la vista previa y la confirmación. El historial no persiste
al reiniciar la app. Los contornos abiertos no aportan superficie ni se rellenan
como habitaciones cerradas.

## Verificación

Las pruebas cubren geometría, cierres por pared vecina, borrado/desconexión,
historial, selección táctil, arrastre y barra inferior en español/inglés.
Las pruebas automatizadas no sustituyen la validación del APK Android ni del
dispositivo iOS. Probar primero con una copia del proyecto, incluyendo cerrar
diálogos, deshacer/rehacer, reabrir el proyecto y exportar contornos abiertos.
