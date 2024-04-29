--------------------------------------------------------
--  DDL for Package Body ZX_NEW_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_NEW_SERVICES_PKG" AS
/* $Header: zxifnewsrvcspubb.pls 120.0.12010000.8 2010/08/27 06:17:49 prigovin ship $ */

/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'ZX_NEW_SERVICES_PKG';
G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_NEW_APIS_PUB.';

TYPE VARCHAR2_tbl_type is TABLE OF VARCHAR2(1)
INDEX BY BINARY_INTEGER;

TYPE VARCHAR2_30_tbl_type is TABLE OF VARCHAR2(30)
INDEX BY BINARY_INTEGER;

TYPE NUMBER_15_tbl_type is TABLE OF NUMBER(15)
INDEX BY BINARY_INTEGER;

TYPE NUMBER_tbl_type is TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

TYPE evnt_cls_rec_type is RECORD
( event_class_code            VARCHAR2_30_tbl_type,
  application_id              NUMBER_tbl_type,
  entity_code                 VARCHAR2_30_tbl_type,
  internal_organization_id    NUMBER_tbl_type,
  precedence                  NUMBER_tbl_type,
  icx_session_id              NUMBER_15_tbl_type,
  quote_flag                  VARCHAR2_tbl_type
);

l_evnt_cls evnt_cls_rec_type;

/* Cursor for updating Det Factors information during Cancel/Discard */
  Cursor c_lines(p_event_class_rec ZX_API_PUB.event_class_rec_type,
                 p_trx_line_id     NUMBER,
                 p_trx_level_type VARCHAR2) is
  SELECT  /*+ INDEX(HEADER ZX_TRX_HEADERS_GT_U1) INDEX(TRXLINES ZX_TRANSACTION_LINES_GT_U1) */
          header.INTERNAL_ORGANIZATION_ID           ,
          header.APPLICATION_ID                     ,
          header.ENTITY_CODE                        ,
          header.EVENT_CLASS_CODE                   ,
          header.EVENT_TYPE_CODE                    ,
          header.TRX_ID                             ,
          trxlines.TRX_LEVEL_TYPE                   ,
          trxlines.TRX_LINE_ID                      ,
          trxlines.LINE_LEVEL_ACTION                ,
          nvl(trxlines.LINE_CLASS,p_event_class_rec.EVENT_CLASS_CODE),  --Bugfix 4938879
          header.TRX_DATE                           ,
          header.TRX_DOC_REVISION                   ,
          header.LEDGER_ID                          ,
          header.TRX_CURRENCY_CODE                  ,
          header.CURRENCY_CONVERSION_DATE           ,
          header.CURRENCY_CONVERSION_RATE           ,
          header.CURRENCY_CONVERSION_TYPE           ,
          header.MINIMUM_ACCOUNTABLE_UNIT           ,
          header.PRECISION                          ,
          trxlines.TRX_LINE_CURRENCY_CODE           ,
          trxlines.TRX_LINE_CURRENCY_CONV_DATE      ,
          trxlines.TRX_LINE_CURRENCY_CONV_RATE      ,
          trxlines.TRX_LINE_CURRENCY_CONV_TYPE      ,
          trxlines.TRX_LINE_MAU                     ,
          trxlines.TRX_LINE_PRECISION               ,
          trxlines.TRX_SHIPPING_DATE                ,
          trxlines.TRX_RECEIPT_DATE                 ,
          header.LEGAL_ENTITY_ID                    ,
          header.ROUNDING_SHIP_TO_PARTY_ID          ,
          header.ROUNDING_SHIP_FROM_PARTY_ID        ,
          header.ROUNDING_BILL_TO_PARTY_ID          ,
          header.ROUNDING_BILL_FROM_PARTY_ID        ,
          header.RNDG_SHIP_TO_PARTY_SITE_ID         ,
          header.RNDG_SHIP_FROM_PARTY_SITE_ID       ,
          header.RNDG_BILL_TO_PARTY_SITE_ID         ,
          header.RNDG_BILL_FROM_PARTY_SITE_ID       ,
          header.ESTABLISHMENT_ID                   ,
          trxlines.TRX_LINE_TYPE                    ,
          trxlines.TRX_LINE_DATE                    ,
          trxlines.TRX_BUSINESS_CATEGORY            ,
          trxlines.LINE_INTENDED_USE                ,
          trxlines.USER_DEFINED_FISC_CLASS          ,
          trxlines.LINE_AMT                         ,
          trxlines.TRX_LINE_QUANTITY                ,
          trxlines.UNIT_PRICE                       ,
          trxlines.EXEMPT_CERTIFICATE_NUMBER        ,
          trxlines.EXEMPT_REASON                    ,
          trxlines.CASH_DISCOUNT                    ,
          trxlines.VOLUME_DISCOUNT                  ,
          trxlines.TRADING_DISCOUNT                 ,
          trxlines.TRANSFER_CHARGE                  ,
          trxlines.TRANSPORTATION_CHARGE            ,
          trxlines.INSURANCE_CHARGE                 ,
          trxlines.OTHER_CHARGE                     ,
          trxlines.PRODUCT_ID                       ,
          trxlines.PRODUCT_FISC_CLASSIFICATION      ,
          trxlines.PRODUCT_ORG_ID                   ,
          trxlines.UOM_CODE                         ,
          trxlines.PRODUCT_TYPE                     ,
          trxlines.PRODUCT_CODE                     ,
          trxlines.PRODUCT_CATEGORY                 ,
          trxlines.TRX_SIC_CODE                     ,
          trxlines.FOB_POINT                        ,
          trxlines.SHIP_TO_PARTY_ID                 ,
          trxlines.SHIP_FROM_PARTY_ID               ,
          trxlines.POA_PARTY_ID                     ,
          trxlines.POO_PARTY_ID                     ,
          trxlines.BILL_TO_PARTY_ID                 ,
          trxlines.BILL_FROM_PARTY_ID               ,
          trxlines.MERCHANT_PARTY_ID                ,
          trxlines.SHIP_TO_PARTY_SITE_ID            ,
          trxlines.SHIP_FROM_PARTY_SITE_ID          ,
          trxlines.POA_PARTY_SITE_ID                ,
          trxlines.POO_PARTY_SITE_ID                ,
          trxlines.BILL_TO_PARTY_SITE_ID            ,
          trxlines.BILL_FROM_PARTY_SITE_ID          ,
          trxlines.SHIP_TO_LOCATION_ID              ,
          trxlines.SHIP_FROM_LOCATION_ID            ,
          trxlines.POA_LOCATION_ID                  ,
          trxlines.POO_LOCATION_ID                  ,
          trxlines.BILL_TO_LOCATION_ID              ,
          trxlines.BILL_FROM_LOCATION_ID            ,
          trxlines.ACCOUNT_CCID                     ,
          trxlines.ACCOUNT_STRING                   ,
          trxlines.MERCHANT_PARTY_COUNTRY           ,
          header.RECEIVABLES_TRX_TYPE_ID            ,
          trxlines.REF_DOC_APPLICATION_ID           ,
          trxlines.REF_DOC_ENTITY_CODE              ,
          trxlines.REF_DOC_EVENT_CLASS_CODE         ,
          trxlines.REF_DOC_TRX_ID                   ,
          trxlines.REF_DOC_LINE_ID                  ,
          trxlines.REF_DOC_LINE_QUANTITY            ,
          header.RELATED_DOC_APPLICATION_ID         ,
          header.RELATED_DOC_ENTITY_CODE            ,
          header.RELATED_DOC_EVENT_CLASS_CODE       ,
          header.RELATED_DOC_TRX_ID                 ,
          header.RELATED_DOC_NUMBER                 ,
          header.RELATED_DOC_DATE                   ,
          trxlines.APPLIED_FROM_APPLICATION_ID      ,
          trxlines.APPLIED_FROM_EVENT_CLASS_CODE    ,
          trxlines.APPLIED_FROM_ENTITY_CODE         ,
          trxlines.APPLIED_FROM_TRX_ID              ,
          trxlines.APPLIED_FROM_LINE_ID             ,
          trxlines.APPLIED_FROM_TRX_NUMBER          ,
          trxlines.ADJUSTED_DOC_APPLICATION_ID      ,
          trxlines.ADJUSTED_DOC_EVENT_CLASS_CODE    ,
          trxlines.ADJUSTED_DOC_ENTITY_CODE         ,
          trxlines.ADJUSTED_DOC_TRX_ID              ,
          trxlines.ADJUSTED_DOC_LINE_ID             ,
          trxlines.ADJUSTED_DOC_NUMBER              ,
          trxlines.ADJUSTED_DOC_DATE                ,
          trxlines.APPLIED_TO_APPLICATION_ID        ,
          trxlines.APPLIED_TO_ENTITY_CODE           ,
          trxlines.APPLIED_TO_EVENT_CLASS_CODE      ,
          trxlines.APPLIED_TO_TRX_ID                ,
          trxlines.APPLIED_TO_TRX_LINE_ID           ,
          trxlines.TRX_ID_LEVEL2                    ,
          trxlines.TRX_ID_LEVEL3                    ,
          trxlines.TRX_ID_LEVEL4                    ,
          trxlines.TRX_ID_LEVEL5                    ,
          trxlines.TRX_ID_LEVEL6                    ,
          header.TRX_NUMBER                         ,
          header.TRX_DESCRIPTION                    ,
          trxlines.TRX_LINE_NUMBER                  ,
          trxlines.TRX_LINE_DESCRIPTION             ,
          trxlines.PRODUCT_DESCRIPTION              ,
          trxlines.TRX_WAYBILL_NUMBER               ,
          header.TRX_COMMUNICATED_DATE              ,
          trxlines.TRX_LINE_GL_DATE                 ,
          header.BATCH_SOURCE_ID                    ,
          header.BATCH_SOURCE_NAME                  ,
          header.DOC_SEQ_ID                         ,
          header.DOC_SEQ_NAME                       ,
          header.DOC_SEQ_VALUE                      ,
          header.TRX_DUE_DATE                       ,
          header.TRX_TYPE_DESCRIPTION               ,
          trxlines.MERCHANT_PARTY_NAME              ,
          trxlines.MERCHANT_PARTY_DOCUMENT_NUMBER   ,
          trxlines.MERCHANT_PARTY_REFERENCE         ,
          trxlines.MERCHANT_PARTY_TAXPAYER_ID       ,
          trxlines.MERCHANT_PARTY_TAX_REG_NUMBER    ,
          trxlines.PAYING_PARTY_ID                  ,
          trxlines.OWN_HQ_PARTY_ID                  ,
          trxlines.TRADING_HQ_PARTY_ID              ,
          trxlines.POI_PARTY_ID                     ,
          trxlines.POD_PARTY_ID                     ,
          trxlines.TITLE_TRANSFER_PARTY_ID          ,
          trxlines.PAYING_PARTY_SITE_ID             ,
          trxlines.OWN_HQ_PARTY_SITE_ID             ,
          trxlines.TRADING_HQ_PARTY_SITE_ID         ,
          trxlines.POI_PARTY_SITE_ID                ,
          trxlines.POD_PARTY_SITE_ID                ,
          trxlines.TITLE_TRANSFER_PARTY_SITE_ID     ,
          trxlines.PAYING_LOCATION_ID               ,
          trxlines.OWN_HQ_LOCATION_ID               ,
          trxlines.TRADING_HQ_LOCATION_ID           ,
          trxlines.POC_LOCATION_ID                  ,
          trxlines.POI_LOCATION_ID                  ,
          trxlines.POD_LOCATION_ID                  ,
          trxlines.TITLE_TRANSFER_LOCATION_ID       ,
          trxlines.ASSESSABLE_VALUE                 ,
          trxlines.ASSET_FLAG                       ,
          trxlines.ASSET_NUMBER                     ,
          trxlines.ASSET_ACCUM_DEPRECIATION         ,
          trxlines.ASSET_TYPE                       ,
          trxlines.ASSET_COST                       ,
          trxlines.NUMERIC1                         ,
          trxlines.NUMERIC2                         ,
          trxlines.NUMERIC3                         ,
          trxlines.NUMERIC4                         ,
          trxlines.NUMERIC5                         ,
          trxlines.NUMERIC6                         ,
          trxlines.NUMERIC7                         ,
          trxlines.NUMERIC8                         ,
          trxlines.NUMERIC9                         ,
          trxlines.NUMERIC10                        ,
          trxlines.CHAR1                            ,
          trxlines.CHAR2                            ,
          trxlines.CHAR3                            ,
          trxlines.CHAR4                            ,
          trxlines.CHAR5                            ,
          trxlines.CHAR6                            ,
          trxlines.CHAR7                            ,
          trxlines.CHAR8                            ,
          trxlines.CHAR9                            ,
          trxlines.CHAR10                           ,
          trxlines.DATE1                            ,
          trxlines.DATE2                            ,
          trxlines.DATE3                            ,
          trxlines.DATE4                            ,
          trxlines.DATE5                            ,
          trxlines.DATE6                            ,
          trxlines.DATE7                            ,
          trxlines.DATE8                            ,
          trxlines.DATE9                            ,
          trxlines.DATE10                           ,
          header.FIRST_PTY_ORG_ID                   ,
          header.TAX_EVENT_CLASS_CODE               ,
          header.TAX_EVENT_TYPE_CODE                ,
          header.DOC_EVENT_STATUS                   ,
          header.RDNG_SHIP_TO_PTY_TX_PROF_ID        ,
          header.RDNG_SHIP_FROM_PTY_TX_PROF_ID      ,
          header.RDNG_BILL_TO_PTY_TX_PROF_ID        ,
          header.RDNG_BILL_FROM_PTY_TX_PROF_ID      ,
          header.RDNG_SHIP_TO_PTY_TX_P_ST_ID        ,
          header.RDNG_SHIP_FROM_PTY_TX_P_ST_ID      ,
          header.RDNG_BILL_TO_PTY_TX_P_ST_ID        ,
          header.RDNG_BILL_FROM_PTY_TX_P_ST_ID      ,
          trxlines.SHIP_TO_PARTY_TAX_PROF_ID        ,
          trxlines.SHIP_FROM_PARTY_TAX_PROF_ID      ,
          trxlines.POA_PARTY_TAX_PROF_ID            ,
          trxlines.POO_PARTY_TAX_PROF_ID            ,
          trxlines.PAYING_PARTY_TAX_PROF_ID         ,
          trxlines.OWN_HQ_PARTY_TAX_PROF_ID         ,
          trxlines.TRADING_HQ_PARTY_TAX_PROF_ID     ,
          trxlines.POI_PARTY_TAX_PROF_ID            ,
          trxlines.POD_PARTY_TAX_PROF_ID            ,
          trxlines.BILL_TO_PARTY_TAX_PROF_ID        ,
          trxlines.BILL_FROM_PARTY_TAX_PROF_ID      ,
          trxlines.TITLE_TRANS_PARTY_TAX_PROF_ID    ,
          trxlines.SHIP_TO_SITE_TAX_PROF_ID         ,
          trxlines.SHIP_FROM_SITE_TAX_PROF_ID       ,
          trxlines.POA_SITE_TAX_PROF_ID             ,
          trxlines.POO_SITE_TAX_PROF_ID             ,
          trxlines.PAYING_SITE_TAX_PROF_ID          ,
          trxlines.OWN_HQ_SITE_TAX_PROF_ID          ,
          trxlines.TRADING_HQ_SITE_TAX_PROF_ID      ,
          trxlines.POI_SITE_TAX_PROF_ID             ,
          trxlines.POD_SITE_TAX_PROF_ID             ,
          trxlines.BILL_TO_SITE_TAX_PROF_ID         ,
          trxlines.BILL_FROM_SITE_TAX_PROF_ID       ,
          trxlines.TITLE_TRANS_SITE_TAX_PROF_ID     ,
          trxlines.MERCHANT_PARTY_TAX_PROF_ID       ,
          to_number(null) HQ_ESTB_PARTY_TAX_PROF_ID,
          header.DOCUMENT_SUB_TYPE                  ,
          header.SUPPLIER_TAX_INVOICE_NUMBER        ,
          header.SUPPLIER_TAX_INVOICE_DATE          ,
          header.SUPPLIER_EXCHANGE_RATE             ,
          header.TAX_INVOICE_DATE                   ,
          header.TAX_INVOICE_NUMBER                 ,
          trxlines.LINE_AMT_INCLUDES_TAX_FLAG       ,
          header.QUOTE_FLAG                         ,
          header.DEFAULT_TAXATION_COUNTRY           ,
          trxlines.HISTORICAL_FLAG                  ,
          header.INTERNAL_ORG_LOCATION_ID           ,
          trxlines.CTRL_HDR_TX_APPL_FLAG            ,
          header.CTRL_TOTAL_HDR_TX_AMT              ,
          trxlines.CTRL_TOTAL_LINE_TX_AMT           ,
          null DIST_LEVEL_ACTION                    ,
          to_number(null) ADJUSTED_DOC_TASK_DIST_ID ,
          to_number(null) APPLIED_FROM_TAX_DIST_ID  ,
          to_number(null) TASK_ID                   ,
          to_number(null) AWARD_ID                  ,
          to_number(null) PROJECT_ID                ,
          null EXPENDITURE_TYPE                     ,
          to_number(null) EXPENDITURE_ORGANIZATION_ID ,
          null EXPENDITURE_ITEM_DATE                ,
          to_number(null) TRX_LINE_DIST_AMT         ,
          to_number(null) TRX_LINE_DIST_QUANTITY    ,
          to_number(null) REF_DOC_CURR_CONV_RATE    ,
          to_number(null) ITEM_DIST_NUMBER          ,
          to_number(null) REF_DOC_DIST_ID           ,
          to_number(null) TRX_LINE_DIST_TAX_AMT     ,
          to_number(null) TRX_LINE_DIST_ID          ,
          to_number(null) APPLIED_FROM_DIST_ID      ,
          to_number(null) ADJUSTED_DOC_DIST_ID      ,
          to_number(null) OVERRIDING_RECOVERY_RATE  ,
          trxlines.INPUT_TAX_CLASSIFICATION_CODE    ,
          trxlines.OUTPUT_TAX_CLASSIFICATION_CODE   ,
          header.PORT_OF_ENTRY_CODE                 ,
          header.TAX_REPORTING_FLAG                 ,
          null TAX_AMT_INCLUDED_FLAG                ,
          null COMPOUNDING_TAX_FLAG                 ,
          header.SHIP_THIRD_PTY_ACCT_ID             ,
          header.BILL_THIRD_PTY_ACCT_ID             ,
          header.SHIP_THIRD_PTY_ACCT_SITE_ID        ,
          header.BILL_THIRD_PTY_ACCT_SITE_ID        ,
          header.SHIP_TO_CUST_ACCT_SITE_USE_ID      ,
          header.BILL_TO_CUST_ACCT_SITE_USE_ID      ,
          header.PROVNL_TAX_DETERMINATION_DATE      ,
          trxlines.START_EXPENSE_DATE               ,
          header.TRX_BATCH_ID                       ,
          header.APPLIED_TO_TRX_NUMBER              ,
          trxlines.SOURCE_APPLICATION_ID            ,
          trxlines.SOURCE_ENTITY_CODE               ,
          trxlines.SOURCE_EVENT_CLASS_CODE          ,
          trxlines.SOURCE_TRX_ID                    ,
          trxlines.SOURCE_LINE_ID                   ,
          trxlines.SOURCE_TRX_LEVEL_TYPE            ,
          trxlines.REF_DOC_TRX_LEVEL_TYPE           ,
          trxlines.APPLIED_TO_TRX_LEVEL_TYPE        ,
          trxlines.APPLIED_FROM_TRX_LEVEL_TYPE      ,
          trxlines.ADJUSTED_DOC_TRX_LEVEL_TYPE      ,
          header.APPLICATION_DOC_STATUS             ,
          header.HDR_TRX_USER_KEY1                  ,
          header.HDR_TRX_USER_KEY2                  ,
          header.HDR_TRX_USER_KEY3                  ,
          header.HDR_TRX_USER_KEY4                  ,
          header.HDR_TRX_USER_KEY5                  ,
          header.HDR_TRX_USER_KEY6                  ,
          trxlines.LINE_TRX_USER_KEY1               ,
          trxlines.LINE_TRX_USER_KEY2               ,
          trxlines.LINE_TRX_USER_KEY3               ,
          trxlines.LINE_TRX_USER_KEY4               ,
          trxlines.LINE_TRX_USER_KEY5               ,
          trxlines.LINE_TRX_USER_KEY6               ,
          trxlines.SOURCE_TAX_LINE_ID               ,
          trxlines.EXEMPTION_CONTROL_FLAG           ,
          to_number(null) REVERSED_APPLN_ID         ,
          null REVERSED_ENTITY_CODE                 ,
          null REVERSED_EVNT_CLS_CODE               ,
          to_number(null) REVERSED_TRX_ID           ,
          null REVERSED_TRX_LEVEL_TYPE              ,
          to_number(null) REVERSED_TRX_LINE_ID      ,
          trxlines.EXEMPT_REASON_CODE               ,
          trxlines.INTERFACE_ENTITY_CODE            ,
          trxlines.INTERFACE_LINE_ID                ,
          trxlines.DEFAULTING_ATTRIBUTE1            ,
          trxlines.DEFAULTING_ATTRIBUTE2            ,
          trxlines.DEFAULTING_ATTRIBUTE3            ,
          trxlines.DEFAULTING_ATTRIBUTE4            ,
          trxlines.DEFAULTING_ATTRIBUTE5            ,
          trxlines.DEFAULTING_ATTRIBUTE6            ,
          trxlines.DEFAULTING_ATTRIBUTE7            ,
          trxlines.DEFAULTING_ATTRIBUTE8            ,
          trxlines.DEFAULTING_ATTRIBUTE9            ,
          trxlines.DEFAULTING_ATTRIBUTE10           ,
          trxlines.HISTORICAL_TAX_CODE_ID           ,
          nvl(trxlines.SHIP_THIRD_PTY_ACCT_ID,header.SHIP_THIRD_PTY_ACCT_ID),
          nvl(trxlines.BILL_THIRD_PTY_ACCT_ID,header.BILL_THIRD_PTY_ACCT_ID),
          nvl(trxlines.SHIP_THIRD_PTY_ACCT_SITE_ID,header.SHIP_THIRD_PTY_ACCT_SITE_ID),
          nvl(trxlines.BILL_THIRD_PTY_ACCT_SITE_ID,header.BILL_THIRD_PTY_ACCT_SITE_ID),
          nvl(trxlines.SHIP_TO_CUST_ACCT_SITE_USE_ID,header.SHIP_TO_CUST_ACCT_SITE_USE_ID),
          nvl(trxlines.BILL_TO_CUST_ACCT_SITE_USE_ID,header.BILL_TO_CUST_ACCT_SITE_USE_ID),
          nvl(trxlines.RECEIVABLES_TRX_TYPE_ID,header.RECEIVABLES_TRX_TYPE_ID),
          trxlines.GLOBAL_ATTRIBUTE_CATEGORY,
          trxlines.GLOBAL_ATTRIBUTE1,
          to_number(null) TOTAL_INC_TAX_AMT     ,
          trxlines.USER_UPD_DET_FACTORS_FLAG,
          decode(trxlines.line_level_action,'CREATE','I',
                                               'CREATE_TAX_ONLY','I',
                                               'APPLY_FROM','I',
                                               'INTERCOMPANY_CREATE','I',
                                               'UNAPPLY_FROM','U',
                                               'LINE_INFO_TAX_ONLY','I',
                                               'CREATE_WITH_TAX','I',
                                               'ALLOCATE_TAX_ONLY_ADJUSTMENT','I',
                                               'COPY_AND_CREATE','I',
                                               'RECORD_WITH_NO_TAX','I',
                                               'NO_CHANGE','U',
                                               'UPDATE','U',
                                               'DISCARD','U',
                                               'CANCEL','U',
                                               'SYNCHRONIZE','U',
                                               'DELETE','U')  INSERT_UPDATE_FLAG
      /* The update insert flag is to determine the records that need to be inserted/updated
	  into zx_lines_det_factors depending on the line_level_action for tax event type UPDATE*/
      FROM ZX_TRANSACTION_LINES_GT trxlines,
           ZX_TRX_HEADERS_GT header
      WHERE trxlines.application_id = header.application_id
        AND trxlines.entity_code = header.entity_code
        AND trxlines.event_class_code = header.event_class_code
        AND trxlines.trx_id = header.trx_id
        AND header.event_class_code = p_event_class_rec.event_class_code
        AND header.entity_code = p_event_class_rec.entity_code
        AND header.application_id = p_event_class_rec.application_id
        AND NVL(header.validation_check_flag, 'Y') = 'Y'
        AND (trxlines.trx_line_id = p_trx_line_id OR
             p_trx_line_id IS NULL)
        AND (trxlines.trx_level_type = p_trx_level_type OR
             p_trx_level_type IS NULL)
        AND NOT EXISTS(
              SELECT 1
                FROM ZX_ERRORS_GT err
               WHERE err.application_id = header.application_id
                 AND err.entity_code = header.entity_code
                 AND err.event_class_code = header.event_class_code
                 AND err.trx_id = header.trx_id)
   ORDER BY header.related_doc_application_id ASC NULLS FIRST ,
            header.legal_entity_id ASC,
            header.trx_date ASC,
            header.trx_id ASC,
            INSERT_UPDATE_FLAG DESC;

