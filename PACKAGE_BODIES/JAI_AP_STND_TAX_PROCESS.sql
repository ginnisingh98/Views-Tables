--------------------------------------------------------
--  DDL for Package Body JAI_AP_STND_TAX_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_AP_STND_TAX_PROCESS" AS
--$Header: jaiapprcb.pls 120.6.12010000.13 2010/06/22 07:52:19 jijili ship $
--|+======================================================================+
--| Copyright (c) 2007 Oracle Corporation Redwood Shores, California, USA |
--|                       All rights reserved.                            |
--+=======================================================================+
--| FILENAME                                                              |
--|     JAI_AP_STND_TAX_PROCESS.plb                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    This package offer funcitons to calculate tax amount and creat     |
--|    tax lines. Also it provide the tax modification and delete         |
--|    functionalities                                                    |
--|                                                                       |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      FUNCTION  Get_Max_Invoice_Line_Number                            |
--|      FUNCTION  Get_Max_Tax_Line_Number                                |
--|      FUNCTION  Get_Gl_Account_Type                                    |
--|      PROCEDURE Get_Tax_Cat_Serv_Type                                  |
--|      PROCEDURE Get_Invoice_Header_Infor                               |
--|      PROCEDURE Delete_Tax_Lines                                       |
--|      PROCEDURE Delete_Useless_Lines                                   |
--|      PROCEDURE Populate_Stnd_Inv_Taxes                                |
--|      PROCEDURE Default_Calculate_Taxes                                |
--|      PROCEDURE Create_Tax_Lines                                       |
--|      PROCEDURE Insert_Tax_Distribution_Lines                          |
--|      PROCEDURE Delete_Tax_Distribution_Lines                          |
--|      PROCEDURE Allocate_Tax_Dist_Lines                                |
--|      FUNCTION  Validate_Item_Dist_Lines                               |
--|      FUNCTION  Get_Pr_Processed_Flag                                  |
--|      FUNCTION  Get_Max_Doc_Source_Line_Id                             |
--|      FUNCTION  Validate_3rd_party_cm_Invoice                                                                        |
--| HISTORY                                                               |
--|     2007/08/23 Eric Ma       Created                                  |
--|     2007/12/24 Eric Ma       for inclusive tax                        |
--|     2008/01/25 Eric Ma       for Bug#6770835    File verison 120.1    |
--|     2008/01/28 Eric Ma       for Bug of not deleting tax lines        |
--|     2008/01/29 Eric Ma       for Bug#6784111                          |
--|     2008/02/18 Eric Ma       Changed Create_Tax_Lines for bug#6824857 |
--|     2008/03/19 Eric Ma       Changed Populate_Stnd_Inv_Taxes for bug#6898716
--|     2008/04/23 Eric Ma       Code change in Populate_Stnd_Inv_Taxes for bug6923963
--|     2008/11/21 Walton liu    Code change in Create_Tax_Lines for bug#7202316
--+======================================================================*/

--==========================================================================
--  FUNCTION NAME:
--
--    Validate_Item_Dist_Lines               Private
--    If any item doesn't have a distribution line of a given invoice id,
--    the function will return FALSE,otherwise it returns TRUE.
--  DESCRIPTION:
--
--
--  PARAMETERS:
--    In:   pn_invoice_id             IN NUMBER   invoice id
--
--    Out:  RETURN BOOLEAN
--
-- PRE-COND  : invoice item line and tax lines exist
-- EXCEPTIONS:
--
--===========================================================================
FUNCTION Validate_Item_Dist_Lines
( pn_invoice_id  IN NUMBER)
--, pn_line_number IN NUMBER)--According eakta's require,added a parameter by Jia Li for inclusive tax on 2008/01/25,commented out for a bug on Jan 28,2008
RETURN BOOLEAN
IS
CURSOR get_dist_line_number_cur IS
SELECT
  aila.line_number
FROM
  AP_INVOICE_LINES_ALL         aila
, Ap_Invoice_Distributions_All aida
WHERE  aila.INVOICE_ID            = aida.invoice_id (+)  --rollback to original logic
  AND  aila.line_number           = aida.invoice_line_number (+)  --rollback to original logic
  AND  aila.invoice_id            = pn_invoice_id
  --AND  aila.line_number           = pn_line_number   -- Added by Jia Li for inclusive tax on 2008/01/25
                                                       --,commented out for the bug of deleting not working on Jan 28,2008
  AND  aila.line_type_lookup_code = GV_CONSTANT_ITEM   -- ;
  AND  aida.invoice_line_number IS NULL
  AND  aida.invoice_id IS NULL ;

/*To check whether User has provided Distribution Account at the Lines Leve for bug 9341898*/
Cursor get_dist_line_number_lines_cur IS
Select 1
FROM AP_INVOICE_LINES_ALL
WHERE invoice_id = pn_invoice_id
and default_dist_ccid is not null;

ln_line_number      NUMBER ;
ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Validate_Item_Dist_Lines';
v_num               NUMBER;

BEGIN

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
  END IF;

  OPEN  get_dist_line_number_cur;
  FETCH get_dist_line_number_cur
  INTO
    ln_line_number;
  CLOSE get_dist_line_number_cur;

  OPEN get_dist_line_number_lines_cur; /*Added by nprashar for bug # 9341898*/
  FETCH get_dist_line_number_lines_cur INTO v_num;
  CLOSE get_dist_line_number_lines_cur;

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN

    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'ln_line_number ' || NVL(ln_line_number,-99)
                   );

    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit Function'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

 /* IF (ln_line_number IS NOT NULL)
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
 */
 --rollback to original logic
/*Code Added by nprashar for bug # 9341898*/

IF ln_line_number IS NOT NULL and v_num IS NOT NULL
  THEN
    RETURN TRUE;
ELSIF ln_line_number IS NULL and v_num IS NULL
     THEN
     RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF; /*Ends Here*/

/* Commented by nprashar for bug # 9341898
 IF (ln_line_number IS NULL)
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF; */

EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

  RETURN FALSE;
END Validate_Item_Dist_Lines;

--==========================================================================
--  FUNCTION NAME:
--
--    Validate_3rd_party_cm_Invoice               Private
--    As the defualt service tax should not be created for CM of
--    3rd invoice, add this function to avoid the tax generation.
--  DESCRIPTION:
--
--
--  PARAMETERS:
--    In:   pn_invoice_id             IN NUMBER   invoice id
--
--    Out:  RETURN BOOLEAN
--
-- PRE-COND  : invoice item line and tax lines exist
-- EXCEPTIONS:
--
--===========================================================================
FUNCTION Validate_3rd_party_cm_Invoice ( pn_invoice_id  IN NUMBER)
RETURN BOOLEAN
IS

CURSOR get_invoice_id_cur IS
SELECT
  aila.invoice_id
FROM
  AP_INVOICES_ALL         aila
WHERE  aila.invoice_id  = pn_invoice_id
  AND  aila.INVOICE_NUM LIKE 'ITP-CM/%'
  AND  aila.description LIKE 'Credit Memo for inclusive 3rd party taxes for receipt%'
  AND  aila.SOURCE = 'INDIA TAX INVOICE'
  AND  aila.invoice_type_lookup_code ='CREDIT';

ln_invoice_id  AP_INVOICES_ALL.invoice_id%TYPE;
ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Validate_3rd_party_cm_Invoice';
BEGIN

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
  END IF;

  OPEN  get_invoice_id_cur;
  FETCH get_invoice_id_cur
  INTO  ln_invoice_id;
  CLOSE get_invoice_id_cur;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN

    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'ln_invoice_id ' || NVL(ln_invoice_id,-99)
                   );

    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit Function'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  IF (ln_invoice_id IS NOT NULL)
  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

  RETURN FALSE;
END Validate_3rd_party_cm_Invoice;


--==========================================================================
--  PROCEDURE NAME:
--
--    Insert_Tax_Distribution_Lines               Private
--
--  DESCRIPTION:
--    Insert tax distribution lines. The allocation numbers of tax line should
--    be same as the numbers of coressponding item lines
--
--  PARAMETERS:
--    In:   pn_invoice_id             IN NUMBER   invoice id
--          pn_invoice_line_number    IN NUMBER   line number
--          pn_item_allocation_number IN NUMBER   item line allocation numbers
--          pn_tax_allocation_number  IN NUMBER   tax line allocation numbers
--    Out:
--
-- PRE-COND  : invoice item line and tax lines exist
-- EXCEPTIONS:
--
--===========================================================================


PROCEDURE Insert_Tax_Distribution_Lines
( pn_invoice_id             IN NUMBER
, pn_invoice_line_number    IN NUMBER
, pn_item_allocation_number IN NUMBER
, pn_tax_allocation_number  IN NUMBER
)
IS

ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Insert_Tax_Distribution_Lines';
BEGIN

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_line_number ' || pn_invoice_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_item_allocation_number ' || pn_item_allocation_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_tax_allocation_number ' || pn_tax_allocation_number
                   );
  END IF;

  FOR i IN (pn_tax_allocation_number+1) .. pn_item_allocation_number
  LOOP
    INSERT INTO AP_INVOICE_DISTRIBUTIONS_ALL
    ( accounting_date
    , accrual_posted_flag
    , assets_addition_flag
    , assets_tracking_flag
    , cash_posted_flag
    , distribution_line_number
    , dist_code_combination_id
    , invoice_id
    , last_updated_by
    , last_update_date
    , line_type_lookup_code
    , period_name
    , set_of_books_id
    , accts_pay_code_combination_id
    , amount
    , base_amount
    , base_invoice_price_variance
    , batch_id
    , created_by
    , creation_date
    , description
    , exchange_rate_variance
    , final_match_flag
    , income_tax_region
    , invoice_price_variance
    , last_update_login
    , match_status_flag
    , posted_flag
    , po_distribution_id
    , program_application_id
    , program_id
    , program_update_date
    , quantity_invoiced
    , rate_var_code_combination_id
    , request_id
    , reversal_flag
    , type_1099
    , unit_price
    , amount_encumbered
    , base_amount_encumbered
    , encumbered_flag
    , exchange_date
    , exchange_rate
    , exchange_rate_type
    , price_adjustment_flag
    , price_var_code_combination_id
    , quantity_unencumbered
    , stat_amount
    , amount_to_post
    , attribute1
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute_category
    , base_amount_to_post
    , cash_je_batch_id
    , expenditure_item_date
    , expenditure_organization_id
    , expenditure_type
    , je_batch_id
    , parent_invoice_id
    , pa_addition_flag
    , pa_quantity
    , posted_amount
    , posted_base_amount
    , prepay_amount_remaining
    , project_accounting_context
    , project_id
    , task_id
    , ussgl_transaction_code
    , ussgl_trx_code_context
    , earliest_settlement_date
    , req_distribution_id
    , quantity_variance
    , base_quantity_variance
    , packet_id
    , awt_flag
    , awt_group_id
    , awt_tax_rate_id
    , awt_gross_amount
    , awt_invoice_id
    , awt_origin_group_id
    , reference_1
    , reference_2
    , org_id
    , other_invoice_id
    , awt_invoice_payment_id
    , global_attribute_category
    , global_attribute1
    , global_attribute2
    , global_attribute3
    , global_attribute4
    , global_attribute5
    , global_attribute6
    , global_attribute7
    , global_attribute8
    , global_attribute9
    , global_attribute10
    , global_attribute11
    , global_attribute12
    , global_attribute13
    , global_attribute14
    , global_attribute15
    , global_attribute16
    , global_attribute17
    , global_attribute18
    , global_attribute19
    , global_attribute20
    , line_group_number
    , receipt_verified_flag
    , receipt_required_flag
    , receipt_missing_flag
    , justification
    , expense_group
    , start_expense_date
    , end_expense_date
    , receipt_currency_code
    , receipt_conversion_rate
    , receipt_currency_amount
    , daily_amount
    , web_parameter_id
    , adjustment_reason
    , award_id
    , mrc_accrual_posted_flag
    , mrc_cash_posted_flag
    , mrc_dist_code_combination_id
    , mrc_amount
    , mrc_base_amount
    , mrc_base_inv_price_variance
    , mrc_exchange_rate_variance
    , mrc_posted_flag
    , mrc_program_application_id
    , mrc_program_id
    , mrc_program_update_date
    , mrc_rate_var_ccid
    , mrc_request_id
    , mrc_exchange_date
    , mrc_exchange_rate
    , mrc_exchange_rate_type
    , mrc_amount_to_post
    , mrc_base_amount_to_post
    , mrc_cash_je_batch_id
    , mrc_je_batch_id
    , mrc_posted_amount
    , mrc_posted_base_amount
    , mrc_receipt_conversion_rate
    , credit_card_trx_id
    , dist_match_type
    , rcv_transaction_id
    , invoice_distribution_id
    , parent_reversal_id
    , tax_recoverable_flag
    , pa_cc_ar_invoice_id
    , pa_cc_ar_invoice_line_num
    , pa_cc_processed_code
    , merchant_document_number
    , merchant_name
    , merchant_reference
    , merchant_tax_reg_number
    , merchant_taxpayer_id
    , country_of_supply
    , matched_uom_lookup_code
    , gms_burdenable_raw_cost
    , accounting_event_id
    , prepay_distribution_id
    , upgrade_posted_amt
    , upgrade_base_posted_amt
    , inventory_transfer_status
    , company_prepaid_invoice_id
    , cc_reversal_flag
    , awt_withheld_amt
    , invoice_includes_prepay_flag
    , price_correct_inv_id
    , price_correct_qty
    , pa_cmt_xface_flag
    , cancellation_flag
    , invoice_line_number
    , corrected_invoice_dist_id
    , rounding_amt
    , charge_applicable_to_dist_id
    , corrected_quantity
    , related_id
    , asset_book_type_code
    , asset_category_id
    , distribution_class
    , final_payment_rounding
    , final_application_rounding
    , amount_at_prepay_xrate
    , cash_basis_final_app_rounding
    , amount_at_prepay_pay_xrate
    , intended_use
    , detail_tax_dist_id
    , rec_nrec_rate
    , recovery_rate_id
    , recovery_rate_name
    , recovery_type_code
    , recovery_rate_code
    , withholding_tax_code_id
    , tax_already_distributed_flag
    , summary_tax_line_id
    , taxable_amount
    , taxable_base_amount
    , extra_po_erv
    , prepay_tax_diff_amount
    , tax_code_id
    , vat_code
    , amount_includes_tax_flag
    , tax_calculated_flag
    , tax_recovery_rate
    , tax_recovery_override_flag
    , tax_code_override_flag
    , total_dist_amount
    , total_dist_base_amount
    , prepay_tax_parent_id
    , cancelled_flag
    , old_distribution_id
    , old_dist_line_number
    , amount_variance
    , base_amount_variance
    , historical_flag
    , rcv_charge_addition_flag
    , awt_related_id
    , related_retainage_dist_id
    , retained_amount_remaining
    , bc_event_id
    , retained_invoice_dist_id
    , final_release_rounding
    , fully_paid_acctd_flag
    , root_distribution_id
    , xinv_parent_reversal_id
    , recurring_payment_id
    , release_inv_dist_derived_from
    )
    SELECT
      accounting_date
    , accrual_posted_flag
    , assets_addition_flag
    , assets_tracking_flag
    , cash_posted_flag
    , i                       --distribution_line_number
    , dist_code_combination_id
    , invoice_id
    , last_updated_by
    , last_update_date
    , line_type_lookup_code
    , period_name
    , set_of_books_id
    , accts_pay_code_combination_id
    , amount
    , base_amount
    , base_invoice_price_variance
    , batch_id
    , created_by
    , creation_date
    , description
    , exchange_rate_variance
    , final_match_flag
    , income_tax_region
    , invoice_price_variance
    , last_update_login
    , match_status_flag
    , posted_flag
    , po_distribution_id
    , program_application_id
    , program_id
    , program_update_date
    , quantity_invoiced
    , rate_var_code_combination_id
    , request_id
    , reversal_flag
    , type_1099
    , unit_price
    , amount_encumbered
    , base_amount_encumbered
    , encumbered_flag
    , exchange_date
    , exchange_rate
    , exchange_rate_type
    , price_adjustment_flag
    , price_var_code_combination_id
    , quantity_unencumbered
    , stat_amount
    , amount_to_post
    , attribute1
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute_category
    , base_amount_to_post
    , cash_je_batch_id
    , expenditure_item_date
    , expenditure_organization_id
    , expenditure_type
    , je_batch_id
    , parent_invoice_id
    , pa_addition_flag
    , pa_quantity
    , posted_amount
    , posted_base_amount
    , prepay_amount_remaining
    , project_accounting_context
    , project_id
    , task_id
    , ussgl_transaction_code
    , ussgl_trx_code_context
    , earliest_settlement_date
    , req_distribution_id
    , quantity_variance
    , base_quantity_variance
    , packet_id
    , awt_flag
    , awt_group_id
    , awt_tax_rate_id
    , awt_gross_amount
    , awt_invoice_id
    , awt_origin_group_id
    , reference_1
    , reference_2
    , org_id
    , other_invoice_id
    , awt_invoice_payment_id
    , global_attribute_category
    , global_attribute1
    , global_attribute2
    , global_attribute3
    , global_attribute4
    , global_attribute5
    , global_attribute6
    , global_attribute7
    , global_attribute8
    , global_attribute9
    , global_attribute10
    , global_attribute11
    , global_attribute12
    , global_attribute13
    , global_attribute14
    , global_attribute15
    , global_attribute16
    , global_attribute17
    , global_attribute18
    , global_attribute19
    , global_attribute20
    , line_group_number
    , receipt_verified_flag
    , receipt_required_flag
    , receipt_missing_flag
    , justification
    , expense_group
    , start_expense_date
    , end_expense_date
    , receipt_currency_code
    , receipt_conversion_rate
    , receipt_currency_amount
    , daily_amount
    , web_parameter_id
    , adjustment_reason
    , award_id
    , mrc_accrual_posted_flag
    , mrc_cash_posted_flag
    , mrc_dist_code_combination_id
    , mrc_amount
    , mrc_base_amount
    , mrc_base_inv_price_variance
    , mrc_exchange_rate_variance
    , mrc_posted_flag
    , mrc_program_application_id
    , mrc_program_id
    , mrc_program_update_date
    , mrc_rate_var_ccid
    , mrc_request_id
    , mrc_exchange_date
    , mrc_exchange_rate
    , mrc_exchange_rate_type
    , mrc_amount_to_post
    , mrc_base_amount_to_post
    , mrc_cash_je_batch_id
    , mrc_je_batch_id
    , mrc_posted_amount
    , mrc_posted_base_amount
    , mrc_receipt_conversion_rate
    , credit_card_trx_id
    , dist_match_type
    , rcv_transaction_id
    , ap_invoice_distributions_s.NEXTVAL    --invoice_distribution_id
    , parent_reversal_id
    , tax_recoverable_flag
    , pa_cc_ar_invoice_id
    , pa_cc_ar_invoice_line_num
    , pa_cc_processed_code
    , merchant_document_number
    , merchant_name
    , merchant_reference
    , merchant_tax_reg_number
    , merchant_taxpayer_id
    , country_of_supply
    , matched_uom_lookup_code
    , gms_burdenable_raw_cost
    , accounting_event_id
    , prepay_distribution_id
    , upgrade_posted_amt
    , upgrade_base_posted_amt
    , inventory_transfer_status
    , company_prepaid_invoice_id
    , cc_reversal_flag
    , awt_withheld_amt
    , invoice_includes_prepay_flag
    , price_correct_inv_id
    , price_correct_qty
    , pa_cmt_xface_flag
    , cancellation_flag
    , invoice_line_number
    , corrected_invoice_dist_id
    , rounding_amt
    , charge_applicable_to_dist_id
    , corrected_quantity
    , related_id
    , asset_book_type_code
    , asset_category_id
    , distribution_class
    , final_payment_rounding
    , final_application_rounding
    , amount_at_prepay_xrate
    , cash_basis_final_app_rounding
    , amount_at_prepay_pay_xrate
    , intended_use
    , detail_tax_dist_id
    , rec_nrec_rate
    , recovery_rate_id
    , recovery_rate_name
    , recovery_type_code
    , recovery_rate_code
    , withholding_tax_code_id
    , tax_already_distributed_flag
    , summary_tax_line_id
    , taxable_amount
    , taxable_base_amount
    , extra_po_erv
    , prepay_tax_diff_amount
    , tax_code_id
    , vat_code
    , amount_includes_tax_flag
    , tax_calculated_flag
    , tax_recovery_rate
    , tax_recovery_override_flag
    , tax_code_override_flag
    , total_dist_amount
    , total_dist_base_amount
    , prepay_tax_parent_id
    , cancelled_flag
    , old_distribution_id
    , old_dist_line_number
    , amount_variance
    , base_amount_variance
    , historical_flag
    , rcv_charge_addition_flag
    , awt_related_id
    , related_retainage_dist_id
    , retained_amount_remaining
    , bc_event_id
    , retained_invoice_dist_id
    , final_release_rounding
    , fully_paid_acctd_flag
    , root_distribution_id
    , xinv_parent_reversal_id
    , recurring_payment_id
    , release_inv_dist_derived_from
    FROM
      ap_invoice_distributions_all
    WHERE  invoice_id               = pn_invoice_id
      AND  invoice_line_number      = pn_invoice_line_number
      AND  line_type_lookup_code    = GV_CONSTANT_MISCELLANEOUS
      AND  distribution_line_number = 1;
  END LOOP; --(i IN (pn_tax_allocation_number+1) .. pn_item_allocation_number)

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

