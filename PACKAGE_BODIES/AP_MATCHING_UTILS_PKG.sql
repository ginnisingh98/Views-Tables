--------------------------------------------------------
--  DDL for Package Body AP_MATCHING_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_MATCHING_UTILS_PKG" AS
/* $Header: apmtutlb.pls 120.36.12010000.10 2010/09/30 07:00:58 sbonala ship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_MATCHING_UTILS_PKG';
G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_MATCHING_UTILS_PKG.';

Procedure Initialize (
		P_invoice_id		IN   NUMBER,
                P_quick_po_id           IN   NUMBER DEFAULT NULL,     --5386827
		P_invoice_num		IN OUT NOCOPY  VARCHAR2,
		P_invoice_amount	IN OUT NOCOPY  NUMBER,
		P_invoice_date		IN OUT NOCOPY  DATE,
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
                P_po_number             IN OUT NOCOPY VARCHAR2,   -- Bug 5386827
		P_vendor_type_lookup_code IN OUT NOCOPY VARCHAR2,
	 	P_item_structure_id	IN OUT NOCOPY  NUMBER,
                P_payment_terms_id      IN OUT NOCOPY NUMBER,
                P_payment_terms_name    IN OUT NOCOPY  VARCHAR2,
                P_period_name           IN OUT NOCOPY VARCHAR2,
                P_minimum_accountable_unit IN OUT NOCOPY NUMBER,
                P_precision		IN OUT NOCOPY NUMBER,
		P_release_amount_net_of_tax IN OUT NOCOPY NUMBER)
IS
	debug_info 		varchar2(100);
BEGIN
	-- select all the out variables from the view ap_invoices_v

	debug_info := 'select out variables from  ap_invoices_v';
        --bug 5056082 Replacing the view with base tables
        SELECT ai.invoice_num,
               ai.invoice_amount,
               ai.invoice_date,
               ai.vendor_id,
               ai.vendor_site_id,
               HP.PARTY_NAME VENDOR_NAME,
               PV.SEGMENT1 VENDOR_NUMBER,
               PVS.VENDOR_SITE_CODE VENDOR_SITE_CODE,
               ai.invoice_currency_code,
               ai.invoice_type_lookup_code,
               ai.description,
               DECODE(PV.TYPE_1099, '','', DECODE(ASP.COMBINED_FILING_FLAG, 'N', '',
               DECODE(ASP.INCOME_TAX_REGION_FLAG, 'Y', DECODE(PVS.country, 'US',PVS.state, NULL), ASP.INCOME_TAX_REGION))) INCOME_TAX_REGION,
               -- ai.ussgl_transaction_code, - bug 4277744
               ai.awt_group_id,
               ai.batch_id,
               ai.gl_date,
               ai.terms_id,
               AT.NAME TERMS_NAME ,
               AP_INVOICES_PKG.GET_PERIOD_NAME( AI.GL_DATE, NULL, AI.ORG_ID) PERIOD_NAME,
               FC.MINIMUM_ACCOUNTABLE_UNIT,
               FC.PRECISION PRECISION,
               ai.release_amount_net_of_tax
	INTO
		P_invoice_num,
		P_invoice_amount,
		P_invoice_date,
		P_vendor_id,
		P_vendor_site_id,
		P_vendor_name,
		P_vendor_number,
		P_vendor_site_code,
		P_inv_curr_code,
		P_inv_type_lookup_code,
		P_inv_description,
		P_income_tax_region,
	     -- P_ussgl_transaction_code, - Bug 4277744
		P_awt_group_id,
		P_batch_id,
		P_gl_date,
                P_payment_terms_id,
                P_payment_terms_name,
                P_period_name,
                P_minimum_accountable_unit,
  		P_precision,
		P_release_amount_net_of_tax
	FROM
	        ap_invoices_all ai,
                FND_CURRENCIES FC,
                HZ_PARTIES HP,
                ap_suppliers pv,
                ap_supplier_sites_all pvs,
                AP_TERMS AT,
                AP_SYSTEM_PARAMETERS ASP,
                FND_TERRITORIES_TL FND
        WHERE   ai.invoice_id = P_invoice_id
         AND    AI.TERMS_ID = AT.TERM_ID (+)
         AND    AI.VENDOR_SITE_ID = PVS.VENDOR_SITE_ID (+)
         AND    AI.INVOICE_CURRENCY_CODE = FC.CURRENCY_CODE (+)
         AND    AI.ORG_ID = ASP.ORG_ID
         AND    FND.territory_code(+) = AI.taxation_country
         AND    (AI.TAXATION_COUNTRY IS NULL OR FND.LANGUAGE = USERENV('LANG'))
         AND    AI.PARTY_ID = HP.PARTY_ID
         AND    HP.PARTY_ID = PV.PARTY_ID (+);

	-- get vendor_type lookup_code from po_vendors
	SELECT vendor_type_lookup_code ,
	       vat_registration_num
	INTO P_vendor_type_lookup_code,
	     P_vat_registration_num
	FROM po_vendors
	WHERE vendor_id = P_vendor_id;

        -- Bug 5386827 : fetch po_number
        -- select the po_number if the quick_po_id is specified,
        debug_info := 'select the po_number';
        -- Changed this Query for CLM Document Numbering 9503239
        If (P_quick_po_id is NOT NULL) Then
            SELECT po_number
            INTO P_po_number
            FROM po_headers_ap_v
            WHERE po_header_id = P_quick_po_id;
        End if;


  	-- select item_structure id for Item category for the product
	-- Purchasing
	-- Get the structure id for Purchasing
    	SELECT mdsv.structure_id
    	INTO   P_item_structure_id
    	FROM   mtl_default_sets_view mdsv
    	WHERE  mdsv.functional_area_id = 2;

   EXCEPTION
	WHEN OTHERS THEN
	If (SQLCODE <> -20001) Then
	    fnd_message.set_name('SQLAP','AP_DEBUG');
	    fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('DEBUG_INFO',debug_info);
	End if;
	app_exception.raise_exception;

   END Initialize;

   Procedure Get_Num_PO_Dists (
		P_line_location_id	IN	NUMBER,
		P_num_po_dists		IN OUT NOCOPY	NUMBER,
		P_po_distribution_id	IN OUT NOCOPY 	NUMBER) IS

   Begin

	SELECT count(*)
        INTO  p_num_po_dists
	FROM po_distributions
	WHERE line_location_id = P_line_location_id;

	If (p_num_po_dists = 1 ) Then
	    SELECT po_distribution_id
	    INTO   p_po_distribution_id
	    FROM   po_distributions
	    WHERE line_location_id = P_line_location_id;
	Else
	   p_po_distribution_id := null;
	End if;

   End Get_Num_PO_Dists;

   Procedure Get_Receipt_Quantities (
		P_rcv_transaction_id	IN	NUMBER,
		P_ordered_qty		IN OUT NOCOPY	NUMBER,
		P_cancelled_qty		IN OUT NOCOPY	NUMBER,
		P_received_qty		IN OUT NOCOPY	NUMBER,
		P_corrected_qty		IN OUT NOCOPY  NUMBER,
		P_delivered_qty		IN OUT NOCOPY	NUMBER,
		P_transaction_qty	IN OUT NOCOPY  NUMBER,
		P_billed_qty		IN OUT NOCOPY	NUMBER,
		P_accepted_qty		IN OUT NOCOPY	NUMBER,
		P_rejected_qty 		IN OUT NOCOPY	NUMBER) IS

	l_po_ordered_qty		NUMBER;
	l_po_received_qty		NUMBER;
	l_po_corrected_qty		NUMBER;
	l_po_delivered_qty		NUMBER;
	l_po_transaction_qty		NUMBER;
	l_po_billed_qty			NUMBER;
	l_po_accepted_qty		NUMBER;
	l_po_rejected_qty		NUMBER;
	l_po_cancelled_qty		NUMBER;
    Begin

	-- Call the PO function which returns quantities in Po UOM and
	-- Receipt UOM.

	RCV_INVOICE_MATCHING_SV.Get_Quantities (
			P_rcv_transaction_id,
			l_po_ordered_qty,
			l_po_cancelled_qty,
			l_po_received_qty,
			l_po_corrected_qty,
			l_po_delivered_qty,
			l_po_transaction_qty,
			l_po_billed_qty,
			l_po_accepted_qty,
			l_po_rejected_qty,
			P_ordered_qty,
			P_cancelled_qty,
			P_received_qty,
			P_corrected_qty,
			P_delivered_qty,
			P_transaction_qty,
			P_billed_qty,
			P_accepted_qty,
			P_rejected_qty );
    End Get_Receipt_Quantities;

    Procedure Get_Recpt_Dist_Qty_Billed (
		P_rcv_transaction_id	IN	NUMBER,
		P_po_distribution_id	IN	NUMBER,
		P_billed_qty		IN OUT NOCOPY	NUMBER)
    IS

    Begin
        -- Bug fix: 1712542 added the NVL in the WHERE clause
	-- so that we get the quantity billed for the case when the
	-- match option is PO, for which we do not stamp the
	-- invoice distribution with rcv_transaction_id .

   -- Bug 7532498 - Removed the NVL on rcv_transaction_id as in R12,
   -- this code is used only for receipt matching and PO Match cases are
   -- handled separately.

	SELECT nvl(sum(nvl(quantity_invoiced,0)),0)-nvl(sum(nvl(price_correct_qty,0)),0) --6509492
	INTO	p_billed_qty
	FROM ap_invoice_distributions AID
	WHERE AID.rcv_transaction_id = P_rcv_transaction_id --bug 7532498
	  AND AID.po_distribution_id = P_po_distribution_id
	  --BUGFIX:5641346
	  AND line_type_lookup_code NOT IN ('RETAINAGE','PREPAY');

    Exception
	WHEN OTHERS THEN
	    app_exception.raise_exception;

    End Get_Recpt_Dist_Qty_Billed;

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
		p_login_id		IN	NUMBER) IS
    Begin

	-- find out if the receipt is matched -check quantity billed on the
	-- receipt



	-- Insert data into the table AP_MATCHED_RECT_ADJ_ALL

	-- set all who column dates to sysdate and conc program related
	-- columns to null

	-- just entering the stub package right now.
        null;
    End Insert_Adjusted_receipt_Ids;

    Function Get_Correction_Quantity (
               p_invoice_id             IN     NUMBER,
               p_line_number            IN     NUMBER)
    Return Number IS

      l_existing_corr_qty    Number;

    Begin

      /*
       * bug 7118571 - added ap_invoices_all to the query to consider non-cancelled invoices only
       */
      Select Nvl(Sum(ail.quantity_invoiced), 0)
      Into l_existing_corr_qty
      From ap_invoice_lines_all ail
      ,ap_invoices_all ai
      Where ail.corrected_inv_id = p_invoice_id
      And   ail.corrected_line_number = p_line_number
      And   ail.match_type = 'QTY_CORRECTION'
      And   ail.invoice_id = ai.invoice_id
      And   ai.cancelled_date is null;

      Return l_existing_corr_qty;

    End Get_Correction_Quantity;

    Function Get_Correction_Unit_Price (
               p_invoice_id             IN     NUMBER,
               p_line_number            IN     NUMBER)
    Return Number IS

      l_corrected_unit_price        Number;
      l_correction_amount           Number;
      l_original_amount             Number;
      l_original_qty_invoiced       Number;
      l_existing_corr_qty           Number;
      l_corrected_original_amt      Number; --7187973

    Begin

      /*
       * bug 7118571 - added ap_invoices_all to the query to consider non-cancelled invoices only
       */
      Select Nvl(Sum(ail.unit_price * ail.quantity_invoiced), 0)
      Into l_correction_amount
      From ap_invoice_lines_all ail
          ,ap_invoices_all ai
      Where ail.corrected_inv_id = p_invoice_id
      And   ail.corrected_line_number = p_line_number
      And   ail.match_type = 'PRICE_CORRECTION'
      And   ai.invoice_id = ail.invoice_id
      And   ai.cancelled_date is null;

/* Bug7187973 Starts
      Select (NVL(ail.unit_price, 0) * NVL(ail.quantity_invoiced, 0)),
             NVL( ail.quantity_invoiced,0)
      Into l_original_amount, l_original_qty_invoiced
      From ap_invoice_lines_all ail
      Where ail.invoice_id = p_invoice_id
      And   ail.line_number = p_line_number;
    Bug 7187973 Ends */

      l_existing_corr_qty := Get_Correction_Quantity(p_invoice_id, p_line_number);

