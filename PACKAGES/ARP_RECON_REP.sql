--------------------------------------------------------
--  DDL for Package ARP_RECON_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RECON_REP" AUTHID CURRENT_USER AS
/* $Header: ARGLRECS.pls 120.1 2005/11/15 05:36:41 rkader noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

type var_t is record(
                       l_ar_system_parameters_all           VARCHAR2(50),
                       l_ar_payment_schedules_all           VARCHAR2(50),
                       l_ar_adjustments_all                 VARCHAR2(50),
                       l_ar_cash_receipt_history_all        VARCHAR2(50),
                       l_ar_batches_all                     VARCHAR2(50),
                       l_ar_cash_receipts_all               VARCHAR2(50),
                       l_ar_distributions_all               VARCHAR2(50),
                       l_ra_customer_trx_all                VARCHAR2(50),
                       l_ra_batches_all                     VARCHAR2(50),
                       l_ra_cust_trx_gl_dist_all            VARCHAR2(50),
                       l_ar_misc_cash_dists_all             VARCHAR2(50),
                       l_ar_rate_adjustments_all            VARCHAR2(50),
                       l_ar_receivable_apps_all             VARCHAR2(50),
                       g_reporting_level                    VARCHAR2(50),
                       g_reporting_entity_id                NUMBER,
                       g_set_of_books_id                    NUMBER,
                       g_chart_of_accounts_id               NUMBER,
                       g_gl_date_from                       DATE,
                       g_gl_date_to                         DATE,
                       g_period_name                        VARCHAR2(15),
                       g_posting_status                     VARCHAR2(15),
                       g_functional_currency                VARCHAR2(15),
                       g_out_of_balance_only                VARCHAR2(1),
                       g_max_gl_date                        DATE
                       );

  var_tname var_t;

TYPE flex_table IS
     table of FND_FLEX_VALUES.flex_value%TYPE
     index by binary_integer;

  detail flex_table;


/*========================================================================+
  Function which returns the global variable g_reporting_level
 ========================================================================+*/

FUNCTION get_reporting_level return VARCHAR2;

/*========================================================================+
  Function which returns the global variable g_reporting_entity_id
 ========================================================================*/

FUNCTION get_reporting_entity_id return NUMBER;

/*========================================================================+
  Function which returns the global variable g_set_of_books_id
 ========================================================================*/

FUNCTION get_set_of_books_id return NUMBER;

/*========================================================================+
  Function which returns the global variable g_chart_of_accounts_id
 ========================================================================*/

FUNCTION get_chart_of_accounts_id return NUMBER;

/*========================================================================+
 Function which returns the global variable g_gl_date_from
 ========================================================================*/

FUNCTION get_gl_date_from return DATE;

/*========================================================================+
  Function which returns the global variable g_gl_date_to
 ========================================================================*/

FUNCTION get_gl_date_to return DATE;

/*========================================================================+
  Function which returns the global variable g_posting_status
 ========================================================================*/

FUNCTION get_posting_status return VARCHAR2;

/*========================================================================+
  Function which returns the maximum possible gl_date
 ========================================================================*/

FUNCTION get_max_gl_date return DATE;

/*========================================================================+
  Function which returns the period_name
 ========================================================================*/

FUNCTION get_period_name return VARCHAR2;

/*========================================================================+
  Function which returns the functional currency
 ========================================================================*/

FUNCTION get_functional_currency return VARCHAR2;

/*========================================================================+
  Function which returns the value of g_out_of_balance_only
 ========================================================================*/

FUNCTION get_out_of_balance_only return VARCHAR2;

