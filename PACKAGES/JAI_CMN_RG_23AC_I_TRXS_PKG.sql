--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_23AC_I_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_23AC_I_TRXS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_23p1.pls 120.2 2006/11/23 09:34:07 sacsethi ship $ */

CURSOR c_get_last_record(cp_register_id IN NUMBER) IS
  SELECT slno, opening_balance_qty, closing_balance_qty, fin_year
  FROM JAI_CMN_RG_23AC_I_TRXS
  WHERE register_id = cp_register_id;

PROCEDURE insert_row(
  P_REGISTER_ID OUT NOCOPY JAI_CMN_RG_23AC_I_TRXS.register_id%TYPE,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23AC_I_TRXS.inventory_item_id%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23AC_I_TRXS.organization_id%TYPE,
  P_QUANTITY_RECEIVED             IN  JAI_CMN_RG_23AC_I_TRXS.quantity_received%TYPE,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23AC_I_TRXS.receipt_ref%TYPE,
  P_TRANSACTION_TYPE              IN  JAI_CMN_RG_23AC_I_TRXS.transaction_type%TYPE,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23AC_I_TRXS.receipt_date%TYPE,
  P_PO_HEADER_ID                  IN  JAI_CMN_RG_23AC_I_TRXS.po_header_id%TYPE,
  P_PO_HEADER_DATE                IN  JAI_CMN_RG_23AC_I_TRXS.po_header_date%TYPE,
  P_PO_LINE_ID                    IN  JAI_CMN_RG_23AC_I_TRXS.po_line_id%TYPE,
  P_PO_LINE_LOCATION_ID           IN  JAI_CMN_RG_23AC_I_TRXS.po_line_location_id%TYPE,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23AC_I_TRXS.vendor_id%TYPE,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23AC_I_TRXS.vendor_site_id%TYPE,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23AC_I_TRXS.customer_id%TYPE,
  P_CUSTOMER_SITE_ID              IN  JAI_CMN_RG_23AC_I_TRXS.customer_site_id%TYPE,
  P_GOODS_ISSUE_ID                IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_id_ref%TYPE,
  P_GOODS_ISSUE_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_date%TYPE,
  P_GOODS_ISSUE_QUANTITY          IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_quantity%TYPE,
  P_SALES_INVOICE_ID              IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_no%TYPE,
  P_SALES_INVOICE_DATE            IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_date%TYPE,
  P_SALES_INVOICE_QUANTITY        IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_quantity%TYPE,
  P_EXCISE_INVOICE_ID             IN  JAI_CMN_RG_23AC_I_TRXS.excise_invoice_no%TYPE,
  P_EXCISE_INVOICE_DATE           IN  JAI_CMN_RG_23AC_I_TRXS.excise_invoice_date%TYPE,
  P_OTH_RECEIPT_QUANTITY          IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_quantity%TYPE,
  P_OTH_RECEIPT_ID                IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_id_ref%TYPE,
  P_OTH_RECEIPT_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_date%TYPE,
  P_REGISTER_TYPE                 IN  JAI_CMN_RG_23AC_I_TRXS.register_type%TYPE,
  P_IDENTIFICATION_NO             IN  JAI_CMN_RG_23AC_I_TRXS.identification_no%TYPE,
  P_IDENTIFICATION_MARK           IN  JAI_CMN_RG_23AC_I_TRXS.identification_mark%TYPE,
  P_BRAND_NAME                    IN  JAI_CMN_RG_23AC_I_TRXS.brand_name%TYPE,
  P_DATE_OF_VERIFICATION          IN  JAI_CMN_RG_23AC_I_TRXS.date_of_verification%TYPE,
  P_DATE_OF_INSTALLATION          IN  JAI_CMN_RG_23AC_I_TRXS.date_of_installation%TYPE,
  P_DATE_OF_COMMISSION            IN  JAI_CMN_RG_23AC_I_TRXS.date_of_commission%TYPE,
  P_REGISER_ID_PART_II            IN  JAI_CMN_RG_23AC_I_TRXS.register_id_part_ii%TYPE,
  P_PLACE_OF_INSTALL              IN  JAI_CMN_RG_23AC_I_TRXS.place_of_install%TYPE,
  P_REMARKS                       IN  JAI_CMN_RG_23AC_I_TRXS.remarks%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23AC_I_TRXS.location_id%TYPE,
  P_TRANSACTION_UOM_CODE          IN  JAI_CMN_RG_23AC_I_TRXS.transaction_uom_code%TYPE,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.transaction_date%TYPE,
  P_BASIC_ED                      IN  JAI_CMN_RG_23AC_I_TRXS.basic_ed%TYPE,
  P_ADDITIONAL_ED                 IN  JAI_CMN_RG_23AC_I_TRXS.additional_ed%TYPE,
  P_ADDITIONAL_CVD                IN  JAI_CMN_RG_23AC_I_TRXS.additional_cvd%TYPE DEFAULT NULL, /* bug 5228046 by sacsethi  */
  P_OTHER_ED                      IN  JAI_CMN_RG_23AC_I_TRXS.other_ed%TYPE,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23AC_I_TRXS.charge_account_id%TYPE,
  P_TRANSACTION_SOURCE            IN  VARCHAR2,
  P_CALLED_FROM                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
);

