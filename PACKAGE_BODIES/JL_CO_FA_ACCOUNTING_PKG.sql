--------------------------------------------------------
--  DDL for Package Body JL_CO_FA_ACCOUNTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_FA_ACCOUNTING_PKG" AS
/* $Header: jlcofgab.pls 120.15 2007/11/21 11:44:47 hbalijep ship $ */

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'JL_CO_FA_ACCOUNTING_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'JL.PLSQL.JL_CO_FA_ACCOUNTING_PKG.';

  -----------------------------------------------------------------------------
  --  Variables corresponding to Who columns                                 --
  -----------------------------------------------------------------------------

  x_last_updated_by         jl_co_fa_adjustments.last_updated_by%TYPE ;
  x_last_update_login       jl_co_fa_adjustments.last_update_login%TYPE;
  x_request_id              jl_co_fa_adjustments.request_id%TYPE;
  x_program_application_id  jl_co_fa_adjustments.program_application_id%TYPE;
  x_program_id              jl_co_fa_adjustments.program_id%TYPE;
  x_sysdate                 date;

  -----------------------------------------------------------------------------
  -- PROCEDURE                                                               --
  --   account_transactions                                                  --
  --                                                                         --
  -- DESCRIPTION                                                             --
  --   Main procedure to execute the Colombian accounting to General Ledger  --
  --                                                                         --
  -- PURPOSE:                                                                --
  --   Oracle Applications Rel. 11.0                                         --
  --                                                                         --
  -- PARAMETERS:                                                             --
  --   ERRBUF       Parameter used by concurrent process                     --
  --   RETCODE      Parameter used by concurrent process                     --
  --   p_tax_book   Tax depreciation book type code                          --
  -----------------------------------------------------------------------------

  PROCEDURE account_transactions (ERRBUF     OUT NOCOPY VARCHAR2,
                                  RETCODE    OUT NOCOPY VARCHAR2,
                                  p_tax_book IN  VARCHAR2
                                 )
  IS

    l_api_name           CONSTANT VARCHAR2(30) := 'ACCOUNT_TRANSACTIONS';

    -----------------------------------------------------------------------------
    --  Accounting flexfield structure parameters                              --
    -----------------------------------------------------------------------------
    --    LER, 18-Jun-99   Balancing and cost center qualifier variables are   --
    --                     not more used.                                      --
    -----------------------------------------------------------------------------

    x_appl_id              NUMBER       := 101;
    x_apps_short_name      VARCHAR2(5)  := 'SQLGL';
    x_key_flex_code        VARCHAR2(3)  := 'GL#';
--    x_balancing_qualifier  VARCHAR2(20) := 'GL_BALANCING';
--    x_cost_ctr_qualifier   VARCHAR2(20) := 'FA_COST_CTR';
    x_account_qualifier    VARCHAR2(20) := 'GL_ACCOUNT';
    x_delimiter            VARCHAR2(1)  ;

    -----------------------------------------------------------------------------
    --  Book and period parameters                                             --
    -----------------------------------------------------------------------------

    x_chart_of_accounts_id     fa_book_controls.accounting_flex_structure%TYPE;
    x_corporate_book           fa_book_controls.book_type_code%TYPE;
    x_period_counter           fa_book_controls.last_period_counter%TYPE;
    x_account_period           fa_book_controls.last_period_counter%TYPE;
    x_period_name              fa_deprn_periods.period_name%TYPE;
    x_deprn_date               fa_deprn_periods.period_open_date%TYPE;

    x_currency_code            gl_sets_of_books.currency_code%TYPE;
    x_precision                fnd_currencies.precision%TYPE;
    x_extended_precision       fnd_currencies.extended_precision%TYPE;
    x_minumum_accountable_unit fnd_currencies.minimum_accountable_unit%TYPE;

    -----------------------------------------------------------------------------
    --  Journal entry categories                                               --
    -----------------------------------------------------------------------------

    x_je_category_name         gl_je_categories.je_category_name%TYPE;
    x_je_std_category_name     gl_je_categories.je_category_name%TYPE;
    x_je_depreciation          gl_je_categories.je_category_name%TYPE;

    x_je_infln_adjustment      gl_je_categories.je_category_name%TYPE;
    x_je_cip_infln_adjustment  gl_je_categories.je_category_name%TYPE;
    x_je_ia_addition           gl_je_categories.je_category_name%TYPE;
    x_je_ia_cip_addition       gl_je_categories.je_category_name%TYPE;
    x_je_ia_adjustment         gl_je_categories.je_category_name%TYPE;
    x_je_ia_cip_adjustment     gl_je_categories.je_category_name%TYPE;
    x_je_ia_reclass            gl_je_categories.je_category_name%TYPE;
    x_je_ia_cip_reclass        gl_je_categories.je_category_name%TYPE;
    x_je_ia_transfer           gl_je_categories.je_category_name%TYPE;
    x_je_ia_cip_transfer       gl_je_categories.je_category_name%TYPE;
    x_je_ia_retirement         gl_je_categories.je_category_name%TYPE;
    x_je_ia_cip_retirement     gl_je_categories.je_category_name%TYPE;
    x_je_appraisal             gl_je_categories.je_category_name%TYPE;

    ---------------------------------------------------------------------------------
    --  Segments and CCIDs for natural accounts used by package                    --
    --    LER, 18-Jun-99   a. Balancing and cost center segment are not more used  --
    --                     b. CCIDs are not more stored in FA_BOOKS_CONTROLS.GDF;  --
    --                        these GDF store the natural accouns in Rel. 11.5     --
    ---------------------------------------------------------------------------------

--    x_balancing_segment   NUMBER;
    x_account_segment     NUMBER;
--    x_cost_ctr_segment    NUMBER;

    x_deprn_reserve_ccid         fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ia_cost_ccid               fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ix_cost_ccid               fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ia_deprn_reserve_ccid      fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ix_deprn_reserve_ccid      fa_category_books.asset_cost_account_ccid%TYPE;
    x_expense_ccid               fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ia_cip_cost_ccid           fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ix_cip_cost_ccid           fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ta_revaluation_ccid        fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ta_surplus_ccid            fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ta_reserve_ccid            fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ta_reserve_expense_ccid    fa_category_books.asset_cost_account_ccid%TYPE;
--    x_ta_reserve_recovery_ccid   fa_category_books.asset_cost_account_ccid%TYPE;

    x_old_deprn_reserve_ccid        fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ia_cost_ccid              fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ix_cost_ccid              fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ia_deprn_reserve_ccid     fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ix_deprn_reserve_ccid     fa_category_books.asset_cost_account_ccid%TYPE;
    x_old_expense_ccid              fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ia_cip_cost_ccid          fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ix_cip_cost_ccid          fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ta_revaluation_ccid       fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ta_surplus_ccid           fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ta_reserve_ccid           fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ta_reserve_expense_ccid   fa_category_books.asset_cost_account_ccid%TYPE;
--    x_old_ta_reserve_recovery_ccid  fa_category_books.asset_cost_account_ccid%TYPE;

    x_deprn_reserve_segm         fa_category_books.asset_cost_acct%TYPE;
    x_ia_cost_segm               fa_category_books.asset_cost_acct%TYPE;
    x_ix_cost_segm               fa_category_books.asset_cost_acct%TYPE;
    x_ia_deprn_reserve_segm      fa_category_books.asset_cost_acct%TYPE;
    x_ix_deprn_reserve_segm      fa_category_books.asset_cost_acct%TYPE;
    x_ia_cip_cost_segm           fa_category_books.asset_cost_acct%TYPE;
    x_ix_cip_cost_segm           fa_category_books.asset_cost_acct%TYPE;
    x_ta_revaluation_segm        fa_category_books.asset_cost_acct%TYPE;
    x_ta_surplus_segm            fa_category_books.asset_cost_acct%TYPE;
    x_ta_reserve_segm            fa_category_books.asset_cost_acct%TYPE;
    x_ta_reserve_expense_segm    fa_category_books.asset_cost_acct%TYPE;
    x_ta_reserve_recovery_segm   fa_category_books.asset_cost_acct%TYPE;

    x_old_deprn_reserve_segm     fa_category_books.asset_cost_acct%TYPE;
    x_old_ia_cost_segm           fa_category_books.asset_cost_acct%TYPE;
    x_old_ia_deprn_reserve_segm  fa_category_books.asset_cost_acct%TYPE;
    x_old_ia_cip_cost_segm       fa_category_books.asset_cost_acct%TYPE;
    x_old_ta_revaluation_segm    fa_category_books.asset_cost_acct%TYPE;
    x_old_ta_surplus_segm        fa_category_books.asset_cost_acct%TYPE;
    x_old_ta_reserve_segm        fa_category_books.asset_cost_acct%TYPE;

    x_old_ix_cost_segm             fa_category_books.asset_cost_acct%TYPE;
    x_old_ix_deprn_reserve_segm    fa_category_books.asset_cost_acct%TYPE;
    x_old_ix_cip_cost_segm         fa_category_books.asset_cost_acct%TYPE;
    x_old_ta_reserve_expense_segm  fa_category_books.asset_cost_acct%TYPE;
    x_old_ta_reserve_recovery_segm fa_category_books.asset_cost_acct%TYPE;

    x_natural_account            fa_category_books.asset_cost_acct%TYPE;
    x_natural_account1           fa_category_books.asset_cost_acct%TYPE;
    x_returned_ccid              fa_category_books.asset_cost_account_ccid%TYPE;
    x_concat_segs                VARCHAR2(240);
    x_return_value               NUMBER;

    -----------------------------------------------------------------------------
    --  Name of the accounts used in JL_CO_FA_ADJUSTMENTS.ADJUSTMENT_TYPE      --
    -----------------------------------------------------------------------------

    x_cost_name                  fa_adjustments.adjustment_type%TYPE := 'COST';
    x_cip_cost_name              fa_adjustments.adjustment_type%TYPE := 'CIP COST';
    x_reserve_name               fa_adjustments.adjustment_type%TYPE := 'RESERVE';
    x_expense_name               fa_adjustments.adjustment_type%TYPE := 'EXPENSE';
    x_nbv_retired_name           fa_adjustments.adjustment_type%TYPE := 'NBV RETIRED';
    x_reval_amort_name           fa_adjustments.adjustment_type%TYPE := 'REVAL AMORT';
    x_reval_reserve_name         fa_adjustments.adjustment_type%TYPE := 'REVAL RESERVE';
    x_proceeds_name              fa_adjustments.adjustment_type%TYPE := 'PROCEEDS';
    x_removal_cost_name          fa_adjustments.adjustment_type%TYPE := 'REMOVALCOST';

    x_ia_cost_name               fa_adjustments.adjustment_type%TYPE := 'IA COST';
    x_ix_cost_name               fa_adjustments.adjustment_type%TYPE := 'IX COST';
    x_ia_cip_cost_name           fa_adjustments.adjustment_type%TYPE := 'IA CIP COST';
    x_ix_cip_cost_name           fa_adjustments.adjustment_type%TYPE := 'IX CIP COST';
    x_ia_reserve_name            fa_adjustments.adjustment_type%TYPE := 'IA DEPRN RESRVE';
    x_ix_reserve_name            fa_adjustments.adjustment_type%TYPE := 'IX DEPRN RESRVE';
    x_ia_expense_name            fa_adjustments.adjustment_type%TYPE := 'IA DEPRN EXPNSE';
    x_ix_expense_name            fa_adjustments.adjustment_type%TYPE := 'IX DEPRN EXPNSE';

    x_ta_revaluation_name        fa_adjustments.adjustment_type%TYPE := 'TA REVALUATION';
    x_ta_surplus_name            fa_adjustments.adjustment_type%TYPE := 'TA SURPLUS';
    x_ta_reserve_name            fa_adjustments.adjustment_type%TYPE := 'TA RESERVE';
    x_ta_expense_name            fa_adjustments.adjustment_type%TYPE := 'TA RESRVE EXPEN';
    x_ta_recovery_name           fa_adjustments.adjustment_type%TYPE := 'TA RESRVE RECOV';

    x_account_name               fa_adjustments.adjustment_type%TYPE;

    -----------------------------------------------------------------------------
    --  Variables for transaction tracking                                     --
    -----------------------------------------------------------------------------

    x_transaction_header_id_in      fa_transaction_headers.transaction_header_id%TYPE;
    x_transaction_header_id_out     fa_transaction_headers.transaction_header_id%TYPE;
    x_date_effective                fa_transaction_headers.date_effective%TYPE;
    x_category_id                   fa_asset_history.category_id%TYPE;
    x_prior_category_id             fa_asset_history.category_id%TYPE;
    x_old_category_id               fa_asset_history.category_id%TYPE;
    x_asset_id                      fa_additions.asset_id%TYPE;

    x_distribution_id               fa_distribution_history.distribution_id%TYPE;
    x_debit_credit_flag             fa_adjustments.debit_credit_flag%TYPE;
    x_code_combination_id           fa_adjustments.code_combination_id%TYPE;
    x_adjustment_amount             fa_adjustments.adjustment_amount%TYPE;
    x_adjustment_type               fa_adjustments.adjustment_type%TYPE;

    x_cost_dr                       NUMBER;
    x_cost_cr                       NUMBER;
    x_reserve_dr                    NUMBER;
    x_reserve_cr                    NUMBER;
    x_expense_dr                    NUMBER;
    x_expense_cr                    NUMBER;

    x_adj_cost                      fa_deprn_summary.adjusted_cost%TYPE;
    x_adj_deprn_reserve             fa_deprn_summary.deprn_reserve%TYPE;
    x_adj_ytd_deprn                 fa_deprn_summary.ytd_deprn%TYPE;
    x_adj_reval_deprn_expense       fa_deprn_summary.reval_deprn_expense%TYPE;
    x_adj_reval_reserve             fa_deprn_summary.reval_reserve%TYPE;
    x_corp_cost                     fa_deprn_summary.adjusted_cost%TYPE;
    x_corp_deprn_reserve            fa_deprn_summary.deprn_reserve%TYPE;
    x_corp_ytd_deprn                fa_deprn_summary.ytd_deprn%TYPE;
    x_corp_reval_deprn_expense      fa_deprn_summary.reval_deprn_expense%TYPE;
    x_corp_reval_reserve            fa_deprn_summary.reval_reserve%TYPE;

    x_corp_retirement_id            fa_retirements.retirement_id%TYPE;
    x_date_retired                  fa_retirements.date_retired%TYPE;
    x_corp_cost_retired             fa_retirements.cost_retired%TYPE;
    x_corp_units_retired            fa_retirements.units%TYPE;
    x_corp_nbv_retired              fa_retirements.nbv_retired%TYPE;
    x_corp_reval_reserve_retired    fa_retirements.reval_reserve_retired%TYPE;
    x_corp_gain_loss_amount         fa_retirements.gain_loss_amount%TYPE;
    x_adj_retirement_id             fa_retirements.retirement_id%TYPE;
    x_adj_cost_retired              fa_retirements.cost_retired%TYPE;
    x_adj_units_retired             fa_retirements.units%TYPE;
    x_adj_nbv_retired               fa_retirements.nbv_retired%TYPE;
    x_adj_reval_reserve_retired     fa_retirements.reval_reserve_retired%TYPE;
    x_adj_gain_loss_amount          fa_retirements.gain_loss_amount%TYPE;

    x_retirement_type               VARCHAR2 (1);
    x_retirement_type_code          fa_transaction_headers.transaction_type_code%TYPE;
    x_source_transaction_header_id  fa_transaction_headers.transaction_header_id%TYPE;
    x_nbv_debit_credit_flag         fa_adjustments.debit_credit_flag%TYPE;
    x_nbv_retired_ccid              fa_adjustments.code_combination_id%TYPE;
    x_ia_cost_retired               NUMBER;
    x_ia_reserve                    NUMBER;
    x_ia_reserve_retired            NUMBER;
    x_gain_loss_changed             BOOLEAN;

    x_global_source      fa_transaction_headers.transaction_type_code%TYPE;
    x_global_appraisal   fa_transaction_headers.transaction_type_code%TYPE := 'APPRAISAL';
    x_adj_cost_line      NUMBER;
    x_corp_cost_line     NUMBER;
    x_deprn_to_cost      NUMBER;
    x_addition_flag      BOOLEAN;
    x_adjustment_flag    BOOLEAN;
    x_factor             NUMBER;
    x_factor_1           NUMBER;
    x_factor_11          NUMBER;
    x_factor_12          NUMBER;
    x_factor_2           NUMBER;
    x_ta_factor          NUMBER;
    x_ta_line_amount     NUMBER;

    x_value_1            NUMBER;
    x_value_2            NUMBER;
    x_value_3            NUMBER;
    x_value_4            NUMBER;
    x_value_5            NUMBER;
    x_period_1           NUMBER;
    l_book_type_code     fa_books.book_type_code%type;

