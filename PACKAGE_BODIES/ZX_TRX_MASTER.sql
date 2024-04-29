--------------------------------------------------------
--  DDL for Package Body ZX_TRX_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRX_MASTER" AS
/* $Header: zxritsimmasterb.pls 120.27 2006/09/22 01:44:10 pla ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  PROCEDURE Insert_Row
       (p_Rowid                      IN OUT NOCOPY VARCHAR2,
        p_first_pty_org_id             NUMBER,
        p_internal_organization_id     NUMBER,
        p_internal_org_location_id     NUMBER,
        p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_tax_event_type_code          VARCHAR2,
        --p_trx_level_type               VARCHAR2,
        p_trx_date                     DATE,
        p_ledger_id                    NUMBER,
        p_trx_currency_code            VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_rate     NUMBER,
        p_currency_conversion_type     VARCHAR2,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER,
        p_legal_entity_ptp_id          NUMBER,
        p_legal_entity_id              NUMBER,
        p_rounding_ship_to_party_id    NUMBER,
        p_rounding_ship_from_party_id  NUMBER,
        p_rounding_bill_to_party_id    NUMBER,
        p_rounding_bill_from_party_id  NUMBER,
        p_rndg_ship_to_party_site_id   NUMBER,
        p_rndg_ship_from_party_site_id NUMBER,
        p_rndg_bill_to_party_site_id   NUMBER,
        p_rndg_bill_from_party_site_id NUMBER,
        p_bill_from_party_site_id      NUMBER,
        p_bill_to_party_site_id        NUMBER,
        p_ship_from_party_site_id      NUMBER,
        p_ship_to_party_site_id        NUMBER,
        p_ship_to_party_id             NUMBER,
        p_ship_from_party_id           NUMBER,
        p_bill_to_party_id             NUMBER,
        p_bill_from_party_id           NUMBER,
        p_ship_to_location_id          NUMBER,
        p_ship_from_location_id        NUMBER,
        p_bill_to_location_id          NUMBER,
        p_bill_from_location_id        NUMBER,
        p_poa_location_id              NUMBER,
        p_poo_location_id              NUMBER,
        p_paying_location_id           NUMBER,
        p_own_hq_location_id           NUMBER,
        p_trading_hq_location_id       NUMBER,
        p_poc_location_id              NUMBER,
        p_poi_location_id              NUMBER,
        p_pod_location_id              NUMBER,
        p_title_transfer_location_id   NUMBER,
        p_trx_number                   VARCHAR2,
        p_trx_description              VARCHAR2,
        p_document_sub_type            VARCHAR2,
        p_supplier_tax_invoice_number  NUMBER,
        p_supplier_tax_invoice_date    DATE,
        p_supplier_exchange_rate       NUMBER,
        p_tax_invoice_date             DATE,
        p_tax_invoice_number           NUMBER,
        p_tax_manual_entry_flag        VARCHAR2,
        p_establishment_id             NUMBER,
        p_receivables_trx_type_id      NUMBER,
        p_default_taxation_country     VARCHAR2,
        p_quote_flag                   VARCHAR2,
        p_ctrl_total_hdr_tx_amt        NUMBER,
        p_port_of_entry_code           VARCHAR2,
        p_tax_reporting_flag           VARCHAR2,
        p_ship_to_cust_acct_siteuse_id NUMBER,
        p_bill_to_cust_acct_siteuse_id NUMBER,
        p_provnl_tax_determ_date       DATE,
        p_applied_to_trx_number        VARCHAR2,
        p_ship_third_pty_acct_id       NUMBER,
        p_bill_third_pty_acct_id       NUMBER,
        p_ship_third_pty_acct_site_id  NUMBER,
        p_bill_third_pty_acct_site_id  NUMBER,
        p_validation_check_flag        VARCHAR2,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    l_set_of_books_id          NUMBER;
    p_error_buffer             VARCHAR2(100);

    CURSOR C IS
      SELECT rowid
      FROM zx_transaction
      WHERE APPLICATION_ID = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id;

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Insert_Row.BEGIN',
                     'ZX_TRX_MASTER: Insert_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Insert_Row',
                     'Insert into ZX_TRANSACTION (+)');
    END IF;

    INSERT INTO ZX_TRANSACTION (FIRST_PTY_ORG_ID,
                                INTERNAL_ORGANIZATION_ID,
                                INTERNAL_ORG_LOCATION_ID,
                                APPLICATION_ID,
                                ENTITY_CODE,
                                EVENT_CLASS_CODE,
                                EVENT_TYPE_CODE,
                                TRX_ID,
                                TAX_EVENT_TYPE_CODE,
                                DOCUMENT_EVENT_TYPE,
                                --TRX_LEVEL_TYPE,
                                TRX_DATE,
                                LEDGER_ID,
                                TRX_CURRENCY_CODE,
                                CURRENCY_CONVERSION_DATE,
                                CURRENCY_CONVERSION_RATE,
                                CURRENCY_CONVERSION_TYPE,
                                MINIMUM_ACCOUNTABLE_UNIT,
                                PRECISION,
                                LEGAL_ENTITY_PTP_ID,
                                LEGAL_ENTITY_ID,
                                ROUNDING_SHIP_TO_PARTY_ID,
                                ROUNDING_SHIP_FROM_PARTY_ID,
                                ROUNDING_BILL_TO_PARTY_ID,
                                ROUNDING_BILL_FROM_PARTY_ID,
                                RNDG_SHIP_TO_PARTY_SITE_ID,
                                RNDG_SHIP_FROM_PARTY_SITE_ID,
                                RNDG_BILL_TO_PARTY_SITE_ID,
                                RNDG_BILL_FROM_PARTY_SITE_ID,
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
                                TITLE_TRANSFER_LOCATION_ID,
                                TRX_NUMBER,
                                TRX_DESCRIPTION,
                                DOCUMENT_SUB_TYPE,
                                SUPPLIER_TAX_INVOICE_NUMBER,
                                SUPPLIER_TAX_INVOICE_DATE,
                                SUPPLIER_EXCHANGE_RATE,
                                TAX_INVOICE_DATE,
                                TAX_INVOICE_NUMBER,
                                TAX_MANUAL_ENTRY_FLAG,
                                ESTABLISHMENT_ID,
                                RECEIVABLES_TRX_TYPE_ID,
                                DEFAULT_TAXATION_COUNTRY,
                                QUOTE_FLAG,
                                CTRL_TOTAL_HDR_TX_AMT,
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
                                OBJECT_VERSION_NUMBER,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATE_LOGIN)
                        VALUES (p_first_pty_org_id,
                                p_internal_organization_id,
                                p_internal_org_location_id,
                                p_application_id,
                                p_entity_code,
                                p_event_class_code,
                                p_event_type_code,
                                p_trx_id,
                                p_tax_event_type_code,
                                p_event_type_code,
                                --p_trx_level_type,
                                p_trx_date,
                                p_ledger_id,
                                p_trx_currency_code,
                                p_currency_conversion_date,
                                p_currency_conversion_rate,
                                p_currency_conversion_type,
                                p_minimum_accountable_unit,
                                p_precision,
                                p_legal_entity_ptp_id,
                                p_legal_entity_id,
                                p_rounding_ship_to_party_id,
                                p_rounding_ship_from_party_id,
                                p_rounding_bill_to_party_id,
                                p_rounding_bill_from_party_id,
                                p_rndg_ship_to_party_site_id,
                                p_rndg_ship_from_party_site_id,
                                p_rndg_bill_to_party_site_id,
                                p_rndg_bill_from_party_site_id,
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
                                p_title_transfer_location_id,
                                p_trx_number,
                                p_trx_description,
                                p_document_sub_type,
                                p_supplier_tax_invoice_number,
                                p_supplier_tax_invoice_date,
                                p_supplier_exchange_rate,
                                p_tax_invoice_date,
                                p_tax_invoice_number,
                                p_tax_manual_entry_flag,
                                p_establishment_id,
                                p_receivables_trx_type_id,
                                p_default_taxation_country,
                                p_quote_flag,
                                p_ctrl_total_hdr_tx_amt,
                                p_port_of_entry_code,
                                p_tax_reporting_flag,
                                p_ship_to_cust_acct_siteuse_id,
                                p_bill_to_cust_acct_siteuse_id,
                                p_provnl_tax_determ_date,
                                p_applied_to_trx_number,
                                p_ship_third_pty_acct_id,
                                p_bill_third_pty_acct_id,
                                p_ship_third_pty_acct_site_id,
                                p_bill_third_pty_acct_site_id,
                                p_validation_check_flag,
                                1,    --p_object_version_number,
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
                     'ZX.PLSQL.ZX_TRX_MASTER.Insert_Row',
                     'Insert into ZX_TRANSACTION (-)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Insert_Row',
                     'Insert into ZX_SIM_PURGE (+)');
    END IF;

      INSERT INTO ZX_SIM_PURGE (TRX_ID,
                                APPLICATION_ID,
                                ENTITY_CODE,
                                EVENT_CLASS_CODE,
                                CREATED_BY,
                                CREATION_DATE,
                                LAST_UPDATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATE_LOGIN)
                        VALUES (p_trx_id,
                                p_application_id,
                                p_entity_code,
                                p_event_class_code,
                                p_created_by,
                                p_creation_date,
                                p_last_updated_by,
                                p_last_update_date,
                                p_last_update_login);

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Insert_Row',
                     'Insert into ZX_SIM_PURGE (-)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Insert_Row.END',
                     'ZX_TRX_MASTER: Insert_Row (-)');
    END IF;


  END Insert_Row;

  PROCEDURE Update_Row
       (p_Rowid                        VARCHAR2,
        p_first_pty_org_id             NUMBER,
        p_internal_organization_id     NUMBER,
        p_internal_org_location_id     NUMBER,
        p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_tax_event_type_code          VARCHAR2,
--        p_trx_level_type               VARCHAR2,
        p_trx_date                     DATE,
        p_document_event_type          VARCHAR2,
        p_ledger_id                    NUMBER,
        p_trx_currency_code            VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_rate     NUMBER,
        p_currency_conversion_type     VARCHAR2,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER,
        p_legal_entity_ptp_id          NUMBER,
        p_legal_entity_id              NUMBER,
        p_rounding_ship_to_party_id    NUMBER,
        p_rounding_ship_from_party_id  NUMBER,
        p_rounding_bill_to_party_id    NUMBER,
        p_rounding_bill_from_party_id  NUMBER,
        p_rndg_ship_to_party_site_id   NUMBER,
        p_rndg_ship_from_party_site_id NUMBER,
        p_rndg_bill_to_party_site_id   NUMBER,
        p_rndg_bill_from_party_site_id NUMBER,
        p_bill_from_party_site_id      NUMBER,
        p_bill_to_party_site_id        NUMBER,
        p_ship_from_party_site_id      NUMBER,
        p_ship_to_party_site_id        NUMBER,
        p_ship_to_party_id             NUMBER,
        p_ship_from_party_id           NUMBER,
        p_bill_to_party_id             NUMBER,
        p_bill_from_party_id           NUMBER,
        p_ship_to_location_id          NUMBER,
        p_ship_from_location_id        NUMBER,
        p_bill_to_location_id          NUMBER,
        p_bill_from_location_id        NUMBER,
        p_poa_location_id              NUMBER,
        p_poo_location_id              NUMBER,
        p_paying_location_id           NUMBER,
        p_own_hq_location_id           NUMBER,
        p_trading_hq_location_id       NUMBER,
        p_poc_location_id              NUMBER,
        p_poi_location_id              NUMBER,
        p_pod_location_id              NUMBER,
        p_title_transfer_location_id   NUMBER,
        p_trx_number                   VARCHAR2,
        p_trx_description              VARCHAR2,
        p_document_sub_type            VARCHAR2,
        p_supplier_tax_invoice_number  NUMBER,
        p_supplier_tax_invoice_date    DATE,
        p_supplier_exchange_rate       NUMBER,
        p_tax_invoice_date             DATE,
        p_tax_invoice_number           NUMBER,
        p_tax_manual_entry_flag        VARCHAR2,
        p_document_event               VARCHAR2,
        p_establishment_id             NUMBER,
        p_receivables_trx_type_id      NUMBER,
        p_default_taxation_country     VARCHAR2,
        p_quote_flag                   VARCHAR2,
        p_ctrl_total_hdr_tx_amt        NUMBER,
        p_port_of_entry_code           VARCHAR2,
        p_tax_reporting_flag           VARCHAR2,
        p_ship_to_cust_acct_siteuse_id NUMBER,
        p_bill_to_cust_acct_siteuse_id NUMBER,
        p_provnl_tax_determ_date       DATE,
        p_applied_to_trx_number        VARCHAR2,
        p_ship_third_pty_acct_id       NUMBER,
        p_bill_third_pty_acct_id       NUMBER,
        p_ship_third_pty_acct_site_id  NUMBER,
        p_bill_third_pty_acct_site_id  NUMBER,
        p_validation_check_flag        VARCHAR2,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    status_detail_block    VARCHAR2(30);
    l_return_status        VARCHAR2(1000);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(1000);
    l_tax_event_type_code  VARCHAR2(30);
    l_transaction_rec      ZX_API_PUB.transaction_rec_type;
    l_validate_status_rec  ZX_API_PUB.validation_status_tbl_type;
    l_hold_codes_tbl       ZX_API_PUB.hold_codes_tbl_type;
    l_validate_status      VARCHAR2(30);
    l_sync_trx_rec         ZX_API_PUB.sync_trx_rec_type;
    l_sync_trx_lines_rec   ZX_API_PUB.sync_trx_lines_rec_type;
    debug_info             VARCHAR2(100);
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

    i := 0;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.update_Row.BEGIN',
                     'ZX_TRX_MASTER: update_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.update_Row',
                     'Update into ZX_TRANSACTION (+)');
    END IF;

    UPDATE ZX_TRANSACTION
      SET EVENT_TYPE_CODE              = p_event_type_code,
          TRX_DATE                     = p_trx_date,
          DOCUMENT_EVENT_TYPE          = p_document_event_type,
          TRX_CURRENCY_CODE            = p_trx_currency_code,
          CURRENCY_CONVERSION_DATE     = p_currency_conversion_date,
          CURRENCY_CONVERSION_RATE     = p_currency_conversion_rate,
          CURRENCY_CONVERSION_TYPE     = p_currency_conversion_type,
          MINIMUM_ACCOUNTABLE_UNIT     = p_minimum_accountable_unit,
          PRECISION                    = p_precision,
          LEGAL_ENTITY_PTP_ID          = p_legal_entity_ptp_id,
          LEGAL_ENTITY_ID              = p_legal_entity_id,
          ROUNDING_SHIP_TO_PARTY_ID    = p_rounding_ship_to_party_id,
          ROUNDING_SHIP_FROM_PARTY_ID  = p_rounding_ship_from_party_id,
          ROUNDING_BILL_TO_PARTY_ID    = p_rounding_bill_to_party_id,
          ROUNDING_BILL_FROM_PARTY_ID  = p_rounding_bill_from_party_id,
          RNDG_SHIP_TO_PARTY_SITE_ID   = p_rndg_ship_to_party_site_id,
          RNDG_SHIP_FROM_PARTY_SITE_ID = p_rndg_ship_from_party_site_id,
          RNDG_BILL_TO_PARTY_SITE_ID   = p_rndg_bill_to_party_site_id,
          RNDG_BILL_FROM_PARTY_SITE_ID = p_rndg_bill_from_party_site_id,
          BILL_FROM_PARTY_SITE_ID      = p_bill_from_party_site_id,
          BILL_TO_PARTY_SITE_ID        = p_bill_to_party_site_id,
          SHIP_FROM_PARTY_SITE_ID      = p_ship_from_party_site_id,
          SHIP_TO_PARTY_SITE_ID        = p_ship_to_party_site_id,
          SHIP_TO_PARTY_ID             = p_ship_to_party_id,
          SHIP_FROM_PARTY_ID           = p_ship_from_party_id,
          BILL_TO_PARTY_ID             = p_bill_to_party_id,
          BILL_FROM_PARTY_ID           = p_bill_from_party_id,
          SHIP_TO_LOCATION_ID          = p_ship_to_location_id,
          SHIP_FROM_LOCATION_ID        = p_ship_from_location_id,
          BILL_TO_LOCATION_ID          = p_bill_to_location_id,
          BILL_FROM_LOCATION_ID        = p_bill_from_location_id,
          POA_LOCATION_ID              = p_poa_location_id,
          POO_LOCATION_ID              = p_poo_location_id,
          PAYING_LOCATION_ID           = p_paying_location_id,
          OWN_HQ_LOCATION_ID           = p_own_hq_location_id,
          TRADING_HQ_LOCATION_ID       = p_trading_hq_location_id,
          POC_LOCATION_ID              = p_poc_location_id,
          POI_LOCATION_ID              = p_poi_location_id,
          POD_LOCATION_ID              = p_pod_location_id,
          TITLE_TRANSFER_LOCATION_ID   = p_title_transfer_location_id,
          TRX_NUMBER                   = p_trx_number,
          TRX_DESCRIPTION              = p_trx_description,
          DOCUMENT_SUB_TYPE            = p_document_sub_type,
          SUPPLIER_TAX_INVOICE_NUMBER  = p_supplier_tax_invoice_number,
          SUPPLIER_TAX_INVOICE_DATE    = p_supplier_tax_invoice_date,
          SUPPLIER_EXCHANGE_RATE       = p_supplier_exchange_rate,
          TAX_INVOICE_DATE             = p_tax_invoice_date,
          TAX_INVOICE_NUMBER           = p_tax_invoice_number,
          ESTABLISHMENT_ID             = p_establishment_id,
          RECEIVABLES_TRX_TYPE_ID      = p_receivables_trx_type_id,
          DEFAULT_TAXATION_COUNTRY     = p_default_taxation_country,
          QUOTE_FLAG                   = p_quote_flag,
          CTRL_TOTAL_HDR_TX_AMT        = p_ctrl_total_hdr_tx_amt,
          PORT_OF_ENTRY_CODE           = p_port_of_entry_code,
          TAX_REPORTING_FLAG           = p_tax_reporting_flag,
          SHIP_TO_CUST_ACCT_SITE_USE_ID = p_ship_to_cust_acct_siteuse_id,
          BILL_TO_CUST_ACCT_SITE_USE_ID = p_bill_to_cust_acct_siteuse_id,
          PROVNL_TAX_DETERMINATION_DATE = p_provnl_tax_determ_date,
          APPLIED_TO_TRX_NUMBER        = p_applied_to_trx_number,
          SHIP_THIRD_PTY_ACCT_ID       = p_ship_third_pty_acct_id,
          BILL_THIRD_PTY_ACCT_ID       = p_bill_third_pty_acct_id,
          SHIP_THIRD_PTY_ACCT_SITE_ID  = p_ship_third_pty_acct_site_id,
          BILL_THIRD_PTY_ACCT_SITE_ID  = p_bill_third_pty_acct_site_id,
          VALIDATION_CHECK_FLAG        = p_validation_check_flag,
          OBJECT_VERSION_NUMBER        = NVL(p_object_version_number, OBJECT_VERSION_NUMBER + 1),
          LAST_UPDATED_BY              = p_last_updated_by,
          LAST_UPDATE_DATE             = p_last_update_date,
          LAST_UPDATE_LOGIN            = p_last_update_login
      WHERE INTERNAL_ORGANIZATION_ID = p_internal_organization_id
      -- AND FIRST_PTY_ORG_ID = p_first_pty_org_id
      AND APPLICATION_ID           = p_application_id
      AND ENTITY_CODE              = p_entity_code
      AND EVENT_CLASS_CODE         = p_event_class_code
      AND TRX_ID                   = p_trx_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Update_Row',
                     'Update into ZX_TRANSACTION (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Update_Row',
                     'Document Event Type (+)');

      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Update_Row',
                     'Document Event Type: '||p_document_event_type);
    END IF;

    --
    -- bug#5208939
    -- update line_level_action in trx line to 'UPDATE'
    --
    UPDATE ZX_TRANSACTION_LINES
       SET line_level_action        = 'UPDATE'
     WHERE APPLICATION_ID           = p_application_id
       AND ENTITY_CODE              = p_entity_code
       AND EVENT_CLASS_CODE         = p_event_class_code
       AND TRX_ID                   = p_trx_id
       AND LINE_LEVEL_ACTION        = 'CREATE';


    IF p_document_event = 'DISTRIBUTE' THEN
      RETURN;
    END IF;

      l_tax_event_type_code := p_document_event_type;

      l_transaction_rec.APPLICATION_ID           := p_application_id;
      l_transaction_rec.ENTITY_CODE              := p_entity_code;
      l_transaction_rec.EVENT_CLASS_CODE         := p_event_class_code;
      l_transaction_rec.EVENT_TYPE_CODE          := p_event_type_code;
      l_transaction_rec.TRX_ID                   := p_trx_id;
      l_transaction_rec.INTERNAL_ORGANIZATION_ID := p_internal_organization_id;
      l_transaction_rec.FIRST_PTY_ORG_ID         := p_first_pty_org_id;
      l_transaction_rec.TAX_EVENT_TYPE_CODE      := l_tax_event_type_code;
      l_transaction_rec.DOC_EVENT_STATUS         := NULL;

    IF p_document_event_type IN ('CANCEL', 'DELETE', 'PURGE',
                                 'FREEZE_FOR_TAX', 'UNFREEZE_FOR_TAX',
                                 'RELEASE_TAX_HOLD') THEN

      ZX_API_PUB.global_document_update (p_api_version     => 1.0,
                                         p_commit           => NULL,
                                         p_validation_level => NULL,
                                         p_transaction_rec => l_transaction_rec,
                                         p_init_msg_list   => FND_API.G_TRUE,
                                         x_return_status   => l_return_status,
                                         x_msg_count       => l_msg_count,
                                         x_msg_data        => l_msg_data);

    ELSIF p_document_event_type = 'VALIDATE' THEN

      INSERT INTO ZX_TRANSACTIONS_GT (APPLICATION_ID,
                                     ENTITY_CODE,
                                     EVENT_CLASS_CODE,
                                     EVENT_TYPE_CODE,
                                     TRX_ID,
                                     INTERNAL_ORGANIZATION_ID,
                                     FIRST_PTY_ORG_ID,
                                     --TAX_EVENT_CLASS_CODE,
                                     TAX_EVENT_TYPE_CODE,
                                     DOC_EVENT_STATUS)
                             VALUES (p_application_id,
                                     p_entity_code,
                                     p_event_class_code,
                                     p_event_type_code,
                                     p_trx_id,
                                     p_internal_organization_id,
                                     p_first_pty_org_id,
                                     --p_tax_event_class_code,
                                     p_tax_event_type_code,
                                     null); --p_doc_event_status

      ZX_API_PUB.validate_document_for_tax (p_api_version       => 1.0,
                                            p_init_msg_list         => NULL,
                                            p_commit                => NULL,
                                            p_validation_level      => NULL,
                                            x_return_status     => l_return_status,
                                            x_msg_count         => l_msg_count,
                                            x_msg_data          => l_msg_data,
                                            p_transaction_rec   => l_transaction_rec,
                                            x_validation_status => l_validate_status,
                                            x_hold_codes_tbl    => l_hold_codes_tbl);

    ELSIF p_document_event = 'SYNC' THEN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRX_MASTER.Insert_Temporary_Table',
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
                       'ZX.PLSQL.ZX_TRX_MASTER.Insert_Temporary_Table',
                       'Insert into zx_trx_headers_gt (-)');
      END IF;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_TRX_MASTER.Insert_Temporary_Table',
                       'Insert into ZX_TRANSACTION_LINES_GT (+)');
      END IF;

      INSERT INTO ZX_TRANSACTION_LINES_GT (APPLICATION_ID,
                                           ENTITY_CODE,
                                           EVENT_CLASS_CODE,
                                           TRX_ID,
                                           TRX_LEVEL_TYPE,
                                           TRX_LINE_ID,
                                           LINE_LEVEL_ACTION,
                                           --TRX_SHIPPING_DATE,
                                           --TRX_RECEIPT_DATE,
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
                                           EXEMPTION_CONTROL_FLAG,
                                           EXEMPT_REASON_CODE,
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
                                           --POA_PARTY_ID,
                                           --POO_PARTY_ID,
                                           BILL_TO_PARTY_ID,
                                           BILL_FROM_PARTY_ID,
                                           MERCHANT_PARTY_ID,
                                           SHIP_TO_PARTY_SITE_ID,
                                           SHIP_FROM_PARTY_SITE_ID,
                                           --POA_PARTY_SITE_ID,
                                           --POO_PARTY_SITE_ID,
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
                                           --MERCHANT_PARTY_COUNTRY,
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
                                           --APPLIED_TO_APPLICATION_ID,
                                           --APPLIED_TO_ENTITY_CODE,
                                           --APPLIED_TO_EVENT_CLASS_CODE,
                                           --APPLIED_TO_TRX_ID,
                                           --APPLIED_TO_TRX_LINE_ID,
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
                                           --p_trx_shipping_date,
                                           --p_trx_receipt_date,
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
                                           exemption_control_flag,
                                           exempt_reason_code,
                                           product_id,
                                           product_fisc_classification,
                                           product_org_id,
                                           uom_code,
                                           product_type,
                                           product_code,
                                           product_category,
                                           --p_trx_sic_code,
                                           --p_fob_point,
                                           ship_to_party_id,
                                           ship_from_party_id,
                                           --p_poa_party_id,
                                           --p_poo_party_id,
                                           bill_to_party_id,
                                           bill_from_party_id,
                                           merchant_party_id,
                                           ship_to_party_site_id,
                                           ship_from_party_site_id,
                                           --p_poa_party_site_id,
                                           --p_poo_party_site_id,
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
                                           --p_merchant_party_country,
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
                                           --p_applied_to_application_id,
                                           --p_applied_to_entity_code,
                                           --p_applied_to_event_class_code,
                                           --p_applied_to_trx_id,
                                           --p_applied_to_trx_line_id,
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
                                           line_amt_includes_tax_flag,
                                           historical_flag
                                           --p_tax_classification_code
                                      FROM ZX_TRANSACTION_LINES
                                      WHERE APPLICATION_ID = p_application_id
                                      AND ENTITY_CODE      = p_entity_code
                                      AND EVENT_CLASS_CODE = p_event_class_code
                                      AND TRX_ID           = p_trx_id
                                      AND TRX_LINE_TYPE    <> 'TAX';

      IF (SQL%ROWCOUNT) = 0 THEN
        RETURN;
      END IF;
      /*
      INSERT INTO ZX_SYNC_TRX_LINES_GT (APPLICATION_ID,
                                        ENTITY_CODE,
                                        EVENT_CLASS_CODE,
                                        TRX_ID,
                                        HDR_TRX_USER_KEY1,
                                        HDR_TRX_USER_KEY2,
                                        HDR_TRX_USER_KEY3,
                                        HDR_TRX_USER_KEY4,
                                        HDR_TRX_USER_KEY5,
                                        HDR_TRX_USER_KEY6,
                                        TRX_LEVEL_TYPE,
                                        TRX_LINE_ID,
                                        LINE_TRX_USER_KEY1,
                                        LINE_TRX_USER_KEY2,
                                        LINE_TRX_USER_KEY3,
                                        LINE_TRX_USER_KEY4,
                                        LINE_TRX_USER_KEY5,
                                        LINE_TRX_USER_KEY6,
                                        TRX_WAYBILL_NUMBER,
                                        TRX_LINE_DESCRIPTION,
                                        PRODUCT_DESCRIPTION,
                                        TRX_LINE_GL_DATE,
                                        BANKING_TP_TAXPAYER_ID,
                                        MERCHANT_PARTY_NAME,
                                        MERCHANT_PARTY_DOCUMENT_NUMBER,
                                        MERCHANT_PARTY_REFERENCE,
                                        MERCHANT_PARTY_TAXPAYER_ID,
                                        MERCHANT_PARTY_TAX_REG_NUMBER,
                                        ASSET_NUMBER)
                                   SELECT APPLICATION_ID,
                                        ENTITY_CODE,
                                        EVENT_CLASS_CODE,
                                        TRX_ID,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        TRX_LEVEL_TYPE,
                                        TRX_LINE_ID,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL, --TRX_WAYBILL_NUMBER,
                                        TRX_LINE_DESCRIPTION,
                                        PRODUCT_DESCRIPTION,
                                        TRX_LINE_GL_DATE,
                                        NULL, --BANKING_TP_TAXPAYER_ID,
                                        NULL, --MERCHANT_PARTY_NAME,
                                        NULL, --MERCHANT_PARTY_DOCUMENT_NUMBER,
                                        NULL, --MERCHANT_PARTY_REFERENCE,
                                        NULL, --MERCHANT_PARTY_TAXPAYER_ID,
                                        NULL, --MERCHANT_PARTY_TAX_REG_NUMBER,
                                        NULL --ASSET_NUMBER
                                   FROM ZX_TRANSACTION_LINES
                                   WHERE APPLICATION_ID = p_application_id
                                   AND ENTITY_CODE      = p_entity_code
                                   AND EVENT_CLASS_CODE = p_event_class_code
                                   AND TRX_ID           = p_trx_id
                                   AND TRX_LINE_TYPE    <> 'TAX';*/


      l_sync_trx_rec.APPLICATION_ID              := p_application_id;
      l_sync_trx_rec.ENTITY_CODE                 := p_entity_code;
      l_sync_trx_rec.EVENT_CLASS_CODE            := p_event_class_code;
      l_sync_trx_rec.EVENT_TYPE_CODE             := p_event_type_code;
      l_sync_trx_rec.TRX_ID                      := p_trx_id;
      l_sync_trx_rec.TRX_NUMBER                  := p_trx_number;
      l_sync_trx_rec.TRX_DESCRIPTION             := p_trx_description;
      l_sync_trx_rec.TRX_COMMUNICATED_DATE       := NULL;
      l_sync_trx_rec.BATCH_SOURCE_ID             := NULL;
      l_sync_trx_rec.BATCH_SOURCE_NAME           := NULL;
      l_sync_trx_rec.DOC_SEQ_ID                  := NULL;
      l_sync_trx_rec.DOC_SEQ_NAME                := NULL;
      l_sync_trx_rec.DOC_SEQ_VALUE               := NULL;
      l_sync_trx_rec.TRX_DUE_DATE                := NULL;
      l_sync_trx_rec.TRX_TYPE_DESCRIPTION        := NULL;
      l_sync_trx_rec.SUPPLIER_TAX_INVOICE_NUMBER := NULL;
      l_sync_trx_rec.SUPPLIER_TAX_INVOICE_DATE   := NULL;
      l_sync_trx_rec.SUPPLIER_EXCHANGE_RATE      := NULL;
      l_sync_trx_rec.TAX_INVOICE_DATE            := NULL;
      l_sync_trx_rec.TAX_INVOICE_NUMBER          := NULL;
      l_sync_trx_rec.PORT_OF_ENTRY_CODE          := NULL;

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

      ZX_API_PUB.synchronize_tax_repository
        (p_api_version           => 1.0,
         p_init_msg_list         => NULL,
         p_commit                => NULL,
         p_validation_level      => NULL,
         x_return_status         => l_return_status,
         x_msg_count             => l_msg_count,
         x_msg_data              => l_msg_data,
         p_sync_trx_rec          => l_sync_trx_rec,
         p_sync_trx_lines_tbl    => l_sync_trx_lines_rec);

      ZX_API_PUB.CALCULATE_TAX (p_api_version      => 1.0,
                                p_init_msg_list    => NULL,
                                p_commit           => NULL,
                                p_validation_level => NULL,
                                x_return_status    => l_return_status,
                                x_msg_count        => l_msg_count,
                                x_msg_data         => l_msg_data);

    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Update_Row',
                     'Document Event Type (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.update_Row.END',
                     'ZX_TRX_MASTER: update_Row (-)');
    END IF;
  END Update_Row;

  PROCEDURE Delete_Row
       (p_Rowid                        VARCHAR2,
        p_first_pty_org_id             NUMBER,
        p_internal_organization_id     NUMBER,
        p_internal_org_location_id     NUMBER,
        p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_tax_event_type_code          VARCHAR2,
--        p_trx_level_type               VARCHAR2,
        p_trx_date                     DATE,
        p_document_event_type          VARCHAR2,
        p_ledger_id                    NUMBER,
        p_trx_currency_code            VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_rate     NUMBER,
        p_currency_conversion_type     VARCHAR2,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER,
        p_legal_entity_ptp_id          NUMBER,
        p_legal_entity_id              NUMBER,
        p_rounding_ship_to_party_id    NUMBER,
        p_rounding_ship_from_party_id  NUMBER,
        p_rounding_bill_to_party_id    NUMBER,
        p_rounding_bill_from_party_id  NUMBER,
        p_rndg_ship_to_party_site_id   NUMBER,
        p_rndg_ship_from_party_site_id NUMBER,
        p_rndg_bill_to_party_site_id   NUMBER,
        p_rndg_bill_from_party_site_id NUMBER,
        p_bill_from_party_site_id      NUMBER,
        p_bill_to_party_site_id        NUMBER,
        p_ship_from_party_site_id      NUMBER,
        p_ship_to_party_site_id        NUMBER,
        p_ship_to_party_id             NUMBER,
        p_ship_from_party_id           NUMBER,
        p_bill_to_party_id             NUMBER,
        p_bill_from_party_id           NUMBER,
        p_ship_to_location_id          NUMBER,
        p_ship_from_location_id        NUMBER,
        p_bill_to_location_id          NUMBER,
        p_bill_from_location_id        NUMBER,
        p_poa_location_id              NUMBER,
        p_poo_location_id              NUMBER,
        p_paying_location_id           NUMBER,
        p_own_hq_location_id           NUMBER,
        p_trading_hq_location_id       NUMBER,
        p_poc_location_id              NUMBER,
        p_poi_location_id              NUMBER,
        p_pod_location_id              NUMBER,
        p_title_transfer_location_id   NUMBER,
        p_trx_number                   VARCHAR2,
        p_trx_description              VARCHAR2,
        p_document_sub_type            VARCHAR2,
        p_supplier_tax_invoice_number  NUMBER,
        p_supplier_tax_invoice_date    DATE,
        p_supplier_exchange_rate       NUMBER,
        p_tax_invoice_date             DATE,
        p_tax_invoice_number           NUMBER,
        p_tax_manual_entry_flag        VARCHAR2,
        p_establishment_id             NUMBER,
        p_receivables_trx_type_id      NUMBER,
        p_default_taxation_country     VARCHAR2,
        p_quote_flag                   VARCHAR2,
        p_ctrl_total_hdr_tx_amt        NUMBER,
        p_port_of_entry_code           VARCHAR2,
        p_tax_reporting_flag           VARCHAR2,
        p_ship_to_cust_acct_siteuse_id NUMBER,
        p_bill_to_cust_acct_siteuse_id NUMBER,
        p_provnl_tax_determ_date       DATE,
        p_applied_to_trx_number        VARCHAR2,
        p_ship_third_pty_acct_id       NUMBER,
        p_bill_third_pty_acct_id       NUMBER,
        p_ship_third_pty_acct_site_id  NUMBER,
        p_bill_third_pty_acct_site_id  NUMBER,
        p_validation_check_flag        VARCHAR2,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Delete_Row.BEGIN',
                     'ZX_TRX_MASTER: Delete_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Delete_Row',
                     'Update for DELETE in ZX_TRANSACTION (+)');
    END IF;

    UPDATE ZX_TRANSACTION
      SET EVENT_TYPE_CODE              = p_event_type_code,
          TRX_DATE                     = p_trx_date,
          TRX_CURRENCY_CODE            = p_trx_currency_code,
          CURRENCY_CONVERSION_DATE     = p_currency_conversion_date,
          CURRENCY_CONVERSION_RATE     = p_currency_conversion_rate,
          CURRENCY_CONVERSION_TYPE     = p_currency_conversion_type,
          MINIMUM_ACCOUNTABLE_UNIT     = p_minimum_accountable_unit,
          PRECISION                    = p_precision,
          LEGAL_ENTITY_PTP_ID          = p_legal_entity_ptp_id,
          LEGAL_ENTITY_ID              = p_legal_entity_id,
          ROUNDING_SHIP_TO_PARTY_ID    = p_rounding_ship_to_party_id,
          ROUNDING_SHIP_FROM_PARTY_ID  = p_rounding_ship_from_party_id,
          ROUNDING_BILL_TO_PARTY_ID    = p_rounding_bill_to_party_id,
          ROUNDING_BILL_FROM_PARTY_ID  = p_rounding_bill_from_party_id,
          RNDG_SHIP_TO_PARTY_SITE_ID   = p_rndg_ship_to_party_site_id,
          RNDG_SHIP_FROM_PARTY_SITE_ID = p_rndg_ship_from_party_site_id,
          RNDG_BILL_TO_PARTY_SITE_ID   = p_rndg_bill_to_party_site_id,
          RNDG_BILL_FROM_PARTY_SITE_ID = p_rndg_bill_from_party_site_id,
          BILL_FROM_PARTY_SITE_ID      = p_bill_from_party_site_id,
          BILL_TO_PARTY_SITE_ID        = p_bill_to_party_site_id,
          SHIP_FROM_PARTY_SITE_ID      = p_ship_from_party_site_id,
          SHIP_TO_PARTY_SITE_ID        = p_ship_to_party_site_id,
          SHIP_TO_PARTY_ID             = p_ship_to_party_id,
          SHIP_FROM_PARTY_ID           = p_ship_from_party_id,
          BILL_TO_PARTY_ID             = p_bill_to_party_id,
          BILL_FROM_PARTY_ID           = p_bill_from_party_id,
          SHIP_TO_LOCATION_ID          = p_ship_to_location_id,
          SHIP_FROM_LOCATION_ID        = p_ship_from_location_id,
          BILL_TO_LOCATION_ID          = p_bill_to_location_id,
          BILL_FROM_LOCATION_ID        = p_bill_from_location_id,
          POA_LOCATION_ID              = p_poa_location_id,
          POO_LOCATION_ID              = p_poo_location_id,
          PAYING_LOCATION_ID           = p_paying_location_id,
          OWN_HQ_LOCATION_ID           = p_own_hq_location_id,
          TRADING_HQ_LOCATION_ID       = p_trading_hq_location_id,
          POC_LOCATION_ID              = p_poc_location_id,
          POI_LOCATION_ID              = p_poi_location_id,
          POD_LOCATION_ID              = p_pod_location_id,
          TITLE_TRANSFER_LOCATION_ID   = p_title_transfer_location_id,
          TRX_NUMBER                   = p_trx_number,
          TRX_DESCRIPTION              = p_trx_description,
          DOCUMENT_SUB_TYPE            = p_document_sub_type,
          SUPPLIER_TAX_INVOICE_NUMBER  = p_supplier_tax_invoice_number,
          SUPPLIER_TAX_INVOICE_DATE    = p_supplier_tax_invoice_date,
          SUPPLIER_EXCHANGE_RATE       = p_supplier_exchange_rate,
          ESTABLISHMENT_ID             = p_establishment_id,
          RECEIVABLES_TRX_TYPE_ID      = p_receivables_trx_type_id,
          DEFAULT_TAXATION_COUNTRY     = p_default_taxation_country,
          QUOTE_FLAG                   = p_quote_flag,
          CTRL_TOTAL_HDR_TX_AMT        = p_ctrl_total_hdr_tx_amt,
          PORT_OF_ENTRY_CODE           = p_port_of_entry_code,
          TAX_REPORTING_FLAG           = p_tax_reporting_flag,
          SHIP_TO_CUST_ACCT_SITE_USE_ID = p_ship_to_cust_acct_siteuse_id,
          BILL_TO_CUST_ACCT_SITE_USE_ID = p_bill_to_cust_acct_siteuse_id,
          PROVNL_TAX_DETERMINATION_DATE = p_provnl_tax_determ_date,
          APPLIED_TO_TRX_NUMBER        = p_applied_to_trx_number,
          SHIP_THIRD_PTY_ACCT_ID       = p_ship_third_pty_acct_id,
          BILL_THIRD_PTY_ACCT_ID       = p_bill_third_pty_acct_id,
          SHIP_THIRD_PTY_ACCT_SITE_ID  = p_ship_third_pty_acct_site_id,
          BILL_THIRD_PTY_ACCT_SITE_ID  = p_bill_third_pty_acct_site_id,
          VALIDATION_CHECK_FLAG        = p_validation_check_flag,
          TAX_INVOICE_DATE             = p_tax_invoice_date,
          TAX_INVOICE_NUMBER           = p_tax_invoice_number
      WHERE INTERNAL_ORGANIZATION_ID = p_internal_organization_id
      --    SUBSCRIBER_ID          = p_subscriber_id
      AND APPLICATION_ID           = p_application_id
      AND ENTITY_CODE              = p_entity_code
      AND EVENT_CLASS_CODE         = p_event_class_code
      AND TRX_ID                   = p_trx_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Delete_Row',
                     'Update for DELETE in ZX_TRANSACTION (-)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Delete_Row.END',
                     'ZX_TRX_MASTER: Delete_Row (-)');
    END IF;
  END Delete_Row;

  PROCEDURE Lock_Row
       (p_Rowid                        VARCHAR2,
        p_first_pty_org_id             NUMBER,
        p_internal_organization_id     NUMBER,
        p_internal_org_location_id     NUMBER,
        p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_tax_event_type_code          VARCHAR2,
--        p_trx_level_type               VARCHAR2,
        p_trx_date                     DATE,
        p_document_event_type          VARCHAR2,
        p_ledger_id                    NUMBER,
        p_trx_currency_code            VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_rate     NUMBER,
        p_currency_conversion_type     VARCHAR2,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER,
        p_legal_entity_ptp_id          NUMBER,
        p_legal_entity_id              NUMBER,
        p_rounding_ship_to_party_id    NUMBER,
        p_rounding_ship_from_party_id  NUMBER,
        p_rounding_bill_to_party_id    NUMBER,
        p_rounding_bill_from_party_id  NUMBER,
        p_rndg_ship_to_party_site_id   NUMBER,
        p_rndg_ship_from_party_site_id NUMBER,
        p_rndg_bill_to_party_site_id   NUMBER,
        p_rndg_bill_from_party_site_id NUMBER,
        p_bill_from_party_site_id      NUMBER,
        p_bill_to_party_site_id        NUMBER,
        p_ship_from_party_site_id      NUMBER,
        p_ship_to_party_site_id        NUMBER,
        p_ship_to_party_id             NUMBER,
        p_ship_from_party_id           NUMBER,
        p_bill_to_party_id             NUMBER,
        p_bill_from_party_id           NUMBER,
        p_ship_to_location_id          NUMBER,
        p_ship_from_location_id        NUMBER,
        p_bill_to_location_id          NUMBER,
        p_bill_from_location_id        NUMBER,
        p_poa_location_id              NUMBER,
        p_poo_location_id              NUMBER,
        p_paying_location_id           NUMBER,
        p_own_hq_location_id           NUMBER,
        p_trading_hq_location_id       NUMBER,
        p_poc_location_id              NUMBER,
        p_poi_location_id              NUMBER,
        p_pod_location_id              NUMBER,
        p_title_transfer_location_id   NUMBER,
        p_trx_number                   VARCHAR2,
        p_trx_description              VARCHAR2,
        p_document_sub_type            VARCHAR2,
        p_supplier_tax_invoice_number  NUMBER,
        p_supplier_tax_invoice_date    DATE,
        p_supplier_exchange_rate       NUMBER,
        p_tax_invoice_date             DATE,
        p_tax_invoice_number           NUMBER,
        p_tax_manual_entry_flag        VARCHAR2,
        p_establishment_id             NUMBER,
        p_receivables_trx_type_id      NUMBER,
        p_default_taxation_country     VARCHAR2,
        p_quote_flag                   VARCHAR2,
        p_ctrl_total_hdr_tx_amt        NUMBER,
        p_port_of_entry_code           VARCHAR2,
        p_tax_reporting_flag           VARCHAR2,
        p_ship_to_cust_acct_siteuse_id NUMBER,
        p_bill_to_cust_acct_siteuse_id NUMBER,
        p_provnl_tax_determ_date       DATE,
        p_applied_to_trx_number        VARCHAR2,
        p_ship_third_pty_acct_id       NUMBER,
        p_bill_third_pty_acct_id       NUMBER,
        p_ship_third_pty_acct_site_id  NUMBER,
        p_bill_third_pty_acct_site_id  NUMBER,
        p_validation_check_flag        VARCHAR2,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    CURSOR C IS
      SELECT FIRST_PTY_ORG_ID,
             INTERNAL_ORGANIZATION_ID,
             INTERNAL_ORG_LOCATION_ID,
             APPLICATION_ID,
             ENTITY_CODE,
             EVENT_CLASS_CODE,
             EVENT_TYPE_CODE,
             TRX_ID,
             TAX_EVENT_TYPE_CODE,
             -- TRX_LEVEL_TYPE,
             TRX_DATE,
             DOCUMENT_EVENT_TYPE,
             LEDGER_ID,
             TRX_CURRENCY_CODE,
             CURRENCY_CONVERSION_DATE,
             CURRENCY_CONVERSION_RATE,
             CURRENCY_CONVERSION_TYPE,
             MINIMUM_ACCOUNTABLE_UNIT,
             PRECISION,
             LEGAL_ENTITY_PTP_ID,
             LEGAL_ENTITY_ID,
             ROUNDING_SHIP_TO_PARTY_ID,
             ROUNDING_SHIP_FROM_PARTY_ID,
             ROUNDING_BILL_TO_PARTY_ID,
             ROUNDING_BILL_FROM_PARTY_ID,
             RNDG_SHIP_TO_PARTY_SITE_ID,
             RNDG_SHIP_FROM_PARTY_SITE_ID,
             RNDG_BILL_TO_PARTY_SITE_ID,
             RNDG_BILL_FROM_PARTY_SITE_ID,
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
             TRX_NUMBER,
             TRX_DESCRIPTION,
             DOCUMENT_SUB_TYPE,
             SUPPLIER_TAX_INVOICE_NUMBER,
             SUPPLIER_TAX_INVOICE_DATE,
             SUPPLIER_EXCHANGE_RATE,
             TAX_INVOICE_DATE,
             TAX_INVOICE_NUMBER,
             TITLE_TRANSFER_LOCATION_ID,
             TAX_MANUAL_ENTRY_FLAG,
             ESTABLISHMENT_ID,
             RECEIVABLES_TRX_TYPE_ID,
             DEFAULT_TAXATION_COUNTRY,
             QUOTE_FLAG,
             CTRL_TOTAL_HDR_TX_AMT,
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
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
        FROM ZX_TRANSACTION
        WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID = p_trx_id
        FOR UPDATE OF APPLICATION_ID,
                      ENTITY_CODE,
                      EVENT_CLASS_CODE,
                      EVENT_TYPE_CODE,
                      TRX_ID
--                      TRX_LEVEL_TYPE
        NOWAIT;

    Recinfo C%ROWTYPE;
    debug_info             VARCHAR2(100);
    p_error_buffer         VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Lock_Row.BEGIN',
                     'ZX_TRX_MASTER: Lock_Row (+)');
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

    IF (((Recinfo.FIRST_PTY_ORG_ID = p_FIRST_PTY_ORG_ID) OR
        ((Recinfo.FIRST_PTY_ORG_ID IS NULL) AND
          (p_FIRST_PTY_ORG_ID IS NULL))) AND
        (Recinfo.INTERNAL_ORGANIZATION_ID = p_INTERNAL_ORGANIZATION_ID ) AND
        ((Recinfo.INTERNAL_ORG_LOCATION_ID = p_INTERNAL_ORG_LOCATION_ID) OR
         ((Recinfo.INTERNAL_ORG_LOCATION_ID IS NULL) AND
          (p_INTERNAL_ORG_LOCATION_ID IS NULL))) AND
        (Recinfo.APPLICATION_ID = p_APPLICATION_ID) AND
        (Recinfo.ENTITY_CODE = p_ENTITY_CODE) AND
        (Recinfo.EVENT_CLASS_CODE = p_EVENT_CLASS_CODE) AND
        (Recinfo.EVENT_TYPE_CODE = p_EVENT_TYPE_CODE) AND
        (Recinfo.TRX_ID = p_TRX_ID) AND
        (Recinfo.LEGAL_ENTITY_ID = p_LEGAL_ENTITY_ID) AND
        ((Recinfo.TAX_EVENT_TYPE_CODE = p_TAX_EVENT_TYPE_CODE) OR
         ((Recinfo.TAX_EVENT_TYPE_CODE IS NULL) AND
          (p_TAX_EVENT_TYPE_CODE IS NULL))) AND
--        (Recinfo.TRX_LEVEL_TYPE = p_TRX_LEVEL_TYPE) AND
        ((Recinfo.TRX_DATE = p_TRX_DATE) OR
         ((Recinfo.TRX_DATE IS NULL) AND
          (p_TRX_DATE IS NULL))) AND
        ((Recinfo.DOCUMENT_EVENT_TYPE = p_document_event_type) OR
         ((Recinfo.DOCUMENT_EVENT_TYPE IS NULL) AND
          (p_document_event_type IS NULL))) AND
        ((Recinfo.LEDGER_ID = p_LEDGER_ID) OR
         ((Recinfo.LEDGER_ID IS NULL) AND
          (p_LEDGER_ID IS NULL))) AND
        ((Recinfo.TRX_CURRENCY_CODE = p_TRX_CURRENCY_CODE) OR
         ((Recinfo.TRX_CURRENCY_CODE IS NULL) AND
          (p_TRX_CURRENCY_CODE IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_DATE = p_CURRENCY_CONVERSION_DATE) OR
         ((Recinfo.CURRENCY_CONVERSION_DATE IS NULL) AND
          (p_CURRENCY_CONVERSION_DATE IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_RATE = p_CURRENCY_CONVERSION_RATE) OR
         ((Recinfo.CURRENCY_CONVERSION_RATE IS NULL) AND
          (p_CURRENCY_CONVERSION_RATE IS NULL))) AND
        ((Recinfo.CURRENCY_CONVERSION_TYPE = p_CURRENCY_CONVERSION_TYPE) OR
         ((Recinfo.CURRENCY_CONVERSION_TYPE IS NULL) AND
          (p_CURRENCY_CONVERSION_TYPE IS NULL))) AND
        ((Recinfo.MINIMUM_ACCOUNTABLE_UNIT = p_MINIMUM_ACCOUNTABLE_UNIT) OR
         ((Recinfo.MINIMUM_ACCOUNTABLE_UNIT IS NULL) AND
          (p_MINIMUM_ACCOUNTABLE_UNIT IS NULL))) AND
        ((Recinfo.PRECISION = p_PRECISION) OR
         ((Recinfo.PRECISION IS NULL) AND
          (p_PRECISION IS NULL))) AND
        ((Recinfo.LEGAL_ENTITY_PTP_ID = p_LEGAL_ENTITY_PTP_ID) OR
         ((Recinfo.LEGAL_ENTITY_PTP_ID IS NULL) AND
          (p_LEGAL_ENTITY_PTP_ID IS NULL))) AND
        ((Recinfo.ROUNDING_SHIP_TO_PARTY_ID = p_ROUNDING_SHIP_TO_PARTY_ID) OR
         ((Recinfo.ROUNDING_SHIP_TO_PARTY_ID IS NULL) AND
          (p_ROUNDING_SHIP_TO_PARTY_ID IS NULL))) AND
        ((Recinfo.ROUNDING_SHIP_FROM_PARTY_ID = p_ROUNDING_SHIP_FROM_PARTY_ID) OR
         ((Recinfo.ROUNDING_SHIP_FROM_PARTY_ID IS NULL) AND
          (p_ROUNDING_SHIP_FROM_PARTY_ID IS NULL))) AND
        ((Recinfo.ROUNDING_BILL_TO_PARTY_ID = p_ROUNDING_BILL_TO_PARTY_ID) OR
         ((Recinfo.ROUNDING_BILL_TO_PARTY_ID IS NULL) AND
          (p_ROUNDING_BILL_TO_PARTY_ID IS NULL))) AND
        ((Recinfo.ROUNDING_BILL_FROM_PARTY_ID = p_ROUNDING_BILL_FROM_PARTY_ID) OR
         ((Recinfo.ROUNDING_BILL_FROM_PARTY_ID IS NULL) AND
          (p_ROUNDING_BILL_FROM_PARTY_ID IS NULL))) AND
        ((Recinfo.RNDG_SHIP_TO_PARTY_SITE_ID = p_RNDG_SHIP_TO_PARTY_SITE_ID) OR
         ((Recinfo.RNDG_SHIP_TO_PARTY_SITE_ID IS NULL) AND
          (p_RNDG_SHIP_TO_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.RNDG_SHIP_FROM_PARTY_SITE_ID = p_RNDG_SHIP_FROM_PARTY_SITE_ID) OR
         ((Recinfo.RNDG_SHIP_FROM_PARTY_SITE_ID IS NULL) AND
          (p_RNDG_SHIP_FROM_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.RNDG_BILL_TO_PARTY_SITE_ID = p_RNDG_BILL_TO_PARTY_SITE_ID) OR
         ((Recinfo.RNDG_BILL_TO_PARTY_SITE_ID IS NULL) AND
          (p_RNDG_BILL_TO_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.RNDG_BILL_FROM_PARTY_SITE_ID = p_RNDG_BILL_FROM_PARTY_SITE_ID) OR
         ((Recinfo.RNDG_BILL_FROM_PARTY_SITE_ID IS NULL) AND
          (p_RNDG_BILL_FROM_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.BILL_FROM_PARTY_SITE_ID = p_BILL_FROM_PARTY_SITE_ID) OR
         ((Recinfo.BILL_FROM_PARTY_SITE_ID IS NULL) AND
          (p_BILL_FROM_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.BILL_TO_PARTY_SITE_ID = p_BILL_TO_PARTY_SITE_ID) OR
         ((Recinfo.BILL_TO_PARTY_SITE_ID IS NULL) AND
          (p_BILL_TO_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.SHIP_FROM_PARTY_SITE_ID = p_SHIP_FROM_PARTY_SITE_ID) OR
         ((Recinfo.SHIP_FROM_PARTY_SITE_ID IS NULL) AND
          (p_SHIP_FROM_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.SHIP_TO_PARTY_SITE_ID = p_SHIP_TO_PARTY_SITE_ID) OR
         ((Recinfo.SHIP_TO_PARTY_SITE_ID IS NULL) AND
          (p_SHIP_TO_PARTY_SITE_ID IS NULL))) AND
        ((Recinfo.SHIP_TO_PARTY_ID = p_SHIP_TO_PARTY_ID) OR
         ((Recinfo.SHIP_TO_PARTY_ID IS NULL) AND
          (p_SHIP_TO_PARTY_ID IS NULL))) AND
        ((Recinfo.SHIP_FROM_PARTY_ID = p_SHIP_FROM_PARTY_ID) OR
         ((Recinfo.SHIP_FROM_PARTY_ID IS NULL) AND
          (p_SHIP_FROM_PARTY_ID IS NULL))) AND
        ((Recinfo.BILL_TO_PARTY_ID = p_BILL_TO_PARTY_ID) OR
         ((Recinfo.BILL_TO_PARTY_ID IS NULL) AND
          (p_BILL_TO_PARTY_ID IS NULL))) AND
        ((Recinfo.BILL_FROM_PARTY_ID = p_BILL_FROM_PARTY_ID) OR
         ((Recinfo.BILL_FROM_PARTY_ID IS NULL) AND
          (p_BILL_FROM_PARTY_ID IS NULL))) AND
        ((Recinfo.SHIP_TO_LOCATION_ID = p_SHIP_TO_LOCATION_ID) OR
         ((Recinfo.SHIP_TO_LOCATION_ID IS NULL) AND
          (p_SHIP_TO_LOCATION_ID IS NULL))) AND
        ((Recinfo.SHIP_FROM_LOCATION_ID = p_SHIP_FROM_LOCATION_ID) OR
         ((Recinfo.SHIP_FROM_LOCATION_ID IS NULL) AND
          (p_SHIP_FROM_LOCATION_ID IS NULL))) AND
        ((Recinfo.BILL_TO_LOCATION_ID = p_BILL_TO_LOCATION_ID) OR
         ((Recinfo.BILL_TO_LOCATION_ID IS NULL) AND
          (p_BILL_TO_LOCATION_ID IS NULL))) AND
        ((Recinfo.BILL_FROM_LOCATION_ID = p_BILL_FROM_LOCATION_ID) OR
         ((Recinfo.BILL_FROM_LOCATION_ID IS NULL) AND
          (p_BILL_FROM_LOCATION_ID IS NULL))) AND
        ((Recinfo.POA_LOCATION_ID = p_POA_LOCATION_ID) OR
         ((Recinfo.POA_LOCATION_ID IS NULL) AND
          (p_POA_LOCATION_ID IS NULL))) AND
        ((Recinfo.POO_LOCATION_ID = p_POO_LOCATION_ID) OR
         ((Recinfo.POO_LOCATION_ID IS NULL) AND
          (p_POO_LOCATION_ID IS NULL))) AND
        ((Recinfo.PAYING_LOCATION_ID = p_PAYING_LOCATION_ID) OR
         ((Recinfo.PAYING_LOCATION_ID IS NULL) AND
          (p_PAYING_LOCATION_ID IS NULL))) AND
        ((Recinfo.OWN_HQ_LOCATION_ID = p_OWN_HQ_LOCATION_ID) OR
         ((Recinfo.OWN_HQ_LOCATION_ID IS NULL) AND
          (p_OWN_HQ_LOCATION_ID IS NULL))) AND
        ((Recinfo.TRADING_HQ_LOCATION_ID = p_TRADING_HQ_LOCATION_ID) OR
         ((Recinfo.TRADING_HQ_LOCATION_ID IS NULL) AND
          (p_TRADING_HQ_LOCATION_ID IS NULL))) AND
        ((Recinfo.POC_LOCATION_ID = p_POC_LOCATION_ID) OR
         ((Recinfo.POC_LOCATION_ID IS NULL) AND
          (p_POC_LOCATION_ID IS NULL))) AND
        ((Recinfo.POI_LOCATION_ID = p_POI_LOCATION_ID) OR
         ((Recinfo.POI_LOCATION_ID IS NULL) AND
          (p_POI_LOCATION_ID IS NULL))) AND
        ((Recinfo.POD_LOCATION_ID = p_POD_LOCATION_ID) OR
         ((Recinfo.POD_LOCATION_ID IS NULL) AND
          (p_POD_LOCATION_ID IS NULL))) AND
        ((Recinfo.TRX_NUMBER = p_TRX_NUMBER) ) AND
        ((Recinfo.TRX_DESCRIPTION = p_TRX_DESCRIPTION) OR
         ((Recinfo.TRX_DESCRIPTION IS NULL) AND
          (p_TRX_DESCRIPTION IS NULL))) AND
        ((Recinfo.DOCUMENT_SUB_TYPE = p_DOCUMENT_SUB_TYPE) OR
         ((Recinfo.DOCUMENT_SUB_TYPE IS NULL) AND
          (p_DOCUMENT_SUB_TYPE IS NULL))) AND
        ((Recinfo.SUPPLIER_TAX_INVOICE_NUMBER = p_SUPPLIER_TAX_INVOICE_NUMBER) OR
         ((Recinfo.SUPPLIER_TAX_INVOICE_NUMBER IS NULL) AND
          (p_SUPPLIER_TAX_INVOICE_NUMBER IS NULL))) AND
        ((Recinfo.SUPPLIER_TAX_INVOICE_DATE = p_supplier_tax_invoice_date) OR
         ((Recinfo.SUPPLIER_TAX_INVOICE_DATE IS NULL) AND
          (p_supplier_tax_invoice_date IS NULL))) AND
        ((Recinfo.SUPPLIER_EXCHANGE_RATE = p_supplier_exchange_rate) OR
         ((Recinfo.SUPPLIER_EXCHANGE_RATE IS NULL) AND
          (p_supplier_exchange_rate IS NULL))) AND
        ((Recinfo.TAX_INVOICE_DATE = p_tax_invoice_date) OR
         ((Recinfo.TAX_INVOICE_DATE IS NULL) AND
          (p_tax_invoice_date IS NULL))) AND
        ((Recinfo.TAX_INVOICE_NUMBER = p_tax_invoice_number) OR
         ((Recinfo.TAX_INVOICE_NUMBER IS NULL) AND
          (p_tax_invoice_number IS NULL))) AND
        ((Recinfo.TITLE_TRANSFER_LOCATION_ID = p_title_transfer_location_id) OR
         ((Recinfo.TITLE_TRANSFER_LOCATION_ID IS NULL) AND
          (p_title_transfer_location_id IS NULL))) AND
        ((Recinfo.TAX_MANUAL_ENTRY_FLAG = p_tax_manual_entry_flag) OR
         ((Recinfo.TAX_MANUAL_ENTRY_FLAG IS NULL) AND
          (p_tax_manual_entry_flag IS NULL))) AND
        ((Recinfo.ESTABLISHMENT_ID = p_ESTABLISHMENT_ID) OR
         ((Recinfo.ESTABLISHMENT_ID IS NULL) AND
          (p_ESTABLISHMENT_ID IS NULL))) AND
        ((Recinfo.RECEIVABLES_TRX_TYPE_ID = p_RECEIVABLES_TRX_TYPE_ID ) OR
         ((Recinfo.RECEIVABLES_TRX_TYPE_ID IS NULL) AND
          (p_RECEIVABLES_TRX_TYPE_ID IS NULL))) AND
        ((Recinfo.DEFAULT_TAXATION_COUNTRY = p_DEFAULT_TAXATION_COUNTRY ) OR
         ((Recinfo.DEFAULT_TAXATION_COUNTRY IS NULL) AND
          (p_DEFAULT_TAXATION_COUNTRY IS NULL))) AND
        ((Recinfo.QUOTE_FLAG = p_QUOTE_FLAG ) OR
         ((Recinfo.QUOTE_FLAG IS NULL) AND
          (p_QUOTE_FLAG IS NULL))) AND
        ((Recinfo.CTRL_TOTAL_HDR_TX_AMT = p_CTRL_TOTAL_HDR_TX_AMT ) OR
         ((Recinfo.CTRL_TOTAL_HDR_TX_AMT IS NULL) AND
          (p_CTRL_TOTAL_HDR_TX_AMT IS NULL))) AND
        ((Recinfo.PORT_OF_ENTRY_CODE = p_PORT_OF_ENTRY_CODE  ) OR
         ((Recinfo.PORT_OF_ENTRY_CODE IS NULL) AND
          (p_PORT_OF_ENTRY_CODE IS NULL))) AND
        ((Recinfo.TAX_REPORTING_FLAG = p_TAX_REPORTING_FLAG  ) OR
         ((Recinfo.TAX_REPORTING_FLAG  IS NULL) AND
          (p_TAX_REPORTING_FLAG  IS NULL))) AND
        ((Recinfo.SHIP_TO_CUST_ACCT_SITE_USE_ID = p_SHIP_TO_CUST_ACCT_SITEUSE_ID ) OR
         ((Recinfo.SHIP_TO_CUST_ACCT_SITE_USE_ID IS NULL) AND
          (p_SHIP_TO_CUST_ACCT_SITEUSE_ID IS NULL))) AND
        ((Recinfo.BILL_TO_CUST_ACCT_SITE_USE_ID = p_BILL_TO_CUST_ACCT_SITEUSE_ID  ) OR
         ((Recinfo.BILL_TO_CUST_ACCT_SITE_USE_ID IS NULL) AND
          (p_BILL_TO_CUST_ACCT_SITEUSE_ID IS NULL))) AND
        ((Recinfo.PROVNL_TAX_DETERMINATION_DATE = p_PROVNL_TAX_DETERM_DATE ) OR
         ((Recinfo.PROVNL_TAX_DETERMINATION_DATE IS NULL) AND
          (p_PROVNL_TAX_DETERM_DATE IS NULL))) AND
         ((Recinfo.APPLIED_TO_TRX_NUMBER = p_APPLIED_TO_TRX_NUMBER ) OR
          ((Recinfo.APPLIED_TO_TRX_NUMBER IS NULL) AND
          (p_APPLIED_TO_TRX_NUMBER IS NULL))) AND
         ((Recinfo.SHIP_THIRD_PTY_ACCT_ID = p_SHIP_THIRD_PTY_ACCT_ID  ) OR
          ((Recinfo.SHIP_THIRD_PTY_ACCT_ID IS NULL) AND
          (p_SHIP_THIRD_PTY_ACCT_ID IS NULL))) AND
         ((Recinfo.BILL_THIRD_PTY_ACCT_ID = p_BILL_THIRD_PTY_ACCT_ID  ) OR
          ((Recinfo.BILL_THIRD_PTY_ACCT_ID IS NULL) AND
          (p_BILL_THIRD_PTY_ACCT_ID IS NULL))) AND
         ((Recinfo.SHIP_THIRD_PTY_ACCT_SITE_ID = p_SHIP_THIRD_PTY_ACCT_SITE_ID  ) OR
          ((Recinfo.SHIP_THIRD_PTY_ACCT_SITE_ID IS NULL) AND
          (p_SHIP_THIRD_PTY_ACCT_SITE_ID IS NULL))) AND
         ((Recinfo.BILL_THIRD_PTY_ACCT_SITE_ID = p_BILL_THIRD_PTY_ACCT_SITE_ID  ) OR
          ((Recinfo.BILL_THIRD_PTY_ACCT_SITE_ID  IS NULL) AND
          (p_BILL_THIRD_PTY_ACCT_SITE_ID IS NULL))) AND
         ((Recinfo.VALIDATION_CHECK_FLAG = p_VALIDATION_CHECK_FLAG  ) OR
          ((Recinfo.VALIDATION_CHECK_FLAG IS NULL) AND
          (p_VALIDATION_CHECK_FLAG IS NULL))) AND
        (Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) AND
        (Recinfo.CREATED_BY = p_created_by) AND
        (Recinfo.CREATION_DATE = p_CREATION_DATE) AND
        (Recinfo.LAST_UPDATED_BY = p_last_updated_by) AND
        (Recinfo.LAST_UPDATE_DATE = p_last_update_date) AND
        ((Recinfo.LAST_UPDATE_LOGIN = p_last_update_login) OR
         ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND
          (p_last_update_login IS NULL))) ) THEN

      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_TRX_MASTER.Lock_Row.END',
                     'ZX_TRX_MASTER: Lock_Row (-)');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_TRX_MASTER.Lock_Row',
                       p_error_buffer);
      END IF;
  END Lock_Row;

END ZX_TRX_MASTER;

/
