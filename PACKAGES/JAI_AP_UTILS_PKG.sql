--------------------------------------------------------
--  DDL for Package JAI_AP_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ap_utils.pls 120.7.12010000.3 2009/11/28 15:26:49 bgowrava ship $ */

/*----------------------------------------------------------------------------------------------------------------

Filename:

Change History:

Date          Remarks
---------------------------------------------------------------------------------------------------------
08-Jun-2005    File Version 116.2 Object is Modified to refer to New DB Entity names in place of
               Old DB Entity Names as required for CASE COMPLAINCE.

14-Jun-2005    rchandan for bug#4428980, Version 116.3
               Modified the object to remove literals from DML statements and CURSORS.
               As part OF R12 Initiative Inventory conversion the OPM code is commented

23-Jun-2005    Brathod , File Version 112.0 , Bug# 4445989
               Signature for procedure get_aportion_factor is modified to use invoice_id and invoice_line_number

02-Sep-2005    Ramananda for  Bug#4418550, File Version 120.2
               Added the new function get_tds_invoice_batch

                Dependency Due to this Bug (Functional)
                --------------------------
                jai_ap_utils.plb   (120.2)
                jai_ap_tds_old.plb (120.3)
                jai_ap_tds_gen.plb (120.8)
                jai_constants.pls  (120.3)
                jaiorgdffsetup.sql (120.2)
                ja12alu.ldt, jaivmlu.ldt
16-apr-2007  Vkaranam for bug #5989740,File version 120.3
             Forward porting the changes done in 11i bug#5583832
             Signature for procedure get_aportion_factor is modified.

---------------------------------------------------------------------------------------------------------*/

PROCEDURE create_pla_invoice(
                            P_PLA_ID IN NUMBER,
                            P_SET_OF_BOOK_ID IN NUMBER,
                            P_ORG_ID IN NUMBER
                            );

PROCEDURE create_boe_invoice(
                            P_BOE_ID             IN     NUMBER,
                            P_SET_OF_BOOK_ID     IN     NUMBER,
                            P_ORG_ID             IN     NUMBER
                            );


