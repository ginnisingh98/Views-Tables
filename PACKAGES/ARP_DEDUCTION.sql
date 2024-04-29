--------------------------------------------------------
--  DDL for Package ARP_DEDUCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DEDUCTION" AUTHID CURRENT_USER AS
/* $Header: ARXLDEDS.pls 115.5 2003/06/03 21:45:27 djancis noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC FUNCTION CHECK_TM
 |
 | DESCRIPTION
 |      This function checks whether Trade Management is installed or not.
 |      If TM is installed, it returns the boolean value TRUE, otherwise
 |      it returns false.
 |      ----------------------------------------
 |      This procedure does the following ......
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 27-NOV-2002           AMateen              Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/
FUNCTION CHECK_TM RETURN BOOLEAN;


/*========================================================================
 | PUBLIC FUNCTION CHECK_TM_DEFAULT_SETUP
 |
 | DESCRIPTION
 |      This function returns true if Trade Management Default setup is
 |      available otherwise it returns false.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |      Called by post batch process
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |      OZF_CLAIM_INSTALL.CHECK_DEFAULT_SETUP
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-FEB-2003           cthangai          Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/
FUNCTION CHECK_TM_DEFAULT_SETUP RETURN BOOLEAN;


/*========================================================================
 | PUBLIC PROCEDURE claim_creation
 |
 | DESCRIPTION
 |     Procedure to create a deduction claim in Trade Management ,updates
 |     receivable applications (i.e. Deduction ID, deduction
 |     number and customer reason code), updates amount in dispute and
 |     and inserts trx notes. Handles Non Trx realted claims
 |     and On Transaction related claims (short pays) for claim creation.
 |     In the cases of subsequent receipt application, it initiates the TM API
 |     API to update the claim, update amount_in_dispute and insert TRX Notes.
 |     This procedure is initiated by the Post Batch process.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     arp_process_application.create_claim
 |     app_exception.invalid_argument
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date         Author       Description of Changes
 | 19-DEC-2002  cthangai     Created
 | 14-FEB-2003  cthangai     ar_system_parameter column name changes specific to
 |                           claim processing
 | 27-MAR-2003  cthangai     Added OUT parameter x_return_status
 *=======================================================================*/
PROCEDURE CLAIM_CREATION
  (p_request_id IN ar_receivable_applications.request_id%TYPE DEFAULT NULL
  ,p_matched_claim_creation_flag IN ar_system_parameters.matched_claim_creation_flag%TYPE
  ,p_matched_claim_excl_cm_flag IN ar_system_parameters.matched_claim_excl_cm_flag%TYPE
  ,x_return_status OUT NOCOPY VARCHAR2
  );


/*===========================================================================+
 | PUBLIC PROCEDURE                                                          |
 |    update_claim                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calls iClaim group API to update a deduction claim.                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      OZF_Claim_GRP.Update_Deduction - Group API to update a claim from AR |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   CTHANGAI    03-FEB-2003  Created                                        |
 |   CTHANGAI    27-FEB-2003  Added OUT paramters x_claim_id,x_claim_number  |
 +===========================================================================*/
