--------------------------------------------------------
--  DDL for Package OE_INVOICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_INVOICE_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPINVS.pls 120.6.12010000.4 2010/08/23 09:10:06 amallik ship $ */

--  Start of Comments
--  API name    OE_Invoice_PUB
--  Type        Public
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
-- Order line Workflow AutoInvoice Interface function
-- Ra Interface Lines record type

TYPE RA_Interface_Lines_Rec_Type IS RECORD
(   CREATED_BY                    NUMBER(15)      :=NULL
,   CREATION_DATE                 DATE            :=NULL
,   LAST_UPDATED_BY               NUMBER(15)      :=NULL
,   LAST_UPDATE_DATE              DATE            :=NULL
,   INTERFACE_LINE_ATTRIBUTE1     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE2     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE3     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE4     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE5     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE6     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE7     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE8     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE9     VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE10    VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE11    VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE12    VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE13    VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE14    VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE15    VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ID             NUMBER(15)      :=NULL
,   INTERFACE_LINE_CONTEXT        VARCHAR2(30)    :=NULL
,   WAREHOUSE_ID                  NUMBER(15)      :=NULL
,   BATCH_SOURCE_NAME             VARCHAR2(50)    :=NULL
,   SET_OF_BOOKS_ID               NUMBER(15)      :=NULL
,   LINE_TYPE                     VARCHAR2(20)    :=NULL
,   DESCRIPTION                   VARCHAR2(240)   :=NULL
,   CURRENCY_CODE                 VARCHAR2(15)    :=NULL
,   AMOUNT                        NUMBER          :=NULL
,   CONVERSION_TYPE               VARCHAR2(30)    :=NULL
,   CONVERSION_DATE               DATE            :=NULL
,   CONVERSION_RATE               NUMBER          :=NULL
,   CUST_TRX_TYPE_NAME            VARCHAR2(20)    :=NULL
,   CUST_TRX_TYPE_ID              NUMBER(15)      :=NULL
,   TERM_NAME                     VARCHAR2(15)    :=NULL
,   TERM_ID                       NUMBER(15)      :=NULL
,   ORIG_SYSTEM_BILL_CUSTOMER_REF VARCHAR2(240)   :=NULL
,   ORIG_SYSTEM_BILL_CUSTOMER_ID  NUMBER(15)      :=NULL
,   ORIG_SYSTEM_BILL_ADDRESS_REF  VARCHAR2(240)   :=NULL
,   ORIG_SYSTEM_BILL_ADDRESS_ID   NUMBER(15)      :=NULL
,   ORIG_SYSTEM_BILL_CONTACT_REF  VARCHAR2(240)   :=NULL
,   ORIG_SYSTEM_BILL_CONTACT_ID   NUMBER(15)      :=NULL
,   ORIG_SYSTEM_SHIP_CUSTOMER_REF VARCHAR2(240)   :=NULL
,   ORIG_SYSTEM_SHIP_CUSTOMER_ID  NUMBER(15)      :=NULL
,   ORIG_SYSTEM_SHIP_ADDRESS_REF  VARCHAR2(240)   :=NULL
,   ORIG_SYSTEM_SHIP_ADDRESS_ID   NUMBER(15)      :=NULL
,   ORIG_SYSTEM_SHIP_CONTACT_REF  VARCHAR2(240)   :=NULL
,   ORIG_SYSTEM_SHIP_CONTACT_ID   NUMBER(15)      :=NULL
,   ORIG_SYSTEM_SOLD_CUSTOMER_REF VARCHAR2(240)   :=NULL
,   ORIG_SYSTEM_SOLD_CUSTOMER_ID  NUMBER(15)      :=NULL
,   LINK_TO_LINE_ID               NUMBER(15)      :=NULL
,   LINK_TO_LINE_CONTEXT          VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE1       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE2       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE3       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE4       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE5       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE6       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE7       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE8       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE9       VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE10      VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE11      VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE12      VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE13      VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE14      VARCHAR2(30)    :=NULL
,   LINK_TO_LINE_ATTRIBUTE15      VARCHAR2(30)    :=NULL
,   RECEIPT_METHOD_NAME           VARCHAR2(30)    :=NULL
,   RECEIPT_METHOD_ID             NUMBER(15)      :=NULL
,   CUSTOMER_TRX_ID               NUMBER(15)      :=NULL
,   TRX_DATE                      DATE            :=NULL
,   GL_DATE                       DATE            :=NULL
,   DOCUMENT_NUMBER               NUMBER(15)      :=NULL
,   DOCUMENT_NUMBER_SEQUENCE_ID   NUMBER(15)      :=NULL
,   TRX_NUMBER                    VARCHAR2(20)    :=NULL
,   QUANTITY                      NUMBER          :=NULL
,   QUANTITY_ORDERED              NUMBER          :=NULL
,   UNIT_SELLING_PRICE            NUMBER          :=NULL
,   UNIT_STANDARD_PRICE           NUMBER          :=NULL
,   UOM_CODE                      VARCHAR2(3)     :=NULL
,   UOM_NAME                      VARCHAR2(25)    :=NULL
,   PRINTING_OPTION               VARCHAR2(20)    :=NULL
,   INTERFACE_STATUS              VARCHAR2(1)     :=NULL
,   REQUEST_ID                    NUMBER(15)      :=NULL
,   RELATED_BATCH_SOURCE_NAME     VARCHAR2(50)    :=NULL
,   RELATED_TRX_NUMBER            VARCHAR2(20)    :=NULL
,   RELATED_CUSTOMER_TRX_ID       NUMBER(15)      :=NULL
,   PREVIOUS_CUSTOMER_TRX_ID      NUMBER(15)      :=NULL
,   INITIAL_CUSTOMER_TRX_ID       NUMBER(15)      :=NULL
,   CREDIT_METHOD_FOR_ACCT_RULE   VARCHAR2(30)    :=NULL
,   CREDIT_METHOD_FOR_INSTALLMENTS  VARCHAR2(30)  :=NULL
,   REASON_CODE_MEANING           VARCHAR2(80)    :=NULL
,   REASON_CODE                   VARCHAR2(30)    :=NULL
,   TAX_RATE                      NUMBER          :=NULL
,   TAX_CODE                      VARCHAR2(50)    :=NULL
,   TAX_PRECEDENCE                NUMBER          :=NULL
,   TAX_EXEMPT_FLAG               VARCHAR2(1)     :=NULL
,   TAX_EXEMPT_NUMBER             VARCHAR2(80)    :=NULL
,   TAX_EXEMPT_REASON_CODE        VARCHAR2(30)    :=NULL
,   EXCEPTION_ID                  NUMBER(15)      :=NULL
,   EXEMPTION_ID                  NUMBER(15)      :=NULL
,   SHIP_DATE_ACTUAL              DATE            :=NULL
,   FOB_POINT                     VARCHAR2(30)    :=NULL
,   SHIP_VIA                      VARCHAR2(25)    :=NULL
,   WAYBILL_NUMBER                VARCHAR2(50)    :=NULL
,   INVOICING_RULE_NAME           VARCHAR2(30)    :=NULL
,   INVOICING_RULE_ID             NUMBER(15)      :=NULL
,   ACCOUNTING_RULE_NAME          VARCHAR2(30)    :=NULL
,   ACCOUNTING_RULE_ID            NUMBER(15)      :=NULL
,   ACCOUNTING_RULE_DURATION      NUMBER(15)      :=NULL
,   RULE_START_DATE               DATE            :=NULL
,   RULE_END_DATE                 DATE            :=NULL --ER 4893057
,   PRIMARY_SALESREP_NUMBER       VARCHAR2(30)    :=NULL
,   PRIMARY_SALESREP_ID           NUMBER(15)      :=NULL
,   SALES_ORDER                   VARCHAR2(50)    :=NULL
,   SALES_ORDER_LINE              VARCHAR2(30)    :=NULL
,   SALES_ORDER_DATE              DATE            :=NULL
,   SALES_ORDER_SOURCE            VARCHAR2(50)    :=NULL
,   SALES_ORDER_REVISION          NUMBER          :=NULL
,   PURCHASE_ORDER                VARCHAR2(50)    :=NULL
,   PURCHASE_ORDER_REVISION       VARCHAR2(50)    :=NULL
,   PURCHASE_ORDER_DATE           DATE            :=NULL
,   AGREEMENT_NAME                VARCHAR2(30)    :=NULL
,   AGREEMENT_ID                  NUMBER(15)      :=NULL
,   MEMO_LINE_NAME                VARCHAR2(50)    :=NULL
,   MEMO_LINE_ID                  NUMBER(15)      :=NULL
,   INVENTORY_ITEM_ID             NUMBER(15)      :=NULL
,   MTL_SYSTEM_ITEMS_SEG1         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG2         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG3         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG4         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG5         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG6         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG7         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG8         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG9         VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG10        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG11        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG12        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG13        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG14        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG15        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG16        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG17        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG18        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG19        VARCHAR2(30)    :=NULL
,   MTL_SYSTEM_ITEMS_SEG20        VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ID             NUMBER(15)      :=NULL
,   REFERENCE_LINE_CONTEXT        VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE1     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE2     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE3     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE4     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE5     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE6     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE7     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE8     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE9     VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE10    VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE11    VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE12    VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE13    VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE14    VARCHAR2(30)    :=NULL
,   REFERENCE_LINE_ATTRIBUTE15    VARCHAR2(30)    :=NULL
,   TERRITORY_ID                  NUMBER(15)      :=NULL
,   TERRITORY_SEGMENT1            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT2            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT3            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT4            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT5            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT6            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT7            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT8            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT9            VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT10           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT11           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT12           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT13           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT14           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT15           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT16           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT17           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT18           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT19           VARCHAR2(25)    :=NULL
,   TERRITORY_SEGMENT20           VARCHAR2(25)    :=NULL
,   ATTRIBUTE_CATEGORY            VARCHAR2(30)    :=NULL
,   ATTRIBUTE1                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE2                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE3                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE4                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE5                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE6                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE7                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE8                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE9                    VARCHAR2(150)   :=NULL
,   ATTRIBUTE10                   VARCHAR2(150)   :=NULL
,   ATTRIBUTE11                   VARCHAR2(150)   :=NULL
,   ATTRIBUTE12                   VARCHAR2(150)   :=NULL
,   ATTRIBUTE13                   VARCHAR2(150)   :=NULL
,   ATTRIBUTE14                   VARCHAR2(150)   :=NULL
,   ATTRIBUTE15                   VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE_CATEGORY     VARCHAR2(30)    :=NULL
,   HEADER_ATTRIBUTE1             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE2             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE3             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE4             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE5             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE6             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE7             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE8             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE9             VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE10            VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE11            VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE12            VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE13            VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE14            VARCHAR2(150)   :=NULL
,   HEADER_ATTRIBUTE15            VARCHAR2(150)   :=NULL
,   COMMENTS                      VARCHAR2(240)   :=NULL
,   INTERNAL_NOTES                VARCHAR2(240)   :=NULL
,   MOVEMENT_ID                   NUMBER(15)      :=NULL
,   ORG_ID                        NUMBER(15)      :=NULL
,   CUSTOMER_BANK_ACCOUNT_ID      NUMBER(15)      :=NULL
,   CUSTOMER_BANK_ACCOUNT_NAME    VARCHAR2(80)    :=NULL
,   APPROVAL_CODE                 VARCHAR2(80)    :=NULL
,   PAYMENT_SERVER_ORDER_NUM      VARCHAR2(80)    :=NULL
,   LINE_GDF_ATTR_CATEGORY 	    VARCHAR2(30)    :=NULL
,   LINE_GDF_ATTRIBUTE1		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE2		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE3		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE4		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE5		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE6		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE7		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE8		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE9		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE10	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE11	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE12	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE13	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE14	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE15	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE16	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE17	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE18	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE19	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE20	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTR_CATEGORY 	    VARCHAR2(30)    :=NULL
,   HEADER_GDF_ATTRIBUTE1	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE2	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE3	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE4	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE5	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE6	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE7	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE8	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE9	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE10	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE11	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE12	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE13	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE14	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE15	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE16	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE17	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE18	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE19	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE20	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE21	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE22	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE23	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE24	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE25	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE26	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE27	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE28	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE29	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE30	    VARCHAR2(150)   :=NULL
,   PROMISED_COMMITMENT_AMOUNT      NUMBER          :=NULL
/* START PREPAYMENT */
,   PAYMENT_SET_ID                  NUMBER(15)      :=NULL
/* END PREPAYMENT */
,   TRANSLATED_DESCRIPTION          VARCHAR2(1000)  :=NULL
--Customer Acceptance
,   PARENT_LINE_ID                  NUMBER(15)      :=NULL
,   DEFERRAL_EXCLUSION_FLAG         VARCHAR2(1)     :=NULL
,   PAYMENT_TRXN_EXTENSION_ID	    NUMBER(15)      := NULL
,   PAYMENT_TYPE_CODE               VARCHAR2(30)    := NULL  --8427382
);

