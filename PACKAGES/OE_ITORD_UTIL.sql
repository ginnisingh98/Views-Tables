--------------------------------------------------------
--  DDL for Package OE_ITORD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ITORD_UTIL" AUTHID CURRENT_USER AS
/* $Header: OEITORDS.pls 120.4.12010000.2 2008/08/26 09:12:17 smanian ship $ */


TYPE Item_Orderability_Rec IS RECORD
(
   orderability_id      number
  ,org_id               number
  ,item_category_id     number
  ,inventory_item_id    number
  ,item_level           varchar2(1)
  ,generally_available  varchar2(1)
  ,enable_flag          varchar2(1)
  ,created_by           number
  ,creation_date        date
  ,last_updated_by      number
  ,last_update_date     date
);

TYPE Item_Orderability_Rules_Rec IS RECORD
(
   ORDERABILITY_ID         NUMBER,
   RULE_LEVEL              VARCHAR2(30),
   CUSTOMER_ID             NUMBER,
   CUSTOMER_CLASS_ID       NUMBER,
   CUSTOMER_CATEGORY_CODE  VARCHAR2(30),
   REGION_ID               NUMBER,
   ORDER_TYPE_ID           NUMBER,
   SHIP_TO_LOCATION_ID     NUMBER,
   SALES_CHANNEL_CODE      VARCHAR2(30),
   SALES_PERSON_ID         NUMBER,
   END_CUSTOMER_ID         NUMBER,
   BILL_TO_LOCATION_ID     NUMBER,
   DELIVER_TO_LOCATION_ID  NUMBER,
   ENABLE_FLAG             VARCHAR2(1),
   CREATED_BY              NUMBER,
   CREATION_DATE           DATE,
   LAST_UPDATED_BY         NUMBER,
   LAST_UPDATE_DATE        DATE,
   CONTEXT                 VARCHAR2(250),
   ATTRIBUTE1              VARCHAR2(250),
   ATTRIBUTE2              VARCHAR2(250),
   ATTRIBUTE3              VARCHAR2(250),
   ATTRIBUTE4              VARCHAR2(250),
   ATTRIBUTE5              VARCHAR2(250),
   ATTRIBUTE6              VARCHAR2(250),
   ATTRIBUTE7              VARCHAR2(250),
   ATTRIBUTE8              VARCHAR2(250),
   ATTRIBUTE9              VARCHAR2(250),
   ATTRIBUTE10             VARCHAR2(250),
   ATTRIBUTE11             VARCHAR2(250),
   ATTRIBUTE12             VARCHAR2(250),
   ATTRIBUTE13             VARCHAR2(250),
   ATTRIBUTE14             VARCHAR2(250),
   ATTRIBUTE15             VARCHAR2(250),
   ATTRIBUTE16             VARCHAR2(250),
   ATTRIBUTE17             VARCHAR2(250),
   ATTRIBUTE18             VARCHAR2(250),
   ATTRIBUTE19             VARCHAR2(250),
   ATTRIBUTE20             VARCHAR2(250)
);


PROCEDURE Insert_Row
(   p_item_orderability_rec       IN  OE_ITORD_UTIL.Item_Orderability_Rec
,   x_return_status               OUT NOCOPY VARCHAR2
);


PROCEDURE Update_Row
(   p_item_orderability_rec       IN  OE_ITORD_UTIL.Item_Orderability_Rec
,   x_return_status               OUT NOCOPY VARCHAR2
);

PROCEDURE Insert_Row
(   p_item_orderability_rules_rec IN OE_ITORD_UTIL.Item_Orderability_Rules_Rec
,   x_return_status               OUT NOCOPY VARCHAR2
,   x_rowid                       OUT NOCOPY  ROWID
);

PROCEDURE Update_Row
(   p_item_orderability_rules_rec   IN   OE_ITORD_UTIL.Item_Orderability_Rules_Rec
,   p_row_id                        IN ROWID
,   x_return_status                 OUT NOCOPY VARCHAR2
);

Procedure REFRESH_MATERIALIZED_VIEW
(
   ERRBUF         OUT NOCOPY VARCHAR2,
   RETCODE        OUT NOCOPY VARCHAR2
);

FUNCTION Check_Duplicate_Rules ( l_sql_stmt varchar2)
RETURN BOOLEAN;



