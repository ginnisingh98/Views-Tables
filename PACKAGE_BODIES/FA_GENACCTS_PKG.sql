--------------------------------------------------------
--  DDL for Package Body FA_GENACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GENACCTS_PKG" as
/* $Header: fagendab.pls 120.22.12010000.2 2009/07/19 13:54:58 glchen ship $   */


      G_gen_expense        varchar2(1) := NULL;
      G_pregen_asset_acct  varchar2(1) := NULL;
      G_pregen_cat_acct    varchar2(1) := NULL;
      G_pregen_book_acct   varchar2(1) := NULL;
      G_FY_first_pc        number      := NULL; --added for BUG# 1339219
      G_request_id         number;

      G_success_count NUMBER := 0;
      G_failure_count NUMBER := 0;

      g_log_level_rec fa_api_types.log_level_rec_type;

      TYPE t_number  is table of number index by binary_integer;
      TYPE t_varchar is table of varchar2(150) index by binary_integer;


PROCEDURE GEN_ACCTS(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                p_request_number     IN     NUMBER,
                x_success_count         OUT NOCOPY number,
                x_failure_count         OUT NOCOPY number,
                x_return_status         OUT NOCOPY number,
                x_worker_jobs           OUT NOCOPY number) IS

   l_batch_size           number;
   l_dist_source_book     varchar2(30);
   l_calling_fn           varchar2(40) := 'FA_GENACCTS_PKG.GEN_ACCTS';

   -- book variables
   h_default_ccid         number;
   h_flex_num             number;
   h_book_class           varchar(30);
   h_nbv_gain_acct        varchar(30);
   h_nbv_loss_acct        varchar(30);
   h_pos_gain_acct        varchar(30);
   h_pos_loss_acct        varchar(30);
   h_cor_gain_acct        varchar(30);
   h_cor_loss_acct        varchar(30);
   h_cor_clearing_acct    varchar(30);
   h_pos_clearing_acct    varchar(30);
   h_deferred_exp_acct    varchar2(30);
   h_deferred_rsv_acct    varchar2(30);
   h_reval_rsv_loss_acct  varchar2(30);
   h_reval_rsv_gain_acct  varchar2(30);
   h_deprn_adj_acct       varchar2(30);
   h_allow_reval_flag     varchar2(3);
   h_allow_deprn_adjust   varchar2(3);
   h_gl_posting_allowed   varchar2(3);
   h_allow_impairment_flag varchar2(1);
   h_allow_sorp_flag varchar2(1); -- Bug 6666666 : Sorp Compliance Project

   h_result               boolean;
   h_return_ccid          number;
   h_total_requests       number;
   h_request_number       number;
   status                 boolean;
   h_submit_child         boolean := FALSE;
   msg_count              NUMBER := 0;
   msg_data               varchar2(512);
   h_req_data             varchar2(10) := NULL;

   -- new paralism
   l_unassigned_cnt       NUMBER := 0;
   l_failed_cnt           NUMBER := 0;
   l_wip_cnt              NUMBER := 0;
   l_completed_cnt        NUMBER := 0;
   l_total_cnt            NUMBER := 0;
   l_count                NUMBER := 0;
   l_start_range          NUMBER := 0;
   l_end_range            NUMBER := 0;



   -- category_account variables
   l_acct_ccid            t_number;
   l_acct_seg             t_varchar;
   l_reserve_acct         t_varchar;
   l_cost_acct            t_varchar;
   l_clearing_acct        t_varchar;
   l_expense_acct         t_varchar;
   l_cip_cost_acct        t_varchar;
   l_cip_clearing_acct    t_varchar;
   l_cost_ccid            t_number;
   l_clearing_ccid        t_number;
   l_reserve_ccid         t_number;
   l_cip_cost_ccid        t_number;
   l_cip_clearing_ccid    t_number;
   l_reval_rsv_acct       t_varchar;
   l_reval_amort_acct     t_varchar;
   l_reval_rsv_ccid       t_number;
   l_reval_amort_ccid     t_number;
   l_bonus_exp_acct       t_varchar;
   l_bonus_rsv_acct       t_varchar;
   l_bonus_rsv_ccid       t_number;
   l_impair_exp_acct      t_varchar;
   l_impair_exp_ccid      t_number;
   l_impair_rsv_acct      t_varchar;
   l_impair_rsv_ccid      t_number;
   l_capital_adj_acct     t_varchar;  -- Bug 6666666 : Sorp Compliance Project
   l_capital_adj_ccid     t_number;   -- Bug 6666666 : Sorp Compliance Project
   l_general_fund_acct    t_varchar;  -- Bug 6666666 : Sorp Compliance Project
   l_general_fund_ccid    t_number;   -- Bug 6666666 : Sorp Compliance Project

   --distribution cursor variables
   l_dist_id              t_number;
   l_asset_number         t_varchar;
   l_asset_id             t_number;
   l_asset_type           t_varchar;
   l_asset_category_id    t_number;
   l_dist_ccid            t_number;
   l_bonus_rule           t_varchar;  -- BUG# 1791317
   l_group_asset_id       t_number;
   l_tracking_method      t_varchar;

   done_exc               exception;
   error_found            exception;

 CURSOR dist (p_book_type_code     varchar2,
              p_dist_source_book   varchar2,
              p_fy_first_pc        number,
              p_pregen_asset_acct  varchar2,
              p_pregen_cat_acct    varchar2,
              p_pregen_book_acct   varchar2,
              p_book_class         varchar2,
              p_gl_posting_allowed varchar2,
              p_allow_deprn_adjust varchar2,
              p_allow_reval_flag   varchar2,
              p_allow_impairment_flag varchar2,
              p_allow_sorp_flag    varchar2, -- Bug 6666666
              p_start_range        number,
              p_end_range          number
              ) is
        SELECT  /*+ leading(dh) index(dh FA_DISTRIBUTION_HISTORY_U1) */
                dh.distribution_id,
                ad.asset_number,
                ad.asset_id,
                ad.asset_type,
                ad.asset_category_id,
                dh.code_combination_id,
                bks.bonus_rule,
                bks.group_asset_id,
                bks.tracking_method
        FROM    fa_distribution_accounts da2,
                fa_additions_b           ad,
                fa_distribution_history  dh,
                fa_books                 bks
        WHERE   dh.date_ineffective is null
        AND     dh.book_type_code      = p_dist_source_book
        AND     da2.book_type_code(+)  = p_book_type_code
        AND     da2.distribution_id(+) = dh.distribution_id
        AND     ad.asset_id            = dh.asset_id
                /* BUG# 1339219: do not select distributions for assets
                   which have been fully retired in a prior year */
        AND     bks.asset_id           = dh.asset_id
        AND     bks.book_type_code     = p_book_type_code
        AND     bks.transaction_header_id_out is null
        AND     (bks.period_counter_fully_retired is null OR
                 bks.period_counter_fully_retired >= p_FY_first_pc)
                -- end BUG# 1339219
        and     dh.distribution_id          between p_start_range and p_end_range
        AND     (((p_pregen_asset_acct = 'Y') AND
                   da2.deprn_expense_account_ccid     is NULL) OR
                 ((p_pregen_cat_acct = 'Y') AND
                  (((ad.asset_type   <> 'GROUP') AND
                    (da2.asset_cost_account_ccid       is NULL or
                     da2.asset_clearing_account_ccid   is NULL)) OR
                     --da2.deprn_expense_account_ccid is NULL OR
                   da2.deprn_reserve_account_ccid     is NULL OR
                   ((ad.asset_type = 'CIP') AND
                    (da2.cip_cost_account_ccid     is NULL OR
                     da2.cip_clearing_account_ccid is NULL)) OR
                   ((p_allow_reval_flag = 'YES' and
                     ad.asset_type     <> 'GROUP') AND
                        (da2.reval_amort_account_ccid is NULL OR
                         da2.reval_rsv_account_ccid   is NULL)) OR
                   ((bks.bonus_rule is not null ) AND
                        (da2.bonus_exp_account_ccid   is NULL OR
                         da2.bonus_rsv_account_ccid   is NULL)))) OR
                 ((p_pregen_book_acct = 'Y' and
                   ad.asset_type     <> 'GROUP') AND
                  (da2.nbv_retired_gain_ccid       is NULL OR
                   da2.nbv_retired_loss_ccid       is NULL OR
                   da2.proceeds_sale_gain_ccid     is NULL OR
                   da2.proceeds_sale_loss_ccid     is NULL OR
                   da2.cost_removal_gain_ccid      is NULL OR
                   da2.cost_removal_loss_ccid      is NULL OR
                   da2.proceeds_sale_clearing_ccid is NULL OR
                   da2.cost_removal_clearing_ccid  is NULL OR
                   ( (p_allow_sorp_flag = 'Y') AND -- Bug 6666666
                     (
                        da2.capital_adj_account_ccid is NULL OR
                        da2.general_fund_account_ccid is NULL
                     )
                   ) OR
                   ((p_allow_impairment_flag = 'Y') AND
                    (da2.impair_expense_account_ccid is NULL OR
                     da2.impair_reserve_account_ccid is NULL)) OR
                   ((p_book_class = 'TAX') AND
                    (((da2.deferred_exp_account_ccid is NULL OR
                       da2.deferred_rsv_account_ccid is NULL)) OR
                     ((p_allow_deprn_adjust = 'YES') AND
                       da2.deprn_adj_account_ccid     is NULL)))) OR
                     ((p_allow_reval_flag = 'YES') AND
                      (da2.reval_rsv_gain_account_ccid  is NULL OR
                       da2.reval_rsv_loss_account_ccid  is NULL))));

