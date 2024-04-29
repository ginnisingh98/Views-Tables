--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_23AC_II_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_23AC_II_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_23p2.pls 120.5 2006/11/03 11:52:20 sacsethi ship $ */

CURSOR c_get_last_record(cp_register_id IN NUMBER) IS
  SELECT slno, opening_balance, closing_balance, fin_year
  FROM JAI_CMN_RG_23AC_II_TRXS
  WHERE register_id = cp_register_id;

PROCEDURE insert_row(
  P_REGISTER_ID OUT NOCOPY JAI_CMN_RG_23AC_II_TRXS.register_id%TYPE,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23AC_II_TRXS.inventory_item_id%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23AC_II_TRXS.organization_id%TYPE,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23AC_II_TRXS.receipt_ref%TYPE,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23AC_II_TRXS.receipt_date%TYPE,
  P_CR_BASIC_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_basic_ed%TYPE,
  P_CR_ADDITIONAL_ED              IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_ed%TYPE,
  P_CR_ADDITIONAL_CVD             IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_cvd%TYPE DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_CR_OTHER_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_other_ed%TYPE,
  P_DR_BASIC_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_basic_ed%TYPE,
  P_DR_ADDITIONAL_ED              IN  JAI_CMN_RG_23AC_II_TRXS.dr_additional_ed%TYPE,
  P_DR_ADDITIONAL_CVD             IN  JAI_CMN_RG_23AC_II_TRXS.dr_additional_cvd%TYPE DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_DR_OTHER_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_other_ed%TYPE,
  P_EXCISE_INVOICE_NO             IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE,
  P_EXCISE_INVOICE_DATE           IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE,
  P_REGISTER_TYPE                 IN  JAI_CMN_RG_23AC_II_TRXS.register_type%TYPE,
  P_REMARKS                       IN  JAI_CMN_RG_23AC_II_TRXS.remarks%TYPE,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23AC_II_TRXS.vendor_id%TYPE,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23AC_II_TRXS.vendor_site_id%TYPE,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.customer_id%TYPE,
  P_CUSTOMER_SITE_ID              IN  JAI_CMN_RG_23AC_II_TRXS.customer_site_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.location_id%TYPE,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23AC_II_TRXS.transaction_date%TYPE,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23AC_II_TRXS.charge_account_id%TYPE,
  P_REGISTER_ID_PART_I            IN  JAI_CMN_RG_23AC_II_TRXS.register_id_part_i%TYPE,
  P_REFERENCE_NUM                 IN  JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE,
  P_ROUNDING_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.rounding_id%TYPE,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_credit%TYPE,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_debit%TYPE,
  p_transaction_type              IN  VARCHAR2,
  P_TRANSACTION_SOURCE            IN  VARCHAR2,
  P_CALLED_FROM                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2,
  P_ADDITIONAL_CVD                IN  NUMBER DEFAULT NULL -- Harshita for bug 5096787
);

