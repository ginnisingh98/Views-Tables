--------------------------------------------------------
--  DDL for Package QP_SOURCING_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_SOURCING_API_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPSAPS.pls 120.0 2005/06/02 00:47:05 appldev noship $ */

TYPE Customer_Info_Rec_Type IS RECORD
(       customer_id         NUMBER
,       customer_class_code VARCHAR2(240)
,       sales_channel_code  VARCHAR2(240)
,       gsa_indicator       VARCHAR2(1)
,       account_types       QP_Attr_Mapping_PUB.t_MultiRecord
,       customer_relationships       QP_Attr_Mapping_PUB.t_MultiRecord
);

TYPE Order_Info_Rec_Type IS RECORD
(       header_id         		NUMBER,
		order_amount			VARCHAR2(240),
		order_quantity			VARCHAR2(240),
		order_total				varchar2(240),
		period1_total_amount	varchar2(240),
		period2_total_amount	varchar2(240),
		period3_total_amount	varchar2(240),
		shippable_flag			varchar2(1)
);

TYPE Site_Use_Rec_Type IS RECORD
(       contact_id        VARCHAR2(240)
,       site_use_id       VARCHAR2(240)
);

TYPE Agreement_Info_Rec_Type IS RECORD
(       agreement_id      	VARCHAR2(240)
,       agreement_type_code   VARCHAR2(240)
);

TYPE Item_Segments_Rec_Type IS RECORD
(       inventory_item_id     	NUMBER
,       segment1   		VARCHAR2(240)
,       segment2   		VARCHAR2(240)
,       segment3   		VARCHAR2(240)
,       segment4   		VARCHAR2(240)
,       segment5   		VARCHAR2(240)
,       segment6   		VARCHAR2(240)
,       segment7   		VARCHAR2(240)
,       segment8   		VARCHAR2(240)
,       segment9   		VARCHAR2(240)
,       segment10   		VARCHAR2(240)
,       segment11   		VARCHAR2(240)
,       segment12   		VARCHAR2(240)
,       segment13   		VARCHAR2(240)
,       segment14   		VARCHAR2(240)
,       segment15   		VARCHAR2(240)
,       segment16   		VARCHAR2(240)
,       segment17   		VARCHAR2(240)
,       segment18   		VARCHAR2(240)
,       segment19   		VARCHAR2(240)
,       segment20   		VARCHAR2(240)
);

PROCEDURE Get_Customer_Info (p_cust_id NUMBER);

FUNCTION Get_Customer_Item_Id (p_item_type VARCHAR2, p_ordered_item_id NUMBER) RETURN NUMBER;

FUNCTION Get_Sales_Channel (p_cust_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Site_Use (p_invoice_to_org_id IN NUMBER, p_ship_to_org_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

FUNCTION Get_Item_Category (p_inventory_item_id IN NUMBER)
         		   RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

FUNCTION Get_Item_Segment(p_inventory_item_id IN NUMBER, p_seg_num NUMBER) RETURN VARCHAR2;

FUNCTION Get_Customer_Class(p_cust_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE Get_Order_AMT_and_QTY (p_header_id IN NUMBER);

FUNCTION Get_Order_Amount(p_header_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Order_Qty (p_header_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Account_Type (p_cust_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

FUNCTION Get_Agreement_Type (p_agreement_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Customer_Relationship (p_cust_id IN NUMBER) RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

FUNCTION Get_Period1_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_ordered_uom IN VARCHAR2)RETURN VARCHAR2;

FUNCTION Get_Period1_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER)RETURN VARCHAR2;

FUNCTION Get_Period2_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_ordered_uom IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Period2_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER)RETURN VARCHAR2;

FUNCTION Get_Period3_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_ordered_uom IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Period3_Item_Quantity(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER)RETURN VARCHAR2;

FUNCTION Get_Period1_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_currency_code IN VARCHAR2, p_conversion_rate_date IN DATE, p_pricing_date IN DATE, p_conversion_rate IN NUMBER, p_conversion_type_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Period1_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Period2_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_currency_code IN VARCHAR2, p_conversion_rate_date IN DATE, p_pricing_date IN DATE, p_conversion_rate IN NUMBER, p_conversion_type_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Period2_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Period3_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER, p_currency_code IN VARCHAR2, p_conversion_rate_date IN DATE, p_pricing_date IN DATE, p_conversion_rate IN NUMBER, p_conversion_type_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Period3_Item_Amount(p_cust_id IN NUMBER, p_inventory_item_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Period1_Order_Amount(p_cust_id IN NUMBER, p_currency_code IN VARCHAR2, p_conversion_rate_date IN DATE, p_pricing_date IN DATE, p_conversion_rate IN NUMBER, p_conversion_type_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Period1_Order_Amount(p_cust_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Period2_Order_Amount(p_cust_id IN NUMBER, p_currency_code IN VARCHAR2, p_conversion_rate_date IN DATE, p_pricing_date IN DATE, p_conversion_rate IN NUMBER, p_conversion_type_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Period2_Order_Amount(p_cust_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Period3_Order_Amount(p_cust_id IN NUMBER, p_currency_code IN VARCHAR2,p_conversion_rate_date IN DATE, p_pricing_date IN DATE, p_conversion_rate IN NUMBER, p_conversion_type_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Period3_Order_Amount(p_cust_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_GSA (p_cust_id NUMBER) RETURN VARCHAR2;

FUNCTION GET_PARTY_ID (p_sold_to_org_id IN NUMBER) RETURN NUMBER;

FUNCTION GET_SHIP_TO_PARTY_SITE_ID(p_ship_to_org_id IN NUMBER) RETURN NUMBER;

FUNCTION GET_INVOICE_TO_PARTY_SITE_ID(p_invoice_to_org_id IN NUMBER) RETURN NUMBER;

FUNCTION GET_MODEL_ID(p_top_model_line_id IN NUMBER) RETURN NUMBER;

FUNCTION GET_SHIPPABLE_FLAG(p_header_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Line_Weight_Or_Volume
(   p_uom_class      IN  VARCHAR2,
    p_inventory_item_id  IN NUMBER,
    p_ordered_quantity IN NUMBER,
    p_order_quantity_uom IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION Get_Order_Weight_Or_Volume
(   p_uom_class      IN  VARCHAR2,
    p_header_id      IN NUMBER
)
RETURN VARCHAR2;

FUNCTION Get_Item_Quantity
(   p_ordered_qty IN NUMBER,
    p_pricing_qty IN NUMBER
)
RETURN VARCHAR2;

FUNCTION Get_Item_Amount
(   p_ordered_qty IN NUMBER,
    p_pricing_qty IN NUMBER
)
RETURN VARCHAR2;

/* Added for 2293711 */
FUNCTION Get_Agreement_Revisions (p_agreement_id IN Number)
                            RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

G_Customer_Info    Customer_Info_Rec_Type;
G_Order_Info	    Order_Info_Rec_Type;
G_Site_Use	    Site_Use_Rec_Type;
G_Agreement_Info   Agreement_Info_Rec_Type;
G_Item_Segments    Item_Segments_Rec_Type;
G_TOP_MODEL_LINE_ID NUMBER;
G_MODEL_ID NUMBER;

FUNCTION Get_Item_Amount
(   p_ordered_qty IN NUMBER,
    p_pricing_qty IN NUMBER,
    p_UNIT_LIST_PRICE_PER_PQTY IN NUMBER,
    p_unit_list_price IN NUMBER
)
RETURN VARCHAR2;

Procedure Get_Customer_Info(p_cust_id NUMBER, invoice_to_org_id NUMBER);


END QP_SOURCING_API_PUB;

 

/