PROCEDURE Pop_Index_Attrbs_To_Null ( p_index          IN  NUMBER,
                                     x_return_status  OUT NOCOPY VARCHAR2
 ) IS
 -- Variables
   l_api_name           CONSTANT VARCHAR2(30):= 'POP_INDEX_ATTRBS_TO_NULL';
   l_application_id     NUMBER;
   l_entity_code        VARCHAR(30);
   l_event_class_code   VARCHAR(30);
   l_trx_id             NUMBER;
   l_trx_line_id        NUMBER;
   l_trx_level_type     VARCHAR(30);

 BEGIN
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',
         'ZX_SRVC_TYP_PKG: Pop_Index_Attrbs_To_Null()+');
   END IF;
   -- Copy the key attributes in the local variables
   l_application_id   := ZX_Global_Structures_Pkg.trx_line_dist_tbl.Application_id(p_index);
   l_entity_code      := ZX_Global_Structures_Pkg.trx_line_dist_tbl.Entity_code(p_index);
   l_event_class_code := ZX_Global_Structures_Pkg.trx_line_dist_tbl.Event_Class_code(p_index);
   l_trx_id           := ZX_Global_Structures_Pkg.trx_line_dist_tbl.Trx_id(p_index);
   l_trx_line_id      := ZX_Global_Structures_Pkg.trx_line_dist_tbl.Trx_line_Id(p_index);
   l_trx_level_type   := ZX_Global_Structures_Pkg.trx_line_dist_tbl.Trx_level_type(p_index);

   -- Call the procedure to populate all the attributes of plsql tbl structure
   -- ZX_Global_Structures_Pkg.trx_line_dist_tbl at index p_index to NULL
   ZX_GLOBAL_STRUCTURES_PKG.init_trx_line_dist_tbl (p_index);

   -- Populate the key attributes of ZX_Global_Structures_Pkg.trx_line_dist_tbl
   -- with values of local variables
   ZX_Global_Structures_Pkg.trx_line_dist_tbl.Application_id(p_index)   := l_application_id;
   ZX_Global_Structures_Pkg.trx_line_dist_tbl.Entity_code(p_index)      := l_entity_code;
   ZX_Global_Structures_Pkg.trx_line_dist_tbl.Event_Class_code(p_index) := l_event_class_code;
   ZX_Global_Structures_Pkg.trx_line_dist_tbl.Trx_id(p_index)           := l_trx_id;
   ZX_Global_Structures_Pkg.trx_line_dist_tbl.Trx_line_Id(p_index)      := l_trx_line_id;
   ZX_Global_Structures_Pkg.trx_line_dist_tbl.Trx_level_type(p_index)   := l_trx_level_type;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.END',
         'ZX_NEW_SERVICES_PKG: Pop_Index_Attrbs_To_Null()-');
   END IF;

 EXCEPTION
        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,
                  'Error occurred in ' || l_api_name || ' : ' ||SQLERRM);
            END IF;

 END Pop_Index_Attrbs_To_Null;

PROCEDURE db_update_line_det_factors
   (p_trx_line_dist_tbl  IN            ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl%TYPE,
    p_event_class_rec    IN            ZX_API_PUB.event_class_rec_type,
    p_line_level_action  IN            VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2)
IS
  l_api_name           CONSTANT VARCHAR2(30):= 'UPDATE_LINE_DET_FACTORS';
  l_context_info_rec   ZX_API_PUB.context_info_rec_type;
  l_insert_tab         ZX_API_PUB.VARCHAR2_1_tbl_type;
  l_return_status      VARCHAR2(1);

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||':'||l_api_name||'()+');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FORALL i IN NVL(p_trx_line_dist_tbl.application_id.FIRST,0) .. NVL(p_trx_line_dist_tbl.application_id.LAST,-99)
       UPDATE ZX_LINES_DET_FACTORS SET
                                EVENT_ID                       = p_event_class_rec.event_id,
                                INTERNAL_ORGANIZATION_ID       = p_trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID(i),
                                EVENT_TYPE_CODE                = p_trx_line_dist_tbl.EVENT_TYPE_CODE(i),
                                DOC_EVENT_STATUS               = p_event_class_rec.DOC_STATUS_CODE,
                                LINE_LEVEL_ACTION              = NVL(p_line_level_action, p_trx_line_dist_tbl.LINE_LEVEL_ACTION(i)),
                                LINE_CLASS                     = NVL(p_trx_line_dist_tbl.LINE_CLASS(i),p_event_class_rec.EVENT_CLASS_CODE), --Bugfix 4938879
                                TRX_DATE                       = p_trx_line_dist_tbl.TRX_DATE(i),
                                TRX_DOC_REVISION               = p_trx_line_dist_tbl.TRX_DOC_REVISION(i),
                                LEDGER_ID                      = p_trx_line_dist_tbl.LEDGER_ID(i),
                                TRX_CURRENCY_CODE              = p_trx_line_dist_tbl.TRX_CURRENCY_CODE(i),
                                CURRENCY_CONVERSION_DATE       = p_trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(i),
                                CURRENCY_CONVERSION_RATE       = p_trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(i),
                                CURRENCY_CONVERSION_TYPE       = p_trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(i),
                                MINIMUM_ACCOUNTABLE_UNIT       = p_trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(i),
                                PRECISION                      = p_trx_line_dist_tbl.PRECISION(i),
                                TRX_LINE_CURRENCY_CODE         = NVL(p_trx_line_dist_tbl.TRX_LINE_CURRENCY_CODE(i),p_trx_line_dist_tbl.TRX_CURRENCY_CODE(i)),
                                TRX_LINE_CURRENCY_CONV_DATE    = NVL(p_trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_DATE(i),p_trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(i)),
                                TRX_LINE_CURRENCY_CONV_RATE    = NVL(p_trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_RATE(i),p_trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(i)),
                                TRX_LINE_CURRENCY_CONV_TYPE    = NVL(p_trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_TYPE(i),p_trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(i)),
                                TRX_LINE_MAU                   = NVL(p_trx_line_dist_tbl.TRX_LINE_MAU(i),p_trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT(i)),
                                TRX_LINE_PRECISION             = NVL(p_trx_line_dist_tbl.TRX_LINE_PRECISION(i),p_trx_line_dist_tbl.PRECISION(i)),
                                LEGAL_ENTITY_ID                = p_trx_line_dist_tbl.LEGAL_ENTITY_ID(i),
                                ESTABLISHMENT_ID               = NVL(p_trx_line_dist_tbl.ESTABLISHMENT_ID(i), ESTABLISHMENT_ID),
--                                RECEIVABLES_TRX_TYPE_ID        = p_trx_line_dist_tbl.RECEIVABLES_TRX_TYPE_ID(i),
--                                DEFAULT_TAXATION_COUNTRY       = NVL(p_trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY(i), DEFAULT_TAXATION_COUNTRY),   -- Bug 5659537
--                                TRX_NUMBER                     = p_trx_line_dist_tbl.TRX_NUMBER(i),
--                                TRX_LINE_NUMBER                = p_trx_line_dist_tbl.TRX_LINE_NUMBER(i),
--                                TRX_LINE_DESCRIPTION           = p_trx_line_dist_tbl.TRX_LINE_DESCRIPTION(i),
--                                TRX_DESCRIPTION                = p_trx_line_dist_tbl.TRX_DESCRIPTION(i),
--                                TRX_COMMUNICATED_DATE          = p_trx_line_dist_tbl.TRX_COMMUNICATED_DATE(i),
--                                BATCH_SOURCE_ID                = p_trx_line_dist_tbl.BATCH_SOURCE_ID(i),
--                                BATCH_SOURCE_NAME              = p_trx_line_dist_tbl.BATCH_SOURCE_NAME(i),
--                                DOC_SEQ_ID                     = p_trx_line_dist_tbl.DOC_SEQ_ID(i),
--                                DOC_SEQ_NAME                   = p_trx_line_dist_tbl.DOC_SEQ_NAME(i),
--                                DOC_SEQ_VALUE                  = p_trx_line_dist_tbl.DOC_SEQ_VALUE(i),
--                                TRX_DUE_DATE                   = p_trx_line_dist_tbl.TRX_DUE_DATE(i),
--                                TRX_TYPE_DESCRIPTION           = p_trx_line_dist_tbl.TRX_TYPE_DESCRIPTION(i),
--                                DOCUMENT_SUB_TYPE              = NVL(p_trx_line_dist_tbl.DOCUMENT_SUB_TYPE(i), DOCUMENT_SUB_TYPE),   -- Bug 5659537
--                                SUPPLIER_TAX_INVOICE_NUMBER    = p_trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_NUMBER(i),
--                                SUPPLIER_TAX_INVOICE_DATE      = p_trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_DATE(i),
--                                SUPPLIER_EXCHANGE_RATE         = p_trx_line_dist_tbl.SUPPLIER_EXCHANGE_RATE(i),
--                                TAX_INVOICE_DATE               = DECODE(USER_UPD_DET_FACTORS_FLAG,'Y', TAX_INVOICE_DATE, NVL(p_trx_line_dist_tbl.TAX_INVOICE_DATE(i), TAX_INVOICE_DATE)),  -- Bug 5659357
--                                TAX_INVOICE_NUMBER             = p_trx_line_dist_tbl.TAX_INVOICE_NUMBER(i),
--                                FIRST_PTY_ORG_ID               = p_event_class_rec.FIRST_PTY_ORG_ID,
                                TAX_EVENT_CLASS_CODE           = p_event_class_rec.TAX_EVENT_CLASS_CODE,
                                TAX_EVENT_TYPE_CODE            = p_event_class_rec.TAX_EVENT_TYPE_CODE,
--                                RDNG_SHIP_TO_PTY_TX_PROF_ID    = p_trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID(i),
--                                RDNG_SHIP_FROM_PTY_TX_PROF_ID  = p_trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID(i),
--                                RDNG_BILL_TO_PTY_TX_PROF_ID    = p_trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID(i),
--                                RDNG_BILL_FROM_PTY_TX_PROF_ID  = p_trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID(i),
--                                RDNG_SHIP_TO_PTY_TX_P_ST_ID    = p_trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID(i),
--                                RDNG_SHIP_FROM_PTY_TX_P_ST_ID  = p_trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID(i),
--                                RDNG_BILL_TO_PTY_TX_P_ST_ID    = p_trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID(i),
--                                RDNG_BILL_FROM_PTY_TX_P_ST_ID  = p_trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID(i),
--                                LINE_INTENDED_USE              = DECODE(USER_UPD_DET_FACTORS_FLAG,'Y', LINE_INTENDED_USE, NVL(p_trx_line_dist_tbl.LINE_INTENDED_USE(i), LINE_INTENDED_USE)), --Bug 7371329
--                                TRX_LINE_TYPE                  = p_trx_line_dist_tbl.TRX_LINE_TYPE(i),
--                                TRX_SHIPPING_DATE              = p_trx_line_dist_tbl.TRX_SHIPPING_DATE(i),
--                                TRX_RECEIPT_DATE               = p_trx_line_dist_tbl.TRX_RECEIPT_DATE(i),
--                                TRX_SIC_CODE                   = p_trx_line_dist_tbl.TRX_SIC_CODE(i),
--                                FOB_POINT                      = p_trx_line_dist_tbl.FOB_POINT(i),
--                                TRX_WAYBILL_NUMBER             = p_trx_line_dist_tbl.TRX_WAYBILL_NUMBER(i),
--                                PRODUCT_ID                     = p_trx_line_dist_tbl.PRODUCT_ID(i),
--                                PRODUCT_FISC_CLASSIFICATION    = DECODE(USER_UPD_DET_FACTORS_FLAG,'Y', NVL(p_trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION(i), PRODUCT_FISC_CLASSIFICATION)),  -- Bug 5659357
--                                PRODUCT_ORG_ID                 = p_trx_line_dist_tbl.PRODUCT_ORG_ID(i),
--                                UOM_CODE                       = p_trx_line_dist_tbl.UOM_CODE(i),
--                                PRODUCT_TYPE                   = DECODE(USER_UPD_DET_FACTORS_FLAG,'Y',PRODUCT_TYPE,NVL(p_trx_line_dist_tbl.PRODUCT_TYPE(i), PRODUCT_TYPE)),  -- Bug 5659357
--                                PRODUCT_CODE                   = p_trx_line_dist_tbl.PRODUCT_CODE(i),
--                                PRODUCT_CATEGORY               = DECODE(USER_UPD_DET_FACTORS_FLAG,'Y',PRODUCT_CATEGORY, NVL(p_trx_line_dist_tbl.PRODUCT_CATEGORY(i), PRODUCT_CATEGORY)),  -- Bug 5659357
--                                PRODUCT_DESCRIPTION            = p_trx_line_dist_tbl.PRODUCT_DESCRIPTION(i),
--                                USER_DEFINED_FISC_CLASS        = DECODE(USER_UPD_DET_FACTORS_FLAG,'Y',USER_DEFINED_FISC_CLASS,NVL(p_trx_line_dist_tbl.USER_DEFINED_FISC_CLASS(i), USER_DEFINED_FISC_CLASS)),  -- Bug 5659357
                                LINE_AMT                       = p_trx_line_dist_tbl.LINE_AMT(i),
                                TRX_LINE_QUANTITY              = p_trx_line_dist_tbl.TRX_LINE_QUANTITY(i),
                                UNIT_PRICE                     = p_trx_line_dist_tbl.UNIT_PRICE(i),
