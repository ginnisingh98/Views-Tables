--------------------------------------------------------
--  DDL for Package Body AP_QUICK_CREDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_QUICK_CREDIT_PKG" AS
/* $Header: apqkcreb.pls 120.12 2006/04/13 07:48:26 sfeng noship $ */

    TYPE Inv_Line_Tab_Type   IS TABLE OF ap_invoice_lines_all%ROWTYPE;

/*=============================================================================
 |  FUNCTION - Validating_Rules()
 |
 |  DESCRIPTION
 |      Private function that will validate the rules for the creation of a
 |      credit or debit memo with quick credit functionality.
 |      This function returns TRUE if the reversal for the invoice can go through
 |      or FALSE and an error code if any of the quick credit rules is not
 |      followed.
 |
 |      The following rules are validated in this function:
 |      1.  Check if supplier is the same for CR/DB memo and credited invoice
 |      2.  Check if credited invoice is not a CR/DB memo or prepayment
 |      3.  Check if credited invoice is cancelled
 |      4.  Check if CI contains price or quantity corrections
 |      5.  Check if CI contains prepayment applications
 |      6.  Check if CI contains withholding tax
 |      For each line
 |      7.  Is line fully distributed?
 |      8.  Is quantity or amount billed below 0 after reversal?
 |      9.  Are ccids in the distributions of the line invalid?
 |
 |  PARAMETERS
 |      P_Invoice_Id - invoice id
 |      P_Vendor_Id_For_Invoice  - vendor id for the debit or credit memo
 |      P_Invoice_Header_Rec - header record for the credited invoice
 |      P_Invoice_Lines_Tab - line list for the credited invoice
 |      P_Error_Code - Error code to be returned to the user
 |      P_Calling_Sequence - debug info
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  SYIDNER            Creation
 |
 *============================================================================*/

  FUNCTION Validating_Rules(
               P_Invoice_Id                IN NUMBER,
               P_Vendor_Id_For_Invoice     IN NUMBER,
               P_Dm_Gl_Date                IN DATE,
               P_Invoice_Header_Rec        IN ap_invoices_all%ROWTYPE,
               P_Invoice_Lines_Tab         IN Inv_Line_Tab_Type,
               P_Error_Code                OUT NOCOPY VARCHAR2,
               P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN

  IS
    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);

    i                            BINARY_INTEGER := 0;
    l_chart_of_accounts_id       gl_sets_of_books.chart_of_accounts_id%TYPE;


    TYPE dist_ccid_list_tab
      IS TABLE OF ap_invoice_distributions_all.dist_code_combination_id%TYPE;
    l_dist_ccid_list             dist_ccid_list_tab;
    l_return_var                 BOOLEAN := TRUE;

  BEGIN
    l_curr_calling_sequence := 'AP_QUICK_CREDIT_PKG.Validating_Rules<-' ||
                               P_calling_sequence;

    ------------------------------------------------------------------
    l_debug_info := 'Step 0: Get Chart of Accounts Id for CCID '||
                    'validation';
    ------------------------------------------------------------------

    BEGIN
      SELECT chart_of_accounts_id
        INTO l_chart_of_accounts_id
        FROM gl_sets_of_books
       WHERE set_of_books_id = P_Invoice_Header_Rec.set_of_books_id;
    END;

    ------------------------------------------------------------------
    l_debug_info := 'Step 1: Check if supplier is the same for CR/DB
                     memo and credited invoice';
    ------------------------------------------------------------------
    IF ( P_Vendor_Id_For_Invoice <> P_Invoice_Header_Rec.vendor_id ) THEN
      p_error_code := 'AP_QC_VENDOR_IS_DIFFERENT';

      l_return_var := FALSE;
    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Step 2: Check if credited invoice is not a CR/DB
                     memo or prepayment';
    ------------------------------------------------------------------
    IF (l_return_var = TRUE) THEN
      IF ( P_Invoice_Header_Rec.invoice_type_lookup_code IN
              ('CREDIT', 'DEBIT', 'PREPAYMENT')) THEN

        p_error_code := 'AP_QC_INV_RESTRICTED_TYPE';
        l_return_var := FALSE;
      END IF;
    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Step 3: Check if credited invoice is cancelled';
    ------------------------------------------------------------------
    IF (l_return_var = TRUE) THEN
      IF (P_Invoice_Header_Rec.cancelled_date IS NOT NULL
          AND P_Invoice_Header_Rec.cancelled_by IS NOT NULL) THEN

        p_error_code := 'AP_QC_INV_ALREADY_CANCELLED';
        l_return_var := FALSE;
      END IF;
    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Step 4: Check if CI contains price or quantity
                     corrections';
    ------------------------------------------------------------------
    IF (l_return_var = TRUE) THEN
      IF (AP_INVOICES_UTILITY_PKG.Inv_With_PQ_Corrections(
          P_Invoice_Id         => P_Invoice_Header_Rec.invoice_id,
          P_Calling_sequence   => l_curr_calling_sequence)) THEN

        p_error_code := 'AP_QC_INV_WITH_PQ_CORRECTION';
        l_return_var := FALSE;
      END IF;
    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Step 5: Check if CI contains prepayment
                     applications';
    ------------------------------------------------------------------
    IF (l_return_var = TRUE) THEN
      IF (AP_INVOICES_UTILITY_PKG.Inv_With_Prepayments(
          P_Invoice_Id         => P_Invoice_Header_Rec.invoice_id,
          P_Calling_sequence   => l_curr_calling_sequence)) THEN

        p_error_code := 'AP_QC_INV_WITH_PREPAYMENTS';
        l_return_var := FALSE;
      END IF;
    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Step 6: Check if CI contains withholding tax';
    ------------------------------------------------------------------
    IF (l_return_var = TRUE) THEN
      IF (AP_INVOICES_UTILITY_PKG.Invoice_Includes_Awt(
          P_Invoice_Id         => P_Invoice_Header_Rec.invoice_id,
          P_Calling_sequence   => l_curr_calling_sequence)) THEN

        p_error_code := 'AP_QC_INV_CONTAINS_AWT';
        l_return_var := FALSE;
      END IF;
    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Step 7: Check if CI is matched to PO finally closed';
    ------------------------------------------------------------------
    IF (l_return_var = TRUE) THEN
      IF (AP_INVOICES_UTILITY_PKG.Inv_Matched_Finally_Closed_Po(
          P_Invoice_Id         => P_Invoice_Header_Rec.invoice_id,
          P_Calling_sequence   => l_curr_calling_sequence)) THEN

        p_error_code := 'AP_QC_INV_PO_FINALLY_CLOSED';
        l_return_var := FALSE;
      END IF;
    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Step 8: Validation for lines';
    ------------------------------------------------------------------
    IF (l_return_var = TRUE) THEN
      FOR i IN P_Invoice_Lines_Tab.FIRST..P_Invoice_Lines_Tab.LAST LOOP

         ------------------------------------------------------------------
         l_debug_info := 'Step 8: Is line fully distributed?';
         ------------------------------------------------------------------
         IF NOT (AP_INVOICE_LINES_UTILITY_PKG.Is_Line_Fully_Distributed(
               P_Invoice_Id         => P_Invoice_Lines_Tab(i).invoice_id,
               P_Line_Number        => P_Invoice_Lines_Tab(i).line_number,
               P_Calling_sequence   => l_curr_calling_sequence)) THEN


            p_error_code := 'AP_QC_INV_NOT_FULLY_DIST';
            l_return_var := FALSE;
         END IF;

         ------------------------------------------------------------------
         l_debug_info := 'Step 9: Is quantity or amount billed below 0
                          after reversal? ';
         ------------------------------------------------------------------
         IF (l_return_var = TRUE) THEN
           IF (AP_INVOICE_LINES_UTILITY_PKG.Is_PO_RCV_Amount_Exceeded(
               P_Invoice_Id         => P_Invoice_Lines_Tab(i).invoice_id,
               P_Line_Number        => P_Invoice_Lines_Tab(i).line_number,
               P_Calling_sequence   => l_curr_calling_sequence)) THEN

              p_error_code := 'AP_QC_BILLED_AMOUNT_BELOW_ZERO';
              l_return_var := FALSE;
           END IF;
         END IF;

         ------------------------------------------------------------------
         l_debug_info := 'Step 10: Are ccids in the distributions of the
                          line invalid?';
         ------------------------------------------------------------------
         IF (l_return_var = TRUE) THEN
           BEGIN
             SELECT DISTINCT aid.dist_code_combination_id
               BULK COLLECT INTO l_dist_ccid_list
               FROM ap_invoice_distributions_all aid
              WHERE aid.invoice_id = P_Invoice_Lines_Tab(i).invoice_id
                AND aid.invoice_line_number = P_Invoice_Lines_Tab(i).line_number
                AND NVL(aid.reversal_flag, 'N') <> 'Y';

             IF l_dist_ccid_list.COUNT > 0 THEN
               FOR j IN l_dist_ccid_list.FIRST..l_dist_ccid_list.LAST LOOP


                 IF (l_return_var = TRUE) THEN
                   IF NOT(AP_UTILITIES_PKG.Is_Ccid_Valid(
                     P_CCID                 => l_dist_ccid_list(j),
                     P_Chart_Of_Accounts_Id => l_chart_of_accounts_id,
                     P_Date                 => P_Dm_Gl_Date,
                     P_Calling_Sequence     => l_curr_calling_sequence)) THEN

                     p_error_code := 'AP_QC_DIST_CCIDS_NOT_VALID';
                     l_return_var := FALSE;
                   END IF;
                 END IF;

               END LOOP;  -- ccid validation loop
             END IF;
           END;
         END IF;  --  l_return_var for ccids validation

      END LOOP; -- lines loop
    END IF; -- l_return_var for lines loop

    RETURN l_return_var;
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Id||
          ' P_Vendor_Id_For_Invoice = '||P_Vendor_Id_For_Invoice||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Validating_Rules;

