--------------------------------------------------------
--  DDL for Package Body AP_RETRO_PRICING_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_RETRO_PRICING_UTIL_PKG" AS
/* $Header: apretrub.pls 120.11.12010000.5 2010/08/19 08:23:19 sbonala ship $ */


/*=============================================================================
 |  FUNCTION - Are_Original_Invoices_Valid()
 |
 |  DESCRIPTION
 |      This function checks for a particular instruction if all the  base
 |  matched Invoices(along with Price Corrections,Qty Corrections and the
 |  previously existing(If Any) Retro Price Adjustments Documents ) for the
 |  retropriced shipments(Records in AP_INVOICE_LINES_INTERFACE) are VALID
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_org_id
 }      p_orig_invoices_valid  --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Are_Original_Invoices_Valid(
             p_instruction_id     IN            NUMBER,
             p_org_id             IN            NUMBER,
             p_orig_invoices_valid    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

l_count                   NUMBER := 0;
debug_info                VARCHAR2(1000);

BEGIN

  debug_info := 'Are Original Invoices Valid';
  SELECT count(*)
    INTO l_count
    FROM ap_invoice_lines_interface IL,
         ap_invoice_lines_all L
   WHERE IL.invoice_id = p_instruction_id
     AND IL.po_line_location_id = L.po_line_location_id
     AND L.org_id = p_org_id
     AND L.match_type IN ('ITEM_TO_PO', 'ITEM_TO_RECEIPT',
                          'QTY_CORRECTION', 'PRICE_CORRECTION',
                          'PO_PRICE_ADJUSTMENT', 'ADJUSTMENT_CORRECTION')
     AND L.discarded_flag <> 'Y'
     AND L.cancelled_flag <> 'Y'
     AND (NVL(L.generate_dists, 'Y') <> 'D' OR
          EXISTS (SELECT 'Unapproved matched dist'
                    FROM   ap_invoice_distributions_all D
                    WHERE  D.invoice_id = L.invoice_id
                    AND    D.invoice_line_number = L.line_number
                    AND    nvl(D.match_status_flag, 'X') NOT IN ('A', 'T'))
         );

   IF l_count > 0 THEN
       p_orig_invoices_valid := 'N';
   ELSE
       p_orig_invoices_valid := 'Y';
   END IF;

   RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;

    RETURN(FALSE);

END Are_Original_Invoices_Valid;


/*=============================================================================
 |  FUNCTION - Are_Holds_Ok()
 |
 |  DESCRIPTION
 |      This function checks for a particular instruction if all the  base
 |  matched Invoices(along with Price Corrections, Qty Corrections and the
 |  previously existing(If Any) Retro Price Adjustments Documents ) for the
 |  retropriced shipments(Records in AP_INVOICE_LINES_INTERFACE) has any holds
 |  (other than Price Hold)
 |
 |  PARAMETERS
 |      p_instruction_id
 |      p_org_id
 }      p_orig_invoices_valid    --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Are_Holds_Ok(
               p_instruction_id     IN            NUMBER,
               p_org_id             IN            NUMBER,
               p_orig_invoices_valid    OUT NOCOPY VARCHAR2)

RETURN BOOLEAN IS

l_count                  NUMBER := 0;
debug_info               VARCHAR2(1000);

BEGIN

  debug_info := 'Are Holds OK';
  SELECT count(*)
    INTO l_count
    FROM ap_invoice_lines_interface IL,
         ap_invoice_lines_all L
   WHERE IL.invoice_id = p_instruction_id
     AND L.org_id = p_org_id
     AND L.po_line_location_id = IL.po_line_location_id
     AND L.match_type IN ('ITEM_TO_PO', 'ITEM_TO_RECEIPT',
                          'QTY_CORRECTION', 'PRICE_CORRECTION',
                          'PO_PRICE_ADJUSTMENT', 'ADJUSTMENT_CORRECTION')
     AND L.discarded_flag <> 'Y'
     AND L.cancelled_flag <> 'Y'
     AND (NVL(L.generate_dists, 'Y') = 'D'
     AND  NOT EXISTS (SELECT 'Unapproved matched dist'
                        FROM  ap_invoice_distributions_all D
                       WHERE  D.invoice_id = L.invoice_id
                         AND  D.invoice_line_number = L.line_number
                         AND  nvl(D.match_status_flag, 'X') NOT IN ('A', 'T'))
     AND  EXISTS (SELECT 'Holds other than Price Hold'
                   FROM   ap_holds_all H
                   WHERE  H.invoice_id = L.invoice_id
                   AND    H.release_lookup_code is null
                   AND    H.hold_lookup_code <> 'PRICE'));

   IF l_count > 0 THEN
       p_orig_invoices_valid := 'N';
   ELSE
       p_orig_invoices_valid := 'Y';
   END IF;

   RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;

    RETURN(FALSE);

END Are_Holds_Ok;


/*=============================================================================
 |  FUNCTION - Is_sequence_assigned()
 |
 |  DESCRIPTION
 |      This function checks whether or not a sequence is assigned with the
 |      particular document category code. This procedure is added for the
 |      bug5769161
 |
 |  PARAMETERS
 |      p_document_category_code
 |      p_set_of_books_id
 |      p_is_sequence_assigned   -OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  12-MAR-2007  gagrawal           Creation
 |  22-MAY-2009  gagrawal           Changed to input org instead of
 |                                  set of books (bug8514744)
 |
 *============================================================================*/
FUNCTION Is_sequence_assigned(
               p_document_category_code     IN    VARCHAR2,
               p_org_id            IN    NUMBER,
               p_is_sequence_assigned       OUT NOCOPY VARCHAR2)

RETURN BOOLEAN IS

l_count                  NUMBER := 0;
debug_info               VARCHAR2(1000);

BEGIN

   debug_info := 'Is sequence Assigned?';

     SELECT count(*)
       INTO l_count
       FROM fnd_document_sequences SEQ,
            fnd_doc_sequence_assignments SA,
            ap_system_parameters_all asp
      WHERE SEQ.doc_sequence_id        = SA.doc_sequence_id
        AND SA.application_id          = 200
        AND SA.category_code           = p_document_category_code
        AND (NVL(SA.method_code,'A') = 'A')
        AND (asp.org_id = p_org_id)
        AND asp.set_of_books_id = SA.set_of_books_id
        AND SYSDATE -- never null
             BETWEEN SA.start_date
             AND NVL(SA.end_date, TO_DATE('31/12/4712','DD/MM/YYYY'));

   IF l_count > 0 THEN
       p_is_sequence_assigned := 'Y';
   ELSE
       p_is_sequence_assigned := 'N';
   END IF;

   RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;

    RETURN(FALSE);

END Is_sequence_assigned;