--                                CASH_DISCOUNT                  = p_trx_line_dist_tbl.CASH_DISCOUNT(i),
--                                VOLUME_DISCOUNT                = p_trx_line_dist_tbl.VOLUME_DISCOUNT(i),
--                                TRADING_DISCOUNT               = p_trx_line_dist_tbl.TRADING_DISCOUNT(i),
--                                TRANSFER_CHARGE                = p_trx_line_dist_tbl.TRANSFER_CHARGE(i),
--                                TRANSPORTATION_CHARGE          = p_trx_line_dist_tbl.TRANSPORTATION_CHARGE(i),
--                                INSURANCE_CHARGE               = p_trx_line_dist_tbl.INSURANCE_CHARGE(i),
--                                OTHER_CHARGE                   = p_trx_line_dist_tbl.OTHER_CHARGE(i),
                                ASSESSABLE_VALUE               = DECODE(USER_UPD_DET_FACTORS_FLAG,'Y',ASSESSABLE_VALUE,NVL(p_trx_line_dist_tbl.ASSESSABLE_VALUE(i), ASSESSABLE_VALUE)),  -- Bug 5659357
--                                ASSET_FLAG                     = p_trx_line_dist_tbl.ASSET_FLAG(i),
--                                ASSET_NUMBER                   = p_trx_line_dist_tbl.ASSET_NUMBER(i),
--                                ASSET_ACCUM_DEPRECIATION       = p_trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION(i),
--                                ASSET_TYPE                     = p_trx_line_dist_tbl.ASSET_TYPE(i),
--                                ASSET_COST                     = p_trx_line_dist_tbl.ASSET_COST(i),
--                                RELATED_DOC_APPLICATION_ID     = p_trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID(i),
--                                RELATED_DOC_ENTITY_CODE        = p_trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE(i),
--                                RELATED_DOC_EVENT_CLASS_CODE   = p_trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE(i),
--                                RELATED_DOC_TRX_ID             = p_trx_line_dist_tbl.RELATED_DOC_TRX_ID(i),
--                                RELATED_DOC_NUMBER             = p_trx_line_dist_tbl.RELATED_DOC_NUMBER(i),
--                                RELATED_DOC_DATE               = p_trx_line_dist_tbl.RELATED_DOC_DATE(i),
--                                APPLIED_FROM_APPLICATION_ID    = p_trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID(i),
--                                APPLIED_FROM_ENTITY_CODE       = p_trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE(i),
--                                APPLIED_FROM_EVENT_CLASS_CODE  = p_trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE(i),
--                                APPLIED_FROM_TRX_ID            = p_trx_line_dist_tbl.APPLIED_FROM_TRX_ID(i),
--                                APPLIED_FROM_LINE_ID           = p_trx_line_dist_tbl.APPLIED_FROM_LINE_ID(i),
--                                APPLIED_FROM_TRX_NUMBER        = p_trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER(i),
--                                ADJUSTED_DOC_APPLICATION_ID    = p_trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID(i),
--                                ADJUSTED_DOC_ENTITY_CODE       = p_trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE(i),
--                                ADJUSTED_DOC_EVENT_CLASS_CODE  = p_trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE(i),
--                                ADJUSTED_DOC_TRX_ID            = p_trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID(i),
--                                ADJUSTED_DOC_LINE_ID           = p_trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID(i),
--                                ADJUSTED_DOC_NUMBER            = p_trx_line_dist_tbl.ADJUSTED_DOC_NUMBER(i),
--                                ADJUSTED_DOC_DATE              = p_trx_line_dist_tbl.ADJUSTED_DOC_DATE(i),
--                                APPLIED_TO_APPLICATION_ID      = p_trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID(i),
--                                APPLIED_TO_ENTITY_CODE         = p_trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE(i),
--                                APPLIED_TO_EVENT_CLASS_CODE    = p_trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE(i),
--                                APPLIED_TO_TRX_ID              = p_trx_line_dist_tbl.APPLIED_TO_TRX_ID(i),
--                                APPLIED_TO_TRX_LINE_ID         = p_trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID(i),
--                                TRX_ID_LEVEL2                  = p_trx_line_dist_tbl.TRX_ID_LEVEL2(i),
--                                TRX_ID_LEVEL3                  = p_trx_line_dist_tbl.TRX_ID_LEVEL3(i),
--                                TRX_ID_LEVEL4                  = p_trx_line_dist_tbl.TRX_ID_LEVEL4(i),
--                                TRX_ID_LEVEL5                  = p_trx_line_dist_tbl.TRX_ID_LEVEL5(i),
--                                TRX_ID_LEVEL6                  = p_trx_line_dist_tbl.TRX_ID_LEVEL6(i),
--                                TRX_BUSINESS_CATEGORY          = DECODE(USER_UPD_DET_FACTORS_FLAG,'Y', TRX_BUSINESS_CATEGORY, NVL(p_trx_line_dist_tbl.TRX_BUSINESS_CATEGORY(i), TRX_BUSINESS_CATEGORY)),  -- Bug 5659357
--                                EXEMPT_CERTIFICATE_NUMBER      = p_trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER(i),
--                                EXEMPT_REASON                  = p_trx_line_dist_tbl.EXEMPT_REASON(i),
--                                HISTORICAL_FLAG                = NVL(HISTORICAL_FLAG,p_trx_line_dist_tbl.HISTORICAL_FLAG(i)),
--                                TRX_LINE_GL_DATE               = p_trx_line_dist_tbl.TRX_LINE_GL_DATE(i),
--                                LINE_AMT_INCLUDES_TAX_FLAG     = p_trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG(i),
--                                ACCOUNT_CCID                   = p_trx_line_dist_tbl.ACCOUNT_CCID(i),
--                                ACCOUNT_STRING                 = p_trx_line_dist_tbl.ACCOUNT_STRING(i),
--                                MERCHANT_PARTY_TAX_PROF_ID     = p_trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID(i),
--                                HQ_ESTB_PARTY_TAX_PROF_ID      = p_trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID(i),
--                                NUMERIC1                       = p_trx_line_dist_tbl.NUMERIC1(i),
--                                NUMERIC2                       = p_trx_line_dist_tbl.NUMERIC2(i),
--                                NUMERIC3                       = p_trx_line_dist_tbl.NUMERIC3(i),
--                                NUMERIC4                       = p_trx_line_dist_tbl.NUMERIC4(i),
--                                NUMERIC5                       = p_trx_line_dist_tbl.NUMERIC5(i),
--                                NUMERIC6                       = p_trx_line_dist_tbl.NUMERIC6(i),
--                                NUMERIC7                       = p_trx_line_dist_tbl.NUMERIC7(i),
--                                NUMERIC8                       = p_trx_line_dist_tbl.NUMERIC8(i),
--                                NUMERIC9                       = p_trx_line_dist_tbl.NUMERIC9(i),
--                                NUMERIC10                      = p_trx_line_dist_tbl.NUMERIC10(i),
--                                CHAR1                          = p_trx_line_dist_tbl.CHAR1(i),
--                                CHAR2                          = p_trx_line_dist_tbl.CHAR2(i),
--                                CHAR3                          = p_trx_line_dist_tbl.CHAR3(i),
--                                CHAR4                          = p_trx_line_dist_tbl.CHAR4(i),
--                                CHAR5                          = p_trx_line_dist_tbl.CHAR5(i),
--                                CHAR6                          = p_trx_line_dist_tbl.CHAR6(i),
--                                CHAR7                          = p_trx_line_dist_tbl.CHAR7(i),
--                                CHAR8                          = p_trx_line_dist_tbl.CHAR8(i),
--                                CHAR9                          = p_trx_line_dist_tbl.CHAR9(i),
--                                CHAR10                         = p_trx_line_dist_tbl.CHAR10(i),
--                                DATE1                          = p_trx_line_dist_tbl.DATE1(i),
--                                DATE2                          = p_trx_line_dist_tbl.DATE2(i),
--                                DATE3                          = p_trx_line_dist_tbl.DATE3(i),
--                                DATE4                          = p_trx_line_dist_tbl.DATE4(i),
--                                DATE5                          = p_trx_line_dist_tbl.DATE5(i),
--                                DATE6                          = p_trx_line_dist_tbl.DATE6(i),
--                                DATE7                          = p_trx_line_dist_tbl.DATE7(i),
--                                DATE8                          = p_trx_line_dist_tbl.DATE8(i),
--                                DATE9                          = p_trx_line_dist_tbl.DATE9(i),
--                                DATE10                         = p_trx_line_dist_tbl.DATE10(i),
--                                MERCHANT_PARTY_NAME            = p_trx_line_dist_tbl.MERCHANT_PARTY_NAME(i),
--                                MERCHANT_PARTY_DOCUMENT_NUMBER = p_trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER(i),
--                                MERCHANT_PARTY_REFERENCE       = p_trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE(i),
--                                MERCHANT_PARTY_TAXPAYER_ID     = p_trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID(i),
--                                MERCHANT_PARTY_TAX_REG_NUMBER  = p_trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER(i),
--                                MERCHANT_PARTY_ID              = p_trx_line_dist_tbl.MERCHANT_PARTY_ID(i),
--                                MERCHANT_PARTY_COUNTRY         = p_trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY(i),
--                                SHIP_TO_LOCATION_ID            = p_trx_line_dist_tbl.SHIP_TO_LOCATION_ID(i),
--                                SHIP_FROM_LOCATION_ID          = p_trx_line_dist_tbl.SHIP_FROM_LOCATION_ID(i),
--                                POA_LOCATION_ID                = p_trx_line_dist_tbl.POA_LOCATION_ID(i),
--                                POO_LOCATION_ID                = p_trx_line_dist_tbl.POO_LOCATION_ID(i),
--                                BILL_TO_LOCATION_ID            = p_trx_line_dist_tbl.BILL_TO_LOCATION_ID(i),
--                                BILL_FROM_LOCATION_ID          = p_trx_line_dist_tbl.BILL_FROM_LOCATION_ID(i),
--                                PAYING_LOCATION_ID             = p_trx_line_dist_tbl.PAYING_LOCATION_ID(i),
--                                OWN_HQ_LOCATION_ID             = p_trx_line_dist_tbl.OWN_HQ_LOCATION_ID(i),
--                                TRADING_HQ_LOCATION_ID         = p_trx_line_dist_tbl.TRADING_HQ_LOCATION_ID(i),
--                                POC_LOCATION_ID                = p_trx_line_dist_tbl.POC_LOCATION_ID(i),
--                                POI_LOCATION_ID                = p_trx_line_dist_tbl.POI_LOCATION_ID(i),
--                                POD_LOCATION_ID                = p_trx_line_dist_tbl.POD_LOCATION_ID(i),
--                                TITLE_TRANSFER_LOCATION_ID     = p_trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID(i),
--                                SHIP_TO_PARTY_TAX_PROF_ID      = p_trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID(i),
--                                SHIP_FROM_PARTY_TAX_PROF_ID    = p_trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID(i),
--                                POA_PARTY_TAX_PROF_ID          = p_trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID(i),
--                                POO_PARTY_TAX_PROF_ID          = p_trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID(i),
--                                PAYING_PARTY_TAX_PROF_ID       = p_trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID(i),
--                                OWN_HQ_PARTY_TAX_PROF_ID       = p_trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID(i),
--                                TRADING_HQ_PARTY_TAX_PROF_ID   = p_trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID(i),
--                                POI_PARTY_TAX_PROF_ID          = p_trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID(i),
--                                POD_PARTY_TAX_PROF_ID          = p_trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID(i),
--                                BILL_TO_PARTY_TAX_PROF_ID      = p_trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID(i),
--                                BILL_FROM_PARTY_TAX_PROF_ID    = p_trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID(i),
--                                TITLE_TRANS_PARTY_TAX_PROF_ID  = p_trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID(i),
--                                SHIP_TO_SITE_TAX_PROF_ID       = p_trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID(i),
--                                SHIP_FROM_SITE_TAX_PROF_ID     = p_trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID(i),
--                                POA_SITE_TAX_PROF_ID           = p_trx_line_dist_tbl.POA_SITE_TAX_PROF_ID(i),
--                                POO_SITE_TAX_PROF_ID           = p_trx_line_dist_tbl.POO_SITE_TAX_PROF_ID(i),
--                                PAYING_SITE_TAX_PROF_ID        = p_trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID(i),
--                                OWN_HQ_SITE_TAX_PROF_ID        = p_trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID(i),
--                                TRADING_HQ_SITE_TAX_PROF_ID    = p_trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID(i),
--                                POI_SITE_TAX_PROF_ID           = p_trx_line_dist_tbl.POI_SITE_TAX_PROF_ID(i),
--                                POD_SITE_TAX_PROF_ID           = p_trx_line_dist_tbl.POD_SITE_TAX_PROF_ID(i),
--                                BILL_TO_SITE_TAX_PROF_ID       = p_trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID(i),
--                                BILL_FROM_SITE_TAX_PROF_ID     = p_trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID(i),
--                                TITLE_TRANS_SITE_TAX_PROF_ID   = p_trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID(i),
--                                CTRL_HDR_TX_APPL_FLAG          = p_trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG(i),
--                                CTRL_TOTAL_LINE_TX_AMT         = p_trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT(i),
--                                CTRL_TOTAL_HDR_TX_AMT          = p_trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(i),
--                                REF_DOC_APPLICATION_ID         = p_trx_line_dist_tbl.REF_DOC_APPLICATION_ID(i),
--                                REF_DOC_ENTITY_CODE            = p_trx_line_dist_tbl.REF_DOC_ENTITY_CODE(i),
--                                REF_DOC_EVENT_CLASS_CODE       = p_trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE(i),
--                                REF_DOC_TRX_ID                 = p_trx_line_dist_tbl.REF_DOC_TRX_ID(i),
--                                REF_DOC_LINE_ID                = p_trx_line_dist_tbl.REF_DOC_LINE_ID(i),
--                                REF_DOC_LINE_QUANTITY          = p_trx_line_dist_tbl.REF_DOC_LINE_QUANTITY(i),
--                                TRX_LINE_DATE                  = p_trx_line_dist_tbl.TRX_LINE_DATE(i),
--                                INPUT_TAX_CLASSIFICATION_CODE  = p_trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE(i),
--                                OUTPUT_TAX_CLASSIFICATION_CODE = p_trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE(i),
--                                INTERNAL_ORG_LOCATION_ID       = p_trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID(i),
--                                PORT_OF_ENTRY_CODE             = p_trx_line_dist_tbl.PORT_OF_ENTRY_CODE(i),
--                                TAX_REPORTING_FLAG             = DECODE(p_trx_line_dist_tbl.LINE_LEVEL_ACTION(i),'RECORD_WITH_NO_TAX',
--                                                                        'N',
--                                                                        NVL(p_trx_line_dist_tbl.TAX_REPORTING_FLAG(i),p_event_class_rec.tax_reporting_flag)),
--                                TAX_AMT_INCLUDED_FLAG          = p_trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG(i),
--                                COMPOUNDING_TAX_FLAG           = p_trx_line_dist_tbl.COMPOUNDING_TAX_FLAG(i),
--                                SHIP_THIRD_PTY_ACCT_ID         = p_trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID(i),
--                                BILL_THIRD_PTY_ACCT_ID         = p_trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID(i),
--                                SHIP_THIRD_PTY_ACCT_SITE_ID    = p_trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID(i),
--                                BILL_THIRD_PTY_ACCT_SITE_ID    = p_trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID(i),
--                                SHIP_TO_CUST_ACCT_SITE_USE_ID  = p_trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID(i),
--                                BILL_TO_CUST_ACCT_SITE_USE_ID  = p_trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID(i),
--                                START_EXPENSE_DATE             = p_trx_line_dist_tbl.START_EXPENSE_DATE(i),
--                                TRX_BATCH_ID                   = p_trx_line_dist_tbl.TRX_BATCH_ID(i),
--                                APPLIED_TO_TRX_NUMBER          = p_trx_line_dist_tbl.APPLIED_TO_TRX_NUMBER(i),
--                                SOURCE_APPLICATION_ID          = p_trx_line_dist_tbl.SOURCE_APPLICATION_ID(i),
--                                SOURCE_ENTITY_CODE             = p_trx_line_dist_tbl.SOURCE_ENTITY_CODE(i),
--                                SOURCE_EVENT_CLASS_CODE        = p_trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE(i),
--                                SOURCE_TRX_ID                  = p_trx_line_dist_tbl.SOURCE_TRX_ID(i),
--                                SOURCE_LINE_ID                 = p_trx_line_dist_tbl.SOURCE_LINE_ID(i),
--                                SOURCE_TRX_LEVEL_TYPE          = p_trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE(i),
--                                SOURCE_TAX_LINE_ID             = p_trx_line_dist_tbl.SOURCE_TAX_LINE_ID(i),
--                                REF_DOC_TRX_LEVEL_TYPE         = p_trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE(i),
--                                APPLIED_TO_TRX_LEVEL_TYPE      = p_trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE(i),
--                                APPLIED_FROM_TRX_LEVEL_TYPE    = p_trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE(i),
--                                ADJUSTED_DOC_TRX_LEVEL_TYPE    = p_trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE(i),
--                                APPLICATION_DOC_STATUS         = p_trx_line_dist_tbl.APPLICATION_DOC_STATUS(i),
                                TAX_PROCESSING_COMPLETED_FLAG  = 'Y',
                                TAX_CALCULATION_DONE_FLAG      = 'Y',
                                OBJECT_VERSION_NUMBER          = OBJECT_VERSION_NUMBER+1,
