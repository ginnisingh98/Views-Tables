--------------------------------------------------------
--  DDL for Package ARP_PROCESS_RETURNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_RETURNS" AUTHID CURRENT_USER AS
/* $Header: ARPRRTNS.pls 120.4 2006/01/06 15:16:33 ggadhams noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

TYPE inv_info_type IS RECORD
(
  num_of_cms        NUMBER,
  cc_apps           BOOLEAN,     --- Has CC apps
  all_recs_in_doubt BOOLEAN,     --- If all receipts are in doubt
  rid_reason        VARCHAR2(2000) -- Correspoding reason for receipt in doubt
);

TYPE app_info_type IS RECORD
(
   rec_proc_option   VARCHAR2(30),
   rec_in_doubt      VARCHAR2(1),
   rec_currency_code ar_cash_receipts.currency_code%type,
   inv_currency_code ar_cash_receipts.currency_code%type,
   cross_currency    BOOLEAN,
   rid_reason        VARCHAR2(2000),
   trx_number        ra_customer_trx.trx_number%type
);

TYPE amt_app_type IS RECORD
(
  line_applied        ar_receivable_applications.amount_applied%type,
  tax_applied         ar_receivable_applications.amount_applied%type,
  freight_applied     ar_receivable_applications.amount_applied%type,
  charges_applied     ar_receivable_applications.amount_applied%type,
  amount_applied      ar_receivable_applications.amount_applied%type
);

TYPE inv_info_table_type IS TABLE OF inv_info_type
    INDEX BY BINARY_INTEGER;

TYPE app_table_type IS TABLE OF ar_receivable_applications%rowtype
    INDEX BY BINARY_INTEGER;

TYPE app_info_table_type IS TABLE OF app_info_type
    INDEX BY BINARY_INTEGER;
TYPE amt_app_table_type IS TABLE OF amt_app_type
    INDEX BY BINARY_INTEGER;

inv_info      inv_info_table_type;
app_info      app_info_table_type;
app_tab       app_table_type;
amt_app_tab   amt_app_table_type;
/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/


/*========================================================================
 | Procedure process_invoice_list()
 |
 | DESCRIPTION
 |      Process Invoices from the list prepared by the AutoInvoice
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
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
 | Date                  Author           Description of Changes
 | 02-Jul-2003           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE process_invoice_list ;

/*========================================================================
 | Procedure process_application_list()
 |
 | DESCRIPTION
 |      Process Applications from the list prepared by the unapply_receipts
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |
 | RETURNS
 |      nothing
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
 | Date                  Author           Description of Changes
 | 18-Jul-2003           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE process_application_list;

/*========================================================================
 | Procedure unapply_receipts()
 |
 | DESCRIPTION
 |      Unapply all receipt applications for the given invoice
 |      and create the application list. This list will be used to create
 |      special applications and apply remaining amount back to original
 |      invoice
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 |   p_inv_customer_trx_id  - Invoice customer Trx ID
 |   p_receipt_handling_option IN VARCHAR2
 |   p_rec_in_doubt        IN BOOLEAN DEFAULT FALSE
 |   p_rid_reason          IN VARCHAR2 DEFAULT NULL
 |
 | RETURNS
 |      nothing
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
 | Date                  Author           Description of Changes
 | 17-Jul-2003           Ramakant Alat    Created
 |
 *=======================================================================*/

PROCEDURE unapply_receipts (p_inv_customer_trx_id IN NUMBER,
                            p_receipt_handling_option IN VARCHAR2
                           );
PROCEDURE add_invoice (p_customer_trx_id IN NUMBER);
FUNCTION get_total_cm_amount (p_inv_customer_trx_id IN NUMBER,
                              p_request_id IN NUMBER) RETURN NUMBER;
FUNCTION get_total_payment_types (p_inv_customer_trx_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_on_acct_cm_apps(p_customer_trx_id   IN NUMBER)
RETURN NUMBER;

FUNCTION get_amount_applied(p_customer_trx_id   IN NUMBER,
                            p_line_type IN VARCHAR2)
RETURN NUMBER;

FUNCTION get_neg_inv_apps(p_customer_trx_id   IN NUMBER)
RETURN NUMBER;

FUNCTION get_llca_apps(p_customer_trx_id   IN NUMBER)
RETURN NUMBER;

END ARP_PROCESS_RETURNS;

 

/
