--------------------------------------------------------
--  DDL for Package AS_FOUNDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_FOUNDATION_PVT" AUTHID CURRENT_USER as
/* $Header: asxvfous.pls 120.1 2005/12/06 03:15:51 amagupta noship $ */

-- Start of Comments
--
-- NAME
--   AS_FOUNDATION_PVT
--
-- PURPOSE
--   This package is a private utility API for OSM
--
--   Procedures:
--    translate_orderBy
--    get_periodNames
--    get_lookupMeaning
--    get_unitOfMeasure
--    get_uomCode
--    get_currency
--    get_inventoryItems
--    get_messages
--
-- NOTES
--   This package is for private use only
--
--
-- HISTORY
--   07/22/98   AWU                Created
--   07/30/98   ALHUNG             Added Get_InventoryItems
--   08/6/98    ALHUNG             Moved inventory_item_rec definition
--                                 to AS_FOUNDATION_PUB
--   08/11/98   ALHUNG             Added Get_InventoryItemPrice
--   06/22/99   AWU                Added get_messages
--
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
--    currency record: util_currency_rec_type
--
--    parameters:
--
--    required:
--
--    defaults:
--        None
-- End of Comments


-- Start of Comments
--
--     Order by record: util_order_by_rec_type
--
--    parameters:
--
--    required: None
--
--    defaults: None
--
--    Notes: 1.    col_x_choice is a two or three digit number.
--        First digit represents the priority for the order by column.
--        (If priority > 10, use 2 digits to represent it)
--        Second(or third) digit represents the descending or ascending order for the query
--        result. 1 for ascending and 0 for descending.
--           2.    col_x_name is the order by column name.
--           3.    The total order by columns are ten.
--
-- End of Comments


TYPE util_order_by_rec_type               IS RECORD
    (
        col_1_choice        NUMBER        := NULL,
        col_1_name        VARCHAR2(30)    := NULL,
        col_2_choice        NUMBER        := NULL,
        col_2_name        VARCHAR2(30)    := NULL,
        col_3_choice        NUMBER        := NULL,
        col_3_name        VARCHAR2(30)    := NULL,
        col_4_choice        NUMBER        := NULL,
        col_4_name        VARCHAR2(30)    := NULL,
        col_5_choice        NUMBER        := NULL,
        col_5_name        VARCHAR2(30)    := NULL,
        col_6_choice        NUMBER        := NULL,
        col_6_name        VARCHAR2(30)    := NULL,
        col_7_choice        NUMBER        := NULL,
        col_7_name        VARCHAR2(30)    := NULL,
        col_8_choice        NUMBER        := NULL,
        col_8_name        VARCHAR2(30)    := NULL,
        col_9_choice        NUMBER        := NULL,
        col_9_name        VARCHAR2(30)    := NULL,
        col_10_choice        NUMBER        := NULL,
        col_10_name        VARCHAR2(30)    := NULL,
        col_11_choice        NUMBER        := NULL,
        col_11_name        VARCHAR2(30)    := NULL,
        col_12_choice        NUMBER        := NULL,
        col_12_name        VARCHAR2(30)    := NULL,
        col_13_choice        NUMBER        := NULL,
        col_13_name        VARCHAR2(30)    := NULL,
        col_14_choice        NUMBER        := NULL,
        col_14_name        VARCHAR2(30)    := NULL
    );

G_MISS_UTIL_ORDER_BY_REC              util_order_by_rec_type;


-- Start of Comments
--
--     Flexfield where record: flex_where_rec_type
--
--    parameters:
--
--    required: None
--
--    defaults: None
--
--    Notes: 1. name is the column name in where clause. Its format is
--		table_alias.column_name.
--	     2. value is the search criteria for the column
--
-- End of Comments

TYPE flex_where_rec_type		IS RECORD
(
	name		VARCHAR2(30)	:= NULL,
	value		VARCHAR2(150)	:= NULL
);

TYPE flex_where_tbl_type        IS TABLE OF    flex_where_rec_type
                    INDEX BY BINARY_INTEGER;


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


