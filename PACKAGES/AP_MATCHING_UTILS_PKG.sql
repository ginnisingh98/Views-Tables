--------------------------------------------------------
--  DDL for Package AP_MATCHING_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_MATCHING_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: apmtutls.pls 120.13.12010000.2 2010/09/30 06:47:32 sbonala ship $ */

Procedure Initialize (
		P_invoice_id		IN   NUMBER,
                P_quick_po_id           IN   NUMBER DEFAULT NULL,    -- 5386827
		P_invoice_num		IN OUT NOCOPY  VARCHAR2,
		P_invoice_amount	IN OUT NOCOPY  NUMBER,
		P_invoice_date		IN OUT NOCOPY	DATE,
		P_vendor_id		IN OUT NOCOPY  NUMBER,
		P_vendor_site_id	IN OUT NOCOPY  NUMBER,
		P_vendor_name		IN OUT NOCOPY  VARCHAR2,
		P_vendor_number		IN OUT NOCOPY  VARCHAR2,
		P_vendor_site_code	IN OUT NOCOPY  VARCHAR2,
		P_vat_registration_num  IN OUT NOCOPY  VARCHAR2,
		P_inv_curr_code		IN OUT NOCOPY  VARCHAR2,
		P_inv_type_lookup_code	IN OUT NOCOPY  VARCHAR2,
		P_inv_description	IN OUT NOCOPY  VARCHAR2,
		P_income_tax_region    	IN OUT NOCOPY  VARCHAR2,
	     -- P_ussgl_transaction_code IN OUT NOCOPY VARCHAR2, - Bug 4277744
		P_awt_group_id  	IN OUT NOCOPY  NUMBER,
		P_batch_id		IN OUT NOCOPY  NUMBER,
		P_gl_date		IN OUT NOCOPY  DATE,
                P_po_number             IN OUT NOCOPY  VARCHAR2, --Bug 5386827
		p_vendor_type_lookup_code IN OUT NOCOPY VARCHAR2,
	        P_item_structure_id	IN OUT NOCOPY NUMBER,
                P_payment_terms_id      IN OUT NOCOPY NUMBER,
                P_payment_terms_name    IN OUT NOCOPY VARCHAR2,
                P_period_name           IN OUT NOCOPY VARCHAR2,
                P_minimum_accountable_unit IN OUT NOCOPY NUMBER,
                P_precision             IN OUT NOCOPY NUMBER,
		P_release_amount_net_of_tax IN OUT NOCOPY NUMBER);

Procedure Get_Num_PO_Dists (
		P_line_location_id	IN	NUMBER,
		P_num_po_dists		IN OUT NOCOPY	NUMBER,
		P_po_distribution_id	IN OUT NOCOPY	NUMBER);

Procedure Get_Receipt_Quantities (
		P_rcv_transaction_id	IN	NUMBER,
		P_ordered_qty		IN OUT NOCOPY	NUMBER,
		P_cancelled_qty		IN OUT NOCOPY  NUMBER,
		P_received_qty		IN OUT NOCOPY	NUMBER,
		P_corrected_qty		IN OUT NOCOPY  NUMBER,
		P_delivered_qty		IN OUT NOCOPY	NUMBER,
		P_transaction_qty	IN OUT NOCOPY  NUMBER,
		P_billed_qty		IN OUT NOCOPY	NUMBER,
		P_accepted_qty		IN OUT NOCOPY	NUMBER,
		P_rejected_qty 		IN OUT NOCOPY	NUMBER);

Procedure Get_Recpt_Dist_Qty_Billed (
		P_rcv_transaction_id	IN	NUMBER,
		P_po_distribution_id	IN	NUMBER,
		P_billed_qty		IN OUT NOCOPY	NUMBER);

/*-------------------------------------------------------------------------
This procedure will be called by PO whenever the receipt is adjusted
The input parameters refer to
p_parent_rcv_txn_id   : the original 'RECEIVE' transaction,
p_adjusted_rcv_txn_id : the 'ADJUST' or 'RETURN' transaction
p_adjusted_date       : the transaction_date on ADJUST or RETURN transaction
p_user_id   	      : WHO column information from the form
p_login_id	      : WHO column information from the form
--------------------------------------------------------------------------*/
Procedure Insert_Adjusted_Receipt_IDs (
		p_parent_rcv_txn_id	IN	NUMBER,
		p_adjusted_rcv_txn_id	IN	NUMBER,
		p_adjusted_date		IN	DATE,
		p_user_id		IN 	NUMBER,
		p_login_id		IN	NUMBER);

