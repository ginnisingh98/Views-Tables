--------------------------------------------------------
--  DDL for Package AR_CALC_AGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CALC_AGING" AUTHID CURRENT_USER AS
/* $Header: ARRECONS.pls 120.6 2006/06/07 08:33:01 salladi ship $ */

/* Global variables */

ca_sob_type  VARCHAR2(1) := 'P';
g_reporting_entity_id  NUMBER;

/*========================================================================+
  Function which returns the global variable g_reporting_entity_id
 ========================================================================*/

FUNCTION get_reporting_entity_id return NUMBER;

PROCEDURE initialize;

FUNCTION flex_sql(
        p_application_id in number,
        p_id_flex_code in varchar2,
        p_id_flex_num in number default null,
        p_table_alias in varchar2,
        p_mode in varchar2,
        p_qualifier in varchar2,
        p_function in varchar2 default null,
        p_operand1 in varchar2 default null,
        p_operand2 in varchar2 default null) return varchar2;



FUNCTION get_value(
        p_application_id in number,
        p_id_flex_code in varchar2,
        p_id_flex_num in number default NULL,
        p_qualifier in varchar2,
        p_ccid in number) return varchar2;



FUNCTION get_description(
        p_application_id in number,
        p_id_flex_code in varchar2,
        p_id_flex_num in number default NULL,
        p_qualifier in varchar2,
        p_data in varchar2) return varchar2;

/* Bug 3940958
   AR Reconciliation Process Enhancements */
PROCEDURE aging_as_of(
                              p_as_of_date_from          IN DATE,
                              p_as_of_date_to            IN DATE,
                              p_reporting_level          IN VARCHAR2,
                              p_reporting_entity_id      IN NUMBER,
                              p_co_seg_low               IN VARCHAR2,
                              p_co_seg_high              IN VARCHAR2,
                              p_coa_id                   IN NUMBER,
                              p_begin_bal                OUT NOCOPY NUMBER,
                              p_end_bal                  OUT NOCOPY NUMBER,
                              p_acctd_begin_bal          OUT NOCOPY NUMBER,
                              p_acctd_end_bal            OUT NOCOPY NUMBER);

PROCEDURE adjustment_register(p_gl_date_low            IN  DATE ,
                              p_gl_date_high           IN  DATE,
                              p_reporting_level        IN  VARCHAR2,
                              p_reporting_entity_id    IN  NUMBER,
                              p_co_seg_low             IN  VARCHAR2,
                              p_co_seg_high            IN  VARCHAR2,
                              p_coa_id                 IN  NUMBER,
                              p_fin_chrg_amount        OUT NOCOPY NUMBER,
                              p_fin_chrg_acctd_amount  OUT NOCOPY NUMBER,
			      p_adj_amount             OUT NOCOPY NUMBER,
                              p_adj_acctd_amount       OUT NOCOPY NUMBER,
                              p_guar_amount            OUT NOCOPY NUMBER,
                              p_guar_acctd_amount      OUT NOCOPY NUMBER,
                              p_dep_amount             OUT NOCOPY NUMBER,
                              p_dep_acctd_amount       OUT NOCOPY NUMBER,
                              p_endorsmnt_amount       OUT NOCOPY NUMBER,
                              p_endorsmnt_acctd_amount OUT NOCOPY NUMBER );

PROCEDURE transaction_register(p_gl_date_low              IN  DATE,
                               p_gl_date_high             IN  DATE,
                               p_reporting_level          IN  VARCHAR2,
                               p_reporting_entity_id      IN  NUMBER,
                               p_co_seg_low               IN  VARCHAR2,
                               p_co_seg_high              IN  VARCHAR2,
                               p_coa_id                   IN  NUMBER,
                               p_non_post_amount          OUT NOCOPY NUMBER,
                               p_non_post_acctd_amount    OUT NOCOPY NUMBER,
                               p_post_amount              OUT NOCOPY NUMBER ,
                               p_post_acctd_amount        OUT NOCOPY NUMBER );

PROCEDURE rounding_diff(l_gl_date_low   IN  DATE,
                        l_gl_date_high  IN  DATE,
                        l_rounding_diff OUT NOCOPY NUMBER ) ;