--                                HDR_TRX_USER_KEY1              = p_trx_line_dist_tbl.HDR_TRX_USER_KEY1(i),
--                                HDR_TRX_USER_KEY2              = p_trx_line_dist_tbl.HDR_TRX_USER_KEY2(i),
--                                HDR_TRX_USER_KEY3              = p_trx_line_dist_tbl.HDR_TRX_USER_KEY3(i),
--                                HDR_TRX_USER_KEY4              = p_trx_line_dist_tbl.HDR_TRX_USER_KEY4(i),
--                                HDR_TRX_USER_KEY5              = p_trx_line_dist_tbl.HDR_TRX_USER_KEY5(i),
--                                HDR_TRX_USER_KEY6              = p_trx_line_dist_tbl.HDR_TRX_USER_KEY6(i),
--                                LINE_TRX_USER_KEY1             = p_trx_line_dist_tbl.LINE_TRX_USER_KEY1(i),
--                                LINE_TRX_USER_KEY2             = p_trx_line_dist_tbl.LINE_TRX_USER_KEY2(i),
--                                LINE_TRX_USER_KEY3             = p_trx_line_dist_tbl.LINE_TRX_USER_KEY3(i),
--                                LINE_TRX_USER_KEY4             = p_trx_line_dist_tbl.LINE_TRX_USER_KEY4(i),
--                                LINE_TRX_USER_KEY5             = p_trx_line_dist_tbl.LINE_TRX_USER_KEY5(i),
--                                LINE_TRX_USER_KEY6             = p_trx_line_dist_tbl.LINE_TRX_USER_KEY6(i),
--                                EXEMPTION_CONTROL_FLAG         = p_trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG(i),
--                                EXEMPT_REASON_CODE             = p_trx_line_dist_tbl.EXEMPT_REASON_CODE(i),
--                                INTERFACE_ENTITY_CODE          = p_trx_line_dist_tbl.INTERFACE_ENTITY_CODE(i),
--                                INTERFACE_LINE_ID              = p_trx_line_dist_tbl.INTERFACE_LINE_ID(i),
--                                DEFAULTING_ATTRIBUTE1          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1(i),
--                                DEFAULTING_ATTRIBUTE2          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2(i),
--                                DEFAULTING_ATTRIBUTE3          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3(i),
--                                DEFAULTING_ATTRIBUTE4          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4(i),
--                                DEFAULTING_ATTRIBUTE5          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5(i),
--                                DEFAULTING_ATTRIBUTE6          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6(i),
--                                DEFAULTING_ATTRIBUTE7          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7(i),
--                                DEFAULTING_ATTRIBUTE8          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8(i),
--                                DEFAULTING_ATTRIBUTE9          = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9(i),
--                                DEFAULTING_ATTRIBUTE10         = p_trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10(i),
--                                PROVNL_TAX_DETERMINATION_DATE  = p_trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(i),
--                                HISTORICAL_TAX_CODE_ID         = p_trx_line_dist_tbl.HISTORICAL_TAX_CODE_ID(i),
--                                GLOBAL_ATTRIBUTE_CATEGORY      = p_trx_line_dist_tbl.GLOBAL_ATTRIBUTE_CATEGORY(i),
--                                GLOBAL_ATTRIBUTE1              = p_trx_line_dist_tbl.GLOBAL_ATTRIBUTE1(i),
                                USER_UPD_DET_FACTORS_FLAG      = NVL(p_trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG(i), USER_UPD_DET_FACTORS_FLAG),  -- Bug 5659357
                                TOTAL_INC_TAX_AMT              = NVL(p_trx_line_dist_tbl.TOTAL_INC_TAX_AMT(i),0),
                                ICX_SESSION_ID                 = ZX_SECURITY.G_ICX_SESSION_ID
--                                LAST_UPDATE_DATE               = sysdate,
--                                LAST_UPDATED_BY                = fnd_global.user_id,
--                                LAST_UPDATE_LOGIN              = fnd_global.conc_login_id
    	   WHERE APPLICATION_ID   = p_event_class_rec.APPLICATION_ID
           AND ENTITY_CODE      = p_event_class_rec.ENTITY_CODE
           AND EVENT_CLASS_CODE = p_event_class_rec.EVENT_CLASS_CODE
           AND TRX_ID           = p_trx_line_dist_tbl.TRX_ID(i)
           AND TRX_LINE_ID      = p_trx_line_dist_tbl.TRX_LINE_ID(i)
           AND TRX_LEVEL_TYPE   = p_trx_line_dist_tbl.TRX_LEVEL_TYPE(i)
           AND NOT EXISTS (SELECT 'Y'
                             FROM zx_errors_gt err_gt
                            WHERE err_gt.application_id   = p_trx_line_dist_tbl.application_id(i)
                              AND err_gt.entity_code      = p_trx_line_dist_tbl.entity_code(i)
                              AND err_gt.event_class_code = p_trx_line_dist_tbl.event_class_code(i)
                              AND err_gt.trx_id           = p_trx_line_dist_tbl.trx_id(i));

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_api_name||'.END',
        G_PKG_NAME ||':'||l_api_name||'(). Records Updated = ' || SQL%ROWCOUNT);
      FND_LOG.STRING(G_LEVEL_STATEMENT, G_MODULE_NAME||l_api_name||'.END',
        G_PKG_NAME ||':'||l_api_name||'()-'||', RETURN_STATUS = ' || x_return_status);
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
       END IF;
 END db_update_line_det_factors;

 /* =======================================================================*
 | PROCEDURE  freeze_tax_distributions :                                  |
 * =======================================================================*/

 PROCEDURE freeze_tax_dists_for_items
  (p_api_version           IN             NUMBER,
   p_init_msg_list         IN             VARCHAR2,
   p_commit                IN             VARCHAR2,
   p_validation_level      IN             NUMBER,
   x_return_status            OUT NOCOPY  VARCHAR2,
   x_msg_count                OUT NOCOPY  NUMBER,
   x_msg_data                 OUT NOCOPY  VARCHAR2,
   p_transaction_rec       IN OUT NOCOPY  ZX_API_PUB.transaction_rec_type,
   p_trx_line_dist_id_tbl  IN             ZX_API_PUB.number_tbl_type
  ) IS

   l_api_name          CONSTANT  VARCHAR2(30) := 'FREEZE_TAX_DISTS_FOR_ITEMS';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_event_class_rec             ZX_API_PUB.event_class_rec_type;
   l_init_msg_list               VARCHAR2(1);

CURSOR get_event_class_info
IS
SELECT evntcls.application_id,
       evntcls.entity_code,
       evntcls.event_class_code,
       evnttyp.event_type_code,
       null,                              --dist.tax_event_class_code,
       'UPDATE' tax_event_type_code,
       'UPDATED' doc_status_code,
       evntcls.summarization_flag,
       evntcls.retain_summ_tax_line_id_flag
  FROM zx_evnt_cls_mappings evntcls,
       zx_evnt_typ_mappings evnttyp
 WHERE p_transaction_rec.application_id = evntcls.application_id
   AND p_transaction_rec.entity_code = evntcls.entity_code
   AND p_transaction_rec.event_class_code = evntcls.event_class_code
   AND evnttyp.application_id = evntcls.application_id
   AND evnttyp.entity_code = evntcls.entity_code
   AND evnttyp.event_class_code = evntcls.event_class_code
   AND evnttyp.tax_event_type_code = 'UPDATE';


 BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||
                    '.BEGIN','ZX_NEW_SERVICES_PKG: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT freeze_tax_dists_for_itms_PVT;

  /*--------------------------------------------------+
   |   Standard call to check for call compatibility  |
   +--------------------------------------------------*/
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                      ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  /*--------------------------------------------------------------+
   |   Initialize message list if p_init_msg_list is set to TRUE  |
   +--------------------------------------------------------------*/
   IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
   ELSE
       l_init_msg_list := p_init_msg_list;
   END IF;

   IF FND_API.to_Boolean(l_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   ZX_API_PUB.G_PUB_SRVC := l_api_name;
   ZX_API_PUB.G_DATA_TRANSFER_MODE := 'PLS';
   ZX_API_PUB.G_EXTERNAL_API_CALL  := 'N';

   -- Get Event Class Info.
   --
   OPEN get_event_class_info;
   FETCH get_event_class_info INTO
             l_event_class_rec.APPLICATION_ID,
             l_event_class_rec.ENTITY_CODE,
             l_event_class_rec.EVENT_CLASS_CODE,
             l_event_class_rec.EVENT_TYPE_CODE,
             l_event_class_rec.TAX_EVENT_CLASS_CODE,
             l_event_class_rec.TAX_EVENT_TYPE_CODE,
             l_event_class_rec.DOC_STATUS_CODE,
             l_event_class_rec.summarization_flag,
             l_event_class_rec.retain_summ_tax_line_id_flag;

     IF get_event_class_info%notfound THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_api_name, G_PKG_NAME||':'||
                         l_api_name ||': Event Class Info not retreived');
      END IF;
     END IF;

     CLOSE get_event_class_info;

   /*-----------------------------------------+
    | Get the event id for the whole document |
    +-----------------------------------------*/
    SELECT ZX_LINES_DET_FACTORS_S.NEXTVAL
    INTO l_event_class_rec.event_id
    FROM dual;

  /*------------------------------------------------+
   |  Update zx_lines_det_factors                   |
   +------------------------------------------------*/
   FORALL i IN NVL(p_trx_line_dist_id_tbl.FIRST,0) ..NVL(p_trx_line_dist_id_tbl.LAST, -1)
     UPDATE /*+ cardinality(ZX_LINES_DET_FACTORS,100) */  ZX_LINES_DET_FACTORS
       SET EVENT_TYPE_CODE     = p_transaction_rec.event_type_code,
           TAX_EVENT_TYPE_CODE = p_transaction_rec.tax_event_type_code,
           EVENT_ID            = l_event_class_rec.event_id,
           DOC_EVENT_STATUS    = l_event_class_rec.doc_status_code
     WHERE APPLICATION_ID      = p_transaction_rec.APPLICATION_ID
       AND ENTITY_CODE         = p_transaction_rec.ENTITY_CODE
       AND EVENT_CLASS_CODE    = p_transaction_rec.EVENT_CLASS_CODE
       AND TRX_ID              = p_transaction_rec.TRX_ID
       AND (TRX_LINE_ID, TRX_LEVEL_TYPE) IN
            (SELECT /*+ use_hash(dist) */ dist.trx_line_id, dist.trx_level_type
               FROM zx_rec_nrec_dist dist
              WHERE application_id = p_transaction_rec.application_id
                AND entity_code = p_transaction_rec.entity_code
                AND event_class_code = p_transaction_rec.event_class_code
                AND trx_id = p_transaction_rec.trx_id
                AND trx_line_dist_id  = p_trx_line_dist_id_tbl(i)
            );

   -- Update Pseudo Item Lines for Tax only lines.
   UPDATE /*+ cardinality(ZX_LINES_DET_FACTORS,100) */  ZX_LINES_DET_FACTORS
     SET EVENT_TYPE_CODE     = p_transaction_rec.event_type_code,
         TAX_EVENT_TYPE_CODE = p_transaction_rec.tax_event_type_code,
         EVENT_ID            = l_event_class_rec.event_id,
         DOC_EVENT_STATUS    = l_event_class_rec.doc_status_code
   WHERE APPLICATION_ID      = p_transaction_rec.APPLICATION_ID
     AND ENTITY_CODE         = p_transaction_rec.ENTITY_CODE
     AND EVENT_CLASS_CODE    = p_transaction_rec.EVENT_CLASS_CODE
     AND TRX_ID              = p_transaction_rec.TRX_ID
     AND (TRX_LINE_ID, TRX_LEVEL_TYPE) IN
          (SELECT dist.trx_line_id, dist.trx_level_type
             FROM zx_rec_nrec_dist dist
            WHERE application_id = p_transaction_rec.application_id
              AND entity_code = p_transaction_rec.entity_code
              AND event_class_code = p_transaction_rec.event_class_code
              AND trx_id = p_transaction_rec.trx_id
              AND tax_only_line_flag  = 'Y'
          );

    FORALL i IN NVL(p_trx_line_dist_id_tbl.FIRST,0) ..NVL(p_trx_line_dist_id_tbl.LAST, -1)
      UPDATE ZX_REC_NREC_DIST
         SET freeze_flag = 'Y',
             event_type_code = l_event_class_rec.event_type_code,
             tax_event_type_code = l_event_class_rec.tax_event_type_code
       WHERE application_id = p_transaction_rec.application_id
         AND entity_code = p_transaction_rec.entity_code
         AND event_class_code = p_transaction_rec.event_class_code
         AND trx_id = p_transaction_rec.trx_id
         AND trx_line_dist_id  = p_trx_line_dist_id_tbl(i);

   -- Update freeze_flag for tax only distributions.
   UPDATE ZX_REC_NREC_DIST
      SET freeze_flag = 'Y',
          event_type_code = l_event_class_rec.event_type_code,
          tax_event_type_code = l_event_class_rec.tax_event_type_code
    WHERE application_id = p_transaction_rec.application_id
      AND entity_code = p_transaction_rec.entity_code
      AND event_class_code = p_transaction_rec.event_class_code
      AND trx_id = p_transaction_rec.trx_id
      AND tax_only_line_flag = 'Y';

   FORALL i IN NVL(p_trx_line_dist_id_tbl.FIRST,0) ..NVL(p_trx_line_dist_id_tbl.LAST, -1)
     UPDATE ZX_LINES ZL
        SET associated_child_frozen_flag ='Y',
            event_type_code = l_event_class_rec.event_type_code,
            tax_event_type_code = l_event_class_rec.tax_event_type_code,
            doc_event_status = l_event_class_rec.doc_status_code
      WHERE TAX_LINE_ID IN (SELECT ZD.TAX_LINE_ID
                              FROM ZX_REC_NREC_DIST ZD
                             WHERE application_id = p_transaction_rec.application_id
                               AND entity_code = p_transaction_rec.entity_code
                               AND event_class_code = p_transaction_rec.event_class_code
                               AND trx_id = p_transaction_rec.trx_id
                               AND trx_line_dist_id  = p_trx_line_dist_id_tbl(i)
                            );

   -- Update assciated_child_frozen_fag for tax only lines.
   UPDATE ZX_LINES ZL
      SET associated_child_frozen_flag ='Y',
          event_type_code = l_event_class_rec.event_type_code,
          tax_event_type_code = l_event_class_rec.tax_event_type_code,
          doc_event_status = l_event_class_rec.doc_status_code
    WHERE TAX_LINE_ID IN (SELECT ZD.TAX_LINE_ID
                            FROM ZX_REC_NREC_DIST ZD
                           WHERE application_id = p_transaction_rec.application_id
                             AND entity_code = p_transaction_rec.entity_code
                             AND event_class_code = p_transaction_rec.event_class_code
                             AND trx_id = p_transaction_rec.trx_id
                             AND tax_only_line_flag = 'Y'
                          );

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_api_name||'.END',
                     'ZX_NEW_SERVICES_PKG: '||l_api_name||'()-');
    END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO freeze_tax_dists_for_itms_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                 );

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO freeze_tax_dists_for_itms_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                 );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN OTHERS THEN
       ROLLBACK TO freeze_tax_dists_for_itms_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                );
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
 END freeze_tax_dists_for_items;

PROCEDURE UPDATE_DET_FACTORS_FOR_CANCEL(
             x_return_status            OUT NOCOPY VARCHAR2,
             x_msg_count                OUT NOCOPY NUMBER,
             x_msg_data                 OUT NOCOPY VARCHAR2,
             p_event_class_rec       IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
             p_transaction_rec       IN            ZX_API_PUB.transaction_rec_type,
             p_trx_line_id           IN            NUMBER,
             p_trx_level_type        IN            VARCHAR2,
             p_line_level_action     IN            VARCHAR2
                                        )
IS

   l_api_name          CONSTANT  VARCHAR2(30) := 'UPDATE_DET_FACTORS_FOR_CANCEL';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             ZX_API_PUB.event_class_rec_type;
   l_init_msg_list               VARCHAR2(1);

  CURSOR event_classes IS
  SELECT distinct
         header.event_class_code,
         header.application_id,
         header.entity_code,
         header.internal_organization_id,
         evntmap.processing_precedence,
         header.icx_session_id,
         header.quote_flag
  FROM ZX_EVNT_CLS_MAPPINGS evntmap,
       ZX_TRX_HEADERS_GT header
  WHERE header.application_id = evntmap.application_id
  AND header.entity_code = evntmap.entity_code
  AND header.event_class_code = evntmap.event_class_code
  AND header.application_id = p_transaction_rec.application_id
  AND header.entity_code = p_transaction_rec.entity_code
  AND header.event_class_code = p_transaction_rec.event_class_code
  AND header.trx_id = p_transaction_rec.trx_id
  ORDER BY evntmap.processing_precedence;

  l_application_id_tbl     	NUMBER_tbl_type;
  l_entity_code_tbl    	VARCHAR2_30_tbl_type;
  l_event_class_code_tbl	VARCHAR2_30_tbl_type;
  l_trx_id_tbl		NUMBER_tbl_type;
  l_icx_session_id_tbl	NUMBER_tbl_type;
  l_event_type_code_tbl	VARCHAR2_30_tbl_type;
  l_tax_event_type_code_tbl	VARCHAR2_30_tbl_type;
  l_doc_event_status_tbl	VARCHAR2_30_tbl_type;

  l_internal_org_location_id    NUMBER;
  l_context_info_rec            ZX_API_PUB.context_info_rec_type;
  l_flag                        BOOLEAN;
  l_trx_id                      NUMBER := -1;
  l_legal_entity_id             NUMBER := -1;
  l_trx_date                    DATE := TO_DATE('01/01/1951', 'DD/MM/RRRR');
  l_effective_date              DATE;
  l_event_id                    NUMBER;
  l_error_buffer                VARCHAR2(2000);

BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_NEW_SERVICES_PKG: '||l_api_name||'()+');
   END IF;

   SAVEPOINT update_det_factors_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (p_event_class_rec => NULL,
                                            p_init_level      => 'SESSION',
                                            x_return_status   => l_return_status
                                           );

   OPEN event_classes;
   LOOP
   FETCH event_classes BULK COLLECT INTO
         l_evnt_cls.event_class_code,
         l_evnt_cls.application_id,
         l_evnt_cls.entity_code,
         l_evnt_cls.internal_organization_id,
         l_evnt_cls.precedence,
         l_evnt_cls.icx_session_id,
         l_evnt_cls.quote_flag
   LIMIT G_LINES_PER_FETCH;
   EXIT WHEN event_classes%NOTFOUND;
   END LOOP;
   CLOSE event_classes;

   IF l_evnt_cls.internal_organization_id.COUNT > 1 THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel',
               'This API cannot handle Bulk calls');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
               'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF l_evnt_cls.event_class_code.LAST is null THEN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         'Event class information does not exist - indicates SALES_TRANSACTION_TAX_QUOTE/PURCHASE_TRANSACTION_TAX_QUOTE');
     END IF;

     select event_class_code,
            application_id,
            entity_code,
            internal_organization_id,
            icx_session_id,
            quote_flag
     into l_evnt_cls.event_class_code(1),
          l_evnt_cls.application_id(1),
          l_evnt_cls.entity_code(1),
          l_evnt_cls.internal_organization_id(1),
          l_evnt_cls.icx_session_id(1),
          l_evnt_cls.quote_flag(1)
     from ZX_TRX_HEADERS_GT
     where application_id = p_transaction_rec.application_id
     and entity_code = p_transaction_rec.entity_code
     and event_class_code = p_transaction_rec.event_class_code
     and trx_id = p_transaction_rec.trx_id;
   END IF;

   select ZX_LINES_DET_FACTORS_S.nextval
   into l_event_id
   from dual;

   l_event_class_rec.EVENT_ID                     :=  l_event_id;
   l_event_class_rec.INTERNAL_ORGANIZATION_ID     :=  l_evnt_cls.internal_organization_id(1);
   l_event_class_rec.APPLICATION_ID               :=  l_evnt_cls.application_id(1);
   l_event_class_rec.ENTITY_CODE                  :=  l_evnt_cls.entity_code(1);
   l_event_class_rec.EVENT_CLASS_CODE             :=  l_evnt_cls.event_class_code(1);
   l_event_class_rec.ICX_SESSION_ID               :=  l_evnt_cls.icx_session_id(1);
   l_event_class_rec.QUOTE_FLAG		                :=  nvl(l_evnt_cls.quote_flag(1),'N');

   IF l_event_class_rec.QUOTE_FLAG = 'Y' and
      l_event_class_rec.ICX_SESSION_ID is not null THEN
     ZX_SECURITY.G_ICX_SESSION_ID := l_event_class_rec.ICX_SESSION_ID;
     ZX_SECURITY.name_value('SESSIONID',to_char(ZX_SECURITY.G_ICX_SESSION_ID));
   END IF;

   ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl.DELETE;
   ZX_VALID_INIT_PARAMS_PKG.calculate_tax(p_event_class_rec => l_event_class_rec,
                                          x_return_status   => l_return_status
                                         );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_return_status := l_return_status ;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
            G_PKG_NAME||': '||l_api_name||':ZX_VALID_INIT_PARAMS_PKG.calculate_tax returned errors');
       FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
            'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
     END IF;
     RETURN;
   END IF;

   ZX_TCM_PTP_PKG.get_location_id(l_event_class_rec.internal_organization_id,
                                  l_internal_org_location_id,
                                  l_return_status
                                  );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_return_status := l_return_status;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        l_context_info_rec.APPLICATION_ID   := l_event_class_rec.APPLICATION_ID;
        l_context_info_rec.ENTITY_CODE      := l_event_class_rec.ENTITY_CODE;
        l_context_info_rec.EVENT_CLASS_CODE := l_event_class_rec.EVENT_CLASS_CODE;
        l_context_info_rec.TRX_ID           := l_event_class_rec.TRX_ID;
        ZX_API_PUB.add_msg(p_context_info_rec => l_context_info_rec);
     END IF;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          ' RETURN_STATUS = ' || x_return_status);
	      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          G_PKG_NAME||': '||l_api_name||':ZX_TCM_PTP_PKG.get_location_id returned errors');
	      FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
            'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
     END IF;
     RETURN;
   END IF;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
   	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
          'p_trx_line_id:' || p_trx_line_id);
	  FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel',
            'p_trx_level_type: ' || p_trx_level_type);
   END IF;

   OPEN c_lines(l_event_class_rec,
                p_trx_line_id,
                p_trx_level_type);
   LOOP
   FETCH c_lines BULK COLLECT INTO
             zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.ENTITY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.EVENT_CLASS_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.EVENT_TYPE_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LEVEL_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_LEVEL_ACTION,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_CLASS,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_DOC_REVISION,
             zx_global_structures_pkg.trx_line_dist_tbl.LEDGER_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_CURRENCY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE,
             zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.MINIMUM_ACCOUNTABLE_UNIT,
             zx_global_structures_pkg.trx_line_dist_tbl.PRECISION,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_RATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_CURRENCY_CONV_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_MAU,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_PRECISION,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_SHIPPING_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_RECEIPT_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.ESTABLISHMENT_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_BUSINESS_CATEGORY,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_INTENDED_USE,
             zx_global_structures_pkg.trx_line_dist_tbl.USER_DEFINED_FISC_CLASS,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_QUANTITY,
             zx_global_structures_pkg.trx_line_dist_tbl.UNIT_PRICE,
             zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_CERTIFICATE_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_REASON,
             zx_global_structures_pkg.trx_line_dist_tbl.CASH_DISCOUNT,
             zx_global_structures_pkg.trx_line_dist_tbl.VOLUME_DISCOUNT,
             zx_global_structures_pkg.trx_line_dist_tbl.TRADING_DISCOUNT,
             zx_global_structures_pkg.trx_line_dist_tbl.TRANSFER_CHARGE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRANSPORTATION_CHARGE,
             zx_global_structures_pkg.trx_line_dist_tbl.INSURANCE_CHARGE,
             zx_global_structures_pkg.trx_line_dist_tbl.OTHER_CHARGE,
             zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_FISC_CLASSIFICATION,
             zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_ORG_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.UOM_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_CATEGORY,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_SIC_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.FOB_POINT,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POA_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POO_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_CCID,
             zx_global_structures_pkg.trx_line_dist_tbl.ACCOUNT_STRING,
             zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_COUNTRY,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_RECEIVABLES_TRX_TYPE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_APPLICATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_ENTITY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_EVENT_CLASS_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_LINE_QUANTITY,
             zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_APPLICATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_ENTITY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_EVENT_CLASS_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_TRX_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_APPLICATION_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_EVENT_CLASS_CODE ,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_ENTITY_CODE ,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_LINE_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_NUMBER ,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_APPLICATION_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_EVENT_CLASS_CODE ,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_ENTITY_CODE ,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_LINE_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_APPLICATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_ENTITY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_EVENT_CLASS_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LINE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL2,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL3,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL4,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL5,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID_LEVEL6,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_DESCRIPTION,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DESCRIPTION,
             zx_global_structures_pkg.trx_line_dist_tbl.PRODUCT_DESCRIPTION,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_WAYBILL_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_COMMUNICATED_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_GL_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.BATCH_SOURCE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BATCH_SOURCE_NAME,
             zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_NAME,
             zx_global_structures_pkg.trx_line_dist_tbl.DOC_SEQ_VALUE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_DUE_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_TYPE_DESCRIPTION,
             zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_NAME,
             zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_DOCUMENT_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_REFERENCE,
             zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAXPAYER_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_REG_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_PARTY_SITE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.PAYING_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POC_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POI_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POD_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANSFER_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.ASSESSABLE_VALUE,
             zx_global_structures_pkg.trx_line_dist_tbl.Asset_Flag,
             zx_global_structures_pkg.trx_line_dist_tbl.ASSET_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.ASSET_ACCUM_DEPRECIATION,
             zx_global_structures_pkg.trx_line_dist_tbl.ASSET_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.ASSET_COST,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC1,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC2,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC3,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC4,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC5,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC6,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC7,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC8,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC9,
             zx_global_structures_pkg.trx_line_dist_tbl.NUMERIC10,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR1,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR2,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR3,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR4,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR5,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR6,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR7,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR8,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR9,
             zx_global_structures_pkg.trx_line_dist_tbl.CHAR10,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE1,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE2,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE3,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE4,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE5,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE6,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE7,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE8,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE9,
             zx_global_structures_pkg.trx_line_dist_tbl.DATE10,
             zx_global_structures_pkg.trx_line_dist_tbl.FIRST_PTY_ORG_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_CLASS_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.DOC_EVENT_STATUS,
             zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_TO_PTY_TX_P_ST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_TO_PTY_TX_P_ST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RDNG_BILL_FROM_PTY_TX_P_ST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POA_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POO_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.PAYING_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POI_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POD_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_FROM_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POA_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POO_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.PAYING_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.OWN_HQ_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRADING_HQ_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POI_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.POD_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_FROM_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TITLE_TRANS_SITE_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.MERCHANT_PARTY_TAX_PROF_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.HQ_ESTB_PARTY_TAX_PROF_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.DOCUMENT_SUB_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_TAX_INVOICE_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.SUPPLIER_EXCHANGE_RATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TAX_INVOICE_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_AMT_INCLUDES_TAX_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.QUOTE_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULT_TAXATION_COUNTRY,
             zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.CTRL_HDR_TX_APPL_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT,
             zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_LINE_TX_AMT,
             zx_global_structures_pkg.trx_line_dist_tbl.DIST_LEVEL_ACTION,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TAX_DIST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TAX_DIST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TASK_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.AWARD_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.PROJECT_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_ORGANIZATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.EXPENDITURE_ITEM_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_AMT,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_QUANTITY,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_CURR_CONV_RATE,
             zx_global_structures_pkg.trx_line_dist_tbl.ITEM_DIST_NUMBER,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_DIST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_TAX_AMT,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_LINE_DIST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_DIST_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_DIST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.OVERRIDING_RECOVERY_RATE,
             zx_global_structures_pkg.trx_line_dist_tbl.INPUT_TAX_CLASSIFICATION_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.OUTPUT_TAX_CLASSIFICATION_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.PORT_OF_ENTRY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.TAX_REPORTING_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.TAX_AMT_INCLUDED_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.COMPOUNDING_TAX_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_SHIP_THIRD_PTY_ACCT_ST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_BILL_THIRD_PTY_ACCT_ST_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_SHIP_TO_CST_ACCT_ST_USE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_BILL_TO_CST_ACCT_ST_USE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_SHIP_THIRD_PTY_ACCT_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_BILL_THIRD_PTY_ACCT_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE,
             zx_global_structures_pkg.trx_line_dist_tbl.START_EXPENSE_DATE ,
             zx_global_structures_pkg.trx_line_dist_tbl.TRX_BATCH_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_NUMBER ,
             zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_APPLICATION_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_ENTITY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_EVENT_CLASS_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_LINE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TRX_LEVEL_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.REF_DOC_TRX_LEVEL_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_TO_TRX_LEVEL_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLIED_FROM_TRX_LEVEL_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.ADJUSTED_DOC_TRX_LEVEL_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.APPLICATION_DOC_STATUS,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY1,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY2,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY3,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY4,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY5,
             zx_global_structures_pkg.trx_line_dist_tbl.HDR_TRX_USER_KEY6,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY1,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY2,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY3,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY4,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY5,
             zx_global_structures_pkg.trx_line_dist_tbl.LINE_TRX_USER_KEY6,
             zx_global_structures_pkg.trx_line_dist_tbl.SOURCE_TAX_LINE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.EXEMPTION_CONTROL_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_APPLN_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_ENTITY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_EVNT_CLS_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_LINE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.REVERSED_TRX_LEVEL_TYPE,
             zx_global_structures_pkg.trx_line_dist_tbl.EXEMPT_REASON_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.INTERFACE_ENTITY_CODE,
             zx_global_structures_pkg.trx_line_dist_tbl.INTERFACE_LINE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE1,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE2,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE3,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE4,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE5,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE6,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE7,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE8,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE9,
             zx_global_structures_pkg.trx_line_dist_tbl.DEFAULTING_ATTRIBUTE10,
             zx_global_structures_pkg.trx_line_dist_tbl.HISTORICAL_TAX_CODE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_THIRD_PTY_ACCT_SITE_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_THIRD_PTY_ACCT_SITE_ID ,
             zx_global_structures_pkg.trx_line_dist_tbl.SHIP_TO_CUST_ACCT_SITE_USE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.BILL_TO_CUST_ACCT_SITE_USE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.RECEIVABLES_TRX_TYPE_ID,
             zx_global_structures_pkg.trx_line_dist_tbl.GLOBAL_ATTRIBUTE_CATEGORY,
             zx_global_structures_pkg.trx_line_dist_tbl.GLOBAL_ATTRIBUTE1,
             zx_global_structures_pkg.trx_line_dist_tbl.TOTAL_INC_TAX_AMT,
             zx_global_structures_pkg.trx_line_dist_tbl.USER_UPD_DET_FACTORS_FLAG,
             zx_global_structures_pkg.trx_line_dist_tbl.INSERT_UPDATE_FLAG
           LIMIT G_LINES_PER_FETCH;
   FOR l_trx_line_index IN 1 .. NVL(zx_global_structures_pkg.trx_line_dist_tbl.INTERNAL_ORGANIZATION_ID.LAST,0)
   LOOP

     IF zx_global_structures_pkg.trx_line_dist_tbl.trx_id(l_trx_line_index) <> l_trx_id THEN
        l_flag := TRUE;
        l_event_class_rec.LEGAL_ENTITY_ID              :=  zx_global_structures_pkg.trx_line_dist_tbl.LEGAL_ENTITY_ID(l_trx_line_index);
        l_event_class_rec.LEDGER_ID                    :=  zx_global_structures_pkg.trx_line_dist_tbl.LEDGER_ID(l_trx_line_index);
        l_event_class_rec.EVENT_TYPE_CODE              :=  zx_global_structures_pkg.trx_line_dist_tbl.EVENT_TYPE_CODE(l_trx_line_index);
        l_event_class_rec.CTRL_TOTAL_HDR_TX_AMT        :=  zx_global_structures_pkg.trx_line_dist_tbl.CTRL_TOTAL_HDR_TX_AMT(l_trx_line_index);
        l_event_class_rec.TRX_ID                       :=  zx_global_structures_pkg.trx_line_dist_tbl.TRX_ID(l_trx_line_index);
        l_event_class_rec.TRX_DATE                     :=  zx_global_structures_pkg.trx_line_dist_tbl.TRX_DATE(l_trx_line_index);
        l_event_class_rec.REL_DOC_DATE                 :=  zx_global_structures_pkg.trx_line_dist_tbl.RELATED_DOC_DATE(l_trx_line_index);
        l_event_class_rec.PROVNL_TAX_DETERMINATION_DATE:=  zx_global_structures_pkg.trx_line_dist_tbl.PROVNL_TAX_DETERMINATION_DATE(l_trx_line_index);
        l_event_class_rec.TRX_CURRENCY_CODE            :=  zx_global_structures_pkg.trx_line_dist_tbl.TRX_CURRENCY_CODE(l_trx_line_index);
        l_event_class_rec.PRECISION                    :=  zx_global_structures_pkg.trx_line_dist_tbl.PRECISION(l_trx_line_index);
        l_event_class_rec.CURRENCY_CONVERSION_TYPE     :=  zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_TYPE(l_trx_line_index);
        l_event_class_rec.CURRENCY_CONVERSION_RATE     :=  zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_RATE(l_trx_line_index);
        l_event_class_rec.CURRENCY_CONVERSION_DATE     :=  zx_global_structures_pkg.trx_line_dist_tbl.CURRENCY_CONVERSION_DATE(l_trx_line_index);
        l_event_class_rec.ROUNDING_SHIP_TO_PARTY_ID    :=  zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_SHIP_TO_PARTY_ID(l_trx_line_index);
        l_event_class_rec.ROUNDING_SHIP_FROM_PARTY_ID  :=  zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_SHIP_FROM_PARTY_ID(l_trx_line_index);
        l_event_class_rec.ROUNDING_BILL_TO_PARTY_ID    :=  zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_BILL_TO_PARTY_ID(l_trx_line_index);
        l_event_class_rec.ROUNDING_BILL_FROM_PARTY_ID  :=  zx_global_structures_pkg.trx_line_dist_tbl.ROUNDING_BILL_FROM_PARTY_ID(l_trx_line_index);
        l_event_class_rec.RNDG_SHIP_TO_PARTY_SITE_ID   :=  zx_global_structures_pkg.trx_line_dist_tbl.RNDG_SHIP_TO_PARTY_SITE_ID(l_trx_line_index);
        l_event_class_rec.RNDG_SHIP_FROM_PARTY_SITE_ID :=  zx_global_structures_pkg.trx_line_dist_tbl.RNDG_SHIP_FROM_PARTY_SITE_ID(l_trx_line_index);
        l_event_class_rec.RNDG_BILL_TO_PARTY_SITE_ID   :=  zx_global_structures_pkg.trx_line_dist_tbl.RNDG_BILL_TO_PARTY_SITE_ID(l_trx_line_index);
        l_event_class_rec.RNDG_BILL_FROM_PARTY_SITE_ID :=  zx_global_structures_pkg.trx_line_dist_tbl.RNDG_BILL_FROM_PARTY_SITE_ID(l_trx_line_index);
        l_event_class_rec.ESTABLISHMENT_ID             :=  zx_global_structures_pkg.trx_line_dist_tbl.ESTABLISHMENT_ID(l_trx_line_index);

        IF zx_global_structures_pkg.trx_line_dist_tbl.trx_currency_code(l_trx_line_index)is not NULL   AND
           zx_global_structures_pkg.trx_line_dist_tbl.precision(l_trx_line_index) is not NULL THEN
          l_event_class_rec.header_level_currency_flag := 'Y';
        END IF;

        zx_valid_init_params_pkg.determine_effective_date(l_event_class_rec,
                                                          l_effective_date,
                                                          l_return_status
                                                      );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	             G_PKG_NAME||': '||l_api_name||':zx_valid_init_params_pkg.determine_effective_date returned errors');
	          FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
              'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
          END IF;
          IF c_lines%ISOPEN THEN
            CLOSE c_lines;
          END IF;
          RETURN;
        END IF;

        IF l_legal_entity_id <> zx_global_structures_pkg.trx_line_dist_tbl.legal_entity_id(l_trx_line_index) THEN
          zx_valid_init_params_pkg.get_tax_subscriber(l_event_class_rec,
                                                      l_effective_date,
                                                      l_return_status
                                                     );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	        G_PKG_NAME||': '||l_api_name||':zx_valid_init_params_pkg.determine_effective_date returned errors');
	            FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
                'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
            END IF;
            IF c_lines%ISOPEN THEN
              CLOSE c_lines;
            END IF;
            RETURN;
          END IF;
        ELSE
          zx_security.g_effective_date := l_effective_date;
          zx_security.name_value('EFFECTIVEDATE',to_char(l_effective_date));
        END IF;

        zx_valid_init_params_pkg.get_tax_event_type
                                   (l_return_status
                                   ,l_event_class_rec.event_class_code
                                   ,l_event_class_rec.application_id
                                   ,l_event_class_rec.entity_code
                                   ,l_event_class_rec.event_type_code
                                   ,l_event_class_rec.tax_event_class_code
                                   ,l_event_class_rec.tax_event_type_code
                                   ,l_event_class_rec.doc_status_code
                                   );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	            G_PKG_NAME||': '||l_api_name||':zx_valid_init_params_pkg.get_tax_event_type returned errors');
	          FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
              'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
          END IF;
          IF c_lines%ISOPEN THEN
            CLOSE c_lines;
          END IF;
          RETURN;
        END IF;

        zx_global_structures_pkg.trx_line_dist_tbl.TAX_EVENT_TYPE_CODE(l_trx_line_index) :=
                                                    l_event_class_rec.tax_event_type_code;
        zx_global_structures_pkg.trx_line_dist_tbl.DOC_EVENT_STATUS(l_trx_line_index) :=
                                                    l_event_class_rec.doc_status_code;

        IF l_legal_entity_id <> zx_global_structures_pkg.trx_line_dist_tbl.legal_entity_id(l_trx_line_index) THEN
          zx_valid_init_params_pkg.populate_event_class_options(l_return_status,
                                              l_effective_date,
                                              l_event_class_rec
                                             );

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	               G_PKG_NAME||': '||l_api_name||':zx_valid_init_params_pkg.populate_event_class_options returned errors');
	            FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
                'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
            END IF;
            IF c_lines%ISOPEN THEN
              CLOSE c_lines;
            END IF;
            RETURN;
          END IF;
        END IF;

        zx_global_structures_pkg.g_event_class_rec := l_event_class_rec;

        ZX_TDS_CALC_SERVICES_PUB_PKG.initialize (l_event_class_rec ,
                                                 'HEADER',
                                                 l_return_status
                                                );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := l_return_status;
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	              G_PKG_NAME||': '||l_api_name||':ZX_TDS_CALC_SERVICES_PUB_PKG.initialize returned errors');
	          FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
                'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
          END IF;
          IF c_lines%ISOPEN THEN
            CLOSE c_lines;
          END IF;
          RETURN;
        END IF;

      END IF; -- End of Trx Id Change check

      IF l_flag = TRUE THEN
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.INTERNAL_ORG_LOCATION_ID(l_trx_line_index) := l_internal_org_location_id;
       ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl.TOTAL_INC_TAX_AMT(l_trx_line_index) := 0;
      ELSIF l_flag = FALSE THEN
       Pop_Index_Attrbs_To_Null ( p_index => l_trx_line_index,
                                  x_return_status => l_return_status);
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
              ' RETURN_STATUS = ' || x_return_status);
	         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	            G_PKG_NAME||': '||l_api_name||':ZX_NEW_SERVICES_PKG.Pop_Index_Attrbs_To_Null returned errors');
	         FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
              'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
         END IF;
         IF c_lines%ISOPEN THEN
            CLOSE c_lines;
         END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
      END IF;
      l_trx_id := zx_global_structures_pkg.trx_line_dist_tbl.trx_id(l_trx_line_index);
      l_legal_entity_id := zx_global_structures_pkg.trx_line_dist_tbl.legal_entity_id(l_trx_line_index);
      l_trx_date := zx_global_structures_pkg.trx_line_dist_tbl.trx_date(l_trx_line_index);
   END LOOP;

   EXIT WHEN c_lines%NOTFOUND;

  END LOOP;

  IF c_lines%ISOPEN THEN
    CLOSE c_lines;
  END IF;

   db_update_line_det_factors (p_trx_line_dist_tbl  => ZX_GLOBAL_STRUCTURES_PKG.trx_line_dist_tbl,
                               p_event_class_rec    => l_event_class_rec,
                               p_line_level_action  => p_line_level_action,
                               x_return_status      => l_return_status
                              );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     x_return_status := l_return_status;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
         ' RETURN_STATUS = ' || x_return_status);
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
	      G_PKG_NAME||': '||l_api_name||':ZX_NEW_SERVICES_PKG.db_update_line_det_factors returned errors');
       FND_LOG.STRING(g_level_statement, 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel.END',
             'ZX_NEW_SERVICES_PKG.update_det_factors_for_cancel(-)');
     END IF;
     RETURN;
   END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO update_det_factors_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       IF c_lines%ISOPEN THEN
         CLOSE c_lines;
       END IF;
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   =>      x_msg_count,
                                 p_data    =>      x_msg_data
                                );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_det_factors_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF c_lines%ISOPEN THEN
        CLOSE c_lines;
      END IF;
      FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   =>      x_msg_count,
                                p_data    =>      x_msg_data
                               );
      IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO update_det_factors_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF c_lines%ISOPEN THEN
        CLOSE c_lines;
      END IF;
      FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count       =>      x_msg_count,
                                p_data        =>      x_msg_data
                               );
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
 END update_det_factors_for_cancel;

