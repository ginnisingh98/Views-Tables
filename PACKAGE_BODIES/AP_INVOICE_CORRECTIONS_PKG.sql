--------------------------------------------------------
--  DDL for Package Body AP_INVOICE_CORRECTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICE_CORRECTIONS_PKG" AS
/*$Header: apinvcob.pls 120.18.12010000.4 2009/10/29 05:03:36 sbonala ship $*/

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_MATCHING_PKG';
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
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_INVOICE_CORRECTIONS_PKG.';

--LOCAL PROCEDURES
PROCEDURE Get_Info(X_Invoice_ID  	IN NUMBER,
		   X_Calling_Sequence	IN VARCHAR2 );


Procedure Create_Invoice_Lines_Dists(
		X_Invoice_Id		IN		NUMBER,
		X_Corrected_Invoice_Id	IN		NUMBER,
		X_Corrected_Line_Number IN		NUMBER,
		X_Line_Tab		IN OUT NOCOPY	LINE_TAB_TYPE,
		X_Dist_Tab		IN OUT NOCOPY 	DIST_TAB_TYPE,
		--bugfix:4700522
		X_Prorate_Dists_Flag	IN		VARCHAR2,
		X_Correction_Quantity	IN		NUMBER,
		X_Correction_Price	IN		NUMBER,
		X_Total_Correction_Amount IN		NUMBER,
		X_Calling_Sequence	IN		VARCHAR2);


Procedure Get_Line_Proration_Info(X_Corrected_Invoice_Id IN NUMBER,
	        		  X_Correction_Amount    IN NUMBER,
	        		  X_Line_Tab IN OUT NOCOPY LINE_TAB_TYPE,
	        		  X_Prorate_Lines_Flag   IN VARCHAR2,
	        		  X_Calling_Sequence     IN VARCHAR2);


Procedure Get_Dist_Proration_Info(X_Corrected_Invoice_Id  IN NUMBER,
				  X_Corrected_Line_Number IN NUMBER,
	        		  X_Line_Amount           IN NUMBER,
				  X_Line_Base_Amount	  IN NUMBER,
                                  X_Included_Tax_Amount   IN NUMBER, -- Bug 5597409
	        		  X_Dist_Tab IN OUT NOCOPY DIST_TAB_TYPE,
	        		  X_Prorate_Dists_Flag    IN VARCHAR2,
	        		  X_Calling_Sequence      IN VARCHAR2);

FUNCTION Get_Dist_Proration_Total(
                X_Corrected_Invoice_id  IN NUMBER,
		X_Corrected_Line_Number IN NUMBER,
		X_Current_Calling_Sequence IN VARCHAR2) RETURN NUMBER;


Procedure Insert_Invoice_Line (X_Invoice_Id 	 	IN	NUMBER,
			       X_Invoice_Line_Number	IN	NUMBER,
			       X_Corrected_Invoice_Id   IN      NUMBER,
			       X_Corrected_Line_Number  IN	NUMBER,
			       X_Amount			IN	NUMBER,
			       X_Base_Amount		IN 	NUMBER,
                   	       X_Rounding_Amt       	IN      NUMBER,
			       X_Correction_Quantity	IN      NUMBER,
			       X_Correction_Price	IN	NUMBER,
			       X_Calling_Sequence	IN	VARCHAR2);


PROCEDURE Insert_Invoice_Distributions (
	     X_Invoice_ID	   IN 	NUMBER,
	     X_Invoice_Line_Number IN	NUMBER,
	     X_Dist_Tab		   IN OUT NOCOPY Dist_Tab_Type,
	     X_Line_Amount	   IN   NUMBER,
	     X_Calling_Sequence	   IN	VARCHAR2);


--Global Variable Declaration
G_max_invoice_line_number	ap_invoice_lines.line_number%TYPE := 0;
G_batch_id			ap_batches.batch_id%TYPE;
G_Accounting_Date 		ap_invoice_lines.accounting_date%TYPE;
G_Period_Name    		gl_period_statuses.period_name%TYPE;
G_Set_of_Books_ID 		ap_system_parameters.set_of_books_id%TYPE;
G_Awt_Group_ID 			ap_awt_groups.group_id%TYPE;
G_Exchange_Rate			ap_invoices.exchange_rate%TYPE;
G_Precision			fnd_currencies.precision%TYPE;
G_Min_Acct_Unit			fnd_currencies.minimum_accountable_unit%TYPE;
G_System_Allow_Awt_Flag		ap_system_parameters.allow_awt_flag%TYPE;
G_Site_Allow_Awt_Flag		po_vendor_sites.allow_awt_flag%TYPE;
G_Base_Currency_Code		ap_system_parameters.base_currency_code%TYPE;
G_Invoice_Currency_Code		ap_invoices.invoice_currency_code%TYPE;
G_Allow_PA_Override		VARCHAR2(1);
G_Income_Tax_Region		ap_system_parameters.income_tax_region%TYPE;
G_Approval_Workflow_Flag	ap_system_parameters.approval_workflow_flag%TYPE;
-- Removed for bug 4277744
-- G_Ussgl_Transaction_Code	ap_invoices.ussgl_transaction_code%TYPE;
G_Type_1099			po_vendors.type_1099%TYPE;
G_User_Id		 	number;
G_Login_Id			number;
G_Trx_Business_Category         ap_invoices.trx_business_category%TYPE;
G_Org_Id			ap_invoices_all.org_id%TYPE;


PROCEDURE Invoice_Correction(
		X_Invoice_Id            IN      NUMBER,
		X_Invoice_Line_Number   IN      NUMBER,
		X_Corrected_Invoice_Id  IN      NUMBER,
		X_Corrected_Line_Number IN      NUMBER,
		X_Prorate_Lines_Flag    IN      VARCHAR2,
		X_Prorate_Dists_Flag	IN	VARCHAR2,
		X_Correction_Quantity   IN      NUMBER,
		X_Correction_Amount     IN      NUMBER,
		X_Correction_Price      IN      NUMBER,
		X_Line_Tab		IN OUT NOCOPY LINE_TAB_TYPE,
		X_Dist_Tab              IN OUT NOCOPY  DIST_TAB_TYPE,
		X_Calling_Sequence      IN      VARCHAR2) IS


l_line_base_amount ap_invoice_lines.base_amount%TYPE;
l_debug_info	VARCHAR2(100);
current_calling_sequence VARCHAR2(2000);
l_api_name VARCHAR2(30);
l_success  BOOLEAN := TRUE;
l_error_code VARCHAR2(2000);
l_included_tax_amount NUMBER;
Tax_Exception Exception;

