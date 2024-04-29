--------------------------------------------------------
--  DDL for Package Body AP_RETAINAGE_RELEASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_RETAINAGE_RELEASE_PKG" As
/* $Header: apcwrelb.pls 120.4.12010000.2 2008/08/08 03:08:07 sparames ship $ */

  -- FND logging global variables

  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_RETAINAGE_RELEASE_PKG';
  G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
  G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
  G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
  G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
  G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
  G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

  G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED      CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR           CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION       CONSTANT NUMBER   := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT           CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE       CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT       CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_RETAINAGE_RELEASE_PKG.';

Cursor c_release_invoice_info (c_invoice_id IN ap_invoices_all.invoice_id%type) Is
	Select ai.invoice_currency_code,
        --Bug6893516 Exchange rate should be 1 for base currency invoices
	       nvl(ai.exchange_rate,1) exchange_rate,
	       ai.gl_date,
	       ai.vendor_id,
	       ai.vendor_site_id,
	       ai.org_id
	  From ap_invoices_all ai
	 Where invoice_id = c_invoice_id;

g_release_invoice_info	c_release_invoice_info%rowtype;
g_period_name		gl_period_statuses.period_name%TYPE;
g_user_id 		NUMBER;
g_login_id 		NUMBER;

TYPE releaseLinesType IS TABLE OF ap_invoice_lines_all%rowtype INDEX BY PLS_INTEGER;
TYPE relDistType IS TABLE OF ap_invoice_distributions_all%rowtype INDEX BY PLS_INTEGER;

Procedure Lock_Retained_Invoices (x_retained_lines_tab 	IN  retainedLinesType,
				  x_lock_status		OUT NOCOPY BOOLEAN);


Procedure Unlock_Retained_Invoices (x_retained_lines_tab 	IN  retainedLinesType,
				    x_lock_status		OUT NOCOPY BOOLEAN);

Procedure create_release_lines (x_invoice_id			IN ap_invoices_all.invoice_id%TYPE,
				x_release_amount		IN number,
				x_release_amount_remaining	IN number,
				x_retained_lines_tab		IN retainedLinesType,
				x_released_lines_tab		OUT NOCOPY releaseLinesType);

Procedure create_release_distributions (x_release_amount		IN number,
					x_release_amount_remaining	IN number,
					x_released_lines_tab		IN releaseLinesType);

Procedure final_release_rounding (x_line_location_id    IN po_line_locations_all.line_location_id%type,
				  x_max_invoice_dist_id IN NUMBER);

Procedure Update_PO_Shipment_Dists
			(x_line_location_id	IN ap_invoice_lines_all.po_line_location_id%type,
			 x_released_amount	IN ap_invoice_lines_all.retained_amount%type,
			 x_released_dist_tab	IN relDistType);

PROCEDURE log (x_api_name IN varchar2, x_debug_info	IN varchar2);

--
-- Main Procedure
--
PROCEDURE create_release (x_invoice_id		  IN ap_invoices_all.invoice_id%TYPE,
			  x_release_shipments_tab IN release_shipments_tab) As

     released_lines_tab		releaseLinesType;
     l_retained_lines_locked	boolean;

     l_debug_info		Varchar2(240);
     l_api_name			Constant Varchar2(100) := 'Create_Release';

BEGIN

     log(l_api_name,'Create_Release (+)');

     -----------------------------------------------------------------
     l_debug_info := 'Step 1: Get Retainage Release Invoice Details';
     log(l_api_name, l_debug_info);
     -----------------------------------------------------------------

     OPEN  c_release_invoice_info (x_invoice_id);
     FETCH c_release_invoice_info
      INTO g_release_invoice_info;
     CLOSE c_release_invoice_info;

     g_user_id  := fnd_profile.value('USER_ID');
     g_login_id := fnd_profile.value('LOGIN_ID');

     g_period_name := AP_UTILITIES_PKG.get_current_gl_date(g_release_invoice_info.gl_date, g_release_invoice_info.org_id);

     IF (g_period_name IS NULL) THEN
	-- Get gl_period and Date from a future period for the accounting date
        ap_utilities_pkg.get_open_gl_date(p_date        => g_release_invoice_info.gl_date,
					  p_period_name => g_period_name,
					  p_gl_date     => g_release_invoice_info.gl_date);

        IF (g_release_invoice_info.gl_date IS NULL) THEN
           fnd_message.set_name('SQLAP','AP_DISTS_NO_OPEN_FUT_PERIOD');
           app_exception.raise_exception;
        END IF;
     END IF;

     IF x_release_shipments_tab.count > 0 THEN

        -----------------------------------------------------------------
        l_debug_info := 'Step 2: Iterate each shipment to create release lines';
        log(l_api_name, l_debug_info);
        -----------------------------------------------------------------

	FOR i in x_release_shipments_tab.first .. x_release_shipments_tab.last
	LOOP

           -----------------------------------------------------------------
           l_debug_info := 'Step 3: Fetch invoice lines with retainage';
           log(l_api_name, l_debug_info);
           -----------------------------------------------------------------

	   IF x_release_shipments_tab(i).invoice_id IS NULL THEN

	       OPEN c_retained_lines_po (x_release_shipments_tab(i).line_location_id);
	      FETCH c_retained_lines_po
	       BULK COLLECT INTO retained_lines_tab;
	      CLOSE c_retained_lines_po;

	   ELSIF (x_release_shipments_tab(i).invoice_id IS NOT NULL AND
		  x_release_shipments_tab(i).line_number IS NOT NULL) THEN

	       OPEN c_retained_lines_inv (x_release_shipments_tab(i).invoice_id,
					  x_release_shipments_tab(i).line_number);
	      FETCH c_retained_lines_inv
	       BULK COLLECT INTO retained_lines_tab;
	      CLOSE c_retained_lines_inv;

	   END IF;

	   IF retained_lines_tab.count > 0 THEN

              -----------------------------------------------------------------
              l_debug_info := 'Step 4: Lock Retained Invoice Lines';
              log(l_api_name, l_debug_info);
              -----------------------------------------------------------------

	      Lock_Retained_Invoices (x_retained_lines_tab => retained_lines_tab,
				      x_lock_status	   => l_retained_lines_locked);

	      IF l_retained_lines_locked THEN

                 -----------------------------------------------------------------
                 l_debug_info := 'Step 5: Create Retainage Release Lines';
                 log(l_api_name, l_debug_info);
                 -----------------------------------------------------------------

	         create_release_lines
				(x_invoice_id		    => x_invoice_id,
				 x_release_amount	    => x_release_shipments_tab(i).release_amount,
				 x_release_amount_remaining => x_release_shipments_tab(i).release_amount_remaining,
				 x_retained_lines_tab       => retained_lines_tab,
				 x_released_lines_tab       => released_lines_tab);

                 -----------------------------------------------------------------
                 l_debug_info := 'Step 6: Create Retainage Release Distributions';
                 log(l_api_name, l_debug_info);
                 -----------------------------------------------------------------

		 IF released_lines_tab.count > 0 THEN

	            create_release_distributions
				(x_release_amount	    => x_release_shipments_tab(i).release_amount,
				 x_release_amount_remaining => x_release_shipments_tab(i).release_amount_remaining,
				 x_released_lines_tab	    => released_lines_tab);
		 END IF;
	      END IF;
	   END IF;

	END LOOP;
     END IF;

     COMMIT;

     -----------------------------------------------------------------
     l_debug_info := 'Step 7: Unlock Retained Invoice Lines';
     log(l_api_name, l_debug_info);
     -----------------------------------------------------------------

     IF l_retained_lines_locked THEN
	Unlock_Retained_Invoices (x_retained_lines_tab => retained_lines_tab,
				  x_lock_status	       => l_retained_lines_locked);
     END IF;

     log(l_api_name, 'Create_Release (-)');

