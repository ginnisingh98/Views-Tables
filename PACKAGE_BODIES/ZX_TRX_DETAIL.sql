--------------------------------------------------------
--  DDL for Package Body ZX_TRX_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRX_DETAIL" AS
/* $Header: zxritsimdetailb.pls 120.50.12010000.1 2008/07/28 13:37:16 appldev ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  TYPE var1_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  trx_line_type_tab        var1_tab;

  PROCEDURE get_error_msg(
        p_trx_id                IN    NUMBER,
        p_application_id        IN    NUMBER,
        p_entity_code           IN    VARCHAR2,
        p_event_class_code      IN    VARCHAR2,
        p_return_status         IN    VARCHAR2,
        x_msg_data                OUT NOCOPY VARCHAR2);


  PROCEDURE perform_purge(
        p_count                IN     NUMBER,
        p_application_id_tbl   IN     APPLICATION_ID_TBL,
        p_entity_code_tbl      IN     ENTITY_CODE_TBL,
        p_event_class_code_tbl IN     EVENT_CLASS_CODE_TBL,
        p_trx_id_tbl           IN     TRX_ID_TBL,
        p_return_status           OUT NOCOPY VARCHAR2,
        p_error_buffer            OUT NOCOPY VARCHAR2);

  PROCEDURE Insert_row
       (p_Rowid                      IN OUT NOCOPY VARCHAR2,
        p_internal_organization_id     NUMBER,
        p_internal_org_location_id     NUMBER,
        p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_trx_date                     DATE,
        p_trx_doc_revision             VARCHAR2,
        p_ledger_id                    NUMBER,
        p_trx_currency_code            VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_rate     NUMBER,
        p_currency_conversion_type     VARCHAR2,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER,
        p_legal_entity_id              NUMBER,
        p_rounding_ship_to_party_id    NUMBER,
        p_rounding_ship_from_party_id  NUMBER,
        p_rounding_bill_to_party_id    NUMBER,
        p_rounding_bill_from_party_id  NUMBER,
        p_rndg_ship_to_party_site_id   NUMBER,
        p_rndg_ship_from_pty_site_id   NUMBER,  --reduced size p_rndg_ship_from_party_site_id
        p_rndg_bill_to_party_site_id   NUMBER,
        p_rndg_bill_from_pty_site_id   NUMBER,  --reduced size p_rndg_bill_from_party_site_id
        p_establishment_id             NUMBER,
        p_related_doc_application_id   NUMBER,
        p_related_doc_entity_code      VARCHAR2,
        p_related_doc_evt_class_code   VARCHAR2,  --reduced size p_related_doc_event_class_code
        p_related_doc_trx_id           NUMBER,
        p_related_doc_number           VARCHAR2,
        p_related_doc_date             DATE,
        p_default_taxation_country     VARCHAR2,
        p_quote_flag                   VARCHAR2,
        p_trx_number                   VARCHAR2,
        p_trx_description              VARCHAR2,
        p_trx_communicated_date        DATE,
        p_batch_source_id              NUMBER,
        p_batch_source_name            VARCHAR2,
        --p_doc_seq_id                   NUMBER,
        --p_doc_seq_name                 VARCHAR2,
        --p_doc_seq_value                VARCHAR2,
        p_trx_due_date                 DATE,
        p_trx_type_description         VARCHAR2,
        p_billing_trad_partner_name    VARCHAR2,  --reduced size p_billing_trading_partner_name
        p_billing_trad_partner_number  VARCHAR2,  --reduced size p_billing_trading_partner_number
        p_billing_tp_tax_report_flg    VARCHAR2,  --reduced size p_Billing_Tp_Tax_Reporting_Flag
        p_billing_tp_taxpayer_id       VARCHAR2,
        p_document_sub_type            VARCHAR2,
        p_supplier_tax_invoice_number  VARCHAR2,
        p_supplier_tax_invoice_date    DATE,--
        p_supplier_exchange_rate       NUMBER,
        p_tax_invoice_date             DATE,
        p_tax_invoice_number           VARCHAR2,
        p_tax_event_class_code         VARCHAR2,
        p_tax_event_type_code          VARCHAR2,
        p_doc_event_status             VARCHAR2,
        p_rdng_ship_to_pty_tx_prof_id  NUMBER,
        p_rdng_ship_fr_pty_tx_prof_id  NUMBER,  --reduced size p_rdng_ship_from_pty_tx_prof_id
        p_rdng_bill_to_pty_tx_prof_id  NUMBER,
        p_rdng_bill_fr_pty_tx_prof_id  NUMBER,  --reduced size p_rdng_bill_from_pty_tx_prof_id
        p_rdng_ship_to_pty_tx_p_st_id  NUMBER,
        p_rdng_ship_fr_pty_tx_p_st_id  NUMBER,  --reduced size p_rdng_ship_from_pty_tx_p_st_id
        p_rdng_bill_to_pty_tx_p_st_id  NUMBER,
        p_rdng_bill_fr_pty_tx_p_st_id  NUMBER,  --reduced size p_rdng_bill_from_pty_tx_p_st_id
        p_trx_level_type               VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_line_level_action            VARCHAR2,
        p_trx_shipping_date            DATE,
        p_trx_receipt_date             DATE,
        p_trx_line_type                VARCHAR2,
        p_trx_line_date                DATE,
        p_trx_business_category        VARCHAR2,
        p_line_intended_use            VARCHAR2,
        p_user_defined_fisc_class      VARCHAR2,
        p_line_amt                     NUMBER,
        p_trx_line_quantity            NUMBER,
        p_unit_price                   NUMBER,
        p_exempt_certificate_number    VARCHAR2,
        p_exempt_reason                VARCHAR2,
        p_cash_discount                NUMBER,
        p_volume_discount              NUMBER,
        p_trading_discount             NUMBER,
        p_transfer_charge              NUMBER,
        p_transportation_charge        NUMBER,
        p_insurance_charge             NUMBER,
        p_other_charge                 NUMBER,
        p_product_id                   NUMBER,
        p_product_fisc_classification  VARCHAR2,
        p_product_org_id               NUMBER,
        p_uom_code                     VARCHAR2,
        p_product_type                 VARCHAR2,
        p_product_code                 VARCHAR2,
        p_product_category             VARCHAR2,
        p_trx_sic_code                 VARCHAR2,
        p_fob_point                    VARCHAR2,
        p_ship_to_party_id             NUMBER,
        p_ship_from_party_id           NUMBER,
        p_poa_party_id                 NUMBER,
        p_poo_party_id                 NUMBER,
        p_bill_to_party_id             NUMBER,
        p_bill_from_party_id           NUMBER,
        p_merchant_party_id            NUMBER,
        p_ship_to_party_site_id        NUMBER,
        p_ship_from_party_site_id      NUMBER,
        p_poa_party_site_id            NUMBER,
        p_poo_party_site_id            NUMBER,
        p_bill_to_party_site_id        NUMBER,
        p_bill_from_party_site_id      NUMBER,
        p_ship_to_location_id          NUMBER,
        p_ship_from_location_id        NUMBER,
        p_poa_location_id              NUMBER,
        p_poo_location_id              NUMBER,
        p_bill_to_location_id          NUMBER,
        p_bill_from_location_id        NUMBER,
        p_account_ccid                 NUMBER,
        p_account_string               VARCHAR2,
        p_merchant_party_country       VARCHAR2,
        p_ref_doc_application_id       NUMBER,
        p_ref_doc_entity_code          VARCHAR2,
        p_ref_doc_event_class_code     VARCHAR2,
        p_ref_doc_trx_id               NUMBER,
        p_ref_doc_line_id              NUMBER,
        p_ref_doc_line_quantity        NUMBER,
        p_applied_from_application_id  NUMBER,
        p_applied_from_entity_code     VARCHAR2,
        p_applied_from_evt_class_code  VARCHAR2,  --reduced size p_applied_from_event_class_code
        p_applied_from_trx_id          NUMBER,
        p_applied_from_line_id         NUMBER,
        p_adjusted_doc_application_id  NUMBER,
        p_adjusted_doc_entity_code     VARCHAR2,
        p_adj_doc_event_class_code     VARCHAR2,  --reduced size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id          NUMBER,
        p_adjusted_doc_line_id         NUMBER,
        p_adjusted_doc_number          VARCHAR2,
        p_adjusted_doc_date            DATE,
        p_applied_to_application_id    NUMBER,
        p_applied_to_entity_code       VARCHAR2,
        p_applied_to_event_class_code  VARCHAR2,
        p_applied_to_trx_id            NUMBER,
        p_applied_to_trx_line_id       NUMBER,
        p_trx_id_level2                NUMBER,
        p_trx_id_level3                NUMBER,
        p_trx_id_level4                NUMBER,
        p_trx_id_level5                NUMBER,
        p_trx_id_level6                NUMBER,
        p_trx_line_number              NUMBER,
        p_trx_line_description         VARCHAR2,
        p_product_description          VARCHAR2,
        p_trx_waybill_number           VARCHAR2,
        p_trx_line_gl_date             DATE,
        p_merchant_party_name          VARCHAR2,
        p_merchant_party_doc_number    VARCHAR2,  --reduced size p_merchant_party_document_number
        p_merchant_party_reference     VARCHAR2,
        p_merchant_party_taxpayer_id   VARCHAR2,
        p_merchant_pty_tax_reg_number  VARCHAR2,  --reduced size p_merchant_party_tax_reg_number
        p_paying_party_id              NUMBER,
        p_own_hq_party_id              NUMBER,
        p_trading_hq_party_id          NUMBER,
        p_poi_party_id                 NUMBER,
        p_pod_party_id                 NUMBER,
        p_title_transfer_party_id      NUMBER,
        p_paying_party_site_id         NUMBER,
        p_own_hq_party_site_id         NUMBER,
        p_trading_hq_party_site_id     NUMBER,
        p_poi_party_site_id            NUMBER,
        p_pod_party_site_id            NUMBER,
        p_title_transfer_pty_site_id   NUMBER,  --reduced size p_title_transfer_party_site_id
        p_paying_location_id           NUMBER,
        p_own_hq_location_id           NUMBER,
        p_trading_hq_location_id       NUMBER,
        p_poc_location_id              NUMBER,
        p_poi_location_id              NUMBER,
        p_pod_location_id              NUMBER,
        p_title_transfer_location_id   NUMBER,
        p_banking_tp_taxpayer_id       VARCHAR2,
        p_assessable_value             NUMBER,
        p_asset_flag                   VARCHAR2,
        p_asset_number                 VARCHAR2,
        p_asset_accum_depreciation     NUMBER,
        p_asset_type                   VARCHAR2,
        p_asset_cost                   NUMBER,
        p_ship_to_party_tax_prof_id    NUMBER,
        p_ship_from_party_tax_prof_id  NUMBER,
        p_poa_party_tax_prof_id        NUMBER,
        p_poo_party_tax_prof_id        NUMBER,
        p_paying_party_tax_prof_id     NUMBER,
        p_own_hq_party_tax_prof_id     NUMBER,
        p_trading_hq_pty_tax_prof_id   NUMBER,  --reduced size p_trading_hq_party_tax_prof_id
        p_poi_party_tax_prof_id        NUMBER,
        p_pod_party_tax_prof_id        NUMBER,
        p_bill_to_party_tax_prof_id    NUMBER,
        p_bill_from_party_tax_prof_id  NUMBER,
        p_title_trans_pty_tax_prof_id  NUMBER,  --reduced size p_title_trans_party_tax_prof_id
        p_ship_to_site_tax_prof_id     NUMBER,
        p_ship_from_site_tax_prof_id   NUMBER,
        p_poa_site_tax_prof_id         NUMBER,
        p_poo_site_tax_prof_id         NUMBER,
        p_paying_site_tax_prof_id      NUMBER,
        p_own_hq_site_tax_prof_id      NUMBER,
        p_trading_hq_site_tax_prof_id  NUMBER,
        p_poi_site_tax_prof_id         NUMBER,
        p_pod_site_tax_prof_id         NUMBER,
        p_bill_to_site_tax_prof_id     NUMBER,
        p_bill_from_site_tax_prof_id   NUMBER,
        p_title_trn_site_tax_prof_id   NUMBER,  --reduced size p_title_trans_site_tax_prof_id
        p_merchant_party_tax_prof_id   NUMBER,
        p_line_amt_includes_tax_flag   VARCHAR2,
        p_historical_flag              VARCHAR2,
        p_tax_classification_code      VARCHAR2,
        p_ctrl_hdr_tx_appl_flag        VARCHAR2,
        p_ctrl_total_line_tx_amt       NUMBER,
        p_tax_regime_id                NUMBER,
        p_tax_regime_code              VARCHAR2,
        p_tax_id                       NUMBER,
        p_tax                          VARCHAR2,
        p_tax_status_id                NUMBER,
        p_tax_status_code              VARCHAR2,
        p_tax_rate_id                  NUMBER,
        p_tax_rate_code                VARCHAR2,
        p_tax_rate                     NUMBER,
        p_tax_line_amt                 NUMBER,
        p_line_class                   VARCHAR2,
        p_input_tax_classif_code       VARCHAR2,
        p_output_tax_classif_code      VARCHAR2,
        p_ref_doc_trx_level_type       VARCHAR2,
        p_applied_to_trx_level_type    VARCHAR2,
        p_applied_from_trx_level_type  VARCHAR2,
        p_adjusted_doc_trx_level_type  VARCHAR2,
        p_exemption_control_flag       VARCHAR2,
        p_exempt_reason_code           VARCHAR2,
        p_receivables_trx_type_id      NUMBER,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    l_return_status       VARCHAR2(1000);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(1000);
    sid                    NUMBER;
    p_error_buffer         VARCHAR2(100);
    l_tax_event_type_code  VARCHAR2(30);

    CURSOR C IS
      SELECT rowid
      FROM zx_transaction_lines
      WHERE APPLICATION_ID = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id
      AND TRX_LINE_ID      = p_trx_line_id
      AND TRX_LEVEL_TYPE   = p_trx_level_type;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Row.BEGIN',
                     'ZX_TRX_DETAIL: Insert_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Row',
                     'Insert into ZX_TRANSACTION_LINES (+)');
    END IF;

    --IF p_trx_line_number IS NOT NULL THEN
/*
      UPDATE ZX_TRANSACTION
        SET EVENT_TYPE_CODE = p_event_type_code
        WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE      = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID           = p_trx_id;
*/
      INSERT INTO ZX_TRANSACTION_LINES (--SUBSCRIBER_ID,
                                        --INTERNAL_ORGANIZATION_ID,
                                        APPLICATION_ID,
                                        ENTITY_CODE,
                                        EVENT_CLASS_CODE,
                                        --EVENT_TYPE_CODE,
                                        TRX_LINE_ID,
                                        TRX_LINE_NUMBER,
                                        TRX_ID,
                                        TRX_LEVEL_TYPE,
                                        TRX_LINE_TYPE,
                                        TRX_LINE_DATE,
                                        TRX_BUSINESS_CATEGORY,
                                        LINE_INTENDED_USE,
                                        USER_DEFINED_FISC_CLASS,
                                        LINE_AMT_INCLUDES_TAX_FLAG,
                                        LINE_AMT,
                                        TRX_LINE_QUANTITY,
                                        UNIT_PRICE,
                                        PRODUCT_ID,
                                        PRODUCT_FISC_CLASSIFICATION,
                                        PRODUCT_ORG_ID,
                                        UOM_CODE,
                                        PRODUCT_TYPE,
                                        PRODUCT_CODE,
                                        PRODUCT_CATEGORY,
                                        MERCHANT_PARTY_ID,
                                        ACCOUNT_CCID,
                                        ACCOUNT_STRING,
                                        REF_DOC_LINE_ID,
                                        REF_DOC_LINE_QUANTITY,
                                        REF_DOC_APPLICATION_ID,
                                        REF_DOC_ENTITY_CODE,
                                        REF_DOC_EVENT_CLASS_CODE,
                                        REF_DOC_TRX_ID,
                                        APPLIED_FROM_LINE_ID,
                                        APPLIED_FROM_APPLICATION_ID,
                                        APPLIED_FROM_ENTITY_CODE,
                                        APPLIED_FROM_EVENT_CLASS_CODE,
                                        APPLIED_FROM_TRX_ID,
                                        ADJUSTED_DOC_LINE_ID,
                                        ADJUSTED_DOC_DATE,
                                        ADJUSTED_DOC_APPLICATION_ID,
                                        ADJUSTED_DOC_ENTITY_CODE,
                                        ADJUSTED_DOC_EVENT_CLASS_CODE,
                                        ADJUSTED_DOC_TRX_ID,
                                        TRX_LINE_DESCRIPTION,
                                        PRODUCT_DESCRIPTION,
                                        --TRX_COMMUNICATED_DATE,
                                        TRX_LINE_GL_DATE,
                                        --DOC_SEQ_ID,
                                        --DOC_SEQ_NAME,
                                        --DOC_SEQ_VALUE,
                                        --RECEIVABLES_TRX_TYPE_ID,
                                        --BATCH_SOURCE_NAME,
                                        LINE_LEVEL_ACTION,
                                        Historical_Flag,
                                        --TRX_DATE,
                                        --LEDGER_ID,
                                        --MINIMUM_ACCOUNTABLE_UNIT,
                                        --PRECISION,
                                        --LEGAL_ENTITY_ID,
                                        BILL_FROM_PARTY_SITE_ID,
                                        BILL_TO_PARTY_SITE_ID,
                                        SHIP_FROM_PARTY_SITE_ID,
                                        SHIP_TO_PARTY_SITE_ID,
                                        SHIP_TO_PARTY_ID,
                                        SHIP_FROM_PARTY_ID,
                                        BILL_TO_PARTY_ID,
                                        BILL_FROM_PARTY_ID,
                                        SHIP_TO_LOCATION_ID,
                                        SHIP_FROM_LOCATION_ID,
                                        BILL_TO_LOCATION_ID,
                                        BILL_FROM_LOCATION_ID,
                                        POA_LOCATION_ID,
                                        POO_LOCATION_ID,
                                        PAYING_LOCATION_ID,
                                        OWN_HQ_LOCATION_ID,
                                        TRADING_HQ_LOCATION_ID,
                                        POC_LOCATION_ID,
                                        POI_LOCATION_ID,
                                        POD_LOCATION_ID,
                                        TAX_REGIME_ID,
                                        TAX_REGIME_CODE,
                                        TAX_ID,
                                        TAX,
                                        TAX_STATUS_ID,
                                        TAX_STATUS_CODE,
                                        TAX_RATE_ID,
                                        TAX_RATE_CODE,
                                        TAX_RATE,
                                        TAX_LINE_AMT,
                                        LINE_CLASS,
                                        INPUT_TAX_CLASSIFICATION_CODE,
                                        OUTPUT_TAX_CLASSIFICATION_CODE,
                                        REF_DOC_TRX_LEVEL_TYPE,
                                        APPLIED_TO_TRX_LEVEL_TYPE,
                                        APPLIED_FROM_TRX_LEVEL_TYPE,
                                        ADJUSTED_DOC_TRX_LEVEL_TYPE,
                                        EXEMPTION_CONTROL_FLAG,
                                        EXEMPT_REASON_CODE,
                                        EXEMPT_CERTIFICATE_NUMBER,
                                        EXEMPT_REASON,
                                        CASH_DISCOUNT,
                                        VOLUME_DISCOUNT,
                                        TRADING_DISCOUNT,
                                        TRANSFER_CHARGE,
                                        TRANSPORTATION_CHARGE,
                                        INSURANCE_CHARGE,
                                        OTHER_CHARGE,
                                        RECEIVABLES_TRX_TYPE_ID,
                                        CTRL_HDR_TX_APPL_FLAG,
                                        CTRL_TOTAL_LINE_TX_AMT,
                                        OBJECT_VERSION_NUMBER,
                                        CREATED_BY,
                                        CREATION_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATE_LOGIN)
                                VALUES (--p_subscriber_id,
                                        --p_internal_organization_id,
                                        p_application_id,
                                        p_entity_code,
                                        p_event_class_code,
                                        --p_event_type_code,
                                        p_trx_line_id,
                                        p_trx_line_number,
                                        p_trx_id,
                                        p_trx_level_type,
                                        p_trx_line_type,
                                        p_trx_line_date,
                                        p_trx_business_category,
                                        p_line_intended_use,
                                        p_user_defined_fisc_class,
                                        p_Line_Amt_Includes_Tax_Flag,
                                        p_line_amt,
                                        p_trx_line_quantity,
                                        p_unit_price,
                                        p_product_id,
                                        p_product_fisc_classification,
                                        p_product_org_id,
                                        p_uom_code,
                                        p_product_type,
                                        p_product_code,
                                        p_product_category,
                                        p_merchant_party_id,
                                        p_account_ccid,
                                        p_account_string,
                                        p_ref_doc_line_id,
                                        p_ref_doc_line_quantity,
                                        p_ref_doc_application_id,
                                        p_ref_doc_entity_code,
                                        p_ref_doc_event_class_code,
                                        p_ref_doc_trx_id,
                                        p_applied_from_line_id,
                                        p_applied_from_application_id,
                                        p_applied_from_entity_code,   --resized
                                        p_applied_from_evt_class_code,--resized
                                        p_applied_from_trx_id,
                                        p_adjusted_doc_line_id,
                                        p_adjusted_doc_date,
                                        p_adjusted_doc_application_id,
                                        p_adjusted_doc_entity_code,
                                        p_adj_doc_event_class_code,   --resized
                                        p_adjusted_doc_trx_id,
                                        p_trx_line_description,
                                        p_product_description,
                                        --p_trx_communicated_date,
                                        p_trx_line_gl_date,
                                        --p_doc_seq_id,
                                        --p_doc_seq_name,
                                        --p_doc_seq_value,
                                        --p_receivables_trx_type_id,
                                        --p_batch_source_name,
                                        p_line_level_action,
                                        p_Historical_Flag,
                                        --p_trx_date,
                                        --p_ledger_id,
                                        --p_minimum_accountable_unit,
                                        --p_precision,
                                        --p_legal_entity_id,
                                        p_bill_from_party_site_id,
                                        p_bill_to_party_site_id,
                                        p_ship_from_party_site_id,
                                        p_ship_to_party_site_id,
                                        p_ship_to_party_id,
                                        p_ship_from_party_id,
                                        p_bill_to_party_id,
                                        p_bill_from_party_id,
                                        p_ship_to_location_id,
                                        p_ship_from_location_id,
                                        p_bill_to_location_id,
                                        p_bill_from_location_id,
                                        p_poa_location_id,
                                        p_poo_location_id,
                                        p_paying_location_id,
                                        p_own_hq_location_id,
                                        p_trading_hq_location_id,
                                        p_poc_location_id,
                                        p_poi_location_id,
                                        p_pod_location_id,
                                        p_tax_regime_id,
                                        p_tax_regime_code,
                                        p_tax_id,
                                        p_tax,
                                        p_tax_status_id,
                                        p_tax_status_code,
                                        p_tax_rate_id,
                                        p_tax_rate_code,
                                        p_tax_rate,
                                        p_tax_line_amt,
                                        p_line_class,
                                        p_input_tax_classif_code,
                                        p_output_tax_classif_code,
                                        p_ref_doc_trx_level_type,
                                        p_applied_to_trx_level_type,
                                        p_applied_from_trx_level_type,
                                        p_adjusted_doc_trx_level_type,
                                        p_exemption_control_flag,
                                        p_exempt_reason_code,
                                        p_exempt_certificate_number,
                                        p_exempt_reason,
                                        p_cash_discount,
                                        p_volume_discount,
                                        p_trading_discount,
                                        p_transfer_charge,
                                        p_transportation_charge,
                                        p_insurance_charge,
                                        p_other_charge,
                                        p_receivables_trx_type_id,
                                        p_ctrl_hdr_tx_appl_flag,
                                        p_ctrl_total_line_tx_amt,
                                        1,  --p_object_version_number,
                                        p_created_by,
                                        p_creation_date,
                                        p_last_updated_by,
                                        p_last_update_date,
                                        p_last_update_login);

    OPEN C;
    FETCH C INTO p_Rowid;
    IF (C%NOTFOUND) THEN
      CLOSE C;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE C;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Row',
                       'Insert into ZX_TRANSACTION_LINES (-)');
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Row.END',
                       'ZX_TRX_DETAIL: Insert_Row (-)');
      END IF;

  END Insert_row;

  PROCEDURE Update_row
       (p_Rowid                        VARCHAR2,
        p_internal_organization_id     NUMBER,
        p_internal_org_location_id     NUMBER,
        p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_trx_date                     DATE,
        p_trx_doc_revision             VARCHAR2,
        p_ledger_id                    NUMBER,
        p_trx_currency_code            VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_rate     NUMBER,
        p_currency_conversion_type     VARCHAR2,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER,
        p_legal_entity_id              NUMBER,
        p_rounding_ship_to_party_id    NUMBER,
        p_rounding_ship_from_party_id  NUMBER,
        p_rounding_bill_to_party_id    NUMBER,
        p_rounding_bill_from_party_id  NUMBER,
        p_rndg_ship_to_party_site_id   NUMBER,
        p_rndg_ship_from_pty_site_id   NUMBER,  --reduced size p_rndg_ship_from_party_site_id
        p_rndg_bill_to_party_site_id   NUMBER,
        p_rndg_bill_from_pty_site_id   NUMBER,  --reduced size p_rndg_bill_from_party_site_id
        p_establishment_id             NUMBER,
        p_related_doc_application_id   NUMBER,
        p_related_doc_entity_code      VARCHAR2,
        p_related_doc_evt_class_code   VARCHAR2,  --reduced size p_related_doc_event_class_code
        p_related_doc_trx_id           NUMBER,
        p_related_doc_number           VARCHAR2,
        p_related_doc_date             DATE,
        p_default_taxation_country     VARCHAR2,
        p_quote_flag                   VARCHAR2,
        p_trx_number                   VARCHAR2,
        p_trx_description              VARCHAR2,
        p_trx_communicated_date        DATE,
        p_batch_source_id              NUMBER,
        p_batch_source_name            VARCHAR2,
        --p_doc_seq_id                   NUMBER,
        --p_doc_seq_name                 VARCHAR2,
        --p_doc_seq_value                VARCHAR2,
        p_trx_due_date                 DATE,
        p_trx_type_description         VARCHAR2,
        p_billing_trad_partner_name    VARCHAR2,  --reduced size p_billing_trading_partner_name
        p_billing_trad_partner_number  VARCHAR2,  --reduced size p_billing_trading_partner_number
        p_billing_tp_tax_report_flg    VARCHAR2,  --reduced size p_Billing_Tp_Tax_Reporting_Flag
        p_billing_tp_taxpayer_id       VARCHAR2,
        p_document_sub_type            VARCHAR2,
        p_supplier_tax_invoice_number  VARCHAR2,
        p_supplier_tax_invoice_date    DATE,
        p_supplier_exchange_rate       NUMBER,
        p_tax_invoice_date             DATE,
        p_tax_invoice_number           VARCHAR2,
        p_tax_event_class_code         VARCHAR2,
        p_tax_event_type_code          VARCHAR2,
        p_doc_event_status             VARCHAR2,
        p_rdng_ship_to_pty_tx_prof_id  NUMBER,
        p_rdng_ship_fr_pty_tx_prof_id  NUMBER,  --reduced size p_rdng_ship_from_pty_tx_prof_id
        p_rdng_bill_to_pty_tx_prof_id  NUMBER,
        p_rdng_bill_fr_pty_tx_prof_id  NUMBER,  --reduced size p_rdng_bill_from_pty_tx_prof_id
        p_rdng_ship_to_pty_tx_p_st_id  NUMBER,
        p_rdng_ship_fr_pty_tx_p_st_id  NUMBER,  --reduced size p_rdng_ship_from_pty_tx_p_st_id
        p_rdng_bill_to_pty_tx_p_st_id  NUMBER,
        p_rdng_bill_fr_pty_tx_p_st_id  NUMBER,  --reduced size p_rdng_bill_from_pty_tx_p_st_id
        p_trx_level_type               VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_line_level_action            VARCHAR2,
        p_trx_shipping_date            DATE,
        p_trx_receipt_date             DATE,
        p_trx_line_type                VARCHAR2,
        p_trx_line_date                DATE,
        p_trx_business_category        VARCHAR2,
        p_line_intended_use            VARCHAR2,
        p_user_defined_fisc_class      VARCHAR2,
        p_line_amt                     NUMBER,
        p_trx_line_quantity            NUMBER,
        p_unit_price                   NUMBER,
        p_exempt_certificate_number    VARCHAR2,
        p_exempt_reason                VARCHAR2,
        p_cash_discount                NUMBER,
        p_volume_discount              NUMBER,
        p_trading_discount             NUMBER,
        p_transfer_charge              NUMBER,
        p_transportation_charge        NUMBER,
        p_insurance_charge             NUMBER,
        p_other_charge                 NUMBER,
        p_product_id                   NUMBER,
        p_product_fisc_classification  VARCHAR2,
        p_product_org_id               NUMBER,
        p_uom_code                     VARCHAR2,
        p_product_type                 VARCHAR2,
        p_product_code                 VARCHAR2,
        p_product_category             VARCHAR2,
        p_trx_sic_code                 VARCHAR2,
        p_fob_point                    VARCHAR2,
        p_ship_to_party_id             NUMBER,
        p_ship_from_party_id           NUMBER,
        p_poa_party_id                 NUMBER,
        p_poo_party_id                 NUMBER,
        p_bill_to_party_id             NUMBER,
        p_bill_from_party_id           NUMBER,
        p_merchant_party_id            NUMBER,
        p_ship_to_party_site_id        NUMBER,
        p_ship_from_party_site_id      NUMBER,
        p_poa_party_site_id            NUMBER,
        p_poo_party_site_id            NUMBER,
        p_bill_to_party_site_id        NUMBER,
        p_bill_from_party_site_id      NUMBER,
        p_ship_to_location_id          NUMBER,
        p_ship_from_location_id        NUMBER,
        p_poa_location_id              NUMBER,
        p_poo_location_id              NUMBER,
        p_bill_to_location_id          NUMBER,
        p_bill_from_location_id        NUMBER,
        p_account_ccid                 NUMBER,
        p_account_string               VARCHAR2,
        p_merchant_party_country       VARCHAR2,
        p_ref_doc_application_id       NUMBER,
        p_ref_doc_entity_code          VARCHAR2,
        p_ref_doc_event_class_code     VARCHAR2,
        p_ref_doc_trx_id               NUMBER,
        p_ref_doc_line_id              NUMBER,
        p_ref_doc_line_quantity        NUMBER,
        p_applied_from_application_id  NUMBER,
        p_applied_from_entity_code     VARCHAR2,
        p_applied_from_evt_class_code  VARCHAR2,  --reduced size p_applied_from_event_class_code
        p_applied_from_trx_id          NUMBER,
        p_applied_from_line_id         NUMBER,
        p_adjusted_doc_application_id  NUMBER,
        p_adjusted_doc_entity_code     VARCHAR2,
        p_adj_doc_event_class_code     VARCHAR2,  --reduced size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id          NUMBER,
        p_adjusted_doc_line_id         NUMBER,
        p_adjusted_doc_number          VARCHAR2,
        p_adjusted_doc_date            DATE,
        p_applied_to_application_id    NUMBER,
        p_applied_to_entity_code       VARCHAR2,
        p_applied_to_event_class_code  VARCHAR2,
        p_applied_to_trx_id            NUMBER,
        p_applied_to_trx_line_id       NUMBER,
        p_trx_id_level2                NUMBER,
        p_trx_id_level3                NUMBER,
        p_trx_id_level4                NUMBER,
        p_trx_id_level5                NUMBER,
        p_trx_id_level6                NUMBER,
        p_trx_line_number              NUMBER,
        p_trx_line_description         VARCHAR2,
        p_product_description          VARCHAR2,
        p_trx_waybill_number           VARCHAR2,
        p_trx_line_gl_date             DATE,
        p_merchant_party_name          VARCHAR2,
        p_merchant_party_doc_number    VARCHAR2,  --reduced size p_merchant_party_document_number
        p_merchant_party_reference     VARCHAR2,
        p_merchant_party_taxpayer_id   VARCHAR2,
        p_merchant_pty_tax_reg_number  VARCHAR2,  --reduced size p_merchant_party_tax_reg_number
        p_paying_party_id              NUMBER,
        p_own_hq_party_id              NUMBER,
        p_trading_hq_party_id          NUMBER,
        p_poi_party_id                 NUMBER,
        p_pod_party_id                 NUMBER,
        p_title_transfer_party_id      NUMBER,
        p_paying_party_site_id         NUMBER,
        p_own_hq_party_site_id         NUMBER,
        p_trading_hq_party_site_id     NUMBER,
        p_poi_party_site_id            NUMBER,
        p_pod_party_site_id            NUMBER,
        p_title_transfer_pty_site_id   NUMBER,  --reduced size p_title_transfer_party_site_id
        p_paying_location_id           NUMBER,
        p_own_hq_location_id           NUMBER,
        p_trading_hq_location_id       NUMBER,
        p_poc_location_id              NUMBER,
        p_poi_location_id              NUMBER,
        p_pod_location_id              NUMBER,
        p_title_transfer_location_id   NUMBER,
        p_banking_tp_taxpayer_id       VARCHAR2,
        p_assessable_value             NUMBER,
        p_asset_flag                   VARCHAR2,
        p_asset_number                 VARCHAR2,
        p_asset_accum_depreciation     NUMBER,
        p_asset_type                   VARCHAR2,
        p_asset_cost                   NUMBER,
        p_ship_to_party_tax_prof_id    NUMBER,
        p_ship_from_party_tax_prof_id  NUMBER,
        p_poa_party_tax_prof_id        NUMBER,
        p_poo_party_tax_prof_id        NUMBER,
        p_paying_party_tax_prof_id     NUMBER,
        p_own_hq_party_tax_prof_id     NUMBER,
        p_trading_hq_pty_tax_prof_id   NUMBER,  --reduced size p_trading_hq_party_tax_prof_id
        p_poi_party_tax_prof_id        NUMBER,
        p_pod_party_tax_prof_id        NUMBER,
        p_bill_to_party_tax_prof_id    NUMBER,
        p_bill_from_party_tax_prof_id  NUMBER,
        p_title_trans_pty_tax_prof_id  NUMBER,  --reduced size p_title_trans_party_tax_prof_id
        p_ship_to_site_tax_prof_id     NUMBER,
        p_ship_from_site_tax_prof_id   NUMBER,
        p_poa_site_tax_prof_id         NUMBER,
        p_poo_site_tax_prof_id         NUMBER,
        p_paying_site_tax_prof_id      NUMBER,
        p_own_hq_site_tax_prof_id      NUMBER,
        p_trading_hq_site_tax_prof_id  NUMBER,
        p_poi_site_tax_prof_id         NUMBER,
        p_pod_site_tax_prof_id         NUMBER,
        p_bill_to_site_tax_prof_id     NUMBER,
        p_bill_from_site_tax_prof_id   NUMBER,
        p_title_trn_site_tax_prof_id   NUMBER,  --reduced size p_title_trans_site_tax_prof_id
        p_merchant_party_tax_prof_id   NUMBER,
        p_line_amt_includes_tax_flag   VARCHAR2,
        p_historical_flag              VARCHAR2,
        p_tax_classification_code      VARCHAR2,
        p_ctrl_hdr_tx_appl_flag        VARCHAR2,
        p_ctrl_total_line_tx_amt       NUMBER,
        p_tax_regime_id                NUMBER,
        p_tax_regime_code              VARCHAR2,
        p_tax_id                       NUMBER,
        p_tax                          VARCHAR2,
        p_tax_status_id                NUMBER,
        p_tax_status_code              VARCHAR2,
        p_tax_rate_id                  NUMBER,
        p_tax_rate_code                VARCHAR2,
        p_tax_rate                     NUMBER,
        p_tax_line_amt                 NUMBER,
        p_line_class                   VARCHAR2,
        p_input_tax_classif_code       VARCHAR2,
        p_output_tax_classif_code      VARCHAR2,
        p_ref_doc_trx_level_type       VARCHAR2,
        p_applied_to_trx_level_type    VARCHAR2,
        p_applied_from_trx_level_type  VARCHAR2,
        p_adjusted_doc_trx_level_type  VARCHAR2,
        p_exemption_control_flag       VARCHAR2,
        p_exempt_reason_code           VARCHAR2,
        p_receivables_trx_type_id      NUMBER,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(240);
    p_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Row.BEGIN',
                     'ZX_TRX_DETAIL: Update_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Row',
                     'Update ZX_TRANSACTION_LINES (+)');
    END IF;


    UPDATE ZX_TRANSACTION_LINES
      SET TRX_LINE_DESCRIPTION          = p_trx_line_description,
          TRX_LINE_TYPE                 = p_trx_line_type,
          PRODUCT_ID                    = p_product_id,
          PRODUCT_ORG_ID                = p_product_org_id,
          PRODUCT_CODE                  = p_product_code,
          PRODUCT_TYPE                  = p_product_type,
          PRODUCT_DESCRIPTION           = p_product_description,
          TRX_LINE_QUANTITY             = p_trx_line_quantity,
          UOM_CODE                      = p_uom_code,
          UNIT_PRICE                    = p_unit_price,
          LINE_AMT                      = p_line_amt,
          PRODUCT_CATEGORY              = p_product_category,
          TRX_LINE_DATE                 = p_trx_line_date,
          LINE_INTENDED_USE             = p_line_intended_use,
          USER_DEFINED_FISC_CLASS       = p_user_defined_fisc_class,
          TRX_BUSINESS_CATEGORY         = p_trx_business_category,
          ACCOUNT_CCID                  = p_account_ccid,
          ACCOUNT_STRING                = p_account_string,
          TRX_LINE_GL_DATE              = p_trx_line_gl_date,
          LINE_LEVEL_ACTION             = p_line_level_action,
          MERCHANT_PARTY_ID             = p_merchant_party_id,
          MERCHANT_PARTY_COUNTRY        = p_merchant_party_country,
          BILL_FROM_PARTY_SITE_ID       = p_bill_from_party_site_id,
          BILL_TO_PARTY_SITE_ID         = p_bill_to_party_site_id,
          SHIP_FROM_PARTY_SITE_ID       = p_ship_from_party_site_id,
          SHIP_TO_PARTY_SITE_ID         = p_ship_to_party_site_id,
          SHIP_TO_PARTY_ID              = p_ship_to_party_id,
          SHIP_FROM_PARTY_ID            = p_ship_from_party_id,
          BILL_TO_PARTY_ID              = p_bill_to_party_id,
          BILL_FROM_PARTY_ID            = p_bill_from_party_id,
          SHIP_TO_LOCATION_ID           = p_ship_to_location_id,
          SHIP_FROM_LOCATION_ID         = p_ship_from_location_id,
          BILL_TO_LOCATION_ID           = p_bill_to_location_id,
          BILL_FROM_LOCATION_ID         = p_bill_from_location_id,
          POA_LOCATION_ID               = p_poa_location_id,
          POO_LOCATION_ID               = p_poo_location_id,
          PAYING_LOCATION_ID            = p_paying_location_id,
          OWN_HQ_LOCATION_ID            = p_own_hq_location_id,
          TRADING_HQ_LOCATION_ID        = p_trading_hq_location_id,
          POC_LOCATION_ID               = p_poc_location_id,
          POI_LOCATION_ID               = p_poi_location_id,
          POD_LOCATION_ID               = p_pod_location_id,
          POA_PARTY_ID                  = p_poa_party_id,
          POO_PARTY_ID                  = p_poo_party_id,
          POA_PARTY_SITE_ID             = p_poa_party_site_id,
          POO_PARTY_SITE_ID             = p_poo_party_site_id,
          REF_DOC_APPLICATION_ID        = p_ref_doc_application_id,
          REF_DOC_ENTITY_CODE           = p_ref_doc_entity_code,
          REF_DOC_EVENT_CLASS_CODE      = p_ref_doc_event_class_code,
          REF_DOC_TRX_ID                = p_ref_doc_trx_id,
          REF_DOC_LINE_ID               = p_ref_doc_line_id,
          REF_DOC_LINE_QUANTITY         = p_ref_doc_line_quantity,
          ADJUSTED_DOC_APPLICATION_ID   = p_adjusted_doc_application_id,
          ADJUSTED_DOC_ENTITY_CODE      = p_adjusted_doc_entity_code,
          ADJUSTED_DOC_EVENT_CLASS_CODE = p_adj_doc_event_class_code,
          ADJUSTED_DOC_TRX_ID           = p_adjusted_doc_trx_id,
          ADJUSTED_DOC_LINE_ID          = p_adjusted_doc_line_id,
          ADJUSTED_DOC_DATE             = p_adjusted_doc_date,
          APPLIED_FROM_APPLICATION_ID   = p_applied_from_application_id,
          APPLIED_FROM_ENTITY_CODE      = p_applied_from_entity_code,
          APPLIED_FROM_EVENT_CLASS_CODE = p_applied_from_evt_class_code,
          APPLIED_FROM_TRX_ID           = p_applied_from_trx_id,
          APPLIED_FROM_LINE_ID          = p_applied_from_line_id,
          APPLIED_TO_APPLICATION_ID     = p_applied_to_application_id,
          APPLIED_TO_ENTITY_CODE        = p_applied_to_entity_code,
          APPLIED_TO_EVENT_CLASS_CODE   = p_applied_to_event_class_code,
          APPLIED_TO_TRX_ID             = p_applied_to_trx_id,
          APPLIED_TO_TRX_LINE_ID        = p_applied_to_trx_line_id,
          PRODUCT_FISC_CLASSIFICATION   = p_product_fisc_classification,
          LINE_CLASS                    = p_line_class,
          INPUT_TAX_CLASSIFICATION_CODE = p_input_tax_classif_code,
          OUTPUT_TAX_CLASSIFICATION_CODE = p_output_tax_classif_code,
          REF_DOC_TRX_LEVEL_TYPE        = p_ref_doc_trx_level_type,
          APPLIED_TO_TRX_LEVEL_TYPE     = p_applied_to_trx_level_type,
          APPLIED_FROM_TRX_LEVEL_TYPE   = p_applied_from_trx_level_type,
          ADJUSTED_DOC_TRX_LEVEL_TYPE   = p_adjusted_doc_trx_level_type,
          EXEMPTION_CONTROL_FLAG        = p_exemption_control_flag,
          EXEMPT_REASON_CODE            = p_exempt_reason_code,
          EXEMPT_CERTIFICATE_NUMBER     = p_exempt_certificate_number,
          EXEMPT_REASON                 = p_exempt_reason,
          CASH_DISCOUNT                 = p_cash_discount,
          VOLUME_DISCOUNT               = p_volume_discount,
          TRADING_DISCOUNT              = p_trading_discount,
          TRANSFER_CHARGE               = p_transfer_charge,
          TRANSPORTATION_CHARGE         = p_transportation_charge,
          INSURANCE_CHARGE              = p_insurance_charge,
          OTHER_CHARGE                  = p_other_charge,
          RECEIVABLES_TRX_TYPE_ID       = p_receivables_trx_type_id,
          CTRL_HDR_TX_APPL_FLAG         = p_ctrl_hdr_tx_appl_flag,
          CTRL_TOTAL_LINE_TX_AMT        = p_ctrl_total_line_tx_amt,
          LINE_AMT_INCLUDES_TAX_FLAG    = p_line_amt_includes_tax_flag,
          HISTORICAL_FLAG               = p_historical_flag,
          OBJECT_VERSION_NUMBER         = NVL(p_object_version_number, OBJECT_VERSION_NUMBER + 1),
          CREATED_BY                    = p_created_by,
          CREATION_DATE                 = p_creation_date,
          LAST_UPDATED_BY               = p_last_updated_by,
          LAST_UPDATE_DATE              = p_last_update_date,
          LAST_UPDATE_LOGIN             = p_last_update_login
      WHERE APPLICATION_ID = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id
      AND TRX_LEVEL_TYPE   = p_trx_level_type
      AND TRX_LINE_ID      = p_trx_line_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Row',
                     'Update ZX_TRANSACTION_LINES (-)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Row.END',
                     'ZX_TRX_DETAIL: Update_Row (-)');
    END IF;

  END Update_row;

  PROCEDURE Delete_row
       (p_Rowid                        VARCHAR2,
        p_internal_organization_id     NUMBER,
        p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_trx_level_type               VARCHAR2,
        p_trx_line_id                  NUMBER
        ) IS

    l_return_status         VARCHAR2(30);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(240);
    l_error_buffer          VARCHAR2(100);
    l_transaction_line_rec  ZX_API_PUB.transaction_line_rec_type;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Delete_Row.BEGIN',
                     'ZX_TRX_DETAIL: Delete_Row (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Delete_Row',
                     'Deleting  ZX_TRANSACTION_LINES');
    END IF;

    DELETE ZX_TRANSACTION_LINES
      WHERE APPLICATION_ID   = p_application_id
        AND ENTITY_CODE      = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID           = p_trx_id
        AND TRX_LEVEL_TYPE   = p_trx_level_type
        AND TRX_LINE_ID      = p_trx_line_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Delete_Row',
                     'Deleted   ZX_TRANSACTION_LINES');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Delete_Row',
                     'Calling ZX_API_PUB.Mark_tax_lines_deleted');
    END IF;

    l_transaction_line_rec.INTERNAL_ORGANIZATION_ID := p_internal_organization_id;
    l_transaction_line_rec.APPLICATION_ID := p_application_id;
    l_transaction_line_rec.ENTITY_CODE      := p_entity_code;
    l_transaction_line_rec.EVENT_CLASS_CODE := p_event_class_code;
    l_transaction_line_rec.EVENT_TYPE_CODE  := p_event_type_code;
    l_transaction_line_rec.TRX_ID           := p_trx_id;
    l_transaction_line_rec.TRX_LEVEL_TYPE   := p_trx_level_type;
    l_transaction_line_rec.TRX_LINE_ID      := p_trx_line_id;

    ZX_API_PUB.Mark_tax_lines_deleted
                 (p_api_version      => 1.0,
                  p_init_msg_list    => NULL,
                  p_commit           => NULL,
                  p_validation_level => NULL,
                  x_return_status    => l_return_status,
                  x_msg_count        => l_msg_count,
                  x_msg_data         => l_msg_data,
                  p_transaction_line_rec => l_transaction_line_rec);


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Delete_Row.END',
                     'ZX_TRX_DETAIL: Delete_Row (-)');
    END IF;

  END Delete_row;

  PROCEDURE Lock_row
       (p_Rowid                        VARCHAR2,
        p_internal_organization_id     NUMBER,
        p_internal_org_location_id     NUMBER,
        p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_trx_date                     DATE,
        p_trx_doc_revision             VARCHAR2,
        p_ledger_id                    NUMBER,
        p_trx_currency_code            VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_rate     NUMBER,
        p_currency_conversion_type     VARCHAR2,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER,
        p_legal_entity_id              NUMBER,
        p_rounding_ship_to_party_id    NUMBER,
        p_rounding_ship_from_party_id  NUMBER,
        p_rounding_bill_to_party_id    NUMBER,
        p_rounding_bill_from_party_id  NUMBER,
        p_rndg_ship_to_party_site_id   NUMBER,
        p_rndg_ship_from_pty_site_id   NUMBER,  --reduced size p_rndg_ship_from_party_site_id
        p_rndg_bill_to_party_site_id   NUMBER,
        p_rndg_bill_from_pty_site_id   NUMBER,  --reduced size p_rndg_bill_from_party_site_id
        p_establishment_id             NUMBER,
        p_related_doc_application_id   NUMBER,
        p_related_doc_entity_code      VARCHAR2,
        p_related_doc_evt_class_code   VARCHAR2,  --reduced size p_related_doc_event_class_code
        p_related_doc_trx_id           NUMBER,
        p_related_doc_number           VARCHAR2,
        p_related_doc_date             DATE,
        p_default_taxation_country     VARCHAR2,
        p_quote_flag                   VARCHAR2,
        p_trx_number                   VARCHAR2,
        p_trx_description              VARCHAR2,
        p_trx_communicated_date        DATE,
        p_batch_source_id              NUMBER,
        p_batch_source_name            VARCHAR2,
        --p_doc_seq_id                   NUMBER,
        --p_doc_seq_name                 VARCHAR2,
        --p_doc_seq_value                VARCHAR2,
        p_trx_due_date                 DATE,
        p_trx_type_description         VARCHAR2,
        p_billing_trad_partner_name    VARCHAR2,  --reduced size p_billing_trading_partner_name
        p_billing_trad_partner_number  VARCHAR2,  --reduced size p_billing_trading_partner_number
        p_billing_tp_tax_report_flg    VARCHAR2,  --reduced size p_Billing_Tp_Tax_Reporting_Flag
        p_billing_tp_taxpayer_id       VARCHAR2,
        p_document_sub_type            VARCHAR2,
        p_supplier_tax_invoice_number  VARCHAR2,
        p_supplier_tax_invoice_date    DATE,--
        p_supplier_exchange_rate       NUMBER,
        p_tax_invoice_date             DATE,
        p_tax_invoice_number           VARCHAR2,
        p_tax_event_class_code         VARCHAR2,
        p_tax_event_type_code          VARCHAR2,
        p_doc_event_status             VARCHAR2,
        p_rdng_ship_to_pty_tx_prof_id  NUMBER,
        p_rdng_ship_fr_pty_tx_prof_id  NUMBER,  --reduced size p_rdng_ship_from_pty_tx_prof_id
        p_rdng_bill_to_pty_tx_prof_id  NUMBER,
        p_rdng_bill_fr_pty_tx_prof_id  NUMBER,  --reduced size p_rdng_bill_from_pty_tx_prof_id
        p_rdng_ship_to_pty_tx_p_st_id  NUMBER,
        p_rdng_ship_fr_pty_tx_p_st_id  NUMBER,  --reduced size p_rdng_ship_from_pty_tx_p_st_id
        p_rdng_bill_to_pty_tx_p_st_id  NUMBER,
        p_rdng_bill_fr_pty_tx_p_st_id  NUMBER,  --reduced size p_rdng_bill_from_pty_tx_p_st_id
        p_trx_level_type               VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_line_level_action            VARCHAR2,
        p_trx_shipping_date            DATE,
        p_trx_receipt_date             DATE,
        p_trx_line_type                VARCHAR2,
        p_trx_line_date                DATE,
        p_trx_business_category        VARCHAR2,
        p_line_intended_use            VARCHAR2,
        p_user_defined_fisc_class      VARCHAR2,
        p_line_amt                     NUMBER,
        p_trx_line_quantity            NUMBER,
        p_unit_price                   NUMBER,
        p_exempt_certificate_number    VARCHAR2,
        p_exempt_reason                VARCHAR2,
        p_cash_discount                NUMBER,
        p_volume_discount              NUMBER,
        p_trading_discount             NUMBER,
        p_transfer_charge              NUMBER,
        p_transportation_charge        NUMBER,
        p_insurance_charge             NUMBER,
        p_other_charge                 NUMBER,
        p_product_id                   NUMBER,
        p_product_fisc_classification  VARCHAR2,
        p_product_org_id               NUMBER,
        p_uom_code                     VARCHAR2,
        p_product_type                 VARCHAR2,
        p_product_code                 VARCHAR2,
        p_product_category             VARCHAR2,
        p_trx_sic_code                 VARCHAR2,
        p_fob_point                    VARCHAR2,
        p_ship_to_party_id             NUMBER,
        p_ship_from_party_id           NUMBER,
        p_poa_party_id                 NUMBER,
        p_poo_party_id                 NUMBER,
        p_bill_to_party_id             NUMBER,
        p_bill_from_party_id           NUMBER,
        p_merchant_party_id            NUMBER,
        p_ship_to_party_site_id        NUMBER,
        p_ship_from_party_site_id      NUMBER,
        p_poa_party_site_id            NUMBER,
        p_poo_party_site_id            NUMBER,
        p_bill_to_party_site_id        NUMBER,
        p_bill_from_party_site_id      NUMBER,
        p_ship_to_location_id          NUMBER,
        p_ship_from_location_id        NUMBER,
        p_poa_location_id              NUMBER,
        p_poo_location_id              NUMBER,
        p_bill_to_location_id          NUMBER,
        p_bill_from_location_id        NUMBER,
        p_account_ccid                 NUMBER,
        p_account_string               VARCHAR2,
        p_merchant_party_country       VARCHAR2,
        p_ref_doc_application_id       NUMBER,
        p_ref_doc_entity_code          VARCHAR2,
        p_ref_doc_event_class_code     VARCHAR2,
        p_ref_doc_trx_id               NUMBER,
        p_ref_doc_line_id              NUMBER,
        p_ref_doc_line_quantity        NUMBER,
        p_applied_from_application_id  NUMBER,
        p_applied_from_entity_code     VARCHAR2,
        p_applied_from_evt_class_code  VARCHAR2,  --reduced size p_applied_from_event_class_code
        p_applied_from_trx_id          NUMBER,
        p_applied_from_line_id         NUMBER,
        p_adjusted_doc_application_id  NUMBER,
        p_adjusted_doc_entity_code     VARCHAR2,
        p_adj_doc_event_class_code     VARCHAR2,  --reduced size p_adjusted_doc_event_class_code
        p_adjusted_doc_trx_id          NUMBER,
        p_adjusted_doc_line_id         NUMBER,
        p_adjusted_doc_number          VARCHAR2,
        p_adjusted_doc_date            DATE,
        p_applied_to_application_id    NUMBER,
        p_applied_to_entity_code       VARCHAR2,
        p_applied_to_event_class_code  VARCHAR2,
        p_applied_to_trx_id            NUMBER,
        p_applied_to_trx_line_id       NUMBER,
        p_trx_id_level2                NUMBER,
        p_trx_id_level3                NUMBER,
        p_trx_id_level4                NUMBER,
        p_trx_id_level5                NUMBER,
        p_trx_id_level6                NUMBER,
        p_trx_line_number              NUMBER,
        p_trx_line_description         VARCHAR2,
        p_product_description          VARCHAR2,
        p_trx_waybill_number           VARCHAR2,
        p_trx_line_gl_date             DATE,
        p_merchant_party_name          VARCHAR2,
        p_merchant_party_doc_number    VARCHAR2,  --reduced size p_merchant_party_document_number
        p_merchant_party_reference     VARCHAR2,
        p_merchant_party_taxpayer_id   VARCHAR2,
        p_merchant_pty_tax_reg_number  VARCHAR2,  --reduced size p_merchant_party_tax_reg_number
        p_paying_party_id              NUMBER,
        p_own_hq_party_id              NUMBER,
        p_trading_hq_party_id          NUMBER,
        p_poi_party_id                 NUMBER,
        p_pod_party_id                 NUMBER,
        p_title_transfer_party_id      NUMBER,
        p_paying_party_site_id         NUMBER,
        p_own_hq_party_site_id         NUMBER,
        p_trading_hq_party_site_id     NUMBER,
        p_poi_party_site_id            NUMBER,
        p_pod_party_site_id            NUMBER,
        p_title_transfer_pty_site_id   NUMBER,  --reduced size p_title_transfer_party_site_id
        p_paying_location_id           NUMBER,
        p_own_hq_location_id           NUMBER,
        p_trading_hq_location_id       NUMBER,
        p_poc_location_id              NUMBER,
        p_poi_location_id              NUMBER,
        p_pod_location_id              NUMBER,
        p_title_transfer_location_id   NUMBER,
        p_banking_tp_taxpayer_id       VARCHAR2,
        p_assessable_value             NUMBER,
        p_asset_flag                   VARCHAR2,
        p_asset_number                 VARCHAR2,
        p_asset_accum_depreciation     NUMBER,
        p_asset_type                   VARCHAR2,
        p_asset_cost                   NUMBER,
        p_ship_to_party_tax_prof_id    NUMBER,
        p_ship_from_party_tax_prof_id  NUMBER,
        p_poa_party_tax_prof_id        NUMBER,
        p_poo_party_tax_prof_id        NUMBER,
        p_paying_party_tax_prof_id     NUMBER,
        p_own_hq_party_tax_prof_id     NUMBER,
        p_trading_hq_pty_tax_prof_id   NUMBER,  --reduced size p_trading_hq_party_tax_prof_id
        p_poi_party_tax_prof_id        NUMBER,
        p_pod_party_tax_prof_id        NUMBER,
        p_bill_to_party_tax_prof_id    NUMBER,
        p_bill_from_party_tax_prof_id  NUMBER,
        p_title_trans_pty_tax_prof_id  NUMBER,  --reduced size p_title_trans_party_tax_prof_id
        p_ship_to_site_tax_prof_id     NUMBER,
        p_ship_from_site_tax_prof_id   NUMBER,
        p_poa_site_tax_prof_id         NUMBER,
        p_poo_site_tax_prof_id         NUMBER,
        p_paying_site_tax_prof_id      NUMBER,
        p_own_hq_site_tax_prof_id      NUMBER,
        p_trading_hq_site_tax_prof_id  NUMBER,
        p_poi_site_tax_prof_id         NUMBER,
        p_pod_site_tax_prof_id         NUMBER,
        p_bill_to_site_tax_prof_id     NUMBER,
        p_bill_from_site_tax_prof_id   NUMBER,
        p_title_trn_site_tax_prof_id   NUMBER,  --reduced size p_title_trans_site_tax_prof_id
        p_merchant_party_tax_prof_id   NUMBER,
        p_line_amt_includes_tax_flag   VARCHAR2,
        p_historical_flag              VARCHAR2,
        p_tax_classification_code      VARCHAR2,
        p_ctrl_hdr_tx_appl_flag        VARCHAR2,
        p_ctrl_total_line_tx_amt       NUMBER,
        p_tax_regime_id                NUMBER,
        p_tax_regime_code              VARCHAR2,
        p_tax_id                       NUMBER,
        p_tax                          VARCHAR2,
        p_tax_status_id                NUMBER,
        p_tax_status_code              VARCHAR2,
        p_tax_rate_id                  NUMBER,
        p_tax_rate_code                VARCHAR2,
        p_tax_rate                     NUMBER,
        p_tax_line_amt                 NUMBER,
        p_line_class                   VARCHAR2,
        p_input_tax_classif_code      VARCHAR2,
        p_output_tax_classif_code      VARCHAR2,
        p_ref_doc_trx_level_type       VARCHAR2,
        p_applied_to_trx_level_type    VARCHAR2,
        p_applied_from_trx_level_type  VARCHAR2,
        p_adjusted_doc_trx_level_type  VARCHAR2,
        p_exemption_control_flag       VARCHAR2,
        p_exempt_reason_code           VARCHAR2,
        p_receivables_trx_type_id      NUMBER,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    CURSOR C IS
      SELECT APPLICATION_ID,
             ENTITY_CODE,
             EVENT_CLASS_CODE,
             TRX_LINE_ID,
             TRX_LINE_NUMBER,
             TRX_ID,
             TRX_LEVEL_TYPE,
             TRX_LINE_TYPE,
             TRX_LINE_DATE,
             TRX_BUSINESS_CATEGORY,
             LINE_INTENDED_USE,
             USER_DEFINED_FISC_CLASS,
             LINE_AMT_INCLUDES_TAX_FLAG,
             LINE_AMT,
             TRX_LINE_QUANTITY,
             UNIT_PRICE,
             PRODUCT_ID,
             PRODUCT_FISC_CLASSIFICATION,
             PRODUCT_ORG_ID,
             UOM_CODE,
             PRODUCT_TYPE,
             PRODUCT_CODE,
             PRODUCT_CATEGORY,
             MERCHANT_PARTY_ID,
             ACCOUNT_CCID,
             ACCOUNT_STRING,
             REF_DOC_LINE_ID,
             REF_DOC_LINE_QUANTITY,
             REF_DOC_APPLICATION_ID,
             REF_DOC_ENTITY_CODE,
             REF_DOC_EVENT_CLASS_CODE,
             REF_DOC_TRX_ID,
             APPLIED_FROM_LINE_ID,
             APPLIED_FROM_APPLICATION_ID,
             APPLIED_FROM_ENTITY_CODE,
             APPLIED_FROM_EVENT_CLASS_CODE,
             APPLIED_FROM_TRX_ID,
             ADJUSTED_DOC_LINE_ID,
             ADJUSTED_DOC_DATE,
             ADJUSTED_DOC_APPLICATION_ID,
             ADJUSTED_DOC_ENTITY_CODE,
             ADJUSTED_DOC_EVENT_CLASS_CODE,
             ADJUSTED_DOC_TRX_ID,
             TRX_LINE_DESCRIPTION,
             PRODUCT_DESCRIPTION,
             TRX_LINE_GL_DATE,
             LINE_LEVEL_ACTION,
             HISTORICAL_FLAG,
             BILL_FROM_PARTY_SITE_ID,
             BILL_TO_PARTY_SITE_ID,
             SHIP_FROM_PARTY_SITE_ID,
             SHIP_TO_PARTY_SITE_ID,
             SHIP_TO_PARTY_ID,
             SHIP_FROM_PARTY_ID,
             BILL_TO_PARTY_ID,
             BILL_FROM_PARTY_ID,
             SHIP_TO_LOCATION_ID,
             SHIP_FROM_LOCATION_ID,
             BILL_TO_LOCATION_ID,
             BILL_FROM_LOCATION_ID,
             POA_LOCATION_ID,
             POO_LOCATION_ID,
             PAYING_LOCATION_ID,
             OWN_HQ_LOCATION_ID,
             TRADING_HQ_LOCATION_ID,
             POC_LOCATION_ID,
             POI_LOCATION_ID,
             POD_LOCATION_ID,
             TAX_REGIME_ID,
             TAX_REGIME_CODE,
             TAX_ID,
             TAX,
             TAX_STATUS_ID,
             TAX_STATUS_CODE,
             TAX_RATE_ID,
             TAX_RATE_CODE,
             TAX_RATE,
             TAX_LINE_AMT,
             LINE_CLASS,
             INPUT_TAX_CLASSIFICATION_CODE,
             OUTPUT_TAX_CLASSIFICATION_CODE,
             REF_DOC_TRX_LEVEL_TYPE,
             APPLIED_TO_TRX_LEVEL_TYPE,
             APPLIED_FROM_TRX_LEVEL_TYPE,
             ADJUSTED_DOC_TRX_LEVEL_TYPE,
             EXEMPTION_CONTROL_FLAG,
             EXEMPT_REASON_CODE,
             EXEMPT_CERTIFICATE_NUMBER,
             EXEMPT_REASON,
             CASH_DISCOUNT,
             VOLUME_DISCOUNT,
             TRADING_DISCOUNT,
             TRANSFER_CHARGE,
             TRANSPORTATION_CHARGE,
             INSURANCE_CHARGE,
             OTHER_CHARGE,
             RECEIVABLES_TRX_TYPE_ID,
             CTRL_HDR_TX_APPL_FLAG,
             CTRL_TOTAL_LINE_TX_AMT,
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
        FROM ZX_TRANSACTION_LINES
        WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_LINE_ID = p_trx_line_id
        AND TRX_LEVEL_TYPE = p_trx_level_type
        AND TRX_ID = p_trx_id
        FOR UPDATE OF APPLICATION_ID,
                      ENTITY_CODE,
                      EVENT_CLASS_CODE,
                      TRX_LINE_ID,
                      TRX_LEVEL_TYPE,
                      TRX_ID
        NOWAIT;

    Recinfo C%ROWTYPE;
    debug_info             VARCHAR2(100);
    p_error_buffer         VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Lock_row.BEGIN',
                     'ZX_TRX_DETAIL: Lock_row (+)');
    END IF;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;

    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    debug_info := 'Close cursor C';
    CLOSE C;

    IF ((Recinfo.APPLICATION_ID = p_APPLICATION_ID) AND
        (Recinfo.ENTITY_CODE = p_ENTITY_CODE) AND
        (Recinfo.EVENT_CLASS_CODE = p_EVENT_CLASS_CODE) AND
        (Recinfo.TRX_LINE_ID = p_TRX_LINE_ID) AND
        (Recinfo.TRX_LINE_NUMBER = p_TRX_LINE_NUMBER) AND
        (Recinfo.TRX_ID = p_TRX_ID) AND
        (Recinfo.TRX_LEVEL_TYPE = p_TRX_LEVEL_TYPE) AND
        ((Recinfo.TRX_LINE_TYPE = p_TRX_LINE_TYPE)  OR
         ((Recinfo.TRX_LINE_TYPE IS NULL) AND
          (p_TRX_LINE_TYPE IS NULL))) AND
        ((Recinfo.TRX_LINE_DATE = p_TRX_LINE_DATE)  OR
         ((Recinfo.TRX_LINE_DATE IS NULL) AND
          (p_TRX_LINE_DATE IS NULL))) AND
        ((Recinfo.TRX_BUSINESS_CATEGORY = p_TRX_BUSINESS_CATEGORY)  OR
         ((Recinfo.TRX_BUSINESS_CATEGORY IS NULL) AND
          (p_TRX_BUSINESS_CATEGORY IS NULL))) AND
        ((Recinfo.LINE_INTENDED_USE = p_LINE_INTENDED_USE)  OR
         ((Recinfo.LINE_INTENDED_USE IS NULL) AND
          (p_LINE_INTENDED_USE IS NULL))) AND
        ((Recinfo.USER_DEFINED_FISC_CLASS = p_USER_DEFINED_FISC_CLASS)  OR
         ((Recinfo.USER_DEFINED_FISC_CLASS IS NULL) AND
          (p_USER_DEFINED_FISC_CLASS IS NULL))) AND
        ((Recinfo.LINE_AMT_INCLUDES_TAX_FLAG = p_LINE_AMT_INCLUDES_TAX_FLAG)  OR
         ((Recinfo.LINE_AMT_INCLUDES_TAX_FLAG IS NULL) AND
          (p_LINE_AMT_INCLUDES_TAX_FLAG IS NULL))) AND
        ((Recinfo.LINE_AMT = p_LINE_AMT)  OR
         ((Recinfo.LINE_AMT IS NULL) AND
          (p_LINE_AMT IS NULL))) AND
        ((Recinfo.TRX_LINE_QUANTITY = p_TRX_LINE_QUANTITY)  OR
         ((Recinfo.TRX_LINE_QUANTITY IS NULL) AND
          (p_TRX_LINE_QUANTITY IS NULL))) AND
        ((Recinfo.UNIT_PRICE = p_UNIT_PRICE)  OR
         ((Recinfo.UNIT_PRICE IS NULL) AND
          (p_UNIT_PRICE IS NULL))) AND
        ((Recinfo.PRODUCT_ID = p_PRODUCT_ID)  OR
         ((Recinfo.PRODUCT_ID IS NULL) AND
          (p_PRODUCT_ID IS NULL))) AND
        ((Recinfo.PRODUCT_FISC_CLASSIFICATION = p_PRODUCT_FISC_CLASSIFICATION)  OR
         ((Recinfo.PRODUCT_FISC_CLASSIFICATION IS NULL) AND
          (p_PRODUCT_FISC_CLASSIFICATION IS NULL))) AND
        ((Recinfo.PRODUCT_ORG_ID = p_PRODUCT_ORG_ID)  OR
         ((Recinfo.PRODUCT_ORG_ID IS NULL) AND
          (p_PRODUCT_ORG_ID IS NULL))) AND
        ((Recinfo.UOM_CODE = p_UOM_CODE)  OR
         ((Recinfo.UOM_CODE IS NULL) AND
          (p_UOM_CODE IS NULL))) AND
        ((Recinfo.PRODUCT_TYPE = p_PRODUCT_TYPE)  OR
         ((Recinfo.PRODUCT_TYPE IS NULL) AND
          (p_PRODUCT_TYPE IS NULL))) AND
        ((Recinfo.PRODUCT_CODE = p_PRODUCT_CODE)  OR
         ((Recinfo.PRODUCT_CODE IS NULL) AND
          (p_PRODUCT_CODE IS NULL))) AND
        ((Recinfo.PRODUCT_CATEGORY = p_PRODUCT_CATEGORY)  OR
         ((Recinfo.PRODUCT_CATEGORY IS NULL) AND
          (p_PRODUCT_CATEGORY IS NULL))) AND
        ((Recinfo.MERCHANT_PARTY_ID = p_MERCHANT_PARTY_ID)  OR
         ((Recinfo.MERCHANT_PARTY_ID IS NULL) AND
          (p_MERCHANT_PARTY_ID IS NULL))) AND
        ((Recinfo.ACCOUNT_CCID = p_ACCOUNT_CCID)  OR
         ((Recinfo.ACCOUNT_CCID IS NULL) AND
          (p_ACCOUNT_CCID IS NULL))) AND
        ((Recinfo.ACCOUNT_STRING = p_ACCOUNT_STRING)  OR
         ((Recinfo.ACCOUNT_STRING IS NULL) AND
          (p_ACCOUNT_STRING IS NULL))) AND
        ((Recinfo.REF_DOC_LINE_ID = p_REF_DOC_LINE_ID)  OR
         ((Recinfo.REF_DOC_LINE_ID IS NULL) AND
          (p_REF_DOC_LINE_ID IS NULL))) AND
        ((Recinfo.REF_DOC_LINE_QUANTITY = p_REF_DOC_LINE_QUANTITY)  OR
         ((Recinfo.REF_DOC_LINE_QUANTITY IS NULL) AND
          (p_REF_DOC_LINE_QUANTITY IS NULL))) AND
        ((Recinfo.REF_DOC_APPLICATION_ID = p_REF_DOC_APPLICATION_ID)  OR
         ((Recinfo.REF_DOC_APPLICATION_ID IS NULL) AND
          (p_REF_DOC_APPLICATION_ID IS NULL))) AND
        ((Recinfo.REF_DOC_ENTITY_CODE = p_REF_DOC_ENTITY_CODE)  OR
         ((Recinfo.REF_DOC_ENTITY_CODE IS NULL) AND
          (p_REF_DOC_ENTITY_CODE IS NULL))) AND
        ((Recinfo.REF_DOC_EVENT_CLASS_CODE = p_REF_DOC_EVENT_CLASS_CODE)  OR
         ((Recinfo.REF_DOC_EVENT_CLASS_CODE IS NULL) AND
          (p_REF_DOC_EVENT_CLASS_CODE IS NULL))) AND
        ((Recinfo.REF_DOC_TRX_ID = p_REF_DOC_TRX_ID)  OR
         ((Recinfo.REF_DOC_TRX_ID IS NULL) AND
          (p_REF_DOC_TRX_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_LINE_ID = p_APPLIED_FROM_LINE_ID)  OR
         ((Recinfo.APPLIED_FROM_LINE_ID IS NULL) AND
          (p_APPLIED_FROM_LINE_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_APPLICATION_ID = p_APPLIED_FROM_APPLICATION_ID)  OR
         ((Recinfo.APPLIED_FROM_APPLICATION_ID IS NULL) AND
          (p_APPLIED_FROM_APPLICATION_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_ENTITY_CODE = p_APPLIED_FROM_ENTITY_CODE)  OR
         ((Recinfo.APPLIED_FROM_ENTITY_CODE IS NULL) AND
          (p_APPLIED_FROM_ENTITY_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_EVENT_CLASS_CODE = p_APPLIED_FROM_EVT_CLASS_CODE)  OR
         ((Recinfo.APPLIED_FROM_EVENT_CLASS_CODE IS NULL) AND
          (p_APPLIED_FROM_EVT_CLASS_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_ID = p_APPLIED_FROM_TRX_ID)  OR
         ((Recinfo.APPLIED_FROM_TRX_ID IS NULL) AND
          (p_APPLIED_FROM_TRX_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_LINE_ID = p_ADJUSTED_DOC_LINE_ID)  OR
         ((Recinfo.ADJUSTED_DOC_LINE_ID IS NULL) AND
          (p_ADJUSTED_DOC_LINE_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_DATE = p_ADJUSTED_DOC_DATE)  OR
         ((Recinfo.ADJUSTED_DOC_DATE IS NULL) AND
          (p_ADJUSTED_DOC_DATE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_APPLICATION_ID = p_ADJUSTED_DOC_APPLICATION_ID)  OR
         ((Recinfo.ADJUSTED_DOC_APPLICATION_ID IS NULL) AND
          (p_ADJUSTED_DOC_APPLICATION_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_ENTITY_CODE = p_ADJUSTED_DOC_ENTITY_CODE)  OR
         ((Recinfo.ADJUSTED_DOC_ENTITY_CODE IS NULL) AND
          (p_ADJUSTED_DOC_ENTITY_CODE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_EVENT_CLASS_CODE = p_ADJ_DOC_EVENT_CLASS_CODE)  OR
         ((Recinfo.ADJUSTED_DOC_EVENT_CLASS_CODE IS NULL) AND
          (p_ADJ_DOC_EVENT_CLASS_CODE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TRX_ID = p_ADJUSTED_DOC_TRX_ID)  OR
         ((Recinfo.ADJUSTED_DOC_TRX_ID IS NULL) AND
          (p_ADJUSTED_DOC_TRX_ID IS NULL))) AND
        ((Recinfo.TRX_LINE_DESCRIPTION = p_TRX_LINE_DESCRIPTION)  OR
         ((Recinfo.TRX_LINE_DESCRIPTION IS NULL) AND
          (p_TRX_LINE_DESCRIPTION IS NULL))) AND
        ((Recinfo.PRODUCT_DESCRIPTION = p_PRODUCT_DESCRIPTION)  OR
         ((Recinfo.PRODUCT_DESCRIPTION IS NULL) AND
          (p_PRODUCT_DESCRIPTION IS NULL))) AND
        ((Recinfo.TRX_LINE_GL_DATE = p_TRX_LINE_GL_DATE)  OR
         ((Recinfo.TRX_LINE_GL_DATE IS NULL) AND
          (p_TRX_LINE_GL_DATE IS NULL))) AND
        ((Recinfo.LINE_LEVEL_ACTION = p_LINE_LEVEL_ACTION)  OR
         ((Recinfo.LINE_LEVEL_ACTION IS NULL) AND
          (p_LINE_LEVEL_ACTION IS NULL))) AND
        ((Recinfo.Historical_Flag = p_Historical_Flag)  OR
         ((Recinfo.Historical_Flag IS NULL) AND
          (p_Historical_Flag IS NULL))) AND
        ((Recinfo.BILL_FROM_PARTY_SITE_ID = p_BILL_FROM_PARTY_SITE_ID)  OR
         ((Recinfo.BILL_FROM_PARTY_SITE_ID IS NULL) AND
          (p_BILL_FROM_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.BILL_TO_PARTY_SITE_ID = p_BILL_TO_PARTY_SITE_ID)  OR
         ((Recinfo.BILL_TO_PARTY_SITE_ID IS NULL) AND
          (p_BILL_TO_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.SHIP_FROM_PARTY_SITE_ID = p_SHIP_FROM_PARTY_SITE_ID)  OR
         ((Recinfo.SHIP_FROM_PARTY_SITE_ID IS NULL) AND
          (p_SHIP_FROM_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.SHIP_TO_PARTY_SITE_ID = p_SHIP_TO_PARTY_SITE_ID)  OR
         ((Recinfo.SHIP_TO_PARTY_SITE_ID IS NULL) AND
          (p_SHIP_TO_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.SHIP_TO_PARTY_ID = p_SHIP_TO_PARTY_ID)  OR
         ((Recinfo.SHIP_TO_PARTY_ID IS NULL) AND
          (p_SHIP_TO_PARTY_ID IS NULL))) AND
        ((Recinfo.SHIP_FROM_PARTY_ID = p_SHIP_FROM_PARTY_ID)  OR
         ((Recinfo.SHIP_FROM_PARTY_ID IS NULL) AND
          (p_SHIP_FROM_PARTY_ID IS NULL))) AND
        ((Recinfo.BILL_TO_PARTY_ID = p_BILL_TO_PARTY_ID)  OR
         ((Recinfo.BILL_TO_PARTY_ID IS NULL) AND
          (p_BILL_TO_PARTY_ID IS NULL))) AND
        ((Recinfo.BILL_FROM_PARTY_ID = p_BILL_FROM_PARTY_ID)  OR
         ((Recinfo.BILL_FROM_PARTY_ID IS NULL) AND
          (p_BILL_FROM_PARTY_ID IS NULL))) AND
        ((Recinfo.SHIP_TO_LOCATION_ID = p_SHIP_TO_LOCATION_ID)  OR
         ((Recinfo.SHIP_TO_LOCATION_ID IS NULL) AND
          (p_SHIP_TO_LOCATION_ID IS NULL))) AND
        ((Recinfo.SHIP_FROM_LOCATION_ID = p_SHIP_FROM_LOCATION_ID)  OR
         ((Recinfo.SHIP_FROM_LOCATION_ID IS NULL) AND
          (p_SHIP_FROM_LOCATION_ID IS NULL))) AND
        ((Recinfo.BILL_TO_LOCATION_ID = p_BILL_TO_LOCATION_ID)  OR
         ((Recinfo.BILL_TO_LOCATION_ID IS NULL) AND
          (p_BILL_TO_LOCATION_ID IS NULL))) AND
        ((Recinfo.BILL_FROM_LOCATION_ID = p_BILL_FROM_LOCATION_ID)  OR
         ((Recinfo.BILL_FROM_LOCATION_ID IS NULL) AND
          (p_BILL_FROM_LOCATION_ID IS NULL))) AND
        ((Recinfo.POA_LOCATION_ID = p_POA_LOCATION_ID)  OR
         ((Recinfo.POA_LOCATION_ID IS NULL) AND
          (p_POA_LOCATION_ID IS NULL))) AND
        ((Recinfo.POO_LOCATION_ID = p_POO_LOCATION_ID)  OR
         ((Recinfo.POO_LOCATION_ID IS NULL) AND
          (p_POO_LOCATION_ID IS NULL))) AND
        ((Recinfo.PAYING_LOCATION_ID = p_PAYING_LOCATION_ID)  OR
         ((Recinfo.PAYING_LOCATION_ID IS NULL) AND
          (p_PAYING_LOCATION_ID IS NULL))) AND
        ((Recinfo.OWN_HQ_LOCATION_ID = p_OWN_HQ_LOCATION_ID)  OR
         ((Recinfo.OWN_HQ_LOCATION_ID IS NULL) AND
          (p_OWN_HQ_LOCATION_ID IS NULL))) AND
        ((Recinfo.TRADING_HQ_LOCATION_ID = p_TRADING_HQ_LOCATION_ID)  OR
         ((Recinfo.TRADING_HQ_LOCATION_ID IS NULL) AND
          (p_TRADING_HQ_LOCATION_ID IS NULL))) AND
        ((Recinfo.POC_LOCATION_ID = p_POC_LOCATION_ID)  OR
         ((Recinfo.POC_LOCATION_ID IS NULL) AND
          (p_POC_LOCATION_ID IS NULL))) AND
        ((Recinfo.POI_LOCATION_ID = p_POI_LOCATION_ID)  OR
         ((Recinfo.POI_LOCATION_ID IS NULL) AND
          (p_POI_LOCATION_ID IS NULL))) AND
        ((Recinfo.POD_LOCATION_ID = p_POD_LOCATION_ID)  OR
         ((Recinfo.POD_LOCATION_ID IS NULL) AND
          (p_POD_LOCATION_ID IS NULL))) AND
        ((Recinfo.TAX_REGIME_ID = p_TAX_REGIME_ID)  OR
         ((Recinfo.TAX_REGIME_ID IS NULL) AND
          (p_TAX_REGIME_ID IS NULL))) AND
        ((Recinfo.TAX_REGIME_CODE = p_TAX_REGIME_CODE)  OR
         ((Recinfo.TAX_REGIME_CODE IS NULL) AND
          (p_TAX_REGIME_CODE IS NULL))) AND
        ((Recinfo.TAX_ID = p_TAX_ID)  OR
         ((Recinfo.TAX_ID IS NULL) AND
          (p_TAX_ID IS NULL))) AND
        ((Recinfo.TAX = p_TAX)  OR
         ((Recinfo.TAX IS NULL) AND
          (p_TAX IS NULL))) AND
        ((Recinfo.TAX_STATUS_ID = p_TAX_STATUS_ID)  OR
         ((Recinfo.TAX_STATUS_ID IS NULL) AND
          (p_TAX_STATUS_ID IS NULL))) AND
        ((Recinfo.TAX_STATUS_CODE = p_TAX_STATUS_CODE)  OR
         ((Recinfo.TAX_STATUS_CODE IS NULL) AND
          (p_TAX_STATUS_CODE IS NULL))) AND
        ((Recinfo.TAX_RATE_ID = p_TAX_RATE_ID)  OR
         ((Recinfo.TAX_RATE_ID IS NULL) AND
          (p_TAX_RATE_ID IS NULL))) AND
        ((Recinfo.TAX_RATE_CODE = p_TAX_RATE_CODE)  OR
         ((Recinfo.TAX_RATE_CODE IS NULL) AND
          (p_TAX_RATE_CODE IS NULL))) AND
        ((Recinfo.TAX_RATE = p_TAX_RATE)  OR
         ((Recinfo.TAX_RATE IS NULL) AND
          (p_TAX_RATE IS NULL))) AND
        ((Recinfo.TAX_LINE_AMT = p_TAX_LINE_AMT)  OR
         ((Recinfo.TAX_LINE_AMT IS NULL) AND
          (p_TAX_LINE_AMT IS NULL))) AND
        ((Recinfo.LINE_CLASS = p_LINE_CLASS )  OR
         ((Recinfo.LINE_CLASS IS NULL) AND
          (p_LINE_CLASS IS NULL))) AND
        ((Recinfo.INPUT_TAX_CLASSIFICATION_CODE  = p_INPUT_TAX_CLASSIF_CODE) OR
         ((Recinfo.INPUT_TAX_CLASSIFICATION_CODE IS NULL) AND
          (p_INPUT_TAX_CLASSIF_CODE IS NULL))) AND
        ((Recinfo.OUTPUT_TAX_CLASSIFICATION_CODE = p_OUTPUT_TAX_CLASSIF_CODE) OR
         ((Recinfo.OUTPUT_TAX_CLASSIFICATION_CODE IS NULL) AND
          (p_OUTPUT_TAX_CLASSIF_CODE IS NULL))) AND
        ((Recinfo.REF_DOC_TRX_LEVEL_TYPE = p_REF_DOC_TRX_LEVEL_TYPE ) OR
         ((Recinfo.REF_DOC_TRX_LEVEL_TYPE IS NULL) AND
          (p_REF_DOC_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.APPLIED_TO_TRX_LEVEL_TYPE = p_APPLIED_TO_TRX_LEVEL_TYPE ) OR
         ((Recinfo.APPLIED_TO_TRX_LEVEL_TYPE IS NULL) AND
          (p_APPLIED_TO_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_LEVEL_TYPE = p_APPLIED_FROM_TRX_LEVEL_TYPE  ) OR
         ((Recinfo.APPLIED_FROM_TRX_LEVEL_TYPE IS NULL) AND
          (p_APPLIED_FROM_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TRX_LEVEL_TYPE = p_ADJUSTED_DOC_TRX_LEVEL_TYPE  ) OR
         ((Recinfo.ADJUSTED_DOC_TRX_LEVEL_TYPE IS NULL) AND
          (p_ADJUSTED_DOC_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.EXEMPTION_CONTROL_FLAG = p_EXEMPTION_CONTROL_FLAG ) OR
         ((Recinfo.EXEMPTION_CONTROL_FLAG IS NULL) AND
          (p_EXEMPTION_CONTROL_FLAG IS NULL))) AND
        ((Recinfo.EXEMPT_REASON_CODE = p_EXEMPT_REASON_CODE  ) OR
         ((Recinfo.EXEMPT_REASON_CODE  IS NULL) AND
          (p_EXEMPT_REASON_CODE IS NULL))) AND
        ((Recinfo.EXEMPT_CERTIFICATE_NUMBER = p_EXEMPT_CERTIFICATE_NUMBER) OR
         ((Recinfo.EXEMPT_CERTIFICATE_NUMBER IS NULL) AND
          (p_EXEMPT_CERTIFICATE_NUMBER IS NULL))) AND
        ((Recinfo.EXEMPT_REASON = p_EXEMPT_REASON ) OR
         ((Recinfo.EXEMPT_REASON IS NULL) AND
          (p_EXEMPT_REASON IS NULL))) AND
        ((Recinfo.CASH_DISCOUNT = p_CASH_DISCOUNT ) OR
         ((Recinfo.CASH_DISCOUNT IS NULL) AND
          (p_CASH_DISCOUNT IS NULL))) AND
        ((Recinfo.VOLUME_DISCOUNT = p_VOLUME_DISCOUNT ) OR
         ((Recinfo.VOLUME_DISCOUNT IS NULL) AND
          (p_VOLUME_DISCOUNT IS NULL))) AND
        ((Recinfo.TRADING_DISCOUNT = p_TRADING_DISCOUNT ) OR
         ((Recinfo.TRADING_DISCOUNT IS NULL) AND
          (p_TRADING_DISCOUNT IS NULL))) AND
        ((Recinfo.TRANSFER_CHARGE = p_TRANSFER_CHARGE ) OR
         ((Recinfo.TRANSFER_CHARGE IS NULL) AND
          (p_TRANSFER_CHARGE IS NULL))) AND
        ((Recinfo.TRANSPORTATION_CHARGE = p_TRANSPORTATION_CHARGE ) OR
         ((Recinfo.TRANSPORTATION_CHARGE IS NULL) AND
          (p_TRANSPORTATION_CHARGE IS NULL))) AND
        ((Recinfo.INSURANCE_CHARGE = p_INSURANCE_CHARGE ) OR
         ((Recinfo.INSURANCE_CHARGE IS NULL) AND
          (p_INSURANCE_CHARGE IS NULL))) AND
        ((Recinfo.OTHER_CHARGE = p_OTHER_CHARGE ) OR
         ((Recinfo.OTHER_CHARGE IS NULL) AND
          (p_OTHER_CHARGE IS NULL))) AND
        ((Recinfo.RECEIVABLES_TRX_TYPE_ID = p_RECEIVABLES_TRX_TYPE_ID  ) OR
         ((Recinfo.RECEIVABLES_TRX_TYPE_ID IS NULL) AND
          (p_RECEIVABLES_TRX_TYPE_ID IS NULL))) AND
        ((Recinfo.CTRL_HDR_TX_APPL_FLAG = p_CTRL_HDR_TX_APPL_FLAG  ) OR
         ((Recinfo.CTRL_HDR_TX_APPL_FLAG IS NULL) AND
          (p_CTRL_HDR_TX_APPL_FLAG IS NULL))) AND
        ((Recinfo.CTRL_TOTAL_LINE_TX_AMT = p_CTRL_TOTAL_LINE_TX_AMT ) OR
         ((Recinfo.CTRL_TOTAL_LINE_TX_AMT IS NULL) AND
          (p_CTRL_TOTAL_LINE_TX_AMT IS NULL))) AND
        (Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) AND
        (Recinfo.CREATED_BY = p_CREATED_BY) AND
        (Recinfo.CREATION_DATE = p_CREATION_DATE) AND
        (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY) AND
        (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE) AND
        ((Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)  OR
         ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND
          (p_LAST_UPDATE_LOGIN IS NULL)))            ) THEN
      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Lock_row.END',
                     'ZX_TRX_DETAIL: Lock_row (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRX_DETAIL.Lock_Row',
                       p_error_buffer);
      END IF;

  END Lock_Row;

  PROCEDURE Insert_Temporary_Table
       (p_application_id              NUMBER,
        p_entity_code                 VARCHAR2,
        p_event_class_code            VARCHAR2,
        p_trx_id                      NUMBER,
        p_event_type_code             VARCHAR2,
        p_ledger_id                   NUMBER,
        p_reporting_currency_code     VARCHAR2,
        p_currency_conversion_date    DATE,
        p_currency_conversion_type    VARCHAR2,
        p_currency_conversion_rate    NUMBER,
        p_minimum_accountable_unit    NUMBER,
        p_status                      VARCHAR2 DEFAULT NULL,
        p_precision                   NUMBER,
        p_line_level_action           VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_data         OUT NOCOPY VARCHAR2 ) IS

    l_return_status        VARCHAR2(30);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(5000);
    l_msg_string           VARCHAR2(5000);
    sid                    NUMBER;
    l_error_buffer         VARCHAR2(256);
    l_tax_event_type_code  VARCHAR2(30);
    debug_info             VARCHAR2(100);
    l_trx_line_type        VARCHAR2(30);
    l_count                NUMBER;
    l_trx_lines_sync       NUMBER;
    l_trx_lines            NUMBER;
    l_sync_trx_rec         ZX_API_PUB.sync_trx_rec_type;
    l_sync_trx_lines_rec   ZX_API_PUB.sync_trx_lines_rec_type;
    i                      NUMBER;

    CURSOR sync_trx_lines_rec IS
      SELECT APPLICATION_ID,
             ENTITY_CODE,
             EVENT_CLASS_CODE,
             TRX_ID,
             TRX_LEVEL_TYPE,
             TRX_LINE_ID,
             NULL TRX_WAYBILL_NUMBER,
             TRX_LINE_DESCRIPTION,
             PRODUCT_DESCRIPTION,
             TRX_LINE_GL_DATE,
             NULL MERCHANT_PARTY_NAME,
             NULL MERCHANT_PARTY_DOCUMENT_NUMBER,
             NULL MERCHANT_PARTY_REFERENCE,
             NULL MERCHANT_PARTY_TAXPAYER_ID,
             NULL MERCHANT_PARTY_TAX_REG_NUMBER,
             NULL ASSET_NUMBER
      FROM ZX_TRANSACTION_LINES
      WHERE APPLICATION_ID = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id
      AND TRX_LINE_TYPE    <> 'TAX';

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table.BEGIN',
                     'ZX_TRX_DETAIL: Insert_Temporary_Table (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                     'Event: Event Type Code :'||p_event_type_code);

    END IF;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Tables',
                     'Insert into zx_trx_headers_gt (+)');
    END IF;

      INSERT INTO ZX_TRX_HEADERS_GT (INTERNAL_ORGANIZATION_ID,
                                             INTERNAL_ORG_LOCATION_ID,
                                             APPLICATION_ID,
                                             ENTITY_CODE,
                                             EVENT_CLASS_CODE,
                                             EVENT_TYPE_CODE,
                                             TRX_ID,
                                             TRX_DATE,
                                             --TRX_DOC_REVISION,
                                             LEDGER_ID,
                                             TRX_CURRENCY_CODE,
                                             CURRENCY_CONVERSION_DATE,
                                             CURRENCY_CONVERSION_RATE,
                                             CURRENCY_CONVERSION_TYPE,
                                             MINIMUM_ACCOUNTABLE_UNIT,
                                             PRECISION,
                                             LEGAL_ENTITY_ID,
                                             ROUNDING_SHIP_TO_PARTY_ID,
                                             ROUNDING_SHIP_FROM_PARTY_ID,
                                             ROUNDING_BILL_TO_PARTY_ID,
                                             ROUNDING_BILL_FROM_PARTY_ID,
                                             RNDG_SHIP_TO_PARTY_SITE_ID,
                                             RNDG_SHIP_FROM_PARTY_SITE_ID,
                                             RNDG_BILL_TO_PARTY_SITE_ID,
                                             RNDG_BILL_FROM_PARTY_SITE_ID,
                                             ESTABLISHMENT_ID,
                                             RECEIVABLES_TRX_TYPE_ID,
                                             --RELATED_DOC_APPLICATION_ID,
                                             --RELATED_DOC_ENTITY_CODE,
                                             --RELATED_DOC_EVENT_CLASS_CODE,
                                             --RELATED_DOC_TRX_ID,
                                             --REL_DOC_HDR_TRX_USER_KEY1,
                                             --REL_DOC_HDR_TRX_USER_KEY2,
                                             --REL_DOC_HDR_TRX_USER_KEY3,
                                             --REL_DOC_HDR_TRX_USER_KEY4,
                                             --REL_DOC_HDR_TRX_USER_KEY5,
                                             --REL_DOC_HDR_TRX_USER_KEY6,
                                             --RELATED_DOC_NUMBER,
                                             --RELATED_DOC_DATE,
                                             DEFAULT_TAXATION_COUNTRY,
                                             Quote_Flag,
                                             CTRL_TOTAL_HDR_TX_AMT,
                                             TRX_NUMBER,
                                             TRX_DESCRIPTION,
                                             --TRX_COMMUNICATED_DATE,
                                             --BATCH_SOURCE_ID,
                                             --BATCH_SOURCE_NAME,
                                             --DOC_SEQ_ID,
                                             --DOC_SEQ_NAME,
                                             --DOC_SEQ_VALUE,
                                             --TRX_DUE_DATE,
                                             --TRX_TYPE_DESCRIPTION,
                                             --BILLING_TRADING_PARTNER_NAME,
                                             --BILLING_TRADING_PARTNER_NUMBER,
                                             --Billing_Tp_Tax_Reporting_Flag,
                                             --BILLING_TP_TAXPAYER_ID,
                                             DOCUMENT_SUB_TYPE,
                                             SUPPLIER_TAX_INVOICE_NUMBER,
                                             SUPPLIER_TAX_INVOICE_DATE,
                                             SUPPLIER_EXCHANGE_RATE,
                                             TAX_INVOICE_DATE,
                                             TAX_INVOICE_NUMBER,
                                             FIRST_PTY_ORG_ID,
                                             PORT_OF_ENTRY_CODE,
                                             TAX_REPORTING_FLAG,
                                             SHIP_TO_CUST_ACCT_SITE_USE_ID,
                                             BILL_TO_CUST_ACCT_SITE_USE_ID,
                                             PROVNL_TAX_DETERMINATION_DATE,
                                             APPLIED_TO_TRX_NUMBER,
                                             SHIP_THIRD_PTY_ACCT_ID,
                                             BILL_THIRD_PTY_ACCT_ID,
                                             SHIP_THIRD_PTY_ACCT_SITE_ID,
                                             BILL_THIRD_PTY_ACCT_SITE_ID,
                                             VALIDATION_CHECK_FLAG,
                                             --TAX_EVENT_CLASS_CODE,
                                             TAX_EVENT_TYPE_CODE
                                             --DOC_EVENT_STATUS,
                                             --RDNG_SHIP_TO_PTY_TX_PROF_ID,
                                             --RDNG_SHIP_FROM_PTY_TX_PROF_ID,
                                             --RDNG_BILL_TO_PTY_TX_PROF_ID,
                                             --RDNG_BILL_FROM_PTY_TX_PROF_ID,
                                             --RDNG_SHIP_TO_PTY_TX_P_ST_ID,
                                             --RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
                                             --RDNG_BILL_TO_PTY_TX_P_ST_ID,
                                             --RDNG_BILL_FROM_PTY_TX_P_ST_ID
                                             )
                                      SELECT internal_organization_id,
                                             internal_org_location_id,
                                             application_id,
                                             entity_code,
                                             event_class_code,
                                             event_type_code,
                                             trx_id,
                                             trx_date,
                                             --p_trx_doc_revision,
                                             ledger_id,
                                             trx_currency_code,
                                             currency_conversion_date,
                                             currency_conversion_rate,
                                             currency_conversion_type,
                                             minimum_accountable_unit,
                                             precision,
                                             legal_entity_id,
                                             rounding_ship_to_party_id,
                                             rounding_ship_from_party_id,
                                             rounding_bill_to_party_id,
                                             rounding_bill_from_party_id,
                                             rndg_ship_to_party_site_id,
                                             rndg_ship_from_party_site_id,
                                             rndg_bill_to_party_site_id,
                                             rndg_bill_from_party_site_id,
                                             establishment_id,
                                             receivables_trx_type_id,
                                             --p_related_doc_application_id,
                                             --p_related_doc_entity_code,
                                             --p_related_doc_evt_class_code,  --reduced size p_related_doc_event_class_code
                                             --p_related_doc_trx_id,
                                             --p_rel_doc_hdr_trx_user_key1,
                                             --p_rel_doc_hdr_trx_user_key2,
                                             --p_rel_doc_hdr_trx_user_key3,
                                             --p_rel_doc_hdr_trx_user_key4,
                                             --p_rel_doc_hdr_trx_user_key5,
                                             --p_rel_doc_hdr_trx_user_key6,
                                             --p_related_doc_number,
                                             --p_related_doc_date,
                                             default_taxation_country,
                                             Quote_Flag,
                                             ctrl_total_hdr_tx_amt,
                                             trx_number,
                                             trx_description,
                                             --p_trx_communicated_date,
                                             --p_batch_source_id,
                                             --p_batch_source_name,
                                             --p_doc_seq_id,
                                             --p_doc_seq_name,
                                             --p_doc_seq_value,
                                             --p_trx_due_date,
                                             --p_trx_type_description,
                                             --p_billing_trad_partner_name,  --reduced size p_billing_trading_partner_name
                                             --p_billing_trad_partner_number,  --reduced size p_billing_trading_partner_number
                                             --p_billing_tp_tax_report_flg,  --reduced size p_Billing_Tp_Tax_Reporting_Flag
                                             --p_billing_tp_taxpayer_id,
                                             document_sub_type,
                                             supplier_tax_invoice_number,
                                             supplier_tax_invoice_date,
                                             supplier_exchange_rate,
                                             tax_invoice_date,
                                             tax_invoice_number,
                                             first_pty_org_id,
                                             port_of_entry_code,
                                             tax_reporting_flag,
                                             ship_to_cust_acct_site_use_id,
                                             bill_to_cust_acct_site_use_id,
                                             provnl_tax_determination_date,
                                             applied_to_trx_number,
                                             ship_third_pty_acct_id,
                                             bill_third_pty_acct_id,
                                             ship_third_pty_acct_site_id,
                                             bill_third_pty_acct_site_id,
                                             validation_check_flag,
                                             --p_tax_event_class_code,
                                             tax_event_type_code--p_tax_event_type_code,
                                             --p_doc_event_status,
                                             --p_rdng_ship_to_pty_tx_prof_id,
                                             --p_rdng_ship_fr_pty_tx_prof_id,  --reduced size p_rdng_ship_from_pty_tx_prof_id
                                             --p_rdng_bill_to_pty_tx_prof_id,
                                             --p_rdng_bill_fr_pty_tx_prof_id,  --reduced size p_rdng_bill_from_pty_tx_prof_id
                                             --p_rdng_ship_to_pty_tx_p_st_id,
                                             --p_rdng_ship_fr_pty_tx_p_st_id,  --reduced size p_rdng_ship_from_pty_tx_p_st_id
                                             --p_rdng_bill_to_pty_tx_p_st_id,
                                             --p_rdng_bill_fr_pty_tx_p_st_id);  --reduced size p_rdng_bill_from_pty_tx_p_st_id
                                        FROM ZX_TRANSACTION
                                        WHERE APPLICATION_ID = p_application_id
                                        AND ENTITY_CODE      = p_entity_code
                                        AND EVENT_CLASS_CODE = p_event_class_code
                                        AND TRX_ID           = p_trx_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                     'Insert into zx_trx_headers_gt (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                     'Insert into ZX_TRANSACTION_LINES_GT (+)');
    END IF;

      INSERT INTO ZX_TRANSACTION_LINES_GT (APPLICATION_ID,
                                           ENTITY_CODE,
                                           EVENT_CLASS_CODE,
                                           TRX_ID,
                                           TRX_LEVEL_TYPE,
                                           TRX_LINE_ID,
                                           LINE_LEVEL_ACTION,
                                           TRX_SHIPPING_DATE,
                                           TRX_RECEIPT_DATE,
                                           TRX_LINE_TYPE,
                                           TRX_LINE_DATE,
                                           TRX_BUSINESS_CATEGORY,
                                           LINE_INTENDED_USE,
                                           USER_DEFINED_FISC_CLASS,
                                           LINE_AMT,
                                           TRX_LINE_QUANTITY,
                                           UNIT_PRICE,
                                           EXEMPT_CERTIFICATE_NUMBER,
                                           EXEMPT_REASON,
                                           CASH_DISCOUNT,
                                           VOLUME_DISCOUNT,
                                           TRADING_DISCOUNT,
                                           TRANSFER_CHARGE,
                                           TRANSPORTATION_CHARGE,
                                           INSURANCE_CHARGE,
                                           OTHER_CHARGE,
                                           PRODUCT_ID,
                                           PRODUCT_FISC_CLASSIFICATION,
                                           PRODUCT_ORG_ID,
                                           UOM_CODE,
                                           PRODUCT_TYPE,
                                           PRODUCT_CODE,
                                           PRODUCT_CATEGORY,
                                           --TRX_SIC_CODE,
                                           --FOB_POINT,
                                           SHIP_TO_PARTY_ID,
                                           SHIP_FROM_PARTY_ID,
                                           POA_PARTY_ID,
                                           POO_PARTY_ID,
                                           BILL_TO_PARTY_ID,
                                           BILL_FROM_PARTY_ID,
                                           MERCHANT_PARTY_ID,
                                           SHIP_TO_PARTY_SITE_ID,
                                           SHIP_FROM_PARTY_SITE_ID,
                                           POA_PARTY_SITE_ID,
                                           POO_PARTY_SITE_ID,
                                           BILL_TO_PARTY_SITE_ID,
                                           BILL_FROM_PARTY_SITE_ID,
                                           SHIP_TO_LOCATION_ID,
                                           SHIP_FROM_LOCATION_ID,
                                           POA_LOCATION_ID,
                                           POO_LOCATION_ID,
                                           BILL_TO_LOCATION_ID,
                                           BILL_FROM_LOCATION_ID,
                                           ACCOUNT_CCID,
                                           ACCOUNT_STRING,
                                           MERCHANT_PARTY_COUNTRY,
                                           REF_DOC_APPLICATION_ID,
                                           REF_DOC_ENTITY_CODE,
                                           REF_DOC_EVENT_CLASS_CODE,
                                           REF_DOC_TRX_ID,
                                           REF_DOC_LINE_ID,
                                           REF_DOC_LINE_QUANTITY,
                                           APPLIED_FROM_APPLICATION_ID,
                                           APPLIED_FROM_ENTITY_CODE,
                                           APPLIED_FROM_EVENT_CLASS_CODE,
                                           APPLIED_FROM_TRX_ID,
                                           APPLIED_FROM_LINE_ID,
                                           ADJUSTED_DOC_APPLICATION_ID,
                                           ADJUSTED_DOC_ENTITY_CODE,
                                           ADJUSTED_DOC_EVENT_CLASS_CODE,
                                           ADJUSTED_DOC_TRX_ID,
                                           ADJUSTED_DOC_LINE_ID,
                                           --ADJUSTED_DOC_NUMBER,
                                           ADJUSTED_DOC_DATE,
                                           APPLIED_TO_APPLICATION_ID,
                                           APPLIED_TO_ENTITY_CODE,
                                           APPLIED_TO_EVENT_CLASS_CODE,
                                           APPLIED_TO_TRX_ID,
                                           APPLIED_TO_TRX_LINE_ID,
                                           --TRX_ID_LEVEL2,
                                           --TRX_ID_LEVEL3,
                                           --TRX_ID_LEVEL4,
                                           --TRX_ID_LEVEL5,
                                           --TRX_ID_LEVEL6,
                                           TRX_LINE_NUMBER,
                                           TRX_LINE_DESCRIPTION,
                                           PRODUCT_DESCRIPTION,
                                           --TRX_WAYBILL_NUMBER,
                                           TRX_LINE_GL_DATE,
                                           --MERCHANT_PARTY_NAME,
                                           --MERCHANT_PARTY_DOCUMENT_NUMBER,
                                           --MERCHANT_PARTY_REFERENCE,
                                           --MERCHANT_PARTY_TAXPAYER_ID,
                                           --MERCHANT_PARTY_TAX_REG_NUMBER,
                                           --PAYING_PARTY_ID,
                                           --OWN_HQ_PARTY_ID,
                                           --TRADING_HQ_PARTY_ID,
                                           --POI_PARTY_ID,
                                           --POD_PARTY_ID,
                                           --TITLE_TRANSFER_PARTY_ID,
                                           --PAYING_PARTY_SITE_ID,
                                           --OWN_HQ_PARTY_SITE_ID,
                                           --TRADING_HQ_PARTY_SITE_ID,
                                           --POI_PARTY_SITE_ID,
                                           --POD_PARTY_SITE_ID,
                                           --TITLE_TRANSFER_PARTY_SITE_ID,
                                           PAYING_LOCATION_ID,
                                           OWN_HQ_LOCATION_ID,
                                           TRADING_HQ_LOCATION_ID,
                                           POC_LOCATION_ID,
                                           POI_LOCATION_ID,
                                           POD_LOCATION_ID,
                                           --TITLE_TRANSFER_LOCATION_ID,
                                           --BANKING_TP_TAXPAYER_ID,
                                           --ASSESSABLE_VALUE,
                                           --ASSET_FLAG,
                                           --ASSET_NUMBER,
                                           --ASSET_ACCUM_DEPRECIATION,
                                           --ASSET_TYPE,
                                           --ASSET_COST,
                                           --NUMERIC1,
                                           --NUMERIC2,
                                           --NUMERIC3,
                                           --NUMERIC4,
                                           --NUMERIC5,
                                           --NUMERIC6,
                                           --NUMERIC7,
                                           --NUMERIC8,
                                           --NUMERIC9,
                                           --NUMERIC10,
                                           --CHAR1,
                                           --CHAR2,
                                           --CHAR3,
                                           --CHAR4,
                                           --CHAR5,
                                           --CHAR6,
                                           --CHAR7,
                                           --CHAR8,
                                           --CHAR9,
                                           --CHAR10,
                                           --DATE1,
                                           --DATE2,
                                           --DATE3,
                                           --DATE4,
                                           --DATE5,
                                           --DATE6,
                                           --DATE7,
                                           --DATE8,
                                           --DATE9,
                                           --DATE10,
                                           --SHIP_TO_PARTY_TAX_PROF_ID,
                                           --SHIP_FROM_PARTY_TAX_PROF_ID,
                                           --POA_PARTY_TAX_PROF_ID,
                                           --POO_PARTY_TAX_PROF_ID,
                                           --PAYING_PARTY_TAX_PROF_ID,
                                           --OWN_HQ_PARTY_TAX_PROF_ID,
                                           --TRADING_HQ_PARTY_TAX_PROF_ID,
                                           --POI_PARTY_TAX_PROF_ID,
                                           --POD_PARTY_TAX_PROF_ID,
                                           --BILL_TO_PARTY_TAX_PROF_ID,
                                           --BILL_FROM_PARTY_TAX_PROF_ID,
                                           --TITLE_TRANS_PARTY_TAX_PROF_ID,
                                           --SHIP_TO_SITE_TAX_PROF_ID,
                                           --SHIP_FROM_SITE_TAX_PROF_ID,
                                           --POA_SITE_TAX_PROF_ID,
                                           --POO_SITE_TAX_PROF_ID,
                                           --PAYING_SITE_TAX_PROF_ID,
                                           --OWN_HQ_SITE_TAX_PROF_ID,
                                           --TRADING_HQ_SITE_TAX_PROF_ID,
                                           --POI_SITE_TAX_PROF_ID,
                                           --POD_SITE_TAX_PROF_ID,
                                           --BILL_TO_SITE_TAX_PROF_ID,
                                           --BILL_FROM_SITE_TAX_PROF_ID,
                                           --TITLE_TRANS_SITE_TAX_PROF_ID,
                                           --MERCHANT_PARTY_TAX_PROF_ID,
                                           LINE_CLASS,
                                           INPUT_TAX_CLASSIFICATION_CODE,
                                           OUTPUT_TAX_CLASSIFICATION_CODE,
                                           REF_DOC_TRX_LEVEL_TYPE,
                                           APPLIED_TO_TRX_LEVEL_TYPE,
                                           APPLIED_FROM_TRX_LEVEL_TYPE,
                                           ADJUSTED_DOC_TRX_LEVEL_TYPE,
                                           EXEMPTION_CONTROL_FLAG,
                                           EXEMPT_REASON_CODE,
                                           --RECEIVABLES_TRX_TYPE_ID,  bug#4288610
                                           CTRL_HDR_TX_APPL_FLAG,
                                           CTRL_TOTAL_LINE_TX_AMT,
                                           LINE_AMT_INCLUDES_TAX_FLAG,
                                           HISTORICAL_FLAG
                                           --TAX_CLASSIFICATION_CODE
                                           )
                                    SELECT application_id,
                                           entity_code,
                                           event_class_code,
                                           trx_id,
                                           trx_level_type,
                                           trx_line_id,
                                           line_level_action,
                                           trx_shipping_date,
                                           trx_receipt_date,
                                           trx_line_type,
                                           trx_line_date,
                                           trx_business_category,
                                           line_intended_use,
                                           user_defined_fisc_class,
                                           line_amt,
                                           trx_line_quantity,
                                           unit_price,
                                           exempt_certificate_number,
                                           exempt_reason,
                                           cash_discount,
                                           volume_discount,
                                           trading_discount,
                                           transfer_charge,
                                           transportation_charge,
                                           insurance_charge,
                                           other_charge,
                                           product_id,
                                           product_fisc_classification,
                                           product_org_id,
                                           uom_code,
                                           DECODE(product_type, 'MEMOS', NULL,
                                                  product_type) product_type,
                                           product_code,
                                           product_category,
                                           --p_trx_sic_code,
                                           --p_fob_point,
                                           ship_to_party_id,
                                           ship_from_party_id,
                                           poa_party_id,
                                           poo_party_id,
                                           bill_to_party_id,
                                           bill_from_party_id,
                                           merchant_party_id,
                                           ship_to_party_site_id,
                                           ship_from_party_site_id,
                                           poa_party_site_id,
                                           poo_party_site_id,
                                           bill_to_party_site_id,
                                           bill_from_party_site_id,
                                           ship_to_location_id,
                                           ship_from_location_id,
                                           poa_location_id,
                                           poo_location_id,
                                           bill_to_location_id,
                                           bill_from_location_id,
                                           account_ccid,
                                           account_string,
                                           merchant_party_country,
                                           ref_doc_application_id,
                                           ref_doc_entity_code,
                                           ref_doc_event_class_code,
                                           ref_doc_trx_id,
                                           ref_doc_line_id,
                                           ref_doc_line_quantity,
                                           applied_from_application_id,
                                           applied_from_entity_code,
                                           applied_from_event_class_code,
                                           applied_from_trx_id,
                                           applied_from_line_id,
                                           adjusted_doc_application_id,
                                           adjusted_doc_entity_code,
                                           adjusted_doc_event_class_code,
                                           adjusted_doc_trx_id,
                                           adjusted_doc_line_id,
                                           --adjusted_doc_number,
                                           adjusted_doc_date,
                                           applied_to_application_id,
                                           applied_to_entity_code,
                                           applied_to_event_class_code,
                                           applied_to_trx_id,
                                           applied_to_trx_line_id,
                                           --p_trx_id_level2,
                                           --p_trx_id_level3,
                                           --p_trx_id_level4,
                                           --p_trx_id_level5,
                                           --p_trx_id_level6,
                                           trx_line_number,
                                           trx_line_description,
                                           product_description,
                                           --trx_waybill_number,
                                           trx_line_gl_date,
                                           --p_merchant_party_name,
                                           --p_merchant_party_doc_number,
                                           --p_merchant_party_reference,
                                           --p_merchant_party_taxpayer_id,
                                           --p_merchant_pty_tax_reg_number,
                                           --p_paying_party_id,
                                           --p_own_hq_party_id,
                                           --p_trading_hq_party_id,
                                           --p_poi_party_id,
                                           --p_pod_party_id,
                                           --p_title_transfer_party_id,
                                           --p_paying_party_site_id,
                                           --p_own_hq_party_site_id,
                                           --p_trading_hq_party_site_id,
                                           --p_poi_party_site_id,
                                           --p_pod_party_site_id,
                                           --p_title_transfer_pty_site_id,
                                           paying_location_id,
                                           own_hq_location_id,
                                           trading_hq_location_id,
                                           poc_location_id,
                                           poi_location_id,
                                           pod_location_id,
                                           --p_title_transfer_location_id,
                                           --p_banking_tp_taxpayer_id,
                                           --p_assessable_value,
                                           --p_asset_flag,
                                           --p_asset_number,
                                           --p_asset_accum_depreciation,
                                           --p_asset_type,
                                           --p_asset_cost,
                                           --p_numeric1,
                                           --p_numeric2,
                                           --p_numeric3,
                                           --p_numeric4,
                                           --p_numeric5,
                                           --p_numeric6,
                                           --p_numeric7,
                                           --p_numeric8,
                                           --p_numeric9,
                                           --p_numeric10,
                                           --p_char1,
                                           --p_char2,
                                           --p_char3,
                                           --p_char4,
                                           --p_char5,
                                           --p_char6,
                                           --p_char7,
                                           --p_char8,
                                           --p_char9,
                                           --p_char10,
                                           --p_date1,
                                           --p_date2,
                                           --p_date3,
                                           --p_date4,
                                           --p_date5,
                                           --p_date6,
                                           --p_date7,
                                           --p_date8,
                                           --p_date9,
                                           --p_date10,
                                           --p_ship_to_party_tax_prof_id,
                                           --p_ship_from_party_tax_prof_id,
                                           --p_poa_party_tax_prof_id,
                                           --p_poo_party_tax_prof_id,
                                           --p_paying_party_tax_prof_id,
                                           --p_own_hq_party_tax_prof_id,
                                           --p_trading_hq_pty_tax_prof_id,
                                           --p_poi_party_tax_prof_id,
                                           --p_pod_party_tax_prof_id,
                                           --p_bill_to_party_tax_prof_id,
                                           --p_bill_from_party_tax_prof_id,
                                           --p_title_trans_pty_tax_prof_id,
                                           --p_ship_to_site_tax_prof_id,
                                           --p_ship_from_site_tax_prof_id,
                                           --p_poa_site_tax_prof_id,
                                           --p_poo_site_tax_prof_id,
                                           --p_paying_site_tax_prof_id,
                                           --p_own_hq_site_tax_prof_id,
                                           --p_trading_hq_site_tax_prof_id,
                                           --p_poi_site_tax_prof_id,
                                           --p_pod_site_tax_prof_id,
                                           --p_bill_to_site_tax_prof_id,
                                           --p_bill_from_site_tax_prof_id,
                                           --p_title_trn_site_tax_prof_id,
                                           --p_merchant_party_tax_prof_id,
                                           line_class,
                                           input_tax_classification_code,
                                           output_tax_classification_code,
                                           ref_doc_trx_level_type,
                                           applied_to_trx_level_type,
                                           applied_from_trx_level_type,
                                           adjusted_doc_trx_level_type,
                                           nvl(exemption_control_flag,'S'),  -- Bug 5211670
                                           exempt_reason_code,
                                           --receivables_trx_type_id, will add later
                                           ctrl_hdr_tx_appl_flag,
                                           ctrl_total_line_tx_amt,
                                           line_amt_includes_tax_flag,
                                           historical_flag
                                           --p_tax_classification_code
                                      FROM ZX_TRANSACTION_LINES
                                      WHERE APPLICATION_ID = p_application_id
                                      AND ENTITY_CODE      = p_entity_code
                                      AND EVENT_CLASS_CODE = p_event_class_code
                                      AND TRX_ID           = p_trx_id
                                      AND TRX_LINE_TYPE    <> 'TAX';


      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                       'Insert to ZX_TRANSACTION_LINES_GT, count : ' ||
                       TO_CHAR(SQL%ROWCOUNT));
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                       'Insert into ZX_TRANSACTION_LINES_GT (-)');
      END IF;

      IF p_status = 'SIMULATOR_IMPORT' THEN
        RETURN;
      END IF;


      IF p_event_type_code = 'STANDARD UPDATED' AND
         p_line_level_action = 'SYNCHRONIZE' THEN

        SELECT APPLICATION_ID,
               ENTITY_CODE,
               EVENT_CLASS_CODE,
               EVENT_TYPE_CODE,
               TRX_ID,
               TRX_NUMBER,
               TRX_DESCRIPTION,
               NULL TRX_COMMUNICATED_DATE,
               NULL BATCH_SOURCE_ID,
               NULL BATCH_SOURCE_NAME,
               NULL DOC_SEQ_ID,
               NULL DOC_SEQ_NAME,
               NULL DOC_SEQ_VALUE,
               NULL TRX_DUE_DATE,
               NULL TRX_TYPE_DESCRIPTION,
               NULL SUPPLIER_TAX_INVOICE_NUMBER,
               NULL SUPPLIER_TAX_INVOICE_DATE,
               NULL SUPPLIER_EXCHANGE_RATE,
               NULL TAX_INVOICE_DATE,
               NULL TAX_INVOICE_NUMBER,
               NULL PORT_OF_ENTRY_CODE
        INTO l_sync_trx_rec.APPLICATION_ID,
             l_sync_trx_rec.ENTITY_CODE,
             l_sync_trx_rec.EVENT_CLASS_CODE,
             l_sync_trx_rec.EVENT_TYPE_CODE,
             l_sync_trx_rec.TRX_ID,
             l_sync_trx_rec.TRX_NUMBER,
             l_sync_trx_rec.TRX_DESCRIPTION,
             l_sync_trx_rec.TRX_COMMUNICATED_DATE,
             l_sync_trx_rec.BATCH_SOURCE_ID,
             l_sync_trx_rec.BATCH_SOURCE_NAME,
             l_sync_trx_rec.DOC_SEQ_ID,
             l_sync_trx_rec.DOC_SEQ_NAME,
             l_sync_trx_rec.DOC_SEQ_VALUE,
             l_sync_trx_rec.TRX_DUE_DATE,
             l_sync_trx_rec.TRX_TYPE_DESCRIPTION,
             l_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER,
             l_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE,
             l_sync_trx_rec.SUPPLIER_EXCHANGE_RATE,
             l_sync_trx_rec.TAX_INVOICE_DATE,
             l_sync_trx_rec.TAX_INVOICE_NUMBER,
             l_sync_trx_rec.PORT_OF_ENTRY_CODE
        FROM ZX_TRANSACTION
        WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE      = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID           = p_trx_id;

        OPEN sync_trx_lines_rec;
        debug_info := 'Fetch cursor sync_trx_lines_rec';

        i :=i + 1;

        FETCH sync_trx_lines_rec INTO l_sync_trx_lines_rec.APPLICATION_ID(i),
                                      l_sync_trx_lines_rec.ENTITY_CODE(i),
                                      l_sync_trx_lines_rec.EVENT_CLASS_CODE(i),
                                      l_sync_trx_lines_rec.TRX_ID(i),
                                      l_sync_trx_lines_rec.TRX_LEVEL_TYPE(i),
                                      l_sync_trx_lines_rec.TRX_LINE_ID(i),
                                      l_sync_trx_lines_rec.TRX_WAYBILL_NUMBER(i),
                                      l_sync_trx_lines_rec.TRX_LINE_DESCRIPTION(i),
                                      l_sync_trx_lines_rec.PRODUCT_DESCRIPTION(i),
                                      l_sync_trx_lines_rec.TRX_LINE_GL_DATE(i),
                                      l_sync_trx_lines_rec.MERCHANT_PARTY_NAME(i),
                                      l_sync_trx_lines_rec.MERCHANT_PARTY_DOCUMENT_NUMBER(i),
                                      l_sync_trx_lines_rec.MERCHANT_PARTY_REFERENCE(i),
                                      l_sync_trx_lines_rec.MERCHANT_PARTY_TAXPAYER_ID(i),
                                      l_sync_trx_lines_rec.MERCHANT_PARTY_TAX_REG_NUMBER(i),
                                      l_sync_trx_lines_rec.ASSET_NUMBER(i);

        IF (sync_trx_lines_rec%NOTFOUND) THEN
          debug_info := 'Close cursor C - DATA NOTFOUND';
          CLOSE sync_trx_lines_rec;
          FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
          APP_EXCEPTION.Raise_Exception;
        END IF;

        debug_info := 'Close cursor sync_trx_lines_rec';
        CLOSE sync_trx_lines_rec;

      END IF;

      BEGIN

        IF p_status = 'SIMULATOR_CONDITIONS' THEN
          IF (g_level_procedure >= g_current_runtime_level ) THEN

            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'API ZX_SIM_CONDITIONS_PKG.create_sim_conditions (+)');
          END IF;

          ZX_SIM_CONDITIONS_PKG.create_sim_conditions(p_return_status => l_return_status,
                                            p_error_buffer  => l_msg_data);

          IF (g_level_procedure >= g_current_runtime_level ) THEN

            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'API ZX_SIM_CONDITIONS_PKG.create_sim_conditions (-)');
          END IF;


        ELSIF p_event_type_code = 'STANDARD UPDATED' AND
              p_line_level_action = 'SYNCHRONIZE' THEN

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'API zx_api_pub.synchronize_tax_repository (+)');
          END IF;

          BEGIN
            SELECT COUNT(*)
            INTO l_trx_lines_sync
            FROM ZX_TRANSACTION_LINES
            WHERE LINE_LEVEL_ACTION = 'SYNCHORONIZE'
            AND APPLICATION_ID   = p_application_id
            AND ENTITY_CODE      = p_entity_code
            AND EVENT_CLASS_CODE = p_event_class_code
            AND TRX_ID           = p_trx_id;

            SELECT COUNT(*)
            INTO l_trx_lines
            FROM ZX_TRANSACTION_LINES
            WHERE APPLICATION_ID   = p_application_id
            AND ENTITY_CODE      = p_entity_code
            AND EVENT_CLASS_CODE = p_event_class_code
            AND TRX_ID           = p_trx_id;

            IF l_trx_lines > l_trx_lines_sync and l_trx_lines_sync <> 0 THEN


              ZX_API_PUB.CALCULATE_TAX(p_api_version      => 1.0,
                                       p_init_msg_list    => FND_API.G_TRUE,
                                       p_commit           => NULL,
                                       p_validation_level => NULL,
                                       x_return_status    => l_return_status,
                                       x_msg_count        => l_msg_count,
                                       x_msg_data         => l_msg_data);

              IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure,
                               'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                               'After calling ZX_API_PUB.CALCULATE_TAX from 1,' ||
                               'l_return_status : ' || TO_CHAR(l_return_status) ||
                               ' ' || 'l_msg_count :' || TO_CHAR(l_msg_count));
              END IF;

	      x_return_status := l_return_status;

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 IF l_msg_count = 1 THEN
                   x_msg_data := l_msg_data;
                 ELSE
                   -- need to fetch more messages

                   get_error_msg(
                         p_trx_id,
                         p_application_id,
                         p_entity_code,
                         p_event_class_code,
                         l_return_status,
                         x_msg_data);
                 END IF;
               END IF;

              mark_reporting_only_flag(
                      p_trx_id,
                      p_application_id,
                      p_entity_code,
                      p_event_class_code,
                      l_return_status,
                      l_error_buffer,
		      'N');

            ELSIF l_trx_lines = l_trx_lines_sync THEN

              ZX_API_PUB.SYNCHRONIZE_TAX_REPOSITORY (p_api_version      => 1.0,
                                                     p_init_msg_list    => FND_API.G_TRUE,
                                                     p_commit           => NULL,
                                                     p_validation_level => NULL,
                                                     x_return_status    => l_return_status,
                                                     x_msg_count        => l_msg_count,
                                                     x_msg_data         => l_msg_data,
                                                     p_sync_trx_rec        => NULL,
                                                     p_sync_trx_lines_tbl  => NULL);

              ZX_API_PUB.CALCULATE_TAX(p_api_version      => 1.0,
                                       p_init_msg_list    => FND_API.G_TRUE,
                                       p_commit           => NULL,
                                       p_validation_level => NULL,
                                       x_return_status    => l_return_status,
                                       x_msg_count        => l_msg_count,
                                       x_msg_data         => l_msg_data);


              IF (g_level_procedure >= g_current_runtime_level ) THEN
                FND_LOG.STRING(g_level_procedure,
                               'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                               'After calling ZX_API_PUB.CALCULATE_TAX from 2, ' ||
                               'l_return_status : ' || TO_CHAR(l_return_status) ||
                               ' ' || 'l_msg_count :' || TO_CHAR(l_msg_count));
              END IF;

	      x_return_status := l_return_status;

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                 IF l_msg_count = 1 THEN
                   x_msg_data := l_msg_data;
                 ELSE
                   -- need to fetch more messages

                   get_error_msg(
                         p_trx_id,
                         p_application_id,
                         p_entity_code,
                         p_event_class_code,
                         l_return_status,
                         x_msg_data);
                 END IF;
               END IF;

	    END IF;
          END;

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'API zx_api_pub.synchronize_tax_repository (-)');
          END IF;

        ELSE

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'API zx_api_pub.calculate_tax for CREATE (+)');
          END IF;


          ZX_API_PUB.CALCULATE_TAX(p_api_version      => 1.0,
                                   p_init_msg_list    => FND_API.G_TRUE,
                                   p_commit           => NULL,
                                   p_validation_level => NULL,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data);

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'After calling ZX_API_PUB.CALCULATE_TAX from 3,' ||
                           'l_return_status : ' || TO_CHAR(l_return_status) ||
                           ' ' || 'l_msg_count :' || TO_CHAR(l_msg_count));
          END IF;

	  x_return_status := l_return_status;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_msg_count = 1 THEN
              x_msg_data := l_msg_data;
            ELSE
              -- need to fetch more messages

              get_error_msg(
                    p_trx_id,
                    p_application_id,
                    p_entity_code,
                    p_event_class_code,
                    l_return_status,
                    x_msg_data);
            END IF;
          END IF;

	  mark_reporting_only_flag(
                      p_trx_id,
                      p_application_id,
                      p_entity_code,
                      p_event_class_code,
                      l_return_status,
                      l_error_buffer,
		      'N');

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'API zx_api_pub.calculate_tax for CREATE (-)');
          END IF;


        END IF;

        IF l_return_status = 'S' THEN

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'Update_Transaction_Lines (+)');
          END IF;

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                           'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                           'Update_Transaction_Lines (-)');
          END IF;

        END IF;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                         'Return Status = ' || l_return_status);
        END IF;
      END;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table.END',
                       'ZX_TRX_DETAIL: Insert_Temporary_Table (-)');
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRX_DETAIL.Insert_Temporary_Table',
                       l_error_buffer);
      END IF;
  END Insert_Temporary_Table;

/******************************************************
  PROCEDURE Update_Transaction_Lines
       (p_application_id      NUMBER,
        p_entity_code         VARCHAR2,
        p_event_class_code    VARCHAR2,
        p_trx_id              NUMBER) IS

    l_return_status        VARCHAR2(1000);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(1000);
    sid                    NUMBER;
    p_error_buffer         VARCHAR2(100);
    l_tax_event_type_code  VARCHAR2(30);
    debug_info             VARCHAR2(100);

    CURSOR TRX_LINE_TAX IS
      SELECT TLS.TRX_LINE_ID,
             TLS.TRX_LINE_NUMBER
      FROM ZX_TRANSACTION_LINES TLS
      WHERE TLS.APPLICATION_ID = p_application_id
      AND TLS.ENTITY_CODE      = p_entity_code
      AND TLS.EVENT_CLASS_CODE = p_event_class_code
      AND TLS.TRX_ID           = p_trx_id
      AND TLS.TRX_LINE_TYPE    = 'TAX';

    Recinfo TRX_LINE_TAX%ROWTYPE;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines.BEGIN',
                     'ZX_TRX_DETAIL: Update_Transaction_Lines (+)');
    END IF;

    debug_info := 'Open cursor TRX_LINE_TAX';
    OPEN TRX_LINE_TAX;
    debug_info := 'Fetch cursor TRX_LINE_TAX';

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines',
                     'Update ZX_TRANSACTION_LINES (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines',
                     'Delete ZX_TRANSACTION_LINES (+)');
    END IF;

    DELETE FROM ZX_TRANSACTION_LINES
      WHERE APPLICATION_ID = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id
      AND TRX_LINE_TYPE    = 'TAX';

    --commit;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines',
                     'Delete ZX_TRANSACTION_LINES (-)');
    END IF;

      LOOP

      FETCH TRX_LINE_TAX INTO Recinfo;

      IF (TRX_LINE_TAX%NOTFOUND) THEN
        debug_info := 'Close cursor TRX_LINE_TAX - DATA NOTFOUND';
        CLOSE TRX_LINE_TAX;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
      END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines',
                     'Insert ZX_TRANSACTION_LINES (+)');
    END IF;

      INSERT INTO ZX_TRANSACTION_LINES (APPLICATION_ID,
                                        ENTITY_CODE,
                                        EVENT_CLASS_CODE,
                                        TRX_LINE_ID,
                                        TRX_LINE_NUMBER,
                                        TRX_ID,
                                        TRX_LEVEL_TYPE,
                                        TRX_LINE_TYPE,
                                        TRX_LINE_DATE,
                                        HISTORICAL_FLAG,
                                        TAX_REGIME_ID,
                                        TAX_REGIME_CODE,
                                        TAX_ID,
                                        TAX,
                                        TAX_STATUS_ID,
                                        TAX_STATUS_CODE,
                                        TAX_RATE_ID,
                                        TAX_RATE_CODE,
                                        TAX_RATE,
                                        TAX_LINE_AMT)
                                 SELECT APPLICATION_ID,
                                        ENTITY_CODE,
                                        EVENT_CLASS_CODE,
                                        Recinfo.TRX_LINE_ID,
                                        Recinfo.TRX_LINE_NUMBER,
                                        TRX_ID,
                                        TRX_LEVEL_TYPE,
                                        'TAX' TRX_LINE_TYPE,
                                        TRX_LINE_DATE,
                                        HISTORICAL_FLAG,
                                        TAX_REGIME_ID,
                                        TAX_REGIME_CODE,
                                        TAX_ID,
                                        TAX,
                                        TAX_STATUS_ID,
                                        TAX_STATUS_CODE,
                                        TAX_RATE_ID,
                                        TAX_RATE_CODE,
                                        TAX_RATE,
                                        LINE_AMT
                                   FROM ZX_LINES
                                   WHERE APPLICATION_ID = p_application_id
                                   AND ENTITY_CODE      = p_entity_code
                                   AND EVENT_CLASS_CODE = p_event_class_code
                                   AND TRX_ID           = p_trx_id;
      END LOOP;

    debug_info := 'Close cursor TRX_LINE_TAX';
    CLOSE TRX_LINE_TAX;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines',
                     'Insert ZX_TRANSACTION_LINES (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines',
                     'Update ZX_TRANSACTION_LINES (-)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines.END',
                     'ZX_TRX_DETAIL: Update_Transaction_Lines (-)');
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

        FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
        FND_MSG_PUB.Add;

        IF (g_level_unexpected >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_unexpected,
                         'ZX.PLSQL.ZX_TRX_DETAIL.Update_Transaction_Lines',
                         p_error_buffer);
        END IF;
  END Update_Transaction_Lines;
************************************************************/


-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  mark_reporting_only_flag
--
--  DESCRIPTION
--
--  This procedure marks the reporting_only_flag to 'N' or 'Y'  so
--  these lines will be reported based on the flag value.
--
--

PROCEDURE mark_reporting_only_flag(
        p_trx_id                IN    NUMBER,
        p_application_id        IN    NUMBER,
        p_entity_code           IN    VARCHAR2,
        p_event_class_code      IN    VARCHAR2,
        p_return_status           OUT NOCOPY VARCHAR2,
        p_error_buffer            OUT NOCOPY VARCHAR2,
	p_reporting_flag        IN  VARCHAR2)
IS

BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.mark_reporting_only_flag.BEGIN',
                   'ZX_TRX_DETAIL: mark_reporting_only_flag(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  UPDATE ZX_LINES
  SET
    REPORTING_ONLY_FLAG = p_reporting_flag ,
    LAST_UPDATED_BY = fnd_global.user_id ,
    LAST_UPDATE_DATE = SYSDATE ,
    LAST_UPDATE_LOGIN = fnd_global.conc_login_id ,
    OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
    WHERE APPLICATION_ID   = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id;

IF (p_reporting_flag= 'N' ) THEN

  UPDATE ZX_LINES_SUMMARY
    SET   REPORTING_ONLY_FLAG = 'N'
    WHERE APPLICATION_ID   = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id;

END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.mark_reporting_only_flag.END',
                   'ZX_TRX_DETAIL: mark_reporting_only_flag (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRX_DETAIL.mark_reporting_only_flag',
                      p_error_buffer);
    END IF;