BEGIN

   l_api_name := 'Invoice_Correction';

   -- Update the calling sequence (for error message).
   current_calling_sequence := 'AP_INVOICE_CORRECTIONS_PKG.Invoice_Correction<-'||X_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Invoice_Correction(+)');
   END IF;

   l_debug_info := 'Get Invoice and System Options information';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   get_info(X_Invoice_Id => X_invoice_id,
            X_Calling_Sequence => current_calling_sequence);

   --Create a invoice distributions for line level correction.
   IF (x_invoice_line_number IS NOT NULL) THEN

      -- Bug 5597409. Calling eTax
      l_debug_info := 'Calculate Tax on the Invoice';

      l_success := ap_etax_pkg.calling_etax
                    (p_invoice_id    => x_invoice_id,
                     p_calling_mode  => 'CALCULATE',
                     p_all_error_messages => 'N',
                     p_error_code    => l_error_code,
                     p_calling_sequence => current_calling_sequence);

      IF (NOT l_success) THEN
        Raise Tax_Exception;
      END IF;

      l_debug_info := 'Call Get_Proration_Info to get
			distribution proration info';

      l_line_base_amount := ap_utilities_pkg.ap_round_currency(x_correction_amount*g_exchange_rate,
      								g_base_currency_code);

      -- Bug 5597409
      l_debug_info := 'Get Line Included Tax Amount';
      Begin
        Select nvl(included_tax_amount, 0)
        Into l_included_tax_amount
        From ap_invoice_lines_all
        Where invoice_id = x_invoice_id
        And   line_number = x_invoice_line_number;
      Exception
        When Others Then
          l_included_tax_amount := 0;
      End ;

      Get_Dist_Proration_Info(
	        X_Corrected_Invoice_Id => x_corrected_invoice_id,
		X_Corrected_Line_Number => x_corrected_line_number,
	        X_Line_Amount          => x_correction_amount,
		X_Line_Base_Amount     => l_line_base_amount,
                X_Included_Tax_Amount  => l_included_tax_amount, -- Bug 5597409
	        X_Dist_Tab             => x_dist_tab,
	        X_Prorate_Dists_Flag   => x_prorate_dists_flag,
	        X_Calling_Sequence     => current_calling_sequence);


      l_debug_info := 'Call Insert_Invoice_Dists to insert correcting
			invoice distributions';
      Insert_Invoice_Distributions(
		X_Invoice_Id	       => x_invoice_id,
	        X_Invoice_Line_Number  => x_invoice_line_number,
		X_Dist_Tab	       => x_dist_tab,
		X_Line_Amount    => x_correction_amount,
		X_Calling_Sequence     => current_calling_sequence);

      l_debug_info := 'Update the generate_dists to D after the distributions are created';

      UPDATE ap_invoice_lines
      SET generate_dists = 'D'
      WHERE invoice_id = x_invoice_id
      AND line_number = x_invoice_line_number;

   ELSE

      l_debug_info := 'Call Get_Line_Proration_Info to get
			             line proration info';

      Get_Line_Proration_Info(
	     	X_Corrected_Invoice_Id => x_corrected_invoice_id,
	        X_Correction_Amount    => x_correction_amount,
	        X_Line_Tab             => x_line_tab,
	        X_Prorate_Lines_Flag   => x_prorate_lines_flag,
	        X_Calling_Sequence     => current_calling_sequence);


      l_debug_info := 'Call Create_Invoice_Lines to create
			correcting lines and distributions';

      Create_Invoice_Lines_Dists(
		X_Invoice_Id	 	=> x_invoice_id,
		X_Corrected_Invoice_Id  => x_corrected_invoice_id,
		X_Corrected_Line_Number => x_corrected_line_number,
		X_Line_Tab		=> x_line_tab,
		X_Dist_Tab		=> x_dist_tab,
		X_Correction_Quantity	=> x_correction_quantity,
		X_Correction_Price	=> x_correction_price,
		X_Total_Correction_Amount => x_correction_amount,
		X_Prorate_Dists_Flag	=> x_prorate_dists_flag,
		X_Calling_Sequence	=> current_calling_sequence);

   END IF;

   --Clean up the PL/SQL tables.
   x_line_tab.delete;
   x_dist_tab.delete;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Invoice_Correction(-)');
   END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',' Invoice Id = '||to_char(x_invoice_id)
     			  ||', Invoice Line Number = '||to_char(x_invoice_line_number)
			  ||', Corrected Invoice Id = '||to_char(x_corrected_invoice_id)
			  ||', Corrected Line Number = '||to_char(x_corrected_line_number)
 			  ||', Correction amount = '||to_char(x_correction_amount));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;

   --Clean up the PL/SQL tables.
   x_line_tab.delete;
   x_dist_tab.delete;

   APP_EXCEPTION.RAISE_EXCEPTION;

END Invoice_Correction;


PROCEDURE Get_Info(X_Invoice_ID  	IN   NUMBER,
		   X_Calling_Sequence	IN   VARCHAR2
		   ) IS

 current_calling_sequence 	VARCHAR2(2000);
 l_debug_info		VARCHAR2(100);
 l_api_name VARCHAR2(30);

BEGIN

   l_api_name := 'Get_Info';

   current_calling_sequence := 'Get_Info<-'||Current_Calling_Sequence;
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Get_Info(+)');
   END IF;


   --NOTE: Need to test out the logic for income_tax_region
   -- Perf bug 5052493
   -- Original SQL causing shared memory usage of 11 MB. Reduced SQL memory usage by going to base
   -- tables
   SELECT ai.gl_date,
	  ai.batch_id,
          ai.set_of_books_id,
          ai.awt_group_id,
          ai.exchange_rate,
	  fc.precision,
	  fc.minimum_accountable_unit,
	  nvl(asp.allow_awt_flag,'N'),
          nvl(pvs.allow_awt_flag,'N'),
          asp.base_currency_code,
          ai.invoice_currency_code,
          decode(pv.type_1099,'','',
          	 decode(combined_filing_flag,'N',NULL,
          	 	decode(asp.income_tax_region_flag,'Y',pvs.state,
          	 	       asp.income_tax_region))),
          pv.type_1099,
	  nvl(asp.approval_workflow_flag,'N'),
       -- ai.ussgl_transaction_code , - Bug 4277744
	  ai.trx_business_category,
	  ai.org_id
   INTO g_accounting_date,
	g_batch_id,
        g_set_of_books_id,
        g_awt_group_id,
        g_exchange_rate,
        g_precision,
	g_min_acct_unit,
	g_system_allow_awt_flag,
        g_site_allow_awt_flag,
        g_base_currency_code,
        g_invoice_currency_code,
        g_income_tax_region,
	g_type_1099,
	g_approval_workflow_flag,
     --	g_ussgl_transaction_code, - Bug 4277744
	g_trx_business_category,
	g_org_id
   FROM ap_invoices_all ai ,
   	ap_system_parameters asp,
   	ap_suppliers pv,
   	ap_supplier_sites_all pvs,
        fnd_currencies fc -- bug 5052493
   WHERE ai.invoice_id = x_invoice_id
   AND   ai.vendor_site_id = pvs.vendor_site_id
   AND   pv.vendor_id = pvs.vendor_id
   AND   ai.org_id = asp.org_id
   AND   ai.set_of_books_id = asp.set_of_books_id
   AND   ai.invoice_currency_code = fc.currency_code (+);

   SELECT nvl(max(ail.line_number),0)
   INTO g_max_invoice_line_number
   FROM ap_invoice_lines ail
   WHERE ail.invoice_id = x_invoice_id;

   l_debug_info := 'select period for accounting date';

   --Get_current_gl_date will return NULL if the date passed to it doesn't fall in a
   --open period.
   g_period_name := AP_UTILITIES_PKG.get_current_gl_date(g_accounting_date,
   							 g_org_id);

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

   g_user_id := FND_PROFILE.VALUE('USER_ID');

   g_login_id := FND_PROFILE.VALUE('LOGIN_ID');

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Get_Info(-)');
   END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||TO_CHAR(X_Invoice_Id));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   app_exception.raise_exception;

