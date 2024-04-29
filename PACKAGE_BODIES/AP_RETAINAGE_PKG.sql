--------------------------------------------------------
--  DDL for Package Body AP_RETAINAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_RETAINAGE_PKG" AS
/* $Header: apcwrtnb.pls 120.6.12010000.4 2009/10/28 14:28:44 pgayen ship $ */

  -- FND logging global variables

  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_RETAINAGE_PKG';
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
  G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_RETAINAGE_PKG.';

  TYPE retDistType  IS TABLE OF ap_invoice_distributions_all%rowtype INDEX BY PLS_INTEGER;

  x_retainage_dist_tab	retDistType;

  Procedure Insert_Distributions (x_invoice_id		IN NUMBER,
				  x_invoice_line_number	IN NUMBER,
				  x_retainage_dist_tab	OUT NOCOPY retDistType);

  Procedure Update_Payment_Schedules (x_invoice_id IN ap_invoices.invoice_id%type);

  Procedure Update_PO_Shipment_Dists (x_line_location_id   IN ap_invoice_lines_all.po_line_location_id%type,
				      x_retained_amount	   IN ap_invoice_lines_all.retained_amount%type,
				      x_retainage_dist_tab IN retDistType);

  Procedure Print (x_api_name IN Varchar2, x_debug_info IN Varchar2);


  CURSOR c_invoice_info(c_invoice_id 		IN ap_invoices.invoice_id%type,
		        c_invoice_line_number	IN ap_invoice_lines.line_number%type) IS
		    Select ai.invoice_amount			invoice_amount,
			   ai.exchange_rate			exchange_rate,
			   ai.invoice_currency_code		invoice_currency_code,
			   ai.payment_currency_code		payment_currency_code,
			   ai.payment_cross_rate		payment_cross_rate,
			   ai.amount_applicable_to_discount	amount_applicable_to_discount,
			   ai.invoice_type_lookup_code		invoice_type_lookup_code,
			   ai.net_of_retainage_flag		net_of_retainage_flag,
			   ail.amount				line_amount,
		           ail.retained_amount			retained_amount,
			   ail.po_line_location_id		po_line_location_id,
			   decode(fc.minimum_accountable_unit,
				   null, round((ail.retained_amount * ai.exchange_rate),
						fc.precision),
				         round((ail.retained_amount * ai.exchange_rate)
						/ fc.minimum_accountable_unit) * fc.minimum_accountable_unit)
								base_retained_amount,
		           fc.precision				precision,
		           fc.minimum_accountable_unit		minimum_accountable_unit,
		           fsp.retainage_code_combination_id	retainage_code_combination_id
		      From ap_invoices                  ai,
		           ap_invoice_lines             ail,
		           ap_system_parameters         asp,
		           financials_system_parameters fsp,
			   fnd_currencies		fc
		     Where ail.invoice_id		= c_invoice_id
		       And ail.line_number		= c_invoice_line_number
		       And ai.invoice_id		= ail.invoice_id
		       And ai.org_id			= asp.org_id
		       And asp.org_id			= fsp.org_id
		       And ai.invoice_currency_code	= fc.currency_code (+);

  g_invoice_info	c_invoice_info%ROWTYPE;
  g_user_id 		NUMBER;
  g_login_id 		NUMBER;

PROCEDURE Create_Retainage_Distributions(x_invoice_id          IN ap_invoices.invoice_id%type,
                                         x_invoice_line_number IN ap_invoice_lines.line_number%type) AS

	l_debug_info            Varchar2(240);
        l_api_name		Constant Varchar2(100) := 'Create_Retainage_Distributions';

