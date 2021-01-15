# Pokézon Web API
Web API that combines pokemon and related Google Shopping products to ranked each pokémon's popularity level
## Routes
### Root check
`GET /`

Status
- 200: API server running (happy)

### Pokémon intro and its popularity
`GET /pokemon/{poke_name}`

Status
- 200: appraisal returned (happy)
- 404: pokemon not found (sad)
- 500: problems finding that pokémon's Google Shopping products in db or popularity (bad)

### Classify Pokémon by different conditions
`GET /pokemon?color=xx&type_name=xx&habitat=xx&low_h=xx&high_h&low_w=xx&high_w=xx`

### Store Google Shopping products
`GET /products/{poke_name}`

Status
- 201: products stored (happy)
- 404: pokémon not found (sad)
- 500: problems storing the products (bad)

### Sort Google Shopping products
`GET /products/{poke_name}?sort=id`

`GET /products/{poke_name}?sort=likes_DESC(ASC)`

`GET /products/{poke_name}?sort=rating_DESC(ASC)`

`GET /products/{poke_name}?sort=price_DESC(ASC)`

### Plus likes of Pokémon & Google Shopping products
`PUT /pokemon/{id}/likes`

`PUT /product/{origin_id}/likes`