--    x_nbv_retired        NUMBER;

    -----------------------------------------------------------------------------
    --  Exception variables                                                    --
    -----------------------------------------------------------------------------

    e_period_was_closed      EXCEPTION;
    e_not_finished_by_ccid   EXCEPTION;
    e_ccid_not_found         EXCEPTION;

    -----------------------------------------------------------------------------
    --  Variables for number and message errors                                --
    -----------------------------------------------------------------------------

    call_status   BOOLEAN;
    err_num       NUMBER;
    err_msg       VARCHAR2(200);
    x_error_ccid  BOOLEAN;
    x_temporal    BOOLEAN;
    x_char        VARCHAR2 (200);

    -----------------------------------------------------------------------------
    --  Get transactions for tracking                                          --
    -----------------------------------------------------------------------------

    CURSOR c_transac (pc_tax_book        IN VARCHAR2,
                      pc_corporate_book  IN VARCHAR2,
                      pc_period_counter  IN NUMBER
                     )
    IS
      SELECT   ah.category_id,
               th.asset_id,
               th.transaction_header_id,
               th.book_type_code,
               th.transaction_type_code,
               th.transaction_subtype,
               th.transaction_date_entered,
               th.date_effective,
               th.source_transaction_header_id,
               ad.asset_number,
               ah.asset_type,
               nvl (ah.units,0)               units,
               bk.date_placed_in_service,
               bk.period_counter_capitalized,
               nvl (bk.cost,0)                adj_cost,
               fnd_number.canonical_to_number(nvl (bk.global_attribute2,0))   appraisal_balance,
               fnd_number.canonical_to_number(nvl (bk.global_attribute7,0))   deprn_to_cost,
               bk.rowid                       book_rowid
      FROM     fa_transaction_headers  th,
               fa_deprn_periods        dp,
               fa_additions            ad,
               fa_asset_history        ah,
               fa_books                bk
      WHERE    dp.book_type_code    = pc_tax_book
        AND    dp.period_counter    = pc_period_counter
        AND    th.book_type_code    = dp.book_type_code
        AND    dp.period_open_date <= th.date_effective
        AND    th.date_effective   <= dp.period_close_date
        AND    th.transaction_type_code IN ('REVALUATION',
                                            'ADDITION',
                                            'CIP ADDITION',
                                            'ADJUSTMENT',
                                            'CIP ADJUSTMENT',
                                            'FULL RETIREMENT',
                                            'PARTIAL RETIREMENT',
                                            'REINSTATEMENT'
                                           )
        AND    ad.asset_id = th.asset_id
        AND    ah.asset_id = th.asset_id
        AND    ah.date_effective <= th.date_effective
        AND    th.date_effective <  nvl (ah.date_ineffective, sysdate)
        AND    bk.book_type_code  = pc_tax_book
        AND    bk.asset_id        = th.asset_id
        AND    bk.date_effective <= th.date_effective
        AND    th.date_effective <  nvl (bk.date_ineffective, sysdate)
      UNION
      SELECT   ah.category_id,
               th.asset_id,
               th.transaction_header_id,
               th.book_type_code,
               th.transaction_type_code,
               th.transaction_subtype,
               th.transaction_date_entered,
               th.date_effective,
               th.source_transaction_header_id,
               ad.asset_number,
               ah.asset_type,
               nvl (ah.units,0),
               bk.date_placed_in_service,
               bk.period_counter_capitalized,
               nvl (bk.cost,0),
               fnd_number.canonical_to_number(nvl (bk.global_attribute2,0)),
               fnd_number.canonical_to_number(nvl (bk.global_attribute7,0)),
               bk.rowid
      FROM     fa_transaction_headers  th,
               fa_deprn_periods        dp,
               fa_additions            ad,
               fa_asset_history        ah,
               fa_books                bk
      WHERE    dp.book_type_code    = pc_corporate_book
        AND    dp.period_counter    = pc_period_counter
        AND    th.book_type_code    = dp.book_type_code
        AND    dp.period_open_date <= th.date_effective
        AND    th.date_effective   <= dp.period_close_date
        AND    th.transaction_type_code IN ('TRANSFER OUT',
                                            'RECLASS',
                                            'CIP RECLASS',
                                            'TRANSFER',
                                            'CIP TRANSFER',
                                            'UNIT ADJUSTMENT'
                                           )
        AND    ad.asset_id = th.asset_id
        AND    ah.asset_id = th.asset_id
        AND    ah.date_effective <= th.date_effective
        AND    th.date_effective <  nvl (ah.date_ineffective, sysdate)
        AND    bk.book_type_code  = pc_tax_book
        AND    bk.asset_id        = th.asset_id
        AND    bk.date_effective <= th.date_effective
        AND    th.date_effective <  nvl (bk.date_ineffective, sysdate)
      ORDER BY 1,2,3 ;

    -----------------------------------------------------------------------------
    --  Get CCID for globalization accounts of a asset category                --
    -----------------------------------------------------------------------------

    CURSOR c_accounts (pc_category_id     IN NUMBER,
                       pc_book_type_code  IN VARCHAR2
                      )
    IS
      SELECT  reserve_account_ccid,
              deprn_reserve_acct,
              global_attribute3,
              global_attribute4,
              global_attribute5,
              global_attribute6,
              global_attribute9,
              global_attribute10,
              global_attribute11,
              global_attribute12,
              global_attribute13,
              global_attribute14,
              global_attribute15
      FROM    fa_category_books
      WHERE   category_id    = pc_category_id
        AND   book_type_code = pc_book_type_code ;

    -----------------------------------------------------------------------------
    --  Get CCID and segment for the Depreciation Reserve account              --
    -----------------------------------------------------------------------------

    CURSOR c_reserve_acct (pc_category_id     IN NUMBER,
                           pc_book_type_code  IN VARCHAR2
                          )
    IS
      SELECT  reserve_account_ccid,
              deprn_reserve_acct
      FROM    fa_category_books
      WHERE   category_id    = pc_category_id
        AND   book_type_code = pc_book_type_code ;

    -----------------------------------------------------------------------------
    --  Get the prior asset category (used in reclassifications)               --
    -----------------------------------------------------------------------------

    CURSOR c_prior_category (pc_asset_id               IN NUMBER,
                             pc_transaction_header_id  IN NUMBER
                            )
    IS
      SELECT  category_id
      FROM    fa_asset_history
      WHERE   asset_id                  = pc_asset_id
        AND   transaction_header_id_out = pc_transaction_header_id;

    -----------------------------------------------------------------------------
    -- Get historical and adjusted depreciation at asset level                 --
    -----------------------------------------------------------------------------

    CURSOR c_deprn_summary (pc_book_type_code  IN VARCHAR2,
                            pc_asset_id        IN NUMBER,
                            pc_period_counter  IN NUMBER
                           )
    IS
      SELECT  nvl (deprn_reserve,0),
              nvl (reval_reserve,0),
              nvl (reval_deprn_expense,0)
      FROM    fa_deprn_summary
      WHERE   asset_id       = pc_asset_id
        AND   book_type_code = pc_book_type_code
        AND   period_counter = pc_period_counter;

    ----------------------------------------------------------------------------
    --  Get all adjustment rows of a transaction with Amount # 0              --
    --  Bug 3931540: Cursor c_tr_adjustments has been splitted in 2 cursors   --
    --               to improve performace and handle the condition of        --
    --               pc_adj_type null or not null                             --
    ----------------------------------------------------------------------------

    CURSOR c_tr_adjustments_no_adj_type (pc_transaction_header_id IN NUMBER,
                             pc_book_type_code        IN VARCHAR2,
                             pc_period_counter        IN NUMBER   -- Bug 3680318
                            )
    IS
      SELECT   ADJ.distribution_id,
               ADJ.source_type_code,
               ADJ.adjustment_type,
               ADJ.debit_credit_flag,
               --ADJ.code_combination_id,
               XLN.code_combination_id,
               ADJ.adjustment_amount,
               ADJ.annualized_adjustment,
               ADJ.period_counter_adjusted,
               ADJ.period_counter_created,
               ADJ.asset_invoice_id
      FROM     fa_adjustments            ADJ,
               --SLA Changes. New Tables Added
               xla_ae_headers            XHD,
               xla_ae_lines              XLN,
               xla_distribution_links    XDL
      WHERE    ADJ.transaction_header_id   = pc_transaction_header_id
        AND    ADJ.book_type_code          = pc_book_type_code
        AND    ADJ.period_counter_created  = pc_period_counter  --Bug 3680318,4060555
        AND    ADJ.adjustment_amount      <> 0
        --SLA Changes. New Joins added.
        AND    XDL.source_distribution_id_num_1 = ADJ.transaction_header_id
        AND    XDL.source_distribution_id_num_2 = ADJ.adjustment_line_id
        AND    XLN.ae_header_id                  = XHD.ae_header_id
        AND    XDL.application_id                = 140
        AND    XDL.source_distribution_type      = 'TRX'
        AND    XLN.ae_header_id                  = XDL.ae_header_id
        AND    XLN.ae_line_num                   = XDL.ae_line_num
        AND    XLN.application_id                = 140
      ORDER BY 1,2,3;


    ----------------------------------------------------------------------------
    --  Get all adjustment rows of a transaction with Amount # 0              --
    --  Bug 3931540: Cursor c_tr_adjustments has been splitted in 2 cursors   --
    --               to improve performace and handle the condition of        --
    --               pc_adj_type null or not null                             --
    ----------------------------------------------------------------------------

    CURSOR c_tr_adjustments_adj_type (pc_transaction_header_id IN NUMBER,
                             pc_book_type_code        IN VARCHAR2,
                             pc_adjustment_type       IN VARCHAR2,
                             pc_period_counter        IN NUMBER   -- Bug 3680318
                            )
    IS
      SELECT   ADJ.distribution_id,
               ADJ.source_type_code,
               ADJ.adjustment_type,
               ADJ.debit_credit_flag,
               --ADJ.code_combination_id,
               XLN.code_combination_id,
               ADJ.adjustment_amount,
               ADJ.annualized_adjustment,
               ADJ.period_counter_adjusted,
               ADJ.period_counter_created,
               ADJ.asset_invoice_id
      FROM     fa_adjustments            ADJ,
               --SLA Changes. New Tables Added
               xla_ae_headers            XHD,
               xla_ae_lines              XLN,
               xla_distribution_links    XDL
      WHERE    ADJ.transaction_header_id   = pc_transaction_header_id
        AND    ADJ.book_type_code          = pc_book_type_code
        AND    ADJ.period_counter_created  = pc_period_counter  --Bug 3680318,4060555
        AND    ADJ.adjustment_amount      <> 0
        AND    ADJ.adjustment_type         = pc_adjustment_type
        --SLA Changes. New Joins added.
        AND    XDL.source_distribution_id_num_1 = ADJ.transaction_header_id
        AND    XDL.source_distribution_id_num_2 = ADJ.adjustment_line_id
        AND    XLN.ae_header_id                  = XHD.ae_header_id
        AND    XDL.application_id                = 140
        AND    XDL.source_distribution_type      = 'TRX'
        AND    XLN.ae_header_id                  = XDL.ae_header_id
        AND    XLN.ae_line_num                   = XDL.ae_line_num
        AND    XLN.application_id                = 140
      ORDER BY 1,2,3;


    -----------------------------------------------------------------------------
    --  For an adjustment row in a book (Corp/Tax) find its corresponding in   --
    --  the associated book (Tax/Corp)                                         --
    -----------------------------------------------------------------------------

    CURSOR c_tr_rel_adjustments (pc_transaction_header_id  IN NUMBER,
                                 pc_book_type_code         IN VARCHAR2,
                                 pc_source_type_code       IN VARCHAR2,
                                 pc_adjustment_type        IN VARCHAR2,
                                 pc_debit_credit_flag      IN VARCHAR2,
                                 pc_distribution_id        IN NUMBER
                                )
    IS
      --SELECT ADJ. code_combination_id,
      SELECT  XLN.code_combination_id,
              ADJ.adjustment_amount
      FROM    fa_adjustments         ADJ,
               --SLA Changes. New Tables Added
              xla_ae_headers         XHD,
              xla_ae_lines           XLN,
              xla_distribution_links XDL
      WHERE   ADJ.transaction_header_id = pc_transaction_header_id
        AND   ADJ.book_type_code        = pc_book_type_code
        AND   ADJ.source_type_code      = pc_source_type_code
        AND   ADJ.adjustment_type       = pc_adjustment_type
        AND   ADJ.debit_credit_flag     = pc_debit_credit_flag
        AND   ADJ.distribution_id       = pc_distribution_id
        AND   ADJ.adjustment_amount    <> 0
        --SLA Changes. New Joins added.
        AND   XDL.source_distribution_id_num_1 = ADJ.transaction_header_id
        AND   XDL.source_distribution_id_num_2 = ADJ.adjustment_line_id
        AND   XLN.ae_header_id                  = XHD.ae_header_id
        AND   XDL.application_id                = 140
        AND   XDL.source_distribution_type      = 'TRX'
        AND   XLN.ae_header_id                  = XDL.ae_header_id
        AND   XLN.ae_line_num                   = XDL.ae_line_num
        AND   XLN.application_id                = 140;

    -----------------------------------------------------------------------------
    --  Get the total value for a concept recorded in FA_ADJUSTMENTS           --
    -----------------------------------------------------------------------------

    CURSOR c_sum_adjustments (pc_asset_id              IN NUMBER,
                              pc_book_type_code        IN VARCHAR2,
                              pc_transaction_header_id IN NUMBER,
                              pc_adjustment_type       IN VARCHAR2,
                              pc_debit_credit_flag     IN VARCHAR2
                             )
    IS
      SELECT nvl (sum (nvl (adjustment_amount,0)), 0)
      FROM   fa_adjustments
      WHERE  asset_id              = pc_asset_id
        AND  book_type_code        = pc_book_type_code
        AND  transaction_header_id = pc_transaction_header_id
        AND  adjustment_type       = pc_adjustment_type
        AND  debit_credit_flag     = pc_debit_credit_flag ;

    -----------------------------------------------------------------------------
    --  Get the total value for a transaction type and concept                 --
    -----------------------------------------------------------------------------

    CURSOR c_sum_all_adjustments (pc_asset_id              IN NUMBER,
                                  pc_book_type_code        IN VARCHAR2,
                                  pc_period_counter        IN NUMBER,
                                  pc_adjustment_type       IN VARCHAR2,
                                  pc_debit_credit_flag     IN VARCHAR2
                                 )
    IS
      SELECT nvl (sum (nvl (adjustment_amount,0)), 0)
      FROM   fa_adjustments
      WHERE  asset_id               = pc_asset_id
        AND  book_type_code         = pc_book_type_code
        AND  period_counter_created = pc_period_counter
        AND  adjustment_type        = pc_adjustment_type
        AND  debit_credit_flag      = pc_debit_credit_flag ;

    -----------------------------------------------------------------------------
    --  Get the cost and depreciation retired in a retirement transaction      --
    -----------------------------------------------------------------------------

    CURSOR c_retirement (pc_transaction_header_id IN NUMBER)
    IS
      SELECT  retirement_id,
              nvl (cost_retired,0),
              nvl (units,0),
              nvl (nbv_retired,0),
              nvl (reval_reserve_retired,0),
              nvl (gain_loss_amount,0)
      FROM    fa_retirements
      WHERE   transaction_header_id_in = pc_transaction_header_id ;

    -----------------------------------------------------------------------------
    --  Get the cost and depreciation retired in a retirement transaction      --
    -----------------------------------------------------------------------------

    CURSOR c_reinstatement (pc_transaction_header_id IN NUMBER)
    IS
      SELECT  rt.retirement_id,
              nvl (rt.cost_retired,0),
              nvl (rt.units,0),
              nvl (rt.nbv_retired,0),
              nvl (rt.reval_reserve_retired,0),
              nvl (rt.gain_loss_amount,0),
              dp.period_counter,
              th.transaction_type_code
      FROM    fa_retirements          rt,
              fa_deprn_periods        dp,
              fa_transaction_headers  th
      WHERE   rt.transaction_header_id_out = pc_transaction_header_id
        AND   dp.book_type_code            = rt.book_type_code
        AND   dp.period_open_date         <= rt.date_effective
        AND   rt.date_effective           <= dp.period_close_date
        AND   th.transaction_header_id     = rt.transaction_header_id_in ;

    -----------------------------------------------------------------------------
    --  Get the source partial unit retirement transaction id in a Corporate   --
    --  book for the same retirement type in a Tax book                        --
    -----------------------------------------------------------------------------

    CURSOR c_source_retirement (pc_transaction_header_id IN NUMBER)
    IS
      SELECT transaction_header_id_in
      FROM   fa_retirements
      WHERE  retirement_id = (SELECT retirement_id
                              FROM   fa_distribution_history
                              WHERE  distribution_id = (SELECT distribution_id
                                                        FROM   fa_distribution_history
                                                        WHERE  transaction_header_id_out = pc_transaction_header_id
                                                          AND  rownum = 1));

    -----------------------------------------------------------------------------
    -- Get the Transaction Header Id. corresponding to the source retirement   --
    --   in a Reinstatement transaction                                        --
    -----------------------------------------------------------------------------

    CURSOR c_prior_retirement (pc_transaction_header_id IN NUMBER)
    IS
      SELECT transaction_header_id_in,
             fnd_number.canonical_to_number(nvl (global_attribute7,0))
      FROM   fa_books
      WHERE  transaction_header_id_out = pc_transaction_header_id;

  -------------------------------------------------------------------------------

    -----------------------------------------------------------------------------
    --  Assets depreciated in the period                                       --
    -----------------------------------------------------------------------------

    CURSOR c_assets_depreciated (pc_book_type_code   IN VARCHAR2,
                                 pc_period_counter   IN NUMBER,
                                 pc_deprn_date       IN DATE
                                )
    IS
      SELECT   ah.category_id,
               ds.asset_id,
               ad.asset_number,
               bk.transaction_header_id_in,
               fnd_number.canonical_to_number(nvl (bk.global_attribute7,0)) deprn_to_cost,
               bk.rowid             book_rowid
      FROM     fa_additions         ad,
               fa_asset_history     ah,
               fa_books             bk,
               fa_deprn_summary     ds
      WHERE    ds.book_type_code  = pc_book_type_code
        AND    ds.period_counter  = pc_period_counter
        AND    ad.asset_id        = ds.asset_id
        AND    ah.asset_id        = ds.asset_id
        AND    ah.date_effective <= pc_deprn_date
        AND    pc_deprn_date     <  nvl (ah.date_ineffective, sysdate)
        AND    bk.book_type_code  = ds.book_type_code
        AND    bk.asset_id        = ds.asset_id
        AND    bk.date_effective <= pc_deprn_date
        AND    pc_deprn_date     <  nvl (bk.date_ineffective, sysdate)
      ORDER BY ah.category_id,
               ds.asset_id ;

    -----------------------------------------------------------------------------
    --  Get depreciation for an asset at distribution lines level              --
    -----------------------------------------------------------------------------

    CURSOR c_lines_depreciated (pc_tax_book        IN VARCHAR2,
                                pc_period_counter  IN NUMBER,
                                pc_asset_id        IN NUMBER,
                                pc_corporate_book  IN VARCHAR2
                               )
    IS
      SELECT   dd.distribution_id,
               nvl (dd.deprn_amount, 0)  adj_deprn_amount,
               nvl (dd.deprn_adjustment_amount, 0)  adj_deprn_adjustment_amount,
               nvl (dc.deprn_amount, 0)  corp_deprn_amount,
               nvl (dc.deprn_adjustment_amount, 0)  corp_deprn_adjustment_amount,
               dh.code_combination_id
      FROM     fa_deprn_detail          dd,
               fa_deprn_detail          dc,
               fa_distribution_history  dh
      WHERE    dd.asset_id          = pc_asset_id
        AND    dd.book_type_code    = pc_tax_book
        AND    dd.period_counter    = pc_period_counter
        AND    dc.asset_id          = dd.asset_id
        AND    dc.book_type_code    = pc_corporate_book
        AND    dc.period_counter    = dd.period_counter
        AND    dc.distribution_id   = dd.distribution_id
        AND    dh.distribution_id   = dd.distribution_id;

  BEGIN

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
       END IF;

    -----------------------------------------------------------------------------
    --  Procedure starts and writes the concurrent parameters on log file      --
    -----------------------------------------------------------------------------

    fnd_message.set_name ('JL', 'JL_CO_FA_PARAMETER');
    fnd_file.put_line (FND_FILE.LOG, fnd_message.get);
    fnd_file.put_line (FND_FILE.LOG, '----------------------------------------');
    fnd_message.set_name ('JL', 'JL_CO_FA_BOOK');
    fnd_message.set_token ('BOOK', p_tax_book);
    fnd_file.put_line (1, fnd_message.get);
    fnd_file.put_line (FND_FILE.LOG, '----------------------------------------');

    -----------------------------------------------------------------------------
    --  Define Who columns                                                     --
    -----------------------------------------------------------------------------

    x_last_updated_by        := fnd_global.user_id;
    x_last_update_login      := fnd_global.login_id;
    x_request_id             := fnd_global.conc_request_id;
    x_program_application_id := fnd_global.prog_appl_id;
    x_program_id             := fnd_global.conc_program_id;
    x_sysdate                := SYSDATE;

    -----------------------------------------------------------------------------
    --  Depreciation Tax book parameters                                       --
    -----------------------------------------------------------------------------

    SELECT  bc.accounting_flex_structure,
            bc.distribution_source_book,
            bc.last_period_counter,
            nvl (bc.global_attribute5, last_period_counter),
           -- bc.je_depreciation_category,
            bc.global_attribute6,
            bc.global_attribute7,
            bc.global_attribute8,
            bc.global_attribute9,
            bc.global_attribute10,
            bc.global_attribute11,
            bc.global_attribute12,
            bc.global_attribute13,
            bc.global_attribute14,
            bc.global_attribute15,
            bc.global_attribute16,
            bc.global_attribute17,
            bc.global_attribute18,
            dp.period_name,
            dp.period_close_date,
            sb.currency_code
    INTO    x_chart_of_accounts_id,
            x_corporate_book,
            x_period_counter,
            x_account_period,
           -- x_je_depreciation,
            x_je_infln_adjustment,
            x_je_ia_reclass,
            x_je_ia_cip_reclass,
            x_je_ia_transfer,
            x_je_ia_cip_transfer,
            x_je_ia_retirement,
            x_je_ia_cip_retirement,
            x_je_appraisal,
            x_je_ia_addition,
            x_je_ia_cip_addition,
            x_je_ia_adjustment,
            x_je_ia_cip_adjustment,
            x_je_cip_infln_adjustment,
            x_period_name,
            x_deprn_date,
            x_currency_code
    FROM    fa_book_controls   bc,
            fa_deprn_periods   dp,
            gl_sets_of_books   sb
    WHERE   bc.book_type_code  = p_tax_book
      AND   dp.book_type_code  = bc.book_type_code
      AND   dp.period_counter  = bc.last_period_counter
      AND   sb.set_of_books_id = bc.set_of_books_id ;

    SELECT je_category_name
    INTO x_je_depreciation
    FROM xla_event_class_attrs
    WHERE application_id = 140
      AND entity_code = 'DEPRECIATION'
      AND event_class_code = 'DEPRECIATION';

    -----------------------------------------------------------------------------
    --  Write close globalization period name on log file                      --
    -----------------------------------------------------------------------------

    fnd_message.set_name ('JL', 'JL_ZZ_FA_PERIOD_NAME');
    fnd_message.set_token ('PERIOD_NAME', x_period_name);
    fnd_file.put_line (1, fnd_message.get);

    -----------------------------------------------------------------------------
    --  Verify conditions to execute                                           --
    -----------------------------------------------------------------------------

    IF ( x_period_counter <> x_account_period + 1 ) THEN
      RAISE e_period_was_closed;
    END IF;

    -----------------------------------------------------------------------------
    --  Get currency parameters                                                --
    -----------------------------------------------------------------------------

    fnd_currency.get_info (x_currency_code,
                           x_precision,
                           x_extended_precision,
                           x_minumum_accountable_unit
                          );

    -----------------------------------------------------------------------------
    --  Identify the segment numbers for qualified segments:                   --
    --    Balance - Cost center - Natural account                              --
    --    LER, 18-Jun-99   Balancing and cost center segment are not more used --
    -----------------------------------------------------------------------------