-- Bug 7187973 Starts
-- The original amount should be calculated with latest quantity.
-- Latest quantity here is sum of the orginal quantity Invoiced and
-- Corrected quantity.

      Select  (NVL(ail.unit_price, 0) * NVL(ail.quantity_invoiced, 0)),
              (NVL(ail.unit_price, 0) * (NVL(ail.quantity_invoiced, 0) + NVL(l_existing_corr_qty,0)) ),
              NVL( ail.quantity_invoiced,0)
      Into    l_original_amount,
              l_corrected_original_amt,
              l_original_qty_invoiced
      From ap_invoice_lines_all ail
      Where ail.invoice_id = p_invoice_id
      And   ail.line_number = p_line_number;
-- Bug 7187973 Ends


      --Bug:4515876
          -- bug7187973 l_original_amount is replaced with
          -- l_corrected_original_amt
      IF l_correction_amount <> 0 THEN
        IF (l_original_qty_invoiced+l_existing_corr_qty) > 0 THEN
           l_corrected_unit_price := (l_correction_amount + l_corrected_original_amt)/
                                  (l_original_qty_invoiced + l_existing_corr_qty);
        END IF;
      ELSE
	    IF l_original_qty_invoiced > 0 THEN							--8299022
           l_corrected_unit_price := l_original_amount / l_original_qty_invoiced;
		END IF;
      END IF;
      Return l_corrected_unit_price;

    End Get_Correction_Unit_Price;

    Function Get_Correction_Quantity_Dist (
               p_invoice_dist_id             IN     NUMBER)
    Return Number IS

      l_existing_corr_qty    Number;

    Begin

      Select Nvl(Sum(aid.corrected_quantity), 0)
      Into l_existing_corr_qty
      From ap_invoice_distributions_all aid,
           ap_invoice_lines_all ail
      Where aid.corrected_invoice_dist_id = p_invoice_dist_id
      And   ail.line_number = aid.invoice_line_number
      And   ail.match_type = 'QTY_CORRECTION'
      And   aid.invoice_id=ail.invoice_id;   --bug 5015014

      Return l_existing_corr_qty;

    End Get_Correction_Quantity_Dist;

    Function Get_Correction_Amount (
               p_invoice_id             IN     NUMBER,
               p_line_number            IN     NUMBER)
    Return Number IS

      l_existing_corr_amt    Number;

    Begin

      /*
       * bug 7118571 - added ap_invoices_all to the query to consider non-cancelled invoices only
       */

      Select Nvl(Sum(ail.amount), 0)
      Into l_existing_corr_amt
      From ap_invoice_lines_all ail
           ,ap_invoices_all ai
      Where ail.corrected_inv_id = p_invoice_id
      And   ail.corrected_line_number = p_line_number
      And   ail.match_type In ( 'QTY_CORRECTION', 'PRICE_CORRECTION',
                                'AMOUNT_CORRECTION')
      And   ai.invoice_id = ail.invoice_id
      And   ai.cancelled_date is null;

      Return l_existing_corr_amt;

    End Get_Correction_Amount;


    Procedure Get_Num_Line_Dists (
                P_invoice_id            IN NUMBER,
                P_invoice_line_number   IN NUMBER,
                P_num_line_dists        IN OUT NOCOPY   NUMBER,
                P_inv_distribution_id   IN OUT NOCOPY   NUMBER) IS

   Begin

        -- Bug 5585744 , added the line_type_lookup_code condition
        SELECT count(*)
        INTO  p_num_line_dists
        FROM ap_invoice_distributions_all
        WHERE invoice_id = P_invoice_id
        AND   invoice_line_number = P_invoice_line_number
        AND   line_type_lookup_code in ('ITEM', 'ACCRUAL')
        AND   prepay_distribution_id is NULL;

        If (p_num_line_dists = 1 ) Then
            SELECT invoice_distribution_id
            INTO   p_inv_distribution_id
            FROM   ap_invoice_distributions_all
            WHERE invoice_id = P_invoice_id
            AND   invoice_line_number = P_invoice_line_number
            AND   line_type_lookup_code in ('ITEM', 'ACCRUAL')
            AND   prepay_distribution_id is NULL;

        Else
           p_inv_distribution_id := null;
        End if;

   End Get_Num_Line_Dists;


--Invoice Lines: Matching
/*----------------------------------------------------------------------
|This procedure when provided with a Invoice Line, based on the        |
|information provided on the line will match the invoice line          |
|appropriately to either PO or Receipt or perform Price/Quantity/Line  |
|correction.							                               |
|								                                       |
-----------------------------------------------------------------------*/
Procedure Match_Invoice_Line(
      P_Invoice_Id 	  	      IN NUMBER,
      P_Invoice_Line_Number   IN NUMBER,
      P_Overbill_Flag		  IN VARCHAR2,
      P_Calling_Sequence 	  IN VARCHAR2) IS

CURSOR Invoice_Lines_Cur IS
 SELECT *
 FROM ap_invoice_lines
 WHERE invoice_id = p_invoice_id
 AND line_number = p_invoice_line_number;

l_invoice_line_rec ap_invoice_lines%ROWTYPE;
l_match_mode VARCHAR2(8);
l_index  po_distributions_all.po_distribution_id%TYPE;
l_dist_ccid ap_invoice_distributions_all.dist_code_combination_id%TYPE;
l_corr_inv_dist_id ap_invoice_distributions_all.invoice_distribution_id%TYPE;
l_dist_tab ap_matching_pkg.dist_tab_type;
l_othr_chrg_tab ap_othr_chrg_match_pkg.othr_chrg_match_tabtype;
l_corr_dist_tab ap_matching_pkg.corr_dist_tab_type;
l_inv_line_tab ap_invoice_corrections_pkg.line_tab_type;
l_inv_dist_tab ap_invoice_corrections_pkg.dist_tab_type;
l_debug_info VARCHAR2(2000);
current_calling_sequence VARCHAR2(2000);
l_api_name 	         VARCHAR2(50);

