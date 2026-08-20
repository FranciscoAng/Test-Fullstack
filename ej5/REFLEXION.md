#### Describe un bug que hayas encontrado en producción: ¿cuál era el síntoma, ¿cuál fue la causa raíz y cómo lo resolviste?

Un sistema de facturación tardaba mucho en buscar el folio de compra si un solo dígito estaba incorrecto. El problema fue que a pesar de estar segmentado por tienda, se realizaba la búsqueda mediante el ID general en la base de datos. Al final se optimizaron las consultas con indices por tienda, monto a 2 décimas, fecha y los últimos dígitos 6 del ID general, donde estos valores se le solicitaban al usuario y mediante los 3 primeros filtros se detectaba algún error.

#### ¿Cómo integrarías un nuevo método de pago a un sistema de cobranza existente sin romper los flujos actuales?

Regularmente se utiliza el patrón de diseño Strategy, donde el método de pago se define como una interfaz y cada nueva forma de pago se crea como una nueva clase que implementa dicha interfaz.

#### ¿Qué consideraciones de seguridad tendrías al diseñar una API que procesa transacciones financieras?

#### ¿Qué experiencia tienes con sistemas ERP? Describe el módulo más complejo que hayas desarrollado o mantenido.

Programé un módulo ERP para monitorear la calidad de baños electrolíticos, con datos provenientes de un PLC y comunicación Modbus TCP/IP usando Python. El problema con estos datos al ser continuos en el tiempo, como temperatura, conductividad, PH, etc. es que es difícil saber cuál es el tiempo correcto para almacenar las lecturas en las bases de datos. En este caso se optó por realizar una lectura cada 10 min que se estuviera realizando el proceso de galvanizado.

#### Un cliente reporta que una transacción se procesó dos veces. ¿Cuál es tu proceso de diagnóstico paso a paso?

Según la fecha y hora que reporte el cliente, se revisa en los logs las peticiones entre los servicios y se determina la causa raíz, ya sea por problemas en el servicio de pagos, reenvío en la capa de red, o que la base de datos no ejecute la corrección tras interrumpirse el proceso de pago. Al final se documentan los logs que se relacionen con el incidente y se hace la corrección y liberación del saldo.

#### Describe una decisión técnica que hoy considerarías un error: ¿por qué te pareció correcta en su momento y qué te hizo cambiar de opinión?

Migrar un sistema completo a microservicios sin la correcta justificación. En un principio parece una buena decisión por su modularidad y escalabilidad, sin embargo a su vez aumenta su complejidad y es mas susceptible a fallos en la comunicación conforme se agregan más microservicios.

#### ¿Qué herramienta, librería o práctica dejaste de usar en los últimos dos años y qué fue exactamente lo que te hizo abandonarla?

Al menos comparado con mis inicios en programación, dejé de comentar el código casi línea por línea y ahora solo comento por clase y función. La lógica debería poder seguirse junto al texto redactado y las funciones de alguna librería externa se consulta en su respectiva documentación.