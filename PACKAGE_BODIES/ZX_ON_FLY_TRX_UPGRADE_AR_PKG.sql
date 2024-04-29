--------------------------------------------------------
--  DDL for Package Body ZX_ON_FLY_TRX_UPGRADE_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ON_FLY_TRX_UPGRADE_AR_PKG" AS
/* $Header: zxmigtrxflyarb.pls 120.16.12010000.6 2010/04/08 12:33:25 ssohal ship $ */

 g_current_runtime_level      NUMBER;
 g_level_statement            CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure            CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_level_event                CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
 g_level_unexpected           CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;

-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- upgrade_trx_on_fly_ar
--
-- DESCRIPTION
-- on the fly migration of one transaction for AR
--
-------------------------------------------------------------------------------

PROCEDURE upgrade_trx_on_fly_ar(
  p_upg_trx_info_rec     IN          ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
) AS
  l_multi_org_flag            VARCHAR2(1);
  l_org_id                    NUMBER;
  l_inv_installed             VARCHAR2(1);
  l_inv_flag                  VARCHAR2(1);
  l_industry                  VARCHAR2(10);
  l_fnd_return                BOOLEAN;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_ar.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_PKG.upgrade_trx_on_fly_ar(+)');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT NVL(multi_org_flag, 'N') INTO l_multi_org_flag FROM FND_PRODUCT_GROUPS;
  -- for single org environment, get value of org_id from profile
  IF l_multi_org_flag = 'N' THEN
    FND_PROFILE.GET('ORG_ID',l_org_id);
    IF l_org_id is NULL THEN
      l_org_id := -99;
    END IF;
  END IF;

  l_fnd_return := FND_INSTALLATION.GET(401,401, l_inv_flag, l_industry);

  if (l_inv_flag = 'I') then
      l_inv_installed := 'Y';
  else
      l_inv_installed := 'N';
  end if;


    INSERT ALL
      WHEN trx_line_type IN ('LINE' ,'CB') THEN
    INTO ZX_LINES_DET_FACTORS(
            INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_CLASS_MAPPING_ID
           ,EVENT_TYPE_CODE
           ,DOC_EVENT_STATUS
           ,LINE_LEVEL_ACTION
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_DATE
           --,TRX_DOC_REVISION
           ,LEDGER_ID
           ,TRX_CURRENCY_CODE
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,LEGAL_ENTITY_ID
           --,ESTABLISHMENT_ID
           ,RECEIVABLES_TRX_TYPE_ID
           ,DEFAULT_TAXATION_COUNTRY
           ,TRX_NUMBER
           ,TRX_LINE_NUMBER
           ,TRX_LINE_DESCRIPTION
           --,TRX_DESCRIPTION
           --,TRX_COMMUNICATED_DATE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,TRX_DUE_DATE
           ,TRX_TYPE_DESCRIPTION
           ,DOCUMENT_SUB_TYPE
           --,SUPPLIER_TAX_INVOICE_NUMBER
           --,SUPPLIER_TAX_INVOICE_DATE
           --,SUPPLIER_EXCHANGE_RATE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,FIRST_PTY_ORG_ID
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           --,LINE_INTENDED_USE
           ,TRX_LINE_TYPE
           --,TRX_SHIPPING_DATE
           --,TRX_RECEIPT_DATE
           --,TRX_SIC_CODE
           ,FOB_POINT
           ,TRX_WAYBILL_NUMBER
           ,PRODUCT_ID
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ORG_ID
           ,UOM_CODE
           --,PRODUCT_TYPE
           --,PRODUCT_CODE
           ,PRODUCT_CATEGORY
           ,PRODUCT_DESCRIPTION
           ,USER_DEFINED_FISC_CLASS
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           --,CASH_DISCOUNT
           --,VOLUME_DISCOUNT
           --,TRADING_DISCOUNT
           --,TRANSFER_CHARGE
           --,TRANSPORTATION_CHARGE
           --,INSURANCE_CHARGE
           --,OTHER_CHARGE
           --,ASSESSABLE_VALUE
           --,ASSET_FLAG
           --,ASSET_NUMBER
           ,ASSET_ACCUM_DEPRECIATION
           --,ASSET_TYPE
           ,ASSET_COST
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE --- Bug6024643
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           ,TRX_BUSINESS_CATEGORY
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPTION_CONTROL_FLAG
           ,EXEMPT_REASON_CODE
           ,HISTORICAL_FLAG
           ,TRX_LINE_GL_DATE
           ,LINE_AMT_INCLUDES_TAX_FLAG
           --,ACCOUNT_CCID
           --,ACCOUNT_STRING
           --,SHIP_TO_LOCATION_ID
           --,SHIP_FROM_LOCATION_ID
           --,POA_LOCATION_ID
           --,POO_LOCATION_ID
           --,BILL_TO_LOCATION_ID
           --,BILL_FROM_LOCATION_ID
           --,PAYING_LOCATION_ID
           --,OWN_HQ_LOCATION_ID
           --,TRADING_HQ_LOCATION_ID
           --,POC_LOCATION_ID
           --,POI_LOCATION_ID
           --,POD_LOCATION_ID
           --,TITLE_TRANSFER_LOCATION_ID
           ,CTRL_HDR_TX_APPL_FLAG
           --,CTRL_TOTAL_LINE_TX_AMT
           --,CTRL_TOTAL_HDR_TX_AMT
           ,LINE_CLASS
           ,TRX_LINE_DATE
           --,INPUT_TAX_CLASSIFICATION_CODE
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           --,INTERNAL_ORG_LOCATION_ID
           --,PORT_OF_ENTRY_CODE
           ,TAX_REPORTING_FLAG
           ,TAX_AMT_INCLUDED_FLAG
           ,COMPOUNDING_TAX_FLAG
           --,EVENT_ID
           ,THRESHOLD_INDICATOR_FLAG
           --,PROVNL_TAX_DETERMINATION_DATE
           ,UNIT_PRICE
           ,SHIP_TO_CUST_ACCT_SITE_USE_ID
           ,BILL_TO_CUST_ACCT_SITE_USE_ID
           ,TRX_BATCH_ID
           --,START_EXPENSE_DATE
           --,SOURCE_APPLICATION_ID
           --,SOURCE_ENTITY_CODE
           --,SOURCE_EVENT_CLASS_CODE
           --,SOURCE_TRX_ID
           --,SOURCE_LINE_ID
           --,SOURCE_TRX_LEVEL_TYPE
           ,RECORD_TYPE_CODE
           ,INCLUSIVE_TAX_OVERRIDE_FLAG
           ,TAX_PROCESSING_COMPLETED_FLAG
           ,OBJECT_VERSION_NUMBER
           ,APPLICATION_DOC_STATUS
           ,USER_UPD_DET_FACTORS_FLAG
           --,SOURCE_TAX_LINE_ID
           --,REVERSED_APPLN_ID
           --,REVERSED_ENTITY_CODE
           --,REVERSED_EVNT_CLS_CODE
           --,REVERSED_TRX_ID
           --,REVERSED_TRX_LEVEL_TYPE
           --,REVERSED_TRX_LINE_ID
           --,TAX_CALCULATION_DONE_FLAG
           ,PARTNER_MIGRATED_FLAG
           ,SHIP_THIRD_PTY_ACCT_SITE_ID
           ,BILL_THIRD_PTY_ACCT_SITE_ID
           ,SHIP_THIRD_PTY_ACCT_ID
           ,BILL_THIRD_PTY_ACCT_ID
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_LINE_ID
           --,HISTORICAL_TAX_CODE_ID
           --,ICX_SESSION_ID
           --,TRX_LINE_CURRENCY_CODE
           --,TRX_LINE_CURRENCY_CONV_RATE
           --,TRX_LINE_CURRENCY_CONV_DATE
           --,TRX_LINE_PRECISION
           --,TRX_LINE_MAU
           --,TRX_LINE_CURRENCY_CONV_TYPE
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
         )
         VALUES (
            INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_CLASS_MAPPING_ID
           ,EVENT_TYPE_CODE
           ,DOC_EVENT_STATUS
           ,LINE_LEVEL_ACTION
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_DATE
           --,TRX_DOC_REVISION
           ,LEDGER_ID
           ,TRX_CURRENCY_CODE
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,LEGAL_ENTITY_ID
           --,ESTABLISHMENT_ID
           ,RECEIVABLES_TRX_TYPE_ID
           ,DEFAULT_TAXATION_COUNTRY
           ,TRX_NUMBER
           ,TRX_LINE_NUMBER
           ,TRX_LINE_DESCRIPTION
           --,TRX_DESCRIPTION
           --,TRX_COMMUNICATED_DATE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,TRX_DUE_DATE
           ,TRX_TYPE_DESCRIPTION
           ,DOCUMENT_SUB_TYPE
           --,SUPPLIER_TAX_INVOICE_NUMBER
           --,SUPPLIER_TAX_INVOICE_DATE
           --,SUPPLIER_EXCHANGE_RATE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,FIRST_PTY_ORG_ID
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           --,LINE_INTENDED_USE
           ,TRX_LINE_TYPE
           --,TRX_SHIPPING_DATE
           --,TRX_RECEIPT_DATE
           --,TRX_SIC_CODE
           ,FOB_POINT
           ,TRX_WAYBILL_NUMBER
           ,PRODUCT_ID
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ORG_ID
           ,UOM_CODE
           --,PRODUCT_TYPE
           --,PRODUCT_CODE
           ,PRODUCT_CATEGORY
           ,PRODUCT_DESCRIPTION
           ,USER_DEFINED_FISC_CLASS
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           --,CASH_DISCOUNT
           --,VOLUME_DISCOUNT
           --,TRADING_DISCOUNT
           --,TRANSFER_CHARGE
           --,TRANSPORTATION_CHARGE
           --,INSURANCE_CHARGE
           --,OTHER_CHARGE
           --,ASSESSABLE_VALUE
           --,ASSET_FLAG
           --,ASSET_NUMBER
           ,ASSET_ACCUM_DEPRECIATION
           --,ASSET_TYPE
           ,ASSET_COST
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE  --- Bug6024643
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           ,TRX_BUSINESS_CATEGORY
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPTION_CONTROL_FLAG
           ,EXEMPT_REASON_CODE
           ,'Y'    --HISTORICAL_FLAG
           ,TRX_LINE_GL_DATE
           ,'N'    --LINE_AMT_INCLUDES_TAX_FLAG
           --,ACCOUNT_CCID
           --,ACCOUNT_STRING
           --,SHIP_TO_LOCATION_ID
           --,SHIP_FROM_LOCATION_ID
           --,POA_LOCATION_ID
           --,POO_LOCATION_ID
           --,BILL_TO_LOCATION_ID
           --,BILL_FROM_LOCATION_ID
           --,PAYING_LOCATION_ID
           --,OWN_HQ_LOCATION_ID
           --,TRADING_HQ_LOCATION_ID
           --,POC_LOCATION_ID
           --,POI_LOCATION_ID
           --,POD_LOCATION_ID
           --,TITLE_TRANSFER_LOCATION_ID
           ,'N'   --CTRL_HDR_TX_APPL_FLAG
           --,CTRL_TOTAL_LINE_TX_AMT
           --,CTRL_TOTAL_HDR_TX_AMT
           ,LINE_CLASS
           ,TRX_LINE_DATE
           --,INPUT_TAX_CLASSIFICATION_CODE
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           --,INTERNAL_ORG_LOCATION_ID
           --,PORT_OF_ENTRY_CODE
           ,'Y'   --TAX_REPORTING_FLAG
           ,'N'   --TAX_AMT_INCLUDED_FLAG
           ,'N'   --COMPOUNDING_TAX_FLAG
           --,EVENT_ID
           ,'N'   --THRESHOLD_INDICATOR_FLAG
           --,PROVNL_TAX_DETERMINATION_DATE
           ,UNIT_PRICE
           ,SHIP_TO_CUST_ACCT_SITE_USE_ID
           ,BILL_TO_CUST_ACCT_SITE_USE_ID
           ,TRX_BATCH_ID
           --,START_EXPENSE_DATE
           --,SOURCE_APPLICATION_ID
           --,SOURCE_ENTITY_CODE
           --,SOURCE_EVENT_CLASS_CODE
           --,SOURCE_TRX_ID
           --,SOURCE_LINE_ID
           --,SOURCE_TRX_LEVEL_TYPE
           ,'MIGRATED'     --RECORD_TYPE_CODE
           ,'N'     --INCLUSIVE_TAX_OVERRIDE_FLAG
           ,'N'     --TAX_PROCESSING_COMPLETED_FLAG
           ,OBJECT_VERSION_NUMBER
           ,APPLICATION_DOC_STATUS
           ,'N'     --USER_UPD_DET_FACTORS_FLAG
           --,SOURCE_TAX_LINE_ID
           --,REVERSED_APPLN_ID
           --,REVERSED_ENTITY_CODE
           --,REVERSED_EVNT_CLS_CODE
           --,REVERSED_TRX_ID
           --,REVERSED_TRX_LEVEL_TYPE
           --,REVERSED_TRX_LINE_ID
           --,TAX_CALCULATION_DONE_FLAG
           ,PARTNER_MIGRATED_FLAG
           ,SHIP_THIRD_PTY_ACCT_SITE_ID
           ,BILL_THIRD_PTY_ACCT_SITE_ID
           ,SHIP_THIRD_PTY_ACCT_ID
           ,BILL_THIRD_PTY_ACCT_ID
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_LINE_ID
           --,HISTORICAL_TAX_CODE_ID
           --,ICX_SESSION_ID
           --,TRX_LINE_CURRENCY_CODE
           --,TRX_LINE_CURRENCY_CONV_RATE
           --,TRX_LINE_CURRENCY_CONV_DATE
           --,TRX_LINE_PRECISION
           --,TRX_LINE_MAU
           --,TRX_LINE_CURRENCY_CONV_TYPE
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
         )
      WHEN (trx_line_type = 'TAX') THEN
    INTO ZX_LINES (
            TAX_LINE_ID
           ,INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_NUMBER
           ,DOC_EVENT_STATUS
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_LINE_NUMBER
           ,CONTENT_OWNER_ID
           ,TAX_REGIME_ID
           ,TAX_REGIME_CODE
           ,TAX_ID
           ,TAX
           ,TAX_STATUS_ID
           ,TAX_STATUS_CODE
           ,TAX_RATE_ID
           ,TAX_RATE_CODE
           ,TAX_RATE
           ,TAX_RATE_TYPE
           ,TAX_APPORTIONMENT_LINE_NUMBER
           ,MRC_TAX_LINE_FLAG
           ,LEDGER_ID
           --,ESTABLISHMENT_ID
           ,LEGAL_ENTITY_ID
           --,LEGAL_ENTITY_TAX_REG_NUMBER
           --,HQ_ESTB_REG_NUMBER
           --,HQ_ESTB_PARTY_TAX_PROF_ID
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_TYPE
           ,CURRENCY_CONVERSION_RATE
           --,TAX_CURRENCY_CONVERSION_DATE
           --,TAX_CURRENCY_CONVERSION_TYPE
           --,TAX_CURRENCY_CONVERSION_RATE
           ,TRX_CURRENCY_CODE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,TRX_NUMBER
           ,TRX_DATE
           ,UNIT_PRICE
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           ,TAX_BASE_MODIFIER_RATE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           --,OTHER_DOC_LINE_AMT
           --,OTHER_DOC_LINE_TAX_AMT
           --,OTHER_DOC_LINE_TAXABLE_AMT
           ,UNROUNDED_TAXABLE_AMT
           ,UNROUNDED_TAX_AMT
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           --,RELATED_DOC_TRX_LEVEL_TYPE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE  --- Bug6024643
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,SUMMARY_TAX_LINE_ID
           --,OFFSET_LINK_TO_TAX_LINE_ID
           ,OFFSET_FLAG
           ,PROCESS_FOR_RECOVERY_FLAG
           --,TAX_JURISDICTION_ID
           --,TAX_JURISDICTION_CODE
           --,PLACE_OF_SUPPLY
           ,PLACE_OF_SUPPLY_TYPE_CODE
           --,PLACE_OF_SUPPLY_RESULT_ID
           --,TAX_DATE_RULE_ID
           ,TAX_DATE
           ,TAX_DETERMINE_DATE
           ,TAX_POINT_DATE
           ,TRX_LINE_DATE
           ,TAX_TYPE_CODE
           --,TAX_CODE
           --,TAX_REGISTRATION_ID
           --,TAX_REGISTRATION_NUMBER
           --,REGISTRATION_PARTY_TYPE
           ,ROUNDING_LEVEL_CODE
           ,ROUNDING_RULE_CODE
           --,ROUNDING_LVL_PARTY_TAX_PROF_ID
           --,ROUNDING_LVL_PARTY_TYPE
           ,COMPOUNDING_TAX_FLAG
           --,ORIG_TAX_STATUS_ID
           --,ORIG_TAX_STATUS_CODE
           --,ORIG_TAX_RATE_ID
           --,ORIG_TAX_RATE_CODE
           --,ORIG_TAX_RATE
           --,ORIG_TAX_JURISDICTION_ID
           --,ORIG_TAX_JURISDICTION_CODE
           --,ORIG_TAX_AMT_INCLUDED_FLAG
           --,ORIG_SELF_ASSESSED_FLAG
           ,TAX_CURRENCY_CODE
           ,TAX_AMT
           ,TAX_AMT_TAX_CURR
           ,TAX_AMT_FUNCL_CURR
           ,TAXABLE_AMT
           ,TAXABLE_AMT_TAX_CURR
           ,TAXABLE_AMT_FUNCL_CURR
           --,ORIG_TAXABLE_AMT
           --,ORIG_TAXABLE_AMT_TAX_CURR
           ,CAL_TAX_AMT
           ,CAL_TAX_AMT_TAX_CURR
           ,CAL_TAX_AMT_FUNCL_CURR
           --,ORIG_TAX_AMT
           --,ORIG_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT
           --,REC_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT_FUNCL_CURR
           --,NREC_TAX_AMT
           --,NREC_TAX_AMT_TAX_CURR
           --,NREC_TAX_AMT_FUNCL_CURR
           ,TAX_EXEMPTION_ID
           --,TAX_RATE_BEFORE_EXEMPTION
           --,TAX_RATE_NAME_BEFORE_EXEMPTION
           --,EXEMPT_RATE_MODIFIER
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPT_REASON_CODE
           ,TAX_EXCEPTION_ID
           ,TAX_RATE_BEFORE_EXCEPTION
           --,TAX_RATE_NAME_BEFORE_EXCEPTION
           --,EXCEPTION_RATE
           ,TAX_APPORTIONMENT_FLAG
           ,HISTORICAL_FLAG
           ,TAXABLE_BASIS_FORMULA
           ,TAX_CALCULATION_FORMULA
           ,CANCEL_FLAG
           ,PURGE_FLAG
           ,DELETE_FLAG
           ,TAX_AMT_INCLUDED_FLAG
           ,SELF_ASSESSED_FLAG
           ,OVERRIDDEN_FLAG
           ,MANUALLY_ENTERED_FLAG
           ,REPORTING_ONLY_FLAG
           ,FREEZE_UNTIL_OVERRIDDEN_FLAG
           ,COPIED_FROM_OTHER_DOC_FLAG
           ,RECALC_REQUIRED_FLAG
           ,SETTLEMENT_FLAG
           ,ITEM_DIST_CHANGED_FLAG
           ,ASSOCIATED_CHILD_FROZEN_FLAG
           ,TAX_ONLY_LINE_FLAG
           ,COMPOUNDING_DEP_TAX_FLAG
           ,ENFORCE_FROM_NATURAL_ACCT_FLAG
           ,COMPOUNDING_TAX_MISS_FLAG
           ,SYNC_WITH_PRVDR_FLAG
           ,LAST_MANUAL_ENTRY
           ,TAX_PROVIDER_ID
           ,RECORD_TYPE_CODE
           --,REPORTING_PERIOD_ID
           --,LEGAL_MESSAGE_APPL_2
           --,LEGAL_MESSAGE_STATUS
           --,LEGAL_MESSAGE_RATE
           --,LEGAL_MESSAGE_BASIS
           --,LEGAL_MESSAGE_CALC
           --,LEGAL_MESSAGE_THRESHOLD
           --,LEGAL_MESSAGE_POS
           --,LEGAL_MESSAGE_TRN
           --,LEGAL_MESSAGE_EXMPT
           --,LEGAL_MESSAGE_EXCPT
           --,TAX_REGIME_TEMPLATE_ID
           --,TAX_APPLICABILITY_RESULT_ID
           --,DIRECT_RATE_RESULT_ID
           --,STATUS_RESULT_ID
           --,RATE_RESULT_ID
           --,BASIS_RESULT_ID
           --,THRESH_RESULT_ID
           --,CALC_RESULT_ID
           --,TAX_REG_NUM_DET_RESULT_ID
           --,EVAL_EXMPT_RESULT_ID
           --,EVAL_EXCPT_RESULT_ID
           --,TAX_HOLD_CODE
           --,TAX_HOLD_RELEASED_CODE
           --,PRD_TOTAL_TAX_AMT
           --,PRD_TOTAL_TAX_AMT_TAX_CURR
           --,PRD_TOTAL_TAX_AMT_FUNCL_CURR
           --,INTERNAL_ORG_LOCATION_ID
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
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,GLOBAL_ATTRIBUTE2
           ,GLOBAL_ATTRIBUTE3
           ,GLOBAL_ATTRIBUTE4
           ,GLOBAL_ATTRIBUTE5
           ,GLOBAL_ATTRIBUTE6
           ,GLOBAL_ATTRIBUTE7
           ,GLOBAL_ATTRIBUTE8
           ,GLOBAL_ATTRIBUTE9
           ,GLOBAL_ATTRIBUTE10
           ,GLOBAL_ATTRIBUTE11
           ,GLOBAL_ATTRIBUTE12
           ,GLOBAL_ATTRIBUTE13
           ,GLOBAL_ATTRIBUTE14
           ,GLOBAL_ATTRIBUTE15
           ,GLOBAL_ATTRIBUTE16
           ,GLOBAL_ATTRIBUTE17
           ,GLOBAL_ATTRIBUTE18
           ,GLOBAL_ATTRIBUTE19
           ,GLOBAL_ATTRIBUTE20
           ,LEGAL_JUSTIFICATION_TEXT1
           ,LEGAL_JUSTIFICATION_TEXT2
           ,LEGAL_JUSTIFICATION_TEXT3
           --,REPORTING_CURRENCY_CODE
           --,LINE_ASSESSABLE_VALUE
           --,TRX_LINE_INDEX
           --,OFFSET_TAX_RATE_CODE
           --,PRORATION_CODE
           --,OTHER_DOC_SOURCE
           --,CTRL_TOTAL_LINE_TX_AMT
           --,MRC_LINK_TO_TAX_LINE_ID
           --,APPLIED_TO_TRX_NUMBER
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_TAX_LINE_ID
           --,TAXING_JURIS_GEOGRAPHY_ID
 	   ,NUMERIC1
           ,NUMERIC2
           ,NUMERIC3
           ,NUMERIC4
           ,ADJUSTED_DOC_TAX_LINE_ID
           ,OBJECT_VERSION_NUMBER
           ,MULTIPLE_JURISDICTIONS_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,LEGAL_REPORTING_STATUS
           ,ACCOUNT_SOURCE_TAX_RATE_ID
         )
         VALUES(
            TAX_LINE_ID
           ,INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_NUMBER
           ,DOC_EVENT_STATUS
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_LINE_NUMBER
           ,CONTENT_OWNER_ID
           ,TAX_REGIME_ID
           ,TAX_REGIME_CODE
           ,TAX_ID
           ,TAX
           ,TAX_STATUS_ID
           ,TAX_STATUS_CODE
           ,TAX_RATE_ID
           ,TAX_RATE_CODE
           ,TAX_RATE
           ,TAX_RATE_TYPE
           ,TAX_APPORTIONMENT_LINE_NUMBER
           ,'N'    --MRC_TAX_LINE_FLAG
           ,LEDGER_ID
           --,ESTABLISHMENT_ID
           ,LEGAL_ENTITY_ID
           --,LEGAL_ENTITY_TAX_REG_NUMBER
           --,HQ_ESTB_REG_NUMBER
           --,HQ_ESTB_PARTY_TAX_PROF_ID
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_TYPE
           ,CURRENCY_CONVERSION_RATE
           --,TAX_CURRENCY_CONVERSION_DATE
           --,TAX_CURRENCY_CONVERSION_TYPE
           --,TAX_CURRENCY_CONVERSION_RATE
           ,TRX_CURRENCY_CODE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,TRX_NUMBER
           ,TRX_DATE
           ,UNIT_PRICE
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           ,TAX_BASE_MODIFIER_RATE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           --,OTHER_DOC_LINE_AMT
           --,OTHER_DOC_LINE_TAX_AMT
           --,OTHER_DOC_LINE_TAXABLE_AMT
           ,UNROUNDED_TAXABLE_AMT
           ,UNROUNDED_TAX_AMT
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           --,RELATED_DOC_TRX_LEVEL_TYPE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           ,ADJUSTED_DOC_EVENT_CLASS_CODE  --- Bug6024643
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,SUMMARY_TAX_LINE_ID
           --,OFFSET_LINK_TO_TAX_LINE_ID
           ,'N'   --OFFSET_FLAG
           ,'N'   --PROCESS_FOR_RECOVERY_FLAG
           --,TAX_JURISDICTION_ID
           --,TAX_JURISDICTION_CODE
           --,PLACE_OF_SUPPLY
           ,PLACE_OF_SUPPLY_TYPE_CODE
           --,PLACE_OF_SUPPLY_RESULT_ID
           --,TAX_DATE_RULE_ID
           ,TAX_DATE
           ,TAX_DETERMINE_DATE
           ,TAX_POINT_DATE
           ,TRX_LINE_DATE
           ,TAX_TYPE_CODE
           --,TAX_CODE
           --,TAX_REGISTRATION_ID
           --,TAX_REGISTRATION_NUMBER
           --,REGISTRATION_PARTY_TYPE
           ,ROUNDING_LEVEL_CODE
           ,ROUNDING_RULE_CODE
           --,ROUNDING_LVL_PARTY_TAX_PROF_ID
           --,ROUNDING_LVL_PARTY_TYPE
           ,'N'   --COMPOUNDING_TAX_FLAG
           --,ORIG_TAX_STATUS_ID
           --,ORIG_TAX_STATUS_CODE
           --,ORIG_TAX_RATE_ID
           --,ORIG_TAX_RATE_CODE
           --,ORIG_TAX_RATE
           --,ORIG_TAX_JURISDICTION_ID
           --,ORIG_TAX_JURISDICTION_CODE
           --,ORIG_TAX_AMT_INCLUDED_FLAG
           --,ORIG_SELF_ASSESSED_FLAG
           ,TAX_CURRENCY_CODE
           ,TAX_AMT
           ,TAX_AMT_TAX_CURR
           ,TAX_AMT_FUNCL_CURR
           ,TAXABLE_AMT
           ,TAXABLE_AMT_TAX_CURR
           ,TAXABLE_AMT_FUNCL_CURR
           --,ORIG_TAXABLE_AMT
           --,ORIG_TAXABLE_AMT_TAX_CURR
           ,CAL_TAX_AMT
           ,CAL_TAX_AMT_TAX_CURR
           ,CAL_TAX_AMT_FUNCL_CURR
           --,ORIG_TAX_AMT
           --,ORIG_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT
           --,REC_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT_FUNCL_CURR
           --,NREC_TAX_AMT
           --,NREC_TAX_AMT_TAX_CURR
           --,NREC_TAX_AMT_FUNCL_CURR
           ,TAX_EXEMPTION_ID
           --,TAX_RATE_BEFORE_EXEMPTION
           --,TAX_RATE_NAME_BEFORE_EXEMPTION
           --,EXEMPT_RATE_MODIFIER
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPT_REASON_CODE
           ,TAX_EXCEPTION_ID
           ,TAX_RATE_BEFORE_EXCEPTION
           --,TAX_RATE_NAME_BEFORE_EXCEPTION
           --,EXCEPTION_RATE
           ,'N'    --TAX_APPORTIONMENT_FLAG
           ,'Y'    --HISTORICAL_FLAG
           ,TAXABLE_BASIS_FORMULA
           ,TAX_CALCULATION_FORMULA
           ,'N'    --CANCEL_FLAG
           ,'N'    --PURGE_FLAG
           ,'N'    --DELETE_FLAG
           ,'N'    --TAX_AMT_INCLUDED_FLAG
           ,'N'    --SELF_ASSESSED_FLAG
           ,'N'    --OVERRIDDEN_FLAG
           ,DECODE(AUTOTAX,'Y','N','Y') --MANUALLY_ENTERED_FLAG
           ,'N'    --REPORTING_ONLY_FLAG
           ,'N'    --FREEZE_UNTIL_OVERRIDDEN_FLAG
           ,'N'    --COPIED_FROM_OTHER_DOC_FLAG
           ,'N'    --RECALC_REQUIRED_FLAG
           ,'N'    --SETTLEMENT_FLAG
           ,'N'    --ITEM_DIST_CHANGED_FLAG
           ,'N'    --ASSOCIATED_CHILD_FROZEN_FLAG
           ,TAX_ONLY_LINE_FLAG
           ,'N'    --COMPOUNDING_DEP_TAX_FLAG
           ,'N'    --ENFORCE_FROM_NATURAL_ACCT_FLAG
           ,'N'    --COMPOUNDING_TAX_MISS_FLAG
           ,'N'    --SYNC_WITH_PRVDR_FLAG
           ,DECODE(AUTOTAX,'Y',NULL,'TAX_AMOUNT') --LAST_MANUAL_ENTRY
           ,TAX_PROVIDER_ID
           ,'MIGRATED'    --RECORD_TYPE_CODE
           --,REPORTING_PERIOD_ID
           --,LEGAL_MESSAGE_APPL_2
           --,LEGAL_MESSAGE_STATUS
           --,LEGAL_MESSAGE_RATE
           --,LEGAL_MESSAGE_BASIS
           --,LEGAL_MESSAGE_CALC
           --,LEGAL_MESSAGE_THRESHOLD
           --,LEGAL_MESSAGE_POS
           --,LEGAL_MESSAGE_TRN
           --,LEGAL_MESSAGE_EXMPT
           --,LEGAL_MESSAGE_EXCPT
           --,TAX_REGIME_TEMPLATE_ID
           --,TAX_APPLICABILITY_RESULT_ID
           --,DIRECT_RATE_RESULT_ID
           --,STATUS_RESULT_ID
           --,RATE_RESULT_ID
           --,BASIS_RESULT_ID
           --,THRESH_RESULT_ID
           --,CALC_RESULT_ID
           --,TAX_REG_NUM_DET_RESULT_ID
           --,EVAL_EXMPT_RESULT_ID
           --,EVAL_EXCPT_RESULT_ID
           --,TAX_HOLD_CODE
           --,TAX_HOLD_RELEASED_CODE
           --,PRD_TOTAL_TAX_AMT
           --,PRD_TOTAL_TAX_AMT_TAX_CURR
           --,PRD_TOTAL_TAX_AMT_FUNCL_CURR
           --,INTERNAL_ORG_LOCATION_ID
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
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,GLOBAL_ATTRIBUTE2
           ,GLOBAL_ATTRIBUTE3
           ,GLOBAL_ATTRIBUTE4
           ,GLOBAL_ATTRIBUTE5
           ,GLOBAL_ATTRIBUTE6
           ,GLOBAL_ATTRIBUTE7
           ,GLOBAL_ATTRIBUTE8
           ,GLOBAL_ATTRIBUTE9
           ,GLOBAL_ATTRIBUTE10
           ,GLOBAL_ATTRIBUTE11
           ,GLOBAL_ATTRIBUTE12
           ,GLOBAL_ATTRIBUTE13
           ,GLOBAL_ATTRIBUTE14
           ,GLOBAL_ATTRIBUTE15
           ,GLOBAL_ATTRIBUTE16
           ,GLOBAL_ATTRIBUTE17
           ,GLOBAL_ATTRIBUTE18
           ,GLOBAL_ATTRIBUTE19
           ,GLOBAL_ATTRIBUTE20
           ,LEGAL_JUSTIFICATION_TEXT1
           ,LEGAL_JUSTIFICATION_TEXT2
           ,LEGAL_JUSTIFICATION_TEXT3
           --,REPORTING_CURRENCY_CODE
           --,LINE_ASSESSABLE_VALUE
           --,TRX_LINE_INDEX
           --,OFFSET_TAX_RATE_CODE
           --,PRORATION_CODE
           --,OTHER_DOC_SOURCE
           --,CTRL_TOTAL_LINE_TX_AMT
           --,MRC_LINK_TO_TAX_LINE_ID
           --,APPLIED_TO_TRX_NUMBER
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_TAX_LINE_ID
           --,TAXING_JURIS_GEOGRAPHY_ID
	   ,NUMERIC1
           ,NUMERIC2
           ,NUMERIC3
           ,NUMERIC4
           ,ADJUSTED_DOC_TAX_LINE_ID
           ,OBJECT_VERSION_NUMBER
           ,'N'     --MULTIPLE_JURISDICTIONS_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,LEGAL_REPORTING_STATUS
           ,ACCOUNT_SOURCE_TAX_RATE_ID
          )
    SELECT /*+ ROWID(custtrx) ORDERED use_hash(arsysparam) swap_join_inputs(arsysparam)
               use_nl(types,fndcurr,fds,ptp,rbs,custtrx_prev,custtrxl,vat,rates,custtrxll,memoline)
               PUSH_SUBQ */
      NVL(custtrx.org_id, l_org_id)                   INTERNAL_ORGANIZATION_ID,
      222                                             APPLICATION_ID,
      'TRANSACTIONS'                                  ENTITY_CODE,
      DECODE(types.type,
        'INV','INVOICE',
        'CM', 'CREDIT_MEMO',
        'DM', 'DEBIT_MEMO',
        'NONE')                                       EVENT_CLASS_CODE,
      DECODE(types.type,
        'INV',4,
        'DM', 5,
        'CM', 6, NULL )                               EVENT_CLASS_MAPPING_ID,