BEGIN

  l_api_name := 'Match_Invoice_Line';
  current_calling_sequence := 'AP_MATCHING_UTILS_PKG.Match_Invoice_Line <-'||p_calling_sequence;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_UTILS_PKG.Match_Invoice_Line(+)');
  END IF;

  l_debug_info := 'Open Cursor Invoice_Lines_Cur';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN Invoice_Lines_Cur;
  FETCH Invoice_Lines_Cur INTO l_invoice_line_rec;
  CLOSE Invoice_Lines_Cur;


  l_debug_info := 'Derive the Match_Mode for the matching';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF (l_invoice_line_rec.match_type IN ('ITEM_TO_PO','ITEM_TO_RECEIPT',
                                        'ITEM_TO_SERVICE_PO', 'ITEM_TO_SERVICE_RECEIPT',
				        'PRICE_CORRECTION','QTY_CORRECTION',
                                        'AMOUNT_CORRECTION')) THEN
                                      /* Amount Based Matching */
     IF (SIGN(l_invoice_line_rec.amount) < 0) THEN
       l_match_mode := 'CR-';
     ELSE
       l_match_mode := 'STD-';
     END IF;

     IF (l_invoice_line_rec.po_distribution_id IS NULL) THEN

       l_match_mode := l_match_mode||'PS';

     ELSE

       l_match_mode := l_match_mode||'PD';

       l_index := l_invoice_line_rec.po_distribution_id;

       IF (l_invoice_line_rec.match_type IN ('ITEM_TO_PO','ITEM_TO_RECEIPT',
                                      'ITEM_TO_SERVICE_PO', 'ITEM_TO_SERVICE_RECEIPT')) THEN
                                      /* AmounT Based Matching */
          l_dist_tab(l_index).po_distribution_id := l_invoice_line_rec.po_distribution_id;
          l_dist_tab(l_index).amount := l_invoice_line_rec.amount;
          l_dist_tab(l_index).quantity_invoiced := l_invoice_line_rec.quantity_invoiced;
          l_dist_tab(l_index).unit_price := l_invoice_line_rec.unit_price;

	  --Bugfix:4699604
	  BEGIN
	     SELECT code_combination_id
	     INTO l_dist_tab(l_index).dist_ccid
	     FROM po_distributions_ap_v
	     WHERE po_distribution_id = l_invoice_line_rec.po_distribution_id;
          EXCEPTION WHEN OTHERS THEN
	    NULL;
	  END;

       ELSE /* match type IN ('PRICE_CORRECTION','QTY_CORRECTION', 'AMOUNT_CORRECTION') */

	  --bugfix:5641346
	  BEGIN

            SELECT invoice_distribution_id, dist_code_combination_id
	    INTO l_corr_inv_dist_id, l_dist_ccid
	    FROM ap_invoice_distributions
	    WHERE invoice_id =  l_invoice_line_rec.corrected_inv_id
	    AND invoice_line_number = l_invoice_line_rec.corrected_line_number
            AND po_distribution_id = l_invoice_line_rec.po_distribution_id;

          EXCEPTION WHEN OTHERS THEN
	    NULL;
          END;

          l_corr_dist_tab(l_index).po_distribution_id :=
                                         l_invoice_line_rec.po_distribution_id;
	  l_corr_dist_tab(l_index).corrected_inv_dist_id := l_corr_inv_dist_id;
	  l_corr_dist_tab(l_index).amount	      := l_invoice_line_rec.amount;
          l_corr_dist_tab(l_index).dist_ccid 	      := l_dist_ccid;

          /* Amount Based Matching */
          IF  l_invoice_line_rec.match_type <> 'AMOUNT_CORRECTION' THEN

            l_corr_dist_tab(l_index).corrected_quantity :=
                                                    l_invoice_line_rec.quantity_invoiced;
            l_corr_dist_tab(l_index).unit_price         := l_invoice_line_rec.unit_price;

          END IF;


       END IF;

     END IF;

  END IF;


  IF (l_invoice_line_rec.match_type = 'ITEM_TO_PO') THEN

     l_debug_info := 'Calling AP_Matching_Pkg.Base_Credit_Po_Match';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     Ap_Matching_Pkg.Base_Credit_PO_Match(
	  X_match_mode  	=> l_match_mode,
          X_invoice_id  	=> p_invoice_id,
          X_invoice_line_number	=> p_invoice_line_number,
          X_Po_Line_Location_id	=> l_invoice_line_rec.po_line_location_id,
          X_Dist_Tab            => l_dist_tab,
          X_amount  		=> l_invoice_line_rec.amount,
          X_quantity 		=> l_invoice_line_rec.quantity_invoiced,
          X_unit_price          => l_invoice_line_rec.unit_price,
          X_uom_lookup_code     => l_invoice_line_rec.unit_meas_lookup_code,
          X_final_match_flag    => l_invoice_line_rec.final_match_flag,
          X_overbill_flag       => p_overbill_flag,
	  X_retained_amount	=> l_invoice_line_rec.retained_amount,
          X_freight_amount      => NULL,
          X_freight_description => NULL,
          X_misc_amount         => NULL,
          X_misc_description    => NULL,
          X_calling_sequence    => current_calling_sequence) ;


  ELSIF (l_invoice_line_rec.match_type = 'ITEM_TO_RECEIPT') THEN

     l_debug_info := 'Calling AP_Rect_Match_Pkg.Base_Credit_RCV_Match';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

      --Bug 5524881  ISP Receipt Matching
     IF  l_invoice_line_rec.rcv_transaction_id IS NULL THEN
         Match_To_Rcv_Shipment_Line(P_Invoice_Id          => p_invoice_id,
                                    P_Invoice_Line_Number => p_invoice_line_number,
                                    P_Calling_Sequence    => current_calling_sequence);
     ELSE

     Ap_Rect_Match_Pkg.Base_Credit_RCV_Match(
          X_match_mode          => l_match_mode,
          X_invoice_id          => p_invoice_id,
          X_invoice_line_number => p_invoice_line_number,
          X_Po_Line_Location_id => l_invoice_line_rec.po_line_location_id,
          X_Rcv_Transaction_id  => l_invoice_line_rec.rcv_transaction_id,
          X_Dist_Tab            => l_dist_tab,
          X_amount              => l_invoice_line_rec.amount,
          X_quantity            => l_invoice_line_rec.quantity_invoiced,
          X_unit_price          => l_invoice_line_rec.unit_price,
          X_uom_lookup_code     => l_invoice_line_rec.unit_meas_lookup_code,
          X_freight_amount      => NULL,
          X_freight_description => NULL,
          X_misc_amount         => NULL,
          X_misc_description    => NULL,
	      X_retained_amount	=> l_invoice_line_rec.retained_amount,
          X_calling_sequence    => current_calling_sequence) ;
    END IF;

  ELSIF (l_invoice_line_rec.match_type = 'OTHER_TO_RECEIPT') THEN

     l_debug_info := 'Calling AP_Othr_Chrg_Match_Pkg.Othr_Chrg_Match';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     l_othr_chrg_tab(1).rcv_txn_id := l_invoice_line_rec.rcv_transaction_id;
     l_othr_chrg_tab(1).charge_amt := l_invoice_line_rec.amount;
     l_othr_chrg_tab(1).base_amt := NULL;
     l_othr_chrg_tab(1).rounding_amt := NULL;
     l_othr_chrg_tab(1).rcv_qty := l_invoice_line_rec.quantity_invoiced;

     Ap_Othr_Chrg_Match_Pkg.Othr_Chrg_Match(
	  X_invoice_id  	=> p_invoice_id,
          X_invoice_line_number => p_invoice_line_number,
          X_line_type           => l_invoice_line_rec.line_type_lookup_code,
          X_prorate_flag        => 'N',
          X_account_id          => l_invoice_line_rec.default_dist_ccid,
          X_description         => l_invoice_line_rec.description,
          X_total_amount        => l_invoice_line_rec.amount ,
          X_othr_chrg_tab       => l_othr_chrg_tab,
          X_row_count           => 1,
          X_calling_sequence    => current_calling_sequence);

  /* Amount Based Matching */
  ELSIF (l_invoice_line_rec.match_type = 'ITEM_TO_SERVICE_PO') THEN

     l_debug_info := 'Calling AP_Po_Amt_Match_Pkg.AP_Amt_Match';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

       Ap_Po_Amt_Match_Pkg.Ap_Amt_Match(
          X_match_mode          => l_match_mode,
          X_invoice_id          => p_invoice_id,
          X_invoice_line_number => p_invoice_line_number,
          X_Dist_Tab            => l_dist_tab,
          X_Po_Line_Location_id => l_invoice_line_rec.po_line_location_id,
          X_amount              => l_invoice_line_rec.amount,
          X_quantity            => l_invoice_line_rec.quantity_invoiced,
          X_unit_price          => l_invoice_line_rec.unit_price,
          X_uom_lookup_code     => l_invoice_line_rec.unit_meas_lookup_code,
          X_final               => l_invoice_line_rec.final_match_flag,
          X_overbill            => p_overbill_flag,
          X_freight_amount      => NULL,
          X_freight_description => NULL,
          X_misc_amount         => NULL,
          X_misc_description    => NULL,
	      X_retained_amount	=> l_invoice_line_rec.retained_amount,
          X_calling_sequence    => current_calling_sequence) ;


   /* Amount Based Matching */
   ELSIF (l_invoice_line_rec.match_type = 'ITEM_TO_SERVICE_RECEIPT') THEN

     l_debug_info := 'AP_Rct_Amt_Match_Pkg.AP_Amt_Match';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     --Bug 5524881  ISP Receipt Matching
     IF  l_invoice_line_rec.rcv_transaction_id IS NULL THEN
         Match_To_Rcv_Shipment_Line(P_Invoice_Id          => p_invoice_id,
                                    P_Invoice_Line_Number => p_invoice_line_number,
                                    P_Calling_Sequence    => current_calling_sequence);
     ELSE

       Ap_Rct_Amt_Match_Pkg.Ap_Amt_Match(
          X_match_mode          => l_match_mode,
          X_invoice_id          => p_invoice_id,
          X_invoice_line_number => p_invoice_line_number,
          X_Dist_Tab            => l_dist_tab,
          X_Po_Line_Location_id => l_invoice_line_rec.po_line_location_id,
          X_Rcv_Transaction_id  => l_invoice_line_rec.rcv_transaction_id,
          X_amount              => l_invoice_line_rec.amount,
          X_quantity            => l_invoice_line_rec.quantity_invoiced,
          X_unit_price          => l_invoice_line_rec.unit_price,
          X_uom_lookup_code     => l_invoice_line_rec.unit_meas_lookup_code,
          X_freight_amount      => NULL,
          X_freight_description => NULL,
          X_misc_amount         => NULL,
          X_misc_description    => NULL,
	      X_retained_amount	=> l_invoice_line_rec.retained_amount,
          X_calling_sequence    => current_calling_sequence) ;
     END IF;

  ELSIF (l_invoice_line_rec.match_type IN ('PRICE_CORRECTION','QTY_CORRECTION')) THEN

     IF (l_invoice_line_rec.rcv_transaction_id IS NULL) THEN

	l_debug_info := 'Calling AP_Matching_Pkg.Price_Quantity_Correct_Inv_PO';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        Ap_Matching_Pkg.Price_Quantity_Correct_Inv_PO(
                X_Invoice_Id            => p_invoice_id,
                X_Invoice_Line_Number   => p_invoice_line_number,
                X_Corrected_Invoice_Id  => l_invoice_line_rec.corrected_inv_id,
                X_Corrected_Line_Number => l_invoice_line_rec.corrected_line_number,
                X_Correction_Type       => l_invoice_line_rec.match_type,
                X_Correction_Quantity   => l_invoice_line_rec.quantity_invoiced,
                X_Correction_Amount     => l_invoice_line_rec.amount,
                X_Correction_Price      => l_invoice_line_rec.unit_price,
		        X_Match_Mode		    => l_match_mode,
                X_Po_Line_Location_Id   => l_invoice_line_rec.po_line_location_id,
                X_Corr_Dist_Tab         => l_corr_dist_tab,
                X_Final_Match_Flag      => l_invoice_line_rec.final_match_flag,
                X_Uom_Lookup_Code       => l_invoice_line_rec.unit_meas_lookup_code,
		        X_Retained_Amount	    => l_invoice_line_rec.retained_amount,
                X_Calling_Sequence      => current_calling_sequence);

     ELSE

       l_debug_info := 'AP_Rect_Match_Pkg.Price_Quantity_Correct_Inv_RCV';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       Ap_Rect_Match_Pkg.Price_Quantity_Correct_Inv_RCV(
                X_Invoice_Id            => p_invoice_id,
                X_Invoice_Line_Number   => p_invoice_line_number,
                X_Corrected_Invoice_Id  => l_invoice_line_rec.corrected_inv_id,
                X_Corrected_Line_Number => l_invoice_line_rec.corrected_line_number,
                X_Correction_Type       => l_invoice_line_rec.match_type,
                X_Correction_Quantity   => l_invoice_line_rec.quantity_invoiced,
                X_Correction_Amount     => l_invoice_line_rec.amount,
                X_Correction_Price      => l_invoice_line_rec.unit_price,
		        X_Match_Mode            => l_match_mode,
                X_Po_Line_Location_Id   => l_invoice_line_rec.po_line_location_id,
		X_Rcv_Transaction_Id    => l_invoice_line_rec.rcv_transaction_id,
                X_Corr_Dist_Tab         => l_corr_dist_tab,
                X_Uom_Lookup_Code       => l_invoice_line_rec.unit_meas_lookup_code,
	  	X_retained_amount	=> l_invoice_line_rec.retained_amount,
                X_Calling_Sequence      => current_calling_sequence);

     END IF;

  /* AmounT Based Matching */
  ELSIF (l_invoice_line_rec.match_type = 'AMOUNT_CORRECTION') THEN

     IF (l_invoice_line_rec.rcv_transaction_id IS NULL) THEN

	l_debug_info := 'Calling AP_Po_Amt_Match_Pkg.Amount_Correct_Inv_Po';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        Ap_Po_Amt_Match_Pkg.Amount_Correct_Inv_PO(
                X_Invoice_Id            => p_invoice_id,
                X_Invoice_Line_Number   => p_invoice_line_number,
                X_Corrected_Invoice_Id  => l_invoice_line_rec.corrected_inv_id,
                X_Corrected_Line_Number => l_invoice_line_rec.corrected_line_number,
                X_Match_Mode            => l_match_mode,
                X_Correction_Amount     => l_invoice_line_rec.amount,
                X_Po_Line_Location_Id   => l_invoice_line_rec.po_line_location_id,
                X_Corr_Dist_Tab         => l_corr_dist_tab,
                X_Final_Match_Flag      => l_invoice_line_rec.final_match_flag,
                X_Uom_Lookup_Code       => l_invoice_line_rec.unit_meas_lookup_code,
		X_Retained_Amount	=> l_invoice_line_rec.retained_amount,
                X_Calling_Sequence      => current_calling_sequence);

     ELSE

	l_debug_info := 'Calling AP_Rct_Amt_Match_Pkg.Amount_Correct_Inv_Rcv';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        Ap_Rct_Amt_Match_Pkg.Amount_Correct_Inv_Rcv(
                X_Invoice_Id            => p_invoice_id,
                X_Invoice_Line_Number   => p_invoice_line_number,
                X_Corrected_Invoice_Id  => l_invoice_line_rec.corrected_inv_id,
                X_Corrected_Line_Number => l_invoice_line_rec.corrected_line_number,
                X_Match_Mode            => l_match_mode,
                X_Correction_Amount     => l_invoice_line_rec.amount,
                X_Po_Line_Location_Id   => l_invoice_line_rec.po_line_location_id,
                X_Rcv_Transaction_Id    => l_invoice_line_rec.rcv_transaction_id,
                X_Corr_Dist_Tab         => l_corr_dist_tab,
                X_Uom_Lookup_Code       => l_invoice_line_rec.unit_meas_lookup_code,
	  	X_retained_amount	=> l_invoice_line_rec.retained_amount,
                X_Calling_Sequence      => current_calling_sequence);

     END IF;

  ELSIF (l_invoice_line_rec.match_type = 'LINE_CORRECTION') THEN
       l_debug_info := 'Calling AP_Invoice_Corrections_Pkg.Invoice_Correction';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       AP_INVOICE_CORRECTIONS_PKG.Invoice_Correction(
		X_Invoice_Id  		=> p_invoice_id,
		X_Invoice_Line_Number   => p_invoice_line_number,
		X_Corrected_Invoice_Id  => l_invoice_line_rec.corrected_inv_id,
		X_Corrected_Line_Number => l_invoice_line_rec.corrected_line_number,
		X_Prorate_Lines_Flag	=> 'N',
		X_Prorate_Dists_Flag    => 'Y',
		X_Correction_Quantity   => l_invoice_line_rec.quantity_invoiced,
		X_Correction_Amount	=> l_invoice_line_rec.amount,
		X_Correction_Price      => l_invoice_line_rec.unit_price,
		X_Line_Tab		=> l_inv_line_tab,
		X_Dist_Tab		=> l_inv_dist_tab,
		X_Calling_Sequence      => current_calling_sequence);

  END IF;

EXCEPTION WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
            'P_invoice_id = '   || P_invoice_id
          ||'P_invoice_line_number = '||P_invoice_line_number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

	If (Invoice_Lines_Cur%ISOPEN) Then
	  Close Invoice_Lines_Cur;
	End if;
  END IF;
  App_Exception.Raise_Exception;

END Match_Invoice_Line;

 --Added the following new procedure for Amount-Based Matching Project

PROCEDURE Get_Recpt_Dist_Amt_Billed (
                p_rcv_transaction_id  IN      NUMBER,
                p_po_distribution_id  IN            NUMBER,
                p_billed_amt          IN OUT NOCOPY NUMBER) IS

BEGIN
    SELECT sum(amount)
     INTO    p_billed_amt
        FROM ap_invoice_distributions AID
        WHERE NVL(AID.rcv_transaction_id,P_rcv_transaction_id)
                                                = P_rcv_transaction_id
          AND AID.po_distribution_id = P_po_distribution_id
	  --Bugfix:5641346
	  AND AID.line_type_lookup_code NOT IN ('RETAINAGE','PREPAY');


EXCEPTION
  WHEN OTHERS THEN
    app_exception.raise_exception;

END Get_Recpt_Dist_Amt_Billed;

Function Get_Avail_Dist_Corr_Amount (
               p_invoice_dist_id             IN     NUMBER)
  Return Number IS

  l_dist_amt             Number;
  l_existing_corr_amt    Number;
  l_avail_corr_amt       Number;