END Insert_Tax_Distribution_Lines;

--==========================================================================
--  PROCEDURE NAME:
--
--    Delete_Tax_Distribution_Lines               Private
--
--  DESCRIPTION:
--    Insert tax distribution lines. The allocation numbers of tax line should
--    be same as the numbers of coressponding item lines
--
--  PARAMETERS:
--    In:   pn_invoice_id             IN NUMBER   invoice id
--          pn_invoice_line_number    IN NUMBER   line number
--          pn_item_allocation_number IN NUMBER   item line allocation numbers
--          pn_tax_allocation_number  IN NUMBER   tax line allocation numbers
--    Out:
--
-- PRE-COND  : invoice item line and tax lines exist
-- EXCEPTIONS:
--
--===========================================================================
PROCEDURE Delete_Tax_Distribution_Lines
( pn_invoice_id             IN NUMBER
, pn_invoice_line_number    IN NUMBER
, pn_item_allocation_number IN NUMBER
)
IS

ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Delete_Tax_Distribution_Lines';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_line_number ' || pn_invoice_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_item_allocation_number ' || pn_item_allocation_number
                   );
  END IF;

  DELETE
  FROM
    ap_invoice_distributions_all
  WHERE  invoice_id               = pn_invoice_id
    AND  invoice_line_number      = pn_invoice_line_number
    AND  line_type_lookup_code    = GV_CONSTANT_MISCELLANEOUS
    AND  distribution_line_number > pn_item_allocation_number;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );

    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Delete_Tax_Distribution_Lines;


--==========================================================================
--  PROCEDURE NAME:
--
--    Allocate_Tax_Dist_Lines               Private
--
--  DESCRIPTION:
--    Insert tax distribution lines. The allocation numbers of tax line should
--    be same as the numbers of coressponding item lines
--
--  PARAMETERS:
--    In:   pn_invoice_id               IN NUMBER   invoice id
--          pn_invoice_item_line_number IN NUMBER   line number
--    Out:
--
-- PRE-COND  : invoice item line and tax lines exist
-- EXCEPTIONS:
--
--===========================================================================

PROCEDURE Allocate_Tax_Dist_Lines
( pn_invoice_id               IN NUMBER
, pn_invoice_item_line_number IN NUMBER
)
IS
ln_invoice_id               NUMBER := pn_invoice_id;
ln_invoice_item_line_number NUMBER := pn_invoice_item_line_number;


CURSOR get_tax_cur (pn_tax_id  NUMBER)
IS
SELECT
  tax_name
, tax_account_id
, mod_cr_percentage
, adhoc_flag
, NVL (tax_rate, -1) tax_rate
, tax_type
, NVL(rounding_factor,0) rounding_factor
FROM
  jai_cmn_taxes_all
WHERE tax_id = pn_tax_id;

CURSOR item_line_cur IS
SELECT
  line_number
, amount
FROM
  ap_invoice_lines_all
WHERE invoice_id  = ln_invoice_id
  AND line_number = NVL(ln_invoice_item_line_number,line_number)
  AND line_type_lookup_code   = GV_CONSTANT_ITEM;

CURSOR invoice_dist_line_cur (pn_invoice_item_ln_number NUMBER)
IS
SELECT
  amount
, dist_code_combination_id
, assets_tracking_flag
, assets_addition_flag
, project_id
, task_id
, expenditure_type
, pa_addition_flag
, ASSET_BOOK_TYPE_CODE
, ASSET_CATEGORY_ID
FROM
  ap_invoice_distributions_all
WHERE invoice_id  = ln_invoice_id
  AND invoice_line_number = pn_invoice_item_ln_number;

CURSOR tax_line_cur  (pn_invoice_item_ln_number NUMBER)
IS
SELECT
  jail.invoice_line_number  invoice_line_number
, jail.line_amount          line_amount
, jcdt.tax_id               tax_id
, NVL(jcdt.modvat_flag,'N') modvat_flag
, aila.base_amount          base_amount
FROM
  jai_ap_invoice_lines      jail
, jai_cmn_document_taxes    jcdt
, ap_invoice_lines_all      aila
WHERE jcdt.source_doc_id              = jail.invoice_id
  AND jcdt.source_doc_line_id         = jail.invoice_line_number
  AND aila.invoice_id                 = jail.invoice_id
  AND aila.line_number                = jail.invoice_line_number
  AND jail.parent_invoice_line_number = pn_invoice_item_ln_number
  AND jail.line_type_lookup_code      = GV_CONSTANT_MISCELLANEOUS
  AND jail.invoice_id                 = ln_invoice_id
  AND jcdt.source_doc_type = jai_constants.g_ap_standalone_invoice  --Added by eric on Jan 29,2008
ORDER BY jail.invoice_line_number;

CURSOR get_allocation_numbers_cur  (pn_invoice_line_number NUMBER)
IS
SELECT
  COUNT(1)
FROM
  ap_invoice_distributions_all
WHERE invoice_id  = ln_invoice_id
  AND invoice_line_number = pn_invoice_line_number;

CURSOR get_dist_total_amount_cur
( pn_invoice_line_number NUMBER
, pn_dist_line_number    NUMBER
)
IS
SELECT
  SUM( amount )
, SUM( base_amount )
FROM
  ap_invoice_distributions_all
WHERE invoice_id  = ln_invoice_id
  AND invoice_line_number      = pn_invoice_line_number
  AND distribution_line_number < pn_dist_line_number;

ln_item_allocation_number   NUMBER ;
ln_tax_allocation_number    NUMBER ;
ln_allocation_factor        NUMBER ;
ln_loop_counter             NUMBER ;
tax_rec                     get_tax_cur%ROWTYPE;
ln_dist_total_amount        NUMBER;
ln_dist_total_base_amount   NUMBER;

ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Allocate_Tax_Dist_Lines';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_item_line_number '
                     || pn_invoice_item_line_number
                   );
  END IF;

  FOR item_line_rec IN item_line_cur
  LOOP
    --initialize the allocation variables
    ln_loop_counter            :=0;

    --Get item allocation total numbers
    OPEN  get_allocation_numbers_cur  (item_line_rec.line_number);
    FETCH get_allocation_numbers_cur
    INTO
      ln_item_allocation_number;
    CLOSE get_allocation_numbers_cur;
    --Get item allocation total numbers end

    -- make dist line numbers of each nonrec tax line same as the dist
    -- line number of its corresponding item line,sync dist line numbers
    FOR tax_line_rec IN tax_line_cur (item_line_rec.line_number)
    LOOP

      --Get item allocation total numbers
      OPEN  get_allocation_numbers_cur  (tax_line_rec.invoice_line_number);
      FETCH get_allocation_numbers_cur
      INTO
        ln_tax_allocation_number;
      CLOSE get_allocation_numbers_cur;
      --Get item allocation total numbers end

      --get tax definition parameters
      OPEN  get_tax_cur (tax_line_rec.tax_id);
      FETCH get_tax_cur
      INTO
        tax_rec;
      CLOSE get_tax_cur;
      --get tax definition parameters end

      --for non recoverable tax lines distribution numbers should
      --be same as the dist line numbers of its item line
      IF (NVL (tax_line_rec.modvat_flag, 'N') = jai_constants.no
          OR NVL (tax_rec.mod_cr_percentage, -1) <= 0
         )
      THEN
      	-- if item dist line number > dist line numbers of current tax line
      	-- ,insert tax lines.
        IF (ln_item_allocation_number >ln_tax_allocation_number)
        THEN
          insert_tax_distribution_lines
          ( pn_invoice_id             => ln_invoice_id
          , pn_invoice_line_number    => tax_line_rec.invoice_line_number
          , pn_item_allocation_number => ln_item_allocation_number
          , pn_tax_allocation_number  => ln_tax_allocation_number
          );
        ELSIF(ln_item_allocation_number <ln_tax_allocation_number)
        THEN
      	  -- if item dist line number < dist line numbers of current tax line
      	  -- ,delete tax lines.
          delete_tax_distribution_lines
          ( pn_invoice_id             => ln_invoice_id
          , pn_invoice_line_number    => tax_line_rec.invoice_line_number
          , pn_item_allocation_number => ln_item_allocation_number
          );
        END IF;
      ELSE --(recoverable tax)
        --no requirement of taking any action for the recoverable tax
         NULL;
      END IF;--(non recoverable)
    END LOOP; --(tax_line_rec IN tax_line_cur,sync dist line numbers end)

    --item distribution lines loop
    FOR item_dist_line_rec IN invoice_dist_line_cur(item_line_rec.line_number)
    LOOP
      ln_loop_counter :=ln_loop_counter + 1;

      ln_allocation_factor :=
        item_dist_line_rec.amount/item_line_rec.amount;

      FOR tax_line_rec IN tax_line_cur (item_line_rec.line_number)
      LOOP
        IF (NVL (tax_line_rec.modvat_flag, 'N') = jai_constants.no
            OR NVL (tax_rec.mod_cr_percentage, -1) <= 0
           )
        THEN
      	  IF (ln_item_allocation_number >1)
      	  THEN
      	    IF (ln_loop_counter < ln_item_allocation_number )
            THEN
      	      --get tax definition parameters
      	      OPEN  get_tax_cur (tax_line_rec.tax_id);
              FETCH get_tax_cur
              INTO
                tax_rec;
              CLOSE get_tax_cur;

      	      --allocation tax amount according to the proportion
      	      --of item dist lines
      	      UPDATE
      	        ap_invoice_distributions_all
      	      SET
      	        amount      =tax_line_rec.line_amount * ln_allocation_factor
      	        /*
      	          ROUND( tax_line_rec.line_amount *
      	                 ln_allocation_factor,tax_rec.rounding_factor
      	               )
      	        */

      	      , base_amount =tax_line_rec.base_amount *ln_allocation_factor
      	      /*
                  ROUND( tax_line_rec.base_amount *
      	                 ln_allocation_factor,tax_rec.rounding_factor
      	               )
      	       */

              , assets_tracking_flag = item_dist_line_rec.assets_tracking_flag
              , assets_addition_flag = item_dist_line_rec.assets_addition_flag
      	      , project_id           = item_dist_line_rec.project_id
      	      , task_id              = item_dist_line_rec.task_id
      	      , expenditure_type     = item_dist_line_rec.expenditure_type
      	      , pa_addition_flag     = item_dist_line_rec.PA_ADDITION_FLAG
              , dist_code_combination_id      =
      	          item_dist_line_rec.dist_code_combination_id
              , ASSET_BOOK_TYPE_CODE = item_dist_line_rec.ASSET_BOOK_TYPE_CODE
              , ASSET_CATEGORY_ID    = item_dist_line_rec.ASSET_CATEGORY_ID
      	      WHERE  invoice_id             = pn_invoice_id
                AND  invoice_line_number    = tax_line_rec.invoice_line_number
                AND  line_type_lookup_code  = GV_CONSTANT_MISCELLANEOUS
                AND  distribution_line_number = ln_loop_counter;
            ELSE --(ln_loop_counter = ln_item_allocation_number,last loop)
              OPEN  get_dist_total_amount_cur
                    ( tax_line_rec.invoice_line_number
                    , ln_loop_counter
                    );
              FETCH get_dist_total_amount_cur
              INTO
                ln_dist_total_amount
              , ln_dist_total_base_amount;
              CLOSE get_dist_total_amount_cur;

      	      UPDATE
      	        ap_invoice_distributions_all
      	      SET
      	        amount      =
      	          tax_line_rec.line_amount - ln_dist_total_amount
      	      , base_amount =
      	          tax_line_rec.base_amount - ln_dist_total_base_amount
              , assets_tracking_flag = item_dist_line_rec.assets_tracking_flag
              , assets_addition_flag = item_dist_line_rec.assets_addition_flag
              , project_id           = item_dist_line_rec.project_id
              , task_id              = item_dist_line_rec.task_id
              , expenditure_type     = item_dist_line_rec.expenditure_type
              , pa_addition_flag     = item_dist_line_rec.pa_addition_flag
      	      , dist_code_combination_id      =
      	          item_dist_line_rec.dist_code_combination_id
              , ASSET_BOOK_TYPE_CODE = item_dist_line_rec.ASSET_BOOK_TYPE_CODE
              , ASSET_CATEGORY_ID    = item_dist_line_rec.ASSET_CATEGORY_ID
              WHERE  invoice_id             = pn_invoice_id
                AND  invoice_line_number    = tax_line_rec.invoice_line_number
                AND  line_type_lookup_code  = GV_CONSTANT_MISCELLANEOUS
                AND  distribution_line_number = ln_loop_counter;
            END IF;-- (ln_loop_counter < ln_item_allocation_number )

      	  ELSE --(ln_item_allocation_number =1)
      	    --As only one item distribution line,tax lines are not
      	    --required to be allocated.

      	    UPDATE
      	      ap_invoice_distributions_all
      	    SET
      	      amount               = tax_line_rec.line_amount
      	    , base_amount          = tax_line_rec.base_amount
            , assets_tracking_flag = item_dist_line_rec.assets_tracking_flag
            , assets_addition_flag = item_dist_line_rec.assets_addition_flag
            , project_id           = item_dist_line_rec.project_id
            , task_id              = item_dist_line_rec.task_id
            , expenditure_type     = item_dist_line_rec.expenditure_type
            , pa_addition_flag     = item_dist_line_rec.pa_addition_flag
      	    , dist_code_combination_id      =
      	      item_dist_line_rec.dist_code_combination_id
            , ASSET_BOOK_TYPE_CODE = item_dist_line_rec.ASSET_BOOK_TYPE_CODE
            , ASSET_CATEGORY_ID    = item_dist_line_rec.ASSET_CATEGORY_ID
      	    WHERE  invoice_id               = pn_invoice_id
              AND  invoice_line_number      = tax_line_rec.invoice_line_number
              AND  line_type_lookup_code    = GV_CONSTANT_MISCELLANEOUS
              AND  distribution_line_number = ln_loop_counter;
      	  END IF;-- (ln_item_allocation_number >1)
        ELSE --(recoverable tax)
          --no requirement of taking any action for the recoverable tax
          NULL;
        END IF;--(non recoverable)
      END LOOP;--(item tax lines loop)
    END LOOP;--(item distribution lines loop)
  END LOOP ; -- (item_line_rec IN item_line_cur,item lines loop)
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Allocate_Tax_Dist_Lines;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Tax_Type               Private
--
--  DESCRIPTION:
--    With given  modvat_flag and credit percentage, return the tax type.
--    Tax type can be FR,fully recoverable,NR,not recoverable,or PR,partially
--    recoverable
--
--  PARAMETERS:
--      In:  pv_modvat_flag        IN VARCHAR   Y or N
--           pn_cr_percentage      IN NUMBER    Credit percentage
--
--     Out:  RETURN VARCHAR2
--
--
-- PRE-COND  : invoice exists
-- EXCEPTIONS:
--
--===========================================================================
FUNCTION Get_Tax_Type
( pv_modvat_flag   VARCHAR2
, pn_cr_percentage NUMBER
)
RETURN VARCHAR2
IS
lv_tax_type         VARCHAR2(10) ;
ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Get_Tax_Type';
BEGIN
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_modvat_flag ' || pv_modvat_flag
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_cr_percentage ' || pn_cr_percentage
                   );
  END IF; --(ln_proc_level >= ln_dbg_level)

  IF ( NVL (pv_modvat_flag, 'N') = jai_constants.no
        OR NVL (pn_cr_percentage, -1) <= 0
     )
  THEN
    lv_tax_type := 'NR' ; --NON RECOVERABLE
  ELSIF
    ( NVL (pv_modvat_flag, 'N') = jai_constants.yes
     AND NVL (pn_cr_percentage, -1) = 100
    )
  THEN
    lv_tax_type := 'FR' ; --FULLY RECOVERABLE
  ELSIF
    ( NVL (pv_modvat_flag, 'N') = jai_constants.yes
     AND NVL (pn_cr_percentage, -1) < 100
    )
  THEN
    lv_tax_type := 'PR' ; --PARTIALLY RECOVERABLE
  END IF;--( (pv_modvat_flag, 'N') = jai_constants.no)


  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'lv_tax_type ' || lv_tax_type
                   );

    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  RETURN lv_tax_type;
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

    RETURN lv_tax_type;
END Get_Tax_Type;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Dist_Account_Ccid               Private
--
--  DESCRIPTION:
--    Get the distribution account ccid for a given tax type code
--    1.get account ccid from regim level
--    2.get account ccid from org-location combination level
--    3.get account ccid from tax definition level
--
--  PARAMETERS:
--      In:
--           pn_invoice_id        IN NUMBER
--           pn_item_line_number  IN NUMBER
--           pn_organization_id   IN NUMBER
--           pn_location_id       IN NUMBER
--           pn_tax_type_code     IN VARCHAR2
--           pn_tax_acct_ccid     IN NUMBER
--           pv_tax_type          IN VARCHAR2
--
--     Out:  RETURN number, account ccid
--
--
-- PRE-COND  :
-- EXCEPTIONS:
--
--===========================================================================
FUNCTION Get_Dist_Account_Ccid
( pn_invoice_id       IN         NUMBER
, pn_item_line_number IN         NUMBER
, pn_organization_id  IN         NUMBER
, pn_location_id      IN         NUMBER
, pn_tax_type_code    IN         VARCHAR2
, pn_tax_acct_ccid    IN         NUMBER
, pv_tax_type         IN         VARCHAR2
)
RETURN NUMBER
IS
  CURSOR item_dist_account_cur IS
  SELECT
    dist_code_combination_id
  FROM
    ap_invoice_distributions_all
  WHERE invoice_id          = pn_invoice_id
    AND invoice_line_number = pn_item_line_number
    AND distribution_line_number =1;


  CURSOR jai_regimes_cur
  (
    pv_regime_code  IN  jai_rgm_definitions.regime_code%TYPE
  )
  IS
  SELECT
    regime_id
  FROM
    jai_rgm_definitions
  WHERE regime_code = pv_regime_code;

  CURSOR regime_tax_type_cur
  ( pn_regime_id       NUMBER
  , pv_tax_type_code   VARCHAR2
  )
  IS
  SELECT
    attribute_code tax_type
  FROM
    jai_rgm_registrations
  WHERE regime_id = pn_regime_id
    AND registration_type =jai_constants.regn_type_tax_types --tax type
    AND attribute_code = pv_tax_type_code;

  CURSOR regime_account_cur
  ( pn_regime_id  NUMBER
  , pn_tax_type   VARCHAR2
  )
  IS
  SELECT
    TO_NUMBER (accnts.attribute_value)
  FROM
    jai_rgm_registrations tax_types
  , jai_rgm_registrations accnts
  WHERE tax_types.regime_id           = pn_regime_id
    AND tax_types.registration_type   = jai_constants.regn_type_tax_types
    AND tax_types.attribute_code      = pn_tax_type
    AND accnts.regime_id              = tax_types.regime_id
    AND accnts.registration_type      = jai_constants.regn_type_accounts
    AND accnts.parent_registration_id = tax_types.registration_id
    AND accnts.attribute_code         = jai_constants.recovery_interim;

service_regimes_rec           jai_regimes_cur%ROWTYPE;
vat_regimes_rec               jai_regimes_cur%ROWTYPE;
ln_dist_acct_ccid             NUMBER;
ln_regime_id                  jai_rgm_definitions.regime_id%TYPE;
lv_regime_code                jai_rgm_definitions.regime_code%TYPE;
lv_regim_tax_type             jai_rgm_registrations.attribute_code%TYPE;

ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Get_Dist_Account_Ccid';

BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_organization_id ' || pn_organization_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_location_id ' || pn_location_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_organization_id ' || pn_organization_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_tax_acct_ccid ' || pn_tax_acct_ccid
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_tax_type ' || pv_tax_type
                   );
  END IF;

  IF (pv_tax_type='NR')  --NON recoverable tax
  THEN
    OPEN  item_dist_account_cur;
    FETCH item_dist_account_cur
    INTO
      ln_dist_acct_ccid ;
    CLOSE item_dist_account_cur;
  ELSE -- recoverable tax
    OPEN  jai_regimes_cur (jai_constants.service_regime);
    FETCH jai_regimes_cur
    INTO
      service_regimes_rec;
    CLOSE jai_regimes_cur;

    OPEN  jai_regimes_cur (jai_constants.vat_regime);
    FETCH jai_regimes_cur
    INTO
      vat_regimes_rec;
    CLOSE jai_regimes_cur;

    --check the tax is service taxes or not
    OPEN regime_tax_type_cur ( service_regimes_rec.regime_id
                             , pn_tax_type_code
                             );
    FETCH regime_tax_type_cur
    INTO
      lv_regim_tax_type;
    CLOSE regime_tax_type_cur;

    IF lv_regim_tax_type IS NOT NULL
    THEN
      lv_regime_code    := jai_constants.service_regime;
    ELSE -- (r_service_regime_tax is null)

      -- vat taxes
      OPEN regime_tax_type_cur ( vat_regimes_rec.regime_id
                               , pn_tax_type_code
                               );
      FETCH regime_tax_type_cur
      INTO
        lv_regim_tax_type;
      CLOSE regime_tax_type_cur;



      IF lv_regim_tax_type IS NOT NULL
      THEN
        lv_regime_code    := jai_constants.vat_regime;
      END IF; --(lv_regim_tax_type IS NOT NULL)

    END IF;   --( end of  r_service_regime_tax_type level)

    --try to get account from regim level
    IF lv_regime_code IS NULL --(tax is not difined in regim level)
    THEN
      ln_dist_acct_ccid    := pn_tax_acct_ccid;
    ELSE  --(lv_regime_code is NOT null,tax has beend difined in regim level)
      OPEN jai_regimes_cur (lv_regime_code);

      FETCH jai_regimes_cur
      INTO
        ln_regime_id;
      CLOSE jai_regimes_cur;

      IF ( pn_organization_id IS NULL
           AND pn_location_id IS NULL
         )
      THEN
        OPEN regime_account_cur
             ( ln_regime_id
             , pn_tax_type_code
             );

        FETCH regime_account_cur
        INTO
          ln_dist_acct_ccid;
        CLOSE regime_account_cur;
      ELSIF( pn_organization_id IS NOT NULL
             AND pn_location_id IS NOT NULL
           )
      THEN
        ln_dist_acct_ccid :=
          jai_cmn_rgm_recording_pkg.get_account
          ( p_regime_id         => ln_regime_id
          , p_organization_type => jai_constants.orgn_type_io
          , p_organization_id   => pn_organization_id
          , p_location_id       => pn_location_id
          , p_tax_type          => pn_tax_type_code
          , p_account_name      => jai_constants.recovery_interim
          );

      END IF; --(pn_organization_id IS NULL AND pn_location_id IS NULL )
    END IF;   --(lv_regime_code IS NULL)
  END IF;     --(lv_recoverable_flag = 'N')

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'ln_dist_acct_ccid ' || ln_dist_acct_ccid
                   );

    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  RETURN ln_dist_acct_ccid ;
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

    RETURN NULL;
END Get_Dist_Account_Ccid;


--==========================================================================
--  FUNCTION NAME:
--
--    Get_Max_Invoice_Line_Number               Private
--
--  DESCRIPTION:
--    Get the max invoice line number for a given invoice id
--
--
--  PARAMETERS:
--      In:  pn_invoice_id        IN NUMBER    invoice id
--
--     Out:  RETURN number
--
--
-- PRE-COND  : invoice exists
-- EXCEPTIONS:
--
--===========================================================================
FUNCTION Get_Max_Invoice_Line_Number (pn_invoice_id  NUMBER)
RETURN NUMBER
IS
ln_max_line_number  NUMBER;
ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Get_Max_Invoice_Line_Number';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
  END IF;

  -- add row level lock to the table ,to avoid duplicated lines created
  UPDATE ap_invoice_lines_all
  SET    invoice_id = pn_invoice_id
  WHERE  invoice_id = pn_invoice_id;

  SELECT
    NVL(MAX (line_number), 0)
  INTO
    ln_max_line_number
  FROM
    ap_invoice_lines_all
  WHERE invoice_id = pn_invoice_id;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'ln_max_line_number ' || ln_max_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  RETURN ln_max_line_number;
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                     || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

    RETURN 0;
END Get_Max_Invoice_Line_Number;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Max_Doc_Source_Line_Id               Private
--
--  DESCRIPTION:
--    Get the max invoice line number( source doc line id )for a given
--    invoice id (source id)
--
--
--  PARAMETERS:
--      In:  pn_invoice_id        IN NUMBER    invoice id
--
--     Out:  RETURN number
--
--
-- PRE-COND  : invoice exists
-- EXCEPTIONS:
--
-- CHANGE HISTORY:
--  1    29-Jan-2008     Eric Ma Created   for bug#6784111
--
--===========================================================================
FUNCTION Get_Max_Doc_Source_Line_Id (pn_invoice_id  NUMBER)
RETURN NUMBER
IS
ln_max_line_number  NUMBER;
ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Get_Max_Doc_Source_Line_Id';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
  END IF;

  -- add row level lock to the table
  UPDATE
    jai_cmn_document_taxes
  SET
    source_doc_id = pn_invoice_id
  WHERE  source_doc_id    = pn_invoice_id
    AND  source_doc_type  = jai_constants.g_ap_standalone_invoice;

  SELECT
    NVL(MAX(source_doc_line_id), 0)
  INTO
    ln_max_line_number
  FROM
    jai_cmn_document_taxes
  WHERE  source_doc_id    = pn_invoice_id
    AND  source_doc_type  = jai_constants.g_ap_standalone_invoice;


  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'ln_max_line_number ' || ln_max_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  RETURN ln_max_line_number;
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                     || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

    RETURN 0;
END Get_Max_Doc_Source_Line_Id;

--==========================================================================
--  FUNCTION NAME:
--
--    Get_Max_Tax_Line_Number               Private
--
--  DESCRIPTION:
--    Get the max tax line number for a given invoice id
--
--
--  PARAMETERS:
--      In:  pn_invoice_id                 IN NUMBER  invoice id
--           pn_parent_invoice_line_number IN NUMBER  item line number
--     Out:  RETURN number
--
--
-- PRE-COND  : invoice exists
-- EXCEPTIONS:
--
--===========================================================================
FUNCTION Get_Max_Tax_Line_Number
( pn_invoice_id                  NUMBER
, pn_parent_invoice_line_number  NUMBER
)
RETURN NUMBER
IS
ln_max_tax_line_num  NUMBER;
ln_dbg_level         NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level        NUMBER         := FND_LOG.level_procedure;
lv_proc_name         VARCHAR2 (100) := 'Get_Max_Tax_Line_Number';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_parent_invoice_line_number ' ||
                     pn_parent_invoice_line_number
                   );
  END IF;

  --add row level lock on the table to avoid data conflication
  UPDATE
    jai_cmn_document_taxes
  SET
    source_doc_parent_line_no     = pn_parent_invoice_line_number
  WHERE source_doc_id             = pn_invoice_id
    AND source_doc_parent_line_no = pn_parent_invoice_line_number
    AND source_doc_type           = jai_constants.g_ap_standalone_invoice;

  SELECT
    NVL(MAX(tax_line_no),0)
  INTO
    ln_max_tax_line_num
  FROM
    jai_cmn_document_taxes
  WHERE source_doc_id             = pn_invoice_id
    AND source_doc_parent_line_no = pn_parent_invoice_line_number
    AND source_doc_type           = jai_constants.g_ap_standalone_invoice;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'ln_max_tax_line_num ' || ln_max_tax_line_num
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  RETURN ln_max_tax_line_num;
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

    RETURN 0;
END Get_Max_Tax_Line_Number;


--==========================================================================
--  FUNCTION NAME:
--
--    Get_Gl_Account_Type               Private
--
--  DESCRIPTION:
--    Get the account type for a given ccid
--
--
--  PARAMETERS:
--      In:  pn_code_combination_id        NUMBER code combnation id
--
--     Out:  RETURN account_type
--
-- PRE-COND  : ccid exists
-- EXCEPTIONS:
--
--===========================================================================
FUNCTION Get_Gl_Account_Type (pn_code_combination_id  IN  NUMBER)
RETURN VARCHAR2
IS
CURSOR get_account_cur IS
SELECT
  account_type
FROM
  gl_code_combinations
WHERE code_combination_id = pn_code_combination_id;

lv_account_type  gl_code_combinations.account_type%TYPE;

ln_dbg_level        NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level       NUMBER         := FND_LOG.level_procedure;
lv_proc_name        VARCHAR2 (100) := 'Get_Gl_Account_Type';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_code_combination_id ' || pn_code_combination_id
                   );
  END IF;--( ln_proc_level >= ln_dbg_level )

  OPEN get_account_cur;
  FETCH get_account_cur
  INTO
    lv_account_type;
  CLOSE get_account_cur;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'lv_account_type ' || lv_account_type
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )


  RETURN lv_account_type;
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                     || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

    RETURN NULL;   -- if required exception can be handled.
END Get_Gl_Account_Type;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Tax_Cat_Serv_Type               Private
--
--  DESCRIPTION:
--    Get the tax category and  service type code for a given vendor site
--    and vendor id
--
--
--  PARAMETERS:
--      In:  pn_invoice_id        NUMBER invoice id
--           pn_vendor_site_id    NUMBER vendor site id
--
--     Out:  x_tax_category_id    NUMBER tax category id
--           x_service_type_code  NUMBER service type code
--
-- PRE-COND  : vendor exists
-- EXCEPTIONS:
--
--===========================================================================
PROCEDURE Get_Tax_Cat_Serv_Type
( pn_vendor_id          IN             NUMBER
, pn_vendor_site_id     IN             NUMBER
, xn_tax_category_id    OUT NOCOPY     NUMBER
, xv_service_type_code  OUT NOCOPY     VARCHAR2
)
IS
CURSOR get_tax_service_cur IS
SELECT
  tax_category_id, service_type_code
FROM
  jai_cmn_vendor_sites
WHERE NVL (vendor_site_id, 0) = pn_vendor_site_id
  AND vendor_id = pn_vendor_id;

ln_dbg_level   NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level  NUMBER         := FND_LOG.level_procedure;
lv_proc_name   VARCHAR2 (100) := 'Get_Tax_Cat_Serv_Type';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_vendor_id ' || pn_vendor_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_vendor_site_id ' || pn_vendor_site_id
                   );
  END IF;

  OPEN get_tax_service_cur;

  FETCH get_tax_service_cur
  INTO
    xn_tax_category_id
  , xv_service_type_code;
  CLOSE get_tax_service_cur;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'xn_tax_category_id ' || xn_tax_category_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'xv_service_type_code ' || xv_service_type_code
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                     || '. Other_Exception '
                     ,SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
    RAISE;
END Get_Tax_Cat_Serv_Type;

--==========================================================================
--  PROCEDURE NAME:
--
--   PROCEDURE Get_Invoice_Header_Infor           Private
--
--  DESCRIPTION:
--
--      For a given invoice id RETURN vendor id,vendor site id, currency code
--      and exchange rate
--
--  PARAMETERS:
--      In:   pn_invoice_id      NUMBER         invoice id
--
--
--     Out:   xn_vendor_id       number         vendor id
--            xn_vendor_site_id  number         vendor site id
--            xv_currency_code   varchar2       currency code
--            xn_exchange_rate   number         exchange rate
--            xn_batch_id        number         xn_batch_id
--
-- PRE-COND  : invoice exists
-- EXCEPTIONS:
--
--
--========================================================================
PROCEDURE Get_Invoice_Header_Infor
( pn_invoice_id      IN             NUMBER
, xn_vendor_id       OUT NOCOPY     NUMBER
, xn_vendor_site_id  OUT NOCOPY     NUMBER
, xv_currency_code   OUT NOCOPY     VARCHAR2
, xn_exchange_rate   OUT NOCOPY     NUMBER
, xn_batch_id        OUT NOCOPY     NUMBER
)
IS
ln_dbg_level   NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level  NUMBER         := FND_LOG.level_procedure;
lv_proc_name   VARCHAR2 (100) := 'Get_Invoice_Header_Infor';

CURSOR Get_Invoice_Header_Infor_cur IS
SELECT
  vendor_id
, vendor_site_id
, invoice_currency_code
, exchange_rate
, batch_id
FROM
  ap_invoices_all
WHERE invoice_id = pn_invoice_id;
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
  END IF; --( ln_proc_level >= ln_dbg_level)  ;

  OPEN  Get_Invoice_Header_Infor_cur ;
  FETCH Get_Invoice_Header_Infor_cur
  INTO
    xn_vendor_id
  , xn_vendor_site_id
  , xv_currency_code
  , xn_exchange_rate
  , xn_batch_id ;
  CLOSE Get_Invoice_Header_Infor_cur ;

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'xn_vendor_id ' || xn_vendor_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'xn_vendor_site_id ' || xn_vendor_site_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'xv_currency_code ' || xv_currency_code
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'xn_exchange_rate ' || xn_exchange_rate
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'xn_batch_id ' || xn_batch_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                     || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
    RAISE;
END Get_Invoice_Header_Infor;

--==========================================================================
--  PROCEDURE NAME:
--
--   PROCEDURE Delete_Tax_Lines           Private
--
--  DESCRIPTION:
--
--     Delete exclusive taxes from ap invoice/dist lines table and
--     jai_ap_invoice_line. Besides, all tax lines in jai_cmn_document_taxes
--     will be deleted in case of pv_modified_only_flag='N'
--  PARAMETERS:
--      In:  pn_invoice_id           NUMBER         invoice id
--           pn_line_number          NUMBER         invoice item line number
--           pv_modified_only_flag   VARCHAR2       indicate flag of
--                                                  tax line modification
--     Out:
--
--
--  DESIGN REFERENCES:
--     AP Technical Design 2.1.doc
--
--  CHANGE HISTORY:
--
--  1    23-Aug-2007     Eric Ma Created
--  2    20-Nov-2007     Eric Ma modified for inclusive tax
--===========================================================================
PROCEDURE Delete_Tax_Lines
( pn_invoice_id          NUMBER
, pn_line_number         NUMBER
, pv_modified_only_flag  VARCHAR2 DEFAULT 'N'
)
IS
ln_invoice_id           NUMBER         := pn_invoice_id;
ln_invoice_line_number  NUMBER         := pn_line_number;
lv_modified_only_flag   VARCHAR2 (1)   := pv_modified_only_flag;
ln_dbg_level            NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level           NUMBER         := FND_LOG.level_procedure;
lv_proc_name            VARCHAR2 (100) := 'Delete_Tax_Lines';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_line_number '|| pn_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_modified_only_flag ' || pv_modified_only_flag
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  IF (lv_modified_only_flag = 'N')
  THEN
  --delete all taxes lines for the specified invoice id and invoice item line
  --if invoice line number is null, all lines for the invoice will be deleted
    DELETE
    FROM
      jai_cmn_document_taxes jcdt
    WHERE  jcdt.source_doc_id = ln_invoice_id
      AND  jcdt.source_doc_type = jai_constants.g_ap_standalone_invoice
    --added by  eric for inclusive tax
    --------------------------------------------------------------------
      AND  jcdt.source_doc_parent_line_no=
           NVL( ln_invoice_line_number, jcdt.source_doc_parent_line_no);


    --end of modification -----------------------------------------------

/*Commented out by eric for inclusive tax
      AND  EXISTS
           ( SELECT
               'X'
             FROM
               jai_ap_invoice_lines jail
             WHERE jail.invoice_line_number = jcdt.source_doc_line_id
               AND jail.invoice_id  =    ln_invoice_id
               AND NVL(jail.parent_invoice_line_number,-1) =
                   NVL(NVL( ln_invoice_line_number
                          , jail.parent_invoice_line_number),-1)
           );
*/
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                     || '.Delete from jai_cmn_document_taxes'
                   , SQL%ROWCOUNT||' ROWS DELETED '
                   );
    END IF;
  END IF;  --(lv_modified_only_flag = 'N')

  --Delete all exclusive taxes lines for the specified invoice id and item line
  --number. If invoice line number is null, all exclusive tax lines for the
  --invoice will be deleted from ap_invoice_lines_all
  DELETE
  FROM
    ap_invoice_lines_all aila
  WHERE aila.invoice_id = ln_invoice_id
    AND EXISTS
        (
         SELECT
           'X'
         FROM
           jai_ap_invoice_lines jail
         WHERE jail.invoice_id          = ln_invoice_id
           AND jail.invoice_line_number = aila.line_number
           AND jail.parent_invoice_line_number =
                 NVL ( ln_invoice_line_number
                     , parent_invoice_line_number
                     )
        )
    AND line_type_lookup_code = GV_CONSTANT_MISCELLANEOUS;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                 , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                   || '.Delete from ap_invoice_lines_all'
                 , SQL%ROWCOUNT||' ROWS DELETED '
                 );
  END IF;--( ln_proc_level >= ln_dbg_level)

  --Delete all exclusive taxes lines for the specified invoice id and item line
  --number. If invoice line number is null, all exclusive tax lines for the
  --invoice will be deleted from ap_invoice_distributions_all
  DELETE
  FROM
    ap_invoice_distributions_all aida
  WHERE aida.invoice_id = ln_invoice_id
    AND EXISTS
        (
         SELECT
           'X'
         FROM
           jai_ap_invoice_lines jail
         WHERE jail.invoice_id          = ln_invoice_id
           AND jail.invoice_line_number = aida.invoice_line_number
           AND jail.parent_invoice_line_number =
                 NVL (ln_invoice_line_number, parent_invoice_line_number)
         )
    AND line_type_lookup_code = GV_CONSTANT_MISCELLANEOUS;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                 , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                   || '.Delete from ap_invoice_distributions_all'
                 , SQL%ROWCOUNT||' ROWS DELETED '
                 );
  END IF;


  --Delete all exclusive taxes lines for the specified invoice id and item line
  --number. If invoice line number is null, all exclusive tax lines for the
  --invoice will be deleted from jai_ap_invoice_lines


  DELETE
  FROM
    jai_ap_invoice_lines
  WHERE invoice_id = ln_invoice_id
    AND parent_invoice_line_number =
          NVL(ln_invoice_line_number,parent_invoice_line_number)
    AND line_type_lookup_code = GV_CONSTANT_MISCELLANEOUS;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING( ln_proc_level
                 , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                   || '.Delete from jai_ap_invoice_lines'
                 , SQL%ROWCOUNT||' ROWS DELETED '
                 );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                     || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Delete_Tax_Lines;

--==========================================================================
--  PROCEDURE NAME:
--
--   PROCEDURE delete_useless_line           Private
--
--  DESCRIPTION:
--
--      For a given invoice id ,delete all lines that are not related to the
--      invoice. Both item lines and tax line in starndard AP and JAI
--      AP module are deleted
--
--  PARAMETERS:
--      In:  pn_invoice_id      NUMBER         invoice id
--
--     Out:
--
--
--  DESIGN REFERENCES:
--     AP Technical Design 2.1.doc
--
--  CHANGE HISTORY:
--
--  1    23-Aug-2007     Eric Ma Created
--  2    30-Nov-2007     Eric Ma Modified for inclusive tax
--===========================================================================
PROCEDURE Delete_Useless_Lines (pn_invoice_id  IN  NUMBER)
IS
ln_invoice_id  NUMBER         := pn_invoice_id;
ln_dbg_level   NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level  NUMBER         := FND_LOG.level_procedure;
lv_proc_name   VARCHAR2 (100) := 'Delete_Useless_Lines';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  -- when a item line is deleted from the Ap invoice work bench,
  -- the related tax rows have to be deleted from other 4 tables as well
  -- and the corresoponding item row in jai_ap_invoice_lines need to be erased
  -- either

  --delete all tax lines not attached to a item that exists in AP Inv Line
  --table from jai_cmn_document_taxes
  DELETE
  FROM
    jai_cmn_document_taxes jcdt
  WHERE jcdt.source_doc_id   = ln_invoice_id
    AND jcdt.source_doc_type = jai_constants.g_ap_standalone_invoice
    --modified by eric for inclusive taxes
    ----------------------------------------------------------------
    AND NOT EXISTS
        (
         SELECT
           'X'
         FROM
           ap_invoice_lines_all aila
         WHERE aila.invoice_id  = ln_invoice_id
           AND aila.line_number = jcdt.source_doc_parent_line_no
        );
   --end of modification by eric for inclusive taxes-----------------

/*commented out by eric for inclusive taxes

    AND EXISTS
        (
         SELECT
           'X'
         FROM
           jai_ap_invoice_lines jail
         WHERE jail.invoice_id          = ln_invoice_id
           AND jail.invoice_line_number = jcdt.source_doc_line_id
           AND NOT EXISTS
               (
                 SELECT
                   'X'
                 FROM
                   ap_invoice_lines_all aila
                 WHERE aila.invoice_id = ln_invoice_id
                   AND aila.line_number =jail.parent_invoice_line_number
               )
        );
*/


  -- delete miscellaneous  from ap_invoice_distributions_all
  DELETE
  FROM
    ap_invoice_distributions_all aida
  WHERE aida.invoice_id = ln_invoice_id
    AND EXISTS
        (
         SELECT
           'X'
         FROM
           jai_ap_invoice_lines jail
         WHERE invoice_id = ln_invoice_id
           AND jail.invoice_line_number = aida.invoice_line_number
           AND NOT EXISTS
               (
                 SELECT
                   'X'
                 FROM
                   ap_invoice_lines_all aila
                 WHERE aila.invoice_id  = ln_invoice_id
                   AND (aila.line_number =jail.parent_invoice_line_number  OR aila.line_type_lookup_code = GV_CONSTANT_ITEM) --added by Bgowrava for Bug#9387830
               )
        )
    AND line_type_lookup_code = GV_CONSTANT_MISCELLANEOUS;

  --delete miscellaneous lines in ap_invoice_lines_all
  DELETE
  FROM
    ap_invoice_lines_all aila
  WHERE aila.invoice_id = ln_invoice_id
    AND EXISTS
        (
         SELECT
           'X'
         FROM
           jai_ap_invoice_lines jail
         WHERE jail.invoice_id = ln_invoice_id
           AND jail.invoice_line_number = aila.line_number
           AND NOT EXISTS
               (
                SELECT
                  'X'
                FROM
                  ap_invoice_lines_all aila
                WHERE aila.invoice_id =ln_invoice_id
                  AND aila.line_number = jail.parent_invoice_line_number
               )
        )
    AND line_type_lookup_code = GV_CONSTANT_MISCELLANEOUS;

  -- delete ITEM lines from  jai_ap_invoice_lines
  DELETE
  FROM
    jai_ap_invoice_lines jail
  WHERE jail.invoice_id = ln_invoice_id
    AND NOT EXISTS
        (
          SELECT
            line_number
          FROM
            ap_invoice_lines_all aila
          WHERE aila.invoice_id  = ln_invoice_id
            AND aila.line_number = jail.invoice_line_number
        )
    AND line_type_lookup_code = GV_CONSTANT_ITEM;

  -- delete miscelleaneous line from jai_ap_invoice_lines
  DELETE
  FROM
    jai_ap_invoice_lines jail
  WHERE
    jail.invoice_id = ln_invoice_id
    AND NOT EXISTS
        (
         SELECT
           'X'
         FROM
           ap_invoice_lines_all aila
         WHERE aila.invoice_id =ln_invoice_id
           AND aila.line_number = jail.parent_invoice_line_number
        )
    AND line_type_lookup_code = GV_CONSTANT_MISCELLANEOUS;

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Delete_Useless_Lines;

