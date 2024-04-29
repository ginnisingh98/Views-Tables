--------------------------------------------------------
--  DDL for Package Body FA_XLA_CMP_CCID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_CMP_CCID_PKG" AS
/* $Header: faxlacib.pls 120.6.12010000.5 2009/07/19 08:41:46 glchen ship $   */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     fa_xla_cmp_ccid_pkg                                                    |
|                                                                            |
| DESCRIPTION                                                                |
|     This is a FA private package, which contains all the APIs required     |
|     for to create ccid extract for each extract type                       |
|                                                                            |
|                                                                            |
| HISTORY                                                                    |
|     25-FEB-2006 BRIDGWAY      Created                                      |
|                                                                            |
+===========================================================================*/


--+============================================+
--|                                            |
--|  PRIVATE  PROCEDURES/FUNCTIONS             |
--|                                            |
--+============================================+


C_PRIVATE_API_1   CONSTANT VARCHAR2(32000) := '

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|    Load_Generated_Ccids                                               |
|                                                                       |
+======================================================================*/

 ----------------------------------------------------
  --
  --  Account Generator Hook
  --
  ----------------------------------------------------
   PROCEDURE Load_Generated_Ccids
              (p_log_level_rec IN FA_API_TYPES.log_level_rec_type) IS

      l_mesg_count               number := 0;
      l_mesg_len                 number;
      l_mesg                     varchar2(4000);

      l_procedure_name  varchar2(80) := ''fa_xla_extract_def_pkg.load_generated_ccids'';   -- BMR make this dynamic on type

      type char_tab_type is table of varchar2(64) index by binary_integer;
      type num_tab_type  is table of number       index by binary_integer;


';

