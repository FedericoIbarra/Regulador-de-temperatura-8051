<h1>Descripción del proyecto</h1>
Nuestro proyecto es una propuesta para el control de la temperatura un determinado lugar, el usuario puede establecer un rango de temperatura adecuado.
Para insertar los datos del rango se utiliza un teclado el cual recibe dos número entre el 0 y el 9 donde el primer número son las decenas de grados y el segundo son las unidades, para establecer qué dato se quiere modificar existe un botón el cual prende un LED verde si se trata de cambiar la temperatura mínima y se apaga si se está configurando la temperatura máxima.
Así mismo, la información de ‘temperatura actual’, el rango máximo y el mínimo son mostrados en una pantalla LCD de 16x2.

<h2>Desarrollo</h2>
Para el desarrollo de este proyecto utilizamos los siguientes componentes
<ul>
<li>Microcontrolador (AT89S52)</li>
<li>Resistencias de 330Ω , 1kΩ y 10kΩ</li>
<li>LED verde</li>
<li>LDC 16x2 (JHD 162A)</li>
<li>Push Buttons</li>
<li>Capacitores de 33pF, 100nF, 1uF</li>
<li>NOP lógico (74LS04)</li>
<li>ADC 0809CNN</li>
<li>Decodificador de teclado (MM74C922)</li>
<li>Sensor de temperatura analogico (LM35)</li>
<li>Relevadores (RAS-06 01 / RAS-05 01)</li>
</ul>

Uno de los aspectos más complejos de esta práctica fue controlar el ADC y el teclado al mismo tiempo, utilizamos interrupciones en los dos pero nos daba problemas de segmentación de código entonces fue cuando decidimos optar por manejar el ADC por pulling y apagando la interrupción del teclado. También optamos por conectar ambos componentes (922 y ADC) al puerto 1 y multiplexarlos, esto fue con el fin de ahorrarnos entradas en el micro, esto fue posible ya que el Output Enable de los chips es diferente, el del 922 es activo en bajo y el del ADC es activo en alto.
Otra de las cuestiones que nos generó fue el cableado y la decodificación del ADC, sin embargo después de leer los manuales y de entender cómo funciona pudimos ver lo que estaba mandando con la ayuda de un multímetro y de un ‘logic port’ casero.
	
<h2>Problemas encontrados</h2>
	Dejando a un lado los componentes quemados, los principales problemas fue conectar correctamente el ADC como se comentaba anteriormente y hacer correctamente los pulsos que éste necesitaba para su correcto funcionamiento. Otro problema fue sincronizar las interrupciones y las funciones para que los punteros de estos no se cruzaran y causaran problemas.
	Otro problema menor fue entender cómo conectar los componentes de 12V para no poner en riesgo la integridad de los otros componentes, al final optamos por utilizar relevadores para este problema.
	La manipulación de datos en formato decimal complicó un poco las cosas sin embargo se logró mediante un sencillo algoritmo de divisiones con los acumuladores.
