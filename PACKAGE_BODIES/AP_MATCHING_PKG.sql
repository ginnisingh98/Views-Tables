--------------------------------------------------------
--  DDL for Package Body AP_MATCHING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_MATCHING_PKG" AS
/*$Header: apmatchb.pls 120.58.12010000.18 2010/04/22 08:44:27 asansari ship $*/

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
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_MATCHING_PKG.';

--LOCAL PROCEDURES
PROCEDURE Get_Info(X_Invoice_ID  	 IN NUMBER,
 		   X_Invoice_Line_Number IN NUMBER DEFAULT NULL,
		   X_Match_Amount	 IN NUMBER DEFAULT NULL,
		   X_Po_Line_Location_Id IN NUMBER DEFAULT NULL,
		   X_Calling_Sequence	 IN VARCHAR2 );

Procedure Get_Dist_Proration_Info(
		  X_Invoice_Id		 IN NUMBER,
		  X_Invoice_Line_Number  IN NUMBER,
		  X_Po_Line_Location_Id  IN NUMBER,
	  	  X_Match_Mode		 IN VARCHAR2,
		  X_Match_Quantity	 IN NUMBER,
		  X_Match_Amount	 IN NUMBER,
		  X_Unit_Price		 IN NUMBER,
		  X_Overbill_Flag	 IN VARCHAR2,
		  X_Dist_Tab		 IN OUT NOCOPY DIST_TAB_TYPE,
		  X_Calling_Sequence	 IN VARCHAR2);

PROCEDURE Get_Total_Proration_Quantity(
                    X_PO_Line_Location_Id  IN 	NUMBER,
                    X_Match_Mode     	   IN 	VARCHAR2,
		    X_Overbill_Flag  	   IN 	VARCHAR2,
		    X_Total_Quantity 	   OUT  NOCOPY NUMBER,
		    X_Calling_Sequence	   IN	VARCHAR2);


Procedure Update_PO_Shipments_Dists(
		    X_Dist_Tab	          IN OUT NOCOPY  Dist_Tab_Type,
		    X_Po_Line_Location_Id IN 	         NUMBER,
		    X_Match_Amount        IN   		 NUMBER,
		    X_Match_Quantity	  IN		 NUMBER,
		    X_Uom_Lookup_Code  	  IN  		 VARCHAR2,
  		    X_Calling_Sequence    IN  		 VARCHAR2);


Procedure Insert_Invoice_Line (
		    X_Invoice_Id 	      IN NUMBER,
		    X_Invoice_Line_Number     IN NUMBER,
		    X_Line_Type_Lookup_Code   IN VARCHAR2,
		    X_Cost_Factor_id	      IN NUMBER DEFAULT NULL,
		    X_Single_Dist_Flag	      IN VARCHAR2 DEFAULT 'N',
		    X_Po_Distribution_Id      IN NUMBER DEFAULT NULL,
       		    X_Po_Line_Location_Id     IN NUMBER DEFAULT NULL,
		    X_Amount		      IN NUMBER,
		    X_Quantity_Invoiced	      IN NUMBER DEFAULT NULL,
		    X_Unit_Price	      IN NUMBER DEFAULT NULL,
		    X_Final_Match_Flag	      IN VARCHAR2 DEFAULT NULL,
		    X_Item_Line_Number	      IN NUMBER,
		    X_Charge_Line_Description IN VARCHAR2,
		    X_Retained_Amount	      IN NUMBER	  DEFAULT NULL,
		    X_Calling_Sequence	      IN VARCHAR2);

PROCEDURE Insert_Invoice_Distributions (
		    X_Invoice_ID	  IN 	 NUMBER,
	  	    X_Invoice_Line_Number IN	 NUMBER,
		    X_Dist_Tab		  IN OUT NOCOPY Dist_Tab_Type,
		    X_Final_Match_Flag	  IN	 VARCHAR2,
		    X_Unit_Price	  IN	 NUMBER,
		    X_Total_Amount	  IN     NUMBER,
	  	    X_Calling_Sequence	  IN	 VARCHAR2);


Procedure Create_Charge_Lines(
		    X_Invoice_Id 	  IN  NUMBER,
		    X_Freight_Cost_Factor_id IN NUMBER,
    		    X_Freight_Amount   	  IN  NUMBER,
    		    X_Freight_Description IN  VARCHAR2,
		    X_Misc_Cost_Factor_id IN  NUMBER,
    		    X_Misc_Amount	  IN  NUMBER,
  		    X_Misc_Description	  IN  VARCHAR2,
    		    X_Item_Line_Number	  IN  NUMBER,
    		    X_Calling_Sequence	  IN  VARCHAR2);

PROCEDURE Get_Corr_Dist_Proration_Info(
                    X_Corrected_Invoice_id  IN    NUMBER,
		    X_Corrected_Line_Number IN    NUMBER,
		    X_Corr_Dist_Tab         IN OUT NOCOPY CORR_DIST_TAB_TYPE,
		    X_Correction_Type       IN    VARCHAR2,
		    X_Correction_Amount     IN    NUMBER,
		    X_Correction_Quantity   IN    NUMBER,
		    X_Correction_Price      IN    NUMBER,
		    X_Match_Mode	    IN    VARCHAR2,
		    X_Calling_Sequence      IN    VARCHAR2);

PROCEDURE Insert_Corr_Invoice_Line(
	 	    X_Invoice_Id            IN  NUMBER,
		    X_Invoice_Line_Number   IN  NUMBER,
		    X_Corrected_Invoice_Id  IN  NUMBER,
		    X_Corrected_Line_Number IN  NUMBER,
		    X_Quantity     	    IN  NUMBER,
		    X_Amount       	    IN  NUMBER,
		    X_Unit_Price   	    IN  NUMBER,
		    X_Correction_Type	    IN  VARCHAR2,
		    X_Final_Match_Flag	    IN  VARCHAR2,
		    X_Po_Distribution_Id    IN  NUMBER,
		    X_Retained_Amount	    IN  NUMBER DEFAULT NULL,
		    X_Calling_Sequence      IN  VARCHAR2);

PROCEDURE Insert_Corr_Invoice_Dists(
		    X_Invoice_Id          IN  NUMBER,
		    X_Invoice_Line_Number IN  NUMBER,
		    X_Corrected_Invoice_Id IN NUMBER,
		    X_Corr_Dist_Tab       IN  OUT NOCOPY CORR_DIST_TAB_TYPE,
		    X_Correction_Type     IN  VARCHAR2,
		    X_Final_Match_Flag    IN  VARCHAR2,
		    X_Total_Amount     	  IN  NUMBER,
		    X_Calling_Sequence    IN  VARCHAR2);

PROCEDURE Update_Corr_Po_Shipments_Dists(
		    X_Corr_Dist_Tab       IN CORR_DIST_TAB_TYPE,
		    X_Po_Line_Location_Id IN NUMBER,
    		    X_Quantity            IN NUMBER,
		    X_Amount              IN NUMBER,
                    X_Correction_Type     IN VARCHAR2,
		    X_Uom_Lookup_Code     IN VARCHAR2,
		    X_Calling_Sequence    IN VARCHAR2);

PROCEDURE Get_Shipment_List_For_QM(
		    X_Invoice_Id       IN  NUMBER,
		    X_Po_Header_Id     IN  NUMBER,
		    X_Match_Option     IN  VARCHAR2,
		    X_Match_Amount     IN  NUMBER,
		    X_Shipment_Table   OUT NOCOPY T_SHIPMENT_TABLE,
		    X_Calling_Sequence IN  VARCHAR2);

PROCEDURE Generate_Lines_For_QuickMatch (
		    X_Invoice_Id       IN  NUMBER,
		    X_Shipment_Table   IN  T_SHIPMENT_TABLE,
		    X_Match_Option     IN  VARCHAR2,
		    X_Calling_Sequence IN  VARCHAR2);

Procedure Generate_Release_Lines (p_po_header_id     IN NUMBER,
                                  p_invoice_id       IN NUMBER,
                                  p_release_amount   IN NUMBER,
                                  x_calling_sequence IN VARCHAR2);

--Global Variable Declaration
G_Max_Invoice_Line_Number	ap_invoice_lines.line_number%TYPE := 0;
G_Batch_id			ap_batches.batch_id%TYPE;
G_Accounting_Date 		ap_invoice_lines.accounting_date%TYPE;
G_Period_Name    		gl_period_statuses.period_name%TYPE;
G_Set_of_Books_ID 		ap_system_parameters.set_of_books_id%TYPE;
G_Awt_Group_ID 			ap_awt_groups.group_id%TYPE;
G_Invoice_Type_Lookup_Code	ap_invoices.invoice_type_lookup_code%TYPE;
G_Exchange_Rate			ap_invoices.exchange_rate%TYPE;
G_Precision			fnd_currencies.precision%TYPE;
G_Min_Acct_Unit			fnd_currencies.minimum_accountable_unit%TYPE;
G_System_Allow_Awt_Flag		ap_system_parameters.allow_awt_flag%TYPE;
G_Site_Allow_Awt_Flag		po_vendor_sites.allow_awt_flag%TYPE;
G_Transfer_Flag			ap_system_parameters.transfer_desc_flex_flag%TYPE;
G_Base_Currency_Code		ap_system_parameters.base_currency_code%TYPE;
G_Invoice_Currency_Code		ap_invoices.invoice_currency_code%TYPE;
G_Allow_PA_Override		varchar2(1);
G_Pa_Expenditure_Date_Default	varchar2(50);
G_Prepay_CCID                   ap_system_parameters.prepay_code_combination_id%TYPE;
G_Build_Prepay_Accts_Flag       ap_system_parameters.build_prepayment_accounts_flag%TYPE;
G_Income_Tax_Region		ap_system_parameters.income_tax_region%TYPE;
G_Project_ID			pa_projects_all.project_id%TYPE;
G_Task_ID			pa_tasks.task_id%TYPE;
G_Award_ID			po_distributions_all.award_id%TYPE;
G_Expenditure_Type		pa_expenditure_types.expenditure_type%TYPE;
G_Invoice_Date			ap_invoices.invoice_date%TYPE;
G_Expenditure_Organization_ID	pa_exp_orgs_it.organization_id%TYPE;
G_Asset_Book_Type_Code		fa_book_controls.book_type_code%TYPE;
G_Asset_Category_Id		mtl_system_items.asset_category_id%TYPE;
G_Inventory_Organization_Id	financials_system_parameters.inventory_organization_id%TYPE;
G_Approval_Workflow_Flag	ap_system_parameters.approval_workflow_flag%TYPE;
-- Removed for bug 4277744
-- G_Ussgl_Transaction_Code	ap_invoices.ussgl_transaction_code%TYPE;
G_Allow_Flex_Override_Flag      ap_system_parameters.allow_flex_override_flag%TYPE;
G_Shipment_Type			po_line_locations.shipment_type%TYPE;
G_Org_id			ap_invoices.org_id%TYPE;
G_Encumbrance_Flag              financials_system_parameters.purch_encumbrance_flag%TYPE;
G_User_Id			number;
G_Login_Id			number;
G_Account_Segment	        ap_invoice_lines.account_segment%TYPE := NULL;
G_Balancing_Segment		ap_invoice_lines.balancing_segment%TYPE := NULL;
G_Cost_Center_Segment		ap_invoice_lines.cost_center_segment%TYPE := NULL;
G_Overlay_Dist_Code_Concat	ap_invoice_lines.overlay_dist_code_concat%TYPE := NULL;
G_Default_Dist_CCid		ap_invoice_lines.default_dist_ccid%TYPE := NULL;
G_Line_Project_Id		ap_invoice_lines.project_id%TYPE ;
G_Line_Task_Id			ap_invoice_lines.task_id%TYPE ;
G_Line_Award_ID			ap_invoice_lines.award_id%TYPE ;
G_Line_Expenditure_Type		ap_invoice_lines.expenditure_type%TYPE ;
G_Line_Expenditure_Item_Date    ap_invoice_lines.expenditure_item_date%TYPE ;
G_Line_Expenditure_Org_Id       ap_invoice_lines.expenditure_organization_id%TYPE ;
G_Line_Base_Amount		ap_invoice_lines.base_amount%TYPE ;
G_Line_Awt_Group_Id		ap_invoice_lines.awt_group_id%TYPE ;
G_Line_Accounting_Date		ap_invoice_lines.accounting_date%TYPE;
G_Trx_Business_Category	        ap_invoices.trx_business_category%TYPE;
--Contract Payments
G_Vendor_Id			ap_invoices.vendor_id%TYPE;
G_Vendor_Site_Id		ap_invoices.vendor_site_id%TYPE;
G_Po_Line_Id			po_lines_all.po_line_id%TYPE;
G_Recoupment_Rate		po_lines_all.recoupment_rate%TYPE;
G_Release_Amount_Net_Of_Tax	ap_invoices_all.release_amount_net_of_tax%TYPE;
--Bugfix:5565310
G_intended_use			zx_lines_det_factors.line_intended_use%type;
G_product_type			zx_lines_det_factors.product_type%type;
G_product_category		zx_lines_det_factors.product_category%type;
G_product_fisc_class		zx_lines_det_factors.product_fisc_classification%type;
G_user_defined_fisc_class       zx_lines_det_factors.user_defined_fisc_class%type;
G_assessable_value		zx_lines_det_factors.assessable_value%type;
G_dflt_tax_class_code		zx_transaction_lines_gt.input_tax_classification_code%type;
G_source			ap_invoices_all.source%type;
G_recurring_payment_id          ap_invoices.recurring_payment_id%TYPE;  -- Bug 7305223
G_PAY_AWT_GROUP_ID   ap_invoices_all.pay_awt_group_id%TYPE; -- bug8222382
G_Line_Pay_Awt_Group_Id		ap_invoice_lines.pay_awt_group_id%TYPE ; -- bug8222382

PROCEDURE Base_Credit_PO_Match(X_match_mode    	  IN 	VARCHAR2,
                   	    X_invoice_id    	  IN	NUMBER,
		   	    X_invoice_line_number IN	NUMBER,
		   	    X_Po_Line_Location_id IN	NUMBER,
		   	    X_Dist_Tab		  IN OUT NOCOPY DIST_TAB_TYPE,
		   	    X_amount	          IN	NUMBER,
		            X_quantity 		  IN 	NUMBER,
		            X_unit_price    	  IN 	NUMBER,
		            X_uom_lookup_code     IN	VARCHAR2,
		   	    X_final_match_flag 	  IN   	VARCHAR2,
			    X_overbill_flag 	  IN	VARCHAR2,
			    X_freight_cost_factor_id IN NUMBER DEFAULT NULL,
		  	    X_freight_amount	  IN	NUMBER,
			    X_freight_description IN	VARCHAR2,
			    X_misc_cost_factor_id IN    NUMBER DEFAULT NULL,
			    X_misc_amount	  IN	NUMBER,
			    X_misc_description	  IN	VARCHAR2,
			    X_retained_amount     IN    NUMBER DEFAULT NULL,
			    X_calling_sequence	  IN	VARCHAR2) IS

l_single_dist_flag		varchar2(1) := 'N';
l_po_distribution_id		po_distributions.po_distribution_id%TYPE := NULL;
l_invoice_distribution_id	ap_invoice_distributions.invoice_distribution_id%TYPE;
l_item_line_number		ap_invoice_lines_all.line_number%TYPE;
l_line_amt_net_retainage        ap_invoice_lines_all.amount%TYPE;
l_max_amount_to_recoup		ap_invoice_lines_all.amount%TYPE;
l_amount_to_recoup	 	ap_invoice_lines_all.amount%TYPE;
l_retained_amount		ap_invoice_lines_all.retained_amount%TYPE;
l_error_message			varchar2(4000);
l_debug_info			varchar2(2000);
l_success			boolean;
current_calling_sequence	varchar2(2000);
l_api_name                      CONSTANT VARCHAR2(200) := 'Base_Credit_PO_Match';

--bugfix:5565310
l_ref_doc_application_id      zx_transaction_lines_gt.ref_doc_application_id%TYPE;
l_ref_doc_entity_code         zx_transaction_lines_gt.ref_doc_entity_code%TYPE;
l_ref_doc_event_class_code    zx_transaction_lines_gt.ref_doc_event_class_code%TYPE;
l_ref_doc_line_quantity       zx_transaction_lines_gt.ref_doc_line_quantity%TYPE;
l_po_header_curr_conv_rat     po_headers_all.rate%TYPE;
l_ref_doc_trx_level_type      zx_transaction_lines_gt.ref_doc_trx_level_type%TYPE;
l_po_header_curr_conv_rate    po_headers_all.rate%TYPE;
l_uom_code                    mtl_units_of_measure.uom_code%TYPE;
l_ref_doc_trx_id	      po_headers_all.po_header_id%TYPE;
l_error_code		      varchar2(2000);
l_po_line_location_id         po_line_locations.line_location_id%TYPE;
l_dummy			      number;
-- bug 7577673: start
l_product_org_id              ap_invoices.org_id%TYPE;
l_allow_tax_code_override     varchar2(10);
l_dflt_tax_class_code         zx_transaction_lines_gt.input_tax_classification_code%type;
-- bug 7577673: end
BEGIN
   -- Update the calling sequence (for error message).
   current_calling_sequence := 'AP_MATCHING_PKG.base_credit_po_match<-'||X_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
      				'AP_MATCHING_PKG.base_credit_po_match(+)');
   END IF;

   l_debug_info := 'Get Invoice and System Options information';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   get_info(X_Invoice_Id 	  => x_invoice_id,
   	    X_Invoice_Line_Number => x_invoice_line_number,
	    X_Match_Amount	  => x_amount,
	    X_Po_Line_Location_id => x_po_line_location_id,
            X_Calling_Sequence    => current_calling_sequence);

   IF g_invoice_type_lookup_code <> 'PREPAYMENT' THEN
      l_retained_amount := AP_INVOICE_LINES_UTILITY_PKG.Get_Retained_Amount
                                        (p_line_location_id => x_po_line_location_id,
                                         p_match_amount     => x_amount);
   END IF;

   --If shipment level match then we need to prorate the match-quantity among the
   --po distributions of the shipment, for distribution level match we need to
   --derive the invoice_distribution_id, base_amount, ccid.

   l_debug_info := 'Get PO information';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   --bugfix:5565310
   l_po_line_location_id := x_po_line_location_id;

   l_success := AP_ETAX_UTILITY_PKG.Get_PO_Info(
                 P_Po_Line_Location_Id         => l_po_line_location_id,
                 P_PO_Distribution_Id          => null,
                 P_Application_Id              => l_ref_doc_application_id,
                 P_Entity_code                 => l_ref_doc_entity_code,
                 P_Event_Class_Code            => l_ref_doc_event_class_code,
                 P_PO_Quantity                 => l_ref_doc_line_quantity,
                 P_Product_Org_Id              => l_product_org_id, -- bug 7577673
                 P_Po_Header_Id                => l_ref_doc_trx_id,
                 P_Po_Header_curr_conv_rate    => l_po_header_curr_conv_rate,
                 P_Uom_Code                    => l_uom_code,
		 P_Dist_Qty		       => l_dummy,
		 P_Ship_Price		       => l_dummy,
                 P_Error_Code                  => l_error_code,
                 P_Calling_Sequence            => current_calling_sequence);


   l_debug_info := 'Get PO Tax Attributes';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

-- bug 7577673: start
   ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification
           (p_ref_doc_application_id           => l_ref_doc_application_id,
            p_ref_doc_entity_code              => l_ref_doc_entity_code,
            p_ref_doc_event_class_code         => l_ref_doc_event_class_code,
            p_ref_doc_trx_id                   => l_ref_doc_trx_id,
            p_ref_doc_line_id                  => x_po_line_location_id,
            p_ref_doc_trx_level_type           => 'SHIPMENT',
            p_vendor_id                        => g_vendor_id,
            p_vendor_site_id                   => g_vendor_site_id,
            p_code_combination_id              => g_default_dist_ccid,
            p_concatenated_segments            => null,
            p_templ_tax_classification_cd      => null,
            p_ship_to_location_id              => null,
            p_ship_to_loc_org_id               => null,
            p_inventory_item_id                => null,
            p_item_org_id                      => l_product_org_id,
            p_tax_classification_code          => g_dflt_tax_class_code,
            p_allow_tax_code_override_flag     => l_allow_tax_code_override,
            APPL_SHORT_NAME                    => 'SQLAP',
            FUNC_SHORT_NAME                    => 'NONE',
            p_calling_sequence                 => 'AP_ETAX_SERVICES_PKG',
            p_event_class_code                 => l_ref_doc_event_class_code,
            p_entity_code                      => 'AP_INVOICES',
            p_application_id                   => 200,
            p_internal_organization_id         => g_org_id);
-- bug 7577673: end

   AP_Etax_Services_Pkg.Get_Po_Tax_Attributes(
   			    p_application_id              => l_ref_doc_application_id,
			    p_org_id                      => g_org_id,
			    p_entity_code                 => l_ref_doc_entity_code,
			    p_event_class_code            => l_ref_doc_event_class_code,
			    p_trx_level_type              => 'SHIPMENT',
			    p_trx_id                      => l_ref_doc_trx_id,
			    p_trx_line_id                 => x_po_line_location_id,
			    x_line_intended_use           => g_intended_use,
			    x_product_type                => g_product_type,
			    x_product_category            => g_product_category,
			    x_product_fisc_classification => g_product_fisc_class,
			    x_user_defined_fisc_class     => g_user_defined_fisc_class,
			    x_assessable_value            => g_assessable_value,
			    x_tax_classification_code     => l_dflt_tax_class_code
			    );

-- bug 7577673: start
   -- if tax classification code not retrieved from hierarchy
   -- retrieve it from PO
   IF (g_dflt_tax_class_code is null) THEN
       g_dflt_tax_class_code := l_dflt_tax_class_code;
   END IF;
