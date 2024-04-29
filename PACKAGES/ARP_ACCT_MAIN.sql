--------------------------------------------------------
--  DDL for Package ARP_ACCT_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ACCT_MAIN" AUTHID CURRENT_USER AS
/* $Header: ARTACCMS.pls 120.10.12010000.3 2010/07/23 02:56:27 nemani ship $ */

--
-- Declare PUBLIC Data Types and Variables
--

--
-- Accounting Entry Document Type Record (Standard)
--
TYPE ae_doc_rec_type IS RECORD (
  document_type           varchar2(30)	                    , -- E.g. INVOICE, RECEIPT, ADJUSTMENT
  document_id         	  number                            , -- E.g. Invoice Id, Receipt Id
  accounting_entity_level varchar2(30)                      , -- ALL or ONE entity.
  source_table            ar_distributions.source_table%TYPE, -- E.g. RA(ar_receivable_applications)
  source_id               NUMBER                            , -- E.g. receivable_application_id
  source_id_old           NUMBER                            , -- E.g. Old receivable_application_id
                                                              -- for Reversals or source_id_secondary
                                                              -- UNAPP, and override of ccid for adjustments
  other_flag              varchar2(10), -- Indicates what source_id_old is used
                                        -- for, e.g. REVERSE or to populate
                                        -- source_id_secondary for PAIRED UNAPP
                                        -- records or OVERRIDE for adjustment ccid
  miscel1                 varchar2(15), --miscel list of variables below were required
  miscel2                 NUMBER      , --specifically for autoreceipts, however in the
  miscel3                 varchar2(30), --future these may be used for any entity accounting
  miscel4                 DATE        , --record based on type declaration
  miscel5                 NUMBER      ,
  miscel6                 NUMBER      ,
  miscel7                 NUMBER      ,
  miscel8                 NUMBER      ,
  event                   VARCHAR2(30), --UNELIMINATE_RISK used to reversal tax and state
                                        --that the MATURITY_DATE
  deferred_tax            VARCHAR2(1) , --Bills Receivable used by housekeeper to indicate
                                        --that deferred tax has already been moved at Maturity
                                        --Date event
  called_from             VARCHAR2(30), --Parent routine call, used to prevent initialization
                                        --of rule amounts in tax accounting routine when called
                                        --from Wrapper routine
  pay_sched_upd_yn        VARCHAR2(1),  --A "Y" indicates that the payment schedule has been updated
                                        --before the call to the accounting engine
  pay_sched_upd_cm_yn     VARCHAR2(1),  --A "Y" indicates that the payment schedule has been updated
                                        --before the call to the accounting engine
  override_source_type    ar_distributions.source_type%TYPE ,
  gl_tax_acct             ar_distributions.code_combination_id%TYPE,  /* Bug fix 2300268 */
  inv_cm_app_mode         VARCHAR2(1)
  );

--
-- Accounting Entry Document Type Record (Product)
--
/* Define product specific Document Type record here */


--
-- Accounting Entry Event Type Record (Standard)
--
TYPE ae_event_rec_type IS RECORD (
  event_type         	varchar2(30),	-- E.g. INVOICE_CREATE, RECEIPT_CREATE
  event_id             	number(15),
  event_date            date,
  event_status          varchar2(30)
  );

--
-- Accounting Entry Event Type Record (Product)
--
/* Define product specific Event Type record here */

--
-- Accounting Entry Line Type
--
-- Doc table and id columns for future usage purposes
--
--