--      DECODE(types.type,
--        'INV', 'INV_CREATE',
--        'CM', 'CM_CREATE',
--        'DM', 'DM_CREATE',
--        'CREATE')                                     EVENT_TYPE_CODE,
      DECODE(types.type,
        'INV',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'INV_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'INV_COMPLETE',
                     'INV_CREATE')),
        'CM',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'CM_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'CM_COMPLETE',
                     'CM_CREATE')),
        'DM',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'DM_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'DM_COMPLETE',
                     'DM_CREATE')),
        'CREATE')                                     EVENT_TYPE_CODE,
      'CREATED'                                       DOC_EVENT_STATUS,
      'CREATE'                                        LINE_LEVEL_ACTION,
      custtrx.customer_trx_id                         TRX_ID,
      DECODE(custtrxl.line_type,
        'TAX', custtrxl.link_to_cust_trx_line_id,
        custtrxl.customer_trx_line_id)                TRX_LINE_ID,
      'LINE'                                          TRX_LEVEL_TYPE,
      NVL(custtrx.trx_date,sysdate)                   TRX_DATE,

      --NULL                                            TRX_DOC_REVISION,
      NVL(custtrx.invoice_currency_code,'USD')        TRX_CURRENCY_CODE,
      custtrx.exchange_date                           CURRENCY_CONVERSION_DATE,
      custtrx.exchange_rate                           CURRENCY_CONVERSION_RATE,
      custtrx.exchange_rate_type                      CURRENCY_CONVERSION_TYPE,
      fndcurr.minimum_accountable_unit                MINIMUM_ACCOUNTABLE_UNIT,
      NVL(fndcurr.precision,0)                        PRECISION,
      NVL(custtrx.legal_entity_id, -99 )              LEGAL_ENTITY_ID,
      --NULL                                            ESTABLISHMENT_ID,
      custtrx.cust_trx_type_id                        RECEIVABLES_TRX_TYPE_ID,
      arsysparam.default_country                      DEFAULT_TAXATION_COUNTRY,
      custtrx.trx_number                              TRX_NUMBER,
      DECODE(custtrxl.line_type,
        'TAX', custtrxll.line_number,
        custtrxl.line_number)                         TRX_LINE_NUMBER,
      SUBSTRB(custtrxl.description,1,240)             TRX_LINE_DESCRIPTION,
      --NULL                                            TRX_DESCRIPTION,
      --NULL                                            TRX_COMMUNICATED_DATE,
      custtrx.batch_source_id                         BATCH_SOURCE_ID,
      rbs.name                                        BATCH_SOURCE_NAME,
      custtrx.doc_sequence_id                         DOC_SEQ_ID,
      fds.name                                        DOC_SEQ_NAME,
      custtrx.doc_sequence_value                      DOC_SEQ_VALUE,
      custtrx.term_due_date                           TRX_DUE_DATE,
      types.description                               TRX_TYPE_DESCRIPTION,
      (CASE
       WHEN (custtrx.global_attribute_category = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX' AND
           custtrx.global_attribute1 is NOT NULL) THEN
         'GUI TYPE/' || custtrx.global_attribute1
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO347' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'E')
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO347PR' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'E')
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO415' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'F')
       WHEN custtrx.global_attribute_category ='JE.ES.ARXTWMAI.MODELO415_347' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute7, 'E', 'MOD340/'||'E', 'F', 'MOD340/'||'F'))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO415_347PR' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute7, 'E', 'MOD340/'||'E', 'F', 'MOD340/'||'F'))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO349' THEN
         DECODE(nvl(custtrx.global_attribute6,'N'),'N','MOD340_EXCL',  'Y',
                decode(custtrx.global_attribute7,'E','MOD340/E',  'U',
		       decode(custtrx.global_attribute9,NULL,'MOD340/U','A','MOD340/UA','B','MOD340/UB')))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO340' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute9, NULL, 'MOD340/U', 'A', 'MOD340/UA', 'B', 'MOD340/UB'))
       END)                                           DOCUMENT_SUB_TYPE,
      --NULL                                            SUPPLIER_TAX_INVOICE_NUMBER,
      --NULL                                            SUPPLIER_TAX_INVOICE_DATE,
      --NULL                                            SUPPLIER_EXCHANGE_RATE,
     (CASE
      WHEN custtrx.global_attribute_category
        IN ('JE.HU.ARXTWMAI.TAX_DATE',
            'JE.SK.ARXTWMAI.TAX_DATE',
            'JE.PL.ARXTWMAI.TAX_DATE',
            'JE.CZ.ARXTWMAI.TAX_DATE')
      THEN
        TO_DATE(custtrx.global_attribute1, 'YYYY/MM/DD HH24:MI:SS')
      WHEN custtrx.global_attribute_category
        = 'JL.AR.ARXTWMAI.TGW_HEADER' THEN
        TO_DATE(custtrx.global_attribute18, 'YYYY/MM/DD HH24:MI:SS')
      END)                                            TAX_INVOICE_DATE,

     (CASE
      WHEN custtrx.global_attribute_category
        = 'JL.AR.ARXTWMAI.TGW_HEADER' THEN
        custtrx.global_attribute17
      END)                                            TAX_INVOICE_NUMBER,
      ptp.party_tax_profile_id                        FIRST_PTY_ORG_ID,
      'SALES_TRANSACTION'                             TAX_EVENT_CLASS_CODE,