-- bug 7577673: end

   l_debug_info := 'g_intended_use,g_product_type,g_product_category,g_product_fisc_class '||
                    g_intended_use||','||g_product_type||','||g_product_category||','||g_product_fisc_class;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   l_debug_info := 'g_user_defined_fisc_class,g_assessable_value,g_dflt_tax_class_code '||
                    g_user_defined_fisc_class||','||g_assessable_value||','||g_dflt_tax_class_code;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   IF g_source = 'ISP'
      and x_invoice_line_number IS NOT NULL THEN

      UPDATE ap_invoice_lines_all
         SET  primary_intended_use        = nvl(primary_intended_use, g_intended_use)
             ,product_type                = nvl(product_type, g_product_type)
             ,product_category            = nvl(product_category, g_product_category)
             ,product_fisc_classification = nvl(product_fisc_classification, g_product_fisc_class)
             ,user_defined_fisc_class     = nvl(user_defined_fisc_class, g_user_defined_fisc_class)
             ,assessable_value            = nvl(assessable_value, g_assessable_value)
             ,tax_classification_code     = nvl(tax_classification_code, g_dflt_tax_class_code)
       WHERE invoice_id  = x_invoice_id
         AND line_number = x_invoice_line_number;

   END IF;

   l_debug_info := 'Get Distribution Proration Info';


   Get_Dist_Proration_Info( X_Invoice_Id	  => x_invoice_id,
			    X_Invoice_Line_Number => x_invoice_line_number,
			    X_Po_Line_Location_Id => x_po_line_location_id,
     			    X_Match_Mode	  => x_match_mode,
    			    X_Match_Quantity	  => x_quantity,
    			    X_Match_Amount	  => x_amount,
			    X_Unit_Price	  => x_unit_price,
    			    X_Overbill_Flag	  => x_overbill_flag,
			    X_Dist_Tab 	          => x_dist_tab,
    			    X_Calling_Sequence    => current_calling_sequence);


   IF (x_dist_tab.COUNT = 1) THEN

      l_single_dist_flag := 'Y';
      l_po_distribution_id := x_dist_tab.FIRST;
      l_invoice_distribution_id := x_dist_tab(l_po_distribution_id).invoice_distribution_id;

   END IF;

   --Create a invoice line if one doesn't exist already.
   IF (x_invoice_line_number IS NULL) THEN

        l_debug_info := 'Create Matched Invoice Line';

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
  	Insert_Invoice_Line(X_Invoice_ID                => x_invoice_id,
  			    X_Invoice_Line_Number       => g_max_invoice_line_number + 1,
  			    X_Line_Type_Lookup_Code     => 'ITEM',
  			    X_Single_Dist_Flag		=> l_single_dist_flag,
  			    X_Po_Distribution_Id	=> l_po_distribution_id,
      			    X_Po_Line_Location_id	=> x_po_line_location_id,
  			    X_Amount			=> x_amount,
  			    X_Quantity_Invoiced	        => x_quantity,
  			    X_Unit_Price		=> x_unit_price,
  			    X_Final_Match_Flag		=> x_final_match_flag,
  			    X_Item_Line_Number		=> NULL,
  			    X_Charge_Line_Description	=> NULL,
			    X_Retained_Amount		=> l_retained_amount,
  			    X_Calling_Sequence		=> current_calling_sequence);
        l_item_line_number := g_max_invoice_line_number;

  END IF;

  l_debug_info := 'Create Matched Invoice Distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  Insert_Invoice_Distributions(	X_Invoice_ID		=> x_invoice_id,
  				X_Invoice_Line_Number	=> nvl(x_invoice_line_number,
							       g_max_invoice_line_number),
				X_Dist_Tab		=> x_dist_tab,
  				X_Final_Match_Flag	=> x_final_match_flag,
				X_Unit_Price		=> x_unit_price,
				X_Total_Amount		=> x_amount,
  				X_Calling_Sequence	=> current_calling_sequence);


  IF (x_invoice_line_number IS NOT NULL) THEN

    IF (l_single_dist_flag = 'Y') THEN

        l_debug_info := 'If the line is matched down to 1 po distribution then need to
        		 update the line with po_distribution_id, award_id,requester_id,
        		 ,projects related information and  generate_dists';
       	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        UPDATE ap_invoice_lines ail
        SET (generate_dists ,
            requester_id ,
            po_distribution_id ,
            project_id ,
            task_id ,
            expenditure_type ,
            expenditure_item_date ,
            expenditure_organization_id ,
            pa_quantity ,
            award_id,
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
            retained_amount,
            retained_amount_remaining
	    ) =
	    (SELECT 'D',
		    pd.deliver_to_person_id,
		    aid.po_distribution_id,
		    aid.project_id,
		    aid.task_id,
		    aid.expenditure_type,
		    aid.expenditure_item_date,
		    aid.expenditure_organization_id,
		    aid.pa_quantity,
		    gms_ap_api.get_distribution_award(aid.award_id),
                    /* Bug 7483260.  If the attribute field is populated in the
                     * interface, take that value. If the attribute field from
                     * the interface is null and the transfer_desc_flex_flag is
                     * Y, take the value from the purchase order.
                     */
                    nvl(ail.attribute_category, decode(g_transfer_flag, 'Y', pll.attribute_category, ail.attribute_category)),
                    nvl(ail.attribute1, decode(g_transfer_flag, 'Y', pll.attribute1, ail.attribute1)),
                    nvl(ail.attribute2, decode(g_transfer_flag, 'Y', pll.attribute2, ail.attribute2)),
                    nvl(ail.attribute3, decode(g_transfer_flag, 'Y', pll.attribute3, ail.attribute3)),
                    nvl(ail.attribute4, decode(g_transfer_flag, 'Y', pll.attribute4, ail.attribute4)),
                    nvl(ail.attribute5, decode(g_transfer_flag, 'Y', pll.attribute5, ail.attribute5)),
                    nvl(ail.attribute6, decode(g_transfer_flag, 'Y', pll.attribute6, ail.attribute6)),
                    nvl(ail.attribute7, decode(g_transfer_flag, 'Y', pll.attribute7, ail.attribute7)),
                    nvl(ail.attribute8, decode(g_transfer_flag, 'Y', pll.attribute8, ail.attribute8)),
                    nvl(ail.attribute9, decode(g_transfer_flag, 'Y', pll.attribute9, ail.attribute9)),
                    nvl(ail.attribute10, decode(g_transfer_flag, 'Y', pll.attribute10, ail.attribute10)),
                    nvl(ail.attribute11, decode(g_transfer_flag, 'Y', pll.attribute11, ail.attribute11)),
                    nvl(ail.attribute12, decode(g_transfer_flag, 'Y', pll.attribute12, ail.attribute12)),
                    nvl(ail.attribute13, decode(g_transfer_flag, 'Y', pll.attribute13, ail.attribute13)),
                    nvl(ail.attribute14, decode(g_transfer_flag, 'Y', pll.attribute14, ail.attribute14)),
                    nvl(ail.attribute15, decode(g_transfer_flag, 'Y', pll.attribute15, ail.attribute15)),
                    --end Bug 7483260
                    l_retained_amount,
                    -1 * l_retained_amount
              FROM ap_invoice_distributions aid,
		   po_distributions pd,
		   po_line_locations pll
	      WHERE aid.invoice_distribution_id = l_invoice_distribution_id
	      AND pd.po_distribution_id = aid.po_distribution_id
	      AND pll.line_location_id = pd.line_location_id)
	WHERE ail.invoice_id = x_invoice_id
	AND   ail.line_number = x_invoice_line_number;


    ELSE

        l_debug_info := 'Update the generate_dists to D after the distributions are created';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        UPDATE ap_invoice_lines ail
        SET (generate_dists ,
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
            retained_amount,
            retained_amount_remaining)
	    =
	  (SELECT 'D',
                /* Bug 7483260.  If the attribute field is populated in the
                 * interface, take that value. If the attribute field from
                 * the interface is null and the transfer_desc_flex_flag is
                 * Y, take the value from the purchase order.
                 */
                nvl(ail.attribute_category, decode(g_transfer_flag, 'Y', pll.attribute_category, ail.attribute_category)),
                nvl(ail.attribute1, decode(g_transfer_flag, 'Y', pll.attribute1, ail.attribute1)),
                nvl(ail.attribute2, decode(g_transfer_flag, 'Y', pll.attribute2, ail.attribute2)),
                nvl(ail.attribute3, decode(g_transfer_flag, 'Y', pll.attribute3, ail.attribute3)),
                nvl(ail.attribute4, decode(g_transfer_flag, 'Y', pll.attribute4, ail.attribute4)),
                nvl(ail.attribute5, decode(g_transfer_flag, 'Y', pll.attribute5, ail.attribute5)),
                nvl(ail.attribute6, decode(g_transfer_flag, 'Y', pll.attribute6, ail.attribute6)),
                nvl(ail.attribute7, decode(g_transfer_flag, 'Y', pll.attribute7, ail.attribute7)),
                nvl(ail.attribute8, decode(g_transfer_flag, 'Y', pll.attribute8, ail.attribute8)),
                nvl(ail.attribute9, decode(g_transfer_flag, 'Y', pll.attribute9, ail.attribute9)),
                nvl(ail.attribute10, decode(g_transfer_flag, 'Y', pll.attribute10, ail.attribute10)),
                nvl(ail.attribute11, decode(g_transfer_flag, 'Y', pll.attribute11, ail.attribute11)),
                nvl(ail.attribute12, decode(g_transfer_flag, 'Y', pll.attribute12, ail.attribute12)),
                nvl(ail.attribute13, decode(g_transfer_flag, 'Y', pll.attribute13, ail.attribute13)),
                nvl(ail.attribute14, decode(g_transfer_flag, 'Y', pll.attribute14, ail.attribute14)),
                nvl(ail.attribute15, decode(g_transfer_flag, 'Y', pll.attribute15, ail.attribute15)),
                --end Bug 7483260
                l_retained_amount,
                -1 * l_retained_amount
           FROM ap_invoice_lines ail1,
		po_line_locations pll
           WHERE ail1.invoice_id = x_invoice_id
	   AND ail1.line_number =x_invoice_line_number
	   AND pll.line_location_id = ail1.po_line_location_id)
        WHERE invoice_id = x_invoice_id
        AND line_number = x_invoice_line_number;

    END IF;

  END IF;

  l_debug_info := 'Create Retainage Distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  Ap_Retainage_Pkg.Create_Retainage_Distributions
			(x_invoice_id          => x_invoice_id,
                         x_invoice_line_number => nvl(x_invoice_line_number,l_item_line_number));

  IF (G_Recoupment_Rate IS NOT NULL and x_amount > 0
  		and g_invoice_type_lookup_code <> 'PREPAYMENT') THEN

     l_debug_info := 'Calculate the maximum amount that can be recouped from this invoice line';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     l_line_amt_net_retainage := x_amount + nvl(l_retained_amount,0);

     l_max_amount_to_recoup := ap_utilities_pkg.ap_round_currency(
     				(x_amount * g_recoupment_rate / 100) ,g_invoice_currency_code);

     IF (l_line_amt_net_retainage < l_max_amount_to_recoup) THEN
        l_amount_to_recoup := l_line_amt_net_retainage;
     ELSE
        l_amount_to_recoup := l_max_amount_to_recoup;
     END IF;

     l_debug_info := 'Automatically recoup any available prepayments against the same po line';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     l_success := AP_Matching_Utils_Pkg.Ap_Recoup_Invoice_Line(
  				P_Invoice_Id           => x_invoice_id ,
			        P_Invoice_Line_Number  => nvl(x_invoice_line_number,l_item_line_number) ,
			        P_Amount_To_Recoup     => l_amount_to_recoup,
			        P_Po_Line_Id           => g_po_line_id,
			        P_Vendor_Id            => g_vendor_id,
			        P_Vendor_Site_Id       => g_vendor_site_id,
			        P_Accounting_Date      => g_accounting_date,
			        P_Period_Name          => g_period_name,
			        P_User_Id              => g_user_id,
			        P_Last_Update_Login    => g_login_id ,
			        P_Error_Message        => l_error_message,
			        P_Calling_Sequence     => current_calling_sequence);

  END IF;

  l_debug_info := 'Update Quantity/Amount Billed/Financed on the Po Shipments and Distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  Update_PO_Shipments_Dists(X_Dist_Tab	    => x_dist_tab,
			    X_Po_Line_Location_Id => x_po_line_location_id,
  			    X_Match_Amount	=> x_amount,
	    		    X_Match_Quantity	=> x_quantity,
  			    X_Uom_Lookup_Code => x_uom_lookup_code,
  			    X_Calling_Sequence => current_calling_sequence);


  IF (x_freight_amount IS NOT NULL or x_misc_amount IS NOT NULL) THEN

     l_debug_info := 'Call the procedure to create charge lines';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     --Due to the way PL/SQL binding is done for global variables, need
     --pass the local instead of global variable for this as global variable
     --is being updated before the x_item_line_number is used during runtime.

     Create_Charge_Lines(X_Invoice_Id 	 	=> x_invoice_id,
     			 X_Freight_Cost_Factor_id  => x_freight_cost_factor_id,
    			 X_Freight_Amount   	=> x_freight_amount,
    			 X_Freight_Description 	=> x_freight_description,
			 X_Misc_Cost_Factor_id  => x_misc_cost_factor_id,
    			 X_Misc_Amount		=> x_misc_amount,
    			 X_Misc_Description	=> x_misc_description,
    			 X_Item_Line_Number	=> l_item_line_number,
    			 X_Calling_Sequence	=> current_calling_sequence);

  END IF;

  --Clean up the PL/SQL table
  X_DIST_TAB.DELETE;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.base_credit_po_match(-)');
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Match Mode = '||x_match_mode
     			  ||', Invoice Id = '||to_char(x_invoice_id)
     			  ||', Invoice Line Number = '||to_char(x_invoice_line_number)
     			  ||', Shipment ID = '||to_char(x_po_line_location_id)
 			  ||', Match amount = '||to_char(x_amount)
 			  ||', Match quantity = '||to_char(x_quantity)
 			  ||', PO UOM = '||x_uom_lookup_code
 			  ||', Final Match Flag = '||X_final_match_flag
 			  ||', Overbill Flag = '||x_overbill_flag
 			  ||', Freight Amount = '||to_char(x_freight_amount)
 			  ||', Freight Description = '||x_freight_description
 			  ||', Misc Amount = '||to_char(x_misc_amount)
 			  ||', Misc Description = '||x_misc_description);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;

   --Clean up the PL/SQL table
   X_DIST_TAB.DELETE;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Base_Credit_PO_Match;



PROCEDURE Get_Info(X_Invoice_ID  	 IN  NUMBER,
		   X_Invoice_Line_Number IN  NUMBER DEFAULT NULL,
		   X_Match_Amount	 IN  NUMBER DEFAULT NULL,
		   X_Po_Line_Location_Id IN  NUMBER DEFAULT NULL,
		   X_Calling_Sequence	 IN  VARCHAR2
		   ) IS

 current_calling_sequence 	VARCHAR2(2000);
 l_debug_info		VARCHAR2(2000);
 l_api_name VARCHAR2(30);
 l_accounting_date ap_invoice_lines.accounting_date%TYPE;  --7463095