END Get_Info;

FUNCTION Get_Line_Proration_Total(X_Corrected_Invoice_Id IN NUMBER,
				  X_Calling_Sequence     IN VARCHAR2) RETURN NUMBER IS
 l_line_total NUMBER;
 l_debug_info VARCHAR2(1000);
 current_calling_sequence VARCHAR2(2000);
BEGIN

  l_debug_info := 'Get Line Proration Total of corrected invoice';
  current_calling_sequence := 'Get_Line_Proration_Total <- '||x_calling_sequence;

  SELECT sum(ail.amount)
  INTO l_line_total
  FROM ap_invoice_lines_all ail
  WHERE ail.invoice_id = x_corrected_invoice_id
  AND ail.line_type_lookup_code = 'ITEM';  -- Bug 5597409

  RETURN(l_line_total);

EXCEPTION WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Corrected Invoice Id = '||TO_CHAR(X_Corrected_Invoice_Id));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   app_exception.raise_exception;

END;

Procedure Get_Line_Proration_Info(X_Corrected_Invoice_Id IN NUMBER,
	        		  X_Correction_Amount    IN NUMBER,
	        		  X_Line_Tab IN OUT NOCOPY LINE_TAB_TYPE,
	        		  X_Prorate_Lines_Flag   IN VARCHAR2,
	        		  X_Calling_Sequence     IN VARCHAR2) IS

CURSOR Invoice_Lines_Cursor(p_line_proration_total NUMBER) IS
   SELECT ail.line_number,
   	  decode(g_min_acct_unit,'',
   	         round (x_correction_amount * ail.amount/p_line_proration_total,
   	    	        g_precision),
      	         round (((x_correction_amount * ail.amount/p_line_proration_total)/
      	        	    g_min_acct_unit) * g_min_acct_unit)
     	        )
   FROM ap_invoice_lines ail,
   	ap_invoices ai
   WHERE ai.invoice_id = x_corrected_invoice_id
   AND ail.invoice_id = ai.invoice_id
   AND ail.line_type_lookup_code = 'ITEM'  -- Bug 5597409, restricting for Item line only
   --Introduced below condition for bug#9010485
   AND nvl(ail.discarded_flag,'N') = 'N';


l_corrected_line_number  ap_invoice_lines.line_number%TYPE;
l_amount		 ap_invoice_lines.amount%TYPE;
i 			 NUMBER;
l_line_rounded_index     ap_invoice_lines.line_number%TYPE;
l_max_line_amount        ap_invoice_lines.amount%TYPE := 0;
l_sum_line_prorated_amount ap_invoice_lines.amount%TYPE := 0;
l_total_base_amount      ap_invoice_lines.base_amount%TYPE := 0;
l_sum_line_base_amount   ap_invoice_lines.base_amount%TYPE := 0;
l_base_amount		 ap_invoice_lines.base_amount%TYPE;
l_debug_info 		 VARCHAR2(100);
l_line_proration_total   NUMBER;
current_calling_sequence VARCHAR2(2000);
l_api_name VARCHAR2(30);


BEGIN

   l_api_name := 'Get_Line_Proration_Info';

   current_calling_sequence := 'Get_Line_Proration_Info<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Get_Line_Proration_Info(+)');
   END IF;


   IF (x_prorate_lines_flag = 'Y') THEN

      l_line_proration_total := Get_Line_Proration_Total(
             				X_Corrected_Invoice_Id,
	     				current_calling_sequence);

      l_debug_info := 'Open Invoice_Lines_Cursor';
      OPEN Invoice_Lines_Cursor(l_line_proration_total);

      LOOP

         FETCH Invoice_Lines_Cursor INTO l_corrected_line_number,
         				 l_amount;

	 EXIT WHEN Invoice_Lines_Cursor%NOTFOUND;

         x_line_tab(l_corrected_line_number).corrected_line_number := l_corrected_line_number;
         x_line_tab(l_corrected_line_number).line_amount := l_amount;

         --Store the index of max of invoice line with largest amount
         --for proration rounding and base_amount rounding
	 l_debug_info := 'Get rounding index';
         --bug 6629136
         IF (abs(l_amount)>= abs(l_max_line_amount)) THEN

            l_line_rounded_index := l_corrected_line_number;
            l_max_line_amount := x_line_tab(l_corrected_line_number).line_amount;

         END IF;

         l_sum_line_prorated_amount := l_sum_line_prorated_amount + l_amount;

      END LOOP;

      l_debug_info := 'Close Invoice Lines Cursor';
      CLOSE Invoice_Lines_Cursor;

      l_debug_info := 'Update the pl/sql table with the rounding amount';
      IF (x_correction_amount <> l_sum_line_prorated_amount and l_line_rounded_index IS NOT NULL) THEN

        x_line_tab(l_line_rounded_index).line_amount := x_line_tab(l_line_rounded_index).line_amount +
                                                          (x_correction_amount - l_sum_line_prorated_amount);
      END IF;

   END IF;


   IF (g_exchange_rate IS NOT NULL) THEN

       l_total_base_amount := ap_utilities_pkg.ap_round_currency(
      					    	x_correction_amount*g_exchange_rate,
      					  	    g_base_currency_code);

       FOR i in nvl(x_line_tab.first,0) .. nvl(x_line_tab.last,0) LOOP

          IF (x_line_tab.exists(i)) THEN

             l_base_amount := ap_utilities_pkg.ap_round_currency(
      					    	  x_line_tab(i).line_amount*g_exchange_rate,
      					  	      g_base_currency_code);
             x_line_tab(i).base_amount := l_base_amount;

             --Store the index of max of invoice line with largest amount
             --for base_amount rounding
	     l_debug_info := 'Get the rounding index for base amount rounding';
             IF (x_line_tab(i).line_amount >= l_max_line_amount) THEN
               l_line_rounded_index := i;
               l_max_line_amount := x_line_tab(i).line_amount;
             END IF;

             l_sum_line_base_amount := l_sum_line_base_amount + l_base_amount;
          END IF;

       END LOOP;

       IF (l_total_base_amount <> l_sum_line_base_amount and l_line_rounded_index IS NOT NULL) THEN

         x_line_tab(l_line_rounded_index).base_amount := x_line_tab(l_line_rounded_index).base_amount +
                                                          (l_total_base_amount - l_sum_line_base_amount);
         x_line_tab(l_line_rounded_index).rounding_amt := l_total_base_amount - l_sum_line_base_amount;

       END IF;

   END IF; /* g_exchange_rate IS NOT NULL*/

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Get_Line_Proration_Info(-)');
   END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
     	'Corrected Invoice Id = '||to_char(x_corrected_invoice_id)
     	||', Correction Amount = '||to_char(x_correction_amount)
     	||', Prorate Lines Flag = '||x_prorate_lines_flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;

   --Clean up the PL/SQL table
   x_line_tab.delete;

   app_exception.raise_exception;

