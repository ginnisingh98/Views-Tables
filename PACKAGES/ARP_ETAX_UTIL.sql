--------------------------------------------------------
--  DDL for Package ARP_ETAX_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ETAX_UTIL" AUTHID CURRENT_USER AS
/* $Header: AREBTUTS.pls 120.19.12010000.4 2008/11/19 09:41:50 ankuagar ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
SUBTYPE ae_doc_rec_type   IS ARP_ACCT_MAIN.ae_doc_rec_type;
SUBTYPE ae_sys_rec_type   IS ARP_ACCT_MAIN.ae_sys_rec_type;

  g_gt_id NUMBER;

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/
--    temp_exception EXCEPTION;

/*========================================================================
 | PUBLIC PROCEDURE populate_ebt_gt
 |
 | DESCRIPTION
 |    This procedure populates the ebt GT tables that are used by
 |    autoinvoice for tax calculations.  The procedure will be called
 |    twice - once for INV and a second time for CM (regular) data.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_request_id    IN      Request_id of import job
 |      p_phase         IN      Indicates 'INV' or 'CM' phase
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-FEB-2005           MRAYMOND          Created
 | 11-SEP-2006           MRAYMOND    5385324 - added p_synch_line_data
 |                                      parameter to synchronize_for_doc_seq
 | 15-JAN-2008           MRAYMOND    6743811 - added p_return_status
 |                                      to calculate_tax_int
 *=======================================================================*/
PROCEDURE clear_ebt_gt;

PROCEDURE validate_tax_int(p_return_status OUT NOCOPY NUMBER,
                            p_called_from_AI IN VARCHAR2 DEFAULT 'N');

PROCEDURE calculate_tax_int(p_return_status OUT NOCOPY NUMBER,
                            p_called_from_AI IN VARCHAR2 DEFAULT 'N');

PROCEDURE get_country_and_legal_ent (
                p_org_id      IN  NUMBER,
                p_def_country OUT NOCOPY VARCHAR2,
                p_legal_ent   OUT NOCOPY NUMBER);

PROCEDURE synchronize_for_doc_seq(
                p_trx_id      IN NUMBER,
                p_return_status  OUT NOCOPY NUMBER,
                p_request_id  IN NUMBER DEFAULT NULL,
                p_sync_line_data IN VARCHAR2 DEFAULT 'N');
/*Bug 6806843.Removing the procedure synchronize_for_auto_trxnum. See bug for
details */


PROCEDURE global_document_update(p_customer_trx_id IN NUMBER,
                                 p_request_id      IN NUMBER,
                                 p_action          IN VARCHAR2);

PROCEDURE get_default_tax_classification(
              p_ship_to_site_use_id        IN     NUMBER DEFAULT NULL,
              p_bill_to_site_use_id        IN     NUMBER DEFAULT NULL,
              p_inv_item_id                IN     NUMBER DEFAULT NULL,
              p_org_id                     IN     NUMBER,
              p_sob_id                     IN     NUMBER,
              p_trx_date                   IN     DATE,
              p_trx_type_id                IN     NUMBER,
              p_cust_trx_id                IN     NUMBER,
              p_cust_trx_line_id           IN     NUMBER DEFAULT NULL,
              p_customer_id                IN     NUMBER DEFAULT NULL,
              p_memo_line_id               IN     NUMBER DEFAULT NULL,
              p_salesrep_id                IN     NUMBER DEFAULT NULL,
              p_warehouse_id               IN     NUMBER DEFAULT NULL,
              p_entity_code                IN     VARCHAR2,
              p_event_class_code           IN     VARCHAR2,
              p_function_short_name        IN     VARCHAR2,
              p_tax_classification_code    OUT    NOCOPY VARCHAR2);

/* Public procedure defined for import processes (AI, API, Copy)
   Specifically designed to grab the tax_classif from
   ZX_LINES_DET_FACTORS and stamp it on the imported lines. */