BEGIN

   l_api_name := 'Get_Info';

   current_calling_sequence := 'Get_Info<-'||X_Calling_Sequence;
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Info(+)');
   END IF;

   SELECT ai.gl_date,
	  ai.batch_id,
          ai.set_of_books_id,
          ai.awt_group_id,
          ai.invoice_type_lookup_code,
          ai.exchange_rate,
	  fc.precision,
	  fc.minimum_accountable_unit,
	  nvl(asp.allow_awt_flag,'N'),
          nvl(pvs.allow_awt_flag,'N'),
          nvl(asp.transfer_desc_flex_flag,'N'),
          asp.base_currency_code,
          ai.invoice_currency_code,
          nvl(pvs.prepay_code_combination_id,
              asp.prepay_code_combination_id),
          nvl(asp.build_prepayment_accounts_flag,'N'),
          decode(pv.type_1099,'','',
          	 decode(combined_filing_flag,'N',NULL,
          	 	decode(asp.income_tax_region_flag,'Y',pvs.state,
          	 	       asp.income_tax_region))),
          ai.project_id,
          ai.task_id,
	  ai.award_id,
          ai.expenditure_type,
          ai.invoice_date,
          ai.expenditure_organization_id,
          fsp.inventory_organization_id,
	  nvl(asp.approval_workflow_flag,'N'),
       -- ai.ussgl_transaction_code,- Bug 4277744
	  asp.allow_flex_override_flag,
	  ai.org_id,
	  nvl(fsp.purch_encumbrance_flag,'N'),
	  ai.award_id,
	  ai.trx_business_category,
	  ai.vendor_id,
	  ai.vendor_site_id,
	  ai.release_amount_net_of_tax,
	  ai.source,
	  ai.recurring_payment_id,  -- Bug 7305223
	  ai.pay_awt_group_id   --bug 8222382
   INTO g_accounting_date,
	g_batch_id,
        g_set_of_books_id,
        g_awt_group_id,
        g_invoice_type_lookup_code,
        g_exchange_rate,
        g_precision,
	g_min_acct_unit,
	g_system_allow_awt_flag,
        g_site_allow_awt_flag,
        g_transfer_flag,
        g_base_currency_code,
        g_invoice_currency_code,
        g_prepay_ccid,
        g_build_prepay_accts_flag,
        g_income_tax_region,
        g_project_id,
        g_task_id,
	g_award_id,
        g_expenditure_type,
        g_invoice_date,
        g_expenditure_organization_id,
        g_inventory_organization_id,
	g_approval_workflow_flag,
     --	g_ussgl_transaction_code,- Bug 4277744
	g_allow_flex_override_flag,
	g_org_id,
	g_encumbrance_flag,
	g_award_id,
	g_trx_business_category,
	g_vendor_id,
	g_vendor_site_id,
	g_release_amount_net_of_tax,
	g_source,
	g_recurring_payment_id,   -- Bug 7305223
   /* Bug 5572876, using base tables */
    g_pay_awt_group_id  -- bug 8222382
   FROM ap_invoices_all ai ,
   	ap_system_parameters_all asp,
   	ap_suppliers pv,
   	ap_supplier_sites_all pvs,
   	financials_system_params_all fsp,
	fnd_currencies fc
   WHERE ai.invoice_id = x_invoice_id
   AND   ai.vendor_site_id = pvs.vendor_site_id
   AND   pv.vendor_id = pvs.vendor_id
   AND   ai.org_id = asp.org_id
   AND   asp.org_id = fsp.org_id
   AND   ai.set_of_books_id = asp.set_of_books_id
   AND   asp.set_of_books_id = fsp.set_of_books_id
   AND   ai.invoice_currency_code = fc.currency_code (+);


   IF (x_match_amount IS NOT NULL AND g_invoice_currency_code <> g_base_currency_code) THEN
      g_line_base_amount := ap_utilities_pkg.ap_round_currency(
                                   x_match_amount * g_exchange_rate,
				   g_base_currency_code);
   END IF;


   IF (x_invoice_line_number IS NOT NULL) THEN

   	SELECT
	       ail.account_segment,
	       ail.balancing_segment,
	       ail.cost_center_segment,
	       ail.overlay_dist_code_concat,
	       ail.default_dist_ccid,
	       ail.project_id,
	       ail.task_id,
	       ail.award_id,
	       ail.expenditure_type,
	       ail.expenditure_item_date,
	       ail.expenditure_organization_id,
	       ail.awt_group_id,
	       ail.accounting_date,
		   ail.pay_awt_group_id
   	INTO
	     g_account_segment,
	     g_balancing_segment,
	     g_cost_center_segment,
	     g_overlay_dist_code_concat,
	     g_default_dist_ccid,
	     g_line_project_id,
	     g_line_task_id,
	     g_line_award_id,
	     g_line_expenditure_type,
	     g_line_expenditure_item_date,
	     g_line_expenditure_org_id,
	     g_line_awt_group_id,
	     g_line_accounting_date,
		 g_line_pay_awt_group_id
   	FROM ap_invoice_lines ail
   	WHERE ail.invoice_id = x_invoice_id
	AND ail.line_number = x_invoice_line_number;

   END IF;

   SELECT nvl(max(ail.line_number),0)
   INTO g_max_invoice_line_number
   FROM ap_invoice_lines ail
   WHERE ail.invoice_id = x_invoice_id;

   /* Bug 5572876 */
   g_asset_book_type_code := Ap_Utilities_Pkg.Ledger_Asset_Book
                               (g_set_of_books_id);

   /*
   BEGIN
   	SELECT book_type_code
	INTO g_asset_book_type_code
	FROM fa_book_controls fc
	WHERE fc.book_class = 'CORP0RATE'
	AND fc.set_of_books_id = g_set_of_books_id
	AND fc.date_ineffective  IS NULL;
    EXCEPTION
    WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
      g_asset_book_type_code := NULL;
   END; */

   IF (x_po_line_location_id IS NOT NULL) THEN

      SELECT pll.shipment_type, pll.po_line_id, pl.recoupment_rate
      INTO g_shipment_type, g_po_line_id, g_recoupment_rate
      FROM po_line_locations pll, po_lines pl
      WHERE pll.line_location_id = x_po_line_location_id
      AND pll.po_line_id = pl.po_line_id;

   END  IF;

   l_debug_info := 'select period for accounting date';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   --get_current_gl_date will return NULL if the date passed to it doesn't fall in a
   --open period.
   --  Bug 4460697. Passed the g_org_id as some cases
   --  mo_global.get_current_org_id does not work
   g_period_name := AP_UTILITIES_PKG.get_current_gl_date(g_accounting_date,
                                                         g_org_id);

   IF (g_period_name IS NULL) THEN

      --Get gl_period and Date from a future period for the accounting date
      -- Bug 4460697. Passed the g_org_id as some cases
      -- mo_global.get_current_org_id does not work

       -- 7463095 Used l_accounting_date instead of g_accounting_date. Using
      --same variable for in/out parmeters causing to make in parameters
      -- as Null
      ap_utilities_pkg.get_open_gl_date(p_date        => g_accounting_date,
  				        p_period_name => g_period_name,
  				        p_gl_date     => l_accounting_date,
                                        p_org_id      => g_org_id);

         g_accounting_date :=   l_accounting_date;   --7463095

    --Bug 7305223 While generating recurring invoices no need of checking
    --gl date is open/closed. Always allowing recurring invoices to generate
    --any period.

    IF g_recurring_payment_id   is null THEN --Bug 7305223
      IF (g_accounting_date IS NULL) THEN
          fnd_message.set_name('SQLAP','AP_DISTS_NO_OPEN_FUT_PERIOD');
          app_exception.raise_exception;
      ELSE
          g_line_accounting_date := g_accounting_date;
      END IF;
     END IF;

   END IF;

   --Bug 6956226. Modified below statement to assign 'Yes' if this profile
   --has defined no value.
   g_allow_pa_override := NVL(FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES'),'Y');

   -- Bug 5294998. API from PA will be used
   -- g_pa_expenditure_date_default := FND_PROFILE.VALUE('PA_AP_EI_DATE_DEFAULT');

   g_user_id := FND_PROFILE.VALUE('USER_ID');

   g_login_id := FND_PROFILE.VALUE('LOGIN_ID');

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Info(-)');
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


Procedure Get_Dist_Proration_Info(
		  X_Invoice_Id		 IN NUMBER,
		  X_Invoice_Line_Number  IN NUMBER,
		  X_Po_Line_Location_Id  IN NUMBER,
		  X_Match_Mode		 IN VARCHAR2,
		  X_Match_Quantity	 IN NUMBER,
		  X_Match_Amount	 IN NUMBER,
		  X_Unit_Price		 IN NUMBER,
		  X_Overbill_Flag	 IN VARCHAR2,
		  X_Dist_Tab		 IN OUT NOCOPY DIST_TAB_TYPE,
		  X_Calling_Sequence	 IN VARCHAR2) IS


  CURSOR po_distributions_cursor(p_total_quantity NUMBER) IS
     SELECT po_distribution_id,
	    /*PRORATED AMOUNT*/
     	    DECODE(g_min_acct_unit,
                   '', ROUND( X_match_amount * DECODE(X_match_mode,
                                                      'STD-PS',DECODE(X_overbill_flag,
                                                                      'Y', NVL(PD.quantity_ordered, 0),
                                                                       NVL(DECODE(SIGN(PD.quantity_ordered -
                                             			                       DECODE(PD.distribution_type,'PREPAYMENT',
											      NVL(PD.quantity_financed,0),
										              NVL(PD.quantity_billed,0)
											      ) -
                                              				               NVL(PD.quantity_cancelled,0)),
                                               				          -1, 0,
                                                                                  PD.quantity_ordered -
                                                                                  DECODE(PD.distribution_type,'PREPAYMENT',
											 NVL(PD.quantity_financed,0),
											 NVL(PD.quantity_billed,0)
											 ) -
                                                                                  NVL(PD.quantity_cancelled,0)
                                                                                  )
                                          		                  ,0)
                                                                      ),
                                                       NVL(PD.quantity_billed, 0)
                                                     )
                            / p_total_quantity,
                           g_precision),
                 ROUND(((X_match_amount * DECODE(X_match_mode,
                                                 'STD-PS',DECODE(X_overbill_flag,
                                                                 'Y', NVL(PD.quantity_ordered, 0),
                                                                  NVL(DECODE(SIGN(PD.quantity_ordered -
                                              			                  DECODE(PD.distribution_type,'PREPAYMENT',
											 NVL(PD.quantity_financed,0),
										         NVL(PD.quantity_billed,0)
											)  -
                                              				          NVL(PD.quantity_cancelled,0)),
                                               				     -1, 0,
                                                                             PD.quantity_ordered -
                                                                             DECODE(PD.distribution_type,'PREPAYMENT',
										    NVL(PD.quantity_financed,0),
										    NVL(PD.quantity_billed,0)
										   )  -
                                                                             NVL(PD.quantity_cancelled,0)
 									    )
                                          		              ,0)
								 ),
                                                 NVL(PD.quantity_billed, 0)
						)
                           / p_total_quantity)
                     / g_min_acct_unit) * g_min_acct_unit)),
	     /*PRORATED QUANTITY*/
             ROUND( X_match_quantity * DECODE(X_match_mode,
                                              'STD-PS',DECODE(X_overbill_flag,
                                                              'Y', NVL(PD.quantity_ordered, 0),
                                                               NVL(DECODE(SIGN(PD.quantity_ordered -
                                             			                DECODE(PD.distribution_type,'PREPAYMENT',
										       NVL(PD.quantity_financed,0),
										       NVL(PD.quantity_billed,0)
										       )  -
                                              				        NVL(PD.quantity_cancelled,0)),
                                               				   -1, 0,
                                                                           PD.quantity_ordered -
                                                                           DECODE(PD.distribution_type,'PREPAYMENT',
										  NVL(PD.quantity_financed,0),
										  NVL(PD.quantity_billed,0)
										 )  -
                                                                           NVL(PD.quantity_cancelled,0))
                                           		           , 0)),
                                               DECODE(PD.distribution_type,'PREPAYMENT',
						      NVL(PD.quantity_financed,0),
						      NVL(PD.quantity_billed,0)
						     )
					     )
                     / p_total_quantity,15),
            PD.code_combination_id,
	    PD.accrue_on_receipt_flag,
	    DECODE(PD.destination_type_code,'EXPENSE',
	    	   PD.project_id,NULL), 		  --project_id
	    DECODE(PD.destination_type_code,'EXPENSE',
	           PD.task_id,NULL),			  --task_id
	    DECODE(PD.destination_type_code,'EXPENSE',
	    	   PD.expenditure_type,NULL),             --expenditure_type
	    DECODE(PD.destination_type_code,
	    	   'EXPENSE',PD.expenditure_item_date,
		   NULL), 				  --expenditure_item_date
	    DECODE(PD.destination_type_code,
	    	   'EXPENSE',PD.expenditure_organization_id,
		   NULL),				  --expenditure_organization_id
            DECODE(PD.destination_type_code,
                   'EXPENSE', PD.award_id),               --award_id
	    ap_invoice_distributions_s.nextval
  FROM po_distributions_ap_v PD
  WHERE line_location_id = x_po_line_location_id;


  l_total_quantity 	  number;
  l_po_distribution_id	  po_distributions_all.po_distribution_id%TYPE;
  l_amount_invoiced	  ap_invoice_distributions_all.amount%TYPE;
  l_quantity_invoiced	  ap_invoice_distributions_all.quantity_invoiced%TYPE;
  l_po_dist_ccid	  po_distributions.code_combination_id%TYPE;
  l_accrue_on_receipt_flag po_distributions.accrue_on_receipt_flag%TYPE;
  l_project_id		  po_distributions.project_id%TYPE;
  l_unbuilt_flex          varchar2(240):='';
  l_reason_unbuilt_flex   varchar2(2000):='';
  l_dist_ccid		  ap_invoice_distributions_all.dist_code_combination_id%TYPE;
  l_invoice_distribution_id ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_task_id		  po_distributions.task_id%TYPE;
  l_award_set_id	  po_distributions_all.award_id%TYPE;
  l_expenditure_type      po_distributions.expenditure_type%TYPE;
  l_po_expenditure_item_date po_distributions.expenditure_item_date%TYPE;
  l_expenditure_organization_id po_distributions.expenditure_organization_id%TYPE;
  l_max_dist_amount	  number := 0;
  l_sum_prorated_amount   number := 0;
  l_sum_dist_base_amount  number := 0;
  l_rounding_index	  po_distributions.po_distribution_id%TYPE;
  l_base_amount		  ap_invoice_distributions.base_amount%TYPE;
  flex_overlay_failed     exception;
  current_calling_sequence varchar2(2000);
  l_debug_info 		  varchar2(2000);
  l_api_name		  VARCHAR2(50);

BEGIN

 l_api_name := 'Get_Dist_Proration_Info';

 current_calling_sequence := 'Get_Dist_Proration_Info<-'||x_calling_sequence;
 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Dist_Proration_Info(+)');
 END IF;

 IF(X_Match_Mode IN ('STD-PS','CR-PS')) THEN

   l_debug_info := 'Get Total Quantity for Proration';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   Get_Total_Proration_Quantity
	                  ( X_PO_Line_Location_Id  => x_po_line_location_id,
	                    X_Match_Mode      => x_match_mode,
			    X_Overbill_Flag   => x_overbill_flag,
			    X_Total_Quantity  => l_total_quantity,
			    X_Calling_Sequence => current_calling_sequence);

   l_debug_info := 'g_min_acct_unit, x_match_amount, x_overbill_flag, x_match_mode, x_match_quantity, x_po_line_location_id'||
		    g_min_acct_unit||','||x_match_amount||','||x_overbill_flag||','||x_match_mode||','||x_match_quantity||','||x_po_line_location_id;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   OPEN PO_Distributions_Cursor(l_total_quantity);
   LOOP

      l_debug_info := 'Fetch record from Po_Distributions_Cursor l_total_quantity is '||l_total_quantity;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      FETCH PO_Distributions_Cursor INTO l_po_distribution_id,
     					 l_amount_invoiced,
     					 l_quantity_invoiced,
					 l_po_dist_ccid,
					 l_accrue_on_receipt_flag,
					 l_project_id,
					 l_task_id,
					 l_expenditure_type,
					 l_po_expenditure_item_date,
					 l_expenditure_organization_id,
					 l_award_set_id,
					 l_invoice_distribution_id;

      EXIT WHEN PO_Distributions_Cursor%NOTFOUND;

      --IF (l_amount_invoiced <> 0) THEN --Bug6321189

         l_debug_info := 'Populate the PL/SQL table x_dist_tab with the distribution information';
	 IF(G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	 END IF;



         x_dist_tab(l_po_distribution_id).po_distribution_id := l_po_distribution_id;
	 x_dist_tab(l_po_distribution_id).invoice_distribution_id := l_invoice_distribution_id;
         x_dist_tab(l_po_distribution_id).amount := l_amount_invoiced;
         x_dist_tab(l_po_distribution_id).quantity_invoiced := l_quantity_invoiced;
	 x_dist_tab(l_po_distribution_id).unit_price := x_unit_price;
	 x_dist_tab(l_po_distribution_id).po_ccid := l_po_dist_ccid;
	 x_dist_tab(l_po_distribution_id).accrue_on_receipt_flag := l_accrue_on_receipt_flag;
	 x_dist_tab(l_po_distribution_id).project_id := l_project_id;
         x_dist_tab(l_po_distribution_id).task_id := l_task_id;
         x_dist_tab(l_po_distribution_id).expenditure_type := l_expenditure_type;
         x_dist_tab(l_po_distribution_id).expenditure_organization_id := l_expenditure_organization_id;
	 x_dist_tab(l_po_distribution_id).expenditure_item_date := l_po_expenditure_item_date;
         --Bug 5554493
         x_dist_tab(l_po_distribution_id).pa_quantity := l_quantity_invoiced;

         If l_award_set_id Is Not Null Then
            x_dist_tab(l_po_distribution_id).award_id := gms_ap_api.get_distribution_award(l_award_set_id);
         End If;

	 --For proration rounding/base amount rounding,
	 --calculating max of the largest distribution's index
	 IF (ABS(l_amount_invoiced) >= ABS(l_max_dist_amount)) THEN  --bug 8796561, added ABS

	   l_rounding_index := l_po_distribution_id;
	   l_max_dist_amount := l_amount_invoiced;

	 END IF;

	 l_sum_prorated_amount := l_sum_prorated_amount + l_amount_invoiced;

     --END IF; /* (l_amount_invoiced <> 0) */

   END LOOP;

   CLOSE PO_Distributions_Cursor;

   --Update the PL/SQL table's amount column with the rounding amount due
   --to proration, before the base_amounts are calculated.

   IF (l_sum_prorated_amount <> x_match_amount and l_rounding_index is not null) THEN

      x_dist_tab(l_rounding_index).amount := x_dist_tab(l_rounding_index).amount +
      								(x_match_amount - l_sum_prorated_amount);

   END IF;

 ELSE

   FOR i IN nvl(x_dist_tab.FIRST,0)..nvl(x_dist_tab.LAST,0) LOOP

     IF (x_dist_tab.exists(i)) THEN

       SELECT accrue_on_receipt_flag,
	      code_combination_id,
	      project_id,
	      task_id,
	      award_id,
	      expenditure_type,
	      expenditure_item_date,
	      expenditure_organization_id,
	      ap_invoice_distributions_s.nextval
       INTO  x_dist_tab(i).accrue_on_receipt_flag,
	     x_dist_tab(i).po_ccid,
	     x_dist_tab(i).project_id,
	     x_dist_tab(i).task_id,
	     l_award_set_id,
	     x_dist_tab(i).expenditure_type,
	     x_dist_tab(i).expenditure_item_date,
	     x_dist_tab(i).expenditure_organization_id,
	     x_dist_tab(i).invoice_distribution_id
       FROM  po_distributions_ap_v
       WHERE po_distribution_id = x_dist_tab(i).po_distribution_id;

       -- Bug 5554493
       x_dist_tab(i).pa_quantity := x_dist_tab(i).quantity_invoiced;

       If l_award_set_id Is Not Null Then
          x_dist_tab(i).award_id := gms_ap_api.get_distribution_award(l_award_set_id);
       End If;

       --calculate the max of the largest distribution's index to be
       --used for base amount rounding. No need to perform proration
       --rounding for the case when the match is distributed by the user.

       --Need to do the base_amount rounding only for foreign currency
       --invoices only.

       IF (g_exchange_rate IS NOT NULL) THEN

          IF (x_dist_tab(i).amount >= l_max_dist_amount) THEN
             l_rounding_index := i;
	     l_max_dist_amount := x_dist_tab(i).amount;
          END IF;

       END IF;

     END IF;

   END LOOP;

 END IF;


 FOR i in nvl(x_dist_tab.first,0) .. nvl(x_dist_tab.last,0) LOOP

   IF (x_dist_tab.exists(i)) THEN

     l_debug_info := 'Populate Project related information';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     --If no project info in the PL/SQL by now,
     --then project info was null on po distribution
     --,then copy it from line for line level match, else copy it from invoice header.

     --Not doing NVL on the g_line_project_id, b'coz for the case of line level match
     --if the user has not provided any project information on the line regardless of
     --whether project info is present on header or not, we will not override what user
     --has explicitly provided.

/*
     IF (x_dist_tab(i).project_id IS NULL ) THEN

        IF (l_accrue_on_receipt_flag = 'N' and g_allow_pa_override = 'Y')THEN

           IF (x_invoice_line_number IS NOT NULL) THEN

               x_dist_tab(i).project_id := g_line_project_id;
               x_dist_tab(i).task_id := g_line_task_id;
               x_dist_tab(i).expenditure_type := g_line_expenditure_type;
               x_dist_tab(i).expenditure_organization_id := g_line_expenditure_org_id;

	   ELSE

	       x_dist_tab(i).project_id := g_project_id;
               x_dist_tab(i).task_id := g_task_id;
               x_dist_tab(i).expenditure_type := g_expenditure_type;
               x_dist_tab(i).expenditure_organization_id := g_expenditure_organization_id;

	   END IF;

        END IF;

     END IF;
*/
     IF (x_dist_tab(i).project_id IS NOT NULL) THEN
         --Bug 5554493
         --x_dist_tab(i).pa_quantity := l_quantity_invoiced;
         -- Bug 5294998. PA API will be used
         /*
         CASE g_pa_expenditure_date_default
         WHEN 'PO Expenditure Item Date/Transaction Date' THEN
            x_dist_tab(i).expenditure_item_date := nvl(x_dist_tab(i).expenditure_item_date,g_invoice_date);
         WHEN 'PO Expenditure Item Date/Transaction GL Date' THEN
            x_dist_tab(i).expenditure_item_date := nvl(x_dist_tab(i).expenditure_item_date,g_accounting_date);
         WHEN 'PO Expenditure Item Date/Transaction System Date' THEN
            x_dist_tab(i).expenditure_item_date := nvl(x_dist_tab(i).expenditure_item_date,sysdate);
         WHEN ('Receipt Date/Transaction Date' )  THEN
            x_dist_tab(i).expenditure_item_date := g_invoice_date;
         WHEN ('Receipt Date/Transaction GL Date') THEN
            x_dist_tab(i).expenditure_item_date := g_accounting_date;
         WHEN ('Receipt Date/Transaction System Date' ) THEN
            x_dist_tab(i).expenditure_item_date := sysdate;
         WHEN 'Transaction Date' THEN
            x_dist_tab(i).expenditure_item_date := g_invoice_date;
         WHEN 'Transaction GL Date' THEN
            x_dist_tab(i).expenditure_item_date := g_accounting_date;
         WHEN 'Transaction System Date' THEN
            x_dist_tab(i).expenditure_item_date := sysdate;
         ELSE
            x_dist_tab(i).expenditure_item_date := NULL;
         END CASE;
         */
         x_dist_tab(i).expenditure_item_date :=
           PA_AP_INTEGRATION.Get_Si_Cost_Exp_Item_Date (
             p_transaction_date   =>  g_invoice_date,
             p_gl_date            =>  g_accounting_date,
             p_creation_date      =>  sysdate,
             p_po_exp_item_date   =>  x_dist_tab(i).expenditure_item_date,
             p_po_distribution_id =>  x_dist_tab(i).po_distribution_id,
             p_calling_program    =>  'PO-MATCH');

     END IF;

     l_debug_info := 'Populate award information';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF (x_dist_tab(i).award_id IS NULL ) THEN
        IF (l_accrue_on_receipt_flag = 'N' and g_allow_pa_override = 'Y')THEN
           IF (x_invoice_line_number IS NOT NULL) THEN
               x_dist_tab(i).award_id := g_line_award_id;
           ELSE
               x_dist_tab(i).award_id := g_award_id;
           END IF;
        END IF;
     END IF; /*(x_dist_tab(i).award_id IS NULL) */

     l_debug_info := 'Populate awt information';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     IF (g_system_allow_awt_flag = 'Y' and g_site_allow_awt_flag = 'Y') THEN

        IF (x_invoice_line_number IS NOT NULL) THEN
           x_dist_tab(i).awt_group_id := g_line_awt_group_id;
		   x_dist_tab(i).pay_awt_group_id := g_line_pay_awt_group_id;
        ELSE
           x_dist_tab(i).awt_group_id := g_awt_group_id;
		   x_dist_tab(i).pay_awt_group_id := g_pay_awt_group_id;
        END IF;

     END IF;

     --Populate Base Amount
     --Need to populate the base amount for foreign currency invoices only.
     IF (g_exchange_rate IS NOT NULL) THEN
        l_base_amount := ap_utilities_pkg.ap_round_currency(
  				      x_dist_tab(i).amount * g_exchange_rate,
                                g_base_currency_code);
        x_dist_tab(i).base_amount := l_base_amount;

        l_sum_dist_base_amount := l_sum_dist_base_amount + l_base_amount;
     END IF;

     --Populate dist_code_combination_id information

        --Can overlay account if not accruing on receipt, and either not project_related
        --or if project related then project account override is allowed
        --and encumbrance is not turned on for all invoices types, except for
	--prepayment invoices and system option to allow
        --override of matching account is turned ON.

     IF (g_invoice_type_lookup_code <> 'PREPAYMENT') THEN

        --Can overlay account if not accruing on receipt, and either not project_related
        --or if project related then project account override is allowed
        --and encumbrance is not turned on and system option to allow
        --override of matching account is turned ON.

        IF (nvl(x_dist_tab(i).accrue_on_receipt_flag,'N') = 'N'
           AND ((x_dist_tab(i).project_id IS NOT NULL AND g_allow_pa_override = 'Y')
              OR x_dist_tab(i).project_id IS NULL)
           AND g_allow_flex_override_flag = 'Y'
           AND g_encumbrance_flag = 'N') THEN

           IF (g_account_segment IS NOT NULL OR
               g_balancing_segment IS NOT NULL OR
               g_cost_center_segment IS NOT NULL OR
               g_overlay_dist_code_concat IS NOT NULL) THEN

               l_dist_ccid := nvl(x_dist_tab(i).dist_ccid,x_dist_tab(i).po_ccid);

               IF (AP_UTILITIES_PKG.overlay_segments(
                                g_balancing_segment,
                                g_cost_center_segment,
                                g_account_segment,
                                g_overlay_dist_code_concat,
                                l_dist_ccid,
                                g_set_of_books_id ,
                                'CREATE_COMB_NO_AT', --Bug 5005198
                                l_unbuilt_flex ,
                                l_reason_unbuilt_flex ,
                                FND_GLOBAL.RESP_APPL_ID,
                                FND_GLOBAL.RESP_ID,
                                FND_GLOBAL.USER_ID,
                                current_calling_sequence ,
                                NULL) <> TRUE) THEN

                   l_debug_info := 'Overlaying Segments for this account was unsuccessful due to '||
                                  l_reason_unbuilt_flex;
                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                   END IF;

                   --Did not handle this exception explicitly as OTHERS handler
                   --should be sufficient for this case.

                   /*OPEN ISSUE 3 */
                   RAISE FLEX_OVERLAY_FAILED;

               ELSE

                  x_dist_tab(i).dist_ccid := l_dist_ccid;

               END IF;

           /*No Overlay info provided */
           ELSE

              --x_dist_tab.dist_ccid is already populated by the
              --calling module with the overriden account ccid, so
              --we need not do anything for the case of 'STD-PD' and 'CR-PD'.

              IF (x_match_mode IN ('STD-PS','CR-PS')) THEN
                  x_dist_tab(i).dist_ccid := nvl(g_default_dist_ccid,x_dist_tab(i).po_ccid);
              END IF;

           END IF; /*IF g_account_segment is not null... */

        ELSIF (nvl(x_dist_tab(i).accrue_on_receipt_flag,'N') = 'Y' OR
              g_allow_flex_override_flag = 'N' OR
              g_encumbrance_flag = 'Y' OR
              --bugfix:4668058 added the following clause
              (x_dist_tab(i).project_id IS NOT NULL AND g_allow_pa_override = 'N')
              ) THEN

            --po_distributions_ap_v.code_combination_id is accrual account
            --if accruing on receipt or else charge account

            x_dist_tab(i).dist_ccid := x_dist_tab(i).po_ccid;

        END IF;  /*IF (nvl(x_dist_tab(i).accrue_on_receipt_flag,'N') = 'N'...*/

     --For Prepayment type invoice build the prepayment account if
     --the system option build_prepayment_accounts_flag is set to Y.
     ELSE

        -- Contract Payments: If matching to an advance/financing pay item do not
        --                    use the prepay ccid, use the po charge account.

        IF g_shipment_type = 'PREPAYMENT' THEN

	   x_dist_tab(i).dist_ccid := x_dist_tab(i).po_ccid;

        ELSE

	   IF (g_build_prepay_accts_flag = 'Y') THEN

	       l_debug_info := 'Calling build_prepay_account to build the prepayment account';
               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
               END IF;
               -- Bug 5465722
               ap_matching_pkg.build_prepay_account(
	                        P_base_ccid => x_dist_tab(i).po_ccid,
	                        P_overlay_ccid => g_prepay_ccid,
	                        P_accounting_date => g_line_accounting_date,
	                        P_result_Ccid => l_dist_ccid,
	                        P_reason_unbuilt_flex => l_reason_unbuilt_flex,
	                        P_calling_sequence => current_calling_sequence);

	       IF (l_dist_ccid <> -1) THEN

		   x_dist_tab(i).dist_ccid := l_dist_ccid;

	       ELSE
                   /*OPEN ISSUE 3 */
                   l_debug_info := 'Flexbuild of prepayment account failed due to '
                                   ||l_reason_unbuilt_flex;
                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                   END IF;

                   RAISE FLEX_OVERLAY_FAILED;

               END IF;

           ELSE

               x_dist_tab(i).dist_ccid := g_prepay_ccid;

           END IF;
       END IF;
     END IF;   /*g_invoice_type_lookup_code <> 'PREPAYMENT'*/

  END IF; /* x_dist_tab.exists(i) */

END LOOP;


 --Base Amount Rounding
 --Need to perform base_amount rounding for only foreign currency invoices.
 IF (g_line_base_amount <> l_sum_dist_base_amount AND g_exchange_rate IS NOT NULL AND l_rounding_index is not null) THEN

    x_dist_tab(l_rounding_index).base_amount := x_dist_tab(l_rounding_index).base_amount +
						(g_line_base_amount - l_sum_dist_base_amount);

    x_dist_tab(l_rounding_index).rounding_amt := g_line_base_amount - l_sum_dist_base_amount;

 END IF;

 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Dist_Proration_Info(-)');
 END IF;



EXCEPTION

 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Shipment id '||to_char(x_po_line_location_id)
                          ||', Match_mode = '||X_match_mode
                          ||', Match Quantity = '||x_match_quantity
                          ||', Match Amount = '||x_match_amount
                          ||', Exchange Rate = '||g_exchange_rate
                          ||', Base Currency = '||g_base_currency_code
 			  ||', Overbill = '||X_overbill_flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Dist_Proration_Info;



/*---------------------------------------------------------------------------+
 |This procedure will retrieve total_quantity to be used for the purpose     |
 |of prorating amounts and quantities.					     |
 |                                                                           |
 |           The algorithm used is                                           |
 |                                                                           |
 |           IF (matching to std invoices) THEN                              |
 |               IF (this is an Overbill) THEN                               |
 |                   total_quantity = sum(qty_ordered)                       |
 |               ELSE (this is not an Overbill)                              |
 |                   total_quantity = sum(qty_ordered - (qty_billed +        |
 |                                                       qty_cancelled))     |
 |               END                                                         |
 |           ELSE                                                            |
 |               total_quantity = sum(qty_billed)                            |
 |           END                                                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
PROCEDURE Get_Total_Proration_Quantity
	                  ( X_PO_Line_Location_Id 	IN 	NUMBER,
	                    X_Match_Mode     		IN 	VARCHAR2,
			    X_Overbill_Flag  		IN 	VARCHAR2,
			    X_Total_Quantity 		OUT NOCOPY NUMBER,
			    X_Calling_Sequence	        IN	VARCHAR2) IS

l_debug_info 			VARCHAR2(2000);
current_calling_sequence	VARCHAR2(2000);
l_api_name			VARCHAR2(50);

BEGIN

   l_api_name := 'Get_Total_Proration_Quantity';
   current_calling_sequence := 'Get_Total_Proration_Quantity<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Total_Proration_Quantity(+)');
   END IF;

   l_debug_info := 'Get total quantity for proration';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;


   SELECT SUM(DECODE(X_Match_Mode,
		     'STD-PS',DECODE(X_overbill_flag,
	                             'Y', NVL(pd.quantity_ordered, 0),
		                     NVL(DECODE(SIGN(pd.quantity_ordered
			   	     	             - DECODE(PD.distribution_type,'PREPAYMENT',
							      NVL(PD.quantity_financed,0),
							      NVL(PD.quantity_billed,0)
							     )
 		                                     - NVL(pd.quantity_cancelled,0)
				                    ),
			                        -1, 0,
			                        quantity_ordered -
			   		        DECODE(PD.distribution_type,'PREPAYMENT',
						       NVL(PD.quantity_financed,0),
						       NVL(PD.quantity_billed,0)
						      )  -
			   		        NVL(pd.quantity_cancelled, 0)
					       )
	     	                        ,0)
			            ),
      	              DECODE(PD.distribution_type,'PREPAYMENT',
		             NVL(PD.quantity_financed,0),
		             NVL(PD.quantity_billed,0)
		    	    )
	            )
	     )
   INTO      X_Total_Quantity
   FROM      po_distributions_ap_v PD
   WHERE     line_location_id = X_Po_Line_Location_Id;

   IF(x_total_quantity = 0) THEN
     x_total_quantity := 1;
   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Total_Proration_Quantity(-)');
   END IF;


EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Match_mode = '||X_match_mode
			  ||', Shipment_id = '||TO_CHAR(X_PO_Line_Location_id)
 			  ||', Overbill = '||X_overbill_flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Total_Proration_Quantity;



Procedure Insert_Invoice_Line (X_Invoice_Id 	 	IN	NUMBER,
			       X_Invoice_Line_Number 	IN    	NUMBER,
			       X_Line_Type_Lookup_Code 	IN 	VARCHAR2,
			       X_Cost_Factor_id		IN	NUMBER DEFAULT NULL,
			       X_Single_Dist_Flag	IN	VARCHAR2 DEFAULT 'N',
			       X_Po_Distribution_Id	IN	NUMBER   DEFAULT NULL,
       			       X_Po_Line_Location_Id	IN	NUMBER   DEFAULT NULL,
			       X_Amount			IN	NUMBER,
			       X_Quantity_Invoiced	IN	NUMBER   DEFAULT NULL,
			       X_Unit_Price		IN	NUMBER   DEFAULT NULL,
			       X_Final_Match_Flag	IN	VARCHAR2 DEFAULT NULL,
  			       X_Item_Line_Number	IN	NUMBER,
			       X_Charge_Line_Description  IN 	VARCHAR2,
			       X_Retained_Amount	IN	NUMBER	 DEFAULT NULL,
			       X_Calling_Sequence	IN	VARCHAR2) IS

 current_calling_sequence	VARCHAR2(2000);
 l_debug_info			VARCHAR2(2000);
 l_api_name			VARCHAR2(50);

BEGIN

   l_api_name := 'Insert_Invoice_Line';
   current_calling_sequence := 'Insert_Invoice_Line<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Insert_Invoice_Line(+)');
   END IF;



   IF (X_LINE_TYPE_LOOKUP_CODE = 'ITEM') THEN

   	l_debug_info := 'Inserting Item Line Matched to a PO';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        -- bug 5061826
        -- go to base tables PO_LINES_ALL, PO_LINE_LOCATIONS and PO_DISTRIBUTIONS
        -- instead of PO_LINE_LOCATIONS_AP_V and PO_DISTRIBUTIONS_AP_V

	INSERT INTO AP_INVOICE_LINES (
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
	      RETAINED_AMOUNT,
	      RETAINED_AMOUNT_REMAINING,
       	      SHIP_TO_LOCATION_ID,
	      PRIMARY_INTENDED_USE,
	      PRODUCT_FISC_CLASSIFICATION,
	      TRX_BUSINESS_CATEGORY,
	      PRODUCT_TYPE,
	      PRODUCT_CATEGORY,
	      USER_DEFINED_FISC_CLASS,
	      ASSESSABLE_VALUE,
	      tax_classification_code,
		  pay_awt_group_id)       --bug8222382
       SELECT X_INVOICE_ID,			--invoice_id
     	      X_INVOICE_LINE_NUMBER,		--invoice_line_number
     	      X_LINE_TYPE_LOOKUP_CODE,		--line_type_lookup_code
     	      DECODE(X_SINGLE_DIST_FLAG,'Y',
     	      PD.DELIVER_TO_PERSON_ID,NULL),--requester_id
	       --bug 5061826,5601344 (added nvl)
    	      NVL(PLL.DESCRIPTION,PL.ITEM_DESCRIPTION),	--description
     	      'HEADER MATCH',			--line_source
    	      PLL.ORG_ID,			--org_id
    	      PL.ITEM_ID,			--inventory_item_id --bug 5061826-PLL to PL
     	      NVL(PLL.DESCRIPTION,PL.ITEM_DESCRIPTION),	--item_description
     	      NULL,				--serial_number
     	      NULL,				--manufacturer
     	      NULL,				--model_number
     	      'D',				--generate_dists
     	      'ITEM_TO_PO',			--match_type
     	      NULL,				--distribution_set_id
     	      NULL,				--account_segment
     	      NULL,				--balancing_segment
     	      NULL,				--cost_center_segment
     	      NULL,				--overlay_dist_code_concat
	      --Bug6965650
              NULL,                             --default_dist_ccid
     	      'N',				--prorate_across_all_items
 	      NULL,				--line_group_number
 	      G_ACCOUNTING_DATE,		--accounting_date
 	      G_PERIOD_NAME,			--period_name
 	      'N',				--deferred_acctg_flag
 	      NULL,				--def_acctg_start_date
 	      NULL,				--def_acctg_end_date
 	      NULL,				--def_acctg_number_of_periods
 	      NULL,				--def_acctg_period_type
 	      G_SET_OF_BOOKS_ID,		--set_of_books_id
 	      X_AMOUNT,				--amount
 	      AP_UTILITIES_PKG.Ap_Round_Currency(
                 NVL(X_AMOUNT, 0) * G_EXCHANGE_RATE,
               		 G_BASE_CURRENCY_CODE), --base_amount
 	      NULL,				--rounding_amount
 	      X_QUANTITY_INVOICED,		--quantity_invoiced
 	      PLL.UNIT_MEAS_LOOKUP_CODE,	--unit_meas_lookup_code
 	      X_UNIT_PRICE,			--unit_price
 	      decode(g_approval_workflow_flag,'Y'
	            ,'REQUIRED','NOT REQUIRED'),--wf_approval_status
           -- Removed for bug 4277744
 	   -- PLL.USSGL_TRANSACTION_CODE,	--ussgl_transaction_code
 	      'N',				--discarded_flag
 	      NULL,				--original_amount
 	      NULL,				--original_base_amount
 	      NULL,				--original_rounding_amt
 	      'N',				--cancelled_flag
 	      G_INCOME_TAX_REGION,		--income_tax_region
 	      PL.TYPE_1099,			--type_1099 -- bug 5061826-PLL to PL
 	      NULL,				--stat_amount
 	      NULL,				--prepay_invoice_id
 	      NULL,				--prepay_line_number
 	      NULL,				--invoice_includes_prepay_flag
 	      NULL,				--corrected_inv_id
 	      NULL,				--corrected_line_number
 	      PLL.PO_HEADER_ID,			--po_header_id
 	      PLL.PO_LINE_ID,			--po_line_id
 	      PLL.PO_RELEASE_ID,		--po_release_id
 	      PLL.LINE_LOCATION_ID,		--po_line_location_id
 	      DECODE(X_SINGLE_DIST_FLAG,'Y',
 	       	     X_PO_DISTRIBUTION_ID,NULL),--po_distribution_id
    	      NULL,				--rcv_transaction_id
   	      X_FINAL_MATCH_FLAG,		--final_match_flag
    	      'N',				--assets_tracking_flag
    	      G_ASSET_BOOK_TYPE_CODE,		--asset_book_type_code
    	      MSI.ASSET_CATEGORY_ID,		--asset_category_id
    	      DECODE(X_SINGLE_DIST_FLAG,'Y',
    	             DECODE(PD.destination_type_code,
		     	    'EXPENSE',PD.project_id,
			    G_PROJECT_ID),
	    	     NULL),			--project_id
   	      DECODE(X_SINGLE_DIST_FLAG,'Y',
    	             DECODE(PD.destination_type_code,
		     	    'EXPENSE',PD.task_id,
			    G_TASK_ID),
	    	     NULL),			--task_id
 	      DECODE(X_SINGLE_DIST_FLAG,'Y',
 	             DECODE(PD.destination_type_code,
		     	    'EXPENSE',PD.expenditure_type,
			    G_EXPENDITURE_TYPE),
 	             NULL),			--expenditure_type
	      DECODE(X_SINGLE_DIST_FLAG,'Y',
                -- Bug 5294998. Calling project API
                    PA_AP_INTEGRATION.Get_Si_Cost_Exp_Item_Date (
                      g_invoice_date,
                      g_accounting_date,
                      NULL,
                      sysdate,
                      x_po_distribution_id,
                      'PO-MATCH'),
                     NULL),                         --expenditure_item_date
 	    /*   DECODE(g_pa_expenditure_date_default,
      		    'PO Expenditure Item Date/Transaction Date',
      		     DECODE(PD.Destination_type_code,
		            'EXPENSE',PD.EXPENDITURE_ITEM_DATE,
			    G_INVOICE_DATE),
      		    'PO Expenditure Item Date/Transaction GL Date',
      		     DECODE(PD.destination_type_code,
		            'EXPENSE', PD.EXPENDITURE_ITEM_DATE,
			    G_ACCOUNTING_DATE),
     		     'PO Expenditure Item Date/Transaction System Date',
     		     DECODE(PD.destination_type_code,
		            'EXPENSE',PD.EXPENDITURE_ITEM_DATE,
			    SYSDATE),
     		     'Receipt Date/Transaction Date',G_INVOICE_DATE,
     		     'Receipt Date/Transaction GL Date',G_ACCOUNTING_DATE,
     		     'Receipt Date/Transaction System Date',SYSDATE,
     		     'Transaction Date',G_INVOICE_DATE,
     		     'Transaction GL Date',G_ACCOUNTING_DATE,
     		     'Transaction System Date', SYSDATE), /
		 NULL), */
 	       DECODE(X_SINGLE_DIST_FLAG,'Y',
 	              DECODE(PD.destination_type_code,
		      	     'EXPENSE',PD.expenditure_organization_id,
			     G_EXPENDITURE_ORGANIZATION_ID),
 	      	      NULL),		--expenditure_organization_id
 	       DECODE( DECODE(X_SINGLE_DIST_FLAG,'Y',
 	      	              DECODE(PD.destination_type_code,
			             'EXPENSE',PD.project_id,
				     G_PROJECT_ID),
 	      	              NULL),
		      '','',x_quantity_invoiced),   --pa_quantity
 	       NULL,				--pa_cc_ar_invoice_id
 	       NULL,				--pa_cc_ar_invoice_line_num
 	       NULL,				--pa_cc_processed_code
               DECODE(X_SINGLE_DIST_FLAG,
                        'Y', nvl(gms_ap_api.get_distribution_award(PD.AWARD_ID), G_AWARD_ID),
                        NULL),  		--award_id
 	       G_AWT_GROUP_ID,			--awt_group_id
 	       NULL,    			--reference_1
 	       NULL,				--reference_2
 	       NULL,				--receipt_verified_flag
 	       NULL,				--receipt_required_flag
 	       NULL,				--receipt_missing_flag
 	       NULL,				--justification
 	       NULL,				--expense_group
 	       NULL,				--start_expense_date
 	       NULL,				--end_expense_date
 	       NULL,				--receipt_currency_code
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
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute_category),''),--attribute_category
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute1),''),	--attribute1
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute2),''),	--attribute2
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute3),''),	--attribute3
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute4),''),	--attribute4
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute5),''),	--attribute5
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute6),''),	--attribute6
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute7),''),	--attribute7
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute8),''),	--attribute8
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute9),''),	--attribute9
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute10),''),	--attribute10
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute11),''),	--attribute11
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute12),''),	--attribute12
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute13),''),	--attribute13
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute14),''),	--attribute14
 	       NVL(DECODE(g_transfer_flag,'Y',PLL.attribute15),''),	--attribute15
 	       /* X_GLOBAL_ATTRIBUTE_CATEGORY,	--global_attribute_category
	       X_GLOBAL_ATTRIBUTE1,		--global_attribute1
      	       X_GLOBAL_ATTRIBUTE2,		--global_attribute2
	       X_GLOBAL_ATTRIBUTE3,		--global_attribute3
      	       X_GLOBAL_ATTRIBUTE4,		--global_attribute4
      	       X_GLOBAL_ATTRIBUTE5,		--global_attribute5
      	       X_GLOBAL_ATTRIBUTE6,		--global_attribute6
      	       X_GLOBAL_ATTRIBUTE7,		--global_attribute7
       	       X_GLOBAL_ATTRIBUTE8,		--global_attribute8
      	       X_GLOBAL_ATTRIBUTE9,		--global_attribute9
       	       X_GLOBAL_ATTRIBUTE10,		--global_attribute10
      	       X_GLOBAL_ATTRIBUTE11,		--global_attribute11
      	       X_GLOBAL_ATTRIBUTE12,		--global_attribute12
      	       X_GLOBAL_ATTRIBUTE13,		--global_attribute13
      	       X_GLOBAL_ATTRIBUTE14,		--global_attribute14
      	       X_GLOBAL_ATTRIBUTE15,		--global_attribute15
      	       X_GLOBAL_ATTRIBUTE16,		--global_attribute16
      	       X_GLOBAL_ATTRIBUTE17,		--global_attribute17
      	       X_GLOBAL_ATTRIBUTE18,		--global_attribute18
      	       X_GLOBAL_ATTRIBUTE19,		--global_attribute19
      	       X_GLOBAL_ATTRIBUTE20, */ 	--global_attribute20
      	       SYSDATE,				--creation_date
      	       G_USER_ID,			--created_by
      	       G_USER_ID,			--last_update_by
      	       SYSDATE,				--last_update_date
      	       G_LOGIN_ID,			--last_update_login
      	       NULL,				--program_application_id
	       NULL,				--program_id
      	       NULL,				--program_update_date
      	       NULL,  	      		       	--request_id
	       X_RETAINED_AMOUNT,		--retained_amount
	       (-X_RETAINED_AMOUNT),		--retained_amount_remaining
	       PLL.SHIP_TO_LOCATION_ID,         --ship_to_location_id
	       --bugfix:5565310
	       G_INTENDED_USE,                  --primary_intended_use
	       G_PRODUCT_FISC_CLASS,            --product_fisc_classification
	       G_TRX_BUSINESS_CATEGORY,         --trx_business_category
	       G_PRODUCT_TYPE,                  --product_type
	       G_PRODUCT_CATEGORY,              --product_category
	       G_USER_DEFINED_FISC_CLASS,        --user_defined_fisc_class
	       G_ASSESSABLE_VALUE,
	       G_dflt_tax_class_code,
		   G_PAY_AWT_GROUP_ID			--pay_awt_group_id  bug8222382
          -- bug 5061826 -- new FROM clause that goes to base tables
          FROM PO_LINES_ALL PL,
               PO_LINE_LOCATIONS_ALL PLL,
               po_distributions pd,
               mtl_system_items msi
          WHERE pll.line_location_id =  x_po_line_location_id
            and pd.line_location_id = pll.line_location_id
            AND PLL.PO_LINE_ID = PL.PO_LINE_ID
            and pd.po_distribution_id = nvl(x_po_distribution_id,pd.po_distribution_id)
            and msi.inventory_item_id(+) = pl.item_id
            and msi.organization_id(+) = g_inventory_organization_id
            and rownum = 1;
 	 /* -- bug 5061826 -- commented out older FROM clause
         FROM PO_LINE_LOCATIONS_AP_V PLL,
 	       PO_DISTRIBUTIONS_AP_V PD,
 	       MTL_SYSTEM_ITEMS MSI
 	 WHERE PLL.LINE_LOCATION_ID = X_PO_LINE_LOCATION_ID
 	  AND PD.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID
 	  AND PD.PO_DISTRIBUTION_ID = NVL(X_PO_DISTRIBUTION_ID,PD.PO_DISTRIBUTION_ID)
 	  AND MSI.INVENTORY_ITEM_ID(+) = PLL.ITEM_ID
 	  AND MSI.ORGANIZATION_ID(+) = G_INVENTORY_ORGANIZATION_ID
	  AND ROWNUM = 1; */


    /* for charge lines (frt and misc) allocated during matching */
    ELSIF (x_line_type_lookup_code IN ('FREIGHT','MISCELLANEOUS')) THEN

        l_debug_info := 'Inserting Charge Line';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        INSERT INTO AP_INVOICE_LINES (
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
	      RETAINED_AMOUNT,
	      RETAINED_AMOUNT_REMAINING,
	      SHIP_TO_LOCATION_ID,
	      --bugfix:5565310
	      PRIMARY_INTENDED_USE,
	      PRODUCT_FISC_CLASSIFICATION,
	      TRX_BUSINESS_CATEGORY,
	      PRODUCT_TYPE,
	      PRODUCT_CATEGORY,
	      USER_DEFINED_FISC_CLASS,
	      ASSESSABLE_VALUE,
	      TAX_CLASSIFICATION_CODE,
	      COST_FACTOR_ID,
		  PAY_AWT_GROUP_ID  --bug 8222382
	      )
    SELECT    X_INVOICE_ID,			--invoice_id
     	      X_INVOICE_LINE_NUMBER,		--invoice_line_number
     	      X_LINE_TYPE_LOOKUP_CODE,		--line_type_lookup_code
     	      AIL.REQUESTER_ID,			--requester_id
     --bug 5102208
	      SUBSTRB(X_CHARGE_LINE_DESCRIPTION || AIL.description, 1, 240),--description
	      'CHRG ITEM MATCH',		--line_source
     	      AIL.ORG_ID,			--org_id
     	      NULL,				--inventory_item_id
     	      NULL,				--item_description
     	      NULL,				--serial_number
     	      NULL,				--manufacturer
     	      NULL,				--model_number
     	      'Y',				--generate_dists
     	      'NOT_MATCHED',			--match_type
     	      NULL,				--distribution_set_id
    	      NULL,				--account_segment
     	      NULL,				--balancing_segment
     	      NULL,				--cost_center_segment
     	      NULL,				--overlay_dist_code_concat
     	      --Bug6965650
 	      NULL,                     	--default_dist_ccid
    	      'N',				--prorate_across_all_items
     	      NULL,				--line_group_number
     	      AIL.ACCOUNTING_DATE,		--accounting_date
     	      AIL.PERIOD_NAME,			--period_name
 	      'N',				--deferred_acctg_flag
 	      NULL,				--deferred_acctg_start_date
 	      NULL,				--deferred_acctg_end_date
 	      NULL,				--def_acctg_number_of_periods
 	      NULL,				--def_acctg_period_type
 	      AIL.SET_OF_BOOKS_ID,	  	--set_of_books_id
 	      X_AMOUNT,				--amount
 	      AP_UTILITIES_PKG.Ap_Round_Currency(
              	    NVL(X_AMOUNT, 0) * G_EXCHANGE_RATE,
                   	 G_BASE_CURRENCY_CODE),	--base_amount
 	      NULL,			 	--rounding_amount
 	      NULL,				--quantity_invoiced
 	      NULL,				--unit_meas_lookup_code
 	      NULL,				--unit_price
	      AIL.WFAPPROVAL_STATUS,            --wf_approval_status
           -- Removed for bug 4277744
 	   -- NULL,				--ussgl_transaction_code
 	      'N',				--discarded_flag
 	      NULL,				--original_amount
 	      NULL,				--original_base_amount
 	      NULL,				--original_rounding_amt
 	      'N',				--cancelled_flag
 	      AIL.INCOME_TAX_REGION,		--income_tax_region
 	      AIL.TYPE_1099,			--type_1099
 	      NULL,				--stat_amount
 	      NULL,				--prepay_invoice_id
 	      NULL,				--prepay_line_number
 	      NULL,				--invoice_includes_prepay_flag
 	      NULL,				--corrected_inv_id
 	      NULL,				--corrected_line_number
 	      NULL,				--po_header_id
 	      NULL,				--po_line_id
 	      NULL,				--po_release_id
 	      NULL,				--po_line_location_id
 	      NULL,				--po_distribution_id
 	      NULL,				--rcv_transaction_id
 	      'N',				--final_match_flag
 	      'N',				--assets_tracking_flag
 	      NULL,				--asset_book_type_code
 	      NULL,				--asset_category_id
 	      AIL.PROJECT_ID,			--project_id
 	      AIL.TASK_ID,			--task_id
 	      AIL.EXPENDITURE_TYPE,		--expenditure_type
 	      AIL.EXPENDITURE_ITEM_DATE,	--expenditure_item_date
 	      AIL.EXPENDITURE_ORGANIZATION_ID,	--expenditure_organization_id
 	      NULL,				--pa_quantity
 	      NULL,				--pa_cc_Ar_invoice_id
 	      NULL,				--pa_cc_Ar_invoice_line_num
 	      NULL,				--pa_cc_processed_code
 	      AIL.AWARD_ID,			--award_id
 	      AIL.AWT_GROUP_ID,			--awt_group_id
 	      NULL,				--reference_1
 	      NULL,				--reference_2
 	      NULL,				--receipt_verified_flag
 	      NULL,				--receipt_required_flag
 	      NULL,				--receipt_missing_flag
 	      NULL,				--justification
 	      NULL,				--expense_group
 	      NULL,				--start_expense_date
 	      NULL,				--end_expense_date
 	      NULL,				--receipt_currency_code
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
 	      AIL.attribute_category,		--attribute_category
 	      AIL.attribute1,			--attribute1
 	      AIL.attribute2,			--attribute2
 	      AIL.attribute3,			--attribute3
 	      AIL.attribute4,			--attribute4
 	      AIL.attribute5,			--attribute5
 	      AIL.attribute6,			--attribute6
 	      AIL.attribute7,			--attribute7
 	      AIL.attribute8,			--attribute8
 	      AIL.attribute9,			--attribute9
 	      AIL.attribute10,			--attribute10
 	      AIL.attribute11,			--attribute11
 	      AIL.attribute12,			--attribute12
 	      AIL.attribute13,			--attribute13
 	      AIL.attribute14,			--attribute14
 	      AIL.attribute15,			--attribute15
 	      /* X_GLOBAL_ATTRIBUTE_CATEGORY,	--global_attribute_category
	      X_GLOBAL_ATTRIBUTE1,		--global_attribute1
      	      X_GLOBAL_ATTRIBUTE2,		--global_attribute2
	      X_GLOBAL_ATTRIBUTE3,		--global_attribute3
      	      X_GLOBAL_ATTRIBUTE4,		--global_attribute4
      	      X_GLOBAL_ATTRIBUTE5,		--global_attribute5
      	      X_GLOBAL_ATTRIBUTE6,		--global_attribute6
      	      X_GLOBAL_ATTRIBUTE7,		--global_attribute7
       	      X_GLOBAL_ATTRIBUTE8,		--global_attribute8
      	      X_GLOBAL_ATTRIBUTE9,		--global_attribute9
       	      X_GLOBAL_ATTRIBUTE10,		--global_attribute10
      	      X_GLOBAL_ATTRIBUTE11,		--global_attribute11
      	      X_GLOBAL_ATTRIBUTE12,		--global_attribute12
      	      X_GLOBAL_ATTRIBUTE13,		--global_attribute13
      	      X_GLOBAL_ATTRIBUTE14,		--global_attribute14
      	      X_GLOBAL_ATTRIBUTE15,		--global_attribute15
      	      X_GLOBAL_ATTRIBUTE16,		--global_attribute16
      	      X_GLOBAL_ATTRIBUTE17,		--global_attribute17
      	      X_GLOBAL_ATTRIBUTE18,		--global_attribute18
      	      X_GLOBAL_ATTRIBUTE19,		--global_attribute19
      	      X_GLOBAL_ATTRIBUTE20, */ 		--global_attribute20
      	      SYSDATE,				--creation_date
      	      G_USER_ID,			--created_by
      	      G_USER_ID,			--last_updated_by
      	      SYSDATE,				--last_updated_date
      	      G_LOGIN_ID,			--last_update_login
      	      NULL,				--program_application_id
      	      NULL,				--program_id
      	      NULL,				--program_update_date
      	      NULL,  	    	      		--request_id
	       X_RETAINED_AMOUNT,		--retained_amount
	       -(X_RETAINED_AMOUNT),		--retained_amount_remaining
              AIL.SHIP_TO_LOCATION_ID,         --ship_to_location_id
	      --bugfix:5565310
              G_INTENDED_USE,                  --primary_intended_use
              G_PRODUCT_FISC_CLASS,            --product_fisc_classification
              G_TRX_BUSINESS_CATEGORY,         --trx_business_category
              G_PRODUCT_TYPE,                  --product_type
              G_PRODUCT_CATEGORY,              --product_category
              G_USER_DEFINED_FISC_CLASS,       --user_defined_fisc_class
	      G_ASSESSABLE_VALUE,
	      G_dflt_tax_class_code,
	      X_COST_FACTOR_ID,		       --cost_factor_id
		  AIL.PAY_AWT_GROUP_ID			--pay_awt_group_id     bug8222382
 	FROM  AP_INVOICE_LINES AIL
      	WHERE AIL.INVOICE_ID = X_INVOICE_ID
          AND AIL.LINE_NUMBER = X_ITEM_LINE_NUMBER;

    END IF;

    g_max_invoice_line_number := g_max_invoice_line_number + 1;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Insert_Invoice_Line(-)');
   END IF;


  EXCEPTION WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice_Id = '||to_char(x_invoice_id)
	||', Invoice Line Number = '||to_char(x_invoice_line_number)
 	||', PO Distribution Id = '||to_char(x_po_distribution_id)
 	||', Project Id = '||to_char(g_project_id)
 	||', Task_Id ='||to_char(g_task_id)
 	||', Expenditure Type ='||g_expenditure_type
 	||', Expenditure_Organization_id ='||to_char(g_expenditure_organization_id));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Insert_Invoice_Line;