/*=============================================================================
 |  FUNCTION - Ppa_Already_Exists()
 |
 |  DESCRIPTION
 |      This function checks if PPA document already exists for a base matched
 |  invoice line that needs to be retropriced. The Adjustment Corrections on the
 |  base matched Invoice doesn't guarentee the existence of a PPA document.
 |  In case multiple PPA document exist for the base matched Invoice then we
 |  select the last PPA document created for reversal.
 |  Note: MAX(invoice_id) insures that we reverse the latest PPA.
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_ppa_exists            --OUT
 |     P_existing_ppa_inv_id   --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Ppa_Already_Exists(
             P_invoice_id          IN     NUMBER,
             P_line_number         IN     NUMBER,
             p_ppa_exists             OUT NOCOPY VARCHAR2,
             P_existing_ppa_inv_id    OUT NOCOPY NUMBER)
RETURN BOOLEAN IS

l_count               NUMBER := 0;
p_existing_invoice_id NUMBER;
debug_info            VARCHAR2(1000);

BEGIN
    --
    debug_info := 'IF ppa_already_Exists';
    SELECT count(*)
      INTO l_count
      FROM ap_invoice_lines_all
     WHERE corrected_inv_id = p_invoice_id
       AND corrected_line_number = p_line_number
       AND line_type_lookup_code IN ('RETROITEM')
       AND match_type = 'PO_PRICE_ADJUSTMENT';
    --
    IF l_count  > 0 THEN
      --
      P_ppa_exists := 'Y';
      debug_info := 'Get Existing Ppa_invoice_id';
      SELECT  invoice_id
        INTO  p_existing_ppa_inv_id   -- Bug 5525506
        FROM  ap_invoices_all AI
       WHERE  invoice_type_lookup_code = 'PO PRICE ADJUST'
         AND  source = 'PPA'
         AND  ai.invoice_id = (SELECT MAX(invoice_id)
                  FROM ap_invoice_lines_all
                 WHERE corrected_inv_id = p_invoice_id
                   AND corrected_line_number = p_line_number
                   AND line_type_lookup_code IN ('RETROITEM')
                   AND match_type = 'PO_PRICE_ADJUSTMENT'
                   );
    --
    ELSE
      --
      P_ppa_exists := 'N';
      --
    END IF;
    --
    RETURN(TRUE);
EXCEPTION
WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    RETURN(FALSE);
    --
END Ppa_already_Exists;


/*=============================================================================
 |  FUNCTION - Ipv_Dists_Exists()
 |
 |  DESCRIPTION
 |      This function checks if IPV distributions exist for base matched
 |  Invoice Line(also Price Correction and Qty Correction Lines) for a
 |  retropriced shipment
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_ipv_dists_exist  --OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Ipv_Dists_Exists(
             p_invoice_id      IN     NUMBER,
             p_line_number     IN     NUMBER,
             p_ipv_dists_exist    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

l_count               NUMBER := 0;
debug_info            VARCHAR2(1000);

BEGIN
     debug_info := 'Get Existing Ppa_invoice_id';
     SELECT count(*)
       INTO l_count
       FROM ap_invoice_distributions_all
      WHERE invoice_id =  p_invoice_id
        AND invoice_line_number = p_line_number
        AND line_type_lookup_code = 'IPV';

      IF l_count > 0 THEN
        p_ipv_dists_exist := 'Y';
      ELSE
       p_ipv_dists_exist := 'N';
      END IF;

     RETURN(TRUE);

END Ipv_Dists_Exists;


/*=============================================================================
 |  FUNCTION - Erv_Dists_Exists()
 |
 |  DESCRIPTION
 |      This function checks if ERV distributions exist for base matched
 |  Invoice Line(also Price Correction and Qty Correction Lines) for a
 |  retropriced shipment. This function is called Compute_IPV_Adjustment_Corr
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_erv_dists_exist    OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Erv_Dists_Exists(
             p_invoice_id      IN     NUMBER,
             p_line_number     IN     NUMBER,
             p_erv_dists_exist    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

l_count              NUMBER := 0;
debug_info           VARCHAR2(1000);

BEGIN
     debug_info := 'IF Erv Dists Exist';
     SELECT count(*)
       INTO l_count
       FROM ap_invoice_distributions_all
      WHERE invoice_id =  p_invoice_id
        AND invoice_line_number = p_line_number
        AND line_type_lookup_code = 'ERV';


      IF l_count > 0 THEN
        p_erv_dists_exist := 'Y';
      ELSE
        p_erv_dists_exist  := 'N';
      END IF;

  RETURN(TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    RETURN(FALSE);
    --
END Erv_Dists_Exists;


/*=============================================================================
 |  FUNCTION - Adj_Corr_Exists()
 |
 |  DESCRIPTION
 |      This function checks if Adjustment Corrections exist for base matched
 |  Invoice Line(also Price Correction and Qty Correction Lines) for a
 |  retropriced shipment.
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_adj_corr_exists    OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Adj_Corr_Exists(
             p_invoice_id      IN     NUMBER,
             p_line_number     IN     NUMBER,
             p_adj_corr_exists    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

l_count              NUMBER := 0;
debug_info           VARCHAR2(1000);
BEGIN
      debug_info := 'IF Adj Corr Exists';
      SELECT count(*)
        INTO l_count
        FROM ap_invoice_lines_all
       WHERE invoice_id = p_invoice_id
         AND corrected_inv_id = p_invoice_id
         AND corrected_line_number = p_line_number
         AND line_type_lookup_code IN ('RETROITEM')
         AND match_type = 'ADJUSTMENT_CORRECTION';

      IF l_count  > 0 THEN
        p_adj_corr_exists := 'Y';
      ELSE
        p_adj_corr_exists := 'N';
      END IF;

RETURN(TRUE);

END Adj_Corr_Exists;


/*=============================================================================
 |  FUNCTION - Corrections_Exists()
 |
 |  DESCRIPTION
 |      This function returns Price or Qty Corrections Lines for affected base
 |   matched Invoice Line depending upon the line_type_lookup_code passed to the
 |   function
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_adj_corr_exists    OUT
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Corrections_Exists(
            p_invoice_id            IN     NUMBER,
            p_line_number           IN     NUMBER,
            p_match_ype             IN     VARCHAR2,   --p_line_type_lookup_code bug#9573078
            p_lines_list               OUT NOCOPY AP_RETRO_PRICING_PKG.invoice_lines_list_type,
            p_corrections_exist        OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS

CURSOR corr_lines IS
SELECT invoice_id,
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
       generate_dists,
       match_type,
       default_dist_ccid,
       prorate_across_all_items,
       accounting_date,
       period_name,
       deferred_acctg_flag,
       set_of_books_id,
       amount,
       base_amount,
       rounding_amt,
       quantity_invoiced,
       unit_meas_lookup_code,
       unit_price,
    -- ussgl_transaction_code, - Bug 4277744
       discarded_flag,
       cancelled_flag,
       income_tax_region,
       type_1099,
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
       award_id,
       awt_group_id,
       pay_awt_group_id, -- Bug 6832773
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
       creation_date,
       created_by,
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
       primary_intended_use,
       ship_to_location_id,
       product_type,
       product_category,
       product_fisc_classification,
       user_defined_fisc_class,
       trx_business_category,
       summary_tax_line_id,
       tax_regime_code,
       tax,
       tax_jurisdiction_code,
       tax_status_code,
       tax_rate_id,
       tax_rate_code,
       tax_rate,
       wfapproval_status,
       pa_quantity,
       NULL,                --instruction_id
       NULL,                --adj_type
       cost_factor_id,       --cost_factor_id
       TAX_CLASSIFICATION_CODE,
       SOURCE_APPLICATION_ID,
       SOURCE_EVENT_CLASS_CODE,
       SOURCE_ENTITY_CODE,
       SOURCE_TRX_ID,
       SOURCE_LINE_ID,
       SOURCE_TRX_LEVEL_TYPE,
       PA_CC_AR_INVOICE_ID,
       PA_CC_AR_INVOICE_LINE_NUM,
       PA_CC_PROCESSED_CODE,
       REFERENCE_1,
       REFERENCE_2,
       DEF_ACCTG_START_DATE,
       DEF_ACCTG_END_DATE,
       DEF_ACCTG_NUMBER_OF_PERIODS,
       DEF_ACCTG_PERIOD_TYPE,
       REFERENCE_KEY5,
       PURCHASING_CATEGORY_ID,
       NULL, -- line group number
       WARRANTY_NUMBER,
       REFERENCE_KEY3,
       REFERENCE_KEY4,
       APPLICATION_ID,
       PRODUCT_TABLE,
       REFERENCE_KEY1,
       REFERENCE_KEY2,
       RCV_SHIPMENT_LINE_ID
FROM  ap_invoice_lines_all
WHERE corrected_inv_id = p_invoice_id
AND   corrected_line_number = p_line_number
AND   discarded_flag <> 'Y'
AND   cancelled_flag <> 'Y'
--Modified 'line_type_lookup_code' to 'match_type' for bug#9573078
AND   match_type = p_match_ype
AND   generate_dists = 'D';
/*AND   NOT EXISTS (SELECT 'Unapproved matched dist'
                        FROM   ap_invoice_distributions D
                        WHERE  D.invoice_id = L.invoice_id
                        AND    D.invoice_line_number = L.line_number
                        AND    nvl(D.match_status_flag, 'X') NOT IN ('A', 'T'))
AND  EXISTS (SELECT 'Holds other than Price Hold'
                       FROM   ap_holds H
                       WHERE  H.invoice_id = L.invoice_id
                       AND    H.release_lookup_code is null
                       AND    H.hold_lookup_code <> 'PRICE')); */


l_count         NUMBER := 0;
debug_info      VARCHAR2(1000);

BEGIN
    --
    debug_info := 'Open cursor Corr_line';
    OPEN corr_lines;
    FETCH corr_lines
    BULK COLLECT INTO p_lines_list;
    CLOSE corr_lines;

    IF p_lines_list.COUNT  > 0 THEN
       p_corrections_exist := 'Y';
    ELSE
       p_corrections_exist := 'N';
    END IF;

    RETURN(TRUE);
EXCEPTION
WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;

     IF ( corr_lines%ISOPEN ) THEN
        CLOSE corr_lines;
      END IF;

    RETURN(FALSE);

END Corrections_Exists;


