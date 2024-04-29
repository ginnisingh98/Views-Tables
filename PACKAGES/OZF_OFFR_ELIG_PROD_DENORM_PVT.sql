--------------------------------------------------------
--  DDL for Package OZF_OFFR_ELIG_PROD_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFR_ELIG_PROD_DENORM_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvodes.pls 120.4 2006/03/30 13:37:02 gramanat ship $ */


TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE char_tbl_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- FUNCTION
--    get_sql
--
-- PURPOSE
--    Retrieves SQL statment for given context, attribute.
--
-- PARAMETERS
--    p_context: product or qualifier context
--    p_attribute: context attribute
--    p_attr_value: context attribute value
--    p_type: PROD for product; ELIG for eligibity
--
-- NOTES
--   This functions returns SQL statement for the given context, attribute and attribute value.
---------------------------------------------------------------------
FUNCTION get_sql(
  p_context           IN  VARCHAR2,
  p_attribute         IN  VARCHAR2,
  p_attr_value_from   IN  VARCHAR2,
  p_attr_value_to     IN  VARCHAR2,
  p_comparison        IN  VARCHAR2,
  p_type              IN  VARCHAR2,
  p_qualifier_id      IN  NUMBER := NULL,
  p_qualifier_group   IN  NUMBER := NULL
)
RETURN VARCHAR2;


---------------------------------------------------------------------
-- PROCEDURE
--   refresh_parties
--
-- PURPOSE
--    Refreshes offer and party denorm table ams_offer_parties.
--
-- PARAMETERS
--    p_list_header_id: list_header_id of the offer
--
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for parties and refresh ams_offer_parties
---------------------------------------------------------------------
PROCEDURE refresh_parties(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_party_stmt       OUT NOCOPY VARCHAR2,
  p_qnum             IN  NUMBER := NULL
);

PROCEDURE refresh_volume_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_product_stmt     OUT NOCOPY VARCHAR2,
  p_lline_id         IN NUMBER := NULL
);

PROCEDURE refresh_lumpsum_parties(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_party_stmt       OUT NOCOPY VARCHAR2
);

PROCEDURE get_actual_values(
  p_uom_code         IN  VARCHAR2,
  p_offer_id         IN  NUMBER,
  p_org_id           IN  NUMBER,
  p_dis_as_exp       IN  VARCHAR2,
  p_curr_code        IN  VARCHAR2,
  x_actual_units     OUT NOCOPY NUMBER,
  x_actual_revenue   OUT NOCOPY NUMBER,
  x_actual_costs     OUT NOCOPY NUMBER,
  xy_actual_revenue  OUT NOCOPY NUMBER,
  xy_actual_costs    OUT NOCOPY NUMBER,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE get_forecast_values (
  p_forecast_uom_code IN  VARCHAR2,
  p_offer_id          IN  NUMBER,
  p_org_id            IN  NUMBER,
  p_dis_as_exp        IN  VARCHAR2,
  x_forecast_units      OUT NOCOPY NUMBER,
  x_forecast_revenue    OUT NOCOPY NUMBER,
  x_forecast_costs      OUT NOCOPY NUMBER,
  xy_forecast_revenue   OUT NOCOPY NUMBER,
  xy_forecast_costs     OUT NOCOPY NUMBER,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------
-- PROCEDURE
--    refresh_products
--
-- PURPOSE
--    Refreshes offer and product denorm table ams_offer_products.
--
-- PARAMETERS
--    p_list_header_id: list_header_id of the offer
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for product and refresh ams_offer_products
----------------------------------------------------------------------
PROCEDURE refresh_products(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,
  p_calling_from_den IN VARCHAR2,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_product_stmt     OUT NOCOPY VARCHAR2,
  p_lline_id         IN NUMBER := NULL
);

-------------------------------------------------------------------
-- PROCEDURE
--    refresh_offers
--
-- PURPOSE
--    Refresh denorm tables ams_offer_products and ams_offer_parties.
--
-- PARAMETERS
--    p_increment_flag: indicates where full or incremental denorm
--    p_latest_comp_date: indicates the last concurrent program run date
-- NOTES
--    This is the main procedure. It calls refresh refresh_parties and ams_products
--    to update ams_offer_parties and ams_offer_produces, respectively.
--------------------------------------------------------------------
PROCEDURE refresh_offers(
  ERRBUF           OUT NOCOPY VARCHAR2,
  RETCODE          OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  p_increment_flag IN  VARCHAR2 := 'N',
  p_latest_comp_date IN DATE,
  p_offer_id       IN NUMBER
);

-------------------------------------------------------------------
-- PROCEDURE
--    find_party_elig
--
-- PURPOSE
--    Find eligible offer for given party and offers.
--
-- PARAMETERS
--   p_offers_tbl: Input, table of qp_list_header_id of offers
--   p_party_id:   Input, party id
--   x_offers_tbl: Output, table of qp_list_header_id of offers
-- NOTES
--
--------------------------------------------------------------------
PROCEDURE find_party_elig(
  p_offers_tbl       IN  num_tbl_type,
  p_party_id         IN  NUMBER,
  p_cust_acct_id     IN  NUMBER := NULL,
  p_cust_site_id     IN  NUMBER := NULL,

  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_offers_tbl       OUT NOCOPY num_tbl_type
);

-------------------------------------------------------------------
-- PROCEDURE
--    find_products_elig
--
-- PURPOSE
--    Find eligible offer for given party and products.
--
-- PARAMETERS
--   p_products_tbl: Input, table of product_id of products
--   p_party_id:   Input, party id
--   x_offers_tbl: Output, table of qp_list_header_id of offers
--
-- NOTES
--
--------------------------------------------------------------------
PROCEDURE find_product_elig(
  p_products_tbl     IN  num_tbl_type,
  p_party_id         IN  NUMBER,
  p_cust_acct_id     IN  NUMBER := NULL,
  p_cust_site_id     IN  NUMBER := NULL,

  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_offers_tbl       OUT NOCOPY num_tbl_type
);

--------------------------------------------------------------------
-- PROCEDURE
--    get_party_product_stmt
--
-- PURPOSE
--    Generates denorm statement for budget validation.
--
-- PARAMETERS
--    p_list_header_id: list_header_id of the offer
--    x_party_stmt:     party statement for the offer
--    x_product_stmt:   product statement for the offer
-- DESCRIPTION
--  This procedure calls get_sql, builds SQL statment for product and refresh ams_offer_products
----------------------------------------------------------------------
PROCEDURE get_party_product_stmt(
  p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2  := FND_API.g_false,
  p_commit           IN  VARCHAR2  := FND_API.g_false,

  p_list_header_id   IN NUMBER,

  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,

  x_party_stmt       OUT NOCOPY VARCHAR2,
  x_product_stmt     OUT NOCOPY VARCHAR2
);


END OZF_OFFR_ELIG_PROD_DENORM_PVT;

 

/