PROCEDURE update_row(
  P_REGISTER_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.register_id%TYPE                              DEFAULT NULL,
  P_FIN_YEAR                      IN  JAI_CMN_RG_23AC_II_TRXS.fin_year%TYPE                                 DEFAULT NULL,
  P_SLNO                          IN  JAI_CMN_RG_23AC_II_TRXS.slno%TYPE                                     DEFAULT NULL,
  P_TRANSACTION_ID                IN  JAI_CMN_RG_23AC_II_TRXS.transaction_source_num%TYPE                           DEFAULT NULL,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23AC_II_TRXS.inventory_item_id%TYPE                        DEFAULT NULL,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23AC_II_TRXS.organization_id%TYPE                          DEFAULT NULL,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23AC_II_TRXS.receipt_ref%TYPE                               DEFAULT NULL,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23AC_II_TRXS.receipt_date%TYPE                             DEFAULT NULL,
  P_RANGE_NO                      IN  JAI_CMN_RG_23AC_II_TRXS.range_no%TYPE                                 DEFAULT NULL,
  P_DIVISION_NO                   IN  JAI_CMN_RG_23AC_II_TRXS.division_no%TYPE                              DEFAULT NULL,
  P_CR_BASIC_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_basic_ed%TYPE                              DEFAULT NULL,
  P_CR_ADDITIONAL_ED              IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_ed%TYPE                         DEFAULT NULL,
  P_CR_ADDITIONAL_CVD             IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_cvd%TYPE                        DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_CR_OTHER_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.cr_other_ed%TYPE                              DEFAULT NULL,
  P_DR_BASIC_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_basic_ed%TYPE                              DEFAULT NULL,
  P_DR_ADDITIONAL_ED              IN  JAI_CMN_RG_23AC_II_TRXS.dr_additional_ed%TYPE                         DEFAULT NULL,
  P_DR_ADDITIONAL_CVD             IN  JAI_CMN_RG_23AC_II_TRXS.cr_additional_cvd%TYPE                        DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_DR_OTHER_ED                   IN  JAI_CMN_RG_23AC_II_TRXS.dr_other_ed%TYPE                              DEFAULT NULL,
  P_EXCISE_INVOICE_NO             IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_no%TYPE                        DEFAULT NULL,
  P_EXCISE_INVOICE_DATE           IN  JAI_CMN_RG_23AC_II_TRXS.excise_invoice_date%TYPE                      DEFAULT NULL,
  P_REGISTER_TYPE                 IN  JAI_CMN_RG_23AC_II_TRXS.register_type%TYPE                            DEFAULT NULL,
  P_REMARKS                       IN  JAI_CMN_RG_23AC_II_TRXS.remarks%TYPE                                  DEFAULT NULL,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23AC_II_TRXS.vendor_id%TYPE                                DEFAULT NULL,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23AC_II_TRXS.vendor_site_id%TYPE                           DEFAULT NULL,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.customer_id%TYPE                              DEFAULT NULL,
  P_CUSTOMER_SITE_ID              IN  JAI_CMN_RG_23AC_II_TRXS.customer_site_id%TYPE                         DEFAULT NULL,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.location_id%TYPE                              DEFAULT NULL,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23AC_II_TRXS.transaction_date%TYPE                         DEFAULT NULL,
  P_OPENING_BALANCE               IN  JAI_CMN_RG_23AC_II_TRXS.opening_balance%TYPE                          DEFAULT NULL,
  P_CLOSING_BALANCE               IN  JAI_CMN_RG_23AC_II_TRXS.closing_balance%TYPE                          DEFAULT NULL,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23AC_II_TRXS.charge_account_id%TYPE                        DEFAULT NULL,
  P_REGISTER_ID_PART_I            IN  JAI_CMN_RG_23AC_II_TRXS.register_id_part_i%TYPE                       DEFAULT NULL,
  P_POSTED_FLAG                   IN  JAI_CMN_RG_23AC_II_TRXS.posted_flag%TYPE                              DEFAULT NULL,
  P_MASTER_FLAG                   IN  JAI_CMN_RG_23AC_II_TRXS.master_flag%TYPE                              DEFAULT NULL,
  P_REFERENCE_NUM                 IN  JAI_CMN_RG_23AC_II_TRXS.reference_num%TYPE                            DEFAULT NULL,
  P_ROUNDING_ID                   IN  JAI_CMN_RG_23AC_II_TRXS.rounding_id%TYPE                              DEFAULT NULL,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_credit%TYPE                         DEFAULT NULL,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_23AC_II_TRXS.other_tax_debit%TYPE                          DEFAULT NULL,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2,
  P_ADDITIONAL_CVD                IN  NUMBER DEFAULT NULL -- Harshita for bug 5096787
);

PROCEDURE update_payment_details(
  p_register_id         IN  NUMBER,
  p_register_id_part_i  IN  NUMBER,
  p_charge_account_id   IN  NUMBER
);

FUNCTION get_trxn_entry_cnt(
  p_register_type     IN VARCHAR2,
  p_organization_id   IN NUMBER,
  p_location_id       IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_receipt_id        IN VARCHAR2,
  p_transaction_id    IN NUMBER,
  p_reference_num     IN VARCHAR2
) RETURN NUMBER;

PROCEDURE get_trxn_type_and_id(
  p_transaction_type    IN OUT NOCOPY VARCHAR2,
  p_transaction_source  IN      VARCHAR2,
  p_transaction_id OUT NOCOPY NUMBER
);

PROCEDURE generate_component_balances
(
    errbuf VARCHAR2,
    retcode VARCHAR2
);

END jai_cmn_rg_23ac_ii_pkg;

/
