--------------------------------------------------------
--  DDL for Package Body AP_PAYMENT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PAYMENT_UTIL_PKG" AS
/* $Header: appayutb.pls 120.25.12010000.7 2010/07/07 20:48:46 bgoyal ship $ */

  G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_PMT_CALLOUT_PKG';
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
  G_MODULE_NAME           CONSTANT VARCHAR2(30) := 'AP.PLSQL.AP_PAYMENT_UTIL_PKG.';
/*===========================================================================
 |  FUNCTION    - get_le_name
 |  DESCRIPTION - Utility to get Legal Entity Name for transactions which store
 |                legal_entity_id
 *==========================================================================*/
FUNCTION get_le_name( p_legal_entity_id   IN NUMBER)

RETURN  VARCHAR2    IS

   l_le_name   xle_entity_profiles.name%TYPE;

BEGIN

    SELECT NAME
      INTO l_le_name
      FROM xle_entity_profiles
     WHERE legal_entity_id =  p_legal_entity_id;

    RETURN l_le_name;

END;


/*===========================================================================
 |  FUNCTION     - get_ou_name
 |  DESCRIPTION  - Utility to get the Operating Unit name for a given org_id
 |                 This API should be replaced by
 |                 fnd_access_control_util.get_org_name(AI.org_id)
 *==========================================================================*/
FUNCTION Get_OU_NAME( p_org_id   IN NUMBER)
RETURN  VARCHAR2    IS

  l_ou_name   hr_all_organization_units.name%TYPE;

BEGIN
    SELECT name
      INTO l_ou_name
      FROM hr_all_organization_units
     WHERE organization_id =  p_org_id;

    RETURN l_ou_name;

END;

/*===========================================================================
 |  FUNCTION     - Get_iby_payer_defaults
 |  DESCRIPTION  - Defaults the following IBY defaults(org_id is NULL)
 |                 1. Document Rejection Level
 |                 2. Payment Rejection Level
 |                 3. Whether to Stop Procees for Review After Proposed
 |                    payments creation
 *==========================================================================*/
PROCEDURE Get_iby_payer_defaults(
                p_doc_rejection_level_code      OUT NOCOPY VARCHAR2,
                p_payment_rejection_level_code  OUT NOCOPY VARCHAR2,
                p_payments_review_settings      OUT NOCOPY VARCHAR2)
IS

BEGIN

    SELECT document_rejection_level_code,
           payment_rejection_level_code,
           require_prop_pmts_review_flag
      INTO p_doc_rejection_level_code,
           p_payment_rejection_level_code,
           p_payments_review_settings
      FROM iby_internal_payers_all
     WHERE org_id IS NULL;

EXCEPTION
 WHEN NO_DATA_FOUND
  THEN NULL;

END ;

/*===========================================================================
 |  FUNCTION    - get_pi_count
 |  DESCRIPTION - This is the number of payment instructions created for all
 |                payments belonging to the PPR.  This appears only after at
 |                least one exists.
 |
 *==========================================================================*/
FUNCTION get_pi_count(p_psr_id            IN  NUMBER)
RETURN NUMBER IS

l_ps_count  NUMBER;

BEGIN

   IF ( p_psr_id  IS NOT NULL ) THEN

    SELECT COUNT(DISTINCT payment_instruction_id)
      INTO l_ps_count
      FROM iby_fd_paymentS_v
     WHERE payment_instruction_id is NOT NULL
       AND payment_service_request_id = p_psr_id;

    END IF;
    IF l_ps_count = 0 THEN
       l_ps_count := NULL;
    END IF;

    RETURN l_ps_count;

END;

/*===========================================================================
 |  FUNCTION    - get_selected_ps_count
 |  DESCRIPTION - Gets the count of selected scheduled payments for the
 |                Payment Batch(Pay Run)
 |
 *==========================================================================*/
FUNCTION get_selected_ps_count(p_checkrun_id   IN  NUMBER,
                               p_psr_id        IN  NUMBER)
RETURN NUMBER IS

l_count1             NUMBER;
l_count2             NUMBER;
l_selected_ps_count  NUMBER;

BEGIN
   l_selected_ps_count := 0;

	SELECT count(*)
	  INTO l_count1
	  FROM ap_selected_invoices_All
	 WHERE checkrun_id = p_checkrun_id
	   AND original_invoice_id is NULL
	   AND original_payment_num is NULL
	   AND ok_to_pay_flag = 'Y';
    --
      SELECT count(*)
        INTO l_count2
        FROM ap_invoice_payments_all aip,
             ap_checks_all ac
       WHERE aip.check_id = ac.check_id
         AND ac.checkrun_id = p_checkrun_id;

    --
    l_selected_ps_count := l_count1 + l_count2;
    --

RETURN l_selected_ps_count;

END;


/*===========================================================================
 |  FUNCTION    - get_unsel_ps_count
 |  DESCRIPTION - Gets the count of un-selected scheduled payments for the
 |                Payment Batch(Pay Run)
 |
 *==========================================================================*/
FUNCTION Get_unsel_ps_Count(p_checkrun_id   IN  NUMBER)
RETURN NUMBER  IS

l_unsel_ps_count  NUMBER;

BEGIN

    SELECT count(*)
      INTO  l_unsel_ps_count
      FROM ap_unselected_invoices_All
     WHERE checkrun_id = p_checkrun_id;
    RETURN l_unsel_ps_count;

END;


/*=============================================================================
 |  FUNCTION    - Get_Rejected_ps_Count
 |  DESCRIPTION - This is the total count of scheduled payments that Oracle
 |                Payments(IBY) has rejected.
 |
 *============================================================================*/
