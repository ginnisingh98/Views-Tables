--------------------------------------------------------
--  DDL for Package QP_PRC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRC_UTIL" AUTHID CURRENT_USER AS
/* $Header: QPXUPRCS.pls 120.1 2005/06/12 23:08:45 appldev  $ */

-- Start of Comments
-- Package name:  QP_PRC_UTIL
--
-- Function:	  Package contains all pricing utilities including:
--
--		  Procedure Calculate_Selling_Price -
--		    Calculates the selling price or selling percent for an
-- 		    item, applying all adjustments.
--
--     		  Procedure Price_Item -
--		    Fetches the best automatic adjustment for an item, sums
--                  up all the adjustments (manual and automatic, header and
--                  line) applied to the item, an finally calculates the
--                  selling price based on the pricing method.
--
-- End Of Comments


--  Global constants representing pricing method codes

G_PRC_METHOD_AMOUNT	CONSTANT    VARCHAR2(10) := 'AMT';
G_PRC_METHOD_PERCENT	CONSTANT    VARCHAR2(10) := '%';


--  Global constants for actions

G_PRC_ACT_PRICE		CONSTANT    VARCHAR2(10) := 'PRICE';
G_PRC_ACT_CALCULATE	CONSTANT    VARCHAR2(10) := 'CALCULATE';
G_PRC_ACT_APPLY_CHG	CONSTANT    VARCHAR2(10) := 'APPLY_CHG';
G_PRC_ACT_ADJUSTMENT	CONSTANT    VARCHAR2(10) := 'ADJUSTMENT';
G_PRC_ACT_LINES		CONSTANT    VARCHAR2(10) := 'LINES';


--  Global constants for operations

G_PRC_OPR_CREATE	CONSTANT    VARCHAR2(10) := 'CREATE';
G_PRC_OPR_DELETE	CONSTANT    VARCHAR2(10) := 'DELETE';
G_PRC_OPR_UPDATE	CONSTANT    VARCHAR2(10) := 'UPDATE';
G_PRC_OPR_LOCK		CONSTANT    VARCHAR2(10) := 'LOCK';

-- Global constant defining Item type code 'SERVICE'.

G_PRC_ITEM_SERVICE	VARCHAR2(30) := 'SERVICE';

--  Global constants for data from oe_entities

G_ATTR_UNIT			NUMBER := 10001;
G_ATTR_QUANTITY			NUMBER := 10002;
G_ATTR_LIST_PRICE		NUMBER := 10003;
G_ATTR_CUSTOMER			NUMBER := 1000;
G_ATTR_ITEM			NUMBER := 1001;
G_ATTR_PO_NUMBER		NUMBER := 1004;
G_ATTR_AGREEMENT_TYPE		NUMBER := 1005;
G_ATTR_AGREEMENT		NUMBER := 1006;
G_ATTR_ORDER_TYPE_ID		NUMBER := 1007;
G_ATTR_INVOICE_TO		NUMBER := 1008;
G_ATTR_SHIP_TO			NUMBER := 1009;
G_ATTR_PRC_ATTRIBUTE1		NUMBER := 1010;
G_ATTR_PRC_ATTRIBUTE2		NUMBER := 1011;
G_ATTR_PRC_ATTRIBUTE3		NUMBER := 1012;
G_ATTR_PRC_ATTRIBUTE4		NUMBER := 1013;
G_ATTR_PRC_ATTRIBUTE5		NUMBER := 1014;
G_ATTR_PRC_ATTRIBUTE6		NUMBER := 1015;
G_ATTR_PRC_ATTRIBUTE7		NUMBER := 1016;
G_ATTR_PRC_ATTRIBUTE8		NUMBER := 1017;
G_ATTR_PRC_ATTRIBUTE9		NUMBER := 1018;
G_ATTR_PRC_ATTRIBUTE10		NUMBER := 1019;
G_ATTR_PRC_ATTRIBUTE11		NUMBER := 1040;
G_ATTR_PRC_ATTRIBUTE12		NUMBER := 1041;
G_ATTR_PRC_ATTRIBUTE13		NUMBER := 1042;
G_ATTR_PRC_ATTRIBUTE14		NUMBER := 1043;
G_ATTR_PRC_ATTRIBUTE15		NUMBER := 1044;
G_ATTR_ITEM_CATEGORY		NUMBER := 1045;
G_ATTR_CUSTOMER_CLASS		NUMBER := 100000;