END mark_reporting_only_flag;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  perform_purge
--
--  DESCRIPTION
--
--  This procedure deletes all tax lines related created by
--  Tax Simulator.
--
--
  PROCEDURE perform_purge(
        p_count                IN     NUMBER,
        p_application_id_tbl   IN     APPLICATION_ID_TBL,
        p_entity_code_tbl      IN     ENTITY_CODE_TBL,
        p_event_class_code_tbl IN     EVENT_CLASS_CODE_TBL,
        p_trx_id_tbl           IN     TRX_ID_TBL,
        p_return_status           OUT NOCOPY VARCHAR2,
        p_error_buffer            OUT NOCOPY VARCHAR2)
IS
BEGIN

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge.BEGIN',
                   'ZX_TRX_DETAIL: perform_purge(+)');
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge',
                   'Deleting rows from ZX_LINES');
  END IF;

  FORALL i IN  1 .. p_count
    DELETE  ZX_LINES
      WHERE APPLICATION_ID   = p_application_id_tbl(i)
        AND ENTITY_CODE      = p_entity_code_tbl(i)
        AND EVENT_CLASS_CODE = p_event_class_code_tbl(i)
        AND TRX_ID           = p_trx_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge',
                   'Deleting rows from ZX_LINES_SUMMARY');
  END IF;

  FORALL i IN  1 .. p_count
    DELETE  ZX_LINES_SUMMARY
      WHERE APPLICATION_ID   = p_application_id_tbl(i)
        AND ENTITY_CODE      = p_entity_code_tbl(i)
        AND EVENT_CLASS_CODE = p_event_class_code_tbl(i)
        AND TRX_ID           = p_trx_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge',
                   'Deleting rows from ZX_REC_NREC_DIST');
  END IF;

  FORALL i IN  1 .. p_count
    DELETE  ZX_REC_NREC_DIST
      WHERE APPLICATION_ID   = p_application_id_tbl(i)
        AND ENTITY_CODE      = p_entity_code_tbl(i)
        AND EVENT_CLASS_CODE = p_event_class_code_tbl(i)
        AND TRX_ID           = p_trx_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge',
                   'Deleting rows from ZX_LINES_DET_FACTORS');
  END IF;

  FORALL i IN  1 .. p_count
    DELETE  ZX_LINES_DET_FACTORS
      WHERE APPLICATION_ID   = p_application_id_tbl(i)
        AND ENTITY_CODE      = p_entity_code_tbl(i)
        AND EVENT_CLASS_CODE = p_event_class_code_tbl(i)
        AND TRX_ID           = p_trx_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge',
                   'Deleting rows from ZX_TRANSACTION');
  END IF;

  FORALL i IN  1 .. p_count
    DELETE  ZX_TRANSACTION
      WHERE APPLICATION_ID   = p_application_id_tbl(i)
        AND ENTITY_CODE      = p_entity_code_tbl(i)
        AND EVENT_CLASS_CODE = p_event_class_code_tbl(i)
        AND TRX_ID           = p_trx_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge',
                   'Deleting rows from ZX_TRANSACTION_LINES');
  END IF;

  FORALL i IN  1 .. p_count
    DELETE  ZX_TRANSACTION_LINES
      WHERE APPLICATION_ID   = p_application_id_tbl(i)
        AND ENTITY_CODE      = p_entity_code_tbl(i)
        AND EVENT_CLASS_CODE = p_event_class_code_tbl(i)
        AND TRX_ID           = p_trx_id_tbl(i);

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge',
                   'Deleting rows from ZX_SIM_TRX_DISTS');
  END IF;

  FORALL i IN  1 .. p_count
    DELETE  ZX_SIM_TRX_DISTS
      WHERE APPLICATION_ID   = p_application_id_tbl(i)
        AND ENTITY_CODE      = p_entity_code_tbl(i)
        AND EVENT_CLASS_CODE = p_event_class_code_tbl(i)
        AND TRX_ID           = p_trx_id_tbl(i);

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge.END',
                   'ZX_TRX_DETAIL: perform_purge (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRX_DETAIL.perform_purge',
                      p_error_buffer);
    END IF;