Begin

   Select amount
   Into l_dist_amt
   From ap_invoice_distributions_all
   Where invoice_distribution_id = p_invoice_dist_id;

   Select Nvl(Sum(aid.amount), 0)
   Into l_existing_corr_amt
   From ap_invoice_distributions_all aid,
        ap_invoice_lines_all ail
   Where aid.corrected_invoice_dist_id = p_invoice_dist_id
   And   ail.line_number = aid.invoice_line_number
   And   ail.match_type = 'LINE_CORRECTION'
   And   aid.invoice_id=ail.invoice_id;  --bug5015014

   l_avail_corr_amt := l_dist_amt - abs(l_existing_corr_amt);

   Return l_avail_corr_amt;

End Get_Avail_Dist_Corr_Amount;

Function Get_Line_Assoc_Charge (
               P_invoice_id    IN NUMBER,
               P_line_number   IN NUMBER)
  Return Number IS

  l_total_amount  NUMBER;

Begin

  Select Nvl(Sum(aarl.amount), 0)
  Into l_total_amount
  From ap_allocation_rule_lines aarl
  Where invoice_id = p_invoice_id
  And   to_invoice_line_number = p_line_number;

  Return l_total_amount;

End Get_Line_Assoc_Charge;

Function Get_Avail_Line_Corr_Amount (
               P_invoice_id    IN NUMBER,
               P_line_number   IN NUMBER)
  Return Number IS

  l_line_amt             Number;
  l_existing_corr_amt    Number;
  l_avail_corr_amt       Number;

Begin

  Select amount
  Into l_line_amt
  From ap_invoice_lines_all
  Where invoice_id = p_invoice_id
  And line_number = p_line_number;

  Select Nvl(Sum(ail.amount), 0)
  Into l_existing_corr_amt
  From ap_invoice_lines_all ail
  Where ail.corrected_inv_id = p_invoice_id
  And   ail.corrected_line_number = p_line_number
  And   ail.match_type = 'LINE_CORRECTION';

  l_avail_corr_amt := l_line_amt - abs(l_existing_corr_amt);

  Return l_avail_corr_amt;

End Get_Avail_Line_Corr_Amount;

Function Get_Avail_Line_Corr_Qty (
               P_invoice_id    IN NUMBER,
               P_line_number   IN NUMBER)
  Return Number IS

  l_line_qty             Number;
  l_existing_corr_qty    Number;
  l_avail_corr_qty       Number;

Begin

  Select nvl(quantity_invoiced,0)
  Into l_line_qty
  From ap_invoice_lines_all
  Where invoice_id = p_invoice_id
  And line_number = p_line_number;

  Select Nvl(Sum(ail.quantity_invoiced), 0)
  Into l_existing_corr_qty
  From ap_invoice_lines_all ail
  Where ail.corrected_inv_id = p_invoice_id
  And   ail.corrected_line_number = p_line_number
  And   ail.match_type = 'LINE_CORRECTION';

  l_avail_corr_qty := l_line_qty - abs(l_existing_corr_qty);

  Return l_avail_corr_qty;

End Get_Avail_Line_Corr_Qty;

Function Get_Avail_Inv_Corr_Amount (
               P_invoice_id    IN NUMBER)
 Return Number IS

 l_invoice_amt           Number;
 l_existing_corr_amt    Number;
 l_avail_corr_amt       Number;

Begin

  Select Nvl(Sum(amount), 0)
  Into l_invoice_amt
  From ap_invoice_lines_all
  Where invoice_id = p_invoice_id
  And   match_type = 'NOT_MATCHED';

  Select Nvl(Sum(ail.amount), 0)
  Into l_existing_corr_amt
  From ap_invoice_lines_all ail
  Where ail.corrected_inv_id = p_invoice_id
  And   ail.match_type = 'LINE_CORRECTION';

  l_avail_corr_amt := l_invoice_amt - abs(l_existing_corr_amt);

  Return l_avail_corr_amt;

End Get_Avail_Inv_Corr_Amount;


Procedure AP_Upgrade_Po_Shipment(P_Po_Line_Location_Id   IN	NUMBER,
				 P_Calling_Sequence      IN	VARCHAR2) IS

   l_total_shipment_qty_invoiced   NUMBER;
   l_total_shipment_amt_invoiced   NUMBER;
   l_total_shipment_qty_applied    NUMBER;
   l_total_shipment_amt_applied    NUMBER;

   l_total_dist_qty_invoiced   NUMBER;
   l_total_dist_amt_invoiced   NUMBER;
   l_total_dist_qty_applied    NUMBER;
   l_total_dist_amt_applied    NUMBER;
   l_po_distribution_id        NUMBER;

   TYPE dist_record_type is RECORD
      (po_distribution_id        PO_DISTRIBUTIONS.po_distribution_id%TYPE,   --Index Column
       total_dist_qty_invoiced   AP_INVOICE_DISTRIBUTIONS.quantity_invoiced%TYPE,
       total_dist_qty_applied    AP_INVOICE_DISTRIBUTIONS.quantity_invoiced%TYPE,
       total_dist_amt_invoiced   AP_INVOICE_DISTRIBUTIONS.amount%TYPE,
       total_dist_amt_applied    AP_INVOICE_DISTRIBUTIONS.amount%TYPE,
       matching_basis            PO_LINE_LOCATIONS.matching_basis%TYPE);

  TYPE dist_tab_type IS TABLE OF dist_record_type INDEX BY BINARY_INTEGER;

  l_dist_tab dist_tab_type;
  l_matching_basis po_line_locations_all.matching_basis%TYPE;
  l_debug_info  VARCHAR2(2000);
  l_api_name    VARCHAR2(50);


  CURSOR C_Po_Dists_Financed IS
  SELECT aid.po_distribution_id,
         decode(pll.matching_basis,'QUANTITY',sum(nvl(aid.quantity_invoiced,0))),
	 decode(pll.matching_basis,'AMOUNT',sum(nvl(aid.amount,0))),
	 pll.matching_basis
  FROM ap_invoice_distributions_v aid,
       ap_invoices ai,
       po_line_locations pll
  WHERE pll.line_location_id = P_Po_Line_Location_Id
  AND pll.shipment_type <> 'PREPAYMENT'
  AND aid.line_location_id =pll.line_location_id
  AND aid.invoice_id = ai.invoice_id
  AND ai.invoice_type_lookup_code = 'PREPAYMENT'
  GROUP BY aid.po_distribution_id, pll.matching_basis;

 CURSOR C_Po_Dists_Recouped IS
 select aid.po_distribution_id,
   decode(pll.matching_basis,'QUANTITY',sum(nvl(aid.quantity_invoiced,0))),
         decode(pll.matching_basis,'AMOUNT',sum(nvl(aid.amount,0))),
  pll.matching_basis
    from ap_invoice_distributions aid,
         po_distributions_all pd,
         po_line_locations pll
    where pll.line_location_id = p_po_line_location_id
    and pll.shipment_type <> 'PREPAYMENT'
    and aid.po_distribution_id = pd.po_distribution_id
    and pd.line_location_id = pll.line_location_id
    and aid.line_type_lookup_code = 'PREPAY'
    group by aid.po_distribution_id,pll.matching_basis;

BEGIN

  l_api_name := 'AP_Upgrade_Po_Shipment';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_UTILS_PKG.Ap_Upgrade_Po_Shipment(+)');
  END IF;


  l_debug_info := 'Get Total Quantity/Amount Financed for this shipment across all invoices';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN C_Po_Dists_Financed;

  LOOP

    FETCH C_Po_Dists_Financed INTO  l_po_distribution_id,
    				    l_total_dist_qty_invoiced,
     				    l_total_dist_amt_invoiced,
				    l_matching_basis;

    EXIT WHEN C_Po_Dists_Financed%NOTFOUND;

    l_dist_tab(l_po_distribution_id).po_distribution_id := l_po_distribution_id;
    l_dist_tab(l_po_distribution_id).total_dist_qty_invoiced := l_total_dist_qty_invoiced;
    l_dist_tab(l_po_distribution_id).total_dist_amt_invoiced := l_total_dist_amt_invoiced;

  END LOOP;

  CLOSE C_Po_Dists_Financed;

  l_debug_info := 'Get Total Quantity/Amount Recouped for this shipment across all invoices';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  OPEN C_Po_Dists_Recouped;

  LOOP

     l_debug_info := 'Fetch C_Po_Dists_Recouped into local variables';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     FETCH C_Po_Dists_Recouped INTO  l_po_distribution_id,
                                     l_total_dist_qty_applied,
                                     l_total_dist_amt_applied,
				     l_matching_basis;

     EXIT WHEN C_Po_Dists_Recouped%NOTFOUND;

     l_dist_tab(l_po_distribution_id).po_distribution_id := l_po_distribution_id;
     l_dist_tab(l_po_distribution_id).total_dist_qty_applied := l_total_dist_qty_applied;
     l_dist_tab(l_po_distribution_id).total_dist_amt_applied := l_total_dist_amt_applied;

  END LOOP;

  CLOSE C_Po_Dists_Financed;


  l_debug_info := 'Update Po_Distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  FOR i in nvl(l_dist_tab.first,0) .. nvl(l_dist_tab.last,0) LOOP

    IF (l_dist_tab.exists(i)) THEN

       IF (l_matching_basis = 'QUANTITY') THEN

          UPDATE po_distributions pod
          SET quantity_financed = l_dist_tab(i).total_dist_qty_invoiced,
              quantity_recouped = l_dist_tab(i).total_dist_qty_applied,
	      quantity_billed = nvl(quantity_billed,0) - (l_dist_tab(i).total_dist_qty_invoiced -
	    					    l_dist_tab(i).total_dist_qty_applied)
          WHERE pod.po_distribution_id = l_dist_tab(i).po_distribution_id
          AND pod.quantity_financed IS NULL;

          l_total_shipment_qty_invoiced := nvl(l_total_shipment_qty_invoiced,0) +
      						nvl(l_dist_tab(i).total_dist_qty_invoiced,0);
          l_total_shipment_qty_applied := nvl(l_total_shipment_qty_applied,0) +
	  					nvl(l_dist_tab(i).total_dist_qty_applied,0);

       ELSIF (l_matching_basis = 'AMOUNT') THEN

          UPDATE po_distributions pod
          SET amount_financed = l_total_dist_amt_invoiced,
              amount_recouped = l_total_dist_amt_applied,
              amount_billed = nvl(amount_billed,0) - (l_dist_tab(i).total_dist_amt_invoiced -
	      					l_dist_tab(i).total_dist_amt_applied)
          WHERE pod.po_distribution_id = l_dist_tab(i).po_distribution_id
          AND pod.amount_financed IS NULL;

	  l_total_shipment_amt_invoiced := nvl(l_total_shipment_amt_invoiced,0) +
	                                                  nvl(l_dist_tab(i).total_dist_amt_invoiced,0);
          l_total_shipment_amt_applied := nvl(l_total_shipment_amt_applied,0) +
	                                                  nvl(l_dist_tab(i).total_dist_amt_applied,0);

       END IF;

    END IF;

  END LOOP;

  l_debug_info := 'Update Po_Shipments with the cumulative totals';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF (l_matching_basis = 'QUANTITY') THEN

    UPDATE po_line_locations
    SET quantity_financed = l_total_shipment_qty_invoiced,
    	quantity_recouped = l_total_shipment_qty_applied,
	quantity_billed = nvl(quantity_billed,0) - (l_total_shipment_qty_invoiced - l_total_shipment_qty_applied)
    WHERE line_location_id = p_po_line_location_id
    AND quantity_financed IS NULL;

  ELSIF (l_matching_basis = 'AMOUNT') THEN

    UPDATE po_line_locations
    SET amount_financed = l_total_shipment_amt_invoiced,
        amount_recouped = l_total_shipment_amt_applied,
        amount_billed = nvl(amount_billed,0) - (l_total_shipment_amt_invoiced - l_total_shipment_amt_applied)
    WHERE line_location_id = p_po_line_location_id
    AND amount_financed IS NULL;

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_UTILS_PKG.Ap_Upgrade_Po_Shipment(-)');
  END IF;

EXCEPTION WHEN OTHERS THEN
  NULL;

END AP_Upgrade_Po_Shipment;




/*API to Automatically recoup Prepayment invoice lines which are matched
 to the same PO Line as the Item Line on the Standard invoice. */
