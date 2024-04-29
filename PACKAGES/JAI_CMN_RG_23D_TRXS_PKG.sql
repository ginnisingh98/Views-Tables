--------------------------------------------------------
--  DDL for Package JAI_CMN_RG_23D_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_CMN_RG_23D_TRXS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_cmn_rg_23d.pls 120.2 2006/11/23 09:30:30 sacsethi ship $ */

CURSOR c_get_last_record(p_register_id IN NUMBER) IS
  SELECT slno, opening_balance_qty, closing_balance_qty, fin_year
  FROM JAI_CMN_RG_23D_TRXS
  WHERE register_id = p_register_id;

PROCEDURE insert_row(
  P_REGISTER_ID OUT NOCOPY JAI_CMN_RG_23D_TRXS.register_id%TYPE,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23D_TRXS.organization_id%TYPE,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23D_TRXS.location_id%TYPE,
  P_TRANSACTION_TYPE              IN  JAI_CMN_RG_23D_TRXS.transaction_type%TYPE,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23D_TRXS.receipt_ref%TYPE,
  P_QUANTITY_RECEIVED             IN  JAI_CMN_RG_23D_TRXS.quantity_received%TYPE,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23D_TRXS.inventory_item_id%TYPE,
  P_SUBINVENTORY                  IN  JAI_CMN_RG_23D_TRXS.subinventory%TYPE,
  P_REFERENCE_LINE_ID             IN  JAI_CMN_RG_23D_TRXS.reference_line_id%TYPE,
  P_TRANSACTION_UOM_CODE          IN  JAI_CMN_RG_23D_TRXS.transaction_uom_code%TYPE,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23D_TRXS.customer_id%TYPE,
  P_BILL_TO_SITE_ID               IN  JAI_CMN_RG_23D_TRXS.bill_to_site_id%TYPE,
  P_SHIP_TO_SITE_ID               IN  JAI_CMN_RG_23D_TRXS.ship_to_site_id%TYPE,
  P_QUANTITY_ISSUED               IN  JAI_CMN_RG_23D_TRXS.quantity_issued%TYPE,
  P_REGISTER_CODE                 IN  JAI_CMN_RG_23D_TRXS.register_code%TYPE,
  P_RELEASED_DATE                 IN  JAI_CMN_RG_23D_TRXS.released_date%TYPE,
  P_COMM_INVOICE_NO               IN  JAI_CMN_RG_23D_TRXS.comm_invoice_no%TYPE,
  P_COMM_INVOICE_DATE             IN  JAI_CMN_RG_23D_TRXS.comm_invoice_date%TYPE,
  P_RECEIPT_BOE_NUM               IN  JAI_CMN_RG_23D_TRXS.receipt_boe_num%TYPE,
  P_OTH_RECEIPT_ID                IN  JAI_CMN_RG_23D_TRXS.oth_receipt_id_ref%TYPE,
  P_OTH_RECEIPT_DATE              IN  JAI_CMN_RG_23D_TRXS.oth_receipt_date%TYPE,
  P_OTH_RECEIPT_QUANTITY          IN  JAI_CMN_RG_23D_TRXS.oth_receipt_quantity%TYPE,
  P_REMARKS                       IN  JAI_CMN_RG_23D_TRXS.remarks%TYPE,
  P_QTY_TO_ADJUST                 IN  JAI_CMN_RG_23D_TRXS.qty_to_adjust%TYPE,
  P_RATE_PER_UNIT                 IN  JAI_CMN_RG_23D_TRXS.rate_per_unit%TYPE,
  P_EXCISE_DUTY_RATE              IN  JAI_CMN_RG_23D_TRXS.excise_duty_rate%TYPE,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23D_TRXS.charge_account_id%TYPE,
  P_DUTY_AMOUNT                   IN  JAI_CMN_RG_23D_TRXS.duty_amount%TYPE,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23D_TRXS.receipt_date%TYPE,
  P_GOODS_ISSUE_ID                IN  JAI_CMN_RG_23D_TRXS.goods_issue_id%TYPE,
  P_GOODS_ISSUE_DATE              IN  JAI_CMN_RG_23D_TRXS.goods_issue_date%TYPE,
  P_GOODS_ISSUE_QUANTITY          IN  JAI_CMN_RG_23D_TRXS.goods_issue_quantity%TYPE,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23D_TRXS.transaction_date%TYPE,
  P_BASIC_ED                      IN  JAI_CMN_RG_23D_TRXS.basic_ed%TYPE,
  P_ADDITIONAL_ED                 IN  JAI_CMN_RG_23D_TRXS.additional_ed%TYPE,
  P_ADDITIONAL_CVD                IN  JAI_CMN_RG_23D_TRXS.additional_cvd%TYPE DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_OTHER_ED                      IN  JAI_CMN_RG_23D_TRXS.other_ed%TYPE,
  P_CVD                           IN  JAI_CMN_RG_23D_TRXS.cvd%TYPE,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23D_TRXS.vendor_id%TYPE,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23D_TRXS.vendor_site_id%TYPE,
  P_RECEIPT_NUM                   IN  JAI_CMN_RG_23D_TRXS.receipt_num%TYPE,
  P_ATTRIBUTE1                    IN  JAI_CMN_RG_23D_TRXS.attribute1%TYPE,
  P_ATTRIBUTE2                    IN  JAI_CMN_RG_23D_TRXS.attribute2%TYPE,
  P_ATTRIBUTE3                    IN  JAI_CMN_RG_23D_TRXS.attribute3%TYPE,
  P_ATTRIBUTE4                    IN  JAI_CMN_RG_23D_TRXS.attribute4%TYPE,
  P_ATTRIBUTE5                    IN  JAI_CMN_RG_23D_TRXS.attribute5%TYPE,
  P_CONSIGNEE                     IN  JAI_CMN_RG_23D_TRXS.consignee%TYPE,
  P_MANUFACTURER_NAME             IN  JAI_CMN_RG_23D_TRXS.manufacturer_name%TYPE,
  P_MANUFACTURER_ADDRESS          IN  JAI_CMN_RG_23D_TRXS.manufacturer_address%TYPE,
  P_MANUFACTURER_RATE_AMT_PER_UN  IN  JAI_CMN_RG_23D_TRXS.manufacturer_rate_amt_per_unit%TYPE,
  P_QTY_RECEIVED_FROM_MANUFACTUR  IN  JAI_CMN_RG_23D_TRXS.qty_received_from_manufacturer%TYPE,
  P_TOT_AMT_PAID_TO_MANUFACTURER  IN  JAI_CMN_RG_23D_TRXS.tot_amt_paid_to_manufacturer%TYPE,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_23D_TRXS.other_tax_credit%TYPE,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_23D_TRXS.other_tax_debit%TYPE,
  P_TRANSACTION_SOURCE            IN  VARCHAR2,
  P_CALLED_FROM                   IN  VARCHAR2,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
);