EXCEPTION

  WHEN OTHERS THEN

     IF l_retained_lines_locked THEN
	Unlock_Retained_Invoices (x_retained_lines_tab => retained_lines_tab,
				  x_lock_status	       => l_retained_lines_locked);
     END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

END create_release;

Procedure create_release_lines (x_invoice_id			IN ap_invoices_all.invoice_id%TYPE,
				x_release_amount		IN number,
				x_release_amount_remaining	IN number,
				x_retained_lines_tab		IN retainedLinesType,
				x_released_lines_tab		OUT NOCOPY releaseLinesType) As

     l_release_proration_factor NUMBER;
     l_release_base_amount	NUMBER;
     l_invoice_line_amount	NUMBER;
     l_sum_amount		NUMBER := 0;
     l_sum_base_amount       	NUMBER := 0;
     l_max_line_amount       	NUMBER := 0;
     l_rounding_index        	NUMBER;
     l_max_inv_line_num		NUMBER;

     TYPE invIDType   IS TABLE OF ap_invoice_lines_all.invoice_id%type INDEX BY PLS_INTEGER;
     TYPE LineNumType IS TABLE OF ap_invoice_lines_all.line_number%type INDEX BY PLS_INTEGER;
     TYPE relAmtType  IS TABLE OF ap_invoice_lines_all.retained_amount_remaining%type INDEX BY PLS_INTEGER;

     retained_inv_id_tab	invIDType;
     retained_line_num_tab	LineNumType;
     release_amount_tab		relAmtType;

     l_debug_info		Varchar2(240);
     l_api_name			Constant Varchar2(100) := 'Create_Release_Lines';

