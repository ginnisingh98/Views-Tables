--------------------------------------------------------
--  DDL for Package Body AP_PO_AMT_MATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PO_AMT_MATCH_PKG" AS
/*$Header: apamtpob.pls 120.44.12010000.7 2010/02/08 08:50:27 baole ship $*/

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_PO_AMT_MATCH_PKG';
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
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_PO_AMT_MATCH_PKG.';
--
-- Define local procedures
--
--LOCAL PROCEDURES
PROCEDURE Get_Info(X_Invoice_ID          IN NUMBER,
                   X_Invoice_Line_Number IN NUMBER DEFAULT NULL,
                   X_Match_Amount        IN NUMBER DEFAULT NULL,
                   X_Po_Line_Location_Id IN NUMBER DEFAULT NULL,
                   X_Calling_Sequence    IN VARCHAR2 );

PROCEDURE Get_Dist_Proration_Info(
                  X_Invoice_Id           IN NUMBER,
                  X_Invoice_Line_Number  IN NUMBER,
                  X_Po_Line_Location_Id  IN NUMBER,
                  X_Match_Mode           IN VARCHAR2,
                  X_Match_Quantity       IN NUMBER,
                  X_Match_Amount         IN NUMBER,
                  X_Unit_Price           IN NUMBER,
                  X_Overbill_Flag        IN VARCHAR2,
                  X_Dist_Tab             IN OUT NOCOPY AP_MATCHING_PKG.DIST_TAB_TYPE,
                  X_Calling_Sequence     IN VARCHAR2);

PROCEDURE Get_Total_Proration_Amount(
                  X_PO_Line_Location_Id  IN NUMBER,
                  X_Match_Mode           IN VARCHAR2,
                  X_Overbill_Flag        IN VARCHAR2,
                  X_Total_Amount         OUT NOCOPY NUMBER,
                  X_Calling_Sequence     IN VARCHAR2);

Procedure Update_PO_Shipments_Dists(
                    X_Dist_Tab         IN OUT NOCOPY  AP_MATCHING_PKG.Dist_Tab_Type,
   		    X_Po_Line_Location_Id IN 	         NUMBER,
		    X_Match_Amount        IN   		 NUMBER,
		    X_Match_Quantity	  IN		 NUMBER,
		    X_Uom_Lookup_Code  	  IN  		 VARCHAR2,
  		    X_Calling_Sequence    IN  		 VARCHAR2);

Procedure Insert_Invoice_Line (
                    X_Invoice_Id              IN NUMBER,
                    X_Invoice_Line_Number     IN NUMBER,
                    X_Line_Type_Lookup_Code   IN VARCHAR2,
		    X_Cost_Factor_Id	      IN NUMBER DEFAULT NULL,
                    X_Single_Dist_Flag        IN VARCHAR2 DEFAULT 'N',
                    X_Po_Distribution_Id      IN NUMBER DEFAULT NULL,
                    X_Po_Line_Location_Id     IN NUMBER DEFAULT NULL,
                    X_Amount                  IN NUMBER,
                    X_Quantity_Invoiced       IN NUMBER DEFAULT NULL,
                    X_Unit_Price              IN NUMBER DEFAULT NULL,
                    X_Final_Match_Flag        IN VARCHAR2 DEFAULT NULL,
                    X_Item_Line_Number        IN NUMBER,
                    X_Charge_Line_Description IN VARCHAR2,
		    X_Retained_Amount	      IN NUMBER DEFAULT NULL,
                    X_Calling_Sequence        IN VARCHAR2);

PROCEDURE Insert_Invoice_Distributions (
                    X_Invoice_ID          IN     NUMBER,
                    X_Invoice_Line_Number IN     NUMBER,
                    X_Dist_Tab            IN OUT NOCOPY AP_MATCHING_PKG.Dist_Tab_Type,
                    X_Final_Match_Flag    IN     VARCHAR2,
                    X_Unit_Price          IN     NUMBER,
                    X_Total_Amount        IN     NUMBER,
                    X_Calling_Sequence    IN     VARCHAR2);

Procedure Create_Charge_Lines(
                    X_Invoice_Id          IN  NUMBER,
		    X_Freight_Cost_Factor_Id IN NUMBER,
                    X_Freight_Amount      IN  NUMBER,
                    X_Freight_Description IN  VARCHAR2,
		    X_Misc_Cost_Factor_Id IN  NUMBER,
                    X_Misc_Amount         IN  NUMBER,
                    X_Misc_Description    IN  VARCHAR2,
                    X_Item_Line_Number    IN  NUMBER,
                    X_Calling_Sequence    IN  VARCHAR2);

PROCEDURE Get_Corr_Dist_Proration_Info(
                    X_Corrected_Invoice_id  IN    NUMBER,
                    X_Corrected_Line_Number IN    NUMBER,
                    X_Corr_Dist_Tab         IN OUT NOCOPY AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
                    X_Correction_Amount     IN    NUMBER,
                    X_Match_Mode            IN    VARCHAR2,
                    X_Calling_Sequence      IN    VARCHAR2);

PROCEDURE Insert_Corr_Invoice_Line(
                    X_Invoice_Id            IN  NUMBER,
                    X_Invoice_Line_Number   IN  NUMBER,
                    X_Corrected_Invoice_Id  IN  NUMBER,
                    X_Corrected_Line_Number IN  NUMBER,
                    X_Amount                IN  NUMBER,
                    X_Final_Match_Flag      IN  VARCHAR2,
                    X_Po_Distribution_Id    IN  NUMBER,
		    X_Retained_Amount	    IN  NUMBER DEFAULT NULL,
                    X_Calling_Sequence      IN  VARCHAR2);

PROCEDURE Insert_Corr_Invoice_Dists(
                    X_Invoice_Id          IN  NUMBER,
                    X_Invoice_Line_Number IN  NUMBER,
		    X_Corrected_Invoice_Id IN NUMBER,
                    X_Corr_Dist_Tab       IN  OUT NOCOPY AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
                    X_Final_Match_Flag    IN  VARCHAR2,
                    X_Total_Amount        IN  NUMBER,
                    X_Calling_Sequence    IN  VARCHAR2);

PROCEDURE Update_Corr_Po_Shipments_Dists(
                    X_Corr_Dist_Tab    IN  AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
    		    X_Po_Line_Location_Id IN NUMBER,
    		    X_Amount              IN NUMBER,
                    X_Uom_Lookup_Code     IN VARCHAR2,
		    X_Calling_Sequence    IN VARCHAR2);


--Global Variable Declaration
G_Max_Invoice_Line_Number       ap_invoice_lines.line_number%TYPE := 0;
G_Batch_id                      ap_batches.batch_id%TYPE;
G_Accounting_Date               ap_invoice_lines.accounting_date%TYPE;
G_Period_Name                   gl_period_statuses.period_name%TYPE;
G_Set_of_Books_ID               ap_system_parameters.set_of_books_id%TYPE;
G_Awt_Group_ID                  ap_awt_groups.group_id%TYPE;
G_Invoice_Type_Lookup_Code      ap_invoices.invoice_type_lookup_code%TYPE;
G_Exchange_Rate                 ap_invoices.exchange_rate%TYPE;
G_Precision                     fnd_currencies.precision%TYPE;
G_Min_Acct_Unit                 fnd_currencies.minimum_accountable_unit%TYPE;
G_System_Allow_Awt_Flag         ap_system_parameters.allow_awt_flag%TYPE;
G_Site_Allow_Awt_Flag           po_vendor_sites.allow_awt_flag%TYPE;
G_Transfer_Flag                 ap_system_parameters.transfer_desc_flex_flag%TYPE;
G_Base_Currency_Code            ap_system_parameters.base_currency_code%TYPE;
G_Invoice_Currency_Code         ap_invoices.invoice_currency_code%TYPE;
G_Allow_PA_Override             varchar2(1);
G_Pa_Expenditure_Date_Default   varchar2(50);
G_Prepay_CCID                   ap_system_parameters.prepay_code_combination_id%TYPE;
G_Build_Prepay_Accts_Flag       ap_system_parameters.build_prepayment_accounts_flag%TYPE;
G_Income_Tax_Region             ap_system_parameters.income_tax_region%TYPE;
G_Project_ID                    pa_projects_all.project_id%TYPE;
G_Task_ID                       pa_tasks.task_id%TYPE;
G_Expenditure_Type              pa_expenditure_types.expenditure_type%TYPE;
G_Invoice_Date                  ap_invoices.invoice_date%TYPE;
G_Expenditure_Organization_ID   pa_exp_orgs_it.organization_id%TYPE;
G_Asset_Book_Type_Code          fa_book_controls.book_type_code%TYPE;
G_Asset_Category_Id             mtl_system_items.asset_category_id%TYPE;
G_Inventory_Organization_Id     financials_system_parameters.inventory_organization_id%TYPE;
G_Approval_Workflow_Flag        ap_system_parameters.approval_workflow_flag%TYPE;
-- Removed for bug 4277744
-- G_Ussgl_Transaction_Code     ap_invoices.ussgl_transaction_code%TYPE;
G_Allow_Flex_Override_Flag      ap_system_parameters.allow_flex_override_flag%TYPE;
G_Shipment_Type                 po_line_locations.shipment_type%TYPE;
G_Org_id                        ap_invoices.org_id%TYPE;
G_Encumbrance_Flag              financials_system_parameters.purch_encumbrance_flag%TYPE;
G_User_Id                       number;
G_Login_Id                      number;
G_Account_Segment               ap_invoice_lines.account_segment%TYPE := NULL;
G_Balancing_Segment             ap_invoice_lines.balancing_segment%TYPE := NULL;
G_Cost_Center_Segment           ap_invoice_lines.cost_center_segment%TYPE := NULL;
G_Overlay_Dist_Code_Concat      ap_invoice_lines.overlay_dist_code_concat%TYPE := NULL;
G_Default_Dist_CCid             ap_invoice_lines.default_dist_ccid%TYPE := NULL;
G_Line_Project_Id               ap_invoice_lines.project_id%TYPE ;
G_Line_Task_Id                  ap_invoice_lines.task_id%TYPE ;
G_Line_Award_Id                 ap_invoice_lines.award_id%TYPE ;
G_Line_Expenditure_Type         ap_invoice_lines.expenditure_type%TYPE ;
G_Line_Expenditure_Item_Date    ap_invoice_lines.expenditure_item_date%TYPE ;
G_Line_Expenditure_Org_Id       ap_invoice_lines.expenditure_organization_id%TYPE ;
G_Award_Id                      ap_invoices.award_id%TYPE;
G_Line_Base_Amount              ap_invoice_lines.base_amount%TYPE ;
G_Line_Awt_Group_Id             ap_invoice_lines.awt_group_id%TYPE ;
G_Line_Accounting_Date          ap_invoice_lines.accounting_date%TYPE;
G_Trx_Business_Category         ap_invoices.trx_business_category%TYPE;

--Contract Payments
G_Vendor_Id                     ap_invoices.vendor_id%TYPE;
G_Vendor_Site_Id                ap_invoices.vendor_site_id%TYPE;
G_Po_Line_Id                    po_lines_all.po_line_id%TYPE;
G_Recoupment_Rate               po_lines_all.recoupment_rate%TYPE;

--Bugfix:5565310
G_intended_use                  zx_lines_det_factors.line_intended_use%type;
G_product_type                  zx_lines_det_factors.product_type%type;
G_product_category              zx_lines_det_factors.product_category%type;
G_product_fisc_class            zx_lines_det_factors.product_fisc_classification%type;
G_user_defined_fisc_class       zx_lines_det_factors.user_defined_fisc_class%type;
G_assessable_value              zx_lines_det_factors.assessable_value%type;
G_dflt_tax_class_code           zx_transaction_lines_gt.input_tax_classification_code%type;
G_source                        ap_invoices_all.source%type;
G_recurring_payment_id          ap_invoices.recurring_payment_id%TYPE;  -- Bug 7305223


PROCEDURE ap_amt_match
                  (X_match_mode          IN     VARCHAR2,
                   X_invoice_id          IN     NUMBER,
                   X_invoice_line_number IN     NUMBER,
                   X_dist_tab            IN OUT NOCOPY AP_MATCHING_PKG.DIST_TAB_TYPE,
                   X_po_line_location_id IN     NUMBER,
                   X_amount              IN     NUMBER,
                   X_quantity            IN     NUMBER,
                   X_unit_price          IN     NUMBER,
                   X_uom_lookup_code     IN     VARCHAR2,
                   X_final               IN     VARCHAR2,
                   X_overbill            IN     VARCHAR2,
		   X_freight_cost_factor_id IN  NUMBER DEFAULT NULL,
                   X_freight_amount      IN     NUMBER,
                   X_freight_description IN     VARCHAR2,
		   X_misc_cost_factor_id IN     NUMBER DEFAULT NULL,
                   X_misc_amount         IN     NUMBER,
                   X_misc_description    IN     VARCHAR2,
		   X_retained_amount	 IN	NUMBER DEFAULT NULL,
                   X_calling_sequence    IN     VARCHAR2)
