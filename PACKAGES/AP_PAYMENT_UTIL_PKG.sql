--------------------------------------------------------
--  DDL for Package AP_PAYMENT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PAYMENT_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: appayuts.pls 120.12.12010000.3 2010/07/07 20:47:49 bgoyal ship $ */

/*===========================================================================
 |  FUNCTION    - get_le_name
 |  DESCRIPTION - Utility to get Legal Entity Name for transactions which
 |                store legal_entity_id
 *==========================================================================*/
FUNCTION get_le_name(p_legal_entity_id   IN NUMBER)
RETURN  VARCHAR2;

/*===========================================================================
 |  FUNCTION     - get_ou_name
 |  DESCRIPTION  - Utility to get the Operating Unit name for a given org_id
 |                 This API should be replaced by
 |                 fnd_access_control_util.get_org_name(AI.org_id)
 *==========================================================================*/
FUNCTION get_ou_name(p_org_id   IN NUMBER)
RETURN  VARCHAR2 ;


/*===========================================================================
 |  PROCEDURE    - Get_iby_payer_defaults
 |  DESCRIPTION  - Defaults the following IBY defaults(org_id is NULL)
 |                 1. Document Rejection Level
 |                 2. Payment Rejection Level
 |                 3. Whether to Stop Procees for Review After Proposed
 |                    payments creation
 *==========================================================================*/
PROCEDURE get_iby_payer_defaults(
                p_doc_rejection_level_code      OUT NOCOPY VARCHAR2,
                p_payment_rejection_level_code  OUT NOCOPY VARCHAR2,
                p_payments_review_settings      OUT NOCOPY VARCHAR2);


/*===========================================================================
 |  FUNCTION    - get_pi_count
 |  DESCRIPTION - This is the number of payment instructions created for all
 |                payments belonging to the PPR.  This appears only after at
 |                least one exists.
 |
 *==========================================================================*/
FUNCTION get_pi_count(p_psr_id    IN  NUMBER)
RETURN NUMBER;


/*===========================================================================
 |  FUNCTION    - get_selected_ps_count
 |  DESCRIPTION - Gets the count of selected scheduled payments for the
 |                Payment Batch(Pay Run)
 |
 *==========================================================================*/
FUNCTION get_selected_ps_count(p_checkrun_id   IN  NUMBER,
                               p_psr_id        IN  NUMBER)
RETURN NUMBER;

/*===========================================================================
 |  FUNCTION    - get_unsel_ps_count
 |  DESCRIPTION - Gets the count of un-selected scheduled payments for the
 |                Payment Batch(Pay Run)
 |
 *==========================================================================*/
FUNCTION Get_unsel_ps_Count(p_checkrun_id   IN  NUMBER)
RETURN NUMBER;



/*=============================================================================
 |  FUNCTION    - Get_Rejected_ps_Count
 |  DESCRIPTION - This is the total count of scheduled payments that Oracle
 |                Payments(IBY) has rejected.
 |
 *============================================================================*/
FUNCTION get_rejected_ps_count(p_psr_id     IN  NUMBER)
RETURN NUMBER;

/*===========================================================================
 |  FUNCTION    - get_unsel_reason_count
 |  DESCRIPTION - This is the count of payment schedules that met the criteria
 |                but were not selected  for a particular dont_pay_reason_code
 |
 *==========================================================================*/
FUNCTION Get_unsel_reason_Count(
             p_checkrun_id      IN           NUMBER,
             p_dont_pay_code    IN           VARCHAR2
            ) RETURN NUMBER;


/*===========================================================================
 |  FUNCTION    - get_ps_ur_count
 |  DESCRIPTION - Gets the count of scheduled payments for the missing User
 |                exchange rates for a combination of  payment currency
 |                and the ledger currency(Invoices associated with one OU
 |                have one ledger currency associated with them)
 |
 *==========================================================================*/
FUNCTION get_ps_ur_count(
               p_checkrun_id                   IN  NUMBER,
               p_ledger_currency_code          IN VARCHAR2,
               p_payment_currency_code         IN VARCHAR2)
RETURN NUMBER;

/*=============================================================================
 |  FUNCTION    - Get_missing_rates_ps_count
 |  DESCRIPTION - This is the total count of selected scheduled payments that
 |                have missing exchange rates
 |
 *============================================================================*/
FUNCTION Get_missing_rates_ps_Count(
                  p_checkrun_id                   IN  NUMBER)
RETURN NUMBER;

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
RETURN NUMBER;

/*===========================================================================
 |  FUNCTION    - Get_interest_paid
 |  DESCRIPTION - This is the total interest that has been paid for the Invoice
 |                Used in PsDetailsPG
 |
 *==========================================================================*/
FUNCTION get_interest_paid(p_invoice_id            IN NUMBER)
RETURN NUMBER;


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
RETURN VARCHAR2;

/*=============================================================================
 |  FUNCTION    - Get_gain_loss_amt
 |  DESCRIPTION - This function would calculate the estimated gain loss for the
 |                Payment Schedule.
 |                PsDetailsPG : Nice to have
 |
 *============================================================================*/
 FUNCTION Get_gain_loss_amount
 RETURN NUMBER;




/*===========================================================================
 |  FUNCTION     - Get_interest_rate
 |  DESCRIPTION  - This is the interest rate use to create planned interest
 |                 invoices. The rate is calculated wrt the payment date.
 |
 *==========================================================================*/
FUNCTION Get_interest_rate(p_check_date      IN  DATE) RETURN NUMBER;



/*=============================================================================
 |  FUNCTION    - get_payment_status_flag
 |  DESCRIPTION - This function returns the status w.r.t payments that have been
 |                created in IBY for this Payment Process Request(Checkrun_id)
 |                IBY will provide an API to get the value of this flag
 |
 *============================================================================*/