--Following are the attributes based on which item orderability rules can be defined
G_CUSTOMER_ID		NUMBER;
G_CUSTOMER_CLASS_ID	NUMBER;
G_CUSTOMER_CATEGORY_CODE VARCHAR2(30);
G_REGION_ID_LIST        VARCHAR2(32000);
G_ORDER_TYPE_ID         NUMBER;
G_SHIP_TO_ORG_ID        NUMBER;
G_SALES_CHANNEL_CODE    VARCHAR2(30);
G_SALESREP_ID           NUMBER;
G_END_CUSTOMER_ID       NUMBER;
G_INVOICE_TO_ORG_ID     NUMBER;
G_DELIVER_TO_ORG_ID     NUMBER;



--Following Variables are used to chace the values to avoid repeated execution of the same sql
G_SOLD_TO_ORG_ID  NUMBER;
G_SHIP_TO_LOCATION_ID  NUMBER;
G_CUSTOMER_PROFILE_CLASS_ID  NUMBER;
G_SHIP_TO_ORGANIZATION_ID    NUMBER;
G_SHIP_TO_REGION_ID_LIST VARCHAR2(32000);
G_INVENTORY_ITEM_ID NUMBER;
G_ITEM_CATEGORY_ID NUMBER;
G_CUST_ID NUMBER;
G_CUST_CATEGORY_CODE VARCHAR2(30);

G_OPERATING_UNIT_ID NUMBER;
G_ITEM_VALIDATION_ORG_ID NUMBER;

G_HEADER_ID NUMBER;
G_HDR_ID    NUMBER;
G_SC_CODE   VARCHAR2(30);
G_TRX_TYPE_ID NUMBER;



Procedure set_globals (
P_CUSTOMER_ID		IN NUMBER,
P_CUSTOMER_CLASS_ID	IN NUMBER,
P_CUSTOMER_CATEGORY_CODE  IN VARCHAR2,
P_REGION_ID_LIST          IN VARCHAR2,
P_ORDER_TYPE_ID         IN NUMBER,
P_SHIP_TO_ORG_ID        IN NUMBER,
P_SALES_CHANNEL_CODE    IN VARCHAR2,
P_SALESREP_ID           IN NUMBER,
P_END_CUSTOMER_ID       IN NUMBER,
P_INVOICE_TO_ORG_ID     IN NUMBER,
P_DELIVER_TO_ORG_ID     IN NUMBER
);


 --Following Functions will return the global variables (Referenced in  views )
 Function get_customer_id
 Return Number;

 Function get_customer_class_id
 Return Number;


 Function get_customer_category_code
 Return Varchar2;

 --bug7294798
 Function get_region_ids
 Return VARCHAR2;

 Function get_order_type_id
 Return Number;

 Function get_ship_to_org_id
 Return Number;

 Function get_sales_channel_code
 Return Varchar2;

 Function get_salesrep_id
 Return Number;

 Function get_end_customer_id
 Return Number;


 Function get_invoice_to_org_id
 Return Number;

 Function get_deliver_to_org_id
 Return Number;

 Function get_operating_unit_id
 Return Number;

 Function get_item_validation_org_id
 Return Number;

--bug7294798
Function get_region_ids ( p_ship_to_org_id IN NUMBER)
Return varchar2;


Function get_item_category_id ( p_inventory_item_id IN Number )
Return Number;

Function get_customer_class_id ( p_customer_id IN Number )
Return Number;

Function get_customer_category_code ( p_customer_id IN NUMBER )
Return Varchar2;



Function Validate_item_orderability ( p_line_rec IN OE_Order_PUB.Line_Rec_Type )
Return BOOLEAN;

Function Validate_item_orderability ( p_org_id IN NUMBER,
				      p_line_id IN NUMBER,
				      p_header_id IN NUMBER,
				      p_inventory_item_id IN NUMBER,
				      p_sold_to_org_id IN NUMBER,
			              p_ship_to_org_id IN NUMBER,
				      p_salesrep_id IN NUMBER,
				      p_end_customer_id IN NUMBER,
				      p_invoice_to_org_id IN NUMBER,
				      p_deliver_to_org_id IN NUMBER )
Return BOOLEAN;

Function get_item_name(p_inventory_item_id IN NUMBER )
RETURN VARCHAR2;

Function get_item_category_name(p_inventory_item_id IN NUMBER )
RETURN VARCHAR2;

FUNCTION GET_RULE_LEVEL_VALUE ( P_RULE_LEVEL varchar2
                              , P_RULE_LEVEL_VALUE varchar2
                              )
RETURN VARCHAR2;

Function Get_Shipto_Location_Id ( p_site_use_id IN NUMBER)
Return NUMBER;

Function get_sales_channel_code (p_header_id IN NUMBER)
Return Varchar2;

Function get_order_type_id (p_header_id IN NUMBER)
Return Number;

END OE_ITORD_UTIL;

/