--      'CREATE'                                        TAX_EVENT_TYPE_CODE,
      DECODE(NVL(SIGN(custtrx.printing_count), 0),
        1, 'FREEZE_FOR_TAX',
        DECODE(custtrx.complete_flag,
             'Y', 'VALIDATE_FOR_TAX',
             'CREATE') )                              TAX_EVENT_TYPE_CODE,

      --NULL                                            LINE_INTENDED_USE,
      custtrxl.line_type                              TRX_LINE_TYPE,
      --NULL                                            TRX_SHIPPING_DATE,
      --NULL                                            TRX_RECEIPT_DATE,
      --NULL                                            TRX_SIC_CODE,
      custtrx.fob_point                               FOB_POINT,
      custtrx.waybill_number                          TRX_WAYBILL_NUMBER,
      custtrxl.inventory_item_id                      PRODUCT_ID,
     (CASE
      WHEN custtrx.global_attribute_category
          = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
        AND  l_inv_installed = 'Y'
      THEN
        DECODE(custtrxl.global_attribute2,
               'Y', 'WINE CIGARRETE',
               'N', NULL)

      WHEN custtrxl.global_attribute_category
          IN ('JL.AR.ARXTWMAI.LINES',
              'JL.BR.ARXTWMAI.Additional Info',
              'JL.CO.ARXTWMAI.LINES' )
        AND  l_inv_installed = 'Y'
      THEN
        custtrxl.global_attribute2
      END)                                            PRODUCT_FISC_CLASSIFICATION,
      custtrxl.warehouse_id                           PRODUCT_ORG_ID,
      custtrxl.uom_code                               UOM_CODE,
      --NULL                                            PRODUCT_TYPE,
      --NULL                                            PRODUCT_CODE,
     (CASE
      WHEN custtrx.global_attribute_category
          = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
        AND  l_inv_installed = 'N'
      THEN
        DECODE(custtrxl.global_attribute2,
               'Y', 'WINE CIGARRETE',
               'N', NULL)

      WHEN custtrxl.global_attribute_category
          IN ('JL.AR.ARXTWMAI.LINES',
              'JL.BR.ARXTWMAI.Additional Info',
              'JL.CO.ARXTWMAI.LINES')
        AND  l_inv_installed = 'N'
      THEN
        custtrxl.global_attribute2
      END)                                            PRODUCT_CATEGORY,

      DECODE( custtrxl.inventory_item_id,
              NULL,NULL,
              SUBSTRB(custtrxl.description,1,240) )   PRODUCT_DESCRIPTION,
     (CASE
      WHEN custtrxl.global_attribute_category
          = 'JL.BR.ARXTWMAI.Additional Info'
      THEN
        custtrxl.global_attribute1
      WHEN custtrxl.interface_line_context
          IN ('OKL_CONTRACTS',
              'OKL_INVESTOR',
              'OKL_MANUAL')
      THEN
        custtrxl.interface_line_attribute12
      WHEN custtrx.global_attribute_category IN (
                    'JE.ES.ARXTWMAI.MODELO347'
                   ,'JE.ES.ARXTWMAI.MODELO347PR'
                   ,'JE.ES.ARXTWMAI.MODELO349'
                   ,'JE.ES.ARXTWMAI.MODELO415'
                   ,'JE.ES.ARXTWMAI.MODELO415_347'
                   ,'JE.ES.ARXTWMAI.MODELO415_347PR'
                   ,'JE.ES.ARXTWMAI.MODELO340') THEN
        nvl(custtrx.global_attribute8, 'MOD340NONE')
      END)                                            USER_DEFINED_FISC_CLASS,

      DECODE( custtrxl.line_type,
        'TAX', nvl(custtrxll.extended_amount,0),
        nvl(custtrxl.extended_amount,0))              LINE_AMT,

      DECODE(custtrxl.line_type,
          'TAX', custtrxll.quantity_invoiced,
          custtrxl.quantity_invoiced )                TRX_LINE_QUANTITY,

      --NULL                                            CASH_DISCOUNT,
      --NULL                                            VOLUME_DISCOUNT,
      --NULL                                            TRADING_DISCOUNT,
      --NULL                                            TRANSFER_CHARGE,
      --NULL                                            TRANSPORTATION_CHARGE,
      --NULL                                            INSURANCE_CHARGE,
      --NULL                                            OTHER_CHARGE,
      --NULL                                            ASSESSABLE_VALUE,
      --NULL                                            ASSET_FLAG,
      --NULL                                            ASSET_NUMBER,
      1                                               ASSET_ACCUM_DEPRECIATION,
      --NULL                                            ASSET_TYPE,
      1                                               ASSET_COST,

      DECODE( custtrx.related_customer_trx_id,
        NULL, NULL,
        222)                                          RELATED_DOC_APPLICATION_ID,
      --NULL                                            RELATED_DOC_ENTITY_CODE,
      --NULL                                            RELATED_DOC_EVENT_CLASS_CODE,
      custtrx.related_customer_trx_id                 RELATED_DOC_TRX_ID,
      --NULL                                            RELATED_DOC_NUMBER,
      --NULL                                            RELATED_DOC_DATE,

      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        222 )                                         ADJUSTED_DOC_APPLICATION_ID,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        'TRANSACTIONS' )                              ADJUSTED_DOC_ENTITY_CODE,
      --NULL                                            ADJUSTED_DOC_EVENT_CLASS_CODE,
      ---Bug6024643
      DECODE(types.type,
        'CM', 'INVOICE',
        'DM', 'INVOICE',
        NULL)                                         ADJUSTED_DOC_EVENT_CLASS_CODE,
      custtrxl.previous_customer_trx_id               ADJUSTED_DOC_TRX_ID,

      DECODE(custtrxl.line_type,
        'TAX', custtrxll.previous_customer_trx_line_id,
        custtrxl.previous_customer_trx_line_id)       ADJUSTED_DOC_LINE_ID,

      custtrx_prev.trx_number                         ADJUSTED_DOC_NUMBER,
      custtrx_prev.trx_Date                           ADJUSTED_DOC_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        'LINE' )                                      ADJUSTED_DOC_TRX_LEVEL_TYPE,

      --NULL                                            REF_DOC_APPLICATION_ID,
      --NULL                                            REF_DOC_ENTITY_CODE,
      --NULL                                            REF_DOC_EVENT_CLASS_CODE,
      --NULL                                            REF_DOC_TRX_ID,
      --NULL                                            REF_DOC_LINE_ID,
      --NULL                                            REF_DOC_LINE_QUANTITY,
      --NULL                                            REF_DOC_TRX_LEVEL_TYPE,

      (CASE
       WHEN custtrx.global_attribute_category
           = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
       THEN
         'SALES_TRANSACTION/' ||custtrx.global_attribute3

       WHEN custtrx.global_attribute_category IN
              ('JE.ES.ARXTWMAI.INVOICE_INFO'
              ,'JE.ES.ARXTWMAI.MODELO347'
              ,'JE.ES.ARXTWMAI.MODELO347PR'
              ,'JE.ES.ARXTWMAI.MODELO349'
              ,'JE.ES.ARXTWMAI.MODELO415'
              ,'JE.ES.ARXTWMAI.MODELO415_347'
              ,'JE.ES.ARXTWMAI.MODELO415_347PR'
              ,'JE.ES.ARXTWMAI.OTHER')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1

       WHEN custtrxl.global_attribute_category IN
              ('JL.AR.ARXTWMAI.LINES'
              ,'JL.BR.ARXTWMAI.Additional Info'
              ,'JL.CO.ARXTWMAI.LINES')
       THEN
         'SALES_TRANSACTION/' ||custtrxl.global_attribute3

       WHEN custtrx.global_attribute_category IN
             ('JE.ES.ARXTWMAI.INVOICE_INFO'
             ,'JE.ES.ARXTWMAI.OTHER')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1

       WHEN custtrx.global_attribute_category IN
             ('JE.ES.ARXTWMAI.MODELO347'
             ,'JE.ES.ARXTWMAI.MODELO347PR'
             ,'JE.ES.ARXTWMAI.MODELO349'
             ,'JE.ES.ARXTWMAI.MODELO415'
             ,'JE.ES.ARXTWMAI.MODELO415_347'
             ,'JE.ES.ARXTWMAI.MODELO415_347PR')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1||'/'||nvl(custtrx.GLOBAL_ATTRIBUTE11,'B')

       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO340'
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1||'/'||nvl(custtrx.GLOBAL_ATTRIBUTE8,'B')
       END )                                          TRX_BUSINESS_CATEGORY,

      custtrxl.tax_exempt_number                      EXEMPT_CERTIFICATE_NUMBER,
      --NULL                                            EXEMPT_REASON,
      custtrxl.tax_exempt_flag                        EXEMPTION_CONTROL_FLAG,
      custtrxl.tax_exempt_reason_code                 EXEMPT_REASON_CODE,
      --'Y'                                             HISTORICAL_FLAG,
      NVL(custtrx.trx_date,sysdate)                   TRX_LINE_GL_DATE,
      --'N'                                             LINE_AMT_INCLUDES_TAX_FLAG,
      --NULL                                            ACCOUNT_CCID,
      --NULL                                            ACCOUNT_STRING,
      --NULL                                            SHIP_TO_LOCATION_ID,
      --NULL                                            SHIP_FROM_LOCATION_ID,
      --NULL                                            POA_LOCATION_ID,
      --NULL                                            POO_LOCATION_ID,
      --NULL                                            BILL_TO_LOCATION_ID,
      --NULL                                            BILL_FROM_LOCATION_ID,
      --NULL                                            PAYING_LOCATION_ID,
      --NULL                                            OWN_HQ_LOCATION_ID,
      --NULL                                            TRADING_HQ_LOCATION_ID,
      --NULL                                            POC_LOCATION_ID,
      --NULL                                            POI_LOCATION_ID,
      --NULL                                            POD_LOCATION_ID,
      --NULL                                            TITLE_TRANSFER_LOCATION_ID,
      --'N'                                             CTRL_HDR_TX_APPL_FLAG,
      --NULL                                            CTRL_TOTAL_LINE_TX_AMT,
      --NULL                                            CTRL_TOTAL_HDR_TX_AMT,

      DECODE(types.type,
        'INV','INVOICE',
        'CM', 'CREDIT_MEMO',
        'DM', 'DEBIT_MEMO',
        types.type)                                   LINE_CLASS,
      NVL(custtrx.trx_date,sysdate)                   TRX_LINE_DATE,
      --NULL                                            INPUT_TAX_CLASSIFICATION_CODE,
      vat.tax_code                                    OUTPUT_TAX_CLASSIFICATION_CODE,
      --NULL                                            INTERNAL_ORG_LOCATION_ID,
      --NULL                                            PORT_OF_ENTRY_CODE,
      --'Y'                                             TAX_REPORTING_FLAG,
      --'N'                                             TAX_AMT_INCLUDED_FLAG,
      --'N'                                             COMPOUNDING_TAX_FLAG,
      --NULL                                            EVENT_ID,
      --'N'                                             THRESHOLD_INDICATOR_FLAG,
      --NULL                                            PROVNL_TAX_DETERMINATION_DATE,
      DECODE(custtrxl.line_type,
        'TAX', custtrxll.unit_selling_price,
        custtrxl.unit_selling_price )                 UNIT_PRICE,
      custtrx.ship_to_site_use_id                     SHIP_TO_CUST_ACCT_SITE_USE_ID,
      custtrx.bill_to_site_use_id                     BILL_TO_CUST_ACCT_SITE_USE_ID,
      custtrx.batch_id                                TRX_BATCH_ID,

      --NULL                                            START_EXPENSE_DATE,
      --NULL                                            SOURCE_APPLICATION_ID,
      --NULL                                            SOURCE_ENTITY_CODE,
      --NULL                                            SOURCE_EVENT_CLASS_CODE,
      --NULL                                            SOURCE_TRX_ID,
      --NULL                                            SOURCE_LINE_ID,
      --NULL                                            SOURCE_TRX_LEVEL_TYPE,
      --'MIGRATED'                                      RECORD_TYPE_CODE,
      --'N'                                             INCLUSIVE_TAX_OVERRIDE_FLAG,
      --'N'                                             TAX_PROCESSING_COMPLETED_FLAG,
      1                                               OBJECT_VERSION_NUMBER,
      DECODE(types.default_status,
        'VD', 'VD',
        NULL)                                         APPLICATION_DOC_STATUS,
      --'N'                                             USER_UPD_DET_FACTORS_FLAG,
      --NULL                                            SOURCE_TAX_LINE_ID,
      --NULL                                            REVERSED_APPLN_ID,
      --NULL                                            REVERSED_ENTITY_CODE,
      --NULL                                            REVERSED_EVNT_CLS_CODE,
      --NULL                                            REVERSED_TRX_ID,
      --NULL                                            REVERSED_TRX_LEVEL_TYPE,
      --NULL                                            REVERSED_TRX_LINE_ID,
      --NULL                                            TAX_CALCULATION_DONE_FLAG,
      decode(arsysparam.tax_database_view_set,'_A','Y','_V','Y',NULL)
						      PARTNER_MIGRATED_FLAG,
      custtrx.ship_to_address_id                      SHIP_THIRD_PTY_ACCT_SITE_ID,
      custtrx.bill_to_address_id                      BILL_THIRD_PTY_ACCT_SITE_ID,
      custtrx.ship_to_customer_id                     SHIP_THIRD_PTY_ACCT_ID,
      custtrx.bill_to_customer_id                     BILL_THIRD_PTY_ACCT_ID,

      --NULL                                            INTERFACE_ENTITY_CODE,
      --NULL                                            INTERFACE_LINE_ID,
      --NULL                                            HISTORICAL_TAX_CODE_ID,
      --NULL                                            ICX_SESSION_ID,
      --NULL                                            TRX_LINE_CURRENCY_CODE,
      --NULL                                            TRX_LINE_CURRENCY_CONV_RATE,
      --NULL                                            TRX_LINE_CURRENCY_CONV_DATE,
      --NULL                                            TRX_LINE_PRECISION,
      --NULL                                            TRX_LINE_MAU,
      --NULL                                            TRX_LINE_CURRENCY_CONV_TYPE,

      -- zx_lines columns start from here

      custtrxl.tax_line_id                            TAX_LINE_ID,
      DECODE(custtrxl.line_type,
        'TAX', RANK() OVER (
                 PARTITION BY
                   custtrxl.link_to_cust_trx_line_id,
                   custtrxl.customer_trx_id
                 ORDER BY
                   custtrxl.line_number,
                   custtrxl.customer_trx_line_id
                 ),
        NULL)                                         TAX_LINE_NUMBER,
      ptp.party_tax_profile_id                        CONTENT_OWNER_ID,
      regimes.tax_regime_id                           TAX_REGIME_ID,
      rates.TAX_REGIME_CODE                           TAX_REGIME_CODE,
      taxes.tax_id                                    TAX_ID,
      rates.tax                                       TAX,
      status.tax_status_id                            TAX_STATUS_ID,
      rates.TAX_STATUS_CODE                           TAX_STATUS_CODE,
      custtrxl.vat_tax_id                             TAX_RATE_ID,
      rates.TAX_RATE_CODE                             TAX_RATE_CODE,
      custtrxl.tax_rate                               TAX_RATE,
      rates.rate_type_code                            TAX_RATE_TYPE,

      DECODE(custtrxl.line_type,
        'TAX', RANK() OVER (
                 PARTITION BY
                   rates.tax_regime_code,
                   rates.tax,
                   custtrxl.link_to_cust_trx_line_id,
                   custtrxl.customer_trx_id
                 ORDER BY
                   custtrxl.line_number,
                   custtrxl.customer_trx_line_id
               ),
        NULL)                                         TAX_APPORTIONMENT_LINE_NUMBER,

      --'N'                                             MRC_TAX_LINE_FLAG,
      custtrx.set_of_books_id                         LEDGER_ID,
      --NULL                                            LEGAL_ENTITY_TAX_REG_NUMBER,
      --NULL                                            HQ_ESTB_REG_NUMBER,
      --NULL                                            HQ_ESTB_PARTY_TAX_PROF_ID,
      --NULL                                            TAX_CURRENCY_CONVERSION_DATE,
      --NULL                                            TAX_CURRENCY_CONVERSION_TYPE,
      --NULL                                            TAX_CURRENCY_CONVERSION_RATE,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ('JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute12,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute12),
           NULL)
      END)                                            TAX_BASE_MODIFIER_RATE,

      --NULL                                            OTHER_DOC_LINE_AMT,
      --NULL                                            OTHER_DOC_LINE_TAX_AMT,
      --NULL                                            OTHER_DOC_LINE_TAXABLE_AMT,
      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11),
           NULL)
       ELSE
         custtrxl.taxable_amount
       END)                                           UNROUNDED_TAXABLE_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19),
           NULL)
       ELSE
         custtrxl.extended_amount
       END)                                           UNROUNDED_TAX_AMT,
      --NULL                                            RELATED_DOC_TRX_LEVEL_TYPE,
      --NULL                                            SUMMARY_TAX_LINE_ID,
      --NULL                                            OFFSET_LINK_TO_TAX_LINE_ID,
      --'N'                                             OFFSET_FLAG,
      --'N'                                             PROCESS_FOR_RECOVERY_FLAG,
      --NULL                                            TAX_JURISDICTION_ID,
      --NULL                                            TAX_JURISDICTION_CODE,
      --NULL                                            PLACE_OF_SUPPLY,
