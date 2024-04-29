--------------------------------------------------------
--  DDL for Package AP_PREPAY_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PREPAY_UTILS_PKG" AUTHID CURRENT_USER AS
/*$Header: apprutls.pls 120.5.12010000.2 2009/12/31 12:15:50 pgayen ship $*/

FUNCTION Get_Line_Prepay_AMT_Remaining (
          P_invoice_id    IN NUMBER,
          P_line_number   IN NUMBER) RETURN NUMBER;

--Contract Payments
FUNCTION Get_Ln_Prep_AMT_Remain_Recoup (
          P_invoice_id    IN NUMBER,
	  P_line_number   IN NUMBER) RETURN NUMBER;

FUNCTION Lock_Line (
          P_invoice_id   IN NUMBER,
          P_line_number  IN NUMBER,
          P_request_id   IN NUMBER) RETURN BOOLEAN;

FUNCTION Unlock_Line (
          P_invoice_id  IN NUMBER,
          P_line_number IN NUMBER) RETURN BOOLEAN;

FUNCTION Unlock_Locked_Lines (
          P_request_id  IN NUMBER) RETURN BOOLEAN;

FUNCTION IS_Line_Locked (
          P_invoice_id  IN NUMBER,
          P_line_number IN NUMBER,
          P_request_id  IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Prepay_Number (
          l_prepay_dist_id IN NUMBER) RETURN VARCHAR2 ;

FUNCTION Get_Prepay_Dist_Number (
          l_prepay_dist_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Prepaid_Amount(
          l_invoice_id IN NUMBER) RETURN NUMBER ;

FUNCTION Get_Total_Prepays(
          l_vendor_id    IN NUMBER,
          l_org_id       IN NUMBER)  RETURN NUMBER ;

FUNCTION Get_Available_Prepays(
          l_vendor_id    IN NUMBER,
          l_org_id       IN NUMBER) RETURN NUMBER ;

FUNCTION Get_Prepay_Amount_Applied (
          P_invoice_id IN number) RETURN NUMBER;

FUNCTION Get_Prepay_Amount_Remaining (
          P_invoice_id IN number) RETURN NUMBER;

FUNCTION Get_Prepayments_Applied_Flag (
          P_invoice_id IN number) RETURN VARCHAR2;

FUNCTION Get_Prepayment_Type (
          P_invoice_id IN number) RETURN VARCHAR2;

FUNCTION Get_Pp_Amt_Applied_On_Date (
          P_invoice_id       IN NUMBER,
          P_prepay_id        IN NUMBER,
          P_application_date IN DATE) RETURN NUMBER;

FUNCTION Get_Amt_Applied_Per_Prepay (
          P_invoice_id          IN NUMBER,
          P_prepay_id           IN NUMBER) RETURN NUMBER;

PROCEDURE Get_Prepay_Amount_Available(
          X_Invoice_ID                   IN          NUMBER,
          X_Prepay_ID                    IN          NUMBER,
          X_Sob_Id                       IN          NUMBER,
          X_Balancing_Segment            OUT NOCOPY  VARCHAR2,
          X_Prepay_Amount                OUT NOCOPY  NUMBER,
          X_Invoice_Amount               OUT NOCOPY  NUMBER);

-- This function will return the prepayment remaining amount
-- exclusive of tax for a line of the prepayment invoice
FUNCTION Get_Ln_Pp_AMT_Remaining_No_Tax(
          P_invoice_id    IN NUMBER,
          P_line_number   IN NUMBER) RETURN NUMBER;

-- This fucntion will return the prepay remaining amount for
-- inclusive taxes for a line of the prepayment invoice
FUNCTION Get_Inc_Tax_PP_Amt_Remaining (
          P_invoice_id    IN NUMBER,
          P_line_number   IN NUMBER) RETURN NUMBER;

-- This function will return the Exclusive tax amount
-- created for a prepayment application
FUNCTION Get_Exc_Tax_Amt_Applied (
          X_Invoice_Id          IN NUMBER,
          X_prepay_invoice_id   IN NUMBER,
          X_prepay_Line_Number  IN NUMBER) RETURN NUMBER;

-- This function will return the total of the invoice
-- unpaid amount not including exclusive taxes
FUNCTION Get_Invoice_Unpaid_Amount (
          X_Invoice_Id          IN NUMBER) RETURN NUMBER;

-- This function will return the total of the invoice
-- unpaid amount including exclusive taxes added for
-- bug6149363
FUNCTION Get_Inv_Tot_Unpaid_Amt (
          X_Invoice_Id          IN NUMBER) RETURN NUMBER;

-- This function will return the total of the invoice
-- unpaid amount not including exclusive taxes
FUNCTION Get_Inclusive_Tax_Unpaid_Amt (
          X_Invoice_Id          IN NUMBER) RETURN NUMBER;

-- This function will return the total of the remaining
-- inclusive tax amount for a distribution
FUNCTION Get_Dist_Inclusive_Tax_Amt (
          X_Invoice_Id               IN NUMBER,
          X_Line_Number              IN NUMBER,
          X_Invoice_Dist_Id          IN NUMBER) RETURN NUMBER;

--Bug 8638881 begin
--This function will return the invoice_includes_prepay_flag of
--the applied prepayment line on standard invoice
FUNCTION Get_pp_appl_inv_incl_pp_flag(
           X_Invoice_Id   IN NUMBER,
	   X_prepay_invoice_id   IN NUMBER,
           X_prepay_Line_Number  IN NUMBER DEFAULT NULL) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_pp_appl_inv_incl_pp_flag, WNDS, WNPS, RNPS); --bug 8638881
PRAGMA RESTRICT_REFERENCES(get_prepay_number, WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES(get_prepay_dist_number, WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES(get_prepaid_amount, WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES(get_prepay_amount_applied, WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES(get_prepay_amount_remaining, WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES(get_prepayment_type, WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES(get_prepayments_applied_flag, WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES(get_pp_amt_applied_on_date, WNDS, WNPS, RNPS);
PRAGMA RESTRICT_REFERENCES(get_amt_applied_per_prepay, WNDS, WNPS, RNPS);


END AP_PREPAY_UTILS_PKG;


/
