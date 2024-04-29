--------------------------------------------------------
--  DDL for Package ASO_QUOTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_QUOTE_PUB" AUTHID CURRENT_USER as
/* $Header: asopqtes.pls 120.12.12010000.32 2016/03/30 20:12:57 akushwah ship $ */
/*# These public APIs allow users to create new quotes, modify existing quotes and convert quotes into orders.
 * @rep:scope public
 * @rep:product ASO
 * @rep:displayname Order Capture
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY ASO_QUOTE
*/



-- Start of Comments
-- Package name     : ASO_QUOTE_PUB
-- Purpose          :
--   This package contains specification for pl/sql records and tables and the
--   Public API of Order Capture.
--
--   Record Type:
--	Control_Rec_Type
--	Submit_Control_Rec_Type
--	Qte_Header_Rec_Type
--	Qte_Sort_Rec_Type
--	Qte_Line_Rec_Type
--	Qte_Line_sort_rec_type
--	Qte_Line_Dtl_Rec_Type
--	Price_Attributes_Rec_Type
--	Price_Adj_Rec_Type
--	PRICE_ADJ_ATTR_Rec_Type
--	Price_Adj_Rltship_Rec_Type
--	Payment_Rec_Type
--	Shipment_Rec_Type
--	Freight_Charge_Rec_Type
--	Tax_Detail_Rec_Type
--	Header_Rltship_Rec_Type
--	Line_Rltship_Rec_Type
--	Party_Rltship_Rec_Type
--	Related_Object_Rec_Type
--	Line_Attribs_Ext_Rec_Type
--     Config_Vaild_Rec_Type
--
--   Procedures:
--      Create_Quote
--	Update_Quote
--	Delete_Quote
--	Copy_Quote
--	Validate_Quote
--	Submit_Quote
--	Create_Quote_Line
--	Update_Quote_Line
--	Delete_Quote_Line
--	Get_Quote_Lines
--	Create_Line_Relationship
--	Update_Line_Relationship
--	Delete_Line_Relationship
--	Create_Header_Relationship
--	Update_Header_Relationship
--	Delete_Header_Relationship
--	Create_Party_Relationship
--	Update_Party_Relationship
--	Delete_Party_Relationship
--	Create_Object_Relationship
--	Update_Object_Relationship
--	Delete_Object_Relationship
--	Create_Price_Adj_Relationship
--	Update_Price_Adj_Relationship
--	Delete_Price_Adj_Relationship
--
-- History          :
-- NOTE             :

-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
OC_APPL_ID               NUMBER := 697;

--Define constants for macd
G_ADD_TO_CONTAINER  CONSTANT  VARCHAR2(16) := 'ADD_TO_CONTAINER';
G_RECONFIGURE       CONSTANT  VARCHAR2(11) := 'RECONFIGURE';
G_DEACTIVATE        CONSTANT  VARCHAR2(10) := 'DEACTIVATE';


TYPE Control_Rec_Type IS RECORD
(
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       AUTO_VERSION_FLAG	       VARCHAR2(1) :=  FND_API.G_MISS_CHAR,
       pricing_request_type	       VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
       header_pricing_event	       VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
       line_pricing_event	       VARCHAR2(30) :=  FND_API.G_MISS_CHAR,
       CALCULATE_TAX_FLAG	       VARCHAR2(1) :=  FND_API.G_MISS_CHAR,
       CALCULATE_FREIGHT_CHARGE_FLAG   VARCHAR2(1) :=  FND_API.G_MISS_CHAR,
       FUNCTIONALITY_CODE              VARCHAR2(240) := FND_API.G_MISS_CHAR,
	  COPY_TASK_FLAG                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
	  COPY_NOTES_FLAG                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
	  COPY_ATT_FLAG                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       DEACTIVATE_ALL                  VARCHAR2(1)   :=  FND_API.G_FALSE,
	  PRICE_MODE                     VARCHAR2(30) := 'ENTIRE_QUOTE',
	  QUOTE_SOURCE                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
	  DEPENDENCY_FLAG                VARCHAR2(1)   :=  FND_API.G_TRUE,
	  DEFAULTING_FLAG                VARCHAR2(1)   :=  FND_API.G_TRUE,
	  DEFAULTING_FWK_FLAG            VARCHAR2(1)   :=  'N',
	  APPLICATION_TYPE_CODE          VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
	  Change_Customer_flag           VARCHAR2(1)   := FND_API.G_FALSE
);



G_MISS_Control_Rec	Control_Rec_Type;

TYPE Submit_Control_Rec_Type IS RECORD
(
      BOOK_FLAG       VARCHAR2(1) := FND_API.G_FALSE,
      RESERVE_FLAG    VARCHAR2(1) := FND_API.G_FALSE,
      CALCULATE_PRICE VARCHAR2(1) := FND_API.G_FALSE,
      SERVER_ID       NUMBER      := -1,
	 CVV2            VARCHAR2(10)  := FND_API.G_MISS_CHAR,
      CC_BY_FAX       VARCHAR2(1) := FND_API.G_FALSE,
      APPLICATION_TYPE_CODE          VARCHAR2(30)  :=  FND_API.G_MISS_CHAR
);

G_MISS_Submit_Control_Rec Submit_Control_Rec_Type;


TYPE Sales_Alloc_Control_Rec_Type IS RECORD
(
	 Submit_Quote_Flag   VARCHAR2(1) := FND_API.G_FALSE
);

G_MISS_Sales_Alloc_Control_Rec Sales_Alloc_Control_Rec_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Qte_Header_Rec_Type
--   -------------------------------------------------------
--   Parameters:
-- QUOTE_HEADER_ID
-- CREATION_DATE
-- CREATED_BY
-- LAST_UPDATE_DATE
-- LAST_UPDATED_BY
-- LAST_UPDATE_LOGIN
-- REQUEST_ID
-- PROGRAM_APPLICATION_ID
-- PROGRAM_ID
-- PROGRAM_UPDATE_DATE
-- ORG_ID
-- QUOTE_NAME
-- QUOTE_NUMBER
-- QUOTE_VERSION
-- QUOTE_STATUS_ID
-- QUOTE_SOURCE_CODE
-- QUOTE_EXPIRATION_DATE
-- PRICE_FROZEN_DATE
-- QUOTE_PASSWORD
-- ORIGINAL_SYSTEM_REFERENCE
-- PARTY_ID
-- CUST_ACCOUNT_ID
-- INVOICE_TO_CUST_ACCOUNT_ID
-- ORG_CONTACT_ID
-- PHONE_ID
-- INVOICE_TO_PARTY_SITE_ID
-- INVOICE_TO_PARTY_ID
-- ORIG_MKTG_SOURCE_CODE_ID
-- MARKETING_SOURCE_CODE_ID
-- ORDER_TYPE_ID
-- QUOTE_CATEGORY_CODE
-- ORDERED_DATE
-- ACCOUNTING_RULE_ID
-- INVOICING_RULE_ID
-- EMPLOYEE_PERSON_ID
-- PRICE_LIST_ID
-- CURRENCY_CODE
-- TOTAL_LIST_PRICE
-- TOTAL_ADJUSTED_AMOUNT
-- TOTAL_ADJUSTED_PERCENT
-- TOTAL_TAX
-- TOTAL_SHIPPING_CHARGE
-- SURCHARGE
-- TOTAL_QUOTE_PRICE
-- PAYMENT_AMOUNT
-- EXCHANGE_RATE
-- EXCHANGE_TYPE_CODE
-- EXCHANGE_RATE_DATE
-- CONTRACT_ID
-- SALES_CHANNEL_CODE
-- ORDER_ID
-- ORDER_NUMBER
-- FFM_REQUEST_ID
-- QTE_CONTRACT_ID
-- ATTRIBUTE_CATEGORY
-- ATTRIBUTE1
-- ATTRIBUTE2
-- ATTRIBUTE3
-- ATTRIBUTE4
-- ATTRIBUTE5
-- ATTRIBUTE6
-- ATTRIBUTE7
-- ATTRIBUTE8
-- ATTRIBUTE9
-- ATTRIBUTE10
-- ATTRIBUTE11
-- ATTRIBUTE12
-- ATTRIBUTE13
-- ATTRIBUTE14
-- ATTRIBUTE15
-- SALESREP_FIRST_NAME
-- SALESREP_LAST_NAME
-- PRICE_LIST_NAME
-- QUOTE_STATUS_CODE
-- QUOTE_STATUS
-- PARTY_NAME
-- PARTY_TYPE
-- PERSON_FIRST_NAME
-- PERSON_MIDDLE_NAME
-- PERSON_LAST_NAME
-- MARKETING_SOURCE_NAME
-- MARKETING_SOURCE_CODE
-- ORDER_TYPE_NAME
-- INVOICE_TO_PARTY_NAME
-- INVOICE_TO_CONTACT_FIRST_NAME
-- INVOICE_TO_CONTACT_MIDDLE_NAME
-- INVOICE_TO_CONTACT_LAST_NAME
-- INVOICE_TO_ADDRESS1
-- INVOICE_TO_ADDRESS2
-- INVOICE_TO_ADDRESS3
-- INVOICE_TO_ADDRESS4
-- INVOICE_TO_COUNTRY_CODE
-- INVOICE_TO_COUNTRY
-- INVOICE_TO_CITY
-- INVOICE_TO_POSTAL_CODE
-- INVOICE_TO_STATE
-- INVOICE_TO_PROVINCE
-- INVOICE_TO_COUNTY
-- RESOURCE_ID
-- CONTRACT_TEMPLATE_ID
-- CONTRACT_TEMPLATE_MAJOR_VER
-- CONTRACT_REQUESTER_ID
-- CONTRACT_APPROVAL_LEVEL
-- PUBLISH_FLAG
-- RESOURCE_GRP_ID
-- SOLD_TO_PARTY_SITE_ID
-- DISPLAY_ARITHMETIC_OPERATOR
-- MAX_VERSION_FLAG
-- QUOTE_TYPE
-- QUOTE_DESCRIPTION
-- CALL_BATCH_VALIDATION_FLAG
-- CUST_PARTY_ID
-- INVOICE_TO_CUST_PARTY_ID
-- MINISITE_ID
-- PRICING_STATUS_INDICATOR
-- TAX_STATUS_INDICATOR
-- PRICE_UPDATED_DATE
-- TAX_UPDATED_DATE
-- RECALCULATE_FLAG
-- BATCH_PRICE_FLAG
-- PRICE_REQUEST_ID
-- CREDIT_UPDATE_DATE
-- Customer_Name_And_Title
-- Customer_Signature_Date
-- Supplier_Name_And_Title
-- Supplier_Signature_Date
-- OBJECT_VERSION_NUMBER
-- ASSISTANCE_REQUESTED
-- ASSISTANCE_REASON_CODE
-- AUTOMATIC_PRICE_FLAG
-- AUTOMATIC_TAX_FLAG
-- END_CUSTOMER_PARTY_ID
-- END_CUSTOMER_PARTY_SITE_ID
-- END_CUSTOMER_CUST_ACCOUNT_ID
-- END_CUSTOMER_CUST_PARTY_ID
-- ATTRIBUTE16
-- ATTRIBUTE17
-- ATTRIBUTE18
-- ATTRIBUTE19
-- ATTRIBUTE20
-- HEADER_PAYNOW_CHARGES
-- PRODUCT_FISC_CLASSIFICATION
-- TRX_BUSINESS_CATEGORY
-- TOTAL_UNIT_COST
-- TOTAL_MARGIN_AMOUNT
-- TOTAL_MARGIN_PERCENT
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comment



TYPE Qte_Header_Rec_Type IS RECORD
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
       PARTY_ID                        NUMBER := FND_API.G_MISS_NUM,
       CUST_ACCOUNT_ID                 NUMBER := FND_API.G_MISS_NUM,
       INVOICE_TO_CUST_ACCOUNT_ID     NUMBER := FND_API.G_MISS_NUM,
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
       EXCHANGE_RATE                   NUMBER := FND_API.G_MISS_NUM,
       EXCHANGE_TYPE_CODE              VARCHAR2(15) := FND_API.G_MISS_CHAR,
       EXCHANGE_RATE_DATE              DATE := FND_API.G_MISS_DATE,
       CONTRACT_ID                     NUMBER := FND_API.G_MISS_NUM,
       SALES_CHANNEL_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ORDER_ID                        NUMBER := FND_API.G_MISS_NUM,
       ORDER_NUMBER                    NUMBER := FND_API.G_MISS_NUM,
       FFM_REQUEST_ID                  NUMBER := FND_API.G_MISS_NUM,
       QTE_CONTRACT_ID                 NUMBER := FND_API.G_MISS_NUM,
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
       SALESREP_FIRST_NAME	       VARCHAR2(255) := FND_API.G_MISS_CHAR,
       SALESREP_LAST_NAME	       VARCHAR2(255) := FND_API.G_MISS_CHAR,
       PRICE_LIST_NAME	               VARCHAR2(255) := FND_API.G_MISS_CHAR,
       QUOTE_STATUS_CODE               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QUOTE_STATUS                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PARTY_NAME		       VARCHAR2(255) := FND_API.G_MISS_CHAR,
       PARTY_TYPE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PERSON_FIRST_NAME	       VARCHAR2(150) := FND_API.G_MISS_CHAR,
       PERSON_MIDDLE_NAME	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       PERSON_LAST_NAME                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       MARKETING_SOURCE_NAME	       VARCHAR2(150) := FND_API.G_MISS_CHAR,
       MARKETING_SOURCE_CODE	       VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ORDER_TYPE_NAME		       VARCHAR2(240) := FND_API.G_MISS_CHAR,
       INVOICE_TO_PARTY_NAME	       VARCHAR2(255) := FND_API.G_MISS_CHAR,
       INVOICE_TO_CONTACT_FIRST_NAME   VARCHAR2(150) := FND_API.G_MISS_CHAR,
       INVOICE_TO_CONTACT_MIDDLE_NAME  VARCHAR2(60) := FND_API.G_MISS_CHAR,
       INVOICE_TO_CONTACT_LAST_NAME    VARCHAR2(150) := FND_API.G_MISS_CHAR,
       INVOICE_TO_ADDRESS1	       VARCHAR2(240) := FND_API.G_MISS_CHAR,
       INVOICE_TO_ADDRESS2	       VARCHAR2(240) := FND_API.G_MISS_CHAR,
       INVOICE_TO_ADDRESS3	       VARCHAR2(240) := FND_API.G_MISS_CHAR,
       INVOICE_TO_ADDRESS4	       VARCHAR2(240) := FND_API.G_MISS_CHAR,
       INVOICE_TO_COUNTRY_CODE	       VARCHAR2(80) := FND_API.G_MISS_CHAR,
       INVOICE_TO_COUNTRY	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       INVOICE_TO_CITY	 	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       INVOICE_TO_POSTAL_CODE	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       INVOICE_TO_STATE	               VARCHAR2(60) := FND_API.G_MISS_CHAR,
       INVOICE_TO_PROVINCE	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       INVOICE_TO_COUNTY	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       RESOURCE_ID                     NUMBER  := FND_API.G_MISS_NUM,
       CONTRACT_TEMPLATE_ID                     NUMBER  := FND_API.G_MISS_NUM,
       CONTRACT_TEMPLATE_MAJOR_VER          NUMBER  := FND_API.G_MISS_NUM,
       CONTRACT_REQUESTER_ID           NUMBER  := FND_API.G_MISS_NUM,
       CONTRACT_APPROVAL_LEVEL         VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PUBLISH_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       RESOURCE_GRP_ID                 NUMBER  := FND_API.G_MISS_NUM,
       SOLD_TO_PARTY_SITE_ID           NUMBER  := FND_API.G_MISS_NUM,
       DISPLAY_ARITHMETIC_OPERATOR	    VARCHAR2(30)  :=  FND_API.G_MISS_CHAR,
	  MAX_VERSION_FLAG                VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
	  QUOTE_TYPE                      VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
	  QUOTE_DESCRIPTION               VARCHAR2(240) :=  FND_API.G_MISS_CHAR,
       CALL_BATCH_VALIDATION_FLAG      VARCHAR2(1)   :=  FND_API.G_TRUE,
	  CUST_PARTY_ID                   NUMBER        :=  FND_API.G_MISS_NUM,
	  INVOICE_TO_CUST_PARTY_ID        NUMBER        :=  FND_API.G_MISS_NUM,
	  MINISITE_ID                     NUMBER        :=  FND_API.G_MISS_NUM,
       PRICING_STATUS_INDICATOR        VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
       TAX_STATUS_INDICATOR            VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
       PRICE_UPDATED_DATE              DATE          :=  FND_API.G_MISS_DATE,
       TAX_UPDATED_DATE                DATE          :=  FND_API.G_MISS_DATE,
       RECALCULATE_FLAG                VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
       BATCH_PRICE_FLAG                VARCHAR2(1)   :=  FND_API.G_MISS_CHAR,
       PRICE_REQUEST_ID                NUMBER        :=  FND_API.G_MISS_NUM,
       CREDIT_UPDATE_DATE              DATE          :=  FND_API.G_MISS_DATE,