Function Ap_Recoup_Invoice_Line(P_Invoice_Id  		IN	NUMBER,
				 P_Invoice_Line_Number	IN	NUMBER,
				 P_Amount_To_Recoup     IN	NUMBER,
				 P_Po_Line_Id		IN	NUMBER,
				 P_Vendor_Id		IN	NUMBER,
				 P_Vendor_Site_Id	IN	NUMBER,
				 P_Accounting_Date	IN	DATE,
				 P_Period_Name		IN	VARCHAR2,
				 P_User_Id		IN	NUMBER,
				 P_Last_Update_Login    IN	NUMBER,
				 P_Error_Message	OUT NOCOPY VARCHAR2,
				 P_Calling_Sequence	IN	VARCHAR2) RETURN BOOLEAN IS

CURSOR Prepayment_Invoice_Lines IS
 /* select matched prepayments */
 SELECT ai.invoice_id prepayment_invoice_id,
 	ai.invoice_num prepayment_invoice_num,
	ail.line_number prepayment_line_number,
	decode(pll.payment_type,'ADVANCE',2,1) prepayment_order_number,
	AP_Prepay_Utils_Pkg.Get_Ln_Prep_Amt_Remain_Recoup(
			ai.invoice_id,ail.line_number) prepay_amount_remaining,
        max(aip.accounting_date) prepayment_payment_date
 FROM ap_invoices ai,
      ap_invoice_lines ail,
      po_line_locations pll,
      ap_invoice_payments aip
 WHERE ai.invoice_id = ail.invoice_id
 AND ail.po_line_id = p_po_line_id
 AND ai.invoice_type_lookup_code = 'PREPAYMENT'
 AND ail.line_type_lookup_code = 'ITEM'
 AND pll.po_line_id = p_po_line_id
 AND pll.payment_type IS NOT NULL
 AND AP_PREPAY_UTILS_PKG.Get_Ln_Prep_Amt_Remain_Recoup(ai.invoice_id,ail.line_number) > 0
 AND NVL(aip.reversal_flag,'N') <> 'Y' -- Added for bug 8340944
 AND aip.invoice_id = ai.invoice_id
 AND pll.line_location_id = ail.po_line_location_id
 --bugfix:4880825 removed '+1' from the NVL condition
 AND nvl(ai.earliest_settlement_date,SYSDATE) <= SYSDATE
 AND NVL(ail.discarded_flag,'N')              <> 'Y'
 --Do we need to check this, since by the time cursor is fetched and the one-by-one
 --prepayment is applied, it could be the case that the prepayment_invoice which was
 --locked when selecting, could be actually unlocked by the time actual application happens.
 --So, just checking if the line if locked or not just before application should be sufficient?
-- AND NVL(ail.line_selected_for_appl_flag,'N') <> 'Y'
 GROUP BY aip.invoice_id, ai.invoice_id,ai.invoice_num,
          ail.line_number,pll.payment_type,aip.accounting_date
 ORDER BY prepayment_payment_date,prepayment_order_number;


 CURSOR C_INVOICE_INFO (CV_Invoice_ID IN NUMBER) IS
 SELECT invoice_currency_code,
        exchange_rate,
        exchange_date,
        exchange_rate_type,
        payment_currency_code,
        payment_cross_rate_date,
        payment_cross_rate_type
   FROM AP_Invoices
   WHERE invoice_id = CV_Invoice_ID;

 CURSOR C_Prepay_dists IS
 SELECT prepay_distribution_id,
        amount
 FROM ap_invoice_distributions
 WHERE invoice_id = p_invoice_id
 AND invoice_line_number = p_invoice_line_number
 AND line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
 AND prepay_distribution_id IS NOT NULL;





l_max_amount_to_recoup  	NUMBER;
l_amount_recouped		NUMBER;
l_amount_to_apply		NUMBER;
l_is_line_locked		VARCHAR2(30);
l_prepayment_invoice_id 	NUMBER;
l_prepayment_invoice_num        VARCHAR2(50);
l_prepayment_line_number	NUMBER;
l_prepayment_amount_remaining   NUMBER;
l_prepayment_order_number	NUMBER;
l_prepayment_payment_date	DATE;
l_prepay_dist_info              AP_PREPAY_PKG.PREPAY_DIST_TAB_TYPE;
l_lock_result			BOOLEAN;
l_debug_info 			VARCHAR2(2000);
l_curr_calling_sequence 	VARCHAR2(2000);
l_api_name               	VARCHAR2(50);
l_error_message			VARCHAR2(4000);
l_success			BOOLEAN;

--bugfix:5496603
l_recouped_tax_amt_in_pay_curr  NUMBER;
l_recouped_tax_amount           NUMBER;
l_inv_curr_code            ap_invoices_all.invoice_currency_code%TYPE;
l_inv_xrate                ap_invoices_all.exchange_rate%TYPE;
l_inv_xdate                ap_invoices_all.exchange_date%TYPE;
l_inv_xrate_type           ap_invoices_all.exchange_rate_type%TYPE;
l_inv_pay_curr_code        ap_invoices_all.payment_currency_code%TYPE;
l_inv_pay_cross_rate_date  ap_invoices_all.payment_cross_rate_date%TYPE;
l_inv_pay_cross_rate_type  ap_invoices_all.payment_cross_rate_type%TYPE;
TYPE PREPAY_DIST_ID_LIST IS TABLE OF AP_INVOICE_DISTRIBUTIONS_ALL.PREPAY_DISTRIBUTION_ID%TYPE INDEX BY PLS_INTEGER;
TYPE RECOUP_AMOUNT_LIST IS TABLE OF AP_INVOICE_DISTRIBUTIONS_ALL.AMOUNT%TYPE INDEX BY PLS_INTEGER;
l_prepay_dist_id_list      prepay_dist_id_list;
l_recoup_amount_list       recoup_amount_list;

tax_exception                   EXCEPTION;

BEGIN
  l_max_amount_to_recoup := p_amount_to_recoup;
  l_amount_recouped := 0;
  l_is_line_locked := 'UNLOCKED';

  l_api_name := 'AP_Recoup_Invoice_Line';
  l_curr_calling_sequence := 'AP_MATCHING_UTILS_PKG.AP_Recoup_Invoice_Line <-'||p_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_UTILS_PKG.Ap_Recoup_Invoice_Line(+)');
  END IF;


  OPEN C_INVOICE_INFO (P_INVOICE_ID);

  FETCH C_INVOICE_INFO INTO
                          l_inv_curr_code,
		          l_inv_xrate,
		          l_inv_xdate,
		          l_inv_xrate_type,
		          l_inv_pay_curr_code,
		          l_inv_pay_cross_rate_date,
		          l_inv_pay_cross_rate_type;

  CLOSE C_INVOICE_INFO;


  l_debug_info := 'Open cursor Prepayment_Invoice_Lines';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  OPEN Prepayment_Invoice_Lines;
  LOOP

     l_debug_info := 'Fetch into local variables';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     FETCH Prepayment_Invoice_Lines INTO l_prepayment_invoice_id,
     					 l_prepayment_invoice_num,
					 l_prepayment_line_number,
					 l_prepayment_order_number,
					 l_prepayment_amount_remaining,
					 l_prepayment_payment_date;

     EXIT WHEN (Prepayment_Invoice_Lines%NOTFOUND OR l_max_amount_to_recoup = 0);

     IF (l_prepayment_amount_remaining >= l_max_amount_to_recoup) THEN
         l_amount_to_apply := l_max_amount_to_recoup;
     ELSE
         l_amount_to_apply := l_prepayment_amount_remaining;
     END IF;

     l_max_amount_to_recoup := l_max_amount_to_recoup - l_amount_to_apply;
     l_amount_recouped := l_amount_recouped + l_amount_to_apply;


     l_debug_info := 'Check if the Prepayment Invoice - Item line is already locked';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     l_is_line_locked := AP_PREPAY_UTILS_PKG.Is_Line_Locked (
                				l_prepayment_invoice_id,
		           			l_prepayment_line_number,
			              		NULL);

     IF l_is_line_locked = 'UNLOCKED' THEN

        l_debug_info := 'Lock the Prepayment Invoice - Item line for this recoupment';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
        l_lock_result := AP_PREPAY_UTILS_PKG.Lock_Line(
		                            l_prepayment_invoice_id,
		                            l_prepayment_line_number,
					    NULL);

     END IF;


     IF(l_lock_result) THEN

	l_debug_info := 'Call AP_Prepay_Pkg.Apply_Prepay_Line';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
	l_success :=
        AP_Prepay_Pkg.Apply_Prepay_Line(
				     P_PREPAY_INVOICE_ID	=> l_prepayment_invoice_id,
       				     P_PREPAY_LINE_NUM		=> l_prepayment_line_number,
				     P_PREPAY_DIST_INFO		=> l_prepay_dist_info,
				     P_PRORATE_FLAG		=> 'Y',
				     P_INVOICE_ID		=> p_invoice_id,
				     P_INVOICE_LINE_NUMBER	=> p_invoice_line_number,
				     P_APPLY_AMOUNT		=> l_amount_to_apply,
				     P_GL_DATE			=> p_accounting_date,
				     P_PERIOD_NAME		=> p_period_name,
				     P_PREPAY_INCLUDED		=> 'N',
				     P_USER_ID			=> p_user_id,
				     P_LAST_UPDATE_LOGIN	=> p_last_update_login,
				     P_CALLING_SEQUENCE		=> l_curr_calling_sequence,
				     P_CALLING_MODE		=> 'RECOUPMENT',
				     P_ERROR_MESSAGE		=> l_error_message);

         IF NOT(l_success) THEN
	   p_error_message := l_error_message;
	   RETURN(l_success);
	 END IF;
     END IF;

  END LOOP;

  CLOSE Prepayment_Invoice_Lines;

  l_debug_info := 'Call to calculate tax';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF NOT (ap_etax_pkg.calling_etax(
	             p_invoice_id             => p_invoice_id
	            ,p_line_number            => p_invoice_line_number
	            ,p_calling_mode           => 'RECOUPMENT'
	            ,p_override_status        => NULL
	            ,p_line_number_to_delete  => NULL
	            ,p_Interface_Invoice_Id   => NULL
	            ,p_all_error_messages     => 'N'
	            ,p_error_code             => p_error_message
	            ,p_calling_sequence       => l_curr_calling_sequence)) THEN

     RAISE tax_exception;

  END IF;


 --Update the prepayment invoice's tax distributions for prepay_amount_remaining
 --after recouped tax distributions have been created.
 --Bugfix:5609186 Starts here
  OPEN c_prepay_dists;

  FETCH c_prepay_dists BULK COLLECT INTO l_prepay_dist_id_list,
                                         l_recoup_amount_list;

  CLOSE c_prepay_dists;

  FORALL i IN l_prepay_dist_id_list.first .. l_prepay_dist_id_list.last
     UPDATE ap_invoice_distributions
     SET prepay_amount_remaining = prepay_amount_remaining + l_recoup_amount_list(i)
     WHERE invoice_distribution_id = l_prepay_dist_id_list(i);

  l_debug_info := 'Update payment schedules with the tax on recouped distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  SELECT sum(aid.amount)
  INTO l_recouped_tax_amount
  FROM ap_invoice_distributions aid,
       ap_invoice_distributions aid1,
       ap_invoice_lines ail
  WHERE aid.invoice_id = p_invoice_id
    AND aid.invoice_line_number = p_invoice_line_number
    AND ail.invoice_id = aid.invoice_id
    AND ail.line_number = aid.invoice_line_number
    AND aid.line_type_lookup_code in ('REC_TAX','NONREC_TAX','TIPV','TRV','TERV')
    AND aid.charge_applicable_to_dist_id = aid1.invoice_distribution_id
    AND aid1.invoice_id = aid.invoice_id
    AND aid1.invoice_line_number = aid.invoice_line_number
    AND aid1.line_type_lookup_code = 'PREPAY';

   l_debug_info := 'Get Apply Amount in Payment Currency l_recouped_tax_amount is '||l_recouped_tax_amount;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   IF (l_recouped_tax_amount IS NOT NULL ) THEN
       IF (l_inv_curr_code <> l_inv_pay_curr_code) THEN

            l_recouped_tax_amt_in_pay_curr :=
                       GL_Currency_API.Convert_Amount (
                                            l_inv_curr_code,
                                            l_inv_pay_curr_code,
                                            l_inv_pay_cross_rate_date,
                                            l_inv_pay_cross_rate_type,
                                            l_recouped_tax_amount);


       ELSE
           l_recouped_tax_amt_in_pay_curr := l_recouped_tax_amount;
       END IF;


       l_debug_info := 'Update Payment Schedules l_recouped_tax_amt_in_pay_curr is '||l_recouped_tax_amt_in_pay_curr;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       l_success := AP_PREPAY_PKG.Update_Payment_Schedule(
                                                    p_invoice_id,
						    l_prepayment_invoice_id,
						    l_prepayment_line_number,
						    (-1)*l_recouped_tax_amt_in_pay_curr,
						    'APPLICATION',
						    l_inv_pay_curr_code,
						    p_user_id,
						    p_last_update_login,
						    l_curr_calling_sequence,
						    'RECOUPMENT',
						    l_error_message);

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_UTILS_PKG.Ap_Recoup_Invoice_Line(-)');
  END IF;

  RETURN(TRUE);

