# PADFED - Blockchain - Modelo de Datos

Especificación del modelo de datos de la implementación basada en blockchain de Padrón Federal.

## Registro de cambios

| Autor         | Fecha       | Comentario                                                    |
| -------------- | ---------- | ---------------------------------------------------------- |
| Fabian Varisco | 2019-05-17 | Cambios en domicilio y actividades, se agrego org. Mas ejemplos. | 
| Pablo Lalloni  | 2019-05-08 | Revisión de máximos, mínimos y ajustes generales |
| Fabian Varisco | 2019-04-30 | Versión inicial |

## Convenciones generales

- **min** y **max**: Para los strings son longitudes y para los integers son valores.
- **ds**: Fecha de la más reciente modificación del registro en la base de datos de AFIP.

### Formatos

- **#organismo**: Es el código de organismo que puede ser `1` AFIP, `900` COMARB, `901` AGIP, `902` ARBA, etc.
- **#fecha**: Es la representación textual de una fecha con formato `YYYY-MM-DD` y los valores de `DD`, `MM` y `YYYY` deben cumplir las reglas de fechas de calendario estándar.
- Períodos:
  - **#periodomensual**: Formato `YYYYMM`, donde `MM` debe estar en rango [`00`, `12`] e `YYYY` debe estar en el rango [`1000`,`9999`].
  - **#periododiario**: Formato `YYYYMMDD`, donde `MM` debe estar en rango [`00`, `12`] y `DD` puede debe ser `00` si el `MM` es `00` o bien estar en el rango [`01`,`NN`] donde `NN` es la cantidad de días correspondiente al mes `MM` e `YYYY` debe estar en el rango [`1000`,`9999`].

## Objeto: Persona - Persona

### Datos comunes

| name     | type     | enum       | min | max | req |
| -------- | -------- | ---------- | --- | --- | --- |
| id       | #cuit    |            |     |     | x   |
| tipoid   | string   | C, E, I, L |     |     | x   |
| tipo     | string   | F, J       |     |     | x   |
| estado   | string   | A, I       |     |     | x   |
| pais     | integer  |            | 100 | 999 |     |
| activoid | #cuit    |            |     |     |     |
| ch       | []string |            |     |     |     |
| ds       | #fecha   |            |     |     |     |

Aclaraciones:

- **activoid**: nueva cuit que se le asignó a la persona
- **ch**: array de nombres de campos cuyos valores fueron modificados en la mas reciente tx

### Datos de personas físicas

| name             | type    | enum | min | max | req |
| ---------------- | ------- | ---- | --- | --- | --- |
| apellido         | string  |      | 1   | 200 | x   |
| nombre           | string  |      | 1   | 200 |     |
| materno          | string  |      | 1   | 200 |     |
| sexo             | string  | M, F |     |     |     |
| documento        | object  |      |     |     |     |
| documento.tipo   | integer |      | 1   | 99  | x   |
| documento.numero | string  |      |     |     | x   |
| nacimiento       | #fecha  |      |     |     |     |
| fallecimiento    | #fecha  |      |     |     |     |

Aclaraciones:

- **materno**: apellido materno

### Datos de personas jurídicas

| name                 | type    | enum | min | max          | req |
| -------------------- | ------- | ---- | --- | ------------ | --- |
| razonsocial          | string  |      | 1   | 200          | x   |
| formajuridica        | integer |      | 1   | 999          |     |
| mescierre            | integer |      | 1   | 12           |     |
| contratosocial       | #fecha  |      |     |              |     |
| duracion             | integer |      | 1   | 999          |     |
| inscripcion          | object  |      |     |              |     |
| inscripcion.registro | integer |      | 1   | 99           |     |
| inscripcion.numero   | integer |      | 1   | 999999999999 | x   |

Aclaraciones:

- **inscripcion**：puede ser en IGJ (registro:1) o en otro registro público de sociedades

### Key

    per:<id>#per

### Ejemplos

#### Persona Física

Key:

    per:20000000168#per

Objeto:

```json
{
    "id": 20000000168,
    "tipoid": "C",
    "tipo": "F",
    "estado": "A",
    "nombre": "XXXXX",
    "apellido": "XXXXXX",
    "materno": "XXXXX",
    "sexo": "M",
    "nacimiento": "1963-01-01",
    "fallecimiento": "2009-08-02",
    "documento": {
        "tipo": 96,
        "numero": "XX"
    },
    "ds": "2010-02-14"
}
```

#### Persona Jurídica

Key:

    per:30120013439#per

Objeto:

```json
{
    "id": 30120013439,
    "tipoid": "C",
    "tipo": "J",
    "estado": "A",
    "razonsocial": "XXXXXXXXX XXXX XX XXXXXXXXXX XXXXXXXXXXX XXXXX",
    "formajuridica": 86,
    "mescierre": 12,
    "contratosocial": "2000-07-31",
    "inscripcion": {
        "registro": 1,
        "numero": 112345
    },
    "ds": "2008-01-21"
}
```

## Colección: Persona - Impuesto

| name             | type            | enum               | min    | max    | req |
| ---------------- | --------------- | ------------------ | ------ | ------ | --- |
| impuesto         | integer         |                    | 1      | 9999   | x   |
| estado           | string          | AC, NA, BD, BP, EX |        |        | x   |
| periodo          | #periodomensual |                    |        |        | x   |
| dia              | integer         |                    | 1      | 31     |     |
| motivo :new:     | object          |                    |        |        |     | 
| motivo.id        | integer         |                    | 1      | 999999 | x   |
| motivo.desde     | #fecha          |                    |        |        |     |
| motivo.hasta     | #fecha          |                    |        |        |     |  
| inscripcion      | #fecha          |                    |        |        |     |
| ds               | #fecha          |                    |        |        |     |

Key:

    per:<id>#imp:<impuesto>

### Ejemplos

#### Impuesto Activo (estado AC) 

Key:

    per:20000000168#imp:20

Objeto:

```json
{
    "impuesto": 20,
    "periodo": 200504,
    "estado": "AC",
    "dia": 19,
    "motivo": {
        "id": 44, 
        "desde":"2005-04-20"
        },
    "inscripcion": "2005-04-20",
    "ds": "2015-12-30"
}
```

#### Impuesto con baja definitiva (estado BD)

Key:

    per:20000000168#imp:5243

Objeto:

```json
{
    "impuesto": 5243,
    "periodo": 201807,
    "estado": "BD",
    "dia": 31,
    "motivo": {
        "id": 44, 
        "desde":"2018-04-20"
        },
    "inscripcion": "2018-06-07",
    "ds": "2018-07-10"
}
```

## Colección: Persona - Domicilio

> 2018-05-17: Se agregó `org`. En esta colección se persisten los domicilios de AFIP (`org 1`) y los jurisdiccionales (`org != 1`)

| name           | type             | enum | min | max     | req |
| -------------- | ---------------- | ---- | --- | ------- | --- |
| org :new:      | #organismo       |      |     |         | x   |
| tipo           | integer          |      | 1   | 3       | x   |
| orden          | integer          |      | 1   | 9999    | x   |
| estado         | integer          |      | 1   | 99      |     |
| calle          | string           |      |     | 200     |     |
| numero         | integer          |      | 1   | 999999  |     |
| piso           | string           |      |     | 5       |     |
| sector         | string           |      |     | 200     |     |
| manzana        | string           |      |     | 200     |     |
| torre          | string           |      |     | 200     |     |
| unidad         | string           |      |     | 5       |     |
| provincia      | integer          |      | 0   | 24      |     |
| localidad      | string           |      |     | 200     |     |
| cp             | string           |      |     | 8       |     |
| nomenclador    | string           |      |     | 9       |     |
| nombre         | string           |      |     | 200     |     |
| adicional      | object           |      |     |         |     |
| adicional.tipo | integer          |      | 1   | 99      | x   |
| adicional.dato | string           |      |     | 200     | x   |
| baja           | #fecha           |      |     |         |     |
| partido        | integer          |      | 1   | 999     |     |
| partida        | integer          |      | 1   | 9999999 |     |
| ds             | #fecha           |      |     |         |     |

Aclaraciones:

- **unidad** es "Oficina, Departamento o Local"
- **nombre** es "Nombre de Fantasia"
- **partido** es el código del partido provincial
- **partida** es el número de partida inmobiliaria
- **tipo** indica el tipo de domicilio para AFIP. Una persona puede tener solamente un domcilio con tipo `1` (Fiscal para AFIP), un solo domcilio con tipo `2` (Real para AFIP) y 0 a n domicilios tipo `3`; Los domicilios jurisdiccionales (`org != 1`) siempre tienen `tipo` `3`
- **orden** comienza desde `1` para cada `org` y `tipo` 

### Key

    per:<id>#dom:<org>.<tipo>.<orden>

### Ejemplos

#### Domicilio Fiscal para AFIP

Key:

    per:20000000168#dom:1.1.1

Objeto:

```json
{
    "org": 1,
    "tipo": 1,
    "orden": 1,
    "estado": 1,
    "provincia": 1,
    "localidad": "MAR DEL PLATA SUR",
    "cp": "7600",
    "nomenclador": "1345",
    "calle": "XXXXX",
    "numero": 1000,
    "adicional": {
        "tipo": 3,
        "dato": "XXXXXXX XXXX"
    },
    "nombre": "XX XXXXXX XXXXXX",
    "ds": "2008-01-18"
}
```
## Colección: Persona - Domicilio - Rol