BEGIN

     Print (l_api_name,'Create_Retainage_Distributions (+)');

     -----------------------------------------------------------------
     l_debug_info := 'Step 1: Fetch Invoice Details';
     Print (l_api_name, l_debug_info);
     -----------------------------------------------------------------

     Open  c_invoice_info (x_invoice_id, x_invoice_line_number);
     Fetch c_invoice_info
      Into g_invoice_info;
     Close c_invoice_info;

     g_user_id  := fnd_profile.value('USER_ID');
     g_login_id := fnd_profile.value('LOGIN_ID');

     If g_invoice_info.invoice_type_lookup_code <> 'PREPAYMENT' And
        g_invoice_info.retained_amount Is Not Null 		Then

           -----------------------------------------------------------------
           l_debug_info := 'Step 2: Insert Retainage Distributions';
           Print (l_api_name, l_debug_info);
           -----------------------------------------------------------------

	   Insert_Distributions (x_invoice_id		=> x_invoice_id,
				 x_invoice_line_number	=> x_invoice_line_number,
				 x_retainage_dist_tab	=> x_retainage_dist_tab);

           -----------------------------------------------------------------
           l_debug_info := 'Step 3: Update Payment Schedules';
           Print (l_api_name, l_debug_info);
           -----------------------------------------------------------------
           --Bug 5558693 If Invoice has Net of Retainage = 'N' then the payment
           --  schedules need to be adjusted with the Retainage Amount.
	   IF nvl(g_invoice_info.net_of_retainage_flag, 'N') = 'N' THEN

              Update_Payment_Schedules (x_invoice_id => x_invoice_id);

           END IF;

           -----------------------------------------------------------------
           l_debug_info := 'Step 4: Update PO Shipment/Distributions';
     	   Print (l_api_name, l_debug_info);
           -----------------------------------------------------------------

	   Update_PO_Shipment_Dists (x_line_location_id   => g_invoice_info.po_line_location_id,
			             x_retained_amount    => g_invoice_info.retained_amount,
			             x_retainage_dist_tab => x_retainage_dist_tab);

	   x_retainage_dist_tab.delete;

     End If;

     Print (l_api_name,'Create_Retainage_Distributions (-)');

END Create_Retainage_Distributions;

PROCEDURE Insert_Distributions (x_invoice_id		IN  NUMBER,
				x_invoice_line_number	IN  NUMBER,
				x_retainage_dist_tab	OUT NOCOPY retDistType) AS

	CURSOR c_invoice_distributions (c_invoice_id 		IN ap_invoices.invoice_id%type,
					c_invoice_line_number	IN ap_invoice_lines.line_number%type,
					c_max_dist_line_number	IN ap_invoice_lines.line_number%type,
				        c_retainage_rate	IN number) IS
		SELECT
			aid.batch_id,
			aid.invoice_id,
			aid.invoice_line_number,
			aid.invoice_distribution_id				invoice_distribution_id,
			ap_invoice_distributions_s.nextval			retainage_distribution_id,
			aid.distribution_line_number + c_max_dist_line_number	retainage_dist_line_number,
			'RETAINAGE'						line_type_lookup_code,
			aid.description,
			aid.dist_match_type,
			aid.distribution_class,
			aid.org_id,
			aid.accounting_date,
			aid.period_name,
			'N' 							posted_flag,
			aid.set_of_books_id,
			decode(g_invoice_info.minimum_accountable_unit,
					null, round(aid.amount * c_retainage_rate,
						    g_invoice_info.precision),
					round((aid.amount * c_retainage_rate)
					       / g_invoice_info.minimum_accountable_unit)
					       * g_invoice_info.minimum_accountable_unit)		amount,
			decode(g_invoice_info.minimum_accountable_unit,
					null, round((aid.amount * c_retainage_rate * g_invoice_info.exchange_rate),
						     g_invoice_info.precision),
					round((aid.amount * c_retainage_rate * g_invoice_info.exchange_rate)
					       / g_invoice_info.minimum_accountable_unit)
					       * g_invoice_info.minimum_accountable_unit)		base_amount,
			aid.match_status_flag,
			aid.ussgl_transaction_code,
			aid.ussgl_trx_code_context,
			aid.po_distribution_id,
			aid.rcv_transaction_id,
			aid.unit_price,
			aid.matched_uom_lookup_code,
			aid.quantity_invoiced,
			aid.final_match_flag,
			aid.related_id,
			aid.assets_addition_flag,
			aid.project_id,
			aid.task_id,
			aid.expenditure_type,
			aid.expenditure_item_date,
			aid.expenditure_organization_id,
			aid.pa_quantity,
			'R' pa_addition_flag, -- Bug 5388196
			aid.pa_cc_ar_invoice_id,
			aid.pa_cc_ar_invoice_line_num,
			aid.pa_cc_processed_code,
			aid.award_id,
			aid.gms_burdenable_raw_cost,
			aid.awt_flag,
			aid.awt_group_id,
			aid.awt_tax_rate_id,
			aid.awt_gross_amount,
			aid.awt_invoice_id,
			aid.awt_origin_group_id,
			aid.awt_invoice_payment_id,
			aid.awt_withheld_amt,
			aid.inventory_transfer_status,
			aid.reference_1,
			aid.reference_2,
			aid.receipt_verified_flag,
			aid.receipt_required_flag,
			aid.receipt_missing_flag,
			aid.justification,
			aid.expense_group,
			aid.start_expense_date,
			aid.end_expense_date,
			aid.receipt_currency_code,
			aid.receipt_conversion_rate,
			aid.receipt_currency_amount,
			aid.attribute_category,
			aid.attribute1,
			aid.attribute2,
			aid.attribute3,
			aid.attribute4,
			aid.attribute5,
			aid.attribute6,
			aid.attribute7,
			aid.attribute8,
			aid.attribute9,
			aid.attribute10,
			aid.attribute11,
			aid.attribute12,
			aid.attribute13,
			aid.attribute14,
			aid.attribute15,
	             	aid.global_attribute_category,
	             	aid.global_attribute1,
	             	aid.global_attribute2,
	             	aid.global_attribute3,
	             	aid.global_attribute4,
	             	aid.global_attribute5,
	             	aid.global_attribute6,
	             	aid.global_attribute7,
	             	aid.global_attribute8,
	             	aid.global_attribute9,
	             	aid.global_attribute10,
	             	aid.global_attribute11,
	             	aid.global_attribute12,
	             	aid.global_attribute13,
	             	aid.global_attribute14,
	             	aid.global_attribute15,
	             	aid.global_attribute16,
	             	aid.global_attribute17,
	             	aid.global_attribute18,
	             	aid.global_attribute19,
	             	aid.global_attribute20,
			aid.intended_use
	           FROM ap_invoice_lines	 ail,
			ap_invoice_distributions aid
	          WHERE ail.invoice_id	= aid.invoice_id
                    AND ail.line_number = aid.invoice_line_number
		    AND ail.invoice_id	= c_invoice_id
		    AND ail.line_number = c_invoice_line_number
		    AND (
			 aid.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
			 or
			 (ail.match_type	    = 'PRICE_CORRECTION' and
		          aid.line_type_lookup_code = 'IPV')
			);

	TYPE itemDistType IS TABLE OF c_invoice_distributions%rowtype INDEX BY PLS_INTEGER;
	TYPE invDistType  IS TABLE OF ap_invoice_distributions_all.invoice_distribution_id%type INDEX BY PLS_INTEGER;

	item_dist_tab		itemDistType;
	inv_dist_tab		invDistType;

	l_max_dist_line_number	ap_invoice_distributions.distribution_line_number%TYPE;
	l_retainage_rate	number;

	l_sum_amount		number;
	l_sum_base_amount	number;
	l_max_dist_amount       number;
	l_rounding_index        number;

	l_debug_info            Varchar2(240);
        l_api_name		Constant Varchar2(100) := 'Insert_Distributions';

