# PADFED Chaincode

- Nombre: `padfedcc`
- Lenguaje: `Golang`
---

### v1.0.5 - 2021 diciembre

- **GetStatesHistory**, por compatibiliad con Fabric 2.2 (actual LTS) se eliminó la obtención del número de bloque. Para obtenerlo desde `padfedcc` invocabamos al `qscc`, pero desde Fabric 2.0 la invocar a un chaincode desde otro quedó bloqueada y produce el error: `Rejecting invoke of QSCC from another chaincode because of potential for deadlocks`
- el nombre del package ahora es: `gitlab.cloudint.afip.gob.ar/padfed-bc-chaincode/padfed-bc-chaincode.git`.

---

### v1.0.4 - 2021 agosto

- resuelve bug panic en GetStatesHistory que ocurria en versiones 1.0.0 y 1.0.1

---

### v1.0.1 - 2021 julio

- `cms`: soporta formato legacy de la key (`{provincia}`) para permitir deletes. Desde v0.8.8 el formato de la key es `{org}.{provincia}`.

---

### v1.0.0 - 2021 junio

- agrega [puntosventa](../model/README.md#personapuntosventa)

- aplica controles mas estrictos sobre el formato de las keys

- corrige los codigos de las provincias LA RIOJA, SANTIAGO DEL ESTERO y TUCUMAN que responden las functions `GetOrganizacion` y `GetOrganizacionAll`.

---

### v0.8.8 - 2020 abril

- `cms`: agrega atributo `org` en la key y en el objeto

ejemplo de `cms` previo al cambio:

`per:30120013439#cms:3`

```json
{
    "provincia": 3,
    "desde": "2019-06-23",
    "hasta": "2019-04-14",
    "ds": "2019-04-14"
}
```

efecto del cambio implementado en v0.8.8:

`per:30120013439#cms:900.3`

```json
{
    "org": 900,
    "provincia": 3,
    "desde": "2019-06-23",
    "hasta": "2019-04-14",
    "ds": "2019-04-14"
}
```

El cambio permite determinar si el registro fue informado por la COMARB mediante el proceso de migración (`org: 900`) o si fue actualizado por el contribuyente desde la webapp de RUT (`org: 1`).