C_PRIVATE_API_DEPRN   CONSTANT VARCHAR2(32000) := '

      type deprn_rec_type is record
        (rowid                       VARCHAR2(64),
         book_type_code              VARCHAR2(30),
         distribution_id             NUMBER(15),
         distribution_ccid           NUMBER(15),
         deprn_entered_amount        NUMBER,
         bonus_entered_amount        NUMBER,
         reval_entered_amount        NUMBER,
         generated_ccid              NUMBER(15),
         generated_offset_ccid       NUMBER(15),
         bonus_generated_ccid        NUMBER(15),
         bonus_generated_offset_ccid NUMBER(15),
         reval_generated_ccid        NUMBER(15),
         reval_generated_offset_ccid NUMBER(15),
         capital_adj_generated_ccid  NUMBER(15),
         general_fund_generated_ccid NUMBER(15),
         -- DEPRN_EXPENSE_ACCOUNT_CCID  NUMBER(15),
         DEPRN_RESERVE_ACCOUNT_CCID  NUMBER(15),
         --BONUS_EXP_ACCOUNT_CCID      NUMBER(15),
         BONUS_RSV_ACCOUNT_CCID      NUMBER(15),
         REVAL_AMORT_ACCOUNT_CCID    NUMBER(15),
         REVAL_RSV_ACCOUNT_CCID      NUMBER(15),
         CAPITAL_ADJ_ACCOUNT_CCID    NUMBER(15),
         GENERAL_FUND_ACCOUNT_CCID   NUMBER(15),
         DEPRN_EXPENSE_ACCT          VARCHAR2(25),
         DEPRN_RESERVE_ACCT          VARCHAR2(25),
         BONUS_DEPRN_EXPENSE_ACCT    VARCHAR2(25),
         BONUS_RESERVE_ACCT          VARCHAR2(25),
         REVAL_AMORT_ACCT            VARCHAR2(25),
         REVAL_RESERVE_ACCT          VARCHAR2(25),
         CAPITAL_ADJ_ACCT            VARCHAR2(25),
         GENERAL_FUND_ACCT           VARCHAR2(25)
        );

      type deprn_tbl_type is table of deprn_rec_type index by binary_integer;

      l_deprn_tbl deprn_tbl_type;

      l_generated_ccid              num_tab_type;
      l_generated_offset_ccid       num_tab_type;
      l_bonus_generated_ccid        num_tab_type;
      l_bonus_generated_offset_ccid num_tab_type;
      l_reval_generated_ccid        num_tab_type;
      l_reval_generated_offset_ccid num_tab_type;
      l_capital_adj_generated_ccid  num_tab_type;
      l_general_fund_generated_ccid num_tab_type;
      l_rowid                       char_tab_type;

      l_last_book    varchar2(30) := '' '';

      cursor c_deprn is
      select /*+ leading(xg) index(xb, FA_XLA_EXT_HEADERS_B_GT_U1) index(xl, FA_XLA_EXT_LINES_B_GT_U1) */
             xl.rowid,
             xb.book_type_code,
             xl.distribution_id,
             xl.EXPENSE_ACCOUNT_CCID,
             xl.entered_amount,
             xl.bonus_entered_amount,
             xl.reval_entered_amount,
             nvl(xl.GENERATED_CCID,              da.DEPRN_EXPENSE_ACCOUNT_CCID),
             nvl(xl.GENERATED_OFFSET_CCID,       da.DEPRN_RESERVE_ACCOUNT_CCID),
             nvl(xl.BONUS_GENERATED_CCID,        da.BONUS_EXP_ACCOUNT_CCID),
             nvl(xl.BONUS_GENERATED_OFFSET_CCID, da.BONUS_RSV_ACCOUNT_CCID),
             nvl(xl.REVAL_GENERATED_CCID,        da.REVAL_AMORT_ACCOUNT_CCID),
             nvl(xl.REVAL_GENERATED_OFFSET_CCID, da.REVAL_RSV_ACCOUNT_CCID),
             da.CAPITAL_ADJ_ACCOUNT_CCID,
             da.GENERAL_FUND_ACCOUNT_CCID,
    --       xl.DEPRN_EXPENSE_ACCOUNT_CCID,
             xl.RESERVE_ACCOUNT_CCID,
    --       xl.BONUS_EXP_ACCOUNT_CCID,
             xl.BONUS_RESERVE_ACCT_CCID,
             xl.REVAL_AMORT_ACCOUNT_CCID,
             xl.REVAL_RESERVE_ACCOUNT_CCID,
             xl.CAPITAL_ADJ_ACCOUNT_CCID,
             xl.GENERAL_FUND_ACCOUNT_CCID,
             xl.deprn_expense_acct,
             xl.DEPRN_RESERVE_ACCT,
             xl.bonus_deprn_expense_acct,
             xl.BONUS_RESERVE_ACCT,
             xl.REVAL_AMORT_ACCT,
             xl.REVAL_RESERVE_ACCT,
             xl.CAPITAL_ADJ_ACCT,
             xl.GENERAL_FUND_ACCT
        from xla_events_gt            xg,
             fa_xla_ext_headers_b_gt  xb,
             fa_xla_ext_lines_b_gt    xl,
             fa_distribution_accounts da
       where xg.event_class_code = ''DEPRECIATION''
         and xb.event_id         = xg.event_id
         and xl.event_id         = xg.event_id
         and xl.distribution_id  = da.distribution_id(+)
         and xl.book_type_code   = da.book_type_code(+);


   BEGIN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||''.begin'',
                        ''Beginning of procedure'');
      END IF;

      open  c_deprn;
      fetch c_deprn bulk collect into l_deprn_tbl;
      close c_deprn;

      for i in 1..l_deprn_tbl.count loop

         if (l_last_book <> l_deprn_tbl(i).book_type_code or
             i = 1) then

            if not (fa_cache_pkg.fazcbc
                      (X_BOOK => l_deprn_tbl(i).book_type_code,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               null;

            end if;
            l_last_book := l_deprn_tbl(i).book_type_code;
         end if;


         -- call FAFBGCC if the ccid doesnt exist in distribution accounts

         if (l_deprn_tbl(i).generated_ccid is null and
             l_deprn_tbl(i).deprn_entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''DEPRN_EXPENSE_ACCT'',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).deprn_expense_acct,
                       X_account_ccid    => 0,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).generated_ccid := -1;
            end if;
         end if;

         if (l_deprn_tbl(i).generated_offset_ccid is null and
             l_deprn_tbl(i).deprn_entered_amount <> 0) then


            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''DEPRN_RESERVE_ACCT'',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).deprn_reserve_acct,
                       X_account_ccid    => l_deprn_tbl(i).deprn_reserve_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).generated_offset_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then

               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).generated_offset_ccid := -1;
            end if;
         end if;

         if (l_deprn_tbl(i).bonus_generated_ccid is null and
             l_deprn_tbl(i).bonus_entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''BONUS_DEPRN_EXPENSE_ACCT'',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).bonus_deprn_expense_acct,
                       X_account_ccid    => 0,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).bonus_generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).bonus_generated_ccid := -1;

            end if;
         end if;

         if (l_deprn_tbl(i).bonus_generated_offset_ccid is null and
             l_deprn_tbl(i).bonus_entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''BONUS_DEPRN_RESERVE_ACCT'',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).bonus_reserve_acct,
                       X_account_ccid    => l_deprn_tbl(i).bonus_rsv_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).bonus_generated_offset_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).bonus_generated_offset_ccid := -1;

            end if;
         end if;


         if (l_deprn_tbl(i).reval_generated_ccid is null and
             l_deprn_tbl(i).reval_entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''REVAL_AMORTIZATION_ACCT'',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).reval_amort_acct,
                       X_account_ccid    => l_deprn_tbl(i).reval_amort_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).reval_generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).reval_generated_ccid := -1;
            end if;
         end if;

         if (l_deprn_tbl(i).reval_generated_offset_ccid is null and
             l_deprn_tbl(i).reval_entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''REVAL_RESERVE_ACCT'',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).reval_reserve_acct,
                       X_account_ccid    => l_deprn_tbl(i).reval_rsv_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).reval_generated_offset_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).reval_generated_offset_ccid := -1;

            end if;
         end if;

         if (l_deprn_tbl(i).capital_adj_generated_ccid is null and
             l_deprn_tbl(i).deprn_entered_amount <> 0 and
             fa_xla_extract_util_pkg.G_sorp_enabled) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''CAPITAL_ADJ_ACCT'',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).capital_adj_acct,
                       X_account_ccid    => l_deprn_tbl(i).capital_adj_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).capital_adj_generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then

               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).capital_adj_generated_ccid := -1;
            end if;
         end if;

         if (l_deprn_tbl(i).general_fund_generated_ccid is null and
             l_deprn_tbl(i).deprn_entered_amount <> 0 and
             fa_xla_extract_util_pkg.G_sorp_enabled) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''GENERAL_FUND_ACCT'',
                       X_dist_ccid       => l_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_deprn_tbl(i).general_fund_acct,
                       X_account_ccid    => l_deprn_tbl(i).general_fund_account_ccid,
                       X_distribution_id => l_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_deprn_tbl(i).general_fund_generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then

               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_deprn_tbl(i).general_fund_generated_ccid := -1;
            end if;
         end if;

      end loop;

      for i in 1.. l_deprn_tbl.count loop

         l_generated_ccid(i)              := l_deprn_tbl(i).generated_ccid;
         l_generated_offset_ccid(i)       := l_deprn_tbl(i).generated_offset_ccid;
         l_bonus_generated_ccid(i)        := l_deprn_tbl(i).bonus_generated_ccid;
         l_bonus_generated_offset_ccid(i) := l_deprn_tbl(i).bonus_generated_offset_ccid;
         l_reval_generated_ccid(i)        := l_deprn_tbl(i).reval_generated_ccid;
         l_reval_generated_offset_ccid(i) := l_deprn_tbl(i).reval_generated_offset_ccid;
         l_capital_adj_generated_ccid(i)  := l_deprn_tbl(i).capital_adj_generated_ccid;
         l_general_fund_generated_ccid(i) := l_deprn_tbl(i).general_fund_generated_ccid;
         l_rowid(i)                       := l_deprn_tbl(i).rowid;

      end loop;

      forall i in 1..l_deprn_tbl.count
      update fa_xla_ext_lines_b_gt
         set generated_ccid              = l_generated_ccid(i),
             generated_offset_ccid       = l_generated_offset_ccid(i),
             bonus_generated_ccid        = l_bonus_generated_ccid(i),
             bonus_generated_offset_ccid = l_bonus_generated_offset_ccid(i),
             reval_generated_ccid        = l_reval_generated_ccid(i),
             reval_generated_offset_ccid = l_reval_generated_offset_ccid(i),
             capital_adj_generated_ccid =  l_capital_adj_generated_ccid(i),
             general_fund_generated_ccid = l_general_fund_generated_ccid(i)
       where rowid                       = l_rowid(i);