| name            | type       | enum | min | max  | req |
| --------------- | -------    | ---- | --- | ---- | --- |
| org             | #organismo |      | 1   | 924  | x   |
| tipo            | integer    |      | 1   | 3    | x   |
| orden           | integer    |      | 1   | 9999 | x   |
| rol             | integer    |      | 1   | 99   | x   |
| ds              | #fecha     |      |     |      |     |

### Key

    per:<id>#dor:<org>.<tipo>.<orden>.<rol>

### Ejemplo

#### Rol "Fiscal Jurisdiccional" asignado por DGR Córdoba al domicilio orden 20.

Key:

    per:20000000168#dor:904.3.20.3

Objeto:

```json
{
    "org": 906,
    "tipo": 3,
    "orden": 20,
    "rol": 3,
    "ds":"2019-05-15"
}
```

## Colección: Persona - Categoría

| name      | type            | enum   | min    | max    | req |
| --------- | --------------- | ------ | ------ | ------ | --- |
| impuesto  | integer         |        | 1      | 9999   | x   |
| categoria | integer         |        | 1      | 999    | x   |
| estado    | string          | AC, BD |        |        | x   |
| periodo   | #periodomensual |        | 100000 | 999912 | x   |
| motivo    | #motivo         |        | 1      | 999999 |     |
| ds        | #fecha          |        |        |        |     |

### Key

    per:<id>#cat:<impuesto>.<categoria>

### Ejemplos

Key:

    per:20000000168#cat:20.1

Objeto:

```json
{
    "impuesto": 20,
    "categoria": 1,
    "periodo": 200004,
    "estado": "AC",
    "ds": "2003-04-14"
}
```

## Colección: Persona - Contribución Municipal

| name      | type    | enum | min | max  | req |
| --------- | ------- | ---- | --- | ---- | --- |
| impuesto  | integer |      | 1   | 9999 | x   |
| municipio | integer |      | 1   | 9999 | x   |
| provincia | integer |      | 0   | 24   | x   |
| desde     | #fecha  |      |     |      | x   |
| hasta     | #fecha  |      |     |      |
| ds        | #fecha  |      |     |      |

### Key

    per:<id>#con:<impuesto>.<municipio>

### Ejemplos

Key:

    per:20000000168#con:5244.98

Objeto:

```json
{
    "impuesto": 5244,
    "municipio": 98,
    "provincia": 3,
    "desde": "2018-06-01",
    "hasta": "2018-07-31",
    "ds": "2018-07-10"
}
```

## Colección: Persona - Actividad

> 2018-05-17: Se agregó `org`. En esta colección se persisten los actividades de AFIP (`org 1`) y las jurisdiccionales (`org != 1` )

| name           | type    | pattern            | min | max | req |
| -------------- | ------- | ------------------ | --- | --- | --- |
| org :new:      | #organismo |                 |     |     | x   |
| actividad      | string  | "^883-[0-9]{3,8}$" |     |     | x   |
| orden          | integer |                    | 1   | 999 | x   |
| desde          | #fecha  |                    |     |     | x   |
| hasta          | #fecha  |                    |     |     |     |
| articulo       | integer |                    | 1   | 999 |     |
| ds             | #fecha  |                    |     |     |     |

Aclaraciones:

- **actividad**: compuesto por codigo de nomenclador y codigo de actividad

### Key

    per:<id>#act:<org>.<actividad>

### Ejemplos

#### Actividad primaria (orden 1) para AFIP 

Key:

    per:20000000168#act:1.883-772099

Objeto:

```json
{
    "org": 1,
    "actividad": "883-772099",
    "orden": 1,
    "desde": 201805,
    "ds": "2018-06-07"
}
```

#### Actividad secundaria (orden > 1) para AFIP

Key:

    per:20000000168#act:1.883-131300

Objeto:

```json
{
    "org": 1,
    "actividad": "883-131300",
    "orden": 3,
    "desde": 201507,
    "ds": "2015-07-22"
}
```

## Colección: Persona - Etiqueta

Se asimila a la *Caracterización* de AFIP.

| name     | type           | enum   | min      | max      | req |
| -------- | -------------- | ------ | -------- | -------- | --- |
| etiqueta | integer        |        | 1        | 9999     | x   |
| periodo  | #periododiario |        | 10000000 | 99991231 | x   |
| estado   | string         | AC, BD |          |          | x   |
| ds       | #fecha         |        |          |          |     |