PROCEDURE update_claim
            ( p_claim_id               IN NUMBER
            , p_claim_number           IN VARCHAR2
            , p_amount                 IN  NUMBER
            , p_currency_code          IN  VARCHAR2
            , p_exchange_rate_type     IN  VARCHAR2
            , p_exchange_rate_date     IN  DATE
            , p_exchange_rate          IN  NUMBER
            , p_customer_trx_id        IN  NUMBER
            , p_invoice_ps_id          IN  NUMBER
            , p_cust_trx_type_id       IN  NUMBER
            , p_trx_number             IN  VARCHAR2
            , p_cust_account_id        IN  NUMBER
            , p_bill_to_site_id        IN  NUMBER
            , p_ship_to_site_id        IN  NUMBER
            , p_salesrep_id            IN  NUMBER
            , p_customer_ref_date      IN  DATE
            , p_customer_ref_number    IN  VARCHAR2
            , p_cash_receipt_id        IN  NUMBER
            , p_receipt_number         IN  VARCHAR2
            , p_reason_id              IN  NUMBER
            , p_comments               IN  VARCHAR2
            , p_attribute_category     IN  VARCHAR2
            , p_attribute1             IN  VARCHAR2
            , p_attribute2             IN  VARCHAR2
            , p_attribute3             IN  VARCHAR2
            , p_attribute4             IN  VARCHAR2
            , p_attribute5             IN  VARCHAR2
            , p_attribute6             IN  VARCHAR2
            , p_attribute7             IN  VARCHAR2
            , p_attribute8             IN  VARCHAR2
            , p_attribute9             IN  VARCHAR2
            , p_attribute10            IN  VARCHAR2
            , p_attribute11            IN  VARCHAR2
            , p_attribute12            IN  VARCHAR2
            , p_attribute13            IN  VARCHAR2
            , p_attribute14            IN  VARCHAR2
            , p_attribute15            IN  VARCHAR2
            , p_applied_date           IN  DATE
            , p_applied_action_type    IN  VARCHAR2
            , p_amount_applied         IN  NUMBER
            , p_applied_receipt_id     IN  NUMBER
            , p_applied_receipt_number IN  VARCHAR2
            , x_return_status          OUT NOCOPY VARCHAR2
            , x_msg_count              OUT NOCOPY NUMBER
            , x_msg_data               OUT NOCOPY VARCHAR2
            , x_object_version_number  OUT NOCOPY NUMBER
            , x_claim_reason_code_id   OUT NOCOPY NUMBER
            , x_claim_reason_name      OUT NOCOPY VARCHAR2
            , x_claim_id               OUT NOCOPY NUMBER
            , x_claim_number           OUT NOCOPY VARCHAR2
            );


/*===========================================================================+
 | PUBLIC PROCEDURE                                                          |
 |    create_claims_rapp_dist                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Procedure for creating claims related RA and associated Distributions  |
 |    Insert 2 RA rows - One as -ve UNAPP row and the second as 'OTHER ACC'  |
 |    The on-account ACC row is similar to the 'OTHER ACC'.                  |
 |    This new procedure is introduced for creating special applications like|
 |    claim.The RA records for 'ACC' or 'OTHER ACC' are created first along  |
 |    with thier corresponding distributions records. After which the        |
 |    negative UNAPP record is created along with its PAIRED distribution    |
 |    record.                                                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |   arp_app_pkg.insert_p - Insert a row into RA table                       |
 |   arp_acct_main.Create_Acct_Entry - Insert a row into Distributions table |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 |              OUT:                                                         |
 |				                                                     |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES  -                                                                  |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 13-JAN-03    CTHANGAI	Created                                        |
 | 21-JAN-03    CTHANGAI	Added receivables_trx_id paramter              |
 | 05-FEB-03    CTHANGAI	Removed application_ref_reason paramter        |
 | 13-FEB-03    CTHANGAI	Removed paramter applied_payment_schedule_id   |
 +===========================================================================*/
 PROCEDURE create_claims_rapp_dist
 (p_cash_receipt_id        IN  ar_receivable_applications.cash_receipt_id%TYPE
 ,p_unapp_ccid             IN  ar_receivable_applications.code_combination_id%TYPE
 ,p_other_acc_ccid         IN  ar_receivable_applications.code_combination_id%TYPE
 ,p_acc_ccid               IN  ar_receivable_applications.code_combination_id%TYPE
 ,p_gl_date                IN  ar_receivable_applications.gl_date%TYPE
 ,p_status                 IN  ar_receivable_applications.status%TYPE
 ,p_amount_applied         IN  ar_receivable_applications.amount_applied%TYPE
 ,p_created_by             IN  ar_receivable_applications.created_by%TYPE
 ,p_creation_date          IN  ar_receivable_applications.creation_date%TYPE
 ,p_last_updated_by        IN  ar_receivable_applications.last_updated_by%TYPE
 ,p_program_application_id IN  ar_receivable_applications.program_application_id%TYPE
 ,p_program_id             IN  ar_receivable_applications.program_id%TYPE
 ,p_request_id             IN  ar_receivable_applications.request_id%TYPE
 ,p_sob_id                 IN  ar_receivable_applications.set_of_books_id%TYPE
 ,p_apply_date             IN  ar_receivable_applications.apply_date%TYPE
 ,p_ussgl_transaction_code IN  ar_receivable_applications.ussgl_transaction_code%TYPE
 ,p_receipt_ps_id          IN  ar_receivable_applications.payment_schedule_id%TYPE
 ,p_unapp_application_rule IN  ar_receivable_applications.application_rule%TYPE
 ,p_other_application_rule IN  ar_receivable_applications.application_rule%TYPE
 ,p_acc_application_rule   IN  ar_receivable_applications.application_rule%TYPE
 ,p_on_account_customer    IN  ar_receivable_applications.on_account_customer%TYPE
 ,p_receivables_trx_id     IN  ar_receivable_applications.receivables_trx_id%TYPE
 ,p_customer_reference     IN  ar_receivable_applications.customer_reference%TYPE
 ,p_customer_reason        IN  ar_receivable_applications.customer_reason%TYPE
 ,p_attribute_category     IN  ar_receivable_applications.attribute_category%TYPE
 ,p_attribute1             IN  ar_receivable_applications.attribute1%TYPE
 ,p_attribute2             IN  ar_receivable_applications.attribute2%TYPE
 ,p_attribute3             IN  ar_receivable_applications.attribute3%TYPE
 ,p_attribute4             IN  ar_receivable_applications.attribute4%TYPE
 ,p_attribute5             IN  ar_receivable_applications.attribute5%TYPE
 ,p_attribute6             IN  ar_receivable_applications.attribute6%TYPE
 ,p_attribute7             IN  ar_receivable_applications.attribute7%TYPE
 ,p_attribute8             IN  ar_receivable_applications.attribute8%TYPE
 ,p_attribute9             IN  ar_receivable_applications.attribute9%TYPE
 ,p_attribute10            IN  ar_receivable_applications.attribute10%TYPE
 ,p_attribute11            IN  ar_receivable_applications.attribute11%TYPE
 ,p_attribute12            IN  ar_receivable_applications.attribute12%TYPE
 ,p_attribute13            IN  ar_receivable_applications.attribute13%TYPE
 ,p_attribute14            IN  ar_receivable_applications.attribute14%TYPE
 ,p_attribute15            IN  ar_receivable_applications.attribute15%TYPE
 ,x_return_status          OUT NOCOPY VARCHAR2
 );