';

C_PRIVATE_API_TRX   CONSTANT VARCHAR2(32000) := '


      -- bug 5563601: Increased length of variable account_type to 50
      type adj_rec_type is record
           (rowid                       VARCHAR2(64),
            book_type_code              VARCHAR2(30),
            distribution_id             NUMBER(15),
            distribution_ccid           NUMBER(15),
            entered_amount              NUMBER,
            account_type                VARCHAR2(50),
            generated_ccid              NUMBER(15),
            account_ccid                NUMBER(15),
            account_segment             VARCHAR2(25),
            offset_account_type         VARCHAR2(25),
            generated_offset_ccid       NUMBER(15),
            offset_account_ccid         NUMBER(15),
            offset_account_segment      VARCHAR2(25),
            counter_account_type        VARCHAR2(50),   -- Bug 6962827:
            counter_generated_ccid      NUMBER(15),     -- Bug 6962827:
            counter_account_ccid        NUMBER(15),     -- Bug 6962827:
            counter_account_segment     VARCHAR2(25),   -- Bug 6962827:
            counter_generated_offset_ccid NUMBER(15),   -- Bug 6962827:
            counter_offset_account_ccid NUMBER(15),     -- Bug 6962827:
            counter_offset_account_segment VARCHAR2(25) -- Bug 6962827:
           );

      type adj_tbl_type is table of adj_rec_type index by binary_integer;

      l_adj_tbl adj_tbl_type;

      l_generated_ccid              num_tab_type;
      l_generated_offset_ccid       num_tab_type;
      l_rowid                       char_tab_type;
      l_counter_generated_ccid      num_tab_type;  -- Bug 6962827:
      l_ctr_generated_off_ccid      num_tab_type;  -- Bug 6962827:

      error_found                   exception;

      l_last_book    varchar2(30) := '' '';

      cursor c_trx is
      select /*+ leading(xg) index(xb, FA_XLA_EXT_HEADERS_B_GT_U1) index(xl, FA_XLA_EXT_LINES_B_GT_U1) */
             xl.rowid,
             xb.book_type_code,
             xl.distribution_id,
             xl.expense_account_ccid,
             xl.entered_amount,
             decode
             (adjustment_type,
              ''COST'',            ''ASSET_COST_ACCT'',
              ''CIP COST'',        ''CIP_COST_ACCT'',
              ''COST CLEARING'',   decode(xl.asset_type,
                                        ''CIP'', ''CIP_CLEARING_ACCT'',
                                                 ''ASSET_CLEARING_ACCT''),
              ''EXPENSE'',         ''DEPRN_EXPENSE_ACCT'',
              ''RESERVE'',         ''DEPRN_RESERVE_ACCT'',
              ''BONUS EXPENSE'',   ''BONUS_DEPRN_EXPENSE_ACCT'',
              ''BONUS RESERVE'',   ''BONUS_DEPRN_RESERVE_ACCT'',
              ''REVAL RESERVE'',   ''REVAL_RESERVE_ACCT'',
              ''CAPITAL ADJ'',     ''CAPITAL_ADJ_ACCT'',
              ''GENERAL FUND'',    ''GENERAL_FUND_ACCT'',
              ''IMPAIR EXPENSE'',  ''IMPAIR_EXPENSE_ACCT'',
              ''IMPAIR RESERVE'',  ''IMPAIR_RESERVE_ACCT'',
              ''LINK IMPAIR EXP'', ''IMPAIR_EXPENSE_ACCT'',
              ''DEPRN ADJUST'',    ''DEPRN_ADJUSTMENT_ACCT'',
              ''PROCEEDS CLR'',    ''PROCEEDS_OF_SALE_CLEARING_ACCT'',
              ''REMOVALCOST CLR'', ''COST_OF_REMOVAL_CLEARING_ACCT'',
              ''REMOVALCOST'',     decode(sign(gain_loss_amount),
                                        -1, ''COST_OF_REMOVAL_LOSS_ACCT'',
                                            ''COST_OF_REMOVAL_GAIN_ACCT''),
              ''PROCEEDS'',        decode(sign(gain_loss_amount),
                                        -1, ''PROCEEDS_OF_SALE_LOSS_ACCT'',
                                            ''PROCEEDS_OF_SALE_GAIN_ACCT''),
              ''REVAL RSV RET'',   decode(sign(gain_loss_amount),
                                        -1, ''REVAL_RSV_RETIRED_LOSS_ACCT'',
                                            ''REVAL_RSV_RETIRED_GAIN_ACCT''),
              ''NBV RETIRED'',     decode(asset_type,
                                        ''GROUP'', decode(sign(gain_loss_amount),
                                                        -1, ''NBV_RETIRED_LOSS_ACCT'',
                                                            ''NBV_RETIRED_GAIN_ACCT''),
                                        decode(sign(gain_loss_amount),
                                               -1, ''NBV_RETIRED_LOSS_ACCT'',
                                                   ''NBV_RETIRED_GAIN_ACCT'')),
              NULL),
             decode(xl.adjustment_type,
              ''COST'',             nvl(xl.generated_ccid, da.ASSET_COST_ACCOUNT_CCID),
              ''CIP COST'',         nvl(xl.generated_ccid, da.CIP_COST_ACCOUNT_CCID),
              ''COST CLEARING'',    decode(xl.asset_type,
                                         ''CIP'', nvl(xl.generated_ccid, da.CIP_CLEARING_ACCOUNT_CCID),
                                                  nvl(xl.generated_ccid, da.ASSET_CLEARING_ACCOUNT_CCID)),
              ''EXPENSE'',          nvl(xl.generated_ccid, da.DEPRN_EXPENSE_ACCOUNT_CCID),
              ''RESERVE'',          nvl(xl.generated_ccid, da.DEPRN_RESERVE_ACCOUNT_CCID),
              ''BONUS EXPENSE'',    nvl(xl.generated_ccid, da.BONUS_EXP_ACCOUNT_CCID),
              ''BONUS RESERVE'',    nvl(xl.generated_ccid, da.BONUS_RSV_ACCOUNT_CCID),
              ''REVAL RESERVE'',    nvl(xl.generated_ccid, da.REVAL_RSV_ACCOUNT_CCID),
              ''CAPITAL ADJ'',      nvl(xl.generated_ccid, da.CAPITAL_ADJ_ACCOUNT_CCID),
              ''GENERAL FUND'',     nvl(xl.generated_ccid, da.GENERAL_FUND_ACCOUNT_CCID),
              ''IMPAIR EXPENSE'',   nvl(xl.generated_ccid, da.IMPAIR_EXPENSE_ACCOUNT_CCID),
              ''IMPAIR RESERVE'',   nvl(xl.generated_ccid, da.IMPAIR_RESERVE_ACCOUNT_CCID),
              ''LINK IMPAIR EXP'',  nvl(xl.generated_ccid, da.IMPAIR_EXPENSE_ACCOUNT_CCID),
              ''DEPRN ADJUST'',     nvl(xl.generated_ccid, da.DEPRN_ADJ_ACCOUNT_CCID),
              ''PROCEEDS CLR'',     nvl(xl.generated_ccid, da.PROCEEDS_SALE_CLEARING_CCID),
              ''REMOVALCOST CLR'',  nvl(xl.generated_ccid, da.COST_REMOVAL_CLEARING_CCID),
              ''PROCEEDS'',         decode(sign(xl.gain_loss_amount),
                                         -1, nvl(xl.generated_ccid, da.PROCEEDS_SALE_LOSS_CCID),
                                             nvl(xl.generated_ccid, da.PROCEEDS_SALE_GAIN_CCID)),
              ''REMOVALCOST'',      decode(sign(xl.gain_loss_amount),
                                         -1, nvl(xl.generated_ccid, da.COST_REMOVAL_LOSS_CCID),
                                             nvl(xl.generated_ccid, da.COST_REMOVAL_GAIN_CCID)),
              ''REVAL RSV RET'',    decode(sign(xl.gain_loss_amount),
                                         -1, nvl(xl.generated_ccid, da.REVAL_RSV_LOSS_ACCOUNT_CCID),
                                             nvl(xl.generated_ccid, da.REVAL_RSV_GAIN_ACCOUNT_CCID)),
              ''NBV RETIRED'',      decode(sign(xl.gain_loss_amount),
                                         -1, nvl(xl.generated_ccid, da.NBV_RETIRED_LOSS_CCID),
                                             nvl(xl.generated_ccid, da.NBV_RETIRED_GAIN_CCID)),
              NULL),
             decode(xl.adjustment_type,
              ''COST'',             xl.ASSET_COST_ACCOUNT_CCID,
              ''CIP COST'',         xl.CIP_COST_ACCOUNT_CCID,
              ''COST CLEARING'',    decode(xl.asset_type,
                                         ''CIP'', xl.CIP_CLEARING_ACCOUNT_CCID,
                                                  xl.ASSET_CLEARING_ACCOUNT_CCID),
              ''RESERVE'',          xl.RESERVE_ACCOUNT_CCID,
              ''BONUS RESERVE'',    xl.BONUS_RESERVE_ACCT_CCID,
              ''REVAL RESERVE'',    xl.REVAL_RESERVE_ACCOUNT_CCID,
              ''CAPITAL ADJ'',      xl.CAPITAL_ADJ_ACCOUNT_CCID,
              ''GENERAL FUND'',     xl.GENERAL_FUND_ACCOUNT_CCID,
              ''IMPAIR EXPENSE'',   xl.IMPAIR_EXPENSE_ACCOUNT_CCID,
              ''IMPAIR RESERVE'',   xl.IMPAIR_RESERVE_ACCOUNT_CCID,
              ''LINK IMPAIR EXP'',  xl.IMPAIR_EXPENSE_ACCOUNT_CCID,
              0),
             decode(xl.adjustment_type,
              ''COST'',             xl.ASSET_COST_ACCT,
              ''CIP COST'',         xl.CIP_COST_ACCT,
              ''COST CLEARING'',    decode(xl.asset_type,
                                         ''CIP'', xl.CIP_CLEARING_ACCT,
                                                  xl.ASSET_CLEARING_ACCT),
              ''EXPENSE'',          xl.DEPRN_EXPENSE_ACCT,
              ''RESERVE'',          xl.DEPRN_RESERVE_ACCT,
              ''BONUS EXPENSE'',    xl.BONUS_DEPRN_EXPENSE_ACCT,
              ''BONUS RESERVE'',    xl.BONUS_RESERVE_ACCT,
              ''REVAL RESERVE'',    xl.REVAL_RESERVE_ACCT,
              ''CAPITAL ADJ'',      xl.CAPITAL_ADJ_ACCT,
              ''GENERAL FUND'',     xl.GENERAL_FUND_ACCT,
              ''IMPAIR EXPENSE'',   xl.IMPAIR_EXPENSE_ACCT,
              ''IMPAIR RESERVE'',   xl.IMPAIR_RESERVE_ACCT,
              ''LINK IMPAIR EXP'',  xl.IMPAIR_EXPENSE_ACCT,
              ''PROCEEDS CLR'',     xb.PROCEEDS_OF_SALE_CLEARING_ACCT,
              ''REMOVALCOST CLR'',  xb.COST_OF_REMOVAL_CLEARING_ACCT,
              ''NBV RETIRED'',      decode(sign(xl.gain_loss_amount),
                                          -1, xb.NBV_RETIRED_LOSS_ACCT,
                                              xb.NBV_RETIRED_GAIN_ACCT),
              ''PROCEEDS'',         decode(sign(xl.gain_loss_amount),
                                          -1, xb.PROCEEDS_OF_SALE_LOSS_ACCT,
                                              xb.PROCEEDS_OF_SALE_GAIN_ACCT),
              ''REMOVALCOST'',      decode(sign(xl.gain_loss_amount),
                                          -1, xb.COST_OF_REMOVAL_LOSS_ACCT,
                                              xb.COST_OF_REMOVAL_GAIN_ACCT),
              ''REVAL RSV RET'',    decode(sign(xl.gain_loss_amount),
                                          -1, xb.REVAL_RSV_RETIRED_LOSS_ACCT,
                                              xb.REVAL_RSV_RETIRED_GAIN_ACCT),
              NULL),
             decode(xl.adjustment_type,
              ''EXPENSE'',       ''DEPRN_RESERVE_ACCT'',
              ''BONUS EXPENSE'', ''BONUS_DEPRN_RESERVE_ACCT'',
              NULL),
             decode(xl.adjustment_type,
              ''EXPENSE'',       da.DEPRN_RESERVE_ACCOUNT_CCID,
              ''BONUS EXPENSE'', da.BONUS_RSV_ACCOUNT_CCID,
              NULL),
             decode(xl.adjustment_type,
              ''EXPENSE'',       xl.RESERVE_ACCOUNT_CCID,
              ''BONUS EXPENSE'', xl.BONUS_RESERVE_ACCT_CCID,
              NULL),
             decode(xl.adjustment_type,
              ''EXPENSE'',       xl.DEPRN_RESERVE_ACCT,
              ''BONUS EXPENSE'', xl.BONUS_RESERVE_ACCT,
              NULL),
             -- Bug 6962827: counter_account_type
             decode(adjustment_type,
              ''BONUS EXPENSE'',         ''DEPRN_EXPENSE_ACCT'',
              ''BONUS RESERVE'',         ''DEPRN_RESERVE_ACCT'',
              NULL),
             -- Bug 6962827: counter_generated_ccid
             decode(xl.adjustment_type,
              ''BONUS EXPENSE'', da.DEPRN_EXPENSE_ACCOUNT_CCID,
              ''BONUS RESERVE'', da.DEPRN_RESERVE_ACCOUNT_CCID,
              NULL),
              -- Bug 6962827 : counter_account_ccid
             decode(xl.adjustment_type,
              ''BONUS RESERVE'', xl.RESERVE_ACCOUNT_CCID,
              0),
              -- Bug 6962827 : counter_account_segment
             decode(xl.adjustment_type,
              ''BONUS EXPENSE'', xl.DEPRN_EXPENSE_ACCT,
              ''BONUS RESERVE'', xl.DEPRN_RESERVE_ACCT,
              NULL),
             -- Bug 6962827 : counter_generated_offset_ccid
             decode(xl.adjustment_type,
              ''BONUS EXPENSE'', da.DEPRN_RESERVE_ACCOUNT_CCID,
              NULL),
              -- Bug 6962827 : counter_offset_account_ccid
             decode(xl.adjustment_type,
              ''BONUS EXPENSE'', xl.RESERVE_ACCOUNT_CCID,
              NULL),
              -- Bug 6962827 : counter_offset_account_segment
             decode(xl.adjustment_type,
              ''BONUS EXPENSE'', xl.DEPRN_RESERVE_ACCT,
              NULL)
        from xla_events_gt            xg,
             fa_xla_ext_headers_b_gt  xb,
             fa_xla_ext_lines_b_gt    xl,
             fa_distribution_accounts da
       where xg.event_class_code     not in (''DEPRECIATION'', ''DEFERRED'')
         and xb.event_id        = xg.event_id
         and xl.event_id        = xg.event_id
         and xl.distribution_id = da.distribution_id(+)
         and xl.book_type_code  = da.book_type_code(+);


   BEGIN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||''.begin'',
                        ''Beginning of procedure'');
      END IF;


      open  c_trx;
      fetch c_trx
       bulk collect into l_adj_tbl;
      close c_trx;

      for i in 1..l_adj_tbl.count loop

         if (l_last_book <> l_adj_tbl(i).book_type_code or
             i = 1) then
            if not (fa_cache_pkg.fazcbc
                      (X_BOOK => l_adj_tbl(1).book_type_code,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               null;
            end if;
            l_last_book := l_adj_tbl(i).book_type_code;
         end if;

         -- call FAFBGCC if the ccid doesnt exist in distribution accounts

         if (l_adj_tbl(i).generated_ccid is null and
             l_adj_tbl(i).entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_adj_tbl(i).book_type_code,
                       X_fn_trx_code     => l_adj_tbl(i).account_type,
                       X_dist_ccid       => l_adj_tbl(i).distribution_ccid,
                       X_acct_segval     => l_adj_tbl(i).account_segment,
                       X_account_ccid    => l_adj_tbl(i).account_ccid,
                       X_distribution_id => l_adj_tbl(i).distribution_id,
                       X_rtn_ccid        => l_adj_tbl(i).generated_ccid,
                       P_LOG_LEVEL_REC => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_adj_tbl(i).generated_ccid := -1;
            end if;
         end if;

         if (l_adj_tbl(i).account_type in
              (''DEPRN_EXPENSE_ACCT'', ''BONUS_DEPRN_EXPENSE_ACCT'') and
             l_adj_tbl(i).generated_offset_ccid is null and
             l_adj_tbl(i).entered_amount <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_adj_tbl(i).book_type_code,
                       X_fn_trx_code     => l_adj_tbl(i).offset_account_type,
                       X_dist_ccid       => l_adj_tbl(i).distribution_ccid,
                       X_acct_segval     => l_adj_tbl(i).offset_account_segment,
                       X_account_ccid    => l_adj_tbl(i).offset_account_ccid,
                       X_distribution_id => l_adj_tbl(i).distribution_id,
                       X_rtn_ccid        => l_adj_tbl(i).generated_offset_ccid,
                       P_LOG_LEVEL_REC => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_adj_tbl(i).generated_offset_ccid := -1;
            end if;
         end if;

         -- Bug 6962827 start
         -- Populate counter_generated_ccid with the Expense acct for
         -- Bonus expense and with Reserve acct for Bonus Reserve lines.
         if (l_adj_tbl(i).account_type in (''BONUS_DEPRN_EXPENSE_ACCT'',''BONUS_DEPRN_RESERVE_ACCT'') and
             l_adj_tbl(i).counter_generated_ccid is null and
             l_adj_tbl(i).entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_adj_tbl(i).book_type_code,
                       X_fn_trx_code     => l_adj_tbl(i).counter_account_type,
                       X_dist_ccid       => l_adj_tbl(i).distribution_ccid,
                       X_acct_segval     => l_adj_tbl(i).counter_account_segment,
                       X_account_ccid    => l_adj_tbl(i).counter_account_ccid,
                       X_distribution_id => l_adj_tbl(i).distribution_id,
                       X_rtn_ccid        => l_adj_tbl(i).counter_generated_ccid,
                       P_LOG_LEVEL_REC => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_adj_tbl(i).counter_generated_ccid := -1;
            end if;

         end if;

         -- Populate counter_generated_offset_ccid with the Reserve acct
         -- for Bonus expense lines.
         if (l_adj_tbl(i).account_type = ''BONUS_DEPRN_EXPENSE_ACCT'' and
             l_adj_tbl(i).counter_generated_offset_ccid is null and
             l_adj_tbl(i).entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_adj_tbl(i).book_type_code,
                       X_fn_trx_code     => ''DEPRN_RESERVE_ACCT'',
                       X_dist_ccid       => l_adj_tbl(i).distribution_ccid,
                       X_acct_segval     => l_adj_tbl(i).counter_offset_account_segment,
                       X_account_ccid    => l_adj_tbl(i).counter_offset_account_ccid,
                       X_distribution_id => l_adj_tbl(i).distribution_id,
                       X_rtn_ccid        => l_adj_tbl(i).counter_generated_offset_ccid,
                       P_LOG_LEVEL_REC => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''FA_INS_ADJUST_PKG.fadoflx'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_adj_tbl(i).counter_generated_offset_ccid := -1;
            end if;

         end if;
         -- Bug 6962827 end

      end loop;

      for i in 1.. l_adj_tbl.count loop

         l_generated_ccid(i)              := l_adj_tbl(i).generated_ccid;
         l_generated_offset_ccid(i)       := l_adj_tbl(i).generated_offset_ccid;
         l_rowid(i)                       := l_adj_tbl(i).rowid;
         -- Bug 6962827
         l_counter_generated_ccid(i)       := l_adj_tbl(i).counter_generated_ccid;
         l_ctr_generated_off_ccid(i)       := l_adj_tbl(i).counter_generated_offset_ccid;
      end loop;

      forall i in 1..l_adj_tbl.count
      update fa_xla_ext_lines_b_gt
         set generated_ccid              = l_generated_ccid(i),
             generated_offset_ccid       = l_generated_offset_ccid(i),
             counter_generated_ccid      = l_counter_generated_ccid(i), -- Bug 6962827
             counter_generated_offset_ccid = l_ctr_generated_off_ccid(i) -- Bug 6962827
       where rowid                       = l_rowid(i);

';

C_PRIVATE_API_DEF   CONSTANT VARCHAR2(32000) := '

      type def_deprn_rec_type is record
        (rowid                           VARCHAR2(64),
         book_type_code                  VARCHAR2(30),
         distribution_id                 NUMBER(15),
         distribution_ccid               NUMBER(15),
         def_deprn_entered_amount        NUMBER,
         generated_ccid                  NUMBER(15),
         generated_offset_ccid           NUMBER(15),
         DEF_DEPRN_EXPENSE_ACCT          VARCHAR2(25),
         DEF_DEPRN_RESERVE_ACCT          VARCHAR2(25)
        );

      type def_deprn_tbl_type is table of def_deprn_rec_type index by binary_integer;

      l_def_deprn_tbl def_deprn_tbl_type;

      l_generated_ccid              num_tab_type;
      l_generated_offset_ccid       num_tab_type;
      l_rowid                       char_tab_type;

      l_last_book    varchar2(30) := '' '';

      cursor c_def_deprn is
      select /*+ leading(xg) index(xb, FA_XLA_EXT_HEADERS_B_GT_U1) index(xl, FA_XLA_EXT_LINES_B_GT_U1) */
             xl.rowid,
             xb.book_type_code,
             xl.distribution_id,
             xl.EXPENSE_ACCOUNT_CCID,
             xl.entered_amount,
             nvl(xl.generated_ccid,        da.DEFERRED_EXP_ACCOUNT_CCID),
             nvl(xl.generated_offset_ccid, da.DEFERRED_RSV_ACCOUNT_CCID),
             xb.DEFERRED_DEPRN_EXPENSE_ACCT,
             xb.DEFERRED_DEPRN_RESERVE_ACCT
        from xla_events_gt            xg,
             fa_xla_ext_headers_b_gt  xb,
             fa_xla_ext_lines_b_gt    xl,
             fa_distribution_accounts da
       where xg.event_class_code = ''DEFERRED DEPRECIATION''
         and xb.event_id         = xg.event_id
         and xl.event_id         = xg.event_id
         and xl.distribution_id  = da.distribution_id(+)
         and xl.tax_book_type_code   = da.book_type_code(+);



   BEGIN

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||''.begin'',
                        ''Beginning of procedure'');
      END IF;

      open  c_def_deprn;
      fetch c_def_deprn bulk collect into l_def_deprn_tbl;
      close c_def_deprn;

      for i in 1..l_def_deprn_tbl.count loop

         if (l_last_book <> l_def_deprn_tbl(i).book_type_code or
             i = 1) then

            if not (fa_cache_pkg.fazcbc
                      (X_BOOK => l_def_deprn_tbl(i).book_type_code,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               null;

            end if;
            l_last_book := l_def_deprn_tbl(i).book_type_code;
         end if;


         -- call FAFBGCC if the ccid doesnt exist in distribution accounts

         if (l_def_deprn_tbl(i).generated_ccid is null and
             l_def_deprn_tbl(i).def_deprn_entered_amount   <> 0) then

            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_def_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''DEFERRED_DEPRN_EXPENSE_ACCT'',
                       X_dist_ccid       => l_def_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_def_deprn_tbl(i).def_deprn_expense_acct,
                       X_account_ccid    => 0,
                       X_distribution_id => l_def_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_def_deprn_tbl(i).generated_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then
               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''fa_xla_extract_def_pkg.Load_Generated_Ccids'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_def_deprn_tbl(i).generated_ccid := -1;
            end if;
         end if;

         if (l_def_deprn_tbl(i).generated_offset_ccid is null and
             l_def_deprn_tbl(i).def_deprn_entered_amount <> 0) then


            if (not FA_GCCID_PKG.fafbgcc
                      (X_book_type_code  => l_def_deprn_tbl(i).book_type_code,
                       X_fn_trx_code     => ''DEFERRED_DEPRN_RESERVE_ACCT'',
                       X_dist_ccid       => l_def_deprn_tbl(i).distribution_ccid,
                       X_acct_segval     => l_def_deprn_tbl(i).def_deprn_reserve_acct,
                       X_account_ccid    => 0,
                       X_distribution_id => l_def_deprn_tbl(i).distribution_id,
                       X_rtn_ccid        => l_def_deprn_tbl(i).generated_offset_ccid,
                       P_LOG_LEVEL_REC   => p_log_level_rec)) then

               FA_SRVR_MSG.ADD_MESSAGE
                  (NAME       => ''FA_GET_ACCOUNT_CCID'',
                   CALLING_FN => ''fa_xla_extract_def_pkg.Load_Generated_Ccids'',
                   P_LOG_LEVEL_REC => p_log_level_rec);
               l_def_deprn_tbl(i).generated_offset_ccid := -1;
            end if;
         end if;

      end loop;

      for i in 1.. l_def_deprn_tbl.count loop

         l_generated_ccid(i)              := l_def_deprn_tbl(i).generated_ccid;
         l_generated_offset_ccid(i)       := l_def_deprn_tbl(i).generated_offset_ccid;
         l_rowid(i)                       := l_def_deprn_tbl(i).rowid;

      end loop;

      forall i in 1..l_def_deprn_tbl.count
      update fa_xla_ext_lines_b_gt
         set generated_ccid              = l_generated_ccid(i),
             generated_offset_ccid       = l_generated_offset_ccid(i)
       where rowid                       = l_rowid(i);

';


C_PRIVATE_API_3   CONSTANT VARCHAR2(32000) := '
--

      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.string(G_LEVEL_PROCEDURE,
                        G_MODULE_NAME||l_procedure_name||''.end'',
                        ''End of procedure'');
      END IF;

   EXCEPTION
      WHEN others THEN
           IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_message.set_name(''OFA'',''FA_SHARED_ORACLE_ERR'');
              fnd_message.set_token(''ORACLE_ERR'',SQLERRM);
              FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
           END IF;
           raise;

   END load_generated_ccids;

';



--
--+==========================================================================+
--|                                                                          |
--| Private global constants                                                 |
--|                                                                          |
--+==========================================================================+
--
C_CREATED_ERROR      CONSTANT BOOLEAN := FALSE;
C_CREATED            CONSTANT BOOLEAN := TRUE;
--
g_Max_line            CONSTANT NUMBER := 225;
g_chr_quote           CONSTANT VARCHAR2(10):='''';
g_chr_newline         CONSTANT VARCHAR2(10):= fa_cmp_string_pkg.g_chr_newline;

g_log_level_rec       fa_api_types.log_level_rec_type;

G_CURRENT_RUNTIME_LEVEL        NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

G_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
G_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
G_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
G_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

G_MODULE_NAME         CONSTANT VARCHAR2(50):= 'fa.plsql.fa_xla_cmp_header_pkg.';

FUNCTION GenerateCcidExtract
      (p_extract_type                 IN VARCHAR2,
       p_package_body                 OUT NOCOPY DBMS_SQL.VARCHAR2S) RETURN BOOLEAN IS

   l_array_pkg              DBMS_SQL.VARCHAR2S;
   l_BodyPkg                VARCHAR2(32000);
   l_array_body             DBMS_SQL.VARCHAR2S;
   l_procedure_name  varchar2(80) := 'GenerateLoadExtract';

BEGIN

   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      fnd_log.string(G_LEVEL_PROCEDURE,
                     G_MODULE_NAME||l_procedure_name||'.begin',
                     'Beginning of procedure');
   END IF;

   l_array_body    := fa_cmp_string_pkg.g_null_varchar2s;
   l_array_pkg     := fa_cmp_string_pkg.g_null_varchar2s;

   -- deferred does not use locking - exit returning nothing
   l_bodypkg := C_PRIVATE_API_1;

   fa_cmp_string_pkg.CreateString
      (p_package_text  => l_BodyPkg
      ,p_array_string  => l_array_pkg);

   if (p_extract_type = 'DEPRN') then

      l_bodypkg := C_PRIVATE_API_DEPRN;

   elsif (p_extract_type = 'TRX') then

      l_bodypkg := C_PRIVATE_API_TRX;

   elsif (p_extract_type = 'DEF') then

      l_bodypkg := C_PRIVATE_API_DEF;

   else
      null;  -- unkown type
   end if;

   fa_cmp_string_pkg.CreateString
     (p_package_text  => l_BodyPkg
     ,p_array_string  => l_array_body);

   l_array_pkg :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1  =>  l_array_pkg
         ,p_array_string_2  =>  l_array_body);


   l_bodypkg := C_PRIVATE_API_3;

   fa_cmp_string_pkg.CreateString
     (p_package_text  => l_BodyPkg
     ,p_array_string  => l_array_body);

   l_array_pkg :=
      fa_cmp_string_pkg.ConcatTwoStrings
         (p_array_string_1  =>  l_array_pkg
         ,p_array_string_2  =>  l_array_body);

   p_package_body := l_array_pkg;

   RETURN TRUE;

EXCEPTION
   WHEN OTHERS THEN
        IF (G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL ) THEN
           fnd_message.set_name('OFA','FA_SHARED_ORACLE_ERR');
           fnd_message.set_token('ORACLE_ERR',SQLERRM);
           FND_LOG.MESSAGE (G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_procedure_name,TRUE);
        END IF;
        RETURN FALSE;

END GenerateCcidExtract;

END fa_xla_cmp_ccid_pkg;

/