Begin

     l_release_proration_factor := x_release_amount / x_release_amount_remaining;

     l_release_base_amount	:= ap_utilities_pkg.ap_round_currency
					     (x_release_amount * g_release_invoice_info.exchange_rate,
					      g_release_invoice_info.invoice_currency_code);

     SELECT nvl(max(line_number),0) + 1
     INTO   l_max_inv_line_num
     FROM   ap_invoice_lines_all
     WHERE  invoice_id = X_invoice_id;

     -- l_max_inv_line_num		:= ap_invoices_pkg.get_max_line_number(x_invoice_id) + 1;

     FOR i in x_retained_lines_tab.first .. x_retained_lines_tab.last
     LOOP

	 x_released_lines_tab(i).invoice_id			:= x_invoice_id;
	 x_released_lines_tab(i).line_number			:= l_max_inv_line_num;
	 x_released_lines_tab(i).line_type_lookup_code		:= 'RETAINAGE RELEASE';
	 x_released_lines_tab(i).description			:= x_retained_lines_tab(i).description;

	 x_released_lines_tab(i).org_id				:= x_retained_lines_tab(i).org_id;

	 x_released_lines_tab(i).generate_dists			:= 'D';
	 x_released_lines_tab(i).match_type			:= x_retained_lines_tab(i).match_type;

	 x_released_lines_tab(i).prorate_across_all_items	:= 'N';
	 x_released_lines_tab(i).accounting_date		:= g_release_invoice_info.gl_date;
	 x_released_lines_tab(i).period_name			:= g_period_name;

	 x_released_lines_tab(i).deferred_acctg_flag		:= 'N';
	 x_released_lines_tab(i).set_of_books_id		:= x_retained_lines_tab(i).set_of_books_id;

	 l_invoice_line_amount					:= l_release_proration_factor *
								   x_retained_lines_tab(i).retained_amount_remaining;

	 x_released_lines_tab(i).amount				:= ap_utilities_pkg.ap_round_currency
									     (l_invoice_line_amount,
									      g_release_invoice_info.invoice_currency_code);

	 x_released_lines_tab(i).base_amount			:= ap_utilities_pkg.ap_round_currency
									     (x_released_lines_tab(i).amount *
									      g_release_invoice_info.exchange_rate,
									      g_release_invoice_info.invoice_currency_code);

	 x_released_lines_tab(i).quantity_invoiced		:= l_release_proration_factor * x_retained_lines_tab(i).quantity_invoiced;
         x_released_lines_tab(i).unit_price                     := l_release_proration_factor * x_retained_lines_tab(i).unit_price;
	 x_released_lines_tab(i).unit_meas_lookup_code		:= x_retained_lines_tab(i).unit_meas_lookup_code;

	 x_released_lines_tab(i).wfapproval_status		:= x_retained_lines_tab(i).wfapproval_status;

	 x_released_lines_tab(i).discarded_flag			:= 'N';
	 x_released_lines_tab(i).cancelled_flag			:= 'N';

	 x_released_lines_tab(i).po_header_id			:= x_retained_lines_tab(i).po_header_id;
	 x_released_lines_tab(i).po_line_id			:= x_retained_lines_tab(i).po_line_id;
	 x_released_lines_tab(i).po_release_id			:= x_retained_lines_tab(i).po_release_id;
	 x_released_lines_tab(i).po_line_location_id		:= x_retained_lines_tab(i).po_line_location_id;
	 x_released_lines_tab(i).po_distribution_id		:= x_retained_lines_tab(i).po_distribution_id;
	 x_released_lines_tab(i).rcv_transaction_id		:= x_retained_lines_tab(i).rcv_transaction_id;

	 x_released_lines_tab(i).final_match_flag		:= x_retained_lines_tab(i).final_match_flag;
	 x_released_lines_tab(i).assets_tracking_flag		:= x_retained_lines_tab(i).assets_tracking_flag;
	 x_released_lines_tab(i).asset_book_type_code		:= x_retained_lines_tab(i).asset_book_type_code;
	 x_released_lines_tab(i).asset_category_id		:= x_retained_lines_tab(i).asset_category_id;
	 x_released_lines_tab(i).project_id			:= x_retained_lines_tab(i).project_id;
	 x_released_lines_tab(i).task_id			:= x_retained_lines_tab(i).task_id;
	 x_released_lines_tab(i).expenditure_type		:= x_retained_lines_tab(i).expenditure_type;
	 x_released_lines_tab(i).expenditure_item_date		:= x_retained_lines_tab(i).expenditure_item_date;
	 x_released_lines_tab(i).expenditure_organization_id	:= x_retained_lines_tab(i).expenditure_organization_id;

	 x_released_lines_tab(i).award_id			:= x_retained_lines_tab(i).award_id;
	 -- x_released_lines_tab(i).awt_group_id
	 x_released_lines_tab(i).reference_1			:= x_retained_lines_tab(i).reference_1;
	 x_released_lines_tab(i).reference_2			:= x_retained_lines_tab(i).reference_2;
	 x_released_lines_tab(i).receipt_verified_flag		:= x_retained_lines_tab(i).receipt_verified_flag;
	 x_released_lines_tab(i).receipt_required_flag		:= x_retained_lines_tab(i).receipt_required_flag;
	 x_released_lines_tab(i).receipt_missing_flag		:= x_retained_lines_tab(i).receipt_missing_flag;
	 x_released_lines_tab(i).justification			:= x_retained_lines_tab(i).justification;
	 x_released_lines_tab(i).expense_group			:= x_retained_lines_tab(i).expense_group;
	 x_released_lines_tab(i).start_expense_date		:= x_retained_lines_tab(i).start_expense_date;
	 x_released_lines_tab(i).end_expense_date		:= x_retained_lines_tab(i).end_expense_date;
	 x_released_lines_tab(i).receipt_currency_code		:= x_retained_lines_tab(i).receipt_currency_code;
	 x_released_lines_tab(i).receipt_conversion_rate	:= x_retained_lines_tab(i).receipt_conversion_rate;
	 x_released_lines_tab(i).receipt_currency_amount	:= x_retained_lines_tab(i).receipt_currency_amount;
	 x_released_lines_tab(i).daily_amount			:= x_retained_lines_tab(i).daily_amount;
	 x_released_lines_tab(i).web_parameter_id		:= x_retained_lines_tab(i).web_parameter_id;
	 x_released_lines_tab(i).adjustment_reason		:= x_retained_lines_tab(i).adjustment_reason;
	 x_released_lines_tab(i).merchant_document_number	:= x_retained_lines_tab(i).merchant_document_number;
	 x_released_lines_tab(i).merchant_name			:= x_retained_lines_tab(i).merchant_name;
	 x_released_lines_tab(i).merchant_reference		:= x_retained_lines_tab(i).merchant_reference;
	 x_released_lines_tab(i).merchant_tax_reg_number	:= x_retained_lines_tab(i).merchant_tax_reg_number;
	 x_released_lines_tab(i).merchant_taxpayer_id		:= x_retained_lines_tab(i).merchant_taxpayer_id;
	 x_released_lines_tab(i).country_of_supply		:= x_retained_lines_tab(i).country_of_supply;
	 x_released_lines_tab(i).credit_card_trx_id		:= x_retained_lines_tab(i).credit_card_trx_id;
	 x_released_lines_tab(i).company_prepaid_invoice_id	:= x_retained_lines_tab(i).company_prepaid_invoice_id;
	 x_released_lines_tab(i).cc_reversal_flag		:= x_retained_lines_tab(i).cc_reversal_flag;

	 x_released_lines_tab(i).creation_date			:= sysdate;
	 x_released_lines_tab(i).created_by			:= g_user_id;
	 x_released_lines_tab(i).last_updated_by		:= g_user_id;
	 x_released_lines_tab(i).last_update_date		:= sysdate;
	 x_released_lines_tab(i).last_update_login		:= g_login_id;

	 x_released_lines_tab(i).attribute_category		:= x_retained_lines_tab(i).attribute_category;
	 x_released_lines_tab(i).attribute1			:= x_retained_lines_tab(i).attribute1;
	 x_released_lines_tab(i).attribute2			:= x_retained_lines_tab(i).attribute2;
	 x_released_lines_tab(i).attribute3			:= x_retained_lines_tab(i).attribute3;
	 x_released_lines_tab(i).attribute4			:= x_retained_lines_tab(i).attribute4;
	 x_released_lines_tab(i).attribute5			:= x_retained_lines_tab(i).attribute5;
	 x_released_lines_tab(i).attribute6			:= x_retained_lines_tab(i).attribute6;
	 x_released_lines_tab(i).attribute7			:= x_retained_lines_tab(i).attribute7;
	 x_released_lines_tab(i).attribute8			:= x_retained_lines_tab(i).attribute8;
	 x_released_lines_tab(i).attribute9			:= x_retained_lines_tab(i).attribute9;
	 x_released_lines_tab(i).attribute10			:= x_retained_lines_tab(i).attribute10;
	 x_released_lines_tab(i).attribute11			:= x_retained_lines_tab(i).attribute11;
	 x_released_lines_tab(i).attribute12			:= x_retained_lines_tab(i).attribute12;
	 x_released_lines_tab(i).attribute13			:= x_retained_lines_tab(i).attribute13;
	 x_released_lines_tab(i).attribute14			:= x_retained_lines_tab(i).attribute14;
	 x_released_lines_tab(i).attribute15			:= x_retained_lines_tab(i).attribute15;
	 x_released_lines_tab(i).global_attribute_category	:= x_retained_lines_tab(i).global_attribute_category;
	 x_released_lines_tab(i).global_attribute1		:= x_retained_lines_tab(i).global_attribute1;
	 x_released_lines_tab(i).global_attribute2		:= x_retained_lines_tab(i).global_attribute2;
	 x_released_lines_tab(i).global_attribute3		:= x_retained_lines_tab(i).global_attribute3;
	 x_released_lines_tab(i).global_attribute4		:= x_retained_lines_tab(i).global_attribute4;
	 x_released_lines_tab(i).global_attribute5		:= x_retained_lines_tab(i).global_attribute5;
	 x_released_lines_tab(i).global_attribute6		:= x_retained_lines_tab(i).global_attribute6;
	 x_released_lines_tab(i).global_attribute7		:= x_retained_lines_tab(i).global_attribute7;
	 x_released_lines_tab(i).global_attribute8		:= x_retained_lines_tab(i).global_attribute8;
	 x_released_lines_tab(i).global_attribute9		:= x_retained_lines_tab(i).global_attribute9;
	 x_released_lines_tab(i).global_attribute10		:= x_retained_lines_tab(i).global_attribute10;
	 x_released_lines_tab(i).global_attribute11		:= x_retained_lines_tab(i).global_attribute11;
	 x_released_lines_tab(i).global_attribute12		:= x_retained_lines_tab(i).global_attribute12;
	 x_released_lines_tab(i).global_attribute13		:= x_retained_lines_tab(i).global_attribute13;
	 x_released_lines_tab(i).global_attribute14		:= x_retained_lines_tab(i).global_attribute14;
	 x_released_lines_tab(i).global_attribute15		:= x_retained_lines_tab(i).global_attribute15;
	 x_released_lines_tab(i).global_attribute16		:= x_retained_lines_tab(i).global_attribute16;
	 x_released_lines_tab(i).global_attribute17		:= x_retained_lines_tab(i).global_attribute17;
	 x_released_lines_tab(i).global_attribute18		:= x_retained_lines_tab(i).global_attribute18;
	 x_released_lines_tab(i).global_attribute19		:= x_retained_lines_tab(i).global_attribute19;
	 x_released_lines_tab(i).global_attribute20		:= x_retained_lines_tab(i).global_attribute20;

	 x_released_lines_tab(i).ship_to_location_id		:= x_retained_lines_tab(i).ship_to_location_id;
	 x_released_lines_tab(i).primary_intended_use		:= x_retained_lines_tab(i).primary_intended_use;
	 x_released_lines_tab(i).product_fisc_classification	:= x_retained_lines_tab(i).product_fisc_classification;
	 x_released_lines_tab(i).trx_business_category		:= x_retained_lines_tab(i).trx_business_category;
	 x_released_lines_tab(i).product_type			:= x_retained_lines_tab(i).product_type;
	 x_released_lines_tab(i).product_category		:= x_retained_lines_tab(i).product_category;
	 x_released_lines_tab(i).user_defined_fisc_class	:= x_retained_lines_tab(i).user_defined_fisc_class;
	 x_released_lines_tab(i).purchasing_category_id		:= x_retained_lines_tab(i).purchasing_category_id;
         x_released_lines_tab(i).tax_classification_code         := x_retained_lines_tab(i).tax_classification_code;
         /* Bug 6729532 : Added code to copy the requester_id from the Standard invoice lines */
         x_released_lines_tab(i).requester_id                   := x_retained_lines_tab(i).requester_id;


         IF (x_released_lines_tab(i).amount >= l_max_line_amount) THEN
             l_rounding_index  := i;
             l_max_line_amount := x_released_lines_tab(i).amount;
         END IF;

         x_released_lines_tab(i).retained_invoice_id	:= x_retained_lines_tab(i).invoice_id;
         x_released_lines_tab(i).retained_line_number	:= x_retained_lines_tab(i).line_number;

	 retained_inv_id_tab(i)		:= x_retained_lines_tab(i).invoice_id;
	 retained_line_num_tab(i) 	:= x_retained_lines_tab(i).line_number;
	 release_amount_tab(i)       	:= x_released_lines_tab(i).amount;

         l_sum_amount      := l_sum_amount + x_released_lines_tab(i).amount;
         l_sum_base_amount := l_sum_base_amount + x_released_lines_tab(i).base_amount;

         l_max_inv_line_num := l_max_inv_line_num + 1;

     END LOOP;

     --
     -- Amount and Base Amount rounding due to proration of shipment
     -- release amount to invoice lines.
     --
     IF l_rounding_index Is Not Null THEN

        IF l_sum_amount <> x_release_amount THEN

           x_released_lines_tab(l_rounding_index).amount := x_released_lines_tab(l_rounding_index).amount +
                                                             (x_release_amount - l_sum_amount);

	   release_amount_tab(l_rounding_index) := x_released_lines_tab(l_rounding_index).amount;

        END IF;

        IF g_release_invoice_info.exchange_rate Is Not Null THEN

           IF l_sum_base_amount <> l_release_base_amount THEN

              x_released_lines_tab(l_rounding_index).rounding_amt := l_release_base_amount - l_sum_base_amount;

              x_released_lines_tab(l_rounding_index).base_amount  := x_released_lines_tab(l_rounding_index).base_amount +
                                                                     x_released_lines_tab(l_rounding_index).rounding_amt;

           END IF;
        END IF;
     END IF;

     -- Insert Release Lines

     IF x_released_lines_tab.count > 0 THEN

	     FORALL i in x_released_lines_tab.first .. x_released_lines_tab.last

			INSERT INTO ap_invoice_lines_all VALUES x_released_lines_tab(i);

     END IF;

     -- Update original invoice line retained amount remaining

     IF retained_inv_id_tab.count > 0 THEN

	     FORALL i in retained_inv_id_tab.first .. retained_inv_id_tab.last

			UPDATE ap_invoice_lines
			   SET retained_amount_remaining = (abs(retained_amount_remaining) - abs(release_amount_tab(i)))
			 WHERE invoice_id  = retained_inv_id_tab(i)
			   AND line_number = retained_line_num_tab(i);

     END IF;