--    x_temporal := fnd_flex_apis.get_qualifier_segnum (x_appl_id,
--                                                      x_key_flex_code,
--                                                      x_chart_of_accounts_id,
--                                                      x_balancing_qualifier,
--                                                      x_balancing_segment
--                                                     );

--    x_temporal := fnd_flex_apis.get_qualifier_segnum (x_appl_id,
--                                                      x_key_flex_code,
--                                                      x_chart_of_accounts_id,
--                                                      x_cost_ctr_qualifier,
--                                                      x_cost_ctr_segment
--                                                     );

    x_temporal := fnd_flex_apis.get_qualifier_segnum (x_appl_id,
                                                      x_key_flex_code,
                                                      x_chart_of_accounts_id,
                                                      x_account_qualifier,
                                                      x_account_segment
                                                     );

    -----------------------------------------------------------------------------
    --  Get character used as delimiter to show accounting flexfield           --
    -----------------------------------------------------------------------------

    x_delimiter := fnd_flex_ext.get_delimiter (x_apps_short_name,
                                               x_key_flex_code,
                                               x_chart_of_accounts_id
                                              );

    -----------------------------------------------------------------------------
    --  Transactions for tracking                                              --
    -----------------------------------------------------------------------------

    x_asset_id := 0;
    x_category_id := 0;
    x_old_category_id := 0;

    FOR tr IN c_transac (p_tax_book,
                         x_corporate_book,
                         x_period_counter
                        ) LOOP

      -----------------------------------------------------------------------------
      --  Write asset and transaction number on log file                         --
      -----------------------------------------------------------------------------

      fnd_message.set_name ('JL', 'JL_CO_FA_TRANSACTION');
      fnd_message.set_token ('ASSET', tr.asset_number);
      fnd_message.set_token ('TRANSACTION_ID', tr.transaction_header_id);
      fnd_message.set_token ('TRANSACTION_TYPE', tr.transaction_type_code);
      fnd_file.put_line (1, fnd_message.get);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'tr.deprn_to_cost = ' || to_char(tr.deprn_to_cost);
        fnd_file.put_line (FND_FILE.LOG, x_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;
      -----------------------------------------------------------------------------
      --  Asset category parameters                                              --
      --    LER, 18-Jun-99   CCIDs are not more stored in FA_BOOKS_CONTROLS.GDF; --
      --                     now are only stored the natural accouns             --
      -----------------------------------------------------------------------------

      IF (tr.category_id <> x_category_id) THEN
        x_category_id := tr.category_id;

        OPEN c_accounts (x_category_id,
                         p_tax_book
                        ) ;
--        FETCH c_accounts INTO x_deprn_reserve_ccid,
--                              x_deprn_reserve_segm,
--                              x_ia_cost_ccid,
--                              x_ix_cost_ccid,
--                              x_ia_deprn_reserve_ccid,
--                              x_ix_deprn_reserve_ccid,
--                              x_ia_cip_cost_ccid,
--                              x_ix_cip_cost_ccid,
--                              x_ta_revaluation_ccid,
--                              x_ta_surplus_ccid,
--                              x_ta_reserve_ccid,
--                              x_ta_reserve_expense_ccid,
--                              x_ta_reserve_recovery_ccid ;
        FETCH c_accounts INTO x_deprn_reserve_ccid,
                              x_deprn_reserve_segm,
                              x_ia_cost_segm,
                              x_ix_cost_segm,
                              x_ia_deprn_reserve_segm,
                              x_ix_deprn_reserve_segm,
                              x_ia_cip_cost_segm,
                              x_ix_cip_cost_segm,
                              x_ta_revaluation_segm,
                              x_ta_surplus_segm,
                              x_ta_reserve_segm,
                              x_ta_reserve_expense_segm,
                              x_ta_reserve_recovery_segm ;
        CLOSE c_accounts;

--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ia_cost_ccid,
--                         x_ia_cost_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ix_cost_ccid,
--                         x_ix_cost_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ia_deprn_reserve_ccid,
--                         x_ia_deprn_reserve_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ix_deprn_reserve_ccid,
--                         x_ix_deprn_reserve_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ia_cip_cost_ccid,
--                         x_ia_cip_cost_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ix_cip_cost_ccid,
--                         x_ix_cip_cost_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ta_revaluation_ccid,
--                         x_ta_revaluation_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ta_surplus_ccid,
--                         x_ta_surplus_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ta_reserve_ccid,
--                         x_ta_reserve_segm
--                        );
--        extract_account (x_chart_of_accounts_id,
--                         x_apps_short_name,
--                         x_key_flex_code,
--                         x_account_segment,
--                         x_ta_reserve_recovery_ccid,
--                         x_ta_reserve_recovery_segm
--                        );
      END IF;

      -----------------------------------------------------------------------------
      --  Asset parameters                                                       --
      --  Bug Fix 1098809  The assignment of tr.deprn_to_cost to x_deprn_to_cost --
      --                   is taken out of the IF statement.                     --
      --                   Earlier for a given asset and category_id, if there   --
      --                   are multiple transaction in the period, deprn_to_cost --
      --                   of only first transaction is assigned to the          --
      --                   x_deprn_to_cost.                                      --
      --  The above statement is incorrect.                                      --
      --  Bug Fix 1212946  The variable x_deprn_to_cost need not be initialized  --
      --                   for each transaction. For each asset, if there are    --
      --                   multiple transactions, we need recalculated           --
      --                   deprn_to_cost after each transaction.                 --
      --                   Therefore, previous changes are reverted.             --
      -----------------------------------------------------------------------------

      IF (tr.asset_id <> x_asset_id) THEN
        x_asset_id := tr.asset_id;
        x_deprn_to_cost := tr.deprn_to_cost;
        x_addition_flag := TRUE;
        x_adjustment_flag := TRUE;
      END IF;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Initial x_deprn_to_cost = ' || to_char(x_deprn_to_cost);
        fnd_file.put_line (FND_FILE.LOG, x_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      -----------------------------------------------------------------------------
      --  REVALUATION = Inflation Adjustments                                    --
      -----------------------------------------------------------------------------

      IF ( tr.transaction_type_code = 'REVALUATION' ) THEN
        x_global_source := 'INFLN ADJUST';

        FOR ra IN c_tr_adjustments_no_adj_type (tr.transaction_header_id,
                                    tr.book_type_code,
                                    x_period_counter
                                   ) LOOP

          --FA SLA Changes.
          IF ra.code_combination_id is null then
            l_book_type_code := tr.book_type_code;
            RAISE e_ccid_not_found;
          END IF;

          IF (ra.debit_credit_flag = 'DR') THEN
            x_debit_credit_flag := 'CR';
           ELSE
            x_debit_credit_flag := 'DR';
          END IF;

          IF (ra.adjustment_type = x_cost_name) THEN

            -----------------------------------------------------------------------------
            --  Capitalized cost inflation adjustments                                 --
            -----------------------------------------------------------------------------

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ia_cost_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_infln_adjustment,
                               x_ia_cost_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               ra.adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ix_cost_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_infln_adjustment,
                               x_ix_cost_name,
                               x_debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               ra.adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

           ELSIF (ra.adjustment_type = x_reserve_name) THEN

            -----------------------------------------------------------------------------
            --  Depreciation reserve inflation adjustments                             --
            -----------------------------------------------------------------------------

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ix_deprn_reserve_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_infln_adjustment,
                               x_ix_reserve_name,
                               x_debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               ra.adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ia_deprn_reserve_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_infln_adjustment,
                               x_ia_reserve_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               ra.adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

           ELSIF (ra.adjustment_type = x_cip_cost_name) THEN
            x_global_source := 'CIP INFLN ADJST';

            -----------------------------------------------------------------------------
            --  CIP cost inflation adjustments                                         --
            -----------------------------------------------------------------------------

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ia_cip_cost_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_cip_infln_adjustment,
                               x_ia_cip_cost_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               ra.adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ix_cip_cost_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_cip_infln_adjustment,
                               x_ix_cip_cost_name,
                               x_debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               ra.adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );
          END IF;
        END LOOP;

        -----------------------------------------------------------------------------
        --  ADDITION / ADJUSTMENT                                                  --
        -----------------------------------------------------------------------------

       ELSIF tr.transaction_type_code IN ('ADDITION',
                                          'CIP ADDITION',
                                          'ADJUSTMENT',
                                          'CIP ADJUSTMENT'
                                         ) THEN

        IF (tr.transaction_type_code = 'ADDITION') THEN
          x_global_source := 'IA ADDITION';
          x_je_category_name := x_je_ia_addition;
          x_je_std_category_name := x_je_ia_addition;
          x_temporal := x_addition_flag;

         ELSIF (tr.transaction_type_code = 'CIP ADDITION') THEN
          x_global_source := 'IA CIP ADDITION';
          x_je_category_name := x_je_ia_cip_addition;
          x_je_std_category_name := x_je_ia_cip_addition;
          x_temporal := x_addition_flag;

         ELSIF (tr.transaction_type_code = 'ADJUSTMENT') THEN
          x_global_source := 'IA ADJUSTMENT';
          x_je_category_name := x_je_ia_adjustment;
          x_je_std_category_name := x_je_ia_adjustment;
          x_temporal := x_adjustment_flag;

         ELSIF (tr.transaction_type_code = 'CIP ADJUSTMENT') THEN
          x_global_source := 'IA CIP ADJUST';
          x_je_category_name := x_je_ia_cip_adjustment;
          x_je_std_category_name := x_je_ia_cip_adjustment;
          x_temporal := x_adjustment_flag;

        END IF;

        -----------------------------------------------------------------------------
        --  Looking for ADDITION / ADJUSTMENT transactions in Corporate book       --
        --    when Source_Transaction_Header_Id is NULL.                           --
        -----------------------------------------------------------------------------

        IF (x_temporal = TRUE) THEN
          IF (tr.source_transaction_header_id IS NULL) THEN
            IF tr.transaction_type_code IN ('ADDITION',
                                            'ADJUSTMENT'
                                           ) THEN

              -----------------------------------------------------------------------------
              --  Adjustments to Depreciation Reserve                                    --
              -----------------------------------------------------------------------------

              OPEN c_sum_all_adjustments (tr.asset_id,
                                          p_tax_book,
                                          x_period_counter,
                                          x_reserve_name,
                                          'DR'
                                         );
              FETCH c_sum_all_adjustments INTO x_value_1;
              CLOSE c_sum_all_adjustments;

              OPEN c_sum_all_adjustments (tr.asset_id,
                                          x_corporate_book,
                                          x_period_counter,
                                          x_reserve_name,
                                          'DR'
                                         );
              FETCH c_sum_all_adjustments INTO x_value_2;
              IF (c_sum_all_adjustments%FOUND = FALSE) THEN
                x_value_2 := 0;
              END IF;
              CLOSE c_sum_all_adjustments;

              OPEN c_sum_adjustments (tr.asset_id,
                                      p_tax_book,
                                      tr.transaction_header_id,
                                      x_reserve_name,
                                      'DR'
                                     );
              FETCH c_sum_adjustments INTO x_adjustment_amount;
              IF (c_sum_adjustments%FOUND = FALSE) THEN
                x_adjustment_amount := 0;
              END IF;
              CLOSE c_sum_adjustments;

              IF x_adjustment_amount = 0 THEN
                x_reserve_dr := 0;
               ELSE
                x_reserve_dr := (x_value_1 - x_value_2) / x_adjustment_amount;
              END IF;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                x_char := 'Value 1 = ' || to_char(x_value_1);
                fnd_file.put_line (FND_FILE.LOG, x_char);
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
                x_char := 'Value 2= ' || to_char(x_value_2);
                fnd_file.put_line (FND_FILE.LOG, x_char);
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
                x_char := 'x_adjustment = ' || to_char(x_adjustment_amount);
                fnd_file.put_line (FND_FILE.LOG, x_char);
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
                x_char := 'x_reserve_dr = ' || to_char(x_reserve_dr);
                fnd_file.put_line (FND_FILE.LOG, x_char);
                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              END IF;

              OPEN c_sum_all_adjustments (tr.asset_id,
                                          p_tax_book,
                                          x_period_counter,
                                          x_reserve_name,
                                          'CR'
                                         );
              FETCH c_sum_all_adjustments INTO x_value_1;
              CLOSE c_sum_all_adjustments;

              OPEN c_sum_all_adjustments (tr.asset_id,
                                          x_corporate_book,
                                          x_period_counter,
                                          x_reserve_name,
                                          'CR'
                                         );
              FETCH c_sum_all_adjustments INTO x_value_2;
              IF (c_sum_all_adjustments%FOUND = FALSE) THEN
                x_value_2 := 0;
              END IF;
              CLOSE c_sum_all_adjustments;

              OPEN c_sum_adjustments (tr.asset_id,
                                      p_tax_book,
                                      tr.transaction_header_id,
                                      x_reserve_name,
                                      'CR'
                                     );
              FETCH c_sum_adjustments INTO x_adjustment_amount;
              IF (c_sum_adjustments%FOUND = FALSE) THEN
                x_adjustment_amount := 0;
              END IF;
              CLOSE c_sum_adjustments;

              IF (x_adjustment_amount = 0) THEN
                x_reserve_cr := 0;
               ELSE
                x_reserve_cr := (x_value_1 - x_value_2) / x_adjustment_amount;
              END IF;

              -----------------------------------------------------------------------------
              --  Adjustments to Depreciation Expense                                    --
              -----------------------------------------------------------------------------

              OPEN c_sum_all_adjustments (tr.asset_id,
                                          p_tax_book,
                                          x_period_counter,
                                          x_expense_name,
                                          'DR'
                                         );
              FETCH c_sum_all_adjustments INTO x_value_1;
              CLOSE c_sum_all_adjustments;

              OPEN c_sum_all_adjustments (tr.asset_id,
                                          x_corporate_book,
                                          x_period_counter,
                                          x_expense_name,
                                          'DR'
                                         );
              FETCH c_sum_all_adjustments INTO x_value_2;
              IF (c_sum_all_adjustments%FOUND = FALSE) THEN
                x_value_2 := 0;
              END IF;
              CLOSE c_sum_all_adjustments;

              OPEN c_sum_adjustments (tr.asset_id,
                                      p_tax_book,
                                      tr.transaction_header_id,
                                      x_expense_name,
                                      'DR'
                                     );
              FETCH c_sum_adjustments INTO x_adjustment_amount;
              IF (c_sum_adjustments%FOUND = FALSE) THEN
                x_adjustment_amount := 0;
              END IF;
              CLOSE c_sum_adjustments;

              IF x_adjustment_amount = 0 THEN
                x_expense_dr := 0;
               ELSE
                x_expense_dr := (x_value_1 - x_value_2) / x_adjustment_amount;
              END IF;

              OPEN c_sum_all_adjustments (tr.asset_id,
                                          p_tax_book,
                                          x_period_counter,
                                          x_expense_name,
                                          'CR'
                                         );
              FETCH c_sum_all_adjustments INTO x_value_1;
              CLOSE c_sum_all_adjustments;

              OPEN c_sum_all_adjustments (tr.asset_id,
                                          x_corporate_book,
                                          x_period_counter,
                                          x_expense_name,
                                          'CR'
                                         );
              FETCH c_sum_all_adjustments INTO x_value_2;
              IF (c_sum_all_adjustments%FOUND = FALSE) THEN
                x_value_2 := 0;
              END IF;
              CLOSE c_sum_all_adjustments;

              OPEN c_sum_adjustments (tr.asset_id,
                                      p_tax_book,
                                      tr.transaction_header_id,
                                      x_expense_name,
                                      'CR'
                                     );
              FETCH c_sum_adjustments INTO x_adjustment_amount;
              IF (c_sum_adjustments%FOUND = FALSE) THEN
                x_adjustment_amount := 0;
              END IF;
              CLOSE c_sum_adjustments;

              IF (x_adjustment_amount = 0) THEN
                x_expense_cr := 0;
               ELSE
                x_expense_cr := (x_value_1 - x_value_2) / x_adjustment_amount;
              END IF;

              x_account_name := x_cost_name;
             ELSE
              x_account_name := x_cip_cost_name;
            END IF;

            -----------------------------------------------------------------------------
            --  Adjustments to Cost (Capitalized or CIP)                               --
            -----------------------------------------------------------------------------

            OPEN c_sum_all_adjustments (tr.asset_id,
                                        p_tax_book,
                                        x_period_counter,
                                        x_account_name,
                                        'DR'
                                       );
            FETCH c_sum_all_adjustments INTO x_value_1;
            CLOSE c_sum_all_adjustments;

            OPEN c_sum_all_adjustments (tr.asset_id,
                                        x_corporate_book,
                                        x_period_counter,
                                        x_account_name,
                                        'DR'
                                       );
            FETCH c_sum_all_adjustments INTO x_value_2;
            IF (c_sum_all_adjustments%FOUND = FALSE) THEN
              x_value_2 := 0;
            END IF;
            CLOSE c_sum_all_adjustments;

            OPEN c_sum_adjustments (tr.asset_id,
                                    p_tax_book,
                                    tr.transaction_header_id,
                                    x_account_name,
                                    'DR'
                                   );
            FETCH c_sum_adjustments INTO x_adjustment_amount;
            IF (c_sum_adjustments%FOUND = FALSE) THEN
              x_adjustment_amount := 0;
            END IF;
            CLOSE c_sum_adjustments;

            IF x_adjustment_amount = 0 THEN
              x_cost_dr := 0;
             ELSE
              x_cost_dr := (x_value_1 - x_value_2) / x_adjustment_amount;
            END IF;

            OPEN c_sum_all_adjustments (tr.asset_id,
                                        p_tax_book,
                                        x_period_counter,
                                        x_account_name,
                                        'CR'
                                       );
            FETCH c_sum_all_adjustments INTO x_value_1;
            CLOSE c_sum_all_adjustments;

            OPEN c_sum_all_adjustments (tr.asset_id,
                                        x_corporate_book,
                                        x_period_counter,
                                        x_account_name,
                                        'CR'
                                       );
            FETCH c_sum_all_adjustments INTO x_value_2;
            IF (c_sum_all_adjustments%FOUND = FALSE) THEN
              x_value_2 := 0;
            END IF;
            CLOSE c_sum_all_adjustments;

            OPEN c_sum_adjustments (tr.asset_id,
                                    p_tax_book,
                                    tr.transaction_header_id,
                                    x_account_name,
                                    'CR'
                                   );
            FETCH c_sum_adjustments INTO x_adjustment_amount;
            IF (c_sum_adjustments%FOUND = FALSE) THEN
              x_adjustment_amount := 0;
            END IF;
            CLOSE c_sum_adjustments;

            IF x_adjustment_amount = 0 THEN
              x_cost_cr := 0;
             ELSE
              x_cost_cr := (x_value_1 - x_value_2) / x_adjustment_amount;
            END IF;

            IF (tr.transaction_type_code IN ('ADDITION',
                                             'CIP ADDITION')
                                            ) THEN
              x_addition_flag := FALSE;
             ELSE
              x_adjustment_flag := FALSE;
            END IF;
          END IF;

          -----------------------------------------------------------------------------
          --  Retrieve adjustments generated by standard depreciation program        --
          -----------------------------------------------------------------------------

          FOR ra IN c_tr_adjustments_no_adj_type (tr.transaction_header_id,
                                      tr.book_type_code,
                                      x_period_counter
                                     ) LOOP

            --FA SLA Changes.
            IF ra.code_combination_id is null then
              l_book_type_code := tr.book_type_code;
              RAISE e_ccid_not_found;
            END IF;


            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'Adjustment for Line = ' || to_char(ra.distribution_id) || ' ' || ra.adjustment_type;
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            IF (tr.source_transaction_header_id IS NULL) THEN
              IF (ra.adjustment_type IN (x_cost_name,
                                         x_cip_cost_name)
                                        ) THEN
                IF (ra.debit_credit_flag = 'DR') THEN
                  x_adjustment_amount := round (ra.adjustment_amount * x_cost_dr, x_precision);
                 ELSE
                  x_adjustment_amount := round (ra.adjustment_amount * x_cost_cr, x_precision);
                END IF;
               ELSIF (ra.adjustment_type = x_reserve_name) THEN
                IF (ra.debit_credit_flag = 'DR') THEN
                  x_adjustment_amount := round (ra.adjustment_amount * x_reserve_dr, x_precision);
                 ELSE
                  x_adjustment_amount := round (ra.adjustment_amount * x_reserve_cr, x_precision);
                END IF;
               ELSIF (ra.adjustment_type = x_expense_name) THEN
                IF (ra.debit_credit_flag = 'DR') THEN

                  x_adjustment_amount := round (ra.adjustment_amount * x_expense_dr, x_precision);
                 ELSE
                  x_adjustment_amount := round (ra.adjustment_amount * x_expense_cr, x_precision);
                END IF;
              END IF;
             ELSE
              OPEN c_tr_rel_adjustments (tr.source_transaction_header_id,
                                         x_corporate_book,
                                         ra.source_type_code,
                                         ra.adjustment_type,
                                         ra.debit_credit_flag,
                                         ra.distribution_id
                                        );
              FETCH c_tr_rel_adjustments INTO x_code_combination_id,
                                              x_adjustment_amount;
              IF (c_tr_rel_adjustments%FOUND = FALSE) THEN
                x_adjustment_amount := 0;
              END IF;
              CLOSE c_tr_rel_adjustments;
              x_adjustment_amount := round (ra.adjustment_amount - x_adjustment_amount, x_precision);
            END IF;

            IF (ra.debit_credit_flag = 'DR') THEN
              x_debit_credit_flag := 'CR';
             ELSE
              x_debit_credit_flag := 'DR';
            END IF;

            IF (ra.adjustment_type = x_cost_name) THEN

              -----------------------------------------------------------------------------
              --  Cost inflation adjustments of the capitalized assets                   --
              -----------------------------------------------------------------------------

              IF (tr.transaction_type_code = 'ADDITION'
                    AND tr.period_counter_capitalized = x_period_counter
                    AND tr.asset_type = 'CAPITALIZED'
                 ) THEN

                insert_adjustment (tr.transaction_header_id,
                                   x_global_source,
                                   x_je_category_name,
                                   x_cost_name,
                                   ra.debit_credit_flag,
                                   ra.code_combination_id,
                                   p_tax_book,
                                   tr.asset_id,
                                   x_adjustment_amount,
                                   ra.distribution_id,
                                   ra.annualized_adjustment,
                                   NULL,
                                   NULL,
                                   ra.period_counter_adjusted,
                                   ra.period_counter_created,
                                   ra.asset_invoice_id,
                                   NULL,
                                   NULL
                                  );
               ELSE
                change_account (x_chart_of_accounts_id,
                                x_apps_short_name,
                                x_key_flex_code,
                                x_account_segment,
                                ra.code_combination_id,
                                x_ia_cost_segm,
                                x_delimiter,
                                x_returned_ccid,
                                x_error_ccid
                               );

                insert_adjustment (tr.transaction_header_id,
                                   x_global_source,
                                   x_je_category_name,
                                   x_ia_cost_name,
                                   ra.debit_credit_flag,
                                   x_returned_ccid,
                                   p_tax_book,
                                   tr.asset_id,
                                   x_adjustment_amount,
                                   ra.distribution_id,
                                   ra.annualized_adjustment,
                                   NULL,
                                   NULL,
                                   ra.period_counter_adjusted,
                                   ra.period_counter_created,
                                   ra.asset_invoice_id,
                                   NULL,
                                   NULL
                                  );

                change_account ( x_chart_of_accounts_id,
                                 x_apps_short_name,
                                 x_key_flex_code,
                                 x_account_segment,
                                 ra.code_combination_id,
                                 x_ix_cost_segm,
                                 x_delimiter,
                                 x_returned_ccid,
                                 x_error_ccid
                               );

                insert_adjustment (tr.transaction_header_id,
                                   x_global_source,
                                   x_je_category_name,
                                   x_ix_cost_name,
                                   x_debit_credit_flag,
                                   x_returned_ccid,
                                   p_tax_book,
                                   tr.asset_id,
                                   x_adjustment_amount,
                                   ra.distribution_id,
                                   ra.annualized_adjustment,
                                   NULL,
                                   NULL,
                                   ra.period_counter_adjusted,
                                   ra.period_counter_created,
                                   ra.asset_invoice_id,
                                   NULL,
                                   NULL
                                  );
              END IF;

             ELSIF (ra.adjustment_type = x_expense_name) THEN

              -----------------------------------------------------------------------------
              --  Depreciation to cost inflation adjustments of the capitalized assets   --
              -----------------------------------------------------------------------------

              x_deprn_to_cost := x_deprn_to_cost + x_adjustment_amount;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                x_char := 'x_deprn_to_cost A = ' || to_char(x_deprn_to_cost);
                fnd_file.put_line (FND_FILE.LOG, x_char);
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              END IF;

              insert_adjustment (tr.transaction_header_id,
                                 'DEPRECIATION',
                                 x_je_depreciation,
                                 x_expense_name,
                                 ra.debit_credit_flag,
                                 ra.code_combination_id,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 x_period_counter,
                                 x_period_counter,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );

              fa_gccid_pkg.fafbgcc_proc (p_tax_book,
                                         'DEPRN_RESERVE_ACCT',
                                         ra.code_combination_id,
                                         x_deprn_reserve_segm,
                                         x_deprn_reserve_ccid,
                                         ra.distribution_id,
                                         x_returned_ccid,
                                         x_concat_segs,
                                         x_return_value
                                        );

              IF (x_return_value = 0) then
                fnd_message.set_name ('JL', 'JL_CO_FA_CCID_NOT_CREATED');
                fnd_message.set_token ('ACCOUNT', x_concat_segs);
                --Bug 2929483. Missing log message handling has been added.
                fnd_file.put_line     (FND_FILE.LOG, fnd_message.get);
                x_error_ccid := TRUE;
               ELSE
                insert_adjustment (tr.transaction_header_id,
                                   'DEPRECIATION',
                                   x_je_depreciation,
                                   x_reserve_name,
                                   x_debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 x_period_counter,
                                 x_period_counter,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );
              END IF;

             ELSIF (ra.adjustment_type = x_reserve_name) THEN

              -----------------------------------------------------------------------------
              --  Depreciation reserve inflation adjustments                             --
              -----------------------------------------------------------------------------

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ix_deprn_reserve_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_source,
                                 x_je_category_name,
                                 x_ix_reserve_name,
                                 x_debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ia_deprn_reserve_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_source,
                                 x_je_category_name,
                                 x_ia_reserve_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );

             ELSIF (ra.adjustment_type = x_cip_cost_name) THEN

              -----------------------------------------------------------------------------
              --  Cost inflation adjustments to the CIP assets                           --
              -----------------------------------------------------------------------------

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ia_cip_cost_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_source,
                                 x_je_category_name,
                                 x_ia_cip_cost_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );

              IF (tr.transaction_type_code <> 'ADDITION'
                    OR tr.period_counter_capitalized <> x_period_counter
                    OR tr.asset_type <> 'CAPITALIZED'
                 ) THEN

                change_account ( x_chart_of_accounts_id,
                                 x_apps_short_name,
                                 x_key_flex_code,
                                 x_account_segment,
                                 ra.code_combination_id,
                                 x_ix_cip_cost_segm,
                                 x_delimiter,
                                 x_returned_ccid,
                                 x_error_ccid
                               );

                insert_adjustment (tr.transaction_header_id,
                                   x_global_source,
                                   x_je_category_name,
                                   x_ix_cip_cost_name,
                                   x_debit_credit_flag,
                                   x_returned_ccid,
                                   p_tax_book,
                                   tr.asset_id,
                                   x_adjustment_amount,
                                   ra.distribution_id,
                                   ra.annualized_adjustment,
                                   NULL,
                                   NULL,
                                   ra.period_counter_adjusted,
                                   ra.period_counter_created,
                                   ra.asset_invoice_id,
                                   NULL,
                                   NULL
                                  );
              END IF;
            END IF;
          END LOOP;
        END IF;

        -----------------------------------------------------------------------------
        --  RECLASSIFICATION / TRANSFER / UNIT ADJUSTMENT                          --
        -----------------------------------------------------------------------------

       ELSIF tr.transaction_type_code IN ('RECLASS',
                                          'CIP RECLASS',
                                          'TRANSFER',
                                          'CIP TRANSFER',
                                          'UNIT ADJUSTMENT'
                                         ) THEN

        IF (tr.transaction_type_code = 'RECLASS') THEN
          x_global_source := 'IA RECLASS';
          x_je_category_name := x_je_ia_reclass;
          x_je_std_category_name := x_je_ia_reclass;

         ELSIF (tr.transaction_type_code = 'CIP RECLASS') THEN
          x_global_source := 'IA CIP RECLASS';
          x_je_category_name := x_je_ia_cip_reclass;
          x_je_std_category_name := x_je_ia_cip_reclass;

         ELSIF (tr.transaction_type_code = 'TRANSFER') THEN
          x_global_source := 'IA TRANSFER';
          x_je_category_name := x_je_ia_transfer;
          x_je_std_category_name := x_je_ia_transfer;

         ELSIF (tr.transaction_type_code = 'CIP TRANSFER') THEN
          x_global_source := 'IA CIP TRANSFER';
          x_je_category_name := x_je_ia_cip_transfer;
          x_je_std_category_name := x_je_ia_cip_transfer;

         ELSIF (tr.transaction_type_code = 'UNIT ADJUSTMENT') THEN
          IF (tr.asset_type = 'CAPITALIZED') THEN
            x_global_source := 'IA TRANSFER';
            x_je_category_name := x_je_ia_transfer;
            x_je_std_category_name := x_je_ia_transfer;

           ELSIF (tr.asset_type = 'CIP') THEN
            x_global_source := 'IA CIP TRANSFER';
            x_je_category_name := x_je_ia_cip_transfer;
            x_je_std_category_name := x_je_ia_cip_transfer;
          END IF;

        END IF;

        -----------------------------------------------------------------------------
        --  Get historical and adjusted values to reserve inflation adjustments    --
        -----------------------------------------------------------------------------

        OPEN c_deprn_summary (x_corporate_book,
                              tr.asset_id,
                              x_period_counter - 1
                             );
        FETCH c_deprn_summary INTO x_corp_deprn_reserve,
                                   x_corp_reval_reserve,
                                   x_corp_reval_deprn_expense;
        CLOSE c_deprn_summary;

        OPEN c_deprn_summary (p_tax_book,
                              tr.asset_id,
                              x_period_counter - 1
                             );
        FETCH c_deprn_summary INTO x_adj_deprn_reserve,
                                   x_adj_reval_reserve,
                                   x_adj_reval_deprn_expense;
        CLOSE c_deprn_summary;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Corp Reserve = ' || to_char(x_corp_deprn_reserve);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Adj Reserve = ' || to_char(x_adj_deprn_reserve);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        OPEN c_sum_adjustments (tr.asset_id,
                                x_corporate_book,
                                tr.transaction_header_id,
                                x_reserve_name,
                                'DR'
                               );
        FETCH c_sum_adjustments INTO x_adjustment_amount;
        CLOSE c_sum_adjustments;

        OPEN c_sum_adjustments (tr.asset_id,
                                p_tax_book,
                                tr.transaction_header_id,
                                x_reserve_name,
                                'DR'
                               );
        FETCH c_sum_adjustments INTO x_adj_cost;
        CLOSE c_sum_adjustments;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Sum Corp Reserve = ' || to_char(x_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Sum Adj Reserve = ' || to_char(x_adj_cost);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        x_adjustment_amount := x_adj_cost - x_adjustment_amount;