PROCEDURE Insert_Invoice_Distributions (
		X_Invoice_ID		IN   NUMBER,
		X_Invoice_Line_Number	IN   NUMBER,
		X_Dist_Tab		IN OUT NOCOPY Dist_Tab_Type,
		X_Final_Match_Flag	IN   VARCHAR2,
		X_Unit_Price		IN   NUMBER,
		X_Total_Amount		IN   NUMBER,
		X_Calling_Sequence	IN   VARCHAR2) IS

i				NUMBER;
l_distribution_line_number	NUMBER := 1;
l_debug_info			VARCHAR2(2000);
current_calling_sequence	VARCHAR2(2000);
l_api_name		        VARCHAR2(50);
l_copy_line_dff_flag    VARCHAR2(1); -- Bug 6837035

BEGIN
  l_api_name := 'Insert_Invoice_Distributions';

  current_calling_sequence := 'Insert_Invoice_Distributions <-'||x_calling_sequence;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Insert_Invoice_Distributions(+)');
  END IF;

  l_debug_info := 'Insert Invoice Distributions';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  -- Bug 6837035 Retrieve the profile value to check if the DFF info should be
  -- copied onto distributions for imported lines.
  l_copy_line_dff_flag := NVL(fnd_profile.value('AP_COPY_INV_LINE_DFF'),'N');
  FOR i in nvl(X_Dist_tab.FIRST, 0) .. nvl(X_Dist_tab.LAST, 0) LOOP

     IF (x_dist_tab.exists(i)) THEN

       l_debug_info := 'Insert invoice distribution corresponding to po_distribution : '||x_dist_tab(i).po_distribution_id;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

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
                global_attribute2, */
		--bugfix:4674194
                global_attribute3,
		/*
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
		intended_use,
		accrual_posted_flag,
		cash_posted_flag,
		--Freight and Special Charges
	        rcv_charge_addition_flag,
			pay_awt_group_id)   --bug 8222382
	 SELECT g_batch_id,			 --batch_id
      	        x_invoice_id,			 --invoice_id
      	        x_invoice_line_number,		 --invoice_line_number
      	        x_dist_tab(i).invoice_distribution_id, --invoice_distribution_id
      	        l_distribution_line_number,	--distribution_line_number
      	        decode(g_invoice_type_lookup_code, 'PREPAYMENT', 'ITEM', -- bug 9081676: modify
                  decode (pd.accrue_on_receipt_flag,'Y',
      	        	'ACCRUAL','ITEM')),      --line_type_lookup_code
      	        ail.item_description, 		--description
      	        'ITEM_TO_PO',			--dist_match_type
      		'PERMANENT',			--distribution_class
      		ail.org_id,			--org_id
                x_dist_tab(i).dist_ccid,	--dist_code_combination_id
                ail.accounting_date,		--accounting_date
      	        ail.period_name, 		--period_name
      		NULL,				--amount_to_post
      		NULL,				--base_amount_to_post
      		NULL,				--posted_amount
      		NULL,				--posted_base_amount
      		NULL,				--je_batch_id
      		NULL,				--cash_je_batch_id
      		'N',				--posted_flag
      		NULL,				--accounting_event_id
      		NULL,				--upgrade_posted_amt
      		NULL,				--upgrade_base_posted_amt
      		g_set_of_books_id,		--set_of_books_id
      		x_dist_tab(i).amount,		--amount
      		x_dist_tab(i).base_amount,	--base_amount
		x_dist_tab(i).rounding_amt,	--rounding_amount
		--bugfix:4959567
      		NULL,				--match_status_flag
      		'N',				--encumbered_flag
      		NULL,				--packet_id
             -- Removed for bug 4277744
             --	NVL(PD.ussgl_transaction_code,
             --	  ail.ussgl_transaction_code),	--ussgl_transaction_code
             --	NULL,				--ussgl_trx_code_context
      		'N',				--reversal_flag
      		NULL,				--parent_reversal_id
      		'N',				--cancellation_flag
      		DECODE(ail.type_1099,'','',
			ail.income_tax_region),	--income_tax_region
      		ail.type_1099, 			--type_1099
      		NULL,				--stat_amount
      		NULL,				--charge_applicable_to_dist_id
      		NULL,				--prepay_amount_remaining
      		NULL,				--prepay_distribution_id
      		NULL,				--parent_invoice_id
      		NULL,				--corrected_invoice_dist_id
      		NULL,				--corrected_quantity
      		NULL,				--other_invoice_id
      		x_dist_tab(i).po_distribution_id,--po_distribution_id
      		NULL,			        --rcv_transaction_id
      		x_dist_tab(i).unit_price,	--unit_price
      		ail.unit_meas_lookup_code,      --matched_uom_lookup_code
      		x_dist_tab(i).quantity_invoiced,--quantity_invoiced
      		x_final_match_flag,		--final_match_flag
      		NULL,				--related_id
      		'U',				--assets_addition_flag
      		decode(gcc.account_type,'E',ail.assets_tracking_flag,'A','Y','N'),  --assets_tracking_flag
      		decode(decode(gcc.account_type,'E',ail.assets_tracking_flag,'A','Y','N'),
      			'Y',ail.asset_book_type_code,NULL), 		      --asset_book_type_code
      		decode(decode(gcc.account_type,'E',ail.assets_tracking_flag,'A','Y','N'),
      			 	 'Y',ail.asset_category_id,NULL),    	     --asset_category_id
      		x_dist_tab(i).project_id ,     		--project_id
      		x_dist_tab(i).task_id    ,     		--task_id
      		x_dist_tab(i).expenditure_type,		--expenditure_type
     	        x_dist_tab(i).expenditure_item_date,    --expenditure_item_date
      		x_dist_tab(i).expenditure_organization_id , --expenditure_organization_id
      	 	x_dist_tab(i).pa_quantity,	        --pa_quantity
      		decode(PD.project_id,NULL, 'E',
		       decode(pd.destination_type_code,
		              'INVENTORY','M','SHOP FLOOR','M','N')),   --pa_addition_flag
      		NULL,					--pa_cc_ar_invoice_id
      		NULL,					--pa_cc_ar_invoice_line_num
      		NULL,					--pa_cc_processed_code
      		NULL,					--award_id
      		NULL,					--gms_burdenable_raw_cost
      		NULL,					--awt_flag
		x_dist_tab(i).awt_group_id,		--awt_group_id
      		NULL,					--awt_tax_rate_id
      		NULL,					--awt_gross_amount
      		NULL,					--awt_invoice_id
      		NULL,					--awt_origin_group_id
      		NULL,					--awt_invoice_payment_id
      		NULL,					--awt_withheld_amt
      		'N',					--inventory_transfer_status
      		NULL,					--reference_1
      		NULL,					--reference_2
      		NULL,					--receipt_verified_flag
      		NULL,					--receipt_required_flag
      		NULL,					--receipt_missing_flag
      		NULL,					--justification
      		NULL,					--expense_group
       		NULL,					--start_expense_date
      		NULL,					--end_expense_date
    		NULL,					--receipt_currency_code
      		NULL,					--receipt_conversion_rate
       		NULL,					--receipt_currency_amount
      		NULL,					--daily_amount
    		NULL,					--web_parameter_id
      		NULL,					--adjustment_reason
       		NULL,					--merchant_document_number
      		NULL,					--merchant_name
    		NULL,					--merchant_reference
      		NULL,					--merchant_tax_reg_number
       		NULL,					--merchant_taxpayer_id
      		NULL,					--country_of_supply
    		NULL,					--credit_card_trx_id
      		NULL,					--company_prepaid_invoice_id
       		NULL,					--cc_reversal_flag
       		-- Bug 6837035 Start
       		NVL(DECODE(g_transfer_flag,'Y',pd.attribute_category,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute_category))), ''),--attribute_category
 	      	NVL(DECODE(g_transfer_flag,'Y',pd.attribute1,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute1))), ''),	--attribute1
 	      	NVL(DECODE(g_transfer_flag,'Y',pd.attribute2,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute2))), ''),	--attribute2
 	      	NVL(DECODE(g_transfer_flag,'Y',pd.attribute3,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute3))), ''),	--attribute3
 	      	NVL(DECODE(g_transfer_flag,'Y',pd.attribute4,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute4))), ''),	--attribute4
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute5,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute5))), ''),	--attribute5
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute6,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute6))), ''),	--attribute6
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute7,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute7))), ''),	--attribute7
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute8,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute8))), ''),	--attribute8
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute9,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute9))), ''),	--attribute9
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute10,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute10))), ''),	--attribute10
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute11,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute11))), ''),	--attribute11
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute12,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute12))), ''),	--attribute12
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute13,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute13))), ''),	--attribute13
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute14,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute14))), ''),	--attribute14
 	        NVL(DECODE(g_transfer_flag,'Y',pd.attribute15,DECODE(line_source,'IMPORTED',
			   DECODE(l_copy_line_dff_flag,'Y',ail.attribute15))), ''),	--attribute15
       		-- Bug 6837035 End
  	        /* X_GLOBAL_ATTRIBUTE_CATEGORY,
		X_GLOBAL_ATTRIBUTE1,
      		X_GLOBAL_ATTRIBUTE2, */
		--Bugfix:4674194
	        DECODE(AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_OPTION,
	               'Y',ail.ship_to_location_id, ''),
		/*
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
      		ail.created_by,			--created_by
      		sysdate,			--creation_date
      		ail.last_updated_by,		--last_updated_by
      		sysdate,			--last_update_date
      		ail.last_update_login,		--last_update_login
      		NULL,				--program_application_id
      		NULL,				--program_id
      		NULL,				--program_update_date
      		NULL,				--request_id
		--bugfix:5565310
		G_intended_use,		        --intended_use
		'N',			        --accrual_posted_flag
		'N',				--cash_posted_flag
		'N',				--rcv_charge_addition_flag
		x_dist_tab(i).pay_awt_group_id		--pay_awt_group_id   bug8222382
      	  FROM  po_distributions pd,
      	        ap_invoice_lines ail,
      	        gl_code_combinations gcc
         WHERE ail.invoice_id = x_invoice_id
           AND ail.line_number = x_invoice_line_number
	   AND ail.po_line_location_id = pd.line_location_id
  	   AND pd.po_distribution_id = x_dist_tab(i).po_distribution_id
  	   AND gcc.code_combination_id = decode(pd.accrue_on_receipt_flag, 'Y',    --Bug6014884
                                             pd.code_combination_id,x_dist_tab(i).dist_ccid);



         --Bugfix:4674635
	 l_debug_info := 'Call the AP_EXTENDED_MATCH to populate global attributes';
	 IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
         END IF;

         IF (AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_ACTIVE) THEN
            AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_MATCH(
				P_Credit_Id    => NULL,
	                        P_Invoice_Id   => X_invoice_id,
			        P_Inv_Line_Num => x_invoice_line_number,
				P_Distribution_Id => x_dist_tab(i).invoice_distribution_id,
				P_Parent_Dist_Id => NULL);

         END IF;


         GMS_AP_API.CREATE_AWARD_DISTRIBUTIONS
                                ( p_invoice_id               => x_invoice_id,
                                  p_distribution_line_number => l_distribution_line_number,
                                  p_invoice_distribution_id  => x_dist_tab(i).invoice_distribution_id,
                                  p_award_id                 => x_dist_tab(i).award_id,
                                  p_mode                     => 'AP',
                                  p_dist_set_id              => NULL,
                                  p_dist_set_line_number     => NULL );

       l_distribution_line_number := l_distribution_line_number + 1;

    END IF;

 END LOOP;

 IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Insert_Invoice_Distributions(-)');
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
		||', Dist_num = '||l_distribution_line_number
		||', Allow_PA_Override = '||g_allow_pa_override
		||', Transfer_Desc_Flag = '||g_Transfer_Flag);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   --Clean up the PL/SQL table
   X_DIST_TAB.DELETE;

   APP_EXCEPTION.RAISE_EXCEPTION;

END Insert_Invoice_Distributions;


Procedure Update_PO_Shipments_Dists(
		    X_Dist_Tab	          IN OUT NOCOPY  Dist_Tab_Type,
		    X_Po_Line_Location_Id IN 	         NUMBER,
		    X_Match_Amount        IN   		 NUMBER,
		    X_Match_Quantity	  IN		 NUMBER,
		    X_Uom_Lookup_Code  	  IN  		 VARCHAR2,
  		    X_Calling_Sequence    IN		 VARCHAR2) IS

 current_calling_sequence	VARCHAR2(2000);
 l_debug_info			VARCHAR2(2000);
 i				NUMBER;
 l_po_ap_dist_rec		PO_AP_DIST_REC_TYPE;
 l_po_ap_line_loc_rec		PO_AP_LINE_LOC_REC_TYPE;
 l_api_name			VARCHAR2(50);
 l_return_status		VARCHAR2(100);
 l_msg_data			VARCHAR2(4000);
BEGIN

   l_api_name := 'Update_PO_Shipments_Dists';

   current_calling_sequence := 'Update_Po_Shipments_Dists<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Update_PO_Shipments_Dists(+)');
   END IF;

   l_debug_info := 'Create l_po_ap_dist_rec object';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   l_po_ap_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

   l_debug_info := 'Create l_po_ap_line_loc_rec object and populate the data';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   IF (g_invoice_type_lookup_code <> 'PREPAYMENT') THEN

      l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
				 p_po_line_location_id => x_po_line_location_id,
				 p_uom_code	       => x_uom_lookup_code,
				 p_quantity_billed     => x_match_quantity,
				 p_amount_billed       => x_match_amount,
				 p_quantity_financed  => NULL,
 				 p_amount_financed    => NULL,
				 p_quantity_recouped  => NULL,
				 p_amount_recouped    => NULL,
				 p_retainage_withheld_amt => NULL,
				 p_retainage_released_amt => NULL
				);

   ELSIF (g_invoice_type_lookup_code = 'PREPAYMENT') THEN

      l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
				 p_po_line_location_id => x_po_line_location_id,
				 p_uom_code	       => x_uom_lookup_code,
				 p_quantity_billed     => NULL,
				 p_amount_billed       => NULL,
				 p_quantity_financed   => x_match_quantity,
 				 p_amount_financed     => x_match_amount,
				 p_quantity_recouped   => NULL,
				 p_amount_recouped     => NULL,
				 p_retainage_withheld_amt => NULL,
				 p_retainage_released_amt => NULL
				);

   END IF;

   l_debug_info := 'Populate the Po_Ap_Dist_Rec with the distribution information';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   FOR i in nvl(x_dist_tab.first,0)..nvl(x_dist_tab.last,0) LOOP

      IF (x_dist_tab.exists(i)) THEN

          IF (g_invoice_type_lookup_code <> 'PREPAYMENT') THEN

              l_po_ap_dist_rec.add_change(p_po_distribution_id => x_dist_tab(i).po_distribution_id,
    				p_uom_code	     => x_uom_lookup_code,
				p_quantity_billed    => x_dist_tab(i).quantity_invoiced,
				p_amount_billed	     => x_dist_tab(i).amount,
				p_quantity_financed  => NULL,
				p_amount_financed    => NULL,
				p_quantity_recouped  => NULL,
				p_amount_recouped    => NULL,
				p_retainage_withheld_amt => NULL,
				p_retainage_released_amt => NULL);

          ELSIF (g_invoice_type_lookup_code = 'PREPAYMENT') THEN

              l_po_ap_dist_rec.add_change(p_po_distribution_id => x_dist_tab(i).po_distribution_id,
    				p_uom_code	     => x_uom_lookup_code,
				p_quantity_billed    => NULL,
				p_amount_billed	     => NULL,
				p_quantity_financed  => x_dist_tab(i).quantity_invoiced,
				p_amount_financed    => x_dist_tab(i).amount,
				p_quantity_recouped  => NULL,
				p_amount_recouped    => NULL,
				p_retainage_withheld_amt => NULL,
				p_retainage_released_amt => NULL);

          END IF;

       END IF;

   END LOOP;

   l_debug_info := 'Call the PO_AP_INVOICE_MATCH_GRP to update the Po Distributions and Po Line Locations';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
					P_Api_Version => 1.0,
					P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
					P_Dist_Changes_Rec     => l_po_ap_dist_rec,
					X_Return_Status	       => l_return_status,
					X_Msg_Data	       => l_msg_data);


   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Update_PO_Shipments_Dists(-)');
   END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','PO Distribution Id = '||TO_CHAR(X_Dist_tab(i).po_distribution_id)
 			  ||', UOM= '||X_uom_lookup_code);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;

   --Clean up the PL/SQL table
   X_DIST_TAB.DELETE;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Update_PO_Shipments_Dists;


Procedure Create_Charge_Lines(  X_Invoice_Id 	 	 IN 	NUMBER,
				X_Freight_Cost_Factor_id IN     NUMBER,
    				X_Freight_Amount   	 IN 	NUMBER,
    				X_Freight_Description 	 IN	VARCHAR2,
				X_Misc_Cost_Factor_id    IN     NUMBER,
    				X_Misc_Amount		 IN	NUMBER,
    				X_Misc_Description	 IN	VARCHAR2,
    				X_Item_Line_Number	 IN	NUMBER,
    				X_Calling_Sequence	 IN	VARCHAR2) IS

l_debug_info	VARCHAR2(2000);
current_calling_sequence	VARCHAR2(2000);
l_api_name			VARCHAR2(50);

BEGIN

	l_api_name := 'Create_Charge_Lines';

 	current_calling_sequence := 'Create_Charge_Lines<-'||X_Calling_Sequence;

	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Create_Charge_Lines(+)');
        END IF;

	IF (X_Freight_Amount IS NOT NULL) THEN

	    l_debug_info := 'Create Freight Line';
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   	    END IF;

	    Insert_Invoice_Line(
	    		    X_Invoice_Id  	  => x_invoice_id,
			    X_Invoice_Line_Number => g_max_invoice_line_number + 1,
			    X_Line_Type_Lookup_Code => 'FREIGHT',
			    X_Cost_Factor_id   	    => x_freight_cost_factor_id,
			    X_Amount		    => x_freight_amount,
			    X_Item_Line_Number	    => x_item_line_number,
			    X_Charge_Line_Description => x_freight_description,
			    X_Calling_Sequence	    => current_calling_sequence);


	    l_debug_info := 'Create Allocation Rules for the freight line';
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   	    END IF;

	    AP_ALLOCATION_RULES_PKG.Insert_Percentage_Alloc_Rule(
	              X_Invoice_id           => x_invoice_id,
		      X_Chrg_Line_Number     => g_max_invoice_line_number,
		      X_To_Line_Number       => x_item_line_number,
		      X_Percentage           => 100,
		      X_Calling_Sequence     => x_calling_sequence);


        END IF;


	IF (X_Misc_Amount IS NOT NULL) THEN

	   l_debug_info := 'Create Misc Line';
	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   	   END IF;

	   Insert_Invoice_Line(
	   		    X_Invoice_Id  	  => x_invoice_id,
			    X_Invoice_Line_Number => g_max_invoice_line_number + 1,
			    X_Line_Type_Lookup_Code => 'MISCELLANEOUS',
			    X_Cost_Factor_id	    => x_misc_cost_factor_id,
			    X_Amount		    => x_misc_amount,
			    X_Item_Line_Number	    => x_item_line_number,
			    X_Charge_Line_Description => x_misc_description,
			    X_Calling_Sequence	    => current_calling_sequence);

	   l_debug_info := 'Create Allocation Rules for the misc line';
	   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	   END IF;

	   AP_ALLOCATION_RULES_PKG.Insert_Percentage_Alloc_Rule(
	                    X_Invoice_id           => x_invoice_id,
			    X_Chrg_Line_Number     => g_max_invoice_line_number,
			    X_To_Line_Number       => x_item_line_number,
			    X_Percentage           => 100,
			    X_Calling_Sequence     => x_calling_sequence);

        END IF;

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
	      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Create_Charge_Lines(-)');
        END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','Invoice Id = '||to_char(X_Invoice_Id)
			  ||', Freight Amount = '||to_char(x_freight_amount)
			  ||', Freight Description = '||x_freight_description
			  ||', Misc Amount = '||to_char(x_misc_amount)
			  ||', Misc Description = '||x_misc_description
			  ||', Item Line Number = '||TO_CHAR(X_Item_Line_Number)
			  ||', Accounting Date = '||g_accounting_date
			  ||', Period Name = '||g_period_name
			  ||', Set of books id = '||to_char(g_set_of_books_id)
			  ||', Exchange Rate = '||g_exchange_rate
			  ||', Base Currency Code = '||g_base_currency_code
			  ||', Income Tax Region = '||g_income_tax_region
			  ||', Awt Group Id = '||g_awt_group_id
			  ||', Transfer Flag = '||g_transfer_flag
			  ||', Pay Awt Group Id = '||g_pay_awt_group_id);  --bug 8222382
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Create_Charge_Lines;


/*===========================================================================
	PRICE AND QUANTITY CORRECTION OF INVOICE MATCHED TO PO
============================================================================*/