/*========================================================================
 | PUBLIC PROCEDURE claim_create_fail_recover
 |
 | DESCRIPTION
 |     Procedure to recover from claim creation failure.
 |     The receivable application records and thier corresponding distribution
 |     records for the claim are deleted. The payment schedule amounts are
 |     updated appropriately.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     claim_creation
 |
 | CALLS PROCEDURES/FUNCTIONS
 |     arp_process_application2.delete_selected_transaction
 |     app_exception.invalid_argument
 |
 |
 | PARAMETERS
 |         IN  :
 |               p_rapp_id
 |               p_cr_id
 |
 |         OUT :
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date         Author            Description of Changes
 | 17-JAN-2003  cthangai          Created
 | 05-MAR-2003  cthangai          Removed In parameter - payment_schedule_id
 *=======================================================================*/
PROCEDURE claim_create_fail_recover
  (p_rapp_id IN ar_receivable_applications.receivable_application_id%TYPE
  ,p_cr_id   IN ar_receivable_applications.cash_receipt_id%TYPE
  );


/*========================================================================
 | PUBLIC FUNCTION GET_FUNCTIONAL_CURRENCY
 |
 | DESCRIPTION
 |      This function is called in the view associated with the LOV in the
 |      multiple Quickcash screen for the receipt to receipt feature to
 |      derive the functional currency code
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    NONE
 |
 |         OUT:    NONE
 |
 | RETURNS    : VARCHAR2 (Functional Currency Code by Set Of Books)
 |
 |
 | NOTES      : This should be eventually rellocated into the arp_util package
 |
 | MODIFICATION HISTORY
 | Date		Author		Description of Changes
 | 21-JAN-2003	cthangai        Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/
FUNCTION GET_FUNCTIONAL_CURRENCY RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION GET_RECEIVABLES_TRX_ID
 |
 | DESCRIPTION
 |      This function is called to retreive the receivables_trx_id
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    p_cash_receipt_id
 |
 |         OUT:    NONE
 |
 | RETURNS    : NUMBER (receivable_trx_id associated with the cash_receipt_id)
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author		Description of Changes
 | 23-JAN-2003	cthangai        Created
 | DD-MON-YYYY           Name              Bug #####, modified amount ..
 |
 *=======================================================================*/
FUNCTION GET_RECEIVABLES_TRX_ID
 (  p_cash_receipt_id IN  ar_cash_receipts.cash_receipt_id%TYPE
 )  RETURN NUMBER;