TYPE RA_Interface_Lines_Tbl_Type IS TABLE OF RA_Interface_Lines_Rec_Type
    INDEX BY BINARY_INTEGER;

--Customer Acceptance
TYPE RA_Interface_Conts_Rec_Type IS RECORD
(
  INTERFACE_CONTINGENCY_ID         NUMBER         :=NULL
  ,CONTINGENCY_ID                   NUMBER      :=NULL
  ,COMPLETED_FLAG                  VARCHAR(1)      :=NULL
  ,EXPIRATION_EVENT_DATE           DATE      :=NULL
  ,EXPIRATION_DATE                 DATE      :=NULL
  ,EXPIRATION_DAYS                 NUMBER      :=NULL
  ,COMPLETED_BY                    NUMBER     := NULL
  ,INTERFACE_LINE_ID               NUMBER      :=NULL
  ,INTERFACE_LINE_CONTEXT         VARCHAR2(30)      :=NULL
  ,INTERFACE_LINE_ATTRIBUTE1      VARCHAR2(30)      :=NULL
  ,INTERFACE_LINE_ATTRIBUTE2      VARCHAR2(30)      :=NULL
  ,INTERFACE_LINE_ATTRIBUTE3      VARCHAR2(30)      :=NULL
  ,INTERFACE_LINE_ATTRIBUTE4      VARCHAR2(30)      :=NULL
  ,INTERFACE_LINE_ATTRIBUTE5      VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE6      VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE7      VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE8      VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE9      VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE10     VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE11     VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE12     VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE13     VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE14     VARCHAR2(30)      :=NULL
 , INTERFACE_LINE_ATTRIBUTE15     VARCHAR2(30)      :=NULL
 , INTERFACE_STATUS               VARCHAR2(1)      :=NULL
 , ATTRIBUTE_CATEGORY             VARCHAR2(30)      :=NULL
 , ATTRIBUTE1                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE2                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE3                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE4                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE5                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE6                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE7                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE8                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE9                     VARCHAR2(30)      :=NULL
 , ATTRIBUTE10                    VARCHAR2(30)      :=NULL
 , ATTRIBUTE11                    VARCHAR2(30)      :=NULL
 , ATTRIBUTE12                    VARCHAR2(30)      :=NULL
 , ATTRIBUTE13                    VARCHAR2(30)      :=NULL
 , ATTRIBUTE14                    VARCHAR2(30)      :=NULL
 , ATTRIBUTE15                    VARCHAR2(30)      :=NULL
 , ORG_ID                         NUMBER      :=NULL
 , REQUEST_ID                     NUMBER      :=NULL
 , CREATED_BY                     NUMBER      :=NULL
 , CREATION_DATE                  DATE        :=NULL
 , LAST_UPDATED_BY                NUMBER      :=NULL
 , LAST_UPDATE_DATE               DATE        :=NULL
 , LAST_UPDATE_LOGIN              NUMBER      :=NULL
);