IS
l_single_dist_flag              varchar2(1) := 'N';
l_po_distribution_id            po_distributions.po_distribution_id%TYPE := NULL;
l_invoice_distribution_id       ap_invoice_distributions.invoice_distribution_id%TYPE;
l_item_line_number              ap_invoice_lines.line_number%TYPE;
l_amount_to_recoup		ap_invoice_lines.amount%TYPE;
l_line_amt_net_retainage        ap_invoice_lines_all.amount%TYPE;
l_max_amount_to_recoup		ap_invoice_lines_all.amount%TYPE;
l_retained_amount		ap_invoice_lines_all.retained_amount%TYPE;
l_debug_info                    varchar2(2000);
l_success			boolean;
l_error_message			varchar2(4000);
current_calling_sequence        varchar2(2000);
l_api_name      		varchar2(32);

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
l_po_line_location_id         po_line_locations.line_location_id%TYPE;
l_dummy				number;

-- bug 8483345: start
l_product_org_id              ap_invoices.org_id%TYPE;
l_allow_tax_code_override     varchar2(10);
l_dflt_tax_class_code         zx_transaction_lines_gt.input_tax_classification_code%type;
-- bug 8483345: end

BEGIN

   l_api_name := 'Ap_Amt_Match';

   -- Update the calling sequence (for error message).
   current_calling_sequence := 'AP_PO_AMT_MATCH_PKG.ap_amt_match<-'||X_calling_sequence;

   l_debug_info := 'Get Invoice and System Options information';

   get_info(X_Invoice_Id          => X_invoice_id,
            X_Invoice_Line_Number => x_invoice_line_number,
            X_Match_Amount        => x_amount,
            X_Po_Line_Location_id => x_po_line_location_id,
            X_Calling_Sequence    => current_calling_sequence);

   IF g_invoice_type_lookup_code <> 'PREPAYMENT' THEN
      l_retained_amount := AP_INVOICE_LINES_UTILITY_PKG.Get_Retained_Amount
                                        (p_line_location_id => x_po_line_location_id,
                                         p_match_amount     => x_amount);
   END IF;


   l_debug_info := 'Get PO information';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   l_po_line_location_id := x_po_line_location_id;

   l_success := AP_ETAX_UTILITY_PKG.Get_PO_Info(
                      P_Po_Line_Location_Id         => l_po_line_location_id,
                      P_PO_Distribution_Id          => null,
                      P_Application_Id              => l_ref_doc_application_id,
                      P_Entity_code                 => l_ref_doc_entity_code,
                      P_Event_Class_Code            => l_ref_doc_event_class_code,
                      P_PO_Quantity                 => l_ref_doc_line_quantity,
                      P_Product_Org_Id              => l_product_org_id, -- 8483345
                      P_Po_Header_Id                => l_ref_doc_trx_id,
                      P_Po_Header_curr_conv_rate    => l_po_header_curr_conv_rate,
                      P_Uom_Code                    => l_uom_code,
		      P_Dist_Qty                    => l_dummy,
		      P_Ship_Price                  => l_dummy,
                      P_Error_Code                  => l_error_code,
                      P_Calling_Sequence            => current_calling_sequence);

	-- bug 8483345: start
    l_debug_info := 'Get Default Tax Classification';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

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
 	 -- bug 8483345: end

    l_debug_info := 'Get PO Tax Attributes';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

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
                      x_tax_classification_code     => l_dflt_tax_class_code -- 8483345
                      );

	 -- bug 8483345: start
 	    -- if tax classification code not retrieved from hierarchy
 	    -- retrieve it from PO
 	    IF (g_dflt_tax_class_code is null) THEN
 	        g_dflt_tax_class_code := l_dflt_tax_class_code;
 	    END IF;
 	 -- bug 8483345: end

     l_debug_info := 'g_intended_use,g_product_type,g_product_category,g_product_fisc_class '
		      ||g_intended_use||','||g_product_type||','||g_product_category||','||g_product_fisc_class;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

     l_debug_info := 'g_user_defined_fisc_class,g_assessable_value,g_dflt_tax_class_code '
		      ||g_user_defined_fisc_class||','||g_assessable_value||','||g_dflt_tax_class_code;

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


   --If shipment level match then we need to prorate the match-amount among the
   --po distributions of the shipment, for distribution level match we need to
   --derive the invoice_distribution_id, base_amount, ccid.

   l_debug_info := 'Get Distribution information';

   Get_Dist_Proration_Info( X_Invoice_Id          => x_invoice_id,
                            X_Invoice_Line_Number => x_invoice_line_number,
                            X_Po_Line_Location_Id => x_po_line_location_id,
                            X_Match_Mode          => x_match_mode,
                            X_Match_Quantity      => x_quantity,
                            X_Match_Amount        => x_amount,
                            X_Unit_Price          => x_unit_price,
                            X_Overbill_Flag       => x_overbill,
                            X_Dist_Tab            => x_dist_tab,
                            X_Calling_Sequence    => current_calling_sequence);

   IF (x_dist_tab.COUNT = 1) THEN

      l_single_dist_flag := 'Y';
      l_po_distribution_id := x_dist_tab.FIRST;
      l_invoice_distribution_id := x_dist_tab(l_po_distribution_id).invoice_distribution_id;

   END IF;

   --Create a invoice line if one doesn't exist already.
   IF (x_invoice_line_number IS NULL) THEN

     l_debug_info := 'Create Matched Invoice Line';

     Insert_Invoice_Line(X_Invoice_ID                => x_invoice_id,
                         X_Invoice_Line_Number       => g_max_invoice_line_number + 1,
                         X_Line_Type_Lookup_Code     => 'ITEM',
                         X_Single_Dist_Flag          => l_single_dist_flag,
                         X_Po_Distribution_Id        => l_po_distribution_id,
                         X_Po_Line_Location_id       => x_po_line_location_id,
                         X_Amount                    => x_amount,
                         X_Quantity_Invoiced         => x_quantity,
                         X_Unit_Price                => x_unit_price,
                         X_Final_Match_Flag          => x_final,
                         X_Item_Line_Number          => NULL,
                         X_Charge_Line_Description   => NULL,
			 X_Retained_Amount	     => l_retained_amount,
                         X_Calling_Sequence          => current_calling_sequence);

   END IF;

   l_debug_info := 'Create Matched Invoice Distributions';

   Insert_Invoice_Distributions(X_Invoice_ID            => x_invoice_id,
                                X_Invoice_Line_Number   => nvl(x_invoice_line_number,
                                                               g_max_invoice_line_number),
                                X_Dist_Tab              => x_dist_tab,
                                X_Final_Match_Flag      => x_final,
                                X_Unit_Price            => x_unit_price,
                                X_Total_Amount          => x_amount,
                                X_Calling_Sequence      => current_calling_sequence);

    IF (x_invoice_line_number IS NOT NULL) THEN

      IF (l_single_dist_flag = 'Y') THEN

        l_debug_info := 'If the line is matched down to 1 po distribution then need to
                         update the line with po_distribution_id, award_id,requester_id,
                         ,projects related information and generate_dists';

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
                         x_invoice_line_number => nvl(x_invoice_line_number,g_max_invoice_line_number));


  IF (G_Recoupment_Rate IS NOT NULL and x_amount > 0
  		and g_invoice_type_lookup_code <> 'PREPAYMENT') THEN

     l_debug_info := 'Calculate the maximum amount that can be recouped from this invoice line';

     l_line_amt_net_retainage := x_amount + nvl(l_retained_amount,0);

     l_max_amount_to_recoup := ap_utilities_pkg.ap_round_currency(
     				(x_amount * g_recoupment_rate / 100) ,g_invoice_currency_code);

     IF (l_line_amt_net_retainage < l_max_amount_to_recoup) THEN
        l_amount_to_recoup := l_line_amt_net_retainage;
     ELSE
        l_amount_to_recoup := l_max_amount_to_recoup;
     END IF;

     l_debug_info := 'Automatically recoup any available prepayments against the same po line';

     l_success := AP_Matching_Utils_Pkg.Ap_Recoup_Invoice_Line(
                            P_Invoice_Id           => x_invoice_id ,
                            P_Invoice_Line_Number  => nvl(x_invoice_line_number,g_max_invoice_line_number),
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


  l_debug_info := 'Update Amount Billed/Financed on the PO Shipment/Distributions';

  Update_PO_Shipments_Dists(X_Dist_Tab	    => x_dist_tab,
			    X_Po_Line_Location_Id => x_po_line_location_id,
  			    X_Match_Amount	=> x_amount,
	    		    X_Match_Quantity	=> x_quantity,
  			    X_Uom_Lookup_Code => x_uom_lookup_code,
  			    X_Calling_Sequence => current_calling_sequence);

  IF (x_freight_amount IS NOT NULL or x_misc_amount IS NOT NULL) THEN

     l_debug_info := 'Call the procedure to create charge lines';

     --Due to the way PL/SQL binding is done for global variables, need
     --pass the local instead of local variable for this as global variable
     --is being updated before the x_item_line_number is used during runtime.

     l_item_line_number := g_max_invoice_line_number;

     Create_Charge_Lines(X_Invoice_Id           => x_invoice_id,
     			 X_Freight_Cost_Factor_Id => x_freight_cost_factor_id,
                         X_Freight_Amount       => x_freight_amount,
                         X_Freight_Description  => x_freight_description,
			 X_Misc_Cost_Factor_Id  => x_misc_cost_factor_id,
                         X_Misc_Amount          => x_misc_amount,
                         X_Misc_Description     => x_misc_description,
                         X_Item_Line_Number     => l_item_line_number,
                         X_Calling_Sequence     => current_calling_sequence);

  END IF;

  --Clean up the PL/SQL table
  X_DIST_TAB.DELETE;

END ap_amt_match;

PROCEDURE Get_Info(X_Invoice_ID          IN NUMBER,
                   X_Invoice_Line_Number IN NUMBER DEFAULT NULL,
                   X_Match_Amount        IN NUMBER DEFAULT NULL,
                   X_Po_Line_Location_Id IN NUMBER DEFAULT NULL,
                   X_Calling_Sequence    IN VARCHAR2 )
IS
  current_calling_sequence       VARCHAR2(2000);
  l_debug_info                   VARCHAR2(2000);

BEGIN

   current_calling_sequence := 'Get_Info<-'||X_Calling_Sequence;

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
          ai.expenditure_type,
          ai.invoice_date,
          ai.expenditure_organization_id,
          fsp.inventory_organization_id,
          nvl(asp.approval_workflow_flag,'N'),
       -- ai.ussgl_transaction_code, - Bug 4277744
          asp.allow_flex_override_flag,
          ai.org_id,
          nvl(fsp.purch_encumbrance_flag,'N'),
          ai.award_id,
          ai.trx_business_category,
	  --Contract Payments
	  ai.vendor_id,
	  ai.vendor_site_id,
	  ai.source,
	  ai.recurring_payment_id  -- Bug 7305223
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
         g_expenditure_type,
         g_invoice_date,
         g_expenditure_organization_id,
         g_inventory_organization_id,
         g_approval_workflow_flag,
      -- g_ussgl_transaction_code, - Bug 4277744
         g_allow_flex_override_flag,
         g_org_id,
         g_encumbrance_flag,
         g_award_id,
         g_trx_business_category,
	 g_vendor_id,
	 g_vendor_site_id,
	 g_source,
	 g_recurring_payment_id   -- Bug 7305223
   /* Bug 5572876, using base tables */
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
               ail.accounting_date
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
             g_line_accounting_date
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
      FROM po_line_locations pll,
      	   po_lines pl
      WHERE pll.line_location_id = x_po_line_location_id
      AND pl.po_line_id = pll.po_line_id;

   END  IF;

   l_debug_info := 'select period for accounting date';

   --get_current_gl_date will return NULL if the date passed to it doesn't fall in a
   --open period.
   g_period_name := AP_UTILITIES_PKG.get_current_gl_date(g_accounting_date,
   							 g_org_id);

   IF (g_period_name IS NULL) THEN

      --Get gl_period and Date from a future period for the accounting date
      ap_utilities_pkg.get_open_gl_date(p_date        => g_accounting_date,
                                        p_period_name => g_period_name,
                                        p_gl_date     => g_accounting_date,
					p_org_id      => g_org_id);


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

--

PROCEDURE Get_Dist_Proration_Info(
                  X_Invoice_Id           IN NUMBER,
                  X_Invoice_Line_Number  IN NUMBER,
                  X_Po_Line_Location_Id  IN NUMBER,
                  X_Match_Mode           IN VARCHAR2,
                  X_Match_Quantity       IN NUMBER,
                  X_Match_Amount         IN NUMBER,
                  X_Unit_Price           IN NUMBER,
                  X_Overbill_Flag        IN VARCHAR2,
                  X_Dist_Tab             IN OUT NOCOPY AP_MATCHING_PKG.DIST_TAB_TYPE,
                  X_Calling_Sequence     IN VARCHAR2)
IS
  CURSOR po_distributions_cursor(p_total_amount NUMBER) IS
     SELECT po_distribution_id,
            /*PRORATED AMOUNT*/
            DECODE(g_min_acct_unit,
                   '', ROUND( X_match_amount * DECODE(X_match_mode,
                                            'STD-PS',DECODE(X_overbill_flag,
                                                           'Y', NVL(PD.amount_ordered, 0),
                                                                NVL(DECODE(SIGN(PD.amount_ordered -
                                                                                DECODE(PD.distribution_type,'PREPAYMENT',
										       NVL(PD.amount_financed,0),
										       NVL(PD.amount_billed,0)) -
                                                                                NVL(PD.amount_cancelled,0)),
                                                                           -1, 0,
                                                                           PD.amount_ordered -
                                                                           DECODE(PD.distribution_type,'PREPAYMENT',
										  NVL(PD.amount_financed,0),
										  NVL(PD.amount_billed,0)) -
                                                                           NVL(PD.amount_cancelled,0))
                                                                   , 0)),
                                            DECODE(PD.distribution_type,'PREPAYMENT',
					          NVL(PD.amount_financed,0),NVL(PD.amount_billed, 0)))
                     / p_total_amount,
                   g_precision),
                 ROUND(((X_match_amount * DECODE(X_match_mode,
                                                'STD-PS',DECODE(X_overbill_flag,
                                                               'Y', NVL(PD.amount_ordered, 0),
                                                                NVL(DECODE(SIGN(PD.amount_ordered -
                                                                                DECODE(PD.distribution_type,'PREPAYMENT',
										       NVL(PD.amount_financed,0),NVL(PD.amount_billed,0)) -
                                                                                NVL(PD.amount_cancelled,0)),
                                                                           -1, 0,
                                                                           PD.amount_ordered -
                                                                           DECODE(PD.distribution_type,'PREPAYMENT',
									          NVL(PD.amount_financed,0),NVL(PD.amount_billed,0)) -
                                                                           NVL(PD.amount_cancelled,0))
                                                                   , 0)),
                                                DECODE(PD.distribution_type,'PREPAYMENT',
						       NVL(PD.amount_financed,0),NVL(PD.amount_billed, 0)))
                           / p_total_amount)
                     / g_min_acct_unit) * g_min_acct_unit)),
            X_match_quantity,
            PD.code_combination_id,
            PD.accrue_on_receipt_flag,
            DECODE(PD.destination_type_code,'EXPENSE',
                   PD.project_id,NULL),			  --project_id
            DECODE(PD.destination_type_code,'EXPENSE',
                   PD.task_id,NULL),			  --task_id
            DECODE(PD.destination_type_code,'EXPENSE',
                   PD.expenditure_type,
                   NULL), 			          --expenditure_type
            DECODE(PD.destination_type_code,
                   'EXPENSE',PD.expenditure_item_date,
                   NULL),                                 --expenditure_item_date
            DECODE(PD.destination_type_code,
                   'EXPENSE',PD.expenditure_organization_id,
		   NULL),				  --expenditure_organization_id
            DECODE(PD.destination_type_code,
                   'EXPENSE', PD.award_id),                     --award_id
            ap_invoice_distributions_s.nextval
  FROM po_distributions_ap_v PD
  WHERE line_location_id = x_po_line_location_id;

  l_total_amount          number;
  l_po_distribution_id    po_distributions_all.po_distribution_id%TYPE;
  l_amount_invoiced       ap_invoice_distributions_all.amount%TYPE;
  l_quantity_invoiced     ap_invoice_distributions_all.quantity_invoiced%TYPE;
  l_po_dist_ccid          po_distributions.code_combination_id%TYPE;
  l_accrue_on_receipt_flag po_distributions.accrue_on_receipt_flag%TYPE;
  l_project_id            po_distributions.project_id%TYPE;
  l_unbuilt_flex          varchar2(240):='';
  l_reason_unbuilt_flex   varchar2(2000):='';
  l_dist_ccid             ap_invoice_distributions_all.dist_code_combination_id%TYPE;
  l_invoice_distribution_id ap_invoice_distributions.invoice_distribution_id%TYPE;
  l_task_id               po_distributions.task_id%TYPE;
  l_award_set_id          po_distributions_all.award_id%TYPE;
  l_expenditure_type      po_distributions.expenditure_type%TYPE;
  l_po_expenditure_item_date po_distributions.expenditure_item_date%TYPE;
  l_expenditure_organization_id po_distributions.expenditure_organization_id%TYPE;
  l_max_dist_amount       number := 0;
  l_sum_prorated_amount   number := 0;
  l_sum_dist_base_amount  number := 0;
  l_rounding_index        po_distributions.po_distribution_id%TYPE;
  l_base_amount           ap_invoice_distributions.base_amount%TYPE;
  flex_overlay_failed     exception;
  current_calling_sequence varchar2(2000);
  l_debug_info            varchar2(2000);

BEGIN

 current_calling_sequence := 'Get_Dist_Proration_Info<-'||x_calling_sequence;

 IF(X_Match_Mode IN ('STD-PS','CR-PS')) THEN

   l_debug_info := 'Get Total Amount for Proration';


   Get_Total_Proration_Amount
                          ( X_PO_Line_Location_Id  => x_po_line_location_id,
                            X_Match_Mode      => x_match_mode,
                            X_Overbill_Flag   => x_overbill_flag,
                            X_Total_Amount    => l_total_amount,
                            X_Calling_Sequence => current_calling_sequence);

   OPEN PO_Distributions_Cursor(l_total_amount);

   LOOP

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

      IF (l_amount_invoiced <> 0) THEN

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
         -- Bug 5554493
         x_dist_tab(l_po_distribution_id).pa_quantity := l_quantity_invoiced;

         If l_award_set_id Is Not Null Then
            x_dist_tab(l_po_distribution_id).award_id := gms_ap_api.get_distribution_award(l_award_set_id);
         End If;

         --For proration rounding/base amount rounding,
         --calculating max of the largest distribution's index
         IF (l_amount_invoiced >= l_max_dist_amount) THEN
           l_rounding_index := l_po_distribution_id;
           l_max_dist_amount := l_amount_invoiced;
         END IF;

         l_sum_prorated_amount := l_sum_prorated_amount + l_amount_invoiced;

      END IF; /* (l_amount_invoiced <> 0) */

   END LOOP;

   CLOSE PO_Distributions_Cursor;

   --Update the PL/SQL table's amount column with the rounding amount due
   --to proration, before the base_amounts are calculated.

   --bugfix:5641346
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

      --If no project info in the PL/SQL by now, either destination type was not
     --EXPENSE on po distribution, or the project info was null on po distribution
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
         -- Bug 5554493
         --x_dist_tab(i).pa_quantity := l_quantity_invoiced;
         -- Bug 5294998. API from PA will be used
	 /*CASE g_pa_expenditure_date_default
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
         END CASE; */

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

     IF (g_system_allow_awt_flag = 'Y' and g_site_allow_awt_flag = 'Y') THEN

        IF (x_invoice_line_number IS NOT NULL) THEN
           x_dist_tab(i).awt_group_id := g_line_awt_group_id;
        ELSE
           x_dist_tab(i).awt_group_id := g_awt_group_id;
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
        --and encumbrance is not turned on and system option to allow
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
                                'CREATE' ,
                                l_unbuilt_flex ,
                                l_reason_unbuilt_flex ,
                                FND_GLOBAL.RESP_APPL_ID,
                                FND_GLOBAL.RESP_ID,
                                FND_GLOBAL.USER_ID,
                                current_calling_sequence ,
                                NULL) <> TRUE) THEN

                   l_debug_info := 'Overlaying Segments for this account was unsuccessful due to '||
                                  l_reason_unbuilt_flex;

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
 l_debug_info := 'Perform base amount rounding';
 --bugfix:5641346
 IF (g_line_base_amount <> l_sum_dist_base_amount AND g_exchange_rate IS NOT NULL
 	and l_rounding_index is not null) THEN

    x_dist_tab(l_rounding_index).base_amount := x_dist_tab(l_rounding_index).base_amount +
                                                (g_line_base_amount - l_sum_dist_base_amount);

    x_dist_tab(l_rounding_index).rounding_amt := g_line_base_amount - l_sum_dist_base_amount;

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