END Get_Line_Proration_Info;



Procedure Get_Dist_Proration_Info(X_Corrected_Invoice_Id  IN NUMBER,
				  X_Corrected_Line_Number IN NUMBER,
	        		  X_Line_Amount           IN NUMBER,
                                  X_Line_Base_Amount      IN NUMBER,
                                  X_Included_Tax_Amount   IN NUMBER,
	        		  X_Dist_Tab              IN OUT NOCOPY DIST_TAB_TYPE,
	        		  X_Prorate_Dists_Flag    IN VARCHAR2,
	        		  X_Calling_Sequence      IN VARCHAR2) IS

CURSOR Invoice_Dists_Cursor(p_proration_total IN  NUMBER) IS
   SELECT aid.invoice_distribution_id,
/*   	  decode(g_min_acct_unit,'',
   	         round ((x_line_amount + nvl(ail.included_tax_amount,0)) * aid.amount/p_proration_total,
   	    	        g_precision),
      	         round ((((x_line_amount + nvl(ail.included_tax_amount,0)) * aid.amount/p_proration_total)/
      	        	    g_min_acct_unit) * g_min_acct_unit)
     	        )   	  , */
           decode(g_min_acct_unit,'',
                 round ((x_line_amount - x_included_tax_amount)   * aid.amount/p_proration_total,
                        g_precision),
                 round ((((x_line_amount - x_included_tax_amount) * aid.amount/p_proration_total)/
                            g_min_acct_unit) * g_min_acct_unit)
                )         ,

          ap_invoice_distributions_s.nextval
   FROM ap_invoice_lines ail,
   	ap_invoice_distributions aid
   WHERE ail.invoice_id = x_corrected_invoice_id
   AND ail.line_number = x_corrected_line_number
   AND aid.invoice_id = ail.invoice_id
   AND aid.invoice_line_number = ail.line_number
   -- Bug 5597409. Add the restriction for Item distribution only
   AND aid.line_type_lookup_code = 'ITEM'
   AND aid.prepay_distribution_id IS NULL
   --Introduced below condition for bug#9010485
   AND nvl(aid.reversal_flag,'N') = 'N';


l_corrected_inv_dist_id  ap_invoice_distributions.invoice_distribution_id%TYPE;
l_invoice_distribution_id ap_invoice_distributions.invoice_distribution_id%TYPE;
l_amount		 ap_invoice_distributions.amount%TYPE;
l_max_dist_amount	 ap_invoice_distributions.amount%TYPE := 0;
l_rounding_index	 ap_invoice_distributions.invoice_distribution_id%TYPE;
l_sum_prorated_amount    ap_invoice_distributions.amount%TYPE := 0;
l_base_amount		 ap_invoice_distributions.base_amount%TYPE := 0;
l_sum_base_amount	 ap_invoice_distributions.base_amount%TYPE := 0;
i 			 NUMBER;
l_debug_info 		 VARCHAR2(100);
current_calling_sequence VARCHAR2(2000);
l_api_name   		 VARCHAR2(30);
l_dist_proration_total   NUMBER;

BEGIN

   l_api_name := 'Get_Dist_Proration_Info';
   current_calling_sequence := 'Get_Dist_Proration_Info<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Get_Dist_Proration_Info(+)');
   END IF;


   IF (x_prorate_dists_flag = 'Y') THEN

      l_debug_info := 'Get Distribution Proration total from corrected line';
      l_dist_proration_total := Get_Dist_Proration_Total(
      					X_Corrected_Invoice_Id,
      			       	        X_Corrected_Line_Number,
			                Current_Calling_Sequence);


      l_debug_info := 'Open Invoice_Dists_Cursor(l_dist_proration_total)';
      OPEN Invoice_Dists_Cursor(l_dist_proration_total);

      l_debug_info := 'Populate distribution proration info';
      LOOP

         FETCH Invoice_Dists_Cursor INTO l_corrected_inv_dist_id,
         				 l_amount,
					 l_invoice_distribution_id;


         EXIT WHEN Invoice_Dists_Cursor%NOTFOUND;

         x_dist_tab(l_invoice_distribution_id).corrected_inv_dist_id := l_corrected_inv_dist_id;
         x_dist_tab(l_invoice_distribution_id).amount := l_amount;
	 x_dist_tab(l_invoice_distribution_id).invoice_distribution_id := l_invoice_distribution_id;

        --Bug6720791
         IF ((l_amount >= l_max_dist_amount) and (l_amount >= 0))
           OR((l_amount < l_max_dist_amount) and (l_amount < 0 ) ) THEN
           l_rounding_index := l_invoice_distribution_id;
           l_max_dist_amount := l_amount;
         END IF;

         l_sum_prorated_amount := l_sum_prorated_amount + l_amount;

      END LOOP;

      CLOSE Invoice_Dists_Cursor;

      l_debug_info := 'Perform Proration rounding';
      IF (l_sum_prorated_amount <> x_line_amount and l_rounding_index IS NOT NULL) THEN

        x_dist_tab(l_rounding_index).amount := x_dist_tab(l_rounding_index).amount +
                                                 (x_line_amount - l_sum_prorated_amount);

      END IF;

   END IF;

   IF (g_exchange_rate IS NOT NULL) THEN

      l_debug_info := 'Calculate Base_amount and Base_amount rounding';
      FOR i in nvl(x_dist_tab.first,0) .. nvl(x_dist_tab.last,0) LOOP

         IF (x_dist_tab.exists(i)) THEN

             l_base_amount := ap_utilities_pkg.ap_round_currency(
      					x_dist_tab(i).amount*g_exchange_rate,
      					g_base_currency_code);

             x_dist_tab(i).base_amount := l_base_amount ;

             l_sum_base_amount := l_sum_base_amount + l_base_amount;

         END IF;

      END LOOP;

      IF (x_line_base_amount <> l_sum_base_amount and l_rounding_index is not null) THEN

         x_dist_tab(l_rounding_index).base_amount := x_dist_tab(l_rounding_index).base_amount +
                                                        (x_line_base_amount - l_sum_base_amount);
         x_dist_tab(l_rounding_index).rounding_amt := x_line_base_amount - l_sum_base_amount;

      END IF;

   END IF;  /*g_exchange_rate IS NOT NULL*/


   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Get_Dist_Proration_Info(-)');
   END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS',
     	'Corrected Invoice Id = '||to_char(x_corrected_invoice_id)
     	||', Line Amount = '||to_char(x_line_amount)
     	||', Prorate Distributions Flag = '||x_prorate_dists_flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;

   --Clean up the PL/SQL table
   x_dist_tab.delete;

   app_exception.raise_exception;

END Get_Dist_Proration_Info;


FUNCTION Get_Dist_Proration_Total(
		X_Corrected_Invoice_id  IN NUMBER,
		X_Corrected_Line_Number IN NUMBER,
		X_Current_Calling_Sequence IN VARCHAR2) RETURN NUMBER IS

 l_dist_total NUMBER;
 l_debug_info VARCHAR2(1000);
 current_calling_sequence VARCHAR2(2000);