-- Start of Comments
--
--      API name        : translate_orderBy
--      Type            : Private
--      Function        : translate order by choice numbers and columns into
--              a order by string with the order of column names and
--              descending or ascending request.
--
--
--      Paramaeters     :
--      IN              :
--            p_api_version_number    IN      NUMBER,
--            p_init_msg_list         IN      VARCHAR2
--             p_validation_level     IN    NUMBER
--      OUT             :
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--      Version :       Current version 2.0
--                      Initial version         1.0
--
--
--
-- End of Comments

PROCEDURE Translate_OrderBy
(   p_api_version_number     IN      NUMBER,
    p_init_msg_list          IN      VARCHAR2
                  := FND_API.G_FALSE,
    p_validation_level       IN      NUMBER
                  := FND_API.G_VALID_LEVEL_FULL,
    p_order_by_rec           IN     UTIL_ORDER_BY_REC_TYPE,
    x_order_by_clause        OUT NOCOPY     VARCHAR2,
    x_return_status          OUT NOCOPY     VARCHAR2,
    x_msg_count              OUT NOCOPY     NUMBER,
    x_msg_data               OUT NOCOPY     VARCHAR2
);


-- Start of Comments
--
--      API name        : Get_PeriodNames
--      Type            : Private
--      Function        : Provide a table of period names, start_date and end date
--              by given start_date and end_date or period name.
--
--      Paramaeters     :
--      IN              :
--                      p_api_version_number    IN      NUMBER,
--                      p_init_msg_list         IN      VARCHAR2
--                      p_validation_level      IN    NUMBER
--      OUT             :
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
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
    p_validation_level              IN      NUMBER
                      := FND_API.G_VALID_LEVEL_FULL,
    p_period_rec                IN      UTIL_PERIOD_REC_TYPE,
    x_period_tbl            OUT NOCOPY     UTIL_PERIOD_TBL_TYPE,
    x_return_status                 OUT NOCOPY     VARCHAR2,
    x_msg_count                     OUT NOCOPY     NUMBER,
    x_msg_data                      OUT NOCOPY     VARCHAR2
);


-- Start of Comments
--
--      API name        : get_lookupMeaning
--      Type            : Private
--      Function        : Return lookup meaning by given lookup type and lookup code
--
--      Paramaeters     :
--      IN              :
--
--      Version :       Current version 2.0
--                      Initial version         1.0
--
--      Notes:  The valid inputs for p_tablename are:
--        G_AS_LOOKUPS        VARCHAR2 := 'AS_LOOKUPS',
--        G_AR_LOOKUPS        VARCHAR2 := 'AR_LOOKUPS',
--        G_SO_LOOKUPS        VARCHAR2 := 'SO_LOOKUPS',
--        G_HR_LOOKUPS        VARCHAR2 := 'HR_LOOKUPS',
--        G_FND_COMMON_LOOKUPS    VARCHAR2 := 'FND_COMMON_LOOKUPS',
--        G_CS_LOOKUPS        VARCHAR2 := 'CS_LOOKUPS'
--
-- End of Comments

FUNCTION get_lookupMeaning
(    p_lookup_type            IN    VARCHAR2,
     p_lookup_code            IN    VARCHAR2,
     p_tablename              IN    VARCHAR2
) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_lookupMeaning, WNDS);

-- Start of Comments
--
--      API name        : get_unitOfMeasure
--      Type            : Private
--      Function        : Return unit of measure by given UOM_code
--
--      Paramaeters     :
--      IN              :
--
--      Version :       Current version 2.0
--                      Initial version         1.0
--
--
--
-- End of Comments

FUNCTION get_unitOfMeasure(p_uom_code IN VARCHAR2) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_unitOfMeasure, WNDS);

-- Start of Comments
--
--      API name        : get_uomCode
--      Type            : Private
--      Function        : Return unit of measure by given UOM
--
--      Paramaeters     :
--      IN              :
--
--      Version :       Current version 2.0
--                      Initial version         1.0
--
--
--
-- End of Comments

FUNCTION get_uomCode(p_uom IN VARCHAR2) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_uomCode, WNDS);