--

/*---------------------------------------------------------------------------+
 |This procedure will retrieve total_amount to be used for the purpose       |
 |of prorating amounts.                                                      |
 |                                                                           |
 |           The algorithm used is                                           |
 |                                                                           |
 |           IF (matching to std invoices) THEN                              |
 |               IF (this is an Overbill) THEN                               |
 |                   total_amount = sum(amount_ordered)                      |
 |               ELSE (this is not an Overbill)                              |
 |                   total_amount = sum(amount_ordered - (amount_billed +    |
 |                                                       amount_cancelled))  |
 |               END                                                         |
 |           ELSE                                                            |
 |               total_amount = sum(amount_billed)                           |
 |           END                                                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
PROCEDURE Get_Total_Proration_Amount
                          ( X_PO_Line_Location_Id       IN      NUMBER,
                            X_Match_Mode                IN      VARCHAR2,
                            X_Overbill_Flag             IN      VARCHAR2,
                            X_Total_Amount              OUT NOCOPY NUMBER,
                            X_Calling_Sequence          IN      VARCHAR2) IS

l_debug_info                    VARCHAR2(2000);
current_calling_sequence        VARCHAR2(2000);

BEGIN

   current_calling_sequence := 'Get_Total_Proration_Amount<-'||x_calling_sequence;
   l_debug_info := 'Get total amount for proration';

   SELECT SUM(DECODE(X_Match_Mode,
                     'STD-PS',DECODE(X_overbill_flag,
                                  'Y', NVL(amount_ordered, 0),
                                  NVL(DECODE(SIGN(amount_ordered
                                                  - DECODE(distribution_type,'PREPAYMENT',
							   NVL(amount_financed,0),NVL(amount_billed,0))
                                                  - NVL(amount_cancelled,0)),
                                              -1, 0,
                                             amount_ordered -
                                             DECODE(distribution_type,'PREPAYMENT',
						    NVL(amount_financed,0),NVL(amount_billed,0)) -
                                             NVL(amount_cancelled, 0))
                                      ,0)),
               DECODE(distribution_type,'PREPAYMENT',
		      NVL(amount_financed,0),NVL(amount_billed, 0))))
   INTO      X_Total_Amount
   FROM      po_distributions_ap_v
   WHERE     line_location_id = X_Po_Line_Location_Id;

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

END Get_Total_Proration_Amount;

--

PROCEDURE Update_PO_Shipments_Dists(
                    X_Dist_Tab         IN OUT NOCOPY  AP_MATCHING_PKG.Dist_Tab_Type,
		    X_Po_Line_Location_Id IN 	         NUMBER,
		    X_Match_Amount        IN   		 NUMBER,
		    X_Match_Quantity	  IN		 NUMBER,
		    X_Uom_Lookup_Code  	  IN  		 VARCHAR2,
  		    X_Calling_Sequence    IN  		 VARCHAR2) IS

  current_calling_sequence       VARCHAR2(2000);
  l_debug_info                   VARCHAR2(2000);
  i                              NUMBER;
  l_po_ap_dist_rec		 PO_AP_DIST_REC_TYPE;
  l_po_ap_line_loc_rec		 PO_AP_LINE_LOC_REC_TYPE;
  l_api_name			 VARCHAR2(50);
  l_return_status		 VARCHAR2(100);
  l_msg_data			 VARCHAR2(4000);
BEGIN

  l_api_name := 'Update_PO_Shipments_Dists';

  current_calling_sequence := 'Update_Po_Shipments_Dists<-'||x_calling_sequence;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PO_AMT_MATCH_PKG.Update_PO_Shipments_Dists(+)');
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
				 p_quantity_billed     => NULL,
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
				 p_quantity_financed   => NULL,
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
				p_quantity_billed    => NULL,
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
				p_quantity_financed  => NULL,
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
					P_Api_Version 	       => 1.0,
					P_Line_Loc_Changes_Rec => l_po_ap_line_loc_rec,
					P_Dist_Changes_Rec     => l_po_ap_dist_rec,
					X_Return_Status	       => l_return_status,
					X_Msg_Data	       => l_msg_data);


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PO_AMT_MATCH_PKG.Update_PO_Shipments_Dists(-)');
  END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','PO Distribution Id = '||TO_CHAR(X_Dist_tab(i).po_distribution_id));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;

   --Clean up the PL/SQL table
   X_DIST_TAB.DELETE;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Update_Po_Shipments_Dists;

--

PROCEDURE Update_PO_Line_Locations(
                    X_Po_Line_Location_id IN  NUMBER,
                    X_Match_Amount        IN  NUMBER,
                    X_Uom_Lookup_Code     IN  VARCHAR2,
                    X_Calling_Sequence    IN  VARCHAR2)
IS
  current_calling_sequence VARCHAR2(2000);
  l_debug_info             VARCHAR2(2000);
BEGIN

  current_calling_sequence := 'Update_PO_Line_Locations<-'||x_calling_sequence;

  l_debug_info := 'Calling the PO api to update Po_Line_Locations';

  RCV_BILL_UPDATING_SV.ap_update_po_line_locations(x_po_line_location_id => x_po_line_location_id,
                                                   x_quantity_billed     => Null,
                                                   x_uom_lookup_code     => x_uom_lookup_code,
                                                   x_amount_billed       => x_match_amount,
                                                   x_matching_basis      => 'AMOUNT');


EXCEPTION
 WHEN OTHERS THEN
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',current_calling_sequence);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','PO Line Location Id = '||TO_CHAR(X_Po_line_location_id)
                          ||', Match amount = '||to_char(x_match_amount));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;
END Update_PO_Line_Locations;

--

PROCEDURE Insert_Invoice_Line (
                    X_Invoice_Id              IN NUMBER,
                    X_Invoice_Line_Number     IN NUMBER,
                    X_Line_Type_Lookup_Code   IN VARCHAR2,
		    X_Cost_Factor_Id	      IN NUMBER DEFAULT NULL,
                    X_Single_Dist_Flag        IN VARCHAR2 DEFAULT 'N',
                    X_Po_Distribution_Id      IN NUMBER DEFAULT NULL,
                    X_Po_Line_Location_Id     IN NUMBER DEFAULT NULL,
                    X_Amount                  IN NUMBER,
                    X_Quantity_Invoiced       IN NUMBER DEFAULT NULL,
                    X_Unit_Price              IN NUMBER DEFAULT NULL,
                    X_Final_Match_Flag        IN VARCHAR2 DEFAULT NULL,
                    X_Item_Line_Number        IN NUMBER,
                    X_Charge_Line_Description IN VARCHAR2,
		    X_Retained_Amount	      IN NUMBER DEFAULT NULL,
                    X_Calling_Sequence        IN VARCHAR2)
IS
  l_debug_info                    VARCHAR2(2000);
  current_calling_sequence        VARCHAR2(2000);
BEGIN

   current_calling_sequence := 'Insert_Invoice_Line<-'||x_calling_sequence;

   IF (X_LINE_TYPE_LOOKUP_CODE = 'ITEM') THEN

        l_debug_info := 'Inserting Item Line Matched to a PO';

        -- perf bug 5058993
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
              --bugfix:5565310
              SHIP_TO_LOCATION_ID,
              PRIMARY_INTENDED_USE,
              PRODUCT_FISC_CLASSIFICATION,
              TRX_BUSINESS_CATEGORY,
              PRODUCT_TYPE,
              PRODUCT_CATEGORY,
              USER_DEFINED_FISC_CLASS,
	      ASSESSABLE_VALUE,
	      TAX_CLASSIFICATION_CODE)
       SELECT X_INVOICE_ID,                     --invoice_id
              X_INVOICE_LINE_NUMBER,            --invoice_line_number
              X_LINE_TYPE_LOOKUP_CODE,          --line_type_lookup_code
              DECODE(X_SINGLE_DIST_FLAG,'Y',
                  PD.DELIVER_TO_PERSON_ID,NULL),--requester_id
	      --bugfix:5601344 added NVL
              NVL(PLL.DESCRIPTION,PL.ITEM_DESCRIPTION),             --description -- 5058993 PLL to PL
              'HEADER MATCH',                   --line_source
              PLL.ORG_ID,                       --org_id
              PL.ITEM_ID,                      --inventory_item_id -- 5058993 PLL to PL
              NVL(PLL.DESCRIPTION,PL.ITEM_DESCRIPTION),   --item_description -- 5058993 PLL to PL
              NULL,                             --serial_number
              NULL,                             --manufacturer
              NULL,                             --model_number
              'D',                              --generate_dists
              'ITEM_TO_SERVICE_PO',             --match_type
              NULL,                             --distribution_set_id
              NULL,                             --account_segment
              NULL,                             --balancing_segment
              NULL,                             --cost_center_segment
              NULL,                             --overlay_dist_code_concat
              --Bug6965650
              NULL,				--default_dist_ccid
              'N',                              --prorate_across_all_items
              NULL,                             --line_group_number
              G_ACCOUNTING_DATE,                --accounting_date
              G_PERIOD_NAME,                    --period_name
              'N',                              --deferred_acctg_flag
              NULL,                             --def_acctg_start_date
              NULL,                             --def_acctg_end_date
              NULL,                             --def_acctg_number_of_periods
              NULL,                             --def_acctg_period_type
              G_SET_OF_BOOKS_ID,                --set_of_books_id
              X_AMOUNT,                         --amount
              AP_UTILITIES_PKG.Ap_Round_Currency(
                 NVL(X_AMOUNT, 0) * G_EXCHANGE_RATE,
                         G_BASE_CURRENCY_CODE), --base_amount
              NULL,                             --rounding_amount
              X_QUANTITY_INVOICED,              --quantity_invoiced
              PLL.UNIT_MEAS_LOOKUP_CODE,        --unit_meas_lookup_code
              X_UNIT_PRICE,                     --unit_price
              decode(g_approval_workflow_flag,'Y'
                    ,'REQUIRED','NOT REQUIRED'),--wf_approval_status
           -- Removed for bug 4277744
           -- PLL.USSGL_TRANSACTION_CODE,       --ussgl_transaction_code
              'N',                              --discarded_flag
              NULL,                             --original_amount
              NULL,                             --original_base_amount
              NULL,                             --original_rounding_amt
              'N',                              --cancelled_flag
              G_INCOME_TAX_REGION,              --income_tax_region
              PL.TYPE_1099,                    --type_1099 -- 5058993 PLL to PL
              NULL,                             --stat_amount
              NULL,                             --prepay_invoice_id
              NULL,                             --prepay_line_number
              NULL,                             --invoice_includes_prepay_flag
              NULL,                             --corrected_inv_id
              NULL,                             --corrected_line_number
              PLL.PO_HEADER_ID,                 --po_header_id
              PLL.PO_LINE_ID,                   --po_line_id
              PLL.PO_RELEASE_ID,                --po_release_id
              PLL.LINE_LOCATION_ID,             --po_line_location_id
              DECODE(X_SINGLE_DIST_FLAG,'Y',
                     X_PO_DISTRIBUTION_ID,NULL),--po_distribution_id
              NULL,                             --rcv_transaction_id
              X_FINAL_MATCH_FLAG,               --final_match_flag
              'N',                              --assets_tracking_flag
              G_ASSET_BOOK_TYPE_CODE,           --asset_book_type_code
              MSI.ASSET_CATEGORY_ID,            --asset_category_id
	      DECODE(X_SINGLE_DIST_FLAG,'Y',
                     DECODE(PD.destination_type_code,
                            'EXPENSE',PD.project_id,
                            G_PROJECT_ID),
                     NULL),                     --project_id
              DECODE(X_SINGLE_DIST_FLAG,'Y',
                     DECODE(PD.destination_type_code,
                            'EXPENSE',PD.task_id,
                            G_TASK_ID),
                     NULL),                     --task_id
              DECODE(X_SINGLE_DIST_FLAG,'Y',
                     DECODE(PD.destination_type_code,
                            'EXPENSE',PD.expenditure_type,
                            G_EXPENDITURE_TYPE),
                     NULL),                     --expenditure_type
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
                 /*DECODE(g_pa_expenditure_date_default,
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
                     'Transaction System Date', SYSDATE),
                 NULL), */
               DECODE(X_SINGLE_DIST_FLAG,'Y',
                      DECODE(PD.destination_type_code,
                             'EXPENSE',PD.expenditure_organization_id,
                             G_EXPENDITURE_ORGANIZATION_ID),
                      NULL),            --expenditure_organization_id
               DECODE( DECODE(X_SINGLE_DIST_FLAG,'Y',
                              DECODE(PD.destination_type_code,
                                     'EXPENSE',PD.project_id,
                                     G_PROJECT_ID),
                              NULL),
                      '','',x_quantity_invoiced),   --pa_quantity


               NULL,                            --pa_cc_ar_invoice_id
               NULL,                            --pa_cc_ar_invoice_line_num
               NULL,                            --pa_cc_processed_code
               DECODE(X_SINGLE_DIST_FLAG,
                        'Y', nvl(gms_ap_api.get_distribution_award(PD.AWARD_ID), G_AWARD_ID),
                        NULL),                  --award_id
               G_AWT_GROUP_ID,                  --awt_group_id
               NULL,                            --reference_1
               NULL,                            --reference_2
               NULL,                            --receipt_verified_flag
               NULL,                            --receipt_required_flag
               NULL,                            --receipt_missing_flag
               NULL,                            --justification
               NULL,                            --expense_group
               NULL,                            --start_expense_date
               NULL,                            --end_expense_date
               NULL,                            --receipt_currency_code
               NULL,                            --receipt_conversion_rate
               NULL,                            --receipt_currency_amount
               NULL,                            --daily_amount
               NULL,                            --web_parameter_id
               NULL,                            --adjustment_reason
                NULL,                            --merchant_document_number
               NULL,                            --merchant_name
               NULL,                            --merchant_reference
               NULL,                            --merchant_tax_reg_number
               NULL,                            --merchant_taxpayer_id
               NULL,                            --country_of_supply
               NULL,                            --credit_card_trx_id
               NULL,                            --company_prepaid_invoice_id
               NULL,                            --cc_reversal_flag
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute_category),''),--attribute_category
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute1),''),      --attribute1
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute2),''),      --attribute2
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute3),''),      --attribute3
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute4),''),      --attribute4
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute5),''),      --attribute5
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute6),''),      --attribute6
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute7),''),      --attribute7
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute8),''),      --attribute8
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute9),''),      --attribute9
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute10),''),     --attribute10
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute11),''),     --attribute11
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute12),''),     --attribute12
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute13),''),     --attribute13
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute14),''),     --attribute14
               NVL(DECODE(g_transfer_flag,'Y',PLL.attribute15),''),     --attribute15
               /* X_GLOBAL_ATTRIBUTE_CATEGORY,  --global_attribute_category
               X_GLOBAL_ATTRIBUTE1,             --global_attribute1
               X_GLOBAL_ATTRIBUTE2,             --global_attribute2
               X_GLOBAL_ATTRIBUTE3,             --global_attribute3
               X_GLOBAL_ATTRIBUTE4,             --global_attribute4
               X_GLOBAL_ATTRIBUTE5,             --global_attribute5
               X_GLOBAL_ATTRIBUTE6,             --global_attribute6
               X_GLOBAL_ATTRIBUTE7,             --global_attribute7
               X_GLOBAL_ATTRIBUTE8,             --global_attribute8
               X_GLOBAL_ATTRIBUTE9,             --global_attribute9
               X_GLOBAL_ATTRIBUTE10,            --global_attribute10
               X_GLOBAL_ATTRIBUTE11,            --global_attribute11
               X_GLOBAL_ATTRIBUTE12,            --global_attribute12
               X_GLOBAL_ATTRIBUTE13,            --global_attribute13
               X_GLOBAL_ATTRIBUTE14,            --global_attribute14
               X_GLOBAL_ATTRIBUTE15,            --global_attribute15
               X_GLOBAL_ATTRIBUTE16,            --global_attribute16
               X_GLOBAL_ATTRIBUTE17,            --global_attribute17
               X_GLOBAL_ATTRIBUTE18,            --global_attribute18
               X_GLOBAL_ATTRIBUTE19,            --global_attribute19
               X_GLOBAL_ATTRIBUTE20, */         --global_attribute20
               SYSDATE,                         --creation_date
               G_USER_ID,                       --created_by
               G_USER_ID,                       --last_update_by
               SYSDATE,                         --last_update_date
               G_LOGIN_ID,                      --last_update_login
               NULL,                            --program_application_id
               NULL,                            --program_id
               NULL,                            --program_update_date
               NULL,                            --request_id
	       X_RETAINED_AMOUNT,		--retained_amount
	       (-X_RETAINED_AMOUNT),		--retained_amount_remaining
               PLL.SHIP_TO_LOCATION_ID,         --ship_to_location_id
               G_INTENDED_USE,        --primary_intended_use
               G_PRODUCT_FISC_CLASS, --product_fisc_classification
               G_TRX_BUSINESS_CATEGORY ,         --trx_business_category
               G_PRODUCT_TYPE,                --product_type
               G_PRODUCT_CATEGORY,            --product_category
               G_USER_DEFINED_FISC_CLASS ,     --user_defined_fisc_clas
	       G_ASSESSABLE_VALUE,
	       G_dflt_tax_class_code
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
          /* -- commented out older from clause below
          FROM PO_LINE_LOCATIONS_AP_V PLL,
               PO_DISTRIBUTIONS_AP_V PD,
               MTL_SYSTEM_ITEMS MSI
         WHERE PLL.LINE_LOCATION_ID = X_PO_LINE_LOCATION_ID
          AND PD.LINE_LOCATION_ID = PLL.LINE_LOCATION_ID
          AND PD.PO_DISTRIBUTION_ID = NVL(X_PO_DISTRIBUTION_ID,PD.PO_DISTRIBUTION_ID)
          AND MSI.INVENTORY_ITEM_ID(+) = PLL.ITEM_ID
          AND MSI.ORGANIZATION_ID(+) = G_INVENTORY_ORGANIZATION_ID
          AND ROWNUM = 1;  */

    /* for charge lines (frt and misc) allocated during matching */
    ELSIF (x_line_type_lookup_code IN ('FREIGHT','MISCELLANEOUS')) THEN

        l_debug_info := 'Inserting Charge Line';

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
	      COST_FACTOR_ID
              )
    SELECT    X_INVOICE_ID,                     --invoice_id
              X_INVOICE_LINE_NUMBER,            --invoice_line_number
              X_LINE_TYPE_LOOKUP_CODE,          --line_type_lookup_code
              AIL.REQUESTER_ID,                 --requester_id
              --bug 5102208
  	      SUBSTRB(X_CHARGE_LINE_DESCRIPTION || AIL.description, 1, 240),--description
              'CHRG ITEM MATCH',                --line_source
              AIL.ORG_ID,                       --org_id
              NULL,                             --inventory_item_id
              NULL,                             --item_description
              NULL,                             --serial_number
              NULL,                             --manufacturer
              NULL,                             --model_number
              'Y',                              --generate_dists
              'NOT_MATCHED',                    --match_type
              NULL,                             --distribution_set_id
              NULL,                             --account_segment
              NULL,                             --balancing_segment
              NULL,                             --cost_center_segment
              NULL,                             --overlay_dist_code_concat
              --Bug6965650
	      NULL,             		--default_dist_ccid
              'N',                              --prorate_across_all_items
              NULL,                             --line_group_number
              AIL.ACCOUNTING_DATE,              --accounting_date
              AIL.PERIOD_NAME,                  --period_name
              'N',                              --deferred_acctg_flag
              NULL,                             --deferred_acctg_start_date
              NULL,                             --deferred_acctg_end_date
              NULL,                             --def_acctg_number_of_periods
              NULL,                             --def_acctg_period_type
              AIL.SET_OF_BOOKS_ID,              --set_of_books_id
              X_AMOUNT,                         --amount
              AP_UTILITIES_PKG.Ap_Round_Currency(
                    NVL(X_AMOUNT, 0) * G_EXCHANGE_RATE,
                         G_BASE_CURRENCY_CODE), --base_amount
              NULL,                             --rounding_amount
              NULL,                             --quantity_invoiced
              NULL,                             --unit_meas_lookup_code
              NULL,                             --unit_price
              AIL.WFAPPROVAL_STATUS,            --wf_approval_status
           -- Removed for bug 4277744
           -- NULL,                             --ussgl_transaction_code
              'N',                              --discarded_flag
              NULL,                             --original_amount
              NULL,                             --original_base_amount
              NULL,                             --original_rounding_amt
              'N',                              --cancelled_flag
              AIL.INCOME_TAX_REGION,            --income_tax_region
              AIL.TYPE_1099,                    --type_1099
              NULL,                             --stat_amount
              NULL,                             --prepay_invoice_id
              NULL,                             --prepay_line_number
              NULL,                             --invoice_includes_prepay_flag
              NULL,                             --corrected_inv_id
              NULL,                             --corrected_line_number
              NULL,                             --po_header_id
              NULL,                             --po_line_id
              NULL,                             --po_release_id
              NULL,                             --po_line_location_id
              NULL,                             --po_distribution_id
              NULL,                             --rcv_transaction_id
              'N',                              --final_match_flag
              'N',                              --assets_tracking_flag
              NULL,                             --asset_book_type_code
              NULL,                             --asset_category_id
              AIL.PROJECT_ID,                   --project_id
              AIL.TASK_ID,                      --task_id
              AIL.EXPENDITURE_TYPE,             --expenditure_type
              AIL.EXPENDITURE_ITEM_DATE,        --expenditure_item_date
              AIL.EXPENDITURE_ORGANIZATION_ID,  --expenditure_organization_id
              NULL,                             --pa_quantity
              NULL,                             --pa_cc_Ar_invoice_id
              NULL,                             --pa_cc_Ar_invoice_line_num
              NULL,                             --pa_cc_processed_code
              AIL.AWARD_ID,                     --award_id
              AIL.AWT_GROUP_ID,                 --awt_group_id
              NULL,                             --reference_1
              NULL,                             --reference_2
              NULL,                             --receipt_verified_flag
              NULL,                             --receipt_required_flag
              NULL,                             --receipt_missing_flag
              NULL,                             --justification
              NULL,                             --expense_group
              NULL,                             --start_expense_date
              NULL,                             --end_expense_date
              NULL,                             --receipt_currency_code
              NULL,                             --receipt_conversion_rate
              NULL,                             --receipt_currency_amount
              NULL,                             --daily_amount
              NULL,                             --web_parameter_id
              NULL,                             --adjustment_reason
              NULL,                             --merchant_document_number
              NULL,                             --merchant_name
              NULL,                             --merchant_reference
              NULL,                             --merchant_tax_reg_number
              NULL,                             --merchant_taxpayer_id
              NULL,                             --country_of_supply
              NULL,                             --credit_card_trx_id
              NULL,                             --company_prepaid_invoice_id
              NULL,                             --cc_reversal_flag
              AIL.attribute_category,           --attribute_category
              AIL.attribute1,                   --attribute1
              AIL.attribute2,                   --attribute2
              AIL.attribute3,                   --attribute3
              AIL.attribute4,                   --attribute4
              AIL.attribute5,                   --attribute5
              AIL.attribute6,                   --attribute6
              AIL.attribute7,                   --attribute7
              AIL.attribute8,                   --attribute8
              AIL.attribute9,                   --attribute9
              AIL.attribute10,                  --attribute10
              AIL.attribute11,                  --attribute11
              AIL.attribute12,                  --attribute12
              AIL.attribute13,                  --attribute13
              AIL.attribute14,                  --attribute14
              AIL.attribute15,                  --attribute15
              /* X_GLOBAL_ATTRIBUTE_CATEGORY,   --global_attribute_category
              X_GLOBAL_ATTRIBUTE1,              --global_attribute1
              X_GLOBAL_ATTRIBUTE2,              --global_attribute2
              X_GLOBAL_ATTRIBUTE3,              --global_attribute3
              X_GLOBAL_ATTRIBUTE4,              --global_attribute4
              X_GLOBAL_ATTRIBUTE5,              --global_attribute5
              X_GLOBAL_ATTRIBUTE6,              --global_attribute6
              X_GLOBAL_ATTRIBUTE7,              --global_attribute7
              X_GLOBAL_ATTRIBUTE8,              --global_attribute8
              X_GLOBAL_ATTRIBUTE9,              --global_attribute9
              X_GLOBAL_ATTRIBUTE10,             --global_attribute10
              X_GLOBAL_ATTRIBUTE11,             --global_attribute11
              X_GLOBAL_ATTRIBUTE12,             --global_attribute12
              X_GLOBAL_ATTRIBUTE13,             --global_attribute13
              X_GLOBAL_ATTRIBUTE14,             --global_attribute14
              X_GLOBAL_ATTRIBUTE15,             --global_attribute15
              X_GLOBAL_ATTRIBUTE16,             --global_attribute16
              X_GLOBAL_ATTRIBUTE17,             --global_attribute17
              X_GLOBAL_ATTRIBUTE18,             --global_attribute18
              X_GLOBAL_ATTRIBUTE19,             --global_attribute19
              X_GLOBAL_ATTRIBUTE20, */          --global_attribute20
              SYSDATE,                          --creation_date
              G_USER_ID,                        --created_by
              G_USER_ID,                        --last_updated_by
              SYSDATE,                          --last_updated_date
              G_LOGIN_ID,                       --last_update_login
              NULL,                             --program_application_id
              NULL,                             --program_id
              NULL,                             --program_update_date
              NULL,                             --request_id
              AIL.SHIP_TO_LOCATION_ID,         --ship_to_location_id
              G_INTENDED_USE,        --primary_intended_use
              G_PRODUCT_FISC_CLASS, --product_fisc_classification
              G_TRX_BUSINESS_CATEGORY,          --trx_business_category
              G_PRODUCT_TYPE,                --product_type
              G_PRODUCT_CATEGORY,            --product_category
              G_USER_DEFINED_FISC_CLASS,      --user_defined_fisc_class
	      G_ASSESSABLE_VALUE,
	      G_dflt_tax_class_code,
	      X_COST_FACTOR_ID		       --cost_factor_id
        FROM  AP_INVOICE_LINES AIL
        WHERE AIL.INVOICE_ID = X_INVOICE_ID
          AND AIL.LINE_NUMBER = X_ITEM_LINE_NUMBER;

    END IF;

    g_max_invoice_line_number := g_max_invoice_line_number + 1;

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