PROCEDURE update_row(
  P_REGISTER_ID                   IN  JAI_CMN_RG_23D_TRXS.register_id%TYPE                                    DEFAULT NULL,
  P_ORGANIZATION_ID               IN  JAI_CMN_RG_23D_TRXS.organization_id%TYPE                                DEFAULT NULL,
  P_LOCATION_ID                   IN  JAI_CMN_RG_23D_TRXS.location_id%TYPE                                    DEFAULT NULL,
  P_SLNO                          IN  JAI_CMN_RG_23D_TRXS.slno%TYPE                                           DEFAULT NULL,
  P_FIN_YEAR                      IN  JAI_CMN_RG_23D_TRXS.fin_year%TYPE                                       DEFAULT NULL,
  P_TRANSACTION_TYPE              IN  JAI_CMN_RG_23D_TRXS.transaction_type%TYPE                               DEFAULT NULL,
  P_RECEIPT_ID                    IN  JAI_CMN_RG_23D_TRXS.receipt_ref%TYPE                                     DEFAULT NULL,
  P_QUANTITY_RECEIVED             IN  JAI_CMN_RG_23D_TRXS.quantity_received%TYPE                              DEFAULT NULL,
  P_INVENTORY_ITEM_ID             IN  JAI_CMN_RG_23D_TRXS.inventory_item_id%TYPE                              DEFAULT NULL,
  P_SUBINVENTORY                  IN  JAI_CMN_RG_23D_TRXS.subinventory%TYPE                                   DEFAULT NULL,
  P_REFERENCE_LINE_ID             IN  JAI_CMN_RG_23D_TRXS.reference_line_id%TYPE                              DEFAULT NULL,
  P_PRIMARY_UOM_CODE              IN  JAI_CMN_RG_23D_TRXS.primary_uom_code%TYPE                               DEFAULT NULL,
  P_TRANSACTION_UOM_CODE          IN  JAI_CMN_RG_23D_TRXS.transaction_uom_code%TYPE                           DEFAULT NULL,
  P_CUSTOMER_ID                   IN  JAI_CMN_RG_23D_TRXS.customer_id%TYPE                                    DEFAULT NULL,
  P_BILL_TO_SITE_ID               IN  JAI_CMN_RG_23D_TRXS.bill_to_site_id%TYPE                                DEFAULT NULL,
  P_SHIP_TO_SITE_ID               IN  JAI_CMN_RG_23D_TRXS.ship_to_site_id%TYPE                                DEFAULT NULL,
  P_QUANTITY_ISSUED               IN  JAI_CMN_RG_23D_TRXS.quantity_issued%TYPE                                DEFAULT NULL,
  P_REGISTER_CODE                 IN  JAI_CMN_RG_23D_TRXS.register_code%TYPE                                  DEFAULT NULL,
  P_RELEASED_DATE                 IN  JAI_CMN_RG_23D_TRXS.released_date%TYPE                                  DEFAULT NULL,
  P_COMM_INVOICE_NO               IN  JAI_CMN_RG_23D_TRXS.comm_invoice_no%TYPE                                DEFAULT NULL,
  P_COMM_INVOICE_DATE             IN  JAI_CMN_RG_23D_TRXS.comm_invoice_date%TYPE                              DEFAULT NULL,
  P_RECEIPT_BOE_NUM               IN  JAI_CMN_RG_23D_TRXS.receipt_boe_num%TYPE                                DEFAULT NULL,
  P_OTH_RECEIPT_ID                IN  JAI_CMN_RG_23D_TRXS.oth_receipt_id_ref%TYPE                                 DEFAULT NULL,
  P_OTH_RECEIPT_DATE              IN  JAI_CMN_RG_23D_TRXS.oth_receipt_date%TYPE                               DEFAULT NULL,
  P_OTH_RECEIPT_QUANTITY          IN  JAI_CMN_RG_23D_TRXS.oth_receipt_quantity%TYPE                           DEFAULT NULL,
  P_REMARKS                       IN  JAI_CMN_RG_23D_TRXS.remarks%TYPE                                        DEFAULT NULL,
  P_QTY_TO_ADJUST                 IN  JAI_CMN_RG_23D_TRXS.qty_to_adjust%TYPE                                  DEFAULT NULL,
  P_RATE_PER_UNIT                 IN  JAI_CMN_RG_23D_TRXS.rate_per_unit%TYPE                                  DEFAULT NULL,
  P_EXCISE_DUTY_RATE              IN  JAI_CMN_RG_23D_TRXS.excise_duty_rate%TYPE                               DEFAULT NULL,
  P_CHARGE_ACCOUNT_ID             IN  JAI_CMN_RG_23D_TRXS.charge_account_id%TYPE                              DEFAULT NULL,
  P_DUTY_AMOUNT                   IN  JAI_CMN_RG_23D_TRXS.duty_amount%TYPE                                    DEFAULT NULL,
  P_TRANSACTION_ID                IN  JAI_CMN_RG_23D_TRXS.transaction_source_num%TYPE                                 DEFAULT NULL,
  P_RECEIPT_DATE                  IN  JAI_CMN_RG_23D_TRXS.receipt_date%TYPE                                   DEFAULT NULL,
  P_GOODS_ISSUE_ID                IN  JAI_CMN_RG_23D_TRXS.goods_issue_id%TYPE                                 DEFAULT NULL,
  P_GOODS_ISSUE_DATE              IN  JAI_CMN_RG_23D_TRXS.goods_issue_date%TYPE                               DEFAULT NULL,
  P_GOODS_ISSUE_QUANTITY          IN  JAI_CMN_RG_23D_TRXS.goods_issue_quantity%TYPE                           DEFAULT NULL,
  P_TRANSACTION_DATE              IN  JAI_CMN_RG_23D_TRXS.transaction_date%TYPE                               DEFAULT NULL,
  P_OPENING_BALANCE_QTY           IN  JAI_CMN_RG_23D_TRXS.opening_balance_qty%TYPE                            DEFAULT NULL,
  P_CLOSING_BALANCE_QTY           IN  JAI_CMN_RG_23D_TRXS.closing_balance_qty%TYPE                            DEFAULT NULL,
  P_BASIC_ED                      IN  JAI_CMN_RG_23D_TRXS.basic_ed%TYPE                                       DEFAULT NULL,
  P_ADDITIONAL_ED                 IN  JAI_CMN_RG_23D_TRXS.additional_ed%TYPE                                  DEFAULT NULL,
  P_ADDITIONAL_CVD                IN  JAI_CMN_RG_23D_TRXS.additional_cvd%TYPE                                 DEFAULT NULL, -- Date 01/11/2006 Bug 5228046 added by SACSETHI
  P_OTHER_ED                      IN  JAI_CMN_RG_23D_TRXS.other_ed%TYPE                                       DEFAULT NULL,
  P_CVD                           IN  JAI_CMN_RG_23D_TRXS.cvd%TYPE                                            DEFAULT NULL,
  P_VENDOR_ID                     IN  JAI_CMN_RG_23D_TRXS.vendor_id%TYPE                                      DEFAULT NULL,
  P_VENDOR_SITE_ID                IN  JAI_CMN_RG_23D_TRXS.vendor_site_id%TYPE                                 DEFAULT NULL,
  P_RECEIPT_NUM                   IN  JAI_CMN_RG_23D_TRXS.receipt_num%TYPE                                    DEFAULT NULL,
  P_ATTRIBUTE1                    IN  JAI_CMN_RG_23D_TRXS.attribute1%TYPE                                     DEFAULT NULL,
  P_ATTRIBUTE2                    IN  JAI_CMN_RG_23D_TRXS.attribute2%TYPE                                     DEFAULT NULL,
  P_ATTRIBUTE3                    IN  JAI_CMN_RG_23D_TRXS.attribute3%TYPE                                     DEFAULT NULL,
  P_ATTRIBUTE4                    IN  JAI_CMN_RG_23D_TRXS.attribute4%TYPE                                     DEFAULT NULL,
  P_ATTRIBUTE5                    IN  JAI_CMN_RG_23D_TRXS.attribute5%TYPE                                     DEFAULT NULL,
  P_CONSIGNEE                     IN  JAI_CMN_RG_23D_TRXS.consignee%TYPE                                      DEFAULT NULL,
  P_MANUFACTURER_NAME             IN  JAI_CMN_RG_23D_TRXS.manufacturer_name%TYPE                              DEFAULT NULL,
  P_MANUFACTURER_ADDRESS          IN  JAI_CMN_RG_23D_TRXS.manufacturer_address%TYPE                           DEFAULT NULL,
  P_MANUFACTURER_RATE_AMT_PER_UN  IN  JAI_CMN_RG_23D_TRXS.manufacturer_rate_amt_per_unit%TYPE                 DEFAULT NULL,
  P_QTY_RECEIVED_FROM_MANUFACTUR  IN  JAI_CMN_RG_23D_TRXS.qty_received_from_manufacturer%TYPE                 DEFAULT NULL,
  P_TOT_AMT_PAID_TO_MANUFACTURER  IN  JAI_CMN_RG_23D_TRXS.tot_amt_paid_to_manufacturer%TYPE                   DEFAULT NULL,
  -- following two parameter added by Vijay Shankar for Bug#3940588 as part of Edu Cess Enhancement
  P_OTHER_TAX_CREDIT              IN  JAI_CMN_RG_23D_TRXS.other_tax_credit%TYPE                               DEFAULT NULL,
  P_OTHER_TAX_DEBIT               IN  JAI_CMN_RG_23D_TRXS.other_tax_debit%TYPE                                DEFAULT NULL,
  P_SIMULATE_FLAG                 IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
);