EXCEPTION WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
   FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     l_curr_calling_sequence);
   FND_MESSAGE.SET_TOKEN('PARAMETERS',
              'P_INVOICE_ID        = '||P_INVOICE_ID
	     ||', P_INVOICE_LINE_NUMBER = '||P_INVOICE_LINE_NUMBER
	     ||', P_AMOUNT_TO_RECOUP    = '||P_AMOUNT_TO_RECOUP
             ||', P_USER_ID           = '||P_USER_ID
             ||', P_LAST_UPDATE_LOGIN = '||P_LAST_UPDATE_LOGIN);

   FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

   APP_EXCEPTION.RAISE_EXCEPTION;
END Ap_Recoup_Invoice_Line;


FUNCTION Get_Inv_Line_Recouped_Amount(P_Invoice_Id  IN NUMBER,
				      P_Invoice_Line_Number IN NUMBER) RETURN NUMBER IS
l_recouped_amount  NUMBER;
BEGIN

   l_recouped_amount := 0;
  --Bug 6841613 : For performance reasons, Split the update into 2 different stmts
  --based on the value of parameter p_invoice_line_number.
  IF (p_invoice_line_number IS NOT NULL) THEN

	   SELECT sum(aid.amount)
	   INTO l_recouped_amount
	   FROM ap_invoice_distributions aid,
	        ap_invoice_lines ail
	   WHERE aid.invoice_id = p_invoice_id
	   AND aid.invoice_line_number = p_invoice_line_number
	   AND ail.invoice_id = aid.invoice_id
	   AND ail.line_number = aid.invoice_line_number
	   AND ail.line_type_lookup_code IN ('ITEM', 'RETAINAGE RELEASE')
	   AND aid.parent_reversal_id is null  -- Added for bug #8928639
	   AND (aid.line_type_lookup_code = 'PREPAY'
	        OR (aid.line_type_lookup_code IN ('REC_TAX','NONREC_TAX') and
	            aid.prepay_distribution_id IS NOT NULL)
	        OR (aid.line_type_lookup_code IN ('TIPV','TRV','TERV')
	             and aid.related_id IN (SELECT invoice_distribution_id
	                                    FROM ap_invoice_distributions aid1
	                                    WHERE aid1.invoice_id = aid.invoice_id
        	                            AND aid1.invoice_line_number = aid.invoice_line_number
	                                    AND aid1.line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
                	                    AND aid1.prepay_distribution_id IS NOT NULL)
	           )
	       );
   ELSE

	   SELECT sum(aid.amount)
	   INTO l_recouped_amount
	   FROM ap_invoice_distributions aid,
	        ap_invoice_lines ail
	   WHERE aid.invoice_id = p_invoice_id
	   AND ail.invoice_id = aid.invoice_id
	   AND ail.line_number = aid.invoice_line_number
	   AND ail.line_type_lookup_code IN ('ITEM', 'RETAINAGE RELEASE')
	   AND aid.parent_reversal_id is null  -- Added for bug #8928639
	   AND (aid.line_type_lookup_code = 'PREPAY'
	        OR (aid.line_type_lookup_code IN ('REC_TAX','NONREC_TAX') and
	            aid.prepay_distribution_id IS NOT NULL)
	        OR (aid.line_type_lookup_code IN ('TIPV','TRV','TERV')
	             and aid.related_id IN (SELECT invoice_distribution_id
	                                    FROM ap_invoice_distributions aid1
	                                    WHERE aid1.invoice_id = aid.invoice_id
        	                            AND aid1.invoice_line_number = aid.invoice_line_number
	                                    AND aid1.line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
                	                    AND aid1.prepay_distribution_id IS NOT NULL)
	           )
	       );

   END IF;
   RETURN(NVL(l_recouped_amount, 0));

EXCEPTION WHEN OTHERS THEN
   RETURN(l_recouped_amount);
END Get_Inv_Line_Recouped_Amount;


FUNCTION Get_Recoup_Amt_Per_Prepay_Line(P_Invoice_Id 		IN NUMBER,
					 P_Invoice_Line_Number  IN NUMBER,
					 P_Prepay_Invoice_Id    IN NUMBER,
					 P_Prepay_Line_Number   IN NUMBER) RETURN NUMBER IS
 l_recouped_amount NUMBER;
BEGIN

  l_recouped_amount := 0;

  SELECT sum(aid.amount)
  INTO l_recouped_amount
  FROM ap_invoice_distributions aid
  WHERE aid.invoice_id = p_invoice_id
  AND aid.invoice_line_number = p_invoice_line_number
  AND aid.line_type_lookup_code = 'PREPAY'
  AND aid.prepay_distribution_id IN (SELECT aid1.invoice_distribution_id
  				     FROM ap_invoice_distributions aid1
				     WHERE aid1.invoice_id = p_prepay_invoice_id
				     AND aid1.invoice_line_number = p_prepay_line_number);

   RETURN(l_recouped_amount);

EXCEPTION WHEN OTHERS THEN
  return (l_recouped_amount);
END Get_Recoup_Amt_Per_Prepay_Line;



FUNCTION Get_Recoup_Tax_Amt_Per_Ppay_Ln(P_Invoice_Id 		IN NUMBER,
				          P_Invoice_Line_Number IN NUMBER,
					  P_Prepay_Invoice_Id   IN NUMBER,
					  P_Prepay_Line_Number  IN NUMBER) RETURN NUMBER IS
  l_recouped_tax_amount NUMBER;
BEGIN

  l_recouped_tax_amount := 0;

  SELECT sum(aid.amount)
  INTO l_recouped_tax_amount
  FROM ap_invoice_distributions aid
  WHERE aid.invoice_id = p_invoice_id
  AND aid.invoice_line_number = p_invoice_line_number
  AND
     ((aid.line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
      and aid.prepay_distribution_id IN (SELECT aid1.invoice_distribution_id
                       FROM ap_invoice_distributions aid1
                     WHERE aid1.invoice_id = p_prepay_invoice_id
                     AND aid1.invoice_line_number = p_prepay_line_number)
      ) OR
      (aid.line_type_lookup_code IN ('TIPV','TRV','TERV')
       and aid.related_id IN (SELECT invoice_distribution_id
                   FROM ap_invoice_distributions aid2
                   WHERE aid2.invoice_id = aid.invoice_id
                   AND aid2.invoice_line_number = aid.invoice_line_number
                   AND aid2.line_type_lookup_code IN ('REC_TAX','NONREC_TAX')
                   AND aid2.prepay_distribution_id IN
                                   (SELECT aid4.invoice_distribution_id
                                             FROM ap_invoice_distributions aid4
                                 WHERE aid4.invoice_id = p_prepay_invoice_id
                                 AND aid4.invoice_line_number = p_prepay_line_number)
                               )
      )
     );

  RETURN(l_recouped_tax_amount);

EXCEPTION WHEN OTHERS THEN
  RETURN(l_recouped_tax_amount);

END Get_Recoup_Tax_Amt_Per_Ppay_Ln;


Procedure Match_To_Rcv_Shipment_Line(P_Invoice_Id          IN NUMBER,
				     P_Invoice_Line_Number IN NUMBER,
				     P_Calling_Sequence    IN VARCHAR2) IS

 CURSOR C_Rcv_Transactions (p_rcv_shipment_line_id IN NUMBER) IS
   SELECT rcv.transaction_id,
	  pll.matching_basis,
	  pll.line_location_id
   FROM rcv_transactions rcv,
   	rcv_shipment_lines rsl,
	po_line_locations pll
   WHERE rcv.shipment_line_id = rsl.shipment_line_id
   AND rsl.shipment_line_id = p_rcv_shipment_line_id
   AND pll.line_location_id = rcv.po_line_location_id
   AND rcv.transaction_type IN ('RECEIVE','MATCH');

 CURSOR C_Deliver_Transactions(p_rcv_transaction_id IN NUMBER) IS
     SELECT po_distribution_id
     FROM
       rcv_transactions
     WHERE
       transaction_type = 'DELIVER'
     START WITH transaction_id = p_rcv_transaction_id
     CONNECT BY parent_transaction_id = PRIOR transaction_id
                AND PRIOR transaction_type <> 'DELIVER';

 l_dist_tab	    	    AP_MATCHING_PKG.DIST_TAB_TYPE;

 l_rcv_shipment_line_id     RCV_SHIPMENT_LINES.SHIPMENT_LINE_ID%TYPE;
 l_po_line_location_id	    PO_LINE_LOCATIONS.LINE_LOCATION_ID%TYPE;
 l_total_match_quantity	    NUMBER;
 l_total_match_amount	    NUMBER;

 l_match_unit_price	    NUMBER;
 l_match_quantity  NUMBER;
 l_match_amount    NUMBER;
 l_rcv_transaction_id	    RCV_TRANSACTIONS.TRANSACTION_ID%TYPE;
 l_matching_basis	    PO_LINE_LOCATIONS.MATCHING_BASIS%TYPE;
 l_invoice_currency_code    AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
 l_invoice_type_lookup_code AP_INVOICES.INVOICE_TYPE_LOOKUP_CODE%TYPE;
 l_unit_meas_lookup_code    AP_INVOICE_LINES.UNIT_MEAS_LOOKUP_CODE%TYPE;
 l_retained_amount	    AP_INVOICE_LINES.RETAINED_AMOUNT%TYPE;
 l_match_type		    AP_INVOICE_LINES.MATCH_TYPE%TYPE;
 l_po_distribution_id	    PO_DISTRIBUTIONS.PO_DISTRIBUTION_ID%TYPE;
 l_match_mode		    VARCHAR2(30);

 l_ordered_po_qty           NUMBER;
 l_cancelled_po_qty         NUMBER;
 l_delivered_po_qty         NUMBER;
 l_returned_po_qty          NUMBER;
 l_corrected_po_qty         NUMBER;
 l_ordered_txn_qty          NUMBER;
 l_cancelled_txn_qty        NUMBER;
 l_delivered_txn_qty        NUMBER;
 l_returned_txn_qty         NUMBER;
 l_corrected_txn_qty        NUMBER;
 l_billed_txn_qty	    NUMBER;

 l_ordered_qty		    NUMBER;
 l_cancelled_qty	    NUMBER;
 l_received_qty		    NUMBER;
 l_corrected_qty	    NUMBER;
 l_delivered_qty	    NUMBER;
 l_transaction_qty 	    NUMBER;
 l_billed_qty		    NUMBER;
 l_accepted_qty		    NUMBER;
 l_rejected_qty		    NUMBER;

 l_amount_delivered	    NUMBER;
 l_amount_corrected	    NUMBER;
 l_amount_ordered	    NUMBER;
 l_amount_cancelled	    NUMBER;
 l_amount_billed	    NUMBER;
 l_amount_received	    NUMBER;
 l_ret_status               VARCHAR2(100);
 l_msg_count                NUMBER;
 l_msg_data                 VARCHAR2(250);

 l_debug_info 		    VARCHAR2(1000);
 l_current_calling_sequence VARCHAR2(2000);