FUNCTION Get_Rejected_ps_Count(p_psr_id                   IN  NUMBER)
RETURN NUMBER IS

l_rejected_ps_count  NUMBER;

BEGIN

    IF ( p_psr_id  IS NOT NULL ) THEN

	    SELECT count(*)
	     INTO l_rejected_ps_count
	     FROM IBY_DOCS_PAYABLE_ALL
	    WHERE payment_service_request_id = p_psr_id
	      AND rejected_docs_group_id is NOT NULL;

    END IF;

    IF l_rejected_ps_count = 0 THEN
        l_rejected_ps_count := NULL;
    END IF;

    RETURN l_rejected_ps_count;

END;

/*===========================================================================
 |  FUNCTION    - get_unsel_reason_count
 |  DESCRIPTION - This is the count of payment schedules that met the criteria
 |                but were not selected  for a particular dont_pay_reason_code
 |
 *==========================================================================*/
FUNCTION get_unsel_reason_count(
             p_checkrun_id      IN           NUMBER,
             p_dont_pay_code    IN           VARCHAR2)
RETURN NUMBER IS

l_count             NUMBER;
BEGIN
   IF p_dont_pay_code = 'OTHERS' THEN
	    SELECT count(*)
	     INTO l_count
	     FROM ap_unselected_invoices_all
	    WHERE checkrun_id = p_checkrun_id
	      AND dont_pay_reason_code NOT IN ('NEEDS_INVOICE_VALIDATION',
	                                       'FAILED_INVOICE_VALIDATION',
	                                       'ZERO INVOICE',
	                                       'NEEDS_APPROVAL',
	                                       'APPROVER_REJECTED',
	                                       'USER REMOVED',
	                                       'SCHEDULED_PAYMENT_HOLD',
	                                       'SUPPLIER_SITE_HOLD',
	                                       'DISCOUNT_RATE_TOO_LOW');
    ELSE

	   SELECT count(*)
	     INTO l_count
	     FROM ap_unselected_invoices_all
	    WHERE checkrun_id = p_checkrun_id
	      AND dont_pay_reason_code = p_dont_pay_code;

    END IF;

 RETURN l_count;

END;

/*===========================================================================
 |  FUNCTION    - get_ps_ur_count
 |  DESCRIPTION - Gets the count of scheduled payments for the missing User
 |                exchange rates for a combination of  payment currency
 |                and the ledger currency(Invoices associated with one OU
 |                have one ledger currency associated with them).
 |                Usage: PsExchangeRatesPG.
 |
 *==========================================================================*/
FUNCTION get_ps_ur_count(
                p_checkrun_id                   IN  NUMBER,
                p_ledger_currency_code          IN VARCHAR2,
                p_payment_currency_code         IN VARCHAR2)
RETURN NUMBER IS

l_ps_ur_count  NUMBER;


BEGIN

	SELECT count(*)
	  INTO  l_ps_ur_count
	  FROM ap_selected_invoices_All asi,
	       ap_system_parameters_all asp
	 WHERE asi.org_id = asp.org_id
	   AND asi.checkrun_id = p_checkrun_id
	   AND asp.base_currency_code  = p_ledger_currency_code
	   AND asi.payment_currency_code = p_payment_currency_code
	   AND asi.payment_exchange_rate_type = 'User'
	   AND asi.ok_to_pay_flag = 'Y';


RETURN l_ps_ur_count;

END;

/*=============================================================================
 |  FUNCTION    - Get_missing_rates_ps_count
 |  DESCRIPTION - This is the total count of selected scheduled payments that
 |                have missing exchange rates
 |
 *============================================================================*/
FUNCTION Get_missing_rates_ps_Count(p_checkrun_id      IN  NUMBER)
RETURN NUMBER IS

l_missing_rates_ps_count  NUMBER := 0;

BEGIN

      SELECT count(*)
      INTO  l_missing_rates_ps_count
      FROM ap_selected_invoices_all asi,
           ap_system_parameters_all asp
     WHERE asi.org_id = asp.org_id
       AND asi.checkrun_id = p_checkrun_id
       AND asp.base_currency_code <> asi.payment_currency_code
       AND asi.payment_exchange_rate_type = 'User'
       AND asi.payment_exchange_rate is NULL
       AND asi.ok_to_pay_flag = 'Y'
       AND  EXISTS (SELECT 'No User Rate'
                      FROM ap_user_exchange_rates aur
                     WHERE aur.ledger_currency_code = asp.base_currency_code
                       AND aur.payment_currency_code = asi.payment_currency_code
                       AND  aur.exchange_rate is NULL);

      RETURN l_missing_rates_ps_count;

END;


/*=============================================================================
 |  FUNCTION     - Get_interest_due
 |  DESCRIPTION  - This is the Total Interest due for the Selected Payment
 |                 Schedule wrt the Payment Date on the Pay Run. The Interest
 |                 Due is calculated during the AutoSelect/Recalculation.
 |
 *============================================================================*/
FUNCTION Get_Interest_due(
                p_checkrun_id                  IN NUMBER,
                p_invoice_id                   IN NUMBER,
                p_payment_num                  IN NUMBER
                )
RETURN NUMBER IS

l_interest_due  NUMBER;

BEGIN

BEGIN
    SELECT payment_amount
      INTO l_interest_due
      FROM ap_selected_invoices_All
     WHERE checkrun_id = p_checkrun_id
       AND original_invoice_id = p_invoice_id
       AND original_payment_num = p_payment_num;
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
     l_interest_due := NULL;
    END;

 RETURN l_interest_due;
END;