EXCEPTION

  WHEN OTHERS THEN
     log(l_api_name,'Error: '||sqlerrm);
     APP_EXCEPTION.RAISE_EXCEPTION;

End create_release_lines;

Procedure create_release_distributions (x_release_amount		IN number,
					x_release_amount_remaining	IN number,
					x_released_lines_tab		IN releaseLinesType) As

     Cursor c_retained_distributions (c_invoice_id  in ap_invoice_distributions_all.invoice_id%type,
				      c_line_number in ap_invoice_distributions_all.invoice_line_number%type) Is
	select aid.*,
	       ap_invoice_distributions_s.nextval released_invoice_dist_id
          from ap_invoice_distributions aid
	 where invoice_id		= c_invoice_id
	   and invoice_line_number	= c_line_number
           and line_type_lookup_code    = 'RETAINAGE';

     Type retDistType IS TABLE OF c_retained_distributions%rowtype INDEX BY PLS_INTEGER;

     retained_dist_tab		retDistType;
     released_dist_tab		relDistType;

     Type invDistIDType   IS TABLE OF ap_invoice_distributions_all.invoice_distribution_id%type INDEX BY PLS_INTEGER;
     Type relAmtType	  IS TABLE OF ap_invoice_distributions_all.amount%type INDEX BY PLS_INTEGER;

     retained_inv_dist_id_tab	invDistIDType;
     release_amount_tab		relAmtType;

     l_release_proration_factor	NUMBER;
     l_distribution_line_number	NUMBER;
     l_distribution_amount	NUMBER;

     -- Rounding variables
     l_sum_amount		NUMBER;
     l_sum_base_amount		NUMBER;
     l_max_dist_amount		NUMBER;
     l_rounding_index		NUMBER;

     -- Recoupment
     l_recoupment_rate          po_lines_all.recoupment_rate%TYPE;
     l_amount_to_recoup         ap_invoice_lines_all.amount%TYPE;
     l_success			Boolean;
     l_error_message            Varchar2(4000);

     l_debug_info		Varchar2(240);
     l_api_name			Constant Varchar2(100) := 'Create_Release_Distributions';