--      The 0% revaluation :
--      In this case, accum. deprn in both corp and tax books at the beginning
--      of the period is same. The deprn to IA Cost at the beginning of the period
--      may or may not be zero.
--      Now, if the revaluation is non zero in the current period, we still don't
--      have the basis to calculate x_factor_1 because (x_adj_deprn_reserve - x_corp_
--      deprn_reserve) = 0. In this scenario, adjusted accum deprn should be equal to
--      IA to accum. depr and the deprn to IA cost = 0.
--      This in turn, means x_factor_11 = 0 and x_factor_12 = 1.

        IF (x_adj_deprn_reserve = x_corp_deprn_reserve) THEN
          x_factor_1 := 0;
        ELSE
          x_factor_1 := x_adjustment_amount / (x_adj_deprn_reserve - x_corp_deprn_reserve);
        END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'x_adjustment_amount = ' || to_char(x_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Factor_1 = ' || to_char(x_factor_1);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        IF ((x_adj_cost <> 0) AND (x_adjustment_amount <> 0)) THEN
          x_factor_12 := x_deprn_to_cost * x_factor_1;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'Factor_12 = ' || to_char(x_factor_12);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          x_factor_11 := x_factor_12 / x_adjustment_amount;
          x_factor_12 := (x_adjustment_amount - x_factor_12) / x_adjustment_amount;
         ELSE
          x_factor_11 := 0;
          x_factor_12 := 0;
        END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Factor_11 = ' || to_char(x_factor_11);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Factor_12 = ' || to_char(x_factor_12);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        --x_ta_factor := abs (tr.appraisal_balance) / tr.adj_cost;

        ----------------------------------------------------------------------------
        --BUG 3865352
        ----------------------------------------------------------------------------
        IF tr.adj_cost = 0 THEN
          x_ta_factor := 0;
        ELSE
          x_ta_factor := abs (tr.appraisal_balance) / tr.adj_cost;
        END IF;



        -----------------------------------------------------------------------------
        --  For Reclassifications, get the account of the prior asset category     --
        --    LER, 18-Jun-99   CCIDs are not more stered in FA_BOOKS_CONTROLS.GDF  --
        --                     now are only stored the natural accouns             --
        -----------------------------------------------------------------------------

        IF tr.transaction_type_code IN ('RECLASS',
                                        'CIP RECLASS'
                                       ) THEN

          OPEN c_prior_category (tr.asset_id,
                                 tr.transaction_header_id
                                );
          FETCH c_prior_category INTO x_prior_category_id;
          CLOSE c_prior_category;

          IF (x_prior_category_id <> x_old_category_id) THEN
            x_old_category_id := x_prior_category_id;

            OPEN c_accounts (x_prior_category_id,
                             p_tax_book
                            ) ;
--            FETCH c_accounts INTO x_old_deprn_reserve_ccid,
--                                  x_old_deprn_reserve_segm,
--                                  x_old_ia_cost_ccid,
--                                  x_old_ix_cost_ccid,
--                                  x_old_ia_deprn_reserve_ccid,
--                                  x_old_ix_deprn_reserve_ccid,
--                                  x_old_ia_cip_cost_ccid,
--                                  x_old_ia_cip_cost_ccid,
--                                  x_old_ta_revaluation_ccid,
--                                  x_old_ta_surplus_ccid,
--                                  x_old_ta_reserve_ccid,
--                                  x_old_ta_reserve_expense_ccid,
--                                  x_old_ta_reserve_recovery_ccid ;
            FETCH c_accounts INTO x_old_deprn_reserve_ccid,
                                  x_old_deprn_reserve_segm,
                                  x_old_ia_cost_segm,
                                  x_old_ix_cost_segm,
                                  x_old_ia_deprn_reserve_segm,
                                  x_old_ix_deprn_reserve_segm,
                                  x_old_ia_cip_cost_segm,
                                  x_old_ia_cip_cost_segm,
                                  x_old_ta_revaluation_segm,
                                  x_old_ta_surplus_segm,
                                  x_old_ta_reserve_segm,
                                  x_old_ta_reserve_expense_segm,
                                  x_old_ta_reserve_recovery_segm ;
            CLOSE c_accounts;

--            extract_account (x_chart_of_accounts_id,
--                             x_apps_short_name,
--                             x_key_flex_code,
--                             x_account_segment,
--                             x_old_ia_cost_ccid,
--                             x_old_ia_cost_segm
--                            );
--            extract_account (x_chart_of_accounts_id,
--                             x_apps_short_name,
--                             x_key_flex_code,
--                             x_account_segment,
--                             x_old_ia_deprn_reserve_ccid,
--                             x_old_ia_deprn_reserve_segm
--                            );
--            extract_account (x_chart_of_accounts_id,
--                             x_apps_short_name,
--                             x_key_flex_code,
--                             x_account_segment,
--                             x_old_ia_cip_cost_ccid,
--                             x_old_ia_cip_cost_segm
--                            );
--            extract_account (x_chart_of_accounts_id,
--                             x_apps_short_name,
--                             x_key_flex_code,
--                             x_account_segment,
--                             x_old_ta_revaluation_ccid,
--                             x_old_ta_revaluation_segm
--                            );
--            extract_account (x_chart_of_accounts_id,
--                             x_apps_short_name,
--                             x_key_flex_code,
--                             x_account_segment,
--                             x_old_ta_surplus_ccid,
--                             x_old_ta_surplus_segm
--                            );
--            extract_account (x_chart_of_accounts_id,
--                             x_apps_short_name,
--                             x_key_flex_code,
--                             x_account_segment,
--                             x_old_ta_reserve_ccid,
--                             x_old_ta_reserve_segm
--                            );
          END IF;
        END IF;

        -----------------------------------------------------------------------------
        --  Loop for related rows in FA_ADJUSTMENTS for the transaction            --
        -----------------------------------------------------------------------------

        FOR ra IN c_tr_adjustments_no_adj_type (tr.transaction_header_id,
                                    tr.book_type_code,
                                    x_period_counter
                                   ) LOOP


          --FA SLA Changes.
          IF ra.code_combination_id is null then
            l_book_type_code := tr.book_type_code;
            RAISE e_ccid_not_found;
          END IF;



          OPEN c_tr_rel_adjustments (tr.transaction_header_id,
                                     p_tax_book,
                                     ra.source_type_code,
                                     ra.adjustment_type,
                                     ra.debit_credit_flag,
                                     ra.distribution_id
                                  );

          FETCH c_tr_rel_adjustments INTO x_code_combination_id,
                                          x_adjustment_amount;

          IF (c_tr_rel_adjustments%FOUND = TRUE) THEN
            x_adj_cost_line := x_adjustment_amount;
            x_adjustment_amount := x_adjustment_amount - ra.adjustment_amount ;
          END IF;
          IF (c_tr_rel_adjustments%FOUND = FALSE) THEN
            x_adjustment_amount := 0;
          END IF;
          CLOSE c_tr_rel_adjustments;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := ra.adjustment_type || ' ' || ra.debit_credit_flag || ' ' || to_char(x_adjustment_amount);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          IF (ra.debit_credit_flag = 'DR') THEN
            x_debit_credit_flag := 'CR';
           ELSE
            x_debit_credit_flag := 'DR';
          END IF;

          IF (ra.adjustment_type = x_cost_name) THEN

            -----------------------------------------------------------------------------
            --  Capitalized cost inflation adjustments                                 --
            -----------------------------------------------------------------------------

            IF (tr.transaction_type_code = 'RECLASS'
                  AND ra.debit_credit_flag = 'CR' ) THEN
              x_natural_account := x_old_ia_cost_segm;
             ELSE
              x_natural_account := x_ia_cost_segm;
            END IF;

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_natural_account,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_category_name,
                               x_ia_cost_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

           ELSIF (ra.adjustment_type = x_reserve_name) THEN

            -----------------------------------------------------------------------------
            --  Depreciation reserve inflation adjustments                             --
            -----------------------------------------------------------------------------

            x_value_1 := round (x_adjustment_amount * x_factor_11, x_precision);
            x_value_2 := round (x_adjustment_amount * x_factor_12, x_precision);

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'x_value_1 = ' || to_char(x_value_1);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              x_char := 'x_value_2 = ' || to_char(x_value_2);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_std_category_name,
                               x_reserve_name,
                               ra.debit_credit_flag,
                               ra.code_combination_id,
                               p_tax_book,
                               tr.asset_id,
                               x_value_1,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

            IF (tr.transaction_type_code = 'RECLASS'
                AND ra.debit_credit_flag = 'DR' ) THEN
              x_natural_account := x_old_ia_deprn_reserve_segm;
             ELSE
              x_natural_account := x_ia_deprn_reserve_segm;
            END IF;

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_natural_account,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_category_name,
                               x_ia_reserve_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               x_value_2,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

           ELSIF (ra.adjustment_type = x_expense_name) THEN

            -----------------------------------------------------------------------------
            --  Calculate the adjustments to depreciation expense due to transaction   --
            -----------------------------------------------------------------------------

            insert_adjustment (tr.transaction_header_id,
                               'DEPRECIATION',
                               x_je_depreciation,
                               x_expense_name,
                               ra.debit_credit_flag,
                               ra.code_combination_id,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               x_period_counter,
                               x_period_counter,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

              -----------------------------------------------------------------------------
              --    LER, 18-Jun-99   The following section was cancelled because the     --
              --                     reserve was completely transferred in previous      --
              --                     section.                                            --
              -----------------------------------------------------------------------------

--            fa_gccid_pkg.fafbgcc_proc (p_tax_book,
--                                       'DEPRN_RESERVE_ACCT',
--                                       ra.code_combination_id,
--                                       x_deprn_reserve_segm,
--                                       x_deprn_reserve_ccid,
--                                       ra.distribution_id,
--                                       x_returned_ccid,
--                                       x_concat_segs,
--                                       x_return_value
--                                      );

--            IF (x_return_value = 0) then
--              fnd_message.set_name ('JL', 'JL_CO_FA_CCID_NOT_CREATED');
--              fnd_message.set_token ('ACCOUNT', x_concat_segs);
--              x_error_ccid := TRUE;

--             ELSE
--              insert_adjustment (tr.transaction_header_id,
--                                 'DEPRECIATION',
--                                 x_je_depreciation,
--                                 x_reserve_name,
--                                 x_debit_credit_flag,
--                                 x_returned_ccid,
--                                 p_tax_book,
--                                 tr.asset_id,
--                                 x_adjustment_amount,
--                                 ra.distribution_id,
--                                 ra.annualized_adjustment,
--                                 NULL,
--                                 NULL,
--                                 x_period_counter,
--                                 x_period_counter,
--                                 ra.asset_invoice_id,
--                                 NULL,
--                                 NULL
--                                );
--            END IF;

           ELSIF (ra.adjustment_type = x_cip_cost_name) THEN

            -----------------------------------------------------------------------------
            --  CIP cost inflation adjustments                                         --
            -----------------------------------------------------------------------------

            IF (tr.transaction_type_code = 'CIP RECLASS'
                AND ra.debit_credit_flag = 'CR' ) THEN
              x_natural_account := x_old_ia_cip_cost_segm;
             ELSE
              x_natural_account := x_ia_cip_cost_segm;
            END IF;

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_natural_account,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_category_name,
                               x_ia_cip_cost_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );
          END IF;

          -----------------------------------------------------------------------------
          --  Transferring Technical Appraisal Account Balances                      --
          -----------------------------------------------------------------------------

          IF ra.adjustment_type IN (x_cost_name,
                                    x_cip_cost_name)
                                THEN

            x_ta_line_amount := round (x_adj_cost_line * x_ta_factor, x_precision);

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'Appraisal Line Amount = ' || to_char (x_ta_line_amount);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            IF (tr.appraisal_balance > 0) THEN
              IF (tr.transaction_type_code IN ('RECLASS', 'CIP RECLASS')
                  AND ra.debit_credit_flag = 'CR' ) THEN
                x_natural_account := x_old_ta_revaluation_segm;
                x_natural_account1 := x_old_ta_surplus_segm;
               ELSE
                x_natural_account := x_ta_revaluation_segm;
                x_natural_account1 := x_ta_surplus_segm;
              END IF;

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_natural_account,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_revaluation_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_natural_account1,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_surplus_name,
                                 x_debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );

             ELSIF (tr.appraisal_balance < 0) THEN

              IF (tr.transaction_type_code IN ('RECLASS', 'CIP RECLASS')
                  AND ra.debit_credit_flag = 'CR' ) THEN
                x_natural_account := x_old_ta_reserve_segm;
               ELSE
                x_natural_account := x_ta_reserve_segm;
              END IF;

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_natural_account,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_reserve_name,
                                 x_debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );
            END IF;
          END IF;
        END LOOP;

        -----------------------------------------------------------------------------
        --  TRANSFER OUT NOCOPY - Transaction used in Partial Unit Retirements            --
        -----------------------------------------------------------------------------

       ELSIF (tr.transaction_type_code = 'TRANSFER OUT') THEN
        IF (tr.asset_type = 'CAPITALIZED') THEN
          x_global_source := 'IA TRANSFER';
          x_je_category_name := x_je_ia_transfer;
          x_je_std_category_name := x_je_ia_transfer;
          x_adjustment_type := x_cost_name;

         ELSIF (tr.asset_type = 'CIP') THEN
          x_global_source := 'IA CIP TRANSFER';
          x_je_category_name := x_je_ia_cip_transfer;
          x_je_std_category_name := x_je_ia_cip_transfer;
          x_adjustment_type := x_cip_cost_name;
        END IF;

        -----------------------------------------------------------------------------
        --  Get information about of the source retirement                         --
        -----------------------------------------------------------------------------

        --x_ta_factor := abs (tr.appraisal_balance) / tr.adj_cost;
        ----------------------------------------------------------------------------
        --BUG 3865352 Added handling of Divisor equal to zero.
        ----------------------------------------------------------------------------
        IF tr.adj_cost = 0 THEN
          x_ta_factor := 0;
        ELSE
          x_ta_factor := abs (tr.appraisal_balance) / tr.adj_cost;
        END IF;


        OPEN  c_source_retirement (tr.transaction_header_id);
        FETCH c_source_retirement INTO x_source_transaction_header_id;
        CLOSE c_source_retirement;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Source Transaction ID = ' || to_char(x_source_transaction_header_id);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        -----------------------------------------------------------------------------
        --  Get historical and adjusted values of the cost inflation adjustments   --
        -----------------------------------------------------------------------------

        OPEN c_sum_adjustments (tr.asset_id,
                                x_corporate_book,
                                x_source_transaction_header_id,
                                x_adjustment_type,
                                'CR'
                               );
        FETCH c_sum_adjustments INTO x_adjustment_amount;
        CLOSE c_sum_adjustments;

        OPEN c_sum_adjustments (tr.asset_id,
                                p_tax_book,
                                tr.transaction_header_id,
                                x_adjustment_type,
                                'CR'
                               );
        FETCH c_sum_adjustments INTO x_adj_cost;
        CLOSE c_sum_adjustments;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Sum Corp Cost = ' || to_char(x_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Sum Adj Cost = ' || to_char(x_adj_cost);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        IF (x_adj_cost <> 0) THEN
          x_factor := (x_adj_cost - x_adjustment_amount) / x_adj_cost;
         ELSE
          x_factor := 0;
        END IF;

        -----------------------------------------------------------------------------
        -- Get historical and adjusted values of the reserve inflation adjustments --
        -----------------------------------------------------------------------------

        OPEN c_deprn_summary (x_corporate_book,
                              tr.asset_id,
                              x_period_counter - 1
                             );
        FETCH c_deprn_summary INTO x_corp_deprn_reserve,
                                   x_corp_reval_reserve,
                                   x_corp_reval_deprn_expense;
        CLOSE c_deprn_summary;

        OPEN c_deprn_summary (p_tax_book,
                              tr.asset_id,
                              x_period_counter - 1
                             );
        FETCH c_deprn_summary INTO x_adj_deprn_reserve,
                                   x_adj_reval_reserve,
                                   x_adj_reval_deprn_expense;
        CLOSE c_deprn_summary;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Sum Corp Reserve = ' || to_char(x_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Sum Adj Reserve = ' || to_char(x_adj_cost);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        -----------------------------------------------------------------------------------
        --    LER, 18-Jun-99   It's enough with the depreciation reserve amounts         --
        --                     because these amounts should be completely transferred.   --
        --                     Then the following statements are unnecessary and they    --
        --                     can be replaced by the new lines at end of this section.  --
        -----------------------------------------------------------------------------------

