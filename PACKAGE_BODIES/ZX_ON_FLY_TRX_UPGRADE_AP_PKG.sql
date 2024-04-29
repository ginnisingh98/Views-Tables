--------------------------------------------------------
--  DDL for Package Body ZX_ON_FLY_TRX_UPGRADE_AP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ON_FLY_TRX_UPGRADE_AP_PKG" AS
/* $Header: zxmigtrxflyapb.pls 120.23.12010000.6 2009/07/30 11:53:10 ssohal ship $ */

 g_current_runtime_level      NUMBER;
 g_level_statement            CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_level_procedure            CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_level_event                CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
 g_level_unexpected           CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;


-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- upgrade_trx_on_fly_ap
--
-- DESCRIPTION
-- on the fly migration of one transaction for AP
--
-------------------------------------------------------------------------------

PROCEDURE upgrade_trx_on_fly_ap(
  p_upg_trx_info_rec     IN          ZX_ON_FLY_TRX_UPGRADE_PKG.zx_upg_trx_info_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
) AS

  l_multi_org_flag            fnd_product_groups.multi_org_flag%TYPE;
  l_org_id                    NUMBER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SELECT multi_org_flag INTO l_multi_org_flag FROM fnd_product_groups;

  -- for single org environment, get value of org_id from profile
  IF l_multi_org_flag = 'N' THEN
    FND_PROFILE.GET('ORG_ID',l_org_id);
    IF l_org_id is NULL THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap',
                   'Current envionment is a Single Org environment,'||
                   ' but peofile ORG_ID is not set up');
      END IF;

    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap',
                   'Inserting data into zx_lines_det_factors and zx_lines_summary');
  END IF;


  -- Insert data into zx_lines_det_factors and zx_lines_summary
  --
  INSERT ALL
    WHEN AP_LINE_LOOKUP_CODE IN ('ITEM', 'PREPAY','FREIGHT','MISCELLANEOUS') OR
         TAX_ONLY_LINE_FLAG = 'Y'
    THEN
      INTO ZX_LINES_DET_FACTORS (
		EVENT_ID
		,OBJECT_VERSION_NUMBER
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,EVENT_TYPE_CODE
		,TAX_EVENT_CLASS_CODE
		,TAX_EVENT_TYPE_CODE
		-- ,DOC_EVENT_STATUS
		,LINE_LEVEL_ACTION
		,LINE_CLASS
		-- ,APPLICATION_DOC_STATUS
		,TRX_ID
		,TRX_LINE_ID
		,TRX_LEVEL_TYPE
		,TRX_DATE
		,LEDGER_ID
		,TRX_CURRENCY_CODE
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_RATE
		,CURRENCY_CONVERSION_TYPE
		,MINIMUM_ACCOUNTABLE_UNIT
		,PRECISION
		,LEGAL_ENTITY_ID
		-- ,ESTABLISHMENT_ID
		,DEFAULT_TAXATION_COUNTRY
		,TRX_NUMBER
		,TRX_LINE_NUMBER
		,TRX_LINE_DESCRIPTION
		,TRX_DESCRIPTION
		,TRX_COMMUNICATED_DATE
		,TRX_LINE_GL_DATE
		,BATCH_SOURCE_ID
		-- ,BATCH_SOURCE_NAME
		,DOC_SEQ_ID
		,DOC_SEQ_NAME
		,DOC_SEQ_VALUE
		,TRX_DUE_DATE
		-- ,TRX_TYPE_DESCRIPTION
		,TRX_LINE_TYPE
		,TRX_LINE_DATE
		-- ,TRX_SHIPPING_DATE
		-- ,TRX_RECEIPT_DATE
		,LINE_AMT
		,TRX_LINE_QUANTITY
		,UNIT_PRICE
		,PRODUCT_ID
		-- ,PRODUCT_ORG_ID
		,UOM_CODE
		,PRODUCT_TYPE
		-- ,PRODUCT_CODE
		,PRODUCT_DESCRIPTION
		,FIRST_PTY_ORG_ID
		-- ,ASSET_NUMBER
		-- ,ASSET_ACCUM_DEPRECIATION
		-- ,ASSET_TYPE
		-- ,ASSET_COST
		,ACCOUNT_CCID
		-- ,ACCOUNT_STRING
		-- ,RELATED_DOC_APPLICATION_ID
		-- ,RELATED_DOC_ENTITY_CODE
		-- ,RELATED_DOC_EVENT_CLASS_CODE
		-- ,RELATED_DOC_TRX_ID
		-- ,RELATED_DOC_NUMBER
		-- ,RELATED_DOC_DATE
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_TRX_ID
		,APPLIED_FROM_LINE_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,ADJUSTED_DOC_LINE_ID
		-- ,ADJUSTED_DOC_NUMBER
		-- ,ADJUSTED_DOC_DATE
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID
		-- ,APPLIED_TO_TRX_NUMBER
		,REF_DOC_TRX_LEVEL_TYPE
		,REF_DOC_APPLICATION_ID
		,REF_DOC_ENTITY_CODE
		,REF_DOC_EVENT_CLASS_CODE
		,REF_DOC_TRX_ID
		,REF_DOC_LINE_ID
		-- ,REF_DOC_LINE_QUANTITY
		,APPLIED_TO_TRX_LEVEL_TYPE
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,MERCHANT_PARTY_NAME
		,MERCHANT_PARTY_DOCUMENT_NUMBER
		,MERCHANT_PARTY_REFERENCE
		,MERCHANT_PARTY_TAXPAYER_ID
		,MERCHANT_PARTY_TAX_REG_NUMBER
		-- ,MERCHANT_PARTY_ID
		,MERCHANT_PARTY_COUNTRY
		,START_EXPENSE_DATE
		,SHIP_TO_LOCATION_ID
		-- ,SHIP_FROM_LOCATION_ID
		-- ,BILL_TO_LOCATION_ID
		-- ,BILL_FROM_LOCATION_ID
		-- ,SHIP_TO_PARTY_TAX_PROF_ID
		-- ,SHIP_FROM_PARTY_TAX_PROF_ID
		-- ,BILL_TO_PARTY_TAX_PROF_ID
		-- ,BILL_FROM_PARTY_TAX_PROF_ID
		-- ,SHIP_TO_SITE_TAX_PROF_ID
		-- ,SHIP_FROM_SITE_TAX_PROF_ID
		-- ,BILL_TO_SITE_TAX_PROF_ID
		-- ,BILL_FROM_SITE_TAX_PROF_ID
		-- ,MERCHANT_PARTY_TAX_PROF_ID
		-- ,HQ_ESTB_PARTY_TAX_PROF_ID
		-- ,CTRL_TOTAL_LINE_TX_AMT
		-- ,CTRL_TOTAL_HDR_TX_AMT
		-- ,INPUT_TAX_CLASSIFICATION_CODE
		-- ,OUTPUT_TAX_CLASSIFICATION_CODE
		-- ,INTERNAL_ORG_LOCATION_ID
		,RECORD_TYPE_CODE
		,PRODUCT_FISC_CLASSIFICATION
		,PRODUCT_CATEGORY
		,USER_DEFINED_FISC_CLASS
		,ASSESSABLE_VALUE
		,TRX_BUSINESS_CATEGORY
		,SUPPLIER_TAX_INVOICE_NUMBER
		,SUPPLIER_TAX_INVOICE_DATE
		,SUPPLIER_EXCHANGE_RATE
		,TAX_INVOICE_DATE
		,TAX_INVOICE_NUMBER
		,DOCUMENT_SUB_TYPE
		,LINE_INTENDED_USE
		,PORT_OF_ENTRY_CODE
		-- ,SOURCE_APPLICATION_ID
		-- ,SOURCE_ENTITY_CODE
		-- ,SOURCE_EVENT_CLASS_CODE
		-- ,SOURCE_TRX_ID
		-- ,SOURCE_LINE_ID
		-- ,SOURCE_TRX_LEVEL_TYPE
		,HISTORICAL_FLAG
		,LINE_AMT_INCLUDES_TAX_FLAG
		,CTRL_HDR_TX_APPL_FLAG
		,TAX_REPORTING_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,INCLUSIVE_TAX_OVERRIDE_FLAG
		,THRESHOLD_INDICATOR_FLAG
		,USER_UPD_DET_FACTORS_FLAG
		,TAX_PROCESSING_COMPLETED_FLAG
		,ASSET_FLAG
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
	        ,LAST_UPDATE_LOGIN
	        ,EVENT_CLASS_MAPPING_ID
	        ,SHIP_THIRD_PTY_ACCT_ID
	        ,SHIP_THIRD_PTY_ACCT_SITE_ID
		,GLOBAL_ATTRIBUTE_CATEGORY
		,GLOBAL_ATTRIBUTE1
                -- ,ICX_SESSION_ID
                -- ,TRX_LINE_CURRENCY_CODE
                -- ,TRX_LINE_CURRENCY_CONV_RATE
                -- ,TRX_LINE_CURRENCY_CONV_DATE
                -- ,TRX_LINE_PRECISION
                -- ,TRX_LINE_MAU
                -- ,TRX_LINE_CURRENCY_CONV_TYPE
                -- ,INTERFACE_ENTITY_CODE
                -- ,INTERFACE_LINE_ID
                -- ,SOURCE_TAX_LINE_ID
	        ,BILL_THIRD_PTY_ACCT_ID
	        ,BILL_THIRD_PTY_ACCT_SITE_ID
	        )
        VALUES(
       		EVENT_ID
		,OBJECT_VERSION_NUMBER
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,EVENT_TYPE_CODE
		,TAX_EVENT_CLASS_CODE
		,TAX_EVENT_TYPE_CODE
		-- ,DOC_EVENT_STATUS
		,LINE_LEVEL_ACTION
		,LINE_CLASS
		-- ,APPLICATION_DOC_STATUS
		,TRX_ID
		,TRX_LINE_ID
		,TRX_LEVEL_TYPE
		,TRX_DATE
		,LEDGER_ID
		,TRX_CURRENCY_CODE
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_RATE
		,CURRENCY_CONVERSION_TYPE
		,MINIMUM_ACCOUNTABLE_UNIT
		,PRECISION
		,LEGAL_ENTITY_ID
		-- ,ESTABLISHMENT_ID
		,DEFAULT_TAXATION_COUNTRY
		,TRX_NUMBER
		,TRX_LINE_NUMBER
		,TRX_LINE_DESCRIPTION
		,TRX_DESCRIPTION
		,TRX_COMMUNICATED_DATE
		,TRX_LINE_GL_DATE
		,BATCH_SOURCE_ID
		-- ,BATCH_SOURCE_NAME
		,DOC_SEQ_ID
		,DOC_SEQ_NAME
		,DOC_SEQ_VALUE
		,TRX_DUE_DATE
		-- ,TRX_TYPE_DESCRIPTION
		,TRX_LINE_TYPE
		,TRX_LINE_DATE
		-- ,TRX_SHIPPING_DATE
		-- ,TRX_RECEIPT_DATE
		,LINE_AMT
		,TRX_LINE_QUANTITY
		,UNIT_PRICE
		,PRODUCT_ID
		-- ,PRODUCT_ORG_ID
		,UOM_CODE
		,PRODUCT_TYPE
		-- ,PRODUCT_CODE
		,PRODUCT_DESCRIPTION
		,FIRST_PTY_ORG_ID
		-- ,ASSET_NUMBER
		-- ,ASSET_ACCUM_DEPRECIATION
		-- ,ASSET_TYPE
		-- ,ASSET_COST
		,ACCOUNT_CCID
		-- ,ACCOUNT_STRING
		-- ,RELATED_DOC_APPLICATION_ID
		-- ,RELATED_DOC_ENTITY_CODE
		-- ,RELATED_DOC_EVENT_CLASS_CODE
		-- ,RELATED_DOC_TRX_ID
		-- ,RELATED_DOC_NUMBER
		-- ,RELATED_DOC_DATE
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_TRX_ID
		,APPLIED_FROM_LINE_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,ADJUSTED_DOC_LINE_ID
		-- ,ADJUSTED_DOC_NUMBER
		-- ,ADJUSTED_DOC_DATE
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID
		-- ,APPLIED_TO_TRX_NUMBER
		,REF_DOC_TRX_LEVEL_TYPE
		,REF_DOC_APPLICATION_ID
		,REF_DOC_ENTITY_CODE
		,REF_DOC_EVENT_CLASS_CODE
		,REF_DOC_TRX_ID
		,REF_DOC_LINE_ID
		-- ,REF_DOC_LINE_QUANTITY
		,APPLIED_TO_TRX_LEVEL_TYPE
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,MERCHANT_PARTY_NAME
		,MERCHANT_PARTY_DOCUMENT_NUMBER
		,MERCHANT_PARTY_REFERENCE
		,MERCHANT_PARTY_TAXPAYER_ID
		,MERCHANT_PARTY_TAX_REG_NUMBER
		-- ,MERCHANT_PARTY_ID
		,MERCHANT_PARTY_COUNTRY
		,START_EXPENSE_DATE
		,SHIP_TO_LOCATION_ID
		-- ,SHIP_FROM_LOCATION_ID
		-- ,BILL_TO_LOCATION_ID
		-- ,BILL_FROM_LOCATION_ID
		-- ,SHIP_TO_PARTY_TAX_PROF_ID
		-- ,SHIP_FROM_PARTY_TAX_PROF_ID
		-- ,BILL_TO_PARTY_TAX_PROF_ID
		-- ,BILL_FROM_PARTY_TAX_PROF_ID
		-- ,SHIP_TO_SITE_TAX_PROF_ID
		-- ,SHIP_FROM_SITE_TAX_PROF_ID
		-- ,BILL_TO_SITE_TAX_PROF_ID
		-- ,BILL_FROM_SITE_TAX_PROF_ID
		-- ,MERCHANT_PARTY_TAX_PROF_ID
		-- ,HQ_ESTB_PARTY_TAX_PROF_ID
		-- ,CTRL_TOTAL_LINE_TX_AMT
		-- ,CTRL_TOTAL_HDR_TX_AMT
		-- ,INPUT_TAX_CLASSIFICATION_CODE
		-- ,OUTPUT_TAX_CLASSIFICATION_CODE
		-- ,INTERNAL_ORG_LOCATION_ID
		,RECORD_TYPE_CODE
		,PRODUCT_FISC_CLASSIFICATION
		,PRODUCT_CATEGORY
		,USER_DEFINED_FISC_CLASS
		,ASSESSABLE_VALUE
		,TRX_BUSINESS_CATEGORY
		,SUPPLIER_TAX_INVOICE_NUMBER
		,SUPPLIER_TAX_INVOICE_DATE
		,SUPPLIER_EXCHANGE_RATE
		,TAX_INVOICE_DATE
		,TAX_INVOICE_NUMBER
		,DOCUMENT_SUB_TYPE
		,LINE_INTENDED_USE
		,PORT_OF_ENTRY_CODE
		-- ,SOURCE_APPLICATION_ID
		-- ,SOURCE_ENTITY_CODE
		-- ,SOURCE_EVENT_CLASS_CODE
		-- ,SOURCE_TRX_ID
		-- ,SOURCE_LINE_ID
		-- ,SOURCE_TRX_LEVEL_TYPE
		,HISTORICAL_FLAG
		,LINE_AMT_INCLUDES_TAX_FLAG
		,CTRL_HDR_TX_APPL_FLAG
		,TAX_REPORTING_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,INCLUSIVE_TAX_OVERRIDE_FLAG
		,THRESHOLD_INDICATOR_FLAG
		,USER_UPD_DET_FACTORS_FLAG
		,TAX_PROCESSING_COMPLETED_FLAG
		,ASSET_FLAG
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
	        ,LAST_UPDATE_LOGIN
	        ,EVENT_CLASS_MAPPING_ID
	        ,SHIP_THIRD_PTY_ACCT_ID
	        ,SHIP_THIRD_PTY_ACCT_SITE_ID
		,GLOBAL_ATTRIBUTE_CATEGORY
		,GLOBAL_ATTRIBUTE1
                -- ,ICX_SESSION_ID
                -- ,TRX_LINE_CURRENCY_CODE
                -- ,TRX_LINE_CURRENCY_CONV_RATE
                -- ,TRX_LINE_CURRENCY_CONV_DATE
                -- ,TRX_LINE_PRECISION
                -- ,TRX_LINE_MAU
                -- ,TRX_LINE_CURRENCY_CONV_TYPE
                -- ,INTERFACE_ENTITY_CODE
                -- ,INTERFACE_LINE_ID
                -- ,SOURCE_TAX_LINE_ID
	        ,BILL_THIRD_PTY_ACCT_ID
	        ,BILL_THIRD_PTY_ACCT_SITE_ID
	        )
    WHEN AP_LINE_LOOKUP_CODE = 'TAX' THEN
      INTO ZX_LINES_SUMMARY (
		SUMMARY_TAX_LINE_ID
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,TRX_ID
		,TRX_NUMBER
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_TRX_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,SUMMARY_TAX_LINE_NUMBER
		,CONTENT_OWNER_ID
		,TAX_REGIME_CODE
		,TAX
		,TAX_STATUS_CODE
		,TAX_RATE_ID
		,TAX_RATE_CODE
		,TAX_RATE
		,TAX_AMT
		,TAX_AMT_TAX_CURR
		,TAX_AMT_FUNCL_CURR
		,TAX_JURISDICTION_CODE
		,TOTAL_REC_TAX_AMT
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,LEDGER_ID
		,LEGAL_ENTITY_ID
		-- ,ESTABLISHMENT_ID
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_TYPE
		,CURRENCY_CONVERSION_RATE
		-- ,SUMMARIZATION_TEMPLATE_ID
		,TAXABLE_BASIS_FORMULA
		,TAX_CALCULATION_FORMULA
		,HISTORICAL_FLAG
		,CANCEL_FLAG
		,DELETE_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,SELF_ASSESSED_FLAG
		,OVERRIDDEN_FLAG
		,REPORTING_ONLY_FLAG
		,ASSOCIATED_CHILD_FROZEN_FLAG
		,COPIED_FROM_OTHER_DOC_FLAG
		,MANUALLY_ENTERED_FLAG
		,LAST_MANUAL_ENTRY  --BUG7146063
		,RECORD_TYPE_CODE
		-- ,TAX_PROVIDER_ID
		,TAX_ONLY_LINE_FLAG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
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
		,APPLIED_FROM_LINE_ID
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_LINE_ID
		-- ,TAX_EXEMPTION_ID
		-- ,TAX_RATE_BEFORE_EXEMPTION
		-- ,TAX_RATE_NAME_BEFORE_EXEMPTION
		-- ,EXEMPT_RATE_MODIFIER
		-- ,EXEMPT_CERTIFICATE_NUMBER
		-- ,EXEMPT_REASON
		-- ,EXEMPT_REASON_CODE
		-- ,TAX_RATE_BEFORE_EXCEPTION
		-- ,TAX_RATE_NAME_BEFORE_EXCEPTION
		-- ,TAX_EXCEPTION_ID
		-- ,EXCEPTION_RATE
		,TOTAL_REC_TAX_AMT_TAX_CURR
		,TOTAL_NREC_TAX_AMT_TAX_CURR
		,MRC_TAX_LINE_FLAG
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
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,APPLIED_TO_TRX_LEVEL_TYPE
		,TRX_LEVEL_TYPE
		,ADJUST_TAX_AMT_FLAG
		,OBJECT_VERSION_NUMBER)
        VALUES(
		SUMMARY_TAX_LINE_ID
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,TRX_ID
		,TRX_NUMBER
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_TRX_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,SUMMARY_TAX_LINE_NUMBER
		,CONTENT_OWNER_ID
		,TAX_REGIME_CODE
		,TAX
		,TAX_STATUS_CODE
		,TAX_RATE_ID
		,TAX_RATE_CODE
		,TAX_RATE
		,TAX_AMT
		,TAX_AMT_TAX_CURR
		,TAX_AMT_FUNCL_CURR
		,TAX_JURISDICTION_CODE
		,TOTAL_REC_TAX_AMT
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,LEDGER_ID
		,LEGAL_ENTITY_ID
		-- ,ESTABLISHMENT_ID
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_TYPE
		,CURRENCY_CONVERSION_RATE
		-- ,NULL                                                 -- SUMMARIZATION_TEMPLATE_ID
		,'STANDARD_TB'                                        -- TAXABLE_BASIS_FORMULA
		,'STANDARD_TC'                                        -- TAX_CALCULATION_FORMULA
		,HISTORICAL_FLAG
		,CANCEL_FLAG
		,'N'                                                  -- DELETE_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,SELF_ASSESSED_FLAG
		,OVERRIDDEN_FLAG
		,'N'                                                  -- REPORTING_ONLY_FLAG
		,'N'                                                  -- ASSOCIATED_CHILD_FROZEN_FLAG
		,'N'                                                  -- COPIED_FROM_OTHER_DOC_FLAG
		,MANUALLY_ENTERED_FLAG   --BUG7146063
		,LAST_MANUAL_ENTRY  --BUG7146063
		,RECORD_TYPE_CODE
		-- ,NULL                                              -- TAX_PROVIDER_ID
		,TAX_ONLY_LINE_FLAG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
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
		,APPLIED_FROM_LINE_ID
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID                               -- APPLIED_TO_LINE_ID
		-- ,NULL                                              -- TAX_EXEMPTION_ID
		-- ,NULL                                              -- TAX_RATE_BEFORE_EXEMPTION
		-- ,NULL                                              -- TAX_RATE_NAME_BEFORE_EXEMPTION
		-- ,NULL                                              -- EXEMPT_RATE_MODIFIER
		-- ,NULL                                              -- EXEMPT_CERTIFICATE_NUMBER
		-- ,NULL                                              -- EXEMPT_REASON
		-- ,NULL                                              -- EXEMPT_REASON_CODE
		-- ,NULL                                              -- TAX_RATE_BEFORE_EXCEPTION
		-- ,NULL                                              -- TAX_RATE_NAME_BEFORE_EXCEPTION
		-- ,NULL                                              -- TAX_EXCEPTION_ID
		-- ,NULL                                              -- EXCEPTION_RATE
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,'N'                                                  -- MRC_TAX_LINE_FLAG
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
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,APPLIED_TO_TRX_LEVEL_TYPE
		,TRX_LEVEL_TYPE
		,NULL                                                -- ADJUST_TAX_AMT_FLAG
		,OBJECT_VERSION_NUMBER
		)
       (SELECT  /*+ ROWID(inv) ORDERED use_nl(fnd_curr,fds,lines,poll,ptp)*/
                NULL                                                  EVENT_ID
                ,1                                                    OBJECT_VERSION_NUMBER
                ,NVL(lines.org_id,-99)                                INTERNAL_ORGANIZATION_ID
                ,200                                                  APPLICATION_ID
                ,'AP_INVOICES'                                        ENTITY_CODE
                ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                  'STANDARD', 'STANDARD INVOICES',
		  'CREDIT'  , 'STANDARD INVOICES',   --Bug 6489409
	          'DEBIT'   , 'STANDARD INVOICES',   --Bug 6489409
		  'MIXED'   , 'STANDARD INVOICES',   --Bug 6489409
		  'ADJUSTMENT','STANDARD INVOICES',  --Bug 6489409
		  'PO PRICE ADJUST','STANDARD INVOICES', --Bug 6489409
		  'INVOICE REQUEST','STANDARD INVOICES', --Bug 6489409
		  'CREDIT MEMO REQUEST','STANDARD INVOICES',--Bug 6489409
 		  'RETAINAGE RELEASE'  ,'STANDARD INVOICES',--Bug 6489409
                  'PREPAYMENT', 'PREPAYMENT INVOICES',
                  'EXPENSE REPORT', 'EXPENSE REPORTS',
                  'INTEREST INVOICE', 'INTEREST INVOICES','NA')       EVENT_CLASS_CODE
                ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE, 'STANDARD', 1,
                  'PREPAYMENT', 7, 'EXPENSE REPORT', 2, NULL)         EVENT_CLASS_MAPPING_ID
                ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                  'STANDARD','STANDARD INVOICE CREATED',
                  'PREPAYMENT','PREPAYMENT INVOICE CREATED',
                  'EXPENSE REPORT','EXPENSE REPORT CREATED',
                  'INTEREST INVOICE','INTEREST INVOICE CREATED','NA') EVENT_TYPE_CODE
               ,(CASE
                 WHEN inv.invoice_type_lookup_code in
                   ('ADJUSTMENT','CREDIT','DEBIT','INTEREST',
                    'MIXED','QUICKDEFAULT','PO PRICE ADJUST',
                    'QUICKMATCH','STANDARD','AWT')
                  THEN 'PURCHASE_TRANSACTION'
                 WHEN inv.invoice_type_lookup_code = 'PREPAYMENT'
                  THEN 'PURCHASE_PREPAYMENTTRANSACTION'
                 WHEN inv.invoice_type_lookup_code='EXPENSE REPORT'
                  THEN  'EXPENSE_REPORT'
                 ELSE   NULL
                END)                                                  TAX_EVENT_CLASS_CODE
                ,'VALIDATE'                                           TAX_EVENT_TYPE_CODE
                -- ,NULL                                              DOC_EVENT_STATUS
                ,'CREATE'                                             LINE_LEVEL_ACTION
                ,DECODE(lines.po_line_location_id,
                  NULL, DECODE(lines.line_type_lookup_code,
                         'PREPAY', 'PREPAY_APPLICATION',
                          DECODE(inv.invoice_type_lookup_code,
                                'STANDARD', 'STANDARD INVOICES',
                                'CREDIT','AP_CREDIT_MEMO',
                                'CREDIT MEMO REQUEST', 'AP_CREDIT_MEMO',
                                'DEBIT','AP_DEBIT_MEMO',
                                'PREPAYMENT','PREPAYMENT INVOICES',
                                'EXPENSE REPORT','EXPENSE REPORTS',
                                'STANDARD INVOICES'
                                )
                               ),
                        DECODE(poll.shipment_type,
                         'PREPAYMENT', DECODE(poll.payment_type,
                                         'ADVANCE', 'ADVANCE',
                                         'MILESTONE', 'FINANCING',
                                         'RATE', 'FINANCING',
                                         'LUMPSUM', 'FINANCING',
                                         DECODE(poll.matching_basis,
                                           'AMOUNT','AMOUNT_MATCHED',
                                           'STANDARD INVOICES')
                                              ),
                                       DECODE(poll.matching_basis,
                                        'AMOUNT','AMOUNT_MATCHED',
                                        'STANDARD INVOICES')
                               )
                      )                                               LINE_CLASS
                -- ,NULL                                              APPLICATION_DOC_STATUS
                ,lines.line_type_lookup_code                          AP_LINE_LOOKUP_CODE
                ,lines.invoice_id                                     TRX_ID
                ,NVL(inv.invoice_date,sysdate)                        TRX_DATE
                ,lines.set_of_books_id                                LEDGER_ID
                ,inv.invoice_currency_code                            TRX_CURRENCY_CODE
		,NVL(inv.legal_entity_id, -99)                        LEGAL_ENTITY_ID
		-- ,NULL					      ESTABLISHMENT_ID
                ,inv.taxation_country                                 DEFAULT_TAXATION_COUNTRY
                ,inv.invoice_num                                      TRX_NUMBER
                ,lines.description                                    TRX_LINE_DESCRIPTION
                ,inv.description                                      TRX_DESCRIPTION
                ,inv.invoice_received_date                            TRX_COMMUNICATED_DATE
                ,NVL(lines.accounting_date,sysdate)                   TRX_LINE_GL_DATE
                ,inv.batch_id                                         BATCH_SOURCE_ID
                -- ,NULL                                              BATCH_SOURCE_NAME
                ,inv.doc_sequence_id                                  DOC_SEQ_ID
                ,fds.name                                             DOC_SEQ_NAME
                ,inv.doc_sequence_value                               DOC_SEQ_VALUE
                ,inv.terms_date                                       TRX_DUE_DATE
                -- ,NULL                                              TRX_TYPE_DESCRIPTION
                ,lines.line_type_lookup_code                          TRX_LINE_TYPE
                ,lines.accounting_date                                TRX_LINE_DATE
                -- ,NULL                                              TRX_SHIPPING_DATE
                -- ,NULL                                              TRX_RECEIPT_DATE
                ,NVL(lines.amount,0)                                  LINE_AMT
                ,lines.quantity_invoiced                              TRX_LINE_QUANTITY
                ,lines.unit_price                                     -- UNIT_PRICE
                ,lines.inventory_item_id                              PRODUCT_ID
                -- ,NULL                                              PRODUCT_ORG_ID
                ,lines.unit_meas_lookup_code                          UOM_CODE
                ,lines.product_type                                   -- PRODUCT_TYPE
                -- ,NULL                                              PRODUCT_CODE
                ,lines.item_description                               PRODUCT_DESCRIPTION
                ,ptp.party_tax_profile_id                             FIRST_PTY_ORG_ID
                -- ,NULL                                              ASSET_NUMBER
                -- ,NULL                                              ASSET_ACCUM_DEPRECIATION
                -- ,NULL                                              ASSET_TYPE
                -- ,NULL                                              ASSET_COST
                -- ,NULL                                              RELATED_DOC_APPLICATION_ID,
                -- ,NULL                                              RELATED_DOC_ENTITY_CODE
                -- ,NULL                                              RELATED_DOC_EVENT_CLASS_CODE
                -- ,NULL                                              RELATED_DOC_TRX_ID
                -- ,NULL                                              RELATED_DOC_NUMBER
                -- ,NULL                                              RELATED_DOC_DATE
                ,DECODE(lines.prepay_invoice_id, NULL, NULL, 200)     APPLIED_FROM_APPLICATION_ID
                ,DECODE(lines.prepay_invoice_id, NULL, NULL,
                        'AP_INVOICES')                                APPLIED_FROM_ENTITY_CODE
                ,DECODE(lines.prepay_invoice_id, NULL, NULL,
                        'PREPAYMENT INVOICES')                        APPLIED_FROM_EVENT_CLASS_CODE
                ,lines.prepay_invoice_id                              APPLIED_FROM_TRX_ID
                ,lines.prepay_line_number                             APPLIED_FROM_LINE_ID
                ,DECODE(lines.corrected_inv_id, NULL, NULL, 200)      ADJUSTED_DOC_APPLICATION_ID
                ,DECODE(lines.corrected_inv_id, NULL, NULL,
                        'AP_INVOICES')                                ADJUSTED_DOC_ENTITY_CODE
                ,DECODE(lines.corrected_inv_id, NULL, NULL,
                        'STANDARD INVOICES')                          ADJUSTED_DOC_EVENT_CLASS_CODE
                ,lines.corrected_inv_id                               ADJUSTED_DOC_TRX_ID
                ,lines.corrected_line_number                          ADJUSTED_DOC_LINE_ID
                -- ,NULL                                              ADJUSTED_DOC_NUMBER
                -- ,NULL                                              ADJUSTED_DOC_DATE
                ,DECODE(lines.rcv_transaction_id, NULL, NULL, 707)    APPLIED_TO_APPLICATION_ID
                ,DECODE(lines.rcv_transaction_id, NULL, NULL,
                       'RCV_ACCOUNTING_EVENTS')                       APPLIED_TO_ENTITY_CODE
                ,DECODE(lines.rcv_transaction_id, NULL, NULL,
                        'RCPT_REC_INSP')                              APPLIED_TO_EVENT_CLASS_CODE
                ,lines.rcv_transaction_id                             APPLIED_TO_TRX_ID
                ,lines.rcv_shipment_line_id                           APPLIED_TO_TRX_LINE_ID
                -- ,NULL                                              APPLIED_TO_TRX_NUMBER
                ,DECODE(NVL(lines.po_release_id, lines.po_header_id),
                        NULL, NULL, 'SHIPMENT')                       REF_DOC_TRX_LEVEL_TYPE
                ,NVL(lines.po_release_id, lines.po_header_id)         REF_DOC_TRX_ID
                ,lines.po_line_location_id                            REF_DOC_LINE_ID
                -- ,NULL                                              REF_DOC_LINE_QUANTITY
                ,DECODE(lines.rcv_transaction_id, NULL, NULL,
                        'LINE')                                       APPLIED_TO_TRX_LEVEL_TYPE
                ,DECODE(lines.prepay_invoice_id, NULL, NULL,
                        'LINE')                                       APPLIED_FROM_TRX_LEVEL_TYPE
                ,DECODE(lines.corrected_inv_id, NULL, NULL,
                        'LINE')                                       ADJUSTED_DOC_TRX_LEVEL_TYPE
                ,lines.merchant_name                                  MERCHANT_PARTY_NAME
                ,lines.merchant_document_number                       MERCHANT_PARTY_DOCUMENT_NUMBER
                ,lines.merchant_reference                             MERCHANT_PARTY_REFERENCE
                ,lines.merchant_taxpayer_id                           MERCHANT_PARTY_TAXPAYER_ID
                ,lines.merchant_tax_reg_number                        MERCHANT_PARTY_TAX_REG_NUMBER
                -- ,NULL                                              MERCHANT_PARTY_ID
                ,lines.country_of_supply                              MERCHANT_PARTY_COUNTRY
                ,lines.start_expense_date                             -- START_EXPENSE_DATE
                ,lines.ship_to_location_id                            -- SHIP_TO_LOCATION_ID
                -- ,NULL                                              SHIP_FROM_LOCATION_ID
                -- ,NULL                                              BILL_TO_LOCATION_ID
                -- ,NULL                                              BILL_FROM_LOCATION_ID
                -- ,NULL                                              SHIP_TO_PARTY_TAX_PROF_ID
                -- ,NULL                                              SHIP_FROM_PARTY_TAX_PROF_ID
                -- ,NULL                                              BILL_TO_PARTY_TAX_PROF_ID
                -- ,NULL                                              BILL_FROM_PARTY_TAX_PROF_ID
                -- ,NULL                                              SHIP_TO_SITE_TAX_PROF_ID
                -- ,NULL                                              SHIP_FROM_SITE_TAX_PROF_ID
                -- ,NULL                                              BILL_TO_SITE_TAX_PROF_ID
                -- ,NULL                                              BILL_FROM_SITE_TAX_PROF_ID
                -- ,NULL                                              MERCHANT_PARTY_TAX_PROF_ID
                -- ,NULL                                              HQ_ESTB_PARTY_TAX_PROF_ID
                -- ,NULL                                              CTRL_TOTAL_LINE_TX_AMT
                -- ,NULL                                              CTRL_TOTAL_HDR_TX_AMT
                -- ,NULL                                              INPUT_TAX_CLASSIFICATION_CODE
                -- ,NULL                                              OUTPUT_TAX_CLASSIFICATION_CODE
                -- ,NULL                                              INTERNAL_ORG_LOCATION_ID
                ,'MIGRATED'                                           RECORD_TYPE_CODE
                ,lines.product_fisc_classification                    -- PRODUCT_FISC_CLASSIFICATION
                ,lines.product_category                               -- PRODUCT_CATEGORY
                ,lines.user_defined_fisc_class                        -- USER_DEFINED_FISC_CLASS
                ,lines.assessable_value                               -- ASSESSABLE_VALUE
                ,lines.trx_business_category                          -- TRX_BUSINESS_CATEGORY
                ,inv.supplier_tax_invoice_number                      -- SUPPLIER_TAX_INVOICE_NUMBER
                ,inv.supplier_tax_invoice_date                        -- SUPPLIER_TAX_INVOICE_DATE
                ,inv.supplier_tax_exchange_rate                       SUPPLIER_EXCHANGE_RATE
                ,inv.tax_invoice_recording_date                       TAX_INVOICE_DATE
                ,inv.tax_invoice_internal_seq                         TAX_INVOICE_NUMBER
                ,inv.document_sub_type                                -- DOCUMENT_SUB_TYPE
                ,lines.primary_intended_use                           LINE_INTENDED_USE
                ,inv.port_of_entry_code                               -- PORT_OF_ENTRY_CODE
                -- ,NULL                                              SOURCE_APPLICATION_ID
                -- ,NULL                                              SOURCE_ENTITY_CODE
                -- ,NULL                                              SOURCE_EVENT_CLASS_CODE
                -- ,NULL                                              SOURCE_TRX_ID,
                -- ,NULL                                              SOURCE_LINE_ID,
                -- ,NULL                                              SOURCE_TRX_LEVEL_TYPE
                ,'N'                                                  LINE_AMT_INCLUDES_TAX_FLAG
                ,'N'                                                  CTRL_HDR_TX_APPL_FLAG
                ,'Y'                                                  TAX_REPORTING_FLAG
                ,'N'                                                  TAX_AMT_INCLUDED_FLAG
                ,'N'                                                  COMPOUNDING_TAX_FLAG
                ,'N'                                                  INCLUSIVE_TAX_OVERRIDE_FLAG
                ,'N'                                                  THRESHOLD_INDICATOR_FLAG
                ,'N'                                                  USER_UPD_DET_FACTORS_FLAG
                ,'N'                                                  TAX_PROCESSING_COMPLETED_FLAG
                ,lines.assets_tracking_flag                           ASSET_FLAG
                ,ptp.party_tax_profile_id                             CONTENT_OWNER_ID
                ,inv.exchange_date                                    CURRENCY_CONVERSION_DATE
                ,inv.exchange_rate                                    CURRENCY_CONVERSION_RATE
                ,inv.exchange_rate_type                               CURRENCY_CONVERSION_TYPE
                ,fnd_curr.minimum_accountable_unit                    MINIMUM_ACCOUNTABLE_UNIT
                ,NVL(fnd_curr.precision,0)                            PRECISION
                ,DECODE(NVL(lines.po_release_id, lines.po_header_id),
                        NULL, NULL, 201)                              REF_DOC_APPLICATION_ID
                ,DECODE(lines.po_release_id, NULL,
                   DECODE(lines.po_header_id, NULL, NULL,
                          'PURCHASE_ORDER'), 'RELEASE')               REF_DOC_ENTITY_CODE
                ,DECODE(lines.po_release_id, NULL,
                   DECODE(lines.po_header_id, NULL, NULL,
                           'PO_PA'), 'RELEASE')                       REF_DOC_EVENT_CLASS_CODE
                ,lines.SUMMARY_TAX_LINE_ID 			      SUMMARY_TAX_LINE_ID
                ,lines.TAX                                            TAX
                ,DECODE(lines.line_type_lookup_code, 'TAX',
                  RANK() OVER (PARTITION BY inv.invoice_id,
                                lines.line_type_lookup_code
                                ORDER BY lines.line_number), NULL)    SUMMARY_TAX_LINE_NUMBER
                ,lines.tax_rate                                       -- TAX_RATE
                ,lines.tax_rate_code                                  -- TAX_RATE_CODE
                ,lines.tax_rate_id                                    -- TAX_RATE_ID
                ,lines.tax_regime_code                                -- TAX_REGIME_CODE
                ,lines.tax_status_code                                -- TAX_STATUS_CODE
                ,lines.tax_jurisdiction_code                          -- TAX_JURISDICTION_CODE
                ,'LINE'                                               TRX_LEVEL_TYPE
                ,lines.line_number                                    TRX_LINE_ID
                ,lines.line_number                                    TRX_LINE_NUMBER
                ,lines.default_dist_ccid                              ACCOUNT_CCID
                -- ,NULL                                              ACCOUNT_STRING
                ,lines.amount                                         TAX_AMT
                ,lines.base_amount                                    TAX_AMT_TAX_CURR
                ,lines.base_amount                                    TAX_AMT_FUNCL_CURR
                ,lines.attribute_category                             -- ATTRIBUTE_CATEGORY
                ,lines.attribute1                                     -- ATTRIBUTE1
                ,lines.attribute2                                     -- ATTRIBUTE2
                ,lines.attribute3                                     -- ATTRIBUTE3
                ,lines.attribute4                                     -- ATTRIBUTE4
                ,lines.attribute5                                     -- ATTRIBUTE5
                ,lines.attribute6                                     -- ATTRIBUTE6
                ,lines.attribute7                                     -- ATTRIBUTE7
                ,lines.attribute8                                     -- ATTRIBUTE8
                ,lines.attribute9                                     -- ATTRIBUTE9
                ,lines.attribute10                                    -- ATTRIBUTE10
                ,lines.attribute11                                    -- ATTRIBUTE11
                ,lines.attribute12                                    -- ATTRIBUTE12
                ,lines.attribute13                                    -- ATTRIBUTE13
                ,lines.attribute14                                    -- ATTRIBUTE14
                ,lines.attribute15                                    -- ATTRIBUTE15
                ,lines.global_attribute_category                      -- GLOBAL_ATTRIBUTE_CATEGORY
                ,lines.global_attribute1                              -- GLOBAL_ATTRIBUTE1
                ,lines.global_attribute2                              -- GLOBAL_ATTRIBUTE2
                ,lines.global_attribute3                              -- GLOBAL_ATTRIBUTE3
                ,lines.global_attribute4                              -- GLOBAL_ATTRIBUTE4
                ,lines.global_attribute5                              -- GLOBAL_ATTRIBUTE5
                ,lines.global_attribute6                              -- GLOBAL_ATTRIBUTE6
                ,lines.global_attribute7                              -- GLOBAL_ATTRIBUTE7
                ,lines.global_attribute8                              -- GLOBAL_ATTRIBUTE8
                ,lines.global_attribute9                              -- GLOBAL_ATTRIBUTE9
                ,lines.global_attribute10                             -- GLOBAL_ATTRIBUTE10
                ,lines.global_attribute11                             -- GLOBAL_ATTRIBUTE11
                ,lines.global_attribute12                             -- GLOBAL_ATTRIBUTE12
                ,lines.global_attribute13                             -- GLOBAL_ATTRIBUTE13
                ,lines.global_attribute14                             -- GLOBAL_ATTRIBUTE14
                ,lines.global_attribute15                             -- GLOBAL_ATTRIBUTE15
                ,lines.global_attribute16                             -- GLOBAL_ATTRIBUTE16
                ,lines.global_attribute17                             -- GLOBAL_ATTRIBUTE17
                ,lines.global_attribute18                             -- GLOBAL_ATTRIBUTE18
                ,lines.global_attribute19                             -- GLOBAL_ATTRIBUTE19
                ,lines.global_attribute20                             -- GLOBAL_ATTRIBUTE20
                ,'Y'                                                  HISTORICAL_FLAG
                ,'N'                                                  OVERRIDDEN_FLAG
                ,'N'                                                  SELF_ASSESSED_FLAG
                ,1                                                    CREATED_BY
                ,SYSDATE                                              CREATION_DATE
                ,SYSDATE                                              LAST_UPDATE_DATE
                ,1                                                    LAST_UPDATE_LOGIN
                ,1                                                    LAST_UPDATED_BY
                -- ,NULL                                              LAST_MANUAL_ENTRY
                ,CASE
                  WHEN lines.line_type_lookup_code <> 'TAX'
                   THEN NULL
                  WHEN NOT EXISTS          -- Tax Lines
                    (SELECT 1
                       FROM AP_INV_DISTS_TARGET dists
                      WHERE dists.invoice_id = lines.invoice_id
                        AND dists.invoice_line_number = lines.line_number
                        AND dists.charge_applicable_to_dist_id IS NOT NULL
                     )
                   THEN 'Y'
                  ELSE  'N'
                END                                                   TAX_ONLY_LINE_FLAG
                ,lines.total_rec_tax_amount                           TOTAL_REC_TAX_AMT
                ,lines.total_nrec_tax_amount                          TOTAL_NREC_TAX_AMT
                ,lines.total_rec_tax_amt_funcl_curr                   -- TOTAL_REC_TAX_AMT_FUNCL_CURR,
                ,lines.total_nrec_tax_amt_funcl_curr                  -- TOTAL_NREC_TAX_AMT_FUNCL_CURR,
                ,inv.vendor_id 					      SHIP_THIRD_PTY_ACCT_ID
	        ,inv.vendor_site_id				      SHIP_THIRD_PTY_ACCT_SITE_ID
                ,inv.vendor_id 					      BILL_THIRD_PTY_ACCT_ID
	        ,inv.vendor_site_id				      BILL_THIRD_PTY_ACCT_SITE_ID
                -- ,NULL                                              ICX_SESSION_ID
                -- ,NULL                                              TRX_LINE_CURRENCY_CODE
                -- ,NULL                                              TRX_LINE_CURRENCY_CONV_RATE
                -- ,NULL                                              TRX_LINE_CURRENCY_CONV_DATE
                -- ,NULL                                              TRX_LINE_PRECISION
                -- ,NULL                                              TRX_LINE_MAU
                -- ,NULL                                              TRX_LINE_CURRENCY_CONV_TYPE
                -- ,NULL                                              INTERFACE_ENTITY_CODE
                -- ,NULL                                              INTERFACE_LINE_ID
                -- ,NULL                                              SOURCE_TAX_LINE_ID
                ,DECODE(lines.discarded_flag, 'Y', 'Y', 'N')          CANCEL_FLAG
                ,DECODE(lines.line_source,'MANUAL LINE ENTRY','Y','N')    MANUALLY_ENTERED_FLAG  --BUG7146063
                ,DECODE(lines.line_source,'MANUAL LINE ENTRY','TAX_AMOUNT',NULL)    LAST_MANUAL_ENTRY  --BUG7146063
           FROM ap_invoices_all          inv,
                fnd_currencies           fnd_curr,
                fnd_document_sequences   fds,
                ap_invoice_lines_all     lines,
                po_line_locations_all    poll,
                zx_party_tax_profile     ptp
          WHERE inv.invoice_id = p_upg_trx_info_rec.trx_id
            AND fnd_curr.currency_code = inv.invoice_currency_code
            AND inv.doc_sequence_id = fds.doc_sequence_id(+)
            AND lines.invoice_id = inv.invoice_id
            AND NVL(lines.historical_flag, 'N') = 'Y'
            AND poll.line_location_id(+) = lines.po_line_location_id
            AND ptp.party_type_code = 'OU'
            AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,lines.org_id)
	    AND NOT EXISTS (SELECT 1 FROM zx_lines_det_factors zxdet --Bug 6738188
                WHERE zxdet.application_id   = 200
                  AND zxdet.entity_code      = 'AP_INVOICES'
                  AND zxdet.event_class_code   = DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                                              'STANDARD', 'STANDARD INVOICES',
                                              'CREDIT'  , 'STANDARD INVOICES',
                                              'DEBIT'   , 'STANDARD INVOICES',
                                              'MIXED'   , 'STANDARD INVOICES',
                                              'ADJUSTMENT','STANDARD INVOICES',
                                              'PO PRICE ADJUST','STANDARD INVOICES',
                                              'INVOICE REQUEST','STANDARD INVOICES',
                                              'CREDIT MEMO REQUEST','STANDARD INVOICES',
                                              'RETAINAGE RELEASE'  ,'STANDARD INVOICES',
                                              'PREPAYMENT', 'PREPAYMENT INVOICES',
                                              'EXPENSE REPORT', 'EXPENSE REPORTS',
                                              'INTEREST INVOICE', 'INTEREST INVOICES','NA')
                  AND zxdet.trx_id=inv.invoice_id
		  AND zxdet.trx_line_id=lines.line_number)
     );

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap',
                   'Inserting data into zx_lines and zx_rec_nrec_dist');
  END IF;

  -- Insert data into zx_lines and zx_rec_nrec_dist
  --
  INSERT ALL
      INTO ZX_REC_NREC_DIST(
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
     		  -- ,ACCOUNT_STRING
     		  -- ,ADJUSTED_DOC_TAX_DIST_ID
     		  -- ,APPLIED_FROM_TAX_DIST_ID
     		  -- ,APPLIED_TO_DOC_CURR_CONV_RATE
     		  ,AWARD_ID
     		  ,EXPENDITURE_ITEM_DATE
     		  ,EXPENDITURE_ORGANIZATION_ID
     		  ,EXPENDITURE_TYPE
     		  ,FUNC_CURR_ROUNDING_ADJUSTMENT
     		  ,GL_DATE
     		  ,INTENDED_USE
     		  ,ITEM_DIST_NUMBER
     		  -- ,MRC_LINK_TO_TAX_DIST_ID
     		  -- ,ORIG_REC_NREC_RATE
     		  -- ,ORIG_REC_NREC_TAX_AMT
     		  -- ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
     		  -- ,ORIG_REC_RATE_CODE
     		  -- ,PER_TRX_CURR_UNIT_NR_AMT
     		  -- ,PER_UNIT_NREC_TAX_AMT
     		  -- ,PRD_TAX_AMT
     		  -- ,PRICE_DIFF
     		  ,PROJECT_ID
     		  -- ,QTY_DIFF
     		  -- ,RATE_TAX_FACTOR
     		  ,REC_NREC_RATE
     		  ,REC_NREC_TAX_AMT
     		  ,REC_NREC_TAX_AMT_FUNCL_CURR
     		  ,REC_NREC_TAX_AMT_TAX_CURR
     		  ,RECOVERY_RATE_CODE
     		  ,RECOVERY_TYPE_CODE
     		  -- ,RECOVERY_TYPE_ID
     		  -- ,REF_DOC_CURR_CONV_RATE
     		  ,REF_DOC_DIST_ID
     		  -- ,REF_DOC_PER_UNIT_NREC_TAX_AMT
     		  -- ,REF_DOC_TAX_DIST_ID
     		  -- ,REF_DOC_TRX_LINE_DIST_QTY
     		  -- ,REF_DOC_UNIT_PRICE
     		  -- ,REF_PER_TRX_CURR_UNIT_NR_AMT
     		  ,REVERSED_TAX_DIST_ID
     		  -- ,ROUNDING_RULE_CODE
     		  ,TASK_ID
     		  ,TAXABLE_AMT_FUNCL_CURR
     		  ,TAXABLE_AMT_TAX_CURR
     		  ,TRX_LINE_DIST_AMT
     		  ,TRX_LINE_DIST_ID
     		  ,TRX_LINE_DIST_QTY
     		  ,TRX_LINE_DIST_TAX_AMT
     		  -- ,UNROUNDED_REC_NREC_TAX_AMT
     		  -- ,UNROUNDED_TAXABLE_AMT
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
     		  ,OBJECT_VERSION_NUMBER
     		  ,ORIG_AP_CHRG_DIST_NUM
                  ,ORIG_AP_CHRG_DIST_ID
                  ,ORIG_AP_TAX_DIST_NUM
                  ,ORIG_AP_TAX_DIST_ID
                 ,INTERNAL_ORGANIZATION_ID
                 ,DEF_REC_SETTLEMENT_OPTION_CODE
                 --,TAX_JURISDICTION_ID
                 ,ACCOUNT_SOURCE_TAX_RATE_ID
		 ,RECOVERY_RATE_ID
                 )
     	 VALUES(
     	         ZX_LINES_S.NEXTVAL
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
     	 	 ,AP_LEDGER_ID
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
     	 	 -- ,ACCOUNT_STRING
     	 	 -- ,ADJUSTED_DOC_TAX_DIST_ID
     	 	 -- ,APPLIED_FROM_TAX_DIST_ID
     	 	 -- ,APPLIED_TO_DOC_CURR_CONV_RATE
     	 	 ,AWARD_ID
     	 	 ,EXPENDITURE_ITEM_DATE
     	 	 ,EXPENDITURE_ORGANIZATION_ID
     	 	 ,EXPENDITURE_TYPE
     	 	 ,FUNC_CURR_ROUNDING_ADJUSTMENT
     	 	 ,GL_DATE
     	 	 ,INTENDED_USE
     	 	 ,ITEM_DIST_NUMBER
     	 	 -- ,MRC_LINK_TO_TAX_DIST_ID
     	 	 -- ,ORIG_REC_NREC_RATE
     	 	 -- ,ORIG_REC_NREC_TAX_AMT
     	 	 -- ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
     	 	 -- ,ORIG_REC_RATE_CODE
     	 	 -- ,PER_TRX_CURR_UNIT_NR_AMT
     	 	 -- ,PER_UNIT_NREC_TAX_AMT
     	 	 -- ,PRD_TAX_AMT
     	 	 -- ,PRICE_DIFF
     	 	 ,PROJECT_ID
     	 	 -- ,QTY_DIFF
     	 	 -- ,RATE_TAX_FACTOR
     	 	 ,REC_NREC_RATE
     	 	 ,REC_NREC_TAX_AMT
     	 	 ,REC_NREC_TAX_AMT_FUNCL_CURR
     	 	 ,REC_NREC_TAX_AMT_TAX_CURR
     	 	 ,RECOVERY_RATE_CODE
     	 	 ,RECOVERY_TYPE_CODE
     	 	 -- ,RECOVERY_TYPE_ID
     	 	 -- ,REF_DOC_CURR_CONV_RATE
     	 	 ,REF_DOC_DIST_ID
     	 	 -- ,REF_DOC_PER_UNIT_NREC_TAX_AMT
     	 	 -- ,REF_DOC_TAX_DIST_ID
     	 	 -- ,REF_DOC_TRX_LINE_DIST_QTY
     	 	 -- ,REF_DOC_UNIT_PRICE
     	 	 -- ,REF_PER_TRX_CURR_UNIT_NR_AMT
     	 	 ,REVERSED_TAX_DIST_ID
     	 	 -- ,ROUNDING_RULE_CODE
     	 	 ,TASK_ID
     	 	 ,TAXABLE_AMT_FUNCL_CURR
     	 	 ,TAXABLE_AMT_TAX_CURR
     	 	 ,TRX_LINE_DIST_AMT
     	 	 ,TRX_LINE_DIST_ID
     	 	 ,TRX_LINE_DIST_QTY
     	 	 ,TRX_LINE_DIST_TAX_AMT
     	 	 -- ,UNROUNDED_REC_NREC_TAX_AMT
     	 	 -- ,UNROUNDED_TAXABLE_AMT
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
 	         ,OBJECT_VERSION_NUMBER
 	         ,ORIG_AP_CHRG_DIST_NUM
                 ,ORIG_AP_CHRG_DIST_ID
                 ,ORIG_AP_TAX_DIST_NUM
                 ,ORIG_AP_TAX_DIST_ID
                 ,INTERNAL_ORGANIZATION_ID
                 ,DEF_REC_SETTLEMENT_OPTION_CODE
                 --,TAX_JURISDICTION_ID
                 ,ACCOUNT_SOURCE_TAX_RATE_ID
		 ,RECOVERY_RATE_ID
                )
   INTO ZX_LINES(
 	 	  TAX_LINE_ID
 	 	  ,TAX_LINE_NUMBER
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
 	 	  ,TAX_RATE_TYPE
 	 	  ,ADJUSTED_DOC_APPLICATION_ID
 	 	  -- ,ADJUSTED_DOC_DATE
 	 	  ,ADJUSTED_DOC_ENTITY_CODE
 	 	  ,ADJUSTED_DOC_EVENT_CLASS_CODE
 	 	  ,ADJUSTED_DOC_LINE_ID
 	 	  -- ,ADJUSTED_DOC_NUMBER
 	 	  ,ADJUSTED_DOC_TRX_ID
 	 	  ,ADJUSTED_DOC_TRX_LEVEL_TYPE
 	 	  ,APPLIED_FROM_APPLICATION_ID
 	 	  ,APPLIED_FROM_ENTITY_CODE
 	 	  ,APPLIED_FROM_EVENT_CLASS_CODE
 	 	  ,APPLIED_FROM_LINE_ID
                  -- ,APPLIED_FROM_TRX_NUMBER
 	 	  ,APPLIED_FROM_TRX_ID
 	 	  ,APPLIED_FROM_TRX_LEVEL_TYPE
 	 	  ,APPLIED_TO_APPLICATION_ID
 	 	  ,APPLIED_TO_ENTITY_CODE
 	 	  ,APPLIED_TO_EVENT_CLASS_CODE
 	 	  ,APPLIED_TO_LINE_ID
 	 	  ,APPLIED_TO_TRX_ID
 	 	  ,APPLIED_TO_TRX_LEVEL_TYPE
 	 	  -- ,APPLIED_TO_TRX_NUMBER
 	 	  -- ,CAL_TAX_AMT
 	 	  -- ,CAL_TAX_AMT_FUNCL_CURR
 	 	  -- ,CAL_TAX_AMT_TAX_CURR
 	 	  -- ,DOC_EVENT_STATUS
 	 	  -- ,INTERNAL_ORG_LOCATION_ID
 	 	  ,INTERNAL_ORGANIZATION_ID
 	 	  ,LINE_AMT
 	 	  ,LINE_ASSESSABLE_VALUE
 	 	  -- ,MRC_LINK_TO_TAX_LINE_ID
 	 	  ,NREC_TAX_AMT
 	 	  ,NREC_TAX_AMT_FUNCL_CURR
 	 	  ,NREC_TAX_AMT_TAX_CURR
 	 	  -- ,OFFSET_LINK_TO_TAX_LINE_ID
 	 	  -- ,OFFSET_TAX_RATE_CODE
 	 	  -- ,ORIG_TAX_AMT
 	 	  -- ,ORIG_TAX_AMT_TAX_CURR
 	 	  -- ,ORIG_TAX_RATE
 	 	  -- ,ORIG_TAX_RATE_CODE
 	 	  -- ,ORIG_TAX_RATE_ID
 	 	  -- ,ORIG_TAX_STATUS_CODE
 	 	  -- ,ORIG_TAX_STATUS_ID
 	 	  -- ,ORIG_TAXABLE_AMT
 	 	  -- ,ORIG_TAXABLE_AMT_TAX_CURR
 	 	  -- ,OTHER_DOC_LINE_AMT
 	 	  -- ,OTHER_DOC_LINE_TAX_AMT
 	 	  -- ,OTHER_DOC_LINE_TAXABLE_AMT
 	 	  -- ,OTHER_DOC_SOURCE
 	 	  -- ,PRORATION_CODE
 	 	  ,REC_TAX_AMT
 	 	  ,REC_TAX_AMT_FUNCL_CURR
 	 	  ,REC_TAX_AMT_TAX_CURR
 	 	  -- ,REF_DOC_LINE_QUANTITY
 	 	  -- ,RELATED_DOC_APPLICATION_ID
 	 	  -- ,RELATED_DOC_DATE
 	 	  -- ,RELATED_DOC_ENTITY_CODE
 	 	  -- ,RELATED_DOC_EVENT_CLASS_CODE
 	 	  -- ,RELATED_DOC_NUMBER
 	 	  -- ,RELATED_DOC_TRX_ID
 	 	  -- ,RELATED_DOC_TRX_LEVEL_TYPE
 	 	  -- ,REPORTING_CURRENCY_CODE
 	 	  ,TAX_AMT
 	 	  ,TAX_AMT_FUNCL_CURR
 	 	  ,TAX_AMT_TAX_CURR
 	 	  ,TAX_CALCULATION_FORMULA
 	 	  -- ,TAX_CODE
 	 	  ,TAX_DATE
 	 	  ,TAX_DETERMINE_DATE
 	 	  ,TAX_POINT_DATE
 	 	  -- ,TAX_TYPE_CODE
 	 	  -- ,ROUNDING_RULE_CODE
 	 	  ,TAXABLE_AMT
 	 	  ,TAXABLE_AMT_FUNCL_CURR
 	 	  ,TAXABLE_AMT_TAX_CURR
 	 	  ,TAXABLE_BASIS_FORMULA
 	 	  ,TRX_DATE
 	 	  ,TRX_LINE_DATE
 	 	  ,TRX_LINE_QUANTITY
 	 	  -- ,UNROUNDED_TAX_AMT
 	 	  -- ,UNROUNDED_TAXABLE_AMT
 	 	  ,HISTORICAL_FLAG
 	 	  ,OVERRIDDEN_FLAG
 	 	  ,SELF_ASSESSED_FLAG
 	 	  ,TAX_APPORTIONMENT_FLAG
 	 	  ,TAX_ONLY_LINE_FLAG
 	 	  ,TAX_AMT_INCLUDED_FLAG
 	 	  ,MRC_TAX_LINE_FLAG
 	 	  ,OFFSET_FLAG
 	 	  ,PROCESS_FOR_RECOVERY_FLAG
 	 	  ,COMPOUNDING_TAX_FLAG
 	 	  ,ORIG_TAX_AMT_INCLUDED_FLAG
 	 	  ,ORIG_SELF_ASSESSED_FLAG
 	 	  ,CANCEL_FLAG
 	 	  ,PURGE_FLAG
 	 	  ,DELETE_FLAG
 	 	  ,MANUALLY_ENTERED_FLAG
		  --,LAST_MANUAL_ENTRY  --BUG7146063
 	 	  ,REPORTING_ONLY_FLAG
 	 	  ,FREEZE_UNTIL_OVERRIDDEN_FLAG
 	 	  ,COPIED_FROM_OTHER_DOC_FLAG
 	 	  ,RECALC_REQUIRED_FLAG
 	 	  ,SETTLEMENT_FLAG
 	 	  ,ITEM_DIST_CHANGED_FLAG
 	 	  ,ASSOCIATED_CHILD_FROZEN_FLAG
 	 	  ,COMPOUNDING_DEP_TAX_FLAG
 	 	  ,ENFORCE_FROM_NATURAL_ACCT_FLAG
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
 	 	  ,LAST_MANUAL_ENTRY
		  ,LEGAL_ENTITY_ID
		  -- ,ESTABLISHMENT_ID
 	 	  ,CREATED_BY
 	 	  ,CREATION_DATE
 	 	  ,LAST_UPDATE_DATE
 	 	  ,LAST_UPDATE_LOGIN
 	 	  ,LAST_UPDATED_BY
		  ,OBJECT_VERSION_NUMBER
		  ,MULTIPLE_JURISDICTIONS_FLAG
		  ,LEGAL_REPORTING_STATUS
                 ,ACCOUNT_SOURCE_TAX_RATE_ID
 	 	  )
 	  VALUES (
 	 	  ZX_LINES_S.NEXTVAL
 	 	  ,TAX_LINE_NUMBER
 	 	  ,APPLICATION_ID
 	 	  ,CONTENT_OWNER_ID
 	 	  ,CURRENCY_CONVERSION_DATE
 	 	  ,CURRENCY_CONVERSION_RATE
 	 	  ,CURRENCY_CONVERSION_TYPE
 	 	  ,ENTITY_CODE
 	 	  ,EVENT_CLASS_CODE
 	 	  ,EVENT_TYPE_CODE
 	 	  ,AP_LEDGER_ID
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
 	 	  ,NULL
 	 	  ,ADJUSTED_DOC_APPLICATION_ID
 	 	  -- ,ADJUSTED_DOC_DATE
 	 	  ,ADJUSTED_DOC_ENTITY_CODE
 	 	  ,ADJUSTED_DOC_EVENT_CLASS_CODE
 	 	  ,ADJUSTED_DOC_LINE_ID
 	 	  -- ,ADJUSTED_DOC_NUMBER
 	 	  ,ADJUSTED_DOC_TRX_ID
 	 	  ,ADJUSTED_DOC_TRX_LEVEL_TYPE
 	 	  ,APPLIED_FROM_APPLICATION_ID
 	 	  ,APPLIED_FROM_ENTITY_CODE
 	 	  ,APPLIED_FROM_EVENT_CLASS_CODE
 	 	  ,APPLIED_FROM_LINE_ID
                  -- ,APPLIED_FROM_TRX_NUMBER
 	 	  ,APPLIED_FROM_TRX_ID
 	 	  ,APPLIED_FROM_TRX_LEVEL_TYPE
 	 	  ,APPLIED_TO_APPLICATION_ID
 	 	  ,APPLIED_TO_ENTITY_CODE
 	 	  ,APPLIED_TO_EVENT_CLASS_CODE
 	 	  ,APPLIED_TO_LINE_ID
 	 	  ,APPLIED_TO_TRX_ID
 	 	  ,APPLIED_TO_TRX_LEVEL_TYPE
 	 	  -- ,APPLIED_TO_TRX_NUMBER
 	 	  -- ,NULL                                            -- CAL_TAX_AMT
 	 	  -- ,NULL                                            -- CAL_TAX_AMT_FUNCL_CURR
 	 	  -- ,NULL                                            -- CAL_TAX_AMT_TAX_CURR
 	 	  -- ,DOC_EVENT_STATUS
 	 	  -- ,INTERNAL_ORG_LOCATION_ID
 	 	  ,INTERNAL_ORGANIZATION_ID
 	 	  ,LINE_AMT
 	 	  ,ASSESSABLE_VALUE
 	 	  -- ,NULL                                            -- MRC_LINK_TO_TAX_LINE_ID
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
	             'NONREC_TAX', REC_NREC_TAX_AMT, NULL)            -- NREC_TAX_AMT
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'NONREC_TAX', REC_NREC_TAX_AMT_FUNCL_CURR, NULL) -- NREC_TAX_AMT_FUNCL_CURR
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'NONREC_TAX', REC_NREC_TAX_AMT_TAX_CURR, NULL)   -- NREC_TAX_AMT_TAX_CURR
 	 	  -- ,NULL                                            -- OFFSET_LINK_TO_TAX_LINE_ID
 	 	  -- ,NULL                                            -- OFFSET_TAX_RATE_CODE
 	 	  -- ,NULL                                            -- ORIG_TAX_AMT
 	 	  -- ,NULL                                            -- ORIG_TAX_AMT_TAX_CURR
 	 	  -- ,NULL                                            -- ORIG_TAX_RATE
 	 	  -- ,NULL                                            -- ORIG_TAX_RATE_CODE
 	 	  -- ,NULL                                            -- ORIG_TAX_RATE_ID
 	 	  -- ,NULL                                            -- ORIG_TAX_STATUS_CODE
 	 	  -- ,NULL                                            -- ORIG_TAX_STATUS_ID
 	 	  -- ,NULL                                            -- ORIG_TAXABLE_AMT
 	 	  -- ,NULL                                            -- ORIG_TAXABLE_AMT_TAX_CURR
 	 	  -- ,NULL                                            -- OTHER_DOC_LINE_AMT
 	 	  -- ,NULL                                            -- OTHER_DOC_LINE_TAX_AMT
 	 	  -- ,NULL                                            -- OTHER_DOC_LINE_TAXABLE_AMT
 	 	  -- ,NULL                                            -- OTHER_DOC_SOURCE
 	 	  -- ,NULL                                            -- PRORATION_CODE
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'REC_TAX', REC_NREC_TAX_AMT, NULL)               -- REC_TAX_AMT
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'REC_TAX', REC_NREC_TAX_AMT_FUNCL_CURR, NULL)    -- REC_TAX_AMT_FUNCL_CURR
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'REC_TAX', REC_NREC_TAX_AMT_TAX_CURR, NULL)      -- REC_TAX_AMT_TAX_CURR
 	 	  -- ,REF_DOC_LINE_QUANTITY
 	 	  -- ,RELATED_DOC_APPLICATION_ID
 	 	  -- ,RELATED_DOC_DATE
 	 	  -- ,RELATED_DOC_ENTITY_CODE
 	 	  -- ,RELATED_DOC_EVENT_CLASS_CODE
 	 	  -- ,RELATED_DOC_NUMBER
 	 	  -- ,RELATED_DOC_TRX_ID
 	 	  -- ,RELATED_DOC_TRX_LEVEL_TYPE
 	 	  -- ,NULL                                            -- REPORTING_CURRENCY_CODE
                  ,TAX_AMT
 	 	  ,TAX_AMT_FUNCL_CURR
 	 	  ,TAX_AMT_TAX_CURR
 	 	  ,'STANDARD_TC'
 	 	  -- ,NULL                                            -- TAX_CODE
 	 	  ,TAX_DATE
 	 	  ,TAX_DETERMINE_DATE
 	 	  ,TAX_POINT_DATE
 	 	  -- ,NULL                                            -- TAX_TYPE_CODE
 	 	  -- ,ROUNDING_RULE_CODE
 	 	  ,TAXABLE_AMT
 	 	  ,TAXABLE_AMT_FUNCL_CURR
 	 	  ,TAXABLE_AMT_TAX_CURR
 	 	  ,'STANDARD_TB'                                      -- TAXABLE_BASIS_FORMULA
 	 	  ,TRX_DATE
 	 	  ,TRX_LINE_DATE
 	 	  ,TRX_LINE_QUANTITY
 	 	  -- ,NULL                                            -- UNROUNDED_TAX_AMT
 	 	  -- ,NULL                                            -- UNROUNDED_TAXABLE_AMT
 	 	  ,HISTORICAL_FLAG
 	 	  ,OVERRIDDEN_FLAG
 	 	  ,SELF_ASSESSED_FLAG
 	 	  ,TAX_APPORTIONMENT_FLAG
 	 	  ,TAX_ONLY_LINE_FLAG
 	 	  ,TAX_AMT_INCLUDED_FLAG
 	 	  ,'N'                                                -- MRC_TAX_LINE_FLAG
 	 	  ,OFFSET_FLAG                                        --Bug 8303411
 	 	  ,'N'                                                -- PROCESS_FOR_RECOVERY_FLAG
 	 	  ,COMPOUNDING_TAX_FLAG
 	 	  ,'N'                                                -- ORIG_TAX_AMT_INCLUDED_FLAG
 	 	  ,'N'                                                -- ORIG_SELF_ASSESSED_FLAG
 	 	  ,CANCEL_FLAG
 	 	  ,'N'                                                -- PURGE_FLAG
 	 	  ,'N'                                                -- DELETE_FLAG
 	 	  ,MANUALLY_ENTERED_FLAG  --BUG7146063
		  --,LAST_MANUAL_ENTRY  --BUG7146063
 	 	  ,'N'                                                -- REPORTING_ONLY_FLAG
 	 	  ,'N'                                                -- FREEZE_UNTIL_OVERRIDDEN_FLAG
 	 	  ,'N'                                                -- COPIED_FROM_OTHER_DOC_FLAG
 	 	  ,'N'                                                -- RECALC_REQUIRED_FLAG
 	 	  ,'N'                                                -- SETTLEMENT_FLAG
 	 	  ,'N'                                                -- ITEM_DIST_CHANGED_FLAG
 	 	  ,'N'                                                -- ASSOCIATED_CHILD_FROZEN_FLAG
 	 	  ,'N'                                                -- COMPOUNDING_DEP_TAX_FLAG
 	 	  ,'N'                                                -- ENFORCE_FROM_NATURAL_ACCT_FLAG
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
 	 	  ,LAST_MANUAL_ENTRY
		  ,LEGAL_ENTITY_ID
		  -- ,ESTABLISHMENT_ID
 	 	  ,CREATED_BY
 	 	  ,CREATION_DATE
 	 	  ,LAST_UPDATE_DATE
 	 	  ,LAST_UPDATE_LOGIN
 	  	  ,LAST_UPDATED_BY
 	  	  ,OBJECT_VERSION_NUMBER
		  ,MULTIPLE_JURISDICTIONS_FLAG
		  ,LEGAL_REPORTING_STATUS
                  ,ACCOUNT_SOURCE_TAX_RATE_ID
		 )
