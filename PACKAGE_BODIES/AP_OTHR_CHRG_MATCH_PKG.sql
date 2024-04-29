--------------------------------------------------------
--  DDL for Package Body AP_OTHR_CHRG_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_OTHR_CHRG_MATCH_PKG" AS
/* $Header: apothmtb.pls 120.20.12010000.3 2010/02/08 09:40:30 baole ship $ */


/*
Procedure OTHR_CHRG_MATCH does the actual matching (linking) of a
standard Invoice/ CM/DM to a particular rcv transaction. It creates the
actual Charge Lines in AP_INVOICE_LINES and 1 invoice distribution
per charge line in AP_INVOICE_DISTRIBUTIONS and stores the associated
rcv_transaction_id for that line. One Charge Invoice line will be created
in AP_INVOICE_LINES for Receipt/Receipt Line the user selects to match to
in the Other Charge Matching Window. Invoice Distributions will be generated
immediately during the matching, 1 per invoice line.

Either the total amount is prorated (if
prorate_flag is 'Y') or the user specified amounts are stored for each
rcv_transaction_id checked in the form. No allocations will be created
for this charge line .


Description of the input parameters:
------------------------------------

X_invoice_id            Id of Invoice that needs to be matched(CM or STD)
X_invoice_line_number   Invoice Line number when the charge match is done
                        from a invoice line or from the import.
X_line_type             Line Type of the charge line. Can be either
                        FREIGHT or MISC
X_prorate_flag          Flag which indicates whether x_total amount needs
                        to be prorated across all the rcv_transactions
X_account_id            The dist_code_combination_id to be used when creating
                        the distributions.  Can be NULL.
X_description           Description to be stored on the invoice distributions
X_total_amount          The total amount that needs to be matched(linked)
                        to the receipts
X_othr_chrg_tab         Pl/SQL table containing the rcv_transaction_id,
                        charge_amount and rcv_transaction_qty for each
                        row checked in the form.
X_row_count             Number of rows in thr pl/sql table
X_calling_sequence      Calling Sequence   */

--Local Procedures
Procedure Get_Info(x_invoice_id	      IN NUMBER,
		   x_calling_sequence IN VARCHAR2);

Procedure Create_Invoice_Lines(x_invoice_id	IN	NUMBER,
        		       x_line_type	IN	VARCHAR2,
			       x_cost_factor_id IN      NUMBER,
           		       x_othr_chrg_tab 	IN OUT NOCOPY	OTHR_CHRG_MATCH_TABTYPE,
           		       x_row_count	IN	NUMBER,
           		       x_description	IN	VARCHAR2,
           		       x_ccid		IN	NUMBER,
           		       x_total_amount	IN	NUMBER,
           		       x_calling_sequence IN	VARCHAR2);

Procedure Insert_Invoice_Line( x_invoice_id  		IN NUMBER,
       			       x_invoice_line_number 	IN NUMBER,
       			       x_line_type		IN VARCHAR2,
			       x_cost_factor_id         IN NUMBER,
       			       x_amount			IN NUMBER,
       			       x_base_amount 		IN NUMBER,
			       x_rounding_amt		IN NUMBER,
       			       x_rcv_transaction_id 	IN NUMBER,
			       x_ccid			IN NUMBER,
			       x_description		IN VARCHAR2,
       			       x_calling_sequence   	IN VARCHAR2);

Procedure Insert_Invoice_dist (X_invoice_id		IN	NUMBER,
			       X_invoice_line_number	IN	NUMBER,
			       X_description		IN	VARCHAR2,
			       X_calling_sequence	IN	VARCHAR2) ;

Procedure Get_Proration_Info(X_Othr_Chrg_Tab    IN OUT NOCOPY OTHR_CHRG_MATCH_TABTYPE,
			     X_Total_Amount     IN    	    NUMBER,
			     X_Prorate_Flag     IN	    VARCHAR2,
			     X_Row_Count	IN	    NUMBER,
			     X_Calling_Sequence IN	    VARCHAR2);

--Global Variables

g_vendor_id		ap_invoices.vendor_id%TYPE;
g_vendor_site_id	ap_invoices.vendor_site_id%TYPE;
g_invoice_date		ap_invoices.invoice_date%TYPE;
g_batch_id 		ap_batches.batch_id%TYPE;
g_max_invoice_line_number ap_invoice_lines.line_number%TYPE;
g_invoice_currency_code ap_invoices.invoice_currency_code%TYPE;
g_exchange_rate		ap_invoices.exchange_rate%TYPE;
g_base_currency_code    ap_system_parameters.base_currency_code%TYPE;
g_accounting_date	ap_invoices.gl_date%TYPE;
g_period_name		gl_period_statuses.period_name%TYPE;
g_set_of_books_id	ap_invoices.set_of_books_id%TYPE;
g_type_1099		po_vendors.type_1099%TYPE;
g_income_tax_region	ap_system_parameters.income_tax_region%TYPE;
g_allow_pa_override	VARCHAR2(1);
g_pa_expenditure_date_default   VARCHAR2(50);
g_approval_workflow_flag ap_system_parameters.approval_workflow_flag%TYPE;
g_asset_book_type_code  fa_book_controls.book_type_code%TYPE;
g_transfer_flag		ap_system_parameters.transfer_desc_flex_flag%TYPE;
g_user_id		number;
g_login_id		number;
g_trx_business_category ap_invoices.trx_business_category%TYPE;
G_Org_Id			ap_invoices.org_id%TYPE;
G_intended_use                  zx_lines_det_factors.line_intended_use%type;
G_product_type                  zx_lines_det_factors.product_type%type;
G_product_category              zx_lines_det_factors.product_category%type;
G_product_fisc_class            zx_lines_det_factors.product_fisc_classification%type;
G_user_defined_fisc_class       zx_lines_det_factors.user_defined_fisc_class%type;
G_assessable_value              zx_lines_det_factors.assessable_value%type;
G_dflt_tax_class_code           zx_transaction_lines_gt.input_tax_classification_code%type;


Procedure OTHR_CHRG_MATCH (
		X_invoice_id		IN	NUMBER,
		X_invoice_line_number	IN	NUMBER,
		X_line_type		IN	VARCHAR2,
		X_cost_factor_id        IN      NUMBER DEFAULT NULL,
		X_prorate_flag		IN	VARCHAR2,
		X_account_id		IN	NUMBER,
		X_description		IN	VARCHAR2,
		X_total_amount		IN	NUMBER,
		X_othr_chrg_tab		IN	OTHR_CHRG_MATCH_TABTYPE,
		X_row_count		IN	NUMBER,
		X_calling_sequence	IN	VARCHAR2) IS