Begin
        log(l_api_name,'Create_Release_Distributions (+)');

	l_release_proration_factor := abs(x_release_amount) / abs(x_release_amount_remaining);

        -----------------------------------------------------------------
        l_debug_info := 'Step 1: Iterate each invoice line with retainage';
        log(l_api_name,l_debug_info);
        -----------------------------------------------------------------

	FOR i in x_released_lines_tab.first .. x_released_lines_tab.last
	LOOP

            -----------------------------------------------------------------
            l_debug_info := 'Step 2: Fetch invoice distributions'||
                            ' Invoice ID : '|| x_released_lines_tab(i).retained_invoice_id ||
			    ' Line Number: '|| x_released_lines_tab(i).retained_line_number;
            log(l_api_name,l_debug_info);
            -----------------------------------------------------------------

	    Open  c_retained_distributions (x_released_lines_tab(i).retained_invoice_id,
					    x_released_lines_tab(i).retained_line_number);
	    Fetch c_retained_distributions
	     Bulk Collect Into retained_dist_tab;
	    Close c_retained_distributions;

	    IF retained_dist_tab.count > 0 Then

		l_rounding_index	   := NULL;
		l_sum_amount		   := 0;
		l_sum_base_amount	   := 0;
		l_max_dist_amount	   := 0;
		l_distribution_line_number := 1;

		-----------------------------------------------------------------
		l_debug_info := 'Step 3: Iterate each invoice distribution';
		log(l_api_name,l_debug_info);
                -----------------------------------------------------------------

		For j in retained_dist_tab.first .. retained_dist_tab.last
		Loop
                    -----------------------------------------------------------------
                    l_debug_info := 'Step 4: Derive Retainage Release Distribution Attributes';
		    log(l_api_name,l_debug_info);
                    -----------------------------------------------------------------

		    released_dist_tab(j).invoice_id			:= x_released_lines_tab(i).invoice_id;
		    released_dist_tab(j).invoice_line_number		:= x_released_lines_tab(i).line_number;

		    released_dist_tab(j).invoice_distribution_id	:= retained_dist_tab(j).released_invoice_dist_id;
		    released_dist_tab(j).retained_invoice_dist_id	:= retained_dist_tab(j).invoice_distribution_id;

		    released_dist_tab(j).distribution_line_number	:= l_distribution_line_number;

		    released_dist_tab(j).line_type_lookup_code         	:= retained_dist_tab(j).line_type_lookup_code;
		    released_dist_tab(j).dist_code_combination_id      	:= retained_dist_tab(j).dist_code_combination_id;

		    l_distribution_amount				:= -1 * l_release_proration_factor *
									        retained_dist_tab(j).amount;

		    released_dist_tab(j).amount				:= ap_utilities_pkg.ap_round_currency
										(l_distribution_amount,
										 g_release_invoice_info.invoice_currency_code);

		    released_dist_tab(j).base_amount			:= ap_utilities_pkg.ap_round_currency
										(released_dist_tab(j).amount,
										 g_release_invoice_info.invoice_currency_code);

		    released_dist_tab(j).description                   := retained_dist_tab(j).description;
		    released_dist_tab(j).dist_match_type               := retained_dist_tab(j).dist_match_type;
		    released_dist_tab(j).distribution_class            := retained_dist_tab(j).distribution_class;

		    released_dist_tab(j).set_of_books_id               := retained_dist_tab(j).set_of_books_id;
		    released_dist_tab(j).org_id                        := retained_dist_tab(j).org_id;

		    released_dist_tab(j).accounting_date               := x_released_lines_tab(i).accounting_date;
		    released_dist_tab(j).period_name                   := x_released_lines_tab(i).period_name;
		    released_dist_tab(j).posted_flag                   := 'N';

		    released_dist_tab(j).po_distribution_id            := retained_dist_tab(j).po_distribution_id;
		    released_dist_tab(j).rcv_transaction_id            := retained_dist_tab(j).rcv_transaction_id;

		    released_dist_tab(j).matched_uom_lookup_code       := retained_dist_tab(j).matched_uom_lookup_code;
		    released_dist_tab(j).unit_price		       := l_release_proration_factor * retained_dist_tab(j).unit_price;
		    released_dist_tab(j).quantity_invoiced	       := l_release_proration_factor * retained_dist_tab(j).quantity_invoiced;

		    released_dist_tab(j).match_status_flag              := null;

		    released_dist_tab(j).creation_date			:= sysdate;
		    released_dist_tab(j).created_by			:= g_user_id;
		    released_dist_tab(j).last_updated_by		:= g_user_id;
		    released_dist_tab(j).last_update_date		:= sysdate;
		    released_dist_tab(j).last_update_login		:= g_login_id;

		    released_dist_tab(j).assets_addition_flag		:= retained_dist_tab(j).assets_addition_flag;
		    released_dist_tab(j).assets_tracking_flag		:= 'N';
		    released_dist_tab(j).asset_book_type_code		:= NULL;
		    released_dist_tab(j).asset_category_id		:= NULL;

         	    released_dist_tab(j).inventory_transfer_status   	:= 'N';
		    released_dist_tab(j).reference_1                 	:= retained_dist_tab(j).reference_1;
		    released_dist_tab(j).reference_2                 	:= retained_dist_tab(j).reference_2;

	            released_dist_tab(j).project_id                  	:= retained_dist_tab(j).project_id;
	            released_dist_tab(j).task_id                     	:= retained_dist_tab(j).task_id;
	            released_dist_tab(j).expenditure_type            	:= retained_dist_tab(j).expenditure_type;
	            released_dist_tab(j).expenditure_item_date       	:= retained_dist_tab(j).expenditure_item_date;
	            released_dist_tab(j).expenditure_organization_id 	:= retained_dist_tab(j).expenditure_organization_id;
	            released_dist_tab(j).pa_quantity                 	:= retained_dist_tab(j).pa_quantity;
	            released_dist_tab(j).pa_addition_flag            	:= retained_dist_tab(j).pa_addition_flag;
	            released_dist_tab(j).pa_cc_ar_invoice_id         	:= retained_dist_tab(j).pa_cc_ar_invoice_id;
	            released_dist_tab(j).pa_cc_ar_invoice_line_num   	:= retained_dist_tab(j).pa_cc_ar_invoice_line_num;
	            released_dist_tab(j).pa_cc_processed_code        	:= retained_dist_tab(j).pa_cc_processed_code;
	            released_dist_tab(j).award_id                    	:= retained_dist_tab(j).award_id;
	            released_dist_tab(j).gms_burdenable_raw_cost     	:= retained_dist_tab(j).gms_burdenable_raw_cost;

	            released_dist_tab(j).attribute_category          	:= retained_dist_tab(j).attribute_category;
	            released_dist_tab(j).attribute1                  	:= retained_dist_tab(j).attribute1;
	            released_dist_tab(j).attribute2                  	:= retained_dist_tab(j).attribute2;
	            released_dist_tab(j).attribute3                  	:= retained_dist_tab(j).attribute3;
	            released_dist_tab(j).attribute4                  	:= retained_dist_tab(j).attribute4;
	            released_dist_tab(j).attribute5                  	:= retained_dist_tab(j).attribute5;
	            released_dist_tab(j).attribute6                  	:= retained_dist_tab(j).attribute6;
	            released_dist_tab(j).attribute7                  	:= retained_dist_tab(j).attribute7;
	            released_dist_tab(j).attribute8                  	:= retained_dist_tab(j).attribute8;
	            released_dist_tab(j).attribute9                  	:= retained_dist_tab(j).attribute9;
	            released_dist_tab(j).attribute10                 	:= retained_dist_tab(j).attribute10;
	            released_dist_tab(j).attribute11                 	:= retained_dist_tab(j).attribute11;
	            released_dist_tab(j).attribute12                 	:= retained_dist_tab(j).attribute12;
	            released_dist_tab(j).attribute13                 	:= retained_dist_tab(j).attribute13;
	            released_dist_tab(j).attribute14                 	:= retained_dist_tab(j).attribute14;
	            released_dist_tab(j).attribute15                 	:= retained_dist_tab(j).attribute15;
	            released_dist_tab(j).global_attribute_category   	:= retained_dist_tab(j).global_attribute_category;
	            released_dist_tab(j).global_attribute1           	:= retained_dist_tab(j).global_attribute1;
	            released_dist_tab(j).global_attribute2           	:= retained_dist_tab(j).global_attribute2;
	            released_dist_tab(j).global_attribute3           	:= retained_dist_tab(j).global_attribute3;
	            released_dist_tab(j).global_attribute4           	:= retained_dist_tab(j).global_attribute4;
	            released_dist_tab(j).global_attribute5           	:= retained_dist_tab(j).global_attribute5;
	            released_dist_tab(j).global_attribute6           	:= retained_dist_tab(j).global_attribute6;
	            released_dist_tab(j).global_attribute7           	:= retained_dist_tab(j).global_attribute7;
	            released_dist_tab(j).global_attribute8           	:= retained_dist_tab(j).global_attribute8;
	            released_dist_tab(j).global_attribute9           	:= retained_dist_tab(j).global_attribute9;
	            released_dist_tab(j).global_attribute10          	:= retained_dist_tab(j).global_attribute10;
	            released_dist_tab(j).global_attribute11          	:= retained_dist_tab(j).global_attribute11;
	            released_dist_tab(j).global_attribute12          	:= retained_dist_tab(j).global_attribute12;
	            released_dist_tab(j).global_attribute13          	:= retained_dist_tab(j).global_attribute13;
	            released_dist_tab(j).global_attribute14          	:= retained_dist_tab(j).global_attribute14;
	            released_dist_tab(j).global_attribute15          	:= retained_dist_tab(j).global_attribute15;
	            released_dist_tab(j).global_attribute16          	:= retained_dist_tab(j).global_attribute16;
	            released_dist_tab(j).global_attribute17          	:= retained_dist_tab(j).global_attribute17;
	            released_dist_tab(j).global_attribute18          	:= retained_dist_tab(j).global_attribute18;
	            released_dist_tab(j).global_attribute19          	:= retained_dist_tab(j).global_attribute19;
	            released_dist_tab(j).global_attribute20          	:= retained_dist_tab(j).global_attribute20;

		    released_dist_tab(j).intended_use                	:= retained_dist_tab(j).intended_use;

		    IF (released_dist_tab(j).amount >= l_max_dist_amount) THEN
			l_rounding_index  := j;
			l_max_dist_amount := released_dist_tab(j).amount;
		    END IF;

		    l_sum_amount      := l_sum_amount + released_dist_tab(j).amount;
		    l_sum_base_amount := l_sum_base_amount + released_dist_tab(j).base_amount;

		    l_distribution_line_number := l_distribution_line_number + 1;

		    release_amount_tab(j)       := released_dist_tab(j).amount;
		    retained_inv_dist_id_tab(j) := retained_dist_tab(j).invoice_distribution_id;

		End Loop;

		IF l_rounding_index Is Not Null THEN

		   IF l_sum_amount <> x_released_lines_tab(i).amount THEN

		      released_dist_tab(l_rounding_index).amount := released_dist_tab(l_rounding_index).amount  +
								    (x_released_lines_tab(i).amount - l_sum_amount);

		      release_amount_tab(l_rounding_index) := released_dist_tab(l_rounding_index).amount;

                   END IF;

		   IF g_release_invoice_info.exchange_rate Is Not Null THEN

		      IF l_sum_base_amount <> x_released_lines_tab(i).base_amount THEN

		         released_dist_tab(l_rounding_index).rounding_amt := x_released_lines_tab(i).base_amount -
									     l_sum_base_amount;

		         released_dist_tab(l_rounding_index).base_amount  := released_dist_tab(l_rounding_index).base_amount +
									     released_dist_tab(l_rounding_index).rounding_amt;
		      END IF;
		   END IF;
		END IF;

		-----------------------------------------------------------------
		l_debug_info := 'Step 5: Update PO Shipment and Distributions';
		log(l_api_name,l_debug_info);
		-----------------------------------------------------------------

		Update_PO_Shipment_Dists (x_released_lines_tab(i).po_line_location_id,
					  x_released_lines_tab(i).amount,
					  released_dist_tab);

		-----------------------------------------------------------------
		l_debug_info := 'Step 6: Insert Retainage Release Distributions: Count: '||released_dist_tab.count;
		log(l_api_name,l_debug_info);
		-----------------------------------------------------------------

		IF released_dist_tab.count > 0 THEN

		   FORALL k in released_dist_tab.first .. released_dist_tab.last

			INSERT INTO ap_invoice_distributions_all VALUES released_dist_tab(k);

		END IF;

		-----------------------------------------------------------------
		l_debug_info := 'Step 7: Update original invoice line retained amount remaining';
		log(l_api_name,l_debug_info);
		-----------------------------------------------------------------

		IF retained_inv_dist_id_tab.count > 0 THEN

		   FORALL i in retained_inv_dist_id_tab.first .. retained_inv_dist_id_tab.last

			UPDATE ap_invoice_distributions_all
			   SET retained_amount_remaining = (abs(retained_amount_remaining) - abs(release_amount_tab(i)))
			 WHERE invoice_distribution_id   = retained_inv_dist_id_tab(i);

		END IF;

		IF (x_released_lines_tab(i).po_line_location_id IS NOT NULL) THEN

		    SELECT pl.recoupment_rate
		      INTO l_recoupment_rate
		      FROM po_line_locations_all pll, po_lines_all pl
		     WHERE pll.line_location_id = x_released_lines_tab(i).po_line_location_id
		       AND pll.po_line_id = pl.po_line_id;

   		END  IF;

		IF (l_recoupment_rate IS NOT NULL) THEN

		   l_amount_to_recoup := ap_utilities_pkg.ap_round_currency(
		                              (x_released_lines_tab(i).amount * l_recoupment_rate / 100), g_release_invoice_info.invoice_currency_code);

		   l_success := ap_matching_utils_pkg.ap_recoup_invoice_line(
		                              P_Invoice_Id           => x_released_lines_tab(i).invoice_id,
		                              P_Invoice_Line_Number  => x_released_lines_tab(i).line_number,
		                              P_Amount_To_Recoup     => l_amount_to_recoup,
		                              P_Po_Line_Id           => x_released_lines_tab(i).po_line_id,
		                              P_Vendor_Id            => g_release_invoice_info.vendor_id,
		                              P_Vendor_Site_Id       => g_release_invoice_info.vendor_site_id,
		                              P_Accounting_Date      => g_release_invoice_info.gl_date,
		                              P_Period_Name          => g_period_name,
		                              P_User_Id              => g_user_id,
		                              P_Last_Update_Login    => g_login_id,
		                              P_Error_Message        => l_error_message,
		                              P_Calling_Sequence     => 'AP_RETAINAGE_RELEASE_PKG.CREATE_RELEASE_DISTRIBUTIONS');

		END IF;

	    END IF;
	END LOOP;

        log(l_api_name, 'Create_Release_Distributions (-)');