/*========================================================================+
 | PUBLIC PROCEDURE GET_DETAIL_ACCOUNTS                                   |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to generate the list of account segments to   |
 |   be queried for a given summary account                               |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 16-NOV-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/

 PROCEDURE get_detail_accounts(p_value_set_id       IN     NUMBER,
                               p_parent_value       IN     VARCHAR2,
                               p_code_combinations  OUT    NOCOPY VARCHAR2 );


/*========================================================================+
 | PUBLIC PROCEDURE INIT                                                  |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to initialize the reporting context. This     |
 |   procedure sets the table names to be used in the queries.            |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 16-NOV-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/

 PROCEDURE INIT(p_set_of_books_id IN NUMBER);

 FUNCTION format_string(p_string varchar2) return varchar2;

 PROCEDURE aradj_journal_load_xml (
          p_reporting_level      IN   VARCHAR2,
          p_reporting_entity_id  IN   NUMBER,
          p_sob_id               IN   NUMBER,
          p_coa_id               IN   NUMBER,
          p_co_seg_low           IN   VARCHAR2,
          p_co_seg_high          IN   VARCHAR2,
          p_gl_date_from         IN   VARCHAR2,
          p_gl_date_to           IN   VARCHAR2,
          p_posting_status       IN   VARCHAR2,
          p_gl_account_low       IN   VARCHAR2,
          p_gl_account_high      IN   VARCHAR2,
          p_summary_account      IN   NUMBER,
          p_receivable_mode      IN   VARCHAR2,
          p_result               OUT NOCOPY CLOB) ;

 PROCEDURE arunapp_journal_load_xml (
          p_reporting_level       IN   VARCHAR2,
          p_reporting_entity_id   IN   NUMBER,
          p_sob_id                IN   NUMBER,
          p_coa_id                IN   NUMBER,
          p_co_seg_low            IN   VARCHAR2,
          p_co_seg_high           IN   VARCHAR2,
          p_gl_date_from          IN   VARCHAR2,
          p_gl_date_to            IN   VARCHAR2,
          p_posting_status        IN   VARCHAR2,
          p_gl_account_low        IN   VARCHAR2,
          p_gl_account_high       IN   VARCHAR2,
          p_summary_account       IN   NUMBER,
          p_receivable_mode       IN   VARCHAR2,
          p_result                OUT NOCOPY CLOB) ;

 PROCEDURE arapp_journal_load_xml (
          p_reporting_level       IN   VARCHAR2,
          p_reporting_entity_id   IN   NUMBER,
          p_sob_id                IN   NUMBER,
          p_coa_id                IN   NUMBER,
          p_co_seg_low            IN   VARCHAR2,
          p_co_seg_high           IN   VARCHAR2,
          p_gl_date_from          IN   VARCHAR2,
          p_gl_date_to            IN   VARCHAR2,
          p_posting_status        IN   VARCHAR2,
          p_gl_account_low        IN   VARCHAR2,
          p_gl_account_high       IN   VARCHAR2,
          p_summary_account       IN   NUMBER,
          p_receivable_mode       IN   VARCHAR2,
          p_result                OUT NOCOPY CLOB) ;

 PROCEDURE arcm_journal_load_xml (
          p_reporting_level       IN   VARCHAR2,
          p_reporting_entity_id   IN   NUMBER,
          p_sob_id                IN   NUMBER,
          p_coa_id                IN   NUMBER,
          p_co_seg_low            IN   VARCHAR2,
          p_co_seg_high           IN   VARCHAR2,
          p_gl_date_from          IN   VARCHAR2,
          p_gl_date_to            IN   VARCHAR2,
          p_posting_status        IN   VARCHAR2,
          p_gl_account_low        IN   VARCHAR2,
          p_gl_account_high       IN   VARCHAR2,
          p_summary_account       IN   NUMBER,
          p_receivable_mode       IN   VARCHAR2,
          p_result                OUT NOCOPY CLOB) ;

 PROCEDURE arglrecon_load_xml(
          p_reporting_level      IN   VARCHAR2,
          p_reporting_entity_id  IN   NUMBER,
          p_sob_id               IN   NUMBER,
          p_coa_id               IN   NUMBER,
          p_out_of_balance_only  IN   VARCHAR2,
          p_co_seg_low           IN   VARCHAR2,
          p_co_seg_high          IN   VARCHAR2,
          p_period_name          IN   VARCHAR2,
          p_gl_account_low       IN   VARCHAR2,
          p_gl_account_high      IN   VARCHAR2,
          p_summary_account      IN   VARCHAR2,
          p_result               OUT  NOCOPY CLOB );
END ARP_RECON_REP;

 

/