-- hyang new okc
    Customer_Name_And_Title           VARCHAR2(240)   :=  FND_API.G_MISS_CHAR,
    Customer_Signature_Date           DATE            :=  FND_API.G_MISS_DATE,
    Supplier_Name_And_Title           VARCHAR2(240)   :=  FND_API.G_MISS_CHAR,
    Supplier_Signature_Date           DATE            :=  FND_API.G_MISS_DATE,
-- end of hyang new okc
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM,
	  ASSISTANCE_REQUESTED           VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,
	  ASSISTANCE_REASON_CODE         VARCHAR2(30)    :=  FND_API.G_MISS_CHAR,
	  AUTOMATIC_PRICE_FLAG           VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,
	  AUTOMATIC_TAX_FLAG             VARCHAR2(1)     :=  FND_API.G_MISS_CHAR,
	  END_CUSTOMER_PARTY_ID          NUMBER          :=  FND_API.G_MISS_NUM,
	  END_CUSTOMER_PARTY_SITE_ID     NUMBER          :=  FND_API.G_MISS_NUM,
	  END_CUSTOMER_CUST_ACCOUNT_ID   NUMBER          :=  FND_API.G_MISS_NUM,
	  END_CUSTOMER_CUST_PARTY_ID     NUMBER          :=  FND_API.G_MISS_NUM,
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       HEADER_PAYNOW_CHARGES          NUMBER          := FND_API.G_MISS_NUM,
       -- ER 12879412
        PRODUCT_FISC_CLASSIFICATION VARCHAR2(240)  := FND_API.G_MISS_CHAR,
       TRX_BUSINESS_CATEGORY             VARCHAR2(240)   := FND_API.G_MISS_CHAR,
        -- ER 21158830
       TOTAL_UNIT_COST              NUMBER          :=  FND_API.G_MISS_NUM,
       TOTAL_MARGIN_AMOUNT          NUMBER          :=  FND_API.G_MISS_NUM,
       TOTAL_MARGIN_PERCENT         NUMBER          :=  FND_API.G_MISS_NUM
);

G_MISS_QTE_HEADER_REC          Qte_Header_Rec_Type;
TYPE  Qte_Header_Tbl_Type      IS TABLE OF Qte_Header_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_QTE_HEADER_TBL          Qte_Header_Tbl_Type;


TYPE QTE_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      QUOTE_HEADER_ID   NUMBER := NULL
);

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:QTE_LINE_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    QUOTE_LINE_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    QUOTE_HEADER_ID
--    ORG_ID
--    LINE_CATEGORY_CODE
--    ITEM_TYPE_CODE
--    LINE_NUMBER
--    START_DATE_ACTIVE
--    END_DATE_ACTIVE
--    ORDER_LINE_TYPE_ID
--    INVOICE_TO_PARTY_SITE_ID
--    INVOICE_TO_PARTY_ID
--    ORGANIZATION_ID
--    INVENTORY_ITEM_ID
--    QUANTITY
--    UOM_CODE
--    MARKETING_SOURCE_CODE_ID
--    PRICE_LIST_ID
--    PRICE_LIST_LINE_ID
--    CURRENCY_CODE
--    LINE_LIST_PRICE
--    LINE_ADJUSTED_AMOUNT
--    LINE_ADJUSTED_PERCENT
--    LINE_QUOTE_PRICE
--    RELATED_ITEM_ID
--    ITEM_RELATIONSHIP_TYPE
--    ACCOUNTING_RULE_ID
--    INVOICING_RULE_ID
--    SPLIT_SHIPMENT_FLAG
--    BACKORDER_FLAG
--    MINISITE_ID
--    SECTION_ID
--    SELLING_PRICE_CHANGE
--    RECALCULATE_FLAG
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--    FFM_CONTENT_NAME
--    FFM_DOCUMENT_TYPE
--    FFM_MEDIA_TYPE
--    FFM_MEDIA_ID
--    FFM_CONTENT_TYPE
--    FFM_USER_NOTE
--    PRICED_PRICE_LIST_ID
--    AGREEMENT_ID
--    COMMITMENT_ID
--    PRICING_QUANTITY_UOM
--    PRICING_QUANTITY
--    OBJECT_VERSION_NUMBER
--    SHIP_MODEL_COMPLETE_FLAG
--    END_CUSTOMER_PARTY_ID
--    END_CUSTOMER_PARTY_SITE_ID
--    END_CUSTOMER_CUST_ACCOUNT_ID
--    END_CUSTOMER_CUST_PARTY_ID
--    CHARGE_PERIODICITY_CODE
--    ATTRIBUTE16
--    ATTRIBUTE17
--    ATTRIBUTE18
--    ATTRIBUTE19
--    ATTRIBUTE20
--    LINE_PAYNOW_CHARGES
--    LINE_PAYNOW_TAX
--    LINE_PAYNOW_SUBTOTAL
--    PRICING_QUANTITY
--    CONFIG_MODEL_TYPE
--    subinventory
--    PRODUCT_FISC_CLASSIFICATION
--    TRX_BUSINESS_CATEGORY
--    ORDERED_ITEM_ID
--    ORDERED_ITEM
--    ITEM_IDENTIFIER_TYPE
--    PREFERRED_GRADE
--    ORDERED_QUANTITY2
--    ORDERED_QUANTITY_UOM2
--    LINE_UNIT_COST
--    LINE_MARGIN_AMOUNT
--    LINE_MARGIN_PERCENT
--    QUANTITY_UOM_CHANGE
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE QTE_LINE_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
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
       INVOICE_TO_CUST_ACCOUNT_ID      NUMBER := FND_API.G_MISS_NUM,
       ORGANIZATION_ID                 NUMBER := FND_API.G_MISS_NUM,
       INVENTORY_ITEM_ID               NUMBER := FND_API.G_MISS_NUM,
       QUANTITY                        NUMBER := FND_API.G_MISS_NUM,
       UOM_CODE                        VARCHAR2(3) := FND_API.G_MISS_CHAR,
       PRICING_QUANTITY_UOM            VARCHAR2(3) := FND_API.G_MISS_CHAR,
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
       SPLIT_SHIPMENT_FLAG             VARCHAR2(1) := FND_API.G_MISS_CHAR,
       BACKORDER_FLAG                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       MINISITE_ID                     NUMBER := FND_API.G_MISS_NUM,
       SECTION_ID                      NUMBER := FND_API.G_MISS_NUM,
       SELLING_PRICE_CHANGE             VARCHAR2(1) := FND_API.G_MISS_CHAR,
       RECALCULATE_FLAG             VARCHAR2(1) := FND_API.G_MISS_CHAR,
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
       FFM_CONTENT_NAME                VARCHAR2(250) := FND_API.G_MISS_CHAR,
       FFM_DOCUMENT_TYPE               VARCHAR2(250) := FND_API.G_MISS_CHAR,
       FFM_MEDIA_TYPE                  VARCHAR2(250) := FND_API.G_MISS_CHAR,
       FFM_MEDIA_ID                    VARCHAR2(250) := FND_API.G_MISS_CHAR,
       FFM_CONTENT_TYPE                VARCHAR2(250) := FND_API.G_MISS_CHAR,
       FFM_USER_NOTE                   VARCHAR2(250) := FND_API.G_MISS_CHAR,
       PRICED_PRICE_LIST_ID            NUMBER := FND_API.G_MISS_NUM,
       AGREEMENT_ID                    NUMBER := FND_API.G_MISS_NUM,
       COMMITMENT_ID                   NUMBER := FND_API.G_MISS_NUM,
       DISPLAY_ARITHMETIC_OPERATOR     VARCHAR2(30)   := FND_API.G_MISS_CHAR,
       PRICING_STATUS_CODE             VARCHAR2(1)    := FND_API.G_MISS_CHAR,
       PRICING_STATUS_TEXT             VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       LINE_TYPE_SOURCE_FLAG           VARCHAR2(1)    := FND_API.G_MISS_CHAR,
	  SERVICE_ITEM_FLAG               VARCHAR2(1)    := FND_API.G_MISS_CHAR,
	  SERVICEABLE_PRODUCT_FLAG        VARCHAR2(1)    := FND_API.G_MISS_CHAR,
	  INVOICE_TO_CUST_PARTY_ID        NUMBER         := FND_API.G_MISS_NUM,
       IS_LINE_CHANGED_FLAG            VARCHAR2(1)    := FND_API.G_MISS_CHAR,
	  UI_LINE_NUMBER                  VARCHAR2(4000) := FND_API.G_MISS_CHAR,
	  PRICING_LINE_TYPE_INDICATOR     VARCHAR2(3)    := FND_API.G_MISS_CHAR,
	  ITEM_REVISION                   VARCHAR2(3)    := FND_API.G_MISS_CHAR,
	  OBJECT_VERSION_NUMBER           NUMBER         := FND_API.G_MISS_NUM,
	  SHIP_MODEL_COMPLETE_FLAG        VARCHAR2(1)    := FND_API.G_MISS_CHAR,
	  END_CUSTOMER_PARTY_ID           NUMBER         := FND_API.G_MISS_NUM,
	  END_CUSTOMER_PARTY_SITE_ID      NUMBER         := FND_API.G_MISS_NUM,
	  END_CUSTOMER_CUST_ACCOUNT_ID    NUMBER         := FND_API.G_MISS_NUM,
	  END_CUSTOMER_CUST_PARTY_ID      NUMBER         := FND_API.G_MISS_NUM,
	  CHARGE_PERIODICITY_CODE         VARCHAR2(3)    := FND_API.G_MISS_CHAR,
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       LINE_PAYNOW_CHARGES             NUMBER         := FND_API.G_MISS_NUM,
       LINE_PAYNOW_TAX                 NUMBER         := FND_API.G_MISS_NUM,
       LINE_PAYNOW_SUBTOTAL            NUMBER         := FND_API.G_MISS_NUM,
	  PRICING_QUANTITY                NUMBER         := FND_API.G_MISS_NUM,
       CONFIG_MODEL_TYPE               VARCHAR2(30)   := FND_API.G_MISS_CHAR
       , subinventory   VARCHAR2(10)   := FND_API.G_MISS_CHAR,
       -- ER 12879412
      PRODUCT_FISC_CLASSIFICATION VARCHAR2(240)  := FND_API.G_MISS_CHAR,
      TRX_BUSINESS_CATEGORY             VARCHAR2(240)   := FND_API.G_MISS_CHAR
	     --ER 16531247
    ,ORDERED_ITEM_ID number := FND_API.G_MISS_NUM
	,ORDERED_ITEM varchar2(2000) := FND_API.G_MISS_CHAR
,ITEM_IDENTIFIER_TYPE varchar2(30) := FND_API.G_MISS_CHAR
       --ER 17968970
	   ,PREFERRED_GRADE varchar2(150) := FND_API.G_MISS_CHAR
   	   ,ORDERED_QUANTITY2 NUMBER := FND_API.G_MISS_NUM
	   ,ORDERED_QUANTITY_UOM2 varchar2(3) := FND_API.G_MISS_CHAR
	-- Not done bug 17517305
           --,UNIT_PRICE                      NUMBER := FND_API.G_MISS_NUM
	-- ER 21158830
       ,LINE_UNIT_COST              NUMBER          :=  FND_API.G_MISS_NUM
       ,LINE_MARGIN_AMOUNT          NUMBER          :=  FND_API.G_MISS_NUM
       ,LINE_MARGIN_PERCENT         NUMBER          :=  FND_API.G_MISS_NUM
	   ,ORIG_SYS_DOCUMENT_REF       VARCHAR2(50)    :=  FND_API.G_MISS_CHAR --bug21237538
	   ,QUANTITY_UOM_CHANGE     VARCHAR2(1) := FND_API.G_MISS_CHAR   -- added for Bug 22582573 , Bug 23026038
	   --ER 7428770
	    ,CONFIG_HEADER_ID NUMBER DEFAULT FND_API.G_MISS_NUM
         ,CONFIG_REVISION_NBR NUMBER DEFAULT FND_API.G_MISS_NUM
);

G_MISS_QTE_LINE_REC          QTE_LINE_Rec_Type;
TYPE  QTE_LINE_Tbl_Type      IS TABLE OF QTE_LINE_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_QTE_LINE_TBL          QTE_LINE_Tbl_Type;