TYPE RA_Interface_Conts_Tbl_Type IS TABLE OF RA_Interface_Conts_Rec_Type
    INDEX BY BINARY_INTEGER;
--Customer Acceptance


TYPE Id_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;


-- JG flexfield record type
TYPE OE_GDF_Rec_Type IS RECORD
(   INVENTORY_ITEM_ID               NUMBER(15)      :=NULL
,   LINE_TYPE                       VARCHAR2(20)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE3       VARCHAR2(30)    :=NULL
,   INTERFACE_LINE_ATTRIBUTE6       VARCHAR2(30)    :=NULL
,   LINE_GDF_ATTR_CATEGORY 	    VARCHAR2(30)    :=NULL
,   LINE_GDF_ATTRIBUTE1		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE2		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE3		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE4		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE5		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE6		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE7		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE8		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE9		    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE10	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE11	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE12	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE13	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE14	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE15	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE16	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE17	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE18	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE19	    VARCHAR2(150)   :=NULL
,   LINE_GDF_ATTRIBUTE20	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTR_CATEGORY 	    VARCHAR2(30)    :=NULL
,   HEADER_GDF_ATTRIBUTE1	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE2	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE3	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE4	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE5	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE6	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE7	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE8	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE9	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE10	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE11	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE12	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE13	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE14	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE15	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE16	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE17	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE18	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE19	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE20	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE21	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE22	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE23	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE24	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE25	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE26	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE27	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE28	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE29	    VARCHAR2(150)   :=NULL
,   HEADER_GDF_ATTRIBUTE30	    VARCHAR2(150)   :=NULL
);