BEGIN

     Print (l_api_name,'Insert_Distributions (+)');

     -----------------------------------------------------------------
     l_debug_info := 'Step 1: Initialize cursor parameters and fetch invoice distributions';
     Print (l_api_name, l_debug_info);
     -----------------------------------------------------------------

     l_retainage_rate	    := g_invoice_info.retained_amount / g_invoice_info.line_amount;

     l_max_dist_line_number := AP_INVOICE_LINES_PKG.get_max_dist_line_num(x_invoice_id, x_invoice_line_number);

     OPEN c_invoice_distributions (x_invoice_id,
				   x_invoice_line_number,
				   l_max_dist_line_number,
				   l_retainage_rate);
     FETCH c_invoice_distributions
      BULK COLLECT INTO item_dist_tab;
     CLOSE c_invoice_distributions;

     l_sum_amount	:= 0;
     l_sum_base_amount	:= 0;
     l_max_dist_amount  := 0;

     -----------------------------------------------------------------
     l_debug_info := 'Step 2: Populate pl/sql table with prorated retainage distributions';
     Print (l_api_name, l_debug_info);
     -----------------------------------------------------------------

     IF item_dist_tab.COUNT > 0 THEN

	FOR i IN item_dist_tab.first .. item_dist_tab.last
	LOOP
	    x_retainage_dist_tab(i).invoice_id			:= item_dist_tab(i).invoice_id;
	    x_retainage_dist_tab(i).invoice_line_number		:= item_dist_tab(i).invoice_line_number;
	    x_retainage_dist_tab(i).line_type_lookup_code	:= item_dist_tab(i).line_type_lookup_code;

	    x_retainage_dist_tab(i).invoice_distribution_id	:= item_dist_tab(i).retainage_distribution_id;
	    x_retainage_dist_tab(i).distribution_line_number	:= item_dist_tab(i).retainage_dist_line_number;
	    x_retainage_dist_tab(i).dist_code_combination_id	:= g_invoice_info.retainage_code_combination_id;

	    x_retainage_dist_tab(i).amount			:= item_dist_tab(i).amount;
	    x_retainage_dist_tab(i).base_amount			:= item_dist_tab(i).base_amount;

	    x_retainage_dist_tab(i).description			:= item_dist_tab(i).description;
	    x_retainage_dist_tab(i).dist_match_type		:= item_dist_tab(i).dist_match_type;
	    x_retainage_dist_tab(i).distribution_class		:= item_dist_tab(i).distribution_class;

	    x_retainage_dist_tab(i).set_of_books_id		:= item_dist_tab(i).set_of_books_id;
	    x_retainage_dist_tab(i).org_id			:= item_dist_tab(i).org_id;

	    x_retainage_dist_tab(i).accounting_date		:= item_dist_tab(i).accounting_date;
	    x_retainage_dist_tab(i).period_name			:= item_dist_tab(i).period_name;
	    x_retainage_dist_tab(i).posted_flag			:= item_dist_tab(i).posted_flag;

	    x_retainage_dist_tab(i).ussgl_transaction_code	:= item_dist_tab(i).ussgl_transaction_code;
	    x_retainage_dist_tab(i).ussgl_trx_code_context	:= item_dist_tab(i).ussgl_trx_code_context;

	    x_retainage_dist_tab(i).po_distribution_id		:= item_dist_tab(i).po_distribution_id;
	    x_retainage_dist_tab(i).rcv_transaction_id		:= item_dist_tab(i).rcv_transaction_id;

	    x_retainage_dist_tab(i).unit_price			:= item_dist_tab(i).unit_price;
	    x_retainage_dist_tab(i).matched_uom_lookup_code	:= item_dist_tab(i).matched_uom_lookup_code;

	    -- Quantity will not be prorated.
	    -- x_retainage_dist_tab(i).quantity_invoiced	:= item_dist_tab(i).quantity_invoiced;

	    x_retainage_dist_tab(i).match_status_flag		:= item_dist_tab(i).match_status_flag;
	    x_retainage_dist_tab(i).final_match_flag		:= item_dist_tab(i).final_match_flag;

	    x_retainage_dist_tab(i).related_id			:= item_dist_tab(i).related_id;
	    x_retainage_dist_tab(i).inventory_transfer_status	:= item_dist_tab(i).inventory_transfer_status;
	    x_retainage_dist_tab(i).reference_1			:= item_dist_tab(i).reference_1;
	    x_retainage_dist_tab(i).reference_2			:= item_dist_tab(i).reference_2;

	    x_retainage_dist_tab(i).assets_addition_flag	:= item_dist_tab(i).assets_addition_flag;
	    x_retainage_dist_tab(i).assets_tracking_flag	:= 'N';
	    x_retainage_dist_tab(i).asset_book_type_code	:= NULL;
	    x_retainage_dist_tab(i).asset_category_id		:= NULL;

	    x_retainage_dist_tab(i).project_id			:= item_dist_tab(i).project_id;
	    x_retainage_dist_tab(i).task_id			:= item_dist_tab(i).task_id;
	    x_retainage_dist_tab(i).expenditure_type		:= item_dist_tab(i).expenditure_type;
	    x_retainage_dist_tab(i).expenditure_item_date	:= item_dist_tab(i).expenditure_item_date;
	    x_retainage_dist_tab(i).expenditure_organization_id	:= item_dist_tab(i).expenditure_organization_id;
	    x_retainage_dist_tab(i).pa_quantity			:= item_dist_tab(i).pa_quantity;
	    x_retainage_dist_tab(i).pa_addition_flag		:= item_dist_tab(i).pa_addition_flag;
	    x_retainage_dist_tab(i).pa_cc_ar_invoice_id		:= item_dist_tab(i).pa_cc_ar_invoice_id;
	    x_retainage_dist_tab(i).pa_cc_ar_invoice_line_num	:= item_dist_tab(i).pa_cc_ar_invoice_line_num;
	    x_retainage_dist_tab(i).pa_cc_processed_code	:= item_dist_tab(i).pa_cc_processed_code;
	    x_retainage_dist_tab(i).award_id			:= item_dist_tab(i).award_id;
	    x_retainage_dist_tab(i).gms_burdenable_raw_cost	:= item_dist_tab(i).gms_burdenable_raw_cost;

	    x_retainage_dist_tab(i).attribute_category		:= item_dist_tab(i).attribute_category;
	    x_retainage_dist_tab(i).attribute1			:= item_dist_tab(i).attribute1;
	    x_retainage_dist_tab(i).attribute2			:= item_dist_tab(i).attribute2;
	    x_retainage_dist_tab(i).attribute3			:= item_dist_tab(i).attribute3;
	    x_retainage_dist_tab(i).attribute4			:= item_dist_tab(i).attribute4;
	    x_retainage_dist_tab(i).attribute5			:= item_dist_tab(i).attribute5;
	    x_retainage_dist_tab(i).attribute6			:= item_dist_tab(i).attribute6;
	    x_retainage_dist_tab(i).attribute7			:= item_dist_tab(i).attribute7;
	    x_retainage_dist_tab(i).attribute8			:= item_dist_tab(i).attribute8;
	    x_retainage_dist_tab(i).attribute9			:= item_dist_tab(i).attribute9;
	    x_retainage_dist_tab(i).attribute10			:= item_dist_tab(i).attribute10;
	    x_retainage_dist_tab(i).attribute11			:= item_dist_tab(i).attribute11;
	    x_retainage_dist_tab(i).attribute12			:= item_dist_tab(i).attribute12;
	    x_retainage_dist_tab(i).attribute13			:= item_dist_tab(i).attribute13;
	    x_retainage_dist_tab(i).attribute14			:= item_dist_tab(i).attribute14;
	    x_retainage_dist_tab(i).attribute15			:= item_dist_tab(i).attribute15;
	    x_retainage_dist_tab(i).global_attribute_category	:= item_dist_tab(i).global_attribute_category;
	    x_retainage_dist_tab(i).global_attribute1		:= item_dist_tab(i).global_attribute1;
	    x_retainage_dist_tab(i).global_attribute2		:= item_dist_tab(i).global_attribute2;
	    x_retainage_dist_tab(i).global_attribute3		:= item_dist_tab(i).global_attribute3;
	    x_retainage_dist_tab(i).global_attribute4		:= item_dist_tab(i).global_attribute4;
	    x_retainage_dist_tab(i).global_attribute5		:= item_dist_tab(i).global_attribute5;
	    x_retainage_dist_tab(i).global_attribute6		:= item_dist_tab(i).global_attribute6;
	    x_retainage_dist_tab(i).global_attribute7		:= item_dist_tab(i).global_attribute7;
	    x_retainage_dist_tab(i).global_attribute8		:= item_dist_tab(i).global_attribute8;
	    x_retainage_dist_tab(i).global_attribute9		:= item_dist_tab(i).global_attribute9;
	    x_retainage_dist_tab(i).global_attribute10		:= item_dist_tab(i).global_attribute10;
	    x_retainage_dist_tab(i).global_attribute11		:= item_dist_tab(i).global_attribute11;
	    x_retainage_dist_tab(i).global_attribute12		:= item_dist_tab(i).global_attribute12;
	    x_retainage_dist_tab(i).global_attribute13		:= item_dist_tab(i).global_attribute13;
	    x_retainage_dist_tab(i).global_attribute14		:= item_dist_tab(i).global_attribute14;
	    x_retainage_dist_tab(i).global_attribute15		:= item_dist_tab(i).global_attribute15;
	    x_retainage_dist_tab(i).global_attribute16		:= item_dist_tab(i).global_attribute16;
	    x_retainage_dist_tab(i).global_attribute17		:= item_dist_tab(i).global_attribute17;
	    x_retainage_dist_tab(i).global_attribute18		:= item_dist_tab(i).global_attribute18;
	    x_retainage_dist_tab(i).global_attribute19		:= item_dist_tab(i).global_attribute19;
	    x_retainage_dist_tab(i).global_attribute20		:= item_dist_tab(i).global_attribute20;

	    x_retainage_dist_tab(i).created_by			:= g_user_id;
	    x_retainage_dist_tab(i).creation_date		:= sysdate;
	    x_retainage_dist_tab(i).last_updated_by		:= g_user_id;
	    x_retainage_dist_tab(i).last_update_date		:= sysdate;
	    x_retainage_dist_tab(i).last_update_login		:= g_login_id;

	    x_retainage_dist_tab(i).intended_use		:= item_dist_tab(i).intended_use;

	    x_retainage_dist_tab(i).related_retainage_dist_id	:= item_dist_tab(i).invoice_distribution_id;
	    x_retainage_dist_tab(i).retained_amount_remaining	:= -1 * item_dist_tab(i).amount;

	    IF (item_dist_tab(i).amount >= l_max_dist_amount) THEN
		l_rounding_index  := i;
		l_max_dist_amount := item_dist_tab(i).amount;
	    END IF;

	    l_sum_amount      := l_sum_amount + item_dist_tab(i).amount;
	    l_sum_base_amount := l_sum_base_amount + item_dist_tab(i).base_amount;

	    inv_dist_tab(i) := item_dist_tab(i).invoice_distribution_id;

	END LOOP;

        -----------------------------------------------------------------
        l_debug_info := 'Step 3: Perform rounding on prorated retainage distributions';
   	Print (l_api_name, l_debug_info);
        -----------------------------------------------------------------

	IF l_rounding_index Is Not Null THEN

	   IF l_sum_amount <> g_invoice_info.retained_amount THEN

	      x_retainage_dist_tab(l_rounding_index).amount := x_retainage_dist_tab(l_rounding_index).amount   +
							       (g_invoice_info.retained_amount - l_sum_amount);

	      x_retainage_dist_tab(l_rounding_index).retained_amount_remaining
							    := -1 * x_retainage_dist_tab(l_rounding_index).amount;
	   END IF;

	   IF g_invoice_info.exchange_rate Is Not Null THEN

	      IF l_sum_base_amount <> g_invoice_info.base_retained_amount THEN

		 x_retainage_dist_tab(l_rounding_index).rounding_amt := g_invoice_info.base_retained_amount - l_sum_base_amount;

		 x_retainage_dist_tab(l_rounding_index).base_amount  := x_retainage_dist_tab(l_rounding_index).base_amount +
								        x_retainage_dist_tab(l_rounding_index).rounding_amt;
	      END IF;
	   END IF;
	END IF;

        -----------------------------------------------------------------
        l_debug_info := 'Step 4: Insert Retainage Distributions';
     	Print (l_api_name, l_debug_info);
        -----------------------------------------------------------------

	FORALL j in x_retainage_dist_tab.first .. x_retainage_dist_tab.last

		INSERT INTO ap_invoice_distributions VALUES x_retainage_dist_tab(j);

        -----------------------------------------------------------------
        l_debug_info := 'Step 5: Update related_retainage_dist_id on parent distributions';
  	Print (l_api_name, l_debug_info);
        -----------------------------------------------------------------

	FORALL k in inv_dist_tab.first .. inv_dist_tab.last

		UPDATE ap_invoice_distributions_all
		   SET related_retainage_dist_id = inv_dist_tab(k)
		 WHERE invoice_distribution_id = inv_dist_tab(k);

        -----------------------------------------------------------------
        l_debug_info := 'Step 6: Clear the local pl/sql tables';
     	Print (l_api_name, l_debug_info);
        -----------------------------------------------------------------

	inv_dist_tab.delete;
	item_dist_tab.delete;

     END IF;

     Print (l_api_name, 'Insert_Distributions (-)');