/*--------------------------------------------------------------------------
This Function  will be used to get any existing correction quantity for a
PO or Receipt Macthed Invoice and will be used new 11ix Correction form
p_invoice_id         : Invoice_id of the Invoice being corrected
p_line_number        : Line Number of the Invoice being corrected
---------------------------------------------------------------------------*/
Function Get_Correction_Quantity (
               p_invoice_id             IN     NUMBER,
               p_line_number            IN     NUMBER)
Return Number;

/*--------------------------------------------------------------------------
This Function  will be used to get any existing unit price correction for a
PO or Receipt Macthed Invoice and will be used new 11ix Correction form
p_invoice_id         : Invoice_id of the Invoice being corrected
p_line_number        : Line Number of the Invoice being corrected
---------------------------------------------------------------------------*/
Function Get_Correction_Unit_Price (
               p_invoice_id             IN     NUMBER,
               p_line_number            IN     NUMBER)
Return Number;

/*--------------------------------------------------------------------------
This Function  will be used to get any existing correction amount for a
PO or Receipt Macthed Invoice and will be used new 11ix Correction form
p_invoice_id         : Invoice_id of the Invoice being corrected
p_line_number        : Line Number of the Invoice being corrected
---------------------------------------------------------------------------*/
Function Get_Correction_Amount (
               p_invoice_id             IN     NUMBER,
               p_line_number            IN     NUMBER)
Return Number;

/*--------------------------------------------------------------------------
This Function  will be used to get any existing correction quantity for a
PO or Receipt Macthed Invoice Dist and will be used new 11ix Correction form
p_invoice_dist_id         : Invoice_distribution_id of the Invoice being corrected
---------------------------------------------------------------------------*/
Function Get_Correction_Quantity_Dist (
               p_invoice_dist_id            IN     NUMBER)
Return Number;

/*This procedure will get number of distributions per invoice_line */
Procedure Get_Num_Line_Dists (
                P_invoice_id            IN      NUMBER,
                P_invoice_line_number   IN      NUMBER,
                P_num_line_dists        IN OUT NOCOPY   NUMBER,
                P_inv_distribution_id   IN OUT NOCOPY   NUMBER);

--This procedure when provided with a invoice lines will call
--the appropriate matching api according to the information
--present on the line.
Procedure Match_Invoice_Line(
                P_Invoice_Id                IN NUMBER,
                P_Invoice_Line_Number       IN NUMBER,
                P_Overbill_Flag             IN VARCHAR2,
                P_Calling_Sequence          IN VARCHAR2);

--This procedure is added amount based matching in 11ix

Procedure Get_Recpt_Dist_Amt_Billed (
                P_rcv_transaction_id    IN      NUMBER,
                P_po_distribution_id    IN      NUMBER,
                P_billed_amt            IN OUT NOCOPY   NUMBER);


/* This function is added for getting the avialable correction amount for a
   invoice distribution for Invoice Line Correction */

Function Get_Avail_Dist_Corr_Amount (
               P_invoice_dist_id IN NUMBER)
Return Number;

/* This function is added for getting the avialable correction amount for a
   invoice line for Invoice Line Correction */

Function Get_Avail_Line_Corr_Amount (
               P_invoice_id    IN NUMBER,
               P_line_number   IN NUMBER)
Return Number;

/* This function is added for getting the avialable correction qty for a
   invoice line for Invoice Line Correction */

Function Get_Avail_Line_Corr_Qty (
               P_invoice_id    IN NUMBER,
               P_line_number   IN NUMBER)
Return Number;

/* This function is added for getting the associated charged for a
   invoice line for Invoice Line Correction */

Function Get_Line_Assoc_Charge (
               P_invoice_id    IN NUMBER,
               P_line_number   IN NUMBER)
Return Number;

/* This function is added for getting the avialable correction amount for a
   invoice for Invoice Line Correction */

