--------------------------------------------------------
--  DDL for Package ASO_PRICING_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PRICING_INT" AUTHID CURRENT_USER AS
/* $Header: asoiprcs.pls 120.2.12010000.6 2015/09/22 17:08:04 rassharm ship $ */
-- Start of Comments
-- Package name     : ASO_PRICING_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

TYPE Index_Link_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
G_MISS_Link_Tbl	 Index_Link_Tbl_Type;

TYPE PRICING_CONTROL_REC_TYPE IS RECORD
(
    REQUEST_TYPE	   VARCHAR2(60),
    PRICING_EVENT      VARCHAR2(30),
    CALCULATE_FLAG     VARCHAR2(30) := 'Y',
    SIMULATION_FLAG    VARCHAR2(1)  := 'N',
    PRICE_CONFIG_FLAG  VARCHAR2(1)  := 'N',
    PRICE_MODE         VARCHAR2(30) := 'ENTIRE_QUOTE',
    PRG_REPRICE_MODE   VARCHAR2(3)  := 'A' -- This parameter values are A or F; A for all lines and F for free lines
);

TYPE PRICING_HEADER_REC_TYPE IS RECORD
(
       QUOTE_HEADER_ID                 NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       ORG_ID                          NUMBER := FND_API.G_MISS_NUM,
       QUOTE_NAME                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       QUOTE_NUMBER                    NUMBER := FND_API.G_MISS_NUM,
       QUOTE_VERSION                   NUMBER := FND_API.G_MISS_NUM,
       QUOTE_STATUS_ID                 NUMBER := FND_API.G_MISS_NUM,
       QUOTE_SOURCE_CODE               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       QUOTE_EXPIRATION_DATE           DATE := FND_API.G_MISS_DATE,
       PRICE_FROZEN_DATE               DATE := FND_API.G_MISS_DATE,
       QUOTE_PASSWORD                  VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ORIGINAL_SYSTEM_REFERENCE       VARCHAR2(240) := FND_API.G_MISS_CHAR,
	  CUST_PARTY_ID                   NUMBER := FND_API.G_MISS_NUM,
       PARTY_ID                        NUMBER := FND_API.G_MISS_NUM,
       CUST_ACCOUNT_ID                 NUMBER := FND_API.G_MISS_NUM,
       ORG_CONTACT_ID                  NUMBER := FND_API.G_MISS_NUM,
       PHONE_ID                        NUMBER := FND_API.G_MISS_NUM,
       INVOICE_TO_PARTY_SITE_ID        NUMBER := FND_API.G_MISS_NUM,
       INVOICE_TO_PARTY_ID             NUMBER := FND_API.G_MISS_NUM,
       ORIG_MKTG_SOURCE_CODE_ID        NUMBER := FND_API.G_MISS_NUM,
       MARKETING_SOURCE_CODE_ID        NUMBER := FND_API.G_MISS_NUM,
       ORDER_TYPE_ID                   NUMBER := FND_API.G_MISS_NUM,
       QUOTE_CATEGORY_CODE             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ORDERED_DATE                    DATE := FND_API.G_MISS_DATE,
       ACCOUNTING_RULE_ID              NUMBER := FND_API.G_MISS_NUM,
       INVOICING_RULE_ID               NUMBER := FND_API.G_MISS_NUM,
       EMPLOYEE_PERSON_ID              NUMBER := FND_API.G_MISS_NUM,
       PRICE_LIST_ID                   NUMBER := FND_API.G_MISS_NUM,
       CURRENCY_CODE                   VARCHAR2(15) := FND_API.G_MISS_CHAR,
       TOTAL_LIST_PRICE                NUMBER := FND_API.G_MISS_NUM,
       TOTAL_ADJUSTED_AMOUNT           NUMBER := FND_API.G_MISS_NUM,
       TOTAL_ADJUSTED_PERCENT          NUMBER := FND_API.G_MISS_NUM,
       TOTAL_TAX                       NUMBER := FND_API.G_MISS_NUM,
       TOTAL_SHIPPING_CHARGE           NUMBER := FND_API.G_MISS_NUM,
       SURCHARGE                       NUMBER := FND_API.G_MISS_NUM,
       TOTAL_QUOTE_PRICE               NUMBER := FND_API.G_MISS_NUM,
       PAYMENT_AMOUNT                  NUMBER := FND_API.G_MISS_NUM,
       CONTRACT_ID                     NUMBER := FND_API.G_MISS_NUM,
       SALES_CHANNEL_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ORDER_ID                        NUMBER := FND_API.G_MISS_NUM,
	  RECALCULATE_FLAG                VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PROMISE_DATE                    DATE := FND_API.G_MISS_DATE,
       REQUEST_DATE                    DATE := FND_API.G_MISS_DATE,
       SCHEDULE_SHIP_DATE              DATE := FND_API.G_MISS_DATE,
       SHIP_TO_PARTY_SITE_ID           NUMBER := FND_API.G_MISS_NUM,
       SHIP_TO_PARTY_ID                NUMBER := FND_API.G_MISS_NUM,
       SHIP_PARTIAL_FLAG               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SHIP_SET_ID                     NUMBER := FND_API.G_MISS_NUM,
       SHIP_METHOD_CODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FREIGHT_TERMS_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FREIGHT_CARRIER_CODE            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FOB_CODE                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SHIPPING_INSTRUCTIONS           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       PACKING_INSTRUCTIONS            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       EXCHANGE_TYPE_CODE              VARCHAR2(15) := FND_API.G_MISS_CHAR,
       EXCHANGE_RATE_DATE              DATE := FND_API.G_MISS_DATE,
       EXCHANGE_RATE                   NUMBER := FND_API.G_MISS_NUM,
	  MINISITE_ID                     NUMBER := FND_API.G_MISS_NUM,
	  -- bug 12696699
       ATTRIBUTE16                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       --Bug 21661093
       END_CUSTOMER_CUST_ACCOUNT_ID     NUMBER := FND_API.G_MISS_NUM
);

