--------------------------------------------------------
--  DDL for Package IBY_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: ibyvutls.pls 120.9.12010000.9 2010/09/01 19:27:12 svinjamu ship $ */


-- iPayment trxn and batch status codes
-- must be in sync with mid-tier definition
-- in iby.ecapp.Constants
-- For an example of using these constants
-- in iby PL/SQL packages, see IBY_BANKPAYMENT_UPDT_PUB package body

-- for obselete statuses
STATUS_OBSELETE CONSTANT NUMBER :=-1;

STATUS_SUCCESS CONSTANT NUMBER := 0;

STATUS_COMM_ERROR CONSTANT NUMBER :=1;

STATUS_DUP_ORDER_ID CONSTANT NUMBER :=2;

STATUS_DUP_BATCH_ID CONSTANT NUMBER :=3;

STATUS_FIELD_MISSING CONSTANT NUMBER :=4;

STATUS_BEP_ERROR CONSTANT NUMBER :=5;

STATUS_BATCH_PARTIAL CONSTANT NUMBER :=6;

STATUS_BATCH_FAIL CONSTANT NUMBER :=7;

STATUS_NOT_SUPPORTED CONSTANT NUMBER :=8;

-- trxn interuppted before final status could be saved;
-- requires query of BEP to sync final statuses
STATUS_TRANSITIONAL CONSTANT NUMBER :=9;

STATUS_PENDING  CONSTANT NUMBER := 11;

STATUS_INVALID  CONSTANT NUMBER := -99;

STATUS_SCHED_IN_PROGRESS  CONSTANT NUMBER := 12;

STATUS_SCHED_SUCCESS  CONSTANT NUMBER := 13;

STATUS_CANCELLED  CONSTANT NUMBER := 14;

STATUS_SCHED_FAILED  CONSTANT NUMBER := 15;

STATUS_BEP_FAILED  CONSTANT NUMBER := 16;

STATUS_UNABLE_TO_PAY  CONSTANT NUMBER := 17;

STATUS_SUBMITTED  CONSTANT NUMBER := 18;

STATUS_INVALID_CC  CONSTANT NUMBER := 19;

STATUS_TRXN_DECLINED  CONSTANT NUMBER := 20;

-- trxn is waiting in an open batch
STATUS_OPEN_BATCHED  CONSTANT NUMBER := 100;

-- trxn was sent in a batch that resulted in comm error
STATUS_BATCH_COMM_ERROR  CONSTANT NUMBER := 101;


-- trxn is about to be sent out as part of a batch.
-- Used to delimit which transactions were actually
-- sent out so that batched transactions which arrive
-- concurrently are not mistakenly updated to
-- see STATUS_BATCH_PENDING
STATUS_BATCH_TRANSITIONAL  CONSTANT NUMBER := 109;

-- trxn is in a submitted batch
STATUS_BATCH_PENDING  CONSTANT NUMBER := 111;

-- trxn was cancelled an open batch
STATUS_BATCH_CANCELLED  CONSTANT NUMBER := 114;

-- iPayment has exceeded the number of batches
-- allowed in a day
STATUS_BATCH_MAX_EXCEEDED  CONSTANT NUMBER := 120;

-- The statuses of all child trxns (and the EC batches
-- in turn for payable merged iby batches) are obtained
-- through querying the BEP. Some child trxns succeeded,
-- some failed. This is considered a final status
-- Usage: payable EC batch - iby_pay_batches_all.batch_status
--        payable iby merged batch - iby_batches_all.batchstatus
STATUS_QRY_BATCH_PARTIAL CONSTANT NUMBER :=206;

-- The batch is failed at the BEP side.
-- This can happen when the batch has a syntax error,
-- for example. As BEP generally take a batch as
-- an atomic entity, batch failure means all
-- child trxns are failed.
-- This status is also used when all trxns in
-- a batch failed on individual basis on the BEP side.
-- Usage: payable EC batch - iby_pay_batches_all.batch_status
--        payable iby merged batch - iby_batches_all.batchstatus
STATUS_QRY_BATCH_FAIL CONSTANT NUMBER :=207;

