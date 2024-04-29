--------------------------------------------------------
--  DDL for Package AS_FOUNDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_FOUNDATION_PUB" AUTHID CURRENT_USER as
/* $Header: asxpfous.pls 120.1 2005/06/05 22:52:20 appldev  $ */

-- Start of Comments
--
-- NAME
--   AS_FOUNDATION_PUB
--
-- PURPOSE
--   This package is a public utility API for OSM
--
-- Procedures:
--
--
-- NOTES
--
--
-- HISTORY
--   8/6/98        Alhung        Created
--   Sept 1, 98    cklee         Added new function Get_Constant
--  06/22/99       awu           Added get_messages, get_periodNames
--  06/29/2000		Srikanth	Deleted get_messages as it is implemented in
--						as_utility_pub
-- End of Comments

-- Following are lookup tables that caller can use for.

G_AS_LOOKUPS            VARCHAR2(30) := 'AS_LOOKUPS';
G_AR_LOOKUPS            VARCHAR2(30) := 'AR_LOOKUPS';
--G_SO_LOOKUPS            VARCHAR2(30) := 'SO_LOOKUPS';
G_HR_LOOKUPS            VARCHAR2(30) := 'HR_LOOKUPS';
G_FND_COMMON_LOOKUPS    VARCHAR2(30) := 'FND_COMMON_LOOKUPS';
G_CS_LOOKUPS            VARCHAR2(30) := 'CS_LOOKUPS';

--     ***********************
--       Composite Types
--     ***********************

-- Start of Comments
--
--     Order by record: inventory_item_type
--
--    parameters:
--        inventory_item_id        Inventory item identifier
--        organization_id          Organization identifier
--        enabled_flag             Flexfield segment enabled flag
--        start_date_active        Flexfield segment start date
--        end_date_active          Flexfield segment end date
--        description              Item description
--        concatenated_segments    Concatenated Flexfield Segments
--        inventory_item_flag      Flag indicating inventory item
--        item_catalog_group_id    Item Catalog group identifier
--        Collateral_flag          Flag indicattng collateral item
--        Primary_UOM_Code         primary unit of measure code (Manufacturing)
--        Primary_Unit_of_Measure  primary stocking unit of measure (Purchasing)
--        inventory_item_status_code material status code
--        product_family_item_id   product familty identifier
--        bom_item_type            Type of item
--
--    required: None
--
--    defaults: None
--
--
-- End of Comments


TYPE inventory_item_rec_type               IS RECORD
    (
        inventory_item_id        Number        := NULL,
        organization_id          Number        := NULL,
        enabled_flag             Varchar2(1)   := NULL,
        start_date_active        date          := NULL,
        end_date_active          date          := NULL,
        description              Varchar2(240) := NULL,
        concatenated_segments    Varchar2(40)  := NULL,
        inventory_item_flag      Varchar2(1)   := NULL,
        item_catalog_group_id    Number        := NULL,
        Collateral_flag          Varchar2(1)   := NULL,
        Primary_UOM_Code         Varchar2(3)   := NULL,
        Primary_Unit_of_Measure  Varchar2(25)  := NULL,
        inventory_item_status_code Varchar2(10) := NULL,
        product_family_item_id   Number        := NULL,
        bom_item_type            Number        := NULL

    );

TYPE Inventory_Item_tbl_type       IS TABLE OF     Inventory_Item_rec_type
                                   INDEX BY BINARY_INTEGER;

G_MISS_Inventory_Item_REC              inventory_item_rec_type;


-- Start of Comments
--
--      period name record: util_period_rec_type
--
--    parameters:
--
--    required:
--
--    defaults:
--        None
-- End of Comments


TYPE util_period_rec_type is RECORD
    (
        period_name    VARCHAR2(20) := NULL,
    start_date    DATE := NULL,
    end_date    DATE := NULL
    );

G_MISS_UTIL_PERIOD_REC    util_period_rec_type;


-- Start of Comments
--
--  Util_Period Table:        util_period_tbl_type
--
-- End of Comments

TYPE util_period_tbl_type       IS TABLE OF     util_period_rec_type
                                        INDEX BY BINARY_INTEGER;

G_MISS_UTIL_PERIOD_TBL         util_period_tbl_type;