/*===========================================================================
 |  FUNCTION    - Get_interest_paid
 |  DESCRIPTION - This is the total interest that has been paid for the Invoice
 |                Used in PsDetailsPG
 |
 *==========================================================================*/
FUNCTION get_interest_paid(p_invoice_id            IN NUMBER)
RETURN NUMBER IS

l_interest_paid  NUMBER := 0;

BEGIN

   BEGIN

        SELECT SUM(NVL(amount_paid,0))
          INTO l_interest_paid
          FROM ap_invoices_all ai
         WHERE invoice_id IN (
              SELECT DISTINCT related_invoice_id
                FROM ap_invoice_relationships air
               WHERE original_invoice_id = p_invoice_id );
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
          NULL;
    END;

 RETURN l_interest_paid;
END;

/*===========================================================================
 |  FUNCTION     - Get_interest_inv
 |  DESCRIPTION  - This is the Interest Invoice planned for the Selected
 |                Scheduled Payment.
 |                Used in PsDetailsPG
 |
 *==========================================================================*/
  FUNCTION Get_Interest_inv(
                p_checkrun_id                  IN NUMBER,
                p_invoice_id                   IN NUMBER,
                p_payment_num                  IN NUMBER
                )
RETURN VARCHAR2 IS

l_interest_inv  AP_INVOICES_ALL.invoice_num%TYPE;


BEGIN

    BEGIN
        SELECT invoice_num
          INTO l_interest_inv
          FROM ap_selected_invoices_All
         WHERE checkrun_id = p_checkrun_id
           AND original_invoice_id = p_invoice_id
           AND original_payment_num = p_payment_num;
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
          NULL;
    END;

 RETURN l_interest_inv;
END;


/*=============================================================================
 |  FUNCTION    - Get_gain_loss_amt
 |  DESCRIPTION - This function would calculate the estimated gain loss for the
 |                Payment Schedule.
 |                PsDetailsPG : Nice to have
 |
 *============================================================================*/
FUNCTION Get_gain_loss_amount
 RETURN NUMBER IS
l_gain_loss_amt   NUMBER;

BEGIN

RETURN  l_gain_loss_amt;

END;


/*===========================================================================
 |  FUNCTION     - Get_interest_rate
 |  DESCRIPTION  - This is the interest rate use to create planned interest
 |                 invoices. The rate is calculated wrt the payment date
 |
 *==========================================================================*/
FUNCTION get_interest_rate(p_check_date   IN  DATE)
RETURN NUMBER IS

l_rate NUMBER;

BEGIN

    BEGIN
        SELECT annual_interest_rate
          INTO l_rate
          FROM ap_interest_periods
         WHERE p_check_date BETWEEN start_date and end_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
         l_rate := NULL;
    END;

RETURN l_rate;
END;


/*=============================================================================
 |  FUNCTION    - get_payment_status_flag
 |  DESCRIPTION - This function returns the status w.r.t payments that have been
 |               created in IBY for this Payment Process Request(Checkrun_id)
 |
 |
 |  BUG 6476559 -  Removed the entire code in this function and calling the IBY
 |                 function to return the status flag.
 |
 *============================================================================*/
FUNCTION get_payment_status_flag(p_psr_id      IN         NUMBER)
RETURN VARCHAR2 IS

l_payment_status_flag  VARCHAR2(1);
l_total_pmt_count      NUMBER;
l_pmt_complete_count   NUMBER;


BEGIN

   l_payment_status_flag := IBY_UTILITY_PVT.get_payment_status_flag(p_psr_id);

   RETURN l_payment_status_flag;

END get_payment_status_flag;



/*=============================================================================
 |  FUNCTION    - get_psr_status
 |  DESCRIPTION - This function returns the status w.r.t payments that have been
 |               created in IBY for this Payment Process Request(Checkrun_id)
 |
 |
 |  BUG 6476559 -  Removed the entire code in this function and calling the IBY
 |                 function to return the status.
 |
 *============================================================================*/
FUNCTION get_psr_status(p_psr_id      IN   NUMBER,
                        p_psr_status  IN   VARCHAR2)
RETURN VARCHAR2 IS

l_psr_status          VARCHAR2(30);
l_total_pmt_count     NUMBER;
l_instr_count         NUMBER;
l_pmt_terminate_count NUMBER;


BEGIN

   l_psr_status := IBY_UTILITY_PVT.get_psr_status(p_psr_id
                                                 ,p_psr_status);

   RETURN l_psr_status;

END get_psr_status;

/*===========================================================================
 |  FUNCTION    - get_destination_function
 |  DESCRIPTION - The destination function is attached to the Payment Process
 |                request Link on the PsrSearch Page. The Payment Process
 |                Name Link navigates the user to Selected Payment Schedules
 |                Page if the request is not yet submitted to IBY and status
 |                is 'REVIEW' or 'MISSING RATES'. If the request has been
 |                submitted to IBY, the link navigates the user to
 |                IBY_FD_REQUEST_DETAIL Page unless the status is INSERTED' or
 |                'SUBMITTED'. For all other statuses the Link is disabled
 |
 |
 *==========================================================================*/
FUNCTION get_destination_function(p_checkrun_id      IN   NUMBER,
                                  p_status_code      IN   VARCHAR2)
RETURN VARCHAR2 IS

l_function fnd_form_functions.FUNCTION_NAME%TYPE;