--

PROCEDURE Insert_Invoice_Distributions (
                    X_Invoice_ID          IN     NUMBER,
                    X_Invoice_Line_Number IN     NUMBER,
                    X_Dist_Tab            IN OUT NOCOPY AP_MATCHING_PKG.Dist_Tab_Type,
                    X_Final_Match_Flag    IN     VARCHAR2,
                    X_Unit_Price          IN     NUMBER,
                    X_Total_Amount        IN     NUMBER,
                    X_Calling_Sequence    IN     VARCHAR2)
IS
  i                               NUMBER;
  l_distribution_line_number      NUMBER := 1;
  l_debug_info                    VARCHAR2(2000);
  current_calling_sequence        VARCHAR2(2000);
  l_api_name 			  VARCHAR2(50);
  l_copy_line_dff_flag    VARCHAR2(1); -- Bug 6837035
BEGIN
  current_calling_sequence := 'Insert_Invoice_Distributions <-'||x_calling_sequence;

  l_api_name := 'Insert_Invoice_Distributions';

  l_debug_info := 'Insert Invoice Distributions';
  -- Bug 6837035 Retrieve the profile value to check if the DFF info should be
  -- copied onto distributions for imported lines.
  l_copy_line_dff_flag := NVL(fnd_profile.value('AP_COPY_INV_LINE_DFF'),'N');

  FOR i in nvl(X_Dist_tab.FIRST, 0) .. nvl(X_Dist_tab.LAST, 0) LOOP

     IF (x_dist_tab.exists(i)) THEN

       l_debug_info := 'x_dist_tab.invoice_distribution_id,dist_ccid is '||x_dist_tab(i).invoice_distribution_id||','||x_dist_tab(i).dist_ccid;

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
		--bugfix:5565310
                intended_use,
                accrual_posted_flag,    -- Bug 5355077
                cash_posted_flag,       -- Bug 5355077
		--Freight and Special Charges
		rcv_charge_addition_flag
                )
         SELECT g_batch_id,                      --batch_id
                x_invoice_id,                    --invoice_id
                x_invoice_line_number,           --invoice_line_number
                x_dist_tab(i).invoice_distribution_id, --invoice_distribution_id
                l_distribution_line_number,     --distribution_line_number
                decode(g_invoice_type_lookup_code, 'PREPAYMENT', 'ITEM', -- bug 9081676: modify
                  decode (pd.accrue_on_receipt_flag,'Y',
      	        	'ACCRUAL','ITEM')),      --line_type_lookup_code
                ail.item_description,           --description
                'ITEM_TO_SERVICE_PO',           --dist_match_type
                'PERMANENT',                    --distribution_class
                ail.org_id,                     --org_id
                x_dist_tab(i).dist_ccid,        --dist_code_combination_id
                ail.accounting_date,            --accounting_date
                ail.period_name,                --period_name
                NULL,                           --amount_to_post
                NULL,                           --base_amount_to_post
                NULL,                           --posted_amount
                NULL,                           --posted_base_amount
                NULL,                           --je_batch_id
                NULL,                           --cash_je_batch_id
                'N',                            --posted_flag
                NULL,                           --accounting_event_id
                NULL,                           --upgrade_posted_amt
                NULL,                           --upgrade_base_posted_amt
                g_set_of_books_id,              --set_of_books_id
                x_dist_tab(i).amount,           --amount
                x_dist_tab(i).base_amount,      --base_amount
                x_dist_tab(i).rounding_amt,     --rounding_amount
		--bugfix:4959567
                NULL,                           --match_status_flag
                'N',                            --encumbered_flag
                NULL,                           --packet_id
             -- Removed for bug 4277744
             -- NVL(PD.ussgl_transaction_code,
             --   ail.ussgl_transaction_code),  --ussgl_transaction_code
             -- NULL,                           --ussgl_trx_code_context
                'N',                            --reversal_flag
                NULL,                           --parent_reversal_id
                'N',                            --cancellation_flag
                DECODE(ail.type_1099,'','',
                        ail.income_tax_region), --income_tax_region
                ail.type_1099,                  --type_1099
                NULL,                           --stat_amount
                NULL,                           --charge_applicable_to_dist_id
                NULL,                           --prepay_amount_remaining
                NULL,                           --prepay_distribution_id
                NULL,                           --parent_invoice_id
                NULL,                           --corrected_invoice_dist_id
                NULL,                           --corrected_quantity
                NULL,                           --other_invoice_id
                x_dist_tab(i).po_distribution_id,--po_distribution_id
                NULL,                           --rcv_transaction_id
                x_dist_tab(i).unit_price,       --unit_price
                ail.unit_meas_lookup_code,      --matched_uom_lookup_code
                x_dist_tab(i).quantity_invoiced,--quantity_invoiced
                x_final_match_flag,             --final_match_flag
                NULL,                           --related_id
                'U',                            --assets_addition_flag
                decode(gcc.account_type,'E',ail.assets_tracking_flag,'A','Y','N'),  --assets_tracking_flag
                decode(decode(gcc.account_type,'E',ail.assets_tracking_flag,'A','Y','N'),
                        'Y',ail.asset_book_type_code,NULL),                   --asset_book_type_code
                decode(decode(gcc.account_type,'E',ail.assets_tracking_flag,'A','Y','N'),
                                 'Y',ail.asset_category_id,NULL),            --asset_category_id
                x_dist_tab(i).project_id ,              --project_id
                x_dist_tab(i).task_id    ,              --task_id
                x_dist_tab(i).expenditure_type,         --expenditure_type
                x_dist_tab(i).expenditure_item_date,    --expenditure_item_date
                x_dist_tab(i).expenditure_organization_id , --expenditure_organization_id
                x_dist_tab(i).pa_quantity,              --pa_quantity
		decode(PD.project_id,NULL, 'E',
			decode(pd.destination_type_code,'SHOP FLOOR','M',
				'INVENTORY','M','N')), --pa_addition_flag
                NULL,                                   --pa_cc_ar_invoice_id
                NULL,                                   --pa_cc_ar_invoice_line_num
                NULL,                                   --pa_cc_processed_code
                NULL,          				--award_id
                NULL,                                   --gms_burdenable_raw_cost
                NULL,                                   --awt_flag
                x_dist_tab(i).awt_group_id,             --awt_group_id
                NULL,                                   --awt_tax_rate_id
                NULL,                                   --awt_gross_amount
                NULL,                                   --awt_invoice_id
                NULL,                                   --awt_origin_group_id
                NULL,                                   --awt_invoice_payment_id
                NULL,                                   --awt_withheld_amt
                'N',                                    --inventory_transfer_status
                NULL,                                   --reference_1
                NULL,                                   --reference_2
                NULL,                                   --receipt_verified_flag
                NULL,                                   --receipt_required_flag
                NULL,                                   --receipt_missing_flag
                NULL,                                   --justification
                NULL,                                   --expense_group
                NULL,                                   --start_expense_date
                NULL,                                   --end_expense_date
                NULL,                                   --receipt_currency_code
                NULL,                                   --receipt_conversion_rate
                NULL,                                   --receipt_currency_amount
                NULL,                                   --daily_amount
                NULL,                                   --web_parameter_id
                NULL,                                   --adjustment_reason
                NULL,                                   --merchant_document_number
                NULL,                                   --merchant_name
                NULL,                                   --merchant_reference
                NULL,                                   --merchant_tax_reg_number
                NULL,                                   --merchant_taxpayer_id
                NULL,                                   --country_of_supply
                NULL,                                   --credit_card_trx_id
                NULL,                                   --company_prepaid_invoice_id
                NULL,                                   --cc_reversal_flag
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
                X_GLOBAL_ATTRIBUTE2,*/
		--Bugfix:4674194
		DECODE(AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_OPTION,
		       'Y',ail.ship_to_location_id, ''),
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
                ail.created_by,                 --created_by
                sysdate,                        --creation_date
                ail.last_updated_by,            --last_updated_by
                sysdate,                        --last_update_date
                ail.last_update_login,          --last_update_login
                NULL,                           --program_application_id
                NULL,                           --program_id
                NULL,                           --program_update_date
                NULL,                           --request_id
                --bugfix:5565310
                g_intended_use,              --intended_use
                'N',                            --accrual_posted_flag
		'N',                            --cash_posted_flag
                'N'                             --rcv_charge_addition_flag
          FROM  po_distributions pd,
                ap_invoice_lines ail,
                gl_code_combinations gcc
         WHERE ail.invoice_id = x_invoice_id
           AND ail.line_number = x_invoice_line_number
           AND ail.po_line_location_id = pd.line_location_id
           AND pd.po_distribution_id = x_dist_tab(i).po_distribution_id
           AND gcc.code_combination_id = x_dist_tab(i).dist_ccid;

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