l_total_rcv_qty		NUMBER := 0;
I			NUMBER;
l_charge_amount		NUMBER;
l_charge_base_amount	NUMBER;
l_othr_chrg_tab		OTHR_CHRG_MATCH_TABTYPE := x_othr_chrg_tab;
l_ref_doc_application_id      zx_transaction_lines_gt.ref_doc_application_id%TYPE;
l_ref_doc_entity_code         zx_transaction_lines_gt.ref_doc_entity_code%TYPE;
l_ref_doc_event_class_code    zx_transaction_lines_gt.ref_doc_event_class_code%TYPE;
l_ref_doc_line_quantity       zx_transaction_lines_gt.ref_doc_line_quantity%TYPE;
l_ref_doc_trx_level_type      zx_transaction_lines_gt.ref_doc_trx_level_type%TYPE;
l_po_header_curr_conv_rate    po_headers_all.rate%TYPE;
l_uom_code                    mtl_units_of_measure.uom_code%TYPE;
l_ref_doc_trx_id              po_headers_all.po_header_id%TYPE;
l_po_line_location_id         po_line_locations.line_location_id%TYPE;
l_dummy			      number;
l_success	              BOOLEAN;
l_debug_info		      VARCHAR2 (100);
l_vendor_id                   NUMBER;
l_vendor_site_id              NUMBER;
l_ship_to_location_id         VARCHAR2(100);
l_product_org_id              NUMBER;
current_calling_sequence      VARCHAR2(2000);
l_allow_tax_code_override     zx_acct_tx_cls_defs.allow_tax_code_override_flag%TYPE;
l_invoice_type_lookup_code    VARCHAR2(20);
Tax_Exception		      EXCEPTION;
l_error_code                  VARCHAR2(4000);
l_dflt_tax_class_code         zx_transaction_lines_gt.input_tax_classification_code%type; -- bug 8483345

Begin

    current_calling_sequence := 'AP_OTHR_CHRG_MATCH_PKG.othr_chrg_match <-'
					|| X_calling_sequence;


    --Retreive certain information from ap_invoices table and
    --ap_system_parameters

    l_debug_info := 'Select information from ap_invoices';

    Get_Info(X_Invoice_Id	=> x_invoice_id,
   	     X_Calling_Sequence => current_calling_sequence);

    --ETAX: Deleted the Tax related code from here , please build
    --the version 115.1 of the file apothmtb.pls, to see what code was deleted.
    --
    -- The Tax related PO attributes are not getting copied to the
    -- Invoice, when matching through the other charge matching
    -- screen (Bug5708602).
    --
    -- Added the calls to the AP_ETAX_UTILITY_PKG.Get_PO_Info
    -- and AP_ETAX_SERVICES_PKG.get_po_tax_attributes to populate
    -- the global variables which then will be used to populate
    -- the attributes on the Invoice Line.
    --

    --
    -- Get the value of the PO line location id from
    -- the Rcv_Transaction_Id
    --

    l_debug_info := 'Get the value of the po_line_location_id from rcv_transaction_id';

    BEGIN

      Select RCV.po_line_location_id,
             RCV.vendor_id,
             RCV.vendor_site_id,
             RSL.ship_to_location_id
      Into   l_po_line_location_id,
             l_vendor_id,
             l_vendor_site_id,
             l_ship_to_location_id
      From   rcv_transactions    RCV,
             rcv_shipment_lines  RSL
      Where  RCV.transaction_id = l_othr_chrg_tab(1).rcv_txn_id
      And    RCV.shipment_line_id = RSL.shipment_line_id
      And    rownum < 2;

    EXCEPTION
     When Others then
          NULL;

    END;


    l_debug_info := 'Get the Event class code by call to the utilities pkg';

    BEGIN

      Select invoice_type_lookup_code
      Into   l_invoice_type_lookup_code
      From   ap_invoices_all ai
      Where  ai.invoice_id = x_invoice_id;

    EXCEPTION
     When Others then
          NULL;

    END;

    l_debug_info := 'Calling the Get_PO_Info API';

    l_success := AP_ETAX_UTILITY_PKG.Get_PO_Info(
                                    P_Po_Line_Location_Id         => l_po_line_location_id,
       	                            P_PO_Distribution_Id          => null,
    				    P_Application_Id              => l_ref_doc_application_id,
    				    P_Entity_code                 => l_ref_doc_entity_code,
    				    P_Event_Class_Code            => l_ref_doc_event_class_code,
    				    P_PO_Quantity                 => l_ref_doc_line_quantity,
    				    P_Product_Org_Id              => l_product_org_id,
    				    P_Po_Header_Id                => l_ref_doc_trx_id,
    				    P_Po_Header_curr_conv_rate    => l_po_header_curr_conv_rate,
    				    P_Uom_Code                    => l_uom_code,
    				    P_Dist_Qty                    => l_dummy,
    				    P_Ship_Price                  => l_dummy,
    				    P_Error_Code                  => l_error_code,
    				    P_Calling_Sequence            => current_calling_sequence);

     l_debug_info := 'Get the default tax classification code';

     ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification
                 (p_ref_doc_application_id           => l_ref_doc_application_id,
                  p_ref_doc_entity_code              => l_ref_doc_entity_code,
                  p_ref_doc_event_class_code         => l_ref_doc_event_class_code,
                  p_ref_doc_trx_id                   => l_ref_doc_trx_id,
                  p_ref_doc_line_id                  => l_po_line_location_id,
                  p_ref_doc_trx_level_type           => 'SHIPMENT',
                  p_vendor_id                        => l_vendor_id,
                  p_vendor_site_id                   => l_vendor_site_id,
                  p_code_combination_id              => X_account_id,
                  p_concatenated_segments            => null,
                  p_templ_tax_classification_cd      => null,
                  p_ship_to_location_id              => l_ship_to_location_id,
                  p_ship_to_loc_org_id               => null,
                  p_inventory_item_id                => null,
                  p_item_org_id                      => l_product_org_id,
                  p_tax_classification_code          => g_dflt_tax_class_code,
                  p_allow_tax_code_override_flag     => l_allow_tax_code_override,
                  APPL_SHORT_NAME                    => 'SQLAP',
                  FUNC_SHORT_NAME                    => 'NONE',
                  p_calling_sequence                 => 'AP_OTHR_CHRG_MATCH_PKG',
                  p_event_class_code                 =>  l_invoice_type_lookup_code,
                  p_entity_code                      => 'AP_INVOICES',
                  p_application_id                   => 200,
                  p_internal_organization_id         => g_org_id);

     l_debug_info := 'calling the Get_PO_Tax_Attributes API';


     AP_Etax_Services_Pkg.Get_Po_Tax_Attributes(
                    p_application_id              => l_ref_doc_application_id,
                    p_org_id                      => g_org_id,
                    p_entity_code                 => l_ref_doc_entity_code,
                    p_event_class_code            => l_ref_doc_event_class_code,
                    p_trx_level_type              => 'SHIPMENT',
                    p_trx_id                      => l_ref_doc_trx_id,
                    p_trx_line_id                 => l_po_line_location_id,
                    x_line_intended_use           => g_intended_use,
                    x_product_type                => g_product_type,
                    x_product_category            => g_product_category,
                    x_product_fisc_classification => g_product_fisc_class,
                    x_user_defined_fisc_class     => g_user_defined_fisc_class,
                    x_assessable_value            => g_assessable_value,
                    x_tax_classification_code     => l_dflt_tax_class_code -- bug 8483345
                    );

	 -- bug 8483345: start
 	    -- if tax classification code not retrieved from hierarchy
 	    -- retrieve it from PO
 	    IF (g_dflt_tax_class_code is null) THEN
 	        g_dflt_tax_class_code := l_dflt_tax_class_code;
 	    END IF;
 	 -- bug 8483345: end

      --
      --  end of bug5708602

    IF (x_invoice_line_number IS NULL) THEN

    	Get_Proration_Info  (X_Othr_Chrg_Tab  => l_othr_chrg_tab,
			     X_Total_Amount   => x_total_amount,
			     X_Prorate_Flag   => x_prorate_flag,
			     X_Row_Count      => x_row_count,
			     X_Calling_Sequence => current_calling_sequence) ;


        Create_Invoice_Lines(x_invoice_id	=> x_invoice_id,
        		     x_line_type	=> x_line_type,
			     x_cost_factor_id   => x_cost_factor_id,
           		     x_othr_chrg_tab 	=> l_othr_chrg_tab,
           		     x_row_count	=> x_row_count,
           		     x_description	=> x_description,
           		     x_ccid		=> x_account_id,
           		     x_total_amount	=> x_total_amount,
           		     x_calling_sequence => current_calling_sequence);

    ELSE

       Insert_Invoice_Dist(x_invoice_id 	 => x_invoice_id,
       			   x_invoice_line_number => x_invoice_line_number,
			   x_description	 => x_description,
	   		   x_calling_sequence	 => current_calling_sequence);

      UPDATE ap_invoice_lines
      SET generate_dists ='D'
      WHERE invoice_id = x_invoice_id
      AND line_number = x_invoice_line_number;

    END IF;

    IF X_Line_Type = 'TAX' THEN

       IF NOT (AP_ETAX_SERVICES_PKG.Calculate_Tax_Receipt_Match(
	                        P_Invoice_Id		=> x_invoice_id,
	                        P_Calling_Mode		=> 'CALCULATE',
	                        P_All_Error_Messages	=> 'N',
	                        P_Error_Code		=> l_error_code,
	                        P_Calling_Sequence	=> current_calling_sequence)) THEN

	  RAISE Tax_Exception;

       END IF;
    END IF;