--        OPEN c_sum_adjustments (tr.asset_id,
--                                x_corporate_book,
--                                x_source_transaction_header_id,
--                                x_reserve_name,
--                                'DR'
--                               );
--        FETCH c_sum_adjustments INTO x_adjustment_amount;
--        CLOSE c_sum_adjustments;

--        OPEN c_sum_adjustments (tr.asset_id,
--                                p_tax_book,
--                                tr.transaction_header_id,
--                                x_reserve_name,
--                                'DR'
--                               );
--        FETCH c_sum_adjustments INTO x_adj_cost;
--        CLOSE c_sum_adjustments;

--        x_adjustment_amount := x_adj_cost - x_adjustment_amount;
--        x_factor_1 := x_adjustment_amount / (x_adj_deprn_reserve - x_corp_deprn_reserve);

--        IF (x_adj_cost <> 0) THEN
--          x_factor_12 := x_deprn_to_cost * x_factor_1;

--  x_char := 'Factor_12 = ' || to_char(x_factor_12);
--  fnd_file.put_line (FND_FILE.LOG, x_char);

--          x_factor_11 := x_factor_12 / x_adj_cost;
--          x_factor_12 := (x_adjustment_amount - x_factor_12) / x_adj_cost;
--         ELSE
--          x_factor_11 := 0;
--          x_factor_12 := 0;
--        END IF;

        ---------------------------------------------------------------------------------
        --  LER 18-Jun-99   The following new statements improve the previous section  --
        ---------------------------------------------------------------------------------

        x_adjustment_amount := x_adj_deprn_reserve - x_corp_deprn_reserve;
        IF (x_adj_deprn_reserve > 0) THEN
          x_factor_11 := x_deprn_to_cost / x_adj_deprn_reserve;
          x_factor_12 := (x_adjustment_amount - x_deprn_to_cost) / x_adj_deprn_reserve;
         ELSE
          x_factor_11 := 0;
          x_factor_12 := 0;
        END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Factor_11 = ' || to_char(x_factor_11);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Factor_12 = ' || to_char(x_factor_12);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        -----------------------------------------------------------------------------
        -- Get historical and adjusted values of the expense inflation adjustments --
        -----------------------------------------------------------------------------

        OPEN c_sum_adjustments (tr.asset_id,
                                x_corporate_book,
                                x_source_transaction_header_id,
                                x_expense_name,
                                'CR'
                               );
        FETCH c_sum_adjustments INTO x_adjustment_amount;
        CLOSE c_sum_adjustments;

        OPEN c_sum_adjustments (tr.asset_id,
                                p_tax_book,
                                tr.transaction_header_id,
                                x_expense_name,
                                'CR'
                               );
        FETCH c_sum_adjustments INTO x_adj_cost;
        CLOSE c_sum_adjustments;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Sum Corp Expense = ' || to_char(x_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Sum Adj Expense = ' || to_char(x_adj_cost);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        IF (x_adj_cost <> 0) THEN
          x_factor_2 := (x_adj_cost - x_adjustment_amount) / x_adj_cost;
         ELSE
          x_factor_2 := 0;
        END IF;

        -----------------------------------------------------------------------------
        --  Find all adjusted rows in FA_ADJUSTMENTS for TAX book                  --
        -----------------------------------------------------------------------------

        FOR ra IN c_tr_adjustments_no_adj_type (tr.transaction_header_id,
                                    p_tax_book,
                                    x_period_counter
                                   ) LOOP

          --FA SLA Changes.
          IF ra.code_combination_id is null then
            l_book_type_code := p_tax_book;
            RAISE e_ccid_not_found;
          END IF;


          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'Distribution Id = ' || to_char(ra.distribution_id);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          IF (ra.debit_credit_flag = 'DR') THEN
            x_debit_credit_flag := 'CR';
           ELSE
            x_debit_credit_flag := 'DR';
          END IF;

          IF (ra.adjustment_type = x_cost_name) THEN

            -----------------------------------------------------------------------------
            --  Cost inflation adjustments                                             --
            -----------------------------------------------------------------------------

            x_adjustment_amount := round (ra.adjustment_amount * x_factor, x_precision);

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'Cost Adjustment Amount = ' || to_char(x_adjustment_amount);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ia_cost_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_category_name,
                               x_ia_cost_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

           ELSIF (ra.adjustment_type = x_reserve_name) THEN

            -----------------------------------------------------------------------------
            --  Depreciation reserve inflation adjustments                             --
            -----------------------------------------------------------------------------

            x_adjustment_amount := round (ra.adjustment_amount * x_factor_11, x_precision);

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'Std Reserve Adjustment Amount = ' || to_char(x_adjustment_amount);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_std_category_name,
                               x_reserve_name,
                               ra.debit_credit_flag,
                               ra.code_combination_id,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

            x_adjustment_amount := round (ra.adjustment_amount * x_factor_12, x_precision);

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'IA Reserve Adjustment Amount = ' || to_char(x_adjustment_amount);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ia_deprn_reserve_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_category_name,
                               x_ia_reserve_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );


           ELSIF (ra.adjustment_type = x_expense_name) THEN

            -----------------------------------------------------------------------------
            --  Adjustments to depreciation expense due to transaction                 --
            -----------------------------------------------------------------------------

            x_adjustment_amount := round (ra.adjustment_amount * x_factor_2, x_precision);

            insert_adjustment (tr.transaction_header_id,
                               'DEPRECIATION',
                               x_je_depreciation,
                               x_expense_name,
                               ra.debit_credit_flag,
                               ra.code_combination_id,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               x_period_counter,
                               x_period_counter,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );

            -----------------------------------------------------------------------------
            --    LER, 18-Jun-99   The following section was cancelled because the     --
            --                     reserve was completely transferred in previous      --
            --                     section.                                            --
            -----------------------------------------------------------------------------

--            fa_gccid_pkg.fafbgcc_proc (p_tax_book,
--                                       'DEPRN_RESERVE_ACCT',
--                                       ra.code_combination_id,
--                                       x_deprn_reserve_segm,
--                                       x_deprn_reserve_ccid,
--                                       ra.distribution_id,
--                                       x_returned_ccid,
--                                       x_concat_segs,
--                                       x_return_value
--                                      );

--            IF (x_return_value = 0) then
--              fnd_message.set_name ('JL', 'JL_CO_FA_CCID_NOT_CREATED');
--              fnd_message.set_token ('ACCOUNT', x_concat_segs);
--              x_error_ccid := TRUE;