--

PROCEDURE Create_Charge_Lines(
                    X_Invoice_Id          IN  NUMBER,
		    X_Freight_Cost_Factor_Id IN NUMBER,
                    X_Freight_Amount      IN  NUMBER,
                    X_Freight_Description IN  VARCHAR2,
		    X_Misc_Cost_Factor_Id IN  NUMBER,
                    X_Misc_Amount         IN  NUMBER,
                    X_Misc_Description    IN  VARCHAR2,
                    X_Item_Line_Number    IN  NUMBER,
                    X_Calling_Sequence    IN  VARCHAR2)
IS
  l_debug_info    VARCHAR2(2000);
  current_calling_sequence        VARCHAR2(2000);

BEGIN

  current_calling_sequence := 'Create_Charge_Lines<-'||X_Calling_Sequence;

  IF (X_Freight_Amount IS NOT NULL) THEN

    l_debug_info := 'Create Freight Line';

    Insert_Invoice_Line(
                         X_Invoice_Id          => x_invoice_id,
                         X_Invoice_Line_Number => g_max_invoice_line_number + 1,
                         X_Line_Type_Lookup_Code => 'FREIGHT',
			 X_Cost_Factor_Id        => x_freight_cost_factor_id,
                         X_Amount                => x_freight_amount,
                         X_Item_Line_Number      => x_item_line_number,
                         X_Charge_Line_Description => x_freight_description,
                         X_Calling_Sequence      => current_calling_sequence);


    l_debug_info := 'Create Allocation Rules for the freight line';

    AP_ALLOCATION_RULES_PKG.Insert_Percentage_Alloc_Rule(
                      X_Invoice_id           => x_invoice_id,
                      X_Chrg_Line_Number     => g_max_invoice_line_number,
                      X_To_Line_Number       => x_item_line_number,
                      X_Percentage           => 100,
                      X_Calling_Sequence     => x_calling_sequence);


  END IF;

  IF (X_Misc_Amount IS NOT NULL) THEN

    l_debug_info := 'Create Misc Line';

    Insert_Invoice_Line(
                        X_Invoice_Id          => x_invoice_id,
                        X_Invoice_Line_Number => g_max_invoice_line_number + 1,
                        X_Line_Type_Lookup_Code => 'MISCELLANEOUS',
			X_Cost_Factor_Id      => x_misc_cost_factor_id,
                        X_Amount                => x_misc_amount,
                        X_Item_Line_Number      => x_item_line_number,
                        X_Charge_Line_Description => x_misc_description,
                        X_Calling_Sequence      => current_calling_sequence);

    l_debug_info := 'Create Allocation Rules for the misc line';

    AP_ALLOCATION_RULES_PKG.Insert_Percentage_Alloc_Rule(
                            X_Invoice_id           => x_invoice_id,
                            X_Chrg_Line_Number     => g_max_invoice_line_number,
                            X_To_Line_Number       => x_item_line_number,
                            X_Percentage           => 100,
                            X_Calling_Sequence     => x_calling_sequence);

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
                          ||', Item Line Number = '||TO_CHAR(X_Item_Line_Number));
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;