TYPE ae_line_rec_type IS RECORD
  (
  ae_line_type			ar_distributions.source_type%TYPE,
  ae_line_type_secondary        ar_distributions.source_type_secondary%TYPE,
  source_id			ar_distributions.source_id%TYPE,
  source_table			ar_distributions.source_table%TYPE,
  account			ar_distributions.code_combination_id%TYPE,
  entered_dr			NUMBER,
  entered_cr			NUMBER,
  accounted_dr			NUMBER,
  accounted_cr			NUMBER,
  source_id_secondary           ar_distributions.source_id_secondary%TYPE,
  source_table_secondary        ar_distributions.source_table_secondary%TYPE,
  currency_code			ar_distributions.currency_code%TYPE,
  currency_conversion_rate	ar_distributions.currency_conversion_rate%TYPE,
  currency_conversion_type	ar_distributions.currency_conversion_type%TYPE,
  currency_conversion_date	ar_distributions.currency_conversion_date%TYPE,
  third_party_id		ar_distributions.third_party_id%TYPE,
  third_party_sub_id		ar_distributions.third_party_sub_id%TYPE,
  tax_group_code_id             ar_distributions.tax_group_code_id%TYPE,
  tax_code_id  			ar_distributions.tax_code_id%TYPE,
  location_segment_id           ar_distributions.location_segment_id%TYPE,
  taxable_entered_dr		NUMBER,
  taxable_entered_cr		NUMBER,
  taxable_accounted_dr		NUMBER,
  taxable_accounted_cr		NUMBER,
  tax_link_id 			ar_distributions.tax_link_id%TYPE,
  applied_from_doc_table 	VARCHAR2(30),
  applied_from_doc_id 		NUMBER,
  applied_to_doc_table 		VARCHAR2(30),
  applied_to_doc_id 		NUMBER,
  reversed_source_id            ar_distributions.reversed_source_id%TYPE,
  summarize_flag                VARCHAR2(1),
  ae_neg_ind                    NUMBER,
  --{BUG#2979254
  ref_customer_trx_line_id      NUMBER,
  ref_prev_cust_trx_line_id     NUMBER,
  ref_cust_trx_line_gl_dist_id  NUMBER,
  ref_line_id                   NUMBER,
  from_amount_dr                NUMBER,
  from_amount_cr                NUMBER,
  from_acctd_amount_dr          NUMBER,
  from_acctd_amount_cr          NUMBER,
  --}
  --{HYUDETUPT
  ref_account_class                     VARCHAR2(30),
  activity_bucket                        VARCHAR2(30),
  ref_dist_ccid                 NUMBER,
  ref_mf_dist_flag              VARCHAR2(15)
  --}
  );

--
-- Accounting Entry Line Table
--
TYPE ae_line_tbl_type IS TABLE of ae_line_rec_type
  INDEX BY BINARY_INTEGER;

--
--System parameter record can be modified based on info required
--
TYPE ae_sys_rec_type IS RECORD (
     set_of_books_id   ar_system_parameters.set_of_books_id%TYPE           ,
     gain_cc_id        ar_system_parameters.code_combination_id_gain%TYPE  ,
     loss_cc_id        ar_system_parameters.code_combination_id_loss%TYPE  ,
     round_cc_id       ar_system_parameters.code_combination_id_round%TYPE ,
     base_currency     gl_sets_of_books.currency_code%TYPE                 ,
     base_precision    fnd_currencies.precision%type                       ,
     base_min_acc_unit fnd_currencies.minimum_accountable_unit%type        ,
     coa_id            number                                              ,
     sob_type          VARCHAR2(2)
  );

ae_sys_rec ae_sys_rec_type;

TYPE ae_curr_rec_type IS RECORD (
  precision                 fnd_currencies.precision%TYPE                ,
  minimum_accountable_unit  fnd_currencies.minimum_accountable_unit%TYPE
  );