--      decode(custtrx.ship_to_site_use_id,null,'BILL_TO','SHIP_TO')       PLACE_OF_SUPPLY_TYPE_CODE,
      'SHIP_TO_BILL_TO'                               PLACE_OF_SUPPLY_TYPE_CODE,
      --NULL                                            PLACE_OF_SUPPLY_RESULT_ID,
      --NULL                                            TAX_DATE_RULE_ID,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_DETERMINE_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_POINT_DATE,
      taxes.tax_type_code                             TAX_TYPE_CODE,
      --NULL                                            TAX_CODE,
      --NULL                                            TAX_REGISTRATION_ID,
      --NULL                                            TAX_REGISTRATION_NUMBER,
      --NULL                                            REGISTRATION_PARTY_TYPE,
      decode (arsysparam.TRX_HEADER_LEVEL_ROUNDING,
              'Y', 'HEADER',
              'LINE')                                 ROUNDING_LEVEL_CODE,
      arsysparam.TAX_ROUNDING_RULE                    ROUNDING_RULE_CODE,
      --NULL                                            ROUNDING_LVL_PARTY_TAX_PROF_ID,
      --NULL                                            ROUNDING_LVL_PARTY_TYPE,
      --NULL                                            ORIG_TAX_STATUS_ID,
      --NULL                                            ORIG_TAX_STATUS_CODE,
      --NULL                                            ORIG_TAX_RATE_ID,
      --NULL                                            ORIG_TAX_RATE_CODE,
      --NULL                                            ORIG_TAX_RATE,
      --NULL                                            ORIG_TAX_JURISDICTION_ID,
      --NULL                                            ORIG_TAX_JURISDICTION_CODE,
      --NULL                                            ORIG_TAX_AMT_INCLUDED_FLAG,
      --NULL                                            ORIG_SELF_ASSESSED_FLAG,
      taxes.tax_currency_code                         TAX_CURRENCY_CODE,
      custtrxl.extended_amount                        TAX_AMT,
      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.extended_amount *
           NVL(custtrx.exchange_rate,1)
       END)                                           TAX_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.extended_amount *
           NVL(custtrx.exchange_rate,1)
       END)                                           TAX_AMT_FUNCL_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11),
           NULL)
       ELSE
         custtrxl.taxable_amount
       END)                                           TAXABLE_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.taxable_amount*
           NVL(custtrx.exchange_rate,1)
       END)                                           TAXABLE_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.taxable_amount*
           NVL(custtrx.exchange_rate,1)
       END)                                           TAXABLE_AMT_FUNCL_CURR,

      --NULL                                            ORIG_TAXABLE_AMT,
      --NULL                                            ORIG_TAXABLE_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20),
           NULL)
      END)                                            CAL_TAX_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20)*
                  NVL(custtrx.EXCHANGE_RATE,1),
           NULL)
      END)                                            CAL_TAX_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20)*
                  NVL(custtrx.EXCHANGE_RATE,1),
           NULL)
      END)                                            CAL_TAX_AMT_FUNCL_CURR,

      --NULL                                            ORIG_TAX_AMT,
      --NULL                                            ORIG_TAX_AMT_TAX_CURR,
      --NULL                                            REC_TAX_AMT,
      --NULL                                            REC_TAX_AMT_TAX_CURR,
      --NULL                                            REC_TAX_AMT_FUNCL_CURR,
      --NULL                                            NREC_TAX_AMT,
      --NULL                                            NREC_TAX_AMT_TAX_CURR,
      --NULL                                            NREC_TAX_AMT_FUNCL_CURR,
      custtrxl.TAX_EXEMPTION_ID                       TAX_EXEMPTION_ID,
      --NULL                                            TAX_RATE_BEFORE_EXEMPTION,
      --NULL                                            TAX_RATE_NAME_BEFORE_EXEMPTION,
      --NULL                                            EXEMPT_RATE_MODIFIER,
      custtrxl.item_exception_rate_id                 TAX_EXCEPTION_ID,
      DECODE(rates.rate_type_code,
        'PERCENTAGE', rates.percentage_rate,
        'QUANTITY', rates.quantity_rate,
        NULL)                                         TAX_RATE_BEFORE_EXCEPTION,
      --NULL                                            TAX_RATE_NAME_BEFORE_EXCEPTION,
      --NULL                                            EXCEPTION_RATE,
      --'N'                                             TAX_APPORTIONMENT_FLAG,
--      DECODE(vat.taxable_basis,
--        'AFTER_EPD', 'STANDARD_TB_DISCOUNT',
--        'QUANTITY', 'STANDARD_QUANTITY',
--        'STANDARD_TB')                                TAXABLE_BASIS_FORMULA,
--      'STANDARD_TC'                                   TAX_CALCULATION_FORMULA,
      NVL(rates.taxable_basis_formula_code,
        taxes.def_taxable_basis_formula)              TAXABLE_BASIS_FORMULA,
      NVL(taxes.def_tax_calc_formula,
        'STANDARD_TC')                                TAX_CALCULATION_FORMULA,
      --'N'                                             CANCEL_FLAG,
      --'N'                                             PURGE_FLAG,
      --'N'                                             DELETE_FLAG,
      --'N'                                             SELF_ASSESSED_FLAG,
      --'N'                                             OVERRIDDEN_FLAG,
      --'N'                                             MANUALLY_ENTERED_FLAG,
      --'N'                                             REPORTING_ONLY_FLAG,
      --'N'                                             FREEZE_UNTIL_OVERRIDDEN_FLAG,
      --'N'                                             COPIED_FROM_OTHER_DOC_FLAG,
      --'N'                                             RECALC_REQUIRED_FLAG,
      --'N'                                             SETTLEMENT_FLAG,
      --'N'                                             ITEM_DIST_CHANGED_FLAG,
      --'N'                                             ASSOCIATED_CHILD_FROZEN_FLAG,
      DECODE(memoline.line_type, 'TAX', 'Y', 'N')     TAX_ONLY_LINE_FLAG,
      --'N'                                             COMPOUNDING_DEP_TAX_FLAG,
      --'N'                                             ENFORCE_FROM_NATURAL_ACCT_FLAG,
      --'N'                                             COMPOUNDING_TAX_MISS_FLAG,
      --'N'                                             SYNC_WITH_PRVDR_FLAG,
      --NULL                                            LAST_MANUAL_ENTRY,
      decode(arsysparam.tax_database_view_set,'_A',2,'_V',1, NULL)
						      TAX_PROVIDER_ID,
      --NULL                                            REPORTING_PERIOD_ID,
      --NULL                                            LEGAL_MESSAGE_APPL_2,
      --NULL                                            LEGAL_MESSAGE_STATUS,
      --NULL                                            LEGAL_MESSAGE_RATE,
      --NULL                                            LEGAL_MESSAGE_BASIS,
      --NULL                                            LEGAL_MESSAGE_CALC,
      --NULL                                            LEGAL_MESSAGE_THRESHOLD,
      --NULL                                            LEGAL_MESSAGE_POS,
      --NULL                                            LEGAL_MESSAGE_TRN,
      --NULL                                            LEGAL_MESSAGE_EXMPT,
      --NULL                                            LEGAL_MESSAGE_EXCPT,
      --NULL                                            TAX_REGIME_TEMPLATE_ID,
      --NULL                                            TAX_APPLICABILITY_RESULT_ID,
      --NULL                                            DIRECT_RATE_RESULT_ID,
      --NULL                                            STATUS_RESULT_ID,
      --NULL                                            RATE_RESULT_ID,
      --NULL                                            BASIS_RESULT_ID,
      --NULL                                            THRESH_RESULT_ID,
      --NULL                                            CALC_RESULT_ID,
      --NULL                                            TAX_REG_NUM_DET_RESULT_ID,
      --NULL                                            EVAL_EXMPT_RESULT_ID,
      --NULL                                            EVAL_EXCPT_RESULT_ID,
      --NULL                                            TAX_HOLD_CODE,
      --NULL                                            TAX_HOLD_RELEASED_CODE,
      --NULL                                            PRD_TOTAL_TAX_AMT,
      --NULL                                            PRD_TOTAL_TAX_AMT_TAX_CURR,
      --NULL                                            PRD_TOTAL_TAX_AMT_FUNCL_CURR,
      custtrxl.GLOBAL_ATTRIBUTE8                      LEGAL_JUSTIFICATION_TEXT1,
      custtrxl.GLOBAL_ATTRIBUTE9                      LEGAL_JUSTIFICATION_TEXT2,
      custtrxl.GLOBAL_ATTRIBUTE10                     LEGAL_JUSTIFICATION_TEXT3,
      --NULL                                            REPORTING_CURRENCY_CODE,
      --NULL                                            LINE_ASSESSABLE_VALUE,
      --NULL                                            TRX_LINE_INDEX,
      --NULL                                            OFFSET_TAX_RATE_CODE,
      --NULL                                            PRORATION_CODE,
      --NULL                                            OTHER_DOC_SOURCE,
      --NULL                                            MRC_LINK_TO_TAX_LINE_ID,
      --NULL                                            APPLIED_TO_TRX_NUMBER,
      --NULL                                            INTERFACE_TAX_LINE_ID,
      --NULL                                            TAXING_JURIS_GEOGRAPHY_ID,
      decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute2,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute2,null),
                        NULL)                               numeric1,
                decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute4,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute4,null),
                        NULL)                               numeric2,
                decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute6,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute6,null),
                        NULL)                               numeric3,
     decode(arsysparam.tax_database_view_Set,
                        '_A',
                decode(custtrxl.global_attribute1,'ALL',
			     to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                        'STATE',
                             to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                                        NULL),
                        '_V',
                decode(custtrxl.global_attribute1,'ALL',
			     to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                       'STATE',
                             to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                                        NULL)
                      ,NULL) numeric4,

      --DECODE(custtrxl.line_type,
      --  'TAX', custtrxl.previous_customer_trx_line_id,
      --  NULL)                                         ADJUSTED_DOC_TAX_LINE_ID,
      decode(custtrxl_prev.line_type, 'TAX', custtrxl_prev.tax_line_id, null) ADJUSTED_DOC_TAX_LINE_ID, -- 6705409
      custtrxl.ATTRIBUTE_CATEGORY                     ATTRIBUTE_CATEGORY,
      custtrxl.ATTRIBUTE1                             ATTRIBUTE1,
      custtrxl.ATTRIBUTE2                             ATTRIBUTE2,
      custtrxl.ATTRIBUTE3                             ATTRIBUTE3,
      custtrxl.ATTRIBUTE4                             ATTRIBUTE4,
      custtrxl.ATTRIBUTE5                             ATTRIBUTE5,
      custtrxl.ATTRIBUTE6                             ATTRIBUTE6,
      custtrxl.ATTRIBUTE7                             ATTRIBUTE7,
      custtrxl.ATTRIBUTE8                             ATTRIBUTE8,
      custtrxl.ATTRIBUTE9                             ATTRIBUTE9,
      custtrxl.ATTRIBUTE10                            ATTRIBUTE10,
      custtrxl.ATTRIBUTE11                            ATTRIBUTE11,
      custtrxl.ATTRIBUTE12                            ATTRIBUTE12,
      custtrxl.ATTRIBUTE13                            ATTRIBUTE13,
      custtrxl.ATTRIBUTE14                            ATTRIBUTE14,
      custtrxl.ATTRIBUTE15                            ATTRIBUTE15,
      custtrxl.GLOBAL_ATTRIBUTE_CATEGORY              GLOBAL_ATTRIBUTE_CATEGORY,
      custtrxl.GLOBAL_ATTRIBUTE1                      GLOBAL_ATTRIBUTE1,
      custtrxl.GLOBAL_ATTRIBUTE2                      GLOBAL_ATTRIBUTE2,
      custtrxl.GLOBAL_ATTRIBUTE3                      GLOBAL_ATTRIBUTE3,
      custtrxl.GLOBAL_ATTRIBUTE4                      GLOBAL_ATTRIBUTE4,
      custtrxl.GLOBAL_ATTRIBUTE5                      GLOBAL_ATTRIBUTE5,
      custtrxl.GLOBAL_ATTRIBUTE6                      GLOBAL_ATTRIBUTE6,
      custtrxl.GLOBAL_ATTRIBUTE7                      GLOBAL_ATTRIBUTE7,
      custtrxl.GLOBAL_ATTRIBUTE8                      GLOBAL_ATTRIBUTE8,
      custtrxl.GLOBAL_ATTRIBUTE9                      GLOBAL_ATTRIBUTE9,
      custtrxl.GLOBAL_ATTRIBUTE10                     GLOBAL_ATTRIBUTE10,
      custtrxl.GLOBAL_ATTRIBUTE11                     GLOBAL_ATTRIBUTE11,
      custtrxl.GLOBAL_ATTRIBUTE12                     GLOBAL_ATTRIBUTE12,
      custtrxl.GLOBAL_ATTRIBUTE13                     GLOBAL_ATTRIBUTE13,
      custtrxl.GLOBAL_ATTRIBUTE14                     GLOBAL_ATTRIBUTE14,
      custtrxl.GLOBAL_ATTRIBUTE15                     GLOBAL_ATTRIBUTE15,
      custtrxl.GLOBAL_ATTRIBUTE16                     GLOBAL_ATTRIBUTE16,
      custtrxl.GLOBAL_ATTRIBUTE17                     GLOBAL_ATTRIBUTE17,
      custtrxl.GLOBAL_ATTRIBUTE18                     GLOBAL_ATTRIBUTE18,
      custtrxl.GLOBAL_ATTRIBUTE19                     GLOBAL_ATTRIBUTE19,
      custtrxl.GLOBAL_ATTRIBUTE20                     GLOBAL_ATTRIBUTE20,
      --'N'                                             MULTIPLE_JURISDICTIONS_FLAG,
      SYSDATE                                         CREATION_DATE,
      1                                               CREATED_BY,
      SYSDATE                                         LAST_UPDATE_DATE,
      1                                               LAST_UPDATED_BY,
      0                                               LAST_UPDATE_LOGIN,
      DECODE(custtrx.complete_flag,
          'Y', '111111111111111',
               '000000000000000')                     LEGAL_REPORTING_STATUS,
      DECODE(vat.tax_type,
             'LOCATION', NULL,
             custtrxl.vat_tax_id)                     ACCOUNT_SOURCE_TAX_RATE_ID,
      custtrxl.autotax                                AUTOTAX
  FROM      RA_CUSTOMER_TRX_ALL        custtrx,
            AR_SYSTEM_PARAMETERS_ALL   arsysparam,
            RA_CUST_TRX_TYPES_ALL      types,
            FND_CURRENCIES             fndcurr,
            FND_DOCUMENT_SEQUENCES     fds,
            ZX_PARTY_TAX_PROFILE       ptp,
            RA_BATCH_SOURCES_ALL       rbs,
            RA_CUSTOMER_TRX_ALL        custtrx_prev,
	    RA_CUSTOMER_TRX_LINES_ALL  custtrxl_prev, -- 6705409
            RA_CUSTOMER_TRX_LINES_ALL  custtrxl,
            AR_VAT_TAX_ALL_B           vat,
            ZX_RATES_B                 rates ,
            RA_CUSTOMER_TRX_LINES_ALL  custtrxll,  -- retrieve the trx line for tax lines
            AR_MEMO_LINES_ALL_B        memoline,
            ZX_REGIMES_B               regimes,
            ZX_TAXES_B                 taxes,
            ZX_STATUS_B                status
    WHERE custtrx.customer_trx_id = p_upg_trx_info_rec.trx_id
      AND custtrx.customer_trx_id = custtrxl.customer_trx_id
      AND custtrx.previous_customer_trx_id = custtrx_prev.customer_trx_id(+)
      AND custtrxl.previous_customer_trx_line_id = custtrxl_prev.customer_trx_line_id(+) -- 6705409
      AND (case when (custtrxl.line_type IN ('LINE' ,'CB')) then custtrxl.customer_trx_line_id
 	                    when (custtrxl.line_type = 'TAX') then custtrxl.link_to_cust_trx_line_id
 	               end
 	              ) = custtrxll.customer_trx_line_id
 	          AND ((custtrxl.line_type = 'TAX' AND custtrxll.line_type = 'LINE')
 	               OR
 	    	   (custtrxl.line_type <> 'TAX')
 	              )
      AND custtrx.cust_trx_type_id = types.cust_trx_type_id
      AND types.type in ('INV','CM', 'DM')
      AND decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id) =
            decode(l_multi_org_flag,'N',l_org_id, types.org_id)
      AND custtrx.invoice_currency_code = fndcurr.currency_code
      AND custtrx.doc_sequence_id = fds.doc_sequence_id (+)
      AND ptp.party_id = decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id)
      AND ptp.party_type_code = 'OU'
      AND custtrx.batch_source_id = rbs.batch_source_id(+)
      AND decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id) =
            decode(l_multi_org_flag,'N',l_org_id, rbs.org_id(+))
      AND custtrxl.vat_tax_id = vat.vat_tax_id(+)
      AND custtrx.org_id = arsysparam.org_id
      AND custtrxl.vat_Tax_id = rates.tax_rate_id(+)
      AND custtrxll.memo_line_id = memoline.memo_line_id(+)
      AND decode(l_multi_org_flag,'N',l_org_id, custtrxll.org_id) = decode(l_multi_org_flag,'N',l_org_id, memoline.org_id(+))
      AND rates.tax_regime_code = regimes.tax_regime_code(+)
      AND rates.tax_regime_code = taxes.tax_regime_code(+)
      AND rates.tax = taxes.tax(+)
      AND rates.content_owner_id = taxes.content_owner_id(+)
      AND rates.tax_regime_code = status.tax_regime_code(+)
      AND rates.tax = status.tax(+)
      AND rates.tax_status_code = status.tax_status_code(+)
      AND rates.content_owner_id = status.content_owner_id(+)
      AND NVL(arsysparam.tax_code, '!') <> 'Localization'
      AND NOT EXISTS
          (SELECT 1 FROM zx_lines_det_factors zxl
            WHERE zxl.APPLICATION_ID   = 222
              AND zxl.EVENT_CLASS_CODE = DECODE(types.type,
                                           'INV','INVOICE',
                                           'CM', 'CREDIT_MEMO',
                                           'DM', 'DEBIT_MEMO',
                                           'NONE')
              AND zxl.ENTITY_CODE      = 'TRANSACTIONS'
              AND zxl.TRX_ID           = p_upg_trx_info_rec.trx_id
              AND zxl.TRX_LINE_ID      = DECODE(custtrxl.line_type,
                                           'LINE',custtrxl.customer_trx_line_id,
                                           'TAX', custtrxl.link_to_cust_trx_line_id)
              AND zxl.TRX_LEVEL_TYPE   = 'LINE'
           );

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_ar.END',
                   'ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_ar(-)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_ar',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_ar.END',
                    'ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_ar(-)');
    END IF;

END upgrade_trx_on_fly_ar;