END perform_purge;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_purge
--
--  DESCRIPTION
--
--  This procedure purges all tax lines related data
--  based on the transaction id passed in
--
--
  PROCEDURE process_purge(
        p_trx_id                       NUMBER)

IS
  l_application_id_tbl         APPLICATION_ID_TBL;
  l_entity_code_tbl            ENTITY_CODE_TBL;
  l_event_class_code_tbl       EVENT_CLASS_CODE_TBL;
  l_trx_id_tbl                 TRX_ID_TBL;
  l_count                      NUMBER;
  l_return_status              VARCHAR2(30);
  l_error_buffer               VARCHAR2(256);

  CURSOR get_purge_single_csr
    (c_trx_id                 NUMBER)
  IS
    SELECT  APPLICATION_ID,
            ENTITY_CODE,
            EVENT_CLASS_CODE,
            TRX_ID
      FROM  ZX_SIM_PURGE
      WHERE TRX_ID = c_trx_id;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.process_purge.BEGIN',
                   'ZX_TRX_DETAIL: process_purge(+)');
   FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.process_purge',
                   'p_trx_id = ' || TO_CHAR(p_trx_id));
  END IF;

  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  OPEN get_purge_single_csr(p_trx_id);
  FETCH get_purge_single_csr INTO
    l_application_id_tbl(1),
    l_entity_code_tbl(1),
    l_event_class_code_tbl(1),
    l_trx_id_tbl(1);
  CLOSE get_purge_single_csr;

  l_count := 1;
  perform_purge(
    l_count,
    l_application_id_tbl,
    l_entity_code_tbl,
    l_event_class_code_tbl,
    l_trx_id_tbl,
    l_return_status,
    l_error_buffer);

  IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
    --
    -- delete row from ZX_SIM_PURGE table
    --
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.process_purge',
                     'Deleting from ZX_SIM_PURGE table');
    END IF;

    DELETE  ZX_SIM_PURGE
      WHERE TRX_ID = p_trx_id;
  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.process_purge.END',
                   'ZX_TRX_DETAIL: process_purge (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRX_DETAIL.process_purge',
                      l_error_buffer);
    END IF;