--==========================================================================
--  PROCEDURE NAME:
--
--    Update_Jai_Line_Amount       Private
--
--  DESCRIPTION:
--
--    update item lines in jai_ap_invoice_lines table,tax category,
--    location_id, can be changed from IL form while line amount, currency,
--    vendor_site_id, are only allowed to be modified from AP invoice work
--    bench.
--
--  PARAMETERS:
--      In:  pn_invoice_id      NUMBER
--           pn_line_number     NUMBER
--           pn_line_amount     NUMBER
--
--     Out:
--
--
--  DESIGN REFERENCES:
--     AP Technical Design 2.1.doc
--
--  CHANGE HISTORY:
--
--  1    09-SEP-2007     Eric Ma Created
--
--===========================================================================
PROCEDURE Update_Jai_Line_Amount
( pn_invoice_id  IN  NUMBER
, pn_line_number IN  NUMBER
, pn_line_amount IN  NUMBER
)
IS
ln_dbg_level   NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level  NUMBER         := FND_LOG.level_procedure;
lv_proc_name   VARCHAR2 (100) := 'Update_Jai_Line_Amount';
BEGIN
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_line_number ' || pn_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_line_amount ' || pn_line_amount
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  UPDATE
    jai_ap_invoice_lines
  SET
    line_amount                = pn_line_amount
  where  invoice_id            = pn_invoice_id
  AND    invoice_line_number   = pn_line_number ;

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                   || '.DML (UPDATE jai_ap_invoice_lines)'
                   ,SQL%ROWCOUNT || ' ROWS UPDATED.'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

EXCEPTION
 WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Update_Jai_Line_Amount;

--==========================================================================
--  PROCEDURE NAME:
--
--    Update_Jai_Item_Info        Private
--
--  DESCRIPTION:
--
--    update item lines in jai_ap_invoice_lines table,tax category,
--    location_id, can be changed from IL form while line amount, currency,
--    vendor_site_id, are only allowed to be modified from AP invoice work
--    bench.
--
--  PARAMETERS:
--      In:   pn_invoice_id         NUMBER
--            pn_vndr_site_id       NUMBER
--            pn_currency_code      NUMBER
--
--     Out:
--
--
--  DESIGN REFERENCES:
--     AP Technical Design 2.1.doc
--
--  CHANGE HISTORY:
--
--  1    09-SEP-2007     Eric Ma Created
--
--===========================================================================
PROCEDURE Update_Jai_Item_Info
( pn_invoice_id    IN  NUMBER
, pn_vndr_site_id  IN  NUMBER
, pn_currency_code IN  VARCHAR2
, pn_tax_category_id IN NUMBER
)
IS
ln_dbg_level   NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level  NUMBER         := FND_LOG.level_procedure;
lv_proc_name   VARCHAR2 (100) := 'Update_Jai_Item_Info';
BEGIN
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_vndr_site_id '    || pn_vndr_site_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_currency_code '   || pn_currency_code
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_tax_category_id '   || pn_tax_category_id
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )


  UPDATE
    jai_ap_invoice_lines
  SET
    supplier_site_id           = pn_vndr_site_id
  , currency_code              = pn_currency_code
  , tax_category_id            = pn_tax_category_id
  WHERE  invoice_id            = pn_invoice_id
  AND    line_type_lookup_code = GV_CONSTANT_ITEM ;

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                   || '.DML (UPDATE jai_ap_invoice_lines)'
                   ,SQL%ROWCOUNT || ' ROWS UPDATED.'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

EXCEPTION
 WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Update_Jai_Item_Info;

--==========================================================================
--  PROCEDURE NAME:
--
--    Populate_Stnd_Inv_Taxes               Public
--
--  DESCRIPTION:
--
--      This procedure is main entrance procedure used by form JAINAPST and
--      standard AP invoice workbench.it invokes the procedure create_tax_line
--      to populate the tax lines
--
--  PARAMETERS:
--      In:  pn_invoice_id      number
--           pn_line_number     NUMBER
--           pn_vendor_site_id  NUMBER
--           pv_currency        VARCHAR2
--           pn_line_amount     NUMBER
--           pn_tax_category_id number
--           pv_tax_modified    VARCHAR2
--
--
--     Out:
--
--
--  DESIGN REFERENCES:
--     AP Technical Design 2.1.doc
--
--  CHANGE HISTORY:
--
--  1    23-Aug-2007     Eric Ma Created
--  2    19-Mar-2008     Changed Default_Calculate_Taxes for bug#6898716
--  3    23-Apr-2008     Eric Ma Code change in Populate_Stnd_Inv_Taxes for bug6923963
--  4    03-Feb-2010	 JMEENA for bug 9237446
--			 Added cursor cur_credit_memo_check to check if the invoice is TDS Credit memo then service tax should not be defaulted.
--===========================================================================
PROCEDURE Populate_Stnd_Inv_Taxes
( pn_invoice_id       NUMBER
, pn_line_number      NUMBER
, pn_vendor_site_id   NUMBER
, pv_currency         VARCHAR2
, pn_line_amount      NUMBER DEFAULT NULL
, pn_tax_category_id  NUMBER DEFAULT NULL
, pv_tax_modified     VARCHAR2
, pn_old_tax_category_id  VARCHAR2
)

IS
ln_std_invoice_id       NUMBER         := pn_invoice_id;
ln_std_line_number      NUMBER         := pn_line_number;
ln_std_vendor_site_id   NUMBER         := pn_vendor_site_id;
lv_std_currency_code    VARCHAR2 (15)  := pv_currency;
ln_std_tax_category_id  NUMBER         := pn_tax_category_id;
ln_jai_tax_line_ctg_id  NUMBER;
lv_std_tax_modified     VARCHAR2 (1)   := pv_tax_modified;
ln_jai_vndr_site_id     NUMBER         := NULL;
lv_jai_currency_code    VARCHAR2 (15)  := NULL;
ln_jai_tax_category_id  NUMBER         := NULL;
ln_jai_line_amount      NUMBER         := NULL;
ln_vendor_id            NUMBER;
ln_vendor_site_id       NUMBER;
lv_currency_code        VARCHAR2 (15);
ln_exchange_rate        NUMBER;
lv_service_type_code    VARCHAR2 (30);
ln_batch_id             NUMBER;
ln_tax_category_id      NUMBER;
ln_dbg_level            NUMBER         := FND_LOG.g_current_runtime_level;
ln_proc_level           NUMBER         := FND_LOG.level_procedure;
lv_proc_name            VARCHAR2 (100) := 'Populate_Stnd_Inv_Taxes';
ln_supplier_id          NUMBER;
l_chk_del_flag          VARCHAR2(1) ;
ln_tax_line_no          NUMBER; -- Added by eric ma for the bug 6898716 on Mar 19,2008
-- Get the details of inv in the IL table

CURSOR jai_invoice_exist_cur IS
SELECT
  supplier_site_id
, currency_code
, tax_category_id
, line_amount
FROM
  jai_ap_invoice_lines
WHERE invoice_id = pn_invoice_id
  AND invoice_line_number = NVL (pn_line_number, invoice_line_number)
  AND line_type_lookup_code = GV_CONSTANT_ITEM;

CURSOR jai_tax_line_ctg_cur IS
SELECT
  tax_category_id
FROM
  jai_ap_invoice_lines
WHERE invoice_id = pn_invoice_id
  AND parent_invoice_line_number = pn_line_number;



-- Get the details of supplier id
CURSOR  jai_get_supplier_id (pn_invoice_id NUMBER)  IS
  SELECT  vendor_id
    FROM ap_invoices_all
   WHERE invoice_id = pn_invoice_id;


-- Get the tax category_id  of supplier id
cursor get_setup_tax_category_id ( p_supplier_id number , p_supplier_site_id number) is
select tax_category_id from jai_cmn_vendor_sites where vendor_id =p_supplier_id
and vendor_site_id = p_supplier_site_id;



--Get the changed amount in the invoice line level
--part 1 is the case of line amount changed
--part 2 is the case of line added or deleted
CURSOR diff_inv_lines_cur IS
SELECT
  apia.line_number line_number
, apia.amount      line_amount
FROM
  ap_invoice_lines_all apia
, jai_ap_invoice_lines jail
WHERE apia.invoice_id  = jail.invoice_id
  AND apia.line_number = jail.invoice_line_number
  AND apia.invoice_id  = ln_std_invoice_id
  AND apia.amount <> jail.line_amount
  AND apia.line_type_lookup_code = jail.line_type_lookup_code
  AND apia.line_type_lookup_code = GV_CONSTANT_ITEM

UNION ALL

SELECT
  apia.line_number line_number
, apia.amount      line_amount
FROM
  ap_invoice_lines_all apia
, jai_ap_invoice_lines jail
WHERE apia.invoice_id  = jail.invoice_id (+)
  AND apia.line_number = jail.invoice_line_number(+)
  AND apia.invoice_id  = ln_std_invoice_id
  AND apia.line_type_lookup_code = GV_CONSTANT_ITEM
  AND jail.invoice_id IS NULL
  AND jail.invoice_line_number IS NULL;
--Added for bug#9237446 by JMEENA
  CURSOR cur_credit_memo_check( p_invoice_id number) IS
  Select invoice_amount, source
  from AP_INVOICES_ALL
  where invoice_id = p_invoice_id;

v_invoice_amount NUMBER;
v_invoice_source VARCHAR2(200);
--End bug#9237446
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_line_number  ' || pn_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_vendor_site_id   ' || pn_vendor_site_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_currency ' || pv_currency
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_line_amount ' || pn_line_amount
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_tax_category_id ' || pn_tax_category_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_tax_modified ' || pv_tax_modified
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_old_tax_category_id ' || pn_old_tax_category_id
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level)

--insert into eric_log values ( 0.1,'pn_invoice_id          :'||pn_invoice_id,sysdate);
--insert into eric_log values ( 0.2,'pn_line_number         :'||pn_line_number,sysdate);
--insert into eric_log values ( 0.3,'pn_vendor_site_id      :'||pn_vendor_site_id,sysdate);
--insert into eric_log values ( 0.4,'pv_currency            :'||pv_currency,sysdate);
--insert into eric_log values ( 0.5,'pn_line_amount         :'||pn_line_amount,sysdate);
--insert into eric_log values ( 0.6,'pn_tax_category_id     :'||pn_tax_category_id,sysdate);
--insert into eric_log values ( 0.7,'pv_tax_modified        :'||pv_tax_modified,sysdate);
--Added for bug#9237446 by JMEENA

OPEN cur_credit_memo_check (pn_invoice_id );
	FETCH cur_credit_memo_check INTO v_invoice_amount, v_invoice_source;
	CLOSE cur_credit_memo_check;
	IF ( ln_proc_level >= ln_dbg_level)
  	THEN
	 FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'v_invoice_amount ' || v_invoice_amount||'-v_invoice_source:'||v_invoice_source
                   );
	END IF;
	IF NVL(v_invoice_amount, 0) < 0 AND v_invoice_source = 'INDIA TDS' THEN
		IF ( ln_proc_level >= ln_dbg_level)
  			THEN
		 FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'Invoice is TDS Credit Memo so not defaulting Service tax'
                   );
		   END IF;
		RETURN;
	END IF;
--End bug#9237446

  -- if any of item line fails the mandatory distirbution lines validation
  -- no tax lines will be processed
  IF ((Validate_Item_Dist_Lines( ln_std_invoice_id))AND (NOT Validate_3rd_party_cm_Invoice(ln_std_invoice_id)) )
                       --       , ln_std_line_number)) --Added a parameter for validate function by Jia Li on 2008/01/25
                                                     -- according eakta's require.
                                                     --,commented out for the bug of deleting not working on Jan 28,2008
  THEN

--insert into eric_log values ( 1.1,'Item_Dist_Lines_Validated',sysdate);

    --only the tax_category_id in the cursor can be modified in the IL form
    --if the current function is invoked by IL form, line_number will be
    --specified. in the standard AP invoice form only line amount is changed
    --in the line level while vndr_site_id or currency_code are in header level
    --we need fetch one line rather than loop every item lines here

    OPEN jai_invoice_exist_cur;
    FETCH jai_invoice_exist_cur
    INTO
      ln_jai_vndr_site_id
    , lv_jai_currency_code
    , ln_jai_tax_category_id
    , ln_jai_line_amount;
    CLOSE jai_invoice_exist_cur;
--insert into eric_log values ( 1.2,'ln_jai_vndr_site_id    :'||ln_jai_vndr_site_id,sysdate);
--insert into eric_log values ( 1.3,'lv_jai_currency_code   :'||lv_jai_currency_code,sysdate);
--insert into eric_log values ( 1.4,'ln_jai_tax_category_id :'||ln_jai_tax_category_id,sysdate);
--insert into eric_log values ( 1.5,'ln_jai_line_amount     :'||ln_jai_line_amount,sysdate);
    OPEN  jai_tax_line_ctg_cur;
    FETCH jai_tax_line_ctg_cur
    INTO
      ln_jai_tax_line_ctg_id  ;
    CLOSE jai_tax_line_ctg_cur;
--insert into eric_log values ( 1.6,'ln_jai_tax_line_ctg_id :'||ln_jai_tax_line_ctg_id,sysdate);

    OPEN jai_get_supplier_id (pn_invoice_id);
    FETCH jai_get_supplier_id into ln_supplier_id;
    close jai_get_supplier_id;
--insert into eric_log values ( 1.7,'ln_supplier_id         :'||ln_supplier_id,sysdate);

    IF((ln_jai_tax_line_ctg_id IS NULL) AND (pn_old_tax_category_id IS NOT NULL))
    THEN
       ln_jai_tax_line_ctg_id := pn_old_tax_category_id ;
    END IF;

--insert into eric_log values ( 1.8,'ln_jai_tax_line_ctg_id :'||ln_jai_tax_line_ctg_id,sysdate);

   --added by eric ma on Mar 19 ,2008 for the bug 6898716 ,begin
   ---------------------------------------------------------------------------
   SELECT
     COUNT(*)
   INTO
     ln_tax_line_no
   FROM
     jai_cmn_document_taxes jcdt
   WHERE jcdt.source_doc_id              = pn_invoice_id
     AND jcdt.source_doc_parent_line_no  = pn_line_number
     AND jcdt.source_doc_type            = jai_constants.g_ap_standalone_invoice;


   IF ln_tax_line_no > 0
   THEN
     GV_LINES_CREATEED := 'YES';
   --added by eric for bug# 6923963 on Apr 23,2008,begin
   ------------------------------------------------------
   ELSE
     GV_LINES_CREATEED := 'NO';
   ----------------------------------------------------
   --added  by eric for bug# 6923963 on Apr 23,2008,end
   END IF;