/* =============================================================================*
 |  PUBLIC PROCEDURE CANCEL_TAX_LINES						                                |
 |  										                                                        |
 |  DESCRIPTION                                                                 |
 |   Payables would call this API for Discarding a Single Item Line             |
 |   or Cancelling a complete Invoice.
 |  										                                                        |
 * =============================================================================*/

PROCEDURE CANCEL_TAX_LINES(
   p_api_version           IN            NUMBER,
   p_init_msg_list         IN            VARCHAR2,
   p_commit                IN            VARCHAR2,
   p_validation_level      IN            NUMBER,
   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   p_transaction_rec       IN OUT NOCOPY ZX_API_PUB.transaction_rec_type,
   p_tax_only_line_flag    IN            VARCHAR2,
   p_trx_line_id           IN            NUMBER,
   p_trx_level_type        IN            VARCHAR2,
   p_line_level_action     IN            VARCHAR2
   )
IS

   l_api_name          CONSTANT  VARCHAR2(30) := 'CANCEL_TAX_LINES';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_return_status               VARCHAR2(30);
   l_event_class_rec             ZX_API_PUB.event_class_rec_type;
   l_init_msg_list               VARCHAR2(1);
   l_rec_nrec_dist_tbl           ZX_TRD_SERVICES_PUB_PKG.rec_nrec_dist_tbl_type;
   l_count                       NUMBER;
   l_upg_trx_info_rec            zx_on_fly_trx_upgrade_pkg.zx_upg_trx_info_rec_type;
   l_trx_migrated_b              BOOLEAN;
   l_summarization_flag          VARCHAR2(1);
   l_ret_summ_tax_line_id_flag   VARCHAR2(1);

   TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE var_tbl_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
   l_summary_tax_line_id_tbl      num_tbl_type;
   l_cancel_flag_tbl              var_tbl_type;
   l_tax_line_id_tbl              num_tbl_type;
   l_unrounded_tax_amt_tbl        num_tbl_type;
   l_tax_amt_tbl                  num_tbl_type;
   l_tax_amt_tax_curr_tbl         num_tbl_type;
   l_tax_amt_funcl_curr_tbl       num_tbl_type;
   l_tot_rec_amt_tbl              num_tbl_type;
   l_tot_rec_amt_tax_curr_tbl     num_tbl_type;
   l_tot_rec_amt_funcl_curr_tbl   num_tbl_type;
   l_tot_nrec_amt_tbl             num_tbl_type;
   l_tot_nrec_amt_tax_curr_tbl    num_tbl_type;
   l_tot_nrec_amt_funcl_curr_tbl  num_tbl_type;

 CURSOR get_event_class_info IS
 SELECT summarization_flag,
        retain_summ_tax_line_id_flag
   FROM zx_evnt_cls_mappings
  WHERE application_id = p_transaction_rec.application_id
    AND entity_code = p_transaction_rec.entity_code
    AND event_class_code = p_transaction_rec.event_class_code;

  CURSOR tot_dist_amt_trx IS
  SELECT sum(unrounded_rec_nrec_tax_amt),
         sum(rec_nrec_tax_amt),
         sum(rec_nrec_tax_amt_tax_curr),
         sum(rec_nrec_tax_amt_funcl_curr),
         tax_line_id
  FROM ZX_REC_NREC_DIST
  WHERE application_id = p_transaction_rec.application_id
    AND entity_code = p_transaction_rec.entity_code
    AND event_class_code = p_transaction_rec.event_class_code
    AND trx_id = p_transaction_rec.trx_id
  GROUP BY tax_line_id;

  CURSOR tot_dist_amt_trx_line IS
  SELECT sum(unrounded_rec_nrec_tax_amt),
         sum(rec_nrec_tax_amt),
         sum(rec_nrec_tax_amt_tax_curr),
         sum(rec_nrec_tax_amt_funcl_curr),
         tax_line_id
  FROM ZX_REC_NREC_DIST
  WHERE application_id = p_transaction_rec.application_id
    AND entity_code = p_transaction_rec.entity_code
    AND event_class_code = p_transaction_rec.event_class_code
    AND trx_id = p_transaction_rec.trx_id
    AND trx_line_id = p_trx_line_id
    AND trx_level_type = p_trx_level_type
  GROUP BY tax_line_id;

  CURSOR tot_tax_amt_trx IS
  SELECT sum(tax_amt),
         sum(tax_amt_tax_curr),
         sum(tax_amt_funcl_curr),
         sum(rec_tax_amt),
         sum(rec_tax_amt_tax_curr),
         sum(rec_tax_amt_funcl_curr),
         sum(nrec_tax_amt),
         sum(nrec_tax_amt_tax_curr),
         sum(nrec_tax_amt_funcl_curr),
         decode((count(*) - Sum(Decode(cancel_flag, 'Y', 1, 0))), 0, 'Y', NULL) cancel_flag,
         summary_tax_line_id
  FROM ZX_LINES
  WHERE application_id = p_transaction_rec.application_id
    AND entity_code = p_transaction_rec.entity_code
    AND event_class_code = p_transaction_rec.event_class_code
    AND trx_id = p_transaction_rec.trx_id
  GROUP BY summary_tax_line_id;

  CURSOR tot_tax_amt_trx_line IS
  SELECT sum(zxl.tax_amt),
         sum(zxl.tax_amt_tax_curr),
         sum(zxl.tax_amt_funcl_curr),
         sum(zxl.rec_tax_amt),
         sum(zxl.rec_tax_amt_tax_curr),
         sum(zxl.rec_tax_amt_funcl_curr),
         sum(zxl.nrec_tax_amt),
         sum(zxl.nrec_tax_amt_tax_curr),
         sum(zxl.nrec_tax_amt_funcl_curr),
         decode((count(*) - Sum(Decode(cancel_flag, 'Y', 1, 0))), 0, 'Y', NULL) cancel_flag,
         zxl.summary_tax_line_id
  FROM ZX_LINES zxl
  WHERE zxl.application_id = p_transaction_rec.application_id
    AND zxl.entity_code = p_transaction_rec.entity_code
    AND zxl.event_class_code = p_transaction_rec.event_class_code
    AND zxl.trx_id = p_transaction_rec.trx_id
    AND zxl.summary_tax_line_id IN (SELECT DISTINCT zd.summary_tax_line_id
                                    FROM ZX_LINES zd
				                            WHERE zd.application_id = zxl.application_id
				                            AND zd.entity_code = zxl.entity_code
				                            AND zd.event_class_code = zxl.event_class_code
				                            AND zd.trx_id = zxl.trx_id
				                            AND zd.application_id = p_transaction_rec.application_id
                                    AND zd.entity_code = p_transaction_rec.entity_code
                                    AND zd.event_class_code = p_transaction_rec.event_class_code
                                    AND zd.trx_id = p_transaction_rec.trx_id
                                    AND zd.trx_line_id = p_trx_line_id
                                    AND zd.trx_level_type = p_trx_level_type
                                    )
  GROUP BY summary_tax_line_id;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_NEW_SERVICES_PKG: '||l_api_name||'()+');
   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
           'Application id: ' || p_transaction_rec.application_id ||
           'Entity_code: ' || p_transaction_rec.entity_code ||
           'Event_class_code: ' || p_transaction_rec.event_class_code ||
           'Trx_id: ' || p_transaction_rec.trx_id ||
           'Trx_line_id: ' || p_trx_line_id ||
           'Trx_level_type: ' || p_trx_level_type ||
           'Line_level_action: ' || p_line_level_action ||
           'Tax_only_line_flag: ' || p_tax_only_line_flag);
   END IF;


   /*--------------------------------------------------+
    |   Standard start of API savepoint                |
    +--------------------------------------------------*/
    SAVEPOINT cancel_tax_lines_PVT;

    /*--------------------------------------------------+
     |   Standard call to check for call compatibility  |
     +--------------------------------------------------*/
     IF NOT FND_API.Compatible_API_Call( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME
                                         ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
      IF p_init_msg_list is null THEN
        l_init_msg_list := FND_API.G_FALSE;
      ELSE
	      l_init_msg_list := p_init_msg_list;
      END IF;

      IF FND_API.to_Boolean(l_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      /*-----------------------------------------+
       |   Initialize return status to SUCCESS   |
       +-----------------------------------------*/
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       /*-----------------------------------------+
        |   Populate Global Variable              |
        +-----------------------------------------*/
        ZX_API_PUB.G_PUB_SRVC := l_api_name;
        ZX_API_PUB.G_DATA_TRANSFER_MODE := 'TAB';
        ZX_API_PUB.G_EXTERNAL_API_CALL  := 'N';

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,
             'Data Transfer Mode: '||ZX_API_PUB.G_DATA_TRANSFER_MODE);
        END IF;

        OPEN  get_event_class_info;
        FETCH get_event_class_info INTO
              l_summarization_flag,
              l_ret_summ_tax_line_id_flag;

        IF get_event_class_info%NOTFOUND THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF get_event_class_info%ISOPEN THEN
            CLOSE get_event_class_info;
          END IF;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.STRING(G_LEVEL_STATEMENT,
                     G_MODULE_NAME || l_api_name,
                     G_PKG_NAME||':'||l_api_name||': Event Class Info not retreived');
             FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
                    'RETURN_STATUS = ' || x_return_status);
             FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines.END',
                    'ZX_NEW_SERVICES_PKG.cancel_tax_lines(-)');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        CLOSE get_event_class_info;

        -- Call on the fly API in case no data exists in zx repository.
        l_upg_trx_info_rec.application_id := p_transaction_rec.application_id;
        l_upg_trx_info_rec.event_class_code := p_transaction_rec.event_class_code;
        l_upg_trx_info_rec.entity_code := p_transaction_rec.entity_code;
        l_upg_trx_info_rec.trx_id := p_transaction_rec.trx_id;
        l_upg_trx_info_rec.trx_line_id := p_trx_line_id;
        l_upg_trx_info_rec.trx_level_type := p_trx_level_type;

        ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
          p_upg_trx_info_rec  => l_upg_trx_info_rec,
          x_trx_migrated_b    => l_trx_migrated_b,
          x_return_status     => l_return_status );

        IF NOT l_trx_migrated_b THEN

          ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly(
            p_upg_trx_info_rec  => l_upg_trx_info_rec,
            x_return_status     => l_return_status );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            IF (g_level_statement >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
                 'Incorrect return_status after calling ' ||
                 ' ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly');
               FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
                 'RETURN_STATUS = ' || x_return_status);
               FND_LOG.STRING(g_level_statement,
                 'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines.END',
                 'ZX_NEW_SERVICES_PKG.cancel_tax_lines(-)');
            END IF;
            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
          END IF;
        END IF;

        -- Check if data exists in zx_lines_det_factors after
        -- on the fly upgrade, if not return control to payables
        -- as no tax impacts here
        ZX_ON_FLY_TRX_UPGRADE_PKG.is_trx_migrated(
          p_upg_trx_info_rec  => l_upg_trx_info_rec,
          x_trx_migrated_b    => l_trx_migrated_b,
          x_return_status     => l_return_status );

        IF NOT l_trx_migrated_b THEN
          IF (g_level_statement >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_statement,
              'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines.END',
              'New Item Line with no tax impacts in Payables, no action required');
            FND_LOG.STRING(g_level_statement,
              'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines.END',
              'ZX_NEW_SERVICES_PKG.cancel_tax_lines(-)');
          END IF;
          RETURN;
        END IF;

        SELECT COUNT(*)
        INTO l_count
        FROM ZX_REVERSE_DIST_GT;

        -- If distributions exists
        IF l_count <> 0 THEN
          -- Discard flow for a single item line
          IF p_trx_line_id IS NOT NULL THEN

            -- Reverse the tax distributions, Payables needs to populate
            -- zx_reverse_dist_gt for this case.
            ZX_TRD_SERVICES_PUB_PKG.REVERSE_DISTRIBUTIONS(x_return_status => l_return_status);

            IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
              x_return_status := l_return_status;
              IF (g_level_unexpected >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
                       'Incorrect return_status after calling ' ||
                       'ZX_TRD_SERVICES_PUB_PKG.REVERSE_DISTRIBUTIONS');
                FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
                       'RETURN_STATUS = ' || x_return_status);
                FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines.END',
                       'ZX_NEW_SERVICES_PKG.cancel_tax_lines(-)');
              END IF;
              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
              ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;

            IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'Set the freeze_flag for the distributions');
            END IF;

            -- Update the freeze flag on the distributions
            UPDATE ZX_REC_NREC_DIST
            SET FREEZE_FLAG = 'Y'
            WHERE APPLICATION_ID = p_transaction_rec.application_id
            AND ENTITY_CODE = p_transaction_rec.entity_code
            AND EVENT_CLASS_CODE = p_transaction_rec.event_class_code
            AND TRX_ID = p_transaction_rec.trx_id
            AND TRX_LINE_ID = p_trx_line_id
            AND TRX_LEVEL_TYPE = p_trx_level_type;

            IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'No Of Rows Updated: ' || sql%rowcount);
            END IF;

            IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'OPEN tot_dist_amt_trx_line');
            END IF;

            -- Set the tax amounts accordingly
            OPEN tot_dist_amt_trx_line;
            LOOP
            FETCH tot_dist_amt_trx_line BULK COLLECT INTO
            l_unrounded_tax_amt_tbl,
            l_tax_amt_tbl,
            l_tax_amt_tax_curr_tbl,
            l_tax_amt_funcl_curr_tbl,
            l_tax_line_id_tbl
            LIMIT G_LINES_PER_FETCH;

            FOR i IN l_tax_line_id_tbl.FIRST .. l_tax_line_id_tbl.LAST LOOP
              UPDATE ZX_LINES
              SET ORIG_TAXABLE_AMT          = NVL(orig_taxable_amt, taxable_amt),
                  ORIG_TAXABLE_AMT_TAX_CURR = NVL(orig_taxable_amt_tax_curr, taxable_amt_tax_curr),
                  ORIG_TAX_AMT              = NVL(orig_tax_amt, tax_amt),
                  ORIG_TAX_AMT_TAX_CURR     = NVL(orig_tax_amt_tax_curr, tax_amt_tax_curr),
                  UNROUNDED_TAX_AMT         = l_unrounded_tax_amt_tbl(i),
                  UNROUNDED_TAXABLE_AMT     = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, UNROUNDED_TAXABLE_AMT),
                  TAX_AMT                   = l_tax_amt_tbl(i),
                  TAX_AMT_TAX_CURR          = l_tax_amt_tax_curr_tbl(i),
                  TAX_AMT_FUNCL_CURR        = l_tax_amt_funcl_curr_tbl(i),
                  TAXABLE_AMT               = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT),
                  TAXABLE_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT_TAX_CURR),
                  TAXABLE_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT_FUNCL_CURR),
                  CAL_TAX_AMT               = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), CAL_TAX_AMT),
                  CAL_TAX_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), CAL_TAX_AMT_TAX_CURR),
                  CAL_TAX_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), CAL_TAX_AMT_FUNCL_CURR),
                  REC_TAX_AMT               = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), REC_TAX_AMT),
                  REC_TAX_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), REC_TAX_AMT_TAX_CURR),
                  REC_TAX_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), REC_TAX_AMT_FUNCL_CURR),
                  NREC_TAX_AMT              = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), NREC_TAX_AMT),
                  NREC_TAX_AMT_TAX_CURR     = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), NREC_TAX_AMT_TAX_cURR),
                  NREC_TAX_AMT_FUNCL_CURR   = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), NREC_TAX_AMT_FUNCL_CURR),
                  ASSOCIATED_CHILD_FROZEN_FLAG = 'Y',
                  PROCESS_FOR_RECOVERY_FLAG = 'N',
                  SYNC_WITH_PRVDR_FLAG      = DECODE(TAX_PROVIDER_ID, NULL, SYNC_WITH_PRVDR_FLAG, 'Y'),
                  CANCEL_FLAG               = 'Y',
                  TAX_HOLD_CODE             = NULL,
                  TAX_HOLD_RELEASED_CODE    = NULL,
                  PRD_TOTAL_TAX_AMT         = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT),
                  PRD_TOTAL_TAX_AMT_TAX_CURR = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT_TAX_CURR),
                  PRD_TOTAL_TAX_AMT_FUNCL_CURR = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT_FUNCL_CURR),
                  TRX_LINE_INDEX            = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, TRX_LINE_INDEX),
                  OFFSET_TAX_RATE_CODE      = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, OFFSET_TAX_RATE_CODE),
                  PRORATION_CODE            = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRORATION_CODE),
                  OTHER_DOC_SOURCE          = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, OTHER_DOC_SOURCE)
             WHERE APPLICATION_ID    = p_transaction_rec.application_id
             AND ENTITY_CODE       = p_transaction_rec.entity_code
             AND EVENT_CLASS_CODE  = p_transaction_rec.event_class_code
             AND TRX_ID            = p_transaction_rec.trx_id
             AND TRX_LINE_ID       = p_trx_line_id
             AND TRX_LEVEL_TYPE    = p_trx_level_type
             AND TAX_LINE_ID       = l_tax_line_id_tbl(i)
             AND NVL(TAX_ONLY_LINE_FLAG,'N') <> 'Y';
           END LOOP;
           EXIT WHEN tot_dist_amt_trx_line%NOTFOUND;
         END LOOP;
         IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'CLOSE tot_dist_amt_trx_line');
         END IF;
         CLOSE tot_dist_amt_trx_line;

         IF l_summarization_flag = 'Y' THEN
           IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'OPEN tot_tax_amt_trx_line');
           END IF;
           OPEN tot_tax_amt_trx_line;
           LOOP
           FETCH tot_tax_amt_trx_line BULK COLLECT INTO
           l_tax_amt_tbl,
           l_tax_amt_tax_curr_tbl,
           l_tax_amt_funcl_curr_tbl,
           l_tot_rec_amt_tbl,
           l_tot_rec_amt_tax_curr_tbl,
           l_tot_rec_amt_funcl_curr_tbl,
           l_tot_nrec_amt_tbl,
           l_tot_nrec_amt_tax_curr_tbl,
           l_tot_nrec_amt_funcl_curr_tbl,
           l_cancel_flag_tbl,
           l_summary_tax_line_id_tbl
           LIMIT G_LINES_PER_FETCH;

           FOR i IN l_summary_tax_line_id_tbl.FIRST .. l_summary_tax_line_id_tbl.LAST LOOP
	           IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'l_tax_amt_tbl(i): ' || l_tax_amt_tbl(i) || ',' ||
		            'l_summary_tax_line_id_tbl(i): ' || l_summary_tax_line_id_tbl(i));
             END IF;

             UPDATE ZX_LINES_SUMMARY
             SET TAX_AMT                       = l_tax_amt_tbl(i),
                 TAX_AMT_TAX_CURR              = l_tax_amt_tax_curr_tbl(i),
                 TAX_AMT_FUNCL_CURR            = l_tax_amt_funcl_curr_tbl(i),
                 TOTAL_REC_TAX_AMT             = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_tbl(i), TOTAL_REC_TAX_AMT),
                 TOTAL_REC_TAX_AMT_FUNCL_CURR  = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_funcl_curr_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_funcl_curr_tbl(i), TOTAL_REC_TAX_AMT_FUNCL_CURR),
                 TOTAL_NREC_TAX_AMT            = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_tbl(i), TOTAL_NREC_TAX_AMT),
                 TOTAL_NREC_TAX_AMT_FUNCL_CURR = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_funcl_curr_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_funcl_curr_tbl(i), TOTAL_NREC_TAX_AMT_FUNCL_CURR),
                 TOTAL_REC_TAX_AMT_TAX_CURR    = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_tax_curr_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_tax_curr_tbl(i), TOTAL_REC_TAX_AMT_TAX_CURR),
                 TOTAL_NREC_TAX_AMT_TAX_CURR   = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_tax_curr_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_tax_curr_tbl(i), TOTAL_NREC_TAX_AMT_TAX_CURR),
                 CANCEL_FLAG                   = l_cancel_flag_tbl(i)
             WHERE APPLICATION_ID    = p_transaction_rec.application_id
             AND ENTITY_CODE         = p_transaction_rec.entity_code
             AND EVENT_CLASS_CODE    = p_transaction_rec.event_class_code
             AND TRX_ID              = p_transaction_rec.trx_id
             AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id_tbl(i)
             AND NVL(TAX_ONLY_LINE_FLAG,'N') <> 'Y';
           END LOOP;
           EXIT WHEN tot_tax_amt_trx_line%NOTFOUND;
          END LOOP;
          CLOSE tot_tax_amt_trx_line;
         END IF; --l_summarization_flag = 'Y'
       -- Cancel flow for the entire Invoice
       ELSE

         -- Reverse the tax distributions, Payables needs to populate
         -- zx_reverse_dist_gt for this case.
         ZX_TRD_SERVICES_PUB_PKG.REVERSE_DISTRIBUTIONS(x_return_status => l_return_status);

         IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
           x_return_status := l_return_status;
           IF (g_level_unexpected >= g_current_runtime_level ) THEN
             FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
                    'Incorrect return_status after calling ' ||
                    'ZX_TRD_SERVICES_PUB_PKG.REVERSE_DISTRIBUTIONS');
             FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
                    'RETURN_STATUS = ' || x_return_status);
             FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines.END',
                    'ZX_NEW_SERVICES_PKG.cancel_tax_lines(-)');
           END IF;
           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
           ELSE
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
         END IF;

         -- Update the freeze flag for the entire invoice
         UPDATE ZX_REC_NREC_DIST
         SET FREEZE_FLAG = 'Y'
         WHERE APPLICATION_ID = p_transaction_rec.application_id
         AND ENTITY_CODE = p_transaction_rec.entity_code
         AND EVENT_CLASS_CODE = p_transaction_rec.event_class_code
         AND TRX_ID = p_transaction_rec.trx_id;

         IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
             'No Of Rows Updated: ' || sql%rowcount);
         END IF;

         -- set the tax amounts accordingly
         OPEN tot_dist_amt_trx;
            LOOP
            FETCH tot_dist_amt_trx BULK COLLECT INTO
            l_unrounded_tax_amt_tbl,
            l_tax_amt_tbl,
            l_tax_amt_tax_curr_tbl,
            l_tax_amt_funcl_curr_tbl,
            l_tax_line_id_tbl
            LIMIT G_LINES_PER_FETCH;

            FOR i IN l_tax_line_id_tbl.FIRST .. l_tax_line_id_tbl.LAST LOOP
              UPDATE ZX_LINES
              SET ORIG_TAXABLE_AMT          = NVL(orig_taxable_amt, taxable_amt),
                  ORIG_TAXABLE_AMT_TAX_CURR = NVL(orig_taxable_amt_tax_curr, taxable_amt_tax_curr),
                  ORIG_TAX_AMT              = NVL(orig_tax_amt, tax_amt),
                  ORIG_TAX_AMT_TAX_CURR     = NVL(orig_tax_amt_tax_curr, tax_amt_tax_curr),
                  UNROUNDED_TAX_AMT         = l_unrounded_tax_amt_tbl(i),
                  UNROUNDED_TAXABLE_AMT     = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, UNROUNDED_TAXABLE_AMT),
                  TAX_AMT                   = l_tax_amt_tbl(i),
                  TAX_AMT_TAX_CURR          = l_tax_amt_tax_curr_tbl(i),
                  TAX_AMT_FUNCL_CURR        = l_tax_amt_funcl_curr_tbl(i),
                  TAXABLE_AMT               = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT),
                  TAXABLE_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT_TAX_CURR),
                  TAXABLE_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT_FUNCL_CURR),
                  CAL_TAX_AMT               = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), CAL_TAX_AMT),
                  CAL_TAX_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), CAL_TAX_AMT_TAX_CURR),
                  CAL_TAX_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), CAL_TAX_AMT_FUNCL_CURR),
                  REC_TAX_AMT               = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), REC_TAX_AMT),
                  REC_TAX_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), REC_TAX_AMT_TAX_CURR),
                  REC_TAX_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), REC_TAX_AMT_FUNCL_CURR),
                  NREC_TAX_AMT              = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), NREC_TAX_AMT),
                  NREC_TAX_AMT_TAX_CURR     = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), NREC_TAX_AMT_TAX_cURR),
                  NREC_TAX_AMT_FUNCL_CURR   = DECODE(p_line_level_action, 'DISCARD', l_tax_amt_tbl(i), 'UNAPPLY_FROM', l_tax_amt_tbl(i), NREC_TAX_AMT_FUNCL_CURR),
                  PROCESS_FOR_RECOVERY_FLAG = 'N',
                  ASSOCIATED_CHILD_FROZEN_FLAG = 'Y',
                  SYNC_WITH_PRVDR_FLAG      = DECODE(TAX_PROVIDER_ID, NULL, SYNC_WITH_PRVDR_FLAG, 'Y'),
                  CANCEL_FLAG               = 'Y',
                  TAX_HOLD_CODE             = NULL,
                  TAX_HOLD_RELEASED_CODE    = NULL,
                  PRD_TOTAL_TAX_AMT         = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT),
                  PRD_TOTAL_TAX_AMT_TAX_CURR = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT_TAX_CURR),
                  PRD_TOTAL_TAX_AMT_FUNCL_CURR = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT_FUNCL_CURR),
                  TRX_LINE_INDEX            = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, TRX_LINE_INDEX),
                  OFFSET_TAX_RATE_CODE      = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, OFFSET_TAX_RATE_CODE),
                  PRORATION_CODE            = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRORATION_CODE),
                  OTHER_DOC_SOURCE          = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, OTHER_DOC_SOURCE)
             WHERE APPLICATION_ID    = p_transaction_rec.application_id
             AND ENTITY_CODE       = p_transaction_rec.entity_code
             AND EVENT_CLASS_CODE  = p_transaction_rec.event_class_code
             AND TRX_ID            = p_transaction_rec.trx_id
             AND TAX_LINE_ID       = l_tax_line_id_tbl(i)
             AND NVL(TAX_ONLY_LINE_FLAG,'N') <> 'Y';
           END LOOP;
           EXIT WHEN tot_dist_amt_trx%NOTFOUND;
         END LOOP;
         CLOSE tot_dist_amt_trx;

         IF l_summarization_flag = 'Y' THEN
           OPEN tot_tax_amt_trx;
            LOOP
            FETCH tot_tax_amt_trx BULK COLLECT INTO
            l_tax_amt_tbl,
            l_tax_amt_tax_curr_tbl,
            l_tax_amt_funcl_curr_tbl,
            l_tot_rec_amt_tbl,
            l_tot_rec_amt_tax_curr_tbl,
            l_tot_rec_amt_funcl_curr_tbl,
            l_tot_nrec_amt_tbl,
            l_tot_nrec_amt_tax_curr_tbl,
            l_tot_nrec_amt_funcl_curr_tbl,
            l_cancel_flag_tbl,
            l_summary_tax_line_id_tbl
            LIMIT G_LINES_PER_FETCH;

            FOR i IN l_summary_tax_line_id_tbl.FIRST .. l_summary_tax_line_id_tbl.LAST LOOP
              UPDATE ZX_LINES_SUMMARY
              SET TAX_AMT                       = l_tax_amt_tbl(i),
                  TAX_AMT_TAX_CURR              = l_tax_amt_tax_curr_tbl(i),
                  TAX_AMT_FUNCL_CURR            = l_tax_amt_funcl_curr_tbl(i),
                  TOTAL_REC_TAX_AMT             = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_tbl(i), TOTAL_REC_TAX_AMT),
                  TOTAL_REC_TAX_AMT_FUNCL_CURR  = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_funcl_curr_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_funcl_curr_tbl(i), TOTAL_REC_TAX_AMT_FUNCL_CURR),
                  TOTAL_NREC_TAX_AMT            = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_tbl(i), TOTAL_NREC_TAX_AMT),
                  TOTAL_NREC_TAX_AMT_FUNCL_CURR = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_funcl_curr_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_funcl_curr_tbl(i), TOTAL_NREC_TAX_AMT_FUNCL_CURR),
                  TOTAL_REC_TAX_AMT_TAX_CURR    = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_tax_curr_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_tax_curr_tbl(i), TOTAL_REC_TAX_AMT_TAX_CURR),
                  TOTAL_NREC_TAX_AMT_TAX_CURR   = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_tax_curr_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_tax_curr_tbl(i), TOTAL_NREC_TAX_AMT_TAX_CURR),
                  CANCEL_FLAG                   = l_cancel_flag_tbl(i)
             WHERE APPLICATION_ID    = p_transaction_rec.application_id
             AND ENTITY_CODE         = p_transaction_rec.entity_code
             AND EVENT_CLASS_CODE    = p_transaction_rec.event_class_code
             AND TRX_ID              = p_transaction_rec.trx_id
             AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id_tbl(i)
             AND NVL(TAX_ONLY_LINE_FLAG,'N') <> 'Y';
            END LOOP;
            EXIT WHEN tot_tax_amt_trx%NOTFOUND;
           END LOOP;
           CLOSE tot_tax_amt_trx;
         END IF; -- l_summarization_flag = 'Y'
       END IF;
    -- If no distributions exists
    ELSE
      -- Discard flow for Single item line.
      IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'If no distributions exists, Discard flow for Single item line.' || p_trx_line_id);
      END IF;
      IF p_trx_line_id IS NOT NULL THEN
        UPDATE ZX_LINES
        SET ORIG_TAXABLE_AMT          = NVL(orig_taxable_amt, taxable_amt),
            ORIG_TAXABLE_AMT_TAX_CURR = NVL(orig_taxable_amt_tax_curr, taxable_amt_tax_curr),
            ORIG_TAX_AMT              = NVL(orig_tax_amt, tax_amt),
            ORIG_TAX_AMT_TAX_CURR     = NVL(orig_tax_amt_tax_curr, tax_amt_tax_curr),
            UNROUNDED_TAX_AMT         = 0,
            UNROUNDED_TAXABLE_AMT     = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, UNROUNDED_TAXABLE_AMT),
            TAX_AMT                   = 0,
            TAX_AMT_TAX_CURR          = 0,
            TAX_AMT_FUNCL_CURR        = 0,
            TAXABLE_AMT               = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT),
            TAXABLE_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT_TAX_CURR),
            TAXABLE_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT_FUNCL_CURR),
            CAL_TAX_AMT               = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, CAL_TAX_AMT),
            CAL_TAX_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, CAL_TAX_AMT_TAX_CURR),
            CAL_TAX_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, CAL_TAX_AMT_FUNCL_CURR),
            REC_TAX_AMT               = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, REC_TAX_AMT),
            REC_TAX_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, REC_TAX_AMT_TAX_CURR),
            REC_TAX_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, REC_TAX_AMT_FUNCL_CURR),
            NREC_TAX_AMT              = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, NREC_TAX_AMT),
            NREC_TAX_AMT_TAX_CURR     = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, NREC_TAX_AMT_TAX_cURR),
            NREC_TAX_AMT_FUNCL_CURR   = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, NREC_TAX_AMT_FUNCL_CURR),
            PROCESS_FOR_RECOVERY_FLAG = 'N',
            SYNC_WITH_PRVDR_FLAG      = DECODE(TAX_PROVIDER_ID, NULL, SYNC_WITH_PRVDR_FLAG, 'Y'),
            CANCEL_FLAG               = 'Y',
            TAX_HOLD_CODE             = NULL,
            TAX_HOLD_RELEASED_CODE    = NULL,
            PRD_TOTAL_TAX_AMT         = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT),
            PRD_TOTAL_TAX_AMT_TAX_CURR = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT_TAX_CURR),
            PRD_TOTAL_TAX_AMT_FUNCL_CURR = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT_FUNCL_CURR),
            TRX_LINE_INDEX            = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, TRX_LINE_INDEX),
            OFFSET_TAX_RATE_CODE      = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, OFFSET_TAX_RATE_CODE),
            PRORATION_CODE            = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRORATION_CODE),
            OTHER_DOC_SOURCE          = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, OTHER_DOC_SOURCE)
        WHERE APPLICATION_ID    = p_transaction_rec.application_id
        AND ENTITY_CODE       = p_transaction_rec.entity_code
        AND EVENT_CLASS_CODE  = p_transaction_rec.event_class_code
        AND TRX_ID            = p_transaction_rec.trx_id
        AND TRX_LINE_ID       = p_trx_line_id
        AND TRX_LEVEL_TYPE    = p_trx_level_type
        AND NVL(TAX_ONLY_LINE_FLAG,'N') <> 'Y';

        IF l_summarization_flag = 'Y' THEN
          IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                'OPEN tot_tax_amt_trx_line');
          END IF;
          OPEN tot_tax_amt_trx_line;
          LOOP
          FETCH tot_tax_amt_trx_line BULK COLLECT INTO
          l_tax_amt_tbl,
          l_tax_amt_tax_curr_tbl,
          l_tax_amt_funcl_curr_tbl,
          l_tot_rec_amt_tbl,
          l_tot_rec_amt_tax_curr_tbl,
          l_tot_rec_amt_funcl_curr_tbl,
          l_tot_nrec_amt_tbl,
          l_tot_nrec_amt_tax_curr_tbl,
          l_tot_nrec_amt_funcl_curr_tbl,
          l_cancel_flag_tbl,
          l_summary_tax_line_id_tbl
          LIMIT G_LINES_PER_FETCH;

          FOR i IN l_summary_tax_line_id_tbl.FIRST .. l_summary_tax_line_id_tbl.LAST LOOP
            UPDATE ZX_LINES_SUMMARY
            SET TAX_AMT                       = l_tax_amt_tbl(i),
                TAX_AMT_TAX_CURR              = l_tax_amt_tax_curr_tbl(i),
                TAX_AMT_FUNCL_CURR            = l_tax_amt_funcl_curr_tbl(i),
                TOTAL_REC_TAX_AMT             = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_tbl(i), TOTAL_REC_TAX_AMT),
                TOTAL_REC_TAX_AMT_FUNCL_CURR  = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_funcl_curr_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_funcl_curr_tbl(i), TOTAL_REC_TAX_AMT_FUNCL_CURR),
                TOTAL_NREC_TAX_AMT            = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_tbl(i), TOTAL_NREC_TAX_AMT),
                TOTAL_NREC_TAX_AMT_FUNCL_CURR = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_funcl_curr_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_funcl_curr_tbl(i), TOTAL_NREC_TAX_AMT_FUNCL_CURR),
                TOTAL_REC_TAX_AMT_TAX_CURR    = DECODE(p_line_level_action, 'DISCARD', l_tot_rec_amt_tax_curr_tbl(i), 'UNAPPLY_FROM', l_tot_rec_amt_tax_curr_tbl(i), TOTAL_REC_TAX_AMT_TAX_CURR),
                TOTAL_NREC_TAX_AMT_TAX_CURR   = DECODE(p_line_level_action, 'DISCARD', l_tot_nrec_amt_tax_curr_tbl(i), 'UNAPPLY_FROM', l_tot_nrec_amt_tax_curr_tbl(i), TOTAL_NREC_TAX_AMT_TAX_CURR),
                CANCEL_FLAG                   = l_cancel_flag_tbl(i)
            WHERE APPLICATION_ID    = p_transaction_rec.application_id
            AND ENTITY_CODE         = p_transaction_rec.entity_code
            AND EVENT_CLASS_CODE    = p_transaction_rec.event_class_code
            AND TRX_ID              = p_transaction_rec.trx_id
            AND SUMMARY_TAX_LINE_ID = l_summary_tax_line_id_tbl(i)
            AND NVL(TAX_ONLY_LINE_FLAG,'N') <> 'Y';
          END LOOP;
          EXIT WHEN tot_tax_amt_trx_line%NOTFOUND;
         END LOOP;
         CLOSE tot_tax_amt_trx_line;
        END IF; --l_summarization_flag = 'Y'

      -- Cancel flow for entire Invoice.
      ELSE
        UPDATE ZX_LINES
        SET ORIG_TAXABLE_AMT          = NVL(orig_taxable_amt, taxable_amt),
            ORIG_TAXABLE_AMT_TAX_CURR = NVL(orig_taxable_amt_tax_curr, taxable_amt_tax_curr),
            ORIG_TAX_AMT              = NVL(orig_tax_amt, tax_amt),
            ORIG_TAX_AMT_TAX_CURR     = NVL(orig_tax_amt_tax_curr, tax_amt_tax_curr),
            UNROUNDED_TAX_AMT         = 0,
            UNROUNDED_TAXABLE_AMT     = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, UNROUNDED_TAXABLE_AMT),
            TAX_AMT                   = 0,
            TAX_AMT_TAX_CURR          = 0,
            TAX_AMT_FUNCL_CURR        = 0,
            TAXABLE_AMT               = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT),
            TAXABLE_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT_TAX_CURR),
            TAXABLE_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TAXABLE_AMT_FUNCL_CURR),
            CAL_TAX_AMT               = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, CAL_TAX_AMT),
            CAL_TAX_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, CAL_TAX_AMT_TAX_CURR),
            CAL_TAX_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, CAL_TAX_AMT_FUNCL_CURR),
            REC_TAX_AMT               = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, REC_TAX_AMT),
            REC_TAX_AMT_TAX_CURR      = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, REC_TAX_AMT_TAX_CURR),
            REC_TAX_AMT_FUNCL_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, REC_TAX_AMT_FUNCL_CURR),
            NREC_TAX_AMT              = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, NREC_TAX_AMT),
            NREC_TAX_AMT_TAX_CURR     = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, NREC_TAX_AMT_TAX_cURR),
            NREC_TAX_AMT_FUNCL_CURR   = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, NREC_TAX_AMT_FUNCL_CURR),
            PROCESS_FOR_RECOVERY_FLAG = 'N',
            SYNC_WITH_PRVDR_FLAG      = DECODE(TAX_PROVIDER_ID, NULL, SYNC_WITH_PRVDR_FLAG, 'Y'),
            CANCEL_FLAG               = 'Y',
            TAX_HOLD_CODE             = NULL,
            TAX_HOLD_RELEASED_CODE    = NULL,
            PRD_TOTAL_TAX_AMT         = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT),
            PRD_TOTAL_TAX_AMT_TAX_CURR = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT_TAX_CURR),
            PRD_TOTAL_TAX_AMT_FUNCL_CURR = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRD_TOTAL_TAX_AMT_FUNCL_CURR),
            TRX_LINE_INDEX            = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, TRX_LINE_INDEX),
            OFFSET_TAX_RATE_CODE      = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, OFFSET_TAX_RATE_CODE),
            PRORATION_CODE            = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, PRORATION_CODE),
            OTHER_DOC_SOURCE          = DECODE(p_line_level_action, 'DISCARD', NULL, 'UNAPPLY_FROM', NULL, OTHER_DOC_SOURCE)
        WHERE APPLICATION_ID    = p_transaction_rec.application_id
        AND ENTITY_CODE       = p_transaction_rec.entity_code
        AND EVENT_CLASS_CODE  = p_transaction_rec.event_class_code
        AND TRX_ID            = p_transaction_rec.trx_id
        AND NVL(TAX_ONLY_LINE_FLAG,'N') <> 'Y';

        IF l_summarization_flag = 'Y' THEN
          UPDATE ZX_LINES_SUMMARY
          SET TAX_AMT                       = 0,
              TAX_AMT_TAX_CURR              = 0,
              TAX_AMT_FUNCL_CURR            = 0,
              TOTAL_REC_TAX_AMT             = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TOTAL_REC_TAX_AMT),
              TOTAL_REC_TAX_AMT_FUNCL_CURR  = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TOTAL_REC_TAX_AMT_FUNCL_CURR),
              TOTAL_NREC_TAX_AMT            = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TOTAL_NREC_TAX_AMT),
              TOTAL_NREC_TAX_AMT_FUNCL_CURR = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TOTAL_NREC_TAX_AMT_FUNCL_CURR),
              TOTAL_REC_TAX_AMT_TAX_CURR    = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TOTAL_REC_TAX_AMT_TAX_CURR),
              TOTAL_NREC_TAX_AMT_TAX_CURR   = DECODE(p_line_level_action, 'DISCARD', 0, 'UNAPPLY_FROM', 0, TOTAL_NREC_TAX_AMT_TAX_CURR)
          WHERE APPLICATION_ID    = p_transaction_rec.application_id
          AND ENTITY_CODE         = p_transaction_rec.entity_code
          AND EVENT_CLASS_CODE    = p_transaction_rec.event_class_code
          AND TRX_ID              = p_transaction_rec.trx_id
          AND NVL(TAX_ONLY_LINE_FLAG,'N') <> 'Y';
        END IF; --l_summarization_flag = 'Y'
      END IF; --IF p_trx_line_id IS NOT NULL THEN
    END IF; --l_count <> 0

    -- Discard Tax Only Lines if any for the complete invoice alone
    -- Assuming that tax only lines cannot be discarded individually.
    IF p_tax_only_line_flag = 'Y' AND p_trx_line_id IS NULL THEN

      ZX_API_PUB.discard_tax_only_lines
               ( p_api_version      => p_api_version,
                 p_init_msg_list    => p_init_msg_list,
                 p_commit           => p_commit,
                 p_validation_level => p_validation_level,
                 x_return_status    => l_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data,
                 p_transaction_rec  => p_transaction_rec
               );
      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
          x_return_status := l_return_status;
          IF (g_level_unexpected >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_NEW_SERVICES_PKG.CANCEL_TAX_LINES',
                   'Incorrect return_status after calling ' ||
                   'ZX_API_PUB.discard_tax_only_lines');
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
                   'RETURN_STATUS = ' || x_return_status);
            FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines.END',
                   'ZX_NEW_SERVICES_PKG.cancel_tax_lines(-)');
          END IF;
          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END IF;
    END IF;

    -- Call update_det_factors_for_cancel
    update_det_factors_for_cancel
              (x_return_status         => x_return_status,
               x_msg_count             => x_msg_count,
               x_msg_data              => x_msg_data,
               p_event_class_rec       => l_event_class_rec,
               p_transaction_rec       => p_transaction_rec,
               p_trx_line_id           => p_trx_line_id,
               p_trx_level_type        => p_trx_level_type,
               p_line_level_action     => p_line_level_action
              );

    -- Call Global Document Update
    ZX_API_PUB.Global_document_update
               ( p_api_version         => p_api_version,
                 p_init_msg_list       => p_init_msg_list,
                 p_commit              => p_commit,
                 p_validation_level    => p_validation_level,
                 x_return_status       => x_return_status,
                 x_msg_count           => x_msg_count,
                 x_msg_data            => x_msg_data,
                 p_transaction_rec     => p_transaction_rec
               );
    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      x_return_status := l_return_status;
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_NEW_SERVICES_PKG.CANCEL_TAX_LINES',
               'Incorrect return_status after calling ' ||
               'ZX_API_PUB.Global_document_update');
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines',
               'RETURN_STATUS = ' || x_return_status);
        FND_LOG.STRING(g_level_unexpected,
               'ZX.PLSQL.ZX_NEW_SERVICES_PKG.cancel_tax_lines.END',
               'ZX_NEW_SERVICES_PKG.cancel_tax_lines(-)');
      END IF;
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_NEW_SERVICES_PKG: '||l_api_name||'()-');
    END IF;

    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO cancel_tax_lines_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count   =>      x_msg_count,
                                 p_data    =>      x_msg_data
                                );
       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO cancel_tax_lines_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   =>      x_msg_count,
                                p_data    =>      x_msg_data
                               );
      IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO cancel_tax_lines_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count       =>      x_msg_count,
                                p_data        =>      x_msg_data
                               );
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;
END cancel_tax_lines;

 /* ======================================================================*
 | PROCEDURE delete_tax_dists:                                   |
 * ======================================================================*/

 PROCEDURE delete_tax_dists(
  p_api_version           IN            NUMBER,
  p_init_msg_list         IN            VARCHAR2,
  p_commit                IN            VARCHAR2,
  p_validation_level      IN            NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2 ,
  x_msg_count             OUT NOCOPY    NUMBER ,
  x_msg_data              OUT NOCOPY    VARCHAR2 ,
  p_transaction_line_rec  IN OUT NOCOPY ZX_API_PUB.transaction_line_rec_type
  )IS
  l_api_name                  CONSTANT  VARCHAR2(30) := 'DELETE_TAX_DISTS';
  l_api_version               CONSTANT  NUMBER := 1.0;
  l_return_status             VARCHAR2(1);
  l_init_msg_list             VARCHAR2(1);

  TYPE num_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
  l_tax_line_id_tbl           num_tbl_type;

  CURSOR get_tax_line_id_cur IS
  SELECT tax_line_id
    FROM zx_rec_nrec_dist zd, zx_tax_dist_id_gt zgt
      WHERE zd.rec_nrec_tax_dist_id = zgt.tax_dist_id;

 BEGIN
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN','ZX_NEW_SERVICES_PKG: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT Del_Cand_Tax_Distributions_PVT;

   /*--------------------------------------------------+
    |   Standard call to check for call compatibility  |
    +--------------------------------------------------*/
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    /*--------------------------------------------------------------+
     |   Initialize message list if p_init_msg_list is set to TRUE  |
     +--------------------------------------------------------------*/
     IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
     ELSE
       l_init_msg_list := p_init_msg_list;
     END IF;

     IF FND_API.to_Boolean(l_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

    /*-----------------------------------------+
     |   Initialize return status to SUCCESS   |
     +-----------------------------------------*/
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*-----------------------------------------+
     |   Populate Global Variable              |
     +-----------------------------------------*/
     ZX_API_PUB.G_PUB_SRVC := l_api_name;
     ZX_API_PUB.G_DATA_TRANSFER_MODE := 'PLS';
     ZX_API_PUB.G_EXTERNAL_API_CALL  := 'N';


    OPEN get_tax_line_id_cur;
    FETCH get_tax_line_id_cur BULK COLLECT INTO
          l_tax_line_id_tbl;
    CLOSE get_tax_line_id_cur;

    /*-----------------------------------------+
     |   Delete tax distributions              |
     +-----------------------------------------*/

     DELETE FROM zx_rec_nrec_dist
           WHERE application_id     = p_transaction_line_rec.application_id
             AND entity_code        = p_transaction_line_rec.entity_code
             AND event_class_code   = p_transaction_line_rec.event_class_code
             AND trx_id             = p_transaction_line_rec.trx_id
             AND trx_level_type     = p_transaction_line_rec.trx_level_type
             AND rec_nrec_tax_dist_id IN (SELECT tax_dist_id FROM zx_tax_dist_id_gt);

     IF SQL%ROWCOUNT > 0 THEN
        FORALL i IN NVL(l_tax_line_id_tbl.FIRST, 0) .. NVL(l_tax_line_id_tbl.LAST, -1)
        UPDATE zx_lines
          SET process_for_recovery_flag   = 'Y',
              rec_tax_amt                 = NULL,
              rec_tax_amt_tax_curr        = NULL,
              rec_tax_amt_funcl_curr      = NULL,
              nrec_tax_amt                = NULL,
              nrec_tax_amt_tax_curr       = NULL,
              nrec_tax_amt_funcl_curr     = NULL
          WHERE application_id   = p_transaction_line_rec.application_id
          AND entity_code        = p_transaction_line_rec.entity_code
          AND event_class_code   = p_transaction_line_rec.event_class_code
          AND trx_id             = p_transaction_line_rec.trx_id
          AND tax_line_id        = l_tax_line_id_tbl(i)
          AND trx_level_type     = p_transaction_line_rec.trx_level_type;
      END IF;


     IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END','ZX_NEW_SERVICES_PKG: '||l_api_name||'()-');
     END IF;

     EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Del_Cand_Tax_Distributions_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Del_Cand_Tax_Distributions_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data
                                  );

        IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
        END IF;

      WHEN OTHERS THEN
         ROLLBACK TO Del_Cand_Tax_Distributions_PVT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
         FND_MSG_PUB.Add;
       /*---------------------------------------------------------+
        | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
        | in the message stack. If there is only one message in   |
        | the stack it retrieves this message                     |
        +---------------------------------------------------------*/
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                   p_count   => x_msg_count,
                                   p_data    => x_msg_data
                                   );
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

 END delete_tax_dists;

 /* =======================================================================*
 | PROCEDURE  sync_tax_dist_dff: Synchronizes DFF in ZX repository         |
 * ========================================================================*/
 -- Bug 7117340 -- DFF ER
 PROCEDURE SYNC_TAX_DIST_DFF
  (p_api_version           IN             NUMBER,
   p_init_msg_list         IN             VARCHAR2,
   p_commit                IN             VARCHAR2,
   p_validation_level      IN             NUMBER,
   x_return_status            OUT NOCOPY  VARCHAR2,
   x_msg_count                OUT NOCOPY  NUMBER,
   x_msg_data                 OUT NOCOPY  VARCHAR2,
   p_tax_dist_dff_tbl      IN             tax_dist_dff_type%TYPE
  ) IS

   l_api_name          CONSTANT  VARCHAR2(30) := 'SYNC_TAX_DIST_DFF';
   l_api_version       CONSTANT  NUMBER := 1.0;
   l_event_class_rec             ZX_API_PUB.event_class_rec_type;
   l_init_msg_list               VARCHAR2(1);

 BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||
                    '.BEGIN','ZX_NEW_SERVICES_PKG: '||l_api_name||'()+');
   END IF;

  /*--------------------------------------------------+
   |   Standard start of API savepoint                |
   +--------------------------------------------------*/
   SAVEPOINT sync_tax_dist_dff_pvt;

  /*--------------------------------------------------+
   |   Standard call to check for call compatibility  |
   +--------------------------------------------------*/
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                      ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  /*--------------------------------------------------------------+
   |   Initialize message list if p_init_msg_list is set to TRUE  |
   +--------------------------------------------------------------*/
   IF p_init_msg_list is null THEN
       l_init_msg_list := FND_API.G_FALSE;
   ELSE
       l_init_msg_list := p_init_msg_list;
   END IF;

   IF FND_API.to_Boolean(l_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

  /*-----------------------------------------+
   |   Initialize return status to SUCCESS   |
   +-----------------------------------------*/
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*-----------------------------------------+
   |   Populate Global Variable              |
   +-----------------------------------------*/
   ZX_API_PUB.G_PUB_SRVC := l_api_name;
   ZX_API_PUB.G_DATA_TRANSFER_MODE := 'PLS';
   ZX_API_PUB.G_EXTERNAL_API_CALL  := 'N';

  /*------------------------------------------------+
   |  Update zx_rec_nrec_dist                       |
   +------------------------------------------------*/
   FORALL i IN NVL(p_tax_dist_dff_tbl.rec_nrec_tax_dist_id.FIRST,0)..NVL(p_tax_dist_dff_tbl.rec_nrec_tax_dist_id.LAST, -1)
     UPDATE zx_rec_nrec_dist
        SET attribute1               = p_tax_dist_dff_tbl.attribute1(i),
            attribute2               = p_tax_dist_dff_tbl.attribute2(i),
            attribute3               = p_tax_dist_dff_tbl.attribute3(i),
            attribute4               = p_tax_dist_dff_tbl.attribute4(i),
            attribute5               = p_tax_dist_dff_tbl.attribute5(i),
            attribute6               = p_tax_dist_dff_tbl.attribute6(i),
            attribute7               = p_tax_dist_dff_tbl.attribute7(i),
            attribute8               = p_tax_dist_dff_tbl.attribute8(i),
            attribute9               = p_tax_dist_dff_tbl.attribute9(i),
            attribute10              = p_tax_dist_dff_tbl.attribute10(i),
            attribute11              = p_tax_dist_dff_tbl.attribute11(i),
            attribute12              = p_tax_dist_dff_tbl.attribute12(i),
            attribute13              = p_tax_dist_dff_tbl.attribute13(i),
            attribute14              = p_tax_dist_dff_tbl.attribute14(i),
            attribute15              = p_tax_dist_dff_tbl.attribute15(i),
            attribute_category       = p_tax_dist_dff_tbl.attribute_category(i),
            overridden_flag          = 'D'
      WHERE rec_nrec_tax_dist_id     = p_tax_dist_dff_tbl.rec_nrec_tax_dist_id(i);


    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_api_name||'.END',
                     'ZX_NEW_SERVICES_PKG: '||l_api_name||'()-');
    END IF;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO sync_tax_dist_dff_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                 );

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO sync_tax_dist_dff_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                 );

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

     WHEN OTHERS THEN
       ROLLBACK TO sync_tax_dist_dff_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('ZX','ZX_UNEXPECTED_ERROR');
       FND_MSG_PUB.Add;
      /*---------------------------------------------------------+
       | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
       | in the message stack. If there is only one message in   |
       | the stack it retrieves this message                     |
       +---------------------------------------------------------*/
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count       =>      x_msg_count,
                                 p_data        =>      x_msg_data
                                );
      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;

 END SYNC_TAX_DIST_DFF;
 --End Bug 7117340 --DFF ER

END ZX_NEW_SERVICES_PKG;

/