-- The statuses of some child trxns are obtained
-- through querying the BEP. Others are still unknown
-- (they will remain in STATUS_BATCH_PENDING).
-- Usage: payable EC batch - iby_pay_batches_all.batch_status
--        payable iby merged batch - iby_batches_all.batchstatus
STATUS_QRY_BATCH_PENDING CONSTANT NUMBER :=211;

-- This is the companion status for STATUS_QRY_BATCH_FAIL.
-- For trxn level. When a batch is failed at BEP side,
-- all it's child trxns will be failed also.
-- For a failed batch/trxn user must make corrections
-- in the originating EC app and submit them
-- as new trxns to iPayment.
-- Note for trxn only failure such as country rule
-- validation error for the trxn, it will get
-- STATUS_BEP_ERROR
-- Usage: payable trxn - iby_pay_payments_all.pmt_status
STATUS_QRY_TRXN_FAIL CONSTANT NUMBER :=220;

-- obseleted financing statuses
STATUS_LENDER_APPROVED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINANCE_TIMEOUT CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINAPP_DRAFT_SAVED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINAPP_RECEIVED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINAPP_SENT CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_ADDINFO_SENT CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_ADDINFO_RECEIVED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINAPP_EXTENDED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINAPP_EXPIRED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FIN_OFFER_EXPIRED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINANCE_OFFLINE CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINANCE_ADDINFO CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINANCE_CANCELLED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FIN_BUYER_ACCEPT CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FIN_BUYER_DECLINE CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_LENDER_INIT_DECLINE CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_LENDER_DECLINE CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FIN_COMPLETE CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FIN_DOC_PROCESS CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FIN_DOC_RECEIVED CONSTANT NUMBER :=STATUS_OBSELETE;
STATUS_FINAPP_PURGED CONSTANT NUMBER :=STATUS_OBSELETE;

--------------------End of Status Codes Definition-----------------------



G_EXPT_ERR         CONSTANT VARCHAR2(80) := 'FND_API.G_EXC_ERROR';
G_EXPT_UNEXP_ERR   CONSTANT VARCHAR2(80) := 'FND_API.G_EXC_UNEXPECTED_ERROR';
G_EXPT_OTR_ERR     CONSTANT VARCHAR2(80) := 'G_EXC_OTHER_ERROR';

C_ERRCODE_PREFIX CONSTANT VARCHAR2(10) := 'IBY_';
C_TOKEN_CONCATENATOR CONSTANT VARCHAR2(1) := '#';
C_TOKEN_VAL_CONCATENATOR CONSTANT VARCHAR2(1) := '=';

-- Yes/no values for 'boolean' parameters of
-- all functions in all IBY* packages
--
C_API_YES CONSTANT VARCHAR2(1) := 'Y';
C_API_NO CONSTANT VARCHAR2(1) := 'N';

/*New parameters for : 10022548 */
TYPE snapshot_count_type IS RECORD (
    l_need_action     NUMBER,
    l_processing      NUMBER,
    l_terminated      NUMBER,
    l_errors          NUMBER,
    l_completed       NUMBER
   );
/*End of New parameters for : 10022548 */
TYPE snapshot_count_t IS TABLE OF  snapshot_count_type ;


--
-- to_number wrapper that catches exceptions
--
FUNCTION to_num( p_str IN VARCHAR2 ) RETURN NUMBER;

--
-- Returns 'Y' if the input is numeric. Else 'N'
--
FUNCTION isNumeric (p_input IN VARCHAR2) RETURN VARCHAR2;

-- Exceptions Handling Routine will do the following:
-- 1. Rollback to savepoint
-- 2. Handle expected, unexpected and other exceptions
-- 3. Add an error message to the API message list
-- 4. Return error status
--
-- The following is example of calling exception handling routines:
--

PROCEDURE handle_exceptions(
  p_api_name        IN  VARCHAR2,
  p_pkg_name        IN  VARCHAR2,
  p_rollback_point  IN  VARCHAR2,
  p_exception_type  IN  VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
);


