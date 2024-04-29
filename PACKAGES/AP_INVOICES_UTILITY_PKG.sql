--------------------------------------------------------
--  DDL for Package AP_INVOICES_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_INVOICES_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: apinvuts.pls 120.17.12010000.4 2010/12/24 04:13:45 pgayen ship $ */

PROCEDURE CHECK_UNIQUE (
              X_ROWID             VARCHAR2,
              X_INVOICE_NUM       VARCHAR2,
              X_VENDOR_ID         NUMBER,
              X_ORG_ID            NUMBER, -- Bug 5407785
	      X_PARTY_SITE_ID     NUMBER, /*Bug9105666*/
	      X_VENDOR_SITE_ID    NUMBER, /*Bug9105666*/
              X_calling_sequence  VARCHAR2);

PROCEDURE CHECK_UNIQUE_VOUCHER_NUM(
              X_ROWID             VARCHAR2,
              X_VOUCHER_NUM       VARCHAR2,
              X_calling_sequence  VARCHAR2);

FUNCTION get_prepay_number(l_prepay_dist_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_prepay_dist_number(l_prepay_dist_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_distribution_total(l_invoice_id IN NUMBER) RETURN NUMBER;

FUNCTION get_posting_status(l_invoice_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_approval_status(
             l_invoice_id               IN NUMBER,
             l_invoice_amount           IN NUMBER,
             l_payment_status_flag      IN VARCHAR2,
             l_invoice_type_lookup_code IN VARCHAR2) return VARCHAR2;

FUNCTION get_po_number(l_invoice_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_release_number(l_invoice_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_receipt_number(l_invoice_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_po_number_list(l_invoice_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_amount_withheld(l_invoice_id IN NUMBER) RETURN NUMBER;

FUNCTION get_prepaid_amount(l_invoice_id IN NUMBER) RETURN NUMBER;

FUNCTION get_notes_count(l_invoice_id IN NUMBER) RETURN NUMBER;

FUNCTION get_holds_count(l_invoice_id IN NUMBER) RETURN NUMBER;

FUNCTION get_sched_holds_count(l_invoice_id IN NUMBER) RETURN NUMBER;  -- Bug 5334577

FUNCTION get_amount_hold_flag(l_invoice_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_vendor_hold_flag(l_invoice_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_total_prepays(
             l_vendor_id   IN NUMBER,
             l_org_id      IN NUMBER) RETURN NUMBER;

FUNCTION get_available_prepays(
             l_vendor_id   IN NUMBER,
             l_org_id      IN NUMBER) RETURN NUMBER;

FUNCTION get_encumbered_flag(l_invoice_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_similar_drcr_memo(
             P_vendor_id                IN number,
             P_vendor_site_id           IN number,
             P_invoice_amount           IN number,
             P_invoice_type_lookup_code IN varchar2,
             P_invoice_currency_code    IN varchar2,
             P_calling_sequence         IN varchar2) RETURN varchar2;

FUNCTION eft_bank_details_exist (
             P_vendor_site_id   IN number,
             P_calling_sequence IN varchar2) RETURN boolean;

FUNCTION eft_bank_curr_details_exist (
             P_vendor_site_id   IN number,
             P_currency_code    IN varchar2,
             P_calling_sequence IN varchar2) RETURN boolean;

FUNCTION selected_for_payment_flag (P_invoice_id IN number) RETURN varchar2;

FUNCTION get_unposted_void_payment (P_invoice_id IN number) RETURN varchar2;

FUNCTION get_discount_pay_dists_flag (P_invoice_id IN number) RETURN varchar2;

FUNCTION get_prepayments_applied_flag (P_invoice_id IN number) RETURN varchar2;

FUNCTION get_payments_exist_flag (P_invoice_id IN number) RETURN varchar2;

FUNCTION get_prepay_amount_applied (P_invoice_id IN number) RETURN number;

FUNCTION get_prepay_amount_remaining (P_invoice_id IN number) RETURN number;

FUNCTION get_prepay_amt_rem_set (P_invoice_id IN number) RETURN number;               -- BUG 4413272

FUNCTION get_prepayment_type (P_invoice_id IN number) RETURN VARCHAR2;

FUNCTION get_packet_id (P_invoice_id IN number) RETURN number;

FUNCTION get_payment_status( p_invoice_id IN  NUMBER ) RETURN VARCHAR2;

FUNCTION is_inv_pmt_prepay_posted(
             P_invoice_id             IN NUMBER,
             P_org_id                 IN NUMBER,
             P_discount_taken         IN NUMBER,
             P_prepaid_amount         IN NUMBER,
             P_automatic_offsets_flag IN VARCHAR2,
             P_discount_dist_method   IN VARCHAR2,
             P_payment_status_flag    IN VARCHAR2) RETURN boolean;

FUNCTION get_pp_amt_applied_on_date (
             P_invoice_id        IN NUMBER,
             P_prepay_id         IN NUMBER,
             P_application_date  IN DATE) RETURN number;

FUNCTION get_dist_count (p_invoice_id IN NUMBER) RETURN NUMBER;

FUNCTION get_amt_applied_per_prepay (
             P_invoice_id           IN NUMBER,
             P_prepay_id            IN NUMBER) RETURN number;

FUNCTION get_explines_count (p_expense_report_id IN NUMBER) RETURN NUMBER;

FUNCTION get_expense_type (
             p_source       in varchar2,
             p_invoice_id   in number) RETURN varchar2;

FUNCTION GET_MAX_INV_LINE_NUM(P_invoice_id IN NUMBER) RETURN NUMBER;

FUNCTION GET_LINE_TOTAL(P_invoice_id IN NUMBER) RETURN NUMBER;

-- table to hold the lines that can be adjusted for rounding -- bug 6892789
TYPE inv_line_num_tab_type IS
TABLE OF AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE
INDEX BY BINARY_INTEGER;

-- function modified to get the lines that can be adjusted -- bug 6892789
FUNCTION round_base_amts(
                       X_Invoice_Id          IN NUMBER,
                       X_Reporting_Ledger_Id IN NUMBER DEFAULT NULL,
                       X_Rounded_Line_Numbers OUT NOCOPY inv_line_num_tab_type,
                       X_Rounded_Amt         OUT NOCOPY NUMBER,
                       X_Debug_Info          OUT NOCOPY VARCHAR2,
                       X_Debug_Context       OUT NOCOPY VARCHAR2,
                       X_Calling_sequence    IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Is_Inv_Credit_Referenced( P_invoice_id  IN NUMBER ) RETURN BOOLEAN;

FUNCTION Inv_With_PQ_Corrections(
           P_Invoice_Id           IN NUMBER,
           P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Inv_With_Prepayments(
           P_Invoice_Id           IN NUMBER,
           P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Invoice_Includes_Awt(
           P_Invoice_Id           IN NUMBER,
           P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Inv_Matched_Finally_Closed_Po(
           P_Invoice_Id           IN NUMBER,
           P_Calling_sequence     IN VARCHAR2) RETURN BOOLEAN;

--Invoice Lines: Distributions
FUNCTION get_max_dist_line_num (P_invoice_id IN number,
                                  P_invoice_line_number IN number) RETURN NUMBER;

--ETAX: Invwkb
FUNCTION get_invoice_num (P_Invoice_Id IN Number) RETURN VARCHAR2;

FUNCTION Get_Retained_Total
		(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER) RETURN NUMBER;

FUNCTION Get_Item_Total
		(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER) RETURN NUMBER;

FUNCTION Get_Freight_Total
		(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER) RETURN NUMBER;

FUNCTION Get_Misc_Total
		(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER) RETURN NUMBER;

FUNCTION Get_Prepay_App_Total
		(P_Invoice_Id IN NUMBER, P_Org_Id IN NUMBER) RETURN NUMBER;

FUNCTION get_invoice_status(
             p_invoice_id               IN NUMBER,
             p_invoice_amount           IN NUMBER,
             p_payment_status_flag      IN VARCHAR2,
             p_invoice_type_lookup_code IN VARCHAR2) return VARCHAR2;

PROCEDURE get_bank_details(
	p_invoice_currency_code	IN VARCHAR2,
	p_party_id				IN NUMBER,
	p_party_site_id			IN NUMBER,
	p_supplier_site_id			IN NUMBER,
	p_org_id				IN NUMBER,
	x_bank_account_name		OUT NOCOPY VARCHAR2,
	x_bank_account_id		OUT NOCOPY VARCHAR2,
	x_bank_account_number	OUT NOCOPY VARCHAR2);

-- FUNCTION get_interface_po_number added for CLM Bug 9503239
FUNCTION get_interface_po_number(p_po_number IN VARCHAR2,
                                 p_org_id    IN NUMBER) RETURN VARCHAR2;

END AP_INVOICES_UTILITY_PKG;

/
