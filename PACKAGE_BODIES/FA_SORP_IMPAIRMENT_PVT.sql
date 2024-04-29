--------------------------------------------------------
--  DDL for Package Body FA_SORP_IMPAIRMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SORP_IMPAIRMENT_PVT" AS
/* $Header: FAVSIMPB.pls 120.3.12010000.1 2009/07/21 12:37:44 glchen noship $ */

  --
  -- Datatypes for pl/sql tables below
  --
  TYPE tab_rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tab_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE tab_char1_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char3_type IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;
  TYPE tab_char15_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE tab_char30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


/*#
 * Thus function is used to create the impairment accounting entries for SORP
 * for a particular impairment classification type
 * This function is invoked from the function 'create_sorp_imp_acct' during
 * the posting of an impairment
 * @param p_impair_class The impairment classification code for which accounting
                         must be done
 * @param p_impair_loss_acct The impairment loss account specified by the user
 * @param p_impairment_amount The impairment loss amount
 * @param p_reval_reserve_adj The amount of revaluation reserve that was adjusted
 * @param px_adj Adjustment record, needs to be prepopulated
 * @param p_created_by Standard WHO column
 * @param p_creation_date Standard WHO column
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname create_acct_impair_class
 * @rep:compatibility S
*/
FUNCTION create_acct_impair_class (
    p_impair_class          IN VARCHAR2,
    p_impair_loss_acct      IN VARCHAR2,
    p_impairment_amount     IN NUMBER,
    p_reval_reserve_adj     IN NUMBER,
    px_adj                   IN OUT NOCOPY FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT,
    p_created_by            IN NUMBER,
    p_creation_date         IN DATE
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS
    pos_err EXCEPTION;
    l_calling_fn        varchar2(60) := 'create_acct_impair_class';
    l_mode              varchar2(20) := 'RUNNING POST';
BEGIN

    IF (p_log_level_rec.statement_level) THEN
        fa_debug_pkg.add(l_calling_fn,'p_impair_class', p_impair_class, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_impair_loss_acct', p_impair_loss_acct, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_impairment_amount', p_impairment_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_reval_reserve_adj', p_reval_reserve_adj, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'px_adj.book_type_code', px_adj.book_type_code, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_created_by', p_created_by, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_creation_date', p_creation_date, p_log_level_rec => p_log_level_rec);
    END IF;

    --Leveling is not required for SORP entries
    px_adj.leveling_flag := FALSE;

    -- Accounting is different for impairment of type CEB
    IF p_impair_class = 'CEB' THEN

        --******************************************************
        --       SORP Accumulated Impairment
        --******************************************************
        px_adj.adjustment_amount := p_impairment_amount;
        px_adj.adjustment_type   := 'IMPAIR RESERVE';
        px_adj.account_type      := 'IMPAIR_RESERVE_ACCT';
        px_adj.account           := fa_cache_pkg.fazccb_record.impair_reserve_acct;
        px_adj.debit_credit_flag := 'CR';

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ',
                                          'SORP CEB Enabled Accumulated Impairments', p_log_level_rec => p_log_level_rec);
        END IF;

        IF NOT FA_INS_ADJUST_PKG.faxinaj (px_adj,
                                          p_creation_date,
                                          p_created_by, p_log_level_rec => p_log_level_rec) THEN
            raise pos_err;
        END IF;


        --******************************************************
        --       SORP Impairment Expense
        --******************************************************
        px_adj.adjustment_amount := p_impairment_amount;
        px_adj.adjustment_type   := 'IMPAIR EXPENSE';
        px_adj.account_type      := 'IMPAIR_EXPENSE_ACCT';
        IF p_impair_loss_acct IS NOT NULL THEN
            px_adj.account           := p_impair_loss_acct;
        ELSE
            px_adj.account           := fa_cache_pkg.fazccb_record.impair_expense_acct;
        END IF;
        px_adj.debit_credit_flag := 'DR';

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ',
                                          'SORP CEB Enabled Impairments Expense', p_log_level_rec => p_log_level_rec);
        END IF;

        IF NOT FA_INS_ADJUST_PKG.faxinaj (px_adj,
                                          p_creation_date,
                                          p_created_by, p_log_level_rec => p_log_level_rec) THEN
            RAISE pos_err;
        END IF;


        IF (p_reval_reserve_adj <> 0) THEN
            --******************************************************
            --      SORP Revaluation Reserve CEB
            --******************************************************
            px_adj.adjustment_amount := p_reval_reserve_adj;
            px_adj.adjustment_type   := 'REVAL RESERVE';
            px_adj.account_type      := 'REVAL_RESERVE_ACCT';
            px_adj.account           := fa_cache_pkg.fazccb_record.reval_reserve_acct;
            px_adj.debit_credit_flag := 'DR';

            IF (p_log_level_rec.statement_level) THEN
                fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ',
                                              'SORP CEB Reval Reserve', p_log_level_rec => p_log_level_rec);
            END IF;

            IF NOT FA_INS_ADJUST_PKG.faxinaj (px_adj,
                                              p_creation_date,
                                              p_created_by, p_log_level_rec => p_log_level_rec) THEN
                RAISE pos_err;
            END IF;

            --******************************************************
            --      SORP Capital Adjustment CEB
            --******************************************************
            px_adj.adjustment_amount := p_reval_reserve_adj;
            px_adj.adjustment_type   := 'CAPITAL ADJ';
            px_adj.account_type      := 'CAPITAL_ADJ_ACCT';
            px_adj.account           := fa_cache_pkg.fazccb_record.capital_adj_acct;
            px_adj.debit_credit_flag := 'CR';

            IF (p_log_level_rec.statement_level) THEN
                fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ',
                                              'SORP CEB Capital Adjustment', p_log_level_rec => p_log_level_rec);
            END IF;
            IF NOT FA_INS_ADJUST_PKG.faxinaj (px_adj,
                                              p_creation_date,
                                              p_created_by, p_log_level_rec => p_log_level_rec) THEN
                RAISE pos_err;
            END IF;
        END IF; --End t_reval_reserve_adj_amount(i) <> 0

        IF NOT FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                   p_impairment_amount
                  , 'N'
                  , px_adj
                  , p_created_by
                  , p_creation_date
                  , p_log_level_rec => p_log_level_rec) then
            fa_debug_pkg.add(l_calling_fn,'Error at create_sorp_neutral_acct',
                                         'for SORP for type CEB', p_log_level_rec => p_log_level_rec);
            RETURN FALSE;
        END IF;

    ELSE -- If p_impair_class <> 'CEB'

        --******************************************************
        --       SORP Accumulated Impairment
        --******************************************************
        px_adj.adjustment_amount := p_impairment_amount + nvl(p_reval_reserve_adj,0);
        px_adj.adjustment_type   := 'IMPAIR RESERVE';
        px_adj.account_type      := 'IMPAIR_RESERVE_ACCT';
        px_adj.account           := fa_cache_pkg.fazccb_record.impair_reserve_acct;
        px_adj.debit_credit_flag := 'CR';

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for '
                                        , 'SORP Enabled Accumulated Impairments', p_log_level_rec => p_log_level_rec);
        END IF;

        IF NOT FA_INS_ADJUST_PKG.faxinaj (px_adj,
                                          p_creation_date,
                                          p_created_by, p_log_level_rec => p_log_level_rec) THEN
            RAISE pos_err;
        END IF;

        --******************************************************
        --       SORP Impairment Expense
        --******************************************************
        px_adj.adjustment_amount := p_impairment_amount;
        px_adj.adjustment_type   := 'IMPAIR EXPENSE';
        px_adj.account_type      := 'IMPAIR_EXPENSE_ACCT';
        IF p_impair_loss_acct IS NOT NULL THEN
            px_adj.account           := p_impair_loss_acct;
        ELSE
            px_adj.account           := fa_cache_pkg.fazccb_record.impair_expense_acct;
        END IF;
        px_adj.debit_credit_flag := 'DR';

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for '
                                        , 'SORP Enabled Impairments Expense', p_log_level_rec => p_log_level_rec);
        END IF;

        IF NOT FA_INS_ADJUST_PKG.faxinaj (px_adj,
                                          p_creation_date,
                                          p_created_by, p_log_level_rec => p_log_level_rec) THEN
            RAISE pos_err;
        END IF;

        IF (p_reval_reserve_adj <> 0) THEN
            --******************************************************
            --      SORP Revaluation Reserve CEB
            --******************************************************
            px_adj.adjustment_amount := p_reval_reserve_adj;
            px_adj.adjustment_type   := 'REVAL RESERVE';
            px_adj.account_type      := 'REVAL_RESERVE_ACCT';
            px_adj.account           := fa_cache_pkg.fazccb_record.reval_reserve_acct;
            px_adj.debit_credit_flag := 'DR';

            IF (p_log_level_rec.statement_level) THEN
                fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for '
                                            , 'SORP Reval Reserve', p_log_level_rec => p_log_level_rec);
            END IF;

            IF NOT FA_INS_ADJUST_PKG.faxinaj (px_adj,
                                              p_creation_date,
                                              p_created_by, p_log_level_rec => p_log_level_rec) THEN
                RAISE pos_err;
            END IF;
        END IF; --End t_reval_reserve_adj_amount(i) <> 0

        IF NOT FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                   p_impairment_amount
                  , 'N'
                  , px_adj
                  , p_created_by
                  , p_creation_date
                  , p_log_level_rec => p_log_level_rec) THEN
            fa_debug_pkg.add(l_calling_fn,'Error at create_sorp_neutral_acct',
                                         'for SORP for type CEB', p_log_level_rec => p_log_level_rec);
            RETURN FALSE;
        END IF;

    END IF; -- End if p_impair_class = 'CEB'

    IF (p_log_level_rec.statement_level) THEN
        fa_debug_pkg.add(l_calling_fn,'create_acct_impair_class completed', 'Success', p_log_level_rec => p_log_level_rec);
    END IF;

    --Reset the flag to True
    px_adj.leveling_flag := TRUE;

    RETURN TRUE;