Exception
    WHEN Tax_Exception Then

	     FND_MESSAGE.SET_NAME('SQLAP','AP_TAX_EXCEPTION');
	     IF l_error_code IS NOT NULL THEN
	        FND_MESSAGE.SET_TOKEN('ERROR', l_error_code);
	     ELSE
	        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
	     END IF;
	     APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN others then
	If (SQLCODE <> -20001) Then
	    fnd_message.set_name('SQLAP','AP_DEBUG');
	    fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
	    fnd_message.set_token('PARAMETERS',
                  'X_invoice_id= '||to_char(x_invoice_id)
		||'X_total_amount= '||to_char(x_total_amount)
		||'X_prorate_flag= '||x_prorate_flag
		||'X_account_id= '||to_char(x_account_id)
		||'X_line_type= '||x_line_type
		||'X_row_count= '||to_char(x_row_count)
		||'X_description= '||x_description);
	    fnd_message.set_token('DEBUG_INFO',l_debug_info);
	End if;
	app_exception.raise_exception;


End OTHR_CHRG_MATCH;

PROCEDURE Get_Info(X_Invoice_ID         IN   NUMBER,
                   X_Calling_Sequence   IN   VARCHAR2) IS

 current_calling_sequence       VARCHAR2(2000);
 l_debug_info           VARCHAR2(100);

BEGIN


   current_calling_sequence := 'Get_Info<-'||Current_Calling_Sequence;

   SELECT ai.batch_id,
    	  ai.invoice_currency_code,
	  ai.exchange_rate,
	  ai.vendor_id,
	  ai.vendor_site_id,
	  ai.invoice_date,
	  asp.base_currency_code,
   	  ai.gl_date,
   	  ai.set_of_books_id,
   	  pv.type_1099,
   	  decode(pv.type_1099,'','',
                 decode(combined_filing_flag,'N',NULL,
                        decode(asp.income_tax_region_flag,'Y',pvs.state,
                               asp.income_tax_region))),
          asp.approval_workflow_flag,
	  asp.transfer_desc_flex_flag,
	  ai.trx_business_category,
          ai.org_id
   INTO  g_batch_id,
         g_invoice_currency_code,
         g_exchange_rate,
         g_vendor_id,
         g_vendor_site_id,
         g_invoice_date,
         g_base_currency_code,
         g_accounting_date,
         g_set_of_books_id,
         g_type_1099,
         g_income_tax_region,
         g_approval_workflow_flag,
	 g_transfer_flag,
	 g_trx_business_category,
         g_org_id
   FROM ap_invoices_all ai,   --bug 5056051
        ap_system_parameters asp,
        ap_suppliers pv,      --bug 5056051
        ap_supplier_sites pvs --bug 5056051
   WHERE ai.invoice_id = x_invoice_id
   AND   ai.vendor_site_id = pvs.vendor_site_id
   AND   pv.vendor_id = pvs.vendor_id
   AND   ai.org_id = asp.org_id;

   SELECT nvl(max(ail.line_number),0)
   INTO g_max_invoice_line_number
   FROM ap_invoice_lines ail
   WHERE ail.invoice_id = x_invoice_id;

   BEGIN

      SELECT book_type_code
      INTO g_asset_book_type_code
      FROM fa_book_controls fc
      WHERE fc.book_class = 'CORPORATE'
      AND fc.set_of_books_id = g_set_of_books_id
      AND fc.date_ineffective  IS NULL;

    EXCEPTION WHEN TOO_MANY_ROWS OR NO_DATA_FOUND THEN
     g_asset_book_type_code := NULL;

   END;
   l_debug_info := 'select period for accounting date';

   --get_current_gl_date will return NULL if the date passed to it doesn't fall in a
   --open period.
   g_period_name := AP_UTILITIES_PKG.get_current_gl_date(g_accounting_date);

   IF (g_period_name IS NULL) THEN

      --Get gl_period and Date from a future period for the accounting date
      ap_utilities_pkg.get_open_gl_date(p_date => g_accounting_date,
                                             p_period_name => g_period_name,
                                             p_gl_date => g_accounting_date);

      IF (g_accounting_date IS NULL) THEN
          fnd_message.set_name('SQLAP','AP_DISTS_NO_OPEN_FUT_PERIOD');
          app_exception.raise_exception;
      END IF;

   END IF;

   g_allow_pa_override := FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES');

   -- Bug 5294998. API from PA will be used
   --g_pa_expenditure_date_default := FND_PROFILE.VALUE('PA_AP_EI_DATE_DEFAULT');

   g_user_id := FND_PROFILE.VALUE('USER_ID');

   g_login_id := FND_PROFILE.VALUE('LOGIN_ID');

END Get_Info;


Procedure Get_Proration_Info(X_Othr_Chrg_Tab  IN OUT NOCOPY OTHR_CHRG_MATCH_TABTYPE,
			     X_Total_Amount   IN    	    NUMBER,
			     X_Prorate_Flag   IN	    VARCHAR2,
			     X_Row_Count      IN	    NUMBER,
			     X_Calling_Sequence IN	    VARCHAR2) IS

l_charge_amount		 number := 0;
l_total_rcv_qty		 number := 0;
I			 number;
l_sum_amount_prorated    ap_invoice_lines.amount%TYPE := 0;
l_rounding_index         number;
l_max_line_amount        ap_invoice_lines.amount%TYPE := 0;
l_total_base_amount 	 ap_invoice_lines.base_amount%TYPE ;
l_base_amount		 ap_invoice_lines.base_amount%TYPE ;
l_sum_line_base_amount   ap_invoice_lines.base_amount%TYPE := 0;
l_debug_info	   	 varchar2(100);
current_calling_sequence varchar2(2000);