TYPE Qte_Line_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      QUOTE_HEADER_ID   NUMBER := NULL
);


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Qte_Line_Dtl_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    QUOTE_LINE_ID
--    QUOTE_LINE_DETAIL_ID
--    CONFIG_HEADER_ID
--    COMPLETE_CONFIGURATION
--    CONFIG_REV_NBR
--    VALID_CONFIGURATION
--    CP_SERVICE_ID
--    SERVICE_COTERMINATE_FLAG
--    SERVICE_DURATION
--    ORG_ID
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE qte_line_dtl_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       QUOTE_LINE_DETAIL_ID            NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       CONFIG_HEADER_ID                NUMBER := FND_API.G_MISS_NUM,
       CONFIG_REVISION_NUM             NUMBER := FND_API.G_MISS_NUM,
       CONFIG_ITEM_ID                  NUMBER := FND_API.G_MISS_NUM,
       COMPLETE_CONFIGURATION_FLAG     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       VALID_CONFIGURATION_FLAG        VARCHAR2(1) := FND_API.G_MISS_CHAR,
       COMPONENT_CODE                  VARCHAR2(1200) := FND_API.G_MISS_CHAR,
       SERVICE_COTERMINATE_FLAG        VARCHAR2(1) := FND_API.G_MISS_CHAR,
       SERVICE_DURATION                NUMBER := FND_API.G_MISS_NUM,
       SERVICE_PERIOD                  VARCHAR2(3) := FND_API.G_MISS_CHAR,
       SERVICE_UNIT_SELLING_PERCENT    NUMBER := FND_API.G_MISS_NUM,
       SERVICE_UNIT_LIST_PERCENT       NUMBER := FND_API.G_MISS_NUM,
       SERVICE_NUMBER                  NUMBER := FND_API.G_MISS_NUM,
       UNIT_PERCENT_BASE_PRICE         NUMBER := FND_API.G_MISS_NUM,
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
       SERVICE_REF_TYPE_CODE           VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SERVICE_REF_ORDER_NUMBER        NUMBER := FND_API.G_MISS_NUM,
       SERVICE_REF_LINE_NUMBER         NUMBER := FND_API.G_MISS_NUM,
       SERVICE_REF_QTE_LINE_INDEX      NUMBER := FND_API.G_MISS_NUM,
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
       CHANGE_REASON_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PARENT_CONFIG_ITEM_ID           NUMBER       := FND_API.G_MISS_NUM,
       REF_TYPE_CODE                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       REF_LINE_ID                     NUMBER       := FND_API.G_MISS_NUM,
       REF_LINE_INDEX                  NUMBER       := FND_API.G_MISS_NUM,
       INSTANCE_ID                     NUMBER       := FND_API.G_MISS_NUM,
       BOM_SORT_ORDER                  VARCHAR2(480) := FND_API.G_MISS_CHAR,
       CONFIG_DELTA                    NUMBER        := FND_API.G_MISS_NUM,
       CONFIG_INSTANCE_NAME            VARCHAR2(255) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER           NUMBER        :=  FND_API.G_MISS_NUM,
       TOP_MODEL_LINE_ID               NUMBER       := FND_API.G_MISS_NUM,
       TOP_MODEL_LINE_INDEX            NUMBER       := FND_API.G_MISS_NUM,
       ATO_LINE_ID                     NUMBER       := FND_API.G_MISS_NUM,
       ATO_LINE_INDEX                  NUMBER       := FND_API.G_MISS_NUM,
	  COMPONENT_SEQUENCE_ID           NUMBER       := FND_API.G_MISS_NUM,
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR
);

G_MISS_Qte_Line_Dtl_REC          Qte_Line_Dtl_Rec_Type;
TYPE  Qte_Line_Dtl_Tbl_Type      IS TABLE OF Qte_Line_Dtl_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Qte_Line_Dtl_TBL          Qte_Line_Dtl_Tbl_Type;

--bug 11696691
 TYPE  Qte_Line_Dtl_Tbl_Type1      IS TABLE OF Qte_Line_Dtl_Rec_Type
                                     INDEX BY VARCHAR2(32767);
 G_MISS_Qte_Line_Dtl_TBL1          Qte_Line_Dtl_Tbl_Type1;
 -- end bug 11696691



--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: Price_Attributes_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    PRICE_ATTRIBUTES_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    QUOTE_HEADER_ID
--    QUOTE_LINE_ID
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--    OBJECT_VERSION_NUMBER
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE  Price_Attributes_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       PRICE_ATTRIBUTE_ID              NUMBER := FND_API.G_MISS_NUM,
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
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       FLEX_TITLE                      VARCHAR2(60) := FND_API.G_MISS_CHAR,
       PRICING_CONTEXT                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE1              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE2              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE3              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE4              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE5              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE6              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE7              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE8              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE9              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE10             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE11             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE12             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE13             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE14             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE15             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE16              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE17              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE18             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE19             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE20             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE21             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE22             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE23              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE24              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE25             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE26             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE27             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE28             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE29             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE30             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE31              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE32              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE33              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE34              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE35              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE36              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE37              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE38              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE39              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE40             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE41             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE42             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE43             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE44             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE45             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE46              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE47              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE48             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE49             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE50              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE51              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE52             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE53             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE54             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE55             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE56             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE57             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE58             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE59             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE60             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE61              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE62              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE63              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE64              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE65              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE66              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE67              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE68              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE69              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE70             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE71             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE72             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE73             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE74             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE75             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE76              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE77              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE78             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE79             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE80             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE81             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE82             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE83              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE84              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE85             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE86             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE87             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE88             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE89             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE90             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE91              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE92              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE93              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE94              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE95              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE96              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE97              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE98              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE99              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE100             VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CONTEXT				VARCHAR2(30) := FND_API.G_MISS_CHAR,
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
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM
);

G_MISS_Price_Attributes_REC          Price_Attributes_Rec_Type;
TYPE Price_Attributes_Tbl_Type      IS TABLE OF Price_Attributes_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Price_Attributes_TBL          Price_Attributes_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Price_Adj_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    PRICE_ADJUSTMENT_ID
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    REQUEST_ID
--    HEADER_ID
--    LINE_ID
--    MODIFIER_HEADER_ID
--    MODIFIER_LINE_ID
--    MODIFER_LINE_TYPE_CODE
--    MODIFIER_MECHANISM_TYPE_CODE
--    MODIFIED_FROM
--    MODIFIER_TO
--    AUTOMATIC_FLAG
--    UPDATE_ALLOWABLE_FLAG
--    UPDATED_FLAG
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--    OBJECT_VERSION_NUMBER
--    OPERAND_PER_PQTY
--    ADJUSTED_AMOUNT_PER_PQTY
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Price_Adj_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_INDEX                  NUMBER := FND_API.G_MISS_NUM,
       PRICE_ADJUSTMENT_ID             NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       QUOTE_HEADER_ID                 NUMBER := FND_API.G_MISS_NUM,
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       QUOTE_SHIPMENT_ID               NUMBER := FND_API.G_MISS_NUM,
       MODIFIER_HEADER_ID              NUMBER := FND_API.G_MISS_NUM,
       MODIFIER_LINE_ID                NUMBER := FND_API.G_MISS_NUM,
       MODIFIER_LINE_TYPE_CODE         VARCHAR2(30) := FND_API.G_MISS_CHAR,
       MODIFIER_MECHANISM_TYPE_CODE    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       MODIFIED_FROM                   NUMBER := FND_API.G_MISS_NUM,
       MODIFIED_TO                     NUMBER := FND_API.G_MISS_NUM,
       OPERAND                         NUMBER := FND_API.G_MISS_NUM,
       ARITHMETIC_OPERATOR             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       AUTOMATIC_FLAG                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       UPDATE_ALLOWABLE_FLAG           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       UPDATED_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       APPLIED_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ON_INVOICE_FLAG                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       PRICING_PHASE_ID                NUMBER := FND_API.G_MISS_NUM,
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
       ORIG_SYS_DISCOUNT_REF           VARCHAR2(50):= FND_API.G_MISS_CHAR ,
       CHANGE_SEQUENCE                 VARCHAR2(50) := FND_API.G_MISS_CHAR ,
--       LIST_HEADER_ID                           NUMBER := FND_API.G_MISS_NUM,
--       LIST_LINE_ID                             NUMBER := FND_API.G_MISS_NUM,
--       LIST_LINE_TYPE_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       UPDATE_ALLOWED                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       CHANGE_REASON_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CHANGE_REASON_TEXT              VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       COST_ID                         NUMBER := FND_API.G_MISS_NUM,
       TAX_CODE                        VARCHAR2(50) := FND_API.G_MISS_CHAR,
       TAX_EXEMPT_FLAG                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       TAX_EXEMPT_NUMBER               VARCHAR2(80) := FND_API.G_MISS_CHAR,
       TAX_EXEMPT_REASON_CODE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PARENT_ADJUSTMENT_ID            NUMBER := FND_API.G_MISS_NUM,
       INVOICED_FLAG                   VARCHAR2(1) := FND_API.G_MISS_CHAR,
       ESTIMATED_FLAG                  VARCHAR2(1) := FND_API.G_MISS_CHAR,
       INC_IN_SALES_PERFORMANCE        VARCHAR2(1) := FND_API.G_MISS_CHAR,
       SPLIT_ACTION_CODE               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ADJUSTED_AMOUNT                 NUMBER := FND_API.G_MISS_NUM,
       CHARGE_TYPE_CODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CHARGE_SUBTYPE_CODE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       RANGE_BREAK_QUANTITY            NUMBER := FND_API.G_MISS_NUM,
       ACCRUAL_CONVERSION_RATE         NUMBER := FND_API.G_MISS_NUM,
       PRICING_GROUP_SEQUENCE          NUMBER := FND_API.G_MISS_NUM,
       ACCRUAL_FLAG                    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       LIST_LINE_NO                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SOURCE_SYSTEM_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       BENEFIT_QTY                     NUMBER := FND_API.G_MISS_NUM,
       BENEFIT_UOM_CODE                VARCHAR2(3) := FND_API.G_MISS_CHAR,
       PRINT_ON_INVOICE_FLAG           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       EXPIRATION_DATE                 DATE := FND_API.G_MISS_DATE,
       REBATE_TRANSACTION_TYPE_CODE    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       REBATE_TRANSACTION_REFERENCE    VARCHAR2(80) := FND_API.G_MISS_CHAR,
       REBATE_PAYMENT_SYSTEM_CODE      VARCHAR2(30) := FND_API.G_MISS_CHAR,
       REDEEMED_DATE                   DATE  := FND_API.G_MISS_DATE,
       REDEEMED_FLAG                   VARCHAR2(1) := FND_API.G_MISS_CHAR,
       MODIFIER_LEVEL_CODE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRICE_BREAK_TYPE_CODE           VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SUBSTITUTION_ATTRIBUTE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRORATION_TYPE_CODE             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       INCLUDE_ON_RETURNS_FLAG         VARCHAR2(1) := FND_API.G_MISS_CHAR,
       CREDIT_OR_CHARGE_FLAG           VARCHAR2(1) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM,
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       OPERAND_PER_PQTY               NUMBER          :=  FND_API.G_MISS_NUM,
       ADJUSTED_AMOUNT_PER_PQTY       NUMBER          :=  FND_API.G_MISS_NUM
);
G_MISS_Price_Adj_REC          Price_Adj_Rec_Type;
TYPE  Price_Adj_Tbl_Type      IS TABLE OF Price_Adj_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Price_Adj_TBL          Price_Adj_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:PRICE_ADJ_ATTR_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    PRICE_ADJ_ATTRIB_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    REQUEST_ID
--    PRICE_ADJUSTMENT_ID
--    PRICING_CONTEXT
--    PRICING_ATTRIBUTE
--    PRICING_ATTR_VALUE_FROM
--    PRICING_ATTR_VALUE_TO
--    COMPARISON_OPERATOR
--    FLEX_TITLE
--    OBJECT_VERSION_NUMBER
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE PRICE_ADJ_ATTR_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       PRICE_ADJ_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       PRICE_ADJ_ATTRIB_ID             NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE   := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE   := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE   := FND_API.G_MISS_DATE,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PRICE_ADJUSTMENT_ID             NUMBER := FND_API.G_MISS_NUM,
       PRICING_CONTEXT                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRICING_ATTRIBUTE               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PRICING_ATTR_VALUE_FROM         VARCHAR2(240):= FND_API.G_MISS_CHAR,
       PRICING_ATTR_VALUE_TO           VARCHAR2(240):= FND_API.G_MISS_CHAR,
       COMPARISON_OPERATOR             VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FLEX_TITLE                      VARCHAR2(60) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM
);

G_MISS_PRICE_ADJ_ATTR_REC          PRICE_ADJ_ATTR_Rec_Type;
TYPE  PRICE_ADJ_ATTR_Tbl_Type      IS TABLE OF PRICE_ADJ_ATTR_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_PRICE_ADJ_ATTR_TBL          PRICE_ADJ_ATTR_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: Price_Adj_Rltship_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    ADJ_RELATIONSHIP_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    QUOTE_LINE_ID
--    OBJECT_VERSION_NUMBER
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE  Price_Adj_Rltship_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ADJ_RELATIONSHIP_ID             NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       QTE_LINE_INDEX                  NUMBER := FND_API.G_MISS_NUM,
       QUOTE_SHIPMENT_ID               NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_INDEX                  NUMBER := FND_API.G_MISS_NUM,
       PRICE_ADJUSTMENT_ID             NUMBER := FND_API.G_MISS_NUM,
       PRICE_ADJ_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       RLTD_PRICE_ADJ_ID	       NUMBER := FND_API.G_MISS_NUM,
       RLTD_PRICE_ADJ_INDEX	       NUMBER := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM
);