--insert into eric_log values ( 1.9,'GV_LINES_CREATEED      :'||GV_LINES_CREATEED,sysdate) ;
   ---------------------------------------------------------------------------
   --added by eric ma on Mar 19 ,2008 for the bug 6898716 ,end

   --  standalone invoice insert is going to happen in the following cases

    -- 1.  create a new invoice from ap invoice workbench
    -- 2.  attach a tax category to an existing  invoice line whose tax ctg is null
    -- 3.  user again attaches a tax category to an invoice which was previouly removed

    IF ((ln_jai_vndr_site_id IS NULL and GV_LINES_CREATEED = 'NO')
    --added "and GV_LINES_CREATEED = 'NO'" in the below two lines
    --modified by eric ma on Mar 19 ,2008 for the bug 6898716 ,begin
    -------------------------------------------------------------
       OR (ln_jai_tax_category_id IS NULL AND ln_std_tax_category_id IS NOT NULL and GV_LINES_CREATEED = 'NO' )
       OR (ln_jai_tax_line_ctg_id IS NULL AND ln_std_tax_category_id IS NOT NULL and GV_LINES_CREATEED = 'NO' )
       )
    -------------------------------------------------------------
    --modified by eric ma on Mar 19 ,2008 for the bug 6898716 ,end
    THEN
      IF ( ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING ( ln_proc_level
                       , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                       , 'Case 1'
                       );
      END IF;-- ( ln_proc_level >= ln_dbg_level)
--insert into eric_log values ( 2.1,'Case 1',sysdate);

      if  ln_std_tax_category_id is null then

      ln_std_tax_category_id := JAI_AP_IL_ORG_PKG.fun_tax_cat_id (ln_supplier_id ,
                          ln_std_vendor_site_id ,
			  ln_std_invoice_id ,
                          ln_std_line_number );
      end if ;
--insert into eric_log values ( 2.11,'ln_std_tax_category_id :'||ln_std_tax_category_id,sysdate);
--insert into eric_log values ( 2.12,'lv_std_tax_modified    :'||lv_std_tax_modified,sysdate);
--insert into eric_log values ( 2.13,'ln_std_line_number     :'||ln_std_line_number,sysdate);
      --insert
      Create_Tax_Lines ( pn_organization_id    => NULL
                       , pv_currency           => lv_std_currency_code
                       , pn_location_id        => NULL
                       , pn_invoice_id         => ln_std_invoice_id
                       , pn_line_number        => ln_std_line_number
                       , pn_tax_category_id    => ln_std_tax_category_id
                       , pv_tax_modified       => lv_std_tax_modified
                       );
--insert into eric_log values ( 2.14,'Create_Tax_Lines() done',sysdate);

       GV_LINES_CREATEED := 'YES';
--insert into eric_log values ( 2.15,'GV_LINES_CREATEED    :'||GV_LINES_CREATEED,sysdate);
    END IF;

    -- vendor site is changed in AP , currency is updated in AP ,
    -- delete the taxes ,update related information in jai_ap_invoice_lines
    -- and recalculate tax lines

    IF ( ( ln_jai_vndr_site_id <> ln_std_vendor_site_id)
          OR ( lv_jai_currency_code <> lv_std_currency_code)
       )
    THEN
      IF ( ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING ( ln_proc_level
                       , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                       , 'Case 2'
                       );
      END IF;-- ( ln_proc_level >= ln_dbg_level)

--insert into eric_log values ( 2.2,'Case 2',sysdate);

       open get_setup_tax_category_id ( ln_supplier_id , ln_std_vendor_site_id );
       fetch get_setup_tax_category_id into ln_std_tax_category_id;
       close get_setup_tax_category_id;



      Delete_Tax_Lines ( pn_invoice_id     => ln_std_invoice_id
                       , pn_line_number    => ln_std_line_number
                       );


      Get_Invoice_Header_Infor ( pn_invoice_id     => ln_std_invoice_id
                               , xn_vendor_id      => ln_vendor_id
                               , xn_vendor_site_id => ln_vendor_site_id
                               , xv_currency_code  => lv_currency_code
                               , xn_exchange_rate  => ln_exchange_rate
                               , xn_batch_id       => ln_batch_id
                               );

      Get_Tax_Cat_Serv_Type   ( pn_vendor_id            => ln_vendor_id
                              , pn_vendor_site_id       => ln_vendor_site_id
                              , xn_tax_category_id      => ln_std_tax_category_id    ---ln_tax_category_id
                              , xv_service_type_code    => lv_service_type_code
                              );

      Update_Jai_Item_Info
      ( pn_invoice_id      => ln_std_invoice_id
      , pn_vndr_site_id    => ln_std_vendor_site_id
      , pn_currency_code   => lv_std_currency_code
      , pn_tax_category_id => ln_std_tax_category_id  ---ln_tax_category_id
      );


      	 /*  ln_std_tax_category_id := JAI_AP_IL_ORG_PKG.fun_tax_cat_id (ln_supplier_id ,
				ln_std_vendor_site_id ,
				 ln_std_invoice_id ,
				ln_std_line_number ); */



      --insert
      Create_Tax_Lines ( pn_organization_id    => NULL
                       , pv_currency           => lv_std_currency_code
                       , pn_location_id        => NULL
                       , pn_invoice_id         => ln_std_invoice_id
                       , pn_line_number        => ln_std_line_number
                       , pn_tax_category_id    => ln_std_tax_category_id
                       , pv_tax_modified       => lv_std_tax_modified
                       );

       GV_LINES_CREATEED := 'YES';
    END IF;--(vndr_site_id changed or currency_code changed)

    --as the data may be changed by case 1 , re-selete table for getting the latest values.
    --added by eric for bug# 6923963 on Apr 23,2008,begin
    ------------------------------------------------------
    OPEN jai_invoice_exist_cur;
    FETCH jai_invoice_exist_cur
    INTO
      ln_jai_vndr_site_id
    , lv_jai_currency_code
    , ln_jai_tax_category_id
    , ln_jai_line_amount;
    CLOSE jai_invoice_exist_cur;
 --insert into eric_log values ( 10.2,'ln_jai_vndr_site_id    :'||ln_jai_vndr_site_id,sysdate);
 --insert into eric_log values ( 10.3,'lv_jai_currency_code   :'||lv_jai_currency_code,sysdate);
 --insert into eric_log values ( 10.4,'ln_jai_tax_category_id :'||ln_jai_tax_category_id,sysdate);
 --insert into eric_log values ( 10.5,'ln_jai_line_amount     :'||ln_jai_line_amount,sysdate);
    OPEN  jai_tax_line_ctg_cur;
    FETCH jai_tax_line_ctg_cur
    INTO
      ln_jai_tax_line_ctg_id  ;
    CLOSE jai_tax_line_ctg_cur;
 --insert into eric_log values ( 10.6,'ln_jai_tax_line_ctg_id :'||ln_jai_tax_line_ctg_id,sysdate);

    ------------------------------------------------------
    --added by eric for bug# 6923963 on Apr 23,2008,end



    -- tax category changed from IL form
    -- tax lines exists but the ctg_id in tax lines are different
    -- OR the original tax category is null and tax lines exist
    -- from the tax ctgs of item line
    IF ( ( ln_jai_tax_line_ctg_id     IS NOT NULL
           AND ln_std_tax_category_id IS NOT NULL
           AND ln_std_tax_category_id <> ln_jai_tax_line_ctg_id
         )
         --added the below creteria for bug 6898716
         --added by eric ma on Mar 19 ,2008 for the bug 6898716 ,begin
         -------------------------------------------------------------
         OR
         ( GV_LINES_CREATEED = 'YES'
           AND ln_jai_tax_line_ctg_id IS NULL
           AND ln_std_tax_category_id IS NOT NULL
         )
         -------------------------------------------------------------
         --added by eric ma on Mar 19 ,2008 for the bug 6898716 ,end
       )
    THEN

      IF ( ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING ( ln_proc_level
                       , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                       , 'Case 3'
                       );
      END IF; -- ( ln_proc_level >= ln_dbg_level)
--insert into eric_log values ( 2.3,'Case 3',sysdate);

      Delete_Tax_Lines ( pn_invoice_id     => ln_std_invoice_id
                       , pn_line_number    => ln_std_line_number
                       );

      --insert
      Create_Tax_Lines ( pn_organization_id    => NULL
                       , pv_currency           => lv_std_currency_code
                       , pn_location_id        => NULL
                       , pn_invoice_id         => ln_std_invoice_id
                       , pn_line_number        => ln_std_line_number
                       , pn_tax_category_id    => ln_std_tax_category_id
                       , pv_tax_modified       => lv_std_tax_modified
                       );

      --if the category changed, ignore the changes of tax lines level
      lv_std_tax_modified :='N';
    END IF;

    -- the tax category is updated to null in IL form delete the taxes
    -- from all the tables


   /* IF ( ln_std_tax_category_id  IS NULL
         AND ln_jai_tax_line_ctg_id IS NOT NULL
         AND GV_LINES_CREATEED = 'NO')    THEN    */--



    if  ln_std_tax_category_id  IS NULL   and  ln_jai_tax_line_ctg_id IS NOT NULL    then

          /*  vendor updated and GV_LINES_CREATEED is yes , nothing has to be deleted
	      l_chk_del_flag = 'Y' is to stop deletion of tax lines due to second call of Post form
	      commit trigger in APXINWKB */

	 IF pn_old_tax_category_id  is null
	 THEN
		 l_chk_del_flag := 'Y'  ;

	 END IF;

      	 if  nvl(l_chk_del_flag, '$' ) = 'Y'  then

		 null;
         -- invoice is queried and tax-category_id is updated to null
         elsif GV_LINES_CREATEED = 'NO' then
              Delete_Tax_Lines ( pn_invoice_id     => ln_std_invoice_id
                       , pn_line_number    => ln_std_line_number
                       );

         --  new invoice is created and then  tax category is set to null without closing the form
         elsif  GV_LINES_CREATEED = 'YES' then
              Delete_Tax_Lines ( pn_invoice_id     => ln_std_invoice_id
                       , pn_line_number    => ln_std_line_number
                       );
         end if;

    END IF;

    -- the tax category remains unchanged but the user enters new taxes
    -- DO NOT DELETE lines from jai_cmn_document_taxes
    -- delte from other tables and then default
    IF ( NVL ( ln_std_tax_category_id, -999) =
         NVL ( ln_jai_tax_line_ctg_id, -999)
         AND NVL (lv_std_tax_modified, 'N') = 'Y'
       )
    THEN
--insert into eric_log values ( 2.5,'Case 5',sysdate);

      IF ( ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING ( ln_proc_level
                       , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                       , 'Case 5'
                       );
      END IF; -- ( ln_proc_level >= ln_dbg_level)

      --insert
      Create_Tax_Lines ( pn_organization_id    => NULL
                       , pv_currency           => lv_std_currency_code
                       , pn_location_id        => NULL
                       , pn_invoice_id         => ln_std_invoice_id
                       , pn_line_number        => ln_std_line_number
                       , pn_tax_category_id    => ln_std_tax_category_id
                       , pv_tax_modified       => lv_std_tax_modified
                       );
    END IF; --( (lv_std_tax_modified, 'N') = 'Y',Modified Tax line in IL form)

    -- 1. When the line amount is changed in the standard form
    --    program going to this branch
    -- 2. A new item line inserted from standard AP form

    -- For the first case, program need to update the item line amount in
    -- jai_ap_invoice_lines
      --get invoice header information


    FOR diff_inv_lines_rec IN diff_inv_lines_cur
    LOOP

      IF ( ln_proc_level >= ln_dbg_level)
      THEN
        FND_LOG.STRING ( ln_proc_level
                       , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                       , 'Case 6'
                       );
      END IF;-- ( ln_proc_level >= ln_dbg_level)
--insert into eric_log values ( 2.6,'Case 6',sysdate);
      Get_Invoice_Header_Infor ( ln_std_invoice_id
                               , ln_vendor_id
                               , ln_vendor_site_id
                               , lv_currency_code
                               , ln_exchange_rate
                               , ln_batch_id
                               );
--insert into eric_log values ( 2.61,'ln_vendor_id          :'|| ln_vendor_id,sysdate);
--insert into eric_log values ( 2.62,'ln_vendor_site_id     :'|| ln_vendor_site_id,sysdate);

     Get_Tax_Cat_Serv_Type   ( pn_vendor_id            => ln_vendor_id
                              , pn_vendor_site_id       => ln_vendor_site_id
                              , xn_tax_category_id      => ln_tax_category_id
                              , xv_service_type_code    => lv_service_type_code
                              );
--insert into eric_log values ( 2.63,'ln_tax_category_id    :'|| ln_tax_category_id,sysdate);
--insert into eric_log values ( 2.64,'lv_service_type_code  :'|| lv_service_type_code,sysdate);

      Delete_Tax_Lines
      ( pn_invoice_id     => ln_std_invoice_id
      , pn_line_number    => diff_inv_lines_rec.line_number
      );
--insert into eric_log values ( 2.65,'ln_std_invoice_id     :'|| ln_std_invoice_id,sysdate);
--insert into eric_log values ( 2.66,'line_number           :'||diff_inv_lines_rec.line_number,sysdate);


      Update_Jai_Line_Amount
      ( pn_invoice_id     => ln_std_invoice_id
      , pn_line_number    => diff_inv_lines_rec.line_number
      , pn_line_amount    => diff_inv_lines_rec.line_amount
      );
--insert into eric_log values ( 2.67,'line_amount          :'|| diff_inv_lines_rec.line_amount,sysdate);

      --insert
      Create_Tax_Lines( pn_organization_id => NULL
                      , pv_currency        => lv_std_currency_code
                      , pn_location_id     => NULL
                      , pn_invoice_id      => ln_std_invoice_id
                      , pn_line_number     => diff_inv_lines_rec.line_number
                      , pn_tax_category_id => ln_tax_category_id
                      , pv_tax_modified    => lv_std_tax_modified
                      );
    END LOOP; --(diff_inv_lines_rec IN diff_inv_lines_cur)

    --delete item lines from Standard Invoice Work Bench
    --then delete its related taxes invoice lines and tax dist lines
    Delete_Useless_Lines ( pn_invoice_id    => ln_std_invoice_id );

    --allocate tax amount in distribution lines according to the propotion
    --of item distirbution lines
    Allocate_Tax_Dist_Lines
    ( pn_invoice_id               => ln_std_invoice_id
    , pn_invoice_item_line_number => ln_std_line_number
    );
    COMMIT;

  ELSE -- (Validate_Item_Dist_Lines not passed or Validate_3rd_party_cm_Invoice(ln_std_invoice_id) passed)

--insert into eric_log values ( 1.20,'Error : Item_Dist_Lines_not_Validated or 3rd_party_cm_Invoice_validated',sysdate);
    NULL ;
  END IF; -- (Validate_Item_Dist_Lines(ln_std_invoice_id))


/* Error msg will be populated AP Invoice workbench when changing the data in header
  UPDATE
    AP_INVOICES_ALL
   SET
     invoice_amount = (SELECT SUM(amount) FROM AP_INVOICE_LINES_ALL WHERE invoice_id =pn_invoice_id ),
     base_amount    = (SELECT SUM(base_amount) FROM AP_INVOICE_LINES_ALL WHERE invoice_id =pn_invoice_id )
   WHERE invoice_id =pn_invoice_id;
*/

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;

    ROLLBACK;
END Populate_Stnd_Inv_Taxes;

--==========================================================================
--  PROCEDURE NAME:
--
--    Default_Calculate_Taxes               Public
--
--  DESCRIPTION:
--
--   This procedure is to invoke standard procedure to insert item information
--   into jai_cmn_document_taxes
--
--  PARAMETERS:
--      In:  pn_invoice_id        IN     NUMBER     invoice id
--           pn_line_number       IN     NUMBER     item line number
--           xn_tax_amount        IN OUT NUMBER     tax ou
--           pv_currency_code     IN     VARCHAR2   currency code
--           pn_tax_category_id   IN     NUMBER     tax category
--           pv_tax_modified      IN     VARCHAR2   tax modified flag
--           pn_supplier_site_id  in     NUMBER     supplier site id
--           pn_supplier_id       in     NUMBER     suppolier id
--
--
--     Out:
--
--
--  DESIGN REFERENCES:
--     AP Technical Design 2.1.doc
--
--  CHANGE HISTORY:
--
--  1    23-Aug-2007     Eric Ma Created
--
--===========================================================================

PROCEDURE Default_Calculate_Taxes
( pn_invoice_id       IN            NUMBER
, pn_line_number      IN            NUMBER
, xn_tax_amount       IN OUT NOCOPY NUMBER
, pn_vendor_id        IN            NUMBER
, pn_vendor_site_id   IN            NUMBER
, pv_currency_code    IN            VARCHAR2
, pn_tax_category_id  IN            NUMBER
, pv_tax_modified     IN            VARCHAR2
)
IS
  ln_invoice_id         NUMBER         := pn_invoice_id;
  ln_line_number        NUMBER         := pn_line_number;
  lv_currency_code      VARCHAR2 (15)  := pv_currency_code;
  ln_tax_category_id    NUMBER         := pn_tax_category_id;
  ln_vendor_id          NUMBER         := pn_vendor_id;
  ln_dbg_level          NUMBER         := FND_LOG.g_current_runtime_level;
  ln_proc_level         NUMBER         := FND_LOG.level_procedure;
  lv_proc_name          VARCHAR2 (100) := 'Default_Calculate_Taxes';
  ln_user_id            NUMBER         := fnd_global.user_id;
  ln_login_id           NUMBER         := fnd_global.login_id;
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_line_number ' || pn_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_currency_code ' || pv_currency_code
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_tax_category_id ' || pn_tax_category_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_tax_modified ' || pv_tax_modified
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_vendor_id ' || pn_vendor_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_vendor_site_id ' || pn_vendor_site_id
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  jai_cmn_tax_defaultation_pkg.ja_in_calc_prec_taxes
  ( transaction_name        => jai_constants.g_ap_standalone_invoice
  , p_tax_category_id       => ln_tax_category_id
  , p_header_id             => ln_invoice_id
  , p_line_id               => ln_line_number
  --, p_assessable_value      => 0 modified by eric on Jan 25th,2008
  , p_assessable_value      => xn_tax_amount --modified by eric ,replace 0 with line amount
  , p_tax_amount            => xn_tax_amount
  , p_inventory_item_id     => NULL
  , p_line_quantity         => 1
  , p_uom_code              => NULL
  , p_vendor_id             => ln_vendor_id
  , p_currency              => lv_currency_code
  , p_currency_conv_factor  => NULL
  , p_creation_date         => SYSDATE
  , p_created_by            => ln_user_id
  , p_last_update_date      => SYSDATE
  , p_last_updated_by       => ln_user_id
  , p_last_update_login     => ln_login_id
  , p_operation_flag        => NULL
  --, p_vat_assessable_value  => 0
  , p_vat_assessable_value  => xn_tax_amount --modified by eric ,replace 0 with line amount
  , p_source_trx_type       => jai_constants.G_AP_STANDALONE_INVOICE
  , p_source_table_name     => GV_JAI_AP_INVOICE_LINES  --'JAI_AP_INVOICE_LINES'
  , p_action                => jai_constants.default_taxes
  );

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )
EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX || '.' || lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Default_Calculate_Taxes;

--==========================================================================
--  FUNCTION NAME:
--
--    Check_Inclusive_Tax               Private
--
--  DESCRIPTION:
--
--      This procedure is to check wether the input tax is inclusive tax or
--      exclusive tax. If return is false,then the tax is exclusive tax.
--      Otherwise ,it's a inclusive tax
--
--  PARAMETERS:
--    In: pn_tax_id          NUMBER      tax id
--
--
--    Out:
--        return             Boolean     TURE /FALSE
--
--  DESIGN REFERENCES:
--     AP Inclusive TD
--
--  CHANGE HISTORY:
--
--  1    12-Dec-2007    Eric Ma Created
--===========================================================================
FUNCTION Check_Inclusive_Tax (pn_tax_id NUMBER)
RETURN BOOLEAN
IS
	CURSOR get_inclusive_tax_flag IS
	SELECT NVL(inclusive_tax_flag,'N')
	FROM
	  jai_cmn_taxes_all
	WHERE
	  tax_id = pn_tax_id;

	lv_inclusive_tax_flag VARCHAR2(1);
  ln_dbg_level          NUMBER         := FND_LOG.g_current_runtime_level;
  ln_proc_level         NUMBER         := FND_LOG.level_procedure;
  lv_proc_name          VARCHAR2 (100) := 'Check_Inclusive_Tax';
BEGIN
	OPEN  get_inclusive_tax_flag;
	FETCH get_inclusive_tax_flag
	INTO
	  lv_inclusive_tax_flag;
  CLOSE   get_inclusive_tax_flag;

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_tax_id ' || pn_tax_id
                   );
  END IF;
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit FUNCTION'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  IF (lv_inclusive_tax_flag='Y')
  THEN
    RETURN TRUE;
  ELSE
  	RETURN FALSE;
  END IF;	--(lv_inclusive_tax_flag='N')

EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX || '.' || lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Check_Inclusive_Tax;

--==========================================================================
--  PROCEDURE NAME:
--
--    Get_Pr_Processed_Flag               Private
--
--  DESCRIPTION:
--
--    If we splited pr tax  into two 2 portions, then the recoverable
--  portion shold not be splited again.  The splited PR tax has the
--  following features: tax_id and tax_line_no are same.
--
--  PARAMETERS:
--    In: pn_source_doc_id          NUMBER      Invoice id
--        pn_source_parent_line_no  NUMBER      Invoice item line no
--
--    Out:
--
--  DESIGN REFERENCES:
--     AP Technical Design 2.1.doc
--
-- CHANGE HISTORY:
--  1    29-Jan-2008     Eric Ma created for bug#6784111
--===========================================================================
FUNCTION Get_Pr_Processed_Flag
( pn_source_doc_id         IN NUMBER
, pn_source_parent_line_no IN NUMBER
, pn_tax_id                IN NUMBER
)
RETURN VARCHAR2
IS
  ln_count NUMBER;
  lv_pr_processed_flag VARCHAR2 (1) DEFAULT NULL;

  ln_dbg_level          NUMBER         := FND_LOG.g_current_runtime_level;
  ln_proc_level         NUMBER         := FND_LOG.level_procedure;
  lv_proc_name          VARCHAR2 (100) := 'Get_Pr_Processed_Flag';
BEGIN
  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_source_doc_id ' || pn_source_doc_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_source_parent_line_no ' || pn_source_parent_line_no
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_tax_id ' || pn_tax_id
                   );
  END IF;--( ln_proc_level >= ln_dbg_level)
  --log for debug

  SELECT
    COUNT(tax_id)
  INTO
    ln_count
  FROM
    jai_cmn_document_taxes
  WHERE source_doc_id             = pn_source_doc_id
    AND source_DOC_parent_line_no = pn_source_parent_line_no
    AND tax_id                    = pn_tax_id
    AND source_doc_type           = jai_constants.g_ap_standalone_invoice;

  IF (ln_count >1)
  THEN
    lv_pr_processed_flag := jai_constants.yes ;
  ELSE
    lv_pr_processed_flag := jai_constants.no	;
  END IF;

  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'lv_pr_processed_flag ' || lv_pr_processed_flag
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit FUNCTION'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  RETURN lv_pr_processed_flag;
EXCEPTION
WHEN OTHERS THEN
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX || '.' || lv_proc_name
                     || '. Other_Exception '
                   , SQLCODE || ':' || SQLERRM
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level)  ;
END Get_Pr_Processed_Flag;
--==========================================================================
--  PROCEDURE NAME:
--
--    Create_Tax_Lines               Public
--
--  DESCRIPTION:
--
--      This procedure is to create tax invoice line and distribution line in
--      both standard tables of ap module and jai ap modules
--
--      This procedures will fetch all the related information which we need to
--      populate the base tables and IlL tables. Maintly to get the project
--      realted information for the Project invoices, asset related info for
--      theasset realted invoices and the various cahrge accounts for the
--      distributions
--
--  PARAMETERS:
--    In: pn_organization_id NUMBER      organization id
--        pv_currency        VARCHAR2    currency
--        pn_location_id     NUMBER      location id
--        pn_invoice_id      NUMBER      invoice id
--        pn_line_number     NUMBER      item line number
--        p_action           VARCHAR2    normally it is DEFAULT_TAXES, it can
--                                       be jai_constants.recalculate_taxes
--        pn_tax_category_id NUMBER      tax category id
--
--
--    Out:
--
--
--  DESIGN REFERENCES:
--     AP Technical Design 2.1.doc
--
--  CHANGE HISTORY:
--
--  1    23-Aug-2007     Eric Ma Created
--  2    30-Nov-2007     Eric Ma modified for inclusive tax
--  3    18-Feb-2008     Eric Ma modified for bug#6824857
--  4    21-Nov-2008     Walton modified for bug#7202316
--  5   10-Nov-2009     Bgowrava for Bug#8975118
--                      Added a new variable lv_dist_class with value as 'PERMANENT' and used it for the value of distribution_class column while
--                      inserting into ap_invoice_distributions_all table.
--  6. 26-Nov-2009	JMEENA for bug#9098529
--			Added cursor get_service_type and fetched service_type_code to
--			populate in the table jai_ap_invoice_lines.
--  7.	17-Nov-2009	JMEENA for bug#9206909
--			Modified cursor get_service_type and fetched organization and location id.
--			Passed same values to function Get_Dist_Account_Ccid to fetch the accounts for organization.
--
--  8.	22-Jun-2010	 Modified by Jia for bug#9666819
--			       Issue: If the tax distribution line was generated before item distribution line,
--                    the NULL will be insert into column reversal_flag.
--               Fix: Modified EXECUTE IMMEDIATE lv_insert_ap_inv_dist_ln_sql,
--                   USING NVL(ap_invoice_dist_rec.reversal_flag,'N')
--===========================================================================

