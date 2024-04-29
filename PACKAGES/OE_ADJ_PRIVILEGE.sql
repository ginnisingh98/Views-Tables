--------------------------------------------------------
--  DDL for Package OE_ADJ_PRIVILEGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ADJ_PRIVILEGE" AUTHID CURRENT_USER AS
/* $Header: OEXSADJS.pls 120.0 2005/05/31 23:17:10 appldev noship $ */

--  Start of Comments
--  API name    Check_Manual_Discount_Priv
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments





-- This procedure is used to check the ability to apply
-- price adjustments on lines. It does this by verifying
-- a) DISCOUTING PRIVILEGE
-- b) UNIT_SELLING_PRICE IS NOT NULL AND NOT 0
-- c) CHECK IF ORDER TYPE ENFORCES PRICE_LIST (if not being called from form)
-- d) CHECK IF ONLY 1 OR NO MANUAL DISCOUNT ARE ALREADY APPLIED
--    IF YES RETURN THE PRICE_ADJUSTMENT_ID


PROCEDURE Check_Manual_Discount_Priv
(   p_api_version_number	IN    NUMBER
,   p_init_msg_list		IN    VARCHAR2 := FND_API.G_FALSE
, x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_order_type_id	        IN    NUMBER  := FND_API.G_MISS_NUM
,   p_Header_Id                 IN    NUMBER
,   p_Line_Id                   IN    NUMBER
,   p_List_Price                IN    NUMBER
,   p_Discounting_Privilege     IN    VARCHAR2
,   p_apply_order_adjs_flag	IN    VARCHAR2 := 'N'
,   p_Check_Multiple_Adj_Flag   IN    VARCHAR2 := 'Y'
, x_adjustment_total OUT NOCOPY NUMBER

, x_price_adjustment_id OUT NOCOPY NUMBER

);


--  Start of Comments
--  API name    Check_Item_Category
--  Type        Public
--  Function
--
--  Pre-reqs:   NONE
--
--  Parameter
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

FUNCTION Check_Item_Category
(   p_inv_item_id 		IN NUMBER
,   p_ent_val			IN VARCHAR2
,   p_orgid			IN NUMBER
,   p_pricing_date		IN DATE
) RETURN VARCHAR2;
PRAGMA restrict_references(CHECK_ITEM_CATEGORY, WNDS, WNPS);

END OE_ADJ_PRIVILEGE;

 

/
