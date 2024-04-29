--------------------------------------------------------
--  DDL for Package AR_CMGT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_UTIL" AUTHID CURRENT_USER AS
/* $Header: ARCMUTLS.pls 120.20.12010000.2 2008/09/24 15:09:43 mraymond ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

 /* Bug 2855292 */
 TYPE ocm_global_setup_options  IS RECORD
 (  aging_bucket_id ar_cmgt_setup_options.aging_bucket_id%TYPE,
    default_credit_classification
	ar_cmgt_setup_options.default_credit_classification%TYPE,
    default_exchange_rate_type
	ar_cmgt_setup_options.default_exchange_rate_type%TYPE,
    match_rule_id ar_cmgt_setup_options.match_rule_id%TYPE,
    cer_dso_days ar_cmgt_setup_options.cer_dso_days%TYPE,
    period ar_cmgt_setup_options.period%TYPE,
    auto_application_num_flag
	ar_cmgt_setup_options.auto_application_num_flag%TYPE
 );

 TYPE t_ocm_global_setup_options IS TABLE OF ocm_global_setup_options
      INDEX BY BINARY_INTEGER;

 pg_ocm_global_setup_options t_ocm_global_setup_options;

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

PROCEDURE debug (
  p_message     IN VARCHAR2,
  p_module_name IN VARCHAR2 default 'ar.cmgt.plsql.AR_CMGT_UTIL',
  p_log_level   IN NUMBER default fnd_log.level_statement);

PROCEDURE wf_debug (p_process_name IN VARCHAR2,
                    p_message IN VARCHAR2);

/*========================================================================
 | PUBLIC FUNCTION
 |      get_wf_debug_flag()
 | DESCRIPTION
 |      This function checks both AFLOG_ENABLED and AR_CMGT_WF_DEBUG
 |      profiles and returns Y if either are set.  Internally,
 |      we handle the logging for either (or both) methods.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |     debug_flag    OUT   Y or N
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-APR-2008           M Raymond         Created
 |
 *=======================================================================*/

FUNCTION  get_wf_debug_flag
    RETURN VARCHAR2;

/*========================================================================
 | PUBLIC FUNCTION
 |      check_user_resource()
 | DESCRIPTION
 |      This function checks whether resource id passed is for the user who
 |      is logged.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_credit_analyst_id    IN   Credit Analyst Id of the case folder
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-May-2002           S.Nambiar         Created
 |
 *=======================================================================*/
FUNCTION check_update_permissions(p_credit_analyst_id IN  NUMBER,
                                  p_requestor_id       IN  NUMBER,
                                  p_credit_request_status IN VARCHAR2 )
    RETURN VARCHAR2;

/* Overloaded Function */
FUNCTION check_update_permissions(p_credit_analyst_id IN  NUMBER,
                                  p_requestor_id       IN  NUMBER)
    RETURN VARCHAR2;
/*========================================================================
 | PUBLIC FUNCTION
 |      check_emp_credit_analyst()
 | DESCRIPTION
 |      This function checks whether employee id passed is a credit analyst
 |      or not
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_employee_id    IN   Employee Id of the user logged in
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-May-2002           S.Nambiar         Created
 |
 *=======================================================================*/
FUNCTION check_emp_credit_analyst(p_employee_id IN  NUMBER )
    RETURN VARCHAR2;

FUNCTION check_emp_credit_analyst
    RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION
 |      check_credit_analyst()
 | DESCRIPTION
 |      This function checks whether resource_id passed is a credit analyst.
 |      For a credit analysts there will be a credit analyst role assigned
 |      in resource manager.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_resource_id    IN      resource_id
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 20-May-2002           S.Nambiar         Created
 |
 *=======================================================================*/
FUNCTION check_credit_analyst(p_resource_id IN  NUMBER )
    RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION
 |      find_analysis_level()
 | DESCRIPTION
 |      This function checks tells you whether the analysis is at the
 |      party, customer account, or account site level.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_party_id             IN     Party Id
 |      p_cust_account_id      IN     Customer Account Id
 |      p_cust_acct_site_id    IN     Customer Account Site Id
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Jun-2003           M.Senthil         Created
 |
 *=======================================================================*/
FUNCTION find_analysis_level(p_party_id IN NUMBER,
                             p_cust_account_id IN NUMBER,
                             p_cust_acct_site_id IN NUMBER)
    RETURN VARCHAR2;


/*========================================================================
 | PUBLIC FUNCTION
 |      get_limit_currency()
 | DESCRIPTION
 |      This function takes in some parameters and fills in the appropriate
 |      values regarding which currency is returned.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_party_id             IN     Party Id
 |      p_cust_account_id      IN     Customer Account Id
 |      p_cust_acct_site_id    IN     Customer Account Site Id
 |      p_trx_currency_code    IN     Transaction Currency Code
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Jun-2003           M.Senthil         Created
 |
 *=======================================================================*/