-- Ra Interface Salescredits record type

TYPE RA_Interface_Scredits_Rec_Type IS RECORD
(    CREATED_BY                               NUMBER(15)      :=NULL
,    CREATION_DATE                            DATE            :=NULL
,    LAST_UPDATED_BY                          NUMBER(15)      :=NULL
,    LAST_UPDATE_DATE                         DATE            :=NULL
,    INTERFACE_SALESCREDIT_ID                 NUMBER(15)      :=NULL
,    INTERFACE_LINE_ID                        NUMBER(15)      :=NULL
,    INTERFACE_LINE_CONTEXT                   VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE1                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE2                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE3                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE4                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE5                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE6                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE7                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE8                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE9                VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE10               VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE11               VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE12               VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE13               VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE14               VARCHAR2(30)    :=NULL
,    INTERFACE_LINE_ATTRIBUTE15               VARCHAR2(30)    :=NULL
,    SALESREP_NUMBER                          VARCHAR2(30)    :=NULL
,    SALESREP_ID                              NUMBER(15)      :=NULL
,    SALES_CREDIT_TYPE_NAME                   VARCHAR2(30)    :=NULL
,    SALES_CREDIT_TYPE_ID                     NUMBER(15)      :=NULL
,    SALES_CREDIT_AMOUNT_SPLIT                NUMBER          :=NULL
,    SALES_CREDIT_PERCENT_SPLIT               NUMBER          :=NULL
,    INTERFACE_STATUS                         VARCHAR2(1)     :=NULL
,    REQUEST_ID                               NUMBER(15)      :=NULL
,    ATTRIBUTE_CATEGORY                       VARCHAR2(30)    :=NULL
,    ATTRIBUTE1                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE2                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE3                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE4                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE5                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE6                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE7                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE8                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE9                               VARCHAR2(150)   :=NULL
,    ATTRIBUTE10                              VARCHAR2(150)   :=NULL
,    ATTRIBUTE11                              VARCHAR2(150)   :=NULL
,    ATTRIBUTE12                              VARCHAR2(150)   :=NULL
,    ATTRIBUTE13                              VARCHAR2(150)   :=NULL
,    ATTRIBUTE14                              VARCHAR2(150)   :=NULL
,    ATTRIBUTE15                              VARCHAR2(150)   :=NULL
,    ORG_ID                                   NUMBER(15)      :=NULL
--SG{
, SALES_GROUP_ID NUMBER :=NULL
--SG}
);

