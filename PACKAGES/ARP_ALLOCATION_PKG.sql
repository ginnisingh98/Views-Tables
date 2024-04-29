--------------------------------------------------------
--  DDL for Package ARP_ALLOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ALLOCATION_PKG" AUTHID CURRENT_USER AS
/* $Header: ARALLOCS.pls 120.10 2005/07/26 15:19:25 naneja ship $ */

/*=======================================================================+
 |  Public Variables and Record Types
 +=======================================================================*/
SUBTYPE ae_doc_rec_type   IS ARP_ACCT_MAIN.ae_doc_rec_type;
SUBTYPE ae_event_rec_type IS ARP_ACCT_MAIN.ae_event_rec_type;
SUBTYPE ae_sys_rec_type   IS ARP_ACCT_MAIN.ae_sys_rec_type;
SUBTYPE ae_line_rec_type  IS ARP_ACCT_MAIN.ae_line_rec_type;
SUBTYPE ae_line_tbl_type  IS ARP_ACCT_MAIN.ae_line_tbl_type;
SUBTYPE ae_curr_rec_type  IS ARP_ACCT_MAIN.ae_curr_rec_type;
SUBTYPE ae_rule_rec_type  IS ARP_ACCT_MAIN.ae_app_rule_rec_type;

adj_code_combination_id ar_adjustments.code_combination_id%TYPE;

--Cache counter to store substituted ccid in a global table
cache_ctr BINARY_INTEGER := 0;

--Record type definition Stores key and accounts derived using flexbuilder
TYPE flex_parms_rec_type IS RECORD
  (
    coa_id       gl_sets_of_books.chart_of_accounts_id%TYPE              ,
    orig_ccid    ar_system_parameters_all.code_combination_id_round%TYPE ,
    subs_ccid    ar_system_parameters_all.code_combination_id_round%TYPE ,
    actual_ccid  ar_system_parameters_all.code_combination_id_round%TYPE
  );

--Table type declaration which stores key for accounts derived using flexbuilder

TYPE flex_parms_tbl_type IS TABLE OF flex_parms_rec_type
   INDEX BY BINARY_INTEGER;

--Actual global table which stores gain, loss, net expense or revenue tax accounts
--with balancing segment matching receivable of Invoice

flex_parms_tbl flex_parms_tbl_type;

--Exception handler which raises an error if unable to derive a valid substituted ccid
--for gain, loss, round or override net expense or tax accounts from location or tax codes

flex_subs_ccid_error    EXCEPTION;
invalid_ccid_error      EXCEPTION;
rounding_error          EXCEPTION;
invalid_allocation_base EXCEPTION;
ram_api_error           EXCEPTION;

/*------------------------------------------------------------+
 |  Allocation Control Record Type                            |
 +------------------------------------------------------------*/
TYPE ae_alloc_rec_type IS RECORD (
     ae_account_class              ra_cust_trx_line_gl_dist.account_class%TYPE        ,
     ae_customer_trx_id            ra_customer_trx_lines.customer_trx_id%TYPE         ,
     ae_customer_trx_line_id       ra_customer_trx_lines.customer_trx_line_id%TYPE    ,
     ae_link_to_cust_trx_line_id   ra_customer_trx_lines.link_to_cust_trx_line_id%TYPE,
     ae_tax_type                   VARCHAR2(3)                                        ,
     ae_code_combination_id        ra_cust_trx_line_gl_dist.code_combination_id%TYPE  ,
     ae_collected_tax_ccid         ra_cust_trx_line_gl_dist.collected_tax_ccid%TYPE   ,
     ae_line_amount                NUMBER                                             ,
     ae_amount                     NUMBER                                             ,
     ae_acctd_amount               NUMBER                                             ,
     ae_tax_group_code_id          NUMBER                                             ,
     ae_tax_id                     NUMBER                                             ,
     ae_taxable_amount             NUMBER                                             ,
     ae_taxable_acctd_amount       NUMBER                                             ,
     ae_adj_ccid                   ar_vat_tax.adj_ccid%TYPE                           ,
     ae_edisc_ccid                 ar_vat_tax.edisc_ccid%TYPE                         ,
     ae_unedisc_ccid               ar_vat_tax.unedisc_ccid%TYPE                       ,
     ae_finchrg_ccid               ar_vat_tax.finchrg_ccid%TYPE                       ,
     ae_adj_non_rec_tax_ccid       ar_vat_tax.adj_non_rec_tax_ccid%TYPE               ,
     ae_edisc_non_rec_tax_ccid     ar_vat_tax.edisc_non_rec_tax_ccid%TYPE             ,
     ae_unedisc_non_rec_tax_ccid   ar_vat_tax.unedisc_non_rec_tax_ccid%TYPE           ,
     ae_finchrg_non_rec_tax_ccid   ar_vat_tax.finchrg_non_rec_tax_ccid%TYPE           ,
     ae_override_ccid1             ra_cust_trx_line_gl_dist.code_combination_id%TYPE  , --edisc, adj
     ae_override_ccid2             ra_cust_trx_line_gl_dist.code_combination_id%TYPE  , --unedisc
     ae_tax_link_id                ar_distributions.tax_link_id%TYPE                  ,
     ae_tax_link_id_act            ar_distributions.tax_link_id%TYPE                  ,
     ae_pro_amt                    NUMBER                                             ,
     ae_pro_acctd_amt              NUMBER                                             ,
     ae_pro_frt_chrg_amt           NUMBER                                             ,
     ae_pro_frt_chrg_acctd_amt     NUMBER                                             ,
     ae_pro_taxable_amt            NUMBER                                             ,
     ae_pro_taxable_acctd_amt      NUMBER                                             ,
     ae_pro_def_tax_amt            NUMBER                                             ,
     ae_pro_def_tax_acctd_amt      NUMBER                                             ,
     ae_summarize_flag             VARCHAR2(1)                                        ,
     ae_counted_flag               VARCHAR2(1)                                        ,
     ae_autotax                    ra_customer_trx_lines.autotax%TYPE
);
/*----------------------------------------------------------------------+
 | Table which stores details for Invoice Revenue and Tax distributions |
 | and their tax code details.                                          |
 +----------------------------------------------------------------------*/