EXCEPTION
  WHEN OTHERS THEN
     log(l_api_name,'Error: '||sqlerrm);
     APP_EXCEPTION.RAISE_EXCEPTION;

End create_release_distributions;

Procedure final_release_rounding (x_line_location_id    IN po_line_locations_all.line_location_id%type,
				  x_max_invoice_dist_id IN NUMBER) Is

     l_sum_retained_base_amount		NUMBER;
     l_sum_released_base_amount		NUMBER;
     l_final_release_rounding_amt	NUMBER;

Begin

     SELECT sum(ap_utilities_pkg.ap_round_currency(ail.retained_amount * ai.exchange_rate, ai.invoice_currency_code))
       INTO l_sum_retained_base_amount
       FROM ap_invoices      ai,
            ap_invoice_lines ail
	 WHERE ai.invoice_id = ail.invoice_id
	   AND ail.po_line_location_id	= x_line_location_id
	   AND ail.line_type_lookup_code = 'ITEM'
	   AND NVL(ail.discarded_flag,'N') <> 'Y';

	SELECT sum(base_amount)
	  INTO l_sum_released_base_amount
	  FROM ap_invoice_lines ail
	 WHERE (ail.retained_invoice_id, ail.retained_line_number)
	       IN
	       (Select invoice_id, line_number
		  From ap_invoice_lines ail2
		 Where ail.po_line_location_id	= x_line_location_id
		   And ail.line_type_lookup_code = 'ITEM'
		   And nvl(ail.discarded_flag,'N') <> 'Y');

	l_final_release_rounding_amt := l_sum_retained_base_amount - l_sum_released_base_amount;

	UPDATE ap_invoice_distributions
	   SET final_release_rounding  = l_final_release_rounding_amt
	 WHERE invoice_distribution_id = x_max_invoice_dist_id;