G_HEADER_REC	PRICING_HEADER_REC_TYPE;


TYPE PRICING_LINE_REC_TYPE IS RECORD
(
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       QUOTE_HEADER_ID                 NUMBER := FND_API.G_MISS_NUM,
       ORG_ID                          NUMBER := FND_API.G_MISS_NUM,
       LINE_CATEGORY_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ITEM_TYPE_CODE                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
       LINE_NUMBER                     NUMBER := FND_API.G_MISS_NUM,
       START_DATE_ACTIVE               DATE := FND_API.G_MISS_DATE,
       END_DATE_ACTIVE                 DATE := FND_API.G_MISS_DATE,
       ORDER_LINE_TYPE_ID              NUMBER := FND_API.G_MISS_NUM,
       INVOICE_TO_PARTY_SITE_ID        NUMBER := FND_API.G_MISS_NUM,
       INVOICE_TO_PARTY_ID             NUMBER := FND_API.G_MISS_NUM,
       ORGANIZATION_ID                 NUMBER := FND_API.G_MISS_NUM,
       INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
       QUANTITY                        NUMBER := FND_API.G_MISS_NUM,
       UOM_CODE                        VARCHAR2(3) := FND_API.G_MISS_CHAR,
       MARKETING_SOURCE_CODE_ID        NUMBER := FND_API.G_MISS_NUM,
       PRICE_LIST_ID                   NUMBER := FND_API.G_MISS_NUM,
       PRICE_LIST_LINE_ID              NUMBER := FND_API.G_MISS_NUM,
       CURRENCY_CODE                   VARCHAR2(15) := FND_API.G_MISS_CHAR,
       LINE_LIST_PRICE                 NUMBER := FND_API.G_MISS_NUM,
       LINE_ADJUSTED_AMOUNT            NUMBER := FND_API.G_MISS_NUM,
       LINE_ADJUSTED_PERCENT           NUMBER := FND_API.G_MISS_NUM,
       LINE_QUOTE_PRICE                NUMBER := FND_API.G_MISS_NUM,
       RELATED_ITEM_ID                 NUMBER := FND_API.G_MISS_NUM,
       ITEM_RELATIONSHIP_TYPE          VARCHAR2(15) := FND_API.G_MISS_CHAR,
       ACCOUNTING_RULE_ID              NUMBER := FND_API.G_MISS_NUM,
       INVOICING_RULE_ID               NUMBER := FND_API.G_MISS_NUM,
       MODEL_ID				    NUMBER := FND_API.G_MISS_NUM,
       SPLIT_SHIPMENT_FLAG             VARCHAR2(1) := FND_API.G_MISS_CHAR,
       BACKORDER_FLAG                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
	  PRICING_LINE_TYPE_INDICATOR     VARCHAR2(3) := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CONFIG_HEADER_ID                NUMBER := FND_API.G_MISS_NUM,
       CONFIG_REVISION_NUM             NUMBER := FND_API.G_MISS_NUM,
       COMPLETE_CONFIGURATION_FLAG     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       VALID_CONFIGURATION_FLAG        VARCHAR2(1) := FND_API.G_MISS_CHAR,
       COMPONENT_CODE                  VARCHAR2(1000) := FND_API.G_MISS_CHAR,
       SERVICE_COTERMINATE_FLAG        VARCHAR2(1) := FND_API.G_MISS_CHAR,
       SERVICE_DURATION                NUMBER := FND_API.G_MISS_NUM,
       SERVICE_PERIOD                  VARCHAR2(3) := FND_API.G_MISS_CHAR,
       SERVICE_UNIT_SELLING_PERCENT    NUMBER := FND_API.G_MISS_NUM,
       SERVICE_UNIT_LIST_PERCENT       NUMBER := FND_API.G_MISS_NUM,
       SERVICE_NUMBER                  NUMBER := FND_API.G_MISS_NUM,
       UNIT_PERCENT_BASE_PRICE         NUMBER := FND_API.G_MISS_NUM,
       SERVICE_REF_TYPE_CODE           VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SERVICE_REF_ORDER_NUMBER        NUMBER := FND_API.G_MISS_NUM,
       SERVICE_REF_LINE_NUMBER         NUMBER := FND_API.G_MISS_NUM,
       SERVICE_REF_LINE_ID             NUMBER := FND_API.G_MISS_NUM,
       SERVICE_REF_SYSTEM_ID           NUMBER := FND_API.G_MISS_NUM,
       SERVICE_REF_OPTION_NUMB         NUMBER := FND_API.G_MISS_NUM,
       SERVICE_REF_SHIPMENT_NUMB       NUMBER := FND_API.G_MISS_NUM,
       RETURN_REF_TYPE                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       RETURN_REF_HEADER_ID            NUMBER := FND_API.G_MISS_NUM,
       RETURN_REF_LINE_ID              NUMBER := FND_API.G_MISS_NUM,
       RETURN_ATTRIBUTE1               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE2               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE3               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE4               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE5               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE6               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE7               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE8               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE9               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE10              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE11              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE15              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE12              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE13              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE14              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RETURN_ATTRIBUTE_CATEGORY       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       RETURN_REASON_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PROMISE_DATE                    DATE := FND_API.G_MISS_DATE,
       REQUEST_DATE                    DATE := FND_API.G_MISS_DATE,
       SCHEDULE_SHIP_DATE              DATE := FND_API.G_MISS_DATE,
       SHIP_TO_PARTY_SITE_ID           NUMBER := FND_API.G_MISS_NUM,
       SHIP_TO_PARTY_ID                NUMBER := FND_API.G_MISS_NUM,
       SHIP_PARTIAL_FLAG               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SHIP_SET_ID                     NUMBER := FND_API.G_MISS_NUM,
       SHIP_METHOD_CODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FREIGHT_TERMS_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FREIGHT_CARRIER_CODE            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FOB_CODE                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SHIPPING_INSTRUCTIONS           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       PACKING_INSTRUCTIONS            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       SHIPPING_QUANTITY               NUMBER := FND_API.G_MISS_NUM,
       RESERVED_QUANTITY               VARCHAR2(240) := FND_API.G_MISS_NUM,
       RESERVATION_ID                  NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_PRIORITY_CODE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ORDER_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
	  INVOICE_TO_CUST_PARTY_ID        NUMBER := FND_API.G_MISS_NUM,
	  SELLING_PRICE_CHANGE            VARCHAR2(1) :=  FND_API.G_MISS_CHAR,
       RECALCULATE_FLAG                VARCHAR2(1) :=  FND_API.G_MISS_CHAR,
       AGREEMENT_ID                    NUMBER := FND_API.G_MISS_NUM,
	  MINISITE_ID                     NUMBER := FND_API.G_MISS_NUM,
	  CHARGE_PERIODICITY_CODE         VARCHAR2(3) :=  FND_API.G_MISS_CHAR,
	  PRICING_QUANTITY_UOM            VARCHAR2(3) :=  FND_API.G_MISS_CHAR,
	  PRICING_QUANTITY                NUMBER := FND_API.G_MISS_NUM,
	  -- bug 12696699
	ATTRIBUTE16                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       -- bug 17517305
       UNIT_PRICE                      NUMBER := FND_API.G_MISS_NUM,
       -- bug 21661093
       END_CUSTOMER_CUST_ACCOUNT_ID    NUMBER := FND_API.G_MISS_NUM
);