(SELECT /*+ ROWID(inv) NO_EXPAND ORDERED
            use_nl(fnd_curr,ap_dists,ap_dists1,lines1,rates,regimes,taxes,status,ptp)
            index(taxes,ZX_TAXES_B_U2) */
        NVL(lines1.org_id,-99)                                        INTERNAL_ORGANIZATION_ID
        ,200			   				      APPLICATION_ID
        ,'AP_INVOICES'		   				      ENTITY_CODE
        ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE   ,
                'STANDARD', 'STANDARD INVOICES'    ,
		'CREDIT'  , 'STANDARD INVOICES',   --Bug 6489409
	        'DEBIT'   , 'STANDARD INVOICES',   --Bug 6489409
		'MIXED'   , 'STANDARD INVOICES',   --Bug 6489409
		'ADJUSTMENT','STANDARD INVOICES',  --Bug 6489409
		'PO PRICE ADJUST','STANDARD INVOICES', --Bug 6489409
		'INVOICE REQUEST','STANDARD INVOICES', --Bug 6489409
		'CREDIT MEMO REQUEST','STANDARD INVOICES',--Bug 6489409
 		'RETAINAGE RELEASE'  ,'STANDARD INVOICES',--Bug 6489409
                'PREPAYMENT','PREPAYMENT INVOICES' ,
                'EXPENSE REPORT','EXPENSE REPORTS' ,
                'INTEREST INVOICE','INTEREST INVOICES','NA')	      EVENT_CLASS_CODE
        ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                'STANDARD','STANDARD INVOICE CREATED',
                'PREPAYMENT','PREPAYMENT INVOICE CREATED',
                'EXPENSE REPORT','EXPENSE REPORT CREATED',
                'INTEREST INVOICE','INTEREST INVOICE CREATED','NA')   EVENT_TYPE_CODE
        ,(CASE WHEN inv.invoice_type_lookup_code in
         	   ('ADJUSTMENT','CREDIT','DEBIT','INTEREST',
         		'MIXED','QUICKDEFAULT','PO PRICE ADJUST',
         		'QUICKMATCH','STANDARD','AWT')
         		  THEN 'PURCHASE_TRANSACTION'
         		  WHEN (inv.invoice_type_lookup_code =
         				'PREPAYMENT')
         		  THEN  'PURCHASE_PREPAYMENTTRANSACTION'
         		  WHEN  (inv.invoice_type_lookup_code =
         				'EXPENSE REPORT')
         		  THEN  'EXPENSE_REPORT'
         		  ELSE   NULL
          END)                      				      TAX_EVENT_CLASS_CODE
        ,'VALIDATE'                  				      TAX_EVENT_TYPE_CODE
        -- ,NULL					              DOC_EVENT_STATUS
        ,lines1.invoice_id 				              TRX_ID
        ,NVL(inv.invoice_date,sysdate)			   	      TRX_DATE
        ,inv.invoice_currency_code                    	              TRX_CURRENCY_CODE
        ,NVL(inv.legal_entity_id, -99)               	              LEGAL_ENTITY_ID
        -- ,NULL						      ESTABLISHMENT_ID
        ,inv.invoice_num                              	              TRX_NUMBER
        -- ,DECODE(ap_dists.charge_applicable_to_dist_id,NULL,1,
        ,(RANK() OVER (PARTITION BY inv.invoice_id ORDER BY
                     ap_dists1.invoice_line_number,
                     ap_dists.invoice_distribution_id))	              TAX_LINE_NUMBER
        ,lines1.accounting_date                        	              TRX_LINE_DATE
        ,NVL(lines1.amount,0)                                 	      LINE_AMT
        ,NVL(lines1.quantity_invoiced, 0)                     	      TRX_LINE_QUANTITY
        ,lines1.UNIT_PRICE                             	              UNIT_PRICE
        -- ,NULL                                         	      RELATED_DOC_APPLICATION_ID
        -- ,NULL                                         	      RELATED_DOC_ENTITY_CODE
        -- ,NULL                                         	      RELATED_DOC_EVENT_CLASS_CODE
        -- ,NULL                                         	      RELATED_DOC_TRX_ID
        -- ,NULL                                                      RELATED_DOC_TRX_LEVEL_TYPE
        -- ,NULL                                         	      RELATED_DOC_NUMBER
        -- ,NULL                                         	      RELATED_DOC_DATE
        ,DECODE(lines1.prepay_invoice_id, NULL, NULL, 200)            APPLIED_FROM_APPLICATION_ID
        ,DECODE(lines1.prepay_invoice_id, NULL, NULL,
                'AP_INVOICES')                                        APPLIED_FROM_ENTITY_CODE
        ,DECODE(lines1.prepay_invoice_id, NULL, NULL,
                'PREPAYMENT INVOICES')                                APPLIED_FROM_EVENT_CLASS_CODE
        ,lines1.prepay_invoice_id                      	              APPLIED_FROM_TRX_ID
        ,lines1.prepay_line_number                    	              APPLIED_FROM_LINE_ID
        -- ,NULL						      APPLIED_FROM_TRX_NUMBER
        ,DECODE(lines1.corrected_inv_id, NULL, NULL, 200)             ADJUSTED_DOC_APPLICATION_ID
        ,DECODE(lines1.corrected_inv_id, NULL, NULL,
                'AP_INVOICES')                                        ADJUSTED_DOC_ENTITY_CODE
        ,DECODE(lines1.corrected_inv_id, NULL, NULL,
                'STANDARD INVOICES')                                  ADJUSTED_DOC_EVENT_CLASS_CODE
        ,lines1.corrected_inv_id                       	              ADJUSTED_DOC_TRX_ID
        ,lines1.Corrected_Line_Number                  	              ADJUSTED_DOC_LINE_ID
        -- ,NULL                                         	      ADJUSTED_DOC_NUMBER
        -- ,NULL                                         	      ADJUSTED_DOC_DATE
        ,DECODE(lines1.rcv_transaction_id, NULL, NULL, 707) 	      APPLIED_TO_APPLICATION_ID
        ,DECODE(lines1.rcv_transaction_id, NULL, NULL,
                'RCV_ACCOUNTING_EVENTS')                              APPLIED_TO_ENTITY_CODE
        ,DECODE(lines1.rcv_transaction_id, NULL, NULL,
                'RCPT_REC_INSP')                      	              APPLIED_TO_EVENT_CLASS_CODE
        ,lines1.rcv_transaction_id                           	      APPLIED_TO_TRX_ID
        ,lines1.rcv_shipment_line_id                         	      APPLIED_TO_LINE_ID
        -- ,NULL                                         	      APPLIED_TO_TRX_NUMBER
        ,DECODE(NVL(lines1.po_release_id,lines1.po_header_id),
                 NULL, NULL, 'SHIPMENT')                     	      REF_DOC_TRX_LEVEL_TYPE
        ,NVL(lines1.po_release_id, lines1.po_header_id)  	      REF_DOC_TRX_ID
        ,lines1.po_line_location_id                    	              REF_DOC_LINE_ID
        -- ,NULL                                         	      REF_DOC_LINE_QUANTITY
        ,DECODE(lines1.rcv_transaction_id, NULL, NULL,
                'LINE')                                     	      APPLIED_TO_TRX_LEVEL_TYPE
        ,DECODE(lines1.prepay_invoice_id, NULL, NULL,
                'LINE')                                     	      APPLIED_FROM_TRX_LEVEL_TYPE
        ,DECODE(lines1.corrected_inv_id, NULL, NULL,
                'LINE')                                	              ADJUSTED_DOC_TRX_LEVEL_TYPE
        -- ,NULL 						      INTERNAL_ORG_LOCATION_ID
        ,'MIGRATED' 					              RECORD_TYPE_CODE
        ,lines1.ASSESSABLE_VALUE                       	              -- ASSESSABLE_VALUE
        ,'N'                                          	              TAX_AMT_INCLUDED_FLAG
        ,'N'                                          	              COMPOUNDING_TAX_FLAG
        ,DECODE(taxes.tax_type_code,'OFFSET','Y','N')                 OFFSET_FLAG --Bug 8303411
        ,ap_dists.DETAIL_TAX_DIST_ID   			              REC_NREC_TAX_DIST_ID
        ,ap_dists.line_type_lookup_code                	              AP_DIST_LOOKUP_CODE
         -- DECODE(ap_dists.charge_applicable_to_dist_id, NULL, 1,
        ,RANK() OVER (PARTITION BY inv.invoice_id,
                      ap_dists.charge_applicable_to_dist_id
                      ORDER BY
                      ap_dists.line_type_lookup_code desc,
                      ap_dists.invoice_distribution_id)               REC_NREC_TAX_DIST_NUMBER
        ,ptp.party_tax_profile_id                                     CONTENT_OWNER_ID
        ,inv.exchange_date 				            CURRENCY_CONVERSION_DATE
        ,inv.exchange_rate     				        CURRENCY_CONVERSION_RATE
        ,inv.exchange_rate_type  				      CURRENCY_CONVERSION_TYPE
        ,ap_dists.set_of_books_id 				      AP_LEDGER_ID
        ,fnd_curr.minimum_accountable_unit   			      MINIMUM_ACCOUNTABLE_UNIT
        ,NVL(fnd_curr.precision, 0)                  		      PRECISION
        ,DECODE(NVL(lines1.po_release_id, lines1.po_header_id),
                 NULL, NULL, 201)		                      REF_DOC_APPLICATION_ID
        ,DECODE(lines1.po_release_id, NULL,
                 DECODE(lines1.po_header_id, NULL, NULL,
                        'PURCHASE_ORDER'), 'RELEASE')                 REF_DOC_ENTITY_CODE
        ,DECODE(lines1.po_release_id, NULL,
                 DECODE(lines1.po_header_id, NULL, NULL,
                        'PO_PA'), 'RELEASE')                          REF_DOC_EVENT_CLASS_CODE
        ,ap_dists.summary_tax_line_id 				      SUMMARY_TAX_LINE_ID
        ,rates.TAX 						      TAX
        -- ,DECODE(ap_dists.charge_applicable_to_dist_id,NULL,1,
        ,RANK() OVER (PARTITION BY inv.invoice_id,
                       ap_dists1.invoice_line_number,
                       rates.tax_regime_code, rates.tax
                       ORDER BY
                       ap_dists.invoice_distribution_id)	      TAX_APPORTIONMENT_LINE_NUMBER
        ,taxes.tax_currency_code                                      -- TAX_CURRENCY_CODE
        ,inv.exchange_date             			      TAX_CURRENCY_CONVERSION_DATE
        ,inv.exchange_rate             			      TAX_CURRENCY_CONVERSION_RATE
        ,inv.exchange_rate_type        			      TAX_CURRENCY_CONVERSION_TYPE
        ,taxes.tax_id                                                 -- TAX_ID
        ,rates.percentage_rate 				              TAX_RATE
        ,rates.tax_rate_code 					      -- TAX_RATE_CODE
        ,rates.tax_rate_id 				              -- TAX_RATE_ID
        ,rates.tax_regime_code 				              -- TAX_REGIME_CODE
        ,regimes.tax_regime_id				              -- TAX_REGIME_ID
        ,rates.tax_status_code 				              -- TAX_STATUS_CODE
        ,status.tax_status_id					      -- TAX_STATUS_ID
        ,'LINE'						              TRX_LEVEL_TYPE
        ,lines1.line_number                                           TRX_LINE_ID
        ,lines1.line_number                                           TRX_LINE_NUMBER
        ,ap_dists.dist_code_combination_id  			      ACCOUNT_CCID
        -- ,NULL 						      ACCOUNT_STRING
        -- ,NULL 						      ADJUSTED_DOC_TAX_DIST_ID
        -- ,NULL 						      APPLIED_FROM_TAX_DIST_ID
        -- ,NULL 						      APPLIED_TO_DOC_CURR_CONV_RATE
        ,ap_dists.award_id  					      -- AWARD_ID
        ,ap_dists.expenditure_item_date  			      -- EXPENDITURE_ITEM_DATE
        ,ap_dists.expenditure_organization_id  		              -- EXPENDITURE_ORGANIZATION_ID
        ,ap_dists.expenditure_type          			      -- EXPENDITURE_TYPE
        ,NULL 						              FUNC_CURR_ROUNDING_ADJUSTMENT
        ,ap_dists.ACCOUNTING_DATE 				      GL_DATE
        ,ap_dists.intended_use 				              -- INTENDED_USE
        ,ap_dists1.distribution_line_number                           ITEM_DIST_NUMBER
        -- ,NULL 						      MRC_LINK_TO_TAX_DIST_ID
        -- ,NULL 						      ORIG_REC_NREC_RATE
        -- ,NULL 						      ORIG_REC_NREC_TAX_AMT
        -- ,NULL 						      ORIG_REC_NREC_TAX_AMT_TAX_CURR
        -- ,NULL 						      ORIG_REC_RATE_CODE
        -- ,NULL 						      PER_TRX_CURR_UNIT_NR_AMT
        -- ,NULL 						      PER_UNIT_NREC_TAX_AMT
        -- ,NULL 						      PRD_TAX_AMT
        -- ,NULL 						      PRICE_DIFF
        ,ap_dists.project_id  				              -- PROJECT_ID
        -- ,NULL 						      QTY_DIFF
        -- ,NULL 						      RATE_TAX_FACTOR
        --,NVL(ap_dists.rec_nrec_rate, 0)                             REC_NREC_RATE
        ,100                                                          REC_NREC_RATE
        ,NVL(ap_dists.amount,0)             			      REC_NREC_TAX_AMT
        ,ap_dists.base_amount        				      REC_NREC_TAX_AMT_FUNCL_CURR
        ,ap_dists.base_amount        				      REC_NREC_TAX_AMT_TAX_CURR
        ,DECODE(ap_dists.line_type_lookup_code,
               'REC_TAX', 'AD_HOC_RECOVERY', NULL)                    RECOVERY_RATE_CODE
        ,DECODE(ap_dists.line_type_lookup_code,
               'REC_TAX', 'STANDARD', NULL)                           RECOVERY_TYPE_CODE
        ,NVL(ap_dists.amount,0)             			      TAX_AMT
        ,ap_dists.base_amount        				      TAX_AMT_FUNCL_CURR
        ,ap_dists.base_amount        				      TAX_AMT_TAX_CURR
        -- ,NULL 						      RECOVERY_TYPE_ID
        -- ,NULL 						      REF_DOC_CURR_CONV_RATE
        ,ap_dists1.po_distribution_id                                 REF_DOC_DIST_ID
        -- ,NULL 						      REF_DOC_PER_UNIT_NREC_TAX_AMT
        -- ,NULL 						      REF_DOC_TAX_DIST_ID
        -- ,NULL 						      REF_DOC_TRX_LINE_DIST_QTY
        -- ,NULL 						      REF_DOC_UNIT_PRICE
        -- ,NULL 						      REF_PER_TRX_CURR_UNIT_NR_AMT
        ,ap_dists.parent_reversal_id				      REVERSED_TAX_DIST_ID
        -- ,NULL 						      ROUNDING_RULE_CODE
        ,ap_dists.task_id  					      -- TASK_ID
        ,ap_dists.taxable_base_amount 			              TAXABLE_AMT_FUNCL_CURR
        ,ap_dists.taxable_base_amount 			              TAXABLE_AMT_TAX_CURR
        ,ap_dists1.amount					      TRX_LINE_DIST_AMT
        ,ap_dists1.invoice_distribution_id 			      TRX_LINE_DIST_ID
        ,NVL(ap_dists1.quantity_invoiced, 0)			      TRX_LINE_DIST_QTY
        ,DECODE(ap_dists.charge_applicable_to_dist_id, NULL,
                ap_dists.amount,
                SUM (ap_dists.amount) OVER
                    (PARTITION BY ap_dists.invoice_id,
                     ap_dists.charge_applicable_to_dist_id))	      TRX_LINE_DIST_TAX_AMT
        -- ,NULL 						      UNROUNDED_REC_NREC_TAX_AMT
        -- ,NULL 						      UNROUNDED_TAXABLE_AMT
        ,ap_dists.TAXABLE_AMOUNT 				      TAXABLE_AMT
        ,ap_dists.ATTRIBUTE_CATEGORY  			              -- ATTRIBUTE_CATEGORY
        ,ap_dists.ATTRIBUTE1       				      -- ATTRIBUTE1
        ,ap_dists.ATTRIBUTE2       				      -- ATTRIBUTE2
        ,ap_dists.ATTRIBUTE3       				      -- ATTRIBUTE3
        ,ap_dists.ATTRIBUTE4       				      -- ATTRIBUTE4
        ,ap_dists.ATTRIBUTE5       				      -- ATTRIBUTE5
        ,ap_dists.ATTRIBUTE6       				      -- ATTRIBUTE6
        ,ap_dists.ATTRIBUTE7       				      -- ATTRIBUTE7
        ,ap_dists.ATTRIBUTE8       				      -- ATTRIBUTE8
        ,ap_dists.ATTRIBUTE9       				      -- ATTRIBUTE9
        ,ap_dists.ATTRIBUTE10      				      -- ATTRIBUTE10
        ,ap_dists.ATTRIBUTE11      				      -- ATTRIBUTE11
        ,ap_dists.ATTRIBUTE12      				      -- ATTRIBUTE12
        ,ap_dists.ATTRIBUTE13      				      -- ATTRIBUTE13
        ,ap_dists.ATTRIBUTE14      				      -- ATTRIBUTE14
        ,ap_dists.ATTRIBUTE15      				      -- ATTRIBUTE15
        ,ap_dists.GLOBAL_ATTRIBUTE_CATEGORY 			      -- GLOBAL_ATTRIBUTE_CATEGORY
        ,ap_dists.GLOBAL_ATTRIBUTE1         			      -- GLOBAL_ATTRIBUTE1
        ,ap_dists.GLOBAL_ATTRIBUTE2         			      -- GLOBAL_ATTRIBUTE2
        ,ap_dists.GLOBAL_ATTRIBUTE3         			      -- GLOBAL_ATTRIBUTE3
        ,ap_dists.GLOBAL_ATTRIBUTE4         			      -- GLOBAL_ATTRIBUTE4
        ,ap_dists.GLOBAL_ATTRIBUTE5         			      -- GLOBAL_ATTRIBUTE5
        ,ap_dists.GLOBAL_ATTRIBUTE6         			      -- GLOBAL_ATTRIBUTE6
        ,ap_dists.GLOBAL_ATTRIBUTE7         			      -- GLOBAL_ATTRIBUTE7
        ,ap_dists.GLOBAL_ATTRIBUTE8         			      -- GLOBAL_ATTRIBUTE8
        ,ap_dists.GLOBAL_ATTRIBUTE9         			      -- GLOBAL_ATTRIBUTE9
        ,ap_dists.GLOBAL_ATTRIBUTE10        			      -- GLOBAL_ATTRIBUTE10
        ,ap_dists.GLOBAL_ATTRIBUTE11        			      -- GLOBAL_ATTRIBUTE11
        ,ap_dists.GLOBAL_ATTRIBUTE12        			      -- GLOBAL_ATTRIBUTE12
        ,ap_dists.GLOBAL_ATTRIBUTE13        			      -- GLOBAL_ATTRIBUTE13
        ,ap_dists.GLOBAL_ATTRIBUTE14        			      -- GLOBAL_ATTRIBUTE14
        ,ap_dists.GLOBAL_ATTRIBUTE15        			      -- GLOBAL_ATTRIBUTE15
        ,ap_dists.GLOBAL_ATTRIBUTE16        			      -- GLOBAL_ATTRIBUTE16
        ,ap_dists.GLOBAL_ATTRIBUTE17        			      -- GLOBAL_ATTRIBUTE17
        ,ap_dists.GLOBAL_ATTRIBUTE18        			      -- GLOBAL_ATTRIBUTE18
        ,ap_dists.GLOBAL_ATTRIBUTE19        			      -- GLOBAL_ATTRIBUTE19
        ,ap_dists.GLOBAL_ATTRIBUTE20        			      -- GLOBAL_ATTRIBUTE20
        ,'Y'                                			      HISTORICAL_FLAG
        ,'N'                                			      OVERRIDDEN_FLAG
        ,'N'                                			      SELF_ASSESSED_FLAG
        ,'Y'                                			      TAX_APPORTIONMENT_FLAG
        ,DECODE(ap_dists.charge_applicable_to_dist_id,
                 NULL, 'Y', 'N')				      TAX_ONLY_LINE_FLAG
        ,'N'                                			      INCLUSIVE_FLAG
        ,'N'                                			      MRC_TAX_DIST_FLAG
        ,'N'                                			      REC_TYPE_RULE_FLAG
        ,'N'                                			      NEW_REC_RATE_CODE_FLAG
        ,NVL(ap_dists.tax_recoverable_flag, 'N')      		      RECOVERABLE_FLAG
        ,ap_dists.reversal_flag				              REVERSE_FLAG
        ,'N'                                			      REC_RATE_DET_RULE_FLAG
        ,'N'                                			      BACKWARD_COMPATIBILITY_FLAG
        ,'N'                                			      FREEZE_FLAG
        ,DECODE(ap_dists.posted_flag, 'Y', 'A', NULL)  	              POSTING_FLAG
        ,NVL(lines1.accounting_date,
              NVL(inv.invoice_date, sysdate))                         TAX_DATE
        ,NVL(lines1.accounting_date,
              NVL(inv.invoice_date, sysdate))                         TAX_DETERMINE_DATE
        ,NVL(lines1.accounting_date,
              NVL(inv.invoice_date, sysdate))                         TAX_POINT_DATE
        ,1                					      CREATED_BY
        ,SYSDATE                            			      CREATION_DATE
        --,NULL                               			      LAST_MANUAL_ENTRY
        ,SYSDATE                            			      LAST_UPDATE_DATE
        ,1           						      LAST_UPDATE_LOGIN
        ,1                					      LAST_UPDATED_BY
        ,1							      OBJECT_VERSION_NUMBER
        ,ap_dists1.old_dist_line_number                               ORIG_AP_CHRG_DIST_NUM
        ,ap_dists1.old_distribution_id                                ORIG_AP_CHRG_DIST_ID
        ,ap_dists.old_dist_line_number                                ORIG_AP_TAX_DIST_NUM
        ,ap_dists.old_distribution_id                                 ORIG_AP_TAX_DIST_ID
        ,'N'                                  		              MULTIPLE_JURISDICTIONS_FLAG
        ,DECODE(ap_dists.posted_flag, 'Y', '111111111111111',
                                      'P', '111111111111111',
                                           '000000000000000')         LEGAL_REPORTING_STATUS
        ,DECODE(lines.discarded_flag, 'Y', 'Y', 'N')                 CANCEL_FLAG
        ,NVL(rates.def_rec_settlement_option_code,
             taxes.def_rec_settlement_option_code)                    DEF_REC_SETTLEMENT_OPTION_CODE
        --,TAX_JURISDICTION_ID
        ,rates.tax_rate_id                                            ACCOUNT_SOURCE_TAX_RATE_ID
	,(SELECT tax_rate_id FROM zx_rates_b
          WHERE tax_rate_code = 'AD_HOC_RECOVERY'
          AND rate_type_code = 'RECOVERY'
          AND tax_regime_code = rates.tax_regime_code
          AND tax = rates.tax
          AND content_owner_id = ptp.party_tax_profile_id
	  AND record_type_code = 'MIGRATED'
	  AND tax_class = 'INPUT')                          RECOVERY_RATE_ID
	 ,DECODE(lines.line_source,'MANUAL LINE ENTRY','Y','N')   MANUALLY_ENTERED_FLAG   --BUG7146063
         ,DECODE(lines.line_source,'MANUAL LINE ENTRY','TAX_AMOUNT',NULL)   LAST_MANUAL_ENTRY   --BUG7146063
   FROM ap_invoices_all inv,
        fnd_currencies fnd_curr,
        -- fnd_document_sequences fds,
        ap_invoice_distributions_all ap_dists,
        ap_invoice_distributions_all ap_dists1,
        ap_invoice_lines_all lines1,
        ap_invoice_lines_all lines,
        zx_rates_b rates,
        zx_regimes_b regimes,
        zx_taxes_b taxes,
        zx_status_b status,
        zx_party_tax_profile ptp
  WHERE inv.invoice_id = p_upg_trx_info_rec.trx_id
    AND fnd_curr.currency_code = inv.invoice_currency_code
    --  AND inv.doc_sequence_id = fds.doc_sequence_id(+)
    AND ap_dists.invoice_id = inv.invoice_id
    AND ap_dists.line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
    AND NVL(ap_dists.historical_flag, 'N') = 'Y'
    --  AND ap_dists1.invoice_id = ap_dists.invoice_id
    AND ap_dists1.invoice_distribution_id = NVL(ap_dists.charge_applicable_to_dist_id,
                                                ap_dists.invoice_distribution_id)
    AND lines1.invoice_id = ap_dists1.invoice_id
    AND lines1.line_number = ap_dists1.invoice_line_number
    AND NVL(lines1.historical_flag, 'N') = 'Y'
    AND lines.invoice_id = ap_dists.invoice_id
    AND lines.line_number = ap_dists.invoice_line_number
    AND NVL(lines.historical_flag, 'N') = 'Y'
    AND rates.source_id(+) = ap_dists.tax_code_id
    AND regimes.tax_regime_code(+) = rates.tax_regime_code
    AND taxes.tax_regime_code(+) = rates.tax_regime_code
    AND taxes.tax(+) = rates.tax
    AND taxes.content_owner_id(+) = rates.content_owner_id
    AND status.tax_regime_code(+) = rates.tax_regime_code
    AND status.tax(+) = rates.tax
    AND status.tax_status_code(+) = rates.tax_status_code
    AND status.content_owner_id(+) = rates.content_owner_id
    -- AND NVL(taxes.effective_from,
    --         NVL(lines1.accounting_date, NVL(inv.invoice_date, sysdate)))
    --       <= NVL(lines1.accounting_date, NVL(inv.invoice_date, sysdate))
    -- AND (NVL(taxes.effective_to,
    --         NVL(lines1.accounting_date,
    --             NVL(inv.invoice_date, sysdate)) )
    --        >= NVL(lines1.accounting_date, NVL(inv.invoice_date, sysdate))
    --      OR taxes.effective_to IS NULL)
    AND ptp.party_type_code = 'OU'
    AND ptp.party_id = DECODE(l_multi_org_flag,'N', l_org_id, ap_dists.org_id)
    AND NOT EXISTS -- Bug 6738188
        (SELECT 1 FROM zx_lines zxl
                 WHERE zxl.application_id   = 200
                  AND zxl.event_class_code = DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                                              'STANDARD', 'STANDARD INVOICES',
                                              'CREDIT'  , 'STANDARD INVOICES',
                                              'DEBIT'   , 'STANDARD INVOICES',
                                              'MIXED'   , 'STANDARD INVOICES',
                                              'ADJUSTMENT','STANDARD INVOICES',
                                              'PO PRICE ADJUST','STANDARD INVOICES',
                                              'INVOICE REQUEST','STANDARD INVOICES',
                                              'CREDIT MEMO REQUEST','STANDARD INVOICES',
                                              'RETAINAGE RELEASE'  ,'STANDARD INVOICES',
                                              'PREPAYMENT', 'PREPAYMENT INVOICES',
                                              'EXPENSE REPORT', 'EXPENSE REPORTS',
                                              'INTEREST INVOICE', 'INTEREST INVOICES','NA')
                   AND zxl.trx_id           = inv.invoice_id
                   AND zxl.entity_code      = 'AP_INVOICES'
		   AND zxl.trx_line_id = lines1.line_number)
    );


  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap.END',
                   'ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap(+)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap.END',
                    'ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_ap(-)');
    END IF;

