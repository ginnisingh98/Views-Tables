--------------------------------------------------------
--  DDL for Package ARI_DB_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARI_DB_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: ARIDBUTLS.pls 120.5.12010000.7 2010/04/14 12:26:29 avepati ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/


/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/



/*========================================================================
 | PUBLIC procedure oir_calc_aging_buckets
 |
 | DESCRIPTION
 |      This procedure performs aging calculations within the context
 |      of a customer, site, currency and an aging bucket style.
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_customer_id        	Customer ID
 |      p_as_of_date         	As of when the calculations are performed.
 |      p_currency_code      	Currency Code
 |      p_credit_option      	Age/Not Age Credits
 |      p_invoice_type_low
 |      p_invoice_type_high
 |      p_ps_max_id
 |      p_app_max_id
 |      p_bucket_name           Aging Bucket Defination to use.
 |      p_session_id            Added for All Location Enhancement
 |
 | RETURNS
 |      p_outstanding_balance	Account Balance
 |      p_bucket_titletop_0     Bucket i's Title
 |      p_bucket_titlebottom_0
 |      p_bucket_amount_0       Bucket i's Amount
 |      p_bucket_titletop_1
 |      p_bucket_titlebottom_1
 |      p_bucket_amount_1
 |      p_bucket_titletop_2
 |      p_bucket_titlebottom_2
 |      p_bucket_amount_2
 |      p_bucket_titletop_3
 |      p_bucket_titlebottom_3
 |      p_bucket_amount_3
 |      p_bucket_titletop_4
 |      p_bucket_titlebottom_4
 |      p_bucket_amount_4
 |      p_bucket_titletop_5
 |      p_bucket_titlebottom_5
 |      p_bucket_amount_5
 |      p_bucket_titletop_6
 |      p_bucket_titlebottom_6
 |      p_bucket_amount_6
 |      p_bucket_status_code0   Status Codes used in Acct. Details
 |      p_bucket_status_code1   Status Poplist
 |      p_bucket_status_code2
 |      p_bucket_status_code3
 |      p_bucket_status_code4
 |      p_bucket_status_code5
 |      p_bucket_status_code6
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-Oct-2002           J. Albowicz       Created
 |
 *=======================================================================*/

PROCEDURE oir_calc_aging_buckets (
        p_customer_id        	IN NUMBER,
        p_as_of_date         	IN DATE,
        p_currency_code      	IN VARCHAR2,
        p_credit_option      	IN VARCHAR2,
        p_invoice_type_low   	IN VARCHAR2,
        p_invoice_type_high  	IN VARCHAR2,
        p_ps_max_id             IN NUMBER DEFAULT 0,
        p_app_max_id            IN NUMBER DEFAULT 0,
        p_bucket_name           IN VARCHAR2,
        p_outstanding_balance	IN OUT NOCOPY VARCHAR2,
        p_bucket_titletop_0     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_0	OUT NOCOPY VARCHAR2,
        p_bucket_amount_0       IN OUT NOCOPY VARCHAR2,
        p_bucket_titletop_1     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_1	OUT NOCOPY VARCHAR2,
        p_bucket_amount_1       IN OUT NOCOPY VARCHAR2,
        p_bucket_titletop_2     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_2  OUT NOCOPY VARCHAR2,
        p_bucket_amount_2       IN OUT NOCOPY VARCHAR2,
        p_bucket_titletop_3     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_3  OUT NOCOPY VARCHAR2,
        p_bucket_amount_3       IN OUT NOCOPY VARCHAR2,
        p_bucket_titletop_4	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_4	OUT NOCOPY VARCHAR2,
        p_bucket_amount_4       IN OUT NOCOPY VARCHAR2,
        p_bucket_titletop_5	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_5	OUT NOCOPY VARCHAR2,
        p_bucket_amount_5       IN OUT NOCOPY VARCHAR2,
        p_bucket_titletop_6	OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_6	OUT NOCOPY VARCHAR2,
        p_bucket_amount_6       IN OUT NOCOPY VARCHAR2,
        p_bucket_status_code0   OUT NOCOPY VARCHAR2,
        p_bucket_status_code1   OUT NOCOPY VARCHAR2,
        p_bucket_status_code2   OUT NOCOPY VARCHAR2,
        p_bucket_status_code3   OUT NOCOPY VARCHAR2,
        p_bucket_status_code4   OUT NOCOPY VARCHAR2,
        p_bucket_status_code5   OUT NOCOPY VARCHAR2,
        p_bucket_status_code6   OUT NOCOPY VARCHAR2,
        p_session_id            IN NUMBER
);


/*========================================================================
 | PUBLIC procedure get_site_info
 |
 | DESCRIPTION
 |      Serves as a wrapper to arw_db_utilities.  This wrapper was created
 |      to solve a performance issue encountered when there is a customer
 |      account with a large number of sites.  Basically, the overhead of
 |      calling the arw_db_utilities individually for all rows of the result
 |      set was too much; the solution was to call the arw_db_utilities only
 |      for the portion of the result set that is displayed.
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_customer_id        	Customer ID
 |      p_addr_id               Address ID
 |      p_site_use           	Type of site (All, bill to, ship to, etc.)
 |
 | RETURNS
 |      p_contact_name          Primary Contact for that (Account, Site) tuple
 |      p_contact_phone         Phone number for Primary Contact
 |      p_site_uses             Concatenated string of the site's uses.
 |      p_bill_to_site_use_id   Returns 0 if the site is not a Bill To.
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 12-Jun-2003           J. Albowicz       Created
 |
 *=======================================================================*/