PROCEDURE set_default_tax_classification(
              p_request_id  IN NUMBER,
              p_phase       IN VARCHAR2 DEFAULT 'INV');

FUNCTION get_event_information (p_customer_trx_id IN NUMBER,
                                p_action IN VARCHAR2,
                                p_event_class_code OUT NOCOPY VARCHAR2,
                                p_event_type_code OUT NOCOPY VARCHAR2)
                                RETURN BOOLEAN;

PROCEDURE build_ar_tax_lines(
                 p_customer_trx_id  IN  NUMBER,
                 p_rows_inserted    OUT NOCOPY NUMBER);

PROCEDURE delete_tax_lines_from_ar(
                 p_customer_trx_id  IN  NUMBER);

FUNCTION tax_curr_round(p_amount    IN NUMBER,
                        p_trx_currency_code IN VARCHAR2 default null,
                        p_precision IN NUMBER,
                        p_min_acct_unit IN NUMBER,
                        p_rounding_rule IN VARCHAR2 default 'NEAREST',
                        p_autotax_flag  IN VARCHAR2 default 'Y')
               RETURN NUMBER;

/* Used to prorate tax across recoverable invoice lines.
  INPUT:
    p_adj_id     = adjustment or receipt id         (reqd)
    p_target_id  = invoice customer_trx_id          (reqd)
    p_target_line_id = invoice customer_trx_line_id (optional)
    p_amount     = total adjustment or discount     (reqd)
    p_apply_date = date effective for application or adj  (reqd)
    p_mode       = INV, LINE, or TAX                      (reqd)
                    INV  = zero out
                    LINE = prorate LINE and TAX
                    TAX  = tax only
    p_upd_adj_and_ps = Y/A/Null.  Y means we will update   (optional)
                       the adj and ps rows (they were already
                       saved with previous values)
                       A means update adj only (ps handled locally)
    p_quote          = Y/N/Null.  Y means we will call etax in
                       quote mode.  No tax will be stored in repository.
                       We will have to fetch the estimated tax back
                       from ZX_DETAIL_TAX_LINES_GT instead of ZX_LINES.

              NOTE:  Per eTax, we should not call in quote mode once
               tax has been calculated on this transaction.

  OUTPUT:
    p_gt_id         = sequence ID assigned in GT table for
                      prorating accounting (needed for arp_acct_Main call)
    p_prorated_line = portion of p_amount allocated to LINE
    p_prorated_tax  = portion of p_amount allocated to TAX
*/
PROCEDURE prorate_recoverable(p_adj_id         IN NUMBER,
                              p_target_id      IN NUMBER,
                              p_target_line_id IN NUMBER,
                              p_amount         IN NUMBER,
                              p_apply_date     IN DATE,
                              p_mode           IN VARCHAR2,
                              p_upd_adj_and_ps IN VARCHAR2,
                              p_gt_id          IN OUT NOCOPY NUMBER,
                              p_prorated_line  IN OUT NOCOPY NUMBER,
                              p_prorated_tax   IN OUT NOCOPY NUMBER,
                              p_quote          IN VARCHAR2 DEFAULT 'N');