PROCEDURE Create_Tax_Lines
( pn_organization_id  IN  NUMBER
, pv_currency         IN  VARCHAR2
, pn_location_id      IN  NUMBER
, pn_invoice_id       IN  NUMBER
, pn_line_number      IN  NUMBER   DEFAULT NULL
, pv_action           IN  VARCHAR2 DEFAULT jai_constants.default_taxes
, pn_tax_category_id  IN  NUMBER
, pv_tax_modified     IN  VARCHAR2
)
IS
  ln_invoice_id                 NUMBER       := pn_invoice_id;
  ln_line_number                NUMBER       := pn_line_number;
  ln_tax_category_id            NUMBER       := pn_tax_category_id;
  lv_tax_modified               VARCHAR2 (1) := pv_tax_modified;

  CURSOR ap_invoice_lines_cur IS
  SELECT
    invoice_id
  , line_number
  , line_type_lookup_code
  , description
  , org_id
  , assets_tracking_flag
  , match_type
  , accounting_date
  , period_name
  , deferred_acctg_flag
  , def_acctg_start_date
  , def_acctg_end_date
  , def_acctg_number_of_periods
  , def_acctg_period_type
  , set_of_books_id
  , amount
  , wfapproval_status
  , creation_date
  , created_by
  , last_updated_by
  , last_update_date
  , last_update_login
  , project_id
  , task_id
  , expenditure_type
  , expenditure_item_date
  , expenditure_organization_id
  FROM
    ap_invoice_lines_all
  WHERE invoice_id = ln_invoice_id
    AND line_type_lookup_code = GV_CONSTANT_ITEM
    AND match_type  = GV_NOT_MATCH_TYPE
    AND line_number = NVL (ln_line_number, line_number);

  CURSOR jai_doc_taxes_cur
  ( pn_invoice_id          NUMBER
  , pn_parent_line_number  NUMBER
  )
  IS
  SELECT
    jcdt.doc_tax_id
  , jcdt.tax_line_no
  , jcdt.tax_id
  , jcdt.tax_type
  , jcdt.currency_code
  , jcdt.tax_rate
  , jcdt.qty_rate
  , jcdt.uom
  , jcdt.tax_amt
  , jcdt.func_tax_amt
  , jcdt.modvat_flag
  , jcdt.tax_category_id
  , jcdt.source_doc_type
  , jcdt.source_doc_id
  , jcdt.source_doc_line_id
  , jcdt.source_table_name
  , jcdt.tax_modified_by
  , jcdt.adhoc_flag
  , jcdt.precedence_1
  , jcdt.precedence_2
  , jcdt.precedence_3
  , jcdt.precedence_4
  , jcdt.precedence_5
  , jcdt.precedence_6
  , jcdt.precedence_7
  , jcdt.precedence_8
  , jcdt.precedence_9
  , jcdt.precedence_10
  , jcdt.creation_date
  , jcdt.created_by
  , jcdt.last_update_date
  , jcdt.last_updated_by
  , jcdt.last_update_login
  , jcdt.object_version_number
  , jcdt.vendor_id
  , jcdt.source_doc_parent_line_no
  , jcta.inclusive_tax_flag inc_tax_flag --Added by Eric for Inclusive Tax
  FROM
    jai_cmn_document_taxes jcdt
  , jai_cmn_taxes_all      jcta --Added by Eric for Inclusive Tax
  WHERE jcdt.source_doc_id             = pn_invoice_id
    AND jcdt.source_doc_parent_line_no = pn_parent_line_number
    AND jcdt.tax_id      = jcta.tax_id  --Added by Eric for Inclusive Tax
    AND jcdt.source_doc_type = jai_constants.g_ap_standalone_invoice
  ORDER BY jcdt.doc_tax_id;

  CURSOR jai_default_doc_taxes_cur
  ( pn_invoice_id   NUMBER
  , pn_line_number  NUMBER
  )
  IS
  SELECT
    jcdt.doc_tax_id
  , jcdt.tax_line_no
  , jcdt.tax_id
  , jcdt.tax_type
  , jcdt.currency_code
  , jcdt.tax_rate
  , jcdt.qty_rate
  , jcdt.uom
  , jcdt.tax_amt
  , jcdt.func_tax_amt
  , jcdt.modvat_flag
  , jcdt.tax_category_id
  , jcdt.source_doc_type
  , jcdt.source_doc_id
  , jcdt.source_doc_line_id
  , jcdt.source_table_name
  , jcdt.tax_modified_by
  , jcdt.adhoc_flag
  , jcdt.precedence_1
  , jcdt.precedence_2
  , jcdt.precedence_3
  , jcdt.precedence_4
  , jcdt.precedence_5
  , jcdt.precedence_6
  , jcdt.precedence_7
  , jcdt.precedence_8
  , jcdt.precedence_9
  , jcdt.precedence_10
  , jcdt.creation_date
  , jcdt.created_by
  , jcdt.last_update_date
  , jcdt.last_updated_by
  , jcdt.last_update_login
  , jcdt.object_version_number
  , jcdt.vendor_id
  , jcdt.source_doc_parent_line_no
  FROM
    jai_cmn_document_taxes jcdt
  WHERE jcdt.source_doc_id             = pn_invoice_id
    AND jcdt.source_doc_line_id        = pn_line_number
    AND jcdt.source_doc_parent_line_no = pn_line_number
    AND jcdt.source_doc_type = jai_constants.g_ap_standalone_invoice
  ORDER BY jcdt.tax_line_no FOR UPDATE;

  CURSOR get_tax_cur (pn_tax_id  NUMBER) IS
  SELECT
    tax_name
  , tax_account_id
  , mod_cr_percentage
  , adhoc_flag
  , NVL (tax_rate, -1) tax_rate
  , tax_type
  , NVL(rounding_factor,0) rounding_factor
  FROM
    jai_cmn_taxes_all
  WHERE tax_id = pn_tax_id;

  CURSOR ap_invoice_dist_cur (pn_line_number  NUMBER) IS
  SELECT
    accounting_date
  , accrual_posted_flag
  , assets_addition_flag
  , assets_tracking_flag
  , cash_posted_flag
  , distribution_line_number
  , dist_code_combination_id
  , invoice_id
  , last_updated_by
  , last_update_date
  , line_type_lookup_code
  , period_name
  , set_of_books_id
  , amount
  , base_amount
  , batch_id
  , created_by
  , creation_date
  , description
  , exchange_rate
  , exchange_rate_variance
  , last_update_login
  , match_status_flag
  , posted_flag
  , rate_var_code_combination_id
  , reversal_flag
  , program_application_id
  , program_id
  , program_update_date
  , accts_pay_code_combination_id
  , invoice_distribution_id
  , quantity_invoiced
  , po_distribution_id
  , rcv_transaction_id
  , price_var_code_combination_id
  , invoice_price_variance
  , base_invoice_price_variance
  , matched_uom_lookup_code
  , invoice_line_number
  , org_id
  , charge_applicable_to_dist_id
  , project_id
  , task_id
  , expenditure_type
  , expenditure_item_date
  , expenditure_organization_id
  , project_accounting_context
  , pa_addition_flag
  , distribution_class
  , ASSET_BOOK_TYPE_CODE
  , ASSET_CATEGORY_ID
  FROM
    ap_invoice_distributions_all
  WHERE invoice_id               = ln_invoice_id
    AND invoice_line_number      = pn_line_number
    AND distribution_line_number = 1;

  CURSOR new_invoice_lines_cur (pn_inovoice_line_num  IN  NUMBER) IS
  SELECT
    invoice_id
  , line_number
  , line_type_lookup_code
  , description
  , org_id
  , assets_tracking_flag
  , match_type
  , accounting_date
  , period_name
  , deferred_acctg_flag
  , def_acctg_start_date
  , def_acctg_end_date
  , def_acctg_number_of_periods
  , def_acctg_period_type
  , set_of_books_id
  , amount
  , wfapproval_status
  , creation_date
  , created_by
  , last_updated_by
  , last_update_date
  , last_update_login
  , project_id
  , task_id
  , expenditure_type
  , expenditure_item_date
  , expenditure_organization_id
  FROM
    ap_invoice_lines_all a
  WHERE invoice_id = ln_invoice_id
    AND line_number = pn_inovoice_line_num
    AND NOT EXISTS
        (
         SELECT
           'X'
         FROM
           jai_ap_invoice_lines b
         WHERE a.invoice_id = b.invoice_id
           AND a.line_number = b.invoice_line_number
        );
--Added below cursor for bug#9098529 by JMEENA
Cursor get_service_type(p_invoice_id NUMBER,p_invoice_line_number NUMBER)  IS
SELECT service_type_code,organization_id, location_id -- Added organization_id,location_id from bug#9206909
FROM jai_ap_invoice_lines
WHERE invoice_id = p_invoice_id
AND invoice_line_number = p_invoice_line_number;

lv_organization_id jai_ap_invoice_lines.ORGANIZATION_ID%type;
lv_location_id jai_ap_invoice_lines.LOCATION_ID%type;

  ap_invoice_dist_rec       ap_invoice_dist_cur%ROWTYPE;
  tax_rec                   get_tax_cur%ROWTYPE;
  lv_account_type  gl_code_combinations.account_type%TYPE;
  ln_inv_dist_id            NUMBER;
  ln_dist_acct_ccid         NUMBER;
  ln_tax_amount             NUMBER;
  ln_vendor_id              NUMBER;
  ln_vendor_site_id         NUMBER;
  lv_currency_code          VARCHAR2 (15);
  ln_exchange_rate          NUMBER;
  lv_service_type_code      VARCHAR2 (30);
  lv_service_type_code_tmp  VARCHAR2 (30); --added by walton for bug#7202316
  ln_batch_id               NUMBER;
  ln_max_inv_line_num       NUMBER;
  ln_source_doc_line_id     NUMBER; --added by eric for inclusive tax
  ln_max_tax_line_num       NUMBER;
  ln_max_pro_line_num       NUMBER; --Added by Jia Li for inclusive tax on 2008/01/23
  ln_recur_tax_amt          NUMBER;
  ln_nrecur_tax_amt         NUMBER;
  ln_func_tax_amount        NUMBER;
  ln_recur_func_tax_amt     NUMBER;
  ln_nrecur_func_tax_amt    NUMBER;
  lv_tax_type               VARCHAR2(10);
  ln_doc_tax_id             NUMBER;
  ln_chargeble_acct_ccid    NUMBER;
  lv_tax_recoverable_flag   VARCHAR2(1);
  lv_insert_jai_inv_sql        VARCHAR2(32000);
  lv_insert_jai_tax_sql        VARCHAR2(32000);
  lv_insert_ap_inv_ln_sql      VARCHAR2(32000);
  lv_insert_ap_inv_dist_ln_sql VARCHAR2(32000);
  lv_pr_processed_flag         VARCHAR2(1); --added by eric on jan 29,2008
  ln_max_source_line_id        NUMBER;      --added by eric on jan 29,2008
  ln_asset_track_flag ap_invoice_lines_all.assets_tracking_flag%TYPE;
  ln_project_id       ap_invoice_lines_all.project_id%TYPE;
  ln_task_id          ap_invoice_lines_all.task_id%TYPE;
  lv_expenditure_type ap_invoice_lines_all.expenditure_type%TYPE;
  ld_exp_item_date    ap_invoice_lines_all.expenditure_item_date%TYPE;
  ln_exp_org_id       ap_invoice_lines_all.expenditure_organization_id%TYPE;
  ld_sys_date         DATE; --Eric added on 18-Feb-2008,for bug#6824857

  ln_dist_asst_add_flag
    ap_invoice_distributions_all.assets_addition_flag%TYPE;
  ln_dist_asst_trck_flag
    ap_invoice_distributions_all.assets_tracking_flag%TYPE;
  ln_dist_project_id
    ap_invoice_distributions_all.project_id%TYPE;
  ln_dist_task_id
    ap_invoice_distributions_all.task_id%TYPE;
  ln_dist_exp_type
    ap_invoice_distributions_all.expenditure_type%TYPE;
  ld_dist_exp_item_date
    ap_invoice_distributions_all.expenditure_item_date%TYPE;
  ln_dist_exp_org_id
    ap_invoice_distributions_all.expenditure_organization_id%TYPE;
  ln_dist_pa_context
    ap_invoice_distributions_all.project_accounting_context%TYPE;
  ln_dist_pa_addition_flag
    ap_invoice_distributions_all.pa_addition_flag%TYPE;
  lv_asset_book_type_code
    ap_invoice_distributions_all.asset_book_type_code%TYPE;
  ln_asset_category_id
    ap_invoice_distributions_all.asset_category_id%TYPE;
  ln_dbg_level         NUMBER        := FND_LOG.g_current_runtime_level;
  ln_proc_level        NUMBER        := FND_LOG.level_procedure;
  lv_proc_name         VARCHAR2 (100):= 'Create_Tax_Lines';
  ln_user_id           NUMBER        := fnd_global.user_id;
  ln_login_id          NUMBER        := fnd_global.login_id;

  lb_inclusive_tax     boolean; --added by eric for inclusive tax
  ln_jai_inv_line_id   NUMBER;
  lv_dist_class        VARCHAR2(50) := 'PERMANENT'; --Added by Bgowrava for Bug#8975118
BEGIN

  lv_insert_jai_inv_sql:=
    'INSERT INTO jai_ap_invoice_lines
     ( jai_ap_invoice_lines_id
     , organization_id
     , location_id
     , invoice_id
     , invoice_line_number
     , supplier_site_id
     , parent_invoice_line_number
     , tax_category_id
     , service_type_code
     , match_type
     , currency_code
     , line_amount
     , line_type_lookup_code
     , created_by
     , creation_date
     , last_update_date
     , last_update_login
     , last_updated_by
     )
     VALUES
     ( :1
     , :2
     , :3
     , :4
     , :5
     , :6
     , :7
     , :8
     , :9
     , :10
     , :11
     , :12
     , :13
     , :14
     , :15
     , :16
     , :17
     , :18
     )';

  lv_insert_jai_tax_sql :=
    'INSERT INTO jai_cmn_document_taxes
     ( doc_tax_id
     , tax_line_no
     , tax_id
     , tax_type
     , currency_code
     , tax_rate
     , qty_rate
     , uom
     , tax_amt
     , func_tax_amt
     , modvat_flag
     , tax_category_id
     , source_doc_type
     , source_doc_id
     , source_doc_line_id
     , source_table_name
     , tax_modified_by
     , adhoc_flag
     , precedence_1
     , precedence_2
     , precedence_3
     , precedence_4
     , precedence_5
     , precedence_6
     , precedence_7
     , precedence_8
     , precedence_9
     , precedence_10
     , creation_date
     , created_by
     , last_update_date
     , last_updated_by
     , last_update_login
     , object_version_number
     , vendor_id
     , source_doc_parent_line_no
     )
     VALUES
     ( :1
     , :2
     , :3
     , :4
     , :5
     , :6
     , :7
     , :8
     , :9
     , :10
     , :11
     , :12
     , :13
     , :14
     , :15
     , :16
     , :17
     , :18
     , :19
     , :20
     , :21
     , :22
     , :23
     , :24
     , :25
     , :26
     , :27
     , :28
     , :29
     , :30
     , :31
     , :32
     , :33
     , :34
     , :35
     , :36
     )';

  lv_insert_ap_inv_ln_sql :=
    'INSERT INTO ap_invoice_lines_all
     ( invoice_id
     , line_number
     , line_type_lookup_code
     , description
     , org_id
     , assets_tracking_flag
     , match_type
     , accounting_date
     , period_name
     , deferred_acctg_flag
     , def_acctg_start_date
     , def_acctg_end_date
     , def_acctg_number_of_periods
     , def_acctg_period_type
     , set_of_books_id
     , amount
     , wfapproval_status
     , creation_date
     , created_by
     , last_updated_by
     , last_update_date
     , last_update_login
     , project_id
     , task_id
     , expenditure_type
     , expenditure_item_date
     , expenditure_organization_id
     )
     VALUES
     ( :1
     , :2
     , :3
     , :4
     , :5
     , :6
     , :7
     , :8
     , :9
     , :10
     , :11
     , :12
     , :13
     , :14
     , :15
     , :16
     , :17
     , :18
     , :19
     , :20
     , :21
     , :22
     , :23
     , :24
     , :25
     , :26
     , :27
     )';

  lv_insert_ap_inv_dist_ln_sql :=
    'INSERT INTO ap_invoice_distributions_all
     ( accounting_date
     , accrual_posted_flag
     , assets_addition_flag
     , assets_tracking_flag
     , cash_posted_flag
     , distribution_line_number
     , dist_code_combination_id
     , invoice_id
     , last_updated_by
     , last_update_date
     , line_type_lookup_code
     , period_name
     , set_of_books_id
     , amount
   --, base_amount   deleted by eric on 2008-Jan-08, as po_matched case not populate the column
     , batch_id
     , created_by
     , creation_date
     , description
     , exchange_rate_variance
     , last_update_login
     , match_status_flag
     , posted_flag
     , rate_var_code_combination_id
     , reversal_flag
     , program_application_id
     , program_id
     , program_update_date
     , accts_pay_code_combination_id
     , invoice_distribution_id
     , quantity_invoiced
     , po_distribution_id
     , rcv_transaction_id
     , price_var_code_combination_id
     , invoice_price_variance
     , base_invoice_price_variance
     , matched_uom_lookup_code
     , invoice_line_number
     , org_id
     , charge_applicable_to_dist_id
     , project_id
     , task_id
     , expenditure_type
     , expenditure_item_date
     , expenditure_organization_id
     , project_accounting_context
     , pa_addition_flag
     , DISTRIBUTION_CLASS
     , TAX_RECOVERABLE_FLAG
     )
     VALUES
     ( :1
     , :2
     , :3
     , :4
     , :5
     , :6
     , :7
     , :8
     , :9
     , :10
     , :11
     , :12
     , :13
     , :14
     , :15
     , :16
     , :17
     , :18
     , :19
     , :20
     , :21
     , :22
     , :23
     , :24
     , :25
     , :26
     , :27
     , :28
     , :29
     , :30
     , :31
     , :32
     , :33
     , :34
     , :35
     , :36
     , :37
     , :38
     , :39
     , :40
     , :41
     , :42
     , :43
     , :44
     , :45
     , :46
     , :47
     , :48
     )';

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.begin'
                   , 'Enter procedure'
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_invoice_id ' || pn_invoice_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_line_number ' || pn_line_number
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_tax_modified    ' || pv_tax_modified
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_organization_id ' || pn_organization_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_location_id ' || pn_location_id
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pv_currency ' || pv_currency
                   );
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.parameters'
                   , 'pn_tax_category_id    ' || pn_tax_category_id
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

--insert into eric_log values (7.0,'Procedure Create_Tax_Lines',sysdate);
  --get invoice header information
  Get_Invoice_Header_Infor ( ln_invoice_id
                           , ln_vendor_id
                           , ln_vendor_site_id
                           , lv_currency_code
                           , ln_exchange_rate
                           , ln_batch_id
                           );

  --When updating tax category from IL form,set the tax_category_id
  --as the input parementer

  --If the program invoked from Standard AP invoice workbench,
  --Get the tax_category_id from configration of vendor-vndr site combination
  IF ( pn_tax_category_id is null
       AND pn_line_number is null ) --invoked form standard ap form
  THEN
    Get_Tax_Cat_Serv_Type ( pn_vendor_id            => ln_vendor_id
                          , pn_vendor_site_id       => ln_vendor_site_id
                          , xn_tax_category_id      => ln_tax_category_id
                          , xv_service_type_code    => lv_service_type_code
                          );
  ELSIF (pn_line_number is not null) --invoked form IL form or Case 6
  THEN
    Get_Tax_Cat_Serv_Type ( pn_vendor_id            => ln_vendor_id
                          , pn_vendor_site_id       => ln_vendor_site_id
                          , xn_tax_category_id      => ln_tax_category_id
                          , xv_service_type_code    => lv_service_type_code_tmp
                          ); --added by walton for bug#7202316
    ln_tax_category_id := pn_tax_category_id;
    --added by walton for bug#7202316
    lv_service_type_code:=nvl(lv_service_type_code,lv_service_type_code_tmp);
  END IF;

  --Get Max Line number
  ln_max_inv_line_num  := Get_Max_Invoice_Line_Number (ln_invoice_id);

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.debug Info.'
                   , 'Item Loop of First Time '
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  --Loop all item lines in the ap_invoice_lines
  FOR ap_invoice_lines_rec IN ap_invoice_lines_cur
  LOOP
--insert into eric_log values (7.1,'Go into Create_Tax_Lines.ap_invoice_lines_cur',sysdate);
--insert into eric_log values (7.2,'ap_invoice_lines_rec.invoice_id :'|| ap_invoice_lines_rec.invoice_id,sysdate);
--insert into eric_log values (7.3,'ap_invoice_lines_rec.line_number :'||ap_invoice_lines_rec.line_number,sysdate);

    ln_tax_amount := ap_invoice_lines_rec.amount;

    -- inserts taxes into jai_cmn_document_taxes
    IF NVL (pv_tax_modified, 'N') = 'N'
    THEN
      Default_Calculate_Taxes
      ( pn_invoice_id         => ap_invoice_lines_rec.invoice_id
      , pn_line_number        => ap_invoice_lines_rec.line_number
      , xn_tax_amount         => ln_tax_amount
      , pn_vendor_id          => ln_vendor_id
      , pn_vendor_site_id     => ln_vendor_site_id
      , pv_currency_code      => lv_currency_code
      , pn_tax_category_id    => ln_tax_category_id
      , pv_tax_modified       => lv_tax_modified
      );

      --into jai_ap_invoice_lines if item line exists in ap_invoice_lines_all
      --and not in jai_ap_invoice_lines

      FOR item_line_rec IN
        new_invoice_lines_cur (ap_invoice_lines_rec.line_number)
      LOOP
        SELECT
          jai_ap_invoice_lines_s.NEXTVAL
        INTO
        	ln_jai_inv_line_id
        FROM DUAL;

        EXECUTE IMMEDIATE lv_insert_jai_inv_sql
          USING ln_jai_inv_line_id
              , pn_organization_id
              , pn_location_id
              , item_line_rec.invoice_id
              , item_line_rec.line_number
              , ln_vendor_site_id
              , ''
              , ln_tax_category_id
              , lv_service_type_code
              , item_line_rec.match_type
              , lv_currency_code
              , item_line_rec.amount
              , item_line_rec.line_type_lookup_code
              , item_line_rec.created_by
              , item_line_rec.creation_date
              , item_line_rec.last_update_date
              , item_line_rec.last_update_login
              , item_line_rec.last_updated_by ;
      END LOOP;