l_count1  NUMBER;
l_count2   NUMBER;
BEGIN

    /* Code Added for Bug#9276224 Start */
    SELECT count(*)
      INTO l_count1
      FROM ap_selected_invoices_All
     WHERE checkrun_id =  p_checkrun_id;

    SELECT count(*)
      INTO l_count2
      FROM ap_selected_invoices
     WHERE checkrun_id =  p_checkrun_id;

    -- current user doesn't has access to all the selected docs
    IF (l_count1 <> l_count2) THEN
       RETURN NULL;
    END IF;
    /* Code Added for Bug#9276224 End */

    IF p_status_code IN ('REVIEW', 'MISSING RATES') THEN
       l_function := 'AP_PAY_PSR_SEL_DOCS';

       /* commented for bug#9276224 Start
       SELECT count(*)
         INTO l_count1
         FROM ap_selected_invoices_All
        WHERE checkrun_id =  p_checkrun_id;

         SELECT count(*)
         INTO l_count2
         FROM ap_selected_invoices
        WHERE checkrun_id =  p_checkrun_id;

       -- current user doesn't has access to all the selected docs
       IF (l_count1 <> l_count2) THEN
          l_function := NULL;
       END IF;
       commented for bug#9276224 End */

    -- bug 9384008. Added COMPLETED status to the list of statuses.

    ELSIF p_status_code IN (
              'INFORMATION_REQUIRED', 'ASSIGNMENT_COMPLETE',
              'DOCUMENTS_VALIDATED', 'VALIDATION_FAILED',
              'RETRY_DOCUMENT_VALIDATION', 'PENDING_REVIEW_DOC_VAL_ERRORS',
              'PAYMENTS_CREATED', 'PENDING_REVIEW',
              'FAILED_PAYMENT_VALIDATION', 'PENDING_REVIEW_PMT_VAL_ERRORS',
              'RETRY_PAYMENT_CREATION', 'RETRY_PAYMENT_CREATION',
              'TERMINATED', 'COMPLETED') THEN
       l_function  := 'IBY_FD_REQUEST_DETAIL';
    ELSE
        --SQLAP --'UNSTARTED', 'SELECTING', 'CANCELLED NO PAYMENTS' , 'SELECTED'
        --IBY  -- 'INSERTED', 'SUBMITTED'
       l_function := null;

    END IF;

RETURN l_function;

END;


/*=============================================================================
 |  FUNCTION - Action_Switcher
 |  DESCRIPTION - The function is attached to the ActionSwitcher
 |  TakeActionEnabled    -- takeaction_enabled.gif(ActionFunction)
 |  TakeActionDisabled   -- No Icon (No Action)
 |  WarningIndEvenActive -- warningind_even_active.gif (This case can happens
 |                          when say a Concurrent Program is Terminated).
 |  ActionInProgress     -- inprogressind_status.gif (No Action)
 |
 *============================================================================*/
FUNCTION Action_Switcher(p_checkrun_id         IN NUMBER,
                         p_psr_id              IN NUMBER,
                         p_status_code         IN VARCHAR2,
                         p_checkrun_request_id IN NUMBER,
                         p_psr_request_id      IN NUMBER
                         )
RETURN VARCHAR2 IS

l_action              VARCHAR2(100);
l_count1              NUMBER;
l_count2              NUMBER;
l_request_status      VARCHAR2(100);

BEGIN

  /* Added for bug#9276224 Start */
  SELECT count(*)
    INTO l_count1
    FROM ap_selected_invoices_All
   WHERE checkrun_id =  p_checkrun_id;

  SELECT count(*)
    INTO l_count2
    FROM ap_selected_invoices
   WHERE checkrun_id =  p_checkrun_id;

   -- current user doesn't has access to all the selected docs
   IF (l_count1 <> l_count2) THEN
      RETURN 'TakeActionDisabled';
   END IF;
  /* Added for bug#9276224 End */

  IF p_psr_id is NULL THEN

    IF p_status_code IN ( 'REVIEW', 'MISSING RATES') THEN
          l_action  := 'TakeActionEnabled';
    ELSE
          l_action := 'TakeActionDisabled';
    END IF;

  ELSE --Request is submitted to IBY

    IF p_status_code IN ( 'INFORMATION_REQUIRED',
                          'PENDING_REVIEW_DOC_VAL_ERRORS',
                          'PENDING_REVIEW_PMT_VAL_ERRORS',
                          'PENDING_REVIEW') THEN

     l_action := 'TakeActionEnabled';

     ELSE

       l_action := 'TakeActionDisabled';
     END IF;
     --
     --If the Conc Request is complete(Normal) IBY NULL's out the Request_id column
     IF l_action = 'TakeActionEnabled' AND  p_psr_request_id IS NOT NULL THEN

        l_request_status :=
              iby_disburse_ui_api_pub_pkg.get_conc_request_status(
                                                      p_psr_request_id);
         --
	     IF (l_request_status = 'SUCCESS') THEN
	       l_action := 'TakeActionEnabled';
	     ELSIF (l_request_status = 'ERROR') THEN
	       l_action := 'WarningIndEvenActive';
	     ELSE
	       l_action := 'ActionInProgress';
	     END IF;
	 END IF;
  END IF;

  /* commented for bug#9276224 Start
  --Disable Action if User doesn't has MOAC access
  IF  l_action IN ('TakeActionEnabled') THEN
  --
     SELECT count(*)
       INTO l_count1
       FROM ap_selected_invoices_All
      WHERE checkrun_id =  p_checkrun_id;

     SELECT count(*)
       INTO l_count2
       FROM ap_selected_invoices
      WHERE checkrun_id =  p_checkrun_id;

      -- current user doesn't has access to all the selected docs
      IF (l_count1 <> l_count2) THEN
           l_action := 'TakeActionDisabled';
      END IF;
      --
  END IF;
  --
  commented for bug#9276224 End */

  RETURN l_action;
  --
