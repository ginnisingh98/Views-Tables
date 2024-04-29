--------------------------------------------------------
--  DDL for Package Body ZX_ON_FLY_TRX_UPGRADE_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ON_FLY_TRX_UPGRADE_PO_PKG" AS
/* $Header: zxmigtrxflypob.pls 120.21.12010000.4 2009/08/18 09:13:02 tsen ship $ */

 g_current_runtime_level      NUMBER;
 g_level_statement            CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure            CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_level_event                CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
 g_level_unexpected           CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- upgrade_trx_on_fly_po
--
-- DESCRIPTION
-- on the fly migration of one transaction for PO
--
-------------------------------------------------------------------------------

PROCEDURE upgrade_trx_on_fly_po(
  p_upg_trx_info_rec     IN          ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
) AS

l_org_id    		NUMBER;
l_multi_org_flag	fnd_product_groups.multi_org_flag%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT multi_org_flag INTO l_multi_org_flag FROM fnd_product_groups;

  IF NVL(l_multi_org_flag,'N') = 'N' THEN  -- non- multi org
    FND_PROFILE.GET('ORG_ID',l_org_id);
    IF l_org_id is NULL THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_po',
                      'Current envionment is a Single Org environment,'||
                      ' but profile ORG_ID is not set up');
      END IF;
    END IF;
  END IF;

  -- calculate recovery rate for tax group
  --
  ZX_PO_REC_PKG.get_rec_info(p_upg_trx_info_rec => p_upg_trx_info_rec,
                             x_return_status    => x_return_status);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_po',
                   'Inserting data into zx_lines_det_factors');
  END IF;

  -- Insert data into zx_lines_det_factors
  --
  IF p_upg_trx_info_rec.entity_code = 'PURCHASE_ORDER' THEN
    INSERT INTO ZX_LINES_DET_FACTORS (
            EVENT_ID
           ,ACCOUNT_CCID
           ,ACCOUNT_STRING
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           ,APPLICATION_DOC_STATUS
           ,APPLICATION_ID
           ,APPLIED_FROM_APPLICATION_ID
           ,APPLIED_FROM_ENTITY_CODE
           ,APPLIED_FROM_EVENT_CLASS_CODE
           ,APPLIED_FROM_LINE_ID
           ,APPLIED_FROM_TRX_ID
           ,APPLIED_FROM_TRX_LEVEL_TYPE
           ,APPLIED_TO_APPLICATION_ID
           ,APPLIED_TO_ENTITY_CODE
           ,APPLIED_TO_EVENT_CLASS_CODE
           ,APPLIED_TO_TRX_ID
           ,APPLIED_TO_TRX_LEVEL_TYPE
           ,APPLIED_TO_TRX_LINE_ID
           ,APPLIED_TO_TRX_NUMBER
           ,ASSESSABLE_VALUE
           ,ASSET_ACCUM_DEPRECIATION
           ,ASSET_COST
           ,ASSET_FLAG
           ,ASSET_NUMBER
           ,ASSET_TYPE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,BILL_FROM_LOCATION_ID
           ,BILL_FROM_PARTY_TAX_PROF_ID
           ,BILL_FROM_SITE_TAX_PROF_ID
           ,BILL_TO_LOCATION_ID
           ,BILL_TO_PARTY_TAX_PROF_ID
           ,BILL_TO_SITE_TAX_PROF_ID
           ,COMPOUNDING_TAX_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,CTRL_HDR_TX_APPL_FLAG
           ,CTRL_TOTAL_HDR_TX_AMT
           ,CTRL_TOTAL_LINE_TX_AMT
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,DEFAULT_TAXATION_COUNTRY
           ,DOC_EVENT_STATUS
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,DOCUMENT_SUB_TYPE
           ,ENTITY_CODE
           ,ESTABLISHMENT_ID
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,FIRST_PTY_ORG_ID
           ,HISTORICAL_FLAG
           ,HQ_ESTB_PARTY_TAX_PROF_ID
           ,INCLUSIVE_TAX_OVERRIDE_FLAG
           ,INPUT_TAX_CLASSIFICATION_CODE
           ,INTERNAL_ORG_LOCATION_ID
           ,INTERNAL_ORGANIZATION_ID
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
           ,LEDGER_ID
           ,LEGAL_ENTITY_ID
           ,LINE_AMT
           ,LINE_AMT_INCLUDES_TAX_FLAG
           ,LINE_CLASS
           ,LINE_INTENDED_USE
           ,LINE_LEVEL_ACTION
           ,MERCHANT_PARTY_COUNTRY
           ,MERCHANT_PARTY_DOCUMENT_NUMBER
           ,MERCHANT_PARTY_ID
           ,MERCHANT_PARTY_NAME
           ,MERCHANT_PARTY_REFERENCE
           ,MERCHANT_PARTY_TAX_PROF_ID
           ,MERCHANT_PARTY_TAX_REG_NUMBER
           ,MERCHANT_PARTY_TAXPAYER_ID
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,OBJECT_VERSION_NUMBER
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           ,PORT_OF_ENTRY_CODE
           ,PRECISION
           ,PRODUCT_CATEGORY
           ,PRODUCT_CODE
           ,PRODUCT_DESCRIPTION
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ID
           ,PRODUCT_ORG_ID
           ,PRODUCT_TYPE
           ,RECORD_TYPE_CODE
           ,REF_DOC_APPLICATION_ID
           ,REF_DOC_ENTITY_CODE
           ,REF_DOC_EVENT_CLASS_CODE
           ,REF_DOC_LINE_ID
           ,REF_DOC_LINE_QUANTITY
           ,REF_DOC_TRX_ID
           ,REF_DOC_TRX_LEVEL_TYPE
           ,RELATED_DOC_APPLICATION_ID
           ,RELATED_DOC_DATE
           ,RELATED_DOC_ENTITY_CODE
           ,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_NUMBER
           ,RELATED_DOC_TRX_ID
           ,SHIP_FROM_LOCATION_ID
           ,SHIP_FROM_PARTY_TAX_PROF_ID
           ,SHIP_FROM_SITE_TAX_PROF_ID
           ,SHIP_TO_LOCATION_ID
           ,SHIP_TO_PARTY_TAX_PROF_ID
           ,SHIP_TO_SITE_TAX_PROF_ID
           ,SOURCE_APPLICATION_ID
           ,SOURCE_ENTITY_CODE
           ,SOURCE_EVENT_CLASS_CODE
           ,SOURCE_LINE_ID
           ,SOURCE_TRX_ID
           ,SOURCE_TRX_LEVEL_TYPE
           ,START_EXPENSE_DATE
           ,SUPPLIER_EXCHANGE_RATE
           ,SUPPLIER_TAX_INVOICE_DATE
           ,SUPPLIER_TAX_INVOICE_NUMBER
           ,TAX_AMT_INCLUDED_FLAG
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,TAX_PROCESSING_COMPLETED_FLAG
           ,TAX_REPORTING_FLAG
           ,THRESHOLD_INDICATOR_FLAG
           ,TRX_BUSINESS_CATEGORY
           ,TRX_COMMUNICATED_DATE
           ,TRX_CURRENCY_CODE
           ,TRX_DATE
           ,TRX_DESCRIPTION
           ,TRX_DUE_DATE
           ,TRX_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_DATE
           ,TRX_LINE_DESCRIPTION
           ,TRX_LINE_GL_DATE
           ,TRX_LINE_ID
           ,TRX_LINE_NUMBER
           ,TRX_LINE_QUANTITY
           ,TRX_LINE_TYPE
           ,TRX_NUMBER
           ,TRX_RECEIPT_DATE
           ,TRX_SHIPPING_DATE
           ,TRX_TYPE_DESCRIPTION
           ,UNIT_PRICE
           ,UOM_CODE
           ,USER_DEFINED_FISC_CLASS
           ,USER_UPD_DET_FACTORS_FLAG
           ,EVENT_CLASS_MAPPING_ID
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,ICX_SESSION_ID
           ,TRX_LINE_CURRENCY_CODE
           ,TRX_LINE_CURRENCY_CONV_RATE
           ,TRX_LINE_CURRENCY_CONV_DATE
           ,TRX_LINE_PRECISION
           ,TRX_LINE_MAU
           ,TRX_LINE_CURRENCY_CONV_TYPE
           ,INTERFACE_ENTITY_CODE
           ,INTERFACE_LINE_ID
           ,SOURCE_TAX_LINE_ID
           ,TAX_CALCULATION_DONE_FLAG
           ,LINE_TRX_USER_KEY1
           ,LINE_TRX_USER_KEY2
           ,LINE_TRX_USER_KEY3
         )
          SELECT /*+ ORDERED NO_EXPAND use_nl(fc, pol, poll, ptp, hr) */
           NULL 			    EVENT_ID,
           NULL 			    ACCOUNT_CCID,
           NULL 			    ACCOUNT_STRING,
           NULL 			    ADJUSTED_DOC_APPLICATION_ID,
           NULL 			    ADJUSTED_DOC_DATE,
           NULL 			    ADJUSTED_DOC_ENTITY_CODE,
           NULL 			    ADJUSTED_DOC_EVENT_CLASS_CODE,
           NULL 			    ADJUSTED_DOC_LINE_ID,
           NULL 			    ADJUSTED_DOC_NUMBER,
           NULL 			    ADJUSTED_DOC_TRX_ID,
           NULL 			    ADJUSTED_DOC_TRX_LEVEL_TYPE,
           NULL 			    APPLICATION_DOC_STATUS,
           201 			            APPLICATION_ID,
           NULL 			    APPLIED_FROM_APPLICATION_ID,
           NULL 			    APPLIED_FROM_ENTITY_CODE,
           NULL 			    APPLIED_FROM_EVENT_CLASS_CODE,
           NULL 			    APPLIED_FROM_LINE_ID,
           NULL 			    APPLIED_FROM_TRX_ID,
           NULL 			    APPLIED_FROM_TRX_LEVEL_TYPE,
           NULL 			    APPLIED_TO_APPLICATION_ID,
           NULL 			    APPLIED_TO_ENTITY_CODE,
           NULL 			    APPLIED_TO_EVENT_CLASS_CODE,
           NULL 			    APPLIED_TO_TRX_ID,
           NULL 			    APPLIED_TO_TRX_LEVEL_TYPE,
           NULL 			    APPLIED_TO_TRX_LINE_ID,
           NULL 			    APPLIED_TO_TRX_NUMBER,
           NULL 			    ASSESSABLE_VALUE,
           NULL 			    ASSET_ACCUM_DEPRECIATION,
           NULL 			    ASSET_COST,
           NULL 			    ASSET_FLAG,
           NULL 			    ASSET_NUMBER,
           NULL 			    ASSET_TYPE,
           NULL 			    BATCH_SOURCE_ID,
           NULL 			    BATCH_SOURCE_NAME,
           NULL 			    BILL_FROM_LOCATION_ID,
           NULL 			    BILL_FROM_PARTY_TAX_PROF_ID,
           NULL 			    BILL_FROM_SITE_TAX_PROF_ID,
           NULL 			    BILL_TO_LOCATION_ID,
           NULL 			    BILL_TO_PARTY_TAX_PROF_ID,
           NULL 			    BILL_TO_SITE_TAX_PROF_ID,
           'N' 			            COMPOUNDING_TAX_FLAG,
           1   			            CREATED_BY,
           SYSDATE 		            CREATION_DATE,
           'N' 			            CTRL_HDR_TX_APPL_FLAG,
           NULL			            CTRL_TOTAL_HDR_TX_AMT,
           NULL	 		            CTRL_TOTAL_LINE_TX_AMT,
           poh.rate_date 		    CURRENCY_CONVERSION_DATE,
           poh.rate 		            CURRENCY_CONVERSION_RATE,
           poh.rate_type 		    CURRENCY_CONVERSION_TYPE,
           NULL 			    DEFAULT_TAXATION_COUNTRY,
           NULL 			    DOC_EVENT_STATUS,
           NULL 			    DOC_SEQ_ID,
           NULL 			    DOC_SEQ_NAME,
           NULL 			    DOC_SEQ_VALUE,
           NULL 			    DOCUMENT_SUB_TYPE,
           'PURCHASE_ORDER' 		    ENTITY_CODE,
           NULL 			    ESTABLISHMENT_ID,
           'PO_PA' 	                    EVENT_CLASS_CODE,
           'PURCHASE ORDER CREATED'         EVENT_TYPE_CODE,
           ptp.party_tax_profile_id	    FIRST_PTY_ORG_ID,
           'Y' 			            HISTORICAL_FLAG,
           NULL	 		            HQ_ESTB_PARTY_TAX_PROF_ID,
           'N' 			            INCLUSIVE_TAX_OVERRIDE_FLAG,
           (select name
	    from ap_tax_codes_all
	    where tax_id = poll.tax_code_id) INPUT_TAX_CLASSIFICATION_CODE,
           NULL 			    INTERNAL_ORG_LOCATION_ID,
           nvl(poh.org_id,-99) 	            INTERNAL_ORGANIZATION_ID,
           SYSDATE 		            LAST_UPDATE_DATE,
           1 			            LAST_UPDATE_LOGIN,
           1 			            LAST_UPDATED_BY,
           poh.set_of_books_id 	            LEDGER_ID,
           NVL(poh.oi_org_information2,-99) LEGAL_ENTITY_ID,
           DECODE(pol.purchase_basis,
            'TEMP LABOR', NVL(POLL.amount,0),
            'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                               NVL(poll.quantity,0) *
                               NVL(poll.price_override,NVL(pol.unit_price,0))),
             NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                            LINE_AMT,
           'N' 			            LINE_AMT_INCLUDES_TAX_FLAG,
           'INVOICE' 		            LINE_CLASS,
           NULL 			    LINE_INTENDED_USE,
           'CREATE' 		            LINE_LEVEL_ACTION,
           NULL 			    MERCHANT_PARTY_COUNTRY,
           NULL 			    MERCHANT_PARTY_DOCUMENT_NUMBER,
           NULL 			    MERCHANT_PARTY_ID,
           NULL 			    MERCHANT_PARTY_NAME,
           NULL 			    MERCHANT_PARTY_REFERENCE,
           NULL 			    MERCHANT_PARTY_TAX_PROF_ID,
           NULL 			    MERCHANT_PARTY_TAX_REG_NUMBER,
           NULL 			    MERCHANT_PARTY_TAXPAYER_ID,
           fc.minimum_accountable_unit      MINIMUM_ACCOUNTABLE_UNIT,
           1 			            OBJECT_VERSION_NUMBER,
           NULL 			    OUTPUT_TAX_CLASSIFICATION_CODE,
           NULL 			    PORT_OF_ENTRY_CODE,
           NVL(fc.precision, 0)             PRECISION,
           -- fc.precision 		    PRECISION,
           NULL 			    PRODUCT_CATEGORY,
           NULL 			    PRODUCT_CODE,
           NULL 			    PRODUCT_DESCRIPTION,
           NULL 			    PRODUCT_FISC_CLASSIFICATION,
           pol.item_id		            PRODUCT_ID,
           poll.ship_to_organization_id	    PRODUCT_ORG_ID,
           DECODE(UPPER(pol.purchase_basis),
                  'GOODS', 'GOODS',
                  'SERVICES', 'SERVICES',
                  'TEMP LABOR','SERVICES',
                  'GOODS') 		    PRODUCT_TYPE,
           'MIGRATED' 		            RECORD_TYPE_CODE,
           NULL 			    REF_DOC_APPLICATION_ID,
           NULL 			    REF_DOC_ENTITY_CODE,
           NULL 			    REF_DOC_EVENT_CLASS_CODE,
           NULL 			    REF_DOC_LINE_ID,
           NULL 			    REF_DOC_LINE_QUANTITY,
           NULL 			    REF_DOC_TRX_ID,
           NULL 			    REF_DOC_TRX_LEVEL_TYPE,
           NULL 			    RELATED_DOC_APPLICATION_ID,
           NULL 			    RELATED_DOC_DATE,
           NULL 			    RELATED_DOC_ENTITY_CODE,
           NULL 			    RELATED_DOC_EVENT_CLASS_CODE,
           NULL 			    RELATED_DOC_NUMBER,
           NULL 			    RELATED_DOC_TRX_ID,
           NULL 			    SHIP_FROM_LOCATION_ID,
           NULL 			    SHIP_FROM_PARTY_TAX_PROF_ID,
           NULL 			    SHIP_FROM_SITE_TAX_PROF_ID,
           poll.ship_to_location_id         SHIP_TO_LOCATION_ID,
           NULL 			    SHIP_TO_PARTY_TAX_PROF_ID,
           NULL 			    SHIP_TO_SITE_TAX_PROF_ID,
           NULL 			    SOURCE_APPLICATION_ID,
           NULL 			    SOURCE_ENTITY_CODE,
           NULL 			    SOURCE_EVENT_CLASS_CODE,
           NULL 			    SOURCE_LINE_ID,
           NULL 			    SOURCE_TRX_ID,
           NULL 			    SOURCE_TRX_LEVEL_TYPE,
           NULL 			    START_EXPENSE_DATE,
           NULL 			    SUPPLIER_EXCHANGE_RATE,
           NULL 			    SUPPLIER_TAX_INVOICE_DATE,
           NULL 			    SUPPLIER_TAX_INVOICE_NUMBER,
           'N' 			            TAX_AMT_INCLUDED_FLAG,
           'PURCHASE_TRANSACTION' 	    TAX_EVENT_CLASS_CODE,
           'VALIDATE'  		            TAX_EVENT_TYPE_CODE,
           NULL 			    TAX_INVOICE_DATE,
           NULL 			    TAX_INVOICE_NUMBER,
           'Y'			            TAX_PROCESSING_COMPLETED_FLAG,
           'N'			            TAX_REPORTING_FLAG,
           'N' 			            THRESHOLD_INDICATOR_FLAG,
           NULL 			    TRX_BUSINESS_CATEGORY,
           NULL 			    TRX_COMMUNICATED_DATE,
           NVL(poh.currency_code,
               poh.base_currency_code) 	    TRX_CURRENCY_CODE,
           poh.last_update_date 	    TRX_DATE,
           NULL 			    TRX_DESCRIPTION,
           NULL 			    TRX_DUE_DATE,
           poh.po_header_id 	            TRX_ID,
           'SHIPMENT' 			    TRX_LEVEL_TYPE,
           poll.LAST_UPDATE_DATE  	    TRX_LINE_DATE,
           NULL 			    TRX_LINE_DESCRIPTION,
           poll.LAST_UPDATE_DATE 	    TRX_LINE_GL_DATE,
           poll.line_location_id 	    TRX_LINE_ID,
           poll.SHIPMENT_NUM 	            TRX_LINE_NUMBER,
           poll.quantity 		    TRX_LINE_QUANTITY,
           'ITEM' 			    TRX_LINE_TYPE,
           poh.segment1 		    TRX_NUMBER,
           NULL 			    TRX_RECEIPT_DATE,
           NULL 			    TRX_SHIPPING_DATE,
           NULL 			    TRX_TYPE_DESCRIPTION,
           NVL(poll.price_override,
                           pol.unit_price)  UNIT_PRICE,
           NULL 			    UOM_CODE,
           NULL 			    USER_DEFINED_FISC_CLASS,
           'N' 			            USER_UPD_DET_FACTORS_FLAG,
           3			            EVENT_CLASS_MAPPING_ID,
           poll.GLOBAL_ATTRIBUTE_CATEGORY   GLOBAL_ATTRIBUTE_CATEGORY,
           poll.GLOBAL_ATTRIBUTE1 	    GLOBAL_ATTRIBUTE1 	   ,
           NULL                             ICX_SESSION_ID,
           NULL                             TRX_LINE_CURRENCY_CODE,
           NULL                             TRX_LINE_CURRENCY_CONV_RATE,
           NULL                             TRX_LINE_CURRENCY_CONV_DATE,
           NULL                             TRX_LINE_PRECISION,
           NULL                             TRX_LINE_MAU,
           NULL                             TRX_LINE_CURRENCY_CONV_TYPE,
           NULL                             INTERFACE_ENTITY_CODE,
           NULL                             INTERFACE_LINE_ID,
           NULL                             SOURCE_TAX_LINE_ID,
           'Y'                              TAX_CALCULATION_DONE_FLAG,
           pol.line_num                     LINE_TRX_USER_KEY1,
           hr.location_code                 LINE_TRX_USER_KEY2,
           DECODE(poll.payment_type,
                   NULL, 0, 'DELIVERY',
                   1,'ADVANCE', 2, 3)       LINE_TRX_USER_KEY3
      FROM (SELECT /*+ NO_MERGE NO_EXPAND swap_join_inputs(fsp) swap_join_inputs(aps)
                   swap_join_inputs(oi) index(aps AP_SYSTEM_PARAMETERS_U1) */
                   poh.*,fsp.set_of_books_id, aps.base_currency_code,
                   oi.org_information2 oi_org_information2
   	      FROM po_headers_all poh,
                   financials_system_params_all fsp,
                   ap_system_parameters_all aps,
                   hr_organization_information oi
	     WHERE poh.po_header_id = p_upg_trx_info_rec.trx_id
               AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
               AND aps.set_of_books_id = fsp.set_of_books_id
               AND NVL(aps.org_id, -99) = NVL(poh.org_id, -99)
               AND oi.organization_id(+) = poh.org_id
               AND oi.org_information_context(+) = 'Operating Unit Information'
            ) poh,
           fnd_currencies fc,
           po_lines_all pol,
           po_line_locations_all poll,
           zx_party_tax_profile ptp,
           hr_locations_all hr
     WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
       AND pol.po_header_id = poh.po_header_id
       AND poll.po_header_id = pol.po_header_id
       AND poll.po_line_id = pol.po_line_id
       AND hr.location_id(+) = poll.ship_to_location_id
       AND NOT EXISTS
           (SELECT 1 FROM zx_transaction_lines_gt lines_gt
              WHERE lines_gt.application_id   = 201
                AND lines_gt.event_class_code = 'PO_PA'
                AND lines_gt.entity_code      = 'PURCHASE_ORDER'
                AND lines_gt.trx_id           = p_upg_trx_info_rec.trx_id
                AND lines_gt.trx_line_id      = poll.line_location_id
                AND lines_gt.trx_level_type   = 'SHIPMENT'
                AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
           )
       AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
       AND ptp.party_type_code = 'OU'
       AND NOT EXISTS
           (SELECT 1 FROM zx_lines_det_factors zxl
             WHERE zxl.APPLICATION_ID   = 201
               AND zxl.EVENT_CLASS_CODE = 'PO_PA'
               AND zxl.ENTITY_CODE      = 'PURCHASE_ORDER'
               AND zxl.TRX_ID           = p_upg_trx_info_rec.trx_id
               AND zxl.TRX_LINE_ID      = poll.line_location_id
               AND zxl.TRX_LEVEL_TYPE   = 'SHIPMENT'
            );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                     'Number of Rows Inserted = ' || TO_CHAR(SQL%ROWCOUNT));
    END IF;

    -- COMMIT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_po',
                     'Inserting data into zx_lines: tax code');
    END IF;

    -- Insert data into zx_lines
    --
    INSERT INTO ZX_LINES(
                ADJUSTED_DOC_APPLICATION_ID
               ,ADJUSTED_DOC_DATE
               ,ADJUSTED_DOC_ENTITY_CODE
               ,ADJUSTED_DOC_EVENT_CLASS_CODE
               ,ADJUSTED_DOC_LINE_ID
               ,ADJUSTED_DOC_NUMBER
               ,ADJUSTED_DOC_TAX_LINE_ID
               ,ADJUSTED_DOC_TRX_ID
               ,ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,APPLICATION_ID
               ,APPLIED_FROM_APPLICATION_ID
               ,APPLIED_FROM_ENTITY_CODE
               ,APPLIED_FROM_EVENT_CLASS_CODE
               ,APPLIED_FROM_LINE_ID
               ,APPLIED_FROM_TRX_ID
               ,APPLIED_FROM_TRX_LEVEL_TYPE
               ,APPLIED_FROM_TRX_NUMBER
               ,APPLIED_TO_APPLICATION_ID
               ,APPLIED_TO_ENTITY_CODE
               ,APPLIED_TO_EVENT_CLASS_CODE
               ,APPLIED_TO_LINE_ID
               ,APPLIED_TO_TRX_ID
               ,APPLIED_TO_TRX_LEVEL_TYPE
               ,APPLIED_TO_TRX_NUMBER
               ,ASSOCIATED_CHILD_FROZEN_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,BASIS_RESULT_ID
               ,CAL_TAX_AMT
               ,CAL_TAX_AMT_FUNCL_CURR
               ,CAL_TAX_AMT_TAX_CURR
               ,CALC_RESULT_ID
               ,CANCEL_FLAG
               ,CHAR1
               ,CHAR10
               ,CHAR2
               ,CHAR3
               ,CHAR4
               ,CHAR5
               ,CHAR6
               ,CHAR7
               ,CHAR8
               ,CHAR9
               ,COMPOUNDING_DEP_TAX_FLAG
               ,COMPOUNDING_TAX_FLAG
               ,COMPOUNDING_TAX_MISS_FLAG
               ,CONTENT_OWNER_ID
               ,COPIED_FROM_OTHER_DOC_FLAG
               ,CREATED_BY
               ,CREATION_DATE
               ,CTRL_TOTAL_LINE_TX_AMT
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,DATE1
               ,DATE10
               ,DATE2
               ,DATE3
               ,DATE4
               ,DATE5
               ,DATE6
               ,DATE7
               ,DATE8
               ,DATE9
               ,DELETE_FLAG
               ,DIRECT_RATE_RESULT_ID
               ,DOC_EVENT_STATUS
               ,ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,ENTITY_CODE
               ,ESTABLISHMENT_ID
               ,EVAL_EXCPT_RESULT_ID
               ,EVAL_EXMPT_RESULT_ID
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,EXCEPTION_RATE
               ,EXEMPT_CERTIFICATE_NUMBER
               ,EXEMPT_RATE_MODIFIER
               ,EXEMPT_REASON
               ,EXEMPT_REASON_CODE
               ,FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,GLOBAL_ATTRIBUTE_CATEGORY
               ,GLOBAL_ATTRIBUTE1
               ,GLOBAL_ATTRIBUTE10
               ,GLOBAL_ATTRIBUTE11
               ,GLOBAL_ATTRIBUTE12
               ,GLOBAL_ATTRIBUTE13
               ,GLOBAL_ATTRIBUTE14
               ,GLOBAL_ATTRIBUTE15
               ,GLOBAL_ATTRIBUTE2
               ,GLOBAL_ATTRIBUTE3
               ,GLOBAL_ATTRIBUTE4
               ,GLOBAL_ATTRIBUTE5
               ,GLOBAL_ATTRIBUTE6
               ,GLOBAL_ATTRIBUTE7
               ,GLOBAL_ATTRIBUTE8
               ,GLOBAL_ATTRIBUTE9
               ,HISTORICAL_FLAG
               ,HQ_ESTB_PARTY_TAX_PROF_ID
               ,HQ_ESTB_REG_NUMBER
               ,INTERFACE_ENTITY_CODE
               ,INTERFACE_TAX_LINE_ID
               ,INTERNAL_ORG_LOCATION_ID
               ,INTERNAL_ORGANIZATION_ID
               ,ITEM_DIST_CHANGED_FLAG
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,LEDGER_ID
               ,LEGAL_ENTITY_ID
               ,LEGAL_ENTITY_TAX_REG_NUMBER
               ,LEGAL_JUSTIFICATION_TEXT1
               ,LEGAL_JUSTIFICATION_TEXT2
               ,LEGAL_JUSTIFICATION_TEXT3
               ,LEGAL_MESSAGE_APPL_2
               ,LEGAL_MESSAGE_BASIS
               ,LEGAL_MESSAGE_CALC
               ,LEGAL_MESSAGE_EXCPT
               ,LEGAL_MESSAGE_EXMPT
               ,LEGAL_MESSAGE_POS
               ,LEGAL_MESSAGE_RATE
               ,LEGAL_MESSAGE_STATUS
               ,LEGAL_MESSAGE_THRESHOLD
               ,LEGAL_MESSAGE_TRN
               ,LINE_AMT
               ,LINE_ASSESSABLE_VALUE
               ,MANUALLY_ENTERED_FLAG
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,MRC_LINK_TO_TAX_LINE_ID
               ,MRC_TAX_LINE_FLAG
               ,NREC_TAX_AMT
               ,NREC_TAX_AMT_FUNCL_CURR
               ,NREC_TAX_AMT_TAX_CURR
               ,NUMERIC1
               ,NUMERIC10
               ,NUMERIC2
               ,NUMERIC3
               ,NUMERIC4
               ,NUMERIC5
               ,NUMERIC6
               ,NUMERIC7
               ,NUMERIC8
               ,NUMERIC9
               ,OBJECT_VERSION_NUMBER
               ,OFFSET_FLAG
               ,OFFSET_LINK_TO_TAX_LINE_ID
               ,OFFSET_TAX_RATE_CODE
               ,ORIG_SELF_ASSESSED_FLAG
               ,ORIG_TAX_AMT
               ,ORIG_TAX_AMT_INCLUDED_FLAG
               ,ORIG_TAX_AMT_TAX_CURR
               ,ORIG_TAX_JURISDICTION_CODE
               ,ORIG_TAX_JURISDICTION_ID
               ,ORIG_TAX_RATE
               ,ORIG_TAX_RATE_CODE
               ,ORIG_TAX_RATE_ID
               ,ORIG_TAX_STATUS_CODE
               ,ORIG_TAX_STATUS_ID
               ,ORIG_TAXABLE_AMT
               ,ORIG_TAXABLE_AMT_TAX_CURR
               ,OTHER_DOC_LINE_AMT
               ,OTHER_DOC_LINE_TAX_AMT
               ,OTHER_DOC_LINE_TAXABLE_AMT
               ,OTHER_DOC_SOURCE
               ,OVERRIDDEN_FLAG
               ,PLACE_OF_SUPPLY
               ,PLACE_OF_SUPPLY_RESULT_ID
               ,PLACE_OF_SUPPLY_TYPE_CODE
               ,PRD_TOTAL_TAX_AMT
               ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,PRD_TOTAL_TAX_AMT_TAX_CURR
               ,PRECISION
               ,PROCESS_FOR_RECOVERY_FLAG
               ,PRORATION_CODE
               ,PURGE_FLAG
               ,RATE_RESULT_ID
               ,REC_TAX_AMT
               ,REC_TAX_AMT_FUNCL_CURR
               ,REC_TAX_AMT_TAX_CURR
               ,RECALC_REQUIRED_FLAG
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_LINE_QUANTITY
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,REGISTRATION_PARTY_TYPE
               ,RELATED_DOC_APPLICATION_ID
               ,RELATED_DOC_DATE
               ,RELATED_DOC_ENTITY_CODE
               ,RELATED_DOC_EVENT_CLASS_CODE
               ,RELATED_DOC_NUMBER
               ,RELATED_DOC_TRX_ID
               ,RELATED_DOC_TRX_LEVEL_TYPE
               ,REPORTING_CURRENCY_CODE
               ,REPORTING_ONLY_FLAG
               ,REPORTING_PERIOD_ID
               ,ROUNDING_LEVEL_CODE
               ,ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,ROUNDING_LVL_PARTY_TYPE
               ,ROUNDING_RULE_CODE
               ,SELF_ASSESSED_FLAG
               ,SETTLEMENT_FLAG
               ,STATUS_RESULT_ID
               ,SUMMARY_TAX_LINE_ID
               ,SYNC_WITH_PRVDR_FLAG
               ,TAX
               ,TAX_AMT
               ,TAX_AMT_FUNCL_CURR
               ,TAX_AMT_INCLUDED_FLAG
               ,TAX_AMT_TAX_CURR
               ,TAX_APPLICABILITY_RESULT_ID
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_BASE_MODIFIER_RATE
               ,TAX_CALCULATION_FORMULA
               ,TAX_CODE
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_DATE
               ,TAX_DATE_RULE_ID
               ,TAX_DETERMINE_DATE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_EXCEPTION_ID
               ,TAX_EXEMPTION_ID
               ,TAX_HOLD_CODE
               ,TAX_HOLD_RELEASED_CODE
               ,TAX_ID
               ,TAX_JURISDICTION_CODE
               ,TAX_JURISDICTION_ID
               ,TAX_LINE_ID
               ,TAX_LINE_NUMBER
               ,TAX_ONLY_LINE_FLAG
               ,TAX_POINT_DATE
               ,TAX_PROVIDER_ID
               ,TAX_RATE
               ,TAX_RATE_BEFORE_EXCEPTION
               ,TAX_RATE_BEFORE_EXEMPTION
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_RATE_NAME_BEFORE_EXCEPTION
               ,TAX_RATE_NAME_BEFORE_EXEMPTION
               ,TAX_RATE_TYPE
               ,TAX_REG_NUM_DET_RESULT_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_REGIME_TEMPLATE_ID
               ,TAX_REGISTRATION_ID
               ,TAX_REGISTRATION_NUMBER
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TAX_TYPE_CODE
               ,TAXABLE_AMT
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TAXABLE_BASIS_FORMULA
               ,TAXING_JURIS_GEOGRAPHY_ID
               ,THRESH_RESULT_ID
               ,TRX_CURRENCY_CODE
               ,TRX_DATE
               ,TRX_ID
               ,TRX_ID_LEVEL2
               ,TRX_ID_LEVEL3
               ,TRX_ID_LEVEL4
               ,TRX_ID_LEVEL5
               ,TRX_ID_LEVEL6
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_DATE
               ,TRX_LINE_ID
               ,TRX_LINE_INDEX
               ,TRX_LINE_NUMBER
               ,TRX_LINE_QUANTITY
               ,TRX_NUMBER
               ,TRX_USER_KEY_LEVEL1
               ,TRX_USER_KEY_LEVEL2
               ,TRX_USER_KEY_LEVEL3
               ,TRX_USER_KEY_LEVEL4
               ,TRX_USER_KEY_LEVEL5
               ,TRX_USER_KEY_LEVEL6
               ,UNIT_PRICE
               ,UNROUNDED_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,MULTIPLE_JURISDICTIONS_FLAG)
        SELECT /*+ leading(poh) NO_EXPAND
                   use_nl(fc,pol,poll,ptp,atc,rates,regimes,taxes,status) */
                NULL 	                           ADJUSTED_DOC_APPLICATION_ID
               ,NULL 	                           ADJUSTED_DOC_DATE
               ,NULL	                           ADJUSTED_DOC_ENTITY_CODE
               ,NULL                               ADJUSTED_DOC_EVENT_CLASS_CODE
               ,NULL                               ADJUSTED_DOC_LINE_ID
               ,NULL                               ADJUSTED_DOC_NUMBER
               ,NULL                               ADJUSTED_DOC_TAX_LINE_ID
               ,NULL                               ADJUSTED_DOC_TRX_ID
               ,NULL                               ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,201	                           APPLICATION_ID
               ,NULL                               APPLIED_FROM_APPLICATION_ID
               ,NULL                               APPLIED_FROM_ENTITY_CODE
               ,NULL                               APPLIED_FROM_EVENT_CLASS_CODE
               ,NULL                               APPLIED_FROM_LINE_ID
               ,NULL                               APPLIED_FROM_TRX_ID
               ,NULL                               APPLIED_FROM_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_FROM_TRX_NUMBER
               ,NULL	                           APPLIED_TO_APPLICATION_ID
               ,NULL	                           APPLIED_TO_ENTITY_CODE
               ,NULL	                           APPLIED_TO_EVENT_CLASS_CODE
               ,NULL	                           APPLIED_TO_LINE_ID
               ,NULL	                           APPLIED_TO_TRX_ID
               ,NULL	                           APPLIED_TO_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_TO_TRX_NUMBER
               ,'N' 	                           ASSOCIATED_CHILD_FROZEN_FLAG
               ,poll.ATTRIBUTE_CATEGORY            ATTRIBUTE_CATEGORY
               ,poll.ATTRIBUTE1 	           ATTRIBUTE1
               ,poll.ATTRIBUTE10	           ATTRIBUTE10
               ,poll.ATTRIBUTE11	           ATTRIBUTE11
               ,poll.ATTRIBUTE12	           ATTRIBUTE12
               ,poll.ATTRIBUTE13	           ATTRIBUTE13
               ,poll.ATTRIBUTE14	           ATTRIBUTE14
               ,poll.ATTRIBUTE15	           ATTRIBUTE15
               ,poll.ATTRIBUTE2 	           ATTRIBUTE2
               ,poll.ATTRIBUTE3 	           ATTRIBUTE3
               ,poll.ATTRIBUTE4 	           ATTRIBUTE4
               ,poll.ATTRIBUTE5 	           ATTRIBUTE5
               ,poll.ATTRIBUTE6 	           ATTRIBUTE6
               ,poll.ATTRIBUTE7 	           ATTRIBUTE7
               ,poll.ATTRIBUTE8 	           ATTRIBUTE8
               ,poll.ATTRIBUTE9 	           ATTRIBUTE9
               ,NULL			           BASIS_RESULT_ID
               ,NULL	                           CAL_TAX_AMT
               ,NULL	                           CAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           CAL_TAX_AMT_TAX_CURR
               ,NULL	                           CALC_RESULT_ID
               ,'N'	                           CANCEL_FLAG
               ,NULL	                           CHAR1
               ,NULL	                           CHAR10
               ,NULL	                           CHAR2
               ,NULL	                           CHAR3
               ,NULL	                           CHAR4
               ,NULL	                           CHAR5
               ,NULL	                           CHAR6
               ,NULL	                           CHAR7
               ,NULL	                           CHAR8
               ,NULL	                           CHAR9
               ,'N'	                           COMPOUNDING_DEP_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_MISS_FLAG
               ,ptp.party_tax_profile_id	   CONTENT_OWNER_ID
               ,'N'	                           COPIED_FROM_OTHER_DOC_FLAG
               ,1	                           CREATED_BY
               ,SYSDATE                            CREATION_DATE
               ,NULL		                   CTRL_TOTAL_LINE_TX_AMT
               ,poh.rate_date 	                   CURRENCY_CONVERSION_DATE
               ,poh.rate 	                   CURRENCY_CONVERSION_RATE
               ,poh.rate_type 	                   CURRENCY_CONVERSION_TYPE
               ,NULL	                           DATE1
               ,NULL	                           DATE10
               ,NULL	                           DATE2
               ,NULL	                           DATE3
               ,NULL	                           DATE4
               ,NULL	                           DATE5
               ,NULL	                           DATE6
               ,NULL	                           DATE7
               ,NULL	                           DATE8
               ,NULL	                           DATE9
               ,'N'	                           DELETE_FLAG
               ,NULL	                           DIRECT_RATE_RESULT_ID
               ,NULL	                           DOC_EVENT_STATUS
               ,'N'	                           ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,'PURCHASE_ORDER' 	           ENTITY_CODE
               ,NULL	                           ESTABLISHMENT_ID
               ,NULL	                           EVAL_EXCPT_RESULT_ID
               ,NULL	                           EVAL_EXMPT_RESULT_ID
               ,'PO_PA' 		           EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	   EVENT_TYPE_CODE
               ,NULL                               EXCEPTION_RATE
               ,NULL	                           EXEMPT_CERTIFICATE_NUMBER
               ,NULL	                           EXEMPT_RATE_MODIFIER
               ,NULL	                           EXEMPT_REASON
               ,NULL	                           EXEMPT_REASON_CODE
               ,'N'	                           FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,poll.GLOBAL_ATTRIBUTE_CATEGORY     GLOBAL_ATTRIBUTE_CATEGORY
               ,poll.GLOBAL_ATTRIBUTE1 	           GLOBAL_ATTRIBUTE1
               ,poll.GLOBAL_ATTRIBUTE10	           GLOBAL_ATTRIBUTE10
               ,poll.GLOBAL_ATTRIBUTE11	           GLOBAL_ATTRIBUTE11
               ,poll.GLOBAL_ATTRIBUTE12	           GLOBAL_ATTRIBUTE12
               ,poll.GLOBAL_ATTRIBUTE13	           GLOBAL_ATTRIBUTE13
               ,poll.GLOBAL_ATTRIBUTE14	           GLOBAL_ATTRIBUTE14
               ,poll.GLOBAL_ATTRIBUTE15	           GLOBAL_ATTRIBUTE15
               ,poll.GLOBAL_ATTRIBUTE2             GLOBAL_ATTRIBUTE2
               ,poll.GLOBAL_ATTRIBUTE3             GLOBAL_ATTRIBUTE3
               ,poll.GLOBAL_ATTRIBUTE4             GLOBAL_ATTRIBUTE4
               ,poll.GLOBAL_ATTRIBUTE5             GLOBAL_ATTRIBUTE5
               ,poll.GLOBAL_ATTRIBUTE6             GLOBAL_ATTRIBUTE6
               ,poll.GLOBAL_ATTRIBUTE7             GLOBAL_ATTRIBUTE7
               ,poll.GLOBAL_ATTRIBUTE8             GLOBAL_ATTRIBUTE8
               ,poll.GLOBAL_ATTRIBUTE9             GLOBAL_ATTRIBUTE9
               ,'Y'	                           HISTORICAL_FLAG
               ,NULL                               HQ_ESTB_PARTY_TAX_PROF_ID
               ,NULL	                           HQ_ESTB_REG_NUMBER
               ,NULL	                           INTERFACE_ENTITY_CODE
               ,NULL	                           INTERFACE_TAX_LINE_ID
               ,NULL                               INTERNAL_ORG_LOCATION_ID
               ,nvl(poh.org_id,-99)                INTERNAL_ORGANIZATION_ID
               ,'N'                                ITEM_DIST_CHANGED_FLAG
               ,NULL	                           LAST_MANUAL_ENTRY
               ,SYSDATE	                           LAST_UPDATE_DATE
               ,1	                           LAST_UPDATE_LOGIN
               ,1	                           LAST_UPDATED_BY
               ,poh.set_of_books_id 	           LEDGER_ID
               ,NVL(poh.oi_org_information2, -99)  LEGAL_ENTITY_ID
               ,NULL                               LEGAL_ENTITY_TAX_REG_NUMBER
               ,NULL                               LEGAL_JUSTIFICATION_TEXT1
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT2
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT3
               ,NULL                               LEGAL_MESSAGE_APPL_2
               ,NULL	                           LEGAL_MESSAGE_BASIS
               ,NULL	                           LEGAL_MESSAGE_CALC
               ,NULL	                           LEGAL_MESSAGE_EXCPT
               ,NULL	                           LEGAL_MESSAGE_EXMPT
               ,NULL	                           LEGAL_MESSAGE_POS
               ,NULL	                           LEGAL_MESSAGE_RATE
               ,NULL                               LEGAL_MESSAGE_STATUS
               ,NULL	                           LEGAL_MESSAGE_THRESHOLD
               ,NULL	                           LEGAL_MESSAGE_TRN
               ,DECODE(pol.purchase_basis,
                 'TEMP LABOR', NVL(POLL.amount,0),
                 'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                    NVL(poll.quantity,0) *
                                    NVL(poll.price_override,NVL(pol.unit_price,0))),
                  NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                                   LINE_AMT
               ,NULL	                           LINE_ASSESSABLE_VALUE
               ,'N'	                           MANUALLY_ENTERED_FLAG
               ,fc.minimum_accountable_unit	   MINIMUM_ACCOUNTABLE_UNIT
               ,NULL	                           MRC_LINK_TO_TAX_LINE_ID
               ,'N'	                           MRC_TAX_LINE_FLAG
               ,NULL	                           NREC_TAX_AMT
               ,NULL	                           NREC_TAX_AMT_FUNCL_CURR
               ,NULL	                           NREC_TAX_AMT_TAX_CURR
               ,NULL	                           NUMERIC1
               ,NULL	                           NUMERIC10
               ,NULL	                           NUMERIC2
               ,NULL	                           NUMERIC3
               ,NULL	                           NUMERIC4
               ,NULL	                           NUMERIC5
               ,NULL	                           NUMERIC6
               ,NULL	                           NUMERIC7
               ,NULL	                           NUMERIC8
               ,NULL	                           NUMERIC9
               ,1	                           OBJECT_VERSION_NUMBER
               ,'N'	                           OFFSET_FLAG
               ,NULL	                           OFFSET_LINK_TO_TAX_LINE_ID
               ,NULL	                           OFFSET_TAX_RATE_CODE
               ,'N'	                           ORIG_SELF_ASSESSED_FLAG
               ,NULL	                           ORIG_TAX_AMT
               ,NULL	                           ORIG_TAX_AMT_INCLUDED_FLAG
               ,NULL	                           ORIG_TAX_AMT_TAX_CURR
               ,NULL	                           ORIG_TAX_JURISDICTION_CODE
               ,NULL	                           ORIG_TAX_JURISDICTION_ID
               ,NULL	                           ORIG_TAX_RATE
               ,NULL	                           ORIG_TAX_RATE_CODE
               ,NULL	                           ORIG_TAX_RATE_ID
               ,NULL	                           ORIG_TAX_STATUS_CODE
               ,NULL	                           ORIG_TAX_STATUS_ID
               ,NULL	                           ORIG_TAXABLE_AMT
               ,NULL	                           ORIG_TAXABLE_AMT_TAX_CURR
               ,NULL	                           OTHER_DOC_LINE_AMT
               ,NULL	                           OTHER_DOC_LINE_TAX_AMT
               ,NULL	                           OTHER_DOC_LINE_TAXABLE_AMT
               ,NULL	                           OTHER_DOC_SOURCE
               ,'N'	                           OVERRIDDEN_FLAG
               ,NULL	                           PLACE_OF_SUPPLY
               ,NULL	                           PLACE_OF_SUPPLY_RESULT_ID
               ,NULL                               PLACE_OF_SUPPLY_TYPE_CODE
               ,NULL	                           PRD_TOTAL_TAX_AMT
               ,NULL	                           PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           PRD_TOTAL_TAX_AMT_TAX_CURR
               ,NVL(fc.precision, 0)               PRECISION
               ,'N'	                           PROCESS_FOR_RECOVERY_FLAG
               ,NULL	                           PRORATION_CODE
               ,'N'	                           PURGE_FLAG
               ,NULL	                           RATE_RESULT_ID
               ,NULL	                           REC_TAX_AMT
               ,NULL	                           REC_TAX_AMT_FUNCL_CURR
               ,NULL	                           REC_TAX_AMT_TAX_CURR
               ,'N'	                           RECALC_REQUIRED_FLAG
               ,'MIGRATED'                         RECORD_TYPE_CODE
               ,NULL	                           REF_DOC_APPLICATION_ID
               ,NULL	                           REF_DOC_ENTITY_CODE
               ,NULL	                           REF_DOC_EVENT_CLASS_CODE
               ,NULL	                           REF_DOC_LINE_ID
               ,NULL	                           REF_DOC_LINE_QUANTITY
               ,NULL	                           REF_DOC_TRX_ID
               ,NULL	                           REF_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REGISTRATION_PARTY_TYPE
               ,NULL	                           RELATED_DOC_APPLICATION_ID
               ,NULL	                           RELATED_DOC_DATE
               ,NULL	                           RELATED_DOC_ENTITY_CODE
               ,NULL	                           RELATED_DOC_EVENT_CLASS_CODE
               ,NULL	                           RELATED_DOC_NUMBER
               ,NULL	                           RELATED_DOC_TRX_ID
               ,NULL	                           RELATED_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REPORTING_CURRENCY_CODE
               ,'N'	                           REPORTING_ONLY_FLAG
               ,NULL	                           REPORTING_PERIOD_ID
               ,NULL	                           ROUNDING_LEVEL_CODE
               ,NULL	                           ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,NULL	                           ROUNDING_LVL_PARTY_TYPE
               ,NULL	                           ROUNDING_RULE_CODE
               ,'N'	                           SELF_ASSESSED_FLAG
               ,'N'                                SETTLEMENT_FLAG
               ,NULL                               STATUS_RESULT_ID
               ,NULL                               SUMMARY_TAX_LINE_ID
               ,NULL                               SYNC_WITH_PRVDR_FLAG
               ,rates.tax                          TAX
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)  TAX_AMT
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)
                                                   TAX_AMT_FUNCL_CURR
               ,'N'                                TAX_AMT_INCLUDED_FLAG
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit) TAX_AMT_TAX_CURR
               ,NULL                               TAX_APPLICABILITY_RESULT_ID
               ,'Y'                                TAX_APPORTIONMENT_FLAG
               ,1                                  TAX_APPORTIONMENT_LINE_NUMBER
               ,NULL                               TAX_BASE_MODIFIER_RATE
               ,'STANDARD_TC'                      TAX_CALCULATION_FORMULA
               ,NULL                               TAX_CODE
               ,taxes.tax_currency_code            TAX_CURRENCY_CODE
               ,poh.rate_date 		           TAX_CURRENCY_CONVERSION_DATE
               ,poh.rate 		           TAX_CURRENCY_CONVERSION_RATE
               ,poh.rate_type 		           TAX_CURRENCY_CONVERSION_TYPE
               ,poll.last_update_date              TAX_DATE
               ,NULL                               TAX_DATE_RULE_ID
               ,poll.last_update_date              TAX_DETERMINE_DATE
               ,'PURCHASE_TRANSACTION' 	           TAX_EVENT_CLASS_CODE
               ,'VALIDATE'  		           TAX_EVENT_TYPE_CODE
               ,NULL                               TAX_EXCEPTION_ID
               ,NULL                               TAX_EXEMPTION_ID
               ,NULL                               TAX_HOLD_CODE
               ,NULL                               TAX_HOLD_RELEASED_CODE
               ,taxes.tax_id                       TAX_ID
               ,NULL                               TAX_JURISDICTION_CODE
               ,NULL                               TAX_JURISDICTION_ID
               ,zx_lines_s.nextval                 TAX_LINE_ID
               ,RANK() OVER
                (PARTITION BY poh.po_header_id
                     ORDER BY poll.line_location_id,
                              atc.tax_id)         TAX_LINE_NUMBER
               ,'N'                               TAX_ONLY_LINE_FLAG
               ,poll.last_update_date             TAX_POINT_DATE
               ,NULL                              TAX_PROVIDER_ID
               ,rates.percentage_rate  	          TAX_RATE
               ,NULL	                          TAX_RATE_BEFORE_EXCEPTION
               ,NULL                              TAX_RATE_BEFORE_EXEMPTION
               ,rates.tax_rate_code               TAX_RATE_CODE
               ,rates.tax_rate_id                 TAX_RATE_ID
               ,NULL                              TAX_RATE_NAME_BEFORE_EXCEPTION
               ,NULL                              TAX_RATE_NAME_BEFORE_EXEMPTION
               ,NULL                              TAX_RATE_TYPE
               ,NULL                              TAX_REG_NUM_DET_RESULT_ID
               ,rates.tax_regime_code             TAX_REGIME_CODE
               ,regimes.tax_regime_id             TAX_REGIME_ID
               ,NULL                              TAX_REGIME_TEMPLATE_ID
               ,NULL                              TAX_REGISTRATION_ID
               ,NULL                              TAX_REGISTRATION_NUMBER
               ,rates.tax_status_code             TAX_STATUS_CODE
               ,status.tax_status_id              TAX_STATUS_ID
               ,NULL                              TAX_TYPE_CODE
               ,NULL                              TAXABLE_AMT
               ,NULL                              TAXABLE_AMT_FUNCL_CURR
               ,NULL                              TAXABLE_AMT_TAX_CURR
               ,'STANDARD_TB'                     TAXABLE_BASIS_FORMULA
               ,NULL                              TAXING_JURIS_GEOGRAPHY_ID
               ,NULL                              THRESH_RESULT_ID
               ,NVL(poh.currency_code,
                    poh.base_currency_code)       TRX_CURRENCY_CODE
               ,poh.last_update_date              TRX_DATE
               ,poh.po_header_id                  TRX_ID
               ,NULL                              TRX_ID_LEVEL2
               ,NULL                              TRX_ID_LEVEL3
               ,NULL                              TRX_ID_LEVEL4
               ,NULL                              TRX_ID_LEVEL5
               ,NULL                              TRX_ID_LEVEL6
               ,'SHIPMENT'                        TRX_LEVEL_TYPE
               ,poll.LAST_UPDATE_DATE             TRX_LINE_DATE
               ,poll.line_location_id             TRX_LINE_ID
               ,NULL                              TRX_LINE_INDEX
               ,poll.SHIPMENT_NUM                 TRX_LINE_NUMBER
               ,poll.quantity 		          TRX_LINE_QUANTITY
               ,poh.segment1                      TRX_NUMBER
               ,NULL                              TRX_USER_KEY_LEVEL1
               ,NULL                              TRX_USER_KEY_LEVEL2
               ,NULL                              TRX_USER_KEY_LEVEL3
               ,NULL                              TRX_USER_KEY_LEVEL4
               ,NULL                              TRX_USER_KEY_LEVEL5
               ,NULL                              TRX_USER_KEY_LEVEL6
               ,NVL(poll.price_override,
                     pol.unit_price)              UNIT_PRICE
               ,NULL                              UNROUNDED_TAX_AMT
               ,NULL                              UNROUNDED_TAXABLE_AMT
               ,'N'                               MULTIPLE_JURISDICTIONS_FLAG
         FROM
              (SELECT /*+ NO_MERGE NO_EXPAND use_hash(fsp) use_hash(aps) use_hash(oi)
                          swap_join_inputs(fsp) swap_join_inputs(aps)
                          swap_join_inputs(oi) */
     	              poh.*, fsp.org_id fsp_org_id, fsp.set_of_books_id,
     	              aps.base_currency_code, oi.org_information2 oi_org_information2
                 FROM po_headers_all poh,
            	      financials_system_params_all fsp,
          	      ap_system_parameters_all aps,
          	      hr_organization_information oi
                WHERE poh.po_header_id = p_upg_trx_info_rec.trx_id
                  AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                  AND NVL(aps.org_id, -99) = NVL(poh.org_id,-99)
                  AND aps.set_of_books_id = fsp.set_of_books_id
                  AND oi.organization_id(+) = poh.org_id
                  AND oi.org_information_context(+) = 'Operating Unit Information'
              ) poh,
                fnd_currencies fc,
                po_lines_all pol,
                po_line_locations_all poll,
                zx_party_tax_profile ptp,
                ap_tax_codes_all atc,
                zx_rates_b rates,
                zx_regimes_b regimes,
                zx_taxes_b taxes,
                zx_status_b status
        WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
          AND poh.po_header_id = pol.po_header_id
          AND pol.po_header_id = poll.po_header_id
          AND pol.po_line_id = poll.po_line_id
          AND nvl(atc.org_id,-99)=nvl(poh.fsp_org_id,-99)
          AND poll.tax_code_id = atc.tax_id
          AND atc.tax_type NOT IN ('TAX_GROUP','USE')
          AND NOT EXISTS
              (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                 WHERE lines_gt.application_id   = 201
                   AND lines_gt.event_class_code = 'PO_PA'
                   AND lines_gt.entity_code      = 'PURCHASE_ORDER'
                   AND lines_gt.trx_id           = p_upg_trx_info_rec.trx_id
                   AND lines_gt.trx_line_id      = poll.line_location_id
                   AND lines_gt.trx_level_type   = 'SHIPMENT'
                   AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
              )
          AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
          AND ptp.party_type_code = 'OU'
          AND rates.source_id = atc.tax_id
          AND regimes.tax_regime_code(+) = rates.tax_regime_code
          AND taxes.tax_regime_code(+) = rates.tax_regime_code
          AND taxes.tax(+) = rates.tax
          AND taxes.content_owner_id(+) = rates.content_owner_id
          AND status.tax_regime_code(+) = rates.tax_regime_code
          AND status.tax(+) = rates.tax
          AND status.tax_status_code(+) = rates.tax_status_code
          AND status.content_owner_id(+) = rates.content_owner_id
          AND NOT EXISTS
              (SELECT 1 FROM zx_lines zxl
                WHERE zxl.APPLICATION_ID   = 201
                  AND zxl.EVENT_CLASS_CODE = 'PO_PA'
                  AND zxl.ENTITY_CODE      = 'PURCHASE_ORDER'
                  AND zxl.TRX_ID           = p_upg_trx_info_rec.trx_id
                  AND zxl.TRX_LINE_ID      = poll.line_location_id
                  AND zxl.TRX_LEVEL_TYPE   = 'SHIPMENT'
               );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                    'Number of Rows Inserted(Tax Code) = '||TO_CHAR(SQL%ROWCOUNT));
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_po',
                     'Inserting data into zx_lines');
    END IF;

    -- Insert data into zx_lines
    --
    INSERT INTO ZX_LINES(
                ADJUSTED_DOC_APPLICATION_ID
               ,ADJUSTED_DOC_DATE
               ,ADJUSTED_DOC_ENTITY_CODE
               ,ADJUSTED_DOC_EVENT_CLASS_CODE
               ,ADJUSTED_DOC_LINE_ID
               ,ADJUSTED_DOC_NUMBER
               ,ADJUSTED_DOC_TAX_LINE_ID
               ,ADJUSTED_DOC_TRX_ID
               ,ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,APPLICATION_ID
               ,APPLIED_FROM_APPLICATION_ID
               ,APPLIED_FROM_ENTITY_CODE
               ,APPLIED_FROM_EVENT_CLASS_CODE
               ,APPLIED_FROM_LINE_ID
               ,APPLIED_FROM_TRX_ID
               ,APPLIED_FROM_TRX_LEVEL_TYPE
               ,APPLIED_FROM_TRX_NUMBER
               ,APPLIED_TO_APPLICATION_ID
               ,APPLIED_TO_ENTITY_CODE
               ,APPLIED_TO_EVENT_CLASS_CODE
               ,APPLIED_TO_LINE_ID
               ,APPLIED_TO_TRX_ID
               ,APPLIED_TO_TRX_LEVEL_TYPE
               ,APPLIED_TO_TRX_NUMBER
               ,ASSOCIATED_CHILD_FROZEN_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,BASIS_RESULT_ID
               ,CAL_TAX_AMT
               ,CAL_TAX_AMT_FUNCL_CURR
               ,CAL_TAX_AMT_TAX_CURR
               ,CALC_RESULT_ID
               ,CANCEL_FLAG
               ,CHAR1
               ,CHAR10
               ,CHAR2
               ,CHAR3
               ,CHAR4
               ,CHAR5
               ,CHAR6
               ,CHAR7
               ,CHAR8
               ,CHAR9
               ,COMPOUNDING_DEP_TAX_FLAG
               ,COMPOUNDING_TAX_FLAG
               ,COMPOUNDING_TAX_MISS_FLAG
               ,CONTENT_OWNER_ID
               ,COPIED_FROM_OTHER_DOC_FLAG
               ,CREATED_BY
               ,CREATION_DATE
               ,CTRL_TOTAL_LINE_TX_AMT
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,DATE1
               ,DATE10
               ,DATE2
               ,DATE3
               ,DATE4
               ,DATE5
               ,DATE6
               ,DATE7
               ,DATE8
               ,DATE9
               ,DELETE_FLAG
               ,DIRECT_RATE_RESULT_ID
               ,DOC_EVENT_STATUS
               ,ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,ENTITY_CODE
               ,ESTABLISHMENT_ID
               ,EVAL_EXCPT_RESULT_ID
               ,EVAL_EXMPT_RESULT_ID
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,EXCEPTION_RATE
               ,EXEMPT_CERTIFICATE_NUMBER
               ,EXEMPT_RATE_MODIFIER
               ,EXEMPT_REASON
               ,EXEMPT_REASON_CODE
               ,FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,GLOBAL_ATTRIBUTE_CATEGORY
               ,GLOBAL_ATTRIBUTE1
               ,GLOBAL_ATTRIBUTE10
               ,GLOBAL_ATTRIBUTE11
               ,GLOBAL_ATTRIBUTE12
               ,GLOBAL_ATTRIBUTE13
               ,GLOBAL_ATTRIBUTE14
               ,GLOBAL_ATTRIBUTE15
               ,GLOBAL_ATTRIBUTE2
               ,GLOBAL_ATTRIBUTE3
               ,GLOBAL_ATTRIBUTE4
               ,GLOBAL_ATTRIBUTE5
               ,GLOBAL_ATTRIBUTE6
               ,GLOBAL_ATTRIBUTE7
               ,GLOBAL_ATTRIBUTE8
               ,GLOBAL_ATTRIBUTE9
               ,HISTORICAL_FLAG
               ,HQ_ESTB_PARTY_TAX_PROF_ID
               ,HQ_ESTB_REG_NUMBER
               ,INTERFACE_ENTITY_CODE
               ,INTERFACE_TAX_LINE_ID
               ,INTERNAL_ORG_LOCATION_ID
               ,INTERNAL_ORGANIZATION_ID
               ,ITEM_DIST_CHANGED_FLAG
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,LEDGER_ID
               ,LEGAL_ENTITY_ID
               ,LEGAL_ENTITY_TAX_REG_NUMBER
               ,LEGAL_JUSTIFICATION_TEXT1
               ,LEGAL_JUSTIFICATION_TEXT2
               ,LEGAL_JUSTIFICATION_TEXT3
               ,LEGAL_MESSAGE_APPL_2
               ,LEGAL_MESSAGE_BASIS
               ,LEGAL_MESSAGE_CALC
               ,LEGAL_MESSAGE_EXCPT
               ,LEGAL_MESSAGE_EXMPT
               ,LEGAL_MESSAGE_POS
               ,LEGAL_MESSAGE_RATE
               ,LEGAL_MESSAGE_STATUS
               ,LEGAL_MESSAGE_THRESHOLD
               ,LEGAL_MESSAGE_TRN
               ,LINE_AMT
               ,LINE_ASSESSABLE_VALUE
               ,MANUALLY_ENTERED_FLAG
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,MRC_LINK_TO_TAX_LINE_ID
               ,MRC_TAX_LINE_FLAG
               ,NREC_TAX_AMT
               ,NREC_TAX_AMT_FUNCL_CURR
               ,NREC_TAX_AMT_TAX_CURR
               ,NUMERIC1
               ,NUMERIC10
               ,NUMERIC2
               ,NUMERIC3
               ,NUMERIC4
               ,NUMERIC5
               ,NUMERIC6
               ,NUMERIC7
               ,NUMERIC8
               ,NUMERIC9
               ,OBJECT_VERSION_NUMBER
               ,OFFSET_FLAG
               ,OFFSET_LINK_TO_TAX_LINE_ID
               ,OFFSET_TAX_RATE_CODE
               ,ORIG_SELF_ASSESSED_FLAG
               ,ORIG_TAX_AMT
               ,ORIG_TAX_AMT_INCLUDED_FLAG
               ,ORIG_TAX_AMT_TAX_CURR
               ,ORIG_TAX_JURISDICTION_CODE
               ,ORIG_TAX_JURISDICTION_ID
               ,ORIG_TAX_RATE
               ,ORIG_TAX_RATE_CODE
               ,ORIG_TAX_RATE_ID
               ,ORIG_TAX_STATUS_CODE
               ,ORIG_TAX_STATUS_ID
               ,ORIG_TAXABLE_AMT
               ,ORIG_TAXABLE_AMT_TAX_CURR
               ,OTHER_DOC_LINE_AMT
               ,OTHER_DOC_LINE_TAX_AMT
               ,OTHER_DOC_LINE_TAXABLE_AMT
               ,OTHER_DOC_SOURCE
               ,OVERRIDDEN_FLAG
               ,PLACE_OF_SUPPLY
               ,PLACE_OF_SUPPLY_RESULT_ID
               ,PLACE_OF_SUPPLY_TYPE_CODE
               ,PRD_TOTAL_TAX_AMT
               ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,PRD_TOTAL_TAX_AMT_TAX_CURR
               ,PRECISION
               ,PROCESS_FOR_RECOVERY_FLAG
               ,PRORATION_CODE
               ,PURGE_FLAG
               ,RATE_RESULT_ID
               ,REC_TAX_AMT
               ,REC_TAX_AMT_FUNCL_CURR
               ,REC_TAX_AMT_TAX_CURR
               ,RECALC_REQUIRED_FLAG
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_LINE_QUANTITY
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,REGISTRATION_PARTY_TYPE
               ,RELATED_DOC_APPLICATION_ID
               ,RELATED_DOC_DATE
               ,RELATED_DOC_ENTITY_CODE
               ,RELATED_DOC_EVENT_CLASS_CODE
               ,RELATED_DOC_NUMBER
               ,RELATED_DOC_TRX_ID
               ,RELATED_DOC_TRX_LEVEL_TYPE
               ,REPORTING_CURRENCY_CODE
               ,REPORTING_ONLY_FLAG
               ,REPORTING_PERIOD_ID
               ,ROUNDING_LEVEL_CODE
               ,ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,ROUNDING_LVL_PARTY_TYPE
               ,ROUNDING_RULE_CODE
               ,SELF_ASSESSED_FLAG
               ,SETTLEMENT_FLAG
               ,STATUS_RESULT_ID
               ,SUMMARY_TAX_LINE_ID
               ,SYNC_WITH_PRVDR_FLAG
               ,TAX
               ,TAX_AMT
               ,TAX_AMT_FUNCL_CURR
               ,TAX_AMT_INCLUDED_FLAG
               ,TAX_AMT_TAX_CURR
               ,TAX_APPLICABILITY_RESULT_ID
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_BASE_MODIFIER_RATE
               ,TAX_CALCULATION_FORMULA
               ,TAX_CODE
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_DATE
               ,TAX_DATE_RULE_ID
               ,TAX_DETERMINE_DATE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_EXCEPTION_ID
               ,TAX_EXEMPTION_ID
               ,TAX_HOLD_CODE
               ,TAX_HOLD_RELEASED_CODE
               ,TAX_ID
               ,TAX_JURISDICTION_CODE
               ,TAX_JURISDICTION_ID
               ,TAX_LINE_ID
               ,TAX_LINE_NUMBER
               ,TAX_ONLY_LINE_FLAG
               ,TAX_POINT_DATE
               ,TAX_PROVIDER_ID
               ,TAX_RATE
               ,TAX_RATE_BEFORE_EXCEPTION
               ,TAX_RATE_BEFORE_EXEMPTION
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_RATE_NAME_BEFORE_EXCEPTION
               ,TAX_RATE_NAME_BEFORE_EXEMPTION
               ,TAX_RATE_TYPE
               ,TAX_REG_NUM_DET_RESULT_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_REGIME_TEMPLATE_ID
               ,TAX_REGISTRATION_ID
               ,TAX_REGISTRATION_NUMBER
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TAX_TYPE_CODE
               ,TAXABLE_AMT
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TAXABLE_BASIS_FORMULA
               ,TAXING_JURIS_GEOGRAPHY_ID
               ,THRESH_RESULT_ID
               ,TRX_CURRENCY_CODE
               ,TRX_DATE
               ,TRX_ID
               ,TRX_ID_LEVEL2
               ,TRX_ID_LEVEL3
               ,TRX_ID_LEVEL4
               ,TRX_ID_LEVEL5
               ,TRX_ID_LEVEL6
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_DATE
               ,TRX_LINE_ID
               ,TRX_LINE_INDEX
               ,TRX_LINE_NUMBER
               ,TRX_LINE_QUANTITY
               ,TRX_NUMBER
               ,TRX_USER_KEY_LEVEL1
               ,TRX_USER_KEY_LEVEL2
               ,TRX_USER_KEY_LEVEL3
               ,TRX_USER_KEY_LEVEL4
               ,TRX_USER_KEY_LEVEL5
               ,TRX_USER_KEY_LEVEL6
               ,UNIT_PRICE
               ,UNROUNDED_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,MULTIPLE_JURISDICTIONS_FLAG)
        SELECT /*+ leading(poh) NO_EXPAND
                   use_nl(fc,pol,poll,ptp,atc,atg,atc1,rates,regimes,taxes,status) */
                NULL 	                           ADJUSTED_DOC_APPLICATION_ID
               ,NULL 	                           ADJUSTED_DOC_DATE
               ,NULL	                           ADJUSTED_DOC_ENTITY_CODE
               ,NULL                               ADJUSTED_DOC_EVENT_CLASS_CODE
               ,NULL                               ADJUSTED_DOC_LINE_ID
               ,NULL                               ADJUSTED_DOC_NUMBER
               ,NULL                               ADJUSTED_DOC_TAX_LINE_ID
               ,NULL                               ADJUSTED_DOC_TRX_ID
               ,NULL                               ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,201	                           APPLICATION_ID
               ,NULL                               APPLIED_FROM_APPLICATION_ID
               ,NULL                               APPLIED_FROM_ENTITY_CODE
               ,NULL                               APPLIED_FROM_EVENT_CLASS_CODE
               ,NULL                               APPLIED_FROM_LINE_ID
               ,NULL                               APPLIED_FROM_TRX_ID
               ,NULL                               APPLIED_FROM_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_FROM_TRX_NUMBER
               ,NULL	                           APPLIED_TO_APPLICATION_ID
               ,NULL	                           APPLIED_TO_ENTITY_CODE
               ,NULL	                           APPLIED_TO_EVENT_CLASS_CODE
               ,NULL	                           APPLIED_TO_LINE_ID
               ,NULL	                           APPLIED_TO_TRX_ID
               ,NULL	                           APPLIED_TO_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_TO_TRX_NUMBER
               ,'N' 	                           ASSOCIATED_CHILD_FROZEN_FLAG
               ,poll.ATTRIBUTE_CATEGORY            ATTRIBUTE_CATEGORY
               ,poll.ATTRIBUTE1 	           ATTRIBUTE1
               ,poll.ATTRIBUTE10	           ATTRIBUTE10
               ,poll.ATTRIBUTE11	           ATTRIBUTE11
               ,poll.ATTRIBUTE12	           ATTRIBUTE12
               ,poll.ATTRIBUTE13	           ATTRIBUTE13
               ,poll.ATTRIBUTE14	           ATTRIBUTE14
               ,poll.ATTRIBUTE15	           ATTRIBUTE15
               ,poll.ATTRIBUTE2 	           ATTRIBUTE2
               ,poll.ATTRIBUTE3 	           ATTRIBUTE3
               ,poll.ATTRIBUTE4 	           ATTRIBUTE4
               ,poll.ATTRIBUTE5 	           ATTRIBUTE5
               ,poll.ATTRIBUTE6 	           ATTRIBUTE6
               ,poll.ATTRIBUTE7 	           ATTRIBUTE7
               ,poll.ATTRIBUTE8 	           ATTRIBUTE8
               ,poll.ATTRIBUTE9 	           ATTRIBUTE9
               ,NULL			           BASIS_RESULT_ID
               ,NULL	                           CAL_TAX_AMT
               ,NULL	                           CAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           CAL_TAX_AMT_TAX_CURR
               ,NULL	                           CALC_RESULT_ID
               ,'N'	                           CANCEL_FLAG
               ,NULL	                           CHAR1
               ,NULL	                           CHAR10
               ,NULL	                           CHAR2
               ,NULL	                           CHAR3
               ,NULL	                           CHAR4
               ,NULL	                           CHAR5
               ,NULL	                           CHAR6
               ,NULL	                           CHAR7
               ,NULL	                           CHAR8
               ,NULL	                           CHAR9
               ,'N'	                           COMPOUNDING_DEP_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_MISS_FLAG
               ,ptp.party_tax_profile_id	   CONTENT_OWNER_ID
               ,'N'	                           COPIED_FROM_OTHER_DOC_FLAG
               ,1	                           CREATED_BY
               ,SYSDATE                            CREATION_DATE
               ,NULL		                   CTRL_TOTAL_LINE_TX_AMT
               ,poh.rate_date 	                   CURRENCY_CONVERSION_DATE
               ,poh.rate 	                   CURRENCY_CONVERSION_RATE
               ,poh.rate_type 	                   CURRENCY_CONVERSION_TYPE
               ,NULL	                           DATE1
               ,NULL	                           DATE10
               ,NULL	                           DATE2
               ,NULL	                           DATE3
               ,NULL	                           DATE4
               ,NULL	                           DATE5
               ,NULL	                           DATE6
               ,NULL	                           DATE7
               ,NULL	                           DATE8
               ,NULL	                           DATE9
               ,'N'	                           DELETE_FLAG
               ,NULL	                           DIRECT_RATE_RESULT_ID
               ,NULL	                           DOC_EVENT_STATUS
               ,'N'	                           ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,'PURCHASE_ORDER' 	           ENTITY_CODE
               ,NULL	                           ESTABLISHMENT_ID
               ,NULL	                           EVAL_EXCPT_RESULT_ID
               ,NULL	                           EVAL_EXMPT_RESULT_ID
               ,'PO_PA' 		           EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	   EVENT_TYPE_CODE
               ,NULL                               EXCEPTION_RATE
               ,NULL	                           EXEMPT_CERTIFICATE_NUMBER
               ,NULL	                           EXEMPT_RATE_MODIFIER
               ,NULL	                           EXEMPT_REASON
               ,NULL	                           EXEMPT_REASON_CODE
               ,'N'	                           FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,poll.GLOBAL_ATTRIBUTE_CATEGORY     GLOBAL_ATTRIBUTE_CATEGORY
               ,poll.GLOBAL_ATTRIBUTE1 	           GLOBAL_ATTRIBUTE1
               ,poll.GLOBAL_ATTRIBUTE10	           GLOBAL_ATTRIBUTE10
               ,poll.GLOBAL_ATTRIBUTE11	           GLOBAL_ATTRIBUTE11
               ,poll.GLOBAL_ATTRIBUTE12	           GLOBAL_ATTRIBUTE12
               ,poll.GLOBAL_ATTRIBUTE13	           GLOBAL_ATTRIBUTE13
               ,poll.GLOBAL_ATTRIBUTE14	           GLOBAL_ATTRIBUTE14
               ,poll.GLOBAL_ATTRIBUTE15	           GLOBAL_ATTRIBUTE15
               ,poll.GLOBAL_ATTRIBUTE2             GLOBAL_ATTRIBUTE2
               ,poll.GLOBAL_ATTRIBUTE3             GLOBAL_ATTRIBUTE3
               ,poll.GLOBAL_ATTRIBUTE4             GLOBAL_ATTRIBUTE4
               ,poll.GLOBAL_ATTRIBUTE5             GLOBAL_ATTRIBUTE5
               ,poll.GLOBAL_ATTRIBUTE6             GLOBAL_ATTRIBUTE6
               ,poll.GLOBAL_ATTRIBUTE7             GLOBAL_ATTRIBUTE7
               ,poll.GLOBAL_ATTRIBUTE8             GLOBAL_ATTRIBUTE8
               ,poll.GLOBAL_ATTRIBUTE9             GLOBAL_ATTRIBUTE9
               ,'Y'	                           HISTORICAL_FLAG
               ,NULL                               HQ_ESTB_PARTY_TAX_PROF_ID
               ,NULL	                           HQ_ESTB_REG_NUMBER
               ,NULL	                           INTERFACE_ENTITY_CODE
               ,NULL	                           INTERFACE_TAX_LINE_ID
               ,NULL                               INTERNAL_ORG_LOCATION_ID
               ,nvl(poh.org_id,-99)                INTERNAL_ORGANIZATION_ID
               ,'N'                                ITEM_DIST_CHANGED_FLAG
               ,NULL	                           LAST_MANUAL_ENTRY
               ,SYSDATE	                           LAST_UPDATE_DATE
               ,1	                           LAST_UPDATE_LOGIN
               ,1	                           LAST_UPDATED_BY
               ,poh.set_of_books_id 	           LEDGER_ID
               ,NVL(poh.oi_org_information2, -99)  LEGAL_ENTITY_ID
               ,NULL                               LEGAL_ENTITY_TAX_REG_NUMBER
               ,NULL                               LEGAL_JUSTIFICATION_TEXT1
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT2
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT3
               ,NULL                               LEGAL_MESSAGE_APPL_2
               ,NULL	                           LEGAL_MESSAGE_BASIS
               ,NULL	                           LEGAL_MESSAGE_CALC
               ,NULL	                           LEGAL_MESSAGE_EXCPT
               ,NULL	                           LEGAL_MESSAGE_EXMPT
               ,NULL	                           LEGAL_MESSAGE_POS
               ,NULL	                           LEGAL_MESSAGE_RATE
               ,NULL                               LEGAL_MESSAGE_STATUS
               ,NULL	                           LEGAL_MESSAGE_THRESHOLD
               ,NULL	                           LEGAL_MESSAGE_TRN
               ,DECODE(pol.purchase_basis,
                 'TEMP LABOR', NVL(POLL.amount,0),
                 'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                    NVL(poll.quantity,0) *
                                    NVL(poll.price_override,NVL(pol.unit_price,0))),
                  NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                                   LINE_AMT
               ,NULL	                           LINE_ASSESSABLE_VALUE
               ,'N'	                           MANUALLY_ENTERED_FLAG
               ,fc.minimum_accountable_unit	   MINIMUM_ACCOUNTABLE_UNIT
               ,NULL	                           MRC_LINK_TO_TAX_LINE_ID
               ,'N'	                           MRC_TAX_LINE_FLAG
               ,NULL	                           NREC_TAX_AMT
               ,NULL	                           NREC_TAX_AMT_FUNCL_CURR
               ,NULL	                           NREC_TAX_AMT_TAX_CURR
               ,NULL	                           NUMERIC1
               ,NULL	                           NUMERIC10
               ,NULL	                           NUMERIC2
               ,NULL	                           NUMERIC3
               ,NULL	                           NUMERIC4
               ,NULL	                           NUMERIC5
               ,NULL	                           NUMERIC6
               ,NULL	                           NUMERIC7
               ,NULL	                           NUMERIC8
               ,NULL	                           NUMERIC9
               ,1	                           OBJECT_VERSION_NUMBER
               ,'N'	                           OFFSET_FLAG
               ,NULL	                           OFFSET_LINK_TO_TAX_LINE_ID
               ,NULL	                           OFFSET_TAX_RATE_CODE
               ,'N'	                           ORIG_SELF_ASSESSED_FLAG
               ,NULL	                           ORIG_TAX_AMT
               ,NULL	                           ORIG_TAX_AMT_INCLUDED_FLAG
               ,NULL	                           ORIG_TAX_AMT_TAX_CURR
               ,NULL	                           ORIG_TAX_JURISDICTION_CODE
               ,NULL	                           ORIG_TAX_JURISDICTION_ID
               ,NULL	                           ORIG_TAX_RATE
               ,NULL	                           ORIG_TAX_RATE_CODE
               ,NULL	                           ORIG_TAX_RATE_ID
               ,NULL	                           ORIG_TAX_STATUS_CODE
               ,NULL	                           ORIG_TAX_STATUS_ID
               ,NULL	                           ORIG_TAXABLE_AMT
               ,NULL	                           ORIG_TAXABLE_AMT_TAX_CURR
               ,NULL	                           OTHER_DOC_LINE_AMT
               ,NULL	                           OTHER_DOC_LINE_TAX_AMT
               ,NULL	                           OTHER_DOC_LINE_TAXABLE_AMT
               ,NULL	                           OTHER_DOC_SOURCE
               ,'N'	                           OVERRIDDEN_FLAG
               ,NULL	                           PLACE_OF_SUPPLY
               ,NULL	                           PLACE_OF_SUPPLY_RESULT_ID
               ,NULL                               PLACE_OF_SUPPLY_TYPE_CODE
               ,NULL	                           PRD_TOTAL_TAX_AMT
               ,NULL	                           PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           PRD_TOTAL_TAX_AMT_TAX_CURR
               ,NVL(fc.precision, 0)               PRECISION
               ,'N'	                           PROCESS_FOR_RECOVERY_FLAG
               ,NULL	                           PRORATION_CODE
               ,'N'	                           PURGE_FLAG
               ,NULL	                           RATE_RESULT_ID
               ,NULL	                           REC_TAX_AMT
               ,NULL	                           REC_TAX_AMT_FUNCL_CURR
               ,NULL	                           REC_TAX_AMT_TAX_CURR
               ,'N'	                           RECALC_REQUIRED_FLAG
               ,'MIGRATED'                         RECORD_TYPE_CODE
               ,NULL	                           REF_DOC_APPLICATION_ID
               ,NULL	                           REF_DOC_ENTITY_CODE
               ,NULL	                           REF_DOC_EVENT_CLASS_CODE
               ,NULL	                           REF_DOC_LINE_ID
               ,NULL	                           REF_DOC_LINE_QUANTITY
               ,NULL	                           REF_DOC_TRX_ID
               ,NULL	                           REF_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REGISTRATION_PARTY_TYPE
               ,NULL	                           RELATED_DOC_APPLICATION_ID
               ,NULL	                           RELATED_DOC_DATE
               ,NULL	                           RELATED_DOC_ENTITY_CODE
               ,NULL	                           RELATED_DOC_EVENT_CLASS_CODE
               ,NULL	                           RELATED_DOC_NUMBER
               ,NULL	                           RELATED_DOC_TRX_ID
               ,NULL	                           RELATED_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REPORTING_CURRENCY_CODE
               ,'N'	                           REPORTING_ONLY_FLAG
               ,NULL	                           REPORTING_PERIOD_ID
               ,NULL	                           ROUNDING_LEVEL_CODE
               ,NULL	                           ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,NULL	                           ROUNDING_LVL_PARTY_TYPE
               ,NULL	                           ROUNDING_RULE_CODE
               ,'N'	                           SELF_ASSESSED_FLAG
               ,'N'                                SETTLEMENT_FLAG
               ,NULL                               STATUS_RESULT_ID
               ,NULL                               SUMMARY_TAX_LINE_ID
               ,NULL                               SYNC_WITH_PRVDR_FLAG
               ,rates.tax                          TAX
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)  TAX_AMT
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)
                                                   TAX_AMT_FUNCL_CURR
               ,'N'                                TAX_AMT_INCLUDED_FLAG
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit) TAX_AMT_TAX_CURR
               ,NULL                               TAX_APPLICABILITY_RESULT_ID
               ,'Y'                                TAX_APPORTIONMENT_FLAG
               ,RANK() OVER
                 (PARTITION BY
                   poh.po_header_id,
                   poll.line_location_id,
                   rates.tax_regime_code,
                   rates.tax
                  ORDER BY atg.tax_code_id)        TAX_APPORTIONMENT_LINE_NUMBER
               ,NULL                               TAX_BASE_MODIFIER_RATE
               ,'STANDARD_TC'                      TAX_CALCULATION_FORMULA
               ,NULL                               TAX_CODE
               ,taxes.tax_currency_code            TAX_CURRENCY_CODE
               ,poh.rate_date 		           TAX_CURRENCY_CONVERSION_DATE
               ,poh.rate 		           TAX_CURRENCY_CONVERSION_RATE
               ,poh.rate_type 		           TAX_CURRENCY_CONVERSION_TYPE
               ,poll.last_update_date              TAX_DATE
               ,NULL                               TAX_DATE_RULE_ID
               ,poll.last_update_date              TAX_DETERMINE_DATE
               ,'PURCHASE_TRANSACTION' 	           TAX_EVENT_CLASS_CODE
               ,'VALIDATE'  		           TAX_EVENT_TYPE_CODE
               ,NULL                               TAX_EXCEPTION_ID
               ,NULL                               TAX_EXEMPTION_ID
               ,NULL                               TAX_HOLD_CODE
               ,NULL                               TAX_HOLD_RELEASED_CODE
               ,taxes.tax_id                       TAX_ID
               ,NULL                               TAX_JURISDICTION_CODE
               ,NULL                               TAX_JURISDICTION_ID
               ,zx_lines_s.nextval                 TAX_LINE_ID
               ,RANK() OVER
                (PARTITION BY poh.po_header_id
                     ORDER BY poll.line_location_id,
                              atg.tax_code_id,
                              atc.tax_id)         TAX_LINE_NUMBER
               ,'N'                               TAX_ONLY_LINE_FLAG
               ,poll.last_update_date             TAX_POINT_DATE
               ,NULL                              TAX_PROVIDER_ID
               ,rates.percentage_rate  	          TAX_RATE
               ,NULL	                          TAX_RATE_BEFORE_EXCEPTION
               ,NULL                              TAX_RATE_BEFORE_EXEMPTION
               ,rates.tax_rate_code               TAX_RATE_CODE
               ,rates.tax_rate_id                 TAX_RATE_ID
               ,NULL                              TAX_RATE_NAME_BEFORE_EXCEPTION
               ,NULL                              TAX_RATE_NAME_BEFORE_EXEMPTION
               ,NULL                              TAX_RATE_TYPE
               ,NULL                              TAX_REG_NUM_DET_RESULT_ID
               ,rates.tax_regime_code             TAX_REGIME_CODE
               ,regimes.tax_regime_id             TAX_REGIME_ID
               ,NULL                              TAX_REGIME_TEMPLATE_ID
               ,NULL                              TAX_REGISTRATION_ID
               ,NULL                              TAX_REGISTRATION_NUMBER
               ,rates.tax_status_code             TAX_STATUS_CODE
               ,status.tax_status_id              TAX_STATUS_ID
               ,NULL                              TAX_TYPE_CODE
               ,NULL                              TAXABLE_AMT
               ,NULL                              TAXABLE_AMT_FUNCL_CURR
               ,NULL                              TAXABLE_AMT_TAX_CURR
               ,'STANDARD_TB'                     TAXABLE_BASIS_FORMULA
               ,NULL                              TAXING_JURIS_GEOGRAPHY_ID
               ,NULL                              THRESH_RESULT_ID
               ,NVL(poh.currency_code,
                    poh.base_currency_code)       TRX_CURRENCY_CODE
               ,poh.last_update_date              TRX_DATE
               ,poh.po_header_id                  TRX_ID
               ,NULL                              TRX_ID_LEVEL2
               ,NULL                              TRX_ID_LEVEL3
               ,NULL                              TRX_ID_LEVEL4
               ,NULL                              TRX_ID_LEVEL5
               ,NULL                              TRX_ID_LEVEL6
               ,'SHIPMENT'                        TRX_LEVEL_TYPE
               ,poll.LAST_UPDATE_DATE             TRX_LINE_DATE
               ,poll.line_location_id             TRX_LINE_ID
               ,NULL                              TRX_LINE_INDEX
               ,poll.SHIPMENT_NUM                 TRX_LINE_NUMBER
               ,poll.quantity 		          TRX_LINE_QUANTITY
               ,poh.segment1                      TRX_NUMBER
               ,NULL                              TRX_USER_KEY_LEVEL1
               ,NULL                              TRX_USER_KEY_LEVEL2
               ,NULL                              TRX_USER_KEY_LEVEL3
               ,NULL                              TRX_USER_KEY_LEVEL4
               ,NULL                              TRX_USER_KEY_LEVEL5
               ,NULL                              TRX_USER_KEY_LEVEL6
               ,NVL(poll.price_override,
                     pol.unit_price)              UNIT_PRICE
               ,NULL                              UNROUNDED_TAX_AMT
               ,NULL                              UNROUNDED_TAXABLE_AMT
               ,'N'                               MULTIPLE_JURISDICTIONS_FLAG
         FROM
              (SELECT /*+ NO_MERGE NO_EXPAND use_hash(fsp) use_hash(aps) use_hash(oi)
                          swap_join_inputs(fsp) swap_join_inputs(aps)
                          swap_join_inputs(oi) */
     	              poh.*, fsp.org_id fsp_org_id, fsp.set_of_books_id,
     	              aps.base_currency_code, oi.org_information2 oi_org_information2
                 FROM po_headers_all poh,
            	      financials_system_params_all fsp,
          	      ap_system_parameters_all aps,
          	      hr_organization_information oi
                WHERE poh.po_header_id = p_upg_trx_info_rec.trx_id
                  AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                  AND NVL(aps.org_id, -99) = NVL(poh.org_id,-99)
                  AND aps.set_of_books_id = fsp.set_of_books_id
                  AND oi.organization_id(+) = poh.org_id
                  AND oi.org_information_context(+) = 'Operating Unit Information'
              ) poh,
                fnd_currencies fc,
                po_lines_all pol,
                po_line_locations_all poll,
                zx_party_tax_profile ptp,
                ap_tax_codes_all atc,
                ar_tax_group_codes_all atg,
                ap_tax_codes_all atc1,
                zx_rates_b rates,
                zx_regimes_b regimes,
                zx_taxes_b taxes,
                zx_status_b status
        WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
          AND poh.po_header_id = pol.po_header_id
          AND pol.po_header_id = poll.po_header_id
          AND pol.po_line_id = poll.po_line_id
          AND nvl(atc.org_id,-99)=nvl(poh.fsp_org_id,-99)
          AND poll.tax_code_id = atc.tax_id
          AND atc.tax_type = 'TAX_GROUP'
          --Bug 8352135
 	        AND atg.start_date <= poll.last_update_date
 	        AND (atg.end_date >= poll.last_update_date OR atg.end_date IS NULL)
          AND poll.tax_code_id = atg.tax_group_id
          AND atc1.tax_id = atg.tax_code_id
          AND atc1.start_date <= poll.last_update_date
          AND(atc1.inactive_date >= poll.last_update_date OR atc1.inactive_date IS NULL)
          AND NOT EXISTS
              (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                 WHERE lines_gt.application_id   = 201
                   AND lines_gt.event_class_code = 'PO_PA'
                   AND lines_gt.entity_code      = 'PURCHASE_ORDER'
                   AND lines_gt.trx_id           = p_upg_trx_info_rec.trx_id
                   AND lines_gt.trx_line_id      = poll.line_location_id
                   AND lines_gt.trx_level_type   = 'SHIPMENT'
                   AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
              )
          AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
          AND ptp.party_type_code = 'OU'
          AND rates.source_id = atg.tax_code_id
          AND regimes.tax_regime_code(+) = rates.tax_regime_code
          AND taxes.tax_regime_code(+) = rates.tax_regime_code
          AND taxes.tax(+) = rates.tax
          AND taxes.content_owner_id(+) = rates.content_owner_id
          AND status.tax_regime_code(+) = rates.tax_regime_code
          AND status.tax(+) = rates.tax
          AND status.tax_status_code(+) = rates.tax_status_code
          AND status.content_owner_id(+) = rates.content_owner_id
          AND NOT EXISTS
              (SELECT 1 FROM zx_lines zxl
                WHERE zxl.APPLICATION_ID   = 201
                  AND zxl.EVENT_CLASS_CODE = 'PO_PA'
                  AND zxl.ENTITY_CODE      = 'PURCHASE_ORDER'
                  AND zxl.TRX_ID           = p_upg_trx_info_rec.trx_id
                  AND zxl.TRX_LINE_ID      = poll.line_location_id
                  AND zxl.TRX_LEVEL_TYPE   = 'SHIPMENT'
               );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                    'Number of Rows Inserted(Tax Group = ' || TO_CHAR(SQL%ROWCOUNT));
    END IF;

    -- COMMIT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_po',
                    'Inserting data into zx_rec_nrec_dist');
    END IF;

    -- Insert data into zx_rec_nrec_dist
    --
    INSERT INTO ZX_REC_NREC_DIST(
              TAX_LINE_ID
             ,REC_NREC_TAX_DIST_ID
             ,REC_NREC_TAX_DIST_NUMBER
             ,APPLICATION_ID
             ,CONTENT_OWNER_ID
             ,CURRENCY_CONVERSION_DATE
             ,CURRENCY_CONVERSION_RATE
             ,CURRENCY_CONVERSION_TYPE
             ,ENTITY_CODE
             ,EVENT_CLASS_CODE
             ,EVENT_TYPE_CODE
             ,LEDGER_ID
             ,MINIMUM_ACCOUNTABLE_UNIT
             ,PRECISION
             ,RECORD_TYPE_CODE
             ,REF_DOC_APPLICATION_ID
             ,REF_DOC_ENTITY_CODE
             ,REF_DOC_EVENT_CLASS_CODE
             ,REF_DOC_LINE_ID
             ,REF_DOC_TRX_ID
             ,REF_DOC_TRX_LEVEL_TYPE
             ,SUMMARY_TAX_LINE_ID
             ,TAX
             ,TAX_APPORTIONMENT_LINE_NUMBER
             ,TAX_CURRENCY_CODE
             ,TAX_CURRENCY_CONVERSION_DATE
             ,TAX_CURRENCY_CONVERSION_RATE
             ,TAX_CURRENCY_CONVERSION_TYPE
             ,TAX_EVENT_CLASS_CODE
             ,TAX_EVENT_TYPE_CODE
             ,TAX_ID
             ,TAX_LINE_NUMBER
             ,TAX_RATE
             ,TAX_RATE_CODE
             ,TAX_RATE_ID
             ,TAX_REGIME_CODE
             ,TAX_REGIME_ID
             ,TAX_STATUS_CODE
             ,TAX_STATUS_ID
             ,TRX_CURRENCY_CODE
             ,TRX_ID
             ,TRX_LEVEL_TYPE
             ,TRX_LINE_ID
             ,TRX_LINE_NUMBER
             ,TRX_NUMBER
             ,UNIT_PRICE
             ,ACCOUNT_CCID
             ,ACCOUNT_STRING
             ,ADJUSTED_DOC_TAX_DIST_ID
             ,APPLIED_FROM_TAX_DIST_ID
             ,APPLIED_TO_DOC_CURR_CONV_RATE
             ,AWARD_ID
             ,EXPENDITURE_ITEM_DATE
             ,EXPENDITURE_ORGANIZATION_ID
             ,EXPENDITURE_TYPE
             ,FUNC_CURR_ROUNDING_ADJUSTMENT
             ,GL_DATE
             ,INTENDED_USE
             ,ITEM_DIST_NUMBER
             ,MRC_LINK_TO_TAX_DIST_ID
             ,ORIG_REC_NREC_RATE
             ,ORIG_REC_NREC_TAX_AMT
             ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
             ,ORIG_REC_RATE_CODE
             ,PER_TRX_CURR_UNIT_NR_AMT
             ,PER_UNIT_NREC_TAX_AMT
             ,PRD_TAX_AMT
             ,PRICE_DIFF
             ,PROJECT_ID
             ,QTY_DIFF
             ,RATE_TAX_FACTOR
             ,REC_NREC_RATE
             ,REC_NREC_TAX_AMT
             ,REC_NREC_TAX_AMT_FUNCL_CURR
             ,REC_NREC_TAX_AMT_TAX_CURR
             ,RECOVERY_RATE_CODE
             ,RECOVERY_RATE_ID
             ,RECOVERY_TYPE_CODE
             ,RECOVERY_TYPE_ID
             ,REF_DOC_CURR_CONV_RATE
             ,REF_DOC_DIST_ID
             ,REF_DOC_PER_UNIT_NREC_TAX_AMT
             ,REF_DOC_TAX_DIST_ID
             ,REF_DOC_TRX_LINE_DIST_QTY
             ,REF_DOC_UNIT_PRICE
             ,REF_PER_TRX_CURR_UNIT_NR_AMT
             ,REVERSED_TAX_DIST_ID
             ,ROUNDING_RULE_CODE
             ,TASK_ID
             ,TAXABLE_AMT_FUNCL_CURR
             ,TAXABLE_AMT_TAX_CURR
             ,TRX_LINE_DIST_AMT
             ,TRX_LINE_DIST_ID
             ,TRX_LINE_DIST_QTY
             ,TRX_LINE_DIST_TAX_AMT
             ,UNROUNDED_REC_NREC_TAX_AMT
             ,UNROUNDED_TAXABLE_AMT
             ,TAXABLE_AMT
             ,ATTRIBUTE_CATEGORY
             ,ATTRIBUTE1
             ,ATTRIBUTE2
             ,ATTRIBUTE3
             ,ATTRIBUTE4
             ,ATTRIBUTE5
             ,ATTRIBUTE6
             ,ATTRIBUTE7
             ,ATTRIBUTE8
             ,ATTRIBUTE9
             ,ATTRIBUTE10
             ,ATTRIBUTE11
             ,ATTRIBUTE12
             ,ATTRIBUTE13
             ,ATTRIBUTE14
             ,ATTRIBUTE15
             ,HISTORICAL_FLAG
             ,OVERRIDDEN_FLAG
             ,SELF_ASSESSED_FLAG
             ,TAX_APPORTIONMENT_FLAG
             ,TAX_ONLY_LINE_FLAG
             ,INCLUSIVE_FLAG
             ,MRC_TAX_DIST_FLAG
             ,REC_TYPE_RULE_FLAG
             ,NEW_REC_RATE_CODE_FLAG
             ,RECOVERABLE_FLAG
             ,REVERSE_FLAG
             ,REC_RATE_DET_RULE_FLAG
             ,BACKWARD_COMPATIBILITY_FLAG
             ,FREEZE_FLAG
             ,POSTING_FLAG
             ,LEGAL_ENTITY_ID
             ,CREATED_BY
             ,CREATION_DATE
             ,LAST_MANUAL_ENTRY
             ,LAST_UPDATE_DATE
             ,LAST_UPDATE_LOGIN
             ,LAST_UPDATED_BY
             ,OBJECT_VERSION_NUMBER)
       SELECT /*+ NO_EXPAND leading(pohzd) use_nl(fc, rates)*/
              pohzd.tax_line_id			         TAX_LINE_ID
              ,zx_rec_nrec_dist_s.nextval                REC_NREC_TAX_DIST_ID
              ,DECODE(tmp.rec_flag,
                'Y', (RANK() OVER (PARTITION BY pohzd.po_header_id,
                                   pohzd.p_po_distribution_id
                                   ORDER BY
                                   pohzd.p_po_distribution_id,pohzd.tax_rate_id))*2-1,
                'N', (RANK() OVER (PARTITION BY pohzd.po_header_id,
                                   pohzd.p_po_distribution_id
                                   ORDER BY
                                   pohzd.p_po_distribution_id,pohzd.tax_rate_id))*2)
                                                         REC_NREC_TAX_DIST_NUMBER
              ,201 					 APPLICATION_ID
              ,pohzd.content_owner_id			 CONTENT_OWNER_ID
              ,pohzd.CURRENCY_CONVERSION_DATE		 CURRENCY_CONVERSION_DATE
              ,pohzd.CURRENCY_CONVERSION_RATE		 CURRENCY_CONVERSION_RATE
              ,pohzd.CURRENCY_CONVERSION_TYPE		 CURRENCY_CONVERSION_TYPE
              ,'PURCHASE_ORDER' 			 ENTITY_CODE
              ,'PO_PA'			 	         EVENT_CLASS_CODE
              ,'PURCHASE ORDER CREATED'		 	 EVENT_TYPE_CODE
              ,pohzd.ledger_id				 LEDGER_ID
              ,pohzd.MINIMUM_ACCOUNTABLE_UNIT		 MINIMUM_ACCOUNTABLE_UNIT
              ,pohzd.PRECISION				 PRECISION
              ,'MIGRATED' 				 RECORD_TYPE_CODE
              ,NULL 					 REF_DOC_APPLICATION_ID
              ,NULL 					 REF_DOC_ENTITY_CODE
              ,NULL					 REF_DOC_EVENT_CLASS_CODE
              ,NULL					 REF_DOC_LINE_ID
              ,NULL					 REF_DOC_TRX_ID
              ,NULL					 REF_DOC_TRX_LEVEL_TYPE
              ,NULL 					 SUMMARY_TAX_LINE_ID
              ,pohzd.tax				 TAX
              ,pohzd.TAX_APPORTIONMENT_LINE_NUMBER       TAX_APPORTIONMENT_LINE_NUMBER
              ,pohzd.TAX_CURRENCY_CODE			 TAX_CURRENCY_CODE
              ,pohzd.TAX_CURRENCY_CONVERSION_DATE	 TAX_CURRENCY_CONVERSION_DATE
              ,pohzd.TAX_CURRENCY_CONVERSION_RATE	 TAX_CURRENCY_CONVERSION_RATE
              ,pohzd.TAX_CURRENCY_CONVERSION_TYPE	 TAX_CURRENCY_CONVERSION_TYPE
              ,'PURCHASE_TRANSACTION' 		 	 TAX_EVENT_CLASS_CODE
              ,'VALIDATE'				 TAX_EVENT_TYPE_CODE
              ,pohzd.tax_id				 TAX_ID
              ,pohzd.tax_line_number			 TAX_LINE_NUMBER
              ,pohzd.tax_rate				 TAX_RATE
              ,pohzd.tax_rate_code 			 TAX_RATE_CODE
              ,pohzd.tax_rate_id			 TAX_RATE_ID
              ,pohzd.tax_regime_code	 		 TAX_REGIME_CODE
              ,pohzd.tax_regime_id		         TAX_REGIME_ID
              ,pohzd.tax_status_code			 TAX_STATUS_CODE
              ,pohzd.tax_status_id	 		 TAX_STATUS_ID
              ,pohzd.trx_currency_code			 TRX_CURRENCY_CODE
              ,pohzd.trx_id				 TRX_ID
              ,'SHIPMENT' 				 TRX_LEVEL_TYPE
              ,pohzd.trx_line_id			 TRX_LINE_ID
              ,pohzd.trx_line_number			 TRX_LINE_NUMBER
              ,pohzd.trx_number				 TRX_NUMBER
              ,pohzd.unit_price				 UNIT_PRICE
              ,NULL					 ACCOUNT_CCID
              ,NULL					 ACCOUNT_STRING
              ,NULL					 ADJUSTED_DOC_TAX_DIST_ID
              ,NULL					 APPLIED_FROM_TAX_DIST_ID
              ,NULL					 APPLIED_TO_DOC_CURR_CONV_RATE
              ,NULL					 AWARD_ID
              ,pohzd.p_expenditure_item_date		 EXPENDITURE_ITEM_DATE
              ,pohzd.p_expenditure_organization_id	 EXPENDITURE_ORGANIZATION_ID
              ,pohzd.p_expenditure_type			 EXPENDITURE_TYPE
              ,NULL					 FUNC_CURR_ROUNDING_ADJUSTMENT
              ,NULL					 GL_DATE
              ,NULL					 INTENDED_USE
              ,NULL					 ITEM_DIST_NUMBER
              ,NULL					 MRC_LINK_TO_TAX_DIST_ID
              ,NULL					 ORIG_REC_NREC_RATE
              ,NULL					 ORIG_REC_NREC_TAX_AMT
              ,NULL					 ORIG_REC_NREC_TAX_AMT_TAX_CURR
              ,NULL					 ORIG_REC_RATE_CODE
              ,NULL					 PER_TRX_CURR_UNIT_NR_AMT
              ,NULL					 PER_UNIT_NREC_TAX_AMT
              ,NULL					 PRD_TAX_AMT
              ,NULL					 PRICE_DIFF
              ,pohzd.p_project_id			 PROJECT_ID
              ,NULL					 QTY_DIFF
              ,NULL					 RATE_TAX_FACTOR
              ,DECODE(tmp.rec_flag,
                'Y', NVL(NVL(pohzd.p_recovery_rate,
                              pohzd.d_rec_rate), 0),
                'N', 100 - NVL(NVL(pohzd.p_recovery_rate,
                                 pohzd.d_rec_rate), 0))  REC_NREC_RATE
              ,DECODE(tmp.rec_flag,
                      'N',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                               (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                   (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                      'Y',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                     )                                   REC_NREC_TAX_AMT
              ,DECODE(tmp.rec_flag,
                      'N',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                               (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                   (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                      'Y',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                     )                                   REC_NREC_TAX_AMT_FUNCL_CURR
              ,DECODE(tmp.rec_flag,
                       'N',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                               (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                   (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                      'Y',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                     )                                   REC_NREC_TAX_AMT_TAX_CURR
               ,NVL(rates.tax_rate_code,
                                     'AD_HOC_RECOVERY')  RECOVERY_RATE_CODE
               ,rates.tax_rate_id                        RECOVERY_RATE_ID
               ,DECODE(tmp.rec_flag,'N', NULL,
                       NVL(rates.recovery_type_code,
                                           'STANDARD'))  RECOVERY_TYPE_CODE
               ,NULL					 RECOVERY_TYPE_ID
               ,NULL					 REF_DOC_CURR_CONV_RATE
               ,NULL					 REF_DOC_DIST_ID
               ,NULL					 REF_DOC_PER_UNIT_NREC_TAX_AMT
               ,NULL					 REF_DOC_TAX_DIST_ID
               ,NULL					 REF_DOC_TRX_LINE_DIST_QTY
               ,NULL					 REF_DOC_UNIT_PRICE
               ,NULL					 REF_PER_TRX_CURR_UNIT_NR_AMT
               ,NULL					 REVERSED_TAX_DIST_ID
               ,NULL					 ROUNDING_RULE_CODE
               ,pohzd.p_task_id				 TASK_ID
               ,null					 TAXABLE_AMT_FUNCL_CURR
               ,NULL					 TAXABLE_AMT_TAX_CURR
               ,NULL					 TRX_LINE_DIST_AMT
               ,pohzd.p_po_distribution_id		 TRX_LINE_DIST_ID
               ,NULL					 TRX_LINE_DIST_QTY
               ,NULL					 TRX_LINE_DIST_TAX_AMT
               ,NULL					 UNROUNDED_REC_NREC_TAX_AMT
               ,NULL					 UNROUNDED_TAXABLE_AMT
               ,NULL					 TAXABLE_AMT
               ,pohzd.p_ATTRIBUTE_CATEGORY               ATTRIBUTE_CATEGORY
               ,pohzd.p_ATTRIBUTE1                       ATTRIBUTE1
               ,pohzd.p_ATTRIBUTE2                       ATTRIBUTE2
               ,pohzd.p_ATTRIBUTE3                       ATTRIBUTE3
               ,pohzd.p_ATTRIBUTE4                       ATTRIBUTE4
               ,pohzd.p_ATTRIBUTE5                       ATTRIBUTE5
               ,pohzd.p_ATTRIBUTE6                       ATTRIBUTE6
               ,pohzd.p_ATTRIBUTE7                       ATTRIBUTE7
               ,pohzd.p_ATTRIBUTE8                       ATTRIBUTE8
               ,pohzd.p_ATTRIBUTE9                       ATTRIBUTE9
               ,pohzd.p_ATTRIBUTE10                      ATTRIBUTE10
               ,pohzd.p_ATTRIBUTE11                      ATTRIBUTE11
               ,pohzd.p_ATTRIBUTE12                      ATTRIBUTE12
               ,pohzd.p_ATTRIBUTE13                      ATTRIBUTE13
               ,pohzd.p_ATTRIBUTE14                      ATTRIBUTE14
               ,pohzd.p_ATTRIBUTE15                      ATTRIBUTE15
               ,'Y'			                 HISTORICAL_FLAG
               ,'N'			                 OVERRIDDEN_FLAG
               ,'N'			                 SELF_ASSESSED_FLAG
               ,'Y'			                 TAX_APPORTIONMENT_FLAG
               ,'N'			                 TAX_ONLY_LINE_FLAG
               ,'N'			                 INCLUSIVE_FLAG
               ,'N'			                 MRC_TAX_DIST_FLAG
               ,'N'			                 REC_TYPE_RULE_FLAG
               ,'N'			                 NEW_REC_RATE_CODE_FLAG
               ,tmp.rec_flag                             RECOVERABLE_FLAG
               ,'N'			                 REVERSE_FLAG
               ,'N'			                 REC_RATE_DET_RULE_FLAG
               ,'Y'			                 BACKWARD_COMPATIBILITY_FLAG
               ,'N'			                 FREEZE_FLAG
               ,'N'			                 POSTING_FLAG
               ,NVL(pohzd.legal_entity_id,-99)           LEGAL_ENTITY_ID
               ,1			                 CREATED_BY
               ,SYSDATE		                         CREATION_DATE
               ,NULL		                         LAST_MANUAL_ENTRY
               ,SYSDATE		                         LAST_UPDATE_DATE
               ,1			                 LAST_UPDATE_LOGIN
               ,1			                 LAST_UPDATED_BY
               ,1			                 OBJECT_VERSION_NUMBER
    FROM (SELECT /*+ use_nl_with_index(recdist ZX_PO_REC_DIST_N1) */
                 pohzd.*,
                 recdist.rec_rate     d_rec_rate
            FROM (SELECT /*+ NO_EXPAND leading(poh) use_nl_with_index(zxl, ZX_LINES_U1) use_nl(pod) */
                        poh.po_header_id,
                        poll.last_update_date poll_last_update_date,
                        fsp.set_of_books_id,
                        zxl.*,
                        pod.po_distribution_id                  p_po_distribution_id,
                        pod.expenditure_item_date               p_expenditure_item_date,
                        pod.expenditure_organization_id         p_expenditure_organization_id,
                        pod.expenditure_type                    p_expenditure_type,
                        pod.project_id                          p_project_id,
                        pod.task_id                             p_task_id,
                        pod.recovery_rate                       p_recovery_rate,
                        pod.quantity_ordered                    p_quantity_ordered,
                        pod.attribute_category                  p_attribute_category ,
                        pod.attribute1                          p_attribute1,
                        pod.attribute2                          p_attribute2,
                        pod.attribute3                          p_attribute3,
                        pod.attribute4                          p_attribute4,
                        pod.attribute5                          p_attribute5,
                        pod.attribute6                          p_attribute6,
                        pod.attribute7                          p_attribute7,
                        pod.attribute8                          p_attribute8,
                        pod.attribute9                          p_attribute9,
                        pod.attribute10                         p_attribute10,
                        pod.attribute11                         p_attribute11,
                        pod.attribute12                         p_attribute12,
                        pod.attribute13                         p_attribute13,
                        pod.attribute14                         p_attribute14,
                        pod.attribute15                         p_attribute15
                   FROM	po_headers_all poh,
                 	financials_system_params_all fsp,
                        zx_lines zxl,
                        po_line_locations_all poll,
                        po_distributions_all pod
                  WHERE poh.po_header_id = p_upg_trx_info_rec.trx_id
                    AND NVL(poh.org_id, -99) = NVL(fsp.org_id, -99)
                    AND zxl.application_id = 201
                    AND zxl.entity_code = 'PURCHASE_ORDER'
                    AND zxl.event_class_code = 'PO_PA'
                    AND zxl.trx_id = poh.po_header_id
                    AND poll.line_location_id = zxl.trx_line_id
                    AND NOT EXISTS
                        (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                           WHERE lines_gt.application_id   = 201
                             AND lines_gt.event_class_code = 'PO_PA'
                             AND lines_gt.entity_code      = 'PURCHASE_ORDER'
                             AND lines_gt.trx_id           = p_upg_trx_info_rec.trx_id
                             AND lines_gt.trx_line_id      = poll.line_location_id
                             AND lines_gt.trx_level_type   = 'SHIPMENT'
                             AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
                        )
                    AND pod.po_header_id = poll.po_header_id
                    AND pod.line_location_id = poll.line_location_id
                 ) pohzd,
                   zx_po_rec_dist recdist
             WHERE recdist.po_header_id(+) = pohzd.trx_id
               AND recdist.po_line_location_id(+) = pohzd.trx_line_id
               AND recdist.po_distribution_id(+) = pohzd.p_po_distribution_id
               AND recdist.tax_rate_id(+) = pohzd.tax_rate_id
         ) pohzd,
         fnd_currencies fc,
         zx_rates_b rates,
         (SELECT 'Y' rec_flag FROM dual UNION ALL SELECT 'N' rec_flag FROM dual) tmp
   WHERE pohzd.trx_currency_code = fc.currency_code(+)
     AND rates.tax_regime_code(+) = pohzd.tax_regime_code
     AND rates.tax(+) = pohzd.tax
     AND rates.content_owner_id(+) = pohzd.content_owner_id
     AND rates.rate_type_code(+) = 'RECOVERY'
     AND rates.recovery_type_code(+) = 'STANDARD'
     AND rates.active_flag(+) = 'Y'
     AND rates.effective_from(+) <= sysdate
     --Bug 8724131
     --AND (rates.effective_to IS NULL OR rates.effective_to >= sysdate)
     --Bug 8752951
     AND pohzd.poll_last_update_date BETWEEN rates.effective_from AND NVL(rates.effective_to, pohzd.poll_last_update_date)
     AND rates.record_type_code(+) = 'MIGRATED'
     AND rates.percentage_rate(+) = NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate),0)
     AND rates.tax_rate_code(+) NOT LIKE 'AD_HOC_RECOVERY%'
     AND NOT EXISTS
    (SELECT 1 FROM zx_rec_nrec_dist zxdist
      WHERE zxdist.application_id               = 201
        AND zxdist.entity_code			= 'PURCHASE_ORDER'
        AND zxdist.event_class_code		= 'PO_PA'
        AND zxdist.trx_id			= p_upg_trx_info_rec.trx_id
        AND zxdist.trx_line_id			= pohzd.trx_line_id
        AND nvl(zxdist.content_owner_id,-99)	= nvl(pohzd.content_owner_id,-99)
        -- AND zxdist.tax_line_id               = pohzd.tax_line_id
        -- AND zxdist.trx_line_dist_id		= pod.po_distribution_id
        );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                    'Number of Rows Inserted = ' || TO_CHAR(SQL%ROWCOUNT));
    END IF;

  ELSIF p_upg_trx_info_rec.entity_code = 'RELEASE' THEN

    -- Insert data into zx_lines_det_factors
    --
    INSERT INTO ZX_LINES_DET_FACTORS (
            EVENT_ID
           ,ACCOUNT_CCID
           ,ACCOUNT_STRING
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           ,APPLICATION_DOC_STATUS
           ,APPLICATION_ID
           ,APPLIED_FROM_APPLICATION_ID
           ,APPLIED_FROM_ENTITY_CODE
           ,APPLIED_FROM_EVENT_CLASS_CODE
           ,APPLIED_FROM_LINE_ID
           ,APPLIED_FROM_TRX_ID
           ,APPLIED_FROM_TRX_LEVEL_TYPE
           ,APPLIED_TO_APPLICATION_ID
           ,APPLIED_TO_ENTITY_CODE
           ,APPLIED_TO_EVENT_CLASS_CODE
           ,APPLIED_TO_TRX_ID
           ,APPLIED_TO_TRX_LEVEL_TYPE
           ,APPLIED_TO_TRX_LINE_ID
           ,APPLIED_TO_TRX_NUMBER
           ,ASSESSABLE_VALUE
           ,ASSET_ACCUM_DEPRECIATION
           ,ASSET_COST
           ,ASSET_FLAG
           ,ASSET_NUMBER
           ,ASSET_TYPE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,BILL_FROM_LOCATION_ID
           ,BILL_FROM_PARTY_TAX_PROF_ID
           ,BILL_FROM_SITE_TAX_PROF_ID
           ,BILL_TO_LOCATION_ID
           ,BILL_TO_PARTY_TAX_PROF_ID
           ,BILL_TO_SITE_TAX_PROF_ID
           ,COMPOUNDING_TAX_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,CTRL_HDR_TX_APPL_FLAG
           ,CTRL_TOTAL_HDR_TX_AMT
           ,CTRL_TOTAL_LINE_TX_AMT
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,DEFAULT_TAXATION_COUNTRY
           ,DOC_EVENT_STATUS
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,DOCUMENT_SUB_TYPE
           ,ENTITY_CODE
           ,ESTABLISHMENT_ID
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,FIRST_PTY_ORG_ID
           ,HISTORICAL_FLAG
           ,HQ_ESTB_PARTY_TAX_PROF_ID
           ,INCLUSIVE_TAX_OVERRIDE_FLAG
           ,INPUT_TAX_CLASSIFICATION_CODE
           ,INTERNAL_ORG_LOCATION_ID
           ,INTERNAL_ORGANIZATION_ID
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
           ,LEDGER_ID
           ,LEGAL_ENTITY_ID
           ,LINE_AMT
           ,LINE_AMT_INCLUDES_TAX_FLAG
           ,LINE_CLASS
           ,LINE_INTENDED_USE
           ,LINE_LEVEL_ACTION
           ,MERCHANT_PARTY_COUNTRY
           ,MERCHANT_PARTY_DOCUMENT_NUMBER
           ,MERCHANT_PARTY_ID
           ,MERCHANT_PARTY_NAME
           ,MERCHANT_PARTY_REFERENCE
           ,MERCHANT_PARTY_TAX_PROF_ID
           ,MERCHANT_PARTY_TAX_REG_NUMBER
           ,MERCHANT_PARTY_TAXPAYER_ID
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,OBJECT_VERSION_NUMBER
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           ,PORT_OF_ENTRY_CODE
           ,PRECISION
           ,PRODUCT_CATEGORY
           ,PRODUCT_CODE
           ,PRODUCT_DESCRIPTION
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ID
           ,PRODUCT_ORG_ID
           ,PRODUCT_TYPE
           ,RECORD_TYPE_CODE
           ,REF_DOC_APPLICATION_ID
           ,REF_DOC_ENTITY_CODE
           ,REF_DOC_EVENT_CLASS_CODE
           ,REF_DOC_LINE_ID
           ,REF_DOC_LINE_QUANTITY
           ,REF_DOC_TRX_ID
           ,REF_DOC_TRX_LEVEL_TYPE
           ,RELATED_DOC_APPLICATION_ID
           ,RELATED_DOC_DATE
           ,RELATED_DOC_ENTITY_CODE
           ,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_NUMBER
           ,RELATED_DOC_TRX_ID
           ,SHIP_FROM_LOCATION_ID
           ,SHIP_FROM_PARTY_TAX_PROF_ID
           ,SHIP_FROM_SITE_TAX_PROF_ID
           ,SHIP_TO_LOCATION_ID
           ,SHIP_TO_PARTY_TAX_PROF_ID
           ,SHIP_TO_SITE_TAX_PROF_ID
           ,SOURCE_APPLICATION_ID
           ,SOURCE_ENTITY_CODE
           ,SOURCE_EVENT_CLASS_CODE
           ,SOURCE_LINE_ID
           ,SOURCE_TRX_ID
           ,SOURCE_TRX_LEVEL_TYPE
           ,START_EXPENSE_DATE
           ,SUPPLIER_EXCHANGE_RATE
           ,SUPPLIER_TAX_INVOICE_DATE
           ,SUPPLIER_TAX_INVOICE_NUMBER
           ,TAX_AMT_INCLUDED_FLAG
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,TAX_PROCESSING_COMPLETED_FLAG
           ,TAX_REPORTING_FLAG
           ,THRESHOLD_INDICATOR_FLAG
           ,TRX_BUSINESS_CATEGORY
           ,TRX_COMMUNICATED_DATE
           ,TRX_CURRENCY_CODE
           ,TRX_DATE
           ,TRX_DESCRIPTION
           ,TRX_DUE_DATE
           ,TRX_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_DATE
           ,TRX_LINE_DESCRIPTION
           ,TRX_LINE_GL_DATE
           ,TRX_LINE_ID
           ,TRX_LINE_NUMBER
           ,TRX_LINE_QUANTITY
           ,TRX_LINE_TYPE
           ,TRX_NUMBER
           ,TRX_RECEIPT_DATE
           ,TRX_SHIPPING_DATE
           ,TRX_TYPE_DESCRIPTION
           ,UNIT_PRICE
           ,UOM_CODE
           ,USER_DEFINED_FISC_CLASS
           ,USER_UPD_DET_FACTORS_FLAG
           ,EVENT_CLASS_MAPPING_ID
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,ICX_SESSION_ID
           ,TRX_LINE_CURRENCY_CODE
           ,TRX_LINE_CURRENCY_CONV_RATE
           ,TRX_LINE_CURRENCY_CONV_DATE
           ,TRX_LINE_PRECISION
           ,TRX_LINE_MAU
           ,TRX_LINE_CURRENCY_CONV_TYPE
           ,INTERFACE_ENTITY_CODE
           ,INTERFACE_LINE_ID
           ,SOURCE_TAX_LINE_ID
           ,TAX_CALCULATION_DONE_FLAG
           ,LINE_TRX_USER_KEY1
           ,LINE_TRX_USER_KEY2
           ,LINE_TRX_USER_KEY3
         )
          SELECT /*+ ORDERED NO_EXPAND use_nl(fc, pol, poll, ptp, hr) */
           NULL 			    EVENT_ID,
           NULL 			    ACCOUNT_CCID,
           NULL 			    ACCOUNT_STRING,
           NULL 			    ADJUSTED_DOC_APPLICATION_ID,
           NULL 			    ADJUSTED_DOC_DATE,
           NULL 			    ADJUSTED_DOC_ENTITY_CODE,
           NULL 			    ADJUSTED_DOC_EVENT_CLASS_CODE,
           NULL 			    ADJUSTED_DOC_LINE_ID,
           NULL 			    ADJUSTED_DOC_NUMBER,
           NULL 			    ADJUSTED_DOC_TRX_ID,
           NULL 			    ADJUSTED_DOC_TRX_LEVEL_TYPE,
           NULL 			    APPLICATION_DOC_STATUS,
           201 			            APPLICATION_ID,
           NULL 			    APPLIED_FROM_APPLICATION_ID,
           NULL 			    APPLIED_FROM_ENTITY_CODE,
           NULL 			    APPLIED_FROM_EVENT_CLASS_CODE,
           NULL 			    APPLIED_FROM_LINE_ID,
           NULL 			    APPLIED_FROM_TRX_ID,
           NULL 			    APPLIED_FROM_TRX_LEVEL_TYPE,
           NULL 			    APPLIED_TO_APPLICATION_ID,
           NULL 			    APPLIED_TO_ENTITY_CODE,
           NULL 			    APPLIED_TO_EVENT_CLASS_CODE,
           NULL 			    APPLIED_TO_TRX_ID,
           NULL 			    APPLIED_TO_TRX_LEVEL_TYPE,
           NULL 			    APPLIED_TO_TRX_LINE_ID,
           NULL 			    APPLIED_TO_TRX_NUMBER,
           NULL 			    ASSESSABLE_VALUE,
           NULL 			    ASSET_ACCUM_DEPRECIATION,
           NULL 			    ASSET_COST,
           NULL 			    ASSET_FLAG,
           NULL 			    ASSET_NUMBER,
           NULL 			    ASSET_TYPE,
           NULL 			    BATCH_SOURCE_ID,
           NULL 			    BATCH_SOURCE_NAME,
           NULL 			    BILL_FROM_LOCATION_ID,
           NULL 			    BILL_FROM_PARTY_TAX_PROF_ID,
           NULL 			    BILL_FROM_SITE_TAX_PROF_ID,
           NULL 			    BILL_TO_LOCATION_ID,
           NULL 			    BILL_TO_PARTY_TAX_PROF_ID,
           NULL 			    BILL_TO_SITE_TAX_PROF_ID,
           'N' 			            COMPOUNDING_TAX_FLAG,
           1   			            CREATED_BY,
           SYSDATE 		            CREATION_DATE,
           'N' 			            CTRL_HDR_TX_APPL_FLAG,
           NULL			            CTRL_TOTAL_HDR_TX_AMT,
           NULL	 		            CTRL_TOTAL_LINE_TX_AMT,
           poll.poh_rate_date 		    CURRENCY_CONVERSION_DATE,
           poll.poh_rate 		    CURRENCY_CONVERSION_RATE,
           poll.poh_rate_type 		    CURRENCY_CONVERSION_TYPE,
           NULL 			    DEFAULT_TAXATION_COUNTRY,
           NULL 			    DOC_EVENT_STATUS,
           NULL 			    DOC_SEQ_ID,
           NULL 			    DOC_SEQ_NAME,
           NULL 			    DOC_SEQ_VALUE,
           NULL 			    DOCUMENT_SUB_TYPE,
           'RELEASE' 		            ENTITY_CODE,
           NULL                             ESTABLISHMENT_ID,
           'RELEASE' 	                    EVENT_CLASS_CODE,
           'PURCHASE ORDER CREATED'         EVENT_TYPE_CODE,
           ptp.party_tax_profile_id	    FIRST_PTY_ORG_ID,
           'Y' 			            HISTORICAL_FLAG,
           NULL	 		            HQ_ESTB_PARTY_TAX_PROF_ID,
           'N' 			            INCLUSIVE_TAX_OVERRIDE_FLAG,
           (select name
	    from ap_tax_codes_all
	    where tax_id = poll.tax_code_id) INPUT_TAX_CLASSIFICATION_CODE,
           NULL 			    INTERNAL_ORG_LOCATION_ID,
           nvl(poll.poh_org_id,-99) 	    INTERNAL_ORGANIZATION_ID,
           SYSDATE 		            LAST_UPDATE_DATE,
           1 			            LAST_UPDATE_LOGIN,
           1 			            LAST_UPDATED_BY,
           poll.fsp_set_of_books_id 	    LEDGER_ID,
           NVL(poll.oi_org_information2,-99) LEGAL_ENTITY_ID,
           DECODE(pol.purchase_basis,
            'TEMP LABOR', NVL(POLL.amount,0),
            'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                               NVL(poll.quantity,0) *
                               NVL(poll.price_override,NVL(pol.unit_price,0))),
             NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                            LINE_AMT,
           'N' 			            LINE_AMT_INCLUDES_TAX_FLAG,
           'INVOICE' 		            LINE_CLASS,
           NULL 			    LINE_INTENDED_USE,
           'CREATE' 		            LINE_LEVEL_ACTION,
           NULL 			    MERCHANT_PARTY_COUNTRY,
           NULL 			    MERCHANT_PARTY_DOCUMENT_NUMBER,
           NULL 			    MERCHANT_PARTY_ID,
           NULL 			    MERCHANT_PARTY_NAME,
           NULL 			    MERCHANT_PARTY_REFERENCE,
           NULL 			    MERCHANT_PARTY_TAX_PROF_ID,
           NULL 			    MERCHANT_PARTY_TAX_REG_NUMBER,
           NULL 			    MERCHANT_PARTY_TAXPAYER_ID,
           fc.minimum_accountable_unit      MINIMUM_ACCOUNTABLE_UNIT,
           1 			            OBJECT_VERSION_NUMBER,
           NULL 			    OUTPUT_TAX_CLASSIFICATION_CODE,
           NULL 			    PORT_OF_ENTRY_CODE,
           NVL(fc.precision, 0)             PRECISION,
           -- fc.precision 		    PRECISION,
           NULL 			    PRODUCT_CATEGORY,
           NULL 			    PRODUCT_CODE,
           NULL 			    PRODUCT_DESCRIPTION,
           NULL 			    PRODUCT_FISC_CLASSIFICATION,
           pol.item_id		            PRODUCT_ID,
           poll.ship_to_organization_id	    PRODUCT_ORG_ID,
           DECODE(UPPER(pol.purchase_basis),
                  'GOODS', 'GOODS',
                  'SERVICES', 'SERVICES',
                  'TEMP LABOR','SERVICES',
                  'GOODS') 		    PRODUCT_TYPE,
           'MIGRATED' 		            RECORD_TYPE_CODE,
           NULL 			    REF_DOC_APPLICATION_ID,
           NULL 			    REF_DOC_ENTITY_CODE,
           NULL 			    REF_DOC_EVENT_CLASS_CODE,
           NULL 			    REF_DOC_LINE_ID,
           NULL 			    REF_DOC_LINE_QUANTITY,
           NULL 			    REF_DOC_TRX_ID,
           NULL 			    REF_DOC_TRX_LEVEL_TYPE,
           NULL 			    RELATED_DOC_APPLICATION_ID,
           NULL 			    RELATED_DOC_DATE,
           NULL 			    RELATED_DOC_ENTITY_CODE,
           NULL 			    RELATED_DOC_EVENT_CLASS_CODE,
           NULL 			    RELATED_DOC_NUMBER,
           NULL 			    RELATED_DOC_TRX_ID,
           NULL 			    SHIP_FROM_LOCATION_ID,
           NULL 			    SHIP_FROM_PARTY_TAX_PROF_ID,
           NULL 			    SHIP_FROM_SITE_TAX_PROF_ID,
           poll.ship_to_location_id         SHIP_TO_LOCATION_ID,
           NULL 			    SHIP_TO_PARTY_TAX_PROF_ID,
           NULL 			    SHIP_TO_SITE_TAX_PROF_ID,
           NULL 			    SOURCE_APPLICATION_ID,
           NULL 			    SOURCE_ENTITY_CODE,
           NULL 			    SOURCE_EVENT_CLASS_CODE,
           NULL 			    SOURCE_LINE_ID,
           NULL 			    SOURCE_TRX_ID,
           NULL 			    SOURCE_TRX_LEVEL_TYPE,
           NULL 			    START_EXPENSE_DATE,
           NULL 			    SUPPLIER_EXCHANGE_RATE,
           NULL 			    SUPPLIER_TAX_INVOICE_DATE,
           NULL 			    SUPPLIER_TAX_INVOICE_NUMBER,
           'N' 			            TAX_AMT_INCLUDED_FLAG,
           'PURCHASE_TRANSACTION' 	    TAX_EVENT_CLASS_CODE,
           'VALIDATE'  		            TAX_EVENT_TYPE_CODE,
           NULL 			    TAX_INVOICE_DATE,
           NULL 			    TAX_INVOICE_NUMBER,
           'Y'			            TAX_PROCESSING_COMPLETED_FLAG,
           'N'			            TAX_REPORTING_FLAG,
           'N' 			            THRESHOLD_INDICATOR_FLAG,
           NULL 			    TRX_BUSINESS_CATEGORY,
           NULL 			    TRX_COMMUNICATED_DATE,
           NVL(poll.poh_currency_code,
               poll.aps_base_currency_code) TRX_CURRENCY_CODE,
           poll.poh_last_update_date 	    TRX_DATE,
           NULL 			    TRX_DESCRIPTION,
           NULL 			    TRX_DUE_DATE,
           poll.po_release_id     TRX_ID,
           'SHIPMENT' 			    TRX_LEVEL_TYPE,
           poll.LAST_UPDATE_DATE  	    TRX_LINE_DATE,
           NULL 			    TRX_LINE_DESCRIPTION,
           poll.LAST_UPDATE_DATE 	    TRX_LINE_GL_DATE,
           poll.line_location_id 	    TRX_LINE_ID,
           poll.SHIPMENT_NUM 	            TRX_LINE_NUMBER,
           poll.quantity 		    TRX_LINE_QUANTITY,
           'ITEM' 			    TRX_LINE_TYPE,
           poll.poh_segment1 		    TRX_NUMBER,
           NULL 			    TRX_RECEIPT_DATE,
           NULL 			    TRX_SHIPPING_DATE,
           NULL 			    TRX_TYPE_DESCRIPTION,
           NVL(poll.price_override,
                           pol.unit_price)  UNIT_PRICE,
           NULL 			    UOM_CODE,
           NULL 			    USER_DEFINED_FISC_CLASS,
           'N' 			            USER_UPD_DET_FACTORS_FLAG,
           12			            EVENT_CLASS_MAPPING_ID,
           poll.GLOBAL_ATTRIBUTE_CATEGORY   GLOBAL_ATTRIBUTE_CATEGORY,
           poll.GLOBAL_ATTRIBUTE1 	    GLOBAL_ATTRIBUTE1 	   ,
           NULL                             ICX_SESSION_ID,
           NULL                             TRX_LINE_CURRENCY_CODE,
           NULL                             TRX_LINE_CURRENCY_CONV_RATE,
           NULL                             TRX_LINE_CURRENCY_CONV_DATE,
           NULL                             TRX_LINE_PRECISION,
           NULL                             TRX_LINE_MAU,
           NULL                             TRX_LINE_CURRENCY_CONV_TYPE,
           NULL                             INTERFACE_ENTITY_CODE,
           NULL                             INTERFACE_LINE_ID,
           NULL                             SOURCE_TAX_LINE_ID,
           'Y'                              TAX_CALCULATION_DONE_FLAG,
           pol.line_num                     LINE_TRX_USER_KEY1,
           hr.location_code                 LINE_TRX_USER_KEY2,
           DECODE(poll.payment_type,
                   NULL, 0, 'DELIVERY',
                   1,'ADVANCE', 2, 3)       LINE_TRX_USER_KEY3
      FROM (SELECT /*+ NO_MERGE NO_EXPAND swap_join_inputs(fsp) swap_join_inputs(aps)
                    wap_join_inputs(oi) index(aps AP_SYSTEM_PARAMETERS_U1) */
                   poll.*,
                   poh.rate_date 	       poh_rate_date,
                   poh.rate 	       poh_rate,
                   poh.rate_type 	       poh_rate_type,
                   poh.org_id              poh_org_id,
                   poh.currency_code       poh_currency_code,
                   poh.last_update_date    poh_last_update_date,
                   poh.segment1            poh_segment1,
                   fsp.set_of_books_id     fsp_set_of_books_id,
                   aps.base_currency_code  aps_base_currency_code,
                   oi.org_information2     oi_org_information2
   	      FROM po_line_locations_all poll,
   	           po_headers_all poh,
                   financials_system_params_all fsp,
                   ap_system_parameters_all aps,
                   hr_organization_information oi
	     WHERE poll.po_release_id = p_upg_trx_info_rec.trx_id
	       AND poh.po_header_id = poll.po_header_id
               AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
               AND aps.set_of_books_id = fsp.set_of_books_id
               AND NVL(aps.org_id, -99) = NVL(poh.org_id, -99)
               AND oi.organization_id(+) = poh.org_id
               AND oi.org_information_context(+) = 'Operating Unit Information'
           ) poll,
           fnd_currencies fc,
           po_lines_all pol,
           zx_party_tax_profile ptp,
           hr_locations_all hr
     WHERE NVL(poll.poh_currency_code, poll.aps_base_currency_code) = fc.currency_code(+)
       AND pol.po_header_id = poll.po_header_id
       AND pol.po_line_id = poll.po_line_id
       AND hr.location_id(+) = poll.ship_to_location_id
       AND NOT EXISTS
           (SELECT 1 FROM zx_transaction_lines_gt lines_gt
              WHERE lines_gt.application_id   = 201
                AND lines_gt.event_class_code = 'RELEASE'
                AND lines_gt.entity_code      = 'RELEASE'
                AND lines_gt.trx_id           = p_upg_trx_info_rec.trx_id
                AND lines_gt.trx_line_id      = poll.line_location_id
                AND lines_gt.trx_level_type   = 'SHIPMENT'
                AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
           )
       AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
       AND ptp.party_type_code = 'OU'
       AND NOT EXISTS
           (SELECT 1 FROM zx_lines_det_factors zxl
             WHERE zxl.APPLICATION_ID   = 201
               AND zxl.EVENT_CLASS_CODE = 'RELEASE'
               AND zxl.ENTITY_CODE      = 'RELEASE'
               AND zxl.TRX_ID           = p_upg_trx_info_rec.trx_id
               AND zxl.TRX_LINE_ID      = poll.line_location_id
               AND zxl.TRX_LEVEL_TYPE   = 'SHIPMENT'
           );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                     'Number of Rows Inserted = ' || TO_CHAR(SQL%ROWCOUNT));
    END IF;


    -- COMMIT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_po',
                     'Inserting data into zx_lines (Tax Code)');
    END IF;

    -- Insert data into zx_lines
    --
    INSERT INTO ZX_LINES(
                ADJUSTED_DOC_APPLICATION_ID
               ,ADJUSTED_DOC_DATE
               ,ADJUSTED_DOC_ENTITY_CODE
               ,ADJUSTED_DOC_EVENT_CLASS_CODE
               ,ADJUSTED_DOC_LINE_ID
               ,ADJUSTED_DOC_NUMBER
               ,ADJUSTED_DOC_TAX_LINE_ID
               ,ADJUSTED_DOC_TRX_ID
               ,ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,APPLICATION_ID
               ,APPLIED_FROM_APPLICATION_ID
               ,APPLIED_FROM_ENTITY_CODE
               ,APPLIED_FROM_EVENT_CLASS_CODE
               ,APPLIED_FROM_LINE_ID
               ,APPLIED_FROM_TRX_ID
               ,APPLIED_FROM_TRX_LEVEL_TYPE
               ,APPLIED_FROM_TRX_NUMBER
               ,APPLIED_TO_APPLICATION_ID
               ,APPLIED_TO_ENTITY_CODE
               ,APPLIED_TO_EVENT_CLASS_CODE
               ,APPLIED_TO_LINE_ID
               ,APPLIED_TO_TRX_ID
               ,APPLIED_TO_TRX_LEVEL_TYPE
               ,APPLIED_TO_TRX_NUMBER
               ,ASSOCIATED_CHILD_FROZEN_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,BASIS_RESULT_ID
               ,CAL_TAX_AMT
               ,CAL_TAX_AMT_FUNCL_CURR
               ,CAL_TAX_AMT_TAX_CURR
               ,CALC_RESULT_ID
               ,CANCEL_FLAG
               ,CHAR1
               ,CHAR10
               ,CHAR2
               ,CHAR3
               ,CHAR4
               ,CHAR5
               ,CHAR6
               ,CHAR7
               ,CHAR8
               ,CHAR9
               ,COMPOUNDING_DEP_TAX_FLAG
               ,COMPOUNDING_TAX_FLAG
               ,COMPOUNDING_TAX_MISS_FLAG
               ,CONTENT_OWNER_ID
               ,COPIED_FROM_OTHER_DOC_FLAG
               ,CREATED_BY
               ,CREATION_DATE
               ,CTRL_TOTAL_LINE_TX_AMT
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,DATE1
               ,DATE10
               ,DATE2
               ,DATE3
               ,DATE4
               ,DATE5
               ,DATE6
               ,DATE7
               ,DATE8
               ,DATE9
               ,DELETE_FLAG
               ,DIRECT_RATE_RESULT_ID
               ,DOC_EVENT_STATUS
               ,ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,ENTITY_CODE
               ,ESTABLISHMENT_ID
               ,EVAL_EXCPT_RESULT_ID
               ,EVAL_EXMPT_RESULT_ID
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,EXCEPTION_RATE
               ,EXEMPT_CERTIFICATE_NUMBER
               ,EXEMPT_RATE_MODIFIER
               ,EXEMPT_REASON
               ,EXEMPT_REASON_CODE
               ,FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,GLOBAL_ATTRIBUTE_CATEGORY
               ,GLOBAL_ATTRIBUTE1
               ,GLOBAL_ATTRIBUTE10
               ,GLOBAL_ATTRIBUTE11
               ,GLOBAL_ATTRIBUTE12
               ,GLOBAL_ATTRIBUTE13
               ,GLOBAL_ATTRIBUTE14
               ,GLOBAL_ATTRIBUTE15
               ,GLOBAL_ATTRIBUTE2
               ,GLOBAL_ATTRIBUTE3
               ,GLOBAL_ATTRIBUTE4
               ,GLOBAL_ATTRIBUTE5
               ,GLOBAL_ATTRIBUTE6
               ,GLOBAL_ATTRIBUTE7
               ,GLOBAL_ATTRIBUTE8
               ,GLOBAL_ATTRIBUTE9
               ,HISTORICAL_FLAG
               ,HQ_ESTB_PARTY_TAX_PROF_ID
               ,HQ_ESTB_REG_NUMBER
               ,INTERFACE_ENTITY_CODE
               ,INTERFACE_TAX_LINE_ID
               ,INTERNAL_ORG_LOCATION_ID
               ,INTERNAL_ORGANIZATION_ID
               ,ITEM_DIST_CHANGED_FLAG
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,LEDGER_ID
               ,LEGAL_ENTITY_ID
               ,LEGAL_ENTITY_TAX_REG_NUMBER
               ,LEGAL_JUSTIFICATION_TEXT1
               ,LEGAL_JUSTIFICATION_TEXT2
               ,LEGAL_JUSTIFICATION_TEXT3
               ,LEGAL_MESSAGE_APPL_2
               ,LEGAL_MESSAGE_BASIS
               ,LEGAL_MESSAGE_CALC
               ,LEGAL_MESSAGE_EXCPT
               ,LEGAL_MESSAGE_EXMPT
               ,LEGAL_MESSAGE_POS
               ,LEGAL_MESSAGE_RATE
               ,LEGAL_MESSAGE_STATUS
               ,LEGAL_MESSAGE_THRESHOLD
               ,LEGAL_MESSAGE_TRN
               ,LINE_AMT
               ,LINE_ASSESSABLE_VALUE
               ,MANUALLY_ENTERED_FLAG
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,MRC_LINK_TO_TAX_LINE_ID
               ,MRC_TAX_LINE_FLAG
               ,NREC_TAX_AMT
               ,NREC_TAX_AMT_FUNCL_CURR
               ,NREC_TAX_AMT_TAX_CURR
               ,NUMERIC1
               ,NUMERIC10
               ,NUMERIC2
               ,NUMERIC3
               ,NUMERIC4
               ,NUMERIC5
               ,NUMERIC6
               ,NUMERIC7
               ,NUMERIC8
               ,NUMERIC9
               ,OBJECT_VERSION_NUMBER
               ,OFFSET_FLAG
               ,OFFSET_LINK_TO_TAX_LINE_ID
               ,OFFSET_TAX_RATE_CODE
               ,ORIG_SELF_ASSESSED_FLAG
               ,ORIG_TAX_AMT
               ,ORIG_TAX_AMT_INCLUDED_FLAG
               ,ORIG_TAX_AMT_TAX_CURR
               ,ORIG_TAX_JURISDICTION_CODE
               ,ORIG_TAX_JURISDICTION_ID
               ,ORIG_TAX_RATE
               ,ORIG_TAX_RATE_CODE
               ,ORIG_TAX_RATE_ID
               ,ORIG_TAX_STATUS_CODE
               ,ORIG_TAX_STATUS_ID
               ,ORIG_TAXABLE_AMT
               ,ORIG_TAXABLE_AMT_TAX_CURR
               ,OTHER_DOC_LINE_AMT
               ,OTHER_DOC_LINE_TAX_AMT
               ,OTHER_DOC_LINE_TAXABLE_AMT
               ,OTHER_DOC_SOURCE
               ,OVERRIDDEN_FLAG
               ,PLACE_OF_SUPPLY
               ,PLACE_OF_SUPPLY_RESULT_ID
               ,PLACE_OF_SUPPLY_TYPE_CODE
               ,PRD_TOTAL_TAX_AMT
               ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,PRD_TOTAL_TAX_AMT_TAX_CURR
               ,PRECISION
               ,PROCESS_FOR_RECOVERY_FLAG
               ,PRORATION_CODE
               ,PURGE_FLAG
               ,RATE_RESULT_ID
               ,REC_TAX_AMT
               ,REC_TAX_AMT_FUNCL_CURR
               ,REC_TAX_AMT_TAX_CURR
               ,RECALC_REQUIRED_FLAG
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_LINE_QUANTITY
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,REGISTRATION_PARTY_TYPE
               ,RELATED_DOC_APPLICATION_ID
               ,RELATED_DOC_DATE
               ,RELATED_DOC_ENTITY_CODE
               ,RELATED_DOC_EVENT_CLASS_CODE
               ,RELATED_DOC_NUMBER
               ,RELATED_DOC_TRX_ID
               ,RELATED_DOC_TRX_LEVEL_TYPE
               ,REPORTING_CURRENCY_CODE
               ,REPORTING_ONLY_FLAG
               ,REPORTING_PERIOD_ID
               ,ROUNDING_LEVEL_CODE
               ,ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,ROUNDING_LVL_PARTY_TYPE
               ,ROUNDING_RULE_CODE
               ,SELF_ASSESSED_FLAG
               ,SETTLEMENT_FLAG
               ,STATUS_RESULT_ID
               ,SUMMARY_TAX_LINE_ID
               ,SYNC_WITH_PRVDR_FLAG
               ,TAX
               ,TAX_AMT
               ,TAX_AMT_FUNCL_CURR
               ,TAX_AMT_INCLUDED_FLAG
               ,TAX_AMT_TAX_CURR
               ,TAX_APPLICABILITY_RESULT_ID
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_BASE_MODIFIER_RATE
               ,TAX_CALCULATION_FORMULA
               ,TAX_CODE
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_DATE
               ,TAX_DATE_RULE_ID
               ,TAX_DETERMINE_DATE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_EXCEPTION_ID
               ,TAX_EXEMPTION_ID
               ,TAX_HOLD_CODE
               ,TAX_HOLD_RELEASED_CODE
               ,TAX_ID
               ,TAX_JURISDICTION_CODE
               ,TAX_JURISDICTION_ID
               ,TAX_LINE_ID
               ,TAX_LINE_NUMBER
               ,TAX_ONLY_LINE_FLAG
               ,TAX_POINT_DATE
               ,TAX_PROVIDER_ID
               ,TAX_RATE
               ,TAX_RATE_BEFORE_EXCEPTION
               ,TAX_RATE_BEFORE_EXEMPTION
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_RATE_NAME_BEFORE_EXCEPTION
               ,TAX_RATE_NAME_BEFORE_EXEMPTION
               ,TAX_RATE_TYPE
               ,TAX_REG_NUM_DET_RESULT_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_REGIME_TEMPLATE_ID
               ,TAX_REGISTRATION_ID
               ,TAX_REGISTRATION_NUMBER
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TAX_TYPE_CODE
               ,TAXABLE_AMT
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TAXABLE_BASIS_FORMULA
               ,TAXING_JURIS_GEOGRAPHY_ID
               ,THRESH_RESULT_ID
               ,TRX_CURRENCY_CODE
               ,TRX_DATE
               ,TRX_ID
               ,TRX_ID_LEVEL2
               ,TRX_ID_LEVEL3
               ,TRX_ID_LEVEL4
               ,TRX_ID_LEVEL5
               ,TRX_ID_LEVEL6
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_DATE
               ,TRX_LINE_ID
               ,TRX_LINE_INDEX
               ,TRX_LINE_NUMBER
               ,TRX_LINE_QUANTITY
               ,TRX_NUMBER
               ,TRX_USER_KEY_LEVEL1
               ,TRX_USER_KEY_LEVEL2
               ,TRX_USER_KEY_LEVEL3
               ,TRX_USER_KEY_LEVEL4
               ,TRX_USER_KEY_LEVEL5
               ,TRX_USER_KEY_LEVEL6
               ,UNIT_PRICE
               ,UNROUNDED_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,MULTIPLE_JURISDICTIONS_FLAG)
        SELECT /*+ leading(poh) NO_EXPAND
                   use_nl(fc,pol,poll,ptp,atc,rates,regimes,taxes,status) */
                NULL 	                           ADJUSTED_DOC_APPLICATION_ID
               ,NULL 	                           ADJUSTED_DOC_DATE
               ,NULL	                           ADJUSTED_DOC_ENTITY_CODE
               ,NULL                               ADJUSTED_DOC_EVENT_CLASS_CODE
               ,NULL                               ADJUSTED_DOC_LINE_ID
               ,NULL                               ADJUSTED_DOC_NUMBER
               ,NULL                               ADJUSTED_DOC_TAX_LINE_ID
               ,NULL                               ADJUSTED_DOC_TRX_ID
               ,NULL                               ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,201	                           APPLICATION_ID
               ,NULL                               APPLIED_FROM_APPLICATION_ID
               ,NULL                               APPLIED_FROM_ENTITY_CODE
               ,NULL                               APPLIED_FROM_EVENT_CLASS_CODE
               ,NULL                               APPLIED_FROM_LINE_ID
               ,NULL                               APPLIED_FROM_TRX_ID
               ,NULL                               APPLIED_FROM_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_FROM_TRX_NUMBER
               ,NULL	                           APPLIED_TO_APPLICATION_ID
               ,NULL	                           APPLIED_TO_ENTITY_CODE
               ,NULL	                           APPLIED_TO_EVENT_CLASS_CODE
               ,NULL	                           APPLIED_TO_LINE_ID
               ,NULL	                           APPLIED_TO_TRX_ID
               ,NULL	                           APPLIED_TO_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_TO_TRX_NUMBER
               ,'N' 	                           ASSOCIATED_CHILD_FROZEN_FLAG
               ,poll.ATTRIBUTE_CATEGORY            ATTRIBUTE_CATEGORY
               ,poll.ATTRIBUTE1 	           ATTRIBUTE1
               ,poll.ATTRIBUTE10	           ATTRIBUTE10
               ,poll.ATTRIBUTE11	           ATTRIBUTE11
               ,poll.ATTRIBUTE12	           ATTRIBUTE12
               ,poll.ATTRIBUTE13	           ATTRIBUTE13
               ,poll.ATTRIBUTE14	           ATTRIBUTE14
               ,poll.ATTRIBUTE15	           ATTRIBUTE15
               ,poll.ATTRIBUTE2 	           ATTRIBUTE2
               ,poll.ATTRIBUTE3 	           ATTRIBUTE3
               ,poll.ATTRIBUTE4 	           ATTRIBUTE4
               ,poll.ATTRIBUTE5 	           ATTRIBUTE5
               ,poll.ATTRIBUTE6 	           ATTRIBUTE6
               ,poll.ATTRIBUTE7 	           ATTRIBUTE7
               ,poll.ATTRIBUTE8 	           ATTRIBUTE8
               ,poll.ATTRIBUTE9 	           ATTRIBUTE9
               ,NULL			           BASIS_RESULT_ID
               ,NULL	                           CAL_TAX_AMT
               ,NULL	                           CAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           CAL_TAX_AMT_TAX_CURR
               ,NULL	                           CALC_RESULT_ID
               ,'N'	                           CANCEL_FLAG
               ,NULL	                           CHAR1
               ,NULL	                           CHAR10
               ,NULL	                           CHAR2
               ,NULL	                           CHAR3
               ,NULL	                           CHAR4
               ,NULL	                           CHAR5
               ,NULL	                           CHAR6
               ,NULL	                           CHAR7
               ,NULL	                           CHAR8
               ,NULL	                           CHAR9
               ,'N'	                           COMPOUNDING_DEP_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_MISS_FLAG
               ,ptp.party_tax_profile_id	   CONTENT_OWNER_ID
               ,'N'	                           COPIED_FROM_OTHER_DOC_FLAG
               ,1	                           CREATED_BY
               ,SYSDATE                            CREATION_DATE
               ,NULL		                   CTRL_TOTAL_LINE_TX_AMT
               ,poll.poh_rate_date 	           CURRENCY_CONVERSION_DATE
               ,poll.poh_rate 	                   CURRENCY_CONVERSION_RATE
               ,poll.poh_rate_type 	           CURRENCY_CONVERSION_TYPE
               ,NULL	                           DATE1
               ,NULL	                           DATE10
               ,NULL	                           DATE2
               ,NULL	                           DATE3
               ,NULL	                           DATE4
               ,NULL	                           DATE5
               ,NULL	                           DATE6
               ,NULL	                          DATE7
               ,NULL	                           DATE8
               ,NULL	                           DATE9
               ,'N'	                           DELETE_FLAG
               ,NULL	                           DIRECT_RATE_RESULT_ID
               ,NULL	                           DOC_EVENT_STATUS
               ,'N'	                           ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,'RELEASE'                          ENTITY_CODE
               ,NULL	                           ESTABLISHMENT_ID
               ,NULL	                           EVAL_EXCPT_RESULT_ID
               ,NULL	                           EVAL_EXMPT_RESULT_ID
               ,'RELEASE'                          EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	   EVENT_TYPE_CODE
               ,NULL                               EXCEPTION_RATE
               ,NULL	                           EXEMPT_CERTIFICATE_NUMBER
               ,NULL	                           EXEMPT_RATE_MODIFIER
               ,NULL	                           EXEMPT_REASON
               ,NULL	                           EXEMPT_REASON_CODE
               ,'N'	                           FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,poll.GLOBAL_ATTRIBUTE_CATEGORY     GLOBAL_ATTRIBUTE_CATEGORY
               ,poll.GLOBAL_ATTRIBUTE1 	           GLOBAL_ATTRIBUTE1
               ,poll.GLOBAL_ATTRIBUTE10	           GLOBAL_ATTRIBUTE10
               ,poll.GLOBAL_ATTRIBUTE11	           GLOBAL_ATTRIBUTE11
               ,poll.GLOBAL_ATTRIBUTE12	           GLOBAL_ATTRIBUTE12
               ,poll.GLOBAL_ATTRIBUTE13	           GLOBAL_ATTRIBUTE13
               ,poll.GLOBAL_ATTRIBUTE14	           GLOBAL_ATTRIBUTE14
               ,poll.GLOBAL_ATTRIBUTE15	           GLOBAL_ATTRIBUTE15
               ,poll.GLOBAL_ATTRIBUTE2             GLOBAL_ATTRIBUTE2
               ,poll.GLOBAL_ATTRIBUTE3             GLOBAL_ATTRIBUTE3
               ,poll.GLOBAL_ATTRIBUTE4             GLOBAL_ATTRIBUTE4
               ,poll.GLOBAL_ATTRIBUTE5             GLOBAL_ATTRIBUTE5
               ,poll.GLOBAL_ATTRIBUTE6             GLOBAL_ATTRIBUTE6
               ,poll.GLOBAL_ATTRIBUTE7             GLOBAL_ATTRIBUTE7
               ,poll.GLOBAL_ATTRIBUTE8             GLOBAL_ATTRIBUTE8
               ,poll.GLOBAL_ATTRIBUTE9             GLOBAL_ATTRIBUTE9
               ,'Y'	                           HISTORICAL_FLAG
               ,NULL                               HQ_ESTB_PARTY_TAX_PROF_ID
               ,NULL	                           HQ_ESTB_REG_NUMBER
               ,NULL	                           INTERFACE_ENTITY_CODE
               ,NULL	                           INTERFACE_TAX_LINE_ID
               ,NULL                               INTERNAL_ORG_LOCATION_ID
               ,NVL(poll.poh_org_id,-99)           INTERNAL_ORGANIZATION_ID
               ,'N'                                 ITEM_DIST_CHANGED_FLAG
               ,NULL	                           LAST_MANUAL_ENTRY
               ,SYSDATE	                           LAST_UPDATE_DATE
               ,1	                           LAST_UPDATE_LOGIN
               ,1	                           LAST_UPDATED_BY
               ,poll.fsp_set_of_books_id 	   LEDGER_ID
               ,NVL(poll.oi_org_information2, -99) LEGAL_ENTITY_ID
               ,NULL                               LEGAL_ENTITY_TAX_REG_NUMBER
               ,NULL                               LEGAL_JUSTIFICATION_TEXT1
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT2
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT3
               ,NULL                               LEGAL_MESSAGE_APPL_2
               ,NULL	                           LEGAL_MESSAGE_BASIS
               ,NULL	                           LEGAL_MESSAGE_CALC
               ,NULL	                           LEGAL_MESSAGE_EXCPT
               ,NULL	                           LEGAL_MESSAGE_EXMPT
               ,NULL	                           LEGAL_MESSAGE_POS
               ,NULL	                           LEGAL_MESSAGE_RATE
               ,NULL                               LEGAL_MESSAGE_STATUS
               ,NULL	                           LEGAL_MESSAGE_THRESHOLD
               ,NULL	                           LEGAL_MESSAGE_TRN
               ,DECODE(pol.purchase_basis,
                 'TEMP LABOR', NVL(POLL.amount,0),
                 'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                    NVL(poll.quantity,0) *
                                    NVL(poll.price_override,NVL(pol.unit_price,0))),
                  NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                                   LINE_AMT
               ,NULL	                           LINE_ASSESSABLE_VALUE
               ,'N'	                           MANUALLY_ENTERED_FLAG
               ,fc.minimum_accountable_unit	   MINIMUM_ACCOUNTABLE_UNIT
               ,NULL	                           MRC_LINK_TO_TAX_LINE_ID
               ,'N'	                           MRC_TAX_LINE_FLAG
               ,NULL	                           NREC_TAX_AMT
               ,NULL	                           NREC_TAX_AMT_FUNCL_CURR
               ,NULL	                           NREC_TAX_AMT_TAX_CURR
               ,NULL	                           NUMERIC1
               ,NULL	                           NUMERIC10
               ,NULL	                           NUMERIC2
               ,NULL	                           NUMERIC3
               ,NULL	                           NUMERIC4
               ,NULL	                           NUMERIC5
               ,NULL	                           NUMERIC6
               ,NULL	                           NUMERIC7
               ,NULL	                           NUMERIC8
               ,NULL	                           NUMERIC9
               ,1	                           OBJECT_VERSION_NUMBER
               ,'N'	                           OFFSET_FLAG
               ,NULL	                           OFFSET_LINK_TO_TAX_LINE_ID
               ,NULL	                           OFFSET_TAX_RATE_CODE
               ,'N'	                           ORIG_SELF_ASSESSED_FLAG
               ,NULL	                           ORIG_TAX_AMT
               ,NULL	                           ORIG_TAX_AMT_INCLUDED_FLAG
               ,NULL	                           ORIG_TAX_AMT_TAX_CURR
               ,NULL	                           ORIG_TAX_JURISDICTION_CODE
               ,NULL	                           ORIG_TAX_JURISDICTION_ID
               ,NULL	                           ORIG_TAX_RATE
               ,NULL	                           ORIG_TAX_RATE_CODE
               ,NULL	                           ORIG_TAX_RATE_ID
               ,NULL	                           ORIG_TAX_STATUS_CODE
               ,NULL	                           ORIG_TAX_STATUS_ID
               ,NULL	                           ORIG_TAXABLE_AMT
               ,NULL	                           ORIG_TAXABLE_AMT_TAX_CURR
               ,NULL	                           OTHER_DOC_LINE_AMT
               ,NULL	                           OTHER_DOC_LINE_TAX_AMT
               ,NULL	                           OTHER_DOC_LINE_TAXABLE_AMT
               ,NULL	                           OTHER_DOC_SOURCE
               ,'N'	                           OVERRIDDEN_FLAG
               ,NULL	                           PLACE_OF_SUPPLY
               ,NULL	                           PLACE_OF_SUPPLY_RESULT_ID
               ,NULL                               PLACE_OF_SUPPLY_TYPE_CODE
               ,NULL	                           PRD_TOTAL_TAX_AMT
               ,NULL	                           PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           PRD_TOTAL_TAX_AMT_TAX_CURR
               ,NVL(fc.precision, 0)               PRECISION
               ,'N'	                           PROCESS_FOR_RECOVERY_FLAG
               ,NULL	                           PRORATION_CODE
               ,'N'	                           PURGE_FLAG
               ,NULL	                           RATE_RESULT_ID
               ,NULL	                           REC_TAX_AMT
               ,NULL	                           REC_TAX_AMT_FUNCL_CURR
               ,NULL	                           REC_TAX_AMT_TAX_CURR
               ,'N'	                           RECALC_REQUIRED_FLAG
               ,'MIGRATED'                         RECORD_TYPE_CODE
               ,NULL	                           REF_DOC_APPLICATION_ID
               ,NULL	                           REF_DOC_ENTITY_CODE
               ,NULL	                           REF_DOC_EVENT_CLASS_CODE
               ,NULL	                           REF_DOC_LINE_ID
               ,NULL	                           REF_DOC_LINE_QUANTITY
               ,NULL	                           REF_DOC_TRX_ID
               ,NULL	                           REF_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REGISTRATION_PARTY_TYPE
               ,NULL	                           RELATED_DOC_APPLICATION_ID
               ,NULL	                           RELATED_DOC_DATE
               ,NULL	                           RELATED_DOC_ENTITY_CODE
               ,NULL	                           RELATED_DOC_EVENT_CLASS_CODE
               ,NULL	                           RELATED_DOC_NUMBER
               ,NULL	                           RELATED_DOC_TRX_ID
               ,NULL	                           RELATED_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REPORTING_CURRENCY_CODE
               ,'N'	                           REPORTING_ONLY_FLAG
               ,NULL	                           REPORTING_PERIOD_ID
               ,NULL	                           ROUNDING_LEVEL_CODE
               ,NULL	                           ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,NULL	                           ROUNDING_LVL_PARTY_TYPE
               ,NULL	                           ROUNDING_RULE_CODE
               ,'N'	                           SELF_ASSESSED_FLAG
               ,'N'                                SETTLEMENT_FLAG
               ,NULL                               STATUS_RESULT_ID
               ,NULL                               SUMMARY_TAX_LINE_ID
               ,NULL                               SYNC_WITH_PRVDR_FLAG
               ,rates.tax                          TAX
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)  TAX_AMT
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)
                                                   TAX_AMT_FUNCL_CURR
               ,'N'                                TAX_AMT_INCLUDED_FLAG
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit) TAX_AMT_TAX_CURR
               ,NULL                               TAX_APPLICABILITY_RESULT_ID
               ,'Y'                                TAX_APPORTIONMENT_FLAG
               ,1                                  TAX_APPORTIONMENT_LINE_NUMBER
               ,NULL                               TAX_BASE_MODIFIER_RATE
               ,'STANDARD_TC'                      TAX_CALCULATION_FORMULA
               ,NULL                               TAX_CODE
               ,taxes.tax_currency_code            TAX_CURRENCY_CODE
               ,poll.poh_rate_date 		   TAX_CURRENCY_CONVERSION_DATE
               ,poll.poh_rate 		           TAX_CURRENCY_CONVERSION_RATE
               ,poll.poh_rate_type 		   TAX_CURRENCY_CONVERSION_TYPE
               ,poll.last_update_date              TAX_DATE
               ,NULL                               TAX_DATE_RULE_ID
               ,poll.last_update_date              TAX_DETERMINE_DATE
               ,'PURCHASE_TRANSACTION' 	           TAX_EVENT_CLASS_CODE
               ,'VALIDATE'  		           TAX_EVENT_TYPE_CODE
               ,NULL                               TAX_EXCEPTION_ID
               ,NULL                               TAX_EXEMPTION_ID
               ,NULL                               TAX_HOLD_CODE
               ,NULL                               TAX_HOLD_RELEASED_CODE
               ,taxes.tax_id                       TAX_ID
               ,NULL                               TAX_JURISDICTION_CODE
               ,NULL                               TAX_JURISDICTION_ID
               ,zx_lines_s.nextval                 TAX_LINE_ID
               ,RANK() OVER
                 (PARTITION BY poll.po_release_id
                  ORDER BY poll.line_location_id,
                           atc.tax_id)             TAX_LINE_NUMBER
               ,'N'                                TAX_ONLY_LINE_FLAG
               ,poll.last_update_date              TAX_POINT_DATE
               ,NULL                               TAX_PROVIDER_ID
               ,rates.percentage_rate  	           TAX_RATE
               ,NULL	                           TAX_RATE_BEFORE_EXCEPTION
               ,NULL                               TAX_RATE_BEFORE_EXEMPTION
               ,rates.tax_rate_code                TAX_RATE_CODE
               ,rates.tax_rate_id                  TAX_RATE_ID
               ,NULL                               TAX_RATE_NAME_BEFORE_EXCEPTION
               ,NULL                               TAX_RATE_NAME_BEFORE_EXEMPTION
               ,NULL                               TAX_RATE_TYPE
               ,NULL                               TAX_REG_NUM_DET_RESULT_ID
               ,rates.tax_regime_code              TAX_REGIME_CODE
               ,regimes.tax_regime_id              TAX_REGIME_ID
               ,NULL                               TAX_REGIME_TEMPLATE_ID
               ,NULL                               TAX_REGISTRATION_ID
               ,NULL                               TAX_REGISTRATION_NUMBER
               ,rates.tax_status_code              TAX_STATUS_CODE
               ,status.tax_status_id               TAX_STATUS_ID
               ,NULL                               TAX_TYPE_CODE
               ,NULL                               TAXABLE_AMT
               ,NULL                               TAXABLE_AMT_FUNCL_CURR
               ,NULL                               TAXABLE_AMT_TAX_CURR
               ,'STANDARD_TB'                      TAXABLE_BASIS_FORMULA
               ,NULL                               TAXING_JURIS_GEOGRAPHY_ID
               ,NULL                               THRESH_RESULT_ID
               ,NVL(poll.poh_currency_code,
                    poll.aps_base_currency_code)   TRX_CURRENCY_CODE
               ,poll.poh_last_update_date          TRX_DATE
               ,poll.po_release_id TRX_ID
               ,NULL                               TRX_ID_LEVEL2
               ,NULL                               TRX_ID_LEVEL3
               ,NULL                               TRX_ID_LEVEL4
               ,NULL                               TRX_ID_LEVEL5
               ,NULL                               TRX_ID_LEVEL6
               ,'SHIPMENT'                         TRX_LEVEL_TYPE
               ,poll.LAST_UPDATE_DATE              TRX_LINE_DATE
               ,poll.line_location_id              TRX_LINE_ID
               ,NULL                               TRX_LINE_INDEX
               ,poll.SHIPMENT_NUM                  TRX_LINE_NUMBER
               ,poll.quantity 		           TRX_LINE_QUANTITY
               ,poll.poh_segment1                  TRX_NUMBER
               ,NULL                               TRX_USER_KEY_LEVEL1
               ,NULL                               TRX_USER_KEY_LEVEL2
               ,NULL                               TRX_USER_KEY_LEVEL3
               ,NULL                               TRX_USER_KEY_LEVEL4
               ,NULL                               TRX_USER_KEY_LEVEL5
               ,NULL                               TRX_USER_KEY_LEVEL6
               ,NVL(poll.price_override,
                     pol.unit_price)               UNIT_PRICE
               ,NULL                               UNROUNDED_TAX_AMT
               ,NULL                               UNROUNDED_TAXABLE_AMT
               ,'N'                                MULTIPLE_JURISDICTIONS_FLAG
          FROM (SELECT /*+ NO_MERGE NO_EXPAND use_hash(fsp) use_hash(aps) use_hash(oi)
                           swap_join_inputs(fsp) swap_join_inputs(aps)
                           swap_join_inputs(oi) */
                       poll.*,
                       poh.rate_date 	       poh_rate_date,
                       poh.rate 	       poh_rate,
                       poh.rate_type 	       poh_rate_type,
                       poh.org_id              poh_org_id,
                       poh.currency_code       poh_currency_code,
                       poh.last_update_date    poh_last_update_date,
                       poh.segment1            poh_segment1,
                       fsp.set_of_books_id     fsp_set_of_books_id,
                       fsp.org_id              fsp_org_id,
                       aps.base_currency_code  aps_base_currency_code,
                       oi.org_information2     oi_org_information2
   	         FROM  po_line_locations_all poll,
   	               po_headers_all poh,
                       financials_system_params_all fsp,
                       ap_system_parameters_all aps,
                       hr_organization_information oi
	         WHERE poll.po_release_id = p_upg_trx_info_rec.trx_id
	           AND poh.po_header_id = poll.po_header_id
                   AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                   AND aps.set_of_books_id = fsp.set_of_books_id
                   AND NVL(aps.org_id, -99) = NVL(poh.org_id, -99)
                   AND oi.organization_id(+) = poh.org_id
                   AND oi.org_information_context(+) = 'Operating Unit Information'
               ) poll,
               fnd_currencies fc,
               po_lines_all pol,
               zx_party_tax_profile ptp,
               ap_tax_codes_all atc,
               zx_rates_b rates,
               zx_regimes_b regimes,
               zx_taxes_b taxes,
               zx_status_b status
         WHERE NVL(poll.poh_currency_code, poll.aps_base_currency_code) = fc.currency_code(+)
           AND pol.po_header_id = poll.po_header_id
           AND pol.po_line_id = poll.po_line_id
           AND nvl(atc.org_id,-99)=nvl(poll.fsp_org_id,-99)
           AND poll.tax_code_id = atc.tax_id
           AND atc.tax_type NOT IN ('TAX_GROUP','USE')
           AND NOT EXISTS
              (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                 WHERE lines_gt.application_id   = 201
                   AND lines_gt.event_class_code = 'RELEASE'
                   AND lines_gt.entity_code      = 'RELEASE'
                   AND lines_gt.trx_id           = p_upg_trx_info_rec.trx_id
                   AND lines_gt.trx_line_id      = poll.line_location_id
                   AND lines_gt.trx_level_type   = 'SHIPMENT'
                   AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
              )
           AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
           AND ptp.party_type_code = 'OU'
           AND rates.source_id = atc.tax_id
           AND regimes.tax_regime_code(+) = rates.tax_regime_code
           AND taxes.tax_regime_code(+) = rates.tax_regime_code
           AND taxes.tax(+) = rates.tax
           AND taxes.content_owner_id(+) = rates.content_owner_id
           AND status.tax_regime_code(+) = rates.tax_regime_code
           AND status.tax(+) = rates.tax
           AND status.tax_status_code(+) = rates.tax_status_code
           AND status.content_owner_id(+) = rates.content_owner_id
           AND NOT EXISTS
                (SELECT 1 FROM zx_lines zxl
                  WHERE zxl.APPLICATION_ID   = 201
                    AND zxl.EVENT_CLASS_CODE = 'RELEASE'
                    AND zxl.ENTITY_CODE      = 'RELEASE'
                    AND zxl.TRX_ID           = p_upg_trx_info_rec.trx_id
                    AND zxl.TRX_LINE_ID      = poll.line_location_id
                    AND zxl.TRX_LEVEL_TYPE   = 'SHIPMENT'
                   -- AND zxl.TAX_REGIME_CODE  = rates.tax_regime_code
                   -- AND zxl.TAX              = rates.tax
                   -- AND NVL(zxl.TAX_APPORTIONMENT_LINE_NUMBER,1) = NVL(TAX_APPORTIONMENT_LINE_NUMBER,1)
                 );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                    'Number of Rows Inserted(Tax Code) = ' || TO_CHAR(SQL%ROWCOUNT));
    END IF;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_po',
                     'Inserting data into zx_lines(Tax Group)');
    END IF;

    -- Insert data into zx_lines
    --
    INSERT INTO ZX_LINES(
                ADJUSTED_DOC_APPLICATION_ID
               ,ADJUSTED_DOC_DATE
               ,ADJUSTED_DOC_ENTITY_CODE
               ,ADJUSTED_DOC_EVENT_CLASS_CODE
               ,ADJUSTED_DOC_LINE_ID
               ,ADJUSTED_DOC_NUMBER
               ,ADJUSTED_DOC_TAX_LINE_ID
               ,ADJUSTED_DOC_TRX_ID
               ,ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,APPLICATION_ID
               ,APPLIED_FROM_APPLICATION_ID
               ,APPLIED_FROM_ENTITY_CODE
               ,APPLIED_FROM_EVENT_CLASS_CODE
               ,APPLIED_FROM_LINE_ID
               ,APPLIED_FROM_TRX_ID
               ,APPLIED_FROM_TRX_LEVEL_TYPE
               ,APPLIED_FROM_TRX_NUMBER
               ,APPLIED_TO_APPLICATION_ID
               ,APPLIED_TO_ENTITY_CODE
               ,APPLIED_TO_EVENT_CLASS_CODE
               ,APPLIED_TO_LINE_ID
               ,APPLIED_TO_TRX_ID
               ,APPLIED_TO_TRX_LEVEL_TYPE
               ,APPLIED_TO_TRX_NUMBER
               ,ASSOCIATED_CHILD_FROZEN_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,BASIS_RESULT_ID
               ,CAL_TAX_AMT
               ,CAL_TAX_AMT_FUNCL_CURR
               ,CAL_TAX_AMT_TAX_CURR
               ,CALC_RESULT_ID
               ,CANCEL_FLAG
               ,CHAR1
               ,CHAR10
               ,CHAR2
               ,CHAR3
               ,CHAR4
               ,CHAR5
               ,CHAR6
               ,CHAR7
               ,CHAR8
               ,CHAR9
               ,COMPOUNDING_DEP_TAX_FLAG
               ,COMPOUNDING_TAX_FLAG
               ,COMPOUNDING_TAX_MISS_FLAG
               ,CONTENT_OWNER_ID
               ,COPIED_FROM_OTHER_DOC_FLAG
               ,CREATED_BY
               ,CREATION_DATE
               ,CTRL_TOTAL_LINE_TX_AMT
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,DATE1
               ,DATE10
               ,DATE2
               ,DATE3
               ,DATE4
               ,DATE5
               ,DATE6
               ,DATE7
               ,DATE8
               ,DATE9
               ,DELETE_FLAG
               ,DIRECT_RATE_RESULT_ID
               ,DOC_EVENT_STATUS
               ,ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,ENTITY_CODE
               ,ESTABLISHMENT_ID
               ,EVAL_EXCPT_RESULT_ID
               ,EVAL_EXMPT_RESULT_ID
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,EXCEPTION_RATE
               ,EXEMPT_CERTIFICATE_NUMBER
               ,EXEMPT_RATE_MODIFIER
               ,EXEMPT_REASON
               ,EXEMPT_REASON_CODE
               ,FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,GLOBAL_ATTRIBUTE_CATEGORY
               ,GLOBAL_ATTRIBUTE1
               ,GLOBAL_ATTRIBUTE10
               ,GLOBAL_ATTRIBUTE11
               ,GLOBAL_ATTRIBUTE12
               ,GLOBAL_ATTRIBUTE13
               ,GLOBAL_ATTRIBUTE14
               ,GLOBAL_ATTRIBUTE15
               ,GLOBAL_ATTRIBUTE2
               ,GLOBAL_ATTRIBUTE3
               ,GLOBAL_ATTRIBUTE4
               ,GLOBAL_ATTRIBUTE5
               ,GLOBAL_ATTRIBUTE6
               ,GLOBAL_ATTRIBUTE7
               ,GLOBAL_ATTRIBUTE8
               ,GLOBAL_ATTRIBUTE9
               ,HISTORICAL_FLAG
               ,HQ_ESTB_PARTY_TAX_PROF_ID
               ,HQ_ESTB_REG_NUMBER
               ,INTERFACE_ENTITY_CODE
               ,INTERFACE_TAX_LINE_ID
               ,INTERNAL_ORG_LOCATION_ID
               ,INTERNAL_ORGANIZATION_ID
               ,ITEM_DIST_CHANGED_FLAG
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,LEDGER_ID
               ,LEGAL_ENTITY_ID
               ,LEGAL_ENTITY_TAX_REG_NUMBER
               ,LEGAL_JUSTIFICATION_TEXT1
               ,LEGAL_JUSTIFICATION_TEXT2
               ,LEGAL_JUSTIFICATION_TEXT3
               ,LEGAL_MESSAGE_APPL_2
               ,LEGAL_MESSAGE_BASIS
               ,LEGAL_MESSAGE_CALC
               ,LEGAL_MESSAGE_EXCPT
               ,LEGAL_MESSAGE_EXMPT
               ,LEGAL_MESSAGE_POS
               ,LEGAL_MESSAGE_RATE
               ,LEGAL_MESSAGE_STATUS
               ,LEGAL_MESSAGE_THRESHOLD
               ,LEGAL_MESSAGE_TRN
               ,LINE_AMT
               ,LINE_ASSESSABLE_VALUE
               ,MANUALLY_ENTERED_FLAG
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,MRC_LINK_TO_TAX_LINE_ID
               ,MRC_TAX_LINE_FLAG
               ,NREC_TAX_AMT
               ,NREC_TAX_AMT_FUNCL_CURR
               ,NREC_TAX_AMT_TAX_CURR
               ,NUMERIC1
               ,NUMERIC10
               ,NUMERIC2
               ,NUMERIC3
               ,NUMERIC4
               ,NUMERIC5
               ,NUMERIC6
               ,NUMERIC7
               ,NUMERIC8
               ,NUMERIC9
               ,OBJECT_VERSION_NUMBER
               ,OFFSET_FLAG
               ,OFFSET_LINK_TO_TAX_LINE_ID
               ,OFFSET_TAX_RATE_CODE
               ,ORIG_SELF_ASSESSED_FLAG
               ,ORIG_TAX_AMT
               ,ORIG_TAX_AMT_INCLUDED_FLAG
               ,ORIG_TAX_AMT_TAX_CURR
               ,ORIG_TAX_JURISDICTION_CODE
               ,ORIG_TAX_JURISDICTION_ID
               ,ORIG_TAX_RATE
               ,ORIG_TAX_RATE_CODE
               ,ORIG_TAX_RATE_ID
               ,ORIG_TAX_STATUS_CODE
               ,ORIG_TAX_STATUS_ID
               ,ORIG_TAXABLE_AMT
               ,ORIG_TAXABLE_AMT_TAX_CURR
               ,OTHER_DOC_LINE_AMT
               ,OTHER_DOC_LINE_TAX_AMT
               ,OTHER_DOC_LINE_TAXABLE_AMT
               ,OTHER_DOC_SOURCE
               ,OVERRIDDEN_FLAG
               ,PLACE_OF_SUPPLY
               ,PLACE_OF_SUPPLY_RESULT_ID
               ,PLACE_OF_SUPPLY_TYPE_CODE
               ,PRD_TOTAL_TAX_AMT
               ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,PRD_TOTAL_TAX_AMT_TAX_CURR
               ,PRECISION
               ,PROCESS_FOR_RECOVERY_FLAG
               ,PRORATION_CODE
               ,PURGE_FLAG
               ,RATE_RESULT_ID
               ,REC_TAX_AMT
               ,REC_TAX_AMT_FUNCL_CURR
               ,REC_TAX_AMT_TAX_CURR
               ,RECALC_REQUIRED_FLAG
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_LINE_QUANTITY
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,REGISTRATION_PARTY_TYPE
               ,RELATED_DOC_APPLICATION_ID
               ,RELATED_DOC_DATE
               ,RELATED_DOC_ENTITY_CODE
               ,RELATED_DOC_EVENT_CLASS_CODE
               ,RELATED_DOC_NUMBER
               ,RELATED_DOC_TRX_ID
               ,RELATED_DOC_TRX_LEVEL_TYPE
               ,REPORTING_CURRENCY_CODE
               ,REPORTING_ONLY_FLAG
               ,REPORTING_PERIOD_ID
               ,ROUNDING_LEVEL_CODE
               ,ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,ROUNDING_LVL_PARTY_TYPE
               ,ROUNDING_RULE_CODE
               ,SELF_ASSESSED_FLAG
               ,SETTLEMENT_FLAG
               ,STATUS_RESULT_ID
               ,SUMMARY_TAX_LINE_ID
               ,SYNC_WITH_PRVDR_FLAG
               ,TAX
               ,TAX_AMT
               ,TAX_AMT_FUNCL_CURR
               ,TAX_AMT_INCLUDED_FLAG
               ,TAX_AMT_TAX_CURR
               ,TAX_APPLICABILITY_RESULT_ID
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_BASE_MODIFIER_RATE
               ,TAX_CALCULATION_FORMULA
               ,TAX_CODE
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_DATE
               ,TAX_DATE_RULE_ID
               ,TAX_DETERMINE_DATE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_EXCEPTION_ID
               ,TAX_EXEMPTION_ID
               ,TAX_HOLD_CODE
               ,TAX_HOLD_RELEASED_CODE
               ,TAX_ID
               ,TAX_JURISDICTION_CODE
               ,TAX_JURISDICTION_ID
               ,TAX_LINE_ID
               ,TAX_LINE_NUMBER
               ,TAX_ONLY_LINE_FLAG
               ,TAX_POINT_DATE
               ,TAX_PROVIDER_ID
               ,TAX_RATE
               ,TAX_RATE_BEFORE_EXCEPTION
               ,TAX_RATE_BEFORE_EXEMPTION
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_RATE_NAME_BEFORE_EXCEPTION
               ,TAX_RATE_NAME_BEFORE_EXEMPTION
               ,TAX_RATE_TYPE
               ,TAX_REG_NUM_DET_RESULT_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_REGIME_TEMPLATE_ID
               ,TAX_REGISTRATION_ID
               ,TAX_REGISTRATION_NUMBER
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TAX_TYPE_CODE
               ,TAXABLE_AMT
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TAXABLE_BASIS_FORMULA
               ,TAXING_JURIS_GEOGRAPHY_ID
               ,THRESH_RESULT_ID
               ,TRX_CURRENCY_CODE
               ,TRX_DATE
               ,TRX_ID
               ,TRX_ID_LEVEL2
               ,TRX_ID_LEVEL3
               ,TRX_ID_LEVEL4
               ,TRX_ID_LEVEL5
               ,TRX_ID_LEVEL6
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_DATE
               ,TRX_LINE_ID
               ,TRX_LINE_INDEX
               ,TRX_LINE_NUMBER
               ,TRX_LINE_QUANTITY
               ,TRX_NUMBER
               ,TRX_USER_KEY_LEVEL1
               ,TRX_USER_KEY_LEVEL2
               ,TRX_USER_KEY_LEVEL3
               ,TRX_USER_KEY_LEVEL4
               ,TRX_USER_KEY_LEVEL5
               ,TRX_USER_KEY_LEVEL6
               ,UNIT_PRICE
               ,UNROUNDED_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,MULTIPLE_JURISDICTIONS_FLAG)
        SELECT /*+ leading(poh) NO_EXPAND
                   use_nl(fc,pol,poll,ptp,atc,atg,atc1,rates,regimes,taxes,status) */
                NULL 	                           ADJUSTED_DOC_APPLICATION_ID
               ,NULL 	                           ADJUSTED_DOC_DATE
               ,NULL	                           ADJUSTED_DOC_ENTITY_CODE
               ,NULL                               ADJUSTED_DOC_EVENT_CLASS_CODE
               ,NULL                               ADJUSTED_DOC_LINE_ID
               ,NULL                               ADJUSTED_DOC_NUMBER
               ,NULL                               ADJUSTED_DOC_TAX_LINE_ID
               ,NULL                               ADJUSTED_DOC_TRX_ID
               ,NULL                               ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,201	                           APPLICATION_ID
               ,NULL                               APPLIED_FROM_APPLICATION_ID
               ,NULL                               APPLIED_FROM_ENTITY_CODE
               ,NULL                               APPLIED_FROM_EVENT_CLASS_CODE
               ,NULL                               APPLIED_FROM_LINE_ID
               ,NULL                               APPLIED_FROM_TRX_ID
               ,NULL                               APPLIED_FROM_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_FROM_TRX_NUMBER
               ,NULL	                           APPLIED_TO_APPLICATION_ID
               ,NULL	                           APPLIED_TO_ENTITY_CODE
               ,NULL	                           APPLIED_TO_EVENT_CLASS_CODE
               ,NULL	                           APPLIED_TO_LINE_ID
               ,NULL	                           APPLIED_TO_TRX_ID
               ,NULL	                           APPLIED_TO_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_TO_TRX_NUMBER
               ,'N' 	                           ASSOCIATED_CHILD_FROZEN_FLAG
               ,poll.ATTRIBUTE_CATEGORY            ATTRIBUTE_CATEGORY
               ,poll.ATTRIBUTE1 	           ATTRIBUTE1
               ,poll.ATTRIBUTE10	           ATTRIBUTE10
               ,poll.ATTRIBUTE11	           ATTRIBUTE11
               ,poll.ATTRIBUTE12	           ATTRIBUTE12
               ,poll.ATTRIBUTE13	           ATTRIBUTE13
               ,poll.ATTRIBUTE14	           ATTRIBUTE14
               ,poll.ATTRIBUTE15	           ATTRIBUTE15
               ,poll.ATTRIBUTE2 	           ATTRIBUTE2
               ,poll.ATTRIBUTE3 	           ATTRIBUTE3
               ,poll.ATTRIBUTE4 	           ATTRIBUTE4
               ,poll.ATTRIBUTE5 	           ATTRIBUTE5
               ,poll.ATTRIBUTE6 	           ATTRIBUTE6
               ,poll.ATTRIBUTE7 	           ATTRIBUTE7
               ,poll.ATTRIBUTE8 	           ATTRIBUTE8
               ,poll.ATTRIBUTE9 	           ATTRIBUTE9
               ,NULL			           BASIS_RESULT_ID
               ,NULL	                           CAL_TAX_AMT
               ,NULL	                           CAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           CAL_TAX_AMT_TAX_CURR
               ,NULL	                           CALC_RESULT_ID
               ,'N'	                           CANCEL_FLAG
               ,NULL	                           CHAR1
               ,NULL	                           CHAR10
               ,NULL	                           CHAR2
               ,NULL	                           CHAR3
               ,NULL	                           CHAR4
               ,NULL	                           CHAR5
               ,NULL	                           CHAR6
               ,NULL	                           CHAR7
               ,NULL	                           CHAR8
               ,NULL	                           CHAR9
               ,'N'	                           COMPOUNDING_DEP_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_MISS_FLAG
               ,ptp.party_tax_profile_id	   CONTENT_OWNER_ID
               ,'N'	                           COPIED_FROM_OTHER_DOC_FLAG
               ,1	                           CREATED_BY
               ,SYSDATE                            CREATION_DATE
               ,NULL		                   CTRL_TOTAL_LINE_TX_AMT
               ,poll.poh_rate_date 	           CURRENCY_CONVERSION_DATE
               ,poll.poh_rate 	                   CURRENCY_CONVERSION_RATE
               ,poll.poh_rate_type 	           CURRENCY_CONVERSION_TYPE
               ,NULL	                           DATE1
               ,NULL	                           DATE10
               ,NULL	                           DATE2
               ,NULL	                           DATE3
               ,NULL	                           DATE4
               ,NULL	                           DATE5
               ,NULL	                           DATE6
               ,NULL	                          DATE7
               ,NULL	                           DATE8
               ,NULL	                           DATE9
               ,'N'	                           DELETE_FLAG
               ,NULL	                           DIRECT_RATE_RESULT_ID
               ,NULL	                           DOC_EVENT_STATUS
               ,'N'	                           ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,'RELEASE'                          ENTITY_CODE
               ,NULL	                           ESTABLISHMENT_ID
               ,NULL	                           EVAL_EXCPT_RESULT_ID
               ,NULL	                           EVAL_EXMPT_RESULT_ID
               ,'RELEASE'                          EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	   EVENT_TYPE_CODE
               ,NULL                               EXCEPTION_RATE
               ,NULL	                           EXEMPT_CERTIFICATE_NUMBER
               ,NULL	                           EXEMPT_RATE_MODIFIER
               ,NULL	                           EXEMPT_REASON
               ,NULL	                           EXEMPT_REASON_CODE
               ,'N'	                           FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,poll.GLOBAL_ATTRIBUTE_CATEGORY     GLOBAL_ATTRIBUTE_CATEGORY
               ,poll.GLOBAL_ATTRIBUTE1 	           GLOBAL_ATTRIBUTE1
               ,poll.GLOBAL_ATTRIBUTE10	           GLOBAL_ATTRIBUTE10
               ,poll.GLOBAL_ATTRIBUTE11	           GLOBAL_ATTRIBUTE11
               ,poll.GLOBAL_ATTRIBUTE12	           GLOBAL_ATTRIBUTE12
               ,poll.GLOBAL_ATTRIBUTE13	           GLOBAL_ATTRIBUTE13
               ,poll.GLOBAL_ATTRIBUTE14	           GLOBAL_ATTRIBUTE14
               ,poll.GLOBAL_ATTRIBUTE15	           GLOBAL_ATTRIBUTE15
               ,poll.GLOBAL_ATTRIBUTE2             GLOBAL_ATTRIBUTE2
               ,poll.GLOBAL_ATTRIBUTE3             GLOBAL_ATTRIBUTE3
               ,poll.GLOBAL_ATTRIBUTE4             GLOBAL_ATTRIBUTE4
               ,poll.GLOBAL_ATTRIBUTE5             GLOBAL_ATTRIBUTE5
               ,poll.GLOBAL_ATTRIBUTE6             GLOBAL_ATTRIBUTE6
               ,poll.GLOBAL_ATTRIBUTE7             GLOBAL_ATTRIBUTE7
               ,poll.GLOBAL_ATTRIBUTE8             GLOBAL_ATTRIBUTE8
               ,poll.GLOBAL_ATTRIBUTE9             GLOBAL_ATTRIBUTE9
               ,'Y'	                           HISTORICAL_FLAG
               ,NULL                               HQ_ESTB_PARTY_TAX_PROF_ID
               ,NULL	                           HQ_ESTB_REG_NUMBER
               ,NULL	                           INTERFACE_ENTITY_CODE
               ,NULL	                           INTERFACE_TAX_LINE_ID
               ,NULL                               INTERNAL_ORG_LOCATION_ID
               ,NVL(poll.poh_org_id,-99)           INTERNAL_ORGANIZATION_ID
               ,'N'                                 ITEM_DIST_CHANGED_FLAG
               ,NULL	                           LAST_MANUAL_ENTRY
               ,SYSDATE	                           LAST_UPDATE_DATE
               ,1	                           LAST_UPDATE_LOGIN
               ,1	                           LAST_UPDATED_BY
               ,poll.fsp_set_of_books_id 	   LEDGER_ID
               ,NVL(poll.oi_org_information2, -99) LEGAL_ENTITY_ID
               ,NULL                               LEGAL_ENTITY_TAX_REG_NUMBER
               ,NULL                               LEGAL_JUSTIFICATION_TEXT1
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT2
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT3
               ,NULL                               LEGAL_MESSAGE_APPL_2
               ,NULL	                           LEGAL_MESSAGE_BASIS
               ,NULL	                           LEGAL_MESSAGE_CALC
               ,NULL	                           LEGAL_MESSAGE_EXCPT
               ,NULL	                           LEGAL_MESSAGE_EXMPT
               ,NULL	                           LEGAL_MESSAGE_POS
               ,NULL	                           LEGAL_MESSAGE_RATE
               ,NULL                               LEGAL_MESSAGE_STATUS
               ,NULL	                           LEGAL_MESSAGE_THRESHOLD
               ,NULL	                           LEGAL_MESSAGE_TRN
               ,DECODE(pol.purchase_basis,
                 'TEMP LABOR', NVL(POLL.amount,0),
                 'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                    NVL(poll.quantity,0) *
                                    NVL(poll.price_override,NVL(pol.unit_price,0))),
                  NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                                   LINE_AMT
               ,NULL	                           LINE_ASSESSABLE_VALUE
               ,'N'	                           MANUALLY_ENTERED_FLAG
               ,fc.minimum_accountable_unit	   MINIMUM_ACCOUNTABLE_UNIT
               ,NULL	                           MRC_LINK_TO_TAX_LINE_ID
               ,'N'	                           MRC_TAX_LINE_FLAG
               ,NULL	                           NREC_TAX_AMT
               ,NULL	                           NREC_TAX_AMT_FUNCL_CURR
               ,NULL	                           NREC_TAX_AMT_TAX_CURR
               ,NULL	                           NUMERIC1
               ,NULL	                           NUMERIC10
               ,NULL	                           NUMERIC2
               ,NULL	                           NUMERIC3
               ,NULL	                           NUMERIC4
               ,NULL	                           NUMERIC5
               ,NULL	                           NUMERIC6
               ,NULL	                           NUMERIC7
               ,NULL	                           NUMERIC8
               ,NULL	                           NUMERIC9
               ,1	                           OBJECT_VERSION_NUMBER
               ,'N'	                           OFFSET_FLAG
               ,NULL	                           OFFSET_LINK_TO_TAX_LINE_ID
               ,NULL	                           OFFSET_TAX_RATE_CODE
               ,'N'	                           ORIG_SELF_ASSESSED_FLAG
               ,NULL	                           ORIG_TAX_AMT
               ,NULL	                           ORIG_TAX_AMT_INCLUDED_FLAG
               ,NULL	                           ORIG_TAX_AMT_TAX_CURR
               ,NULL	                           ORIG_TAX_JURISDICTION_CODE
               ,NULL	                           ORIG_TAX_JURISDICTION_ID
               ,NULL	                           ORIG_TAX_RATE
               ,NULL	                           ORIG_TAX_RATE_CODE
               ,NULL	                           ORIG_TAX_RATE_ID
               ,NULL	                           ORIG_TAX_STATUS_CODE
               ,NULL	                           ORIG_TAX_STATUS_ID
               ,NULL	                           ORIG_TAXABLE_AMT
               ,NULL	                           ORIG_TAXABLE_AMT_TAX_CURR
               ,NULL	                           OTHER_DOC_LINE_AMT
               ,NULL	                           OTHER_DOC_LINE_TAX_AMT
               ,NULL	                           OTHER_DOC_LINE_TAXABLE_AMT
               ,NULL	                           OTHER_DOC_SOURCE
               ,'N'	                           OVERRIDDEN_FLAG
               ,NULL	                           PLACE_OF_SUPPLY
               ,NULL	                           PLACE_OF_SUPPLY_RESULT_ID
               ,NULL                               PLACE_OF_SUPPLY_TYPE_CODE
               ,NULL	                           PRD_TOTAL_TAX_AMT
               ,NULL	                           PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           PRD_TOTAL_TAX_AMT_TAX_CURR
               ,NVL(fc.precision, 0)               PRECISION
               ,'N'	                           PROCESS_FOR_RECOVERY_FLAG
               ,NULL	                           PRORATION_CODE
               ,'N'	                           PURGE_FLAG
               ,NULL	                           RATE_RESULT_ID
               ,NULL	                           REC_TAX_AMT
               ,NULL	                           REC_TAX_AMT_FUNCL_CURR
               ,NULL	                           REC_TAX_AMT_TAX_CURR
               ,'N'	                           RECALC_REQUIRED_FLAG
               ,'MIGRATED'                         RECORD_TYPE_CODE
               ,NULL	                           REF_DOC_APPLICATION_ID
               ,NULL	                           REF_DOC_ENTITY_CODE
               ,NULL	                           REF_DOC_EVENT_CLASS_CODE
               ,NULL	                           REF_DOC_LINE_ID
               ,NULL	                           REF_DOC_LINE_QUANTITY
               ,NULL	                           REF_DOC_TRX_ID
               ,NULL	                           REF_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REGISTRATION_PARTY_TYPE
               ,NULL	                           RELATED_DOC_APPLICATION_ID
               ,NULL	                           RELATED_DOC_DATE
               ,NULL	                           RELATED_DOC_ENTITY_CODE
               ,NULL	                           RELATED_DOC_EVENT_CLASS_CODE
               ,NULL	                           RELATED_DOC_NUMBER
               ,NULL	                           RELATED_DOC_TRX_ID
               ,NULL	                           RELATED_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REPORTING_CURRENCY_CODE
               ,'N'	                           REPORTING_ONLY_FLAG
               ,NULL	                           REPORTING_PERIOD_ID
               ,NULL	                           ROUNDING_LEVEL_CODE
               ,NULL	                           ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,NULL	                           ROUNDING_LVL_PARTY_TYPE
               ,NULL	                           ROUNDING_RULE_CODE
               ,'N'	                           SELF_ASSESSED_FLAG
               ,'N'                                SETTLEMENT_FLAG
               ,NULL                               STATUS_RESULT_ID
               ,NULL                               SUMMARY_TAX_LINE_ID
               ,NULL                               SYNC_WITH_PRVDR_FLAG
               ,rates.tax                          TAX
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)  TAX_AMT
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)
                                                   TAX_AMT_FUNCL_CURR
               ,'N'                                TAX_AMT_INCLUDED_FLAG
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit) TAX_AMT_TAX_CURR
               ,NULL                               TAX_APPLICABILITY_RESULT_ID
               ,'Y'                                TAX_APPORTIONMENT_FLAG
               ,RANK() OVER
                 (PARTITION BY
                   poll.po_release_id,
                   poll.line_location_id,
                   rates.tax_regime_code,
                   rates.tax
                  ORDER BY atg.tax_code_id)        TAX_APPORTIONMENT_LINE_NUMBER
               ,NULL                               TAX_BASE_MODIFIER_RATE
               ,'STANDARD_TC'                      TAX_CALCULATION_FORMULA
               ,NULL                               TAX_CODE
               ,taxes.tax_currency_code            TAX_CURRENCY_CODE
               ,poll.poh_rate_date 		   TAX_CURRENCY_CONVERSION_DATE
               ,poll.poh_rate 		           TAX_CURRENCY_CONVERSION_RATE
               ,poll.poh_rate_type 		   TAX_CURRENCY_CONVERSION_TYPE
               ,poll.last_update_date              TAX_DATE
               ,NULL                               TAX_DATE_RULE_ID
               ,poll.last_update_date              TAX_DETERMINE_DATE
               ,'PURCHASE_TRANSACTION' 	           TAX_EVENT_CLASS_CODE
               ,'VALIDATE'  		           TAX_EVENT_TYPE_CODE
               ,NULL                               TAX_EXCEPTION_ID
               ,NULL                               TAX_EXEMPTION_ID
               ,NULL                               TAX_HOLD_CODE
               ,NULL                               TAX_HOLD_RELEASED_CODE
               ,taxes.tax_id                       TAX_ID
               ,NULL                               TAX_JURISDICTION_CODE
               ,NULL                               TAX_JURISDICTION_ID
               ,zx_lines_s.nextval                 TAX_LINE_ID
               ,RANK() OVER
                 (PARTITION BY poll.po_release_id
                  ORDER BY poll.line_location_id,
                           atg.tax_code_id,
                           atc.tax_id)             TAX_LINE_NUMBER
               ,'N'                                TAX_ONLY_LINE_FLAG
               ,poll.last_update_date              TAX_POINT_DATE
               ,NULL                               TAX_PROVIDER_ID
               ,rates.percentage_rate  	           TAX_RATE
               ,NULL	                           TAX_RATE_BEFORE_EXCEPTION
               ,NULL                               TAX_RATE_BEFORE_EXEMPTION
               ,rates.tax_rate_code                TAX_RATE_CODE
               ,rates.tax_rate_id                  TAX_RATE_ID
               ,NULL                               TAX_RATE_NAME_BEFORE_EXCEPTION
               ,NULL                               TAX_RATE_NAME_BEFORE_EXEMPTION
               ,NULL                               TAX_RATE_TYPE
               ,NULL                               TAX_REG_NUM_DET_RESULT_ID
               ,rates.tax_regime_code              TAX_REGIME_CODE
               ,regimes.tax_regime_id              TAX_REGIME_ID
               ,NULL                               TAX_REGIME_TEMPLATE_ID
               ,NULL                               TAX_REGISTRATION_ID
               ,NULL                               TAX_REGISTRATION_NUMBER
               ,rates.tax_status_code              TAX_STATUS_CODE
               ,status.tax_status_id               TAX_STATUS_ID
               ,NULL                               TAX_TYPE_CODE
               ,NULL                               TAXABLE_AMT
               ,NULL                               TAXABLE_AMT_FUNCL_CURR
               ,NULL                               TAXABLE_AMT_TAX_CURR
               ,'STANDARD_TB'                      TAXABLE_BASIS_FORMULA
               ,NULL                               TAXING_JURIS_GEOGRAPHY_ID
               ,NULL                               THRESH_RESULT_ID
               ,NVL(poll.poh_currency_code,
                    poll.aps_base_currency_code)   TRX_CURRENCY_CODE
               ,poll.poh_last_update_date          TRX_DATE
               ,poll.po_release_id TRX_ID
               ,NULL                               TRX_ID_LEVEL2
               ,NULL                               TRX_ID_LEVEL3
               ,NULL                               TRX_ID_LEVEL4
               ,NULL                               TRX_ID_LEVEL5
               ,NULL                               TRX_ID_LEVEL6
               ,'SHIPMENT'                         TRX_LEVEL_TYPE
               ,poll.LAST_UPDATE_DATE              TRX_LINE_DATE
               ,poll.line_location_id              TRX_LINE_ID
               ,NULL                               TRX_LINE_INDEX
               ,poll.SHIPMENT_NUM                  TRX_LINE_NUMBER
               ,poll.quantity 		           TRX_LINE_QUANTITY
               ,poll.poh_segment1                  TRX_NUMBER
               ,NULL                               TRX_USER_KEY_LEVEL1
               ,NULL                               TRX_USER_KEY_LEVEL2
               ,NULL                               TRX_USER_KEY_LEVEL3
               ,NULL                               TRX_USER_KEY_LEVEL4
               ,NULL                               TRX_USER_KEY_LEVEL5
               ,NULL                               TRX_USER_KEY_LEVEL6
               ,NVL(poll.price_override,
                     pol.unit_price)               UNIT_PRICE
               ,NULL                               UNROUNDED_TAX_AMT
               ,NULL                               UNROUNDED_TAXABLE_AMT
               ,'N'                                MULTIPLE_JURISDICTIONS_FLAG
          FROM (SELECT /*+ NO_MERGE NO_EXPAND use_hash(fsp) use_hash(aps) use_hash(oi)
                           swap_join_inputs(fsp) swap_join_inputs(aps)
                           swap_join_inputs(oi) */
                       poll.*,
                       poh.rate_date 	       poh_rate_date,
                       poh.rate 	       poh_rate,
                       poh.rate_type 	       poh_rate_type,
                       poh.org_id              poh_org_id,
                       poh.currency_code       poh_currency_code,
                       poh.last_update_date    poh_last_update_date,
                       poh.segment1            poh_segment1,
                       fsp.set_of_books_id     fsp_set_of_books_id,
                       fsp.org_id              fsp_org_id,
                       aps.base_currency_code  aps_base_currency_code,
                       oi.org_information2     oi_org_information2
   	         FROM  po_line_locations_all poll,
   	               po_headers_all poh,
                       financials_system_params_all fsp,
                       ap_system_parameters_all aps,
                       hr_organization_information oi
	         WHERE poll.po_release_id = p_upg_trx_info_rec.trx_id
	           AND poh.po_header_id = poll.po_header_id
                   AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                   AND aps.set_of_books_id = fsp.set_of_books_id
                   AND NVL(aps.org_id, -99) = NVL(poh.org_id, -99)
                   AND oi.organization_id(+) = poh.org_id
                   AND oi.org_information_context(+) = 'Operating Unit Information'
               ) poll,
               fnd_currencies fc,
               po_lines_all pol,
               zx_party_tax_profile ptp,
               ap_tax_codes_all atc,
               ar_tax_group_codes_all atg,
               ap_tax_codes_all atc1,
               zx_rates_b rates,
               zx_regimes_b regimes,
               zx_taxes_b taxes,
               zx_status_b status
         WHERE NVL(poll.poh_currency_code, poll.aps_base_currency_code) = fc.currency_code(+)
           AND pol.po_header_id = poll.po_header_id
           AND pol.po_line_id = poll.po_line_id
           AND nvl(atc.org_id,-99)=nvl(poll.fsp_org_id,-99)
           AND poll.tax_code_id = atc.tax_id
           AND atc.tax_type = 'TAX_GROUP'
           --Bug 8352135
 	         AND atg.start_date <= poll.last_update_date
 	         AND (atg.end_date >= poll.last_update_date OR atg.end_date IS NULL)
           AND poll.tax_code_id = atg.tax_group_id
           AND atc1.tax_id = atg.tax_code_id
           AND atc1.start_date <= poll.last_update_date
           AND(atc1.inactive_date >= poll.last_update_date OR atc1.inactive_date IS NULL)
           AND NOT EXISTS
              (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                 WHERE lines_gt.application_id   = 201
                   AND lines_gt.event_class_code = 'RELEASE'
                   AND lines_gt.entity_code      = 'RELEASE'
                   AND lines_gt.trx_id           = p_upg_trx_info_rec.trx_id
                   AND lines_gt.trx_line_id      = poll.line_location_id
                   AND lines_gt.trx_level_type   = 'SHIPMENT'
                   AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
              )
           AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
           AND ptp.party_type_code = 'OU'
           AND rates.source_id = atg.tax_code_id
           AND regimes.tax_regime_code(+) = rates.tax_regime_code
           AND taxes.tax_regime_code(+) = rates.tax_regime_code
           AND taxes.tax(+) = rates.tax
           AND taxes.content_owner_id(+) = rates.content_owner_id
           AND status.tax_regime_code(+) = rates.tax_regime_code
           AND status.tax(+) = rates.tax
           AND status.tax_status_code(+) = rates.tax_status_code
           AND status.content_owner_id(+) = rates.content_owner_id
           AND NOT EXISTS
                (SELECT 1 FROM zx_lines zxl
                  WHERE zxl.APPLICATION_ID   = 201
                    AND zxl.EVENT_CLASS_CODE = 'RELEASE'
                    AND zxl.ENTITY_CODE      = 'RELEASE'
                    AND zxl.TRX_ID           = p_upg_trx_info_rec.trx_id
                    AND zxl.TRX_LINE_ID      = poll.line_location_id
                    AND zxl.TRX_LEVEL_TYPE   = 'SHIPMENT'
                   -- AND zxl.TAX_REGIME_CODE  = rates.tax_regime_code
                   -- AND zxl.TAX              = rates.tax
                   -- AND NVL(zxl.TAX_APPORTIONMENT_LINE_NUMBER,1) = NVL(TAX_APPORTIONMENT_LINE_NUMBER,1)
                 );

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                    'Number of Rows Inserted(Tax Group) = ' || TO_CHAR(SQL%ROWCOUNT));
    END IF;


    -- COMMIT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_po',
                    'Inserting data into zx_rec_nrec_dist');
    END IF;

    -- Insert data into zx_rec_nrec_dist
    --
    INSERT INTO ZX_REC_NREC_DIST(
                TAX_LINE_ID
               ,REC_NREC_TAX_DIST_ID
               ,REC_NREC_TAX_DIST_NUMBER
               ,APPLICATION_ID
               ,CONTENT_OWNER_ID
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,ENTITY_CODE
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,LEDGER_ID
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,PRECISION
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,SUMMARY_TAX_LINE_ID
               ,TAX
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_ID
               ,TAX_LINE_NUMBER
               ,TAX_RATE
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TRX_CURRENCY_CODE
               ,TRX_ID
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_ID
               ,TRX_LINE_NUMBER
               ,TRX_NUMBER
               ,UNIT_PRICE
               ,ACCOUNT_CCID
               ,ACCOUNT_STRING
               ,ADJUSTED_DOC_TAX_DIST_ID
               ,APPLIED_FROM_TAX_DIST_ID
               ,APPLIED_TO_DOC_CURR_CONV_RATE
               ,AWARD_ID
               ,EXPENDITURE_ITEM_DATE
               ,EXPENDITURE_ORGANIZATION_ID
               ,EXPENDITURE_TYPE
               ,FUNC_CURR_ROUNDING_ADJUSTMENT
               ,GL_DATE
               ,INTENDED_USE
               ,ITEM_DIST_NUMBER
               ,MRC_LINK_TO_TAX_DIST_ID
               ,ORIG_REC_NREC_RATE
               ,ORIG_REC_NREC_TAX_AMT
               ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
               ,ORIG_REC_RATE_CODE
               ,PER_TRX_CURR_UNIT_NR_AMT
               ,PER_UNIT_NREC_TAX_AMT
               ,PRD_TAX_AMT
               ,PRICE_DIFF
               ,PROJECT_ID
               ,QTY_DIFF
               ,RATE_TAX_FACTOR
               ,REC_NREC_RATE
               ,REC_NREC_TAX_AMT
               ,REC_NREC_TAX_AMT_FUNCL_CURR
               ,REC_NREC_TAX_AMT_TAX_CURR
               ,RECOVERY_RATE_CODE
               ,RECOVERY_RATE_ID
               ,RECOVERY_TYPE_CODE
               ,RECOVERY_TYPE_ID
               ,REF_DOC_CURR_CONV_RATE
               ,REF_DOC_DIST_ID
               ,REF_DOC_PER_UNIT_NREC_TAX_AMT
               ,REF_DOC_TAX_DIST_ID
               ,REF_DOC_TRX_LINE_DIST_QTY
               ,REF_DOC_UNIT_PRICE
               ,REF_PER_TRX_CURR_UNIT_NR_AMT
               ,REVERSED_TAX_DIST_ID
               ,ROUNDING_RULE_CODE
               ,TASK_ID
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TRX_LINE_DIST_AMT
               ,TRX_LINE_DIST_ID
               ,TRX_LINE_DIST_QTY
               ,TRX_LINE_DIST_TAX_AMT
               ,UNROUNDED_REC_NREC_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,TAXABLE_AMT
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,HISTORICAL_FLAG
               ,OVERRIDDEN_FLAG
               ,SELF_ASSESSED_FLAG
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_ONLY_LINE_FLAG
               ,INCLUSIVE_FLAG
               ,MRC_TAX_DIST_FLAG
               ,REC_TYPE_RULE_FLAG
               ,NEW_REC_RATE_CODE_FLAG
               ,RECOVERABLE_FLAG
               ,REVERSE_FLAG
               ,REC_RATE_DET_RULE_FLAG
               ,BACKWARD_COMPATIBILITY_FLAG
               ,FREEZE_FLAG
               ,POSTING_FLAG
               ,LEGAL_ENTITY_ID
               ,CREATED_BY
               ,CREATION_DATE
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,OBJECT_VERSION_NUMBER)
        SELECT /*+ NO_EXPAND leading(pohzd) use_nl(fc, rates)*/
                pohzd.tax_line_id		    TAX_LINE_ID
               ,zx_rec_nrec_dist_s.NEXTVAL          REC_NREC_TAX_DIST_ID
               ,DECODE(tmp.rec_flag,
                 'Y', (RANK() OVER (PARTITION BY pohzd.trx_id,
                                    pohzd.p_po_distribution_id
                                    ORDER BY
                                    pohzd.p_po_distribution_id,pohzd.tax_rate_id))*2-1,
                 'N', (RANK() OVER (PARTITION BY pohzd.trx_id,
                                    pohzd.p_po_distribution_id
                                    ORDER BY
                                    pohzd.p_po_distribution_id,pohzd.tax_rate_id))*2)
                                                    REC_NREC_TAX_DIST_NUMBER
               ,201 				    APPLICATION_ID
               ,pohzd.content_owner_id		    CONTENT_OWNER_ID
               ,pohzd.CURRENCY_CONVERSION_DATE	    CURRENCY_CONVERSION_DATE
               ,pohzd.CURRENCY_CONVERSION_RATE	    CURRENCY_CONVERSION_RATE
               ,pohzd.CURRENCY_CONVERSION_TYPE	    CURRENCY_CONVERSION_TYPE
               ,'RELEASE' 			    ENTITY_CODE
               ,'RELEASE'			    EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	    EVENT_TYPE_CODE
               ,pohzd.ledger_id			    LEDGER_ID
               ,pohzd.MINIMUM_ACCOUNTABLE_UNIT	    MINIMUM_ACCOUNTABLE_UNIT
               ,pohzd.PRECISION			    PRECISION
               ,'MIGRATED' 			    RECORD_TYPE_CODE
               ,NULL 				    REF_DOC_APPLICATION_ID
               ,NULL 				    REF_DOC_ENTITY_CODE
               ,NULL				    REF_DOC_EVENT_CLASS_CODE
               ,NULL				    REF_DOC_LINE_ID
               ,NULL				    REF_DOC_TRX_ID
               ,NULL				    REF_DOC_TRX_LEVEL_TYPE
               ,NULL 				    SUMMARY_TAX_LINE_ID
               ,pohzd.tax			    TAX
               ,pohzd.TAX_APPORTIONMENT_LINE_NUMBER TAX_APPORTIONMENT_LINE_NUMBER
               ,pohzd.TAX_CURRENCY_CODE	            TAX_CURRENCY_CODE
               ,pohzd.TAX_CURRENCY_CONVERSION_DATE  TAX_CURRENCY_CONVERSION_DATE
               ,pohzd.TAX_CURRENCY_CONVERSION_RATE  TAX_CURRENCY_CONVERSION_RATE
               ,pohzd.TAX_CURRENCY_CONVERSION_TYPE  TAX_CURRENCY_CONVERSION_TYPE
               ,'PURCHASE_TRANSACTION' 		    TAX_EVENT_CLASS_CODE
               ,'VALIDATE'			    TAX_EVENT_TYPE_CODE
               ,pohzd.tax_id			    TAX_ID
               ,pohzd.tax_line_number		    TAX_LINE_NUMBER
               ,pohzd.tax_rate			    TAX_RATE
               ,pohzd.tax_rate_code 		    TAX_RATE_CODE
               ,pohzd.tax_rate_id		    TAX_RATE_ID
               ,pohzd.tax_regime_code	 	    TAX_REGIME_CODE
               ,pohzd.tax_regime_id		    TAX_REGIME_ID
               ,pohzd.tax_status_code		    TAX_STATUS_CODE
               ,pohzd.tax_status_id	 	    TAX_STATUS_ID
               ,pohzd.trx_currency_code		    TRX_CURRENCY_CODE
               ,pohzd.trx_id			    TRX_ID
               ,'SHIPMENT' 			    TRX_LEVEL_TYPE
               ,pohzd.trx_line_id		    TRX_LINE_ID
               ,pohzd.trx_line_number		    TRX_LINE_NUMBER
               ,pohzd.trx_number		    TRX_NUMBER
               ,pohzd.unit_price		    UNIT_PRICE
               ,NULL				    ACCOUNT_CCID
               ,NULL				    ACCOUNT_STRING
               ,NULL				    ADJUSTED_DOC_TAX_DIST_ID
               ,NULL				    APPLIED_FROM_TAX_DIST_ID
               ,NULL				    APPLIED_TO_DOC_CURR_CONV_RATE
               ,NULL			            AWARD_ID
               ,pohzd.p_expenditure_item_date	    EXPENDITURE_ITEM_DATE
               ,pohzd.p_expenditure_organization_id EXPENDITURE_ORGANIZATION_ID
               ,pohzd.p_expenditure_type	    EXPENDITURE_TYPE
               ,NULL				    FUNC_CURR_ROUNDING_ADJUSTMENT
               ,NULL			            GL_DATE
               ,NULL				    INTENDED_USE
               ,NULL				    ITEM_DIST_NUMBER
               ,NULL				    MRC_LINK_TO_TAX_DIST_ID
               ,NULL				    ORIG_REC_NREC_RATE
               ,NULL				    ORIG_REC_NREC_TAX_AMT
               ,NULL				    ORIG_REC_NREC_TAX_AMT_TAX_CURR
               ,NULL				    ORIG_REC_RATE_CODE
               ,NULL				    PER_TRX_CURR_UNIT_NR_AMT
               ,NULL				    PER_UNIT_NREC_TAX_AMT
               ,NULL				    PRD_TAX_AMT
               ,NULL				    PRICE_DIFF
               ,pohzd.p_project_id		    PROJECT_ID
               ,NULL				    QTY_DIFF
               ,NULL				    RATE_TAX_FACTOR
               ,DECODE(tmp.rec_flag,
                 'Y', NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate), 0),
                 'N', 100 - NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate), 0))
                                                    REC_NREC_RATE
               ,DECODE(tmp.rec_flag,
                       'N',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                               (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                       'Y',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                 (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                  NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                     (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                      )                             REC_NREC_TAX_AMT
               ,DECODE(tmp.rec_flag,
                       'N',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                       'Y',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                 (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                  NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                     (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                      )                             REC_NREC_TAX_AMT_FUNCL_CURR
               ,DECODE(tmp.rec_flag,
                        'N',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                       'Y',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                 (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                  NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                     (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                      )                             REC_NREC_TAX_AMT_TAX_CURR
               ,NVL(rates.tax_rate_code,
                             'AD_HOC_RECOVERY')     RECOVERY_RATE_CODE
               ,rates.tax_rate_id                   RECOVERY_RATE_ID
               ,DECODE(tmp.rec_flag,'N', NULL,
                      NVL(rates.recovery_type_code,
                          'STANDARD'))              RECOVERY_TYPE_CODE
               ,NULL				    RECOVERY_TYPE_ID
               ,NULL				    REF_DOC_CURR_CONV_RATE
               ,NULL				    REF_DOC_DIST_ID
               ,NULL				    REF_DOC_PER_UNIT_NREC_TAX_AMT
               ,NULL				    REF_DOC_TAX_DIST_ID
               ,NULL				    REF_DOC_TRX_LINE_DIST_QTY
               ,NULL				    REF_DOC_UNIT_PRICE
               ,NULL				    REF_PER_TRX_CURR_UNIT_NR_AMT
               ,NULL				    REVERSED_TAX_DIST_ID
               ,NULL				    ROUNDING_RULE_CODE
               ,pohzd.p_task_id			    TASK_ID
               ,null				    TAXABLE_AMT_FUNCL_CURR
               ,NULL				    TAXABLE_AMT_TAX_CURR
               ,NULL				    TRX_LINE_DIST_AMT
               ,pohzd.p_po_distribution_id	    TRX_LINE_DIST_ID
               ,NULL				    TRX_LINE_DIST_QTY
               ,NULL				    TRX_LINE_DIST_TAX_AMT
               ,NULL				    UNROUNDED_REC_NREC_TAX_AMT
               ,NULL				    UNROUNDED_TAXABLE_AMT
               ,NULL				    TAXABLE_AMT
               ,pohzd.p_ATTRIBUTE_CATEGORY          ATTRIBUTE_CATEGORY
               ,pohzd.p_ATTRIBUTE1                  ATTRIBUTE1
               ,pohzd.p_ATTRIBUTE2                  ATTRIBUTE2
               ,pohzd.p_ATTRIBUTE3                  ATTRIBUTE3
               ,pohzd.p_ATTRIBUTE4                  ATTRIBUTE4
               ,pohzd.p_ATTRIBUTE5                  ATTRIBUTE5
               ,pohzd.p_ATTRIBUTE6                  ATTRIBUTE6
               ,pohzd.p_ATTRIBUTE7                  ATTRIBUTE7
               ,pohzd.p_ATTRIBUTE8                  ATTRIBUTE8
               ,pohzd.p_ATTRIBUTE9                  ATTRIBUTE9
               ,pohzd.p_ATTRIBUTE10                 ATTRIBUTE10
               ,pohzd.p_ATTRIBUTE11                 ATTRIBUTE11
               ,pohzd.p_ATTRIBUTE12                 ATTRIBUTE12
               ,pohzd.p_ATTRIBUTE13                 ATTRIBUTE13
               ,pohzd.p_ATTRIBUTE14                 ATTRIBUTE14
               ,pohzd.p_ATTRIBUTE15                 ATTRIBUTE15
               ,'Y'			            HISTORICAL_FLAG
               ,'N'			            OVERRIDDEN_FLAG
               ,'N'			            SELF_ASSESSED_FLAG
               ,'Y'			            TAX_APPORTIONMENT_FLAG
               ,'N'			            TAX_ONLY_LINE_FLAG
               ,'N'			            INCLUSIVE_FLAG
               ,'N'			            MRC_TAX_DIST_FLAG
               ,'N'			            REC_TYPE_RULE_FLAG
               ,'N'			            NEW_REC_RATE_CODE_FLAG
               ,tmp.rec_flag                        RECOVERABLE_FLAG
               ,'N'			            REVERSE_FLAG
               ,'N'			            REC_RATE_DET_RULE_FLAG
               ,'Y'			            BACKWARD_COMPATIBILITY_FLAG
               ,'N'			            FREEZE_FLAG
               ,'N'			            POSTING_FLAG
               ,NVL(pohzd.legal_entity_id, -99)	    LEGAL_ENTITY_ID
               ,1			            CREATED_BY
               ,SYSDATE		                    CREATION_DATE
               ,NULL		                    LAST_MANUAL_ENTRY
               ,SYSDATE		                    LAST_UPDATE_DATE
               ,1			            LAST_UPDATE_LOGIN
               ,1			            LAST_UPDATED_BY
               ,1			            OBJECT_VERSION_NUMBER
          FROM (SELECT /*+ use_nl_with_index(recdist ZX_PO_REC_DIST_N1) */
                       pohzd.*,
                       recdist.rec_rate     d_rec_rate
                  FROM (SELECT /*+ NO_EXPAND leading(poh) use_nl_with_index(zxl, ZX_LINES_U1) use_nl(pod) */
                              poh.po_header_id,
                              poll.last_update_date poll_last_update_date,
                              fsp.set_of_books_id,
                              zxl.*,
                              pod.po_distribution_id                  p_po_distribution_id,
                              pod.expenditure_item_date               p_expenditure_item_date,
                              pod.expenditure_organization_id         p_expenditure_organization_id,
                              pod.expenditure_type                    p_expenditure_type,
                              pod.project_id                          p_project_id,
                              pod.task_id                             p_task_id,
                              pod.recovery_rate                       p_recovery_rate,
                              pod.quantity_ordered                    p_quantity_ordered,
                              pod.attribute_category                  p_attribute_category ,
                              pod.attribute1                          p_attribute1,
                              pod.attribute2                          p_attribute2,
                              pod.attribute3                          p_attribute3,
                              pod.attribute4                          p_attribute4,
                              pod.attribute5                          p_attribute5,
                              pod.attribute6                          p_attribute6,
                              pod.attribute7                          p_attribute7,
                              pod.attribute8                          p_attribute8,
                              pod.attribute9                          p_attribute9,
                              pod.attribute10                         p_attribute10,
                              pod.attribute11                         p_attribute11,
                              pod.attribute12                         p_attribute12,
                              pod.attribute13                         p_attribute13,
                              pod.attribute14                         p_attribute14,
                              pod.attribute15                         p_attribute15
                         FROM po_line_locations_all poll,
                              po_headers_all poh,
                       	      financials_system_params_all fsp,
                              zx_lines zxl,
                              po_distributions_all pod
                        WHERE poll.po_release_id = p_upg_trx_info_rec.trx_id
                          AND poh.po_header_id = poll.po_header_id
                          AND NVL(poh.org_id, -99) = NVL(fsp.org_id, -99)
                          AND zxl.application_id = 201
                          AND zxl.entity_code = 'RELEASE'
                          AND zxl.event_class_code = 'RELEASE'
                          AND zxl.trx_id = p_upg_trx_info_rec.trx_id
                          AND zxl.trx_line_id = poll.line_location_id
                          AND NOT EXISTS
                              (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                                WHERE lines_gt.application_id   = 201
                                  AND lines_gt.event_class_code = 'RELEASE'
                                  AND lines_gt.entity_code      = 'RELEASE'
                                  AND lines_gt.trx_id           = p_upg_trx_info_rec.trx_id
                                  AND lines_gt.trx_line_id      = poll.line_location_id
                                  AND lines_gt.trx_level_type   = 'SHIPMENT'
                                  AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
                              )
                          AND pod.po_header_id = poll.po_header_id
                          AND pod.line_location_id = poll.line_location_id
                       ) pohzd,
                         zx_po_rec_dist recdist
                   WHERE recdist.po_header_id(+) = pohzd.trx_id
                     AND recdist.po_line_location_id(+) = pohzd.trx_line_id
                     AND recdist.po_distribution_id(+) = pohzd.p_po_distribution_id
                     AND recdist.tax_rate_id(+) = pohzd.tax_rate_id
               ) pohzd,
               fnd_currencies fc,
               zx_rates_b rates,
               (SELECT 'Y' rec_flag FROM dual UNION ALL SELECT 'N' rec_flag FROM dual) tmp
         WHERE pohzd.trx_currency_code = fc.currency_code(+)
           AND rates.tax_regime_code(+) = pohzd.tax_regime_code
           AND rates.tax(+) = pohzd.tax
           AND rates.content_owner_id(+) = pohzd.content_owner_id
           AND rates.rate_type_code(+) = 'RECOVERY'
           AND rates.recovery_type_code(+) = 'STANDARD'
           AND rates.active_flag(+) = 'Y'
           AND rates.effective_from(+) <= sysdate
           --Bug 8724131
           --AND (rates.effective_to IS NULL OR rates.effective_to >= sysdate)
           --Bug 8752951
           AND pohzd.poll_last_update_date BETWEEN rates.effective_from AND NVL(rates.effective_to, pohzd.poll_last_update_date)
           AND rates.record_type_code(+) = 'MIGRATED'
           AND rates.percentage_rate(+) = NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate),0)
           AND rates.tax_rate_code(+) NOT LIKE 'AD_HOC_RECOVERY%'
           AND NOT EXISTS
          (SELECT 1 FROM zx_rec_nrec_dist zxdist
            WHERE zxdist.application_id               = 201
              AND zxdist.entity_code			= 'RELEASE'
              AND zxdist.event_class_code		= 'RELEASE'
              AND zxdist.trx_id			= p_upg_trx_info_rec.trx_id
              AND zxdist.trx_line_id			= pohzd.trx_line_id
              AND nvl(zxdist.content_owner_id,-99)	= nvl(pohzd.content_owner_id,-99)
              -- AND zxdist.tax_line_id               = pohzd.tax_line_id
              -- AND zxdist.trx_line_dist_id		= pod.po_distribution_id
           );

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                   'Number of Rows Inserted = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;
 END IF;       -- entity_code = 'PURCHASE_ORDER' or 'RELEASE'

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po.END',
                   'ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po.END',
                    'ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_po(-)');
    END IF;

END upgrade_trx_on_fly_po;


-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- upgrade_trx_on_fly_blk_po
--
-- DESCRIPTION
-- handle bulk on the fly migration for PO, called from validate and default API
--
-------------------------------------------------------------------------------
PROCEDURE upgrade_trx_on_fly_blk_po(
  x_return_status        OUT NOCOPY  VARCHAR2
) AS

l_org_id    		NUMBER;
l_multi_org_flag	fnd_product_groups.multi_org_flag%TYPE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT multi_org_flag INTO l_multi_org_flag FROM fnd_product_groups;

  IF NVL(l_multi_org_flag,'N') = 'N' THEN  -- non- multi org
    FND_PROFILE.GET('ORG_ID',l_org_id);
    IF l_org_id is NULL THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                      'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk_po',
                      'Current envionment is a Single Org environment,'||
                      ' but profile ORG_ID is not set up');
      END IF;
    END IF;
  END IF;

  -- calculate recovery rate for tax group
  --
  ZX_PO_REC_PKG.get_rec_info(x_return_status  =>  x_return_status);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk_po',
                   'Inserting data into zx_lines_det_factors');
  END IF;
  -- Insert data into zx_lines_det_factors
  --
    INSERT INTO ZX_LINES_DET_FACTORS (
            EVENT_ID
           ,ACCOUNT_CCID
           ,ACCOUNT_STRING
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           ,APPLICATION_DOC_STATUS
           ,APPLICATION_ID
           ,APPLIED_FROM_APPLICATION_ID
           ,APPLIED_FROM_ENTITY_CODE
           ,APPLIED_FROM_EVENT_CLASS_CODE
           ,APPLIED_FROM_LINE_ID
           ,APPLIED_FROM_TRX_ID
           ,APPLIED_FROM_TRX_LEVEL_TYPE
           ,APPLIED_TO_APPLICATION_ID
           ,APPLIED_TO_ENTITY_CODE
           ,APPLIED_TO_EVENT_CLASS_CODE
           ,APPLIED_TO_TRX_ID
           ,APPLIED_TO_TRX_LEVEL_TYPE
           ,APPLIED_TO_TRX_LINE_ID
           ,APPLIED_TO_TRX_NUMBER
           ,ASSESSABLE_VALUE
           ,ASSET_ACCUM_DEPRECIATION
           ,ASSET_COST
           ,ASSET_FLAG
           ,ASSET_NUMBER
           ,ASSET_TYPE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,BILL_FROM_LOCATION_ID
           ,BILL_FROM_PARTY_TAX_PROF_ID
           ,BILL_FROM_SITE_TAX_PROF_ID
           ,BILL_TO_LOCATION_ID
           ,BILL_TO_PARTY_TAX_PROF_ID
           ,BILL_TO_SITE_TAX_PROF_ID
           ,COMPOUNDING_TAX_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,CTRL_HDR_TX_APPL_FLAG
           ,CTRL_TOTAL_HDR_TX_AMT
           ,CTRL_TOTAL_LINE_TX_AMT
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,DEFAULT_TAXATION_COUNTRY
           ,DOC_EVENT_STATUS
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,DOCUMENT_SUB_TYPE
           ,ENTITY_CODE
           ,ESTABLISHMENT_ID
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,FIRST_PTY_ORG_ID
           ,HISTORICAL_FLAG
           ,HQ_ESTB_PARTY_TAX_PROF_ID
           ,INCLUSIVE_TAX_OVERRIDE_FLAG
           ,INPUT_TAX_CLASSIFICATION_CODE
           ,INTERNAL_ORG_LOCATION_ID
           ,INTERNAL_ORGANIZATION_ID
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
           ,LEDGER_ID
           ,LEGAL_ENTITY_ID
           ,LINE_AMT
           ,LINE_AMT_INCLUDES_TAX_FLAG
           ,LINE_CLASS
           ,LINE_INTENDED_USE
           ,LINE_LEVEL_ACTION
           ,MERCHANT_PARTY_COUNTRY
           ,MERCHANT_PARTY_DOCUMENT_NUMBER
           ,MERCHANT_PARTY_ID
           ,MERCHANT_PARTY_NAME
           ,MERCHANT_PARTY_REFERENCE
           ,MERCHANT_PARTY_TAX_PROF_ID
           ,MERCHANT_PARTY_TAX_REG_NUMBER
           ,MERCHANT_PARTY_TAXPAYER_ID
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,OBJECT_VERSION_NUMBER
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           ,PORT_OF_ENTRY_CODE
           ,PRECISION
           ,PRODUCT_CATEGORY
           ,PRODUCT_CODE
           ,PRODUCT_DESCRIPTION
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ID
           ,PRODUCT_ORG_ID
           ,PRODUCT_TYPE
           ,RECORD_TYPE_CODE
           ,REF_DOC_APPLICATION_ID
           ,REF_DOC_ENTITY_CODE
           ,REF_DOC_EVENT_CLASS_CODE
           ,REF_DOC_LINE_ID
           ,REF_DOC_LINE_QUANTITY
           ,REF_DOC_TRX_ID
           ,REF_DOC_TRX_LEVEL_TYPE
           ,RELATED_DOC_APPLICATION_ID
           ,RELATED_DOC_DATE
           ,RELATED_DOC_ENTITY_CODE
           ,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_NUMBER
           ,RELATED_DOC_TRX_ID
           ,SHIP_FROM_LOCATION_ID
           ,SHIP_FROM_PARTY_TAX_PROF_ID
           ,SHIP_FROM_SITE_TAX_PROF_ID
           ,SHIP_TO_LOCATION_ID
           ,SHIP_TO_PARTY_TAX_PROF_ID
           ,SHIP_TO_SITE_TAX_PROF_ID
           ,SOURCE_APPLICATION_ID
           ,SOURCE_ENTITY_CODE
           ,SOURCE_EVENT_CLASS_CODE
           ,SOURCE_LINE_ID
           ,SOURCE_TRX_ID
           ,SOURCE_TRX_LEVEL_TYPE
           ,START_EXPENSE_DATE
           ,SUPPLIER_EXCHANGE_RATE
           ,SUPPLIER_TAX_INVOICE_DATE
           ,SUPPLIER_TAX_INVOICE_NUMBER
           ,TAX_AMT_INCLUDED_FLAG
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,TAX_PROCESSING_COMPLETED_FLAG
           ,TAX_REPORTING_FLAG
           ,THRESHOLD_INDICATOR_FLAG
           ,TRX_BUSINESS_CATEGORY
           ,TRX_COMMUNICATED_DATE
           ,TRX_CURRENCY_CODE
           ,TRX_DATE
           ,TRX_DESCRIPTION
           ,TRX_DUE_DATE
           ,TRX_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_DATE
           ,TRX_LINE_DESCRIPTION
           ,TRX_LINE_GL_DATE
           ,TRX_LINE_ID
           ,TRX_LINE_NUMBER
           ,TRX_LINE_QUANTITY
           ,TRX_LINE_TYPE
           ,TRX_NUMBER
           ,TRX_RECEIPT_DATE
           ,TRX_SHIPPING_DATE
           ,TRX_TYPE_DESCRIPTION
           ,UNIT_PRICE
           ,UOM_CODE
           ,USER_DEFINED_FISC_CLASS
           ,USER_UPD_DET_FACTORS_FLAG
           ,EVENT_CLASS_MAPPING_ID
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,ICX_SESSION_ID
           ,TRX_LINE_CURRENCY_CODE
           ,TRX_LINE_CURRENCY_CONV_RATE
           ,TRX_LINE_CURRENCY_CONV_DATE
           ,TRX_LINE_PRECISION
           ,TRX_LINE_MAU
           ,TRX_LINE_CURRENCY_CONV_TYPE
           ,INTERFACE_ENTITY_CODE
           ,INTERFACE_LINE_ID
           ,SOURCE_TAX_LINE_ID
           ,TAX_CALCULATION_DONE_FLAG
           ,LINE_TRX_USER_KEY1
           ,LINE_TRX_USER_KEY2
           ,LINE_TRX_USER_KEY3
         )
          SELECT /*+ ORDERED NO_EXPAND use_nl(fc, pol, poll, ptp, hr) */
           NULL 			    EVENT_ID,
           NULL 			    ACCOUNT_CCID,
           NULL 			    ACCOUNT_STRING,
           NULL 			    ADJUSTED_DOC_APPLICATION_ID,
           NULL 			    ADJUSTED_DOC_DATE,
           NULL 			    ADJUSTED_DOC_ENTITY_CODE,
           NULL 			    ADJUSTED_DOC_EVENT_CLASS_CODE,
           NULL 			    ADJUSTED_DOC_LINE_ID,
           NULL 			    ADJUSTED_DOC_NUMBER,
           NULL 			    ADJUSTED_DOC_TRX_ID,
           NULL 			    ADJUSTED_DOC_TRX_LEVEL_TYPE,
           NULL 			    APPLICATION_DOC_STATUS,
           201 			            APPLICATION_ID,
           NULL 			    APPLIED_FROM_APPLICATION_ID,
           NULL 			    APPLIED_FROM_ENTITY_CODE,
           NULL 			    APPLIED_FROM_EVENT_CLASS_CODE,
           NULL 			    APPLIED_FROM_LINE_ID,
           NULL 			    APPLIED_FROM_TRX_ID,
           NULL 			    APPLIED_FROM_TRX_LEVEL_TYPE,
           NULL 			    APPLIED_TO_APPLICATION_ID,
           NULL 			    APPLIED_TO_ENTITY_CODE,
           NULL 			    APPLIED_TO_EVENT_CLASS_CODE,
           NULL 			    APPLIED_TO_TRX_ID,
           NULL 			    APPLIED_TO_TRX_LEVEL_TYPE,
           NULL 			    APPLIED_TO_TRX_LINE_ID,
           NULL 			    APPLIED_TO_TRX_NUMBER,
           NULL 			    ASSESSABLE_VALUE,
           NULL 			    ASSET_ACCUM_DEPRECIATION,
           NULL 			    ASSET_COST,
           NULL 			    ASSET_FLAG,
           NULL 			    ASSET_NUMBER,
           NULL 			    ASSET_TYPE,
           NULL 			    BATCH_SOURCE_ID,
           NULL 			    BATCH_SOURCE_NAME,
           NULL 			    BILL_FROM_LOCATION_ID,
           NULL 			    BILL_FROM_PARTY_TAX_PROF_ID,
           NULL 			    BILL_FROM_SITE_TAX_PROF_ID,
           NULL 			    BILL_TO_LOCATION_ID,
           NULL 			    BILL_TO_PARTY_TAX_PROF_ID,
           NULL 			    BILL_TO_SITE_TAX_PROF_ID,
           'N' 			            COMPOUNDING_TAX_FLAG,
           1   			            CREATED_BY,
           SYSDATE 		            CREATION_DATE,
           'N' 			            CTRL_HDR_TX_APPL_FLAG,
           NULL			            CTRL_TOTAL_HDR_TX_AMT,
           NULL	 		            CTRL_TOTAL_LINE_TX_AMT,
           poh.rate_date 		    CURRENCY_CONVERSION_DATE,
           poh.rate 		            CURRENCY_CONVERSION_RATE,
           poh.rate_type 		    CURRENCY_CONVERSION_TYPE,
           NULL 			    DEFAULT_TAXATION_COUNTRY,
           NULL 			    DOC_EVENT_STATUS,
           NULL 			    DOC_SEQ_ID,
           NULL 			    DOC_SEQ_NAME,
           NULL 			    DOC_SEQ_VALUE,
           NULL 			    DOCUMENT_SUB_TYPE,
           'PURCHASE_ORDER' 		    ENTITY_CODE,
           NULL 			    ESTABLISHMENT_ID,
           'PO_PA' 	                    EVENT_CLASS_CODE,
           'PURCHASE ORDER CREATED'         EVENT_TYPE_CODE,
           ptp.party_tax_profile_id	    FIRST_PTY_ORG_ID,
           'Y' 			            HISTORICAL_FLAG,
           NULL	 		            HQ_ESTB_PARTY_TAX_PROF_ID,
           'N' 			            INCLUSIVE_TAX_OVERRIDE_FLAG,
           (select name
	    from ap_tax_codes_all
	    where tax_id = poll.tax_code_id) INPUT_TAX_CLASSIFICATION_CODE,
           NULL 			    INTERNAL_ORG_LOCATION_ID,
           nvl(poh.org_id,-99) 	            INTERNAL_ORGANIZATION_ID,
           SYSDATE 		            LAST_UPDATE_DATE,
           1 			            LAST_UPDATE_LOGIN,
           1 			            LAST_UPDATED_BY,
           poh.set_of_books_id 	            LEDGER_ID,
           NVL(poh.oi_org_information2,-99) LEGAL_ENTITY_ID,
           DECODE(pol.purchase_basis,
            'TEMP LABOR', NVL(POLL.amount,0),
            'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                               NVL(poll.quantity,0) *
                               NVL(poll.price_override,NVL(pol.unit_price,0))),
             NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                            LINE_AMT,
           'N' 			            LINE_AMT_INCLUDES_TAX_FLAG,
           'INVOICE' 		            LINE_CLASS,
           NULL 			    LINE_INTENDED_USE,
           'CREATE' 		            LINE_LEVEL_ACTION,
           NULL 			    MERCHANT_PARTY_COUNTRY,
           NULL 			    MERCHANT_PARTY_DOCUMENT_NUMBER,
           NULL 			    MERCHANT_PARTY_ID,
           NULL 			    MERCHANT_PARTY_NAME,
           NULL 			    MERCHANT_PARTY_REFERENCE,
           NULL 			    MERCHANT_PARTY_TAX_PROF_ID,
           NULL 			    MERCHANT_PARTY_TAX_REG_NUMBER,
           NULL 			    MERCHANT_PARTY_TAXPAYER_ID,
           fc.minimum_accountable_unit      MINIMUM_ACCOUNTABLE_UNIT,
           1 			            OBJECT_VERSION_NUMBER,
           NULL 			    OUTPUT_TAX_CLASSIFICATION_CODE,
           NULL 			    PORT_OF_ENTRY_CODE,
           NVL(fc.precision, 0)             PRECISION,
           -- fc.precision 		    PRECISION,
           NULL 			    PRODUCT_CATEGORY,
           NULL 			    PRODUCT_CODE,
           NULL 			    PRODUCT_DESCRIPTION,
           NULL 			    PRODUCT_FISC_CLASSIFICATION,
           pol.item_id		            PRODUCT_ID,
           poll.ship_to_organization_id	    PRODUCT_ORG_ID,
           DECODE(UPPER(pol.purchase_basis),
                  'GOODS', 'GOODS',
                  'SERVICES', 'SERVICES',
                  'TEMP LABOR','SERVICES',
                  'GOODS') 		    PRODUCT_TYPE,
           'MIGRATED' 		            RECORD_TYPE_CODE,
           NULL 			    REF_DOC_APPLICATION_ID,
           NULL 			    REF_DOC_ENTITY_CODE,
           NULL 			    REF_DOC_EVENT_CLASS_CODE,
           NULL 			    REF_DOC_LINE_ID,
           NULL 			    REF_DOC_LINE_QUANTITY,
           NULL 			    REF_DOC_TRX_ID,
           NULL 			    REF_DOC_TRX_LEVEL_TYPE,
           NULL 			    RELATED_DOC_APPLICATION_ID,
           NULL 			    RELATED_DOC_DATE,
           NULL 			    RELATED_DOC_ENTITY_CODE,
           NULL 			    RELATED_DOC_EVENT_CLASS_CODE,
           NULL 			    RELATED_DOC_NUMBER,
           NULL 			    RELATED_DOC_TRX_ID,
           NULL 			    SHIP_FROM_LOCATION_ID,
           NULL 			    SHIP_FROM_PARTY_TAX_PROF_ID,
           NULL 			    SHIP_FROM_SITE_TAX_PROF_ID,
           poll.ship_to_location_id         SHIP_TO_LOCATION_ID,
           NULL 			    SHIP_TO_PARTY_TAX_PROF_ID,
           NULL 			    SHIP_TO_SITE_TAX_PROF_ID,
           NULL 			    SOURCE_APPLICATION_ID,
           NULL 			    SOURCE_ENTITY_CODE,
           NULL 			    SOURCE_EVENT_CLASS_CODE,
           NULL 			    SOURCE_LINE_ID,
           NULL 			    SOURCE_TRX_ID,
           NULL 			    SOURCE_TRX_LEVEL_TYPE,
           NULL 			    START_EXPENSE_DATE,
           NULL 			    SUPPLIER_EXCHANGE_RATE,
           NULL 			    SUPPLIER_TAX_INVOICE_DATE,
           NULL 			    SUPPLIER_TAX_INVOICE_NUMBER,
           'N' 			            TAX_AMT_INCLUDED_FLAG,
           'PURCHASE_TRANSACTION' 	    TAX_EVENT_CLASS_CODE,
           'VALIDATE'  		            TAX_EVENT_TYPE_CODE,
           NULL 			    TAX_INVOICE_DATE,
           NULL 			    TAX_INVOICE_NUMBER,
           'Y'			            TAX_PROCESSING_COMPLETED_FLAG,
           'N'			            TAX_REPORTING_FLAG,
           'N' 			            THRESHOLD_INDICATOR_FLAG,
           NULL 			    TRX_BUSINESS_CATEGORY,
           NULL 			    TRX_COMMUNICATED_DATE,
           NVL(poh.currency_code,
               poh.base_currency_code) 	    TRX_CURRENCY_CODE,
           poh.last_update_date 	    TRX_DATE,
           NULL 			    TRX_DESCRIPTION,
           NULL 			    TRX_DUE_DATE,
           poh.po_header_id 	            TRX_ID,
           'SHIPMENT' 			    TRX_LEVEL_TYPE,
           poll.LAST_UPDATE_DATE  	    TRX_LINE_DATE,
           NULL 			    TRX_LINE_DESCRIPTION,
           poll.LAST_UPDATE_DATE 	    TRX_LINE_GL_DATE,
           poll.line_location_id 	    TRX_LINE_ID,
           poll.SHIPMENT_NUM 	            TRX_LINE_NUMBER,
           poll.quantity 		    TRX_LINE_QUANTITY,
           'ITEM' 			    TRX_LINE_TYPE,
           poh.segment1 		    TRX_NUMBER,
           NULL 			    TRX_RECEIPT_DATE,
           NULL 			    TRX_SHIPPING_DATE,
           NULL 			    TRX_TYPE_DESCRIPTION,
           NVL(poll.price_override,
                           pol.unit_price)  UNIT_PRICE,
           NULL 			    UOM_CODE,
           NULL 			    USER_DEFINED_FISC_CLASS,
           'N' 			            USER_UPD_DET_FACTORS_FLAG,
           3			            EVENT_CLASS_MAPPING_ID,
           poll.GLOBAL_ATTRIBUTE_CATEGORY   GLOBAL_ATTRIBUTE_CATEGORY,
           poll.GLOBAL_ATTRIBUTE1 	    GLOBAL_ATTRIBUTE1 	   ,
           NULL                             ICX_SESSION_ID,
           NULL                             TRX_LINE_CURRENCY_CODE,
           NULL                             TRX_LINE_CURRENCY_CONV_RATE,
           NULL                             TRX_LINE_CURRENCY_CONV_DATE,
           NULL                             TRX_LINE_PRECISION,
           NULL                             TRX_LINE_MAU,
           NULL                             TRX_LINE_CURRENCY_CONV_TYPE,
           NULL                             INTERFACE_ENTITY_CODE,
           NULL                             INTERFACE_LINE_ID,
           NULL                             SOURCE_TAX_LINE_ID,
           'Y'                              TAX_CALCULATION_DONE_FLAG,
           pol.line_num                     LINE_TRX_USER_KEY1,
           hr.location_code                 LINE_TRX_USER_KEY2,
           DECODE(poll.payment_type,
                   NULL, 0, 'DELIVERY',
                   1,'ADVANCE', 2, 3)       LINE_TRX_USER_KEY3
      FROM (SELECT /*+ NO_MERGE swap_join_inputs(fsp) swap_join_inputs(aps)
                       swap_join_inputs(oi) index(aps AP_SYSTEM_PARAMETERS_U1) */
                   poh.*,
                   fsp.set_of_books_id,
                   aps.base_currency_code,
                   oi.org_information2 oi_org_information2
       	      FROM (select distinct other_doc_application_id, other_doc_trx_id
       	              from ZX_VALIDATION_ERRORS_GT
       	             where other_doc_application_id = 201
       	               and other_doc_entity_code = 'PURCHASE_ORDER'
       	               and other_doc_event_class_code = 'PO_PA'
       	           ) zxvalerr, --Bug 5187701
       	           po_headers_all poh,
                   financials_system_params_all fsp,
                   ap_system_parameters_all aps,
                   hr_organization_information oi
    	     WHERE poh.po_header_id = zxvalerr.other_doc_trx_id
               AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
               AND aps.set_of_books_id = fsp.set_of_books_id
               AND NVL(aps.org_id, -99) = NVL(poh.org_id, -99)
               AND oi.organization_id(+) = poh.org_id
               AND oi.org_information_context(+) = 'Operating Unit Information'
           ) poh,
           fnd_currencies fc,
           po_lines_all pol,
           po_line_locations_all poll,
           zx_party_tax_profile ptp,
           hr_locations_all hr
     WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
       AND pol.po_header_id = poh.po_header_id
       AND poll.po_header_id = pol.po_header_id
       AND poll.po_line_id = pol.po_line_id
       AND hr.location_id(+) = poll.ship_to_location_id
       AND NOT EXISTS
           (SELECT 1 FROM zx_transaction_lines_gt lines_gt
             WHERE lines_gt.application_id   = 201
               AND lines_gt.event_class_code = 'PO_PA'
               AND lines_gt.entity_code      = 'PURCHASE_ORDER'
               AND lines_gt.trx_id           = poh.po_header_id
               AND lines_gt.trx_line_id      = poll.line_location_id
               AND lines_gt.trx_level_type   = 'SHIPMENT'
               AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
           )
       AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
       AND ptp.party_type_code = 'OU';

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                   'Number of Rows Inserted = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;

  -- COMMIT;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk_po',
                   'Inserting data into zx_lines(Tax Code)');
  END IF;

  -- Insert data into zx_lines
  --

    INSERT INTO ZX_LINES(
                ADJUSTED_DOC_APPLICATION_ID
               ,ADJUSTED_DOC_DATE
               ,ADJUSTED_DOC_ENTITY_CODE
               ,ADJUSTED_DOC_EVENT_CLASS_CODE
               ,ADJUSTED_DOC_LINE_ID
               ,ADJUSTED_DOC_NUMBER
               ,ADJUSTED_DOC_TAX_LINE_ID
               ,ADJUSTED_DOC_TRX_ID
               ,ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,APPLICATION_ID
               ,APPLIED_FROM_APPLICATION_ID
               ,APPLIED_FROM_ENTITY_CODE
               ,APPLIED_FROM_EVENT_CLASS_CODE
               ,APPLIED_FROM_LINE_ID
               ,APPLIED_FROM_TRX_ID
               ,APPLIED_FROM_TRX_LEVEL_TYPE
               ,APPLIED_FROM_TRX_NUMBER
               ,APPLIED_TO_APPLICATION_ID
               ,APPLIED_TO_ENTITY_CODE
               ,APPLIED_TO_EVENT_CLASS_CODE
               ,APPLIED_TO_LINE_ID
               ,APPLIED_TO_TRX_ID
               ,APPLIED_TO_TRX_LEVEL_TYPE
               ,APPLIED_TO_TRX_NUMBER
               ,ASSOCIATED_CHILD_FROZEN_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,BASIS_RESULT_ID
               ,CAL_TAX_AMT
               ,CAL_TAX_AMT_FUNCL_CURR
               ,CAL_TAX_AMT_TAX_CURR
               ,CALC_RESULT_ID
               ,CANCEL_FLAG
               ,CHAR1
               ,CHAR10
               ,CHAR2
               ,CHAR3
               ,CHAR4
               ,CHAR5
               ,CHAR6
               ,CHAR7
               ,CHAR8
               ,CHAR9
               ,COMPOUNDING_DEP_TAX_FLAG
               ,COMPOUNDING_TAX_FLAG
               ,COMPOUNDING_TAX_MISS_FLAG
               ,CONTENT_OWNER_ID
               ,COPIED_FROM_OTHER_DOC_FLAG
               ,CREATED_BY
               ,CREATION_DATE
               ,CTRL_TOTAL_LINE_TX_AMT
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,DATE1
               ,DATE10
               ,DATE2
               ,DATE3
               ,DATE4
               ,DATE5
               ,DATE6
               ,DATE7
               ,DATE8
               ,DATE9
               ,DELETE_FLAG
               ,DIRECT_RATE_RESULT_ID
               ,DOC_EVENT_STATUS
               ,ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,ENTITY_CODE
               ,ESTABLISHMENT_ID
               ,EVAL_EXCPT_RESULT_ID
               ,EVAL_EXMPT_RESULT_ID
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,EXCEPTION_RATE
               ,EXEMPT_CERTIFICATE_NUMBER
               ,EXEMPT_RATE_MODIFIER
               ,EXEMPT_REASON
               ,EXEMPT_REASON_CODE
               ,FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,GLOBAL_ATTRIBUTE_CATEGORY
               ,GLOBAL_ATTRIBUTE1
               ,GLOBAL_ATTRIBUTE10
               ,GLOBAL_ATTRIBUTE11
               ,GLOBAL_ATTRIBUTE12
               ,GLOBAL_ATTRIBUTE13
               ,GLOBAL_ATTRIBUTE14
               ,GLOBAL_ATTRIBUTE15
               ,GLOBAL_ATTRIBUTE2
               ,GLOBAL_ATTRIBUTE3
               ,GLOBAL_ATTRIBUTE4
               ,GLOBAL_ATTRIBUTE5
               ,GLOBAL_ATTRIBUTE6
               ,GLOBAL_ATTRIBUTE7
               ,GLOBAL_ATTRIBUTE8
               ,GLOBAL_ATTRIBUTE9
               ,HISTORICAL_FLAG
               ,HQ_ESTB_PARTY_TAX_PROF_ID
               ,HQ_ESTB_REG_NUMBER
               ,INTERFACE_ENTITY_CODE
               ,INTERFACE_TAX_LINE_ID
               ,INTERNAL_ORG_LOCATION_ID
               ,INTERNAL_ORGANIZATION_ID
               ,ITEM_DIST_CHANGED_FLAG
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,LEDGER_ID
               ,LEGAL_ENTITY_ID
               ,LEGAL_ENTITY_TAX_REG_NUMBER
               ,LEGAL_JUSTIFICATION_TEXT1
               ,LEGAL_JUSTIFICATION_TEXT2
               ,LEGAL_JUSTIFICATION_TEXT3
               ,LEGAL_MESSAGE_APPL_2
               ,LEGAL_MESSAGE_BASIS
               ,LEGAL_MESSAGE_CALC
               ,LEGAL_MESSAGE_EXCPT
               ,LEGAL_MESSAGE_EXMPT
               ,LEGAL_MESSAGE_POS
               ,LEGAL_MESSAGE_RATE
               ,LEGAL_MESSAGE_STATUS
               ,LEGAL_MESSAGE_THRESHOLD
               ,LEGAL_MESSAGE_TRN
               ,LINE_AMT
               ,LINE_ASSESSABLE_VALUE
               ,MANUALLY_ENTERED_FLAG
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,MRC_LINK_TO_TAX_LINE_ID
               ,MRC_TAX_LINE_FLAG
               ,NREC_TAX_AMT
               ,NREC_TAX_AMT_FUNCL_CURR
               ,NREC_TAX_AMT_TAX_CURR
               ,NUMERIC1
               ,NUMERIC10
               ,NUMERIC2
               ,NUMERIC3
               ,NUMERIC4
               ,NUMERIC5
               ,NUMERIC6
               ,NUMERIC7
               ,NUMERIC8
               ,NUMERIC9
               ,OBJECT_VERSION_NUMBER
               ,OFFSET_FLAG
               ,OFFSET_LINK_TO_TAX_LINE_ID
               ,OFFSET_TAX_RATE_CODE
               ,ORIG_SELF_ASSESSED_FLAG
               ,ORIG_TAX_AMT
               ,ORIG_TAX_AMT_INCLUDED_FLAG
               ,ORIG_TAX_AMT_TAX_CURR
               ,ORIG_TAX_JURISDICTION_CODE
               ,ORIG_TAX_JURISDICTION_ID
               ,ORIG_TAX_RATE
               ,ORIG_TAX_RATE_CODE
               ,ORIG_TAX_RATE_ID
               ,ORIG_TAX_STATUS_CODE
               ,ORIG_TAX_STATUS_ID
               ,ORIG_TAXABLE_AMT
               ,ORIG_TAXABLE_AMT_TAX_CURR
               ,OTHER_DOC_LINE_AMT
               ,OTHER_DOC_LINE_TAX_AMT
               ,OTHER_DOC_LINE_TAXABLE_AMT
               ,OTHER_DOC_SOURCE
               ,OVERRIDDEN_FLAG
               ,PLACE_OF_SUPPLY
               ,PLACE_OF_SUPPLY_RESULT_ID
               ,PLACE_OF_SUPPLY_TYPE_CODE
               ,PRD_TOTAL_TAX_AMT
               ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,PRD_TOTAL_TAX_AMT_TAX_CURR
               ,PRECISION
               ,PROCESS_FOR_RECOVERY_FLAG
               ,PRORATION_CODE
               ,PURGE_FLAG
               ,RATE_RESULT_ID
               ,REC_TAX_AMT
               ,REC_TAX_AMT_FUNCL_CURR
               ,REC_TAX_AMT_TAX_CURR
               ,RECALC_REQUIRED_FLAG
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_LINE_QUANTITY
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,REGISTRATION_PARTY_TYPE
               ,RELATED_DOC_APPLICATION_ID
               ,RELATED_DOC_DATE
               ,RELATED_DOC_ENTITY_CODE
               ,RELATED_DOC_EVENT_CLASS_CODE
               ,RELATED_DOC_NUMBER
               ,RELATED_DOC_TRX_ID
               ,RELATED_DOC_TRX_LEVEL_TYPE
               ,REPORTING_CURRENCY_CODE
               ,REPORTING_ONLY_FLAG
               ,REPORTING_PERIOD_ID
               ,ROUNDING_LEVEL_CODE
               ,ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,ROUNDING_LVL_PARTY_TYPE
               ,ROUNDING_RULE_CODE
               ,SELF_ASSESSED_FLAG
               ,SETTLEMENT_FLAG
               ,STATUS_RESULT_ID
               ,SUMMARY_TAX_LINE_ID
               ,SYNC_WITH_PRVDR_FLAG
               ,TAX
               ,TAX_AMT
               ,TAX_AMT_FUNCL_CURR
               ,TAX_AMT_INCLUDED_FLAG
               ,TAX_AMT_TAX_CURR
               ,TAX_APPLICABILITY_RESULT_ID
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_BASE_MODIFIER_RATE
               ,TAX_CALCULATION_FORMULA
               ,TAX_CODE
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_DATE
               ,TAX_DATE_RULE_ID
               ,TAX_DETERMINE_DATE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_EXCEPTION_ID
               ,TAX_EXEMPTION_ID
               ,TAX_HOLD_CODE
               ,TAX_HOLD_RELEASED_CODE
               ,TAX_ID
               ,TAX_JURISDICTION_CODE
               ,TAX_JURISDICTION_ID
               ,TAX_LINE_ID
               ,TAX_LINE_NUMBER
               ,TAX_ONLY_LINE_FLAG
               ,TAX_POINT_DATE
               ,TAX_PROVIDER_ID
               ,TAX_RATE
               ,TAX_RATE_BEFORE_EXCEPTION
               ,TAX_RATE_BEFORE_EXEMPTION
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_RATE_NAME_BEFORE_EXCEPTION
               ,TAX_RATE_NAME_BEFORE_EXEMPTION
               ,TAX_RATE_TYPE
               ,TAX_REG_NUM_DET_RESULT_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_REGIME_TEMPLATE_ID
               ,TAX_REGISTRATION_ID
               ,TAX_REGISTRATION_NUMBER
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TAX_TYPE_CODE
               ,TAXABLE_AMT
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TAXABLE_BASIS_FORMULA
               ,TAXING_JURIS_GEOGRAPHY_ID
               ,THRESH_RESULT_ID
               ,TRX_CURRENCY_CODE
               ,TRX_DATE
               ,TRX_ID
               ,TRX_ID_LEVEL2
               ,TRX_ID_LEVEL3
               ,TRX_ID_LEVEL4
               ,TRX_ID_LEVEL5
               ,TRX_ID_LEVEL6
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_DATE
               ,TRX_LINE_ID
               ,TRX_LINE_INDEX
               ,TRX_LINE_NUMBER
               ,TRX_LINE_QUANTITY
               ,TRX_NUMBER
               ,TRX_USER_KEY_LEVEL1
               ,TRX_USER_KEY_LEVEL2
               ,TRX_USER_KEY_LEVEL3
               ,TRX_USER_KEY_LEVEL4
               ,TRX_USER_KEY_LEVEL5
               ,TRX_USER_KEY_LEVEL6
               ,UNIT_PRICE
               ,UNROUNDED_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,MULTIPLE_JURISDICTIONS_FLAG)
        SELECT /*+ leading(poh) NO_EXPAND
                   use_nl(fc,pol,poll,ptp,atc,rates,regimes,taxes,status) */
                NULL 	                           ADJUSTED_DOC_APPLICATION_ID
               ,NULL 	                           ADJUSTED_DOC_DATE
               ,NULL	                           ADJUSTED_DOC_ENTITY_CODE
               ,NULL                               ADJUSTED_DOC_EVENT_CLASS_CODE
               ,NULL                               ADJUSTED_DOC_LINE_ID
               ,NULL                               ADJUSTED_DOC_NUMBER
               ,NULL                               ADJUSTED_DOC_TAX_LINE_ID
               ,NULL                               ADJUSTED_DOC_TRX_ID
               ,NULL                               ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,201	                           APPLICATION_ID
               ,NULL                               APPLIED_FROM_APPLICATION_ID
               ,NULL                               APPLIED_FROM_ENTITY_CODE
               ,NULL                               APPLIED_FROM_EVENT_CLASS_CODE
               ,NULL                               APPLIED_FROM_LINE_ID
               ,NULL                               APPLIED_FROM_TRX_ID
               ,NULL                               APPLIED_FROM_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_FROM_TRX_NUMBER
               ,NULL	                           APPLIED_TO_APPLICATION_ID
               ,NULL	                           APPLIED_TO_ENTITY_CODE
               ,NULL	                           APPLIED_TO_EVENT_CLASS_CODE
               ,NULL	                           APPLIED_TO_LINE_ID
               ,NULL	                           APPLIED_TO_TRX_ID
               ,NULL	                           APPLIED_TO_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_TO_TRX_NUMBER
               ,'N' 	                           ASSOCIATED_CHILD_FROZEN_FLAG
               ,poll.ATTRIBUTE_CATEGORY            ATTRIBUTE_CATEGORY
               ,poll.ATTRIBUTE1 	           ATTRIBUTE1
               ,poll.ATTRIBUTE10	           ATTRIBUTE10
               ,poll.ATTRIBUTE11	           ATTRIBUTE11
               ,poll.ATTRIBUTE12	           ATTRIBUTE12
               ,poll.ATTRIBUTE13	           ATTRIBUTE13
               ,poll.ATTRIBUTE14	           ATTRIBUTE14
               ,poll.ATTRIBUTE15	           ATTRIBUTE15
               ,poll.ATTRIBUTE2 	           ATTRIBUTE2
               ,poll.ATTRIBUTE3 	           ATTRIBUTE3
               ,poll.ATTRIBUTE4 	           ATTRIBUTE4
               ,poll.ATTRIBUTE5 	           ATTRIBUTE5
               ,poll.ATTRIBUTE6 	           ATTRIBUTE6
               ,poll.ATTRIBUTE7 	           ATTRIBUTE7
               ,poll.ATTRIBUTE8 	           ATTRIBUTE8
               ,poll.ATTRIBUTE9 	           ATTRIBUTE9
               ,NULL			           BASIS_RESULT_ID
               ,NULL	                           CAL_TAX_AMT
               ,NULL	                           CAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           CAL_TAX_AMT_TAX_CURR
               ,NULL	                           CALC_RESULT_ID
               ,'N'	                           CANCEL_FLAG
               ,NULL	                           CHAR1
               ,NULL	                           CHAR10
               ,NULL	                           CHAR2
               ,NULL	                           CHAR3
               ,NULL	                           CHAR4
               ,NULL	                           CHAR5
               ,NULL	                           CHAR6
               ,NULL	                           CHAR7
               ,NULL	                           CHAR8
               ,NULL	                           CHAR9
               ,'N'	                           COMPOUNDING_DEP_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_MISS_FLAG
               ,ptp.party_tax_profile_id	   CONTENT_OWNER_ID
               ,'N'	                           COPIED_FROM_OTHER_DOC_FLAG
               ,1	                           CREATED_BY
               ,SYSDATE                            CREATION_DATE
               ,NULL		                   CTRL_TOTAL_LINE_TX_AMT
               ,poh.rate_date 	                   CURRENCY_CONVERSION_DATE
               ,poh.rate 	                   CURRENCY_CONVERSION_RATE
               ,poh.rate_type 	                   CURRENCY_CONVERSION_TYPE
               ,NULL	                           DATE1
               ,NULL	                           DATE10
               ,NULL	                           DATE2
               ,NULL	                           DATE3
               ,NULL	                           DATE4
               ,NULL	                           DATE5
               ,NULL	                           DATE6
               ,NULL	                           DATE7
               ,NULL	                           DATE8
               ,NULL	                           DATE9
               ,'N'	                           DELETE_FLAG
               ,NULL	                           DIRECT_RATE_RESULT_ID
               ,NULL	                           DOC_EVENT_STATUS
               ,'N'	                           ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,'PURCHASE_ORDER' 	           ENTITY_CODE
               ,NULL	                           ESTABLISHMENT_ID
               ,NULL	                           EVAL_EXCPT_RESULT_ID
               ,NULL	                           EVAL_EXMPT_RESULT_ID
               ,'PO_PA' 		           EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	   EVENT_TYPE_CODE
               ,NULL                               EXCEPTION_RATE
               ,NULL	                           EXEMPT_CERTIFICATE_NUMBER
               ,NULL	                           EXEMPT_RATE_MODIFIER
               ,NULL	                           EXEMPT_REASON
               ,NULL	                           EXEMPT_REASON_CODE
               ,'N'	                           FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,poll.GLOBAL_ATTRIBUTE_CATEGORY     GLOBAL_ATTRIBUTE_CATEGORY
               ,poll.GLOBAL_ATTRIBUTE1 	           GLOBAL_ATTRIBUTE1
               ,poll.GLOBAL_ATTRIBUTE10	           GLOBAL_ATTRIBUTE10
               ,poll.GLOBAL_ATTRIBUTE11	           GLOBAL_ATTRIBUTE11
               ,poll.GLOBAL_ATTRIBUTE12	           GLOBAL_ATTRIBUTE12
               ,poll.GLOBAL_ATTRIBUTE13	           GLOBAL_ATTRIBUTE13
               ,poll.GLOBAL_ATTRIBUTE14	           GLOBAL_ATTRIBUTE14
               ,poll.GLOBAL_ATTRIBUTE15	           GLOBAL_ATTRIBUTE15
               ,poll.GLOBAL_ATTRIBUTE2             GLOBAL_ATTRIBUTE2
               ,poll.GLOBAL_ATTRIBUTE3             GLOBAL_ATTRIBUTE3
               ,poll.GLOBAL_ATTRIBUTE4             GLOBAL_ATTRIBUTE4
               ,poll.GLOBAL_ATTRIBUTE5             GLOBAL_ATTRIBUTE5
               ,poll.GLOBAL_ATTRIBUTE6             GLOBAL_ATTRIBUTE6
               ,poll.GLOBAL_ATTRIBUTE7             GLOBAL_ATTRIBUTE7
               ,poll.GLOBAL_ATTRIBUTE8             GLOBAL_ATTRIBUTE8
               ,poll.GLOBAL_ATTRIBUTE9             GLOBAL_ATTRIBUTE9
               ,'Y'	                           HISTORICAL_FLAG
               ,NULL                               HQ_ESTB_PARTY_TAX_PROF_ID
               ,NULL	                           HQ_ESTB_REG_NUMBER
               ,NULL	                           INTERFACE_ENTITY_CODE
               ,NULL	                           INTERFACE_TAX_LINE_ID
               ,NULL                               INTERNAL_ORG_LOCATION_ID
               ,nvl(poh.org_id,-99)                INTERNAL_ORGANIZATION_ID
               ,'N'                                ITEM_DIST_CHANGED_FLAG
               ,NULL	                           LAST_MANUAL_ENTRY
               ,SYSDATE	                           LAST_UPDATE_DATE
               ,1	                           LAST_UPDATE_LOGIN
               ,1	                           LAST_UPDATED_BY
               ,poh.set_of_books_id 	           LEDGER_ID
               ,NVL(poh.oi_org_information2, -99)  LEGAL_ENTITY_ID
               ,NULL                               LEGAL_ENTITY_TAX_REG_NUMBER
               ,NULL                               LEGAL_JUSTIFICATION_TEXT1
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT2
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT3
               ,NULL                               LEGAL_MESSAGE_APPL_2
               ,NULL	                           LEGAL_MESSAGE_BASIS
               ,NULL	                           LEGAL_MESSAGE_CALC
               ,NULL	                           LEGAL_MESSAGE_EXCPT
               ,NULL	                           LEGAL_MESSAGE_EXMPT
               ,NULL	                           LEGAL_MESSAGE_POS
               ,NULL	                           LEGAL_MESSAGE_RATE
               ,NULL                               LEGAL_MESSAGE_STATUS
               ,NULL	                           LEGAL_MESSAGE_THRESHOLD
               ,NULL	                           LEGAL_MESSAGE_TRN
               ,DECODE(pol.purchase_basis,
                 'TEMP LABOR', NVL(POLL.amount,0),
                 'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                    NVL(poll.quantity,0) *
                                    NVL(poll.price_override,NVL(pol.unit_price,0))),
                  NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                                   LINE_AMT
               ,NULL	                           LINE_ASSESSABLE_VALUE
               ,'N'	                           MANUALLY_ENTERED_FLAG
               ,fc.minimum_accountable_unit	   MINIMUM_ACCOUNTABLE_UNIT
               ,NULL	                           MRC_LINK_TO_TAX_LINE_ID
               ,'N'	                           MRC_TAX_LINE_FLAG
               ,NULL	                           NREC_TAX_AMT
               ,NULL	                           NREC_TAX_AMT_FUNCL_CURR
               ,NULL	                           NREC_TAX_AMT_TAX_CURR
               ,NULL	                           NUMERIC1
               ,NULL	                           NUMERIC10
               ,NULL	                           NUMERIC2
               ,NULL	                           NUMERIC3
               ,NULL	                           NUMERIC4
               ,NULL	                           NUMERIC5
               ,NULL	                           NUMERIC6
               ,NULL	                           NUMERIC7
               ,NULL	                           NUMERIC8
               ,NULL	                           NUMERIC9
               ,1	                           OBJECT_VERSION_NUMBER
               ,'N'	                           OFFSET_FLAG
               ,NULL	                           OFFSET_LINK_TO_TAX_LINE_ID
               ,NULL	                           OFFSET_TAX_RATE_CODE
               ,'N'	                           ORIG_SELF_ASSESSED_FLAG
               ,NULL	                           ORIG_TAX_AMT
               ,NULL	                           ORIG_TAX_AMT_INCLUDED_FLAG
               ,NULL	                           ORIG_TAX_AMT_TAX_CURR
               ,NULL	                           ORIG_TAX_JURISDICTION_CODE
               ,NULL	                           ORIG_TAX_JURISDICTION_ID
               ,NULL	                           ORIG_TAX_RATE
               ,NULL	                           ORIG_TAX_RATE_CODE
               ,NULL	                           ORIG_TAX_RATE_ID
               ,NULL	                           ORIG_TAX_STATUS_CODE
               ,NULL	                           ORIG_TAX_STATUS_ID
               ,NULL	                           ORIG_TAXABLE_AMT
               ,NULL	                           ORIG_TAXABLE_AMT_TAX_CURR
               ,NULL	                           OTHER_DOC_LINE_AMT
               ,NULL	                           OTHER_DOC_LINE_TAX_AMT
               ,NULL	                           OTHER_DOC_LINE_TAXABLE_AMT
               ,NULL	                           OTHER_DOC_SOURCE
               ,'N'	                           OVERRIDDEN_FLAG
               ,NULL	                           PLACE_OF_SUPPLY
               ,NULL	                           PLACE_OF_SUPPLY_RESULT_ID
               ,NULL                               PLACE_OF_SUPPLY_TYPE_CODE
               ,NULL	                           PRD_TOTAL_TAX_AMT
               ,NULL	                           PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           PRD_TOTAL_TAX_AMT_TAX_CURR
               ,NVL(fc.precision, 0)               PRECISION
               ,'N'	                           PROCESS_FOR_RECOVERY_FLAG
               ,NULL	                           PRORATION_CODE
               ,'N'	                           PURGE_FLAG
               ,NULL	                           RATE_RESULT_ID
               ,NULL	                           REC_TAX_AMT
               ,NULL	                           REC_TAX_AMT_FUNCL_CURR
               ,NULL	                           REC_TAX_AMT_TAX_CURR
               ,'N'	                           RECALC_REQUIRED_FLAG
               ,'MIGRATED'                         RECORD_TYPE_CODE
               ,NULL	                           REF_DOC_APPLICATION_ID
               ,NULL	                           REF_DOC_ENTITY_CODE
               ,NULL	                           REF_DOC_EVENT_CLASS_CODE
               ,NULL	                           REF_DOC_LINE_ID
               ,NULL	                           REF_DOC_LINE_QUANTITY
               ,NULL	                           REF_DOC_TRX_ID
               ,NULL	                           REF_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REGISTRATION_PARTY_TYPE
               ,NULL	                           RELATED_DOC_APPLICATION_ID
               ,NULL	                           RELATED_DOC_DATE
               ,NULL	                           RELATED_DOC_ENTITY_CODE
               ,NULL	                           RELATED_DOC_EVENT_CLASS_CODE
               ,NULL	                           RELATED_DOC_NUMBER
               ,NULL	                           RELATED_DOC_TRX_ID
               ,NULL	                           RELATED_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REPORTING_CURRENCY_CODE
               ,'N'	                           REPORTING_ONLY_FLAG
               ,NULL	                           REPORTING_PERIOD_ID
               ,NULL	                           ROUNDING_LEVEL_CODE
               ,NULL	                           ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,NULL	                           ROUNDING_LVL_PARTY_TYPE
               ,NULL	                           ROUNDING_RULE_CODE
               ,'N'	                           SELF_ASSESSED_FLAG
               ,'N'                                SETTLEMENT_FLAG
               ,NULL                               STATUS_RESULT_ID
               ,NULL                               SUMMARY_TAX_LINE_ID
               ,NULL                               SYNC_WITH_PRVDR_FLAG
               ,rates.tax                          TAX
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)  TAX_AMT
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)
                                                   TAX_AMT_FUNCL_CURR
               ,'N'                                TAX_AMT_INCLUDED_FLAG
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit) TAX_AMT_TAX_CURR
               ,NULL                               TAX_APPLICABILITY_RESULT_ID
               ,'Y'                                TAX_APPORTIONMENT_FLAG
               ,1                                  TAX_APPORTIONMENT_LINE_NUMBER
               ,NULL                               TAX_BASE_MODIFIER_RATE
               ,'STANDARD_TC'                      TAX_CALCULATION_FORMULA
               ,NULL                               TAX_CODE
               ,taxes.tax_currency_code            TAX_CURRENCY_CODE
               ,poh.rate_date 		           TAX_CURRENCY_CONVERSION_DATE
               ,poh.rate 		           TAX_CURRENCY_CONVERSION_RATE
               ,poh.rate_type 		           TAX_CURRENCY_CONVERSION_TYPE
               ,poll.last_update_date              TAX_DATE
               ,NULL                               TAX_DATE_RULE_ID
               ,poll.last_update_date              TAX_DETERMINE_DATE
               ,'PURCHASE_TRANSACTION' 	           TAX_EVENT_CLASS_CODE
               ,'VALIDATE'  		           TAX_EVENT_TYPE_CODE
               ,NULL                               TAX_EXCEPTION_ID
               ,NULL                               TAX_EXEMPTION_ID
               ,NULL                               TAX_HOLD_CODE
               ,NULL                               TAX_HOLD_RELEASED_CODE
               ,taxes.tax_id                       TAX_ID
               ,NULL                               TAX_JURISDICTION_CODE
               ,NULL                               TAX_JURISDICTION_ID
               ,zx_lines_s.nextval                 TAX_LINE_ID
               ,RANK() OVER
                (PARTITION BY poh.po_header_id
                  ORDER BY poll.line_location_id,
                              atc.tax_id)         TAX_LINE_NUMBER
               ,'N'                               TAX_ONLY_LINE_FLAG
               ,poll.last_update_date             TAX_POINT_DATE
               ,NULL                              TAX_PROVIDER_ID
               ,rates.percentage_rate  	          TAX_RATE
               ,NULL	                          TAX_RATE_BEFORE_EXCEPTION
               ,NULL                              TAX_RATE_BEFORE_EXEMPTION
               ,rates.tax_rate_code               TAX_RATE_CODE
               ,rates.tax_rate_id                 TAX_RATE_ID
               ,NULL                              TAX_RATE_NAME_BEFORE_EXCEPTION
               ,NULL                              TAX_RATE_NAME_BEFORE_EXEMPTION
               ,NULL                              TAX_RATE_TYPE
               ,NULL                              TAX_REG_NUM_DET_RESULT_ID
               ,rates.tax_regime_code             TAX_REGIME_CODE
               ,regimes.tax_regime_id             TAX_REGIME_ID
               ,NULL                              TAX_REGIME_TEMPLATE_ID
               ,NULL                              TAX_REGISTRATION_ID
               ,NULL                              TAX_REGISTRATION_NUMBER
               ,rates.tax_status_code             TAX_STATUS_CODE
               ,status.tax_status_id              TAX_STATUS_ID
               ,NULL                              TAX_TYPE_CODE
               ,NULL                              TAXABLE_AMT
               ,NULL                              TAXABLE_AMT_FUNCL_CURR
               ,NULL                              TAXABLE_AMT_TAX_CURR
               ,'STANDARD_TB'                     TAXABLE_BASIS_FORMULA
               ,NULL                              TAXING_JURIS_GEOGRAPHY_ID
               ,NULL                              THRESH_RESULT_ID
               ,NVL(poh.currency_code,
                    poh.base_currency_code)       TRX_CURRENCY_CODE
               ,poh.last_update_date              TRX_DATE
               ,poh.po_header_id                  TRX_ID
               ,NULL                              TRX_ID_LEVEL2
               ,NULL                              TRX_ID_LEVEL3
               ,NULL                              TRX_ID_LEVEL4
               ,NULL                              TRX_ID_LEVEL5
               ,NULL                              TRX_ID_LEVEL6
               ,'SHIPMENT'                        TRX_LEVEL_TYPE
               ,poll.LAST_UPDATE_DATE             TRX_LINE_DATE
               ,poll.line_location_id             TRX_LINE_ID
               ,NULL                              TRX_LINE_INDEX
               ,poll.SHIPMENT_NUM                 TRX_LINE_NUMBER
               ,poll.quantity 		          TRX_LINE_QUANTITY
               ,poh.segment1                      TRX_NUMBER
               ,NULL                              TRX_USER_KEY_LEVEL1
               ,NULL                              TRX_USER_KEY_LEVEL2
               ,NULL                              TRX_USER_KEY_LEVEL3
               ,NULL                              TRX_USER_KEY_LEVEL4
               ,NULL                              TRX_USER_KEY_LEVEL5
               ,NULL                              TRX_USER_KEY_LEVEL6
               ,NVL(poll.price_override,
                     pol.unit_price)              UNIT_PRICE
               ,NULL                              UNROUNDED_TAX_AMT
               ,NULL                              UNROUNDED_TAXABLE_AMT
               ,'N'                               MULTIPLE_JURISDICTIONS_FLAG
         FROM (SELECT /*+ NO_MERGE NO_EXPAND use_hash(fsp) use_hash(aps) use_hash(oi)
                      swap_join_inputs(fsp) swap_join_inputs(aps)
                      swap_join_inputs(oi) */
   	              poh.* , fsp.org_id fsp_org_id, fsp.set_of_books_id,
   	              aps.base_currency_code, oi.org_information2 oi_org_information2
                 FROM (select distinct other_doc_application_id, other_doc_trx_id
   	                 from ZX_VALIDATION_ERRORS_GT
   	                where other_doc_application_id = 201
   	                  and other_doc_entity_code = 'PURCHASE_ORDER'
   	                  and other_doc_event_class_code = 'PO_PA'
   	              ) zxvalerr, --Bug 5187701
                      po_headers_all poh,
   	              financials_system_params_all fsp,
	              ap_system_parameters_all aps,
	              hr_organization_information oi
                WHERE poh.po_header_id = zxvalerr.other_doc_trx_id
                  AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                  AND NVL(aps.org_id, -99) = NVL(poh.org_id,-99)
                  AND aps.set_of_books_id = fsp.set_of_books_id
                  AND oi.organization_id(+) = poh.org_id
                  AND oi.org_information_context(+) = 'Operating Unit Information'
              ) poh,
              fnd_currencies fc,
              po_lines_all pol,
              po_line_locations_all poll,
              zx_party_tax_profile ptp,
              ap_tax_codes_all atc,
              zx_rates_b rates,
              zx_regimes_b regimes,
              zx_taxes_b taxes,
              zx_status_b status
        WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
          AND poh.po_header_id = pol.po_header_id
          AND pol.po_header_id = poll.po_header_id
          AND pol.po_line_id = poll.po_line_id
          AND NOT EXISTS
              (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                 WHERE lines_gt.application_id   = 201
                   AND lines_gt.event_class_code = 'PO_PA'
                   AND lines_gt.entity_code      = 'PURCHASE_ORDER'
                   AND lines_gt.trx_id           = poh.po_header_id
                   AND lines_gt.trx_line_id      = poll.line_location_id
                   AND lines_gt.trx_level_type   = 'SHIPMENT'
                   AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
              )
          AND nvl(atc.org_id,-99)=nvl(poh.fsp_org_id,-99)
          AND poll.tax_code_id = atc.tax_id
          AND atc.tax_type NOT IN ('TAX_GROUP','USE')
          AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
          AND ptp.party_type_code = 'OU'
          AND rates.source_id = atc.tax_id
          AND regimes.tax_regime_code(+) = rates.tax_regime_code
          AND taxes.tax_regime_code(+) = rates.tax_regime_code
          AND taxes.tax(+) = rates.tax
          AND taxes.content_owner_id(+) = rates.content_owner_id
          AND status.tax_regime_code(+) = rates.tax_regime_code
          AND status.tax(+) = rates.tax
          AND status.content_owner_id(+) = rates.content_owner_id
          AND status.tax_status_code(+) = rates.tax_status_code;


  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                   'ZX_LINES Number of Rows Inserted(Tax Code) = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk_po',
                   'Inserting data into zx_lines(Tax Group)');
  END IF;

  -- Insert data into zx_lines
  --

    INSERT INTO ZX_LINES(
                ADJUSTED_DOC_APPLICATION_ID
               ,ADJUSTED_DOC_DATE
               ,ADJUSTED_DOC_ENTITY_CODE
               ,ADJUSTED_DOC_EVENT_CLASS_CODE
               ,ADJUSTED_DOC_LINE_ID
               ,ADJUSTED_DOC_NUMBER
               ,ADJUSTED_DOC_TAX_LINE_ID
               ,ADJUSTED_DOC_TRX_ID
               ,ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,APPLICATION_ID
               ,APPLIED_FROM_APPLICATION_ID
               ,APPLIED_FROM_ENTITY_CODE
               ,APPLIED_FROM_EVENT_CLASS_CODE
               ,APPLIED_FROM_LINE_ID
               ,APPLIED_FROM_TRX_ID
               ,APPLIED_FROM_TRX_LEVEL_TYPE
               ,APPLIED_FROM_TRX_NUMBER
               ,APPLIED_TO_APPLICATION_ID
               ,APPLIED_TO_ENTITY_CODE
               ,APPLIED_TO_EVENT_CLASS_CODE
               ,APPLIED_TO_LINE_ID
               ,APPLIED_TO_TRX_ID
               ,APPLIED_TO_TRX_LEVEL_TYPE
               ,APPLIED_TO_TRX_NUMBER
               ,ASSOCIATED_CHILD_FROZEN_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,BASIS_RESULT_ID
               ,CAL_TAX_AMT
               ,CAL_TAX_AMT_FUNCL_CURR
               ,CAL_TAX_AMT_TAX_CURR
               ,CALC_RESULT_ID
               ,CANCEL_FLAG
               ,CHAR1
               ,CHAR10
               ,CHAR2
               ,CHAR3
               ,CHAR4
               ,CHAR5
               ,CHAR6
               ,CHAR7
               ,CHAR8
               ,CHAR9
               ,COMPOUNDING_DEP_TAX_FLAG
               ,COMPOUNDING_TAX_FLAG
               ,COMPOUNDING_TAX_MISS_FLAG
               ,CONTENT_OWNER_ID
               ,COPIED_FROM_OTHER_DOC_FLAG
               ,CREATED_BY
               ,CREATION_DATE
               ,CTRL_TOTAL_LINE_TX_AMT
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,DATE1
               ,DATE10
               ,DATE2
               ,DATE3
               ,DATE4
               ,DATE5
               ,DATE6
               ,DATE7
               ,DATE8
               ,DATE9
               ,DELETE_FLAG
               ,DIRECT_RATE_RESULT_ID
               ,DOC_EVENT_STATUS
               ,ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,ENTITY_CODE
               ,ESTABLISHMENT_ID
               ,EVAL_EXCPT_RESULT_ID
               ,EVAL_EXMPT_RESULT_ID
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,EXCEPTION_RATE
               ,EXEMPT_CERTIFICATE_NUMBER
               ,EXEMPT_RATE_MODIFIER
               ,EXEMPT_REASON
               ,EXEMPT_REASON_CODE
               ,FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,GLOBAL_ATTRIBUTE_CATEGORY
               ,GLOBAL_ATTRIBUTE1
               ,GLOBAL_ATTRIBUTE10
               ,GLOBAL_ATTRIBUTE11
               ,GLOBAL_ATTRIBUTE12
               ,GLOBAL_ATTRIBUTE13
               ,GLOBAL_ATTRIBUTE14
               ,GLOBAL_ATTRIBUTE15
               ,GLOBAL_ATTRIBUTE2
               ,GLOBAL_ATTRIBUTE3
               ,GLOBAL_ATTRIBUTE4
               ,GLOBAL_ATTRIBUTE5
               ,GLOBAL_ATTRIBUTE6
               ,GLOBAL_ATTRIBUTE7
               ,GLOBAL_ATTRIBUTE8
               ,GLOBAL_ATTRIBUTE9
               ,HISTORICAL_FLAG
               ,HQ_ESTB_PARTY_TAX_PROF_ID
               ,HQ_ESTB_REG_NUMBER
               ,INTERFACE_ENTITY_CODE
               ,INTERFACE_TAX_LINE_ID
               ,INTERNAL_ORG_LOCATION_ID
               ,INTERNAL_ORGANIZATION_ID
               ,ITEM_DIST_CHANGED_FLAG
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,LEDGER_ID
               ,LEGAL_ENTITY_ID
               ,LEGAL_ENTITY_TAX_REG_NUMBER
               ,LEGAL_JUSTIFICATION_TEXT1
               ,LEGAL_JUSTIFICATION_TEXT2
               ,LEGAL_JUSTIFICATION_TEXT3
               ,LEGAL_MESSAGE_APPL_2
               ,LEGAL_MESSAGE_BASIS
               ,LEGAL_MESSAGE_CALC
               ,LEGAL_MESSAGE_EXCPT
               ,LEGAL_MESSAGE_EXMPT
               ,LEGAL_MESSAGE_POS
               ,LEGAL_MESSAGE_RATE
               ,LEGAL_MESSAGE_STATUS
               ,LEGAL_MESSAGE_THRESHOLD
               ,LEGAL_MESSAGE_TRN
               ,LINE_AMT
               ,LINE_ASSESSABLE_VALUE
               ,MANUALLY_ENTERED_FLAG
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,MRC_LINK_TO_TAX_LINE_ID
               ,MRC_TAX_LINE_FLAG
               ,NREC_TAX_AMT
               ,NREC_TAX_AMT_FUNCL_CURR
               ,NREC_TAX_AMT_TAX_CURR
               ,NUMERIC1
               ,NUMERIC10
               ,NUMERIC2
               ,NUMERIC3
               ,NUMERIC4
               ,NUMERIC5
               ,NUMERIC6
               ,NUMERIC7
               ,NUMERIC8
               ,NUMERIC9
               ,OBJECT_VERSION_NUMBER
               ,OFFSET_FLAG
               ,OFFSET_LINK_TO_TAX_LINE_ID
               ,OFFSET_TAX_RATE_CODE
               ,ORIG_SELF_ASSESSED_FLAG
               ,ORIG_TAX_AMT
               ,ORIG_TAX_AMT_INCLUDED_FLAG
               ,ORIG_TAX_AMT_TAX_CURR
               ,ORIG_TAX_JURISDICTION_CODE
               ,ORIG_TAX_JURISDICTION_ID
               ,ORIG_TAX_RATE
               ,ORIG_TAX_RATE_CODE
               ,ORIG_TAX_RATE_ID
               ,ORIG_TAX_STATUS_CODE
               ,ORIG_TAX_STATUS_ID
               ,ORIG_TAXABLE_AMT
               ,ORIG_TAXABLE_AMT_TAX_CURR
               ,OTHER_DOC_LINE_AMT
               ,OTHER_DOC_LINE_TAX_AMT
               ,OTHER_DOC_LINE_TAXABLE_AMT
               ,OTHER_DOC_SOURCE
               ,OVERRIDDEN_FLAG
               ,PLACE_OF_SUPPLY
               ,PLACE_OF_SUPPLY_RESULT_ID
               ,PLACE_OF_SUPPLY_TYPE_CODE
               ,PRD_TOTAL_TAX_AMT
               ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,PRD_TOTAL_TAX_AMT_TAX_CURR
               ,PRECISION
               ,PROCESS_FOR_RECOVERY_FLAG
               ,PRORATION_CODE
               ,PURGE_FLAG
               ,RATE_RESULT_ID
               ,REC_TAX_AMT
               ,REC_TAX_AMT_FUNCL_CURR
               ,REC_TAX_AMT_TAX_CURR
               ,RECALC_REQUIRED_FLAG
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_LINE_QUANTITY
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,REGISTRATION_PARTY_TYPE
               ,RELATED_DOC_APPLICATION_ID
               ,RELATED_DOC_DATE
               ,RELATED_DOC_ENTITY_CODE
               ,RELATED_DOC_EVENT_CLASS_CODE
               ,RELATED_DOC_NUMBER
               ,RELATED_DOC_TRX_ID
               ,RELATED_DOC_TRX_LEVEL_TYPE
               ,REPORTING_CURRENCY_CODE
               ,REPORTING_ONLY_FLAG
               ,REPORTING_PERIOD_ID
               ,ROUNDING_LEVEL_CODE
               ,ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,ROUNDING_LVL_PARTY_TYPE
               ,ROUNDING_RULE_CODE
               ,SELF_ASSESSED_FLAG
               ,SETTLEMENT_FLAG
               ,STATUS_RESULT_ID
               ,SUMMARY_TAX_LINE_ID
               ,SYNC_WITH_PRVDR_FLAG
               ,TAX
               ,TAX_AMT
               ,TAX_AMT_FUNCL_CURR
               ,TAX_AMT_INCLUDED_FLAG
               ,TAX_AMT_TAX_CURR
               ,TAX_APPLICABILITY_RESULT_ID
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_BASE_MODIFIER_RATE
               ,TAX_CALCULATION_FORMULA
               ,TAX_CODE
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_DATE
               ,TAX_DATE_RULE_ID
               ,TAX_DETERMINE_DATE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_EXCEPTION_ID
               ,TAX_EXEMPTION_ID
               ,TAX_HOLD_CODE
               ,TAX_HOLD_RELEASED_CODE
               ,TAX_ID
               ,TAX_JURISDICTION_CODE
               ,TAX_JURISDICTION_ID
               ,TAX_LINE_ID
               ,TAX_LINE_NUMBER
               ,TAX_ONLY_LINE_FLAG
               ,TAX_POINT_DATE
               ,TAX_PROVIDER_ID
               ,TAX_RATE
               ,TAX_RATE_BEFORE_EXCEPTION
               ,TAX_RATE_BEFORE_EXEMPTION
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_RATE_NAME_BEFORE_EXCEPTION
               ,TAX_RATE_NAME_BEFORE_EXEMPTION
               ,TAX_RATE_TYPE
               ,TAX_REG_NUM_DET_RESULT_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_REGIME_TEMPLATE_ID
               ,TAX_REGISTRATION_ID
               ,TAX_REGISTRATION_NUMBER
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TAX_TYPE_CODE
               ,TAXABLE_AMT
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TAXABLE_BASIS_FORMULA
               ,TAXING_JURIS_GEOGRAPHY_ID
               ,THRESH_RESULT_ID
               ,TRX_CURRENCY_CODE
               ,TRX_DATE
               ,TRX_ID
               ,TRX_ID_LEVEL2
               ,TRX_ID_LEVEL3
               ,TRX_ID_LEVEL4
               ,TRX_ID_LEVEL5
               ,TRX_ID_LEVEL6
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_DATE
               ,TRX_LINE_ID
               ,TRX_LINE_INDEX
               ,TRX_LINE_NUMBER
               ,TRX_LINE_QUANTITY
               ,TRX_NUMBER
               ,TRX_USER_KEY_LEVEL1
               ,TRX_USER_KEY_LEVEL2
               ,TRX_USER_KEY_LEVEL3
               ,TRX_USER_KEY_LEVEL4
               ,TRX_USER_KEY_LEVEL5
               ,TRX_USER_KEY_LEVEL6
               ,UNIT_PRICE
               ,UNROUNDED_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,MULTIPLE_JURISDICTIONS_FLAG)
        SELECT /*+ leading(poh) NO_EXPAND
                   use_nl(fc,pol,poll,ptp,atc,atg,atc1,rates,regimes,taxes,status) */
                NULL 	                           ADJUSTED_DOC_APPLICATION_ID
               ,NULL 	                           ADJUSTED_DOC_DATE
               ,NULL	                           ADJUSTED_DOC_ENTITY_CODE
               ,NULL                               ADJUSTED_DOC_EVENT_CLASS_CODE
               ,NULL                               ADJUSTED_DOC_LINE_ID
               ,NULL                               ADJUSTED_DOC_NUMBER
               ,NULL                               ADJUSTED_DOC_TAX_LINE_ID
               ,NULL                               ADJUSTED_DOC_TRX_ID
               ,NULL                               ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,201	                           APPLICATION_ID
               ,NULL                               APPLIED_FROM_APPLICATION_ID
               ,NULL                               APPLIED_FROM_ENTITY_CODE
               ,NULL                               APPLIED_FROM_EVENT_CLASS_CODE
               ,NULL                               APPLIED_FROM_LINE_ID
               ,NULL                               APPLIED_FROM_TRX_ID
               ,NULL                               APPLIED_FROM_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_FROM_TRX_NUMBER
               ,NULL	                           APPLIED_TO_APPLICATION_ID
               ,NULL	                           APPLIED_TO_ENTITY_CODE
               ,NULL	                           APPLIED_TO_EVENT_CLASS_CODE
               ,NULL	                           APPLIED_TO_LINE_ID
               ,NULL	                           APPLIED_TO_TRX_ID
               ,NULL	                           APPLIED_TO_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_TO_TRX_NUMBER
               ,'N' 	                           ASSOCIATED_CHILD_FROZEN_FLAG
               ,poll.ATTRIBUTE_CATEGORY            ATTRIBUTE_CATEGORY
               ,poll.ATTRIBUTE1 	           ATTRIBUTE1
               ,poll.ATTRIBUTE10	           ATTRIBUTE10
               ,poll.ATTRIBUTE11	           ATTRIBUTE11
               ,poll.ATTRIBUTE12	           ATTRIBUTE12
               ,poll.ATTRIBUTE13	           ATTRIBUTE13
               ,poll.ATTRIBUTE14	           ATTRIBUTE14
               ,poll.ATTRIBUTE15	           ATTRIBUTE15
               ,poll.ATTRIBUTE2 	           ATTRIBUTE2
               ,poll.ATTRIBUTE3 	           ATTRIBUTE3
               ,poll.ATTRIBUTE4 	           ATTRIBUTE4
               ,poll.ATTRIBUTE5 	           ATTRIBUTE5
               ,poll.ATTRIBUTE6 	           ATTRIBUTE6
               ,poll.ATTRIBUTE7 	           ATTRIBUTE7
               ,poll.ATTRIBUTE8 	           ATTRIBUTE8
               ,poll.ATTRIBUTE9 	           ATTRIBUTE9
               ,NULL			           BASIS_RESULT_ID
               ,NULL	                           CAL_TAX_AMT
               ,NULL	                           CAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           CAL_TAX_AMT_TAX_CURR
               ,NULL	                           CALC_RESULT_ID
               ,'N'	                           CANCEL_FLAG
               ,NULL	                           CHAR1
               ,NULL	                           CHAR10
               ,NULL	                           CHAR2
               ,NULL	                           CHAR3
               ,NULL	                           CHAR4
               ,NULL	                           CHAR5
               ,NULL	                           CHAR6
               ,NULL	                           CHAR7
               ,NULL	                           CHAR8
               ,NULL	                           CHAR9
               ,'N'	                           COMPOUNDING_DEP_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_MISS_FLAG
               ,ptp.party_tax_profile_id	   CONTENT_OWNER_ID
               ,'N'	                           COPIED_FROM_OTHER_DOC_FLAG
               ,1	                           CREATED_BY
               ,SYSDATE                            CREATION_DATE
               ,NULL		                   CTRL_TOTAL_LINE_TX_AMT
               ,poh.rate_date 	                   CURRENCY_CONVERSION_DATE
               ,poh.rate 	                   CURRENCY_CONVERSION_RATE
               ,poh.rate_type 	                   CURRENCY_CONVERSION_TYPE
               ,NULL	                           DATE1
               ,NULL	                           DATE10
               ,NULL	                           DATE2
               ,NULL	                           DATE3
               ,NULL	                           DATE4
               ,NULL	                           DATE5
               ,NULL	                           DATE6
               ,NULL	                           DATE7
               ,NULL	                           DATE8
               ,NULL	                           DATE9
               ,'N'	                           DELETE_FLAG
               ,NULL	                           DIRECT_RATE_RESULT_ID
               ,NULL	                           DOC_EVENT_STATUS
               ,'N'	                           ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,'PURCHASE_ORDER' 	           ENTITY_CODE
               ,NULL	                           ESTABLISHMENT_ID
               ,NULL	                           EVAL_EXCPT_RESULT_ID
               ,NULL	                           EVAL_EXMPT_RESULT_ID
               ,'PO_PA' 		           EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	   EVENT_TYPE_CODE
               ,NULL                               EXCEPTION_RATE
               ,NULL	                           EXEMPT_CERTIFICATE_NUMBER
               ,NULL	                           EXEMPT_RATE_MODIFIER
               ,NULL	                           EXEMPT_REASON
               ,NULL	                           EXEMPT_REASON_CODE
               ,'N'	                           FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,poll.GLOBAL_ATTRIBUTE_CATEGORY     GLOBAL_ATTRIBUTE_CATEGORY
               ,poll.GLOBAL_ATTRIBUTE1 	           GLOBAL_ATTRIBUTE1
               ,poll.GLOBAL_ATTRIBUTE10	           GLOBAL_ATTRIBUTE10
               ,poll.GLOBAL_ATTRIBUTE11	           GLOBAL_ATTRIBUTE11
               ,poll.GLOBAL_ATTRIBUTE12	           GLOBAL_ATTRIBUTE12
               ,poll.GLOBAL_ATTRIBUTE13	           GLOBAL_ATTRIBUTE13
               ,poll.GLOBAL_ATTRIBUTE14	           GLOBAL_ATTRIBUTE14
               ,poll.GLOBAL_ATTRIBUTE15	           GLOBAL_ATTRIBUTE15
               ,poll.GLOBAL_ATTRIBUTE2             GLOBAL_ATTRIBUTE2
               ,poll.GLOBAL_ATTRIBUTE3             GLOBAL_ATTRIBUTE3
               ,poll.GLOBAL_ATTRIBUTE4             GLOBAL_ATTRIBUTE4
               ,poll.GLOBAL_ATTRIBUTE5             GLOBAL_ATTRIBUTE5
               ,poll.GLOBAL_ATTRIBUTE6             GLOBAL_ATTRIBUTE6
               ,poll.GLOBAL_ATTRIBUTE7             GLOBAL_ATTRIBUTE7
               ,poll.GLOBAL_ATTRIBUTE8             GLOBAL_ATTRIBUTE8
               ,poll.GLOBAL_ATTRIBUTE9             GLOBAL_ATTRIBUTE9
               ,'Y'	                           HISTORICAL_FLAG
               ,NULL                               HQ_ESTB_PARTY_TAX_PROF_ID
               ,NULL	                           HQ_ESTB_REG_NUMBER
               ,NULL	                           INTERFACE_ENTITY_CODE
               ,NULL	                           INTERFACE_TAX_LINE_ID
               ,NULL                               INTERNAL_ORG_LOCATION_ID
               ,nvl(poh.org_id,-99)                INTERNAL_ORGANIZATION_ID
               ,'N'                                ITEM_DIST_CHANGED_FLAG
               ,NULL	                           LAST_MANUAL_ENTRY
               ,SYSDATE	                           LAST_UPDATE_DATE
               ,1	                           LAST_UPDATE_LOGIN
               ,1	                           LAST_UPDATED_BY
               ,poh.set_of_books_id 	           LEDGER_ID
               ,NVL(poh.oi_org_information2, -99)  LEGAL_ENTITY_ID
               ,NULL                               LEGAL_ENTITY_TAX_REG_NUMBER
               ,NULL                               LEGAL_JUSTIFICATION_TEXT1
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT2
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT3
               ,NULL                               LEGAL_MESSAGE_APPL_2
               ,NULL	                           LEGAL_MESSAGE_BASIS
               ,NULL	                           LEGAL_MESSAGE_CALC
               ,NULL	                           LEGAL_MESSAGE_EXCPT
               ,NULL	                           LEGAL_MESSAGE_EXMPT
               ,NULL	                           LEGAL_MESSAGE_POS
               ,NULL	                           LEGAL_MESSAGE_RATE
               ,NULL                               LEGAL_MESSAGE_STATUS
               ,NULL	                           LEGAL_MESSAGE_THRESHOLD
               ,NULL	                           LEGAL_MESSAGE_TRN
               ,DECODE(pol.purchase_basis,
                 'TEMP LABOR', NVL(POLL.amount,0),
                 'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                    NVL(poll.quantity,0) *
                                    NVL(poll.price_override,NVL(pol.unit_price,0))),
                  NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                                   LINE_AMT
               ,NULL	                           LINE_ASSESSABLE_VALUE
               ,'N'	                           MANUALLY_ENTERED_FLAG
               ,fc.minimum_accountable_unit	   MINIMUM_ACCOUNTABLE_UNIT
               ,NULL	                           MRC_LINK_TO_TAX_LINE_ID
               ,'N'	                           MRC_TAX_LINE_FLAG
               ,NULL	                           NREC_TAX_AMT
               ,NULL	                           NREC_TAX_AMT_FUNCL_CURR
               ,NULL	                           NREC_TAX_AMT_TAX_CURR
               ,NULL	                           NUMERIC1
               ,NULL	                           NUMERIC10
               ,NULL	                           NUMERIC2
               ,NULL	                           NUMERIC3
               ,NULL	                           NUMERIC4
               ,NULL	                           NUMERIC5
               ,NULL	                           NUMERIC6
               ,NULL	                           NUMERIC7
               ,NULL	                           NUMERIC8
               ,NULL	                           NUMERIC9
               ,1	                           OBJECT_VERSION_NUMBER
               ,'N'	                           OFFSET_FLAG
               ,NULL	                           OFFSET_LINK_TO_TAX_LINE_ID
               ,NULL	                           OFFSET_TAX_RATE_CODE
               ,'N'	                           ORIG_SELF_ASSESSED_FLAG
               ,NULL	                           ORIG_TAX_AMT
               ,NULL	                           ORIG_TAX_AMT_INCLUDED_FLAG
               ,NULL	                           ORIG_TAX_AMT_TAX_CURR
               ,NULL	                           ORIG_TAX_JURISDICTION_CODE
               ,NULL	                           ORIG_TAX_JURISDICTION_ID
               ,NULL	                           ORIG_TAX_RATE
               ,NULL	                           ORIG_TAX_RATE_CODE
               ,NULL	                           ORIG_TAX_RATE_ID
               ,NULL	                           ORIG_TAX_STATUS_CODE
               ,NULL	                           ORIG_TAX_STATUS_ID
               ,NULL	                           ORIG_TAXABLE_AMT
               ,NULL	                           ORIG_TAXABLE_AMT_TAX_CURR
               ,NULL	                           OTHER_DOC_LINE_AMT
               ,NULL	                           OTHER_DOC_LINE_TAX_AMT
               ,NULL	                           OTHER_DOC_LINE_TAXABLE_AMT
               ,NULL	                           OTHER_DOC_SOURCE
               ,'N'	                           OVERRIDDEN_FLAG
               ,NULL	                           PLACE_OF_SUPPLY
               ,NULL	                           PLACE_OF_SUPPLY_RESULT_ID
               ,NULL                               PLACE_OF_SUPPLY_TYPE_CODE
               ,NULL	                           PRD_TOTAL_TAX_AMT
               ,NULL	                           PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           PRD_TOTAL_TAX_AMT_TAX_CURR
               ,NVL(fc.precision, 0)               PRECISION
               ,'N'	                           PROCESS_FOR_RECOVERY_FLAG
               ,NULL	                           PRORATION_CODE
               ,'N'	                           PURGE_FLAG
               ,NULL	                           RATE_RESULT_ID
               ,NULL	                           REC_TAX_AMT
               ,NULL	                           REC_TAX_AMT_FUNCL_CURR
               ,NULL	                           REC_TAX_AMT_TAX_CURR
               ,'N'	                           RECALC_REQUIRED_FLAG
               ,'MIGRATED'                         RECORD_TYPE_CODE
               ,NULL	                           REF_DOC_APPLICATION_ID
               ,NULL	                           REF_DOC_ENTITY_CODE
               ,NULL	                           REF_DOC_EVENT_CLASS_CODE
               ,NULL	                           REF_DOC_LINE_ID
               ,NULL	                           REF_DOC_LINE_QUANTITY
               ,NULL	                           REF_DOC_TRX_ID
               ,NULL	                           REF_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REGISTRATION_PARTY_TYPE
               ,NULL	                           RELATED_DOC_APPLICATION_ID
               ,NULL	                           RELATED_DOC_DATE
               ,NULL	                           RELATED_DOC_ENTITY_CODE
               ,NULL	                           RELATED_DOC_EVENT_CLASS_CODE
               ,NULL	                           RELATED_DOC_NUMBER
               ,NULL	                           RELATED_DOC_TRX_ID
               ,NULL	                           RELATED_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REPORTING_CURRENCY_CODE
               ,'N'	                           REPORTING_ONLY_FLAG
               ,NULL	                           REPORTING_PERIOD_ID
               ,NULL	                           ROUNDING_LEVEL_CODE
               ,NULL	                           ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,NULL	                           ROUNDING_LVL_PARTY_TYPE
               ,NULL	                           ROUNDING_RULE_CODE
               ,'N'	                           SELF_ASSESSED_FLAG
               ,'N'                                SETTLEMENT_FLAG
               ,NULL                               STATUS_RESULT_ID
               ,NULL                               SUMMARY_TAX_LINE_ID
               ,NULL                               SYNC_WITH_PRVDR_FLAG
               ,rates.tax                          TAX
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)  TAX_AMT
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)
                                                   TAX_AMT_FUNCL_CURR
               ,'N'                                TAX_AMT_INCLUDED_FLAG
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit) TAX_AMT_TAX_CURR
               ,NULL                               TAX_APPLICABILITY_RESULT_ID
               ,'Y'                                TAX_APPORTIONMENT_FLAG
               ,RANK() OVER
                 (PARTITION BY
                   poh.po_header_id,
                   poll.line_location_id,
                   rates.tax_regime_code,
                   rates.tax
                  ORDER BY atg.tax_code_id)        TAX_APPORTIONMENT_LINE_NUMBER
               ,NULL                               TAX_BASE_MODIFIER_RATE
               ,'STANDARD_TC'                      TAX_CALCULATION_FORMULA
               ,NULL                               TAX_CODE
               ,taxes.tax_currency_code            TAX_CURRENCY_CODE
               ,poh.rate_date 		           TAX_CURRENCY_CONVERSION_DATE
               ,poh.rate 		           TAX_CURRENCY_CONVERSION_RATE
               ,poh.rate_type 		           TAX_CURRENCY_CONVERSION_TYPE
               ,poll.last_update_date              TAX_DATE
               ,NULL                               TAX_DATE_RULE_ID
               ,poll.last_update_date              TAX_DETERMINE_DATE
               ,'PURCHASE_TRANSACTION' 	           TAX_EVENT_CLASS_CODE
               ,'VALIDATE'  		           TAX_EVENT_TYPE_CODE
               ,NULL                               TAX_EXCEPTION_ID
               ,NULL                               TAX_EXEMPTION_ID
               ,NULL                               TAX_HOLD_CODE
               ,NULL                               TAX_HOLD_RELEASED_CODE
               ,taxes.tax_id                       TAX_ID
               ,NULL                               TAX_JURISDICTION_CODE
               ,NULL                               TAX_JURISDICTION_ID
               ,zx_lines_s.nextval                 TAX_LINE_ID
               ,RANK() OVER
                (PARTITION BY poh.po_header_id
                     ORDER BY poll.line_location_id,
                              atg.tax_code_id,
                              atc.tax_id)         TAX_LINE_NUMBER
               ,'N'                               TAX_ONLY_LINE_FLAG
               ,poll.last_update_date             TAX_POINT_DATE
               ,NULL                              TAX_PROVIDER_ID
               ,rates.percentage_rate  	          TAX_RATE
               ,NULL	                          TAX_RATE_BEFORE_EXCEPTION
               ,NULL                              TAX_RATE_BEFORE_EXEMPTION
               ,rates.tax_rate_code               TAX_RATE_CODE
               ,rates.tax_rate_id                 TAX_RATE_ID
               ,NULL                              TAX_RATE_NAME_BEFORE_EXCEPTION
               ,NULL                              TAX_RATE_NAME_BEFORE_EXEMPTION
               ,NULL                              TAX_RATE_TYPE
               ,NULL                              TAX_REG_NUM_DET_RESULT_ID
               ,rates.tax_regime_code             TAX_REGIME_CODE
               ,regimes.tax_regime_id             TAX_REGIME_ID
               ,NULL                              TAX_REGIME_TEMPLATE_ID
               ,NULL                              TAX_REGISTRATION_ID
               ,NULL                              TAX_REGISTRATION_NUMBER
               ,rates.tax_status_code             TAX_STATUS_CODE
               ,status.tax_status_id              TAX_STATUS_ID
               ,NULL                              TAX_TYPE_CODE
               ,NULL                              TAXABLE_AMT
               ,NULL                              TAXABLE_AMT_FUNCL_CURR
               ,NULL                              TAXABLE_AMT_TAX_CURR
               ,'STANDARD_TB'                     TAXABLE_BASIS_FORMULA
               ,NULL                              TAXING_JURIS_GEOGRAPHY_ID
               ,NULL                              THRESH_RESULT_ID
               ,NVL(poh.currency_code,
                    poh.base_currency_code)       TRX_CURRENCY_CODE
               ,poh.last_update_date              TRX_DATE
               ,poh.po_header_id                  TRX_ID
               ,NULL                              TRX_ID_LEVEL2
               ,NULL                              TRX_ID_LEVEL3
               ,NULL                              TRX_ID_LEVEL4
               ,NULL                              TRX_ID_LEVEL5
               ,NULL                              TRX_ID_LEVEL6
               ,'SHIPMENT'                        TRX_LEVEL_TYPE
               ,poll.LAST_UPDATE_DATE             TRX_LINE_DATE
               ,poll.line_location_id             TRX_LINE_ID
               ,NULL                              TRX_LINE_INDEX
               ,poll.SHIPMENT_NUM                 TRX_LINE_NUMBER
               ,poll.quantity 		          TRX_LINE_QUANTITY
               ,poh.segment1                      TRX_NUMBER
               ,NULL                              TRX_USER_KEY_LEVEL1
               ,NULL                              TRX_USER_KEY_LEVEL2
               ,NULL                              TRX_USER_KEY_LEVEL3
               ,NULL                              TRX_USER_KEY_LEVEL4
               ,NULL                              TRX_USER_KEY_LEVEL5
               ,NULL                              TRX_USER_KEY_LEVEL6
               ,NVL(poll.price_override,
                     pol.unit_price)              UNIT_PRICE
               ,NULL                              UNROUNDED_TAX_AMT
               ,NULL                              UNROUNDED_TAXABLE_AMT
               ,'N'                               MULTIPLE_JURISDICTIONS_FLAG
         FROM (SELECT /*+ NO_MERGE NO_EXPAND use_hash(fsp) use_hash(aps) use_hash(oi)
                      swap_join_inputs(fsp) swap_join_inputs(aps)
                      swap_join_inputs(oi) */
   	              poh.* , fsp.org_id fsp_org_id, fsp.set_of_books_id,
   	              aps.base_currency_code, oi.org_information2 oi_org_information2
                 FROM (select distinct other_doc_application_id, other_doc_trx_id
   	                 from ZX_VALIDATION_ERRORS_GT
   	                where other_doc_application_id = 201
   	                  and other_doc_entity_code = 'PURCHASE_ORDER'
   	                  and other_doc_event_class_code = 'PO_PA'
   	              ) zxvalerr, --Bug 5187701
                      po_headers_all poh,
   	              financials_system_params_all fsp,
	              ap_system_parameters_all aps,
	              hr_organization_information oi
                WHERE poh.po_header_id = zxvalerr.other_doc_trx_id
                  AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                  AND NVL(aps.org_id, -99) = NVL(poh.org_id,-99)
                  AND aps.set_of_books_id = fsp.set_of_books_id
                  AND oi.organization_id(+) = poh.org_id
                  AND oi.org_information_context(+) = 'Operating Unit Information'
              ) poh,
              fnd_currencies fc,
              po_lines_all pol,
              po_line_locations_all poll,
              zx_party_tax_profile ptp,
              ap_tax_codes_all atc,
              ar_tax_group_codes_all atg,
              ap_tax_codes_all atc1,
              zx_rates_b rates,
              zx_regimes_b regimes,
              zx_taxes_b taxes,
              zx_status_b status
        WHERE NVL(poh.currency_code, poh.base_currency_code) = fc.currency_code(+)
          AND poh.po_header_id = pol.po_header_id
          AND pol.po_header_id = poll.po_header_id
          AND pol.po_line_id = poll.po_line_id
          AND NOT EXISTS
              (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                 WHERE lines_gt.application_id   = 201
                   AND lines_gt.event_class_code = 'PO_PA'
                   AND lines_gt.entity_code      = 'PURCHASE_ORDER'
                   AND lines_gt.trx_id           = poh.po_header_id
                   AND lines_gt.trx_line_id      = poll.line_location_id
                   AND lines_gt.trx_level_type   = 'SHIPMENT'
                   AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
              )
          AND nvl(atc.org_id,-99)=nvl(poh.fsp_org_id,-99)
          AND poll.tax_code_id = atc.tax_id
          AND atc.tax_type = 'TAX_GROUP'
          --Bug 8352135
 	        AND atg.start_date <= poll.last_update_date
	        AND (atg.end_date >= poll.last_update_date OR atg.end_date IS NULL)
          AND poll.tax_code_id = atg.tax_group_id
          AND atc1.tax_id = atg.tax_code_id
          AND atc1.start_date <= poll.last_update_date
          AND(atc1.inactive_date >= poll.last_update_date OR atc1.inactive_date IS NULL)
          AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
          AND ptp.party_type_code = 'OU'
          AND rates.source_id = atg.tax_code_id
          AND regimes.tax_regime_code(+) = rates.tax_regime_code
          AND taxes.tax_regime_code(+) = rates.tax_regime_code
          AND taxes.tax(+) = rates.tax
          AND taxes.content_owner_id(+) = rates.content_owner_id
          AND status.tax_regime_code(+) = rates.tax_regime_code
          AND status.tax(+) = rates.tax
          AND status.content_owner_id(+) = rates.content_owner_id
          AND status.tax_status_code(+) = rates.tax_status_code;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                   'ZX_LINES Number of Rows Inserted(Tax Group) = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;

  -- COMMIT;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk_po',
                  'Inserting data into zx_rec_nrec_dist');
  END IF;

  -- Insert data into zx_rec_nrec_dist
  --
    INSERT INTO ZX_REC_NREC_DIST(
              TAX_LINE_ID
             ,REC_NREC_TAX_DIST_ID
             ,REC_NREC_TAX_DIST_NUMBER
             ,APPLICATION_ID
             ,CONTENT_OWNER_ID
             ,CURRENCY_CONVERSION_DATE
             ,CURRENCY_CONVERSION_RATE
             ,CURRENCY_CONVERSION_TYPE
             ,ENTITY_CODE
             ,EVENT_CLASS_CODE
             ,EVENT_TYPE_CODE
             ,LEDGER_ID
             ,MINIMUM_ACCOUNTABLE_UNIT
             ,PRECISION
             ,RECORD_TYPE_CODE
             ,REF_DOC_APPLICATION_ID
             ,REF_DOC_ENTITY_CODE
             ,REF_DOC_EVENT_CLASS_CODE
             ,REF_DOC_LINE_ID
             ,REF_DOC_TRX_ID
             ,REF_DOC_TRX_LEVEL_TYPE
             ,SUMMARY_TAX_LINE_ID
             ,TAX
             ,TAX_APPORTIONMENT_LINE_NUMBER
             ,TAX_CURRENCY_CODE
             ,TAX_CURRENCY_CONVERSION_DATE
             ,TAX_CURRENCY_CONVERSION_RATE
             ,TAX_CURRENCY_CONVERSION_TYPE
             ,TAX_EVENT_CLASS_CODE
             ,TAX_EVENT_TYPE_CODE
             ,TAX_ID
             ,TAX_LINE_NUMBER
             ,TAX_RATE
             ,TAX_RATE_CODE
             ,TAX_RATE_ID
             ,TAX_REGIME_CODE
             ,TAX_REGIME_ID
             ,TAX_STATUS_CODE
             ,TAX_STATUS_ID
             ,TRX_CURRENCY_CODE
             ,TRX_ID
             ,TRX_LEVEL_TYPE
             ,TRX_LINE_ID
             ,TRX_LINE_NUMBER
             ,TRX_NUMBER
             ,UNIT_PRICE
             ,ACCOUNT_CCID
             ,ACCOUNT_STRING
             ,ADJUSTED_DOC_TAX_DIST_ID
             ,APPLIED_FROM_TAX_DIST_ID
             ,APPLIED_TO_DOC_CURR_CONV_RATE
             ,AWARD_ID
             ,EXPENDITURE_ITEM_DATE
             ,EXPENDITURE_ORGANIZATION_ID
             ,EXPENDITURE_TYPE
             ,FUNC_CURR_ROUNDING_ADJUSTMENT
             ,GL_DATE
             ,INTENDED_USE
             ,ITEM_DIST_NUMBER
             ,MRC_LINK_TO_TAX_DIST_ID
             ,ORIG_REC_NREC_RATE
             ,ORIG_REC_NREC_TAX_AMT
             ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
             ,ORIG_REC_RATE_CODE
             ,PER_TRX_CURR_UNIT_NR_AMT
             ,PER_UNIT_NREC_TAX_AMT
             ,PRD_TAX_AMT
             ,PRICE_DIFF
             ,PROJECT_ID
             ,QTY_DIFF
             ,RATE_TAX_FACTOR
             ,REC_NREC_RATE
             ,REC_NREC_TAX_AMT
             ,REC_NREC_TAX_AMT_FUNCL_CURR
             ,REC_NREC_TAX_AMT_TAX_CURR
             ,RECOVERY_RATE_CODE
             ,RECOVERY_RATE_ID
             ,RECOVERY_TYPE_CODE
             ,RECOVERY_TYPE_ID
             ,REF_DOC_CURR_CONV_RATE
             ,REF_DOC_DIST_ID
             ,REF_DOC_PER_UNIT_NREC_TAX_AMT
             ,REF_DOC_TAX_DIST_ID
             ,REF_DOC_TRX_LINE_DIST_QTY
             ,REF_DOC_UNIT_PRICE
             ,REF_PER_TRX_CURR_UNIT_NR_AMT
             ,REVERSED_TAX_DIST_ID
             ,ROUNDING_RULE_CODE
             ,TASK_ID
             ,TAXABLE_AMT_FUNCL_CURR
             ,TAXABLE_AMT_TAX_CURR
             ,TRX_LINE_DIST_AMT
             ,TRX_LINE_DIST_ID
             ,TRX_LINE_DIST_QTY
             ,TRX_LINE_DIST_TAX_AMT
             ,UNROUNDED_REC_NREC_TAX_AMT
             ,UNROUNDED_TAXABLE_AMT
             ,TAXABLE_AMT
             ,ATTRIBUTE_CATEGORY
             ,ATTRIBUTE1
             ,ATTRIBUTE2
             ,ATTRIBUTE3
             ,ATTRIBUTE4
             ,ATTRIBUTE5
             ,ATTRIBUTE6
             ,ATTRIBUTE7
             ,ATTRIBUTE8
             ,ATTRIBUTE9
             ,ATTRIBUTE10
             ,ATTRIBUTE11
             ,ATTRIBUTE12
             ,ATTRIBUTE13
             ,ATTRIBUTE14
             ,ATTRIBUTE15
             ,HISTORICAL_FLAG
             ,OVERRIDDEN_FLAG
             ,SELF_ASSESSED_FLAG
             ,TAX_APPORTIONMENT_FLAG
             ,TAX_ONLY_LINE_FLAG
             ,INCLUSIVE_FLAG
             ,MRC_TAX_DIST_FLAG
             ,REC_TYPE_RULE_FLAG
             ,NEW_REC_RATE_CODE_FLAG
             ,RECOVERABLE_FLAG
             ,REVERSE_FLAG
             ,REC_RATE_DET_RULE_FLAG
             ,BACKWARD_COMPATIBILITY_FLAG
             ,FREEZE_FLAG
             ,POSTING_FLAG
             ,LEGAL_ENTITY_ID
             ,CREATED_BY
             ,CREATION_DATE
             ,LAST_MANUAL_ENTRY
             ,LAST_UPDATE_DATE
             ,LAST_UPDATE_LOGIN
             ,LAST_UPDATED_BY
             ,OBJECT_VERSION_NUMBER)
       SELECT /*+ NO_EXPAND leading(pohzd) use_nl(fc, rates)*/
              pohzd.tax_line_id			         TAX_LINE_ID
              ,zx_rec_nrec_dist_s.nextval                REC_NREC_TAX_DIST_ID
              ,DECODE(tmp.rec_flag,
                'Y', (RANK() OVER (PARTITION BY pohzd.po_header_id,
                                   pohzd.p_po_distribution_id
                                   ORDER BY
                                   pohzd.p_po_distribution_id,pohzd.tax_rate_id))*2-1,
                'N', (RANK() OVER (PARTITION BY pohzd.po_header_id,
                                   pohzd.p_po_distribution_id
                                   ORDER BY
                                   pohzd.p_po_distribution_id,pohzd.tax_rate_id))*2)
                                                         REC_NREC_TAX_DIST_NUMBER
              ,201 					 APPLICATION_ID
              ,pohzd.content_owner_id			 CONTENT_OWNER_ID
              ,pohzd.CURRENCY_CONVERSION_DATE		 CURRENCY_CONVERSION_DATE
              ,pohzd.CURRENCY_CONVERSION_RATE		 CURRENCY_CONVERSION_RATE
              ,pohzd.CURRENCY_CONVERSION_TYPE		 CURRENCY_CONVERSION_TYPE
              ,'PURCHASE_ORDER' 			 ENTITY_CODE
              ,'PO_PA'			 	         EVENT_CLASS_CODE
              ,'PURCHASE ORDER CREATED'		 	 EVENT_TYPE_CODE
              ,pohzd.ledger_id				 LEDGER_ID
              ,pohzd.MINIMUM_ACCOUNTABLE_UNIT		 MINIMUM_ACCOUNTABLE_UNIT
              ,pohzd.PRECISION				 PRECISION
              ,'MIGRATED' 				 RECORD_TYPE_CODE
              ,NULL 					 REF_DOC_APPLICATION_ID
              ,NULL 					 REF_DOC_ENTITY_CODE
              ,NULL					 REF_DOC_EVENT_CLASS_CODE
              ,NULL					 REF_DOC_LINE_ID
              ,NULL					 REF_DOC_TRX_ID
              ,NULL					 REF_DOC_TRX_LEVEL_TYPE
              ,NULL 					 SUMMARY_TAX_LINE_ID
              ,pohzd.tax				 TAX
              ,pohzd.TAX_APPORTIONMENT_LINE_NUMBER       TAX_APPORTIONMENT_LINE_NUMBER
              ,pohzd.TAX_CURRENCY_CODE			 TAX_CURRENCY_CODE
              ,pohzd.TAX_CURRENCY_CONVERSION_DATE	 TAX_CURRENCY_CONVERSION_DATE
              ,pohzd.TAX_CURRENCY_CONVERSION_RATE	 TAX_CURRENCY_CONVERSION_RATE
              ,pohzd.TAX_CURRENCY_CONVERSION_TYPE	 TAX_CURRENCY_CONVERSION_TYPE
              ,'PURCHASE_TRANSACTION' 		 	 TAX_EVENT_CLASS_CODE
              ,'VALIDATE'				 TAX_EVENT_TYPE_CODE
              ,pohzd.tax_id				 TAX_ID
              ,pohzd.tax_line_number			 TAX_LINE_NUMBER
              ,pohzd.tax_rate				 TAX_RATE
              ,pohzd.tax_rate_code 			 TAX_RATE_CODE
              ,pohzd.tax_rate_id			 TAX_RATE_ID
              ,pohzd.tax_regime_code	 		 TAX_REGIME_CODE
              ,pohzd.tax_regime_id		         TAX_REGIME_ID
              ,pohzd.tax_status_code			 TAX_STATUS_CODE
              ,pohzd.tax_status_id	 		 TAX_STATUS_ID
              ,pohzd.trx_currency_code			 TRX_CURRENCY_CODE
              ,pohzd.trx_id				 TRX_ID
              ,'SHIPMENT' 				 TRX_LEVEL_TYPE
              ,pohzd.trx_line_id			 TRX_LINE_ID
              ,pohzd.trx_line_number			 TRX_LINE_NUMBER
              ,pohzd.trx_number				 TRX_NUMBER
              ,pohzd.unit_price				 UNIT_PRICE
              ,NULL					 ACCOUNT_CCID
              ,NULL					 ACCOUNT_STRING
              ,NULL					 ADJUSTED_DOC_TAX_DIST_ID
              ,NULL					 APPLIED_FROM_TAX_DIST_ID
              ,NULL					 APPLIED_TO_DOC_CURR_CONV_RATE
              ,NULL					 AWARD_ID
              ,pohzd.p_expenditure_item_date		 EXPENDITURE_ITEM_DATE
              ,pohzd.p_expenditure_organization_id	 EXPENDITURE_ORGANIZATION_ID
              ,pohzd.p_expenditure_type			 EXPENDITURE_TYPE
              ,NULL					 FUNC_CURR_ROUNDING_ADJUSTMENT
              ,NULL					 GL_DATE
              ,NULL					 INTENDED_USE
              ,NULL					 ITEM_DIST_NUMBER
              ,NULL					 MRC_LINK_TO_TAX_DIST_ID
              ,NULL					 ORIG_REC_NREC_RATE
              ,NULL					 ORIG_REC_NREC_TAX_AMT
              ,NULL					 ORIG_REC_NREC_TAX_AMT_TAX_CURR
              ,NULL					 ORIG_REC_RATE_CODE
              ,NULL					 PER_TRX_CURR_UNIT_NR_AMT
              ,NULL					 PER_UNIT_NREC_TAX_AMT
              ,NULL					 PRD_TAX_AMT
              ,NULL					 PRICE_DIFF
              ,pohzd.p_project_id			 PROJECT_ID
              ,NULL					 QTY_DIFF
              ,NULL					 RATE_TAX_FACTOR
              ,DECODE(tmp.rec_flag,
                'Y', NVL(NVL(pohzd.p_recovery_rate,
                              pohzd.d_rec_rate), 0),
                'N', 100 - NVL(NVL(pohzd.p_recovery_rate,
                                 pohzd.d_rec_rate), 0))  REC_NREC_RATE
              ,DECODE(tmp.rec_flag,
                      'N',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                               (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                   (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                      'Y',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                               (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                     )                                   REC_NREC_TAX_AMT
              ,DECODE(tmp.rec_flag,
                      'N',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                               (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                   (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                      'Y',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                     )                                   REC_NREC_TAX_AMT_FUNCL_CURR
              ,DECODE(tmp.rec_flag,
                       'N',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                               (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                         ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                   (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                      'Y',
                       DECODE(fc.Minimum_Accountable_Unit,null,
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                        (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                     )                                   REC_NREC_TAX_AMT_TAX_CURR
               ,NVL(rates.tax_rate_code,
                                     'AD_HOC_RECOVERY')  RECOVERY_RATE_CODE
               ,rates.tax_rate_id                        RECOVERY_RATE_ID
               ,DECODE(tmp.rec_flag,'N', NULL,
                       NVL(rates.recovery_type_code,
                                           'STANDARD'))  RECOVERY_TYPE_CODE
               ,NULL					 RECOVERY_TYPE_ID
               ,NULL					 REF_DOC_CURR_CONV_RATE
               ,NULL					 REF_DOC_DIST_ID
               ,NULL					 REF_DOC_PER_UNIT_NREC_TAX_AMT
               ,NULL					 REF_DOC_TAX_DIST_ID
               ,NULL					 REF_DOC_TRX_LINE_DIST_QTY
               ,NULL					 REF_DOC_UNIT_PRICE
               ,NULL					 REF_PER_TRX_CURR_UNIT_NR_AMT
               ,NULL					 REVERSED_TAX_DIST_ID
               ,NULL					 ROUNDING_RULE_CODE
               ,pohzd.p_task_id				 TASK_ID
               ,null					 TAXABLE_AMT_FUNCL_CURR
               ,NULL					 TAXABLE_AMT_TAX_CURR
               ,NULL					 TRX_LINE_DIST_AMT
               ,pohzd.p_po_distribution_id		 TRX_LINE_DIST_ID
               ,NULL					 TRX_LINE_DIST_QTY
               ,NULL					 TRX_LINE_DIST_TAX_AMT
               ,NULL					 UNROUNDED_REC_NREC_TAX_AMT
               ,NULL					 UNROUNDED_TAXABLE_AMT
               ,NULL					 TAXABLE_AMT
               ,pohzd.p_ATTRIBUTE_CATEGORY               ATTRIBUTE_CATEGORY
               ,pohzd.p_ATTRIBUTE1                       ATTRIBUTE1
               ,pohzd.p_ATTRIBUTE2                       ATTRIBUTE2
               ,pohzd.p_ATTRIBUTE3                       ATTRIBUTE3
               ,pohzd.p_ATTRIBUTE4                       ATTRIBUTE4
               ,pohzd.p_ATTRIBUTE5                       ATTRIBUTE5
               ,pohzd.p_ATTRIBUTE6                       ATTRIBUTE6
               ,pohzd.p_ATTRIBUTE7                       ATTRIBUTE7
               ,pohzd.p_ATTRIBUTE8                       ATTRIBUTE8
               ,pohzd.p_ATTRIBUTE9                       ATTRIBUTE9
               ,pohzd.p_ATTRIBUTE10                      ATTRIBUTE10
               ,pohzd.p_ATTRIBUTE11                      ATTRIBUTE11
               ,pohzd.p_ATTRIBUTE12                      ATTRIBUTE12
               ,pohzd.p_ATTRIBUTE13                      ATTRIBUTE13
               ,pohzd.p_ATTRIBUTE14                      ATTRIBUTE14
               ,pohzd.p_ATTRIBUTE15                      ATTRIBUTE15
               ,'Y'			                 HISTORICAL_FLAG
               ,'N'			                 OVERRIDDEN_FLAG
               ,'N'			                 SELF_ASSESSED_FLAG
               ,'Y'			                 TAX_APPORTIONMENT_FLAG
               ,'N'			                 TAX_ONLY_LINE_FLAG
               ,'N'			                 INCLUSIVE_FLAG
               ,'N'			                 MRC_TAX_DIST_FLAG
               ,'N'			                 REC_TYPE_RULE_FLAG
               ,'N'			                 NEW_REC_RATE_CODE_FLAG
               ,tmp.rec_flag                             RECOVERABLE_FLAG
               ,'N'			                 REVERSE_FLAG
               ,'N'			                 REC_RATE_DET_RULE_FLAG
               ,'Y'			                 BACKWARD_COMPATIBILITY_FLAG
               ,'N'			                 FREEZE_FLAG
               ,'N'			                 POSTING_FLAG
               ,NVL(pohzd.legal_entity_id,-99)           LEGAL_ENTITY_ID
               ,1			                 CREATED_BY
               ,SYSDATE		                         CREATION_DATE
               ,NULL		                         LAST_MANUAL_ENTRY
               ,SYSDATE		                         LAST_UPDATE_DATE
               ,1			                 LAST_UPDATE_LOGIN
               ,1			                 LAST_UPDATED_BY
               ,1			                 OBJECT_VERSION_NUMBER
          FROM (SELECT /*+ use_nl_with_index(recdist ZX_PO_REC_DIST_N1) */
                       pohzd.*,
                       recdist.rec_rate     d_rec_rate
                  FROM (SELECT /*+ NO_EXPAND leading(poh) use_nl_with_index(zxl, ZX_LINES_U1) use_nl(pod) */
                              poh.po_header_id,
                              poll.last_update_date poll_last_update_date,
                              fsp.set_of_books_id,
                              zxl.*,
                              pod.po_distribution_id                  p_po_distribution_id,
                              pod.expenditure_item_date               p_expenditure_item_date,
                              pod.expenditure_organization_id         p_expenditure_organization_id,
                              pod.expenditure_type                    p_expenditure_type,
                              pod.project_id                          p_project_id,
                              pod.task_id                             p_task_id,
                              pod.recovery_rate                       p_recovery_rate,
                              pod.quantity_ordered                    p_quantity_ordered,
                              pod.attribute_category                  p_attribute_category ,
                              pod.attribute1                          p_attribute1,
                              pod.attribute2                          p_attribute2,
                              pod.attribute3                          p_attribute3,
                              pod.attribute4                          p_attribute4,
                              pod.attribute5                          p_attribute5,
                              pod.attribute6                          p_attribute6,
                              pod.attribute7                          p_attribute7,
                              pod.attribute8                          p_attribute8,
                              pod.attribute9                          p_attribute9,
                              pod.attribute10                         p_attribute10,
                              pod.attribute11                         p_attribute11,
                              pod.attribute12                         p_attribute12,
                              pod.attribute13                         p_attribute13,
                              pod.attribute14                         p_attribute14,
                              pod.attribute15                         p_attribute15
                         FROM (select distinct other_doc_application_id, other_doc_trx_id
                                 from ZX_VALIDATION_ERRORS_GT
                                where other_doc_application_id = 201
                                  and other_doc_entity_code = 'PURCHASE_ORDER'
                                  and other_doc_event_class_code = 'PO_PA'
                              ) zxvalerr, --Bug 5187701
                              po_headers_all poh,
                       	      financials_system_params_all fsp,
                              zx_lines zxl,
                              po_line_locations_all poll,
                              po_distributions_all pod
                        WHERE poh.po_header_id = zxvalerr.other_doc_trx_id
                          AND NVL(poh.org_id, -99) = NVL(fsp.org_id, -99)
                          AND zxl.application_id = 201
                          AND zxl.entity_code = 'PURCHASE_ORDER'
                          AND zxl.event_class_code = 'PO_PA'
                          AND zxl.trx_id = poh.po_header_id
                          AND poll.line_location_id = zxl.trx_line_id
                          AND NOT EXISTS
                             (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                                WHERE lines_gt.application_id   = 201
                                  AND lines_gt.event_class_code = 'PO_PA'
                                  AND lines_gt.entity_code      = 'PURCHASE_ORDER'
                                  AND lines_gt.trx_id           = poh.po_header_id
                                  AND lines_gt.trx_line_id      = poll.line_location_id
                                  AND lines_gt.trx_level_type   = 'SHIPMENT'
                                  AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
                             )
                          AND pod.po_header_id = poll.po_header_id
                          AND pod.line_location_id = poll.line_location_id
                       ) pohzd,
                         zx_po_rec_dist recdist
                   WHERE recdist.po_header_id(+) = pohzd.trx_id
                     AND recdist.po_line_location_id(+) = pohzd.trx_line_id
                     AND recdist.po_distribution_id(+) = pohzd.p_po_distribution_id
                     AND recdist.tax_rate_id(+) = pohzd.tax_rate_id
               ) pohzd,
               fnd_currencies fc,
               zx_rates_b rates,
               (SELECT 'Y' rec_flag FROM dual UNION ALL SELECT 'N' rec_flag FROM dual) tmp
         WHERE pohzd.trx_currency_code = fc.currency_code(+)
           AND rates.tax_regime_code(+) = pohzd.tax_regime_code
           AND rates.tax(+) = pohzd.tax
           AND rates.content_owner_id(+) = pohzd.content_owner_id
           AND rates.rate_type_code(+) = 'RECOVERY'
           AND rates.recovery_type_code(+) = 'STANDARD'
           AND rates.active_flag(+) = 'Y'
           AND rates.effective_from(+) <= sysdate
           --Bug 8724131
           --AND (rates.effective_to IS NULL OR rates.effective_to >= sysdate)
           --Bug 8752951
           AND pohzd.poll_last_update_date BETWEEN rates.effective_from AND NVL(rates.effective_to, pohzd.poll_last_update_date)
           AND rates.record_type_code(+) = 'MIGRATED'
           AND rates.percentage_rate(+) = NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate),0)
           AND rates.tax_rate_code(+) NOT LIKE 'AD_HOC_RECOVERY%';

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                   'Number of Rows Inserted = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;

  -- bug 5166217 : Do bulk migration for RELEASE
  --
  -- Insert data into zx_lines_det_factors
  --
    INSERT INTO ZX_LINES_DET_FACTORS (
            EVENT_ID
           ,ACCOUNT_CCID
           ,ACCOUNT_STRING
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           ,APPLICATION_DOC_STATUS
           ,APPLICATION_ID
           ,APPLIED_FROM_APPLICATION_ID
           ,APPLIED_FROM_ENTITY_CODE
           ,APPLIED_FROM_EVENT_CLASS_CODE
           ,APPLIED_FROM_LINE_ID
           ,APPLIED_FROM_TRX_ID
           ,APPLIED_FROM_TRX_LEVEL_TYPE
           ,APPLIED_TO_APPLICATION_ID
           ,APPLIED_TO_ENTITY_CODE
           ,APPLIED_TO_EVENT_CLASS_CODE
           ,APPLIED_TO_TRX_ID
           ,APPLIED_TO_TRX_LEVEL_TYPE
           ,APPLIED_TO_TRX_LINE_ID
           ,APPLIED_TO_TRX_NUMBER
           ,ASSESSABLE_VALUE
           ,ASSET_ACCUM_DEPRECIATION
           ,ASSET_COST
           ,ASSET_FLAG
           ,ASSET_NUMBER
           ,ASSET_TYPE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,BILL_FROM_LOCATION_ID
           ,BILL_FROM_PARTY_TAX_PROF_ID
           ,BILL_FROM_SITE_TAX_PROF_ID
           ,BILL_TO_LOCATION_ID
           ,BILL_TO_PARTY_TAX_PROF_ID
           ,BILL_TO_SITE_TAX_PROF_ID
           ,COMPOUNDING_TAX_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,CTRL_HDR_TX_APPL_FLAG
           ,CTRL_TOTAL_HDR_TX_AMT
           ,CTRL_TOTAL_LINE_TX_AMT
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,DEFAULT_TAXATION_COUNTRY
           ,DOC_EVENT_STATUS
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,DOCUMENT_SUB_TYPE
           ,ENTITY_CODE
           ,ESTABLISHMENT_ID
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,FIRST_PTY_ORG_ID
           ,HISTORICAL_FLAG
           ,HQ_ESTB_PARTY_TAX_PROF_ID
           ,INCLUSIVE_TAX_OVERRIDE_FLAG
           ,INPUT_TAX_CLASSIFICATION_CODE
           ,INTERNAL_ORG_LOCATION_ID
           ,INTERNAL_ORGANIZATION_ID
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
           ,LEDGER_ID
           ,LEGAL_ENTITY_ID
           ,LINE_AMT
           ,LINE_AMT_INCLUDES_TAX_FLAG
           ,LINE_CLASS
           ,LINE_INTENDED_USE
           ,LINE_LEVEL_ACTION
           ,MERCHANT_PARTY_COUNTRY
           ,MERCHANT_PARTY_DOCUMENT_NUMBER
           ,MERCHANT_PARTY_ID
           ,MERCHANT_PARTY_NAME
           ,MERCHANT_PARTY_REFERENCE
           ,MERCHANT_PARTY_TAX_PROF_ID
           ,MERCHANT_PARTY_TAX_REG_NUMBER
           ,MERCHANT_PARTY_TAXPAYER_ID
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,OBJECT_VERSION_NUMBER
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           ,PORT_OF_ENTRY_CODE
           ,PRECISION
           ,PRODUCT_CATEGORY
           ,PRODUCT_CODE
           ,PRODUCT_DESCRIPTION
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ID
           ,PRODUCT_ORG_ID
           ,PRODUCT_TYPE
           ,RECORD_TYPE_CODE
           ,REF_DOC_APPLICATION_ID
           ,REF_DOC_ENTITY_CODE
           ,REF_DOC_EVENT_CLASS_CODE
           ,REF_DOC_LINE_ID
           ,REF_DOC_LINE_QUANTITY
           ,REF_DOC_TRX_ID
           ,REF_DOC_TRX_LEVEL_TYPE
           ,RELATED_DOC_APPLICATION_ID
           ,RELATED_DOC_DATE
           ,RELATED_DOC_ENTITY_CODE
           ,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_NUMBER
           ,RELATED_DOC_TRX_ID
           ,SHIP_FROM_LOCATION_ID
           ,SHIP_FROM_PARTY_TAX_PROF_ID
           ,SHIP_FROM_SITE_TAX_PROF_ID
           ,SHIP_TO_LOCATION_ID
           ,SHIP_TO_PARTY_TAX_PROF_ID
           ,SHIP_TO_SITE_TAX_PROF_ID
           ,SOURCE_APPLICATION_ID
           ,SOURCE_ENTITY_CODE
           ,SOURCE_EVENT_CLASS_CODE
           ,SOURCE_LINE_ID
           ,SOURCE_TRX_ID
           ,SOURCE_TRX_LEVEL_TYPE
           ,START_EXPENSE_DATE
           ,SUPPLIER_EXCHANGE_RATE
           ,SUPPLIER_TAX_INVOICE_DATE
           ,SUPPLIER_TAX_INVOICE_NUMBER
           ,TAX_AMT_INCLUDED_FLAG
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,TAX_PROCESSING_COMPLETED_FLAG
           ,TAX_REPORTING_FLAG
           ,THRESHOLD_INDICATOR_FLAG
           ,TRX_BUSINESS_CATEGORY
           ,TRX_COMMUNICATED_DATE
           ,TRX_CURRENCY_CODE
           ,TRX_DATE
           ,TRX_DESCRIPTION
           ,TRX_DUE_DATE
           ,TRX_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_DATE
           ,TRX_LINE_DESCRIPTION
           ,TRX_LINE_GL_DATE
           ,TRX_LINE_ID
           ,TRX_LINE_NUMBER
           ,TRX_LINE_QUANTITY
           ,TRX_LINE_TYPE
           ,TRX_NUMBER
           ,TRX_RECEIPT_DATE
           ,TRX_SHIPPING_DATE
           ,TRX_TYPE_DESCRIPTION
           ,UNIT_PRICE
           ,UOM_CODE
           ,USER_DEFINED_FISC_CLASS
           ,USER_UPD_DET_FACTORS_FLAG
           ,EVENT_CLASS_MAPPING_ID
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,ICX_SESSION_ID
           ,TRX_LINE_CURRENCY_CODE
           ,TRX_LINE_CURRENCY_CONV_RATE
           ,TRX_LINE_CURRENCY_CONV_DATE
           ,TRX_LINE_PRECISION
           ,TRX_LINE_MAU
           ,TRX_LINE_CURRENCY_CONV_TYPE
           ,INTERFACE_ENTITY_CODE
           ,INTERFACE_LINE_ID
           ,SOURCE_TAX_LINE_ID
           ,TAX_CALCULATION_DONE_FLAG
           ,LINE_TRX_USER_KEY1
           ,LINE_TRX_USER_KEY2
           ,LINE_TRX_USER_KEY3
         )
          SELECT /*+ ORDERED NO_EXPAND use_nl(fc, pol, poll, ptp, hr) */
           NULL 			    EVENT_ID,
           NULL 			    ACCOUNT_CCID,
           NULL 			    ACCOUNT_STRING,
           NULL 			    ADJUSTED_DOC_APPLICATION_ID,
           NULL 			    ADJUSTED_DOC_DATE,
           NULL 			    ADJUSTED_DOC_ENTITY_CODE,
           NULL 			    ADJUSTED_DOC_EVENT_CLASS_CODE,
           NULL 			    ADJUSTED_DOC_LINE_ID,
           NULL 			    ADJUSTED_DOC_NUMBER,
           NULL 			    ADJUSTED_DOC_TRX_ID,
           NULL 			    ADJUSTED_DOC_TRX_LEVEL_TYPE,
           NULL 			    APPLICATION_DOC_STATUS,
           201 			            APPLICATION_ID,
           NULL 			    APPLIED_FROM_APPLICATION_ID,
           NULL 			    APPLIED_FROM_ENTITY_CODE,
           NULL 			    APPLIED_FROM_EVENT_CLASS_CODE,
           NULL 			    APPLIED_FROM_LINE_ID,
           NULL 			    APPLIED_FROM_TRX_ID,
           NULL 			    APPLIED_FROM_TRX_LEVEL_TYPE,
           NULL 			    APPLIED_TO_APPLICATION_ID,
           NULL 			    APPLIED_TO_ENTITY_CODE,
           NULL 			    APPLIED_TO_EVENT_CLASS_CODE,
           NULL 			    APPLIED_TO_TRX_ID,
           NULL 			    APPLIED_TO_TRX_LEVEL_TYPE,
           NULL 			    APPLIED_TO_TRX_LINE_ID,
           NULL 			    APPLIED_TO_TRX_NUMBER,
           NULL 			    ASSESSABLE_VALUE,
           NULL 			    ASSET_ACCUM_DEPRECIATION,
           NULL 			    ASSET_COST,
           NULL 			    ASSET_FLAG,
           NULL 			    ASSET_NUMBER,
           NULL 			    ASSET_TYPE,
           NULL 			    BATCH_SOURCE_ID,
           NULL 			    BATCH_SOURCE_NAME,
           NULL 			    BILL_FROM_LOCATION_ID,
           NULL 			    BILL_FROM_PARTY_TAX_PROF_ID,
           NULL 			    BILL_FROM_SITE_TAX_PROF_ID,
           NULL 			    BILL_TO_LOCATION_ID,
           NULL 			    BILL_TO_PARTY_TAX_PROF_ID,
           NULL 			    BILL_TO_SITE_TAX_PROF_ID,
           'N' 			            COMPOUNDING_TAX_FLAG,
           1   			            CREATED_BY,
           SYSDATE 		            CREATION_DATE,
           'N' 			            CTRL_HDR_TX_APPL_FLAG,
           NULL			            CTRL_TOTAL_HDR_TX_AMT,
           NULL	 		            CTRL_TOTAL_LINE_TX_AMT,
           poll.poh_rate_date 		    CURRENCY_CONVERSION_DATE,
           poll.poh_rate 		    CURRENCY_CONVERSION_RATE,
           poll.poh_rate_type 		    CURRENCY_CONVERSION_TYPE,
           NULL 			    DEFAULT_TAXATION_COUNTRY,
           NULL 			    DOC_EVENT_STATUS,
           NULL 			    DOC_SEQ_ID,
           NULL 			    DOC_SEQ_NAME,
           NULL 			    DOC_SEQ_VALUE,
           NULL 			    DOCUMENT_SUB_TYPE,
           'RELEASE' 		            ENTITY_CODE,
           NULL                             ESTABLISHMENT_ID,
           'RELEASE' 	                    EVENT_CLASS_CODE,
           'PURCHASE ORDER CREATED'         EVENT_TYPE_CODE,
           ptp.party_tax_profile_id	    FIRST_PTY_ORG_ID,
           'Y' 			            HISTORICAL_FLAG,
           NULL	 		            HQ_ESTB_PARTY_TAX_PROF_ID,
           'N' 			            INCLUSIVE_TAX_OVERRIDE_FLAG,
           (select name
	    from ap_tax_codes_all
	    where tax_id = poll.tax_code_id) INPUT_TAX_CLASSIFICATION_CODE,
           NULL 			    INTERNAL_ORG_LOCATION_ID,
           nvl(poll.poh_org_id,-99) 	    INTERNAL_ORGANIZATION_ID,
           SYSDATE 		            LAST_UPDATE_DATE,
           1 			            LAST_UPDATE_LOGIN,
           1 			            LAST_UPDATED_BY,
           poll.fsp_set_of_books_id 	    LEDGER_ID,
           NVL(poll.oi_org_information2,-99) LEGAL_ENTITY_ID,
           DECODE(pol.purchase_basis,
            'TEMP LABOR', NVL(POLL.amount,0),
            'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                               NVL(poll.quantity,0) *
                               NVL(poll.price_override,NVL(pol.unit_price,0))),
             NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                            LINE_AMT,
           'N' 			            LINE_AMT_INCLUDES_TAX_FLAG,
           'INVOICE' 		            LINE_CLASS,
           NULL 			    LINE_INTENDED_USE,
           'CREATE' 		            LINE_LEVEL_ACTION,
           NULL 			    MERCHANT_PARTY_COUNTRY,
           NULL 			    MERCHANT_PARTY_DOCUMENT_NUMBER,
           NULL 			    MERCHANT_PARTY_ID,
           NULL 			    MERCHANT_PARTY_NAME,
           NULL 			    MERCHANT_PARTY_REFERENCE,
           NULL 			    MERCHANT_PARTY_TAX_PROF_ID,
           NULL 			    MERCHANT_PARTY_TAX_REG_NUMBER,
           NULL 			    MERCHANT_PARTY_TAXPAYER_ID,
           fc.minimum_accountable_unit      MINIMUM_ACCOUNTABLE_UNIT,
           1 			            OBJECT_VERSION_NUMBER,
           NULL 			    OUTPUT_TAX_CLASSIFICATION_CODE,
           NULL 			    PORT_OF_ENTRY_CODE,
           NVL(fc.precision, 0)             PRECISION,
           -- fc.precision 		    PRECISION,
           NULL 			    PRODUCT_CATEGORY,
           NULL 			    PRODUCT_CODE,
           NULL 			    PRODUCT_DESCRIPTION,
           NULL 			    PRODUCT_FISC_CLASSIFICATION,
           pol.item_id		            PRODUCT_ID,
           poll.ship_to_organization_id	    PRODUCT_ORG_ID,
           DECODE(UPPER(pol.purchase_basis),
                  'GOODS', 'GOODS',
                  'SERVICES', 'SERVICES',
                  'TEMP LABOR','SERVICES',
                  'GOODS') 		    PRODUCT_TYPE,
           'MIGRATED' 		            RECORD_TYPE_CODE,
           NULL 			    REF_DOC_APPLICATION_ID,
           NULL 			    REF_DOC_ENTITY_CODE,
           NULL 			    REF_DOC_EVENT_CLASS_CODE,
           NULL 			    REF_DOC_LINE_ID,
           NULL 			    REF_DOC_LINE_QUANTITY,
           NULL 			    REF_DOC_TRX_ID,
           NULL 			    REF_DOC_TRX_LEVEL_TYPE,
           NULL 			    RELATED_DOC_APPLICATION_ID,
           NULL 			    RELATED_DOC_DATE,
           NULL 			    RELATED_DOC_ENTITY_CODE,
           NULL 			    RELATED_DOC_EVENT_CLASS_CODE,
           NULL 			    RELATED_DOC_NUMBER,
           NULL 			    RELATED_DOC_TRX_ID,
           NULL 			    SHIP_FROM_LOCATION_ID,
           NULL 			    SHIP_FROM_PARTY_TAX_PROF_ID,
           NULL 			    SHIP_FROM_SITE_TAX_PROF_ID,
           poll.ship_to_location_id         SHIP_TO_LOCATION_ID,
           NULL 			    SHIP_TO_PARTY_TAX_PROF_ID,
           NULL 			    SHIP_TO_SITE_TAX_PROF_ID,
           NULL 			    SOURCE_APPLICATION_ID,
           NULL 			    SOURCE_ENTITY_CODE,
           NULL 			    SOURCE_EVENT_CLASS_CODE,
           NULL 			    SOURCE_LINE_ID,
           NULL 			    SOURCE_TRX_ID,
           NULL 			    SOURCE_TRX_LEVEL_TYPE,
           NULL 			    START_EXPENSE_DATE,
           NULL 			    SUPPLIER_EXCHANGE_RATE,
           NULL 			    SUPPLIER_TAX_INVOICE_DATE,
           NULL 			    SUPPLIER_TAX_INVOICE_NUMBER,
           'N' 			            TAX_AMT_INCLUDED_FLAG,
           'PURCHASE_TRANSACTION' 	    TAX_EVENT_CLASS_CODE,
           'VALIDATE'  		            TAX_EVENT_TYPE_CODE,
           NULL 			    TAX_INVOICE_DATE,
           NULL 			    TAX_INVOICE_NUMBER,
           'Y'			            TAX_PROCESSING_COMPLETED_FLAG,
           'N'			            TAX_REPORTING_FLAG,
           'N' 			            THRESHOLD_INDICATOR_FLAG,
           NULL 			    TRX_BUSINESS_CATEGORY,
           NULL 			    TRX_COMMUNICATED_DATE,
           NVL(poll.poh_currency_code,
               poll.aps_base_currency_code) TRX_CURRENCY_CODE,
           poll.poh_last_update_date 	    TRX_DATE,
           NULL 			    TRX_DESCRIPTION,
           NULL 			    TRX_DUE_DATE,
           poll.po_release_id     TRX_ID,
           'SHIPMENT' 			    TRX_LEVEL_TYPE,
           poll.LAST_UPDATE_DATE  	    TRX_LINE_DATE,
           NULL 			    TRX_LINE_DESCRIPTION,
           poll.LAST_UPDATE_DATE 	    TRX_LINE_GL_DATE,
           poll.line_location_id 	    TRX_LINE_ID,
           poll.SHIPMENT_NUM 	            TRX_LINE_NUMBER,
           poll.quantity 		    TRX_LINE_QUANTITY,
           'ITEM' 			    TRX_LINE_TYPE,
           poll.poh_segment1 		    TRX_NUMBER,
           NULL 			    TRX_RECEIPT_DATE,
           NULL 			    TRX_SHIPPING_DATE,
           NULL 			    TRX_TYPE_DESCRIPTION,
           NVL(poll.price_override,
                           pol.unit_price)  UNIT_PRICE,
           NULL 			    UOM_CODE,
           NULL 			    USER_DEFINED_FISC_CLASS,
           'N' 			            USER_UPD_DET_FACTORS_FLAG,
           12			            EVENT_CLASS_MAPPING_ID,
           poll.GLOBAL_ATTRIBUTE_CATEGORY   GLOBAL_ATTRIBUTE_CATEGORY,
           poll.GLOBAL_ATTRIBUTE1 	    GLOBAL_ATTRIBUTE1 	   ,
           NULL                             ICX_SESSION_ID,
           NULL                             TRX_LINE_CURRENCY_CODE,
           NULL                             TRX_LINE_CURRENCY_CONV_RATE,
           NULL                             TRX_LINE_CURRENCY_CONV_DATE,
           NULL                             TRX_LINE_PRECISION,
           NULL                             TRX_LINE_MAU,
           NULL                             TRX_LINE_CURRENCY_CONV_TYPE,
           NULL                             INTERFACE_ENTITY_CODE,
           NULL                             INTERFACE_LINE_ID,
           NULL                             SOURCE_TAX_LINE_ID,
           'Y'                              TAX_CALCULATION_DONE_FLAG,
           pol.line_num                     LINE_TRX_USER_KEY1,
           hr.location_code                 LINE_TRX_USER_KEY2,
           DECODE(poll.payment_type,
                   NULL, 0, 'DELIVERY',
                   1,'ADVANCE', 2, 3)       LINE_TRX_USER_KEY3
     FROM (SELECT /*+ NO_MERGE swap_join_inputs(fsp) swap_join_inputs(aps)
                       swap_join_inputs(oi) index(aps AP_SYSTEM_PARAMETERS_U1) */
                   poll.*,
                   poh.rate_date 	       poh_rate_date,
                   poh.rate 	       poh_rate,
                   poh.rate_type 	       poh_rate_type,
                   poh.org_id              poh_org_id,
                   poh.currency_code       poh_currency_code,
                   poh.last_update_date    poh_last_update_date,
                   poh.segment1            poh_segment1,
                   fsp.set_of_books_id     fsp_set_of_books_id,
                   aps.base_currency_code  aps_base_currency_code,
                   oi.org_information2     oi_org_information2
       	     FROM  (select distinct other_doc_application_id, other_doc_trx_id
       	              from ZX_VALIDATION_ERRORS_GT
       	             where other_doc_application_id = 201
       	               and other_doc_entity_code = 'RELEASE'
       	               and other_doc_event_class_code = 'RELEASE'
       	           ) zxvalerr,
                   po_line_locations_all poll,
       	           po_headers_all poh,
                   financials_system_params_all fsp,
                   ap_system_parameters_all aps,
                   hr_organization_information oi
    	    WHERE poll.po_release_id = zxvalerr.other_doc_trx_id
       	      AND poh.po_header_id = poll.po_header_id
                  AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                  AND aps.set_of_books_id = fsp.set_of_books_id
              AND NVL(aps.org_id, -99) = NVL(poh.org_id, -99)
              AND oi.organization_id(+) = poh.org_id
              AND oi.org_information_context(+) = 'Operating Unit Information'
           ) poll,
           fnd_currencies fc,
           po_lines_all pol,
           zx_party_tax_profile ptp,
           hr_locations_all hr
     WHERE NVL(poll.poh_currency_code, poll.aps_base_currency_code) = fc.currency_code(+)
       AND pol.po_header_id = poll.po_header_id
       AND pol.po_line_id = poll.po_line_id
       AND hr.location_id(+) = poll.ship_to_location_id
       AND NOT EXISTS
           (SELECT 1 FROM zx_transaction_lines_gt lines_gt
              WHERE lines_gt.application_id   = 201
                AND lines_gt.event_class_code = 'RELEASE'
                AND lines_gt.entity_code      = 'RELEASE'
                AND lines_gt.trx_id           = poll.po_release_id
                AND lines_gt.trx_line_id      = poll.line_location_id
                AND lines_gt.trx_level_type   = 'SHIPMENT'
                AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
           )
       AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
       AND ptp.party_type_code = 'OU';

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                   'Number of Rows Inserted = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;

  -- COMMIT;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk_po',
                   'Inserting data into zx_lines(Tax Code)');
  END IF;

  -- Insert data into zx_lines
  --

    INSERT INTO ZX_LINES(
                ADJUSTED_DOC_APPLICATION_ID
               ,ADJUSTED_DOC_DATE
               ,ADJUSTED_DOC_ENTITY_CODE
               ,ADJUSTED_DOC_EVENT_CLASS_CODE
               ,ADJUSTED_DOC_LINE_ID
               ,ADJUSTED_DOC_NUMBER
               ,ADJUSTED_DOC_TAX_LINE_ID
               ,ADJUSTED_DOC_TRX_ID
               ,ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,APPLICATION_ID
               ,APPLIED_FROM_APPLICATION_ID
               ,APPLIED_FROM_ENTITY_CODE
               ,APPLIED_FROM_EVENT_CLASS_CODE
               ,APPLIED_FROM_LINE_ID
               ,APPLIED_FROM_TRX_ID
               ,APPLIED_FROM_TRX_LEVEL_TYPE
               ,APPLIED_FROM_TRX_NUMBER
               ,APPLIED_TO_APPLICATION_ID
               ,APPLIED_TO_ENTITY_CODE
               ,APPLIED_TO_EVENT_CLASS_CODE
               ,APPLIED_TO_LINE_ID
               ,APPLIED_TO_TRX_ID
               ,APPLIED_TO_TRX_LEVEL_TYPE
               ,APPLIED_TO_TRX_NUMBER
               ,ASSOCIATED_CHILD_FROZEN_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,BASIS_RESULT_ID
               ,CAL_TAX_AMT
               ,CAL_TAX_AMT_FUNCL_CURR
               ,CAL_TAX_AMT_TAX_CURR
               ,CALC_RESULT_ID
               ,CANCEL_FLAG
               ,CHAR1
               ,CHAR10
               ,CHAR2
               ,CHAR3
               ,CHAR4
               ,CHAR5
               ,CHAR6
               ,CHAR7
               ,CHAR8
               ,CHAR9
               ,COMPOUNDING_DEP_TAX_FLAG
               ,COMPOUNDING_TAX_FLAG
               ,COMPOUNDING_TAX_MISS_FLAG
               ,CONTENT_OWNER_ID
               ,COPIED_FROM_OTHER_DOC_FLAG
               ,CREATED_BY
               ,CREATION_DATE
               ,CTRL_TOTAL_LINE_TX_AMT
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,DATE1
               ,DATE10
               ,DATE2
               ,DATE3
               ,DATE4
               ,DATE5
               ,DATE6
               ,DATE7
               ,DATE8
               ,DATE9
               ,DELETE_FLAG
               ,DIRECT_RATE_RESULT_ID
               ,DOC_EVENT_STATUS
               ,ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,ENTITY_CODE
               ,ESTABLISHMENT_ID
               ,EVAL_EXCPT_RESULT_ID
               ,EVAL_EXMPT_RESULT_ID
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,EXCEPTION_RATE
               ,EXEMPT_CERTIFICATE_NUMBER
               ,EXEMPT_RATE_MODIFIER
               ,EXEMPT_REASON
               ,EXEMPT_REASON_CODE
               ,FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,GLOBAL_ATTRIBUTE_CATEGORY
               ,GLOBAL_ATTRIBUTE1
               ,GLOBAL_ATTRIBUTE10
               ,GLOBAL_ATTRIBUTE11
               ,GLOBAL_ATTRIBUTE12
               ,GLOBAL_ATTRIBUTE13
               ,GLOBAL_ATTRIBUTE14
               ,GLOBAL_ATTRIBUTE15
               ,GLOBAL_ATTRIBUTE2
               ,GLOBAL_ATTRIBUTE3
               ,GLOBAL_ATTRIBUTE4
               ,GLOBAL_ATTRIBUTE5
               ,GLOBAL_ATTRIBUTE6
               ,GLOBAL_ATTRIBUTE7
               ,GLOBAL_ATTRIBUTE8
               ,GLOBAL_ATTRIBUTE9
               ,HISTORICAL_FLAG
               ,HQ_ESTB_PARTY_TAX_PROF_ID
               ,HQ_ESTB_REG_NUMBER
               ,INTERFACE_ENTITY_CODE
               ,INTERFACE_TAX_LINE_ID
               ,INTERNAL_ORG_LOCATION_ID
               ,INTERNAL_ORGANIZATION_ID
               ,ITEM_DIST_CHANGED_FLAG
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,LEDGER_ID
               ,LEGAL_ENTITY_ID
               ,LEGAL_ENTITY_TAX_REG_NUMBER
               ,LEGAL_JUSTIFICATION_TEXT1
               ,LEGAL_JUSTIFICATION_TEXT2
               ,LEGAL_JUSTIFICATION_TEXT3
               ,LEGAL_MESSAGE_APPL_2
               ,LEGAL_MESSAGE_BASIS
               ,LEGAL_MESSAGE_CALC
               ,LEGAL_MESSAGE_EXCPT
               ,LEGAL_MESSAGE_EXMPT
               ,LEGAL_MESSAGE_POS
               ,LEGAL_MESSAGE_RATE
               ,LEGAL_MESSAGE_STATUS
               ,LEGAL_MESSAGE_THRESHOLD
               ,LEGAL_MESSAGE_TRN
               ,LINE_AMT
               ,LINE_ASSESSABLE_VALUE
               ,MANUALLY_ENTERED_FLAG
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,MRC_LINK_TO_TAX_LINE_ID
               ,MRC_TAX_LINE_FLAG
               ,NREC_TAX_AMT
               ,NREC_TAX_AMT_FUNCL_CURR
               ,NREC_TAX_AMT_TAX_CURR
               ,NUMERIC1
               ,NUMERIC10
               ,NUMERIC2
               ,NUMERIC3
               ,NUMERIC4
               ,NUMERIC5
               ,NUMERIC6
               ,NUMERIC7
               ,NUMERIC8
               ,NUMERIC9
               ,OBJECT_VERSION_NUMBER
               ,OFFSET_FLAG
               ,OFFSET_LINK_TO_TAX_LINE_ID
               ,OFFSET_TAX_RATE_CODE
               ,ORIG_SELF_ASSESSED_FLAG
               ,ORIG_TAX_AMT
               ,ORIG_TAX_AMT_INCLUDED_FLAG
               ,ORIG_TAX_AMT_TAX_CURR
               ,ORIG_TAX_JURISDICTION_CODE
               ,ORIG_TAX_JURISDICTION_ID
               ,ORIG_TAX_RATE
               ,ORIG_TAX_RATE_CODE
               ,ORIG_TAX_RATE_ID
               ,ORIG_TAX_STATUS_CODE
               ,ORIG_TAX_STATUS_ID
               ,ORIG_TAXABLE_AMT
               ,ORIG_TAXABLE_AMT_TAX_CURR
               ,OTHER_DOC_LINE_AMT
               ,OTHER_DOC_LINE_TAX_AMT
               ,OTHER_DOC_LINE_TAXABLE_AMT
               ,OTHER_DOC_SOURCE
               ,OVERRIDDEN_FLAG
               ,PLACE_OF_SUPPLY
               ,PLACE_OF_SUPPLY_RESULT_ID
               ,PLACE_OF_SUPPLY_TYPE_CODE
               ,PRD_TOTAL_TAX_AMT
               ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,PRD_TOTAL_TAX_AMT_TAX_CURR
               ,PRECISION
               ,PROCESS_FOR_RECOVERY_FLAG
               ,PRORATION_CODE
               ,PURGE_FLAG
               ,RATE_RESULT_ID
               ,REC_TAX_AMT
               ,REC_TAX_AMT_FUNCL_CURR
               ,REC_TAX_AMT_TAX_CURR
               ,RECALC_REQUIRED_FLAG
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_LINE_QUANTITY
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,REGISTRATION_PARTY_TYPE
               ,RELATED_DOC_APPLICATION_ID
               ,RELATED_DOC_DATE
               ,RELATED_DOC_ENTITY_CODE
               ,RELATED_DOC_EVENT_CLASS_CODE
               ,RELATED_DOC_NUMBER
               ,RELATED_DOC_TRX_ID
               ,RELATED_DOC_TRX_LEVEL_TYPE
               ,REPORTING_CURRENCY_CODE
               ,REPORTING_ONLY_FLAG
               ,REPORTING_PERIOD_ID
               ,ROUNDING_LEVEL_CODE
               ,ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,ROUNDING_LVL_PARTY_TYPE
               ,ROUNDING_RULE_CODE
               ,SELF_ASSESSED_FLAG
               ,SETTLEMENT_FLAG
               ,STATUS_RESULT_ID
               ,SUMMARY_TAX_LINE_ID
               ,SYNC_WITH_PRVDR_FLAG
               ,TAX
               ,TAX_AMT
               ,TAX_AMT_FUNCL_CURR
               ,TAX_AMT_INCLUDED_FLAG
               ,TAX_AMT_TAX_CURR
               ,TAX_APPLICABILITY_RESULT_ID
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_BASE_MODIFIER_RATE
               ,TAX_CALCULATION_FORMULA
               ,TAX_CODE
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_DATE
               ,TAX_DATE_RULE_ID
               ,TAX_DETERMINE_DATE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_EXCEPTION_ID
               ,TAX_EXEMPTION_ID
               ,TAX_HOLD_CODE
               ,TAX_HOLD_RELEASED_CODE
               ,TAX_ID
               ,TAX_JURISDICTION_CODE
               ,TAX_JURISDICTION_ID
               ,TAX_LINE_ID
               ,TAX_LINE_NUMBER
               ,TAX_ONLY_LINE_FLAG
               ,TAX_POINT_DATE
               ,TAX_PROVIDER_ID
               ,TAX_RATE
               ,TAX_RATE_BEFORE_EXCEPTION
               ,TAX_RATE_BEFORE_EXEMPTION
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_RATE_NAME_BEFORE_EXCEPTION
               ,TAX_RATE_NAME_BEFORE_EXEMPTION
               ,TAX_RATE_TYPE
               ,TAX_REG_NUM_DET_RESULT_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_REGIME_TEMPLATE_ID
               ,TAX_REGISTRATION_ID
               ,TAX_REGISTRATION_NUMBER
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TAX_TYPE_CODE
               ,TAXABLE_AMT
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TAXABLE_BASIS_FORMULA
               ,TAXING_JURIS_GEOGRAPHY_ID
               ,THRESH_RESULT_ID
               ,TRX_CURRENCY_CODE
               ,TRX_DATE
               ,TRX_ID
               ,TRX_ID_LEVEL2
               ,TRX_ID_LEVEL3
               ,TRX_ID_LEVEL4
               ,TRX_ID_LEVEL5
               ,TRX_ID_LEVEL6
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_DATE
               ,TRX_LINE_ID
               ,TRX_LINE_INDEX
               ,TRX_LINE_NUMBER
               ,TRX_LINE_QUANTITY
               ,TRX_NUMBER
               ,TRX_USER_KEY_LEVEL1
               ,TRX_USER_KEY_LEVEL2
               ,TRX_USER_KEY_LEVEL3
               ,TRX_USER_KEY_LEVEL4
               ,TRX_USER_KEY_LEVEL5
               ,TRX_USER_KEY_LEVEL6
               ,UNIT_PRICE
               ,UNROUNDED_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,MULTIPLE_JURISDICTIONS_FLAG)
        SELECT /*+ leading(poh) NO_EXPAND
                   use_nl(fc,pol,poll,ptp,atc,rates,regimes,taxes,status) */
                NULL 	                           ADJUSTED_DOC_APPLICATION_ID
               ,NULL 	                           ADJUSTED_DOC_DATE
               ,NULL	                           ADJUSTED_DOC_ENTITY_CODE
               ,NULL                               ADJUSTED_DOC_EVENT_CLASS_CODE
               ,NULL                               ADJUSTED_DOC_LINE_ID
               ,NULL                               ADJUSTED_DOC_NUMBER
               ,NULL                               ADJUSTED_DOC_TAX_LINE_ID
               ,NULL                               ADJUSTED_DOC_TRX_ID
               ,NULL                               ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,201	                           APPLICATION_ID
               ,NULL                               APPLIED_FROM_APPLICATION_ID
               ,NULL                               APPLIED_FROM_ENTITY_CODE
               ,NULL                               APPLIED_FROM_EVENT_CLASS_CODE
               ,NULL                               APPLIED_FROM_LINE_ID
               ,NULL                               APPLIED_FROM_TRX_ID
               ,NULL                               APPLIED_FROM_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_FROM_TRX_NUMBER
               ,NULL	                           APPLIED_TO_APPLICATION_ID
               ,NULL	                           APPLIED_TO_ENTITY_CODE
               ,NULL	                           APPLIED_TO_EVENT_CLASS_CODE
               ,NULL	                           APPLIED_TO_LINE_ID
               ,NULL	                           APPLIED_TO_TRX_ID
               ,NULL	                           APPLIED_TO_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_TO_TRX_NUMBER
               ,'N' 	                           ASSOCIATED_CHILD_FROZEN_FLAG
               ,poll.ATTRIBUTE_CATEGORY            ATTRIBUTE_CATEGORY
               ,poll.ATTRIBUTE1 	           ATTRIBUTE1
               ,poll.ATTRIBUTE10	           ATTRIBUTE10
               ,poll.ATTRIBUTE11	           ATTRIBUTE11
               ,poll.ATTRIBUTE12	           ATTRIBUTE12
               ,poll.ATTRIBUTE13	           ATTRIBUTE13
               ,poll.ATTRIBUTE14	           ATTRIBUTE14
               ,poll.ATTRIBUTE15	           ATTRIBUTE15
               ,poll.ATTRIBUTE2 	           ATTRIBUTE2
               ,poll.ATTRIBUTE3 	           ATTRIBUTE3
               ,poll.ATTRIBUTE4 	           ATTRIBUTE4
               ,poll.ATTRIBUTE5 	           ATTRIBUTE5
               ,poll.ATTRIBUTE6 	           ATTRIBUTE6
               ,poll.ATTRIBUTE7 	           ATTRIBUTE7
               ,poll.ATTRIBUTE8 	           ATTRIBUTE8
               ,poll.ATTRIBUTE9 	           ATTRIBUTE9
               ,NULL			           BASIS_RESULT_ID
               ,NULL	                           CAL_TAX_AMT
               ,NULL	                           CAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           CAL_TAX_AMT_TAX_CURR
               ,NULL	                           CALC_RESULT_ID
               ,'N'	                           CANCEL_FLAG
               ,NULL	                           CHAR1
               ,NULL	                           CHAR10
               ,NULL	                           CHAR2
               ,NULL	                           CHAR3
               ,NULL	                           CHAR4
               ,NULL	                           CHAR5
               ,NULL	                           CHAR6
               ,NULL	                           CHAR7
               ,NULL	                           CHAR8
               ,NULL	                           CHAR9
               ,'N'	                           COMPOUNDING_DEP_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_MISS_FLAG
               ,ptp.party_tax_profile_id	   CONTENT_OWNER_ID
               ,'N'	                           COPIED_FROM_OTHER_DOC_FLAG
               ,1	                           CREATED_BY
               ,SYSDATE                            CREATION_DATE
               ,NULL		                   CTRL_TOTAL_LINE_TX_AMT
               ,poll.poh_rate_date 	           CURRENCY_CONVERSION_DATE
               ,poll.poh_rate 	                   CURRENCY_CONVERSION_RATE
               ,poll.poh_rate_type 	           CURRENCY_CONVERSION_TYPE
               ,NULL	                           DATE1
               ,NULL	                           DATE10
               ,NULL	                           DATE2
               ,NULL	                           DATE3
               ,NULL	                           DATE4
               ,NULL	                           DATE5
               ,NULL	                           DATE6
               ,NULL	                          DATE7
               ,NULL	                           DATE8
               ,NULL	                           DATE9
               ,'N'	                           DELETE_FLAG
               ,NULL	                           DIRECT_RATE_RESULT_ID
               ,NULL	                           DOC_EVENT_STATUS
               ,'N'	                           ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,'RELEASE'                          ENTITY_CODE
               ,NULL	                           ESTABLISHMENT_ID
               ,NULL	                           EVAL_EXCPT_RESULT_ID
               ,NULL	                           EVAL_EXMPT_RESULT_ID
               ,'RELEASE'                          EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	   EVENT_TYPE_CODE
               ,NULL                               EXCEPTION_RATE
               ,NULL	                           EXEMPT_CERTIFICATE_NUMBER
               ,NULL	                           EXEMPT_RATE_MODIFIER
               ,NULL	                           EXEMPT_REASON
               ,NULL	                           EXEMPT_REASON_CODE
               ,'N'	                           FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,poll.GLOBAL_ATTRIBUTE_CATEGORY     GLOBAL_ATTRIBUTE_CATEGORY
               ,poll.GLOBAL_ATTRIBUTE1 	           GLOBAL_ATTRIBUTE1
               ,poll.GLOBAL_ATTRIBUTE10	           GLOBAL_ATTRIBUTE10
               ,poll.GLOBAL_ATTRIBUTE11	           GLOBAL_ATTRIBUTE11
               ,poll.GLOBAL_ATTRIBUTE12	           GLOBAL_ATTRIBUTE12
               ,poll.GLOBAL_ATTRIBUTE13	           GLOBAL_ATTRIBUTE13
               ,poll.GLOBAL_ATTRIBUTE14	           GLOBAL_ATTRIBUTE14
               ,poll.GLOBAL_ATTRIBUTE15	           GLOBAL_ATTRIBUTE15
               ,poll.GLOBAL_ATTRIBUTE2             GLOBAL_ATTRIBUTE2
               ,poll.GLOBAL_ATTRIBUTE3             GLOBAL_ATTRIBUTE3
               ,poll.GLOBAL_ATTRIBUTE4             GLOBAL_ATTRIBUTE4
               ,poll.GLOBAL_ATTRIBUTE5             GLOBAL_ATTRIBUTE5
               ,poll.GLOBAL_ATTRIBUTE6             GLOBAL_ATTRIBUTE6
               ,poll.GLOBAL_ATTRIBUTE7             GLOBAL_ATTRIBUTE7
               ,poll.GLOBAL_ATTRIBUTE8             GLOBAL_ATTRIBUTE8
               ,poll.GLOBAL_ATTRIBUTE9             GLOBAL_ATTRIBUTE9
               ,'Y'	                           HISTORICAL_FLAG
               ,NULL                               HQ_ESTB_PARTY_TAX_PROF_ID
               ,NULL	                           HQ_ESTB_REG_NUMBER
               ,NULL	                           INTERFACE_ENTITY_CODE
               ,NULL	                           INTERFACE_TAX_LINE_ID
               ,NULL                               INTERNAL_ORG_LOCATION_ID
               ,NVL(poll.poh_org_id,-99)           INTERNAL_ORGANIZATION_ID
               ,'N'                                 ITEM_DIST_CHANGED_FLAG
               ,NULL	                           LAST_MANUAL_ENTRY
               ,SYSDATE	                           LAST_UPDATE_DATE
               ,1	                           LAST_UPDATE_LOGIN
               ,1	                           LAST_UPDATED_BY
               ,poll.fsp_set_of_books_id 	   LEDGER_ID
               ,NVL(poll.oi_org_information2, -99) LEGAL_ENTITY_ID
               ,NULL                               LEGAL_ENTITY_TAX_REG_NUMBER
               ,NULL                               LEGAL_JUSTIFICATION_TEXT1
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT2
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT3
               ,NULL                               LEGAL_MESSAGE_APPL_2
               ,NULL	                           LEGAL_MESSAGE_BASIS
               ,NULL	                           LEGAL_MESSAGE_CALC
               ,NULL	                           LEGAL_MESSAGE_EXCPT
               ,NULL	                           LEGAL_MESSAGE_EXMPT
               ,NULL	                           LEGAL_MESSAGE_POS
               ,NULL	                           LEGAL_MESSAGE_RATE
               ,NULL                               LEGAL_MESSAGE_STATUS
               ,NULL	                           LEGAL_MESSAGE_THRESHOLD
               ,NULL	                           LEGAL_MESSAGE_TRN
               ,DECODE(pol.purchase_basis,
                 'TEMP LABOR', NVL(POLL.amount,0),
                 'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                    NVL(poll.quantity,0) *
                                    NVL(poll.price_override,NVL(pol.unit_price,0))),
                  NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                                   LINE_AMT
               ,NULL	                           LINE_ASSESSABLE_VALUE
               ,'N'	                           MANUALLY_ENTERED_FLAG
               ,fc.minimum_accountable_unit	   MINIMUM_ACCOUNTABLE_UNIT
               ,NULL	                           MRC_LINK_TO_TAX_LINE_ID
               ,'N'	                           MRC_TAX_LINE_FLAG
               ,NULL	                           NREC_TAX_AMT
               ,NULL	                           NREC_TAX_AMT_FUNCL_CURR
               ,NULL	                           NREC_TAX_AMT_TAX_CURR
               ,NULL	                           NUMERIC1
               ,NULL	                           NUMERIC10
               ,NULL	                           NUMERIC2
               ,NULL	                           NUMERIC3
               ,NULL	                           NUMERIC4
               ,NULL	                           NUMERIC5
               ,NULL	                           NUMERIC6
               ,NULL	                           NUMERIC7
               ,NULL	                           NUMERIC8
               ,NULL	                           NUMERIC9
               ,1	                           OBJECT_VERSION_NUMBER
               ,'N'	                           OFFSET_FLAG
               ,NULL	                           OFFSET_LINK_TO_TAX_LINE_ID
               ,NULL	                           OFFSET_TAX_RATE_CODE
               ,'N'	                           ORIG_SELF_ASSESSED_FLAG
               ,NULL	                           ORIG_TAX_AMT
               ,NULL	                           ORIG_TAX_AMT_INCLUDED_FLAG
               ,NULL	                           ORIG_TAX_AMT_TAX_CURR
               ,NULL	                           ORIG_TAX_JURISDICTION_CODE
               ,NULL	                           ORIG_TAX_JURISDICTION_ID
               ,NULL	                           ORIG_TAX_RATE
               ,NULL	                           ORIG_TAX_RATE_CODE
               ,NULL	                           ORIG_TAX_RATE_ID
               ,NULL	                           ORIG_TAX_STATUS_CODE
               ,NULL	                           ORIG_TAX_STATUS_ID
               ,NULL	                           ORIG_TAXABLE_AMT
               ,NULL	                           ORIG_TAXABLE_AMT_TAX_CURR
               ,NULL	                           OTHER_DOC_LINE_AMT
               ,NULL	                           OTHER_DOC_LINE_TAX_AMT
               ,NULL	                           OTHER_DOC_LINE_TAXABLE_AMT
               ,NULL	                           OTHER_DOC_SOURCE
               ,'N'	                           OVERRIDDEN_FLAG
               ,NULL	                           PLACE_OF_SUPPLY
               ,NULL	                           PLACE_OF_SUPPLY_RESULT_ID
               ,NULL                               PLACE_OF_SUPPLY_TYPE_CODE
               ,NULL	                           PRD_TOTAL_TAX_AMT
               ,NULL	                           PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           PRD_TOTAL_TAX_AMT_TAX_CURR
               ,NVL(fc.precision, 0)               PRECISION
               ,'N'	                           PROCESS_FOR_RECOVERY_FLAG
               ,NULL	                           PRORATION_CODE
               ,'N'	                           PURGE_FLAG
               ,NULL	                           RATE_RESULT_ID
               ,NULL	                           REC_TAX_AMT
               ,NULL	                           REC_TAX_AMT_FUNCL_CURR
               ,NULL	                           REC_TAX_AMT_TAX_CURR
               ,'N'	                           RECALC_REQUIRED_FLAG
               ,'MIGRATED'                         RECORD_TYPE_CODE
               ,NULL	                           REF_DOC_APPLICATION_ID
               ,NULL	                           REF_DOC_ENTITY_CODE
               ,NULL	                           REF_DOC_EVENT_CLASS_CODE
               ,NULL	                           REF_DOC_LINE_ID
               ,NULL	                           REF_DOC_LINE_QUANTITY
               ,NULL	                           REF_DOC_TRX_ID
               ,NULL	                           REF_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REGISTRATION_PARTY_TYPE
               ,NULL	                           RELATED_DOC_APPLICATION_ID
               ,NULL	                           RELATED_DOC_DATE
               ,NULL	                           RELATED_DOC_ENTITY_CODE
               ,NULL	                           RELATED_DOC_EVENT_CLASS_CODE
               ,NULL	                           RELATED_DOC_NUMBER
               ,NULL	                           RELATED_DOC_TRX_ID
               ,NULL	                           RELATED_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REPORTING_CURRENCY_CODE
               ,'N'	                           REPORTING_ONLY_FLAG
               ,NULL	                           REPORTING_PERIOD_ID
               ,NULL	                           ROUNDING_LEVEL_CODE
               ,NULL	                           ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,NULL	                           ROUNDING_LVL_PARTY_TYPE
               ,NULL	                           ROUNDING_RULE_CODE
               ,'N'	                           SELF_ASSESSED_FLAG
               ,'N'                                SETTLEMENT_FLAG
               ,NULL                               STATUS_RESULT_ID
               ,NULL                               SUMMARY_TAX_LINE_ID
               ,NULL                               SYNC_WITH_PRVDR_FLAG
               ,rates.tax                          TAX
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)  TAX_AMT
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)
                                                   TAX_AMT_FUNCL_CURR
               ,'N'                                TAX_AMT_INCLUDED_FLAG
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(rates.percentage_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit) TAX_AMT_TAX_CURR
               ,NULL                               TAX_APPLICABILITY_RESULT_ID
               ,'Y'                                TAX_APPORTIONMENT_FLAG
               ,1                                  TAX_APPORTIONMENT_LINE_NUMBER
               ,NULL                               TAX_BASE_MODIFIER_RATE
               ,'STANDARD_TC'                      TAX_CALCULATION_FORMULA
               ,NULL                               TAX_CODE
               ,taxes.tax_currency_code            TAX_CURRENCY_CODE
               ,poll.poh_rate_date 		   TAX_CURRENCY_CONVERSION_DATE
               ,poll.poh_rate 		           TAX_CURRENCY_CONVERSION_RATE
               ,poll.poh_rate_type 		   TAX_CURRENCY_CONVERSION_TYPE
               ,poll.last_update_date              TAX_DATE
               ,NULL                               TAX_DATE_RULE_ID
               ,poll.last_update_date              TAX_DETERMINE_DATE
               ,'PURCHASE_TRANSACTION' 	           TAX_EVENT_CLASS_CODE
               ,'VALIDATE'  		           TAX_EVENT_TYPE_CODE
               ,NULL                               TAX_EXCEPTION_ID
               ,NULL                               TAX_EXEMPTION_ID
               ,NULL                               TAX_HOLD_CODE
               ,NULL                               TAX_HOLD_RELEASED_CODE
               ,taxes.tax_id                       TAX_ID
               ,NULL                               TAX_JURISDICTION_CODE
               ,NULL                               TAX_JURISDICTION_ID
               ,zx_lines_s.nextval                 TAX_LINE_ID
               ,RANK() OVER
                 (PARTITION BY poll.po_release_id
                  ORDER BY poll.line_location_id,
                           atc.tax_id)             TAX_LINE_NUMBER
               ,'N'                                TAX_ONLY_LINE_FLAG
               ,poll.last_update_date              TAX_POINT_DATE
               ,NULL                               TAX_PROVIDER_ID
               ,rates.percentage_rate  	           TAX_RATE
               ,NULL	                           TAX_RATE_BEFORE_EXCEPTION
               ,NULL                               TAX_RATE_BEFORE_EXEMPTION
               ,rates.tax_rate_code                TAX_RATE_CODE
               ,rates.tax_rate_id                  TAX_RATE_ID
               ,NULL                               TAX_RATE_NAME_BEFORE_EXCEPTION
               ,NULL                               TAX_RATE_NAME_BEFORE_EXEMPTION
               ,NULL                               TAX_RATE_TYPE
               ,NULL                               TAX_REG_NUM_DET_RESULT_ID
               ,rates.tax_regime_code              TAX_REGIME_CODE
               ,regimes.tax_regime_id              TAX_REGIME_ID
               ,NULL                               TAX_REGIME_TEMPLATE_ID
               ,NULL                               TAX_REGISTRATION_ID
               ,NULL                               TAX_REGISTRATION_NUMBER
               ,rates.tax_status_code              TAX_STATUS_CODE
               ,status.tax_status_id               TAX_STATUS_ID
               ,NULL                               TAX_TYPE_CODE
               ,NULL                               TAXABLE_AMT
               ,NULL                               TAXABLE_AMT_FUNCL_CURR
               ,NULL                               TAXABLE_AMT_TAX_CURR
               ,'STANDARD_TB'                      TAXABLE_BASIS_FORMULA
               ,NULL                               TAXING_JURIS_GEOGRAPHY_ID
               ,NULL                               THRESH_RESULT_ID
               ,NVL(poll.poh_currency_code,
                    poll.aps_base_currency_code)   TRX_CURRENCY_CODE
               ,poll.poh_last_update_date          TRX_DATE
               ,poll.po_release_id TRX_ID
               ,NULL                               TRX_ID_LEVEL2
               ,NULL                               TRX_ID_LEVEL3
               ,NULL                               TRX_ID_LEVEL4
               ,NULL                               TRX_ID_LEVEL5
               ,NULL                               TRX_ID_LEVEL6
               ,'SHIPMENT'                         TRX_LEVEL_TYPE
               ,poll.LAST_UPDATE_DATE              TRX_LINE_DATE
               ,poll.line_location_id              TRX_LINE_ID
               ,NULL                               TRX_LINE_INDEX
               ,poll.SHIPMENT_NUM                  TRX_LINE_NUMBER
               ,poll.quantity 		           TRX_LINE_QUANTITY
               ,poll.poh_segment1                  TRX_NUMBER
               ,NULL                               TRX_USER_KEY_LEVEL1
               ,NULL                               TRX_USER_KEY_LEVEL2
               ,NULL                               TRX_USER_KEY_LEVEL3
               ,NULL                               TRX_USER_KEY_LEVEL4
               ,NULL                               TRX_USER_KEY_LEVEL5
               ,NULL                               TRX_USER_KEY_LEVEL6
               ,NVL(poll.price_override,
                     pol.unit_price)               UNIT_PRICE
               ,NULL                               UNROUNDED_TAX_AMT
               ,NULL                               UNROUNDED_TAXABLE_AMT
               ,'N'                                MULTIPLE_JURISDICTIONS_FLAG
          FROM (SELECT /*+ NO_MERGE NO_EXPAND use_hash(fsp) use_hash(aps)
                       swap_join_inputs(fsp) swap_join_inputs(aps)
                       swap_join_inputs(oi) */
                       poll.*,
                       poh.rate_date 	       poh_rate_date,
                       poh.rate 	       poh_rate,
                       poh.rate_type 	       poh_rate_type,
                       poh.org_id              poh_org_id,
                       poh.currency_code       poh_currency_code,
                       poh.last_update_date    poh_last_update_date,
                       poh.segment1            poh_segment1,
                       fsp.set_of_books_id     fsp_set_of_books_id,
                       fsp.org_id              fsp_org_id,
                       aps.base_currency_code  aps_base_currency_code,
                       oi.org_information2     oi_org_information2
                  FROM (select distinct other_doc_application_id, other_doc_trx_id
             	          from ZX_VALIDATION_ERRORS_GT
             	         where other_doc_application_id = 201
             	           and other_doc_entity_code = 'RELEASE'
             	           and other_doc_event_class_code = 'RELEASE'
             	       ) zxvalerr,
                         po_line_locations_all poll,
                         po_headers_all poh,
             	         financials_system_params_all fsp,
          	         ap_system_parameters_all aps,
          	         hr_organization_information oi
                   WHERE poll.po_release_id = zxvalerr.other_doc_trx_id
                     AND poh.po_header_id = poll.po_header_id
                     AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                     AND NVL(aps.org_id, -99) = NVL(poh.org_id,-99)
                     AND aps.set_of_books_id = fsp.set_of_books_id
                     AND oi.organization_id(+) = poh.org_id
                     AND oi.org_information_context(+) = 'Operating Unit Information'
                ) poll,
                fnd_currencies fc,
                po_lines_all pol,
                zx_party_tax_profile ptp,
                ap_tax_codes_all atc,
                zx_rates_b rates,
                zx_regimes_b regimes,
                zx_taxes_b taxes,
                zx_status_b status
          WHERE NVL(poll.poh_currency_code, poll.aps_base_currency_code) = fc.currency_code(+)
            AND pol.po_header_id = poll.po_header_id
            AND pol.po_line_id = poll.po_line_id
            AND NOT EXISTS
                (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                   WHERE lines_gt.application_id   = 201
                     AND lines_gt.event_class_code = 'RELEASE'
                     AND lines_gt.entity_code      = 'RELEASE'
                     AND lines_gt.trx_id           = poll.po_release_id
                     AND lines_gt.trx_line_id      = poll.line_location_id
                     AND lines_gt.trx_level_type   = 'SHIPMENT'
                     AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
                )
            AND nvl(atc.org_id,-99)=nvl(poll.fsp_org_id,-99)
            AND poll.tax_code_id = atc.tax_id
            AND atc.tax_type NOT IN ('TAX_GROUP','USE')
            AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
            AND ptp.party_type_code = 'OU'
            AND rates.source_id = atc.tax_id
            AND regimes.tax_regime_code(+) = rates.tax_regime_code
            AND taxes.tax_regime_code(+) = rates.tax_regime_code
            AND taxes.tax(+) = rates.tax
            AND taxes.content_owner_id(+) = rates.content_owner_id
            AND status.tax_regime_code(+) = rates.tax_regime_code
            AND status.tax(+) = rates.tax
            AND status.content_owner_id(+) = rates.content_owner_id
            AND status.tax_status_code(+) = rates.tax_status_code;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                   'ZX_LINES Number of Rows Inserted(Tax Code) = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk_po',
                   'Inserting data into zx_lines(Tax Group)');
  END IF;

  -- Insert data into zx_lines
  --

    INSERT INTO ZX_LINES(
                ADJUSTED_DOC_APPLICATION_ID
               ,ADJUSTED_DOC_DATE
               ,ADJUSTED_DOC_ENTITY_CODE
               ,ADJUSTED_DOC_EVENT_CLASS_CODE
               ,ADJUSTED_DOC_LINE_ID
               ,ADJUSTED_DOC_NUMBER
               ,ADJUSTED_DOC_TAX_LINE_ID
               ,ADJUSTED_DOC_TRX_ID
               ,ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,APPLICATION_ID
               ,APPLIED_FROM_APPLICATION_ID
               ,APPLIED_FROM_ENTITY_CODE
               ,APPLIED_FROM_EVENT_CLASS_CODE
               ,APPLIED_FROM_LINE_ID
               ,APPLIED_FROM_TRX_ID
               ,APPLIED_FROM_TRX_LEVEL_TYPE
               ,APPLIED_FROM_TRX_NUMBER
               ,APPLIED_TO_APPLICATION_ID
               ,APPLIED_TO_ENTITY_CODE
               ,APPLIED_TO_EVENT_CLASS_CODE
               ,APPLIED_TO_LINE_ID
               ,APPLIED_TO_TRX_ID
               ,APPLIED_TO_TRX_LEVEL_TYPE
               ,APPLIED_TO_TRX_NUMBER
               ,ASSOCIATED_CHILD_FROZEN_FLAG
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,BASIS_RESULT_ID
               ,CAL_TAX_AMT
               ,CAL_TAX_AMT_FUNCL_CURR
               ,CAL_TAX_AMT_TAX_CURR
               ,CALC_RESULT_ID
               ,CANCEL_FLAG
               ,CHAR1
               ,CHAR10
               ,CHAR2
               ,CHAR3
               ,CHAR4
               ,CHAR5
               ,CHAR6
               ,CHAR7
               ,CHAR8
               ,CHAR9
               ,COMPOUNDING_DEP_TAX_FLAG
               ,COMPOUNDING_TAX_FLAG
               ,COMPOUNDING_TAX_MISS_FLAG
               ,CONTENT_OWNER_ID
               ,COPIED_FROM_OTHER_DOC_FLAG
               ,CREATED_BY
               ,CREATION_DATE
               ,CTRL_TOTAL_LINE_TX_AMT
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,DATE1
               ,DATE10
               ,DATE2
               ,DATE3
               ,DATE4
               ,DATE5
               ,DATE6
               ,DATE7
               ,DATE8
               ,DATE9
               ,DELETE_FLAG
               ,DIRECT_RATE_RESULT_ID
               ,DOC_EVENT_STATUS
               ,ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,ENTITY_CODE
               ,ESTABLISHMENT_ID
               ,EVAL_EXCPT_RESULT_ID
               ,EVAL_EXMPT_RESULT_ID
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,EXCEPTION_RATE
               ,EXEMPT_CERTIFICATE_NUMBER
               ,EXEMPT_RATE_MODIFIER
               ,EXEMPT_REASON
               ,EXEMPT_REASON_CODE
               ,FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,GLOBAL_ATTRIBUTE_CATEGORY
               ,GLOBAL_ATTRIBUTE1
               ,GLOBAL_ATTRIBUTE10
               ,GLOBAL_ATTRIBUTE11
               ,GLOBAL_ATTRIBUTE12
               ,GLOBAL_ATTRIBUTE13
               ,GLOBAL_ATTRIBUTE14
               ,GLOBAL_ATTRIBUTE15
               ,GLOBAL_ATTRIBUTE2
               ,GLOBAL_ATTRIBUTE3
               ,GLOBAL_ATTRIBUTE4
               ,GLOBAL_ATTRIBUTE5
               ,GLOBAL_ATTRIBUTE6
               ,GLOBAL_ATTRIBUTE7
               ,GLOBAL_ATTRIBUTE8
               ,GLOBAL_ATTRIBUTE9
               ,HISTORICAL_FLAG
               ,HQ_ESTB_PARTY_TAX_PROF_ID
               ,HQ_ESTB_REG_NUMBER
               ,INTERFACE_ENTITY_CODE
               ,INTERFACE_TAX_LINE_ID
               ,INTERNAL_ORG_LOCATION_ID
               ,INTERNAL_ORGANIZATION_ID
               ,ITEM_DIST_CHANGED_FLAG
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,LEDGER_ID
               ,LEGAL_ENTITY_ID
               ,LEGAL_ENTITY_TAX_REG_NUMBER
               ,LEGAL_JUSTIFICATION_TEXT1
               ,LEGAL_JUSTIFICATION_TEXT2
               ,LEGAL_JUSTIFICATION_TEXT3
               ,LEGAL_MESSAGE_APPL_2
               ,LEGAL_MESSAGE_BASIS
               ,LEGAL_MESSAGE_CALC
               ,LEGAL_MESSAGE_EXCPT
               ,LEGAL_MESSAGE_EXMPT
               ,LEGAL_MESSAGE_POS
               ,LEGAL_MESSAGE_RATE
               ,LEGAL_MESSAGE_STATUS
               ,LEGAL_MESSAGE_THRESHOLD
               ,LEGAL_MESSAGE_TRN
               ,LINE_AMT
               ,LINE_ASSESSABLE_VALUE
               ,MANUALLY_ENTERED_FLAG
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,MRC_LINK_TO_TAX_LINE_ID
               ,MRC_TAX_LINE_FLAG
               ,NREC_TAX_AMT
               ,NREC_TAX_AMT_FUNCL_CURR
               ,NREC_TAX_AMT_TAX_CURR
               ,NUMERIC1
               ,NUMERIC10
               ,NUMERIC2
               ,NUMERIC3
               ,NUMERIC4
               ,NUMERIC5
               ,NUMERIC6
               ,NUMERIC7
               ,NUMERIC8
               ,NUMERIC9
               ,OBJECT_VERSION_NUMBER
               ,OFFSET_FLAG
               ,OFFSET_LINK_TO_TAX_LINE_ID
               ,OFFSET_TAX_RATE_CODE
               ,ORIG_SELF_ASSESSED_FLAG
               ,ORIG_TAX_AMT
               ,ORIG_TAX_AMT_INCLUDED_FLAG
               ,ORIG_TAX_AMT_TAX_CURR
               ,ORIG_TAX_JURISDICTION_CODE
               ,ORIG_TAX_JURISDICTION_ID
               ,ORIG_TAX_RATE
               ,ORIG_TAX_RATE_CODE
               ,ORIG_TAX_RATE_ID
               ,ORIG_TAX_STATUS_CODE
               ,ORIG_TAX_STATUS_ID
               ,ORIG_TAXABLE_AMT
               ,ORIG_TAXABLE_AMT_TAX_CURR
               ,OTHER_DOC_LINE_AMT
               ,OTHER_DOC_LINE_TAX_AMT
               ,OTHER_DOC_LINE_TAXABLE_AMT
               ,OTHER_DOC_SOURCE
               ,OVERRIDDEN_FLAG
               ,PLACE_OF_SUPPLY
               ,PLACE_OF_SUPPLY_RESULT_ID
               ,PLACE_OF_SUPPLY_TYPE_CODE
               ,PRD_TOTAL_TAX_AMT
               ,PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,PRD_TOTAL_TAX_AMT_TAX_CURR
               ,PRECISION
               ,PROCESS_FOR_RECOVERY_FLAG
               ,PRORATION_CODE
               ,PURGE_FLAG
               ,RATE_RESULT_ID
               ,REC_TAX_AMT
               ,REC_TAX_AMT_FUNCL_CURR
               ,REC_TAX_AMT_TAX_CURR
               ,RECALC_REQUIRED_FLAG
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_LINE_QUANTITY
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,REGISTRATION_PARTY_TYPE
               ,RELATED_DOC_APPLICATION_ID
               ,RELATED_DOC_DATE
               ,RELATED_DOC_ENTITY_CODE
               ,RELATED_DOC_EVENT_CLASS_CODE
               ,RELATED_DOC_NUMBER
               ,RELATED_DOC_TRX_ID
               ,RELATED_DOC_TRX_LEVEL_TYPE
               ,REPORTING_CURRENCY_CODE
               ,REPORTING_ONLY_FLAG
               ,REPORTING_PERIOD_ID
               ,ROUNDING_LEVEL_CODE
               ,ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,ROUNDING_LVL_PARTY_TYPE
               ,ROUNDING_RULE_CODE
               ,SELF_ASSESSED_FLAG
               ,SETTLEMENT_FLAG
               ,STATUS_RESULT_ID
               ,SUMMARY_TAX_LINE_ID
               ,SYNC_WITH_PRVDR_FLAG
               ,TAX
               ,TAX_AMT
               ,TAX_AMT_FUNCL_CURR
               ,TAX_AMT_INCLUDED_FLAG
               ,TAX_AMT_TAX_CURR
               ,TAX_APPLICABILITY_RESULT_ID
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_BASE_MODIFIER_RATE
               ,TAX_CALCULATION_FORMULA
               ,TAX_CODE
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_DATE
               ,TAX_DATE_RULE_ID
               ,TAX_DETERMINE_DATE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_EXCEPTION_ID
               ,TAX_EXEMPTION_ID
               ,TAX_HOLD_CODE
               ,TAX_HOLD_RELEASED_CODE
               ,TAX_ID
               ,TAX_JURISDICTION_CODE
               ,TAX_JURISDICTION_ID
               ,TAX_LINE_ID
               ,TAX_LINE_NUMBER
               ,TAX_ONLY_LINE_FLAG
               ,TAX_POINT_DATE
               ,TAX_PROVIDER_ID
               ,TAX_RATE
               ,TAX_RATE_BEFORE_EXCEPTION
               ,TAX_RATE_BEFORE_EXEMPTION
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_RATE_NAME_BEFORE_EXCEPTION
               ,TAX_RATE_NAME_BEFORE_EXEMPTION
               ,TAX_RATE_TYPE
               ,TAX_REG_NUM_DET_RESULT_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_REGIME_TEMPLATE_ID
               ,TAX_REGISTRATION_ID
               ,TAX_REGISTRATION_NUMBER
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TAX_TYPE_CODE
               ,TAXABLE_AMT
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TAXABLE_BASIS_FORMULA
               ,TAXING_JURIS_GEOGRAPHY_ID
               ,THRESH_RESULT_ID
               ,TRX_CURRENCY_CODE
               ,TRX_DATE
               ,TRX_ID
               ,TRX_ID_LEVEL2
               ,TRX_ID_LEVEL3
               ,TRX_ID_LEVEL4
               ,TRX_ID_LEVEL5
               ,TRX_ID_LEVEL6
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_DATE
               ,TRX_LINE_ID
               ,TRX_LINE_INDEX
               ,TRX_LINE_NUMBER
               ,TRX_LINE_QUANTITY
               ,TRX_NUMBER
               ,TRX_USER_KEY_LEVEL1
               ,TRX_USER_KEY_LEVEL2
               ,TRX_USER_KEY_LEVEL3
               ,TRX_USER_KEY_LEVEL4
               ,TRX_USER_KEY_LEVEL5
               ,TRX_USER_KEY_LEVEL6
               ,UNIT_PRICE
               ,UNROUNDED_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,MULTIPLE_JURISDICTIONS_FLAG)
        SELECT /*+ leading(poh) NO_EXPAND
                   use_nl(fc,pol,poll,ptp,atc,atg,atc1,rates,regimes,taxes,status) */
                NULL 	                           ADJUSTED_DOC_APPLICATION_ID
               ,NULL 	                           ADJUSTED_DOC_DATE
               ,NULL	                           ADJUSTED_DOC_ENTITY_CODE
               ,NULL                               ADJUSTED_DOC_EVENT_CLASS_CODE
               ,NULL                               ADJUSTED_DOC_LINE_ID
               ,NULL                               ADJUSTED_DOC_NUMBER
               ,NULL                               ADJUSTED_DOC_TAX_LINE_ID
               ,NULL                               ADJUSTED_DOC_TRX_ID
               ,NULL                               ADJUSTED_DOC_TRX_LEVEL_TYPE
               ,201	                           APPLICATION_ID
               ,NULL                               APPLIED_FROM_APPLICATION_ID
               ,NULL                               APPLIED_FROM_ENTITY_CODE
               ,NULL                               APPLIED_FROM_EVENT_CLASS_CODE
               ,NULL                               APPLIED_FROM_LINE_ID
               ,NULL                               APPLIED_FROM_TRX_ID
               ,NULL                               APPLIED_FROM_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_FROM_TRX_NUMBER
               ,NULL	                           APPLIED_TO_APPLICATION_ID
               ,NULL	                           APPLIED_TO_ENTITY_CODE
               ,NULL	                           APPLIED_TO_EVENT_CLASS_CODE
               ,NULL	                           APPLIED_TO_LINE_ID
               ,NULL	                           APPLIED_TO_TRX_ID
               ,NULL	                           APPLIED_TO_TRX_LEVEL_TYPE
               ,NULL	                           APPLIED_TO_TRX_NUMBER
               ,'N' 	                           ASSOCIATED_CHILD_FROZEN_FLAG
               ,poll.ATTRIBUTE_CATEGORY            ATTRIBUTE_CATEGORY
               ,poll.ATTRIBUTE1 	           ATTRIBUTE1
               ,poll.ATTRIBUTE10	           ATTRIBUTE10
               ,poll.ATTRIBUTE11	           ATTRIBUTE11
               ,poll.ATTRIBUTE12	           ATTRIBUTE12
               ,poll.ATTRIBUTE13	           ATTRIBUTE13
               ,poll.ATTRIBUTE14	           ATTRIBUTE14
               ,poll.ATTRIBUTE15	           ATTRIBUTE15
               ,poll.ATTRIBUTE2 	           ATTRIBUTE2
               ,poll.ATTRIBUTE3 	           ATTRIBUTE3
               ,poll.ATTRIBUTE4 	           ATTRIBUTE4
               ,poll.ATTRIBUTE5 	           ATTRIBUTE5
               ,poll.ATTRIBUTE6 	           ATTRIBUTE6
               ,poll.ATTRIBUTE7 	           ATTRIBUTE7
               ,poll.ATTRIBUTE8 	           ATTRIBUTE8
               ,poll.ATTRIBUTE9 	           ATTRIBUTE9
               ,NULL			           BASIS_RESULT_ID
               ,NULL	                           CAL_TAX_AMT
               ,NULL	                           CAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           CAL_TAX_AMT_TAX_CURR
               ,NULL	                           CALC_RESULT_ID
               ,'N'	                           CANCEL_FLAG
               ,NULL	                           CHAR1
               ,NULL	                           CHAR10
               ,NULL	                           CHAR2
               ,NULL	                           CHAR3
               ,NULL	                           CHAR4
               ,NULL	                           CHAR5
               ,NULL	                           CHAR6
               ,NULL	                           CHAR7
               ,NULL	                           CHAR8
               ,NULL	                           CHAR9
               ,'N'	                           COMPOUNDING_DEP_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_FLAG
               ,'N'	                           COMPOUNDING_TAX_MISS_FLAG
               ,ptp.party_tax_profile_id	   CONTENT_OWNER_ID
               ,'N'	                           COPIED_FROM_OTHER_DOC_FLAG
               ,1	                           CREATED_BY
               ,SYSDATE                            CREATION_DATE
               ,NULL		                   CTRL_TOTAL_LINE_TX_AMT
               ,poll.poh_rate_date 	           CURRENCY_CONVERSION_DATE
               ,poll.poh_rate 	                   CURRENCY_CONVERSION_RATE
               ,poll.poh_rate_type 	           CURRENCY_CONVERSION_TYPE
               ,NULL	                           DATE1
               ,NULL	                           DATE10
               ,NULL	                           DATE2
               ,NULL	                           DATE3
               ,NULL	                           DATE4
               ,NULL	                           DATE5
               ,NULL	                           DATE6
               ,NULL	                          DATE7
               ,NULL	                           DATE8
               ,NULL	                           DATE9
               ,'N'	                           DELETE_FLAG
               ,NULL	                           DIRECT_RATE_RESULT_ID
               ,NULL	                           DOC_EVENT_STATUS
               ,'N'	                           ENFORCE_FROM_NATURAL_ACCT_FLAG
               ,'RELEASE'                          ENTITY_CODE
               ,NULL	                           ESTABLISHMENT_ID
               ,NULL	                           EVAL_EXCPT_RESULT_ID
               ,NULL	                           EVAL_EXMPT_RESULT_ID
               ,'RELEASE'                          EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	   EVENT_TYPE_CODE
               ,NULL                               EXCEPTION_RATE
               ,NULL	                           EXEMPT_CERTIFICATE_NUMBER
               ,NULL	                           EXEMPT_RATE_MODIFIER
               ,NULL	                           EXEMPT_REASON
               ,NULL	                           EXEMPT_REASON_CODE
               ,'N'	                           FREEZE_UNTIL_OVERRIDDEN_FLAG
               ,poll.GLOBAL_ATTRIBUTE_CATEGORY     GLOBAL_ATTRIBUTE_CATEGORY
               ,poll.GLOBAL_ATTRIBUTE1 	           GLOBAL_ATTRIBUTE1
               ,poll.GLOBAL_ATTRIBUTE10	           GLOBAL_ATTRIBUTE10
               ,poll.GLOBAL_ATTRIBUTE11	           GLOBAL_ATTRIBUTE11
               ,poll.GLOBAL_ATTRIBUTE12	           GLOBAL_ATTRIBUTE12
               ,poll.GLOBAL_ATTRIBUTE13	           GLOBAL_ATTRIBUTE13
               ,poll.GLOBAL_ATTRIBUTE14	           GLOBAL_ATTRIBUTE14
               ,poll.GLOBAL_ATTRIBUTE15	           GLOBAL_ATTRIBUTE15
               ,poll.GLOBAL_ATTRIBUTE2             GLOBAL_ATTRIBUTE2
               ,poll.GLOBAL_ATTRIBUTE3             GLOBAL_ATTRIBUTE3
               ,poll.GLOBAL_ATTRIBUTE4             GLOBAL_ATTRIBUTE4
               ,poll.GLOBAL_ATTRIBUTE5             GLOBAL_ATTRIBUTE5
               ,poll.GLOBAL_ATTRIBUTE6             GLOBAL_ATTRIBUTE6
               ,poll.GLOBAL_ATTRIBUTE7             GLOBAL_ATTRIBUTE7
               ,poll.GLOBAL_ATTRIBUTE8             GLOBAL_ATTRIBUTE8
               ,poll.GLOBAL_ATTRIBUTE9             GLOBAL_ATTRIBUTE9
               ,'Y'	                           HISTORICAL_FLAG
               ,NULL                               HQ_ESTB_PARTY_TAX_PROF_ID
               ,NULL	                           HQ_ESTB_REG_NUMBER
               ,NULL	                           INTERFACE_ENTITY_CODE
               ,NULL	                           INTERFACE_TAX_LINE_ID
               ,NULL                               INTERNAL_ORG_LOCATION_ID
               ,NVL(poll.poh_org_id,-99)           INTERNAL_ORGANIZATION_ID
               ,'N'                                 ITEM_DIST_CHANGED_FLAG
               ,NULL	                           LAST_MANUAL_ENTRY
               ,SYSDATE	                           LAST_UPDATE_DATE
               ,1	                           LAST_UPDATE_LOGIN
               ,1	                           LAST_UPDATED_BY
               ,poll.fsp_set_of_books_id 	   LEDGER_ID
               ,NVL(poll.oi_org_information2, -99) LEGAL_ENTITY_ID
               ,NULL                               LEGAL_ENTITY_TAX_REG_NUMBER
               ,NULL                               LEGAL_JUSTIFICATION_TEXT1
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT2
               ,NULL	                           LEGAL_JUSTIFICATION_TEXT3
               ,NULL                               LEGAL_MESSAGE_APPL_2
               ,NULL	                           LEGAL_MESSAGE_BASIS
               ,NULL	                           LEGAL_MESSAGE_CALC
               ,NULL	                           LEGAL_MESSAGE_EXCPT
               ,NULL	                           LEGAL_MESSAGE_EXMPT
               ,NULL	                           LEGAL_MESSAGE_POS
               ,NULL	                           LEGAL_MESSAGE_RATE
               ,NULL                               LEGAL_MESSAGE_STATUS
               ,NULL	                           LEGAL_MESSAGE_THRESHOLD
               ,NULL	                           LEGAL_MESSAGE_TRN
               ,DECODE(pol.purchase_basis,
                 'TEMP LABOR', NVL(POLL.amount,0),
                 'SERVICES', DECODE(pol.matching_basis, 'AMOUNT',NVL(POLL.amount,0),
                                    NVL(poll.quantity,0) *
                                    NVL(poll.price_override,NVL(pol.unit_price,0))),
                  NVL(poll.quantity,0) * NVL(poll.price_override,NVL(pol.unit_price,0)))
                                                   LINE_AMT
               ,NULL	                           LINE_ASSESSABLE_VALUE
               ,'N'	                           MANUALLY_ENTERED_FLAG
               ,fc.minimum_accountable_unit	   MINIMUM_ACCOUNTABLE_UNIT
               ,NULL	                           MRC_LINK_TO_TAX_LINE_ID
               ,'N'	                           MRC_TAX_LINE_FLAG
               ,NULL	                           NREC_TAX_AMT
               ,NULL	                           NREC_TAX_AMT_FUNCL_CURR
               ,NULL	                           NREC_TAX_AMT_TAX_CURR
               ,NULL	                           NUMERIC1
               ,NULL	                           NUMERIC10
               ,NULL	                           NUMERIC2
               ,NULL	                           NUMERIC3
               ,NULL	                           NUMERIC4
               ,NULL	                           NUMERIC5
               ,NULL	                           NUMERIC6
               ,NULL	                           NUMERIC7
               ,NULL	                           NUMERIC8
               ,NULL	                           NUMERIC9
               ,1	                           OBJECT_VERSION_NUMBER
               ,'N'	                           OFFSET_FLAG
               ,NULL	                           OFFSET_LINK_TO_TAX_LINE_ID
               ,NULL	                           OFFSET_TAX_RATE_CODE
               ,'N'	                           ORIG_SELF_ASSESSED_FLAG
               ,NULL	                           ORIG_TAX_AMT
               ,NULL	                           ORIG_TAX_AMT_INCLUDED_FLAG
               ,NULL	                           ORIG_TAX_AMT_TAX_CURR
               ,NULL	                           ORIG_TAX_JURISDICTION_CODE
               ,NULL	                           ORIG_TAX_JURISDICTION_ID
               ,NULL	                           ORIG_TAX_RATE
               ,NULL	                           ORIG_TAX_RATE_CODE
               ,NULL	                           ORIG_TAX_RATE_ID
               ,NULL	                           ORIG_TAX_STATUS_CODE
               ,NULL	                           ORIG_TAX_STATUS_ID
               ,NULL	                           ORIG_TAXABLE_AMT
               ,NULL	                           ORIG_TAXABLE_AMT_TAX_CURR
               ,NULL	                           OTHER_DOC_LINE_AMT
               ,NULL	                           OTHER_DOC_LINE_TAX_AMT
               ,NULL	                           OTHER_DOC_LINE_TAXABLE_AMT
               ,NULL	                           OTHER_DOC_SOURCE
               ,'N'	                           OVERRIDDEN_FLAG
               ,NULL	                           PLACE_OF_SUPPLY
               ,NULL	                           PLACE_OF_SUPPLY_RESULT_ID
               ,NULL                               PLACE_OF_SUPPLY_TYPE_CODE
               ,NULL	                           PRD_TOTAL_TAX_AMT
               ,NULL	                           PRD_TOTAL_TAX_AMT_FUNCL_CURR
               ,NULL	                           PRD_TOTAL_TAX_AMT_TAX_CURR
               ,NVL(fc.precision, 0)               PRECISION
               ,'N'	                           PROCESS_FOR_RECOVERY_FLAG
               ,NULL	                           PRORATION_CODE
               ,'N'	                           PURGE_FLAG
               ,NULL	                           RATE_RESULT_ID
               ,NULL	                           REC_TAX_AMT
               ,NULL	                           REC_TAX_AMT_FUNCL_CURR
               ,NULL	                           REC_TAX_AMT_TAX_CURR
               ,'N'	                           RECALC_REQUIRED_FLAG
               ,'MIGRATED'                         RECORD_TYPE_CODE
               ,NULL	                           REF_DOC_APPLICATION_ID
               ,NULL	                           REF_DOC_ENTITY_CODE
               ,NULL	                           REF_DOC_EVENT_CLASS_CODE
               ,NULL	                           REF_DOC_LINE_ID
               ,NULL	                           REF_DOC_LINE_QUANTITY
               ,NULL	                           REF_DOC_TRX_ID
               ,NULL	                           REF_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REGISTRATION_PARTY_TYPE
               ,NULL	                           RELATED_DOC_APPLICATION_ID
               ,NULL	                           RELATED_DOC_DATE
               ,NULL	                           RELATED_DOC_ENTITY_CODE
               ,NULL	                           RELATED_DOC_EVENT_CLASS_CODE
               ,NULL	                           RELATED_DOC_NUMBER
               ,NULL	                           RELATED_DOC_TRX_ID
               ,NULL	                           RELATED_DOC_TRX_LEVEL_TYPE
               ,NULL	                           REPORTING_CURRENCY_CODE
               ,'N'	                           REPORTING_ONLY_FLAG
               ,NULL	                           REPORTING_PERIOD_ID
               ,NULL	                           ROUNDING_LEVEL_CODE
               ,NULL	                           ROUNDING_LVL_PARTY_TAX_PROF_ID
               ,NULL	                           ROUNDING_LVL_PARTY_TYPE
               ,NULL	                           ROUNDING_RULE_CODE
               ,'N'	                           SELF_ASSESSED_FLAG
               ,'N'                                SETTLEMENT_FLAG
               ,NULL                               STATUS_RESULT_ID
               ,NULL                               SUMMARY_TAX_LINE_ID
               ,NULL                               SYNC_WITH_PRVDR_FLAG
               ,rates.tax                          TAX
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)  TAX_AMT
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit)
                                                   TAX_AMT_FUNCL_CURR
               ,'N'                                TAX_AMT_INCLUDED_FLAG
               ,decode(FC.Minimum_Accountable_Unit, NULL,
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100), NVL(FC.Precision,0)),
                  ROUND((NVL(poll.quantity,0) * NVL(poll.price_override, NVL(pol.unit_price,0)))* (nvl(atc1.tax_rate,0)/100)/FC.Minimum_Accountable_Unit)
                                   * FC.Minimum_Accountable_Unit) TAX_AMT_TAX_CURR
               ,NULL                               TAX_APPLICABILITY_RESULT_ID
               ,'Y'                                TAX_APPORTIONMENT_FLAG
               ,RANK() OVER
                 (PARTITION BY
                   poll.po_release_id,
                   poll.line_location_id,
                   rates.tax_regime_code,
                   rates.tax
                  ORDER BY atg.tax_code_id)        TAX_APPORTIONMENT_LINE_NUMBER
               ,NULL                               TAX_BASE_MODIFIER_RATE
               ,'STANDARD_TC'                      TAX_CALCULATION_FORMULA
               ,NULL                               TAX_CODE
               ,taxes.tax_currency_code            TAX_CURRENCY_CODE
               ,poll.poh_rate_date 		   TAX_CURRENCY_CONVERSION_DATE
               ,poll.poh_rate 		           TAX_CURRENCY_CONVERSION_RATE
               ,poll.poh_rate_type 		   TAX_CURRENCY_CONVERSION_TYPE
               ,poll.last_update_date              TAX_DATE
               ,NULL                               TAX_DATE_RULE_ID
               ,poll.last_update_date              TAX_DETERMINE_DATE
               ,'PURCHASE_TRANSACTION' 	           TAX_EVENT_CLASS_CODE
               ,'VALIDATE'  		           TAX_EVENT_TYPE_CODE
               ,NULL                               TAX_EXCEPTION_ID
               ,NULL                               TAX_EXEMPTION_ID
               ,NULL                               TAX_HOLD_CODE
               ,NULL                               TAX_HOLD_RELEASED_CODE
               ,taxes.tax_id                       TAX_ID
               ,NULL                               TAX_JURISDICTION_CODE
               ,NULL                               TAX_JURISDICTION_ID
               ,zx_lines_s.nextval                 TAX_LINE_ID
               ,RANK() OVER
                 (PARTITION BY poll.po_release_id
                  ORDER BY poll.line_location_id,
                           atg.tax_code_id,
                           atc.tax_id)             TAX_LINE_NUMBER
               ,'N'                                TAX_ONLY_LINE_FLAG
               ,poll.last_update_date              TAX_POINT_DATE
               ,NULL                               TAX_PROVIDER_ID
               ,rates.percentage_rate  	           TAX_RATE
               ,NULL	                           TAX_RATE_BEFORE_EXCEPTION
               ,NULL                               TAX_RATE_BEFORE_EXEMPTION
               ,rates.tax_rate_code                TAX_RATE_CODE
               ,rates.tax_rate_id                  TAX_RATE_ID
               ,NULL                               TAX_RATE_NAME_BEFORE_EXCEPTION
               ,NULL                               TAX_RATE_NAME_BEFORE_EXEMPTION
               ,NULL                               TAX_RATE_TYPE
               ,NULL                               TAX_REG_NUM_DET_RESULT_ID
               ,rates.tax_regime_code              TAX_REGIME_CODE
               ,regimes.tax_regime_id              TAX_REGIME_ID
               ,NULL                               TAX_REGIME_TEMPLATE_ID
               ,NULL                               TAX_REGISTRATION_ID
               ,NULL                               TAX_REGISTRATION_NUMBER
               ,rates.tax_status_code              TAX_STATUS_CODE
               ,status.tax_status_id               TAX_STATUS_ID
               ,NULL                               TAX_TYPE_CODE
               ,NULL                               TAXABLE_AMT
               ,NULL                               TAXABLE_AMT_FUNCL_CURR
               ,NULL                               TAXABLE_AMT_TAX_CURR
               ,'STANDARD_TB'                      TAXABLE_BASIS_FORMULA
               ,NULL                               TAXING_JURIS_GEOGRAPHY_ID
               ,NULL                               THRESH_RESULT_ID
               ,NVL(poll.poh_currency_code,
                    poll.aps_base_currency_code)   TRX_CURRENCY_CODE
               ,poll.poh_last_update_date          TRX_DATE
               ,poll.po_release_id TRX_ID
               ,NULL                               TRX_ID_LEVEL2
               ,NULL                               TRX_ID_LEVEL3
               ,NULL                               TRX_ID_LEVEL4
               ,NULL                               TRX_ID_LEVEL5
               ,NULL                               TRX_ID_LEVEL6
               ,'SHIPMENT'                         TRX_LEVEL_TYPE
               ,poll.LAST_UPDATE_DATE              TRX_LINE_DATE
               ,poll.line_location_id              TRX_LINE_ID
               ,NULL                               TRX_LINE_INDEX
               ,poll.SHIPMENT_NUM                  TRX_LINE_NUMBER
               ,poll.quantity 		           TRX_LINE_QUANTITY
               ,poll.poh_segment1                  TRX_NUMBER
               ,NULL                               TRX_USER_KEY_LEVEL1
               ,NULL                               TRX_USER_KEY_LEVEL2
               ,NULL                               TRX_USER_KEY_LEVEL3
               ,NULL                               TRX_USER_KEY_LEVEL4
               ,NULL                               TRX_USER_KEY_LEVEL5
               ,NULL                               TRX_USER_KEY_LEVEL6
               ,NVL(poll.price_override,
                     pol.unit_price)               UNIT_PRICE
               ,NULL                               UNROUNDED_TAX_AMT
               ,NULL                               UNROUNDED_TAXABLE_AMT
               ,'N'                                MULTIPLE_JURISDICTIONS_FLAG
          FROM (SELECT /*+ NO_MERGE NO_EXPAND use_hash(fsp) use_hash(aps)
                       swap_join_inputs(fsp) swap_join_inputs(aps)
                       swap_join_inputs(oi) */
                       poll.*,
                       poh.rate_date 	       poh_rate_date,
                       poh.rate 	       poh_rate,
                       poh.rate_type 	       poh_rate_type,
                       poh.org_id              poh_org_id,
                       poh.currency_code       poh_currency_code,
                       poh.last_update_date    poh_last_update_date,
                       poh.segment1            poh_segment1,
                       fsp.set_of_books_id     fsp_set_of_books_id,
                       fsp.org_id              fsp_org_id,
                       aps.base_currency_code  aps_base_currency_code,
                       oi.org_information2     oi_org_information2
                  FROM (select distinct other_doc_application_id, other_doc_trx_id
             	          from ZX_VALIDATION_ERRORS_GT
             	         where other_doc_application_id = 201
             	           and other_doc_entity_code = 'RELEASE'
             	           and other_doc_event_class_code = 'RELEASE'
             	       ) zxvalerr,
                         po_line_locations_all poll,
                         po_headers_all poh,
             	         financials_system_params_all fsp,
          	         ap_system_parameters_all aps,
          	         hr_organization_information oi
                   WHERE poll.po_release_id = zxvalerr.other_doc_trx_id
                     AND poh.po_header_id = poll.po_header_id
                     AND NVL(poh.org_id,-99) = NVL(fsp.org_id,-99)
                     AND NVL(aps.org_id, -99) = NVL(poh.org_id,-99)
                     AND aps.set_of_books_id = fsp.set_of_books_id
                     AND oi.organization_id(+) = poh.org_id
                     AND oi.org_information_context(+) = 'Operating Unit Information'
                ) poll,
                fnd_currencies fc,
                po_lines_all pol,
                zx_party_tax_profile ptp,
                ap_tax_codes_all atc,
                ar_tax_group_codes_all atg,
                ap_tax_codes_all atc1,
                zx_rates_b rates,
                zx_regimes_b regimes,
                zx_taxes_b taxes,
                zx_status_b status
          WHERE NVL(poll.poh_currency_code, poll.aps_base_currency_code) = fc.currency_code(+)
            AND pol.po_header_id = poll.po_header_id
            AND pol.po_line_id = poll.po_line_id
            AND NOT EXISTS
                (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                   WHERE lines_gt.application_id   = 201
                     AND lines_gt.event_class_code = 'RELEASE'
                     AND lines_gt.entity_code      = 'RELEASE'
                     AND lines_gt.trx_id           = poll.po_release_id
                     AND lines_gt.trx_line_id      = poll.line_location_id
                     AND lines_gt.trx_level_type   = 'SHIPMENT'
                     AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
                )
            AND nvl(atc.org_id,-99)=nvl(poll.fsp_org_id,-99)
            AND poll.tax_code_id = atc.tax_id
            AND atc.tax_type = 'TAX_GROUP'
            --Bug 8352135
 	          AND atg.start_date <= poll.last_update_date
 	          AND (atg.end_date >= poll.last_update_date OR atg.end_date IS NULL)
            AND poll.tax_code_id = atg.tax_group_id
            AND atc1.tax_id = atg.tax_code_id
            AND atc1.start_date <= poll.last_update_date
            AND(atc1.inactive_date >= poll.last_update_date OR atc1.inactive_date IS NULL)
            AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,poll.org_id)
            AND ptp.party_type_code = 'OU'
            AND rates.source_id = atg.tax_code_id
            AND regimes.tax_regime_code(+) = rates.tax_regime_code
            AND taxes.tax_regime_code(+) = rates.tax_regime_code
            AND taxes.tax(+) = rates.tax
            AND taxes.content_owner_id(+) = rates.content_owner_id
            AND status.tax_regime_code(+) = rates.tax_regime_code
            AND status.tax(+) = rates.tax
            AND status.content_owner_id(+) = rates.content_owner_id
            AND status.tax_status_code(+) = rates.tax_status_code;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                   'ZX_LINES Number of Rows Inserted(Tax Group) = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;

  -- COMMIT;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                  'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_blk_po',
                  'Inserting data into zx_rec_nrec_dist');
  END IF;

  -- Insert data into zx_rec_nrec_dist
  --
    INSERT INTO ZX_REC_NREC_DIST(
                TAX_LINE_ID
               ,REC_NREC_TAX_DIST_ID
               ,REC_NREC_TAX_DIST_NUMBER
               ,APPLICATION_ID
               ,CONTENT_OWNER_ID
               ,CURRENCY_CONVERSION_DATE
               ,CURRENCY_CONVERSION_RATE
               ,CURRENCY_CONVERSION_TYPE
               ,ENTITY_CODE
               ,EVENT_CLASS_CODE
               ,EVENT_TYPE_CODE
               ,LEDGER_ID
               ,MINIMUM_ACCOUNTABLE_UNIT
               ,PRECISION
               ,RECORD_TYPE_CODE
               ,REF_DOC_APPLICATION_ID
               ,REF_DOC_ENTITY_CODE
               ,REF_DOC_EVENT_CLASS_CODE
               ,REF_DOC_LINE_ID
               ,REF_DOC_TRX_ID
               ,REF_DOC_TRX_LEVEL_TYPE
               ,SUMMARY_TAX_LINE_ID
               ,TAX
               ,TAX_APPORTIONMENT_LINE_NUMBER
               ,TAX_CURRENCY_CODE
               ,TAX_CURRENCY_CONVERSION_DATE
               ,TAX_CURRENCY_CONVERSION_RATE
               ,TAX_CURRENCY_CONVERSION_TYPE
               ,TAX_EVENT_CLASS_CODE
               ,TAX_EVENT_TYPE_CODE
               ,TAX_ID
               ,TAX_LINE_NUMBER
               ,TAX_RATE
               ,TAX_RATE_CODE
               ,TAX_RATE_ID
               ,TAX_REGIME_CODE
               ,TAX_REGIME_ID
               ,TAX_STATUS_CODE
               ,TAX_STATUS_ID
               ,TRX_CURRENCY_CODE
               ,TRX_ID
               ,TRX_LEVEL_TYPE
               ,TRX_LINE_ID
               ,TRX_LINE_NUMBER
               ,TRX_NUMBER
               ,UNIT_PRICE
               ,ACCOUNT_CCID
               ,ACCOUNT_STRING
               ,ADJUSTED_DOC_TAX_DIST_ID
               ,APPLIED_FROM_TAX_DIST_ID
               ,APPLIED_TO_DOC_CURR_CONV_RATE
               ,AWARD_ID
               ,EXPENDITURE_ITEM_DATE
               ,EXPENDITURE_ORGANIZATION_ID
               ,EXPENDITURE_TYPE
               ,FUNC_CURR_ROUNDING_ADJUSTMENT
               ,GL_DATE
               ,INTENDED_USE
               ,ITEM_DIST_NUMBER
               ,MRC_LINK_TO_TAX_DIST_ID
               ,ORIG_REC_NREC_RATE
               ,ORIG_REC_NREC_TAX_AMT
               ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
               ,ORIG_REC_RATE_CODE
               ,PER_TRX_CURR_UNIT_NR_AMT
               ,PER_UNIT_NREC_TAX_AMT
               ,PRD_TAX_AMT
               ,PRICE_DIFF
               ,PROJECT_ID
               ,QTY_DIFF
               ,RATE_TAX_FACTOR
               ,REC_NREC_RATE
               ,REC_NREC_TAX_AMT
               ,REC_NREC_TAX_AMT_FUNCL_CURR
               ,REC_NREC_TAX_AMT_TAX_CURR
               ,RECOVERY_RATE_CODE
               ,RECOVERY_RATE_ID
               ,RECOVERY_TYPE_CODE
               ,RECOVERY_TYPE_ID
               ,REF_DOC_CURR_CONV_RATE
               ,REF_DOC_DIST_ID
               ,REF_DOC_PER_UNIT_NREC_TAX_AMT
               ,REF_DOC_TAX_DIST_ID
               ,REF_DOC_TRX_LINE_DIST_QTY
               ,REF_DOC_UNIT_PRICE
               ,REF_PER_TRX_CURR_UNIT_NR_AMT
               ,REVERSED_TAX_DIST_ID
               ,ROUNDING_RULE_CODE
               ,TASK_ID
               ,TAXABLE_AMT_FUNCL_CURR
               ,TAXABLE_AMT_TAX_CURR
               ,TRX_LINE_DIST_AMT
               ,TRX_LINE_DIST_ID
               ,TRX_LINE_DIST_QTY
               ,TRX_LINE_DIST_TAX_AMT
               ,UNROUNDED_REC_NREC_TAX_AMT
               ,UNROUNDED_TAXABLE_AMT
               ,TAXABLE_AMT
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,HISTORICAL_FLAG
               ,OVERRIDDEN_FLAG
               ,SELF_ASSESSED_FLAG
               ,TAX_APPORTIONMENT_FLAG
               ,TAX_ONLY_LINE_FLAG
               ,INCLUSIVE_FLAG
               ,MRC_TAX_DIST_FLAG
               ,REC_TYPE_RULE_FLAG
               ,NEW_REC_RATE_CODE_FLAG
               ,RECOVERABLE_FLAG
               ,REVERSE_FLAG
               ,REC_RATE_DET_RULE_FLAG
               ,BACKWARD_COMPATIBILITY_FLAG
               ,FREEZE_FLAG
               ,POSTING_FLAG
               ,LEGAL_ENTITY_ID
               ,CREATED_BY
               ,CREATION_DATE
               ,LAST_MANUAL_ENTRY
               ,LAST_UPDATE_DATE
               ,LAST_UPDATE_LOGIN
               ,LAST_UPDATED_BY
               ,OBJECT_VERSION_NUMBER)
        SELECT /*+ NO_EXPAND leading(pohzd) use_nl(fc, rates)*/
                pohzd.tax_line_id		    TAX_LINE_ID
               ,zx_rec_nrec_dist_s.NEXTVAL          REC_NREC_TAX_DIST_ID
               ,DECODE(tmp.rec_flag,
                 'Y', (RANK() OVER (PARTITION BY pohzd.trx_id,
                                    pohzd.p_po_distribution_id
                                    ORDER BY
                                    pohzd.p_po_distribution_id,pohzd.tax_rate_id))*2-1,
                 'N', (RANK() OVER (PARTITION BY pohzd.trx_id,
                                    pohzd.p_po_distribution_id
                                    ORDER BY
                                    pohzd.p_po_distribution_id,pohzd.tax_rate_id))*2)
                                                    REC_NREC_TAX_DIST_NUMBER
               ,201 				    APPLICATION_ID
               ,pohzd.content_owner_id		    CONTENT_OWNER_ID
               ,pohzd.CURRENCY_CONVERSION_DATE	    CURRENCY_CONVERSION_DATE
               ,pohzd.CURRENCY_CONVERSION_RATE	    CURRENCY_CONVERSION_RATE
               ,pohzd.CURRENCY_CONVERSION_TYPE	    CURRENCY_CONVERSION_TYPE
               ,'RELEASE' 			    ENTITY_CODE
               ,'RELEASE'			    EVENT_CLASS_CODE
               ,'PURCHASE ORDER CREATED'	    EVENT_TYPE_CODE
               ,pohzd.ledger_id			    LEDGER_ID
               ,pohzd.MINIMUM_ACCOUNTABLE_UNIT	    MINIMUM_ACCOUNTABLE_UNIT
               ,pohzd.PRECISION			    PRECISION
               ,'MIGRATED' 			    RECORD_TYPE_CODE
               ,NULL 				    REF_DOC_APPLICATION_ID
               ,NULL 				    REF_DOC_ENTITY_CODE
               ,NULL				    REF_DOC_EVENT_CLASS_CODE
               ,NULL				    REF_DOC_LINE_ID
               ,NULL				    REF_DOC_TRX_ID
               ,NULL				    REF_DOC_TRX_LEVEL_TYPE
               ,NULL 				    SUMMARY_TAX_LINE_ID
               ,pohzd.tax			    TAX
               ,pohzd.TAX_APPORTIONMENT_LINE_NUMBER TAX_APPORTIONMENT_LINE_NUMBER
               ,pohzd.TAX_CURRENCY_CODE	            TAX_CURRENCY_CODE
               ,pohzd.TAX_CURRENCY_CONVERSION_DATE  TAX_CURRENCY_CONVERSION_DATE
               ,pohzd.TAX_CURRENCY_CONVERSION_RATE  TAX_CURRENCY_CONVERSION_RATE
               ,pohzd.TAX_CURRENCY_CONVERSION_TYPE  TAX_CURRENCY_CONVERSION_TYPE
               ,'PURCHASE_TRANSACTION' 		    TAX_EVENT_CLASS_CODE
               ,'VALIDATE'			    TAX_EVENT_TYPE_CODE
               ,pohzd.tax_id			    TAX_ID
               ,pohzd.tax_line_number		    TAX_LINE_NUMBER
               ,pohzd.tax_rate			    TAX_RATE
               ,pohzd.tax_rate_code 		    TAX_RATE_CODE
               ,pohzd.tax_rate_id		    TAX_RATE_ID
               ,pohzd.tax_regime_code	 	    TAX_REGIME_CODE
               ,pohzd.tax_regime_id		    TAX_REGIME_ID
               ,pohzd.tax_status_code		    TAX_STATUS_CODE
               ,pohzd.tax_status_id	 	    TAX_STATUS_ID
               ,pohzd.trx_currency_code		    TRX_CURRENCY_CODE
               ,pohzd.trx_id			    TRX_ID
               ,'SHIPMENT' 			    TRX_LEVEL_TYPE
               ,pohzd.trx_line_id		    TRX_LINE_ID
               ,pohzd.trx_line_number		    TRX_LINE_NUMBER
               ,pohzd.trx_number		    TRX_NUMBER
               ,pohzd.unit_price		    UNIT_PRICE
               ,NULL				    ACCOUNT_CCID
               ,NULL				    ACCOUNT_STRING
               ,NULL				    ADJUSTED_DOC_TAX_DIST_ID
               ,NULL				    APPLIED_FROM_TAX_DIST_ID
               ,NULL				    APPLIED_TO_DOC_CURR_CONV_RATE
               ,NULL			            AWARD_ID
               ,pohzd.p_expenditure_item_date	    EXPENDITURE_ITEM_DATE
               ,pohzd.p_expenditure_organization_id EXPENDITURE_ORGANIZATION_ID
               ,pohzd.p_expenditure_type	    EXPENDITURE_TYPE
               ,NULL				    FUNC_CURR_ROUNDING_ADJUSTMENT
               ,NULL			            GL_DATE
               ,NULL				    INTENDED_USE
               ,NULL				    ITEM_DIST_NUMBER
               ,NULL				    MRC_LINK_TO_TAX_DIST_ID
               ,NULL				    ORIG_REC_NREC_RATE
               ,NULL				    ORIG_REC_NREC_TAX_AMT
               ,NULL				    ORIG_REC_NREC_TAX_AMT_TAX_CURR
               ,NULL				    ORIG_REC_RATE_CODE
               ,NULL				    PER_TRX_CURR_UNIT_NR_AMT
               ,NULL				    PER_UNIT_NREC_TAX_AMT
               ,NULL				    PRD_TAX_AMT
               ,NULL				    PRICE_DIFF
               ,pohzd.p_project_id		    PROJECT_ID
               ,NULL				    QTY_DIFF
               ,NULL				    RATE_TAX_FACTOR
               ,DECODE(tmp.rec_flag,
                 'Y', NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate), 0),
                 'N', 100 - NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate), 0))
                                                    REC_NREC_RATE
               ,DECODE(tmp.rec_flag,
                       'N',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                       'Y',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                 (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                  NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                     (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                      )                             REC_NREC_TAX_AMT
               ,DECODE(tmp.rec_flag,
                       'N',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                       'Y',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                 (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                  NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                     (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                      )                             REC_NREC_TAX_AMT_FUNCL_CURR
               ,DECODE(tmp.rec_flag,
                        'N',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0)),
                          ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                 nvl(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                    (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)),
                       'Y',
                        DECODE(fc.Minimum_Accountable_Unit,null,
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0), NVL(FC.precision,0)) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) * nvl(pohzd.p_quantity_ordered,0) *
                                 (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)), (100 - nvl(pohzd.p_recovery_rate,0))),0)/100) ,NVL(FC.precision,0))),
                         (ROUND((NVL(pohzd.unit_price, 0)) * (NVL(pohzd.tax_rate,0)/100) * NVL(pohzd.p_quantity_ordered,0)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit) -
                           ROUND((NVL(pohzd.unit_price, 0))* (nvl(pohzd.tax_rate,0)/100) *
                                  NVL(pohzd.p_quantity_ordered,0) * (nvl(decode(pohzd.p_recovery_rate,null,(100 - nvl(pohzd.d_rec_rate,0)),
                                     (100 - nvl(pohzd.p_recovery_rate,0))),0)/100)/FC.Minimum_Accountable_Unit)* (FC.Minimum_Accountable_Unit)))
                      )                             REC_NREC_TAX_AMT_TAX_CURR
               ,NVL(rates.tax_rate_code,
                             'AD_HOC_RECOVERY')     RECOVERY_RATE_CODE
               ,rates.tax_rate_id                   RECOVERY_RATE_ID
               ,DECODE(tmp.rec_flag,'N', NULL,
                      NVL(rates.recovery_type_code,
                          'STANDARD'))              RECOVERY_TYPE_CODE
               ,NULL				    RECOVERY_TYPE_ID
               ,NULL				    REF_DOC_CURR_CONV_RATE
               ,NULL				    REF_DOC_DIST_ID
               ,NULL				    REF_DOC_PER_UNIT_NREC_TAX_AMT
               ,NULL				    REF_DOC_TAX_DIST_ID
               ,NULL				    REF_DOC_TRX_LINE_DIST_QTY
               ,NULL				    REF_DOC_UNIT_PRICE
               ,NULL				    REF_PER_TRX_CURR_UNIT_NR_AMT
               ,NULL				    REVERSED_TAX_DIST_ID
               ,NULL				    ROUNDING_RULE_CODE
               ,pohzd.p_task_id			    TASK_ID
               ,null				    TAXABLE_AMT_FUNCL_CURR
               ,NULL				    TAXABLE_AMT_TAX_CURR
               ,NULL				    TRX_LINE_DIST_AMT
               ,pohzd.p_po_distribution_id	    TRX_LINE_DIST_ID
               ,NULL				    TRX_LINE_DIST_QTY
               ,NULL				    TRX_LINE_DIST_TAX_AMT
               ,NULL				    UNROUNDED_REC_NREC_TAX_AMT
               ,NULL				    UNROUNDED_TAXABLE_AMT
               ,NULL				    TAXABLE_AMT
               ,pohzd.p_ATTRIBUTE_CATEGORY          ATTRIBUTE_CATEGORY
               ,pohzd.p_ATTRIBUTE1                  ATTRIBUTE1
               ,pohzd.p_ATTRIBUTE2                  ATTRIBUTE2
               ,pohzd.p_ATTRIBUTE3                  ATTRIBUTE3
               ,pohzd.p_ATTRIBUTE4                  ATTRIBUTE4
               ,pohzd.p_ATTRIBUTE5                  ATTRIBUTE5
               ,pohzd.p_ATTRIBUTE6                  ATTRIBUTE6
               ,pohzd.p_ATTRIBUTE7                  ATTRIBUTE7
               ,pohzd.p_ATTRIBUTE8                  ATTRIBUTE8
               ,pohzd.p_ATTRIBUTE9                  ATTRIBUTE9
               ,pohzd.p_ATTRIBUTE10                 ATTRIBUTE10
               ,pohzd.p_ATTRIBUTE11                 ATTRIBUTE11
               ,pohzd.p_ATTRIBUTE12                 ATTRIBUTE12
               ,pohzd.p_ATTRIBUTE13                 ATTRIBUTE13
               ,pohzd.p_ATTRIBUTE14                 ATTRIBUTE14
               ,pohzd.p_ATTRIBUTE15                 ATTRIBUTE15
               ,'Y'			            HISTORICAL_FLAG
               ,'N'			            OVERRIDDEN_FLAG
               ,'N'			            SELF_ASSESSED_FLAG
               ,'Y'			            TAX_APPORTIONMENT_FLAG
               ,'N'			            TAX_ONLY_LINE_FLAG
               ,'N'			            INCLUSIVE_FLAG
               ,'N'			            MRC_TAX_DIST_FLAG
               ,'N'			            REC_TYPE_RULE_FLAG
               ,'N'			            NEW_REC_RATE_CODE_FLAG
               ,tmp.rec_flag                        RECOVERABLE_FLAG
               ,'N'			            REVERSE_FLAG
               ,'N'			            REC_RATE_DET_RULE_FLAG
               ,'Y'			            BACKWARD_COMPATIBILITY_FLAG
               ,'N'			            FREEZE_FLAG
               ,'N'			            POSTING_FLAG
               ,NVL(pohzd.legal_entity_id, -99)	    LEGAL_ENTITY_ID
               ,1			            CREATED_BY
               ,SYSDATE		                    CREATION_DATE
               ,NULL		                    LAST_MANUAL_ENTRY
               ,SYSDATE		                    LAST_UPDATE_DATE
               ,1			            LAST_UPDATE_LOGIN
               ,1			            LAST_UPDATED_BY
               ,1			            OBJECT_VERSION_NUMBER
          FROM (SELECT /*+ use_nl_with_index(recdist ZX_PO_REC_DIST_N1) */
                       pohzd.*,
                       recdist.rec_rate     d_rec_rate
                 FROM (SELECT /*+ NO_EXPAND leading(poh) use_nl_with_index(zxl, ZX_LINES_U1) use_nl(pod) */
                             poh.po_header_id,
                             poll.last_update_date poll_last_update_date,
                             fsp.set_of_books_id,
                             zxl.*,
                             pod.po_distribution_id                  p_po_distribution_id,
                             pod.expenditure_item_date               p_expenditure_item_date,
                             pod.expenditure_organization_id         p_expenditure_organization_id,
                             pod.expenditure_type                    p_expenditure_type,
                             pod.project_id                          p_project_id,
                             pod.task_id                             p_task_id,
                             pod.recovery_rate                       p_recovery_rate,
                             pod.quantity_ordered                    p_quantity_ordered,
                             pod.attribute_category                  p_attribute_category ,
                             pod.attribute1                          p_attribute1,
                             pod.attribute2                          p_attribute2,
                             pod.attribute3                          p_attribute3,
                             pod.attribute4                          p_attribute4,
                             pod.attribute5                          p_attribute5,
                             pod.attribute6                          p_attribute6,
                             pod.attribute7                          p_attribute7,
                             pod.attribute8                          p_attribute8,
                             pod.attribute9                          p_attribute9,
                             pod.attribute10                         p_attribute10,
                             pod.attribute11                         p_attribute11,
                             pod.attribute12                         p_attribute12,
                             pod.attribute13                         p_attribute13,
                             pod.attribute14                         p_attribute14,
                             pod.attribute15                         p_attribute15
                        FROM (select distinct other_doc_application_id, other_doc_trx_id
                                from ZX_VALIDATION_ERRORS_GT
                               where other_doc_application_id = 201
                                 and other_doc_entity_code = 'RELEASE'
                                 and other_doc_event_class_code = 'RELEASE')
                             zxvalerr,
                             po_line_locations_all poll,
                             po_headers_all poh,
                      	     financials_system_params_all fsp,
                             zx_lines zxl,
                             po_distributions_all pod
                       WHERE poll.po_release_id = zxvalerr.other_doc_trx_id
                         AND poh.po_header_id = poll.po_header_id
                         AND NVL(poh.org_id, -99) = NVL(fsp.org_id, -99)
                         AND zxl.application_id = 201
                         AND zxl.entity_code = 'RELEASE'
                         AND zxl.event_class_code = 'RELEASE'
                         AND zxl.trx_id = poll.po_release_id
                         AND zxl.trx_line_id = poll.line_location_id
                         AND NOT EXISTS
                             (SELECT 1 FROM zx_transaction_lines_gt lines_gt
                               WHERE lines_gt.application_id   = 201
                                 AND lines_gt.event_class_code = 'RELEASE'
                                 AND lines_gt.entity_code      = 'RELEASE'
                                 AND lines_gt.trx_id           = poll.po_release_id
                                 AND lines_gt.trx_line_id      = poll.line_location_id
                                 AND lines_gt.trx_level_type   = 'SHIPMENT'
                                 AND NVL(lines_gt.line_level_action, 'X') = 'CREATE'
                             )
                         AND pod.po_header_id = poll.po_header_id
                         AND pod.line_location_id = poll.line_location_id
                      ) pohzd,
                      zx_po_rec_dist recdist
                WHERE recdist.po_header_id(+) = pohzd.trx_id
                  AND recdist.po_line_location_id(+) = pohzd.trx_line_id
                  AND recdist.po_distribution_id(+) = pohzd.p_po_distribution_id
                  AND recdist.tax_rate_id(+) = pohzd.tax_rate_id
               ) pohzd,
               fnd_currencies fc,
               zx_rates_b rates,
               (SELECT 'Y' rec_flag FROM dual UNION ALL SELECT 'N' rec_flag FROM dual) tmp
         WHERE pohzd.trx_currency_code = fc.currency_code(+)
           AND rates.tax_regime_code(+) = pohzd.tax_regime_code
           AND rates.tax(+) = pohzd.tax
           AND rates.content_owner_id(+) = pohzd.content_owner_id
           AND rates.rate_type_code(+) = 'RECOVERY'
           AND rates.recovery_type_code(+) = 'STANDARD'
           AND rates.active_flag(+) = 'Y'
           AND rates.effective_from(+) <= sysdate
           --Bug 8724131
           --AND (rates.effective_to IS NULL OR rates.effective_to >= sysdate)
           --Bug 8752951
           AND pohzd.poll_last_update_date BETWEEN rates.effective_from AND NVL(rates.effective_to, pohzd.poll_last_update_date)
           AND rates.record_type_code(+) = 'MIGRATED'
           AND rates.percentage_rate(+) = NVL(NVL(pohzd.p_recovery_rate, pohzd.d_rec_rate),0)
           AND rates.tax_rate_code(+) NOT LIKE 'AD_HOC_RECOVERY%';

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                   'Number of Rows Inserted = ' || TO_CHAR(SQL%ROWCOUNT));
  END IF;




  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                  'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po.END',
                  'ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po.END',
                    'ZX_ON_FLY_TRX_UPGRADE_PO_PKG.upgrade_trx_on_fly_blk_po(-)');
    END IF;

END upgrade_trx_on_fly_blk_po;

END ZX_ON_FLY_TRX_UPGRADE_PO_PKG;


/