-- Start of Comments
--
--      API name        : Get_Currency
--      Type            : Private
--      Function        : Provide a record of currency by given currency_code
--
--      Paramaeters     :
--      IN              :
--                      p_api_version_number    IN      NUMBER,
--                      p_init_msg_list         IN      VARCHAR2
--                      p_validation_level      IN    NUMBER
--      OUT             :
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--      Version :       Current version 2.0
--                      Initial version         1.0
--
--
--
-- End of Comments



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
--    OUT        :
--            x_return_status                      OUT    VARCHAR2(1)
--            x_msg_count                          OUT    NUMBER
--            x_msg_data                           OUT    VARCHAR2(2000)
--            x_opp_tbl                            OUT    AS_OPPORTUNITY_PUB.Opp_tbl_Type
--            x_returned_rec_count                 OUT    NUMBER
--            x_next_rec_ptr                       OUT    NUMBER
--            x_tot_rec_count                      OUT    NUMBER
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
                                p_validation_level        IN    NUMBER
                                    := FND_API.G_VALID_LEVEL_FULL,
                                p_inventory_item_rec      IN    AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE,
                                x_return_status           OUT NOCOPY   VARCHAR2,
                                x_msg_count               OUT NOCOPY   NUMBER,
                                x_msg_data                OUT NOCOPY   VARCHAR2,
                                x_inventory_item_tbl      OUT NOCOPY   AS_FOUNDATION_PUB.inventory_item_TBL_TYPE);

--
-- Start of Comments
--
--      API name        : get_inventory_tiem
--      Type            : Private
--      Function        : Return concatenated segements based on inventory_item_id and
--                        organization_id
--
--      Paramaeters     :
--      IN              : p_inventory_item_id, p_organization_id
--
--      Version :       Current version 2.0
--                      Initial version         1.0
--

FUNCTION Get_Concatenated_Segments( p_inventory_item_id IN NUMBER
                            ,p_organization_id   IN NUMBER) return Varchar2;

PRAGMA RESTRICT_REFERENCES(Get_Concatenated_Segments, WNDS);


--
--    API name    : Get_Inventory_ItemPrice
--    Type        : Private
--    Function    : return list price of inventory item.
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN          :
--            p_api_version_number        IN NUMBER                        Required
--            p_identity_salesforce_id    IN NUMBER                        Optional
--                Default = NULL
--            p_init_msg_list             IN VARCHAR2                      Optional
--                Default = FND_API.G_FALSE
--            p_inventory_item_rec        IN Inventory_Item_Rec            Required
--
--
--    OUT        :
--            x_return_status                      OUT    VARCHAR2(1)
--            x_msg_count                          OUT    NUMBER
--            x_msg_data                           OUT    VARCHAR2(2000)
--            x_list_price                         OUT    NUMBER
--            x_currency_code                      OUT    VARCHAR2
--
--    Version    :    Current version     2.0
--                    Initial version     1.0
--
--    Requirement:
--        1. p_inventory_item_rec.inventory_item_id
--        2. p_inventory_item_rec.primary_uom_code
--        3. p_price_list_id
--
--    Limitation:
--        1. Secondary Price List is not considered.

PROCEDURE Get_inventory_itemPrice(  p_api_version_number      IN    NUMBER,
                                p_init_msg_list           IN    VARCHAR2
                                    := FND_API.G_FALSE,
                                p_identity_salesforce_id  IN    NUMBER,
                                p_validation_level        IN    NUMBER
                                    := FND_API.G_VALID_LEVEL_FULL,
                                p_inventory_item_rec      IN    AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE,
                                p_price_list_id           IN    NUMBER,
                                x_return_status           OUT NOCOPY   VARCHAR2,
                                x_msg_count               OUT NOCOPY   NUMBER,
                                x_msg_data                OUT NOCOPY   VARCHAR2,
                                x_list_price              OUT NOCOPY   NUMBER,
                                x_currency_code           OUT NOCOPY   VARCHAR2);