PROCEDURE insert_ap_inv_interface(
                p_jai_source                      IN  VARCHAR2,
                p_invoice_id OUT NOCOPY ap_invoices_interface.INVOICE_ID%TYPE,
                p_invoice_num                     IN  ap_invoices_interface.INVOICE_NUM%TYPE DEFAULT NULL,
                p_invoice_type_lookup_code        IN  ap_invoices_interface.INVOICE_TYPE_LOOKUP_CODE%TYPE DEFAULT NULL,
                p_invoice_date                    IN  ap_invoices_interface.INVOICE_DATE%TYPE DEFAULT NULL,
                p_po_number                       IN  ap_invoices_interface.PO_NUMBER%TYPE DEFAULT NULL,
                p_vendor_id                       IN  ap_invoices_interface.VENDOR_ID%TYPE DEFAULT NULL,
                p_vendor_num                      IN  ap_invoices_interface.VENDOR_NUM%TYPE DEFAULT NULL,
                p_vendor_name                     IN  ap_invoices_interface.VENDOR_NAME%TYPE DEFAULT NULL,
                p_vendor_site_id                  IN  ap_invoices_interface.VENDOR_SITE_ID%TYPE DEFAULT NULL,
                p_vendor_site_code                IN  ap_invoices_interface.VENDOR_SITE_CODE%TYPE DEFAULT NULL,
                p_invoice_amount                  IN  ap_invoices_interface.INVOICE_AMOUNT%TYPE DEFAULT NULL,
                p_invoice_currency_code           IN  ap_invoices_interface.INVOICE_CURRENCY_CODE%TYPE DEFAULT NULL,
                p_exchange_rate                   IN  ap_invoices_interface.EXCHANGE_RATE%TYPE DEFAULT NULL,
                p_exchange_rate_type              IN  ap_invoices_interface.EXCHANGE_RATE_TYPE%TYPE DEFAULT NULL,
                p_exchange_date                   IN  ap_invoices_interface.EXCHANGE_DATE%TYPE DEFAULT NULL,
                p_terms_id                        IN  ap_invoices_interface.TERMS_ID%TYPE DEFAULT NULL,
                p_terms_name                      IN  ap_invoices_interface.TERMS_NAME%TYPE DEFAULT NULL,
                p_description                     IN  ap_invoices_interface.DESCRIPTION%TYPE DEFAULT NULL,
                p_awt_group_id                    IN  ap_invoices_interface.AWT_GROUP_ID%TYPE DEFAULT NULL,
                p_awt_group_name                  IN  ap_invoices_interface.AWT_GROUP_NAME%TYPE DEFAULT NULL,
                p_last_update_date                IN  ap_invoices_interface.LAST_UPDATE_DATE%TYPE DEFAULT NULL,
                p_last_updated_by                 IN  ap_invoices_interface.LAST_UPDATED_BY%TYPE DEFAULT NULL,
                p_last_update_login               IN  ap_invoices_interface.LAST_UPDATE_LOGIN%TYPE DEFAULT NULL,
                p_creation_date                   IN  ap_invoices_interface.CREATION_DATE%TYPE DEFAULT NULL,
                p_created_by                      IN  ap_invoices_interface.CREATED_BY%TYPE DEFAULT NULL,
                --Added below the attribute category and attribute parameters for Bug #3841637
                p_attribute_category              IN  ap_invoices_interface.ATTRIBUTE_CATEGORY%TYPE DEFAULT NULL,
                p_attribute1                      IN  ap_invoices_interface.ATTRIBUTE1%TYPE DEFAULT NULL,
                p_attribute2                      IN  ap_invoices_interface.ATTRIBUTE2%TYPE DEFAULT NULL,
                p_attribute3                      IN  ap_invoices_interface.ATTRIBUTE3%TYPE DEFAULT NULL,
                p_attribute4                      IN  ap_invoices_interface.ATTRIBUTE4%TYPE DEFAULT NULL,
                p_attribute5                      IN  ap_invoices_interface.ATTRIBUTE5%TYPE DEFAULT NULL,
                p_attribute6                      IN  ap_invoices_interface.ATTRIBUTE6%TYPE DEFAULT NULL,
                p_attribute7                      IN  ap_invoices_interface.ATTRIBUTE7%TYPE DEFAULT NULL,
                p_attribute8                      IN  ap_invoices_interface.ATTRIBUTE8%TYPE DEFAULT NULL,
                p_attribute9                      IN  ap_invoices_interface.ATTRIBUTE9%TYPE DEFAULT NULL,
                p_attribute10                     IN  ap_invoices_interface.ATTRIBUTE10%TYPE DEFAULT NULL,
                p_attribute11                     IN  ap_invoices_interface.ATTRIBUTE11%TYPE DEFAULT NULL,
                p_attribute12                     IN  ap_invoices_interface.ATTRIBUTE12%TYPE DEFAULT NULL,
                p_attribute13                     IN  ap_invoices_interface.ATTRIBUTE13%TYPE DEFAULT NULL,
                p_attribute14                     IN  ap_invoices_interface.ATTRIBUTE14%TYPE DEFAULT NULL,
                p_attribute15                     IN  ap_invoices_interface.ATTRIBUTE15%TYPE DEFAULT NULL,
                p_status                          IN  ap_invoices_interface.STATUS%TYPE DEFAULT NULL,
                p_source                          IN  ap_invoices_interface.SOURCE%TYPE DEFAULT NULL,
                p_group_id                        IN  ap_invoices_interface.GROUP_ID%TYPE DEFAULT NULL,
                p_request_id                      IN  ap_invoices_interface.REQUEST_ID%TYPE DEFAULT NULL,
                p_payment_cross_rate_type         IN  ap_invoices_interface.PAYMENT_CROSS_RATE_TYPE%TYPE DEFAULT NULL,
                p_payment_cross_rate_date         IN  ap_invoices_interface.PAYMENT_CROSS_RATE_DATE%TYPE DEFAULT NULL,
                p_payment_cross_rate              IN  ap_invoices_interface.PAYMENT_CROSS_RATE%TYPE DEFAULT NULL,
                p_payment_currency_code           IN  ap_invoices_interface.PAYMENT_CURRENCY_CODE%TYPE DEFAULT NULL,
                p_workflow_flag                   IN  ap_invoices_interface.WORKFLOW_FLAG%TYPE DEFAULT NULL,
                p_doc_category_code               IN  ap_invoices_interface.DOC_CATEGORY_CODE%TYPE DEFAULT NULL,
                p_voucher_num                     IN  ap_invoices_interface.VOUCHER_NUM%TYPE DEFAULT NULL,
                p_payment_method_lookup_code      IN  ap_invoices_interface.PAYMENT_METHOD_LOOKUP_CODE%TYPE DEFAULT NULL,
                p_pay_group_lookup_code           IN  ap_invoices_interface.PAY_GROUP_LOOKUP_CODE%TYPE DEFAULT NULL,
                p_goods_received_date             IN  ap_invoices_interface.GOODS_RECEIVED_DATE%TYPE DEFAULT NULL,
                p_invoice_received_date           IN  ap_invoices_interface.INVOICE_RECEIVED_DATE%TYPE DEFAULT NULL,
                p_gl_date                         IN  ap_invoices_interface.GL_DATE%TYPE DEFAULT NULL,
                p_accts_pay_ccid                  IN  ap_invoices_interface.ACCTS_PAY_CODE_COMBINATION_ID%TYPE DEFAULT NULL,
                p_ussgl_transaction_code          IN  ap_invoices_interface.USSGL_TRANSACTION_CODE%TYPE DEFAULT NULL,
                p_exclusive_payment_flag          IN  ap_invoices_interface.EXCLUSIVE_PAYMENT_FLAG%TYPE DEFAULT NULL,
                p_org_id                          IN  ap_invoices_interface.ORG_ID%TYPE DEFAULT NULL,
                p_amount_applicable_to_dis        IN  ap_invoices_interface.AMOUNT_APPLICABLE_TO_DISCOUNT%TYPE DEFAULT NULL,
                p_prepay_num                      IN  ap_invoices_interface.PREPAY_NUM%TYPE DEFAULT NULL,
                p_prepay_dist_num                 IN  ap_invoices_interface.PREPAY_DIST_NUM%TYPE DEFAULT NULL,
                p_prepay_apply_amount             IN  ap_invoices_interface.PREPAY_APPLY_AMOUNT%TYPE DEFAULT NULL,
                p_prepay_gl_date                  IN  ap_invoices_interface.PREPAY_GL_DATE%TYPE DEFAULT NULL,
                -- Bug4240179. Added by LGOPALSA. Changed the data type
                -- for the following 4 fields.
                p_invoice_includes_prepay_flag    IN  VARCHAR2 DEFAULT NULL,
                p_no_xrate_base_amount            IN  NUMBER DEFAULT NULL,
                p_vendor_email_address            IN  VARCHAR2 DEFAULT NULL,
                p_terms_date                      IN  DATE DEFAULT NULL,
                p_requester_id                    IN  NUMBER DEFAULT NULL,
                p_ship_to_location                IN  VARCHAR2 DEFAULT NULL,
                p_external_doc_ref                IN  VARCHAR2 DEFAULT NULL,
                -- bug 7109056. Added by Lakshmi Gopalsami
                p_payment_method_code             IN  VARCHAR2  DEFAULT NULL);