END Insert_Distributions;

PROCEDURE Update_Payment_Schedules (x_invoice_id IN ap_invoices.invoice_id%type) AS

    CURSOR c_payment_schedules (c_invoice_id IN ap_invoices.invoice_id%type) IS
	SELECT *
	  FROM ap_payment_schedules_all
	 WHERE invoice_id  = c_invoice_id
    	   FOR UPDATE OF amount_remaining;

    TYPE payNum		IS TABLE OF ap_payment_schedules_all.payment_num%type INDEX BY PLS_INTEGER;
    TYPE paySchedUpd	IS TABLE OF ap_payment_schedules_all%rowtype INDEX BY PLS_INTEGER;

    pay_num_tab		payNum;
    pay_sched_upd_tab	paySchedUpd;

    l_inv_curr_gross_amount		ap_payment_schedules_all.inv_curr_gross_amount%type;
    l_invoice_amount			ap_invoices_all.invoice_amount%type
						:= g_invoice_info.invoice_amount;
    l_retained_amount			ap_invoice_lines_all.retained_amount%type
						:= g_invoice_info.retained_amount;
    l_invoice_currency_code		ap_invoices_all.invoice_currency_code%type
						:= g_invoice_info.invoice_currency_code;
    l_payment_currency_code		ap_invoices_all.payment_currency_code%type
						:= g_invoice_info.payment_currency_code;
    l_payment_cross_rate		ap_invoices_all.payment_cross_rate%type
						:= g_invoice_info.payment_cross_rate;
    l_amt_applicable_to_discount	ap_invoices_all.amount_applicable_to_discount%type
						:= g_invoice_info.amount_applicable_to_discount;

    l_amt_to_subtract			NUMBER;
    l_amt_to_subtract_pay_curr		NUMBER;
    l_disc_amt_factor			NUMBER;
    l_sum_amt_to_subtract		NUMBER := 0;
    l_last_schedule			NUMBER;

    l_debug_info            		Varchar2(2000);
    l_api_name				Constant Varchar2(100)
						:= 'Update_Payment_Schedules';