/*=============================================================================
 |  FUNCTION - Tipv_Exists()
 |
 |  DESCRIPTION
 |      This function returns all the Tax lines allocated to the base matched
 |  (or Price/Qty Correction) line that is affected by Retropricing. The function
 |  insures that the Tax line has TIPV distribtuions that need to be
 |  Retro-Adjusted.
 |  Note : Only EXCLUSIVE tax is supported for Po matched lines. TIPV distributions
 |         can only exist on the Tax line if the original invoce line(that the tax
 |         line is allocated to) has IPV distributions. Futhermore this check is
 |         only done if original invoice has IPV dists and the Original Invoice
 |         has not been retro-adjusted
 |
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_tax_lines_list   --OUT
 |     p_tipv_exist       --OUT
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Tipv_Exists(
             p_invoice_id              IN            NUMBER,
             p_invoice_line_number     IN            NUMBER,
             p_tax_lines_list OUT NOCOPY AP_RETRO_PRICING_PKG.invoice_lines_list_type,
             p_tipv_exist                 OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

CURSOR tax_lines IS
SELECT  AIL.invoice_id,
        AIL.line_number,
        AIL.line_type_lookup_code,
        AIL.requester_id,
        AIL.description,
        AIL.line_source,
        AIL.org_id,
        AIL.inventory_item_id,
        AIL.item_description,
        AIL.serial_number,
        AIL.manufacturer,
        AIL.model_number,
        AIL.generate_dists,
        AIL.match_type,
        AIL.default_dist_ccid,
        AIL.prorate_across_all_items,
        AIL.accounting_date,
        AIL.period_name,
        AIL.deferred_acctg_flag,
        AIL.set_of_books_id,
        AIL.amount,
        AIL.base_amount,
        AIL.rounding_amt,
        AIL.quantity_invoiced,
        AIL.unit_meas_lookup_code,
        AIL.unit_price,
     -- AIL.ussgl_transaction_code, - Bug 4277744
        AIL.discarded_flag,
        AIL.cancelled_flag,
        AIL.income_tax_region,
        AIL.type_1099,
        AIL.corrected_inv_id,
        AIL.corrected_line_number,
        AIL.po_header_id,
        AIL.po_line_id,
        AIL.po_release_id,
        AIL.po_line_location_id,
        AIL.po_distribution_id,
        AIL.rcv_transaction_id,
        AIL.final_match_flag,
        AIL.assets_tracking_flag,
        AIL.asset_book_type_code,
        AIL.asset_category_id,
        AIL.project_id,
        AIL.task_id,
        AIL.expenditure_type,
        AIL.expenditure_item_date,
        AIL.expenditure_organization_id,
        AIL.award_id,
        AIL.awt_group_id,
	AIL.pay_awt_group_id,   -- Bug 6832773
        AIL.receipt_verified_flag,
        AIL.receipt_required_flag,
        AIL.receipt_missing_flag,
        AIL.justification,
        AIL.expense_group,
        AIL.start_expense_date,
        AIL.end_expense_date,
        AIL.receipt_currency_code,
        AIL.receipt_conversion_rate,
        AIL.receipt_currency_amount,
        AIL.daily_amount,
        AIL.web_parameter_id,
        AIL.adjustment_reason,
        AIL.merchant_document_number,
        AIL.merchant_name,
        AIL.merchant_reference,
        AIL.merchant_tax_reg_number,
        AIL.merchant_taxpayer_id,
        AIL.country_of_supply,
        AIL.credit_card_trx_id,
        AIL.company_prepaid_invoice_id,
        AIL.cc_reversal_flag,
        AIL.creation_date,
        AIL.created_by,
        AIL.attribute_category,
        AIL.attribute1,
        AIL.attribute2,
        AIL.attribute3,
        AIL.attribute4,
        AIL.attribute5,
        AIL.attribute6,
        AIL.attribute7,
        AIL.attribute8,
        AIL.attribute9,
        AIL.attribute10,
        AIL.attribute11,
        AIL.attribute12,
        AIL.attribute13,
        AIL.attribute14,
        AIL.attribute15,
        AIL.global_attribute_category,
        AIL.global_attribute1,
        AIL.global_attribute2,
        AIL.global_attribute3,
        AIL.global_attribute4,
        AIL.global_attribute5,
        AIL.global_attribute6,
        AIL.global_attribute7,
        AIL.global_attribute8,
        AIL.global_attribute9,
        AIL.global_attribute10,
        AIL.global_attribute11,
        AIL.global_attribute12,
        AIL.global_attribute13,
        AIL.global_attribute14,
        AIL.global_attribute15,
        AIL.global_attribute16,
        AIL.global_attribute17,
        AIL.global_attribute18,
        AIL.global_attribute19,
        AIL.global_attribute20,
        AIL.primary_intended_use,
        AIL.ship_to_location_id,
        AIL.product_type,
        AIL.product_category,
        AIL.product_fisc_classification,
        AIL.user_defined_fisc_class,
        AIL.trx_business_category,
        AIL.summary_tax_line_id,
        AIL.tax_regime_code,
        AIL.tax,
        AIL.tax_jurisdiction_code,
        AIL.tax_status_code,
        AIL.tax_rate_id,
        AIL.tax_rate_code,
        AIL.tax_rate,
        AIL.wfapproval_status,
        AIL.pa_quantity,
        NULL,                --instruction_id
        NULL,                --adj_type
	AIL.cost_factor_id,   --cost_factor_id
       AIL.TAX_CLASSIFICATION_CODE,
       AIL.SOURCE_APPLICATION_ID,
       AIL.SOURCE_EVENT_CLASS_CODE,
       AIL.SOURCE_ENTITY_CODE,
       AIL.SOURCE_TRX_ID,
       AIL.SOURCE_LINE_ID,
       AIL.SOURCE_TRX_LEVEL_TYPE,
       AIL.PA_CC_AR_INVOICE_ID,
       AIL.PA_CC_AR_INVOICE_LINE_NUM,
       AIL.PA_CC_PROCESSED_CODE,
       AIL.REFERENCE_1,
       AIL.REFERENCE_2,
       AIL.DEF_ACCTG_START_DATE,
       AIL.DEF_ACCTG_END_DATE,
       AIL.DEF_ACCTG_NUMBER_OF_PERIODS,
       AIL.DEF_ACCTG_PERIOD_TYPE,
       AIL.REFERENCE_KEY5,
       AIL.PURCHASING_CATEGORY_ID,
       NULL, -- line group number
       AIL.WARRANTY_NUMBER,
       AIL.REFERENCE_KEY3,
       AIL.REFERENCE_KEY4,
       AIL.APPLICATION_ID,
       AIL.PRODUCT_TABLE,
       AIL.REFERENCE_KEY1,
       AIL.REFERENCE_KEY2,
       AIL.RCV_SHIPMENT_LINE_ID
   FROM ap_invoice_lines AIL,
        ap_allocation_rule_lines ARL
  WHERE AIL.invoice_id = ARL.invoice_id
    AND ARL.invoice_id = p_invoice_id
    AND ARL.to_invoice_line_number = p_invoice_line_number
    AND ARL.chrg_invoice_line_number = AIL.line_number
    AND AIL.line_type_lookup_code = 'TAX'
    AND EXISTS (SELECT 1
		          FROM ap_invoice_distributions_all AID
		         WHERE AID.invoice_id = AIL.invoice_id
		           AND AID.invoice_line_number = AIL.line_number
		           AND AID.invoice_id = p_invoice_id
		           AND AID.line_type_lookup_code = 'TIPV');


l_included_tax_amount  NUMBER;
l_tipv_count           NUMBER := 0;
debug_info             VARCHAR2(1000);

BEGIN
    --
    debug_info := 'IF tipv exist';
    SELECT count(*)
      INTO l_tipv_count
      FROM ap_invoice_distributions_all d1
     WHERE invoice_id = p_invoice_id
       AND invoice_line_number <> p_invoice_line_number
       AND line_type_lookup_code = 'TIPV'
       AND charge_applicable_to_dist_id IN
            (SELECT invoice_distribution_id
               FROM ap_invoice_distributions_all
              WHERE invoice_id  = p_invoice_id
                AND invoice_line_number = p_invoice_line_number);
	--
	IF l_tipv_count > 0 THEN
	   p_tipv_exist := 'Y';
	ELSE
	   p_tipv_exist := 'N';
	END IF;
	--
	debug_info := 'Open cursor tax_lines';
	OPEN tax_lines;
    FETCH tax_lines
    BULK COLLECT INTO p_tax_lines_list;
    CLOSE tax_lines;
    --
    RETURN(TRUE);
    --
EXCEPTION
WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;
    --
    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( tax_lines%ISOPEN ) THEN
        CLOSE tax_lines;
    END IF;
    --
    RETURN(FALSE);
    --
END Tipv_Exists;


/*=============================================================================
 |  FUNCTION - Terv_Dists_Exists()
 |
 |  DESCRIPTION
 |      This function is called from Compute_TIPV_Adjustment_Corr to check if TERV
 |  distributions exist for Tax line(allocated to a original line for a
 |  retropriced shipment). Furthermore check is only made if the allocated Tax lines
 |  have TIPV distributions.
 |
 |
 |
 |  PARAMETERS
 |     P_invoice_id
 |     P_line_number
 |     p_terv_dists_exist    OUT
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Terv_Dists_Exists(
             p_invoice_id      IN     NUMBER,
             p_line_number     IN     NUMBER,
             p_terv_dists_exist    OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS

l_count              NUMBER := 0;
debug_info           VARCHAR2(1000);

BEGIN
     --
     debug_info := 'IF Terv Dists Exist';
     SELECT count(*)
       INTO l_count
       FROM ap_invoice_distributions_all
      WHERE invoice_id =  p_invoice_id
        AND invoice_line_number = p_line_number
        AND line_type_lookup_code = 'TERV';

      IF l_count > 0 THEN
        p_terv_dists_exist := 'Y';
      ELSE
        p_terv_dists_exist  := 'N';
      END IF;

  RETURN(TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    RETURN(FALSE);
    --
END Terv_Dists_Exists;

/*=============================================================================
 |  FUNCTION - Get_Invoice_distribution_id()
 |
 |  DESCRIPTION
 |      This function returns the invoice_distribution_id
 |
 |  PARAMETERS
 |     NONE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Get_Invoice_distribution_id
RETURN   NUMBER IS

l_inv_dist_id        NUMBER(15);
debug_info           VARCHAR2(1000);
BEGIN
  debug_info := 'Get Invoice_distribution_id';
  SELECT ap_invoice_distributions_s.NEXTVAL
  INTO   l_inv_dist_id
  FROM   dual;

  RETURN l_inv_dist_id;

END Get_Invoice_distribution_id;


/*=============================================================================
 |  FUNCTION - Get_Ccid()
 |
 |  DESCRIPTION
 |      This function returns the ccid depending on the Parameter
 |  p_invoice_distribution_id. This function is called in context
 |  of IPV distributions on the base matched line or Price Corrections.
 |  p_invoice_distribution_id
 |  = Related_dist_Id  for the IPV distributions on the base matched line.
 |  = corrected_dist_id   for the IPV distributions on the PC Line.
 |
 |
 |  PARAMETERS
 |     p_invoice_distribution_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION Get_Ccid(
              p_invoice_distribution_id IN NUMBER)
RETURN NUMBER IS

l_ccid            NUMBER;
debug_info        VARCHAR2(1000);

BEGIN
  debug_info := 'Get ccid';
  SELECT dist_code_combination_id
  INTO   l_ccid
  FROM   ap_invoice_distributions_all
  WHERE  invoice_distribution_id = p_invoice_distribution_id;
  --
  RETURN l_ccid;
  --
END Get_Ccid;


/*=============================================================================
 |  FUNCTION - Get_Dist_Type_lookup_code()
 |
 |  DESCRIPTION
 |      This function returns the Dist_Type_lookup_code depending on the
 |  parameter invoice_distribution_id. This function is called in context
 |  of IPV distributions on the base matched line or Price Corrections.
 |  p_invoice_distribution_id
 |  = Related_dist_Id  for the IPV distributions on the base matched line.
 |  = corrected_dist_id   for the IPV distributions on the PC Line.
 |
 |
 |  PARAMETERS
 |     p_invoice_distribution_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION  Get_Dist_Type_lookup_code(
              p_invoice_distribution_id IN NUMBER)
RETURN VARCHAR2 IS

l_line_type_lookup_code    AP_INVOICE_LINES_ALL.line_type_lookup_code%TYPE;
debug_info                 VARCHAR2(1000);

BEGIN
  debug_info := 'Get Dist_Type_lookup_code';
  SELECT DECODE(line_type_lookup_code, 'ITEM', 'RETROEXPENSE',
                                       'ACCRUAL', 'RETROACCRUAL', 'RETROEXPENSE')
  INTO   l_line_type_lookup_code
  FROM   ap_invoice_distributions_all
  WHERE  invoice_distribution_id = p_invoice_distribution_id;

  RETURN l_line_type_lookup_code;

END  Get_Dist_Type_lookup_code;


/*=============================================================================
 |  FUNCTION - get_max_ppa_line_num()
 |
 |  DESCRIPTION
 |      This function is called to get the max line number for the PPA Document
 |  from the global temp table for a given PPA invoice_id.
 |
 |  PARAMETERS
 |     P_invoice_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION get_max_ppa_line_num(
              P_invoice_id IN NUMBER)
RETURN NUMBER IS

l_max_inv_line_num         NUMBER := 0;
debug_info                 VARCHAR2(1000);

BEGIN
    debug_info := 'Get max_ppa_line_num';
    SELECT COUNT(*)
      INTO l_max_inv_line_num
      FROM ap_ppa_invoice_lines_gt
     WHERE invoice_id = P_invoice_id;

    RETURN (l_max_inv_line_num);

END get_max_ppa_line_num;


/*=============================================================================
 |  FUNCTION - Get_Exchange_Rate()
 |
 |  DESCRIPTION
 |      This function returns the Exchange rate on the Receipt or PO depending
 |  on the P_match paramter.
 |
 |  PARAMETERS
 |     P_match
 |     p_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
FUNCTION get_exchange_rate(
              P_match        IN      VARCHAR2,
              p_id           IN      NUMBER)
RETURN NUMBER IS

l_rate   NUMBER;
debug_info                 VARCHAR2(1000);
BEGIN
  debug_info := 'Get exchange_rate';
  IF (p_match    = 'RECEIPT') then
       SELECT RTXN.currency_conversion_rate
         INTO l_rate
         FROM rcv_transactions RTXN
        WHERE RTXN.transaction_id = p_id;
  ELSE
      SELECT rate
        INTO l_rate
        FROM po_headers_All
       WHERE po_header_id = p_id;

  END IF;
  --
  RETURN(l_rate);
  --
END get_exchange_rate;


/*============================================================================
 |  FUNCTION - get_invoice_amount()
 |
 |  DESCRIPTION
 |      This function sums the invoice line amounts for the PPA docs created
 |  in the Global temporary tables for a particular invoice.
 |
 |  PARAMETERS
 |     NONE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
--Bugfix:4681253 modified the signature of get_invoice_amount to make
--p_invoice_currency_code of type VARCHAR2
FUNCTION get_invoice_amount(
             P_invoice_id            IN NUMBER,
             p_invoice_currency_code IN VARCHAR2)
RETURN NUMBER IS

l_invoice_amount          NUMBER := 0;
debug_info                VARCHAR2(1000);
BEGIN
   SELECT NVL(SUM(amount), 0)
      INTO l_invoice_amount
      FROM ap_ppa_invoice_lines_gt L
     WHERE L.invoice_id = P_invoice_id;
      -- AND L.adj_type = 'PPA';  bug#9573078

   IF l_invoice_amount <> 0 THEN
      debug_info := 'Get_Invoice_Amount step2: Call ap_round_currency';
      IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
         AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      l_invoice_amount := ap_utilities_pkg.ap_round_currency(
                                 l_invoice_amount,
                                 p_invoice_currency_code);
   END IF;

 debug_info := 'l_invoice_amount is '||l_invoice_amount;
 IF AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' THEN
     AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
 END IF;

 RETURN (l_invoice_amount);

END get_invoice_amount;


/*============================================================================
 |  FUNCTION - Get_corresponding_retro_DistId()
 |
 |  DESCRIPTION
 |      This function returns the distribution_id of the corresponding Retro
 |  Expense/Accrual distribution.
 |
 |  PARAMETERS
 |     NONE
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Get_corresponding_retro_DistId(
              p_match_type  IN VARCHAR2,
              p_ccid        IN NUMBER)
RETURN NUMBER IS

l_dist_id               NUMBER;
debug_info              VARCHAR2(1000);
BEGIN
  debug_info := 'Get corresponding_retro_ccid';
  SELECT invoice_distribution_id
  INTO   l_dist_id
  FROM   ap_ppa_invoice_dists_gt
  WHERE  corrected_invoice_dist_id =
         (SELECT invoice_distribution_id --5485084
            FROM ap_invoice_distributions_all
           WHERE DECODE(p_match_type,
                        'PRICE_CORRECTION',corrected_invoice_dist_id,
                        related_id) = p_ccid
             AND line_type_lookup_code = 'IPV')
  AND line_type_lookup_code IN ('RETROEXPENSE', 'RETROACCRUAL');

  RETURN (l_dist_id);

END Get_corresponding_retro_DistId;


/*============================================================================
 |  FUNCTION - Create_Line()
 |
 |  DESCRIPTION
 |      This function is called to create zero amount adjustments lines
 |  for IPV reversals, reversals for existing Po Price Adjustment PPA lines,
 |  and to create Po Price Adjsutment lines w.r.t the Retropriced Amount.
 |
 |  PARAMETERS
 |     p_lines_rec
 |     P_calling_sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Create_Line(
              p_lines_rec          IN   AP_RETRO_PRICING_PKG.invoice_lines_rec_type,
              P_calling_sequence  IN     VARCHAR2)
RETURN BOOLEAN IS

debug_info      VARCHAR2(1000);
BEGIN

debug_info := 'Insert into ap_ppa_invoice_lines_gt';

INSERT INTO ap_ppa_invoice_lines_gt (
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
                generate_dists,
                match_type,
                default_dist_ccid,
                prorate_across_all_items,
                accounting_date,
                period_name,
                deferred_acctg_flag,
                set_of_books_id,
                amount,
                base_amount,
                rounding_amt,
                quantity_invoiced,
                unit_meas_lookup_code,
                unit_price,
             -- ussgl_transaction_code, - Bug 4277744
                discarded_flag,
                cancelled_flag,
                income_tax_region,
                type_1099,
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
                award_id,
                awt_group_id,
		pay_awt_group_id,  -- Bug 6832773
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
                creation_date,
                created_by,
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
                primary_intended_use,
                ship_to_location_id,
                product_type,
                product_category,
                product_fisc_classification,
                user_defined_fisc_class,
                trx_business_category,
                summary_tax_line_id,
                tax_regime_code,
                tax,
                tax_jurisdiction_code,
                tax_status_code,
                tax_rate_id,
                tax_rate_code,
                tax_rate,
                wfapproval_status,
                pa_quantity,
                instruction_id,
                adj_type,
                invoice_line_id,
		cost_factor_id)
           VALUES (
                p_lines_rec.invoice_id,
                p_lines_rec.line_number,
                p_lines_rec.line_type_lookup_code,
                p_lines_rec.requester_id,
                p_lines_rec.description,
                p_lines_rec.line_source,
                p_lines_rec.org_id,
                p_lines_rec.inventory_item_id,
                p_lines_rec.item_description,
                p_lines_rec.serial_number,
                p_lines_rec.manufacturer,
                p_lines_rec.model_number,
                p_lines_rec.generate_dists,
                p_lines_rec.match_type,
                p_lines_rec.default_dist_ccid,
                p_lines_rec.prorate_across_all_items,
                p_lines_rec.accounting_date,
                p_lines_rec.period_name,
                p_lines_rec.deferred_acctg_flag,
                p_lines_rec.set_of_books_id,
                p_lines_rec.amount,
                p_lines_rec.base_amount,
                p_lines_rec.rounding_amt,
                p_lines_rec.quantity_invoiced,
                p_lines_rec.unit_meas_lookup_code,
                p_lines_rec.unit_price,
             -- p_lines_rec.ussgl_transaction_code, - Bug 4277744
                p_lines_rec.discarded_flag,
                p_lines_rec.cancelled_flag,
                p_lines_rec.income_tax_region,
                p_lines_rec.type_1099,
                p_lines_rec.corrected_inv_id,
                p_lines_rec.corrected_line_number,
                p_lines_rec.po_header_id,
                p_lines_rec.po_line_id,
                p_lines_rec.po_release_id,
                p_lines_rec.po_line_location_id,
                p_lines_rec.po_distribution_id,
                p_lines_rec.rcv_transaction_id,
                p_lines_rec.final_match_flag,
                p_lines_rec.assets_tracking_flag,
                p_lines_rec.asset_book_type_code,
                p_lines_rec.asset_category_id,
                p_lines_rec.project_id,
                p_lines_rec.task_id,
                p_lines_rec.expenditure_type,
                p_lines_rec.expenditure_item_date,
                p_lines_rec.expenditure_organization_id,
                p_lines_rec.award_id,
                p_lines_rec.awt_group_id,
		p_lines_rec.pay_awt_group_id,   --Bug 6832773
                p_lines_rec.receipt_verified_flag,
                p_lines_rec.receipt_required_flag,
                p_lines_rec.receipt_missing_flag,
                p_lines_rec.justification,
                p_lines_rec.expense_group,
                p_lines_rec.start_expense_date,
                p_lines_rec.end_expense_date,
                p_lines_rec.receipt_currency_code,
                p_lines_rec.receipt_conversion_rate,
                p_lines_rec.receipt_currency_amount,
                p_lines_rec.daily_amount,
                p_lines_rec.web_parameter_id,
                p_lines_rec.adjustment_reason,
                p_lines_rec.merchant_document_number,
                p_lines_rec.merchant_name,
                p_lines_rec.merchant_reference,
                p_lines_rec.merchant_tax_reg_number,
                p_lines_rec.merchant_taxpayer_id,
                p_lines_rec.country_of_supply,
                p_lines_rec.credit_card_trx_id,
                p_lines_rec.company_prepaid_invoice_id,
                p_lines_rec.cc_reversal_flag,
                p_lines_rec.creation_date,
                p_lines_rec.created_by,
                p_lines_rec.attribute_category,
                p_lines_rec.attribute1,
                p_lines_rec.attribute2,
                p_lines_rec.attribute3,
                p_lines_rec.attribute4,
                p_lines_rec.attribute5,
                p_lines_rec.attribute6,
                p_lines_rec.attribute7,
                p_lines_rec.attribute8,
                p_lines_rec.attribute9,
                p_lines_rec.attribute10,
                p_lines_rec.attribute11,
                p_lines_rec.attribute12,
                p_lines_rec.attribute13,
                p_lines_rec.attribute14,
                p_lines_rec.attribute15,
                p_lines_rec.global_attribute_category,
                p_lines_rec.global_attribute1,
                p_lines_rec.global_attribute2,
                p_lines_rec.global_attribute3,
                p_lines_rec.global_attribute4,
                p_lines_rec.global_attribute5,
                p_lines_rec.global_attribute6,
                p_lines_rec.global_attribute7,
                p_lines_rec.global_attribute8,
                p_lines_rec.global_attribute9,
                p_lines_rec.global_attribute10,
                p_lines_rec.global_attribute11,
                p_lines_rec.global_attribute12,
                p_lines_rec.global_attribute13,
                p_lines_rec.global_attribute14,
                p_lines_rec.global_attribute15,
                p_lines_rec.global_attribute16,
                p_lines_rec.global_attribute17,
                p_lines_rec.global_attribute18,
                p_lines_rec.global_attribute19,
                p_lines_rec.global_attribute20,
                p_lines_rec.primary_intended_use,
                p_lines_rec.ship_to_location_id,
                p_lines_rec.product_type,
                p_lines_rec.product_category,
                p_lines_rec.product_fisc_classification,
                p_lines_rec.user_defined_fisc_class,
                p_lines_rec.trx_business_category,
                p_lines_rec.summary_tax_line_id,
                p_lines_rec.tax_regime_code,
                p_lines_rec.tax,
                p_lines_rec.tax_jurisdiction_code,
                p_lines_rec.tax_status_code,
                p_lines_rec.tax_rate_id,
                p_lines_rec.tax_rate_code,
                p_lines_rec.tax_rate,
                p_lines_rec.wfapproval_status,
                p_lines_rec.pa_quantity,
                p_lines_rec.instruction_id,
                p_lines_rec.adj_type,
                AP_INVOICE_LINES_INTERFACE_S.nextval,
		p_lines_rec.cost_factor_id);


    --
    RETURN(TRUE);
    --
EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;

    RETURN(FALSE);

END Create_Line;



/*============================================================================
 |  FUNCTION - Get_Base_Match_Lines()
 |
 |  DESCRIPTION
 |      This function returns the list of all base matched Invoice Lines
 |  for the Instruction that are candidate for retropricing.
 |  Note: Retro price Adjustments and Adjustment corrections may already
 |        exist for these base matched lines.
 |
 |  PARAMETERS
 |    p_instruction_id
 |    p_instruction_line_id
 |    p_base_match_lines_list
 |    P_calling_sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Get_Base_Match_Lines(
           p_instruction_id        IN     NUMBER,
           p_instruction_line_id   IN     NUMBER,
           p_base_match_lines_list    OUT NOCOPY  AP_RETRO_PRICING_PKG.invoice_lines_list_type,
           P_calling_sequence      IN     VARCHAR2)
RETURN BOOLEAN IS

current_calling_sequence   VARCHAR2(1000);
debug_info                 VARCHAR2(1000);

CURSOR base_match_lines  IS
SELECT L.invoice_id,
       L.line_number,
       L.line_type_lookup_code,
       L.requester_id,
       L.description,
       L.line_source,
       L.org_id,
       L.inventory_item_id,
       L.item_description,
       L.serial_number,
       L.manufacturer,
       L.model_number,
       L.generate_dists,
       L.match_type,
       L.default_dist_ccid,
       L.prorate_across_all_items,
       L.accounting_date,
       L.period_name,
       L.deferred_acctg_flag,
       L.set_of_books_id,
       L.amount,
       L.base_amount,
       L.rounding_amt,
       L.quantity_invoiced,
       L.unit_meas_lookup_code,
       L.unit_price,
    -- L.ussgl_transaction_code, - Bug 4277744
       L.discarded_flag,
       L.cancelled_flag,
       L.income_tax_region,
       L.type_1099,
       L.corrected_inv_id,
       L.corrected_line_number,
       L.po_header_id,
       L.po_line_id,
       L.po_release_id,
       L.po_line_location_id,
       L.po_distribution_id,
       L.rcv_transaction_id,
       L.final_match_flag,
       L.assets_tracking_flag,
       L.asset_book_type_code,
       L.asset_category_id,
       L.project_id,
       L.task_id,
       L.expenditure_type,
       L.expenditure_item_date,
       L.expenditure_organization_id,
       L.award_id,
       L.awt_group_id,
       L.pay_awt_group_id, --Bug 6832773
       L.receipt_verified_flag,
       L.receipt_required_flag,
       L.receipt_missing_flag,
       L.justification,
       L.expense_group,
       L.start_expense_date,
       L.end_expense_date,
       L.receipt_currency_code,
       L.receipt_conversion_rate,
       L.receipt_currency_amount,
       L.daily_amount,
       L.web_parameter_id,
       L.adjustment_reason,
       L.merchant_document_number,
       L.merchant_name,
       L.merchant_reference,
       L.merchant_tax_reg_number,
       L.merchant_taxpayer_id,
       L.country_of_supply,
       L.credit_card_trx_id,
       L.company_prepaid_invoice_id,
       L.cc_reversal_flag,
       L.creation_date,
       L.created_by,
       L.attribute_category,
       L.attribute1,
       L.attribute2,
       L.attribute3,
       L.attribute4,
       L.attribute5,
       L.attribute6,
       L.attribute7,
       L.attribute8,
       L.attribute9,
       L.attribute10,
       L.attribute11,
       L.attribute12,
       L.attribute13,
       L.attribute14,
       L.attribute15,
       L.global_attribute_category,
       L.global_attribute1,
       L.global_attribute2,
       L.global_attribute3,
       L.global_attribute4,
       L.global_attribute5,
       L.global_attribute6,
       L.global_attribute7,
       L.global_attribute8,
       L.global_attribute9,
       L.global_attribute10,
       L.global_attribute11,
       L.global_attribute12,
       L.global_attribute13,
       L.global_attribute14,
       L.global_attribute15,
       L.global_attribute16,
       L.global_attribute17,
       L.global_attribute18,
       L.global_attribute19,
       L.global_attribute20,
       L.primary_intended_use,
       L.ship_to_location_id,
       L.product_type,
       L.product_category,
       L.product_fisc_classification,
       L.user_defined_fisc_class,
       L.trx_business_category,
       L.summary_tax_line_id,
       L.tax_regime_code,
       L.tax,
       L.tax_jurisdiction_code,
       L.tax_status_code,
       L.tax_rate_id,
       L.tax_rate_code,
       L.tax_rate,
       L.wfapproval_status,
       L.pa_quantity,
       p_instruction_id,   --instruction_id
       NULL            ,   --adj_type
       L.cost_factor_id,    --cost_factor_id
       L.TAX_CLASSIFICATION_CODE,
       L.SOURCE_APPLICATION_ID,
       L.SOURCE_EVENT_CLASS_CODE,
       L.SOURCE_ENTITY_CODE,
       L.SOURCE_TRX_ID,
       L.SOURCE_LINE_ID,
       L.SOURCE_TRX_LEVEL_TYPE,
       L.PA_CC_AR_INVOICE_ID,
       L.PA_CC_AR_INVOICE_LINE_NUM,
       L.PA_CC_PROCESSED_CODE,
       L.REFERENCE_1,
       L.REFERENCE_2,
       L.DEF_ACCTG_START_DATE,
       L.DEF_ACCTG_END_DATE,
       L.DEF_ACCTG_NUMBER_OF_PERIODS,
       L.DEF_ACCTG_PERIOD_TYPE,
       L.REFERENCE_KEY5,
       L.PURCHASING_CATEGORY_ID,
       NULL, -- line group number
       L.WARRANTY_NUMBER,
       L.REFERENCE_KEY3,
       L.REFERENCE_KEY4,
       L.APPLICATION_ID,
       L.PRODUCT_TABLE,
       L.REFERENCE_KEY1,
       L.REFERENCE_KEY2,
       L.RCV_SHIPMENT_LINE_ID
 FROM ap_invoice_lines L,
      ap_invoice_lines_interface IL
WHERE L.po_line_location_id = IL.po_line_location_id
  AND IL.invoice_id = p_instruction_id
  AND IL.invoice_line_id = p_instruction_line_id
  AND L.discarded_flag <> 'Y'
  AND L.cancelled_flag <> 'Y'
  AND L.line_type_lookup_code = 'ITEM'
  AND L.match_type IN ('ITEM_TO_PO', 'ITEM_TO_RECEIPT')
  AND L.generate_dists = 'D'
ORDER BY L.invoice_id;  --Added for bug#9855094

BEGIN
  --
  current_calling_sequence := 'AP_RETRO_PRICING_PKG.Get_Base_Match_Lines'
                ||P_Calling_Sequence;

  debug_info :=  'Open base_match_lines';
  OPEN base_match_lines;
  FETCH base_match_lines
  BULK COLLECT INTO p_base_match_lines_list;
  CLOSE base_match_lines;
  --
  RETURN(TRUE);
  --
EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;
    --
    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( base_match_lines%ISOPEN ) THEN
        CLOSE base_match_lines;
    END IF;
    --
    RETURN(FALSE);

END Get_Base_Match_Lines;

/*============================================================================
 |  FUNCTION - Create_ppa_Invoice()
 |
 |  DESCRIPTION
 |      This function inserts a temporary Ppa Invoice Header in the Global
 |  Temporary Tables.
 |
 |  PARAMETERS
 |    p_instruction_id
 |    p_instruction_line_id
 |    p_base_match_lines_list
 |    P_calling_sequence
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION Create_ppa_Invoice(
             p_instruction_id   IN     NUMBER,
             p_invoice_id       IN     NUMBER,  --Base match line's invoice_id
             p_line_number      IN     NUMBER,  --Base match line number
             p_batch_id         IN     NUMBER,
             p_ppa_invoice_rec     OUT NOCOPY AP_RETRO_PRICING_PKG.invoice_rec_type,
             P_calling_sequence IN     VARCHAR2)
RETURN BOOLEAN IS
CURSOR ppa_header
IS
SELECT ap_invoices_s.NEXTVAL,             --invoice_id
       NVL(AII.vendor_id, AI.vendor_id),  --vendor_id
       AI.invoice_num,                    --invoice_num
       AI.set_of_books_id,                --set_of_books_id
       AI.invoice_currency_code,          --invoice_currency_code
       NVL(AII.payment_currency_code, AI.payment_currency_code),
       NVL(AII.payment_cross_rate, AI.payment_cross_rate),
       NULL,                              --invoice_amount
       --Bugfix:4681253
       AI.vendor_site_id,                 --vendor_site_id  -- from po_view
       TRUNC(SYSDATE),                           --invoice_date
       'PPA',                             --source
       'PO PRICE ADJUST',                 --Invoice_type_lookup_code
       NULL,                              --description
       NULL,
       NVL(AII.terms_id, AI.terms_id),    --terms_id
       trunc(sysdate),                           --terms_date
       NVL(AII.payment_method_code, AI.payment_method_code),  --4552701
       NVL(AII.Pay_group_lookup_code, AI.pay_group_lookup_code),
       NVL(AII.accts_pay_code_combination_id, AI.accts_pay_code_combination_id),
       'N',                               --payment_status_flag
       SYSDATE,                           --creation_date
       AII.created_by,                    --created_by
       NULL,                              --base_amount
       DECODE(sign(AI.invoice_amount), -1, 'N', AI.exclusive_payment_flag),
       AI.goods_received_date,            --goods_received_date
       NULL,                           --invoice_received_date
       -- Bug 5469166. Modified to 'User' from 'USER'
       DECODE(AI.exchange_rate_type, 'User', NVL(AII.exchange_rate, AI.exchange_rate),
              NULL) exchange_rate,
       NVL(AII.exchange_rate_type, AI.exchange_rate_type) exchange_rate_type,
       DECODE(AI.exchange_rate_type, 'User', AI.exchange_date,
                                      NULL,NULL,
                                      trunc(sysdate)) exchange_date,
       AI.attribute1,
       AI.attribute2,
       AI.attribute3,
       AI.attribute4,
       AI.attribute5,
       AI.attribute6,
       AI.attribute7,
       AI.attribute8,
       AI.attribute9,
       AI.attribute10,
       AI.attribute11,
       AI.attribute12,
       AI.attribute13,
       AI.attribute14,
       AI.attribute15,
       AI.attribute_category,
    -- AI.ussgl_transaction_code, - Bug 4277744
    -- AI.ussgl_trx_code_context, - Bug 4277744
       AI.project_id,
       AI.task_id,
       AI.expenditure_type,
       AI.expenditure_item_date,
       AI.expenditure_organization_id,
       AI.pa_default_dist_ccid,
       'N',                               --awt_flag
       AI.awt_group_id,                   --awt_group_id
       AI.pay_awt_group_id,                --pay_awt_group_id    Bug 6832773
       AI.org_id,                         --org_id
       AI.award_id,                       --award_id
       'Y',                               --approval_ready_flag
       'NOT REQUIRED',                    --wfapproval_status
       NVL(AII.requester_id, AI.requester_id),
       AI.global_attribute_category,
       NVL(aii.global_attribute1, AI.global_attribute1),
       NVL(aii.global_attribute2, AI.global_attribute2),
       NVL(aii.global_attribute3, AI.global_attribute3),
       NVL(aii.global_attribute4, AI.global_attribute4),
       NVL(aii.global_attribute5, AI.global_attribute5),
       NVL(aii.global_attribute6, AI.global_attribute6),
       NVL(aii.global_attribute7, AI.global_attribute7),
       NVL(aii.global_attribute8, AI.global_attribute8),
       NVL(AII.global_attribute9, AI.global_attribute9),
       NVL(AII.global_attribute10, AI.global_attribute10),
       NVL(AII.global_attribute11, AI.global_attribute11),
       NVL(AII.global_attribute12, AI.global_attribute12),
       NVL(AII.global_attribute13, AI.global_attribute13),
       NVL(AII.global_attribute14, AI.global_attribute14),
       NVL(AII.global_attribute15, AI.global_attribute15),
       NVL(AII.global_attribute16, AI.global_attribute16),
       NVL(AII.global_attribute17, AI.global_attribute17),
       NVL(AII.global_attribute18, AI.global_attribute18),
       NVL(AII.global_attribute19, AI.global_attribute19),
       NVL(AII.global_attribute20, AI.global_attribute20),
       p_instruction_id,                 --instruction_id
       'U',                              --instr_status_flag
       p_batch_id,                       --batch_id
       NULL,                             --doc_sequence_id
       NULL,                             --doc_sequence_value
       NULL,                              --doc_category_code
 ai.APPLICATION_ID ,
 ai.BANK_CHARGE_BEARER ,
 ai.DELIVERY_CHANNEL_CODE ,
 ai.DISC_IS_INV_LESS_TAX_FLAG ,
 ai.DOCUMENT_SUB_TYPE	,
 ai.EXCLUDE_FREIGHT_FROM_DISCOUNT	,
 ai.EXTERNAL_BANK_ACCOUNT_ID	,
 NULL , -- gl date
 ai.LEGAL_ENTITY_ID	,
 ai.NET_OF_RETAINAGE_FLAG	,
 ai.PARTY_ID	,
 ai.PARTY_SITE_ID	,
 ai.PAYMENT_CROSS_RATE_DATE	,
 ai.PAYMENT_CROSS_RATE_TYPE	,
 ai.PAYMENT_FUNCTION	,
 ai.PAYMENT_REASON_CODE	,
 ai.PAYMENT_REASON_COMMENTS	,
 ai.PAY_CURR_INVOICE_AMOUNT	,
 ai.PAY_PROC_TRXN_TYPE_CODE	,
 ai.PORT_OF_ENTRY_CODE	,
 ai.POSTING_STATUS	,
 ai.PO_HEADER_ID	,
 ai.PRODUCT_TABLE	,
 ai.PROJECT_ACCOUNTING_CONTEXT	,
 ai.QUICK_PO_HEADER_ID	,
 ai.REFERENCE_1	,
 ai.REFERENCE_2	,
 ai.REFERENCE_KEY1	,
 ai.REFERENCE_KEY2	,
 ai.REFERENCE_KEY3	,
 ai.REFERENCE_KEY4	,
 ai.REFERENCE_KEY5	,
 ai.REMITTANCE_MESSAGE1	,
 ai.REMITTANCE_MESSAGE2	,
 ai.REMITTANCE_MESSAGE3	,
 ai.SETTLEMENT_PRIORITY	,
 ai.SUPPLIER_TAX_EXCHANGE_RATE ,
 ai.SUPPLIER_TAX_INVOICE_DATE	,
 ai.SUPPLIER_TAX_INVOICE_NUMBER	,
 ai.TAXATION_COUNTRY	,
 ai.TAX_INVOICE_INTERNAL_SEQ ,
 ai.TAX_INVOICE_RECORDING_DATE	,
 ai.TAX_RELATED_INVOICE_ID	,
 ai.TRX_BUSINESS_CATEGORY	,
 ai.UNIQUE_REMITTANCE_IDENTIFIER	,
 ai.URI_CHECK_DIGIT	,
 ai.USER_DEFINED_FISC_CLASS
FROM  ap_invoices_all AI,
      ap_invoices_interface AII
WHERE AII.invoice_id = p_instruction_id  -- instruction_rec.invoice_id
AND   AI.vendor_id   = AII.vendor_id
AND   AI.invoice_id =  p_invoice_id;     -- base_match_lines_rec.invoice_id

l_new_ppa_count          NUMBER;
l_existing_ppa_count     NUMBER;
l_temp_ppa_count         NUMBER;  --bug#9855094
l_ppa_invoice_rec        AP_RETRO_PRICING_PKG.invoice_rec_type;
l_description            AP_INVOICES_ALL.description%TYPE;
l_dbseqnm                VARCHAR2(30);
l_seqassid               NUMBER;
l_seq_num_profile        VARCHAR2(80);
l_return_code            NUMBER;
current_calling_sequence VARCHAR2(1000);
debug_info               VARCHAR2(1000);


BEGIN

   current_calling_sequence := 'AP_RETRO_PRICING_PKG.Create_ppa_Invoice'
                ||P_Calling_Sequence;
   ---------------------------------------------
   debug_info := 'Create_Ppa_Invoice Step :1 Open cursor ppa_header';
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
   ---------------------------------------------
   OPEN  ppa_header;
   FETCH ppa_header INTO  l_ppa_invoice_rec;
   IF (ppa_header%NOTFOUND) THEN
        CLOSE ppa_header;
        RAISE NO_DATA_FOUND;
   END IF;
   CLOSE ppa_header;

   -------------------------------------------
   debug_info := 'Create_Ppa_Invoice Step :2 Get meaning';
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
   -------------------------------------------
   SELECT displayed_field
     INTO l_description
     FROM ap_lookup_codes
    WHERE lookup_type = 'LINE SOURCE'
      AND lookup_code = 'PO PRICE ADJUSTMENT';

   l_ppa_invoice_rec.description := l_description || '-' ||
                        l_ppa_invoice_rec.invoice_num;

   ----------------------------------------------------------------
   debug_info := 'Create_Ppa_Invoice Step :3 Get existing ppa count for the base matched line';
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
   -----------------------------------------------------------------
   SELECT count(*)
     INTO l_existing_ppa_count
     FROM ap_invoices_all  I
    WHERE I.source = 'PPA'
      AND EXISTS  (SELECT invoice_id
                     FROM ap_invoice_lines_all L
                    WHERE L.invoice_id = I.invoice_id
                      AND L.corrected_inv_id = p_invoice_id
		       --Commented below condition for bug#9855094
                      --AND L.corrected_line_number = p_line_number
                      AND L.match_type = 'PO_PRICE_ADJUSTMENT');


     --Introduced below SELECT for bug#9855094
             SELECT count(*)
             INTO l_temp_ppa_count
             FROM ap_ppa_invoices_gt apig
             WHERE  instruction_id = p_instruction_id
	      and exists(select invoice_id
                         from ap_ppa_invoice_lines_gt apilg
                         where apilg.invoice_id = apig.invoice_id
                           and apilg.corrected_inv_id = p_invoice_id
			  -- and apilg.adj_type = 'PPA'  --Commented for bug#9573078
			 and nvl(apilg.amount,0) <> 0); --Modified for bug#9573078

   l_ppa_invoice_rec.invoice_num :=  l_ppa_invoice_rec.source
        || '-' || substrb(l_ppa_invoice_rec.invoice_num,0,27)
        || '-' ||(l_existing_ppa_count + l_temp_ppa_count+1);  --bug#9855094

   debug_info := 'l_ppa_invoice_rec.invoice_num is '||l_ppa_invoice_rec.invoice_num;
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(
	          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;
   -- Removed step 4 and step 5 for bug8514744
   -- Same logic moved to apretrob.pls
  ------------------------------------------------
  debug_info := 'Create_Ppa_Invoice Step :6 Insert into ap_ppa_invoices_gt';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
  ------------------------------------------------
  INSERT INTO ap_ppa_invoices_gt(
                    accts_pay_code_combination_id,
                    amount_applicable_to_discount,
                    approval_ready_flag,
                    attribute_category,
                    attribute1,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    award_id,
                    awt_flag,
                    awt_group_id,
		    pay_awt_group_id,   -- Bug 6832773
                    base_amount,
                    batch_id,
                    created_by,
                    creation_date,
                    description,
                    exchange_date,
                    exchange_rate,
                    exchange_rate_type,
                    exclusive_payment_flag,
                    expenditure_item_date,
                    expenditure_organization_id,
                    expenditure_type,
                    global_attribute_category,
                    global_attribute1,
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
                    global_attribute2,
                    global_attribute20,
                    global_attribute3,
                    global_attribute4,
                    global_attribute5,
                    global_attribute6,
                    global_attribute7,
                    global_attribute8,
                    global_attribute9,
                    goods_received_date,
                    invoice_amount,
                    invoice_currency_code,
                    invoice_date,
                    invoice_id,
                    invoice_num,
                    invoice_received_date,
                    invoice_type_lookup_code,
                    org_id,
                    pa_default_dist_ccid,
                    pay_group_lookup_code,
                    payment_cross_rate,
                    payment_currency_code,
                    payment_method_code,
                    payment_status_flag,
                    project_id,
                    requester_id,
                    set_of_books_id,
                    source,
                    task_id,
                    terms_date,
                    terms_id,
                 -- ussgl_transaction_code, - Bug 4277744
                 -- ussgl_trx_code_context, - Bug 4277744
                    vendor_id,
                    vendor_site_id,
                    wfapproval_status,
                    doc_sequence_id,
                    doc_sequence_value,
                    doc_category_code,
                    instruction_id,
                    instr_status_flag,
                    party_id,
                    party_site_id,
                    legal_entity_id,
		    external_bank_account_id) /*Bug 9048000: Added external bank account id*/
          VALUES (  l_ppa_invoice_rec.accts_pay_code_combination_id,
                    l_ppa_invoice_rec.amount_applicable_to_discount,
                    l_ppa_invoice_rec.approval_ready_flag,
                    l_ppa_invoice_rec.attribute_category,
                    l_ppa_invoice_rec.attribute1,
                    l_ppa_invoice_rec.attribute10,
                    l_ppa_invoice_rec.attribute11,
                    l_ppa_invoice_rec.attribute12,
                    l_ppa_invoice_rec.attribute13,
                    l_ppa_invoice_rec.attribute14,
                    l_ppa_invoice_rec.attribute15,
                    l_ppa_invoice_rec.attribute2,
                    l_ppa_invoice_rec.attribute3,
                    l_ppa_invoice_rec.attribute4,
                    l_ppa_invoice_rec.attribute5,
                    l_ppa_invoice_rec.attribute6,
                    l_ppa_invoice_rec.attribute7,
                    l_ppa_invoice_rec.attribute8,
                    l_ppa_invoice_rec.attribute9,
                    l_ppa_invoice_rec.award_id,
                    l_ppa_invoice_rec.awt_flag,
                    l_ppa_invoice_rec.awt_group_id,
                    l_ppa_invoice_rec.pay_awt_group_id,   -- Bug 6832773
                    l_ppa_invoice_rec.base_amount,
                    p_batch_id,
                    l_ppa_invoice_rec.created_by,
                    l_ppa_invoice_rec.creation_date,
                    l_ppa_invoice_rec.description,
                    l_ppa_invoice_rec.exchange_date,
                    l_ppa_invoice_rec.exchange_rate,
                    l_ppa_invoice_rec.exchange_rate_type,
                    l_ppa_invoice_rec.exclusive_payment_flag,
                    l_ppa_invoice_rec.expenditure_item_date,
                    l_ppa_invoice_rec.expenditure_organization_id,
                    l_ppa_invoice_rec.expenditure_type,
                    l_ppa_invoice_rec.global_attribute_category,
                    l_ppa_invoice_rec.global_attribute1,
                    l_ppa_invoice_rec.global_attribute10,
                    l_ppa_invoice_rec.global_attribute11,
                    l_ppa_invoice_rec.global_attribute12,
                    l_ppa_invoice_rec.global_attribute13,
                    l_ppa_invoice_rec.global_attribute14,
                    l_ppa_invoice_rec.global_attribute15,
                    l_ppa_invoice_rec.global_attribute16,
                    l_ppa_invoice_rec.global_attribute17,
                    l_ppa_invoice_rec.global_attribute18,
                    l_ppa_invoice_rec.global_attribute19,
                    l_ppa_invoice_rec.global_attribute2,
                    l_ppa_invoice_rec.global_attribute20,
                    l_ppa_invoice_rec.global_attribute3,
                    l_ppa_invoice_rec.global_attribute4,
                    l_ppa_invoice_rec.global_attribute5,
                    l_ppa_invoice_rec.global_attribute6,
                    l_ppa_invoice_rec.global_attribute7,
                    l_ppa_invoice_rec.global_attribute8,
                    l_ppa_invoice_rec.global_attribute9,
                    l_ppa_invoice_rec.goods_received_date,
                    l_ppa_invoice_rec.invoice_amount,
                    l_ppa_invoice_rec.invoice_currency_code,
                    l_ppa_invoice_rec.invoice_date,
                    l_ppa_invoice_rec.invoice_id,
                    l_ppa_invoice_rec.invoice_num,
                    l_ppa_invoice_rec.invoice_received_date,
                    l_ppa_invoice_rec.invoice_type_lookup_code,
                    l_ppa_invoice_rec.org_id,
                    l_ppa_invoice_rec.pa_default_dist_ccid,
                    l_ppa_invoice_rec.pay_group_lookup_code,
                    l_ppa_invoice_rec.payment_cross_rate,
                    l_ppa_invoice_rec.payment_currency_code,
                    l_ppa_invoice_rec.payment_method_code,
                    l_ppa_invoice_rec.payment_status_flag,
                    l_ppa_invoice_rec.project_id,
                    l_ppa_invoice_rec.requester_id,
                    l_ppa_invoice_rec.set_of_books_id,
                    l_ppa_invoice_rec.source,
                    l_ppa_invoice_rec.task_id,
                    l_ppa_invoice_rec.terms_date,
                    l_ppa_invoice_rec.terms_id,
                 -- l_ppa_invoice_rec.ussgl_transaction_code, - Bug 4277744
                 -- l_ppa_invoice_rec.ussgl_trx_code_context, - Bug 4277744
                    l_ppa_invoice_rec.vendor_id,
                    l_ppa_invoice_rec.vendor_site_id,
                    l_ppa_invoice_rec.wfapproval_status,
                    l_ppa_invoice_rec.doc_sequence_id,
                    l_ppa_invoice_rec.doc_sequence_value,
                    l_ppa_invoice_rec.doc_category_code,
                    l_ppa_invoice_rec.instruction_id,
                    l_ppa_invoice_rec.instr_status_flag,
                    l_ppa_invoice_rec.party_id,
                    l_ppa_invoice_rec.party_site_id,
                    l_ppa_invoice_rec.legal_entity_id,
		    l_ppa_invoice_rec.external_bank_account_id); /*Bug 9048000: Added external bank account id*/

   --Bugfix:4681253
   p_ppa_invoice_rec := l_ppa_invoice_rec;
   --
   RETURN(TRUE);
   --
