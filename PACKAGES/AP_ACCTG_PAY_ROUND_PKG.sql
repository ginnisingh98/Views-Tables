--------------------------------------------------------
--  DDL for Package AP_ACCTG_PAY_ROUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_ACCTG_PAY_ROUND_PKG" AUTHID CURRENT_USER AS
/* $Header: apacrnds.pls 120.0.12010000.2 2009/04/22 09:09:48 gkarampu ship $ */


  PROCEDURE Do_Rounding
     (P_XLA_Event_Rec    IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Pay_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Clr_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Inv_Rec          IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Inv_Pay_Rec      IN   ap_acctg_pay_dist_pkg.r_inv_pay_info
     ,P_Prepay_Inv_Rec   IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Prepay_Hist_Rec  IN   AP_ACCTG_PREPAY_DIST_PKG.r_prepay_hist_info
     ,P_Prepay_Dist_Rec  IN   AP_ACCTG_PREPAY_DIST_PKG.r_prepay_dist_info
     ,P_Calling_Sequence IN   VARCHAR2
     );

  PROCEDURE Final_Pay
     (P_XLA_Event_Rec    IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Pay_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Clr_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Inv_Rec          IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Inv_Pay_Rec      IN   ap_acctg_pay_dist_pkg.r_inv_pay_info
     ,P_Prepay_Inv_Rec   IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Prepay_Hist_Rec  IN   AP_ACCTG_PREPAY_DIST_PKG.r_prepay_hist_info
     ,P_Prepay_Dist_Rec  IN   AP_ACCTG_PREPAY_DIST_PKG.r_prepay_dist_info
     ,P_Calling_Sequence IN   VARCHAR2
     );


  PROCEDURE Total_Pay
     (P_XLA_Event_Rec    IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Pay_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Inv_Rec          IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Inv_Pay_Rec      IN   ap_acctg_pay_dist_pkg.r_inv_pay_info
     ,P_Calling_Sequence IN   VARCHAR2
     );


  PROCEDURE Compare_Pay
     (P_XLA_Event_Rec    IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Pay_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Inv_Rec          IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Inv_Pay_Rec      IN   ap_acctg_pay_dist_pkg.r_inv_pay_info
     ,P_Calling_Sequence IN   VARCHAR2
     );


  PROCEDURE Total_Appl
     (P_XLA_Event_Rec    IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Pay_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Clr_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Inv_Rec          IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Prepay_Inv_Rec   IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Prepay_Hist_Rec  IN   AP_ACCTG_PREPAY_DIST_PKG.r_prepay_hist_info
     ,P_Prepay_Dist_Rec  IN   AP_ACCTG_PREPAY_DIST_PKG.r_prepay_dist_info
     ,P_Calling_Sequence IN   VARCHAR2
     );


  PROCEDURE Final_Appl
     (P_XLA_Event_Rec    IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Pay_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Clr_Hist_Rec     IN   ap_accounting_pay_pkg.r_pay_hist_info
     ,P_Inv_Rec          IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Prepay_Inv_Rec   IN   ap_accounting_pay_pkg.r_invoices_info
     ,P_Prepay_Hist_Rec  IN   AP_ACCTG_PREPAY_DIST_PKG.r_prepay_hist_info
     ,P_Prepay_Dist_Rec  IN   AP_ACCTG_PREPAY_DIST_PKG.r_prepay_dist_info
     ,P_Calling_Sequence IN   VARCHAR2
     );

  -- Cash Rounding 8288996
  PROCEDURE Final_Cash
     (P_XLA_Event_Rec    IN   ap_accounting_pay_pkg.r_xla_event_info
     ,P_Calling_Sequence IN   VARCHAR2
     );

END AP_ACCTG_PAY_ROUND_PKG;

/
