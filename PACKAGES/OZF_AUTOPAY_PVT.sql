--------------------------------------------------------
--  DDL for Package OZF_AUTOPAY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_AUTOPAY_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvatos.pls 120.3 2005/12/02 04:59:42 kdhulipa ship $ */

TYPE offer_type IS RECORD
( cust_account_id number,
  amount          number,
  offer_id        number,
  adjustment_type_id number
);

g_miss_offer_rec          offer_type;
TYPE  offer_tbl_type      IS TABLE OF offer_type INDEX BY BINARY_INTEGER;
g_miss_offer_tbl          offer_tbl_type;

---------------------------------------------------------------------
-- PROCEDURE
--    Create_Claim_for_BD_Offer
--
-- PURPOSE
--    Create a claim for a backdated offer.
--
-- PARAMETERS
--    p_offer_tbl : list of offers info that a claim will be created on.
--
---------------------------------------------------------------------
PROCEDURE  Create_Claim_for_BD_Offer(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_offer_tbl              IN    offer_tbl_type
);

--------------------------------------------------------------------------------
--    API name   : Start_Autopay
--    Type       : Public
--    Pre-reqs   : None
--    Function   : Package that performs auto payment.
--    Parameters :
--
--    IN         : p_run_mode                       IN VARCHAR2  Optional
--               : p_customer_id                    IN NUMBER    Optional
--               : p_relationship_type              IN VARCHAR2   Optional
--               : p_related_cust_account_id        IN NUMBER     Optional
--               : p_buy_group_party_id             IN NUMBER     Optional
--               : p_select_cust_children_flag      IN VARCHAR2   Optional
--               : p_pay_to_customer                IN VARCHAR2   Optional
--               : p_fund_id                        IN NUMBER    Optional
--               : p_plan_type                      IN NUMBER    Optional
--               : p_offer_type                     IN VARCHAR2  Optional
--               : p_plan_id                        IN NUMBER    Optional
--               : p_product_category_id            IN NUMBER    Optional
--               : p_product_id                     IN NUMBER    Optional
--               : p_end_date                       IN VARCHAR2  Optional
--               : p_org_id                         IN NUMBER    Optional
--
--    Version    : Current version     1.0
--
--------------------------------------------------------------------------------
PROCEDURE Start_Autopay (
    ERRBUF                           OUT NOCOPY VARCHAR2,
    RETCODE                          OUT NOCOPY NUMBER,
    p_org_id                         IN NUMBER    DEFAULT NULL,
    p_run_mode                       IN VARCHAR2 := NULL,
    p_customer_id                    IN NUMBER   := NULL,
    p_relationship_type              IN VARCHAR2 := NULL,
    p_related_cust_account_id        IN NUMBER   := NULL,
    p_buy_group_party_id             IN NUMBER   := NULL,
    p_select_cust_children_flag      IN VARCHAR2  := 'N',
    p_pay_to_customer                IN VARCHAR2 := NULL,
    p_fund_id                        IN NUMBER   := NULL,
    p_plan_type                      IN VARCHAR2 := NULL,
    p_offer_type                     IN VARCHAR2 := NULL,
    p_plan_id                        IN NUMBER   := NULL,
    p_product_category_id            IN NUMBER   := NULL,
    p_product_id                     IN NUMBER   := NULL,
    p_end_date                       IN VARCHAR2,
    p_group_by_offer                 IN VARCHAR2
);

END OZF_AUTOPAY_PVT;

 

/