/*=============================================================================
 |  FUNCTION - Full_Reversal()
 |
 |  DESCRIPTION
 |      Private function that will create the reversed lines and distributions
 |      for the credit or debit memo.
 |      This function returns TRUE if the lines and distributions are created
 |      or FALSE and an error code otherwise.
 |
 |  PARAMETERS
 |      P_Invoice_Id - invoice id
 |      P_Invoice_Header_Rec - header record for the credited invoice
 |      P_Invoice_Lines_Tab - line list for the credited invoice
 |      P_Error_Code - Error code to be returned to the user
 |      P_Calling_Sequence - debug info
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  SYIDNER            Creation
 |
 *============================================================================*/

  FUNCTION Full_Reversal(
               P_Invoice_Id           IN NUMBER,
               P_Dm_Gl_Date           IN DATE,
               P_Dm_Org_Id            IN NUMBER,
               P_Invoice_Header_Rec   IN ap_invoices_all%ROWTYPE,
               P_Invoice_Lines_Tab    IN Inv_Line_Tab_Type,
               P_error_code           OUT NOCOPY VARCHAR2,
               P_calling_sequence     IN VARCHAR2) RETURN BOOLEAN

  IS
    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);
    i                            BINARY_INTEGER := 0;
    l_line_number                ap_invoice_lines_all.line_number%TYPE;
    l_period_name                gl_period_statuses.period_name%TYPE := '';
    l_line_source
      ap_invoice_lines_all.line_source%TYPE := 'QUICK CREDIT';

    l_wfapproval_flag
      ap_system_parameters_all.approval_workflow_flag%TYPE;
    l_wfapproval_status          ap_invoice_lines_all.wfapproval_status%TYPE;
    l_key_value_list             GL_CA_UTILITY_PKG.R_KEY_VALUE_ARR;

    l_Corr_Dist_Tab_Po           AP_MATCHING_PKG.corr_dist_tab_type;
    l_Corr_Dist_Tab_Rcv          AP_MATCHING_PKG.corr_dist_tab_type;

    l_matching_basis             PO_LINE_TYPES.matching_basis%TYPE; /* ABM */

    CURSOR corrected_dist_po(c_invoice_id   NUMBER,
                             c_line_number  NUMBER) IS
      SELECT aid.po_distribution_id po_distribution_id,
             null invoice_distribution_id, --will be populated by the corr API
             aid.invoice_distribution_id corrected_inv_dist_id,
             (-1)*aid.quantity_invoiced corrected_quantity,
             (-1)*aid.amount amount,
             null base_amount, --will be populated by the corr API
             null rounding_amt, --will be populated by the corr API
             aid.unit_price unit_price,
             null pa_quantity,
             aid.dist_code_combination_id dist_ccid
        FROM ap_invoice_distributions aid
       WHERE aid.invoice_id = c_invoice_id
         AND aid.invoice_line_number = c_line_number
         AND line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX', 'TIPV', 'TERV',
                                           'TRV', 'IPV', 'ERV')
         AND NVL(reversal_flag, 'N') <> 'Y';


    CURSOR corrected_dist_rcv(c_invoice_id   NUMBER,
                              c_line_number  NUMBER) IS
      SELECT aid.po_distribution_id po_distribution_id,
             null invoice_distribution_id, --will be populated by the corr API
             aid.invoice_distribution_id corrected_inv_dist_id,
             (-1)*aid.quantity_invoiced corrected_quantity,
             (-1)*aid.amount amount,
             null base_amount, --will be populated by the corr API
             null rounding_amt, --will be populated by the corr API
	     aid.unit_price unit_price,
             null pa_quantity,
             aid.dist_code_combination_id dist_ccid
        FROM ap_invoice_distributions aid
       WHERE aid.invoice_id = c_invoice_id
         AND aid.invoice_line_number = c_line_number
         AND line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX', 'TIPV', 'TERV',
                                           'TRV', 'IPV', 'ERV')
         AND NVL(reversal_flag, 'N') <> 'Y';

  BEGIN

    l_curr_calling_sequence := 'AP_QUICK_CREDIT_PKG.Full_Reversal<-' ||
                               P_calling_sequence;

    ----------------------------------------------------------------------------
    l_debug_info := 'Getting period name for the lines based on the gl_date for '||
                    'the credit/debit memo';
    ----------------------------------------------------------------------------

    l_period_name := AP_INVOICES_PKG.Get_Period_Name(
                       l_invoice_date => P_Dm_Gl_Date,
                       l_receipt_date => null,
                       l_org_id       => P_Dm_Org_Id);

    ----------------------------------------------------------------------------
    l_debug_info := 'Get wfapproval information ';
    ----------------------------------------------------------------------------
    BEGIN
      SELECT approval_workflow_flag
        INTO l_wfapproval_flag
        FROM ap_system_parameters_all
       WHERE org_id = P_Dm_Org_Id;
    END;

    if NVL(l_wfapproval_flag,'N') = 'Y' then
      l_wfapproval_status := 'REQUIRED';
    else
      l_wfapproval_status := 'NOT REQUIRED';
    end if;


    ----------------------------------------------------------------------------
    l_debug_info := 'For every line...';
    ----------------------------------------------------------------------------

    FOR i in P_Invoice_Lines_Tab.FIRST..P_Invoice_Lines_Tab.LAST LOOP

    ----------------------------------------------------------------------------
    l_debug_info := 'Verify if it is a PO/RCV matched line';
    ----------------------------------------------------------------------------

      IF (P_Invoice_Lines_Tab(i).po_line_location_id IS NOT NULL AND
          P_Invoice_Lines_Tab(i).rcv_transaction_id IS NULL) THEN
        ------------------------------------------------------------------------
        l_debug_info := 'The line PO matched populate dist pl/sql table';
        ------------------------------------------------------------------------
        BEGIN
          OPEN corrected_dist_po(P_Invoice_Lines_Tab(i).invoice_id,
                                 P_Invoice_Lines_Tab(i).line_number);
          FETCH corrected_dist_po
            BULK COLLECT INTO l_Corr_Dist_Tab_Po;
          CLOSE corrected_dist_po;
        END;

        /* For Amount Based Matching */
        ------------------------------------------------------------------------
        l_debug_info := 'retrieving the  matching basis from po';
        ------------------------------------------------------------------------
        SELECT plt.matching_basis
        INTO   l_matching_basis
        FROM   po_line_locations_all pll,
               po_lines_all pl,
               po_line_types plt
        WHERE  pll.line_location_id = P_Invoice_Lines_Tab(i).po_line_location_id
        AND    pll.po_line_id = pl.po_line_id
        AND    pl.line_type_id = plt.line_type_id;

        IF l_matching_basis = 'AMOUNT' THEN

          ------------------------------------------------------------------------
          l_debug_info := 'Call Amount correction API for PO match';
          ------------------------------------------------------------------------
          AP_PO_AMT_MATCH_PKG.Amount_Correct_Inv_PO(
            X_Invoice_Id            => P_Invoice_id,
            X_Invoice_Line_Number   => NULL,
            X_Corrected_Invoice_Id  => P_Invoice_Lines_Tab(i).invoice_id,
            X_Corrected_Line_Number => P_Invoice_Lines_Tab(i).line_number,
            X_Match_Mode            => 'CR-PD',
            X_Correction_Amount     => (-1)*P_Invoice_Lines_Tab(i).amount,
            X_Po_Line_Location_Id   => P_Invoice_Lines_Tab(i).po_line_location_id,
            X_Corr_Dist_Tab         => l_Corr_Dist_Tab_Po,
            X_Final_Match_Flag      => 'N',
            X_Uom_Lookup_Code       => P_Invoice_Lines_Tab(i).unit_meas_lookup_code,
            X_Calling_Sequence      => l_curr_calling_sequence);

        ELSE

          ------------------------------------------------------------------------
          l_debug_info := 'Call quantity correction API for PO match';
          ------------------------------------------------------------------------
          AP_MATCHING_PKG.Price_Quantity_Correct_Inv_PO(
            X_Invoice_Id            => P_Invoice_id,
            X_Invoice_Line_Number   => NULL,
            X_Corrected_Invoice_Id  => P_Invoice_Lines_Tab(i).invoice_id,
            X_Corrected_Line_Number => P_Invoice_Lines_Tab(i).line_number,
            X_Correction_Type       => 'QTY_CORRECTION',
            X_Match_Mode            => 'CR-PD',
            X_Correction_Quantity   => (-1)*P_Invoice_Lines_Tab(i).quantity_invoiced,
            X_Correction_Amount     => (-1)*P_Invoice_Lines_Tab(i).amount,
            X_Correction_Price      => P_Invoice_Lines_Tab(i).unit_price,
            X_Po_Line_Location_Id   => P_Invoice_Lines_Tab(i).po_line_location_id,
            X_Corr_Dist_Tab         => l_Corr_Dist_Tab_Po,
            X_Final_Match_Flag      => 'N',
            X_Uom_Lookup_Code       => P_Invoice_Lines_Tab(i).unit_meas_lookup_code,
            X_Calling_Sequence      => l_curr_calling_sequence);

        END IF;

      ELSIF (P_Invoice_Lines_Tab(i).po_line_location_id IS NOT NULL AND
             P_Invoice_Lines_Tab(i).rcv_transaction_id IS NOT NULL) THEN
        ----------------------------------------------------------------------------
        l_debug_info := 'The line RCV matched populate dist pl/sql table';
        ----------------------------------------------------------------------------
        BEGIN
          OPEN corrected_dist_rcv(P_Invoice_Lines_Tab(i).invoice_id,
                                  P_Invoice_Lines_Tab(i).line_number);
          FETCH corrected_dist_rcv
            BULK COLLECT INTO l_Corr_Dist_Tab_Rcv;
          CLOSE corrected_dist_rcv;
        END;

         /* For Amount Based Matching */
        ------------------------------------------------------------------------
        l_debug_info := 'retrieving the  matching basis from po';
        ------------------------------------------------------------------------
        SELECT plt.matching_basis
        INTO   l_matching_basis
        FROM   po_line_locations_all pll,
               po_lines_all pl,
               po_line_types plt
        WHERE  pll.line_location_id = P_Invoice_Lines_Tab(i).po_line_location_id
        AND    pll.po_line_id = pl.po_line_id
        AND    pl.line_type_id = plt.line_type_id;

        IF l_matching_basis = 'AMOUNT' THEN

          ------------------------------------------------------------------------
          l_debug_info := 'Call Amount correction API for receipt match';
          ------------------------------------------------------------------------
          AP_RCT_AMT_MATCH_PKG.Amount_Correct_Inv_RCV(
            X_Invoice_Id             => P_Invoice_id,
            X_Invoice_Line_Number    => NULL,
            X_Corrected_Invoice_Id   => P_Invoice_Lines_Tab(i).invoice_id,
            X_Corrected_Line_Number  => P_Invoice_Lines_Tab(i).line_number,
            X_Correction_Amount      => (-1)*P_Invoice_Lines_Tab(i).amount,
            X_Match_Mode             => 'CR-PD',
            X_Po_Line_Location_Id    => P_Invoice_Lines_Tab(i).po_line_location_id,
            X_Rcv_Transaction_Id     => P_Invoice_Lines_Tab(i).rcv_transaction_id,
            X_Corr_Dist_Tab          => l_Corr_Dist_Tab_Rcv,
            X_Uom_Lookup_Code        => P_Invoice_Lines_Tab(i).unit_meas_lookup_code,
            X_Calling_Sequence       => l_curr_calling_sequence);

        ELSE

          ------------------------------------------------------------------------
          l_debug_info := 'Call quantity correction API for receipt match';
          ------------------------------------------------------------------------
          AP_RECT_MATCH_PKG.Price_Quantity_Correct_Inv_RCV(
            X_Invoice_Id             => P_Invoice_id,
            X_Invoice_Line_Number    => NULL,
            X_Corrected_Invoice_Id   => P_Invoice_Lines_Tab(i).invoice_id,
            X_Corrected_Line_Number  => P_Invoice_Lines_Tab(i).line_number,
            X_Correction_Type        => 'QTY_CORRECTION',
            X_Match_Mode             => 'CR-PD',
            X_Correction_Quantity    => (-1)*P_Invoice_Lines_Tab(i).quantity_invoiced,
            X_Correction_Amount      => (-1)*P_Invoice_Lines_Tab(i).amount,
            X_Correction_Price       => P_Invoice_Lines_Tab(i).unit_price,
            X_Po_Line_Location_Id    => P_Invoice_Lines_Tab(i).po_line_location_id,
            X_Rcv_Transaction_Id     => P_Invoice_Lines_Tab(i).rcv_transaction_id,
            X_Corr_Dist_Tab          => l_Corr_Dist_Tab_Rcv,
            X_Uom_Lookup_Code        => P_Invoice_Lines_Tab(i).unit_meas_lookup_code,
            X_Calling_Sequence       => l_curr_calling_sequence);

        END IF;

      ELSE
        ----------------------------------------------------------------------------
        l_debug_info := 'The line is NOT PO or RCV matched - Create line';
        ----------------------------------------------------------------------------
        l_line_number := AP_INVOICES_PKG.get_max_line_number(P_invoice_id)+1;

        BEGIN
          INSERT INTO ap_invoice_lines_all(
            invoice_id,
            line_number,
            line_type_lookup_code,
            requester_id,
            description,
            line_source,
            org_id,
            inventory_item_id,
            item_description,
            serial_number,
            manufacturer,
            model_number,
            warranty_number,
            generate_dists,
            match_type,
            distribution_set_id,
            account_segment,
            balancing_segment,
            cost_center_segment,
            overlay_dist_code_concat,
            default_dist_ccid,
            prorate_across_all_items,
            line_group_number,
            accounting_date,
            period_name,
            deferred_acctg_flag,
            def_acctg_start_date,
            def_acctg_end_date,
            def_acctg_number_of_periods,
            def_acctg_period_type,
            set_of_books_id,
            amount,
            base_amount,
            rounding_amt,
            quantity_invoiced,
            unit_meas_lookup_code,
            unit_price,
            wfapproval_status,
         -- ussgl_transaction_code, - Bug 4277744
            discarded_flag,
            original_amount,
            original_base_amount,
            original_rounding_amt,
            cancelled_flag,
            income_tax_region,
            type_1099,
            stat_amount,
            prepay_invoice_id,
            prepay_line_number,
            invoice_includes_prepay_flag,
            corrected_inv_id,
            corrected_line_number,
            po_header_id,
            po_line_id,
            po_release_id,
            po_line_location_id,
            po_distribution_id,
            rcv_transaction_id,
            final_match_flag,
            assets_tracking_flag,
            asset_book_type_code,
            asset_category_id,
            project_id,
            task_id,
            expenditure_type,
            expenditure_item_date,
            expenditure_organization_id,
            pa_quantity,
            pa_cc_ar_invoice_id,
            pa_cc_ar_invoice_line_num,
            pa_cc_processed_code,
            award_id,
            awt_group_id,
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
            global_attribute_category,
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
            global_attribute20,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            program_application_id,
            program_id,
            program_update_date,
            request_id,
	    purchasing_category_id)
      VALUES (
            P_Invoice_id,                                      --  invoice_id
            l_line_number,                                     --  line_number
            P_Invoice_Lines_Tab(i).line_type_lookup_code,      --  line_type_lookup_code
            P_Invoice_Lines_Tab(i).requester_id,               --  requester_id
            P_Invoice_Lines_Tab(i).description,                --  description
            l_line_source,                                     --  line_source
            P_Dm_Org_Id,                                       --  org_id
            P_Invoice_Lines_Tab(i).inventory_item_id,          --  inventory_item_id
            P_Invoice_Lines_Tab(i).Item_description,           --  item_description
            P_Invoice_Lines_Tab(i).serial_number,              --  serial_number
            P_Invoice_Lines_Tab(i).Manufacturer,               --  manufacturer
            P_Invoice_Lines_Tab(i).Model_Number,               --  model_number
            P_Invoice_Lines_Tab(i).warranty_number,            --  warranty_number
            P_Invoice_Lines_Tab(i).generate_dists,             --  generate_dists
            P_Invoice_Lines_Tab(i).match_type,                 --  match_type
            P_Invoice_Lines_Tab(i).distribution_set_id,        --  distribution_set_id
            P_Invoice_Lines_Tab(i).account_segment,            --  account_segment
            P_Invoice_Lines_Tab(i).balancing_segment,          --  balancing_segment
            P_Invoice_Lines_Tab(i).cost_center_segment,        --  cost_center_segment
            P_Invoice_Lines_Tab(i).overlay_dist_code_concat,   --  overlay_dist_code_concat
            P_Invoice_Lines_Tab(i).default_dist_ccid,          --  default_dist_ccid
            P_Invoice_Lines_Tab(i).prorate_across_all_items,   --  prorate_across_all_items
            P_Invoice_Lines_Tab(i).line_group_number,          --  line_group_number
            P_Dm_Gl_Date,                                      --  accounting_date
            l_period_name,                                     --  period_name
            P_Invoice_Lines_Tab(i).deferred_acctg_flag,        --  deferred_acctg_flag
            P_Invoice_Lines_Tab(i).def_acctg_start_date,       --  def_acctg_start_date
            P_Invoice_Lines_Tab(i).def_acctg_end_date,         --  def_acctg_end_date
            P_Invoice_Lines_Tab(i).def_acctg_number_of_periods, --  def_acctg_number_of_periods
            P_Invoice_Lines_Tab(i).def_acctg_period_type,      --  def_acctg_period_type
            P_Invoice_Lines_Tab(i).set_of_books_id,            --  set_of_books_id
            (-1)*P_Invoice_Lines_Tab(i).amount,                --  amount
            P_Invoice_Lines_Tab(i).base_amount,                --  base_amount
            P_Invoice_Lines_Tab(i).rounding_amt,               --  rounding_amt
            P_Invoice_Lines_Tab(i).quantity_invoiced,          --  quantity_invoiced
            P_Invoice_Lines_Tab(i).unit_meas_lookup_code,      --  unit_meas_lookup_code
            P_Invoice_Lines_Tab(i).unit_price,                 --  unit_price
            l_wfapproval_status,                               --  wfapproval_status
         -- Bug 4277744
         -- P_Invoice_Lines_Tab(i).ussgl_transaction_code,     --  ussgl_transaction_code
            'N',                                               --  discarded_flag
            P_Invoice_Lines_Tab(i).original_amount,            --  original_amount
            P_Invoice_Lines_Tab(i).original_base_amount,       --  original_base_amount
            P_Invoice_Lines_Tab(i).original_rounding_amt,      --  original_rounding_amt
            P_Invoice_Lines_Tab(i).cancelled_flag,              --  cancelled_flag
            P_Invoice_Lines_Tab(i).income_tax_region,          --  income_tax_region
            P_Invoice_Lines_Tab(i).type_1099,                  --  type_1099
            P_Invoice_Lines_Tab(i).stat_amount,                --  stat_amount
            P_Invoice_Lines_Tab(i).prepay_invoice_id,          --  prepay_invoice_id
            P_Invoice_Lines_Tab(i).prepay_line_number,         --  prepay_line_number
            P_Invoice_Lines_Tab(i).invoice_includes_prepay_flag, --  invoice_includes_prepay_flag
            P_Invoice_Lines_Tab(i).invoice_id,         --  corrected_inv_id
            P_Invoice_Lines_Tab(i).line_number,        --  corrected_line_number
            P_Invoice_Lines_Tab(i).po_header_id,               --  po_header_id
            P_Invoice_Lines_Tab(i).po_line_id,                 --  po_line_id
            P_Invoice_Lines_Tab(i).po_release_id,              --  po_release_id
            P_Invoice_Lines_Tab(i).po_line_location_id,        --  po_line_location_id
            P_Invoice_Lines_Tab(i).po_distribution_id,         --  po_distribution_id
            P_Invoice_Lines_Tab(i).rcv_transaction_id,         --  rcv_transaction_id
            P_Invoice_Lines_Tab(i).final_match_flag,           --  final_match_flag
            P_Invoice_Lines_Tab(i).assets_tracking_flag,       --  assets_tracking_flag
            P_Invoice_Lines_Tab(i).asset_book_type_code,       --  asset_book_type_code,
            P_Invoice_Lines_Tab(i).asset_category_id,          --  asset_category_id
            P_Invoice_Lines_Tab(i).project_id,                 --  project_id
            P_Invoice_Lines_Tab(i).task_id,                    --  task_id
            P_Invoice_Lines_Tab(i).expenditure_type,           --  expenditure_type
            P_Invoice_Lines_Tab(i).expenditure_item_date,      --  expenditure_item_date
            P_Invoice_Lines_Tab(i).expenditure_organization_id,--  expenditure_organization_id
            P_Invoice_Lines_Tab(i).pa_quantity,                --  pa_quantity
            P_Invoice_Lines_Tab(i).pa_cc_ar_invoice_id,        --  pa_cc_ar_invoice_id
            P_Invoice_Lines_Tab(i).pa_cc_ar_invoice_line_num,  --  pa_cc_ar_invoice_line_num
            P_Invoice_Lines_Tab(i).pa_cc_processed_code,       --  pa_cc_processed_code
            P_Invoice_Lines_Tab(i).award_id,                   --  award_id
            P_Invoice_Lines_Tab(i).awt_group_id,               --  awt_group_id
            P_Invoice_Lines_Tab(i).reference_1,                --  reference_1
            P_Invoice_Lines_Tab(i).reference_2,                --  reference_2
            P_Invoice_Lines_Tab(i).receipt_verified_flag,      --  receipt_verified_flag
            P_Invoice_Lines_Tab(i).receipt_required_flag,      --  receipt_required_flag
            P_Invoice_Lines_Tab(i).receipt_missing_flag,       --  receipt_missing_flag
            P_Invoice_Lines_Tab(i).justification,              --  justification
            P_Invoice_Lines_Tab(i).expense_group,              --  expense_group
            P_Invoice_Lines_Tab(i).start_expense_date,         --  start_expense_date
            P_Invoice_Lines_Tab(i).end_expense_date,           --  end_expense_date
            P_Invoice_Lines_Tab(i).receipt_currency_code,      --  receipt_currency_code
            P_Invoice_Lines_Tab(i).receipt_conversion_rate,    --  receipt_conversion_rate
            P_Invoice_Lines_Tab(i).receipt_currency_amount,    --  receipt_currency_amount
            P_Invoice_Lines_Tab(i).daily_amount,               --  daily_amount
            P_Invoice_Lines_Tab(i).web_parameter_id,           --  web_parameter_id
            P_Invoice_Lines_Tab(i).adjustment_reason,          --  adjustment_reason
            P_Invoice_Lines_Tab(i).merchant_document_number,   --  merchant_document_number
            P_Invoice_Lines_Tab(i).merchant_name,              --  merchant_name
            P_Invoice_Lines_Tab(i).merchant_reference,         --  merchant_reference
            P_Invoice_Lines_Tab(i).merchant_tax_reg_number,    --  merchant_tax_reg_number
            P_Invoice_Lines_Tab(i).merchant_taxpayer_id,       --  merchant_taxpayer_id
            P_Invoice_Lines_Tab(i).country_of_supply,          --  country_of_supply
            P_Invoice_Lines_Tab(i).credit_card_trx_id,         --  credit_card_trx_id
            P_Invoice_Lines_Tab(i).company_prepaid_invoice_id, --  company_prepaid_invoice_id
            P_Invoice_Lines_Tab(i).cc_reversal_flag,           --  cc_reversal_flag
            P_Invoice_Lines_Tab(i).attribute_category,         --  attribute_category
            P_Invoice_Lines_Tab(i).attribute1,                 --  attribute1
            P_Invoice_Lines_Tab(i).attribute2,                 --  attribute2
            P_Invoice_Lines_Tab(i).attribute3,                 --  attribute3
            P_Invoice_Lines_Tab(i).attribute4,                 --  attribute4
            P_Invoice_Lines_Tab(i).attribute5,                 --  attribute5
            P_Invoice_Lines_Tab(i).attribute6,                 --  attribute6
            P_Invoice_Lines_Tab(i).attribute7,                 --  attribute7
            P_Invoice_Lines_Tab(i).attribute8,                 --  attribute8
            P_Invoice_Lines_Tab(i).attribute9,                 --  attribute9
            P_Invoice_Lines_Tab(i).attribute10,                --  attribute10
            P_Invoice_Lines_Tab(i).attribute11,                --  attribute11
            P_Invoice_Lines_Tab(i).attribute12,                --  attribute12
            P_Invoice_Lines_Tab(i).attribute13,                --  attribute13
            P_Invoice_Lines_Tab(i).attribute14,                --  attribute14
            P_Invoice_Lines_Tab(i).attribute15,                --  attribute15
            P_Invoice_Lines_Tab(i).global_attribute_category,  -- global_attribute_category
            P_Invoice_Lines_Tab(i).global_attribute1,          -- global_attribute1
            P_Invoice_Lines_Tab(i).global_attribute2,          -- global_attribute2
            P_Invoice_Lines_Tab(i).global_attribute3,          -- global_attribute3
            P_Invoice_Lines_Tab(i).global_attribute4,          -- global_attribute4
            P_Invoice_Lines_Tab(i).global_attribute5,          -- global_attribute5
            P_Invoice_Lines_Tab(i).global_attribute6,          -- global_attribute6
            P_Invoice_Lines_Tab(i).global_attribute7,          -- global_attribute7
            P_Invoice_Lines_Tab(i).global_attribute8,          -- global_attribute8
            P_Invoice_Lines_Tab(i).global_attribute9,          -- global_attribute9
            P_Invoice_Lines_Tab(i).global_attribute10,         -- global_attribute10
            P_Invoice_Lines_Tab(i).global_attribute11,         -- global_attribute11
            P_Invoice_Lines_Tab(i).global_attribute12,         -- global_attribute12
            P_Invoice_Lines_Tab(i).global_attribute13,         -- global_attribute13
            P_Invoice_Lines_Tab(i).global_attribute14,         -- global_attribute14
            P_Invoice_Lines_Tab(i).global_attribute15,         -- global_attribute15
            P_Invoice_Lines_Tab(i).global_attribute16,         -- global_attribute16
            P_Invoice_Lines_Tab(i).global_attribute17,         -- global_attribute17
            P_Invoice_Lines_Tab(i).global_attribute18,         -- global_attribute18
            P_Invoice_Lines_Tab(i).global_attribute19,         -- global_attribute19
            P_Invoice_Lines_Tab(i).global_attribute20,         -- global_attribute20
            sysdate,                                           -- creation_date
            FND_GLOBAL.user_id,                                -- created_by
            FND_GLOBAL.user_id,                                -- last_updated_by
            sysdate,                                           -- last_update_date
            FND_GLOBAL.login_id,                               -- last_update_login
            P_Invoice_Lines_Tab(i).program_application_id,     -- program_application_id
            P_Invoice_Lines_Tab(i).program_id,                 -- program_id
            P_Invoice_Lines_Tab(i).program_update_date,        -- program_update_date
            P_Invoice_Lines_Tab(i).request_id,                 -- request_id
	    P_Invoice_Lines_Tab(i).purchasing_category_id      -- purchasing_category_id
            );

        END;

        ----------------------------------------------------------------------------
        l_debug_info := 'create distributions';
        ----------------------------------------------------------------------------
        INSERT INTO ap_invoice_distributions_all(
          invoice_id,
          invoice_line_number,
          dist_code_combination_id,
          invoice_distribution_id,
          last_update_date,
          last_updated_by,
          accounting_date,
          period_name,
          set_of_books_id,
          amount,
          description,
          type_1099,
          tax_code_id,
          posted_flag,
          batch_id,
          quantity_invoiced,
          corrected_quantity,
          unit_price,
          match_status_flag,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          prepay_amount_remaining,
          assets_addition_flag,
          assets_tracking_flag,
          distribution_line_number,
          line_type_lookup_code,
          po_distribution_id,
          base_amount,
          pa_addition_flag,
          encumbered_flag,
          accrual_posted_flag,
          cash_posted_flag,
          last_update_login,
          creation_date,
          created_by,
          stat_amount,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute15,
          reversal_flag,
          parent_invoice_id,
          income_tax_region,
          final_match_flag,
       -- ussgl_transaction_code, - Bug 4277744
       -- ussgl_trx_code_context, - Bug 4277744
          expenditure_item_date,
          expenditure_organization_id,
          expenditure_type,
          pa_quantity,
          project_id,
          task_id,
          quantity_variance,
          base_quantity_variance,
          awt_flag,
          awt_group_id,
          awt_tax_rate_id,
          awt_gross_amount,
          reference_1,
          reference_2,
          other_invoice_id,
          awt_invoice_id,
          awt_origin_group_id,
          program_application_id,
          program_id,
          program_update_date,
          request_id,
          award_id,
          start_expense_date,
          merchant_document_number,
          merchant_name,
          merchant_tax_reg_number,
          merchant_taxpayer_id,
          country_of_supply,
          merchant_reference,
          parent_reversal_id,
          rcv_transaction_id,
          dist_match_type,
          matched_uom_lookup_code,
          global_attribute_category,
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
          global_attribute20,
          receipt_verified_flag,
          receipt_required_flag,
          receipt_missing_flag,
          justification,
          expense_Group,
          end_Expense_Date,
          receipt_Currency_Code,
          receipt_Conversion_Rate,
          receipt_Currency_Amount,
          daily_Amount,
          web_Parameter_Id,
          adjustment_Reason,
          credit_Card_Trx_Id,
          company_Prepaid_Invoice_Id,
          org_id,
          rounding_amt,
          charge_applicable_to_dist_id,
          corrected_invoice_dist_id,
          related_id,
          asset_book_type_code,
          asset_category_id,
          accounting_event_id,
          cancellation_flag,
	  --Freight and Special Charges
	  rcv_charge_addition_flag)
        (SELECT
           P_Invoice_Id,                       -- invoice_id
           l_Line_Number,                      -- invoice_line_number
           Dist_Code_Combination_Id,           -- dist_code_combination_id
           ap_invoice_distributions_s.NEXTVAL, -- distribution_id
           sysdate,                  -- last_update_date
           FND_GLOBAL.user_id,         -- last_updated_by
           P_Dm_Gl_Date, -- accounting_date
           l_period_name,  -- period_name
           Set_Of_Books_Id, -- set_of_book_id
           (-1)*Amount,  -- Amount
           Description,  -- description
           Type_1099,    -- type_1099
           Tax_Code_Id,  -- tax_code_id
           'N',          -- Posted_Flag,
           Batch_Id,     -- batch_id
           quantity_invoiced,    -- Quantity_Invoiced
           corrected_quantity,   -- corrected_quanity
           unit_price,           -- Unit_Price,
           NULL,                 -- Match_Status_Flag /* bug 4916530 */
           attribute_category, -- attribute_category
           attribute1,         -- attribute1
           attribute2,         -- attribute2
           attribute3,         -- attribute3
           attribute4,         -- attribute4
           attribute5,         -- attribute5
           NULL,               --prepay_amount_remaining
           'U', -- Assets_Addition_Flag
           Assets_Tracking_Flag, -- assets_tracking_flag
           distribution_line_number, -- dist. line number
           Line_Type_Lookup_Code, -- line_type_lookup_code
           Po_Distribution_Id, -- po_distribution_id
           (-1)*Base_Amount, -- base_amount
           decode(project_id,NULL,'E', 'N'), -- Pa_addition_flag
           'N', --Encumbered_Flag,
           'N', --Accrual_Posted_Flag,
           'N', --Cash_Posted_Flag,
           FND_GLOBAL.login_id, -- last_update_login
           sysdate, --Creation_Date,
           FND_GLOBAL.user_id, --Created_By,
           (-1)*Stat_Amount, -- Stat_Amount
           attribute11,    -- attribute11,
           attribute12,    -- attribute12,
           attribute13,    -- attribute13,
           attribute14,    -- attribute14,
           attribute6,     -- attribute6,
           attribute7,     -- attribute7,
           attribute8,     -- attribute8,
           attribute9,     -- attribute9,
           attribute10,    -- attribute10,
           attribute15,    -- attribute15,
           'N',            -- Reversal_Flag,
           invoice_id,     -- parent_invoice_id
           Income_Tax_Region, -- income_tax_region
           NULL,           -- final_match_flag
        -- Removed for bug 4277744
        -- Ussgl_Transaction_Code, -- ussgl_transaction_code
        -- Ussgl_Trx_Code_Context, -- ussgal_trx_code_contextt,
           expenditure_item_date,  -- expenditure_item_date
           Expenditure_Organization_Id, -- expenditure_orgnization_id
           Expenditure_Type, -- expenditure_type
           (-1)*Pa_Quantity, -- Pa_quantity
           Project_Id, -- project_id
           Task_Id, -- task_id
           (-1)*Quantity_Variance, -- quantity_variance
           (-1)*Base_Quantity_Variance, -- base quantity_variance
           awt_flag,          -- awt_flag
           awt_group_id,      --awt_group_id,
           awt_tax_rate_id,   --awt_tax_rate_id
           awt_gross_amount,  --awt_gross_amount
           reference_1,       -- reference_1
           reference_2,       -- reference_2
           other_invoice_id,  -- other_invoice_id
           awt_invoice_id,    -- awt_invoice_id
           awt_origin_group_id, -- awt_origin_group_id
           FND_GLOBAL.prog_appl_id,    --program_application_id
           FND_GLOBAL.conc_program_id, --program_id
           SYSDATE,                    --program_update_date,
           FND_GLOBAL.conc_request_id, --request_id
           award_id,   -- award_id
           start_expense_date,    -- start_expense_date
           merchant_document_number,  -- merchant_document_number
           merchant_name,             -- merchant_name
           merchant_tax_reg_number,   -- merchant_tax_reg_number
           merchant_taxpayer_id,      -- merchant_taxpayer_id
           country_of_supply,         -- country_of_supply
           merchant_reference,        -- merchant_reference
           invoice_distribution_id,   --Parent_Reversal_Id
           rcv_transaction_id,        -- rcv_transaction_id
           dist_match_type,           -- dist_match_type
           matched_uom_lookup_code,   -- matched_uom_lookup_code
           global_attribute_category, -- global_attribute_category
           global_attribute1,         -- global_attribute1
           global_attribute2,         -- global_attribute2
           global_attribute3,         -- global_attribute3
           global_attribute4,         -- global_attribute4
           global_attribute5,         -- global_attribute5
           global_attribute6,         -- global_attribute6
           global_attribute7,         -- global_attribute7
           global_attribute8,         -- global_attribute8
           global_attribute9,         -- global_attribute9
           global_attribute10,        -- global_attribute10
           global_attribute11,        -- global_attribute11
           global_attribute12,        -- global_attribute12
           global_attribute13,        -- global_attribute13
           global_attribute14,        -- global_attribute14
           global_attribute15,        -- global_attribute15
           global_attribute16,        -- global_attribute16
           global_attribute17,        -- global_attribute17
           global_attribute18,        -- global_attribute18
           global_attribute19,        -- global_attribute19
           global_attribute20,        -- global_attribute20
           receipt_verified_flag,     --receipt_verified_flag
           receipt_required_flag,     --receipt_required_flag
           receipt_missing_flag,      --receipt_missing_flag
           justification,             --justification
           expense_Group,             --expense_Group
           end_Expense_Date,          --end_Expense_Date
           receipt_Currency_Code,     --receipt_Currency_Code
           receipt_Conversion_Rate,   --receipt_Conversion_Rate
           receipt_Currency_Amount,   --receipt_Currency_Amount
           daily_Amount,              --daily_Amount
           web_Parameter_Id,          --web_Parameter_Id
           adjustment_Reason,         --adjustment_Reason
           credit_Card_Trx_Id,        --credit_Card_Trx_Id
           company_Prepaid_Invoice_Id,--company_Prepaid_Invoice_Id
           org_id,                    -- org_id
           (-1)*rounding_amt,         -- rounding_amt
           NULL,                      -- charge_applicable_to_dist_id
           invoice_distribution_id,   -- corrected_invoice_dist_id
           NULL,                      -- related_id
           asset_book_type_code,      -- asset_book_type_code
           asset_category_id,         -- asset_category_id
           NULL,                      -- accounting_event_id -- bug 5152035
           'N',                       -- cancellation_flag
	         'N'			      -- rcv_charge_addition_flag
            FROM ap_invoice_distributions_all
           WHERE invoice_id = P_Invoice_Lines_Tab(i).invoice_id
             AND invoice_line_number = P_Invoice_Lines_Tab(i).line_number
             AND line_type_lookup_code NOT IN ('REC_TAX','NONREC_TAX', 'TIPV', 'TERV', 'TRV',
                                               'IPV', 'ERV')
        -- This to exclude the tax distributions created in the case of inclusive calculation
        -- of taxes since for the exclusive case the TAX lines are not included in the
        -- pl/sql table.  Also exclude the variances created by AP.  Those will
        -- be created during validation of the invoice.
             AND NVL(reversal_flag, 'N') <> 'Y');


        ----------------------------------------------------------------------------
        l_debug_info := 'Update charge_applicable_to_dist_id for allocation info ...';
        ----------------------------------------------------------------------------
        UPDATE ap_invoice_distributions_all aid
           SET aid.charge_applicable_to_dist_id =
               (SELECT d1.invoice_distribution_id
                  FROM ap_invoice_distributions_all d,
                       ap_invoice_distributions_all cor,
                       ap_invoice_distributions_all d1
                 WHERE d.invoice_id = aid.invoice_id
                   AND d.invoice_distribution_id = aid.invoice_distribution_id
                   AND d.corrected_invoice_dist_id = cor.invoice_distribution_id
                   AND cor.charge_applicable_to_dist_id IS NOT NULL
                   AND d1.corrected_invoice_dist_id = cor.charge_applicable_to_dist_id)
         WHERE aid.invoice_id = P_Invoice_Id;

        ----------------------------------------------------------------------------
        l_debug_info := 'MRC Maintenance...';
        ----------------------------------------------------------------------------
        SELECT aid.invoice_distribution_id
          BULK COLLECT INTO l_key_value_list
          FROM ap_invoice_distributions aid
         WHERE aid.invoice_id = P_Invoice_Id
           AND aid.invoice_line_number = l_line_number;

        l_key_value_list.DELETE;

     END IF;

    END LOOP;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Id||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Full_Reversal;