-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- upgrade_trx_on_fly_blk_ar
--
-- DESCRIPTION
-- handle bulk on the fly migration for AR, called from validate and default API
--
-------------------------------------------------------------------------------
PROCEDURE upgrade_trx_on_fly_blk_ar(
  x_return_status        OUT NOCOPY  VARCHAR2
) AS
  l_multi_org_flag            VARCHAR2(1);
  l_org_id                    NUMBER;
  l_inv_installed             VARCHAR2(1);
  l_inv_flag                  VARCHAR2(1);
  l_industry                  VARCHAR2(10);
  l_fnd_return                BOOLEAN;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SELECT NVL(multi_org_flag, 'N') INTO l_multi_org_flag FROM FND_PRODUCT_GROUPS;
  -- for single org environment, get value of org_id from profile
  IF l_multi_org_flag = 'N' THEN
    FND_PROFILE.GET('ORG_ID',l_org_id);
    IF l_org_id is NULL THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar',
                   'Current envionment is a Single Org environment,'||
                   ' but peofile ORG_ID is not set up');
      END IF;

    END IF;
  END IF;

  l_fnd_return := FND_INSTALLATION.GET(401,401, l_inv_flag, l_industry);

  if (l_inv_flag = 'I') then
      l_inv_installed := 'Y';
  else
      l_inv_installed := 'N';
  end if;


    INSERT ALL
      WHEN trx_line_type IN ('LINE' ,'CB') THEN
    INTO ZX_LINES_DET_FACTORS(
            INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_CLASS_MAPPING_ID
           ,EVENT_TYPE_CODE
           ,DOC_EVENT_STATUS
           ,LINE_LEVEL_ACTION
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_DATE
           --,TRX_DOC_REVISION
           ,LEDGER_ID
           ,TRX_CURRENCY_CODE
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,LEGAL_ENTITY_ID
           --,ESTABLISHMENT_ID
           ,RECEIVABLES_TRX_TYPE_ID
           ,DEFAULT_TAXATION_COUNTRY
           ,TRX_NUMBER
           ,TRX_LINE_NUMBER
           ,TRX_LINE_DESCRIPTION
           --,TRX_DESCRIPTION
           --,TRX_COMMUNICATED_DATE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,TRX_DUE_DATE
           ,TRX_TYPE_DESCRIPTION
           ,DOCUMENT_SUB_TYPE
           --,SUPPLIER_TAX_INVOICE_NUMBER
           --,SUPPLIER_TAX_INVOICE_DATE
           --,SUPPLIER_EXCHANGE_RATE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,FIRST_PTY_ORG_ID
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           --,LINE_INTENDED_USE
           ,TRX_LINE_TYPE
           --,TRX_SHIPPING_DATE
           --,TRX_RECEIPT_DATE
           --,TRX_SIC_CODE
           ,FOB_POINT
           ,TRX_WAYBILL_NUMBER
           ,PRODUCT_ID
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ORG_ID
           ,UOM_CODE
           --,PRODUCT_TYPE
           --,PRODUCT_CODE
           ,PRODUCT_CATEGORY
           ,PRODUCT_DESCRIPTION
           ,USER_DEFINED_FISC_CLASS
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           --,CASH_DISCOUNT
           --,VOLUME_DISCOUNT
           --,TRADING_DISCOUNT
           --,TRANSFER_CHARGE
           --,TRANSPORTATION_CHARGE
           --,INSURANCE_CHARGE
           --,OTHER_CHARGE
           --,ASSESSABLE_VALUE
           --,ASSET_FLAG
           --,ASSET_NUMBER
           ,ASSET_ACCUM_DEPRECIATION
           --,ASSET_TYPE
           ,ASSET_COST
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           --,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           ,TRX_BUSINESS_CATEGORY
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPTION_CONTROL_FLAG
           ,EXEMPT_REASON_CODE
           ,HISTORICAL_FLAG
           ,TRX_LINE_GL_DATE
           ,LINE_AMT_INCLUDES_TAX_FLAG
           --,ACCOUNT_CCID
           --,ACCOUNT_STRING
           --,SHIP_TO_LOCATION_ID
           --,SHIP_FROM_LOCATION_ID
           --,POA_LOCATION_ID
           --,POO_LOCATION_ID
           --,BILL_TO_LOCATION_ID
           --,BILL_FROM_LOCATION_ID
           --,PAYING_LOCATION_ID
           --,OWN_HQ_LOCATION_ID
           --,TRADING_HQ_LOCATION_ID
           --,POC_LOCATION_ID
           --,POI_LOCATION_ID
           --,POD_LOCATION_ID
           --,TITLE_TRANSFER_LOCATION_ID
           ,CTRL_HDR_TX_APPL_FLAG
           --,CTRL_TOTAL_LINE_TX_AMT
           --,CTRL_TOTAL_HDR_TX_AMT
           ,LINE_CLASS
           ,TRX_LINE_DATE
           --,INPUT_TAX_CLASSIFICATION_CODE
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           --,INTERNAL_ORG_LOCATION_ID
           --,PORT_OF_ENTRY_CODE
           ,TAX_REPORTING_FLAG
           ,TAX_AMT_INCLUDED_FLAG
           ,COMPOUNDING_TAX_FLAG
           --,EVENT_ID
           ,THRESHOLD_INDICATOR_FLAG
           --,PROVNL_TAX_DETERMINATION_DATE
           ,UNIT_PRICE
           ,SHIP_TO_CUST_ACCT_SITE_USE_ID
           ,BILL_TO_CUST_ACCT_SITE_USE_ID
           ,TRX_BATCH_ID
           --,START_EXPENSE_DATE
           --,SOURCE_APPLICATION_ID
           --,SOURCE_ENTITY_CODE
           --,SOURCE_EVENT_CLASS_CODE
           --,SOURCE_TRX_ID
           --,SOURCE_LINE_ID
           --,SOURCE_TRX_LEVEL_TYPE
           ,RECORD_TYPE_CODE
           ,INCLUSIVE_TAX_OVERRIDE_FLAG
           ,TAX_PROCESSING_COMPLETED_FLAG
           ,OBJECT_VERSION_NUMBER
           ,APPLICATION_DOC_STATUS
           ,USER_UPD_DET_FACTORS_FLAG
           --,SOURCE_TAX_LINE_ID
           --,REVERSED_APPLN_ID
           --,REVERSED_ENTITY_CODE
           --,REVERSED_EVNT_CLS_CODE
           --,REVERSED_TRX_ID
           --,REVERSED_TRX_LEVEL_TYPE
           --,REVERSED_TRX_LINE_ID
           --,TAX_CALCULATION_DONE_FLAG
           ,PARTNER_MIGRATED_FLAG
           ,SHIP_THIRD_PTY_ACCT_SITE_ID
           ,BILL_THIRD_PTY_ACCT_SITE_ID
           ,SHIP_THIRD_PTY_ACCT_ID
           ,BILL_THIRD_PTY_ACCT_ID
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_LINE_ID
           --,HISTORICAL_TAX_CODE_ID
           --,ICX_SESSION_ID
           --,TRX_LINE_CURRENCY_CODE
           --,TRX_LINE_CURRENCY_CONV_RATE
           --,TRX_LINE_CURRENCY_CONV_DATE
           --,TRX_LINE_PRECISION
           --,TRX_LINE_MAU
           --,TRX_LINE_CURRENCY_CONV_TYPE
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
         )
         VALUES (
            INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_CLASS_MAPPING_ID
           ,EVENT_TYPE_CODE
           ,DOC_EVENT_STATUS
           ,LINE_LEVEL_ACTION
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_DATE
           --,TRX_DOC_REVISION
           ,LEDGER_ID
           ,TRX_CURRENCY_CODE
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_RATE
           ,CURRENCY_CONVERSION_TYPE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,LEGAL_ENTITY_ID
           --,ESTABLISHMENT_ID
           ,RECEIVABLES_TRX_TYPE_ID
           ,DEFAULT_TAXATION_COUNTRY
           ,TRX_NUMBER
           ,TRX_LINE_NUMBER
           ,TRX_LINE_DESCRIPTION
           --,TRX_DESCRIPTION
           --,TRX_COMMUNICATED_DATE
           ,BATCH_SOURCE_ID
           ,BATCH_SOURCE_NAME
           ,DOC_SEQ_ID
           ,DOC_SEQ_NAME
           ,DOC_SEQ_VALUE
           ,TRX_DUE_DATE
           ,TRX_TYPE_DESCRIPTION
           ,DOCUMENT_SUB_TYPE
           --,SUPPLIER_TAX_INVOICE_NUMBER
           --,SUPPLIER_TAX_INVOICE_DATE
           --,SUPPLIER_EXCHANGE_RATE
           ,TAX_INVOICE_DATE
           ,TAX_INVOICE_NUMBER
           ,FIRST_PTY_ORG_ID
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           --,LINE_INTENDED_USE
           ,TRX_LINE_TYPE
           --,TRX_SHIPPING_DATE
           --,TRX_RECEIPT_DATE
           --,TRX_SIC_CODE
           ,FOB_POINT
           ,TRX_WAYBILL_NUMBER
           ,PRODUCT_ID
           ,PRODUCT_FISC_CLASSIFICATION
           ,PRODUCT_ORG_ID
           ,UOM_CODE
           --,PRODUCT_TYPE
           --,PRODUCT_CODE
           ,PRODUCT_CATEGORY
           ,PRODUCT_DESCRIPTION
           ,USER_DEFINED_FISC_CLASS
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           --,CASH_DISCOUNT
           --,VOLUME_DISCOUNT
           --,TRADING_DISCOUNT
           --,TRANSFER_CHARGE
           --,TRANSPORTATION_CHARGE
           --,INSURANCE_CHARGE
           --,OTHER_CHARGE
           --,ASSESSABLE_VALUE
           --,ASSET_FLAG
           --,ASSET_NUMBER
           ,ASSET_ACCUM_DEPRECIATION
           --,ASSET_TYPE
           ,ASSET_COST
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           --,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           ,TRX_BUSINESS_CATEGORY
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPTION_CONTROL_FLAG
           ,EXEMPT_REASON_CODE
           ,'Y'    --HISTORICAL_FLAG
           ,TRX_LINE_GL_DATE
           ,'N'    --LINE_AMT_INCLUDES_TAX_FLAG
           --,ACCOUNT_CCID
           --,ACCOUNT_STRING
           --,SHIP_TO_LOCATION_ID
           --,SHIP_FROM_LOCATION_ID
           --,POA_LOCATION_ID
           --,POO_LOCATION_ID
           --,BILL_TO_LOCATION_ID
           --,BILL_FROM_LOCATION_ID
           --,PAYING_LOCATION_ID
           --,OWN_HQ_LOCATION_ID
           --,TRADING_HQ_LOCATION_ID
           --,POC_LOCATION_ID
           --,POI_LOCATION_ID
           --,POD_LOCATION_ID
           --,TITLE_TRANSFER_LOCATION_ID
           ,'N'   --CTRL_HDR_TX_APPL_FLAG
           --,CTRL_TOTAL_LINE_TX_AMT
           --,CTRL_TOTAL_HDR_TX_AMT
           ,LINE_CLASS
           ,TRX_LINE_DATE
           --,INPUT_TAX_CLASSIFICATION_CODE
           ,OUTPUT_TAX_CLASSIFICATION_CODE
           --,INTERNAL_ORG_LOCATION_ID
           --,PORT_OF_ENTRY_CODE
           ,'Y'   --TAX_REPORTING_FLAG
           ,'N'   --TAX_AMT_INCLUDED_FLAG
           ,'N'   --COMPOUNDING_TAX_FLAG
           --,EVENT_ID
           ,'N'   --THRESHOLD_INDICATOR_FLAG
           --,PROVNL_TAX_DETERMINATION_DATE
           ,UNIT_PRICE
           ,SHIP_TO_CUST_ACCT_SITE_USE_ID
           ,BILL_TO_CUST_ACCT_SITE_USE_ID
           ,TRX_BATCH_ID
           --,START_EXPENSE_DATE
           --,SOURCE_APPLICATION_ID
           --,SOURCE_ENTITY_CODE
           --,SOURCE_EVENT_CLASS_CODE
           --,SOURCE_TRX_ID
           --,SOURCE_LINE_ID
           --,SOURCE_TRX_LEVEL_TYPE
           ,'MIGRATED'     --RECORD_TYPE_CODE
           ,'N'     --INCLUSIVE_TAX_OVERRIDE_FLAG
           ,'N'     --TAX_PROCESSING_COMPLETED_FLAG
           ,OBJECT_VERSION_NUMBER
           ,APPLICATION_DOC_STATUS
           ,'N'     --USER_UPD_DET_FACTORS_FLAG
           --,SOURCE_TAX_LINE_ID
           --,REVERSED_APPLN_ID
           --,REVERSED_ENTITY_CODE
           --,REVERSED_EVNT_CLS_CODE
           --,REVERSED_TRX_ID
           --,REVERSED_TRX_LEVEL_TYPE
           --,REVERSED_TRX_LINE_ID
           --,TAX_CALCULATION_DONE_FLAG
           ,PARTNER_MIGRATED_FLAG
           ,SHIP_THIRD_PTY_ACCT_SITE_ID
           ,BILL_THIRD_PTY_ACCT_SITE_ID
           ,SHIP_THIRD_PTY_ACCT_ID
           ,BILL_THIRD_PTY_ACCT_ID
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_LINE_ID
           --,HISTORICAL_TAX_CODE_ID
           --,ICX_SESSION_ID
           --,TRX_LINE_CURRENCY_CODE
           --,TRX_LINE_CURRENCY_CONV_RATE
           --,TRX_LINE_CURRENCY_CONV_DATE
           --,TRX_LINE_PRECISION
           --,TRX_LINE_MAU
           --,TRX_LINE_CURRENCY_CONV_TYPE
           ,CREATION_DATE
           ,CREATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_LOGIN
         )
      WHEN (trx_line_type = 'TAX') THEN
    INTO ZX_LINES (
            TAX_LINE_ID
           ,INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_NUMBER
           ,DOC_EVENT_STATUS
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_LINE_NUMBER
           ,CONTENT_OWNER_ID
           ,TAX_REGIME_ID
           ,TAX_REGIME_CODE
           ,TAX_ID
           ,TAX
           ,TAX_STATUS_ID
           ,TAX_STATUS_CODE
           ,TAX_RATE_ID
           ,TAX_RATE_CODE
           ,TAX_RATE
           ,TAX_RATE_TYPE
           ,TAX_APPORTIONMENT_LINE_NUMBER
           ,MRC_TAX_LINE_FLAG
           ,LEDGER_ID
           --,ESTABLISHMENT_ID
           ,LEGAL_ENTITY_ID
           --,LEGAL_ENTITY_TAX_REG_NUMBER
           --,HQ_ESTB_REG_NUMBER
           --,HQ_ESTB_PARTY_TAX_PROF_ID
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_TYPE
           ,CURRENCY_CONVERSION_RATE
           --,TAX_CURRENCY_CONVERSION_DATE
           --,TAX_CURRENCY_CONVERSION_TYPE
           --,TAX_CURRENCY_CONVERSION_RATE
           ,TRX_CURRENCY_CODE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,TRX_NUMBER
           ,TRX_DATE
           ,UNIT_PRICE
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           ,TAX_BASE_MODIFIER_RATE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           --,OTHER_DOC_LINE_AMT
           --,OTHER_DOC_LINE_TAX_AMT
           --,OTHER_DOC_LINE_TAXABLE_AMT
           ,UNROUNDED_TAXABLE_AMT
           ,UNROUNDED_TAX_AMT
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           --,RELATED_DOC_TRX_LEVEL_TYPE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           --,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,SUMMARY_TAX_LINE_ID
           --,OFFSET_LINK_TO_TAX_LINE_ID
           ,OFFSET_FLAG
           ,PROCESS_FOR_RECOVERY_FLAG
           --,TAX_JURISDICTION_ID
           --,TAX_JURISDICTION_CODE
           --,PLACE_OF_SUPPLY
           ,PLACE_OF_SUPPLY_TYPE_CODE
           --,PLACE_OF_SUPPLY_RESULT_ID
           --,TAX_DATE_RULE_ID
           ,TAX_DATE
           ,TAX_DETERMINE_DATE
           ,TAX_POINT_DATE
           ,TRX_LINE_DATE
           ,TAX_TYPE_CODE
           --,TAX_CODE
           --,TAX_REGISTRATION_ID
           --,TAX_REGISTRATION_NUMBER
           --,REGISTRATION_PARTY_TYPE
           ,ROUNDING_LEVEL_CODE
           ,ROUNDING_RULE_CODE
           --,ROUNDING_LVL_PARTY_TAX_PROF_ID
           --,ROUNDING_LVL_PARTY_TYPE
           ,COMPOUNDING_TAX_FLAG
           --,ORIG_TAX_STATUS_ID
           --,ORIG_TAX_STATUS_CODE
           --,ORIG_TAX_RATE_ID
           --,ORIG_TAX_RATE_CODE
           --,ORIG_TAX_RATE
           --,ORIG_TAX_JURISDICTION_ID
           --,ORIG_TAX_JURISDICTION_CODE
           --,ORIG_TAX_AMT_INCLUDED_FLAG
           --,ORIG_SELF_ASSESSED_FLAG
           ,TAX_CURRENCY_CODE
           ,TAX_AMT
           ,TAX_AMT_TAX_CURR
           ,TAX_AMT_FUNCL_CURR
           ,TAXABLE_AMT
           ,TAXABLE_AMT_TAX_CURR
           ,TAXABLE_AMT_FUNCL_CURR
           --,ORIG_TAXABLE_AMT
           --,ORIG_TAXABLE_AMT_TAX_CURR
           ,CAL_TAX_AMT
           ,CAL_TAX_AMT_TAX_CURR
           ,CAL_TAX_AMT_FUNCL_CURR
           --,ORIG_TAX_AMT
           --,ORIG_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT
           --,REC_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT_FUNCL_CURR
           --,NREC_TAX_AMT
           --,NREC_TAX_AMT_TAX_CURR
           --,NREC_TAX_AMT_FUNCL_CURR
           ,TAX_EXEMPTION_ID
           --,TAX_RATE_BEFORE_EXEMPTION
           --,TAX_RATE_NAME_BEFORE_EXEMPTION
           --,EXEMPT_RATE_MODIFIER
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPT_REASON_CODE
           ,TAX_EXCEPTION_ID
           ,TAX_RATE_BEFORE_EXCEPTION
           --,TAX_RATE_NAME_BEFORE_EXCEPTION
           --,EXCEPTION_RATE
           ,TAX_APPORTIONMENT_FLAG
           ,HISTORICAL_FLAG
           ,TAXABLE_BASIS_FORMULA
           ,TAX_CALCULATION_FORMULA
           ,CANCEL_FLAG
           ,PURGE_FLAG
           ,DELETE_FLAG
           ,TAX_AMT_INCLUDED_FLAG
           ,SELF_ASSESSED_FLAG
           ,OVERRIDDEN_FLAG
           ,MANUALLY_ENTERED_FLAG
           ,REPORTING_ONLY_FLAG
           ,FREEZE_UNTIL_OVERRIDDEN_FLAG
           ,COPIED_FROM_OTHER_DOC_FLAG
           ,RECALC_REQUIRED_FLAG
           ,SETTLEMENT_FLAG
           ,ITEM_DIST_CHANGED_FLAG
           ,ASSOCIATED_CHILD_FROZEN_FLAG
           ,TAX_ONLY_LINE_FLAG
           ,COMPOUNDING_DEP_TAX_FLAG
           ,ENFORCE_FROM_NATURAL_ACCT_FLAG
           ,COMPOUNDING_TAX_MISS_FLAG
           ,SYNC_WITH_PRVDR_FLAG
           ,LAST_MANUAL_ENTRY
           ,TAX_PROVIDER_ID
           ,RECORD_TYPE_CODE
           --,REPORTING_PERIOD_ID
           --,LEGAL_MESSAGE_APPL_2
           --,LEGAL_MESSAGE_STATUS
           --,LEGAL_MESSAGE_RATE
           --,LEGAL_MESSAGE_BASIS
           --,LEGAL_MESSAGE_CALC
           --,LEGAL_MESSAGE_THRESHOLD
           --,LEGAL_MESSAGE_POS
           --,LEGAL_MESSAGE_TRN
           --,LEGAL_MESSAGE_EXMPT
           --,LEGAL_MESSAGE_EXCPT
           --,TAX_REGIME_TEMPLATE_ID
           --,TAX_APPLICABILITY_RESULT_ID
           --,DIRECT_RATE_RESULT_ID
           --,STATUS_RESULT_ID
           --,RATE_RESULT_ID
           --,BASIS_RESULT_ID
           --,THRESH_RESULT_ID
           --,CALC_RESULT_ID
           --,TAX_REG_NUM_DET_RESULT_ID
           --,EVAL_EXMPT_RESULT_ID
           --,EVAL_EXCPT_RESULT_ID
           --,TAX_HOLD_CODE
           --,TAX_HOLD_RELEASED_CODE
           --,PRD_TOTAL_TAX_AMT
           --,PRD_TOTAL_TAX_AMT_TAX_CURR
           --,PRD_TOTAL_TAX_AMT_FUNCL_CURR
           --,INTERNAL_ORG_LOCATION_ID
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
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,GLOBAL_ATTRIBUTE2
           ,GLOBAL_ATTRIBUTE3
           ,GLOBAL_ATTRIBUTE4
           ,GLOBAL_ATTRIBUTE5
           ,GLOBAL_ATTRIBUTE6
           ,GLOBAL_ATTRIBUTE7
           ,GLOBAL_ATTRIBUTE8
           ,GLOBAL_ATTRIBUTE9
           ,GLOBAL_ATTRIBUTE10
           ,GLOBAL_ATTRIBUTE11
           ,GLOBAL_ATTRIBUTE12
           ,GLOBAL_ATTRIBUTE13
           ,GLOBAL_ATTRIBUTE14
           ,GLOBAL_ATTRIBUTE15
           ,GLOBAL_ATTRIBUTE16
           ,GLOBAL_ATTRIBUTE17
           ,GLOBAL_ATTRIBUTE18
           ,GLOBAL_ATTRIBUTE19
           ,GLOBAL_ATTRIBUTE20
           ,LEGAL_JUSTIFICATION_TEXT1
           ,LEGAL_JUSTIFICATION_TEXT2
           ,LEGAL_JUSTIFICATION_TEXT3
           --,REPORTING_CURRENCY_CODE
           --,LINE_ASSESSABLE_VALUE
           --,TRX_LINE_INDEX
           --,OFFSET_TAX_RATE_CODE
           --,PRORATION_CODE
           --,OTHER_DOC_SOURCE
           --,CTRL_TOTAL_LINE_TX_AMT
           --,MRC_LINK_TO_TAX_LINE_ID
           --,APPLIED_TO_TRX_NUMBER
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_TAX_LINE_ID
           --,TAXING_JURIS_GEOGRAPHY_ID
 	   ,NUMERIC1
           ,NUMERIC2
           ,NUMERIC3
           ,NUMERIC4
           ,ADJUSTED_DOC_TAX_LINE_ID
           ,OBJECT_VERSION_NUMBER
           ,MULTIPLE_JURISDICTIONS_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,LEGAL_REPORTING_STATUS
         )
         VALUES(
            TAX_LINE_ID
           ,INTERNAL_ORGANIZATION_ID
           ,APPLICATION_ID
           ,ENTITY_CODE
           ,EVENT_CLASS_CODE
           ,EVENT_TYPE_CODE
           ,TRX_ID
           ,TRX_LINE_ID
           ,TRX_LEVEL_TYPE
           ,TRX_LINE_NUMBER
           ,DOC_EVENT_STATUS
           ,TAX_EVENT_CLASS_CODE
           ,TAX_EVENT_TYPE_CODE
           ,TAX_LINE_NUMBER
           ,CONTENT_OWNER_ID
           ,TAX_REGIME_ID
           ,TAX_REGIME_CODE
           ,TAX_ID
           ,TAX
           ,TAX_STATUS_ID
           ,TAX_STATUS_CODE
           ,TAX_RATE_ID
           ,TAX_RATE_CODE
           ,TAX_RATE
           ,TAX_RATE_TYPE
           ,TAX_APPORTIONMENT_LINE_NUMBER
           ,'N'    --MRC_TAX_LINE_FLAG
           ,LEDGER_ID
           --,ESTABLISHMENT_ID
           ,LEGAL_ENTITY_ID
           --,LEGAL_ENTITY_TAX_REG_NUMBER
           --,HQ_ESTB_REG_NUMBER
           --,HQ_ESTB_PARTY_TAX_PROF_ID
           ,CURRENCY_CONVERSION_DATE
           ,CURRENCY_CONVERSION_TYPE
           ,CURRENCY_CONVERSION_RATE
           --,TAX_CURRENCY_CONVERSION_DATE
           --,TAX_CURRENCY_CONVERSION_TYPE
           --,TAX_CURRENCY_CONVERSION_RATE
           ,TRX_CURRENCY_CODE
           ,MINIMUM_ACCOUNTABLE_UNIT
           ,PRECISION
           ,TRX_NUMBER
           ,TRX_DATE
           ,UNIT_PRICE
           ,LINE_AMT
           ,TRX_LINE_QUANTITY
           ,TAX_BASE_MODIFIER_RATE
           --,REF_DOC_APPLICATION_ID
           --,REF_DOC_ENTITY_CODE
           --,REF_DOC_EVENT_CLASS_CODE
           --,REF_DOC_TRX_ID
           --,REF_DOC_LINE_ID
           --,REF_DOC_LINE_QUANTITY
           --,REF_DOC_TRX_LEVEL_TYPE
           --,OTHER_DOC_LINE_AMT
           --,OTHER_DOC_LINE_TAX_AMT
           --,OTHER_DOC_LINE_TAXABLE_AMT
           ,UNROUNDED_TAXABLE_AMT
           ,UNROUNDED_TAX_AMT
           ,RELATED_DOC_APPLICATION_ID
           --,RELATED_DOC_ENTITY_CODE
           --,RELATED_DOC_EVENT_CLASS_CODE
           ,RELATED_DOC_TRX_ID
           --,RELATED_DOC_NUMBER
           --,RELATED_DOC_DATE
           --,RELATED_DOC_TRX_LEVEL_TYPE
           ,ADJUSTED_DOC_APPLICATION_ID
           ,ADJUSTED_DOC_ENTITY_CODE
           --,ADJUSTED_DOC_EVENT_CLASS_CODE
           ,ADJUSTED_DOC_TRX_ID
           ,ADJUSTED_DOC_LINE_ID
           ,ADJUSTED_DOC_NUMBER
           ,ADJUSTED_DOC_DATE
           ,ADJUSTED_DOC_TRX_LEVEL_TYPE
           --,SUMMARY_TAX_LINE_ID
           --,OFFSET_LINK_TO_TAX_LINE_ID
           ,'N'   --OFFSET_FLAG
           ,'N'   --PROCESS_FOR_RECOVERY_FLAG
           --,TAX_JURISDICTION_ID
           --,TAX_JURISDICTION_CODE
           --,PLACE_OF_SUPPLY
           ,PLACE_OF_SUPPLY_TYPE_CODE
           --,PLACE_OF_SUPPLY_RESULT_ID
           --,TAX_DATE_RULE_ID
           ,TAX_DATE
           ,TAX_DETERMINE_DATE
           ,TAX_POINT_DATE
           ,TRX_LINE_DATE
           ,TAX_TYPE_CODE
           --,TAX_CODE
           --,TAX_REGISTRATION_ID
           --,TAX_REGISTRATION_NUMBER
           --,REGISTRATION_PARTY_TYPE
           ,ROUNDING_LEVEL_CODE
           ,ROUNDING_RULE_CODE
           --,ROUNDING_LVL_PARTY_TAX_PROF_ID
           --,ROUNDING_LVL_PARTY_TYPE
           ,'N'   --COMPOUNDING_TAX_FLAG
           --,ORIG_TAX_STATUS_ID
           --,ORIG_TAX_STATUS_CODE
           --,ORIG_TAX_RATE_ID
           --,ORIG_TAX_RATE_CODE
           --,ORIG_TAX_RATE
           --,ORIG_TAX_JURISDICTION_ID
           --,ORIG_TAX_JURISDICTION_CODE
           --,ORIG_TAX_AMT_INCLUDED_FLAG
           --,ORIG_SELF_ASSESSED_FLAG
           ,TAX_CURRENCY_CODE
           ,TAX_AMT
           ,TAX_AMT_TAX_CURR
           ,TAX_AMT_FUNCL_CURR
           ,TAXABLE_AMT
           ,TAXABLE_AMT_TAX_CURR
           ,TAXABLE_AMT_FUNCL_CURR
           --,ORIG_TAXABLE_AMT
           --,ORIG_TAXABLE_AMT_TAX_CURR
           ,CAL_TAX_AMT
           ,CAL_TAX_AMT_TAX_CURR
           ,CAL_TAX_AMT_FUNCL_CURR
           --,ORIG_TAX_AMT
           --,ORIG_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT
           --,REC_TAX_AMT_TAX_CURR
           --,REC_TAX_AMT_FUNCL_CURR
           --,NREC_TAX_AMT
           --,NREC_TAX_AMT_TAX_CURR
           --,NREC_TAX_AMT_FUNCL_CURR
           ,TAX_EXEMPTION_ID
           --,TAX_RATE_BEFORE_EXEMPTION
           --,TAX_RATE_NAME_BEFORE_EXEMPTION
           --,EXEMPT_RATE_MODIFIER
           ,EXEMPT_CERTIFICATE_NUMBER
           --,EXEMPT_REASON
           ,EXEMPT_REASON_CODE
           ,TAX_EXCEPTION_ID
           ,TAX_RATE_BEFORE_EXCEPTION
           --,TAX_RATE_NAME_BEFORE_EXCEPTION
           --,EXCEPTION_RATE
           ,'N'    --TAX_APPORTIONMENT_FLAG
           ,'Y'    --HISTORICAL_FLAG
           ,TAXABLE_BASIS_FORMULA
           ,TAX_CALCULATION_FORMULA
           ,'N'    --CANCEL_FLAG
           ,'N'    --PURGE_FLAG
           ,'N'    --DELETE_FLAG
           ,'N'    --TAX_AMT_INCLUDED_FLAG
           ,'N'    --SELF_ASSESSED_FLAG
           ,'N'    --OVERRIDDEN_FLAG
           ,DECODE(AUTOTAX,'Y','N','Y') --MANUALLY_ENTERED_FLAG
           ,'N'    --REPORTING_ONLY_FLAG
           ,'N'    --FREEZE_UNTIL_OVERRIDDEN_FLAG
           ,'N'    --COPIED_FROM_OTHER_DOC_FLAG
           ,'N'    --RECALC_REQUIRED_FLAG
           ,'N'    --SETTLEMENT_FLAG
           ,'N'    --ITEM_DIST_CHANGED_FLAG
           ,'N'    --ASSOCIATED_CHILD_FROZEN_FLAG
           ,TAX_ONLY_LINE_FLAG
           ,'N'    --COMPOUNDING_DEP_TAX_FLAG
           ,'N'    --ENFORCE_FROM_NATURAL_ACCT_FLAG
           ,'N'    --COMPOUNDING_TAX_MISS_FLAG
           ,'N'    --SYNC_WITH_PRVDR_FLAG
           ,DECODE(AUTOTAX,'Y',NULL,'TAX_AMOUNT') --LAST_MANUAL_ENTRY
           ,TAX_PROVIDER_ID
           ,'MIGRATED'    --RECORD_TYPE_CODE
           --,REPORTING_PERIOD_ID
           --,LEGAL_MESSAGE_APPL_2
           --,LEGAL_MESSAGE_STATUS
           --,LEGAL_MESSAGE_RATE
           --,LEGAL_MESSAGE_BASIS
           --,LEGAL_MESSAGE_CALC
           --,LEGAL_MESSAGE_THRESHOLD
           --,LEGAL_MESSAGE_POS
           --,LEGAL_MESSAGE_TRN
           --,LEGAL_MESSAGE_EXMPT
           --,LEGAL_MESSAGE_EXCPT
           --,TAX_REGIME_TEMPLATE_ID
           --,TAX_APPLICABILITY_RESULT_ID
           --,DIRECT_RATE_RESULT_ID
           --,STATUS_RESULT_ID
           --,RATE_RESULT_ID
           --,BASIS_RESULT_ID
           --,THRESH_RESULT_ID
           --,CALC_RESULT_ID
           --,TAX_REG_NUM_DET_RESULT_ID
           --,EVAL_EXMPT_RESULT_ID
           --,EVAL_EXCPT_RESULT_ID
           --,TAX_HOLD_CODE
           --,TAX_HOLD_RELEASED_CODE
           --,PRD_TOTAL_TAX_AMT
           --,PRD_TOTAL_TAX_AMT_TAX_CURR
           --,PRD_TOTAL_TAX_AMT_FUNCL_CURR
           --,INTERNAL_ORG_LOCATION_ID
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
           ,GLOBAL_ATTRIBUTE_CATEGORY
           ,GLOBAL_ATTRIBUTE1
           ,GLOBAL_ATTRIBUTE2
           ,GLOBAL_ATTRIBUTE3
           ,GLOBAL_ATTRIBUTE4
           ,GLOBAL_ATTRIBUTE5
           ,GLOBAL_ATTRIBUTE6
           ,GLOBAL_ATTRIBUTE7
           ,GLOBAL_ATTRIBUTE8
           ,GLOBAL_ATTRIBUTE9
           ,GLOBAL_ATTRIBUTE10
           ,GLOBAL_ATTRIBUTE11
           ,GLOBAL_ATTRIBUTE12
           ,GLOBAL_ATTRIBUTE13
           ,GLOBAL_ATTRIBUTE14
           ,GLOBAL_ATTRIBUTE15
           ,GLOBAL_ATTRIBUTE16
           ,GLOBAL_ATTRIBUTE17
           ,GLOBAL_ATTRIBUTE18
           ,GLOBAL_ATTRIBUTE19
           ,GLOBAL_ATTRIBUTE20
           ,LEGAL_JUSTIFICATION_TEXT1
           ,LEGAL_JUSTIFICATION_TEXT2
           ,LEGAL_JUSTIFICATION_TEXT3
           --,REPORTING_CURRENCY_CODE
           --,LINE_ASSESSABLE_VALUE
           --,TRX_LINE_INDEX
           --,OFFSET_TAX_RATE_CODE
           --,PRORATION_CODE
           --,OTHER_DOC_SOURCE
           --,CTRL_TOTAL_LINE_TX_AMT
           --,MRC_LINK_TO_TAX_LINE_ID
           --,APPLIED_TO_TRX_NUMBER
           --,INTERFACE_ENTITY_CODE
           --,INTERFACE_TAX_LINE_ID
           --,TAXING_JURIS_GEOGRAPHY_ID
	   ,NUMERIC1
           ,NUMERIC2
           ,NUMERIC3
           ,NUMERIC4
           ,ADJUSTED_DOC_TAX_LINE_ID
           ,OBJECT_VERSION_NUMBER
           ,'N'     --MULTIPLE_JURISDICTIONS_FLAG
           ,CREATED_BY
           ,CREATION_DATE
           ,LAST_UPDATED_BY
           ,LAST_UPDATE_DATE
           ,LAST_UPDATE_LOGIN
           ,LEGAL_REPORTING_STATUS
          )
    SELECT /*+ ROWID(custtrx) ORDERED use_hash(arsysparam) swap_join_inputs(arsysparam)
              use_nl(types,fndcurr,fds,ptp,rbs,custtrx_prev,custtrxl,vat,rates,custtrxll,memoline) */
      NVL(custtrx.org_id, l_org_id)                   INTERNAL_ORGANIZATION_ID,
      222                                             APPLICATION_ID,
      'TRANSACTIONS'                                  ENTITY_CODE,
      DECODE(types.type,
        'INV','INVOICE',
        'CM', 'CREDIT_MEMO',
        'DM', 'DEBIT_MEMO',
        'NONE')                                       EVENT_CLASS_CODE,
      DECODE(types.type,
        'INV',4,
        'DM', 5,
        'CM', 6, NULL )                               EVENT_CLASS_MAPPING_ID,
