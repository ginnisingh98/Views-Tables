--------------------------------------------------------
--  DDL for Package CST_MGD_INFL_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_MGD_INFL_ADJUSTMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTPIADS.pls 120.1 2006/01/10 18:51:00 vjavli noship $ */

--===================
-- TYPES
--===================
TYPE Inflation_Adjustment_Rec_Type IS RECORD
( country_code           VARCHAR2(2)
, organization_id        NUMBER
, acct_period_id         NUMBER
, inventory_item_id      NUMBER
, category_id            NUMBER
, category_set_id        NUMBER
, last_update_date       DATE
, last_updated_by        NUMBER
, creation_date          DATE
, created_by             NUMBER
, last_update_login      NUMBER
, request_id             NUMBER
, program_application_id NUMBER
, program_id             NUMBER
, program_update_date    DATE
, begin_qty              NUMBER
, begin_cost             NUMBER
, begin_inflation_adj    NUMBER
, purchase_qty           NUMBER
, purchase_cost          NUMBER
, actual_qty             NUMBER
, actual_cost            NUMBER
, actual_inflation_adj   NUMBER
, issue_qty              NUMBER
, issue_cost             NUMBER
, issue_inflation_adj    NUMBER
, inventory_adj_acct_cr  NUMBER
, inventory_adj_acct_dr  NUMBER
, monetary_corr_acct_cr  NUMBER
, sales_cost_acct_dr     NUMBER
, Historical_Flag        VARCHAR2(1)
, item_unit_cost         NUMBER
);


--===================
-- PUBLIC PROCEDURES
--===================

--========================================================================
-- PROCEDURE : Create_Historical_Cost  PUBLIC
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_historical_infl_adj_rec Historical data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : User use this API to create historical inflation
--             adjustment data
--========================================================================
PROCEDURE Create_Historical_Cost (
  p_api_version_number      IN  NUMBER
, p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_historical_infl_adj_rec IN  Inflation_Adjustment_Rec_Type
);


--========================================================================
-- PROCEDURE : Delete_All_Historical_Costs PUBLIC
-- PARAMETERS: p_api_version_number    known api version error buffer
--             p_init_msg_list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : User use this API to refresh the inflation adjustment
--             process
--========================================================================
PROCEDURE Delete_All_Historical_Costs (
  p_api_version_number IN  NUMBER
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
);


END CST_MGD_INFL_ADJUSTMENT_PUB;

 

/