G_MISS_Price_Adj_Rltship_REC          Price_Adj_Rltship_Rec_Type;
TYPE Price_Adj_Rltship_Tbl_Type      IS TABLE OF Price_Adj_Rltship_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Price_Adj_Rltship_TBL          Price_Adj_Rltship_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Payment_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    PAYMENT_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    QUOTE_HEADER_ID
--    QUOTE_LINE_ID
--    PAYMENT_TYPE_CODE
--    PAYMENT_OPTION
--    INSTALLMENT_SEQUENCE_NUM
--    INSTALLMENT_PAYMENT_DUE_DATE
--    PAYMENT_TERM_ID
--    PO_NUMBER
--    CHECK_NUMBER
--    CREDIT_CARD_CODE
--    CREDIT_CARD_HOLDER_NAME
--    CREDIT_CARD_NUMBER
--    CREDIT_CARD_EXPIRATION_DATE
--    CREDIT_CARD_APPROVAL_CODE
--    CREDIT_CARD_AUTHORIZATION_CODE
--    PAYMENT_AMOUNT
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--    OBJECT_VERSION_NUMBER
--    TRXN_EXTENSION_ID
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Payment_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       PAYMENT_ID                      NUMBER := FND_API.G_MISS_NUM,
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
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       QUOTE_SHIPMENT_ID               NUMBER := FND_API.G_MISS_NUM,
       PAYMENT_TYPE_CODE               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PAYMENT_REF_NUMBER              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PAYMENT_OPTION                  VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PAYMENT_TERM_ID                 NUMBER := FND_API.G_MISS_NUM,
       CREDIT_CARD_CODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CREDIT_CARD_HOLDER_NAME         VARCHAR2(80) := FND_API.G_MISS_CHAR,
       CREDIT_CARD_EXPIRATION_DATE     DATE := FND_API.G_MISS_DATE,
       CREDIT_CARD_APPROVAL_CODE       VARCHAR2(50) := FND_API.G_MISS_CHAR,
       CREDIT_CARD_APPROVAL_DATE       DATE := FND_API.G_MISS_DATE,
       PAYMENT_AMOUNT                  NUMBER := FND_API.G_MISS_NUM,
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
       CUST_PO_NUMBER                  VARCHAR2(50)  := FND_API.G_MISS_CHAR,
       CVV2                            VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       PAYMENT_TERM_ID_FROM            NUMBER        := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER           NUMBER        := FND_API.G_MISS_NUM,
	  CUST_PO_LINE_NUMBER             VARCHAR2(50)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
	  CARD_ID                        NUMBER          := FND_API.G_MISS_NUM,
	  INSTR_ASSIGNMENT_ID            NUMBER          := FND_API.G_MISS_NUM,
	  INSTRUMENT_ID                  NUMBER          := FND_API.G_MISS_NUM,
	  TRXN_EXTENSION_ID              NUMBER          := FND_API.G_MISS_NUM

);

G_MISS_Payment_REC          Payment_Rec_Type;
TYPE  Payment_Tbl_Type      IS TABLE OF Payment_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Payment_TBL          Payment_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Shipment_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    SHIPMENT_ID
--    QUOTE_HEADER_ID
--    QUOTE_LINE_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    PROMISE_DATE
--    NEED_BY_DATE
--    SHIP_TO_SITE_USE_ID
--    SHIP_TO_CONTACT_ID
--    SHIP_SET_ID
--    SHIP_PARTIAL_FLAG
--    SHIP_METHOD_CODE
--    SHIPMENT_PRIORITY_CODE
--    FREIGHT_TERMS_CODE
--    SHIPPING_INSTRUCTIONS
--    PACKING_INSTRUCTIONS
--    QUANTITY
--    RESERVE_QUANTITY
--    OBJECT_VERSION_NUMBER
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Shipment_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_ID                     NUMBER := FND_API.G_MISS_NUM,
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
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       PROMISE_DATE                    DATE := FND_API.G_MISS_DATE,
       REQUEST_DATE                    DATE := FND_API.G_MISS_DATE,
       SCHEDULE_SHIP_DATE              DATE := FND_API.G_MISS_DATE,
       SHIP_TO_PARTY_SITE_ID           NUMBER := FND_API.G_MISS_NUM,
       SHIP_TO_PARTY_ID                NUMBER := FND_API.G_MISS_NUM,
       SHIP_TO_CUST_ACCOUNT_ID         NUMBER := FND_API.G_MISS_NUM,
       SHIP_PARTIAL_FLAG               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SHIP_SET_ID                     NUMBER := FND_API.G_MISS_NUM,
       SHIP_METHOD_CODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FREIGHT_TERMS_CODE              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FREIGHT_CARRIER_CODE            VARCHAR2(30) := FND_API.G_MISS_CHAR,
       FOB_CODE                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SHIPPING_INSTRUCTIONS           VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       PACKING_INSTRUCTIONS            VARCHAR2(2000) := FND_API.G_MISS_CHAR,
       SHIP_QUOTE_PRICE                NUMBER := FND_API.G_MISS_NUM,
       QUANTITY                        NUMBER := FND_API.G_MISS_NUM,
       PRICING_QUANTITY                NUMBER := FND_API.G_MISS_NUM,
       RESERVED_QUANTITY               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RESERVATION_ID                  NUMBER := FND_API.G_MISS_NUM,
       ORDER_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       SHIP_TO_PARTY_NAME	       VARCHAR2(255) := FND_API.G_MISS_CHAR,
       SHIP_TO_CONTACT_FIRST_NAME      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       SHIP_TO_CONTACT_MIDDLE_NAME     VARCHAR2(60) := FND_API.G_MISS_CHAR,
       SHIP_TO_CONTACT_LAST_NAME       VARCHAR2(150) := FND_API.G_MISS_CHAR,
       SHIP_TO_ADDRESS1	               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SHIP_TO_ADDRESS2	               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SHIP_TO_ADDRESS3	               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SHIP_TO_ADDRESS4	               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SHIP_TO_COUNTRY_CODE	       VARCHAR2(80) := FND_API.G_MISS_CHAR,
       SHIP_TO_COUNTRY	               VARCHAR2(60) := FND_API.G_MISS_CHAR,
       SHIP_TO_CITY	 	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       SHIP_TO_POSTAL_CODE	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       SHIP_TO_STATE	               VARCHAR2(60) := FND_API.G_MISS_CHAR,
       SHIP_TO_PROVINCE	               VARCHAR2(60) := FND_API.G_MISS_CHAR,
       SHIP_TO_COUNTY	               VARCHAR2(60) := FND_API.G_MISS_CHAR,
       ATTRIBUTE_CATEGORY              VARCHAR2(30)  := FND_API.G_MISS_CHAR,
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
       SHIPMENT_PRIORITY_CODE          VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       SHIP_FROM_ORG_ID                NUMBER        := FND_API.G_MISS_NUM,
       SHIP_TO_CUST_PARTY_ID           NUMBER        := FND_API.G_MISS_NUM,
       SHIP_METHOD_CODE_FROM           VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       FREIGHT_TERMS_CODE_FROM         VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER           NUMBER        := FND_API.G_MISS_NUM,
	  REQUEST_DATE_TYPE               VARCHAR2(30)  := FND_API.G_MISS_CHAR,
	  DEMAND_CLASS_CODE               VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR
);

G_MISS_Shipment_REC			Shipment_Rec_Type;
TYPE  Shipment_Tbl_Type		IS TABLE OF Shipment_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Shipment_TBL			Shipment_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Freight_Charge_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    FREIGHT_CHARGE_ID
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    REQUEST_ID
--    QUOTE_SHIPMENT_ID
--    FREIGHT_CHARGE_TYPE_ID
--    CHARGE_AMOUNT
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--    OBJECT_VERSION_NUMBER
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Freight_Charge_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       FREIGHT_CHARGE_ID               NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       QUOTE_SHIPMENT_ID               NUMBER := FND_API.G_MISS_NUM,
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       FREIGHT_CHARGE_TYPE_ID          NUMBER := FND_API.G_MISS_NUM,
       CHARGE_AMOUNT                   NUMBER := FND_API.G_MISS_NUM,
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
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM
);

G_MISS_Freight_Charge_Rec          Freight_Charge_Rec_Type;
TYPE  Freight_Charge_Tbl_Type      IS TABLE OF Freight_charge_rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Freight_Charge_Tbl                Freight_Charge_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Tax_Detail_Rec_Type
--   -------------------------------------------------------
--   Record structure changed with addition of TAX_RATE_ID by Anoop Rajan on 30/08/2005
--   Parameters:
--    TAX_DETAIL_ID
--    QUOTE_HEADER_ID
--    QUOTE_LINE_ID
--    QUOTE_SHIPMENT_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    ORIG_TAX_CODE
--    TAX_CODE
--    TAX_RATE
--    TAX_DATE
--    TAX_AMOUNT
--    TAX_EXEMPT_FLAG
--    TAX_EXEMPT_NUMBER
--    TAX_EXEMPT_REASON_CODE
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--    OBJECT_VERSION_NUMBER
--    TAX_RATE_ID
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Tax_Detail_Rec_Type IS RECORD
(
       OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       TAX_DETAIL_ID                   NUMBER := FND_API.G_MISS_NUM,
       QUOTE_HEADER_ID                 NUMBER := FND_API.G_MISS_NUM,
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       QUOTE_SHIPMENT_ID               NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       ORIG_TAX_CODE                  VARCHAR2(240) := FND_API.G_MISS_CHAR,
       TAX_CODE                        VARCHAR2(50) := FND_API.G_MISS_CHAR,
       TAX_RATE                        NUMBER := FND_API.G_MISS_NUM,
       TAX_DATE                        DATE := FND_API.G_MISS_DATE,
       TAX_AMOUNT                      NUMBER := FND_API.G_MISS_NUM,
       TAX_EXEMPT_FLAG                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       TAX_EXEMPT_NUMBER               VARCHAR2(80) := FND_API.G_MISS_CHAR,
       TAX_EXEMPT_REASON_CODE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
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
       TAX_INCLUSIVE_FLAG              VARCHAR2(1)   := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM,
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       TAX_RATE_ID		      NUMBER		:= FND_API.G_MISS_NUM,
       TAX_CLASSIFICATION_CODE VARCHAR2(50) := FND_API.G_MISS_CHAR   -- rassharm gsi

);

G_MISS_Tax_Detail_Rec          Tax_Detail_Rec_Type;
TYPE  Tax_Detail_Tbl_Type      IS TABLE OF Tax_Detail_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Tax_Detail_TBL          Tax_Detail_Tbl_Type;



--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Header_Rltship_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    HEADER_RELATIONSHIP_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    QUOTE_HEADER_ID
--    RELATED_HEADER_ID
--    RELATIONAL_TYPE_CODE
--    RECIPROCAL_FLAG
--    OBJECT_VERSION_NUMBER
--
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Header_Rltship_Rec_Type IS RECORD
(
    HEADER_RELATIONSHIP_ID      NUMBER := FND_API.G_MISS_NUM,
      CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
    QUOTE_HEADER_ID             NUMBER := FND_API.G_MISS_NUM,
    RELATED_HEADER_ID     NUMBER := FND_API.G_MISS_NUM,
    RELATIONAL_TYPE_CODE     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    RECIPROCAL_FLAG          VARCHAR2(150) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM

);

G_MISS_Header_Rltship_REC           Header_Rltship_Rec_Type;
TYPE  Header_Rltship_Tbl_Type      IS TABLE OF Header_Rltship_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Header_Rltship_TBL          Header_Rltship_Tbl_Type;



--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Line_Rltship_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    LINE_RELATIONSHIP_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    QUOTE_LINE_ID
--    RELATED_QUOTE_LINE_ID
--    RELATIONAL_TYPE_CODE
--    RECIPROCAL_FLAG
--    OBJECT_VERSION_NUMBER
--
--
--    Required:
--    Defaults:
--
--   End of Comments

TYPE Line_Rltship_Rec_Type IS RECORD
(
    OPERATION_CODE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
    LINE_RELATIONSHIP_ID      NUMBER := FND_API.G_MISS_NUM,
      CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
    QUOTE_LINE_ID             NUMBER := FND_API.G_MISS_NUM,
    QTE_LINE_INDEX          NUMBER := FND_API.G_MISS_NUM,
    RELATED_QUOTE_LINE_ID     NUMBER := FND_API.G_MISS_NUM,
    RELATED_QTE_LINE_INDEX  NUMBER := FND_API.G_MISS_NUM,
    RELATIONSHIP_TYPE_CODE     VARCHAR2(30) := FND_API.G_MISS_CHAR,
    RECIPROCAL_FLAG          VARCHAR2(1) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM

);

G_MISS_Line_Rltship_REC          Line_Rltship_Rec_Type;
TYPE  Line_Rltship_Tbl_Type      IS TABLE OF Line_Rltship_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Line_Rltship_TBL          Line_Rltship_Tbl_Type;





--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Party_Rltship_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    PARTY_RELATIONSHIP_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    QUOTE_HEADER_ID
--    QUOTE_LINE_ID
--    OBJECT_TYPE_CODE
--    OBJECT_ID
--    RELATIONAL_TYPE_CODE
--    OBJECT_VERSION_NUMBER
--
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE PARTY_RLTSHIP_Rec_Type IS RECORD
(
       PARTY_RELATIONSHIP_ID           NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       QUOTE_OBJECT_TYPE               VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QUOTE_OBJECT_ID                 NUMBER := FND_API.G_MISS_NUM,
       RELATIONSHIP_TYPE_CODE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       RELATED_OBJECT_TYPE_CODE        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       RELATED_OBJECT_ID               NUMBER := FND_API.G_MISS_NUM,
       QUOTE_HEADER_ID                 NUMBER := FND_API.G_MISS_NUM,
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       OBJECT_TYPE_CODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       OBJECT_ID                       NUMBER := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM
);

G_MISS_PARTY_RLTSHIP_REC          PARTY_RLTSHIP_Rec_Type;
TYPE  PARTY_RLTSHIP_Tbl_Type      IS TABLE OF PARTY_RLTSHIP_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_PARTY_RLTSHIP_TBL          PARTY_RLTSHIP_Tbl_Type;

/*
TYPE Party_Rltship_Rec_Type IS RECORD
(
    PARTY_RELATIONSHIP_ID      NUMBER := FND_API.G_MISS_NUM,
      CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
    QUOTE_HEADER_ID             NUMBER := FND_API.G_MISS_NUM,
    QUOTE_LINE_ID            NUMBER := FND_API.G_MISS_NUM,
    QUOTE_LINE_INDEX	     NUMBER := FND_API.G_MISS_NUM,
    OBJECT_TYPE_CODE         NUMBER := FND_API.G_MISS_NUM,
    OBJECT_ID                NUMBER := FND_API.G_MISS_NUM,
    RELATIONAL_TYPE_CODE     VARCHAR2(150) := FND_API.G_MISS_CHAR

);

G_MISS_Party_Rltship_REC           Party_Rltship_Rec_Type;
TYPE  Party_Rltship_Tbl_Type      IS TABLE OF Party_Rltship_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Party_Rltship_TBL          Party_Rltship_Tbl_Type;
*/

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:Related_Object_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    RELATED_OBJECT_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    QUOTE_HEADER_ID
--    QUOTE_LINE_ID
--    OBJECT_TYPE_CODE
--    OBJECT_ID
--    RELATIONAL_TYPE_CODE
--    RECIPROCAL_FLAG
--    OBJECT_VERSION_NUMBER
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE Related_Object_Rec_Type IS RECORD
(
    RELATED_OBJECT_ID      NUMBER := FND_API.G_MISS_NUM,
    CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
    CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
    LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
    LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
    LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
    REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
    PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
    PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
    QUOTE_HEADER_ID             NUMBER := FND_API.G_MISS_NUM,
    QUOTE_LINE_ID            NUMBER := FND_API.G_MISS_NUM,
    QUOTE_OBJECT_TYPE_CODE   VARCHAR2(50) := FND_API.G_MISS_CHAR,
    QUOTE_OBJECT_ID          NUMBER := FND_API.G_MISS_NUM,
    QUOTE_LINE_INDEX	     NUMBER := FND_API.G_MISS_NUM,
    OBJECT_TYPE_CODE         NUMBER := FND_API.G_MISS_NUM,
    OBJECT_ID                NUMBER := FND_API.G_MISS_NUM,
    RELATIONAL_TYPE_CODE     VARCHAR2(150) := FND_API.G_MISS_CHAR,
    RECIPROCAL_FLAG          VARCHAR2(150) := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM
);