PROCEDURE Price_Quantity_Correct_Inv_PO(
		X_Invoice_Id		IN	NUMBER,
		X_Invoice_Line_Number   IN 	NUMBER,
		X_Corrected_Invoice_Id  IN	NUMBER,
		X_Corrected_Line_Number IN	NUMBER,
		X_Correction_Type	IN	VARCHAR2,
		X_Match_Mode		IN	VARCHAR2,
		X_Correction_Quantity	IN	NUMBER,
		X_Correction_Amount	IN	NUMBER,
		X_Correction_Price	IN	NUMBER,
		X_Po_Line_Location_Id   IN	NUMBER,
		X_Corr_Dist_Tab		IN OUT NOCOPY CORR_DIST_TAB_TYPE,
		X_Final_Match_Flag	IN	VARCHAR2,
		X_Uom_Lookup_Code	IN	VARCHAR2,
		X_Retained_Amount	IN	NUMBER DEFAULT NULL,
		X_Calling_Sequence	IN 	VARCHAR2) IS

l_po_distribution_id     PO_DISTRIBUTIONS.PO_DISTRIBUTION_ID%TYPE := NULL;
l_item_line_number	 AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE;
l_line_amt_net_retainage        ap_invoice_lines_all.amount%TYPE;
l_max_amount_to_recoup		ap_invoice_lines_all.amount%TYPE;
l_amount_to_recoup	 	ap_invoice_lines_all.amount%TYPE;
l_retained_amount		ap_invoice_lines_all.retained_amount%TYPE;
l_success		 BOOLEAN;
l_error_message		 VARCHAR2(4000);
l_debug_info		 VARCHAR2(2000);
current_calling_sequence VARCHAR2(2000);
l_api_name		 VARCHAR2(50);

BEGIN

   l_api_name := 'Price_Quantity_Correct_Inv_PO';

   current_calling_sequence := 'Price_Quantity_Correct_Inv_PO<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Price_Quantity_Correct_Inv_PO(+)');
   END IF;

   l_debug_info := 'Calling Get_Info';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   Get_Info(x_invoice_id  => x_invoice_id,
	    x_invoice_line_number => x_invoice_line_number,
	    x_match_amount	  => x_correction_amount,
	    x_po_line_location_id => x_po_line_location_id,
	    x_calling_sequence => current_calling_sequence);

   IF g_invoice_type_lookup_code <> 'PREPAYMENT' THEN
      l_retained_amount := AP_INVOICE_LINES_UTILITY_PKG.Get_Retained_Amount
                                        (p_line_location_id => x_po_line_location_id,
                                         p_match_amount     => x_correction_amount);
   END IF;

   l_debug_info := 'Calling Get_Corr_Dist_Proration_Info';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   Get_Corr_Dist_Proration_Info(
            x_corrected_invoice_id  => x_corrected_invoice_id,
	    x_corrected_line_number => x_corrected_line_number,
	    x_corr_dist_tab 	    => x_corr_dist_tab,
	    x_correction_type       => x_correction_type,
	    x_correction_amount     => x_correction_amount,
	    x_correction_quantity   => x_correction_quantity,
	    x_correction_price      => x_correction_price,
	    x_match_mode	    => x_match_mode,
	    x_calling_sequence      => current_calling_sequence);

   IF (x_corr_dist_tab.COUNT = 1) THEN

      l_po_distribution_id := x_corr_dist_tab.FIRST;

   END IF;

   IF (x_invoice_line_number IS NULL) THEN

	l_debug_info := 'Calling Insert_Corr_Invoice_Line';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

	Insert_Corr_Invoice_Line(x_invoice_id	         => x_invoice_id,
		 	         x_invoice_line_number   => g_max_invoice_line_number +1,
		 	         x_corrected_invoice_id  => x_corrected_invoice_id,
		 	         x_corrected_line_number => x_corrected_line_number,
				 x_quantity	      => x_correction_quantity,
				 x_amount	      => x_correction_amount,
				 x_unit_price         => x_correction_price,
				 x_correction_type    => x_correction_type,
				 x_final_match_flag   => x_final_match_flag,
				 x_po_distribution_id => l_po_distribution_id,
				 x_retained_amount    => l_retained_amount,
				 x_calling_sequence   => current_calling_sequence);

   END IF;

   l_item_line_number := g_max_invoice_line_number;

   l_debug_info := 'Calling Insert_Corr_Invoice_Dists';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   Insert_Corr_Invoice_Dists(x_invoice_id          => x_invoice_id,
			     x_invoice_line_number => nvl(x_invoice_line_number,
							  g_max_invoice_line_number),
		             x_corrected_invoice_id=> x_corrected_invoice_id,
			     x_corr_dist_tab	   => x_corr_dist_tab,
			     x_correction_type	   => x_correction_type,
			     x_final_match_flag	   => x_final_match_flag,
			     x_total_amount	   => x_correction_amount,
			     x_calling_sequence    => current_calling_sequence);


   IF(x_invoice_line_number IS NOT NULL) THEN

      l_debug_info := 'Updating Invoice Line Attributes after matching';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      UPDATE ap_invoice_lines ail
        SET (generate_dists ,
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
            retained_amount,
            retained_amount_remaining)
            =
          (SELECT 'D',
                /* Bug 7483260.  If the attribute field is populated in the
                 * interface, take that value. If the attribute field from
                 * the interface is null and the transfer_desc_flex_flag is
                 * Y, take the value from the purchase order.
                 */
                nvl(ail.attribute_category, decode(g_transfer_flag, 'Y', pll.attribute_category, ail.attribute_category)),
                nvl(ail.attribute1, decode(g_transfer_flag, 'Y', pll.attribute1, ail.attribute1)),
                nvl(ail.attribute2, decode(g_transfer_flag, 'Y', pll.attribute2, ail.attribute2)),
                nvl(ail.attribute3, decode(g_transfer_flag, 'Y', pll.attribute3, ail.attribute3)),
                nvl(ail.attribute4, decode(g_transfer_flag, 'Y', pll.attribute4, ail.attribute4)),
                nvl(ail.attribute5, decode(g_transfer_flag, 'Y', pll.attribute5, ail.attribute5)),
                nvl(ail.attribute6, decode(g_transfer_flag, 'Y', pll.attribute6, ail.attribute6)),
                nvl(ail.attribute7, decode(g_transfer_flag, 'Y', pll.attribute7, ail.attribute7)),
                nvl(ail.attribute8, decode(g_transfer_flag, 'Y', pll.attribute8, ail.attribute8)),
                nvl(ail.attribute9, decode(g_transfer_flag, 'Y', pll.attribute9, ail.attribute9)),
                nvl(ail.attribute10, decode(g_transfer_flag, 'Y', pll.attribute10, ail.attribute10)),
                nvl(ail.attribute11, decode(g_transfer_flag, 'Y', pll.attribute11, ail.attribute11)),
                nvl(ail.attribute12, decode(g_transfer_flag, 'Y', pll.attribute12, ail.attribute12)),
                nvl(ail.attribute13, decode(g_transfer_flag, 'Y', pll.attribute13, ail.attribute13)),
                nvl(ail.attribute14, decode(g_transfer_flag, 'Y', pll.attribute14, ail.attribute14)),
                nvl(ail.attribute15, decode(g_transfer_flag, 'Y', pll.attribute15, ail.attribute15)),
                --end Bug 7483260
                l_retained_amount,
                -1 * l_retained_amount
           FROM ap_invoice_lines ail1,
                po_line_locations pll
           WHERE ail1.invoice_id = x_invoice_id
           AND ail1.line_number =x_invoice_line_number
           AND pll.line_location_id = ail1.po_line_location_id)
        WHERE invoice_id = x_invoice_id
        AND line_number = x_invoice_line_number;

   END IF;

   l_debug_info := 'Create Retainage Distributions';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   Ap_Retainage_Pkg.Create_Retainage_Distributions
			(x_invoice_id          => x_invoice_id,
                         x_invoice_line_number => nvl(x_invoice_line_number,l_item_line_number));

   IF (g_recoupment_rate is not null and x_correction_amount > 0
   		and g_invoice_type_lookup_code <> 'PREPAYMENT') THEN

      l_debug_info := 'Calculate the maximum amount that can be recouped from this invoice line';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_line_amt_net_retainage := x_correction_amount + nvl(l_retained_amount,0);

      l_max_amount_to_recoup := ap_utilities_pkg.ap_round_currency(
     				(x_correction_amount * g_recoupment_rate / 100) ,g_invoice_currency_code);

      IF (l_line_amt_net_retainage < l_max_amount_to_recoup) THEN
        l_amount_to_recoup := l_line_amt_net_retainage;
      ELSE
        l_amount_to_recoup := l_max_amount_to_recoup;
      END IF;

      l_debug_info := 'Automatically recoup any available prepayments against the same po line';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      l_success := AP_Matching_Utils_Pkg.Ap_Recoup_Invoice_Line(
                                P_Invoice_Id           => x_invoice_id ,
                                P_Invoice_Line_Number  => nvl(x_invoice_line_number,l_item_line_number) ,
                                P_Amount_To_Recoup     => l_amount_to_recoup,
                                P_Po_Line_Id           => g_po_line_id,
                                P_Vendor_Id            => g_vendor_id,
                                P_Vendor_Site_Id       => g_vendor_site_id,
                                P_Accounting_Date      => g_accounting_date,
                                P_Period_Name          => g_period_name,
                                P_User_Id              => g_user_id,
                                P_Last_Update_Login    => g_login_id ,
                                P_Error_Message        => l_error_message,
                                P_Calling_Sequence     => current_calling_sequence);

   END IF;


   l_debug_info := 'Calling Update_Corr_Po_Shipments_Dists';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;
   Update_Corr_Po_Shipments_Dists(x_corr_dist_tab    => x_corr_dist_tab,
				x_po_line_location_id => x_po_line_location_id,
				x_quantity	   => x_correction_quantity,
				x_amount	   => x_correction_amount,
   				x_correction_type  => x_correction_type,
   				x_uom_lookup_code  => x_uom_lookup_code,
				x_calling_sequence => current_calling_sequence);

   --Clean up the PL/SQL tables
   x_corr_dist_tab.delete;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Price_Quantity_Correct_Inv_PO(-)');
   END IF;


EXCEPTION
    WHEN others then
        If (SQLCODE <> -20001) Then
            fnd_message.set_name('SQLAP','AP_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
            fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
                  ' invoice_id = '||to_char(x_invoice_id)
                ||', invoice_line_number = ' ||to_char(x_invoice_line_number)
                ||', corrected_invoice_id = '||to_char(x_corrected_invoice_id)
                ||', corrected_line_number = '||to_char(x_corrected_line_number)
                ||', correction_type = '||x_correction_type
		||', match_mode = '||x_match_mode
                ||', correction quantity = '||to_char(x_correction_quantity)
                ||', correction amount = '||to_char(x_correction_amount)
                ||', correction price = '||to_char(x_correction_price)
                ||', final_match_flag = '||x_final_match_flag
                ||', po_line_location_id = '||to_char(x_po_line_location_id));
            fnd_message.set_token('DEBUG_INFO',l_debug_info);
        End if;

	--Clean up the PL/SQL tables
	x_corr_dist_tab.delete;

        app_exception.raise_exception;

END Price_Quantity_Correct_Inv_PO;



PROCEDURE Get_Corr_Dist_Proration_Info(
			x_corrected_invoice_id  IN    NUMBER,
			x_corrected_line_number IN    NUMBER,
			x_corr_dist_tab IN OUT NOCOPY CORR_DIST_TAB_TYPE,
			x_correction_type     IN VARCHAR2,
			x_correction_amount   IN NUMBER,
			x_correction_quantity IN NUMBER,
			x_correction_price    IN NUMBER,
			x_match_mode	      IN VARCHAR2,
			x_calling_sequence    IN VARCHAR2) IS


CURSOR Price_Correction_Cursor(c_price_variance NUMBER) IS
  SELECT aid.invoice_distribution_id corrected_inv_dist_id,
  	 aid.po_distribution_id,
	 decode(g_min_acct_unit,'',
  	        round(x_correction_amount * (aid.amount+c_price_variance)/ail.amount,
	              g_precision),
                round((x_correction_amount * (aid.amount+c_price_variance)/ail.amount)
		      /g_min_acct_unit) * g_min_acct_unit
                ) amount,
         round(x_correction_quantity * (aid.amount+c_price_variance)/ail.amount,15) corrected_quantity,
	 --bugfix:5606697
	 DECODE(pd.destination_type_code,
	         'EXPENSE', DECODE(pd.accrue_on_receipt_flag,
	                           'Y', pd.code_combination_id,
	                           aid.dist_code_combination_id),
	         pd.variance_account_id),
	 ap_invoice_distributions_s.nextval
  FROM  ap_invoice_lines ail,
  	ap_invoice_distributions aid,
	po_distributions pd
  WHERE ail.invoice_id = x_corrected_invoice_id
  AND ail.line_number = x_corrected_line_number
  AND aid.invoice_id = ail.invoice_id
  AND aid.po_distribution_id = pd.po_distribution_id /*bugfix:5606697*/
  AND aid.invoice_line_number = ail.line_number
   -- Bug 5585744, Modified the condition below
  AND aid.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
  AND aid.prepay_distribution_id IS NULL;
  /*AND aid.line_type_lookup_code NOT IN ('PREPAY','AWT','RETAINAGE')
  AND (aid.line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX')
       OR aid.prepay_distribution_id IS NULL);  */

/*-----------------------------------------------------------
Amount: Quantity_Invoiced at the line level prorated based on
quantity_billed against the PO and multiplied by the unit_price
at the line level.

Corrected Quantity: Quantity_Invoiced selected prorated as done
for the Amount.
------------------------------------------------------------*/
CURSOR Quantity_Correction_Cursor(p_total_quantity_billed IN NUMBER) IS
  SELECT aid.invoice_distribution_id corrected_inv_dist_id,
  	 aid.po_distribution_id,
  	 decode(g_min_acct_unit,'',
	        round((x_correction_quantity *
			decode(pd.distribution_type,'PREPAYMENT',nvl(pd.quantity_financed,0),nvl(pd.quantity_billed,0))/p_total_quantity_billed
		        ) * x_correction_price,
		       g_precision),
                round(((x_correction_quantity * decode(pd.distribution_type,'PREPAYMENT',nvl(pd.quantity_financed,0),nvl(pd.quantity_billed,0))/
		 	 p_total_quantity_billed)*x_correction_price)
			 /g_min_acct_unit) * g_min_acct_unit
                ) amount,
         round((x_correction_quantity * decode(pd.distribution_type,'PREPAYMENT',nvl(pd.quantity_financed,0),nvl(pd.quantity_billed,0)))/
	 	  p_total_quantity_billed , 15) corrected_quantity,
         aid.dist_code_combination_id,
	 ap_invoice_distributions_s.nextval
  FROM ap_invoice_distributions aid,
       ap_invoice_lines ail,
       po_distributions pd
  WHERE ail.invoice_id = x_corrected_invoice_id
  AND ail.line_number = x_corrected_line_number
  AND aid.invoice_id = ail.invoice_id
  AND aid.invoice_line_number = ail.line_number
  AND pd.po_distribution_id = aid.po_distribution_id
   -- Bug 5585744, Modified the condition below
  AND aid.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
  AND aid.prepay_distribution_id IS NULL;
  /*AND aid.line_type_lookup_code NOT IN ('PREPAY','AWT','RETAINAGE')
  AND (aid.line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX')
       OR aid.prepay_distribution_id IS NULL); */

l_corrected_inv_dist_id   ap_invoice_distributions.corrected_invoice_dist_id%TYPE;
l_amount                  ap_invoice_distributions.amount%TYPE;
l_corrected_quantity      ap_invoice_distributions.corrected_quantity%TYPE;
l_total_quantity_billed   number;
l_base_amount	          ap_invoice_distributions.base_amount%TYPE;
l_invoice_distribution_id ap_invoice_distributions.invoice_distribution_id%TYPE;
l_max_dist_amount	  ap_invoice_distributions.amount%TYPE := 0;
l_sum_prorated_amount     ap_invoice_distributions.amount%TYPE := 0;
l_rounding_index	  ap_invoice_distributions.invoice_distribution_id%TYPE;
l_sum_dist_base_amount    ap_invoice_distributions.base_amount%TYPE := 0;
l_dist_ccid		  ap_invoice_distributions.dist_code_combination_id%TYPE;
l_po_dist_id		  ap_invoice_distributions.po_distribution_id%TYPE;
l_price_variance	  ap_invoice_distributions.amount%TYPE := 0;
l_debug_info	          varchar2(2000);
current_calling_sequence  varchar2(2000);
l_api_name		  varchar2(50);

BEGIN

   l_api_name := 'Get_Corr_Dist_Proration_Info';

   current_calling_sequence := 'Get_Corr_Dist_Proration_Info<-'||x_calling_sequence;
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Corr_Dist_Proration_Info(+)');
   END IF;


/* Bug 5176411, Changed the index for x_corr_dist_tab from l_po_dist_id to
   l_invoice_distrbution_id */

   IF (x_correction_type = 'PRICE_CORRECTION') THEN

     IF (x_match_mode IN ('STD-PS','CR-PS')) THEN

         BEGIN
            SELECT nvl(sum(amount),0)  -- Bug 5629985. Added the NVL
              INTO l_price_variance
              FROM ap_invoice_distributions_all
             WHERE invoice_id            = x_corrected_invoice_id
               AND invoice_line_number   = x_corrected_line_number
               AND line_type_lookup_code = 'IPV';
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;

        OPEN price_correction_cursor(l_price_variance);

        LOOP

           FETCH price_correction_cursor INTO l_corrected_inv_dist_id,
					   l_po_dist_id,
					   l_amount,
					   l_corrected_quantity,
					   l_dist_ccid,
					   l_invoice_distribution_id;

	   EXIT WHEN price_correction_cursor%NOTFOUND;

	   x_corr_dist_tab(l_invoice_distribution_id).po_distribution_id := l_po_dist_id;
	   x_corr_dist_tab(l_invoice_distribution_id).invoice_distribution_id := l_invoice_distribution_id;
	   x_corr_dist_tab(l_invoice_distribution_id).corrected_inv_dist_id := l_corrected_inv_dist_id;
	   x_corr_dist_tab(l_invoice_distribution_id).amount := l_amount;
	   x_corr_dist_tab(l_invoice_distribution_id).corrected_quantity := l_corrected_quantity;
	   x_corr_dist_tab(l_invoice_distribution_id).unit_price := x_correction_price;
	   x_corr_dist_tab(l_invoice_distribution_id).pa_quantity := l_corrected_quantity;
	   x_corr_dist_tab(l_invoice_distribution_id).dist_ccid := l_dist_ccid;

	   --Calculate the index of the max of the largest distribution for
	   --proration/base amount rounding.
	   IF (l_amount >= l_max_dist_amount) THEN
	      l_rounding_index := l_invoice_distribution_id;
	      l_max_dist_amount := l_max_dist_amount;
	   END IF;

	   l_sum_prorated_amount := l_sum_prorated_amount + l_amount;

        END LOOP;

        CLOSE price_correction_cursor;

     END IF; /*x_match_mode in 'STD-PS','CR-PS' */

   ELSIF (x_correction_type = 'QTY_CORRECTION') THEN

     --For Shipment Level Match
     IF (x_match_mode IN ('STD-PS','CR-PS')) THEN

       SELECT sum(decode(pd.distribution_type,'PREPAYMENT',nvl(pd.quantity_financed,0),nvl(pd.quantity_billed,0)))
       INTO l_total_quantity_billed
       FROM po_distributions pd,
            ap_invoice_distributions aid
       WHERE pd.po_distribution_id = aid.po_distribution_id
       AND aid.invoice_id = x_corrected_invoice_id
       AND aid.invoice_line_number = x_corrected_line_number
        -- Bug 5585744, Modified the condition below
       AND aid.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
       AND aid.prepay_distribution_id IS NULL;
      /*AND aid.line_type_lookup_code NOT IN ('PREPAY','AWT','RETAINAGE')
       AND (aid.line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX')
       OR aid.prepay_distribution_id IS NULL); */

       OPEN quantity_correction_cursor(l_total_quantity_billed);

       LOOP

	 FETCH quantity_correction_cursor INTO l_corrected_inv_dist_id,
	 				       l_po_dist_id,
					       l_amount,
					       l_corrected_quantity,
					       l_dist_ccid,
					       l_invoice_distribution_id;

	 EXIT WHEN quantity_correction_cursor%NOTFOUND;

         x_corr_dist_tab(l_invoice_distribution_id).po_distribution_id := l_po_dist_id;
	 x_corr_dist_tab(l_invoice_distribution_id).invoice_distribution_id := l_invoice_distribution_id;
         x_corr_dist_tab(l_invoice_distribution_id).corrected_inv_dist_id := l_corrected_inv_dist_id;
         x_corr_dist_tab(l_invoice_distribution_id).amount := l_amount;
         x_corr_dist_tab(l_invoice_distribution_id).corrected_quantity := l_corrected_quantity;
         x_corr_dist_tab(l_invoice_distribution_id).unit_price := x_correction_price;
         x_corr_dist_tab(l_invoice_distribution_id).pa_quantity := l_corrected_quantity;
	 x_corr_dist_tab(l_invoice_distribution_id).dist_ccid := l_dist_ccid;

	 --Calculate the index of the max of the largest distribution for
	 --proration/base amount rounding.
	 IF (l_amount >= l_max_dist_amount) THEN
            l_rounding_index := l_invoice_distribution_id;
            l_max_dist_amount := l_max_dist_amount;
         END IF;

         l_sum_prorated_amount := l_sum_prorated_amount + l_amount;

       END LOOP;

       CLOSE quantity_correction_cursor;

       --Perform Proration Rounding before the base amounts are populated

       IF (l_sum_prorated_amount <> x_correction_amount and l_rounding_index is not null) THEN
          x_corr_dist_tab(l_rounding_index).amount := x_corr_dist_tab(l_rounding_index).amount +
 						  (x_correction_amount - l_sum_prorated_amount);
       END IF;

     END IF; /*x_match_mode in 'STD-PS'... */

   END IF; /*x_correction_type ...*/


   --For the case when user distributes the correction, we still
   --need to populate the PL/SQL table with invoice_distribution_id...
   IF (x_match_mode IN ('STD-PD','CR-PD')) THEN

       FOR i IN nvl(x_corr_dist_tab.first,0) ..nvl(x_corr_dist_tab.last,0) LOOP

	 IF (x_corr_dist_tab.exists(i)) THEN

 	   SELECT ap_invoice_distributions_s.nextval
           INTO	x_corr_dist_tab(i).invoice_distribution_id
           FROM DUAL;

	   x_corr_dist_tab(i).pa_quantity := x_corr_dist_tab(i).corrected_quantity;

	   --Calculate the index of the max of the largest distribution for
	   --base amount rounding. For this case there will be no proration
	   --rounding as the user distributes the correction quantity.

	   --Also we will need this index only for foreign currency invoices only.

	   IF (g_exchange_rate IS NOT NULL) THEN
	      IF (x_corr_dist_tab(i).amount > l_max_dist_amount) THEN
	         l_rounding_index := i;
	         l_max_dist_amount := x_corr_dist_tab(i).amount;
	      END IF;
           END IF;

         END IF;

       END LOOP;

   END IF; /*x_match_mode IN ('STD-PD','CR-PD' */


   FOR i in nvl(x_corr_dist_tab.first,0) .. nvl(x_corr_dist_tab.last,0) LOOP

     IF (x_corr_dist_tab.exists(i)) THEN

       --Populating the base_amount column, after proration related rounding
       --has been done if it is a foreign currency invoice.

       IF (g_exchange_rate IS NOT NULL) THEN
          x_corr_dist_tab(i).base_amount := ap_utilities_pkg.ap_round_currency(
                                                  x_corr_dist_tab(i).amount * g_exchange_rate,
						  g_base_currency_code);

          l_sum_dist_base_amount := l_sum_dist_base_amount + x_corr_dist_tab(i).base_amount ;
       END IF;

     END IF;

   END LOOP;

   --Base Amount Rounding for foreign currency invoices only.
   --If it is a foreign currency invoice g_exchange_rate not be NULL
   IF (g_exchange_rate IS NOT NULL AND g_line_base_amount <> l_sum_dist_base_amount and l_rounding_index is not null) THEN

      x_corr_dist_tab(l_rounding_index).base_amount := x_corr_dist_tab(l_rounding_index).base_amount +
      						(g_line_base_amount - l_sum_dist_base_amount);

      x_corr_dist_tab(l_rounding_index).rounding_amt := g_line_base_amount - l_sum_dist_base_amount;

   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Corr_Dist_Proration_Info(-)');
   END IF;


EXCEPTION
WHEN others then
    If (SQLCODE <> -20001) Then
      fnd_message.set_name('SQLAP','AP_DEBUG');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
      fnd_message.set_token('PARAMETERS',
           ' corrected_invoice_id = '||to_char(x_corrected_invoice_id)
	   ||', corrected_line_number = '||to_char(x_corrected_line_number)
	   ||', correction quantity ='||to_char(x_correction_quantity)
	   ||', correction amount = '||to_char(x_correction_amount)
	   ||', correction price = '||to_char(x_correction_price)
	   ||', correction type = '||x_correction_type);
      fnd_message.set_token('DEBUG_INFO',l_debug_info);
    End if;
    --Clean up the PL/SQL tables on error
    x_corr_dist_tab.delete;

    app_exception.raise_exception;