--
--    API name    : Get_Price_List_Id
--    Type        : Private
--    Function    : return price list id for a price group and specified currency code.
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN          :
--            p_api_version_number        IN NUMBER                        Required
--            p_init_msg_list             IN VARCHAR2                      Optional
--                Default = FND_API.G_FALSE
--            p_validation_level          IN NUMBER		           Optional
--	      p_currency_code		  IN VARCHAR2			   Required
--
--    OUT        :
--            x_return_status                      OUT    VARCHAR2(1)
--            x_msg_count                          OUT    NUMBER
--            x_msg_data                           OUT    VARCHAR2(2000)
--            x_price_list_id                      OUT    NUMBER
--
--    Version    :
--
--    Note:
--
PROCEDURE Get_Price_List_Id(p_api_version_number	IN  NUMBER,
			    p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
			    p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
			    x_return_status	 OUT NOCOPY VARCHAR2,
			    x_msg_count		 OUT NOCOPY NUMBER,
			    x_msg_data		 OUT NOCOPY VARCHAR2,
			    p_currency_code		IN  VARCHAR2,
			    x_price_list_id	 OUT NOCOPY NUMBER);

--
--    API name    : Get_Price_Info
--    Type        : Private
--    Function    : return price list id and price for an inventory inem or price for a product family.
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN          :
--            p_api_version_number        IN NUMBER                        Required
--	      p_init_msg_list		  IN VARCHAR2			   Optional
--		Default FND_API.G_FALSE
--	      p_validation_level	  IN NUMBER			   Optional
--		Default FND_API.G_VALID_LEVEL_FULL
--	      p_inventory_item_rec	  IN AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE Optional
--	        Default AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC,
--	      p_secondary_interest_code_id IN NUMBER			   Optional
--	        Default FND_API.G_MISS_NUM,
--	      p_currency_code		  IN VARCHAR2			   Required
--
--    OUT        :
--            x_return_status                      OUT    VARCHAR2(1)
--            x_msg_count                          OUT    NUMBER
--            x_msg_data                           OUT    VARCHAR2(2000)
--            x_price_list_id                      OUT    NUMBER
--	      x_price				   OUT    NUMBER
--
--    Version    :
--
--    Note:
--
PROCEDURE Get_Price_Info(p_api_version_number	IN  NUMBER,
			 p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
			 p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
			 p_inventory_item_rec		IN  AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE DEFAULT AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC,
			 p_secondary_interest_code_id	IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			 p_currency_code		IN  VARCHAR2,
			 x_return_status	 OUT NOCOPY VARCHAR2,
			 x_msg_count		 OUT NOCOPY NUMBER,
			 x_msg_data		 OUT NOCOPY VARCHAR2,
			 x_price_list_id	 OUT NOCOPY NUMBER,
			 x_price		 OUT NOCOPY NUMBER);