--
--Rule record for earned and unearned discounts
--
TYPE ae_app_rule_rec_type IS RECORD (

--Rules Earned discounts, adjustments
    gl_account_source1       ar_receivables_trx.gl_account_source%TYPE       ,
    tax_code_source1         ar_receivables_trx.tax_code_source%TYPE         ,
    tax_recoverable_flag1    ar_receivables_trx.tax_recoverable_flag%TYPE    ,
    code_combination_id1     ar_receivables_trx.code_combination_id%TYPE     ,
    asset_tax_code1          zx_rates_b.tax_rate_code%TYPE                   ,
    liability_tax_code1      zx_rates_b.tax_rate_code%TYPE                   ,
    act_tax_non_rec_ccid1    ar_receivables_trx.code_combination_id%TYPE     ,
    act_vat_tax_id1          zx_rates_b.tax_rate_id%TYPE                      ,

--Rules Unearned discounts
    gl_account_source2       ar_receivables_trx.gl_account_source%TYPE       ,
    tax_code_source2         ar_receivables_trx.tax_code_source%TYPE         ,
    tax_recoverable_flag2    ar_receivables_trx.tax_recoverable_flag%TYPE    ,
    code_combination_id2     ar_receivables_trx.code_combination_id%TYPE     ,
    asset_tax_code2          zx_rates_b.tax_rate_code%TYPE                   ,
    liability_tax_code2      zx_rates_b.tax_rate_code%TYPE                   ,
    act_tax_non_rec_ccid2    ar_receivables_trx.code_combination_id%TYPE     ,
    act_vat_tax_id2          zx_rates_b.tax_rate_id%TYPE                      ,

--Amounts for line, tax, charges, freight revenue and tax
    receivable_account        ra_cust_trx_line_gl_dist.code_combination_id%TYPE ,
    receivable_amt            NUMBER                                            ,
    receivable_acctd_amt      NUMBER                                            ,
    revenue_amt               NUMBER                                            ,
    revenue_acctd_amt         NUMBER                                            ,
    tax_amt                   NUMBER                                            ,
    tax_acctd_amt             NUMBER                                            ,
    --{BUG#2979254
    freight_amt               NUMBER                                            ,
    freight_acctd_amt         NUMBER                                            ,
    line_charge_amt           NUMBER,
    line_charge_acctd_amt     NUMBER,
    frt_charge_amt            NUMBER,
    frt_charge_acctd_amt      NUMBER,
    --}
    def_tax_amt               NUMBER                                            ,
    def_tax_acctd_amt         NUMBER                                            ,
    line_amt_alloc            NUMBER                                            ,
    line_acctd_amt_alloc      NUMBER                                            ,
    tax_amt_alloc             NUMBER                                            ,
    tax_acctd_amt_alloc       NUMBER                                            ,
    freight_amt_alloc         NUMBER                                            ,
    freight_acctd_amt_alloc   NUMBER                                            ,
    charges_amt_alloc         NUMBER                                            ,
    charges_acctd_amt_alloc   NUMBER                                            ,
    --{Separe line_Amt_alloc from chrg_line_amt_alloc same for frt
    line_chrg_amt_alloc       NUMBER                                            ,
    line_chrg_acctd_amt_alloc NUMBER                                            ,
    frt_chrg_amt_alloc        NUMBER                                            ,
    frt_chrg_acctd_amt_alloc  NUMBER                                            ,
    --}
    line_amt_applied          NUMBER                                            ,
    line_acctd_amt_applied    NUMBER                                            ,
    tax_amt_applied           NUMBER                                            ,
    tax_acctd_amt_applied     NUMBER                                            ,
    freight_amt_applied       NUMBER                                            ,
    freight_acctd_amt_applied NUMBER                                            ,
    charges_amt_applied       NUMBER                                            ,
    charges_acctd_amt_applied NUMBER                                            ,
    --{BUG#2979254
    line_amt_rem              NUMBER,
    line_acctd_amt_rem        NUMBER,
    tax_amt_rem               NUMBER,
    tax_acctd_amt_rem         NUMBER,
    frt_amt_rem               NUMBER,
    frt_acctd_amt_rem         NUMBER,
    line_chrg_amt_rem         NUMBER,
    line_chrg_acctd_amt_rem   NUMBER,
    frt_chrg_amt_rem          NUMBER,
    frt_chrg_acctd_amt_rem    NUMBER
    --}
  );

invalid_dr_cr_total EXCEPTION;

/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This procedure calls the document main packages to create accounting
 |      for Receipts, Credit Memos and Adjustments.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
		p_mode 		IN VARCHAR2,	-- DOCUMENT or ACCT_EVENT
		p_ae_doc_rec 	IN ae_doc_rec_type,
		p_ae_event_rec 	IN ae_event_rec_type,
                p_client_server IN VARCHAR2 DEFAULT NULL,
                --{HYUDETUPT
                p_from_llca_call  IN VARCHAR2 DEFAULT 'N',
                p_gt_id           IN NUMBER   DEFAULT NULL,
		p_called_from     IN VARCHAR2 DEFAULT NULL
                --}
		);

/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure to which is passed the document
 |      information, to create accounting entries for Receipts, Credit Memos
 |      or Adjustments.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_ae_doc_rec    IN ae_doc_rec_type,    -- DOCUMENT or ACCT_EVENT
                p_client_server IN VARCHAR2 DEFAULT NULL,
                --{HYUDETUPT
                p_from_llca_call  IN VARCHAR2 DEFAULT 'N',
                p_gt_id           IN NUMBER   DEFAULT NULL,
                --}
		p_called_from     IN VARCHAR2 DEFAULT NULL
                );