G_MISS_Related_Object_REC           Related_Object_Rec_Type;
TYPE  Related_Object_Tbl_Type      IS TABLE OF Related_Object_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Related_Object_TBL          Related_Object_Tbl_Type;




TYPE RELATED_OBJ_Rec_Type IS RECORD
(
       RELATED_OBJECT_ID               NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       QUOTE_OBJECT_TYPE_CODE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QUOTE_OBJECT_ID                 NUMBER := FND_API.G_MISS_NUM,
       OBJECT_TYPE_CODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       OBJECT_ID                       NUMBER := FND_API.G_MISS_NUM,
       RELATIONSHIP_TYPE_CODE          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       RECIPROCAL_FLAG                 VARCHAR2(1) := FND_API.G_MISS_CHAR,
       QUOTE_OBJECT_CODE               NUMBER := FND_API.G_MISS_NUM,
       OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM,
	  OPERATION_CODE                  VARCHAR2(30) := FND_API.G_MISS_CHAR
);

G_MISS_RELATED_OBJ_REC          RELATED_OBJ_Rec_Type;
TYPE  RELATED_OBJ_Tbl_Type      IS TABLE OF RELATED_OBJ_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_RELATED_OBJ_TBL          RELATED_OBJ_Tbl_Type;



TYPE Line_Attribs_Ext_Rec_Type IS RECORD
(
 QTE_LINE_INDEX			 NUMBER := FND_API.G_MISS_NUM,
 SHIPMENT_INDEX			 NUMBER := FND_API.G_MISS_NUM,
 LINE_ATTRIBUTE_ID               NUMBER := FND_API.G_MISS_NUM,
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
 QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
 QUOTE_SHIPMENT_ID               NUMBER := FND_API.G_MISS_NUM,
 ATTRIBUTE_TYPE_CODE             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 NAME 				 VARCHAR2(30) := FND_API.G_MISS_CHAR,
 VALUE				 VARCHAR2(150) := FND_API.G_MISS_CHAR,
 VALUE_TYPE                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 STATUS				 VARCHAR2(30) := FND_API.G_MISS_CHAR,
 APPLICATION_ID 		 NUMBER,
 START_DATE_ACTIVE   		 DATE := FND_API.G_MISS_DATE,
 END_DATE_ACTIVE                 DATE := FND_API.G_MISS_DATE,
 OPERATION_CODE                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM
);
G_MISS_Line_Attribs_Ext_REC           Line_Attribs_Ext_Rec_Type;
TYPE  Line_Attribs_Ext_Tbl_Type      IS TABLE OF Line_Attribs_Ext_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Line_Attribs_Ext_TBL          Line_Attribs_Ext_Tbl_Type;

-- ER 3177722
TYPE Config_Vaild_Rec_Type IS RECORD
(
      QUOTE_LINE_ID           NUMBER := FND_API.G_MISS_NUM,
      IS_CFG_CHANGED_FLAG     VARCHAR2(1)    := FND_API.G_MISS_CHAR,
      IS_CFG_VALID            VARCHAR2(1)    := FND_API.G_MISS_CHAR,
      IS_CFG_COMPLETE         VARCHAR2(1)    := FND_API.G_MISS_CHAR

     );

G_MISS_Config_Vaild_Rec_Type Config_Vaild_Rec_Type;
TYPE  Config_Vaild_Tbl_Type      IS TABLE OF Config_Vaild_Rec_Type    INDEX BY BINARY_INTEGER;
G_MISS_QTE_Config_Valid_TBL          Config_Vaild_Tbl_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:QUOTE_PARTY_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    QUOTE_PARTY_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    LAST_UPDATED_BY
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    QUOTE_HEADER_ID
--    QUOTE_LINE_ID
--    QUOTE_SHIPMENT_ID
--    PARTY_TYPE
--    PARTY_ID
--    PARTY_OBJECT_TYPE
--    PARTY_OBJECT_ID
--    ATTRIBUTE_CATEGORY
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE QUOTE_PARTY_Rec_Type IS RECORD
(
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       SHIPMENT_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       OPERATION_CODE                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
       QUOTE_PARTY_ID                  NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       QUOTE_HEADER_ID                 NUMBER := FND_API.G_MISS_NUM,
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       QUOTE_SHIPMENT_ID               NUMBER := FND_API.G_MISS_NUM,
       PARTY_TYPE                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PARTY_ID                        NUMBER := FND_API.G_MISS_NUM,
       PARTY_OBJECT_TYPE               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PARTY_OBJECT_ID                 NUMBER := FND_API.G_MISS_NUM,
       ATTRIBUTE_CATEGORY              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM
);

G_MISS_QUOTE_PARTY_REC          QUOTE_PARTY_Rec_Type;
TYPE  QUOTE_PARTY_Tbl_Type      IS TABLE OF QUOTE_PARTY_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_QUOTE_PARTY_TBL          QUOTE_PARTY_Tbl_Type;



--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:SALES_CREDIT_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    SALES_CREDIT_ID
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    REQUEST_ID
--    PROGRAM_APPLICATION_ID
--    PROGRAM_ID
--    PROGRAM_UPDATE_DATE
--    QUOTE_HEADER_ID
--    QUOTE_LINE_ID
--    PERCENT
--    RESOURCE_ID
--    RESOURCE_GROUP_ID
--    EMPLOYEE_PERSON_ID
--    SALES_CREDIT_TYPE_ID
--    ATTRIBUTE_CATEGORY_CODE
--    ATTRIBUTE1
--    ATTRIBUTE2
--    ATTRIBUTE3
--    ATTRIBUTE4
--    ATTRIBUTE5
--    ATTRIBUTE6
--    ATTRIBUTE7
--    ATTRIBUTE8
--    ATTRIBUTE9
--    ATTRIBUTE10
--    ATTRIBUTE11
--    ATTRIBUTE12
--    ATTRIBUTE13
--    ATTRIBUTE14
--    ATTRIBUTE15
--
--    Required:
--    Defaults:
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

TYPE SALES_CREDIT_Rec_Type IS RECORD
(
       QTE_LINE_INDEX		       NUMBER := FND_API.G_MISS_NUM,
       OPERATION_CODE                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
       SALES_CREDIT_ID                 NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE   := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATED_BY                 VARCHAR2(240) := FND_API.G_MISS_CHAR,
       LAST_UPDATE_DATE                DATE   := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE   := FND_API.G_MISS_DATE,
       QUOTE_HEADER_ID                 NUMBER := FND_API.G_MISS_NUM,
       QUOTE_LINE_ID                   NUMBER := FND_API.G_MISS_NUM,
       PERCENT                         NUMBER := FND_API.G_MISS_NUM,
       RESOURCE_ID                     NUMBER := FND_API.G_MISS_NUM,
       FIRST_NAME                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       LAST_NAME                       VARCHAR2(240) := FND_API.G_MISS_CHAR,
       SALES_CREDIT_TYPE               VARCHAR2(240) := FND_API.G_MISS_CHAR,
        RESOURCE_GROUP_NAME            VARCHAR2(240) := FND_API.G_MISS_CHAR,
       RESOURCE_GROUP_ID               NUMBER := FND_API.G_MISS_NUM,
       EMPLOYEE_PERSON_ID              NUMBER := FND_API.G_MISS_NUM,
       SALES_CREDIT_TYPE_ID            NUMBER := FND_API.G_MISS_NUM,
       ATTRIBUTE_CATEGORY_CODE         VARCHAR2(30) := FND_API.G_MISS_CHAR,
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
       CREDIT_RULE_ID                  NUMBER := FND_API.G_MISS_NUM,
       SYSTEM_ASSIGNED_FLAG            VARCHAR2(1) := FND_API.G_MISS_CHAR,
	  OBJECT_VERSION_NUMBER          NUMBER          :=  FND_API.G_MISS_NUM,
       ATTRIBUTE16                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE17                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE18                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE19                    VARCHAR2(240)   := FND_API.G_MISS_CHAR,
       ATTRIBUTE20                    VARCHAR2(240)   := FND_API.G_MISS_CHAR

);

G_MISS_SALES_CREDIT_REC          SALES_CREDIT_Rec_Type;
TYPE  SALES_CREDIT_Tbl_Type      IS TABLE OF SALES_CREDIT_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_SALES_CREDIT_TBL          SALES_CREDIT_Tbl_Type;


TYPE Order_Header_Rec_Type IS RECORD
(
       ORDER_NUMBER          NUMBER := FND_API.G_MISS_NUM,
       ORDER_HEADER_ID       NUMBER := FND_API.G_MISS_NUM,
       ORDER_REQUEST_ID      NUMBER := FND_API.G_MISS_NUM,
       CONTRACT_ID           NUMBER := FND_API.G_MISS_NUM,
       STATUS                VARCHAR2(150) := FND_API.G_MISS_CHAR
);


TYPE Lot_Serial_Rec_Type IS RECORD
(   attribute1                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute10                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute11                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute12                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute13                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute14                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute15                   VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute2                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute3                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute4                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute5                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute6                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute7                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute8                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   attribute9                    VARCHAR2(240)  := FND_API.G_MISS_CHAR
,   context                       VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   created_by                    NUMBER         := FND_API.G_MISS_NUM
,   creation_date                 DATE           := FND_API.G_MISS_DATE
,   from_serial_number            VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   last_updated_by               NUMBER         := FND_API.G_MISS_NUM
,   last_update_date              DATE           := FND_API.G_MISS_DATE
,   last_update_login             NUMBER         := FND_API.G_MISS_NUM
,   line_id                       NUMBER         := FND_API.G_MISS_NUM
,   lot_number                    VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   lot_serial_id                 NUMBER         := FND_API.G_MISS_NUM
,   quantity                      NUMBER         := FND_API.G_MISS_NUM
,   to_serial_number              VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   return_status                 VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   db_flag                       VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   operation                     VARCHAR2(30)   := FND_API.G_MISS_CHAR
,   line_index                    NUMBER         := FND_API.G_MISS_NUM
,   orig_sys_lotserial_ref        VARCHAR2(50)   := FND_API.G_MISS_CHAR
,   change_request_code	  	  VARCHAR2(30)	 := FND_API.G_MISS_CHAR
,   status_flag		  	  VARCHAR2(1)    := FND_API.G_MISS_CHAR
,   line_set_id                   NUMBER         := FND_API.G_MISS_NUM
);

TYPE Lot_Serial_Tbl_Type IS TABLE OF Lot_Serial_Rec_Type
    INDEX BY BINARY_INTEGER;

G_MISS_Lot_Serial_Tbl            Lot_Serial_Tbl_Type ;

-- this record type is used for flexfield validation
TYPE attribute_rec_type IS RECORD(
                        attribute_category    VARCHAR2(30)  DEFAULT NULL,
                        attribute1            VARCHAR2(150) DEFAULT NULL,
			attribute2            VARCHAR2(150) DEFAULT NULL,
       			attribute3            VARCHAR2(150) DEFAULT NULL,
       			attribute4            VARCHAR2(150) DEFAULT NULL,
       			attribute5            VARCHAR2(150) DEFAULT NULL,
       			attribute6            VARCHAR2(150) DEFAULT NULL,
       			attribute7            VARCHAR2(150) DEFAULT NULL,
       			attribute8            VARCHAR2(150) DEFAULT NULL,
       			attribute9            VARCHAR2(150) DEFAULT NULL,
       			attribute10           VARCHAR2(150) DEFAULT NULL,
       			attribute11           VARCHAR2(150) DEFAULT NULL,
       			attribute12           VARCHAR2(150) DEFAULT NULL,
       			attribute13           VARCHAR2(150) DEFAULT NULL,
       			attribute14           VARCHAR2(150) DEFAULT NULL,
       			attribute15           VARCHAR2(150) DEFAULT NULL);


/* Quote Access or Sales Team record structure */

TYPE Qte_Access_Rec_Type IS RECORD
(
    ACCESS_ID                       NUMBER        := FND_API.G_MISS_NUM,
    QUOTE_NUMBER                    NUMBER        := FND_API.G_MISS_NUM,
    RESOURCE_ID                     NUMBER        := FND_API.G_MISS_NUM,
    RESOURCE_GRP_ID                 NUMBER        := FND_API.G_MISS_NUM,
    CREATED_BY                      NUMBER        := FND_API.G_MISS_NUM,
    CREATION_DATE                   DATE          := FND_API.G_MISS_DATE,
    LAST_UPDATED_BY                 NUMBER        := FND_API.G_MISS_NUM,
    LAST_UPDATE_LOGIN               NUMBER        := FND_API.G_MISS_NUM,
    LAST_UPDATE_DATE                DATE          := FND_API.G_MISS_DATE,
    REQUEST_ID                      NUMBER        := FND_API.G_MISS_NUM,
    PROGRAM_APPLICATION_ID          NUMBER        := FND_API.G_MISS_NUM,
    PROGRAM_ID                      NUMBER        := FND_API.G_MISS_NUM,
    PROGRAM_UPDATE_DATE             DATE          := FND_API.G_MISS_DATE,
    KEEP_FLAG                       VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    UPDATE_ACCESS_FLAG              VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    CREATED_BY_TAP_FLAG             VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    TERRITORY_ID                    NUMBER        := FND_API.G_MISS_NUM,
    TERRITORY_SOURCE_FLAG           VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    ROLE_ID                         NUMBER        := FND_API.G_MISS_NUM,
    ATTRIBUTE_CATEGORY              VARCHAR2(30)  := FND_API.G_MISS_CHAR,
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
    BATCH_PRICE_FLAG                VARCHAR2(1)   := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER           NUMBER        := FND_API.G_MISS_NUM,
    ATTRIBUTE16                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
    ATTRIBUTE17                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
    ATTRIBUTE18                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
    ATTRIBUTE19                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
    ATTRIBUTE20                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
    OPERATION_CODE                  VARCHAR2(30)  := FND_API.G_MISS_CHAR
);