BEGIN

  l_current_calling_sequence := 'AP_Matching_Utils_Pkg.Match_To_Rcv_Shipment_Line <-' ||p_calling_sequence;

  l_debug_info := 'Get Invoice and Invoice Line info';

  SELECT ail.rcv_shipment_line_id,
  	 ail.quantity_invoiced,
	 ail.amount,
	 ail.unit_price,
	 ai.invoice_currency_code,
	 ai.invoice_type_lookup_code,
	 ail.unit_meas_lookup_code,
	 ail.retained_amount,
	 ail.match_type,
	 ail.po_distribution_id
  INTO l_rcv_shipment_line_id,
       l_total_match_quantity,
       l_total_match_amount,
       l_match_unit_price,
       l_invoice_currency_code,
       l_invoice_type_lookup_code,
       l_unit_meas_lookup_code,
       l_retained_amount,
       l_match_type,
       l_po_distribution_id
  FROM ap_invoice_lines_all ail,
       ap_invoices ai
  WHERE ai.invoice_id = p_invoice_id
  AND ail.invoice_id = ai.invoice_id
  AND ail.line_number = p_invoice_line_number;

  l_debug_info := 'Derive Match_Mode';
  IF (l_match_type IN ('ITEM_TO_RECEIPT','ITEM_TO_SERVICE_RECEIPT')) THEN

     IF (SIGN(l_total_match_amount) < 0) THEN
       l_match_mode := 'CR-';
     ELSE
       l_match_mode := 'STD-';
     END IF;

     IF (l_po_distribution_id IS NULL) THEN
       l_match_mode := l_match_mode||'PS';
     ELSE
       l_match_mode := l_match_mode||'PD';
     END IF;

  END IF;


  IF (l_match_mode IN ('STD-PS','STD-PD')) THEN
     l_debug_info := 'Open C_Rcv_Transactions cursor';
     OPEN c_rcv_transactions(l_rcv_shipment_line_id);

     LOOP

        FETCH C_Rcv_Transactions INTO l_rcv_transaction_id,
	   			   l_matching_basis,
				   l_po_line_location_id;
        EXIT WHEN C_Rcv_Transactions%NOTFOUND OR l_total_match_amount = 0
		  OR l_total_match_quantity = 0;


        OPEN C_Deliver_Transactions(l_rcv_transaction_id);

        LOOP

           FETCH C_Deliver_Transactions INTO l_po_distribution_id;

    	   EXIT WHEN C_Deliver_Transactions%NOTFOUND OR l_total_match_quantity <= 0 OR l_total_match_amount <= 0;

           IF (l_matching_basis = 'QUANTITY') THEN

   	       RCV_INVOICE_MATCHING_SV.Get_Delivered_Quantity(
			   rcv_transaction_id     => l_rcv_transaction_id,
                           p_distribution_id      => l_po_distribution_id,
                           ordered_po_qty         => l_ordered_po_qty,
                           cancelled_po_qty       => l_cancelled_po_qty,
                           delivered_po_qty       => l_delivered_po_qty,
                           returned_po_qty        => l_returned_po_qty,
                           corrected_po_qty       => l_corrected_po_qty,
                           ordered_txn_qty        => l_ordered_txn_qty,
                           cancelled_txn_qty      => l_cancelled_txn_qty,
                           delivered_txn_qty      => l_delivered_txn_qty,
                           returned_txn_qty       => l_returned_txn_qty,
                           corrected_txn_qty      => l_corrected_txn_qty);

               AP_MATCHING_UTILS_PKG.Get_Recpt_Dist_Qty_Billed (
                        l_rcv_transaction_id,
                        l_po_distribution_id,
                        l_billed_txn_qty);

               l_billed_txn_qty := nvl(l_billed_txn_qty,0);

               l_delivered_txn_qty := nvl(l_delivered_txn_qty,0)
                                + nvl(l_corrected_txn_qty,0)
                                 - nvl(l_returned_txn_qty,0);

               l_ordered_txn_qty :=  nvl(l_ordered_txn_qty,0)
                                - nvl(l_cancelled_txn_qty,0);

               IF (l_total_match_quantity >= (l_delivered_txn_qty - l_billed_txn_qty)) THEN

		  l_match_quantity := l_delivered_txn_qty - l_billed_txn_qty;

   	       ELSE

		  l_match_quantity := l_total_match_quantity;

               END IF;

   	       l_match_amount := ap_utilities_pkg.ap_round_currency(l_match_quantity*l_match_unit_price,
								 l_invoice_currency_code);

   	       l_total_match_quantity := l_total_match_quantity - l_match_quantity;
	       l_total_match_amount := l_total_match_amount - l_match_amount;

               l_debug_info := 'Call Receipt Matching Api';
	       AP_RECT_MATCH_PKG.Base_Credit_Rcv_Match(X_Match_Mode 	  => l_match_mode,
						    X_Invoice_Id 	  => p_invoice_id,
						    X_Invoice_Line_Number => p_invoice_line_number,
						    X_Po_Line_Location_Id => l_po_line_location_id,
						    X_Rcv_Transaction_Id  => l_rcv_transaction_id,
						    X_Dist_Tab		  => l_dist_tab,
						    X_Amount		  => l_match_amount,
						    X_Quantity		  => l_match_quantity,
						    X_Unit_Price	  => l_match_unit_price,
						    X_Uom_Lookup_Code	  => l_unit_meas_lookup_code,
						    X_freight_cost_factor_id => NULL,
                            			    X_freight_amount      => NULL,
                            			    X_freight_description => NULL,
                            			    X_misc_cost_factor_id => NULL,
			                            X_misc_amount         => NULL,
                        			    X_misc_description    => NULL,
                        		            X_retained_amount     => l_retained_amount,
						    X_Calling_Sequence    => l_current_calling_sequence);


            ELSIF l_matching_basis = 'AMOUNT' THEN

               RCV_INVOICE_MATCHING_SV.get_DeliverAmount(
                        p_api_version   => 1.0,
                        p_init_msg_list => FND_API.G_TRUE,
                        x_return_status => l_ret_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_receive_transaction_id => l_rcv_transaction_id,
                        p_po_distribution_id     => l_po_distribution_id,
                        x_delivered_amt => l_amount_delivered,
                        x_corrected_amt => l_amount_corrected);

	       AP_MATCHING_UTILS_PKG.Get_Recpt_Dist_Amt_Billed (
                           l_rcv_transaction_id,
                           l_po_distribution_id,
                           l_amount_billed);

               l_amount_billed := nvl(l_amount_billed,0);

               l_amount_delivered := nvl(l_amount_delivered,0) + nvl(l_amount_corrected,0);

	       IF (l_total_match_amount >= (l_amount_delivered - l_amount_billed)) THEN

		  l_match_amount := l_amount_delivered - l_amount_billed;
		  l_match_quantity := ROUND(((l_amount_delivered - l_amount_billed) / l_match_unit_price),15);

 	       ELSE

		  l_match_amount := l_total_match_amount;
		  l_match_quantity := ROUND((l_total_match_amount/l_match_unit_price),15);

               END IF;

	       l_total_match_quantity := l_total_match_quantity - l_match_quantity;
	       l_total_match_amount := l_total_match_amount - l_match_amount;

               l_debug_info := 'Call Receipt Matching api for service orders';

 	       AP_RCT_AMT_MATCH_PKG.AP_AMT_MATCH(
				X_match_mode          => l_match_mode,
                   		X_invoice_id          => p_invoice_id,
                   		X_invoice_line_number => p_invoice_line_number,
                   		X_dist_tab            => l_dist_tab,
                   		X_po_line_location_id => l_po_line_location_id,
                   		X_rcv_transaction_id  => l_rcv_transaction_id,
                   		X_amount              => l_match_amount,
                   		X_quantity            => l_match_quantity,
                   		X_unit_price          => l_match_unit_price,
                   		X_uom_lookup_code     => l_unit_meas_lookup_code,
                   		X_freight_cost_factor_id => NULL,
                   		X_freight_amount      => NULL,
                   		X_freight_description => NULL,
                   		X_misc_cost_factor_id => NULL,
                   		X_misc_amount         => NULL,
                   		X_misc_description    => NULL,
                   		X_retained_amount     => l_retained_amount,
                   		X_calling_sequence    => l_current_calling_sequence);

           END IF;

        END LOOP;

        CLOSE C_Deliver_Transactions;

     END LOOP;

     CLOSE C_Rcv_Transactions;

  END IF; /* l_match_mode IN ...*/

  --If match_quantity or amount is still not used up by the
  --deliver transactions above, then we prorate the remaining
  --quantity/amount across all the rcv_transactions based on O-B ??

  IF ((l_match_mode IN ('CR-PS','CR-PD')) OR
      (l_matching_basis = 'QUANTITY' and l_total_match_quantity > 0 ) OR
      (l_matching_basis = 'AMOUNT' and l_total_match_amount > 0)) THEN

     OPEN C_Rcv_Transactions(l_rcv_shipment_line_id);

     LOOP

	FETCH C_Rcv_Transactions INTO l_rcv_transaction_id,
				      l_matching_basis,
				      l_po_line_location_id;

	EXIT WHEN (C_Rcv_Transactions%NOTFOUND or
		   l_total_match_quantity = 0 OR l_total_match_amount = 0);

	IF (l_matching_basis = 'QUANTITY') THEN

	   AP_MATCHING_UTILS_PKG.Get_receipt_Quantities(
                        l_rcv_transaction_id,
                        l_ordered_qty,
                        l_cancelled_qty,
                        l_received_qty,
                        l_corrected_qty,
                        l_delivered_qty,
                        l_transaction_qty,
                        l_billed_qty,
                        l_accepted_qty,
                        l_rejected_qty);

    	   l_billed_qty := nvl(l_billed_qty,0);
     	   l_delivered_qty := nvl(l_delivered_qty,0);
   	   l_cancelled_qty := nvl(l_cancelled_qty,0);
   	   l_ordered_qty := nvl(l_ordered_qty,0);

	   IF (l_match_mode IN ('STD-PS','STD-PD')) THEN

	      IF ((l_ordered_qty - l_cancelled_qty - l_billed_qty) > 0) THEN

   	         IF (l_total_match_quantity >= (l_ordered_qty - l_cancelled_qty - l_billed_qty)) THEN
		    l_match_quantity := l_ordered_qty - l_cancelled_qty - l_billed_qty;
		    l_match_amount := ap_utilities_pkg.ap_round_currency(l_match_quantity * l_match_unit_price,l_invoice_currency_code);
	         ELSE
		    l_match_quantity := l_total_match_quantity;
		    l_match_amount := ap_utilities_pkg.ap_round_currency(l_match_quantity * l_match_unit_price,l_invoice_currency_code);
	         END IF;

	      /* For overbill cases, for positive invoices we go off of ordered qty*/
	      ELSE

		IF (l_total_match_quantity >= l_ordered_qty - l_cancelled_qty) THEN
		   l_match_quantity := l_ordered_qty - l_cancelled_qty;
		   l_match_amount := ap_utilities_pkg.ap_round_currency(l_match_quantity * l_match_unit_price,l_invoice_currency_code);
		ELSE
		   l_match_quantity := l_total_match_quantity;
		   l_match_amount := ap_utilities_pkg.ap_round_currency(l_match_quantity * l_match_unit_price,l_invoice_currency_code);
		END IF;

	      END IF;

           ELSE /*For Credit/Debit memos */

		IF (l_total_match_quantity >= l_billed_qty) THEN
		   l_match_quantity := -1*l_billed_qty;
		   l_match_amount := ap_utilities_pkg.ap_round_currency(l_match_quantity * l_match_unit_price,l_invoice_currency_code);
		ELSE
		   l_match_quantity := l_total_match_quantity;
		   l_match_amount := ap_utilities_pkg.ap_round_currency(l_match_quantity * l_match_unit_price,l_invoice_currency_code);
		END IF;

	   END IF;

	   l_total_match_quantity := l_total_match_quantity - l_match_quantity;
	   l_total_match_amount := l_total_match_amount - l_match_amount;

	   l_debug_info := 'Call Receipt Matching api';

	   AP_RECT_MATCH_PKG.Base_Credit_Rcv_Match(X_Match_Mode 	  => l_match_mode,
						    X_Invoice_Id 	  => p_invoice_id,
						    X_Invoice_Line_Number => p_invoice_line_number,
						    X_Po_Line_Location_Id => l_po_line_location_id,
						    X_Rcv_Transaction_Id  => l_rcv_transaction_id,
						    X_Dist_Tab		  => l_dist_tab,
						    X_Amount		  => l_match_amount,
						    X_Quantity		  => l_match_quantity,
						    X_Unit_Price	  => l_match_unit_price,
						    X_Uom_Lookup_Code	  => l_unit_meas_lookup_code,
						    X_freight_cost_factor_id => NULL,
                            			    X_freight_amount      => NULL,
                            			    X_freight_description => NULL,
                            			    X_misc_cost_factor_id => NULL,
			                            X_misc_amount         => NULL,
                        			    X_misc_description    => NULL,
                        		            X_retained_amount     => l_retained_amount,
						    X_Calling_Sequence    => l_current_calling_sequence);

	ELSIF (l_matching_basis = 'AMOUNT') THEN

	   RCV_INVOICE_MATCHING_SV.Get_ReceiveAmount(
                        p_api_version   => 1.0,
                        p_init_msg_list => FND_API.G_TRUE,
                        x_return_status => l_ret_status,
                        x_msg_count     => l_msg_count,
                        x_msg_data      => l_msg_data,
                        p_receive_transaction_id => l_rcv_transaction_id,
                        x_billed_amt  => l_amount_billed,
                        x_received_amt => l_amount_received,
                        x_delivered_amt => l_amount_delivered,
                        x_corrected_amt => l_amount_corrected);

           PO_AP_INVOICE_MATCH_GRP.Get_po_ship_amounts(
			p_api_version   => 1.0,
                        p_receive_transaction_id        => l_rcv_transaction_id,
                        x_ship_amt_ordered              => l_amount_ordered,
                        x_ship_amt_cancelled            => l_amount_cancelled,
                        x_ret_status                    => l_ret_status,
                        x_msg_count                     => l_msg_count,
                        x_msg_data                      => l_msg_data);

	   l_amount_billed := nvl(l_amount_billed,0);
           l_amount_delivered := nvl(l_amount_delivered,0);
           l_amount_cancelled := nvl(l_amount_cancelled,0);

	   IF (l_match_mode IN ('STD-PS','STD-PD')) THEN

	      IF (l_amount_ordered - l_amount_cancelled - l_amount_billed > 0) THEN

	         IF (l_total_match_amount >= l_amount_ordered - l_amount_cancelled - l_amount_billed) THEN
                    l_match_amount := l_amount_ordered - l_amount_cancelled - l_amount_billed;
	         ELSE
	            l_match_amount := l_total_match_amount;
	         END IF;

	      /* For the overbill cases */
	      ELSE

		 IF (l_total_match_amount >= l_amount_ordered - l_amount_cancelled) THEN
		    l_match_amount := l_amount_ordered - l_amount_cancelled;
		 ELSE
		    l_match_amount := l_total_match_amount;
		 END IF;

	      END IF;

	   ELSE /*For Credit/Debit memos */

	      IF (l_total_match_amount >= l_amount_billed) THEN
		  l_match_amount := -1*l_amount_billed;
	      ELSE
		  l_match_amount := l_total_match_amount;
	      END IF;

	   END IF; /* l_match_mode IN 'STD-PS' ...*/

           l_match_quantity := ROUND(l_match_amount/l_match_unit_price,15);

	   l_total_match_amount := l_total_match_amount - l_match_amount;
	   l_total_match_quantity := l_total_match_quantity - l_match_quantity;

           l_debug_info := 'Call Receipt Matching api for service orders';
           AP_RCT_AMT_MATCH_PKG.AP_AMT_MATCH(
				X_match_mode          => l_match_mode,
                   		X_invoice_id          => p_invoice_id,
                   		X_invoice_line_number => p_invoice_line_number,
                   		X_dist_tab            => l_dist_tab,
                   		X_po_line_location_id => l_po_line_location_id,
                   		X_rcv_transaction_id  => l_rcv_transaction_id,
                   		X_amount              => l_match_amount,
                   		X_quantity            => l_match_quantity,
                   		X_unit_price          => l_match_unit_price,
                   		X_uom_lookup_code     => l_unit_meas_lookup_code,
                   		X_freight_cost_factor_id => NULL,
                   		X_freight_amount      => NULL,
                   		X_freight_description => NULL,
                   		X_misc_cost_factor_id => NULL,
                   		X_misc_amount         => NULL,
                   		X_misc_description    => NULL,
                   		X_retained_amount     => l_retained_amount,
                   		X_calling_sequence    => l_current_calling_sequence);

        END IF;  /* l_matching_basis */

     END LOOP;

     CLOSE C_Rcv_Transactions;

  END IF;  /* l_match_mode = 'STD-PS' OR l_total_match_quantity > 0 OR ... */

