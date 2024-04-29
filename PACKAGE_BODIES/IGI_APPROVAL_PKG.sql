--------------------------------------------------------
--  DDL for Package Body IGI_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_APPROVAL_PKG" AS
/* $Header: igiexpnb.pls 115.8 2003/08/09 13:36:41 rgopalan ship $ */


--==========================================================================
---------------------------------------------------------------------------
-- Private (Non Public) Procedure Specifications
---------------------------------------------------------------------------
--==========================================================================

PROCEDURE Log(p_msg 	IN VARCHAR2,
	      p_loc	IN VARCHAR2);

FUNCTION Inv_Needs_Approving(p_invoice_id		IN NUMBER,
			     p_run_option		IN VARCHAR2,
			     p_calling_sequence		IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Get_Inv_Matched_Status(p_invoice_id		IN NUMBER,
			        p_calling_sequence	IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE Get_Invoice_Statuses(p_invoice_id       IN NUMBER,
		   	       p_holds_count      IN OUT NOCOPY NUMBER,
			       p_approval_status  IN OUT NOCOPY VARCHAR2,
			       p_calling_sequence IN VARCHAR2);

PROCEDURE Update_Inv_Dists_To_Approved(p_invoice_id	 IN NUMBER,
			     	      p_user_id          IN NUMBER,
			     	      p_calling_sequence IN VARCHAR2);

PROCEDURE Update_Inv_Dists_To_Selected(p_invoice_id		IN NUMBER,
			     	       p_run_option		IN VARCHAR2,
			     	       p_calling_sequence	IN VARCHAR2);

PROCEDURE Approval_Init(p_chart_of_accounts_id		IN OUT NOCOPY NUMBER,
			p_set_of_books_id		IN OUT NOCOPY NUMBER,
			p_auto_offsets_flag		IN OUT NOCOPY VARCHAR2,
			p_recalc_pay_sched_flag		IN OUT NOCOPY VARCHAR2,
			p_flex_method			IN OUT NOCOPY VARCHAR2,
			p_sys_xrate_gain_ccid		IN OUT NOCOPY NUMBER,
			p_sys_xrate_loss_ccid		IN OUT NOCOPY NUMBER,
			p_base_currency_code		IN OUT NOCOPY VARCHAR2,
			p_inv_enc_type_id		IN OUT NOCOPY NUMBER,
 			p_purch_enc_type_id		IN OUT NOCOPY NUMBER,
			p_gl_date_from_receipt_flag	IN OUT NOCOPY VARCHAR2,
			p_match_on_tax_flag		IN OUT NOCOPY VARCHAR2,
			p_enforce_tax_on_acct           IN OUT NOCOPY VARCHAR2,
			p_receipt_acc_days		IN OUT NOCOPY NUMBER,
			p_cash_only			IN OUT NOCOPY BOOLEAN,
			p_system_user			IN OUT NOCOPY NUMBER,
			p_user_id			IN OUT NOCOPY NUMBER,
			p_tax_tolerance			IN OUT NOCOPY NUMBER,
			p_tax_tol_amt_range		IN OUT NOCOPY NUMBER,
			p_ship_amt_tolerance		IN OUT NOCOPY NUMBER,
			p_rate_amt_tolerance		IN OUT NOCOPY NUMBER,
			p_total_amt_tolerance		IN OUT NOCOPY NUMBER,
			p_price_tolerance		IN OUT NOCOPY NUMBER,
			p_qty_tolerance			IN OUT NOCOPY NUMBER,
			p_qty_rec_tolerance		IN OUT NOCOPY NUMBER,
			p_max_qty_ord_tolerance		IN OUT NOCOPY NUMBER,
			p_max_qty_rec_tolerance		IN OUT NOCOPY NUMBER,
			p_cash_basis_enc_nr_flag	IN OUT NOCOPY VARCHAR2,
			p_enable_non_recoverable_tax	IN OUT NOCOPY VARCHAR2,
			p_calling_sequence		IN VARCHAR2);

PROCEDURE Set_Hold(p_invoice_id			IN NUMBER,
		   p_line_location_id		IN NUMBER,
		   p_rcv_transaction_id		IN NUMBER,
		   p_hold_lookup_code		IN VARCHAR2,
		   p_hold_reason		IN VARCHAR2,
		   p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
		   p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   p_calling_sequence		IN VARCHAR2);

PROCEDURE Count_Hold(p_hold_lookup_code		IN VARCHAR2,
		     p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
		     p_count			IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		     p_calling_sequence		IN VARCHAR2);

PROCEDURE Get_Release_Lookup_For_Hold(p_hold_lookup_code       IN VARCHAR2,
		   		      p_release_lookup_code    IN OUT NOCOPY VARCHAR2,
				      p_calling_sequence       IN VARCHAR2);

PROCEDURE Withhold_Tax_On(p_invoice_id			IN NUMBER,
 			  p_gl_date_from_receipt	IN VARCHAR2,
			  p_last_updated_by		IN NUMBER,
			  p_last_update_login		IN NUMBER,
			  p_program_application_id	IN NUMBER,
			  p_program_id			IN NUMBER,
			  p_request_id			IN NUMBER,
			  p_system_user			IN NUMBER,
		   	  p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			  p_holds_count			IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			  p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			  p_calling_sequence		IN VARCHAR2);
--shelley
PROCEDURE Manual_Withhold_Tax(p_invoice_id			IN NUMBER,
			p_last_updated_by		IN NUMBER,
			p_last_update_login		IN NUMBER,
			p_calling_sequence		IN VARCHAR2);

PROCEDURE Execute_Tax_Checks(p_invoice_id		IN NUMBER,
			     p_tax_tolerance		IN NUMBER,
			     p_tax_tol_amt_range	IN NUMBER,
			     p_invoice_currency_code	IN VARCHAR2,
			     p_system_user		IN NUMBER,
			     p_tax_rounding_rule	IN VARCHAR2,
                             p_auto_tax_calc_flag       IN VARCHAR2,
 			     p_match_on_tax_flag        IN VARCHAR2,
			     p_enforce_tax_on_acct      IN VARCHAR2,
			     p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			     p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	     p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			     p_calling_sequence		IN OUT NOCOPY VARCHAR2);

PROCEDURE Calculate_Tax_Variance(p_invoice_id                IN NUMBER,
				 p_invoice_currency_code     IN VARCHAR2,
                                 p_tax_tolerance             IN NUMBER,
                                 p_tax_tol_amt_range         IN NUMBER,
                                 p_tax_rounding_rule         IN VARCHAR2,
                                 p_auto_tax_calc_flag        IN VARCHAR2,
                                 p_tax_var_exists            IN OUT NOCOPY VARCHAR2,
                                 p_out_of_tax_range_exists   IN OUT NOCOPY VARCHAR2,
                                 p_calling_sequence          IN VARCHAR2);

PROCEDURE Verify_Tax_Code(p_invoice_id              IN NUMBER,
                             p_match_on_tax_flag    IN VARCHAR2,
                             p_enforce_tax_on_acct  IN VARCHAR2,
                             p_acct_tax_difference  IN OUT NOCOPY VARCHAR2,
                             p_match_tax_difference IN OUT NOCOPY VARCHAR2,
			     p_system_user	    IN NUMBER,
			     p_holds     	    IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			     p_holds_count          IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	     p_release_count	    IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                             p_calling_sequence     IN VARCHAR2);

PROCEDURE Check_Header_Lvl_Tax_Incl_Excl(p_calc_inclusive	   IN VARCHAR2,
					 p_invoice_id		   IN NUMBER,
                                         p_tax_tolerance           IN NUMBER,
                                         p_tax_tol_amt_range       IN NUMBER,
                                         p_inv_currency_code       IN VARCHAR2,
                                         p_tax_rounding_rule       IN VARCHAR2,
                                         p_tax_rate                IN NUMBER,
                                         p_dist_sum                IN NUMBER,
                                         p_tax_sum                 IN NUMBER,
                                         p_tax_var_exists          IN OUT NOCOPY VARCHAR2,
                                         p_out_of_tax_range_exists IN OUT NOCOPY VARCHAR2,
                                         p_calling_sequence        IN VARCHAR2);

PROCEDURE Check_Line_Level_Tax_Incl_Excl(p_calc_inclusive          IN VARCHAR2,
				   	 p_invoice_id		   IN NUMBER,
					 p_tax_tolerance 	   IN NUMBER,
					 p_tax_tol_amt_range       IN NUMBER,
					 p_inv_currency_code	   IN VARCHAR2,
					 p_tax_rounding_rule	   IN VARCHAR2,
					 p_tax_code_id		   IN NUMBER,
					 p_tax_rate		   IN NUMBER,
					 p_dist_sum		   IN NUMBER,
					 p_tax_sum		   IN NUMBER,
					 p_tax_var_exists	   IN OUT NOCOPY VARCHAR2,
					 p_out_of_tax_range_exists IN OUT NOCOPY VARCHAR2,
					 p_calling_sequence	   IN VARCHAR2);

PROCEDURE Get_Total_Sum(p_invoice_id		IN NUMBER,
			p_total_sum		IN OUT NOCOPY NUMBER,
			p_calling_sequence	IN VARCHAR2);

PROCEDURE Get_Dist_Sum(p_invoice_id		IN NUMBER,
		       p_tax_code_id		IN NUMBER,
		       p_dist_sum		IN OUT NOCOPY NUMBER,
                       p_amt_includes_tax_flag  IN VARCHAR2,
		       p_calling_sequence	IN VARCHAR2);

PROCEDURE Get_Tax_Sum(p_invoice_id		IN NUMBER,
		      p_tax_code_id		IN NUMBER,
		      p_tax_sum			IN OUT NOCOPY NUMBER,
                      p_amt_includes_tax_flag   IN VARCHAR2,
		      p_calling_sequence	IN VARCHAR2);

PROCEDURE Execute_General_Checks(p_invoice_id		IN NUMBER,
			     	 p_set_of_books_id	IN NUMBER,
			      	 p_base_currency_code	IN VARCHAR2,
                                 p_invoice_amount            IN NUMBER,
                                 p_base_amount               IN NUMBER,
                                 p_invoice_currency_code     IN VARCHAR2,
                                 p_invoice_amount_limit      IN NUMBER,
                                 p_hold_future_payments_flag IN VARCHAR2,
				 p_system_user	       	IN NUMBER,
			      	 p_holds		IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			      	 p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			      	 p_release_count	IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			      	 p_calling_sequence 	IN VARCHAR2);

PROCEDURE Check_Future_Period(p_invoice_id		IN NUMBER,
			      p_set_of_books_id		IN NUMBER,
			      p_system_user		IN NUMBER,
			      p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			      p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	      p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			      p_calling_sequence	IN VARCHAR2);

PROCEDURE Check_Dist_Variance(p_invoice_id		IN NUMBER,
                              p_base_currency_code      IN VARCHAR2,
			      p_system_user		IN NUMBER,
			      p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			      p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	      p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			      p_calling_sequence	IN VARCHAR2);

PROCEDURE Check_No_Rate(p_invoice_id		IN NUMBER,
			p_base_currency_code	IN VARCHAR2,
			p_system_user		IN NUMBER,
			p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		  	p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			p_calling_sequence	IN VARCHAR2);

PROCEDURE Check_invoice_vendor(p_invoice_id         IN NUMBER,
                        p_base_currency_code        IN VARCHAR2,
                        p_invoice_amount            IN NUMBER,
                        p_base_amount               IN NUMBER,
                        p_invoice_currency_code     IN VARCHAR2,
                        p_invoice_amount_limit      IN NUMBER,
                        p_hold_future_payments_flag IN VARCHAR2,
                        p_system_user               IN NUMBER,
                        p_holds                     IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
                        p_holds_count               IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                        p_release_count             IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                        p_calling_sequence          IN VARCHAR2);



PROCEDURE Check_Invalid_Dist_Acct(p_invoice_id          IN NUMBER,
                                  p_system_user         IN NUMBER,
                                  p_holds               IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
                                  p_holds_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                                  p_release_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                                  p_calling_sequence    IN VARCHAR2);

PROCEDURE Approve(p_run_option			IN VARCHAR2,
             	  p_invoice_batch_id		IN NUMBER,
                  p_begin_invoice_date		IN DATE,
                  p_end_invoice_date		IN DATE,
                  p_vendor_id			IN NUMBER,
                  p_pay_group			IN VARCHAR2,
                  p_invoice_id			IN NUMBER,
                  p_entered_by			IN NUMBER,
                  p_set_of_books_id		IN NUMBER,
                  p_trace_option		IN VARCHAR2,
		  p_conc_flag			IN VARCHAR2,
		  p_holds_count			IN OUT NOCOPY NUMBER,
		  p_approval_status		IN OUT NOCOPY VARCHAR2,
		  p_calling_sequence		IN VARCHAR2) IS
BEGIN
NULL;
END Approve;

--============================================================================
-- APPROVAL_INIT:  Procedure called by APPROVAL to retrieve system variables
--		   to be used by the APPROVAL program
--
-- All parameters are in out:  To be populated by the procecure
--
-- Procedure Flow:
-- ---------------
-- Retrieve system parameters
-- Determine if accounting method is Cash Only
-- Retrieve profile option user_id
-- Set approval system user_id value
-- Retrieve system tolerances
--============================================================================

PROCEDURE Approval_Init(p_chart_of_accounts_id		IN OUT NOCOPY NUMBER,
			p_set_of_books_id		IN OUT NOCOPY NUMBER,
			p_auto_offsets_flag		IN OUT NOCOPY VARCHAR2,
			p_recalc_pay_sched_flag		IN OUT NOCOPY VARCHAR2,
			p_flex_method			IN OUT NOCOPY VARCHAR2,
			p_sys_xrate_gain_ccid		IN OUT NOCOPY NUMBER,
			p_sys_xrate_loss_ccid		IN OUT NOCOPY NUMBER,
			p_base_currency_code		IN OUT NOCOPY VARCHAR2,
			p_inv_enc_type_id		IN OUT NOCOPY NUMBER,
 			p_purch_enc_type_id		IN OUT NOCOPY NUMBER,
			p_gl_date_from_receipt_flag	IN OUT NOCOPY VARCHAR2,
			p_match_on_tax_flag		IN OUT NOCOPY VARCHAR2,
			p_enforce_tax_on_acct           IN OUT NOCOPY VARCHAR2,
			p_receipt_acc_days		IN OUT NOCOPY NUMBER,
			p_cash_only			IN OUT NOCOPY BOOLEAN,
			p_system_user			IN OUT NOCOPY NUMBER,
			p_user_id			IN OUT NOCOPY NUMBER,
			p_tax_tolerance			IN OUT NOCOPY NUMBER,
			p_tax_tol_amt_range		IN OUT NOCOPY NUMBER,
			p_ship_amt_tolerance		IN OUT NOCOPY NUMBER,
			p_rate_amt_tolerance		IN OUT NOCOPY NUMBER,
			p_total_amt_tolerance		IN OUT NOCOPY NUMBER,
			p_price_tolerance		IN OUT NOCOPY NUMBER,
			p_qty_tolerance			IN OUT NOCOPY NUMBER,
			p_qty_rec_tolerance		IN OUT NOCOPY NUMBER,
			p_max_qty_ord_tolerance		IN OUT NOCOPY NUMBER,
			p_max_qty_rec_tolerance		IN OUT NOCOPY NUMBER,
			p_cash_basis_enc_nr_flag	IN OUT NOCOPY VARCHAR2,
			p_enable_non_recoverable_tax	IN OUT NOCOPY VARCHAR2,
			p_calling_sequence		IN VARCHAR2) IS
BEGIN
NULL;
END Approval_Init;


--============================================================================
-- INV_NEEDS_APPROVING:  Function when given an invoice_id and run_option,
--			 it returns a boolean to indicate whether to approve
-- an invoice or not.  Returns FALSE if the run_option is 'New' and the
-- invoice doesn't have any unapproved distributions
--============================================================================
FUNCTION Inv_Needs_Approving(p_invoice_id		IN NUMBER,
			     p_run_option		IN VARCHAR2,
			     p_calling_sequence		IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
NULL;
END Inv_Needs_Approving;


--============================================================================
-- UPDATE_INV_DISTS_TO_SELECTED:  Procedure given the invoice_id and
--				  run option, updates the invoice distributions
-- to be selected for approval depending on the run option.  If the run_option
-- is 'New' then we only select distributions that have never been processed by
-- approval, otherwise we select all distributions that have not successfully
-- been approved.
--============================================================================
PROCEDURE Update_Inv_Dists_To_Selected(p_invoice_id	IN NUMBER,
			     	     p_run_option	IN VARCHAR2,
			     	     p_calling_sequence	IN VARCHAR2) IS
BEGIN
NULL;
END Update_Inv_Dists_To_Selected;


--============================================================================
-- EXECUTE_GENERAL_CHECKS:  Procedure that performs general invoice checks
--			    on the invoice.
--
-- Parameters:
-- -----------
--
-- p_invoice_id:  Invoice Id
--
-- p_set_of_books_id:  Set of Books Id
--
-- p_base_currency_code:  Base Currency Code
--
-- p_system_user:  Approval Program User Id
--
-- p_holds:  Holds Array
--
-- p_holds_count:  Holds Count Array
--
-- p_release_count:  Release Count Array
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--
-- Procedure Flow:
-- ---------------
--
-- Check for Invalid Dist Acct - set or release hold depending on condition
-- Check for PO Required - set or release hold depending on condition
-- Check for Missing Exchange Rate - set or release hold depending on contition
-- Check for Dist Variance - set or release hold depending on condition
-- Check for UnOpen Future Period - set or release hold depending on condition
-- Check for Invoice Limit and vendor holds - set or release hold depending on
--                                          condition
--============================================================================
PROCEDURE Execute_General_Checks(p_invoice_id		     IN NUMBER,
			     	 p_set_of_books_id	     IN NUMBER,
			      	 p_base_currency_code	     IN VARCHAR2,
                                 p_invoice_amount            IN NUMBER,
                                 p_base_amount	             IN NUMBER,
                                 p_invoice_currency_code     IN VARCHAR2,
                                 p_invoice_amount_limit      IN NUMBER,
                                 p_hold_future_payments_flag IN VARCHAR2,
				 p_system_user		     IN NUMBER,
			      	 p_holds		     IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			      	 p_holds_count		     IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			      	 p_release_count	     IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			      	 p_calling_sequence 	     IN VARCHAR2) IS
BEGIN
NULL;
END Execute_General_Checks;


--============================================================================
-- CHECK_INVALID_DIST_ACCT:  Procedure that checks whether an invoice has
--                           a distribution with an invalid distribution
-- account and places or releases the DIST ACCT INVALID hold depending on
-- the condition.
--============================================================================
PROCEDURE Check_Invalid_Dist_Acct(p_invoice_id          IN NUMBER,
                                  p_system_user         IN NUMBER,
                                  p_holds               IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
                                  p_holds_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                                  p_release_count       IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                                  p_calling_sequence    IN VARCHAR2)IS
BEGIN
NULL;
END Check_Invalid_Dist_Acct;


--============================================================================
-- CHECK_PO_REQUIRED:  Procedure that checks whether an invoice has a
--		       PO REQUIRED condition and places or releases the hold
-- depending on the condition.
--============================================================================

PROCEDURE Check_PO_Required(p_invoice_id	IN NUMBER,
			    p_system_user	IN NUMBER,
			    p_holds		IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			    p_holds_count	IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	    p_release_count	IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			    p_calling_sequence	IN VARCHAR2)IS
BEGIN
NULL;
END Check_PO_Required;


--============================================================================
-- CHECK_NO_RATE:  Procedure that checks if an invoice is a foreign invoice
--		   missing an exchange rate and places or releases the
--		   'NO RATE' hold depending on the condition.
--============================================================================
PROCEDURE Check_No_Rate(p_invoice_id		IN NUMBER,
			p_base_currency_code	IN VARCHAR2,
			p_system_user		IN NUMBER,
			p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		  	p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			p_calling_sequence	IN VARCHAR2)IS
BEGIN
NULL;
END Check_No_Rate;


--============================================================================
-- CHECK_DIST_VARIANCE:  Procedure that checks whether an invoice has a
--			 DIST VARIANCE condition, i.e. distribution total
-- does not equal to invoice amount and places or releases the hold depending
-- on the condition.
--============================================================================

PROCEDURE Check_Dist_Variance(p_invoice_id		IN NUMBER,
                              p_base_currency_code      IN VARCHAR2,
			      p_system_user		IN NUMBER,
			      p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			      p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	      p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			      p_calling_sequence	IN VARCHAR2)IS
BEGIN
NULL;
END Check_Dist_Variance;


--============================================================================
-- CHECK_FUTURE_PERIOD:  Procedure that checks whether an invoice has a
--			 distribution line whose accounting date is in an
-- future period and places or releases the FUTURE PERIOD hold depending on
-- the condition.
--============================================================================
PROCEDURE Check_Future_Period(p_invoice_id		IN NUMBER,
			      p_set_of_books_id		IN NUMBER,
			      p_system_user		IN NUMBER,
			      p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			      p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	      p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			      p_calling_sequence	IN VARCHAR2)IS
BEGIN
NULL;
END Check_Future_Period;

--============================================================================
-- CHECK_INVOICE_VENDOR: Procedure that checks if an invoice has any of the
--			 following:
--			 1. Exceeds the invoice amount limit stated at the
--			    vendor site level and places or releases the
--			    'AMOUNT' hold depending on the condition.
--			 2. The vendor site has set to hold future payments
--			    and places or release the 'VENDOR' hold depending
--			    on the condition.
--============================================================================
PROCEDURE Check_invoice_vendor(p_invoice_id            IN NUMBER,
                        p_base_currency_code        IN VARCHAR2,
                        p_invoice_amount            IN NUMBER,
                        p_base_amount               IN NUMBER,
                        p_invoice_currency_code     IN VARCHAR2,
                        p_invoice_amount_limit      IN NUMBER,
                        p_hold_future_payments_flag IN VARCHAR2,
                        p_system_user               IN NUMBER,
                        p_holds                     IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
                        p_holds_count               IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                        p_release_count             IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                        p_calling_sequence          IN VARCHAR2)IS
BEGIN
NULL;
END Check_invoice_vendor;


--============================================================================
-- EXECUTE_TAX_CHECKS:  Procedure that perfroms tax checks on an invoice
--
-- Parameters:
--
-- p_invoice_id:  Invoice Id
--
-- p_tax_tolerance:  System Tax Tolerance
--
-- p_tax_tol_amt_range:  System Tax Tolerance Amount Range
--
-- p_invoice_currency_code: Invoice Currency Code
--
-- p_system_user:  Approval Program User Id
--
-- p_tax_rounding_rule:  Tax Rounding Rule(Up, Down or Nearest)
--
-- p_auto_tax_calc_flag: Kind of automatic tax calculation if any.
--
-- p_holds:  Holds Array
--
-- p_holds_count:  Holds Count Array
--
-- p_release_count:  Release Count Array
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--
-- Procedure Flow:
-- ---------------
-- For an invoice call to calculate the variance
-- Set or Release TAX VARIANCE hold if one of the dist tax lines has the
--  condition
-- Set or Release TAX AMOUNT RANGE hold if one of the dist tax lines has the
--  condition
--============================================================================
PROCEDURE Execute_Tax_Checks(p_invoice_id		IN NUMBER,
			     p_tax_tolerance		IN NUMBER,
			     p_tax_tol_amt_range	IN NUMBER,
			     p_invoice_currency_code    IN VARCHAR2,
			     p_system_user		IN NUMBER,
			     p_tax_rounding_rule	IN VARCHAR2,
			     p_auto_tax_calc_flag       IN VARCHAR2,
 			     p_match_on_tax_flag        IN VARCHAR2,
			     p_enforce_tax_on_acct      IN VARCHAR2,
			     p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			     p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	     p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			     p_calling_sequence		IN OUT NOCOPY VARCHAR2)IS
BEGIN
NULL;
END Execute_Tax_Checks;


--============================================================================
-- CALCULATE_TAX_VARIANCE: Procedure called both from batch and online
--                         approval to return variance results on a
--                         particular invoice and vat code.
-- Parameters:
-- p_invoice_id: Id of the Invoice in question
-- p_invoice_currency_code: Invoice Currency
-- p_tax_tolerance: The % tax tolerance
-- p_tax_tol_amt_range: The amount range of tax tolerance
-- p_auto_tax_calc_flag: The current setting for automatic tax calculation
-- p_tax_var_exists: Flag that indicates whether tax variance exists
-- p_out_of_tax_range_exists: Flag that indicates if tax is out NOCOPY of tolerance
--                            range.
--
-- FOR each distribution tax line for the invoice
-- (modified now, to only select distribution lines with distinct vat_codes -
--  bug #665011)
--   Retrieve the Tax Sum
--   Retrieve the Tax Rate
--   Retrieve the Dist Sum
--   IF Dist_Sum is null
--     Retrieve the Total_Sum
--     Use the Total_Sum as the Sum on which to calculate tax
--   ELSE
--     Use the Dist_Sum as the Sum on which to calculate tax
--   Calculate variances using the appropriate (inclusive vs exclusive method)
-- END LOOP
--
-- NOTE: Tax Variance calculation is ***VERY*** related to the method
--       utilized for calculating the tax originally. i.e. if when the
--       invoice is entered the tax is calculated as an inclusive amount
--       on an invoice total, that may yield different results than if
--       the tax is calculated as an exclusive amount on the sum of the
--       distribution lines of type <> TAX.   This is due to loss of precision
--       during rounding.
--       e.g. Assume: invoice total = $10.82 tax rate = 6.5% and rounding = UP
--            Automatic tax calculation yields: distribution = $10.15
--                                              tax line = $0.67
--            However, exclusive tax calculation on the distribution would
--            yield: tax line = $0.66
--       Rules: 1. If automatic tax calculation is Header we assume inclusive
--                 tax calculation.
--              2. If automatic tax calculation is Line or Tax Code we do
--                 both inclusive tax calculation for those lines which have
--                 the amount includes tax flag set to Y and exclusive tax
--                 calculation for those lines which have the amount includes
--                 tax flag set to N.  Note that we use as the tax sum the
--                 tax lines with the includes tax flag set to Y or N respectively.
--              3. Due to recoverability/nonrecoverability we will also
--                 group by project information and po_distribution_id which
--                 we obtain off the nonrecoverable lines.
--              4. If automatic tax calculation is OFF we assume exclusive
--                 tax calculation.
--============================================================================
PROCEDURE Calculate_Tax_Variance(p_invoice_id              IN NUMBER,
				 p_invoice_currency_code   IN VARCHAR2,
                                 p_tax_tolerance           IN NUMBER,
                                 p_tax_tol_amt_range       IN NUMBER,
                                 p_tax_rounding_rule       IN VARCHAR2,
                                 p_auto_tax_calc_flag      IN VARCHAR2,
                                 p_tax_var_exists          IN OUT NOCOPY VARCHAR2,
                                 p_out_of_tax_range_exists IN OUT NOCOPY VARCHAR2,
                                 p_calling_sequence        IN VARCHAR2) IS
BEGIN
NULL;
END Calculate_Tax_Variance;


--============================================================================
-- CHECK_HEADER_LVL_TAX_INCL_EXCL:  Procedure that performs tax checks on an
--			            invoice assuming tax calculations should
--				    be per invoice.  The calculations are
--				    based on whether the tax should be
--				    calculated inclusively or exclusively.
--	                            It returns via IN/OUT parameters whether
--				    variance exists.
-- Parameters
-- p_calc_inclusive:    Whether calculation should be inclusive ('Y') or
--		        exclusive ('N')
-- p_invoice_id:        Invoice Id
-- p_tax_tolerance:     Tax tolerance defined.
-- p_tax_tol_amt_range: Tax tolerance amount range defined.
-- p_inv_currency_code: Invoice Currency Code
-- p_tax_rounding_rule: Rounding rule for tax purposes (nearest/up/down)
-- p_tax_rate:		Tax rate
-- p_dist_sum:		Total distribution sum for the distributions we are
-- 			analyzing i.e. distributions with the vat code being
-- 			analyzed.
-- p_tax_sum:		The inclusive/exclusive tax total for the vat code
--			being analyzed.
-- p_tax_var_exists:    IN/OUT parameter to establish whether a tax variance
--		   	exists.
-- p_out_of_tax_range_exists: IN/OUT parameter to establish whether out NOCOPY of tax
--   			      range variance exists.
--============================================================================
PROCEDURE Check_Header_Lvl_Tax_Incl_Excl(p_calc_inclusive          IN VARCHAR2,
				         p_invoice_id              IN NUMBER,
                                         p_tax_tolerance           IN NUMBER,
         			         p_tax_tol_amt_range       IN NUMBER,
                                         p_inv_currency_code       IN VARCHAR2,
			                 p_tax_rounding_rule       IN VARCHAR2,
                                         p_tax_rate                IN NUMBER,
			                 p_dist_sum                IN NUMBER,
                                         p_tax_sum                 IN NUMBER,
                                         p_tax_var_exists          IN OUT NOCOPY VARCHAR2,
                                         p_out_of_tax_range_exists IN OUT NOCOPY VARCHAR2,
			                 p_calling_sequence	     IN VARCHAR2)IS
BEGIN
NULL;
END  Check_Header_Lvl_Tax_Incl_Excl;


--============================================================================
-- CHECK_LINE_LEVEL_TAX_INCL_EXCL:  Procedure that performs tax checks on an
--                 		    invoice for those distribution lines where
-- 				    the tax was calculated at line level.
--                                  The calculation depends on whether the tax
--                                  should be calculated inclusively or
-- 				    exclusively.
--                                  It returns via IN/OUT parameters whether
--                                  variance exists
-- Parameters:
-- p_calc_inclusive:    Whether calculation should be inclusive ('Y') or
--		        exclusive ('N')
-- p_invoice_id:        Invoice Id
-- p_tax_tolerance:     Tax tolerance defined.
-- p_tax_tol_amt_range: Tax tolerance amount range defined.
-- p_inv_currency_code: Invoice Currency Code
-- p_tax_rounding_rule: Rounding rule for tax purposes (nearest/up/down)
-- p_tax_code_id:       Tax Code Id
-- p_tax_rate:		Tax rate
-- p_dist_sum:		Total distribution sum for the distributions we are
-- 			analyzing i.e. distributions with the vat code being
-- 			analyzed, all either inclusive or exclusive.
-- p_tax_sum:		The inclusive/exclusive tax total for the vat code
--			being analyzed.
-- p_tax_var_exists:    IN/OUT parameter to establish whether a tax variance
--		   	exists.
-- p_out_of_tax_range_exists: IN/OUT parameter to establish whether out NOCOPY of tax
--   			      range variance exists.
--============================================================================
PROCEDURE Check_Line_Level_Tax_Incl_Excl(p_calc_inclusive          IN VARCHAR2,
					 p_invoice_id              IN NUMBER,
                            	         p_tax_tolerance           IN NUMBER,
               			         p_tax_tol_amt_range       IN NUMBER,
                                         p_inv_currency_code       IN VARCHAR2,
			                 p_tax_rounding_rule       IN VARCHAR2,
					 p_tax_code_id             IN NUMBER,
                                         p_tax_rate                IN NUMBER,
					 p_dist_sum 		   IN NUMBER,
                                         p_tax_sum                 IN NUMBER,
                                         p_tax_var_exists          IN OUT NOCOPY VARCHAR2,
                                         p_out_of_tax_range_exists IN OUT NOCOPY VARCHAR2,
			                 p_calling_sequence	   IN VARCHAR2)IS
BEGIN
NULL;
END  Check_Line_Level_Tax_Incl_Excl;


--============================================================================
-- GET_TAX_SUM:  Procedure that retrieves the tax_sum of a invoice, i.e. the
--		 sum of all invoice tax_lines.
--============================================================================
PROCEDURE Get_Tax_Sum(p_invoice_id		IN NUMBER,
		      p_tax_code_id		IN NUMBER,
		      p_tax_sum			IN OUT NOCOPY NUMBER,
                      p_amt_includes_tax_flag   IN VARCHAR2,
		      p_calling_sequence	IN VARCHAR2) IS
BEGIN
NULL;
END  Get_Tax_Sum;


--============================================================================
-- GET_DIST_SUM:  Retrieves the sum of the distribution lines that are NON
--		  TAX lines but have a tax code.
--============================================================================
PROCEDURE Get_Dist_Sum(p_invoice_id		IN NUMBER,
		       p_tax_code_id		IN NUMBER,
		       p_dist_sum		IN OUT NOCOPY NUMBER,
                       p_amt_includes_tax_flag  IN VARCHAR2,
		       p_calling_sequence	IN VARCHAR2) IS
BEGIN
NULL;
END  Get_Dist_Sum;


--============================================================================
-- GET_TOTAL_SUM:  Procedure that returns the sum of invoice distribution
--		   lines that are NON-TAX lines.
--============================================================================
PROCEDURE Get_Total_Sum(p_invoice_id		IN NUMBER,
			p_total_sum		IN OUT NOCOPY NUMBER,
			p_calling_sequence	IN VARCHAR2) IS
BEGIN
NULL;
END Get_Total_Sum;


--============================================================================
-- GET_INV_MATCHED_STATUS:  Function given an invoice_id returns True if
--			    the invoice has any matched distribution lines,
-- False otherwise
--============================================================================
FUNCTION Get_Inv_Matched_Status(p_invoice_id		IN NUMBER,
			        p_calling_sequence	IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
NULL;
END  Get_Inv_Matched_Status;

--============================================================================
-- MANUAL_WITHHOLD_TAX:  Procedure that update payment schedules
--		                 to reflect the manual withholding amount
--============================================================================
PROCEDURE Manual_Withhold_Tax(p_invoice_id			IN NUMBER,
			p_last_updated_by		IN NUMBER,
			p_last_update_login		IN NUMBER,
			p_calling_sequence		IN VARCHAR2) IS
BEGIN
NULL;
END  Manual_Withhold_Tax;

--============================================================================
-- WITHHOLD_TAX_ON:  Procedure that calls the withholding tax package on an
--		     invoice and checks for any errors.  Depending on whether
-- an error exists or not, a hold gets placed or released.
--
-- Parameters:
--
-- p_invoice_id:  Invoice Id
--
-- p_gl_date_from_receipt: GL Date From Receipt Flag system option
--
-- p_last_updated_by:  Column Who Info
--
-- p_last_update_login:  Column Who Info
--
-- p_program_application_id:  Column Who Info
--
-- p_program_id:  Column Who Info
--
-- p_request_id:  Column Who Info
--
-- p_system_user:  Approval Program User Id
--
-- p_holds:  Hold Array
--
-- p_holds_count:  Holds Count Array
--
-- p_release_count:  Release Count Array
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--
-- Program Flow:
-- -------------
--
-- Check if okay to call Withholding Routine
--  invoice has at lease on distribution with a withholding tax group
--  invoice has not already been withheld by the system
--  invoice has no user non-releaseable holds (ther than AWT ERROR)
--  invoice has no manual withholding lines
-- IF okay then call AP_DO_WITHHOLDING package on the invoice
-- Depending on whether withholding is successful or not, place or
--  or release the 'AWT ERROR' with the new error reason.
--  (If the invoice already has the hold we want to release the old one and
--   replace the hold with the new error reason)
--============================================================================
PROCEDURE Withhold_Tax_On(p_invoice_id			IN NUMBER,
 			  p_gl_date_from_receipt	IN VARCHAR2,
			  p_last_updated_by		IN NUMBER,
			  p_last_update_login		IN NUMBER,
			  p_program_application_id	IN NUMBER,
			  p_program_id			IN NUMBER,
			  p_request_id			IN NUMBER,
			  p_system_user			IN NUMBER,
		   	  p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			  p_holds_count			IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			  p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			  p_calling_sequence		IN VARCHAR2) IS
BEGIN
NULL;
END  Withhold_Tax_On;


--============================================================================
-- UPDATE_INV_DISTS_TO_APPROVED:  Procedure that updates the invoice
--			          distribution match_status_flag to 'A'
-- if encumbered or has no postable holds or is a reversal line, otherwise
-- if the invoice has postable holds then the match_status_flag remains a
-- 'T'.
--============================================================================
PROCEDURE Update_Inv_Dists_To_Approved(p_invoice_id	  IN NUMBER,
			     	       p_user_id          IN NUMBER,
			     	       p_calling_sequence IN VARCHAR2) IS
BEGIN
NULL;
END  Update_Inv_Dists_To_Approved;

--============================================================================
-- HOLD Processing Routines
--============================================================================

--============================================================================
-- PROCESS_INV_HOLD_STATUS:  Procedure that process and invoice hold status.
--			     Determines whether to place or release a given
-- hold.
--
-- Parameters:
--
-- p_invoice_id:  Invoice Id
--
-- p_line_location_id:  Line Location Id
--
-- p_hold_lookup_code:  Hold Lookup Code
--
-- p_should_have_hold:  ('Y' or 'N') to indicate whether the invoice should
--			have the hold (previous parameter)
--
-- p_hold_reason:  AWT ERROR parameter.  The only hold whose hold reason is
--		   not static.
--
-- p_system_user:  Approval Program User Id
--
-- p_holds:  Holds Array
--
-- p_holds_count:  Holds Count Array
--
-- p_release_count:  Release Count Array
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--
-- Procedure Flow:
-- ---------------
--
-- Retrieve current hold_status for current hold
-- IF already_on_hold
--   IF shoould_not_have_hold OR if p_hold_reason is different from the
--     exists hold reason
--     Release the hold
-- ELSIF should_have_hold and hold_status <> Released By User
--   IF p_hold_reason is null or existing_hold_reason id different from
--    p_hold_reason
--     Place the hold on the invoice
--============================================================================
PROCEDURE Process_Inv_Hold_Status(p_invoice_id 		IN NUMBER,
				  p_line_location_id	IN NUMBER,
				  p_rcv_transaction_id  IN NUMBER,
				  p_hold_lookup_code	IN VARCHAR2,
				  p_should_have_hold	IN VARCHAR2,
				  p_hold_reason		IN VARCHAR2,
				  p_system_user		IN NUMBER,
				  p_holds		IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
				  p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
				  p_release_count	IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
				  p_calling_sequence	IN VARCHAR2)IS
BEGIN
NULL;
END  Process_Inv_Hold_Status;


--============================================================================
-- GET_HOLD_STATUS:  Prcedure to return the hold information and status
--		     of an invoice, whether it is ALREADY ON HOLD,
-- RELEASED BY USER or NOT ON HOLD.
--============================================================================
PROCEDURE Get_Hold_Status(p_invoice_id		IN NUMBER,
			  p_line_location_id	IN NUMBER,
			  p_rcv_transaction_id  IN NUMBER,
			  p_hold_lookup_code	IN VARCHAR2,
			  p_system_user		IN NUMBER,
			  p_status		IN OUT NOCOPY VARCHAR2,
			  p_return_hold_reason  IN OUT NOCOPY VARCHAR2,
			  p_user_id     	IN OUT NOCOPY VARCHAR2,
			  p_resp_id		IN OUT NOCOPY VARCHAR2,
			  p_calling_sequence  	IN VARCHAR2) IS
BEGIN
NULL;
END  Get_Hold_Status;

--============================================================================
-- RELEASE_HOLD:  Procedure to release a hold from an invoice and update the
--		  the release count array.
--============================================================================
PROCEDURE Release_Hold(p_invoice_id		IN NUMBER,
		       p_line_location_id	IN NUMBER,
		       p_rcv_transaction_id	IN NUMBER,
		       p_hold_lookup_code	IN VARCHAR2,
		       p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
		       p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		       p_calling_sequence	IN VARCHAR2) IS
BEGIN
NULL;
END  Release_Hold;


--============================================================================
-- SET_HOLD:  Procedure to Set an Invoice on Hold and update the hold count
--	      array.
--============================================================================
PROCEDURE Set_Hold(p_invoice_id			IN NUMBER,
		   p_line_location_id		IN NUMBER,
		   p_rcv_transaction_id		IN NUMBER,
		   p_hold_lookup_code		IN VARCHAR2,
		   p_hold_reason		IN VARCHAR2,
		   p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
		   p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   p_calling_sequence		IN VARCHAR2) IS
BEGIN
NULL;
END  Set_Hold;

--============================================================================
-- COUNT_HOLD:  Procedure given the hold_array and count_array, increments the
--		the count for a given hold.
--============================================================================
PROCEDURE Count_Hold(p_hold_lookup_code		IN VARCHAR2,
		     p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
		     p_count			IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		     p_calling_sequence		IN VARCHAR2) IS
BEGIN
NULL;
END  Count_Hold;

--============================================================================
-- GET_RELEASE_LOOKUP_FOR_HOLD:  Procedure given a hold_lookup_code retunrs
--			         the associated return_lookup_code
--============================================================================
PROCEDURE Get_Release_Lookup_For_Hold(p_hold_lookup_code       IN VARCHAR2,
		   		      p_release_lookup_code    IN OUT NOCOPY VARCHAR2,
				      p_calling_sequence       IN VARCHAR2) IS
BEGIN
NULL;
END  Get_Release_Lookup_For_Hold;


--============================================================================
-- GET_INVOICE_STATUSES:  Procedure given a hold_lookup_code retunrs
--			         the associated return_lookup_code
--============================================================================
PROCEDURE Get_Invoice_Statuses(p_invoice_id       IN NUMBER,
		   	       p_holds_count      IN OUT NOCOPY NUMBER,
			       p_approval_status  IN OUT NOCOPY VARCHAR2,
			       p_calling_sequence IN VARCHAR2) IS
BEGIN
NULL;
END  Get_Invoice_Statuses;

--
--
--
PROCEDURE Verify_Tax_Code(p_invoice_id              IN NUMBER,
                             p_match_on_tax_flag    IN VARCHAR2,
                             p_enforce_tax_on_acct  IN VARCHAR2,
                             p_acct_tax_difference  IN OUT NOCOPY VARCHAR2,
                             p_match_tax_difference IN OUT NOCOPY VARCHAR2,
			     p_system_user	    IN NUMBER,
			     p_holds     	    IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			     p_holds_count          IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		   	     p_release_count	    IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                             p_calling_sequence     IN VARCHAR2) IS
BEGIN
NULL;
END  Verify_Tax_Code;

-- Short-named procedure for logging

PROCEDURE Log(p_msg 	IN VARCHAR2,
	      p_loc	IN VARCHAR2) IS
BEGIN
NULL;
END Log;

END  IGI_APPROVAL_PKG;

/