End final_release_rounding;

Procedure Lock_Retained_Invoices (x_retained_lines_tab 	IN  retainedLinesType,
				  x_lock_status		OUT NOCOPY BOOLEAN) As
Pragma Autonomous_Transaction;

     TYPE invIDType   IS TABLE OF ap_invoice_lines_all.invoice_id%type INDEX BY PLS_INTEGER;
     TYPE lineNumType IS TABLE OF ap_invoice_lines_all.line_number%type INDEX BY PLS_INTEGER;

     lock_invoice_id_tab	invIDType;
     lock_line_number_tab	lineNumType;

Begin

     SAVEPOINT lock_invoice;

     FOR i in x_retained_lines_tab.first .. x_retained_lines_tab.last
     LOOP
	 lock_invoice_id_tab(i)  := x_retained_lines_tab(i).invoice_id;
	 lock_line_number_tab(i) := x_retained_lines_tab(i).line_number;
     END LOOP;

     FORALL i in x_retained_lines_tab.first .. x_retained_lines_tab.last

	     Update ap_invoice_lines
		Set line_selected_for_release_flag = 'Y'
	      Where invoice_id	= lock_invoice_id_tab(i)
	        And line_number	= lock_line_number_tab(i);

     x_lock_status := SQL%ROWCOUNT > 0;

     COMMIT;