G_LINE_REC	PRICING_LINE_REC_TYPE;

FUNCTION Set_Global_Rec (
    p_qte_header_rec      ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    p_shipment_rec        ASO_QUOTE_PUB.Shipment_Rec_Type)
RETURN PRICING_HEADER_REC_TYPE;

FUNCTION Set_Global_Rec (
    p_qte_line_rec        ASO_QUOTE_PUB.Qte_Line_Rec_Type,
    p_qte_line_dtl_rec    ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type,
    p_shipment_rec        ASO_QUOTE_PUB.Shipment_Rec_Type)
RETURN PRICING_LINE_REC_TYPE;


--wli_start
FUNCTION Get_Customer_Class
(p_cust_account_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_Account_Type
(p_cust_account_id IN NUMBER)
RETURN QP_Attr_Mapping_PUB.t_MultiRecord;

FUNCTION Get_Sales_Channel
(p_cust_account_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_GSA
(p_cust_account_id NUMBER)
RETURN VARCHAR2;

FUNCTION Get_quote_Qty
(p_qte_header_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_quote_Amount(p_qte_header_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Get_shippable_flag(p_qte_line_id NUMBER)
RETURN VARCHAR2;
--wli_end

-- kchervel start
FUNCTION Get_Cust_Acct (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Ship_to_Site_Use (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Line_Ship_to_Site_Use (p_quote_line_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Invoice_to_Site_Use (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Line_Invoice_Site_Use (p_quote_line_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Ship_to_Party_Site (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Line_Ship_Party_Site (p_quote_line_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Invoice_to_Party_Site (p_quote_header_id NUMBER)
RETURN NUMBER;

FUNCTION Get_Line_Invoice_Party_Site (p_quote_line_id NUMBER)
RETURN NUMBER;

--FUNCTION Get_Party_Id (p_quote_header_id NUMBER)
--RETURN NUMBER;
-- kchervel end

PROCEDURE Pricing_Item (
        P_Api_Version_Number         IN   NUMBER,
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
        p_control_rec		       IN	  PRICING_CONTROL_REC_TYPE,
        p_qte_header_rec	            IN	  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        p_hd_shipment_rec	       IN	  ASO_QUOTE_PUB.Shipment_Rec_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
        p_hd_price_attr_tbl	       IN	  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
        p_qte_line_rec		       IN	  ASO_QUOTE_PUB.Qte_Line_Rec_Type,
        p_qte_line_dtl_rec	       IN	  ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Rec,
        p_ln_shipment_rec	       IN	  ASO_QUOTE_PUB.Shipment_Rec_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
        p_ln_price_attr_tbl	       IN	  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
        x_qte_line_tbl		       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        x_qte_line_dtl_tbl	       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
        x_price_adj_tbl		       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
        x_price_adj_attr_tbl	       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
        x_price_adj_rltship_tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
        x_return_status		       OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count		            OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data		            OUT NOCOPY /* file.sql.39 change */    VARCHAR2);

PROCEDURE Pricing_Order(
        P_Api_Version_Number         IN   NUMBER,
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
        p_control_rec		       IN	  PRICING_CONTROL_REC_TYPE,
        p_qte_header_rec	            IN	  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        p_hd_shipment_rec            IN	  ASO_QUOTE_PUB.Shipment_Rec_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Shipment_Rec,
        p_hd_price_attr_tbl          IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
                                          := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
        p_qte_line_tbl		       IN	  ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        p_line_rltship_tbl	       IN	  ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
    	                                     := ASO_QUOTE_PUB.G_Miss_Line_Rltship_Tbl,
        p_qte_line_dtl_tbl	       IN	  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Qte_Line_Dtl_Tbl,
        p_ln_shipment_tbl		  IN	  ASO_QUOTE_PUB.Shipment_Tbl_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Shipment_Tbl,
        p_ln_price_attr_tbl	       IN	  ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
    				                      := ASO_QUOTE_PUB.G_Miss_Price_Attributes_Tbl,
        x_qte_header_rec	            OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Header_Rec_Type,
        x_qte_line_tbl		       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        x_qte_line_dtl_tbl	       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type,
        x_price_adj_tbl		       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Tbl_Type,
        x_price_adj_attr_tbl	       OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type,
        x_price_adj_rltship_tbl      OUT NOCOPY /* file.sql.39 change */    ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type,
        x_return_status		       OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count		            OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data		            OUT NOCOPY /* file.sql.39 change */    VARCHAR2);

PROCEDURE Pricing_Item (
        P_Api_Version_Number         IN   NUMBER,
        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
        p_control_rec		       IN	  PRICING_CONTROL_REC_TYPE,
        p_qte_line_id		       IN	  NUMBER,
        x_return_status		      OUT NOCOPY /* file.sql.39 change */  	  VARCHAR2,
        x_msg_count		           OUT NOCOPY /* file.sql.39 change */  	  NUMBER,
        x_msg_data		           OUT NOCOPY /* file.sql.39 change */  	  VARCHAR2);

PROCEDURE Pricing_Order (
        P_Api_Version_Number  IN   NUMBER,
        P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
        P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
        p_control_rec		IN	PRICING_CONTROL_REC_TYPE,
        p_qte_line_tbl		IN	ASO_QUOTE_PUB.Qte_Line_Tbl_Type,
        p_qte_header_id		IN	NUMBER,
        x_return_status	    OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
        x_msg_count		    OUT NOCOPY /* file.sql.39 change */  	NUMBER,
        x_msg_data		    OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

Procedure Delete_Promotion (
        P_Api_Version_Number IN   NUMBER,
        P_Init_Msg_List      IN   VARCHAR2  := FND_API.G_FALSE,
        P_Commit             IN   VARCHAR2  := FND_API.G_FALSE,
	   p_price_attr_tbl     IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type,
        x_return_status      OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
        x_msg_count          OUT NOCOPY /* file.sql.39 change */    NUMBER,
        x_msg_data           OUT NOCOPY /* file.sql.39 change */    VARCHAR2);

-- hagrawal_start
FUNCTION Get_Cust_Po(
p_qte_header_id 	number
) RETURN  VARCHAR2;

FUNCTION Get_line_Cust_Po(
p_qte_line_id       number
) RETURN  VARCHAR2;

FUNCTION Get_Request_date(
p_qte_header_id 	number
) RETURN  DATE;

FUNCTION Get_line_Request_date(
p_qte_line_id 	number
) RETURN  DATE;

FUNCTION Get_Freight_term(
p_qte_header_id 	number
    ) RETURN  DATE;

FUNCTION Get_line_Freight_term(
p_qte_line_id    number
) RETURN  VARCHAR2;

FUNCTION Get_Payment_term(
p_qte_header_id 	number
) RETURN  NUMBER;

FUNCTION Get_line_Payment_term(
p_qte_line_id    number
) RETURN  NUMBER;

End ASO_PRICING_INT;

/
