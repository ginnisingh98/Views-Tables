--------------------------------------------------------
--  DDL for Package OZF_AR_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_AR_INTERFACE_PVT" AUTHID CURRENT_USER AS
/*$Header: ozfvaris.pls 120.1.12010000.2 2009/06/22 09:22:42 ateotia ship $*/

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

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
,   INTERFACE_LINE_CONTEXT        VARCHAR2(30)    :=NULL
,   BATCH_SOURCE_NAME             VARCHAR2(50)    :=NULL
,   GL_DATE                       DATE            :=NULL -- *
,   SET_OF_BOOKS_ID               NUMBER(15)      :=NULL -- *
,   LINE_TYPE                     VARCHAR2(20)    :=NULL
,   DESCRIPTION                   VARCHAR2(240)   :=NULL
,   CURRENCY_CODE                 VARCHAR2(15)    :=NULL -- *
,   AMOUNT                        NUMBER          :=NULL
,   CONVERSION_TYPE               VARCHAR2(30)    :=NULL -- *
,   CONVERSION_DATE               DATE            :=NULL -- *
,   CONVERSION_RATE               NUMBER          :=NULL -- *
,   CUST_TRX_TYPE_ID              NUMBER(15)      :=NULL -- *
,   TERM_ID                       NUMBER(15)      :=NULL -- *
,   ORIG_SYSTEM_BILL_CUSTOMER_ID  NUMBER(15)      :=NULL -- *
--Bug# 8619806 fixed by ateotia(+)
--, ORIG_SYSTEM_BILL_ADDRESS_ID   NUMBER(15)      :=NULL -- *
,   ORIG_SYSTEM_BILL_ADDRESS_ID   NUMBER          :=NULL
--Bug# 8619806 fixed by ateotia(-)
,   ORIG_SYSTEM_BILL_CONTACT_ID   NUMBER(15)      :=NULL -- *
,   ORIG_SYSTEM_SHIP_CUSTOMER_ID  NUMBER(15)      :=NULL -- *
--Bug# 8619806 fixed by ateotia(+)
--, ORIG_SYSTEM_SHIP_ADDRESS_ID   NUMBER(15)      :=NULL -- *
,   ORIG_SYSTEM_SHIP_ADDRESS_ID   NUMBER          :=NULL
--Bug# 8619806 fixed by ateotia(-)
,   ORIG_SYSTEM_SHIP_CONTACT_ID   NUMBER(15)      :=NULL -- *
,   ORIG_SYSTEM_SOLD_CUSTOMER_ID  NUMBER(15)      :=NULL -- *
,   ORG_ID                        NUMBER(15)      :=NULL
/*  Attributes required by grouping rule and are not selected above */
,   AGREEMENT_ID                  NUMBER(15)      :=NULL
,   COMMENTS                      VARCHAR2(240)   :=NULL
,   CREDIT_METHOD_FOR_ACCT_RULE   VARCHAR2(30)    :=NULL
,   CREDIT_METHOD_FOR_INSTALLMENTS  VARCHAR2(30)  :=NULL
,   CUSTOMER_BANK_ACCOUNT_ID      NUMBER(15)      :=NULL
,   DOCUMENT_NUMBER               NUMBER(15)      :=NULL
,   DOCUMENT_NUMBER_SEQUENCE_ID   NUMBER(15)      :=NULL
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
,   INITIAL_CUSTOMER_TRX_ID       NUMBER(15)      :=NULL
,   INTERNAL_NOTES                VARCHAR2(240)   :=NULL
,   INVOICING_RULE_ID             NUMBER(15)      :=NULL
,   ORIG_SYSTEM_BATCH_NAME        VARCHAR2(40)    :=NULL
,   PREVIOUS_CUSTOMER_TRX_ID      NUMBER(15)      :=NULL
,   PRIMARY_SALESREP_ID           NUMBER(15)      :=NULL
,   PRINTING_OPTION               VARCHAR2(20)    :=NULL
,   PURCHASE_ORDER                VARCHAR2(50)    :=NULL
,   PURCHASE_ORDER_REVISION       VARCHAR2(50)    :=NULL
,   PURCHASE_ORDER_DATE           DATE            :=NULL
,   REASON_CODE                   VARCHAR2(30)    :=NULL
,   RECEIPT_METHOD_ID             NUMBER(15)      :=NULL
,   RELATED_CUSTOMER_TRX_ID       NUMBER(15)      :=NULL
,   TERRITORY_ID                  NUMBER(15)      :=NULL
,   TRX_DATE                      DATE            :=NULL
,   TRX_NUMBER                    VARCHAR2(20)    :=NULL
,   MEMO_LINE_ID                  NUMBER(15)      :=NULL
/*  18-FEb-2002 MCHANG: Attributes required by passing tax lines */
,   TAX_CODE                      VARCHAR2(50)    :=NULL
,   TAX_RATE                      NUMBER          :=NULL
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
,   INVENTORY_ITEM_ID             NUMBER          :=NULL
,   QUANTITY                      NUMBER          :=NULL
,   UOM_CODE                      VARCHAR2(3)     :=NULL
,   UNIT_SELLING_PRICE            NUMBER          :=NULL
,   LEGAL_ENTITY_ID               NUMBER(15)      :=NULL
);