/*========================================================================
 | PUBLIC PROCEDURE UPDATE_CLAIM_CREATE_STATUS
 |
 | DESCRIPTION
 |      This function is called to update ar_payment_schedules table
 |      active_claim_flag with the appropriate claim status returned from TM
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    Payment Schedule ID
 |                 Claim Status
 |
 |         OUT:    NONE
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author	    Description of Changes
 | 21-JAN-2003	cthangai    Update ar_payment_schdeules.active_claim_flag
 |                            based on the claim status in TM
 | DD-MON-YYYY    Name        Bug #####, modified amount ..
 |
 *=======================================================================*/
PROCEDURE UPDATE_CLAIM_CREATE_STATUS
 (p_ps_id        IN ar_payment_schedules.payment_schedule_id%type
 ,p_claim_status IN ar_payment_schedules.active_claim_flag%type
 );


/*========================================================================
 | PUBLIC PROCEDURE conc_req_log_msg
 |
 | DESCRIPTION
 |      This function writes messages to the concurrent request log file
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    message
 |
 |         OUT:    NONE
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author	Description of Changes
 | 13-FEB-2003	cthangai    Created
 | DD-MON-YYYY    Name        Bug #####
 |
 *=======================================================================*/
PROCEDURE conc_req_log_msg (p_message IN VARCHAR2);


/*========================================================================
 | PUBLIC PROCEDURE conc_req_out_msg
 |
 | DESCRIPTION
 |      This function writes messages to the concurrent request output file
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    message
 |
 |         OUT:    NONE
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author	Description of Changes
 | 13-FEB-2003	cthangai    Created
 | DD-MON-YYYY    Name        Bug #####
 |
 *=======================================================================*/
PROCEDURE conc_req_out_msg (p_message IN VARCHAR2);


/*========================================================================
 | PUBLIC FUNCTION OVERAPPLICATION_INDICATOR
 |
 | DESCRIPTION
 |     Function to determine whether amount applied will cause an
 |     overapplication given the current amount due remaining and
 |     amount due original.
 |     A=sign(amount_due_remaining - amount_applied)
 |     B=sign(amount_due_original)
 |     If A=-1 and B=+1 or A=+1 and B=-1 then overapplication
 |     Returns Y else Return N
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |      Called from AR_INTERIM_CASH_RECEIPTS_V ,AR_INTERIM_CR_LINES_V
 |      and Quick Cash Form (ARXRWQRC.fmb)
 | CALLS PROCEDURES/FUNCTIONS
 |
 |
 |
 | PARAMETERS
 |  IN:
 |    P_AMOUNT_DUE_ORIGINAL IN  NUMBER
 |    P_AMOUNT_DUE_REMAININIG  IN NUMBER
 |    P_AMOUNT_APPLIED  IN NUMBER
 |  OUT:
 |      RETURN Y/N
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date         Author            Description of Changes
 | 21-JAN-2003  KDhaliwal         Created
 |
 *=======================================================================*/
FUNCTION OVERAPPLICATION_INDICATOR
(P_AMOUNT_DUE_ORIGINAL IN  NUMBER
,P_AMOUNT_DUE_REMAINING  IN NUMBER
,P_AMOUNT_APPLIED  IN NUMBER
)
 RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION CHECK_APP_VIOLATE
 |
 | DESCRIPTION
 |    Function to determine whether amount entered in the screen
 |    is violating Natural Applicatioon OR violating Over Application OR
 |    is a valid Natural Application
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     Called from WHEN-VALIDATE-ITEM trigger of the AMOUNT field in the
 |     Multiple QuickCash window as well as the Receipt Application window
 |
 | CALLS PROCEDURES/FUNCTIONS
 |
 | PARAMETERS
 |  IN:
 |    P_AMOUNT_DUE_ORIGINAL IN  NUMBER
 |    P_AMOUNT_DUE_REMAININIG  IN NUMBER
 |    P_AMOUNT_APPLIED  IN NUMBER
 |  OUT:
 |      RETURN ('NATURAL','OVER','NO')
 |         NATURAL -> Natural Application Violation
 |         OVER    -> Over Application Violation
 |         NO      -> No Violation
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date         Author  	Description of Changes
 | 23-JAN-2003  CTHANGAI      Created
 |
 *=======================================================================*/