END;

/*=============================================================================
 |  FUNCTION - Get_Action_Function
 |  DESCRIPTION - The Action function is attached to the Start Action Icon
 |                The Icon navigates the user to Selected Payment Schedules
 |                Page if the request is not yet submitted to IBY and status
 |                is 'REVIEW' or 'MISSING RATES'. If the request has been
 |                submitted to IBY, the link navigates the user to the
 |                following pages
 |
 |                IBY Statuses                  Destinations
 |                ----------------------------  -----------------------
 |                INFORMATION_REQUIRED          IBY_FD_ASSIGN_COMPLETE
 |                PENDING_REVIEW_DOC_VAL_ERRORS IBY_FD_DOCS_VALIDATE
 |                PENDING_REVIEW_PMT_VAL_ERRORS IBY_FD_PAYMENT_VALIDATE
 |                PENDING_REVIEW                IBY_FD_PAYMENT_REVIEW
 |
 *============================================================================*/
FUNCTION get_action_function(p_checkrun_id      IN     NUMBER,
                             p_status_code      IN     VARCHAR2)
RETURN VARCHAR2 IS

l_function            fnd_form_functions.function_name%TYPE;
l_count1              NUMBER;
l_count2              NUMBER;

BEGIN

    IF p_status_code IN ('REVIEW', 'MISSING RATES') THEN
           l_function := 'AP_PAY_PSR_SEL_DOCS';

    ELSIF p_status_code IN ('INFORMATION_REQUIRED')  THEN
        l_function :=  'IBY_FD_ASSIGN_COMPLETE';  -- Complete Document
                                                  -- Assignments
    ELSIF p_status_code IN ('PENDING_REVIEW_DOC_VAL_ERRORS') THEN
        l_function :=  'IBY_FD_DOCS_VALIDATE';    -- Resolve Document
                                                  -- Validation Errors
    ELSIF p_status_code IN ('PENDING_REVIEW_PMT_VAL_ERRORS') THEN
        l_function :=  'IBY_FD_PAYMENT_VALIDATE'; -- Resolve Payment
                                                  -- Validation Errors
    ELSIF p_status_code IN ('PENDING_REVIEW') THEN
        l_function :=  'IBY_FD_PAYMENT_REVIEW';  -- Review proposed
                                                 -- payment
    ELSE
        l_function := null;
    END IF;

    IF  l_function is NOT NULL THEN
      SELECT count(*)
          INTO l_count1
          FROM ap_selected_invoices_All
         WHERE checkrun_id =  p_checkrun_id;


          SELECT count(*)
          INTO l_count2
          FROM ap_selected_invoices
         WHERE checkrun_id =  p_checkrun_id;

       -- current user doesn't has access to all the selected docs
       IF (l_count1 <> l_count2) THEN
           l_function := NULL;
       END IF;

    END  IF;


    RETURN l_function;

END;


 /*===========================================================================
 |  FUNCTION     - get_psr_snapshot_count
 |  DESCRIPTION  - This function is designed for the Payables Payment Manager
 |                 Home Page . The function returns the total count of Payment
 |                 Process Requests with a particular Status or a combination
 |                 of Payment Process Request Statuses that map to a particular
 |                 snapshot code
 |
 |  BUG 6476559 -  Removed the entire code in this function and calling the IBY
 |                 function to return the count.
 |
 |
 *==========================================================================*/
FUNCTION get_psr_snapshot_count(p_snapshot_code      IN     VARCHAR2)
RETURN NUMBER IS

l_ret_val             NUMBER;

BEGIN

    l_ret_val := IBY_UTILITY_PVT.get_psr_snapshot_count(p_snapshot_code);

    RETURN l_ret_val;

END;

/*=============================================================================
 |  FUNCTION    - Update Payment Schedules
 |  DESCRIPTION - This method locks the newly added Payment Schedules
 |
 |  Bug 5646905 -- Modified the update statement from the = clause to the IN
 |                 clause so the plan can execute the sub-query first.
 |
 |
 *============================================================================*/
FUNCTION Update_payment_schedules(
                  p_checkrun_id                   IN  NUMBER)
RETURN VARCHAR2 IS

BEGIN
	UPDATE ap_payment_schedules_all APS
	   SET APS.checkrun_id = p_checkrun_id
	 WHERE (APS.invoice_id, APS.payment_num ) IN
	                    (SELECT ASI.invoice_id, ASI.payment_num
	                       FROM ap_selected_invoices_all ASI
	                      WHERE APS.invoice_id = ASI.invoice_id
	                        AND APS.payment_num = ASI.payment_num
	                        AND ASI.checkrun_id = p_checkrun_id)
	  AND APS.checkrun_id is NULL;

	 RETURN 'S';
END;

/*=============================================================================
 |  FUNCTION    - Validates Psr
 |  DESCRIPTION - This method is a wrapper on IBY's  API
 |                IBY_FD_USER_API_PUB.Validate_Method_and_Profile(ibyfduas.pls)
 *============================================================================*/
FUNCTION Validate_Psr(
                  p_checkrun_id                   IN  NUMBER)
RETURN VARCHAR2 IS

l_ret_status           VARCHAR2(1) := 'E';
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);

l_payment_method_code  ap_inv_selection_criteria_all.payment_method_code%TYPE;
l_payment_profile_id   ap_inv_selection_criteria_all.payment_profile_id%TYPE;
l_payment_document_id  ap_inv_selection_criteria_all.payment_document_id%TYPE;
l_create_instrs_flag   ap_inv_selection_criteria_all.create_instrs_flag%TYPE;