--      DECODE(types.type,
--        'INV', 'INV_CREATE',
--        'CM', 'CM_CREATE',
--        'DM', 'DM_CREATE',
--        'CREATE')                                     EVENT_TYPE_CODE,
      DECODE(types.type,
        'INV',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'INV_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'INV_COMPLETE',
                     'INV_CREATE')),
        'CM',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'CM_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'CM_COMPLETE',
                     'CM_CREATE')),
        'DM',DECODE(NVL(SIGN(custtrx.printing_count), 0),
                1, 'DM_PRINT',
                DECODE(custtrx.complete_flag,
                     'Y', 'DM_COMPLETE',
                     'DM_CREATE')),
        'CREATE')                                     EVENT_TYPE_CODE,
      'CREATED'                                       DOC_EVENT_STATUS,
      'CREATE'                                        LINE_LEVEL_ACTION,
      custtrx.customer_trx_id                         TRX_ID,
      DECODE(custtrxl.line_type,
        'TAX', custtrxl.link_to_cust_trx_line_id,
        custtrxl.customer_trx_line_id)                TRX_LINE_ID,
      'LINE'                                          TRX_LEVEL_TYPE,
      NVL(custtrx.trx_date,sysdate)                   TRX_DATE,

      --NULL                                            TRX_DOC_REVISION,
      NVL(custtrx.invoice_currency_code,'USD')        TRX_CURRENCY_CODE,
      custtrx.exchange_date                           CURRENCY_CONVERSION_DATE,
      custtrx.exchange_rate                           CURRENCY_CONVERSION_RATE,
      custtrx.exchange_rate_type                      CURRENCY_CONVERSION_TYPE,
      fndcurr.minimum_accountable_unit                MINIMUM_ACCOUNTABLE_UNIT,
      NVL(fndcurr.precision,0)                        PRECISION,
      NVL(custtrx.legal_entity_id, -99 )              LEGAL_ENTITY_ID,
      --NULL                                            ESTABLISHMENT_ID,
      custtrx.cust_trx_type_id                        RECEIVABLES_TRX_TYPE_ID,
      arsysparam.default_country                      DEFAULT_TAXATION_COUNTRY,
      custtrx.trx_number                              TRX_NUMBER,
      DECODE(custtrxl.line_type,
        'TAX', custtrxll.line_number,
        custtrxl.line_number)                         TRX_LINE_NUMBER,
      SUBSTRB(custtrxl.description,1,240)             TRX_LINE_DESCRIPTION,
      --NULL                                            TRX_DESCRIPTION,
      --NULL                                            TRX_COMMUNICATED_DATE,
      custtrx.batch_source_id                         BATCH_SOURCE_ID,
      rbs.name                                        BATCH_SOURCE_NAME,
      custtrx.doc_sequence_id                         DOC_SEQ_ID,
      fds.name                                        DOC_SEQ_NAME,
      custtrx.doc_sequence_value                      DOC_SEQ_VALUE,
      custtrx.term_due_date                           TRX_DUE_DATE,
      types.description                               TRX_TYPE_DESCRIPTION,
      (CASE
       WHEN (custtrx.global_attribute_category = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX' AND
           custtrx.global_attribute1 is NOT NULL) THEN
         'GUI TYPE/' || custtrx.global_attribute1
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO347' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'E')
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO347PR' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'E')
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO415' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y', 'MOD340/'||'F')
       WHEN custtrx.global_attribute_category ='JE.ES.ARXTWMAI.MODELO415_347' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute7, 'E', 'MOD340/'||'E', 'F', 'MOD340/'||'F'))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO415_347PR' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute7, 'E', 'MOD340/'||'E', 'F', 'MOD340/'||'F'))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO349' THEN
         DECODE(nvl(custtrx.global_attribute6,'N'),'N','MOD340_EXCL',  'Y',
                decode(custtrx.global_attribute7,'E','MOD340/E',  'U',
		       decode(custtrx.global_attribute9,NULL,'MOD340/U','A','MOD340/UA','B','MOD340/UB')))
       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO340' THEN
         DECODE(nvl(custtrx.global_attribute6, 'N'), 'N', 'MOD340_EXCL', 'Y',
	        decode(custtrx.global_attribute9, NULL, 'MOD340/U', 'A', 'MOD340/UA', 'B', 'MOD340/UB'))
       END)                                           DOCUMENT_SUB_TYPE,
      --NULL                                            SUPPLIER_TAX_INVOICE_NUMBER,
      --NULL                                            SUPPLIER_TAX_INVOICE_DATE,
      --NULL                                            SUPPLIER_EXCHANGE_RATE,
     (CASE
      WHEN custtrx.global_attribute_category
        IN ('JE.HU.ARXTWMAI.TAX_DATE',
            'JE.SK.ARXTWMAI.TAX_DATE',
            'JE.PL.ARXTWMAI.TAX_DATE',
            'JE.CZ.ARXTWMAI.TAX_DATE')
      THEN
        TO_DATE(custtrx.global_attribute1, 'YYYY/MM/DD HH24:MI:SS')
      WHEN custtrx.global_attribute_category
        = 'JL.AR.ARXTWMAI.TGW_HEADER' THEN
        TO_DATE(custtrx.global_attribute18, 'YYYY/MM/DD HH24:MI:SS')
      END)                                            TAX_INVOICE_DATE,

     (CASE
      WHEN custtrx.global_attribute_category
        = 'JL.AR.ARXTWMAI.TGW_HEADER' THEN
        custtrx.global_attribute17
      END)                                            TAX_INVOICE_NUMBER,
      ptp.party_tax_profile_id                        FIRST_PTY_ORG_ID,
      'SALES_TRANSACTION'                             TAX_EVENT_CLASS_CODE,
