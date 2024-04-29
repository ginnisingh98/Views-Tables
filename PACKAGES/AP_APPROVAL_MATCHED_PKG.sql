--------------------------------------------------------
--  DDL for Package AP_APPROVAL_MATCHED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APPROVAL_MATCHED_PKG" AUTHID CURRENT_USER AS
/* $Header: aprmtchs.pls 120.5.12010000.5 2010/03/22 13:48:35 sjetti ship $ */


/*===========================================================================
 | Public Procedure Specifications
 *==========================================================================*/
    g_debug_mode                     VARCHAR2(1):= 'N';

/*===========================================================================
 | Public Procedure Specifications
 *==========================================================================*/

PROCEDURE Exec_Matched_Variance_Checks(
              p_invoice_id                IN NUMBER,
              p_inv_line_number           IN NUMBER,
              p_base_currency_code        IN VARCHAR2,
              p_inv_currency_code         IN VARCHAR2,
              p_sys_xrate_gain_ccid       IN NUMBER,
              p_sys_xrate_loss_ccid       IN NUMBER,
              p_system_user               IN NUMBER,
              p_holds               IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_hold_count          IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence    IN VARCHAR2);

PROCEDURE Exec_Qty_Variance_Check(
              p_invoice_id                IN NUMBER,
              p_base_currency_code        IN VARCHAR2,
              p_inv_currency_code         IN VARCHAR2,
              p_system_user               IN NUMBER,
              p_calling_sequence          IN VARCHAR2);

/* New Procedure for Amount Vriance Check for Amount Based Matching */
PROCEDURE Exec_Amt_Variance_Check(
              p_invoice_id                IN NUMBER,
              p_base_currency_code        IN VARCHAR2,
              p_inv_currency_code         IN VARCHAR2,
              p_system_user               IN NUMBER,
              p_calling_sequence          IN VARCHAR2);

PROCEDURE Exec_PO_Final_Close(
              p_invoice_id        IN            NUMBER,
              p_system_user       IN            NUMBER,
              p_conc_flag         IN            VARCHAR2,
              p_holds             IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_holds_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count     IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence  IN            VARCHAR2);

PROCEDURE Execute_Matched_Checks(
              p_invoice_id          IN            NUMBER,
              p_base_currency_code  IN            VARCHAR2,
              p_price_tol           IN            NUMBER,
              p_qty_tol             IN            NUMBER,
              p_qty_rec_tol         IN            NUMBER,
              p_max_qty_ord_tol     IN            NUMBER,
              p_max_qty_rec_tol     IN            NUMBER,
        p_amt_tol        IN      NUMBER,
        p_amt_rec_tol      IN      NUMBER,
        p_max_amt_ord_tol     IN      NUMBER,
        p_max_amt_rec_tol     IN      NUMBER,
              p_goods_ship_amt_tolerance      IN  NUMBER,
              p_goods_rate_amt_tolerance      IN  NUMBER,
              p_goods_total_amt_tolerance     IN  NUMBER,
        p_services_ship_amt_tolerance   IN  NUMBER,
        p_services_rate_amt_tolerance   IN  NUMBER,
        p_services_total_amt_tolerance  IN  NUMBER,
              p_system_user         IN            NUMBER,
              p_conc_flag           IN            VARCHAR2,
              p_holds               IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_holds_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_calling_sequence    IN            VARCHAR2);

  -- 7299826 EnC Project
  PROCEDURE exec_pay_when_paid_check(p_invoice_id       IN NUMBER,
                                     p_system_user      IN NUMBER,
                                     p_holds            IN OUT NOCOPY AP_APPROVAL_PKG.holdsarray,
                                     p_holds_count      IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                     p_release_count    IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                     p_calling_sequence IN VARCHAR2);

  -- 7299826 EnC Project
  PROCEDURE exec_po_deliverable_check(p_invoice_id       IN NUMBER,
                                      p_system_user          IN NUMBER,
                                      p_holds            IN OUT NOCOPY AP_APPROVAL_PKG.holdsarray,
                                      p_holds_count      IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                      p_release_count    IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                      p_calling_sequence IN VARCHAR2);

  --for CLM project - bug 9494400
  PROCEDURE exec_partial_funds_check (p_invoice_id       IN NUMBER,
                                     p_system_user      IN NUMBER,
                                     p_holds            IN OUT NOCOPY AP_APPROVAL_PKG.holdsarray,
                                     p_holds_count      IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                     p_release_count    IN OUT NOCOPY AP_APPROVAL_PKG.countarray,
                                     p_calling_sequence IN VARCHAR2) ;

END AP_APPROVAL_MATCHED_PKG;

/