PROCEDURE cash_receipts_register(p_gl_date_low           IN  DATE ,
                                 p_gl_date_high          IN  DATE,
                                 p_reporting_level       IN  VARCHAR2,
                                 p_reporting_entity_id   IN  NUMBER,
                                 p_co_seg_low            IN  VARCHAR2,
                                 p_co_seg_high           IN  VARCHAR2,
                                 p_coa_id                IN  NUMBER,
                                 p_unapp_amount          OUT NOCOPY NUMBER,
                                 p_unapp_acctd_amount    OUT NOCOPY NUMBER,
                                 p_acc_amount            OUT NOCOPY NUMBER,
                                 p_acc_acctd_amount      OUT NOCOPY NUMBER,
                                 p_claim_amount          OUT NOCOPY NUMBER,
                                 p_claim_acctd_amount    OUT NOCOPY NUMBER,
                                 p_prepay_amount         OUT NOCOPY NUMBER,
                                 p_prepay_acctd_amount   OUT NOCOPY NUMBER,
                                 p_app_amount            OUT NOCOPY NUMBER,
                                 p_app_acctd_amount      OUT NOCOPY NUMBER,
                                 p_edisc_amount          OUT NOCOPY NUMBER,
                                 p_edisc_acctd_amount    OUT NOCOPY NUMBER,
                                 p_unedisc_amount        OUT NOCOPY NUMBER,
                                 p_unedisc_acctd_amount  OUT NOCOPY NUMBER,
                                 p_cm_gain_loss          OUT NOCOPY NUMBER,
                                 p_on_acc_cm_ref_amount   OUT NOCOPY NUMBER,        /*bug4173702*/
                                 p_on_acc_cm_ref_acctd_amount OUT NOCOPY NUMBER  ) ;

PROCEDURE invoice_exceptions( p_gl_date_low                 IN  DATE,
                              p_gl_date_high                IN  DATE,
                              p_reporting_level             IN  VARCHAR2,
                              p_reporting_entity_id         IN  NUMBER,
                              p_co_seg_low                  IN  VARCHAR2,
                              p_co_seg_high                 IN  VARCHAR2,
                              p_coa_id                      IN  NUMBER,
                              p_post_excp_amount            OUT NOCOPY NUMBER,
                              p_post_excp_acctd_amount      OUT NOCOPY NUMBER,
                              p_nonpost_excp_amount         OUT NOCOPY NUMBER,
                              p_nonpost_excp_acctd_amount   OUT NOCOPY NUMBER);

FUNCTION begin_or_end_bal(  p_gl_date                     IN DATE,
                            p_gl_date_closed              IN DATE,
                            p_activity_date               IN DATE,
                            p_as_of_date                  IN DATE
                          )RETURN NUMBER;

PROCEDURE journal_reports(  p_gl_date_low                 IN  DATE,
                            p_gl_date_high                IN  DATE,
                            p_reporting_level             IN  VARCHAR2,
                            p_reporting_entity_id         IN  NUMBER,
                            p_co_seg_low                  IN  VARCHAR2,
                            p_co_seg_high                 IN  VARCHAR2,
                            p_coa_id                      IN  NUMBER,
                            p_sales_journal_amt           OUT NOCOPY NUMBER,
                            p_sales_journal_acctd_amt     OUT NOCOPY NUMBER,
                            p_adj_journal_amt             OUT NOCOPY NUMBER,
                            p_adj_journal_acctd_amt       OUT NOCOPY NUMBER,
                            p_app_journal_amt             OUT NOCOPY NUMBER,
                            p_app_journal_acctd_amt       OUT NOCOPY NUMBER,
                            p_unapp_journal_amt           OUT NOCOPY NUMBER,
                            p_unapp_journal_acctd_amt     OUT NOCOPY NUMBER,
                            p_cm_journal_acctd_amt        OUT NOCOPY NUMBER);

PROCEDURE get_report_heading ( p_reporting_level          IN  VARCHAR2,
                               p_reporting_entity_id      IN  NUMBER,
                               p_set_of_books_id          IN  NUMBER,
                               p_sob_name                 OUT NOCOPY VARCHAR2,
                               p_functional_currency      OUT NOCOPY VARCHAR2,
                               p_coa_id                   OUT NOCOPY NUMBER,
                               p_precision                OUT NOCOPY NUMBER,
                               p_sysdate                  OUT NOCOPY VARCHAR2,
                               p_organization             OUT NOCOPY VARCHAR2,
                               p_bills_receivable_flag    OUT NOCOPY VARCHAR2);
END ar_calc_aging ;

 

/