BEGIN

    Print (l_api_name, 'Update_Payment_Schedules (+)');

    OPEN  c_payment_schedules(x_invoice_id);
    FETCH c_payment_schedules
     BULK COLLECT INTO pay_sched_upd_tab;
    CLOSE c_payment_schedules;

    If pay_sched_upd_tab.COUNT > 0 Then

       -----------------------------------------------------------------
       l_debug_info := 'Step 1: Fetch Payment Schedules';
       Print (l_api_name, l_debug_info);
       -----------------------------------------------------------------

       For i IN pay_sched_upd_tab.first .. pay_sched_upd_tab.last
       Loop
	   If (l_invoice_amount = 0) Then

               l_amt_to_subtract := 0;
               l_disc_amt_factor := 0;

	   Else

	       l_inv_curr_gross_amount    := nvl(pay_sched_upd_tab(i).inv_curr_gross_amount, pay_sched_upd_tab(i).gross_amount);

	       l_amt_to_subtract 	  := l_retained_amount *
						  (l_inv_curr_gross_amount / l_invoice_amount);

	       l_amt_to_subtract 	  := ap_utilities_pkg.ap_round_currency
						(l_amt_to_subtract, l_invoice_currency_code);

	       l_amt_to_subtract_pay_curr := ap_utilities_pkg.ap_round_currency
						(l_amt_to_subtract * l_payment_cross_rate, l_payment_currency_code);

	       l_disc_amt_factor	  := l_retained_amount /
						nvl(l_amt_applicable_to_discount, l_invoice_amount);

	       pay_sched_upd_tab(i).gross_amount
					:= pay_sched_upd_tab(i).gross_amount +
						l_amt_to_subtract_pay_curr;

	       pay_sched_upd_tab(i).inv_curr_gross_amount := pay_sched_upd_tab(i).gross_amount;

	       pay_sched_upd_tab(i).amount_remaining
					:= pay_sched_upd_tab(i).amount_remaining +
						l_amt_to_subtract_pay_curr;

	       pay_sched_upd_tab(i).discount_amount_available
					:= pay_sched_upd_tab(i).discount_amount_available +
						ap_utilities_pkg.ap_round_currency
						   (pay_sched_upd_tab(i).discount_amount_available * l_disc_amt_factor,
						    l_payment_currency_code);

	       pay_sched_upd_tab(i).second_disc_amt_available
					:= pay_sched_upd_tab(i).second_disc_amt_available +
						ap_utilities_pkg.ap_round_currency
						   (pay_sched_upd_tab(i).second_disc_amt_available * l_disc_amt_factor,
						    l_payment_currency_code);

	       pay_sched_upd_tab(i).third_disc_amt_available
					:= pay_sched_upd_tab(i).third_disc_amt_available +
						ap_utilities_pkg.ap_round_currency
						   (pay_sched_upd_tab(i).third_disc_amt_available  * l_disc_amt_factor,
						    l_payment_currency_code);

	       l_sum_amt_to_subtract	  := l_sum_amt_to_subtract + l_amt_to_subtract;

	       pay_num_tab(i) := pay_sched_upd_tab(i).payment_num;

               --bug 8991699
	       -----------------------------------------------------------------
               l_debug_info := 'Step 1.1: After fetching each record: l_inv_curr_gross_amount->'||l_inv_curr_gross_amount||
	       'l_amt_to_subtract->'||l_amt_to_subtract||'l_amt_to_subtract_pay_curr->'||l_amt_to_subtract_pay_curr||
	       'pay_sched_upd_tab(i).inv_curr_gross_amount->'||pay_sched_upd_tab(i).inv_curr_gross_amount||
	       'pay_sched_upd_tab(i).amount_remaining->'||pay_sched_upd_tab(i).amount_remaining;
               Print (l_api_name, l_debug_info);
               -----------------------------------------------------------------

          End If;
	End Loop;

	-- To keep it consistent with the withholding logic, rounding
	-- due to proration is applied to the last payment schedule.
	--bug 8991699
        -----------------------------------------------------------------
        l_debug_info := 'Step 2: Perform rounding on payment schedules->l_retained_amount'||l_retained_amount||
	'l_sum_amt_to_subtract->'||l_sum_amt_to_subtract;
    	Print (l_api_name, l_debug_info);
        -----------------------------------------------------------------

	If l_retained_amount <> l_sum_amt_to_subtract Then

	   l_last_schedule := pay_sched_upd_tab.last;

	   --Changed  '-' to '+' in the below statement for the bug #8795837

	   pay_sched_upd_tab(l_last_schedule).gross_amount
						:= pay_sched_upd_tab(l_last_schedule).gross_amount
						  + (l_retained_amount - l_sum_amt_to_subtract);

	   pay_sched_upd_tab(l_last_schedule).inv_curr_gross_amount
						:= pay_sched_upd_tab(l_last_schedule).gross_amount;

            --Changed  '-' to '+' in the below statement for the bug #8849377

	   pay_sched_upd_tab(l_last_schedule).amount_remaining
						:= pay_sched_upd_tab(l_last_schedule).amount_remaining
						    +	(l_retained_amount - l_sum_amt_to_subtract);
	End If;

        -----------------------------------------------------------------
        l_debug_info := 'Step 3: Bulk Update Payment Schedules';
    	Print (l_api_name, l_debug_info);
        -----------------------------------------------------------------

	FORALL i in pay_sched_upd_tab.first .. pay_sched_upd_tab.last

		UPDATE ap_payment_schedules_all
		   SET ROW = pay_sched_upd_tab(i)
		 WHERE invoice_id  = x_invoice_id
		   AND payment_num = pay_num_tab(i);