BEGIN

   Current_Calling_Sequence := 'Get_Dist_Proration_Total <- '||x_current_calling_sequence;
   l_debug_info := 'Get the total dist proration total';

   SELECT sum(aid.amount)
   INTO l_dist_total
   FROM ap_invoice_distributions_all aid
   WHERE aid.invoice_id = x_corrected_invoice_id
   AND aid.invoice_line_number = x_corrected_line_number
   AND aid.line_type_lookup_code = 'ITEM'  -- Bug 5597409. Restrict to 'ITEM' type only
   AND aid.prepay_distribution_id IS NULL;

   RETURN(l_dist_total);

EXCEPTION WHEN OTHERS THEN
  IF (SQLCODE <> -20001) THEN
    FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
    FND_MESSAGE.SET_TOKEN('PARAMETERS',
           'Corrected Invoice Id = '||to_char(x_corrected_invoice_id)
           ||',Corrected Line Number = '||to_char(x_corrected_line_number));
    FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
  END IF;

  app_exception.raise_exception;

END Get_Dist_Proration_Total;


Procedure Create_Invoice_Lines_Dists(
		X_Invoice_Id		  IN		NUMBER,
		X_Corrected_Invoice_Id	  IN		NUMBER,
		X_Corrected_Line_Number   IN		NUMBER,
		X_Line_Tab		  IN OUT NOCOPY	LINE_TAB_TYPE,
		X_Dist_Tab		  IN OUT NOCOPY	DIST_TAB_TYPE,
		--bugfix:4700522
		X_Prorate_Dists_Flag	  IN		VARCHAR2,
		X_Correction_Quantity	  IN		NUMBER,
		X_Correction_Price	  IN		NUMBER,
		X_Total_Correction_Amount IN		NUMBER,
		X_Calling_Sequence	  IN		VARCHAR2) IS

l_invoice_line_number	 ap_invoice_lines.line_number%TYPE;
l_sum_prorated_amount	 ap_invoice_lines.amount%TYPE;
l_max_line_amount	 ap_invoice_lines.amount%TYPE;
l_line_rounded_index	 ap_invoice_lines.line_number%TYPE;
l_line_rounding_amount   ap_invoice_lines.amount%TYPE;
l_debug_info		 VARCHAR2(100);
current_calling_sequence VARCHAR2(2000);
l_api_name 		 VARCHAR2(30);
l_line_base_amount       NUMBER;
l_success                BOOLEAN := TRUE;
l_error_code             VARCHAR2(2000);
Tax_Exception            Exception;


BEGIN

   l_api_name := 'Create_Invoice_Lines_Dists';

   current_calling_sequence := 'Create_Invoice_Lines_Dists<-'||x_calling_sequence;


   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Create_Invoice_Lines_Dists(+)');
   END IF;


   l_invoice_line_number := g_max_invoice_line_number + 1;

   l_debug_info := 'Insert Invoice Lines for this correction';

   FOR i IN nvl(x_line_tab.first,0).. nvl(x_line_tab.last,0) LOOP

      IF (x_line_tab.exists(i)) THEN

         x_line_tab(i).line_number := l_invoice_line_number;

         Insert_Invoice_Line(X_Invoice_Id => x_invoice_id,
      			     X_Invoice_Line_Number   => l_invoice_line_number,
      			     X_Corrected_Invoice_Id  => x_corrected_invoice_id,
      			     X_Corrected_Line_Number => x_line_tab(i).corrected_line_number,
      			     X_Amount		     => x_line_tab(i).line_amount,
      			     X_Base_Amount	     => x_line_tab(i).base_amount,
                     	     X_Rounding_Amt          => x_line_tab(i).rounding_amt,
      			     X_Correction_Quantity   => x_correction_quantity,
       			     X_Correction_Price	     => x_correction_price,
      			     X_Calling_Sequence      => current_calling_sequence);

        l_invoice_line_number := l_invoice_line_number + 1;

      END IF;

   END LOOP;

   -- Bug 5597409. Calling eTax
   l_debug_info := 'Calculate Tax on the Invoice';


   l_success := ap_etax_pkg.calling_etax
                     (p_invoice_id    => x_invoice_id,
                      p_calling_mode  => 'CALCULATE',
                      p_all_error_messages => 'N',
                      p_error_code    => l_error_code,
                      p_calling_sequence => current_calling_sequence);

   IF (NOT l_success) THEN
     Raise Tax_Exception;
   END IF;

   FOR i IN nvl(x_line_tab.first,0).. nvl(x_line_tab.last,0) LOOP

     IF (x_line_tab.exists(i)) THEN

      Begin
        Select nvl(included_tax_amount, 0)
        Into x_line_tab(i).included_tax_amount
        From ap_invoice_lines_all
        Where invoice_id = x_invoice_id
        And   line_number = x_line_tab(i).line_number;

      Exception
        When Others Then
           x_line_tab(i).included_tax_amount := 0;
      End ;

     END IF;

   END LOOP;

   FOR i IN nvl(x_line_tab.first,0).. nvl(x_line_tab.last,0) LOOP

     IF (x_line_tab.exists(i)) THEN

        Get_Dist_Proration_Info(
	        X_Corrected_Invoice_Id => x_corrected_invoice_id,
		X_Corrected_Line_Number  =>x_line_tab(i).corrected_line_number,
	        X_Line_Amount   	 => x_line_tab(i).line_amount,
                X_Line_Base_Amount   => x_line_tab(i).base_amount,
                X_Included_Tax_Amount  => x_line_tab(i).included_tax_amount,
	        X_Dist_Tab             => x_dist_tab,
	        X_Prorate_Dists_Flag   => x_prorate_dists_flag,
	        X_Calling_Sequence     => current_calling_sequence);

        Insert_Invoice_Distributions(
	 			   X_Invoice_ID	=> x_invoice_id,
				   X_Invoice_Line_Number => x_line_tab(i).line_number,
				   X_Dist_Tab		 => x_dist_tab,
				   X_Line_Amount	 => x_line_tab(i).line_amount,
				   X_Calling_Sequence	 => current_calling_sequence);

         l_invoice_line_number := l_invoice_line_number + 1;

      END IF;

   END LOOP;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Create_Invoice_Lines_Dists(-)');
   END IF;



EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_Id = '||to_char(x_invoice_id)
		||', Corrected Invoice Id = '||to_char(x_corrected_invoice_id)
		||', Corrected line Number = '||to_char(x_corrected_line_number)
		||', Correction Quantity = '||to_char(x_correction_quantity)
		||', Correction Price = '||to_char(x_correction_price)
		||', Total Correction Amount = '||to_char(x_total_correction_amount));

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   --Clean up the PL/SQL tables.
   x_line_tab.delete;
   x_dist_tab.delete;

   APP_EXCEPTION.RAISE_EXCEPTION;

END Create_Invoice_Lines_Dists;