--             ELSE
--              insert_adjustment (tr.transaction_header_id,
--                                 'DEPRECIATION',
--                                 x_je_depreciation,
--                                 x_reserve_name,
--                                 x_debit_credit_flag,
--                                 x_returned_ccid,
--                                 p_tax_book,
--                                 tr.asset_id,
--                                 x_adjustment_amount,
--                                 ra.distribution_id,
--                                 ra.annualized_adjustment,
--                                 NULL,
--                                 NULL,
--                                 x_period_counter,
--                                 x_period_counter,
--                                 ra.asset_invoice_id,
--                                 NULL,
--                                 NULL
--                                );
--            END IF;

           ELSIF (ra.adjustment_type = x_cip_cost_name) THEN

            -----------------------------------------------------------------------------
            --  CIP cost inflation adjustments                                         --
            -----------------------------------------------------------------------------

            x_adjustment_amount := round (ra.adjustment_amount * x_factor, x_precision);

            change_account (x_chart_of_accounts_id,
                            x_apps_short_name,
                            x_key_flex_code,
                            x_account_segment,
                            ra.code_combination_id,
                            x_ia_cip_cost_segm,
                            x_delimiter,
                            x_returned_ccid,
                            x_error_ccid
                           );

            insert_adjustment (tr.transaction_header_id,
                               x_global_source,
                               x_je_category_name,
                               x_ia_cip_cost_name,
                               ra.debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               ra.period_counter_adjusted,
                               ra.period_counter_created,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );
          END IF;

          -----------------------------------------------------------------------------
          --  Transferring Technical Appraisal Account Balances                      --
          -----------------------------------------------------------------------------

          IF ra.adjustment_type IN (x_cost_name,
                                    x_cip_cost_name
                                   ) THEN

            x_ta_line_amount := round (ra.adjustment_amount * x_ta_factor, x_precision);

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'Appraisal Line Amount =' || to_char (x_ta_line_amount);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            IF (tr.appraisal_balance > 0) THEN

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ta_revaluation_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_revaluation_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ta_surplus_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_surplus_name,
                                 x_debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );

             ELSIF (tr.appraisal_balance < 0) THEN

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ta_reserve_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_reserve_name,
                                 x_debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );
            END IF;
          END IF;
        END LOOP;

      -----------------------------------------------------------------------------
      --  RETIREMENT / REINSTATEMENT                                             --
      -----------------------------------------------------------------------------

       ELSIF tr.transaction_type_code IN ('FULL RETIREMENT',
                                          'PARTIAL RETIREMENT',
                                          'REINSTATEMENT'
                                         ) THEN
        IF (tr.asset_type = 'CAPITALIZED') THEN
          x_global_source := 'IA RETIREMENT';
          x_adjustment_type := x_cost_name;
          x_je_std_category_name := x_je_ia_retirement;
         ELSE
          x_global_source := 'IA CIP RETIRE';
          x_adjustment_type := x_cip_cost_name;
          x_je_std_category_name := x_je_ia_cip_retirement;
        END IF;

        -----------------------------------------------------------------------------
        --  Get corporate and adjusted depreciation values of the retirement       --
        -----------------------------------------------------------------------------
        --     LER, 18-Jun-99    Moved after of the following section to lookup    --
        --                       the Period_Counter of the source Retirement       --
        -----------------------------------------------------------------------------

--        IF (tr.transaction_type_code = 'REINSTATEMENT') THEN
--          x_period_1 := x_period_counter - 1;
--         ELSE
--          x_period_1 := x_period_counter;
--        END IF;

--        OPEN c_deprn_summary (x_corporate_book,
--                              tr.asset_id,
--                              x_period_1
--                             );
--        FETCH c_deprn_summary INTO x_corp_deprn_reserve,
--                                   x_corp_reval_reserve,
--                                   x_corp_reval_deprn_expense;
--        CLOSE c_deprn_summary;

--        OPEN c_deprn_summary (p_tax_book,
--                              tr.asset_id,
--                              x_period_1
--                             );
--        FETCH c_deprn_summary INTO x_adj_deprn_reserve,
--                                   x_adj_reval_reserve,
--                                   x_adj_reval_deprn_expense;
--        CLOSE c_deprn_summary;

--        x_ia_reserve := x_adj_deprn_reserve - x_corp_deprn_reserve;


        IF (tr.transaction_type_code = 'REINSTATEMENT') THEN

          -----------------------------------------------------------------------------
          --  Get information about the reinstatement and previous transactions      --
          -----------------------------------------------------------------------------

          OPEN c_reinstatement (tr.source_transaction_header_id);
          FETCH c_reinstatement INTO x_corp_retirement_id,
                                     x_corp_cost_retired,
                                     x_corp_units_retired,
                                     x_corp_nbv_retired,
                                     x_corp_reval_reserve_retired,
                                     x_corp_gain_loss_amount,
                                     x_period_1,
                                     x_retirement_type_code;
          CLOSE c_reinstatement;

          OPEN c_reinstatement (tr.transaction_header_id);
          FETCH c_reinstatement INTO x_adj_retirement_id,
                                     x_adj_cost_retired,
                                     x_adj_units_retired,
                                     x_adj_nbv_retired,
                                     x_adj_reval_reserve_retired,
                                     x_adj_gain_loss_amount,
                                     x_period_1,
                                     x_retirement_type_code;
          CLOSE c_reinstatement;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'tr.transaction_header_id_in = ' || to_char (tr.transaction_header_id);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'x_period_1 = ' || to_char(x_period_1);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          -----------------------------------------------------------------------------------
          --       LER, 18-Jun-99   Lines commented were moved outside of the IF section   --
          -----------------------------------------------------------------------------------

--          x_adjustment_amount := x_adj_cost_retired - x_adj_nbv_retired;
--          x_ia_reserve_retired := x_adjustment_amount - (x_corp_cost_retired - x_corp_nbv_retired);
--          x_ia_reserve := x_ia_reserve + x_ia_reserve_retired;

          OPEN c_prior_retirement (tr.transaction_header_id);
          FETCH c_prior_retirement INTO x_transaction_header_id_in,
                                        x_value_2;
          CLOSE c_prior_retirement;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'x_transaction_header_id_in = ' || to_char(x_transaction_header_id_in);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'x_value_1 = ' || to_char(x_value_2);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          OPEN c_prior_retirement (x_transaction_header_id_in);
          FETCH c_prior_retirement INTO x_transaction_header_id_out,
                                        x_value_1;
          CLOSE c_prior_retirement;

          x_deprn_to_cost := x_deprn_to_cost + x_value_1 - x_value_2;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'x_transaction_header_id_out = ' || to_char(x_transaction_header_id_out);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'x_value_2 = ' || to_char(x_value_1);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'x_ia_reserve = ' || to_char(x_ia_reserve);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'x_ia_reserve_retired ' || to_char(x_ia_reserve_retired);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'x_deprn_to_cost = ' || to_char(x_deprn_to_cost);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

         ELSE

          -----------------------------------------------------------------------------
          --  Get information about the retirement                                   --
          -----------------------------------------------------------------------------

          OPEN c_retirement (tr.transaction_header_id);
          FETCH c_retirement INTO x_adj_retirement_id,
                                  x_adj_cost_retired,
                                  x_adj_units_retired,
                                  x_adj_nbv_retired,
                                  x_adj_reval_reserve_retired,
                                  x_adj_gain_loss_amount;
          CLOSE c_retirement;

          OPEN c_retirement (tr.source_transaction_header_id);
          FETCH c_retirement INTO x_corp_retirement_id,
                                  x_corp_cost_retired,
                                  x_corp_units_retired,
                                  x_corp_nbv_retired,
                                  x_corp_reval_reserve_retired,
                                  x_corp_gain_loss_amount;
          CLOSE c_retirement;

          -----------------------------------------------------------------------------------
          --       LER, 18-Jun-99   Lines commented were moved outside of the IF section   --
          -----------------------------------------------------------------------------------

--          x_adjustment_amount := x_adj_cost_retired - x_adj_nbv_retired;
--          x_ia_reserve_retired := x_adjustment_amount - (x_corp_cost_retired - x_corp_nbv_retired);
--          x_ia_reserve := x_ia_reserve + x_ia_reserve_retired;

          x_period_1 := x_period_counter;
          x_retirement_type_code := tr.transaction_type_code;
        END IF;

        x_adjustment_amount := x_adj_cost_retired - x_adj_nbv_retired;
        x_ia_reserve_retired := x_adjustment_amount - (x_corp_cost_retired - x_corp_nbv_retired);