BEGIN

   G_success_count := 0;
   G_failure_count := 0;
   x_success_count := 0;
   x_failure_count := 0;
   x_worker_jobs   := 0;

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise error_found;
      end if;
   end if;
   -- Initialize server message stack and debug
   FA_DEBUG_PKG.Initialize;

   -- get book information
   if not fa_cache_pkg.fazcbc(X_book => p_book_type_code, p_log_level_rec => g_log_level_rec) then
      raise error_found;
   end if;

   l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 1000);
   l_dist_source_book := fa_cache_pkg.fazcbc_record.distribution_source_book;

   fnd_profile.get('FA_GEN_EXPENSE_ACCOUNT', G_gen_expense);
   fnd_profile.get('FA_PREGEN_ASSET_ACCOUNT', G_pregen_asset_acct);
   fnd_profile.get('FA_PREGEN_CAT_ACCOUNT', G_pregen_cat_acct);
   fnd_profile.get('FA_PREGEN_BOOK_ACCOUNT', G_pregen_book_acct);

   -- if null set accordingly
   if (G_gen_expense is null) then
      G_gen_expense := 'N';
   end if;

   if (G_pregen_asset_acct is null) then
      G_pregen_asset_acct := 'Y';
   end if;

   if (G_pregen_cat_acct is null) then
      G_pregen_cat_acct := 'Y';
   end if;

   if (G_pregen_book_acct is null) then
      G_pregen_book_acct:= 'Y';
   end if;

   /* Get the first period counter of the current Fiscal Year --BUG# 1339219 */
   h_default_ccid        := fa_cache_pkg.fazcbc_record.flexbuilder_defaults_ccid;
   h_flex_num            := fa_cache_pkg.fazcbc_record.accounting_flex_structure;
   h_book_class          := fa_cache_pkg.fazcbc_record.book_class;
   h_nbv_gain_acct       := fa_cache_pkg.fazcbc_record.nbv_retired_gain_acct;
   h_nbv_loss_acct       := fa_cache_pkg.fazcbc_record.nbv_retired_loss_acct;
   h_pos_gain_acct       := fa_cache_pkg.fazcbc_record.proceeds_of_sale_gain_acct;
   h_pos_loss_acct       := fa_cache_pkg.fazcbc_record.proceeds_of_sale_loss_acct;
   h_pos_clearing_acct   := fa_cache_pkg.fazcbc_record.proceeds_of_sale_clearing_acct;
   h_cor_gain_acct       := fa_cache_pkg.fazcbc_record.cost_of_removal_gain_acct;
   h_cor_loss_acct       := fa_cache_pkg.fazcbc_record.cost_of_removal_loss_acct;
   h_cor_clearing_acct   := fa_cache_pkg.fazcbc_record.cost_of_removal_clearing_acct;
   h_reval_rsv_gain_acct := fa_cache_pkg.fazcbc_record.reval_rsv_retired_gain_acct;
   h_reval_rsv_loss_acct := fa_cache_pkg.fazcbc_record.reval_rsv_retired_loss_acct;
   h_deferred_exp_acct   := fa_cache_pkg.fazcbc_record.deferred_deprn_expense_acct;
   h_deferred_rsv_acct   := fa_cache_pkg.fazcbc_record.deferred_deprn_reserve_acct;
   h_deprn_adj_acct      := fa_cache_pkg.fazcbc_record.deprn_adjustment_acct;
   h_allow_reval_flag    := fa_cache_pkg.fazcbc_record.allow_reval_flag;
   h_allow_deprn_adjust  := fa_cache_pkg.fazcbc_record.allow_deprn_adjustments;
   h_gl_posting_allowed  := fa_cache_pkg.fazcbc_record.gl_posting_allowed_flag;
   h_allow_impairment_flag := nvl(fa_cache_pkg.fazcbc_record.allow_impairment_flag, 'N');
   h_allow_sorp_flag := nvl(fa_cache_pkg.fazcbc_record.sorp_enabled_flag, 'N'); -- Bug 6666666

   if g_log_level_rec.statement_level then
       fa_debug_pkg.add(l_calling_fn,'Sorp Enabled Flag',h_allow_sorp_flag, p_log_level_rec => g_log_level_rec);
   end if;

   select dp.period_counter
     into G_FY_first_pc
     from fa_deprn_periods dp
    where dp.book_type_code = p_book_type_code
      and dp.fiscal_year    = fa_cache_pkg.fazcbc_record.current_fiscal_year
      and dp.period_num     =
          (select min(period_num)
             from fa_deprn_periods dp2
            where dp2.book_type_code = p_book_type_code
              and dp2.fiscal_year    = fa_cache_pkg.fazcbc_record.current_fiscal_year);

   if not fa_cache_pkg.fazcdp
            (x_book_type_code => p_book_type_code,
             x_period_counter => null,
             x_effective_date => null, p_log_level_rec => g_log_level_rec) then
     raise error_found;
   end if;

   G_validation_date := fa_cache_pkg.fazcdp_record.calendar_period_close_date;

   -- ------------------------------------------
   -- Loop thru job list
   -- -----------------------------------------

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'looping through: ', 'job list', p_log_level_rec => g_log_level_rec);
   end if;



   SELECT NVL(sum(decode(status,'UNASSIGNED', 1, 0)),0),
          NVL(sum(decode(status,'FAILED', 1, 0)),0),
          NVL(sum(decode(status,'IN PROCESS', 1, 0)),0),
          NVL(sum(decode(status,'COMPLETED',1 , 0)),0),
          count(*)
   INTO   l_unassigned_cnt,
          l_failed_cnt,
          l_wip_cnt,
          l_completed_cnt,
          l_total_cnt
   FROM   FA_WORKER_JOBS
   WHERE  request_id = p_parent_request_id;

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'Job status - Unassigned: ', l_unassigned_cnt, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'Job status - In Process: ', l_wip_cnt, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'Job status - Completed: ',  l_completed_cnt, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'Job status - Failed: ',     l_failed_cnt, p_log_level_rec => g_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, 'Job status - Total: ',      l_total_cnt, p_log_level_rec => g_log_level_rec);
   end if;

   IF (l_failed_cnt > 0) THEN
      if g_log_level_rec.statement_level then
        fa_debug_pkg.add(l_calling_fn, 'Another worker has errored out: ', 'Stop processing', p_log_level_rec => g_log_level_rec);
      end if;
      raise error_found;  -- probably not
   ELSIF (l_unassigned_cnt = 0) THEN
      if g_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'No more jobs left', 'Terminating.', p_log_level_rec => g_log_level_rec);
      end if;
      raise done_exc;
   ELSIF (l_completed_cnt = l_total_cnt) THEN
      if g_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'All jobs completed, no more jobs. ', 'Terminating', p_log_level_rec => g_log_level_rec);
      end if;
      raise done_exc;
   ELSIF (l_unassigned_cnt > 0) THEN
      UPDATE FA_WORKER_JOBS
      SET    status = 'IN PROCESS',
             worker_num = p_request_number
      WHERE  status = 'UNASSIGNED'
      AND    request_id = p_parent_request_id
      AND    rownum < 2;

      l_count := sql%rowcount;

      if g_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'Taking job from job queue',  l_count, p_log_level_rec => g_log_level_rec);
      end if;
      x_worker_jobs := l_count;
      COMMIT;
   END IF;

   -- -----------------------------------
   -- There could be rare situations where
   -- between Section 30 and Section 50
   -- the unassigned job gets taken by
   -- another worker.  So, if unassigned
   -- job no longer exist.  Do nothing.
   -- -----------------------------------
   IF (l_count > 0) THEN

      if g_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'entering', 'main logic', p_log_level_rec => g_log_level_rec);
      end if;

      DECLARE
      BEGIN

         if g_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'selecting', 'ranges', p_log_level_rec => g_log_level_rec);
         end if;

         SELECT start_range,
                end_range
           INTO l_start_range,
                l_end_range
           FROM FA_WORKER_JOBS
          WHERE request_id = p_parent_request_id
            AND worker_num = p_request_number
            AND  status = 'IN PROCESS';

         if g_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'opening cursor', 'dist', p_log_level_rec => g_log_level_rec);
         end if;

         OPEN dist
             (p_book_type_code     => p_book_type_code,
              p_dist_source_book   => fa_cache_pkg.fazcbc_record.distribution_source_book,
              p_fy_first_pc        => G_fy_first_pc,
              p_pregen_asset_acct  => G_pregen_asset_acct,
              p_pregen_cat_acct    => G_pregen_cat_acct,
              p_pregen_book_acct   => G_pregen_book_acct,
              p_book_class         => h_book_class,
              p_gl_posting_allowed => h_gl_posting_allowed,
              p_allow_deprn_adjust => h_allow_deprn_adjust,
              p_allow_reval_flag   => h_allow_reval_flag,
              p_allow_impairment_flag => h_allow_impairment_flag,
              p_allow_sorp_flag    => h_allow_sorp_flag, -- Bug 6666666
              p_start_range        => l_start_range,
              p_end_range          => l_end_range);

         if g_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'fecthing cursor', 'dist', p_log_level_rec => g_log_level_rec);
         end if;

         FETCH dist bulk collect
          into l_dist_id,
               l_asset_number,
               l_asset_id,
               l_asset_type,
               l_asset_category_id,
               l_dist_ccid,
               l_bonus_rule,
               l_group_asset_id,
               l_tracking_method;

         if g_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'closing cursor', 'dist', p_log_level_rec => g_log_level_rec);
         end if;

         close dist;
