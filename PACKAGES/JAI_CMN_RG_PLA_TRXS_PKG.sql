--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_PLA_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_PLA_TRXS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_pla.pls 120.1 2005/07/20 12:57:24 avallabh ship $ */

CURSOR c_get_last_record(cp_register_id IN NUMBER) IS
  SELECT slno, opening_balance, closing_balance, fin_year
  FROM JAI_CMN_RG_PLA_TRXS
  WHERE register_id = cp_register_id;

CURSOR c_orgn_info(cp_organization_id IN NUMBER, cp_location_id IN NUMBER) IS
  SELECT modvat_rm_account_id, modvat_cg_account_id, modvat_pla_account_id, ssi_unit_flag,
        pref_rg23a, pref_rg23c, pref_pla, excise_in_rg23d, excise_23d_account, excise_rcvble_account
  FROM JAI_CMN_INVENTORY_ORGS
  WHERE organization_id = cp_organization_id
  AND location_id = cp_location_id;

PROCEDURE insert_row(
  P_REGISTER_ID OUT NOCOPY JAI_CMN_RG_PLA_TRXS.register_id%TYPE,
  P_TR6_CHALLAN_NO                IN  JAI_CMN_RG_PLA_TRXS.tr6_challan_no%TYPE,
  P_TR6_CHALLAN_DATE              IN  JAI_CMN_RG_PLA_TRXS.tr6_challan_date%TYPE,
  P_CR_BASIC_ED                   IN  JAI_CMN_RG_PLA_TRXS.cr_basic_ed%TYPE,
  P_CR_ADDITIONAL_ED              IN  JAI_CMN_RG_PLA_TRXS.cr_additional_ed%TYPE,
  P_CR_OTHER_ED                   IN  JAI_CMN_RG_PLA_TRXS.cr_other_ed%TYPE,
  P_REF_DOCUMENT_ID               IN  JAI_CMN_RG_PLA_TRXS.ref_document_id%TYPE,
  P_REF_DOCUMENT_DATE             IN  JAI_CMN_RG_PLA_TRXS.ref_document_date%TYPE,
  P_DR_INVOICE_ID                 IN  JAI_CMN_RG_PLA_TRXS.dr_invoice_no%TYPE,
  P_DR_INVOICE_DATE               IN  JAI_CMN_RG_PLA_TRXS.dr_invoice_date%TYPE,
  P_DR_BASIC_ED                   IN  JAI_CMN_RG_PLA_TRXS.dr_basic_ed%TYPE,
  P_DR_ADDITIONAL_ED              IN  JAI_CMN_RG_PLA_TRXS.dr_additional_ed%TYPE,
  P_DR_OTHER_ED                   IN  JAI_CMN_RG_PLA_TRXS.dr_other_ed%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_PLA_TRXS.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_PLA_TRXS.location_id%TYPE,
  P_BANK_BRANCH_ID                IN  JAI_CMN_RG_PLA_TRXS.bank_branch_id%TYPE,
  P_ENTRY_DATE                    IN  JAI_CMN_RG_PLA_TRXS.entry_date%TYPE,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_PLA_TRXS.inventory_item_id%TYPE,
  P_VENDOR_CUST_FLAG              IN  JAI_CMN_RG_PLA_TRXS.vendor_cust_flag%TYPE,
  P_VENDOR_ID                     IN  JAI_CMN_RG_PLA_TRXS.vendor_id%TYPE,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_PLA_TRXS.vendor_site_id%TYPE,
  P_EXCISE_INVOICE_NO             IN  JAI_CMN_RG_PLA_TRXS.excise_invoice_no%TYPE,
  P_REMARKS                       IN  JAI_CMN_RG_PLA_TRXS.remarks%TYPE,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_PLA_TRXS.transaction_date%TYPE,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_PLA_TRXS.charge_account_id%TYPE,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_PLA_TRXS.other_tax_credit%TYPE,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_PLA_TRXS.other_tax_debit%TYPE,
  p_transaction_type              IN  VARCHAR2,
  p_transaction_source            IN  VARCHAR2,
  p_called_from                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2,
  p_rounding_id                   IN  NUMBER default null -- Vijay Shankar for Bug#4103161
);

