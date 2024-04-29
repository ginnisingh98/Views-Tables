--------------------------------------------------------
--  DDL for Package QP_PRICE_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVPRLS.pls 120.1 2005/06/09 05:23:54 appldev  $ */

--  Start of Comments
--  API name    Process_Price_List
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

PROCEDURE Process_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_old_PRICE_LIST_rec            IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_LINE_tbl           IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   p_old_PRICE_LIST_LINE_tbl       IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
);

--  Start of Comments
--  API name    Lock_Price_List
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

PROCEDURE Lock_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_PRICE_LIST_LINE_tbl           IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_LIST_LINE_TBL
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
);

--  Start of Comments
--  API name    Get_Price_List
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

PROCEDURE Get_Price_List
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_name                          IN  VARCHAR2
,   p_price_list_id                 IN  NUMBER
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
);

-- Start of Comments
-- API name	: Fetch_List_Price
-- Type		: PRIVATE
-- Function	: Return the list price of an item based on a specified
--                price list, item, and unit code.
-- Pre-reqs	: None
-- Parameters	:
-- IN		: p_api_version_number	IN NUMBER	required
--  		  p_init_msg_list	IN VARCHAR2	optional
-- 			default = FND_API.G_FALSE
--		  p_validation_level	IN NUMBER	optional
--			default = FND_API.G_VALID_LEVEL_FULL
--		  p_price_list_id	IN NUMBER	required
--  		  p_inventory_item_id	IN NUMBER	required
--		  p_unit_code		IN VARCHAR2	required
--		  p_service_duration	IN NUMBER	optional
--		  p_item_type_code	IN VARCHAR2	optional
-- 		  p_prc_method_code	IN VARCHAR2	optional
--                p_pricing_attribute1	IN VARCHAR2 	optional
--                p_pricing_attribute2	IN VARCHAR2 	optional
--                p_pricing_attribute3	IN VARCHAR2 	optional
--                p_pricing_attribute4	IN VARCHAR2 	optional
--                p_pricing_attribute5	IN VARCHAR2 	optional
--                p_pricing_attribute6	IN VARCHAR2 	optional
--                p_pricing_attribute7	IN VARCHAR2 	optional
--                p_pricing_attribute8	IN VARCHAR2 	optional
--                p_pricing_attribute9	IN VARCHAR2 	optional
--                p_pricing_attribute10	IN VARCHAR2 	optional
--                p_pricing_attribute11	IN VARCHAR2 	optional
--                p_pricing_attribute12	IN VARCHAR2 	optional
--                p_pricing_attribute13	IN VARCHAR2 	optional
--                p_pricing_attribute14	IN VARCHAR2 	optional
--                p_pricing_attribute15	IN VARCHAR2 	optional
--		  p_base_price		IN NUMBER	optional
--		  p_fetch_attempts	IN NUMBER	optional
-- 			default = G_PRC_LST_DEF_ATTEMPTS
-- OUT NOCOPY /* file.sql.39 change */		: p_return_status   	OUT NOCOPY /* file.sql.39 change */ VARCHAR2(1)
--		  p_msg_count		OUT NOCOPY /* file.sql.39 change */ NUMBER
--		  p_msg_data		OUT NOCOPY /* file.sql.39 change */ VARCHAR2(2000)
--		  p_price_list_id_out	OUT NOCOPY /* file.sql.39 change */ NUMBER
-- 		  p_prc_method_code_out	OUT NOCOPY /* file.sql.39 change */ VARCHAR2(4)
--		  p_list_price		OUT NOCOPY /* file.sql.39 change */ NUMBER
--		  p_list_percent	OUT NOCOPY /* file.sql.39 change */ NUMBER
--		  p_rounding_factor	OUT NOCOPY /* file.sql.39 change */ NUMBER
-- Version	: Current Version 1.0
--		  Initial Version 1.0
-- Notes	:
-- End Of Comments



--  Global constants holding the maximum number of fetch attempts allowed.

G_PRC_LST_MAX_ATTEMPTS    CONSTANT	NUMBER := 2 ;
G_PRC_LST_DEF_ATTEMPTS    CONSTANT	NUMBER := 2 ;

--  Global constants representing pricing method codes

--G_PRC_METHOD_AMOUNT	CONSTANT    VARCHAR2(10) := 'AMNT';
--G_PRC_METHOD_PERCENT	CONSTANT    VARCHAR2(10) := 'PERC';

-- QP BEGIN Edited for QP datamodel
G_PRC_METHOD_AMOUNT	CONSTANT    VARCHAR2(30) := 'AMT';
G_PRC_METHOD_PERCENT	CONSTANT    VARCHAR2(30) := '%';
G_PRC_PRICE_LIST_LINE   CONSTANT    VARCHAR2(30) :='PLL';
-- QP END
--  Global constant Item type codes