/*
         if (l_dist_id.count = 0) then
            raise done_exc;
         end if;
*/

         -- load the category values into the struct
         if (g_pregen_cat_acct   = 'Y' or
             g_pregen_asset_acct = 'Y') then

            if g_log_level_rec.statement_level then
               fa_debug_pkg.add(l_calling_fn, 'processing ', 'cat and asset', p_log_level_rec => g_log_level_rec);
            end if;

            for i in 1..l_dist_id.count loop

               if not (fa_cache_pkg.fazccb(X_book   => p_book_type_code,
                                           X_cat_id => l_asset_category_id(i),
                                           p_log_level_rec => g_log_level_rec)) then
                  raise error_found;
               end if;

               l_cost_acct(i)         := fa_cache_pkg.fazccb_record.asset_cost_acct;
               l_clearing_acct(i)     := fa_cache_pkg.fazccb_record.asset_clearing_acct;
               l_cost_ccid(i)         := fa_cache_pkg.fazccb_record.asset_cost_account_ccid;
               l_clearing_ccid(i)     := fa_cache_pkg.fazccb_record.asset_clearing_account_ccid;
               l_reserve_acct(i)      := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
               l_reserve_ccid(i)      := fa_cache_pkg.fazccb_record.reserve_account_ccid;
               l_expense_acct(i)      := fa_cache_pkg.fazccb_record.deprn_expense_acct;
               l_cip_cost_acct(i)     := fa_cache_pkg.fazccb_record.cip_cost_acct;
               l_cip_clearing_acct(i) := fa_cache_pkg.fazccb_record.cip_clearing_acct;
               l_cip_cost_ccid(i)     := fa_cache_pkg.fazccb_record.wip_cost_account_ccid;
               l_cip_clearing_ccid(i) := fa_cache_pkg.fazccb_record.wip_clearing_account_ccid;
               l_reval_amort_acct(i)  := fa_cache_pkg.fazccb_record.reval_amortization_acct;
               l_reval_amort_ccid(i)  := fa_cache_pkg.fazccb_record.reval_amort_account_ccid;
               l_reval_rsv_acct(i)    := fa_cache_pkg.fazccb_record.reval_reserve_acct;
               l_reval_rsv_ccid(i)    := fa_cache_pkg.fazccb_record.reval_reserve_account_ccid;
               l_bonus_exp_acct(i)    := fa_cache_pkg.fazccb_record.bonus_deprn_expense_acct;
               l_bonus_rsv_acct(i)    := fa_cache_pkg.fazccb_record.bonus_deprn_reserve_acct;
               l_bonus_rsv_ccid(i)    := fa_cache_pkg.fazccb_record.bonus_reserve_acct_ccid;
               l_impair_exp_acct(i)   := fa_cache_pkg.fazccb_record.impair_expense_acct;
               l_impair_exp_ccid(i)   := fa_cache_pkg.fazccb_record.impair_expense_account_ccid;
               l_impair_rsv_acct(i)   := fa_cache_pkg.fazccb_record.impair_reserve_acct;
               l_impair_rsv_ccid(i)   := fa_cache_pkg.fazccb_record.impair_reserve_account_ccid;
               -- Bug 6666666 : Start of SORP Code
               l_capital_adj_acct(i)  := fa_cache_pkg.fazccb_record.capital_adj_acct;
               l_capital_adj_ccid(i)  := fa_cache_pkg.fazccb_record.capital_adj_account_ccid;
               l_general_fund_acct(i) := fa_cache_pkg.fazccb_record.general_fund_acct;
               l_general_fund_ccid(i) := fa_cache_pkg.fazccb_record.general_fund_account_ccid;
               -- Bug 6666666 : End of SORP Code
            end loop;

         else

            if g_log_level_rec.statement_level then
               fa_debug_pkg.add(l_calling_fn, 'skipping ', 'cat and asset', p_log_level_rec => g_log_level_rec);
            end if;

            -- BUG# 3280298
            -- need to load the table values here with null if we're not
            -- generating the category accounts to avoid 1403

            for i in 1..l_dist_id.count loop

               l_cost_acct(i)         := null;
               l_clearing_acct(i)     := null;
               l_cost_ccid(i)         := null;
               l_clearing_ccid(i)     := null;
               l_reserve_acct(i)      := null;
               l_reserve_ccid(i)      := null;
               l_expense_acct(i)      := null;
               l_cip_cost_acct(i)     := null;
               l_cip_clearing_acct(i) := null;
               l_cip_cost_ccid(i)     := null;
               l_cip_clearing_ccid(i) := null;
               l_reval_amort_acct(i)  := null;
               l_reval_amort_ccid(i)  := null;
               l_reval_rsv_acct(i)    := null;
               l_reval_rsv_ccid(i)    := null;
               l_bonus_exp_acct(i)    := null;
               l_bonus_rsv_acct(i)    := null;
               l_bonus_rsv_ccid(i)    := null;
               l_impair_exp_acct(i)   := null;
               l_impair_exp_ccid(i)   := null;
               l_impair_rsv_acct(i)   := null;
               l_impair_rsv_ccid(i)   := null;
               -- Bug 6666666 : Start of SORP Code
               l_capital_adj_acct(i)  := null;
               l_capital_adj_ccid(i)  := null;
               l_general_fund_acct(i) := null;
               l_general_fund_ccid(i) := null;
               -- Bug 6666666 : End of SORP Code

            end loop;
         end if;

         if g_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'looping and calling', 'GEN_CCID', p_log_level_rec => g_log_level_rec);
         end if;

         for i in 1..l_dist_id.count loop

             -- clear the debug stack for each line
             -- FA_DEBUG_PKG.Initialize;
             -- reset the message level to prevent bogus errors
             FA_SRVR_MSG.Set_Message_Level(message_level => 10, p_log_level_rec => g_log_level_rec);

             GEN_CCID(
                     X_book_type_code      => p_book_type_code,
                     X_flex_num            => h_flex_num,
                     X_default_ccid        => h_default_ccid,
                     X_book_class          => h_book_class,
                     X_nbv_gain_acct       => h_nbv_gain_acct,
                     X_nbv_loss_acct       => h_nbv_loss_acct,
                     X_pos_gain_acct       => h_pos_gain_acct,
                     X_pos_loss_acct       => h_pos_loss_acct,
                     X_cor_gain_acct       => h_cor_gain_acct,
                     X_cor_loss_acct       => h_cor_loss_acct,
                     X_cor_clearing_acct   => h_cor_clearing_acct,
                     X_pos_clearing_acct   => h_pos_clearing_acct,
                     X_reval_rsv_gain_acct => h_reval_rsv_gain_acct,
                     X_reval_rsv_loss_acct => h_reval_rsv_loss_acct,
                     X_deferred_exp_acct   => h_deferred_exp_acct,
                     X_deferred_rsv_acct   => h_deferred_rsv_acct,
                     X_deprn_adj_acct      => h_deprn_adj_acct,
                     X_allow_reval_flag    => h_allow_reval_flag,
                     X_allow_deprn_adjust  => h_allow_deprn_adjust,
                     X_allow_impairment_flag => h_allow_impairment_flag,
                     X_allow_sorp_flag     => h_allow_sorp_flag, -- Bug 6666666
                     X_gl_posting_allowed  => h_gl_posting_allowed,
                     X_asset_number        => l_asset_number(i),
                     X_asset_id            => l_asset_id(i),
                     X_dist_ccid           => l_dist_ccid(i),
                     X_reserve_acct        => l_reserve_acct(i),
                     X_cost_acct           => l_cost_acct(i),
                     X_clearing_acct       => l_clearing_acct(i),
                     X_expense_acct        => l_expense_acct(i),
                     X_cip_cost_acct       => l_cip_cost_acct(i),
                     X_cip_clearing_acct   => l_cip_clearing_acct(i),
                     X_cost_ccid           => l_cost_ccid(i),
                     X_clearing_ccid       => l_clearing_ccid(i),
                     X_reserve_ccid        => l_reserve_ccid(i),
                     X_distribution_id     => l_dist_id(i),
                     X_cip_cost_ccid       => l_cip_cost_ccid(i),
                     X_cip_clearing_ccid   => l_cip_clearing_ccid(i),
                     X_asset_type          => l_asset_type(i),
                     X_reval_amort_acct    => l_reval_amort_acct(i),
                     X_reval_amort_ccid    => l_reval_amort_ccid(i),
                     X_reval_rsv_acct      => l_reval_rsv_acct(i),
                     X_reval_rsv_ccid      => l_reval_rsv_ccid(i),
                     X_bonus_exp_acct      => l_bonus_exp_acct(i),
                     X_bonus_rsv_acct      => l_bonus_rsv_acct(i),
                     X_bonus_rsv_ccid      => l_bonus_rsv_ccid(i),
                     X_bonus_rule          => l_bonus_rule(i),   -- BUG# 1791317
                     X_impair_exp_acct     => l_impair_exp_acct(i),
                     X_impair_exp_ccid     => l_impair_exp_ccid(i),
                     X_impair_rsv_acct     => l_impair_rsv_acct(i),
                     X_impair_rsv_ccid     => l_impair_rsv_ccid(i),
                     X_group_asset_id      => l_group_asset_id(i),
                     X_capital_adj_acct    => l_capital_adj_acct(i), -- Bug 6666666
                     X_capital_adj_ccid    => l_capital_adj_ccid(i), -- Bug 6666666
                     X_general_fund_acct   => l_general_fund_acct(i), -- Bug 6666666
                     X_general_fund_ccid   => l_general_fund_ccid(i), -- Bug 6666666
                     X_tracking_method     => l_tracking_method(i));

         END LOOP; -- bulk update loop

         if g_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'updating', 'worker jobs', p_log_level_rec => g_log_level_rec);
         end if;

         UPDATE FA_WORKER_JOBS
            SET status     = 'COMPLETED'
          WHERE request_id = p_parent_request_id
            AND worker_num = p_request_number
            AND status     = 'IN PROCESS';

         COMMIT;

         --   Handle any exception that occured during
         --   your child process

      EXCEPTION
         WHEN OTHERS THEN

              FA_SRVR_MSG.ADD_SQL_ERROR(
                 CALLING_FN => 'FA_GENACCTS_PKG.gen_accts',  p_log_level_rec => g_log_level_rec);

              UPDATE FA_WORKER_JOBS
                 SET status     = 'FAILED'
               WHERE request_id = p_parent_request_id
                 AND worker_num = p_request_number
                 AND status     = 'IN PROCESS';

              COMMIT;
              Raise error_found;

      END;  -- block

   END IF; /* IF (l_count> 0) */


   -- using these as dummys - leave as zero when we've done nothing
   x_success_count := G_success_count;
   x_failure_count := G_failure_count;

   if (g_log_level_rec.statement_level) then
       fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
   end if;

   x_return_status := 0;