EXCEPTION WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
                          ' X_Invoice_Id = '||TO_CHAR(P_Invoice_id)
                          ||', X_Invoice_Line_Number = '||TO_CHAR(P_Invoice_Line_Number));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Match_To_Rcv_Shipment_Line;



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
|                                this parameter for a Receipt Ship Line.
|
|  MODIFICATION HISTORY
|    DATE          Author         Action
|    09/27/06    dgulraja        Created
|    09-Nov-09     sjetti        Modified for bug 8881382 to prevent overbill
|                                of receipt returns.
|
*============================================================================*/
FUNCTION Get_rcv_ship_qty_amt(p_rcv_shipment_line_id    IN NUMBER,
                              p_matching_basis          IN VARCHAR2,
                              p_returned_item           IN VARCHAR2)
RETURN NUMBER IS

 CURSOR C_Rcv_Transactions (p_rcv_shipment_line_id IN NUMBER) IS
 SELECT rcv.transaction_id,
	    pll.matching_basis,
	    pll.line_location_id
  FROM rcv_transactions rcv,
   	   rcv_shipment_lines rsl,
	   po_line_locations pll
 WHERE rcv.shipment_line_id = rsl.shipment_line_id
   AND rsl.shipment_line_id = p_rcv_shipment_line_id
   AND pll.line_location_id = rcv.po_line_location_id
   AND rcv.transaction_type IN ('RECEIVE','MATCH');

l_po_line_location_id	PO_LINE_LOCATIONS.LINE_LOCATION_ID%TYPE;
l_rcv_transaction_id	RCV_TRANSACTIONS.TRANSACTION_ID%TYPE;
l_matching_basis	    PO_LINE_LOCATIONS.MATCHING_BASIS%TYPE;
l_po_distribution_id	PO_DISTRIBUTIONS.PO_DISTRIBUTION_ID%TYPE;

l_ordered_qty		    NUMBER;
l_cancelled_qty	        NUMBER;
l_received_qty		    NUMBER;
l_corrected_qty	        NUMBER;
l_delivered_qty	        NUMBER;
l_transaction_qty 	    NUMBER;
l_billed_qty		    NUMBER;
l_accepted_qty		    NUMBER;
l_rejected_qty		    NUMBER;

l_amount_delivered	    NUMBER;
l_amount_corrected	    NUMBER;
l_amount_ordered	    NUMBER;
l_amount_cancelled	    NUMBER;
l_amount_billed	        NUMBER;
l_amount_received	    NUMBER;
l_ret_status            VARCHAR2(100);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(250);

l_debug_info 		    VARCHAR2(1000);
l_current_calling_sequence VARCHAR2(2000);

l_total_ordered_qty     NUMBER;
l_total_cancelled_qty   NUMBER;
l_total_billed_qty      NUMBER;
l_total_delivered_qty   NUMBER;
l_total_amount_billed   NUMBER;
l_total_amount_cancelled NUMBER;
l_total_amount_ordered  NUMBER;
l_total_received_qty  NUMBER;
l_total_received_Amount NUMBER;


BEGIN

	l_current_calling_sequence := 'AP_Matching_Utils_Pkg. Get_qty_amt <-' ;
	l_total_ordered_qty     := 0;
	l_total_cancelled_qty   := 0;
	l_total_billed_qty      := 0;
	l_total_delivered_qty   := 0;
	l_total_amount_billed   := 0;
	l_total_amount_cancelled := 0;
	l_total_amount_ordered  := 0;
	l_total_received_qty    := 0;
    l_total_received_Amount := 0;

    l_debug_info := 'Open C_Rcv_Transactions cursor';
    OPEN c_rcv_transactions(p_rcv_shipment_line_id);
    LOOP
       FETCH C_Rcv_Transactions
       INTO l_rcv_transaction_id,
   	     l_matching_basis,
            l_po_line_location_id;
       EXIT WHEN C_Rcv_Transactions%NOTFOUND;

       IF (l_matching_basis = 'QUANTITY') THEN

           AP_MATCHING_UTILS_PKG.Get_receipt_Quantities(
                   l_rcv_transaction_id,
                   l_ordered_qty,
                   l_cancelled_qty,
                   l_received_qty,
                   l_corrected_qty,
                   l_delivered_qty,
                   l_transaction_qty,
                   l_billed_qty,
                   l_accepted_qty,
                   l_rejected_qty);


   	    l_billed_qty := nvl(l_billed_qty,0);
  	        l_cancelled_qty := nvl(l_cancelled_qty,0);
  	        l_ordered_qty := nvl(l_ordered_qty,0);
  	         l_received_qty := nvl(l_received_qty,0);
             l_delivered_qty := nvl(l_delivered_qty,0); --Bug 8881382

       ELSIF l_matching_basis = 'AMOUNT' THEN

           RCV_INVOICE_MATCHING_SV.Get_ReceiveAmount(
                  p_api_version   => 1.0,
                  p_init_msg_list => FND_API.G_TRUE,
                  x_return_status => l_ret_status,
                  x_msg_count     => l_msg_count,
                  x_msg_data      => l_msg_data,
                  p_receive_transaction_id => l_rcv_transaction_id,
                  x_billed_amt  => l_amount_billed,
                  x_received_amt => l_amount_received,
                  x_delivered_amt => l_amount_delivered,
                  x_corrected_amt => l_amount_corrected);

           PO_AP_INVOICE_MATCH_GRP.Get_po_ship_amounts(
                  p_api_version   => 1.0,
                  p_receive_transaction_id        => l_rcv_transaction_id,
                  x_ship_amt_ordered              => l_amount_ordered,
                  x_ship_amt_cancelled            => l_amount_cancelled,
                  x_ret_status                    => l_ret_status,
                  x_msg_count                     => l_msg_count,
                  x_msg_data                      => l_msg_data);

           l_amount_ordered := nvl(l_amount_ordered, 0);
        l_amount_billed := nvl(l_amount_billed,0);
           l_amount_cancelled := nvl(l_amount_cancelled,0);
            l_amount_received := nvl(l_amount_received, 0);

        END IF;

	l_total_ordered_qty := l_ordered_qty + l_total_ordered_qty;
	l_total_billed_qty :=  l_billed_qty +  l_total_billed_qty;
	l_total_cancelled_qty := l_cancelled_qty + l_total_cancelled_qty;

	l_total_amount_ordered :=  l_amount_ordered +  l_total_amount_ordered;
	l_total_amount_billed :=  l_amount_billed +  l_total_amount_billed;
	l_total_amount_cancelled :=  l_amount_cancelled +  l_total_amount_cancelled;

	l_total_received_qty := l_received_qty + l_total_received_qty;
    l_total_delivered_qty := l_delivered_qty + l_total_delivered_qty;  --Bug 8881382
    l_total_received_Amount :=  l_amount_received +  l_total_received_Amount;
    END LOOP;
    CLOSE C_Rcv_Transactions;

    IF p_returned_item = 'QUANTITY_BILLED' THEN
       RETURN l_total_billed_qty;
    ELSIF  p_returned_item = 'QUANTITY_RECEIVED' THEN
       RETURN  l_total_delivered_qty; --Bug 8881382
    ELSIF  p_returned_item = 'AMOUNT_BILLED' THEN
       RETURN l_total_amount_billed;
    ELSIF   p_returned_item = 'AMOUNT_RECEIVED' THEN
       RETURN l_total_received_amount;
    ELSIF   p_returned_item = 'QUANTITY_UNBILLED' THEN
       RETURN  l_total_received_qty - l_total_cancelled_qty - l_total_billed_qty;
    ELSIF   p_returned_item = 'AMOUNT_UNBILLED' THEN
       RETURN   l_total_received_amount -   l_total_amount_cancelled -  l_total_amount_billed ;
    END IF;


EXCEPTION WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
                          ' p_rcv_shipment_line_id = '||TO_CHAR(p_rcv_shipment_line_id));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END;

--Introduced below procedure for bug#10062826

Procedure Get_Num_Rect_Dists (
		P_rcv_transaction_id	IN	NUMBER,
		P_num_rect_po_dists	OUT NOCOPY NUMBER) IS

   Begin

	 SELECT count(*)
         INTO  P_num_rect_po_dists
         FROM po_distributions_all pod,
              rcv_transactions rt
         WHERE rt.transaction_id  =P_rcv_transaction_id
           and rt.po_line_location_id = pod.line_location_id
           and (rt.po_distribution_id  is null
                or rt.po_distribution_id = pod.po_distribution_id);

End Get_Num_Rect_Dists;





END AP_MATCHING_UTILS_PKG;


/