END process_purge;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_purge
--
--  DESCRIPTION
--
--  This procedure purges all tax lines related data
--  created by Tax Simulator
--
--
PROCEDURE process_purge (
  errbuf                      OUT NOCOPY varchar2,
  retcode                     OUT NOCOPY number )
IS
  l_application_id_tbl         APPLICATION_ID_TBL;
  l_entity_code_tbl            ENTITY_CODE_TBL;
  l_event_class_code_tbl       EVENT_CLASS_CODE_TBL;
  l_trx_id_tbl                 TRX_ID_TBL;
  l_count                      NUMBER;
  l_return_status              VARCHAR2(30);
  l_error_buffer               VARCHAR2(256);

  CURSOR get_purge_all_csr
  IS
   SELECT  APPLICATION_ID,
           ENTITY_CODE,
           EVENT_CLASS_CODE,
           TRX_ID
     FROM  ZX_SIM_PURGE;

BEGIN

  g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (g_level_statement >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_statement,
                   'ZX.PLSQL.ZX_TRX_DETAIL.process_purge.BEGIN',
                   'ZX_TRX_DETAIL: process_purge(+)');
  END IF;

  l_return_status :=  FND_API.G_RET_STS_SUCCESS;

  OPEN get_purge_all_csr;
  LOOP
    FETCH get_purge_all_csr BULK COLLECT INTO
      l_application_id_tbl,
      l_entity_code_tbl,
      l_event_class_code_tbl,
      l_trx_id_tbl
    LIMIT C_LINES_PER_COMMIT;

    l_count := l_trx_id_tbl.COUNT;

    IF (g_level_statement >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_statement,
                     'ZX.PLSQL.ZX_TRX_DETAIL.process_purge',
                     'l_count = ' || TO_CHAR(l_count));
    END IF;

    IF l_count > 0 THEN

      perform_purge(
        l_count,
        l_application_id_tbl,
        l_entity_code_tbl,
        l_event_class_code_tbl,
        l_trx_id_tbl,
        l_return_status,
        l_error_buffer);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        EXIT;
      END IF;
    ELSE
      --
      -- no more records to process
      --
      EXIT;
    END IF;
  END LOOP;

  CLOSE get_purge_all_csr;

  IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
    --
    -- delete ZX_SIM_PURGE table
    --
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_DETAIL.process_purge',
                     'Deleting ZX_SIM_PURGE table');
    END IF;

    DELETE  ZX_SIM_PURGE;

  END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.process_purge.END',
                   'ZX_TRX_DETAIL: process_purge (-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRX_DETAIL.process_purge',
                      l_error_buffer);
    END IF;