Procedure Insert_Invoice_Line (X_Invoice_Id 	 	IN	NUMBER,
			       X_Invoice_Line_Number	IN	NUMBER,
			       X_Corrected_Invoice_Id   IN      NUMBER,
			       X_Corrected_Line_Number  IN	NUMBER,
			       X_Amount			IN	NUMBER,
			       X_Base_Amount		IN 	NUMBER,
    		               X_Rounding_Amt      	IN  	NUMBER,
			       X_Correction_Quantity	IN      NUMBER,
			       X_Correction_Price	IN	NUMBER,
			       X_Calling_Sequence	IN	VARCHAR2) IS

 current_calling_sequence	VARCHAR2(2000);
 l_debug_info			VARCHAR2(100);
 l_api_name			VARCHAR2(30);

BEGIN

   l_api_name := 'Insert_Invoice_Line';

   current_calling_sequence := 'Insert_Invoice_Line<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Insert_Invoice_Lines(+)');
   END IF;


   l_debug_info := 'Inserting non-matched Item Line';

   INSERT INTO AP_INVOICE_LINES_ALL (
	      INVOICE_ID,
	      LINE_NUMBER,
	      LINE_TYPE_LOOKUP_CODE,
	      REQUESTER_ID,
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
	      PROJECT_ID,
	      TASK_ID,
	      EXPENDITURE_TYPE,
	      EXPENDITURE_ITEM_DATE,
	      EXPENDITURE_ORGANIZATION_ID,
	      PA_QUANTITY,
	      PA_CC_AR_INVOICE_ID,
	      PA_CC_AR_INVOICE_LINE_NUM,
	      PA_CC_PROCESSED_CODE,
	      AWARD_ID,
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
	      TAX_CLASSIFICATION_CODE, --Bug 8717668
	      SHIP_TO_LOCATION_ID,
	      PRIMARY_INTENDED_USE,
	      PRODUCT_FISC_CLASSIFICATION,
	      TRX_BUSINESS_CATEGORY,
	      PRODUCT_TYPE,
	      PRODUCT_CATEGORY,
	      USER_DEFINED_FISC_CLASS,
	      PURCHASING_CATEGORY_ID)
   SELECT     x_invoice_id,				--invoice_id
	      x_invoice_line_number,    		--line_number
	      ail.line_type_lookup_code,		--line_type_lookup_code
 	      ail.requester_id,				--requester_id
 	      ail.description,				--description
 	      'HEADER CORRECTION',			--line_source
 	      ail.org_id,				--org_id
 	      ail.inventory_item_id,			--inventory_item_id
 	      ail.item_description,			--item_description
 	      ail.serial_number,			--serial_number
 	      ail.manufacturer,				--manufacturer
 	      ail.model_number,				--model_number
 	      'D',					--generate_dists
 	      'LINE_CORRECTION',			--match_type
 	      NULL,					--distribution_set_id
 	      ail.account_segment,			--account_segment
 	      ail.balancing_segment,			--balancing_segment
 	      ail.cost_center_segment,			--cost_center_segment
 	      ail.overlay_dist_code_concat,		--overlay_dist_code_concat
 	      ail.default_dist_ccid,			--default_dist_ccid
 	      'N',					--prorate_across_all_items
 	      NULL,					--line_group_number
 	      g_accounting_date,			--accounting_date
 	      g_period_name,				--period_name
 	      'N',					--deferred_acctg_flag
 	      NULL,					--def_acctg_start_date
 	      NULL,					--def_acctg_end_date
 	      NULL,					--def_acctg_number_of_periods
 	      NULL,					--def_acctg_period_type
 	      g_set_of_books_id,			--set_of_books_id
 	      x_amount,					--amount
 	      x_base_amount, 				--base_amount
 	      x_rounding_amt,				--rounding_amount
 	      x_correction_quantity,			--quantity_invoiced
 	      decode(x_correction_quantity,'','',
 	      	     ail.unit_meas_lookup_code),	--unit_meas_lookup_code
 	      x_correction_price,			--unit_price
 	      decode(g_approval_workflow_flag,'Y',
 	             'REQUIRED','NOT REQUIRED'),        --wf_approval_status
           -- Removed for bug 4277744
 	   -- g_ussgl_transaction_code, 		--ussgl_transaction_code
 	      'N',					--discarded_flag
 	      NULL,					--original_amount
 	      NULL,					--original_base_amount
 	      NULL,					--original_rounding_amt
 	      'N',					--cancelled_flag
 	      g_income_tax_region,			--income_tax_region
 	      g_type_1099,				--type_1099
 	      NULL,					--stat_amount
 	      NULL,					--prepay_invoice_id
 	      NULL,					--prepay_line_number
 	      NULL,					--invoice_includes_prepay_flag
 	      x_corrected_invoice_id,			--corrected_inv_id
 	      x_corrected_line_number,			--corrected_line_number
 	      NULL,					--po_header_id
 	      NULL,					--po_line_id
 	      NULL,					--po_release_id
 	      NULL,					--po_line_location_id
 	      NULL,					--po_distribution_id
 	      NULL,					--rcv_transaction_id
 	      NULL,					--final_match_flag
 	      ail.assets_tracking_flag,			--assets_tracking_flag
 	      ail.asset_book_type_code,			--asset_book_type_code
 	      ail.asset_category_id,			--asset_category_id
 	      ail.project_id,				--project_id
 	      ail.task_id,				--task_id
 	      ail.expenditure_type,			--expenditure_type
 	      ail.expenditure_item_date,		--expenditure_item_date
 	      ail.expenditure_organization_id,		--expenditure_organization_id
 	      x_correction_quantity,   			--pa_quantity
 	      NULL,					--pa_cc_ar_invoice_id
 	      NULL,					--pa_cc_ar_invoice_line_num
 	      NULL,					--pa_cc_processed_code
 	      ail.award_id,				--award_id
 	      g_awt_group_id,				--awt_group_id
 	      ail.reference_1,				--reference_1
      	      ail.reference_2,				--reference_2
              ail.receipt_verified_flag,		--receipt_verified_flag
      	      ail.receipt_required_flag,		--receipt_required_flag
      	      ail.receipt_missing_flag,         	--receipt_missing_flag
      	      ail.justification,			--justification
      	      ail.expense_group,			--expense_group
              ail.start_expense_date,			--start_expense_date
      	      ail.end_expense_date,			--end_expense_date
    	      ail.receipt_currency_code,		--receipt_currency_code
    	      ail.receipt_conversion_rate,		--receipt_conversion_rate
       	      ail.receipt_currency_amount,		--receipt_currency_amount
      	      ail.daily_amount,				--daily_amount
    	      ail.web_parameter_id,			--web_parameter_id
      	      ail.adjustment_reason,			--adjustment_reason
       	      ail.merchant_document_number,		--merchant_document_number
      	      ail.merchant_name,			--merchant_name
    	      ail.merchant_reference,			--merchant_reference
      	      ail.merchant_tax_reg_number,		--merchant_tax_reg_number
       	      ail.merchant_taxpayer_id,			--merchant_taxpayer_id
      	      ail.country_of_supply,  			--country_of_supply
    	      ail.credit_card_trx_id,			--credit_card_trx_id
     	      ail.company_prepaid_invoice_id,		--company_prepaid_invoice_id
       	      ail.cc_reversal_flag,			--cc_reversal_flag
       	      ail.attribute_category,			--attribute_category
       	      ail.attribute1,				--attribute1
       	      ail.attribute2,				--attribute2
       	      ail.attribute3,				--attribute3
       	      ail.attribute4,				--attribute4
       	      ail.attribute5,				--attribute5
       	      ail.attribute6,				--attribute6
       	      ail.attribute7,				--attribute7
       	      ail.attribute8,				--attribute8
       	      ail.attribute9,				--attribute9
       	      ail.attribute10,				--attribute10
       	      ail.attribute11,				--attribute11
       	      ail.attribute12,				--attribute12
       	      ail.attribute13,				--attribute13
       	      ail.attribute14,				--attribute14
       	      ail.attribute15,				--attribute15
       	      /*OPEN ISSUE 1*/
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
      	      X_GLOBAL_ATTRIBUTE20, */ 			--global_attribute20
      	      sysdate,					--creation_date
      	      g_user_id,				--created_by
      	      g_user_id,				--last_update_by
      	      sysdate,					--last_update_date
      	      g_login_id,				--last_update_login
      	      NULL,					--program_application_id
      	      NULL,					--program_id
      	      NULL,					--program_update_date
      	      NULL,  	      		       		--request_id
	      --ETAX: Invwkb
	      TAX_CLASSIFICATION_CODE,         --Tax Classification Code Bug 8717668
	      AIL.SHIP_TO_LOCATION_ID,         --ship_to_location_id
	      AIL.PRIMARY_INTENDED_USE,        --primary_intended_use
	      AIL.PRODUCT_FISC_CLASSIFICATION, --product_fisc_classification
	      G_TRX_BUSINESS_CATEGORY,         --trx_business_category
	      AIL.PRODUCT_TYPE,                --product_type
	      AIL.PRODUCT_CATEGORY,            --product_category
	      AIL.USER_DEFINED_FISC_CLASS,     --user_defined_fisc_class
	      AIL.PURCHASING_CATEGORY_ID       --purchasing_category_id
   FROM ap_invoices ai,
	ap_invoice_lines ail
   WHERE ai.invoice_id = ail.invoice_id
   AND   ai.invoice_id = x_corrected_invoice_id
   AND   ail.line_number = x_corrected_line_number;


   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Insert_Invoice_Lines(-)');
   END IF;


  EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_Id = '||to_char(x_invoice_id)
			  ||', Invoice Line Number = '||to_char(x_invoice_line_number)
			  ||', Corrected Invoice Id = '||to_char(x_corrected_invoice_id)
			  ||', Corrected line Number = '||to_char(x_corrected_line_number));

     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;

   APP_EXCEPTION.RAISE_EXCEPTION;