TYPE RA_Interface_Lines_Tbl_Type IS TABLE OF RA_Interface_Lines_Rec_Type
    INDEX BY BINARY_INTEGER;


TYPE RA_Int_Distributions_Rec_Type IS RECORD
(
  INTERFACE_DISTRIBUTION_ID  NUMBER(15),
  INTERFACE_LINE_ID          NUMBER(15),
  INTERFACE_LINE_CONTEXT     VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE1  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE2  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE3  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE4  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE5  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE6  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE7  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE8  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE9  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE10  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE11  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE12  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE13  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE14  VARCHAR2(30),
  INTERFACE_LINE_ATTRIBUTE15  VARCHAR2(30),
  ACCOUNT_CLASS              VARCHAR2(20),
  AMOUNT                     NUMBER,
  ACCTD_AMOUNT               NUMBER,
  PERCENT                    NUMBER,
  INTERFACE_STATUS           VARCHAR2(1),
  REQUEST_ID                 NUMBER(15),
  CODE_COMBINATION_ID        NUMBER(15),
  SEGMENT1                   VARCHAR2(25),
  SEGMENT2                   VARCHAR2(25),
  SEGMENT3                   VARCHAR2(25),
  SEGMENT4                   VARCHAR2(25),
  SEGMENT5                   VARCHAR2(25),
  SEGMENT6                   VARCHAR2(25),
  SEGMENT7                   VARCHAR2(25),
  SEGMENT8                   VARCHAR2(25),
  SEGMENT9                   VARCHAR2(25),
  SEGMENT10                  VARCHAR2(25),
  SEGMENT11                  VARCHAR2(25),
  SEGMENT12                  VARCHAR2(25),
  SEGMENT13                  VARCHAR2(25),
  SEGMENT14                  VARCHAR2(25),
  SEGMENT15                  VARCHAR2(25),
  SEGMENT16                  VARCHAR2(25),
  SEGMENT17                  VARCHAR2(25),
  SEGMENT18                  VARCHAR2(25),
  SEGMENT19                  VARCHAR2(25),
  SEGMENT20                  VARCHAR2(25),
  SEGMENT21                  VARCHAR2(25),
  SEGMENT22                  VARCHAR2(25),
  SEGMENT23                  VARCHAR2(25),
  SEGMENT24                  VARCHAR2(25),
  SEGMENT25                  VARCHAR2(25),
  SEGMENT26                  VARCHAR2(25),
  SEGMENT27                  VARCHAR2(25),
  SEGMENT28                  VARCHAR2(25),
  SEGMENT29                  VARCHAR2(25),
  SEGMENT30                  VARCHAR2(25),
  COMMENTS                   VARCHAR2(240),
  ATTRIBUTE_CATEGORY         VARCHAR2(30),
  ATTRIBUTE1                 VARCHAR2(150),
  ATTRIBUTE2                 VARCHAR2(150),
  ATTRIBUTE3                 VARCHAR2(150),
  ATTRIBUTE4                 VARCHAR2(150),
  ATTRIBUTE5                 VARCHAR2(150),
  ATTRIBUTE6                 VARCHAR2(150),
  ATTRIBUTE7                 VARCHAR2(150),
  ATTRIBUTE8                 VARCHAR2(150),
  ATTRIBUTE9                 VARCHAR2(150),
  ATTRIBUTE10                VARCHAR2(150),
  ATTRIBUTE11                VARCHAR2(150),
  ATTRIBUTE12                VARCHAR2(150),
  ATTRIBUTE13                VARCHAR2(150),
  ATTRIBUTE14                VARCHAR2(150),
  ATTRIBUTE15                VARCHAR2(150),
  CREATED_BY                 NUMBER(15),
  CREATION_DATE              DATE,
  LAST_UPDATED_BY            NUMBER(15),
  LAST_UPDATE_DATE           DATE,
  LAST_UPDATE_LOGIN          NUMBER(15),
  ORG_ID                     NUMBER(15),
  INTERIM_TAX_CCID           NUMBER(15),
  INTERIM_TAX_SEGMENT1       VARCHAR2(25),
  INTERIM_TAX_SEGMENT2       VARCHAR2(25),
  INTERIM_TAX_SEGMENT3       VARCHAR2(25),
  INTERIM_TAX_SEGMENT4       VARCHAR2(25),
  INTERIM_TAX_SEGMENT5       VARCHAR2(25),
  INTERIM_TAX_SEGMENT6       VARCHAR2(25),
  INTERIM_TAX_SEGMENT7       VARCHAR2(25),
  INTERIM_TAX_SEGMENT8       VARCHAR2(25),
  INTERIM_TAX_SEGMENT9       VARCHAR2(25),
  INTERIM_TAX_SEGMENT10      VARCHAR2(25),
  INTERIM_TAX_SEGMENT11      VARCHAR2(25),
  INTERIM_TAX_SEGMENT12      VARCHAR2(25),
  INTERIM_TAX_SEGMENT13      VARCHAR2(25),
  INTERIM_TAX_SEGMENT14      VARCHAR2(25),
  INTERIM_TAX_SEGMENT15      VARCHAR2(25),
  INTERIM_TAX_SEGMENT16      VARCHAR2(25),
  INTERIM_TAX_SEGMENT17      VARCHAR2(25),
  INTERIM_TAX_SEGMENT18      VARCHAR2(25),
  INTERIM_TAX_SEGMENT19      VARCHAR2(25),
  INTERIM_TAX_SEGMENT20      VARCHAR2(25),
  INTERIM_TAX_SEGMENT21      VARCHAR2(25),
  INTERIM_TAX_SEGMENT22      VARCHAR2(25),
  INTERIM_TAX_SEGMENT23      VARCHAR2(25),
  INTERIM_TAX_SEGMENT24      VARCHAR2(25),
  INTERIM_TAX_SEGMENT25      VARCHAR2(25),
  INTERIM_TAX_SEGMENT26      VARCHAR2(25),
  INTERIM_TAX_SEGMENT27      VARCHAR2(25),
  INTERIM_TAX_SEGMENT28      VARCHAR2(25),
  INTERIM_TAX_SEGMENT29      VARCHAR2(25),
  INTERIM_TAX_SEGMENT30      VARCHAR2(25)
);