BEGIN

  current_calling_sequence := 'Get_Proration_Info<-'||x_calling_sequence;

  --If prorate = 'Y' then get the total rcv_qty from the pl/sql table
  IF X_prorate_flag = 'Y' Then

    l_debug_info := 'find total qty to prorate against';

    FOR I IN 1..X_row_count LOOP
	l_total_rcv_qty := l_total_rcv_qty +
				X_othr_chrg_tab(I).rcv_qty;
    END LOOP;

  END IF;


  FOR I IN 1..X_row_count LOOP

     l_debug_info := 'Calculate charge amount';

     If x_prorate_flag = 'Y' then

	  l_charge_amount :=(x_othr_chrg_tab(i).rcv_qty /l_total_rcv_qty)
					* x_total_amount;

	  x_othr_chrg_tab(i).charge_amt:= AP_UTILITIES_PKG.ap_round_currency(
						l_charge_amount, g_invoice_currency_code);

          --get the max of the invoice line number with largest amount
          IF ( x_othr_chrg_tab(i).charge_amt >= l_max_line_amount) THEN
             l_rounding_index := i;
             l_max_line_amount := x_othr_chrg_tab(i).charge_amt;
          END IF;

          l_sum_amount_prorated := l_sum_amount_prorated + x_othr_chrg_tab(i).charge_amt;

     Else

          --get the max of the invoice line number with largest amount
	  IF (  x_othr_chrg_tab(i).charge_amt >= l_max_line_amount) THEN
	        l_rounding_index := i;
	        l_max_line_amount := x_othr_chrg_tab(i).charge_amt;
	  END IF;

	  l_sum_amount_prorated := l_sum_amount_prorated + x_othr_chrg_tab(i).charge_amt;

     End if;

  END LOOP;

  --Perform Proration Rounding before base_amounts are populated
  IF (l_sum_amount_prorated <> x_total_amount) THEN
      x_othr_chrg_tab(l_rounding_index).charge_amt := x_othr_chrg_tab(l_rounding_index).charge_amt +
                                                        (x_total_amount - l_sum_amount_prorated);

  END IF;

  --Calculate the base amount and rounding_amount
  --for foreign currency invoices.
  IF (g_exchange_rate IS NOT NULL) THEN

    l_total_base_amount := AP_UTILITIES_PKG.ap_round_currency
                              (g_exchange_rate * X_Total_Amount,
			        g_base_currency_code);


    FOR I IN 1..X_row_count LOOP

      l_debug_info := 'calculate the base amount';

      l_base_amount := AP_UTILITIES_PKG.ap_round_currency
				(g_exchange_rate * x_othr_chrg_tab(i).charge_amt,
					g_base_currency_code);

      x_othr_chrg_tab(i).base_amt := l_base_amount;

      l_sum_line_base_amount := l_sum_line_base_amount + l_base_amount;

    END LOOP;

    --Perform Base Amount Rounding
    IF (l_total_base_amount <> l_sum_line_base_amount) THEN
        x_othr_chrg_tab(l_rounding_index).base_amt := x_othr_chrg_tab(l_rounding_index).base_amt +
                                                          (l_total_base_amount - l_sum_line_base_amount);
        x_othr_chrg_tab(l_rounding_index).rounding_amt := l_total_base_amount - l_sum_line_base_amount;
    END IF;

  END IF; /*g_exchange_rate IS NOT NULL*/

END Get_Proration_Info;



Procedure Create_Invoice_Lines(x_invoice_id	IN	NUMBER,
        		       x_line_type	IN	VARCHAR2,
			       x_cost_factor_id IN      NUMBER,
           		       x_othr_chrg_tab 	IN OUT NOCOPY OTHR_CHRG_MATCH_TABTYPE,
           		       x_row_count	IN	NUMBER,
           		       x_description	IN	VARCHAR2,
           		       x_ccid		IN	NUMBER,
           		       x_total_amount	IN	NUMBER,
           		       x_calling_sequence IN	VARCHAR2) IS

l_debug_info 			VARCHAR2(100);
current_calling_sequence	VARCHAR2(2000);
l_invoice_line_number		AP_INVOICE_LINES.LINE_NUMBER%TYPE;
l_sum_amount_prorated		NUMBER;
l_max_line_amount		NUMBER := 0;
l_proration_round_amount	NUMBER := 0;
l_rounded_line_number		NUMBER;

BEGIN

   current_calling_sequence := 'Create_Invoice_Lines<-'||x_calling_sequence;

   l_invoice_line_number := g_max_invoice_line_number + 1;

   FOR i IN 1..x_row_count LOOP

       l_debug_info := 'Calling Insert_Invoice_Line';

       Insert_Invoice_Line(x_invoice_id  => x_invoice_id,
       			   x_invoice_line_number => l_invoice_line_number,
       			   x_line_type	 => x_line_type,
			   x_cost_factor_id => x_cost_factor_id,
       			   x_amount	 => x_othr_chrg_tab(i).charge_amt,
       			   x_base_amount => x_othr_chrg_tab(i).base_amt,
                           x_rounding_amt => x_othr_chrg_tab(i).rounding_amt,
       			   x_rcv_transaction_id => x_othr_chrg_tab(i).rcv_txn_id,
			   x_ccid		=> x_ccid,
			   x_description	=> x_description,
       			   x_calling_sequence   => current_calling_sequence);

       l_debug_info := 'Calling Insert_Invoice_Dist';

       Insert_Invoice_Dist(x_invoice_id => x_invoice_id,
       			   x_invoice_line_number => l_invoice_line_number,
       			   x_description => x_description,
			   x_calling_sequence => current_calling_sequence);

       l_invoice_line_number := l_invoice_line_number + 1;

    END LOOP;


 EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_Id = '||to_char(x_invoice_id)
			  ||', Invoice Line Type = '|| x_line_type
 			  ||', Total Match Amount = '||to_char(x_total_amount)
 			  ||', Row Count = '||to_char(x_row_count)
			  ||', Description = '||x_Description);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   --clean up the PL/SQL tables.
   x_othr_chrg_tab.delete;

   APP_EXCEPTION.RAISE_EXCEPTION;
END Create_Invoice_Lines;


Procedure Insert_Invoice_Line( x_invoice_id  		IN NUMBER,
       			       x_invoice_line_number 	IN NUMBER,
       			       x_line_type		IN VARCHAR2,
			       x_cost_factor_id         IN NUMBER,
       			       x_amount			IN NUMBER,
       			       x_base_amount 		IN NUMBER,
                       	       x_rounding_amt 		IN NUMBER,
       			       x_rcv_transaction_id 	IN NUMBER,
			       x_ccid		    	IN NUMBER,
			       x_description	    	IN VARCHAR2,
       			       x_calling_sequence   	IN VARCHAR2) IS

l_debug_info 	VARCHAR2(100);
current_calling_sequence	VARCHAR2(2000);