EXCEPTION
 WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    --
    IF ( ppa_header%ISOPEN ) THEN
        CLOSE ppa_header;
    END IF;
    --
    RETURN(FALSE);

END Create_ppa_Invoice;


/*============================================================================
 |  FUNCTION - get_invoice_num()
 |
 |  DESCRIPTION
 |      This function is called from the APXIIMPT.rdf
 |
 |  PARAMETERS
 |    p_invoice_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION get_invoice_num(
             p_invoice_id              IN            NUMBER)
RETURN VARCHAR2 IS

l_invoice_num       VARCHAR2(50);
debug_info          VARCHAR2(1000);
BEGIN
  debug_info := 'Get invoice_num for the corrected invoice';
  SELECT invoice_num
    INTO l_invoice_num
    FROM ap_invoices_all
   WHERE invoice_id = p_invoice_id;

   RETURN l_invoice_num;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END get_invoice_num;


/*============================================================================
 |  FUNCTION - get_corrected_pc_line_num()
 |
 |  DESCRIPTION
 |      This function is called to get the corrected line number for the
 |  Ajustment Correction Lines on the PPA document.
 |  Note: These lines correct the Zero Line Adjustments Lines for a PC.
 |
 |  PARAMETERS
 |    p_invoice_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *==========================================================================*/
