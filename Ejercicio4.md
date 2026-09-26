## 4.1 Requisitos ampliados

Una clínica veterinaria quiere llevar el control de sus pacientes (mascotas), dueños, citas y tratamientos. Al no tener un sistema establecido,
esto genera problemas como: dificultad para encontrar el historial médico completo de una mascota, duplicidad de información de los dueños, pérdida
de citas por falta de recordatorios, y dificultad para saber qué vacunas o tratamientos le corresponden a cada mascota y cuándo. Se necesita una base
de datos que centralice la información de dueños, mascotas, veterinarios, citas y tratamientos, para agilizar la atención y llevar un historial confiable de cada paciente.

Los requisitos ampliados (restricciones de cardinalidad específicas, entidades que dependen de otras, categorías dentro de las entidades principales,
y relaciones que involucran más de dos entidades) se detallan a continuación en la sección 4.2.

## 4.2 Conceptos del Modelo Extendido

### Restricciones de cardinalidad específicas

- **Dueño – Tiene – Mascota : (1,N) : (0,1)** — un dueño solo se registra si tiene al menos una mascota (mínimo 1), y puede tener varias a lo largo
-  del tiempo (máximo N). Una mascota puede no tener dueño registrado (caso de animales callejeros atendidos), por lo que su mínimo es 0, y solo puede
-   pertenecer a un dueño a la vez (máximo 1).

- **Mascota – Tiene – Cita : (0,N) : (1,1)** — una mascota puede no tener ninguna cita aún, o puede tener muchas a lo largo de su historial. Una cita,
  en cambio, siempre pertenece exactamente a una mascota.

- **Veterinario – Atiende – Cita : (0,N) : (1,1)** — un veterinario puede no tener citas asignadas todavía, o atender muchas a lo largo del tiempo
  . Cada cita, sin embargo, debe ser atendida por exactamente un veterinario.

- **Cita – Recibe – Tratamiento : (0,N) : (1,1)** — una cita puede no generar ningún tratamiento, o puede generar varios
  (por ejemplo, si se recetan distintos medicamentos o procedimientos en la misma consulta). Un tratamiento, en cambio, siempre corresponde exactamente a una cita.

### Entidades que dependen de otras (entidades débiles)

- **Tratamiento** — dependencia de **existencia**: un tratamiento no puede registrarse en el sistema si no existe una cita en la cual se haya recetado.
  Sin embargo, se identifica con su propio `codigo_de_tratamiento`, sin necesitar la clave de Cita para ello.

- **Cita** — dependencia de **identificación**: el `codigo_de_cita` se reinicia por cada mascota (cada mascota lleva su propia numeración de citas: 1, 2, 3...).
  Por lo tanto, para identificar una cita de forma única se necesita combinar `codigo_de_cita` + `codigo_mascota`, ya que ese número por sí solo se repite entre distintas mascotas.

### Categorías o tipos dentro de las entidades principales

**Superclase:** Veterinario — **Subtipos:** Cirujano, Dermatólogo (Especialización)

- **Cirujano:** atributos propios — `num_cirugias_certificadas`, `tipo_anestesia_autorizada`.
- **Dermatólogo:** atributos propios — `certificacion_dermatologia`, `tipo_padecimientos_tratados`.
- **Restricción de disyunción:** SOLAPADA — un mismo veterinario puede certificarse tanto en cirugía como en dermatología al mismo tiempo,
  ya que son capacitaciones independientes entre sí.
- **Restricción de completitud:** PARCIAL — pueden existir veterinarios generales en el sistema que no tengan ninguna especialidad registrada.

**Superclase:** Mascota — **Subtipos:** Perro, Gato (Generalización)

- **Perro:** atributos propios — `raza_especifica`, `nivel_actividad`.
- **Gato:** atributos propios — `color_pelaje`, `es_domestico`.
- **Restricción de disyunción:** DISJUNTA — una mascota específica no puede ser Perro y Gato al mismo tiempo.
- **Restricción de completitud:** PARCIAL — pueden existir mascotas de otras especies (aves, reptiles) que no caen en ninguno de estos dos subtipos.

### Relaciones que involucran más de dos entidades

No se identificó una relación estrictamente ternaria en este modelo. Sin embargo, se identificó un caso de **agregación**: la relación Veterinario–Atiende–Cita 
puede tratarse como una unidad para conectarse, a su vez, con la entidad Tratamiento (el tratamiento recetado corresponde específicamente a la combinación de ese 
veterinario atendiendo esa cita en particular, no a la cita o al veterinario por separado).