Function Get_Avail_Inv_Corr_Amount (
               P_invoice_id    IN NUMBER)
Return Number;


/*This procedure is used to do the upgrade of PO Shipment and its related
distributions, if the shipment was not already upgraded and it is a historical
shipment*/
/*=============================================================================
|  FUNCTION - AP_Upgrade_Po_Shipment
|
|  DESCRIPTION
|     This public  procedure is used to do the upgrade of PO Shipment and
|     its related distributions, if the shipment was not already upgraded
|     and it is a historical shipment.
|
|
|  PARAMETERS
|      P_Invoice_Type_Lookup_Code - Invoice Type
|      P_Event_Class_Code - event class code
|      P_error_code - Error code to be returned
|      P_calling_sequence -  Calling sequence
|
|  MODIFICATION HISTORY
|    DATE          Author         Action
|    28-MAY-2005   SMYADAM        Created
|
*============================================================================*/

Procedure AP_Upgrade_Po_Shipment(P_Po_Line_Location_id 	IN	NUMBER,
				 P_Calling_Sequence     IN	VARCHAR2);


/*API to Automatically recoup Prepayment invoice lines which are matched
 to the same PO Line as the Item Line on the Standard invoice. */

/*=============================================================================
|  FUNCTION - AP_Recoup_Invoice_Line
|
|  DESCRIPTION
|      Public function to Automatically recoup Prepayment invoice lines which
|      are matched to the same PO Line as the Item Line on the Standard invoice.
|
|  PARAMETERS
|      P_Invoice_Id - 	 Id of the STD invoice which is recouping from the
|			 Prepayment Invoice
|      P_Invoice_Line_Number - Line_Number of the ITEM line which is recouping
|			       prepayment invoice
|      P_Amount_To_Recoup - Amount to recoup
|
|
|  MODIFICATION HISTORY
|    DATE          Author         Action
|    28-MAY-2005   SMYADAM        Created
|
*============================================================================*/

Function Ap_Recoup_Invoice_Line(P_Invoice_Id           IN      NUMBER,
                                P_Invoice_Line_Number  IN      NUMBER,
				P_Amount_To_Recoup     IN      NUMBER,
				P_Po_Line_Id           IN      NUMBER,
				P_Vendor_Id            IN      NUMBER,
				P_Vendor_Site_Id       IN      NUMBER,
				P_Accounting_Date      IN      DATE,
			        P_Period_Name          IN      VARCHAR2,
			        P_User_Id              IN      NUMBER,
			        P_Last_Update_Login    IN      NUMBER,
                                P_Error_Message        OUT NOCOPY VARCHAR2,
			        P_Calling_Sequence     IN      VARCHAR2)
				RETURN BOOLEAN;
/*=============================================================================
|  FUNCTION - Get_Inv_Line_Recouped_Amount
|
|  DESCRIPTION
|      Public function to get the total amount recouped by the ITEM line on the
|	standard invoice.
|
|  PARAMETERS
|      P_Invoice_Id - Invoice id of the invoice which has recouped.
|      P_Invoice_Line_Numbe - Line Number of the ITEM line which has recouped
|			      automatically from 1 or more prepayment invoices/lines
|
|
|  MODIFICATION HISTORY
|    DATE          Author         Action
|    28-MAY-2005   SMYADAM        Created
|
*============================================================================*/
FUNCTION Get_Inv_Line_Recouped_Amount(P_Invoice_Id  IN NUMBER,
				      P_Invoice_Line_Number IN NUMBER)
				      RETURN NUMBER;


/*=============================================================================
|  FUNCTION - Get_Recoup_Amt_Per_Prepay_Line
|
|  DESCRIPTION
|      Public function to get the total amount recouped by the ITEM line on the
|	standard invoice for a particular prepayment invoice line.This amount
|       doesn't include the related tax amount applied.
|
|  PARAMETERS
|      P_Invoice_Id - Invoice id of the invoice which has recouped.
|      P_Invoice_Line_Number - Line Number of the ITEM line which has recouped
|			      automatically from 1 or more prepayment invoices/lines
|      P_Prepay_Invoice_Id - Invoice_Id of the prepayment invoice.
|      P_Prepay_Line_Number - Prepayment invoice line number.
|
|  MODIFICATION HISTORY
|    DATE          Author         Action
|    28-MAY-2005   SMYADAM        Created
|
*============================================================================*/
FUNCTION Get_Recoup_Amt_Per_Prepay_Line(P_Invoice_Id 		IN NUMBER,
					 P_Invoice_Line_Number  IN NUMBER,
					 P_Prepay_Invoice_Id    IN NUMBER,
					 P_Prepay_Line_Number   IN NUMBER) RETURN NUMBER;