PROCEDURE get_site_info(p_customer_id IN NUMBER,
                        p_addr_id IN NUMBER DEFAULT  NULL,
                        p_site_use IN VARCHAR2 DEFAULT  'ALL',
                        p_contact_name OUT NOCOPY VARCHAR,
                        p_contact_phone OUT NOCOPY VARCHAR,
                        p_site_uses OUT NOCOPY VARCHAR,
                        p_bill_to_site_use_id OUT NOCOPY VARCHAR);


/*========================================================================
 | PUBLIC procedure get_print_request_url
 |
 | DESCRIPTION
 |      This procedure is used to get the status of the print request and
 |      and also its URL.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_request_id            The print request ID
 |      p_gwyuid                The gateway user ID
 |      p_two_task              The value of TWO_TASK
 |      p_user_id               The user ID
 |
 | RETURNS
 |      p_output_url            The output URL for the request
 |      p_status                The status of the print request
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 08-Aug-2003           yashaskar         Created
 |
 *=======================================================================*/

PROCEDURE get_print_request_url(
	p_request_id		IN NUMBER,
	p_gwyuid		IN VARCHAR2,
	p_two_task		IN VARCHAR2,
	p_user_id               IN NUMBER,
	p_output_url		OUT NOCOPY VARCHAR2,
	p_status		OUT NOCOPY VARCHAR2 );


/*========================================================================
 | PUBLIC procedure oir_bpa_print_invoices
 |
 | DESCRIPTION
 |      This procedure is used to submit the print request to BPA and also
 |      inserts the record in ar_irec_print_requests table.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_id_list            	The ids to be submitted
 |      p_list_type             List type
 |      p_description           Description
 |	p_template_id		Template id
 |	p_customer_id		Customer id
 |	p_site_id		Customer Site Use Id
 |
 | RETURNS
 |      x_req_id_list           Request Id
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-May-2005           rsinthre          Created
 |
 *=======================================================================*/
PROCEDURE oir_bpa_print_invoices(
                                 p_id_list   IN  VARCHAR2,
                                 x_req_id_list  OUT NOCOPY VARCHAR2,
                                 p_list_type    IN  VARCHAR2,
                                 p_description  IN  VARCHAR2 ,
                                 p_customer_id  IN  NUMBER,
                                 p_customer_site_id      IN  NUMBER DEFAULT NULL,
                                 p_user_name IN VARCHAR2
);

/*========================================================================
 | PUBLIC procedure oir_invoice_print_selected_invoices
 |
 | DESCRIPTION
 |      This procedure submits cuncurrent request to print the
 |      selected invoices .The notification is sent to the user
 |      who has submited this request .
 |      ----------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_resp_name             Responsibility Name
 |      p_user_name             User Name
 |      p_random_invoices_flag  Randomly selected invoices or a range of invoices
 |      p_invoice_list_string   Customer_trx_ids of all selected invoices
 |
 | RETURNS
 |      p_request_id            Request ID
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 21-Jun-2009           avepati           Created
 |
 *=======================================================================*/


PROCEDURE oir_print_selected_invoices(
        p_resp_name             IN VARCHAR2,
        p_user_name             IN VARCHAR2,
        p_org_id                IN NUMBER,
        p_random_invoices_flag  IN VARCHAR2,
        p_invoice_list_string   IN VARCHAR2,
        p_customer_id           IN VARCHAR2,
        p_customer_site_id      IN VARCHAR2,
        p_request_id            OUT NOCOPY NUMBER );

/*========================================================================
 | PUBLIC procedure upload_ar_bank_branch_concur
 |
 | DESCRIPTION
 |      This procedure submits cuncurrent request to upload AR_BANK_DIRECTORY
 |      table data to HZ_PARTIES.
 |      --------------------------------------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |        NONE
 |
 | RETURNS
 |      ERRBUF                  Error Data
 |      RETCODE                 Return Status
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-sep-2009           avepati           Created
 |
 *=======================================================================*/


PROCEDURE upload_ar_bank_branch_concur(ERRBUF   OUT NOCOPY     VARCHAR2,
                                      RETCODE  OUT NOCOPY     VARCHAR2,
                                      p_import_new_banks_only IN VARCHAR2);

/*========================================================================
 | PUBLIC procedure PURGE_IREC_PRINT_REQUESTS
 |
 | DESCRIPTION
 |      This procedure submits cuncurrent request to purge AR_IREC_PRINT_REQUESTS
 |      table data matching the purge process of FND_CONCURRENT_REQUESTS table.
 |      --------------------------------------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |        NONE
 |
 | RETURNS
 |      ERRBUF                  Error Data
 |      RETCODE                 Return Status
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 02-Apr-2010           avepati           Created
 |
 *=======================================================================*/


PROCEDURE PURGE_IREC_PRINT_REQUESTS(ERRBUF   OUT NOCOPY     VARCHAR2,
  		                                    RETCODE  OUT NOCOPY     VARCHAR2,
				p_creation_date  in varchar2);

/*========================================================================
 | PUBLIC procedure PURGE_IREC_PRINT_REQUESTS
 |
 | DESCRIPTION
 |      This procedure submits cuncurrent request to purge PURGE_IREC_USER_ACCT_SITES_ALL
 |      --------------------------------------------------------------------
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |        NONE
 |
 | RETURNS
 |      ERRBUF                  Error Data
 |      RETCODE                 Return Status
 |     p_creation_date          purge date
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  	Author            Description of Changes
 | 14-Apr-2010           	avepati           Created
 |
 *=======================================================================*/


PROCEDURE PURGE_IREC_USER_ACCT_SITES_ALL(ERRBUF   OUT NOCOPY     VARCHAR2,
  		                                    RETCODE  OUT NOCOPY     VARCHAR2,
				p_creation_date  in varchar2);

END ARI_DB_UTILITIES;

/