TYPE RA_Int_Distributions_Tbl_Type IS TABLE OF RA_Int_Distributions_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE RA_Int_Sales_Credits_Rec_Type IS RECORD(
  INTERFACE_LINE_CONTEXT      VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE1   VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE2   VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE3   VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE4   VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE5   VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE6   VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE7   VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE8   VARCHAR2 (30),
  SALESREP_NUMBER             VARCHAR2 (30),
  SALESREP_ID                 NUMBER (15),
  SALES_CREDIT_TYPE_NAME      VARCHAR2 (30),
  SALES_CREDIT_TYPE_ID        NUMBER (15),
  SALES_CREDIT_AMOUNT_SPLIT   NUMBER,
  SALES_CREDIT_PERCENT_SPLIT  NUMBER,
  INTERFACE_STATUS            VARCHAR2 (1),
  REQUEST_ID                  NUMBER (15),
  ATTRIBUTE_CATEGORY          VARCHAR2 (30),
  ATTRIBUTE1                  VARCHAR2 (150),
  ATTRIBUTE2                  VARCHAR2 (150),
  ATTRIBUTE3                  VARCHAR2 (150),
  ATTRIBUTE4                  VARCHAR2 (150),
  ATTRIBUTE5                  VARCHAR2 (150),
  ATTRIBUTE6                  VARCHAR2 (150),
  ATTRIBUTE7                  VARCHAR2 (150),
  ATTRIBUTE8                  VARCHAR2 (150),
  ATTRIBUTE9                  VARCHAR2 (150),
  ATTRIBUTE10                 VARCHAR2 (150),
  ATTRIBUTE11                 VARCHAR2 (150),
  ATTRIBUTE12                 VARCHAR2 (150),
  ATTRIBUTE13                 VARCHAR2 (150),
  ATTRIBUTE14                 VARCHAR2 (150),
  ATTRIBUTE15                 VARCHAR2 (150),
  INTERFACE_LINE_ATTRIBUTE10  VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE11  VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE12  VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE13  VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE14  VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE15  VARCHAR2 (30),
  INTERFACE_LINE_ATTRIBUTE9   VARCHAR2 (30),
  CREATED_BY                  NUMBER (15),
  CREATION_DATE               DATE,
  LAST_UPDATED_BY             NUMBER (15),
  LAST_UPDATE_DATE            DATE,
  LAST_UPDATE_LOGIN           NUMBER (15),
  ORG_ID                      NUMBER (15)
);