PROCEDURE insert_ap_inv_lines_interface(
                p_jai_source                      IN  VARCHAR2,
                p_invoice_id                      IN  ap_invoice_lines_interface.INVOICE_ID%TYPE,
                p_invoice_line_id OUT NOCOPY ap_invoice_lines_interface.INVOICE_LINE_ID%TYPE,
                p_line_number                     IN  ap_invoice_lines_interface.LINE_NUMBER%TYPE DEFAULT NULL,
                p_line_type_lookup_code           IN  ap_invoice_lines_interface.LINE_TYPE_LOOKUP_CODE%TYPE DEFAULT NULL,
                p_line_group_number               IN  ap_invoice_lines_interface.LINE_GROUP_NUMBER%TYPE DEFAULT NULL,
                p_amount                          IN  ap_invoice_lines_interface.AMOUNT%TYPE DEFAULT NULL,
                p_accounting_date                 IN  ap_invoice_lines_interface.ACCOUNTING_DATE%TYPE DEFAULT NULL,
                p_description                     IN  ap_invoice_lines_interface.DESCRIPTION%TYPE DEFAULT NULL,
                p_amount_includes_tax_flag        IN  ap_invoice_lines_interface.AMOUNT_INCLUDES_TAX_FLAG%TYPE DEFAULT NULL,
                p_prorate_across_flag             IN  ap_invoice_lines_interface.PRORATE_ACROSS_FLAG%TYPE DEFAULT NULL,
                p_tax_code                        IN  ap_invoice_lines_interface.TAX_CODE%TYPE DEFAULT NULL,
                p_final_match_flag                IN  ap_invoice_lines_interface.FINAL_MATCH_FLAG%TYPE DEFAULT NULL,
                p_po_header_id                    IN  ap_invoice_lines_interface.PO_HEADER_ID%TYPE DEFAULT NULL,
                p_po_number                       IN  ap_invoice_lines_interface.PO_NUMBER%TYPE DEFAULT NULL,
                p_po_line_id                      IN  ap_invoice_lines_interface.PO_LINE_ID%TYPE DEFAULT NULL,
                p_po_line_number                  IN  ap_invoice_lines_interface.PO_LINE_NUMBER%TYPE DEFAULT NULL,
                p_po_line_location_id             IN  ap_invoice_lines_interface.PO_LINE_LOCATION_ID%TYPE DEFAULT NULL,
                p_po_shipment_num                 IN  ap_invoice_lines_interface.PO_SHIPMENT_NUM%TYPE DEFAULT NULL,
                p_po_distribution_id              IN  ap_invoice_lines_interface.PO_DISTRIBUTION_ID%TYPE DEFAULT NULL,
                p_po_distribution_num             IN  ap_invoice_lines_interface.PO_DISTRIBUTION_NUM%TYPE DEFAULT NULL,
                p_po_unit_of_measure              IN  ap_invoice_lines_interface.PO_UNIT_OF_MEASURE%TYPE DEFAULT NULL,
                p_inventory_item_id               IN  ap_invoice_lines_interface.INVENTORY_ITEM_ID%TYPE DEFAULT NULL,
                p_item_description                IN  ap_invoice_lines_interface.ITEM_DESCRIPTION%TYPE DEFAULT NULL,
                p_quantity_invoiced               IN  ap_invoice_lines_interface.QUANTITY_INVOICED%TYPE DEFAULT NULL,
                p_ship_to_location_code           IN  ap_invoice_lines_interface.SHIP_TO_LOCATION_CODE%TYPE DEFAULT NULL,
                p_unit_price                      IN  ap_invoice_lines_interface.UNIT_PRICE%TYPE DEFAULT NULL,
                p_distribution_set_id             IN  ap_invoice_lines_interface.DISTRIBUTION_SET_ID%TYPE DEFAULT NULL,
                p_distribution_set_name           IN  ap_invoice_lines_interface.DISTRIBUTION_SET_NAME%TYPE DEFAULT NULL,
                p_dist_code_concatenated          IN  ap_invoice_lines_interface.DIST_CODE_CONCATENATED%TYPE DEFAULT NULL,
                p_dist_code_combination_id        IN  ap_invoice_lines_interface.DIST_CODE_COMBINATION_ID%TYPE DEFAULT NULL,
                p_awt_group_id                    IN  ap_invoice_lines_interface.AWT_GROUP_ID%TYPE DEFAULT NULL,
                p_awt_group_name                  IN  ap_invoice_lines_interface.AWT_GROUP_NAME%TYPE DEFAULT NULL,
                p_last_updated_by                 IN  ap_invoice_lines_interface.LAST_UPDATED_BY%TYPE DEFAULT NULL,
                p_last_update_date                IN  ap_invoice_lines_interface.LAST_UPDATE_DATE%TYPE DEFAULT NULL,
                p_last_update_login               IN  ap_invoice_lines_interface.LAST_UPDATE_LOGIN%TYPE DEFAULT NULL,
                p_created_by                      IN  ap_invoice_lines_interface.CREATED_BY%TYPE DEFAULT NULL,
                p_creation_date                   IN  ap_invoice_lines_interface.CREATION_DATE%TYPE DEFAULT NULL,
                --Added below the attribute category and attribute parameters for Bug #3841637
                p_attribute_category              IN  ap_invoices_interface.ATTRIBUTE_CATEGORY%TYPE DEFAULT NULL,
                p_attribute1                      IN  ap_invoices_interface.ATTRIBUTE1%TYPE DEFAULT NULL,
                p_attribute2                      IN  ap_invoices_interface.ATTRIBUTE2%TYPE DEFAULT NULL,
                p_attribute3                      IN  ap_invoices_interface.ATTRIBUTE3%TYPE DEFAULT NULL,
                p_attribute4                      IN  ap_invoices_interface.ATTRIBUTE4%TYPE DEFAULT NULL,
                p_attribute5                      IN  ap_invoices_interface.ATTRIBUTE5%TYPE DEFAULT NULL,
                p_attribute6                      IN  ap_invoices_interface.ATTRIBUTE6%TYPE DEFAULT NULL,
                p_attribute7                      IN  ap_invoices_interface.ATTRIBUTE7%TYPE DEFAULT NULL,
                p_attribute8                      IN  ap_invoices_interface.ATTRIBUTE8%TYPE DEFAULT NULL,
                p_attribute9                      IN  ap_invoices_interface.ATTRIBUTE9%TYPE DEFAULT NULL,
                p_attribute10                     IN  ap_invoices_interface.ATTRIBUTE10%TYPE DEFAULT NULL,
                p_attribute11                     IN  ap_invoices_interface.ATTRIBUTE11%TYPE DEFAULT NULL,
                p_attribute12                     IN  ap_invoices_interface.ATTRIBUTE12%TYPE DEFAULT NULL,
                p_attribute13                     IN  ap_invoices_interface.ATTRIBUTE13%TYPE DEFAULT NULL,
                p_attribute14                     IN  ap_invoices_interface.ATTRIBUTE14%TYPE DEFAULT NULL,
                p_attribute15                     IN  ap_invoices_interface.ATTRIBUTE15%TYPE DEFAULT NULL,
                p_po_release_id                   IN  ap_invoice_lines_interface.PO_RELEASE_ID%TYPE DEFAULT NULL,
                p_release_num                     IN  ap_invoice_lines_interface.RELEASE_NUM%TYPE DEFAULT NULL,
                p_account_segment                 IN  ap_invoice_lines_interface.ACCOUNT_SEGMENT%TYPE DEFAULT NULL,
                p_balancing_segment               IN  ap_invoice_lines_interface.BALANCING_SEGMENT%TYPE DEFAULT NULL,
                p_cost_center_segment             IN  ap_invoice_lines_interface.COST_CENTER_SEGMENT%TYPE DEFAULT NULL,
                p_project_id                      IN  ap_invoice_lines_interface.PROJECT_ID%TYPE DEFAULT NULL,
                p_task_id                         IN  ap_invoice_lines_interface.TASK_ID%TYPE DEFAULT NULL,
                p_expenditure_type                IN  ap_invoice_lines_interface.EXPENDITURE_TYPE%TYPE DEFAULT NULL,
                p_expenditure_item_date           IN  ap_invoice_lines_interface.EXPENDITURE_ITEM_DATE%TYPE DEFAULT NULL,
                p_expenditure_organization_id     IN  ap_invoice_lines_interface.EXPENDITURE_ORGANIZATION_ID%TYPE DEFAULT NULL,
                p_project_accounting_context      IN  ap_invoice_lines_interface.PROJECT_ACCOUNTING_CONTEXT%TYPE DEFAULT NULL,
                p_pa_addition_flag                IN  ap_invoice_lines_interface.PA_ADDITION_FLAG%TYPE DEFAULT NULL,
                p_pa_quantity                     IN  ap_invoice_lines_interface.PA_QUANTITY%TYPE DEFAULT NULL,
                p_ussgl_transaction_code          IN  ap_invoice_lines_interface.USSGL_TRANSACTION_CODE%TYPE DEFAULT NULL,
                p_stat_amount                     IN  ap_invoice_lines_interface.STAT_AMOUNT%TYPE DEFAULT NULL,
                p_type_1099                       IN  ap_invoice_lines_interface.TYPE_1099%TYPE DEFAULT NULL,
                p_income_tax_region               IN  ap_invoice_lines_interface.INCOME_TAX_REGION%TYPE DEFAULT NULL,
                p_assets_tracking_flag            IN  ap_invoice_lines_interface.ASSETS_TRACKING_FLAG%TYPE DEFAULT NULL,
                p_price_correction_flag           IN  ap_invoice_lines_interface.PRICE_CORRECTION_FLAG%TYPE DEFAULT NULL,
                p_org_id                          IN  ap_invoice_lines_interface.ORG_ID%TYPE DEFAULT NULL,
                p_receipt_number                  IN  ap_invoice_lines_interface.RECEIPT_NUMBER%TYPE DEFAULT NULL,
                p_receipt_line_number             IN  ap_invoice_lines_interface.RECEIPT_LINE_NUMBER%TYPE DEFAULT NULL,
                p_match_option                    IN  ap_invoice_lines_interface.MATCH_OPTION%TYPE DEFAULT NULL,
                p_packing_slip                    IN  ap_invoice_lines_interface.PACKING_SLIP%TYPE DEFAULT NULL,
                p_rcv_transaction_id              IN  ap_invoice_lines_interface.RCV_TRANSACTION_ID%TYPE DEFAULT NULL,
                p_pa_cc_ar_invoice_id             IN  ap_invoice_lines_interface.PA_CC_AR_INVOICE_ID%TYPE DEFAULT NULL,
                p_pa_cc_ar_invoice_line_num       IN  ap_invoice_lines_interface.PA_CC_AR_INVOICE_LINE_NUM%TYPE DEFAULT NULL,
                p_reference_1                     IN  ap_invoice_lines_interface.REFERENCE_1%TYPE DEFAULT NULL,
                p_reference_2                     IN  ap_invoice_lines_interface.REFERENCE_2%TYPE DEFAULT NULL,
                p_pa_cc_processed_code            IN  ap_invoice_lines_interface.PA_CC_PROCESSED_CODE%TYPE DEFAULT NULL,
                p_tax_recovery_rate               IN  ap_invoice_lines_interface.TAX_RECOVERY_RATE%TYPE DEFAULT NULL,
                p_tax_recovery_override_flag      IN  ap_invoice_lines_interface.TAX_RECOVERY_OVERRIDE_FLAG%TYPE DEFAULT NULL,
                p_tax_recoverable_flag            IN  ap_invoice_lines_interface.TAX_RECOVERABLE_FLAG%TYPE DEFAULT NULL,
                p_tax_code_override_flag          IN  ap_invoice_lines_interface.TAX_CODE_OVERRIDE_FLAG%TYPE DEFAULT NULL,
                p_tax_code_id                     IN  ap_invoice_lines_interface.TAX_CODE_ID%TYPE DEFAULT NULL,
                p_credit_card_trx_id              IN  ap_invoice_lines_interface.CREDIT_CARD_TRX_ID%TYPE DEFAULT NULL,
                -- Bug 4240179. Changed data for vendor_item_num and award_id
                -- Added by LGOPALSA
                p_award_id                        IN  NUMBER DEFAULT NULL,
                p_vendor_item_num                 IN  VARCHAR2 DEFAULT NULL,
                p_taxable_flag                    IN  VARCHAR2 DEFAULT NULL,
                p_price_correct_inv_num           IN  VARCHAR2 DEFAULT NULL,
                p_external_doc_line_ref           IN  VARCHAR2 DEFAULT NULL);