G_MISS_QTE_ACCESS_REC           Qte_Access_Rec_Type;


TYPE Qte_Access_Tbl_Type IS TABLE OF Qte_Access_Rec_Type INDEX BY BINARY_INTEGER;

G_MISS_QTE_ACCESS_TBL           Qte_Access_Tbl_Type;


/* Template record structure */

TYPE Template_Rec_Type IS RECORD
(
 TEMPLATE_ID         NUMBER        := FND_API.G_MISS_NUM
);

G_MISS_TEMPLATE_REC     Template_Rec_Type;

TYPE Template_Tbl_Type IS TABLE OF Template_Rec_Type INDEX BY BINARY_INTEGER;

G_MISS_TEMPLATE_TBL     Template_Tbl_Type;




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_Qte_Header_Rec     IN Qte_Header_Rec_Type  Required
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Control_Rec		 IN   Control_Rec_Type := G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec		 IN   ASO_QUOTE_PUB.Shipment_Rec_Type
					:= G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    P_Qte_Line_Tbl		 IN   Qte_Line_Tbl_Type := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   Qte_Line_Dtl_Tbl_Type
					:= G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type
					:= G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   Line_Rltship_Tbl_Type
					:= G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   Price_Adj_Tbl_Type
					:= G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	 IN   Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type
					:= G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		 IN   Payment_Tbl_Type := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		 IN   Shipment_Tbl_Type := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	 IN   Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		 IN   Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,

    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,

    X_Qte_Line_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */  Shipment_Rec_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_Qte_Header_Rec     IN Qte_Header_Rec_Type  Required
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.

PROCEDURE Update_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Control_Rec		 IN   Control_Rec_Type := G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
					:= G_MISS_SHIPMENT_TBL,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    P_Qte_Line_Tbl		 IN   Qte_Line_Tbl_Type := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   Qte_Line_Dtl_Tbl_Type
					:= G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type
					:= G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   Line_Rltship_Tbl_Type
					:= G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   Price_Adj_Tbl_Type
					:= G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	 IN   Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type
					:= G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		 IN   Payment_Tbl_Type := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		 IN   Shipment_Tbl_Type := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	 IN   Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		 IN   Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,

    X_Qte_Line_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_Qte_Header_Rec     IN Qte_Header_Rec_Type  Required
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Copy_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Copy_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Id		 IN   NUMBER,
    P_Last_Update_Date		 IN   DATE,
    P_Copy_Only_Header		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_New_Version		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Qte_Status_Id		 IN   NUMBER	   := NULL,
    P_Qte_Number		 IN   NUMBER	   := NULL,
    X_Qte_Header_Id		 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Copy_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:This is the Overloaded Version of Copy_quote Which
--   Takes P_control_rec as input parameter.This p_control_rec can
--   be used to copy notes and task.
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Copy_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_control_rec                IN  Control_Rec_Type,
    P_Qte_Header_Id		 IN   NUMBER,
    P_Last_Update_Date		 IN   DATE,
    P_Copy_Only_Header		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_New_Version		 IN   VARCHAR2	   := FND_API.G_FALSE,
    P_Qte_Status_Id		 IN   NUMBER	   := NULL,
    P_Qte_Number		 IN   NUMBER	   := NULL,
    X_Qte_Header_Id		 OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Validate_Quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Validate_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */  NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */  VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Submit_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
--    P_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_control_rec		 IN   Submit_Control_Rec_Type
					:= G_MISS_Submit_Control_Rec,
    P_Qte_Header_Id		 IN   NUMBER,
    x_order_header_rec		 OUT NOCOPY /* file.sql.39 change */  Order_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_Qte_Header_Rec     IN Qte_Header_Rec_Type  Required
--   Hint: Add List of bind variables here
--       p_rec_requested           IN   NUMBER     Optional  Default = 30
--       p_start_rec_ptr           IN   NUMBER     Optional  Default = 1
--
--       Return Total Records Count Flag. This flag controls whether the total record count
--       and total record amount is returned.
--
--       p_return_tot_count        IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--   Hint: User defined record type
--       p_order_by_tbl            IN   AS_UTILITY_PUB.UTIL_ORDER_BY_TBL_TYPE;
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       X_Qte_Header_Tbl     OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type
--       x_returned_rec_count      OUT NOCOPY /* file.sql.39 change */    NUMBER
--       x_next_rec_ptr            OUT NOCOPY /* file.sql.39 change */    NUMBER
--       x_tot_rec_count           OUT NOCOPY /* file.sql.39 change */    NUMBER
--  other optional OUT NOCOPY /* file.sql.39 change */  parameters
--       x_tot_rec_amount          OUT NOCOPY /* file.sql.39 change */    NUMBER
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Get_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Header_Rec		 IN    Qte_Header_Rec_Type,
  -- Hint: Add list of bind variables here
    p_rec_requested              IN   NUMBER  := G_DEFAULT_NUM_REC_FETCH,
    p_start_rec_prt              IN   NUMBER  := 1,
    p_return_tot_count           IN   NUMBER  := FND_API.G_FALSE,
  -- Hint: user defined record type
    p_order_by_rec               IN   QTE_sort_rec_type,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Qte_Header_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Header_Tbl_Type,
    x_returned_rec_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_next_rec_ptr               OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_tot_rec_count              OUT NOCOPY /* file.sql.39 change */  NUMBER
  -- other optional parameters
--  x_tot_rec_amount             OUT NOCOPY /* file.sql.39 change */  NUMBER
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_qte_lines_Rec     IN    qte_line_Rec_Type         Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--       P_Payment_Tbl       IN    Payment_Tbl_Type
--       P_Price_Adj_Tbl     IN    Price_Adj_Tbl_Type
--       P_Qte_Line_Dtl_Rec  IN    Qte_Line_Dtl_Rec_Type
--       P_Shipment_Tbl      IN    Shipment_Tbl_Type
--       P_Tax_Detail_Tbl      IN    Tax_Detail_Tbl_Type
--       P_Freight_Charge_Tbl  IN    Freight_Charge_Tbl_Type
--       P_Line_Rltship_Tbl IN   Line_Rltship_Tbl_Type
--       P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type
--       P_Price_Adj_Rltship_Tbl IN Price_Adj_Rltship_Tbl_Type
--       P_Update_Header_Flag    IN   VARCHAR2     Optional  Default = FND_API.G_TRUE