l_le_arr               IBY_FD_USER_API_PUB.Legal_Entity_Tab_Type;
l_int_bank_account_id  NUMBER;
l_int_bank_account_arr IBY_FD_USER_API_PUB.Int_Bank_Acc_Tab_Type;
l_curr_arr             IBY_FD_USER_API_PUB.Currency_Tab_type;
l_ou_arr               IBY_FD_USER_API_PUB.Org_Tab_Type;

CURSOR curr_arr_cursor IS
SELECT currency_code
  FROM ap_currency_group
 WHERE checkrun_id = p_checkrun_id;

CURSOR le_arr_cursor IS
SELECT legal_entity_id
  FROM ap_le_group
 WHERE checkrun_id = p_checkrun_id;

CURSOR ou_arr_cursor IS
SELECT org_id,
       'OPERATING_UNIT'
  FROM ap_ou_group
 WHERE checkrun_id = p_checkrun_id;

BEGIN
    --
    fnd_msg_pub.Initialize;
    --
   SELECT payment_method_code,
          payment_profile_id,
          bank_account_id,
          payment_document_id,
          create_instrs_flag
     INTO l_payment_method_code,
	      l_payment_profile_id,
	      l_int_bank_account_id,
	      l_payment_document_id,
	      l_create_instrs_flag
	 FROM ap_inv_selection_criteria_all
    WHERE checkrun_id = p_checkrun_id;
	--
	OPEN curr_arr_cursor;
	FETCH curr_arr_cursor
	BULK COLLECT INTO l_curr_arr;
	CLOSE curr_arr_cursor;
	--
	OPEN le_arr_cursor;
	FETCH le_arr_cursor
	BULK COLLECT INTO l_le_arr;
	CLOSE le_arr_cursor;
	--
	OPEN ou_arr_cursor;
	FETCH ou_arr_cursor
	BULK COLLECT INTO l_ou_arr;
	CLOSE ou_arr_cursor;
	--
        IF l_int_bank_account_id IS NOT NULL THEN
	  l_int_bank_account_arr(1) := l_int_bank_Account_id;
        END IF;
    --
    IBY_FD_USER_API_PUB.Validate_Method_and_Profile (
	     p_api_version              =>   1.0,
	     p_init_msg_list            =>   'F',
	     p_payment_method_code      =>   l_payment_method_code,
	     p_ppp_id                   =>   l_payment_profile_id,
	     p_payment_document_id      =>   l_payment_document_id,
         p_crt_instr_flag           =>   l_create_instrs_flag,
	     p_int_bank_acc_arr         =>   l_int_bank_account_arr,
	     p_le_arr                   =>   l_le_arr,
	     p_org_arr                  =>   l_ou_arr,
	     p_curr_arr                 =>   l_curr_arr,
	     x_return_status            =>   l_ret_status,
	     x_msg_count                =>   l_msg_count,
	     x_msg_data                 =>   l_msg_data);
	--
	l_curr_arr.DELETE;
	l_le_arr.DELETE;
	l_ou_arr.DELETE;
    --
    RETURN   l_ret_status;

END;

/*=============================================================================
 |  FUNCTION    - Validates Payment Template
 |  DESCRIPTION - This method is a wrapper on IBY's  API
 |                IBY_FD_USER_API_PUB.Validate_Method_and_Profile(ibyfduas.pls)
 |
 *============================================================================*/
FUNCTION Validate_payment_template(
                  p_template_id                   IN  NUMBER)
RETURN VARCHAR2 IS

l_ret_status           VARCHAR2(1) := 'E';
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);

l_payment_method_code  ap_inv_selection_criteria_all.payment_method_code%TYPE;
l_payment_profile_id   ap_inv_selection_criteria_all.payment_profile_id%TYPE;
l_payment_document_id  ap_inv_selection_criteria_all.payment_document_id%TYPE;
l_create_instrs_flag   ap_inv_selection_criteria_all.create_instrs_flag%TYPE;

l_le_arr               IBY_FD_USER_API_PUB.Legal_Entity_Tab_Type;
l_int_bank_account_id  NUMBER;
l_int_bank_account_arr IBY_FD_USER_API_PUB.Int_Bank_Acc_Tab_Type;
l_curr_arr             IBY_FD_USER_API_PUB.Currency_Tab_type;
l_ou_arr               IBY_FD_USER_API_PUB.Org_Tab_Type;

CURSOR curr_arr_cursor IS
SELECT currency_code
  FROM ap_currency_group
 WHERE template_id = p_template_id;

CURSOR le_arr_cursor IS
SELECT legal_entity_id
  FROM ap_le_group
 WHERE template_id = p_template_id;

CURSOR ou_arr_cursor IS
SELECT org_id,
       'OPERATING_UNIT'
  FROM ap_ou_group
 WHERE template_id = p_template_id;