/*=============================================================================
|  FUNCTION - Get_Recoup_Tax_Amt_Per_Ppay_Ln
|
|  DESCRIPTION
|      Public function to get the total TAX amount recouped by the ITEM line on the
|	standard invoice for a particular prepayment invoice line.
|
|  PARAMETERS
|      P_Invoice_Id - Invoice id of the invoice which has recouped.
|      P_Invoice_Line_Number - Line Number of the ITEM line which has recouped
|			      automatically from 1 or more prepayment invoices/lines
|      P_Prepay_Invoice_Id - Invoice_Id of the prepayment invoice.
|      P_Prepay_Line_Number - Prepayment invoice line number.
|
|  MODIFICATION HISTORY
|    DATE          Author         Action
|    28-MAY-2005   SMYADAM        Created
|
*============================================================================*/
FUNCTION Get_Recoup_Tax_Amt_Per_Ppay_Ln(P_Invoice_Id 		IN NUMBER,
				          P_Invoice_Line_Number IN NUMBER,
					  P_Prepay_Invoice_Id   IN NUMBER,
					  P_Prepay_Line_Number  IN NUMBER) RETURN NUMBER;


/*=============================================================================
|  FUNCTION - Match_To_Rcv_Shipment_Line
|
|  DESCRIPTION
|      Public api to match a invoice line to a rcv_shipment_line. This api will
|	need the rcv_shipment_line_id along with the other needed matching details
|       to be populated on the invoice line. The api will prorate the quantity/amount
|	to be matched to the first available delivery rcv transactions of this
|	rcv_shipment_line, and any remaining quantity/amount will be prorated to all
|	rcv_transactions based on the ordered_billed quantity/amount. This wrapper
|	calls the original receipt matching apis in a loop for each of the
|       rcv transaction.
|
|  PARAMETERS
|      P_Invoice_Id - Invoice id of the invoice which need to be matched.
|      P_Invoice_Line_Number - Line Number of the ITEM line which needs to
|			      matched to the rcv shipment line.
|
|  MODIFICATION HISTORY
|    DATE          Author         Action
|    27-JUL-2005   SMYADAM        Created
|
*============================================================================*/

PROCEDURE Match_To_Rcv_Shipment_Line (P_Invoice_Id          IN NUMBER,
				      P_Invoice_Line_Number IN NUMBER,
				      P_Calling_Sequence    IN VARCHAR2);


--Bug 5524881  ISP Receipt Matching
/*=============================================================================
|  FUNCTION - Get_rcv_ship_qty_amt
|
|  DESCRIPTION
|    This API is used by the SupplierPortal in the PO Search Page to display
|    the quantity_recieved, quantity_billed, amount_recieved, amount_billed
|    etc for a Reciept Shipment Line
|  PARAMETERS
|      p_rcv_shipment_line_id    Receipt Shipment Line Id,
|      p_matching_basis          Qnantity or Amount
|      p_returned_item           This parameter can take six different values
|                                and the function returns value associated with
|                                this parameter  for a Receipt Ship Line.
|
|  MODIFICATION HISTORY
|    DATE          Author         Action
|    09/27/06    dgulraja        Created
|
*============================================================================*/
FUNCTION Get_rcv_ship_qty_amt(p_rcv_shipment_line_id    IN NUMBER,
                              p_matching_basis          IN VARCHAR2,
                              p_returned_item           IN VARCHAR2)
RETURN NUMBER;

--Introduced for bug#10062826
Procedure Get_Num_Rect_Dists (
		P_rcv_transaction_id	IN	NUMBER,
		P_num_rect_po_dists	OUT	NOCOPY NUMBER);


END AP_MATCHING_UTILS_PKG;


/