--
-- Name: handleException
-- Args: p_err_msg => The error message associated with the exception
--       p_err_code => The error code generated by the exception
-- Notes: Scans the error message for the generated exception; if of the
--        form 'IBY_[0-9]*' then this is an iPayment internal error message
--        intended for Java which the procedure will then parse and correctly
--        put on the message stack
--
PROCEDURE handleException
        (
        p_err_msg IN VARCHAR2,
        p_err_code IN VARCHAR2
        );


--
-- Name: get_property
-- Args: p_name => property name
-- Outs: x_val => property value
--
-- Notes: gets an application-wide property
--
PROCEDURE get_property
	(
	p_name      IN  VARCHAR2,
	x_val       OUT NOCOPY VARCHAR2
	);

--
-- Name: set_property
-- Args: p_name => property name
--       p_val => property value
-- Notes: properties are set at the site level
--
--
PROCEDURE set_property
	(
	p_name      IN  VARCHAR2,
	p_val       IN  VARCHAR2
	);

--
-- Name: get_jtf_property
-- Args: p_name => property name
-- Outs: x_val => property value
--
-- Notes: gets an IBY property from old JTF Property manager tables.
--        only the first element of the value list is returned.
--        this function is used by ibyprupg.sql
--
FUNCTION get_jtf_property(p_name IN  VARCHAR2) RETURN VARCHAR2;