G_PRC_ITEM_SERVICE	CONSTANT    VARCHAR2(10) := 'SERVICE';



PROCEDURE Fetch_List_Price
( p_api_version_number	IN  NUMBER	    	    	    	    	,
  p_init_msg_list	IN  VARCHAR2    := FND_API.G_FALSE		,
  p_validation_level	IN  NUMBER	:= FND_API.G_VALID_LEVEL_FULL	,
  p_return_status   	OUT NOCOPY /* file.sql.39 change */ VARCHAR2    ,
  p_msg_count		OUT NOCOPY /* file.sql.39 change */ NUMBER	,
  p_msg_data		OUT NOCOPY /* file.sql.39 change */ VARCHAR2	,
  p_price_list_id	IN  NUMBER	:= NULL				,
  p_inventory_item_id	IN  NUMBER	:= NULL				,
  p_unit_code		IN  VARCHAR2	:= NULL				,
  p_service_duration	IN  NUMBER	:= NULL				,
  p_item_type_code	IN  VARCHAR2	:= NULL				,
  p_prc_method_code	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute1	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute2	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute3	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute4	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute5	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute6	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute7	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute8	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute9	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute10	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute11	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute12	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute13	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute14	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute15	IN  VARCHAR2	:= NULL				,
  p_base_price		IN  NUMBER	:= NULL				,
  p_pricing_date	IN  DATE	:= NULL				,
  p_fetch_attempts	IN  NUMBER	:= G_PRC_LST_DEF_ATTEMPTS	,
  p_price_list_id_out	OUT NOCOPY /* file.sql.39 change */	NUMBER	,
  p_prc_method_code_out	OUT NOCOPY /* file.sql.39 change */	VARCHAR2	,
  p_list_price		OUT NOCOPY /* file.sql.39 change */	NUMBER	,
  p_list_percent	OUT NOCOPY /* file.sql.39 change */	NUMBER	,
  p_rounding_factor	OUT NOCOPY /* file.sql.39 change */	NUMBER
);

Type product_rec_type is RECORD
(
  l_rowid varchar2(2000) := NULL,
  l_last_update_date date := NULL,
  l_product_context varchar2(30) := NULL,
  l_product_attr varchar2(30) := NULL,
  l_product_attr_value varchar2(240) := NULL);

Type priceattr_rec_type is RECORD
(
  l_rowid varchar2(2000) := NULL,
  l_last_update_date date := NULL,
  l_pricing_context varchar2(30) := NULL,
  l_pricing_attr varchar2(30) := NULL,
  l_pricing_attr_value_from varchar2(240) := NULL,
  l_pricing_attr_value_to varchar2(240) := NULL);

Type priceattr_tbl_type is table of priceattr_rec_type
  INDEX BY BINARY_INTEGER;

G_MISS_PRICEATTR_TBL priceattr_tbl_type;
G_MISS_PRODUCT_REC product_rec_type;

Function Get_Secondary_Price_List( p_list_header_id in number) return number;
Function Get_Inventory_Item_Id( p_list_line_id in NUMBER) return number;
Function Get_Customer_Item_Id( p_list_line_id in NUMBER) return number;
Function Get_Pricing_Attr_Context( p_list_line_id in NUMBER) return varchar2;
Function Get_Pricing_Attribute( p_list_line_id in NUMBER,
                                p_pricing_attr in varchar2) return varchar2;


Function Get_Price_Break_High ( p_list_line_id in number ) return number;
Function Get_Price_Break_Low ( p_list_line_id in number ) return number;
Function Get_Product_UOM_Code ( p_list_line_id in number ) return varchar2;
Function   Does_Pricing_Attribute_Exist
(P_Product_Attr_Context In Varchar2,
 p_Product_Attr In Varchar2,
 P_Product_Attr_Val In Varchar2,
 P_PRODUCT_UOM_CODE In Varchar2,
 P_PRICING_ATTRIBUTE_CONTEXT In Varchar2,
 P_PRICING_ATTRIBUTE In Varchar2,
 P_PRICING_ATTR_VALUE_FROM In Varchar2,
 P_PRICING_ATTR_VALUE_TO In Varchar2,
 P_LIST_LINE_ID In Number,
 P_LIST_HEADER_ID In Number
) Return Varchar2;
Pragma Restrict_References(Does_Pricing_Attribute_Exist,WNDS,WNPS);
END QP_PRICE_LIST_PVT;

 

/
