--------------------------------------------------------
--  DDL for Package OZF_ALLOCATION_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_ALLOCATION_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvaegs.pls 120.1 2005/09/08 17:50:26 appldev ship $  */
   VERSION	CONSTANT CHAR(80) := '$Header: ozfvaegs.pls 120.1 2005/09/08 17:50:26 appldev ship $';

-- ------------------------
-- Public Procedures
-- ------------------------

-- ------------------------------------------------------------------
-- Name: SETUP PRODUCT SPREAD
-- Desc: 1. Setup product spread for Root Node, Normal Node and Facts
--          in the Worksheet.
--       2. Update or Delete the product spread
--       3. Add-on Quota on subsequent call
-- -----------------------------------------------------------------
PROCEDURE setup_product_spread(
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_mode               IN          VARCHAR2,
    p_obj_id             IN          NUMBER,
    p_context            IN          VARCHAR2
);

-- ------------------------------------------------------------------
-- Name: CASCADE PRODUCT SPREAD
-- Desc: 1. Cascade product spread for Creator Node to all other Nodes
--          who are part of same hierarchy.
-- -----------------------------------------------------------------
PROCEDURE cascade_product_spread(
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_mode               IN          VARCHAR2,
    p_fund_id            IN          NUMBER,
    p_item_id            IN          NUMBER,
    p_item_type          IN          VARCHAR2
);

-- ------------------------------------------------------------------
-- Name: ALLOCATE TARGET
-- Desc: 1. Allocate Target across Accounts and Products for Sales Rep
--       2. Add-on Target on subsequent call
-- -----------------------------------------------------------------
PROCEDURE allocate_target
 (
    p_api_version        IN          NUMBER,
    p_init_msg_list      IN          VARCHAR2   := FND_API.G_FALSE,
    p_commit             IN          VARCHAR2   := FND_API.G_FALSE,
    p_validation_level   IN          NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_mode               IN          VARCHAR2,
    p_fund_id            IN          NUMBER,
    p_old_start_date     IN          DATE,
    p_new_end_date       IN          DATE,
    p_addon_fact_id      IN          NUMBER,
    p_addon_amount       IN          NUMBER
);

-- ------------------------------------------------------------------
-- Name: Called from Account Spread and Product Spread UI
-- Desc: This is part of the tweaking to swap DB rows to UI columns
--       after brainstorming with ATG, Performance, Arch teams.
-- Note: Distinct allocation_for are = { CUST, PROD }
-- ------------------------------------------------------------------
FUNCTION GET_TARGET
    (
     p_allocation_for_id      IN number,
     p_time_id                IN number,
     p_allocation_for         IN varchar2 DEFAULT 'PROD'
    ) RETURN NUMBER;

-- ------------------------------------------------------------------
-- Name: Called from Account Spread and Product Spread UI
-- Desc: This is part of the tweaking to swap DB rows to UI columns
--       after brainstorming with ATG, Performance, Arch teams.
-- Note: Distinct allocation_for are = { CUST, PROD }
-- ------------------------------------------------------------------
FUNCTION GET_TARGET_PKEY
    (
     p_allocation_for_id      IN number,
     p_time_id                IN number,
     p_allocation_for         IN varchar2 DEFAULT 'PROD'
    ) RETURN NUMBER;

-- ------------------------------------------------------------------
-- Name: Called from Account Spread and Product Spread UI
-- Desc: This is part of the tweaking to swap DB rows to UI columns
--       after brainstorming with ATG, Performance, Arch teams.
-- Note: Distinct allocation_for are = { CUST, PROD }
-- ------------------------------------------------------------------
FUNCTION GET_SALES
    (
     p_allocation_for_id      IN number,
     p_time_id                IN number,
     p_allocation_for         IN varchar2 DEFAULT 'PROD'
    ) RETURN NUMBER;

-- ------------------------------------------------------------------
-- Name: Called from Product Spread UI and from private apis
-- Desc: This function will calculate and return LYSP sales of the newly
--       added Product or Category on the Product Spread UI for ROOT fund
--       for or any ShipTo Customer
-- Note: Distinct object types are = { ROOT, CUST }
-- ------------------------------------------------------------------
FUNCTION GET_SALES
   (
    p_object_type        IN          VARCHAR2,
    p_object_id          IN          NUMBER,
    p_item_id            IN          NUMBER,
    p_item_type          IN          VARCHAR2,
    p_time_id            IN          NUMBER
   ) RETURN NUMBER;

-- ------------------------
-- Public Function
-- ------------------------
-- ------------------------------------------------------------------
-- Name: Called from Quota Create APIs
-- Desc: This is for checking if product allocation for a particular
--       fund is already done.
--
-- -----------------------------------------------------------------
 FUNCTION GET_PROD_ALLOC_COUNT
    (
     p_fund_id  IN number
    ) RETURN NUMBER;

-- ------------------------
-- ------------------------
-- Public  Procedure
-- ------------------------
-- ------------------------------------------------------------------
-- Name: ADJUST_ACCOUNT_TARGETS
-- Desc: 1. Create new target allocation records,
--          when an account is newly assigned to a territory
--       2. Adjust old target allocation records,
--          when an account is moved away from a territory
-- History
--   09-SEP-05       mkothari    created
--
-- -----------------------------------------------------------------
PROCEDURE adjust_account_targets
(
    x_error_number       OUT NOCOPY  NUMBER,
    x_error_message      OUT NOCOPY  VARCHAR2,
    p_terr_id            IN          NUMBER := NULL
);

END OZF_ALLOCATION_ENGINE_PVT;

 

/