END Create_Charge_Lines;


/*===========================================================================+
 |      PRICE CORRECTION OF INVOICE MATCHED TO PO                            |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Amount_Correct_Inv_PO(
                X_Invoice_Id            IN      NUMBER,
                X_Invoice_Line_Number   IN      NUMBER,
                X_Corrected_Invoice_Id  IN      NUMBER,
                X_Corrected_Line_Number IN      NUMBER,
                X_Match_Mode            IN      VARCHAR2,
                X_Correction_Amount     IN      NUMBER,
                X_Po_Line_Location_Id   IN      NUMBER,
                X_Corr_Dist_Tab         IN OUT NOCOPY AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
                X_Final_Match_Flag      IN      VARCHAR2,
                X_Uom_Lookup_Code       IN      VARCHAR2,
		X_Retained_Amount	IN	NUMBER DEFAULT NULL,
                X_Calling_Sequence      IN      VARCHAR2) IS

l_po_distribution_id     PO_DISTRIBUTIONS.PO_DISTRIBUTION_ID%TYPE := NULL;
l_item_line_number       AP_INVOICE_LINES_ALL.LINE_NUMBER%TYPE;
l_amount_to_recoup       AP_INVOICE_LINES_ALL.AMOUNT%TYPE;
l_line_amt_net_retainage        ap_invoice_lines_all.amount%TYPE;
l_max_amount_to_recoup		ap_invoice_lines_all.amount%TYPE;
l_retained_amount		ap_invoice_lines_all.retained_amount%TYPE;
l_success                BOOLEAN;
l_error_message          VARCHAR2(4000);
l_debug_info             VARCHAR2(2000);
current_calling_sequence VARCHAR2(2000);
l_api_name      	 VARCHAR2(32);

BEGIN

   l_api_name := 'Amount_Correct_Inv_PO';

   current_calling_sequence := 'Amount_Correct_Inv_PO<-'||x_calling_sequence;

   Get_Info(x_invoice_id  => x_invoice_id,
            x_invoice_line_number => x_invoice_line_number,
            x_match_amount        => x_correction_amount,
            x_po_line_location_id => x_po_line_location_id,
            x_calling_sequence => current_calling_sequence);

   IF g_invoice_type_lookup_code <> 'PREPAYMENT' THEN
      l_retained_amount := AP_INVOICE_LINES_UTILITY_PKG.Get_Retained_Amount
                                        (p_line_location_id => x_po_line_location_id,
                                         p_match_amount     => x_correction_amount);
   END IF;

   Get_Corr_Dist_Proration_Info(
            x_corrected_invoice_id  => x_corrected_invoice_id,
            x_corrected_line_number => x_corrected_line_number,
            x_corr_dist_tab         => x_corr_dist_tab,
            x_correction_amount     => x_correction_amount,
            x_match_mode            => x_match_mode,
            x_calling_sequence      => current_calling_sequence);

   IF (x_corr_dist_tab.COUNT = 1) THEN

      l_po_distribution_id := x_corr_dist_tab.FIRST;

   END IF;

   IF (x_invoice_line_number IS NULL) THEN

        Insert_Corr_Invoice_Line(x_invoice_id            => x_invoice_id,
                                 x_invoice_line_number   => g_max_invoice_line_number +1,
                                 x_corrected_invoice_id  => x_corrected_invoice_id,
                                 x_corrected_line_number => x_corrected_line_number,
                                 x_amount             => x_correction_amount,
                                 x_final_match_flag   => x_final_match_flag,
                                 x_po_distribution_id => l_po_distribution_id,
				 x_retained_amount    => l_retained_amount,
                                 x_calling_sequence   => current_calling_sequence);

   END IF;

   l_item_line_number := g_max_invoice_line_number;

   Insert_Corr_Invoice_Dists(x_invoice_id          => x_invoice_id,
                             x_invoice_line_number => nvl(x_invoice_line_number,
                                                          g_max_invoice_line_number),
			     x_corrected_invoice_id => x_corrected_invoice_id,
                             x_corr_dist_tab       => x_corr_dist_tab,
                             x_final_match_flag    => x_final_match_flag,
                             x_total_amount        => x_correction_amount,
                             x_calling_sequence    => current_calling_sequence);


   IF(x_invoice_line_number IS NOT NULL) THEN

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
                         x_invoice_line_number => nvl(x_invoice_line_number,g_max_invoice_line_number));

   IF (g_recoupment_rate is not null and x_correction_amount > 0
   		and g_invoice_type_lookup_code <> 'PREPAYMENT') THEN

      l_debug_info := 'Calculate the maximum amount that can be recouped from this invoice line';

      l_line_amt_net_retainage := x_correction_amount + nvl(l_retained_amount,0);

      l_max_amount_to_recoup := ap_utilities_pkg.ap_round_currency(
     				(x_correction_amount * g_recoupment_rate / 100) ,g_invoice_currency_code);

      IF (l_line_amt_net_retainage < l_max_amount_to_recoup) THEN
        l_amount_to_recoup := l_line_amt_net_retainage;
      ELSE
        l_amount_to_recoup := l_max_amount_to_recoup;
      END IF;

      l_debug_info := 'Automatically recoup any available prepayments against the same po line';

      l_success := AP_Matching_Utils_Pkg.Ap_Recoup_Invoice_Line(
                                P_Invoice_Id           => x_invoice_id ,
                                P_Invoice_Line_Number  => nvl(x_invoice_line_number,g_max_invoice_line_number) ,
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


   Update_Corr_Po_Shipments_Dists(x_corr_dist_tab    => x_corr_dist_tab,
				x_po_line_location_id => x_po_line_location_id,
                                x_amount              => x_correction_amount,
                                x_uom_lookup_code  => x_uom_lookup_code,
                                x_calling_sequence => current_calling_sequence);


   --Clean up the PL/SQL tables
   x_corr_dist_tab.delete;

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
                ||', match_mode = '||x_match_mode
                ||', correction amount = '||to_char(x_correction_amount)
                ||', final_match_flag = '||x_final_match_flag
                ||', po_line_location_id = '||to_char(x_po_line_location_id));
            fnd_message.set_token('DEBUG_INFO',l_debug_info);
        End if;

        --Clean up the PL/SQL tables
        x_corr_dist_tab.delete;

        app_exception.raise_exception;

END Amount_Correct_Inv_PO;

--

PROCEDURE Get_Corr_Dist_Proration_Info(
                        x_corrected_invoice_id  IN    NUMBER,
                        x_corrected_line_number IN    NUMBER,
                        x_corr_dist_tab IN OUT NOCOPY AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
                        x_correction_amount   IN NUMBER,
                        x_match_mode          IN VARCHAR2,
                        x_calling_sequence    IN VARCHAR2) IS


CURSOR Amount_Correction_Cursor IS
  SELECT aid.invoice_distribution_id corrected_inv_dist_id,
         aid.po_distribution_id,
         decode(g_min_acct_unit,'',
                round(x_correction_amount * aid.amount/ail.amount,
                      g_precision),
                round((x_correction_amount * aid.amount/ail.amount)
                      /g_min_acct_unit) * g_min_acct_unit
                ) amount,
         aid.dist_code_combination_id,
         ap_invoice_distributions_s.nextval
  FROM  ap_invoice_lines ail,
        ap_invoice_distributions aid
  WHERE ail.invoice_id = x_corrected_invoice_id
  AND ail.line_number = x_corrected_line_number
  AND aid.invoice_id = ail.invoice_id
  AND aid.invoice_line_number = ail.line_number
   -- Bug 5585744, Modified the condition below
  AND aid.line_type_lookup_code IN ('ITEM', 'ACCRUAL')
  AND aid.prepay_distribution_id IS NULL;
  /*AND aid.line_type_lookup_code NOT IN ('PREPAY','AWT','RETAINAGE')
  AND (aid.line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX')
       OR aid.prepay_distribution_id IS NULL); */