EXCEPTION
   WHEN done_exc then
        x_success_count := G_success_count;
        x_failure_count := G_failure_count;

        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;

        x_return_status := 0;

   WHEN error_found then
        x_success_count := G_success_count;
        x_failure_count := G_failure_count;
        fa_srvr_msg.add_message(calling_fn => 'fa_genaccts_pkg.gen_accts',  p_log_level_rec => g_log_level_rec);
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;
        x_return_status := 2;

   WHEN OTHERS THEN
        x_success_count := G_success_count;
        x_failure_count := G_failure_count;
        FA_SRVR_MSG.ADD_SQL_ERROR(
           CALLING_FN => 'FA_GENACCTS_PKG.gen_accts',  p_log_level_rec => g_log_level_rec);
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;
        x_return_status := 2;

END GEN_ACCTS;

-----------------------------------------------------------------------

PROCEDURE GEN_CCID (
          X_book_type_code        in    varchar2,
          X_flex_num              in    number,
          X_dist_ccid             in    number,
          X_asset_number          in    varchar2,
          X_asset_id              in    number,
          X_reserve_acct          in    varchar2,
          X_cost_acct             in    varchar2,
          X_clearing_acct         in    varchar2,
          X_expense_acct          in    varchar2,
          X_cip_cost_acct         in    varchar2,
          X_cip_clearing_acct     in    varchar2,
          X_default_ccid          in    number,
          X_cost_ccid             in    number,
          X_clearing_ccid         in    number,
          X_reserve_ccid          in    number,
          X_distribution_id       in    number,
          X_cip_cost_ccid         in    number,
          X_cip_clearing_ccid     in    number,
          X_asset_type            in    varchar2,
          X_book_class            in    varchar2,
          X_nbv_gain_acct         in    varchar2,
          X_nbv_loss_acct         in    varchar2,
          X_pos_gain_acct         in    varchar2,
          X_pos_loss_acct         in    varchar2,
          X_cor_gain_acct         in    varchar2,
          X_cor_loss_acct         in    varchar2,
          X_cor_clearing_acct     in    varchar2,
          X_pos_clearing_acct     in    varchar2,
          X_reval_rsv_gain_acct   in    varchar2,
          X_reval_rsv_loss_acct   in    varchar2,
          X_deferred_exp_acct     in    varchar2,
          X_deferred_rsv_acct     in    varchar2,
          X_deprn_adj_acct        in    varchar2,
          X_reval_amort_acct      in    varchar2,
          X_reval_amort_ccid      in    number,
          X_reval_rsv_acct        in    varchar2,
          X_reval_rsv_ccid        in    number,
          X_bonus_exp_acct        in    varchar2,
          X_bonus_rsv_acct        in    varchar2,
          X_bonus_rsv_ccid        in    number,
          X_allow_reval_flag      in    varchar2,
          X_allow_deprn_adjust    in    varchar2,
          X_allow_impairment_flag in    varchar2,
          X_allow_sorp_flag       in    varchar2, -- Bug 6666666
          X_gl_posting_allowed    in    varchar2,
          X_bonus_rule            in    varchar2,
          X_impair_exp_acct       in    varchar2,
          X_impair_exp_ccid       in    number,
          X_impair_rsv_acct       in    varchar2,
          X_impair_rsv_ccid       in    number,
          X_capital_adj_acct      in    varchar2, -- Bug 6666666
          X_capital_adj_ccid      in    number,   -- Bug 6666666
          X_general_fund_acct     in    varchar2, -- Bug 6666666
          X_general_fund_ccid     in    number,   -- Bug 6666666
          X_group_asset_id        in    number,
          X_tracking_method       in    varchar2) IS

   result                 boolean;
   h_count                number;
   h_return_ccid          number;
   h_acct_ccid            number;
   h_acct_seg             varchar2(30);
   h_flex_account_type    varchar2(30);

   h_cost_acct_ccid       number := NULL;
   h_clearing_acct_ccid   number := NULL;
   h_reserve_acct_ccid    number := NULL;
   h_expense_acct_ccid    number := NULL;
   h_cip_cost_ccid        number := NULL;
   h_cip_clearing_ccid    number := NULL;
   h_nbv_gain_ccid        number := NULL;
   h_nbv_loss_ccid        number := NULL;
   h_pos_gain_ccid        number := NULL;
   h_pos_loss_ccid        number := NULL;
   h_cor_gain_ccid        number := NULL;
   h_cor_loss_ccid        number := NULL;
   h_cor_clearing_ccid    number := NULL;
   h_pos_clearing_ccid    number := NULL;

   h_deferred_exp_ccid    number := NULL;
   h_deferred_rsv_ccid    number := NULL;
   h_reval_rsv_loss_ccid  number := NULL;
   h_reval_rsv_gain_ccid  number := NULL;
   h_deprn_adj_ccid       number := NULL;
   h_reval_rsv_ccid       number := NULL;
   h_reval_amort_ccid     number := NULL;
   h_bonus_exp_ccid       number := NULL;
   h_bonus_rsv_ccid       number := NULL;
   h_impair_exp_ccid      number := NULL;
   h_impair_rsv_ccid      number := NULL;
   h_capital_adj_ccid     number := NULL;  -- Bug 6666666
   h_general_fund_ccid    number := NULL;  -- Bug 6666666

   found                  boolean := FALSE;

   h_user_id              number;
   h_login_id             number;

   CURSOR get_ccids IS
     SELECT ASSET_COST_ACCOUNT_CCID,
            ASSET_CLEARING_ACCOUNT_CCID,
            DEPRN_EXPENSE_ACCOUNT_CCID,
            DEPRN_RESERVE_ACCOUNT_CCID,
            CIP_COST_ACCOUNT_CCID,
            CIP_CLEARING_ACCOUNT_CCID,
            NBV_RETIRED_GAIN_CCID,
            NBV_RETIRED_LOSS_CCID,
            PROCEEDS_SALE_GAIN_CCID,
            PROCEEDS_SALE_LOSS_CCID,
            COST_REMOVAL_GAIN_CCID,
            COST_REMOVAL_LOSS_CCID,
            PROCEEDS_SALE_CLEARING_CCID,
            COST_REMOVAL_CLEARING_CCID,
            reval_rsv_gain_account_ccid,
            reval_rsv_loss_account_ccid,
            deferred_exp_account_ccid,
            deferred_rsv_account_ccid,
            deprn_adj_account_ccid,
            reval_amort_account_ccid,
            reval_rsv_account_ccid,
            bonus_exp_account_ccid,
            bonus_rsv_account_ccid,
            impair_expense_account_ccid,
            impair_reserve_account_ccid,
            capital_adj_account_ccid,   -- Bug 6666666
            general_fund_account_ccid   -- Bug 6666666
       FROM FA_DISTRIBUTION_ACCOUNTS
      WHERE BOOK_TYPE_CODE  = X_book_type_code
        AND DISTRIBUTION_ID = X_distribution_id;