BEGIN

   current_calling_sequence := 'Insert_Invoice_Line<-'||x_calling_sequence;

   INSERT INTO AP_INVOICE_LINES
	     (INVOICE_ID,
	      LINE_NUMBER,
	      LINE_TYPE_LOOKUP_CODE,
	      /*OPEN ISSUE 2*/
	      --REQUESTER_ID,
	      DESCRIPTION,
	      LINE_SOURCE,
	      ORG_ID,
	      INVENTORY_ITEM_ID,
	      ITEM_DESCRIPTION,
	      SERIAL_NUMBER,
	      MANUFACTURER,
	      MODEL_NUMBER,
	      GENERATE_DISTS,
	      MATCH_TYPE,
	      DISTRIBUTION_SET_ID,
	      ACCOUNT_SEGMENT,
	      BALANCING_SEGMENT,
	      COST_CENTER_SEGMENT,
	      OVERLAY_DIST_CODE_CONCAT,
	      DEFAULT_DIST_CCID,
	      PRORATE_ACROSS_ALL_ITEMS,
	      LINE_GROUP_NUMBER,
	      ACCOUNTING_DATE,
	      PERIOD_NAME,
	      DEFERRED_ACCTG_FLAG,
	      DEF_ACCTG_START_DATE,
	      DEF_ACCTG_END_DATE,
	      DEF_ACCTG_NUMBER_OF_PERIODS,
	      DEF_ACCTG_PERIOD_TYPE,
	      SET_OF_BOOKS_ID,
	      AMOUNT,
	      BASE_AMOUNT,
	      ROUNDING_AMT,
	      QUANTITY_INVOICED,
	      UNIT_MEAS_LOOKUP_CODE,
	      UNIT_PRICE,
	      WFAPPROVAL_STATUS,
	   -- USSGL_TRANSACTION_CODE, - Bug 4277744
	      DISCARDED_FLAG,
	      ORIGINAL_AMOUNT,
	      ORIGINAL_BASE_AMOUNT,
	      ORIGINAL_ROUNDING_AMT,
	      CANCELLED_FLAG,
	      INCOME_TAX_REGION,
	      TYPE_1099,
	      STAT_AMOUNT,
	      PREPAY_INVOICE_ID,
	      PREPAY_LINE_NUMBER,
	      INVOICE_INCLUDES_PREPAY_FLAG,
	      CORRECTED_INV_ID,
	      CORRECTED_LINE_NUMBER,
	      PO_HEADER_ID,
	      PO_LINE_ID,
	      PO_RELEASE_ID,
	      PO_LINE_LOCATION_ID,
	      PO_DISTRIBUTION_ID,
	      RCV_TRANSACTION_ID,
	      FINAL_MATCH_FLAG,
	      ASSETS_TRACKING_FLAG,
	      ASSET_BOOK_TYPE_CODE,
	      ASSET_CATEGORY_ID,
	      /*OPEN ISSUE 2*/
	      /*PROJECT_ID,
	      TASK_ID,
	      EXPENDITURE_TYPE,
	      EXPENDITURE_ITEM_DATE,
	      EXPENDITURE_ORGANIZATION_ID,*/
	      PA_QUANTITY,
	      PA_CC_AR_INVOICE_ID,
	      PA_CC_AR_INVOICE_LINE_NUM,
	      PA_CC_PROCESSED_CODE,
	      /*OPEN ISSUE 2 */
	      --AWARD_ID,
	      AWT_GROUP_ID,
	      REFERENCE_1,
	      REFERENCE_2,
	      RECEIPT_VERIFIED_FLAG,
	      RECEIPT_REQUIRED_FLAG,
	      RECEIPT_MISSING_FLAG,
	      JUSTIFICATION,
	      EXPENSE_GROUP,
	      START_EXPENSE_DATE,
	      END_EXPENSE_DATE,
	      RECEIPT_CURRENCY_CODE,
	      RECEIPT_CONVERSION_RATE,
	      RECEIPT_CURRENCY_AMOUNT,
	      DAILY_AMOUNT,
	      WEB_PARAMETER_ID,
	      ADJUSTMENT_REASON,
	      MERCHANT_DOCUMENT_NUMBER,
	      MERCHANT_NAME,
	      MERCHANT_REFERENCE,
	      MERCHANT_TAX_REG_NUMBER,
	      MERCHANT_TAXPAYER_ID,
	      COUNTRY_OF_SUPPLY,
	      CREDIT_CARD_TRX_ID,
	      COMPANY_PREPAID_INVOICE_ID,
	      CC_REVERSAL_FLAG,
	      ATTRIBUTE_CATEGORY,
	      ATTRIBUTE1,
      	      ATTRIBUTE2,
      	      ATTRIBUTE3,
      	      ATTRIBUTE4,
      	      ATTRIBUTE5,
      	      ATTRIBUTE6,
      	      ATTRIBUTE7,
      	      ATTRIBUTE8,
      	      ATTRIBUTE9,
      	      ATTRIBUTE10,
      	      ATTRIBUTE11,
      	      ATTRIBUTE12,
      	      ATTRIBUTE13,
      	      ATTRIBUTE14,
      	      ATTRIBUTE15,
      	     /* GLOBAL_ATTRIBUTE_CATEGORY,
	      GLOBAL_ATTRIBUTE1,
      	      GLOBAL_ATTRIBUTE2,
      	      GLOBAL_ATTRIBUTE3,
      	      GLOBAL_ATTRIBUTE4,
      	      GLOBAL_ATTRIBUTE5,
      	      GLOBAL_ATTRIBUTE6,
      	      GLOBAL_ATTRIBUTE7,
       	      GLOBAL_ATTRIBUTE8,
      	      GLOBAL_ATTRIBUTE9,
       	      GLOBAL_ATTRIBUTE10,
      	      GLOBAL_ATTRIBUTE11,
      	      GLOBAL_ATTRIBUTE12,
      	      GLOBAL_ATTRIBUTE13,
      	      GLOBAL_ATTRIBUTE14,
      	      GLOBAL_ATTRIBUTE15,
      	      GLOBAL_ATTRIBUTE16,
      	      GLOBAL_ATTRIBUTE17,
      	      GLOBAL_ATTRIBUTE18,
      	      GLOBAL_ATTRIBUTE19,
      	      GLOBAL_ATTRIBUTE20, */
      	      CREATION_DATE,
      	      CREATED_BY,
      	      LAST_UPDATED_BY,
      	      LAST_UPDATE_DATE,
      	      LAST_UPDATE_LOGIN,
      	      PROGRAM_APPLICATION_ID,
      	      PROGRAM_ID,
      	      PROGRAM_UPDATE_DATE,
      	      REQUEST_ID,
	      --ETAX: Invwkb
	      --OPEN ISSUE 2
              --bug5708602
	      SHIP_TO_LOCATION_ID,

	      PRIMARY_INTENDED_USE,
	      PRODUCT_FISC_CLASSIFICATION,
	      TRX_BUSINESS_CATEGORY

	      ,PRODUCT_TYPE,
	      PRODUCT_CATEGORY,
	      USER_DEFINED_FISC_CLASS
	      ,COST_FACTOR_ID
	      )
    SELECT    X_INVOICE_ID,			--invoice_id
 	      X_INVOICE_LINE_NUMBER,		--invoice_line_number
 	      X_LINE_TYPE,			--line_type_lookup_code
 	      /*OPEN ISSUE 2*/
 	      --NULL,				--requester_id
 	      x_description,			--description
 	      'HEADER MATCH',			--line_source
 	      rcv.org_id,			--org_id
 	      NULL,				--inventory_item_id
 	      NULL,				--item_Description
 	      NULL,				--serial_number
 	      NULL,				--manufacturer
 	      NULL,				--model_number
 	      'D',				--generate_dists
 	      'OTHER_TO_RECEIPT',		--match_type
 	      NULL,				--distribution_set_id
 	      NULL,				--account_segment
 	      NULL,				--balancing_Segment
 	      NULL,				--cost_center_segment
 	      NULL,				--overlay_dist_code_concat
 	      x_ccid,				--default_dist_ccid
 	      'N',				--prorate_across_all_items
 	      NULL,				--line_group_number
 	      g_accounting_date,		--accounting_date
 	      g_period_name,			--period_name
 	      'N',				--deferred_acctg_flag
 	      NULL,				--def_acctg_start_date
 	      NULL,				--def_acctg_end_date
 	      NULL,				--def_acctg_number_of_periods
 	      NULL,				--def_acctg_period_type
 	      g_set_of_books_id	,		--set_of_books_id
 	      x_amount,				--amount
 	      x_base_amount,			--base_amount
              x_rounding_amt,   		--rounding_amt
 	      NULL,				--quantity_invoiced
 	      NULL,				--unit_meas_lookup_code
 	      NULL,				--unit_price
 	      decode(g_approval_workflow_flag,'Y'
		   ,'REQUIRED','NOT REQUIRED'), --wfapproval_status
           -- Removed for bug 4277744
	   -- rsl.ussgl_transaction_code,	--ussgl_transaction_code
	      'N',				--discarded_flag
	      NULL,				--original_amount
	      NULL,				--original_base_amount
	      NULL,				--original_rounding_amt
	      'N',				--cancelled_flag
	      g_income_tax_region,		--income_tax_region
	      g_type_1099,			--type_1099
	      NULL,				--stat_amount
	      NULL,				--prepay_invoice_id
	      NULL,				--prepay_line_number
	      NULL,				--invoice_includes_prepay_flag
	      NULL,				--corrected_inv_id
	      NULL,				--corrected_line_number
	      rcv.po_header_id,			--po_header_id
	      rcv.po_line_id,			--po_line_id
	      rcv.po_release_id,		--po_release_id
	      rcv.po_line_location_id,		--po_line_location_id
	      NULL,				--po_distribution_id
	      x_rcv_transaction_id,		--rcv_transaction_id
	      NULL,				--final_match_flag
	      'N',				--assets_tracking_flag
	      g_asset_book_type_code,		--asset_book_type_code
	      NULL,				--asset_category_id
	      /*OPEN ISSUE 2*/
	      /*
	      NULL,				--project_id
	      NULL,				--task_id
	      NULL,				--expenditure_type
	      NULL,				--expenditure_item_date
	      NULL,				--expenditure_organization_id
	      */
	      NULL,				--pa_quantity
	      NULL,				--pa_cc_ar_invoice_id
	      NULL,				--pa_cc_ar_invoice_line_num
	      NULL,				--pa_cc_processed_code
	      /*OPEN ISSUE 2*/
	      /* NULL,	*/			--award_id
	      NULL,				--awt_group_id
	      NULL,    				--reference_1
 	      NULL,				--reference_2
 	      NULL,				--receipt_verified_flag
 	      NULL,				--receipt_required_flag
 	      NULL,				--receipt_missing_flag
 	      NULL,				--justification
 	      NULL,				--expense_group
 	      NULL,				--start_expense_date
 	      NULL,				--end_expense_date
 	      NULL,				--receipt_currency_amount
 	      NULL,				--receipt_conversion_rate
 	      NULL,				--receipt_currency_amount
 	      NULL,				--daily_amount
 	      NULL,				--web_parameter_id
 	      NULL,				--adjustment_reason
 	      NULL,				--merchant_document_number
 	      NULL,				--merchant_name
 	      NULL,				--merchant_reference
 	      NULL,				--merchant_tax_reg_number
 	      NULL,				--merchant_taxpayer_id
 	      NULL,				--country_of_supply
 	      NULL,				--credit_card_trx_id
 	      NULL,				--company_prepaid_invoice_id
 	      NULL,				--cc_reversal_flag
	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute_category),''),--attribute_category
    	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute1),''), --attribute1
   	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute2),''), --attribute2
   	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute3),''), --attribute3
    	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute4),''), --attribute4
   	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute5),''), --attribute5
   	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute6),''), --attribute6
   	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute7),''), --attribute7
   	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute8),''), --attribute8
    	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute9),''), --attribute9
   	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute10),''), --attribute10
    	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute11),''), --attribute11
   	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute12),''), --attribute12
    	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute13),''), --attribute13
    	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute14),''), --attribute14
    	      NVL(DECODE(g_transfer_flag,'Y',rsl.attribute15),''), --attribute15
    	      /* OPEN ISSUE 1 */
   	      /* X_GLOBAL_ATTRIBUTE_CATEGORY,		--global_attribute_category
	      X_GLOBAL_ATTRIBUTE1,			--global_attribute1
      	      X_GLOBAL_ATTRIBUTE2,			--global_attribute2
	      X_GLOBAL_ATTRIBUTE3,			--global_attribute3
      	      X_GLOBAL_ATTRIBUTE4,			--global_attribute4
      	      X_GLOBAL_ATTRIBUTE5,			--global_attribute5
      	      X_GLOBAL_ATTRIBUTE6,			--global_attribute6
      	      X_GLOBAL_ATTRIBUTE7,			--global_attribute7
       	      X_GLOBAL_ATTRIBUTE8,			--global_attribute8
      	      X_GLOBAL_ATTRIBUTE9,			--global_attribute9
       	      X_GLOBAL_ATTRIBUTE10,			--global_attribute10
      	      X_GLOBAL_ATTRIBUTE11,			--global_attribute11
      	      X_GLOBAL_ATTRIBUTE12,			--global_attribute12
      	      X_GLOBAL_ATTRIBUTE13,			--global_attribute13
      	      X_GLOBAL_ATTRIBUTE14,			--global_attribute14
      	      X_GLOBAL_ATTRIBUTE15,			--global_attribute15
      	      X_GLOBAL_ATTRIBUTE16,			--global_attribute16
      	      X_GLOBAL_ATTRIBUTE17,			--global_attribute17
      	      X_GLOBAL_ATTRIBUTE18,			--global_attribute18
      	      X_GLOBAL_ATTRIBUTE19,			--global_attribute19
      	      X_GLOBAL_ATTRIBUTE20, */
      	      sysdate,					--creation_date
      	      g_user_id,				--created_by
      	      g_user_id,				--last_updated_by
      	      sysdate,					--last_update_date
      	      g_login_id,				--last update login
      	      NULL,					--program_application_id
      	      NULL,					--program_id
      	      NULL,					--program_update_date
      	      NULL,					--request_date
	      --ETAX: Invwkb
	      --OPEN ISSUE 2
              --bug5708602
	      RCV.SHIP_TO_LOCATION_ID,         --ship_to_location_id
	      G_intended_use,                            --primary_intended_use
	      G_product_fisc_class,                      --product_fisc_classification
	      G_TRX_BUSINESS_CATEGORY,                   --trx_business_category
	      G_product_type,                            --product_type
	      G_product_category,                        --product_category
	      G_user_defined_fisc_class,                 --user_defined_fisc_class
	      X_COST_FACTOR_ID		                 --cost_factor_id
 	 FROM po_ap_receipt_match_v rcv,
 	      rcv_shipment_lines rsl
 	 WHERE rcv.rcv_transaction_id = x_rcv_transaction_id
 	 AND   rsl.shipment_line_id = rcv.rcv_shipment_line_id;

  EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_Id = '||to_char(x_invoice_id)
			  ||', Invoice Line Number = '||to_char(x_invoice_line_number)
			  ||', Invoice Line Type = '|| x_line_type
 			  ||', Rcv Transaction id ='||to_char(x_rcv_transaction_id)
 			  ||', Amount = '||to_char(x_amount)
 			  ||', Base Amount = '||to_char(x_base_amount));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Insert_Invoice_Line;