TYPE RA_Int_Sales_Credits_Rec_Tbl IS TABLE OF RA_Int_Sales_Credits_Rec_Type
    INDEX BY BINARY_INTEGER;

TYPE Claim_Rec_Type IS RECORD
(
  CLAIM_ID                                 NUMBER             :=NULL
, OBJECT_VERSION_NUMBER                    NUMBER(9)          :=NULL
, LAST_UPDATE_DATE                         DATE               :=NULL
, LAST_UPDATED_BY                          NUMBER(15)         :=NULL
, CREATION_DATE                            DATE               :=NULL
, CREATED_BY                               NUMBER(15)         :=NULL
, LAST_UPDATE_LOGIN                        NUMBER(15)         :=NULL
, REQUEST_ID                               NUMBER             :=NULL
, PROGRAM_APPLICATION_ID                   NUMBER             :=NULL
, PROGRAM_UPDATE_DATE                      DATE               :=NULL
, PROGRAM_ID                               NUMBER             :=NULL
, CREATED_FROM                             VARCHAR2(30)       :=NULL
, BATCH_ID                                 NUMBER             :=NULL
, CLAIM_NUMBER                             VARCHAR2(30)       :=NULL
, CLAIM_TYPE_ID                            NUMBER             :=NULL
, CLAIM_CLASS                              VARCHAR2(30)       :=NULL
, CLAIM_DATE                               DATE               :=NULL
, DUE_DATE                                 DATE               :=NULL
, OWNER_ID                                 NUMBER             :=NULL
, HISTORY_EVENT                            VARCHAR2(30)       :=NULL
, HISTORY_EVENT_DATE                       DATE               :=NULL
, HISTORY_EVENT_DESCRIPTION                VARCHAR2(2000)     :=NULL
, SPLIT_FROM_CLAIM_ID                      NUMBER             :=NULL
, DUPLICATE_CLAIM_ID                       NUMBER             :=NULL
, SPLIT_DATE                               DATE               :=NULL
, ROOT_CLAIM_ID                            NUMBER             :=NULL
, AMOUNT                                   NUMBER             :=NULL
, AMOUNT_ADJUSTED                          NUMBER             :=NULL
, AMOUNT_REMAINING                         NUMBER             :=NULL
, AMOUNT_SETTLED                           NUMBER             :=NULL
, ACCTD_AMOUNT                             NUMBER             :=NULL
, ACCTD_AMOUNT_REMAINING                   NUMBER             :=NULL
, TAX_AMOUNT                               NUMBER             :=NULL
, TAX_CODE                                 VARCHAR2(50)       :=NULL
, TAX_CALCULATION_FLAG                     VARCHAR2(1)        :=NULL
, CURRENCY_CODE                            VARCHAR2(15)       :=NULL
, EXCHANGE_RATE_TYPE                       VARCHAR2(30)       :=NULL
, EXCHANGE_RATE_DATE                       DATE               :=NULL
, EXCHANGE_RATE                            NUMBER             :=NULL
, SET_OF_BOOKS_ID                          NUMBER             :=NULL
, ORIGINAL_CLAIM_DATE                      DATE               :=NULL
, SOURCE_OBJECT_ID                         NUMBER             :=NULL
, SOURCE_OBJECT_CLASS                      VARCHAR2(15)       :=NULL
, SOURCE_OBJECT_TYPE_ID                    NUMBER             :=NULL
, SOURCE_OBJECT_NUMBER                     VARCHAR2(30)       :=NULL
, CUST_ACCOUNT_ID                          NUMBER             :=NULL
, CUST_BILLTO_ACCT_SITE_ID                 NUMBER             :=NULL
, CUST_SHIPTO_ACCT_SITE_ID                 VARCHAR2(240)      :=NULL
, LOCATION_ID                              NUMBER             :=NULL
, PAY_RELATED_ACCOUNT_FLAG                 VARCHAR2(1)        :=NULL
, RELATED_CUST_ACCOUNT_ID                  NUMBER             :=NULL
, RELATED_SITE_USE_ID                      NUMBER             :=NULL
, RELATIONSHIP_TYPE                        VARCHAR2(30)       :=NULL
, VENDOR_ID                                NUMBER             :=NULL
, VENDOR_SITE_ID                           NUMBER             :=NULL
, REASON_TYPE                              VARCHAR2(30)       :=NULL
, REASON_CODE_ID                           NUMBER             :=NULL
, TASK_TEMPLATE_GROUP_ID                   NUMBER             :=NULL
, STATUS_CODE                              VARCHAR2(30)       :=NULL
, USER_STATUS_ID                           NUMBER             :=NULL
, SALES_REP_ID                             NUMBER             :=NULL
, COLLECTOR_ID                             NUMBER             :=NULL
, CONTACT_ID                               NUMBER             :=NULL
, BROKER_ID                                NUMBER             :=NULL
, TERRITORY_ID                             NUMBER             :=NULL
, CUSTOMER_REF_DATE                        DATE               :=NULL
, CUSTOMER_REF_NUMBER                      VARCHAR2(30)       :=NULL
, ASSIGNED_TO                              NUMBER             :=NULL
, RECEIPT_ID                               NUMBER             :=NULL
, RECEIPT_NUMBER                           VARCHAR2(30)       :=NULL
, DOC_SEQUENCE_ID                          NUMBER             :=NULL
, DOC_SEQUENCE_VALUE                       NUMBER             :=NULL
, GL_DATE                                  DATE               :=NULL
, PAYMENT_METHOD                           VARCHAR2(15)       :=NULL
, VOUCHER_ID                               NUMBER             :=NULL
, VOUCHER_NUMBER                           VARCHAR2(30)       :=NULL
, PAYMENT_REFERENCE_ID                     NUMBER             :=NULL
, PAYMENT_REFERENCE_NUMBER                 VARCHAR2(15)       :=NULL
, PAYMENT_REFERENCE_DATE                   DATE               :=NULL
, PAYMENT_STATUS                           VARCHAR2(10)       :=NULL
, APPROVED_FLAG                            VARCHAR2(1)        :=NULL
, APPROVED_DATE                            DATE               :=NULL
, APPROVED_BY                              NUMBER             :=NULL
, SETTLED_DATE                             DATE               :=NULL
, SETTLED_BY                               NUMBER             :=NULL
, EFFECTIVE_DATE                           DATE               :=NULL
, CUSTOM_SETUP_ID                          NUMBER             :=NULL
, TASK_ID                                  NUMBER             :=NULL
, COUNTRY_ID                               NUMBER             :=NULL
, COMMENTS                                 VARCHAR2(2000)     :=NULL
, ATTRIBUTE_CATEGORY                       VARCHAR2(30)       :=NULL
, ATTRIBUTE1                               VARCHAR2(150)      :=NULL
, ATTRIBUTE2                               VARCHAR2(150)      :=NULL
, ATTRIBUTE3                               VARCHAR2(150)      :=NULL
, ATTRIBUTE4                               VARCHAR2(150)      :=NULL
, ATTRIBUTE5                               VARCHAR2(150)      :=NULL
, ATTRIBUTE6                               VARCHAR2(150)      :=NULL
, ATTRIBUTE7                               VARCHAR2(150)      :=NULL
, ATTRIBUTE8                               VARCHAR2(150)      :=NULL
, ATTRIBUTE9                               VARCHAR2(150)      :=NULL
, ATTRIBUTE10                              VARCHAR2(150)      :=NULL
, ATTRIBUTE11                              VARCHAR2(150)      :=NULL
, ATTRIBUTE12                              VARCHAR2(150)      :=NULL
, ATTRIBUTE13                              VARCHAR2(150)      :=NULL
, ATTRIBUTE14                              VARCHAR2(150)      :=NULL
, ATTRIBUTE15                              VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE_CATEGORY             VARCHAR2(30)       :=NULL
, DEDUCTION_ATTRIBUTE1                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE2                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE3                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE4                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE5                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE6                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE7                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE8                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE9                     VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE10                    VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE11                    VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE12                    VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE13                    VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE14                    VARCHAR2(150)      :=NULL
, DEDUCTION_ATTRIBUTE15                    VARCHAR2(150)      :=NULL
, ORG_ID                                   NUMBER             :=NULL
, CUSTOMER_REASON                          VARCHAR2(30)       :=NULL
, SHIP_TO_CUST_ACCOUNT_ID                  NUMBER             :=NULL
, LEGAL_ENTITY_ID                          NUMBER             :=NULL
);

TYPE Claim_Tbl_Type IS TABLE OF Claim_Rec_Type
     INDEX BY BINARY_INTEGER;

PROCEDURE Interface_Claim
(   p_api_version      IN NUMBER
   ,p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE
   ,p_commit           IN VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level IN VARCHAR2 := FND_API.G_VALID_LEVEL_FULL
   ,p_claim_id         IN NUMBER
   ,x_return_status    OUT NOCOPY VARCHAR2
   ,x_msg_data         OUT NOCOPY VARCHAR2
   ,x_msg_count        OUT NOCOPY NUMBER
);

PROCEDURE Query_Claim
(
   p_claim_id      IN NUMBER
  ,x_claim_rec     IN OUT NOCOPY Claim_Rec_Type
  ,x_return_status OUT NOCOPY VARCHAR2
);

FUNCTION Get_Memo_Line_Id(p_claim_line_id IN NUMBER) RETURN NUMBER ;

END OZF_Ar_Interface_PVT;

/