/* 5677984 -
   Used to prorate tax across recoverable invoice lines.
   THIS VERSION SPECIFIC TO RECEIPT APPLICATIONS/UNAPPLICATIONS
  INPUT:
    p_adj_id     = adjustment or receipt id         (reqd)
    p_target_id  = invoice customer_trx_id          (reqd)
    p_target_line_id = invoice customer_trx_line_id (optional)
    p_amount     = total adjustment or discount     (reqd)
    p_apply_date = date effective for application or adj  (reqd)
    p_mode       = INV, LINE, or TAX                      (reqd)
                    INV  = zero out
                    LINE = prorate LINE and TAX
                    TAX  = tax only
    p_upd_adj_and_ps = Y/A/Null.  Y means we will update   (optional)
                       the adj and ps rows (they were already
                       saved with previous values)
                       A means update adj only (ps handled locally)
    p_quote          = Y/N/Null.  Y means we will call etax in
                       quote mode.  No tax will be stored in repository.
                       We will have to fetch the estimated tax back
                       from ZX_DETAIL_TAX_LINES_GT instead of ZX_LINES.

              NOTE:  Per eTax, we should not call in quote mode once
               tax has been calculated on this transaction.

  OUTPUT:
    p_gt_id         = sequence ID assigned in GT table for
                      prorating accounting (needed for arp_acct_Main call)
    p_prorated_line = portion of p_amount allocated to LINE
    p_prorated_tax  = portion of p_amount allocated to TAX

  BOTH:
    p_ra_app_id = the application_id of the current APP or UNAPP
                       row.  If passed in, we will honor it.  If not
                       passed, we will get an ID and return it.

NOTE:  The original version of prorate_recoverable calls this new
   version behind the scenes with -1 for application_id.  That prevents
   assignment of a new ID and maintains backward compatibility for
   adjustments.
*/
PROCEDURE prorate_recoverable(p_adj_id         IN NUMBER,
                              p_target_id      IN NUMBER,
                              p_target_line_id IN NUMBER,
                              p_amount         IN NUMBER,
                              p_apply_date     IN DATE,
                              p_mode           IN VARCHAR2,
                              p_upd_adj_and_ps IN VARCHAR2,
                              p_gt_id          IN OUT NOCOPY NUMBER,
                              p_prorated_line  IN OUT NOCOPY NUMBER,
                              p_prorated_tax   IN OUT NOCOPY NUMBER,
                              p_quote          IN VARCHAR2 DEFAULT 'N',
                              p_ra_app_id IN OUT NOCOPY NUMBER);

PROCEDURE adjust_for_inclusive_tax(p_trx_id     IN NUMBER,
                                   p_request_id IN NUMBER   DEFAULT NULL,
                                   p_phase      IN VARCHAR2 DEFAULT NULL);

PROCEDURE set_recoverable(p_trx_id IN NUMBER,
                          p_request_id IN NUMBER   DEFAULT NULL,
                          p_phase      IN VARCHAR2 DEFAULT NULL);

/* Function to call etax for tax-related accounts.  Currently
   only fetches tax and interim accounts.

   Takes tax trx_line_id, date, and 'TAX' or 'INTERIM' and returns
   ccid or -1 (no errors)

   p_subject_table takes either 'TAX_LINE' or 'TAX_RATE' */

/* actually supports a list of desired_account values but all
   except TAX and INTERIM return -1 at this time */
FUNCTION  get_tax_account (p_subject_id IN NUMBER,
                           p_gl_date    IN DATE,
                           p_desired_account IN VARCHAR2,
                           p_subject_table IN VARCHAR2 DEFAULT 'TAX_LINE')
     RETURN NUMBER;

PROCEDURE calc_applied_and_remaining ( p_amt            in number
                               ,p_receipt_id            in number
                               ,p_apply_date            in date
                               ,p_trx_id                in number
                               ,p_mode                  in varchar2
                               ,p_rule_set_id           in number
                               ,p_currency              in varchar2
                               ,p_line_remaining        in out NOCOPY number
                               ,p_line_tax_remaining    in out NOCOPY number
                               ,p_freight_remaining     in out NOCOPY number
                               ,p_charges_remaining     in out NOCOPY number
                               ,p_line_applied          out NOCOPY number
                               ,p_line_tax_applied      out NOCOPY number
                               ,p_freight_applied       out NOCOPY number
                               ,p_charges_applied       out NOCOPY number
                               ,p_rec_app_id             in out NOCOPY number
                               );

PROCEDURE distribute_recoverable(p_rec_app_id     IN NUMBER,
                                 p_gt_id          IN NUMBER);

FUNCTION  get_discount_rate(p_trx_id              IN NUMBER)
    RETURN NUMBER;

PROCEDURE validate_for_tax (p_request_id IN NUMBER);

END ARP_ETAX_UTIL;

/