BEGIN
    --
    fnd_msg_pub.Initialize;
    --
	SELECT payment_method_code,
               payment_profile_id,
               bank_account_id,
               payment_document_id,
               create_instrs_flag
         INTO l_payment_method_code,
	      l_payment_profile_id,
	      l_int_bank_account_id,
	      l_payment_document_id,
	      l_create_instrs_flag
	 FROM ap_payment_templates
	WHERE template_id = p_template_id;
	--
	OPEN curr_arr_cursor;
	FETCH curr_arr_cursor
	BULK COLLECT INTO l_curr_arr;
	CLOSE curr_arr_cursor;
	--
	OPEN le_arr_cursor;
	FETCH le_arr_cursor
	BULK COLLECT INTO l_le_arr;
	CLOSE le_arr_cursor;
	--
	OPEN ou_arr_cursor;
	FETCH ou_arr_cursor
	BULK COLLECT INTO l_ou_arr;
	CLOSE ou_arr_cursor;
	--
        IF l_int_bank_account_id IS NOT NULL THEN
	  l_int_bank_account_arr(1) := l_int_bank_Account_id;
        END IF;
        --
	IBY_FD_USER_API_PUB.Validate_Method_and_Profile (
	     p_api_version              =>   1.0,
	     p_init_msg_list            =>   'F',
	     p_payment_method_code      =>   l_payment_method_code,
	     p_ppp_id                   =>   l_payment_profile_id,
	     p_payment_document_id      =>   l_payment_document_id,
         p_crt_instr_flag           =>   l_create_instrs_flag,
	     p_int_bank_acc_arr         =>   l_int_bank_account_arr,
	     p_le_arr                   =>   l_le_arr,
	     p_org_arr                  =>   l_ou_arr,
	     p_curr_arr                 =>   l_curr_arr,
	     x_return_status            =>   l_ret_status,
	     x_msg_count                =>   l_msg_count,
	     x_msg_data                 =>   l_msg_data);

    --
	l_curr_arr.DELETE;
	l_le_arr.DELETE;
	l_ou_arr.DELETE;
    --
    RETURN   l_ret_status;
    --
END;

/*=============================================================================
 |  FUNCTION    - Get_request_status
 |  DESCRIPTION - This function returns YES if a batch can be cancelled and NO
 |                if the PPR is not allowed to be cancelled.
 |                In NO case, appropriate error messages are thrown on to OA page.
 |                Earlier, this method was used to determine whether Cancel icon
 |                should be enabled. Post PPR/PI Termination enhancement, this
 |                is used to check if PPR can be terminated after clicking the
 |                always enabled Terminate icon.
 *============================================================================*/
FUNCTION Get_request_status
     (p_checkrun_id  IN NUMBER,
      p_psr_id       IN NUMBER)
RETURN VARCHAR2
IS
  l_request_id             NUMBER;
  call_status              BOOLEAN;
  rphase                   VARCHAR2(80);
  rstatus                  VARCHAR2(80);
  dphase                   VARCHAR2(30);
  dstatus                  VARCHAR2(30);
  message                  VARCHAR2(240);
  l_status                 VARCHAR2(30);
  l_payment_status         VARCHAR2(1);
  l_psr_status             VARCHAR2(30);
  l_pmt_complete_count     NUMBER;
  -- added 2 vars for Bug 9074848 PPR/PI Termination Enhancement
  l_straight_through_flag  VARCHAR2(1);
  l_ppr_term_allowed       VARCHAR2(3);
BEGIN

  FND_MSG_PUB.initialize;
  IF p_psr_id IS NULL THEN
    --

/* Bug 9074848 PPR/PI Termination Enhancement
   Commented below SELECT as no further code uses it.
*/

/*
    SELECT request_id, status
    INTO l_request_id, l_status
    FROM ap_inv_selection_criteria_all
    WHERE checkrun_id = p_checkrun_id;
*/


/*    Bug 9074848 PPR/PI Termination Enhancement
      Commented below check for 11i batches.
      We are disabling Terminate icon for such batches through the PsrSearchVO itself
*/

   /*
   -- 11i Payment batches have request_id as NULL, disable the cancel icon
      IF  l_request_id is NULL THEN
       RETURN 'N';
      END IF;
   */


   /* Bug 9074848 PPR/PI Termination Enhancement
      Commented below check for cancelled batches.
      We are disabling Terminate icon for such batches through the PsrSearchVO itself
   */


    /*
    --R12 baches which are already cancelled.
    IF l_status IN ( 'CANCELED' , 'CANCELLED NO PAYMENTS') THEN
     RETURN 'N';
    END IF;

   */

/* Bug 9074848 PPR/PI Termination Enhancement
   Returning YES to signal cancellation of the AP PPR if no IBY PSR is raised yet.
*/
    RETURN 'YES';
  ELSE  --IBY

    SELECT request_id,
           payment_service_request_status
    INTO   l_request_id,l_psr_status
    FROM   iby_pay_service_requests
    WHERE  payment_service_request_id = p_psr_id;

/* Bug 9074848 PPR/PI Termination Enhancement
   Commented below check for terminated Payment Service Request.
   We are disabling Terminate icon for such requests through the PsrSearchVO itself
*/

/*  IF  l_psr_status = 'TERMINATED' THEN
      RETURN 'N';
    END  IF;
*/

    SELECT Count(* )
    INTO   l_pmt_complete_count
    FROM   iby_payments_all
    WHERE  payment_service_request_id = p_psr_id
           AND payment_instruction_id IS NOT NULL
           AND ROWNUM = 1;

    --If Instructions exist, we should not allow Cancellation of the Pay Run.
    IF l_pmt_complete_count > 0 THEN
/* Bug 9074848 PPR/PI Termination Enhancement
   At least on PI exists for this PPR.
   Check if straight-through processing is used.
*/
      SELECT Nvl(create_instrs_flag,'N')
      INTO   l_straight_through_flag
      FROM   ap_inv_selection_criteria_all
      WHERE  checkrun_id = p_checkrun_id;

