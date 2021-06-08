# PADFED Chaincode

- Nombre: `padfedcc`
- Lenguaje: `Golang`

---

### version 1.0.0 - 2021 junio

- agrega [puntosventa](../model/README.md#personapuntosventa)

- aplica controles mas estrictos sobre el formato de las keys

- corrige los codigos de las provincias LA RIOJA, SANTIAGO DEL ESTERO y TUCUMAN que responden las functions `GetOrganizacion` y `GetOrganizacionAll`.

---

### version 0.8.8 - 2020 abril

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