-- Type Prc_Item_Rec_Type record
-- Usage:
-- Description:
--  The Prc_Item_Rec_Type record holds the item/price_list information.  It
--  also holds the discounting attributes affecting the fetch of the
--  best discounts.
-- Parameters:
--	inventory_item_id	NUMBER		optional
--	price_list_id		NUMBER 		required
--		If price_list_id is missing, price_item procedure
--              returns with all OUT parameters set to NULL
-- 	unit_code		VARCHAR2(3)	optional
--		Discounting attribute from oe_order_lines
--      pricing_df_rec		VARCHAR2(150)   optional
--		Discounting attribute from oe_order_lines
--      item_category_id	NUMBER		optional
--		Discounting attribute from MTL_ITEM_CATEGORIES
--      quantity		NUMBER		optional
--		Discounting attribute from oe_order_lines
--	ship_to_site_use_id	NUMBER		optional
--		Discounting attribute from oe_order_lines
--	list_price		NUMBER		required
--		If list_price is missing, price_item procedure
--              returns with all OUT variables set to NULL
-- 	list_percent		NUMBER		optional
--		Used when price_method_code = PERC (percent)
--      base_price		NUMBER		optional
--		Used when price_method_code = PERC.  Comes from
--		the parent service line list_price in oe_order_lines
-- 	service_duration	NUMBER		optional
--		Used when price_method_code = PERC
--	item_type_code	VARCHAR2(30)	optional
--		Used when price_method_code = PERC to check if
--		the item is service or not
-- 	price_method_code	VARCHAR2(4)	required
--		price_item procedure supports two types of pricing:
--			G_PRC_METHOD_AMOUNT - an amount
--			G_PRC_METHOD_PERCENT - a percent
--		Value for price_method_code comes from oe_order_lines or
--		from fetch_list_price.  If price_method_code is
-- 		missing, price_item returns with all out
--		parameters set to NULL
--	customer_id		NUMBER		optional
--		Discounting attribute from oe_order_headers
-- 	customer_class_code	VARCHAR2(30)	optional
-- 		Discounting attribute from hz_cust_accounts
-- 	invoice_to_site_use_id  NUMBER	optional
--		Discounting attribute from oe_order_headers
--	po_number		NUMBER		optional
--		Discounting attribute from oe_order_headers
--	agreement_id		NUMBER		optional
--		Discounting attribute from oe_order_headers
-- 	agreement_type_code	VARCHAR(30)	optional
--	order_type_id		NUMBER		optional
--		Discounting attribute from oe_order_headers
--	gsa			VARCHAR2(1)	optional
--		Discounting attribute from oe_order_headers.  If value
--		is not passed for gsa, the price_item procedure
--		derives it from the customer or invoice
-- Notes:

TYPE Prc_Item_Rec_Type is RECORD
( inventory_item_id	NUMBER 		:= NULL				,
  price_list_id		NUMBER		:= NULL				,
  unit_code		VARCHAR2(3)	:= NULL				,
  pricing_attribute1	VARCHAR2(150)	:= NULL				,
  pricing_attribute2    VARCHAR2(150)	:= NULL				,
  pricing_attribute3	VARCHAR2(150)	:= NULL				,
  pricing_attribute4	VARCHAR2(150)	:= NULL				,
  pricing_attribute5	VARCHAR2(150)	:= NULL				,
  pricing_attribute6	VARCHAR2(150)	:= NULL				,
  pricing_attribute7	VARCHAR2(150)	:= NULL				,
  pricing_attribute8	VARCHAR2(150)	:= NULL				,
  pricing_attribute9	VARCHAR2(150)	:= NULL				,
  pricing_attribute10	VARCHAR2(150)	:= NULL				,
  pricing_attribute11	VARCHAR2(150)	:= NULL				,
  pricing_attribute12	VARCHAR2(150)	:= NULL				,
  pricing_attribute13	VARCHAR2(150)	:= NULL				,
  pricing_attribute14	VARCHAR2(150)   := NULL				,
  pricing_attribute15   VARCHAR2(150)	:= NULL				,
  pricing_date		DATE		:= NULL				,
  item_category_id	NUMBER		:= NULL				,
  quantity		NUMBER		:= NULL				,
  ship_to_site_use_id	NUMBER		:= NULL				,
  list_price		NUMBER		:= NULL				,
  list_percent		NUMBER		:= NULL				,
  base_price		NUMBER 		:= NULL				,
  service_duration	NUMBER		:= NULL				,
  item_type_code	VARCHAR2(30)	:= NULL				,
  price_method_code	VARCHAR2(4)	:= NULL				,
  sold_to_org_id		NUMBER		:= NULL				,
  customer_class_code	VARCHAR2(30)	:= NULL				,
/*  invoice_to_site_use_id  NUMBER	:= NULL				, */
  invoice_to_org_id  NUMBER	:= NULL				,
  po_number		VARCHAR2(50)	:= NULL				,
  agreement_id		NUMBER		:= NULL				,
  agreement_type_code	VARCHAR2(30)	:= NULL				,
  order_type_id		NUMBER		:= NULL				,
  gsa			VARCHAR2(1)	:= NULL
);



-- Type Adj_Short_Rec_Type record:
-- Usage:
-- Description:
--   The Adj_Short_Rec_Type record holds one fetched adjustment.
-- Parameters:
--	adjustment_id		NUMBER := NULL
--		adjustment_id is not fetched by this function.
--		It is up to the calling function to get an
--		adjustment_id and insert the adjustment
--		into OE_PRICE_ADJUSTMENTS
--	discount_id		NUMBER
--	discount_line_id	NUMBER
--	automatic_flag		VARCHAR2(1)
--	percent			NUMBER
--		discount_id, discount_line_id, automatic_flag,
--		and percent all returned from oe_price_adjustments
--	line_id			NUMBER
-- 	header_id		NUMBER
--	line_tbl_index		NUMBER
--		line_id, header_id and line_tbl_index are not
--		used by this function
--      discount_name		VARCHAR2(30)
--  		Name of the discount from oe_discounts
--	operation		VARCHAR2(10)
--	line_tbl_index		NUMBER := NULL
--		Not currently used
-- Notes:

TYPE Adj_Short_Rec_Type is RECORD
( adjustment_id		NUMBER		:= NULL			,
  discount_id		NUMBER		:= NULL			,
  discount_line_id	NUMBER		:= NULL			,
  automatic_flag	VARCHAR2(1)	:= NULL			,
  percent		NUMBER		:= NULL			,
  line_id		NUMBER		:= NULL			,
  header_id		NUMBER		:= NULL			,
  discount_name		VARCHAR2(30)	:= NULL			,
  pricing_date		DATE		:= NULL			,
  operation		VARCHAR2(10)	:= NULL			,
  line_tbl_index	NUMBER		:= NULL
);



-- Type Adj_Short_Tbl_Type table:
-- Usage:
-- Description:
--   The Adj_Short_Tbl_Type table holds fetched adjustments.
--   Currently the Price_Item procedure fetches only one automatic adjustment.
--   We use the Adj_Short_Tbl_Type table as an OUT parameter to allow for
--   future enhancements that may result in the procedure returning more than
--   one adjustment.  This type is also used in the Price_line API
--   to hold a table of line level adjustments.
-- Parameters: None
-- Notes:

TYPE Adj_Short_Tbl_Type is TABLE OF Adj_Short_Rec_Type
  INDEX BY BINARY_INTEGER;

--  Global variable representing the missing Adj_Short_Tbl