l_corrected_inv_dist_id   ap_invoice_distributions.corrected_invoice_dist_id%TYPE;
l_amount                  ap_invoice_distributions.amount%TYPE;
l_base_amount             ap_invoice_distributions.base_amount%TYPE;
l_invoice_distribution_id ap_invoice_distributions.invoice_distribution_id%TYPE;
l_max_dist_amount         ap_invoice_distributions.amount%TYPE := 0;
l_sum_prorated_amount     ap_invoice_distributions.amount%TYPE := 0;
l_rounding_index          ap_invoice_distributions.invoice_distribution_id%TYPE;
l_sum_dist_base_amount    ap_invoice_distributions.base_amount%TYPE := 0;
l_dist_ccid               ap_invoice_distributions.dist_code_combination_id%TYPE;
l_po_dist_id              ap_invoice_distributions.po_distribution_id%TYPE;
l_debug_info              varchar2(2000);
current_calling_sequence  varchar2(2000);

BEGIN

  current_calling_sequence := 'Get_Corr_Dist_Proration_Info<-'||x_calling_sequence;

   -- Bug 5585744. using invoice_distribution_id as index in place of po_distribution_id
   IF (x_match_mode IN ('STD-PS','CR-PS')) THEN

     OPEN amount_correction_cursor;

     LOOP

       FETCH amount_correction_cursor INTO l_corrected_inv_dist_id,
                                        l_po_dist_id,
                                        l_amount,
                                        l_dist_ccid,
                                        l_invoice_distribution_id;

       EXIT WHEN amount_correction_cursor%NOTFOUND;

       x_corr_dist_tab(l_invoice_distribution_id).po_distribution_id := l_po_dist_id;
       x_corr_dist_tab(l_invoice_distribution_id).invoice_distribution_id := l_invoice_distribution_id;
       x_corr_dist_tab(l_invoice_distribution_id).corrected_inv_dist_id := l_corrected_inv_dist_id;
       x_corr_dist_tab(l_invoice_distribution_id).amount := l_amount;
       x_corr_dist_tab(l_invoice_distribution_id).corrected_quantity := 0;
       x_corr_dist_tab(l_invoice_distribution_id).unit_price := 0;
       x_corr_dist_tab(l_invoice_distribution_id).pa_quantity := 0;
       x_corr_dist_tab(l_invoice_distribution_id).dist_ccid := l_dist_ccid;

       --Calculate the index of the max of the largest distribution for
       --proration/base amount rounding.
       IF (l_amount >= l_max_dist_amount) THEN
         l_rounding_index := l_invoice_distribution_id;
         l_max_dist_amount := l_max_dist_amount;
       END IF;

       l_sum_prorated_amount := l_sum_prorated_amount + l_amount;

     END LOOP;

     CLOSE amount_correction_cursor;

   --For the case when user distributes the correction, we still
   --need to populate the PL/SQL table with invoice_distribution_id...
   ELSIF (x_match_mode IN ('STD-PD','CR-PD')) THEN

     FOR i IN nvl(x_corr_dist_tab.first,0) ..nvl(x_corr_dist_tab.last,0) LOOP

       IF (x_corr_dist_tab.exists(i)) THEN

         SELECT ap_invoice_distributions_s.nextval
         INTO x_corr_dist_tab(i).invoice_distribution_id
         FROM DUAL;

         x_corr_dist_tab(i).corrected_quantity := Null;
         x_corr_dist_tab(i).pa_quantity := Null;

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

   END IF; /*x_match_mode  */

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
   IF (g_exchange_rate IS NOT NULL AND g_line_base_amount <> l_sum_dist_base_amount
       and l_rounding_index is not null) THEN

      x_corr_dist_tab(l_rounding_index).base_amount :=
                                      x_corr_dist_tab(l_rounding_index).base_amount +
                                       (g_line_base_amount - l_sum_dist_base_amount);

      x_corr_dist_tab(l_rounding_index).rounding_amt := g_line_base_amount
                                                        - l_sum_dist_base_amount;

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
           ||', correction amount = '||to_char(x_correction_amount));
      fnd_message.set_token('DEBUG_INFO',l_debug_info);
    End if;
    --Clean up the PL/SQL tables on error
    x_corr_dist_tab.delete;

    app_exception.raise_exception;

END Get_Corr_Dist_Proration_Info;

--

PROCEDURE Update_Corr_Po_Shipments_Dists(
                    X_Corr_Dist_Tab    IN  AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
    		    X_Po_Line_Location_Id IN NUMBER,
    		    X_Amount              IN NUMBER,
                    X_Uom_Lookup_Code     IN VARCHAR2,
		    X_Calling_Sequence    IN VARCHAR2) IS

i       NUMBER;
l_po_ap_dist_rec          PO_AP_DIST_REC_TYPE;
l_po_ap_line_loc_rec      PO_AP_LINE_LOC_REC_TYPE;
l_api_name    		  VARCHAR2(50);
l_return_status                VARCHAR2(100);
l_msg_data                     VARCHAR2(4000);
l_debug_info  VARCHAR2(2000);
current_calling_sequence  VARCHAR2(2000);
BEGIN
   l_api_name := 'Update_Corr_Po_Shipments_Dists';

   current_calling_sequence := 'Update_Corr_Po_Shipments_Dists<-'||x_calling_sequence;

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PO_AMT_MATCH_PKG.Update_Corr_Po_Distributions(+)');
   END IF;

   l_debug_info := 'Create l_po_ap_dist_rec object';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   l_po_ap_dist_rec := PO_AP_DIST_REC_TYPE.create_object();

   l_debug_info := 'Create l_po_ap_line_loc_rec object';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   l_po_ap_line_loc_rec := PO_AP_LINE_LOC_REC_TYPE.create_object(
                                 p_po_line_location_id => x_po_line_location_id,
                                 p_uom_code            => x_uom_lookup_code,
                                 p_quantity_billed     => NULL,
                                 p_amount_billed       => x_amount,
                                 p_quantity_financed   => NULL,
                                 p_amount_financed     => NULL,
                                 p_quantity_recouped   => NULL,
                                 p_amount_recouped     => NULL,
                                 p_retainage_withheld_amt => NULL,
                                 p_retainage_released_amt => NULL
                                );

   --bugfix:4742961 added the NVL condition
   l_debug_info := 'Populate l_po_ap_line_loc_rec object with data';
   FOR i in nvl(x_corr_dist_tab.first,0)..nvl(x_corr_dist_tab.last,0) LOOP

     IF (x_corr_dist_tab.exists(i)) THEN

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
         FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_PO_AMT_MATCH_PKG.Update_Corr_Po_Shipments_Dists(-)');
   END IF;


EXCEPTION
WHEN others then
    If (SQLCODE <> -20001) Then
        fnd_message.set_name('SQLAP','AP_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS',
                  ' po_line_location_id = '||to_char(x_po_line_location_id));
        fnd_message.set_token('DEBUG_INFO',l_debug_info);
    End if;

    app_exception.raise_exception;

END Update_Corr_Po_Shipments_Dists;

--

PROCEDURE Update_Corr_Po_Line_Locations(
                        x_po_line_location_id  IN NUMBER,
                        x_amount               IN NUMBER,
                        x_uom_lookup_code      IN VARCHAR2,
                        x_calling_sequence     IN VARCHAR2) IS

l_debug_info    VARCHAR2(2000);
current_calling_sequence        VARCHAR2(2000);

BEGIN

   current_calling_sequence := ' Update_Corr_Po_Line_Locations<-'||x_calling_sequence;

   l_debug_info := 'Call PO api to update the po_line_location with quantity/amount billed
                    information';


    RCV_BILL_UPDATING_SV.ap_update_po_line_locations(
                x_po_line_location_id   => x_po_line_location_id,
                x_quantity_billed => Null,
                x_uom_lookup_code => x_uom_lookup_code,
                x_amount_billed   => x_amount,
                x_matching_basis  => 'AMOUNT');


EXCEPTION
WHEN others then
    If (SQLCODE <> -20001) Then
        fnd_message.set_name('SQLAP','AP_DEBUG');
        fnd_message.set_token('ERROR',SQLERRM);
        fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
        fnd_message.set_token('PARAMETERS',
                    '  po_line_location_id = '||to_char(x_po_line_location_id)
                  ||', amount = '|| to_char(x_amount));
        fnd_message.set_token('DEBUG_INFO',l_debug_info);
    End if;
    app_exception.raise_exception;

END Update_Corr_Po_Line_Locations;

--

PROCEDURE Insert_Corr_Invoice_Line(x_invoice_id            IN NUMBER,
                                   x_invoice_line_number   IN NUMBER,
                                   x_corrected_invoice_id  IN NUMBER,
                                   x_corrected_line_number IN NUMBER,
                                   x_amount                IN NUMBER,
                                   x_final_match_flag      IN VARCHAR2,
                                   x_po_distribution_id    IN NUMBER,
				   x_retained_amount	   IN NUMBER DEFAULT NULL,
                                   x_calling_sequence      IN VARCHAR2 ) IS

l_debug_info    VARCHAR2(2000);
current_calling_sequence   VARCHAR2(2000);

BEGIN

   current_calling_sequence := 'Insert_Corr_Invoice_Line<-'||x_calling_sequence;

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
                                USER_DEFINED_FISC_CLASS
                               )
                        SELECT  x_invoice_id,                   --invoice_id
                                x_invoice_line_number,          --line_number
                                'ITEM',                         --line_type_lookup_code
                                ail.requester_id,               --requester_id
                                ail.description,                --description
                                'HEADER CORRECTION',            --line_source
                                ail.org_id,                     --org_id
                                ail.inventory_item_id,          --inventory_item_id
                                ail.item_description,           --item_description
                                ail.serial_number,              --serial_number
                                ail.manufacturer,               --manufacturer
                                ail.model_number,               --model_number
                                'D',                            --generate_dists
                                'AMOUNT_CORRECTION',            --match_type
                                NULL,                           --distribution_set_id
                                ail.account_segment,            --account_segment
                                ail.balancing_segment,          --balancing_segment
                                ail.cost_center_segment,        --cost_center_segment
                                ail.overlay_dist_code_concat,   --overlay_dist_code_concat
                                ail.default_dist_ccid,          --default_dist_ccid
                                'N',                            --prorate_across_all_items
                                NULL,                           --line_group_number
                                g_accounting_date,              --accounting_date
                                g_period_name,                  --period_name
                                'N',                            --deferred_acctg_flag
                                NULL,                           --def_acctg_start_date
                                NULL,                           --def_acctg_end_date
                                NULL,                           --def_acctg_number_of_periods
                                NULL,                           --def_acctg_period_type
                                g_set_of_books_id,              --set_of_books_id
                                x_amount,                       --amount
                                AP_UTILITIES_PKG.Ap_Round_Currency(
                                   NVL(X_AMOUNT, 0) * G_EXCHANGE_RATE,
                                        G_BASE_CURRENCY_CODE),  --base_amount
                                NULL,                           --rounding_amount
                                Null,                           --quantity_invoiced
                                ail.unit_meas_lookup_code,      --unit_meas_lookup_code
                                NULL,                           --unit_price
                                decode(g_approval_workflow_flag,'Y'
                                      ,'REQUIRED','NOT REQUIRED'),--wf_approval_status
                             -- Bug 4277744
                             -- g_ussgl_transaction_code,       --ussgl_transaction_code
                                'N',                            --discarded_flag
                                NULL,                           --original_amount
                                NULL,                           --original_base_amount
                                NULL,                           --original_rounding_amt
                                'N',                            --cancelled_flag
                                g_income_tax_region,            --income_tax_region
                                pll.type_1099,                  --type_1099
                                NULL,                           --stat_amount
                                NULL,                           --prepay_invoice_id
                                NULL,                           --prepay_line_number
                                NULL,                           --invoice_includes_prepay_flag
                                x_corrected_invoice_id,         --corrected_invoice_id
                                x_corrected_line_number,        --corrected_line_number
                                ail.po_header_id,               --po_header_id
                                ail.po_line_id,                 --po_line_id
                                ail.po_release_id,              --release_id
                                ail.po_line_location_id,        --po_line_location_id
                                nvl(ail.po_distribution_id,
                                    x_po_distribution_id),      --po_distribution_id
                                NULL,                           --rcv_transaction_id
                                 x_final_match_flag,             --final_match_flag
                                ail.assets_tracking_flag,       --assets_tracking_flag
                                ail.asset_book_type_code,       --asset_book_type_code
                                ail.asset_category_id,          --asset_category_id
                                ail.project_id,                 --project_id
                                ail.task_id,                    --task_id
                                ail.expenditure_type,           --expenditure_type
                                ail.expenditure_item_date,      --expenditure_item_date
                                ail.expenditure_organization_id, --expenditure_organization_id
                                NULL,                           --pa_quantity
                                NULL,                           --pa_cc_ar_invoice_id
                                NULL,                           --pa_cc_ar_invoice_line_num
                                NULL,                           --pa_cc_processed_code
                                ail.award_id,                   --award_id
                                g_awt_group_id,                 --awt_group_id
                                ail.reference_1,                --reference_1
                                ail.reference_2,                --reference_2
                                ail.receipt_verified_flag,      --receipt_verified_flag
                                ail.receipt_required_flag,      --receipt_required_flag
                                ail.receipt_missing_flag,       --receipt_missing_flag
                                ail.justification,              --ail.justification
                                ail.expense_group,              --ail.expense_group
                                ail.start_expense_date,         --start_expense_date
                                ail.end_expense_date,           --end_expense_date
                                ail.receipt_currency_code,      --receipt_currency_code
                                ail.receipt_conversion_rate,    --receipt_conversion_rate
                                ail.receipt_currency_amount,    --receipt_currency_amount
                                ail.daily_amount,               --daily_amount
                                ail.web_parameter_id,           --web_parameter_id
                                ail.adjustment_reason,          --adjustment_reason
                                ail.merchant_document_number,   --merchant_document_number
                                ail.merchant_name,              --merchant_name
                                ail.merchant_reference,         --merchant_reference
                                ail.merchant_tax_reg_number,    --merchant_tax_reg_number
                                ail.merchant_taxpayer_id,       --merchant_taxpayer_id
                                ail.country_of_supply,          --country_of_supply
                                ail.credit_card_trx_id,         --credit_card_trx_id
                                ail.company_prepaid_invoice_id, --cpmany_prepaid_invoice_id
                                ail.cc_reversal_flag,           --cc_reversal_flag
                                ail.attribute_category,         --attribute_category
                                ail.attribute1,                 --attribute1
                                ail.attribute2,                 --attribute2
                                ail.attribute3,                 --attribute3
                                ail.attribute4,                 --attribute4
                                ail.attribute5,                 --attribute5
                                ail.attribute6,                 --attribute6
                                ail.attribute7,                 --attribute7
                                ail.attribute8,                 --attribute8
                                ail.attribute9,                 --attribute9
                                ail.attribute10,                --attribute10
                                ail.attribute11,                --attribute11
                                ail.attribute12,                --attribute12
                                ail.attribute13,                --attribute13
                                ail.attribute14,                --attribute14
                                ail.attribute15,                --attribute15
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
                                sysdate,                        --creation_date
                                g_user_id,                      --created_by
                                g_user_id,                      --last_updated_by
                                sysdate,                        --last_update_date
                                g_login_id,                     --user_login_id
                                NULL,                           --program_application_id
                                NULL,                           --program_id
                                NULL,                           --program_update_date
                                NULL,                           --request_id
				X_RETAINED_AMOUNT,		--retained_amount
				(-X_RETAINED_AMOUNT),		--retained_amount_remaining
                                 --ETAX: Invwkb
                                PLL.SHIP_TO_LOCATION_ID,         --ship_to_location_id
                                AIL.PRIMARY_INTENDED_USE,        --primary_intended_use
                                AIL.PRODUCT_FISC_CLASSIFICATION, --product_fisc_classification
                                G_TRX_BUSINESS_CATEGORY,         --trx_business_category
                                AIL.PRODUCT_TYPE,                --product_type
                                AIL.PRODUCT_CATEGORY,            --product_category
                                AIL.USER_DEFINED_FISC_CLASS      --user_defined_fisc_class
                        FROM  ap_invoices ai,
                              ap_invoice_lines ail,
                              po_line_locations_ap_v pll
                        WHERE ai.invoice_id = x_corrected_invoice_id
                        AND   ail.invoice_id = ai.invoice_id
                        AND   ail.line_number = x_corrected_line_number
                        AND   pll.line_location_id = ail.po_line_location_id;

    g_max_invoice_line_number := g_max_invoice_line_number + 1;

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
                ||', amount = '||to_char(x_amount)
                ||', final_match_flag = '||x_final_match_flag
                ||', po_distribution_id = '||to_char(x_po_distribution_id));
            fnd_message.set_token('DEBUG_INFO',l_debug_info);
        End if;
        app_exception.raise_exception;