--
-- Name: encode64
-- Args: s => string to encode
-- Return: the given string in base64 encoding
--
FUNCTION encode64(s IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: decode64
-- Args: s => base64 encoded string
-- Return: the given string decoded
--
FUNCTION decode64(s IN VARCHAR2) RETURN VARCHAR2;


--
-- Name: get_local_nls
-- Args: none
-- Return: the local (i.e. database) characterset.
--
FUNCTION get_local_nls RETURN VARCHAR2;

--
-- Name: get_nls_charset
-- Args: p_nls => NLSLang parameter (e.g. AMERICAN_AMERICA.US7ASCII)
-- Return: The character set encoding portion of the
--         NLSLang, e.g.:
--         get_nls_charset('AMERICAN_AMERICA.US7ASCII') = 'US7ASCII'
--
FUNCTION get_nls_charset( p_nls VARCHAR2 ) RETURN VARCHAR2;

--
-- Name: MAKE_ASCII
-- Args: p_from_text => text to be converted.
-- Return: The text converted to the US7ASCII character set.
--
FUNCTION MAKE_ASCII(p_from_text IN VARCHAR2) RETURN VARCHAR2;

--
-- Name: get_call_exec
-- Args: p_pkg_name => name of the package in which the procedure is defined
--       p_function_name => name of the function/procedure to invoke
--       p_params => Array of fixed parameters to the call; all positions
--                   should be represented, with arguments that will
--                   take bind variables given null values
-- Return: String usable by EXECUTE IMMEDIATE to invoke the
--         PL/SQL procedure
--
FUNCTION get_call_exec
(
p_pkg_name VARCHAR2,
p_function_name VARCHAR2,
p_params JTF_VARCHAR2_TABLE_200
)
RETURN VARCHAR2;

--
-- Name: set_view_param
-- Args: p_name => view parameter name
--       p_val => view parameter value
--
-- Notes: The name-value pair is lost at the end of
--        the current transaction
--
PROCEDURE set_view_param
(
p_name iby_view_parameters_gt.name%TYPE,
p_val iby_view_parameters_gt.value%TYPE
);

--
-- Name: get_view_param
-- Args: p_name => view parameter name
-- Return: The value of the parameter, or NULL if not defined
--
FUNCTION get_view_param( p_name iby_view_parameters_gt.name%TYPE )
RETURN iby_view_parameters_gt.value%TYPE;

--
-- Name: check_lookup_val
-- Args: p_val => lookup value
--       p_lookup => lookup name code
-- Return: True if the lookup contains that value code
--
--
FUNCTION check_lookup_val(p_val IN VARCHAR2, p_lookup IN VARCHAR2)
RETURN BOOLEAN;

--
-- Return: True if the party id is valid
FUNCTION validate_party_id(p_party_id IN hz_parties.party_id%TYPE)
RETURN BOOLEAN;

--
-- Return: True if the application id is valid
FUNCTION validate_app_id( p_app_id IN fnd_application.application_id%TYPE )
RETURN BOOLEAN;

--
-- Return: True if the territory code is valid
FUNCTION validate_territory
( p_territory IN fnd_territories.territory_code%TYPE )
RETURN BOOLEAN;

--
-- Return: True if the string is trivial
FUNCTION is_trivial(p_string VARCHAR2)
RETURN BOOLEAN;

FUNCTION validate_organization(p_org_id IN iby_trxn_summaries_all.org_id%TYPE,
                               p_org_type IN iby_trxn_summaries_all.org_type%TYPE)
RETURN VARCHAR2;


PROCEDURE validate_pmt_channel_code(p_instrument_type IN iby_creditcard.instrument_type%TYPE,
                                    p_payment_channel_code IN OUT NOCOPY iby_trxn_summaries_all.payment_channel_code%TYPE,
                                    p_valid OUT NOCOPY VARCHAR2);



/*-----------------------------------------------------------------------------------------
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
  -----------------------------------------------------------------------------------------
 */
FUNCTION get_psr_snapshot_count(p_snapshot_code      IN       VARCHAR2)
RETURN NUMBER;


/*-----------------------------------------------------------------------------------------
 |  FUNCTION     - get_psr_snapshot_count PIPELINED.
 |
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
 |===========================================================================================
 |Understanding PIPELINED FUNCTION:
 |-----------------------------------
 |PIPELINED functions are piece of code that can be used for querying SQL.
 |Basically, when you would like a PLSQL routine to be the source
 |of data -- instead of a table -- you would use a pipelined function.
 |PIPELINED functions will operate like a table.
 |Using PL/SQL table functions can significantly lower the over-head of
 |doing such transformations. PL/SQL table functions accept and return
 |multiple rows, delivering them as they are ready rather than all at once,
 |and can be made to execute as parallel operations.
 |
  -----------------------------------------------------------------------------------------
 */
  FUNCTION get_psr_snapshot_pipe RETURN snapshot_count_t PIPELINED;


 /*-----------------------------------------------------------------------------------------
  FUNCTION    - get_payment_status_flag
  DESCRIPTION - This function returns the status w.r.t payments that have been
                created in IBY for this Payment Process Request(payment_service_request_id)
  ------------------------------------------------------------------------------------------
 */

FUNCTION get_payment_status_flag(p_psr_id      IN         NUMBER,
                                 p_from_cache  IN         VARCHAR2 DEFAULT 'FALSE')
RETURN VARCHAR2;


/*-----------------------------------------------------------------------------------------
  FUNCTION    - get_psr_status
  DESCRIPTION - This function returns the status w.r.t payments that have been
                created in IBY for this Payment Process Request(payment_service_request_id)

 ------------------------------------------------------------------------------------------
 */
FUNCTION get_psr_status(p_psr_id      IN         NUMBER,
                        p_psr_status  IN         VARCHAR2,
			p_from_cache  IN         VARCHAR2 DEFAULT 'FALSE')
RETURN VARCHAR2;

/* Bug Number: 7279395
 * This procedure is used to initialize the table type variable
 * g_psr_table.
 * The pages which are accessing the functions get_psr_status and
 * get_payment_status_flag should take the responsibility of initializing
 * g_psr_table by calling this procedure.
 */
PROCEDURE initialize;

Function check_user_access(p_pay_instruction_id IN Number) RETURN VARCHAR2;


/*-----------------------------------------------------------------------------------------
 |  FUNCTION    - get_format_program_name
 |  DESCRIPTION - This method returns the name of the concurrent program to be invoked for
 |                for formatting given the instruction id. The valid return values can be
 |                IBY_FD_PAYMENT_FORMAT, IBY_FD_PAYMENT_FORMAT_TEXT
  ------------------------------------------------------------------------------------------
*/
FUNCTION get_format_program_name(p_pay_instruction_id                   IN  NUMBER)
RETURN VARCHAR2;


 FUNCTION check_org_access( p_payment_service_request_id IN NUMBER)
 RETURN VARCHAR2;

END IBY_UTILITY_PVT;

/