END Get_Corr_Dist_Proration_Info;



PROCEDURE Update_Corr_Po_Shipments_Dists(
		    X_Corr_Dist_Tab    IN  CORR_DIST_TAB_TYPE,
		    X_Po_Line_Location_Id IN NUMBER,
    		    X_Quantity             IN  NUMBER,
		    X_Amount               IN  NUMBER,
                    X_Correction_Type  IN  VARCHAR2,
		    X_Uom_Lookup_Code  IN  VARCHAR2,
		    X_Calling_Sequence IN  VARCHAR2) IS

i			  NUMBER;
l_po_ap_dist_rec          PO_AP_DIST_REC_TYPE;
l_po_ap_line_loc_rec      PO_AP_LINE_LOC_REC_TYPE;
l_debug_info              VARCHAR2(2000);
current_calling_sequence  VARCHAR2(2000);
l_api_name    		  VARCHAR2(50);
l_return_status                VARCHAR2(100);
l_msg_data                     VARCHAR2(4000);

BEGIN

   l_api_name := 'Update_Corr_Po_Shipments_Dists';

   current_calling_sequence := 'Update_Corr_Po_Shipments_Dists<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Update_Corr_Po_Distributions(+)');
   END IF;

   l_debug_info := 'Create l_po_ap_dist_rec object';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   l_po_ap_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

   l_debug_info := 'Create l_po_ap_line_loc_rec object and populate the data';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   IF (x_correction_type = 'QTY_CORRECTION') THEN

      l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                 p_po_line_location_id => x_po_line_location_id,
                                 p_uom_code            => x_uom_lookup_code,
                                 p_quantity_billed     => x_quantity,
                                 p_amount_billed       => NULL,
                                 p_quantity_financed   => NULL,
                                 p_amount_financed     => NULL,
                                 p_quantity_recouped   => NULL,
                                 p_amount_recouped     => NULL,
                                 p_retainage_withheld_amt => NULL,
                                 p_retainage_released_amt => NULL
                                );

   ELSIF (x_correction_type = 'PRICE_CORRECTION') THEN

      l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                 p_po_line_location_id => x_po_line_location_id,
                                 p_uom_code            => x_uom_lookup_code,
                                 p_quantity_billed     => NULL,
                                 p_amount_billed       => NULL,
                                 p_quantity_financed   => NULL,
                                 p_amount_financed     => NULL,
                                 p_quantity_recouped   => NULL,
                                 p_amount_recouped     => NULL,
                                 p_retainage_withheld_amt => NULL,
                                 p_retainage_released_amt => NULL
                                );

   END IF;


   l_debug_info := 'Call PO api to update po_distributions and po_shipments table'
		   ||' with quantity/amount billed information.';

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   FOR i in nvl(x_corr_dist_tab.first,0)..nvl(x_corr_dist_tab.last,0) LOOP

     IF (x_corr_dist_tab.exists(i)) THEN

        IF (x_correction_type = 'PRICE_CORRECTION') THEN

	   l_po_ap_dist_rec.add_change(p_po_distribution_id => x_corr_dist_tab(i).po_distribution_id,
                                p_uom_code           => x_uom_lookup_code,
                                p_quantity_billed    => NULL,
                                p_amount_billed      => x_corr_dist_tab(i).amount,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => NULL,
                                p_amount_recouped    => NULL,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);

        ELSIF (x_correction_type = 'QTY_CORRECTION') THEN

	   l_po_ap_dist_rec.add_change(p_po_distribution_id => x_corr_dist_tab(i).po_distribution_id,
                                p_uom_code           => x_uom_lookup_code,
                                p_quantity_billed    => x_corr_dist_tab(i).corrected_quantity,
                                p_amount_billed      => x_corr_dist_tab(i).amount,
                                p_quantity_financed  => NULL,
                                p_amount_financed    => NULL,
                                p_quantity_recouped  => NULL,
                                p_amount_recouped    => NULL,
                                p_retainage_withheld_amt => NULL,
                                p_retainage_released_amt => NULL);

        END IF;

     END IF;

   END LOOP;

   l_debug_info := 'Call the PO_AP_INVOICE_MATCH_GRP to update the Po Distributions and Po Line Locations';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   PO_AP_INVOICE_MATCH_GRP.Update_Document_Ap_Values(
                                        P_Api_Version => 1.0,
                                        P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
                                        P_Dist_Changes_Rec     => l_po_ap_dist_rec,
                                        X_Return_Status        => l_return_status,
                                        X_Msg_Data             => l_msg_data);


   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Update_Corr_Po_Shipments_Dists(-)');
   END IF;


EXCEPTION
WHEN others then
    If (SQLCODE <> -20001) Then
        fnd_message.set_name('SQLAP','AP_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS',
                  ' po_distribution_id = '||to_char(x_corr_dist_tab(i).po_distribution_id)
                  ||', correction_type = '||x_correction_type);
        fnd_message.set_token('DEBUG_INFO',l_debug_info);
    End if;

    app_exception.raise_exception;

END Update_Corr_Po_Shipments_Dists;



PROCEDURE Update_Corr_Po_Line_Locations(
			x_po_line_location_id  IN NUMBER,
			x_quantity	       IN NUMBER,
			x_amount	       IN NUMBER,
			x_correction_type      IN VARCHAR2,
			x_uom_lookup_code      IN VARCHAR2,
			x_calling_sequence     IN VARCHAR2) IS

l_debug_info 	VARCHAR2(2000);
current_calling_sequence	VARCHAR2(2000);
l_api_name      VARCHAR2(50);

BEGIN

   l_api_name := 'Update_Corr_Po_Line_Locations';
   current_calling_sequence := ' Update_Corr_Po_Line_Locations<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Update_Corr_Po_Line_Locations(+)');
   END IF;

   l_debug_info := 'Call PO api to update the po_line_location with quantity/amount billed
   		    information';

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   IF (x_correction_type = 'QTY_CORRECTION') THEN

      RCV_BILL_UPDATING_SV.ap_update_po_line_locations(
      		x_po_line_location_id	=> x_po_line_location_id,
      		x_quantity_billed => x_quantity,
      		x_uom_lookup_code => x_uom_lookup_code,
      		x_amount_billed   => NULL,
      		x_matching_basis  => 'QUANTITY');

   END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Update_Corr_Po_Line_Locations(-)');
   END IF;


EXCEPTION
WHEN others then
    If (SQLCODE <> -20001) Then
        fnd_message.set_name('SQLAP','AP_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS',
                    '  po_line_location_id = '||to_char(x_po_line_location_id)
                  ||', quantity = '|| to_char(x_quantity)
                  ||', amount = '|| to_char(x_amount)
                  ||', correction_type = '||x_correction_type);
        fnd_message.set_token('DEBUG_INFO',l_debug_info);
    End if;
    app_exception.raise_exception;

END Update_Corr_Po_Line_Locations;


PROCEDURE Insert_Corr_Invoice_Line(x_invoice_id            IN NUMBER,
				   x_invoice_line_number   IN NUMBER,
				   x_corrected_invoice_id  IN NUMBER,
				   x_corrected_line_number IN NUMBER,
				   x_quantity     	   IN NUMBER,
				   x_amount       	   IN NUMBER,
				   x_unit_price   	   IN NUMBER,
				   x_correction_type	   IN VARCHAR2,
				   x_final_match_flag	   IN VARCHAR2,
				   x_po_distribution_id    IN NUMBER,
				   x_retained_amount	   IN NUMBER DEFAULT NULL,
				   x_calling_sequence      IN VARCHAR2 ) IS

l_debug_info	VARCHAR2(2000);
current_calling_sequence   VARCHAR2(2000);
l_api_name	VARCHAR2(50);

BEGIN

   l_api_name := 'Insert_Corr_Invoice_Line';

   current_calling_sequence := 'Insert_Corr_Invoice_Line<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Insert_Corr_Invoice_Line(+)');
   END IF;

   INSERT INTO AP_INVOICE_LINES(INVOICE_ID,
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
			     --	USSGL_TRANSACTION_CODE,- Bug 4277744
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
   				/* OPEN ISSUE 1*/
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
				RETAINED_AMOUNT,
				RETAINED_AMOUNT_REMAINING,
				--ETAX: Invwkb
				SHIP_TO_LOCATION_ID,
				PRIMARY_INTENDED_USE,
				PRODUCT_FISC_CLASSIFICATION,
				TRX_BUSINESS_CATEGORY,
				PRODUCT_TYPE,
				PRODUCT_CATEGORY,
				USER_DEFINED_FISC_CLASS,
				PAY_AWT_GROUP_ID
				)
			SELECT  x_invoice_id,			--invoice_id
				x_invoice_line_number,		--line_number
				'ITEM',				--line_type_lookup_code
				ail.requester_id,		--requester_id
				ail.description,		--description
				'HEADER CORRECTION',		--line_source
				ail.org_id,			--org_id
				ail.inventory_item_id,		--inventory_item_id
				ail.item_description,		--item_description
				ail.serial_number,		--serial_number
				ail.manufacturer,		--manufacturer
				ail.model_number,		--model_number
				'D',				--generate_dists
				x_correction_type,		--match_type
				NULL,				--distribution_set_id
				ail.account_segment,		--account_segment
				ail.balancing_segment,		--balancing_segment
				ail.cost_center_segment,	--cost_center_segment
				ail.overlay_dist_code_concat,	--overlay_dist_code_concat
				ail.default_dist_ccid,		--default_dist_ccid
				'N',				--prorate_across_all_items
				NULL,				--line_group_number
				g_accounting_date,		--accounting_date
				g_period_name,			--period_name
				'N',				--deferred_acctg_flag
				NULL,                           --def_acctg_start_date
                                NULL,                           --def_acctg_end_date
                                NULL,                           --def_acctg_number_of_periods
                                NULL,                           --def_acctg_period_type
                                g_set_of_books_id,              --set_of_books_id
                                x_amount,			--amount
                                AP_UTILITIES_PKG.Ap_Round_Currency(
                                   NVL(X_AMOUNT, 0) * G_EXCHANGE_RATE,
                                        G_BASE_CURRENCY_CODE),  --base_amount
                                NULL,                           --rounding_amount
                                x_quantity,                     --quantity_invoiced
                                ail.unit_meas_lookup_code,	--unit_meas_lookup_code
                                x_unit_price,			--unit_price
                                decode(g_approval_workflow_flag,'Y'
                                      ,'REQUIRED','NOT REQUIRED'),--wf_approval_status
                             -- Removed for bug 4277744
                             -- g_ussgl_transaction_code,	--ussgl_transaction_code
                                'N',				--discarded_flag
                                NULL,				--original_amount
                                NULL,				--original_base_amount
                                NULL,				--original_rounding_amt
                                'N',				--cancelled_flag
                                g_income_tax_region,		--income_tax_region
                                pll.type_1099,			--type_1099
                                NULL,                           --stat_amount
                                NULL,                           --prepay_invoice_id
                                NULL,                           --prepay_line_number
                                NULL,                           --invoice_includes_prepay_flag
                                x_corrected_invoice_id,		--corrected_invoice_id
                                x_corrected_line_number,	--corrected_line_number
                                ail.po_header_id,		--po_header_id
                                ail.po_line_id,			--po_line_id
                                ail.po_release_id,		--release_id
                                ail.po_line_location_id,	--po_line_location_id
                                nvl(ail.po_distribution_id,
                                    x_po_distribution_id),	--po_distribution_id
                                NULL,				--rcv_transaction_id
                                x_final_match_flag,		--final_match_flag
                                ail.assets_tracking_flag,	--assets_tracking_flag
                                ail.asset_book_type_code,	--asset_book_type_code
                                ail.asset_category_id,		--asset_category_id
                                ail.project_id,			--project_id
                                ail.task_id,			--task_id
                                ail.expenditure_type,		--expenditure_type
                                ail.expenditure_item_date,	--expenditure_item_date
                                ail.expenditure_organization_id, --expenditure_organization_id
                                decode(ail.project_id,'','',
                                      decode(x_quantity,'',(ail.pa_quantity*x_amount/ail.amount),
                                      	     x_quantity)),      --pa_quantity
                                NULL,				--pa_cc_ar_invoice_id
                                NULL,				--pa_cc_ar_invoice_line_num
                                NULL,				--pa_cc_processed_code
                                ail.award_id,			--award_id
                                g_awt_group_id,			--awt_group_id
                                ail.reference_1,		--reference_1
                                ail.reference_2,		--reference_2
                                ail.receipt_verified_flag,	--receipt_verified_flag
                                ail.receipt_required_flag,	--receipt_required_flag
                                ail.receipt_missing_flag,	--receipt_missing_flag
                                ail.justification,		--ail.justification
                                ail.expense_group,		--ail.expense_group
                                ail.start_expense_date,		--start_expense_date
                                ail.end_expense_date,		--end_expense_date
                                ail.receipt_currency_code,	--receipt_currency_code
                                ail.receipt_conversion_rate,	--receipt_conversion_rate
                                ail.receipt_currency_amount,	--receipt_currency_amount
                                ail.daily_amount,		--daily_amount
                                ail.web_parameter_id,		--web_parameter_id
                                ail.adjustment_reason,		--adjustment_reason
                                ail.merchant_document_number,	--merchant_document_number
                                ail.merchant_name,		--merchant_name
                                ail.merchant_reference,		--merchant_reference
                                ail.merchant_tax_reg_number,	--merchant_tax_reg_number
                                ail.merchant_taxpayer_id,	--merchant_taxpayer_id
                                ail.country_of_supply,		--country_of_supply
                                ail.credit_card_trx_id,		--credit_card_trx_id
                                ail.company_prepaid_invoice_id, --cpmany_prepaid_invoice_id
                                ail.cc_reversal_flag,		--cc_reversal_flag
                                ail.attribute_category,		--attribute_category
 	      		    	ail.attribute1,			--attribute1
 	      		    	ail.attribute2,			--attribute2
 	      		    	ail.attribute3,			--attribute3
 	      		    	ail.attribute4,			--attribute4
 	      		    	ail.attribute5,			--attribute5
 	      		    	ail.attribute6,			--attribute6
 	      		    	ail.attribute7,			--attribute7
 	      		    	ail.attribute8,			--attribute8
 	      		    	ail.attribute9,			--attribute9
 	      		    	ail.attribute10,		--attribute10
 	      		    	ail.attribute11,		--attribute11
 	      		    	ail.attribute12,		--attribute12
 	      		    	ail.attribute13,		--attribute13
 	      		    	ail.attribute14,		--attribute14
 	      		        ail.attribute15,		--attribute15
 	      		        /*OPEN ISSUE 1*/
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
      				sysdate,			--creation_date
      				g_user_id,			--created_by
      				g_user_id,			--last_updated_by
      				sysdate,			--last_update_date
      				g_login_id,			--user_login_id
      				NULL,				--program_application_id
      				NULL,				--program_id
      				NULL,				--program_update_date
      				NULL,				--request_id
				x_retained_amount,		--retained_amount
				(-x_retained_amount),		--retained_amount_remaining
			        --ETAX: Invwkb
				PLL.SHIP_TO_LOCATION_ID,         --ship_to_location_id
				AIL.PRIMARY_INTENDED_USE,        --primary_intended_use
                                AIL.PRODUCT_FISC_CLASSIFICATION, --product_fisc_classification
			        G_TRX_BUSINESS_CATEGORY,         --trx_business_category
			        AIL.PRODUCT_TYPE,                --product_type
			        AIL.PRODUCT_CATEGORY,            --product_category
			        AIL.USER_DEFINED_FISC_CLASS,      --user_defined_fisc_class
					g_pay_awt_group_id			--pay_awt_group_id   bug8222382
			FROM  ap_invoices ai,
			      ap_invoice_lines ail,
			      po_line_locations_ap_v pll
			WHERE ai.invoice_id = x_corrected_invoice_id
			AND   ail.invoice_id = ai.invoice_id
			AND   ail.line_number = x_corrected_line_number
			AND   pll.line_location_id = ail.po_line_location_id;

    g_max_invoice_line_number := g_max_invoice_line_number + 1;


    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Insert_Corr_Invoice_Line(-)');
    END IF;


EXCEPTION
    WHEN others then
        If (SQLCODE <> -20001) Then
            fnd_message.set_name('SQLAP','AP_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
            fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
                  ' invoice_id = '||to_char(x_invoice_id)
                ||', invoice_line_number = ' ||to_char(x_invoice_line_number)
                ||', corrected_invoice_id = '||to_char(x_corrected_invoice_id)
                ||', corrected_line_number = '||to_char(x_corrected_line_number)
                ||', quantity = '||to_char(x_quantity)
                ||', amount = '||to_char(x_amount)
                ||', unit_price = '||to_char(x_unit_price)
                ||', correction_type = '||x_correction_type
                ||', final_match_flag = '||x_final_match_flag
                ||', po_distribution_id = '||to_char(x_po_distribution_id));
            fnd_message.set_token('DEBUG_INFO',l_debug_info);
        End if;
        app_exception.raise_exception;


END Insert_Corr_Invoice_Line;


PROCEDURE Insert_Corr_Invoice_Dists(x_invoice_id          IN NUMBER,
			     	    x_invoice_line_number IN NUMBER,
				    x_corrected_invoice_id IN NUMBER,
			     	    x_corr_dist_tab       IN OUT NOCOPY CORR_DIST_TAB_TYPE,
			     	    x_correction_type     IN VARCHAR2,
			     	    x_final_match_flag    IN VARCHAR2,
			     	    x_total_amount     	  IN NUMBER,
			     	    x_calling_sequence    IN VARCHAR2) IS

 i		NUMBER;
 l_distribution_line_number  ap_invoice_distributions.distribution_line_number%type := 1;
 l_debug_info  VARCHAR2(2000);
 current_calling_sequence VARCHAR2(2000);
 l_api_name    VARCHAR2(50);

BEGIN

   l_api_name := 'Insert_Corr_Invoice_Dists';

   current_calling_sequence := 'Insert_Corr_Invoice_Dists<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Insert_Corr_Invoice_Dists(+)');
   END IF;

   FOR i in NVL(x_corr_dist_tab.FIRST,0) .. NVL(x_corr_dist_tab.LAST,0) LOOP

     IF (x_corr_dist_tab.exists(i)) THEN

   	INSERT INTO AP_INVOICE_DISTRIBUTIONS(
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
                     --	ussgl_transaction_code, - Bug 4277744
                     --	ussgl_trx_code_context, - Bug 4277744
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
               	        /*OPEN ISSUE 1*/
              	        /*global_attribute_category,
              	         global_attribute1,
                         global_attribute2,*/
			 --bugfix:4674194
                         global_attribute3,
                         /*global_attribute4,
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
			 --ETAX:Invwkb
			 intended_use ,
			 accrual_posted_flag,
			 cash_posted_flag,
			 --Freight and Special Charges
			 rcv_charge_addition_flag,
			 pay_awt_group_id
			 --bug8222382
			 )
      		  SELECT g_batch_id,		        --batch_id
      		         x_invoice_id,	                --invoice_id
      		 	 x_invoice_line_number,	        --invoice_line_number
      			 x_corr_dist_tab(i).invoice_distribution_id, --invoice_distribution_id
      			 l_distribution_line_number,    --distribution_line_number
      			 decode(x_correction_type,
      			    'PRICE_CORRECTION','IPV',
      			    'QTY_CORRECTION',aid.line_type_lookup_code), --line_type_lookup_code
      			 ail.description, 	        --description
      			 x_correction_type,	        --dist_match_type
      			 'PERMANENT',		        --distribution_class
      			 ail.org_id,		        --org_id
      			 x_corr_dist_tab(i).dist_ccid,  --dist_code_combination_id
                         ail.accounting_date,		--accounting_date
      			 ail.period_name, 		--period_name
      			 NULL,				--amount_to_post
      			 NULL,				--base_amount_to_post
      			 NULL,				--posted_amount
      			 NULL,				--posted_base_amount
      			 NULL,				--je_batch_id
      			 NULL,				--cash_je_batch_id
      			 'N',				--posted_flag
      			 NULL,				--accounting_event_id
      			 NULL,				--upgrade_posted_amt
      			 NULL,				--upgrade_base_posted_amt
      		         g_set_of_books_id,		--set_of_books_id
      			 x_corr_dist_tab(i).amount,	--amount
      			 x_corr_dist_tab(i).base_amount,--base_amount
			 x_corr_dist_tab(i).rounding_amt,--rounding_amount
      			 NULL,				--match_status_flag
      			 'N',				--encumbered_flag
      			 NULL,				--packet_id
                      -- Removed for bug 4277744
      		      -- ail.ussgl_transaction_code,	--ussgl_transaction_code
      		      -- NULL,				--ussgl_trx_code_context
      			 'N',				--reversal_flag
      			 NULL,				--parent_reversal_id
      			 'N',				--cancellation_flag
      			 DECODE(ail.type_1099,'','',ail.income_tax_region), --income_tax_region
      			 ail.type_1099, 		--type_1099
      			 NULL,				--stat_amount
      			 NULL,				--charge_applicable_to_dist_id
      			 NULL,				--prepay_amount_remaining
      			 NULL,				--prepay_distribution_id
      			 ail.corrected_inv_id,		--parent_invoice_id
      			 x_corr_dist_tab(i).corrected_inv_dist_id, --corrected_invoice_dist_id
      			 x_corr_dist_tab(i).corrected_quantity,  --corrected_quantity
      			 NULL,				        --other_invoice_id
      			 x_corr_dist_tab(i).po_distribution_id,	--po_distribution_id
      			 NULL,					--rcv_transaction_id
      			 x_corr_dist_tab(i).unit_price,		--unit_price
      			 aid.matched_uom_lookup_code,		--matched_uom_lookup_code
			 NULL,					--quantity_invoiced
      			 x_final_match_flag,			--final_match_flag
      			 NULL,					--related_id
      			 'U',					--assets_addition_flag
      			 aid.assets_tracking_flag,		--assets_tracking_flag
      			 decode(aid.assets_tracking_flag,'Y',
      			 	ail.asset_book_type_code,NULL), --asset_book_type_code
      			 decode(aid.assets_tracking_flag,'Y',
      			 	ail.asset_category_id,NULL),    --asset_category_id
      			 aid.project_id, 		        --project_id
			 aid.task_id,			        --task_id
      			 aid.expenditure_type,		        --expenditure_type
      			 aid.expenditure_item_date,	        --expenditure_item_date
  	 	         aid.expenditure_organization_id,       --expenditure_organization_id
      			 decode(aid.project_id,'','',
			   x_corr_dist_tab(i).pa_quantity),     --pa_quantity
      			 decode(aid.project_id,NULL,'E',
			        decode(pd.destination_type_code,'SHOP FLOOR','M',
					'INVENTORY','M','N')),   --pa_addition_flag
      			 NULL,				        --pa_cc_ar_invoice_id
      			 NULL,				        --pa_cc_ar_invoice_line_num
      			 NULL,				        --pa_cc_processed_code
      			 aid.award_id, 	  		        --award_id
      			 NULL,				        --gms_burdenable_raw_cost
      			 NULL,				        --awt_flag
      			 decode(g_system_allow_awt_flag,'Y',
      			        decode(g_site_allow_awt_flag,'Y',
				       ail.awt_group_id,NULL),
      			        NULL), 			        --awt_group_id
      			 NULL,  			        --awt_tax_rate_id
      			 NULL,					--awt_gross_amount
      			 NULL,					--awt_invoice_id
      			 NULL,					--awt_origin_group_id
      			 NULL,					--awt_invoice_payment_id
      			 NULL,					--awt_withheld_amt
      			 'N',					--inventory_transfer_status
      			 ail.reference_1,			--reference_1
      			 ail.reference_2,			--reference_2
     			 ail.receipt_verified_flag,		--receipt_verified_flag
      		         ail.receipt_required_flag,		--receipt_required_flag
      			 ail.receipt_missing_flag,		--receipt_missing_flag
      			 ail.justification,			--justification
      			 ail.expense_group,			--expense_group
       			 ail.start_expense_date,		--start_expense_date
      			 ail.end_expense_date,			--end_expense_date
    			 ail.receipt_currency_code,		--receipt_currency_code
      			 ail.receipt_conversion_rate,		--receipt_conversion_rate
       			 ail.receipt_currency_amount,		--receipt_currency_amount
      			 ail.daily_amount,			--daily_amount
    			 ail.web_parameter_id,			--web_parameter_id
      			 ail.adjustment_reason,			--adjustment_reason
			 ail.merchant_document_number,		--merchant_document_number
      			 ail.merchant_name,			--merchant_name
    			 ail.merchant_reference,		--merchant_reference
      			 ail.merchant_tax_reg_number,		--merchant_tax_reg_number
       			 ail.merchant_taxpayer_id, 	        --merchant_taxpayer_id
      			 ail.country_of_supply,			--country_of_supply
    			 ail.credit_card_trx_id,		--credit_card_trx_id
      			 ail.company_prepaid_invoice_id,	--company_prepaid_invoice_id
       			 ail.cc_reversal_flag,			--cc_reversal_flag
       			 aid.attribute_category,		--attribute_category
 	      		 aid.attribute1,			--attribute1
 	      		 aid.attribute2,			--attribute2
 	      		 aid.attribute3,			--attribute3
 	      		 aid.attribute4,			--attribute4
 	      		 aid.attribute5,			--attribute5
 	      		 aid.attribute6,			--attribute6
 	      		 aid.attribute7,			--attribute7
 	      		 aid.attribute8,			--attribute8
 	      		 aid.attribute9,			--attribute9
 	      		 aid.attribute10,			--attribute10
 	      		 aid.attribute11,			--attribute11
 	      		 aid.attribute12,			--attribute12
 	      		 aid.attribute13,			--attribute13
 	      		 aid.attribute14,			--attribute14
 	      		 aid.attribute15,			--attribute15
 	      		 /* X_GLOBAL_ATTRIBUTE_CATEGORY,
			 X_GLOBAL_ATTRIBUTE1,
      			 X_GLOBAL_ATTRIBUTE2,*/
			 --bugfix:4674194
			 decode(ap_extended_withholding_pkg.ap_extended_withholding_option,
			        'Y',ail.ship_to_location_id,''),
      			 /*X_GLOBAL_ATTRIBUTE4,
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
      			 ail.created_by,		--created_by
      			 sysdate,			--creation_date
      			 ail.last_updated_by,		--last_updated_by
      			 sysdate,			--last_update_date
      			 ail.last_update_login,		--last_update_login
      			 NULL,				--program_application_id
      			 NULL,				--program_id
      			 NULL,				--program_update_date
      			 NULL,				--request_id
			 --ETAX: Invwkb
			 aid.intended_use,	        --intended_use
			 'N',				--accrual_posted_flag
			 'N',				--cash_posted_flag
			 'N',				--rcv_charge_addition_flag
			 decode(g_system_allow_awt_flag,'Y',
      			        decode(g_site_allow_awt_flag,'Y',
				       ail.pay_awt_group_id,NULL),
      			        NULL) 			        --pay_awt_group_id    bug8222382
   		    FROM ap_invoice_lines ail,
   	     		 ap_invoice_distributions aid,
			 po_distributions pd
   		    WHERE ail.invoice_id = x_invoice_id
   	  	    AND ail.line_number = x_invoice_line_number
   	  	    AND aid.invoice_id = ail.corrected_inv_id
   	  	    AND aid.invoice_line_number = ail.corrected_line_number
   	  	    AND aid.invoice_distribution_id = x_corr_dist_tab(i).corrected_inv_dist_id
		    AND aid.po_distribution_id = pd.po_distribution_id;

        --Bugfix:4674635
        l_debug_info := 'Call the AP_EXTENDED_MATCH to populate global attributes';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        IF (AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_ACTIVE) THEN
            AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_MATCH(
                                P_Credit_Id    => X_invoice_id,
                                P_Invoice_Id   => X_corrected_invoice_id,
                                P_Inv_Line_Num => X_invoice_line_number,
				P_Distribution_id => x_corr_dist_tab(i).invoice_distribution_id,
				P_Parent_Dist_Id  => x_corr_dist_tab(i).corrected_inv_dist_id);

        END IF;

        l_distribution_line_number := l_distribution_line_number + 1;

     END IF; /*(x_corr_dist_tab.exists(i))  */

   END LOOP;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Insert_Corr_Invoice_Dists(-)');
   END IF;


EXCEPTION
    WHEN others then
        If (SQLCODE <> -20001) Then
            fnd_message.set_name('SQLAP','AP_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
            fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
                  ' invoice_id = '||to_char(x_invoice_id)
                ||', invoice_line_number =' ||to_char(x_invoice_line_number)
                ||', correction_type = '||x_correction_type
                ||', final_match_flag = '||x_final_match_flag
                ||', total_amount = '||to_char(x_total_amount));
            fnd_message.set_token('DEBUG_INFO',l_debug_info);
        End if;

	--Clean up the PL/SQL tables on error
        x_corr_dist_tab.delete;

        app_exception.raise_exception;

END Insert_Corr_Invoice_Dists;


/*=============================================================================
			       QUICK MATCH
==============================================================================*/


PROCEDURE Quick_Match_Line_Generation(
		x_invoice_id  	   IN	NUMBER,
		x_po_header_id	   IN	NUMBER,
		x_match_option	   IN	VARCHAR2,
	        x_invoice_amount   IN	NUMBER,
       	        x_calling_sequence IN 	VARCHAR2) IS

l_shipment_table		T_SHIPMENT_TABLE;
current_calling_sequence	VARCHAR2(2000);
l_debug_info			VARCHAR2(2000);
l_api_name			VARCHAR2(50);

BEGIN

   l_api_name := 'Quick_Match_Line_Generation';

   current_calling_sequence := 'Quick_Match_PO_RCV<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Quick_Match_Line_Generation(+)');
   END IF;

   l_debug_info := 'Call Get_Info';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   Get_Info(x_invoice_id => x_invoice_id,
   	    x_calling_sequence => current_calling_sequence);

   IF g_invoice_type_lookup_code = 'RETAINAGE RELEASE' THEN

      l_debug_info := 'Call Generate_Release_Lines';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      Generate_Release_Lines (p_po_header_id     => x_po_header_id,
                              p_invoice_id       => x_invoice_id,
                              p_release_amount   => g_release_amount_net_of_tax,
                              x_calling_sequence => current_calling_sequence);

   ELSE

   l_debug_info := 'Call Get_Shipment_List_For_QM';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   Get_Shipment_List_For_QM(X_Invoice_Id => x_invoice_id,
   			    X_Po_Header_Id => x_po_header_id,
   			    X_Match_Option => x_match_option,
			    X_Match_Amount => x_invoice_amount,
   			    X_Shipment_Table => l_shipment_table,
   			    X_Calling_Sequence => current_calling_sequence);

   l_debug_info := 'Call Generate_Lines_For_Quickmatch';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   Generate_Lines_for_Quickmatch(X_Invoice_Id  => x_invoice_id,
	    			 X_Match_Option => x_match_option,
   				 X_Shipment_Table => l_shipment_table,
   				 X_Calling_Sequence => current_calling_sequence);


  --Clean up the PL/SQL table
  l_shipment_table.delete;

  END IF;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Quick_Match_Line_Generation(-)');
   END IF;