--
--    API name    : Get_Inventory_Items
--    Type        : Private
--    Function    : Get/Find invenotory items that satisfy caller specified criteria.
--
--    Pre-reqs    : None
--    Paramaeters    :
--    IN        :
--            p_api_version_number        IN NUMBER                        Required
--            p_identity_salesforce_id    IN NUMBER                        Optional
--                Default = NULL
--            p_init_msg_list             IN VARCHAR2                      Optional
--                Default = FND_API.G_FALSE
--            p_inventory_item_rec        IN Inventory_Item_Rec            Required
--
--    OUT NOCOPY /* file.sql.39 change */        :
--            x_return_status                      OUT NOCOPY /* file.sql.39 change */    VARCHAR2(1)
--            x_msg_count                          OUT NOCOPY /* file.sql.39 change */    NUMBER
--            x_msg_data                           OUT NOCOPY /* file.sql.39 change */    VARCHAR2(2000)
--            x_opp_tbl                            OUT NOCOPY /* file.sql.39 change */    AS_OPPORTUNITY_PUB.Opp_tbl_Type
--            x_returned_rec_count                 OUT NOCOPY /* file.sql.39 change */    NUMBER
--            x_next_rec_ptr                       OUT NOCOPY /* file.sql.39 change */    NUMBER
--            x_tot_rec_count                      OUT NOCOPY /* file.sql.39 change */    NUMBER
--
--    Version    :    Current version     2.0
--                    Initial version     1.0
--
--    Requirement:
--        1. p_inventory_item_rec.Organization_id is required for any search.
--           Use one of the global variables to set this criteria. Valid values are:
--           G_Collateral_Organization, G_Quote_Organization, G_Product_Organization
--
--    Limitation:
--        1. Only Inventory_item_id, Concatenated_segments, Description,
--           Collateral_flag, BOM_item_type are
--           considered criteria.  Other fields are for viewing purpose only.

PROCEDURE Get_inventory_items(  p_api_version_number      IN    NUMBER,
                                p_init_msg_list           IN    VARCHAR2
                                    := FND_API.G_FALSE,
                                p_identity_salesforce_id  IN    NUMBER,
                                p_inventory_item_rec      IN    AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE,
                                x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                                x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER,
                                x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                                x_inventory_item_tbl      OUT NOCOPY /* file.sql.39 change */   AS_FOUNDATION_PUB.inventory_item_TBL_TYPE);

--
--   This function will return constant according to the passed in constant name.
--   There is a problem referencing constants from forms. We have to create server-
--   side function that return these values.
Function Get_Constant(Constant_Name varchar2) return varchar2;

PROCEDURE Calculate_Amount( p_api_version_number      IN    NUMBER,
                            p_init_msg_list           IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
			    p_validation_level	      IN    NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            p_identity_salesforce_id  IN    NUMBER,
			    p_inventory_item_rec      IN    AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE
				 DEFAULT AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC,
			    p_secondary_interest_code_id    IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			    p_currency_code	      IN    VARCHAR2,
			    p_volume		      IN    NUMBER,
                            x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                            x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER,
                            x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
			    x_amount		      OUT NOCOPY /* file.sql.39 change */   NUMBER);

-- Start of Comments
--
--      API name        : Get_PeriodNames
--      Type            : Public
--      Function        : Provide a table of period names, start_date and end date
--              by given start_date and end_date or period name.
--
--      Paramaeters     :
--      IN              :
--                      p_api_version_number    IN      NUMBER,
--                      p_init_msg_list         IN      VARCHAR2
--
--      OUT NOCOPY /* file.sql.39 change */             :
--                      x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2(1)
--                      x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER
--                      x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2(2000)
--
--      Version :       Current version 2.0
--                      Initial version         1.0
--
--
--
-- End of Comments

PROCEDURE Get_PeriodNames
(   p_api_version_number            IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2
                      := FND_API.G_FALSE,
    p_period_rec                IN      UTIL_PERIOD_REC_TYPE,
    x_period_tbl            OUT NOCOPY /* file.sql.39 change */     UTIL_PERIOD_TBL_TYPE,
    x_return_status                 OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    x_msg_count                     OUT NOCOPY /* file.sql.39 change */     NUMBER,
    x_msg_data                      OUT NOCOPY /* file.sql.39 change */     VARCHAR2
);

END AS_FOUNDATION_PUB;

 

/