PROCEDURE update_row(
  P_REGISTER_ID                   IN  JAI_CMN_RG_23AC_I_TRXS.register_id%TYPE                               DEFAULT NULL,
  P_QUANTITY_RECEIVED             IN  JAI_CMN_RG_23AC_I_TRXS.quantity_received%TYPE                         DEFAULT NULL,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23AC_I_TRXS.receipt_ref%TYPE                               DEFAULT NULL,
  P_TRANSACTION_TYPE              IN  JAI_CMN_RG_23AC_I_TRXS.transaction_type%TYPE                          DEFAULT NULL,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23AC_I_TRXS.receipt_date%TYPE                              DEFAULT NULL,
  P_RANGE_NO                      IN  JAI_CMN_RG_23AC_I_TRXS.range_no%TYPE                                  DEFAULT NULL,
  P_DIVISION_NO                   IN  JAI_CMN_RG_23AC_I_TRXS.division_no%TYPE                               DEFAULT NULL,
  P_PO_HEADER_ID                  IN  JAI_CMN_RG_23AC_I_TRXS.po_header_id%TYPE                              DEFAULT NULL,
  P_PO_HEADER_DATE                IN  JAI_CMN_RG_23AC_I_TRXS.po_header_date%TYPE                            DEFAULT NULL,
  P_PO_LINE_ID                    IN  JAI_CMN_RG_23AC_I_TRXS.po_line_id%TYPE                                DEFAULT NULL,
  P_PO_LINE_LOCATION_ID           IN  JAI_CMN_RG_23AC_I_TRXS.po_line_location_id%TYPE                       DEFAULT NULL,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23AC_I_TRXS.vendor_id%TYPE                                 DEFAULT NULL,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23AC_I_TRXS.vendor_site_id%TYPE                            DEFAULT NULL,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23AC_I_TRXS.customer_id%TYPE                               DEFAULT NULL,
  P_CUSTOMER_SITE_ID              IN  JAI_CMN_RG_23AC_I_TRXS.customer_site_id%TYPE                          DEFAULT NULL,
  P_GOODS_ISSUE_ID                IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_id_ref%TYPE                        DEFAULT NULL,
  P_GOODS_ISSUE_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_date%TYPE                          DEFAULT NULL,
  P_GOODS_ISSUE_QUANTITY          IN  JAI_CMN_RG_23AC_I_TRXS.goods_issue_quantity%TYPE                      DEFAULT NULL,
  P_SALES_INVOICE_ID              IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_no%TYPE                          DEFAULT NULL,
  P_SALES_INVOICE_DATE            IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_date%TYPE                        DEFAULT NULL,
  P_SALES_INVOICE_QUANTITY        IN  JAI_CMN_RG_23AC_I_TRXS.sales_invoice_quantity%TYPE                    DEFAULT NULL,
  P_EXCISE_INVOICE_ID             IN  JAI_CMN_RG_23AC_I_TRXS.excise_invoice_no%TYPE                         DEFAULT NULL,
  P_EXCISE_INVOICE_DATE           IN  JAI_CMN_RG_23AC_I_TRXS.excise_invoice_date%TYPE                       DEFAULT NULL,
  P_OTH_RECEIPT_QUANTITY          IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_quantity%TYPE                      DEFAULT NULL,
  P_OTH_RECEIPT_ID                IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_id_ref%TYPE                        DEFAULT NULL,
  P_OTH_RECEIPT_DATE              IN  JAI_CMN_RG_23AC_I_TRXS.oth_receipt_date%TYPE                          DEFAULT NULL,
  P_REGISTER_TYPE                 IN  JAI_CMN_RG_23AC_I_TRXS.register_type%TYPE                             DEFAULT NULL,
  P_IDENTIFICATION_NO             IN  JAI_CMN_RG_23AC_I_TRXS.identification_no%TYPE                         DEFAULT NULL,
  P_IDENTIFICATION_MARK           IN  JAI_CMN_RG_23AC_I_TRXS.identification_mark%TYPE                       DEFAULT NULL,
  P_BRAND_NAME                    IN  JAI_CMN_RG_23AC_I_TRXS.brand_name%TYPE                                DEFAULT NULL,
  P_DATE_OF_VERIFICATION          IN  JAI_CMN_RG_23AC_I_TRXS.date_of_verification%TYPE                      DEFAULT NULL,
  P_DATE_OF_INSTALLATION          IN  JAI_CMN_RG_23AC_I_TRXS.date_of_installation%TYPE                      DEFAULT NULL,
  P_DATE_OF_COMMISSION            IN  JAI_CMN_RG_23AC_I_TRXS.date_of_commission%TYPE                        DEFAULT NULL,
  P_REGISER_ID_PART_II            IN  JAI_CMN_RG_23AC_I_TRXS.register_id_part_ii%TYPE                       DEFAULT NULL,
  P_PLACE_OF_INSTALL              IN  JAI_CMN_RG_23AC_I_TRXS.place_of_install%TYPE                          DEFAULT NULL,
  P_REMARKS                       IN  JAI_CMN_RG_23AC_I_TRXS.remarks%TYPE                                   DEFAULT NULL,
  P_BASIC_ED                      IN  JAI_CMN_RG_23AC_I_TRXS.basic_ed%TYPE                                  DEFAULT NULL,
  P_ADDITIONAL_ED                 IN  JAI_CMN_RG_23AC_I_TRXS.additional_ed%TYPE                             DEFAULT NULL,
  P_ADDITIONAL_CVD                IN  JAI_CMN_RG_23AC_I_TRXS.additional_cvd%TYPE                                 DEFAULT NULL, /* Bug 5228046 added by sacsethi   */
  P_OTHER_ED                      IN  JAI_CMN_RG_23AC_I_TRXS.other_ed%TYPE                                  DEFAULT NULL,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23AC_I_TRXS.charge_account_id%TYPE                         DEFAULT NULL,
  P_POSTED_FLAG                   IN  JAI_CMN_RG_23AC_I_TRXS.posted_flag%TYPE                               DEFAULT NULL,
  P_MASTER_FLAG                   IN  JAI_CMN_RG_23AC_I_TRXS.master_flag%TYPE                               DEFAULT NULL,
  P_TRANSACTION_SOURCE            IN  VARCHAR2,
  P_CALLED_FROM                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
);

PROCEDURE update_payment_details(
  p_register_id         IN  NUMBER,
  p_register_id_part_ii IN  NUMBER,
  p_charge_account_id   IN  NUMBER
);

FUNCTION get_trxn_entry_cnt(
  p_register_type   IN VARCHAR2,
  p_organization_id   IN NUMBER,
  p_location_id     IN NUMBER,
  p_inventory_item_id IN NUMBER,
  p_receipt_id    IN VARCHAR2,
  p_transaction_id IN NUMBER
) RETURN NUMBER;

PROCEDURE get_trxn_type_and_id(
  p_transaction_type    IN OUT NOCOPY VARCHAR2,
  p_transaction_source  IN      VARCHAR2,
  p_transaction_id OUT NOCOPY NUMBER
);

END jai_cmn_rg_23ac_i_trxs_pkg;

/
