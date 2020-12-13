# Pokézon Web API
Web API that combines pokemon and related Amazon products to ranked each pokemon's popularity level
## Routes
### Root check
`GET /`

Status:
- 200: API server running (happy)

### Pokemon intro and its popularity
`GET /pokemons/{poke_name}`

Status
- 200: appraisal returned (happy)
- 404: pokemon not found (sad)
- 500: problems finding that pokemon's Amazon products in db or popularity (bad)

### Store Amazon products
`POST /products/{poke_name}`

Status
- 201: products stored (happy)
- 404: pokemon not found (sad)
- 500: problems storing the products (bad)