-- Start of Comments
--
-- API name	: Check_Volume_Amount
-- Type		:
-- Pre-reqs	:
-- Function	:
--	This api takes inventory_item_rec, secondary_interest_code_id, currency_code, volume
--	and amount as the input, it will compute volume or amount if either of them is missed
--      or check the consistency between them if both of them have been set a value.
--
-- Parameters	:
-- IN		:
--			p_api_version_number	IN  NUMBER,
--			p_init_msg_list		IN  VARCHAR2
--					:= FND_API.G_FALSE
--			 p_validation_level		IN  NUMBER
--					:= FND_API.G_VALID_LEVEL_FULL
--			 p_inventory_item_rec		IN  AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE
--					DEFAULT AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC
--			 p_secondary_interest_code_id	IN  NUMBER
--					DEFAULT FND_API.G_MISS_NUM
--			 p_currency_code		IN  VARCHAR2
--			 p_volume			IN  NUMBER
--					DEFAULT FND_API.G_MISS_NUM
--			 p_amount			IN  NUMBER
--					DEFAULT FND_API.G_MISS_NUM
--			 x_return_status		OUT VARCHAR2
--			 x_msg_count			OUT NUMBER
--			 x_msg_data			OUT VARCHAR2
--			 x_vol_tolerance_margin		OUT NUMBER
--			 x_volume			OUT NUMBER
--			 x_amount			OUT NUMBER
--			 x_uom_code			OUT VARCHAR2
--			 x_price_list_id		OUT NUMBER
--			 x_price			OUT NUMBER
--
-- Version	:
--
-- HISTORY
--	19-Nov-1998	J. Shang	Created
-- Note     :
--	1. Inventory item will overwrite the secondary interest code when both of them are set
--      2. The values needed in pass-in parameter p_inventory_item_rec maybe:
--			Item_Id, Organization_Id and uom_code
--	   Among them, if uom_code is not set, the value in the table will be used
--	3. p_volume, p_amount and p_volume_1, p_amount_1 are two pairs of volume_amount to be checking.
--	   But it only computs p_volume and p_amount if one of them is missed, not p_volume_1 and p_amount_1.
--	   So, there is only one pair of volume_amount in the output parameters.
--      4. If the profile value tells that the volume forecasting is disabled, all parameters from
--	   x_vol_tolerance_margin to x_price will be NULL and x_return_status is FND_API.G_RET_STS_SUCCESS.
--End of Comments
PROCEDURE Check_Volume_Amount(p_api_version_number	IN  NUMBER,
			 p_init_msg_list		IN  VARCHAR2 := FND_API.G_FALSE,
			 p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
			 p_inventory_item_rec		IN  AS_FOUNDATION_PUB.Inventory_Item_REC_TYPE DEFAULT AS_FOUNDATION_PUB.G_MISS_INVENTORY_ITEM_REC,
			 p_secondary_interest_code_id	IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			 p_currency_code		IN  VARCHAR2,
			 p_volume			IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			 p_amount			IN  NUMBER DEFAULT FND_API.G_MISS_NUM,
			 x_return_status	 OUT NOCOPY VARCHAR2,
			 x_msg_count		 OUT NOCOPY NUMBER,
			 x_msg_data		 OUT NOCOPY VARCHAR2,
			 x_vol_tolerance_margin	 OUT NOCOPY NUMBER,
			 x_volume		 OUT NOCOPY NUMBER,
			 x_amount		 OUT NOCOPY NUMBER,
			 x_uom_code		 OUT NOCOPY VARCHAR2,
			 x_price_list_id	 OUT NOCOPY NUMBER,
			 x_price		 OUT NOCOPY NUMBER);


-- 	Name: 		Gen_NoBind_Flex_Where
--	Function:	common procedure for flexfield search without binding
-- 	IN:		p_flex_where_tbl_type: column names and the search criteria
--			for those columns in where clause
--	OUT:		x_flex_where_clause: where clause based on flexfield, the format
--			of which like ' AND table.column1 = value1 AND
--			table.column2 = value2 ...'
--

PROCEDURE Gen_NoBind_Flex_Where(
		p_flex_where_tbl_type	IN 	AS_FOUNDATION_PVT.flex_where_tbl_type,
		x_flex_where_clause OUT NOCOPY VARCHAR2);

-- 	Name: 		Gen_Flexfield_Where
--	Function:	common procedure for flexfield search with binding
-- 	IN:		p_flex_where_tbl_type: column names and the search criteria
--			for those columns in where clause
--	OUT:		x_flex_where_clause: where clause based on flexfield, the format
--			of which like ' AND table.column1 = :p_ofso_flex_var1 AND
--			table.column2 = :p_ofso_flex_var2 ...'

PROCEDURE Gen_Flexfield_Where(
		p_flex_where_tbl_type	IN 	AS_FOUNDATION_PVT.flex_where_tbl_type,
		x_flex_where_clause OUT NOCOPY VARCHAR2);

-- 	Name: 		Bind_Flexfield_Where
--	Function:	common procedure for flexfield search with binding. Bind
--			placeholders in the where clause generated by Gen_Flecfield_Where.
-- 	IN:		p_cursor_id: identifier of the cursor for binding.
--			p_flex_where_tbl_type: column names and the search criteria
--			for those columns in where clause
--	OUT:		none.

PROCEDURE Bind_Flexfield_Where(
		p_cursor_id		IN	NUMBER,
		p_flex_where_tbl_type	IN AS_FOUNDATION_PVT.flex_where_tbl_type);

PROCEDURE Get_Messages (p_message_count IN  NUMBER,
                          p_msgs          OUT NOCOPY VARCHAR2);

END AS_FOUNDATION_PVT;

 

/
