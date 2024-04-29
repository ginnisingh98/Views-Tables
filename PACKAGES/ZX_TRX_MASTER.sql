--------------------------------------------------------
--  DDL for Package ZX_TRX_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRX_MASTER" AUTHID CURRENT_USER AS
/* $Header: zxritsimmasters.pls 120.11 2005/06/17 23:45:53 pla ship $ */

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
--        p_trx_level_type               VARCHAR2,
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
        p_last_update_login            NUMBER);

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
        p_last_update_login            NUMBER
        );

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
        p_last_update_login            NUMBER
        );

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
        p_last_update_login            NUMBER
        );

END ZX_TRX_MASTER;

 

/