## 4.4 Justificación

### Por qué las entidades débiles no pueden existir de forma independiente

**Tratamiento** no puede existir por sí solo porque, por regla de negocio, un tratamiento siempre se aplica dentro de una cita específica: 
no tiene sentido registrar un tratamiento "en el aire", sin saber en qué consulta se recetó. Su existencia depende directamente de que exista primero la Cita que lo origina.

**Cita** tampoco puede existir de forma independiente, por dos razones combinadas: primero, porque no puede haber una cita sin una mascota a la cual atender; 
y segundo, porque su propio identificador (`codigo_de_cita`) se numera de forma independiente por cada mascota (cada una lleva su propio conteo de citas 1, 2, 3...). 
Esto significa que Cita no solo depende de Mascota para existir, sino también para poder ser identificada de forma única, ya que un mismo número de cita se repite entre distintas mascotas.

### Por qué se eligió cada tipo de especialización

**Mascota (disjunta, parcial):** se eligió disjunta porque, en la realidad, un animal específico pertenece a una sola especie a la vez, no puede ser Perro y Gato 
simultáneamente, son categorías mutuamente excluyentes. Se eligió parcial porque el sistema puede recibir mascotas de otras especies (aves, reptiles, etc.) que no están 
contempladas dentro de los subtipos definidos, por lo que no toda mascota está obligada a caer en Perro o Gato. Se eligió generalización porque se partió de las subclases 
para formar a la superclase.

**Veterinario (solapada, parcial):** se eligió solapada porque, a diferencia de la especie de una mascota, las especialidades médicas no son mutuamente excluyentes: 
un mismo veterinario puede certificarse tanto en cirugía como en dermatología al mismo tiempo, ya que son capacitaciones independientes entre sí. Se eligió parcial 
porque pueden existir veterinarios generales en la clínica que no cuenten con ninguna de estas dos especialidades registradas. Se eligió especialización porque se partió 
de la superclase para crear a las subclases.

### Cómo las cardinalidades reflejan las reglas del negocio

**Dueño–Tiene–Mascota (1,N):(0,1):** refleja que la clínica solo registra a un dueño cuando trae al menos una mascota (de ahí el mínimo 1 del lado de Dueño), 
pero acepta atender mascotas sin dueño conocido, como animales callejeros (de ahí el mínimo 0 del lado de Mascota).

**Mascota–Tiene–Cita (0,N):(1,1):** refleja que una mascota puede apenas estar siendo registrada sin tener citas todavía, pero que toda cita, una vez creada, 
pertenece siempre a una sola mascota, sin ambigüedad.

**Veterinario–Atiende–Cita (0,N):(1,1):** refleja que un veterinario recién contratado puede no tener citas asignadas aún, pero que ninguna cita puede quedar 
sin un veterinario responsable que la atienda.

**Cita–Recibe–Tratamiento (0,N):(1,1):** refleja que una consulta puede no derivar en ningún tratamiento (por ejemplo, una revisión de rutina sin hallazgos), o 
puede derivar en varios, pero todo tratamiento registrado siempre corresponde a una cita específica.

### Tres consultas que permite el modelo extendido y que un modelo básico no podría resolver

1. **"Listar los veterinarios certificados simultáneamente en cirugía y dermatología."** Esto solo es posible gracias a la especialización solapada de Veterinario,
   que permite que una misma instancia pertenezca a dos subtipos a la vez, cada uno con sus propios atributos de certificación. Un modelo sin especialización tendría
   todos los atributos mezclados en una sola tabla de Veterinario, sin forma clara de distinguir combinaciones de especialidades.

2. **"Obtener el diagnóstico de la cita número 2 de la mascota con código M045."** Esta consulta depende directamente de la estructura de entidad débil de Cita,
   donde el identificador real es la combinación `codigo_mascota` + `codigo_de_cita`. Sin ese diseño, sería necesario un identificador global de cita sin relación clara
   con el conteo por mascota, perdiendo esta forma natural de consulta.

3. **"Consultar qué medicamento se recetó cuando el veterinario V03 atendió la cita C002 de la mascota M045."** Esta consulta requiere el concepto de agregación
   (Veterinario–Atiende–Cita tratado como una unidad conectada a Tratamiento), ya que el medicamento no pertenece únicamente al veterinario ni únicamente a la cita,
   sino específicamente a esa combinación particular. Sin agregación, no habría forma de asociar el tratamiento al hecho conjunto de "ese veterinario atendiendo esa
   cita en particular".


    