--      'CREATE'                                        TAX_EVENT_TYPE_CODE,
      DECODE(NVL(SIGN(custtrx.printing_count), 0),
        1, 'FREEZE_FOR_TAX',
        DECODE(custtrx.complete_flag,
             'Y', 'VALIDATE_FOR_TAX',
             'CREATE') )                              TAX_EVENT_TYPE_CODE,

      --NULL                                            LINE_INTENDED_USE,
      custtrxl.line_type                              TRX_LINE_TYPE,
      --NULL                                            TRX_SHIPPING_DATE,
      --NULL                                            TRX_RECEIPT_DATE,
      --NULL                                            TRX_SIC_CODE,
      custtrx.fob_point                               FOB_POINT,
      custtrx.waybill_number                          TRX_WAYBILL_NUMBER,
      custtrxl.inventory_item_id                      PRODUCT_ID,
     (CASE
      WHEN custtrx.global_attribute_category
          = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
        AND  l_inv_installed = 'Y'
      THEN
        DECODE(custtrxl.global_attribute2,
               'Y', 'WINE CIGARRETE',
               'N', NULL)

      WHEN custtrxl.global_attribute_category
          IN ('JL.AR.ARXTWMAI.LINES',
              'JL.BR.ARXTWMAI.Additional Info',
              'JL.CO.ARXTWMAI.LINES' )
        AND  l_inv_installed = 'Y'
      THEN
        custtrxl.global_attribute2
      END)                                            PRODUCT_FISC_CLASSIFICATION,
      custtrxl.warehouse_id                           PRODUCT_ORG_ID,
      custtrxl.uom_code                               UOM_CODE,
      --NULL                                            PRODUCT_TYPE,
      --NULL                                            PRODUCT_CODE,
     (CASE
      WHEN custtrx.global_attribute_category
          = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
        AND  l_inv_installed = 'N'
      THEN
        DECODE(custtrxl.global_attribute2,
               'Y', 'WINE CIGARRETE',
               'N', NULL)

      WHEN custtrxl.global_attribute_category
          IN ('JL.AR.ARXTWMAI.LINES',
              'JL.BR.ARXTWMAI.Additional Info',
              'JL.CO.ARXTWMAI.LINES')
        AND  l_inv_installed = 'N'
      THEN
        custtrxl.global_attribute2
      END)                                            PRODUCT_CATEGORY,

      DECODE( custtrxl.inventory_item_id,
              NULL,NULL,
              SUBSTRB(custtrxl.description,1,240) )   PRODUCT_DESCRIPTION,
     (CASE
      WHEN custtrxl.global_attribute_category
          = 'JL.BR.ARXTWMAI.Additional Info'
      THEN
        custtrxl.global_attribute1
      WHEN custtrxl.interface_line_context
          IN ('OKL_CONTRACTS',
              'OKL_INVESTOR',
              'OKL_MANUAL')
      THEN
        custtrxl.interface_line_attribute12
      WHEN custtrx.global_attribute_category IN (
                    'JE.ES.ARXTWMAI.MODELO347'
                   ,'JE.ES.ARXTWMAI.MODELO347PR'
                   ,'JE.ES.ARXTWMAI.MODELO349'
                   ,'JE.ES.ARXTWMAI.MODELO415'
                   ,'JE.ES.ARXTWMAI.MODELO415_347'
                   ,'JE.ES.ARXTWMAI.MODELO415_347PR'
                   ,'JE.ES.ARXTWMAI.MODELO340') THEN
        nvl(custtrx.global_attribute8, 'MOD340NONE')
      END)                                            USER_DEFINED_FISC_CLASS,

      DECODE( custtrxl.line_type,
        'TAX', nvl(custtrxll.extended_amount,0),
        nvl(custtrxl.extended_amount,0))              LINE_AMT,

      DECODE(custtrxl.line_type,
          'TAX', custtrxll.quantity_invoiced,
          custtrxl.quantity_invoiced )                TRX_LINE_QUANTITY,

      --NULL                                            CASH_DISCOUNT,
      --NULL                                            VOLUME_DISCOUNT,
      --NULL                                            TRADING_DISCOUNT,
      --NULL                                            TRANSFER_CHARGE,
      --NULL                                            TRANSPORTATION_CHARGE,
      --NULL                                            INSURANCE_CHARGE,
      --NULL                                            OTHER_CHARGE,
      --NULL                                            ASSESSABLE_VALUE,
      --NULL                                            ASSET_FLAG,
      --NULL                                            ASSET_NUMBER,
      1                                               ASSET_ACCUM_DEPRECIATION,
      --NULL                                            ASSET_TYPE,
      1                                               ASSET_COST,

      DECODE( custtrx.related_customer_trx_id,
        NULL, NULL,
        222)                                          RELATED_DOC_APPLICATION_ID,
      --NULL                                            RELATED_DOC_ENTITY_CODE,
      --NULL                                            RELATED_DOC_EVENT_CLASS_CODE,
      custtrx.related_customer_trx_id                 RELATED_DOC_TRX_ID,
      --NULL                                            RELATED_DOC_NUMBER,
      --NULL                                            RELATED_DOC_DATE,

      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        222 )                                         ADJUSTED_DOC_APPLICATION_ID,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        'TRANSACTIONS' )                              ADJUSTED_DOC_ENTITY_CODE,
      --NULL                                            ADJUSTED_DOC_EVENT_CLASS_CODE,
      custtrxl.previous_customer_trx_id               ADJUSTED_DOC_TRX_ID,

      DECODE(custtrxl.line_type,
        'TAX', custtrxll.previous_customer_trx_line_id,
        custtrxl.previous_customer_trx_line_id)       ADJUSTED_DOC_LINE_ID,

      custtrx_prev.trx_number                         ADJUSTED_DOC_NUMBER,
      custtrx_prev.trx_Date                           ADJUSTED_DOC_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, NULL,
        'LINE' )                                      ADJUSTED_DOC_TRX_LEVEL_TYPE,

      --NULL                                            REF_DOC_APPLICATION_ID,
      --NULL                                            REF_DOC_ENTITY_CODE,
      --NULL                                            REF_DOC_EVENT_CLASS_CODE,
      --NULL                                            REF_DOC_TRX_ID,
      --NULL                                            REF_DOC_LINE_ID,
      --NULL                                            REF_DOC_LINE_QUANTITY,
      --NULL                                            REF_DOC_TRX_LEVEL_TYPE,

      (CASE
       WHEN custtrx.global_attribute_category
           = 'JA.TW.ARXTWMAI.RA_CUSTOMER_TRX'
       THEN
         'SALES_TRANSACTION/' ||custtrx.global_attribute3

       WHEN custtrx.global_attribute_category IN
              ('JE.ES.ARXTWMAI.INVOICE_INFO'
              ,'JE.ES.ARXTWMAI.MODELO347'
              ,'JE.ES.ARXTWMAI.MODELO347PR'
              ,'JE.ES.ARXTWMAI.MODELO349'
              ,'JE.ES.ARXTWMAI.MODELO415'
              ,'JE.ES.ARXTWMAI.MODELO415_347'
              ,'JE.ES.ARXTWMAI.MODELO415_347PR'
              ,'JE.ES.ARXTWMAI.OTHER')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1

       WHEN custtrxl.global_attribute_category IN
              ('JL.AR.ARXTWMAI.LINES'
              ,'JL.BR.ARXTWMAI.Additional Info'
              ,'JL.CO.ARXTWMAI.LINES')
       THEN
         'SALES_TRANSACTION/' ||custtrxl.global_attribute3

       WHEN custtrx.global_attribute_category IN
             ('JE.ES.ARXTWMAI.INVOICE_INFO'
             ,'JE.ES.ARXTWMAI.OTHER')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1

       WHEN custtrx.global_attribute_category IN
             ('JE.ES.ARXTWMAI.MODELO347'
             ,'JE.ES.ARXTWMAI.MODELO347PR'
             ,'JE.ES.ARXTWMAI.MODELO349'
             ,'JE.ES.ARXTWMAI.MODELO415'
             ,'JE.ES.ARXTWMAI.MODELO415_347'
             ,'JE.ES.ARXTWMAI.MODELO415_347PR')
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1||'/'||nvl(custtrx.GLOBAL_ATTRIBUTE11,'B')

       WHEN custtrx.global_attribute_category = 'JE.ES.ARXTWMAI.MODELO340'
       THEN
         'SALES_TRANSACTION/INVOICE TYPE/'||custtrx.global_attribute1||'/'||nvl(custtrx.GLOBAL_ATTRIBUTE8,'B')
       END )                                          TRX_BUSINESS_CATEGORY,

      custtrxl.tax_exempt_number                      EXEMPT_CERTIFICATE_NUMBER,
      --NULL                                            EXEMPT_REASON,
      custtrxl.tax_exempt_flag                        EXEMPTION_CONTROL_FLAG,
      custtrxl.tax_exempt_reason_code                 EXEMPT_REASON_CODE,
      --'Y'                                             HISTORICAL_FLAG,
      NVL(custtrx.trx_date,sysdate)                   TRX_LINE_GL_DATE,
      --'N'                                             LINE_AMT_INCLUDES_TAX_FLAG,
      --NULL                                            ACCOUNT_CCID,
      --NULL                                            ACCOUNT_STRING,
      --NULL                                            SHIP_TO_LOCATION_ID,
      --NULL                                            SHIP_FROM_LOCATION_ID,
      --NULL                                            POA_LOCATION_ID,
      --NULL                                            POO_LOCATION_ID,
      --NULL                                            BILL_TO_LOCATION_ID,
      --NULL                                            BILL_FROM_LOCATION_ID,
      --NULL                                            PAYING_LOCATION_ID,
      --NULL                                            OWN_HQ_LOCATION_ID,
      --NULL                                            TRADING_HQ_LOCATION_ID,
      --NULL                                            POC_LOCATION_ID,
      --NULL                                            POI_LOCATION_ID,
      --NULL                                            POD_LOCATION_ID,
      --NULL                                            TITLE_TRANSFER_LOCATION_ID,
      --'N'                                             CTRL_HDR_TX_APPL_FLAG,
      --NULL                                            CTRL_TOTAL_LINE_TX_AMT,
      --NULL                                            CTRL_TOTAL_HDR_TX_AMT,

      DECODE(types.type,
        'INV','INVOICE',
        'CM', 'CREDIT_MEMO',
        'DM', 'DEBIT_MEMO',
        types.type)                                   LINE_CLASS,
      NVL(custtrx.trx_date,sysdate)                   TRX_LINE_DATE,
      --NULL                                            INPUT_TAX_CLASSIFICATION_CODE,
      vat.tax_code                                    OUTPUT_TAX_CLASSIFICATION_CODE,
      --NULL                                            INTERNAL_ORG_LOCATION_ID,
      --NULL                                            PORT_OF_ENTRY_CODE,
      --'Y'                                             TAX_REPORTING_FLAG,
      --'N'                                             TAX_AMT_INCLUDED_FLAG,
      --'N'                                             COMPOUNDING_TAX_FLAG,
      --NULL                                            EVENT_ID,
      --'N'                                             THRESHOLD_INDICATOR_FLAG,
      --NULL                                            PROVNL_TAX_DETERMINATION_DATE,
      DECODE(custtrxl.line_type,
        'TAX', custtrxll.unit_selling_price,
        custtrxl.unit_selling_price )                 UNIT_PRICE,
      custtrx.ship_to_site_use_id                     SHIP_TO_CUST_ACCT_SITE_USE_ID,
      custtrx.bill_to_site_use_id                     BILL_TO_CUST_ACCT_SITE_USE_ID,
      custtrx.batch_id                                TRX_BATCH_ID,

      --NULL                                            START_EXPENSE_DATE,
      --NULL                                            SOURCE_APPLICATION_ID,
      --NULL                                            SOURCE_ENTITY_CODE,
      --NULL                                            SOURCE_EVENT_CLASS_CODE,
      --NULL                                            SOURCE_TRX_ID,
      --NULL                                            SOURCE_LINE_ID,
      --NULL                                            SOURCE_TRX_LEVEL_TYPE,
      --'MIGRATED'                                      RECORD_TYPE_CODE,
      --'N'                                             INCLUSIVE_TAX_OVERRIDE_FLAG,
      --'N'                                             TAX_PROCESSING_COMPLETED_FLAG,
      1                                               OBJECT_VERSION_NUMBER,
      DECODE(types.default_status,
        'VD', 'VD',
        NULL)                                         APPLICATION_DOC_STATUS,
      --'N'                                             USER_UPD_DET_FACTORS_FLAG,
      --NULL                                            SOURCE_TAX_LINE_ID,
      --NULL                                            REVERSED_APPLN_ID,
      --NULL                                            REVERSED_ENTITY_CODE,
      --NULL                                            REVERSED_EVNT_CLS_CODE,
      --NULL                                            REVERSED_TRX_ID,
      --NULL                                            REVERSED_TRX_LEVEL_TYPE,
      --NULL                                            REVERSED_TRX_LINE_ID,
      --NULL                                            TAX_CALCULATION_DONE_FLAG,
      decode(arsysparam.tax_database_view_set,'_A','Y','_V','Y',NULL)
						      PARTNER_MIGRATED_FLAG,
      custtrx.ship_to_address_id                      SHIP_THIRD_PTY_ACCT_SITE_ID,
      custtrx.bill_to_address_id                      BILL_THIRD_PTY_ACCT_SITE_ID,
      custtrx.ship_to_customer_id                     SHIP_THIRD_PTY_ACCT_ID,
      custtrx.bill_to_customer_id                     BILL_THIRD_PTY_ACCT_ID,

      --NULL                                            INTERFACE_ENTITY_CODE,
      --NULL                                            INTERFACE_LINE_ID,
      --NULL                                            HISTORICAL_TAX_CODE_ID,
      --NULL                                            ICX_SESSION_ID,
      --NULL                                            TRX_LINE_CURRENCY_CODE,
      --NULL                                            TRX_LINE_CURRENCY_CONV_RATE,
      --NULL                                            TRX_LINE_CURRENCY_CONV_DATE,
      --NULL                                            TRX_LINE_PRECISION,
      --NULL                                            TRX_LINE_MAU,
      --NULL                                            TRX_LINE_CURRENCY_CONV_TYPE,

      -- zx_lines columns start from here

      custtrxl.tax_line_id                            TAX_LINE_ID,
      DECODE(custtrxl.line_type,
        'TAX', RANK() OVER (
                 PARTITION BY
                   custtrxl.link_to_cust_trx_line_id,
                   custtrxl.customer_trx_id
                 ORDER BY
                   custtrxl.line_number,
                   custtrxl.customer_trx_line_id
                 ),
        NULL)                                         TAX_LINE_NUMBER,
      ptp.party_tax_profile_id                        CONTENT_OWNER_ID,
      regimes.tax_regime_id                           TAX_REGIME_ID,
      rates.TAX_REGIME_CODE                           TAX_REGIME_CODE,
      taxes.tax_id                                    TAX_ID,
      rates.tax                                       TAX,
      status.tax_status_id                            TAX_STATUS_ID,
      rates.TAX_STATUS_CODE                           TAX_STATUS_CODE,
      custtrxl.vat_tax_id                             TAX_RATE_ID,
      rates.TAX_RATE_CODE                             TAX_RATE_CODE,
      custtrxl.tax_rate                               TAX_RATE,
      rates.rate_type_code                            TAX_RATE_TYPE,

      DECODE(custtrxl.line_type,
        'TAX', RANK() OVER (
                 PARTITION BY
                   rates.tax_regime_code,
                   rates.tax,
                   custtrxl.link_to_cust_trx_line_id,
                   custtrxl.customer_trx_id
                 ORDER BY
                   custtrxl.line_number,
                   custtrxl.customer_trx_line_id
               ),
        NULL)                                         TAX_APPORTIONMENT_LINE_NUMBER,

      --'N'                                             MRC_TAX_LINE_FLAG,
      custtrx.set_of_books_id                         LEDGER_ID,
      --NULL                                            LEGAL_ENTITY_TAX_REG_NUMBER,
      --NULL                                            HQ_ESTB_REG_NUMBER,
      --NULL                                            HQ_ESTB_PARTY_TAX_PROF_ID,
      --NULL                                            TAX_CURRENCY_CONVERSION_DATE,
      --NULL                                            TAX_CURRENCY_CONVERSION_TYPE,
      --NULL                                            TAX_CURRENCY_CONVERSION_RATE,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ('JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute12,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute12),
           NULL)
      END)                                            TAX_BASE_MODIFIER_RATE,

      --NULL                                            OTHER_DOC_LINE_AMT,
      --NULL                                            OTHER_DOC_LINE_TAX_AMT,
      --NULL                                            OTHER_DOC_LINE_TAXABLE_AMT,
      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11),
           NULL)
       ELSE
         custtrxl.taxable_amount
       END)                                           UNROUNDED_TAXABLE_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19),
           NULL)
       ELSE
         custtrxl.extended_amount
       END)                                           UNROUNDED_TAX_AMT,
      --NULL                                            RELATED_DOC_TRX_LEVEL_TYPE,
      --NULL                                            SUMMARY_TAX_LINE_ID,
      --NULL                                            OFFSET_LINK_TO_TAX_LINE_ID,
      --'N'                                             OFFSET_FLAG,
      --'N'                                             PROCESS_FOR_RECOVERY_FLAG,
      --NULL                                            TAX_JURISDICTION_ID,
      --NULL                                            TAX_JURISDICTION_CODE,
      --NULL                                            PLACE_OF_SUPPLY,