### Key

    per:<id>#eti:<etiqueta>

### Ejemplos

Key:

    per:20000000168#eti:160

Objeto:

```json
{
    "etiqueta": 160,
    "periodo": 19940801,
    "estado": "AC",
    "ds": "2003-04-11"
}
```

## Colección: Persona - Teléfono

| name   | type    | enum | min | max             | req |
| ------ | ------- | ---- | --- | --------------- | --- |
| orden  | integer |      | 1   | 999999          | x   |
| pais   | integer |      | 1   | 9999            |     |
| area   | integer |      | 1   | 9999            |     |
| numero | integer |      | 1   | 999999999999999 | x   |
| tipo   | integer |      | 1   | 99              |     |
| linea  | integer |      | 1   | 999             |     |
| ds     | #fecha  |      |     |                 |     |

### Key

    per:<id>#tel:<orden>

Ejemplo:

    per:20000000168#tel:1

```json
{
    "orden": 1,
    "pais": 200,
    "area": 11,
    "numero": 99999999,
    "tipo": 2,
    "linea": 1,
    "ds": "2013-12-16"
}
```

## Coleccción: Persona - Email

| name      | type    | enum | min | max | req |
| --------- | ------- | ---- | --- | --- | --- |
| orden     | integer |      | 1   | 999 | x   |
| direccion | string  |      |     | 100 | x   |
| tipo      | integer |      | 1   | 99  |     |
| estado    | integer |      | 1   | 99  |     |
| ds        | #fecha  |      |     |     |     |

### Key

    per:<id>#ema:<orden>

### Ejemplos

Key:

    per:20000000168#ema:1

Objeto:

```json
{
    "orden": 1,
    "direccion": "XXXXXXXXXXXXXX@XXXXX.XXX.XX",
    "tipo": 1,
    "estado": 2,
    "ds": "2016-10-20"
}
```

## Colección: Persona - Relación

| name    | type    | enum | min | max | req |
| ------- | ------- | ---- | --- | --- | --- |
| persona | #cuit   |      |     |     | x   |
| tipo    | integer |      | 1   | 999 | x   |
| subtipo | integer |      | 1   | 999 | x   |
| desde   | #fecha  |      |     |     | x   |
| ds      | #fecha  |      |     |     |     |

Aclaraciones:

- **tipo**: Inicialmente será siempre `3` que son relaciones societarias.

### Key

    per:<id>#rel:<persona>.<tipo>.<subtipo>

### Ejemplos

Socio de una Sociedad Anónima.

Key:

    per:30120013439#rel:20012531001.3.4

Objeto:

```json
{
    "persona": 20012531001,
    "tipo": 3,
    "subtipo": 4,
    "desde": "2009-01-12",
    "ds": "2014-04-30"
}
```

## Colección: Persona - Jurisdiccion

| name      | type    | enum | min | max | req |
| --------- | ------- | ---- | --- | --- | --- |
| org       | #organizacion |      |  |  | x   |
| provincia | integer |      | 0   | 24  | x   |
| desde     | #fecha  |      |     |     | x   |
| hasta     | #fecha  |      |     |     |     |
| ds        | #fecha  |      |     |     |     |

### Key

    per:<id>#jur:<org>.<provincia>

### Ejemplos

#### Jurisdiccon CABA informada por COMARB

Key:

    per:30120013439#jur:900.0

Objeto:

```json
{
    "org": 900,
    "provincia": 0,
    "desde": "2019-03-01",
    "ds": "2019-05-15"
}
```

## Colección: Persona - Sede Convenio Multilateral

| name      | type    | enum | min | max | req |
| --------- | ------- | ---- | --- | --- | --- |
| provincia | integer |      | 0   | 24  | x   |
| desde     | #fecha  |      |     |     | x   |
| hasta     | #fecha  |      |     |     |     |
| ds        | #fecha  |      |     |     |     |

### Key

    per:<id>#cms:<provincia>

### Ejemplos

Key:

    per:30120013439#cms:3

Objecto:

```json
{
    "provincia": 3,
    "desde": "2019-06-23",
    "hasta": "2019-04-14",
    "ds": "2019-04-14"
}
```

## Colección: Persona - Archivo :soon:

Representará registro de archivos documentales almacenados en los sistemas de AFIP.

## Colección: Persona - Fusion :soon:

Represantará datos de fusiones empresarias en las cuales la persona tuvo participación.

## Colección: Persona - Transferencia :soon:

Represantará datos de transferencias de empresas en las cuales la persona tuvo participación.

## Colección: Persona - Escision :soon:

Represantará datos de esciciones empresarias en las cuales la persona tuvo participación.