PROCEDURE update_qty_to_adjust(
  p_register_id       IN NUMBER,
  p_quantity          IN NUMBER,
  P_SIMULATE_FLAG     IN  VARCHAR2,
  P_PROCESS_STATUS OUT NOCOPY VARCHAR2,
  P_PROCESS_MESSAGE OUT NOCOPY VARCHAR2
);

PROCEDURE update_payment_details(
  p_register_id       IN  NUMBER,
  p_charge_account_id IN  NUMBER
);

FUNCTION get_trxn_entry_cnt(
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

PROCEDURE make_entry
(p_org_id 		IN NUMBER,
 p_location_id 		IN NUMBER,
 p_trans_type 		IN VARCHAR2,
 p_item_id		IN NUMBER,
 p_subinv_code 		IN VARCHAR2,
 p_pr_uom_code 		IN VARCHAR2,
 p_trans_uom_code 	IN VARCHAR2,
 p_oth_receipt_id 	IN NUMBER,
 p_oth_receipt_date 	IN DATE,
 p_oth_receipt_qty 	IN NUMBER,
 p_transaction_id 	IN NUMBER,
 p_goods_issue_id 	IN NUMBER,
 p_goods_issue_date 	IN DATE,
 p_goods_issue_qty 	IN NUMBER,
 p_trans_date		IN DATE,
 p_creation_date	IN DATE,
 p_created_by		IN NUMBER,
 p_last_update_date	IN DATE,
 p_last_update_login	IN NUMBER,
 p_last_updated_by	IN NUMBER);

 PROCEDURE calculate_qty_balances
(p_org_id IN NUMBER,
 p_fin_year IN NUMBER,
 p_mode VARCHAR2,
 qty NUMBER,
 v_opening_Qty IN OUT NOCOPY NUMBER,
 v_closing_qty IN OUT NOCOPY NUMBER,
 p_inventory_item_id Number) ;

PROCEDURE upd_receipt_qty_matched (p_receipt_id in number,
                                                     p_quantity_applied in number,
                                                     p_qty_to_adjust Number);

END jai_cmn_rg_23d_trxs_pkg;

/
