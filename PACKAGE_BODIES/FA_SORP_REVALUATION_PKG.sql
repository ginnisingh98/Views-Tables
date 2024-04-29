--------------------------------------------------------
--  DDL for Package Body FA_SORP_REVALUATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_SORP_REVALUATION_PKG" AS
/* $Header: FAVSRVB.pls 120.4.12010000.1 2009/07/21 12:37:55 glchen noship $   */

   g_temp_integer  binary_integer;
   g_temp_number   number;

   /*Bug#7392015 added following fucntion which will calculate deprn effect for double db
   depreciation method */
   Function fa_sorp_link_reval_dd(
      p_mass_reval_id       IN           NUMBER,
      p_asset_id            IN           NUMBER,
      p_book_type_code      IN           VARCHAR2,
      p_impairment_id       IN           NUMBER,
      p_unused_imp_amount   IN           NUMBER,
      p_mrc_sob_type_code   IN           VARCHAR2,
      p_set_of_books_id     IN           NUMBER,
      x_deprn_rsv           OUT NOCOPY   NUMBER,
      x_impairment_amt      OUT NOCOPY   NUMBER,
      x_impair_split_flag   OUT NOCOPY   VARCHAR2,
      x_override_flag       OUT NOCOPY   VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) RETURN BOOLEAN IS

      l_dpr_in                       FA_STD_TYPES.dpr_struct;
      l_dpr_out                      FA_STD_TYPES.dpr_out_struct;
      l_dpr_arr                      FA_STD_TYPES.dpr_arr_type;
      l_dpr_row         FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
      l_status          boolean;
      l_running_mode                  VARCHAR2(20);
      l_calling_fn   varchar2(60) := 'fa_sorp_link_reval_dd';

      l_period_counter_impaired      NUMBER:=0;
      l_impairment_date date;
      l_split_impair_flag varchar2(3);
      l_deprn_rsv_out  number:=0;
      L_LINKED_IMPAIR_AMOUNT number :=0;
      l_impairment_amount number :=0;
      l_split_impair_amt number:=0;
      l_reval_expense number :=0;
      l_count number :=0;
      l_reval_amort_deprn_exp number :=0;
      l_period_counter_revalued number :=0;

      CURSOR c_impair_period_counter is
          select PERIOD_COUNTER,IMPAIRMENT_DATE,
                 impairment_amount,
                 decode(SPLIT_IMPAIR_FLAG,'N','NO','Y','YES','NO'),
                 DECODE(INSTR (p_impairment_id, '.'),'0',impairment_amount,
                 DECODE (SUBSTR (p_impairment_id, -1,LENGTH (p_impairment_id)),
                                    '1', split1_loss_amount,
                                    '2', split2_loss_amount,
                                    '3', split3_loss_amount
                           )) split_impairm_amount
          from fa_ITF_impairments
          where asset_id = p_asset_id and
          impairment_id=fa_sorp_process_imp_id_fn(p_impairment_id) and
          book_type_code=p_book_type_code;

      CURSOR c_get_old_fin_rec is
          select * from
          fa_books
          where book_type_code = p_book_type_code and
          asset_id = p_asset_id and
          transaction_header_id_out = (select transaction_header_id
                                       from
                                       fa_transaction_headers
                                       where MASS_TRANSACTION_ID = fa_sorp_process_imp_id_fn(p_impairment_id));


      CURSOR c_get_period_rec (c_start_date  date) IS
          select cp.period_num
                  , fy.fiscal_year
          from   fa_fiscal_year fy
                  , fa_calendar_periods cp
          where  cp.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
          and    fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
          and    cp.start_date between fy.start_date and fy.end_date
          and    c_start_date between cp.start_date and cp.end_date;

      CURSOR c_get_open_period_rec IS
          select period_num,fiscal_year,PERIOD_COUNTER
          from fa_deprn_periods
          where book_type_code = p_book_type_code
          and PERIOD_CLOSE_DATE is null;

      Cursor c_get_deprn_rsv_out(c_period_counter_impaired number) is
          select SUM(decode(ADJUSTMENT_TYPE,'RESERVE',adjustment_amount,0)),
                 sum(decode(ADJUSTMENT_TYPE,'EXPENSE',adjustment_amount,0)),
                 PERIOD_COUNTER_CREATED
          from fa_adjustments
          where asset_id = p_asset_id AND
          book_type_code = p_book_type_code AND
          PERIOD_COUNTER_CREATED >= c_period_counter_impaired and
          SOURCE_TYPE_CODE='REVALUATION'
          group by PERIOD_COUNTER_CREATED;

      CURSOR c_get_reval_expenses(c_period_counter_impaired number) is
          select sum(REVAL_DEPRN_EXPENSE),count(*)
          from fa_deprn_summary
          where asset_id = p_asset_id and
          PERIOD_COUNTER >= c_period_counter_impaired
          and book_type_code=p_book_type_code;
      l_c_get_old_fin_rec c_get_old_fin_rec%rowtype;