TYPE ae_alloc_tbl_type IS TABLE of ae_alloc_rec_type
  INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------+
 |  Invoice Lines Revenue amounts and revenue accounted amount totals |
 +--------------------------------------------------------------------*/
TYPE ae_rev_total_rec  IS RECORD (
     ae_inv_line           ra_customer_trx_lines.customer_trx_line_id%TYPE,
     ae_sum_rev_amt        NUMBER,
     ae_sum_rev_acctd_amt  NUMBER,
     ae_count              NUMBER
);

/*---------------------------------------------------------------------+
 | Table which stores the Invoice lines revenue amounts and accounted  |
 | amounts sum totals                                                  |
 +---------------------------------------------------------------------*/
TYPE ae_rev_total_type IS TABLE of ae_rev_total_rec
  INDEX BY BINARY_INTEGER;

/*--------------------------------------------------------------------------+
 |  Table which stores link id and revenue allocated totals for line amounts|
 +--------------------------------------------------------------------------*/
TYPE ae_link_rec  IS RECORD (
     ae_tax_link_id             NUMBER,
     ae_inv_line                ra_customer_trx_lines.customer_trx_line_id%TYPE,
     ae_sum_alloc_amt           NUMBER,
     ae_sum_alloc_acctd_amt     NUMBER,
     ae_run_amt_tot             NUMBER,
     ae_run_acctd_amt_tot       NUMBER,
     ae_run_pro_amt_tot         NUMBER,
     ae_run_pro_acctd_amt_tot   NUMBER,
     ae_def_flg                 BOOLEAN,
     ae_tax_id                  NUMBER,
     ae_tax_type                VARCHAR2(3)
);

/*---------------------------------------------------------------------+
 | Table which stores the link id and revenu allocated totals          |
 +---------------------------------------------------------------------*/
TYPE ae_link_tbl_type IS TABLE of ae_link_rec
  INDEX BY BINARY_INTEGER;

/* ==========================================================================================
 | PROCEDURE Allocate_Tax
 |
 | DESCRIPTION
 |      This procedure is the cover routine which will tax account for
 |      discounts, adjustments and finance charges. The rule details
 |      and document, event details are passed to this procedure which will
 |      help determine the manner in which discounts and adjustments are
 |      allocated over specific accounts based on Activity Rule.
 |
 | PARAMETERS
 |      p_ae_doc_rec            IN      Document record
 |      p_ae_event_rec          IN      Event record
 |      p_app_rec               IN      Application record for discounts
 |      p_adj_rec               IN      Adjustment record for adjustments
 |      p_rule_rec              IN      Rule record
 |      p_ae_line_tbl           OUT     Table with accounting for discounts or adjustments
 * ==========================================================================================*/
PROCEDURE Allocate_Tax ( p_ae_doc_rec           IN      ae_doc_rec_type                     ,
                         p_ae_event_rec         IN      ae_event_rec_type                   ,
                         p_ae_rule_rec          IN      ae_rule_rec_type                    ,
                         p_app_rec              IN      ar_receivable_applications%ROWTYPE  ,
                         p_cust_inv_rec         IN      ra_customer_trx%ROWTYPE             ,
                         p_adj_rec              IN      ar_adjustments%ROWTYPE              ,
                         p_ae_ctr               IN OUT NOCOPY  BINARY_INTEGER                      ,
                         p_ae_line_tbl          IN OUT NOCOPY  ae_line_tbl_type                    ,
                         p_br_cust_trx_line_id  IN      ra_customer_trx_lines.customer_trx_line_id%TYPE default NULL,
                         p_simul_app            IN      VARCHAR2 default NULL               ,
                         --{HYUDETUPT
                         p_from_llca_call       IN      VARCHAR2 DEFAULT 'N',
                         p_gt_id                IN      NUMBER   DEFAULT NULL,
                         -- this flag is introduced to indicate if the application need conversion
                         p_inv_cm               IN      VARCHAR2 DEFAULT 'I'
                          ) ;

FUNCTION Retain_Neg_Ind(p_rowid IN ROWID) RETURN NUMBER;

FUNCTION Get_Tax_Count(p_invoice_line_id IN NUMBER) RETURN NUMBER;

FUNCTION Set_Adj_CCID(p_action IN VARCHAR2) RETURN NUMBER;

PROCEDURE Substitute_Ccid(p_coa_id        IN  gl_sets_of_books.chart_of_accounts_id%TYPE        ,
                          p_original_ccid IN  ar_system_parameters.code_combination_id_gain%TYPE,
                          p_subs_ccid     IN  ar_system_parameters.code_combination_id_gain%TYPE,
                          p_actual_ccid   OUT NOCOPY ar_system_parameters.code_combination_id_gain%TYPE);
END ARP_ALLOCATION_PKG;

 

/