END Insert_Corr_Invoice_Line;

--

PROCEDURE Insert_Corr_Invoice_Dists(x_invoice_id          IN NUMBER,
                                    x_invoice_line_number IN NUMBER,
				    x_corrected_invoice_id IN NUMBER,
                                    x_corr_dist_tab       IN OUT NOCOPY AP_MATCHING_PKG.CORR_DIST_TAB_TYPE,
                                    x_final_match_flag    IN VARCHAR2,
                                    x_total_amount        IN NUMBER,
                                    x_calling_sequence    IN VARCHAR2) IS

 i              NUMBER;
 l_distribution_line_number  ap_invoice_distributions.distribution_line_number%type := 1;
 l_debug_info  VARCHAR2(2000);
 current_calling_sequence VARCHAR2(2000);
 l_api_name VARCHAR2(50);

BEGIN

   current_calling_sequence := 'Insert_Corr_Invoice_Dists<-'||x_calling_sequence;
   l_api_name := 'Insert_Corr_Invoice_Dists';

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
                        /*OPEN ISSUE 1*/
                        /*global_attribute_category,
                         global_attribute1,
                         global_attribute2,*/
			 --Bugfix:4674194
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
                         intended_use,
			 --Freight and Special Charges
                         accrual_posted_flag,   -- Bug 5355077
                         cash_posted_flag,      -- Bug 5355077
			 rcv_charge_addition_flag
                         )
                  SELECT g_batch_id,                    --batch_id
                         x_invoice_id,                  --invoice_id
                         x_invoice_line_number,         --invoice_line_number
                         x_corr_dist_tab(i).invoice_distribution_id, --invoice_distribution_id
                         l_distribution_line_number,    --distribution_line_number
                         aid.line_type_lookup_code,     --line_type_lookup_code
                         ail.description,               --description
                         'AMOUNT_CORRECTION',           --dist_match_type
                         'PERMANENT',                   --distribution_class
                         ail.org_id,                    --org_id
                         x_corr_dist_tab(i).dist_ccid,  --dist_code_combination_id
                         ail.accounting_date,           --accounting_date
                         ail.period_name,               --period_name
                         NULL,                          --amount_to_post
                         NULL,                          --base_amount_to_post
                         NULL,                          --posted_amount
                         NULL,                          --posted_base_amount
                         NULL,                          --je_batch_id
                         NULL,                          --cash_je_batch_id
                         'N',                           --posted_flag
                         NULL,                          --accounting_event_id
                         NULL,                          --upgrade_posted_amt
                         NULL,                          --upgrade_base_posted_amt
                         g_set_of_books_id,             --set_of_books_id
                         x_corr_dist_tab(i).amount,     --amount
                         x_corr_dist_tab(i).base_amount,--base_amount
                         x_corr_dist_tab(i).rounding_amt,--rounding_amount
			 --bugfix:4959567
                         NULL,                          --match_status_flag
                         'N',                           --encumbered_flag
                         NULL,                          --packet_id
                      -- Removed for bug 4277744
                      -- ail.ussgl_transaction_code,    --ussgl_transaction_code
                      -- NULL,                          --ussgl_trx_code_context
                         'N',                           --reversal_flag
                         NULL,                          --parent_reversal_id
                         'N',                           --cancellation_flag
                         DECODE(ail.type_1099,'','',ail.income_tax_region), --income_tax_region
                         ail.type_1099,                 --type_1099
                         NULL,                          --stat_amount
                         NULL,                          --charge_applicable_to_dist_id
                         NULL,                          --prepay_amount_remaining
                         NULL,                          --prepay_distribution_id
                         ail.corrected_inv_id,          --parent_invoice_id
                         x_corr_dist_tab(i).corrected_inv_dist_id, --corrected_invoice_dist_id
                         x_corr_dist_tab(i).corrected_quantity,  --corrected_quantity
                         NULL,                                  --other_invoice_id
                         x_corr_dist_tab(i).po_distribution_id, --po_distribution_id
                         NULL,                                  --rcv_transaction_id
                         x_corr_dist_tab(i).unit_price,         --unit_price
                         aid.matched_uom_lookup_code,           --matched_uom_lookup_code
                         NULL,                                  --quantity_invoiced
                         x_final_match_flag,                    --final_match_flag
                         NULL,                                  --related_id
                         'U',                                   --assets_addition_flag
                         aid.assets_tracking_flag,              --assets_tracking_flag
                         decode(aid.assets_tracking_flag,'Y',
                                ail.asset_book_type_code,NULL), --asset_book_type_code
                         decode(aid.assets_tracking_flag,'Y',
                                ail.asset_category_id,NULL),    --asset_category_id
                         aid.project_id,                        --project_id
                         aid.task_id,                           --task_id
                         aid.expenditure_type,                  --expenditure_type
                         aid.expenditure_item_date,             --expenditure_item_date
                         aid.expenditure_organization_id,       --expenditure_organization_id
                         decode(aid.project_id,'','',
                           x_corr_dist_tab(i).pa_quantity),     --pa_quantity
			 decode(aid.project_id,NULL,'E',
			        decode(pd.destination_type_code,'SHOP FLOOR','M',
			               'INVENTORY','M','N')),   --pa_addition_flag
                         NULL,                                  --pa_cc_ar_invoice_id
                         NULL,                                  --pa_cc_ar_invoice_line_num
                         NULL,                                  --pa_cc_processed_code
                         aid.award_id,                          --award_id
                         NULL,                                  --gms_burdenable_raw_cost
                         NULL,                                  --awt_flag
                         decode(g_system_allow_awt_flag,'Y',
                                decode(g_site_allow_awt_flag,'Y',
                                       ail.awt_group_id,NULL),
                                NULL),                          --awt_group_id
                         NULL,                                  --awt_tax_rate_id
                         NULL,                                  --awt_gross_amount
                         NULL,                                  --awt_invoice_id
                         NULL,                                  --awt_origin_group_id
                         NULL,                                  --awt_invoice_payment_id
                         NULL,                                  --awt_withheld_amt
                        'N',                                   --inventory_transfer_status
                         ail.reference_1,                       --reference_1
                         ail.reference_2,                       --reference_2
                         ail.receipt_verified_flag,             --receipt_verified_flag
                         ail.receipt_required_flag,             --receipt_required_flag
                         ail.receipt_missing_flag,              --receipt_missing_flag
                         ail.justification,                     --justification
                         ail.expense_group,                     --expense_group
                         ail.start_expense_date,                --start_expense_date
                         ail.end_expense_date,                  --end_expense_date
                         ail.receipt_currency_code,             --receipt_currency_code
                         ail.receipt_conversion_rate,           --receipt_conversion_rate
                         ail.receipt_currency_amount,           --receipt_currency_amount
                         ail.daily_amount,                      --daily_amount
                         ail.web_parameter_id,                  --web_parameter_id
                         ail.adjustment_reason,                 --adjustment_reason
                         ail.merchant_document_number,          --merchant_document_number
                         ail.merchant_name,                     --merchant_name
                         ail.merchant_reference,                --merchant_reference
                         ail.merchant_tax_reg_number,           --merchant_tax_reg_number
                         ail.merchant_taxpayer_id,              --merchant_taxpayer_id
                         ail.country_of_supply,                 --country_of_supply
                         ail.credit_card_trx_id,                --credit_card_trx_id
                         ail.company_prepaid_invoice_id,        --company_prepaid_invoice_id
                         ail.cc_reversal_flag,                  --cc_reversal_flag
                         aid.attribute_category,                --attribute_category
                         aid.attribute1,                        --attribute1
                         aid.attribute2,                        --attribute2
                         aid.attribute3,                        --attribute3
                         aid.attribute4,                        --attribute4
                         aid.attribute5,                        --attribute5
                         aid.attribute6,                        --attribute6
                         aid.attribute7,                        --attribute7
                         aid.attribute8,                        --attribute8
                         aid.attribute9,                        --attribute9
                         aid.attribute10,                       --attribute10
                         aid.attribute11,                       --attribute11
                         aid.attribute12,                       --attribute12
                         aid.attribute13,                       --attribute13
                         aid.attribute14,                       --attribute14
                         aid.attribute15,                       --attribute15
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
                         ail.created_by,                --created_by
                         sysdate,                       --creation_date
                         ail.last_updated_by,           --last_updated_by
                         sysdate,                       --last_update_date
                         ail.last_update_login,         --last_update_login
                         NULL,                          --program_application_id
                         NULL,                          --program_id
                         NULL,                          --program_update_date
                         NULL,                          --request_id
                          --ETAX: Invwkb
                         aid.intended_use,              --intended_use
                         'N',                           --accrual_posted_flag
                         'N',                           --cash_posted_flag
			 'N'				--rcv_charge_addition_flag
                    FROM ap_invoice_lines ail,
                         ap_invoice_distributions aid,
			 po_distributions pd
                    WHERE ail.invoice_id = x_invoice_id
                    AND ail.line_number = x_invoice_line_number
                    AND aid.invoice_id = ail.corrected_inv_id
                    AND aid.invoice_line_number = ail.corrected_line_number
                    AND aid.invoice_distribution_id = x_corr_dist_tab(i).corrected_inv_dist_id
		    AND pd.po_distribution_id = aid.po_distribution_id;

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

EXCEPTION
    WHEN others then
        If (SQLCODE <> -20001) Then
            fnd_message.set_name('SQLAP','AP_DEBUG');
            fnd_message.set_token('ERROR',SQLERRM);
            fnd_message.set_token('CALLING_SEQUENCE',current_calling_sequence);
            fnd_message.set_token('PARAMETERS',
                  ' invoice_id = '||to_char(x_invoice_id)
                ||', invoice_line_number =' ||to_char(x_invoice_line_number)
                ||', final_match_flag = '||x_final_match_flag
                ||', total_amount = '||to_char(x_total_amount));
            fnd_message.set_token('DEBUG_INFO',l_debug_info);
        End if;

        --Clean up the PL/SQL tables on error
        x_corr_dist_tab.delete;

        app_exception.raise_exception;

END Insert_Corr_Invoice_Dists;

--

END AP_PO_AMT_MATCH_PKG;

/