END Insert_Invoice_Line;



PROCEDURE Insert_Invoice_Distributions (X_Invoice_ID		IN 	NUMBER,
					X_Invoice_Line_Number	IN	NUMBER,
					X_Dist_Tab		IN OUT NOCOPY Dist_Tab_Type,
					X_Line_Amount		IN      NUMBER,
					X_Calling_Sequence	IN	VARCHAR2) IS
l_distribution_line_number	NUMBER := 1;
l_rounding_amount		NUMBER;
l_sum_prorated_amount		NUMBER := 0;
l_rounded_index      ap_invoice_distributions.invoice_distribution_id%type;
i				NUMBER;
l_max_dist_amount		NUMBER := 0;
l_max_distribution_id ap_invoice_distributions.invoice_distribution_id%type;
l_debug_info			VARCHAR2(100);
current_calling_sequence	VARCHAR2(2000);
l_api_name			VARCHAR2(30);

BEGIN

  l_api_name := 'Insert_Invoice_Distributions';

  current_calling_sequence := 'Insert_Invoice_Distributions <-'||current_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Insert_Invoice_Distributions(+)');
  END IF;

  l_debug_info := 'Insert Invoice Distributions';

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  FOR i in nvl(X_Dist_tab.FIRST, 0) .. nvl(X_Dist_tab.LAST, 0) LOOP

    IF (x_dist_tab.exists(i)) THEN


       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       INSERT INTO ap_invoice_distributions(
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
             -- Removed for bug 4277744
             -- ussgl_transaction_code,
             -- ussgl_trx_code_context,
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
                project_id,
                task_id,
                expenditure_type,
                expenditure_item_date,
                expenditure_organization_id,
                pa_quantity,
                pa_addition_flag,
                pa_cc_ar_invoice_id,
                pa_cc_ar_invoice_line_num,
                pa_cc_processed_code,
                award_id,
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
		intended_use,
		--Freight and Special Charges
		rcv_charge_addition_flag)
        SELECT  g_batch_id,	       			--batch_id
      	        x_invoice_id,	       			--invoice_id
      	        x_invoice_line_number, 			--invoice_line_number
         	NVL(x_dist_tab(i).invoice_distribution_id,
                                  ap_invoice_distributions_s.nextval),  --invoice_distribution_id
      		l_distribution_line_number,   		--distribution_line_number
      		aid.line_type_lookup_code,    		--line_type_lookup_code
       	        ail.item_description,         		--description
      	        'DIST_CORRECTION',            		--dist_match_type
      		'PERMANENT', 		      		--distribution_class
      		ail.org_id,		      		--org_id
                aid.dist_code_combination_id, 		--dist_code_combination_id
                ail.accounting_date,			--accounting_date
      		ail.period_name, 			--period_name
       	        'N',					--accrual_posted_flag
       	        'N',					--cash_posted_flag
      		NULL,					--amount_to_post
      		NULL,					--base_amount_to_post
      		NULL,					--posted_amount
      		NULL,					--posted_base_amount
      		NULL,					--je_batch_id
      		NULL,					--cash_je_batch_id
      		'N',					--posted_flag
      		NULL,					--accounting_event_id
      		NULL,					--upgrade_posted_amt
      		NULL,					--upgrade_base_posted_amt
      		g_set_of_books_id,		--set_of_books_id
      		x_dist_tab(i).amount,	--amount
      		x_dist_tab(i).base_amount,	--base_amount
		    x_dist_tab(i).rounding_amt,	--rounding_amount
      		NULL,					--match_status_flag
      		'N',					--encumbered_flag
      		NULL,					--packet_id
             -- Removed for bug 4277744
      	     --	ail.ussgl_transaction_code,		--ussgl_transaction_code
      	     --	NULL,					--ussgl_trx_code_context
      		'N',					--reversal_flag
      		NULL,					--parent_reversal_id
      		'N',					--cancellation_flag
      		aid.income_tax_region,			--income_tax_region
      		aid.type_1099, 				--type_1099
      		ap_utilities_pkg.ap_round_currency(
                   (x_dist_tab(i).amount * aid.stat_amount)/aid.amount,
                    'STAT'),            	        --stat_amount
      		NULL,					--charge_applicable_to_dist_id
      		NULL,					--prepay_amount_remaining
      		NULL,					--prepay_distribution_id
     	        aid.invoice_id,				--parent_invoice_id
      		x_dist_tab(i).corrected_inv_dist_id,	--corrected_invoice_dist_id
      		NULL,					--corrected_quantity
      		NULL,					--other_invoice_id
      		NULL,					--po_distribution_id
      		NULL,					--rcv_transaction_id
         	NULL,					--unit_price
      		NULL,					--matched_uom_lookup_code
      		NULL,					--quantity_invoiced
      		NULL,					--final_match_flag
      		NULL,					--related_id
      		'U',					--assets_addition_flag
      		decode(gcc.account_type,'E',
      		       ail.assets_tracking_flag,
      		       'A','Y','N'),    		--assets_tracking_flag
      		decode(decode(gcc.account_type,'E',
      			      ail.assets_tracking_flag,'A','Y','N'),
      		     'Y',ail.asset_book_type_code,NULL),--asset_book_type_code
      		decode(decode(gcc.account_type,'E',
      			      ail.assets_tracking_flag,'A','Y','N'),
      		       'Y',ail.asset_category_id,NULL), --asset_category_id
    		aid.project_id,	        		--project_id
		aid.task_id,  	        		--task_id
		aid.expenditure_type,   		--expenditure_type
      		aid.expenditure_item_date,      	--expenditure_item_date
      		aid.expenditure_organization_id,	--expenditure_organization_id
      		x_dist_tab(i).amount * aid.pa_quantity/aid.amount,  --pa_quantity
      		decode(aid.project_id,NULL, 'E', 'N'), 	--pa_addition_flag
      		NULL,					--pa_cc_ar_invoice_id
      		NULL,					--pa_cc_ar_invoice_line_num
      		NULL,					--pa_cc_processed_code
      		aid.award_id,				--award_id
      		NULL,					--gms_burdenable_raw_cost
      		NULL,					--awt_flag
      		decode(g_system_allow_awt_flag,'Y',
      		       decode(g_site_allow_awt_flag,'Y',ail.awt_group_id,NULL),
      		       NULL), 				--awt_group_id
      		NULL,					--awt_tax_rate_id
      		NULL,					--awt_gross_amount
      		NULL,					--awt_invoice_id
      		NULL,					--awt_origin_group_id
      		NULL,					--awt_invoice_payment_id
      		NULL,					--awt_withheld_amt
      		'N',					--inventory_transfer_status
      		aid.reference_1,			--reference_1
      		aid.reference_2,			--reference_2
                aid.receipt_verified_flag,		--receipt_verified_flag
      		aid.receipt_required_flag,		--receipt_required_flag
      		aid.receipt_missing_flag,       	--receipt_missing_flag
      		aid.justification,			--justification
      		aid.expense_group,			--expense_group
       		aid.start_expense_date,			--start_expense_date
      		aid.end_expense_date,			--end_expense_date
    		aid.receipt_currency_code,		--receipt_currency_code
    		aid.receipt_conversion_rate,		--receipt_conversion_rate
       		aid.receipt_currency_amount,		--receipt_currency_amount
      		aid.daily_amount,			--daily_amount
    		aid.web_parameter_id,			--web_parameter_id
      		aid.adjustment_reason,			--adjustment_reason
       		aid.merchant_document_number,		--merchant_document_number
      		aid.merchant_name,			--merchant_name
    		aid.merchant_reference,			--merchant_reference
      		aid.merchant_tax_reg_number,		--merchant_tax_reg_number
       		aid.merchant_taxpayer_id,		--merchant_taxpayer_id
      		aid.country_of_supply,  		--country_of_supply
    		aid.credit_card_trx_id,			--credit_card_trx_id
     		aid.company_prepaid_invoice_id,		--company_prepaid_invoice_id
       		aid.cc_reversal_flag,			--cc_reversal_flag
       		aid.attribute_category,			--attribute_category
       		aid.attribute1,				--attribute1
       		aid.attribute2,				--attribute2
       		aid.attribute3,				--attribute3
       		aid.attribute4,				--attribute4
       		aid.attribute5,				--attribute5
       		aid.attribute6,				--attribute6
       		aid.attribute7,				--attribute7
       		aid.attribute8,				--attribute8
       		aid.attribute9,				--attribute9
       		aid.attribute10,			--attribute10
       		aid.attribute11,			--attribute11
       		aid.attribute12,			--attribute12
       		aid.attribute13,			--attribute13
       		aid.attribute14,			--attribute14
       		aid.attribute15,			--attribute15
       		/* X_GLOBAL_ATTRIBUTE_CATEGORY,
		X_GLOBAL_ATTRIBUTE1,
      		X_GLOBAL_ATTRIBUTE2,
		X_GLOBAL_ATTRIBUTE3,
      		X_GLOBAL_ATTRIBUTE4,
      		X_GLOBAL_ATTRIBUTE5,
      		X_GLOBAL_ATTRIBUTE6,
      		X_GLOBAL_ATTRIBUTE7,
       		X_GLOBAL_ATTRIBUTE8,
      		X_GLOBAL_ATTRIBUTE9,
       		X_GLOBAL_ATTRIBUTE10,
      		X_GLOBAL_ATTRIBUTE11,
      		X_GLOBAL_ATTRIBUTE12,
      		X_GLOBAL_ATTRIBUTE13,
      		X_GLOBAL_ATTRIBUTE14,
      		X_GLOBAL_ATTRIBUTE15,
      		X_GLOBAL_ATTRIBUTE16,
      		X_GLOBAL_ATTRIBUTE17,
      		X_GLOBAL_ATTRIBUTE18,
      		X_GLOBAL_ATTRIBUTE19,
      		X_GLOBAL_ATTRIBUTE20, */
      		ail.created_by,				--created_by
      		sysdate,				--creation_date
      		ail.last_updated_by,			--last_updated_by
      		sysdate,				--last_update_date
      		ail.last_update_login,			--last_update_login
      		NULL,					--program_application_id
      		NULL,					--program_id
      		NULL,					--program_update_date
      		NULL,					--request_id
		--ETAX: Invwkb
		aid.intended_use,			--intended_use
		'N'
      	  FROM  ap_invoice_distributions aid,
      	        ap_invoice_lines ail,
      	        gl_code_combinations gcc
  	 WHERE ail.invoice_id = x_invoice_id
  	 AND   ail.line_number = x_invoice_line_number
	 AND   aid.invoice_id = ail.corrected_inv_id
	 AND   aid.invoice_line_number = ail.corrected_line_number
	 AND   aid.invoice_distribution_id  = x_dist_tab(i).corrected_inv_dist_id
	 AND   gcc.code_combination_id = aid.dist_code_combination_id;


	   l_distribution_line_number := l_distribution_line_number + 1;

      END IF; /*x_dist_tab.exists(i))*/

    END LOOP;


    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_INVOICE_CORRECTIONS_PKG.Insert_Invoice_Distributions(-)');
    END IF;


EXCEPTION
 WHEN OTHERS THEN

   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Batch_Id = '||TO_CHAR(g_Batch_Id)
     	        ||', Invoice_id = '||TO_CHAR(X_invoice_id)
		||', Invoice Line Number = '||X_Invoice_Line_Number
		||', Dist_num = '||l_distribution_line_number);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   --Clean up the PL/SQL tables.
   X_DIST_TAB.DELETE;

   APP_EXCEPTION.RAISE_EXCEPTION;

END Insert_Invoice_Distributions;


END AP_INVOICE_CORRECTIONS_PKG;

/