END upgrade_trx_on_fly_ap;

-------------------------------------------------------------------------------
-- PUBLIC PROCEDURE
-- upgrade_trx_on_fly_blk_ap
--
-- DESCRIPTION
-- handle bulk on the fly migration for AP, called from validate and default API
--
-------------------------------------------------------------------------------
PROCEDURE upgrade_trx_on_fly_blk_ap(
  x_return_status        OUT NOCOPY  VARCHAR2
) AS

  l_multi_org_flag            fnd_product_groups.multi_org_flag%TYPE;
  l_org_id                    NUMBER;

BEGIN
  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap.BEGIN',
                   'ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap(+)');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SELECT multi_org_flag INTO l_multi_org_flag FROM fnd_product_groups;

  -- for single org environment, get value of org_id from profile
  IF l_multi_org_flag = 'N' THEN
    FND_PROFILE.GET('ORG_ID',l_org_id);
    IF l_org_id is NULL THEN
      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ar',
                   'Current envionment is a Single Org environment,'||
                   ' but peofile ORG_ID is not set up');
      END IF;

    END IF;
  END IF;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap',
                   'Inserting data into zx_lines_det_factors and zx_lines_summary');
  END IF;

  -- Insert data into zx_lines_det_factors and zx_lines_summary
  --
  INSERT ALL
    WHEN AP_LINE_LOOKUP_CODE IN ('ITEM', 'PREPAY','FREIGHT','MISCELLANEOUS') OR
         TAX_ONLY_LINE_FLAG = 'Y'
    THEN
      INTO ZX_LINES_DET_FACTORS (
		EVENT_ID
		,OBJECT_VERSION_NUMBER
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,EVENT_TYPE_CODE
		,TAX_EVENT_CLASS_CODE
		,TAX_EVENT_TYPE_CODE
		-- ,DOC_EVENT_STATUS
		,LINE_LEVEL_ACTION
		,LINE_CLASS
		-- ,APPLICATION_DOC_STATUS
		,TRX_ID
		,TRX_LINE_ID
		,TRX_LEVEL_TYPE
		,TRX_DATE
		,LEDGER_ID
		,TRX_CURRENCY_CODE
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_RATE
		,CURRENCY_CONVERSION_TYPE
		,MINIMUM_ACCOUNTABLE_UNIT
		,PRECISION
		,LEGAL_ENTITY_ID
		-- ,ESTABLISHMENT_ID
		,DEFAULT_TAXATION_COUNTRY
		,TRX_NUMBER
		,TRX_LINE_NUMBER
		,TRX_LINE_DESCRIPTION
		,TRX_DESCRIPTION
		,TRX_COMMUNICATED_DATE
		,TRX_LINE_GL_DATE
		,BATCH_SOURCE_ID
		-- ,BATCH_SOURCE_NAME
		,DOC_SEQ_ID
		,DOC_SEQ_NAME
		,DOC_SEQ_VALUE
		,TRX_DUE_DATE
		-- ,TRX_TYPE_DESCRIPTION
		,TRX_LINE_TYPE
		,TRX_LINE_DATE
		-- ,TRX_SHIPPING_DATE
		-- ,TRX_RECEIPT_DATE
		,LINE_AMT
		,TRX_LINE_QUANTITY
		,UNIT_PRICE
		,PRODUCT_ID
		-- ,PRODUCT_ORG_ID
		,UOM_CODE
		,PRODUCT_TYPE
		-- ,PRODUCT_CODE
		,PRODUCT_DESCRIPTION
		,FIRST_PTY_ORG_ID
		-- ,ASSET_NUMBER
		-- ,ASSET_ACCUM_DEPRECIATION
		-- ,ASSET_TYPE
		-- ,ASSET_COST
		,ACCOUNT_CCID
		-- ,ACCOUNT_STRING
		-- ,RELATED_DOC_APPLICATION_ID
		-- ,RELATED_DOC_ENTITY_CODE
		-- ,RELATED_DOC_EVENT_CLASS_CODE
		-- ,RELATED_DOC_TRX_ID
		-- ,RELATED_DOC_NUMBER
		-- ,RELATED_DOC_DATE
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_TRX_ID
		,APPLIED_FROM_LINE_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,ADJUSTED_DOC_LINE_ID
		-- ,ADJUSTED_DOC_NUMBER
		-- ,ADJUSTED_DOC_DATE
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID
		-- ,APPLIED_TO_TRX_NUMBER
		,REF_DOC_TRX_LEVEL_TYPE
		,REF_DOC_APPLICATION_ID
		,REF_DOC_ENTITY_CODE
		,REF_DOC_EVENT_CLASS_CODE
		,REF_DOC_TRX_ID
		,REF_DOC_LINE_ID
		-- ,REF_DOC_LINE_QUANTITY
		,APPLIED_TO_TRX_LEVEL_TYPE
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,MERCHANT_PARTY_NAME
		,MERCHANT_PARTY_DOCUMENT_NUMBER
		,MERCHANT_PARTY_REFERENCE
		,MERCHANT_PARTY_TAXPAYER_ID
		,MERCHANT_PARTY_TAX_REG_NUMBER
		-- ,MERCHANT_PARTY_ID
		,MERCHANT_PARTY_COUNTRY
		,START_EXPENSE_DATE
		,SHIP_TO_LOCATION_ID
		-- ,SHIP_FROM_LOCATION_ID
		-- ,BILL_TO_LOCATION_ID
		-- ,BILL_FROM_LOCATION_ID
		-- ,SHIP_TO_PARTY_TAX_PROF_ID
		-- ,SHIP_FROM_PARTY_TAX_PROF_ID
		-- ,BILL_TO_PARTY_TAX_PROF_ID
		-- ,BILL_FROM_PARTY_TAX_PROF_ID
		-- ,SHIP_TO_SITE_TAX_PROF_ID
		-- ,SHIP_FROM_SITE_TAX_PROF_ID
		-- ,BILL_TO_SITE_TAX_PROF_ID
		-- ,BILL_FROM_SITE_TAX_PROF_ID
		-- ,MERCHANT_PARTY_TAX_PROF_ID
		-- ,HQ_ESTB_PARTY_TAX_PROF_ID
		-- ,CTRL_TOTAL_LINE_TX_AMT
		-- ,CTRL_TOTAL_HDR_TX_AMT
		-- ,INPUT_TAX_CLASSIFICATION_CODE
		-- ,OUTPUT_TAX_CLASSIFICATION_CODE
		-- ,INTERNAL_ORG_LOCATION_ID
		,RECORD_TYPE_CODE
		,PRODUCT_FISC_CLASSIFICATION
		,PRODUCT_CATEGORY
		,USER_DEFINED_FISC_CLASS
		,ASSESSABLE_VALUE
		,TRX_BUSINESS_CATEGORY
		,SUPPLIER_TAX_INVOICE_NUMBER
		,SUPPLIER_TAX_INVOICE_DATE
		,SUPPLIER_EXCHANGE_RATE
		,TAX_INVOICE_DATE
		,TAX_INVOICE_NUMBER
		,DOCUMENT_SUB_TYPE
		,LINE_INTENDED_USE
		,PORT_OF_ENTRY_CODE
		-- ,SOURCE_APPLICATION_ID
		-- ,SOURCE_ENTITY_CODE
		-- ,SOURCE_EVENT_CLASS_CODE
		-- ,SOURCE_TRX_ID
		-- ,SOURCE_LINE_ID
		-- ,SOURCE_TRX_LEVEL_TYPE
		,HISTORICAL_FLAG
		,LINE_AMT_INCLUDES_TAX_FLAG
		,CTRL_HDR_TX_APPL_FLAG
		,TAX_REPORTING_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,INCLUSIVE_TAX_OVERRIDE_FLAG
		,THRESHOLD_INDICATOR_FLAG
		,USER_UPD_DET_FACTORS_FLAG
		,TAX_PROCESSING_COMPLETED_FLAG
		,ASSET_FLAG
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
	        ,LAST_UPDATE_LOGIN
	        ,EVENT_CLASS_MAPPING_ID
	        ,SHIP_THIRD_PTY_ACCT_ID
	        ,SHIP_THIRD_PTY_ACCT_SITE_ID
		,GLOBAL_ATTRIBUTE_CATEGORY
		,GLOBAL_ATTRIBUTE1
                -- ,ICX_SESSION_ID
                -- ,TRX_LINE_CURRENCY_CODE
                -- ,TRX_LINE_CURRENCY_CONV_RATE
                -- ,TRX_LINE_CURRENCY_CONV_DATE
                -- ,TRX_LINE_PRECISION
                -- ,TRX_LINE_MAU
                -- ,TRX_LINE_CURRENCY_CONV_TYPE
                -- ,INTERFACE_ENTITY_CODE
                -- ,INTERFACE_LINE_ID
                -- ,SOURCE_TAX_LINE_ID
	        ,BILL_THIRD_PTY_ACCT_ID
	        ,BILL_THIRD_PTY_ACCT_SITE_ID
	        )
        VALUES(
       		EVENT_ID
		,OBJECT_VERSION_NUMBER
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,EVENT_TYPE_CODE
		,TAX_EVENT_CLASS_CODE
		,TAX_EVENT_TYPE_CODE
		-- ,DOC_EVENT_STATUS
		,LINE_LEVEL_ACTION
		,LINE_CLASS
		-- ,APPLICATION_DOC_STATUS
		,TRX_ID
		,TRX_LINE_ID
		,TRX_LEVEL_TYPE
		,TRX_DATE
		,LEDGER_ID
		,TRX_CURRENCY_CODE
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_RATE
		,CURRENCY_CONVERSION_TYPE
		,MINIMUM_ACCOUNTABLE_UNIT
		,PRECISION
		,LEGAL_ENTITY_ID
		-- ,ESTABLISHMENT_ID
		,DEFAULT_TAXATION_COUNTRY
		,TRX_NUMBER
		,TRX_LINE_NUMBER
		,TRX_LINE_DESCRIPTION
		,TRX_DESCRIPTION
		,TRX_COMMUNICATED_DATE
		,TRX_LINE_GL_DATE
		,BATCH_SOURCE_ID
		-- ,BATCH_SOURCE_NAME
		,DOC_SEQ_ID
		,DOC_SEQ_NAME
		,DOC_SEQ_VALUE
		,TRX_DUE_DATE
		-- ,TRX_TYPE_DESCRIPTION
		,TRX_LINE_TYPE
		,TRX_LINE_DATE
		-- ,TRX_SHIPPING_DATE
		-- ,TRX_RECEIPT_DATE
		,LINE_AMT
		,TRX_LINE_QUANTITY
		,UNIT_PRICE
		,PRODUCT_ID
		-- ,PRODUCT_ORG_ID
		,UOM_CODE
		,PRODUCT_TYPE
		-- ,PRODUCT_CODE
		,PRODUCT_DESCRIPTION
		,FIRST_PTY_ORG_ID
		-- ,ASSET_NUMBER
		-- ,ASSET_ACCUM_DEPRECIATION
		-- ,ASSET_TYPE
		-- ,ASSET_COST
		,ACCOUNT_CCID
		-- ,ACCOUNT_STRING
		-- ,RELATED_DOC_APPLICATION_ID
		-- ,RELATED_DOC_ENTITY_CODE
		-- ,RELATED_DOC_EVENT_CLASS_CODE
		-- ,RELATED_DOC_TRX_ID
		-- ,RELATED_DOC_NUMBER
		-- ,RELATED_DOC_DATE
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_TRX_ID
		,APPLIED_FROM_LINE_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,ADJUSTED_DOC_LINE_ID
		-- ,ADJUSTED_DOC_NUMBER
		-- ,ADJUSTED_DOC_DATE
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID
		-- ,APPLIED_TO_TRX_NUMBER
		,REF_DOC_TRX_LEVEL_TYPE
		,REF_DOC_APPLICATION_ID
		,REF_DOC_ENTITY_CODE
		,REF_DOC_EVENT_CLASS_CODE
		,REF_DOC_TRX_ID
		,REF_DOC_LINE_ID
		-- ,REF_DOC_LINE_QUANTITY
		,APPLIED_TO_TRX_LEVEL_TYPE
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,MERCHANT_PARTY_NAME
		,MERCHANT_PARTY_DOCUMENT_NUMBER
		,MERCHANT_PARTY_REFERENCE
		,MERCHANT_PARTY_TAXPAYER_ID
		,MERCHANT_PARTY_TAX_REG_NUMBER
		-- ,MERCHANT_PARTY_ID
		,MERCHANT_PARTY_COUNTRY
		,START_EXPENSE_DATE
		,SHIP_TO_LOCATION_ID
		-- ,SHIP_FROM_LOCATION_ID
		-- ,BILL_TO_LOCATION_ID
		-- ,BILL_FROM_LOCATION_ID
		-- ,SHIP_TO_PARTY_TAX_PROF_ID
		-- ,SHIP_FROM_PARTY_TAX_PROF_ID
		-- ,BILL_TO_PARTY_TAX_PROF_ID
		-- ,BILL_FROM_PARTY_TAX_PROF_ID
		-- ,SHIP_TO_SITE_TAX_PROF_ID
		-- ,SHIP_FROM_SITE_TAX_PROF_ID
		-- ,BILL_TO_SITE_TAX_PROF_ID
		-- ,BILL_FROM_SITE_TAX_PROF_ID
		-- ,MERCHANT_PARTY_TAX_PROF_ID
		-- ,HQ_ESTB_PARTY_TAX_PROF_ID
		-- ,CTRL_TOTAL_LINE_TX_AMT
		-- ,CTRL_TOTAL_HDR_TX_AMT
		-- ,INPUT_TAX_CLASSIFICATION_CODE
		-- ,OUTPUT_TAX_CLASSIFICATION_CODE
		-- ,INTERNAL_ORG_LOCATION_ID
		,RECORD_TYPE_CODE
		,PRODUCT_FISC_CLASSIFICATION
		,PRODUCT_CATEGORY
		,USER_DEFINED_FISC_CLASS
		,ASSESSABLE_VALUE
		,TRX_BUSINESS_CATEGORY
		,SUPPLIER_TAX_INVOICE_NUMBER
		,SUPPLIER_TAX_INVOICE_DATE
		,SUPPLIER_EXCHANGE_RATE
		,TAX_INVOICE_DATE
		,TAX_INVOICE_NUMBER
		,DOCUMENT_SUB_TYPE
		,LINE_INTENDED_USE
		,PORT_OF_ENTRY_CODE
		-- ,SOURCE_APPLICATION_ID
		-- ,SOURCE_ENTITY_CODE
		-- ,SOURCE_EVENT_CLASS_CODE
		-- ,SOURCE_TRX_ID
		-- ,SOURCE_LINE_ID
		-- ,SOURCE_TRX_LEVEL_TYPE
		,HISTORICAL_FLAG
		,LINE_AMT_INCLUDES_TAX_FLAG
		,CTRL_HDR_TX_APPL_FLAG
		,TAX_REPORTING_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,INCLUSIVE_TAX_OVERRIDE_FLAG
		,THRESHOLD_INDICATOR_FLAG
		,USER_UPD_DET_FACTORS_FLAG
		,TAX_PROCESSING_COMPLETED_FLAG
		,ASSET_FLAG
		,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
	        ,LAST_UPDATE_LOGIN
	        ,EVENT_CLASS_MAPPING_ID
	        ,SHIP_THIRD_PTY_ACCT_ID
	        ,SHIP_THIRD_PTY_ACCT_SITE_ID
		,GLOBAL_ATTRIBUTE_CATEGORY
		,GLOBAL_ATTRIBUTE1
                -- ,ICX_SESSION_ID
                -- ,TRX_LINE_CURRENCY_CODE
                -- ,TRX_LINE_CURRENCY_CONV_RATE
                -- ,TRX_LINE_CURRENCY_CONV_DATE
                -- ,TRX_LINE_PRECISION
                -- ,TRX_LINE_MAU
                -- ,TRX_LINE_CURRENCY_CONV_TYPE
                -- ,INTERFACE_ENTITY_CODE
                -- ,INTERFACE_LINE_ID
                -- ,SOURCE_TAX_LINE_ID
	        ,BILL_THIRD_PTY_ACCT_ID
	        ,BILL_THIRD_PTY_ACCT_SITE_ID
	        )
    WHEN AP_LINE_LOOKUP_CODE = 'TAX' THEN
      INTO ZX_LINES_SUMMARY (
		SUMMARY_TAX_LINE_ID
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,TRX_ID
		,TRX_NUMBER
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_TRX_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,SUMMARY_TAX_LINE_NUMBER
		,CONTENT_OWNER_ID
		,TAX_REGIME_CODE
		,TAX
		,TAX_STATUS_CODE
		,TAX_RATE_ID
		,TAX_RATE_CODE
		,TAX_RATE
		,TAX_AMT
		,TAX_AMT_TAX_CURR
		,TAX_AMT_FUNCL_CURR
		,TAX_JURISDICTION_CODE
		,TOTAL_REC_TAX_AMT
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,LEDGER_ID
		,LEGAL_ENTITY_ID
		-- ,ESTABLISHMENT_ID
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_TYPE
		,CURRENCY_CONVERSION_RATE
		-- ,SUMMARIZATION_TEMPLATE_ID
		,TAXABLE_BASIS_FORMULA
		,TAX_CALCULATION_FORMULA
		,HISTORICAL_FLAG
		,CANCEL_FLAG
		,DELETE_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,SELF_ASSESSED_FLAG
		,OVERRIDDEN_FLAG
		,REPORTING_ONLY_FLAG
		,ASSOCIATED_CHILD_FROZEN_FLAG
		,COPIED_FROM_OTHER_DOC_FLAG
		,MANUALLY_ENTERED_FLAG
		,LAST_MANUAL_ENTRY   --BUG7146063
		,RECORD_TYPE_CODE
		-- ,TAX_PROVIDER_ID
		,TAX_ONLY_LINE_FLAG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
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
		,APPLIED_FROM_LINE_ID
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_LINE_ID
		-- ,TAX_EXEMPTION_ID
		-- ,TAX_RATE_BEFORE_EXEMPTION
		-- ,TAX_RATE_NAME_BEFORE_EXEMPTION
		-- ,EXEMPT_RATE_MODIFIER
		-- ,EXEMPT_CERTIFICATE_NUMBER
		-- ,EXEMPT_REASON
		-- ,EXEMPT_REASON_CODE
		-- ,TAX_RATE_BEFORE_EXCEPTION
		-- ,TAX_RATE_NAME_BEFORE_EXCEPTION
		-- ,TAX_EXCEPTION_ID
		-- ,EXCEPTION_RATE
		,TOTAL_REC_TAX_AMT_TAX_CURR
		,TOTAL_NREC_TAX_AMT_TAX_CURR
		,MRC_TAX_LINE_FLAG
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
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,APPLIED_TO_TRX_LEVEL_TYPE
		,TRX_LEVEL_TYPE
		,ADJUST_TAX_AMT_FLAG
		,OBJECT_VERSION_NUMBER)
        VALUES(
		SUMMARY_TAX_LINE_ID
		,INTERNAL_ORGANIZATION_ID
		,APPLICATION_ID
		,ENTITY_CODE
		,EVENT_CLASS_CODE
		,TRX_ID
		,TRX_NUMBER
		,APPLIED_FROM_APPLICATION_ID
		,APPLIED_FROM_EVENT_CLASS_CODE
		,APPLIED_FROM_ENTITY_CODE
		,APPLIED_FROM_TRX_ID
		,ADJUSTED_DOC_APPLICATION_ID
		,ADJUSTED_DOC_ENTITY_CODE
		,ADJUSTED_DOC_EVENT_CLASS_CODE
		,ADJUSTED_DOC_TRX_ID
		,SUMMARY_TAX_LINE_NUMBER
		,CONTENT_OWNER_ID
		,TAX_REGIME_CODE
		,TAX
		,TAX_STATUS_CODE
		,TAX_RATE_ID
		,TAX_RATE_CODE
		,TAX_RATE
		,TAX_AMT
		,TAX_AMT_TAX_CURR
		,TAX_AMT_FUNCL_CURR
		,TAX_JURISDICTION_CODE
		,TOTAL_REC_TAX_AMT
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,LEDGER_ID
		,LEGAL_ENTITY_ID
		-- ,ESTABLISHMENT_ID
		,CURRENCY_CONVERSION_DATE
		,CURRENCY_CONVERSION_TYPE
		,CURRENCY_CONVERSION_RATE
		-- ,NULL                                                 -- SUMMARIZATION_TEMPLATE_ID
		,'STANDARD_TB'                                        -- TAXABLE_BASIS_FORMULA
		,'STANDARD_TC'                                        -- TAX_CALCULATION_FORMULA
		,HISTORICAL_FLAG
		,CANCEL_FLAG
		,'N'                                                  -- DELETE_FLAG
		,TAX_AMT_INCLUDED_FLAG
		,COMPOUNDING_TAX_FLAG
		,SELF_ASSESSED_FLAG
		,OVERRIDDEN_FLAG
		,'N'                                                  -- REPORTING_ONLY_FLAG
		,'N'                                                  -- ASSOCIATED_CHILD_FROZEN_FLAG
		,'N'                                                  -- COPIED_FROM_OTHER_DOC_FLAG
		,MANUALLY_ENTERED_FLAG   --BUG7146063
		,LAST_MANUAL_ENTRY  --BUG7146063
		,RECORD_TYPE_CODE
		-- ,NULL                                              -- TAX_PROVIDER_ID
		,TAX_ONLY_LINE_FLAG
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
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
		,APPLIED_FROM_LINE_ID
		,APPLIED_TO_APPLICATION_ID
		,APPLIED_TO_EVENT_CLASS_CODE
		,APPLIED_TO_ENTITY_CODE
		,APPLIED_TO_TRX_ID
		,APPLIED_TO_TRX_LINE_ID                               -- APPLIED_TO_LINE_ID
		-- ,NULL                                              -- TAX_EXEMPTION_ID
		-- ,NULL                                              -- TAX_RATE_BEFORE_EXEMPTION
		-- ,NULL                                              -- TAX_RATE_NAME_BEFORE_EXEMPTION
		-- ,NULL                                              -- EXEMPT_RATE_MODIFIER
		-- ,NULL                                              -- EXEMPT_CERTIFICATE_NUMBER
		-- ,NULL                                              -- EXEMPT_REASON
		-- ,NULL                                              -- EXEMPT_REASON_CODE
		-- ,NULL                                              -- TAX_RATE_BEFORE_EXCEPTION
		-- ,NULL                                              -- TAX_RATE_NAME_BEFORE_EXCEPTION
		-- ,NULL                                              -- TAX_EXCEPTION_ID
		-- ,NULL                                              -- EXCEPTION_RATE
		,TOTAL_REC_TAX_AMT_FUNCL_CURR
		,TOTAL_NREC_TAX_AMT_FUNCL_CURR
		,'N'                                                  -- MRC_TAX_LINE_FLAG
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
		,APPLIED_FROM_TRX_LEVEL_TYPE
		,ADJUSTED_DOC_TRX_LEVEL_TYPE
		,APPLIED_TO_TRX_LEVEL_TYPE
		,TRX_LEVEL_TYPE
		,NULL                                                -- ADJUST_TAX_AMT_FLAG
		,OBJECT_VERSION_NUMBER
		)
       (SELECT  /*+ ROWID(inv) ORDERED use_nl(fnd_curr,fds,lines,poll,ptp)*/
                NULL                                                  EVENT_ID
                ,1                                                    OBJECT_VERSION_NUMBER
                ,NVL(lines.org_id,-99)                                INTERNAL_ORGANIZATION_ID
                ,200                                                  APPLICATION_ID
                ,'AP_INVOICES'                                        ENTITY_CODE
                ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                  'STANDARD', 'STANDARD INVOICES',
		  'CREDIT'  , 'STANDARD INVOICES',   --Bug 6489409
	          'DEBIT'   , 'STANDARD INVOICES',   --Bug 6489409
		  'MIXED'   , 'STANDARD INVOICES',   --Bug 6489409
		  'ADJUSTMENT','STANDARD INVOICES',  --Bug 6489409
		  'PO PRICE ADJUST','STANDARD INVOICES', --Bug 6489409
		  'INVOICE REQUEST','STANDARD INVOICES', --Bug 6489409
		  'CREDIT MEMO REQUEST','STANDARD INVOICES',--Bug 6489409
 		  'RETAINAGE RELEASE'  ,'STANDARD INVOICES',--Bug 6489409
                  'PREPAYMENT', 'PREPAYMENT INVOICES',
                  'EXPENSE REPORT', 'EXPENSE REPORTS',
                  'INTEREST INVOICE', 'INTEREST INVOICES','NA')       EVENT_CLASS_CODE
                ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE, 'STANDARD', 1,
                  'PREPAYMENT', 7, 'EXPENSE REPORT', 2, NULL)         EVENT_CLASS_MAPPING_ID
                ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                  'STANDARD','STANDARD INVOICE CREATED',
                  'PREPAYMENT','PREPAYMENT INVOICE CREATED',
                  'EXPENSE REPORT','EXPENSE REPORT CREATED',
                  'INTEREST INVOICE','INTEREST INVOICE CREATED','NA') EVENT_TYPE_CODE
               ,(CASE
                 WHEN inv.invoice_type_lookup_code in
                   ('ADJUSTMENT','CREDIT','DEBIT','INTEREST',
                    'MIXED','QUICKDEFAULT','PO PRICE ADJUST',
                    'QUICKMATCH','STANDARD','AWT')
                  THEN 'PURCHASE_TRANSACTION'
                 WHEN inv.invoice_type_lookup_code = 'PREPAYMENT'
                  THEN 'PURCHASE_PREPAYMENTTRANSACTION'
                 WHEN inv.invoice_type_lookup_code='EXPENSE REPORT'
                  THEN  'EXPENSE_REPORT'
                 ELSE   NULL
                END)                                                  TAX_EVENT_CLASS_CODE
                ,'VALIDATE'                                           TAX_EVENT_TYPE_CODE
                -- ,NULL                                              DOC_EVENT_STATUS
                ,'CREATE'                                             LINE_LEVEL_ACTION
                ,DECODE(lines.po_line_location_id,
                  NULL, DECODE(lines.line_type_lookup_code,
                         'PREPAY', 'PREPAY_APPLICATION',
                          DECODE(inv.invoice_type_lookup_code,
                                'STANDARD', 'STANDARD INVOICES',
                                'CREDIT','AP_CREDIT_MEMO',
                                'CREDIT MEMO REQUEST', 'AP_CREDIT_MEMO',
                                'DEBIT','AP_DEBIT_MEMO',
                                'PREPAYMENT','PREPAYMENT INVOICES',
                                'EXPENSE REPORT','EXPENSE REPORTS',
                                'STANDARD INVOICES'
                                )
                               ),
                        DECODE(poll.shipment_type,
                         'PREPAYMENT', DECODE(poll.payment_type,
                                         'ADVANCE', 'ADVANCE',
                                         'MILESTONE', 'FINANCING',
                                         'RATE', 'FINANCING',
                                         'LUMPSUM', 'FINANCING',
                                         DECODE(poll.matching_basis,
                                           'AMOUNT','AMOUNT_MATCHED',
                                           'STANDARD INVOICES')
                                              ),
                                       DECODE(poll.matching_basis,
                                        'AMOUNT','AMOUNT_MATCHED',
                                        'STANDARD INVOICES')
                               )
                      )                                               LINE_CLASS
                -- ,NULL                                              APPLICATION_DOC_STATUS
                ,lines.line_type_lookup_code                          AP_LINE_LOOKUP_CODE
                ,lines.invoice_id                                     TRX_ID
                ,NVL(inv.invoice_date,sysdate)                        TRX_DATE
                ,lines.set_of_books_id                                LEDGER_ID
                ,inv.invoice_currency_code                            TRX_CURRENCY_CODE
		,NVL(inv.legal_entity_id, -99)                        LEGAL_ENTITY_ID
		-- ,NULL					      ESTABLISHMENT_ID
                ,inv.taxation_country                                 DEFAULT_TAXATION_COUNTRY
                ,inv.invoice_num                                      TRX_NUMBER
                ,lines.description                                    TRX_LINE_DESCRIPTION
                ,inv.description                                      TRX_DESCRIPTION
                ,inv.invoice_received_date                            TRX_COMMUNICATED_DATE
                ,NVL(lines.accounting_date,sysdate)                   TRX_LINE_GL_DATE
                ,inv.batch_id                                         BATCH_SOURCE_ID
                -- ,NULL                                              BATCH_SOURCE_NAME
                ,inv.doc_sequence_id                                  DOC_SEQ_ID
                ,fds.name                                             DOC_SEQ_NAME
                ,inv.doc_sequence_value                               DOC_SEQ_VALUE
                ,inv.terms_date                                       TRX_DUE_DATE
                -- ,NULL                                              TRX_TYPE_DESCRIPTION
                ,lines.line_type_lookup_code                          TRX_LINE_TYPE
                ,lines.accounting_date                                TRX_LINE_DATE
                -- ,NULL                                              TRX_SHIPPING_DATE
                -- ,NULL                                              TRX_RECEIPT_DATE
                ,NVL(lines.amount,0)                                  LINE_AMT
                ,lines.quantity_invoiced                              TRX_LINE_QUANTITY
                ,lines.unit_price                                     -- UNIT_PRICE
                ,lines.inventory_item_id                              PRODUCT_ID
                -- ,NULL                                              PRODUCT_ORG_ID
                ,lines.unit_meas_lookup_code                          UOM_CODE
                ,lines.product_type                                   -- PRODUCT_TYPE
                -- ,NULL                                              PRODUCT_CODE
                ,lines.item_description                               PRODUCT_DESCRIPTION
                ,ptp.party_tax_profile_id                             FIRST_PTY_ORG_ID
                -- ,NULL                                              ASSET_NUMBER
                -- ,NULL                                              ASSET_ACCUM_DEPRECIATION
                -- ,NULL                                              ASSET_TYPE
                -- ,NULL                                              ASSET_COST
                -- ,NULL                                              RELATED_DOC_APPLICATION_ID,
                -- ,NULL                                              RELATED_DOC_ENTITY_CODE
                -- ,NULL                                              RELATED_DOC_EVENT_CLASS_CODE
                -- ,NULL                                              RELATED_DOC_TRX_ID
                -- ,NULL                                              RELATED_DOC_NUMBER
                -- ,NULL                                              RELATED_DOC_DATE
                ,DECODE(lines.prepay_invoice_id, NULL, NULL, 200)     APPLIED_FROM_APPLICATION_ID
                ,DECODE(lines.prepay_invoice_id, NULL, NULL,
                        'AP_INVOICES')                                APPLIED_FROM_ENTITY_CODE
                ,DECODE(lines.prepay_invoice_id, NULL, NULL,
                        'PREPAYMENT INVOICES')                        APPLIED_FROM_EVENT_CLASS_CODE
                ,lines.prepay_invoice_id                              APPLIED_FROM_TRX_ID
                ,lines.prepay_line_number                             APPLIED_FROM_LINE_ID
                ,DECODE(lines.corrected_inv_id, NULL, NULL, 200)      ADJUSTED_DOC_APPLICATION_ID
                ,DECODE(lines.corrected_inv_id, NULL, NULL,
                        'AP_INVOICES')                                ADJUSTED_DOC_ENTITY_CODE
                ,DECODE(lines.corrected_inv_id, NULL, NULL,
                        'STANDARD INVOICES')                          ADJUSTED_DOC_EVENT_CLASS_CODE
                ,lines.corrected_inv_id                               ADJUSTED_DOC_TRX_ID
                ,lines.corrected_line_number                          ADJUSTED_DOC_LINE_ID
                -- ,NULL                                              ADJUSTED_DOC_NUMBER
                -- ,NULL                                              ADJUSTED_DOC_DATE
                ,DECODE(lines.rcv_transaction_id, NULL, NULL, 707)    APPLIED_TO_APPLICATION_ID
                ,DECODE(lines.rcv_transaction_id, NULL, NULL,
                       'RCV_ACCOUNTING_EVENTS')                       APPLIED_TO_ENTITY_CODE
                ,DECODE(lines.rcv_transaction_id, NULL, NULL,
                        'RCPT_REC_INSP')                              APPLIED_TO_EVENT_CLASS_CODE
                ,lines.rcv_transaction_id                             APPLIED_TO_TRX_ID
                ,lines.rcv_shipment_line_id                           APPLIED_TO_TRX_LINE_ID
                -- ,NULL                                              APPLIED_TO_TRX_NUMBER
                ,DECODE(NVL(lines.po_release_id, lines.po_header_id),
                        NULL, NULL, 'SHIPMENT')                       REF_DOC_TRX_LEVEL_TYPE
                ,NVL(lines.po_release_id, lines.po_header_id)         REF_DOC_TRX_ID
                ,lines.po_line_location_id                            REF_DOC_LINE_ID
                -- ,NULL                                              REF_DOC_LINE_QUANTITY
                ,DECODE(lines.rcv_transaction_id, NULL, NULL,
                        'LINE')                                       APPLIED_TO_TRX_LEVEL_TYPE
                ,DECODE(lines.prepay_invoice_id, NULL, NULL,
                        'LINE')                                       APPLIED_FROM_TRX_LEVEL_TYPE
                ,DECODE(lines.corrected_inv_id, NULL, NULL,
                        'LINE')                                       ADJUSTED_DOC_TRX_LEVEL_TYPE
                ,lines.merchant_name                                  MERCHANT_PARTY_NAME
                ,lines.merchant_document_number                       MERCHANT_PARTY_DOCUMENT_NUMBER
                ,lines.merchant_reference                             MERCHANT_PARTY_REFERENCE
                ,lines.merchant_taxpayer_id                           MERCHANT_PARTY_TAXPAYER_ID
                ,lines.merchant_tax_reg_number                        MERCHANT_PARTY_TAX_REG_NUMBER
                -- ,NULL                                              MERCHANT_PARTY_ID
                ,lines.country_of_supply                              MERCHANT_PARTY_COUNTRY
                ,lines.start_expense_date                             -- START_EXPENSE_DATE
                ,lines.ship_to_location_id                            -- SHIP_TO_LOCATION_ID
                -- ,NULL                                              SHIP_FROM_LOCATION_ID
                -- ,NULL                                              BILL_TO_LOCATION_ID
                -- ,NULL                                              BILL_FROM_LOCATION_ID
                -- ,NULL                                              SHIP_TO_PARTY_TAX_PROF_ID
                -- ,NULL                                              SHIP_FROM_PARTY_TAX_PROF_ID
                -- ,NULL                                              BILL_TO_PARTY_TAX_PROF_ID
                -- ,NULL                                              BILL_FROM_PARTY_TAX_PROF_ID
                -- ,NULL                                              SHIP_TO_SITE_TAX_PROF_ID
                -- ,NULL                                              SHIP_FROM_SITE_TAX_PROF_ID
                -- ,NULL                                              BILL_TO_SITE_TAX_PROF_ID
                -- ,NULL                                              BILL_FROM_SITE_TAX_PROF_ID
                -- ,NULL                                              MERCHANT_PARTY_TAX_PROF_ID
                -- ,NULL                                              HQ_ESTB_PARTY_TAX_PROF_ID
                -- ,NULL                                              CTRL_TOTAL_LINE_TX_AMT
                -- ,NULL                                              CTRL_TOTAL_HDR_TX_AMT
                -- ,NULL                                              INPUT_TAX_CLASSIFICATION_CODE
                -- ,NULL                                              OUTPUT_TAX_CLASSIFICATION_CODE
                -- ,NULL                                              INTERNAL_ORG_LOCATION_ID
                ,'MIGRATED'                                           RECORD_TYPE_CODE
                ,lines.product_fisc_classification                    -- PRODUCT_FISC_CLASSIFICATION
                ,lines.product_category                               -- PRODUCT_CATEGORY
                ,lines.user_defined_fisc_class                        -- USER_DEFINED_FISC_CLASS
                ,lines.assessable_value                               -- ASSESSABLE_VALUE
                ,lines.trx_business_category                          -- TRX_BUSINESS_CATEGORY
                ,inv.supplier_tax_invoice_number                      -- SUPPLIER_TAX_INVOICE_NUMBER
                ,inv.supplier_tax_invoice_date                        -- SUPPLIER_TAX_INVOICE_DATE
                ,inv.supplier_tax_exchange_rate                       SUPPLIER_EXCHANGE_RATE
                ,inv.tax_invoice_recording_date                       TAX_INVOICE_DATE
                ,inv.tax_invoice_internal_seq                         TAX_INVOICE_NUMBER
                ,inv.document_sub_type                                -- DOCUMENT_SUB_TYPE
                ,lines.primary_intended_use                           LINE_INTENDED_USE
                ,inv.port_of_entry_code                               -- PORT_OF_ENTRY_CODE
                -- ,NULL                                              SOURCE_APPLICATION_ID
                -- ,NULL                                              SOURCE_ENTITY_CODE
                -- ,NULL                                              SOURCE_EVENT_CLASS_CODE
                -- ,NULL                                              SOURCE_TRX_ID,
                -- ,NULL                                              SOURCE_LINE_ID,
                -- ,NULL                                              SOURCE_TRX_LEVEL_TYPE
                ,'N'                                                  LINE_AMT_INCLUDES_TAX_FLAG
                ,'N'                                                  CTRL_HDR_TX_APPL_FLAG
                ,'Y'                                                  TAX_REPORTING_FLAG
                ,'N'                                                  TAX_AMT_INCLUDED_FLAG
                ,'N'                                                  COMPOUNDING_TAX_FLAG
                ,'N'                                                  INCLUSIVE_TAX_OVERRIDE_FLAG
                ,'N'                                                  THRESHOLD_INDICATOR_FLAG
                ,'N'                                                  USER_UPD_DET_FACTORS_FLAG
                ,'N'                                                  TAX_PROCESSING_COMPLETED_FLAG
                ,lines.assets_tracking_flag                           ASSET_FLAG
                ,ptp.party_tax_profile_id                             CONTENT_OWNER_ID
                ,inv.exchange_date                                    CURRENCY_CONVERSION_DATE
                ,inv.exchange_rate                                    CURRENCY_CONVERSION_RATE
                ,inv.exchange_rate_type                               CURRENCY_CONVERSION_TYPE
                ,fnd_curr.minimum_accountable_unit                    MINIMUM_ACCOUNTABLE_UNIT
                ,NVL(fnd_curr.precision,0)                            PRECISION
                ,DECODE(NVL(lines.po_release_id, lines.po_header_id),
                        NULL, NULL, 201)                              REF_DOC_APPLICATION_ID
                ,DECODE(lines.po_release_id, NULL,
                   DECODE(lines.po_header_id, NULL, NULL,
                          'PURCHASE_ORDER'), 'RELEASE')               REF_DOC_ENTITY_CODE
                ,DECODE(lines.po_release_id, NULL,
                   DECODE(lines.po_header_id, NULL, NULL,
                           'PO_PA'), 'RELEASE')                       REF_DOC_EVENT_CLASS_CODE
                ,lines.SUMMARY_TAX_LINE_ID 			      SUMMARY_TAX_LINE_ID
                ,lines.TAX                                            TAX
                ,DECODE(lines.line_type_lookup_code, 'TAX',
                  RANK() OVER (PARTITION BY inv.invoice_id,
                                lines.line_type_lookup_code
                                ORDER BY lines.line_number), NULL)    SUMMARY_TAX_LINE_NUMBER
                ,lines.tax_rate                                       -- TAX_RATE
                ,lines.tax_rate_code                                  -- TAX_RATE_CODE
                ,lines.tax_rate_id                                    -- TAX_RATE_ID
                ,lines.tax_regime_code                                -- TAX_REGIME_CODE
                ,lines.tax_status_code                                -- TAX_STATUS_CODE
                ,lines.tax_jurisdiction_code                          -- TAX_JURISDICTION_CODE
                ,'LINE'                                               TRX_LEVEL_TYPE
                ,lines.line_number                                    TRX_LINE_ID
                ,lines.line_number                                    TRX_LINE_NUMBER
                ,lines.default_dist_ccid                              ACCOUNT_CCID
                -- ,NULL                                              ACCOUNT_STRING
                ,lines.amount                                         TAX_AMT
                ,lines.base_amount                                    TAX_AMT_TAX_CURR
                ,lines.base_amount                                    TAX_AMT_FUNCL_CURR
                ,lines.attribute_category                             -- ATTRIBUTE_CATEGORY
                ,lines.attribute1                                     -- ATTRIBUTE1
                ,lines.attribute2                                     -- ATTRIBUTE2
                ,lines.attribute3                                     -- ATTRIBUTE3
                ,lines.attribute4                                     -- ATTRIBUTE4
                ,lines.attribute5                                     -- ATTRIBUTE5
                ,lines.attribute6                                     -- ATTRIBUTE6
                ,lines.attribute7                                     -- ATTRIBUTE7
                ,lines.attribute8                                     -- ATTRIBUTE8
                ,lines.attribute9                                     -- ATTRIBUTE9
                ,lines.attribute10                                    -- ATTRIBUTE10
                ,lines.attribute11                                    -- ATTRIBUTE11
                ,lines.attribute12                                    -- ATTRIBUTE12
                ,lines.attribute13                                    -- ATTRIBUTE13
                ,lines.attribute14                                    -- ATTRIBUTE14
                ,lines.attribute15                                    -- ATTRIBUTE15
                ,lines.global_attribute_category                      -- GLOBAL_ATTRIBUTE_CATEGORY
                ,lines.global_attribute1                              -- GLOBAL_ATTRIBUTE1
                ,lines.global_attribute2                              -- GLOBAL_ATTRIBUTE2
                ,lines.global_attribute3                              -- GLOBAL_ATTRIBUTE3
                ,lines.global_attribute4                              -- GLOBAL_ATTRIBUTE4
                ,lines.global_attribute5                              -- GLOBAL_ATTRIBUTE5
                ,lines.global_attribute6                              -- GLOBAL_ATTRIBUTE6
                ,lines.global_attribute7                              -- GLOBAL_ATTRIBUTE7
                ,lines.global_attribute8                              -- GLOBAL_ATTRIBUTE8
                ,lines.global_attribute9                              -- GLOBAL_ATTRIBUTE9
                ,lines.global_attribute10                             -- GLOBAL_ATTRIBUTE10
                ,lines.global_attribute11                             -- GLOBAL_ATTRIBUTE11
                ,lines.global_attribute12                             -- GLOBAL_ATTRIBUTE12
                ,lines.global_attribute13                             -- GLOBAL_ATTRIBUTE13
                ,lines.global_attribute14                             -- GLOBAL_ATTRIBUTE14
                ,lines.global_attribute15                             -- GLOBAL_ATTRIBUTE15
                ,lines.global_attribute16                             -- GLOBAL_ATTRIBUTE16
                ,lines.global_attribute17                             -- GLOBAL_ATTRIBUTE17
                ,lines.global_attribute18                             -- GLOBAL_ATTRIBUTE18
                ,lines.global_attribute19                             -- GLOBAL_ATTRIBUTE19
                ,lines.global_attribute20                             -- GLOBAL_ATTRIBUTE20
                ,'Y'                                                  HISTORICAL_FLAG
                ,'N'                                                  OVERRIDDEN_FLAG
                ,'N'                                                  SELF_ASSESSED_FLAG
                ,1                                                    CREATED_BY
                ,SYSDATE                                              CREATION_DATE
                ,SYSDATE                                              LAST_UPDATE_DATE
                ,1                                                    LAST_UPDATE_LOGIN
                ,1                                                    LAST_UPDATED_BY
                -- ,NULL                                              LAST_MANUAL_ENTRY
                ,CASE
                  WHEN lines.line_type_lookup_code <> 'TAX'
                   THEN NULL
                  WHEN NOT EXISTS          -- Tax Lines
                    (SELECT 1
                       FROM AP_INV_DISTS_TARGET dists
                      WHERE dists.invoice_id = lines.invoice_id
                        AND dists.invoice_line_number = lines.line_number
                        AND dists.charge_applicable_to_dist_id IS NOT NULL
                     )
                   THEN 'Y'
                  ELSE  'N'
                END                                                   TAX_ONLY_LINE_FLAG
                ,lines.total_rec_tax_amount                           TOTAL_REC_TAX_AMT
                ,lines.total_nrec_tax_amount                          TOTAL_NREC_TAX_AMT
                ,lines.total_rec_tax_amt_funcl_curr                   -- TOTAL_REC_TAX_AMT_FUNCL_CURR,
                ,lines.total_nrec_tax_amt_funcl_curr                  -- TOTAL_NREC_TAX_AMT_FUNCL_CURR,
                ,inv.vendor_id 					      SHIP_THIRD_PTY_ACCT_ID
	        ,inv.vendor_site_id				      SHIP_THIRD_PTY_ACCT_SITE_ID
                ,inv.vendor_id 					      BILL_THIRD_PTY_ACCT_ID
	        ,inv.vendor_site_id				      BILL_THIRD_PTY_ACCT_SITE_ID
                -- ,NULL                                              ICX_SESSION_ID
                -- ,NULL                                              TRX_LINE_CURRENCY_CODE
                -- ,NULL                                              TRX_LINE_CURRENCY_CONV_RATE
                -- ,NULL                                              TRX_LINE_CURRENCY_CONV_DATE
                -- ,NULL                                              TRX_LINE_PRECISION
                -- ,NULL                                              TRX_LINE_MAU
                -- ,NULL                                              TRX_LINE_CURRENCY_CONV_TYPE
                -- ,NULL                                              INTERFACE_ENTITY_CODE
                -- ,NULL                                              INTERFACE_LINE_ID
                -- ,NULL                                              SOURCE_TAX_LINE_ID
                ,DECODE(lines.discarded_flag, 'Y', 'Y', 'N')          CANCEL_FLAG
                ,DECODE(lines.line_source,'MANUAL LINE ENTRY','Y','N')    MANUALLY_ENTERED_FLAG  --BUG7146063
                ,DECODE(lines.line_source,'MANUAL LINE ENTRY','TAX_AMOUNT',NULL)    LAST_MANUAL_ENTRY  --BUG7146063
           FROM ( select distinct other_doc_application_id,other_doc_trx_id from ZX_VALIDATION_ERRORS_GT ) zxvalerr, --Bug 5187701
                ap_invoices_all          inv,
                fnd_currencies           fnd_curr,
                fnd_document_sequences   fds,
                ap_invoice_lines_all     lines,
                po_line_locations_all    poll,
                zx_party_tax_profile     ptp
          WHERE zxvalerr.other_doc_application_id = 200
            AND inv.invoice_id = zxvalerr.other_doc_trx_id
            AND fnd_curr.currency_code = inv.invoice_currency_code
            AND inv.doc_sequence_id = fds.doc_sequence_id(+)
            AND lines.invoice_id = inv.invoice_id
            AND NVL(lines.historical_flag, 'N') = 'Y'
            AND poll.line_location_id(+) = lines.po_line_location_id
            AND ptp.party_type_code = 'OU'
            AND ptp.party_id = DECODE(l_multi_org_flag,'N',l_org_id,lines.org_id)
          );

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap',
                   'Inserting data into zx_lines and zx_rec_nrec_dist');
  END IF;

  -- Insert data into zx_lines and zx_rec_nrec_dist
  --
  INSERT ALL
      INTO ZX_REC_NREC_DIST(
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
     		  -- ,ACCOUNT_STRING
     		  -- ,ADJUSTED_DOC_TAX_DIST_ID
     		  -- ,APPLIED_FROM_TAX_DIST_ID
     		  -- ,APPLIED_TO_DOC_CURR_CONV_RATE
     		  ,AWARD_ID
     		  ,EXPENDITURE_ITEM_DATE
     		  ,EXPENDITURE_ORGANIZATION_ID
     		  ,EXPENDITURE_TYPE
     		  ,FUNC_CURR_ROUNDING_ADJUSTMENT
     		  ,GL_DATE
     		  ,INTENDED_USE
     		  ,ITEM_DIST_NUMBER
     		  -- ,MRC_LINK_TO_TAX_DIST_ID
     		  -- ,ORIG_REC_NREC_RATE
     		  -- ,ORIG_REC_NREC_TAX_AMT
     		  -- ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
     		  -- ,ORIG_REC_RATE_CODE
     		  -- ,PER_TRX_CURR_UNIT_NR_AMT
     		  -- ,PER_UNIT_NREC_TAX_AMT
     		  -- ,PRD_TAX_AMT
     		  -- ,PRICE_DIFF
     		  ,PROJECT_ID
     		  -- ,QTY_DIFF
     		  -- ,RATE_TAX_FACTOR
     		  ,REC_NREC_RATE
     		  ,REC_NREC_TAX_AMT
     		  ,REC_NREC_TAX_AMT_FUNCL_CURR
     		  ,REC_NREC_TAX_AMT_TAX_CURR
     		  ,RECOVERY_RATE_CODE
     		  ,RECOVERY_TYPE_CODE
     		  -- ,RECOVERY_TYPE_ID
     		  -- ,REF_DOC_CURR_CONV_RATE
     		  ,REF_DOC_DIST_ID
     		  -- ,REF_DOC_PER_UNIT_NREC_TAX_AMT
     		  -- ,REF_DOC_TAX_DIST_ID
     		  -- ,REF_DOC_TRX_LINE_DIST_QTY
     		  -- ,REF_DOC_UNIT_PRICE
     		  -- ,REF_PER_TRX_CURR_UNIT_NR_AMT
     		  ,REVERSED_TAX_DIST_ID
     		  -- ,ROUNDING_RULE_CODE
     		  ,TASK_ID
     		  ,TAXABLE_AMT_FUNCL_CURR
     		  ,TAXABLE_AMT_TAX_CURR
     		  ,TRX_LINE_DIST_AMT
     		  ,TRX_LINE_DIST_ID
     		  ,TRX_LINE_DIST_QTY
     		  ,TRX_LINE_DIST_TAX_AMT
     		  -- ,UNROUNDED_REC_NREC_TAX_AMT
     		  -- ,UNROUNDED_TAXABLE_AMT
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
     		  ,OBJECT_VERSION_NUMBER
     		  ,ORIG_AP_CHRG_DIST_NUM
                  ,ORIG_AP_CHRG_DIST_ID
                  ,ORIG_AP_TAX_DIST_NUM
                  ,ORIG_AP_TAX_DIST_ID
                  ,INTERNAL_ORGANIZATION_ID
                  ,DEF_REC_SETTLEMENT_OPTION_CODE
                  --,TAX_JURISDICTION_ID
                  ,ACCOUNT_SOURCE_TAX_RATE_ID
		  ,RECOVERY_RATE_ID
                 )
     	 VALUES(
     	         ZX_LINES_S.NEXTVAL
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
     	 	 ,AP_LEDGER_ID
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
     	 	 -- ,ACCOUNT_STRING
     	 	 -- ,ADJUSTED_DOC_TAX_DIST_ID
     	 	 -- ,APPLIED_FROM_TAX_DIST_ID
     	 	 -- ,APPLIED_TO_DOC_CURR_CONV_RATE
     	 	 ,AWARD_ID
     	 	 ,EXPENDITURE_ITEM_DATE
     	 	 ,EXPENDITURE_ORGANIZATION_ID
     	 	 ,EXPENDITURE_TYPE
     	 	 ,FUNC_CURR_ROUNDING_ADJUSTMENT
     	 	 ,GL_DATE
     	 	 ,INTENDED_USE
     	 	 ,ITEM_DIST_NUMBER
     	 	 -- ,MRC_LINK_TO_TAX_DIST_ID
     	 	 -- ,ORIG_REC_NREC_RATE
     	 	 -- ,ORIG_REC_NREC_TAX_AMT
     	 	 -- ,ORIG_REC_NREC_TAX_AMT_TAX_CURR
     	 	 -- ,ORIG_REC_RATE_CODE
     	 	 -- ,PER_TRX_CURR_UNIT_NR_AMT
     	 	 -- ,PER_UNIT_NREC_TAX_AMT
     	 	 -- ,PRD_TAX_AMT
     	 	 -- ,PRICE_DIFF
     	 	 ,PROJECT_ID
     	 	 -- ,QTY_DIFF
     	 	 -- ,RATE_TAX_FACTOR
     	 	 ,REC_NREC_RATE
     	 	 ,REC_NREC_TAX_AMT
     	 	 ,REC_NREC_TAX_AMT_FUNCL_CURR
     	 	 ,REC_NREC_TAX_AMT_TAX_CURR
     	 	 ,RECOVERY_RATE_CODE
     	 	 ,RECOVERY_TYPE_CODE
     	 	 -- ,RECOVERY_TYPE_ID
     	 	 -- ,REF_DOC_CURR_CONV_RATE
     	 	 ,REF_DOC_DIST_ID
     	 	 -- ,REF_DOC_PER_UNIT_NREC_TAX_AMT
     	 	 -- ,REF_DOC_TAX_DIST_ID
     	 	 -- ,REF_DOC_TRX_LINE_DIST_QTY
     	 	 -- ,REF_DOC_UNIT_PRICE
     	 	 -- ,REF_PER_TRX_CURR_UNIT_NR_AMT
     	 	 ,REVERSED_TAX_DIST_ID
     	 	 -- ,ROUNDING_RULE_CODE
     	 	 ,TASK_ID
     	 	 ,TAXABLE_AMT_FUNCL_CURR
     	 	 ,TAXABLE_AMT_TAX_CURR
     	 	 ,TRX_LINE_DIST_AMT
     	 	 ,TRX_LINE_DIST_ID
     	 	 ,TRX_LINE_DIST_QTY
     	 	 ,TRX_LINE_DIST_TAX_AMT
     	 	 -- ,UNROUNDED_REC_NREC_TAX_AMT
     	 	 -- ,UNROUNDED_TAXABLE_AMT
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
 	         ,OBJECT_VERSION_NUMBER
 	         ,ORIG_AP_CHRG_DIST_NUM
                 ,ORIG_AP_CHRG_DIST_ID
                 ,ORIG_AP_TAX_DIST_NUM
                 ,ORIG_AP_TAX_DIST_ID
                 ,INTERNAL_ORGANIZATION_ID
                 ,DEF_REC_SETTLEMENT_OPTION_CODE
                 --,TAX_JURISDICTION_ID
                 ,ACCOUNT_SOURCE_TAX_RATE_ID
		 ,RECOVERY_RATE_ID
                )
   INTO ZX_LINES(
 	 	  TAX_LINE_ID
 	 	  ,TAX_LINE_NUMBER
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
 	 	  ,TAX_RATE_TYPE
 	 	  ,ADJUSTED_DOC_APPLICATION_ID
 	 	  -- ,ADJUSTED_DOC_DATE
 	 	  ,ADJUSTED_DOC_ENTITY_CODE
 	 	  ,ADJUSTED_DOC_EVENT_CLASS_CODE
 	 	  ,ADJUSTED_DOC_LINE_ID
 	 	  -- ,ADJUSTED_DOC_NUMBER
 	 	  ,ADJUSTED_DOC_TRX_ID
 	 	  ,ADJUSTED_DOC_TRX_LEVEL_TYPE
 	 	  ,APPLIED_FROM_APPLICATION_ID
 	 	  ,APPLIED_FROM_ENTITY_CODE
 	 	  ,APPLIED_FROM_EVENT_CLASS_CODE
 	 	  ,APPLIED_FROM_LINE_ID
                  -- ,APPLIED_FROM_TRX_NUMBER
 	 	  ,APPLIED_FROM_TRX_ID
 	 	  ,APPLIED_FROM_TRX_LEVEL_TYPE
 	 	  ,APPLIED_TO_APPLICATION_ID
 	 	  ,APPLIED_TO_ENTITY_CODE
 	 	  ,APPLIED_TO_EVENT_CLASS_CODE
 	 	  ,APPLIED_TO_LINE_ID
 	 	  ,APPLIED_TO_TRX_ID
 	 	  ,APPLIED_TO_TRX_LEVEL_TYPE
 	 	  -- ,APPLIED_TO_TRX_NUMBER
 	 	  -- ,CAL_TAX_AMT
 	 	  -- ,CAL_TAX_AMT_FUNCL_CURR
 	 	  -- ,CAL_TAX_AMT_TAX_CURR
 	 	  -- ,DOC_EVENT_STATUS
 	 	  -- ,INTERNAL_ORG_LOCATION_ID
 	 	  ,INTERNAL_ORGANIZATION_ID
 	 	  ,LINE_AMT
 	 	  ,LINE_ASSESSABLE_VALUE
 	 	  -- ,MRC_LINK_TO_TAX_LINE_ID
 	 	  ,NREC_TAX_AMT
 	 	  ,NREC_TAX_AMT_FUNCL_CURR
 	 	  ,NREC_TAX_AMT_TAX_CURR
 	 	  -- ,OFFSET_LINK_TO_TAX_LINE_ID
 	 	  -- ,OFFSET_TAX_RATE_CODE
 	 	  -- ,ORIG_TAX_AMT
 	 	  -- ,ORIG_TAX_AMT_TAX_CURR
 	 	  -- ,ORIG_TAX_RATE
 	 	  -- ,ORIG_TAX_RATE_CODE
 	 	  -- ,ORIG_TAX_RATE_ID
 	 	  -- ,ORIG_TAX_STATUS_CODE
 	 	  -- ,ORIG_TAX_STATUS_ID
 	 	  -- ,ORIG_TAXABLE_AMT
 	 	  -- ,ORIG_TAXABLE_AMT_TAX_CURR
 	 	  -- ,OTHER_DOC_LINE_AMT
 	 	  -- ,OTHER_DOC_LINE_TAX_AMT
 	 	  -- ,OTHER_DOC_LINE_TAXABLE_AMT
 	 	  -- ,OTHER_DOC_SOURCE
 	 	  -- ,PRORATION_CODE
 	 	  ,REC_TAX_AMT
 	 	  ,REC_TAX_AMT_FUNCL_CURR
 	 	  ,REC_TAX_AMT_TAX_CURR
 	 	  -- ,REF_DOC_LINE_QUANTITY
 	 	  -- ,RELATED_DOC_APPLICATION_ID
 	 	  -- ,RELATED_DOC_DATE
 	 	  -- ,RELATED_DOC_ENTITY_CODE
 	 	  -- ,RELATED_DOC_EVENT_CLASS_CODE
 	 	  -- ,RELATED_DOC_NUMBER
 	 	  -- ,RELATED_DOC_TRX_ID
 	 	  -- ,RELATED_DOC_TRX_LEVEL_TYPE
 	 	  -- ,REPORTING_CURRENCY_CODE
 	 	  ,TAX_AMT
 	 	  ,TAX_AMT_FUNCL_CURR
 	 	  ,TAX_AMT_TAX_CURR
 	 	  ,TAX_CALCULATION_FORMULA
 	 	  -- ,TAX_CODE
 	 	  ,TAX_DATE
 	 	  ,TAX_DETERMINE_DATE
 	 	  ,TAX_POINT_DATE
 	 	  -- ,TAX_TYPE_CODE
 	 	  -- ,ROUNDING_RULE_CODE
 	 	  ,TAXABLE_AMT
 	 	  ,TAXABLE_AMT_FUNCL_CURR
 	 	  ,TAXABLE_AMT_TAX_CURR
 	 	  ,TAXABLE_BASIS_FORMULA
 	 	  ,TRX_DATE
 	 	  ,TRX_LINE_DATE
 	 	  ,TRX_LINE_QUANTITY
 	 	  -- ,UNROUNDED_TAX_AMT
 	 	  -- ,UNROUNDED_TAXABLE_AMT
 	 	  ,HISTORICAL_FLAG
 	 	  ,OVERRIDDEN_FLAG
 	 	  ,SELF_ASSESSED_FLAG
 	 	  ,TAX_APPORTIONMENT_FLAG
 	 	  ,TAX_ONLY_LINE_FLAG
 	 	  ,TAX_AMT_INCLUDED_FLAG
 	 	  ,MRC_TAX_LINE_FLAG
 	 	  ,OFFSET_FLAG
 	 	  ,PROCESS_FOR_RECOVERY_FLAG
 	 	  ,COMPOUNDING_TAX_FLAG
 	 	  ,ORIG_TAX_AMT_INCLUDED_FLAG
 	 	  ,ORIG_SELF_ASSESSED_FLAG
 	 	  ,CANCEL_FLAG
 	 	  ,PURGE_FLAG
 	 	  ,DELETE_FLAG
 	 	  ,MANUALLY_ENTERED_FLAG
		  --,LAST_MANUAL_ENTRY  --BUG7146063
 	 	  ,REPORTING_ONLY_FLAG
 	 	  ,FREEZE_UNTIL_OVERRIDDEN_FLAG
 	 	  ,COPIED_FROM_OTHER_DOC_FLAG
 	 	  ,RECALC_REQUIRED_FLAG
 	 	  ,SETTLEMENT_FLAG
 	 	  ,ITEM_DIST_CHANGED_FLAG
 	 	  ,ASSOCIATED_CHILD_FROZEN_FLAG
 	 	  ,COMPOUNDING_DEP_TAX_FLAG
 	 	  ,ENFORCE_FROM_NATURAL_ACCT_FLAG
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
 	 	  ,LAST_MANUAL_ENTRY
		  ,LEGAL_ENTITY_ID
		  -- ,ESTABLISHMENT_ID
 	 	  ,CREATED_BY
 	 	  ,CREATION_DATE
 	 	  ,LAST_UPDATE_DATE
 	 	  ,LAST_UPDATE_LOGIN
 	 	  ,LAST_UPDATED_BY
		  ,OBJECT_VERSION_NUMBER
		  ,MULTIPLE_JURISDICTIONS_FLAG
		  ,LEGAL_REPORTING_STATUS
                  ,ACCOUNT_SOURCE_TAX_RATE_ID
 	 	  )
 	  VALUES (
 	 	  ZX_LINES_S.NEXTVAL
 	 	  ,TAX_LINE_NUMBER
 	 	  ,APPLICATION_ID
 	 	  ,CONTENT_OWNER_ID
 	 	  ,CURRENCY_CONVERSION_DATE
 	 	  ,CURRENCY_CONVERSION_RATE
 	 	  ,CURRENCY_CONVERSION_TYPE
 	 	  ,ENTITY_CODE
 	 	  ,EVENT_CLASS_CODE
 	 	  ,EVENT_TYPE_CODE
 	 	  ,AP_LEDGER_ID
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
 	 	  ,NULL
 	 	  ,ADJUSTED_DOC_APPLICATION_ID
 	 	  -- ,ADJUSTED_DOC_DATE
 	 	  ,ADJUSTED_DOC_ENTITY_CODE
 	 	  ,ADJUSTED_DOC_EVENT_CLASS_CODE
 	 	  ,ADJUSTED_DOC_LINE_ID
 	 	  -- ,ADJUSTED_DOC_NUMBER
 	 	  ,ADJUSTED_DOC_TRX_ID
 	 	  ,ADJUSTED_DOC_TRX_LEVEL_TYPE
 	 	  ,APPLIED_FROM_APPLICATION_ID
 	 	  ,APPLIED_FROM_ENTITY_CODE
 	 	  ,APPLIED_FROM_EVENT_CLASS_CODE
 	 	  ,APPLIED_FROM_LINE_ID
                  -- ,APPLIED_FROM_TRX_NUMBER
 	 	  ,APPLIED_FROM_TRX_ID
 	 	  ,APPLIED_FROM_TRX_LEVEL_TYPE
 	 	  ,APPLIED_TO_APPLICATION_ID
 	 	  ,APPLIED_TO_ENTITY_CODE
 	 	  ,APPLIED_TO_EVENT_CLASS_CODE
 	 	  ,APPLIED_TO_LINE_ID
 	 	  ,APPLIED_TO_TRX_ID
 	 	  ,APPLIED_TO_TRX_LEVEL_TYPE
 	 	  -- ,APPLIED_TO_TRX_NUMBER
 	 	  -- ,NULL                                            -- CAL_TAX_AMT
 	 	  -- ,NULL                                            -- CAL_TAX_AMT_FUNCL_CURR
 	 	  -- ,NULL                                            -- CAL_TAX_AMT_TAX_CURR
 	 	  -- ,DOC_EVENT_STATUS
 	 	  -- ,INTERNAL_ORG_LOCATION_ID
 	 	  ,INTERNAL_ORGANIZATION_ID
 	 	  ,LINE_AMT
 	 	  ,ASSESSABLE_VALUE
 	 	  -- ,NULL                                            -- MRC_LINK_TO_TAX_LINE_ID
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
	             'NONREC_TAX', REC_NREC_TAX_AMT, NULL)            -- NREC_TAX_AMT
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'NONREC_TAX', REC_NREC_TAX_AMT_FUNCL_CURR, NULL) -- NREC_TAX_AMT_FUNCL_CURR
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'NONREC_TAX', REC_NREC_TAX_AMT_TAX_CURR, NULL)   -- NREC_TAX_AMT_TAX_CURR
 	 	  -- ,NULL                                            -- OFFSET_LINK_TO_TAX_LINE_ID
 	 	  -- ,NULL                                            -- OFFSET_TAX_RATE_CODE
 	 	  -- ,NULL                                            -- ORIG_TAX_AMT
 	 	  -- ,NULL                                            -- ORIG_TAX_AMT_TAX_CURR
 	 	  -- ,NULL                                            -- ORIG_TAX_RATE
 	 	  -- ,NULL                                            -- ORIG_TAX_RATE_CODE
 	 	  -- ,NULL                                            -- ORIG_TAX_RATE_ID
 	 	  -- ,NULL                                            -- ORIG_TAX_STATUS_CODE
 	 	  -- ,NULL                                            -- ORIG_TAX_STATUS_ID
 	 	  -- ,NULL                                            -- ORIG_TAXABLE_AMT
 	 	  -- ,NULL                                            -- ORIG_TAXABLE_AMT_TAX_CURR
 	 	  -- ,NULL                                            -- OTHER_DOC_LINE_AMT
 	 	  -- ,NULL                                            -- OTHER_DOC_LINE_TAX_AMT
 	 	  -- ,NULL                                            -- OTHER_DOC_LINE_TAXABLE_AMT
 	 	  -- ,NULL                                            -- OTHER_DOC_SOURCE
 	 	  -- ,NULL                                            -- PRORATION_CODE
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'REC_TAX', REC_NREC_TAX_AMT, NULL)               -- REC_TAX_AMT
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'REC_TAX', REC_NREC_TAX_AMT_FUNCL_CURR, NULL)    -- REC_TAX_AMT_FUNCL_CURR
 	 	  ,DECODE(AP_DIST_LOOKUP_CODE,
 	 	     'REC_TAX', REC_NREC_TAX_AMT_TAX_CURR, NULL)      -- REC_TAX_AMT_TAX_CURR
 	 	  -- ,REF_DOC_LINE_QUANTITY
 	 	  -- ,RELATED_DOC_APPLICATION_ID
 	 	  -- ,RELATED_DOC_DATE
 	 	  -- ,RELATED_DOC_ENTITY_CODE
 	 	  -- ,RELATED_DOC_EVENT_CLASS_CODE
 	 	  -- ,RELATED_DOC_NUMBER
 	 	  -- ,RELATED_DOC_TRX_ID
 	 	  -- ,RELATED_DOC_TRX_LEVEL_TYPE
 	 	  -- ,NULL                                            -- REPORTING_CURRENCY_CODE
                  ,TAX_AMT
 	 	  ,TAX_AMT_FUNCL_CURR
 	 	  ,TAX_AMT_TAX_CURR
 	 	  ,'STANDARD_TC'
 	 	  -- ,NULL                                            -- TAX_CODE
 	 	  ,TAX_DATE
 	 	  ,TAX_DETERMINE_DATE
 	 	  ,TAX_POINT_DATE
 	 	  -- ,NULL                                            -- TAX_TYPE_CODE
 	 	  -- ,ROUNDING_RULE_CODE
 	 	  ,TAXABLE_AMT
 	 	  ,TAXABLE_AMT_FUNCL_CURR
 	 	  ,TAXABLE_AMT_TAX_CURR
 	 	  ,'STANDARD_TB'                                      -- TAXABLE_BASIS_FORMULA
 	 	  ,TRX_DATE
 	 	  ,TRX_LINE_DATE
 	 	  ,TRX_LINE_QUANTITY
 	 	  -- ,NULL                                            -- UNROUNDED_TAX_AMT
 	 	  -- ,NULL                                            -- UNROUNDED_TAXABLE_AMT
 	 	  ,HISTORICAL_FLAG
 	 	  ,OVERRIDDEN_FLAG
 	 	  ,SELF_ASSESSED_FLAG
 	 	  ,TAX_APPORTIONMENT_FLAG
 	 	  ,TAX_ONLY_LINE_FLAG
 	 	  ,TAX_AMT_INCLUDED_FLAG
 	 	  ,'N'                                                -- MRC_TAX_LINE_FLAG
 	 	  ,OFFSET_FLAG                                        -- Bug 8303411
 	 	  ,'N'                                                -- PROCESS_FOR_RECOVERY_FLAG
 	 	  ,COMPOUNDING_TAX_FLAG
 	 	  ,'N'                                                -- ORIG_TAX_AMT_INCLUDED_FLAG
 	 	  ,'N'                                                -- ORIG_SELF_ASSESSED_FLAG
 	 	  ,CANCEL_FLAG
 	 	  ,'N'                                                -- PURGE_FLAG
 	 	  ,'N'                                                -- DELETE_FLAG
 	 	  ,MANUALLY_ENTERED_FLAG
		  --,LAST_MANUAL_ENTRY  --BUG7146063
 	 	  ,'N'                                                -- REPORTING_ONLY_FLAG
 	 	  ,'N'                                                -- FREEZE_UNTIL_OVERRIDDEN_FLAG
 	 	  ,'N'                                                -- COPIED_FROM_OTHER_DOC_FLAG
 	 	  ,'N'                                                -- RECALC_REQUIRED_FLAG
 	 	  ,'N'                                                -- SETTLEMENT_FLAG
 	 	  ,'N'                                                -- ITEM_DIST_CHANGED_FLAG
 	 	  ,'N'                                                -- ASSOCIATED_CHILD_FROZEN_FLAG
 	 	  ,'N'                                                -- COMPOUNDING_DEP_TAX_FLAG
 	 	  ,'N'                                                -- ENFORCE_FROM_NATURAL_ACCT_FLAG
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
 	 	  ,LAST_MANUAL_ENTRY
		  ,LEGAL_ENTITY_ID
		  -- ,ESTABLISHMENT_ID
 	 	  ,CREATED_BY
 	 	  ,CREATION_DATE
 	 	  ,LAST_UPDATE_DATE
 	 	  ,LAST_UPDATE_LOGIN
 	  	  ,LAST_UPDATED_BY
 	  	  ,OBJECT_VERSION_NUMBER
		  ,MULTIPLE_JURISDICTIONS_FLAG
		  ,LEGAL_REPORTING_STATUS
                  ,ACCOUNT_SOURCE_TAX_RATE_ID
		 )
