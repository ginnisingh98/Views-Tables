--------------------------------------------------------
--  DDL for Package Body FV_AP_PREPAY_PKG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_AP_PREPAY_PKG_PVT" AS
/* $Header: FVAPPFRB.pls 120.3 2005/12/29 22:26:28 dsadhukh noship $ */




--==========================================================================
---------------------------------------------------------------------------
-- Procedure Definitions
---------------------------------------------------------------------------
--==========================================================================


--=========================================================================
-- ENCUMBRANCE_ENABLED:  is a function that returns boolean. True if
--                       encumbrance is enabled, false otherwise.
--=========================================================================

FUNCTION Encumbrance_Enabled RETURN BOOLEAN IS
  BEGIN
    RETURN(TRUE);
END Encumbrance_Enabled;



--=========================================================================
-- SETUP_GL_FUNDSCHK_PARAMS:  Procedure that sets up parameters needed by
--                            gl_fundschecker, such as retrieving the
-- packet_id, setting the appropriate mode and partial_reservation_flag
-- depending on whether it is for fundschecking or approval's funds
-- reservation.
--
-- Parameters:
--
--  p_packet_id:  Packet_id variable to be populated by this procedure
--
--  p_mode:  GL Fundschecking mode to be populated by this procedure
--           ('C' if for fundscheking, 'R' for approval's funds reservation)
--
--  p_partial_reserv_flag:  GL Fundschecking partial reservation flag
--                          to be populated by this procedure.
--                          ('Y' for fundschecking, 'N' for approval's funds
--                          reservation.)
--
--  p_called_by:  Which Program this api is called by ('APPRVOAL'
--                or 'FUNDSCHKER')
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--=========================================================================

PROCEDURE SetUp_GL_FundsChk_Params(p_packet_id   	 IN OUT NOCOPY NUMBER,
	          		   p_mode        	 IN OUT NOCOPY VARCHAR2,
				   p_partial_resv_flag   IN OUT NOCOPY VARCHAR2,
				   p_called_by 	 	 IN VARCHAR2,
		   		   p_calling_sequence 	 IN VARCHAR2) IS
  BEGIN

 null;
END SetUp_GL_FundsChk_Params;



--=========================================================================
-- GET_GL_FUNDSCHK_PACKET_ID:  Prcedure to retrieve the next packet_id to
--                             be used for inserting records into
-- gl_bc_packets and for calling gl_fundschecker api.
--
-- Parameters;
--
--   p_packet_id:   Packet_Id variable to be populated by this procedure
--
--=========================================================================

PROCEDURE Get_GL_FundsChk_Packet_Id(p_packet_id   	 IN OUT NOCOPY NUMBER) IS
BEGIN
  null;
END Get_GL_FundsChk_Packet_ID;



--============================================================================
-- FUNDS_CHECK:  Procedure to perform fundschecking on a whole invoice if
--		 p_dist_line_num is null or a particular invoice distribution
-- line if p_dist_line_num is provided.
--
-- Parameters:
--
-- p_invoice_id:  Invoice_Id to perform funds_checking on
--
-- p_dist_line_num:  Invoice Distribution Line Number if populated, tells
--		     the api to fundscheck a particular invoice distribution
--		     instead of all the distribution lines of the invoice
--
-- p_return_message_name:  Message returned to the calling module of status of
--                         of invoice
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--============================================================================

PROCEDURE Funds_Check(p_invoice_id		IN NUMBER,
		      p_dist_line_num		IN NUMBER,
		      p_return_message_name 	IN OUT NOCOPY VARCHAR2,
                      p_calling_sequence 	IN VARCHAR2) IS

BEGIN
 null;
END Funds_Check;


--============================================================================
-- FUNDS_RESERVE:  Procedure to performs funds reservations.
--
-- Parameters:
--
-- p_invoice_id:  Invoice Id
--
-- p_unique_packet_id_per:  ('INVOICE' or 'DISTRIBUTION')
--
-- p_set_of_books_id:  Set of books Id
--
-- p_base_currency_code:  Base Currency Code
--
-- p_inv_enc_type_id:  Financials Invoice Encumbrance Type Id
--
-- p_purch_enc_type_id:  Financials Purchasing Encumbrance Type Id
--
-- p_conc_flag: ('Y' or 'N') indicating if procedure is to be called as a
--		 concurrent program or userexit.
--
-- p_system_user:  Approval Program User Id
--
-- p_ussgl_option:
--
-- p_holds:  Holds Array
--
-- p_hold_count:  Holds Count Array
--
-- p_release_count:  Release Count Array
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--============================================================================

PROCEDURE Funds_Reserve(p_invoice_id		IN NUMBER,
		        p_unique_packet_id_per	IN VARCHAR2,
  			p_set_of_books_id	IN NUMBER,
		   	p_base_currency_code	IN VARCHAR2,
		   	p_inv_enc_type_id	IN NUMBER,
		   	p_purch_enc_type_id	IN NUMBER,
			p_conc_flag	  	IN VARCHAR2,
			p_system_user		IN NUMBER,
			p_ussgl_option		IN VARCHAR2,
			p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
			p_hold_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
			p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
                        p_calling_sequence 	IN VARCHAR2) IS



BEGIN

 null;
END Funds_Reserve;

--============================================================================
-- CLEAR_PACKET_ID_FROM_INVDISTS:  Procedure that clears the packet_id from
--				   the distributions with the given invoice_id
-- and given packet_id.
--============================================================================

PROCEDURE Clear_Packet_Id_From_InvDists(p_invoice_id 	IN NUMBER,
				        p_packet_id 	IN NUMBER,
				        p_calling_sequence IN VARCHAR2) IS
 BEGIN
  null;
END Clear_Packet_Id_From_InvDists;


--============================================================================
-- FUNDSCHECK_INIT:  Procedure to retrieve system parameters to be used in
--                   fundschecker.
--
-- Parameters:
--
--  p_chart_of_accounts_id:  Variable for the procedure to populate with the
--                           chart of accounts id
--
--  p_set_of_books_id:  Variable for the procedure to populate with the
--			set of books id
--
--  p_auto_offsets_flag:  Variable for the procedure to populate with the
--			  automatic offsets flag.
--
--  p_flex_method:  Variable for the procedure to populate with the
--		    flexbuild method
--
--  p_xrate_gain_ccid:  Variable for the procedure to populate with the
--			exchange rate variance gain ccid
--
--  p_xrate_loss_ccid:  Variable for the procedure to populate with the
--			exchange rate variance loss ccid
--
--  p_base_currency_code:  Variable for the procedure to populate with the
--			   base currency code
--
--  p_inv_enc_type_id:  Variable for the procedure to populate with the
--			invoice encumbrance type id
--
--  p_gl_user_id:  Variable for the procedure to populate with the
--		   profile option user_id to be used for the gl_fundschecker
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--============================================================================

PROCEDURE FundsCheck_Init(p_chart_of_accounts_id IN OUT NOCOPY NUMBER,
			  p_set_of_books_id   	IN OUT NOCOPY NUMBER,
			  p_auto_offsets_flag 	IN OUT NOCOPY VARCHAR2,
			  p_flex_method 	IN OUT NOCOPY VARCHAR2,
			  p_xrate_gain_ccid 	IN OUT NOCOPY NUMBER,
			  p_xrate_loss_ccid 	IN OUT NOCOPY NUMBER,
			  p_base_currency_code 	IN OUT NOCOPY VARCHAR2,
			  p_inv_enc_type_id 	IN OUT NOCOPY NUMBER,
			  p_gl_user_id     	IN OUT NOCOPY NUMBER,
                          p_calling_sequence 	IN VARCHAR2) IS
BEGIN
   null;
END FundsCheck_Init;


--============================================================================
-- SETUP_FLEXBUILD_PARAMS:  Procedure to setup the flexbuild parameters
--			    needed to flexbuild either or both exchange
-- rate gain/loss account ccids.  It returns the qualifier name, segment
-- delimiter, segment number, number of segments, system level exchange
-- rate variance account segments and some flags and message if flexbuilding
-- cannot happen for exchange rate accounts.
--
-- Parameters:
--
--  p_chart_of_accounts_id:  Chart of accounts id
--
--  p_flex_method: System Level Flexbuild method
--
--  p_flex_xrate_flag:  BOOLEAN, whether to flexbuild the exchange rate
--			variance account (TRUE for flexbuild, FALSE otherwise).
--
--  p_xrate_gain_ccid:  System level exchange rate variance gain ccid.
--			Only needed if p_flex_xrate_flag = TRUE
--
--  p_xrate_loss_ccid:  System level excahgne rate variance loss ccid
--			Only needed if p_flex_xrate_flag = TRUE
--
--  p_flex_qualifier_name:  Variable to be populated with the flexbuild
--			    qualifier name by the procedure for flexbuilding
--
--  p_flex_segment_delimiter:  Variable to be populated with the flexbuild
--			       segment delimiter by the procedure for
--			       flexbuilding
--
--  p_flex_segment_number:  Variable to be populated with the flexbuild
--			    segment number by the procedure for flexbuilding
--
--  p_num_of_segments:	Variable to be populated with the flexbuild number
--			of segments by the procedure for flexbuilding
--
--  p_xrate_gain_segments:  Variable to contain the exchange rate variance
--			    gain account segments to be populated by the
--			    procedure for flexbuilding
--
--  p_xrate_loss_segments:  Variable to contain the exchange rate variance
--			    loss account segments to be populated by the
--			    procedure for flexbuilding
--
--  p_xrate_cant_flexbuild_flag:  Boolean value to be set by the procedure  if
--				  for some reason the exchange rate variance
--				  account cannot be flexbuilt.
--
--  p_cant_flexbuild_reason:  Variable to contain the reason why the
--			      liability account could not be flexbuilt
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--============================================================================

PROCEDURE SetUp_Flexbuild_Params(p_chart_of_accounts_id IN NUMBER,
				 p_flex_method IN VARCHAR2,
                                 p_flex_xrate_flag IN BOOLEAN,
				 p_xrate_gain_ccid IN NUMBER,
				 p_xrate_loss_ccid IN NUMBER,
				 p_flex_qualifier_name IN OUT NOCOPY VARCHAR2,
				 p_flex_segment_delimiter IN OUT NOCOPY VARCHAR2,
				 p_flex_segment_number IN OUT NOCOPY NUMBER,
                                 p_num_of_segments IN OUT NOCOPY NUMBER,
				 p_xrate_gain_segments IN OUT NOCOPY FND_FLEX_EXT.SEGMENTARRAY,
				 p_xrate_loss_segments IN OUT NOCOPY FND_FLEX_EXT.SEGMENTARRAY,
				 p_xrate_cant_flexbuild_flag IN OUT NOCOPY BOOLEAN,
                                 p_cant_flexbuild_reason IN OUT NOCOPY VARCHAR2,
				 p_calling_sequence IN VARCHAR2) IS
 BEGIN
  null;
END SetUp_Flexbuild_Params;


--============================================================================
-- BC_PACKETS_INSERT:  Procedure that inserts accounting debits or credit
--		       records into gl_bc_packets depending on whether the
-- invoice distribution was a reversal and whether the amount inserted is
-- positive or negative.  Records need to be inserted into gl_bc_packets
-- before gl_fundschecker can be called.
--
-- Parameters:
--
--  p_packet_id:  Packet Id
--
--  p_set_of_books_id:  Set of Books Id
--
--  p_ccid:  Code Combination Id
--
--  p_period_year:  Period Year
--
--  p_period_num:  Period Num
--
--  p_quarter_num:  Quarter Num
--
--  p_gl_user:  User Id
--
--  p_enc_type_id:  Encumbrance Type Id
--
 --  -------------------------------------------------+
 --  | Journal Entry Reference Columns                |
 --  | (Not needed for funds checking)                |
 --  |                                                |
 --  |   Expense Lines:                               |
 --  |     o p_ref1:  Vendor Name                     |
 --  |     o p_ref2:  Invoice ID                      |
 --  |     o p_ref3:  Distribution Line Number        |
 --  |     o p_ref4:  Invoice Number                  |
 --  |     o p_ref5:  Voucher Number                  |
 --  |   Encumbrance Lines and Reversals              |
 --  |     o p_ref1:  Vendor Name                     |
 --  |     o p_ref2:  Invoice ID                      |
 --  |     o p_ref3:  Distribution Line Number        |
 --  |     o p_ref4:  PO Number                       |
 --  |     o p_ref5:  Invoice Number                  |
 --  |   Payment Lines                                |
 --  |     o p_ref1: Vendor Name                      |
 --  |     o p_ref2: Invoice ID                       |
 --  |     o p_ref3: Check ID                         |
 --  |     o p_ref4: Check Number                     |
 --  |     o p_ref5: Invoice Number                   |
 --  +-------------------------------------------------
--
--  p_je_source:  Je Source Name ('Payables')
--
--  p_je_category:  Je Category Nmae ('Purchase Invoices')
--
--  p_actual_flag:  Actual Flag ('E')
--
--  p_period_name:  Period Name
--
--  p_base_currency_code:  Base Currency Code
--
--  p_status_code:  Status Code ('C' for fundschecking, 'P' for approval's
--				 funds reservation)
--
--  p_ussgl_code:  USSGL code profile option (Not needed for fundschecking)
--
--  p_base_amt:  Base Amount
--
--  p_reversal_flag:  Reversal Flag
--
--  p_calling_sequence:  Debugging string to indicate path of module calls to
--			 be printed out NOCOPY upon error.
--============================================================================

PROCEDURE BC_Packets_Insert(p_packet_id		IN NUMBER,
			    p_set_of_books_id	IN NUMBER,
			    p_ccid		IN NUMBER,
			    p_period_year	IN NUMBER,
			    p_period_num	IN NUMBER,
			    p_quarter_num	IN NUMBER,
                       	    p_gl_user		IN NUMBER,
			    p_enc_type_id	IN NUMBER,
                       	    p_ref1		IN VARCHAR2,
			    p_ref2		IN NUMBER,
			    p_ref3		IN NUMBER,
			    p_ref4		IN VARCHAR2,
			    p_ref5		IN VARCHAR2,
                       	    p_je_source		IN VARCHAR2,
			    p_je_category	IN VARCHAR2,
			    p_actual_flag	IN VARCHAR2,
                       	    p_period_name	IN VARCHAR2,
			    p_base_currency_code IN VARCHAR2,
			    p_status_code	IN VARCHAR2,
                       	    p_ussgl_code	IN VARCHAR2,
                       	    p_base_amt		IN NUMBER,
			    p_reversal_flag	IN VARCHAR2,
			    p_calling_sequence 	IN VARCHAR2) IS
BEGIN
 null;
END BC_Packets_Insert;


/**==========================================================================
ENCUMBRANCE_LINES_INSERT : This Procedure inserts lines into ap_encumbrance
lines. The p_conc_flag determines whether to set the extended who columns
if called by a concurrent program
==========================================================================**/

PROCEDURE Encumbrance_Lines_Insert (
			p_invoice_distribution_id	IN	NUMBER,
			p_encum_line_type		IN	VARCHAR2,
			p_accounting_date		IN	DATE,
			p_period_name			IN	VARCHAR2,
			p_encum_type_id			IN	NUMBER,
			p_code_combination_id		IN	NUMBER,
			p_accounted_cr			IN 	NUMBER,
			p_accounted_dr			IN	NUMBER,
			p_reversal_flag			IN	VARCHAR2,
			p_user_id			IN	NUMBER,
			p_conc_flag			IN 	VARCHAR2,
			p_calling_sequence		IN	VARCHAR2) IS

BEGIN
null;
END Encumbrance_Lines_Insert;


--============================================================================
-- CALC_IPV_ERV:  Procedure to calculate invoice price variance, base invoice
--		  price variance, exchange rate variance and to return the
-- the appropriate invoice price variance ccid and exchange rate variance ccid
-- depending on the po distribution destination type.  If the destination
-- type is EXPENSE, both the ipv_ccid and erv_ccid equals the po distribution
-- expense ccid.  If the destination type is INVENDTORY, the ipv_ccid equals
-- the po distribution variance account ccid, while the erv_ccid depends on
-- whether it is a gain or loss to be assigned to the system level exchange
-- rate variance gain/loss ccid and also if automatic offsets is on,
-- to determine if the system gain/loss account gets overlaid with the
-- dist_ccid depending on the flex  method.
--
-- Parameters:
--
--  p_auto_offset_flag:   Boolean to indicated whether automatic offsets is
--			  enabled or not (TRUE for enabled, FALSE otherwise)
--
--  p_xrate_cant_flexbuild_flag:  Boolean to indicate whether the procedure
--				  has problems setting up parameters to
--				  flexbuild the exchange rate variacne account
--
--  p_chart_of_account_id:   Chart of Accounts Id
--
--  p_xrate_gain_segments:  Exchange Rate Variance Gain Account Segments
--
--  p_xrate_loss_segments:  Exchange Rate Variance Loss Account Segments
--
--  p_sys_xrate_gain_ccid:  System level Exchange Rate Variance Gain Ccid
--
--  p_sys_xrate_loss_ccid:  System level Exchange Rate Variance Loss Ccid
--
--  p_dist_ccid:  Invoice Distribution Line Ccid
--
--  p_expense_ccid:  PO Distribution Expense Ccid
--
--  p_variance_ccid:  PO Distribution Variance Ccid
--
--  p_segment_number:  Flexbuild Segment Number
--
--  p_flex_method:  Flexbuild Method
--
--  p_flex_qualifier_name:  Flexbuild Qualifier Name
--
--  p_flex_segment_delimiter:  Flexbuild Segment Delimiter
--
--  p_po_rate:  PO Rate
--
--  p_po_price:  PO Price
--
--  p_inv_rate:  Invoice Rate
--
--  p_inv_price:  Invoice Price
--
--  p_inv_qty:  Invoice Quantity
--
--  p_inv_currency_code:  Invoice Currency Code
--
--  p_base_currency_code:  Base Currency Code
--
--  p_destination_type:  PO Distribution Destination Type
--
--  p_ipv:  Variable to contain the invoice price variance calculated by the
--          procedure.
--
--  p_bipv:  Variable to contain the base invoice price variance calculated
--           by the procedure.
--
--  p_price_var_ccid:  Variable to contain the invoice price variance ccid
--                     that is determined by the po distribution destination
--		       type.
--  p_erv:  Variable to contain the exchange rate variacne calculated by the
--          procedure.
--
--  p_erv_ccid:  Variable to contains the exchange rate variance ccid that
--		 is determined by the po distribution destination type and
--		 if automatic offsets is on or not.
--
--  p_calling_sequence:  Debugging string to indicate path of module calls to
--			 be printed out NOCOPY upon error.
--============================================================================

PROCEDURE Calc_IPV_ERV(p_auto_offsets_flag	IN VARCHAR2,
		       p_xrate_cant_flexbuild_flag IN BOOLEAN,
		       p_chart_of_accounts_id	IN NUMBER,
		       p_xrate_gain_segments    IN FND_FLEX_EXT.SEGMENTARRAY,
		       p_xrate_loss_segments    IN FND_FLEX_EXT.SEGMENTARRAY,
		       p_sys_xrate_gain_ccid    IN NUMBER,
		       p_sys_xrate_loss_ccid    IN NUMBER,
		       p_dist_ccid 		IN NUMBER,
		       p_expense_ccid		IN NUMBER,
		       p_variance_ccid    	IN NUMBER,
		       p_segment_number		IN NUMBER,
		       p_flex_method		IN VARCHAR2,
		       p_flex_qualifier_name	IN VARCHAR2,
		       p_flex_segment_delimiter IN VARCHAR2,
		       p_po_rate		IN NUMBER,
		       p_po_price		IN NUMBER,
		       p_inv_rate		IN NUMBER,
		       p_rtxn_rate		IN NUMBER,
		       p_rtxn_uom		IN VARCHAR2,
		       p_rtxn_item_id		IN NUMBER,
		       p_po_uom			IN VARCHAR2,
		       p_match_option		IN VARCHAR2,
		       p_inv_price		IN NUMBER,
		       p_inv_qty		IN NUMBER,
		       p_dist_amount		IN NUMBER,
		       p_base_dist_amount	IN NUMBER,
		       p_inv_currency_code	IN VARCHAR2,
		       p_base_currency_code	IN VARCHAR2,
		       p_destination_type	IN VARCHAR2,
		       p_ipv   			IN OUT NOCOPY NUMBER,
		       p_bipv  			IN OUT NOCOPY NUMBER,
		       p_price_var_ccid		IN OUT NOCOPY NUMBER,
		       p_erv   			IN OUT NOCOPY NUMBER,
		       p_erv_ccid 		IN OUT NOCOPY NUMBER,
		       p_calling_sequence	IN VARCHAR2) IS
BEGIN
 null;
END Calc_IPV_ERV;


Procedure Calc_Tax_IPV_ERV(p_auto_offsets_flag	IN VARCHAR2,
		       p_xrate_cant_flexbuild_flag IN BOOLEAN,
		       p_chart_of_accounts_id	IN NUMBER,
		       p_xrate_gain_segments    IN FND_FLEX_EXT.SEGMENTARRAY,
		       p_xrate_loss_segments    IN FND_FLEX_EXT.SEGMENTARRAY,
		       p_sys_xrate_gain_ccid    IN NUMBER,
		       p_sys_xrate_loss_ccid    IN NUMBER,
                       p_flex_segment_number    IN NUMBER,
                       p_flex_method            IN VARCHAR2,
                       p_flex_qualifier_name    IN VARCHAR2,
                       p_flex_segment_delimiter IN VARCHAR2,
		       p_tax_dist_id 		IN NUMBER,
		       p_po_dist_id 		IN NUMBER,
		       p_dist_ccid 		IN NUMBER,
		       p_sum_qty_invoiced 	IN NUMBER,
		       p_sum_allocated_amount 	IN NUMBER,
                       p_po_expense_ccid        IN NUMBER,
                       p_price_variance_ccid    IN NUMBER,
                       p_po_price               IN NUMBER,
                       p_rtxn_rate              IN NUMBER,
                       p_rtxn_uom               IN VARCHAR2,
                       p_rtxn_item_id           IN NUMBER,
                       p_po_uom                 IN VARCHAR2,
                       p_match_option           IN VARCHAR2,
                       p_po_rate                IN NUMBER,
                       p_inv_rate               IN NUMBER,
                       p_destination_type       IN VARCHAR2,
                       p_po_tax_rate            IN NUMBER,
                       p_po_recov_rate          IN NUMBER,
                       p_invoice_currency_code  IN VARCHAR2,
                       p_base_currency_code     IN VARCHAR2,
                       p_tax_ipv_ccid           IN OUT NOCOPY NUMBER,
                       p_tax_erv_ccid           IN OUT NOCOPY NUMBER,
                       p_tax_ipv                IN OUT NOCOPY NUMBER,
                       p_tax_bipv               IN OUT NOCOPY NUMBER,
                       p_tax_erv                IN OUT NOCOPY NUMBER,
                       p_calling_sequence       IN VARCHAR2,
		       p_tax_id			IN NUMBER,
		       p_codeorgroup		IN NUMBER,
		       p_vendor_id		IN NUMBER,
		       p_vendor_site_id		IN NUMBER) IS


BEGIN
  null;
END Calc_Tax_IPV_ERV;

--============================================================================
-- CALC_QV:  Procedure to calculate the quantity variance and base quantity
--           variance and also return the invoice distribution line number
-- that the quantity variances should be applied to.
--
-- Parameters:
--
--  p_invoice_id:  Invoice Id
--
--  p_po_dist_id:  Po Distribution Id that the invoice is matched to
--
--  p_inv_currency_code:  Invoice Currency Code
--
--  p_base_currency_code:  Base Currency Code
--
--  p_po_price:   Po Price
--
--  p_po_qty:  Po Quantity
--
--  p_qv:  Variable to contain the quantity variance of the invoice to be
--         calculated by the procedure
--
--  p_bqv:  Variable to contain the base quantity variance of the invoice to
--          be calculated by the procedure
--
--  p_update_line_num:  Variable to contain the distribution line number
--                      of the invoice that the qv should be applied to
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--============================================================================

PROCEDURE Calc_QV(p_invoice_id		IN NUMBER,
		  p_po_dist_id		IN NUMBER,
		  p_inv_currency_code	IN VARCHAR2,
                  p_base_currency_code  IN VARCHAR2,
		  p_po_price		IN NUMBER,
		  p_po_qty		IN NUMBER,
		  p_match_option	IN VARCHAR2,
		  p_rtxn_uom		IN VARCHAR2,
	          p_po_uom		IN VARCHAR2,
		  p_item_id		IN NUMBER,
		  p_qv			IN OUT NOCOPY NUMBER,
		  p_bqv			IN OUT NOCOPY NUMBER,
		  p_update_line_num	IN OUT NOCOPY NUMBER,
		  p_calling_sequence    IN VARCHAR2) IS

BEGIN
  	   null;
END Calc_QV;


--============================================================================
-- PROCESS_FUNDSCHK_FAILURE_CODE:  Procedure to process the gl_fundschecker
--				   failure code.  It updates all the
-- unapproved invoice distributions associated for a invoice if
-- p_dist_line_num is null or a particular invoice distribution line if
-- p_dist_line_num is provided with the given packet_id.  It then retrieves
-- the gl_fundschecker failure result code and determines which message to
-- return to let the user know why fundschecking failed.
--
-- Parameters:
--
--  p_invoice_id:  Invoice Id
--
--  p_dist_line_num:  Dist Line Number (if null, updates the whole invoice
--		      with the packet_id, otherwise only updates this
--		      invoice distribution line)
--
--  p_packet_id:  Packet Id
--
--  p_return_message_name:  Variable to contain the return message name
--			    of why fundschecking failed to be populated by
--			    the procedure.
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--============================================================================

PROCEDURE Process_Fundschk_Failure_Code(p_invoice_id 		IN NUMBER,
			      		p_dist_line_num 	IN NUMBER,
			      		p_packet_id 		IN NUMBER,
			      		p_return_message_name IN OUT NOCOPY VARCHAR2,
			      		p_calling_sequence 	IN VARCHAR2) IS
BEGIN
  null;
END Process_Fundschk_Failure_Code;


--============================================================================
-- UPDATE_INVDISTS_WTH_PACKETID:  Procedure to update all the upapproved dist
--				  in an invoice if p_dist_line_num is null
--				  or a particular invoice distribution line,
--				  if p_dist_line_num is provided.
--
-- Parameters:
--
--  p_invoice_id:  Invoice Id
--
--  p_dist_line_num:  Dist Line Number (if null, updates the whole invoice
--		      with the packet_id, otherwise only updates this
--		      invoice distribution line)
--
--  p_packet_id:  Packet Id
--
--============================================================================

PROCEDURE Update_InvDists_Wth_PacketId(p_invoice_id 	IN NUMBER,
				       p_dist_line_num	IN NUMBER,
				       p_packet_id 	IN NUMBER) IS
BEGIN
   null;
END Update_InvDists_Wth_PacketId;


--============================================================================
-- GET_GL_FUNDSCHK_RESULT_CODE:  Procedure to retrieve the GL_Fundschecker
--				 result code after the GL_Fundschecker has
--				 been run.
--
-- Parameters:
--
--  p_packet_id:  Packet Id
--
--  p_fc_result_code:  Variable to contain the gl_fundschecker result code
--
--============================================================================

PROCEDURE Get_GL_FundsChk_Result_Code(p_packet_id  	IN NUMBER,
				      p_fc_result_code  IN OUT NOCOPY VARCHAR2) IS
BEGIN
 null;
END Get_GL_FundsChk_Result_Code;


--============================================================================
-- UPDATE_INVDIST_WTH_ENCUM_FLAG:  Procedure that sets the encumbrance_flag
--				   to the given encumbrance_flag for the
-- given invoice_id with the given packet_id.
--============================================================================

PROCEDURE Update_InvDist_Wth_Encum_Flag(p_invoice_id	IN NUMBER,
					  p_packet_id	IN NUMBER,
					  p_encum_flag	IN VARCHAR2,
					  p_calling_sequence IN VARCHAR2) IS
  BEGIN

 null;
END Update_InvDist_Wth_Encum_Flag;


--============================================================================
-- PROCESS_FUNDSRESV_FAIL_CODE:  Procedure to process the gl_fundschecker
--				 failure code.  It tretrieves the
-- gl_fundschecker result code and determines whether insufficient funds
-- or cant funds check exists and retunrs those values.
--
-- Parameters:
--
-- p_invoice_id:  Invoice Id
--
-- p_packet_id:  Packet Id
--
-- p_insuff_funds_exists:  Variable to be set if insufficent funds exists.
--
-- p_cant_fundschk_exists:  Variable to be set if insufficent funds exists.
--
-- p_calling_sequence:  Debugging string to indicate path of module calls to be
--                      printed out NOCOPY upon error.
--============================================================================
PROCEDURE Process_FundsResv_Fail_Code(p_invoice_id	    IN NUMBER,
				      p_packet_id	    IN NUMBER,
				      p_insuff_funds_exists IN OUT NOCOPY VARCHAR2,
				      p_cant_fundsck_exists IN OUT NOCOPY VARCHAR2,
				      p_calling_sequence    IN VARCHAR2) IS
  BEGIN

 null;
END Process_FundsResv_Fail_Code;

-- Short-named procedure for logging

PROCEDURE Log(msg 	IN VARCHAR2,
	      loc	IN VARCHAR2) IS
BEGIN

  null;
  --AP_LOGGING_PKG.AP_Log(msg, loc);
END Log;

END FV_AP_PREPAY_PKG_PVT;

/