FUNCTION get_payment_status_flag(p_psr_id      IN         NUMBER)
RETURN VARCHAR2;

/*=============================================================================
 |  FUNCTION    - get_psr_status
 |  DESCRIPTION - This function returns the status w.r.t payments that have been
 |               created in IBY for this Payment Process Request(Checkrun_id)
 |
 *============================================================================*/
FUNCTION get_psr_status(p_psr_id      IN         NUMBER,
                        p_psr_status  IN         VARCHAR2)
RETURN VARCHAR2;


/*===========================================================================
 |  FUNCTION    - get_destination_function
 |  DESCRIPTION - The destination function is attached to the Payment Process
 |                request Link on the PsrSearch Page. The Payment Process
 |                Name Link navigates the user to Selected Payment Schedules
 |                Page if the request is not yet submitted to IBY and status
 |                is 'REVIEW' or 'MISSING RATES'. If the request has been
 |                submitted to IBY, the link navigates the user to
 |                IBY_FD_REQUESTS_DET Page uless the status is INSERTED' or
 |                'SUBMITTED'
 |
 |
 *==========================================================================*/
FUNCTION get_destination_function(p_checkrun_id      IN      NUMBER,
                                  p_status_code      IN      VARCHAR2)
RETURN VARCHAR2 ;


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
RETURN VARCHAR2;

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
FUNCTION get_action_function(p_checkrun_id      IN      NUMBER,
                             p_status_code      IN      VARCHAR2)
RETURN VARCHAR2;



 /*===========================================================================
 |  FUNCTION     - get_psr_snapshot_count
 |  DESCRIPTION  - This function is designed for the Payables Payment Manager
 |                 Home Page . The function returns the total count of Payment
 |                 Process Requests with a particular Status or a combination
 |                 of Payment Process Request Statuses that map to a particular
 |                 snapshot code
 |
 |   SNAPSHOT CODE           STATUS
 |   -------------           ------------------------------------------------
 |   NEED_ACTION_BY_ME       AP:
 |                             'REVIEW', 'MISSING RATES'
 |                            IBY:
 |                              'INFORMATION_REQUIRED'
 |                              'PENDING_REVIEW_DOC_VAL_ERRORS',
 |                              'PENDING_REVIEW_PMT_VAL_ERRORS',
 |                              'PENDING_REVIEW'
 |
 |   PROCESSING              AP:
 |                             'UNSTARTED', 'SELECTING', 'CANCELING',
 |                             'CALCULATING', 'SELECTED'
 |                           IBY:
 |                             'INSERTED', 'SUBMITTED',
 |                             'ASSIGNMENT_COMPLETE','DOCUMENTS_VALIDATED',
 |                             'RETRY_DOCUMENT_VALIDATION',
 |                             'RETRY_PAYMENT_CREATION'
 |
 |   USER_TERMINATED         AP:
 |                             'CANCELED' , 'CANCELLED NO PAYMENTS'
 |                           IBY:
 |                             'TERMINATED'
 |
 |   PROGRAM_ERRORS          IBY:
 |                             'PENDING_REVIEW_DOC_VAL_ERRORS'
 |                             'PENDING_REVIEW_PMT_VAL_ERRORS'
 |
 |   COMPLETED               IBY:
 |                           'PAYMENTS_CREATED'
 |
 |   TOTAL                   COUNT(*) IN AP
 |
 *==========================================================================*/
FUNCTION get_psr_snapshot_count(p_snapshot_code      IN       VARCHAR2)
RETURN NUMBER;

/*=============================================================================
 |  FUNCTION    - Update Payment Schedules
 |  DESCRIPTION - This method locks the newly added Payment Schedules
 |
 |
 *============================================================================*/
FUNCTION Update_payment_schedules(
                  p_checkrun_id                   IN  NUMBER)
RETURN VARCHAR2;

/*=============================================================================
 |  FUNCTION    - Validates Psr
 |  DESCRIPTION - This method is a wrapper on IBY's  API
 |                IBY_FD_USER_API_PUB.Validate_Method_and_Profile(ibyfduas.pls)
 |
 *============================================================================*/
FUNCTION Validate_Psr(
                  p_checkrun_id                   IN  NUMBER)
RETURN VARCHAR2;

/*=============================================================================
 |  FUNCTION    - Validates Payment Template
 |  DESCRIPTION - This method is a wrapper on IBY's  API
 |                IBY_FD_USER_API_PUB.Validate_Method_and_Profile(ibyfduas.pls)
 |
 *============================================================================*/
FUNCTION Validate_payment_template(
                  p_template_id                   IN  NUMBER)
RETURN VARCHAR2;


/*=============================================================================
 |  FUNCTION    - Get Request Status
 |  DESCRIPTION - This method is a wrapper on FND API  API
 |                FND_CONCURRENT.Get_Request_status
 |
 *============================================================================*/
FUNCTION Get_request_status(p_checkrun_id   IN  NUMBER,
                            p_psr_id        IN  NUMBER)
RETURN VARCHAR2;


/*=============================================================================
 |  FUNCTION    - Is Federal Installed
 |  DESCRIPTION - This method is a wrapper on FV_INSTALL.Enabled(org_id)
 |                API
 |
 *============================================================================*/
FUNCTION Is_Federal_Installed(p_org_id      IN  NUMBER)
RETURN VARCHAR2;

/*=============================================================================
 |  FUNCTION    -  Check_PPR_MOAC_Access                                      |
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
RETURN VARCHAR2;

/* Added for bug#9835337 Start */
FUNCTION Check_PPR_PMT_MOAC_Access(p_instruction_id IN  NUMBER)
RETURN VARCHAR2;
/* Added for bug#9835337 End */

END AP_PAYMENT_UTIL_PKG;

/