EXCEPTION
   WHEN pos_err THEN

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn,'exception at create_acct_impair_class', 'pos_err', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      END IF;

      RETURN FALSE;

   WHEN OTHERS THEN

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn,'exception at create_acct_impair_class', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      END IF;

      RETURN FALSE;
END;


/*#
 * Thus function is used to create the impairment accounting entries a SORP
 * impairment
 * This function is invoked from the package FA_IMPAIRMENT_POST_PVT during
 * the posting of an impairment
 * @param px_adj Adjustment record, needs to be prepopulated
 * @param p_impairment_amount The impairment loss amount
 * @param p_reval_reserve_adj The amount of revaluation reserve that was adjusted
 * @param p_impair_class The impairment classification code for which accounting
                         must be done
 * @param p_impair_loss_acct The impairment loss account specified by the user
 * @param p_split_impair_flag Indicates whether the impairment is split or not
 * @param p_split1_impair_class The impairment classification type for Split 1
 * @param p_split1_loss_amount The impairment loss amount for Split 1
 * @param p_split1_reval_reserve The amount of revaluation reserve that was
                                 adjustment for Split 1
 * @param p_split1_loss_acct The impairment loss account for Split 1
 * @param p_split2_impair_class The impairment classification type for Split 2
 * @param p_split2_loss_amount The impairment loss amount for Split 2
 * @param p_split2_reval_reserve The amount of revaluation reserve that was
                                 adjustment for Split 2
 * @param p_split2_loss_acct The impairment loss account for Split 2
 * @param p_split3_impair_class The impairment classification type for Split 3
 * @param p_split3_loss_amount The impairment loss amount for Split 3
 * @param p_split3_reval_reserve The amount of revaluation reserve that was
                                 adjustment for Split 3
 * @param p_split3_loss_acct The impairment loss account for Split 3
 * @param p_created_by Standard WHO column
 * @param p_creation_date Standard WHO column
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname create_sorp_imp_acct
 * @rep:compatibility S
*/
FUNCTION create_sorp_imp_acct (
    px_adj                   IN OUT NOCOPY FA_ADJUST_TYPE_PKG.FA_ADJ_ROW_STRUCT,
    p_impairment_amount     IN NUMBER,
    p_reval_reserve_adj     IN NUMBER,

    p_impair_class          IN VARCHAR2,
    p_impair_loss_acct      IN VARCHAR2,
    p_split_impair_flag     IN VARCHAR2,

    p_split1_impair_class   IN VARCHAR2,
    p_split1_loss_amount    IN NUMBER,
    p_split1_reval_reserve  IN NUMBER,
    p_split1_loss_acct      IN VARCHAR2,

    p_split2_impair_class   IN VARCHAR2,
    p_split2_loss_amount    IN NUMBER,
    p_split2_reval_reserve  IN NUMBER,
    p_split2_loss_acct      IN VARCHAR2,

    p_split3_impair_class   IN VARCHAR2,
    p_split3_loss_amount    IN NUMBER,
    p_split3_reval_reserve  IN NUMBER,
    p_split3_loss_acct      IN VARCHAR2,

    p_created_by            IN NUMBER,
    p_creation_date         IN DATE

, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS
    l_calling_fn        varchar2(60) := 'create_sorp_imp_acct';
    l_mode              varchar2(20) := 'RUNNING POST';
BEGIN

    IF (p_log_level_rec.statement_level) THEN
        fa_debug_pkg.add(l_calling_fn,'px_adj.book_type_code', px_adj.book_type_code, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_impairment_amount', p_impairment_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_reval_reserve_adj', p_reval_reserve_adj, p_log_level_rec => p_log_level_rec);

        fa_debug_pkg.add(l_calling_fn,'p_impair_class', p_impair_class, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_impair_loss_acct', p_impair_loss_acct, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split_impair_flag', p_split_impair_flag, p_log_level_rec => p_log_level_rec);

        fa_debug_pkg.add(l_calling_fn,'p_split1_impair_class', p_split1_impair_class, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split1_loss_amount', p_split1_loss_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split1_reval_reserve', p_split1_reval_reserve, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split1_loss_acct', p_split1_loss_acct, p_log_level_rec => p_log_level_rec);

        fa_debug_pkg.add(l_calling_fn,'p_split2_impair_class', p_split2_impair_class, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split2_loss_amount', p_split2_loss_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split2_reval_reserve', p_split2_reval_reserve, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split2_loss_acct', p_split2_loss_acct, p_log_level_rec => p_log_level_rec);

        fa_debug_pkg.add(l_calling_fn,'p_split3_impair_class', p_split3_impair_class, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split3_loss_amount', p_split3_loss_amount, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split3_reval_reserve', p_split3_reval_reserve, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_split3_loss_acct', p_split3_loss_acct, p_log_level_rec => p_log_level_rec);

        fa_debug_pkg.add(l_calling_fn,'p_created_by', p_created_by, p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'p_creation_date', p_creation_date, p_log_level_rec => p_log_level_rec);
    END IF;

    IF p_split_impair_flag = 'Y' THEN

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'calling create_acct_impair_class', 'split1', p_log_level_rec => p_log_level_rec);
        END IF;

        IF p_split1_impair_class IS NOT NULL THEN
            IF NOT create_acct_impair_class(
                        p_impair_class => p_split1_impair_class
                      , p_impair_loss_acct => p_split1_loss_acct
                      , p_impairment_amount => p_split1_loss_amount
                      , p_reval_reserve_adj => p_split1_reval_reserve
                      , px_adj => px_adj
                      , p_created_by => p_created_by
                      , p_creation_date => p_creation_date
                      , p_log_level_rec => p_log_level_rec
                      ) THEN
                fa_debug_pkg.add(l_calling_fn,'Error at split 1 create_acct_impair_class',
                                             'for SORP', p_log_level_rec => p_log_level_rec);
                RETURN FALSE;
            END IF;
        END IF;

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'calling create_acct_impair_class', 'split2', p_log_level_rec => p_log_level_rec);
        END IF;

        IF p_split2_impair_class IS NOT NULL THEN
            IF NOT create_acct_impair_class(
                        p_impair_class => p_split2_impair_class
                      , p_impair_loss_acct => p_split2_loss_acct
                      , p_impairment_amount => p_split2_loss_amount
                      , p_reval_reserve_adj => p_split2_reval_reserve
                      , px_adj => px_adj
                      , p_created_by => p_created_by
                      , p_creation_date => p_creation_date
                      , p_log_level_rec => p_log_level_rec
                      ) THEN
                fa_debug_pkg.add(l_calling_fn,'Error at split 2 create_acct_impair_class',
                                             'for SORP', p_log_level_rec => p_log_level_rec);
                RETURN FALSE;
            END IF;
        END IF;

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'calling create_acct_impair_class', 'split3', p_log_level_rec => p_log_level_rec);
        END IF;

        IF p_split3_impair_class IS NOT NULL THEN
            IF NOT create_acct_impair_class(
                        p_impair_class => p_split3_impair_class
                      , p_impair_loss_acct => p_split3_loss_acct
                      , p_impairment_amount => p_split3_loss_amount
                      , p_reval_reserve_adj => p_split3_reval_reserve
                      , px_adj => px_adj
                      , p_created_by => p_created_by
                      , p_creation_date => p_creation_date
                      , p_log_level_rec => p_log_level_rec
                      ) THEN
                fa_debug_pkg.add(l_calling_fn,'Error at split 3 create_acct_impair_class',
                                             'for SORP', p_log_level_rec => p_log_level_rec);
                RETURN FALSE;
            END IF;
        END IF;

        If (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'create_sorp_imp_acct completed for split', 'Success', p_log_level_rec => p_log_level_rec);
        END IF;

        RETURN TRUE;

    ELSE -- Impairment is not split

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'calling', 'create_acct_impair_class', p_log_level_rec => p_log_level_rec);
        END IF;

        IF NOT create_acct_impair_class(
                    p_impair_class => p_impair_class
                  , p_impair_loss_acct => p_impair_loss_acct
                  , p_impairment_amount => p_impairment_amount
                  , p_reval_reserve_adj => p_reval_reserve_adj
                  , px_adj => px_adj
                  , p_created_by => p_created_by
                  , p_creation_date => p_creation_date
                  , p_log_level_rec => p_log_level_rec

                  ) THEN
            fa_debug_pkg.add(l_calling_fn,'Error at non split create_acct_impair_class',
                                         'for SORP', p_log_level_rec => p_log_level_rec);
            RETURN FALSE;
        END IF;

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'create_acct_impair_class completed', 'Success', p_log_level_rec => p_log_level_rec);
        END IF;

        IF (p_log_level_rec.statement_level) THEN
            fa_debug_pkg.add(l_calling_fn,'create_sorp_imp_acct completed for non split', 'Success', p_log_level_rec => p_log_level_rec);
        END IF;

        RETURN TRUE;

    END IF; -- IF p_split_impair_flag = 'Y' THEN