PROCEDURE update_row(
  P_REGISTER_ID                   IN  JAI_CMN_RG_PLA_TRXS.register_id%TYPE                                       DEFAULT NULL,
  P_FIN_YEAR                      IN  JAI_CMN_RG_PLA_TRXS.fin_year%TYPE                                          DEFAULT NULL,
  P_SLNO                          IN  JAI_CMN_RG_PLA_TRXS.slno%TYPE                                              DEFAULT NULL,
  P_TR6_CHALLAN_NO                IN  JAI_CMN_RG_PLA_TRXS.tr6_challan_no%TYPE                                    DEFAULT NULL,
  P_TR6_CHALLAN_DATE              IN  JAI_CMN_RG_PLA_TRXS.tr6_challan_date%TYPE                                  DEFAULT NULL,
  P_CR_BASIC_ED                   IN  JAI_CMN_RG_PLA_TRXS.cr_basic_ed%TYPE                                       DEFAULT NULL,
  P_CR_ADDITIONAL_ED              IN  JAI_CMN_RG_PLA_TRXS.cr_additional_ed%TYPE                                  DEFAULT NULL,
  P_CR_OTHER_ED                   IN  JAI_CMN_RG_PLA_TRXS.cr_other_ed%TYPE                                       DEFAULT NULL,
  P_TRANSACTION_ID                IN  JAI_CMN_RG_PLA_TRXS.transaction_source_num%TYPE                                    DEFAULT NULL,
  P_REF_DOCUMENT_ID               IN  JAI_CMN_RG_PLA_TRXS.ref_document_id%TYPE                                   DEFAULT NULL,
  P_REF_DOCUMENT_DATE             IN  JAI_CMN_RG_PLA_TRXS.ref_document_date%TYPE                                 DEFAULT NULL,
  P_DR_INVOICE_ID                 IN  JAI_CMN_RG_PLA_TRXS.dr_invoice_no%TYPE                                     DEFAULT NULL,
  P_DR_INVOICE_DATE               IN  JAI_CMN_RG_PLA_TRXS.dr_invoice_date%TYPE                                   DEFAULT NULL,
  P_DR_BASIC_ED                   IN  JAI_CMN_RG_PLA_TRXS.dr_basic_ed%TYPE                                       DEFAULT NULL,
  P_DR_ADDITIONAL_ED              IN  JAI_CMN_RG_PLA_TRXS.dr_additional_ed%TYPE                                  DEFAULT NULL,
  P_DR_OTHER_ED                   IN  JAI_CMN_RG_PLA_TRXS.dr_other_ed%TYPE                                       DEFAULT NULL,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_PLA_TRXS.organization_id%TYPE                                   DEFAULT NULL,
  P_LOCATION_ID                   IN  JAI_CMN_RG_PLA_TRXS.location_id%TYPE                                       DEFAULT NULL,
  P_BANK_BRANCH_ID                IN  JAI_CMN_RG_PLA_TRXS.bank_branch_id%TYPE                                    DEFAULT NULL,
  P_ENTRY_DATE                    IN  JAI_CMN_RG_PLA_TRXS.entry_date%TYPE                                        DEFAULT NULL,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_PLA_TRXS.inventory_item_id%TYPE                                 DEFAULT NULL,
  P_VENDOR_CUST_FLAG              IN  JAI_CMN_RG_PLA_TRXS.vendor_cust_flag%TYPE                                  DEFAULT NULL,
  P_VENDOR_ID                     IN  JAI_CMN_RG_PLA_TRXS.vendor_id%TYPE                                         DEFAULT NULL,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_PLA_TRXS.vendor_site_id%TYPE                                    DEFAULT NULL,
  P_RANGE_NO                      IN  JAI_CMN_RG_PLA_TRXS.range_no%TYPE                                          DEFAULT NULL,
  P_DIVISION_NO                   IN  JAI_CMN_RG_PLA_TRXS.division_no%TYPE                                       DEFAULT NULL,
  P_EXCISE_INVOICE_NO             IN  JAI_CMN_RG_PLA_TRXS.excise_invoice_no%TYPE                                 DEFAULT NULL,
  P_REMARKS                       IN  JAI_CMN_RG_PLA_TRXS.remarks%TYPE                                           DEFAULT NULL,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_PLA_TRXS.transaction_date%TYPE                                  DEFAULT NULL,
  P_OPENING_BALANCE               IN  JAI_CMN_RG_PLA_TRXS.opening_balance%TYPE                                   DEFAULT NULL,
  P_CLOSING_BALANCE               IN  JAI_CMN_RG_PLA_TRXS.closing_balance%TYPE                                   DEFAULT NULL,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_PLA_TRXS.charge_account_id%TYPE                                 DEFAULT NULL,
  P_POSTED_FLAG                   IN  JAI_CMN_RG_PLA_TRXS.posted_flag%TYPE                                       DEFAULT NULL,
  P_MASTER_FLAG                   IN  JAI_CMN_RG_PLA_TRXS.master_flag%TYPE                                       DEFAULT NULL,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_PLA_TRXS.other_tax_credit%TYPE                                  DEFAULT NULL,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_PLA_TRXS.other_tax_debit%TYPE                                   DEFAULT NULL,
  p_rounding_id                   IN  NUMBER default null -- Vijay Shankar for Bug#4103161
);

PROCEDURE update_payment_details(
  p_register_id         IN  NUMBER,
  p_charge_account_id   IN  NUMBER
);

FUNCTION get_trxn_entry_cnt(
  p_organization_id   IN NUMBER,
  p_location_id     IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_ref_document_id    IN NUMBER,
  p_transaction_id IN NUMBER
) RETURN NUMBER;

PROCEDURE get_trxn_type_and_id(
  p_transaction_type    IN OUT NOCOPY VARCHAR2,
  p_transaction_source  IN      VARCHAR2,
  p_transaction_id OUT NOCOPY NUMBER
);

PROCEDURE generate_component_balances(
  errbuf VARCHAR2,
  retcode VARCHAR2
);

END jai_cmn_rg_pla_trxs_pkg;
 

/