TYPE RA_Interface_Scredits_Tbl_Type IS TABLE OF RA_Interface_Scredits_Rec_Type
    INDEX BY BINARY_INTEGER;

PROCEDURE Interface_Line
(   p_line_id       IN   NUMBER
,   p_itemtype      IN   VARCHAR2
,   x_result_out    OUT  NOCOPY VARCHAR2
,   x_return_status OUT  NOCOPY VARCHAR2
);

PROCEDURE Interface_Header
(   p_header_id     IN   NUMBER
,   p_itemtype      IN   VARCHAR2
,   x_result_out    OUT  NOCOPY VARCHAR2
,   x_return_status OUT  NOCOPY VARCHAR2
);

FUNCTION Invoice_Balance
( p_customer_trx_id IN NUMBER
) RETURN NUMBER;

Procedure Any_Line_ARInterfaced( p_application_id IN NUMBER,
                         p_entity_short_name in VARCHAR2,
                         p_validation_entity_short_name in VARCHAR2,
                         p_validation_tmplt_short_name in VARCHAR2,
                         p_record_set_tmplt_short_name in VARCHAR2,
                         p_scope in VARCHAR2,
                         p_result OUT NOCOPY NUMBER );

Procedure All_Lines_ARInterfaced( p_application_id IN NUMBER,
                         p_entity_short_name in VARCHAR2,
                         p_validation_entity_short_name in VARCHAR2,
                         p_validation_tmplt_short_name in VARCHAR2,
                         p_record_set_tmplt_short_name in VARCHAR2,
                         p_scope in VARCHAR2,
                         p_result OUT NOCOPY NUMBER );