/*=============================================================================
 |  FUNCTION - Quick_Credit()
 |
 |  DESCRIPTION
 |      Public function that will include all the quick credit functionality.
 |      This API is called from the Invoice Workbench at commit.
 |      This function returns TRUE if the full reversal for the invoice goes through
 |      or FALSE and an error code otherwise.
 |
 |  PARAMETERS
 |      P_Invoice_Id - quick credit invoice id
 |      P_Vendor_Id_For_Invoice  - vendor id for the debit or credit memo
 |      P_DM_gl_date - gl_date for the credit/debit memo
 |      P_credited_Invoice_id - Invoice id for the credited invoice
 |      P_error_code - Error code to be returned when the rules are not followed
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  SYIDNER            Creation
 |
 *============================================================================*/

  FUNCTION Quick_Credit(
               P_Invoice_Id            IN NUMBER,
               P_Vendor_Id_For_Invoice IN NUMBER,
               P_Dm_Gl_Date            IN DATE,
               P_Dm_Org_Id             IN NUMBER,
               P_Credited_Invoice_Id   IN NUMBER,
               P_error_code            OUT NOCOPY VARCHAR2,
               P_calling_sequence      IN VARCHAR2) RETURN BOOLEAN

  IS

    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);

    l_inv_header_rec             ap_invoices_all%ROWTYPE;
    l_inv_line_list              Inv_Line_Tab_Type;

    CURSOR Invoice_Header IS
    SELECT *
      FROM ap_invoices_all
     WHERE invoice_id = P_Credited_Invoice_Id;

    CURSOR Invoice_Lines IS
    SELECT *
      FROM ap_invoice_lines_all
     WHERE invoice_id = P_Credited_Invoice_Id
       AND line_type_lookup_code <> 'TAX'
       AND (NVL(discarded_flag, 'N' ) <> 'Y'
        OR NVL(cancelled_flag, 'N' ) <> 'Y')
     ORDER BY line_number;

    l_return_value       BOOLEAN := TRUE;

  BEGIN

    l_curr_calling_sequence := 'AP_QUICK_CREDIT_PKG.Quick_Credit<-' ||
                               P_calling_sequence;

    -----------------------------------------------------------------
    l_debug_info := 'Step 1: Populating invoice and lines collections'||
                    'for credited invoices';
    -----------------------------------------------------------------
    BEGIN
      OPEN Invoice_Header;
      FETCH Invoice_Header INTO l_inv_header_rec;
      CLOSE Invoice_Header;
    END;

    BEGIN
      OPEN Invoice_Lines;
      FETCH Invoice_Lines
      BULK COLLECT INTO l_inv_line_list;
      CLOSE Invoice_Lines;
    END;

    -------------------------------------------------------------------
    l_debug_info := 'Step 2: Calling Validating Rules';
    -------------------------------------------------------------------
    IF NOT (AP_QUICK_CREDIT_PKG.Validating_Rules(
              P_Invoice_Id             => P_Invoice_Id,
              P_Vendor_Id_For_Invoice  => P_Vendor_Id_For_Invoice,
              P_Dm_Gl_Date             => P_Dm_Gl_Date,
              P_Invoice_Header_Rec     => l_inv_header_rec,
              P_Invoice_Lines_Tab      => l_inv_line_list,
              P_error_code             => P_error_code,
              P_calling_sequence       => l_curr_calling_sequence)) THEN

      l_return_value := FALSE;
    END IF;

    --------------------------------------------------------------------
    l_debug_info := 'Step 3: Calling Full Reverse';
    --------------------------------------------------------------------
    IF (l_return_value = TRUE) THEN
      IF NOT (AP_QUICK_CREDIT_PKG.Full_Reversal(
                P_Invoice_Id             => P_Invoice_Id,
                P_Dm_Gl_Date             => P_Dm_Gl_Date,
                P_Dm_Org_Id              => P_Dm_Org_Id,
                P_Invoice_Header_Rec     => l_inv_header_rec,
                P_Invoice_Lines_Tab      => l_inv_line_list,
                P_error_code             => P_error_code,
                P_calling_sequence       => l_curr_calling_sequence)) THEN

        l_return_value := FALSE;
      END IF;
    END IF;

    --------------------------------------------------------------------
    l_debug_info := 'Step 4: Calling tax ';
    --------------------------------------------------------------------
    IF (l_return_value = TRUE) THEN
      IF NOT (AP_ETAX_PKG.Calling_eTax(
                P_Invoice_id              => P_Invoice_Id,
                P_Calling_Mode            => 'REVERSE INVOICE',
                P_Override_Status         => NULL,
                P_Line_Number_To_Delete   => NULL,
                P_All_Error_Messages      => 'N',
                P_error_code              => P_error_code,
                P_calling_sequence        => l_curr_calling_sequence)) THEN

        l_return_value := FALSE;

      END IF;
    END IF;

    RETURN l_return_value;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Id||
          ' P_Vendor_Id_For_Invoice = '||P_Vendor_Id_For_Invoice||
          ' P_Credited_Invoice_Id = '||P_Credited_Invoice_Id||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);

      END IF;

      IF ( Invoice_Header%ISOPEN ) THEN
        CLOSE Invoice_Header;
      END IF;

      IF ( Invoice_Lines%ISOPEN ) THEN
        CLOSE Invoice_Lines;
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Quick_Credit;
END AP_QUICK_CREDIT_PKG;

/