PROCEDURE get_limit_currency(
            p_party_id                  IN          NUMBER,
            p_cust_account_id           IN          NUMBER,
            p_cust_acct_site_id         IN          NUMBER,
            p_trx_currency_code         IN          VARCHAR2,
            p_limit_curr_code           OUT nocopy         VARCHAR2,
            p_trx_limit                 OUT nocopy         NUMBER,
            p_overall_limit             OUT nocopy         NUMBER,
            p_cust_acct_profile_amt_id  OUT nocopy         NUMBER,
            p_global_exposure_flag      OUT nocopy         VARCHAR2,
            p_include_all_flag          OUT nocopy         VARCHAR2,
            p_usage_curr_tbl            OUT nocopy         HZ_CREDIT_USAGES_PKG.curr_tbl_type,
            p_excl_curr_list            OUT nocopy         VARCHAR2
          );


FUNCTION get_latest_cf_number(p_credit_request_id IN NUMBER)
   RETURN NUMBER;

PROCEDURE get_no_of_ref_data_points(
            p_credit_classification         IN      VARCHAR2,
            p_review_type                   IN      VARCHAR2,
            p_data_point_id                 IN      NUMBER,
            p_number_of_references          OUT NOCOPY     NUMBER,
            p_value                         OUT NOCOPY     VARCHAR2 );


PROCEDURE copy_checklist_data_points(
            p_new_check_list_id                 IN      VARCHAR2,
            p_old_check_list_id                 IN      VARCHAR2);

FUNCTION IS_DUPLICATE_CHECKLIST (
        p_credit_classification         IN      VARCHAR2,
        p_review_type                   IN      VARCHAR2,
        p_start_date                    IN      DATE)
        return  VARCHAR2;

FUNCTION is_valid_date (
        p_start_date                    IN      DATE,
        p_end_date                      IN      DATE)
        return NUMBER;

FUNCTION get_fnd_user_name (
        p_user_id               IN      NUMBER )
        return VARCHAR2;

FUNCTION get_credit_analyst_name(p_credit_analyst_id IN NUMBER)
      RETURN VARCHAR2;

FUNCTION check_delete_permissions(p_credit_analyst_id  IN  NUMBER,
                                  p_requestor_id       IN  NUMBER,
                                  p_credit_request_status IN VARCHAR2 )
    RETURN VARCHAR2;

FUNCTION get_person_based_on_resource ( l_resource_id   IN  NUMBER)
return NUMBER;

FUNCTION get_person_based_on_cf ( l_case_folder_id   IN  NUMBER)
return NUMBER;

FUNCTION check_casefolder_exists(p_party_id             IN NUMBER,
                                 p_cust_account_id      IN NUMBER,
                                 p_cust_account_site_id IN NUMBER)
return VARCHAR2;

FUNCTION IsApplicationExists(
	p_party_id	        IN 	    NUMBER,
    p_cust_account_id   IN      NUMBER,
    p_site_use_id       IN      NUMBER)
return VARCHAR2;

FUNCTION get_score_summary(p_case_folder_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_credit_classification(p_party_id          IN NUMBER,
                                   p_cust_account_id   IN NUMBER,
                                   p_site_use_id       IN NUMBER)
RETURN VARCHAR2;

PROCEDURE CLOSE_WF_NOTIFICATION  (
		p_credit_request_id		IN			NUMBER,
		p_message_name 			IN			VARCHAR2,
		p_recipient_role		IN			VARCHAR2,
		p_resultout				OUT NOCOPY 	VARCHAR2,
		p_error_msg				OUT NOCOPY	VARCHAR2);


FUNCTION convert_amount ( p_from_currency         VARCHAR2,
                	  p_to_currency           VARCHAR2,
                	  p_conversion_date       DATE,
                	  p_conversion_type       VARCHAR2 DEFAULT NULL,
                	  p_amount                NUMBER )
RETURN NUMBER;

FUNCTION get_setup_option(p_detail_type IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE OM_CUST_APPLY_HOLD (
    p_party_id            			IN          NUMBER,
    p_cust_account_id            	IN          NUMBER,
    p_site_use_id					IN			NUMBER,
    p_error_msg         			OUT NOCOPY  VARCHAR2,
	p_return_status					OUT NOCOPY	VARCHAR2 );


PROCEDURE OM_CUST_RELEASE_HOLD (
    p_party_id            			IN          NUMBER,
    p_cust_account_id            	IN          NUMBER,
    p_site_use_id					IN			NUMBER,
    p_error_msg         			OUT NOCOPY  VARCHAR2,
	p_return_status					OUT NOCOPY	VARCHAR2 ) ;

FUNCTION get_requestor_name(p_requestor_id IN NUMBER)
      RETURN VARCHAR2;

END AR_CMGT_UTIL;

/
