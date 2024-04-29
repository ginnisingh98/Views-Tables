--------------------------------------------------------
--  DDL for Package AR_AGING_BUCKETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_AGING_BUCKETS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARAGBKTS.pls 120.0.12010000.2 2009/07/28 06:01:33 nproddut noship $*/


/*==========================================================================
| PRIVATE FUNCTION get_reporting_entity_id                                 |
|                                                                          |
| DESCRIPTION                                                              |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
FUNCTION get_reporting_entity_id RETURN NUMBER;


/*==========================================================================
| PRIVATE FUNCTION get_contact_information                                 |
|                                                                          |
| DESCRIPTION                                                              |
|  Returns contact information  associated to given site,return values     |
|  also depends on what sort of information is requested                   |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)            |
|                                                                          |
| PARAMETERS                                                               |
|  p_site_use_id                                                           |
|  p_info_type  -possible values are NAME and PHONE                        |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
FUNCTION get_contact_information( p_site_use_id NUMBER,
                                  p_info_type   VARCHAR2) RETURN VARCHAR2;



/*==========================================================================
| PRIVATE PROCEDURE aging_seven_buckets                                    |
|                                                                          |
| DESCRIPTION                                                              |
|                                                                          |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS                                         |
|    Used as part of the cocurrent program defintion                       |
|                                                                          |
| PARAMETERS                                                               |
|  NONE                                                                    |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
| NOTES                                                                    |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE aging_seven_buckets(
                      p_rep_type                 IN VARCHAR2,
		      p_reporting_level          IN VARCHAR2,
		      p_reporting_entity_id      IN VARCHAR2,
		      p_coaid                    IN VARCHAR2,
		      p_in_bal_segment_low       IN VARCHAR2,
		      p_in_bal_segment_high      IN VARCHAR2,
		      p_in_as_of_date_low        IN VARCHAR2,
		      p_in_summary_option_low    IN VARCHAR2,
		      p_in_format_option_low     IN VARCHAR2,
		      p_in_bucket_type_low       IN VARCHAR2,
		      p_credit_option            IN VARCHAR2,
		      p_risk_option              IN VARCHAR2,
		      p_in_currency              IN VARCHAR2,
		      p_in_customer_name_low     IN VARCHAR2,
		      p_in_customer_name_high    IN VARCHAR2,
		      p_in_customer_num_low      IN VARCHAR2,
		      p_in_customer_num_high     IN VARCHAR2,
		      p_in_amt_due_low           IN VARCHAR2,
		      p_in_amt_due_high          IN VARCHAR2,
		      p_in_invoice_type_low      IN VARCHAR2,
		      p_in_invoice_type_high     IN VARCHAR2,
		      p_accounting_method        IN VARCHAR2,
		      p_in_worker_id             IN VARCHAR2 DEFAULT -1,
		      p_in_worker_count          IN VARCHAR2 DEFAULT 1,
		      p_retain_staging_flag      IN VARCHAR2 DEFAULT NULL,
		      p_master_req_flag          IN VARCHAR2   DEFAULT 'Y' );




/*==========================================================================
| PRIVATE PROCEDURE aging_rep_extract                                      |
|                                                                          |
| DESCRIPTION                                                              |
|    Acts as child process,makes required procedure call to process the    |
|    alllocated payment schedules and generate aging information           |
|                                                                          |
| CALLED FROM PROCEDURES/FUNCTIONS                                         |
|    Used as part of the cocurrent program defintion                       |
|                                                                          |
|                                                                          |
| KNOWN ISSUES                                                             |
|                                                                          |
|                                                                          |
| MODIFICATION HISTORY                                                     |
| Date                  Author            Description of Changes           |
| 10-JUL-2009           Naveen Prodduturi Created                          |
*==========================================================================*/
PROCEDURE aging_rep_extract(
                      p_errbuf                   OUT NOCOPY VARCHAR2,
                      p_retcode                  OUT NOCOPY NUMBER,
                      p_rep_type                 IN VARCHAR2,
		      p_reporting_level          IN VARCHAR2,
		      p_reporting_entity_id      IN VARCHAR2,
		      p_coaid                    IN VARCHAR2,
		      p_in_bal_segment_low       IN VARCHAR2,
		      p_in_bal_segment_high      IN VARCHAR2,
		      p_in_as_of_date_low        IN VARCHAR2,
		      p_in_summary_option_low    IN VARCHAR2,
		      p_in_format_option_low     IN VARCHAR2,
		      p_in_bucket_type_low       IN VARCHAR2,
		      p_credit_option            IN VARCHAR2,
		      p_risk_option              IN VARCHAR2,
		      p_in_currency              IN VARCHAR2,
		      p_in_customer_name_low     IN VARCHAR2,
		      p_in_customer_name_high    IN VARCHAR2,
		      p_in_customer_num_low      IN VARCHAR2,
		      p_in_customer_num_high     IN VARCHAR2,
		      p_in_amt_due_low           IN VARCHAR2,
		      p_in_amt_due_high          IN VARCHAR2,
		      p_in_invoice_type_low      IN VARCHAR2,
		      p_in_invoice_type_high     IN VARCHAR2,
		      p_accounting_method        IN VARCHAR2,
		      p_in_worker_id             IN VARCHAR2 DEFAULT -1,
		      p_in_worker_count          IN VARCHAR2 DEFAULT 1,
		      p_retain_staging_flag      IN VARCHAR2 DEFAULT NULL) ;

END AR_AGING_BUCKETS_PKG;

/