EXCEPTION
   WHEN OTHERS THEN

      IF (p_log_level_rec.statement_level) THEN
         fa_debug_pkg.add(l_calling_fn,'exception at create_acct_impair_class', 'OTHERS', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
      END IF;

      RETURN FALSE;
END;


/*#
 * Thus function is invoked during the impairment preview stage. This performs
 * all the necessary SORP events required during impairment preview stage
 * This function is invoked from the package FA_IMPAIRMENT_PREV_PVT during
 * the the impairment preview phase
 * @param p_request_id The request id of the impairment preview process
 * @param p_impairment_id The impairment id for which processing need to be done
 * @param @p_mrc_sob_type_code Indicates if MRC is used
 * @param @p_book_type_code The book for which impairment was generated
 * @param @p_precision The precision of the current in order to perform rounding
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname sorp_processing
 * @rep:compatibility S
*/
FUNCTION sorp_processing( p_request_id            IN NUMBER
                        , p_impairment_id         IN NUMBER
                        , p_mrc_sob_type_code     IN VARCHAR2
                        , p_set_of_books_id       IN NUMBER
                        , p_book_type_code        IN VARCHAR2
                        , p_precision             IN NUMBER

, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

    l_calling_fn   varchar2(60) := 'imp sorp_processing';

    CURSOR c_mc_impairment_details(c_impairment_id NUMBER
                              , c_book_type_code VARCHAR2) IS
        select IMPAIRMENT_AMOUNT
             , REVAL_RESERVE
             , NVL(SPLIT_IMPAIR_FLAG, 'N')
             , SPLIT1_PERCENT
             , SPLIT2_PERCENT
             , SPLIT3_PERCENT
             , ASSET_ID
             , SPLIT1_IMPAIR_CLASS
             , SPLIT2_IMPAIR_CLASS
             , SPLIT3_IMPAIR_CLASS
        from   fa_mc_itf_impairments
        where  impairment_id = c_impairment_id
        and    book_type_code = c_book_type_code
        and    nvl(goodwill_asset_flag, 'N') <> 'Y'
        and    set_of_books_id = p_set_of_books_id;

    CURSOR c_impairment_details(c_impairment_id NUMBER
                              , c_book_type_code VARCHAR2) IS
        select IMPAIRMENT_AMOUNT
             , REVAL_RESERVE
             , NVL(SPLIT_IMPAIR_FLAG, 'N')
             , SPLIT1_PERCENT
             , SPLIT2_PERCENT
             , SPLIT3_PERCENT
             , ASSET_ID
             , SPLIT1_IMPAIR_CLASS
             , SPLIT2_IMPAIR_CLASS
             , SPLIT3_IMPAIR_CLASS
        from   fa_itf_impairments
        where  impairment_id = c_impairment_id
        and    book_type_code = c_book_type_code
        and    nvl(goodwill_asset_flag, 'N') <> 'Y';

    -- Placeholder columns for c_impairment_details
    t_impair_amount         tab_num_type;
    t_reval_reserve         tab_num_type;
    t_split_impair_flag     tab_char1_type;
    t_split1_percent        tab_num_type;
    t_split2_percent        tab_num_type;
    t_split3_percent        tab_num_type;
    t_asset_id              tab_num_type;
    t_split1_impair_class   tab_char3_type;
    t_split2_impair_class   tab_char3_type;
    t_split3_impair_class   tab_char3_type;

    -- Columns to hold the calculated split amount
    l_split1_loss_amount    NUMBER;
    l_split2_loss_amount    NUMBER;
    l_split3_loss_amount    NUMBER;

    -- Variable to hold the number of splits for a given impairment
    l_number_of_splits      NUMBER;

    -- Record to store the split
    -- This is used for sorting and determining the order in which the splits
    -- have to be processed
    TYPE split_process_order_rec IS RECORD (split_class        number
                                          , split_class_code   varchar2(3)
                                          , split_loss_amount  number
                                          , split_number       number
                                          , reval_reserve      number
                                          );
    TYPE split_process_order_tab IS TABLE OF split_process_order_rec;
    t_split_process_order split_process_order_tab;
    l_temp_split_process_order split_process_order_rec;

BEGIN


    IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.add(l_calling_fn,'Start ', 'sorp_processing', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'p_request_id', p_request_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'p_impairment_id',p_impairment_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'p_mrc_sob_type_code ', p_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn,'p_precision ', p_precision, p_log_level_rec => p_log_level_rec);
    END IF;

    -- This is used for sorting and determining the order in which the splits
    -- have to be processed
    -- Since there are a maximum of three splits, the size of this structure
    -- can be set to 3 at the initialization time
    t_split_process_order := split_process_order_tab();
    t_split_process_order.extend(3);

    IF (p_mrc_sob_type_code = 'R') THEN
        OPEN c_mc_impairment_details(p_impairment_id, p_book_type_code);
        FETCH c_mc_impairment_details BULK COLLECT INTO t_impair_amount
                                      , t_reval_reserve
                                      , t_split_impair_flag
                                      , t_split1_percent
                                      , t_split2_percent
                                      , t_split3_percent
                                      , t_asset_id
                                      , t_split1_impair_class
                                      , t_split2_impair_class
                                      , t_split3_impair_class
                                      ;

        IF t_asset_id.count = 0 THEN
            fa_debug_pkg.add(l_calling_fn,'p_impairment_id', p_impairment_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,'p_book_type_code', p_book_type_code, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,'Unexpected error at c_mc_impairment_details', 'FA_ITF_IMPAIRMENTS', p_log_level_rec => p_log_level_rec);
            CLOSE c_mc_impairment_details;
            RETURN FALSE;
        END IF;

        CLOSE c_mc_impairment_details;
    ELSE
        OPEN c_impairment_details(p_impairment_id, p_book_type_code);
        FETCH c_impairment_details BULK COLLECT INTO t_impair_amount
                                      , t_reval_reserve
                                      , t_split_impair_flag
                                      , t_split1_percent
                                      , t_split2_percent
                                      , t_split3_percent
                                      , t_asset_id
                                      , t_split1_impair_class
                                      , t_split2_impair_class
                                      , t_split3_impair_class
                                      ;

        IF t_asset_id.count = 0 THEN
            fa_debug_pkg.add(l_calling_fn,'p_impairment_id', p_impairment_id, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,'p_book_type_code', p_book_type_code, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn,'Unexpected error at c_impairment_details', 'FA_ITF_IMPAIRMENTS', p_log_level_rec => p_log_level_rec);
            CLOSE c_impairment_details;
            RETURN FALSE;
        END IF;

        CLOSE c_impairment_details;
    END IF;

    IF (p_log_level_rec.statement_level) THEN
      fa_debug_pkg.add(l_calling_fn,'Number of records fetched', t_asset_id.count, p_log_level_rec => p_log_level_rec);
    END IF;

    FOR i IN t_asset_id.FIRST..t_asset_id.LAST LOOP

        IF (p_log_level_rec.statement_level) THEN
          fa_debug_pkg.add(l_calling_fn,'i', i, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn,'t_impair_amount(i)', t_impair_amount(i));
          fa_debug_pkg.add(l_calling_fn,'t_reval_reserve(i)', t_reval_reserve(i));
          fa_debug_pkg.add(l_calling_fn,'t_split_impair_flag(i)', t_split_impair_flag(i));
          fa_debug_pkg.add(l_calling_fn,'t_split1_percent(i)', t_split1_percent(i));
          fa_debug_pkg.add(l_calling_fn,'t_split2_percent(i)', t_split2_percent(i));
          fa_debug_pkg.add(l_calling_fn,'t_split3_percent(i)', t_split3_percent(i));
          fa_debug_pkg.add(l_calling_fn,'t_asset_id(i)', t_asset_id(i));
          fa_debug_pkg.add(l_calling_fn,'t_split1_impair_class(i)', t_split1_impair_class(i));
          fa_debug_pkg.add(l_calling_fn,'t_split2_impair_class(i)', t_split2_impair_class(i));
          fa_debug_pkg.add(l_calling_fn,'t_split3_impair_class(i)', t_split3_impair_class(i));
        END IF;

        IF t_split_impair_flag(i) = 'Y' THEN -- If the impairment is split

            --******************************************************************
            --Logic A
            --Logic to calculate the loss amounts for each split. Users define
            --the split percentage in the WebADI. This logic is used to calculate
            --the impairment loss amount for each split. There can be a minimum of
            --two splits and a maximum of three splits
            --******************************************************************

            IF t_split1_impair_class(i) IS NOT NULL AND -- If two splits are defined
            t_split2_impair_class(i) IS NOT NULL AND
            t_split3_impair_class(i) IS NULL THEN
                l_number_of_splits := 2;
                l_split1_loss_amount := round(((t_impair_amount(i) * t_split1_percent(i))/100),p_precision);
                l_split2_loss_amount := t_impair_amount(i) - l_split1_loss_amount;
            ELSE
                IF t_split1_impair_class(i) is NOT NULL AND  -- If three splits are defined
                    t_split2_impair_class(i) is NOT NULL AND
                    t_split3_impair_class(i) is NOT NULL THEN
                        l_number_of_splits := 3;
                        l_split1_loss_amount := round(((t_impair_amount(i) * t_split1_percent(i))/100),p_precision);
                        l_split2_loss_amount := round(((t_impair_amount(i) * t_split2_percent(i))/100),p_precision);
                        l_split3_loss_amount := t_impair_amount(i) - (l_split1_loss_amount + l_split2_loss_amount);
                END IF;
            END IF;

            IF (p_log_level_rec.statement_level) THEN
                fa_debug_pkg.add(l_calling_fn,'l_number_of_splits', l_number_of_splits, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn,'l_split1_loss_amount', l_split1_loss_amount, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn,'l_split2_loss_amount', l_split2_loss_amount, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn,'l_split3_loss_amount', l_split3_loss_amount, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn,'t_reval_reserve(i)',t_reval_reserve(i));
                fa_debug_pkg.add(l_calling_fn,'Calculation of split amounts', 'Completed', p_log_level_rec => p_log_level_rec);
            END IF;

            --------------------------------------------------------------------
            -- End of Logic A
            -- End of Logic to calculate the loss amounts for each split
            --------------------------------------------------------------------




            --******************************************************************
            -- Logic B
            -- Logic to select the order of split processing
            -- As per the SORP Function Design Document, splits must be processed
            -- in the following hierarchy
            -- 1. Classification Type- First "CPP", followed by "Others", then "CEB"
            -- 2. Amounts (Percent)- Largest first
            -- 3. Split Number - Smallest first
            --******************************************************************

            -- Populate the record array on which sorting will be performed
            -- Split 1
            IF t_split1_impair_class(i) = 'CPP' THEN
                t_split_process_order(1).split_class := 1;
            END IF;
            IF t_split1_impair_class(i) = 'OTH' THEN
                t_split_process_order(1).split_class := 2;
            END IF;
            IF t_split1_impair_class(i) = 'CEB' THEN
                t_split_process_order(1).split_class := 3;
            END IF;
            t_split_process_order(1).split_class_code := t_split1_impair_class(i);
            t_split_process_order(1).split_loss_amount := l_split1_loss_amount;
            t_split_process_order(1).split_number := 1;

            -- Split 2
            IF t_split2_impair_class(i) = 'CPP' THEN
                t_split_process_order(2).split_class := 1;
            END IF;
            IF t_split2_impair_class(i) = 'OTH' THEN
                t_split_process_order(2).split_class := 2;
            END IF;
            IF t_split2_impair_class(i) = 'CEB' THEN
                t_split_process_order(2).split_class := 3;
            END IF;
            t_split_process_order(2).split_class_code := t_split2_impair_class(i);
            t_split_process_order(2).split_loss_amount := l_split2_loss_amount;
            t_split_process_order(2).split_number := 2;

            -- Split 3
            IF t_split3_impair_class(i) = 'CPP' THEN
                t_split_process_order(3).split_class := 1;
            END IF;
            IF t_split3_impair_class(i) = 'OTH' THEN
                t_split_process_order(3).split_class := 2;
            END IF;
            IF t_split3_impair_class(i) = 'CEB' THEN
                t_split_process_order(3).split_class := 3;
            END IF;
            t_split_process_order(3).split_class_code := t_split3_impair_class(i);
            t_split_process_order(3).split_loss_amount := l_split3_loss_amount;
            t_split_process_order(3).split_number := 3;

            IF (p_log_level_rec.statement_level) THEN
                fa_debug_pkg.add(l_calling_fn,'t_split_process_order', 'Populated', p_log_level_rec => p_log_level_rec);
            END IF;


            -- The actual sorting logic to determine the split processing order
            -- The sorting is done as follows:
            -- 1. Classification Type- First "CPP", followed by "Others", then "CEB"
            -- 2. Amounts (Percent)- Largest first
            -- 3. Split Number - Smallest first
            FOR j IN 1..l_number_of_splits LOOP
                FOR k IN j+1..l_number_of_splits LOOP
                    IF t_split_process_order(j).split_class > t_split_process_order(k).split_class THEN
                        l_temp_split_process_order := t_split_process_order(j);
                        t_split_process_order(j) := t_split_process_order(k);
                        t_split_process_order(k) := l_temp_split_process_order;
                    ELSE
                        IF t_split_process_order(j).split_class = t_split_process_order(k).split_class
                        AND t_split_process_order(j).split_loss_amount < t_split_process_order(k).split_loss_amount THEN
                            l_temp_split_process_order := t_split_process_order(j);
                            t_split_process_order(j) := t_split_process_order(k);
                            t_split_process_order(k) := l_temp_split_process_order;
                        ELSE
                            IF t_split_process_order(j).split_class = t_split_process_order(k).split_class
                            AND t_split_process_order(j).split_loss_amount < t_split_process_order(k).split_loss_amount
                            AND t_split_process_order(j).split_number > t_split_process_order(k).split_number THEN
                                l_temp_split_process_order := t_split_process_order(j);
                                t_split_process_order(j) := t_split_process_order(k);
                                t_split_process_order(k) := l_temp_split_process_order;
                            END IF; --t_split_process_order(j).split_number > t_split_process_order(k).split_number
                        END IF; -- End if _split_process_order(j).split_loss_amount < t_split_process_order(k).split_loss_amount
                    END IF; -- End if t_split_process_order(j).split_class > t_split_process_order(k).split_class
                END LOOP; -- End Loop k
            END LOOP; -- End Loop j


            IF (p_log_level_rec.statement_level) THEN
                fa_debug_pkg.add(l_calling_fn,'Calculation of split processing order', 'Completed', p_log_level_rec => p_log_level_rec);
            END IF;

            --------------------------------------------------------------------
            -- End of Logic B
            -- End to select the order of split processing
            --------------------------------------------------------------------



            --******************************************************************
            -- Logic C
            -- Determine the revaluation impact and update the impairment
            -- records
            --******************************************************************

            IF (p_log_level_rec.statement_level) THEN
                fa_debug_pkg.add(l_calling_fn,'t_reval_reserve(i)', t_reval_reserve(i));
            END IF;


            IF t_reval_reserve(i) = 0 THEN
                -- If the revaluation reserve is zero then calculation of the
                -- revaluation reserve impact is not required
                -- Update the interface table with the split impairment details
                IF (p_mrc_sob_type_code = 'R') THEN
                    UPDATE FA_MC_ITF_IMPAIRMENTS ITF
                    SET SPLIT1_LOSS_AMOUNT = l_split1_loss_amount
                     ,  SPLIT2_LOSS_AMOUNT = l_split2_loss_amount
                     ,  SPLIT3_LOSS_AMOUNT = l_split3_loss_amount
                     ,  CAPITAL_ADJUSTMENT = NVL(CAPITAL_ADJUSTMENT,0) + NVL(IMPAIRMENT_AMOUNT,0)
                     ,  GENERAL_FUND       = NVL(GENERAL_FUND,0) + NVL(IMPAIRMENT_AMOUNT,0)
                     ,  SPLIT1_PROCESS_ORDER = 0
                     ,  SPLIT2_PROCESS_ORDER = 0
                     ,  SPLIT3_PROCESS_ORDER = 0
                     ,  SPLIT1_REVAL_RESERVE = 0
                     ,  SPLIT2_REVAL_RESERVE = 0
                     ,  SPLIT3_REVAL_RESERVE = 0
                    WHERE  IMPAIRMENT_ID = p_impairment_id
                    AND    book_type_code = p_book_type_code
                    AND    asset_id = t_asset_id(i)
                    AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
                    and    set_of_books_id = p_set_of_books_id;
                ELSE
                    UPDATE FA_ITF_IMPAIRMENTS ITF
                    SET SPLIT1_LOSS_AMOUNT = l_split1_loss_amount
                     ,  SPLIT2_LOSS_AMOUNT = l_split2_loss_amount
                     ,  SPLIT3_LOSS_AMOUNT = l_split3_loss_amount
                     ,  CAPITAL_ADJUSTMENT = NVL(CAPITAL_ADJUSTMENT,0) + NVL(IMPAIRMENT_AMOUNT,0)
                     ,  GENERAL_FUND       = NVL(GENERAL_FUND,0) + NVL(IMPAIRMENT_AMOUNT,0)
                     ,  SPLIT1_PROCESS_ORDER = 0
                     ,  SPLIT2_PROCESS_ORDER = 0
                     ,  SPLIT3_PROCESS_ORDER = 0
                     ,  SPLIT1_REVAL_RESERVE = 0
                     ,  SPLIT2_REVAL_RESERVE = 0
                     ,  SPLIT3_REVAL_RESERVE = 0
                    WHERE  IMPAIRMENT_ID = p_impairment_id
                    AND    book_type_code = p_book_type_code
                    AND    asset_id = t_asset_id(i)
                    AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y';
                END IF;

                IF (p_log_level_rec.statement_level) THEN
                    fa_debug_pkg.add(l_calling_fn,'t_reval_reserve(i)', t_reval_reserve(i));
                    fa_debug_pkg.add(l_calling_fn,'Updated FA_ITF_IMPAIRMENTS', 'UPDATED', p_log_level_rec => p_log_level_rec);
                END IF;

            ELSE -- t_reval_reserve(i) <> 0
                IF t_reval_reserve(i) > 0 THEN
                    -- If revaluation reserve is non negative, calculate the
                    -- impact due to the revaluation reserve
                    -- This revaluation reserve must be consumed in the order
                    -- in determined in Logic B
                    FOR j IN 1..l_number_of_splits LOOP
                        IF (p_log_level_rec.statement_level) THEN
                            fa_debug_pkg.add(l_calling_fn,'j', j, p_log_level_rec => p_log_level_rec);
                        END IF;

                        IF (p_log_level_rec.statement_level) THEN
                            fa_debug_pkg.add(l_calling_fn,'split order j', j, p_log_level_rec => p_log_level_rec);
                            fa_debug_pkg.add(l_calling_fn,'before consumption t_split_process_order(j).reval_reserve'
                            , t_split_process_order(j).reval_reserve);
                            fa_debug_pkg.add(l_calling_fn,'before consumption t_reval_reserve(i)', t_reval_reserve(i));
                        END IF;

                        IF t_reval_reserve(i) > 0 THEN
                            IF t_split_process_order(j).split_loss_amount >= t_reval_reserve(i) THEN
                                t_split_process_order(j).reval_reserve := t_reval_reserve(i);
                                t_reval_reserve(i) := 0;
                            ELSE
                                t_split_process_order(j).reval_reserve := t_split_process_order(j).split_loss_amount;
                                t_reval_reserve(i) := t_reval_reserve(i) - t_split_process_order(j).split_loss_amount;
                            END IF;
                        ELSE
                            t_split_process_order(j).reval_reserve := 0;
                        END IF; -- t_reval_reserve(i) > 0

                        IF (p_log_level_rec.statement_level) THEN
                            fa_debug_pkg.add(l_calling_fn,'split order j', j, p_log_level_rec => p_log_level_rec);
                            fa_debug_pkg.add(l_calling_fn,'t_split_process_order(j).split_class_code', t_split_process_order(j).split_class_code);
                            fa_debug_pkg.add(l_calling_fn,'t_split_process_order(j).split_number', t_split_process_order(j).split_number);
                            fa_debug_pkg.add(l_calling_fn,'t_split_process_order(j).split_loss_amount', t_split_process_order(j).split_loss_amount);
                            fa_debug_pkg.add(l_calling_fn,'t_split_process_order(j).reval_reserve', t_split_process_order(j).reval_reserve);
                            fa_debug_pkg.add(l_calling_fn,'after consumption t_reval_reserve(i)', t_reval_reserve(i));
                        END IF;

                        -- Once revaluation reserve is consumed, update the
                        -- interface table with the values
                        IF t_split_process_order(j).split_number = 1 THEN
                            IF (p_mrc_sob_type_code = 'R') THEN
                                UPDATE FA_MC_ITF_IMPAIRMENTS ITF
                                SET SPLIT1_LOSS_AMOUNT = t_split_process_order(j).split_loss_amount
                                                         - DECODE(SPLIT1_IMPAIR_CLASS,'CEB',0,t_split_process_order(j).reval_reserve)
                                 ,  SPLIT1_REVAL_RESERVE = t_split_process_order(j).reval_reserve
                                 ,  SPLIT1_PROCESS_ORDER = j
                                WHERE  IMPAIRMENT_ID = p_impairment_id
                                AND    book_type_code = p_book_type_code
                                AND    asset_id = t_asset_id(i)
                                AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
                                and    set_of_books_id = p_set_of_books_id;
                            ELSE
                                UPDATE FA_ITF_IMPAIRMENTS ITF
                                SET SPLIT1_LOSS_AMOUNT = t_split_process_order(j).split_loss_amount
                                                         - DECODE(SPLIT1_IMPAIR_CLASS,'CEB',0,t_split_process_order(j).reval_reserve)
                                 ,  SPLIT1_REVAL_RESERVE = t_split_process_order(j).reval_reserve
                                 ,  SPLIT1_PROCESS_ORDER = j
                                WHERE  IMPAIRMENT_ID = p_impairment_id
                                AND    book_type_code = p_book_type_code
                                AND    asset_id = t_asset_id(i)
                                AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y';
                            END IF;
                        END IF;
                        IF t_split_process_order(j).split_number = 2 THEN
                            IF (p_mrc_sob_type_code = 'R') THEN
                                UPDATE FA_MC_ITF_IMPAIRMENTS ITF
                                SET SPLIT2_LOSS_AMOUNT = t_split_process_order(j).split_loss_amount
                                                         - DECODE(SPLIT2_IMPAIR_CLASS,'CEB',0,t_split_process_order(j).reval_reserve)
                                 ,  SPLIT2_REVAL_RESERVE = t_split_process_order(j).reval_reserve
                                 ,  SPLIT2_PROCESS_ORDER = j
                                WHERE  IMPAIRMENT_ID = p_impairment_id
                                AND    book_type_code = p_book_type_code
                                AND    asset_id = t_asset_id(i)
                                AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
                                and    set_of_books_id = p_set_of_books_id;
                            ELSE
                                UPDATE FA_ITF_IMPAIRMENTS ITF
                                SET SPLIT2_LOSS_AMOUNT = t_split_process_order(j).split_loss_amount
                                                         - DECODE(SPLIT2_IMPAIR_CLASS,'CEB',0,t_split_process_order(j).reval_reserve)
                                 ,  SPLIT2_REVAL_RESERVE = t_split_process_order(j).reval_reserve
                                 ,  SPLIT2_PROCESS_ORDER = j
                                WHERE  IMPAIRMENT_ID = p_impairment_id
                                AND    book_type_code = p_book_type_code
                                AND    asset_id = t_asset_id(i)
                                AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y';
                            END IF;
                        END IF;
                        IF t_split_process_order(j).split_number = 3 THEN
                            IF (p_mrc_sob_type_code = 'R') THEN
                                UPDATE FA_MC_ITF_IMPAIRMENTS ITF
                                SET SPLIT3_LOSS_AMOUNT = t_split_process_order(j).split_loss_amount
                                                         - DECODE(SPLIT3_IMPAIR_CLASS,'CEB',0,t_split_process_order(j).reval_reserve)
                                 ,  SPLIT3_REVAL_RESERVE = t_split_process_order(j).reval_reserve
                                 ,  SPLIT3_PROCESS_ORDER = j
                                WHERE  IMPAIRMENT_ID = p_impairment_id
                                AND    book_type_code = p_book_type_code
                                AND    asset_id = t_asset_id(i)
                                AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
                                and    set_of_books_id = p_set_of_books_id;
                            ELSE
                                UPDATE FA_ITF_IMPAIRMENTS ITF
                                SET SPLIT3_LOSS_AMOUNT = t_split_process_order(j).split_loss_amount
                                                         - DECODE(SPLIT3_IMPAIR_CLASS,'CEB',0,t_split_process_order(j).reval_reserve)
                                 ,  SPLIT3_REVAL_RESERVE = t_split_process_order(j).reval_reserve
                                 ,  SPLIT3_PROCESS_ORDER = j
                                WHERE  IMPAIRMENT_ID = p_impairment_id
                                AND    book_type_code = p_book_type_code
                                AND    asset_id = t_asset_id(i)
                                AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y';
                            END IF;
                        END IF;
                    END LOOP;

                    -- Update the interface table with the remaining
                    -- revaluation reserve left after consumption
                    IF (p_mrc_sob_type_code = 'R') THEN
                        UPDATE FA_MC_ITF_IMPAIRMENTS ITF
                        SET YTD_IMPAIRMENT    = NVL(YTD_IMPAIRMENT,0) - (IMPAIRMENT_AMOUNT-
                                                (NVL(SPLIT1_LOSS_AMOUNT,0) + NVL(SPLIT2_LOSS_AMOUNT,0) + NVL(SPLIT3_LOSS_AMOUNT,0)))
                          , IMPAIRMENT_AMOUNT = NVL(SPLIT1_LOSS_AMOUNT,0) + NVL(SPLIT2_LOSS_AMOUNT,0) + NVL(SPLIT3_LOSS_AMOUNT,0)
                          , REVAL_RESERVE_ADJ_AMOUNT = REVAL_RESERVE - t_reval_reserve(i)
                          , REVAL_RESERVE = t_reval_reserve(i)
                          , GENERAL_FUND = NVL(GENERAL_FUND,0) + NVL(SPLIT1_LOSS_AMOUNT,0) + NVL(SPLIT2_LOSS_AMOUNT,0) + NVL(SPLIT3_LOSS_AMOUNT,0)
                                         + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                          , CAPITAL_ADJUSTMENT = NVL(CAPITAL_ADJUSTMENT,0) + NVL(SPLIT1_LOSS_AMOUNT,0)
                                               + NVL(SPLIT2_LOSS_AMOUNT,0) + NVL(SPLIT3_LOSS_AMOUNT,0)
                                               - DECODE(SPLIT1_IMPAIR_CLASS,'CEB',NVL(SPLIT1_REVAL_RESERVE,0),0)
                                               - DECODE(SPLIT2_IMPAIR_CLASS,'CEB',NVL(SPLIT2_REVAL_RESERVE,0),0)
                                               - DECODE(SPLIT3_IMPAIR_CLASS,'CEB',NVL(SPLIT3_REVAL_RESERVE,0),0)
                                               + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                        WHERE  IMPAIRMENT_ID = p_impairment_id
                        AND    book_type_code = p_book_type_code
                        AND    asset_id = t_asset_id(i)
                        AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
                        and    set_of_books_id = p_set_of_books_id;
                    ELSE
                        UPDATE FA_ITF_IMPAIRMENTS ITF
                        SET YTD_IMPAIRMENT    = NVL(YTD_IMPAIRMENT,0) - (IMPAIRMENT_AMOUNT-
                                                (NVL(SPLIT1_LOSS_AMOUNT,0) + NVL(SPLIT2_LOSS_AMOUNT,0) + NVL(SPLIT3_LOSS_AMOUNT,0)))
                          , IMPAIRMENT_AMOUNT = NVL(SPLIT1_LOSS_AMOUNT,0) + NVL(SPLIT2_LOSS_AMOUNT,0) + NVL(SPLIT3_LOSS_AMOUNT,0)
                          , REVAL_RESERVE_ADJ_AMOUNT = REVAL_RESERVE - t_reval_reserve(i)
                          , REVAL_RESERVE = t_reval_reserve(i)
                          , GENERAL_FUND = NVL(GENERAL_FUND,0) + NVL(SPLIT1_LOSS_AMOUNT,0) + NVL(SPLIT2_LOSS_AMOUNT,0) + NVL(SPLIT3_LOSS_AMOUNT,0)
                                         + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                          , CAPITAL_ADJUSTMENT = NVL(CAPITAL_ADJUSTMENT,0) + NVL(SPLIT1_LOSS_AMOUNT,0)
                                               + NVL(SPLIT2_LOSS_AMOUNT,0) + NVL(SPLIT3_LOSS_AMOUNT,0)
                                               - DECODE(SPLIT1_IMPAIR_CLASS,'CEB',NVL(SPLIT1_REVAL_RESERVE,0),0)
                                               - DECODE(SPLIT2_IMPAIR_CLASS,'CEB',NVL(SPLIT2_REVAL_RESERVE,0),0)
                                               - DECODE(SPLIT3_IMPAIR_CLASS,'CEB',NVL(SPLIT3_REVAL_RESERVE,0),0)
                                               + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                        WHERE  IMPAIRMENT_ID = p_impairment_id
                        AND    book_type_code = p_book_type_code
                        AND    asset_id = t_asset_id(i)
                        AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y';
                    END IF;

                ELSE -- if reval reserve is negative
                    -- Revaluation Reserve cannot be negative for a SORP book
                    fa_debug_pkg.add(l_calling_fn,'Revaluation reserve', t_reval_reserve(i));
                    fa_debug_pkg.add(l_calling_fn,'Revaluation reserve is negative', 'True', p_log_level_rec => p_log_level_rec);
                    fa_debug_pkg.add(l_calling_fn,'Revaluation reserve cannot be negative for a SORP Book', 'Unknown error', p_log_level_rec => p_log_level_rec);
                    RETURN FALSE;
                END IF; --t_reval_reserve(i) > 0
            END IF; -- t_reval_reserve(i) = 0

            -- Execution at this stage indicates successful processing
            RETURN TRUE;

        ELSE -- Impairment is not split

            IF t_reval_reserve(i) <> 0 THEN
                IF (p_mrc_sob_type_code = 'R') THEN
                    UPDATE FA_MC_ITF_IMPAIRMENTS ITF
                    SET
                        REVAL_RESERVE            = NVL(REVAL_RESERVE,0) - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
                      , REVAL_RESERVE_ADJ_AMOUNT = least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
                      , CAPITAL_ADJUSTMENT       = NVL(CAPITAL_ADJUSTMENT,0) + NVL(IMPAIRMENT_AMOUNT,0) - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
                                                 + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                      , GENERAL_FUND             = NVL(GENERAL_FUND,0) + NVL(IMPAIRMENT_AMOUNT,0)
                                                 - DECODE(IMPAIR_CLASS, 'CEB', 0,least(REVAL_RESERVE, IMPAIRMENT_AMOUNT))
                                                 + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                      , IMPAIRMENT_AMOUNT        = NVL(IMPAIRMENT_AMOUNT,0)
                                                 - DECODE(IMPAIR_CLASS, 'CEB', 0,least(REVAL_RESERVE, IMPAIRMENT_AMOUNT))
                      , YTD_IMPAIRMENT           = NVL(YTD_IMPAIRMENT,0)
                                                 - DECODE(IMPAIR_CLASS, 'CEB', 0,least(REVAL_RESERVE, IMPAIRMENT_AMOUNT))
                      , SPLIT1_PROCESS_ORDER = -1
                      , SPLIT2_PROCESS_ORDER = -1
                      , SPLIT3_PROCESS_ORDER = -1
                    WHERE  IMPAIRMENT_ID = p_impairment_id
                    AND    book_type_code = p_book_type_code
                    AND    asset_id = t_asset_id(i)
                    AND    nvl(REVAL_RESERVE, 0) <> 0
                    AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
                    and    set_of_books_id = p_set_of_books_id;
                ELSE
                    UPDATE FA_ITF_IMPAIRMENTS ITF
                    SET
                        REVAL_RESERVE            = NVL(REVAL_RESERVE,0) - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
                      , REVAL_RESERVE_ADJ_AMOUNT = least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
                      , CAPITAL_ADJUSTMENT       = NVL(CAPITAL_ADJUSTMENT,0) + NVL(IMPAIRMENT_AMOUNT,0) - least(REVAL_RESERVE, IMPAIRMENT_AMOUNT)
                                                 + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                      , GENERAL_FUND             = NVL(GENERAL_FUND,0) + NVL(IMPAIRMENT_AMOUNT,0)
                                                 - DECODE(IMPAIR_CLASS, 'CEB', 0,least(REVAL_RESERVE, IMPAIRMENT_AMOUNT))
                                                 + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                      , IMPAIRMENT_AMOUNT        = NVL(IMPAIRMENT_AMOUNT,0)
                                                 - DECODE(IMPAIR_CLASS, 'CEB', 0,least(REVAL_RESERVE, IMPAIRMENT_AMOUNT))
                      , YTD_IMPAIRMENT           = NVL(YTD_IMPAIRMENT,0)
                                                 - DECODE(IMPAIR_CLASS, 'CEB', 0,least(REVAL_RESERVE, IMPAIRMENT_AMOUNT))
                      , SPLIT1_PROCESS_ORDER = -1
                      , SPLIT2_PROCESS_ORDER = -1
                      , SPLIT3_PROCESS_ORDER = -1
                    WHERE  IMPAIRMENT_ID = p_impairment_id
                    AND    book_type_code = p_book_type_code
                    AND    asset_id = t_asset_id(i)
                    AND    nvl(REVAL_RESERVE, 0) <> 0
                    AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y';
                END IF;
            ELSE -- If t_reval_reserve(i) = 0
                IF (p_mrc_sob_type_code = 'R') THEN
                    UPDATE FA_MC_ITF_IMPAIRMENTS ITF
                    SET    CAPITAL_ADJUSTMENT       = NVL(CAPITAL_ADJUSTMENT,0) + NVL(IMPAIRMENT_AMOUNT,0)
                                                    + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                         , GENERAL_FUND             = NVL(GENERAL_FUND,0) + NVL(IMPAIRMENT_AMOUNT,0)
                                                    + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                         , REVAL_RESERVE_ADJ_AMOUNT = 0
                         , SPLIT1_PROCESS_ORDER = -1
                         , SPLIT2_PROCESS_ORDER = -1
                         , SPLIT3_PROCESS_ORDER = -1
                    WHERE  IMPAIRMENT_ID = p_impairment_id
                    AND    book_type_code = p_book_type_code
                    AND    asset_id = t_asset_id(i)
                    AND    nvl(REVAL_RESERVE,0) = 0
                    AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y'
                    and    set_of_books_id = p_set_of_books_id;
                ELSE
                    UPDATE FA_ITF_IMPAIRMENTS ITF
                    SET    CAPITAL_ADJUSTMENT       = NVL(CAPITAL_ADJUSTMENT,0) + NVL(IMPAIRMENT_AMOUNT,0)
                                                    + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                         , GENERAL_FUND             = NVL(GENERAL_FUND,0) + NVL(IMPAIRMENT_AMOUNT,0)
                                                    + NVL(DEPRN_ADJUSTMENT_AMOUNT,0)
                         , REVAL_RESERVE_ADJ_AMOUNT = 0
                         , SPLIT1_PROCESS_ORDER = -1
                         , SPLIT2_PROCESS_ORDER = -1
                         , SPLIT3_PROCESS_ORDER = -1
                    WHERE  IMPAIRMENT_ID = p_impairment_id
                    AND    book_type_code = p_book_type_code
                    AND    asset_id = t_asset_id(i)
                    AND    nvl(REVAL_RESERVE,0) = 0
                    AND    nvl(GOODWILL_ASSET_FLAG, 'N') <> 'Y';
                END IF;
            END IF; -- If t_reval_reserve(i) = 0

            RETURN TRUE;
        END IF; -- End if t_split_impair_flag
    END LOOP;

    RETURN FALSE;

EXCEPTION
    WHEN OTHERS THEN
        fa_debug_pkg.add(l_calling_fn,'Unknown exception', 'Others', p_log_level_rec => p_log_level_rec);
        fa_debug_pkg.add(l_calling_fn,'sqlerrm', substrb(sqlerrm, 1, 200));
        RETURN FALSE;
END;



END FA_SORP_IMPAIRMENT_PVT;

/
