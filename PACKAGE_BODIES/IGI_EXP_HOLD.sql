--------------------------------------------------------
--  DDL for Package Body IGI_EXP_HOLD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_HOLD" AS
--  $Header: igiexpmb.pls 115.7 2003/08/09 11:46:22 rgopalan ship $

PROCEDURE Process_Inv_Hold_Status(p_invoice_id          IN NUMBER,
			          p_line_location_id	IN NUMBER,
				  p_rcv_transaction_id  IN NUMBER,
				  p_hold_lookup_code	IN VARCHAR2,
				  p_should_have_hold	IN VARCHAR2,
				  p_hold_reason         IN VARCHAR2,
				  p_system_user	        IN NUMBER,
				  p_holds               IN OUT NOCOPY HOLDSARRAY,
				  p_holds_count	        IN OUT NOCOPY COUNTARRAY,
				  p_release_count       IN OUT NOCOPY COUNTARRAY,
				  p_calling_sequence	IN VARCHAR2);

PROCEDURE Update_Inv_Dists_To_Approved(p_invoice_id	  IN NUMBER,
			               p_user_id          IN NUMBER,
     			               p_calling_sequence IN VARCHAR2);

PROCEDURE Get_Hold_Status(p_invoice_id	        IN NUMBER,
			  p_line_location_id	IN NUMBER,
			  p_rcv_transaction_id  IN NUMBER,
			  p_hold_lookup_code	IN VARCHAR2,
			  p_system_user	        IN NUMBER,
			  p_status	        IN OUT NOCOPY VARCHAR2,
			  p_return_hold_reason  IN OUT NOCOPY VARCHAR2,
			  p_user_id             IN OUT NOCOPY VARCHAR2,
			  p_resp_id	        IN OUT NOCOPY VARCHAR2,
			  p_calling_sequence  	IN VARCHAR2) ;

PROCEDURE Release_Hold(p_invoice_id		IN NUMBER,
		       p_line_location_id	IN NUMBER,
		       p_rcv_transaction_id	IN NUMBER,
		       p_hold_lookup_code	IN VARCHAR2,
		       p_holds			IN OUT NOCOPY HOLDSARRAY,
		       p_release_count		IN OUT NOCOPY COUNTARRAY,
		       p_calling_sequence	IN VARCHAR2) ;

PROCEDURE Set_Hold(p_invoice_id		IN NUMBER,
                   p_line_location_id	IN NUMBER,
		   p_rcv_transaction_id	IN NUMBER,
		   p_hold_lookup_code	IN VARCHAR2,
		   p_hold_reason	IN VARCHAR2,
		   p_holds	        IN OUT NOCOPY HOLDSARRAY,
		   p_holds_count	IN OUT NOCOPY COUNTARRAY,
		   p_calling_sequence	IN VARCHAR2);

PROCEDURE Get_Release_Lookup_For_Hold(p_hold_lookup_code    IN VARCHAR2,
		   		      p_release_lookup_code IN OUT NOCOPY VARCHAR2,
				      p_calling_sequence    IN VARCHAR2);

--
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
				  p_holds		IN OUT NOCOPY HOLDSARRAY,
				  p_holds_count		IN OUT NOCOPY COUNTARRAY,
				  p_release_count	IN OUT NOCOPY COUNTARRAY,
				  p_calling_sequence	IN VARCHAR2)IS
BEGIN
NULL;
END Process_Inv_Hold_Status;


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
END Get_Hold_Status;

--============================================================================
-- RELEASE_HOLD:  Procedure to release a hold from an invoice and update the
--                the release count array.
--============================================================================
PROCEDURE Release_Hold(p_invoice_id             IN NUMBER,
                       p_line_location_id       IN NUMBER,
                       p_rcv_transaction_id     IN NUMBER,
                       p_hold_lookup_code       IN VARCHAR2,
                       p_holds                  IN OUT NOCOPY HOLDSARRAY,
                       p_release_count          IN OUT NOCOPY COUNTARRAY,
                       p_calling_sequence       IN VARCHAR2) IS