BEGIN

      FA_SRVR_MSG.ADD_MESSAGE
              (CALLING_FN => NULL,
               NAME       => 'FA_FAGDA_DISTRIBUTION_ID',
               TOKEN1     => 'DISTRIBUTION_ID',
               VALUE1     => X_distribution_id, p_log_level_rec => g_log_level_rec);

      open get_ccids;
      fetch get_ccids
       into h_cost_acct_ccid,
            h_clearing_acct_ccid,
            h_expense_acct_ccid,
            h_reserve_acct_ccid,
            h_cip_cost_ccid,
            h_cip_clearing_ccid,
            h_nbv_gain_ccid,
            h_nbv_loss_ccid,
            h_pos_gain_ccid,
            h_pos_loss_ccid,
            h_cor_gain_ccid,
            h_cor_loss_ccid,
            h_pos_clearing_ccid,
            h_cor_clearing_ccid,
            h_reval_rsv_loss_ccid,
            h_reval_rsv_gain_ccid,
            h_deferred_exp_ccid,
            h_deferred_rsv_ccid,
            h_deprn_adj_ccid,
            h_reval_amort_ccid,
            h_reval_rsv_ccid,
            h_bonus_exp_ccid,
            h_bonus_rsv_ccid,
            h_impair_exp_ccid,
            h_impair_rsv_ccid,
            h_capital_adj_ccid,
            h_general_fund_ccid;

      if (get_ccids%NOTFOUND) then
         found := FALSE;
      else
         found := TRUE;
      end if;

      if (G_pregen_asset_acct = 'Y') then
         if (((found and h_expense_acct_ccid is null) OR (not found)) AND
             ((X_group_asset_id  is null) or
              (X_group_asset_id  is not null and
               X_tracking_method is not null))) then
            /* Generate DEPRN_EXPENSE_ACCT */
            if (G_gen_expense = 'Y') then
               h_acct_seg          := X_expense_acct;
               h_acct_ccid         := X_dist_ccid;
               h_flex_account_type := 'DEPRN_EXP';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                   h_expense_acct_ccid := h_return_ccid;
                   G_success_count := G_success_count + 1;
               else
                   Add_Messages(
                      X_asset_number,
                      X_asset_id,
                      h_acct_ccid,
                      h_acct_seg,
                      h_flex_account_type,
                      X_book_type_code,
                      X_default_ccid,
                      X_dist_ccid);
               end if;
            else
               h_expense_acct_ccid := X_dist_ccid;
            end if;
         end if;
      end if;

      if (G_pregen_cat_acct = 'Y') then
         if (X_asset_type <> 'GROUP') then -- only prevents cost and clearing
            if ((found and h_cost_acct_ccid is null) OR (not found)) then
               /* Generate COST Account  */
               h_acct_seg          := X_cost_acct;
               h_acct_ccid         := X_cost_ccid;
               h_flex_account_type := 'ASSET_COST';
               result := FAFLEX_PKG_WF.START_PROCESS(
                    X_flex_account_type => h_flex_account_type,
                    X_book_type_code    => X_book_type_code,
                    X_flex_num          => X_flex_num,
                    X_dist_ccid         => X_dist_ccid,
                    X_acct_segval       => h_acct_seg,
                    X_default_ccid      => X_default_ccid,
                    X_account_ccid      => h_acct_ccid,
                    X_distribution_id   => X_distribution_id,
                    X_validation_date   => G_validation_date,
                    X_return_ccid       => h_return_ccid,
                    p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_cost_acct_ccid := h_return_ccid;
               else
                  Add_Messages(
                     X_asset_number,
                     X_asset_id,
                     h_acct_ccid,
                     h_acct_seg,
                     h_flex_account_type,
                     X_book_type_code,
                     X_default_ccid,
                     X_dist_ccid);
               end if;
            end if;

            if ((found and h_clearing_acct_ccid is null) OR (not found)) then
               /* Generate Cost Clearing account */
               h_acct_seg          := X_clearing_acct;
               h_acct_ccid         := X_clearing_ccid;
               h_flex_account_type := 'ASSET_CLEARING';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_clearing_acct_ccid := h_return_ccid;
               else
                  Add_Messages(
                     X_asset_number,
                     X_asset_id,
                     h_acct_ccid,
                     h_acct_seg,
                     h_flex_account_type,
                     X_book_type_code,
                     X_default_ccid,
                     X_dist_ccid);
               end if;
            end if;
         end if; -- group

         if ((found and h_reserve_acct_ccid is null) OR (not found)) then
            /* Generate DEPRN_RESERVE_ACCT */
            h_acct_seg := X_reserve_acct;
            h_acct_ccid := X_reserve_ccid;
            h_flex_account_type := 'DEPRN_RSV';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_reserve_acct_ccid := h_return_ccid;
            else
               Add_Messages(
                   X_asset_number,
                   X_asset_id,
                   h_acct_ccid,
                   h_acct_seg,
                   h_flex_account_type,
                   X_book_type_code,
                   X_default_ccid,
                   X_dist_ccid);
            end if;
         end if;

         if (X_asset_type = 'CIP') then

            if ((found and h_cip_cost_ccid is null) OR (not found)) then
            /* Generate CIP COST account */
               h_acct_seg          := X_cip_cost_acct;
               h_acct_ccid         := X_cip_cost_ccid;
               h_flex_account_type := 'CIP_COST';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_cip_cost_ccid := h_return_ccid;
               else
                  Add_Messages(
                      X_asset_number,
                      X_asset_id,
                      h_acct_ccid,
                      h_acct_seg,
                      h_flex_account_type,
                      X_book_type_code,
                      X_default_ccid,
                      X_dist_ccid);
               end if;
            end if;

            if ((found and h_cip_clearing_ccid is null) OR (not found)) then
               /* Generate CIP CLEARING account */
               h_acct_seg          := X_cip_clearing_acct;
               h_acct_ccid         := X_cip_clearing_ccid;
               h_flex_account_type := 'CIP_CLEARING';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_cip_clearing_ccid := h_return_ccid;
               else
                  Add_Messages(
                      X_asset_number,
                      X_asset_id,
                      h_acct_ccid,
                      h_acct_seg,
                      h_flex_account_type,
                      X_book_type_code,
                      X_default_ccid,
                      X_dist_ccid);
               end if;
            end if;
         end if; -- asset_type CIP

         /* BUG# 1553682 */
         if (X_allow_reval_flag = 'YES' and
             X_asset_type      <> 'GROUP' AND
             X_group_asset_id  is null) then

            if ((found and h_reval_amort_ccid is null) OR (not found)) then
               /* Generate REVAL AMORT account */
               h_acct_seg          := X_reval_amort_acct;
               h_acct_ccid         := X_reval_amort_ccid;
               h_flex_account_type := 'REV_AMORT';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_reval_amort_ccid := h_return_ccid;
               else
                  Add_Messages(
                      X_asset_number,
                      X_asset_id,
                      h_acct_ccid,
                      h_acct_seg,
                      h_flex_account_type,
                      X_book_type_code,
                      X_default_ccid,
                      X_dist_ccid);
               end if;
            end if;


            if ((found and h_reval_rsv_ccid is null) OR (not found)) then
               /* Generate REVAL RESERVE  account */
               h_acct_seg          := X_reval_rsv_acct;
               h_acct_ccid         := X_reval_rsv_ccid;
               h_flex_account_type := 'REV_RSV';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_reval_rsv_ccid := h_return_ccid;
               else
                  Add_Messages(
                      X_asset_number,
                      X_asset_id,
                      h_acct_ccid,
                      h_acct_seg,
                      h_flex_account_type,
                      X_book_type_code,
                      X_default_ccid,
                      X_dist_ccid);
               end if;
            end if;
         end if;   -- reval allowed flag


         if (X_bonus_rule is not null) then  -- BUG# 1791317

            if ((found and h_bonus_exp_ccid is null) OR (not found)) then
               /* Generate BONUS EXPENSE account */
               h_acct_seg          := X_bonus_exp_acct;
               h_acct_ccid         := 0;  /* BONUS EXPENSE */
               h_flex_account_type := 'BONUS_DEPRN_EXP';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_bonus_exp_ccid := h_return_ccid;
               else
                  Add_Messages(
                      X_asset_number,
                      X_asset_id,
                      h_acct_ccid,
                      h_acct_seg,
                      h_flex_account_type,
                      X_book_type_code,
                      X_default_ccid,
                      X_dist_ccid);
               end if;
            end if;


            if ((found and h_bonus_rsv_ccid is null) OR (not found)) then
               /* Generate BONUS RESERVE  account */
               h_acct_seg          := X_bonus_rsv_acct;
               h_acct_ccid         := X_bonus_rsv_ccid;
               h_flex_account_type := 'BONUS_DEPRN_RSV';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_bonus_rsv_ccid := h_return_ccid;
               else
                  Add_Messages(
                     X_asset_number,
                     X_asset_id,
                     h_acct_ccid,
                     h_acct_seg,
                     h_flex_account_type,
                     X_book_type_code,
                     X_default_ccid,
                     X_dist_ccid);
               end if;
            end if;
         end if;  -- end bonus_rule not null

         -- bugfix 5080401, applied if condition to avoid generating impairment expense and
	 -- impairment reserve accounts if they are not defined in category books
         if (X_allow_impairment_flag = 'Y') then
           if (X_impair_exp_acct is not null) and (X_impair_rsv_ccid is not null) then
	    if ((found and h_impair_exp_ccid is null) OR (not found)) then
               /* Generate IMPAIR EXP account */
               h_acct_seg          := X_impair_exp_acct;
               h_acct_ccid         := X_impair_exp_ccid;
               h_flex_account_type := 'IMPAIR_EXP';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_impair_exp_ccid := h_return_ccid;
               else
                  Add_Messages(
                      X_asset_number,
                      X_asset_id,
                      h_acct_ccid,
                      h_acct_seg,
                      h_flex_account_type,
                      X_book_type_code,
                      X_default_ccid,
                      X_dist_ccid);
               end if;
            end if;

	    if ((found and h_impair_rsv_ccid is null) OR (not found)) then
               /* Generate IMPAIR RESERVE  account */
               h_acct_seg          := X_impair_rsv_acct;
               h_acct_ccid         := X_impair_rsv_ccid;
               h_flex_account_type := 'IMPAIR_RSV';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_impair_rsv_ccid := h_return_ccid;
               else
                  Add_Messages(
                      X_asset_number,
                      X_asset_id,
                      h_acct_ccid,
                      h_acct_seg,
                      h_flex_account_type,
                      X_book_type_code,
                      X_default_ccid,
                      X_dist_ccid);
               end if;
            end if;
	 end if; -- impair account not null
        end if;  -- impair allowed

      -- Bug 6666666 : Start of changes for SORP Compliance Project

          if (X_allow_sorp_flag = 'Y') then

              if ((found and h_capital_adj_ccid is null) OR (not found)) then
                  /* Generate Capital Adjustment account */
                   h_acct_seg          := X_capital_adj_acct;
                   h_acct_ccid         := X_capital_adj_ccid;
                   h_flex_account_type := 'CAPITAL_ADJ';
                   result := FAFLEX_PKG_WF.START_PROCESS(
                                    X_flex_account_type => h_flex_account_type,
                                    X_book_type_code    => X_book_type_code,
                                    X_flex_num          => X_flex_num,
                                    X_dist_ccid         => X_dist_ccid,
                                    X_acct_segval       => h_acct_seg,
                                    X_default_ccid      => X_default_ccid,
                                    X_account_ccid      => h_acct_ccid,
                                    X_distribution_id   => X_distribution_id,
                                    X_validation_date   => G_validation_date,
                                    X_return_ccid       => h_return_ccid,
                                    p_log_level_rec     => g_log_level_rec);
                   if (result) then
                       G_success_count := G_success_count + 1;
                       h_capital_adj_ccid := h_return_ccid;
                   else
                       Add_Messages(
                          X_asset_number,
                          X_asset_id,
                          h_acct_ccid,
                          h_acct_seg,
                          h_flex_account_type,
                          X_book_type_code,
                          X_default_ccid,
                          X_dist_ccid);
                   end if; -- Result
              end if; -- End Found Capital Adjustment

              if ((found and h_general_fund_ccid is null) OR (not found)) then
                  /* Generate General Fund account */
                   h_acct_seg          := X_general_fund_acct;
                   h_acct_ccid         := X_general_fund_ccid;
                   h_flex_account_type := 'GENERAL_FUND';
                   result := FAFLEX_PKG_WF.START_PROCESS(
                                    X_flex_account_type => h_flex_account_type,
                                    X_book_type_code    => X_book_type_code,
                                    X_flex_num          => X_flex_num,
                                    X_dist_ccid         => X_dist_ccid,
                                    X_acct_segval       => h_acct_seg,
                                    X_default_ccid      => X_default_ccid,
                                    X_account_ccid      => h_acct_ccid,
                                    X_distribution_id   => X_distribution_id,
                                    X_validation_date   => G_validation_date,
                                    X_return_ccid       => h_return_ccid,
                                    p_log_level_rec     => g_log_level_rec);
                   if (result) then
                       G_success_count := G_success_count + 1;
                       h_general_fund_ccid := h_return_ccid;
                   else
                       Add_Messages(
                          X_asset_number,
                          X_asset_id,
                          h_acct_ccid,
                          h_acct_seg,
                          h_flex_account_type,
                          X_book_type_code,
                          X_default_ccid,
                          X_dist_ccid);
                   end if; -- Result
              end if; -- End Found General Fund

          end If; -- Allow Sorp Flag

      -- Bug 6666666 : End of changes for SORP Compliance Project

      end if;  -- end category accts

      if (G_pregen_book_acct = 'Y' AND
          X_asset_type <> 'GROUP') then

         if ((found and h_nbv_gain_ccid is null) OR (not found)) then
            /* Generate NBV_RETIRED_GAIN_ACCT */
            h_acct_seg          := X_nbv_gain_acct;
            h_acct_ccid         := 0;
            h_flex_account_type := 'NBV_GAIN';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_nbv_gain_ccid := h_return_ccid;
            else
              Add_Messages(
                X_asset_number,
                X_asset_id,
                h_acct_ccid,
                h_acct_seg,
                h_flex_account_type,
                X_book_type_code,
                X_default_ccid,
                X_dist_ccid);
            end if;
         end if;

         if ((found and h_nbv_loss_ccid is null) OR (not found)) then
            /* Generate NBV_RETIRED_LOSS_ACCT */
            h_acct_seg          := X_nbv_loss_acct;
            h_acct_ccid         := 0;
            h_flex_account_type := 'NBV_LOSS';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_nbv_loss_ccid := h_return_ccid;
            else
               Add_Messages(
                  X_asset_number,
                  X_asset_id,
                  h_acct_ccid,
                  h_acct_seg,
                  h_flex_account_type,
                  X_book_type_code,
                  X_default_ccid,
                  X_dist_ccid);
            end if;
         end if;

         if ((found and h_pos_gain_ccid is null) OR (not found)) then
            /* Generate PROCEEDS_OF_SALE_GAIN_ACCT */
            h_acct_seg          := X_pos_gain_acct;
            h_acct_ccid         := 0;
            h_flex_account_type := 'POS_GAIN';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_pos_gain_ccid := h_return_ccid;
            else
               Add_Messages(
                  X_asset_number,
                  X_asset_id,
                  h_acct_ccid,
                  h_acct_seg,
                  h_flex_account_type,
                  X_book_type_code,
                  X_default_ccid,
                  X_dist_ccid);
            end if;
         end if;

         if ((found and h_pos_loss_ccid is null) OR (not found)) then
            /* Generate PROCEEDS_OF_SALE_LOSS_ACCT */
            h_acct_seg          := X_pos_loss_acct;
            h_acct_ccid         := 0;
            h_flex_account_type := 'POS_LOSS';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_pos_loss_ccid := h_return_ccid;
            else
               Add_Messages(
                  X_asset_number,
                  X_asset_id,
                  h_acct_ccid,
                  h_acct_seg,
                  h_flex_account_type,
                  X_book_type_code,
                  X_default_ccid,
                  X_dist_ccid);
            end if;
         end if;

         if ((found and h_cor_gain_ccid is null) OR (not found)) then
            /* Generate COST_OF_REMOVAL_GAIN_ACCT */
            h_acct_seg          := X_cor_gain_acct;
            h_acct_ccid         := 0;
            h_flex_account_type := 'COR_GAIN';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_cor_gain_ccid := h_return_ccid;
            else
               Add_Messages(
                  X_asset_number,
                  X_asset_id,
                  h_acct_ccid,
                  h_acct_seg,
                  h_flex_account_type,
                  X_book_type_code,
                  X_default_ccid,
                  X_dist_ccid);
            end if;
         end if;

         if ((found and h_cor_loss_ccid is null) OR (not found)) then
            /* Generate COST_OF_REMOVAL_LOSS_ACCT */
            h_acct_seg          := X_cor_loss_acct;
            h_acct_ccid         := 0;
            h_flex_account_type := 'COR_LOSS';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_cor_loss_ccid := h_return_ccid;
            else
              Add_Messages(
                 X_asset_number,
                 X_asset_id,
                 h_acct_ccid,
                 h_acct_seg,
                 h_flex_account_type,
                 X_book_type_code,
                 X_default_ccid,
                 X_dist_ccid);
            end if;
         end if;

         if ((found and h_cor_clearing_ccid is null) OR (not found)) then
            /* Generate COST_OF_REMOVAL_CLEARING_ACCT */
            h_acct_seg          := X_cor_clearing_acct;
            h_acct_ccid         := 0;
            h_flex_account_type := 'COR_CLEARING';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_cor_clearing_ccid := h_return_ccid;
            else
               Add_Messages(
                  X_asset_number,
                  X_asset_id,
                  h_acct_ccid,
                  h_acct_seg,
                  h_flex_account_type,
                  X_book_type_code,
                  X_default_ccid,
                  X_dist_ccid);
            end if;
         end if;

         if ((found and h_pos_clearing_ccid is null) OR (not found)) then
            /* Generate PROCEEDS_OF_SALE_CLEARING_ACCT */
            h_acct_seg          := X_pos_clearing_acct;
            h_acct_ccid         := 0;
            h_flex_account_type := 'POS_CLEARING';
            result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
            if (result) then
               G_success_count := G_success_count + 1;
               h_pos_clearing_ccid := h_return_ccid;
            else
               Add_Messages(
                  X_asset_number,
                  X_asset_id,
                  h_acct_ccid,
                  h_acct_seg,
                  h_flex_account_type,
                  X_book_type_code,
                  X_default_ccid,
                  X_dist_ccid);
            end if;
         end if;

         /* BUG# 1553682 */

         if (X_book_class = 'TAX' and
             X_group_asset_id is null) then

            if (X_allow_deprn_adjust = 'YES') then

               if ((found and h_deprn_adj_ccid is null) OR (not found)) then
                  /* Generate DEPRN_ADJ */
                  h_acct_seg          := X_deprn_adj_acct;
                  h_acct_ccid         := 0;
                  h_flex_account_type := 'DEPRN_ADJ';
                  result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
                   if (result) then
                      G_success_count := G_success_count + 1;
                      h_deprn_adj_ccid := h_return_ccid;
                   else
                      Add_Messages(
                        X_asset_number,
                        X_asset_id,
                        h_acct_ccid,
                        h_acct_seg,
                        h_flex_account_type,
                        X_book_type_code,
                        X_default_ccid,
                        X_dist_ccid);
                   end if;
               end if;
            end if;  -- allow deprn_adjust flag


            if ((found and h_deferred_exp_ccid is null) OR (not found)) then
               /* Generate DEFERRED_DEPRN_EXPENSE_ACCT */
               h_acct_seg          := X_deferred_exp_acct;
               h_acct_ccid         := 0;
               h_flex_account_type := 'DEF_DEPRN_EXP';
               result := FAFLEX_PKG_WF.START_PROCESS(
                             X_flex_account_type => h_flex_account_type,
                             X_book_type_code    => X_book_type_code,
                             X_flex_num          => X_flex_num,
                             X_dist_ccid         => X_dist_ccid,
                             X_acct_segval       => h_acct_seg,
                             X_default_ccid      => X_default_ccid,
                             X_account_ccid      => h_acct_ccid,
                             X_distribution_id   => X_distribution_id,
                             X_validation_date   => G_validation_date,
                             X_return_ccid       => h_return_ccid,
                             p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_deferred_exp_ccid := h_return_ccid;
               else
                  Add_Messages(
                     X_asset_number,
                     X_asset_id,
                     h_acct_ccid,
                     h_acct_seg,
                     h_flex_account_type,
                     X_book_type_code,
                     X_default_ccid,
                     X_dist_ccid);
               end if;
            end if;

            if ((found and h_deferred_rsv_ccid is null) OR (not found)) then
               /* Generate DEFERRED_DEPRN_RESERVE_ACCT */
               h_acct_seg          := X_deferred_rsv_acct;
               h_acct_ccid         := 0;
               h_flex_account_type := 'DEF_DEPRN_RSV';
               result := FAFLEX_PKG_WF.START_PROCESS(
                             X_flex_account_type => h_flex_account_type,
                             X_book_type_code    => X_book_type_code,
                             X_flex_num          => X_flex_num,
                             X_dist_ccid         => X_dist_ccid,
                             X_acct_segval       => h_acct_seg,
                             X_default_ccid      => X_default_ccid,
                             X_account_ccid      => h_acct_ccid,
                             X_distribution_id   => X_distribution_id,
                             X_validation_date   => G_validation_date,
                             X_return_ccid       => h_return_ccid,
                             p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_deferred_rsv_ccid := h_return_ccid;
               else
                  Add_Messages(
                     X_asset_number,
                     X_asset_id,
                     h_acct_ccid,
                     h_acct_seg,
                     h_flex_account_type,
                     X_book_type_code,
                     X_default_ccid,
                     X_dist_ccid);
               end if;
            end if;

         end if;    -- X_book_Class = TAX


         if (X_allow_reval_flag  = 'YES' and
             X_group_asset_id is null) then

            if ((found and h_reval_rsv_gain_ccid is null) OR (not found)) then
               /* Generate REVAL_RSV_RETIRED_GAIN_ACCT */
               h_acct_seg          := X_reval_rsv_gain_acct;
               h_acct_ccid         := 0;
               h_flex_account_type := 'REV_RSV_GAIN';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_reval_rsv_gain_ccid := h_return_ccid;
               else
                  Add_Messages(
                        X_asset_number,
                        X_asset_id,
                        h_acct_ccid,
                        h_acct_seg,
                        h_flex_account_type,
                        X_book_type_code,
                        X_default_ccid,
                        X_dist_ccid);
               end if;
            end if;

            if ((found and h_reval_rsv_loss_ccid is null) OR (not found)) then
               /* Generate REVAL_RSV_RETIRED_LOSS_ACCT */
               h_acct_seg          := X_reval_rsv_loss_acct;
               h_acct_ccid         := 0;
               h_flex_account_type := 'REV_RSV_LOSS';
               result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => h_flex_account_type,
                                X_book_type_code    => X_book_type_code,
                                X_flex_num          => X_flex_num,
                                X_dist_ccid         => X_dist_ccid,
                                X_acct_segval       => h_acct_seg,
                                X_default_ccid      => X_default_ccid,
                                X_account_ccid      => h_acct_ccid,
                                X_distribution_id   => X_distribution_id,
                                X_validation_date   => G_validation_date,
                                X_return_ccid       => h_return_ccid,
                                p_log_level_rec     => g_log_level_rec);
               if (result) then
                  G_success_count := G_success_count + 1;
                  h_reval_rsv_loss_ccid := h_return_ccid;
               else
                  Add_Messages(
                        X_asset_number,
                        X_asset_id,
                        h_acct_ccid,
                        h_acct_seg,
                        h_flex_account_type,
                        X_book_type_code,
                        X_default_ccid,
                        X_dist_ccid);
               end if;
            end if;

         end if;    -- end if allow_reval_flag

      end if; --end book level accts

      close get_ccids;

      -- insert or update all the CCID's obtained for distribution
      -- into FA_DISTRIBUTION_ACCOUNTS

      h_user_id := fnd_global.user_id;
      h_login_id := fnd_global.login_id;

      if (not found) then

         INSERT INTO FA_DISTRIBUTION_ACCOUNTS(
                      BOOK_TYPE_CODE,
                      DISTRIBUTION_ID,
                      ASSET_COST_ACCOUNT_CCID,
                      ASSET_CLEARING_ACCOUNT_CCID,
                      DEPRN_EXPENSE_ACCOUNT_CCID,
                      DEPRN_RESERVE_ACCOUNT_CCID,
                      CIP_COST_ACCOUNT_CCID,
                      CIP_CLEARING_ACCOUNT_CCID,
                      NBV_RETIRED_GAIN_CCID,
                      NBV_RETIRED_LOSS_CCID,
                      PROCEEDS_SALE_GAIN_CCID,
                      PROCEEDS_SALE_LOSS_CCID,
                      COST_REMOVAL_GAIN_CCID,
                      COST_REMOVAL_LOSS_CCID,
                      COST_REMOVAL_CLEARING_CCID,
                      PROCEEDS_SALE_CLEARING_CCID,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      CREATED_BY,
                      CREATION_DATE,
                      LAST_UPDATE_LOGIN,
                      deferred_exp_account_ccid,
                      deferred_rsv_account_ccid,
                      reval_rsv_gain_account_ccid,
                      reval_rsv_loss_account_ccid,
                      deprn_adj_account_ccid,
                      reval_amort_account_ccid,
                      reval_rsv_account_ccid,
                      bonus_exp_account_ccid,
                      bonus_rsv_account_ccid,
                      impair_expense_account_ccid,
                      impair_reserve_account_ccid,
                      capital_adj_account_ccid,   -- Bug 6666666
                      general_fund_account_ccid   -- Bug 6666666
          )VALUES(
          X_book_type_code,
          X_distribution_id,
          h_cost_acct_ccid,
          h_clearing_acct_ccid,
          h_expense_acct_ccid,
          h_reserve_acct_ccid,
          h_cip_cost_ccid,
          h_cip_clearing_ccid,
          h_nbv_gain_ccid,
          h_nbv_loss_ccid,
          h_pos_gain_ccid,
          h_pos_loss_ccid,
          h_cor_gain_ccid,
          h_cor_loss_ccid,
          h_cor_clearing_ccid,
          h_pos_clearing_ccid,
          sysdate,
          h_user_id,
          h_user_id,
          sysdate,
          h_login_id,
          h_deferred_exp_ccid,
          h_deferred_rsv_ccid,
          h_reval_rsv_gain_ccid,
          h_reval_rsv_loss_ccid,
          h_deprn_adj_ccid,
          h_reval_amort_ccid,
          h_reval_rsv_ccid,
          h_bonus_exp_ccid,
          h_bonus_rsv_ccid,
          h_impair_exp_ccid,
          h_impair_rsv_ccid,
          h_capital_adj_ccid,
          h_general_fund_ccid);
      else
       UPDATE FA_DISTRIBUTION_ACCOUNTS
          SET ASSET_COST_ACCOUNT_CCID     = h_cost_acct_ccid,
              ASSET_CLEARING_ACCOUNT_CCID = h_clearing_acct_ccid,
              DEPRN_EXPENSE_ACCOUNT_CCID  = h_expense_acct_ccid,
              DEPRN_RESERVE_ACCOUNT_CCID  = h_reserve_acct_ccid,
              CIP_COST_ACCOUNT_CCID       = h_cip_cost_ccid,
              CIP_CLEARING_ACCOUNT_CCID   = h_cip_clearing_ccid,
              NBV_RETIRED_GAIN_CCID       = h_nbv_gain_ccid,
              NBV_RETIRED_LOSS_CCID       = h_nbv_loss_ccid,
              PROCEEDS_SALE_GAIN_CCID     = h_pos_gain_ccid,
              PROCEEDS_SALE_LOSS_CCID     = h_pos_loss_ccid,
              COST_REMOVAL_GAIN_CCID      = h_cor_gain_ccid,
              COST_REMOVAL_LOSS_CCID      = h_cor_loss_ccid,
              COST_REMOVAL_CLEARING_CCID  = h_cor_clearing_ccid,
              PROCEEDS_SALE_CLEARING_CCID = h_pos_clearing_ccid,
              LAST_UPDATE_DATE            = sysdate,
              LAST_UPDATED_BY             = h_user_id,
              LAST_UPDATE_LOGIN           = h_login_id,
              deferred_exp_account_ccid   = h_deferred_exp_ccid,
              deferred_rsv_account_ccid   = h_deferred_rsv_ccid,
              reval_rsv_gain_account_ccid = h_reval_rsv_gain_ccid,
              reval_rsv_loss_account_ccid = h_reval_rsv_loss_ccid,
              deprn_adj_account_ccid      = h_deprn_adj_ccid,
              reval_amort_account_ccid    = h_reval_amort_ccid,
              reval_rsv_account_ccid      = h_reval_rsv_ccid,
              bonus_exp_account_ccid      = h_bonus_exp_ccid,
              bonus_rsv_account_ccid      = h_bonus_rsv_ccid,
              impair_expense_account_ccid = h_impair_exp_ccid,
              impair_reserve_account_ccid = h_impair_rsv_ccid,
              capital_adj_account_ccid    = h_capital_adj_ccid,
              general_fund_account_ccid   = h_general_fund_ccid
        WHERE BOOK_TYPE_CODE              = X_book_type_code
          AND DISTRIBUTION_ID             = X_distribution_id;
      end if;
      COMMIT;

EXCEPTION
      WHEN OTHERS THEN
           FA_SRVR_MSG.ADD_SQL_ERROR(
              CALLING_FN => 'FA_GENACCTS_PKG.GEN_CCID',  p_log_level_rec => g_log_level_rec);
           ROLLBACK WORK;
           wf_core.context('FA_FLEX_PKG',
                    'StartProcess',
                    X_book_type_code,
                    X_dist_ccid,
                    X_default_ccid,
                    'FAFLEXWF');
           raise;
END GEN_CCID;

---------------------------------------------------------------------

PROCEDURE Add_Messages(
          X_asset_number       IN     VARCHAR2,
          X_asset_id           IN     NUMBER,
          X_account_ccid       IN     NUMBER,
          X_acct_seg           IN     VARCHAR2,
          X_flex_account_type  IN     VARCHAR2,
          X_book_type_code     IN     VARCHAR2,
          X_default_ccid       IN     NUMBER,
          X_dist_ccid          IN     NUMBER) IS

BEGIN

   G_failure_count := G_failure_count + 1;

   -- BUG# 1504839
   -- Main flex error is already dumped out in FAFLEX_WF_PKG, so there
   -- is not need to dump it here as well...
   -- book and account_type are also dumped out in the message from FAFLEX_WF_PKG

   if (g_log_level_rec.statement_level) then

      FA_SRVR_MSG.ADD_MESSAGE
              (CALLING_FN => 'FA_GENACCTS_PKG.GEN_CCID',
               NAME       => 'FA_ASSET_NUMBER',
               TOKEN1     => 'ASSET_NUMBER',
               VALUE1     => X_asset_number,  p_log_level_rec => g_log_level_rec);
      FA_SRVR_MSG.ADD_MESSAGE
              (CALLING_FN => 'FA_GENACCTS_PKG.GEN_CCID',
               NAME       => 'FA_ASSET_ID',
               TOKEN1     => 'ASSET_ID',
               VALUE1     => X_asset_id,  p_log_level_rec => g_log_level_rec);

      FA_SRVR_MSG.ADD_MESSAGE
              (CALLING_FN => 'FA_GENACCTS_PKG.GEN_CCID',
               NAME       => 'FA_FLEX_ACCOUNT_SEGMENT',
               TOKEN1     => 'ACCOUNT_SEGMENT',
               VALUE1     => X_acct_seg,  p_log_level_rec => g_log_level_rec);
      FA_SRVR_MSG.ADD_MESSAGE
              (CALLING_FN => 'FA_GENACCTS_PKG.GEN_CCID',
               NAME       => 'FA_FLEX_ACCOUNT_CCID',
               TOKEN1     => 'ACCOUNT_CCID',
               VALUE1     => X_account_ccid,  p_log_level_rec => g_log_level_rec);
      FA_SRVR_MSG.ADD_MESSAGE
              (CALLING_FN => 'FA_GENACCTS_PKG.GEN_CCID',
               NAME       => 'FA_FLEX_DEFAULT_CCID',
               TOKEN1     => 'DEFAULT_CCID',
               VALUE1     => X_default_ccid,  p_log_level_rec => g_log_level_rec);
      FA_SRVR_MSG.ADD_MESSAGE
              (CALLING_FN => 'FA_GENACCTS_PKG.GEN_CCID',
               NAME       => 'FA_FLEX_DISTRIBUTION_CCID',
               TOKEN1     => 'DISTRIBUTION_CCID',
               VALUE1     => X_dist_ccid,  p_log_level_rec => g_log_level_rec);
   end if;

END Add_Messages;

-----------------------------------------------------------------------

PROCEDURE Load_Workers(
                p_book_type_code     IN     VARCHAR2,
                p_parent_request_id  IN     NUMBER,
                p_total_requests     IN     NUMBER,
                x_worker_jobs           OUT NOCOPY NUMBER,
                x_return_status         OUT NOCOPY number) IS

   l_batch_size         number;
   l_dist_source_book   varchar2(30);
   l_calling_fn         varchar2(60) := 'FA_GENACCTS_PKG.Load_Workers';

   error_found          exception;

BEGIN

   if (not g_log_level_rec.initialized) then
      if (NOT fa_util_pub.get_log_level_rec (
                x_log_level_rec =>  g_log_level_rec
      )) then
         raise  FND_API.G_EXC_ERROR;
      end if;
   end if;

   if not (fa_cache_pkg.fazcbc(x_book => p_book_type_code, p_log_level_rec => g_log_level_rec)) then
      raise error_found;
   end if;

   l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 1000);
   l_dist_source_book := fa_cache_pkg.fazcbc_record.distribution_source_book;

   INSERT INTO FA_WORKER_JOBS
          (START_RANGE, END_RANGE, WORKER_NUM, STATUS,REQUEST_ID)
   SELECT MIN(DISTRIBUTION_ID), MAX(DISTRIBUTION_ID), 0,
          'UNASSIGNED', p_parent_request_id  FROM ( SELECT /*+ parallel(DH) */
          DISTRIBUTION_ID, FLOOR(RANK()
          OVER (ORDER BY DISTRIBUTION_ID)/l_batch_size ) UNIT_ID
     FROM FA_DISTRIBUTION_HISTORY DH
    WHERE DH.BOOK_TYPE_CODE = l_dist_source_book )
    GROUP BY UNIT_ID;

   if g_log_level_rec.statement_level then
      fa_debug_pkg.add(l_calling_fn, 'rows inserted into worker jobs: ', SQL%ROWCOUNT);
   end if;

   commit;

   x_return_status := 0;

EXCEPTION
   WHEN error_found then
        rollback;
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => g_log_level_rec);
        x_return_status := 2;

   WHEN OTHERS THEN
        FA_SRVR_MSG.ADD_SQL_ERROR(
           CALLING_FN => 'FA_GENACCTS_PKG.gen_accts',  p_log_level_rec => g_log_level_rec);
        rollback;
        if (g_log_level_rec.statement_level) then
           fa_debug_pkg.dump_debug_messages(max_mesgs => 0, p_log_level_rec => g_log_level_rec);
        end if;
        x_return_status := 2;

END Load_Workers;

-----------------------------------------------------------------------

END FA_GENACCTS_PKG;

/