END process_purge;

-----------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  process_import_doc_with_tax
--
--  DESCRIPTION
--
--  This procedure processes import document with tax
--
--
PROCEDURE process_import_doc_with_tax
       (p_application_id              NUMBER,
        p_entity_code                 VARCHAR2,
        p_event_class_code            VARCHAR2,
        p_trx_id                      NUMBER)
IS
  l_msg_count                      NUMBER;
  l_return_status              VARCHAR2(30);
  l_error_buffer               VARCHAR2(256);
  l_msg_data                   VARCHAR2(1000);

BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.process_import_doc_with_tax.BEGIN',
                   'ZX_TRX_DETAIL: process_import_doc_with_tax(+)');
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.process_import_doc_with_tax',
                   'Inserting into ZX_IMPORT_TAX_LINES_GT (+)');
  END IF;

    INSERT INTO ZX_IMPORT_TAX_LINES_GT (
                                            SUMMARY_TAX_LINE_NUMBER,
                                            INTERNAL_ORGANIZATION_ID,
                                            APPLICATION_ID,
                                            ENTITY_CODE,
                                            EVENT_CLASS_CODE,
                                            TRX_ID,
                                            TAX_LINE_ALLOCATION_FLAG,
                                            TAX_REGIME_CODE,
                                            TAX,
                                            TAX_STATUS_CODE,
                                            TAX_RATE_CODE,
                                            TAX_RATE,
                                            TAX_AMT)
                                     SELECT TRL.TRX_LINE_NUMBER,
                                            TRX.INTERNAL_ORGANIZATION_ID,
                                            TRL.APPLICATION_ID,
                                            TRL.ENTITY_CODE,
                                            TRL.EVENT_CLASS_CODE,
                                            TRL.TRX_ID,
                                            'N',
                                            TRL.TAX_REGIME_CODE,
                                            TRL.TAX,
                                            TRL.TAX_STATUS_CODE,
                                            TRL.TAX_RATE_CODE,
                                            TRL.TAX_RATE,
                                            TRL.TAX_LINE_AMT
                                     FROM ZX_TRANSACTION_LINES TRL,
                                          ZX_TRANSACTION TRX
                                     WHERE TRL.TRX_ID         = TRX.trx_id
                                     AND TRL.APPLICATION_ID   = p_application_id
                                     AND TRL.ENTITY_CODE      = p_entity_code
                                     AND TRL.EVENT_CLASS_CODE = p_event_class_code
                                     AND TRL.TRX_ID           = p_trx_id
                                     AND TRL.TRX_LINE_TYPE    = 'TAX';

        IF (g_level_procedure >= g_current_runtime_level ) THEN

          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRX_DETAIL.process_import_doc_with_tax',
                         'Inserted into ZX_IMPORT_TAX_LINES_GT (-)');
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRX_DETAIL.process_import_doc_with_tax',
                         'calling ZX_API_PUB.IMPORT_DOCUMENT_WITH_TAX (+)');
        END IF;


        ZX_API_PUB.IMPORT_DOCUMENT_WITH_TAX(
                                                p_api_version      => 1.0,
                                                p_init_msg_list    => NULL,
                                                p_commit           => NULL,
                                                p_validation_level => NULL,
                                                x_return_status    => l_return_status,
                                                x_msg_count        => l_msg_count,
                                                x_msg_data         => l_msg_data);
          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRX_DETAIL.process_import_doc_with_tax',
                         'calling ZX_API_PUB.IMPORT_DOCUMENT_WITH_TAX (-)');

            FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.process_import_doc_with_tax.END',
                   'ZX_TRX_DETAIL: process_import_doc_with_tax(-)');
          END IF;