/*
        -----------------------------------------------------------------
        l_debug_info := 'Step 4: Update amount_applicable_to_discount';
    	Print (l_api_name, l_debug_info);
        -----------------------------------------------------------------

	UPDATE ap_invoices_all
	   SET amount_applicable_to_discount = (amount_applicable_to_discount + l_retained_amount)
         WHERE invoice_id = x_invoice_id;
*/
	pay_num_tab.delete;
	pay_sched_upd_tab.delete;

    End If;

  --bug 8991699 begin
        ---------------------------------------------------------------------------------------------------------
        l_debug_info := 'Step 4: Update invoice header amount_applicable_to_discount and pay_curr_invoice_amount';
    	Print (l_api_name, l_debug_info);
        ----------------------------------------------------------------------------------------------------------

     IF abs(l_retained_amount) > 0 then
	UPDATE ap_invoices_all
	   SET amount_applicable_to_discount = (amount_applicable_to_discount + l_retained_amount),
	       pay_curr_invoice_amount = (pay_curr_invoice_amount + l_retained_amount)
         WHERE invoice_id = x_invoice_id;

     ENd IF;

 --bug 8991699 end

    Print (l_api_name, 'Update_Payment_Schedules(-)');

END Update_Payment_Schedules;

Procedure Update_PO_Shipment_Dists
			(x_line_location_id	IN ap_invoice_lines_all.po_line_location_id%type,
			 x_retained_amount	IN ap_invoice_lines_all.retained_amount%type,
			 x_retainage_dist_tab	IN retDistType) AS

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
				 p_retainage_withheld_amt => -x_retained_amount,
				 p_retainage_released_amt => NULL
				);

   FOR i in nvl(x_retainage_dist_tab.first,0)..nvl(x_retainage_dist_tab.last,0)
   LOOP

       IF (x_retainage_dist_tab.exists(i)) THEN

          l_po_ap_dist_rec.add_change
				(p_po_distribution_id	  => x_retainage_dist_tab(i).po_distribution_id,
    				 p_uom_code		  => NULL,
				 p_quantity_billed	  => NULL,
				 p_amount_billed	  => NULL,
				 p_quantity_financed	  => NULL,
				 p_amount_financed	  => NULL,
				 p_quantity_recouped	  => NULL,
				 p_amount_recouped	  => NULL,
				 p_retainage_withheld_amt => -x_retainage_dist_tab(i).amount,
				 p_retainage_released_amt => NULL);


       END IF;

   END LOOP;

   PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
					P_Api_Version	       => 1.0,
					P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
					P_Dist_Changes_Rec     => l_po_ap_dist_rec,
					X_Return_Status	       => l_return_status,
					X_Msg_Data	       => l_msg_data);
END Update_PO_Shipment_Dists;

Procedure Print (x_api_name   IN Varchar2, x_debug_info IN Varchar2) As
Begin
     IF (g_level_procedure >= g_current_runtime_level) THEN
         fnd_log.string(g_level_procedure,g_module_name||x_api_name,x_debug_info);
     END IF;
End Print;

END AP_RETAINAGE_PKG;

/