/*-------------------------------------------------------------------------
INSERT_INVOICE_DIST
This procedure inserts a distribution into ap_invoice distributions.
--------------------------------------------------------------------------*/

Procedure Insert_Invoice_dist (
		X_invoice_id		IN	NUMBER,
		X_invoice_line_number	IN	NUMBER,
		X_description		IN	VARCHAR2,
		x_calling_sequence	IN	VARCHAR2) IS

l_invoice_distribution_id	AP_INVOICE_DISTRIBUTIONS.INVOICE_DISTRIBUTION_ID%TYPE;
current_calling_sequence 	VARCHAR2(2000);
l_debug_info			VARCHAR2(2000);
l_copy_line_dff_flag    VARCHAR2(1); -- Bug 6837035

Begin

    -- Update calling sequence
    current_calling_sequence := 'Insert_Invoice_Dist <-' ||X_calling_sequence;

    -- insert into ap_invoice_distributions

    l_debug_info := 'insert into ap_invoice_distributions';
    -- Bug 6837035 Retrieve the profile value to check if the DFF info should be
    -- copied onto distributions for imported lines.
    l_copy_line_dff_flag := NVL(fnd_profile.value('AP_COPY_INV_LINE_DFF'),'N');

    INSERT INTO ap_invoice_distributions (
		batch_id,
                invoice_id,
                invoice_line_number,
                invoice_distribution_id,
                distribution_line_number,
                line_type_lookup_code,
                description,
                dist_match_type,
                distribution_class,
                org_id,
                dist_code_combination_id,
                accounting_date,
                period_name,
                accrual_posted_flag,
                cash_posted_flag,
                amount_to_post,
                base_amount_to_post,
                posted_amount,
                posted_base_amount,
                je_batch_id,
                cash_je_batch_id,
                posted_flag,
                accounting_event_id,
                upgrade_posted_amt,
                upgrade_base_posted_amt,
                set_of_books_id,
                amount,
		base_amount,
                rounding_amt,
                match_status_flag,
                encumbered_flag,
                packet_id,
             -- ussgl_transaction_code, - Bug 4277744
             -- ussgl_trx_code_context, - Bug 4277744
                reversal_flag,
                parent_reversal_id,
                cancellation_flag,
                income_tax_region,
                type_1099,
                stat_amount,
                charge_applicable_to_dist_id,
                prepay_amount_remaining,
                prepay_distribution_id,
                parent_invoice_id,
                corrected_invoice_dist_id,
                corrected_quantity,
                other_invoice_id,
                po_distribution_id,
                rcv_transaction_id,
                unit_price,
                matched_uom_lookup_code,
                quantity_invoiced,
                final_match_flag,
                related_id,
                assets_addition_flag,
                assets_tracking_flag,
                asset_book_type_code,
                asset_category_id,
                pa_cc_ar_invoice_id,
                pa_cc_ar_invoice_line_num,
                pa_cc_processed_code,
                gms_burdenable_raw_cost,
                awt_flag,
                awt_group_id,
                awt_tax_rate_id,
                awt_gross_amount,
                awt_invoice_id,
                awt_origin_group_id,
                awt_invoice_payment_id,
                awt_withheld_amt,
                inventory_transfer_status,
                reference_1,
                reference_2,
                receipt_verified_flag,
                receipt_required_flag,
                receipt_missing_flag,
                justification,
                expense_group,
                start_expense_date,
                end_expense_date,
                receipt_currency_code,
                receipt_conversion_rate,
                receipt_currency_amount,
                daily_amount,
                web_parameter_id,
                adjustment_reason,
                merchant_document_number,
                merchant_name,
                merchant_reference,
                merchant_tax_reg_number,
                merchant_taxpayer_id,
                country_of_supply,
                credit_card_trx_id,
                company_prepaid_invoice_id,
                cc_reversal_flag,
                /*Invoice Lines: OPEN ISSUE2*/
                -- Bug 6837035 Uncommented the DFF fields so that they can be
                -- populated for imported lines.
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
		/* Invoice Lines */
                /*OPEN ISSUE 1*/
                /*global_attribute_category,
                global_attribute1,
                global_attribute2,
                global_attribute3,
                global_attribute4,
                global_attribute5,
                global_attribute6,
                global_attribute7,
                global_attribute8,
                global_attribute9,
                global_attribute10,
                global_attribute11,
                global_attribute12,
		global_attribute13,
                global_attribute14,
                global_attribute15,
                global_attribute16,
                global_attribute17,
                global_attribute18,
                global_attribute19,
                global_attribute20,*/
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                program_application_id,
                program_id,
                program_update_date,
                request_id,
		--ETAX: Invwkb
		--OPEN ISSUE 1
		/*,intended_use*/
		--Freight and Special Charges
                rcv_charge_addition_flag)
    SELECT g_batch_id,			--batch_id
    	   x_invoice_id,		--invoice_id
    	   x_invoice_line_number,	--invoice_line_number
    	   ap_invoice_distributions_s.nextval,	--invoice_distribution_id
    	   1,				--distribution_line_number
    	   ail.line_type_lookup_code,	--line_type_lookup_code
    	   ail.description,		--description
    	   'OTHER_TO_RECEIPT',		--dist_match_type
    	   'PERMANENT',			--distribution_class
    	   ail.org_id,			--org_id
    	   ail.default_dist_ccid,	--dist_code_combination_id
    	   ail.accounting_date,		--accounting_date
    	   ail.period_name,		--period_name
           'N',				--accrual_posted_flag
    	   'N',				--cash_posted_flag
    	   NULL,			--amount_to_post
    	   NULL,			--base_amount_to_post
    	   NULL,			--posted_amount
    	   NULL,			--posted_base_amount
    	   NULL,			--je_batch_id
    	   NULL,			--cash_je_batch_id
    	   'N',				--posted_flag
    	   NULL,			--accounting_event_id
    	   NULL,			--upgrade_posted_amt
    	   NULL,			--upgrade_base_posted_amt
    	   g_set_of_books_id,		--set_of_books_id
    	   ail.amount,			--amount
    	   ail.base_amount,		--base_amount
    	   ail.rounding_amt,		--rounding_amt
    	   NULL,			--match_status_flag
    	   'N',				--encumbered_flag
    	   NULL,			--packet_id
    	-- ail.ussgl_transaction_code,	--ussgl_transaction_code - Bug 4277744
    	-- NULL,			--ussgl_trx_code_context - Bug 4277744
    	   'N',				--reversal_flag
    	   NULL,			--parent_reversal_id
    	   'N',				--cancellation_flag
    	   decode(g_type_1099,'','',ail.income_tax_region) , --income_tax_region
    	   ail.type_1099,		--type_1099
    	   NULL,			--stat_amount
    	   NULL,			--charge_applicable_to_dist_id
    	   NULL,			--prepay_amount_remaining
    	   NULL,			--prepay_distribution_id
    	   NULL,			--parent_invoice_id
    	   NULL,			--corrected_invoice_dist_id
    	   NULL,			--corrected_quantity
    	   NULL,			--other_invoice_id
    	   NULL,			--po_distribution_id
    	   ail.rcv_transaction_id,	--rcv_transaction_id
    	   NULL,			--unit_price
    	   NULL,			--matched_uom_lookup_code
    	   NULL,			--quantity_invoiced
    	   NULL,			--final_match_flag
    	   NULL,			--related_id
    	   'U',				--assets_addition_flag
    	   decode(gcc.account_type,'E',
    	   	  ail.assets_tracking_flag,
    	   	  'A','Y','N'),		--assets_tracking_flag
           decode(decode(gcc.account_type,'E',ail.assets_tracking_flag,
    	   	 	 'A','Y','N'),'Y',ail.asset_book_type_code,NULL), --asset_book_type_code
    	   decode(decode(gcc.account_type,'E',ail.assets_tracking_flag,
    	   	 	 'A','Y','N'),'Y',ail.asset_category_id,NULL),    --asset_category_id
    	   NULL,			 --pa_cc_ar_invoice_id
    	   NULL,			 --pa_cc_ar_invoice_line_num
    	   NULL,			 --pa_cc_processed_code
    	   NULL,			 --gms_burdenable_raw_cost
    	   NULL,			 --awt_flag
    	   NULL,			 --awt_group_id
  	   NULL,                         --awt_tax_rate_id
           NULL,                         --awt_gross_amount
           NULL,                         --awt_invoice_id
           NULL,                         --awt_origin_group_id
           NULL,                         --awt_invoice_payment_id
           NULL,                         --awt_withheld_amt
           'N',				 --inventory_transfer_status
           NULL,                         --reference_1
           NULL,                         --reference_2
           NULL,                         --receipt_verified_flag
           NULL,                         --receipt_required_flag
           NULL,                         --receipt_missing_flag
           NULL,                         --justification
           NULL,                         --expense_group
           NULL,                         --start_expense_date
           NULL,                         --end_expense_date
           NULL,                         --receipt_currency_code
           NULL,                         --receipt_conversion_rate
           NULL,                         --receipt_currency_amount
           NULL,                         --daily_amount
           NULL,                         --web_parameter_id
           NULL,                         --adjustment_reason
           NULL,                         --merchant_document_number
           NULL,                         --merchant_name
           NULL,                         --merchant_reference
           NULL,                         --merchant_tax_reg_number
           NULL,                         --merchant_taxpayer_id
           NULL,                         --country_of_supply
           NULL,                         --credit_card_trx_id
           NULL,                         --company_prepaid_invoice_id
           NULL,                         --cc_reversal_flag
           -- Bug 6837035 Start Need to copy DFF info from line for imported lines
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute_category,NULL),NULL), --attribute_category
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute1,NULL),NULL), --attribute1
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute2,NULL),NULL), --attribute2
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute3,NULL),NULL), --attribute3
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute4,NULL),NULL), --attribute4
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute5,NULL),NULL), --attribute5
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute6,NULL),NULL), --attribute6
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute7,NULL),NULL), --attribute7
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute8,NULL),NULL), --attribute8
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute9,NULL),NULL), --attribute9
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute10,NULL),NULL), --attribute10
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute11,NULL),NULL), --attribute11
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute12,NULL),NULL), --attribute12
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute13,NULL),NULL), --attribute13
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute14,NULL),NULL), --attribute14
           DECODE(line_source,'IMPORTED'
		       ,DECODE(l_copy_line_dff_flag,'Y',ail.attribute15,NULL),NULL), --attribute15
           -- Bug 6837035 End.
           /*OPEN ISSUE1*/
           /*
           NULL,			 --global_attribute_category
           NULL,			 --global_attribute1
           NULL,			 --global_attribute2
           NULL,			 --global_attribute3
           NULL,			 --global_attribute4
           NULL,			 --global_attribute5
           NULL,			 --global_attribute6
           NULL,			 --global_attribute7
           NULL,			 --global_attribute8
           NULL,			 --global_attribute9
           NULL,			 --global_attribute10
           NULL,			 --global_attribute11
           NULL,			 --global_attribute12
           NULL,			 --global_attribute13
           NULL,			 --global_attribute14
           NULL,			 --global_attribute15  */
           ail.created_by,		 --created_by
           sysdate,			 --creation_date
           ail.last_updated_by,		 --last_updated_by
           sysdate,	 		 --last_update_date
           ail.last_update_login,	 --last_update_login
           NULL,			 --program_application_id
           NULL,			 --program_id
           NULL,			 --program_update_date
           NULL, 		 	 --request_id
	   --ETAX: Invwkb
	   --OPEN ISSUE 1
	   /*,rcv.intended_use */
	   'N'				 --rcv_charge_addition_flag
    FROM ap_invoice_lines AIL,
	 gl_code_combinations GCC,
	 rcv_transactions rcv
    WHERE ail.invoice_id = x_invoice_id
      AND ail.line_number = x_invoice_line_number
      AND ail.rcv_transaction_id = rcv.transaction_id
      AND gcc.code_combination_id = ail.default_dist_ccid
      AND rcv.transaction_id = ail.rcv_transaction_id;


    UPDATE ap_invoice_distributions_all id
    SET    (project_id,
	    task_id,
	    expenditure_type,
	    expenditure_item_date,
	    expenditure_organization_id,
	    award_id) =
	   (SELECT
	            DECODE(PD.destination_type_code,'EXPENSE',
	                   PD.project_id,'SHOP FLOOR',PD.project_id,
	                   'INVENTORY',PD.project_id),                      --project_id
	            DECODE(PD.destination_type_code,'EXPENSE',
	                   PD.task_id,'SHOP FLOOR',PD.task_id,
	                   'INVENTORY',PD.task_id),                         --task_id
	            DECODE(PD.destination_type_code,'EXPENSE',
	                   PD.expenditure_type,
	                   'SHOP FLOOR',PD.expenditure_type,
	                   'INVENTORY', PD.expenditure_type),               --expenditure_type
	            DECODE(PD.destination_type_code,
	                   'EXPENSE',PD.expenditure_item_date,
	                   'SHOP FLOOR', PD.expenditure_item_date,
	                   'INVENTORY',PD.expenditure_item_date),           --expenditure_item_date
	            DECODE(PD.destination_type_code,
	                   'EXPENSE',PD.expenditure_organization_id,
	                   'SHOP FLOOR', PD.expenditure_organization_id,
	                   'INVENTORY', PD.expenditure_organization_id),    --expenditure_organization_id
	            DECODE(PD.destination_type_code,
	                   'EXPENSE', PD.award_id)                          --award_id
	   FROM	    ap_invoice_distributions_all aid,
		    rcv_transactions             rcv,
		    po_distributions_all         pd
	   WHERE    aid.invoice_distribution_id = l_invoice_distribution_id
	     AND    aid.rcv_transaction_id = rcv.transaction_id
	     AND    rcv.po_distribution_id = pd.po_distribution_id)
   WHERE id.invoice_distribution_id = l_invoice_distribution_id;

    --Bug 4539462 DBI logging
    AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'I',
               p_key_value1 => x_invoice_id,
               p_key_value2 => l_invoice_distribution_id,
                p_calling_sequence => current_calling_sequence);

Exception
    WHEN others then
	If (SQLCODE <> -20001) Then
	    fnd_message.set_name('SQLAP','AP_DEBUG');
	    fnd_message.set_token('ERROR',SQLERRM);
	    fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
	    fnd_message.set_token('PARAMETERS',
                  'X_invoice_id= '||to_char(x_invoice_id)
                ||'X_invoice_line_number =' ||to_char(x_invoice_line_number));
	    fnd_message.set_token('DEBUG_INFO',l_debug_info);
	End if;
	app_exception.raise_exception;


End Insert_Invoice_dist;


END AP_OTHR_CHRG_MATCH_PKG;


/