EXCEPTION
  WHEN others then
     If (SQLCODE <> -20001) Then
        fnd_message.set_name('SQLAP','AP_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS',
                  ' invoice_id = '||to_char(x_invoice_id)
                ||', Po header id = '||to_char(x_po_header_id)
                ||', match option = '||x_match_option
                ||', invoice_amount = '||to_char(x_invoice_amount));
        fnd_message.set_token('DEBUG_INFO',l_debug_info);
     End if;
  --Clean up the PL/SQL tables on error
  l_shipment_table.delete;

  app_exception.raise_exception;

END Quick_Match_Line_Generation;


PROCEDURE Get_Shipment_List_For_QM(X_Invoice_Id	      IN	 NUMBER,
				   X_Po_Header_Id     IN	 NUMBER,
				   X_Match_Option     IN         VARCHAR2,
				   X_Match_Amount     IN	 NUMBER,
				   X_Shipment_Table   OUT NOCOPY T_SHIPMENT_TABLE,
				   X_Calling_Sequence IN 	 VARCHAR2) IS

CURSOR PO_Shipment_list_cursor IS
 SELECT pll.line_location_id,
 	pll.po_line_id,
 	pll.po_release_id,
 	decode(pll.matching_basis_lookup_code,'AMOUNT',
	        (pll.amount - decode(pll.shipment_type,'PREPAYMENT',
		     	             nvl(pll.amount_financed,0),
	 	                     nvl(pll.amount_billed,0)
                                    )
                 - nvl(pll.amount_cancelled,0)
                ),
	        ap_utilities_pkg.ap_round_currency(
				  		   (pll.quantity - decode(pll.shipment_type,'PREPAYMENT',
		  	         		    			  nvl(pll.quantity_financed,0),
				 		    			  nvl(pll.quantity_billed,0)
		    				   			 )
						    - nvl(pll.quantity_cancelled,0)
						   ) * pll.price_override, g_invoice_currency_code
						  )
              ) amount_available,
 	pll.item_id,
 	pll.unit_meas_lookup_code,
 	pll.price_override,
 	pll.item_description,
 	msi.asset_category_id,
     -- pll.ussgl_transaction_code, - Bug 4277744
 	pll.type_1099,
	pll.matching_basis_lookup_code,
 	decode(g_transfer_flag,'Y',pll.attribute_category,NULL) attribute_category,
 	decode(g_transfer_flag,'Y',pll.attribute1,NULL) attribute1,
 	decode(g_transfer_flag,'Y',pll.attribute2,NULL) attribute2,
 	decode(g_transfer_flag,'Y',pll.attribute3,NULL) attribute3,
 	decode(g_transfer_flag,'Y',pll.attribute4,NULL) attribute4,
 	decode(g_transfer_flag,'Y',pll.attribute5,NULL) attribute5,
  	decode(g_transfer_flag,'Y',pll.attribute6,NULL) attribute6,
  	decode(g_transfer_flag,'Y',pll.attribute7,NULL) attribute7,
  	decode(g_transfer_flag,'Y',pll.attribute8,NULL) attribute8,
  	decode(g_transfer_flag,'Y',pll.attribute9,NULL) attribute9,
  	decode(g_transfer_flag,'Y',pll.attribute10,NULL) attribute10,
  	decode(g_transfer_flag,'Y',pll.attribute11,NULL) attribute11,
  	decode(g_transfer_flag,'Y',pll.attribute12,NULL) attribute12,
  	decode(g_transfer_flag,'Y',pll.attribute13,NULL) attribute13,
  	decode(g_transfer_flag,'Y',pll.attribute14,NULL) attribute14,
  	decode(g_transfer_flag,'Y',pll.attribute15,NULL) attribute15
	--ETAX: Invwkb
	--OPEN ISSUE 1
	,pll.ship_to_location_id	ship_to_location_id
	,decode(pll.matching_basis_lookup_code,'AMOUNT',
	        (pll.amount - decode(pll.shipment_type,'PREPAYMENT',
		     	             nvl(pll.amount_financed,0),
	 	                     nvl(pll.amount_billed,0)
                                    )
                 - nvl(pll.amount_cancelled,0)),
          (pll.quantity - decode(pll.shipment_type,'PREPAYMENT',
		  	         nvl(pll.quantity_financed,0),
				 nvl(pll.quantity_billed,0)
		    	        )- nvl(pll.quantity_cancelled,0)) * decode(pll.price_override,0,1,pll.price_override)) amount_available_unrounded /*bug 8973086*//*9559298*/
	/*
	pll.primary_intended_use primary_intended_use,
	pll.product_fisc_classification product_fisc_classification,
	pll.product_type  product_type,
	pll.product_category product_category,
	pll.user_defined_fisc_class user_defined_fisc_class
	*/
 FROM po_line_locations_ap_v pll,
      mtl_system_items msi
 WHERE  pll.po_header_id = x_po_header_id
 AND msi.inventory_item_id(+)  = pll.item_id
 AND msi.organization_id(+) = g_inventory_organization_id
 AND pll.match_option = 'P'
 AND pll.closed_code NOT IN ('FINALLY CLOSED') /*, 'CLOSED', 'CLOSED FOR INVOICE')*/ --Bug9323877 --bug 8899681
 --Make sure there is some quantity or amount left to be billed
 --based on the matching_basis of the shipment
 AND ((g_invoice_type_lookup_code <> 'PREPAYMENT'
       and (
            (pll.matching_basis_lookup_code = 'QUANTITY' and
             pll.quantity - nvl(pll.quantity_billed,0) - nvl(pll.quantity_cancelled,0) > 0
            ) or
            (pll.matching_basis_lookup_code = 'AMOUNT' and
	     pll.amount - nvl(pll.amount_billed,0) - nvl(pll.amount_cancelled,0) > 0
	    )
           )
      ) OR
      (g_invoice_type_lookup_code = 'PREPAYMENT'
       and (
            (pll.matching_basis_lookup_code = 'QUANTITY' and pll.shipment_type = 'PREPAYMENT' and
             pll.quantity - nvl(pll.quantity_financed,0) - nvl(pll.quantity_cancelled,0) > 0
            ) or
	    (pll.matching_basis_lookup_code = 'AMOUNT' and pll.shipment_type = 'PREPAYMENT' and
	     pll.amount - nvl(pll.amount_financed,0) - nvl(pll.amount_cancelled,0) > 0
            ) or
	    (pll.matching_basis_lookup_code = 'QUANTITY' and pll.shipment_type <> 'PREPAYMENT' and
	     pll.quantity - nvl(pll.quantity_billed,0) - nvl(pll.quantity_cancelled,0) > 0
	    ) or
	    (pll.matching_basis_lookup_code = 'AMOUNT' and pll.shipment_type <> 'PREPAYMENT' and
	     pll.amount - nvl(pll.amount_billed,0) - nvl(pll.amount_cancelled,0) > 0
	    )
           )
      )
     )
 --make sure the correct shipment type is matched to correct invoice type
 AND
  ((g_invoice_type_lookup_code <> 'PREPAYMENT' and
    pll.shipment_type <> 'PREPAYMENT'
   ) OR
   (g_invoice_type_lookup_code = 'PREPAYMENT' and
    ((pll.payment_type IS NOT NULL and
      pll.shipment_type = 'PREPAYMENT') or
     (pll.payment_type IS NULL)
    )
   )
  )
 ORDER BY pll.line_location_id ;


CURSOR Receipt_Shipment_List_cursor IS
 SELECT rcv.po_line_id,
  	rcv.po_release_id,
 	rcv.po_line_location_id,
 	rcv.rcv_transaction_id,
 	rcv.receipt_uom_lookup_code,
 	rcv.po_uom_lookup_code,
 	rcv.po_unit_price,
 	rcv.item_id,
 	rcv.item_description,
 	msi.asset_category_id,
     -- rsl.ussgl_transaction_code, - Bug 4277744
 	rcv.type_1099,
        rcv.matching_basis_lookup_code,
 	decode(g_transfer_flag,'Y',rsl.attribute_category,NULL) attribute_category,
 	decode(g_transfer_flag,'Y',rsl.attribute1,NULL) attribute1,
 	decode(g_transfer_flag,'Y',rsl.attribute2,NULL) attribute2,
 	decode(g_transfer_flag,'Y',rsl.attribute3,NULL) attribute3,
 	decode(g_transfer_flag,'Y',rsl.attribute4,NULL) attribute4,
 	decode(g_transfer_flag,'Y',rsl.attribute5,NULL) attribute5,
  	decode(g_transfer_flag,'Y',rsl.attribute6,NULL) attribute6,
  	decode(g_transfer_flag,'Y',rsl.attribute7,NULL) attribute7,
  	decode(g_transfer_flag,'Y',rsl.attribute8,NULL) attribute8,
  	decode(g_transfer_flag,'Y',rsl.attribute9,NULL) attribute9,
  	decode(g_transfer_flag,'Y',rsl.attribute10,NULL) attribute10,
  	decode(g_transfer_flag,'Y',rsl.attribute11,NULL) attribute11,
  	decode(g_transfer_flag,'Y',rsl.attribute12,NULL) attribute12,
  	decode(g_transfer_flag,'Y',rsl.attribute13,NULL) attribute13,
  	decode(g_transfer_flag,'Y',rsl.attribute14,NULL) attribute14,
  	decode(g_transfer_flag,'Y',rsl.attribute15,NULL) attribute15
	--ETAX: Invwkb
	--OPEN ISSUE 1
	,rcv.ship_to_location_id        ship_to_location_id
	/*
	rcv.primary_intended_use        primary_intended_use,
	rcv.product_fisc_classification product_fisc_classification,
	rcv.product_type  		product_type,
	rcv.product_category 		product_category,
	rcv.user_defined_fisc_class 	user_defined_fisc_class
	*/
 FROM   po_ap_receipt_match_v rcv,
        mtl_system_items msi,
        rcv_shipment_lines rsl
 WHERE  rcv.po_header_id = x_po_header_id
 AND    msi.inventory_item_id(+) = rcv.item_id
 AND    msi.organization_id(+) = g_inventory_organization_id
 AND    rcv.rcv_shipment_line_id = rsl.shipment_line_id
 AND    rcv.po_match_option = 'R'
 ORDER BY rcv.rcv_transaction_id;

l_available_match_amount      NUMBER := x_match_amount;
l_amount 		      ap_invoice_lines.amount%TYPE;
l_base_amount		      ap_invoice_lines.base_amount%TYPE;
l_quantity 		      ap_invoice_lines.quantity_invoiced%TYPE;
l_po_line_location_id         po_line_locations.line_location_id%TYPE;
l_po_line_id 	              po_lines.po_line_id%TYPE;
l_po_release_id        	      po_releases.po_release_id%TYPE;
l_rcv_transaction_id	      rcv_transactions.transaction_id%TYPE;
l_receipt_uom_lookup_code     rcv_shipment_lines.unit_of_measure%TYPE;
l_po_uom_lookup_code	      po_lines.unit_meas_lookup_code%TYPE;
l_po_unit_price		      po_lines.unit_price%TYPE;
l_available_shipment_amount   po_line_locations.amount%TYPE;
l_item_id 	      	      po_lines.item_id%TYPE;
l_unit_meas_lookup_code       po_lines.unit_meas_lookup_code%TYPE;
l_price_override	      po_line_locations.price_override%TYPE;
l_item_description	      po_lines.item_description%TYPE;
l_asset_category_id	      mtl_system_items.asset_category_id%TYPE;
-- Removed for bug 4277744
-- l_ussgl_transaction_code   po_line_locations.ussgl_transaction_code%TYPE;
l_type_1099		      po_lines.type_1099%TYPE;
l_attribute_category	      po_line_locations.attribute_category%TYPE;
l_attribute1		      po_line_locations.attribute1%TYPE;
l_attribute2		      po_line_locations.attribute2%TYPE;
l_attribute3		      po_line_locations.attribute3%TYPE;
l_attribute4		      po_line_locations.attribute4%TYPE;
l_attribute5		      po_line_locations.attribute5%TYPE;
l_attribute6		      po_line_locations.attribute6%TYPE;
l_attribute7		      po_line_locations.attribute7%TYPE;
l_attribute8		      po_line_locations.attribute8%TYPE;
l_attribute9		      po_line_locations.attribute9%TYPE;
l_attribute10		      po_line_locations.attribute10%TYPE;
l_attribute11		      po_line_locations.attribute11%TYPE;
l_attribute12		      po_line_locations.attribute12%TYPE;
l_attribute13		      po_line_locations.attribute13%TYPE;
l_attribute14		      po_line_locations.attribute14%TYPE;
l_attribute15		      po_line_locations.attribute15%TYPE;
l_invoice_line_number         ap_invoice_lines.line_number%TYPE := 1;
l_index                       po_line_locations.line_location_id%TYPE;
l_conversion_factor	      NUMBER;
l_ordered_qty 		      NUMBER;
l_cancelled_qty		      NUMBER;
l_received_qty  	      NUMBER;
l_corrected_qty 	      NUMBER;
l_delivered_qty 	      NUMBER;
l_transaction_qty 	      NUMBER;
l_billed_qty      	      NUMBER;
l_accepted_qty    	      NUMBER;
l_rejected_qty    	      NUMBER;
l_rect_unit_price   	      po_lines.unit_price%TYPE;
l_max_line_amount	      ap_invoice_lines.amount%TYPE := 0;
l_rounded_index		      po_line_locations.line_location_id%TYPE;
l_sum_prorated_amount	      ap_invoice_lines.amount%TYPE := 0;
l_available_amount	      po_line_locations.amount%TYPE;
l_available_qty		      po_line_locations.quantity%TYPE;
l_invoice_base_amount	      ap_invoice_lines.base_amount%TYPE := 0;
l_sum_line_base_amount	      ap_invoice_lines.base_amount%TYPE := 0;
l_ship_to_location_id         ap_invoice_lines.ship_to_location_id%TYPE;
l_primary_intended_use	      ap_invoice_lines.primary_intended_use%TYPE;
l_product_fisc_classification ap_invoice_lines.product_fisc_classification%TYPE;
l_product_type		      ap_invoice_lines.product_type%TYPE;
l_product_category	      ap_invoice_lines.product_category%TYPE;
l_user_defined_fisc_class     ap_invoice_lines.user_defined_fisc_class%TYPE;
l_amount_ordered              NUMBER;
l_amount_cancelled            NUMBER;
l_amount_delivered            NUMBER;
l_amount_billed               NUMBER;
l_amount_received             NUMBER;
l_amount_corrected            NUMBER;
l_matching_basis	      po_line_locations.matching_basis%TYPE;
l_retained_amount             ap_invoice_lines.retained_amount%TYPE;
l_ret_status                  VARCHAR2(100);
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(250);
l_debug_info        	      VARCHAR2(2000);
current_calling_sequence      VARCHAR2(2000);
l_api_name		      VARCHAR2(50);

--bugfix:5565310
l_ref_doc_application_id      zx_transaction_lines_gt.ref_doc_application_id%TYPE;
l_ref_doc_entity_code         zx_transaction_lines_gt.ref_doc_entity_code%TYPE;
l_ref_doc_event_class_code    zx_transaction_lines_gt.ref_doc_event_class_code%TYPE;
l_ref_doc_line_quantity       zx_transaction_lines_gt.ref_doc_line_quantity%TYPE;
l_po_header_curr_conv_rat     po_headers_all.rate%TYPE;
l_ref_doc_trx_level_type      zx_transaction_lines_gt.ref_doc_trx_level_type%TYPE;
l_po_header_curr_conv_rate    po_headers_all.rate%TYPE;
l_uom_code                    mtl_units_of_measure.uom_code%TYPE;
l_ref_doc_trx_id              po_headers_all.po_header_id%TYPE;
l_error_code                  varchar2(2000);
l_success		      boolean;
l_dummy				number;
-- bug#6977104
l_inv_org_id                  NUMBER;
-- bug 7577673: start
l_allow_tax_code_override     varchar2(10);
l_dflt_tax_class_code         zx_transaction_lines_gt.input_tax_classification_code%type;
-- bug 7577673: end
l_available_shipment_amt_unrnd  po_line_locations.amount%TYPE; --bug 8973086
BEGIN

  l_api_name := 'Get_Shipment_List_For_QuickMatch';

  current_calling_sequence:= 'Get_Shipment_List_For_QuickMatch<-'||x_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Shipment_List_For_QuickMatch(+)');
  END IF;

  IF (x_match_option = 'P') THEN

     OPEN Po_Shipment_List_Cursor;

     LOOP

        l_debug_info := 'Fetch next record of PO_Shipment_List_Cursor';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        FETCH PO_Shipment_List_Cursor INTO l_po_line_location_id,
      					 l_po_line_id,
				         l_po_release_id,
				         l_available_shipment_amount,
				         l_item_id,
				         l_unit_meas_lookup_code,
				         l_price_override,
				         l_item_description,
				         l_asset_category_id,
				      -- l_ussgl_transaction_code, - Bug 4277744
				         l_type_1099,
					 l_matching_basis,
				         l_attribute_category,
				         l_attribute1,
				         l_attribute2,
				         l_attribute3,
				         l_attribute4,
				         l_attribute5,
      				         l_attribute6,
      				         l_attribute7,
      				         l_attribute8,
      				         l_attribute9,
      				         l_attribute10,
      				         l_attribute11,
      				         l_attribute12,
      				         l_attribute13,
      				         l_attribute14,
      				         l_attribute15,
					 l_ship_to_location_id,
					 l_available_shipment_amt_unrnd --bug 8973086
					 ;

       EXIT WHEN (Po_Shipment_List_Cursor%NOTFOUND);    --OR l_available_match_amount = 0);  bug 8899681


       --calculate the amount on each line that will be generated
      /* IF(l_available_shipment_amount >= l_available_match_amount) THEN
               l_amount := l_available_match_amount;
         ELSE
               l_amount := l_available_shipment_amount;
         END IF;*/

        l_amount := l_available_shipment_amount;	--bug 8899681, l_amount should be available shipment amount

       --bugfix:5565310
       l_success := AP_ETAX_UTILITY_PKG.Get_PO_Info(
                          P_Po_Line_Location_Id         => l_po_line_location_id,
                          P_PO_Distribution_Id          => null,
                          P_Application_Id              => l_ref_doc_application_id,
                          P_Entity_code                 => l_ref_doc_entity_code,
                          P_Event_Class_Code            => l_ref_doc_event_class_code,
                          P_PO_Quantity                 => l_ref_doc_line_quantity,
                          P_Product_Org_Id              => l_inv_org_id, -- bug#6977104
                          P_Po_Header_Id                => l_ref_doc_trx_id,
                          P_Po_Header_curr_conv_rate    => l_po_header_curr_conv_rate,
                          P_Uom_Code                    => l_uom_code,
			  P_Dist_Qty                    => l_dummy,
			  P_Ship_Price                  => l_dummy,
                          P_Error_Code                  => l_error_code,
                          P_Calling_Sequence            => current_calling_sequence);

-- bug 7577673: start
      ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification
		            (p_ref_doc_application_id           => l_ref_doc_application_id,
		             p_ref_doc_entity_code              => l_ref_doc_entity_code,
		             p_ref_doc_event_class_code         => l_ref_doc_event_class_code,
		             p_ref_doc_trx_id                   => l_ref_doc_trx_id,
		             p_ref_doc_line_id                  => l_po_line_location_id,
		             p_ref_doc_trx_level_type           => 'SHIPMENT',
		             p_vendor_id                        => g_vendor_id,
		             p_vendor_site_id                   => g_vendor_site_id,
		             p_code_combination_id              => g_default_dist_ccid,
		             p_concatenated_segments            => null,
		             p_templ_tax_classification_cd      => null,
		             p_ship_to_location_id              => null,
		             p_ship_to_loc_org_id               => null,
		             p_inventory_item_id                => null,
		             p_item_org_id                      => g_inventory_organization_id,
		             p_tax_classification_code          => g_dflt_tax_class_code,
		             p_allow_tax_code_override_flag     => l_allow_tax_code_override,
		             APPL_SHORT_NAME                    => 'SQLAP',
		             FUNC_SHORT_NAME                    => 'NONE',
		             p_calling_sequence                 => 'AP_ETAX_SERVICES_PKG',
		             p_event_class_code                 => l_ref_doc_event_class_code,
		             p_entity_code                      => 'AP_INVOICES',
		             p_application_id                   => 200,
		             p_internal_organization_id         => g_org_id);
-- bug 7577673: end

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
			  x_tax_classification_code     => l_dflt_tax_class_code);

-- bug 7577673: start
   -- if tax classification code not retrieved from hierarchy
   -- retrieve it from PO
   IF (g_dflt_tax_class_code is null) THEN
       g_dflt_tax_class_code := l_dflt_tax_class_code;
   END IF;