EXCEPTION
  WHEN OTHERS THEN
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);
    FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
    FND_MSG_PUB.Add;

    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRX_DETAIL.process_import_doc_with_tax',
                      l_error_buffer);
    END IF;

END process_import_doc_with_tax;

-----------------------------------------------------------------------
--  PRIVATE PROCEDURE
--  get_error_msg
--
--  DESCRIPTION
--
--  This procedure gets all error messages returned from internal
--  services during tax calculation proccess.
--
--
PROCEDURE get_error_msg(
        p_trx_id                IN    NUMBER,
        p_application_id        IN    NUMBER,
        p_entity_code           IN    VARCHAR2,
        p_event_class_code      IN    VARCHAR2,
        p_return_status         IN    VARCHAR2,
        x_msg_data                OUT NOCOPY VARCHAR2)

IS

  l_count                      NUMBER;
  l_error_msg                  ZX_ERRORS_GT.message_text%TYPE;

  TYPE msg_string_tbl IS TABLE OF
    ZX_ERRORS_GT.message_text%TYPE
  INDEX BY BINARY_INTEGER;

  l_msg_string_tbl             MSG_STRING_TBL;

  CURSOR c_get_error_msg(
              c_trx_id                NUMBER,
              c_event_class_code      VARCHAR2,
              c_application_id        NUMBER,
              c_entity_code           VARCHAR2)
  IS
    SELECT message_text
      FROM ZX_ERRORS_GT
      WHERE trx_id           = c_trx_id
        AND event_class_code = c_event_class_code
        AND application_id   = c_application_id
        AND entity_code      = c_entity_code;


