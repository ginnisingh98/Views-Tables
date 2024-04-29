--------------------------------------------------------
--  DDL for Package ZX_TAX_PARTNER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_PARTNER_PKG" AUTHID CURRENT_USER AS
/* $Header: zxiftaxptnrpubs.pls 120.19.12010000.3 2008/11/17 20:26:41 tsen ship $ */
/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'ZX_TAX_PARTNER_PKG';
G_CURRENT_RUNTIME_LEVEL  CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
LEVEL_UNEXPECTED         CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
LEVEL_ERROR              CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
LEVEL_EXCEPTION          CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
LEVEL_EVENT              CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
LEVEL_PROCEDURE          CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
LEVEL_STATEMENT          CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME            CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_TAX_PARTNER_PKG.';

/* ======================================================================*
 | Global Structure Data Types                                           |
 * ======================================================================*/

TYPE NUMBER_tbl_type            IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_1_tbl_type        IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_2_tbl_type        IS TABLE OF VARCHAR2(2)    INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_15_tbl_type       IS TABLE OF VARCHAR2(15)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_tbl_type       IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_80_tbl_type       IS TABLE OF VARCHAR2(80)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_50_tbl_type       IS TABLE OF VARCHAR2(50)   INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_150_tbl_type      IS TABLE OF VARCHAR2(150)  INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_240_tbl_type      IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
TYPE DATE_tbl_type              IS TABLE OF DATE           INDEX BY BINARY_INTEGER;


 TYPE tax_currencies_rec_type IS RECORD (
 TAX                             VARCHAR2(30),
 TAX_CURRENCY_CODE               VARCHAR2(15),   -- Bug 5090593
 TRX_LINE_CURRENCY_CODE          VARCHAR2(15),   -- Bug 5090593
 EXCHANGE_RATE                   NUMBER,
 TAX_CURRENCY_PRECISION          NUMBER          -- Bug 5288518
);

 TYPE tax_currencies_tbl_type IS TABLE OF tax_currencies_rec_type
 INDEX BY BINARY_INTEGER;

 TYPE exemption_rec_type IS RECORD (
 CONTENT_OWNER_ID            NUMBER,
 COUNTRY_CODE                VARCHAR2(30),
 LAST_IMPORT_DATETIME        DATE
 );

 TYPE exemptions_tbl_type IS RECORD (
 CONTENT_OWNER_ID             Number_tbl_type,
 EXEMPTION_CLASS_CODE         VARCHAR2_30_TBL_TYPE,
 COUNTRY_CODE                 VARCHAR2_30_TBL_TYPE,
 TAX                          VARCHAR2_30_TBL_TYPE,
 EXEMPT_CERTIFICATE_NUMBER    VARCHAR2_80_TBL_TYPE,
 EXEMPT_REASON_CODE           VARCHAR2_240_TBL_TYPE,
 EFFECTIVE_FROM               DATE_TBL_TYPE,
 EFFECTIVE_TO                 DATE_TBL_TYPE,
 EXEMPT_RATE_MODIFIER         NUMBER_TBL_TYPE,
 PARTY_NUMBER                 VARCHAR2_30_tbl_type,
 PARTY_FISCAL_CLASSIFICATION  VARCHAR2_30_tbl_type,
 PARTY_TAX_PROFILE_ID         Number_tbl_type,
 GEOGRAPHY_ID                 Number_tbl_type,
 STATE                        VARCHAR2_30_TBL_TYPE,
 COUNTY                       VARCHAR2_30_TBL_TYPE,
 CITY                         VARCHAR2_30_TBL_TYPE
 );

 TYPE exmpt_messages_tbl_type IS RECORD (
 INTERNAL_ORGANIZATION_ID     NUMBER_TBL_TYPE,
 EXEMPTION_CLASS_CODE         VARCHAR2_30_TBL_TYPE,
 COUNTRY_CODE                 VARCHAR2_30_TBL_TYPE,
 TAX                          VARCHAR2_30_TBL_TYPE,
 ERROR_MESSAGE_TYPE           VARCHAR2_30_TBL_TYPE,
 ERROR_MESSAGE_STRING         VARCHAR2_240_TBL_TYPE
 );


 TYPE tax_lines_tbl_type IS RECORD (
 TAX_LINE_ID                   NUMBER_tbl_type,
 BUSINESS_GROUP_ID             NUMBER_tbl_type,
 INTERNAL_ORGANIZATION_ID      NUMBER_tbl_type,
 DOCUMENT_TYPE_ID              NUMBER_tbl_type,
 APPLICATION_ID                NUMBER_tbl_type,
 ENTITY_CODE                   VARCHAR2_30_tbl_type,
 EVENT_CLASS_CODE              VARCHAR2_30_tbl_type,
 EVENT_TYPE_CODE               VARCHAR2_30_tbl_type,
 TRANSACTION_ID                NUMBER_tbl_type,
 TRANSACTION_LINE_ID           NUMBER_tbl_type,
 TRX_LEVEL_TYPE                VARCHAR2_30_tbl_type,
 TAX_LINE_NUMBER               NUMBER_tbl_type,
 COUNTRY_CODE                  VARCHAR2_30_tbl_type,
 TAX                           VARCHAR2_30_tbl_type,
 TAX_STATUS_CODE               VARCHAR2_30_tbl_type,
 TAX_RATE_CODE                 VARCHAR2_50_tbl_type,
 RATE_TYPE_CODE                VARCHAR2_30_tbl_type,
 TAX_APPORTIONMENT_LINE_NUMBER NUMBER_tbl_type,
 SITUS                         VARCHAR2_30_tbl_type,
 TAX_JURISDICTION              VARCHAR2_30_tbl_type,
 TAX_CURRENCY_CODE             VARCHAR2_15_tbl_type,
 TAX_AMOUNT                    NUMBER_tbl_type,
 UNROUNDED_TAX_AMOUNT          NUMBER_tbl_type,
 TAX_CURR_TAX_AMOUNT           NUMBER_tbl_type,
 TAX_RATE_PERCENTAGE           NUMBER_tbl_type,
 TAXABLE_AMOUNT                NUMBER_tbl_type,
 EXEMPT_AMT                    NUMBER_tbl_type,
 EXEMPT_CERTIFICATE_NUMBER     VARCHAR2_80_TBL_TYPE,
 EXEMPT_RATE_MODIFIER          NUMBER_tbl_type,
 EXEMPT_REASON                 VARCHAR2_240_tbl_type,
 SYNC_WITH_PRVDR_FLAG          VARCHAR2_1_tbl_type,
 TAX_ONLY_LINE_FLAG            VARCHAR2_1_tbl_type,
 INCLUSIVE_TAX_LINE_FLAG       VARCHAR2_1_tbl_type,
 LINE_AMT_INCLUDES_TAX_FLAG    VARCHAR2_1_tbl_type,
 USE_TAX_FLAG                  VARCHAR2_1_tbl_type,
 USER_OVERRIDE_FLAG            VARCHAR2_1_tbl_type,
 LAST_MANUAL_ENTRY             VARCHAR2_30_tbl_type,
 MANUALLY_ENTERED_FLAG         VARCHAR2_1_tbl_type,
 REGISTRATION_PARTY_TYPE       VARCHAR2_30_tbl_type,  -- Bug 5288518
 PARTY_TAX_REG_NUMBER          VARCHAR2_30_tbl_type,  -- Bug 5288518
 THIRD_PARTY_TAX_REG_NUMBER    VARCHAR2_30_tbl_type,
 TAX_PROVIDER_ID               NUMBER_tbl_type,
 CANCEL_FLAG                   VARCHAR2_1_tbl_type,
 DELETE_FLAG                   VARCHAR2_1_tbl_type,
 THRESHOLD_INDICATOR_FLAG      VARCHAR2_1_tbl_type,
 TAX_PRECISION                 NUMBER_tbl_type,
 MINIMUM_ACCOUNTABLE_UNIT      NUMBER_tbl_type,
 ROUNDING_RULE_CODE            VARCHAR2_30_tbl_type,
 STATE                         VARCHAR2_2_tbl_type,
 COUNTY                        VARCHAR2_30_tbl_type,
 CITY                          VARCHAR2_30_tbl_type,
 TRX_LINE_NUMBER               NUMBER_tbl_type,
 TRX_NUMBER                    VARCHAR2_150_tbl_type,
 LINE_AMT                      NUMBER_tbl_type,
 TRX_DATE                      DATE_tbl_type,
 UNIT_PRICE                    NUMBER_tbl_type,
 TRX_LINE_QUANTITY             NUMBER_tbl_type,
 DOC_EVENT_STATUS              VARCHAR2_30_tbl_type,
 TAX_EVENT_CLASS_CODE          VARCHAR2_30_tbl_type,
 TAX_EVENT_TYPE_CODE           VARCHAR2_30_tbl_type,
 TAX_REGIME_ID                 NUMBER_tbl_type,
 TAX_ID                        NUMBER_tbl_type,
 TAX_STATUS_ID                 NUMBER_tbl_type,
 TAX_RATE_ID                   NUMBER_tbl_type,
 LEDGER_ID                     NUMBER_tbl_type,
 LEGAL_ENTITY_ID               NUMBER_tbl_type,
 TAX_CURRENCY_CONVERSION_DATE  DATE_tbl_type,
 TAX_CURRENCY_CONVERSION_TYPE  VARCHAR2_30_tbl_type,
 TAX_CURRENCY_CONVERSION_RATE  NUMBER_tbl_type,
 TRX_CURRENCY_CODE             VARCHAR2_30_tbl_type,
 OFFSET_FLAG                   VARCHAR2_1_tbl_type,
 PROCESS_FOR_RECOVERY_FLAG     VARCHAR2_1_tbl_type,
 TAX_JURISDICTION_ID           NUMBER_tbl_type,
 TAX_DATE                      DATE_tbl_type,
 TAX_DETERMINE_DATE            DATE_tbl_type,
 TRX_LINE_DATE                 DATE_tbl_type,
 TAX_TYPE_CODE                 VARCHAR2_30_tbl_type,
 COMPOUNDING_TAX_FLAG          VARCHAR2_1_tbl_type,
 TAXABLE_AMT_TAX_CURR          NUMBER_tbl_type,
 TAX_APPORTIONMENT_FLAG        VARCHAR2_1_tbl_type,
 HISTORICAL_FLAG               VARCHAR2_1_tbl_type,
 PURGE_FLAG                    VARCHAR2_1_tbl_type,
 REPORTING_ONLY_FLAG           VARCHAR2_1_tbl_type,
 FREEZE_UNTIL_OVERRIDDEN_FLAG  VARCHAR2_1_tbl_type,
 COPIED_FROM_OTHER_DOC_FLAG    VARCHAR2_1_tbl_type,
 MRC_TAX_LINE_FLAG             VARCHAR2_1_tbl_type,
 APPLIED_FROM_APPLICATION_ID   NUMBER_tbl_type,        -- Bug 5468010
 APPLIED_FROM_ENTITY_CODE      VARCHAR2_30_tbl_type,   -- Bug 5468010
 APPLIED_FROM_EVENT_CLASS_CODE VARCHAR2_30_tbl_type,   -- Bug 5468010
 APPLIED_FROM_TRX_ID           NUMBER_tbl_type,        -- Bug 5468010
 APPLIED_FROM_LINE_ID          NUMBER_tbl_type,        -- Bug 5468010
 APPLIED_FROM_TRX_LEVEL_TYPE   VARCHAR2_30_tbl_type,   -- Bug 5468010
 APPLIED_FROM_TRX_NUMBER       VARCHAR2_150_tbl_type,  -- Bug 5468010
 ADJUSTED_DOC_APPLICATION_ID   NUMBER_tbl_type,        -- Bug 5468010
 ADJUSTED_DOC_ENTITY_CODE      VARCHAR2_30_tbl_type,   -- Bug 5468010
 ADJUSTED_DOC_EVENT_CLASS_CODE VARCHAR2_30_tbl_type,   -- Bug 5468010
 ADJUSTED_DOC_TRX_ID           NUMBER_tbl_type,        -- Bug 5468010
 ADJUSTED_DOC_LINE_ID          NUMBER_tbl_type,        -- Bug 5468010
 ADJUSTED_DOC_TRX_LEVEL_TYPE   VARCHAR2_30_tbl_type,   -- Bug 5468010
 ADJUSTED_DOC_NUMBER           VARCHAR2_150_tbl_type,  -- Bug 5468010
 ADJUSTED_DOC_DATE             DATE_tbl_type,          -- Bug 5468010
 ADJUSTED_DOC_TAX_LINE_ID      NUMBER_tbl_type,
 GLOBAL_ATTRIBUTE2             VARCHAR2_150_tbl_type,  -- Bug 6831713
 GLOBAL_ATTRIBUTE4             VARCHAR2_150_tbl_type,  -- Bug 6831713
 GLOBAL_ATTRIBUTE6             VARCHAR2_150_tbl_type,  -- Bug 6831713
 GLOBAL_ATTRIBUTE_CATEGORY     VARCHAR2_150_tbl_type,  -- Bug 6831713
 TAX_EXEMPTION_ID              NUMBER_tbl_type,
 EXEMPT_REASON_CODE            VARCHAR2_30_tbl_type
);

 TYPE sync_tax_lines_rec_type IS RECORD (
 INTERNAL_ORGANIZATION_ID      NUMBER,
 LEGAL_ENTITY_NUMBER	       VARCHAR2(30),
 ESTABLISHMENT_NUMBER          VARCHAR2(30),    -- Bug 5139731
 DOCUMENT_TYPE_ID              NUMBER,
 APPLICATION_ID                NUMBER,
 ENTITY_CODE                   VARCHAR2(30),
 EVENT_CLASS_CODE              VARCHAR2(30),
 TRANSACTION_ID                NUMBER,
 TRANSACTION_LINE_ID           NUMBER,
 TRX_LEVEL_TYPE                VARCHAR2(30),
 COUNTRY_CODE                  VARCHAR2(30),
 TAX                           VARCHAR2(30),
 TAX_APPORTIONMENT_LINE_NUMBER NUMBER,
 SITUS                         VARCHAR2(30),
 TAX_RATE_PERCENTAGE           NUMBER,
 TAXABLE_AMOUNT                NUMBER
 );
 TYPE output_sync_tax_lines_tbl_type IS TABLE OF sync_tax_lines_rec_type
 INDEX BY BINARY_INTEGER;

 TYPE trx_rec_type IS RECORD (
 DOCUMENT_TYPE_ID              NUMBER,
 TRANSACTION_ID                NUMBER,
 DOCUMENT_LEVEL_ACTION         VARCHAR2(30)
 );

 TYPE trx_tbl_type IS TABLE OF trx_rec_type
 INDEX BY BINARY_INTEGER;          -- Bug 5664259

 TYPE messages_rec_type IS RECORD (
 DOCUMENT_TYPE_ID              NUMBER,
 TRANSACTION_ID                NUMBER,
 TRANSACTION_LINE_ID           NUMBER,
 TRX_LEVEL_TYPE                VARCHAR2(30),
 COUNTRY_CODE                  VARCHAR2(30),
 TAX                           VARCHAR2(30),
 SITUS                         VARCHAR2(30),
 ERROR_MESSAGE_TYPE            VARCHAR2(30),
 ERROR_MESSAGE_STRING          VARCHAR2(240)
 );

 TYPE messages_tbl_type IS RECORD (
 DOCUMENT_TYPE_ID             Number_tbl_type,
 TRANSACTION_ID               Number_tbl_type,
 TRANSACTION_LINE_ID          Number_tbl_type,
 EXEMPTION_CLASS_CODE         VARCHAR2_30_TBL_TYPE,
 TRX_LEVEL_TYPE               VARCHAR2_30_TBL_TYPE,
 COUNTRY_CODE                 VARCHAR2_30_TBL_TYPE,
 TAX                          VARCHAR2_30_TBL_TYPE,
 SITUS                        VARCHAR2_30_TBL_TYPE,
 ERROR_MESSAGE_TYPE           VARCHAR2_30_TBL_TYPE,
 ERROR_MESSAGE_STRING         VARCHAR2_240_TBL_TYPE
 );

 G_BUSINESS_FLOW               VARCHAR2(30);
 G_TAX_REGIME_CODE             VARCHAR2(30);
 G_EVENT_CLASS_REC             ZX_API_PUB.event_class_rec_type;
END  ZX_TAX_PARTNER_PKG;


/