/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure to which is passed the document
 |      information, to create accounting entries for Receipts, Credit Memos
 |      or Adjustments.
 |
 | PARAMETERS
 |      document_type           IN      Document Type
 |      document_id             IN      Document Id
 |      accounting_entity_level IN      Entitity Level accounting
 |      source_table            IN      Source table
 |      source_id               IN      Source Id
 |      source_id_old           IN      Source Id Old
 |      other_flag              IN      Other Flag
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_document_type           VARCHAR2,
                p_document_id             NUMBER  ,
                p_accounting_entity_level VARCHAR2,
                p_source_table            VARCHAR2,
                p_source_id               NUMBER  ,
                p_source_id_old           NUMBER  ,
                p_other_flag              VARCHAR2,
                p_client_server IN VARCHAR2 DEFAULT NULL,
                --{HYUDETUPT
                p_from_llca_call  IN VARCHAR2 DEFAULT 'N',
                p_gt_id           IN NUMBER   DEFAULT NULL
                --}
                );

/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure to which is passed the document
 |      information, to create accounting entries for Receipts, Credit Memos
 |      or Adjustments. This is used by C code and it was necessary to overload
 |      this to pass the pay_sched_upd_yn, for Bills Receivable reconciliation
 |      on closure, required by autoadjustments, and postbatch, this avoided having
 |      to change other C routines.
 |
 | PARAMETERS
 |      document_type           IN      Document Type
 |      document_id             IN      Document Id
 |      accounting_entity_level IN      Entitity Level accounting
 |      source_table            IN      Source table
 |      source_id               IN      Source Id
 |      source_id_old           IN      Source Id Old
 |      other_flag              IN      Other Flag
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_document_type           IN VARCHAR2,
                p_document_id             IN NUMBER  ,
                p_accounting_entity_level IN VARCHAR2,
                p_source_table            IN VARCHAR2,
                p_source_id               IN NUMBER  ,
                p_source_id_old           IN NUMBER  ,
                p_other_flag              IN VARCHAR2,
                p_pay_sched_upd_yn        IN VARCHAR2,
                p_client_server           IN VARCHAR2,
                --{HYUDETUPT
                p_from_llca_call  IN VARCHAR2 DEFAULT 'N',
                p_gt_id           IN NUMBER   DEFAULT NULL
                --}
                );
/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure to which is passed a request_id
 |      from AUTORECEIPTS for processing the Receivable APPLICATION Rows
 |
 | PARAMETERS
 |      p_request_id    IN      Request_id
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_request_id              IN NUMBER,
                p_called_from             IN VARCHAR
                );

/*========================================================================
 | PUBLIC PROCEDURE Delete_Acct_Entry
 |
 | DESCRIPTION
 |      Delete accounting entries for a document
 |      ----------------------------------------
 |      This procedure is the standard delete routine which calls packages
 |      for Receipts, Credit Memos and Adjustments to delete the accounting
 |      associated with the document for a source id
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 *=======================================================================*/
PROCEDURE Delete_Acct_Entry(
                p_mode          IN VARCHAR2,    -- DOCUMENT or ACCT_EVENT
                p_ae_doc_rec    IN OUT NOCOPY ae_doc_rec_type,
                p_ae_event_rec  IN ae_event_rec_type
                );

/*========================================================================
 | PUBLIC PROCEDURE Delete_Acct_Entry
 |
 | DESCRIPTION
 |      Delete accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure which calls packages associated
 |      with a Receipt, Credit Memo or Adjustment document to delete the
 |      accounting for a source id.
 |
 | PARAMETERS
 |      p_ae_doc_rec    IN      Document Record
 *=======================================================================*/
PROCEDURE Delete_Acct_Entry(
                p_ae_doc_rec    IN OUT NOCOPY ae_doc_rec_type    -- DOCUMENT or ACCT_EVENT
                );
/*========================================================================
 | PUBLIC PROCEDURE Delete_Acct_Entry
 |
 | DESCRIPTION
 |      Delete accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure which calls packages associated
 |      with a Receipt, Credit Memo or Adjustment document to delete the
 |      accounting for a source id. Required for C code delete calls.
 |
 | PARAMETERS
 |      document_type           IN      Document Type
 |      document_id             IN      Document Id
 |      accounting_entity_level IN      Entitity Level accounting
 |      source_table            IN      Source table
 |      source_id               IN      Source Id
 |      source_id_old           IN OUT NOCOPY  Source Id Old
 |      other_flag              IN      Other Flag
 *=======================================================================*/
PROCEDURE Delete_Acct_Entry(
                p_document_type           IN     VARCHAR2,
                p_document_id             IN     NUMBER  ,
                p_accounting_entity_level IN     VARCHAR2,
                p_source_table            IN     VARCHAR2,
                p_source_id               IN     NUMBER  ,
                p_source_id_old           IN OUT NOCOPY NUMBER  ,
                p_other_flag              IN     VARCHAR2
                );

END ARP_ACCT_MAIN;

/