BEGIN
NULL;
END Release_Hold;

--============================================================================
-- SET_HOLD:  Procedure to Set an Invoice on Hold and update the hold count
--            array.
--============================================================================

PROCEDURE Set_Hold(p_invoice_id                 IN NUMBER,
                   p_line_location_id           IN NUMBER,
                   p_rcv_transaction_id         IN NUMBER,
                   p_hold_lookup_code           IN VARCHAR2,
                   p_hold_reason                IN VARCHAR2,
                   p_holds                      IN OUT NOCOPY HOLDSARRAY,
                   p_holds_count                IN OUT NOCOPY COUNTARRAY,
                   p_calling_sequence           IN VARCHAR2) IS
BEGIN
NULL;
END Set_Hold;

--============================================================================
-- GET_RELEASE_LOOKUP_FOR_HOLD:  Procedure given a hold_lookup_code retunrs
--                               the associated return_lookup_code
--============================================================================
PROCEDURE Get_Release_Lookup_For_Hold(p_hold_lookup_code       IN VARCHAR2,
                                      p_release_lookup_code    IN OUT NOCOPY VARCHAR2,
                                      p_calling_sequence       IN VARCHAR2) IS
BEGIN
NULL;
END Get_Release_Lookup_For_Hold;


 FUNCTION get_approval_status(l_invoice_id               IN NUMBER,
 		              l_invoice_amount           IN NUMBER,
		              l_payment_status_flag      IN VARCHAR2,
		              l_invoice_type_lookup_code IN VARCHAR2,
		              l_calling_sequence         IN VARCHAR2) RETURN VARCHAR2 ;

     -----------------------------------------------------------------------
     -- Function get_approval_status returns the invoice approval status
     -- lookup code.
     --
     -- Invoices:
     --                 'APPROVED'
     --                 'NEEDS REAPPROVAL'
     --                 'NEVER APPROVED'
     --                 'CANCELLED'
     --
     -- Prepayments:
     --                 'AVAILABLE'
     --                 'CANCELLED'
     --                 'FULL'
     --                 'UNAPPROVED'
     --                 'UNPAID'
     FUNCTION get_approval_status(l_invoice_id IN NUMBER,
                                  l_invoice_amount IN NUMBER,
                                  l_payment_status_flag IN VARCHAR2,
                                  l_invoice_type_lookup_code IN VARCHAR2,
		                  l_calling_sequence         IN VARCHAR2)
         RETURN VARCHAR2
     IS
     BEGIN NULL;
     END get_approval_status;


--============================================================================
-- UPDATE_INV_DISTS_TO_APPROVED:  Procedure that updates the invoice
--                                distribution match_status_flag to 'A'
-- if encumbered or has no postable holds or is a reversal line, otherwise
-- if the invoice has postable holds then the match_status_flag remains a
-- 'T'.
--============================================================================
PROCEDURE Update_Inv_Dists_To_Approved(p_invoice_id       IN NUMBER,
                                       p_user_id          IN NUMBER,
                                       p_calling_sequence IN VARCHAR2) IS
     BEGIN NULL;
     END Update_Inv_Dists_To_Approved;


--============================================================================
-- FUNCTION:
--        Determine if the source of the invoice excludes it from EXP.
--
--============================================================================

FUNCTION invoice_not_excluded( p_invoice_id       NUMBER
                             , p_source           VARCHAR2
                             , p_calling_sequence VARCHAR2) RETURN BOOLEAN
IS
     BEGIN NULL;
     END invoice_not_excluded ;

--============================================================================
-- PLACE_EXP_HOLD:
--              Procedure that places an Exchange Protocol Hold if there
--              are no other holds placed by the approval process.
--
--============================================================================

 PROCEDURE place_hold( p_invoice_id       IN NUMBER
                     , p_source           IN VARCHAR2
                     , p_cancelled_date   IN DATE
                     , p_calling_sequence IN VARCHAR2 )
 IS
     BEGIN NULL;
     END place_hold;

END igi_exp_hold ;

/