FUNCTION Get_Customer_Transaction_Type
(  p_line_rec IN OE_Order_Pub.Line_Rec_Type
) RETURN NUMBER;

FUNCTION Get_Customer_Transaction_Type
(  p_record IN OE_AK_ORDER_LINES_V%ROWTYPE
) RETURN NUMBER;


Procedure This_Line_ARInterfaced( p_application_id               IN NUMBER,
                                 p_entity_short_name            in VARCHAR2,
                                 p_validation_entity_short_name in VARCHAR2,
                                 p_validation_tmplt_short_name  in VARCHAR2,
                                 p_record_set_tmplt_short_name  in VARCHAR2,
                                 p_scope                        in VARCHAR2,
                                 p_result                       OUT NOCOPY NUMBER );

--retro{Made the procedure public
PROCEDURE Interface_Single_Line
(  p_line_rec    IN    OE_Order_PUB.Line_Rec_Type
,  p_header_rec  IN    OE_Order_PUB.Header_Rec_Type
,  p_x_interface_line_rec   IN OUT NOCOPY  RA_Interface_Lines_Rec_Type
,  x_return_status     OUT NOCOPY VARCHAR2
,  x_result_out        OUT NOCOPY  VARCHAR2
);
--retro}

--Customer Acceptance (Made the function public)
FUNCTION Shipping_info_Available
(  p_line_rec   IN   OE_Order_Pub.Line_Rec_Type
)
RETURN BOOLEAN;

--SG{
G_AR_SALES_GROUP_ENABLED VARCHAR2(1):=NULL;
--SG}

-- Bug # 4454055
-- The function signature is brought to the API specification, as this same function
-- would be reused by other API's too.
-- This is done as a part of Deferred Revenue Project (Bug # 4454055).
--

FUNCTION Line_Invoiceable
(  p_line_rec   IN   OE_Order_Pub.Line_Rec_Type
)
RETURN BOOLEAN ;



-- BUG# 7431368 : Performance fix : Start
G_INVOICE_HEADER_ID NUMBER;
G_INVOICE_LINE_ID   NUMBER;
G_ORDER_TYPE VARCHAR2(30); -- Added for bug 10030712
G_ORDER_NUMBER NUMBER;

Procedure set_header_id ( p_header_id IN NUMBER);
Procedure set_line_id ( p_line_id IN NUMBER);
Procedure set_order_type ( p_order_type IN VARCHAR2 );  -- Added for bug 10030712
Procedure set_order_number ( p_order_number IN NUMBER ); -- Added for bug 10030712

Function  get_header_id return NUMBER;
Function  get_line_id return NUMBER;
Function  get_order_type return VARCHAR2; -- Added for bug 10030712
Function  get_order_number return  VARCHAR2; -- Added for bug 10030712

-- BUG# 7431368 : Performance fix : End



END OE_Invoice_PUB;

/