BEGIN
  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.get_error_msg.BEGIN',
                   'ZX_TRX_DETAIL: get_error_msg(+)');
  END IF;

  x_msg_data := NULL;

  IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    LOOP
      l_error_msg := FND_MSG_PUB.GET(FND_MSG_PUB.G_NEXT,
                                     FND_API.G_FALSE);

      IF l_error_msg IS NULL THEN
        EXIT;
      ELSE
        x_msg_data := x_msg_data ||'. '|| l_error_msg;
      END IF;
    END LOOP;
  ELSIF p_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    --
    -- should be FND_API.G_RET_STS_ERROR but
    -- currently many are set at wrong
    -- status of FND_API.G_RET_STS_UNEXP_ERROR
    --
    --
    -- need to fetch error messages from zx_errors_gt
    --
    OPEN c_get_error_msg(
                      p_trx_id,
                      p_event_class_code,
                      p_application_id,
                      p_entity_code);
    LOOP
      FETCH c_get_error_msg BULK COLLECT
        INTO l_msg_string_tbl
      LIMIT C_LINES_PER_COMMIT;

      l_count := l_msg_string_tbl.COUNT;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure,
                         'ZX.PLSQL.ZX_TRX_DETAIL.get_error_msg',
                         'Count in zx_errors_gt: ' ||
                         TO_CHAR(l_count));
      END IF;

      IF l_count > 0 THEN
        FOR i IN 1.. l_count LOOP
          x_msg_data := x_msg_data || '. ' ||
                        l_msg_string_tbl(i);
        END LOOP;
      ELSE
         --
         -- no more records to process
         --
         CLOSE  c_get_error_msg;
         EXIT;
       END IF;
     END LOOP;
   END IF;

  IF (g_level_procedure >= g_current_runtime_level ) THEN
    FND_LOG.STRING(g_level_procedure,
                   'ZX.PLSQL.ZX_TRX_DETAIL.get_error_msg.END',
                   'ZX_TRX_DETAIL: get_error_msg(-)');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.PLSQL.ZX_TRX_DETAIL.get_error_msg',
                      sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80));
    END IF;

END get_error_msg;


END ZX_TRX_DETAIL;

/