--        x_ia_reserve := x_ia_reserve + x_ia_reserve_retired;

        x_value_3 := x_deprn_to_cost;
        x_value_5 := x_deprn_to_cost;

        -----------------------------------------------------------------------------------
        --  Get corporate and adjusted depreciation values of the retirement             --
        -----------------------------------------------------------------------------------
        --    LER, 18-Jun-99   Moved from the begin of the RETIREMENT transaction code   --
        -----------------------------------------------------------------------------------

        OPEN c_deprn_summary (x_corporate_book,
                              tr.asset_id,
                              x_period_1
                             );
        FETCH c_deprn_summary INTO x_corp_deprn_reserve,
                                   x_corp_reval_reserve,
                                   x_corp_reval_deprn_expense;
        CLOSE c_deprn_summary;

        OPEN c_deprn_summary (p_tax_book,
                              tr.asset_id,
                              x_period_1
                             );
        FETCH c_deprn_summary INTO x_adj_deprn_reserve,
                                   x_adj_reval_reserve,
                                   x_adj_reval_deprn_expense;
        CLOSE c_deprn_summary;

        x_ia_reserve := x_adj_deprn_reserve - x_corp_deprn_reserve + x_ia_reserve_retired;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'x_adjustment = ' || to_char(x_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'x_ia_reserve = ' || to_char(x_ia_reserve);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'x_ia_reserve_retired ' || to_char(x_ia_reserve_retired);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'x_value_3 ' || to_char(x_value_3);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'adj_deprn_reserve = ' || to_char(x_adj_deprn_reserve);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'corp_deprn_reserve = ' || to_char(x_corp_deprn_reserve);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        -----------------------------------------------------------------------------
        --  Identify if retirement Gain/Loss is different in Corporate and Tax      --
        -----------------------------------------------------------------------------

        x_corp_gain_loss_amount := x_corp_gain_loss_amount - x_corp_reval_reserve_retired;
        x_adj_gain_loss_amount := x_adj_gain_loss_amount - x_adj_reval_reserve_retired;

        IF (x_adj_gain_loss_amount >= 0 AND x_corp_gain_loss_amount < 0
            OR x_adj_gain_loss_amount < 0 AND x_corp_gain_loss_amount >= 0) THEN
          x_gain_loss_changed := TRUE;
         ELSE
          x_gain_loss_changed := FALSE;
        END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Gain/Loss Corp = ' || to_char(x_corp_gain_loss_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Gain/Loss Adj = ' || to_char(x_adj_gain_loss_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        -----------------------------------------------------------------------------
        --  Define values used in retire of Technical Appraisal balances           --
        -----------------------------------------------------------------------------

        IF (tr.adj_cost > 0) THEN
          x_ta_factor := tr.adj_cost;
         ELSE
          x_ta_factor := x_adj_cost_retired;
        END IF;

        x_distribution_id := 0;

        --x_ta_factor := abs (tr.appraisal_balance) / x_ta_factor;
        ----------------------------------------------------------------------------
        --BUG 3865352
        ----------------------------------------------------------------------------
        IF x_ta_factor = 0 THEN
          x_ta_factor := 0;
        ELSE
          x_ta_factor := abs (tr.appraisal_balance) / x_ta_factor;
        END IF;




        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'Asset cost = ' || to_char(tr.adj_cost);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'Appraisal = ' || to_char(tr.appraisal_balance);
          fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        -----------------------------------------------------------------------------
        --  Identify retirement type                                               --
        --    Technical Reference Manual define that column                        --
        --    FA_TRANSACTION_HEADERS.TRANSACTION_SUBTYPE contains the retirement   --
        --    type, but standard application always leave this column as NULL      --
        -----------------------------------------------------------------------------

        x_retirement_type := 'O';
        IF (tr.transaction_type_code = 'PARTIAL RETIREMENT'
              AND x_corp_units_retired > 0
           ) THEN
          x_retirement_type := 'U';

          -----------------------------------------------------------------------------------
          --    LER, 18-Jun-99    Looking for adjustments to Acc. Depreciation at begin    --
          --                      of the current period (end of previous period)           --
          -----------------------------------------------------------------------------------

          x_period_1 := x_period_counter - 1;

          OPEN c_deprn_summary (x_corporate_book,
                                tr.asset_id,
                                x_period_1
                               );
          FETCH c_deprn_summary INTO x_corp_deprn_reserve,
                                     x_corp_reval_reserve,
                                     x_corp_reval_deprn_expense;
          CLOSE c_deprn_summary;

          OPEN c_deprn_summary (p_tax_book,
                                tr.asset_id,
                                x_period_1
                               );
          FETCH c_deprn_summary INTO x_adj_deprn_reserve,
                                     x_adj_reval_reserve,
                                     x_adj_reval_deprn_expense;
          CLOSE c_deprn_summary;

          x_value_4 := x_adj_deprn_reserve - x_corp_deprn_reserve;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'adj_deprn_reserve = ' || to_char(x_adj_deprn_reserve);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'corp_deprn_reserve = ' || to_char(x_corp_deprn_reserve);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          -----------------------------------------------------------------------------
          --  Calculate Deprn. To Cost Inflation Adjusts. and Adjustments to Deprn.  --
          -----------------------------------------------------------------------------

          OPEN c_sum_adjustments (tr.asset_id,
                                  p_tax_book,
                                  tr.transaction_header_id,
                                  x_expense_name,
                                  'DR'
                                 );
          FETCH c_sum_adjustments INTO x_adj_cost_retired;
          CLOSE c_sum_adjustments;

--          OPEN c_sum_adjustments (tr.transaction_header_id,
--                                  x_expense_name,
--                                  'CR'
--                                 );
--          FETCH c_sum_adjustments INTO x_adj_cost;
--          CLOSE c_sum_adjustments;
--          x_adj_cost_retired := x_adjustment_amount - x_adj_cost;

--          x_adjustment_amount := 0;
--          x_adj_cost := 0;

          OPEN c_sum_adjustments (tr.asset_id,
                                  x_corporate_book,
                                  tr.source_transaction_header_id,
                                  x_expense_name,
                                  'DR'
                                 );
          FETCH c_sum_adjustments INTO x_adjustment_amount;
          CLOSE c_sum_adjustments;
          OPEN c_sum_adjustments (tr.asset_id,
                                  x_corporate_book,
                                  tr.source_transaction_header_id,
                                  x_expense_name,
                                  'CR'
                                 );
          FETCH c_sum_adjustments INTO x_adj_cost;
          CLOSE c_sum_adjustments;

          IF (x_adj_cost_retired <> 0) THEN
            x_factor_2 := (x_adj_cost_retired - x_adjustment_amount + x_adj_cost) / x_adj_cost_retired;
           ELSE
            x_factor_2 := 0;
          END IF;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'Expense - Corp -Dr = ' || to_char(x_adjustment_amount);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'Expense - Corp - Cr = ' || to_char(x_adj_cost);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'Expense - Adj - Dr = ' || to_char(x_adj_cost_retired);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;
        END IF;

        --------------------------------------------------------------------------------
        --  Calculate the adjustments to depreciation expense debt to the retirement  --
        --------------------------------------------------------------------------------

        FOR ra IN c_tr_adjustments_adj_type (tr.transaction_header_id,
                                    tr.book_type_code,
                                    x_expense_name,
                                    x_period_counter
                                   ) LOOP

          --FA SLA Changes.
          IF ra.code_combination_id is null then
            l_book_type_code := tr.book_type_code;
            RAISE e_ccid_not_found;
          END IF;


          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'Adjustment for Line = ' || to_char(ra.distribution_id) || ' ' || ra.adjustment_type;
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          IF (x_retirement_type = 'O') THEN
            OPEN c_tr_rel_adjustments (tr.source_transaction_header_id,
                                       x_corporate_book,
                                       ra.source_type_code,
                                       ra.adjustment_type,
                                       ra.debit_credit_flag,
                                       ra.distribution_id
                                      );
            FETCH c_tr_rel_adjustments INTO x_code_combination_id,
                                            x_adjustment_amount;

            IF (c_tr_rel_adjustments%FOUND = FALSE) THEN
              x_adjustment_amount := 0;
            END IF;
            CLOSE c_tr_rel_adjustments;

            x_adjustment_amount := round (ra.adjustment_amount - x_adjustment_amount, x_precision);

           ELSE
            x_adjustment_amount := round (ra.adjustment_amount * x_factor_2, x_precision);

          END IF;

          IF (tr.transaction_type_code = 'REINSTATEMENT') THEN
            x_value_3 := x_value_3 - x_adjustment_amount;
           ELSE
            x_deprn_to_cost := x_deprn_to_cost + x_adjustment_amount;
            x_value_3 := x_deprn_to_cost;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'X_value_3 ' || to_char(x_value_3);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;
          END IF;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'x_deprn_to_cost A = ' || to_char(x_deprn_to_cost);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          IF (ra.debit_credit_flag = 'DR') THEN
            x_debit_credit_flag := 'CR';
           ELSE
            x_debit_credit_flag := 'DR';
          END IF;

          insert_adjustment (tr.transaction_header_id,
                             'DEPRECIATION',
                             x_je_depreciation,
                             x_expense_name,
                             ra.debit_credit_flag,
                             ra.code_combination_id,
                             p_tax_book,
                             tr.asset_id,
                             x_adjustment_amount,
                             ra.distribution_id,
                             ra.annualized_adjustment,
                             NULL,
                             NULL,
                             x_period_counter,
                             x_period_counter,
                             ra.asset_invoice_id,
                             NULL,
                             NULL
                            );

          fa_gccid_pkg.fafbgcc_proc (p_tax_book,
                                     'DEPRN_RESERVE_ACCT',
                                     ra.code_combination_id,
                                     x_deprn_reserve_segm,
                                     x_deprn_reserve_ccid,
                                     ra.distribution_id,
                                     x_returned_ccid,
                                     x_concat_segs,
                                     x_return_value
                                    );

          IF (x_return_value = 0) then
            fnd_message.set_name ('JL', 'JL_CO_FA_CCID_NOT_CREATED');
            fnd_message.set_token ('ACCOUNT', x_concat_segs);
            --Bug 2929483. Missing log message handling has been added.
            fnd_file.put_line     (FND_FILE.LOG, fnd_message.get);
            x_error_ccid := TRUE;

           ELSE
            insert_adjustment (tr.transaction_header_id,
                               'DEPRECIATION',
                               x_je_depreciation,
                               x_reserve_name,
                               x_debit_credit_flag,
                               x_returned_ccid,
                               p_tax_book,
                               tr.asset_id,
                               x_adjustment_amount,
                               ra.distribution_id,
                               ra.annualized_adjustment,
                               NULL,
                               NULL,
                               x_period_counter,
                               x_period_counter,
                               ra.asset_invoice_id,
                               NULL,
                               NULL
                              );
          END IF;
        END LOOP;

        -----------------------------------------------------------------------------
        --  Calculate Deprn. To Cost Inflation Adjusts. and Adjustments to Deprn.  --
        -----------------------------------------------------------------------------

        IF (x_retirement_type = 'O') THEN
          IF x_ia_reserve <> 0 THEN
            x_factor_1 := x_ia_reserve_retired / x_ia_reserve;
           ELSE
            x_factor_1 := 0;
          END IF;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'Retirement ID for Tax book = ' || to_char(x_adj_retirement_id);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'Retirement ID for Corp book = ' || to_char(x_corp_retirement_id);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'Factor 1 = ' || to_char(x_factor_1);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'x_deprn_to cost B = ' || to_char(x_deprn_to_cost);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          IF (x_ia_reserve_retired <> 0) THEN
            x_factor_12 := x_value_3 * x_factor_1;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'Factor_12 = ' || to_char(x_factor_12);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            x_factor_11 := x_factor_12 / x_ia_reserve_retired;
            x_factor_12 := (x_ia_reserve_retired - x_factor_12) / x_ia_reserve_retired;
           ELSE
            x_factor_11 := 0;
            x_factor_12 := 0;
          END IF;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'Factor_11 = ' || to_char(x_factor_11);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            x_char := 'Factor_12 = ' || to_char(x_factor_12);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

         ELSE
          -------------------------------------------------------------------------------------
          --  Find source data to calculate factors applied in partial retirements by units  --
          -------------------------------------------------------------------------------------

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'Units Retired = ' || to_char(x_corp_units_retired);
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          IF (x_retirement_type = 'U') THEN
--          x_adj_cost_retired := 0;
--          x_adjustment_amount := 0;
--          x_adj_cost := 0;

            OPEN c_sum_adjustments (tr.asset_id,
                                    p_tax_book,
                                    tr.transaction_header_id,
                                    x_adjustment_type,
                                    'CR'
                                   );
            FETCH c_sum_adjustments INTO x_adj_cost_retired;
            CLOSE c_sum_adjustments;

--          OPEN c_sum_adjustments (tr.transaction_header_id,
--                                  x_adjustment_type,
--                                  'DR'
--                                 );
--          FETCH c_sum_adjustments INTO x_adj_cost;
--          CLOSE c_sum_adjustments;
--          x_adj_cost_retired := x_adjustment_amount - x_adj_cost;

            OPEN c_sum_adjustments (tr.asset_id,
                                    x_corporate_book,
                                    tr.source_transaction_header_id,
                                    x_adjustment_type,
                                    'CR'
                                   );
            FETCH c_sum_adjustments INTO x_adjustment_amount;
            CLOSE c_sum_adjustments;

            OPEN c_sum_adjustments (tr.asset_id,
                                    x_corporate_book,
                                    tr.source_transaction_header_id,
                                    x_adjustment_type,
                                    'DR'
                                   );
            FETCH c_sum_adjustments INTO x_adj_cost;
            CLOSE c_sum_adjustments;

            IF (x_adj_cost_retired <> 0) THEN
              x_factor := (x_adj_cost_retired - x_adjustment_amount + x_adj_cost) / x_adj_cost_retired;
             ELSE
              x_factor := 0;
            END IF;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'Sum Corp Cost Retired = ' || to_char(x_adjustment_amount - x_adj_cost);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              x_char := 'Sum Adj Cost = ' || to_char(x_adj_cost_retired);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            OPEN c_sum_adjustments (tr.asset_id,
                                    p_tax_book,
                                    tr.transaction_header_id,
                                    x_reserve_name,
                                    'DR'
                                   );
            FETCH c_sum_adjustments INTO x_adj_cost_retired;
            CLOSE c_sum_adjustments;

--          OPEN c_sum_adjustments (tr.transaction_header_id,
--                                  x_reserve_name,
--                                  'CR'
--                                 );
--          FETCH c_sum_adjustments INTO x_adj_cost;
--          CLOSE c_sum_adjustments;
--          x_adj_cost_retired := x_adjustment_amount - x_adj_cost;

--          x_adjustment_amount := 0;
--          x_adj_cost := 0;

            OPEN c_sum_adjustments (tr.asset_id,
                                    x_corporate_book,
                                    tr.source_transaction_header_id,
                                    x_reserve_name,
                                    'DR'
                                   );
            FETCH c_sum_adjustments INTO x_adjustment_amount;
            CLOSE c_sum_adjustments;

            OPEN c_sum_adjustments (tr.asset_id,
                                    x_corporate_book,
                                    tr.source_transaction_header_id,
                                    x_reserve_name,
                                    'CR'
                                   );
            FETCH c_sum_adjustments INTO x_adj_cost;
            CLOSE c_sum_adjustments;

            IF (x_adj_cost_retired <> 0) THEN
              x_factor_1 := (x_adj_cost_retired - x_adjustment_amount + x_adj_cost) / x_adj_cost_retired;
             ELSE
              x_factor_1 := 0;
            END IF;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'Sum Corp Reserve Retired = ' || to_char(x_adjustment_amount - x_adj_cost);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              x_char := 'Sum Adj Reserve = ' || to_char(x_adj_cost_retired);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              x_char := 'x_value_4 = ' || to_char(x_value_4);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              x_char := 'x_value_5 = ' || to_char(x_value_5);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            ----------------------------------------------------------------------------------
            --    LER, 18-Jun-99   New code to calculate factors_11/12 used in              --
            --                     calculations of each component of the IA to Acc. Deprn.  --
            ----------------------------------------------------------------------------------

            IF (x_ia_reserve_retired > 0) THEN
              --x_value_3 := (x_ia_reserve_retired - (x_deprn_to_cost - x_value_5)) / x_value_4;
              ----------------------------------------------------------------------------
              --BUG 3865352
              ----------------------------------------------------------------------------
              IF x_value_4 = 0 THEN
                x_value_3 := 0;
              ELSE
                x_value_3 := (x_ia_reserve_retired - (x_deprn_to_cost - x_value_5)) / x_value_4;
              END IF;


              x_value_3 := (x_value_4 - x_value_5) * x_value_3;
              x_factor_12 := x_value_3 * x_factor_1 / x_ia_reserve_retired ;
              x_factor_11 := (x_ia_reserve_retired - x_value_3) * x_factor_1/ x_ia_reserve_retired ;
             ELSE
              x_factor_11 := 0 ;
              x_factor_12 := 0 ;
            END IF;

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'x_factor_11 = ' || to_char(x_factor_11);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              x_char := 'x_factor_12 = ' || to_char(x_factor_12);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;
          END IF;
        END IF;

        -----------------------------------------------------------------------------
        --  Find all rows in FA_ADJUSTMENTS for the retirement transaction         --
        -----------------------------------------------------------------------------

        FOR ra IN c_tr_adjustments_no_adj_type (tr.transaction_header_id,
                                    tr.book_type_code,
                                    x_period_counter
                                   ) LOOP

          --FA SLA Changes.
          IF ra.code_combination_id is null then
            l_book_type_code := tr.book_type_code;
            RAISE e_ccid_not_found;
          END IF;


          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            x_char := 'Adjustment for Line = ' || to_char(ra.distribution_id) || ' ' || ra.adjustment_type;
            fnd_file.put_line (FND_FILE.LOG, x_char);
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          END IF;

          IF (ra.distribution_id <> x_distribution_id) THEN

            -----------------------------------------------------------------------------
            --  Add row corresponding to NBV retired due to inflation adjustment       --
            -----------------------------------------------------------------------------

            IF (x_distribution_id > 0) THEN
              x_adjustment_amount := x_ia_cost_retired - x_ia_reserve_retired;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                x_char := 'IANBV = ' || to_char(x_adjustment_amount);
                fnd_file.put_line (FND_FILE.LOG, x_char);
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              END IF;

              insert_adjustment (tr.transaction_header_id,
                                 x_global_source,
                                 x_je_ia_retirement,
                                 x_nbv_retired_name,
                                 x_nbv_debit_credit_flag,
                                 x_nbv_retired_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 x_distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 x_period_counter,
                                 x_period_counter,
                                 NULL,
                                 NULL,
                                 NULL
                                );
            END IF;

            x_ia_cost_retired := 0;
            x_ia_reserve_retired := 0;
            x_distribution_id := ra.distribution_id;
          END IF;

          IF ra.adjustment_type IN (x_cip_cost_name,
                                    x_cost_name,
                                    x_reserve_name,
                                    x_expense_name
                                   ) THEN

            -----------------------------------------------------------------------------
            --  Rows to add due to inflation adjustments                               --
            --    Calculate amount                                                     --
            --    Built accounting flexfield                                           --
            --    Insert row in JL_CO_FA_ADJUSTMENTS                                   --
            -----------------------------------------------------------------------------

            IF (x_retirement_type = 'O') THEN
              x_adjustment_amount := ra.adjustment_amount;

              OPEN c_tr_rel_adjustments (tr.source_transaction_header_id,
                                         x_corporate_book,
                                         ra.source_type_code,
                                         ra.adjustment_type,
                                         ra.debit_credit_flag,
                                         ra.distribution_id
                                        );
              FETCH c_tr_rel_adjustments INTO x_code_combination_id,
                                              x_adjustment_amount;
              CLOSE c_tr_rel_adjustments;
            END IF;

            IF ra.adjustment_type = x_cip_cost_name THEN
              IF (x_retirement_type = 'U') THEN
                x_adjustment_amount := round (ra.adjustment_amount * x_factor, x_precision);
               ELSE
                x_adjustment_amount := round (ra.adjustment_amount - x_adjustment_amount, x_precision);
              END IF;

              --------------------------------------------------------------------------------
              --    LER, 18-Jun-99   Fixed a bug. Add current value to  x_ia_cost_retired   --
              --------------------------------------------------------------------------------

              x_ia_cost_retired := x_adjustment_amount + x_ia_cost_retired;

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ia_cip_cost_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_source,
                                 x_je_ia_cip_retirement,
                                 x_ia_cip_cost_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );

             ELSIF ra.adjustment_type = x_cost_name THEN
              IF (x_retirement_type = 'U') THEN
                x_adjustment_amount := round (ra.adjustment_amount * x_factor, x_precision);
               ELSE
                x_adjustment_amount := round (ra.adjustment_amount - x_adjustment_amount, x_precision);
              END IF;
              x_ia_cost_retired := x_adjustment_amount + x_ia_cost_retired;

              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                x_char := 'COST = ' || to_char(x_adjustment_amount);
                fnd_file.put_line (FND_FILE.LOG, x_char);
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
              END IF;

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ia_cost_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_source,
                                 x_je_ia_retirement,
                                 x_ia_cost_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );

             ELSIF ra.adjustment_type = x_reserve_name THEN
              IF (x_retirement_type = 'U') THEN
                x_adjustment_amount := round (ra.adjustment_amount * x_factor_11, x_precision);
                x_ia_reserve := round (ra.adjustment_amount * x_factor_12, x_precision);
               ELSE
                x_ia_reserve := ra.adjustment_amount - x_adjustment_amount;
                x_adjustment_amount := round ((x_ia_reserve * x_factor_11), x_precision);
                x_ia_reserve := round ((x_ia_reserve * x_factor_12), x_precision);

--                x_nbv_retired := x_ia_reserve;

              END IF;

              IF (tr.transaction_type_code <> 'REINSTATEMENT') THEN
                x_deprn_to_cost := x_deprn_to_cost - x_adjustment_amount;
              END IF;

----------------------------------------------------------------------------------
--    Bug Fix 1098809  Add x_ia_reserve also to  x_ia_reserve_retired           --
----------------------------------------------------------------------------------

              x_ia_reserve_retired := x_adjustment_amount + x_ia_reserve + x_ia_reserve_retired;

              insert_adjustment (tr.transaction_header_id,
                                 x_global_source,
                                 x_je_std_category_name,
                                 x_reserve_name,
                                 ra.debit_credit_flag,
                                 ra.code_combination_id,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_adjustment_amount,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ia_deprn_reserve_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_source,
                                 x_je_ia_retirement,
                                 x_ia_reserve_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ia_reserve,
                                 ra.distribution_id,
                                 ra.annualized_adjustment,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 ra.asset_invoice_id,
                                 NULL,
                                 NULL
                                );

            END IF;

           ELSIF ra.adjustment_type IN (x_nbv_retired_name,
                                        x_reval_amort_name,
                                        x_reval_reserve_name,
                                        x_proceeds_name,
                                        x_removal_cost_name
                                       ) THEN

            -----------------------------------------------------------------------------
            -- Change Gain/Loss. Reverse the standard rows and create new rows with    --
            --                   the right account.                                    --
            --    Get the standard row                                                 --
            --    Insert row reversing it                                              --
            --    Insert new row with right account in JL_CO_FA_ADJUSTMENTS            --
            -----------------------------------------------------------------------------

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := ra.adjustment_type;
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            IF (x_gain_loss_changed = TRUE) THEN

              OPEN c_tr_rel_adjustments (tr.source_transaction_header_id,
                                         x_corporate_book,
                                         ra.source_type_code,
                                         ra.adjustment_type,
                                         ra.debit_credit_flag,
                                         ra.distribution_id
                                      );
              FETCH c_tr_rel_adjustments INTO x_code_combination_id,
                                              x_adjustment_amount ;

              IF (c_tr_rel_adjustments%FOUND = TRUE) THEN

                  --FA SLA Changes.
                  IF x_code_combination_id is null then
                    l_book_type_code := x_corporate_book;
                    RAISE e_ccid_not_found;
                  END IF;



                IF (ra.debit_credit_flag = 'DR') THEN
                  x_debit_credit_flag := 'CR';
                 ELSE
                  x_debit_credit_flag := 'DR';
                END IF;

                insert_adjustment (tr.transaction_header_id,
                                   x_global_source,
                                   x_je_ia_retirement,
                                   ra.adjustment_type,
                                   x_debit_credit_flag,
                                   x_code_combination_id,
                                   p_tax_book,
                                   tr.asset_id,
                                   x_adjustment_amount,
                                   ra.distribution_id,
                                   ra.annualized_adjustment,
                                   NULL,
                                   NULL,
                                   ra.period_counter_adjusted,
                                   ra.period_counter_created,
                                   ra.asset_invoice_id,
                                   NULL,
                                   NULL
                                  );

                insert_adjustment (tr.transaction_header_id,
                                   x_global_source,
                                   x_je_ia_retirement,
                                   ra.adjustment_type,
                                   ra.debit_credit_flag,
                                   ra.code_combination_id,
                                   p_tax_book,
                                   tr.asset_id,
                                   x_adjustment_amount,
                                   ra.distribution_id,
                                   ra.annualized_adjustment,
                                   NULL,
                                   NULL,
                                   ra.period_counter_adjusted,
                                   ra.period_counter_created,
                                   ra.asset_invoice_id,
                                   NULL,
                                   NULL
                                  );
              END IF;

              CLOSE c_tr_rel_adjustments;
            END IF;

            IF (ra.adjustment_type = x_nbv_retired_name) THEN
              x_nbv_retired_ccid := ra.code_combination_id;
              x_nbv_debit_credit_flag := ra.debit_credit_flag;
            END IF;
          END IF;

          -----------------------------------------------------------------------------
          --  Retiring or Reinstating Technical Appraisal Account Balances           --
          --    Account balances are full retired or reinstatement                   --
          --    No actions in Partial Retirements                                    --
          -----------------------------------------------------------------------------
 --    LER, 18-Jun-99   Technical Appraisal Balance is retired only FULL    --
--                     RETIREMENTS or Reinstatements reinstated FULL       --
--                     RETIREMENTS.                                         --
          ----------------------------------------------------------------------------------

--          IF (tr.transaction_type_code IN ('FULL RETIREMENT',
--                                           'REINSTATEMENT')

          IF ( (x_retirement_type_code = 'FULL RETIREMENT')
              AND ra.adjustment_type IN (x_cost_name,
                                         x_cip_cost_name
                                        ) ) THEN

            x_ta_line_amount := round (ra.adjustment_amount * x_ta_factor, x_precision);

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              x_char := 'TA adjustment line = ' || to_char(x_ta_line_amount);
              fnd_file.put_line (FND_FILE.LOG, x_char);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
            END IF;

            IF (ra.debit_credit_flag = 'DR') THEN
              x_debit_credit_flag := 'CR';
             ELSE
              x_debit_credit_flag := 'DR';
            END IF;

            IF (tr.appraisal_balance > 0) THEN

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ta_revaluation_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_revaluation_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ta_surplus_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_surplus_name,
                                 x_debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );

             ELSIF (tr.appraisal_balance < 0) THEN

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ta_reserve_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_reserve_name,
                                 x_debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );

              change_account (x_chart_of_accounts_id,
                              x_apps_short_name,
                              x_key_flex_code,
                              x_account_segment,
                              ra.code_combination_id,
                              x_ta_reserve_recovery_segm,
                              x_delimiter,
                              x_returned_ccid,
                              x_error_ccid
                             );

              insert_adjustment (tr.transaction_header_id,
                                 x_global_appraisal,
                                 x_je_appraisal,
                                 x_ta_recovery_name,
                                 ra.debit_credit_flag,
                                 x_returned_ccid,
                                 p_tax_book,
                                 tr.asset_id,
                                 x_ta_line_amount,
                                 ra.distribution_id,
                                 NULL,
                                 NULL,
                                 NULL,
                                 ra.period_counter_adjusted,
                                 ra.period_counter_created,
                                 NULL,
                                 NULL,
                                 NULL
                                );
            END IF;
          END IF;

        END LOOP;

        -----------------------------------------------------------------------------
        --  Add row corresponding to NBV retired due to inflation adjustment       --
        -----------------------------------------------------------------------------

