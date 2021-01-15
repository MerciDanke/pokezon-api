![](https://img.shields.io/badge/Ruby-2.7.2-green)

# Pokézon Web API
Web API that combines pokémon and related Google Shopping products to ranked each pokémon's popularity level
## Routes
### Root check
`GET /`

Status
- 200: API server running (happy)

### Pokémon intro and its popularity
`GET api/v1/pokemon`

Status
- 200: Return all the pokémon basic info and its popularity (happy)
- 500: Having trouble accessing the database (bad)

### Classify Pokémon by different conditions
`GET api/v1/pokemon?color=xx&type_name=xx&habitat=xx&low_h=xx&high_h&low_w=xx&high_w=xx`

### Store Google Shopping products
`GET api/v1/products/{poke_name}`

Status
- 200: Return products (happy)
- 202: Search products and store in database (happy)
- 404: pokémon not found (sad)
- 500: problems storing the products/accessing the database (bad)

### Sort Google Shopping products
`GET api/v1/products/{poke_name}?sort=id`
`GET api/v1/products/{poke_name}?sort=likes_DESC(ASC)`
`GET api/v1/products/{poke_name}?sort=rating_DESC(ASC)`
`GET api/v1/products/{poke_name}?sort=price_DESC(ASC)`
- 200: Return sorted products (happy)
- 404: pokémon not found (sad)
- 500: problems accessing the database (bad)
### Plus likes of Pokémon & Google Shopping products
`PUT api/v1/pokemon/{id}/likes`
- 200: plus a like to pokemon successfully (happy)
- 500: Having trouble accessing the database (bad)
`PUT api/v1/product/{id}/likes`
- 200: plus a like to product successfully (happy)
- 500: Having trouble accessing the database (bad)