begin

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.ADD (l_calling_fn,'BEGINS','1', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,'p_mass_reval_id',p_mass_reval_id, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,'p_asset_id',p_asset_id, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,'p_book_type_code',p_book_type_code, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,'p_impairment_id',p_impairment_id, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,'p_unused_imp_amount',p_unused_imp_amount, p_log_level_rec => p_log_level_rec);
      end if;

      open c_impair_period_counter;
      fetch c_impair_period_counter into l_period_counter_impaired,
                                         l_impairment_date,
                                         l_impairment_amount,
                                         l_split_impair_flag,
                                         l_split_impair_amt;
      close c_impair_period_counter;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.ADD (l_calling_fn,'period_counter_impaired',l_period_counter_impaired, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,'l_impairment_date',l_impairment_date, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,'l_split_impair_flag',l_split_impair_flag, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn,'l_impairment_amount',l_impairment_amount, p_log_level_rec => p_log_level_rec);
      end if;
      x_impair_split_flag := l_split_impair_flag;
      /*+++++++ Populating l_dpr_in to call faxcde ++++++++++*/
            l_dpr_in.calendar_type         := fa_cache_pkg.fazcbc_record.deprn_calendar;
            l_dpr_in.book                  := p_book_type_code;
            l_dpr_in.asset_id              := p_asset_id;

            l_dpr_row.asset_id            := p_asset_id;
            l_dpr_row.book                 := p_book_type_code;
            l_dpr_row.period_ctr           := l_period_counter_impaired;
            l_dpr_row.dist_id              := 0;
            l_dpr_row.mrc_sob_type_code    := 'P';

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Calling', 'query_balances_int', p_log_level_rec => p_log_level_rec);
            end if;
            l_running_mode                 := 'STANDARD';
            fa_query_balances_pkg.query_balances_int(
                                   X_DPR_ROW               => l_dpr_row,
                                   X_RUN_MODE              => l_running_mode,
                                   X_DEBUG                 => FALSE,
                                   X_SUCCESS               => l_status,
                                   X_CALLING_FN            => l_calling_fn,
                                   X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

            if (NOT l_status) then

               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'ERROR',
                                   'Calling fa_query_balances_pkg.query_balances_int', p_log_level_rec => p_log_level_rec);
               end if;

               --raise dpr_err;
            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_adjust_exp', l_dpr_row.deprn_adjust_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_exp', l_dpr_row.deprn_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_rsv', l_dpr_row.deprn_rsv, p_log_level_rec => p_log_level_rec);
            end if;

            open c_get_old_fin_rec;
            fetch c_get_old_fin_rec into l_c_get_old_fin_rec;
            close c_get_old_fin_rec;

            l_dpr_in.rec_cost                   := l_c_get_old_fin_rec.recoverable_cost;
            l_dpr_in.salvage_value              := l_c_get_old_fin_rec.salvage_value;
            l_dpr_in.adj_rec_cost               := l_c_get_old_fin_rec.adjusted_recoverable_cost;
            l_dpr_in.adj_cost                   := l_c_get_old_fin_rec.adjusted_cost;
            l_dpr_in.formula_factor             := l_c_get_old_fin_rec.formula_factor;
            l_dpr_in.rate_adj_factor            := l_c_get_old_fin_rec.rate_adjustment_factor;
            l_dpr_in.eofy_reserve               := l_c_get_old_fin_rec.eofy_reserve;

            l_dpr_in.method_code                := l_c_get_old_fin_rec.deprn_method_code;
            if(l_c_get_old_fin_rec.deprn_method_code = 'STL') then
               x_override_flag                     := 'NO';
            else
               x_override_flag                     := 'YES';
             end if;
            l_dpr_in.life                       := l_c_get_old_fin_rec.life_in_months;
            l_dpr_in.reval_amo_basis            := l_c_get_old_fin_rec.reval_amortization_basis;

            l_dpr_in.jdate_in_service           := to_number(to_char(l_c_get_old_fin_rec.date_placed_in_service, 'J'));
            l_dpr_in.prorate_jdate              := to_number(to_char(l_c_get_old_fin_rec.prorate_date, 'J'));
            l_dpr_in.deprn_start_jdate          := to_number(to_char(l_c_get_old_fin_rec.deprn_start_date, 'J'));
            l_dpr_in.prorate_date               := l_c_get_old_fin_rec.prorate_date;
            l_dpr_in.orig_deprn_start_date      := l_c_get_old_fin_rec.original_deprn_start_date;

            l_dpr_in.jdate_retired              := 0;
            l_dpr_in.ret_prorate_jdate          := 0;

            l_dpr_in.ltd_prod                   := l_dpr_row.ltd_prod;
            l_dpr_in.ytd_deprn                  := l_dpr_row.ytd_deprn;
            l_dpr_in.deprn_rsv                  := l_dpr_row.deprn_rsv;
            l_dpr_in.reval_rsv                  := l_dpr_row.reval_rsv;
            l_dpr_in.bonus_deprn_exp            := 0;
            l_dpr_in.bonus_ytd_deprn            := l_dpr_row.bonus_ytd_deprn;
            l_dpr_in.bonus_deprn_rsv            := l_dpr_row.bonus_deprn_rsv;
            l_dpr_in.prior_fy_exp               := l_dpr_row.prior_fy_exp;
            l_dpr_in.prior_fy_bonus_exp         := l_dpr_row.prior_fy_bonus_exp;
            l_dpr_in.impairment_exp             := 0;
            l_dpr_in.ytd_impairment             := 0;--l_dpr_row.ytd_impairment;
            l_dpr_in.impairment_rsv             := 0;--l_dpr_row.impairment_rsv;
            l_dpr_in.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;
            l_dpr_in.rsv_known_flag := TRUE;
            l_dpr_in.deprn_rounding_flag := 'ADJ';
            l_dpr_in.used_by_adjustment := FALSE;
            l_dpr_in.capital_adjustment := l_dpr_row.capital_adjustment;
            l_dpr_in.general_fund := l_dpr_row.general_fund;
	    l_dpr_in.set_of_books_id      := p_set_of_books_id;
            l_running_mode := fa_std_types.FA_DPR_NORMAL;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'Calling', 'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
            end if;

             if not fa_cache_pkg.fazccp(fa_cache_pkg.fazcbc_record.prorate_calendar,
                                          fa_cache_pkg.fazcbc_record.fiscal_year_name,
                                          l_dpr_in.prorate_jdate,
                                          g_temp_number,
                                          l_dpr_in.y_begin,
                                          g_temp_integer, p_log_level_rec => p_log_level_rec) then
               if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add(l_calling_fn, 'Error calling',
                                   'fa_cache_pkg.fazccp', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.prorate_calendar',
                                   fa_cache_pkg.fazcbc_record.prorate_calendar, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add(l_calling_fn, 'fa_cache_pkg.fazcbc_record.fiscal_year_name',
                                   fa_cache_pkg.fazcbc_record.fiscal_year_name, p_log_level_rec => p_log_level_rec);

               end if;

               --raise dpr_err;
            end if;

            open c_get_period_rec(l_impairment_date);
            fetch c_get_period_rec into l_dpr_in.p_cl_begin,l_dpr_in.y_begin;
            close c_get_period_rec;
            open c_get_open_period_rec;
            fetch c_get_open_period_rec into l_dpr_in.p_cl_end,l_dpr_in.y_end,l_dpr_row.period_ctr;
            close c_get_open_period_rec;

            /*Bug8221363 -- Need to calculate till last period only*/
            if l_dpr_in.p_cl_end = 1 then
               l_dpr_in.p_cl_end := 12;
               l_dpr_in.y_end := l_dpr_in.y_end - 1;
            else
               l_dpr_in.p_cl_end := l_dpr_in.p_cl_end - 1;
            end if;

             if (p_log_level_rec.statement_level) then
               fa_debug_pkg.ADD (l_calling_fn,'before calling faxcde','1', p_log_level_rec => p_log_level_rec);
             end if;
             if not FA_CDE_PKG.faxcde(l_dpr_in,
                                        l_dpr_arr,
                                        l_dpr_out,
                                        l_running_mode, p_log_level_rec => p_log_level_rec) then
               fa_debug_pkg.ADD (l_calling_fn,'failled running','FA_CDE_PKG.faxcde', p_log_level_rec => p_log_level_rec);
             end if;

      x_deprn_rsv := l_dpr_out.new_deprn_rsv - l_dpr_row.deprn_exp;
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'x_deprn_rsv calculated by faxcde call', x_deprn_rsv, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'Calling again to get current reserve', 'query_balances_int', p_log_level_rec => p_log_level_rec);
      end if;

      l_running_mode                 := 'STANDARD';
      fa_query_balances_pkg.query_balances_int(
                                   X_DPR_ROW               => l_dpr_row,
                                   X_RUN_MODE              => l_running_mode,
                                   X_DEBUG                 => FALSE,
                                   X_SUCCESS               => l_status,
                                   X_CALLING_FN            => l_calling_fn,
                                   X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

      if (NOT l_status) then

         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'ERROR',
                                   'Calling fa_query_balances_pkg.query_balances_int', p_log_level_rec => p_log_level_rec);
         end if;
         --raise dpr_err;
      end if;
      if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_adjust_exp', l_dpr_row.deprn_adjust_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_exp', l_dpr_row.deprn_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'l_dpr_row.deprn_rsv', l_dpr_row.deprn_rsv, p_log_level_rec => p_log_level_rec);
      end if;

      /* Complex logic to calculated the deper effect */
      /* first take difference of calculated deprn and current deprn*/
      x_deprn_rsv := (x_deprn_rsv - l_dpr_row.deprn_rsv);
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'deprn effect before perious partial linked reval impact (if any) :', x_deprn_rsv);
      end if;

      /* check if any partial linking has happened,if so consider deprn reserve at that point in time to
          as it will reversed by revaluation.*/
      open c_get_deprn_rsv_out(l_period_counter_impaired);
      fetch c_get_deprn_rsv_out into l_deprn_rsv_out,
                                     l_reval_expense,
                                     l_period_counter_revalued;
      close c_get_deprn_rsv_out;
      x_deprn_rsv := x_deprn_rsv - nvl(l_deprn_rsv_out,0);
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'deprn rsv moved out because of period revaluation if any:',l_deprn_rsv_out, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'already linked amount l_reval_expense:', l_reval_expense, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'already linked amount l_period_counter_revalued:', l_period_counter_revalued, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'deprn effect reverse NOT FINAL######:', x_deprn_rsv, p_log_level_rec => p_log_level_rec);
      end if;

      /*Logic to prorate deprn effect if partial linking has happened earlier */

      x_impairment_amt := 0;
      if l_split_impair_flag = 'NO' then
         /* p_unused_imp_amount <> l_impairment_amount will be true if already partially linked*/
         if p_unused_imp_amount <> l_impairment_amount then
            open c_get_reval_expenses(l_period_counter_revalued);
            fetch c_get_reval_expenses into l_reval_amort_deprn_exp,
                                            l_count;
            close c_get_reval_expenses;
            x_deprn_rsv := x_deprn_rsv + nvl(l_reval_expense,0)*l_count;
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, 'sum of reval amortization amount after partial link', l_reval_amort_deprn_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'count no of period l_count:', l_count, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, 'deprn effect reverse NOT FINAL 3######:', x_deprn_rsv, p_log_level_rec => p_log_level_rec);
             end if;
            /* set x_impairment_amt which will be used in calling function for calculation*/
            x_impairment_amt := l_impairment_amount;
         end if;
      elsif l_split_impair_flag = 'YES' then
         open c_get_reval_expenses(l_period_counter_revalued);
         fetch c_get_reval_expenses into l_reval_amort_deprn_exp,
                                         l_count;
         close c_get_reval_expenses;
         x_deprn_rsv := nvl(l_reval_expense,0)*l_count + x_deprn_rsv + l_reval_amort_deprn_exp;
         x_deprn_rsv :=  (x_deprn_rsv * p_unused_imp_amount)/l_impairment_amount;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, 'sum of reval amortization amount after partial link', l_reval_amort_deprn_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'count no of period l_count:', l_count, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add(l_calling_fn, 'deprn effect reverse NOT FINAL 3######:', x_deprn_rsv, p_log_level_rec => p_log_level_rec);
         end if;
         x_impairment_amt := l_split_impair_amt ;
         /* set x_impairment_amt which will be used in calling function for calculation*/
      end if;
      /*round before return */
      x_deprn_rsv := round(x_deprn_rsv,2);
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'deprn effect reverse FINAL######:', x_deprn_rsv, p_log_level_rec => p_log_level_rec);
      end if;
      return true;
end fa_sorp_link_reval_dd;