FUNCTION get_corrected_pc_line_num(
             p_invoice_id              IN            NUMBER,
             p_line_number             IN            NUMBER)
RETURN NUMBER IS

l_line_number       NUMBER;
debug_info          VARCHAR2(1000);

BEGIN
  debug_info := 'Get invoice_num for the corrected invoice';
  SELECT line_number
    INTO l_line_number
    FROM ap_ppa_invoice_lines_gt
   WHERE invoice_id = p_invoice_id
     AND corrected_line_number = p_line_number
     AND match_type = 'ADJUSTMENT_CORRECTION';

   RETURN (l_line_number);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
END get_corrected_pc_line_num;


/*=============================================================================
 |  FUNCTION - Get_Erv_Ccid()
 |
 |  DESCRIPTION
 |      This function returns the ccid of the ERV distribution related to the
 |  IPV distribution on the Price Correction and (IPV+Item) distribution
 |  on the base match or qty correction.
 |
 |
 |  PARAMETERS
 |     p_invoice_distribution_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
-- Bug 5469166. Modified the logic to derive erv ccid based original IPV
FUNCTION Get_Erv_Ccid(
              p_invoice_distribution_id IN NUMBER)
RETURN NUMBER IS

l_ccid            NUMBER;
debug_info        VARCHAR2(1000);

BEGIN
  debug_info := 'Get ERV ccid';
  SELECT aid1.dist_code_combination_id
   INTO  l_ccid
   FROM  ap_invoice_distributions_all aid1
   WHERE aid1.line_type_lookup_code = 'ERV'
   AND   aid1.related_id = (SELECT aid2.related_id
                            FROM   ap_invoice_distributions_all aid2
                            WHERE  aid2.line_type_lookup_code = 'IPV'
                            AND    aid2.invoice_distribution_id =
                                   p_invoice_distribution_id);
  --
  RETURN (l_ccid);
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN (NULL);
END Get_Erv_Ccid;


/*=============================================================================
 |  FUNCTION - Get_Terv_Ccid()
 |
 |  DESCRIPTION
 |      This function returns the ccid of the TERV distribution related to the
 |  TIPV distribution.
 |
 |  PARAMETERS
 |     p_invoice_distribution_id
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  29-JUL-2003  dgulraja           Creation
 |
 *============================================================================*/
-- Bug 5469166. Modified the logic to derive erv ccid based original TIPV
FUNCTION Get_Terv_Ccid(
              p_invoice_distribution_id IN NUMBER)
RETURN NUMBER IS

l_ccid            NUMBER;
debug_info        VARCHAR2(1000);

BEGIN
  debug_info := 'Get Terv ccid';
   SELECT aid1.dist_code_combination_id
   INTO  l_ccid
   FROM  ap_invoice_distributions_all aid1
   WHERE aid1.line_type_lookup_code = 'TERV'
   AND   aid1.related_id = (SELECT aid2.related_id
                            FROM   ap_invoice_distributions_all aid2
                            WHERE  aid2.line_type_lookup_code = 'TIPV'
                            AND    aid2.invoice_distribution_id =
                                   p_invoice_distribution_id);
--
  RETURN (l_ccid);
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(NULL);
END Get_Terv_Ccid;


END AP_RETRO_PRICING_UTIL_PKG;

/