--insert into eric_log values (7.4,'lv_insert_jai_inv_sql executed for item line :'||ap_invoice_lines_rec.line_number,sysdate);


    END IF;

    --get max tax line numbers
    ln_max_tax_line_num  := Get_Max_Tax_Line_Number
                            ( ln_invoice_id
                            , ap_invoice_lines_rec.line_number
                            );
    --update the tax line number for the filed of
    --jai_cmn_document_taxes.source_doc_line_id
    --and split each PR taxes into to two lines
    FOR jai_default_doc_taxes_rec IN
        jai_default_doc_taxes_cur
        ( pn_invoice_id  =>ln_invoice_id
        , pn_line_number =>ap_invoice_lines_rec.line_number
        )
    LOOP
--insert into eric_log values (7.5,'Go into Create_Tax_Lines.ap_invoice_lines_cur.jai_default_doc_taxes_cur',sysdate);
    	lb_inclusive_tax := check_inclusive_tax
    	                    (jai_default_doc_taxes_rec.tax_id);
--insert into eric_log values (7.6,'jai_default_doc_taxes_rec.tax_id: '||jai_default_doc_taxes_rec.tax_id,sysdate);

    	--commented out by eric for inclusive tax
    	----------------------------------------------------------
      --ln_max_inv_line_num  :=ln_max_inv_line_num   + 1;
      ----------------------------------------------------------

      --added by eric  for inclusive tax
      --for a inclusive tax, line source id is item LN #
      --for a exclusive tax, line source id is its corresponding invoice LN #
      ------------------------------------------------------------
      IF (lb_inclusive_tax) -- inclusive tax
      THEN
--insert into eric_log values (7.7,'lb_inclusive_tax: '||'inclusive tax',sysdate);
        ln_source_doc_line_id := ap_invoice_lines_rec.line_number;
      ELSE   -- exclusive tax
--insert into eric_log values (7.7,'lb_inclusive_tax: '||'exclusive tax',sysdate);
      	ln_max_inv_line_num   := ln_max_inv_line_num   + 1;
      	ln_source_doc_line_id := ln_max_inv_line_num ;
      END IF;--(lb_inclusive_tax)
      ------------------------------------------------------------

      IF pv_action = jai_constants.default_taxes
      THEN
        OPEN  get_tax_cur (jai_default_doc_taxes_rec.tax_id);
        FETCH get_tax_cur
        INTO
          tax_rec;
        CLOSE get_tax_cur;

        lv_tax_type := Get_Tax_Type
                       ( pv_modvat_flag   =>jai_default_doc_taxes_rec.modvat_flag
                       , pn_cr_percentage =>tax_rec.mod_cr_percentage
                       );

      --added by eric to fix the bug  bug#6784111 on Jan 29,2008 ,begin
      --------------------------------------------------------------------
       lv_pr_processed_flag := Get_Pr_Processed_Flag
                               ( pn_source_doc_id         =>jai_default_doc_taxes_rec.source_doc_id
                               , pn_source_parent_line_no =>jai_default_doc_taxes_rec.source_doc_parent_line_no
                               , pn_tax_id                =>jai_default_doc_taxes_rec.tax_id
                               );
      --------------------------------------------------------------------
      --added by eric to fix the bug  bug#6784111  on Jan 29,2008,end

        --common variables
        ln_tax_amount                   := NVL(jai_default_doc_taxes_rec.tax_amt,0);
        ln_func_tax_amount              := NVL(jai_default_doc_taxes_rec.func_tax_amt,0);


        --log for debug
        IF ( ln_proc_level >= ln_dbg_level)
        THEN
          FND_LOG.STRING ( ln_proc_level
                         , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.ap_invoice_lines_rec.line_number'
                         , ap_invoice_lines_rec.line_number
                         );

          FND_LOG.STRING ( ln_proc_level
                         , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.lv_tax_type'
                         , lv_tax_type
                         );
        END IF;   --( ln_proc_level >= ln_dbg_level )

        --fully recoverable /non recoverable tax
        --only one tax line are created
        IF (lv_tax_type='FR' OR lv_tax_type='NR')
        THEN
          -- update the source_doc_line_id to the real invoice line number
          UPDATE
            jai_cmn_document_taxes
          SET
            --modified by eric for inclusive tax
            ----------------------------------------------------------------
            source_doc_line_id = ln_source_doc_line_id --ln_max_inv_line_num
            ----------------------------------------------------------------
          WHERE CURRENT OF jai_default_doc_taxes_cur ;

        --deleted by eric to fix the bug  bug#6784111 on Jan 29,2008 ,begin
        ----------------------------------------------------------------------
        -- partially recoverable lines
        -- ELSIF ( lv_tax_type='PR' )
        --------------------------------------------------------------------
        --added by eric to fix the bug  bug#6784111  on Jan 29,2008 ,end

        --To fix the bug of processing the PR tax on the splitted Recvoerable portion
        --added by eric to fix the bug  bug#6784111  on Jan 29,2008 ,begin
        ----------------------------------------------------------------------
        ELSIF ( lv_tax_type='PR' AND lv_pr_processed_flag =JAI_CONSTANTS.no)
        THEN
        --------------------------------------------------------------------
        --added by eric to fix the bug  bug#6784111  on Jan 29,2008 ,end

          -- if the tax is partially recoverable tax, the tax line of table
          -- jai_cmn_document_taxes is required to be splited in two lines
          -- recoverable part and non-recoverable part

          ln_recur_tax_amt      :=
          NVL(ROUND( ln_tax_amount
                   * (tax_rec.mod_cr_percentage / 100)
                 , tax_rec.rounding_factor
                 ),0);

          ln_recur_func_tax_amt      :=
          NVL(ROUND( ln_func_tax_amount
                   * (tax_rec.mod_cr_percentage / 100)
                 , tax_rec.rounding_factor
                 ),0);
          ln_nrecur_tax_amt     :=ln_tax_amount-ln_recur_tax_amt;
          ln_nrecur_func_tax_amt :=ln_func_tax_amount -ln_recur_func_tax_amt;

          --log for debug
          IF ( ln_proc_level >= ln_dbg_level)
          THEN
            FND_LOG.STRING ( ln_proc_level
                           , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.ln_recur_tax_amt'
                           , ln_recur_tax_amt
                           );

            FND_LOG.STRING ( ln_proc_level
                           , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.ln_recur_func_tax_amt'
                           , ln_recur_func_tax_amt
                           );
            FND_LOG.STRING ( ln_proc_level
                           , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.ln_nrecur_tax_amt'
                           , ln_nrecur_tax_amt
                           );
            FND_LOG.STRING ( ln_proc_level
                           , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.ln_nrecur_func_tax_amt'
                           , ln_nrecur_func_tax_amt
                           );
          END IF;   --( ln_proc_level >= ln_dbg_level )

          -- To make the 2 PR tax line with same creation date and last update
          ld_sys_date   := sysdate; --Eric added on 18-Feb-2008,for bug#6824857

          FOR i IN 1..2
          LOOP

            --log for debug
            IF ( ln_proc_level >= ln_dbg_level)
            THEN
              FND_LOG.STRING ( ln_proc_level
                             , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.i'
                             , i
                             );
            END IF;   --( ln_proc_level >= ln_dbg_level )

            -- insert revocerable part
            IF (i = 1)
            THEN
              -- update the source_doc_line_id to the invoice line number
              UPDATE
                jai_cmn_document_taxes
              SET
                --modified by eric for inclusive tax
                ----------------------------------------------------------------
                source_doc_line_id = ln_source_doc_line_id --ln_max_inv_line_num
                ----------------------------------------------------------------
              , tax_amt            = ln_recur_tax_amt
              , func_tax_amt       = ln_recur_func_tax_amt
              , modvat_flag        = 'Y'
              , creation_date      = ld_sys_date --Eric added on 18-Feb-2008,for bug#6824857
              , last_update_date   = ld_sys_date --sysdate,Eric changed on 18-Feb-2008,for bug#6824857
              , created_by         = ln_user_id  --Eric added on 18-Feb-2008,for bug#6824857
              , last_updated_by    = ln_user_id
              , last_update_login  = ln_login_id
              WHERE CURRENT OF jai_default_doc_taxes_cur ;
            ELSIF (i=2)
            THEN
              --commented out by eric for inclusive tax
    	        ----------------------------------------------------------
              --ln_max_inv_line_num  :=ln_max_inv_line_num   + 1;
              ----------------------------------------------------------

              --added by eric  for inclusive tax
              --for a inclusive tax, line source id is item LN #
              --for a exclusive tax, line source id is its corresponding invoice LN #
              ------------------------------------------------------------
              IF (lb_inclusive_tax) -- inclusive tax
              THEN
                ln_source_doc_line_id := ap_invoice_lines_rec.line_number;
              ELSE  -- exclusive tax
              	ln_max_inv_line_num   := ln_max_inv_line_num   + 1;
              	ln_source_doc_line_id := ln_max_inv_line_num ;
              END IF;--(lb_inclusive_tax)

              --ln_max_tax_line_num := ln_max_tax_line_num +1; Eric deleted  for two records shown in Form

              --Eric Ma added for two records shown in Form,begin
            	--------------------------------------------------
              ln_max_tax_line_num := jai_default_doc_taxes_rec.tax_line_no;
              ------------------------------------------------------
              --Eric Ma added for two records shown in Form,end

              SELECT
                jai_cmn_document_taxes_s.nextval
              INTO
                ln_doc_tax_id
              FROM DUAL;

              EXECUTE IMMEDIATE lv_insert_jai_tax_sql
                USING ln_doc_tax_id
                    , ln_max_tax_line_num
                    , jai_default_doc_taxes_rec.tax_id
                    , jai_default_doc_taxes_rec.tax_type
                    , jai_default_doc_taxes_rec.currency_code
                    , jai_default_doc_taxes_rec.tax_rate
                    , jai_default_doc_taxes_rec.qty_rate
                    , jai_default_doc_taxes_rec.uom
                    , ln_nrecur_tax_amt      --TAX_AMT
                    , ln_nrecur_func_tax_amt --FUNC_TAX_AMT
                    , 'N'                    --MODVAT_FLAG
                    , jai_default_doc_taxes_rec.tax_category_id
                    , jai_default_doc_taxes_rec.source_doc_type
                    , jai_default_doc_taxes_rec.source_doc_id
                    --modified by eric for inclusive tax
                    -----------------------------------------------
                    ,ln_source_doc_line_id --, ln_max_inv_line_num
                    -----------------------------------------------
                    , jai_default_doc_taxes_rec.source_table_name
                    , jai_default_doc_taxes_rec.tax_modified_by
                    , jai_default_doc_taxes_rec.adhoc_flag
                    , jai_default_doc_taxes_rec.precedence_1
                    , jai_default_doc_taxes_rec.precedence_2
                    , jai_default_doc_taxes_rec.precedence_3
                    , jai_default_doc_taxes_rec.precedence_4
                    , jai_default_doc_taxes_rec.precedence_5
                    , jai_default_doc_taxes_rec.precedence_6
                    , jai_default_doc_taxes_rec.precedence_7
                    , jai_default_doc_taxes_rec.precedence_8
                    , jai_default_doc_taxes_rec.precedence_9
                    , jai_default_doc_taxes_rec.precedence_10
                    , ld_sys_date --SYSDATE,Eric changed on 18-Feb-2008,for bug#6824857          --creation_date
                    , ln_user_id       --created_by
                    , ld_sys_date --SYSDATE,Eric changed on 18-Feb-2008,for bug#6824857         --last_update_date
                    , ln_user_id       --last_updated_by
                    , ln_login_id      --last_update_login
                    , jai_default_doc_taxes_rec.object_version_number
                    , jai_default_doc_taxes_rec.vendor_id
                    , ap_invoice_lines_rec.line_number;
            END IF; --(i=1)
          END LOOP; --(i IN 1..2)
        END IF;  --(lv_tax_type='FR' OR lv_tax_type='NR')
      END IF; -- (default_tax)
    END LOOP; -- (jai_default_doc_taxes_cur)
  END LOOP;   -- (ap_invoice_lines_rec AP INVOICE ITEM LINE LEVEL)

  --delete taxes from ap invoice/dist lines,jai_ap_invoice_lines
  IF (pv_tax_modified ='Y')
  THEN
      Delete_Tax_Lines ( pn_invoice_id            => ln_invoice_id
                       , pn_line_number           => ln_line_number
                       , pv_modified_only_flag    => 'Y'
                       );
  END IF;--(pv_tax_modified ='Y')

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.debug Info.'
                   , 'Item Loop of Second Time '
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

  --The below 2 loops is to synchronize exclusive taxes information from
  --jai_cmn_document_taxes to other 3 tables

--insert into eric_log values (7.8,'prepare to sync data from jai_cmn_document_taxes to other 3 tables ',sysdate);

  --Loop 1, item level: Loop all item lines in the ap_invoice_lines
  FOR ap_invoice_lines_rec IN ap_invoice_lines_cur
  LOOP

    --Loop 2,tax level:Loop all tax lines in jai_cmn_document_taxes
    FOR jai_doc_taxes_rec IN
        jai_doc_taxes_cur
        ( pn_invoice_id         => ln_invoice_id
        , pn_parent_line_number => ap_invoice_lines_rec.line_number
        )
    LOOP
      --insert into eric_log values (7.801,'come into loop ap_invoice_lines_rec.jai_doc_taxes_rec for item line :'|| ap_invoice_lines_rec.line_number,sysdate);
      --insert into eric_log values (7.802,'jai_doc_taxes_rec.tax_id = '|| jai_doc_taxes_rec.tax_id,sysdate);

      /*Removed this IF from here by Jia Li for inclusive tax on 2008/01/23
      --added by eric for inclusive tax
      --insert exclusive tax into jai_ap_invoice_lines and standard ap tables
      ----------------------------------------------------------
      IF (NVL(jai_doc_taxes_rec.inc_tax_flag,'N')='N')
      THEN
      ----------------------------------------------------------
      */
      OPEN  get_tax_cur (jai_doc_taxes_rec.tax_id);
      FETCH get_tax_cur
      INTO
        tax_rec;
      CLOSE get_tax_cur;

      lv_tax_type :=
        Get_Tax_Type
        ( pv_modvat_flag   =>jai_doc_taxes_rec.modvat_flag
        , pn_cr_percentage =>tax_rec.mod_cr_percentage
        );

      --get mandantory parameters from item line
      --the acct distribution will be handled in other procedure
      OPEN ap_invoice_dist_cur (ap_invoice_lines_rec.line_number);
      FETCH
        ap_invoice_dist_cur
      INTO
        ap_invoice_dist_rec ;
      CLOSE ap_invoice_dist_cur;

      IF (lv_tax_type = 'NR')
      THEN
        ln_asset_track_flag := ap_invoice_lines_rec.assets_tracking_flag;
        ln_project_id       := ap_invoice_lines_rec.project_id;
        ln_task_id          := ap_invoice_lines_rec.task_id;
        lv_expenditure_type := ap_invoice_lines_rec.expenditure_type;
        ld_exp_item_date    := ap_invoice_lines_rec.expenditure_item_date;
        ln_exp_org_id     := ap_invoice_lines_rec.expenditure_organization_id;

        ln_dist_asst_add_flag :=ap_invoice_dist_rec.assets_addition_flag ;
        ln_dist_asst_trck_flag:=ap_invoice_dist_rec.assets_tracking_flag ;
        ln_dist_project_id    :=ap_invoice_dist_rec.project_id;
        ln_dist_task_id       :=ap_invoice_dist_rec.task_id;
        ln_dist_exp_type      :=ap_invoice_dist_rec.expenditure_type;
        ld_dist_exp_item_date :=ap_invoice_dist_rec.expenditure_item_date;
        ln_dist_exp_org_id  :=ap_invoice_dist_rec.expenditure_organization_id;
        ln_dist_pa_context  :=ap_invoice_dist_rec.project_accounting_context;
        ln_dist_pa_addition_flag :=ap_invoice_dist_rec.pa_addition_flag;
        lv_asset_book_type_code  :=ap_invoice_dist_rec.asset_book_type_code;
        ln_asset_category_id     :=ap_invoice_dist_rec.asset_category_id;
        lv_tax_recoverable_flag  :='N';

      ELSE --(RECOVERABLE)
      	ln_asset_track_flag      := 'N';
      	ln_project_id            := NULL;
        ln_task_id               := NULL;
        lv_expenditure_type      := NULL;
        ld_exp_item_date         := NULL;
        ln_exp_org_id            := NULL;

        ln_dist_asst_add_flag    := 'U';
        ln_dist_asst_trck_flag   := 'N';
        ln_dist_project_id       := NULL;
        ln_dist_task_id          := NULL;
        ln_dist_exp_type         := NULL;
        ld_dist_exp_item_date    := NULL;
        ln_dist_exp_org_id       := NULL;
        ln_dist_pa_context       := NULL;
        ln_dist_pa_addition_flag := 'E'; --NOT PROJECT RELATED
        lv_tax_recoverable_flag  := 'Y';
        lv_asset_book_type_code  := NULL;
        ln_asset_category_id     := NULL;
      END IF; --(lv_tax_type = 'NR')

      --Moved  IF to here by Jia Li for inclusive tax on 2008/01/23
      --added by eric for inclusive tax
      --insert exclusive tax into jai_ap_invoice_lines and standard ap tables
      ----------------------------------------------------------
      IF (NVL(jai_doc_taxes_rec.inc_tax_flag,'N')='N')
      THEN
      ----------------------------------------------------------
        SELECT
          jai_ap_invoice_lines_s.NEXTVAL
        INTO
        	ln_jai_inv_line_id
        FROM DUAL;

        /*bug 9539642 - this cursor should be executed in all casses, to fetch
          the organization-location details. So changed the target variables and
          replaced the if-end if with nvl at the end*/
          lv_service_type_code_tmp := null;
		OPEN get_service_type (ln_invoice_id, ap_invoice_lines_rec.line_number);
		FETCH get_service_type INTO lv_service_type_code_tmp, lv_organization_id,lv_location_id ; --Added organization location for bug#9206909 by JMEENA
	        CLOSE get_service_type;
          lv_service_type_code := nvl(lv_service_type_code, lv_service_type_code_tmp);

--insert into eric_log values (7.81,'jai_doc_taxes_rec.inc_tax_flag =''N'' Branch ',sysdate);
        --insert into jai_ap_invoice_lines
        EXECUTE IMMEDIATE lv_insert_jai_inv_sql
          USING ln_jai_inv_line_id
              , lv_organization_id --Replaced pn_organization_id with lv_organization_id for bug#9206909
              , lv_location_id --Replaced pn_location_id with lv_location_id for bug#9206909
              , jai_doc_taxes_rec.source_doc_id
              , jai_doc_taxes_rec.source_doc_line_id
              , ln_vendor_site_id
              , jai_doc_taxes_rec.source_doc_parent_line_no
              , jai_doc_taxes_rec.tax_category_id
              , lv_service_type_code --Added for bug#9098529 by JMEENA
              , ap_invoice_lines_rec.match_type
              , lv_currency_code
              , jai_doc_taxes_rec.tax_amt
              , GV_CONSTANT_MISCELLANEOUS
              , ln_user_id
              , SYSDATE
              , SYSDATE
              , ln_login_id
              , ln_user_id ;