-- bug 7577673: end

       l_debug_info := 'l_po_line_location_id is '||l_po_line_location_id;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       --Bug9559298
       IF(l_price_override = 0) THEN
	    l_quantity := round(l_available_shipment_amt_unrnd,15);
       ELSE
            l_quantity := round(l_available_shipment_amt_unrnd/l_price_override,15); --bug 8973086 replaced l_amount with l_available_shipment_amt_unrnd
       END IF;
       --Bug9559298

       /*l_available_match_amount := l_available_match_amount - l_amount;  */   --bug 8899681

       l_index := l_po_line_location_id;

       X_Shipment_Table(l_index).po_header_id := x_po_header_id;
       X_Shipment_Table(l_index).po_line_id := l_po_line_id;
       X_Shipment_Table(l_index).po_release_id := l_po_release_id;
       X_Shipment_Table(l_index).po_line_location_id := l_po_line_location_id;
       X_Shipment_Table(l_index).uom := l_unit_meas_lookup_code;
       X_Shipment_Table(l_index).unit_price :=  l_price_override;
       X_Shipment_Table(l_index).line_number := l_invoice_line_number;
       X_Shipment_Table(l_index).quantity_invoiced := l_quantity;
       X_Shipment_Table(l_index).amount := l_amount;

       l_debug_info := 'X_Shipment_Table('||l_index||').amount is'||X_Shipment_Table(l_index).amount;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       X_Shipment_Table(l_index).inventory_item_id := l_item_id;
       X_Shipment_Table(l_index).item_description := l_item_description;
       X_Shipment_Table(l_index).asset_category_id := l_asset_category_id;
    -- Removed for bug 4277744
    -- X_Shipment_Table(l_index).ussgl_transaction_code := l_ussgl_transaction_code;
       X_Shipment_Table(l_index).type_1099 := l_type_1099;
       X_Shipment_Table(l_index).attribute_category := l_attribute_category;
       X_Shipment_Table(l_index).attribute1 := l_attribute1;
       X_Shipment_Table(l_index).attribute2 := l_attribute2;
       X_Shipment_Table(l_index).attribute3 := l_attribute3;
       X_Shipment_Table(l_index).attribute4 := l_attribute4;
       X_Shipment_Table(l_index).attribute5 := l_attribute5;
       X_Shipment_Table(l_index).attribute6 := l_attribute6;
       X_Shipment_Table(l_index).attribute7 := l_attribute7;
       X_Shipment_Table(l_index).attribute8 := l_attribute8;
       X_Shipment_Table(l_index).attribute9 := l_attribute9;
       X_Shipment_Table(l_index).attribute10 := l_attribute10;
       X_Shipment_Table(l_index).attribute11 := l_attribute11;
       X_Shipment_Table(l_index).attribute12 := l_attribute12;
       X_Shipment_Table(l_index).attribute13 := l_attribute13;
       X_Shipment_Table(l_index).attribute14 := l_attribute14;
       X_Shipment_Table(l_index).attribute15 := l_attribute15;
       X_Shipment_Table(l_index).ship_to_location_id := l_ship_to_location_id;
       X_Shipment_Table(l_index).primary_intended_use := g_intended_use;
       X_Shipment_Table(l_index).product_fisc_classification := g_product_fisc_class;
       X_Shipment_Table(l_index).product_type := g_product_type;
       X_Shipment_Table(l_index).product_category := g_product_category;
       X_Shipment_Table(l_index).user_defined_fisc_class := g_user_defined_fisc_class;
       X_shipment_Table(l_index).assessable_value := g_assessable_value;
       X_shipment_Table(l_index).tax_classification_code := g_dflt_tax_class_code;

      X_Shipment_Table(l_index).matching_basis  := l_matching_basis;
      X_Shipment_Table(l_index).retained_amount := ap_invoice_lines_utility_pkg.get_retained_amount
			                                        (l_po_line_location_id, l_amount);

       --Get the max of the largest invoice line, to be used for assignment of
       --rounding due to proration.
     /*  IF (l_amount >= l_max_line_amount) THEN

           l_rounded_index := l_po_line_location_id;
           l_max_line_amount := l_amount;

       END IF;*/

         l_invoice_line_number := l_invoice_line_number + 1;
   /*    l_sum_prorated_amount := l_sum_prorated_amount + l_amount;*/  -- bug 8899681

    END LOOP;

    CLOSE PO_Shipment_List_Cursor;

    --If proration resulted in rounding error, then add  the rounding amt
    --onto max of the largest line, index for which was calculated above
    --We need to do the proration rounding only if we exhausted the match amount
    --and not if we exhausted the shipments.
    /*  IF (l_available_match_amount = 0) THEN

        IF (x_match_amount - l_sum_prorated_amount <> 0 and l_rounded_index is not null) THEN

          X_Shipment_Table(l_rounded_index).amount := X_Shipment_Table(l_rounded_index).amount +
      						   (l_available_match_amount - l_sum_prorated_amount);

        END IF;

        END IF;*/  -- bug 8899681

  ELSIF (x_match_option = 'R') THEN

      OPEN Receipt_Shipment_List_Cursor;

      LOOP

	l_debug_info := 'Fetch next record of Receipt_Shipment_List_Cursor';
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

        FETCH Receipt_Shipment_List_Cursor INTO l_po_line_id,
        					l_po_release_id,
        					l_po_line_location_id,
        					l_rcv_transaction_id,
        					l_receipt_uom_lookup_code,
        					l_po_uom_lookup_code,
        					l_po_unit_price,
        					l_item_id,
        					l_item_description,
        					l_asset_category_id,
                                             -- Bug 4277744
        				     -- l_ussgl_transaction_code,
        					l_type_1099,
						l_matching_basis,
        					l_attribute_category,
				         	l_attribute1,
				         	l_attribute2,
				        	l_attribute3,
				        	l_attribute4,
				        	l_attribute5,
      				        	l_attribute6,
      				         	l_attribute7,
      				        	l_attribute8,
      				         	l_attribute9,
      				         	l_attribute10,
      				        	l_attribute11,
      				         	l_attribute12,
      				         	l_attribute13,
      				         	l_attribute14,
      				         	l_attribute15
						--ETAX: Invwkb
						--OPEN ISSUE 1
						,l_ship_to_location_id
						/*
						l_primary_intended_use,
						l_product_fisc_classification,
						l_product_type,
						l_product_category,
						l_user_defined_fisc_class*/
						;

        EXIT WHEN (Receipt_Shipment_List_Cursor%NOTFOUND OR l_available_match_amount = 0);


        IF ((l_receipt_uom_lookup_code <> l_po_uom_lookup_code) AND
                (l_po_uom_lookup_code is not null) AND
                (l_receipt_uom_lookup_code is not null)) THEN
       	    l_debug_info := 'Call PO_UOM_S.PO_UOM_CONVERT to get the conversion
       	 			factor between receipt uom and po uom';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   	    END IF;

            l_conversion_factor := PO_UOM_S.PO_UOM_CONVERT(l_receipt_uom_lookup_code,
           						  l_po_uom_lookup_code,
           						  l_item_id);
            l_rect_unit_price := l_po_unit_price * l_conversion_factor;    --bug8334274

        ELSE

            l_rect_unit_price := l_po_unit_price;

        END IF;


        IF (l_matching_basis = 'QUANTITY') THEN

             ap_matching_utils_pkg.get_receipt_quantities(
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
	      l_received_qty := nvl(l_received_qty,0); --BUG # 8229551

	    /* BUG # 8229551. using l_received_qty instead of l_delivered_qty.
	       because  we can create the invoice once we receive the goods
	       even before delivering the goods. so we should not compare the
	       deliver quantities. */
              --l_available_qty := l_delivered_qty - l_billed_qty;
	      l_available_qty := l_received_qty - l_billed_qty;

              IF (l_available_qty > 0) THEN

                 IF (g_min_acct_unit IS NOT NULL) THEN
                    l_available_amount := ROUND(l_available_qty * l_rect_unit_price/g_min_acct_unit)
						* g_min_acct_unit;
                 ELSE
                    l_available_amount := ROUND(l_available_qty * l_rect_unit_price, g_precision);
                 END IF;


              END IF;  /* l_available_qty > 0 */

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

              l_amount_billed := nvl(l_amount_billed,0);
              l_amount_delivered := nvl(l_amount_delivered,0);
              l_amount_cancelled := nvl(l_amount_cancelled,0);
	      l_amount_received  := nvl(l_amount_received,0); --BUG # 8229551

	    /* BUG # 8229551 */
              --l_available_amount := l_amount_delivered - l_amount_billed;
              l_available_amount := l_amount_received - l_amount_billed;

           END IF; /* l_matching_basis = 'QUANTITY' */


           IF (l_available_amount > 0) THEN

              IF (l_available_amount  >= l_available_match_amount) THEN
                 l_amount := l_available_match_amount;
              ELSE
                 l_amount := l_available_amount;
              END IF;

              l_quantity := ROUND(l_amount/l_rect_unit_price,15); /*Bug 7515118*/

              l_available_match_amount := l_available_match_amount - l_amount;

	      /* BUG # 8229551 need to use l_invoice_line_number instead of l_po_line_location_id
	         if there are more than one receipt for the same po line then it will fail to
		 load all the records by using single po line location id.*/
              --l_index := l_po_line_location_id; -- bug 5929800 l_index was not being initialized
	       l_index := l_invoice_line_number;

     	      X_Shipment_Table(l_index).po_header_id := x_po_header_id;
     	      X_Shipment_Table(l_index).po_line_id := l_po_line_id;
     	      X_Shipment_Table(l_index).po_release_id := l_po_release_id;
     	      X_Shipment_Table(l_index).po_line_location_id := l_po_line_location_id;
     	      X_Shipment_Table(l_index).rcv_transaction_id := l_rcv_transaction_id;
     	      X_Shipment_Table(l_index).uom := l_receipt_uom_lookup_code;
     	      X_Shipment_Table(l_index).unit_price :=  l_rect_unit_price;
     	      X_Shipment_Table(l_index).line_number := l_invoice_line_number;
     	      X_Shipment_Table(l_index).quantity_invoiced := l_quantity;
     	      X_Shipment_Table(l_index).amount := l_amount;
    	      X_Shipment_Table(l_index).inventory_item_id := l_item_id;
    	      X_Shipment_Table(l_index).item_description := l_item_description;
    	      X_Shipment_Table(l_index).asset_category_id := l_asset_category_id;
           -- Removed for bug 4277744
    	   -- X_Shipment_Table(l_index).ussgl_transaction_code := l_ussgl_transaction_code;
    	      X_Shipment_Table(l_index).type_1099 := l_type_1099;
     	      X_Shipment_Table(l_index).attribute_category := l_attribute_category;
     	      X_Shipment_Table(l_index).attribute1 := l_attribute1;
     	      X_Shipment_Table(l_index).attribute2 := l_attribute2;
     	      X_Shipment_Table(l_index).attribute3 := l_attribute3;
      	      X_Shipment_Table(l_index).attribute4 := l_attribute4;
      	      X_Shipment_Table(l_index).attribute5 := l_attribute5;
     	      X_Shipment_Table(l_index).attribute6 := l_attribute6;
              X_Shipment_Table(l_index).attribute7 := l_attribute7;
     	      X_Shipment_Table(l_index).attribute8 := l_attribute8;
     	      X_Shipment_Table(l_index).attribute9 := l_attribute9;
    	      X_Shipment_Table(l_index).attribute10 := l_attribute10;
    	      X_Shipment_Table(l_index).attribute11 := l_attribute11;
   	      X_Shipment_Table(l_index).attribute12 := l_attribute12;
   	      X_Shipment_Table(l_index).attribute13 := l_attribute13;
   	      X_Shipment_Table(l_index).attribute14 := l_attribute14;
   	      X_Shipment_Table(l_index).attribute15 := l_attribute15;
	      X_Shipment_Table(l_index).ship_to_location_id := l_ship_to_location_id;
	      X_Shipment_Table(l_index).primary_intended_use := l_primary_intended_use;
	      X_Shipment_Table(l_index).product_fisc_classification := l_product_fisc_classification;
	      X_Shipment_Table(l_index).product_type := l_product_type;
	      X_Shipment_Table(l_index).product_category := l_product_category;
	      X_Shipment_Table(l_index).user_defined_fisc_class := l_user_defined_fisc_class;

	      X_Shipment_Table(l_index).matching_basis  := l_matching_basis;
	      X_Shipment_Table(l_index).retained_amount := ap_invoice_lines_utility_pkg.get_retained_amount
		                                                                (l_po_line_location_id, l_amount);

              --Get the max of the largest invoice line, to be used for assignment of
              --rounding due to proration.
              IF (l_amount >= l_max_line_amount) THEN

                 l_rounded_index := l_invoice_line_number;  --BUG # 8229551
                 l_max_line_amount := l_amount;

              END IF;

              l_invoice_line_number := l_invoice_line_number + 1;
              l_sum_prorated_amount := l_sum_prorated_amount + l_amount;

         END IF; /* (l_available_amount > 0)*/

    END LOOP;

    CLOSE Receipt_Shipment_List_Cursor;

    --If proration resulted in rounding error, then add  the rounding amt
    --onto max of the largest line, index for which was calculated above
    --We need to do the proration rounding only if we exhausted the match amount
    --and not if we exhausted the shipments.
    IF(l_available_match_amount = 0) THEN
       IF (x_match_amount - l_sum_prorated_amount <> 0 and l_rounded_index IS NOT NULL) THEN

          X_Shipment_Table(l_rounded_index).amount := X_Shipment_Table(l_rounded_index).amount +
      						   (l_available_match_amount - l_sum_prorated_amount);

       END IF;
    END IF;

  END IF;/*(x_match option = 'P')*/


  --Calculate base_amounts and rounding for foriegn currency invoices
  IF (g_exchange_rate IS NOT NULL) THEN

     l_invoice_base_amount := ap_utilities_pkg.ap_round_currency(
     				  x_match_amount * g_exchange_rate,
				  g_base_currency_code);

     --Populate base_amount column for foriegn currency invoice.
     --Base amount needs to be populated after the lines have been rounded
     --for proration, hence doing in the loop below.

     FOR i IN NVL(X_Shipment_Table.first,0) .. NVL(X_Shipment_Table.last,0) LOOP

        l_base_amount := ap_utilities_pkg.ap_round_currency(
                                                x_shipment_table(i).amount * g_exchange_rate,
					        g_base_currency_code);

	x_shipment_table(i).base_amount := l_base_amount;

        l_sum_line_base_amount := l_sum_line_base_amount + l_base_amount;

     END LOOP;

     --Perform rounding
     IF (l_invoice_base_amount <> l_sum_line_base_amount) THEN

       x_shipment_table(l_rounded_index).base_amount := x_shipment_table(l_rounded_index).base_amount +
       							  (l_invoice_base_amount - l_sum_line_base_amount);
       x_shipment_table(l_rounded_index).rounding_amt := l_invoice_base_amount - l_sum_line_base_amount;

     END IF;

  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Get_Shipment_List_For_QuickMatch(-)');
  END IF;


EXCEPTION
  WHEN others then
     If (SQLCODE <> -20001) Then
        fnd_message.set_name('SQLAP','AP_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS',
                  ' invoice_id = '||to_char(x_invoice_id)
                ||', Po header id = '||to_char(x_po_header_id)
                ||', match option = '||x_match_option
                ||', match_amount = '||to_char(x_match_amount));
        fnd_message.set_token('DEBUG_INFO',l_debug_info);
     End if;
  --Clean up the PL/SQL tables on error
  x_shipment_table.delete;

  app_exception.raise_exception;

END Get_Shipment_List_For_QM;


PROCEDURE Generate_Lines_For_QuickMatch (
		x_invoice_id  IN NUMBER,
		x_shipment_table IN T_SHIPMENT_TABLE,
		x_match_option IN VARCHAR2,
		x_calling_sequence IN VARCHAR2) IS

i NUMBER;
l_debug_info VARCHAR2(2000);
current_calling_sequence VARCHAR2(2000);
l_api_name   VARCHAR2(50);

BEGIN


   l_api_name := 'Generate_Lines_For_QuickMatch';
   current_calling_sequence := 'Generate_Lines_For_QuickMatch<-'||x_calling_sequence;
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Generate_Lines_For_QuickMatch(+)');
   END IF;

   FOR i IN NVL(x_shipment_table.first,0) .. NVL(x_shipment_table.last,0) LOOP

     IF (x_shipment_table.exists(i)) THEN
     /* bug 6150813 */
   	INSERT INTO AP_INVOICE_LINES_ALL
   		(INVOICE_ID,
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
       	     -- USSGL_TRANSACTION_CODE,- Bug 4277744
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
		/*OPEN ISSUE 1*/
   		/*GLOBAL_ATTRIBUTE_CATEGORY,
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
		RETAINED_AMOUNT,
		RETAINED_AMOUNT_REMAINING,
		--bugfix:5565310
		SHIP_TO_LOCATION_ID,
		PRIMARY_INTENDED_USE,
		PRODUCT_FISC_CLASSIFICATION,
		TRX_BUSINESS_CATEGORY,
	        PRODUCT_TYPE,
	        PRODUCT_CATEGORY,
	        USER_DEFINED_FISC_CLASS,
		ASSESSABLE_VALUE,
		TAX_CLASSIFICATION_CODE,
		PAY_AWT_GROUP_ID)
      VALUES( X_INVOICE_ID,			--invoice_id
       	      X_SHIPMENT_TABLE(i).line_number,  --line_number
              'ITEM',				--line_type_lookup_code
   	      NULL,				--requester_id
 	      X_SHIPMENT_TABLE(i).item_description,--description
 	      'HEADER MATCH',			--line_source
 	      G_ORG_ID,				--org_id
 	      X_SHIPMENT_TABLE(i).inventory_item_id,--inventory_item_id
 	      X_SHIPMENT_TABLE(i).item_description,--item_description
 	      NULL,				--serial_number
 	      NULL,				--manufacturer
 	      NULL,				--model_number
 	      'Y',				--generate_dists
              DECODE(X_MATCH_OPTION,'P',
			(DECODE(X_SHIPMENT_TABLE(i).matching_basis,
				'QUANTITY', 'ITEM_TO_PO', 'ITEM_TO_SERVICE_PO')),
			(DECODE(X_SHIPMENT_TABLE(i).matching_basis,
				'QUANTITY', 'ITEM_TO_RECEIPT', 'ITEM_TO_SERVICE_RECEIPT'))),  --match_type
 	      NULL,				--distribution_set_id
 	      NULL,				--account_segment
 	      NULL,				--balancing_segment
 	      NULL,				--cost_center_segment
 	      NULL,				--overlay_dist_code_concat
     	      NULL,				--default_dist_ccid
     	      'N',				--prorate_across_all_items
 	      NULL,				--line_group_number
 	      G_ACCOUNTING_DATE,		--accounting_date
 	      G_PERIOD_NAME,			--period_name
 	      'N',				--deferred_acctg_flag
 	      NULL,				--def_acctg_start_date
 	      NULL,				--def_acctg_end_date
 	      NULL,				--def_acctg_number_of_periods
 	      NULL,				--def_acctg_period_type
 	      G_SET_OF_BOOKS_ID,		--set_of_books_id
 	      X_SHIPMENT_TABLE(i).AMOUNT,	--amount
 	      X_SHIPMENT_TABLE(i).BASE_AMOUNT,  --base_amount
 	      X_SHIPMENT_TABLE(i).rounding_amt,	--rounding_amount
 	      X_SHIPMENT_TABLE(i).QUANTITY_INVOICED,--quantity_invoiced
 	      X_SHIPMENT_TABLE(i).UOM, 		--unit_meas_lookup_code
 	      X_SHIPMENT_TABLE(i).UNIT_PRICE,	--unit_price
 	      DECODE(G_APPROVAL_WORKFLOW_FLAG,'Y'
	            ,'REQUIRED','NOT REQUIRED'),--wf_approval_status
           -- Removed for bug 4277744
 	   -- X_SHIPMENT_TABLE(i).USSGL_TRANSACTION_CODE,--ussgl_transaction_code
 	      'N',				--discarded_flag
 	      NULL,				--original_amount
 	      NULL,				--original_base_amount
 	      NULL,				--original_rounding_amt
 	      'N',				--cancelled_flag
 	      G_INCOME_TAX_REGION,		--income_tax_region
 	      X_SHIPMENT_TABLE(i).TYPE_1099,	--type_1099
 	      NULL,				--stat_amount
 	      NULL,				--prepay_invoice_id
 	      NULL,				--prepay_line_number
 	      NULL,				--invoice_includes_prepay_flag
 	      NULL,				--corrected_inv_id
 	      NULL,				--corrected_line_number
 	      X_SHIPMENT_TABLE(i).PO_HEADER_ID,	--po_header_id
 	      X_SHIPMENT_TABLE(i).PO_LINE_ID,	--po_line_id
 	      X_SHIPMENT_TABLE(i).PO_RELEASE_ID,--po_release_id
 	      X_SHIPMENT_TABLE(i).PO_LINE_LOCATION_ID,--po_line_location_id
 	      NULL,			        --po_distribution_id
    	      DECODE(X_MATCH_OPTION,'P',NULL,
    	             X_SHIPMENT_TABLE(i).RCV_TRANSACTION_ID),	--rcv_transaction_id
   	      NULL,				--final_match_flag
    	      'N',				--assets_tracking_flag
    	      G_ASSET_BOOK_TYPE_CODE,		--asset_book_type_code
    	      X_SHIPMENT_TABLE(i).ASSET_CATEGORY_ID,--asset_category_id
    	      NULL,				--project_id
   	      NULL,				--task_id
 	      NULL,				--expenditure_type
 	      NULL,	 			--expenditure_item_date
 	      NULL,				--expenditure_organization_id
 	      NULL,				--pa_quantity
 	      NULL,				--pa_cc_ar_invoice_id
 	      NULL,				--pa_cc_ar_invoice_line_num
 	      NULL,				--pa_cc_processed_code
 	      NULL,				--award_id
 	      G_AWT_GROUP_ID,			--awt_group_id
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
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE_CATEGORY,--attribute_category
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE1,	--attribute1
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE2,	--attribute2
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE3,	--attribute3
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE4,	--attribute4
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE5,	--attribute5
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE6,	--attribute6
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE7,	--attribute7
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE8,	--attribute8
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE9,	--attribute9
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE10,	--attribute10
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE11,	--attribute11
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE12,	--attribute12
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE13,	--attribute13
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE14,	--attribute14
 	      X_SHIPMENT_TABLE(i).ATTRIBUTE15,	--attribute15
 	      /*X_GLOBAL_ATTRIBUTE_CATEGORY,	--global_attribute_category
	      X_GLOBAL_ATTRIBUTE1,		--global_attribute1
      	      X_GLOBAL_ATTRIBUTE2,		--global_attribute2
	      X_GLOBAL_ATTRIBUTE3,		--global_attribute3
      	      X_GLOBAL_ATTRIBUTE4,		--global_attribute4
      	      X_GLOBAL_ATTRIBUTE5,		--global_attribute5
      	      X_GLOBAL_ATTRIBUTE6,		--global_attribute6
      	      X_GLOBAL_ATTRIBUTE7,		--global_attribute7
       	      X_GLOBAL_ATTRIBUTE8,		--global_attribute8
      	      X_GLOBAL_ATTRIBUTE9,		--global_attribute9
       	      X_GLOBAL_ATTRIBUTE10,		--global_attribute10
      	      X_GLOBAL_ATTRIBUTE11,		--global_attribute11
      	      X_GLOBAL_ATTRIBUTE12,		--global_attribute12
      	      X_GLOBAL_ATTRIBUTE13,		--global_attribute13
      	      X_GLOBAL_ATTRIBUTE14,		--global_attribute14
      	      X_GLOBAL_ATTRIBUTE15,		--global_attribute15
      	      X_GLOBAL_ATTRIBUTE16,		--global_attribute16
      	      X_GLOBAL_ATTRIBUTE17,		--global_attribute17
      	      X_GLOBAL_ATTRIBUTE18,		--global_attribute18
      	      X_GLOBAL_ATTRIBUTE19,		--global_attribute19
      	      X_GLOBAL_ATTRIBUTE20, 	--global_attribute20*/
      	      SYSDATE,				--creation_date
      	      G_USER_ID,			--created_by
      	      G_USER_ID,			--last_update_by
      	      SYSDATE,				--last_update_date
      	      G_LOGIN_ID,			--last_update_login
      	      NULL,				--program_application_id
	      NULL,				--program_id
      	      NULL,				--program_update_date
      	      NULL,  	      		       	--request_id
	      X_SHIPMENT_TABLE(i).retained_amount,	-- retained_amount
	      (-X_SHIPMENT_TABLE(i).retained_amount),	-- retained_amount_remaining
	      --bugfix:5565310
	      X_SHIPMENT_TABLE(i).SHIP_TO_LOCATION_ID,         --ship_to_location_id
	      X_SHIPMENT_TABLE(i).PRIMARY_INTENDED_USE,        --primary_intended_use
	      X_SHIPMENT_TABLE(i).PRODUCT_FISC_CLASSIFICATION, --product_fisc_classification
	      G_TRX_BUSINESS_CATEGORY          --trx_business_category
	      ,X_SHIPMENT_TABLE(i).PRODUCT_TYPE,                --product_type
	      X_SHIPMENT_TABLE(i).PRODUCT_CATEGORY,            --product_category
	      X_SHIPMENT_TABLE(i).USER_DEFINED_FISC_CLASS,      --user_defined_fisc_class
	      X_SHIPMENT_TABLE(I).ASSESSABLE_VALUE,
	      X_SHIPMENT_TABLE(i).TAX_CLASSIFICATION_CODE,
		  G_PAY_AWT_GROUP_ID			--pay_awt_group_id   bug8222382
      	      );

      END IF;

   END LOOP;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_MATCHING_PKG.Generate_Lines_For_QuickMatch(-)');
   END IF;



EXCEPTION
  WHEN others then
     If (SQLCODE <> -20001) Then
        fnd_message.set_name('SQLAP','AP_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS',
                  ' invoice_id = '||to_char(x_invoice_id)
                ||', match option = '||x_match_option);
        fnd_message.set_token('DEBUG_INFO',l_debug_info);
     End if;

  app_exception.raise_exception;

END Generate_Lines_For_QuickMatch;

Procedure Generate_Release_Lines (p_po_header_id     IN NUMBER,
         	                  p_invoice_id       IN NUMBER,
		                  p_release_amount   IN NUMBER,
				  x_calling_sequence IN VARCHAR2) Is

        Cursor c_line_locations (c_po_header_id NUMBER) IS
        Select pll.*
          From po_line_locations_all pll
         Where pll.po_header_id = c_po_header_id
           And nvl(retainage_withheld_amount,0) - nvl(retainage_released_amount,0) <> 0;

        l_line_locations c_line_locations%rowtype;

        i                               number:=1;
        l_release_amount_rtot           number;
	l_shipment_release_amount	number;
        l_release_amount_remaining      number;

        l_release_shipment_tab  ap_retainage_release_pkg.release_shipments_tab;

	l_debug_info		 VARCHAR2(2000);
	current_calling_sequence VARCHAR2(2000);
	l_api_name		 VARCHAR2(50);

BEGIN

    l_api_name               := 'Generate_Release_Lines';
    current_calling_sequence := 'Generate_Release_Lines<-'||x_calling_sequence;

    l_debug_info := 'Generate_Release_Lines (+)';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    l_release_amount_rtot := p_release_amount;

    Open  c_line_locations (p_po_header_id);
    Loop
        Fetch c_line_locations
         Into l_line_locations;

        Exit When c_line_locations%notfound OR
                  l_release_amount_rtot = 0;

        l_release_amount_remaining := nvl(l_line_locations.retainage_withheld_amount,0) -
                                      nvl(l_line_locations.retainage_released_amount,0);

	If l_release_amount_rtot > l_release_amount_remaining Then
           l_shipment_release_amount := l_release_amount_remaining;
        Else
	   l_shipment_release_amount := l_release_amount_rtot;
	End If;

        l_release_shipment_tab(i).po_header_id             := l_line_locations.po_header_id;
        l_release_shipment_tab(i).po_line_id               := l_line_locations.po_line_id;
        l_release_shipment_tab(i).po_release_id            := l_line_locations.po_release_id;
        l_release_shipment_tab(i).line_location_id         := l_line_locations.line_location_id;
        l_release_shipment_tab(i).release_amount           := l_shipment_release_amount;
        l_release_shipment_tab(i).release_amount_remaining := l_release_amount_remaining;

        l_debug_info := 'Call Release API: '||
	                        'line_location_id: ' || l_line_locations.line_location_id||
				'release_amount: '   || l_shipment_release_amount;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        ap_retainage_release_pkg.create_release
                                (x_invoice_id            => p_invoice_id,
                                 x_release_shipments_tab => l_release_shipment_tab);

        l_release_amount_rtot := l_release_amount_rtot - l_shipment_release_amount;
        i:=i+1;

    End Loop;
    Close c_line_locations;

    l_debug_info := 'Generate_Release_Lines (-)';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

EXCEPTION
  WHEN others then
     If (SQLCODE <> -20001) Then
        fnd_message.set_name('SQLAP','AP_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS',
                  ' invoice_id = '||to_char(p_invoice_id));
        fnd_message.set_token('DEBUG_INFO',l_debug_info);
     End if;

  app_exception.raise_exception;

End Generate_Release_Lines;

-- Bug 5465722. Building Prepay Proper Account as per Federal Functionality.
-- Only Natural Account will be overlayed
PROCEDURE  Build_Prepay_Account(P_base_ccid             IN     NUMBER
                              ,P_overlay_ccid          IN     NUMBER
                              ,P_accounting_date       IN     DATE
                              ,P_result_ccid           OUT NOCOPY    NUMBER
                              ,P_Reason_Unbuilt_Flex   OUT NOCOPY    VARCHAR2
                              ,P_calling_sequence      IN     VARCHAR2 ) IS

  l_base_segments                FND_FLEX_EXT.SEGMENTARRAY ;
  l_overlay_segments             FND_FLEX_EXT.SEGMENTARRAY ;
  l_segments                     FND_FLEX_EXT.SEGMENTARRAY ;
  l_num_of_segments              NUMBER ;
  l_result                       BOOLEAN ;
  l_curr_calling_sequence        VARCHAR2(2000);
  G_flex_qualifier_name          VARCHAR2(100);
  l_primary_sob_id               AP_SYSTEM_PARAMETERS.set_of_books_id%TYPE;
  l_liability_post_lookup_code   AP_SYSTEM_PARAMETERS.liability_post_lookup_code%TYPE;
  l_chart_of_accts_id            GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
  G_flex_segment_num             NUMBER;
  l_api_name                     CONSTANT VARCHAR2(200) := 'Build_Prepay_Account';
  l_debug_info                   VARCHAR2(2000);


BEGIN

   l_curr_calling_sequence := 'Ap_Matching_Pkg.Build_Prepay_Account<-'
                             || P_calling_sequence;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
   END IF;


   SELECT set_of_books_id
   INTO   l_primary_sob_id
   FROM   ap_system_parameters;

   SELECT chart_of_accounts_id
   INTO   l_chart_of_accts_id
   FROM   gl_sets_of_books
   WHERE  set_of_books_id = l_primary_sob_id;


   G_flex_qualifier_name := 'GL_ACCOUNT' ;


   l_result := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                 101, 'GL#',
                                 l_chart_of_accts_id,
                                 G_flex_qualifier_name,
                                 G_flex_segment_num);

   l_debug_info := 'G_Flex_Segment_Num: '||G_Flex_Segment_Num;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

  -- Get the segments of the two given accounts
   IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL', 'GL#',
                                    l_chart_of_accts_id,
                                    P_base_ccid, l_num_of_segments,
                                    l_base_segments)
     ) THEN
      -- Print reason why flex failed
     P_result_ccid := -1;
     P_reason_unbuilt_flex := 'INVALID ACCOUNT';

     l_debug_info := 'Charge Account is Invalid -> '||FND_MESSAGE.GET;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     RETURN ;

   END IF;

   IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL', 'GL#',
                                    l_chart_of_accts_id,
                                    P_overlay_ccid, l_num_of_segments,
                                    l_overlay_segments)
     ) THEN
     -- Print reason why flex failed
     P_result_ccid := -1;
     P_reason_unbuilt_flex := 'INVALID ACCOUNT';

     l_debug_info := 'Overlay Account is Invalid -> '||FND_MESSAGE.GET;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     RETURN ;

   END IF;

   /*
    Account Segment Overlay
    Base      A    A    [A]  A
    Overlay   B    B    [B]  B
    Result    A    A    [B]  A

   */

   FOR i IN 1.. l_num_of_segments LOOP

     l_debug_info := 'Overlaying Account Segment -> '||to_char(i);
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     --  Account segment overlay
     IF (i = G_flex_segment_num) THEN
       l_segments(i) := l_overlay_segments(i);
     ELSE
       l_segments(i) := l_base_segments(i);
     END IF;

   END LOOP;

   -- Get ccid fOR overlayed segments
   l_result := FND_FLEX_EXT.GET_COMBINATION_ID('SQLGL', 'GL#',
                                   l_chart_of_accts_id,
                                   P_accounting_date, l_num_of_segments,
                                   l_segments, P_result_ccid) ;

   IF (NOT l_result) THEN

     -- Store reason why flex failed
     P_result_ccid := -1;
     P_reason_unbuilt_flex := 'INVALID ACCOUNT';

     l_debug_info := 'Account Based on Overlayed Segments can not be build -> '||FND_MESSAGE.GET;
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS','Base CCID = '||to_char(p_base_ccid)
                          ||', Overlay CCID = '||to_char(p_overlay_ccid));
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

       l_debug_info := 'Exception occured in Building Prepay Account> '||FND_MESSAGE.GET;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
     END IF;
     APP_EXCEPTION.RAISE_EXCEPTION;

 END Build_Prepay_Account;


END AP_MATCHING_PKG;

/