/* Brathod, For Bug# 4445989, get_apportion_factor signature is modified to use invoice_id and line_number*/
FUNCTION get_apportion_factor(
                             -- p_invoice_distribution_id in number
                               pn_invoice_id  AP_INVOICE_LINES_ALL.INVOICE_ID%TYPE
                             , pn_invoice_line_number AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE
                             --added the foll parameter by vkarnam for bug #5989740
                             , p_factor_type varchar2 default null
                             ) return number ;

PROCEDURE submit_pla_boe_for_approval(
                                    ERRBUF OUT NOCOPY VARCHAR2,
                                    RETCODE OUT NOCOPY VARCHAR2,
                                    p_boe_id          In  VARCHAR2,
                                    p_set_of_books_id In  Number,
                                    p_prv_req_id      In  Number,
                                    p_vendor_id       In  Number
                                    ) ;

--As part OF R12 Inititive Inventory conversion the following code IS commented BY Ravi
--FUNCTION get_opm_assessable_value(p_item_id number,p_qty number,p_exted_price number,P_Cust_Id Number Default 0 ) RETURN NUMBER ;


PROCEDURE pan_update( P_errbuf       OUT NOCOPY varchar2,
                      P_return_code  OUT NOCOPY varchar2,
                      P_vendor_id in   PO_VENDORS.vendor_id%TYPE ,
                      P_old_pan_num  IN JAI_AP_TDS_VENDOR_HDRS.pan_no%TYPE,
                      P_new_pan_num  IN JAI_AP_TDS_VENDOR_HDRS.pan_no%TYPE,
                      P_debug_flag IN varchar2
                    );