/* Function takes impairment id as input.
   For split impairments impairment id is concatenated with split numbers
   This function removes the concatenation and is used in query joins
*/



   FUNCTION fa_sorp_process_imp_id_fn (p_impairment_id NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN NUMBER
   IS
      v_impairment_id   NUMBER;

--The cursor checks if there is '.' string the impairment id.
--If there is no '.' string then it means no split associated with this imapirment
--If '.' string is present then it removes 2 chars from concatenated impairment id
      CURSOR c_cur
      IS
         SELECT DECODE (NVL (INSTR (p_impairment_id, '.'), 0),
                        0, TO_NUMBER (p_impairment_id),
                        TO_NUMBER (SUBSTR (p_impairment_id,
                                           1,
                                           (LENGTH (p_impairment_id) - 2)
                                          )
                                  )
                       )
           FROM DUAL;
   BEGIN
      IF p_impairment_id = 0
      THEN
         RETURN 0;
      ELSE
         OPEN c_cur;

         FETCH c_cur
          INTO v_impairment_id;

         CLOSE c_cur;

         RETURN v_impairment_id;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_log_level_rec.statement_level
         THEN
            fa_debug_pkg.ADD ('fa_sorp_process_imp_id_fn',
                              'Error Occured',
                              'YES'
                             , p_log_level_rec => p_log_level_rec);
         END IF;

         RETURN (0);
   END fa_sorp_process_imp_id_fn;

/* This function will calculate the effect of impairment on depriciation runs
*/
   FUNCTION fa_imp_deprn_eff_fn (
      p_impairment_id    NUMBER,
      p_book_type_code   VARCHAR2,
      p_asset_id         NUMBER,
      p_reval_imp_flag   VARCHAR2,
      p_amount           NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN NUMBER
   IS
-- Local variables declaration
      v_deprn_cnt                 NUMBER;
      v_book_type_code            FA_SORP_ASSET_LINK_REVAL_V.book_type_code%TYPE;
      v_asset_id                  FA_SORP_ASSET_LINK_REVAL_V.asset_id%TYPE;
      v_deprn_amount              NUMBER;
      v_deprn_reserve             NUMBER;
      v_period_name               VARCHAR2 (25);
      v_period_counter_impaired   NUMBER;
      l_imp_effect                NUMBER;
      l_last_period_counter       NUMBER;
      l_dpr_row_test              fa_std_types.fa_deprn_row_struct;
      l_status_test               BOOLEAN;
      l_running_mode_test         VARCHAR2 (20);
      v_deprn_delta               NUMBER;
      v_impair_loss_amount        NUMBER;
      v_reserve_adj_amount        NUMBER;
      v_imp_flag                  VARCHAR2 (1);

/* There are three cursors used in this function
   All cursors check if impairment has any splits and calcuates deprn impact based on split or non split

   1.c_deprn_common_cur
      This cursor calcuates deprn impact due to impairment on whole Impairment amount.This is used to calculate Reval Gain
   2.c_deprn_imp_amt_cur
      This cursor calcuates deprn impact due to impairment on calculated impairment amount
      (Total Impairment Amount - Reval Reserve Adj  Amount).
  3.c_deprn_reval_rsv_amt_cur
      This cursor calcuates deprn impact due to impairment on any Amount
*/
      CURSOR c_deprn_common_cur
      IS
         SELECT deprn_sum.book_type_code, deprn_sum.asset_id,
                deprn_sum.deprn_amount, deprn_sum.deprn_reserve,
                deprn_periods.period_name, imp.period_counter_impaired,
                DECODE
                   (INSTR (p_impairment_id, '.'),
                    '0', ROUND ((  (  (  itf.impairment_amount
                                       + NVL (itf.reval_reserve_adj_amount, 0)
                                      )
                                    * deprn_sum.deprn_amount
                                   )
                                 / imp.net_book_value
                                ),
                                2
                               ),
                    DECODE (SUBSTR (p_impairment_id,
                                    -1,
                                    LENGTH (p_impairment_id)
                                   ),
                            '1', ROUND ((  (  (  itf.split1_loss_amount
                                               + NVL
                                                    (itf.split1_reval_reserve,
                                                     0
                                                    )
                                              )
                                            * deprn_sum.deprn_amount
                                           )
                                         / imp.net_book_value
                                        ),
                                        2
                                       ),
                            '2', ROUND ((  (  (  itf.split2_loss_amount
                                               + NVL
                                                    (itf.split2_reval_reserve,
                                                     0
                                                    )
                                              )
                                            * deprn_sum.deprn_amount
                                           )
                                         / imp.net_book_value
                                        ),
                                        2
                                       ),
                            '3', ROUND ((  (  (  itf.split3_loss_amount
                                               + NVL
                                                    (itf.split3_reval_reserve,
                                                     0
                                                    )
                                              )
                                            * deprn_sum.deprn_amount
                                           )
                                         / imp.net_book_value
                                        ),
                                        2
                                       )
                           )
                   ) deprn_delta
           FROM fa_deprn_summary deprn_sum,
                fa_deprn_periods deprn_periods,
                fa_impairments imp,
                fa_itf_impairments itf
          WHERE deprn_sum.book_type_code = deprn_periods.book_type_code
            AND deprn_sum.period_counter = deprn_periods.period_counter
            AND deprn_sum.period_counter = imp.period_counter_impaired
            AND deprn_sum.book_type_code = imp.book_type_code
            AND deprn_sum.asset_id = imp.asset_id
            AND imp.impairment_id = itf.impairment_id
            AND imp.asset_id = itf.asset_id
            AND imp.impairment_id =
                                   fa_sorp_process_imp_id_fn (p_impairment_id);

      CURSOR c_deprn_imp_amt_cur
      IS
         SELECT deprn_sum.book_type_code, deprn_sum.asset_id,
                deprn_sum.deprn_amount, deprn_sum.deprn_reserve,
                deprn_periods.period_name, imp.period_counter_impaired,
                DECODE
                   (INSTR (p_impairment_id, '.'),
                    '0', ROUND ((  (  (  itf.impairment_amount
                                       - (  NVL (itf.reversed_imp_amt, 0)
                                          + NVL (itf.reversed_deprn_impact, 0)
                                         )
                                      )
                                    * deprn_sum.deprn_amount
                                   )
                                 / imp.net_book_value
                                ),
                                2
                               ),
                    DECODE (SUBSTR (p_impairment_id,
                                    -1,
                                    LENGTH (p_impairment_id)
                                   ),
                            '1', ROUND
                                    ((  (  (  itf.split1_loss_amount
                                            - (  NVL (itf.reversed_imp_amt_s1,
                                                      0
                                                     )
                                               + NVL
                                                    (itf.reversed_deprn_impact_s1,
                                                     0
                                                    )
                                              )
                                           )
                                         * deprn_sum.deprn_amount
                                        )
                                      / imp.net_book_value
                                     ),
                                     2
                                    ),
                            '2', ROUND
                                    ((  (  (  itf.split2_loss_amount
                                            - (  NVL (itf.reversed_imp_amt_s2,
                                                      0
                                                     )
                                               + NVL
                                                    (itf.reversed_deprn_impact_s2,
                                                     0
                                                    )
                                              )
                                           )
                                         * deprn_sum.deprn_amount
                                        )
                                      / imp.net_book_value
                                     ),
                                     2
                                    ),
                            '3', ROUND
                                    ((  (  (  itf.split3_loss_amount
                                            - (  NVL (itf.reversed_imp_amt_s3,
                                                      0
                                                     )
                                               + NVL
                                                    (itf.reversed_deprn_impact_s3,
                                                     0
                                                    )
                                              )
                                           )
                                         * deprn_sum.deprn_amount
                                        )
                                      / imp.net_book_value
                                     ),
                                     2
                                    )
                           )
                   ) deprn_delta
           FROM fa_deprn_summary deprn_sum,
                fa_deprn_periods deprn_periods,
                fa_impairments imp,
                fa_itf_impairments itf
          WHERE deprn_sum.book_type_code = deprn_periods.book_type_code
            AND deprn_sum.period_counter = deprn_periods.period_counter
            AND deprn_sum.period_counter = imp.period_counter_impaired
            AND deprn_sum.book_type_code = imp.book_type_code
            AND deprn_sum.asset_id = imp.asset_id
            AND imp.impairment_id = itf.impairment_id
            AND imp.asset_id = itf.asset_id
            AND imp.impairment_id =
                                   fa_sorp_process_imp_id_fn (p_impairment_id);

      CURSOR c_deprn_reval_rsv_amt_cur
      IS
         SELECT deprn_sum.book_type_code, deprn_sum.asset_id,
                deprn_sum.deprn_amount, deprn_sum.deprn_reserve,
                deprn_periods.period_name, imp.period_counter_impaired,
                ROUND ((  ((p_amount) * deprn_sum.deprn_amount)
                        / imp.net_book_value
                       ),
                       2
                      ) deprn_delta
           FROM fa_deprn_summary deprn_sum,
                fa_deprn_periods deprn_periods,
                fa_impairments imp,
                fa_itf_impairments itf
          WHERE deprn_sum.book_type_code = deprn_periods.book_type_code
            AND deprn_sum.period_counter = deprn_periods.period_counter
            AND deprn_sum.period_counter = imp.period_counter_impaired
            AND deprn_sum.book_type_code = imp.book_type_code
            AND deprn_sum.asset_id = imp.asset_id
            AND imp.impairment_id = itf.impairment_id
            AND imp.asset_id = itf.asset_id
            AND imp.impairment_id =
                                   fa_sorp_process_imp_id_fn (p_impairment_id);
   BEGIN
      l_last_period_counter := fa_cache_pkg.fazcbc_record.last_period_counter;

      IF p_reval_imp_flag = 'C'
      THEN
         OPEN c_deprn_common_cur;

         FETCH c_deprn_common_cur
          INTO v_book_type_code, v_asset_id, v_deprn_amount, v_deprn_reserve,
               v_period_name, v_period_counter_impaired, v_deprn_delta;

         --Below query finds the number of deprn runs after the impairment
         SELECT COUNT (1)
           INTO v_deprn_cnt
           FROM fa_deprn_summary deprn_sum, fa_deprn_periods deprn_periods
          WHERE deprn_sum.book_type_code = deprn_periods.book_type_code
            AND deprn_sum.period_counter = deprn_periods.period_counter
            AND deprn_periods.period_close_date IS NOT NULL
            AND deprn_sum.book_type_code = p_book_type_code
            AND deprn_sum.asset_id = p_asset_id
            AND deprn_sum.period_counter > v_period_counter_impaired;

         IF v_deprn_cnt <> 0
         THEN
            --Depn impact is the deprn delta multiplied by no. of deprn runs
            l_imp_effect := (v_deprn_cnt * v_deprn_delta);

            CLOSE c_deprn_common_cur;

            RETURN (l_imp_effect);
         ELSE
            l_imp_effect := 0;
            RETURN (l_imp_effect);
         END IF;
      ELSIF p_reval_imp_flag = 'I'
      THEN
         SELECT DECODE (INSTR (p_impairment_id, '.'),
                        '0', ROUND (NVL (itf.impairment_amount, 0), 2),
                        DECODE (SUBSTR (p_impairment_id,
                                        -1,
                                        LENGTH (p_impairment_id)
                                       ),
                                '1', ROUND (NVL (itf.split1_loss_amount, 0),
                                            2),
                                '2', ROUND (NVL (itf.split2_loss_amount, 0),
                                            2),
                                '3', ROUND (NVL (itf.split3_loss_amount, 0),
                                            2)
                               )
                       ) impair_loss_amount,
                DECODE (INSTR (p_impairment_id, '.'),
                        '0', ROUND (NVL (itf.reval_reserve_adj_amount, 0), 2),
                        DECODE (SUBSTR (p_impairment_id,
                                        -1,
                                        LENGTH (p_impairment_id)
                                       ),
                                '1', ROUND (NVL (itf.split1_reval_reserve, 0),
                                            2
                                           ),
                                '2', ROUND (NVL (itf.split2_reval_reserve, 0),
                                            2
                                           ),
                                '3', ROUND (NVL (itf.split3_reval_reserve, 0),
                                            2
                                           )
                               )
                       ) reserve_adj_amount
           INTO v_impair_loss_amount,
                v_reserve_adj_amount
           FROM fa_itf_impairments itf
          WHERE impairment_id = fa_sorp_process_imp_id_fn (p_impairment_id);

         OPEN c_deprn_imp_amt_cur;

         FETCH c_deprn_imp_amt_cur
          INTO v_book_type_code, v_asset_id, v_deprn_amount, v_deprn_reserve,
               v_period_name, v_period_counter_impaired, v_deprn_delta;

         --Below query finds the number of deprn runs after the impairment
         SELECT COUNT (1)
           INTO v_deprn_cnt
           FROM fa_deprn_summary deprn_sum, fa_deprn_periods deprn_periods
          WHERE deprn_sum.book_type_code = deprn_periods.book_type_code
            AND deprn_sum.period_counter = deprn_periods.period_counter
            AND deprn_periods.period_close_date IS NOT NULL
            AND deprn_sum.book_type_code = p_book_type_code
            AND deprn_sum.asset_id = p_asset_id
            AND deprn_sum.period_counter > v_period_counter_impaired;

         IF v_deprn_cnt <> 0
         THEN
            --Depn impact is the deprn delta multiplied by no. of deprn runs
            l_imp_effect := (v_deprn_cnt * v_deprn_delta);

            CLOSE c_deprn_imp_amt_cur;

            RETURN (l_imp_effect);
         ELSE
            l_imp_effect := 0;
            RETURN (l_imp_effect);
         END IF;
      ELSIF p_reval_imp_flag = 'R'
      THEN
         OPEN c_deprn_reval_rsv_amt_cur;

         FETCH c_deprn_reval_rsv_amt_cur
          INTO v_book_type_code, v_asset_id, v_deprn_amount, v_deprn_reserve,
               v_period_name, v_period_counter_impaired, v_deprn_delta;

         --Below query finds the number of deprn runs after the impairment
         SELECT COUNT (1)
           INTO v_deprn_cnt
           FROM fa_deprn_summary deprn_sum, fa_deprn_periods deprn_periods
          WHERE deprn_sum.book_type_code = deprn_periods.book_type_code
            AND deprn_sum.period_counter = deprn_periods.period_counter
            AND deprn_periods.period_close_date IS NOT NULL
            AND deprn_sum.book_type_code = p_book_type_code
            AND deprn_sum.asset_id = p_asset_id
            AND deprn_sum.period_counter > v_period_counter_impaired;

         IF v_deprn_cnt <> 0
         THEN
            --Depn impact is the deprn delta multiplied by no. of deprn runs
            l_imp_effect := (v_deprn_cnt * v_deprn_delta);

            CLOSE c_deprn_reval_rsv_amt_cur;

            RETURN (l_imp_effect);
         ELSE
            l_imp_effect := 0;
            RETURN (l_imp_effect);
         END IF;
      END IF;

      IF p_log_level_rec.statement_level
      THEN
         fa_debug_pkg.ADD ('fa_imp_deprn_eff_fn',
                           'Impairment Impact on deprn',
                           l_imp_effect
                          , p_log_level_rec => p_log_level_rec);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF p_log_level_rec.statement_level
         THEN
            fa_debug_pkg.ADD ('fa_imp_deprn_eff_fn', 'Error Occured', 'YES', p_log_level_rec => p_log_level_rec);
         END IF;

         RETURN (0);
   END fa_imp_deprn_eff_fn;

   FUNCTION fa_sorp_accounting (
      p_asset_id        IN       NUMBER,
      p_request_id      IN       NUMBER,
      px_adj            IN OUT NOCOPY fa_adjust_type_pkg.fa_adj_row_struct,
      p_created_by      IN       NUMBER,
      p_creation_date   IN       DATE
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
      RETURN BOOLEAN
   AS
      pos_err                       EXCEPTION;
      l_calling_fn                  VARCHAR2 (60) := 'fa_sorp_accounting';
      v_imapirment_id               NUMBER;
      v_reval_reserve_impact_flag   VARCHAR2 (1);
      v_impair_loss_impact          NUMBER;
      v_reval_reserve               NUMBER;
      v_imp_deprn_effect            NUMBER;
      l_imp_deprn_effect            NUMBER;
      v_impair_loss_acct            VARCHAR2 (25);
      v_reval_fraction              NUMBER;
      v_imp_loss_fraction           NUMBER;
      v_calc_imp_reverse_amt        NUMBER;
      v_calc_imp_rev_deprn_effect   NUMBER;
      v_rsv_reverse_amt             NUMBER;
      v_rsv_reverse_deprn_effect    NUMBER;

      CURSOR c_sorp_link_itf_cur
      IS
         SELECT impairment_id, reval_reserve_impact_flag, impair_loss_impact,
                imp_deprn_effect, NVL (impair_loss_acct, 'N'),
                calc_imp_reverse_amt, calc_imp_reverse_deprn_effect,
                rsv_reverse_amt, rsv_reverse_deprn_effect
           FROM fa_sorp_link_reval_itf
          WHERE request_id = p_request_id
            AND asset_id = p_asset_id
            AND run_mode = 'RUN';

      v_tmp_amt                     NUMBER;
   BEGIN
      fa_debug_pkg.ADD ('SORP_ACCOUNTING', 'START', 'START', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('SORP_ACCOUNTING', 'p_asset_id', p_asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('SORP_ACCOUNTING', 'p_request_id', p_request_id, p_log_level_rec => p_log_level_rec);

      OPEN c_sorp_link_itf_cur;

      FETCH c_sorp_link_itf_cur
       INTO v_imapirment_id, v_reval_reserve_impact_flag,
            v_impair_loss_impact, v_imp_deprn_effect, v_impair_loss_acct,
            v_calc_imp_reverse_amt, v_calc_imp_rev_deprn_effect,
            v_rsv_reverse_amt, v_rsv_reverse_deprn_effect;

      IF v_impair_loss_acct = 'N'
      THEN
         v_impair_loss_acct := fa_cache_pkg.fazccb_record.impair_expense_acct;
      END IF;

      fa_debug_pkg.ADD ('SORP_ACCOUNTING',
                        'v_impair_loss_acct',
                        v_impair_loss_acct
                       , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('SORP_ACCOUNTING',
                        'v_REVAL_RESERVE_IMPACT_FLAG',
                        v_reval_reserve_impact_flag
                       , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('SORP_ACCOUNTING', 'v_imapirment_id', v_imapirment_id, p_log_level_rec => p_log_level_rec);

      IF NVL (v_calc_imp_reverse_amt, 0) <> 0
      THEN
         px_adj.adjustment_amount := ROUND ((v_calc_imp_reverse_amt), 2);
         px_adj.adjustment_type := 'LINK IMPAIR EXP';
         px_adj.account_type := 'IMPAIR_EXPENSE_ACCT';
         px_adj.ACCOUNT := v_impair_loss_acct;
         px_adj.debit_credit_flag := 'CR';

         IF NOT fa_ins_adjust_pkg.faxinaj (px_adj,
                                           p_creation_date,
                                           p_created_by
                                          , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE pos_err;
         END IF;

         IF NOT fa_sorp_util_pvt.create_sorp_neutral_acct
                                             (ROUND ((v_calc_imp_reverse_amt
                                                     ),
                                                     2
                                                    ),
                                              'Y',
                                              px_adj,
                                              p_created_by,
                                              p_creation_date, p_log_level_rec
                                             )
         THEN
            RAISE pos_err;
         END IF;
      END IF;

      IF NVL (v_calc_imp_rev_deprn_effect, 0) <> 0
      THEN
         px_adj.adjustment_amount := ROUND ((v_calc_imp_rev_deprn_effect), 2);
         px_adj.adjustment_type := 'LINK IMPAIR EXP';
         px_adj.account_type := 'IMPAIR_EXPENSE_ACCT';
         px_adj.ACCOUNT := v_impair_loss_acct;
         px_adj.debit_credit_flag := 'CR';

         IF NOT fa_ins_adjust_pkg.faxinaj (px_adj,
                                           p_creation_date,
                                           p_created_by
                                          , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE pos_err;
         END IF;

         IF NOT fa_sorp_util_pvt.create_sorp_neutral_acct
                                        (ROUND ((v_calc_imp_rev_deprn_effect
                                                ),
                                                2
                                               ),
                                         'Y',
                                         px_adj,
                                         p_created_by,
                                         p_creation_date, p_log_level_rec
                                        )
         THEN
            RAISE pos_err;
         END IF;

         px_adj.adjustment_amount := ROUND ((v_calc_imp_rev_deprn_effect), 2);
         px_adj.adjustment_type := 'EXPENSE';
         px_adj.account_type := 'DEPRN_EXPENSE_ACCT';
         px_adj.ACCOUNT := fa_cache_pkg.fazccb_record.deprn_expense_acct;
         px_adj.debit_credit_flag := 'DR';

         IF NOT fa_ins_adjust_pkg.faxinaj (px_adj,
                                           p_creation_date,
                                           p_created_by
                                          , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE pos_err;
         END IF;

         IF NOT fa_sorp_util_pvt.create_sorp_neutral_acct
                                        (ROUND ((v_calc_imp_rev_deprn_effect
                                                ),
                                                2
                                               ),
                                         'N',
                                         px_adj,
                                         p_created_by,
                                         p_creation_date, p_log_level_rec
                                        )
         THEN
            RAISE pos_err;
         END IF;
      END IF;

      IF NVL (v_rsv_reverse_deprn_effect, 0) <> 0
      THEN
         px_adj.adjustment_amount := ROUND ((v_rsv_reverse_deprn_effect), 2);
         px_adj.adjustment_type := 'EXPENSE';
         px_adj.account_type := 'DEPRN_EXPENSE_ACCT';
         px_adj.ACCOUNT := fa_cache_pkg.fazccb_record.deprn_expense_acct;
         px_adj.debit_credit_flag := 'DR';

         IF NOT fa_ins_adjust_pkg.faxinaj (px_adj,
                                           p_creation_date,
                                           p_created_by
                                          , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE pos_err;
         END IF;

         IF NOT fa_sorp_util_pvt.create_sorp_neutral_acct
                                         (ROUND ((v_rsv_reverse_deprn_effect
                                                 ),
                                                 2
                                                ),
                                          'N',
                                          px_adj,
                                          p_created_by,
                                          p_creation_date, p_log_level_rec
                                         )
         THEN
            RAISE pos_err;
         END IF;

         px_adj.adjustment_amount := ROUND ((v_rsv_reverse_deprn_effect), 2);
         px_adj.adjustment_type := 'REVAL RESERVE';
         px_adj.account_type := 'REVAL_RESERVE_ACCT';
         px_adj.ACCOUNT := fa_cache_pkg.fazccb_record.reval_reserve_acct;
         px_adj.debit_credit_flag := 'CR';

         IF NOT fa_ins_adjust_pkg.faxinaj (px_adj,
                                           p_creation_date,
                                           p_created_by
                                          , p_log_level_rec => p_log_level_rec)
         THEN
            RAISE pos_err;
         END IF;
      END IF;

      CLOSE c_sorp_link_itf_cur;

      RETURN TRUE;
   EXCEPTION
      WHEN pos_err
      THEN
         fa_debug_pkg.ADD (l_calling_fn,
                           'exception at sorp accounting',
                           'pos_err'
                          , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn, 'sqlerrm', SUBSTRB (SQLERRM, 1, 200));
         RETURN FALSE;
      WHEN OTHERS
      THEN
         fa_debug_pkg.ADD (l_calling_fn,
                           'exception at sorp accounting',
                           'OTHERS'
                          , p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.ADD (l_calling_fn, 'sqlerrm', SUBSTRB (SQLERRM, 1, 200));
         RETURN FALSE;
   END fa_sorp_accounting;

/* Procedure has logic for linking revaluations with prior impairments.
   It handles both asset level and category level revaluation
   Parameter p_reval_type takes value 'A' for asset level and value 'C' category level
*/
   PROCEDURE fa_sorp_link_reval (
      -- p_nbv                            NUMBER,
      p_adj_amt                        NUMBER,
      p_mass_reval_id                  NUMBER,
      p_asset_id                       NUMBER,
      p_book_type_code                 VARCHAR2,
      p_run_mode                       VARCHAR2,
      p_request_id                     NUMBER,
      p_mrc_sob_type_code              VARCHAR2,
      p_category_id                    NUMBER,
      p_reval_type                     VARCHAR2,
      p_set_of_books_id                NUMBER,
      x_imp_loss_impact          OUT NOCOPY  NUMBER,
      x_reval_gain               OUT NOCOPY  NUMBER,
      x_impair_loss_acct         OUT NOCOPY  VARCHAR2,
      x_temp_imp_deprn_effect    OUT NOCOPY  NUMBER,
      x_reval_rsv_deprn_effect   OUT NOCOPY  NUMBER
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
   IS
-- Local Varibales declaration
      v_sum                         NUMBER;             -- sum of impairments
      v_impairment_id               FA_SORP_ASSET_LINK_REVAL_V.impairment_id%TYPE;
      v_book_type_code              FA_SORP_ASSET_LINK_REVAL_V.book_type_code%TYPE;
      v_asset_id                    FA_SORP_ASSET_LINK_REVAL_V.asset_id%TYPE;
      v_IMP_LOSS_AMOUNT             FA_SORP_ASSET_LINK_REVAL_V.IMP_LOSS_AMOUNT%Type;
      V_SPLIT_IMPAIR_FLAG           varchar2(3);
      v_mass_reval_id               FA_SORP_ASSET_LINK_REVAL_V.mass_reval_id%TYPE;
      v_reverse_imp_amt             FA_SORP_ASSET_LINK_REVAL_V.unused_imp_loss_amount%TYPE;
      -- Amount to be reversed
      l_adj_amt                     NUMBER;
      -- Delta value NBV(Reval) - NBV(Current)
      l_new_reverse_amt             NUMBER;
      l_temp_reverse_amt            NUMBER;
      l_exit                        BOOLEAN                           := TRUE;
      v_category_id                 NUMBER;
      v_imp_impact                  NUMBER;
      v_temp_imp_impact             NUMBER;
      l_reval_gain                  NUMBER;
      v_impair_loss_acct            NUMBER;
      v_imp_deprn_effect            NUMBER;
      v_temp_imp_deprn_effect       NUMBER;
      v_reval_reserve_impact_flag   VARCHAR2 (1);
      v_impair_class                VARCHAR2 (240);
      v_reason                      VARCHAR2 (240);
      v_calc_imp_deprn_effect       NUMBER;
      v_calc_imp_impact             NUMBER;
      l_temp_reval_rsv              NUMBER;
      l_reval_rsv_deprn_effect      NUMBER;
       l_temp_reval_rsv_deprn_effect      NUMBER;
      v_reval_rsv_adj_amount        NUMBER;
      v_calc_imp_loss_amount        NUMBER;
      l_reverse_rsv_amount          NUMBER;
      l_temp_reverse_rsv_amount          NUMBER;
      v_split_number                NUMBER;
      l_reval_gain_temp             NUMBER;
      t_1 number;
      t_2 number;
      t_3 number;
      t_4 number;

      CURSOR c_asset_cur
      IS
         SELECT   impairment_id, split_number, book_type_code, asset_id,
                  IMP_LOSS_AMOUNT,decode(SPLIT_IMPAIR_FLAG,'N','NO','Y','YES','NO')
                  /*Bug# 7392015-Added to columns for prorate */
                  ,unused_imp_loss_amount, mass_reval_id,
                  (  unused_imp_loss_amount
                   - fa_imp_deprn_eff_fn (impairment_id,
                                          book_type_code,
                                          asset_id,
                                          'C',
                                          NULL
                                         )
                  ) imp_impact, -- Impairtment Amount -- Deprn Impact due to impairment amount
                  fa_imp_deprn_eff_fn (impairment_id,
                                       book_type_code,
                                       asset_id,
                                       'C',
                                       NULL
                                      ) imp_deprn_effect, -- Deprn Impact due to impairment amount
                  calc_imp_loss_amount,
                  (  calc_imp_loss_amount
                   - fa_imp_deprn_eff_fn (impairment_id,
                                          book_type_code,
                                          asset_id,
                                          'I',
                                          NULL
                                         )
                  ) calc_imp_impact, -- (I/E Impairment amount - depreciation impact on the I/E)
                  fa_imp_deprn_eff_fn (impairment_id,
                                       book_type_code,
                                       asset_id,
                                       'I',
                                       NULL
                                      ) calc_imp_deprn_effect, --(depreciation impact on the I/E)
                  impair_loss_acct, NULL category_id,
                  reval_reserve_impact_flag, NVL (reval_rsv_adj_amount, 0),
                  impair_class, reason
             FROM fa_sorp_asset_link_reval_v
            WHERE asset_id = p_asset_id
              AND book_type_code = p_book_type_code
              AND mass_reval_id = p_mass_reval_id
              AND imp_include_flag = 'Y'
         ORDER BY impairment_date DESC,
                  impair_class,
                  unused_imp_loss_amount,
                  imp_impact;

      CURSOR c_cat_cur
      IS
         SELECT *
           FROM (SELECT   impairment_id, split_number, book_type_code,
                          asset_id,unused_imp_loss_amount, mass_reval_id,
                          (  unused_imp_loss_amount
                           - fa_imp_deprn_eff_fn (impairment_id,
                                                  book_type_code,
                                                  asset_id,
                                                  'C',
                                                  NULL
                                                 )
                          ) imp_impact, -- Impairtment Amount -- Deprn Impact due to impairment amount
                          fa_imp_deprn_eff_fn
                                            (impairment_id,
                                             book_type_code,
                                             asset_id,
                                             'C',
                                             NULL
                                            ) imp_deprn_effect, -- Deprn Impact due to impairment amount
                          calc_imp_loss_amount,
                          (  calc_imp_loss_amount
                           - fa_imp_deprn_eff_fn (impairment_id,
                                                  book_type_code,
                                                  asset_id,
                                                  'I',
                                                  NULL
                                                 )
                          ) calc_imp_impact, -- (I/E Impairment amount - depreciation impact on the I/E)
                          fa_imp_deprn_eff_fn
                                       (impairment_id,
                                        book_type_code,
                                        asset_id,
                                        'I',
                                        NULL
                                       ) calc_imp_deprn_effect, --(depreciation impact on the I/E)
                          NVL (reval_rsv_adj_amount, 0), impair_loss_acct,
                          category_id, reval_reserve_impact_flag,
                          impair_class, reason
                     FROM fa_sorp_cat_link_reval_v
                    WHERE asset_id = p_asset_id
                      AND book_type_code = p_book_type_code
                      AND mass_reval_id = p_mass_reval_id
                      AND category_id = p_category_id
                      AND unused_imp_loss_amount > 0
                 ORDER BY impairment_date DESC,
                          impair_class,
                          unused_imp_loss_amount,
                          imp_impact)
          WHERE ROWNUM = 1;

          x_deprn_rsv number;
          x_impairment_amt NUMBER;
          x_override_flag varchar2(3);
          x_impair_split_flag varchar2(3);
   BEGIN
      fa_debug_pkg.ADD ('fa_sorp_link_reval', 'Start', 'Start', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('fa_sorp_link_reval', 'p_adj_amt', p_adj_amt, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('fa_sorp_link_reval',
                        'p_mass_reval_id',
                        p_mass_reval_id
                       , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('fa_sorp_link_reval', 'p_asset_id', p_asset_id, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('fa_sorp_link_reval',
                        'p_book_type_code',
                        p_book_type_code
                       , p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('fa_sorp_link_reval', 'p_run_mode', p_run_mode, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('fa_sorp_link_reval', 'p_request_id', p_request_id, p_log_level_rec => p_log_level_rec);
-- Adjustment Amount is the  amount that can be adjusted based on amount entered for revaluation by the user and on revaluation method
-- Calculation for getting adj amount in available in Reval Private package
      l_adj_amt := p_adj_amt;
      fa_debug_pkg.ADD ('fa_sorp_link_reval', 'p_reval_type', p_reval_type, p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.ADD ('fa_sorp_link_reval', 'l_adj_amt', l_adj_amt, p_log_level_rec => p_log_level_rec);

      IF p_reval_type = 'A'
      THEN
         OPEN c_asset_cur; -- Start Asset cursor

         FETCH c_asset_cur
          INTO v_impairment_id, v_split_number, v_book_type_code, v_asset_id,
               v_IMP_LOSS_AMOUNT,V_SPLIT_IMPAIR_FLAG,
               v_reverse_imp_amt, v_mass_reval_id, v_imp_impact,
               v_imp_deprn_effect, v_calc_imp_loss_amount, v_calc_imp_impact,
               v_calc_imp_deprn_effect, v_impair_loss_acct, v_category_id,
               v_reval_reserve_impact_flag, v_reval_rsv_adj_amount,
               v_impair_class, v_reason;

         -- v_reverse_imp_amt is Unused Imairment amount i.e impairment amount - prior reval reversals
         -- v_imp_deprn_effect is deprn impact due to impairment amount
         -- v_imp_impact = (v_reverse_imp_amt - v_imp_deprn_effect)

         -- v_calc_imp_loss_amount = I/E Impairment amount
         -- v_calc_imp_deprn_effect = depreciation impact on the I/E
         -- v_calc_imp_impact = (v_calc_imp_loss_amount - v_calc_imp_deprn_effect)
         /*Bug#7392015 - Call to calculate deprn effect for double dd depreciation nmehtod */
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.ADD ('fa_sorp_link_reval', 'before calling ', 'fa_sorp_link_reval_dd', p_log_level_rec => p_log_level_rec);
         end if;
         if NOT fa_sorp_link_reval_dd(p_mass_reval_id,
                                      v_asset_id,
                                      v_book_type_code,
                                      v_impairment_id,
                                      v_reverse_imp_amt,
				      p_mrc_sob_type_code,
				      p_set_of_books_id,
                                      x_deprn_rsv,
                                      x_impairment_amt,
                                      x_impair_split_flag,
                                      x_override_flag) THEN
            fa_debug_pkg.ADD ('fa_sorp_link_reval', 'failed calling ', 'fa_sorp_link_reval_dd', p_log_level_rec => p_log_level_rec);
         END IF;
         if (p_log_level_rec.statement_level) then
            fa_debug_pkg.ADD ('fa_sorp_link_reval', 'deprn reserve from fa_sorp_link_reval_dd :',x_deprn_rsv, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fa_sorp_link_reval', 'x_impairment_amt from fa_sorp_link_reval_dd :',x_impairment_amt, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fa_sorp_link_reval', 'x_impair_split_flag from fa_sorp_link_reval_dd :',x_impair_split_flag, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fa_sorp_link_reval', 'x_override_flag from fa_sorp_link_reval_dd :',x_override_flag, p_log_level_rec => p_log_level_rec);
        end if;

        /* if x_override_flag is 'YES' reset values calculated by existing cursor*/
        if nvl(x_override_flag,'NO')='YES' then
           if(V_SPLIT_IMPAIR_FLAG = 'NO') then
              v_imp_deprn_effect := x_deprn_rsv;
              v_imp_impact := v_reverse_imp_amt - x_deprn_rsv;
              if v_calc_imp_loss_amount <> 0 then
                 v_calc_imp_deprn_effect := x_deprn_rsv;
                 if v_reverse_imp_amt <> v_IMP_LOSS_AMOUNT then
                    v_calc_imp_deprn_effect :=  (x_deprn_rsv * v_reverse_imp_amt)/v_IMP_LOSS_AMOUNT;
                    v_calc_imp_deprn_effect := round(v_calc_imp_deprn_effect,2);
                 end if;
               end if;
               v_calc_imp_impact  := v_calc_imp_loss_amount - v_calc_imp_deprn_effect;
           else
              if v_calc_imp_loss_amount <> 0 then
                 v_calc_imp_deprn_effect := x_deprn_rsv;
                 v_calc_imp_impact := v_calc_imp_loss_amount - v_calc_imp_deprn_effect;
               end if;
              if v_IMP_LOSS_AMOUNT <> v_reverse_imp_amt then
                  x_deprn_rsv := (x_deprn_rsv * v_IMP_LOSS_AMOUNT)/v_reverse_imp_amt;
                  x_deprn_rsv :=round(x_deprn_rsv,2);
              end if;
              v_imp_deprn_effect := x_deprn_rsv;
              v_imp_impact := v_reverse_imp_amt - x_deprn_rsv;
           end if;
         end if;

         IF v_reverse_imp_amt < l_adj_amt -- Start v_reverse_imp_amt < l_adj_amt
         THEN
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'v_reverse_imp_amt < l_adj_amt',
                              v_reverse_imp_amt < l_adj_amt
                             , p_log_level_rec => p_log_level_rec);
            v_temp_imp_impact := NVL (v_temp_imp_impact, 0) + v_imp_impact;
            v_temp_imp_deprn_effect := v_imp_deprn_effect;
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'v_temp_imp_impact',
                              v_temp_imp_impact
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'v_temp_imp_deprn_effect',
                              v_temp_imp_deprn_effect
                             , p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fa_sorp_link_reval', 'l_adj_amt', l_adj_amt, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'v_calc_imp_impact',
                              v_calc_imp_impact
                             , p_log_level_rec => p_log_level_rec);
            l_reval_gain := l_adj_amt - v_calc_imp_impact;
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'v_reverse_imp_amt < l_adj_amt',
                              v_reverse_imp_amt < l_adj_amt
                             , p_log_level_rec => p_log_level_rec);
            x_reval_rsv_deprn_effect := 0;

            IF v_reval_reserve_impact_flag = 'Y'
            THEN
               IF l_reval_gain < v_reval_rsv_adj_amount
               THEN
                  l_reval_rsv_deprn_effect :=
                     ROUND ((l_reval_gain / v_imp_impact) * v_imp_deprn_effect,
                            2
                           );
                  l_reverse_rsv_amount := ROUND (l_reval_gain, 2);
               ELSIF l_reval_gain >= v_reval_rsv_adj_amount
               THEN
                  l_reverse_rsv_amount := v_reval_rsv_adj_amount;
                  l_reval_rsv_deprn_effect :=
                     fa_imp_deprn_eff_fn (v_impairment_id,
                                          v_book_type_code,
                                          v_asset_id,
                                          'R',
                                          l_reverse_rsv_amount
                                         );
                  l_reverse_rsv_amount :=
                             v_reval_rsv_adj_amount - l_reval_rsv_deprn_effect;
               END IF;

               x_reval_rsv_deprn_effect := l_reval_rsv_deprn_effect;
            ELSE
               l_reverse_rsv_amount := 0;
               l_reval_rsv_deprn_effect := 0;
            END IF;

            -- Assigning values from local varibales to out parameters
            x_imp_loss_impact := v_temp_imp_impact;
            x_reval_gain := l_reval_gain;
            x_temp_imp_deprn_effect := v_temp_imp_deprn_effect;
            x_impair_loss_acct := v_impair_loss_acct;

            INSERT INTO fa_sorp_link_reval_itf
                        (request_id, mass_reval_id, asset_id,
                         category_id, book_type_code,
                         impairment_id,
                         split_number, impairment_loss_amount,
                         impair_loss_impact, impair_loss_acct,
                         imp_deprn_effect, run_mode,
                         reval_reserve_impact_flag, impair_class_type,
                         reason,
                         calc_imp_amount,
                         calc_imp_deprn_effect,
                         reval_rsv_adj_amount,
                         reval_rsv_adj_deprn_effect,
                         calc_imp_reverse_amt,
                         calc_imp_reverse_deprn_effect,
                         rsv_reverse_amt,
                         rsv_reverse_deprn_effect,
                         reval_gain,
                         created_by,
                         creation_date
                        )
                 VALUES (p_request_id, v_mass_reval_id, v_asset_id,
                         v_category_id, v_book_type_code,
                         fa_sorp_process_imp_id_fn (v_impairment_id),
                         v_split_number, v_reverse_imp_amt,
                         v_imp_impact, v_impair_loss_acct,
                         v_imp_deprn_effect, p_run_mode,
                         v_reval_reserve_impact_flag, v_impair_class,
                         v_reason,
                         v_calc_imp_impact,
                         v_calc_imp_deprn_effect,
                         v_reval_rsv_adj_amount,
                         l_reval_rsv_deprn_effect,
                         v_calc_imp_impact,  -- calc_imp_reverse_amt - calculated impairment amount to be reversed
                         v_calc_imp_deprn_effect,  -- calc_imp_reverse_deprn_effect - calulated deprn impact due to calculated impairment amount
                         l_reverse_rsv_amount, -- rsv_reverse_amt - Reval Reserve Adjustment amount to be reversed
                         l_reval_rsv_deprn_effect, -- rsv_reverse_deprn_effect - deprn impact due to Reval Reserve Adjustment amount to be reversed
                         l_reval_gain,  -- reval_gain - Revaluation Gain
                         '-1',
                         SYSDATE
                        );

            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'Adjustment(Delta) Amount(A)',
                              p_adj_amt
                             );
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'Impairment Loss Impact(B)',
                              v_temp_imp_impact
                             );
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'Reval Gain(C)',
                              l_reval_gain
                             );
         -- If v_sum is greater than or equal to adjustment amount
         ELSIF v_reverse_imp_amt >= l_adj_amt
         THEN
                                fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'v_reverse_imp_amt >= l_adj_amt',
                              'v_reverse_imp_amt >= l_adj_amt'
                             , p_log_level_rec => p_log_level_rec);
            -- Bug#7524125
            IF l_adj_amt < v_calc_imp_impact
            THEN
                               fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'l_adj_amt <  v_calc_imp_impact',
                              'l_adj_amt <  v_calc_imp_impact'
                             , p_log_level_rec => p_log_level_rec);

               l_new_reverse_amt := l_adj_amt;
               v_temp_imp_deprn_effect := round(((l_adj_amt*v_imp_deprn_effect)/v_imp_impact),2);
             /*   l_new_reverse_amt :=
                           NVL (l_new_reverse_amt, 0)
                           - v_temp_imp_deprn_effect; */
               l_reval_gain :=0;
               l_reval_gain_temp := 0;
            ELSIF l_adj_amt >=  v_calc_imp_impact
            THEN
                               fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'l_adj_amt >=  v_calc_imp_impact',
                              'l_adj_amt >=  v_calc_imp_impact'
                             , p_log_level_rec => p_log_level_rec);
               l_new_reverse_amt :=
                                NVL (l_new_reverse_amt, 0)
                                + v_calc_imp_impact;
               v_temp_imp_deprn_effect :=  v_calc_imp_deprn_effect;

               l_reval_gain := 0;
            END IF;

            x_reval_rsv_deprn_effect := 0;

            --Commented for Bug#7524125

            IF v_reval_reserve_impact_flag = 'Y' and l_adj_amt > v_calc_imp_impact
            THEN
               /* IF l_reval_gain < v_reval_rsv_adj_amount
               THEN
                  l_reval_rsv_deprn_effect :=
                     ROUND ((l_reval_gain / v_imp_impact) * v_imp_deprn_effect,
                            2
                           );
                  l_reverse_rsv_amount := ROUND (l_reval_gain, 2);
               ELSIF l_reval_gain >= v_reval_rsv_adj_amount
               THEN */
                  l_temp_reverse_rsv_amount :=v_reval_rsv_adj_amount;

                fa_debug_pkg.ADD ('fa_sorp_link_reval','first time l_temp_reverse_rsv_amount',l_temp_reverse_rsv_amount, p_log_level_rec => p_log_level_rec);

                  l_temp_reval_rsv_deprn_effect :=
                     fa_imp_deprn_eff_fn (v_impairment_id,
                                          v_book_type_code,
                                          v_asset_id,
                                          'R',
                                          l_temp_reverse_rsv_amount
                                         );

                                fa_debug_pkg.ADD ('fa_sorp_link_reval','l_temp_reval_rsv_deprn_effect',l_temp_reval_rsv_deprn_effect, p_log_level_rec => p_log_level_rec);

                  l_temp_reverse_rsv_amount := nvl(l_temp_reverse_rsv_amount,0) - nvl(l_temp_reval_rsv_deprn_effect,0);

                                fa_debug_pkg.ADD ('fa_sorp_link_reval','second time l_temp_reverse_rsv_amount',l_temp_reverse_rsv_amount, p_log_level_rec => p_log_level_rec);

                 if l_temp_reverse_rsv_amount > l_adj_amt - v_calc_imp_impact then

                        l_reverse_rsv_amount := l_adj_amt-v_calc_imp_impact;

                                fa_debug_pkg.ADD ('fa_sorp_link_reval','l_reverse_rsv_amount',l_reverse_rsv_amount, p_log_level_rec => p_log_level_rec);

                        l_reval_rsv_deprn_effect := round((l_reverse_rsv_amount*nvl(l_temp_reval_rsv_deprn_effect,0))/l_temp_reverse_rsv_amount,2);

                                fa_debug_pkg.ADD ('fa_sorp_link_reval','l_reval_rsv_deprn_effect',l_reval_rsv_deprn_effect, p_log_level_rec => p_log_level_rec);
                else
                        l_reverse_rsv_amount := l_temp_reverse_rsv_amount;
                        l_reval_rsv_deprn_effect := l_temp_reval_rsv_deprn_effect;

                 end if;
               --END IF;


               x_reval_rsv_deprn_effect := l_reval_rsv_deprn_effect;
            ELSE
               l_reverse_rsv_amount := 0;
               l_reval_rsv_deprn_effect := 0;
               x_reval_rsv_deprn_effect := 0;
            END IF;

           /*  IF NVL (l_reval_gain_temp, 0) <> 0
            THEN
               l_reval_gain := l_reval_gain_temp;
            END IF;*/

            -- Assigning values from local varibales to out parameters
            x_imp_loss_impact := l_new_reverse_amt;
            x_reval_gain := l_reval_gain;
            x_temp_imp_deprn_effect := v_temp_imp_deprn_effect;
            x_impair_loss_acct := v_impair_loss_acct;

            INSERT INTO fa_sorp_link_reval_itf
                        (request_id, mass_reval_id, asset_id,
                         category_id, book_type_code,
                         impairment_id,
                         split_number, impairment_loss_amount,
                         impair_loss_impact, impair_loss_acct,
                         imp_deprn_effect, run_mode,
                         reval_reserve_impact_flag, impair_class_type,
                         reason,
                         calc_imp_amount,
                         calc_imp_deprn_effect,
                         reval_rsv_adj_amount,
                         reval_rsv_adj_deprn_effect,
                         calc_imp_reverse_amt,
                         calc_imp_reverse_deprn_effect,
                         rsv_reverse_amt,
                         rsv_reverse_deprn_effect,
                         reval_gain,
                         created_by,
                         creation_date
                        )
                 VALUES (p_request_id, v_mass_reval_id, v_asset_id,
                         v_category_id, v_book_type_code,
                         fa_sorp_process_imp_id_fn (v_impairment_id),
                         v_split_number, v_reverse_imp_amt,
                         v_imp_impact, v_impair_loss_acct,
                         v_imp_deprn_effect, p_run_mode,
                         v_reval_reserve_impact_flag, v_impair_class,
                         v_reason,
                         v_calc_imp_impact,
                         v_calc_imp_deprn_effect,
                         v_reval_rsv_adj_amount,
                         l_reval_rsv_deprn_effect,
                         l_new_reverse_amt, -- calc_imp_reverse_amt - calculated impairment amount to be reversed
                         v_temp_imp_deprn_effect,  -- calc_imp_reverse_deprn_effect - calulated deprn impact due to calculated impairment amount
                         l_reverse_rsv_amount, -- rsv_reverse_amt - Reval Reserve Adjustment amount to be reversed
                         l_reval_rsv_deprn_effect, -- rsv_reverse_deprn_effect - deprn impact due to Reval Reserve Adjustment amount to be reversed
                         l_reval_gain,  -- reval_gain - Revaluation Gain
                         '-1',
                         SYSDATE
                        );
         END IF; -- End v_reverse_imp_amt < l_adj_amt

         CLOSE c_asset_cur; -- End Asset cur

         fa_debug_pkg.ADD ('fa_sorp_link_reval',
                           'Adjustment(Delta) Amount(A)',
                           p_adj_amt
                          );
         fa_debug_pkg.ADD ('fa_sorp_link_reval',
                           'Impairment Loss Impact(B)',
                           l_new_reverse_amt
                          );
         fa_debug_pkg.ADD ('fa_sorp_link_reval', 'Reval Gain(C)',
                           l_reval_gain);
      END IF;

      IF p_reval_type = 'C'
      THEN
         OPEN c_cat_cur;

         FETCH c_cat_cur
          INTO v_impairment_id, v_split_number, v_book_type_code, v_asset_id,
               v_reverse_imp_amt, v_mass_reval_id, v_imp_impact,
               v_imp_deprn_effect, v_calc_imp_loss_amount, v_calc_imp_impact,
               v_calc_imp_deprn_effect, v_reval_rsv_adj_amount,
               v_impair_loss_acct, v_category_id,
               v_reval_reserve_impact_flag, v_impair_class, v_reason;

         /*Bug#7392015 - Call to calculate deprn effect for double dd depreciation nmehtod */
         if v_impairment_id is not null then
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.ADD ('fa_sorp_link_reval', 'before calling ', 'fa_sorp_link_reval_dd', p_log_level_rec => p_log_level_rec);
            end if;
            if NOT fa_sorp_link_reval_dd(p_mass_reval_id,
                                      v_asset_id,
                                      v_book_type_code,
                                      v_impairment_id,
                                      v_reverse_imp_amt,
				      p_mrc_sob_type_code,
				      p_set_of_books_id,
                                      x_deprn_rsv,
                                      x_impairment_amt,
                                      x_impair_split_flag,
                                      x_override_flag) THEN
               fa_debug_pkg.ADD ('fa_sorp_link_reval', 'failed calling ', 'fa_sorp_link_reval_dd', p_log_level_rec => p_log_level_rec);
            END IF;
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.ADD ('fa_sorp_link_reval', 'deprn reserve from fa_sorp_link_reval_dd :',x_deprn_rsv, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD ('fa_sorp_link_reval', 'x_impairment_amt from fa_sorp_link_reval_dd :',x_impairment_amt, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD ('fa_sorp_link_reval', 'x_impair_split_flag from fa_sorp_link_reval_dd :',x_impair_split_flag, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.ADD ('fa_sorp_link_reval', 'x_override_flag from fa_sorp_link_reval_dd :',x_override_flag, p_log_level_rec => p_log_level_rec);
            end if;
            if nvl(x_override_flag,'NO')='YES' then
               if nvl(x_impair_split_flag,'NO') = 'NO' then
                  v_imp_deprn_effect := x_deprn_rsv;
                  v_imp_impact :=  v_reverse_imp_amt - v_imp_deprn_effect;
                  v_calc_imp_deprn_effect := x_deprn_rsv;
                  if (x_impairment_amt <> 0) then
                     v_calc_imp_deprn_effect := round((x_deprn_rsv * v_reverse_imp_amt)/x_impairment_amt,2);
                     fa_debug_pkg.ADD ('fa_sorp_link_reval', 'v_calc_imp_deprn_effect from fa_sorp_link_reval_dd :',v_calc_imp_deprn_effect, p_log_level_rec => p_log_level_rec);
                  end if;
                  v_calc_imp_impact  := v_calc_imp_loss_amount - v_calc_imp_deprn_effect;
               elsif x_impair_split_flag = 'YES' then
                  v_calc_imp_deprn_effect := x_deprn_rsv;
                  v_calc_imp_impact  := v_calc_imp_loss_amount - v_calc_imp_deprn_effect;
                  v_imp_deprn_effect := x_deprn_rsv;
                  if (x_impairment_amt <> 0) then
                     v_imp_deprn_effect := round((x_deprn_rsv * x_impairment_amt)/v_reverse_imp_amt,2);
                     fa_debug_pkg.ADD ('fa_sorp_link_reval', 'v_imp_deprn_effect from fa_sorp_link_reval_dd :',v_imp_deprn_effect, p_log_level_rec => p_log_level_rec);
                  end if;
                  v_imp_impact :=  v_reverse_imp_amt - v_imp_deprn_effect;
               end if;
            end if; --nvl(x_override_flag,'NO')='YES'
         end if; --v_impairment_id is not null
        /*Bug#7392015 changes ends*/

        IF v_reverse_imp_amt < l_adj_amt
         THEN
            v_temp_imp_impact := NVL (v_temp_imp_impact, 0) + v_imp_impact;
            v_temp_imp_deprn_effect := v_imp_deprn_effect;
            l_reval_gain := l_adj_amt - v_calc_imp_impact;
            x_reval_rsv_deprn_effect := 0;

            IF v_reval_reserve_impact_flag = 'Y'
            THEN
               IF l_reval_gain < v_reval_rsv_adj_amount
               THEN
                  l_reval_rsv_deprn_effect :=
                     ROUND ((l_reval_gain / v_imp_impact) * v_imp_deprn_effect,
                            2
                           );
                  l_reverse_rsv_amount := ROUND (l_reval_gain, 2);
               ELSIF l_reval_gain >= v_reval_rsv_adj_amount
               THEN
                  l_reverse_rsv_amount := v_reval_rsv_adj_amount;
                  l_reval_rsv_deprn_effect :=
                     fa_imp_deprn_eff_fn (v_impairment_id,
                                          v_book_type_code,
                                          v_asset_id,
                                          'R',
                                          l_reverse_rsv_amount
                                         );
                  l_reverse_rsv_amount :=
                             v_reval_rsv_adj_amount - l_reval_rsv_deprn_effect;
               END IF;

               x_reval_rsv_deprn_effect := l_reval_rsv_deprn_effect;
            ELSE
               l_reverse_rsv_amount := 0;
               l_reval_rsv_deprn_effect := 0;
            END IF;

            -- Assigning values from local varibales to out parameters
            x_imp_loss_impact := v_temp_imp_impact;
            x_reval_gain := l_reval_gain;
            x_temp_imp_deprn_effect := v_temp_imp_deprn_effect;
            x_impair_loss_acct := v_impair_loss_acct;

            INSERT INTO fa_sorp_link_reval_itf
                        (request_id, mass_reval_id, asset_id,
                         category_id, book_type_code,
                         impairment_id,
                         split_number, impairment_loss_amount,
                         impair_loss_impact, impair_loss_acct,
                         imp_deprn_effect, run_mode,
                         reval_reserve_impact_flag, impair_class_type,
                         reason,
                         calc_imp_amount,
                         calc_imp_deprn_effect,
                         reval_rsv_adj_amount,
                         reval_rsv_adj_deprn_effect,
                         calc_imp_reverse_amt,
                         calc_imp_reverse_deprn_effect,
                         rsv_reverse_amt,
                         rsv_reverse_deprn_effect,
                         reval_gain, created_by,
                         creation_date
                        )
                 VALUES (p_request_id, v_mass_reval_id, v_asset_id,
                         v_category_id, v_book_type_code,
                         fa_sorp_process_imp_id_fn (v_impairment_id),
                         v_split_number, v_reverse_imp_amt,
                         v_imp_impact, v_impair_loss_acct,
                         v_imp_deprn_effect, p_run_mode,
                         v_reval_reserve_impact_flag, v_impair_class,
                         v_reason,
                         v_calc_imp_impact,
                         v_calc_imp_deprn_effect,
                         v_reval_rsv_adj_amount,
                         l_reval_rsv_deprn_effect,
                         v_calc_imp_impact, -- calc_imp_reverse_amt - calculated impairment amount to be reversed
                         v_temp_imp_deprn_effect, -- calc_imp_reverse_deprn_effect - calulated deprn impact due to calculated impairment amount
                         l_reverse_rsv_amount,-- rsv_reverse_amt - Reval Reserve Adjustment amount to be reversed
                         l_reval_rsv_deprn_effect,  -- rsv_reverse_deprn_effect - deprn impact due to Reval Reserve Adjustment amount to be reversed
                         l_reval_gain, -- reval_gain - Revaluation Gain
                         '-1',
                         SYSDATE
                        );

            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'Adjustment(Delta) Amount(A)',
                              p_adj_amt
                             );
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'Impairment Loss Impact(B)',
                              v_calc_imp_impact
                             );
            fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'Reval Gain(C)',
                              l_reval_gain
                             );
        ELSIF v_reverse_imp_amt >= l_adj_amt
         THEN
                                fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'v_reverse_imp_amt >= l_adj_amt',
                              'v_reverse_imp_amt >= l_adj_amt'
                             , p_log_level_rec => p_log_level_rec);
            -- Bug#7524125
            IF l_adj_amt <  v_calc_imp_impact
            THEN
                               fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'l_adj_amt <  v_calc_imp_impact',
                              'l_adj_amt <  v_calc_imp_impact'
                             , p_log_level_rec => p_log_level_rec);

               l_new_reverse_amt := l_adj_amt;
               v_temp_imp_deprn_effect := round(((l_adj_amt*v_imp_deprn_effect)/v_imp_impact),2);
             /*   l_new_reverse_amt :=
                           NVL (l_new_reverse_amt, 0)
                           - v_temp_imp_deprn_effect; */
               l_reval_gain :=0;
               l_reval_gain_temp := 0;
            ELSIF l_adj_amt >=  v_calc_imp_impact
            THEN
                               fa_debug_pkg.ADD ('fa_sorp_link_reval',
                              'l_adj_amt >=  v_calc_imp_impact',
                              'l_adj_amt >=  v_calc_imp_impact'
                             , p_log_level_rec => p_log_level_rec);
               l_new_reverse_amt :=
                                NVL (l_new_reverse_amt, 0)
                                + v_calc_imp_impact;
               v_temp_imp_deprn_effect :=  v_calc_imp_deprn_effect;

               l_reval_gain := 0;
            END IF;

            x_reval_rsv_deprn_effect := 0;

            --Commented for Bug#7524125

            IF v_reval_reserve_impact_flag = 'Y' and l_adj_amt > v_calc_imp_impact
            THEN
               /* IF l_reval_gain < v_reval_rsv_adj_amount
               THEN
                  l_reval_rsv_deprn_effect :=
                     ROUND ((l_reval_gain / v_imp_impact) * v_imp_deprn_effect,
                            2
                           );
                  l_reverse_rsv_amount := ROUND (l_reval_gain, 2);
               ELSIF l_reval_gain >= v_reval_rsv_adj_amount
               THEN */
                  l_temp_reverse_rsv_amount :=v_reval_rsv_adj_amount;

                fa_debug_pkg.ADD ('fa_sorp_link_reval','first time l_temp_reverse_rsv_amount',l_temp_reverse_rsv_amount, p_log_level_rec => p_log_level_rec);

                  l_temp_reval_rsv_deprn_effect :=
                     fa_imp_deprn_eff_fn (v_impairment_id,
                                          v_book_type_code,
                                          v_asset_id,
                                          'R',
                                          l_temp_reverse_rsv_amount
                                         );

                                fa_debug_pkg.ADD ('fa_sorp_link_reval','l_temp_reval_rsv_deprn_effect',l_temp_reval_rsv_deprn_effect, p_log_level_rec => p_log_level_rec);

                  l_temp_reverse_rsv_amount := nvl(l_temp_reverse_rsv_amount,0) - nvl(l_temp_reval_rsv_deprn_effect,0);

                                fa_debug_pkg.ADD ('fa_sorp_link_reval','second time l_temp_reverse_rsv_amount',l_temp_reverse_rsv_amount, p_log_level_rec => p_log_level_rec);

                 if l_temp_reverse_rsv_amount > l_adj_amt - v_calc_imp_impact then

                        l_reverse_rsv_amount := l_adj_amt-v_calc_imp_impact;

                                fa_debug_pkg.ADD ('fa_sorp_link_reval','l_reverse_rsv_amount',l_reverse_rsv_amount, p_log_level_rec => p_log_level_rec);

                        l_reval_rsv_deprn_effect := round((l_reverse_rsv_amount*nvl(l_temp_reval_rsv_deprn_effect,0))/l_temp_reverse_rsv_amount,2);

                                fa_debug_pkg.ADD ('fa_sorp_link_reval','l_reval_rsv_deprn_effect',l_reval_rsv_deprn_effect, p_log_level_rec => p_log_level_rec);
                else
                        l_reverse_rsv_amount := l_temp_reverse_rsv_amount;
                        l_reval_rsv_deprn_effect := l_temp_reval_rsv_deprn_effect;

                 end if;
               --END IF;


               x_reval_rsv_deprn_effect := l_reval_rsv_deprn_effect;
            ELSE
               l_reverse_rsv_amount := 0;
               l_reval_rsv_deprn_effect := 0;
               x_reval_rsv_deprn_effect := 0;
            END IF;

           /*  IF NVL (l_reval_gain_temp, 0) <> 0
            THEN
               l_reval_gain := l_reval_gain_temp;
            END IF;*/

            -- Assigning values from local varibales to out parameters
            x_imp_loss_impact := l_new_reverse_amt;
            x_reval_gain := l_reval_gain;
            x_temp_imp_deprn_effect := v_temp_imp_deprn_effect;
            x_impair_loss_acct := v_impair_loss_acct;

            INSERT INTO fa_sorp_link_reval_itf
                        (request_id, mass_reval_id, asset_id,
                         category_id, book_type_code,
                         impairment_id,
                         split_number, impairment_loss_amount,
                         impair_loss_impact, impair_loss_acct,
                         imp_deprn_effect, run_mode,
                         reval_reserve_impact_flag, impair_class_type,
                         reason,
                         calc_imp_amount,
                         calc_imp_deprn_effect,
                         reval_rsv_adj_amount,
                         reval_rsv_adj_deprn_effect,
                         calc_imp_reverse_amt,
                         calc_imp_reverse_deprn_effect,
                         rsv_reverse_amt,
                         rsv_reverse_deprn_effect,
                         reval_gain,
                         created_by,
                         creation_date
                        )
                 VALUES (p_request_id, v_mass_reval_id, v_asset_id,
                         v_category_id, v_book_type_code,
                         fa_sorp_process_imp_id_fn (v_impairment_id),
                         v_split_number, v_reverse_imp_amt,
                         v_imp_impact, v_impair_loss_acct,
                         v_imp_deprn_effect, p_run_mode,
                         v_reval_reserve_impact_flag, v_impair_class,
                         v_reason,
                         v_calc_imp_impact,
                         v_calc_imp_deprn_effect,
                         v_reval_rsv_adj_amount,
                         l_reval_rsv_deprn_effect,
                         l_new_reverse_amt, -- calc_imp_reverse_amt - calculated impairment amount to be reversed
                         v_temp_imp_deprn_effect, -- calc_imp_reverse_deprn_effect - calulated deprn impact due to calculated impairment amount
                         l_reverse_rsv_amount,-- rsv_reverse_amt - Reval Reserve Adjustment amount to be reversed
                         l_reval_rsv_deprn_effect, -- rsv_reverse_deprn_effect - deprn impact due to Reval Reserve Adjustment amount to be reversed
                         l_reval_gain,  -- reval_gain - Revaluation Gain
                         '-1',
                         SYSDATE
                        );
         END IF;

         CLOSE c_cat_cur;

         fa_debug_pkg.ADD ('fa_sorp_link_reval',
                           'Adjustment(Delta) Amount(A)',
                           p_adj_amt
                          );
         fa_debug_pkg.ADD ('fa_sorp_link_reval',
                           'Impairment Loss Impact(B)',
                           l_new_reverse_amt
                          );
         fa_debug_pkg.ADD ('fa_sorp_link_reval', 'Reval Gain(C)',
                           l_reval_gain);
      END IF;

      fa_debug_pkg.ADD ('fa_sorp_link_reval', 'End', 'End', p_log_level_rec => p_log_level_rec);
   END fa_sorp_link_reval;

/* Procedure updates FA_ITF_IMPAIRMENTS with reversed amounts

*/
   PROCEDURE fa_imp_itf_upd (
      p_request_id         NUMBER,
      p_book_type_code     VARCHAR2,
      p_asset_id           NUMBER,
      p_last_updated_by    NUMBER,
      p_last_update_date   DATE
   , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
   IS
      CURSOR c_reval_link_itf_cur
      IS
         SELECT impairment_id, split_number, calc_imp_reverse_amt,
                calc_imp_reverse_deprn_effect, rsv_reverse_amt,
                rsv_reverse_deprn_effect
           FROM fa_sorp_link_reval_itf
          WHERE request_id = p_request_id
            AND book_type_code = p_book_type_code
            AND asset_id = p_asset_id
            AND run_mode = 'RUN';

      v_impairment_id               NUMBER;
      v_split_number                NUMBER;
      v_calc_imp_reverse_amt        NUMBER;
      v_calc_imp_rev_deprn_effect   NUMBER;
      v_rsv_reverse_amt             NUMBER;
      v_rsv_reverse_deprn_effect    NUMBER;
   BEGIN
      OPEN c_reval_link_itf_cur;

      LOOP
         FETCH c_reval_link_itf_cur
          INTO v_impairment_id, v_split_number, v_calc_imp_reverse_amt,
               v_calc_imp_rev_deprn_effect, v_rsv_reverse_amt,
               v_rsv_reverse_deprn_effect;

         EXIT WHEN c_reval_link_itf_cur%NOTFOUND;

         IF NVL (v_split_number, 0) = 0
         THEN
            IF NVL (v_calc_imp_reverse_amt, 0) <> 0
            THEN
               UPDATE fa_itf_impairments
                  SET reversed_imp_amt = nvl(reversed_imp_amt,0)+v_calc_imp_reverse_amt,
                      reversed_deprn_impact = nvl(reversed_deprn_impact,0)+v_calc_imp_rev_deprn_effect,
                      last_updated_by = p_last_updated_by,
                      last_update_date = p_last_update_date
                WHERE impairment_id = v_impairment_id;
            END IF;

            IF NVL (v_rsv_reverse_amt, 0) <> 0
            THEN
               UPDATE fa_itf_impairments
                  SET reversed_reval_amt = nvl(reversed_reval_amt,0)+v_rsv_reverse_amt,
                      reversed_reval_impact = nvl(reversed_reval_impact,0)+v_rsv_reverse_deprn_effect,
                      last_updated_by = p_last_updated_by,
                      last_update_date = p_last_update_date
                WHERE impairment_id = v_impairment_id;
            END IF;
         ELSIF NVL (v_split_number, 0) = 1
         THEN
            IF NVL (v_calc_imp_reverse_amt, 0) <> 0
            THEN
               UPDATE fa_itf_impairments
                  SET reversed_imp_amt_s1 = nvl(reversed_imp_amt_s1,0)+v_calc_imp_reverse_amt,
                      reversed_deprn_impact_s1 = nvl(reversed_deprn_impact_s1,0)+v_calc_imp_rev_deprn_effect,
                      last_updated_by = p_last_updated_by,
                      last_update_date = p_last_update_date
                WHERE impairment_id = v_impairment_id;
            END IF;

            IF NVL (v_rsv_reverse_amt, 0) <> 0
            THEN
               UPDATE fa_itf_impairments
                  SET reversed_reval_amt_s1 = nvl(reversed_reval_amt_s1,0)+v_rsv_reverse_amt,
                      reversed_reval_impact_s1 = nvl(reversed_reval_impact_s1,0)+v_rsv_reverse_deprn_effect,
                      last_updated_by = p_last_updated_by,
                      last_update_date = p_last_update_date
                WHERE impairment_id = v_impairment_id;
            END IF;
         ELSIF NVL (v_split_number, 0) = 2
         THEN
            IF NVL (v_calc_imp_reverse_amt, 0) <> 0
            THEN
               UPDATE fa_itf_impairments
                  SET reversed_imp_amt_s2 = nvl(reversed_imp_amt_s2,0)+v_calc_imp_reverse_amt,
                      reversed_deprn_impact_s2 = nvl(reversed_deprn_impact_s2,0)+v_calc_imp_rev_deprn_effect,
                      last_updated_by = p_last_updated_by,
                      last_update_date = p_last_update_date
                WHERE impairment_id = v_impairment_id;
            END IF;

            IF NVL (v_rsv_reverse_amt, 0) <> 0
            THEN
               UPDATE fa_itf_impairments
                  SET reversed_reval_amt_s2 = nvl(reversed_reval_amt_s2,0)+v_rsv_reverse_amt,
                      reversed_reval_impact_s2 = nvl(reversed_reval_impact_s2,0)+v_rsv_reverse_deprn_effect,
                      last_updated_by = p_last_updated_by,
                      last_update_date = p_last_update_date
                WHERE impairment_id = v_impairment_id;
            END IF;
         ELSIF NVL (v_split_number, 0) = 3
         THEN
            IF NVL (v_calc_imp_reverse_amt, 0) <> 0
            THEN
               UPDATE fa_itf_impairments
                  SET reversed_imp_amt_s3 = nvl(reversed_imp_amt_s3,0)+v_calc_imp_reverse_amt,
                      reversed_deprn_impact_s3 = nvl(reversed_deprn_impact_s3,0)+v_calc_imp_rev_deprn_effect,
                      last_updated_by = p_last_updated_by,
                      last_update_date = p_last_update_date
                WHERE impairment_id = v_impairment_id;
            END IF;

            IF NVL (v_rsv_reverse_amt, 0) <> 0
            THEN
               UPDATE fa_itf_impairments
                  SET reversed_reval_amt_s3 = nvl(reversed_reval_amt_s3,0)+v_rsv_reverse_amt,
                      reversed_reval_impact_s3 = nvl(reversed_reval_impact_s3,0)+v_rsv_reverse_deprn_effect,
                      last_updated_by = p_last_updated_by,
                      last_update_date = p_last_update_date
                WHERE impairment_id = v_impairment_id;
            END IF;
         END IF;
      END LOOP;

      CLOSE c_reval_link_itf_cur;
   END fa_imp_itf_upd;
END fa_sorp_revaluation_pkg;

/