G_MISS_ADJ_SHORT_TBL	Adj_Short_Tbl_Type;

--  FUNCTION EQUAL

FUNCTION    Equal
(   p_attr1	IN  NUMBER ,
    p_attr2	IN  NUMBER
) RETURN BOOLEAN;

FUNCTION    Equal
(   p_attr1	IN  VARCHAR2,
    p_attr2	IN  VARCHAR2
) RETURN BOOLEAN;

FUNCTION    Equal
(   p_attr1	IN  DATE ,
    p_attr2	IN  DATE
) RETURN BOOLEAN;


-- Function Get_Hdr_Adj_Total
-- Usage:
--   This function is called from the Price_Line and Price_Order APIs
-- Description:
--   Get_Hdr_Adj_Total returns the total of all header level adjustments
--   from the G_hdr_adj_tbl global table for the specified header header_id
-- Parameters:
--   IN:
--     p_header_id  	IN  NUMBER		required
--   RETURNS: NUMBER
-- Notes:

FUNCTION Get_Hdr_Adj_Total
( p_header_id   	IN  	NUMBER := NULL) RETURN NUMBER;



-- Procedure Query_Adjustments
-- Usage:
--   This procedure is called from Price_Line.
-- Description:
--   Queries line and header level adjustments.
--   The header level adjustments will be stored in
--   G_hdr_adj_tbl, while line level adjustments will be
--   returned in l_adj_tbl.
--   Keep in mind that if G_hdr_adj_tbl has already been
--   queried then no extra queries will be performed. This is
--   intentional to allow the Price_Header portion of the
--   Price_Order API to manipulate header level adjustment and
--   have this manipulation reflect on lines selling prices.

PROCEDURE Query_Adjustments
(   p_header_id		IN	NUMBER	:=  NULL    ,
    p_line_id		IN	NUMBER	:=  NULL    ,
    p_adj_tbl		OUT NOCOPY /* file.sql.39 change */	QP_PRC_UTIL.Adj_Short_Tbl_Type
);

--  FUNCTION Get_Agr_Type : Queries the agreement type code from
--  OE_AGREEMENTS.

FUNCTION Get_Agr_Type
(   p_agreement_id   	IN  	NUMBER := NULL
) RETURN VARCHAR2;

-- Procedure Calculate_Selling_Price
-- Usage:
--   Calculate_Selling_Price is called from the Price_Item procedure
--   after Price_Item has fetched the best available automatic
--   adjustment and calculated the total adjustment total.
--   Calculate_Selling_Price is also called from the Price_Line
--   procedure as a full call to Price_Item from the Price_Line API
--   is unnecessary in certain situations.
-- Description:
--   Calculates the selling price or selling percent for an
--   item, applying all adjustments.
--   Two pricing methods are supported: amount and percent.
-- Parameters:
--   IN:
--     p_adj_total		NUMBER          required
-- 		Total adjustment percent to apply 0-100
--     p_list_price		NUMBER		required
--		Used when price_method_code = AMNT (amount),
--               otherwise pass NULL
--     p_list_percent		NUMBER		required
--		Used when price_method_code = PERC (percent),
--		 otherwise pass NULL
--     p_price_list_id		NUMBER 		required
--		If p_price_list_id is NULL, Calculate_Selling_Price
--              returns with all OUT parameters set to NULL
--     p_base_price		NUMBER		required
--		Used when price_method_code = PERC.  Comes from
--		the parent service line list_price in oe_order_lines
--     p_service_duration		NUMBER	required
--		Used when price_method_code = PERC,
--		otherwise pass NULL
--     p_price_method_code	VARCHAR2(4)	required
--		price_item procedure supports two types of pricing:
--			G_PRC_METHOD_AMOUNT - an amount
--			G_PRC_METHOD_PERCENT - a percent
--		Value for price_method_code comes from oe_order_lines or
--		from fetch_list_price.  If price_method_code is
-- 		missing, price_item returns with all out
--		parameters set to NULL
--
--   OUT:
--     p_selling_price		NUMBER
--		Final rounded selling price
--     p_selling_percent	NUMBER
--  		When price_method_code = PERC, this parameter
--		holds the selling percent
--     p_list_price_out		NUMBER
--		When price_method_code = PERC, this parameter
--		holds the list price
--
-- Notes:

PROCEDURE   Calculate_Selling_Price
(  p_adj_total		   IN  NUMBER	 			,
   p_list_price	    	   IN  NUMBER	 			,
   p_list_percent	   IN  NUMBER	 			,
   p_price_list_id	   IN  NUMBER	 			,
   p_base_price	    	   IN  NUMBER	 			,
   p_service_duration	   IN  NUMBER	 			,
   p_pricing_method_code   IN  VARCHAR2	 			,
   p_selling_price	   OUT NOCOPY /* file.sql.39 change */ NUMBER				,
   p_selling_percent	   OUT NOCOPY /* file.sql.39 change */ NUMBER				,
   p_list_price_out	   OUT NOCOPY /* file.sql.39 change */ NUMBER
);



-- Procedure Price_Item
-- Usage:
--   Price_Item is called from the Price_Line API.
-- Description:
--   Fetches the best automatic adjustment for an item, sums
--   up all the adjustments (manual and automatic, header and
--   line) applied to the item, an finally calculates the
--   selling price based on the pricing method.
-- Parameters:
--   IN:
--     p_item_rec		Prc_Item_Rec_Type	required
--  		p_item_rec holds the item/price_list information.
--		It also holds the discounting attributes affecting
--		the fetch of the best discount.
--     p_existing_adj_total  	NUMBER			optional
--		This parameter holds the total of all manual
--		line and header level adjustments.  It will be
--		used when validating that by applying the new
--		adjustment, the total is not going to exceed 100,
--		and it will be added to the new adjustment (if any)
--		to compute the final adjustment total that will
--		be used to calculate the selling price
--   OUT:
--     p_return_status   	VARCHAR2(1)
--     p_selling_price		NUMBER
--		Final rounded selling price
--     p_selling_percent	NUMBER
--  		When price_method_code = PERC, this parameter
--		holds the selling percent
--     p_adj_out_tbl		Adj_Short_Tbl_Type
--		PL/SQL table that holds the new fetched automatic
--		adjustment if found.  Currently the Price_Item
--              procedure fetches only one automatic adjustment.
--              We use the Adj_Short_Tbl_Type table as an OUT
--              parameter to allow for future enhancements that
--              may result in the procedure returning more than
--              one adjustment.
-- Notes:

PROCEDURE Price_Item
( p_return_status   	OUT NOCOPY /* file.sql.39 change */ VARCHAR2					,
  p_item_rec		IN  Prc_Item_Rec_Type				,
  p_existing_adj_total	IN  NUMBER	:= 0				,
  p_selling_price	OUT NOCOPY /* file.sql.39 change */ NUMBER					,
  p_selling_percent	OUT NOCOPY /* file.sql.39 change */ NUMBER					,
  p_list_price_out	OUT NOCOPY /* file.sql.39 change */ NUMBER					,
  p_adj_out_table	OUT NOCOPY /* file.sql.39 change */ Adj_Short_Tbl_Type
);

FUNCTION Get_item_Category
(   p_item_id		IN  NUMBER
) RETURN NUMBER;

FUNCTION Get_Cust_Class
(   p_sold_to_org_id   	IN  	NUMBER := NULL
) RETURN VARCHAR2;

--  Fix For Bug-1974413
--  Function Get_Attribute_Name
--  Description : This Function returns Attribute Name corresponding to the
--                Attribute Code Passed
--  Usage       : This Function  is called from FND_MESSAGE.SET_TOKEN
--  Parameters  : IN p_attribute_code
--  RETURNS     : VARCHAR2

FUNCTION  Get_Attribute_Name
(   p_attribute_code   IN VARCHAR2
)  RETURN VARCHAR2;


END QP_PRC_UTIL;


 

/