/*
|| Added by Ramananda for bug#4584221
*/

/* Begin 4579729 */

FUNCTION get_tds_invoice_batch(p_invoice_id IN  NUMBER,
                               p_org_id number default null)   --added org_id parameter for bug#9149941
    RETURN VARCHAR2;

  procedure jai_calc_ipv_erv ( P_errmsg OUT NOCOPY VARCHAR2,
                               P_retcode OUT NOCOPY Number,
             P_invoice_id in number,
             P_po_dist_id in number,
             P_invoice_distribution_id IN NUMBER,
             P_amount IN NUMBER,
             P_base_amount IN NUMBER,
             P_rcv_transaction_id IN NUMBER,
             P_invoice_price_variance IN NUMBER,
             P_base_invoice_price_variance IN NUMBER,
             P_price_var_ccid IN NUMBER,
             P_Exchange_rate_variance IN NUMBER,
             P_rate_var_ccid IN NUMBER
                      );

FUNCTION fetch_tax_target_amt
( p_invoice_id          IN NUMBER      ,
  p_line_location_id    IN NUMBER ,
  p_transaction_id      IN NUMBER ,
  p_parent_dist_id      IN NUMBER,
  p_tax_id              IN NUMBER
)
RETURN NUMBER ;

/* End 4579729 */
-- Added by Jia Li for Tax inclusive computation on 2007/12/17, Begin
--==========================================================================
--  PROCEDURE NAME:
--
--    acct_inclu_taxes                        Public
--
--  DESCRIPTION:
--
--    This procedure is written that would pass GL entries for inclusive taxes in GL interface
--
--  PARAMETERS:
--      In:  pn_invoice_id                 pass the invoice id for which the accounting needs to done
--           pn_invoice_distribution_id    pass the invoice distribution id for the item line which the accounting needs to done
--     OUt:  xv_process_flag               Indicates the process flag, 'SS' for success
--                                                                     'EE' for expected error
--                                                                     'UE' for unexpected error
--           xv_process_message           Indicates the process message
--
--
--  DESIGN REFERENCES:
--    Inclusive Tax Technical Design V1.4.doc
--
--  CHANGE HISTORY:
--
--           17-DEC-2007   Jia Li  created
--==========================================================================
PROCEDURE acct_inclu_taxes
( pn_invoice_id              IN  NUMBER
, pn_invoice_distribution_id IN NUMBER
, xv_process_flag            OUT NOCOPY VARCHAR2
, xv_process_message         OUT NOCOPY VARCHAR2
);


END jai_ap_utils_pkg ;

/