(SELECT /*+ ROWID(inv) NO_EXPAND ORDERED
            use_nl(fnd_curr,ap_dists,ap_dists1,lines1,rates,regimes,taxes,status,ptp)
            index(taxes,ZX_TAXES_B_U2) */
        NVL(lines1.org_id,-99)                                        INTERNAL_ORGANIZATION_ID
        ,200			   				      APPLICATION_ID
        ,'AP_INVOICES'		   				      ENTITY_CODE
        ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE   ,
                'STANDARD', 'STANDARD INVOICES'    ,
		'CREDIT'  , 'STANDARD INVOICES',   --Bug 6489409
	        'DEBIT'   , 'STANDARD INVOICES',   --Bug 6489409
		'MIXED'   , 'STANDARD INVOICES',   --Bug 6489409
		'ADJUSTMENT','STANDARD INVOICES',  --Bug 6489409
		'PO PRICE ADJUST','STANDARD INVOICES', --Bug 6489409
		'INVOICE REQUEST','STANDARD INVOICES', --Bug 6489409
		'CREDIT MEMO REQUEST','STANDARD INVOICES',--Bug 6489409
 		'RETAINAGE RELEASE'  ,'STANDARD INVOICES',--Bug 6489409
                'PREPAYMENT','PREPAYMENT INVOICES' ,
                'EXPENSE REPORT','EXPENSE REPORTS' ,
                'INTEREST INVOICE','INTEREST INVOICES','NA')	      EVENT_CLASS_CODE
        ,DECODE(inv.INVOICE_TYPE_LOOKUP_CODE,
                'STANDARD','STANDARD INVOICE CREATED',
                'PREPAYMENT','PREPAYMENT INVOICE CREATED',
                'EXPENSE REPORT','EXPENSE REPORT CREATED',
                'INTEREST INVOICE','INTEREST INVOICE CREATED','NA')   EVENT_TYPE_CODE
        ,(CASE WHEN inv.invoice_type_lookup_code in
         	   ('ADJUSTMENT','CREDIT','DEBIT','INTEREST',
         		'MIXED','QUICKDEFAULT','PO PRICE ADJUST',
         		'QUICKMATCH','STANDARD','AWT')
         		  THEN 'PURCHASE_TRANSACTION'
         		  WHEN (inv.invoice_type_lookup_code =
         				'PREPAYMENT')
         		  THEN  'PURCHASE_PREPAYMENTTRANSACTION'
         		  WHEN  (inv.invoice_type_lookup_code =
         				'EXPENSE REPORT')
         		  THEN  'EXPENSE_REPORT'
         		  ELSE   NULL
          END)                      				      TAX_EVENT_CLASS_CODE
        ,'VALIDATE'                  				      TAX_EVENT_TYPE_CODE
        -- ,NULL					              DOC_EVENT_STATUS
        ,lines1.invoice_id 				              TRX_ID
        ,NVL(inv.invoice_date,sysdate)			   	      TRX_DATE
        ,inv.invoice_currency_code                    	              TRX_CURRENCY_CODE
        ,NVL(inv.legal_entity_id, -99)               	              LEGAL_ENTITY_ID
        -- ,NULL						      ESTABLISHMENT_ID
        ,inv.invoice_num                              	              TRX_NUMBER
        -- ,DECODE(ap_dists.charge_applicable_to_dist_id,NULL,1,
        ,(RANK() OVER (PARTITION BY inv.invoice_id ORDER BY
                     ap_dists1.invoice_line_number,
                     ap_dists.invoice_distribution_id))	              TAX_LINE_NUMBER
        ,lines1.accounting_date                        	              TRX_LINE_DATE
        ,NVL(lines1.amount,0)                                 	      LINE_AMT
        ,NVL(lines1.quantity_invoiced, 0)                     	      TRX_LINE_QUANTITY
        ,lines1.UNIT_PRICE                             	              UNIT_PRICE
        -- ,NULL                                         	      RELATED_DOC_APPLICATION_ID
        -- ,NULL                                         	      RELATED_DOC_ENTITY_CODE
        -- ,NULL                                         	      RELATED_DOC_EVENT_CLASS_CODE
        -- ,NULL                                         	      RELATED_DOC_TRX_ID
        -- ,NULL                                                      RELATED_DOC_TRX_LEVEL_TYPE
        -- ,NULL                                         	      RELATED_DOC_NUMBER
        -- ,NULL                                         	      RELATED_DOC_DATE
        ,DECODE(lines1.prepay_invoice_id, NULL, NULL, 200)            APPLIED_FROM_APPLICATION_ID
        ,DECODE(lines1.prepay_invoice_id, NULL, NULL,
                'AP_INVOICES')                                        APPLIED_FROM_ENTITY_CODE
        ,DECODE(lines1.prepay_invoice_id, NULL, NULL,
                'PREPAYMENT INVOICES')                                APPLIED_FROM_EVENT_CLASS_CODE
        ,lines1.prepay_invoice_id                      	              APPLIED_FROM_TRX_ID
        ,lines1.prepay_line_number                    	              APPLIED_FROM_LINE_ID
        -- ,NULL						      APPLIED_FROM_TRX_NUMBER
        ,DECODE(lines1.corrected_inv_id, NULL, NULL, 200)             ADJUSTED_DOC_APPLICATION_ID
        ,DECODE(lines1.corrected_inv_id, NULL, NULL,
                'AP_INVOICES')                                        ADJUSTED_DOC_ENTITY_CODE
        ,DECODE(lines1.corrected_inv_id, NULL, NULL,
                'STANDARD INVOICES')                                  ADJUSTED_DOC_EVENT_CLASS_CODE
        ,lines1.corrected_inv_id                       	              ADJUSTED_DOC_TRX_ID
        ,lines1.Corrected_Line_Number                  	              ADJUSTED_DOC_LINE_ID
        -- ,NULL                                         	      ADJUSTED_DOC_NUMBER
        -- ,NULL                                         	      ADJUSTED_DOC_DATE
        ,DECODE(lines1.rcv_transaction_id, NULL, NULL, 707) 	      APPLIED_TO_APPLICATION_ID
        ,DECODE(lines1.rcv_transaction_id, NULL, NULL,
                'RCV_ACCOUNTING_EVENTS')                              APPLIED_TO_ENTITY_CODE
        ,DECODE(lines1.rcv_transaction_id, NULL, NULL,
                'RCPT_REC_INSP')                      	              APPLIED_TO_EVENT_CLASS_CODE
        ,lines1.rcv_transaction_id                           	      APPLIED_TO_TRX_ID
        ,lines1.rcv_shipment_line_id                         	      APPLIED_TO_LINE_ID
        -- ,NULL                                         	      APPLIED_TO_TRX_NUMBER
        ,DECODE(NVL(lines1.po_release_id,lines1.po_header_id),
                 NULL, NULL, 'SHIPMENT')                     	      REF_DOC_TRX_LEVEL_TYPE
        ,NVL(lines1.po_release_id, lines1.po_header_id)  	      REF_DOC_TRX_ID
        ,lines1.po_line_location_id                    	              REF_DOC_LINE_ID
        -- ,NULL                                         	      REF_DOC_LINE_QUANTITY
        ,DECODE(lines1.rcv_transaction_id, NULL, NULL,
                'LINE')                                     	      APPLIED_TO_TRX_LEVEL_TYPE
        ,DECODE(lines1.prepay_invoice_id, NULL, NULL,
                'LINE')                                     	      APPLIED_FROM_TRX_LEVEL_TYPE
        ,DECODE(lines1.corrected_inv_id, NULL, NULL,
                'LINE')                                	              ADJUSTED_DOC_TRX_LEVEL_TYPE
        -- ,NULL 						      INTERNAL_ORG_LOCATION_ID
        ,'MIGRATED' 					              RECORD_TYPE_CODE
        ,lines1.ASSESSABLE_VALUE                       	              -- ASSESSABLE_VALUE
        ,'N'                                          	              TAX_AMT_INCLUDED_FLAG
        ,'N'                                          	              COMPOUNDING_TAX_FLAG
        ,DECODE(taxes.tax_type_code,'OFFSET','Y','N')                 OFFSET_FLAG --Bug 8303411
        ,ap_dists.DETAIL_TAX_DIST_ID   			              REC_NREC_TAX_DIST_ID
        ,ap_dists.line_type_lookup_code                	              AP_DIST_LOOKUP_CODE
         -- DECODE(ap_dists.charge_applicable_to_dist_id, NULL, 1,
        ,RANK() OVER (PARTITION BY inv.invoice_id,
                      ap_dists.charge_applicable_to_dist_id
                      ORDER BY
                      ap_dists.line_type_lookup_code desc,
                      ap_dists.invoice_distribution_id)               REC_NREC_TAX_DIST_NUMBER
        ,ptp.party_tax_profile_id                                     CONTENT_OWNER_ID
        ,inv.exchange_date 				            CURRENCY_CONVERSION_DATE
        ,inv.exchange_rate     				        CURRENCY_CONVERSION_RATE
        ,inv.exchange_rate_type  				      CURRENCY_CONVERSION_TYPE
        ,ap_dists.set_of_books_id 				      AP_LEDGER_ID
        ,fnd_curr.minimum_accountable_unit   			      MINIMUM_ACCOUNTABLE_UNIT
        ,NVL(fnd_curr.precision, 0)                  		      PRECISION
        ,DECODE(NVL(lines1.po_release_id, lines1.po_header_id),
                 NULL, NULL, 201)		                      REF_DOC_APPLICATION_ID
        ,DECODE(lines1.po_release_id, NULL,
                 DECODE(lines1.po_header_id, NULL, NULL,
                        'PURCHASE_ORDER'), 'RELEASE')                 REF_DOC_ENTITY_CODE
        ,DECODE(lines1.po_release_id, NULL,
                 DECODE(lines1.po_header_id, NULL, NULL,
                        'PO_PA'), 'RELEASE')                          REF_DOC_EVENT_CLASS_CODE
        ,ap_dists.summary_tax_line_id 				      SUMMARY_TAX_LINE_ID
        ,rates.TAX 						      TAX
        -- ,DECODE(ap_dists.charge_applicable_to_dist_id,NULL,1,
        ,RANK() OVER (PARTITION BY inv.invoice_id,
                       ap_dists1.invoice_line_number,
                       rates.tax_regime_code, rates.tax
                       ORDER BY
                       ap_dists.invoice_distribution_id)	      TAX_APPORTIONMENT_LINE_NUMBER
        ,taxes.tax_currency_code                                      -- TAX_CURRENCY_CODE
        ,inv.exchange_date             			      TAX_CURRENCY_CONVERSION_DATE
        ,inv.exchange_rate             			      TAX_CURRENCY_CONVERSION_RATE
        ,inv.exchange_rate_type        			      TAX_CURRENCY_CONVERSION_TYPE
        ,taxes.tax_id                                                 -- TAX_ID
        ,rates.percentage_rate 				              TAX_RATE
        ,rates.tax_rate_code 					      -- TAX_RATE_CODE
        ,rates.tax_rate_id 				              -- TAX_RATE_ID
        ,rates.tax_regime_code 				              -- TAX_REGIME_CODE
        ,regimes.tax_regime_id				              -- TAX_REGIME_ID
        ,rates.tax_status_code 				              -- TAX_STATUS_CODE
        ,status.tax_status_id					      -- TAX_STATUS_ID
        ,'LINE'						              TRX_LEVEL_TYPE
        ,lines1.line_number                                           TRX_LINE_ID
        ,lines1.line_number                                           TRX_LINE_NUMBER
        ,ap_dists.dist_code_combination_id  			      ACCOUNT_CCID
        -- ,NULL 						      ACCOUNT_STRING
        -- ,NULL 						      ADJUSTED_DOC_TAX_DIST_ID
        -- ,NULL 						      APPLIED_FROM_TAX_DIST_ID
        -- ,NULL 						      APPLIED_TO_DOC_CURR_CONV_RATE
        ,ap_dists.award_id  					      -- AWARD_ID
        ,ap_dists.expenditure_item_date  			      -- EXPENDITURE_ITEM_DATE
        ,ap_dists.expenditure_organization_id  		              -- EXPENDITURE_ORGANIZATION_ID
        ,ap_dists.expenditure_type          			      -- EXPENDITURE_TYPE
        ,NULL 						              FUNC_CURR_ROUNDING_ADJUSTMENT
        ,ap_dists.ACCOUNTING_DATE 				      GL_DATE
        ,ap_dists.intended_use 				              -- INTENDED_USE
        ,ap_dists1.distribution_line_number                           ITEM_DIST_NUMBER
        -- ,NULL 						      MRC_LINK_TO_TAX_DIST_ID
        -- ,NULL 						      ORIG_REC_NREC_RATE
        -- ,NULL 						      ORIG_REC_NREC_TAX_AMT
        -- ,NULL 						      ORIG_REC_NREC_TAX_AMT_TAX_CURR
        -- ,NULL 						      ORIG_REC_RATE_CODE
        -- ,NULL 						      PER_TRX_CURR_UNIT_NR_AMT
        -- ,NULL 						      PER_UNIT_NREC_TAX_AMT
        -- ,NULL 						      PRD_TAX_AMT
        -- ,NULL 						      PRICE_DIFF
        ,ap_dists.project_id  				              -- PROJECT_ID
        -- ,NULL 						      QTY_DIFF
        -- ,NULL 						      RATE_TAX_FACTOR
        --,NVL(ap_dists.rec_nrec_rate, 0)                             REC_NREC_RATE
        ,100                                                          REC_NREC_RATE
        ,NVL(ap_dists.amount,0)             			      REC_NREC_TAX_AMT
        ,ap_dists.base_amount        				      REC_NREC_TAX_AMT_FUNCL_CURR
        ,ap_dists.base_amount        				      REC_NREC_TAX_AMT_TAX_CURR
        ,DECODE(ap_dists.line_type_lookup_code,
               'REC_TAX', 'AD_HOC_RECOVERY', NULL)                    RECOVERY_RATE_CODE
        ,DECODE(ap_dists.line_type_lookup_code,
               'REC_TAX', 'STANDARD', NULL)                           RECOVERY_TYPE_CODE
        ,NVL(ap_dists.amount,0)             			      TAX_AMT
        ,ap_dists.base_amount        				      TAX_AMT_FUNCL_CURR
        ,ap_dists.base_amount        				      TAX_AMT_TAX_CURR
        -- ,NULL 						      RECOVERY_TYPE_ID
        -- ,NULL 						      REF_DOC_CURR_CONV_RATE
        ,ap_dists1.po_distribution_id                                 REF_DOC_DIST_ID
        -- ,NULL 						      REF_DOC_PER_UNIT_NREC_TAX_AMT
        -- ,NULL 						      REF_DOC_TAX_DIST_ID
        -- ,NULL 						      REF_DOC_TRX_LINE_DIST_QTY
        -- ,NULL 						      REF_DOC_UNIT_PRICE
        -- ,NULL 						      REF_PER_TRX_CURR_UNIT_NR_AMT
        ,ap_dists.parent_reversal_id				      REVERSED_TAX_DIST_ID
        -- ,NULL 						      ROUNDING_RULE_CODE
        ,ap_dists.task_id  					      -- TASK_ID
        ,ap_dists.taxable_base_amount 			              TAXABLE_AMT_FUNCL_CURR
        ,ap_dists.taxable_base_amount 			              TAXABLE_AMT_TAX_CURR
        ,ap_dists1.amount					      TRX_LINE_DIST_AMT
        ,ap_dists1.invoice_distribution_id 			      TRX_LINE_DIST_ID
        ,NVL(ap_dists1.quantity_invoiced, 0)			      TRX_LINE_DIST_QTY
        ,DECODE(ap_dists.charge_applicable_to_dist_id, NULL,
                ap_dists.amount,
                SUM (ap_dists.amount) OVER
                    (PARTITION BY ap_dists.invoice_id,
                     ap_dists.charge_applicable_to_dist_id))	      TRX_LINE_DIST_TAX_AMT
        -- ,NULL 						      UNROUNDED_REC_NREC_TAX_AMT
        -- ,NULL 						      UNROUNDED_TAXABLE_AMT
        ,ap_dists.TAXABLE_AMOUNT 				      TAXABLE_AMT
        ,ap_dists.ATTRIBUTE_CATEGORY  			              -- ATTRIBUTE_CATEGORY
        ,ap_dists.ATTRIBUTE1       				      -- ATTRIBUTE1
        ,ap_dists.ATTRIBUTE2       				      -- ATTRIBUTE2
        ,ap_dists.ATTRIBUTE3       				      -- ATTRIBUTE3
        ,ap_dists.ATTRIBUTE4       				      -- ATTRIBUTE4
        ,ap_dists.ATTRIBUTE5       				      -- ATTRIBUTE5
        ,ap_dists.ATTRIBUTE6       				      -- ATTRIBUTE6
        ,ap_dists.ATTRIBUTE7       				      -- ATTRIBUTE7
        ,ap_dists.ATTRIBUTE8       				      -- ATTRIBUTE8
        ,ap_dists.ATTRIBUTE9       				      -- ATTRIBUTE9
        ,ap_dists.ATTRIBUTE10      				      -- ATTRIBUTE10
        ,ap_dists.ATTRIBUTE11      				      -- ATTRIBUTE11
        ,ap_dists.ATTRIBUTE12      				      -- ATTRIBUTE12
        ,ap_dists.ATTRIBUTE13      				      -- ATTRIBUTE13
        ,ap_dists.ATTRIBUTE14      				      -- ATTRIBUTE14
        ,ap_dists.ATTRIBUTE15      				      -- ATTRIBUTE15
        ,ap_dists.GLOBAL_ATTRIBUTE_CATEGORY 			      -- GLOBAL_ATTRIBUTE_CATEGORY
        ,ap_dists.GLOBAL_ATTRIBUTE1         			      -- GLOBAL_ATTRIBUTE1
        ,ap_dists.GLOBAL_ATTRIBUTE2         			      -- GLOBAL_ATTRIBUTE2
        ,ap_dists.GLOBAL_ATTRIBUTE3         			      -- GLOBAL_ATTRIBUTE3
        ,ap_dists.GLOBAL_ATTRIBUTE4         			      -- GLOBAL_ATTRIBUTE4
        ,ap_dists.GLOBAL_ATTRIBUTE5         			      -- GLOBAL_ATTRIBUTE5
        ,ap_dists.GLOBAL_ATTRIBUTE6         			      -- GLOBAL_ATTRIBUTE6
        ,ap_dists.GLOBAL_ATTRIBUTE7         			      -- GLOBAL_ATTRIBUTE7
        ,ap_dists.GLOBAL_ATTRIBUTE8         			      -- GLOBAL_ATTRIBUTE8
        ,ap_dists.GLOBAL_ATTRIBUTE9         			      -- GLOBAL_ATTRIBUTE9
        ,ap_dists.GLOBAL_ATTRIBUTE10        			      -- GLOBAL_ATTRIBUTE10
        ,ap_dists.GLOBAL_ATTRIBUTE11        			      -- GLOBAL_ATTRIBUTE11
        ,ap_dists.GLOBAL_ATTRIBUTE12        			      -- GLOBAL_ATTRIBUTE12
        ,ap_dists.GLOBAL_ATTRIBUTE13        			      -- GLOBAL_ATTRIBUTE13
        ,ap_dists.GLOBAL_ATTRIBUTE14        			      -- GLOBAL_ATTRIBUTE14
        ,ap_dists.GLOBAL_ATTRIBUTE15        			      -- GLOBAL_ATTRIBUTE15
        ,ap_dists.GLOBAL_ATTRIBUTE16        			      -- GLOBAL_ATTRIBUTE16
        ,ap_dists.GLOBAL_ATTRIBUTE17        			      -- GLOBAL_ATTRIBUTE17
        ,ap_dists.GLOBAL_ATTRIBUTE18        			      -- GLOBAL_ATTRIBUTE18
        ,ap_dists.GLOBAL_ATTRIBUTE19        			      -- GLOBAL_ATTRIBUTE19
        ,ap_dists.GLOBAL_ATTRIBUTE20        			      -- GLOBAL_ATTRIBUTE20
        ,'Y'                                			      HISTORICAL_FLAG
        ,'N'                                			      OVERRIDDEN_FLAG
        ,'N'                                			      SELF_ASSESSED_FLAG
        ,'Y'                                			      TAX_APPORTIONMENT_FLAG
        ,DECODE(ap_dists.charge_applicable_to_dist_id,
                 NULL, 'Y', 'N')				      TAX_ONLY_LINE_FLAG
        ,'N'                                			      INCLUSIVE_FLAG
        ,'N'                                			      MRC_TAX_DIST_FLAG
        ,'N'                                			      REC_TYPE_RULE_FLAG
        ,'N'                                			      NEW_REC_RATE_CODE_FLAG
        ,NVL(ap_dists.tax_recoverable_flag, 'N')      		      RECOVERABLE_FLAG
        ,ap_dists.reversal_flag				              REVERSE_FLAG
        ,'N'                                			      REC_RATE_DET_RULE_FLAG
        ,'N'                                			      BACKWARD_COMPATIBILITY_FLAG
        ,'N'                                			      FREEZE_FLAG
        ,DECODE(ap_dists.posted_flag, 'Y', 'A', NULL)  	              POSTING_FLAG
        ,NVL(lines1.accounting_date,
              NVL(inv.invoice_date, sysdate))                         TAX_DATE
        ,NVL(lines1.accounting_date,
              NVL(inv.invoice_date, sysdate))                         TAX_DETERMINE_DATE
        ,NVL(lines1.accounting_date,
              NVL(inv.invoice_date, sysdate))                         TAX_POINT_DATE
        ,1                					      CREATED_BY
        ,SYSDATE                            			      CREATION_DATE
        --,NULL                               			      LAST_MANUAL_ENTRY
        ,SYSDATE                            			      LAST_UPDATE_DATE
        ,1           						      LAST_UPDATE_LOGIN
        ,1                					      LAST_UPDATED_BY
        ,1							      OBJECT_VERSION_NUMBER
        ,ap_dists1.old_dist_line_number                               ORIG_AP_CHRG_DIST_NUM
        ,ap_dists1.old_distribution_id                                ORIG_AP_CHRG_DIST_ID
        ,ap_dists.old_dist_line_number                                ORIG_AP_TAX_DIST_NUM
        ,ap_dists.old_distribution_id                                 ORIG_AP_TAX_DIST_ID
        ,'N'                                  		              MULTIPLE_JURISDICTIONS_FLAG
        ,DECODE(ap_dists.posted_flag, 'Y', '111111111111111',
                                      'P', '111111111111111',
                                           '000000000000000')         LEGAL_REPORTING_STATUS
        ,DECODE(lines.discarded_flag, 'Y', 'Y', 'N')                 CANCEL_FLAG
        ,NVL(rates.def_rec_settlement_option_code,
             taxes.def_rec_settlement_option_code)                    DEF_REC_SETTLEMENT_OPTION_CODE
        --,TAX_JURISDICTION_ID
        ,rates.tax_rate_id                                            ACCOUNT_SOURCE_TAX_RATE_ID
        ,(SELECT tax_rate_id FROM zx_rates_b
          WHERE tax_rate_code = 'AD_HOC_RECOVERY'
          AND rate_type_code = 'RECOVERY'
          AND tax_regime_code = rates.tax_regime_code
          AND tax = rates.tax
          AND content_owner_id = ptp.party_tax_profile_id
	  AND record_type_code = 'MIGRATED'
	  AND tax_class = 'INPUT')                          RECOVERY_RATE_ID
        ,DECODE(lines.line_source,'MANUAL LINE ENTRY','Y','N')   MANUALLY_ENTERED_FLAG   --BUG7146063
        ,DECODE(lines.line_source,'MANUAL LINE ENTRY','TAX_AMOUNT',NULL)   LAST_MANUAL_ENTRY   --BUG7146063
   FROM ( select distinct other_doc_application_id,other_doc_trx_id from ZX_VALIDATION_ERRORS_GT ) zxvalerr, --Bug 5187701
        ap_invoices_all inv,
        fnd_currencies fnd_curr,
        -- fnd_document_sequences fds,
        ap_invoice_distributions_all ap_dists,
        ap_invoice_distributions_all ap_dists1,
        ap_invoice_lines_all lines1,
        ap_invoice_lines_all lines,
        zx_rates_b rates,
        zx_regimes_b regimes,
        zx_taxes_b taxes,
        zx_status_b status,
        zx_party_tax_profile ptp
  WHERE zxvalerr.other_doc_application_id = 200
    AND inv.invoice_id = zxvalerr.other_doc_trx_id
    AND fnd_curr.currency_code = inv.invoice_currency_code
    --  AND inv.doc_sequence_id = fds.doc_sequence_id(+)
    AND ap_dists.invoice_id = inv.invoice_id
    AND ap_dists.line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
    AND NVL(ap_dists.historical_flag, 'N') = 'Y'
    --  AND ap_dists1.invoice_id = ap_dists.invoice_id
    AND ap_dists1.invoice_distribution_id = NVL(ap_dists.charge_applicable_to_dist_id,
                                                ap_dists.invoice_distribution_id)
    AND lines1.invoice_id = ap_dists1.invoice_id
    AND lines1.line_number = ap_dists1.invoice_line_number
    AND NVL(lines1.historical_flag, 'N') = 'Y'
    AND lines.invoice_id = ap_dists.invoice_id
    AND lines.line_number = ap_dists.invoice_line_number
    AND NVL(lines.historical_flag, 'N') = 'Y'
    AND rates.source_id(+) = ap_dists.tax_code_id
    AND regimes.tax_regime_code(+) = rates.tax_regime_code
    AND taxes.tax_regime_code(+) = rates.tax_regime_code
    AND taxes.tax(+) = rates.tax
    AND taxes.content_owner_id(+) = rates.content_owner_id
    AND status.tax_regime_code(+) = rates.tax_regime_code
    AND status.tax(+) = rates.tax
    AND status.tax_status_code(+) = rates.tax_status_code
    AND status.content_owner_id(+) = rates.content_owner_id
    -- AND NVL(taxes.effective_from,
    --         NVL(lines1.accounting_date, NVL(inv.invoice_date, sysdate)))
    --       <= NVL(lines1.accounting_date, NVL(inv.invoice_date, sysdate))
    -- AND (NVL(taxes.effective_to,
    --         NVL(lines1.accounting_date,
    --             NVL(inv.invoice_date, sysdate)) )
    --        >= NVL(lines1.accounting_date, NVL(inv.invoice_date, sysdate))
    --      OR taxes.effective_to IS NULL)
    AND ptp.party_type_code = 'OU'
    AND ptp.party_id = DECODE(l_multi_org_flag,'N', l_org_id, ap_dists.org_id));

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap.END',
                   'ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap(+)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap',
                     sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
      FND_LOG.STRING(g_level_unexpected,
                    'ZX.PLSQL.ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap.END',
                    'ZX_ON_FLY_TRX_UPGRADE_AP_PKG.upgrade_trx_on_fly_blk_ap(-)');
    END IF;

END upgrade_trx_on_fly_blk_ap;

END ZX_ON_FLY_TRX_UPGRADE_AP_PKG;


/