Exception

     When Others Then

        x_lock_status := FALSE;

	ROLLBACK To lock_invoice;

End Lock_Retained_Invoices;

Procedure Unlock_Retained_Invoices (x_retained_lines_tab 	IN  retainedLinesType,
				    x_lock_status		OUT NOCOPY BOOLEAN) As
Pragma Autonomous_Transaction;

     TYPE invIDType   IS TABLE OF ap_invoice_lines_all.invoice_id%type INDEX BY PLS_INTEGER;
     TYPE lineNumType IS TABLE OF ap_invoice_lines_all.line_number%type INDEX BY PLS_INTEGER;

     lock_invoice_id_tab	invIDType;
     lock_line_number_tab	lineNumType;

     l_debug_info               Varchar2(240);
     l_api_name                 Constant Varchar2(100) := 'Unlock_Retained_Invoices';

Begin

     SAVEPOINT unlock_invoice;

     -----------------------------------------------------------------
     l_debug_info := 'Step 1';
     log(l_api_name, l_debug_info);
     -----------------------------------------------------------------

     FOR i in x_retained_lines_tab.first .. x_retained_lines_tab.last
     LOOP
	 lock_invoice_id_tab(i)  := x_retained_lines_tab(i).invoice_id;
	 lock_line_number_tab(i) := x_retained_lines_tab(i).line_number;
     END LOOP;

     -----------------------------------------------------------------
     l_debug_info := 'Step 2';
     log(l_api_name, l_debug_info);
     -----------------------------------------------------------------

     FORALL i in x_retained_lines_tab.first .. x_retained_lines_tab.last

	     Update ap_invoice_lines
		Set line_selected_for_release_flag = NULL
	      Where invoice_id	= lock_invoice_id_tab(i)
	        And line_number	= lock_line_number_tab(i);

     -----------------------------------------------------------------
     l_debug_info := 'Step 3';
     log(l_api_name, l_debug_info);
     -----------------------------------------------------------------

     x_lock_status := SQL%ROWCOUNT > 0;

     COMMIT;

Exception

     When Others Then

        x_lock_status := FALSE;

	ROLLBACK To unlock_invoice;

End Unlock_Retained_Invoices;

Procedure Update_PO_Shipment_Dists
			(x_line_location_id	IN ap_invoice_lines_all.po_line_location_id%type,
			 x_released_amount	IN ap_invoice_lines_all.retained_amount%type,
			 x_released_dist_tab	IN relDistType) As

 l_po_ap_dist_rec		PO_AP_DIST_REC_TYPE;
 l_po_ap_line_loc_rec		PO_AP_LINE_LOC_REC_TYPE;

 l_return_status		VARCHAR2(100);
 l_msg_data			VARCHAR2(4000);

 l_api_name			VARCHAR2(50);
 l_debug_info			VARCHAR2(2000);

BEGIN

   l_api_name := 'Update_PO_Shipment_Dists';

   l_po_ap_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

   l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
				 p_po_line_location_id    => x_line_location_id,
				 p_uom_code	          => NULL,
				 p_quantity_billed        => NULL,
				 p_amount_billed          => NULL,
				 p_quantity_financed      => NULL,
 				 p_amount_financed        => NULL,
				 p_quantity_recouped      => NULL,
				 p_amount_recouped     	  => NULL,
				 p_retainage_withheld_amt => NULL,
				 p_retainage_released_amt => x_released_amount
				);

   FOR i in nvl(x_released_dist_tab.first,0)..nvl(x_released_dist_tab.last,0)
   LOOP

       IF (x_released_dist_tab.exists(i)) THEN

          l_po_ap_dist_rec.add_change
				(p_po_distribution_id	  => x_released_dist_tab(i).po_distribution_id,
    				 p_uom_code		  => NULL,
				 p_quantity_billed	  => NULL,
				 p_amount_billed	  => NULL,
				 p_quantity_financed	  => NULL,
				 p_amount_financed	  => NULL,
				 p_quantity_recouped	  => NULL,
				 p_amount_recouped	  => NULL,
				 p_retainage_withheld_amt => NULL,
				 p_retainage_released_amt => x_released_dist_tab(i).amount);


       END IF;

   END LOOP;

   PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
					P_Api_Version	       => 1.0,
					P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
					P_Dist_Changes_Rec     => l_po_ap_dist_rec,
					X_Return_Status	       => l_return_status,
					X_Msg_Data	       => l_msg_data);
END Update_PO_Shipment_Dists;


PROCEDURE log (x_api_name	IN varchar2,
	       x_debug_info	IN varchar2) As

BEGIN
     IF (g_level_procedure >= g_current_runtime_level) THEN
         fnd_log.string(g_level_procedure,g_module_name||x_api_name,x_debug_info);
     END IF;
END log;

End ap_retainage_release_pkg;

/