/* Bug 9074848 PPR/PI Termination Enhancement
   Throw error message if straight through processing is not used.
   PIs of this PPR may contain payments from other PPRs, so cant terminate.
*/
      IF l_straight_through_flag <> 'Y' THEN
        fnd_message.Set_name('SQLAP','AP_PPR_STRGT_THRU_NOT_USED');
        fnd_msg_pub.ADD;
        RETURN 'NO';
      ELSE  -- straight-through processing is used
        -- Check if PPR can be terminated (whether all PIs of this PPR are terminate-able)
        l_ppr_term_allowed := iby_fd_user_api_pub.Ppr_sec_term_allowed(p_psr_id);
        IF l_ppr_term_allowed <> 'YES' THEN
          fnd_message.Set_name('SQLAP','AP_PPR_PI_CANT_TERM');
          fnd_msg_pub.ADD;
          RETURN 'NO';
        END IF;
      END IF;
    END IF; --psr_id is NOT NULL
    IF l_request_id IS NOT NULL THEN
      call_status := fnd_concurrent.Get_request_status(l_request_id,'','',rphase,rstatus,dphase,
                                                       dstatus,message);

      IF ((dphase = 'COMPLETE')
           OR (dphase IS NULL)) THEN
        RETURN 'YES';
      ELSE
        fnd_message.Set_name('SQLAP','AP_PPR_BUILD_PMT_RUNNING');
        fnd_msg_pub.ADD;
        RETURN 'NO';
      END IF;
    ELSE --request_id is NULL
      RETURN 'YES';
    END IF;
  END IF;
  RETURN 'YES';
END;



/*=============================================================================
 |  FUNCTION    - Is Federal Installed
 |  DESCRIPTION - This method is a wrapper on FV_INSTALL.Enabled(org_id)
 |                API
 |
 *============================================================================*/
FUNCTION Is_Federal_Installed(p_org_id      IN  NUMBER)
RETURN VARCHAR2 IS
BEGIN

 IF FV_INSTALL.Enabled(p_org_id) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

 END Is_Federal_Installed;

/*=============================================================================
 |  FUNCTION    -  CHECK_PPR_MOAC_ACCESS                                       |
 |  DESCRIPTION - This method will check if User can take action on PPR or not |
 |                Logic is to check the each Org against the current user Org  |
 |                access. If any of the org is not listed under User's Security|
 |                set by FND; Function will return 'N' else 'Y'                |
 |                                                                             |
 |                Get Distinct Org Id for Invoices selected in PPR --> Count1  |
 |                Check no of Org_Id accessible against the security context   |
 |                set in session. If Count mismatches Return 'N' else 'Y'      |
 *============================================================================*/
 FUNCTION Check_PPR_MOAC_Access(p_checkrun_id IN  NUMBER)
   RETURN VARCHAR2 IS

 CURSOR C_GET_ORG_INFO IS
  SELECT DISTINCT ORG_ID
  FROM AP_SELECTED_INVOICES_ALL
  WHERE CHECKRUN_ID = p_checkrun_id
  and NVL(MO_GLOBAL.CHECK_ACCESS(ORG_ID), 'N') <> 'Y';

  l_return_val VARCHAR2(1);
  l_org_id     number;
  l_curent_calling_seq VARCHAR2(60);
  l_debug_info VARCHAR2(200);
  l_api_name   VARCHAR2(100);
 BEGIN
  l_return_val := 'Y';
  l_api_name := 'Check_PPR_MOAC_Access';
  l_curent_calling_seq := 'AP_PAYMENT_UTIL_PKG.Check_PPR_MOAC_Access';
  l_debug_info := 'AP_PAYMENT_UTIL_PKG.Check_PPR_MOAC_Access(+)';

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;
  IF(p_checkrun_id IS NULL) THEN
     l_debug_info := 'Checkrun Id is NULL';
     RETURN 'N';
  END IF;

  --If one record exists then Return the value as 'N'
  OPEN C_GET_ORG_INFO;
  FETCH C_GET_ORG_INFO INTO l_org_id;
  IF(C_GET_ORG_INFO%ROWCOUNT > 0) THEN
    l_return_val := 'N';
  END IF;
  CLOSE C_GET_ORG_INFO;
  l_debug_info := 'AP_PAYMENT_UTIL_PKG.Check_PPR_MOAC_Access(-) with Rtuen value  ' ||l_return_val;

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  RETURN l_return_val;
  EXCEPTION
   WHEN OTHERS THEN
     l_debug_info := 'AP_PAYMENT_UTIL_PKG.Check_PPR_MOAC_Access(-) Exception Occurs';
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
     END IF;
     RETURN 'N';
 END Check_PPR_MOAC_Access;

 /* Added for bug#9835337 Start */
 FUNCTION Check_PPR_PMT_MOAC_Access(p_instruction_id IN  NUMBER)
 RETURN VARCHAR2 IS
  l_access_link  VARCHAR2(20);
  l_debug_info   VARCHAR2(200);
  l_api_name     VARCHAR2(100);
 BEGIN
   l_api_name := 'Check_PPR_PMT_MOAC_Access';
   l_access_link := 'NOLINK';

   SELECT 'NOLINK'
     INTO l_access_link
     FROM dual
    WHERE EXISTS
          ( SELECT 1
              FROM iby_payments_all
             WHERE payment_instruction_id = p_instruction_id
               AND org_id <> -1
               AND MO_GLOBAL.CHECK_ACCESS(org_id) = 'N'
          );
   RETURN 'NOLINK';

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'LINK';
  WHEN OTHERS THEN
    l_debug_info := 'AP_PAYMENT_UTIL_PKG.Check_PPR_PMT_MOAC_Access(-) Exception Occurs';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;
    RETURN 'NOLINK';

 END Check_PPR_PMT_MOAC_Access;
 /* Added for bug#9835337 End */

END AP_PAYMENT_UTIL_PKG;

/