FUNCTION CHECK_APP_VIOLATE
 (p_amount   IN ar_receivable_applications.amount_applied%TYPE
 ,p_rapp_id  IN ar_receivable_applications.receivable_application_id%TYPE DEFAULT NULL
 ,p_cr_id    IN ar_receivable_applications.cash_receipt_id%TYPE
 )  RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION GET_TM_ORACLE_REASON
 |
 | DESCRIPTION
 |      This function is called to retrieve the Oracle reason description
 |      from TM
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    TM Claim ID
 |
 |         OUT:    NONE
 |
 | RETURNS    : VARCHAR (Oracle Reason From TM)
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author		Description of Changes
 | 12-FEB-2003	cthangai        Created
 | DD-MON-YYYY  Name            Bug #####, modified amount ..
 |
 *=======================================================================*/
FUNCTION GET_TM_ORACLE_REASON
 (p_claim_id   IN ar_receivable_applications.secondary_application_ref_id%TYPE
 ) RETURN VARCHAR2;

/*========================================================================
 | PUBLIC PROCEDURE apply_open_receipt_cover
 |
 | DESCRIPTION
 |      This procedure is a wrapper to initiate calls to receipts API.
 |      Performs validation and initiates the API on success
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN :    NONE
 |
 |         OUT:    X_RETURN_STAUS ('S' for success, 'E' or 'U' for Error)
 |
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date		Author	    Description of Changes
 | 19-FEB-2003	cthangai    Created
 | 25-FEB-2003	cthangai    Add OUT parameters x_return_status, x_apply_type
 | DD-MON-YYYY  Name        Bug #####
 |
 *=======================================================================*/
PROCEDURE apply_open_receipt_cover
  (p_cash_receipt_id             IN  ar_cash_receipts.cash_receipt_id%TYPE
  ,p_applied_payment_schedule_id IN  ar_payment_schedules.payment_schedule_id%TYPE
  ,p_open_rec_app_id             IN  ar_receivable_applications.receivable_application_id%TYPE
  ,p_amount_applied              IN  ar_receivable_applications.amount_applied%TYPE
  ,p_attribute_category          IN  ar_receivable_applications.attribute_category%TYPE
  ,p_attribute1                  IN  ar_receivable_applications.attribute1%TYPE
  ,p_attribute2                  IN  ar_receivable_applications.attribute2%TYPE
  ,p_attribute3                  IN  ar_receivable_applications.attribute3%TYPE
  ,p_attribute4                  IN  ar_receivable_applications.attribute4%TYPE
  ,p_attribute5                  IN  ar_receivable_applications.attribute5%TYPE
  ,p_attribute6                  IN  ar_receivable_applications.attribute6%TYPE
  ,p_attribute7                  IN  ar_receivable_applications.attribute7%TYPE
  ,p_attribute8                  IN  ar_receivable_applications.attribute8%TYPE
  ,p_attribute9                  IN  ar_receivable_applications.attribute9%TYPE
  ,p_attribute10                 IN  ar_receivable_applications.attribute10%TYPE
  ,p_attribute11                 IN  ar_receivable_applications.attribute11%TYPE
  ,p_attribute12                 IN  ar_receivable_applications.attribute12%TYPE
  ,p_attribute13                 IN  ar_receivable_applications.attribute13%TYPE
  ,p_attribute14                 IN  ar_receivable_applications.attribute14%TYPE
  ,p_attribute15                 IN  ar_receivable_applications.attribute15%TYPE
  ,x_return_status               OUT NOCOPY VARCHAR2
  ,x_receipt_number              OUT NOCOPY ar_cash_receipts.receipt_number%TYPE
  ,x_apply_type                  OUT NOCOPY VARCHAR2
  );

/*========================================================================
 | PUBLIC FUNCTION GET_ACTIVE_CLAIM_FLAG
 |
 | DESCRIPTION
 |      This function returns the value of the active claim flag which is
 |      stored on the Payment Schedule of a transaction.   This flag indicates
 |      whether or not an active claim exists in trade management.
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURE/FUNCTIONS ACCESSED - NONE
 |
 | ARGUMENTS  :
 |         IN     :    payment_schedule_id
 |
 |         RETURNS:    ACTIVE_CLAIM_FLAG (for that payment schedule id)
 |
 | KNOWN ISSUES
 |
 | NOTES      :
 |
 | MODIFICATION HISTORY
 | Date         Author		Description of Changes
 | 03-JUN-2003  Debbie Jancis 	Created
 |
 *=======================================================================*/
FUNCTION GET_ACTIVE_CLAIM_FLAG(
    p_payment_schedule_id  IN ar_payment_schedules.payment_schedule_id%TYPE)
 RETURN VARCHAR2;


END ARP_DEDUCTION;

 

/