--      decode(custtrx.ship_to_site_use_id,null,'BILL_TO','SHIP_TO')       PLACE_OF_SUPPLY_TYPE_CODE,
      'SHIP_TO_BILL_TO'                               PLACE_OF_SUPPLY_TYPE_CODE,
      --NULL                                            PLACE_OF_SUPPLY_RESULT_ID,
      --NULL                                            TAX_DATE_RULE_ID,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_DETERMINE_DATE,
      DECODE(custtrxl.previous_customer_trx_id,
        NULL, custtrx.trx_date,
        custtrx_prev.trx_date )                       TAX_POINT_DATE,
      taxes.tax_type_code                             TAX_TYPE_CODE,
      --NULL                                            TAX_CODE,
      --NULL                                            TAX_REGISTRATION_ID,
      --NULL                                            TAX_REGISTRATION_NUMBER,
      --NULL                                            REGISTRATION_PARTY_TYPE,
      decode (arsysparam.TRX_HEADER_LEVEL_ROUNDING,
              'Y', 'HEADER',
              'LINE')                                 ROUNDING_LEVEL_CODE,
      arsysparam.TAX_ROUNDING_RULE                    ROUNDING_RULE_CODE,
      --NULL                                            ROUNDING_LVL_PARTY_TAX_PROF_ID,
      --NULL                                            ROUNDING_LVL_PARTY_TYPE,
      --NULL                                            ORIG_TAX_STATUS_ID,
      --NULL                                            ORIG_TAX_STATUS_CODE,
      --NULL                                            ORIG_TAX_RATE_ID,
      --NULL                                            ORIG_TAX_RATE_CODE,
      --NULL                                            ORIG_TAX_RATE,
      --NULL                                            ORIG_TAX_JURISDICTION_ID,
      --NULL                                            ORIG_TAX_JURISDICTION_CODE,
      --NULL                                            ORIG_TAX_AMT_INCLUDED_FLAG,
      --NULL                                            ORIG_SELF_ASSESSED_FLAG,
      taxes.tax_currency_code                         TAX_CURRENCY_CODE,
      custtrxl.extended_amount                        TAX_AMT,
      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.extended_amount *
           NVL(custtrx.exchange_rate,1)
       END)                                           TAX_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN( 'JL.BR.ARXTWMAI.Additional Info',
               'JL.CO.ARXTWMAI.LINES',
               'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute19,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute19)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.extended_amount *
           NVL(custtrx.exchange_rate,1)
       END)                                           TAX_AMT_FUNCL_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11),
           NULL)
       ELSE
         custtrxl.taxable_amount
       END)                                           TAXABLE_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.taxable_amount*
           NVL(custtrx.exchange_rate,1)
       END)                                           TAXABLE_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute11,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute11)*
                  NVL(custtrx.exchange_rate,1),
           NULL)
       ELSE
         custtrxl.taxable_amount*
           NVL(custtrx.exchange_rate,1)
       END)                                           TAXABLE_AMT_FUNCL_CURR,

      --NULL                                            ORIG_TAXABLE_AMT,
      --NULL                                            ORIG_TAXABLE_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20),
           NULL)
      END)                                            CAL_TAX_AMT,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20)*
                  NVL(custtrx.EXCHANGE_RATE,1),
           NULL)
      END)                                            CAL_TAX_AMT_TAX_CURR,

      (CASE
       WHEN custtrxl.global_attribute_category
           IN ( 'JL.BR.ARXTWMAI.Additional Info',
                'JL.CO.ARXTWMAI.LINES',
                'JL.AR.ARXTWMAI.LINES')
       THEN
         DECODE(LTRIM(custtrxl.global_attribute20,'-.0123456789'),
           NULL,TO_NUMBER(custtrxl.global_attribute20)*
                  NVL(custtrx.EXCHANGE_RATE,1),
           NULL)
      END)                                            CAL_TAX_AMT_FUNCL_CURR,

      --NULL                                            ORIG_TAX_AMT,
      --NULL                                            ORIG_TAX_AMT_TAX_CURR,
      --NULL                                            REC_TAX_AMT,
      --NULL                                            REC_TAX_AMT_TAX_CURR,
      --NULL                                            REC_TAX_AMT_FUNCL_CURR,
      --NULL                                            NREC_TAX_AMT,
      --NULL                                            NREC_TAX_AMT_TAX_CURR,
      --NULL                                            NREC_TAX_AMT_FUNCL_CURR,
      custtrxl.TAX_EXEMPTION_ID                       TAX_EXEMPTION_ID,
      --NULL                                            TAX_RATE_BEFORE_EXEMPTION,
      --NULL                                            TAX_RATE_NAME_BEFORE_EXEMPTION,
      --NULL                                            EXEMPT_RATE_MODIFIER,
      custtrxl.item_exception_rate_id                 TAX_EXCEPTION_ID,
      DECODE(rates.rate_type_code,
        'PERCENTAGE', rates.percentage_rate,
        'QUANTITY', rates.quantity_rate,
        NULL)                                         TAX_RATE_BEFORE_EXCEPTION,
      --NULL                                            TAX_RATE_NAME_BEFORE_EXCEPTION,
      --NULL                                            EXCEPTION_RATE,
      --'N'                                             TAX_APPORTIONMENT_FLAG,
--      DECODE(vat.taxable_basis,
--        'AFTER_EPD', 'STANDARD_TB_DISCOUNT',
--        'QUANTITY', 'STANDARD_QUANTITY',
--        'STANDARD_TB')                                TAXABLE_BASIS_FORMULA,
--      'STANDARD_TC'                                   TAX_CALCULATION_FORMULA,
      NVL(rates.taxable_basis_formula_code,
        taxes.def_taxable_basis_formula)              TAXABLE_BASIS_FORMULA,
      NVL(taxes.def_tax_calc_formula,
        'STANDARD_TC')                                TAX_CALCULATION_FORMULA,
      --'N'                                             CANCEL_FLAG,
      --'N'                                             PURGE_FLAG,
      --'N'                                             DELETE_FLAG,
      --'N'                                             SELF_ASSESSED_FLAG,
      --'N'                                             OVERRIDDEN_FLAG,
      --'N'                                             MANUALLY_ENTERED_FLAG,
      --'N'                                             REPORTING_ONLY_FLAG,
      --'N'                                             FREEZE_UNTIL_OVERRIDDEN_FLAG,
      --'N'                                             COPIED_FROM_OTHER_DOC_FLAG,
      --'N'                                             RECALC_REQUIRED_FLAG,
      --'N'                                             SETTLEMENT_FLAG,
      --'N'                                             ITEM_DIST_CHANGED_FLAG,
      --'N'                                             ASSOCIATED_CHILD_FROZEN_FLAG,
      DECODE(memoline.line_type, 'TAX', 'Y', 'N')     TAX_ONLY_LINE_FLAG,
      --'N'                                             COMPOUNDING_DEP_TAX_FLAG,
      --'N'                                             ENFORCE_FROM_NATURAL_ACCT_FLAG,
      --'N'                                             COMPOUNDING_TAX_MISS_FLAG,
      --'N'                                             SYNC_WITH_PRVDR_FLAG,
      --NULL                                            LAST_MANUAL_ENTRY,
      decode(arsysparam.tax_database_view_set,'_A',2,'_V',1, NULL)
						      TAX_PROVIDER_ID,
      --NULL                                            REPORTING_PERIOD_ID,
      --NULL                                            LEGAL_MESSAGE_APPL_2,
      --NULL                                            LEGAL_MESSAGE_STATUS,
      --NULL                                            LEGAL_MESSAGE_RATE,
      --NULL                                            LEGAL_MESSAGE_BASIS,
      --NULL                                            LEGAL_MESSAGE_CALC,
      --NULL                                            LEGAL_MESSAGE_THRESHOLD,
      --NULL                                            LEGAL_MESSAGE_POS,
      --NULL                                            LEGAL_MESSAGE_TRN,
      --NULL                                            LEGAL_MESSAGE_EXMPT,
      --NULL                                            LEGAL_MESSAGE_EXCPT,
      --NULL                                            TAX_REGIME_TEMPLATE_ID,
      --NULL                                            TAX_APPLICABILITY_RESULT_ID,
      --NULL                                            DIRECT_RATE_RESULT_ID,
      --NULL                                            STATUS_RESULT_ID,
      --NULL                                            RATE_RESULT_ID,
      --NULL                                            BASIS_RESULT_ID,
      --NULL                                            THRESH_RESULT_ID,
      --NULL                                            CALC_RESULT_ID,
      --NULL                                            TAX_REG_NUM_DET_RESULT_ID,
      --NULL                                            EVAL_EXMPT_RESULT_ID,
      --NULL                                            EVAL_EXCPT_RESULT_ID,
      --NULL                                            TAX_HOLD_CODE,
      --NULL                                            TAX_HOLD_RELEASED_CODE,
      --NULL                                            PRD_TOTAL_TAX_AMT,
      --NULL                                            PRD_TOTAL_TAX_AMT_TAX_CURR,
      --NULL                                            PRD_TOTAL_TAX_AMT_FUNCL_CURR,
      custtrxl.GLOBAL_ATTRIBUTE8                      LEGAL_JUSTIFICATION_TEXT1,
      custtrxl.GLOBAL_ATTRIBUTE9                      LEGAL_JUSTIFICATION_TEXT2,
      custtrxl.GLOBAL_ATTRIBUTE10                     LEGAL_JUSTIFICATION_TEXT3,
      --NULL                                            REPORTING_CURRENCY_CODE,
      --NULL                                            LINE_ASSESSABLE_VALUE,
      --NULL                                            TRX_LINE_INDEX,
      --NULL                                            OFFSET_TAX_RATE_CODE,
      --NULL                                            PRORATION_CODE,
      --NULL                                            OTHER_DOC_SOURCE,
      --NULL                                            MRC_LINK_TO_TAX_LINE_ID,
      --NULL                                            APPLIED_TO_TRX_NUMBER,
      --NULL                                            INTERFACE_TAX_LINE_ID,
      --NULL                                            TAXING_JURIS_GEOGRAPHY_ID,
      decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute2,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute2,null),
                        NULL)                               numeric1,
                decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute4,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute4,null),
                        NULL)                               numeric2,
                decode(arsysparam.tax_database_view_Set ,
                        '_A',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute6,null),
                        '_V',decode(custtrxl.global_attribute1,'ALL',
				    custtrxl.global_Attribute6,null),
                        NULL)                               numeric3,
     decode(arsysparam.tax_database_view_Set,
                        '_A',
                decode(custtrxl.global_attribute1,'ALL',
			     to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                        'STATE',
                             to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                                        NULL),
                        '_V',
                decode(custtrxl.global_attribute1,'ALL',
			     to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                       'STATE',
                             to_number(substrb(custtrxl.global_Attribute12,1,
                             instrb(custtrxl.global_Attribute12,'|',1,1)-1)),
                                        NULL)
                      ,NULL) numeric4,

      --DECODE(custtrxl.line_type,
      --  'TAX', custtrxl.previous_customer_trx_line_id,
      --  NULL)                                         ADJUSTED_DOC_TAX_LINE_ID,
      decode(custtrxl_prev.line_type, 'TAX', custtrxl_prev.tax_line_id, null) ADJUSTED_DOC_TAX_LINE_ID, -- 6705409
      custtrxl.ATTRIBUTE_CATEGORY                     ATTRIBUTE_CATEGORY,
      custtrxl.ATTRIBUTE1                             ATTRIBUTE1,
      custtrxl.ATTRIBUTE2                             ATTRIBUTE2,
      custtrxl.ATTRIBUTE3                             ATTRIBUTE3,
      custtrxl.ATTRIBUTE4                             ATTRIBUTE4,
      custtrxl.ATTRIBUTE5                             ATTRIBUTE5,
      custtrxl.ATTRIBUTE6                             ATTRIBUTE6,
      custtrxl.ATTRIBUTE7                             ATTRIBUTE7,
      custtrxl.ATTRIBUTE8                             ATTRIBUTE8,
      custtrxl.ATTRIBUTE9                             ATTRIBUTE9,
      custtrxl.ATTRIBUTE10                            ATTRIBUTE10,
      custtrxl.ATTRIBUTE11                            ATTRIBUTE11,
      custtrxl.ATTRIBUTE12                            ATTRIBUTE12,
      custtrxl.ATTRIBUTE13                            ATTRIBUTE13,
      custtrxl.ATTRIBUTE14                            ATTRIBUTE14,
      custtrxl.ATTRIBUTE15                            ATTRIBUTE15,
      custtrxl.GLOBAL_ATTRIBUTE_CATEGORY              GLOBAL_ATTRIBUTE_CATEGORY,
      custtrxl.GLOBAL_ATTRIBUTE1                      GLOBAL_ATTRIBUTE1,
      custtrxl.GLOBAL_ATTRIBUTE2                      GLOBAL_ATTRIBUTE2,
      custtrxl.GLOBAL_ATTRIBUTE3                      GLOBAL_ATTRIBUTE3,
      custtrxl.GLOBAL_ATTRIBUTE4                      GLOBAL_ATTRIBUTE4,
      custtrxl.GLOBAL_ATTRIBUTE5                      GLOBAL_ATTRIBUTE5,
      custtrxl.GLOBAL_ATTRIBUTE6                      GLOBAL_ATTRIBUTE6,
      custtrxl.GLOBAL_ATTRIBUTE7                      GLOBAL_ATTRIBUTE7,
      custtrxl.GLOBAL_ATTRIBUTE8                      GLOBAL_ATTRIBUTE8,
      custtrxl.GLOBAL_ATTRIBUTE9                      GLOBAL_ATTRIBUTE9,
      custtrxl.GLOBAL_ATTRIBUTE10                     GLOBAL_ATTRIBUTE10,
      custtrxl.GLOBAL_ATTRIBUTE11                     GLOBAL_ATTRIBUTE11,
      custtrxl.GLOBAL_ATTRIBUTE12                     GLOBAL_ATTRIBUTE12,
      custtrxl.GLOBAL_ATTRIBUTE13                     GLOBAL_ATTRIBUTE13,
      custtrxl.GLOBAL_ATTRIBUTE14                     GLOBAL_ATTRIBUTE14,
      custtrxl.GLOBAL_ATTRIBUTE15                     GLOBAL_ATTRIBUTE15,
      custtrxl.GLOBAL_ATTRIBUTE16                     GLOBAL_ATTRIBUTE16,
      custtrxl.GLOBAL_ATTRIBUTE17                     GLOBAL_ATTRIBUTE17,
      custtrxl.GLOBAL_ATTRIBUTE18                     GLOBAL_ATTRIBUTE18,
      custtrxl.GLOBAL_ATTRIBUTE19                     GLOBAL_ATTRIBUTE19,
      custtrxl.GLOBAL_ATTRIBUTE20                     GLOBAL_ATTRIBUTE20,
      --'N'                                             MULTIPLE_JURISDICTIONS_FLAG,
      SYSDATE                                         CREATION_DATE,
      1                                               CREATED_BY,
      SYSDATE                                         LAST_UPDATE_DATE,
      1                                               LAST_UPDATED_BY,
      0                                               LAST_UPDATE_LOGIN,
      DECODE(custtrx.complete_flag,
          'Y', '111111111111111',
               '000000000000000')                     LEGAL_REPORTING_STATUS,
      custtrxl.autotax                                AUTOTAX
  FROM   ( select distinct other_doc_application_id,other_doc_trx_id from ZX_VALIDATION_ERRORS_GT ) zxvalerr, --Bug 5187701
            RA_CUSTOMER_TRX_ALL        custtrx,
            AR_SYSTEM_PARAMETERS_ALL   arsysparam,
            RA_CUST_TRX_TYPES_ALL      types,
            FND_CURRENCIES             fndcurr,
            FND_DOCUMENT_SEQUENCES     fds,
            ZX_PARTY_TAX_PROFILE       ptp,
            RA_BATCH_SOURCES_ALL       rbs,
            RA_CUSTOMER_TRX_ALL        custtrx_prev,
	    RA_CUSTOMER_TRX_LINES_ALL  custtrxl_prev, -- 6705409
            RA_CUSTOMER_TRX_LINES_ALL  custtrxl,
            AR_VAT_TAX_ALL_B           vat,
            ZX_RATES_B                 rates ,
            RA_CUSTOMER_TRX_LINES_ALL  custtrxll,  -- retrieve the line for tax lines
            AR_MEMO_LINES_ALL_B        memoline,
            ZX_REGIMES_B               regimes,
            ZX_TAXES_B                 taxes,
            ZX_STATUS_B                status
    WHERE zxvalerr.other_doc_application_id = 222
      AND custtrx.customer_trx_id = zxvalerr.other_doc_trx_id
      AND custtrx.customer_trx_id = custtrxl.customer_trx_id
      AND custtrx.previous_customer_trx_id = custtrx_prev.customer_trx_id(+)
      AND custtrxl.previous_customer_trx_line_id = custtrxl_prev.customer_trx_line_id(+) -- 6705409
      AND (case when (custtrxl.line_type IN ('LINE' ,'CB')) then custtrxl.customer_trx_line_id
 	                    when (custtrxl.line_type = 'TAX') then custtrxl.link_to_cust_trx_line_id
 	               end
 	              ) = custtrxll.customer_trx_line_id
 	          AND ((custtrxl.line_type = 'TAX' AND custtrxll.line_type = 'LINE')
 	               OR
 	    	   (custtrxl.line_type <> 'TAX')
 	              )
      AND custtrx.cust_trx_type_id = types.cust_trx_type_id
      AND types.type in ('INV','CM', 'DM')
      AND decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id) =
            decode(l_multi_org_flag,'N',l_org_id, types.org_id)
      AND custtrx.invoice_currency_code = fndcurr.currency_code
      AND custtrx.doc_sequence_id = fds.doc_sequence_id (+)
      AND ptp.party_id = decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id)
      AND ptp.party_type_code = 'OU'
      AND custtrx.batch_source_id = rbs.batch_source_id(+)
      AND decode(l_multi_org_flag,'N',l_org_id, custtrx.org_id) =
            decode(l_multi_org_flag,'N',l_org_id, rbs.org_id(+))
      AND custtrxl.vat_tax_id = vat.vat_tax_id(+)
      AND custtrx.org_id = arsysparam.org_id
      AND custtrxl.vat_Tax_id = rates.tax_rate_id(+)
      AND custtrxll.memo_line_id = memoline.memo_line_id(+)
      AND decode(l_multi_org_flag,'N',l_org_id, custtrxll.org_id) = decode(l_multi_org_flag,'N',l_org_id, memoline.org_id(+))
      AND rates.tax_regime_code = regimes.tax_regime_code(+)
      AND rates.tax_regime_code = taxes.tax_regime_code(+)
      AND rates.tax = taxes.tax(+)
      AND rates.content_owner_id = taxes.content_owner_id(+)
      AND rates.tax_regime_code = status.tax_regime_code(+)
      AND rates.tax = status.tax(+)
      AND rates.tax_status_code = status.tax_status_code(+)
      AND rates.content_owner_id = status.content_owner_id(+)
      AND NVL(arsysparam.tax_code, '!') <> 'Localization';

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar(+)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar.END',
                    'ZX_ON_FLY_TRX_UPGRADE_AR_PKG.upgrade_trx_on_fly_blk_ar(-)');
    END IF;

END upgrade_trx_on_fly_blk_ar;

END ZX_ON_FLY_TRX_UPGRADE_AR_PKG;


/