--        x_adjustment_amount := x_ia_cost_retired - x_ia_reserve_retired - x_nbv_retired;
        x_adjustment_amount := x_ia_cost_retired - x_ia_reserve_retired;

        insert_adjustment (tr.transaction_header_id,
                           x_global_source,
                           x_je_ia_retirement,
                           x_nbv_retired_name,
                           x_nbv_debit_credit_flag,
                           x_nbv_retired_ccid,
                           p_tax_book,
                           tr.asset_id,
                           x_adjustment_amount,
                           x_distribution_id,
                           NULL,
                           NULL,
                           NULL,
                           x_period_counter,
                           x_period_counter,
                           NULL,
                           NULL,
                           NULL
                          );
      END IF;

    -----------------------------------------------------------------------------
    --  End of transaction tracked                                             --
    --    Update Depreciation to Cost Inflation Adjustments                    --
    -----------------------------------------------------------------------------

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Update Deprn_to_cost = ' || to_char(x_deprn_to_cost);
        fnd_file.put_line (FND_FILE.LOG, x_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      UPDATE  fa_books
      SET     global_attribute7 = fnd_number.number_to_canonical(x_deprn_to_cost)
      WHERE   rowid = tr.book_rowid ;

    END LOOP;

    -----------------------------------------------------------------------------
    --  Procedure to calculate the Depreciation to Cost Inflation Adjustments  --
    -----------------------------------------------------------------------------

    x_category_id := 0;
    x_global_source := 'DEPRECIATION';

    -----------------------------------------------------------------------------
    --  Assets for tracking                                                    --
    -----------------------------------------------------------------------------

    FOR ad IN c_assets_depreciated (p_tax_book,
                                    x_period_counter,
                                    x_deprn_date
                                   ) LOOP

      -----------------------------------------------------------------------------
      --  Write asset and transaction number on log file                         --
      -----------------------------------------------------------------------------

      fnd_message.set_name ('JL', 'JL_CO_FA_TRANSACTION');
      fnd_message.set_token ('ASSET', ad.asset_number);
      fnd_message.set_token ('TRANSACTION_ID', NULL);
      fnd_message.set_token ('TRANSACTION_TYPE', 'DEPRECIATION');
      fnd_file.put_line (1, fnd_message.get);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Transaction Header Id In = ' || to_char(ad.transaction_header_id_in);
        fnd_file.put_line (FND_FILE.LOG, x_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      -----------------------------------------------------------------------------
      --  Asset category parameters                                                  --
      -----------------------------------------------------------------------------

      IF (ad.category_id <> x_category_id) THEN
          x_category_id := ad.category_id;

        OPEN c_reserve_acct (x_category_id,
                             p_tax_book
                            ) ;
        FETCH c_reserve_acct INTO x_deprn_reserve_ccid,
                                  x_deprn_reserve_segm;
        CLOSE c_reserve_acct;
      END IF;

      x_deprn_to_cost := ad.deprn_to_cost;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Deprn_to_Cost Inicial  = ' || to_char(x_deprn_to_cost);
        fnd_file.put_line (FND_FILE.LOG, x_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      -----------------------------------------------------------------------------
      --  Get distribution lines depreciated for the asset                       --
      -----------------------------------------------------------------------------

      FOR ld IN c_lines_depreciated (p_tax_book,
                                     x_period_counter,
                                     ad.asset_id,
                                     x_corporate_book
                                    ) LOOP

--        IF (ld.adj_deprn_adjustment_amount = 0) THEN
--          x_adjustment_amount := ld.adj_deprn_amount - ld.corp_deprn_amount;
--         ELSE
          x_adjustment_amount := (ld.adj_deprn_amount - ld.adj_deprn_adjustment_amount) -  (ld.corp_deprn_amount - ld.corp_deprn_adjustment_amount);
--        END IF;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'adj_deprn_amount = ' || to_char(ld.adj_deprn_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'adj_deprn_adjust_amount = ' || to_char(ld.adj_deprn_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'corp_deprn_amount = ' || to_char(ld.corp_deprn_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'corp_deprn_adjust_amount = ' || to_char(ld.corp_deprn_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        x_adjustment_amount := round (x_adjustment_amount, x_precision);
        x_deprn_to_cost := x_deprn_to_cost + x_adjustment_amount;

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          x_char := 'x_adjustment_amount = ' || to_char(x_adjustment_amount);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
          x_char := 'x_deprn_to_cost = ' || to_char(x_deprn_to_cost);
          fnd_file.put_line (FND_FILE.LOG, x_char);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
        END IF;

        insert_adjustment (NULL,
                           x_global_source,
                           x_je_depreciation,
                           x_expense_name,
                           'DR',
                           ld.code_combination_id,
                           p_tax_book,
                           ad.asset_id,
                           x_adjustment_amount,
                           ld.distribution_id,
                           NULL,
                           NULL,
                           NULL,
                           x_period_counter,
                           x_period_counter,
                           NULL,
                           NULL,
                           NULL
                          );

        fa_gccid_pkg.fafbgcc_proc (p_tax_book,
                                   'DEPRN_RESERVE_ACCT',
                                   ld.code_combination_id,
                                   x_deprn_reserve_segm,
                                   x_deprn_reserve_ccid,
                                   ld.distribution_id,
                                   x_returned_ccid,
                                   x_concat_segs,
                                   x_return_value
                                  );

        IF (x_return_value = 0) then
          fnd_message.set_name ('JL', 'JL_CO_FA_CCID_NOT_CREATED');
          fnd_message.set_token ('ACCOUNT', x_concat_segs);
          --Bug 2929483. Missing log message handling has been added.
          fnd_file.put_line     (FND_FILE.LOG, fnd_message.get);
          x_error_ccid := TRUE;

         ELSE
          insert_adjustment (NULL,
                             x_global_source,
                             x_je_depreciation,
                             x_reserve_name,
                             'CR',
                             x_returned_ccid,
                             p_tax_book,
                             ad.asset_id,
                             x_adjustment_amount,
                             ld.distribution_id,
                             NULL,
                             NULL,
                             NULL,
                             x_period_counter,
                             x_period_counter,
                             NULL,
                             NULL,
                             NULL
                            );
        END IF;
      END LOOP;

    -----------------------------------------------------------------------------
    --  End of procedure to calculate the Deprn. To Cost Infln. Adjustments    --
    --    Update Depreciation to Cost Inflation Adjustments in GDF7            --
    -----------------------------------------------------------------------------

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        x_char := 'Update Deprn_to_cost = ' || to_char(x_deprn_to_cost);
        fnd_file.put_line (FND_FILE.LOG, x_char);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, x_char);
      END IF;

      UPDATE  fa_books
      SET     global_attribute7 = fnd_number.number_to_canonical(x_deprn_to_cost)
      WHERE   rowid = ad.book_rowid ;

    END LOOP;

    -----------------------------------------------------------------------------
    --  Verify the program error condition                                     --
    -----------------------------------------------------------------------------

    IF (x_error_ccid = TRUE) THEN
      RAISE e_not_finished_by_ccid;
     ELSE

      -----------------------------------------------------------------------------
      --  Update globalization close period counter                              --
      -----------------------------------------------------------------------------

      UPDATE fa_book_controls
      SET    global_attribute5 = x_period_counter
      WHERE  book_type_code = p_tax_book;

      COMMIT WORK;
    END IF;

       IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
       END IF;

    EXCEPTION

      WHEN e_ccid_not_found THEN
        fnd_message.set_name ('JL', 'JL_CO_GENERAL_ERROR');
        fnd_file.put_line (1, fnd_message.get);
        x_char := 'No Code Combination ID has been found. The Create Accounting Program needs to be run for the Book '
                   || l_book_type_code ||' and the period '|| x_period_name;
        fnd_file.put_line (FND_FILE.LOG, x_char);
        ROLLBACK;
        call_status := fnd_concurrent.set_completion_status('ERROR','');
        RAISE_APPLICATION_ERROR (-20000, x_char);



      WHEN e_period_was_closed THEN
        fnd_message.set_name ('JL', 'JL_CO_FA_SAME_AS_PERIOD_CLOSED');
        fnd_message.set_token ('PERIOD', x_period_name);
        fnd_message.set_token ('BOOK', p_tax_book);
        fnd_file.put_line (fnd_file.log, fnd_message.get);
        fnd_file.put_line (1, fnd_message.get);
        ROLLBACK;
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        RAISE_APPLICATION_ERROR (err_num, err_msg);
*/

      WHEN e_not_finished_by_ccid THEN
        fnd_message.set_name ('JL', 'JL_CO_FA_NOT_FINISHED_BY_CCID');
        fnd_file.put_line (1, fnd_message.get);
        ROLLBACK;
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*
        RAISE_APPLICATION_ERROR (err_num, err_msg);
*/

      WHEN OTHERS THEN
        fnd_message.set_name ('JL', 'JL_CO_FA_GENERAL_ERROR');
        fnd_file.put_line (1, fnd_message.get);
        err_num := SQLCODE;
        err_msg := substr (SQLERRM, 1, 190);
        ROLLBACK;
        err_msg := to_char(err_num) || err_msg;
        RAISE_APPLICATION_ERROR (-20000, err_msg);

  END account_transactions;

  ----------------------------------------------------------------------------
  -- PROCEDURE                                                              --
  --   extract_account                                                      --
  --                                                                        --
  -- DESCRIPTION                                                            --
  --   This procedure extracts the natural account from an input AFF        --
  --                                                                        --
  -- PARAMETERS                                                             --
  --   p_chart_of_accounts_id  Identification of accounting structure       --
  --   p_apps_short_name       Short name of the application                --
  --   p_key_flex_code         Code identification of the key flexfield     --
  --   p_account_segment_num   Number of the account segment into AFF       --
  --   p_account_ccid          Default CCID of the account required         --
  --   p_account_segment       Natural account segment                      --
  ----------------------------------------------------------------------------
  --    LER, 18-Jun-99   Procedure is not more used in Release 11.5         --
  --                     because natural account segment will be            --
  --                     directly stored in FA_BOOK_CONTROLS.GDF            --
  ----------------------------------------------------------------------------

  PROCEDURE extract_account (p_chart_of_accounts_id IN  NUMBER,
                             p_apps_short_name      IN  VARCHAR2,
                             p_key_flex_code        IN  VARCHAR2,
                             p_account_segment_num  IN  NUMBER,
                             p_account_ccid         IN  VARCHAR2,
                             p_account_segment      OUT NOCOPY VARCHAR2
                            )
  IS
    x_num_segs    NUMBER ;
    x_segs        FND_FLEX_EXT.SegmentArray ;
    x_dummy       BOOLEAN ;

  BEGIN

    ------------------------------------------------------------------------
    --  Get required segments from distribution line CCID                 --
    ------------------------------------------------------------------------

    x_dummy := fnd_flex_ext.get_segments (p_apps_short_name,
                                          p_key_flex_code,
                                          p_chart_of_accounts_id,
                                          p_account_ccid,
                                          x_num_segs,
                                          x_segs
                                         );

    p_account_segment := x_segs (p_account_segment_num);

  END extract_account;

  ----------------------------------------------------------------------------
  -- PROCEDURE                                                              --
  --   change_account                                                       --
  --                                                                        --
  -- DESCRIPTION                                                            --
  --   This procedure insert the natural account segment in the input AFF   --
  --   and find or generate the CCID for it.                                --
  --                                                                        --
  -- PARAMETERS                                                             --
  --   p_chart_of_accounts_id  Identification of accounting structure       --
  --   p_apps_short_name       Short name of the application                --
  --   p_key_flex_code         Code identification of the key flexfield     --
  --   p_num_segment           Number of the natural account segment        --
  --   p_account_ccid          CCID of the original account flexfield       --
  --   p_account_segment       New natural account segment                  --
  --   p_delimiter             Delimiter character used by application      --
  --   p_returned_ccid         CCID find or generated by procedure          --
  --   p_error_ccid            Error flag if a new CCID can not be inserted --
  ----------------------------------------------------------------------------

  PROCEDURE change_account (p_chart_of_accounts_id IN NUMBER,
                            p_apps_short_name      IN VARCHAR2,
                            p_key_flex_code        IN VARCHAR2,
                            p_num_segment          IN NUMBER,
                            p_account_ccid         IN NUMBER,
                            p_account_segment      IN VARCHAR2,
                            p_delimiter            IN VARCHAR2,
                            p_returned_ccid       OUT NOCOPY NUMBER,
                            p_error_ccid       IN OUT NOCOPY BOOLEAN
                           )
  IS
    x_num_segs   NUMBER ;
    x_segs       FND_FLEX_EXT.SegmentArray ;
    x_flexfield  VARCHAR2 (2000);
    x_dummy      BOOLEAN ;


  BEGIN

    ------------------------------------------------------------------------
    --  Get required segments from distribution line CCID                 --
    ------------------------------------------------------------------------

    x_dummy := fnd_flex_ext.get_segments (p_apps_short_name,
                                          p_key_flex_code,
                                          p_chart_of_accounts_id,
                                          p_account_ccid,
                                          x_num_segs,
                                          x_segs
                                         );

    ------------------------------------------------------------------------
    --  Insert the natural account into input distribution lines CCID     --
    ------------------------------------------------------------------------

    x_segs (p_num_segment) := p_account_segment;

    ------------------------------------------------------------------------
    --  Find or generate the CCID for the new accounting flexfield        --
    ------------------------------------------------------------------------

    x_dummy := fnd_flex_ext.get_combination_id (p_apps_short_name,
                                                p_key_flex_code,
                                                p_chart_of_accounts_id,
                                                sysdate,
                                                x_num_segs,
                                                x_segs,
                                                p_returned_ccid
                                               );
    IF (x_dummy = FALSE) then
      x_flexfield := fnd_flex_ext.concatenate_segments (x_num_segs,
                                                        x_segs,
                                                        p_delimiter
                                                       );
      fnd_message.set_name ('JL', 'JL_CO_FA_CCID_NOT_CREATED');
      fnd_message.set_token ('ACCOUNT', x_flexfield);
      --Bug 2929483. Missing log message handling has been added.
      fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
      p_error_ccid := TRUE;
    END IF;

  END change_account;

  ----------------------------------------------------------------------------
  -- PROCEDURE                                                              --
  --   insert_adjustment                                                    --
  --                                                                        --
  -- DESCRIPTION                                                            --
  --   Insert a row in the table JL_CO_FA_ADJUSTMENT                        --
  --                                                                        --
  -- PARAMETERS                                                             --
  --   p_transaction_header_id                                              --
  --   p_source_type_code                                                   --
  --   p_je_category_name                                                   --
  --   p_adjustment_type                                                    --
  --   p_debit_credit_flag                                                  --
  --   p_code_combination_id                                                --
  --   p_book_type_code                                                     --
  --   p_asset_id                                                           --
  --   p_adjustment_amount                                                  --
  --   p_distribution_id                                                    --
  --   p_annualized_adjustment                                              --
  --   p_je_header_reference_id                                             --
  --   p_sequence_line                                                      --
  --   p_period_counter_adjusted                                            --
  --   p_period_counter_created                                             --
  --   p_asset_invoice_id                                                   --
  --   p_reference                                                          --
  --   p_posting_flag                                                       --
  ----------------------------------------------------------------------------

  PROCEDURE insert_adjustment (p_transaction_header_id    IN jl_co_fa_adjustments.transaction_header_id%TYPE,
                               p_source_type_code         IN jl_co_fa_adjustments.source_type_code%TYPE,
                               p_je_category_name         IN jl_co_fa_adjustments.je_category_name%TYPE,
                               p_adjustment_type          IN jl_co_fa_adjustments.adjustment_type%TYPE,
                               p_debit_credit_flag        IN jl_co_fa_adjustments.debit_credit_flag%TYPE,
                               p_code_combination_id      IN jl_co_fa_adjustments.code_combination_id%TYPE,
                               p_book_type_code           IN jl_co_fa_adjustments.book_type_code%TYPE,
                               p_asset_id                 IN jl_co_fa_adjustments.asset_id%TYPE,
                               p_adjustment_amount        IN jl_co_fa_adjustments.adjustment_amount%TYPE,
                               p_distribution_id          IN jl_co_fa_adjustments.distribution_id%TYPE,
                               p_annualized_adjustment    IN jl_co_fa_adjustments.annualized_adjustment%TYPE,
                               p_je_header_reference_id   IN jl_co_fa_adjustments.je_header_reference_id%TYPE,
                               p_sequence_line            IN jl_co_fa_adjustments.sequence_line%TYPE,
                               p_period_counter_adjusted  IN jl_co_fa_adjustments.period_counter_adjusted%TYPE,
                               p_period_counter_created   IN jl_co_fa_adjustments.period_counter_created%TYPE,
                               p_asset_invoice_id         IN jl_co_fa_adjustments.asset_invoice_id%TYPE,
                               p_reference                IN jl_co_fa_adjustments.reference%TYPE,
                               p_posting_flag             IN jl_co_fa_adjustments.posting_flag%TYPE
                              )
  IS

    x_adjustment_amount   NUMBER;
    x_debit_credit_flag   fa_adjustments.debit_credit_flag%TYPE;
    call_status   BOOLEAN;
    l_original_cost       NUMBER;


  BEGIN

    IF (p_adjustment_amount <> 0) THEN

      --------------------------------------------------------------------------------
      -- Bug 4758713. Assets with Negative cost are allowed. When inflation amount
      --              is a Credit to accoumulated depreciation, this value shoud have
      --              been displayed a negative value.
      --------------------------------------------------------------------------------

      --Bug 4758713. Retrieves the original cost to verify if the asset has negative cost.
      BEGIN
        SELECT original_cost
        INTO   l_original_cost
        FROM   FA_BOOKS
        WHERE  book_type_code = p_book_type_code
        AND    asset_id       = p_asset_id;
      EXCEPTION
        WHEN OTHERS THEN
        --If exception occurs, we assume orignal cost as zero (positive).
        l_original_cost := 0;
      END;

      --Bug 4758713. If asset has negative cost do not flip the flags DR and CR or sign.
      IF l_original_cost >= 0 THEN
        IF (p_adjustment_amount > 0) THEN
          x_adjustment_amount := p_adjustment_amount;
          x_debit_credit_flag := p_debit_credit_flag;
        ELSE
          x_adjustment_amount := - p_adjustment_amount;
          IF (p_debit_credit_flag = 'DR') THEN
            x_debit_credit_flag := 'CR';
          ELSE
            x_debit_credit_flag := 'DR';
          END IF;
        END IF;
      ELSE
        x_adjustment_amount := p_adjustment_amount;
        x_debit_credit_flag := p_debit_credit_flag;
      END IF;

      IF p_code_combination_id IS NOT NULL THEN
        INSERT INTO jl_co_fa_adjustments
                  (transaction_header_id,
                   source_type_code,
                   je_category_name,
                   adjustment_type,
                   debit_credit_flag,
                   code_combination_id,
                   book_type_code,
                   asset_id,
                   adjustment_amount,
                   distribution_id,
                   annualized_adjustment,
                   je_header_reference_id,
                   sequence_line,
                   period_counter_adjusted,
                   period_counter_created,
                   asset_invoice_id,
                   reference,
                   posting_flag,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date
                  )
        VALUES    (p_transaction_header_id,
                   p_source_type_code,
                   p_je_category_name,
                   p_adjustment_type,
                   x_debit_credit_flag,
                   p_code_combination_id,
                   p_book_type_code,
                   p_asset_id,
                   x_adjustment_amount,
                   p_distribution_id,
                   p_annualized_adjustment,
                   p_je_header_reference_id,
                   p_sequence_line,
                   p_period_counter_adjusted,
                   p_period_counter_created,
                   p_asset_invoice_id,
                   p_reference,
                   p_posting_flag,
                   x_last_updated_by,
                   x_sysdate,
                   x_last_updated_by,
                   x_sysdate,
                   x_last_update_login,
                   x_request_id,
                   x_program_application_id,
                   x_program_id,
                   x_sysdate
                  );
      ELSE
        fnd_message.set_name ('JL', 'JL_CO_FA_NOT_FINISHED_BY_CCID');
        fnd_file.put_line (FND_FILE.LOG,fnd_message.get);
        ROLLBACK;
        call_status := fnd_concurrent.set_completion_status('ERROR','');
      END IF;

    END IF;

  END insert_adjustment;

----------------------------------------------------------------------------
--    End of body package file                                            --
----------------------------------------------------------------------------

END jl_co_fa_accounting_pkg;

/