--   OUT NOCOPY /* file.sql.39 change */  :
--       X_quote_line_id     OUT NOCOPY /* file.sql.39 change */   NUMBER,
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
PROCEDURE Create_Quote_Line(

    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Line_Rec         IN   Qte_Line_Rec_Type  := G_MISS_qte_line_REC,
    P_Control_Rec          IN   Control_rec_Type   := G_MISS_control_REC,
    P_Qte_Line_Dtl_Tbl    IN   Qte_Line_Dtl_Tbl_Type:= G_MISS_qte_line_dtl_TBL,
    P_Line_Attribs_Ext_Tbl IN   Line_Attribs_Ext_Tbl_type
                                        := G_Miss_Line_Attribs_Ext_Tbl,
    P_Payment_Tbl          IN   Payment_Tbl_Type   := G_MISS_Payment_TBL,
    P_Price_Adj_Tbl        IN   Price_Adj_Tbl_Type := G_MISS_Price_Adj_TBL,
    P_Price_Attributes_Tbl IN   Price_Attributes_Tbl_Type := G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN  Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Shipment_Tbl          IN  Shipment_Tbl_Type   := G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN  Tax_Detail_Tbl_Type:= G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN  Freight_Charge_Tbl_Type   := G_MISS_freight_charge_TBL,
    P_Update_Header_Flag    IN  VARCHAR2   := FND_API.G_TRUE,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  Qte_Line_Rec_Type,
    X_Qte_Line_Dtl_TBL      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_TBL_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type ,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN

PROCEDURE Update_Quote_Line(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Qte_Line_Rec        IN    Qte_Line_Rec_Type  := G_MISS_qte_line_REC,
    P_Control_Rec         IN    Control_rec_Type   := G_MISS_control_REC,
    P_Qte_Line_Dtl_TBL   IN    Qte_Line_Dtl_tbl_Type:= G_MISS_qte_line_dtl_TBL,
    P_Line_Attribs_Ext_Tbl  IN   Line_Attribs_Ext_Tbl_type
                                        := G_Miss_Line_Attribs_Ext_Tbl,
    P_Payment_Tbl           IN    Payment_Tbl_Type   := G_MISS_Payment_TBL,
    P_Price_Adj_Tbl         IN    Price_Adj_Tbl_Type := G_MISS_Price_Adj_TBL,
    P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type := G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Shipment_Tbl          IN    Shipment_Tbl_Type   := G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN    Tax_Detail_Tbl_Type:= G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN   Freight_Charge_Tbl_Type   := G_MISS_freight_charge_TBL,
    P_Update_Header_Flag    IN   VARCHAR2   := FND_API.G_TRUE,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  Qte_Line_Rec_Type,
    X_Qte_Line_Dtl_TBL      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_TBL_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type ,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_qte_line_Rec      IN qte_line_Rec_Type  Required
--       P_quote_header_id   IN    NUMBER                    Required
--       P_header_last_update_date IN DATE                   Required
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT  parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.

PROCEDURE Delete_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_qte_line_Rec     IN     qte_line_Rec_Type,
    P_Control_Rec      IN    Control_rec_Type   := G_MISS_control_REC,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );



--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--   Version : Current version 2.0
--   Note: This is an overloaded procedure. It takes additional attributes
--   which include the hd_attributes, sales credits and quote party record
--   types
--
--   End of Comments
--



PROCEDURE Create_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		 IN   Control_Rec_Type := G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec		 IN   ASO_QUOTE_PUB.Shipment_Rec_Type
					:= G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type
					:= G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		 IN   Qte_Line_Tbl_Type := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   Qte_Line_Dtl_Tbl_Type
					:= G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type
					:= G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   Line_Rltship_Tbl_Type
					:= G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   Price_Adj_Tbl_Type
					:= G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	 IN   Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type
					:= G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		 IN   Payment_Tbl_Type := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		 IN   Shipment_Tbl_Type := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	 IN   Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		 IN   Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,

    X_Qte_Line_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */  Shipment_Rec_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--  This is an overloaded procedure. It takes additional attributes
--   which include the hd_attributes, sales credits and quote party record
--   types
/*#
* Use this procedure to modify existing quotes.
* This API allows users to modify the quote header, create and modify quote lines, enter and modify price adjustments, pricing attributes, sales credits, shipping information, tax handling information and payment information.
*    @param         p_api_version_number   API version used to check the compatibility of a call.
*    @param         p_init_msg_list        Boolean parameter which determines whether internal message tables should be initialized.
*    @param         P_Validation_Level     Number parameter to determine which validation steps to be executed and which steps to skip.
*    @param         p_commit            Boolean  parameter which is used by API callers to ask the API to commit on their behalf after performing its function.
*    @param         x_return_status     Return status of the API call.
*    @param         x_msg_count    Number of stored processing messages.
*    @param         x_msg_data                  Processing message data.
*    @param         p_control_rec               Input control record structure containing information about the actions (Price,Tax and so on) that can be performed on a quote.
*    @param         P_Qte_Header_Rec            Input record structure containing current header level information for a quote to be updated.
*    @param         P_hd_Price_Attributes_Tbl   Input table structure containing current header level information for pricing attributes.
*    @param         P_hd_Payment_Tbl            Input table  structure containing current header level Payment information for a quote.
*    @param         P_hd_Shipment_Tbl           Input table structure containing current header level Shipment information for a quote.
*    @param         P_hd_Freight_Charge_Tbl     Not Used (Obsolete).
*    @param         P_hd_Tax_Detail_Tbl         Input table structure containing current header level Tax information for a quote.
*    @param         P_hd_Attr_Ext_Tbl           Not Used (Obsolete).
*    @param         P_hd_Sales_Credit_Tbl       Input table  structure containing current header level Sales Credit information for a quote.
*    @param         P_hd_Quote_Party_Tbl        Not Used (Obsolete).
*    @param         P_Qte_Line_Tbl              Input table structure containing quote lines information for a quote.
*    @param         P_Qte_Line_Dtl_Tbl          Input table structure containing line details(Configuration Lines,Service Lines) information for a quote.
*    @param         P_Line_Attr_Ext_Tbl         Not Used (Obsolete).
*    @param         P_line_rltship_tbl          Input table structure containing relationships at line level.
*    @param         P_Price_Adjustment_Tbl      Input table structure containing  Price Adjustments(Header and Lines) information for a quote.
*    @param         P_Price_Adj_Attr_Tbl        Input table structure containing  Price Adjustments Attributes(Header and Lines) information for a quote.
*    @param         P_Price_Adj_Rltship_Tbl     Input table structure containing relationships at Price Adjustment level.
*    @param         P_Ln_Price_Attributes_Tbl   Input table structure containing  quote line level information for pricing attributes.
*    @param         P_Ln_Payment_Tbl            Input table  structure containing quote line level Payment information for a quote.
*    @param         P_Ln_Shipment_Tbl           Input record structure containing quote line level Shipment information for a quote.
*    @param         P_Ln_Freight_Charge_Tbl     Not Used (Obsolete).
*    @param         P_Ln_Tax_Detail_Tbl         Input table structure containing quote line level Tax information for a quote.
*    @param         P_Ln_Sales_Credit_Tbl       Input table  structure containing quote line level Sales Credit information for a quote.
*    @param         P_Ln_Quote_Party_Tbl        Not Used (Obsolete).
*    @param         X_Qte_Header_Rec            Output record structure containing quote header level information with a Quote Header Id. This is a unique identifier generated for the quote.
*    @param         X_hd_Price_Attributes_Tbl   Output table structure containing header level information for pricing attributes with Price Attribute Id. This is a unique identifier generated for the price attribute records.
*    @param         X_hd_Payment_Tbl            Output table structure containing header level Payment information for a quote with Payment Id. This is a unique identifier generated for the payment records.
*    @param         X_hd_Shipment_Tbl           Output table structure containing header level Shipment information for a quote with a Shipment Id. This is a unique identifier generated for the shipment records.
*    @param         X_Hd_Freight_Charge_Tbl     Not Used (Obsolete).
*    @param         X_hd_Tax_Detail_Tbl         Output table structure containing header level Tax information for a quote with a Tax Detail Id. This is a unique identifier generated for the tax detail records.
*    @param         X_hd_Attr_Ext_Tbl           Not Used (Obsolete).
*    @param         X_hd_Sales_Credit_Tbl       Output table  structure containing header level Sales Credit information for a quote with a Sales Credit Id. This is a  unique identifier generated for the sales credit records.
*    @param         X_hd_Quote_Party_Tbl        Not Used (Obsolete).
*    @param         X_Qte_Line_Tbl              Output table structure containing quote lines information for a quote with a Quote Line Id. This is a unique identifier generated for the quote lines.
*    @param         X_Qte_Line_Dtl_Tbl          Output table structure containing line details(Configuration Lines,Service Lines) information for a quote with a Line Detail Id. This is a  unique identifier generated for the line detail records.
*    @param         X_Line_Attr_Ext_Tbl         Not Used (Obsolete).
*    @param         X_line_rltship_tbl          Output table structure containing relationships at line level with Line Relationship Id.
*    @param         X_Price_Adjustment_Tbl      Output table structure containing  Price Adjustments(Header and Lines) information for quote with a Price Adjustment Id. This is a unique identifier generated for the price adjustment records.
*    @param         X_Price_Adj_Attr_Tbl Output table structure containing Price Adjustment Attributes(Header, Lines) information for a quote. Price Adjustment Attribute Id is a unique identifier generated for the price adjustment attributes records.
*    @param         X_Price_Adj_Rltship_Tbl     Output table structure containing  relationships at Price Adjustment level with a Adjustment Relationship Id. This is a unique identifier generated for the price adjustment relationship.
*    @param         X_Ln_Price_Attributes_Tbl   Output table structure containing  quote line level information for pricing attributes with a Price Attribute Id. This is a unique identifier generated for the price attribute records.
*    @param         X_Ln_Payment_Tbl            Output table structure containing quote line level Payment information for a quote with a Payment Id. This is a unique identifier generated for the payment records.
*    @param         X_Ln_Shipment_Tbl           Output record structure containing line level Shipment information for a quote with a Shipment Id. This is a unique identifier generated for the shipment records.
*    @param         X_Ln_Freight_Charge_Tbl     Not Used (Obsolete).
*    @param         X_Ln_Tax_Detail_Tbl        Output table structure containing line level Tax information for a quote with a Tax Detail Id. This is a unique identifier generated for the tax detail records.
*    @param         X_Ln_Sales_Credit_Tbl      Output table  structure containing line level Sales Credit information for a quote with Sales Credit Id. This is a unique identifier generated for the sales credit records.
*    @param         X_Ln_Quote_Party_Tbl     Not Used (Obsolete).
 *    @rep:scope          public
 *    @rep:lifecycle      active
 *    @rep:category  BUSINESS_ENTITY     ASO_QUOTE
 *    @rep:displayname       Update Quote
*/

PROCEDURE Update_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		 IN   Control_Rec_Type := G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
					:= G_MISS_SHIPMENT_TBL,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type
					:= G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		 IN   Qte_Line_Tbl_Type := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   Qte_Line_Dtl_Tbl_Type
					:= G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type
					:= G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   Line_Rltship_Tbl_Type
					:= G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   Price_Adj_Tbl_Type
					:= G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	 IN   Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type
					:= G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		 IN   Payment_Tbl_Type := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		 IN   Shipment_Tbl_Type := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	 IN   Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		 IN   Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,

    X_Qte_Line_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl        OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl         OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   overloaded function includes the p_commit flag
--
--   End of Comments
--
PROCEDURE Submit_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_commit                     IN   VARCHAR2  ,
    p_control_rec		 IN   Submit_Control_Rec_Type
					:= G_MISS_Submit_Control_Rec,
    P_Qte_Header_Id		 IN   NUMBER,
    x_order_header_rec		 OUT NOCOPY /* file.sql.39 change */  Order_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:


--
--   End of Comments
--
PROCEDURE Create_Quote_Line(

    P_Api_Version_Number   IN   NUMBER,
    P_Init_Msg_List        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Rec           IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_Qte_Line_Rec         IN   Qte_Line_Rec_Type  := G_MISS_qte_line_REC,
    P_Control_Rec          IN   Control_rec_Type   := G_MISS_control_REC,
    P_Qte_Line_Dtl_Tbl    IN   Qte_Line_Dtl_Tbl_Type:= G_MISS_qte_line_dtl_TBL,
    P_Line_Attribs_Ext_Tbl IN   Line_Attribs_Ext_Tbl_type
                                        := G_Miss_Line_Attribs_Ext_Tbl,
    P_Payment_Tbl          IN   Payment_Tbl_Type   := G_MISS_Payment_TBL,
    P_Price_Adj_Tbl        IN   Price_Adj_Tbl_Type := G_MISS_Price_Adj_TBL,
    P_Price_Attributes_Tbl IN   Price_Attributes_Tbl_Type := G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN  Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Shipment_Tbl          IN  Shipment_Tbl_Type   := G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN  Tax_Detail_Tbl_Type:= G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN  Freight_Charge_Tbl_Type   := G_MISS_freight_charge_TBL,
    P_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag    IN  VARCHAR2   := FND_API.G_TRUE,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  Qte_Line_Rec_Type,
    X_Qte_Line_Dtl_TBL      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_TBL_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type ,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Return_Status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_Quote_Line
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN

PROCEDURE Update_Quote_Line(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Qte_Header_Rec           IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_Qte_Line_Rec        IN    Qte_Line_Rec_Type  := G_MISS_qte_line_REC,
    P_Control_Rec         IN    Control_rec_Type   := G_MISS_control_REC,
    P_Qte_Line_Dtl_TBL   IN    Qte_Line_Dtl_tbl_Type:= G_MISS_qte_line_dtl_TBL,
    P_Line_Attribs_Ext_Tbl  IN   Line_Attribs_Ext_Tbl_type
                                        := G_Miss_Line_Attribs_Ext_Tbl,
    P_Payment_Tbl           IN    Payment_Tbl_Type   := G_MISS_Payment_TBL,
    P_Price_Adj_Tbl         IN    Price_Adj_Tbl_Type := G_MISS_Price_Adj_TBL,
    P_Price_Attributes_Tbl  IN   Price_Attributes_Tbl_Type := G_MISS_Price_attributes_TBL,
    P_Price_Adj_Attr_Tbl    IN   Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Shipment_Tbl          IN    Shipment_Tbl_Type   := G_MISS_shipment_TBL,
    P_Tax_Detail_Tbl        IN    Tax_Detail_Tbl_Type:= G_MISS_tax_detail_TBL,
    P_Freight_Charge_Tbl    IN   Freight_Charge_Tbl_Type   := G_MISS_freight_charge_TBL,
    P_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    P_Update_Header_Flag    IN   VARCHAR2   := FND_API.G_TRUE,
    X_Qte_Line_Rec          OUT NOCOPY /* file.sql.39 change */  Qte_Line_Rec_Type,
    X_Qte_Line_Dtl_TBL      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_TBL_Type,
    X_Line_Attribs_Ext_Tbl  OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_type,
    X_Payment_Tbl           OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Price_Adj_Tbl         OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Attributes_Tbl  OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type ,
    X_Price_Adj_Attr_Tbl    OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Shipment_Tbl          OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Tax_Detail_Tbl        OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Freight_Charge_Tbl    OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type ,
    X_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

PROCEDURE Delete_Quote_Line(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_qte_line_Rec     IN    qte_line_Rec_Type,
    P_Control_REC      IN    Control_Rec_Type := G_MISS_Control_Rec,
    P_Update_Header_Flag         IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

PROCEDURE Quote_Security_Check(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_User_Id                    IN   NUMBER,
    X_Resource_Id                OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Security_Flag              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Quote
--   Type    :  Public
--   Pre-Req :
--   Parameters: Overloaded to include P_Qte_Header_Rec
--
--   End of Comments
--

/*# Use this procedure to convert quotes into orders.

*    @param         p_api_version_number   API version used to check the compatibility of a call.
*    @param         p_init_msg_list        Boolean parameter which determines whether internal message tables should be initialized.
*    @param         p_commit            Boolean  parameter which is used by API callers to ask the API to commit on their behalf after performing its function.
*    @param         p_control_rec               Input control record structure containing information about the actions (Price,Tax and so on.) that can be performed on a quote.
*    @param         P_Qte_Header_Rec            Input record structure containing current header level information of a quote to be converted into an order.
*    @param         X_Order_Header_Rec          Output record structure containing order header level information containing Order Id which is the unique identifier for an order.
*    @param         x_return_status     Return status of an API call
*    @param         x_msg_count    Number of stored processing messages.
*    @param         x_msg_data                  Processing message data.
*    @rep:scope          public
*    @rep:lifecycle      active
*    @rep:category  BUSINESS_ENTITY     ASO_QUOTE
*    @rep:displayname       Submit  Quote
*/
PROCEDURE Submit_Quote
(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    p_control_rec         IN   ASO_QUOTE_PUB.SUBMIT_CONTROL_REC_TYPE
                                            :=  ASO_QUOTE_PUB.G_MISS_SUBMIT_CONTROL_REC,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Order_Header_Rec    OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Order_Header_Rec_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2);


-- vtariker: Sales Credit Allocation Public API
PROCEDURE Allocate_Sales_Credits
(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit              IN   VARCHAR2     := FND_API.G_FALSE,
    p_control_rec         IN   ASO_QUOTE_PUB.SALES_ALLOC_CONTROL_REC_TYPE
                                            :=  ASO_QUOTE_PUB.G_MISS_SALES_ALLOC_CONTROL_REC,
    P_Qte_Header_Rec      IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Qte_Header_Rec      OUT NOCOPY /* file.sql.39 change */  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2);


PROCEDURE Sales_Credit_Event_Pre (
                  P_Qte_Header_Id     IN  NUMBER,
                  X_Return_Status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

PROCEDURE Sales_Credit_Event_Post (
                  P_Qte_Header_Id     IN  NUMBER,
                  X_Return_Status     OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--   Version : Current version 2.0
--   Note: This is an overloaded procedure. It takes additional attributes
--   which include the p_template_tbl, P_Qte_Access_Tbl and P_Related_Obj_Tbl record
--   types
--
--   End of Comments
--

/*#
* Use this procedure to create new quotes.
* This API allows users to create a quote and enter price adjustments, pricing attributes, sales credits, shipping, tax, payment information for the quote.
*    @param         p_api_version_number   API version used to check the compatibility of a call.
*    @param         p_init_msg_list        Boolean parameter which determines whether internal message table should be initialized.
*    @param         P_Validation_Level     Number parameter to determine which validation steps to execute and which steps to skip.
*    @param         p_commit               Boolean  parameter which is used by API callers to ask the API to commit on their behalf after performing its function.
*    @param         x_return_status        Return status of API call
*    @param         x_msg_count            Number of stored processing messages
*    @param         x_msg_data                  Processing message data
*    @param         p_control_rec               Input control record structure containing information about the actions (Price,Tax, and so on) that can be performed on a quote.
*    @param         P_Qte_Header_Rec            Input record structure containing current header level information to create a quote.
*    @param         P_hd_Price_Attributes_Tbl   Input table structure containing current header level information for pricing attributes.
*    @param         P_hd_Payment_Tbl            Input table  structure containing current header level Payment information for a quote.
*    @param         P_hd_Shipment_Rec           Input record structure containing current header level Shipment information for a quote.
*    @param         P_hd_Freight_Charge_Tbl     Not Used (Obsolete).
*    @param         P_hd_Tax_Detail_Tbl         Input table structure containing current header level Tax information for a quote.
*    @param         P_hd_Attr_Ext_Tbl           Not Used (Obsolete).
*    @param         P_hd_Sales_Credit_Tbl       Input table  structure containing current header level Sales Credit information for a quote.
*    @param         P_hd_Quote_Party_Tbl        Not Used (Obsolete).
*    @param         P_Qte_Line_Tbl      Input table structure containing quote lines  information to create a quote.
*    @param         P_Qte_Line_Dtl_Tbl  Input table structure containing line details (Configuration Lines,Service Lines) information to create a quote.
*    @param         P_Line_Attr_Ext_Tbl         Not Used (Obsolete).
*    @param         P_line_rltship_tbl          Input table structure containing relationships at the line level in a quote.
*    @param         P_Price_Adjustment_Tbl      Input table structure containing  Price Adjustments (Header and Lines) information to create a quote.
*    @param         P_Price_Adj_Attr_Tbl        Input table structure containing  Price Adjustments Attributes (Header and Lines) information to create a quote.
*    @param         P_Price_Adj_Rltship_Tbl     Input table structure containing relationships at Price Adjustment level.
*    @param         P_Ln_Price_Attributes_Tbl   Input table structure containing quote line level information for pricing attributes.
*    @param         P_Ln_Payment_Tbl            Input table  structure containing quote line level payment information for a quote.
*    @param         P_Ln_Shipment_Tbl           Input record structure containing Quote Line level Shipment information for a quote.
*    @param         P_Ln_Freight_Charge_Tbl     Not Used (Obsolete).
*    @param         P_Ln_Tax_Detail_Tbl         Input table structure containing quote line level Tax information for a quote.
*    @param         P_Ln_Sales_Credit_Tbl       Input table  structure containing quote line level Sales Credit information for a quote.
*    @param         P_Ln_Quote_Party_Tbl        Not Used (Obsolete).
*    @param         P_Qte_Access_Tbl            Input table structure containing information about quote sales team for a quote.
*    @param         P_Template_Tbl              Input table structure containing information on quote template.
*    @param         P_Related_Obj_Tbl           Input table structure containing information on relationship between a quote or a quote line to any entity in the schema and records the type of relationship.
*    @param         X_Qte_Header_Rec            Output record structure containing quote header level information with a Quote Header Id. This is a  unique identifier generated for the newly  created quote.
*    @param         X_hd_Price_Attributes_Tbl   Output table structure containing header level information for pricing attributes with a Price Attribute Id. This is a unique identifier generated for the newly  created price attribute records.
*    @param         X_hd_Payment_Tbl            Output table  structure containing header level Payment information for a quote with a Payment Id. This is a  unique identifier generated for the newly  created payment records.
*    @param         X_hd_Shipment_Rec           Output record structure containing header level Shipment information for a quote with a Shipment Id. This is a  unique identifier generated for the newly  created shipment records.
*    @param         X_Hd_Freight_Charge_Tbl     Not Used (Obsolete).
*    @param         X_hd_Tax_Detail_Tbl         Output table structure containing header level Tax information for a quote with a Tax Detail Id. This is a  unique identifier generated for the newly  created tax detail records
*    @param         X_hd_Attr_Ext_Tbl           Not Used (Obsolete).
*    @param         X_hd_Sales_Credit_Tbl       Output table  structure containing header level Sales Credit information for a quote with a Sales Credit Id. This is a unique identifier generated for the newly created sales credit records.
*    @param         X_hd_Quote_Party_Tbl        Not Used (Obsolete).
*    @param         X_Qte_Line_Tbl              Output table structure containing quote lines information for a quote with a Quote Line Id. This is a unique identifier generated for the newly  created quote lines.
*    @param         X_Qte_Line_Dtl_Tbl          Output table structure containing line details (Configurator,Service Lines)information for a quote with a Line Detail Id. This is a unique identifier generated for the newly  created line detail records.
*    @param         X_Line_Attr_Ext_Tbl         Not Used (Obsolete)
*    @param         X_line_rltship_tbl          Output table structure containing relationships at line level with a Line Relationship Id.
*    @param         X_Price_Adjustment_Tbl      Output table structure containing Price Adjustments(Header and Lines)information for a quote with a Price Adjustment Id. This is a unique identifier generated for the newly created price adjustment records.
*    @param         X_Price_Adj_Attr_Tbl Output table structure containing Price Adjustment Attributes(Header, Lines) information for a quote. Price_adj_attribute_id is a unique identifier generated for the price adjustment attributes records.
*    @param         X_Price_Adj_Rltship_Tbl     Output table structure containing  relationships at Price Adjustment level with a Adjustment Relationship Id. This is a unique identifier generated for the price adjustment relationship records.
*    @param         X_Ln_Price_Attributes_Tbl   Output table structure containing  quote line level information for pricing attributes with a Price Attribute Id. This is a unique identifier generated for the newly  created price attribute records.
*    @param         X_Ln_Payment_Tbl            Output table  structure containing quote line level Payment information for a quote with a Payment Id. This is a unique identifier generated for the newly created payment records.
*    @param         X_Ln_Shipment_Tbl           Output record structure containing line level Shipment information for a quote with a Shipment Id. This is a unique identifier generated for the newly created shipment records.
*    @param         X_Ln_Freight_Charge_Tbl    Not Used (Obsolete).
*    @param         X_Ln_Tax_Detail_Tbl        Output table structure containing line level Tax information for a quote with a Tax Detail Id. This is a unique identifier generated for the newly created tax detail records.
*    @param         X_Ln_Sales_Credit_Tbl      Output table  structure containing line level Sales Credit information for a quote with a Sales Credit Id. This is a unique identifier generated for the newly created sales credit records.
*    @param         X_Ln_Quote_Party_Tbl     Not Used (Obsolete).
*    @param         X_Qte_Access_Tbl          Output table  structure containing  information about quote sales team for a quote.This is a unique identifier generated for the quote access record.
*    @param         X_Template_Tbl            Output table  structure containing  containing information on quote template.This is a unique identifier generated for the quote template.
*    @param         X_Related_Obj_Tbl         Output table  structureontaining information on relationship between a quote or a quote line to any entity in the schema .This is a unique identifier generated for the quote relationship  record.
 *    @rep:scope          public
 *    @rep:lifecycle      active
 *    @rep:category  BUSINESS_ENTITY     ASO_QUOTE
 *    @rep:displayname       Create Quote
*
*/
PROCEDURE Create_quote(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level         IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec              IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec           IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl           IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type         := G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl          IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl      IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl       IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl             IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl         IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl        IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl         IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl     IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	      IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl           IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl          IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl    IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl        IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl      IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl       IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl           IN   Qte_Access_Tbl_Type                     := G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl             IN   Template_Tbl_Type                       := G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl          IN   Related_Obj_Tbl_Type                    := G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec           OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl             OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */  Shipment_Rec_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	      OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl           OUT NOCOPY /* file.sql.39 change */  Qte_Access_Tbl_Type,
    X_Template_Tbl             OUT NOCOPY /* file.sql.39 change */  Template_Tbl_Type,
    X_Related_Obj_Tbl          OUT NOCOPY /* file.sql.39 change */  Related_Obj_Tbl_Type,
    X_Return_Status            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_quote_Service
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--   Version : Current version 1.0
--   End of Comments

PROCEDURE Create_quote_Service(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2                                := FND_API.G_FALSE,
    P_Validation_Level         IN   NUMBER                                  := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec              IN   Control_Rec_Type                        := G_Miss_Control_Rec,
    P_Qte_Header_Rec           IN   Qte_Header_Rec_Type                     := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl  IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type := G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl           IN   ASO_QUOTE_PUB.Payment_Tbl_Type          := G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Rec          IN   ASO_QUOTE_PUB.Shipment_Rec_Type         := G_MISS_SHIPMENT_REC,
    P_hd_Freight_Charge_Tbl    IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type   := G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl        IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type       := G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl          IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl      IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl       IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl             IN   Qte_Line_Tbl_Type                       := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl         IN   Qte_Line_Dtl_Tbl_Type                   := G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl        IN   Line_Attribs_Ext_Tbl_Type               := G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl         IN   Line_Rltship_Tbl_Type                   := G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl     IN   Price_Adj_Tbl_Type                      := G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	      IN   Price_Adj_Attr_Tbl_Type                 := G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type              := G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type               := G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl           IN   Payment_Tbl_Type                        := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl          IN   Shipment_Tbl_Type                       := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl    IN   Freight_Charge_Tbl_Type                 := G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl        IN   Tax_Detail_Tbl_Type                     := G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl      IN   Sales_Credit_Tbl_Type                   := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl       IN   Quote_Party_Tbl_Type                    := G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl           IN   Qte_Access_Tbl_Type                     := G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl             IN   Template_Tbl_Type                       := G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl          IN   Related_Obj_Tbl_Type                    := G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec           OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,
    X_Qte_Line_Tbl             OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Rec		 OUT NOCOPY /* file.sql.39 change */  Shipment_Rec_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	      OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl           OUT NOCOPY /* file.sql.39 change */  Qte_Access_Tbl_Type,
    X_Template_Tbl             OUT NOCOPY /* file.sql.39 change */  Template_Tbl_Type,
    X_Related_Obj_Tbl          OUT NOCOPY /* file.sql.39 change */  Related_Obj_Tbl_Type,
    X_Return_Status            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_quote
--   Type    :  Public
--   Pre-Req :
--   Parameters:

--  This is an overloaded procedure. It takes additional parameters
--  which include the p_template_tbl, P_Qte_Access_Tbl and P_Related_Obj_Tbl record
--  types


PROCEDURE Update_quote(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 	IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec		 IN   Control_Rec_Type := G_Miss_Control_Rec,
    P_Qte_Header_Rec		 IN    Qte_Header_Rec_Type  := G_MISS_Qte_Header_Rec,
    P_hd_Price_Attributes_Tbl	 IN   ASO_QUOTE_PUB.Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_hd_Payment_Tbl		 IN   ASO_QUOTE_PUB.Payment_Tbl_Type
					:= G_MISS_PAYMENT_TBL,
    P_hd_Shipment_Tbl		 IN   ASO_QUOTE_PUB.Shipment_Tbl_Type
					:= G_MISS_SHIPMENT_TBL,
    P_hd_Freight_Charge_Tbl	 IN   ASO_QUOTE_PUB.Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_hd_Tax_Detail_Tbl		 IN   ASO_QUOTE_PUB.Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    P_hd_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type
					:= G_MISS_Line_Attribs_Ext_TBL,
    P_hd_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_hd_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    P_Qte_Line_Tbl		 IN   Qte_Line_Tbl_Type := G_MISS_QTE_LINE_TBL,
    P_Qte_Line_Dtl_Tbl		 IN   Qte_Line_Dtl_Tbl_Type
					:= G_MISS_QTE_LINE_DTL_TBL,
    P_Line_Attr_Ext_Tbl		 IN   Line_Attribs_Ext_Tbl_Type
					:= G_MISS_Line_Attribs_Ext_TBL,
    P_line_rltship_tbl		 IN   Line_Rltship_Tbl_Type
					:= G_MISS_Line_Rltship_Tbl,
    P_Price_Adjustment_Tbl	 IN   Price_Adj_Tbl_Type
					:= G_Miss_Price_Adj_Tbl,
    P_Price_Adj_Attr_Tbl	 IN   Price_Adj_Attr_Tbl_Type
					:= G_Miss_PRICE_ADJ_ATTR_Tbl,
    P_Price_Adj_Rltship_Tbl	 IN   Price_Adj_Rltship_Tbl_Type
					:= G_Miss_Price_Adj_Rltship_Tbl,
    P_Ln_Price_Attributes_Tbl	 IN   Price_Attributes_Tbl_Type
					:= G_Miss_Price_Attributes_Tbl,
    P_Ln_Payment_Tbl		 IN   Payment_Tbl_Type := G_MISS_PAYMENT_TBL,
    P_Ln_Shipment_Tbl		 IN   Shipment_Tbl_Type := G_MISS_SHIPMENT_TBL,
    P_Ln_Freight_Charge_Tbl	 IN   Freight_Charge_Tbl_Type
					:= G_Miss_Freight_Charge_Tbl,
    P_Ln_Tax_Detail_Tbl		 IN   Tax_Detail_Tbl_Type
					:= G_Miss_Tax_Detail_Tbl,
    P_ln_Sales_Credit_Tbl        IN   Sales_Credit_Tbl_Type
                                        := G_MISS_Sales_Credit_Tbl,
    P_ln_Quote_Party_Tbl         IN   Quote_Party_Tbl_Type
                                        := G_MISS_Quote_Party_Tbl,
    P_Qte_Access_Tbl           IN   Qte_Access_Tbl_Type := G_MISS_QTE_ACCESS_TBL,
    P_Template_Tbl             IN   Template_Tbl_Type   := G_MISS_TEMPLATE_TBL,
    P_Related_Obj_Tbl          IN   Related_Obj_Tbl_Type                    := G_MISS_RELATED_OBJ_TBL,
    x_Qte_Header_Rec		 OUT NOCOPY /* file.sql.39 change */  Qte_Header_Rec_Type,

    X_Qte_Line_Tbl		      OUT NOCOPY /* file.sql.39 change */  Qte_Line_Tbl_Type,
    X_Qte_Line_Dtl_Tbl		 OUT NOCOPY /* file.sql.39 change */  Qte_Line_Dtl_Tbl_Type,
    X_Hd_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Hd_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Hd_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Hd_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Hd_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_hd_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_hd_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_hd_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    x_Line_Attr_Ext_Tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Attribs_Ext_Tbl_Type,
    X_line_rltship_tbl		 OUT NOCOPY /* file.sql.39 change */  Line_Rltship_Tbl_Type,
    X_Price_Adjustment_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Tbl_Type,
    X_Price_Adj_Attr_Tbl	      OUT NOCOPY /* file.sql.39 change */  Price_Adj_Attr_Tbl_Type,
    X_Price_Adj_Rltship_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Adj_Rltship_Tbl_Type,
    X_Ln_Price_Attributes_Tbl	 OUT NOCOPY /* file.sql.39 change */  Price_Attributes_Tbl_Type,
    X_Ln_Payment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Payment_Tbl_Type,
    X_Ln_Shipment_Tbl		 OUT NOCOPY /* file.sql.39 change */  Shipment_Tbl_Type,
    X_Ln_Freight_Charge_Tbl	 OUT NOCOPY /* file.sql.39 change */  Freight_Charge_Tbl_Type,
    X_Ln_Tax_Detail_Tbl		 OUT NOCOPY /* file.sql.39 change */  Tax_Detail_Tbl_Type,
    X_Ln_Sales_Credit_Tbl      OUT NOCOPY /* file.sql.39 change */  Sales_Credit_Tbl_Type,
    X_Ln_Quote_Party_Tbl       OUT NOCOPY /* file.sql.39 change */  Quote_Party_Tbl_Type,
    X_Qte_Access_Tbl           OUT NOCOPY /* file.sql.39 change */  Qte_Access_Tbl_Type,
    X_Template_Tbl             OUT NOCOPY /* file.sql.39 change */  Template_Tbl_Type,
    X_Related_Obj_Tbl          OUT NOCOPY /* file.sql.39 change */  Related_Obj_Tbl_Type,
    X_Return_Status            OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  validate_model_configuration
--   Type    :  Public
--   Pre-Req :
--   Parameters:


/*#
* Use this procedure to validate the model configurations.
* @param   p_api_version_number   API version used to check the compatibility of a call.
* @param   p_init_msg_list        Boolean parameter which determines whether internal message tables should be initialized.
* @param   p_commit            Boolean  parameter which is used by API callers to ask the API to commit on their behalf after performing its function.
* @param  P_QUOTE_HEADER_ID                Quote header id for the quote.
* @param  P_QUOTE_LINE_ID                  Quote line id for the top level model item in the quote. If this parameter is not passed, then all the configurations in the quote should be validated.
* @param  P_UPDATE_QUOTE                  If set to 'Yes', then the results of the validation will be applied. Default is 'Yes'. If set to No, then the quote will not be updated.
* @param  P_CONFIG_EFFECTIVE_DATE         Date parameter and default value is FND_API.G_MISS_DATE. If no specific date value is passed then derives the date based on the profile ASO: Configuration Effective Date.
* @param  P_CONFIG_MODEL_LOOKUP_DATE      Date parameter and default value is FND_API.G_MISS_DATE. If no specific date value is passed then derives the date based on the profile ASO: Configuration Effective Date.
* @param  X_Config_tbl                   Output table structure containing configuration details.
* @param  x_return_status     Return status of an API call.
* @param  x_msg_count    Number of stored processing messages.
* @param  x_msg_data                  Processing message data.
* @rep:scope          public
* @rep:lifecycle      active
* @rep:category  BUSINESS_ENTITY     ASO_QUOTE
* @rep:displayname      Validate model configuration
*/

    procedure validate_model_configuration
(
    P_Api_Version_Number               IN             NUMBER    := FND_API.G_MISS_NUM,
    P_Init_Msg_List                              IN             VARCHAR2  := FND_API.G_TRUE,
    P_Commit                                     IN             VARCHAR2  := FND_API.G_FALSE,
    P_Quote_header_id                   IN   NUMBER,
    p_Quote_line_id                          IN   NUMBER := FND_API.G_MISS_NUM,
    P_UPDATE_QUOTE                   IN   VARCHAR2     := FND_API.G_FALSE,
    P_Config_EFFECTIVE_DATE		     IN   Date  := FND_API.G_MISS_DATE,
    P_Config_model_lookup_DATE             IN   Date  := FND_API.G_MISS_DATE,
    X_Config_tbl                                          OUT NOCOPY /* file.sql.39 change */ Config_Vaild_Tbl_Type,
    X_Return_Status                                     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    X_Msg_Count                                          OUT NOCOPY /* file.sql.39 change */  NUMBER,
    X_Msg_Data                                             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    );

End ASO_QUOTE_PUB;

/
