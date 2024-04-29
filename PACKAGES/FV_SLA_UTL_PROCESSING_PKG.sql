--------------------------------------------------------
--  DDL for Package FV_SLA_UTL_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_SLA_UTL_PROCESSING_PKG" AUTHID CURRENT_USER AS
--$Header: FVXLAUTS.pls 120.0.12010000.2 2010/03/24 19:06:07 sasukuma noship $

  ----Ledger Variables
  TYPE LedgerRecType IS RECORD
  (
    ledger_id            gl_ledgers.ledger_id%TYPE,
    ledger_name          gl_ledgers.name%TYPE,
    coaid                gl_ledgers.chart_of_accounts_id%TYPE,
    accounting_seg_num   fnd_id_flex_segments.segment_num%TYPE,
    accounting_seg_name  fnd_id_flex_segments.application_column_name%TYPE,
    balancing_seg_num    fnd_id_flex_segments.segment_num%TYPE,
    balancing_seg_name   fnd_id_flex_segments.application_column_name%TYPE,
    bfy_segment_num      fnd_id_flex_segments.segment_num%TYPE,
    bfy_segment_name     fnd_id_flex_segments.application_column_name%TYPE,
    fyr_segment_id       NUMBER,
    currency_code        gl_ledgers.currency_code%TYPE
  );
  TYPE LedgerTabType IS TABLE OF LedgerRecType INDEX BY BINARY_INTEGER;

  TYPE fv_ref_detail IS TABLE OF FV_EXTRACT_DETAIL_GT%ROWTYPE
  INDEX BY BINARY_INTEGER;

  PROCEDURE trace
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  );

  PROCEDURE stack_error
  (
    p_program_name  IN VARCHAR2,
    p_location      IN VARCHAR2,
    p_error_message IN VARCHAR2
  );

  PROCEDURE get_ledger_info
  (
    p_ledger_id  IN NUMBER,
    p_ledger_rec OUT NOCOPY LedgerRecType,
    p_error_code OUT NOCOPY NUMBER,
    p_error_desc OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_segment_values
  (
    p_ledger_id     IN NUMBER,
    p_ccid          IN NUMBER,
    p_fund_value    OUT NOCOPY VARCHAR2,
    p_account_value OUT NOCOPY VARCHAR2,
    p_bfy_value     OUT NOCOPY VARCHAR2,
    p_error_code    OUT NOCOPY NUMBER,
    p_error_desc    OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_fund_details
  (
    p_application_id     IN  NUMBER,
    p_ledger_id          IN  NUMBER,
    p_fund_value         IN  VARCHAR2,
    p_gl_date            IN  DATE,
    p_fund_category      OUT NOCOPY fv_fund_parameters.fund_category%TYPE,
    p_fund_status        OUT NOCOPY VARCHAR2,
    p_fund_time_frame    OUT NOCOPY fv_treasury_symbols.time_frame%TYPE,
    p_treasury_symbol_id OUT NOCOPY fv_fund_parameters.treasury_symbol_id%TYPE,
    p_treasury_symbol    OUT NOCOPY fv_treasury_symbols.treasury_symbol%TYPE,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_prior_year_status
  (
    p_application_id IN NUMBER,
    p_ledger_id      IN NUMBER,
    p_bfy_value      IN VARCHAR2,
    p_gl_date        IN DATE,
    p_pya            OUT NOCOPY VARCHAR2,
    p_pya_type       OUT NOCOPY VARCHAR2,
    p_error_code     OUT NOCOPY NUMBER,
    p_error_desc     OUT NOCOPY VARCHAR2
  );

  PROCEDURE dump_gt_table
  (
    p_fv_extract_detail IN fv_ref_detail,
    p_error_code OUT NOCOPY NUMBER,
    p_error_desc OUT NOCOPY VARCHAR2
  );

  PROCEDURE init_extract_record
  (
    p_application_id    IN NUMBER,
    p_fv_extract_detail IN OUT NOCOPY fv_extract_detail_gt%ROWTYPE
  );
  PROCEDURE get_sla_doc_balances
  (
    p_called_from        IN VARCHAR2,
    p_trx_amount         IN NUMBER,
    p_ordered_amount     IN NUMBER,
    p_delivered_amount   IN NUMBER,
    p_billed_amount      IN NUMBER,
    p_4801_bal           OUT NOCOPY NUMBER,
    p_4802_bal           OUT NOCOPY NUMBER,
    p_4901_bal           OUT NOCOPY NUMBER,
    p_4902_bal           OUT NOCOPY NUMBER,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  );
  PROCEDURE determine_upward_downward
  (
    p_ledger_id            IN NUMBER,
    p_event_id             IN NUMBER,
    p_po_header_id         IN NUMBER,
    p_fund_value           IN VARCHAR2,
    p_gl_date              IN DATE,
    p_entered_pya_diff_amt IN NUMBER,
    p_net_pya_adj_amt      OUT NOCOPY NUMBER,
    p_adjustment_type      OUT NOCOPY VARCHAR2,
    p_anticipation         OUT NOCOPY VARCHAR2,
    p_anticipated_amt      OUT NOCOPY NUMBER,
    p_unanticipated_amt    OUT NOCOPY NUMBER,
    p_balance_amt          OUT NOCOPY NUMBER,
    p_error_code           OUT NOCOPY NUMBER,
    p_error_desc           OUT NOCOPY VARCHAR2
  );

  PROCEDURE get_anticipated_ts_amt
  (
    p_ledger_id          IN NUMBER,
    p_gl_date            IN DATE,
    p_treasury_symbol_id IN VARCHAR2,
    p_anticipated_amt    OUT NOCOPY NUMBER,
    p_error_code         OUT NOCOPY NUMBER,
    p_error_desc         OUT NOCOPY VARCHAR2
  );

END fv_sla_utl_processing_pkg; -- Package spec

/