--insert into eric_log values (7.82,'lv_insert_jai_inv_sql executed for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);
        --log for debug
        IF ( ln_proc_level >= ln_dbg_level)
        THEN
          FND_LOG.STRING ( ln_proc_level
                         , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                           || '.debug Info.'
                         , 'Table jai_ap_invoice_lines inserted '
                         );
        END IF;   --( ln_proc_level >= ln_dbg_level )

        --insert into ap_invoice_lines_all
        EXECUTE IMMEDIATE lv_insert_ap_inv_ln_sql
          USING jai_doc_taxes_rec.source_doc_id
              , jai_doc_taxes_rec.source_doc_line_id
              , GV_CONSTANT_MISCELLANEOUS
              , tax_rec.tax_name
              , ap_invoice_lines_rec.org_id
              , ln_asset_track_flag
              , ap_invoice_lines_rec.match_type
              , ap_invoice_lines_rec.accounting_date
              , ap_invoice_lines_rec.period_name
              , ap_invoice_lines_rec.deferred_acctg_flag
              , ap_invoice_lines_rec.def_acctg_start_date
              , ap_invoice_lines_rec.def_acctg_end_date
              , ap_invoice_lines_rec.def_acctg_number_of_periods
              , ap_invoice_lines_rec.def_acctg_period_type
              , ap_invoice_lines_rec.set_of_books_id
              , jai_doc_taxes_rec.tax_amt
              , ap_invoice_lines_rec.wfapproval_status
              , SYSDATE
              , ln_user_id
              , ln_user_id
              , SYSDATE
              , ln_login_id
              , ln_project_id
              , ln_task_id
              , lv_expenditure_type
              , ld_exp_item_date
              , ln_exp_org_id ;

--insert into eric_log values (7.83,'lv_insert_ap_inv_ln_sql executed  for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);

        --log for debug
        IF ( ln_proc_level >= ln_dbg_level)
        THEN
          FND_LOG.STRING ( ln_proc_level
                         , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                           || '.debug Info.'
                         , 'Table ap_invoice_lines_all inserted '
                         );
        END IF;   --( ln_proc_level >= ln_dbg_level )

        ln_dist_acct_ccid :=
          Get_Dist_Account_Ccid
          ( pn_invoice_id       => ln_invoice_id
          , pn_item_line_number => ap_invoice_lines_rec.line_number
          , pn_organization_id  => lv_organization_id --Replaced pn_organization_id with lv_organization_id for bug#9206909
          , pn_location_id      => lv_location_id --Replaced pn_location_id with lv_location_id for bug#9206909
          , pn_tax_type_code    => tax_rec.tax_type
          , pn_tax_acct_ccid    => tax_rec.tax_account_id
          , pv_tax_type         => lv_tax_type
          );

        SELECT
          ap_invoice_distributions_s.NEXTVAL
        INTO
        	ln_inv_dist_id
        FROM DUAL;

        IF (ap_invoice_dist_rec.assets_tracking_flag = 'N')
        THEN
          ln_chargeble_acct_ccid :=NULL;
        ELSE
          lv_account_type := Get_Gl_Account_Type (ln_dist_acct_ccid);

          IF lv_account_type ='A'
          THEN
          	ln_chargeble_acct_ccid := ln_dist_acct_ccid;
          ELSE
          	ln_chargeble_acct_ccid := NULL;
          END IF;
        END IF;

        --insert into ap_distribution_lines_all
        EXECUTE IMMEDIATE lv_insert_ap_inv_dist_ln_sql
          USING ap_invoice_lines_rec.accounting_date
              , 'N'
              , ln_dist_asst_add_flag
              , ln_dist_asst_trck_flag
              , 'N'
              , 1             --distribution_line_number
              , ln_dist_acct_ccid
              , ln_invoice_id
              , ln_user_id
              , SYSDATE
              , GV_CONSTANT_MISCELLANEOUS
              , ap_invoice_lines_rec.period_name
              , ap_invoice_lines_rec.set_of_books_id
              , jai_doc_taxes_rec.tax_amt
          --  , jai_doc_taxes_rec.func_tax_amt :deleted by eric on 2008-Jan-08, as po_matched case not populate the column
              , ln_batch_id            --invoice header level
              , ln_user_id
              , SYSDATE
              , tax_rec.tax_name
              , ''
              , ln_login_id
              , ap_invoice_dist_rec.match_status_flag
              , 'N'                    -- posted_flag
              , ''
              --, ap_invoice_dist_rec.reversal_flag -- Comments by Jia for bug#9666819
              , NVL(ap_invoice_dist_rec.reversal_flag,'N')   -- Modified by Jia for  bug#9666819
              , ap_invoice_dist_rec.program_application_id
              , ap_invoice_dist_rec.program_id
              , ap_invoice_dist_rec.program_update_date
              , ap_invoice_dist_rec.accts_pay_code_combination_id
              , ln_inv_dist_id
              , -1
              , ''
              , ''
              , ap_invoice_dist_rec.rcv_transaction_id
              , ap_invoice_dist_rec.invoice_price_variance
              , ap_invoice_dist_rec.base_invoice_price_variance
              , ap_invoice_dist_rec.matched_uom_lookup_code
              , jai_doc_taxes_rec.source_doc_line_id
              , ap_invoice_lines_rec.org_id
              , ln_chargeble_acct_ccid
              , ln_dist_project_id
              , ln_dist_task_id
              , ln_dist_exp_type
              , ld_dist_exp_item_date
              , ln_dist_exp_org_id
              , ln_dist_pa_context
              , ln_dist_pa_addition_flag
              , lv_dist_class --ap_invoice_dist_rec.distribution_class  --Added by Bgowrava for Bug#8975118
              , lv_tax_recoverable_flag;

--insert into eric_log values (7.84,'lv_insert_ap_inv_dist_ln_sql executed  for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);
              --log for debug
              IF ( ln_proc_level >= ln_dbg_level)
              THEN
                FND_LOG.STRING ( ln_proc_level
                               , GV_MODULE_PREFIX ||'.'|| lv_proc_name
                                 || '.debug Info.'
                               , 'Table ap_distribution_lines_all inserted '
                               );
              END IF;   --( ln_proc_level >= ln_dbg_level )
      --added by eric for inclusive tax
      ----------------------------------------------------------------------

      -- Added by Jia Li for inclusive tax on 2008/01/23, Begin
      -- insert two lines with inclusive recoverable tax
      -- One line is negative with project info
      -- another line is positive with no project info
      ----------------------------------------------------------
      ELSIF ( NVL(jai_doc_taxes_rec.inc_tax_flag,'N') = 'Y' )
            AND ( lv_tax_type <> 'NR' )
            AND ( ap_invoice_lines_rec.project_id IS NOT NULL )
      THEN

--insert into eric_log values (7.91,'jai_doc_taxes_rec.inc_tax_flag =''Y'' AND recoverable with project case ',sysdate);

        -- Insert negative line with project info
        -- Line number got from max jai_cmn_document_taxes.source_doc_line_id
        --  or max ap_invoice_lines_all.line_number
        ln_max_inv_line_num := Get_Max_Invoice_Line_Number(ln_invoice_id);

        -- deleted by eric for fixing the bug of bug#6784111 on 29-JAN,2008,begin
        /*
        ln_max_tax_line_num := Get_Max_Tax_Line_Number
                            ( ln_invoice_id
                            , ap_invoice_lines_rec.line_number );

        IF ln_max_inv_line_num >= ln_max_tax_line_num
        THEN
          ln_max_pro_line_num := ln_max_inv_line_num + 1;
        ELSE
          ln_max_pro_line_num := ln_max_tax_line_num + 1;
        END IF;
        */
        -- deleted by eric for fixing the bug of bug#6784111 on 29-JAN,2008,end

        --added by eric for fixing the bug of bug#6784111 on 29-JAN,2008,begin
        ----------------------------------------------------------------------
        ln_max_source_line_id := Get_Max_Doc_Source_Line_Id(ln_invoice_id);

        IF (ln_max_inv_line_num >= ln_max_source_line_id )
        THEN
          ln_max_pro_line_num :=  ln_max_inv_line_num + 1;
        ELSE
          ln_max_pro_line_num := ln_max_source_line_id + 1;
        END IF; --(ln_max_inv_line_num >= ln_max_source_line_id )
        ----------------------------------------------------------------------
        --added by eric for fixing the bug of bug#6784111 on 29-JAN,2008,end

        SELECT
          jai_ap_invoice_lines_s.NEXTVAL
        INTO
        	ln_jai_inv_line_id
        FROM DUAL;

        /*bug 9539642 - this cursor should be executed in all casses, to fetch
          the organization-location details. So changed the target variables and
          replaced the if-end if with nvl at the end*/
          lv_service_type_code_tmp := null;
		OPEN get_service_type (ln_invoice_id, ap_invoice_lines_rec.line_number);
		FETCH get_service_type INTO lv_service_type_code_tmp, lv_organization_id,lv_location_id ; --Added organization location for bug#9206909 by JMEENA
	        CLOSE get_service_type;
          lv_service_type_code := nvl(lv_service_type_code, lv_service_type_code_tmp);

        EXECUTE IMMEDIATE lv_insert_jai_inv_sql
          USING ln_jai_inv_line_id
              , lv_organization_id --Replaced pn_organization_id with lv_organization_id for bug#9206909
              , lv_location_id --Replaced pn_location_id with lv_location_id for bug#9206909
              , jai_doc_taxes_rec.source_doc_id  -- invoice_id
              , ln_max_pro_line_num              -- invoice_line_num
              , ln_vendor_site_id
              , jai_doc_taxes_rec.source_doc_parent_line_no
              , jai_doc_taxes_rec.tax_category_id
              , lv_service_type_code --Added for bug#9098529 by JMEENA
              , ap_invoice_lines_rec.match_type
              , lv_currency_code
              , -jai_doc_taxes_rec.tax_amt  -- negative tax amount
              , GV_CONSTANT_MISCELLANEOUS
              , ln_user_id
              , SYSDATE
              , SYSDATE
              , ln_login_id
              , ln_user_id ;

--insert into eric_log values (7.92,'lv_insert_jai_inv_sql executed  for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);

        EXECUTE IMMEDIATE lv_insert_ap_inv_ln_sql
          USING jai_doc_taxes_rec.source_doc_id      -- invoice_id
              , ln_max_pro_line_num                  -- line_number
              , GV_CONSTANT_MISCELLANEOUS
              , tax_rec.tax_name
              , ap_invoice_lines_rec.org_id
              , ap_invoice_lines_rec.assets_tracking_flag
              , ap_invoice_lines_rec.match_type
              , ap_invoice_lines_rec.accounting_date
              , ap_invoice_lines_rec.period_name
              , ap_invoice_lines_rec.deferred_acctg_flag
              , ap_invoice_lines_rec.def_acctg_start_date
              , ap_invoice_lines_rec.def_acctg_end_date
              , ap_invoice_lines_rec.def_acctg_number_of_periods
              , ap_invoice_lines_rec.def_acctg_period_type
              , ap_invoice_lines_rec.set_of_books_id
              , -jai_doc_taxes_rec.tax_amt           -- negative tax amount
              , ap_invoice_lines_rec.wfapproval_status
              , SYSDATE
              , ln_user_id
              , ln_user_id
              , SYSDATE
              , ln_login_id
              , ap_invoice_lines_rec.project_id
              , ap_invoice_lines_rec.task_id
              , ap_invoice_lines_rec.expenditure_type
              , ap_invoice_lines_rec.expenditure_item_date
              , ap_invoice_lines_rec.expenditure_organization_id ;

--insert into eric_log values (7.92,'lv_insert_ap_inv_ln_sql executed  for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);

        ln_dist_acct_ccid := Get_Dist_Account_Ccid
                ( pn_invoice_id       => ln_invoice_id
                , pn_item_line_number => ap_invoice_lines_rec.line_number
                , pn_organization_id  => lv_organization_id --Replaced pn_organization_id with lv_organization_id for bug#9206909
                , pn_location_id      => lv_location_id --Replaced pn_location_id with lv_location_id for bug#9206909
                , pn_tax_type_code    => tax_rec.tax_type
                , pn_tax_acct_ccid    => tax_rec.tax_account_id
                , pv_tax_type         => lv_tax_type
                );

        SELECT
          ap_invoice_distributions_s.NEXTVAL
        INTO
        	ln_inv_dist_id
        FROM DUAL;

        IF (ap_invoice_dist_rec.assets_tracking_flag = 'N')
        THEN
          ln_chargeble_acct_ccid :=NULL;
        ELSE
          lv_account_type := Get_Gl_Account_Type (ln_dist_acct_ccid);

          IF lv_account_type ='A'
          THEN
          	ln_chargeble_acct_ccid := ln_dist_acct_ccid;
          ELSE
          	ln_chargeble_acct_ccid := NULL;
          END IF;
        END IF;

        EXECUTE IMMEDIATE lv_insert_ap_inv_dist_ln_sql
          USING ap_invoice_lines_rec.accounting_date
              , 'N'
              , ap_invoice_dist_rec.assets_addition_flag
              , ap_invoice_dist_rec.assets_tracking_flag
              , 'N'
              , 1             --distribution_line_number
              , ln_dist_acct_ccid
              , ln_invoice_id
              , ln_user_id
              , SYSDATE
              , GV_CONSTANT_MISCELLANEOUS
              , ap_invoice_lines_rec.period_name
              , ap_invoice_lines_rec.set_of_books_id
              , -jai_doc_taxes_rec.tax_amt        -- negative tax amount
          --  , jai_doc_taxes_rec.func_tax_amt :deleted by eric on 2008-Jan-08, as po_matched case not populate the column
              , ln_batch_id                       -- invoice header level
              , ln_user_id
              , SYSDATE
              , tax_rec.tax_name
              , ''
              , ln_login_id
              , ap_invoice_dist_rec.match_status_flag
              , 'N'                    -- posted_flag
              , ''
              , ap_invoice_dist_rec.reversal_flag
              , ap_invoice_dist_rec.program_application_id
              , ap_invoice_dist_rec.program_id
              , ap_invoice_dist_rec.program_update_date
              , ap_invoice_dist_rec.accts_pay_code_combination_id
              , ln_inv_dist_id
              , -1
              , ''
              , ''
              , ap_invoice_dist_rec.price_var_code_combination_id
              , ap_invoice_dist_rec.invoice_price_variance
              , ap_invoice_dist_rec.base_invoice_price_variance
              , ap_invoice_dist_rec.matched_uom_lookup_code
              , ln_max_pro_line_num             -- invoice_line_number
              , ap_invoice_lines_rec.org_id
              , ln_chargeble_acct_ccid
              , ap_invoice_dist_rec.project_id
              , ap_invoice_dist_rec.task_id
              , ap_invoice_dist_rec.expenditure_type
              , ap_invoice_dist_rec.expenditure_item_date
              , ap_invoice_dist_rec.expenditure_organization_id
              , ap_invoice_dist_rec.project_accounting_context
              , ap_invoice_dist_rec.pa_addition_flag
              , lv_dist_class --ap_invoice_dist_rec.distribution_class  --Added by Bgowrava for Bug#8975118
              , 'Y';

--insert into eric_log values (7.93,'lv_insert_ap_inv_dist_ln_sql executed  for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);

        -- Insert positive line with no project info
        ln_max_pro_line_num := ln_max_pro_line_num + 1;

        SELECT
          jai_ap_invoice_lines_s.NEXTVAL
        INTO
        	ln_jai_inv_line_id
        FROM DUAL;

--insert into eric_log values (7.94,'prepare to insert ositive line with no project info ',sysdate);
        /*bug 9539642 - this cursor should be executed in all casses, to fetch
          the organization-location details. So changed the target variables and
          replaced the if-end if with nvl at the end*/
          lv_service_type_code_tmp := null;
		OPEN get_service_type (ln_invoice_id, ap_invoice_lines_rec.line_number);
		FETCH get_service_type INTO lv_service_type_code_tmp, lv_organization_id,lv_location_id ; --Added organization location for bug#9206909 by JMEENA
	        CLOSE get_service_type;
          lv_service_type_code := nvl(lv_service_type_code, lv_service_type_code_tmp);

        EXECUTE IMMEDIATE lv_insert_jai_inv_sql
          USING ln_jai_inv_line_id
              , lv_organization_id --Replaced pn_organization_id with lv_organization_id for bug#9206909
              , lv_location_id --Replaced pn_location_id with lv_location_id for bug#9206909
              , jai_doc_taxes_rec.source_doc_id   -- invoice_id
              , ln_max_pro_line_num               -- line_number
              , ln_vendor_site_id
              , jai_doc_taxes_rec.source_doc_parent_line_no
              , jai_doc_taxes_rec.tax_category_id
              , lv_service_type_code --Added for bug#9098529 by JMEENA
              , ap_invoice_lines_rec.match_type
              , lv_currency_code
              , jai_doc_taxes_rec.tax_amt  -- positive tax amount
              , GV_CONSTANT_MISCELLANEOUS
              , ln_user_id
              , SYSDATE
              , SYSDATE
              , ln_login_id
              , ln_user_id ;

--insert into eric_log values (7.95,'lv_insert_jai_inv_sql executed  for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);

        EXECUTE IMMEDIATE lv_insert_ap_inv_ln_sql
          USING jai_doc_taxes_rec.source_doc_id      -- invoice_id
              , ln_max_pro_line_num                  -- line_number
              , GV_CONSTANT_MISCELLANEOUS
              , tax_rec.tax_name
              , ap_invoice_lines_rec.org_id
              , 'N'
              , ap_invoice_lines_rec.match_type
              , ap_invoice_lines_rec.accounting_date
              , ap_invoice_lines_rec.period_name
              , ap_invoice_lines_rec.deferred_acctg_flag
              , ap_invoice_lines_rec.def_acctg_start_date
              , ap_invoice_lines_rec.def_acctg_end_date
              , ap_invoice_lines_rec.def_acctg_number_of_periods
              , ap_invoice_lines_rec.def_acctg_period_type
              , ap_invoice_lines_rec.set_of_books_id
              , jai_doc_taxes_rec.tax_amt           -- positive tax amount
              , ap_invoice_lines_rec.wfapproval_status
              , SYSDATE
              , ln_user_id
              , ln_user_id
              , SYSDATE
              , ln_login_id
              , ''
              , ''
              , ''
              , ''
              , '' ;

--insert into eric_log values (7.96,'lv_insert_ap_inv_ln_sql executed  for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);

        ln_dist_acct_ccid := Get_Dist_Account_Ccid
                ( pn_invoice_id       => ln_invoice_id
                , pn_item_line_number => ap_invoice_lines_rec.line_number
                , pn_organization_id  => lv_organization_id --Replaced pn_organization_id with lv_organization_id for bug#9206909
                , pn_location_id      => lv_location_id --Replaced pn_location_id with lv_location_id for bug#9206909
                , pn_tax_type_code    => tax_rec.tax_type
                , pn_tax_acct_ccid    => tax_rec.tax_account_id
                , pv_tax_type         => lv_tax_type
                );

        SELECT
          ap_invoice_distributions_s.NEXTVAL
        INTO
        	ln_inv_dist_id
        FROM DUAL;

        IF (ap_invoice_dist_rec.assets_tracking_flag = 'N')
        THEN
          ln_chargeble_acct_ccid :=NULL;
        ELSE
          lv_account_type := Get_Gl_Account_Type (ln_dist_acct_ccid);

          IF lv_account_type ='A'
          THEN
          	ln_chargeble_acct_ccid := ln_dist_acct_ccid;
          ELSE
          	ln_chargeble_acct_ccid := NULL;
          END IF;
        END IF;

        EXECUTE IMMEDIATE lv_insert_ap_inv_dist_ln_sql
          USING ap_invoice_lines_rec.accounting_date
              , 'N'
              , 'U'        -- assets_addition_flag
              , 'N'        -- assets_tracking_flag
              , 'N'        -- cash_posted_flag
              , 1          -- distribution_line_number
              , ln_dist_acct_ccid
              , ln_invoice_id
              , ln_user_id
              , SYSDATE
              , GV_CONSTANT_MISCELLANEOUS
              , ap_invoice_lines_rec.period_name
              , ap_invoice_lines_rec.set_of_books_id
              , jai_doc_taxes_rec.tax_amt        -- positive tax amount
          --  , jai_doc_taxes_rec.func_tax_amt :deleted by eric on 2008-Jan-08, as po_matched case not populate the column
              , ln_batch_id                       -- invoice header level
              , ln_user_id
              , SYSDATE
              , tax_rec.tax_name
              , ''
              , ln_login_id
              , ap_invoice_dist_rec.match_status_flag
              , 'N'                    -- posted_flag
              , ''
              , ap_invoice_dist_rec.reversal_flag
              , ap_invoice_dist_rec.program_application_id
              , ap_invoice_dist_rec.program_id
              , ap_invoice_dist_rec.program_update_date
              , ap_invoice_dist_rec.accts_pay_code_combination_id
              , ln_inv_dist_id
              , -1
              , ''
              , ''
              , ap_invoice_dist_rec.price_var_code_combination_id
              , ap_invoice_dist_rec.invoice_price_variance
              , ap_invoice_dist_rec.base_invoice_price_variance
              , ap_invoice_dist_rec.matched_uom_lookup_code
              , ln_max_pro_line_num        -- invoice_line_number
              , ap_invoice_lines_rec.org_id
              , ln_chargeble_acct_ccid
              , ''  -- project_id
              , ''  -- task_id
              , ''  -- expenditure_type
              , ''  -- expenditure_item_date
              , ''  -- expenditure_organization_id
              , ''  -- project_accounting_context
              , 'E'   -- pa_addition_flag
              , lv_dist_class --ap_invoice_dist_rec.distribution_class --Added by Bgowrava for Bug#8975118
              , 'Y';

--insert into eric_log values (7.97,'lv_insert_ap_inv_dist_ln_sql executed  for item line number :'|| ap_invoice_lines_rec.line_number,sysdate);

      ----------------------------------------------------------
      -- Added by Jia Li for inclusive tax on 2008/01/23, End

      END IF;  -- NVL(jai_doc_taxes_rec.inc_tax_flag,'N')='N'
      ----------------------------------------------------------------------
    END LOOP; -- (all taxes for a given parent line number)
  END LOOP;   -- (ap_invoice_lines_rec IN ap_invoice_lines_cur,second time)

  --log for debug
  IF ( ln_proc_level >= ln_dbg_level)
  THEN
    FND_LOG.STRING ( ln_proc_level
                   , GV_MODULE_PREFIX ||'.'|| lv_proc_name || '.end'
                   , 'Exit procedure'
                   );
  END IF;   --( ln_proc_level >= ln_dbg_level )

EXCEPTION
  WHEN OTHERS THEN
    IF ( ln_proc_level >= ln_dbg_level)
    THEN
      FND_LOG.STRING ( ln_proc_level
                     , GV_MODULE_PREFIX|| '.'|| lv_proc_name
                       || '. Other_Exception '
                     , SQLCODE || ':' || SQLERRM
                     );
    END IF;   --( ln_proc_level >= ln_dbg_level)  ;
    RAISE;
END Create_Tax_Lines;
END JAI_AP_STND_TAX_PROCESS;

/
