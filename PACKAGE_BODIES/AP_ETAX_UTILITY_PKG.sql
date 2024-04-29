--------------------------------------------------------
--  DDL for Package Body AP_ETAX_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_ETAX_UTILITY_PKG" AS
/* $Header: apetxutb.pls 120.102.12010000.53 2010/07/20 20:36:45 anarun ship $*/
  -- Create global variables to maintain the session info
  l_user_id		ap_invoices_all.created_by%TYPE 	:= FND_GLOBAL.user_id;
  l_login_id		ap_invoices_all.last_update_login%TYPE 	:= FND_GLOBAL.login_id;
  l_sysdate		DATE := sysdate;

  Global_Exception      EXCEPTION; -- bug 7126676

  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_ETAX_UTILITY_PKG';
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
  G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'AP.PLSQL.AP_ETAX_UTILITY_PKG.';

  -- This record type is used for ap_invoice_distributions_all and ap_self_assessed_tax_dist_all

  TYPE r_ins_tax_dist_info IS RECORD (
      accounting_date 			ap_invoice_distributions_all.accounting_date%TYPE,
      dist_code_combination_id		ap_invoice_distributions_all.dist_code_combination_id%TYPE,
      line_type_lookup_code		ap_invoice_distributions_all.line_type_lookup_code%TYPE,
      period_name			ap_invoice_distributions_all.period_name%TYPE,
      amount				ap_invoice_distributions_all.amount%TYPE,
      base_amount			ap_invoice_distributions_all.base_amount%TYPE,
      description			ap_invoice_distributions_all.description%TYPE,
      income_tax_region			ap_invoice_distributions_all.income_tax_region%TYPE,
      po_distribution_id		ap_invoice_distributions_all.po_distribution_id%TYPE,
      type_1099 			ap_invoice_distributions_all.type_1099%TYPE,
      attribute1 			ap_invoice_distributions_all.attribute1%TYPE,
      attribute10 			ap_invoice_distributions_all.attribute10%TYPE,
      attribute11 			ap_invoice_distributions_all.attribute11%TYPE,
      attribute12 			ap_invoice_distributions_all.attribute12%TYPE,
      attribute13 			ap_invoice_distributions_all.attribute13%TYPE,
      attribute14 			ap_invoice_distributions_all.attribute14%TYPE,
      attribute15 			ap_invoice_distributions_all.attribute15%TYPE,
      attribute2 			ap_invoice_distributions_all.attribute2%TYPE,
      attribute3 			ap_invoice_distributions_all.attribute3%TYPE,
      attribute4 			ap_invoice_distributions_all.attribute4%TYPE,
      attribute5 			ap_invoice_distributions_all.attribute5%TYPE,
      attribute6 			ap_invoice_distributions_all.attribute6%TYPE,
      attribute7 			ap_invoice_distributions_all.attribute7%TYPE,
      attribute8 			ap_invoice_distributions_all.attribute8%TYPE,
      attribute9 			ap_invoice_distributions_all.attribute9%TYPE,
      attribute_category 		ap_invoice_distributions_all.attribute_category%TYPE,
      expenditure_item_date		ap_invoice_distributions_all.expenditure_item_date%TYPE,
      expenditure_organization_id	ap_invoice_distributions_all.expenditure_organization_id%TYPE,
      expenditure_type 			ap_invoice_distributions_all.expenditure_type%TYPE,
      parent_invoice_id 		ap_invoice_distributions_all.parent_invoice_id%TYPE,
      pa_addition_flag 			ap_invoice_distributions_all.pa_addition_flag%TYPE,
      pa_quantity 			ap_invoice_distributions_all.pa_quantity%TYPE,
      project_accounting_context	ap_invoice_distributions_all.project_accounting_context%TYPE,
      project_id			ap_invoice_distributions_all.project_id%TYPE,
      task_id 				ap_invoice_distributions_all.task_id%TYPE,
      awt_group_id 			ap_invoice_distributions_all.awt_group_id%TYPE,
      global_attribute_category		ap_invoice_distributions_all.global_attribute_category%TYPE,
      global_attribute1 		ap_invoice_distributions_all.global_attribute1%TYPE,
      global_attribute2 		ap_invoice_distributions_all.global_attribute2%TYPE,
      global_attribute3 		ap_invoice_distributions_all.global_attribute3%TYPE,
      global_attribute4 		ap_invoice_distributions_all.global_attribute4%TYPE,
      global_attribute5 		ap_invoice_distributions_all.global_attribute5%TYPE,
      global_attribute6 		ap_invoice_distributions_all.global_attribute6%TYPE,
      global_attribute7 		ap_invoice_distributions_all.global_attribute7%TYPE,
      global_attribute8 		ap_invoice_distributions_all.global_attribute8%TYPE,
      global_attribute9 		ap_invoice_distributions_all.global_attribute9%TYPE,
      global_attribute10 		ap_invoice_distributions_all.global_attribute10%TYPE,
      global_attribute11 		ap_invoice_distributions_all.global_attribute11%TYPE,
      global_attribute12 		ap_invoice_distributions_all.global_attribute12%TYPE,
      global_attribute13 		ap_invoice_distributions_all.global_attribute13%TYPE,
      global_attribute14 		ap_invoice_distributions_all.global_attribute14%TYPE,
      global_attribute15 		ap_invoice_distributions_all.global_attribute15%TYPE,
      global_attribute16 		ap_invoice_distributions_all.global_attribute16%TYPE,
      global_attribute17 		ap_invoice_distributions_all.global_attribute17%TYPE,
      global_attribute18 		ap_invoice_distributions_all.global_attribute18%TYPE,
      global_attribute19 		ap_invoice_distributions_all.global_attribute19%TYPE,
      global_attribute20 		ap_invoice_distributions_all.global_attribute20%TYPE,
      award_id 				ap_invoice_distributions_all.award_id%TYPE,
      dist_match_type 			ap_invoice_distributions_all.dist_match_type%TYPE,
      rcv_transaction_id 		ap_invoice_distributions_all.rcv_transaction_id%TYPE,
      tax_recoverable_flag		ap_invoice_distributions_all.tax_recoverable_flag%TYPE,
      cancellation_flag 		ap_invoice_distributions_all.cancellation_flag%TYPE,
      invoice_line_number		ap_invoice_distributions_all.invoice_line_number%TYPE,
      corrected_invoice_dist_id		ap_invoice_distributions_all.corrected_invoice_dist_id%TYPE,
      rounding_amt			ap_invoice_distributions_all.rounding_amt%TYPE,
      charge_applicable_to_dist_id	ap_invoice_distributions_all.charge_applicable_to_dist_id%TYPE,
      distribution_class 		ap_invoice_distributions_all.distribution_class%TYPE,
      tax_code_id			ap_invoice_distributions_all.tax_code_id%TYPE,
      detail_tax_dist_id 		ap_invoice_distributions_all.detail_tax_dist_id%TYPE,
      rec_nrec_rate 			ap_invoice_distributions_all.rec_nrec_rate%TYPE,
      recovery_rate_id 			ap_invoice_distributions_all.recovery_rate_id%TYPE,
      recovery_rate_name 		ap_invoice_distributions_all.recovery_rate_name%TYPE,
      recovery_type_code 		ap_invoice_distributions_all.recovery_type_code%TYPE,
      summary_tax_line_id		ap_invoice_distributions_all.summary_tax_line_id%TYPE,
      extra_po_erv 			ap_invoice_distributions_all.extra_po_erv%TYPE,
      taxable_amount 			ap_invoice_distributions_all.taxable_amount%TYPE,
      taxable_base_amount 		ap_invoice_distributions_all.taxable_base_amount%TYPE,
      accrue_on_receipt_flag 		po_distributions_all.accrue_on_receipt_flag%TYPE,
      allow_flex_override_flag		ap_system_parameters_all.allow_flex_override_flag%TYPE,
      purch_encumbrance_flag		financials_system_params_all.purch_encumbrance_flag%TYPE,
      org_id 				ap_invoice_distributions_all.org_id%TYPE,
      tax_regime_id 			zx_rec_nrec_dist.tax_regime_id%TYPE,
      tax_id 				zx_rec_nrec_dist.tax_id%TYPE,
      tax_status_id 			zx_rec_nrec_dist.tax_status_id%TYPE,
      tax_jurisdiction_id 		zx_lines.tax_jurisdiction_id%TYPE,
      parent_dist_cancellation_flag	ap_invoice_distributions_all.cancellation_flag%TYPE,
      parent_dist_reversal_flag		ap_invoice_distributions_all.reversal_flag%TYPE,
      parent_dist_parent_reversal_id	ap_invoice_distributions_all.parent_reversal_id%TYPE,
      reversed_tax_dist_id 		zx_rec_nrec_dist.reversed_tax_dist_id%TYPE,
      adjusted_doc_tax_dist_id 		zx_rec_nrec_dist.adjusted_doc_tax_dist_id%TYPE,
      applied_from_tax_dist_id 		zx_rec_nrec_dist.applied_from_tax_dist_id%TYPE,
      prepay_distribution_id		ap_invoice_distributions_all.prepay_distribution_id%TYPE,
      prepay_tax_diff_amount	        ap_invoice_distributions_all.prepay_tax_diff_amount%TYPE,
      invoice_id			ap_invoice_distributions_all.invoice_id%TYPE,
      batch_id				ap_invoice_distributions_all.batch_id%TYPE,
      set_of_books_id			ap_invoice_distributions_all.set_of_books_id%TYPE,
	  pay_awt_group_id			ap_invoice_distributions_all.pay_awt_group_id%TYPE, --bug8345264
      account_source_tax_rate_id	zx_rec_nrec_dist.account_source_tax_rate_id%TYPE
      );

  PROCEDURE insert_tax_distributions
  			(p_invoice_header_rec        IN ap_invoices_all%ROWTYPE,
			 p_inv_dist_rec              IN r_ins_tax_dist_info,
			 p_dist_code_combination_id  IN NUMBER,
			 p_user_id	             IN NUMBER,
			 p_sysdate	             IN DATE,
			 p_login_id	             IN	NUMBER,
			 p_calling_sequence          IN VARCHAR2);

/*=============================================================================
 |  FUNCTION - Get_Event_Class_Code()
 |
 |  DESCRIPTION
 |      Public function that will get the event class code required to call
 |      the eTax services based on the invoice type.  These event class code is
 |      AP specific.  eTax will convert this event class code to the tax class
 |      code used by eTax.
 |
 |  PARAMETERS
 |      P_Invoice_Type_Lookup_Code - Invoice Type
 |      P_Event_Class_Code - event class code
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    08-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Event_Class_Code(
             P_Invoice_Type_Lookup_Code    IN VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN
  IS

    l_debug_info                 VARCHAR2(2000);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_return_var                 BOOLEAN := TRUE;
    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Event_Class_Code';

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Event_Class_Code<-' ||
                               P_calling_sequence;

    -- The following invoice types are not included to get an event class due to:
    -- AWT and INTEREST: Withholding Tax and Interest invoices do not require
    --                   tax calculation.
    -- QUICKDEFAULT and QUICKMATCH: These defined types for invoices are only
    --                              entry mechanisms.  When the invoice is commit
    --                              the type is STANDARD.

    IF (P_Invoice_Type_Lookup_Code IN ('STANDARD','CREDIT','DEBIT','MIXED',
                                       'ADJUSTMENT','PO PRICE ADJUST',
                                       'INVOICE REQUEST','CREDIT MEMO REQUEST',
                                       'RETAINAGE RELEASE','PAYMENT REQUEST')) THEN   -- for bug 5948586


      P_Event_Class_Code := 'STANDARD INVOICES';

      ------------------------------------------------------------------
      l_debug_info := 'Step 1: Event Class Code is STANDARD INVOICES '||P_Event_Class_Code;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ------------------------------------------------------------------


    ELSIF (P_Invoice_Type_Lookup_Code IN ('PREPAYMENT')) THEN


      P_Event_Class_Code := 'PREPAYMENT INVOICES';

      ------------------------------------------------------------------
      l_debug_info := 'Step 2: Event Class Code is PREPAYMENT INVOICES '||P_Event_Class_Code;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ------------------------------------------------------------------

    ELSIF (P_Invoice_Type_Lookup_Code IN ('EXPENSE REPORT')) THEN

      P_Event_Class_Code := 'EXPENSE REPORTS';

      ------------------------------------------------------------------
      l_debug_info := 'Step 3: Event Class Code is EXPENSE REPORTS '||P_Event_Class_Code;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ------------------------------------------------------------------

    ELSE

      P_Event_Class_Code := NULL;
      l_return_var := FALSE;

      ------------------------------------------------------------------
      l_debug_info := 'Step 4: Event Class Code is NULL and function '||
                      'returns FALSE because eTax is not defined to be '||
                      'called for this Invoice type ';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      ------------------------------------------------------------------

    END IF;

    RETURN l_return_var;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Type_Lookup_Code = '||P_Invoice_Type_Lookup_Code||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Event_Class_Code;


/*=============================================================================
 |  FUNCTION - Get_Event_Type_Code()
 |
 |  DESCRIPTION
 |      Public function that will get the event type code required to call
 |      eTax services based on the event class code, calling_mode and if
 |      eTax was already called or not.
 |
 |  PARAMETERS
 |      P_Event_Class_Code - Event class code
 |      P_Calling_Mode - Calling mode
 |      P_eTax_Already_called_flag - Is eTax already called?
 |      P_Event_Type_Code - event type code
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    09-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/

  FUNCTION Get_Event_Type_Code(
             P_Event_Class_Code            IN VARCHAR2,
             P_Calling_Mode                IN VARCHAR2,
             P_eTax_Already_called_flag    IN VARCHAR2,
             P_Event_Type_Code             OUT NOCOPY VARCHAR2,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN

  IS

    l_debug_info                 VARCHAR2(2000);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_class_section              VARCHAR2(500);
    l_action_section             VARCHAR2(500);

    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Event_Type_Code';

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Event_Type_Code<-' ||
                               P_calling_sequence;

    --  There are 3 different event classes defined for AP to handle tax in 11ix.
    --  They are: STANDARD INVOICES, PREPAYMENT INVOICES and EXPENSE REPORTS.
    --  There are different event type codes per event type and event class due to
    --  a requirement of SLA.  The event type code should be unique per product.
    --  So, we can say the event type code is composed of 2 sections:
    --  The class section (STANDARD, PREPAYMENT or EXPENSE REPORT) and the
    --  action section that determines the action ocurred to the class
    --  (CREATE, UPDATE, CANCELLED, FROZEN, etc).

    ------------------------------------------------------------------
    l_debug_info := 'Step 1: Event Class Code is: '||p_event_class_code;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ------------------------------------------------------------------

    IF ( P_Event_Class_Code = 'STANDARD INVOICES' ) THEN
      l_class_section := 'STANDARD ';

    ELSIF ( P_Event_Class_Code = 'PREPAYMENT INVOICES' ) THEN
      l_class_section := 'PREPAYMENT ';

    ELSIF ( P_Event_Class_Code = 'EXPENSE REPORTS' ) THEN
      l_class_section := 'EXPENSE REPORT ';

    END IF;

    ------------------------------------------------------------------
    l_debug_info := 'Step 2: Calling mode is: '||p_calling_mode;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ------------------------------------------------------------------
    IF ( p_calling_mode IN
         ('CALCULATE', 'CALCULATE QUOTE', 'APPLY PREPAY',
          'UNAPPLY PREPAY', 'RECOUPMENT','DISCARD LINE')) THEN  --Bug8811102
      IF ( P_eTax_Already_called_flag = 'N' ) THEN
        l_action_section := 'CREATED';
      ELSE
        l_action_section := 'UPDATED';

      END IF;

    ELSIF ( p_calling_mode IN ('CALCULATE IMPORT', 'VALIDATE IMPORT',
                               'IMPORT INTERFACE')) THEN
      l_action_section := 'CREATED';

    ELSIF ( p_calling_mode IN ('DISTRIBUTE', 'DISTRIBUTE RECOUP') ) THEN
      IF ( P_eTax_Already_called_flag = 'N' ) THEN
         l_action_section := 'DISTRIBUTE';

      ELSE
         l_action_section := 'REDISTRIBUTE';

      END IF;

    ELSIF ( p_calling_mode = 'DISTRIBUTE IMPORT' ) THEN
      l_action_section := 'DISTRIBUTE';

    ELSIF ( p_calling_mode = 'REVERSE INVOICE' ) THEN
      l_action_section := 'FULLY REVERSED';

    ELSIF ( p_calling_mode = 'OVERRIDE TAX' ) THEN
      l_action_section := 'OVERRIDE TAX';

    ELSIF ( p_calling_mode = 'OVERRIDE RECOVERY' ) THEN
      l_action_section := 'OVERRIDE DIST';

    ELSIF ( p_calling_mode = 'CANCEL INVOICE' ) THEN
      l_action_section := 'CANCELLED TAX';

    ELSIF ( p_calling_mode = 'FREEZE INVOICE' ) THEN
      l_action_section := 'FROZEN';

    ELSIF ( p_calling_mode = 'UNFREEZE INVOICE' ) THEN
      l_action_section := 'UNFROZEN';

    ELSIF ( p_calling_mode = 'RELEASE TAX HOLDS' ) THEN
      l_action_section := 'HOLDS RELEASED';

    ELSIF ( p_calling_mode
              IN ('MARK TAX LINES DELETED', 'FREEZE DISTRIBUTIONS')) THEN
      l_action_section := 'UPDATED';

    ELSIF ( p_calling_mode = 'VALIDATE' ) THEN
      l_action_section := 'VALIDATED TAX';

    /*Introduced this condition for the bug 7388641 */
    ELSIF ( p_calling_mode = 'DELETE INVOICE' ) THEN
      l_action_section := 'PURGED';

    END IF;

    -- Construct the code from the class and action sections
    p_event_type_code := l_class_section||l_action_section;

    ------------------------------------------------------------------
    l_debug_info := 'Step 3: Event Type Code: '||p_event_type_code;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    ------------------------------------------------------------------

    RETURN(TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Event_Class_Code = '||P_Event_Class_Code||
          ' P_Calling_Mode ='||P_Calling_Mode||
          ' P_eTax_Already_called_flag ='||P_eTax_Already_called_flag||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Event_Type_Code;

/*=============================================================================
 |  FUNCTION - Get_Corrected_Invoice_Info()
 |
 |  DESCRIPTION
 |      This function return the additional information required to populate
 |      the zx_transaction_lines_gt global temporary table for eTax.
 |
 |  PARAMETERS
 |      P_Corrected_Invoice_Id - Invoice Id for the corrected line
 |      P_corrected_Line_number - Line number for the corrected line
 |      P_Application_Id - Application Id for the corrected invoice
 |      P_Entity_code - entity code required for the event class
 |      P_Event_Class_Code - Event class code for the corrected invoice
 |      P_Invoice_Number - Corrected invoice number
 |      P_Invoice_Date - corrected invoice date
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    13-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Corrected_Invoice_Info(
             P_Corrected_Invoice_Id        IN NUMBER,
             P_Corrected_Line_Number       IN NUMBER,
             P_Application_Id              OUT NOCOPY NUMBER,
             P_Entity_code                 OUT NOCOPY VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_Invoice_Number              OUT NOCOPY VARCHAR2,
             P_Invoice_Date                OUT NOCOPY DATE,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN VARCHAR2) RETURN BOOLEAN

  IS

    l_debug_info                 VARCHAR2(2000);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_corrected_invoice_type     ap_invoices_all.invoice_type_lookup_code%TYPE;

    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Corrected_Invoice_Info';


    CURSOR corrected_inv( c_corrected_inv_id IN NUMBER) IS
    SELECT invoice_num, invoice_date, invoice_type_lookup_code
      FROM ap_invoices_all
     WHERE invoice_id = c_corrected_inv_id;

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Corrected_Invoice_Info<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get corrected invoice info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    IF ( P_Corrected_Invoice_Id IS NOT NULL) THEN

      P_Application_Id := 200; -- Oracle Payables
      P_Entity_code := 'AP_INVOICES';

      BEGIN
        OPEN corrected_inv (P_Corrected_Invoice_Id);
        FETCH corrected_inv
          INTO P_Invoice_Number, P_Invoice_Date,
               l_corrected_invoice_type;
        CLOSE corrected_inv;
      END ;
    -------------------------------------------------------------------
    l_debug_info := 'Step 1.1: Corrected Inv Id Info '||P_Invoice_Number||' & '||P_Invoice_Date||' & '||l_corrected_invoice_type;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
      --------------------------------------------------------------------------
      l_debug_info := 'Step 2: Get event class code corrected_invoice_id';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      --------------------------------------------------------------------------
      IF NOT(AP_ETAX_UTILITY_PKG.Get_Event_Class_Code(
        P_Invoice_Type_Lookup_Code => l_corrected_invoice_type,
        P_Event_Class_Code         => P_Event_Class_Code,
        P_error_code               => P_error_code,
        P_calling_sequence         => l_curr_calling_sequence)) THEN

        RETURN FALSE;
      END IF;

    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Corrected_Invoice_Id = '||P_Corrected_Invoice_Id||
          ' P_Corrected_Line_Number = '||P_Corrected_Line_Number||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Corrected_Invoice_Info;

/*=============================================================================
 |  FUNCTION - Get_Prepay_Invoice_Info()
 |
 |  DESCRIPTION
 |      This function return the additional information required to populate
 |      the zx_transaction_lines_gt global temporary table for eTax.
 |
 |  PARAMETERS
 |      P_Prepay_Invoice_Id - Invoice Id for the applied prepay line
 |      P_Prepay_Line_number - Line number for the applied prepay line
 |      P_Application_Id - Application Id for the applied prepay invoice
 |      P_Entity_code - entity code required for the event class
 |      P_Event_Class_Code - Event class code for the applied prepay invoice
 |      P_Invoice_Number - Applied Prepayment number
 |      P_Invoice_Date - Applied prepayment invoice date
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/

  FUNCTION Get_Prepay_Invoice_Info(
             P_Prepay_Invoice_Id        IN  NUMBER,
             P_Prepay_Line_Number       IN  NUMBER,
             P_Application_Id           OUT NOCOPY NUMBER,
             P_Entity_code              OUT NOCOPY VARCHAR2,
             P_Event_Class_Code         OUT NOCOPY VARCHAR2,
             P_Invoice_Number           OUT NOCOPY VARCHAR2,
             P_Invoice_Date             OUT NOCOPY DATE,
             P_Error_Code               OUT NOCOPY VARCHAR2,
             P_Calling_Sequence         IN  VARCHAR2) RETURN BOOLEAN
  IS

    l_debug_info                 VARCHAR2(2000);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_prepay_invoice_type        ap_invoices_all.invoice_type_lookup_code%TYPE;

    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Prepay_Invoice_Info';

    CURSOR prepay_inv (c_prepay_inv_id IN NUMBER) IS
    SELECT invoice_num, invoice_date, invoice_type_lookup_code
      FROM ap_invoices_all
     WHERE invoice_id = c_prepay_inv_id;

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Prepay_Invoice_Info<-' ||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get applied prepayment invoice info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    IF ( P_Prepay_Invoice_Id IS NOT NULL) THEN

      P_Application_Id := 200;
      P_Entity_code    := 'AP_INVOICES';

      BEGIN
        OPEN  prepay_inv (P_Prepay_Invoice_Id);
        FETCH prepay_inv
         INTO P_Invoice_Number, P_Invoice_Date,
              l_prepay_invoice_type;
        CLOSE prepay_inv;
      END ;
    -------------------------------------------------------------------
    l_debug_info := 'Step 1.1: Applied prepayment invoice info '||P_Invoice_Number||' & '||P_Invoice_Date||' & '||l_prepay_invoice_type;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
      --------------------------------------------------------------------------
      l_debug_info := 'Step 2: Get event class code prepay_invoice_id';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      --------------------------------------------------------------------------
      IF NOT(AP_ETAX_UTILITY_PKG.Get_Event_Class_Code(
        P_Invoice_Type_Lookup_Code => l_prepay_invoice_type,
        P_Event_Class_Code         => P_Event_Class_Code,
        P_error_code               => P_error_code,
        P_calling_sequence         => l_curr_calling_sequence)) THEN

        RETURN FALSE;
      END IF;

    END IF;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Prepay_Invoice_Id = '||P_Prepay_Invoice_Id||
          ' P_Prepay_Line_Number = '||P_Prepay_Line_Number||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Prepay_Invoice_Info;

/*=============================================================================
 |  FUNCTION - Get_Receipt_Info()
 |
 |  DESCRIPTION
 |      This function return the additional information required to populate
 |      the zx_transaction_lines_gt global temporary table for eTax.
 |
 |  PARAMETERS
 |      P_Rcv_Transaction_Id - Receipt id
 |      P_Application_Id - Application Id for the Receipt (201)
 |      P_Entity_code - entity code required for the event class
 |      P_Event_Class_Code - Event class code for the receipt
 |      P_Transaction_Date - Transaction date
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Receipt_Info(
             P_Rcv_Transaction_Id          IN  NUMBER,
             P_Application_Id              OUT NOCOPY NUMBER,
             P_Entity_code                 OUT NOCOPY VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_Transaction_Date            OUT NOCOPY DATE,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN  VARCHAR2) RETURN BOOLEAN
  IS

    l_debug_info                 VARCHAR2(2000);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_return_status              VARCHAR2(100);
    l_msg_count                  NUMBER;
    l_msg_data                   VARCHAR2(2000);

    l_transaction_type           rcv_transactions.transaction_type%TYPE;

    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Receipt_Info';

    CURSOR receipt_info (c_rcv_transaction IN NUMBER) IS
    SELECT transaction_date, transaction_type
      FROM rcv_transactions
     WHERE transaction_id = c_rcv_transaction;

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Receipt_Info<-' ||
                               P_calling_sequence;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;
    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get receipt info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    IF (P_Rcv_Transaction_Id IS NOT NULL) THEN

      OPEN  receipt_info (P_Rcv_Transaction_Id);
      FETCH receipt_info
       INTO P_Transaction_Date, l_transaction_type;
      CLOSE receipt_info;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1.1: Receipt info '||P_Transaction_Date||' & '||l_transaction_type;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

      --------------------------------------------------------------------------
      l_debug_info := 'Step 2: Call PO API to get additional receipt info';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      --------------------------------------------------------------------------
      CST_UTILITY_PUB.Get_Receipt_Event_Info (
			  p_api_version      => 1.0 ,
			  p_transaction_type => 'MATCH',
			  x_return_status    => l_return_status,
			  x_msg_count        => l_msg_count,
			  x_msg_data         => l_msg_data,
			  p_entity_code      => p_entity_code,
			  p_application_id   => p_application_id,
			  p_event_class_code => p_event_class_code);

    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Rcv_Transaction_Id = '||P_Rcv_Transaction_Id||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Receipt_Info;

/*=============================================================================
 |  FUNCTION - Get_PO_Info()
 |
 |  DESCRIPTION
 |      This function return the additional information required to populate
 |      the zx_transaction_lines_gt and the zx_distribution_lines_gt global
 |      temporary tables for eTax.
 |      The parameters po_line_location_id and po_distribution_id are mutual
 |      exclusive.
 |
 |  PARAMETERS
 |      P_Po_line_location_id - PO line location
 |      P_Po_Distribution_id - Po distribution
 |      P_Application_Id - Application Id for the PO document (201)
 |      P_Entity_code - entity code required for the event class
 |      P_Event_Class_Code - Event class code for the PO doc
 |      P_PO_Quantity - PO quantity
 |      P_Product_Org_Id - Product Org_id
 |      P_Po_Header_Id - Po header Id
 |      P_Po_Header_Curr_Conv_Rate - Po Header currency conversion rate
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |    20-OCT-2003   SYIDNER        Included po_distribution as a parameter
 |                                 and modify the function to return Po data
 |                                 for the call to the determine_recovery serv
 *============================================================================*/
  FUNCTION Get_PO_Info(
             P_PO_Line_Location_Id         IN  OUT NOCOPY NUMBER,
             P_Po_Distribution_Id          IN  NUMBER,
             P_Application_Id              OUT NOCOPY NUMBER,
             P_Entity_code                 OUT NOCOPY VARCHAR2,
             P_Event_Class_Code            OUT NOCOPY VARCHAR2,
             P_PO_Quantity                 OUT NOCOPY NUMBER,
             P_Product_Org_Id              OUT NOCOPY NUMBER,
             P_Po_Header_Id                OUT NOCOPY NUMBER,
             P_Po_Header_Curr_Conv_Rate    OUT NOCOPY NUMBER,
	         P_Uom_Code			   OUT NOCOPY VARCHAR2,
	         P_Dist_Qty			   OUT NOCOPY NUMBER,
	         P_Ship_Price		   OUT NOCOPY NUMBER,
             P_Error_Code                  OUT NOCOPY VARCHAR2,
             P_Calling_Sequence            IN  VARCHAR2) RETURN BOOLEAN

  IS

    l_debug_info                 VARCHAR2(2000);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_return_status 		 VARCHAR2(100);
    l_msg_count			 NUMBER;
    l_msg_data 			 VARCHAR2(2000);

    l_org_id			 po_line_locations_all.org_id%type;
    l_po_release_id		 po_line_locations_all.po_release_id%type;
    l_doc_type			 VARCHAR2(20);

    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_PO_Info';

    CURSOR PO_Info_from_line_loc (c_po_line_location_Id IN NUMBER) IS
    SELECT pll.org_id, pll.quantity, pll.po_header_id, nvl(ph.rate ,1), pll.po_release_id, mum.uom_code
      FROM po_line_locations_all pll, po_headers_all ph, mtl_units_of_measure mum
     WHERE pll.line_location_id = c_po_line_location_Id
       AND pll.po_header_id = ph.po_header_id
       AND pll.unit_meas_lookup_code = mum.unit_of_measure (+);

    CURSOR PO_Info_from_dist (c_po_dist_Id IN NUMBER) IS
    SELECT pll.org_id, pll.quantity, pll.line_location_id,
           pll.po_header_id, nvl(ph.rate,1), pll.po_release_id, mum.uom_code,
	   pd.quantity_ordered, pll.price_override
      FROM po_line_locations_all pll, po_distributions_all pd,
           po_headers_all ph, mtl_units_of_measure mum
     WHERE pd.po_distribution_id = c_po_dist_Id
       AND pd.line_location_id = pll.line_location_id
       AND pll.po_header_id = ph.po_header_id
       AND pll.unit_meas_lookup_code = mum.unit_of_measure (+);

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_PO_Info<-' ||
                               P_calling_sequence;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get PO additional info';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    IF ( P_PO_Line_Location_Id IS NOT NULL) THEN
        OPEN  PO_info_from_line_loc (P_PO_Line_Location_Id);
        FETCH PO_info_from_line_loc
         INTO l_org_Id, P_PO_Quantity,
              P_Po_Header_Id, P_Po_header_curr_conv_rate, l_po_release_id, p_uom_code;
        CLOSE PO_info_from_line_loc;

        -------------------------------------------------------------------
        l_debug_info := 'Step 1.1: PO additional info '||l_org_Id||' & '||P_PO_Quantity||' & '||P_Po_Header_Id||' &' ||P_Po_header_curr_conv_rate ||' & '||l_po_release_id||' & '||p_uom_code ;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        -------------------------------------------------------------------

    ELSIF ( P_PO_Distribution_Id IS NOT NULL) THEN
        OPEN  PO_info_from_dist (P_PO_Distribution_Id);
        FETCH PO_info_from_dist
         INTO l_org_id, P_PO_Quantity, P_PO_Line_Location_Id,
              P_Po_Header_Id, P_Po_header_curr_conv_rate, l_po_release_id, p_uom_code,
	      P_Dist_Qty, P_Ship_Price;
        CLOSE PO_info_from_dist;

        -------------------------------------------------------------------
        l_debug_info := 'Step 1.1: PO additional info '||l_org_Id||' & '||P_PO_Quantity||' & '||P_PO_Line_Location_Id||' & '||P_Po_Header_Id||' &' ||P_Po_header_curr_conv_rate ||' & '||l_po_release_id||' & '||p_uom_code ;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        -------------------------------------------------------------------



    END IF;

    IF NOT AP_ETAX_SERVICES_PKG.g_fsp_attributes.exists(l_org_id) THEN

       SELECT inventory_organization_id
         INTO AP_ETAX_SERVICES_PKG.g_fsp_attributes(l_org_id).inventory_organization_id
         FROM financials_system_params_all
        WHERE org_id = l_org_id;

    END IF;

    p_product_org_id := AP_ETAX_SERVICES_PKG.g_fsp_attributes(l_org_id).inventory_organization_id;

    -------------------------------------------------------------------
    l_debug_info := 'Step 2: Product Org Id '||p_product_org_id;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    -- Bug 5193570
    -- Set ref_doc_trx_id to po_release_id when matched to a Release.

    IF l_po_release_id IS NOT NULL THEN
	p_po_header_id := l_po_release_id;
	l_doc_type     := 'RELEASE';

    -------------------------------------------------------------------
    l_debug_info := 'Step 3: p_po_header_id and  l_doc_type '||p_po_header_id||' & '||l_doc_type;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    ELSE
        l_doc_type     := 'PO';

        -------------------------------------------------------------------
        l_debug_info := 'Step 3: l_doc_type '||l_doc_type;
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        -------------------------------------------------------------------

    END IF;




    PO_TAX_INTERFACE_GRP.get_document_tax_constants(
    	p_api_version 		=> 1.0,
		p_init_msg_list		=> NULL,
		p_commit		=> 'N',
		p_validation_level	=> NULL,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data,
		p_doc_type		=> l_doc_type,
		x_application_id	=> p_application_id,
		x_entity_code		=> p_entity_code,
		x_event_class_code	=> p_event_class_code );

    -------------------------------------------------------------------
    l_debug_info := 'Step 4: Calling PO API to get PO etax document '||
                    ' setup info '||l_doc_type||' & '||p_application_id||' & '||p_entity_code||' & '||p_event_class_code;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_PO_Line_Location_Id = '||P_PO_Line_Location_Id||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_PO_Info;

/*=============================================================================
 |  FUNCTION - Get_Prepay_Awt_Group_Id()
 |
 |  DESCRIPTION
 |      This function return the awt_group_id for a parent prepay item line
 |      based on the prepayment distribution id.
 |
 |  PARAMETERS
 |      P_Prepay_Distribution_id - Distribution Id of the prepayment
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Prepay_Awt_Group_Id(
             P_Prepay_Distribution_id    IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN NUMBER
  IS

    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Prepay_Awt_Group_Id';

    CURSOR prepay_awt_group_id (c_prepay_dist_id IN NUMBER) IS
    SELECT aid.awt_group_id
      FROM ap_invoice_distributions_all aid
          -- ,ap_invoice_lines_all ail
     WHERE aid.invoice_distribution_id = c_prepay_dist_id;
      -- AND aid.invoice_id = ail.invoice_id
      -- AND aid.invoice_line_number = ail.line_number;
      --Bug8334059 Awt_group_id will be retrieved from ap_invoice_distributions_all

    l_awt_group_id     ap_invoice_lines_all.awt_group_id%TYPE;

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Prepay_Awt_Group_Id<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;


    OPEN  prepay_awt_group_id( P_Prepay_Distribution_id);
    FETCH prepay_awt_group_id
    INTO  l_awt_group_id;
    CLOSE prepay_awt_group_id;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get awt_group_id from prepay item line '||l_awt_group_id;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    RETURN l_awt_group_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Prepay_Distribution_id = '||P_Prepay_Distribution_id||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF ( prepay_awt_group_id%ISOPEN ) THEN
        CLOSE prepay_awt_group_id;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
  END Get_Prepay_Awt_Group_Id;

/*=============================================================================
 |  FUNCTION - Return_Tax_Lines()
 |
 |  DESCRIPTION
 |      This function handles the return of tax lines.  It includes creation,
 |      update, or delete of existing exclusive tax lines in AP if required.
 |      It also handles the update of the total tax amounts. (Inclusive and
 |      self-assessed.
 |
 |  PARAMETERS
 |      P_Invoice_Header_Rec - Header info
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    15-OCT-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Tax_Lines(
             P_Invoice_Header_Rec        IN ap_invoices_all%ROWTYPE,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN
  IS

    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);

    l_period_name                gl_period_statuses.period_name%TYPE;
    l_gl_date                    ap_invoice_lines_all.accounting_date%TYPE;
    l_wfapproval_flag		     ap_system_parameters_all.approval_workflow_flag%TYPE;
    l_awt_include_tax_amt        ap_system_parameters_all.awt_include_tax_amt%TYPE;
    l_base_currency_code         ap_system_parameters_all.base_currency_code%TYPE;
    l_combined_filing_flag       ap_system_parameters_all.combined_filing_flag%TYPE;
    l_income_tax_region_flag     ap_system_parameters_all.income_tax_region_flag%TYPE;
    l_income_tax_region          ap_system_parameters_all.income_tax_region%TYPE;
    l_disc_is_inv_less_tax_flag	 ap_system_parameters_all.disc_is_inv_less_tax_flag%TYPE;
    l_wfapproval_status          ap_invoice_lines_all.wfapproval_status%TYPE;
    l_new_amt_applicable_to_disc ap_invoices_all.amount_applicable_to_discount%TYPE;
    l_payment_priority           ap_batches_all.payment_priority%TYPE;

    l_total_tax_amount          NUMBER;
    l_self_assessed_tax_amt     NUMBER;

    -- Allocations
    Cursor c_item_line (c_invoice_id IN NUMBER) IS
	Select ail.line_number
	From   ap_invoice_lines_all ail
	Where  ail.invoice_id = c_invoice_id
        And    ail.line_type_lookup_code = 'TAX'
        And    ail.prepay_invoice_id IS NULL;

        /*
	And NOT EXISTS
		(Select chrg_invoice_line_number
		 From ap_allocation_rule_lines arl
          	 Where arl.invoice_id = ail.invoice_id
            	 And arl.chrg_invoice_line_number = ail.line_number);
        */

    l_item_line	     c_item_line%rowtype;

    l_ap_summary_tax_line_id    NUMBER;
    l_invoice_line_number       NUMBER;

    l_api_name                  CONSTANT VARCHAR2(100) := 'RETURN_TAX_LINES';

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Return_Tax_Lines<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;

     -------------------------------------------------------------------
     l_debug_info := 'Incorrect Summary Tax Line Check';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     -------------------------------------------------------------------

     BEGIN

     l_ap_summary_tax_line_id := NULL;

     SELECT ail.line_number, ail.summary_tax_line_id
       INTO l_invoice_line_number, l_ap_summary_tax_line_id
       FROM AP_INVOICE_LINES_ALL ail
      WHERE ail.invoice_id            = P_Invoice_Header_Rec.invoice_id
        AND ail.line_type_lookup_code = 'TAX'
        AND NOT EXISTS
            (SELECT ls.summary_tax_line_id
               FROM zx_lines_summary ls
              WHERE ls.summary_tax_line_id             = ail.summary_tax_line_id
                AND ls.trx_id                          = ail.invoice_id
                AND NVL(ls.tax_amt_included_flag, 'N') = 'N'
                AND NVL(ls.self_assessed_flag, 'N')    = 'N'
                AND NVL(ls.reporting_only_flag, 'N')   = 'N'
            )
        AND EXISTS
            (SELECT 'Invoice Distributions Exist'
               FROM ap_invoice_distributions_all aid
              WHERE aid.invoice_id          = ail.invoice_id
                AND aid.invoice_line_number = ail.line_number
                AND (aid.accounting_event_id IS NOT NULL
                     OR NVL(aid.match_status_flag,'N') IN ('A','T')
                     OR aid.bc_event_id IS NOT NULL
                     OR NVL(aid.encumbered_flag, 'N') IN ('Y','D','W','X')
                    ) --This is done for Mexicana Bug7623255 to avoid such Data Fix Condition
            )
        AND EXISTS
            (SELECT zl.summary_tax_line_id
               FROM zx_lines_summary zl
              WHERE zl.application_id                = 200
                AND zl.entity_code                   = 'AP_INVOICES'
                AND zl.event_class_code             IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
                AND zl.trx_id                        = ail.invoice_id
                AND zl.tax_regime_code               = ail.tax_regime_code
                AND zl.tax                           = ail.tax
                AND zl.tax_status_code               = ail.tax_status_code
                AND (zl.tax_rate_code                = ail.tax_rate_code
                     OR zl.tax_rate_id               = ail.tax_rate_id)
                AND (zl.tax_jurisdiction_code        = ail.tax_jurisdiction_code
                     OR zl.tax_jurisdiction_code    IS NULL)
                AND zl.tax_rate                      = ail.tax_rate
                AND zl.tax_amt			 = ail.amount
                AND NVL(zl.reporting_only_flag, 'N') = 'N'
                AND NVL(zl.self_assessed_flag, 'N')  = 'N'
                AND NVL(zl.cancel_flag, 'N')         = NVL(ail.cancelled_flag,'N')
                AND zl.summary_tax_line_id          <> ail.summary_tax_line_id
           )
       AND rownum = 1;

       --Bug 7485573 -- Move the exception block above the if condition.

       EXCEPTION
          WHEN NO_DATA_FOUND THEN
               NULL;

          WHEN OTHERS THEN
	       NULL;
    END;

     IF l_ap_summary_tax_line_id IS NOT NULL THEN

               -------------------------------------------------------------------
               l_debug_info := 'Invoice Line Number that causes this failure: '||l_invoice_line_number;
               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
               END IF;

               l_debug_info := 'Summary Tax Line ID for this line: '||l_ap_summary_tax_line_id;
               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
               END IF;
               -------------------------------------------------------------------
	       /* Bug 9777752
               FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	           FND_MESSAGE.SET_TOKEN('ERROR', 'Summary Tax Line Deleted by EBTax. This would cause orphan distributions.');
	           FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
	           FND_MESSAGE.SET_TOKEN('PARAMETERS',
	            ' P_Invoice_Id = '||P_Invoice_Header_Rec.invoice_id||
	            ' P_Error_Code = '||P_Error_Code||
	            ' P_Calling_Sequence = '||P_Calling_Sequence);
	           FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
	       */
               FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_SUM_TAX_LINE_DEL' ); -- Bug 9777752

	       --Bug9395593

               IF AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID IS NULL THEN
                  APP_EXCEPTION.RAISE_EXCEPTION;
               ELSE
                  RETURN FALSE;
               END IF;

               --Bug9395593


    END IF;


    -------------------------------------------------------------------
    l_debug_info := 'Get ap_system_parameters data';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    BEGIN
      SELECT
          approval_workflow_flag,
          awt_include_tax_amt,
          disc_is_inv_less_tax_flag,
          base_currency_code,
          combined_filing_flag,
          income_tax_region_flag,
          income_tax_region
        INTO
          l_wfapproval_flag,
          l_awt_include_tax_amt,
          l_disc_is_inv_less_tax_flag,
          l_base_currency_code,
          l_combined_filing_flag,
          l_income_tax_region_flag,
          l_income_tax_region
        FROM ap_system_parameters_all
       WHERE org_id = P_Invoice_Header_Rec.org_id;
    END;

    -------------------------------------------------------------------
    l_debug_info := 'Update existing exclusive tax lines';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    BEGIN
      UPDATE ap_invoice_lines_all ail
         SET
       (ail.description,
        ail.amount,
        ail.base_amount,
        ail.discarded_flag,  --Bug9346774 Changed From Canceled_flag to discarded_flag
        ail.last_updated_by,
        ail.last_update_login,
        ail.last_update_date,
        ail.tax_regime_code,
        ail.tax,
        ail.tax_jurisdiction_code,
        ail.tax_status_code,
        ail.tax_rate_id,
        ail.tax_rate_code,
        ail.tax_rate,
	ail.generate_dists) =
	(
      SELECT
        DECODE( ail.line_source,
		'MANUAL LINE ENTRY', ail.description,
		'IMPORTED'         , ail.description,
                zls.tax_regime_code||' - '||zls.tax ),          -- description : Bug 9383712 - Added DECODE
        zls.tax_amt, 						-- amount
        zls.tax_amt_funcl_curr,					-- base_amount
        zls.cancel_flag,					-- cancelled_flag
        l_user_id,						-- last_updated_by
        l_login_id,						-- last_update_login
        l_sysdate, 						-- last_update_date
        zls.tax_regime_code,	    				-- tax_regime_code
        zls.tax,		    				-- tax
        zls.tax_jurisdiction_code,  				-- tax_jurisdiction_code
        zls.tax_status_code,	    				-- tax_status_code
        zls.tax_rate_id,	    				-- tax_rate_id
        zls.tax_rate_code,	    				-- tax_rate_code
        zls.tax_rate, 		    				-- tax_rate
	DECODE(ail.generate_dists,'D','D','Y')		        -- generate_dists  bug 5460342
        FROM zx_lines_summary zls
       WHERE zls.summary_tax_line_id		= ail.summary_tax_line_id
         AND nvl(zls.reporting_only_flag, 'N')	= 'N'
       )
       WHERE ail.invoice_id = P_Invoice_Header_Rec.invoice_id
	 AND ail.line_type_lookup_code	= 'TAX'
         AND EXISTS
	       	    (SELECT ls.summary_tax_line_id
                       FROM zx_lines_summary ls
                      WHERE ls.summary_tax_line_id		= ail.summary_tax_line_id
                        AND ls.trx_id				= ail.invoice_id
                        AND NVL(ls.tax_amt_included_flag, 'N')	= 'N'
                        AND NVL(ls.self_assessed_flag, 'N')	= 'N'
                        AND NVL(ls.reporting_only_flag, 'N')	= 'N');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_Invoice_Id = '||P_Invoice_Header_Rec.Invoice_Id||
            ' P_Error_Code = '||P_Error_Code||
            ' P_Calling_Sequence = '||P_Calling_Sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
    END;

    /* Start for bug 5943074-- updating summary_tax_line_id of ap_invoice_lines_all based on zx_lines
       for manual tax lines and tax only lines so that we do not delete and regenerate the tax lines . */
    -------------------------------------------------------------------
    l_debug_info := 'Update summary tax line id for manual tax lines';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    BEGIN

      UPDATE ap_invoice_lines_all ail
      SET ail.summary_tax_line_id = (SELECT  zl.summary_tax_line_id
                                            FROM zx_lines zl
                                            WHERE zl.application_id 	 =  200
                                            AND zl.entity_code 	 =  'AP_INVOICES'
                                            AND zl.event_class_code IN
					        ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
                                            AND zl.trx_id 	= ail.invoice_id
                                            AND zl.tax_regime_code = ail.tax_regime_code
                                            AND zl.tax = ail.tax
                                            AND zl.tax_status_code = ail.tax_status_code
                                            AND (zl.tax_rate_code = ail.tax_rate_code OR zl.tax_rate_id = ail.tax_rate_id)
					    AND (zl.tax_jurisdiction_code = ail.tax_jurisdiction_code OR zl.tax_jurisdiction_code IS NULL)
                                            AND zl.tax_rate = ail.tax_rate
                                            AND zl.manually_entered_flag = 'Y'
                                            AND nvl(zl.reporting_only_flag, 'N') = 'N'
					    AND nvl(zl.self_assessed_flag, 'N') = 'N'
					    AND nvl(zl.cancel_flag, 'N') = nvl(ail.cancelled_flag,'N')
                                            AND zl.proration_code = 'REGULAR_IMPORT' --Bug8524286
                                            AND rownum = 1       )
      WHERE ail.invoice_id = P_Invoice_Header_Rec.invoice_id
      AND ail.line_type_lookup_code	= 'TAX'
      AND ail.line_source in ('MANUAL LINE ENTRY','IMPORTED')
      AND ail.summary_tax_line_id IS NULL
      AND NOT EXISTS
           (SELECT 1
              FROM ap_invoice_lines_all ail2
             WHERE ail2.invoice_id = ail.invoice_id
               AND ail2.line_number <> ail.line_number
               AND ail2.tax_regime_code = ail.tax_regime_code
               AND ail2.tax = ail.tax
               AND ail2.tax_status_code = ail.tax_status_code
               AND (ail2.tax_rate_code = ail.tax_rate_code OR ail2.tax_rate_id = ail.tax_rate_id)
	       AND (ail2.tax_jurisdiction_code = ail.tax_jurisdiction_code OR ail2.tax_jurisdiction_code IS NULL)
               AND ail2.tax_rate = ail.tax_rate
               AND ail2.line_type_lookup_code = 'TAX'
               AND ail2.line_source in ('MANUAL LINE ENTRY','IMPORTED')
               AND ail2.line_group_number IS NOT NULL
               AND ail2.prorate_across_all_items='Y');    --Bug7331216

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
            NULL;

       WHEN OTHERS THEN
            IF (SQLCODE <> -20001) THEN
               FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
               FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
               FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
               FND_MESSAGE.SET_TOKEN('PARAMETERS',' P_Invoice_Id = '||P_Invoice_Header_Rec.Invoice_Id
                                                  ||' P_Error_Code = '||P_Error_Code
                                                  ||' P_Calling_Sequence = '||P_Calling_Sequence);
               FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
            END IF;
            APP_EXCEPTION.RAISE_EXCEPTION;
    END;
    /* End for bug 5943074 */

    -------------------------------------------------------------------
    l_debug_info := 'Delete exclusive tax lines if required';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    BEGIN
      DELETE ap_invoice_lines_all ail
       WHERE ail.invoice_id = P_Invoice_Header_Rec.invoice_id
         AND ail.line_type_lookup_code = 'TAX'
         AND NOT EXISTS (SELECT ls.summary_tax_line_id
                           FROM zx_lines_summary ls
                          WHERE ls.summary_tax_line_id  = ail.summary_tax_line_id
                            AND ls.trx_id               = ail.invoice_id
                            AND NVL(ls.tax_amt_included_flag, 'N') = 'N'
                            AND NVL(ls.self_assessed_flag,    'N') = 'N'
                            AND NVL(ls.reporting_only_flag,   'N') = 'N');
-- Bug 7260087 Starts
-- When ever invoice line is deleted corresponding
-- allocations should  be deleted.
      DELETE FROM ap_allocation_rules ar
       WHERE ar.invoice_id = p_invoice_header_rec.invoice_id
         AND NOT EXISTS
                 (SELECT 'y'
                  FROM ap_invoice_lines_all l
                  WHERE l.invoice_id = ar.invoice_id
                  AND l.line_number = ar.chrg_invoice_line_number);

       DELETE FROM ap_allocation_rule_lines arl
        WHERE arl.invoice_id = p_invoice_header_rec.invoice_id
          AND NOT EXISTS
                  (SELECT 'y'
                   FROM ap_invoice_lines_all l
                   WHERE l.invoice_id = arl.invoice_id
                   AND l.line_number = arl.chrg_invoice_line_number);
-- Bug 7260087 ends

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_Invoice_Id = '||P_Invoice_Header_Rec.invoice_id||
            ' P_Error_Code = '||P_Error_Code||
            ' P_Calling_Sequence = '||P_Calling_Sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
    END;

    -------------------------------------------------------------------
    l_debug_info := 'Get open gl_date';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    l_period_name := AP_UTILITIES_PKG.get_current_gl_date (P_Invoice_Header_Rec.gl_date, P_Invoice_header_Rec.org_id);

    IF (l_period_name IS NULL) THEN
	AP_UTILITIES_PKG.get_open_gl_date(
	       P_Date                  => P_Invoice_Header_Rec.gl_date,
	       P_Period_Name           => l_period_name,
	       P_GL_Date               => l_gl_date,
	       P_Org_Id                => P_Invoice_Header_Rec.org_id);
    ELSE
	l_gl_date := P_Invoice_Header_Rec.gl_date;
    END IF;

    IF NVL(l_wfapproval_flag,'N') = 'Y' THEN
      l_wfapproval_status := 'REQUIRED';
    ELSE
      l_wfapproval_status := 'NOT REQUIRED';
    END IF;

    -------------------------------------------------------------------
    l_debug_info := 'Insert exclusive tax lines';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    BEGIN
      INSERT INTO ap_invoice_lines_all (
        invoice_id,
        line_number,
        line_type_lookup_code,
        requester_id,
        description,
        line_source,
        org_id,
        line_group_number,
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
        creation_date,
        created_by,
        last_updated_by,
        last_update_date,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
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
        control_amount,
        assessable_value,
        total_rec_tax_amount,
        total_nrec_tax_amount,
        total_rec_tax_amt_funcl_curr,
        total_nrec_tax_amt_funcl_curr,
        included_tax_amount,
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
        tax_code_id,
		pay_awt_group_id)  --Bug8345264
      SELECT
        P_Invoice_Header_Rec.Invoice_Id,				-- invoice_id
        (SELECT NVL(MAX(ail2.line_number),0)
           FROM ap_invoice_lines_all ail2
          WHERE ail2.invoice_id =  zls.trx_id) + ROWNUM,  		-- line_number
        'TAX',								-- line_type_lookup_code
        null,								-- requester_id
        zls.tax_regime_code||' - '||zls.tax,				-- description
        'ETAX',								-- line_source
        P_Invoice_Header_Rec.org_id,   					-- org_id
        null,   							-- line_group_number
        null,   							-- inventory_item_id
        null,   							-- item_description
        null,   							-- serial_number
        null,   							-- manufacturer
        null,   							-- model_number
        null,   							-- warranty_number
        DECODE(NVL(zls.tax_only_line_flag, 'N'),
               'Y', 'D',
               'Y'),   							-- generate_dists
        DECODE(zls.applied_to_trx_id,
               null, 'NOT_MATCHED',
               'OTHER_TO_RECEIPT'),   					-- match_type
        null,   							-- distribution_set_id
        null,   							-- account_segment
        null,   							-- balancing_segment
        null,   							-- cost_center_segment
        null,   							-- overlay_dist_code_concat
        null,   							-- default_dist_ccid
        'N',   								-- prorate_across_all_items
        l_gl_date,   							-- accounting_date
        DECODE(NVL(zls.tax_only_line_flag, 'N'),
               'N', DECODE(zls.applied_to_trx_id,
                           null, null, l_period_name),
                l_period_name),   					-- period_name
        'N',   								-- deferred_acctg_flag
        null,   							-- def_acctg_start_date
        null,   							-- def_acctg_end_date
        null,   							-- def_acctg_number_of_periods
        null,   							-- def_acctg_period_type
        P_Invoice_Header_Rec.set_of_books_id,   			-- set_of_books_id
        zls.tax_amt,   							-- amount
        DECODE(P_Invoice_Header_Rec.invoice_currency_code,
               l_base_currency_code, NULL,
               zls.tax_amt_funcl_curr),    				-- base_amount
        null,   							-- rounding_amt
        null,   							-- quantity_invoiced
        null,   							-- unit_meas_lookup_code
        null,   							-- unit_price
        l_wfapproval_status,   						-- wfapproval_status
        'N',   								-- discarded_flag
        null,   							-- original_amount
        null,   							-- original_base_amount
        null,   							-- original_rounding_amt
        'N',   								-- cancelled_flag
        DECODE(ap.type_1099,
               '','',
               DECODE(l_combined_filing_flag,
                      'N', '',
                      DECODE(l_income_tax_region_flag,
                             'Y', aps.state,
                             l_income_tax_region))),  			-- income_tax_region
        ap.type_1099,   						-- type_1099
        null,   							-- stat_amount
        zls.applied_from_trx_id,   					-- prepay_invoice_id
        zls.applied_from_line_id,   					-- prepay_line_number
        prepay.invoice_includes_prepay_flag,   				-- invoice_includes_prepay_flag
        zls.adjusted_doc_trx_id,   					-- corrected_inv_id
        -- zls.adjusted_doc_line_id,   					-- corrected_line_number
        null,								-- corrected_line_number
        null,   							-- po_header_id
        null,   							-- po_line_id
        null,   							-- po_release_id
        null,   							-- po_line_location_id
        null,   							-- po_distribution_id
        zls.applied_to_trx_id,						-- rcv_transaction_id
        'N',   								-- final_match_flag
        null,   							-- assets_tracking_flag
        null,   							-- asset_book_type_code
        null,   							-- asset_category_id
        null,   							-- project_id
        null,   							-- task_id
        null,   							-- expenditure_type
        null,   							-- expenditure_item_date
        null,   							-- expenditure_organization_id
        null,   							-- pa_quantity
        null,   							-- pa_cc_ar_invoice_id
        null,   							-- pa_cc_ar_invoice_line_num
        null,   							-- pa_cc_processed_code
        null,   							-- award_id
	null,                                                           -- awt_group_id -- bug9035846
  /*	DECODE(l_awt_include_tax_amt,
               'N', null,
               DECODE(zls.applied_from_trx_id,
                      null, P_Invoice_Header_Rec.awt_group_id,
                      prepay.awt_group_id)),   				-- awt_group_id  */
        null,   							-- reference_1
        null,   							-- reference_2
        null,   							-- receipt_verified_flag
        null,   							-- receipt_required_flag
        null,   							-- receipt_missing_flag
        null,   							-- justification
        null,   							-- expense_group
        null,   							-- start_expense_date
        null,   							-- end_expense_date
        null,   							-- receipt_currency_code
        null,   							-- receipt_conversion_rate
        null,   							-- receipt_currency_amount
        null,   							-- daily_amount
        null,   							-- web_parameter_id
        null,   							-- adjustment_reason
        null,   							-- merchant_document_number
        null,   							-- merchant_name
        null,   							-- merchant_reference
        null,   							-- merchant_tax_reg_number
        null,								-- merchant_taxpayer_id
        null,								-- country_of_supply
        null,								-- credit_card_trx_id
        null,								-- company_prepaid_invoice_id
        null,								-- cc_reversal_flag
        l_sysdate,							-- creation_date
        l_user_id,   							-- created_by
        l_user_id,   							-- last_updated_by
        l_sysdate,   							-- last_update_date
        l_login_id,   							-- last_update_login
        null,   							-- program_application_id
        null,   							-- program_id
        null,   							-- program_update_date
        null,   							-- request_id
        zls.attribute_category,   					-- attribute_category
        zls.attribute1,   						-- attribute1
        zls.attribute2,   						-- attribute2
        zls.attribute3,   						-- attribute3
        zls.attribute4,   						-- attribute4
        zls.attribute5,   						-- attribute5
        zls.attribute6,   						-- attribute6
        zls.attribute7,   						-- attribute7
        zls.attribute8,   						-- attribute8
        zls.attribute9,   						-- attribute9
        zls.attribute10,   						-- attribute10
        zls.attribute11,   						-- attribute11
        zls.attribute12,   						-- attribute12
        zls.attribute13,   						-- attribute13
        zls.attribute14,   						-- attribute14
        zls.attribute15,   						-- attribute15
        zls.global_attribute_category,   				-- global_attribute_category
        zls.global_attribute1,   					-- global_attribute1
        zls.global_attribute2,   					-- global_attribute2
        zls.global_attribute3,   					-- global_attribute3
        zls.global_attribute4,   					-- global_attribute4
        zls.global_attribute5,   					-- global_attribute5
        zls.global_attribute6,   					-- global_attribute6
        zls.global_attribute7,   					-- global_attribute7
        zls.global_attribute8,   					-- global_attribute8
        zls.global_attribute9,   					-- global_attribute9
        zls.global_attribute10,   					-- global_attribute10
        zls.global_attribute11,   					-- global_attribute11
        zls.global_attribute12,   					-- global_attribute12
        zls.global_attribute13,   					-- global_attribute13
        zls.global_attribute14,   					-- global_attribute14
        zls.global_attribute15,   					-- global_attribute15
        zls.global_attribute16,   					-- global_attribute16
        zls.global_attribute17,   					-- global_attribute17
        zls.global_attribute18,   					-- global_attribute18
        zls.global_attribute19,   					-- global_attribute19
        zls.global_attribute20,   					-- global_attribute20
        null,   							-- control_amount
        null,   							-- assessable_value
        null,   							-- total_rec_tax_amount
        null,   							-- total_nrec_tax_amount
        null,   							-- total_rec_tax_amt_funcl_curr
        null,   							-- total_nrec_tax_amt_funcl_curr
        null,   							-- included_tax_amount
        null,   							-- primary_intended_use
        null,   							-- ship_to_location_id
        null,   							-- product_type
        null,   							-- product_category
        null,   							-- product_fisc_classification
        null,   							-- user_defined_fisc_class
        null,   							-- trx_business_category
        zls.summary_tax_line_id,   					-- summary_tax_line_id
        zls.tax_regime_code,   						-- tax_regime_code
        zls.tax,   							-- tax
        zls.tax_jurisdiction_code,   					-- tax_jurisdiction_code
        zls.tax_status_code,   						-- tax_status_code
        zls.tax_rate_id,   						-- tax_rate_id
        zls.tax_rate_code,   						-- tax_rate_code
        zls.tax_rate,   						-- tax_rate
        null,   							-- tax_code_id
        null								-- pay_awt_group_id -- bug9035846
/*		DECODE(l_awt_include_tax_amt,
               'N', null,
               DECODE(zls.applied_from_trx_id,
                      null, P_Invoice_Header_Rec.pay_awt_group_id,
                      prepay.pay_awt_group_id))   		-- pay_awt_group_id  Bug8345264 */
     FROM ap_invoices_all       ai,
          ap_suppliers          ap,
          ap_supplier_sites_all aps,
          zx_lines_summary      zls,
          ap_invoice_lines_all  prepay
    WHERE ai.invoice_id				= p_invoice_header_rec.invoice_id
      AND ai.vendor_id                          = ap.vendor_id
      AND ai.vendor_site_id                     = aps.vendor_site_id
      AND zls.application_id 			= 200
      AND zls.entity_code 			= 'AP_INVOICES'
      AND zls.event_class_code			IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
      AND zls.trx_id 				= ai.invoice_id
      AND NVL(zls.tax_amt_included_flag, 'N') 	= 'N'
      AND NVL(zls.self_assessed_flag, 'N') 	= 'N'
      AND NVL(zls.reporting_only_flag, 'N') 	= 'N'
      AND zls.applied_from_trx_id  		= prepay.invoice_id(+)
      AND zls.applied_from_line_id 		= prepay.line_number(+)
      AND NOT EXISTS (SELECT il.summary_tax_line_id
                        FROM ap_invoice_lines_all il
                       WHERE il.invoice_id = ai.invoice_id
                         AND il.summary_tax_line_id = zls.summary_tax_line_id)
      AND EXISTS
          (SELECT 'Recoupment Exists'
           FROM    ZX_LINES ZL
           WHERE   ZL.application_id      = ZLS.application_id
           AND     ZL.entity_code         = ZLS.entity_code
           AND     ZL.event_class_code    = ZLS.event_class_code
           AND     ZL.trx_id              = ZLS.trx_id
           AND     ((nvl(ZL.tax_only_line_flag,'N') <> 'Y'
                     and sign(ZL.TRX_LINE_ID)       <> -1)
                    OR nvl(ZL.tax_only_line_flag,'N') = 'Y')
           AND     ZL.SUMMARY_TAX_LINE_ID = ZLS.SUMMARY_TAX_LINE_ID);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_Invoice_Id = '||P_Invoice_Header_Rec.invoice_id||
            ' P_Error_Code = '||P_Error_Code||
            ' P_Calling_Sequence = '||P_Calling_Sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
    END;

    -------------------------------------------------------------------
    l_debug_info := 'Update Inclusive tax amount';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    BEGIN
    --bug 6931461
      UPDATE ap_invoice_lines_all ail
         SET ail.included_tax_amount =
             (SELECT /*+ index(ZL ZX_LINES_U1) */SUM(NVL(zl.tax_amt, 0))
                FROM zx_lines zl
               WHERE zl.application_id 	 =  200
                 AND zl.entity_code 	 =  'AP_INVOICES'
		 AND zl.event_class_code IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
                 AND zl.trx_id 		= ail.invoice_id
                 AND zl.trx_line_id 	= ail.line_number
                 AND NVL(zl.self_assessed_flag,    'N')	= 'N'
                 AND NVL(zl.reporting_only_flag,   'N') = 'N'
                 AND NVL(zl.tax_amt_included_flag, 'N') = 'Y')
       WHERE ail.invoice_id = P_Invoice_Header_Rec.invoice_id
         AND ail.line_type_lookup_code NOT IN ('TAX', 'AWT');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_Invoice_Id = '||P_Invoice_Header_Rec.invoice_id||
            ' P_Error_Code = '||P_Error_Code||
            ' P_Calling_Sequence = '||P_Calling_Sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
    END;

    --------------------------------------------------
    l_debug_info := 'Create Tax Allocations';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    --------------------------------------------------
    BEGIN
	OPEN c_item_line(P_Invoice_Header_Rec.invoice_id);
	LOOP
	   FETCH c_item_line
	    INTO l_item_line;
	   EXIT WHEN c_item_line%notfound;

	   IF NOT AP_ALLOCATION_RULES_PKG.insert_tax_allocations (
				          P_Invoice_Header_Rec.invoice_id,
				          L_Item_Line.line_number,
				          P_error_code ) THEN
	      NULL;
	   END IF;
	END LOOP;
	CLOSE c_item_line;
    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
            				' P_Invoice_Id		= '||P_Invoice_Header_Rec.invoice_id||
					' P_Error_Code		= '||P_Error_Code||
					' P_Calling_Sequence 	= '||P_Calling_Sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,sqlerrm);
        END IF;

        IF ( c_item_line%ISOPEN ) THEN
             CLOSE c_item_line;
        END IF;

        APP_EXCEPTION.RAISE_EXCEPTION;
    END;

    -------------------------------------------------------------------
    l_debug_info := 'Update total_tax_amount and self_assessed tax';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

      /*Bug 8638881 added CASE in the below SQL to consider the case of invoice includes prepay*/
    BEGIN
      UPDATE ap_invoices_all ai
          SET (ai.total_tax_amount,
               ai.self_assessed_tax_amount) =
                   (SELECT SUM(DECODE(NVL(zls.self_assessed_flag, 'N'),
                            'N', case when exists (SELECT 'Prepay App Exists'
                                          FROM ap_invoice_lines_all prepay
                                         WHERE prepay.invoice_id = zls.trx_id
                                         AND prepay.line_type_lookup_code = 'PREPAY'
                                         AND prepay.prepay_invoice_id  = zls.applied_from_trx_id
                                         AND prepay.prepay_line_number = zls.applied_from_line_id
                                         AND prepay.invoice_includes_prepay_flag = 'Y'
                                         AND (prepay.discarded_flag is null
                                           or prepay.discarded_flag = 'N')) THEN
                                           0
                                        ELSE NVL(zls.tax_amt, 0) end,
                                       0)),
                        SUM(DECODE(NVL(zls.self_assessed_flag, 'N'),
                                   'Y', NVL(zls.tax_amt, 0),
                                    0))
                   FROM zx_lines_summary zls
            WHERE zls.application_id = 200
           AND zls.entity_code = 'AP_INVOICES'
           AND zls.event_class_code IN
              ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
                  AND zls.trx_id   = ai.invoice_id
                  AND NVL(zls.reporting_only_flag, 'N') = 'N')
        WHERE ai.invoice_id = P_Invoice_Header_Rec.invoice_id
        RETURNING ai.total_tax_amount, ai.self_assessed_tax_amount
             INTO l_total_tax_amount, l_self_assessed_tax_amt;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_Invoice_Id = '||P_Invoice_Header_Rec.invoice_id||
            ' P_Error_Code = '||P_Error_Code||
            ' P_Calling_Sequence = '||P_Calling_Sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
    END;

    -----------------------------------------------------------------
    l_debug_info := 'Update tax_already_calculated_flag';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -----------------------------------------------------------------
    BEGIN
      UPDATE ap_invoice_lines_all ail
         SET ail.tax_already_calculated_flag = 'Y'
       WHERE ail.invoice_id = P_invoice_header_rec.invoice_id
         AND ail.line_type_lookup_code NOT IN ('TAX', 'AWT')
         AND NVL(ail.tax_already_calculated_flag, 'N') = 'N';

      /* Bug 5013526: We will set tax_already_calculated_flag to 'Y' even if tax lines are
		      not generated. User could change any of the tax determining attributes
		      on the invoice invoice line and resubmit tax calculation. In this case
		      we would need to pass event_type as UPDATED.
         AND EXISTS
             ( SELECT zl.tax_line_id
                 FROM zx_lines zl
                WHERE zl.trx_id = ail.invoice_id
                  AND zl.trx_line_id = ail.line_number
                  AND zl.application_id = 200
                  AND zl.entity_code = 'AP_INVOICES'
                  AND nvl(zl.reporting_only_flag, 'N') = 'N');
      */

    EXCEPTION
      WHEN no_data_found THEN
        null;
    END;

    -----------------------------------------------------------------
    l_debug_info := 'Update Invoice Includes Prepay Flag';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -----------------------------------------------------------------

    /*added the case for bug 8638881*/
   UPDATE ap_invoice_lines_all tax
     SET tax.invoice_includes_prepay_flag = CASE WHEN EXISTS (SELECT 'Prepay App Exists'
                            FROM ap_invoice_lines_all prepay
                           WHERE prepay.invoice_id = tax.invoice_id
                             AND prepay.line_type_lookup_code = 'PREPAY'
                             AND prepay.prepay_invoice_id = tax.prepay_invoice_id
                             AND prepay.prepay_line_number = tax.prepay_line_number
                             AND prepay.invoice_includes_prepay_flag = 'Y'
                             AND (prepay.discarded_flag is null or
                                 prepay.discarded_flag = 'N')) THEN
                               'Y'
                            ELSE
                              'N'
                            END /*added the case for bug 8638881*/
 WHERE tax.invoice_id = P_Invoice_Header_Rec.Invoice_Id
   AND tax.line_type_lookup_code = 'TAX'
   AND tax.prepay_invoice_id is not null;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          			' P_Invoice_Id = '      ||P_Invoice_Header_Rec.Invoice_Id||
          			' P_Error_Code = '      ||P_Error_Code||
          			' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Return_Tax_Lines;


/*=============================================================================
 |  FUNCTION - Return_Tax_Distributions()
 |
 |  DESCRIPTION
 |      This function handles the return of tax distributions.  It includes
 |      creation, update, or delete of existing distributions and TIPV and
 |      TERV distributions if required.
 |      It also handles the creation, update or delete of self-assessed
 |      distributions.
 |
 |  PARAMETERS
 |      P_Invoice_Header_Rec - Header info
 |      P_All_Error_Messages - Should API return 1 error message or allow
 |                             calling point to get them from message stack
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    23-OCT-2003   SYIDNER        Created
 |    05-MAR-2004   SYIDNER        Included changes for returning of tax
 |                                 distributions related to prepayment
 |                                 application distributions (PREPAY)
 |                                 In this case only the primary distribution
 |                                 should be created for the total value of
 |                                 the distribution (same as eTax.) No tax
 |                                 variances will be created for PREPAY type
 |                                 distributions
 *============================================================================*/

  FUNCTION Return_Tax_Distributions(
             P_Invoice_Header_Rec        IN  ap_invoices_all%ROWTYPE,
             P_All_Error_Messages        IN  VARCHAR2,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN  VARCHAR2) RETURN BOOLEAN
  IS

    l_debug_info		VARCHAR2(2000);
    l_curr_calling_sequence	VARCHAR2(4000);
    l_api_name			CONSTANT VARCHAR2(100) := 'RETURN_TAX_DISTRIBUTIONS';

    l_dist_ccid_rec		zx_api_pub.distccid_det_facts_rec_type;
    l_dist_count		NUMBER;

    --Bug9021265
    l_frozen_tax_dist_id   NUMBER;
    l_frozen_summary_tax_line_id  NUMBER;
    --Bug9021265

    -- This record type is used for ap_invoice_distributions_all and ap_self_assessed_tax_dist_all

    TYPE r_upd_tax_dist_info IS RECORD (
      accounting_date 			ap_invoice_distributions_all.accounting_date%TYPE,
      dist_code_combination_id		ap_invoice_distributions_all.dist_code_combination_id%TYPE,
      line_type_lookup_code		ap_invoice_distributions_all.line_type_lookup_code%TYPE,
      period_name 			ap_invoice_distributions_all.period_name%TYPE,
      amount 				ap_invoice_distributions_all.amount%TYPE,
      base_amount 			ap_invoice_distributions_all.base_amount%TYPE,
      description 			ap_invoice_distributions_all.description%TYPE,
      income_tax_region 		ap_invoice_distributions_all.income_tax_region%TYPE,
      type_1099 			ap_invoice_distributions_all.type_1099%TYPE,
      attribute1 			ap_invoice_distributions_all.attribute1%TYPE,
      attribute10 			ap_invoice_distributions_all.attribute10%TYPE,
      attribute11 			ap_invoice_distributions_all.attribute11%TYPE,
      attribute12 			ap_invoice_distributions_all.attribute12%TYPE,
      attribute13 			ap_invoice_distributions_all.attribute13%TYPE,
      attribute14 			ap_invoice_distributions_all.attribute14%TYPE,
      attribute15 			ap_invoice_distributions_all.attribute15%TYPE,
      attribute2 			ap_invoice_distributions_all.attribute2%TYPE,
      attribute3 			ap_invoice_distributions_all.attribute3%TYPE,
      attribute4 			ap_invoice_distributions_all.attribute4%TYPE,
      attribute5 			ap_invoice_distributions_all.attribute5%TYPE,
      attribute6 			ap_invoice_distributions_all.attribute6%TYPE,
      attribute7 			ap_invoice_distributions_all.attribute7%TYPE,
      attribute8 			ap_invoice_distributions_all.attribute8%TYPE,
      attribute9 			ap_invoice_distributions_all.attribute9%TYPE,
      attribute_category 		ap_invoice_distributions_all.attribute_category%TYPE,
      expenditure_item_date		ap_invoice_distributions_all.expenditure_item_date%TYPE,
      expenditure_organization_id	ap_invoice_distributions_all.expenditure_organization_id%TYPE,
      expenditure_type 			ap_invoice_distributions_all.expenditure_type%TYPE,
      parent_invoice_id 		ap_invoice_distributions_all.parent_invoice_id%TYPE,
      pa_addition_flag 			ap_invoice_distributions_all.pa_addition_flag%TYPE,
      pa_quantity 			ap_invoice_distributions_all.pa_quantity%TYPE,
      project_accounting_context	ap_invoice_distributions_all.project_accounting_context%TYPE,
      project_id 			ap_invoice_distributions_all.project_id%TYPE,
      task_id 				ap_invoice_distributions_all.task_id%TYPE,
      awt_group_id 			ap_invoice_distributions_all.awt_group_id%TYPE,
      global_attribute_category		ap_invoice_distributions_all.global_attribute_category%TYPE,
      global_attribute1 		ap_invoice_distributions_all.global_attribute1%TYPE,
      global_attribute2 		ap_invoice_distributions_all.global_attribute2%TYPE,
      global_attribute3 		ap_invoice_distributions_all.global_attribute3%TYPE,
      global_attribute4 		ap_invoice_distributions_all.global_attribute4%TYPE,
      global_attribute5 		ap_invoice_distributions_all.global_attribute5%TYPE,
      global_attribute6 		ap_invoice_distributions_all.global_attribute6%TYPE,
      global_attribute7 		ap_invoice_distributions_all.global_attribute7%TYPE,
      global_attribute8 		ap_invoice_distributions_all.global_attribute8%TYPE,
      global_attribute9 		ap_invoice_distributions_all.global_attribute9%TYPE,
      global_attribute10 		ap_invoice_distributions_all.global_attribute10%TYPE,
      global_attribute11 		ap_invoice_distributions_all.global_attribute11%TYPE,
      global_attribute12 		ap_invoice_distributions_all.global_attribute12%TYPE,
      global_attribute13 		ap_invoice_distributions_all.global_attribute13%TYPE,
      global_attribute14 		ap_invoice_distributions_all.global_attribute14%TYPE,
      global_attribute15 		ap_invoice_distributions_all.global_attribute15%TYPE,
      global_attribute16 		ap_invoice_distributions_all.global_attribute16%TYPE,
      global_attribute17 		ap_invoice_distributions_all.global_attribute17%TYPE,
      global_attribute18 		ap_invoice_distributions_all.global_attribute18%TYPE,
      global_attribute19 		ap_invoice_distributions_all.global_attribute19%TYPE,
      global_attribute20 		ap_invoice_distributions_all.global_attribute20%TYPE,
      award_id 				ap_invoice_distributions_all.award_id%TYPE,
      dist_match_type 			ap_invoice_distributions_all.dist_match_type%TYPE,
      rcv_transaction_id 		ap_invoice_distributions_all.rcv_transaction_id%TYPE,
      tax_recoverable_flag		ap_invoice_distributions_all.tax_recoverable_flag%TYPE,
      cancellation_flag 		ap_invoice_distributions_all.cancellation_flag%TYPE,
      invoice_line_number		ap_invoice_distributions_all.invoice_line_number%TYPE,
      corrected_invoice_dist_id		ap_invoice_distributions_all.corrected_invoice_dist_id%TYPE,
      rounding_amt 			ap_invoice_distributions_all.rounding_amt%TYPE,
      charge_applicable_to_dist_id	ap_invoice_distributions_all.charge_applicable_to_dist_id%TYPE,
      distribution_class 		ap_invoice_distributions_all.distribution_class%TYPE,
      tax_code_id 			ap_invoice_distributions_all.tax_code_id%TYPE,
      detail_tax_dist_id 		ap_invoice_distributions_all.detail_tax_dist_id%TYPE,
      rec_nrec_rate 			ap_invoice_distributions_all.rec_nrec_rate%TYPE,
      recovery_rate_id 			ap_invoice_distributions_all.recovery_rate_id%TYPE,
      recovery_rate_name		ap_invoice_distributions_all.recovery_rate_name%TYPE,
      recovery_type_code 		ap_invoice_distributions_all.recovery_type_code%TYPE,
      taxable_amount 			ap_invoice_distributions_all.taxable_amount%TYPE,
      taxable_base_amount 		ap_invoice_distributions_all.taxable_base_amount%TYPE,
      summary_tax_line_id		ap_invoice_distributions_all.summary_tax_line_id%TYPE,
      extra_po_erv			ap_invoice_distributions_all.extra_po_erv%TYPE ,
      prepay_tax_diff_amount		ap_invoice_distributions_all.prepay_tax_diff_amount%TYPE,
      invoice_distribution_id		ap_invoice_distributions_all.invoice_distribution_id%TYPE,
	  pay_awt_group_id			ap_invoice_distributions_all.pay_awt_group_id%TYPE, --Bug8345264
      account_source_tax_rate_id	zx_rec_nrec_dist.account_source_tax_rate_id%TYPE);


    TYPE ins_tax_dist_type IS TABLE OF r_ins_tax_dist_info;
    TYPE upd_tax_dist_type IS TABLE OF r_upd_tax_dist_info;
    TYPE del_tax_dist_type IS TABLE OF ap_invoice_distributions_all.invoice_distribution_id%TYPE;

    l_inv_dist_ins		ins_tax_dist_type;
    l_inv_self_ins		ins_tax_dist_type;

    l_inv_dist_upd		upd_tax_dist_type;
    l_inv_self_upd		upd_tax_dist_type;

    l_inv_dist_del		del_tax_dist_type;
    l_inv_self_del		del_tax_dist_type;


    CURSOR insert_tax_dist IS
      SELECT /*+ leading(gt,zd) cardinality(gt,1) */
         zd.gl_date accounting_date , --Bug6809792
         /*For tax distributions accounting date will be stamped from zx_rec_nrec_dist
           Ebtax will now store accounting date of opne period in their table*/
         decode(NVL(zl.tax_only_line_flag,'N'),
                               'Y',parent_tax_line.default_dist_ccid,
                                parent_taxable_dist.dist_code_combination_id) 			dist_code_combination_id, ---for 6010950
        -- this ccid is a temporary value that will be used if other
        -- conditions are met before inserting the tax distribution.
        DECODE(NVL(zd.recoverable_flag, 'N'),
               'Y', 'REC_TAX',
               'N', 'NONREC_TAX') 					line_type_lookup_code,
        ap_utilities_pkg.get_gl_period_name(zd.gl_date,ai.org_id)	period_name,
        -- included the decode as part of the prepayment changes.
        -- since for prepayment tax variances will not be created,
        -- the dist amount should be the total including variances
-- bug 8317515: modify start
        DECODE(parent_item_line.line_type_lookup_code,
               'PREPAY', zd.rec_nrec_tax_amt,
               decode(parent_taxable_dist.line_type_lookup_code, 'PREPAY', zd.rec_nrec_tax_amt,
               decode(nvl(zd.recoverable_flag,'N'),
			  'Y', zd.rec_nrec_tax_amt,
				NVL(zd.rec_nrec_tax_amt, 0) -
                            get_tv(zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt,
						    nvl(zd.ref_doc_per_unit_nrec_tax_amt,0), zd.per_trx_curr_unit_nr_amt,
						    zd.ref_per_trx_curr_unit_nr_amt, zd.price_diff, parent_tax_line.corrected_inv_id,
						    parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, ai.invoice_currency_code,
						    parent_item_line.match_type, zd.unit_price)))) amount, -- bug 9231678
        ap_utilities_pkg.ap_round_currency(
        DECODE(parent_item_line.line_type_lookup_code,
		'PREPAY', zd.rec_nrec_tax_amt_funcl_curr,
                decode(parent_taxable_dist.line_type_lookup_code, 'PREPAY', zd.rec_nrec_tax_amt_funcl_curr,
                decode(nvl(zd.recoverable_flag,'N'),
		       'Y', zd.rec_nrec_tax_amt_funcl_curr,
			     NVL(zd.rec_nrec_tax_amt_funcl_curr, 0) -
				    (get_tv_base
					(zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt, nvl(zd.ref_doc_per_unit_nrec_tax_amt,0),
					 zd.per_trx_curr_unit_nr_amt, zd.ref_per_trx_curr_unit_nr_amt, nvl(zd.currency_conversion_rate, 1),
					 zd.ref_doc_curr_conv_rate, zd.price_diff, parent_tax_line.corrected_inv_id,
					 parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, asp.base_currency_code,
					 parent_item_line.match_type, zd.unit_price)+
				     get_terv
					(zd.trx_line_dist_qty, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate, zd.applied_to_doc_curr_conv_rate,
					 NULL, zd.per_unit_nrec_tax_amt, nvl(zd.ref_doc_per_unit_nrec_tax_amt,zd.per_unit_nrec_tax_amt),
					 parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code, parent_tax_line.line_source,
					 asp.base_currency_code))))),
					 asp.base_currency_code) base_amount, -- bug 9231678
-- bug 8317515: modify end
        -- included the decode as part of the prepayment changes.
        -- since for prepayments tax variances will not be created,
        -- the base_amount should be the total including variances
        DECODE(NVL(zd.inclusive_flag, 'N'),
		'Y', parent_item_line.description,
		'N', parent_tax_line.description) 				description,
        DECODE(NVL(zd.inclusive_flag, 'N'),
		'Y', DECODE(parent_item_line.type_1099,
			    NULL, NULL,
			    parent_item_line.income_tax_region),
         	'N', DECODE(parent_tax_line.type_1099,
                	    NULL, NULL,
			    parent_tax_line.income_tax_region))			income_tax_region,
         parent_taxable_dist.po_distribution_id 			po_distribution_id,  --change for bug 8713009
	                                                             -- now rec_tax dist will also have po_dist_id stamped on it
        DECODE(NVL(zd.inclusive_flag, 'N'),
		'Y', parent_item_line.type_1099,
		'N', parent_tax_line.type_1099) 				type_1099,
        zd.attribute1 								attribute1,
        zd.attribute10 								attribute10,
        zd.attribute11 								attribute11,
        zd.attribute12 								attribute12,
        zd.attribute13 								attribute13,
        zd.attribute14 								attribute14,
        zd.attribute15 								attribute15,
        zd.attribute2 								attribute2,
        zd.attribute3 								attribute3,
        zd.attribute4 								attribute4,
        zd.attribute5 								attribute5,
        zd.attribute6 								attribute6,
        zd.attribute7 								attribute7,
        zd.attribute8 								attribute8,
        zd.attribute9 								attribute9,
        zd.attribute_category 							attribute_category,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.expenditure_item_date)			expenditure_item_date,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.expenditure_organization_id)		expenditure_organization_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.expenditure_type) 			expenditure_type,
        parent_taxable_dist.parent_invoice_id 					parent_invoice_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', 'E',
         	'N', parent_taxable_dist.pa_addition_flag) 			pa_addition_flag,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', NULL,
         	'N', parent_taxable_dist.pa_quantity) pa_quantity,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', NULL,
         	'N', parent_taxable_dist.project_accounting_context)		project_accounting_context,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.project_id)				project_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.task_id) 				task_id,
        DECODE(NVL(asp.allow_awt_flag, 'N'),
               'Y', DECODE(NVL(pvs.allow_awt_flag, 'N'),
                      'Y',  DECODE(parent_tax_line.awt_group_id,
				            null,DECODE(NVL(asp.awt_include_tax_amt, 'N'),
                                   'Y', DECODE(NVL(zd.inclusive_flag, 'N'),
                                          'Y', DECODE(zd.applied_from_tax_dist_id,
                                                null, parent_taxable_dist.awt_group_id,  --Bug8334059
                                                ap_etax_utility_pkg.Get_Prepay_Awt_Group_Id(
                                                parent_taxable_dist.prepay_distribution_id,
                                                P_Calling_Sequence)),
                                          'N', parent_taxable_dist.awt_group_id),
								  NULL),
					        parent_tax_line.awt_group_id), --Bug6648050 --bug 9035846  -- bug9117319
									--Bug8334059
                      NULL),
               NULL) 								awt_group_id,
	      --Bug6505640 Populating DFF's from Invoice distributions instead of Tax dists
		parent_taxable_dist.global_attribute_category 						global_attribute_category,
		parent_taxable_dist.global_attribute1 							global_attribute1,
		parent_taxable_dist.global_attribute2 							global_attribute2,
		parent_taxable_dist.global_attribute3 							global_attribute3,
		parent_taxable_dist.global_attribute4 							global_attribute4,
		parent_taxable_dist.global_attribute5 							global_attribute5,
		parent_taxable_dist.global_attribute6 							global_attribute6,
		parent_taxable_dist.global_attribute7 							global_attribute7,
		parent_taxable_dist.global_attribute8 							global_attribute8,
		parent_taxable_dist.global_attribute9 							global_attribute9,
		parent_taxable_dist.global_attribute10 							global_attribute10,
		parent_taxable_dist.global_attribute11 							global_attribute11,
		parent_taxable_dist.global_attribute12 							global_attribute12,
		parent_taxable_dist.global_attribute13 							global_attribute13,
		parent_taxable_dist.global_attribute14 							global_attribute14,
		parent_taxable_dist.global_attribute15 							global_attribute15,
		parent_taxable_dist.global_attribute16 							global_attribute16,
		parent_taxable_dist.global_attribute17 							global_attribute17,
		parent_taxable_dist.global_attribute18 							global_attribute18,
		parent_taxable_dist.global_attribute19 							global_attribute19,
		parent_taxable_dist.global_attribute20 							global_attribute20,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.award_id) 				award_id,
        DECODE(zd.ref_doc_dist_id,
		NULL, DECODE(zl.applied_to_trx_id,
              			NULL, 'NOT_MATCHED',
              			'OTHER_TO_RECEIPT'),
		'NOT_MATCHED') 							dist_match_type,
         DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
        --Bug 8910531
         	'N', parent_taxable_dist.rcv_transaction_id) 			rcv_transaction_id,
        zd.recoverable_flag 							tax_recoverable_flag,
        parent_taxable_dist.cancellation_flag 					cancellation_flag,
        DECODE(NVL(zd.inclusive_flag, 'N'),
		'Y', zd.trx_line_id,
		'N', nvl(parent_tax_line.line_number,
                         parent_taxable_dist.invoice_line_number)) 		invoice_line_number,
        parent_taxable_dist.corrected_invoice_dist_id 				corrected_invoice_dist_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		zd.func_curr_rounding_adjustment) 				rounding_amt,
        -- the rounding amount in the non-recoverable case will be populated
        -- to the primary distribution later in the cycle.
        decode(NVL(zl.tax_only_line_flag,'N'),
                     'Y', NULL, zd.trx_line_dist_id)				charge_applicable_to_dist_id,
        DECODE(zl.ref_doc_trx_id,
          	NULL, 'CANDIDATE', 'PERMANENT') 				distribution_class,
        zd.tax_rate_id 								tax_code_id,
        zd.rec_nrec_tax_dist_id 						detail_tax_dist_id,
        zd.rec_nrec_rate 							rec_nrec_rate,
        zd.recovery_rate_id 							recovery_rate_id,
        zd.recovery_rate_code 							recovery_rate_name,
        zd.recovery_type_code 							recovery_type_code,
        zd.summary_tax_line_id 							summary_tax_line_id,
        null									extra_po_erv,
        zd.taxable_amt								taxable_amount,
        zd.taxable_amt_funcl_curr 						taxable_base_amount,
        pd.accrue_on_receipt_flag 						accrue_on_receipt_flag,
        asp.allow_flex_override_flag 						allow_flex_override_flag,
        fsp.purch_encumbrance_flag 						purch_encumbrance_flag,
        asp.org_id 								org_id,
        zd.tax_regime_id 							tax_regime_id,
        zd.tax_id 								tax_id,
        zd.tax_status_id 							tax_status_id,
        zl.tax_jurisdiction_id 							tax_jurisdiction_id,
        parent_taxable_dist.cancellation_flag 					parent_dist_cancellation_flag,
        parent_taxable_dist.reversal_flag 					parent_dist_reversal_flag,
        parent_taxable_dist.parent_reversal_id 					parent_dist_parent_reversal_id,
        zd.reversed_tax_dist_id 						reversed_tax_dist_id,
        zd.adjusted_doc_tax_dist_id 						adjusted_doc_tax_dist_id,
        zd.applied_from_tax_dist_id 						applied_from_tax_dist_id,
        -- the prepay_distribution_id will be populated with
        -- invoice_distribution_id for the associated rec or
        -- nonrec tax distributions
        DECODE(parent_item_line.line_type_lookup_code,
               'PREPAY', AP_ETAX_UTILITY_PKG.get_dist_id_for_tax_dist_id
               			(zd.applied_from_tax_dist_id),
               decode(parent_taxable_dist.line_type_lookup_code,
		      'PREPAY', AP_ETAX_UTILITY_PKG.get_dist_id_for_tax_dist_id
                                       (zd.applied_from_tax_dist_id), NULL))	prepay_distribution_id,
        DECODE(parent_item_line.line_type_lookup_code,
               'PREPAY', DECODE(NVL(zd.recoverable_flag, 'N'),
				'N', (zd.prd_tax_amt - zd.rec_nrec_tax_amt), NULL),
               NULL) 								prepay_tax_diff_amount,
       ai.invoice_id								invoice_id,
       ai.batch_id								batch_id,
       ai.set_of_books_id							set_of_books_id,
	   DECODE(NVL(asp.allow_awt_flag, 'N'),
               'Y', DECODE(NVL(pvs.allow_awt_flag, 'N'),
                      'Y', DECODE(parent_tax_line.pay_awt_group_id,
					        NULL, DECODE(NVL(asp.awt_include_tax_amt, 'N'),
                                    'Y', DECODE(NVL(zd.inclusive_flag, 'N'),
                                           'Y',DECODE(zd.applied_from_tax_dist_id,
                                                null, parent_taxable_dist.pay_awt_group_id,
                                                ap_etax_utility_pkg.Get_Prepay_Pay_Awt_Group_Id(
                                                parent_taxable_dist.prepay_distribution_id,
                                                P_Calling_Sequence)),
                                           'N', parent_taxable_dist.pay_awt_group_id),
								   NULL),
					        parent_tax_line.pay_awt_group_id), --Bug6648050 -- bug 9035846 -- bug9117319
                     NULL),
               NULL) 								pay_awt_group_id,  --Bug8345264
       zd.account_source_tax_rate_id				account_source_tax_rate_id
  FROM zx_trx_headers_gt                gt,
       zx_rec_nrec_dist                 zd,
       zx_lines                         zl,
       ap_invoices_all                  ai,
       ap_supplier_sites_all            pvs,
       ap_system_parameters_all         asp,
       financials_system_params_all     fsp,
       po_distributions_all             pd,
       ap_invoice_lines_all             parent_tax_line,
       ap_invoice_lines_all             parent_item_line,
       ap_invoice_distributions_all     parent_taxable_dist
 WHERE gt.APPLICATION_ID                        = zd.APPLICATION_ID
   AND gt.ENTITY_CODE                           = zd.ENTITY_CODE
   AND gt.EVENT_CLASS_CODE                      = zd.EVENT_CLASS_CODE
   AND gt.TRX_ID                                = zd.TRX_ID
   AND zd.tax_line_id                           = zl.tax_line_id
   AND gt.trx_id                                = ai.invoice_id
   AND ai.vendor_site_id                        = pvs.vendor_site_id
   AND ai.set_of_books_id                       = asp.set_of_books_id
   AND ai.org_id                                = asp.org_id
   AND asp.set_of_books_id                      = fsp.set_of_books_id
   AND asp.org_id                               = fsp.org_id
   AND NVL(zd.self_assessed_flag, 'N')          = 'N'
   AND NVL(zl.reporting_only_flag, 'N')         = 'N'
   AND parent_taxable_dist.po_distribution_id   = pd.po_distribution_id (+)
   AND zd.trx_id                                = parent_tax_line.invoice_id (+)
   AND zd.summary_tax_line_id                   = parent_tax_line.summary_tax_line_id (+)
   AND zd.trx_id                                = parent_item_line.invoice_id (+)
   AND zd.trx_line_id                           = parent_item_line.line_number (+)
   AND zd.trx_id                                = parent_taxable_dist.invoice_id (+)
   AND zd.trx_line_dist_id                      = parent_taxable_dist.invoice_distribution_id (+)
   AND (zd.ref_doc_application_id IS NULL
        or (zd.ref_doc_application_id IS NOT NULL
            and (nvl(zd.recoverable_flag, 'N') = 'Y'
                 or (parent_taxable_dist.prepay_distribution_id IS NOT NULL
                     and (parent_item_line.line_type_lookup_code IS NULL
			  or parent_item_line.line_type_lookup_code <> 'PREPAY'))
		 or ( zd.rec_nrec_tax_amt = 0
		    and nvl(zd.recoverable_flag, 'N') = 'N'
	/* Commented for Bug 6906867*/	/*    and zd.rec_nrec_rate = 100*/  )  -- added the condition for bug fix 6695517
                 or zd.rec_nrec_tax_amt <> ap_etax_utility_pkg.get_tv
                                            (zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt,
                                             nvl(zd.ref_doc_per_unit_nrec_tax_amt,0), zd.per_trx_curr_unit_nr_amt,
                                             zd.ref_per_trx_curr_unit_nr_amt, zd.price_diff, parent_tax_line.corrected_inv_id,
                                             parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, ai.invoice_currency_code,
					     parent_item_line.match_type, zd.unit_price))))
--   AND ((zd.recoverable_flag = 'N'  AND zd.rec_nrec_rate<>0) OR zd.recoverable_flag = 'Y') --bug 6350100   -- commented out the condition for bug fix 6695517
   AND NOT EXISTS
      (SELECT aid.detail_tax_dist_id
         FROM ap_invoice_distributions_all aid
        WHERE aid.invoice_id            = zd.trx_id
          AND aid.detail_tax_dist_id    = zd.rec_nrec_tax_dist_id
          AND aid.line_type_lookup_code IN ('REC_TAX','NONREC_TAX'))
   AND NOT EXISTS
      (SELECT aid.detail_tax_dist_id
         FROM ap_invoice_distributions_all aid
        WHERE aid.invoice_id            = zd.trx_id
          AND aid.detail_tax_dist_id    = zd.rec_nrec_tax_dist_id
          AND aid.line_type_lookup_code IN ('TRV','TERV','TIPV')
          AND (NVL(aid.posted_flag,'N') = 'Y' OR
               aid.accounting_event_id IS NOT NULL OR
               NVL(aid.encumbered_flag, 'N') IN ('Y','D','W','X') OR
          --Bug7419940 Dont allow any insert from posted / frozen variacnes it should be reversed
               NVL(aid.reversal_flag,'N') = 'Y'))
          --Bug8481532 Added Condition To exclude reversed distribuion from getting changed
   AND (parent_taxable_dist.dist_match_type is null
        or nvl(zd.recoverable_flag, 'N') = 'Y'
        or parent_taxable_dist.dist_match_type <> 'PRICE_CORRECTION')
   AND (parent_taxable_dist.prepay_distribution_id IS NULL
        or (parent_taxable_dist.prepay_distribution_id IS NOT NULL
            and (parent_item_line.line_number IS NOT NULL
                 or zd.trx_line_id = (select -1 * (aid.invoice_id || aid.invoice_line_number || parent_taxable_dist.invoice_line_number)
                                        from ap_invoice_distributions_all aid
                                       where aid.invoice_distribution_id = parent_taxable_dist.prepay_distribution_id))))
   -- Bug 7462582
   -- Reverting the fixes done in bugs 6805527 and 7389822 as Etax bug 7515711 will take care of these fixes.
   /* Added by schitlap, epajaril to fix the issue in Bug 6805527 */
   /*AND (nvl(parent_taxable_dist.reversal_flag, 'N') <> 'Y'
        OR zd.reversed_tax_dist_id IS NULL) -- 7389822*/
  ORDER BY detail_tax_dist_id ;  --bug 8359426 --bug 9666759 Removed the desc clause


  CURSOR insert_tax_variances IS
	SELECT /*+ leading(gt,zd) cardinality(gt,1) */
                zd.gl_date accounting_date , --Bug6809792
                /*For tax distributions accounting date will be stamped from zx_rec_nrec_dist
                  Ebtax will now store accounting date of opne period in their table*/
		(CASE dist.line_type
			WHEN 'TERV' THEN
			    DECODE(pd.destination_type_code, 'EXPENSE', pd.code_combination_id,
				   parent_taxable_dist.dist_code_combination_id)
			ELSE
			    DECODE(pd.destination_type_code, 'EXPENSE',
				      DECODE(pd.accrue_on_receipt_flag, 'Y', pd.code_combination_id,
				             parent_taxable_dist.dist_code_combination_id),
				   pd.variance_account_id)
		END)												dist_code_combination_id,
	        (CASE dist.line_type
			WHEN 'TIPV' THEN 'TIPV'
			WHEN 'TERV' THEN 'TERV'
			WHEN 'TRV'  THEN 'TRV'
	        END)												line_type_lookup_code,
        	ap_utilities_pkg.get_gl_period_name(zd.gl_date,ai.org_id)					period_name,
	        (CASE dist.line_type
                 WHEN 'TIPV' THEN
		        decode(parent_taxable_dist.dist_match_type,
				'PRICE_CORRECTION', zd.rec_nrec_tax_amt,
				ap_etax_utility_pkg.get_tipv(
					zd.rate_tax_factor, zd.trx_line_dist_qty,
			                nvl2(parent_taxable_dist.rcv_transaction_id,
						ap_etax_utility_pkg.get_converted_price
						(parent_taxable_dist.invoice_distribution_id), zd.unit_price),
					zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,zd.per_trx_curr_unit_nr_amt),
					zd.price_diff, parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
					parent_tax_line.line_source, ai.invoice_currency_code,
					parent_item_line.match_type))
		 WHEN 'TRV' THEN
		        (ap_etax_utility_pkg.get_tv(
				zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt,
				nvl(zd.ref_doc_per_unit_nrec_tax_amt,0), zd.per_trx_curr_unit_nr_amt,
				zd.ref_per_trx_curr_unit_nr_amt, zd.price_diff, parent_tax_line.corrected_inv_id,
				parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, ai.invoice_currency_code,
				parent_item_line.match_type, zd.unit_price) -
		         ap_etax_utility_pkg.get_tipv(
				zd.rate_tax_factor, zd.trx_line_dist_qty,
		                nvl2(parent_taxable_dist.rcv_transaction_id,
					ap_etax_utility_pkg.get_converted_price
					(parent_taxable_dist.invoice_distribution_id), zd.unit_price),
				zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,per_trx_curr_unit_nr_amt),
				zd.price_diff, parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
				parent_tax_line.line_source, ai.invoice_currency_code, parent_item_line.match_type))
		 WHEN 'TERV' THEN 0
	         END)														amount,
	        (CASE dist.line_type
		 WHEN 'TIPV' THEN
		        ap_utilities_pkg.ap_round_currency(
	                        decode(parent_taxable_dist.dist_match_type,
	                                'PRICE_CORRECTION', zd.rec_nrec_tax_amt,
					ap_etax_utility_pkg.get_tipv_base(
						zd.rate_tax_factor, zd.trx_line_dist_qty,
				                nvl2(parent_taxable_dist.rcv_transaction_id,
							ap_etax_utility_pkg.get_converted_price
							(parent_taxable_dist.invoice_distribution_id), zd.unit_price),
						zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,zd.per_trx_curr_unit_nr_amt),
						zd.price_diff, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate, NULL,
						parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
						parent_tax_line.line_source, ai.invoice_currency_code, asp.base_currency_code,
						parent_item_line.match_type)),
				asp.base_currency_code)
		 WHEN 'TRV' THEN
			ap_utilities_pkg.ap_round_currency(
			(ap_etax_utility_pkg.get_tv_base(
				zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt,
				nvl(zd.ref_doc_per_unit_nrec_tax_amt,0), zd.per_trx_curr_unit_nr_amt,
				zd.ref_per_trx_curr_unit_nr_amt, nvl(zd.currency_conversion_rate,1),
				zd.ref_doc_curr_conv_rate, zd.price_diff, parent_tax_line.corrected_inv_id,
				parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, asp.base_currency_code,
				parent_item_line.match_type, zd.unit_price) -
			ap_etax_utility_pkg.get_tipv_base(
				zd.rate_tax_factor, zd.trx_line_dist_qty,
		                nvl2(parent_taxable_dist.rcv_transaction_id,
					ap_etax_utility_pkg.get_converted_price
					(parent_taxable_dist.invoice_distribution_id), zd.unit_price),
				zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,zd.per_trx_curr_unit_nr_amt),
				zd.price_diff, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate, NULL,
				parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
				parent_tax_line.line_source, ai.invoice_currency_code, asp.base_currency_code,
				parent_item_line.match_type)), asp.base_currency_code) -- bug 9231678
		 WHEN 'TERV' THEN
			ap_utilities_pkg.ap_round_currency
			(ap_etax_utility_pkg.get_terv(
					zd.trx_line_dist_qty, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate,
					zd.applied_to_doc_curr_conv_rate, NULL, zd.per_unit_nrec_tax_amt,
					nvl(zd.ref_doc_per_unit_nrec_tax_amt,zd.per_unit_nrec_tax_amt),
					parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
					parent_tax_line.line_source, asp.base_currency_code), asp.base_currency_code)
	        END)														base_amount,
        DECODE(NVL(zd.inclusive_flag, 'N'),
		'Y', parent_item_line.description,
		'N', parent_tax_line.description)							description,
        DECODE(NVL(zd.inclusive_flag, 'N'),
		'Y', DECODE(parent_item_line.type_1099,
			    NULL, NULL, parent_item_line.income_tax_region),
		'N', DECODE(parent_tax_line.type_1099,
			    NULL, NULL, parent_tax_line.income_tax_region))				income_tax_region,
         parent_taxable_dist.po_distribution_id						                po_distribution_id, -- change for bug 8713009
        DECODE(NVL(zd.inclusive_flag, 'N'),
		'Y', parent_item_line.type_1099,
		'N', parent_tax_line.type_1099) 							type_1099,
        zd.attribute1											attribute1,
        zd.attribute10 											attribute10,
        zd.attribute11 											attribute11,
        zd.attribute12 											attribute12,
        zd.attribute13 											attribute13,
        zd.attribute14 											attribute14,
        zd.attribute15 											attribute15,
        zd.attribute2 											attribute2,
        zd.attribute3 											attribute3,
        zd.attribute4 											attribute4,
        zd.attribute5 											attribute5,
        zd.attribute6 											attribute6,
        zd.attribute7 											attribute7,
        zd.attribute8 											attribute8,
        zd.attribute9 											attribute9,
        zd.attribute_category 										attribute_category,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', NULL,
         	'N', parent_taxable_dist.expenditure_item_date) 					expenditure_item_date,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', NULL,
         	'N', parent_taxable_dist.expenditure_organization_id)					expenditure_organization_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.expenditure_type)						expenditure_type,
        parent_taxable_dist.parent_invoice_id								parent_invoice_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', 'E',
		'N', parent_taxable_dist.pa_addition_flag)						pa_addition_flag,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', NULL,
         	'N', parent_taxable_dist.pa_quantity) 							pa_quantity,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', NULL,
         	'N', parent_taxable_dist.project_accounting_context)					project_accounting_context,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.project_id)							project_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', NULL,
         	'N', parent_taxable_dist.task_id) 							task_id,
        DECODE(NVL(asp.allow_awt_flag, 'N'),
               'Y', DECODE(NVL(pvs.allow_awt_flag, 'N'),
                      'Y',  DECODE(parent_tax_line.awt_group_id,
				            null,DECODE(NVL(asp.awt_include_tax_amt, 'N'),
                                   'Y', DECODE(NVL(zd.inclusive_flag, 'N'),
                                          'Y', DECODE(zd.applied_from_tax_dist_id,
                                                null, parent_taxable_dist.awt_group_id,  --Bug8334059
                                                ap_etax_utility_pkg.Get_Prepay_Awt_Group_Id(
                                                parent_taxable_dist.prepay_distribution_id,
                                                P_Calling_Sequence)),
                                          'N', parent_taxable_dist.awt_group_id),
								  NULL),
					        parent_tax_line.awt_group_id), --Bug6648050 --bug 9035846  -- bug9117319
									--Bug8334059 --bug9200123
                      NULL),
               NULL) 								awt_group_id,
        zd.global_attribute_category									global_attribute_category,
        zd.global_attribute1										global_attribute1,
        zd.global_attribute2										global_attribute2,
        zd.global_attribute3										global_attribute3,
        zd.global_attribute4										global_attribute4,
        zd.global_attribute5										global_attribute5,
        zd.global_attribute6										global_attribute6,
        zd.global_attribute7										global_attribute7,
        zd.global_attribute8										global_attribute8,
        zd.global_attribute9										global_attribute9,
        zd.global_attribute10										global_attribute10,
        zd.global_attribute11										global_attribute11,
        zd.global_attribute12										global_attribute12,
        zd.global_attribute13										global_attribute13,
        zd.global_attribute14										global_attribute14,
        zd.global_attribute15										global_attribute15,
        zd.global_attribute16										global_attribute16,
        zd.global_attribute17										global_attribute17,
        zd.global_attribute18										global_attribute18,
        zd.global_attribute19										global_attribute19,
        zd.global_attribute20										global_attribute20,
        DECODE(NVL(zd.recoverable_flag, 'N'),
		'Y', NULL,
		'N', parent_taxable_dist.award_id) 							award_id,
        DECODE(zd.ref_doc_dist_id,
          	NULL, DECODE(zl.applied_to_trx_id,
				NULL, 'NOT_MATCHED',
				'OTHER_TO_RECEIPT'),
		'NOT_MATCHED')										dist_match_type,
         DECODE(NVL(zd.recoverable_flag, 'N'),
         	'Y', NULL,
            --Bug 8910531
         	'N', parent_taxable_dist.rcv_transaction_id) 						rcv_transaction_id,
        zd.recoverable_flag 										tax_recoverable_flag,
        parent_taxable_dist.cancellation_flag 								cancellation_flag,
        DECODE(NVL(zd.inclusive_flag, 'N'),
         	'Y', zd.trx_line_id,
         	'N', parent_tax_line.line_number) 							invoice_line_number,
        parent_taxable_dist.corrected_invoice_dist_id 							corrected_invoice_dist_id,
        NULL rounding_amt,
        decode(NVL(zl.tax_only_line_flag,'N'),
                     'Y', NULL, zd.trx_line_dist_id)							charge_applicable_to_dist_id,
        DECODE(zl.ref_doc_trx_id,
          	NULL, 'CANDIDATE', 'PERMANENT') 							distribution_class,
        zd.tax_rate_id 											tax_code_id,
        zd.rec_nrec_tax_dist_id 									detail_tax_dist_id,
        zd.rec_nrec_rate 										rec_nrec_rate,
        zd.recovery_rate_id 										recovery_rate_id,
        zd.recovery_rate_code 										recovery_rate_name,
        zd.recovery_type_code 										recovery_type_code,
        zd.summary_tax_line_id 										summary_tax_line_id,
        NULL 												extra_po_erv,
        NULL 												taxable_amount,
        NULL 												taxable_base_amount,
        pd.accrue_on_receipt_flag 									accrue_on_receipt_flag,
        asp.allow_flex_override_flag 									allow_flex_override_flag,
        fsp.purch_encumbrance_flag 									purch_encumbrance_flag,
        asp.org_id 											org_id,
        zd.tax_regime_id 										tax_regime_id,
        zd.tax_id 											tax_id,
        zd.tax_status_id 										tax_status_id,
        zl.tax_jurisdiction_id 										tax_jurisdiction_id,
        parent_taxable_dist.cancellation_flag 								parent_dist_cancellation_flag,
        parent_taxable_dist.reversal_flag 								parent_dist_reversal_flag,
        parent_taxable_dist.parent_reversal_id 								parent_dist_parent_reversal_id,
        zd.reversed_tax_dist_id 									reversed_tax_dist_id,
        zd.adjusted_doc_tax_dist_id 									adjusted_doc_tax_dist_id,
        zd.applied_from_tax_dist_id  									applied_from_tax_dist_id,
        NULL 												prepay_distribution_id,
        NULL 												prepay_tax_diff_amount,
        ai.invoice_id                                                 invoice_id,
        ai.batch_id                                                   batch_id,
        ai.set_of_books_id                                            set_of_books_id,
	   DECODE(NVL(asp.allow_awt_flag, 'N'),
               'Y', DECODE(NVL(pvs.allow_awt_flag, 'N'),
                      'Y', DECODE(parent_tax_line.pay_awt_group_id,
					        NULL, DECODE(NVL(asp.awt_include_tax_amt, 'N'),
                                    'Y', DECODE(NVL(zd.inclusive_flag, 'N'),
                                           'Y',DECODE(zd.applied_from_tax_dist_id,
                                                null, parent_taxable_dist.pay_awt_group_id,
                                                ap_etax_utility_pkg.Get_Prepay_Pay_Awt_Group_Id(
                                                parent_taxable_dist.prepay_distribution_id,
                                                P_Calling_Sequence)),
                                           'N', parent_taxable_dist.pay_awt_group_id),
								   NULL),
					        parent_tax_line.pay_awt_group_id), --Bug6648050 -- bug 9035846 -- bug9117319 --bug9200123
                     NULL),
               NULL) 								pay_awt_group_id,  --Bug8345264
        zd.account_source_tax_rate_id									account_source_tax_rate_id
  FROM zx_trx_headers_gt		gt,
       zx_rec_nrec_dist                 zd,
       zx_lines                         zl,
       ap_invoices_all                  ai,
       ap_supplier_sites_all            pvs,
       ap_system_parameters_all         asp,
       financials_system_params_all     fsp,
       po_distributions_all             pd,
       ap_invoice_lines_all             parent_tax_line,
       ap_invoice_lines_all             parent_item_line,
       ap_invoice_distributions_all     parent_taxable_dist,
       ap_line_temp_gt			dist
 WHERE gt.APPLICATION_ID                        = zd.APPLICATION_ID
   AND gt.ENTITY_CODE                           = zd.ENTITY_CODE
   AND gt.EVENT_CLASS_CODE                      = zd.EVENT_CLASS_CODE
   AND gt.TRX_ID                                = zd.TRX_ID
   AND zd.tax_line_id                           = zl.tax_line_id
   AND gt.trx_id                                = ai.invoice_id
   AND ai.vendor_site_id                        = pvs.vendor_site_id
   AND ai.set_of_books_id                       = asp.set_of_books_id
   AND ai.org_id                                = asp.org_id
   AND asp.set_of_books_id                      = fsp.set_of_books_id
   AND asp.org_id                               = fsp.org_id
   AND NVL(zd.recoverable_flag, 'N')    	= 'N'
   AND NVL(zd.self_assessed_flag, 'N')          = 'N'
   AND NVL(zl.reporting_only_flag, 'N')         = 'N'
   --Bug9777752 Removed Outer join on PD
   AND parent_taxable_dist.po_distribution_id   = pd.po_distribution_id
   --Bug9777752 Removed Outer join on PD
   AND zd.trx_id                                = parent_tax_line.invoice_id(+)
   AND zd.summary_tax_line_id                   = parent_tax_line.summary_tax_line_id(+)
   AND zd.trx_id                                = parent_item_line.invoice_id(+)
   AND zd.trx_line_id                           = parent_item_line.line_number(+)
   AND zd.trx_id                                = parent_taxable_dist.invoice_id
   AND zd.trx_line_dist_id                      = parent_taxable_dist.invoice_distribution_id
   AND parent_item_line.line_type_lookup_code(+) <> 'PREPAY'
   AND parent_taxable_dist.line_type_lookup_code <> 'PREPAY'
   AND NOT EXISTS
      (SELECT aid.detail_tax_dist_id
         FROM ap_invoice_distributions_all aid
        WHERE aid.invoice_id            = zd.trx_id
          AND aid.detail_tax_dist_id    = zd.rec_nrec_tax_dist_id
          AND aid.line_type_lookup_code IN ('TIPV', 'TERV', 'TRV'))
   AND NOT EXISTS
      (SELECT aid.detail_tax_dist_id
         FROM ap_invoice_distributions_all aid
        WHERE aid.invoice_id            = zd.trx_id
          AND aid.detail_tax_dist_id    = zd.rec_nrec_tax_dist_id
          AND aid.line_type_lookup_code = 'NONREC_TAX'
          AND (NVL(aid.posted_flag,'N') = 'Y' OR
               aid.accounting_event_id IS NOT NULL OR
               NVL(aid.encumbered_flag,'N') IN ('Y','D','W','X') OR
               --Bug7419940 Dont allow any insert from posted / frozen variacnes it should be reversed
               NVL(aid.reversal_flag,'N')='Y'))
               --Bug8481532 Added Condition To exclude reversed distribuion from getting changed
   AND ((dist.line_type =  'TIPV'
	 AND (ap_etax_utility_pkg.get_tipv
		(zd.rate_tax_factor, zd.trx_line_dist_qty,
		 nvl2(parent_taxable_dist.rcv_transaction_id,
			ap_etax_utility_pkg.get_converted_price
			(parent_taxable_dist.invoice_distribution_id), zd.unit_price),
		 zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,zd.per_trx_curr_unit_nr_amt),
                 zd.price_diff, parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
		 parent_tax_line.line_source, ai.invoice_currency_code, parent_item_line.match_type) <> 0
	      or parent_taxable_dist.dist_match_type = 'PRICE_CORRECTION'
	     ))
	OR
	(dist.line_type =  'TRV'
	 and (ap_etax_utility_pkg.get_tv(
			zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt,
			nvl(zd.ref_doc_per_unit_nrec_tax_amt,0), zd.per_trx_curr_unit_nr_amt,
			zd.ref_per_trx_curr_unit_nr_amt, zd.price_diff, parent_tax_line.corrected_inv_id,
			parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, ai.invoice_currency_code,
			parent_item_line.match_type, zd.unit_price) -
	        ap_etax_utility_pkg.get_tipv(
			zd.rate_tax_factor, zd.trx_line_dist_qty,
                        nvl2(parent_taxable_dist.rcv_transaction_id,
                                ap_etax_utility_pkg.get_converted_price
                                (parent_taxable_dist.invoice_distribution_id), zd.unit_price),
			zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,per_trx_curr_unit_nr_amt),
			zd.price_diff, parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
			parent_tax_line.line_source, ai.invoice_currency_code, parent_item_line.match_type)) <> 0)
	OR
	(dist.line_type =  'TERV'
	 AND (ap_etax_utility_pkg.get_terv(
			zd.trx_line_dist_qty, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate,
			zd.applied_to_doc_curr_conv_rate, NULL, zd.per_unit_nrec_tax_amt,
			nvl(zd.ref_doc_per_unit_nrec_tax_amt,zd.per_unit_nrec_tax_amt),
			parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
			parent_tax_line.line_source, asp.base_currency_code)) <> 0))
     -- bug 9231678 removed sign condition
  ORDER BY detail_tax_dist_id;


  CURSOR update_tax_dist IS
      SELECT /*+ leading(gt,zd) cardinality(gt,1) */
        zd.gl_date accounting_date , --Bug6809792
         /*For tax distributions accounting date will be stamped from zx_rec_nrec_dist
           Ebtax will now store accounting date of opne period in their table*/
        parent_taxable_dist.dist_code_combination_id dist_code_combination_id,
        -- this ccid is a temporary value that will be used if other conditions
        -- are met before inserting the tax distribution
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', 'REC_TAX',
         'N', 'NONREC_TAX') line_type_lookup_code,
        ap_utilities_pkg.get_gl_period_name(zd.gl_date,ai.org_id)	period_name,
-- bug 8317515: modify start
        DECODE(parent_item_line.line_type_lookup_code,
               'PREPAY', zd.rec_nrec_tax_amt,
               decode(parent_taxable_dist.line_type_lookup_code, 'PREPAY', zd.rec_nrec_tax_amt,
               decode(nvl(zd.recoverable_flag,'N'),
			  'Y', zd.rec_nrec_tax_amt,
				(NVL(zd.rec_nrec_tax_amt, 0) -
                            get_tv(zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt,
						    nvl(zd.ref_doc_per_unit_nrec_tax_amt,0), zd.per_trx_curr_unit_nr_amt,
						    zd.ref_per_trx_curr_unit_nr_amt, zd.price_diff, parent_tax_line.corrected_inv_id,
						    parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, ai.invoice_currency_code,
						    parent_item_line.match_type, zd.unit_price))))) amount, -- bug 9231678
        ap_utilities_pkg.ap_round_currency(
        DECODE(parent_item_line.line_type_lookup_code,
		'PREPAY', zd.rec_nrec_tax_amt_funcl_curr,
                decode(parent_taxable_dist.line_type_lookup_code, 'PREPAY', zd.rec_nrec_tax_amt_funcl_curr,
                decode(nvl(zd.recoverable_flag,'N'),
		       'Y', zd.rec_nrec_tax_amt_funcl_curr,
			     (NVL(zd.rec_nrec_tax_amt_funcl_curr, 0) -
				    (get_tv_base
					(zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt, nvl(zd.ref_doc_per_unit_nrec_tax_amt,0),
					 zd.per_trx_curr_unit_nr_amt, zd.ref_per_trx_curr_unit_nr_amt, nvl(zd.currency_conversion_rate, 1),
					 zd.ref_doc_curr_conv_rate, zd.price_diff, parent_tax_line.corrected_inv_id,
					 parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, asp.base_currency_code,
					 parent_item_line.match_type, zd.unit_price)+
				     get_terv
					(zd.trx_line_dist_qty, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate, zd.applied_to_doc_curr_conv_rate,
					 NULL, zd.per_unit_nrec_tax_amt, nvl(zd.ref_doc_per_unit_nrec_tax_amt,zd.per_unit_nrec_tax_amt),
					 parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code, parent_tax_line.line_source,
					 asp.base_currency_code)))))),
					 asp.base_currency_code) base_amount, -- bug 9231678
-- bug 8317515: modify end
        -- included the decode as part of the prepayment changes.
        -- since for prepayment applic tax variances will not be created,
        -- the base_amount should be the total including variances
        DECODE(NVL(zd.inclusive_flag, 'N'),
         'Y', parent_item_line.description,
         'N', parent_tax_line.description) description,
        DECODE(NVL(zd.inclusive_flag, 'N'),
         'Y', DECODE(parent_item_line.type_1099,
                NULL, NULL,
                parent_item_line.income_tax_region),
         'N', DECODE(parent_tax_line.type_1099,
                NULL, NULL,
                parent_tax_line.income_tax_region)) income_tax_region,
        DECODE(NVL(zd.inclusive_flag, 'N'),
         'Y', parent_item_line.type_1099,
         'N', parent_tax_line.type_1099) type_1099,
-- bug 6914575: modify start
-- Populating DFF's from Invoice distributions instead of Tax dists
        aid.attribute1 attribute1,
        aid.attribute10 attribute10,
        aid.attribute11 attribute11,
        aid.attribute12 attribute12,
        aid.attribute13 attribute13,
        aid.attribute14 attribute14,
        aid.attribute15 attribute15,
        aid.attribute2 attribute2,
        aid.attribute3 attribute3,
        aid.attribute4 attribute4,
        aid.attribute5 attribute5,
        aid.attribute6 attribute6,
        aid.attribute7 attribute7,
        aid.attribute8 attribute8,
        aid.attribute9 attribute9,
        aid.attribute_category attribute_category,
-- bug 6914575: modify end
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_item_date) expenditure_item_date,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_organization_id)
           expenditure_organization_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_type) expenditure_type,
        parent_taxable_dist.parent_invoice_id parent_invoice_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', 'E',
         'N', parent_taxable_dist.pa_addition_flag) pa_addition_flag,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.pa_quantity) pa_quantity,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.project_accounting_context)
           project_accounting_context,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.project_id) project_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.task_id) task_id,
        aid.awt_group_id awt_group_id,
	--Bug6505640 Populating DFF's from Invoice distributions instead of Tax dists
        aid.global_attribute_category global_attribute_category,
        aid.global_attribute1 global_attribute1,
        aid.global_attribute2 global_attribute2,
        aid.global_attribute3 global_attribute3,
        aid.global_attribute4 global_attribute4,
        aid.global_attribute5 global_attribute5,
        aid.global_attribute6 global_attribute6,
        aid.global_attribute7 global_attribute7,
        aid.global_attribute8 global_attribute8,
        aid.global_attribute9 global_attribute9,
        aid.global_attribute10 global_attribute10,
        aid.global_attribute11 global_attribute11,
        aid.global_attribute12 global_attribute12,
        aid.global_attribute13 global_attribute13,
        aid.global_attribute14 global_attribute14,
        aid.global_attribute15 global_attribute15,
        aid.global_attribute16 global_attribute16,
        aid.global_attribute17 global_attribute17,
        aid.global_attribute18 global_attribute18,
        aid.global_attribute19 global_attribute19,
        aid.global_attribute20 global_attribute20,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.award_id) award_id,
        DECODE(zd.ref_doc_dist_id,
          NULL, DECODE(zl.applied_to_trx_id,
              NULL, 'NOT_MATCHED',
              'OTHER_TO_RECEIPT'),
          'NOT_MATCHED') dist_match_type,
         DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         --Bug 8910531
         'N', parent_taxable_dist.rcv_transaction_id) rcv_transaction_id,
        zd.recoverable_flag tax_recoverable_flag,
        parent_taxable_dist.cancellation_flag cancellation_flag,
        DECODE(NVL(zd.inclusive_flag, 'N'),
         'Y', zd.trx_line_id,
         'N', nvl(parent_tax_line.line_number,
                  parent_taxable_dist.invoice_line_number)) invoice_line_number,
        parent_taxable_dist.corrected_invoice_dist_id corrected_invoice_dist_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
          'Y', NULL,
          zd.func_curr_rounding_adjustment) rounding_amt,
        -- This will update the rounding_amt in the recoverable dist
        -- for the non-recoverable the primary distribution will be
        -- updated later on
        decode(NVL(zl.tax_only_line_flag,'N'),
                     'Y', NULL, zd.trx_line_dist_id)	charge_applicable_to_dist_id,
        DECODE(zl.ref_doc_trx_id,
          NULL, 'CANDIDATE',
          'PERMANENT') distribution_class,
        zd.tax_rate_id tax_code_id,
        zd.rec_nrec_tax_dist_id detail_tax_dist_id,
        zd.rec_nrec_rate rec_nrec_rate,
        zd.recovery_rate_id recovery_rate_id,
        zd.recovery_rate_code recovery_rate_name,
        zd.recovery_type_code recovery_type_code,
        zd.taxable_amt taxable_amount,
        zd.taxable_amt_funcl_curr taxable_base_amount,
        zd.summary_tax_line_id summary_tax_line_id,
        null extra_po_erv,
        -- (zd.applied_to_doc_erv - zx.reference_doc_erv) null extra_po_erv,
        DECODE(parent_item_line.line_type_lookup_code,
          'PREPAY', DECODE(NVL(zd.recoverable_flag, 'N'),
                      'N', (zd.prd_tax_amt - zd.rec_nrec_tax_amt), NULL),
          NULL) prepay_tax_diff_amount,
        aid.invoice_distribution_id invoice_distribution_id,
		aid.pay_awt_group_id 		pay_awt_group_id,  --bug8345264
        zd.account_source_tax_rate_id
  FROM  zx_trx_headers_gt		gt,
	    zx_rec_nrec_dist        zd,
        zx_lines                zl,
	    ap_invoices_all         ai,
        ap_invoice_distributions_all    aid,
        ap_supplier_sites_all           pvs,
        ap_system_parameters_all        asp,
        financials_system_params_all    fsp,
        po_distributions_all            pd,
        ap_invoice_lines_all            parent_tax_line,
        ap_invoice_lines_all            parent_item_line,
        ap_invoice_distributions_all    parent_taxable_dist
 WHERE  gt.APPLICATION_ID                        = zd.APPLICATION_ID
   AND  gt.ENTITY_CODE                           = zd.ENTITY_CODE
   AND  gt.EVENT_CLASS_CODE                      = zd.EVENT_CLASS_CODE
   AND  gt.TRX_ID                                = zd.TRX_ID
   AND  zd.tax_line_id                           = zl.tax_line_id
   AND  gt.trx_id                                = ai.invoice_id
   AND  ai.invoice_id                            = aid.invoice_id
   AND  aid.detail_tax_dist_id                   = zd.rec_nrec_tax_dist_id
   AND  aid.line_type_lookup_code                IN ('REC_TAX','NONREC_TAX')
   AND  nvl(aid.reversal_flag,'N')               <> 'Y'
   AND (NVL(aid.posted_flag,'N') <> 'Y' AND
        aid.accounting_event_id IS NULL AND
        NVL(aid.encumbered_flag, 'N') NOT IN ('Y','D','W','X')) --Bug7419940 Dont allow any insert from posted / frozen variacnes it should be reversed)
   AND  ai.vendor_site_id                        = pvs.vendor_site_id
   AND  ai.set_of_books_id                       = asp.set_of_books_id
   AND  ai.org_id                                = asp.org_id
   AND  asp.set_of_books_id                      = fsp.set_of_books_id
   AND  asp.org_id                               = fsp.org_id
   AND  parent_taxable_dist.po_distribution_id   = pd.po_distribution_id(+)
   AND  zd.trx_id                                = parent_tax_line.invoice_id (+)
   AND  zd.summary_tax_line_id                   = parent_tax_line.summary_tax_line_id(+)
   AND  zd.trx_id                                = parent_item_line.invoice_id(+)
   AND  zd.trx_line_id                           = parent_item_line.line_number(+)
   AND  zd.trx_id                                = parent_taxable_dist.invoice_id(+)
   AND  zd.trx_line_dist_id                      = parent_taxable_dist.invoice_distribution_id(+);


  CURSOR update_tax_variances IS
	SELECT /*+ leading(gt,zd) cardinality(gt,1) */
	         zd.gl_date accounting_date , --Bug6809792
                 /*For tax distributions accounting date will be stamped from zx_rec_nrec_dist
                   Ebtax will now store accounting date of opne period in their table*/
                (CASE aid.line_type_lookup_code
                        WHEN 'TERV' THEN
                            DECODE(pd.destination_type_code, 'EXPENSE', pd.code_combination_id,
                                   parent_taxable_dist.dist_code_combination_id)
                        ELSE
                            DECODE(pd.destination_type_code, 'EXPENSE',
                                      DECODE(pd.accrue_on_receipt_flag, 'Y', pd.code_combination_id,
                                             parent_taxable_dist.dist_code_combination_id),
                                   pd.variance_account_id)
                END)                                                                                            dist_code_combination_id,
	        (CASE aid.line_type_lookup_code
			WHEN 'TIPV' THEN 'TIPV'
			WHEN 'TERV' THEN 'TERV'
			WHEN 'TRV'  THEN 'TRV'
	        END)												line_type_lookup_code,
        	ap_utilities_pkg.get_gl_period_name(zd.gl_date,ai.org_id)					period_name,
               (CASE aid.line_type_lookup_code
                 WHEN 'TIPV' THEN
                       decode(parent_taxable_dist.dist_match_type,     -- Bug 5639076
                              'PRICE_CORRECTION', zd.rec_nrec_tax_amt,
		                        ap_etax_utility_pkg.get_tipv(
   		                          zd.rate_tax_factor, zd.trx_line_dist_qty,
		                          nvl2(parent_taxable_dist.rcv_transaction_id,
		                                ap_etax_utility_pkg.get_converted_price
		                                  (parent_taxable_dist.invoice_distribution_id), zd.unit_price),
                                                zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,zd.per_trx_curr_unit_nr_amt),
			                        zd.price_diff, parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
		                                parent_tax_line.line_source, ai.invoice_currency_code, parent_item_line.match_type))
		 WHEN 'TRV' THEN
		        (ap_etax_utility_pkg.get_tv(
				zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt,
				nvl(zd.ref_doc_per_unit_nrec_tax_amt,0), zd.per_trx_curr_unit_nr_amt,
				zd.ref_per_trx_curr_unit_nr_amt, zd.price_diff, parent_tax_line.corrected_inv_id,
				parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, ai.invoice_currency_code,
				parent_item_line.match_type, zd.unit_price) -
		         ap_etax_utility_pkg.get_tipv(
				zd.rate_tax_factor, zd.trx_line_dist_qty,
	                        nvl2(parent_taxable_dist.rcv_transaction_id,
	                                ap_etax_utility_pkg.get_converted_price
	                                (parent_taxable_dist.invoice_distribution_id), zd.unit_price),
				zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,per_trx_curr_unit_nr_amt),
				zd.price_diff, parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
				parent_tax_line.line_source, ai.invoice_currency_code, parent_item_line.match_type))
		 WHEN 'TERV' THEN 0
	        END)												amount,
	        (CASE aid.line_type_lookup_code
		 WHEN 'TIPV' THEN
		        ap_utilities_pkg.ap_round_currency(
			ap_etax_utility_pkg.get_tipv_base(
				zd.rate_tax_factor, zd.trx_line_dist_qty,
	                        nvl2(parent_taxable_dist.rcv_transaction_id,
	                                ap_etax_utility_pkg.get_converted_price
	                                (parent_taxable_dist.invoice_distribution_id), zd.unit_price),
				zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,zd.per_trx_curr_unit_nr_amt),
				zd.price_diff, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate, NULL,
				parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
				parent_tax_line.line_source, ai.invoice_currency_code, asp.base_currency_code,
				parent_item_line.match_type),
				asp.base_currency_code)
		 WHEN 'TRV' THEN
			ap_utilities_pkg.ap_round_currency(
			(ap_etax_utility_pkg.get_tv_base(
				zd.rate_tax_factor, zd.trx_line_dist_qty, zd.per_unit_nrec_tax_amt,
				nvl(zd.ref_doc_per_unit_nrec_tax_amt,0), zd.per_trx_curr_unit_nr_amt,
				zd.ref_per_trx_curr_unit_nr_amt, nvl(zd.currency_conversion_rate,1),
				zd.ref_doc_curr_conv_rate, zd.price_diff, parent_tax_line.corrected_inv_id,
				parent_tax_line.line_type_lookup_code, parent_tax_line.line_source, asp.base_currency_code,
				parent_item_line.match_type, zd.unit_price) -
			ap_etax_utility_pkg.get_tipv_base(
				zd.rate_tax_factor, zd.trx_line_dist_qty,
	                        nvl2(parent_taxable_dist.rcv_transaction_id,
	                                ap_etax_utility_pkg.get_converted_price
	                                (parent_taxable_dist.invoice_distribution_id), zd.unit_price),
				zd.ref_doc_unit_price, nvl(zd.ref_per_trx_curr_unit_nr_amt,zd.per_trx_curr_unit_nr_amt),
				zd.price_diff, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate, NULL,
				parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
				parent_tax_line.line_source, ai.invoice_currency_code, asp.base_currency_code,
				parent_item_line.match_type)), asp.base_currency_code) -- bug 9231678
		 WHEN 'TERV' THEN
			ap_utilities_pkg.ap_round_currency
			(ap_etax_utility_pkg.get_terv(
					zd.trx_line_dist_qty, zd.currency_conversion_rate, zd.ref_doc_curr_conv_rate,
					zd.applied_to_doc_curr_conv_rate, NULL, zd.per_unit_nrec_tax_amt,
					nvl(zd.ref_doc_per_unit_nrec_tax_amt,zd.per_unit_nrec_tax_amt),
					parent_tax_line.corrected_inv_id, parent_tax_line.line_type_lookup_code,
					parent_tax_line.line_source, asp.base_currency_code), asp.base_currency_code)
	        END)												base_amount,
	        DECODE(NVL(zd.inclusive_flag, 'N'),
			'Y', parent_item_line.description,
			'N', parent_tax_line.description) 							description,
	        DECODE(NVL(zd.inclusive_flag, 'N'),
			'Y', DECODE(parent_item_line.type_1099, NULL, NULL,
					parent_item_line.income_tax_region),
			'N', DECODE(parent_tax_line.type_1099, NULL, NULL,
					parent_tax_line.income_tax_region))					income_tax_region,
	        DECODE(NVL(zd.inclusive_flag, 'N'),
			'Y', parent_item_line.type_1099,
			'N', parent_tax_line.type_1099)								type_1099,
 	        --Bug9346774
                aid.attribute1											attribute1,
	        aid.attribute10											attribute10,
	        aid.attribute11											attribute11,
	        aid.attribute12											attribute12,
	        aid.attribute13											attribute13,
	        aid.attribute14											attribute14,
	        aid.attribute15											attribute15,
	        aid.attribute2 											attribute2,
	        aid.attribute3 											attribute3,
	        aid.attribute4 											attribute4,
	        aid.attribute5 											attribute5,
	        aid.attribute6 											attribute6,
	        aid.attribute7 											attribute7,
	        aid.attribute8 											attribute8,
	        aid.attribute9 											attribute9,
	        aid.attribute_category 										attribute_category,
                --Bug9346774
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', NULL, 'N', parent_taxable_dist.expenditure_item_date) 				expenditure_item_date,
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', NULL, 'N', parent_taxable_dist.expenditure_organization_id) 			expenditure_organization_id,
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', NULL, 'N', parent_taxable_dist.expenditure_type) 					expenditure_type,
	        parent_taxable_dist.parent_invoice_id 								parent_invoice_id,
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', 'E', 'N', parent_taxable_dist.pa_addition_flag) pa_addition_flag,
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', NULL, 'N', parent_taxable_dist.pa_quantity) 					pa_quantity,
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', NULL, 'N', parent_taxable_dist.project_accounting_context) 			project_accounting_context,
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', NULL, 'N', parent_taxable_dist.project_id) 					project_id,
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', NULL, 'N', parent_taxable_dist.task_id) 						task_id,
	        aid.awt_group_id 										awt_group_id,
                --Bug9346774
	        aid.global_attribute_category								global_attribute_category,
                aid.global_attribute1                                             	 	                global_attribute1,
	        aid.global_attribute2										global_attribute2,
	        aid.global_attribute3										global_attribute3,
	        aid.global_attribute4										global_attribute4,
	        aid.global_attribute5										global_attribute5,
	        aid.global_attribute6										global_attribute6,
	        aid.global_attribute7										global_attribute7,
	        aid.global_attribute8										global_attribute8,
	        aid.global_attribute9										global_attribute9,
	        aid.global_attribute10										global_attribute10,
	        aid.global_attribute11										global_attribute11,
	        aid.global_attribute12										global_attribute12,
	        aid.global_attribute13										global_attribute13,
	        aid.global_attribute14										global_attribute14,
	        aid.global_attribute15										global_attribute15,
	        aid.global_attribute16										global_attribute16,
	        aid.global_attribute17										global_attribute17,
	        aid.global_attribute18										global_attribute18,
	        aid.global_attribute19										global_attribute19,
	        aid.global_attribute20										global_attribute20,
                --Bug9346774
	        DECODE(NVL(zd.recoverable_flag, 'N'),
			'Y', NULL, 'N', parent_taxable_dist.award_id) 						award_id,
	        DECODE(zd.ref_doc_dist_id,
			NULL, DECODE(zl.applied_to_trx_id,
				NULL, 'NOT_MATCHED', 'OTHER_TO_RECEIPT'), 'NOT_MATCHED')			dist_match_type,
	        DECODE(NVL(zd.recoverable_flag, 'N'),
            --Bug 8910531
				'Y', NULL, 'N', parent_taxable_dist.rcv_transaction_id) 				rcv_transaction_id,
	        zd.recoverable_flag										tax_recoverable_flag,
	        parent_taxable_dist.cancellation_flag 								cancellation_flag,
	        DECODE(NVL(zd.inclusive_flag, 'N'),
				'Y', zd.trx_line_id, 'N', parent_tax_line.line_number)				invoice_line_number,
	        parent_taxable_dist.corrected_invoice_dist_id							corrected_invoice_dist_id,
	        NULL 												rounding_amt,
	        decode(NVL(zl.tax_only_line_flag,'N'),
                         'Y', NULL, zd.trx_line_dist_id)							charge_applicable_to_dist_id,
	        DECODE(zl.ref_doc_trx_id, NULL, 'CANDIDATE', 'PERMANENT') 					distribution_class,
	        zd.tax_rate_id 											tax_code_id,
	        zd.rec_nrec_tax_dist_id 									detail_tax_dist_id,
	        zd.rec_nrec_rate 										rec_nrec_rate,
	        zd.recovery_rate_id 										recovery_rate_id,
	        zd.recovery_rate_code 										recovery_rate_name,
	        zd.recovery_type_code 										recovery_type_code,
	        NULL 												taxable_amount,
	        NULL 												taxable_base_amount,
	        zd.summary_tax_line_id 										summary_tax_line_id,
	        NULL 												extra_po_erv,
	        NULL 												prepay_tax_diff_amount,
	        aid.invoice_distribution_id 									invoice_distribution_id,
			aid.pay_awt_group_id 											pay_awt_group_id, --Bug8345264
		    zd.account_source_tax_rate_id									account_source_tax_rate_id
           FROM zx_trx_headers_gt               gt,
	        zx_rec_nrec_dist                zd,
	        zx_lines                        zl,
	        ap_invoices_all                 ai,
	        ap_invoice_distributions_all    aid,
	        ap_supplier_sites_all           pvs,
	        ap_system_parameters_all        asp,
	        financials_system_params_all    fsp,
	        po_distributions_all            pd,
	        ap_invoice_lines_all            parent_tax_line,
	        ap_invoice_lines_all            parent_item_line,
	        ap_invoice_distributions_all    parent_taxable_dist
	 WHERE  gt.APPLICATION_ID                        = zd.APPLICATION_ID
	   AND  gt.ENTITY_CODE                           = zd.ENTITY_CODE
	   AND  gt.EVENT_CLASS_CODE                      = zd.EVENT_CLASS_CODE
	   AND  gt.TRX_ID                                = zd.TRX_ID
	   AND  zd.tax_line_id                           = zl.tax_line_id
	   AND  gt.trx_id                                = ai.invoice_id
	   AND  ai.invoice_id                            = aid.invoice_id
	   AND  aid.detail_tax_dist_id                   = zd.rec_nrec_tax_dist_id
	   AND  aid.line_type_lookup_code                IN ('TIPV', 'TRV', 'TERV')
       AND  nvl(aid.reversal_flag,'N')               <> 'Y'
       AND (NVL(aid.posted_flag,'N') <> 'Y' AND
            aid.accounting_event_id IS NULL AND
            NVL(aid.encumbered_flag, 'N') NOT IN ('Y','D','W','X')) --Bug7419940 Dont allow any insert from posted / frozen variacnes it should be reversed)
 	   AND  ai.vendor_site_id                        = pvs.vendor_site_id
	   AND  ai.set_of_books_id                       = asp.set_of_books_id
	   AND  ai.org_id                                = asp.org_id
	   AND  asp.set_of_books_id                      = fsp.set_of_books_id
	   AND  asp.org_id                               = fsp.org_id
	   AND  parent_taxable_dist.po_distribution_id   = pd.po_distribution_id(+)
	   AND  zd.trx_id                                = parent_tax_line.invoice_id (+)
	   AND  zd.summary_tax_line_id                   = parent_tax_line.summary_tax_line_id(+)
	   AND  zd.trx_id                                = parent_item_line.invoice_id(+)
	   AND  zd.trx_line_id                           = parent_item_line.line_number(+)
	   AND  zd.trx_id                                = parent_taxable_dist.invoice_id(+)
	   AND  zd.trx_line_dist_id                      = parent_taxable_dist.invoice_distribution_id(+)
	   AND  parent_item_line.line_type_lookup_code(+) <> 'PREPAY';
      -- bug 9231678 removed sign condition

  -- Cursors for self assessed distributions
  CURSOR insert_tax_self IS
      SELECT /*+ leading(gt,zd) cardinality(gt,1) INDEX (ZD ZX_REC_NREC_DIST_U3) */
        zd.gl_date accounting_date , --Bug6809792
        /*For tax distributions accounting date will be stamped from zx_rec_nrec_dist
          Ebtax will now store accounting date of opne period in their table*/
         -- Modified dist_code_combination_id value for bug#Bug9437885
        DECODE(pd.accrue_on_receipt_flag, 'Y', pd.code_combination_id,parent_taxable_dist.dist_code_combination_id) dist_code_combination_id,
        -- this ccid is a temporary value that will be used if other conditions
        -- are met before inserting the tax distribution
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', 'REC_TAX',
         'N', 'NONREC_TAX') line_type_lookup_code,
        ap_utilities_pkg.get_gl_period_name(zd.gl_date,ai.org_id)	period_name,
        zd.rec_nrec_tax_amt amount,
        ap_utilities_pkg.ap_round_currency
                (zd.rec_nrec_tax_amt_funcl_curr,asp.base_currency_code) base_amount,
	parent_item_line.description description,
	DECODE(parent_item_line.type_1099,
                NULL, NULL,
                parent_item_line.income_tax_region) income_tax_region,
       parent_taxable_dist.po_distribution_id po_distribution_id,  --changed for bug 8713009
	parent_item_line.type_1099 type_1099,
        zd.attribute1 attribute1,
        zd.attribute10 attribute10,
        zd.attribute11 attribute11,
        zd.attribute12 attribute12,
        zd.attribute13 attribute13,
        zd.attribute14 attribute14,
        zd.attribute15 attribute15,
        zd.attribute2 attribute2,
        zd.attribute3 attribute3,
        zd.attribute4 attribute4,
        zd.attribute5 attribute5,
        zd.attribute6 attribute6,
        zd.attribute7 attribute7,
        zd.attribute8 attribute8,
        zd.attribute9 attribute9,
        zd.attribute_category attribute_category,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_item_date) expenditure_item_date,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_organization_id)
           expenditure_organization_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_type) expenditure_type,
        parent_taxable_dist.parent_invoice_id parent_invoice_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', 'E',
         'N', parent_taxable_dist.pa_addition_flag) pa_addition_flag,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.pa_quantity) pa_quantity,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.project_accounting_context)
           project_accounting_context,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.project_id) project_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.task_id) task_id,
        DECODE(NVL(asp.allow_awt_flag, 'N'),
               'Y', DECODE(NVL(pvs.allow_awt_flag, 'N'),
                      'Y', DECODE(NVL(asp.awt_include_tax_amt, 'N'),
                             'Y', DECODE(NVL(zd.inclusive_flag, 'N'),
                                    'Y', DECODE(zd.applied_from_tax_dist_id,
                                           null, parent_taxable_dist.awt_group_id, --Bug8334059
                                           ap_etax_utility_pkg.Get_Prepay_Awt_Group_Id(
                                             parent_taxable_dist.prepay_distribution_id,
                                             P_Calling_Sequence)),
                                    'N', parent_taxable_dist.awt_group_id),
                             NULL),
                      NULL),
               NULL) awt_group_id,
        zd.global_attribute_category global_attribute_category,
        zd.global_attribute1 global_attribute1,
        zd.global_attribute2 global_attribute2,
        zd.global_attribute3 global_attribute3,
        zd.global_attribute4 global_attribute4,
        zd.global_attribute5 global_attribute5,
        zd.global_attribute6 global_attribute6,
        zd.global_attribute7 global_attribute7,
        zd.global_attribute8 global_attribute8,
        zd.global_attribute9 global_attribute9,
        zd.global_attribute10 global_attribute10,
        zd.global_attribute11 global_attribute11,
        zd.global_attribute12 global_attribute12,
        zd.global_attribute13 global_attribute13,
        zd.global_attribute14 global_attribute14,
        zd.global_attribute15 global_attribute15,
        zd.global_attribute16 global_attribute16,
        zd.global_attribute17 global_attribute17,
        zd.global_attribute18 global_attribute18,
        zd.global_attribute19 global_attribute19,
        zd.global_attribute20 global_attribute20,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.award_id) award_id,
        DECODE(zd.ref_doc_dist_id,
          NULL, DECODE(zl.applied_to_trx_id,
              NULL, 'NOT_MATCHED',
              'OTHER_TO_RECEIPT'),
          'NOT_MATCHED') dist_match_type,
         DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         --Bug 8910531
         'N', parent_taxable_dist.rcv_transaction_id) rcv_transaction_id,
        zd.recoverable_flag tax_recoverable_flag,
        parent_taxable_dist.cancellation_flag cancellation_flag,
	zd.trx_line_id invoice_line_number,
        parent_taxable_dist.corrected_invoice_dist_id corrected_invoice_dist_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
          'Y', NULL,
          zd.func_curr_rounding_adjustment) rounding_amt,
        -- the rounding amount in the non-recoverable case will be populated
        -- to the primary distribution later in the cycle.
        decode(NVL(zl.tax_only_line_flag,'N'),
                     'Y', NULL, zd.trx_line_dist_id) charge_applicable_to_dist_id,
        DECODE(zl.ref_doc_trx_id,
          NULL, 'CANDIDATE',
          'PERMANENT') distribution_class,
        zd.tax_rate_id tax_code_id,
        zd.rec_nrec_tax_dist_id detail_tax_dist_id,
        zd.rec_nrec_rate rec_nrec_rate,
        zd.recovery_rate_id recovery_rate_id,
        zd.recovery_rate_code recovery_rate_name,
        zd.recovery_type_code recovery_type_code,
        zd.summary_tax_line_id summary_tax_line_id,
        null extra_po_erv,
        zd.taxable_amt taxable_amount,
        zd.taxable_amt_funcl_curr taxable_base_amount,
        pd.accrue_on_receipt_flag accrue_on_receipt_flag,
        asp.allow_flex_override_flag allow_flex_override_flag,
        fsp.purch_encumbrance_flag purch_encumbrance_flag,
        asp.org_id org_id,
        zd.tax_regime_id tax_regime_id,
        zd.tax_id tax_id,
        zd.tax_status_id tax_status_id,
        zl.tax_jurisdiction_id tax_jurisdiction_id,
        parent_taxable_dist.cancellation_flag parent_dist_cancellation_flag,
        parent_taxable_dist.reversal_flag parent_dist_reversal_flag,
        parent_taxable_dist.parent_reversal_id parent_dist_parent_reversal_id,
        zd.reversed_tax_dist_id reversed_tax_dist_id,
        zd.adjusted_doc_tax_dist_id adjusted_doc_tax_dist_id,
        zd.applied_from_tax_dist_id applied_from_tax_dist_id,
        -- the prepay_distribution_id will be populated with
        -- invoice_distribution_id for the TAX rec or nonrec
        -- asociated
        DECODE(parent_item_line.line_type_lookup_code,
               'PREPAY',
               AP_ETAX_UTILITY_PKG.Get_Dist_Id_For_Tax_Dist_Id(
                 zd.applied_from_tax_dist_id),
               NULL) prepay_distribution_id,
        DECODE(parent_item_line.line_type_lookup_code,
               'PREPAY', DECODE(NVL(zd.recoverable_flag, 'N'),
                           'N', (zd.prd_tax_amt - zd.rec_nrec_tax_amt), NULL),
               NULL) prepay_tax_diff_amount,
       ai.invoice_id     	invoice_id,
       ai.batch_id              batch_id,
       ai.set_of_books_id       set_of_books_id,
	   parent_taxable_dist.pay_awt_group_id        pay_awt_group_id, --Bug8345264
       zd.account_source_tax_rate_id	account_source_tax_rate_id
  FROM zx_trx_headers_gt                gt,
       zx_rec_nrec_dist                 zd,
       zx_lines                         zl,
       ap_invoices_all                  ai,
       ap_supplier_sites_all            pvs,
       ap_system_parameters_all         asp,
       financials_system_params_all     fsp,
       po_distributions_all             pd,
       ap_invoice_lines_all             parent_item_line,
       ap_invoice_distributions_all     parent_taxable_dist
 WHERE gt.APPLICATION_ID                        = zd.APPLICATION_ID
   AND gt.ENTITY_CODE                           = zd.ENTITY_CODE
   AND gt.EVENT_CLASS_CODE                      = zd.EVENT_CLASS_CODE
   AND gt.TRX_ID                                = zd.TRX_ID
   AND zd.tax_line_id                           = zl.tax_line_id
   AND gt.trx_id                                = ai.invoice_id
   AND ai.vendor_site_id                        = pvs.vendor_site_id
   AND ai.set_of_books_id                       = asp.set_of_books_id
   AND ai.org_id                                = asp.org_id
   AND asp.set_of_books_id                      = fsp.set_of_books_id
   AND asp.org_id                               = fsp.org_id
   AND NVL(zd.self_assessed_flag,  'N')         = 'Y'
   AND NVL(zl.reporting_only_flag, 'N')         = 'N'
   AND parent_taxable_dist.po_distribution_id   = pd.po_distribution_id(+)
   AND zd.trx_id                                = parent_item_line.invoice_id(+)
   AND zd.trx_line_id                           = parent_item_line.line_number(+)
   AND zd.trx_id                                = parent_taxable_dist.invoice_id(+)
   AND zd.trx_line_dist_id                      = parent_taxable_dist.invoice_distribution_id(+)
   AND NOT EXISTS
      (SELECT aid.detail_tax_dist_id
         FROM ap_self_assessed_tax_dist_all aid
        WHERE aid.invoice_id            = ai.invoice_id
          AND aid.detail_tax_dist_id    = zd.rec_nrec_tax_dist_id
          AND aid.line_type_lookup_code IN ('REC_TAX','NONREC_TAX'))
   -- Bug 7462582
   -- Reverting the fixes done in bugs 6805527 and 7389822 as Etax bug 7515711 will take care of these fixes.
   /* Added by schitlap, epajaril to fix the issue in Bug 6805527 */
   /*AND (nvl(parent_taxable_dist.reversal_flag, 'N') <> 'Y'
        OR zd.reversed_tax_dist_id IS NULL) -- 7389822*/
  ORDER BY detail_tax_dist_id;


  CURSOR update_tax_self IS
      SELECT /*+ leading(gt,zd) cardinality(gt,1) */
        zd.gl_date accounting_date , --Bug6809792
        /*For tax distributions accounting date will be stamped from zx_rec_nrec_dist
          Ebtax will now store accounting date of opne period in their table*/
        aid.dist_code_combination_id dist_code_combination_id,  --9437885
        -- this ccid is a temporary value that will be used if other conditions
        -- are met before inserting the tax distribution
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', 'REC_TAX',
         'N', 'NONREC_TAX') line_type_lookup_code,
        ap_utilities_pkg.get_gl_period_name(zd.gl_date,ai.org_id)	period_name,
	zd.rec_nrec_tax_amt amount,
        ap_utilities_pkg.ap_round_currency
		(zd.rec_nrec_tax_amt_funcl_curr,asp.base_currency_code) base_amount,
        -- included the decode as part of the prepayment changes.
        -- since for prepayment applic tax variances will not be created,
        -- the base_amount should be the total including variances
        DECODE(NVL(zd.inclusive_flag, 'N'),
         'Y', parent_item_line.description,
         'N', parent_tax_line.description) description,
        DECODE(NVL(zd.inclusive_flag, 'N'),
         'Y', DECODE(parent_item_line.type_1099,
                NULL, NULL,
                parent_item_line.income_tax_region),
         'N', DECODE(parent_tax_line.type_1099,
                NULL, NULL,
                parent_tax_line.income_tax_region)) income_tax_region,
        DECODE(NVL(zd.inclusive_flag, 'N'),
         'Y', parent_item_line.type_1099,
         'N', parent_tax_line.type_1099) type_1099,
        --Bug9346774
        aid.attribute1                                                                 attribute1,
        aid.attribute10                                                                attribute10,
        aid.attribute11                                                                attribute11,
        aid.attribute12                                                                attribute12,
        aid.attribute13                                                                attribute13,
        aid.attribute14                                                                attribute14,
        aid.attribute15                                                                attribute15,
        aid.attribute2                                                                 attribute2,
        aid.attribute3                                                                 attribute3,
        aid.attribute4                                                                 attribute4,
        aid.attribute5                                                                 attribute5,
        aid.attribute6                                                                 attribute6,
        aid.attribute7                                                                 attribute7,
        aid.attribute8                                                                 attribute8,
        aid.attribute9                                                                 attribute9,
        aid.attribute_category                                                         attribute_category,
        --Bug9346774
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_item_date) expenditure_item_date,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_organization_id)
           expenditure_organization_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.expenditure_type) expenditure_type,
        parent_taxable_dist.parent_invoice_id parent_invoice_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', 'E',
         'N', parent_taxable_dist.pa_addition_flag) pa_addition_flag,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.pa_quantity) pa_quantity,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.project_accounting_context)
           project_accounting_context,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.project_id) project_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.task_id) task_id,
        DECODE(NVL(asp.allow_awt_flag, 'N'),
               'Y', DECODE(NVL(pvs.allow_awt_flag, 'N'),
                      'Y', DECODE(NVL(asp.awt_include_tax_amt, 'N'),
                             'Y', DECODE(NVL(zd.inclusive_flag, 'N'),
                                    'Y', DECODE(zd.applied_from_tax_dist_id,
                                           null, parent_taxable_dist.awt_group_id,  --Bug8334059
                                           ap_etax_utility_pkg.Get_Prepay_Awt_Group_Id(
                                             parent_taxable_dist.prepay_distribution_id,
                                             P_Calling_Sequence)),
                                    'N', parent_taxable_dist.awt_group_id),
                             NULL),
                      NULL),
               NULL) awt_group_id,
        --Bug9346774
        aid.global_attribute_category                                                           global_attribute_category,
        aid.global_attribute1                                                                   global_attribute1,
        aid.global_attribute2                                                                   global_attribute2,
        aid.global_attribute3                                                                   global_attribute3,
        aid.global_attribute4                                                                   global_attribute4,
        aid.global_attribute5                                                                   global_attribute5,
        aid.global_attribute6                                                                   global_attribute6,
        aid.global_attribute7                                                                   global_attribute7,
        aid.global_attribute8                                                                   global_attribute8,
        aid.global_attribute9                                                                   global_attribute9,
        aid.global_attribute10                                                                  global_attribute10,
        aid.global_attribute11                                                                  global_attribute11,
        aid.global_attribute12                                                                  global_attribute12,
        aid.global_attribute13                                                                  global_attribute13,
        aid.global_attribute14                                                                  global_attribute14,
        aid.global_attribute15                                                                  global_attribute15,
        aid.global_attribute16                                                                  global_attribute16,
        aid.global_attribute17                                                                  global_attribute17,
        aid.global_attribute18                                                                  global_attribute18,
        aid.global_attribute19                                                                  global_attribute19,
        aid.global_attribute20                                                                  global_attribute20,
        --Bug9346774
        DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         'N', parent_taxable_dist.award_id) award_id,
        DECODE(zd.ref_doc_dist_id,
          NULL, DECODE(zl.applied_to_trx_id,
              NULL, 'NOT_MATCHED',
              'OTHER_TO_RECEIPT'),
          'NOT_MATCHED') dist_match_type,
         DECODE(NVL(zd.recoverable_flag, 'N'),
         'Y', NULL,
         --Bug 8910531
         'N', parent_taxable_dist.rcv_transaction_id) rcv_transaction_id,
        zd.recoverable_flag tax_recoverable_flag,
        parent_taxable_dist.cancellation_flag cancellation_flag,
        DECODE(NVL(zd.inclusive_flag, 'N'),
         'Y', zd.trx_line_id,
         'N', parent_tax_line.line_number) invoice_line_number,
        parent_taxable_dist.corrected_invoice_dist_id corrected_invoice_dist_id,
        DECODE(NVL(zd.recoverable_flag, 'N'),
          'Y', NULL,
          zd.func_curr_rounding_adjustment) rounding_amt,
        -- This will update the rounding_amt in the recoverable dist
        -- for the non-recoverable the primary distribution will be
        -- updated later on
        decode(NVL(zl.tax_only_line_flag,'N'),
                     'Y', NULL, zd.trx_line_dist_id) charge_applicable_to_dist_id,
        DECODE(zl.ref_doc_trx_id,
          NULL, 'CANDIDATE',
          'PERMANENT') distribution_class,
        zd.tax_rate_id tax_code_id,
        zd.rec_nrec_tax_dist_id detail_tax_dist_id,
        zd.rec_nrec_rate rec_nrec_rate,
        zd.recovery_rate_id recovery_rate_id,
        zd.recovery_rate_code recovery_rate_name,
        zd.recovery_type_code recovery_type_code,
        zd.taxable_amt taxable_amount,
        zd.taxable_amt_funcl_curr taxable_base_amount,
        zd.summary_tax_line_id summary_tax_line_id,
        null extra_po_erv,
        -- (zd.applied_to_doc_erv - zx.reference_doc_erv) null extra_po_erv,
        DECODE(parent_item_line.line_type_lookup_code,
          'PREPAY', DECODE(NVL(zd.recoverable_flag, 'N'),
                      'N', (zd.prd_tax_amt - zd.rec_nrec_tax_amt), NULL),
          NULL) prepay_tax_diff_amount,
        aid.invoice_distribution_id invoice_distribution_id,
		parent_taxable_dist.pay_awt_group_id        pay_awt_group_id,   --Bug8345264
        zd.account_source_tax_rate_id
  FROM  zx_trx_headers_gt               gt,
        zx_rec_nrec_dist                zd,
        zx_lines                        zl,
        ap_invoices_all                 ai,
        ap_self_assessed_tax_dist_all	aid,
        ap_supplier_sites_all           pvs,
        ap_system_parameters_all        asp,
        financials_system_params_all    fsp,
        po_distributions_all            pd,
        ap_invoice_lines_all            parent_tax_line,
        ap_invoice_lines_all            parent_item_line,
        ap_invoice_distributions_all    parent_taxable_dist
 WHERE  gt.APPLICATION_ID                        = zd.APPLICATION_ID
   AND  gt.ENTITY_CODE                           = zd.ENTITY_CODE
   AND  gt.EVENT_CLASS_CODE                      = zd.EVENT_CLASS_CODE
   AND  gt.TRX_ID                                = zd.TRX_ID
   AND  zd.tax_line_id                           = zl.tax_line_id
   AND  gt.trx_id                                = ai.invoice_id
   AND  ai.invoice_id                            = aid.invoice_id
   AND  aid.detail_tax_dist_id                   = zd.rec_nrec_tax_dist_id
   AND  aid.line_type_lookup_code                IN ('REC_TAX','NONREC_TAX')
   AND  nvl(aid.reversal_flag,'N')               <> 'Y'
   AND  ai.vendor_site_id                        = pvs.vendor_site_id
   AND  ai.set_of_books_id                       = asp.set_of_books_id
   AND  ai.org_id                                = asp.org_id
   AND  asp.set_of_books_id                      = fsp.set_of_books_id
   AND  asp.org_id                               = fsp.org_id
   AND  parent_taxable_dist.po_distribution_id   = pd.po_distribution_id(+)
   AND  zd.trx_id                                = parent_tax_line.invoice_id (+)
   AND  zd.summary_tax_line_id                   = parent_tax_line.summary_tax_line_id(+)
   AND  zd.trx_id                                = parent_item_line.invoice_id(+)
   AND  zd.trx_line_id                           = parent_item_line.line_number(+)
   AND  zd.trx_id                                = parent_taxable_dist.invoice_id(+)
   AND  zd.trx_line_dist_id                      = parent_taxable_dist.invoice_distribution_id(+);


  l_dist_code_combination_id	ap_invoice_distributions_all.dist_code_combination_id%TYPE;
  l_allow_pa_override		VARCHAR2(1);

  -- Variables for the eTax API to get the default ccids

  l_return_status_service       VARCHAR2(4000);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(4000);
  l_tax_liab_ccid		ap_invoice_distributions_all.dist_code_combination_id%TYPE;

  l_trx_id			NUMBER;
  l_trx_line_id			NUMBER;
  l_trx_line_dist_id		NUMBER;
  l_summary_tax_line_id		NUMBER;
  l_rec_nrec_tax_dist_id	NUMBER;
  l_tax_line_id			NUMBER;
  l_application_id		NUMBER;

  l_self_assessed_flag		VARCHAR2(20);
  l_recoverable_flag		VARCHAR2(20);
  l_reporting_only_flag		VARCHAR2(20);

  l_first 			NUMBER;
  l_last			NUMBER;

  -- Project LCM 7588322
  l_lcm_enabled                   VARCHAR2(1) := 'N';
  l_rcv_transaction_id            NUMBER;
  l_lcm_account_id                NUMBER;
  l_tax_variance_account_id       NUMBER;
  l_def_charges_account_id        NUMBER;
  l_exchange_variance_account_id  NUMBER;
  l_inv_variance_account_id       NUMBER;

  TYPE LineList IS TABLE OF VARCHAR2(25);
  linetype  LineList := LineList('TIPV', 'TRV', 'TERV');

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Return_Tax_Distributions<-'||
                               P_calling_sequence;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ETAX_UTILITY_PKG.Return_Tax_Distributions(+)');
    END IF;

    DELETE FROM AP_Line_Temp_GT;

    FORALL i IN linetype.FIRST..linetype.LAST
	INSERT INTO AP_Line_Temp_GT (Line_Type)
	VALUES (linetype(i));

    -------------------------------------------------------------------
    l_debug_info := 'Get profile option info';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    l_allow_pa_override := FND_PROFILE.VALUE('PA_ALLOW_FLEXBUILDER_OVERRIDES');

    -------------------------------------------------------------------
    l_debug_info := 'Get tax distributions for update';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    OPEN UPDATE_TAX_DIST;
    LOOP
        FETCH UPDATE_TAX_DIST
         BULK COLLECT INTO L_INV_DIST_UPD
        LIMIT AP_ETAX_PKG.G_BATCH_LIMIT;

        EXIT WHEN UPDATE_TAX_DIST%NOTFOUND
                  AND L_INV_DIST_UPD.COUNT <= 0;

	-------------------------------------------------------------------
	l_debug_info := 'Tax distributions updated: '||l_inv_dist_upd.count;
	-------------------------------------------------------------------
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

	IF (l_inv_dist_upd.COUNT <> 0) THEN

	    FOR j IN l_inv_dist_upd.FIRST..l_inv_dist_upd.LAST LOOP



	         UPDATE ap_invoice_distributions_all
	          SET 	accounting_date 		= l_inv_dist_upd(j).accounting_date,
			        last_updated_by 		= l_user_id,
	            	last_update_date 		= l_sysdate,
	            	line_type_lookup_code 	= l_inv_dist_upd(j).line_type_lookup_code,
	            	period_name 			= l_inv_dist_upd(j).period_name,
	            	amount 				= l_inv_dist_upd(j).amount,
	            	base_amount 			= decode(l_inv_dist_upd(j).base_amount,
                                                     0, decode(l_inv_dist_upd(j).amount, 0, l_inv_dist_upd(j).base_amount, NULL),
                                                     l_inv_dist_upd(j).base_amount),
	            	description 			= l_inv_dist_upd(j).description,
	            	income_tax_region 		= l_inv_dist_upd(j).income_tax_region,
	            	last_update_login 		= l_login_id,
	            	type_1099 			= l_inv_dist_upd(j).type_1099,
	            	attribute1 			= l_inv_dist_upd(j).attribute1,
	            	attribute10 			= l_inv_dist_upd(j).attribute10,
	            	attribute11 			= l_inv_dist_upd(j).attribute11,
	            	attribute12 			= l_inv_dist_upd(j).attribute12,
	            	attribute13 			= l_inv_dist_upd(j).attribute13,
	            	attribute14 			= l_inv_dist_upd(j).attribute14,
	            	attribute15 			= l_inv_dist_upd(j).attribute15,
	            	attribute2 			= l_inv_dist_upd(j).attribute2,
	            	attribute3 			= l_inv_dist_upd(j).attribute3,
	            	attribute4 			= l_inv_dist_upd(j).attribute4,
	            	attribute5 			= l_inv_dist_upd(j).attribute5,
	            	attribute6 			= l_inv_dist_upd(j).attribute6,
	            	attribute7 			= l_inv_dist_upd(j).attribute7,
	            	attribute8 			= l_inv_dist_upd(j).attribute8,
	            	attribute9 			= l_inv_dist_upd(j).attribute9,
	            	attribute_category 		= l_inv_dist_upd(j).attribute_category,
	            	expenditure_item_date 		= l_inv_dist_upd(j).expenditure_item_date,
	            	expenditure_organization_id 	= l_inv_dist_upd(j).expenditure_organization_id,
	            	expenditure_type 		= l_inv_dist_upd(j).expenditure_type,
	            	parent_invoice_id 		= l_inv_dist_upd(j).parent_invoice_id,
	            	pa_addition_flag 		= l_inv_dist_upd(j).pa_addition_flag,
	            	pa_quantity 			= l_inv_dist_upd(j).pa_quantity,
	            	project_accounting_context 	= l_inv_dist_upd(j).project_accounting_context,
	            	project_id 			= l_inv_dist_upd(j).project_id,
	            	task_id 			= l_inv_dist_upd(j).task_id,
	            	awt_group_id 			= l_inv_dist_upd(j).awt_group_id,
	            	global_attribute_category 	= l_inv_dist_upd(j).global_attribute_category,
	            	global_attribute1 		= l_inv_dist_upd(j).global_attribute1,
	            	global_attribute2 		= l_inv_dist_upd(j).global_attribute2,
	            	global_attribute3 		= l_inv_dist_upd(j).global_attribute3,
	            	global_attribute4 		= l_inv_dist_upd(j).global_attribute4,
	            	global_attribute5 		= l_inv_dist_upd(j).global_attribute5,
	            	global_attribute6 		= l_inv_dist_upd(j).global_attribute6,
	            	global_attribute7 		= l_inv_dist_upd(j).global_attribute7,
	            	global_attribute8 		= l_inv_dist_upd(j).global_attribute8,
	            	global_attribute9 		= l_inv_dist_upd(j).global_attribute9,
	            	global_attribute10 		= l_inv_dist_upd(j).global_attribute10,
	            	global_attribute11 		= l_inv_dist_upd(j).global_attribute11,
	            	global_attribute12 		= l_inv_dist_upd(j).global_attribute12,
	            	global_attribute13 		= l_inv_dist_upd(j).global_attribute13,
	            	global_attribute14 		= l_inv_dist_upd(j).global_attribute14,
	            	global_attribute15 		= l_inv_dist_upd(j).global_attribute15,
	            	global_attribute16 		= l_inv_dist_upd(j).global_attribute16,
	            	global_attribute17 		= l_inv_dist_upd(j).global_attribute17,
	            	global_attribute18 		= l_inv_dist_upd(j).global_attribute18,
	            	global_attribute19 		= l_inv_dist_upd(j).global_attribute19,
	            	global_attribute20 		= l_inv_dist_upd(j).global_attribute20,
	            	award_id 			= l_inv_dist_upd(j).award_id,
	            	dist_match_type 		= l_inv_dist_upd(j).dist_match_type,
	            	rcv_transaction_id 		= l_inv_dist_upd(j).rcv_transaction_id,
	            	tax_recoverable_flag 		= l_inv_dist_upd(j).tax_recoverable_flag,
	            	cancellation_flag 		= l_inv_dist_upd(j).cancellation_flag,
	            	--invoice_line_number 		= l_inv_dist_upd(j).invoice_line_number,
        	    	corrected_invoice_dist_id 	= l_inv_dist_upd(j).corrected_invoice_dist_id,
	            	rounding_amt 			= l_inv_dist_upd(j).rounding_amt,
	            	charge_applicable_to_dist_id 	= l_inv_dist_upd(j).charge_applicable_to_dist_id,
	            	--distribution_class 		= l_inv_dist_upd(j).distribution_class,    --Bug6678578
	            	tax_code_id 			= l_inv_dist_upd(j).tax_code_id,
	            	detail_tax_dist_id 		= l_inv_dist_upd(j).detail_tax_dist_id,
	            	rec_nrec_rate 			= l_inv_dist_upd(j).rec_nrec_rate,
	            	recovery_rate_id 		= l_inv_dist_upd(j).recovery_rate_id,
	            	recovery_rate_name 		= l_inv_dist_upd(j).recovery_rate_name,
	            	recovery_type_code 		= l_inv_dist_upd(j).recovery_type_code,
	            	taxable_amount 			= l_inv_dist_upd(j).taxable_amount,
	            	taxable_base_amount 	= l_inv_dist_upd(j).taxable_base_amount,
	            	summary_tax_line_id 	= l_inv_dist_upd(j).summary_tax_line_id,
	            	extra_po_erv 			= l_inv_dist_upd(j).extra_po_erv,
	            	prepay_tax_diff_amount 	= l_inv_dist_upd(j).prepay_tax_diff_amount,
			        match_status_flag		= decode (amount, l_inv_dist_upd(j).amount,
									                  match_status_flag, 'N')
	          WHERE invoice_distribution_id = l_inv_dist_upd(j).invoice_distribution_id;

              	-------------------------------------------------------------------
	            l_debug_info := 'Tax dist id updated: '||l_inv_dist_upd(j).invoice_distribution_id||
                                ' Tax Detail Tax Dist Id: '||l_inv_dist_upd(j).detail_tax_dist_id||
                                ' Summary Tax Line Id: '||l_inv_dist_upd(j).summary_tax_line_id||
                                ' Amt: '||l_inv_dist_upd(j).amount||
                                ' Base Amt: '||l_inv_dist_upd(j).base_amount;

	            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	            END IF;
	            -------------------------------------------------------------------

             END LOOP;
             L_INV_DIST_UPD.DELETE;
         END IF;
    END LOOP;
    CLOSE UPDATE_TAX_DIST;


    -------------------------------------------------------------------
    l_debug_info := 'Get tax variance distributions for update';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
    -------------------------------------------------------------------

    OPEN UPDATE_TAX_VARIANCES;
    LOOP
        FETCH UPDATE_TAX_VARIANCES
         BULK COLLECT INTO L_INV_DIST_UPD
        LIMIT AP_ETAX_PKG.G_BATCH_LIMIT;

        EXIT WHEN UPDATE_TAX_VARIANCES%NOTFOUND
                  AND L_INV_DIST_UPD.COUNT <= 0;

	-------------------------------------------------------------------
	l_debug_info := 'Tax Variance distributions updated: '||l_inv_dist_upd.count;
	-------------------------------------------------------------------
	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;

	IF (l_inv_dist_upd.COUNT <> 0) THEN

	    FOR j IN l_inv_dist_upd.FIRST..l_inv_dist_upd.LAST LOOP

	         UPDATE ap_invoice_distributions_all
	          SET 	accounting_date 		= l_inv_dist_upd(j).accounting_date,
			        last_updated_by 		= l_user_id,
	            	last_update_date 		= l_sysdate,
	            	line_type_lookup_code 		= l_inv_dist_upd(j).line_type_lookup_code,
	            	period_name 			= l_inv_dist_upd(j).period_name,
	            	amount 				= l_inv_dist_upd(j).amount,
	            	base_amount 			= decode(l_inv_dist_upd(j).base_amount,
					                			     0, decode(l_inv_dist_upd(j).amount, 0, l_inv_dist_upd(j).base_amount, NULL),
                                                     l_inv_dist_upd(j).base_amount),
	            	description 			= l_inv_dist_upd(j).description,
	            	income_tax_region 		= l_inv_dist_upd(j).income_tax_region,
	            	last_update_login 		= l_login_id,
	            	type_1099 			= l_inv_dist_upd(j).type_1099,
	            	attribute1 			= l_inv_dist_upd(j).attribute1,
	            	attribute10 			= l_inv_dist_upd(j).attribute10,
	            	attribute11 			= l_inv_dist_upd(j).attribute11,
	            	attribute12 			= l_inv_dist_upd(j).attribute12,
	            	attribute13 			= l_inv_dist_upd(j).attribute13,
	            	attribute14 			= l_inv_dist_upd(j).attribute14,
	            	attribute15 			= l_inv_dist_upd(j).attribute15,
	            	attribute2 			= l_inv_dist_upd(j).attribute2,
	            	attribute3 			= l_inv_dist_upd(j).attribute3,
	            	attribute4 			= l_inv_dist_upd(j).attribute4,
	            	attribute5 			= l_inv_dist_upd(j).attribute5,
	            	attribute6 			= l_inv_dist_upd(j).attribute6,
	            	attribute7 			= l_inv_dist_upd(j).attribute7,
	            	attribute8 			= l_inv_dist_upd(j).attribute8,
	            	attribute9 			= l_inv_dist_upd(j).attribute9,
	            	attribute_category 		= l_inv_dist_upd(j).attribute_category,
	            	expenditure_item_date 		= l_inv_dist_upd(j).expenditure_item_date,
	            	expenditure_organization_id 	= l_inv_dist_upd(j).expenditure_organization_id,
	            	expenditure_type 		= l_inv_dist_upd(j).expenditure_type,
	            	parent_invoice_id 		= l_inv_dist_upd(j).parent_invoice_id,
	            	pa_addition_flag 		= l_inv_dist_upd(j).pa_addition_flag,
	            	pa_quantity 			= l_inv_dist_upd(j).pa_quantity,
	            	project_accounting_context 	= l_inv_dist_upd(j).project_accounting_context,
	            	project_id 			= l_inv_dist_upd(j).project_id,
	            	task_id 			= l_inv_dist_upd(j).task_id,
	            	awt_group_id 			= l_inv_dist_upd(j).awt_group_id,
	            	global_attribute_category 	= l_inv_dist_upd(j).global_attribute_category,
	            	global_attribute1 		= l_inv_dist_upd(j).global_attribute1,
	            	global_attribute2 		= l_inv_dist_upd(j).global_attribute2,
	            	global_attribute3 		= l_inv_dist_upd(j).global_attribute3,
	            	global_attribute4 		= l_inv_dist_upd(j).global_attribute4,
	            	global_attribute5 		= l_inv_dist_upd(j).global_attribute5,
	            	global_attribute6 		= l_inv_dist_upd(j).global_attribute6,
	            	global_attribute7 		= l_inv_dist_upd(j).global_attribute7,
	            	global_attribute8 		= l_inv_dist_upd(j).global_attribute8,
	            	global_attribute9 		= l_inv_dist_upd(j).global_attribute9,
	            	global_attribute10 		= l_inv_dist_upd(j).global_attribute10,
	            	global_attribute11 		= l_inv_dist_upd(j).global_attribute11,
	            	global_attribute12 		= l_inv_dist_upd(j).global_attribute12,
	            	global_attribute13 		= l_inv_dist_upd(j).global_attribute13,
	            	global_attribute14 		= l_inv_dist_upd(j).global_attribute14,
	            	global_attribute15 		= l_inv_dist_upd(j).global_attribute15,
	            	global_attribute16 		= l_inv_dist_upd(j).global_attribute16,
	            	global_attribute17 		= l_inv_dist_upd(j).global_attribute17,
	            	global_attribute18 		= l_inv_dist_upd(j).global_attribute18,
	            	global_attribute19 		= l_inv_dist_upd(j).global_attribute19,
	            	global_attribute20 		= l_inv_dist_upd(j).global_attribute20,
	            	award_id 			= l_inv_dist_upd(j).award_id,
	            	dist_match_type 		= l_inv_dist_upd(j).dist_match_type,
	            	rcv_transaction_id 		= l_inv_dist_upd(j).rcv_transaction_id,
	            	tax_recoverable_flag 		= l_inv_dist_upd(j).tax_recoverable_flag,
	            	cancellation_flag 		= l_inv_dist_upd(j).cancellation_flag,
	            	--invoice_line_number 		= l_inv_dist_upd(j).invoice_line_number,
        	    	corrected_invoice_dist_id 	= l_inv_dist_upd(j).corrected_invoice_dist_id,
	            	rounding_amt 			= l_inv_dist_upd(j).rounding_amt,
	            	charge_applicable_to_dist_id 	= l_inv_dist_upd(j).charge_applicable_to_dist_id,
	            	--distribution_class 		= l_inv_dist_upd(j).distribution_class, --Bug6678578
	            	tax_code_id 			= l_inv_dist_upd(j).tax_code_id,
	            	detail_tax_dist_id 		= l_inv_dist_upd(j).detail_tax_dist_id,
	            	rec_nrec_rate 			= l_inv_dist_upd(j).rec_nrec_rate,
	            	recovery_rate_id 		= l_inv_dist_upd(j).recovery_rate_id,
	            	recovery_rate_name 		= l_inv_dist_upd(j).recovery_rate_name,
	            	recovery_type_code 		= l_inv_dist_upd(j).recovery_type_code,
	            	taxable_amount 			= l_inv_dist_upd(j).taxable_amount,
	            	taxable_base_amount 	= l_inv_dist_upd(j).taxable_base_amount,
	            	summary_tax_line_id 	= l_inv_dist_upd(j).summary_tax_line_id,
	            	extra_po_erv 			= l_inv_dist_upd(j).extra_po_erv,
	            	prepay_tax_diff_amount 	= l_inv_dist_upd(j).prepay_tax_diff_amount,
                    match_status_flag       = decode (amount, l_inv_dist_upd(j).amount,
                                                      match_status_flag, 'N')
	          WHERE invoice_distribution_id = l_inv_dist_upd(j).invoice_distribution_id;

                -------------------------------------------------------------------
	            l_debug_info := 'Tax dist id updated: '||l_inv_dist_upd(j).invoice_distribution_id||
                                ' Tax Detail Tax Dist Id: '||l_inv_dist_upd(j).detail_tax_dist_id||
                                ' Summary Tax Line Id: '||l_inv_dist_upd(j).summary_tax_line_id||
                                ' Amt: '||l_inv_dist_upd(j).amount||
                                ' Base Amt: '||l_inv_dist_upd(j).base_amount;

	            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	            END IF;
	            -------------------------------------------------------------------

             END LOOP;
             L_INV_DIST_UPD.DELETE;
         END IF;
    END LOOP;
    CLOSE UPDATE_TAX_VARIANCES;


    -------------------------------------------------------------------
    l_debug_info := 'Step 5: Get tax distributions for update';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
    -------------------------------------------------------------------

    OPEN UPDATE_TAX_SELF;
    LOOP
        FETCH UPDATE_TAX_SELF
         BULK COLLECT INTO L_INV_SELF_UPD
        LIMIT AP_ETAX_PKG.G_BATCH_LIMIT;

        EXIT WHEN UPDATE_TAX_SELF%NOTFOUND
                  AND L_INV_DIST_UPD.COUNT <= 0;

	    -------------------------------------------------------------------
    	l_debug_info := 'Step 5: Self assessed dist updated: '||l_inv_self_upd.COUNT;
    	-------------------------------------------------------------------
    	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      	    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    	END IF;

    	IF (l_inv_self_upd.COUNT <> 0) THEN

      	    FOR j IN l_inv_self_upd.FIRST..l_inv_self_upd.LAST LOOP

	        UPDATE ap_self_assessed_tax_dist_all
	        SET accounting_date 		= l_inv_self_upd(j).accounting_date,
		        last_updated_by 		= l_user_id,
	            last_update_date 		= l_sysdate,
	            line_type_lookup_code 	= l_inv_self_upd(j).line_type_lookup_code,
	            period_name 		= l_inv_self_upd(j).period_name,
	            amount 			= l_inv_self_upd(j).amount,
	            base_amount 		= decode(l_inv_self_upd(j).base_amount,
                                             0, decode(l_inv_self_upd(j).amount, 0, l_inv_self_upd(j).base_amount, NULL),
                                             l_inv_self_upd(j).base_amount),
	            description 		= l_inv_self_upd(j).description,
	            income_tax_region 	= l_inv_self_upd(j).income_tax_region,
	            last_update_login 	= l_login_id,
	            type_1099 			= l_inv_self_upd(j).type_1099,
	            attribute1 			= l_inv_self_upd(j).attribute1,
	            attribute10 		= l_inv_self_upd(j).attribute10,
	            attribute11 		= l_inv_self_upd(j).attribute11,
	            attribute12 		= l_inv_self_upd(j).attribute12,
	            attribute13 		= l_inv_self_upd(j).attribute13,
	            attribute14 		= l_inv_self_upd(j).attribute14,
	            attribute15 		= l_inv_self_upd(j).attribute15,
	            attribute2 			= l_inv_self_upd(j).attribute2,
	            attribute3 			= l_inv_self_upd(j).attribute3,
	            attribute4 			= l_inv_self_upd(j).attribute4,
	            attribute5 			= l_inv_self_upd(j).attribute5,
	            attribute6 			= l_inv_self_upd(j).attribute6,
	            attribute7 			= l_inv_self_upd(j).attribute7,
	            attribute8 			= l_inv_self_upd(j).attribute8,
	            attribute9 			= l_inv_self_upd(j).attribute9,
	            attribute_category 		= l_inv_self_upd(j).attribute_category,
	            expenditure_item_date 	= l_inv_self_upd(j).expenditure_item_date,
	            expenditure_organization_id = l_inv_self_upd(j).expenditure_organization_id,
	            expenditure_type 		= l_inv_self_upd(j).expenditure_type,
	            parent_invoice_id 		= l_inv_self_upd(j).parent_invoice_id,
	            pa_addition_flag 		= l_inv_self_upd(j).pa_addition_flag,
	            pa_quantity 		= l_inv_self_upd(j).pa_quantity,
	            project_accounting_context 	= l_inv_self_upd(j).project_accounting_context,
	            project_id 			= l_inv_self_upd(j).project_id,
	            task_id 			= l_inv_self_upd(j).task_id,
				--Bug8334059 Awt_group_id need not be updated since awt is not calculated
	            --awt_group_id 		= l_inv_self_upd(j).awt_group_id,
	            global_attribute_category 	= l_inv_self_upd(j).global_attribute_category,
	            global_attribute1 		= l_inv_self_upd(j).global_attribute1,
	            global_attribute2 		= l_inv_self_upd(j).global_attribute2,
	            global_attribute3 		= l_inv_self_upd(j).global_attribute3,
	            global_attribute4 		= l_inv_self_upd(j).global_attribute4,
	            global_attribute5 		= l_inv_self_upd(j).global_attribute5,
	            global_attribute6 		= l_inv_self_upd(j).global_attribute6,
	            global_attribute7 		= l_inv_self_upd(j).global_attribute7,
	            global_attribute8 		= l_inv_self_upd(j).global_attribute8,
	            global_attribute9 		= l_inv_self_upd(j).global_attribute9,
	            global_attribute10 		= l_inv_self_upd(j).global_attribute10,
	            global_attribute11 		= l_inv_self_upd(j).global_attribute11,
	            global_attribute12 		= l_inv_self_upd(j).global_attribute12,
	            global_attribute13 		= l_inv_self_upd(j).global_attribute13,
	            global_attribute14 		= l_inv_self_upd(j).global_attribute14,
	            global_attribute15 		= l_inv_self_upd(j).global_attribute15,
	            global_attribute16 		= l_inv_self_upd(j).global_attribute16,
	            global_attribute17 		= l_inv_self_upd(j).global_attribute17,
	            global_attribute18 		= l_inv_self_upd(j).global_attribute18,
	            global_attribute19 		= l_inv_self_upd(j).global_attribute19,
	            global_attribute20 		= l_inv_self_upd(j).global_attribute20,
	            award_id 			    = l_inv_self_upd(j).award_id,
	            dist_match_type 		= l_inv_self_upd(j).dist_match_type,
	            rcv_transaction_id 		= l_inv_self_upd(j).rcv_transaction_id,
	            tax_recoverable_flag 	= l_inv_self_upd(j).tax_recoverable_flag,
	            cancellation_flag 		= l_inv_self_upd(j).cancellation_flag,
	            invoice_line_number 	= l_inv_self_upd(j).invoice_line_number,
	            corrected_invoice_dist_id 	= l_inv_self_upd(j).corrected_invoice_dist_id,
	            rounding_amt 		= l_inv_self_upd(j).rounding_amt,
	            charge_applicable_to_dist_id = l_inv_self_upd(j).charge_applicable_to_dist_id,
	            --distribution_class 		= l_inv_self_upd(j).distribution_class, --Bug6678578
	            tax_code_id 		    = l_inv_self_upd(j).tax_code_id,
	            detail_tax_dist_id 		= l_inv_self_upd(j).detail_tax_dist_id,
	            rec_nrec_rate 		    = l_inv_self_upd(j).rec_nrec_rate,
	            recovery_rate_id 		= l_inv_self_upd(j).recovery_rate_id,
	            recovery_rate_name 		= l_inv_self_upd(j).recovery_rate_name,
	            recovery_type_code 		= l_inv_self_upd(j).recovery_type_code,
	            taxable_amount 		    = l_inv_self_upd(j).taxable_amount,
	            taxable_base_amount 	= l_inv_self_upd(j).taxable_base_amount,
	            summary_tax_line_id 	= l_inv_self_upd(j).summary_tax_line_id,
	            extra_po_erv 		    = l_inv_self_upd(j).extra_po_erv,
	            prepay_tax_diff_amount 	=  l_inv_self_upd(j).prepay_tax_diff_amount
	        WHERE invoice_distribution_id = l_inv_self_upd(j).invoice_distribution_id;


            -------------------------------------------------------------------
	            l_debug_info := 'Tax dist id updated: '||l_inv_self_upd(j).invoice_distribution_id||
                                ' Tax Detail Tax Dist Id: '||l_inv_self_upd(j).detail_tax_dist_id||
                                ' Summary Tax Line Id: '||l_inv_self_upd(j).summary_tax_line_id||
                                ' Amt: '||l_inv_self_upd(j).amount||
                                ' Base Amt: '||l_inv_self_upd(j).base_amount;

	            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	            END IF;
	        -------------------------------------------------------------------

            END LOOP;
            L_INV_SELF_UPD.DELETE;
        END IF;
    END LOOP;
    CLOSE UPDATE_TAX_SELF;

    -------------------------------------------------------------------
    l_debug_info := 'Step 6: Get tax distributions for insert';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
    -------------------------------------------------------------------
    OPEN INSERT_TAX_DIST;
    LOOP
        l_dist_code_combination_id := NULL; -- bug 9690870

        FETCH INSERT_TAX_DIST
         BULK COLLECT INTO L_INV_DIST_INS
        LIMIT AP_ETAX_PKG.G_BATCH_LIMIT;

        EXIT WHEN INSERT_TAX_DIST%NOTFOUND
                  AND L_INV_DIST_INS.COUNT <= 0;

        IF (l_inv_dist_ins.COUNT <> 0) THEN

            -------------------------------------------------------------------
            l_debug_info := 'Tax distributions to insert: '||l_inv_dist_ins.COUNT;
            -------------------------------------------------------------------
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;

            FOR i IN l_inv_dist_ins.FIRST..l_inv_dist_ins.LAST LOOP

                IF (l_inv_dist_ins(i).line_type_lookup_code =  'NONREC_TAX') THEN

	           IF ( l_inv_dist_ins(i).po_distribution_id IS NOT NULL OR
	                l_inv_dist_ins(i).rcv_transaction_id IS NOT NULL) THEN

	              IF ( l_inv_dist_ins(i).accrue_on_receipt_flag = 'Y' OR
	                   --l_inv_dist_ins(i).allow_flex_override_flag = 'Y' -- Bug 6720793
	                   l_inv_dist_ins(i).purch_encumbrance_flag = 'Y') THEN

                           -------------------------------------------------------------------
                           l_debug_info := 'PO: Setting Non-Rec tax account same as its parent';
                           -------------------------------------------------------------------
                           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                           END IF;

                           l_dist_code_combination_id := l_inv_dist_ins(i).dist_code_combination_id;

	              END IF;

	           ELSIF ( l_inv_dist_ins(i).project_id IS NOT NULL AND
	                   l_allow_pa_override = 'N') THEN

	              l_dist_code_combination_id := l_inv_dist_ins(i).dist_code_combination_id;

	           END IF;


                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'before geting ccid from corresponding tax distribution');
                   END IF;
                   -- This section to get ccid from corresponding tax distribution if
	           -- line discard/invoice cancellation or correction
	           -- quick credit or prepayment application/unapplication

	           IF (l_inv_dist_ins(i).parent_dist_cancellation_flag = 'Y' OR
	               (l_inv_dist_ins(i).parent_dist_reversal_flag = 'Y'
	                and l_inv_dist_ins(i).parent_dist_parent_reversal_id IS NOT NULL
					AND l_inv_dist_ins(i).reversed_tax_dist_id IS NOT NULL)) THEN -- bug 7389822 --Bugg 9034372

                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'geting ccid for discard, cancellation');
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'l_inv_dist_ins(i).parent_dist_cancellation_flag'||l_inv_dist_ins(i).parent_dist_cancellation_flag);
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_invoice_header_rec.quick_credit'||p_invoice_header_rec.quick_credit);
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'p_invoice_header_rec.credited_invoice_id'||to_char(p_invoice_header_rec.credited_invoice_id));
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'l_inv_dist_ins(i).parent_dist_reversal_flag'||l_inv_dist_ins(i).parent_dist_reversal_flag);
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'l_inv_dist_ins(i).parent_dist_parent_reversal_id'||to_char(l_inv_dist_ins(i).parent_dist_parent_reversal_id));
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'l_inv_dist_ins(i).reversed_tax_dist_id'||to_char(l_inv_dist_ins(i).reversed_tax_dist_id));
                      END IF;

                      --Bug fix 6653070, bug fix 6687031
	              SELECT dist_code_combination_id
	                INTO l_dist_code_combination_id
	                FROM ap_invoice_distributions_all
	               WHERE detail_tax_dist_id = l_inv_dist_ins(i).reversed_tax_dist_id
	                 AND line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX','TIPV', 'TRV', 'TERV')
                         AND rownum =1;--Bug7241425

                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'after geting ccid for discard, cancellation');
                      END IF;

                   --Below ELSIF will execute only during Quick Credit Operation
                   --Batch Validation and Online Validation have no impact due to
                   --this condition though wrong invoice reference is present in header rec.

	           ELSIF (nvl(p_invoice_header_rec.quick_credit,'N') <> 'Y' and -- Bug 9034372
                             l_inv_dist_ins(i).corrected_invoice_dist_id IS NOT NULL) THEN

                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'geting ccid for correction case');
                      END IF;

	              SELECT dist_code_combination_id
	                INTO l_dist_code_combination_id
	                FROM ap_invoice_distributions_all
	               WHERE detail_tax_dist_id = l_inv_dist_ins(i).adjusted_doc_tax_dist_id
	                 AND line_type_lookup_code IN ('REC_TAX','NONREC_TAX','TIPV','TRV','TERV')--Bug7241425
                         AND rownum =1;--Bug7241425
                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,'after geting ccid from corresponding tax distribution for correction case');
                      END IF;

                   --BUG 8740802
                   --ELSIF (l_inv_dist_ins(i).applied_from_tax_dist_id IS NOT NULL) THEN

	           -- l_dist_code_combination_id := l_inv_dist_ins(i).dist_code_combination_id;
                   --BUG 8740802

	           END IF;
	        END IF;


                --BUG 8740802
                IF ((l_inv_dist_ins(i).line_type_lookup_code = 'REC_TAX' OR
   	                 l_inv_dist_ins(i).line_type_lookup_code = 'NONREC_TAX') AND
                     l_inv_dist_ins(i).applied_from_tax_dist_id IS NOT NULL) THEN

                    -------------------------------------------------------------------
                    l_debug_info := 'Before Getting CCID based on applied from tax dist id';

                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                    END IF;
                    -------------------------------------------------------------------

                     BEGIN
                       SELECT dist_code_combination_id
                         INTO l_dist_code_combination_id
                         FROM ap_invoice_distributions_all
                        WHERE invoice_distribution_id = AP_ETAX_UTILITY_PKG.Get_Dist_Id_For_Tax_Dist_Id
                                                        (l_inv_dist_ins(i).applied_from_tax_dist_id);
                     END;

                    -------------------------------------------------------------------
                    l_debug_info := 'After Getting CCID based on applied from tax dist id';

                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                    END IF;
                    -------------------------------------------------------------------
                     --It is Expected that no exception will occur.
                END IF;
                --BUG 8740802


	        IF ((l_inv_dist_ins(i).line_type_lookup_code = 'REC_TAX' OR
	            (l_inv_dist_ins(i).line_type_lookup_code = 'NONREC_TAX'
	             and l_dist_code_combination_id IS NULL)) AND
                     l_inv_dist_ins(i).applied_from_tax_dist_id IS NULL) THEN --Bug8740802

		  l_dist_ccid_rec.gl_date			    := l_inv_dist_ins(i).accounting_date;
		  l_dist_ccid_rec.tax_rate_id			:= l_inv_dist_ins(i).tax_code_id;
		  l_dist_ccid_rec.rec_rate_id			:= l_inv_dist_ins(i).recovery_rate_id;
		  l_dist_ccid_rec.self_assessed_flag	:= 'N';
		  l_dist_ccid_rec.recoverable_flag		:= l_inv_dist_ins(i).tax_recoverable_flag;
		  l_dist_ccid_rec.tax_jurisdiction_id	:= l_inv_dist_ins(i).tax_jurisdiction_id;
		  l_dist_ccid_rec.tax_regime_id			:= l_inv_dist_ins(i).tax_regime_id;
		  l_dist_ccid_rec.tax_id			    := l_inv_dist_ins(i).tax_id;
		  l_dist_ccid_rec.internal_organization_id	:= l_inv_dist_ins(i).org_id;
		  l_dist_ccid_rec.tax_status_id			    := l_inv_dist_ins(i).tax_status_id;

		  l_dist_ccid_rec.revenue_expense_ccid		    := NVL(l_inv_dist_ins(i).dist_code_combination_id,-99);  ---6010950
		  l_dist_ccid_rec.account_source_tax_rate_id    := l_inv_dist_ins(i).account_source_tax_rate_id;

	          -----------------------------------------------------------
	          l_debug_info := 'Call zx_api_pub.get_tax_distribution_ccids';
	          -----------------------------------------------------------
		      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
		      END IF;

	          zx_api_pub.get_tax_distribution_ccids(
		            p_api_version            => 1.0,
		            p_init_msg_list          => FND_API.G_TRUE,
		            p_commit                 => FND_API.G_FALSE,
		            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
		            x_return_status          => l_return_status_service,
		            x_msg_count              => l_msg_count,
		            x_msg_data               => l_msg_data,
			        p_dist_ccid_rec	     => l_dist_ccid_rec);

		            l_dist_code_combination_id	:= l_dist_ccid_rec.rec_nrec_ccid;
		            l_tax_liab_ccid		:= l_dist_ccid_rec.tax_liab_ccid;

	          IF (l_return_status_service <> 'S') THEN
	              -----------------------------------------------------------
	              l_debug_info := 'Handle errors returned by API';
	              -----------------------------------------------------------
		          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	              END IF;

	              IF NOT(AP_ETAX_UTILITY_PKG.Return_Error_Messages(
				        P_All_Error_Messages  => P_All_Error_Messages,
	               		P_Msg_Count           => l_msg_count,
	               		P_Msg_Data            => l_msg_data,
	               		P_Error_Code          => P_Error_Code,
	               		P_Calling_Sequence    => l_curr_calling_sequence)) THEN
	                 NULL;
	              END IF;

	              RETURN FALSE;

	          END IF;
	        END IF;

    	        --bug 8359426 start
		/*if account is -99 for NONREC_TAX distribution (tax only line)  then raise exception
		as the account is neither entered in the invoice line nor is an expense account set up*/
                -----------------------------------------------------------
	            l_debug_info := 'Check If Tax Only Non Rec Distribution has CCID';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	            END IF;
	            -----------------------------------------------------------
                IF l_dist_ccid_rec.recoverable_flag = 'N' AND
                               NVL(l_dist_code_combination_id, -99) = -99 THEN
                 --bug 8840245, if online validaiton then raise exception else return false
                    --Bug9021265
                    FND_MESSAGE.SET_NAME('SQLAP','AP_NO_NON_REC_ACC');
              	    FND_MESSAGE.SET_TOKEN('ERROR', 'Default Account for tax only line not provided or expense account not defined.');
	                FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
	                FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                                      'P_Error_Code = '||P_Error_Code||
	                                      'P_Calling_Sequence = '||P_Calling_Sequence);
	                FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
                    IF AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID IS NULL THEN
                       APP_EXCEPTION.RAISE_EXCEPTION;
                    ELSE
                       P_Error_Code := FND_MESSAGE.GET;
                       RETURN FALSE;
                    END IF;
                    --Bug9021265
                END IF;

                --bug 8359426 end


	        -------------------------------------------------------------------
	        l_debug_info := 'Insert REC/NONREC distributions';
	        -------------------------------------------------------------------
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	        END IF;

	        ap_etax_utility_pkg.insert_tax_distributions
	        			(p_invoice_header_rec        => p_invoice_header_rec,
					 p_inv_dist_rec              => l_inv_dist_ins(i),
					 p_dist_code_combination_id  => l_dist_code_combination_id,
					 p_user_id		     => l_user_id,
					 p_sysdate	     	     => l_sysdate,
					 p_login_id		     => l_login_id,
					 p_calling_sequence          => l_curr_calling_sequence);

	    END LOOP;
            L_INV_DIST_INS.DELETE;
        END IF;
    END LOOP;
    CLOSE INSERT_TAX_DIST;

    -------------------------------------------------------------------
    l_debug_info := 'Get Tax Variances';
    ------------------------------------------------------------------
    OPEN INSERT_TAX_VARIANCES;
    LOOP
        l_dist_code_combination_id := NULL; -- bug 9690870

        FETCH INSERT_TAX_VARIANCES
         BULK COLLECT INTO L_INV_DIST_INS
        LIMIT AP_ETAX_PKG.G_BATCH_LIMIT;

        EXIT WHEN INSERT_TAX_VARIANCES%NOTFOUND
                  AND L_INV_DIST_INS.COUNT <= 0;

        IF (l_inv_dist_ins.COUNT <> 0) THEN

            FOR i IN l_inv_dist_ins.FIRST..l_inv_dist_ins.LAST LOOP
                l_dist_code_combination_id := l_inv_dist_ins(i).dist_code_combination_id;

				-- Project LCM 7588322
	         BEGIN
              SELECT 'Y'
	            INTO   l_lcm_enabled
	            FROM   RCV_TRANSACTIONS
	            WHERE  TRANSACTION_ID = L_INV_DIST_INS(i).rcv_transaction_id
	            AND    LCM_SHIPMENT_LINE_ID IS NOT NULL;
	           EXCEPTION
               WHEN NO_DATA_FOUND THEN NULL;
             END;

	            IF(l_lcm_enabled = 'Y') THEN
	               l_rcv_transaction_id := L_INV_DIST_INS(i).rcv_transaction_id;
	               RCV_UTILITIES.Get_RtLcmInfo(
	                            p_rcv_transaction_id           => l_rcv_transaction_id,
	                            x_lcm_account_id               => l_lcm_account_id,
								x_tax_variance_account_id      => l_tax_variance_account_id,
								x_def_charges_account_id       => l_def_charges_account_id,
								x_exchange_variance_account_id => l_exchange_variance_account_id,
								x_inv_variance_account_id      => l_inv_variance_account_id
								);
	               l_dist_code_combination_id := l_tax_variance_account_id;

                END IF;
	            -- End Project LCM 7588322


                -------------------------------------------------------------------
                l_debug_info := 'Insert Tax Variance Distributions';
                -------------------------------------------------------------------
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;

                ap_etax_utility_pkg.insert_tax_distributions(
				  p_invoice_header_rec       => p_invoice_header_rec,
				  p_inv_dist_rec             => l_inv_dist_ins(i),
				  p_dist_code_combination_id => l_dist_code_combination_id,
				  p_user_id		     => l_user_id,
				  p_sysdate	     	     => l_sysdate,
				  p_login_id		     => l_login_id,
				  p_calling_sequence         => l_curr_calling_sequence);
           END LOOP;
           L_INV_DIST_INS.DELETE;
        END IF;
    END LOOP;
    CLOSE INSERT_TAX_VARIANCES;


    -------------------------------------------------------------------
    l_debug_info := 'Get self assessed dist for insert';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    OPEN INSERT_TAX_SELF;
    LOOP
        l_dist_code_combination_id := NULL; -- bug 9690870

        FETCH INSERT_TAX_SELF
         BULK COLLECT INTO L_INV_SELF_INS
        LIMIT AP_ETAX_PKG.G_BATCH_LIMIT;

        EXIT WHEN INSERT_TAX_SELF%NOTFOUND
                  AND L_INV_SELF_INS.COUNT <= 0;

        IF (l_inv_self_ins.COUNT <> 0) THEN

      	    -------------------------------------------------------------------
      	    l_debug_info := 'Insert self assessed tax distributions';
      	    -------------------------------------------------------------------
      	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      	    END IF;

	    FOR i IN l_inv_self_ins.FIRST..l_inv_self_ins.LAST LOOP

		        -------------------------------------------------------------------
		        l_debug_info := 'Get ccid for self assessed distributions';
             	-------------------------------------------------------------------
	         	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
             	END IF;

	        IF (l_inv_self_ins(i).line_type_lookup_code =  'NONREC_TAX') THEN

	           IF ( l_inv_self_ins(i).po_distribution_id IS NOT NULL OR
	                l_inv_self_ins(i).rcv_transaction_id IS NOT NULL) THEN

	              IF ( l_inv_self_ins(i).accrue_on_receipt_flag = 'Y' OR
	                   --l_inv_self_ins(i).allow_flex_override_flag = 'Y' -- Bug 6720793
	                   l_inv_self_ins(i).purch_encumbrance_flag = 'Y') THEN

                           -------------------------------------------------------------------
                           l_debug_info := 'PO: Setting Self Assessed Non-Rec tax account same as its parent';
                           -------------------------------------------------------------------
                           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                           END IF;

	                   l_dist_code_combination_id := l_inv_self_ins(i).dist_code_combination_id;

	              END IF;

	           ELSIF ( l_inv_self_ins(i).project_id IS NOT NULL AND
	                   l_allow_pa_override = 'N') THEN

	             l_dist_code_combination_id := l_inv_self_ins(i).dist_code_combination_id;

	           END IF;

	           -- This section to get ccid from corresponding tax distribution if
	           -- line discard/invoice cancellation or correction
	           -- quick credit or prepayment application/unapplication
	           IF (l_inv_self_ins(i).parent_dist_cancellation_flag = 'Y' OR
                        (nvl(p_invoice_header_rec.quick_credit, 'N') = 'Y'
                        and p_invoice_header_rec.credited_invoice_id IS NOT
                        NULL) OR		                                         --Bug8834205
	              (l_inv_self_ins(i).parent_dist_reversal_flag = 'Y'
	               and l_inv_self_ins(i).parent_dist_parent_reversal_id IS NOT NULL)) THEN

	              SELECT dist_code_combination_id
	                INTO l_dist_code_combination_id
	                FROM ap_self_assessed_tax_dist_all
	               WHERE detail_tax_dist_id = l_inv_self_ins(i).reversed_tax_dist_id
				   AND line_type_lookup_code IN ('REC_TAX','NONREC_TAX','TIPV','TRV','TERV')--Bug8834205
                   AND rownum =1;

	           ELSIF (l_inv_self_ins(i).corrected_invoice_dist_id IS NOT NULL) THEN

	              SELECT dist_code_combination_id
	                INTO l_dist_code_combination_id
	                FROM ap_self_assessed_tax_dist_all
	               WHERE detail_tax_dist_id = l_inv_self_ins(i).adjusted_doc_tax_dist_id
				   AND line_type_lookup_code IN ('REC_TAX','NONREC_TAX','TIPV','TRV','TERV')--Bug8834205
                   AND rownum =1;

	          --In case of Selfassessed Tax resulted due to prepayment application
                  --CCID can be derived from its correrponding taxable distribution
                  --or expense acccount but certainly user cannot change CCID on self
                  --assessed tax distributions. Hence we can call ZX_API_PUB.GET_TAX_DISTRIBUTION_CCIDS
                  --This function will return the correct CCID. In case of normal exclusive tax
                  --we need to fetch it from its original tax distribution on PREPAY invoice.


                   --Bug8740802
                   --ELSIF (l_inv_self_ins(i).applied_from_tax_dist_id IS NOT NULL) THEN

	             --l_dist_code_combination_id := l_inv_self_ins(i).dist_code_combination_id;
                   --Bug8740802

	           END IF;

	        ELSIF (l_inv_self_ins(i).line_type_lookup_code IN
	              ('TIPV', 'TERV', 'TRV')) THEN

	          l_dist_code_combination_id := l_inv_self_ins(i).dist_code_combination_id;

	        END IF;

	        IF (l_inv_self_ins(i).line_type_lookup_code = 'REC_TAX' OR
	            (l_inv_self_ins(i).line_type_lookup_code = 'NONREC_TAX' )) THEN --Bug6599804

		  l_dist_ccid_rec.gl_date			    := l_inv_self_ins(i).accounting_date;
		  l_dist_ccid_rec.tax_rate_id			:= l_inv_self_ins(i).tax_code_id;
		  l_dist_ccid_rec.rec_rate_id			:= l_inv_self_ins(i).recovery_rate_id;
		  l_dist_ccid_rec.self_assessed_flag	:= 'Y';
		  l_dist_ccid_rec.recoverable_flag		:= l_inv_self_ins(i).tax_recoverable_flag;
		  l_dist_ccid_rec.tax_jurisdiction_id	:= l_inv_self_ins(i).tax_jurisdiction_id;
		  l_dist_ccid_rec.tax_regime_id			:= l_inv_self_ins(i).tax_regime_id;
		  l_dist_ccid_rec.tax_id			    := l_inv_self_ins(i).tax_id;
		  l_dist_ccid_rec.internal_organization_id	:= l_inv_self_ins(i).org_id;
		  l_dist_ccid_rec.tax_status_id			:= l_inv_self_ins(i).tax_status_id;
		  l_dist_ccid_rec.revenue_expense_ccid	:= l_inv_self_ins(i).dist_code_combination_id;
		  l_dist_ccid_rec.account_source_tax_rate_id    := l_inv_self_ins(i).account_source_tax_rate_id;

	          zx_api_pub.get_tax_distribution_ccids(
		            p_api_version            => 1.0,
		            p_init_msg_list          => FND_API.G_TRUE,
		            p_commit                 => FND_API.G_FALSE,
		            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
		            x_return_status          => l_return_status_service,
		            x_msg_count              => l_msg_count,
		            x_msg_data               => l_msg_data,
			        p_dist_ccid_rec	     => l_dist_ccid_rec);

                 IF (l_inv_self_ins(i).line_type_lookup_code = 'REC_TAX' OR
                    (l_inv_self_ins(i).line_type_lookup_code = 'NONREC_TAX'
                     and l_dist_code_combination_id IS NULL)) THEN  --Bug6599804

		  l_dist_code_combination_id	:= l_dist_ccid_rec.rec_nrec_ccid;

                 END IF;

		  l_tax_liab_ccid		:= l_dist_ccid_rec.tax_liab_ccid;

	          IF (l_return_status_service <> 'S') THEN
	              -----------------------------------------------------------
	              l_debug_info := 'Handle errors returned by API';
	              -----------------------------------------------------------
		          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	              END IF;

	              IF NOT(AP_ETAX_UTILITY_PKG.Return_Error_Messages(
		               P_All_Error_Messages  => P_All_Error_Messages,
		               P_Msg_Count           => l_msg_count,
		               P_Msg_Data            => l_msg_data,
		               P_Error_Code          => P_Error_Code,
		               P_Calling_Sequence    => l_curr_calling_sequence)) THEN
	                 NULL;
	              END IF;

	              RETURN FALSE;
	          END IF;
	        END IF;

	        -------------------------------------------------------------------
	        l_debug_info := 'Insert self assessed distributions';
	        -------------------------------------------------------------------
		    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	        END IF;

	        BEGIN
	          INSERT INTO ap_self_assessed_tax_dist_all (
	            accounting_date,
	            accrual_posted_flag,
	            assets_addition_flag,
	            assets_tracking_flag,
	            cash_posted_flag,
	            distribution_line_number,
	            dist_code_combination_id,
	            invoice_id,
	            last_updated_by,
	            last_update_date,
	            line_type_lookup_code,
	            period_name,
	            set_of_books_id,
	            amount,
	            base_amount,
	            batch_id,
	            created_by,
	            creation_date,
	            description,
	            final_match_flag,
	            income_tax_region,
	            last_update_login,
	            match_status_flag,
	            posted_flag,
	            po_distribution_id,
	            program_application_id,
	            program_id,
	            program_update_date,
	            quantity_invoiced,
	            request_id,
	            reversal_flag,
	            type_1099,
	            unit_price,
	            encumbered_flag,
	            stat_amount,
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
	            attribute_category,
	            expenditure_item_date,
	            expenditure_organization_id,
	            expenditure_type,
	            parent_invoice_id,
	            pa_addition_flag,
	            pa_quantity,
	            prepay_amount_remaining,
	            project_accounting_context,
	            project_id,
	            task_id,
	            packet_id,
	            awt_flag,
	            awt_group_id,
	            awt_tax_rate_id,
	            awt_gross_amount,
	            awt_invoice_id,
	            awt_origin_group_id,
	            reference_1,
	            reference_2,
	            org_id,
	            awt_invoice_payment_id,
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
	            expense_group,
	            start_expense_date,
	            end_expense_date,
	            receipt_currency_code,
	            receipt_conversion_rate,
	            receipt_currency_amount,
	            daily_amount,
	            web_parameter_id,
	            adjustment_reason,
	            award_id,
	            credit_card_trx_id,
	            dist_match_type,
	            rcv_transaction_id,
	            invoice_distribution_id,
	            parent_reversal_id,
	            tax_recoverable_flag,
	            merchant_document_number,
	            merchant_name,
	            merchant_reference,
	            merchant_tax_reg_number,
	            merchant_taxpayer_id,
	            country_of_supply,
	            matched_uom_lookup_code,
	            gms_burdenable_raw_cost,
	            accounting_event_id,
	            prepay_distribution_id,
	            upgrade_posted_amt,
	            upgrade_base_posted_amt,
	            inventory_transfer_status,
	            company_prepaid_invoice_id,
	            cc_reversal_flag,
	            awt_withheld_amt,
	            pa_cmt_xface_flag,
	            cancellation_flag,
	            invoice_line_number,
	            corrected_invoice_dist_id,
	            rounding_amt,
	            charge_applicable_to_dist_id,
	            corrected_quantity,
	            related_id,
	            asset_book_type_code,
	            asset_category_id,
	            distribution_class,
	            tax_code_id,
	            intended_use,
	            detail_tax_dist_id,
	            rec_nrec_rate,
	            recovery_rate_id,
	            recovery_rate_name,
	            recovery_type_code,
	            withholding_tax_code_id,
	            taxable_amount,
	            taxable_base_amount,
	            tax_already_distributed_flag,
        	    summary_tax_line_id,
	            extra_po_erv,
	            prepay_tax_diff_amount,
	            self_assessed_tax_liab_ccid,
		        rcv_charge_addition_flag,
		        self_assessed_flag
	          ) VALUES (
	            l_inv_self_ins(i).accounting_date,    -- accounting_date
	            'N',                                  -- accrual_posted_flag
	            'U',                                  -- assets_addition_flag
	            'N',                                  -- assets_tracking_flag
	            'N',                                  -- cash_posted_flag
	            AP_ETAX_UTILITY_PKG.get_max_dist_num_self(
                      --P_Invoice_Header_Rec.invoice_id,
                      l_inv_self_ins(i).invoice_id,
	              l_inv_self_ins(i).invoice_line_number)+1, --Bug7611551
	                                                  -- distribution_line_number
	            l_dist_code_combination_id,           -- dist_code_combination_id
                    l_inv_self_ins(i).invoice_id,         -- invoice_id Bug7611551
	            --P_Invoice_Header_Rec.invoice_id,      -- invoice_id
	            l_user_id,                            -- last_updated_by
	            l_sysdate,                            -- last_update_date
	            l_inv_self_ins(i).line_type_lookup_code,
	                                                  -- line_type_lookup_code
	            l_inv_self_ins(i).period_name,        -- period_name
                    l_inv_self_ins(i).set_of_books_id,         -- set_of_books_id bug7611551
	            --P_Invoice_Header_Rec.set_of_books_id, -- set_of_books_id
	            l_inv_self_ins(i).amount,             -- amount
	            decode(l_inv_self_ins(i).base_amount,
                           0, decode(l_inv_self_ins(i).amount, 0, l_inv_self_ins(i).base_amount, NULL),
                           l_inv_self_ins(i).base_amount), -- base_amount
	            l_inv_self_ins(i).batch_id,           -- batch_id  --Bug7611551
                    --P_Invoice_Header_Rec.batch_id,      -- batch_id
	            l_user_id,                            -- created_by
	            l_sysdate,                            -- creation_date
	            l_inv_self_ins(i).description,        -- description
	            NULL,                                 -- final_match_flag
	            l_inv_self_ins(i).income_tax_region,  -- income_tax_region
	            l_login_id,                           -- last_update_login
	            NULL,                                 -- match_status_flag
	            'N',                                  -- posted_flag
	            l_inv_self_ins(i).po_distribution_id, -- po_distribution_id
	            NULL,                                 -- program_application_id
	            NULL,                                 -- program_id
	            NULL,                                 -- program_update_date
	            NULL,                                 -- quantity_invoiced
	            NULL,                                 -- request_id
	            'N',                                  -- reversal_flag
	            l_inv_self_ins(i).type_1099,          -- type_1099
	            NULL,                                 -- unit_price
	            'N',                                  -- encumbered_flag
	            NULL,                                 -- stat_amount
	            l_inv_self_ins(i).attribute1,         -- attribute1
	            l_inv_self_ins(i).attribute10,        -- attribute10
	            l_inv_self_ins(i).attribute11,        -- attribute11,
	            l_inv_self_ins(i).attribute12,        -- attribute12
	            l_inv_self_ins(i).attribute13,        -- attribute13
	            l_inv_self_ins(i).attribute14,        -- attribute14
	            l_inv_self_ins(i).attribute15,        -- attribute15
	            l_inv_self_ins(i).attribute2,         -- attribute2
	            l_inv_self_ins(i).attribute3,         -- attribute3
	            l_inv_self_ins(i).attribute4,         -- attribute4
	            l_inv_self_ins(i).attribute5,         -- attribute5
	            l_inv_self_ins(i).attribute6,         -- attribute6
	            l_inv_self_ins(i).attribute7,         -- attribute7
	            l_inv_self_ins(i).attribute8,         -- attribute8
	            l_inv_self_ins(i).attribute9,         -- attribute9
	            l_inv_self_ins(i).attribute_category, -- attribute_category
	            l_inv_self_ins(i).expenditure_item_date,
	                                                  -- expenditure_item_date
	            l_inv_self_ins(i).expenditure_organization_id,
	                                                  -- expenditure_organization_id
	            l_inv_self_ins(i).expenditure_type,   -- expenditure_type
        	    l_inv_self_ins(i).parent_invoice_id,  -- parent_invoice_id
	            l_inv_self_ins(i).pa_addition_flag,   -- pa_addition_flag
	            l_inv_self_ins(i).pa_quantity,        -- pa_quantity
	            NULL,                                 -- prepay_amount_remaining
	            -- the prepay_amount_remaining will be populated for all the
	            -- prepayment distributions during the payment. And later will be
	            -- updated during the prepayment applications
	            l_inv_self_ins(i).project_accounting_context,
	                                                  -- project_accounting_context
	            l_inv_self_ins(i).project_id,         -- project_id
	            l_inv_self_ins(i).task_id,            -- task_id
	            NULL,                                 -- packet_id
	            'N',                                  -- awt_flag
	            l_inv_self_ins(i).awt_group_id,       -- awt_group_id
	            NULL,                                 -- awt_tax_rate_id
	            NULL,                                 -- awt_gross_amount
	            NULL,                                 -- awt_invoice_id
	            NULL,                                 -- awt_origin_group_id
	            NULL,                                 -- reference_1
	            NULL,                                 -- reference_2
                    l_inv_self_ins(i).org_id,             -- org_id --Bug7611551
  	            --P_Invoice_Header_Rec.org_id,        -- org_id
	            NULL,                                 -- awt_invoice_payment_id
	            l_inv_self_ins(i).global_attribute_category,
	                                                  -- global_attribute_category
	            l_inv_self_ins(i).global_attribute1,  -- global_attribute1
	            l_inv_self_ins(i).global_attribute2,  -- global_attribute2
	            l_inv_self_ins(i).global_attribute3,  -- global_attribute3
	            l_inv_self_ins(i).global_attribute4,  -- global_attribute4
	            l_inv_self_ins(i).global_attribute5,  -- global_attribute5
	            l_inv_self_ins(i).global_attribute6,  -- global_attribute6
	            l_inv_self_ins(i).global_attribute7,  -- global_attribute7
	            l_inv_self_ins(i).global_attribute8,  -- global_attribute8
	            l_inv_self_ins(i).global_attribute9,  -- global_attribute9
	            l_inv_self_ins(i).global_attribute10, -- global_attribute10
	            l_inv_self_ins(i).global_attribute11, -- global_attribute11
	            l_inv_self_ins(i).global_attribute12, -- global_attribute12
	            l_inv_self_ins(i).global_attribute13, -- global_attribute13
	            l_inv_self_ins(i).global_attribute14, -- global_attribute14
	            l_inv_self_ins(i).global_attribute15, -- global_attribute15
	            l_inv_self_ins(i).global_attribute16, -- global_attribute16
	            l_inv_self_ins(i).global_attribute17, -- global_attribute17
	            l_inv_self_ins(i).global_attribute18, -- global_attribute18
        	    l_inv_self_ins(i).global_attribute19, -- global_attribute19
	            l_inv_self_ins(i).global_attribute20, -- global_attribute20
	            NULL,                                 -- receipt_verified_flag
	            NULL,                                 -- receipt_required_flag
	            NULL,                                 -- receipt_missing_flag
	            NULL,                                 -- justification
	            NULL,                                 -- expense_group
	            NULL,                                 -- start_expense_date
	            NULL,                                 -- end_expense_date
	            NULL,                                 -- receipt_currency_code
	            NULL,                                 -- receipt_conversion_rate
	            NULL,                                 -- receipt_currency_amount
	            NULL,                                 -- daily_amount
	            NULL,                                 -- web_parameter_id
	            NULL,                                 -- adjustment_reason
	            l_inv_self_ins(i).award_id,           -- award_id
	            NULL,                                 -- credit_card_trx_id
	            l_inv_self_ins(i).dist_match_type,    -- dist_match_type
	            l_inv_self_ins(i).rcv_transaction_id, -- rcv_transaction_id
        	    ap_invoice_distributions_s.NEXTVAL,   -- invoice_distribution_id
	            NULL,                                 -- parent_reversal_id
	            l_inv_self_ins(i).tax_recoverable_flag,
	                                                  -- tax_recoverable_flag
	            NULL,                                 -- merchant_document_number
	            NULL,                                 -- merchant_name
	            NULL,                                 -- merchant_reference
	            NULL,                                 -- merchant_tax_reg_number
	            NULL,                                 -- merchant_taxpayer_id
	            NULL,                                 -- country_of_supply
	            NULL,                                 -- matched_uom_lookup_code
	            NULL,                                 -- gms_burdenable_raw_cost
	            NULL,                                 -- accounting_event_id
	            l_inv_self_ins(i).prepay_distribution_id,  -- prepay_distribution_id
	            NULL,                                 -- upgrade_posted_amt
	            NULL,                                 -- upgrade_base_posted_amt
	            'N',                                  -- inventory_transfer_status
	            NULL,                                 -- company_prepaid_invoice_id
	            NULL,                                 -- cc_reversal_flag
	            NULL,                                 -- awt_withheld_amt
	            NULL,                                 -- pa_cmt_xface_flag
	            l_inv_self_ins(i).cancellation_flag,  -- cancellation_flag
	            l_inv_self_ins(i).invoice_line_number,-- invoice_line_number
	            l_inv_self_ins(i).corrected_invoice_dist_id,
	                                                  -- corrected_invoice_dist_id
	            l_inv_self_ins(i).rounding_amt,       -- rounding_amt
	            l_inv_self_ins(i).charge_applicable_to_dist_id,
	                                                 -- charge_applicable_to_dist_id
	            NULL,                                 -- corrected_quantity
	            NULL,                                 -- related_id
	            NULL,                                 -- asset_book_type_code
	            NULL,                                 -- asset_category_id
	            l_inv_self_ins(i).distribution_class, -- distribution_class
	            l_inv_self_ins(i).tax_code_id,        -- tax_code_id
	            NULL,                                 -- intended_use,
	            l_inv_self_ins(i).detail_tax_dist_id, -- detail_tax_dist_id
	            l_inv_self_ins(i).rec_nrec_rate,      -- rec_nrec_rate
	            l_inv_self_ins(i).recovery_rate_id,   -- recovery_rate_id
	            l_inv_self_ins(i).recovery_rate_name, -- recovery_rate_name
	            l_inv_self_ins(i).recovery_type_code, -- recovery_type_code
	            NULL,                                 -- withholding_tax_code_id,
	            l_inv_self_ins(i).taxable_amount,     -- taxable_amount
	            l_inv_self_ins(i).taxable_base_amount, -- taxable_base_amount
	            NULL,                                -- tax_already_distributed_flag
	            l_inv_self_ins(i).summary_tax_line_id, -- summary_tax_line_id
	            l_inv_self_ins(i).extra_po_erv,        -- extra_po_erv
	            l_inv_self_ins(i).prepay_tax_diff_amount, -- prepay_tax_diff_amount
	            l_tax_liab_ccid,                        -- self_assessed_tax_liab_ccid
		        'N',				    -- rcv_charge_addition_flag
		        'Y'					    -- self_assessed_flag
		     );

	        EXCEPTION
			WHEN OTHERS THEN
			     IF (SQLCODE <> -20001) THEN
				 FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
				 FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
				 FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
				 FND_MESSAGE.SET_TOKEN('PARAMETERS',
					            ' P_Invoice_Id = '||l_inv_self_ins(i).invoice_id||
					            ' P_Error_Code = '||P_Error_Code||
					            ' P_Calling_Sequence = '||P_Calling_Sequence);
				 FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
			     END IF;

			IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
	           	    FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
			END IF;

			APP_EXCEPTION.RAISE_EXCEPTION;
	        END;
            l_tax_liab_ccid               := NULL;
            END LOOP;
            L_INV_SELF_INS.DELETE;
        END IF;
    END LOOP;
    CLOSE INSERT_TAX_SELF;

    --Bug9021265
    --Raising error if any distribution frozen dist is missing
    --as discussed  : Himesh,Atul,Venkat,Kiran,Ranjith,Taniya

    BEGIN
    SELECT /*+ leading(GT) index(GT ZX_TRX_HEADERS_GT_U1) cardinality(GT, 1) use_nl(AID) */ -- 9485828
         detail_tax_dist_id,aid.summary_tax_line_id
      INTO l_frozen_tax_dist_id,l_frozen_summary_tax_line_id
      FROM ap_invoice_distributions_all aid,
           zx_trx_headers_gt gt
     WHERE aid.line_type_lookup_code IN ('NONREC_TAX','REC_TAX','TRV','TERV','TIPV')
       AND (aid.accounting_event_id IS NOT NULL         OR
            NVL(aid.match_status_flag,'N') IN ('A','T') OR
            NVL(aid.posted_flag,'N') ='Y'               OR
            NVL(aid.encumbered_flag, 'N') IN ('Y','D','W','X'))
       AND gt.application_id         = AP_ETAX_PKG.AP_APPLICATION_ID
       AND gt.entity_code            = AP_ETAX_PKG.AP_ENTITY_CODE
	   AND gt.event_class_code       IN (AP_ETAX_PKG.AP_INV_EVENT_CLASS_CODE,
	                                     AP_ETAX_PKG.AP_PP_EVENT_CLASS_CODE,
	                                     AP_ETAX_PKG.AP_ER_EVENT_CLASS_CODE)
	   AND gt.trx_id                 = aid.invoice_id
       AND NOT EXISTS(SELECT /*+ NO_UNNEST  */ 'Tax Distributions'  -- 9485828
			            FROM zx_rec_nrec_dist zd
			           WHERE zd.rec_nrec_tax_dist_id = aid.detail_tax_dist_id
			             AND NVL(SELF_ASSESSED_FLAG, 'N') = 'N')
       AND rownum=1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    END;

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Frozen Deleted Dist Count: '||sql%rowcount);
      END IF;

    IF l_frozen_tax_dist_id  IS NOT NULL THEN
       -------------------------------------------------------------------
       l_debug_info := 'Froze Dist Deleted: ' ||l_frozen_tax_dist_id;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       l_debug_info := 'Summary Tax Line ID for this Dist: '||l_frozen_summary_tax_line_id;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       -------------------------------------------------------------------

       /* Bug 9777752
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	   FND_MESSAGE.SET_TOKEN('ERROR', 'Frozen Tax Distribution Deleted by EBTax. This would cause orphan events.');
	   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
	   FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                         ' P_Error_Code = '||P_Error_Code||
	                         ' P_Calling_Sequence = '||P_Calling_Sequence);
	   FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
       */
       FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_FRZN_TAX_DIST_DEL' ); -- Bug 9777752

       IF AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID IS NULL THEN
          APP_EXCEPTION.RAISE_EXCEPTION;
       ELSE
          RETURN FALSE;
       END IF;
    END IF;

    --Bug9021265
    --Raising error if any distribution frozen dist is missing
    --as discussed  : Himesh,Atul,Venkat,Kiran,Ranjith,Taniya

    -------------------------------------------------------------------
    l_debug_info := 'Delete tax distributions';
    -------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    DELETE FROM ap_invoice_distributions_all aid
     WHERE aid.invoice_distribution_id IN
		(SELECT /*+ leading(gt) cardinality(gt,1) */
                        dist.invoice_distribution_id
	           FROM zx_trx_headers_gt		gt,
			ap_invoice_distributions_all	dist
		  WHERE gt.application_id         = AP_ETAX_PKG.AP_APPLICATION_ID
	            AND gt.entity_code            = AP_ETAX_PKG.AP_ENTITY_CODE
	            AND gt.event_class_code       IN (AP_ETAX_PKG.AP_INV_EVENT_CLASS_CODE,
	                                              AP_ETAX_PKG.AP_PP_EVENT_CLASS_CODE,
	                                              AP_ETAX_PKG.AP_ER_EVENT_CLASS_CODE)
	            AND gt.trx_id                 = dist.invoice_id
		    AND dist.line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX', 'TRV', 'TIPV', 'TERV')
		    AND NOT EXISTS
				(SELECT 'Tax Distributions'
				   FROM zx_rec_nrec_dist zd
				  WHERE zd.rec_nrec_tax_dist_id = dist.detail_tax_dist_id
				   AND NVL(SELF_ASSESSED_FLAG, 'N') = 'N')-- bug 7422547
		);                                                        --Bug7634436

    --Bug9021265
    --Raising error if any distribution frozen dist is missing
    --as discussed  : Himesh,Atul,Venkat,Kiran,Ranjith,Taniya

    l_frozen_tax_dist_id  := NULL;
    l_frozen_summary_tax_line_id := NULL;

    BEGIN
    SELECT /*+ leading(GT) index(GT ZX_TRX_HEADERS_GT_U1) cardinality(GT, 1) use_nl(AID) */ -- 9485828
          detail_tax_dist_id,aid.summary_tax_line_id
      INTO l_frozen_tax_dist_id,l_frozen_summary_tax_line_id
      FROM ap_self_assessed_tax_dist_all aid,
           zx_trx_headers_gt gt
     WHERE aid.line_type_lookup_code IN ('NONREC_TAX','REC_TAX')
       AND (aid.accounting_event_id IS NOT NULL         OR
            NVL(aid.match_status_flag,'N') IN ('A','T') OR
            NVL(aid.posted_flag,'N') ='Y'               OR
            NVL(aid.encumbered_flag, 'N') IN ('Y','D','W','X'))
       AND gt.application_id         = AP_ETAX_PKG.AP_APPLICATION_ID
       AND gt.entity_code            = AP_ETAX_PKG.AP_ENTITY_CODE
	   AND gt.event_class_code       IN (AP_ETAX_PKG.AP_INV_EVENT_CLASS_CODE,
	                                   AP_ETAX_PKG.AP_PP_EVENT_CLASS_CODE,
	                                   AP_ETAX_PKG.AP_ER_EVENT_CLASS_CODE)
	   AND gt.trx_id                 = aid.invoice_id
       AND NOT EXISTS(SELECT /*+ NO_UNNEST  */ 'Tax Distributions'  -- 9485828
		                FROM zx_rec_nrec_dist zd
			           WHERE zd.rec_nrec_tax_dist_id = aid.detail_tax_dist_id
			             AND NVL(SELF_ASSESSED_FLAG, 'N') = 'Y')
       AND rownum=1;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    END;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Frozen Deleted Self Assessed Dist Count: '||sql%rowcount);
    END IF;
    IF l_frozen_tax_dist_id IS NOT NULL THEN
       -------------------------------------------------------------------
       l_debug_info := 'Froze Self Assessed Dist Deleted: '||l_frozen_tax_dist_id;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       l_debug_info := 'Summary Tax Line ID for this Dist: '||l_frozen_summary_tax_line_id;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
       -------------------------------------------------------------------
       /* Bug 9777752
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
   	   FND_MESSAGE.SET_TOKEN('ERROR', 'Frozen Tax Distribution Deleted by EBTax. This would cause orphan events.');
	   FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
	   FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                         ' P_Error_Code = '||P_Error_Code||
	                         ' P_Calling_Sequence = '||P_Calling_Sequence);
	   FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
       */
       FND_MESSAGE.SET_NAME( 'SQLAP', 'AP_FRZN_TAX_DIST_DEL' ); -- Bug 9777752

       IF AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID IS NULL THEN
          APP_EXCEPTION.RAISE_EXCEPTION;
       ELSE
          RETURN FALSE;
       END IF;
    END IF;

    --Bug9021265
    --Raising error if any distribution frozen dist is missing
    --as discussed  : Himesh,Atul,Venkat,Kiran,Ranjith,Taniya
    -------------------------------------------------------------------
    l_debug_info := 'Get self assessed distributions to delete';
    -------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    DELETE FROM ap_self_assessed_tax_dist_all aid
     WHERE aid.invoice_distribution_id IN
                (SELECT /*+ leading(gt) cardinality(gt,1) */
			dist.invoice_distribution_id
                   FROM zx_trx_headers_gt               gt,
                        ap_self_assessed_tax_dist_all   dist
                  WHERE gt.application_id         = AP_ETAX_PKG.AP_APPLICATION_ID
                    AND gt.entity_code            = AP_ETAX_PKG.AP_ENTITY_CODE
                    AND gt.event_class_code       IN (AP_ETAX_PKG.AP_INV_EVENT_CLASS_CODE,
                                                      AP_ETAX_PKG.AP_PP_EVENT_CLASS_CODE,
                                                      AP_ETAX_PKG.AP_ER_EVENT_CLASS_CODE)
                    AND gt.trx_id                 = dist.invoice_id
                    AND dist.line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX')
                    AND NOT EXISTS
                                (SELECT 'Tax Distributions'
                                   FROM zx_rec_nrec_dist zd
                                  WHERE zd.rec_nrec_tax_dist_id = dist.detail_tax_dist_id
				                   AND NVL(SELF_ASSESSED_FLAG, 'N') = 'Y')-- bug 7422547
                );                                                                        --bug7634436

    -------------------------------------------------------------------
    l_debug_info := 'Synchronize line numbers for orphan distributions';
    -------------------------------------------------------------------
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    BEGIN -- Bug 9777752
       UPDATE ap_invoice_distributions_all aid
          SET invoice_line_number = (SELECT line_number
                                       FROM ap_invoice_lines_all ail
                                      WHERE ail.invoice_id          = aid.invoice_id
                                        AND ail.summary_tax_line_id = aid.summary_tax_line_id
                                        AND rownum                  = 1)
        WHERE aid.invoice_distribution_id IN
                   (SELECT /*+ leading(gt) cardinality(gt,1) */
                           dist.invoice_distribution_id
                      FROM zx_trx_headers_gt               gt,
                           ap_invoice_distributions_all    dist
                     WHERE gt.application_id         = 200
                       AND gt.entity_code            = 'AP_INVOICES'
                       AND gt.event_class_code       IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
                       AND gt.trx_id                 = dist.invoice_id
                       AND dist.line_type_lookup_code IN ('REC_TAX', 'NONREC_TAX', 'TRV', 'TIPV', 'TERV')
                       AND dist.invoice_line_number NOT IN
                                                           (SELECT line_number
                                                              FROM ap_invoice_lines_all al
                                                             WHERE al.invoice_id  = dist.invoice_id)
                   );

    EXCEPTION
       WHEN DUP_VAL_ON_INDEX THEN
          IF INSTRB( SQLERRM, 'AP_INVOICE_DISTRIBUTION_U1' ) <> 0 THEN
             FND_MESSAGE.SET_NAME('SQLAP', 'AP_ERR_TAX_DIST_SYNC') ;

             IF AP_APPROVAL_PKG.G_VALIDATION_REQUEST_ID IS NULL THEN
                APP_EXCEPTION.RAISE_EXCEPTION;
             ELSE
                RETURN FALSE;
             END IF;
          END IF ;
    END ; -- Bug 9777752

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Orphan Distributions updated: '||sql%rowcount);
    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
          		' P_Invoice_Id = '||P_Invoice_Header_Rec.Invoice_Id||
          		' P_Error_Code = '||P_Error_Code||
          		' P_Calling_Sequence = '||P_Calling_Sequence);
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF (insert_tax_dist%ISOPEN ) THEN
        CLOSE insert_tax_dist;
      END IF;

      IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Return_Tax_Distributions;

/*=============================================================================
 |  FUNCTION - Return_Default_Import()
 |
 |  DESCRIPTION
 |      This function handles the return of default values for tax and trx lines
 |      after running the eTax service that validates and defaults info during the
 |      import program.  This function will modify the pl/sql tables used in the
 |      import program.
 |
 |  PARAMETERS
 |      P_Invoice_Header_Rec - Header info
 |      P_All_Error_Messages - Should API return 1 error message or allow
 |                             calling point to get them from message stack
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |	P_Invoice_Status -Status flag to check if further processing should be done.--Bug6625518
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    20-JAN-2004   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Default_Import(
             P_Invoice_Header_Rec        IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
             P_Invoice_Lines_Tab         IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.t_lines_table,
             P_All_Error_Messages        IN VARCHAR2,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2,
	     P_Invoice_Status		 OUT NOCOPY VARCHAR2) --Bug6625518
	     RETURN BOOLEAN
  IS

    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);

    trans_lines_gt     zx_transaction_lines_gt%ROWTYPE;
    tax_lines_gt       zx_import_tax_lines_gt%ROWTYPE;

    TYPE rej_lines_rec IS RECORD (
      invoice_id zx_validation_errors_gt.trx_id%TYPE,
      line_number zx_validation_errors_gt.trx_line_id%TYPE,
      rejection_code zx_validation_errors_gt.message_name%TYPE,
      summary_tax_line_number zx_validation_errors_gt.summary_tax_line_number%TYPE,
      invoice_line_id ap_invoice_lines_interface.invoice_line_id%TYPE);

    TYPE rej_lines_tab IS TABLE OF rej_lines_rec;
    rej_lines rej_lines_tab;

    CURSOR Trx_Lines_c (c_line_number IN NUMBER) IS
    SELECT *
      FROM zx_transaction_lines_gt
     WHERE trx_id = P_Invoice_Header_Rec.invoice_id
       AND trx_line_id = c_line_number;

    CURSOR Tax_Lines_c (c_line_number IN NUMBER) IS
    SELECT *
      FROM zx_import_tax_lines_gt
     WHERE trx_id = P_Invoice_Header_Rec.invoice_id
       AND summary_tax_line_number = c_line_number;

    CURSOR rejections_gt IS
    SELECT ve.trx_id invoice_id,
           ve.trx_line_id line_number,
           ve.message_name rejection_code,
           ve.summary_tax_line_number summary_tax_line_number,
           ail.invoice_line_id invoice_line_id
      FROM zx_validation_errors_gt ve,
           ap_invoice_lines_interface ail
     WHERE ve.application_id = 200
       AND ve.entity_code = 'AP_INVOICES'
       AND ve.event_class_code IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
       AND ve.trx_id = P_Invoice_Header_Rec.invoice_id
       AND ail.invoice_id = ve.trx_id;
       --AND ail.line_number = ve.trx_line_id; --  bug6255826

    -- Bug 6665695
    l_api_name VARCHAR2(100):='AP_ETAX_SERVICES_PKG.Return_Default_Import';

  BEGIN
    l_curr_calling_sequence := 'AP_ETAX_SERVICES_PKG.Return_Default_Import<-' ||
                               P_calling_sequence;
    -----------------------------------------------------------------
    l_debug_info := 'Step 1: Get rejections from zx_trans_lines_val_errs'||
                    ' table';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -----------------------------------------------------------------
    BEGIN
      OPEN rejections_gt;
      FETCH rejections_gt BULK COLLECT INTO rej_lines;
      CLOSE rejections_gt;
    END;

    IF (rej_lines.COUNT <> 0 ) THEN
      FOR i IN rej_lines.FIRST..rej_lines.LAST LOOP

        -----------------------------------------------------------------
        l_debug_info := 'Step 2: Create rejections in the import rejections '||
                        'table';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        -----------------------------------------------------------------
        IF (rej_lines(i).line_number IS NULL) THEN -- rejection is at invoice level
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                p_parent_table        => 'AP_INVOICES_INTERFACE',
                p_parent_id           => rej_lines(i).invoice_id,
                p_reject_code         => rej_lines(i).rejection_code,
                p_last_updated_by     => l_user_id,
                p_last_update_login   => l_login_id,
                p_calling_sequence    => l_curr_calling_sequence) <> TRUE) THEN

               RETURN FALSE;
          END IF;

        ELSE  -- rejection is at line level

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                p_parent_table        => 'AP_INVOICE_LINES_INTERFACE',
                p_parent_id           => rej_lines(i).invoice_line_id,
                p_reject_code         => rej_lines(i).rejection_code,
                p_last_updated_by     => l_user_id,
                p_last_update_login   => l_login_id,
                p_calling_sequence    => l_curr_calling_sequence) <> TRUE) THEN
		RETURN FALSE;
          END IF;

        END IF;

      END LOOP;

      p_invoice_status := 'N';--Bug6625518 Set processing flag to 'N' if there are rejections
    ELSE  -- there are no rejections for this invoice.  Update pl/sql tables
          -- with defaulted info

      -- No need to update invoice header import pl/sql record since
      -- eTax will not default any column.

      -----------------------------------------------------------------
      l_debug_info := 'Step 3: Loop through lines import pl/sql table';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;
      -----------------------------------------------------------------
      IF (P_Invoice_Lines_Tab.COUNT > 0) THEN
        FOR i IN P_Invoice_Lines_Tab.FIRST..P_Invoice_Lines_Tab.LAST LOOP

          -------------------------------------------------------------------
          l_debug_info := 'Step 4: Get trx and tax line info to update pl/sql '||
                          'table';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
          -------------------------------------------------------------------
          IF (P_Invoice_Lines_Tab(i).line_type_lookup_code <> 'TAX') THEN

            BEGIN
              OPEN Trx_Lines_c (P_Invoice_Lines_Tab(i).line_number);
              FETCH Trx_Lines_c INTO trans_lines_gt;
              CLOSE Trx_Lines_c;
            END;

            -----------------------------------------------------------------
            l_debug_info := 'Step 5: Update non-tax lines in pl/sql table';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            -----------------------------------------------------------------
            P_Invoice_Lines_Tab(i).trx_business_category := trans_lines_gt.trx_business_category;
            P_Invoice_Lines_Tab(i).primary_intended_use := trans_lines_gt.line_intended_use;
            P_Invoice_Lines_Tab(i).product_fisc_classification
              := trans_lines_gt.product_fisc_classification;
            P_Invoice_Lines_Tab(i).product_type := trans_lines_gt.product_type;
            P_Invoice_Lines_Tab(i).product_category := trans_lines_gt.product_category;

            -----------------------------------------------------------------
            -- Bug 6665695 -- Added assignment for Tax Classification Code
            -----------------------------------------------------------------
            l_debug_info := 'Step 5.1 Getting INPUT_TAX_CLASSIFICATION_CODE:'
                            ||trans_lines_gt.INPUT_TAX_CLASSIFICATION_CODE;
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            -----------------------------------------------------------------
            P_Invoice_Lines_Tab(i).tax_classification_code :=
                                trans_lines_gt.INPUT_TAX_CLASSIFICATION_CODE;
          ELSE  -- It is a tax line

            BEGIN
              OPEN Tax_Lines_c (P_Invoice_Lines_Tab(i).line_number);
              FETCH Tax_Lines_c INTO tax_lines_gt;
              CLOSE Tax_Lines_c;
            END;

            -----------------------------------------------------------------
            l_debug_info := 'Step 6: Update tax lines in pl/sql table';
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
            END IF;
            -----------------------------------------------------------------
            --6255826 Added Tax_regime_code and Tax assignments
            P_Invoice_Lines_Tab(i).tax_regime_code :=
                                               tax_lines_gt.tax_regime_code;
            P_Invoice_Lines_Tab(i).tax := tax_lines_gt.tax;
            P_Invoice_Lines_Tab(i).tax_jurisdiction_code := tax_lines_gt.tax_jurisdiction_code;
            P_Invoice_Lines_Tab(i).tax_status_code := tax_lines_gt.tax_status_code;
            P_Invoice_Lines_Tab(i).tax_rate_id := tax_lines_gt.tax_rate_id;
            P_Invoice_Lines_Tab(i).tax_rate_code := tax_lines_gt.tax_rate_code;
            P_Invoice_Lines_Tab(i).tax_rate := tax_lines_gt.tax_rate;

            IF (P_Invoice_Header_Rec.tax_only_flag = 'Y') THEN
              -- If the invoice is tax only, copy any defaulted values from the
              -- trx global temp table to the tax line

              BEGIN
                OPEN Trx_Lines_c (P_Invoice_Lines_Tab(i).line_number);
                FETCH Trx_Lines_c INTO trans_lines_gt;
                CLOSE Trx_Lines_c;
              END;

              -----------------------------------------------------------------
              l_debug_info := 'Step 7: Update tax line if tax only invoice in pl/sql table';
              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
              END IF;
              -----------------------------------------------------------------
              P_Invoice_Lines_Tab(i).trx_business_category :=
                trans_lines_gt.trx_business_category;
              P_Invoice_Lines_Tab(i).primary_intended_use :=
                trans_lines_gt.line_intended_use;
              P_Invoice_Lines_Tab(i).product_fisc_classification
                := trans_lines_gt.product_fisc_classification;
              P_Invoice_Lines_Tab(i).product_type := trans_lines_gt.product_type;
              P_Invoice_Lines_Tab(i).product_category :=
                trans_lines_gt.product_category;

            END IF;
          END IF;

        END LOOP;
      END IF;  -- lines pl/sql table has records.
      p_invoice_status := 'Y';--Bug6625518 Set processing flag to Y if no rejections are there
     END IF;  -- there are no rejections for this invoice

   RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Header_Rec.Invoice_Id||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
  END Return_Default_Import;

/*=============================================================================
 |  FUNCTION - Return_Tax_Quote()
 |
 |  DESCRIPTION
 |      This function handles the return of tax lines when the calculate service is
 |      ran for quote.  This case is specific for recurring invoices and invoice
 |      lines created through distribution sets.
 |
 |  PARAMETERS
 |      P_Invoice_Header_Rec - Header info
 |      P_error_code - Error code to be returned
 |      P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    03-NOV-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Tax_Quote(
             P_Invoice_Header_Rec        IN ap_invoices_all%ROWTYPE,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN

  IS

    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_api_name			  CONSTANT VARCHAR2(100) := 'Return_Tax_Quote';

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Return_Tax_Quote<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;
    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get data from zx_detail_tax_lines_gt and '||
                    'update amount and base_amount for line(s)';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    BEGIN
      UPDATE ap_invoice_lines_all ail
         SET (ail.amount, ail.base_amount) =
             (SELECT NVL(ail.amount, 0) - SUM(NVL(zdl.tax_amt,0)),
                     NVL(ail.base_amount,0) - SUM(NVL(zdl.tax_amt_funcl_curr,0))
                FROM zx_detail_tax_lines_gt zdl
             WHERE zdl.application_id = 200
                 AND zdl.entity_code = 'AP_INVOICES'
		         AND zdl.event_class_code IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
                 AND zdl.trx_id = ail.invoice_id
                 AND zdl.trx_line_id = ail.line_number
                 AND NVL(zdl.self_assessed_flag, 'N') = 'N'
                 AND NVL(zdl.tax_amt_included_flag, 'N') = 'N')
       WHERE ail.invoice_id = P_Invoice_Header_Rec.invoice_id
         AND ail.line_type_lookup_code NOT IN ('TAX', 'AWT');

    EXCEPTION
      WHEN no_data_found THEN
        null;

    END;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Header_Rec.Invoice_Id||
          ' P_Error_Code = '||P_Error_Code||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Return_Tax_Quote;

/*=============================================================================
 |  FUNCTION - Return_Error_Messages()
 |
 |  DESCRIPTION
 |      This function will handle the return of the error messages from the
 |      eTax services.  The services can return 1 or more error messages or
 |      warnings.  The calling point will indicate the API if it wants the return of
 |      only 1 error messages through the parameter P_All_Error_Messages = N
 |      eventhough the service returns more than one error message.
 |      If the calling point requires all the error messages, it will need to get them
 |      directly from the message stack.
 |
 |  PARAMETERS
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    05-NOV-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Return_Error_Messages(
             P_All_Error_Messages        IN VARCHAR2,
             P_Msg_Count                 IN NUMBER,
             P_Msg_Data                  IN VARCHAR2,
             P_Error_Code                OUT NOCOPY VARCHAR2,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN

  IS

    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_api_name                   CONSTANT VARCHAR2(100) := 'Return_Error_Messages';

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Return_Error_Messages<-'||
                               P_calling_sequence;

    -------------------------------------------------------------------
    l_debug_info := 'Get error message from eTax API';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    BEGIN
    SELECT message_text
      INTO p_error_code
      FROM zx_errors_gt
     WHERE rownum = 1;
    EXCEPTION
	WHEN OTHERS THEN
	    -------------------------------------------------------------------
	    l_debug_info := 'Get error message from stack';
	    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	    END IF;
	    -------------------------------------------------------------------
	    IF (NVL(P_Msg_Count, 0) <= 1) THEN
	         P_Error_Code := P_Msg_Data;

	    ELSE
	      IF (P_All_Error_Messages = 'N') THEN
	        LOOP
	          P_Error_Code := FND_MSG_PUB.Get;
	          EXIT;
	        END LOOP;
	      ELSE
	        P_Error_Code := NULL;
	      END IF;
	    END IF;
    END;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,p_error_code);
    END IF;

    RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
       IF (SQLCODE <> -20001) THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
         FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_Error_Code = '||P_Error_Code||
             ' P_Calling_Sequence = '||P_Calling_Sequence);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
       END IF;

       APP_EXCEPTION.RAISE_EXCEPTION;

  END Return_Error_Messages;

/*=============================================================================
 |  FUNCTION - Is_Tax_Already_Calc_Inv()
 |
 |  DESCRIPTION
 |    This function will return TRUE if any taxable line in the invoice has the
 |    tax_already_calculated_flag equals Y.  It will return FALSE otherwise.
 |
 |  PARAMETERS
 |    P_Invoice_Id - Invoice Id
 |    P_Calling_Sequence - calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    29-DEC-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Is_Tax_Already_Calc_Inv(
             P_Invoice_Id                IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN
  IS

    l_debug_info                        VARCHAR2(240);
    l_curr_calling_sequence             VARCHAR2(4000);
    l_tax_already_calculated_flag       VARCHAR2(1) := 'N';
    l_api_name			  CONSTANT VARCHAR2(100) := 'Is_Tax_Already_Calc_Inv';

    -- Modified this select to include the TAX only case
    CURSOR tax_already_calculated IS
    SELECT 'Y'
--- Start for bug 6485124
    FROM   zx_lines_det_factors
     WHERE  trx_id = p_invoice_id
     AND application_id        =  200
     AND entity_code   =  'AP_INVOICES'
     AND event_class_code IN
         ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
     AND ROWNUM=1;
--- End for bug 6485124
-- commented for bug 6485124
/*      FROM ap_invoice_lines_all
     WHERE invoice_id = p_invoice_id
       AND line_type_lookup_code <> 'AWT'
       AND (tax_already_calculated_flag = 'Y'
             OR  summary_tax_line_id IS NOT NULL)
       AND ROWNUM = 1; */

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Is_Tax_Already_Called_Inv<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
	END IF;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get tax_already_calculated_flag for any '||
                    'taxable line in the invoice';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
    -------------------------------------------------------------------
    OPEN tax_already_calculated;
    FETCH tax_already_calculated
     INTO l_tax_already_calculated_flag;
      CLOSE tax_already_calculated;

    IF (l_tax_already_calculated_flag = 'Y') THEN
       -------------------------------------------------------------------
       l_debug_info := 'Step 1.1: Tax Already Calculated Flag: '||l_tax_already_calculated_flag;
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;
      -------------------------------------------------------------------
      RETURN TRUE;

    ELSE
      RETURN FALSE;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Id||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF (tax_already_calculated%ISOPEN ) THEN
        CLOSE tax_already_calculated;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Is_Tax_Already_Calc_Inv;




 /*=============================================================================
 |  FUNCTION - Is_Tax_Already_Calc_Inv_char()
 |
 |  DESCRIPTION
 |    This function will return Y if any taxable line in the invoice has the
 |    tax_already_calculated_flag equals Y.  It will return N otherwise.
 |
 |    This function is same of Is_Tax_Already_Calc_Inv except that
 |	it returns VARCHAR instead of BOOLEAN.
 |
 |  PARAMETERS
 |    P_Invoice_Id - Invoice Id
 |    P_Calling_Sequence - calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    29-DEC-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Is_Tax_Already_Calc_Inv_char(
             P_Invoice_Id                IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN VARCHAR2
  IS

    l_debug_info                        VARCHAR2(240);
    l_curr_calling_sequence             VARCHAR2(4000);
    l_tax_already_calculated_flag       VARCHAR2(1) := 'N';
    l_api_name			  CONSTANT VARCHAR2(100) := 'Is_Tax_Already_Calc_Inv_char';


  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Is_Tax_Already_Called_Inv<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
	END IF;


    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get tax_already_calculated_flag for any '||
                    'taxable line in the invoice';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
    -------------------------------------------------------------------
     SELECT 'Y'
      INTO l_tax_already_calculated_flag
      FROM ap_invoice_lines_all
     WHERE invoice_id = p_invoice_id
       AND line_type_lookup_code <> 'AWT'
       AND (tax_already_calculated_flag = 'Y'
             OR  summary_tax_line_id IS NOT NULL)
       AND ROWNUM = 1;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1.1: Tax_already_calculated_flag '||l_tax_already_calculated_flag;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
	END IF;
    -------------------------------------------------------------------

   RETURN(l_tax_already_calculated_flag);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN(l_tax_already_calculated_flag);
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Id||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Is_Tax_Already_Calc_Inv_char;

/*=============================================================================
 |  FUNCTION - Is_Tax_Already_Dist_Inv()
 |
 |  DESCRIPTION
 |    This function will return TRUE if any taxable dist in the invoice has the
 |    tax_already_distributed_flag equals Y.  It will return FALSE otherwise.
 |
 |  PARAMETERS
 |    P_Invoice_Id - Invoice Id
 |    P_Calling_Sequence - calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    29-DEC-2003   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Is_Tax_Already_Dist_Inv(
             P_Invoice_Id                IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN BOOLEAN
  IS

    l_debug_info                        VARCHAR2(240);
    l_curr_calling_sequence             VARCHAR2(4000);
    l_tax_already_distributed_flag       VARCHAR2(1) := 'N';
    l_api_name			  CONSTANT VARCHAR2(100) := 'Is_Tax_Already_Dist_Inv';


    -- Modified this select to include the TAX only case
    CURSOR etax_already_distributed IS
    SELECT 'Y'
      FROM ap_invoice_distributions_all
     WHERE invoice_id = p_invoice_id
       AND line_type_lookup_code <> 'AWT'
       AND (tax_already_distributed_flag = 'Y'
            OR detail_tax_dist_id IS NOT NULL)
       AND (related_id IS NULL
            OR related_id = invoice_distribution_id)
       AND ROWNUM = 1;

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Is_Tax_Already_Dist_Inv<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;
    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get tax_already_Distributed_flag for any '||
                    'taxable line in the invoice';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    OPEN etax_already_distributed;
    FETCH etax_already_distributed INTO l_tax_already_distributed_flag;
    IF (etax_already_distributed%NOTFOUND) THEN
      CLOSE etax_already_distributed;
      l_tax_already_distributed_flag := 'N';

    END IF;

    IF (etax_already_distributed%ISOPEN ) THEN
      CLOSE etax_already_distributed;
    END IF;

    IF (l_tax_already_distributed_flag = 'Y') THEN
    -------------------------------------------------------------------
    l_debug_info := 'Step 1.1: Tax_already_Distributed_flag '||l_tax_already_distributed_flag;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

      RETURN TRUE;

    ELSE
      RETURN FALSE;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Id||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF (etax_already_distributed%ISOPEN ) THEN
        CLOSE etax_already_distributed;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Is_Tax_Already_Dist_Inv;

/*=============================================================================
 |  FUNCTION - Get_Dist_Id_For_Tax_Dist_Id()
 |
 |  DESCRIPTION
 |    This function will return the invoice_distribution_id for an AP TAX (
 |    recoverable, non recoverable or tax variance distribution)
 |    based on the detail_tax_dist_id
 |
 |  PARAMETERS
 |    P_Tax_Dist_Id - Is the id for a Tax distribution in eTax
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    02-APR-2004   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION Get_Dist_Id_For_Tax_Dist_Id(
             P_Tax_Dist_Id               IN NUMBER ) RETURN NUMBER
  IS

    l_debug_info                        VARCHAR2(240);
    l_curr_calling_sequence             VARCHAR2(4000);
    l_invoice_distribution_id
    ap_invoice_distributions_all.invoice_distribution_id%TYPE;
    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Dist_Id_For_Tax_Dist_Id';

    CURSOR invoice_dist_id IS
    SELECT invoice_distribution_id
      FROM ap_invoice_distributions_all
     WHERE detail_tax_dist_id = P_Tax_Dist_Id;

  BEGIN

    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get invoice_distribution_id from tax dist id';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    OPEN  invoice_dist_id;
    FETCH invoice_dist_id INTO l_invoice_distribution_id;
    IF (invoice_dist_id%NOTFOUND) THEN
      CLOSE invoice_dist_id;
      l_invoice_distribution_id := NULL;

    END IF;

    IF (invoice_dist_id%ISOPEN ) THEN
      CLOSE invoice_dist_id;
    END IF;

    RETURN l_invoice_distribution_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
          'AP_ETAX_UTILITY_PKG.Get_Dist_Id_For_Tax_Dist_Id');
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Tax_Dist_Id = '||P_Tax_Dist_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF (invoice_dist_id%ISOPEN ) THEN
        CLOSE invoice_dist_id;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Get_Dist_Id_For_Tax_Dist_Id;


  --ETAX: Invwkb
  /*=============================================================================
  |  FUNCTION - Is_Tax_Dist_Frozen()
  |
  |  DESCRIPTION
  |    This function will return TRUE when the tax distribution is frozen
  |    as per the following rules, else will return FALSE.
  |
  |    When the function returns TRUE, then user should not modify the tax
  |    distribution, and vice versa.
  |
  |  PARAMETERS
  |    P_Invoice_Id  - Is the invoice_id of the tax distribution
  |    P_Tax_Dist_Id - Is the id for a Tax distribution in eTax
  |
  |  USAGE: This function is called from ETAX security functions in APXINWKB.fmb
  |         from the form procedure 'IS_TAX_DIST_FROZEN'.
  |
  |  MODIFICATION HISTORY
  |    DATE          Author         Action
  |    01-JUL-2004   SMYADAM        Created
  |
  *============================================================================*/
  FUNCTION Is_Tax_Dist_Frozen(P_Invoice_Id IN NUMBER,
                              P_Tax_Dist_Id IN NUMBER,
			      P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN IS

   l_posted_flag              ap_invoice_distributions.posted_flag%TYPE;
   l_encumbered_flag  	      ap_invoice_distributions.encumbered_flag%TYPE;
   l_parent_distribution_id   ap_invoice_distributions.invoice_distribution_id%TYPE;
   l_prepay_distribution_id   ap_invoice_distributions.invoice_distribution_id%TYPE;
   l_pa_addition_flag	      ap_invoice_distributions.pa_addition_flag%TYPE;
   l_match_status_flag	      ap_invoice_distributions.match_status_flag%TYPE;
   l_invoice_type_lookup_code ap_invoices.invoice_type_lookup_code%TYPE;
   l_line_type_lookup_code    ap_invoice_lines.line_type_lookup_code%TYPE;
   l_parent_line_type_lookup_code  ap_invoice_lines.line_type_lookup_code%TYPE;
   l_parent_line_number	      ap_invoice_lines.line_number%TYPE;
   l_discarded_flag	      ap_invoice_lines.discarded_flag%TYPE;
   l_reversal_flag	      ap_invoice_distributions.reversal_flag%TYPE;
   l_po_distribution_id       po_distributions.po_distribution_id%TYPE;
   l_rcv_transaction_id	      rcv_transactions.transaction_id%TYPE;
   l_parent_dist_amount	      ap_invoice_distributions.amount%TYPE;
   l_prepay_amount_remaining  ap_invoice_distributions.prepay_amount_remaining%TYPE;
   l_debug_info 	      VARCHAR2(1000);
   l_tax_dist_frozen          VARCHAR2(1) := 'N';
   l_curr_calling_sequence    VARCHAR2(2000);
  BEGIN

   l_curr_calling_sequence := p_calling_sequence || ' -> AP_Etax_Utility_Pkg.Is_Tax_Dist_Frozen';

   l_debug_info := 'Select values from ap_invoice_distributions for tax distribution id';

   SELECT aid1.invoice_distribution_id parent_distribution_id,
   	  ai.invoice_type_lookup_code ,
	  ail.line_type_lookup_code,
	  ail1.line_type_lookup_code parent_line_type_lookup_code,
	  ail1.line_number parent_line_number,
	  ail1.discarded_flag,
	  aid.posted_flag,
   	  aid.encumbered_flag,
	  aid.reversal_flag,
	  aid.prepay_distribution_id,
	  aid.pa_addition_flag,
	  nvl(aid.match_status_flag,'N'),
	  aid1.po_distribution_id,
	  aid1.rcv_transaction_id,
	  aid1.amount,
	  aid1.prepay_amount_remaining
   INTO l_parent_distribution_id,
    	l_invoice_type_lookup_code,
	l_line_type_lookup_code,
	l_parent_line_type_lookup_code,
	l_parent_line_number,
	l_discarded_flag,
        l_encumbered_flag,
	l_posted_flag,
	l_reversal_flag,
	l_prepay_distribution_id,
	l_pa_addition_flag,
	l_match_status_flag,
	l_po_distribution_id,
	l_rcv_transaction_id,
	l_parent_dist_amount,
	l_prepay_amount_remaining
   FROM ap_invoice_distributions aid,
   	ap_invoice_distributions aid1,
	ap_invoices ai,
	ap_invoice_lines ail,
	ap_invoice_lines ail1
   WHERE ai.invoice_id = p_invoice_id
   AND ail.invoice_id = ai.invoice_id
   AND ail.line_number = aid.invoice_line_number
   AND aid.invoice_id = ai.invoice_id
   AND aid1.invoice_id = ai.invoice_id
   AND aid.invoice_distribution_id = p_tax_dist_id
   /* Outer join is needed since charge_applicable_to_dist_id can be NULL
      for Tax-Only lines */
   AND aid.charge_applicable_to_dist_id = aid1.invoice_distribution_id(+)
   AND ail1.invoice_id = p_invoice_id
   AND aid1.invoice_line_number = ail1.line_number(+);

   --Rule 1: Tax distribution is frozen if the parent Tax line has been discarded
   l_debug_info := 'Checking if parent tax line is discarded';
   IF (l_line_type_lookup_code = 'TAX' ) THEN  /* for exclusive case */

      IF (l_tax_dist_frozen = 'N' and l_discarded_flag = 'Y') THEN
         l_tax_dist_frozen := 'Y';
      END IF;

   ELSE /* for inclusive case */

      --SMYADAM: Need to validate if this below query is right ?
      --Basically we need to figure out if the Tax line has been discarded in ETAX
      --for the inclusive case. can we use cancel_flag , since
      --discard_flag is not available on zx_lines?

      /*
      SELECT zl.discarded_flag
      INTO l_discarded_flag
      FROM zx_lines zl,
           zx_rec_nrec_dist zd,
           ap_invoice_distributions aid
      WHERE zl.tax_line_id = zd.tax_line_id
      AND nvl(zl.reporting_only_flag, 'N') = 'N'
      AND zd.rec_nrec_tax_dist_id = aid.detail_tax_dist_id
      AND aid.invoice_distribution_id = p_tax_dist_id; */

      IF (l_tax_dist_frozen = 'N' and l_discarded_flag = 'Y') THEN
         l_tax_dist_frozen := 'Y';
      END IF;

   END IF;


   --Rule 2: Tax distribution is frozen if the parent item line is adjusted
   --	     by PO Price adjustment or is itself an adjustment.
   l_debug_info := 'Checking if parent item line is a adjustment or referred by a adjustment';

   IF (l_parent_line_number IS NOT NULL) THEN
      IF (l_tax_dist_frozen = 'N' AND
          (ap_invoice_lines_utility_pkg.is_line_a_adjustment(p_invoice_id,
       						     l_parent_line_number,
						     l_curr_calling_sequence) or
           ap_invoice_lines_utility_pkg.line_referred_by_adjustment(
	   					     p_invoice_id,
						     l_parent_line_number,
						     l_curr_calling_sequence))) THEN

	   l_tax_dist_frozen := 'Y';
      END IF;
   END IF;


   --Rule 3: Tax distribution is frozen if the parent item line is corrected
   --	     or is itself a correction.
   l_debug_info := 'Checking if parent item line is corrected or is a correction';

   IF (l_parent_line_number IS NOT NULL) THEN
      IF (l_tax_dist_frozen = 'N' AND
          (ap_invoice_lines_utility_pkg.is_line_a_correction(p_invoice_id,
	                                             l_parent_line_number,
						     l_curr_calling_sequence) or
           ap_invoice_lines_utility_pkg.line_referred_by_corr(p_invoice_id,
                                                     l_parent_line_number,
						     l_curr_calling_sequence))) THEN

           l_tax_dist_frozen := 'Y';
      END IF;
   END IF;


   --Rule 4: Tax distribution is frozen if Parent Item line is a
   --	     Prepayment application/unapplication
   l_debug_info := 'Checking if parent item line is a Prepayment
   			application/unapplication';

   IF (l_parent_line_number IS NOT NULL) THEN
      IF (l_tax_dist_frozen = 'N' AND l_parent_line_type_lookup_code = 'PREPAY') THEN
         l_tax_dist_frozen := 'Y';
      END IF;
   END IF;


   --Rule 5: Tax distribution is frozen if the tax distribution is
   --	     partially or fully accounted
   l_debug_info := 'Checking if tax distribution is partially or fully accounted';

   IF (l_tax_dist_frozen = 'N' AND l_posted_flag <> 'N') THEN
      l_tax_dist_frozen := 'Y';
   END IF;


   --Rule 6: Tax distribution is frozen if the tax distribution is
   -- 	     encumbered.
   l_debug_info := 'Checking if tax distribution is encumbered';

   IF (l_tax_dist_frozen = 'N' AND l_encumbered_flag IN ('Y','D','W','X')) THEN
      l_tax_dist_frozen := 'Y';
   END IF;


   --Rule 7: Tax distribution is frozen if the tax distribution is
   -- 	     transferred to projects.
   l_debug_info := 'Checking if tax distribution is transferred to Projects';

   IF (l_tax_dist_frozen = 'N' AND l_pa_addition_flag NOT IN ('N', 'E')) THEN
      l_tax_dist_frozen := 'Y';
   END IF;


   --Rule 8: Tax distribution is frozen if the tax distribution is
   --        part of a reversal pair.
   l_debug_info := 'Checking if tax distribution is part of a reversal pair';

   IF (l_tax_dist_frozen = 'N' AND l_reversal_flag = 'Y') THEN
      l_tax_dist_frozen := 'Y';
   END IF;


   --Rule 9: Tax distribution is frozen if the tax distribution is
   --	     validated (accounting event has been created).
   l_debug_info := 'Checking if tax distribution is validated';

   IF (l_tax_dist_frozen = 'N' AND l_match_status_flag <> 'N') THEN
      l_tax_dist_frozen := 'Y';
   END IF;


   --Rule 10: Tax distribution is frozen if the parent item distribution is
   --	      PO/RCV matched.
   l_debug_info := 'Checking if parent item distribution is PO/RCV matched';

   IF (l_parent_line_number IS NOT NULL) THEN
      IF (l_tax_dist_frozen = 'N' AND
           ( l_po_distribution_id IS NOT NULL
	     OR l_rcv_transaction_id IS NOT NULL)) THEN
         l_tax_dist_frozen := 'Y';
      END IF;
   END IF;


   --Rule 11: Tax distribution is frozen if the parent item distribution is
   --	      part of Prepayment , and has been partially or fully applied.
   l_debug_info := 'Checking if parent item distribution is prepay dist that has been partially
   		    or fully applied';

   IF (l_parent_line_number IS NOT NULL and l_parent_line_type_lookup_code = 'PREPAY') THEN
       IF (l_tax_dist_frozen = 'N' AND
           nvl(l_prepay_amount_remaining,l_parent_dist_amount) <> l_parent_dist_amount) THEN
	   l_tax_dist_frozen := 'Y';
       END IF;
   END IF;


   IF (l_tax_dist_frozen = 'Y') THEN
      return(TRUE);
   ELSE
      return(FALSE);
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
	                ' P_Invoice_Id = '||P_Invoice_id||
	                ' P_Tax_Dist_Id = '||P_Tax_Dist_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     END IF;

     APP_EXCEPTION.RAISE_EXCEPTION;

  END Is_Tax_Dist_Frozen;



  /*=============================================================================
  |  FUNCTION - Is_Tax_Line_Delete_Allowed()
  |
  |  DESCRIPTION
  |    This function will return TRUE when Detail Tax line can be deleted in ETAX,
  |    else will return FALSE.
  |
  |    When the function returns TRUE, then user can delete the TAX line else
  |      should not be allowed to delete the TAX line.
  |
  |  PARAMETERS
  |    P_Invoice_Id  - Is the invoice_id of the of the Invoice which owns this
  |                    detail tax line indirectly through the summary tax line.
  |    P_Detail_Tax_Line_Id - Is the id for a Detail Tax Line in eTax
  |
  |  USAGE: This function is called from ETAX security functions in APXINWKB.fmb
  |         from the form procedure 'IS_TAX_LINE_DELETE_ALLOWED'.
  |
  |  MODIFICATION HISTORY
  |    DATE          Author         Action
  |    04-JUL-2004   SMYADAM        Created
  |
  *============================================================================*/
  FUNCTION IS_TAX_LINE_DELETE_ALLOWED(P_Invoice_Id IN NUMBER,
                                      P_Detail_Tax_Line_Id IN NUMBER,
                                      P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN IS

     CURSOR Tax_Distributions IS
     SELECT aid.invoice_distribution_id
     FROM ap_invoice_distributions aid,
          zx_rec_nrec_dist zd
     WHERE aid.invoice_id = p_invoice_id
     AND aid.detail_tax_dist_id = zd.rec_nrec_tax_dist_id
     AND zd.tax_line_id = p_detail_tax_line_id;

     l_tax_invoice_distribution_id ap_invoice_distributions.invoice_distribution_id%TYPE;
     l_tax_line_delete_allowed     varchar2(1) := 'Y';
     l_debug_info		   varchar2(1000);
     l_curr_calling_sequence	   varchar2(2000);
     l_api_name			  CONSTANT VARCHAR2(100) := 'IS_TAX_LINE_DELETE_ALLOWED';

  BEGIN

   l_curr_calling_sequence := p_calling_sequence ||'->AP_Etax_Utility_Pkg.Is_Tax_Line_Delete_Allowed';

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
   END IF;

   l_debug_info := 'Open Tax_Distributions Cursor';

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   OPEN tax_distributions;

   LOOP

    FETCH tax_distributions INTO l_tax_invoice_distribution_id;

    EXIT WHEN tax_distributions%NOTFOUND OR l_tax_line_delete_allowed = 'N';

    IF (ap_etax_utility_pkg.is_tax_dist_frozen(p_invoice_id => p_invoice_id,
    					       p_tax_dist_id => l_tax_invoice_distribution_id,
					       p_calling_sequence => l_curr_calling_sequence)) THEN
      l_tax_line_delete_allowed := 'N';
    END IF;

   END LOOP;

      l_debug_info := 'Tax Line Delete Allowed '||l_tax_line_delete_allowed;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   IF (l_tax_line_delete_allowed = 'N') THEN
     RETURN(FALSE);
   ELSE
     RETURN(TRUE);
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
                           ' P_Invoice_Id = '||P_Invoice_id||
                           ' P_Detail_Tax_Line_Id = '||P_Detail_Tax_Line_Id);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END IS_TAX_LINE_DELETE_ALLOWED;

/*=============================================================================
 |  PROCEDURE - set_tax_security_context()
 |
 |  DESCRIPTION
 |    This procedure will return the tax effective date. The effective date
 |    is used in the list of values for tax drivers and tax related attributes.
 |
 |  PARAMETERS
 |	p_org_id		- Operating unit identifier
 |	p_legal_entity_id	- Legal entity identifier.
 |	p_transaction_date	- Transaction Date.
 |    P_Related_Doc_Date  - Date of the related document.  (Eg: Standard PO)
 |    P_Adjusted_Doc_Date - Date of the adjusted document. (Eg: DM/CM applied to Invoice)
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE set_tax_security_context
				(p_org_id		IN NUMBER,
				 p_legal_entity_id	IN NUMBER,
				 p_transaction_date	IN DATE,
				 p_related_doc_date	IN DATE,
				 p_adjusted_doc_date	IN DATE,
				 p_effective_date	OUT NOCOPY DATE,
				 p_return_status	OUT NOCOPY VARCHAR2,
				 p_msg_count		OUT NOCOPY NUMBER,
				 p_msg_data		OUT NOCOPY VARCHAR2) IS

       l_debug_info	VARCHAR2(240);
       l_api_name			  CONSTANT VARCHAR2(100) := 'set_tax_security_context';

  BEGIN
        ---------------------------------------------------------------
	l_debug_info := 'Calling zx_api_pub.set_tax_security_context';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
        ---------------------------------------------------------------

	IF p_org_id	      IS NOT NULL AND
	   p_legal_entity_id  IS NOT NULL AND
	   p_transaction_date IS NOT NULL THEN

	zx_api_pub.set_tax_security_context
				(p_api_version		=> 1.0,          -- Bug 6469397
				 p_init_msg_list	=> FND_API.G_FALSE,
				 p_commit		=> FND_API.G_FALSE,
				 p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
				 x_return_status	=> p_return_status,
				 x_msg_count		=> p_msg_count,
				 x_msg_data             => p_msg_data,
				 p_internal_org_id	=> p_org_id,
				 p_legal_entity_id      => p_legal_entity_id,
				 p_transaction_date	=> p_transaction_date,
				 p_related_doc_date	=> p_related_doc_date,
				 p_adjusted_doc_date	=> p_adjusted_doc_date,
				 x_effective_date	=> p_effective_date);

	END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'AP_ETAX_UTILITY_PKG.set_tax_security_context');
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'p_org_id: '	   || p_org_id 		 ||
					    'p_legal_entity_id: '  || p_legal_entity_id  ||
					    'p_transaction_date: ' || p_transaction_date ||
					    'p_related_doc_date: ' || p_related_doc_date);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END set_tax_security_context;


/*=============================================================================
 |  FUNCTION get_tipv()
 |
 |  DESCRIPTION
 |    This function will return the invoice price variance.
 |
 *============================================================================*/
  FUNCTION get_tipv ( p_rate_tax_factor     IN NUMBER   ,
                      p_quantity_invoiced   IN NUMBER   ,
                      p_inv_unit_price      IN NUMBER   ,
                      p_ref_doc_unit_price  IN NUMBER   ,
                      p_ref_per_unit_nr_amt IN NUMBER   ,
                      p_pc_price_diff       IN NUMBER   ,
                      p_corrected_inv_id    IN NUMBER   ,
                      p_line_type           IN VARCHAR2 ,
                      p_line_source         IN VARCHAR2 ,
                      p_inv_currency_code   IN VARCHAR2 ,
                      p_line_match_type     IN VARCHAR2 ) RETURN NUMBER IS

    p_tax_ipv NUMBER;
    l_debug_info varchar2(2000);
    l_api_name VARCHAR2(2000) := 'get_tipv';

  BEGIN

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

        l_debug_info := 'p_rate_tax_factor '||p_rate_tax_factor||' '||'p_quantity_invoiced '||p_quantity_invoiced||' '||
                        'p_inv_unit_price '||p_inv_unit_price||' '||'p_ref_doc_unit_price '||p_ref_doc_unit_price||' '||
                        'p_ref_per_unit_nr_amt '||p_ref_per_unit_nr_amt||' '||'p_pc_price_diff '||p_pc_price_diff||' '||
                        'p_corrected_inv_id '||p_corrected_inv_id||' '||'p_line_type '||p_line_type||' '||
                        'p_line_source '||p_line_source||' '||'p_inv_currency_code '||p_inv_currency_code||' '||
                        'p_line_match_type '||p_line_match_type;
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    IF p_line_type = 'RETROITEM' THEN

       -- When a PO is retro-priced, price variances are reversed on the original document
       -- and moved to the expense account. This is done in the open interface program and
       -- the tax lines will have tax_already_calculated_flag set to 'Y'. TIPV is computed
       -- as zero for the PPA document.

       p_tax_ipv := 0;


        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

            l_debug_info := 'In P_LINE_TYPE = RETROITEM CHECK. TAX IPV IS 0';
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

        END IF;

    ELSIF p_corrected_inv_id IS NULL THEN

           IF p_line_match_type IN ('ITEM_TO_SERVICE_RECEIPT', 'ITEM_TO_SERVICE_PO') THEN

              p_tax_ipv := 0;

              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                 l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_SERVICE_RECEIPT OR ITEM_TO_SERVICE_PO. HENCE TAX IPV IS 0';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

              END IF;



           ELSE
                  -- PO/Receipt Matched Invoice

                  p_tax_ipv := p_rate_tax_factor * p_quantity_invoiced *
                       (p_inv_unit_price - p_ref_doc_unit_price) * p_ref_per_unit_nr_amt;


                  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                     l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_RECEIPT OR ITEM_TO_PO. HENCE TAX IPV IS '||p_tax_ipv;

                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                     l_debug_info := 'p_tax_ipv := p_rate_tax_factor * p_quantity_invoiced * (p_inv_unit_price - p_ref_doc_unit_price) * p_ref_per_unit_nr_amt '||
                                      p_rate_tax_factor ||' * '||p_quantity_invoiced||' * ('||p_inv_unit_price ||' - '||p_ref_doc_unit_price||') * '||
                                      p_ref_per_unit_nr_amt;

                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                  END IF;

       END IF;

    ELSIF p_corrected_inv_id IS NOT NULL THEN

          -- Price/Quantity Correction

          p_tax_ipv := p_rate_tax_factor * p_quantity_invoiced * p_pc_price_diff * p_ref_per_unit_nr_amt;

                  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                     l_debug_info := 'CORRECTED INV ID IS NOT  NULL. HENCE TAX IPV IS '||p_tax_ipv;

                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                     l_debug_info := 'p_tax_ipv := p_rate_tax_factor * p_quantity_invoiced * p_inv_unit_price * p_ref_per_unit_nr_amt '||
                                      p_rate_tax_factor ||' * '||p_quantity_invoiced||' * '||p_inv_unit_price||' * '||
                                      p_ref_per_unit_nr_amt;

                     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                  END IF;


    END IF;

    IF p_tax_ipv IS NOT NULL THEN

       p_tax_ipv := ap_utilities_pkg.ap_round_currency (p_tax_ipv, p_inv_currency_code);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

           l_debug_info := 'TAX IPV AFTER ROUNDING IS '||p_tax_ipv;

           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;


    END IF;

    RETURN NVL(p_tax_ipv,0);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

         RETURN NVL(p_tax_ipv,0);

    WHEN OTHERS THEN

         RETURN NVL(p_tax_ipv,0);

  END get_tipv;

/*=============================================================================
 |  FUNCTION get_tipv_base()
 |
 |  DESCRIPTION
 |    This function will return the base invoice price variance.
 |
 *============================================================================*/
  FUNCTION get_tipv_base
        ( p_rate_tax_factor          IN NUMBER ,
          p_quantity_invoiced        IN NUMBER ,
          p_inv_unit_price           IN NUMBER ,
          p_ref_doc_unit_price       IN NUMBER ,
          p_ref_per_trx_nrec_amt     IN NUMBER ,
          p_price_diff               IN NUMBER ,
          p_inv_currency_rate        IN NUMBER ,
          p_ref_doc_curr_rate        IN NUMBER ,
          p_adj_doc_curr_rate        IN NUMBER ,
          p_corrected_inv_id         IN NUMBER ,
          p_line_type                IN VARCHAR2 ,
          p_line_source              IN VARCHAR2 ,
          p_inv_currency_code        IN VARCHAR2 ,
          p_base_currency_code       IN VARCHAR2 ,
          p_line_match_type          IN VARCHAR2 ) RETURN NUMBER IS

    p_tax_ipv_base NUMBER;
    l_debug_info varchar2(2000);
    l_api_name VARCHAR2(2000) := 'get_tipv_base';

        --bug 5528375
        l_tax_ipv      NUMBER;

  BEGIN

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

        l_debug_info := 'p_rate_tax_factor '||p_rate_tax_factor||' '||'p_quantity_invoiced '||p_quantity_invoiced||' '||
                        'p_inv_unit_price '||p_inv_unit_price||' '||'p_ref_doc_unit_price '||p_ref_doc_unit_price||' '||
                        'p_ref_per_trx_nrec_amt '||p_ref_per_trx_nrec_amt||' '||'p_price_diff '||p_price_diff||' '||
                        'p_inv_currency_rate '||p_inv_currency_rate||' '||'p_ref_doc_curr_rate '||p_ref_doc_curr_rate||' '||
                        'p_adj_doc_curr_rate '||p_adj_doc_curr_rate||' '||'p_corrected_inv_id '||p_corrected_inv_id||' '||
                        'p_line_type '||p_line_type||' '||'p_line_source '||p_line_source||' '||
                        'p_inv_currency_code '||p_inv_currency_code||' '||'p_base_currency_code '||p_base_currency_code||' '||
                        'p_line_match_type '||p_line_match_type;
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    IF p_line_type = 'RETROITEM' THEN

       -- PO Price Adjustment

       p_tax_ipv_base := 0;

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

            l_debug_info := 'In P_LINE_TYPE = RETROITEM CHECK. TAX IPV BASE IS 0';
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;


    ELSIF p_corrected_inv_id IS NULL THEN

           IF p_line_match_type IN ('ITEM_TO_SERVICE_RECEIPT', 'ITEM_TO_SERVICE_PO') THEN

              p_tax_ipv_base := 0;


              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                 l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_SERVICE_RECEIPT OR ITEM_TO_SERVICE_PO. HENCE TAX IPV BASE IS 0';
                 FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

              END IF;

           ELSE

                -- PO/Receipt Matched Invoice

                p_tax_ipv_base := p_rate_tax_factor * p_quantity_invoiced * p_inv_currency_rate *
                            (p_inv_unit_price - p_ref_doc_unit_price ) * p_ref_per_trx_nrec_amt;


                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                   l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_RECEIPT OR ITEM_TO_PO. HENCE TAX IPV BASE IS '||p_tax_ipv_base;

                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                    l_debug_info := 'p_tax_ipv_base := p_rate_tax_factor * p_quantity_invoiced * p_inv_currency_rate * (p_inv_unit_price - p_ref_doc_unit_price) * p_ref_per_trx_nrec_amt '||
                                     p_rate_tax_factor ||' * '||p_quantity_invoiced||' * '||p_inv_currency_rate||' * ('||p_inv_unit_price ||' - '||p_ref_doc_unit_price||') * '||
                                     p_ref_per_trx_nrec_amt;

                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                END IF;

              -- Bug 5528375
                l_tax_ipv := p_rate_tax_factor * p_quantity_invoiced *(p_inv_unit_price - p_ref_doc_unit_price) * p_ref_per_trx_nrec_amt;

                IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                    l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_RECEIPT OR ITEM_TO_PO. HENCE l_tax_ipv IS '||l_tax_ipv;

                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                    l_debug_info := 'p_tax_ipv_base := p_rate_tax_factor * p_quantity_invoiced * (p_inv_unit_price - p_ref_doc_unit_price) * p_ref_per_trx_nrec_amt '||
                                     p_rate_tax_factor ||' * '||p_quantity_invoiced||' * ('||p_inv_unit_price ||' - '||p_ref_doc_unit_price||') * '||
                                     p_ref_per_trx_nrec_amt;

                    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                END IF;


       END IF;

    ELSIF p_corrected_inv_id IS NOT NULL THEN

       -- Corrections

       p_tax_ipv_base := p_rate_tax_factor * p_quantity_invoiced * p_adj_doc_curr_rate * p_price_diff * p_ref_per_trx_nrec_amt;

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

          l_debug_info := 'CORRECTED INV ID IS NOT NULL. HENCE TAX IPV BASE IS '||p_tax_ipv_base;

          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

          l_debug_info := 'p_tax_ipv_base := p_rate_tax_factor * p_quantity_invoiced * p_adj_doc_curr_rate * p_price_diff * p_ref_per_trx_nrec_amt '||
                           p_rate_tax_factor ||' * '||p_quantity_invoiced||' * '||p_adj_doc_curr_rate||' * '|| p_price_diff ||' * '||p_ref_per_trx_nrec_amt;

          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;


           -- Bug 5528375
       l_tax_ipv := p_rate_tax_factor * p_quantity_invoiced * p_price_diff * p_ref_per_trx_nrec_amt;


       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

          l_debug_info := 'CORRECTED INV ID IS NOT NULL. HENCE l_tax_ipv IS '||l_tax_ipv;

          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

          l_debug_info := 'l_tax_ipv := p_rate_tax_factor * p_quantity_invoiced * p_price_diff * p_ref_per_trx_nrec_amt '||
                           p_rate_tax_factor ||' * '||p_quantity_invoiced||' * '||p_price_diff||' * '|| p_ref_per_trx_nrec_amt;

          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;



    END IF;

    IF p_tax_ipv_base IS NOT NULL THEN
       p_tax_ipv_base := ap_utilities_pkg.ap_round_currency (p_tax_ipv_base, p_base_currency_code);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

           l_debug_info := 'TAX IPV BASE AFTER ROUNDING IS '||p_tax_ipv_base;

           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;


    END IF;

        -- Bug 5528375
    IF l_tax_ipv IS NOT NULL THEN
      l_tax_ipv := ap_utilities_pkg.ap_round_currency (l_tax_ipv, p_inv_currency_code);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

           l_debug_info := 'l_tax_ipv AFTER ROUNDING IS '||l_tax_ipv;

           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;


        ELSE
           l_tax_ipv := 0;

           IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

              l_debug_info := 'l_tax_ipv IS 0 IN ELSE';

              FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

           END IF;


        END IF;

        RETURN NVL(p_tax_ipv_base,l_tax_ipv);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

         RETURN NVL(p_tax_ipv_base,0);

    WHEN OTHERS THEN

         RETURN NVL(p_tax_ipv_base,0);

  END get_tipv_base;


/*=============================================================================
 |  FUNCTION get_terv()
 |
 |  DESCRIPTION
 |    This function will return the tax exchange rate variance.
 *============================================================================*/
  FUNCTION get_terv
        ( p_quantity_invoiced         IN NUMBER   ,
          p_inv_curr_conv_rate        IN NUMBER   ,
          p_ref_doc_curr_conv_rate    IN NUMBER   ,
          p_app_doc_curr_conv_rate    IN NUMBER   ,
          p_adj_doc_curr_conv_rate    IN NUMBER   ,
          p_per_unit_nrec_amt         IN NUMBER   ,
          p_ref_doc_per_unit_nrec_amt IN NUMBER   ,
          p_corrected_inv_id          IN NUMBER   ,
          p_line_type                 IN VARCHAR2 ,
          p_line_source               IN VARCHAR2 ,
          p_base_currency_code        IN VARCHAR2 ) RETURN NUMBER IS

    p_tax_erv NUMBER;
    l_debug_info varchar2(2000);
    l_api_name VARCHAR2(2000) := 'get_terv';


  BEGIN


    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

        l_debug_info := 'p_quantity_invoiced '||p_quantity_invoiced||' '||'p_inv_curr_conv_rate '||p_inv_curr_conv_rate||' '||
                        'p_ref_doc_curr_conv_rate '||p_ref_doc_curr_conv_rate||' '||'p_app_doc_curr_conv_rate '||p_app_doc_curr_conv_rate||' '||
                        'p_adj_doc_curr_conv_rate '||p_adj_doc_curr_conv_rate||' '||'p_per_unit_nrec_amt '||p_per_unit_nrec_amt||' '||
                        'p_ref_doc_per_unit_nrec_amt '||p_ref_doc_per_unit_nrec_amt||' '||'p_corrected_inv_id '||p_corrected_inv_id||' '||
                        'p_line_type '||p_line_type||' '||'p_line_source '||p_line_source||' '||'p_base_currency_code '||p_base_currency_code;
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;


    IF p_line_type = 'RETROITEM' THEN

       -- TERV = Qi * Ni * (Ei - Ep)

       p_tax_erv := p_quantity_invoiced * p_per_unit_nrec_amt *
            (p_inv_curr_conv_rate - p_ref_doc_curr_conv_rate);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

            l_debug_info := 'In P_LINE_TYPE = RETROITEM CHECK. TAX ERV IS '||p_tax_erv;
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

            l_debug_info := 'p_tax_erv := p_quantity_invoiced * p_per_unit_nrec_amt * (p_inv_curr_conv_rate - p_ref_doc_curr_conv_rate) '||
                             p_quantity_invoiced ||' * '||p_per_unit_nrec_amt||' * ('||p_inv_curr_conv_rate ||' - '||p_ref_doc_curr_conv_rate||')';

            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;


    ELSIF p_corrected_inv_id IS NULL THEN

       -- TERV = Qi * Np * (Ei - Ep)

       p_tax_erv := p_quantity_invoiced * p_ref_doc_per_unit_nrec_amt *
            (p_inv_curr_conv_rate - nvl(p_app_doc_curr_conv_rate,p_ref_doc_curr_conv_rate));


       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

            l_debug_info := 'CORRECTED INV ID IS NULL. HENCE TAX ERV IS  '||p_tax_erv;
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

            l_debug_info := 'p_tax_erv := p_quantity_invoiced * p_ref_doc_per_unit_nrec_amt * (p_inv_curr_conv_rate - nvl(p_app_doc_curr_conv_rate,p_ref_doc_curr_conv_rate)) '||
                             p_quantity_invoiced ||' * '||p_ref_doc_per_unit_nrec_amt||' * ('||p_inv_curr_conv_rate ||' - NVL('||p_app_doc_curr_conv_rate||' , '||p_ref_doc_curr_conv_rate||')';

            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;


    ELSIF p_corrected_inv_id IS NOT NULL THEN

       -- TERV = Qi * Ni * (Eij - Ei).

       p_tax_erv  := p_quantity_invoiced * p_per_unit_nrec_amt *
             (p_inv_curr_conv_rate - p_adj_doc_curr_conv_rate);


       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

            l_debug_info := 'CORRECTED INV ID IS NOT NULL. HENCE TAX ERV IS  '||p_tax_erv;
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

            l_debug_info := 'p_tax_erv := p_quantity_invoiced * p_per_unit_nrec_amt * (p_inv_curr_conv_rate - p_adj_doc_curr_conv_rate) '||
                             p_quantity_invoiced ||' * '||p_per_unit_nrec_amt||' * ('||p_inv_curr_conv_rate ||' - '||p_adj_doc_curr_conv_rate||')';

            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;



    END IF;

    IF p_tax_erv IS NOT NULL THEN

       p_tax_erv := ap_utilities_pkg.ap_round_currency (p_tax_erv, p_base_currency_code);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

           l_debug_info := 'TAX ERV AFTER ROUNDING IS '||p_tax_erv;

           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;

    END IF;

    RETURN NVL(p_tax_erv, 0);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

         RETURN NVL(p_tax_erv,0);

    WHEN OTHERS THEN

         RETURN NVL(p_tax_erv,0);

  END get_terv;

/*=============================================================================
 |  FUNCTION get_tv()
 |
 |  DESCRIPTION
 |    This function will return the invoice price variance.
 |
 *============================================================================*/
  FUNCTION get_tv ( p_rate_tax_factor   IN NUMBER   ,
            p_quantity_invoiced         IN NUMBER   ,
            p_inv_per_unit_nrec         IN NUMBER   ,
            p_ref_per_unit_nrec         IN NUMBER   ,
            p_inv_per_trx_cur_unit_nrec IN NUMBER   ,
            p_ref_per_trx_cur_unit_nrec IN NUMBER   ,
            p_pc_price_diff             IN NUMBER   ,
            p_corrected_inv_id          IN NUMBER   ,
            p_line_type                 IN VARCHAR2 ,
            p_line_source               IN VARCHAR2 ,
            p_inv_currency_code         IN VARCHAR2 ,
            p_line_match_type           IN VARCHAR2 ,
            p_unit_price                IN NUMBER   ) RETURN NUMBER IS

    p_tax_tv NUMBER;
    l_debug_info varchar2(2000);
    l_api_name VARCHAR2(2000) := 'get_tv';

  BEGIN

    /*
      ni = p_inv_per_unit_nrec
      np = p_ref_per_unit_nrec
      ti = p_inv_per_trx_cur_unit_nrec
      tp = p_ref_per_trx_cur_unit_nrec
    */

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

        l_debug_info := 'p_rate_tax_factor '||p_rate_tax_factor||' '||'p_quantity_invoiced '||p_quantity_invoiced||' '||
                        'p_inv_per_unit_nrec '||p_inv_per_unit_nrec||' '||'p_ref_per_unit_nrec '||p_ref_per_unit_nrec||' '||
                        'p_inv_per_trx_cur_unit_nrec '||p_inv_per_trx_cur_unit_nrec||' '||'p_ref_per_trx_cur_unit_nrec '||' '||p_ref_per_trx_cur_unit_nrec||' '||
                        'p_pc_price_diff '||p_pc_price_diff||' '||'p_corrected_inv_id '||p_corrected_inv_id||' '||
                        'p_line_type '||p_line_type||' '||'p_line_source '||p_line_source||' '||'p_inv_currency_code '||' '||p_inv_currency_code||' '||
                        'p_line_match_type '||p_line_match_type||' '||'p_unit_price '||p_unit_price;
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    IF p_line_type = 'RETROITEM' THEN

       -- PPA Document. TV = Qi * Ni * (ti - tp)

              p_tax_tv := p_quantity_invoiced * p_inv_per_unit_nrec *
               (p_inv_per_trx_cur_unit_nrec - p_ref_per_trx_cur_unit_nrec); -- bug 8317515: modify

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

            l_debug_info := 'In P_LINE_TYPE = RETROITEM CHECK. TAX VARIANCE IS '||p_tax_tv;
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

            l_debug_info := 'p_tax_tv := p_quantity_invoiced * p_inv_per_unit_nrec * (p_inv_per_trx_cur_unit_nrec - p_ref_per_trx_cur_unit_nrec) '||
                             p_quantity_invoiced ||' * '||p_inv_per_unit_nrec||' * ('||p_inv_per_trx_cur_unit_nrec ||' - '||p_ref_per_trx_cur_unit_nrec||')';

            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;


    ELSIF p_corrected_inv_id IS NULL THEN

       IF p_line_match_type IN ('ITEM_TO_SERVICE_RECEIPT', 'ITEM_TO_SERVICE_PO') THEN

              p_tax_tv := p_quantity_invoiced * p_unit_price *
                          (p_inv_per_trx_cur_unit_nrec - p_ref_per_trx_cur_unit_nrec); -- bug 8317515: modify


              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                  l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_SERVICE_RECEIPT OR ITEM_TO_SERVICE_PO. HENCE TAX VARIANCE IS '||p_tax_tv;
                  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                  l_debug_info := 'p_tax_tv := p_quantity_invoiced * p_unit_price * (p_inv_per_trx_cur_unit_nrec - p_ref_per_trx_cur_unit_nrec) '||
                                     p_quantity_invoiced||' * '||p_unit_price||' * ('||p_inv_per_trx_cur_unit_nrec ||' - '||p_ref_per_trx_cur_unit_nrec||')';

                  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);


              END IF;

       ELSE
              -- PO/Receipt Matched Invoice. TV = Qi * (ni - np)

              p_tax_tv := p_quantity_invoiced * (p_inv_per_unit_nrec - p_ref_per_unit_nrec); -- bug 8317515: modify


              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                  l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_RECEIPT OR ITEM_TO_PO. HENCE TAX VARIANCE IS '||p_tax_tv;
                  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                  l_debug_info := 'p_tax_tv := p_quantity_invoiced * (p_inv_per_unit_nrec - p_ref_per_unit_nrec) '||
                                   p_quantity_invoiced||' * ('||p_inv_per_unit_nrec ||' - '||p_ref_per_unit_nrec||')';

                  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);


              END IF;



       END IF;

    ELSIF p_corrected_inv_id IS NOT NULL THEN

       -- Price/Quantity Correction. TV = RTF * Qi * Price Diff * ti

       p_tax_tv := p_rate_tax_factor * p_quantity_invoiced * p_pc_price_diff * p_inv_per_trx_cur_unit_nrec; --Bug9363214

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

           l_debug_info := 'CORRECTED INV ID IS NOT NULL. HENCE TAX VARIANCE IS '||p_tax_tv;
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

           l_debug_info := 'p_tax_tv := p_rate_tax_factor * p_quantity_invoiced * p_pc_price_diff * p_inv_per_trx_cur_unit_nrec '||
                            p_rate_tax_factor ||' * '||p_quantity_invoiced||' * '||p_pc_price_diff||' * '||p_inv_per_trx_cur_unit_nrec;
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);


       END IF;

    END IF;

    IF p_tax_tv IS NOT NULL THEN
       p_tax_tv := ap_utilities_pkg.ap_round_currency (p_tax_tv, p_inv_currency_code);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

           l_debug_info := 'TAX VARIANCE AFTER ROUNDING IS '||p_tax_tv;

           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;

    END IF;

    RETURN NVL(p_tax_tv,0);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN

         RETURN NVL(p_tax_tv,0);

    WHEN OTHERS THEN

         RETURN NVL(p_tax_tv,0);

  END get_tv;

/*=============================================================================
 |  FUNCTION get_tv_base()
 |
 |  DESCRIPTION
 |    This function will return the invoice price variance.
 |
 *============================================================================*/
  FUNCTION get_tv_base ( p_rate_tax_factor  IN NUMBER   ,
             p_quantity_invoiced            IN NUMBER   ,
             p_inv_per_unit_nrec            IN NUMBER   ,
             p_ref_per_unit_nrec            IN NUMBER   ,
             p_inv_per_trx_cur_unit_nrec    IN NUMBER   ,
             p_ref_per_trx_cur_unit_nrec    IN NUMBER   ,
             p_inv_curr_rate                IN NUMBER   ,
             p_ref_doc_curr_rate            IN NUMBER   ,
             p_pc_price_diff                IN NUMBER   ,
             p_corrected_inv_id             IN NUMBER   ,
             p_line_type                    IN VARCHAR2 ,
             p_line_source                  IN VARCHAR2 ,
             p_base_currency_code           IN VARCHAR2 ,
             p_line_match_type              IN VARCHAR2 ,
             p_unit_price                   IN NUMBER   ) RETURN NUMBER IS

    p_tax_tv_base NUMBER;
    l_debug_info varchar2(2000);
    l_api_name VARCHAR2(2000) := 'get_tv_base';


  BEGIN
    /*
      ni = p_inv_per_unit_nrec
      np = p_ref_per_unit_nrec
      ti = p_inv_per_trx_cur_unit_nrec
      tp = p_ref_per_trx_cur_unit_nrec
    */

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

        l_debug_info := 'p_rate_tax_factor '||p_rate_tax_factor||' '||'p_quantity_invoiced '||p_quantity_invoiced||' '||
                        'p_inv_per_unit_nrec '||p_inv_per_unit_nrec||' '||'p_ref_per_unit_nrec '||p_ref_per_unit_nrec||' '||
                        'p_inv_per_trx_cur_unit_nrec '||p_inv_per_trx_cur_unit_nrec||' '||'p_ref_per_trx_cur_unit_nrec '||' '||p_ref_per_trx_cur_unit_nrec||' '||
                        'p_inv_curr_rate '||p_inv_curr_rate||' '||'p_ref_doc_curr_rate '||' '||p_ref_doc_curr_rate||' '||
                        'p_pc_price_diff '||p_pc_price_diff||' '||'p_corrected_inv_id '||p_corrected_inv_id||' '||
                        'p_line_type '||p_line_type||' '||'p_line_source '||p_line_source||' '||'p_base_currency_code '||' '||p_base_currency_code||' '||
                        'p_line_match_type '||p_line_match_type||' '||'p_unit_price '||p_unit_price;
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    IF p_line_type = 'RETROITEM' THEN

       IF p_line_source = 'PO PRICE ADJUSTMENT' THEN

          -- PO Price Adjustment Line.
          -- tv_base = Qi * ni * (ti - tp) * Ep

          p_tax_tv_base := p_quantity_invoiced * p_inv_per_unit_nrec * p_ref_doc_curr_rate *
                   (p_inv_per_trx_cur_unit_nrec - p_ref_per_trx_cur_unit_nrec); -- bug 8317515: modify


          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

             l_debug_info := 'In P_LINE_TYPE = RETROITEM AND P_LINE_SOURCE PO PRICE ADJUSTMENT CHECK. TAX VARIANCE BASE IS '||p_tax_tv_base;
             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

             l_debug_info := 'p_tax_tv_base := p_quantity_invoiced * p_inv_per_unit_nrec *  p_ref_doc_curr_rate * (p_inv_per_trx_cur_unit_nrec - p_ref_per_trx_cur_unit_nrec) '||
                              p_quantity_invoiced ||' * '||p_inv_per_unit_nrec||' * '|| p_ref_doc_curr_rate||' * ('||p_inv_per_trx_cur_unit_nrec ||' - '||p_ref_per_trx_cur_unit_nrec||')';

             FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

           END IF;

       END IF;


    ELSIF p_corrected_inv_id IS NULL THEN

           IF p_line_match_type IN ('ITEM_TO_SERVICE_RECEIPT', 'ITEM_TO_SERVICE_PO') THEN

              p_tax_tv_base := p_quantity_invoiced * p_unit_price * p_inv_curr_rate *
                               (p_inv_per_trx_cur_unit_nrec - p_ref_per_trx_cur_unit_nrec); -- bug 8317515: modify


              IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                  l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_RECEIPT OR ITEM_TO_PO. HENCE TAX VARIANCE BASE IS '||p_tax_tv_base;
                  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                  l_debug_info := 'p_tax_tv_base := p_quantity_invoiced *p_unit_price * p_inv_curr_rate *(p_inv_per_trx_cur_unit_nrec - p_ref_per_trx_cur_unit_nrec) '||
                                   p_quantity_invoiced||' * '||p_unit_price||' * '||p_inv_curr_rate ||' * ('||p_inv_per_trx_cur_unit_nrec ||' - '||p_ref_per_trx_cur_unit_nrec||')';

                  FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);


              END IF;

           ELSE

              -- PO/Receipt Matched Invoice.
          -- tv_base = Qi * (ni - np) * Ei

               p_tax_tv_base := p_quantity_invoiced * p_inv_curr_rate * (p_inv_per_unit_nrec - p_ref_per_unit_nrec); -- bug 8317515: modify

               IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

                   l_debug_info := 'CORRECTED INV ID IS NULL AND MATCH TYPE IS ITEM_TO_RECEIPT OR ITEM_TO_PO. HENCE TAX VARIANCE BASE IS '||p_tax_tv_base;
                   FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

                   l_debug_info := 'p_tax_tv_base := p_quantity_invoiced * p_inv_curr_rate * (p_inv_per_unit_nrec - p_ref_per_unit_nrec) '||
                                    p_quantity_invoiced||' * '||p_inv_curr_rate||' * ('||p_inv_per_unit_nrec ||' - '||p_ref_per_unit_nrec||')';

                   FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);


               END IF;

       END IF;

    ELSIF p_corrected_inv_id IS NOT NULL THEN

       -- Price/Quantity Correction.
       -- tv_base = RTF * Qi * Pi * ti * Ei

       p_tax_tv_base := p_rate_tax_factor * p_quantity_invoiced * p_pc_price_diff * p_inv_curr_rate * p_inv_per_trx_cur_unit_nrec ; --Bug9363214

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

           l_debug_info := 'CORRECTED INV ID IS NOT NULL. HENCE TAX VARIANCE BASE IS '||p_tax_tv_base;
           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

           l_debug_info := 'p_tax_tv_base := p_rate_tax_factor * p_quantity_invoiced * p_pc_price_diff * p_inv_curr_rate * p_inv_per_trx_cur_unit_nrec '||
                            p_rate_tax_factor ||' * '||p_quantity_invoiced||' * '||p_pc_price_diff||' * '||p_inv_curr_rate||' * '||
                            p_inv_per_trx_cur_unit_nrec;

           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);


       END IF;

    END IF;

    IF p_tax_tv_base IS NOT NULL THEN
       p_tax_tv_base := ap_utilities_pkg.ap_round_currency (p_tax_tv_base, p_base_currency_code);

       IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN

           l_debug_info := 'TAX VARIANCE BASE AFTER ROUNDING IS '||p_tax_tv_base;

           FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);

       END IF;

    END IF;

    RETURN NVL(p_tax_tv_base,0);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

         RETURN NVL(p_tax_tv_base,0);

    WHEN OTHERS THEN

         RETURN NVL(p_tax_tv_base,0);

  END get_tv_base;

/*=============================================================================
 |  PROCEDURE - get_header_tax_attr_desc()
 |
 |  DESCRIPTION
 |    This procedure will return the description of the following tax drivers
 |    stored at the document header.
 |    1. Taxation Country
 |    2. Document Sub Type
 |    3. Related Invoice
 |
 |  PARAMETERS
 |    P_Taxation_Country        - Taxation Country
 |    P_Document_Sub_Type       - Document Sub Type
 |    P_Tax_Related_Invoice_Id  - Related Invoice
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE get_header_tax_attr_desc
                ( p_taxation_country            IN         VARCHAR2,
                  p_document_sub_type           IN         VARCHAR2,
                  p_tax_related_inv_id          IN         NUMBER,
                  p_taxation_country_desc       OUT NOCOPY VARCHAR2,
                  p_document_sub_type_desc      OUT NOCOPY VARCHAR2,
                  p_tax_related_inv_num         OUT NOCOPY VARCHAR2,
                  p_calling_sequence            IN         VARCHAR2) IS

        CURSOR c_txn_ctry (c_ctry_code VARCHAR2) IS
        SELECT territory_short_name
          FROM fnd_territories_tl
         WHERE territory_code = c_ctry_code
           AND language = userenv ('LANG');

        CURSOR c_tax_rel_inv_num (c_inv_id VARCHAR2) IS
        SELECT ai.invoice_num tax_related_invoice_num
          FROM ap_invoices ai
         WHERE ai.invoice_id = c_inv_id;

        CURSOR c_doc_sub_type (c_class_code VARCHAR2,
                               c_ctry_code  VARCHAR2) IS
        SELECT classification_name
          FROM zx_fc_intended_use_v
         WHERE classification_code = c_class_code
           AND country_code        = c_ctry_code;

        l_debug_info                 VARCHAR2(240);
        l_curr_calling_sequence      VARCHAR2(4000);
        l_api_name			  CONSTANT VARCHAR2(100) := 'get_header_tax_attr_desc';

  BEGIN
        l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Header_Tax_Attr_Desc<-' ||
                                    p_calling_sequence;

        --------------------------------------------------
        l_debug_info := 'Step 1: Get Taxation Country';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --------------------------------------------------
        IF p_taxation_country IS NOT NULL THEN

           OPEN  c_txn_ctry (p_taxation_country);
           FETCH c_txn_ctry
           INTO  p_taxation_country_desc;
           CLOSE c_txn_ctry;

        END IF;

        --------------------------------------------------
        l_debug_info := 'Step 2: Get Related Inv Number';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --------------------------------------------------
        IF p_tax_related_inv_id IS NOT NULL THEN

           OPEN  c_tax_rel_inv_num (p_tax_related_inv_id);
           FETCH c_tax_rel_inv_num
           INTO  p_tax_related_inv_num;
           CLOSE c_tax_rel_inv_num;

        END IF;

        --------------------------------------------------
        l_debug_info := 'Step 3: Get Document Sub Type';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        --------------------------------------------------
        IF p_document_sub_type IS NOT NULL AND
           p_taxation_country  IS NOT NULL THEN

           OPEN  c_doc_sub_type (p_document_sub_type,
                                 p_taxation_country);
           FETCH c_doc_sub_type
           INTO  p_document_sub_type_desc;
           CLOSE c_doc_sub_type;

        END IF;

  EXCEPTION
        WHEN OTHERS THEN
             IF (SQLCODE <> -20001) THEN
                fnd_message.set_name ('SQLAP', 'AP_DEBUG');
                fnd_message.set_token('ERROR', SQLERRM);
                fnd_message.set_token('CALLING_SEQUENCE', l_curr_calling_sequence);
                fnd_message.set_token('PARAMETERS',
                                      ' p_taxation_country   = '||p_taxation_country  ||
                                      ' p_document_sub_type  = '||p_document_sub_type ||
                                      ' p_tax_related_inv_id = '||p_tax_related_inv_id);
                fnd_message.set_token('DEBUG_INFO',l_debug_info);
             END IF;
             app_exception.raise_exception;


  END get_header_tax_attr_desc;


/*=============================================================================
 |  PROCEDURE - get_taxable_line_attr_desc()
 |
 |  DESCRIPTION
 |    This procedure will return the descriptions of tax drivers on the taxable
 |    line.
 |
 |  PARAMETERS
 |    P_Taxation_Country        - Taxation Country
 |    P_Trx_Bus_Category        - Transaction Business Category
 |    P_Prd_Fisc_Class          - Product Fiscal Classification
 |    P_User_Fisc_Class         - User Defined Fiscal Classification
 |    P_Prim_Int_Use            - Primary Intended Use
 |    P_Product_Type            - Product Type
 |    P_Product_Category        - Product Category
 |    P_Inv_Item_Id             - Inventory Item Identifier
 |    P_Org_Id                  - Organization Identifier
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE get_taxable_line_attr_desc
                ( p_taxation_country            IN         VARCHAR2,
                  p_trx_bus_category            IN         VARCHAR2,
                  p_prd_fisc_class              IN         VARCHAR2,
                  p_user_fisc_class             IN         VARCHAR2,
                  p_prim_int_use                IN         VARCHAR2,
                  p_product_type                IN         VARCHAR2,
                  p_product_category            IN         VARCHAR2,
                  p_inv_item_id                 IN         NUMBER,
                  p_org_id                      IN         NUMBER,
                  p_trx_bus_category_desc       OUT NOCOPY VARCHAR2,
                  p_prd_fisc_class_desc         OUT NOCOPY VARCHAR2,
                  p_user_fisc_class_desc        OUT NOCOPY VARCHAR2,
                  p_prim_int_use_desc           OUT NOCOPY VARCHAR2,
                  p_product_type_desc           OUT NOCOPY VARCHAR2,
                  p_product_category_desc       OUT NOCOPY VARCHAR2,
                  p_calling_sequence            IN         VARCHAR2) IS

        CURSOR c_bus_cat (c_class_code VARCHAR2,
                          c_txn_ctry   VARCHAR2) IS
        SELECT classification_name
        FROM   zx_fc_business_categories_v
        WHERE  classification_code = c_class_code
        AND    (country_code       = c_txn_ctry OR
                country_code IS NULL);

        CURSOR c_fisc_class (c_class_code VARCHAR2,
                             c_txn_ctry   VARCHAR2) IS
        SELECT classification_name
        FROM   zx_fc_product_fiscal_v
        WHERE  classification_code = c_class_code
        AND    (country_code       = c_txn_ctry OR
                country_code IS NULL);

        CURSOR c_user_fisc_class (c_class_code VARCHAR2,
                                  c_txn_ctry   VARCHAR2) IS
        SELECT classification_name
        FROM   zx_fc_user_defined_v
        WHERE  classification_code = c_class_code
        AND    (country_code       = c_txn_ctry OR
                country_code IS NULL);

        CURSOR c_prim_int_use (c_class_code VARCHAR2,
                               c_txn_ctry   VARCHAR2) IS
        SELECT classification_name
        FROM   zx_fc_intended_use_v
        WHERE  classification_code = c_class_code
        AND    (country_code       = c_txn_ctry OR
                country_code IS NULL);

	CURSOR c_product_type (c_class_code  VARCHAR2) IS
        SELECT classification_name
        FROM   zx_product_types_v
	WHERE  classification_code = c_class_code;

        CURSOR c_product_category (c_class_code VARCHAR2,
                                   c_txn_ctry   VARCHAR2) IS
        SELECT classification_name
        FROM   zx_fc_product_categories_v
        WHERE  classification_code = c_class_code
        AND    (country_code       = c_txn_ctry OR
                country_code IS NULL);

        l_debug_info                 VARCHAR2(240);
        l_curr_calling_sequence      VARCHAR2(4000);
        l_api_name			  CONSTANT VARCHAR2(100) := 'get_taxable_line_attr_desc';

BEGIN

        l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Taxable_Line_Attr_Desc<-' ||
                                    p_calling_sequence;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
        END IF;

        ------------------------------------------------------------------
        l_debug_info := 'Step 1: Get Business Category';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------------------------
        IF p_trx_bus_category IS NOT NULL THEN

           OPEN  c_bus_cat (p_trx_bus_category,
                            p_taxation_country);
           FETCH c_bus_cat
           INTO  p_trx_bus_category_desc;
           CLOSE c_bus_cat;

        END IF;

        ------------------------------------------------------------------
        l_debug_info := 'Step 2: Get Fiscal Classification';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------------------------
        IF p_prd_fisc_class IS NOT NULL THEN

           OPEN  c_fisc_class (p_prd_fisc_class,
                               p_taxation_country);
           FETCH c_fisc_class
           INTO  p_prd_fisc_class_desc;
           CLOSE c_fisc_class;

        END IF;

        ------------------------------------------------------------------
        l_debug_info := 'Step 3: Get User Defined Fiscal Classification';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------------------------
        IF p_user_fisc_class IS NOT NULL THEN

           OPEN  c_user_fisc_class (p_user_fisc_class,
                                    p_taxation_country);
           FETCH c_user_fisc_class
           INTO  p_user_fisc_class_desc;
           CLOSE c_user_fisc_class;

        END IF;

        ------------------------------------------------------------------
        l_debug_info := 'Step 4: Get Primary Intended Use';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------------------------
        IF p_prim_int_use IS NOT NULL THEN

           OPEN  c_prim_int_use (p_prim_int_use,
                                 p_taxation_country);
           FETCH c_prim_int_use
           INTO  p_prim_int_use_desc;
           CLOSE c_prim_int_use;

        END IF;

        ------------------------------------------------------------------
        l_debug_info := 'Step 5: Get Product Type';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------------------------
        IF p_product_type IS NOT NULL THEN

	   OPEN  c_product_type (p_product_type);
           FETCH c_product_type
           INTO  p_product_type_desc;
           CLOSE c_product_type;

        END IF;

        ------------------------------------------------------------------
        l_debug_info := 'Step 5: Get Product Category';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------------------------
        IF p_product_category IS NOT NULL THEN

           OPEN  c_product_category (p_product_category,
                                     p_taxation_country);
           FETCH c_product_category
           INTO  p_product_category_desc;
           CLOSE c_product_category;

        END IF;

  EXCEPTION
        WHEN OTHERS THEN
             IF (SQLCODE <> -20001) THEN
                fnd_message.set_name ('SQLAP', 'AP_DEBUG');
                fnd_message.set_token('ERROR', SQLERRM);
                fnd_message.set_token('CALLING_SEQUENCE', l_curr_calling_sequence);
                fnd_message.set_token('PARAMETERS',
                                      ' p_taxation_country   = '||p_taxation_country  ||
                                      ' p_trx_bus_category   = '||p_trx_bus_category  ||
                                      ' p_prd_fisc_class     = '||p_prd_fisc_class    ||
                                      ' p_user_fisc_class    = '||p_user_fisc_class   ||
                                      ' p_prim_int_use       = '||p_prim_int_use      ||
                                      ' p_product_type       = '||p_product_type      ||
                                      ' p_product_category   = '||p_product_category  ||
                                      ' p_inv_item_id        = '||p_inv_item_id       ||
                                      ' p_org_id             = '||p_org_id            );

                fnd_message.set_token('DEBUG_INFO',l_debug_info);
             END IF;
             app_exception.raise_exception;

  END get_taxable_line_attr_desc;

/*=============================================================================
 |  PROCEDURE - get_tax_line_attr_desc()
 |
 |  DESCRIPTION
 |    This procedure will return the descriptions of tax related attributes
 |    on the tax line.
 |
 |  PARAMETERS
 |    P_Taxation_Country        - Taxation Country
 |    P_Tax_Regime_Code         - Tax Regime
 |    P_Tax                     - Tax
 |    P_Tax_Jurisdiction_Code   - Tax Jurisidiction
 |    P_Tax_Status_Code         - Tax Status
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE get_tax_line_attr_desc
                ( p_taxation_country            IN         VARCHAR2,
                  p_tax_regime_code             IN         VARCHAR2,
                  p_tax                         IN         VARCHAR2,
                  p_tax_jurisdiction_code       IN         VARCHAR2,
                  p_tax_status_code             IN         VARCHAR2,
                  p_tax_regime_code_desc        OUT NOCOPY VARCHAR2,
                  p_tax_desc                    OUT NOCOPY VARCHAR2,
                  p_tax_jurisdiction_desc       OUT NOCOPY VARCHAR2,
                  p_tax_status_code_desc        OUT NOCOPY VARCHAR2,
                  p_calling_sequence            IN         VARCHAR2) AS

        CURSOR c_tax_regime (c_tax_regime_code VARCHAR2,
                             c_txn_ctry        VARCHAR2) IS
        SELECT vl.tax_regime_name
        FROM   zx_regimes_vl vl
        WHERE  vl.country_code    = c_txn_ctry
        AND    vl.tax_regime_code = c_tax_regime_code;

        CURSOR c_tax (c_tax        VARCHAR2,
                      c_tax_regime VARCHAR2) IS
        SELECT tax_full_name
        FROM   zx_sco_taxes
        WHERE  tax_regime_code = c_tax_regime
        AND    tax             = c_tax;

        CURSOR c_tax_jurisdiction (c_tax              VARCHAR2,
                                   c_tax_regime       VARCHAR2,
                                   c_tax_jurisdiction VARCHAR2) IS
        SELECT tax_jurisdiction_name
          FROM zx_jurisdictions_vl
         WHERE tax_regime_code       = c_tax_regime
           AND tax                   = c_tax
           AND tax_jurisdiction_code = c_tax_jurisdiction;

        CURSOR c_tax_status (c_tax        VARCHAR2,
                             c_tax_regime VARCHAR2,
                             c_tax_status VARCHAR2) IS
        SELECT tax_status_name
        FROM   zx_sco_status
        WHERE  tax_regime_code  = c_tax_regime
        AND    tax              = c_tax
        AND    tax_status_code  = c_tax_status;

        l_debug_info                 VARCHAR2(240);
        l_curr_calling_sequence      VARCHAR2(4000);
        l_api_name			  CONSTANT VARCHAR2(100) := 'get_tax_line_attr_desc';

  BEGIN
        l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Taxable_Line_Attr_Desc<-' ||
                                    p_calling_sequence;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
        END IF;

        ------------------------------------------------
        l_debug_info := 'Step 1: Get Tax Regime';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------
        IF p_tax_regime_code IS NOT NULL THEN

           OPEN  c_tax_regime (p_tax_regime_code,
                               p_taxation_country);
           FETCH c_tax_regime
           INTO  p_tax_regime_code_desc;
           CLOSE c_tax_regime;

        END IF;

        ------------------------------------------------
        l_debug_info := 'Step 2: Get Tax';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------
        IF p_tax IS NOT NULL THEN

           OPEN  c_tax (p_tax,
                        p_tax_regime_code);
           FETCH c_tax
           INTO  p_tax_desc;
           CLOSE c_tax;

        END IF;

        ------------------------------------------------
        l_debug_info := 'Step 3: Get Tax Jurisdiction';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------
        IF p_tax_jurisdiction_code IS NOT NULL THEN

           OPEN  c_tax_jurisdiction (p_tax,
                                     p_tax_regime_code,
                                     p_tax_jurisdiction_code);
           FETCH c_tax_jurisdiction
           INTO  p_tax_jurisdiction_desc;
           CLOSE c_tax_jurisdiction;

        END IF;

        ------------------------------------------------
        l_debug_info := 'Step 4: Get Tax Status';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------
        IF p_tax_status_code IS NOT NULL THEN

           OPEN  c_tax_status (p_tax,
                               p_tax_regime_code,
                               p_tax_status_code);

           FETCH c_tax_status
           INTO  p_tax_status_code_desc;
           CLOSE c_tax_status;

        END IF;

  EXCEPTION
        WHEN OTHERS THEN
             IF (SQLCODE <> -20001) THEN
                fnd_message.set_name ('SQLAP', 'AP_DEBUG');
                fnd_message.set_token('ERROR', SQLERRM);
                fnd_message.set_token('CALLING_SEQUENCE', l_curr_calling_sequence);
                fnd_message.set_token('PARAMETERS',
                                      ' p_taxation_country      = '||p_taxation_country      ||
                                      ' p_tax_regime_code       = '||p_tax_regime_code       ||
                                      ' p_tax                   = '||p_tax                   ||
                                      ' p_tax_jurisdiction_code = '||p_tax_jurisdiction_code ||
                                      ' p_tax_status_code       = '||p_tax_status_code );

                fnd_message.set_token('DEBUG_INFO',l_debug_info);
             END IF;
             app_exception.raise_exception;

  END get_tax_line_attr_desc;

/*=============================================================================
 |  PROCEDURE - get_default_tax_det_attribs()
 |
 |  DESCRIPTION
 |    This procedure will return the default tax drivers based on the
 |    organization identifier.
 |
 |  PARAMETERS
 |    P_Org_Id          - Organization Id
 |    P_Legal_Entity_Id - Legal Entity Id
 |    P_Item_Id         - Inventory Item Id
 |    P_Doc_Type        - Document Type
 |    P_Trx_Date        - Transaction Date
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Action
 |    13-AUG-2004   Sanjay  Created
 *============================================================================*/
  PROCEDURE get_default_tax_det_attribs
                        (p_org_id               IN NUMBER,
                         p_legal_entity_id      IN NUMBER,
                         p_item_id              IN NUMBER,
                         p_doc_type             IN VARCHAR2,
                         p_trx_date             IN DATE,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         p_country_code         OUT NOCOPY VARCHAR2,
                         p_trx_biz_category     OUT NOCOPY VARCHAR2,
                         p_intended_use         OUT NOCOPY VARCHAR2,
                         p_prod_category        OUT NOCOPY VARCHAR2,
                         p_prod_fisc_class_code OUT NOCOPY VARCHAR2,
                         p_calling_sequence     IN  VARCHAR2) IS

        l_tax_effective_date    DATE;
        l_success               BOOLEAN;
        l_error_code            VARCHAR2(30);
        l_event_class_code      VARCHAR2(100);
	    l_product_type		ap_invoice_lines_all.product_type%type;

        l_debug_info            VARCHAR2(240);
        l_curr_calling_sequence VARCHAR2(4000);
        l_api_name			  CONSTANT VARCHAR2(100) := 'get_default_tax_det_attribs';

  BEGIN

        l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Default_Tax_Det_Attribs<-' ||
                                    p_calling_sequence;

        ------------------------------------------------
        l_debug_info := 'Step 1: Get Taxation Country';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        ------------------------------------------------
        xle_utilities_grp.get_fp_countrycode_ou (
                                p_api_version       => 1.0,
                                p_init_msg_list     => FND_API.G_FALSE,
                                p_commit            => FND_API.G_FALSE,
                                x_return_status     => x_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data,
                                p_operating_unit    => p_org_id,
                                x_country_code      => p_country_code);

        IF p_country_code IS NOT NULL THEN

        -------------------------------------------
        l_debug_info := 'Step 2: Get Event Class';
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;
        -------------------------------------------
           l_success := AP_ETAX_UTILITY_PKG.Get_Event_Class_Code (
                                p_invoice_type_lookup_code  => p_doc_type,
                                p_event_class_code          => l_event_class_code,
                                p_error_code                => l_error_code,
                                p_calling_sequence          => l_curr_calling_sequence);

           IF (l_success) THEN

                ----------------------------------------------------
                l_debug_info := 'Step 3: Set Tax Security Context';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;
                ----------------------------------------------------
                AP_ETAX_UTILITY_PKG.set_tax_security_context (
                                p_org_id                => p_org_id,
                                p_legal_entity_id       => p_legal_entity_id,
                                p_transaction_date      => NVL(p_trx_date, sysdate),
                                p_related_doc_date      => NULL,
                                p_adjusted_doc_date     => NULL,
                                p_effective_date        => l_tax_effective_date,
                                p_return_status         => x_return_status,
                                p_msg_count             => x_msg_count,
                                p_msg_data              => x_msg_data);

                ------------------------------------------------------------------
                l_debug_info := 'Step 4: Get Default Tax Determining Attributes';
                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
                END IF;
                ------------------------------------------------------------------
                zx_api_pub.get_default_tax_det_attribs (
                                p_api_version           => 1.0,
                                p_init_msg_list         => FND_API.G_FALSE,
                                p_commit                => FND_API.G_FALSE,
                                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data,
                                p_application_id        => 200,
                                p_entity_code           => 'AP_INVOICES',
                                p_event_class_code      => l_event_class_code,
                                p_org_id                => p_org_id,
                                p_item_id               => p_item_id,
                                p_country_code          => p_country_code,
                                p_effective_date        => l_tax_effective_date,
                                x_trx_biz_category      => p_trx_biz_category,
                                x_intended_use          => p_intended_use,
                                x_prod_category         => p_prod_category,
                                x_prod_fisc_class_code  => p_prod_fisc_class_code,
				x_product_type		=> l_product_type);

           END IF;

        END IF;

  EXCEPTION
        WHEN OTHERS THEN
             IF (SQLCODE <> -20001) THEN
                fnd_message.set_name ('SQLAP', 'AP_DEBUG');
                fnd_message.set_token('ERROR', SQLERRM);
                fnd_message.set_token('CALLING_SEQUENCE', l_curr_calling_sequence);
                fnd_message.set_token('PARAMETERS',
                                      ' p_org_id                = '||p_org_id           ||
                                      ' p_legal_entity_id       = '||p_legal_entity_id  ||
                                      ' p_item_id               = '||p_item_id          ||
                                      ' p_doc_type              = '||p_doc_type         ||
                                      ' p_trx_date              = '||p_trx_date );

                fnd_message.set_token('DEBUG_INFO',l_debug_info);
             END IF;
             app_exception.raise_exception;

  END get_default_tax_det_attribs;


PROCEDURE insert_tax_distributions(
				  p_invoice_header_rec       IN ap_invoices_all%ROWTYPE,
				  p_inv_dist_rec             IN r_ins_tax_dist_info,
				  p_dist_code_combination_id IN NUMBER,
				  p_user_id	             IN NUMBER,
				  p_sysdate	             IN DATE,
				  p_login_id	             IN	NUMBER,
				  p_calling_sequence         IN VARCHAR2) IS

 l_curr_calling_sequence VARCHAR2(2000);
 l_debug_info		 VARCHAR2(2000);
 l_api_name		 VARCHAR2(80);

  -- Bug 7126676
 l_awt_success   Varchar2(1000);
 l_invoice_distribution_id ap_invoice_distributions_all.invoice_distribution_id%TYPE;
BEGIN

     l_api_name := 'Insert_Tax_Distributions';

     l_curr_calling_sequence := 'Insert_Tax_Distributions <- '||p_calling_sequence;

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ETAX_UTILITY_PKG.Insert_Tax_Distributions(+)');
     END IF;

     l_debug_info := 'Step 11: Insert new distributions including variances';

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;

     -- bug 7126676
     select ap_invoice_distributions_s.NEXTVAL into l_invoice_distribution_id from dual;

     INSERT INTO ap_invoice_distributions_all (
            accounting_date,
            accrual_posted_flag,
            assets_addition_flag,
            assets_tracking_flag,
            cash_posted_flag,
            distribution_line_number,
            dist_code_combination_id,
            invoice_id,
            last_updated_by,
            last_update_date,
            line_type_lookup_code,
            period_name,
            set_of_books_id,
            amount,
            base_amount,
            batch_id,
            created_by,
            creation_date,
            description,
            final_match_flag,
            income_tax_region,
            last_update_login,
            match_status_flag,
            posted_flag,
            po_distribution_id,
            program_application_id,
            program_id,
            program_update_date,
            quantity_invoiced,
            request_id,
            reversal_flag,
            type_1099,
            unit_price,
            encumbered_flag,
            stat_amount,
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
            attribute_category,
            expenditure_item_date,
            expenditure_organization_id,
            expenditure_type,
            parent_invoice_id,
            pa_addition_flag,
            pa_quantity,
            prepay_amount_remaining,
            project_accounting_context,
            project_id,
            task_id,
            packet_id,
            awt_flag,
            awt_group_id,
            awt_tax_rate_id,
            awt_gross_amount,
            awt_invoice_id,
            awt_origin_group_id,
            reference_1,
            reference_2,
            org_id,
            awt_invoice_payment_id,
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
            expense_group,
            start_expense_date,
            end_expense_date,
            receipt_currency_code,
            receipt_conversion_rate,
            receipt_currency_amount,
            daily_amount,
            web_parameter_id,
            adjustment_reason,
            award_id,
            credit_card_trx_id,
            dist_match_type,
            rcv_transaction_id,
            invoice_distribution_id,
            parent_reversal_id,
            tax_recoverable_flag,
            merchant_document_number,
            merchant_name,
            merchant_reference,
            merchant_tax_reg_number,
            merchant_taxpayer_id,
            country_of_supply,
            matched_uom_lookup_code,
            gms_burdenable_raw_cost,
            accounting_event_id,
            prepay_distribution_id,
            upgrade_posted_amt,
            upgrade_base_posted_amt,
            inventory_transfer_status,
            company_prepaid_invoice_id,
            cc_reversal_flag,
            awt_withheld_amt,
            pa_cmt_xface_flag,
            cancellation_flag,
            invoice_line_number,
            corrected_invoice_dist_id,
            rounding_amt,
            charge_applicable_to_dist_id,
            corrected_quantity,
            related_id,
            asset_book_type_code,
            asset_category_id,
            distribution_class,
            tax_code_id,
            intended_use,
            detail_tax_dist_id,
            rec_nrec_rate,
            recovery_rate_id,
            recovery_rate_name,
            recovery_type_code,
            withholding_tax_code_id,
            taxable_amount,
            taxable_base_amount,
            tax_already_distributed_flag,
            summary_tax_line_id,
            extra_po_erv,
            prepay_tax_diff_amount,
			--Freight and Special Charges
			rcv_charge_addition_flag,
			pay_awt_group_id) --Bug8345264
      VALUES (
            p_inv_dist_rec.accounting_date,    -- accounting_date
            'N',                                  -- accrual_posted_flag
            'U',                                  -- assets_addition_flag
            'N',                                  -- assets_tracking_flag
            'N',                                  -- cash_posted_flag
            AP_INVOICE_LINES_PKG.get_max_dist_line_num(
              p_inv_dist_rec.invoice_id,
              p_inv_dist_rec.invoice_line_number)+1,
                                                  -- distribution_line_number
            P_dist_code_combination_id,           -- dist_code_combination_id
            p_inv_dist_rec.invoice_id,      	  -- invoice_id
            P_user_id,                            -- last_updated_by
            P_sysdate,                            -- last_update_date
            p_inv_dist_rec.line_type_lookup_code,
                                                  -- line_type_lookup_code
            p_inv_dist_rec.period_name,           -- period_name
            p_inv_dist_rec.set_of_books_id,	  -- set_of_books_id
            p_inv_dist_rec.amount,                -- amount
            decode(p_inv_dist_rec.base_amount,
                   0, decode(p_inv_dist_rec.amount, 0, p_inv_dist_rec.base_amount, NULL),
                   p_inv_dist_rec.base_amount),   -- base_amount
            p_inv_dist_rec.batch_id,        	  -- batch_id
            P_user_id,                            -- created_by
            P_sysdate,                            -- creation_date
            p_inv_dist_rec.description,        	  -- description
            NULL,                                 -- final_match_flag
            p_inv_dist_rec.income_tax_region,  -- income_tax_region
            P_login_id,                           -- last_update_login
            NULL,                                 -- match_status_flag
            'N',                                  -- posted_flag
            p_inv_dist_rec.po_distribution_id, -- po_distribution_id
            NULL,                                 -- program_application_id
            NULL,                                 -- program_id
            NULL,                                 -- program_update_date
            NULL,                                 -- quantity_invoiced
            NULL,                                 -- request_id
            'N',                                  -- reversal_flag
            p_inv_dist_rec.type_1099,          -- type_1099
            NULL,                                 -- unit_price
            'N',                                  -- encumbered_flag
            NULL,                                 -- stat_amount
            p_inv_dist_rec.attribute1,         -- attribute1
            p_inv_dist_rec.attribute10,        -- attribute10
            p_inv_dist_rec.attribute11,        -- attribute11,
            p_inv_dist_rec.attribute12,        -- attribute12
            p_inv_dist_rec.attribute13,        -- attribute13
            p_inv_dist_rec.attribute14,        -- attribute14
            p_inv_dist_rec.attribute15,        -- attribute15
            p_inv_dist_rec.attribute2,         -- attribute2
            p_inv_dist_rec.attribute3,         -- attribute3
            p_inv_dist_rec.attribute4,         -- attribute4
            p_inv_dist_rec.attribute5,         -- attribute5
            p_inv_dist_rec.attribute6,         -- attribute6
            p_inv_dist_rec.attribute7,         -- attribute7
            p_inv_dist_rec.attribute8,         -- attribute8
            p_inv_dist_rec.attribute9,         -- attribute9
            p_inv_dist_rec.attribute_category, -- attribute_category
            p_inv_dist_rec.expenditure_item_date,
                                                  -- expenditure_item_date
            p_inv_dist_rec.expenditure_organization_id,
                                                  -- expenditure_organization_id
            p_inv_dist_rec.expenditure_type,   -- expenditure_type
            p_inv_dist_rec.parent_invoice_id,  -- parent_invoice_id
            p_inv_dist_rec.pa_addition_flag,   -- pa_addition_flag
            p_inv_dist_rec.pa_quantity,        -- pa_quantity
            NULL,                                 -- prepay_amount_remaining
            -- the prepay_amount_remaining will be populated for all the
            -- prepayment distributions during the payment. And later will be
            -- updated during the prepayment applications
            p_inv_dist_rec.project_accounting_context,
                                                  -- project_accounting_context
            p_inv_dist_rec.project_id,         -- project_id
            p_inv_dist_rec.task_id,            -- task_id
            NULL,                                 -- packet_id
            'N',                                  -- awt_flag
            p_inv_dist_rec.awt_group_id,       -- awt_group_id
            NULL,                                 -- awt_tax_rate_id
            NULL,                                 -- awt_gross_amount
            NULL,                                 -- awt_invoice_id
            NULL,                                 -- awt_origin_group_id
            NULL,                                 -- reference_1
            NULL,                                 -- reference_2
            p_inv_dist_rec.org_id,		  -- org_id
            NULL,                                 -- awt_invoice_payment_id
            p_inv_dist_rec.global_attribute_category,
                                                  -- global_attribute_category
            p_inv_dist_rec.global_attribute1,  -- global_attribute1
            p_inv_dist_rec.global_attribute2,  -- global_attribute2
            p_inv_dist_rec.global_attribute3,  -- global_attribute3
            p_inv_dist_rec.global_attribute4,  -- global_attribute4
            p_inv_dist_rec.global_attribute5,  -- global_attribute5
            p_inv_dist_rec.global_attribute6,  -- global_attribute6
            p_inv_dist_rec.global_attribute7,  -- global_attribute7
            p_inv_dist_rec.global_attribute8,  -- global_attribute8
            p_inv_dist_rec.global_attribute9,  -- global_attribute9
            p_inv_dist_rec.global_attribute10, -- global_attribute10
            p_inv_dist_rec.global_attribute11, -- global_attribute11
            p_inv_dist_rec.global_attribute12, -- global_attribute12
            p_inv_dist_rec.global_attribute13, -- global_attribute13
            p_inv_dist_rec.global_attribute14, -- global_attribute14
            p_inv_dist_rec.global_attribute15, -- global_attribute15
            p_inv_dist_rec.global_attribute16, -- global_attribute16
            p_inv_dist_rec.global_attribute17, -- global_attribute17
            p_inv_dist_rec.global_attribute18, -- global_attribute18
            p_inv_dist_rec.global_attribute19, -- global_attribute19
            p_inv_dist_rec.global_attribute20, -- global_attribute20
            NULL,                                 -- receipt_verified_flag
            NULL,                                 -- receipt_required_flag
            NULL,                                 -- receipt_missing_flag
            NULL,                                 -- justification
            NULL,                                 -- expense_group
            NULL,                                 -- start_expense_date
            NULL,                                 -- end_expense_date
            NULL,                                 -- receipt_currency_code
            NULL,                                 -- receipt_conversion_rate
            NULL,                                 -- receipt_currency_amount
            NULL,                                 -- daily_amount
            NULL,                                 -- web_parameter_id
            NULL,                                 -- adjustment_reason
            p_inv_dist_rec.award_id,           -- award_id
            NULL,                                 -- credit_card_trx_id
            p_inv_dist_rec.dist_match_type,    -- dist_match_type
            p_inv_dist_rec.rcv_transaction_id, -- rcv_transaction_id
            l_invoice_distribution_id,         -- invoice_distribution_id
            NULL,                                 -- parent_reversal_id
            p_inv_dist_rec.tax_recoverable_flag,
                                                  -- tax_recoverable_flag
            NULL,                                 -- merchant_document_number
            NULL,                                 -- merchant_name
            NULL,                                 -- merchant_reference
            NULL,                                 -- merchant_tax_reg_number
            NULL,                                 -- merchant_taxpayer_id
            NULL,                                 -- country_of_supply
            NULL,                                 -- matched_uom_lookup_code
            NULL,                                 -- gms_burdenable_raw_cost
            NULL,                                 -- accounting_event_id
            p_inv_dist_rec.prepay_distribution_id,  -- prepay_distribution_id
            NULL,                                 -- upgrade_posted_amt
            NULL,                                 -- upgrade_base_posted_amt
            'N',                                  -- inventory_transfer_status
            NULL,                                 -- company_prepaid_invoice_id
            NULL,                                 -- cc_reversal_flag
            NULL,                                 -- awt_withheld_amt
            NULL,                                 -- pa_cmt_xface_flag
            p_inv_dist_rec.cancellation_flag,  -- cancellation_flag
            p_inv_dist_rec.invoice_line_number,-- invoice_line_number
            p_inv_dist_rec.corrected_invoice_dist_id,
                                                  -- corrected_invoice_dist_id
            p_inv_dist_rec.rounding_amt,       -- rounding_amt
            p_inv_dist_rec.charge_applicable_to_dist_id,
                                                 -- charge_applicable_to_dist_id
            NULL,                                 -- corrected_quantity
            NULL,                                 -- related_id
            NULL,                                 -- asset_book_type_code
            NULL,                                 -- asset_category_id
            p_inv_dist_rec.distribution_class, -- distribution_class
            p_inv_dist_rec.tax_code_id,        -- tax_code_id
            NULL,                                 -- intended_use,
            p_inv_dist_rec.detail_tax_dist_id, -- detail_tax_dist_id
            p_inv_dist_rec.rec_nrec_rate,      -- rec_nrec_rate
            p_inv_dist_rec.recovery_rate_id,   -- recovery_rate_id
            p_inv_dist_rec.recovery_rate_name, -- recovery_rate_name
            p_inv_dist_rec.recovery_type_code, -- recovery_type_code
            NULL,                                 -- withholding_tax_code_id,
            p_inv_dist_rec.taxable_amount,     -- taxable_amount
            p_inv_dist_rec.taxable_base_amount, -- taxable_base_amount
            NULL,                                -- tax_already_distributed_flag
            p_inv_dist_rec.summary_tax_line_id, -- summary_tax_line_id
            p_inv_dist_rec.extra_po_erv,        -- extra_po_erv
            p_inv_dist_rec.prepay_tax_diff_amount, -- prepay_tax_diff_amount
			'N',					      	-- rcv_charge_addition_flag
			p_inv_dist_rec.pay_awt_group_id		--pay_awt_group_id Bug8345264
			);

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,'AP_ETAX_UTILITY_PKG.Insert_Tax_Distributions(-)');
  END IF;

  -- Following code was introduce because of bug 7126676
  -- This code will generate withholding applicability for
  -- tax lines for JL Exteneded withholdings
  IF (AP_EXTENDED_WITHHOLDING_PKG.AP_EXTENDED_WITHHOLDING_ACTIVE) THEN

       l_debug_info := 'Call the Ap_Ext_Withholding_Default from match';
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
       END IF;

       Ap_Extended_Withholding_Pkg.Ap_Ext_Withholding_Default
                           (p_invoice_id       => p_inv_dist_rec.invoice_id,
                            p_inv_line_num     => p_inv_dist_rec.invoice_line_number,
                            p_inv_dist_id      => l_invoice_distribution_id,
                            p_calling_module   => l_curr_calling_sequence,
                            p_parent_dist_id   => NULL,
                            p_awt_success      => l_awt_success);

       IF (l_awt_success <> 'SUCCESS') THEN
           RAISE Global_Exception;
       END IF;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
         FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
         FND_MESSAGE.SET_TOKEN('PARAMETERS',
           ' P_Invoice_Id = '||P_Invoice_Header_Rec.invoice_id||
           ' P_Calling_Sequence = '||P_Calling_Sequence);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
       END IF;

        IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
         END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
END;


 -- Bug 4887847: Added function Get_Line_Class to populate a new attribute that
 --              is required for tax calculation and reporting purposes.

/*=============================================================================
 |  FUNCTION - Get_Line_Class()
 |
 |  DESCRIPTION
 |   This function will return the line class based on the invoice document type
 |    invoice line type and matching information.
 |
 *============================================================================*/

 FUNCTION Get_Line_Class(
         P_Invoice_Type_Lookup_Code    IN  VARCHAR2,
         P_Inv_Line_Type               IN  VARCHAR2,
         P_Line_Location_Id            IN  NUMBER,
         P_Line_Class                  OUT NOCOPY VARCHAR2,
         P_Error_Code                  OUT NOCOPY VARCHAR2,
         P_Calling_Sequence            IN  VARCHAR2) RETURN BOOLEAN
IS
  l_matching_basis    po_line_locations_ap_v.matching_basis%type;
  l_payment_type      po_line_locations_ap_v.payment_type%type;
  l_shipment_type     po_line_locations_ap_v.shipment_type%type;

  l_debug_info                 VARCHAR2(240);
  l_curr_calling_sequence      VARCHAR2(4000);
  l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Line_Class';

BEGIN

  l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Line_Class_Code<-' ||
                              P_calling_sequence;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
  END IF;

  IF (P_Invoice_Type_Lookup_Code IN ('STANDARD','MIXED','ADJUSTMENT',
			                         'PO PRICE ADJUST','INVOICE REQUEST')) THEN

      P_Line_Class := 'STANDARD INVOICES';

   ELSIF (P_Invoice_Type_Lookup_Code IN ('CREDIT', 'CREDIT MEMO REQUEST')) THEN

      P_Line_Class := 'AP_CREDIT_MEMO';

   ELSIF (P_Invoice_Type_Lookup_Code = 'DEBIT') THEN

      P_Line_Class := 'AP_DEBIT_MEMO';

   ELSIF (P_Invoice_Type_Lookup_Code IN ('PREPAYMENT')) THEN

      P_Line_Class := 'PREPAYMENT INVOICES';

   ELSIF (P_Invoice_Type_Lookup_Code IN ('EXPENSE REPORT')) THEN

      P_Line_Class := 'EXPENSE REPORTS';

   END IF;

   IF P_Inv_Line_Type  = 'PREPAY' THEN

      P_Line_Class := 'PREPAY_APPLICATION';

   END IF;

   IF P_Line_Location_Id IS NOT NULL THEN

      SELECT matching_basis, payment_type, shipment_type
        INTO l_matching_basis, l_payment_type, l_shipment_type
        FROM po_line_locations_all
       WHERE line_location_id = P_Line_Location_Id;

      IF l_matching_basis = 'AMOUNT' THEN

         P_Line_Class := 'AMOUNT_MATCHED';

      END IF;

      IF l_shipment_type = 'PREPAYMENT' THEN

         IF l_payment_type = 'ADVANCE' THEN

             P_Line_Class := 'ADVANCE';

         ELSIF l_payment_type IN ('MILESTONE', 'RATE', 'LUMPSUM') THEN

             P_Line_Class := 'FINANCING';

         END IF;
      END IF;

   END IF;

   l_debug_info := 'Line Class '||P_Line_Class;

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF;

   RETURN (TRUE);

 EXCEPTION
   WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
            ' P_Invoice_Type_Lookup_Code = '||P_Invoice_Type_Lookup_Code||
            ' P_Error_Code = '||P_Error_Code||
            ' P_Calling_Sequence = '||P_Calling_Sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
   END IF;

   APP_EXCEPTION.RAISE_EXCEPTION;

END Get_Line_Class;

  FUNCTION Is_Tax_Already_Dist_Inv_Char(
             P_Invoice_Id                IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN VARCHAR2
  IS

    l_debug_info                        VARCHAR2(240);
    l_curr_calling_sequence             VARCHAR2(4000);
    l_tax_already_distributed_flag       VARCHAR2(1) := 'N';
    l_api_name			  CONSTANT VARCHAR2(100) := 'Is_Tax_Already_Dist_Inv_Char';

    -- Modified this select to include the TAX only case
    CURSOR etax_already_distributed IS
    SELECT 'Y'
      FROM ap_invoice_distributions_all
     WHERE invoice_id = p_invoice_id
       AND line_type_lookup_code <> 'AWT'
       AND (tax_already_distributed_flag = 'Y'
            OR detail_tax_dist_id IS NOT NULL)
       AND (related_id IS NULL
            OR related_id = invoice_distribution_id)
       AND ROWNUM = 1;

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Is_Tax_Already_Dist_Inv<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get tax_already_Distributed_flag for any '||
                    'taxable line in the invoice';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    OPEN etax_already_distributed;
    FETCH etax_already_distributed INTO l_tax_already_distributed_flag;
    IF (etax_already_distributed%NOTFOUND) THEN
      CLOSE etax_already_distributed;
      l_tax_already_distributed_flag := 'N';

    END IF;

    IF (etax_already_distributed%ISOPEN ) THEN
      CLOSE etax_already_distributed;
    END IF;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1.1: Tax_already_Distributed_flag '||l_tax_already_distributed_flag;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    RETURN l_tax_already_distributed_flag;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Invoice_Id = '||P_Invoice_Id||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF (etax_already_distributed%ISOPEN ) THEN
        CLOSE etax_already_distributed;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;

  END Is_Tax_Already_Dist_Inv_Char;

FUNCTION Get_Converted_Price (x_invoice_distribution_id IN NUMBER)
                RETURN NUMBER
IS
        CURSOR c_rct_info (c_inv_dist_id NUMBER) IS
         SELECT  D.unit_price                 unit_price,
                 pll.matching_basis           match_basis,
                 pll.match_option             match_option,
                 pl.unit_meas_lookup_code     po_uom,
                 D.matched_uom_lookup_code    rcv_uom,
                 rsl.item_id                  rcv_item_id
          FROM   ap_invoice_distributions_all D,
                 po_distributions_all         PD,
                 po_lines_all                 PL,
                 po_line_locations_all        PLL,
                 rcv_transactions             RTXN,
                 rcv_shipment_lines           RSL
          WHERE  D.invoice_distribution_id = c_inv_dist_id
            AND  D.po_distribution_id      = PD.po_distribution_id
            AND  PL.po_header_id           = PD.po_header_id
            AND  PL.po_line_id             = PD.po_line_id
            AND  PD.line_location_id       = PLL.line_location_id
            AND  D.rcv_transaction_id      = RTXN.transaction_id
            AND  RTXN.shipment_line_id     = RSL.shipment_line_id;

        l_match_basis   po_line_types.matching_basis%TYPE;
        l_match_option  po_line_locations.match_option%TYPE;
        l_po_uom        po_line_locations.unit_meas_lookup_code%TYPE;
        l_rct_uom       po_line_locations.unit_meas_lookup_code%TYPE;
        l_rct_item_id   rcv_shipment_lines.item_id%TYPE;
        l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Converted_Price';
        l_debug_info                 VARCHAR2(240);

        l_uom_conv_rate NUMBER;
        l_inv_price     NUMBER;
Begin

     OPEN  c_rct_info (x_invoice_distribution_id);
     FETCH c_rct_info
     INTO  l_inv_price, l_match_basis, l_match_option, l_po_uom, l_rct_uom, l_rct_item_id;
     CLOSE c_rct_info;

     IF l_match_basis  = 'QUANTITY'  and
        l_match_option = 'R'         and
        l_po_uom       <> l_rct_uom THEN

        l_uom_conv_rate := po_uom_s.po_uom_convert (
                             l_rct_uom,
                             l_po_uom,
                             l_rct_item_id);


        l_debug_info := 'Step 1 : Get Coverted Price '||
                        ' l_uom_conv_rate '||l_uom_conv_rate||
                        ' l_inv_price '||l_inv_price;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;

        l_inv_price := l_inv_price / l_uom_conv_rate;

        l_debug_info := 'Step 1.1 :  Coverted Price '||
                        ' l_inv_price '||l_inv_price;

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
        END IF;


     END IF;

     RETURN l_inv_price;

EXCEPTION
     WHEN OTHERS THEN
          NULL;
END Get_Converted_Price;

  FUNCTION Get_Max_Dist_Num_Self(
              X_invoice_id          IN      NUMBER,
              X_line_number         IN      NUMBER) RETURN NUMBER
  IS
    l_max_dist_line_num NUMBER := 0;
  BEGIN

    SELECT nvl(max(distribution_line_number),0)
      INTO l_max_dist_line_num
      FROM ap_self_assessed_tax_dist_all
     WHERE invoice_id = X_invoice_id
       AND invoice_line_number = X_line_number;

    RETURN(l_max_dist_line_num);

  END Get_Max_Dist_Num_Self;

 /*=============================================================================
 |  FUNCTION - Get_Prepay_Pay_Awt_Group_Id()
 |
 |  DESCRIPTION
 |      This function return the pay_awt_group_id for a parent prepay item line
 |      based on the prepayment distribution id.
 |		Added for bug8345264
 |
 |  PARAMETERS
 |      P_Prepay_Distribution_id - Distribution Id of the prepayment
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    30-MAR-2009   ASANSARI       Created
 |
 *============================================================================*/
  FUNCTION Get_Prepay_Pay_Awt_Group_Id(
             P_Prepay_Distribution_id    IN NUMBER,
             P_Calling_Sequence          IN VARCHAR2) RETURN NUMBER
  IS

    l_debug_info                 VARCHAR2(240);
    l_curr_calling_sequence      VARCHAR2(4000);
    l_api_name			  CONSTANT VARCHAR2(100) := 'Get_Prepay_Pay_Awt_Group_Id';

    CURSOR prepay_pay_awt_group_id (c_prepay_dist_id IN NUMBER) IS
    SELECT aid.pay_awt_group_id
      FROM ap_invoice_distributions_all aid
     WHERE aid.invoice_distribution_id = c_prepay_dist_id;

    l_pay_awt_group_id     ap_invoice_distributions_all.pay_awt_group_id%TYPE;

  BEGIN

    l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Get_Prepay_Pay_Awt_Group_Id<-'||
                               P_calling_sequence;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
    END IF;

    -------------------------------------------------------------------
    l_debug_info := 'Step 1: Get awt_group_id from prepay item line';

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------
    OPEN  prepay_pay_awt_group_id( P_Prepay_Distribution_id);
    FETCH prepay_pay_awt_group_id
    INTO  l_pay_awt_group_id;
    CLOSE prepay_pay_awt_group_id;

     -------------------------------------------------------------------
    l_debug_info := 'Awt_group_id from prepay item line '||l_pay_awt_group_id;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    -------------------------------------------------------------------

    RETURN l_pay_awt_group_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' P_Prepay_Distribution_id = '||P_Prepay_Distribution_id||
          ' P_Calling_Sequence = '||P_Calling_Sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      END IF;

      IF ( prepay_pay_awt_group_id%ISOPEN ) THEN
        CLOSE prepay_pay_awt_group_id;
      END IF;

      APP_EXCEPTION.RAISE_EXCEPTION;
  END Get_Prepay_Pay_Awt_Group_Id;

  /*=============================================================================
 |  FUNCTION - Is_Inclusive_Flag_Updatable()
 |
 |  DESCRIPTION
 |      This function is called by Ebtax to make the Inclusive Check Box
 |      on Detail Tax Window editable based on return status by this
 |		function.Added for ER 6772098
 |      RETURN TRUE   : Allow To Override Inclusive Checkbox
 |      RETURN FALUSE : Don't Allow To Override Inclusive Checkbox
 |
 |
 |  PARAMETERS
 |      p_invoice_id  - Invoice Id of the Invoice open on workbench
 |      p_line_number - Invoice Line Number of Non Tax Line for which
 |                      Detail Tax line is being overriden
 |                      (Inclusive Check Box)
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    31-JUL-2009   hchaudha        Created
 |
 *============================================================================*/

  FUNCTION Is_Inclusive_Flag_Updatable(
           p_invoice_id       IN NUMBER,
           p_line_number      IN NUMBER,
           p_error_code       IN OUT NOCOPY VARCHAR2,
           p_calling_sequence IN VARCHAR2)
  RETURN BOOLEAN IS
           l_Posted_count        NUMBER :=0;
           l_Encumbered_count    NUMBER :=0;
           l_Prepay_line_count   NUMBER :=0;
           l_Prepay_dist_count   NUMBER :=0;
           l_Payment_Stat_Flag   NUMBER :=0;
           l_Hist_Flag           VARCHAR2(1);
           l_Awt_Computed        VARCHAR2(1);
           l_quick_credit        VARCHAR2(1);
           l_Awt_line_count      NUMBER :=0;
           l_manual_Awt_line     NUMBER :=0; --Bug8920386
           l_Invoice_Type        VARCHAR2(20);
           l_Po_Dist_id_count    NUMBER :=0;
           l_Po_line_num_count   NUMBER :=0;
           l_corr_inv_count      NUMBER :=0;
           l_curr_calling_sequence VARCHAR2(4000);
           l_debug_info            VARCHAR2(4000);
           l_api_name     CONSTANT VARCHAR2(100):='IS_INCLUSIVE_FLAG_UPDATABLE';
  BEGIN

  l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Is_Inclusive_Flag_Updatable<-'||
                               P_calling_sequence;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
  END IF;
  -------------------------------------------------------------------
  l_debug_info := 'Step 0: Invoice Id and Invoice Line Number '||p_invoice_id||' '||p_line_number;
  -------------------------------------------------------------------
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  --1 Posted Dist
  -------------------------------------------------------------------
  l_debug_info := 'Step 1: Check Posted Distributions Count ';
  -------------------------------------------------------------------
  SELECT COUNT(posted_flag)
    INTO l_Posted_count
    FROM ap_invoice_distributions_all
   WHERE invoice_id = p_invoice_id
     AND invoice_line_number = p_line_number
     AND NVL(posted_flag,'N') = 'Y';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Posted_count);
  END IF;

  IF l_Posted_count > 0 THEN
     RETURN FALSE;
  END IF;

  --2 Prepayment Applied
  -------------------------------------------------------------------
  l_debug_info := 'Step 2: Check Prepayment Applied ';
  -------------------------------------------------------------------
  SELECT count(line_number)
    INTO l_Prepay_line_count
    FROM ap_invoice_lines_all
   WHERE invoice_id = p_invoice_id
     AND line_type_lookup_code ='PREPAY'
     AND (NVL(discarded_flag,'N') <> 'Y');

  IF l_Prepay_line_count = 0 THEN
   SELECT count(prepay_distribution_id)
     INTO l_Prepay_dist_count
     FROM ap_invoice_distributions_all
    WHERE invoice_id = p_invoice_id
      AND prepay_distribution_id IS NOT NULL
      AND (NVL(reversal_flag,'N') <> 'Y');
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Prepay_line_count||' '||l_Prepay_dist_count);
  END IF;

  IF l_Prepay_line_count > 0 OR l_Prepay_dist_count > 0 THEN
     RETURN FALSE;
  END IF;



  --3,4,5,6,7 Paid/Upgraded/AWT Calculated/Quick Credit/Expense Report/
  --Applied Credit and Debit Memo
  ----------------------------------------------------------------------------
  l_debug_info := 'Step 3-7: Check Paid/Upgraded/AWT Calculated/Quick Credit/';
  l_debug_info := l_debug_info||' Expense Report/ Applied Credit and';
  l_debug_info := l_debug_info||' Debit Memo';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  ----------------------------------------------------------------------------
  SELECT Historical_flag,
         Awt_Flag,
         quick_credit,
         Invoice_type_lookup_code
    INTO l_Hist_Flag,
         l_Awt_Computed,
         l_quick_credit,
         l_Invoice_Type
    FROM ap_invoices_all
   WHERE invoice_id = p_invoice_id;

  SELECT count(invoice_id)
    INTO l_Payment_Stat_Flag
    FROM ap_invoice_payments_all
   WHERE invoice_id =  p_invoice_id
     AND NVL(reversal_flag,'N') <> 'Y';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_debug_info :='Step 3 : Check Payment Status ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Payment_Stat_Flag);
     l_debug_info :='Step 4 : Check Upgraded Status ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Hist_Flag);
     l_debug_info :='Step 5 : Check AWT Computed ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Awt_Computed);
     l_debug_info :='Step 6 : Check Quick Credit Invoice ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_quick_credit);
     l_debug_info :='Step 7 : Check Invoice Type ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Invoice_Type);
  END IF;

  IF l_Payment_Stat_Flag > 0  OR
     NVL(l_Hist_Flag,'N') = 'Y' OR
     --NVL(l_Awt_Computed,'N') = 'Y' OR
     NVL(l_quick_credit,'N') ='Y' OR
     NVL(l_Invoice_Type,'A') = 'EXPENSE REPORT' THEN
     RETURN FALSE;
  END IF;

  IF NVL(l_Invoice_Type,'A') IN ('DEBIT','CREDIT') THEN
     SELECT COUNT(CORRECTED_INV_ID)
       INTO l_corr_inv_count
       FROM ap_invoice_lines_all
      WHERE invoice_id = p_invoice_id
        AND CORRECTED_INV_ID IS NOT NULL
        AND (NVL(discarded_flag,'N') <> 'Y');

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_debug_info :='Step 6.1 : Check Applied Debit/Credit Memo Count ';
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_corr_inv_count);
     END IF;

     IF l_corr_inv_count > 0 THEN
        RETURN FALSE;
     END IF;

  END IF;

  --Step 5.1 : Better Way To Check AWT Computation
  --Bug8920386

  SELECT count(line_number)
    INTO l_manual_Awt_line
    FROM ap_invoice_lines_all ail
   WHERE invoice_id = p_invoice_id
     AND line_type_lookup_code ='AWT'
     AND (NVL(discarded_flag,'N') <> 'Y')
     AND line_source = 'MANUAL LINE ENTRY'
     AND NOT EXISTS (SELECT 1
                       FROM ap_invoice_distributions_all aid
                      WHERE ail.invoice_id  = aid.invoice_id
                        AND ail.line_number = aid.invoice_line_number);
  SELECT COUNT(1)
    INTO l_Awt_line_count
    FROM ap_invoice_distributions_all aid
   WHERE aid.invoice_id = p_invoice_id
     AND NVL(aid.reversal_flag,'N') <> 'Y'
     AND aid.line_type_lookup_code = 'AWT'
     AND aid.awt_related_id IN
        (SELECT aid1.invoice_distribution_id
           FROM ap_invoice_distributions_all aid1
          WHERE aid1.invoice_id = aid.invoice_id
            AND aid1.invoice_line_number = p_line_number
            AND aid1.line_type_lookup_code <> 'AWT');


  l_debug_info :='Step 5.1 : Check Non Discarded AWT lines, Non Prorated Manual AWT Lines ';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Awt_line_count ||' '||l_manual_Awt_line );
  END IF;

  IF l_Awt_line_count > 0 OR l_manual_Awt_line > 0 THEN
   RETURN FALSE;
  END IF;

  --Bug8920386


  --8 Encumbered Dist
  -------------------------------------------------------------------
  l_debug_info := 'Step 7: Check Encumbered Distributions Count ';
  -------------------------------------------------------------------
  SELECT COUNT(1)
    INTO l_Encumbered_count
    FROM ap_invoice_distributions_all
   WHERE invoice_id = p_invoice_id
     AND invoice_line_number = p_line_number
     AND NVL(encumbered_flag,'N') = 'Y';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Encumbered_count);
  END IF;

  IF l_Encumbered_count > 0 THEN
     RETURN FALSE;
  END IF;

  --9 PO Matched Dist
  -------------------------------------------------------------------
  l_debug_info := 'Step 8: Check PO Matched Distributions Count ';
  -------------------------------------------------------------------
  SELECT COUNT(po_distribution_id)
    INTO l_Po_Dist_id_count
    FROM ap_invoice_distributions_all
   WHERE invoice_id = p_invoice_id
     AND invoice_line_number = p_line_number
     AND po_distribution_id IS NOT NULL;

  IF  l_Po_Dist_id_count = 0 THEN
    SELECT COUNT(po_header_id)
      INTO l_Po_line_num_count
      FROM ap_invoice_lines_all
     WHERE invoice_id = p_invoice_id
       AND line_number = p_line_number
       AND po_header_id IS NOT NULL;
  END IF;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_Po_Dist_id_count);
  END IF;

   IF l_Po_Dist_id_count > 0 OR l_Po_line_num_count > 0 THEN
      RETURN FALSE;
   END IF;

   RETURN TRUE;
   EXCEPTION
   WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS',
          ' p_invoice_id = '||p_invoice_id||
          ' p_line_number = '||p_line_number);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        p_error_code:=SQLCODE;
        RETURN FALSE;
      END IF;
   END;

/*=============================================================================
 |  FUNCTION - Is_Incl_Tax_Driver_Updatable()
 |
 |  DESCRIPTION
 |      Called from : AP_ETAX_SERVICES_PKG.Populate_Lines_GT()
 |                    APINLIN.pld
 |                    APXINWKB.fmb
 |      RETURN TRUE   : Allow To Override Tax drivers
 |      RETURN FALUSE : Don't Allow To Override Tax drivers
 |
 |
 |  PARAMETERS
 |      p_invoice_id  - Invoice Id of the Invoice
 |      p_line_number - Invoice Line Number
 |
 |  MODIFICATION HISTORY
 |    DATE          Author  Bug      Action
 |    02-Feb-2010   ANARUN  9068689  Created
 |
 ============================================================================*/

FUNCTION Is_Incl_Tax_Driver_Updatable(
         p_invoice_id       IN NUMBER,
         p_line_number      IN NUMBER,
         p_calling_sequence IN VARCHAR2   )
RETURN BOOLEAN IS
         l_allow_update          NUMBER ;
         l_curr_calling_sequence VARCHAR2(4000);
         l_debug_info            VARCHAR2(4000);
         l_api_name              CONSTANT VARCHAR2(100):='Is_Inclusive_Tax_Driver_Updatable';
BEGIN

  l_curr_calling_sequence := 'AP_ETAX_UTILITY_PKG.Is_Incl_Tax_Driver_Updatable<-'||
                               P_calling_sequence;


  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_curr_calling_sequence);
  END IF;
  -------------------------------------------------------------------
  l_debug_info := 'Step 0: Invoice Id and Invoice Line Number '||p_invoice_id||' '||p_line_number;
  -------------------------------------------------------------------
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  -------------------------------------------------------------------------------
  l_debug_info := 'Step 1: Check if Posted or Encumbered Distributions exist : ';
  -------------------------------------------------------------------------------
  -- Bug 9499176 : Replaced 1 SQL having NVL with 2 SQLs and added extra conditions
  IF p_line_number is NOT NULL THEN
     SELECT COUNT('INCLUSIVE TAX CALC ON POSTED DISTS')
       INTO l_allow_update
       FROM zx_rec_nrec_dist ZD
      WHERE ZD.application_id     = 200
        AND ZD.entity_code        = 'AP_INVOICES'
        AND ZD.event_class_code  IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
        AND ZD.trx_id             = p_invoice_id
        AND ZD.inclusive_flag     = 'Y'
        AND ZD.rec_nrec_tax_dist_id IN
            ( SELECT AID.detail_tax_dist_id
                FROM ap_invoice_distributions AID
               WHERE AID.invoice_id             = p_invoice_id
                 AND AID.invoice_line_number    = p_line_number
                 AND AID.line_type_lookup_code IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV')
		 AND AID.detail_tax_dist_id    IS NOT NULL
                 AND EXISTS ( SELECT 'LINE HAS ANY POSTED DIST'
                                FROM ap_invoice_distributions AID1
                               WHERE AID1.invoice_id               = AID.invoice_id
                                 AND AID1.invoice_line_number      = AID.invoice_line_number
                                 AND AID1.line_type_lookup_code   <> AID.line_type_lookup_code
                                 AND AID1.invoice_distribution_id  = AID.charge_applicable_to_dist_id
                                 AND ( AID1.posted_flag = 'Y' OR
				       NVL( AID1.encumbered_flag, 'N' ) IN ('Y', 'D', 'W', 'X')
				     )
		            )
	    )
	AND ROWNUM = 1 ;
  ELSE
     SELECT COUNT('INCLUSIVE TAX CALC ON POSTED DISTS')
       INTO l_allow_update
       FROM zx_rec_nrec_dist ZD
      WHERE ZD.application_id     = 200
        AND ZD.entity_code        = 'AP_INVOICES'
        AND ZD.event_class_code  IN ('STANDARD INVOICES', 'PREPAYMENT INVOICES', 'EXPENSE REPORTS')
        AND ZD.trx_id             = p_invoice_id
        AND ZD.inclusive_flag     = 'Y'
        AND ZD.rec_nrec_tax_dist_id IN
            ( SELECT AID.detail_tax_dist_id
                FROM ap_invoice_distributions AID
               WHERE AID.invoice_id             = p_invoice_id
                 AND AID.line_type_lookup_code IN ('REC_TAX','NONREC_TAX','TRV','TERV','TIPV')
		 AND AID.detail_tax_dist_id    IS NOT NULL
                 AND EXISTS ( SELECT 'LINE HAS ANY POSTED DIST'
                                FROM ap_invoice_distributions AID1
                               WHERE AID1.invoice_id               = AID.invoice_id
                                 AND AID1.invoice_line_number      = AID.invoice_line_number
                                 AND AID1.line_type_lookup_code   <> AID.line_type_lookup_code
                                 AND AID1.invoice_distribution_id  = AID.charge_applicable_to_dist_id
                                 AND ( AID1.posted_flag = 'Y' OR
				       NVL( AID1.encumbered_flag, 'N' ) IN ('Y', 'D', 'W', 'X')
				     )
			    )
	    )
	AND ROWNUM = 1 ;
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,l_debug_info||l_allow_update);
  END IF;

  IF l_allow_update > 0 THEN
     RETURN FALSE ;
  END IF ;

  RETURN TRUE ;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',l_curr_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                             ' p_invoice_id = '||p_invoice_id||
                             ' p_line_number = '||p_line_number);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
       RETURN FALSE;
    END IF;
END Is_Incl_Tax_Driver_Updatable ;

END AP_ETAX_UTILITY_PKG;

/
