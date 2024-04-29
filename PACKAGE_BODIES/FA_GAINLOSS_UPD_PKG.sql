--------------------------------------------------------
--  DDL for Package Body FA_GAINLOSS_UPD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GAINLOSS_UPD_PKG" AS
/* $Header: fagupdb.pls 120.79.12010000.27 2010/03/19 14:16:43 mswetha ship $*/


/*============================================================================
| NAME        faginfo
|
| FUNCTION   Set selection_mode accordingly for Tax book
|
|
| History     YYOON          05/23/06         Created
|                            added for the bug 5149832 and 5231996
|===========================================================================*/


Function faginfo(
        RET                 IN fa_ret_types.ret_struct,
        BK                  IN fa_ret_types.book_struct,
        cpd_ctr             IN NUMBER,
        today               IN DATE,
        user_id             IN NUMBER,
        calling_module      IN  varchar,
        candidate_mode      IN  varchar,
        set_adj_row         IN  boolean,
        unit_ret_in_corp    OUT nocopy boolean,
        ret_id_in_corp      OUT nocopy number,
        th_id_out_in_corp   OUT nocopy number,
        balance_tfr_in_tax  OUT nocopy number,
        adj_row             IN  OUT nocopy FA_ADJUST_TYPE_PKG.fa_adj_row_struct,
        p_log_level_rec     IN  FA_API_TYPES.log_level_rec_type) return boolean IS

    l_unit_ret_in_corp    boolean;
    l_ret_id_in_corp      number;
    l_id_out              number;
    l_selection_retid     number;
    l_units_retired       number;
    l_balance_tfr_in_tax  number;

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UPD_PKG.faginfo';

    faginfo_error       EXCEPTION;

BEGIN

   if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn, '++++++++++++++++++++++++', '...', p_log_level_rec => p_log_level_rec);
      fa_debug_pkg.add(l_calling_fn, '++ CALLED BY ', calling_module, p_log_level_rec => p_log_level_rec);
   end if;

   if candidate_mode in ('RETIRE', 'CLEAR_PARTIAL') then

          l_id_out := -1;

          begin

               select r.retirement_id
                     ,r.units
                 into l_ret_id_in_corp
                     ,l_units_retired
               from fa_transaction_headers sth
                   ,fa_retirements r
                   ,fa_book_controls bc
               where sth.transaction_header_id = RET.th_id_in
                 and sth.asset_id = RET.asset_id
                 and sth.book_type_code = RET.book
                 and bc.book_type_code = sth.book_type_code
                 and bc.book_class = 'TAX'
                 and r.asset_id = sth.asset_id
                 and r.transaction_header_id_in = nvl(sth.source_transaction_header_id, sth.transaction_header_id)
                 and rownum = 1;

               if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '++ IN FAGINFO: Processing TAX', '...', p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, '++ retirement_id in CORP', l_ret_id_in_corp, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add(l_calling_fn, '++ l_units_retired in CORP', l_units_retired, p_log_level_rec => p_log_level_rec);
               end if;

          exception
                when no_data_found then -- when called from Corp
                  l_ret_id_in_corp := RET.retirement_id;
                  l_units_retired := RET.units_retired;
          end;

          l_unit_ret_in_corp := FALSE;
          begin
               -- calculate Corp's TRANSFER OUT THID
               select transaction_header_id_out
                 into l_id_out
               from fa_distribution_history
               where retirement_id =
                (select r.retirement_id
                 from fa_transaction_headers sth
                     ,fa_retirements r
                 where sth.transaction_header_id = RET.th_id_in
                   and sth.asset_id = RET.asset_id
                   and sth.book_type_code = RET.book
                   and r.asset_id = sth.asset_id
                   and r.transaction_header_id_in = nvl(sth.source_transaction_header_id, sth.transaction_header_id)
                )
                and transaction_header_id_out is not null
                and rownum = 1;

               l_unit_ret_in_corp := TRUE;

          exception
                when no_data_found then
                  l_unit_ret_in_corp := FALSE;
          end;


          -- Bug 5337905
          begin

               -- check if there were balance transfers in Tax book due to changes to DIST IDs in Corp book.(done via ret api)
               -- l_balance_tfr_in_tax will still remain zero for the partial retirement after reinstatement being copied to TAX.
               begin

                  if nvl(ret.mrc_sob_type_code,'P') <> 'R' then
                    select count(*)
                      into l_balance_tfr_in_tax
                    from fa_adjustments
                    where book_type_code = RET.book
                      and asset_id = RET.asset_id
                      and transaction_header_id = l_id_out -- Corp's TRANSFER OUT THID
                      and source_type_code in ('TRANSFER', 'RETIREMENT')
                      and adjustment_amount <> 0
                      and rownum = 1;
                  else
                    select count(*)
                      into l_balance_tfr_in_tax
                    from fa_mc_adjustments
                    where book_type_code = RET.book
                      and asset_id = RET.asset_id
                      and transaction_header_id = l_id_out -- Corp's TRANSFER OUT THID
                      and source_type_code in ('TRANSFER', 'RETIREMENT') -- TRANSFER for part-ret, RETIREMENT for reinst of full retirement
                      and adjustment_amount <> 0
                      and set_of_books_id = ret.set_of_books_id
                      and rownum = 1;
                  end if;

               exception
                  when no_data_found then null;
                  when others then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    raise faginfo_error;
               end;

          end;


          -- issue #3 in Bug 4398887
          begin

            if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add(l_calling_fn, '++ IN FAGINFO: l_balance_tfr_in_tax BEFORE code for issue#3', l_balance_tfr_in_tax, p_log_level_rec => p_log_level_rec);
            end if;

            if l_balance_tfr_in_tax = 0 then

               -- check if a transaction prior to this retirement in Tax book has already used the latest active dist IDs
               -- if yes, l_balance_tfr_in_tax will be set to 2.
               begin

                if nvl(ret.mrc_sob_type_code,'P') <> 'R' then

                 select 2 -- this has to be set to 2 to differ from 1 for a regular balance tfr; used for fagurt
                 into l_balance_tfr_in_tax
                 from fa_distribution_history
                 where asset_id = RET.asset_id
                   and transaction_header_id_out is NULL
                   and rownum = 1
                   and distribution_id =
                       nvl((select max(distribution_id) /*Bug 8301287. There may be a case where there exists no Records*/
                            from fa_adjustments
                            where book_type_code = RET.book
                              and asset_id = RET.asset_id
                              -- and source_type_code in ('ADDITION')
                              and adjustment_amount <> 0
                              and transaction_header_id
                                  in (select transaction_header_id  /*Bug 8301287. There can exist Non Financial Transaction which does not insert records into fa_adjustments*/
                                        from fa_transaction_headers
                                       where book_type_code = RET.book
                                         and asset_id = RET.asset_id
                                         and transaction_header_id < RET.th_id_in -- ret thid in TAX
                                     )
                          ),distribution_id);
                else

                 select 2 -- this has to be set to 2 to differ from 1 for a regular balance tfr; used for fagurt
                 into l_balance_tfr_in_tax
                 from fa_distribution_history
                 where asset_id = RET.asset_id
                   and transaction_header_id_out is NULL
                   and rownum = 1
                   and distribution_id =
                       nvl((select max(distribution_id) /*Bug 8301287. There may be a case where there exists no Records*/
                            from fa_mc_adjustments
                            where book_type_code = RET.book
                              and asset_id = RET.asset_id
                              -- and source_type_code in ('ADDITION')
                              and adjustment_amount <> 0
                              and set_of_books_id = ret.set_of_books_id
                              and transaction_header_id
                                  in (select transaction_header_id  /*Bug 8301287. There can exist Non Financial Transaction which does not insert records into fa_adjustments*/
                                        from fa_transaction_headers
                                       where book_type_code = RET.book
                                         and asset_id = RET.asset_id
                                         and transaction_header_id < RET.th_id_in -- ret thid in TAX
                                     )
                          ),distribution_id);
                end if;

               exception
                  when no_data_found then
                    l_balance_tfr_in_tax := 0;
                  when others then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    raise faginfo_error;
               end;


            end if;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '++ IN FAGINFO: l_balance_tfr_in_tax AFTER code for issue#3', l_balance_tfr_in_tax, p_log_level_rec => p_log_level_rec);
            end if;

          end;


          if set_adj_row then

            if (bk.book_class and l_unit_ret_in_corp) then -- if partial unit ret in TAX book

               if (l_balance_tfr_in_tax > 0) then
                 --adj_row.selection_retid := 0;
                 --adj_row.units_retired := 0;
                 adj_row.selection_thid := 0;
                 adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                 if p_log_level_rec.statement_level then
                    fa_debug_pkg.add(l_calling_fn, '++++ selection_mode', 'FA_STD_TYPES.FA_AJ_ACTIVE', p_log_level_rec => p_log_level_rec);
                 end if;
               else
                 if candidate_mode in ('RETIRE') then
                   adj_row.selection_retid := l_ret_id_in_corp;
                   adj_row.units_retired := l_units_retired;
                   adj_row.selection_mode := FA_STD_TYPES.FA_AJ_RETIRE;
                   if p_log_level_rec.statement_level then
                      fa_debug_pkg.add(l_calling_fn, '++++ selection_mode', 'FA_STD_TYPES.FA_AJ_RETIRE', p_log_level_rec => p_log_level_rec);
                   end if;
                 else
                   adj_row.selection_thid := l_id_out;
                   adj_row.selection_mode := FA_STD_TYPES.FA_AJ_CLEAR_PARTIAL;
                   if p_log_level_rec.statement_level then
                      fa_debug_pkg.add(l_calling_fn, '++++ selection_mode', 'FA_STD_TYPES.FA_AJ_CLEAR_PARTIAL', p_log_level_rec => p_log_level_rec);
                   end if;
                 end if;

               end if;

            else
               --adj_row.selection_retid := 0;
               --adj_row.units_retired := 0;
               adj_row.selection_thid := 0;
               adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
               if p_log_level_rec.statement_level then
                  fa_debug_pkg.add(l_calling_fn, '++++ in ELSE:  selection_mode', 'FA_STD_TYPES.FA_AJ_ACTIVE', p_log_level_rec => p_log_level_rec);
               end if;
            end if;

          end if;

  end if;


  unit_ret_in_corp := l_unit_ret_in_corp;
  ret_id_in_corp := l_ret_id_in_corp;
  th_id_out_in_corp := l_id_out;
  balance_tfr_in_tax := l_balance_tfr_in_tax;

  return TRUE;
EXCEPTION

    when faginfo_error then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;
END;



/*==========================================================================*
|  NAME         fagitc                                                      |
|                                                                           |
|  FUNCTION     This function calculates ITC_RECAPTURED (if necessary) for  |
|               this retirement. The ITC_AMOUNT_ID in FA_BOOKS must not be  |
|               null in order for ITC_RECAPTURED to be calculated.          |
|                                                                           |
|  HISTORY      1/17/89         R Rumanang      Created                     |
|               12/27/89        R RUmanang      Fixed bug in itc recaptured.|
|                                               we should take partial itc  |
|                                               recaptured when partial ret.|
|               05/03/91        M Chan          Modified for MPL 9          |
|               11/17/96        S Behura        Converted into PL/SQL       |
*===========================================================================*/

FUNCTION fagitc(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                cost_frac in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) Return boolean IS

    no_recapture        exception;
    fagitc_err          exception;

    h_itc_amount        number;
    h_itc_amount_id     number(15);
    h_retirement_id     number(15);
    h_asset_id          number(15);
    h_recaptured        number;
    h_itc_recapture_id  number(15);
    h_date_placed       date;
    h_date_retired      date;
    h_book              varchar2(30);
    h_years_kept        number(5);
    h_cost_frac         number;
    h_cur_units         number(6);

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UPD_PKG.fagitc';

    BEGIN <<FAGITC>>

        h_itc_amount_id := bk.itc_used;
        h_date_placed := bk.date_in_srv;
        h_date_retired := ret.date_retired;
        h_book := ret.book;
        h_cur_units := bk.cur_units;
        h_itc_amount := bk.itc_amount;
        h_asset_id := ret.asset_id;
        h_retirement_id := ret.retirement_id;
        h_cost_frac := cost_frac;

        SELECT (MONTHS_BETWEEN(trunc(h_date_retired),
                               trunc(h_date_placed)) / 12) + 1
        INTO   h_years_kept
        FROM   FA_RETIREMENTS
        WHERE  RETIREMENT_ID = h_retirement_id;

        begin
          SELECT  farecap.itc_recapture_id ,
                  h_itc_amount * farecap.itc_recapture_rate *
                  h_cost_frac
          INTO
                  h_itc_recapture_id,
                  h_recaptured
          FROM    fa_itc_recapture_rates farecap,
                  fa_itc_rates farate
          WHERE   farecap.tax_year = farate.tax_year
          AND     farecap.life_in_months = farate.life_in_months
          AND     farecap.year_of_retirement = h_years_kept
          AND     farate.itc_amount_id = h_itc_amount_id;

          EXCEPTION

             when no_data_found then
             RAISE no_recapture;

        end;

        -- Call faxrnd in fagitc
        if not FA_UTILS_PKG.faxrnd(h_recaptured, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           RAISE fagitc_err;
        end if;

        if (ret.mrc_sob_type_code <> 'R') then
            UPDATE      fa_retirements fr
            SET         fr.itc_recaptured = h_recaptured,
                        fr.itc_recapture_id = h_itc_recapture_id
            WHERE       fr.retirement_id = h_retirement_id;
        else
            UPDATE      fa_mc_retirements fr
            SET         fr.itc_recaptured = h_recaptured,
                        fr.itc_recapture_id = h_itc_recapture_id
            WHERE       fr.retirement_id = h_retirement_id
              AND       fr.set_of_books_id = ret.set_of_books_id;
        end if;

        return(TRUE);

    EXCEPTION

        when no_recapture then
             fa_srvr_msg.add_message(
                 calling_fn => NULL,
                 name       => 'FA_RET_NO_ITC',
                 token1     => 'MODULE',
                 value1     => 'FAGITC', p_log_level_rec => p_log_level_rec);
             return TRUE;

        when others then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return FALSE;

    END FAGITC;    -- End of Function FAGITC

/*===========================================================================*
| NAME          fagurt                                                       |
|                                                                            |
| FUNCTION                                                                   |
|       It calculates GAIN/LOSS, NBV_RETIRED, STL_DEPRN_AMOUNT. Update the   |
| status in FA_RETIREMENTS table from 'PENDING' to 'PROCESSED'. It           |
| also inserts  GAIN/LOSS, PROCEEDS_OF_SALE, and COST_OF_REMOVAL to          |
| FA_ADJUSTMENTS table.                                                      |
|                                                                            |
|  HISTORY     01/12/89    R Rumanang  Created                               |
|              08/30/89    R Rumanang  Updated to insert to                  |
|                                      FA_ADJUSTMENTS.                       |
|              01/31/90    R Rumanang  Insert PROCEEDS_OF_SALE to            |
|                                      ADJUSTMENT                            |
|              05/03/91    M Chan      Rewrote for MPL 9                     |
|              12/30/96    S Behura    Rewriting in PL/SQL                   |
*============================================================================*/

FUNCTION fagurt(ret       in out nocopy fa_ret_types.ret_struct,
                bk        in out nocopy fa_ret_types.book_struct,
                cpd_ctr          number,
                dpr       in out nocopy FA_STD_TYPES.dpr_struct,
                cost_frac in     number,
                retpdnum  in out nocopy number,
                today     in     date,
                user_id          number,
                p_log_level_rec  in FA_API_TYPES.log_level_rec_type) return boolean IS

    reval_deprn_amt     number;
    reval_amort_amt     number;
    cost_of_removal     number;
    proceeds_of_sale    number;
    proc_of_sale_clearing_acct          varchar2(26);
    proceeds_of_sale_gain_acct          varchar2(26);
    proceeds_of_sale_loss_acct          varchar2(26);
    cost_of_removal_clearing_acct       varchar2(26);
    cost_of_removal_gain_acct           varchar2(26);
    cost_of_removal_loss_acct           varchar2(26);
    nbv_retired_gain_acct               varchar2(26);
    nbv_retired_loss_acct               varchar2(26);
    reval_rsv_retired_gain_acct         varchar2(26);
    reval_rsv_retired_loss_acct         varchar2(26);

    --adj_row     FA_STD_TYPES.fa_adj_row_struct;
    adj_row     FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

    h_dr_cr_flag        number;
    h_retire_reval_flag number;
    h_retirement_id     number(15);
    h_th_id_in          number(15);
    h_asset_id          number(15);
    h_user_id           number(15);
    h_nbv_retired       number;
    h_gain_loss         number;
    h_reval_rsv_retired number;
    h_bonus_rsv_retired number;
    h_impair_rsv_retired number;
    h_stl_deprn         number;
    h_unrevalued_cost_retired   number;
    h_dist_book         varchar2(30);
    h_today             date;
    h_book              varchar2(30);
    h_proc_of_sale_clearing_acct        varchar2(26);
    h_proceeds_of_sale_gain_acct        varchar2(26);
    h_proceeds_of_sale_loss_acct        varchar2(26);
    h_cost_of_removal_clr_acct          varchar2(26);
    h_cost_of_removal_gain_acct         varchar2(26);
    h_cost_of_removal_loss_acct         varchar2(26);
    h_nbv_retired_gain_acct             varchar2(26);
    h_nbv_retired_loss_acct             varchar2(26);
    h_reval_rsv_retired_gain_acct       varchar2(26);
    h_reval_rsv_retired_loss_acct       varchar2(26);

    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;

    h_bonus_deprn_amt   number := 0;
    h_impairment_amt    number := 0;

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UPD_PKG.fagurt';

    /* Bug2316862 */
    l_dist_id           NUMBER;
    l_ccid              NUMBER;
    l_location_id       NUMBER;
    l_th_id_out         NUMBER;
    l_new_dist_id       NUMBER;
    l_dist_cost         NUMBER;
    l_dist_reserve      NUMBER;

    /* bug 3519644 */
    l_assigned_to       NUMBER;
    total_adj_amount    NUMBER;
    loop_counter        NUMBER;
    tot_dist_lines      NUMBER;
    /* bug 3519644 */

    l_unit_ret_in_corp  boolean;
    l_ret_id_in_corp    number;
    h_id_out            number;
    l_balance_tfr_in_tax  number;

    l_dist_imp_rsv      NUMBER; --hh: 6867027


    CURSOR c_ret_dists IS
    SELECT DISTRIBUTION_ID,
           CODE_COMBINATION_ID,
           LOCATION_ID,
           ASSIGNED_TO, -- bug 3519644
           TRANSACTION_HEADER_ID_OUT
    FROM   FA_DISTRIBUTION_HISTORY dist,
           FA_BOOK_CONTROLS bc
    -- Bug 5149832 WHERE  RETIREMENT_ID  = ret.retirement_id
    WHERE  RETIREMENT_ID  = nvl(l_ret_id_in_corp, ret.retirement_id)
    AND    ASSET_ID       = ret.asset_id
    -- Bug 5149832 AND    BOOK_TYPE_CODE = ret.book;
    AND    bc.book_type_code = ret.book
    AND    dist.BOOK_TYPE_CODE = bc.distribution_source_book;

    CURSOR c_new_dist (c_ccid        number,
                       c_location_id number,
                       c_assigned_to number,  -- bug 3519644
                       c_th_id_out   number) IS
    SELECT DISTRIBUTION_ID
    FROM   FA_DISTRIBUTION_HISTORY dist,
           FA_BOOK_CONTROLS bc
    WHERE  dist.TRANSACTION_HEADER_ID_IN = c_th_id_out
    AND    dist.TRANSACTION_HEADER_ID_OUT is NULL
    AND    dist.CODE_COMBINATION_ID = c_ccid
    AND    dist.LOCATION_ID = c_location_id
    AND    dist.ASSET_ID       = ret.asset_id
    -- Bug 5149832 AND    BOOK_TYPE_CODE = ret.book
    AND    bc.book_type_code = RET.book
    AND    dist.BOOK_TYPE_CODE = bc.distribution_source_book
    AND    nvl (dist.assigned_to, -99) = nvl (c_assigned_to, -99); -- bug 3519644


    -- NEW for TAX
    CURSOR c_new_dist_tax (c_ccid        number,
                           c_location_id number,
                           c_assigned_to number,
                           c_th_id_out   number) IS
    SELECT DISTRIBUTION_ID
    FROM   FA_DISTRIBUTION_HISTORY dist,
           FA_BOOK_CONTROLS bc
    WHERE
           dist.CODE_COMBINATION_ID = c_ccid
    AND    dist.LOCATION_ID = c_location_id
    AND    dist.ASSET_ID       = RET.asset_id
    AND    bc.book_type_code = RET.book
    AND    bc.book_class = 'TAX'
    AND    dist.BOOK_TYPE_CODE = bc.distribution_source_book
    AND    dist.transaction_header_id_in =
          (select max(adj.transaction_header_id) -- get the latest THID in the same period that caused DIST ID to change
           from fa_adjustments adj
           where adj.book_type_code = RET.book
             and adj.asset_id = RET.asset_id
             and adj.source_type_code in ('RETIREMENT', 'TRANSFER') -- RETIREMENT: balance tfr for Reinstatement, TRANSFER: balance tfr for Retirement
             and adj.period_counter_created = cpd_ctr
             and adj.adjustment_type = 'COST'
             and not exists -- check to see if adj.THID is from Corp
                 (select 1
                  from fa_transaction_headers th
                  where th.transaction_header_id = adj.transaction_header_id
                    and th.book_type_code = RET.book
                    and th.asset_id = RET.asset_id
                 )
          )
    ;



    /* BUG 2665163. No NBV RETIRED row in fa_adj.
       Modified c_ret_amount cursor to handle TAX book as well */
    CURSOR c_ret_amount (c_asset_id       number) is
    SELECT DISTRIBUTION_ID,
           CODE_COMBINATION_ID
    FROM   FA_DISTRIBUTION_HISTORY dist,
           FA_BOOK_CONTROLS bc
    WHERE  TRANSACTION_HEADER_ID_OUT is NULL
    AND    ASSET_ID       = c_asset_id
    AND    bc.book_type_code = ret.book
    AND    dist.book_type_code = bc.distribution_source_book;


    CURSOR c_ret_rsv_costs (c_dist_id           number,
                            c_new_dist_id       number,
                            c_source_type_code  varchar2,
                            c_adjustment_type   varchar2) IS
    SELECT SUM(NVL(DECODE(DEBIT_CREDIT_FLAG,
                            'CR', ADJUSTMENT_AMOUNT,
                                  -1 * ADJUSTMENT_AMOUNT), 0)*
               DECODE(ADJUSTMENT_TYPE, 'RESERVE', -1,
                                       'IMPAIR RESERVE', -1, 1)) --hh: 6867027
    FROM   FA_ADJUSTMENTS
    WHERE  (DISTRIBUTION_ID       = c_dist_id
         OR DISTRIBUTION_ID       = c_new_dist_id)
    AND    BOOK_TYPE_CODE         = ret.book
    AND    PERIOD_COUNTER_CREATED = cpd_ctr
    AND    SOURCE_TYPE_CODE       = c_source_type_code
    AND    ADJUSTMENT_TYPE        = c_adjustment_type
    AND    TRANSACTION_HEADER_ID  = ret.th_id_in;

    CURSOR c_ret_rsv_costs_mrc (c_dist_id           number,
                            c_new_dist_id       number,
                            c_source_type_code  varchar2,
                            c_adjustment_type   varchar2) IS
    SELECT SUM(NVL(DECODE(DEBIT_CREDIT_FLAG,
                            'CR', ADJUSTMENT_AMOUNT,
                                  -1 * ADJUSTMENT_AMOUNT), 0)*
               DECODE(ADJUSTMENT_TYPE, 'RESERVE', -1,
                                       'IMPAIR RESERVE', -1, 1)) --hh: 6867027
    FROM   FA_MC_ADJUSTMENTS
    WHERE  (DISTRIBUTION_ID       = c_dist_id
         OR DISTRIBUTION_ID       = c_new_dist_id)
    AND    BOOK_TYPE_CODE         = ret.book
    AND    PERIOD_COUNTER_CREATED = cpd_ctr
    AND    SOURCE_TYPE_CODE       = c_source_type_code
    AND    ADJUSTMENT_TYPE        = c_adjustment_type
    AND    set_of_books_id        = ret.set_of_books_id
    AND    TRANSACTION_HEADER_ID  = ret.th_id_in;
    /* End of Bug2316862 */
    /* Bug2316862 was causing a data corruption.
       Fixed by BUG#2626812 */

    -- +++++ Get Current Unit of Group Asset +++++
    CURSOR c_get_unit (c_asset_id number) is
      select units
      from   fa_asset_history
      where  asset_id = c_asset_id
      and    transaction_header_id_out is null;

    -- +++++ Get Group's reserve retired +++++
    -- At this stage reserve retired entry against
    -- Group has member asset's transaction_header_id.
    -- This will be updated to group one in
    -- FA_RETIREMENT_PVT.Do_Retirement_in_CGL
    --
    CURSOR c_get_g_rsv_ret is
      select adjustment_amount
      from   fa_adjustments
      where  asset_id = bk.group_asset_id
      and    book_type_code = ret.book
      and    transaction_header_id = ret.th_id_in
      and    adjustment_type = 'RESERVE';

    CURSOR c_get_g_rsv_ret_mrc is  --Bug 9103418
      select adjustment_amount
      from   fa_mc_adjustments
      where  asset_id = bk.group_asset_id
      and    book_type_code = ret.book
      and    transaction_header_id = ret.th_id_in
      and    adjustment_type = 'RESERVE'
      and    set_of_books_id = ret.set_of_books_id;

    CURSOR c_get_nbv_ret is
      select sum(decode(adjustment_type
               ,'COST', decode(debit_credit_flag,'CR', nvl(adjustment_amount,0), -1 * nvl(adjustment_amount,0))
               ,'RESERVE', decode(debit_credit_flag,'DR', -1 * nvl(adjustment_amount,0), nvl(adjustment_amount,0))
               ,'IMPAIR RESERVE', decode(debit_credit_flag,'DR', -1 * nvl(adjustment_amount,0), nvl(adjustment_amount,0))
             ,0))
      from   fa_adjustments
      where  asset_id = ret.asset_id
      and    book_type_code = ret.book
      and    transaction_header_id = ret.th_id_in
      and    source_type_code='RETIREMENT'
      and    adjustment_type in ('COST', 'RESERVE', 'IMPAIR RESERVE');  --hh: 6867027

   --created for bug# 5086360
    CURSOR c_get_nbv_ret_mrc is
      select sum(decode(adjustment_type
               ,'COST', decode(debit_credit_flag,'CR', nvl(adjustment_amount,0), -1 * nvl(adjustment_amount,0))
               ,'RESERVE', decode(debit_credit_flag,'DR', -1 * nvl(adjustment_amount,0), nvl(adjustment_amount,0))
               ,'IMPAIR RESERVE', decode(debit_credit_flag,'DR', -1 * nvl(adjustment_amount,0), nvl(adjustment_amount,0))
             ,0))
      from   fa_mc_adjustments
      where  asset_id = ret.asset_id
      and    book_type_code = ret.book
      and    transaction_header_id = ret.th_id_in
      and    source_type_code='RETIREMENT'
      and    set_of_books_id = ret.set_of_books_id
      and    adjustment_type in ('COST', 'RESERVE', 'IMPAIR RESERVE'); --hh: 6867027


    /* Bug2425233 */
    l_adj_type    VARCHAR2(15);

    -- +++++ Records to hold member asset and group asset info +++++
    l_asset_cat_rec_m  FA_API_TYPES.asset_cat_rec_type;
    l_asset_hdr_rec_g  FA_API_TYPES.asset_hdr_rec_type;
    l_asset_cat_rec_g  FA_API_TYPES.asset_cat_rec_type;

    l_g_reserve        NUMBER;

    l_prev_leveling_flag BOOLEAN; -- Bug 6666666

BEGIN <<FAGURT>>

       h_retire_reval_flag := 0;
       reval_deprn_amt := 0;
       reval_amort_amt := 0;
       cost_of_removal := 0;
       proceeds_of_sale := 0;
       h_nbv_retired := 0;
       h_gain_loss := 0;
       h_reval_rsv_retired := 0;
       h_bonus_rsv_retired := 0;
       h_unrevalued_cost_retired := 0;
       h_impair_rsv_retired := 0;
       h_stl_deprn := 0;

       h_th_id_in := ret.th_id_in;
       h_asset_id := ret.asset_id;
       h_retirement_id := ret.retirement_id;
       h_user_id := user_id;
       h_today := today;

       h_book := ret.book;
       h_dist_book := bk.dis_book;

       if (bk.group_asset_id is not null) and
          (nvl(bk.member_rollup_flag, 'N') = 'N') then
          if (ret.mrc_sob_type_code <> 'R') then --Bug 9103418
          OPEN c_get_g_rsv_ret;
          FETCH c_get_g_rsv_ret INTO l_g_reserve;
          CLOSE c_get_g_rsv_ret;
          else
          OPEN c_get_g_rsv_ret_mrc;
          FETCH c_get_g_rsv_ret_mrc INTO l_g_reserve;
          CLOSE c_get_g_rsv_ret_mrc;
          end if;

          -- fix for bug 3627497
          /*h_nbv_retired := (ret.cost_retired + ret.cost_of_removal) -
                           (ret.proceeds_of_sale + l_g_reserve); */
          h_nbv_retired := ret.cost_retired - nvl(l_g_reserve,0); --bug fix3639923

       elsif ret.wip_asset > 0 then
          h_nbv_retired := ret.cost_retired;

          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '++ IN FAGURT(1.2): in ret.wip_asset > 0', '');
          end if;

       else
         -- Bug#8220521:fetching c_get_nbv_ret even in case of full_retirement.
         --created for bug# 5086360
          if (ret.mrc_sob_type_code <> 'R') then
                  OPEN c_get_nbv_ret;
                  FETCH c_get_nbv_ret INTO h_nbv_retired;
                  CLOSE c_get_nbv_ret;
          else
                  OPEN c_get_nbv_ret_mrc;
                  FETCH c_get_nbv_ret_mrc INTO h_nbv_retired;
                  CLOSE c_get_nbv_ret_mrc;
          end if;
          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add(l_calling_fn, '++ IN FAGURT(1.2): in else ret.units_retired is not null', '');
          end if;

       end if;

       if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '++ IN FAGURT(1.5): ret.cost_retired', ret.cost_retired);
           fa_debug_pkg.add(l_calling_fn, 'ret.rsv_retired', ret.rsv_retired, p_log_level_rec => p_log_level_rec);
       end if;

       h_unrevalued_cost_retired := cost_frac * bk.unrevalued_cost;

       /****************************************************************
         Calculate stl_deprn . The dpr.y_begin and dpr.y_end had been
         setup in retire routine. However, if h_deprn_lastyr_flag is 1,
         we should not take the last year depreciation. Thus, we
         decrease dpr.y_end by 1. If dpr.y_end is less than dpr.y_begin,
         we set pd_num = 0 which is special value and caused it NOT to
         caluculate the stl depreciation.
         ****************************************************************/

       /**************************************************************
         If the asset is WIP, no STL calculation is required.
         If the STL_METHOD_ID = 0, it implies that NO STL method is
         used; no calculation is needed.
         ************************************************************/

       if (not bk.depreciate_lastyr) and (bk.book_class) and
          (ret.wip_asset is null or ret.wip_asset <= 0) and
          (ret.stl_method_code is not null) then

          dpr.y_end := dpr.y_end - 1;
          retpdnum := bk.pers_per_yr;

          if dpr.y_end < dpr.y_begin then
             retpdnum := 0;                     -- Special value
          end if;
       end if;

       if (bk.book_class) and (retpdnum <> 0) and
          (ret.wip_asset is null or ret.wip_asset <= 0) and
          (ret.stl_method_code is not null) then

          dpr.method_code := ret.stl_method_code;
          dpr.life := ret.stl_life;

           /**************************************************************
             For STL depreciation calculation, the old deprn reserve
             should not be used. zero depreciation reserve should be used.
             ************************************************************/
          dpr.deprn_rsv := 0;

          if not FA_GAINLOSS_DPR_PKG.fagcdp(dpr, h_stl_deprn,
                             reval_deprn_amt, h_bonus_deprn_amt,
                             h_impairment_amt,
                             reval_amort_amt, bk.deprn_start_date,
                             bk.d_cal, bk.p_cal, 0, retpdnum, bk.prorate_fy,
                             bk.dsd_fy, bk.prorate_jdate,
                             bk.deprn_start_jdate, p_log_level_rec => p_log_level_rec) then

               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);

          end if;

          h_stl_deprn := cost_frac * (h_stl_deprn + reval_deprn_amt);

       end if;

       select  bc.proceeds_of_sale_clearing_acct,
               bc.proceeds_of_sale_gain_acct,
               bc.proceeds_of_sale_loss_acct,
               bc.cost_of_removal_clearing_acct,
               bc.cost_of_removal_gain_acct,
               bc.cost_of_removal_loss_acct,
               bc.nbv_retired_gain_acct,
               bc.nbv_retired_loss_acct,
               bc.reval_rsv_retired_gain_acct,
               bc.reval_rsv_retired_loss_acct,
               decode(bc.retire_reval_reserve_flag,'NO',0,
                      decode(cb.reval_reserve_acct,null,0,1)),
               ad.asset_category_id
       into    h_proc_of_sale_clearing_acct,
               h_proceeds_of_sale_gain_acct,
               h_proceeds_of_sale_loss_acct,
               h_cost_of_removal_clr_acct,
               h_cost_of_removal_gain_acct,
               h_cost_of_removal_loss_acct,
               h_nbv_retired_gain_acct,
               h_nbv_retired_loss_acct,
               h_reval_rsv_retired_gain_acct,
               h_reval_rsv_retired_loss_acct,
               h_retire_reval_flag,
               l_asset_cat_rec_m.category_id
       from    fa_book_controls bc,
               fa_additions_b ad, fa_category_books cb
       where   ad.asset_id = h_asset_id
       and     cb.category_id = ad.asset_category_id
       and     cb.book_type_code = h_book
       and     bc.book_type_code = cb.book_type_code;

       proc_of_sale_clearing_acct := h_proc_of_sale_clearing_acct;
       proceeds_of_sale_gain_acct := h_proceeds_of_sale_gain_acct;
       proceeds_of_sale_loss_acct := h_proceeds_of_sale_loss_acct;
       cost_of_removal_clearing_acct := h_cost_of_removal_clr_acct;
       cost_of_removal_gain_acct := h_cost_of_removal_gain_acct;
       cost_of_removal_loss_acct := h_cost_of_removal_loss_acct;
       nbv_retired_gain_acct := h_nbv_retired_gain_acct;
       nbv_retired_loss_acct := h_nbv_retired_loss_acct;
       reval_rsv_retired_gain_acct := h_reval_rsv_retired_gain_acct;
       reval_rsv_retired_loss_acct := h_reval_rsv_retired_loss_acct;

       if h_retire_reval_flag = 0 then
          ret.reval_rsv_retired := 0;
       end if;

       h_reval_rsv_retired := ret.reval_rsv_retired;
       h_bonus_rsv_retired := ret.bonus_rsv_retired;
       h_impair_rsv_retired := ret.impair_rsv_retired;

       -- Bug#5037745: added nvl to reval_rsv_retired
       h_gain_loss := (ret.proceeds_of_sale + nvl(ret.reval_rsv_retired,0)) -
                      (h_nbv_retired + ret.cost_of_removal) -
                      nvl(ret.impair_rsv_retired, 0);

       if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(l_calling_fn, '++ IN FAGURT(2): ret.proceeds_of_sale', ret.proceeds_of_sale);
           fa_debug_pkg.add(l_calling_fn, 'ret.cost_of_removal', ret.cost_of_removal, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'ret.reval_rsv_retired', ret.reval_rsv_retired, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_nbv_retired', h_nbv_retired, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'ret.impair_rsv_retired', ret.impair_rsv_retired, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(l_calling_fn, 'h_gain_loss', h_gain_loss, p_log_level_rec => p_log_level_rec);
       end if;

       -- Call faxrnd to round nbv_retired in fagurt
       if not FA_UTILS_PKG.faxrnd(h_nbv_retired, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);
       end if;

       -- Call faxrnd to round gain_loss in fagurt
       if not FA_UTILS_PKG.faxrnd(h_gain_loss, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);
       end if;

       -- Call faxrnd to round stl_deprn in fagurt
       if not FA_UTILS_PKG.faxrnd(h_stl_deprn, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);
       end if;

       -- Call faxrnd to round reval_rsv_retired in fagurt
       if not FA_UTILS_PKG.faxrnd(h_reval_rsv_retired, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);
       end if;

       -- Call faxrnd to round bonus_rsv_retired in fagurt
       if not FA_UTILS_PKG.faxrnd(h_bonus_rsv_retired, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);
       end if;

       -- Call faxrnd to round impair_rsv_retired in fagurt
       if not FA_UTILS_PKG.faxrnd(h_impair_rsv_retired, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);
       end if;

       -- Call faxrnd to round unrevalued_cost_retired in fagurt
       if not FA_UTILS_PKG.faxrnd(h_unrevalued_cost_retired, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);
       end if;

       if (ret.mrc_sob_type_code <> 'R') then
                UPDATE  fa_retirements fr
                SET     fr.nbv_retired   = h_nbv_retired,
                        fr.gain_loss_amount = h_gain_loss,
                        fr.stl_deprn_amount = h_stl_deprn,
                        fr.reval_reserve_retired = h_reval_rsv_retired,
                        bonus_reserve_retired = h_bonus_rsv_retired,
                        impair_reserve_retired = h_impair_rsv_retired,
                        fr.unrevalued_cost_retired =
                                        h_unrevalued_cost_retired,
                        fr.status                = 'PROCESSED',
                        fr.last_update_date = h_today,
                        fr.last_updated_by  = h_user_id
                WHERE
                        fr.retirement_id         = h_retirement_id;
       else
                UPDATE  fa_mc_retirements fr
                SET     fr.nbv_retired   = h_nbv_retired,
                        fr.gain_loss_amount = h_gain_loss,
                        fr.stl_deprn_amount = h_stl_deprn,
                        fr.reval_reserve_retired = h_reval_rsv_retired,
                        bonus_reserve_retired = h_bonus_rsv_retired,
                        impair_reserve_retired = h_impair_rsv_retired,
                        fr.unrevalued_cost_retired =
                                        h_unrevalued_cost_retired,
                        fr.status                = 'PROCESSED',
                        fr.last_update_date = h_today,
                        fr.last_updated_by  = h_user_id
                WHERE
                        fr.retirement_id         = h_retirement_id
                  AND   set_of_books_id = ret.set_of_books_id;
       end if;

    /* If gain it's 1(CR), else it's 0(DR) */
    /* h_dr_cr_flag = (int) ((h_gain_loss < 0) ? 0 : 1); */

       if h_gain_loss < 0 then
          h_dr_cr_flag := 0;
       else
          h_dr_cr_flag := 1;
       end if;

    /* Note that we debit or credit the account based on the gain-loss.
       The amount that we inserted into the table must be positive.
    */

       -- Setting l_unit_ret_in_corp
       if NOT faginfo(
                RET, BK, cpd_ctr,today, user_id
               ,calling_module => l_calling_fn
               ,candidate_mode => 'RETIRE'
               ,set_adj_row => FALSE -- just to get l_unit_ret_in_corp and h_id_out
               ,unit_ret_in_corp => l_unit_ret_in_corp
               ,ret_id_in_corp => l_ret_id_in_corp
               ,th_id_out_in_corp => h_id_out
               ,balance_tfr_in_tax => l_balance_tfr_in_tax
               ,adj_row => adj_row
               ,p_log_level_rec => p_log_level_rec) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);
       end if;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn, '++++++ AFTER faginfo to get some variables...', '...', p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, '++ l_unit_ret_in_corp', l_unit_ret_in_corp, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, '++ l_ret_id_in_corp', l_ret_id_in_corp, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, '++ h_id_out', h_id_out, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add(l_calling_fn, '++ l_balance_tfr_in_tax (1=TRUE)', l_balance_tfr_in_tax);
       end if;


       adj_row.transaction_header_id := ret.th_id_in;

       if ret.wip_asset > 0 then
          adj_row.source_type_code := 'CIP RETIREMENT';
       else
          adj_row.source_type_code := 'RETIREMENT';
       end if;

       adj_row.book_type_code := ret.book;
       adj_row.period_counter_created := cpd_ctr;
       adj_row.asset_id := ret.asset_id;
       adj_row.period_counter_adjusted := cpd_ctr;
       adj_row.last_update_date := today;
       adj_row.current_units := bk.cur_units;
       adj_row.gen_ccid_flag := TRUE;
       adj_row.flush_adj_flag := TRUE;
       adj_row.annualized_adjustment := 0;
       adj_row.code_combination_id := 0;
       adj_row.distribution_id := 0;
       adj_row.selection_thid := 0;
       adj_row.asset_invoice_id := 0;
       adj_row.leveling_flag := TRUE;


       if (ret.units_retired <= 0 or ret.units_retired is null) then

          adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
          adj_row.selection_retid := 0;
          adj_row.units_retired := 0;

          if (bk.current_cost = ret.cost_retired) then
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
          else

            if bk.book_class then
               if NOT faginfo(
                            RET, BK, cpd_ctr,today, user_id
                           ,calling_module => l_calling_fn
                           ,candidate_mode => 'RETIRE'
                           ,set_adj_row => TRUE -- set adj_row
                           ,unit_ret_in_corp => l_unit_ret_in_corp
                           ,ret_id_in_corp => l_ret_id_in_corp
                           ,th_id_out_in_corp => h_id_out
                           ,balance_tfr_in_tax => l_balance_tfr_in_tax
                           ,adj_row => adj_row
                           ,p_log_level_rec => p_log_level_rec            ) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  return(FALSE);
               end if;
            end if;

          end if;

       else
          adj_row.selection_mode := FA_STD_TYPES.FA_AJ_RETIRE;
          adj_row.selection_retid := ret.retirement_id;
          adj_row.units_retired := ret.units_retired;
       end if;

       if (bk.group_asset_id is not null) and
          (nvl(bk.member_rollup_flag, 'N') = 'N') then
          if not fa_cache_pkg.fazccb
                  (X_book   => ret.book,
                   X_cat_id => l_asset_cat_rec_m.category_id, p_log_level_rec => p_log_level_rec) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return(FALSE);
          end if;

       end if;

       -- +++++ BUG 2669638: Change operator from > to <> +++++
       -- +++++ Create PROCEEDS/RESERVE if this is not member asset with ALLOCATE +++++
       --8244128 Changed the check from Allocate to member rollup flag
       --8546627 Added condition for Stand Alone assets
       --8681627 Modified the check for member_rollup_flag to tracking method
       if (ret.proceeds_of_sale <> 0)  and
          (((bk.group_asset_id is not null) and (bk.tracking_method is not null)) or bk.group_asset_id is null)  then

          if (bk.group_asset_id is not null) and
             (nvl(bk.member_rollup_flag, 'N') = 'N') then
             adj_row.track_member_flag := 'Y';
          else
             adj_row.track_member_flag := null;
          end if;

          adj_row.adjustment_type := 'PROCEEDS';

          adj_row.adjustment_amount := ret.proceeds_of_sale;

          if h_dr_cr_flag = 1 then
             adj_row.account := proceeds_of_sale_gain_acct;
             adj_row.account_type := 'PROCEEDS_OF_SALE_GAIN_ACCT';
          else
             adj_row.account := proceeds_of_sale_loss_acct;
             adj_row.account_type := 'PROCEEDS_OF_SALE_LOSS_ACCT';
          end if;

          adj_row.debit_credit_flag := 'CR';
          adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

          end if;

          -- added for bug 3627497
          if (bk.group_asset_id is not null) and
             (nvl(bk.member_rollup_flag, 'N') = 'N') then

            adj_row.adjustment_type := 'PROCEEDS CLR';
            adj_row.adjustment_amount := ret.proceeds_of_sale;
            adj_row.account := proc_of_sale_clearing_acct;
            adj_row.account_type := 'PROCEEDS_OF_SALE_CLEARING_ACCT';
            adj_row.debit_credit_flag := 'DR';
            adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
            adj_row.set_of_books_id := ret.set_of_books_id;

            if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);
            end if;

          end if;

       end if; -- (ret.proceeds_of_sale <> 0) and

       -- +++++ BUG 2669638: Changed operator from > to <>. +++++
       -- +++++ Create REMOVALCOST/RESERVE if this is not member asset with ALLOCATE +++++
       --8244128 Changed the check from Allocate to member rollup flag
       --8546627 Added condition for Stand Alone assets
       --8681627 Modified the check for member_rollup_flag to tracking method
       if (ret.cost_of_removal <> 0)  and
          (((bk.group_asset_id is not null) and (bk.tracking_method is not null)) or bk.group_asset_id is null)  then

          if (bk.group_asset_id is not null) and
             (nvl(bk.member_rollup_flag, 'N') = 'N') then
             adj_row.track_member_flag := 'Y';
          else
             adj_row.track_member_flag := null;
          end if;

          adj_row.adjustment_type := 'REMOVALCOST';

          adj_row.adjustment_amount := ret.cost_of_removal;

          if h_dr_cr_flag = 1 then
             adj_row.account := cost_of_removal_gain_acct;
             adj_row.account_type := 'COST_OF_REMOVAL_GAIN_ACCT';
          else
             adj_row.account := cost_of_removal_loss_acct;
             adj_row.account_type := 'COST_OF_REMOVAL_LOSS_ACCT';
          end if;

          adj_row.debit_credit_flag := 'DR';
          adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return(FALSE);

          end if;


        -- added for bug 3627497
        if (bk.group_asset_id is not null) and
           (nvl(bk.member_rollup_flag, 'N') = 'N') then
          adj_row.adjustment_type := 'REMOVALCOST CLR';
          adj_row.adjustment_amount := ret.cost_of_removal;
          adj_row.account := cost_of_removal_clearing_acct;
          adj_row.account_type := 'COST_OF_REMOVAL_CLEARING_ACCT';
          adj_row.debit_credit_flag := 'CR';
          adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);

          end if;
        end if;

       end if; -- (ret.cost_of_removal > 0) and

       /* BUG 2316862
        * NBV RETIRED entiries are created for each distribution lines retired
        * to avoid rounding errors.
        * Fisrt of all, get distribution which is effected by retirement.
        * If this is partial unit retirement, get only effected lines, otherwise
        * all ditribution lines.
        * Then find out cost and reserve retired and use these to find out
        * NBV retired for each effected distribution line.
        */
       if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add(fname => l_calling_fn,
                            element => '+++ret.cost_retired before if condition',
                            value   => ret.cost_retired, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(fname => l_calling_fn,
                            element => '+++ret.rsv_retired before if condition',
                            value   => ret.rsv_retired, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add(fname => l_calling_fn,
                            element => '+++h_nbv_retired before if condition',
                            value   => h_nbv_retired, p_log_level_rec => p_log_level_rec);
       end if;

       -- +++++ BUG 2669638: Changed operator from > to <> +++++
       --8244128 Changed the check from Allocate to member rollup flag
       --8546627 Added condition for Stand Alone assets
       --8677070 , Added condition for processing member with group having rollupflag Yes and calculate tracking
       --8681627 Modified the check for member_rollup_flag to tracking method
       if (h_nbv_retired <> 0)  and
         (((bk.group_asset_id is not null) and (bk.tracking_method is not null)) or bk.group_asset_id is null)  then

          adj_row.selection_mode := fa_adjust_type_pkg.FA_AJ_TRANSFER_SINGLE;

          adj_row.adjustment_type := 'NBV RETIRED';
          adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;

          if (bk.group_asset_id is not null) and
             (nvl(bk.member_rollup_flag, 'N') = 'N') then
             adj_row.track_member_flag := 'Y';
          else
             adj_row.track_member_flag := null;
          end if;

          if h_dr_cr_flag = 1 then
             adj_row.account := nbv_retired_gain_acct;
             adj_row.account_type := 'NBV_RETIRED_GAIN_ACCT';
             adj_row.debit_credit_flag := 'DR';
          else
             adj_row.account := nbv_retired_loss_acct;
             adj_row.account_type := 'NBV_RETIRED_LOSS_ACCT';
             adj_row.debit_credit_flag := 'DR';
          end if;

          -- if (ret.units_retired is null and NOT l_unit_ret_in_corp) then
          -- fix for issue#3 in Bug 4398887
          /* Cursor used in each of the following conditions

                    Unit Ret =  True           False
           ------------------- ------------   --------------
          Bal Tfr=0            c_ret_dists     c_ret_amount
          Bal Tfr=1            c_ret_amount    c_ret_amount
          Bal Tfr=2            c_ret_amount    c_ret_amount
          */

          if (ret.units_retired is null and NOT (l_unit_ret_in_corp and l_balance_tfr_in_tax = 0)) then

            OPEN c_ret_amount (ret.asset_id);
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(fname => l_calling_fn,
                                element => '+++in amount',
                                value   => 1, p_log_level_rec => p_log_level_rec);
            end if;
          else
            OPEN c_ret_dists;
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(fname => l_calling_fn,
                                element => '+++in dists',
                                value   => 1, p_log_level_rec => p_log_level_rec);
            end if;
          end if;

             /* bug 3519644 */

          -- bug fix 5965367 (Replaced below if clause with new if clause)
          --   if (ret.units_retired is null and NOT l_unit_ret_in_corp) then
          if (ret.units_retired is null and NOT (l_unit_ret_in_corp and l_balance_tfr_in_tax = 0)) then

             SELECT count(*)
             INTO   tot_dist_lines
             FROM   FA_DISTRIBUTION_HISTORY dist,
                    FA_BOOK_CONTROLS bc
             WHERE  TRANSACTION_HEADER_ID_OUT is NULL
             AND    ASSET_ID       = RET.asset_id
             AND    bc.book_type_code = RET.book
             AND    dist.book_type_code = bc.distribution_source_book;

             else

             SELECT count(*)
             INTO   tot_dist_lines
             FROM   FA_DISTRIBUTION_HISTORY dist,
                    FA_BOOK_CONTROLS bc
             WHERE  dist.RETIREMENT_ID  = nvl(l_ret_id_in_corp, ret.retirement_id)
             AND    dist.ASSET_ID       = RET.asset_id
             AND    bc.book_type_code = RET.book
             AND    dist.book_type_code = bc.distribution_source_book;

             end if;

             loop_counter     := 0;
             total_adj_amount := 0;
             /* bug 3519644 */

          LOOP

              adj_row.adjustment_type := 'NBV RETIRED';
              adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
              adj_row.set_of_books_id := ret.set_of_books_id;

              if (bk.group_asset_id is not null) and
                 (nvl(bk.member_rollup_flag, 'N') = 'N') then
                 adj_row.track_member_flag := 'Y';
              else
                 adj_row.track_member_flag := null;
              end if;

              if h_dr_cr_flag = 1 then
                 adj_row.account := nbv_retired_gain_acct;
                 adj_row.account_type := 'NBV_RETIRED_GAIN_ACCT';
                 adj_row.debit_credit_flag := 'DR';
              else
                 adj_row.account := nbv_retired_loss_acct;
                 adj_row.account_type := 'NBV_RETIRED_LOSS_ACCT';
                 adj_row.debit_credit_flag := 'DR';
              end if;
             /* Fetch all distribution effected process NBV retired */
             --if (ret.units_retired is null and NOT l_unit_ret_in_corp ) then
             if (ret.units_retired is null and NOT (l_unit_ret_in_corp and l_balance_tfr_in_tax = 0)) then
               FETCH c_ret_amount INTO l_dist_id, l_ccid;
             else
               FETCH c_ret_dists INTO l_dist_id, l_ccid, l_location_id, l_assigned_to, l_th_id_out; -- bug 3519644
             end if;

             --if (ret.units_retired is null and NOT l_unit_ret_in_corp) then
             if (ret.units_retired is null and NOT (l_unit_ret_in_corp and l_balance_tfr_in_tax = 0)) then
               EXIT WHEN c_ret_amount%NOTFOUND;
             else
               EXIT WHEN c_ret_dists%NOTFOUND;
               l_new_dist_id := to_number(null);

               /*
                * If there are new distributiion created because of retirement
                * get distribution id which will be used to determine cost and reserve
                * retired.
                */
               if (l_th_id_out is not null) then

                  if bk.book_class then -- if TRUE=TAX
                    OPEN c_new_dist_tax (l_ccid, l_location_id, l_assigned_to, l_th_id_out);
                    FETCH c_new_dist_tax INTO l_new_dist_id;
                    CLOSE c_new_dist_tax;
                  else
                    OPEN c_new_dist (l_ccid, l_location_id, l_assigned_to, l_th_id_out);
                    FETCH c_new_dist INTO l_new_dist_id;
                    CLOSE c_new_dist;
                  end if;

               end if;

               if l_new_dist_id is null then
                 l_new_dist_id := l_dist_id;
               else
                 if bk.book_class and l_balance_tfr_in_tax > 0 then
                   l_dist_id := l_new_dist_id;
                 end if;
               end if;

             end if;

             loop_counter := loop_counter + 1; -- bug 3519644
             adj_row.distribution_id := l_dist_id;
             adj_row.code_combination_id := l_ccid;


             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(fname => l_calling_fn,
                                 element => 'l_dist_id',
                                 value   => l_dist_id, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(fname => l_calling_fn,
                                 element => 'l_ccid',
                                 value   => l_ccid, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(fname => l_calling_fn,
                                 element => 'l_location_id',
                                 value   => l_location_id, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(fname => l_calling_fn,
                                 element => 'l_th_id_out',
                                 value   => l_th_id_out, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(fname => l_calling_fn,
                                 element => 'l_new_dist_id',
                                 value   => l_new_dist_id, p_log_level_rec => p_log_level_rec);
             end if;


             /* Get distribution level cost retired */
             /* Bug2425233
              *   Check source type code and set ajustment type
              *   accordingly.  Also moved reserve query inside
              *   of this check so reserve query should be executed
              *   only if it's necessary.
              */
             if (adj_row.source_type_code <> 'CIP RETIREMENT') then
               l_adj_type := 'COST';

                /* Get distribution level reserve retired */
                /* BUG# 2626812 */
                if (ret.mrc_sob_type_code <> 'R') then
                  OPEN c_ret_rsv_costs (adj_row.distribution_id,
                                        l_new_dist_id,
                                        'RETIREMENT',
                                        'RESERVE');
                  FETCH c_ret_rsv_costs INTO l_dist_reserve;
                  CLOSE c_ret_rsv_costs;
                else
                  OPEN c_ret_rsv_costs_mrc (adj_row.distribution_id,
                                            l_new_dist_id,
                                            'RETIREMENT',
                                            'RESERVE');
                  FETCH c_ret_rsv_costs_mrc INTO l_dist_reserve;
                  CLOSE c_ret_rsv_costs_mrc;
               end if;
               -- HH: 6867027
               -- Get dist impair reserve
               if (ret.mrc_sob_type_code <> 'R') then
                  OPEN c_ret_rsv_costs (adj_row.distribution_id,
                                        l_new_dist_id,
                                        'RETIREMENT',
                                        'IMPAIR RESERVE');
                  FETCH c_ret_rsv_costs INTO l_dist_imp_rsv;
                  CLOSE c_ret_rsv_costs;
                else
                  OPEN c_ret_rsv_costs_mrc (adj_row.distribution_id,
                                            l_new_dist_id,
                                            'RETIREMENT',
                                            'IMPAIR RESERVE');
                  FETCH c_ret_rsv_costs_mrc INTO l_dist_imp_rsv;
                  CLOSE c_ret_rsv_costs_mrc;
               end if;

             else
               l_adj_type := 'CIP COST';
               l_dist_reserve := 0;
             end if;

             if (ret.mrc_sob_type_code <> 'R') then
               OPEN c_ret_rsv_costs (adj_row.distribution_id,
                                     l_new_dist_id,
                                     adj_row.source_type_code,
                                     l_adj_type);
               FETCH c_ret_rsv_costs INTO l_dist_cost;
               CLOSE c_ret_rsv_costs;
             else
               OPEN c_ret_rsv_costs_mrc (adj_row.distribution_id,
                                         l_new_dist_id,
                                         adj_row.source_type_code,
                                         l_adj_type);
               FETCH c_ret_rsv_costs_mrc INTO l_dist_cost;
               CLOSE c_ret_rsv_costs_mrc;
             end if;

             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn, '++++ ret.th_id_in',  ret.th_id_in, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, '++++ ret.book',  ret.book, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, '++++ cpd_ctr',  cpd_ctr, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, '++++ adj_row.distribution_id',  adj_row.distribution_id, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, '++++ adj_row.source_type_code',  adj_row.source_type_code, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, '++++ l_adj_type',  l_adj_type, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, '++ l_dist_cost', l_dist_cost, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, '++ l_dist_reserve', l_dist_reserve, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, '++ l_dist_imp_rsv', l_dist_imp_rsv, p_log_level_rec => p_log_level_rec);
             end if;

             --commented for bug 3519644
             --adj_row.adjustment_amount := l_dist_cost - l_dist_reserve;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(fname => l_calling_fn,
                                element => '+++ loop_counter',
                                value   => loop_counter, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(fname => l_calling_fn,
                                element => '+++ tot_dist_lines',
                                value   => tot_dist_lines, p_log_level_rec => p_log_level_rec);
            end if;


            /* bug 3519644 */
            if (loop_counter <> tot_dist_lines) then
                --adj_row.adjustment_amount := l_dist_cost - l_dist_reserve - nvl(l_dist_imp_rsv,0);
                -- Bug # 6975088 added NVL to l_dist_imp_rsv
                adj_row.adjustment_amount := l_dist_cost - l_dist_reserve - nvl(l_dist_imp_rsv,0);
            else
                adj_row.adjustment_amount := h_nbv_retired - total_adj_amount;
            end if;

            total_adj_amount := total_adj_amount + adj_row.adjustment_amount;

           /* bug 3519644 */

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(fname => l_calling_fn,
                                element => '+++adjustment_amount for NBV retired',
                                value   => adj_row.adjustment_amount, p_log_level_rec => p_log_level_rec);
            end if;

             if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                               X_last_update_date,
                                               X_last_updated_by,
                                               X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

             end if;

            --Bug 6666666 If SORP is enabled create additional accounting entries
            --            to clear capital adjustment and general fund
            if fa_cache_pkg.fazcbc_record.sorp_enabled_flag = 'Y' then

                l_prev_leveling_flag := adj_row.leveling_flag;
                adj_row.leveling_flag := FALSE;

                --******************************************************
                --       Capital Adjustment
                --******************************************************
                adj_row.adjustment_type   := 'CAPITAL ADJ';
                adj_row.account_type      := 'CAPITAL_ADJ_ACCT';
                adj_row.account           := fa_cache_pkg.fazccb_record.capital_adj_acct;
                adj_row.debit_credit_flag := 'DR';

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Retirement
                                                            - Capital Adjustment', p_log_level_rec => p_log_level_rec);
                end if;

                if not FA_INS_ADJUST_PKG.faxinaj (adj_row,
                                                  X_last_update_date,
                                                  X_last_updated_by,
                                                  X_last_update_login, p_log_level_rec => p_log_level_rec) then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);
                end if;

                --******************************************************
                --       General Fund
                --******************************************************
                adj_row.adjustment_type   := 'GENERAL FUND';
                adj_row.account_type      := 'GENERAL_FUND_ACCT';
                adj_row.account           := fa_cache_pkg.fazccb_record.general_fund_acct;
                adj_row.debit_credit_flag := 'CR';

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add(l_calling_fn,'Calling faxinaj for ', 'Retirement
                                                          - General Fund Balance', p_log_level_rec => p_log_level_rec);
                end if;

                if not FA_INS_ADJUST_PKG.faxinaj (adj_row,
                                                  X_last_update_date,
                                                  X_last_updated_by,
                                                  X_last_update_login, p_log_level_rec => p_log_level_rec) then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);
                end if;

                adj_row.leveling_flag := l_prev_leveling_flag;

            end if; -- If sorp is enabled

          END LOOP;

          --if (ret.units_retired is null and NOT l_unit_ret_in_corp) then
          if (ret.units_retired is null and NOT (l_unit_ret_in_corp and l_balance_tfr_in_tax = 0)) then
            CLOSE c_ret_amount;
          else
            CLOSE c_ret_dists;
          end if;

       end if; -- h_nbv_retired <> 0

       -- +++++ Process for Group Asset +++++
       adj_row.track_member_flag := null;

       if (bk.group_asset_id is not null) and
          (nvl(bk.member_rollup_flag, 'N') = 'N') and
          (h_nbv_retired <> 0) then

             l_asset_hdr_rec_g.asset_id := bk.group_asset_id;
             l_asset_hdr_rec_g.book_type_code := ret.book;
             l_asset_hdr_rec_g.set_of_books_id := ret.set_of_books_id;

             if not FA_UTIL_PVT.get_asset_cat_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec_g,
                   px_asset_cat_rec        => l_asset_cat_rec_g,
                   p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);
             end if;

             if not fa_cache_pkg.fazccb(
                   X_book   => ret.book,
                   X_cat_id => l_asset_cat_rec_g.category_id, p_log_level_rec => p_log_level_rec) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);
             end if;

             OPEN c_get_unit (bk.group_asset_id);
             FETCH c_get_unit INTO adj_row.current_units;
             CLOSE c_get_unit;

             adj_row.asset_id := bk.group_asset_id;
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
             adj_row.selection_retid := 0;
             adj_row.units_retired := 0;

             adj_row.adjustment_type := 'NBV RETIRED';
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             /* commented for bug 3627497 */
             /* if ((ret.proceeds_of_sale + l_g_reserve)>
                 (ret.cost_retired + ret.cost_of_removal)) then
                adj_row.account := nbv_retired_gain_acct;
                adj_row.account_type := 'NBV_RETIRED_GAIN_ACCT';
                adj_row.debit_credit_flag := 'CR';
             else
                adj_row.account := nbv_retired_loss_acct;
                adj_row.account_type := 'NBV_RETIRED_LOSS_ACCT';
                adj_row.debit_credit_flag := 'DR';
             end if;

             adj_row.adjustment_amount := abs((ret.cost_retired + ret.cost_of_removal) -
                                              (ret.proceeds_of_sale + l_g_reserve));
             */

             -- added for bug 3627497
             adj_row.adjustment_amount := ret.cost_retired - nvl(l_g_reserve,0);--bug fix 3639923

              if h_dr_cr_flag = 1 then
                adj_row.account := nbv_retired_gain_acct;
                adj_row.account_type := 'NBV_RETIRED_GAIN_ACCT';
                adj_row.debit_credit_flag := 'DR';
             else
                adj_row.account := nbv_retired_loss_acct;
                adj_row.account_type := 'NBV_RETIRED_LOSS_ACCT';
                adj_row.debit_credit_flag := 'DR';
             end if;

             if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                               X_last_update_date,
                                               X_last_updated_by,
                                               X_last_update_login,
                                               p_log_level_rec => p_log_level_rec)) then
                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);
             end if;

             -- +++++ Set asset id back to member asset +++++
             adj_row.asset_id := ret.asset_id;
       end if; -- (bk.group_asset_id is not null) and


       /* BUG# 2444408
          This error began to occur after the fix for bug 2316862
          which was propagated from pro*c code.
          The remaining part of this revaluation gain/loss logic
          still continue to be called in the same manner
          as done before the fix for bug 2316862 */
       if (ret.units_retired <= 0 or ret.units_retired is null) then

          adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
          adj_row.selection_retid := 0;
          adj_row.units_retired := 0;
       else
          adj_row.selection_mode := FA_STD_TYPES.FA_AJ_RETIRE;
          adj_row.selection_retid := ret.retirement_id;
          adj_row.units_retired := ret.units_retired;
       end if;
       /* End of fix for bug 2444408 */

       if (ret.wip_asset is null or ret.wip_asset <= 0) and
          (h_retire_reval_flag = 1) then

          if ret.reval_rsv_retired <> 0 then
             -- Bug 6666666 : For SORP, the reveal gain/loss should go into
             --               the capital adjustment account
             if fa_cache_pkg.fazcbc_record.sorp_enabled_flag = 'Y' then
                 adj_row.adjustment_type := 'CAPITAL ADJ';
                 l_prev_leveling_flag := adj_row.leveling_flag;
                 adj_row.leveling_flag := FALSE;
             else
                 adj_row.adjustment_type := 'REVAL RSV RET';
             end if;
             adj_row.adjustment_amount := ret.reval_rsv_retired;
             -- bug 418884, should always be CR since the 'REVAL RESERVE' is always DR
             adj_row.debit_credit_flag := 'CR';

            if h_dr_cr_flag = 1 then
               adj_row.account := reval_rsv_retired_gain_acct;
               adj_row.account_type := 'REVAL_RSV_RETIRED_GAIN_ACCT';
            else
               adj_row.account := reval_rsv_retired_loss_acct;
               adj_row.account_type := 'REVAL_RSV_RETIRED_LOSS_ACCT';
            end if;

            adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
            adj_row.set_of_books_id := ret.set_of_books_id;

            if p_log_level_rec.statement_level then
              fa_debug_pkg.add
              (fname   => 'fagurt',
               element => '+++ before faxinaj for REVAL_RSV_RETIRED_GAIN_ACCT',
               value   => adj_row.selection_mode, p_log_level_rec => p_log_level_rec);
            end if;

            if (bk.group_asset_id is not null) and
               (nvl(bk.member_rollup_flag, 'N') = 'N') then
               adj_row.track_member_flag := 'Y';
            else
               adj_row.track_member_flag := null;
            end if;


            if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);

            end if;

            -- Bug 6666666 : Reset the leveling flag to the original
            if fa_cache_pkg.fazcbc_record.sorp_enabled_flag = 'Y' then
                adj_row.leveling_flag := l_prev_leveling_flag;
            end if;

            if p_log_level_rec.statement_level then
              fa_debug_pkg.add
              (fname   => 'fagurt',
               element => '+++ before faxinaj for REVAL_RSV_RETIRED_GAIN_ACCT',
               value   => '', p_log_level_rec => p_log_level_rec);
            end if;

          end if;

         end if;

         --
         -- If this is a member asset, POS and COR needs to be inserted
         -- with group asset id. Also group is not the one retired
         -- so set other parameters accordingly.
         --
         if (bk.group_asset_id is not null) and
            (nvl(bk.member_rollup_flag, 'N') = 'N') then
            adj_row.track_member_flag := null;
            adj_row.asset_id := bk.group_asset_id;
            adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
            adj_row.selection_retid := 0;
            adj_row.units_retired := 0;
         end if;

         /* BUG 2669638: if ret.proceeds_of_sale > 0 then */
         if ret.proceeds_of_sale <> 0 then

            adj_row.adjustment_type := 'PROCEEDS CLR';
            adj_row.adjustment_amount := ret.proceeds_of_sale;
            adj_row.account := proc_of_sale_clearing_acct;
            adj_row.account_type := 'PROCEEDS_OF_SALE_CLEARING_ACCT';
            adj_row.debit_credit_flag := 'DR';
            adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
            adj_row.set_of_books_id := ret.set_of_books_id;

            if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);
            end if;

            -- added for bug 3627497
         if (bk.group_asset_id is not null) and
            (nvl(bk.member_rollup_flag, 'N') = 'N') then
            adj_row.adjustment_type := 'PROCEEDS';
            adj_row.adjustment_amount := ret.proceeds_of_sale;
            adj_row.debit_credit_flag := 'CR';
            adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
            adj_row.set_of_books_id := ret.set_of_books_id;

            if h_dr_cr_flag = 1 then
               adj_row.account := proceeds_of_sale_gain_acct;
               adj_row.account_type := 'PROCEEDS_OF_SALE_GAIN_ACCT';
            else
               adj_row.account := proceeds_of_sale_loss_acct;
               adj_row.account_type := 'PROCEEDS_OF_SALE_LOSS_ACCT';
            end if;

            if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);
            end if;
         end if;
       end if;

       /* BUG 2669638: if ret.cost_of_removal > 0 then */
       if ret.cost_of_removal <> 0 then

          adj_row.adjustment_type := 'REMOVALCOST CLR';
          adj_row.adjustment_amount := ret.cost_of_removal;
          adj_row.account := cost_of_removal_clearing_acct;
          adj_row.account_type := 'COST_OF_REMOVAL_CLEARING_ACCT';
          adj_row.debit_credit_flag := 'CR';
          adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);

          end if;

            -- added for bug 3627497
         if (bk.group_asset_id is not null) and
            (nvl(bk.member_rollup_flag, 'N') = 'N') then
          adj_row.adjustment_type := 'REMOVALCOST';
          adj_row.adjustment_amount := ret.cost_of_removal;
          adj_row.debit_credit_flag := 'DR';
          adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if h_dr_cr_flag = 1 then
             adj_row.account := cost_of_removal_gain_acct;
             adj_row.account_type := 'COST_OF_REMOVAL_GAIN_ACCT';
          else
             adj_row.account := cost_of_removal_loss_acct;
             adj_row.account_type := 'COST_OF_REMOVAL_LOSS_ACCT';
          end if;

          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);

          end if;
        end if;

       end if;

       /* Calculate ITC recaptured */

       if (bk.itc_used > 0) and
          (ret.wip_asset is null or ret.wip_asset <= 0) then

          if not fagitc(ret, bk, cost_frac,p_log_level_rec) then

               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               return(FALSE);

          end if;

       end if;

       return(TRUE);

EXCEPTION
   when others then

            if c_ret_amount%ISOPEN then
               CLOSE c_ret_amount;
            end if;

            if c_ret_dists%ISOPEN then
               CLOSE c_ret_dists;
            end if;

            if c_ret_rsv_costs%ISOPEN then
              CLOSE c_ret_rsv_costs;
            end if;

            if c_ret_rsv_costs_mrc%ISOPEN then
              CLOSE c_ret_rsv_costs_mrc;
            end if;

            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

END FAGURT;

/*===========================================================================*
| NAME        fagpct                                                         |
|                                                                            |
| FUNCTION    Add a cost retired adjustment into FA_ADJUSTMENTS. Credit to   |
|             the asset account.                                             |
|                                                                            |
| HISTORY     08/30/89    R Rumanang      Created                            |
|             05/03/91    M Chan          Rewrote for MPL 9                  |
|             12/31/96    S Behura        Rewrote in PL/SQL                  |
|                                                                            |
*============================================================================*/

FUNCTION fagpct(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                cpd_ctr number, today in date,
                user_id number,
                p_log_level_rec in FA_API_TYPES.log_level_rec_type) return boolean IS

    fagpct_err          exception;

    asset_cost_acct     varchar2(26);
    cip_cost_acct       varchar2(26);
    -- adj_row             FA_STD_TYPES.fa_adj_row_struct;
    adj_row     FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

    h_asset_id          number(15);
    h_ret_id            number(15);
    h_book              varchar2(30);
    h_id_out            number;
    h_cip_cost_acct     varchar2(26);
    h_asset_cost_acct   varchar2(26);
    h_cur_units         number;

    h_cost_retired        number;
    h_adjustment_amount   number;
    h_adjustment_ccid   number;

    l_balance_tfr_in_tax  number;
    l_unit_ret_in_corp    boolean;
    l_ret_id_in_corp    number;

    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UPD_PKG.fagpct';

    l_dummy number;

    BEGIN <<FAGPCT>>

       h_cur_units := 0;
       h_asset_id := ret.asset_id;
       h_ret_id := ret.retirement_id;
       h_book := ret.book;

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'acct segment in fagpct',
             value   => '', p_log_level_rec => p_log_level_rec);
       end if;

       select  asset_cost_acct,
               nvl(cip_cost_acct, '0')
       into    h_asset_cost_acct,
               h_cip_cost_acct
       from    fa_additions_b    faadd,
               fa_category_books facb
       where   faadd.asset_id = h_asset_id
       and     facb.category_id = faadd.asset_category_id
       and     facb.book_type_code = h_book;

       asset_cost_acct := h_asset_cost_acct;
       cip_cost_acct := h_cip_cost_acct;

       adj_row.transaction_header_id := ret.th_id_in;
       adj_row.book_type_code := ret.book;
       adj_row.period_counter_created := cpd_ctr;
       adj_row.asset_id := ret.asset_id;
       adj_row.period_counter_adjusted := cpd_ctr;
       adj_row.last_update_date := today;
       adj_row.current_units := bk.cur_units;
       adj_row.gen_ccid_flag := TRUE;
       adj_row.flush_adj_flag := TRUE;
       adj_row.annualized_adjustment := 0;
       adj_row.code_combination_id := 0;
       adj_row.distribution_id := 0;
       adj_row.selection_retid := 0;
       adj_row.units_retired := 0;
       adj_row.asset_invoice_id := 0;
       adj_row.leveling_flag := FALSE;

       if ret.wip_asset > 0 then
          adj_row.source_type_code := 'CIP RETIREMENT';
          adj_row.account := cip_cost_acct;
          adj_row.account_type := 'CIP_COST_ACCT';
       else
          adj_row.source_type_code := 'RETIREMENT';
          adj_row.account := asset_cost_acct;
          adj_row.account_type := 'ASSET_COST_ACCT';
       end if;

       adj_row.adjustment_type := 'COST';
       adj_row.adjustment_amount := ret.cost_retired;

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'fagpct: ret.units_retired(1)',
             value   => ret.units_retired);
       end if;

       if (ret.units_retired <= 0 or ret.units_retired is null) then

           adj_row.selection_thid := 0;
           adj_row.debit_credit_flag := 'CR';

           if (bk.current_cost = ret.cost_retired) then
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_CLEAR;
           else

             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;

             if (bk.book_class) then
                if NOT faginfo(
                            RET, BK, cpd_ctr,today, user_id
                           ,calling_module => l_calling_fn
                           ,candidate_mode => 'CLEAR_PARTIAL'
                           ,set_adj_row => TRUE
                           ,unit_ret_in_corp => l_unit_ret_in_corp
                           ,ret_id_in_corp => l_ret_id_in_corp
                           ,th_id_out_in_corp => h_id_out
                           ,balance_tfr_in_tax => l_balance_tfr_in_tax
                           ,adj_row => adj_row
                           ,p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  return(FALSE);
                end if;
             end if;

           end if;

           if p_log_level_rec.statement_level then
             fa_debug_pkg.add(l_calling_fn, '++ bk.book_class (TRUE=TAX)', bk.book_class);
             fa_debug_pkg.add(l_calling_fn, '++ ret.th_id_in', ret.th_id_in, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, '++ h_id_out=th_id_out_in_corp', h_id_out, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add(l_calling_fn, '++ adj_row.selection_thid', adj_row.selection_thid, p_log_level_rec => p_log_level_rec);
           end if;

           adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
           adj_row.set_of_books_id := ret.set_of_books_id;

           if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then
              fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
              return(FALSE);

          end if;

       else
            select      distinct nvl(transaction_header_id_out,0)
            into        h_id_out
            from        fa_distribution_history
            where       asset_id = h_asset_id
            and         book_type_code = h_book
            and         retirement_id = h_ret_id;

           /* Fix for Bug#4617352: We have decided to create adj lines only for affected rows
             to avoid rounding issues with remaining rows in partial unit intercompany retirement.
           */
           adj_row.selection_thid := h_id_out;
           adj_row.debit_credit_flag := 'CR';
           adj_row.selection_mode := FA_STD_TYPES.FA_AJ_CLEAR_PARTIAL;
           adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
           adj_row.set_of_books_id := ret.set_of_books_id;

           if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
              fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
              return(FALSE);

           end if;

           adj_row.adjustment_amount := adj_row.amount_inserted-
                                                ret.cost_retired;

/*
            select      nvl(units,0)
            into        h_cur_units
            from        fa_asset_history
            where       asset_id = h_asset_id
            and         date_ineffective is null;
*/

            h_cur_units := 0;

            begin
              select 1
                into l_dummy
              from fa_distribution_history
              where asset_id = h_asset_id
                and date_ineffective is null
                and transaction_header_id_in = h_id_out
                and rownum = 1;


              select sum(nvl(units_assigned,0))
                into h_cur_units
              from fa_distribution_history
              where asset_id = h_asset_id
                and date_ineffective is null
                and transaction_header_id_in = h_id_out;

            exception
              when no_data_found then
                h_cur_units := 0;
            end;

            if (h_cur_units <>0) then

              adj_row.current_units := h_cur_units;
              --adj_row.selection_thid :=  0;
              adj_row.selection_thid := h_id_out;
              adj_row.debit_credit_flag := 'DR';
              adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE_PARTIAL;
              adj_row.leveling_flag := FALSE;
              adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
              adj_row.set_of_books_id := ret.set_of_books_id;

              if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

             end if;

           end if; -- if h_cur_units <> 0


      end if;

      return (TRUE);

EXCEPTION

       when others then

            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

END FAGPCT;

/*======================================================================*
  | Name        farboe                                                  |
  |                                                                     |
  | Function                                                            |
  |     This function is to calculate the back out deprn_expense,       |
  |     reval_expense, and reval_amort we have taken so far and         |
  |     insert them into fa_adjustments table.                          |
  |                                                                     |
  | History     11/13/92        L. Sun          Created                 |
  |                                                                     |
  |             12/31/96        S. Behura       Rewrote into PL/SQL     |
  |             11/08/97        S. Behura      Rewrote into PL/SQL(10.7)|
  *=====================================================================*/

FUNCTION farboe(asset_id number, book in varchar2,
                current_fiscal_yr number, cost_frac in number,
                start_pdnum number, end_pdnum number,
                adj_type in varchar2, pds_per_year number,
                dpr_evenly number, fiscal_year_name in varchar2,
                units_retired number, th_id_in number,
                cpd_ctr number, today in date,
                current_units number, retirement_id number, d_cal in varchar2,
                dpr in out nocopy FA_STD_TYPES.dpr_struct, p_cal in varchar2,
                pds_catchup number, depreciate_lastyr boolean,
                start_pp number, end_pp number,
                mrc_sob_type_code in varchar2,
                ret in fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                p_log_level_rec in FA_API_TYPES.log_level_rec_type) Return BOOLEAN IS

    farboe_err          exception;

    i                   integer;
    m                   integer;
    j                   integer;
    dpr_detail_counter  number;
    dpr_detail_size     number;
    dpr_detail          fa_RET_TYPES.dpr_detail_struct;
    in_dpr_detail       number;
    target_dpr_detail   number;
    expand_array        number;
    tot_backup_deprn    number;
    backup_deprn        number;
    frac_of_fiscal_year number;
    -- adj_row             FA_STD_TYPES.fa_adj_row_struct;
    adj_row             FA_ADJUST_TYPE_PKG.fa_adj_row_struct;
    period_fracs        FA_STD_TYPES.table_fa_cp_struct;

    -- dummy               FA_STD_TYPES.dpr_arr_type;
    dummy_num           number;
    dummy_num2          number;
    dpr_out             FA_STD_TYPES.dpr_out_struct;
    deprn_adjustment    number;

    temp_frac           number;
    temp_pds            number;
    y_begin             integer;
    pp_begin            integer;
    dpy_begin           integer;
    dpp_begin           integer;
    --fy_name             varchar2(20); -- bug 2719715
    /* the length of fy_name should be equal to
       the lenght of FA_FISCAL_YEAR.FISCAL_YEAR_NAME varchar2(30)  */
    --fy_name             varchar2(30); -- bug 2719715
    fy_name   FA_FISCAL_YEAR.FISCAL_YEAR_NAME%TYPE;

    temp_start_pp       number;
    source_type_code    varchar2(30);
    prev_dist_id        number;
    bonus_deprn_exp_acct varchar2(30);
    deprn_exp_acct      varchar2(30);
    impair_exp_acct     varchar2(30);

    h_start_pdnum       number;
    h_end_pdnum         number;
    h_i                 number;
    h_cost_frac         number;
    h_asset_id          number(15);
    h_book              varchar2(30);
    h_bonus_deprn_exp_acct varchar2(30);
    h_impair_exp_acct   varchar2(30);
    h_current_fiscal_yr number;
    h_adj_type          varchar2(16);
    h_adj_amount        number;
    h_dist_id           number(15);
    h_ccid              number;
    h_deprn_amount      number;
    h_annualized_adj    number;
    h_tot_deprn         number;
    h_units_retired     number(15);
    h_retirement_id     number(15);
    h_cpd_ctr           number(15);
    h_same_fy           integer;
    h_rate_source_rule  integer;
    h_dwacq             integer;
    h_depr_first_year_ret integer;
    h_adj_count         number;
    h_ret_count         number;
    h_curr_pd_add       number;
    h_currpd_amount     number;
    h_net_deprn_amount  number;
    h_source_type_code  varchar2(30);
    h_deprn_exp_acct    varchar2(30);
    h_prior_pd_tfr      number;
    h_curr_pd_reinst    number;
    h_old_reinst_trx_id number;
    h_old_reinst_pc     number;
    h_old_ret_pc        number;
    h_ret_prorate_pc    number;
    h_no_of_per_to_exclude      number;

    -- Fix for 4259471
    k                   integer;
    h_start_pd_endpp    number;
    h_start_pd_deprn    number;
    h_temp_startpd_deprn number;
    h_ret_pp            number;
    h_ret_pjdate        number;
    h_pc                number;
    h_start_pd_pc       number;
    deprn_amt           number;
    bonus_deprn_amt     number;
    impairment_amt      number;
    reval_deprn_amt     number;
    reval_amort         number;
    p_pers_per_yr       number(3);
    h_dpr_temp          FA_STD_TYPES.dpr_struct;
    h_amt_to_retain     number;
    h_temp_end_pp       number;

    deprn_start_pnum    number;
    deprn_start_fy      number;


--bug fix 3558253 and 3518604 start
    h_temp_calc number;
    h_adj_exp_row       number;
    h_prior_fy_exp      number;
    h_backout_flag      number;
    h_ytd_deprn         number;
    h_bonus_ytd_deprn   number;  -- bug 3846296
    h_ytd_impairment    number;
    h_pd_num            number;
    h_temp_deprn_tot    number;
    h_fiscal_year       number;
--bug fix 3558253 and 3518604 end

    h_Brow_deprn_reserve number; -- bug 5443855

    l_deprn_exp         number;
    l_bonus_deprn_exp   number;
    l_impairment_exp    number;
    l_asset_fin_rec_new FA_API_TYPES.asset_fin_rec_type;

    h_id_out              number;
    l_balance_tfr_in_tax  number;
    l_unit_ret_in_corp    boolean;
    l_ret_id_in_corp    number;

    h_asset_addition_pc    number := -1;
    h_fully_rsv_pd         number := -1;     --Bug#8978794
    l_same_fy              number := -1;     --Bug#8496694
    h_fiscal_year_name     varchar2(30);     -- Bug 9311291

    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;


    /* The second half of the union was added in order to obtain
     * adjustments amounts for the current open period.  This is
     * neccessary since that period would not have deprn_detail
     * rows yet, and the original select statement would not have
     * returned these adjustment amounts.  --y.i.
     */
    CURSOR DEPRN_ADJ IS
        SELECT  fadd.distribution_id,
                fadh.code_combination_id,
                -1 * h_cost_frac *
                    (decode (h_adj_type,
                             'EXPENSE', fadd.deprn_amount,
                             'BONUS EXPENSE', fadd.bonus_deprn_amount,
                             'IMPAIR EXPENSE', fadd.impairment_amount,
                             'REVAL EXPENSE', fadd.reval_deprn_expense,
                             'REVAL AMORT', fadd.reval_amortization) -
                     nvl(sum(decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                             faadj.adjustment_amount), 0)),
                nvl(SUM(-1 * h_cost_frac *
                        decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                        faadj.adjustment_amount), 0),
                nvl(SUM(-1 * h_cost_frac *
                        decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                        faadj.annualized_adjustment), 0),
                nvl(-1 * h_cost_frac *
                   (decode (h_adj_type,
                            'EXPENSE',(fadd.deprn_amount -
                                        fadd.deprn_adjustment_amount),
                            'BONUS EXPENSE',(fadd.bonus_deprn_amount -
                                        fadd.bonus_deprn_adjustment_amount),
                            'IMPAIR EXPENSE', fadd.impairment_amount,
                            'REVAL EXPENSE', fadd.reval_deprn_expense,
                            'REVAL AMORT', fadd.reval_amortization)),0),
                nvl(-1 * h_cost_frac *
                    (decode (h_adj_type,
                             'EXPENSE', fadd.deprn_amount,
                             'BONUS EXPENSE', fadd.bonus_deprn_amount,
                             'IMPAIR EXPENSE', fadd.impairment_amount,
                             'REVAL EXPENSE', fadd.reval_deprn_expense,
                             'REVAL AMORT', fadd.reval_amortization)),0),
                nvl(faadj.source_type_code, 'DEPRECIATION'),
                fadp.period_counter
                FROM
                    fa_distribution_history     fadh,
                    fa_deprn_detail             fadd,
                    fa_deprn_periods            fadp,
                    fa_adjustments              faadj
                WHERE
                       fadd.asset_id = h_asset_id
                AND    fadd.distribution_id = fadh.distribution_id
                AND    fadd.book_type_code = h_book
                AND    fadd.deprn_source_code = 'D'
                AND    fadd.period_counter = fadp.period_counter
                AND    fadp.period_num = h_i
                AND    fadp.book_type_code = h_book
                AND    fadp.fiscal_year = h_current_fiscal_yr
                AND    faadj.distribution_id(+) = fadd.distribution_id
                AND    faadj.book_type_code(+) = fadd.book_type_code
                AND    faadj.asset_id(+) = fadd.asset_id
                AND    faadj.period_counter_created(+) = fadd.period_counter
                AND    faadj.adjustment_type(+) = h_adj_type
        GROUP BY
                    fadd.distribution_id,
                    fadh.code_combination_id,
                    fadd.deprn_amount,
                    fadd.deprn_adjustment_amount,
                    fadd.bonus_deprn_amount,
                    fadd.bonus_deprn_adjustment_amount,
                    fadd.impairment_amount,
                    fadd.reval_deprn_expense,
                    fadd.reval_amortization,
                    faadj.distribution_id,
                    faadj.source_type_Code,
                    faadj.adjustment_amount,
                    fadp.period_counter
        UNION
        SELECT  fadh.distribution_id,
                fadh.code_combination_id,
                0,
                nvl(SUM(-1 * h_cost_frac *
                        decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                        faadj.adjustment_amount), 0),
                nvl(SUM(-1 * h_cost_frac *
                        decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                        faadj.annualized_adjustment), 0),
                0,
                0,
                nvl(faadj.source_type_code, 'DEPRECIATION'),
                fadp.period_counter
                FROM
                    fa_distribution_history     fadh,
                    fa_deprn_periods            fadp,
                    fa_adjustments              faadj
                WHERE
                       fadp.period_num = h_i
                AND    fadp.book_type_code = h_book
                AND    fadp.fiscal_year = h_current_fiscal_yr
                AND    fadp.period_counter = h_cpd_ctr
                AND    faadj.distribution_id = fadh.distribution_id
                AND    faadj.book_type_code = fadp.book_type_code
                AND    faadj.asset_id = h_asset_id
                AND    faadj.period_counter_created = fadp.period_counter
                AND    faadj.adjustment_type = h_adj_type
        GROUP BY
                    fadh.distribution_id,
                    fadh.code_combination_id,
                    faadj.distribution_id,
                    faadj.source_type_Code,
                    faadj.adjustment_amount,
                    fadp.period_counter;

    CURSOR MRC_DEPRN_ADJ IS
        SELECT  fadd.distribution_id,
                fadh.code_combination_id,
                -1 * h_cost_frac *
                    (decode (h_adj_type,
                             'EXPENSE', fadd.deprn_amount,
                             'BONUS EXPENSE', fadd.bonus_deprn_amount,
                             'IMPAIR EXPENSE', fadd.impairment_amount,
                             'REVAL EXPENSE', fadd.reval_deprn_expense,
                             'REVAL AMORT', fadd.reval_amortization) -
                     nvl(sum(decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                             faadj.adjustment_amount), 0)),
                nvl(SUM(-1 * h_cost_frac *
                        decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                        faadj.adjustment_amount), 0),
                nvl(SUM(-1 * h_cost_frac *
                        decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                        faadj.annualized_adjustment), 0),
                nvl(-1 * h_cost_frac *
                   (decode (h_adj_type,
                            'EXPENSE',(fadd.deprn_amount -
                                        fadd.deprn_adjustment_amount),
                            'BONUS EXPENSE',(fadd.bonus_deprn_amount -
                                        fadd.bonus_deprn_adjustment_amount),
                            'IMPAIR EXPENSE', fadd.impairment_amount,
                            'REVAL EXPENSE', fadd.reval_deprn_expense,
                            'REVAL AMORT', fadd.reval_amortization)),0),
                nvl(-1 * h_cost_frac *
                    (decode (h_adj_type,
                             'EXPENSE', fadd.deprn_amount,
                             'BONUS EXPENSE', fadd.bonus_deprn_amount,
                             'IMPAIR EXPENSE', fadd.impairment_amount,
                             'REVAL EXPENSE', fadd.reval_deprn_expense,
                             'REVAL AMORT', fadd.reval_amortization)),0),
                nvl(faadj.source_type_code, 'DEPRECIATION'),
                fadp.period_counter
                FROM
                    fa_distribution_history     fadh,
                    fa_mc_deprn_detail          fadd,
                    fa_deprn_periods            fadp,
                    fa_mc_adjustments           faadj
                WHERE
                       fadd.asset_id = h_asset_id
                AND    fadd.distribution_id = fadh.distribution_id
                AND    fadd.book_type_code = h_book
                AND    fadd.deprn_source_code = 'D'
                AND    fadd.period_counter = fadp.period_counter
                AND    fadd.set_of_books_id = ret.set_of_books_id
                AND    fadp.period_num = h_i
                AND    fadp.book_type_code = h_book
                AND    fadp.fiscal_year = h_current_fiscal_yr
                AND    faadj.distribution_id(+) = fadd.distribution_id
                AND    faadj.book_type_code(+) = fadd.book_type_code
                AND    faadj.asset_id(+) = fadd.asset_id
                AND    faadj.period_counter_created(+) = fadd.period_counter
                AND    faadj.adjustment_type(+) = h_adj_type
                AND    faadj.set_of_books_id(+) = ret.set_of_books_id
        GROUP BY
                    fadd.distribution_id,
                    fadh.code_combination_id,
                    fadd.deprn_amount,
                    fadd.deprn_adjustment_amount,
                    fadd.bonus_deprn_amount,
                    fadd.bonus_deprn_adjustment_amount,
                    fadd.impairment_amount,
                    fadd.reval_deprn_expense,
                    fadd.reval_amortization,
                    faadj.distribution_id,
                    faadj.source_type_Code,
                    faadj.adjustment_amount,
                    fadp.period_counter
        UNION
        SELECT  fadh.distribution_id,
                fadh.code_combination_id,
                0,
                nvl(SUM(-1 * h_cost_frac *
                        decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                        faadj.adjustment_amount), 0),
                nvl(SUM(-1 * h_cost_frac *
                        decode (faadj.debit_credit_flag, 'DR', 1, -1) *
                        faadj.annualized_adjustment), 0),
                0,
                0,
                nvl(faadj.source_type_code, 'DEPRECIATION'),
                fadp.period_counter
                FROM
                    fa_distribution_history     fadh,
                    fa_deprn_periods            fadp,
                    fa_mc_adjustments           faadj
                WHERE
                       fadp.period_num = h_i
                AND    fadp.book_type_code = h_book
                AND    fadp.fiscal_year = h_current_fiscal_yr
                AND    fadp.period_counter = h_cpd_ctr
                AND    faadj.distribution_id = fadh.distribution_id
                AND    faadj.book_type_code = fadp.book_type_code
                AND    faadj.asset_id = h_asset_id
                AND    faadj.period_counter_created = fadp.period_counter
                AND    faadj.adjustment_type = h_adj_type
                AND    faadj.set_of_books_id = ret.set_of_books_id
        GROUP BY
                    fadh.distribution_id,
                    fadh.code_combination_id,
                    faadj.distribution_id,
                    faadj.source_type_Code,
                    faadj.adjustment_amount,
                    fadp.period_counter;


    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UPD_PKG.farboe';

     --bug6503327
    h_ret_pd_nums               number;
    h_tot_days_in_mon           number;
    l_same_year                 varchar2(1) :='N' ;
    l_tot_days                  number ;
    deprn_start_dp_num          number;
    h_frac                      number;
    h_ytd                       number;

    BEGIN <<FARBOE>>

       if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in farboe', '', p_log_level_rec => p_log_level_rec); end if;

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add('farboe','IN FARBOE',1, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','start_pp',start_pp, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','end_pp',end_pp, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','pds_catchup',pds_catchup, p_log_level_rec => p_log_level_rec);
       end if;

       tot_backup_deprn := 0;
       backup_deprn := 0;
       frac_of_fiscal_year := 0;
       h_cost_frac := 0;
       h_adj_amount := 0;
       h_deprn_amount := 0;
       h_annualized_adj := 0;
       h_tot_deprn := 0;
        h_temp_calc := 0;----bug fix 3558253 and 3518604 start
        h_adj_exp_row := 0;
        h_prior_fy_exp := 0;
        h_backout_flag := 1;
        h_ytd_deprn := 0;
        h_bonus_ytd_deprn := 0;
        h_ytd_impairment := 0;
        h_pd_num := 1;
        h_temp_deprn_tot := 0;--bug fix 3558253 and 3518604 end
       h_start_pdnum := start_pdnum;
       h_end_pdnum := end_pdnum;
       h_cost_frac := cost_frac;
       h_asset_id := asset_id;
       h_book := book;
       h_current_fiscal_yr := current_fiscal_yr;
       h_adj_type := adj_type;
       h_units_retired := units_retired;
       h_retirement_id := retirement_id;
       h_cpd_ctr := cpd_ctr;
       h_Brow_deprn_reserve := 0; -- bug 5443855
       h_fiscal_year_name := fiscal_year_name;  -- Bug 9311291

       if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add('farboe','h_start_pdnum',h_start_pdnum, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','h_end_pdnum',h_end_pdnum, p_log_level_rec => p_log_level_rec);
       end if;


       expand_array := 2;

       for m in 1.. FA_RET_TYPES.FA_DPR_DETAIL_SIZE loop

          dpr_detail.dist_id(m) := 0;
          dpr_detail.ccid(m) := 0;
          dpr_detail.deprn_amount(m) := 0;
          dpr_detail.adj_amount(m) := 0;
          dpr_detail.annualized_adj(m) := 0;

       end loop;

       dpr_detail_size := FA_RET_TYPES.FA_DPR_DETAIL_SIZE;
       dpr_detail_counter := 1;

       -- bug fix 3558253 and 3518604 start

       if mrc_sob_type_code <> 'R' then

                SELECT ytd_deprn, period_num, bonus_ytd_deprn, fiscal_year,
                       ytd_impairment, deprn_reserve
                INTO   h_ytd_deprn, h_pd_num, h_bonus_ytd_deprn, h_fiscal_year,
                       h_ytd_impairment, h_Brow_deprn_reserve
                FROM
                        fa_deprn_summary ds,
                        fa_deprn_periods dp
                WHERE
                        ds.asset_id = h_asset_id
                AND     ds.book_type_code = h_book
                AND     ds.deprn_source_code = 'BOOKS'
                AND     dp.book_type_code = h_book
                AND     dp.period_counter = ds.period_counter;

       else

                SELECT ytd_deprn,period_num, bonus_ytd_deprn, fiscal_year,
                       ytd_impairment, deprn_reserve
                INTO   h_ytd_deprn, h_pd_num, h_bonus_ytd_deprn, h_fiscal_year,
                       h_ytd_impairment, h_Brow_deprn_reserve
                FROM
                        fa_mc_deprn_summary ds,
                        fa_deprn_periods dp
                WHERE
                        ds.asset_id = h_asset_id
                AND     ds.book_type_code = h_book
                AND     ds.deprn_source_code = 'BOOKS'
                AND     ds.set_of_books_id = ret.set_of_books_id
                AND     dp.book_type_code = h_book
                AND     dp.period_counter = ds.period_counter;

       end if;

       -- bug fix 3558253 and 3518604 end

       for i in reverse h_start_pdnum..h_end_pdnum loop

          h_i := i;
          prev_dist_id := 0;

          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('farboe','backing out pd',h_i, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','h_asset_id',h_asset_id, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','h_book',h_book, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','h_adj_type',h_adj_type, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','h_current_fiscal_yr',h_current_fiscal_yr, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','h_cpd_ctr',h_cpd_ctr, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','h_i',h_i, p_log_level_rec => p_log_level_rec);
          end if;

          if mrc_sob_type_code <> 'R' then
               open DEPRN_ADJ;
          else
               open MRC_DEPRN_ADJ;
          end if;


          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('farboe','after open deprn_adj',1, p_log_level_rec => p_log_level_rec);
          end if;

          /* Get the number of adjustments in period being backed out
            Fix for 807256 */

          if mrc_sob_type_code <> 'R' then

            SELECT  count(*)
            INTO    h_ret_count
            FROM
                    fa_deprn_periods            fadp,
                    fa_adjustments              faadj
            WHERE
                    fadp.period_num = h_i
            AND     fadp.book_type_code = h_book
            AND     fadp.fiscal_year = h_current_fiscal_yr
            AND     faadj.book_type_code = h_book
            AND     faadj.asset_id = h_asset_id
            AND     faadj.period_counter_created = fadp.period_counter
            AND     faadj.adjustment_type = h_adj_type
            AND     faadj.source_type_code = 'RETIREMENT'
            AND     faadj.adjustment_amount <> 0;

            SELECT  count(*)
            INTO    h_adj_count
            FROM
                    fa_deprn_periods            fadp,
                    fa_adjustments              faadj
            WHERE
                    fadp.period_num = h_i
            AND     fadp.book_type_code = h_book
            AND     fadp.fiscal_year = h_current_fiscal_yr
            AND     faadj.book_type_code = h_book
            AND     faadj.asset_id = h_asset_id
            AND     faadj.period_counter_created = fadp.period_counter
            AND     faadj.adjustment_type = h_adj_type
            AND     faadj.source_type_code <> 'RETIREMENT'
            AND     faadj.adjustment_amount <> 0;

          else

            SELECT  count(*)
            INTO    h_ret_count
            FROM
                    fa_deprn_periods            fadp,
                    fa_mc_adjustments           faadj
            WHERE
                    fadp.period_num = h_i
            AND     fadp.book_type_code = h_book
            AND     fadp.fiscal_year = h_current_fiscal_yr
            AND     faadj.book_type_code = h_book
            AND     faadj.asset_id = h_asset_id
            AND     faadj.period_counter_created = fadp.period_counter
            AND     faadj.adjustment_type = h_adj_type
            AND     faadj.set_of_books_id = ret.set_of_books_id
            AND     faadj.source_type_code = 'RETIREMENT'
            AND     faadj.adjustment_amount <> 0;

            SELECT  count(*)
            INTO    h_adj_count
            FROM
                    fa_deprn_periods            fadp,
                    fa_mc_adjustments           faadj
            WHERE
                    fadp.period_num = h_i
            AND     fadp.book_type_code = h_book
            AND     fadp.fiscal_year = h_current_fiscal_yr
            AND     faadj.book_type_code = h_book
            AND     faadj.asset_id = h_asset_id
            AND     faadj.period_counter_created = fadp.period_counter
            AND     faadj.adjustment_type = h_adj_type
            AND     faadj.set_of_books_id = ret.set_of_books_id
            AND     faadj.source_type_code <> 'RETIREMENT'
            AND     faadj.adjustment_amount <> 0;

          end if;

          -- Fix for Bug #3941213.  Check if there are any prior period
          -- transfers in this period.
          h_prior_pd_tfr := 0;

          SELECT  count(*)
          INTO    h_prior_pd_tfr
          FROM    fa_deprn_periods dp1,
                  fa_deprn_periods dp2,
                  fa_transaction_headers th
          WHERE   th.asset_id = h_asset_id
          AND     th.book_type_code = h_book
          AND     th.transaction_type_code = 'TRANSFER'
          AND     th.date_effective between dp1.period_open_date
                          and nvl(dp1.period_close_date, sysdate)
          AND     dp1.book_type_code = th.book_type_code
          AND     dp1.period_num = h_i
          AND     dp1.fiscal_year = h_current_fiscal_yr
          AND     th.transaction_date_entered between
                  dp2.calendar_period_open_date and
                  dp2.calendar_period_close_date
          AND     dp2.book_type_code = th.book_type_code
          AND     dp2.period_num < h_i;

          --while deprn_adj%FOUND loop
          loop

             if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add('farboe','top of while loop',1, p_log_level_rec => p_log_level_rec);
             end if;

             h_adj_amount := 0;
             h_deprn_amount := 0;
             h_annualized_adj := 0;

             if mrc_sob_type_code <> 'R' then

                fetch DEPRN_ADJ into
                  h_dist_id,
                  h_ccid,
                  h_deprn_amount,
                  h_adj_amount,
                  h_annualized_adj,
                  h_currpd_amount,
                  h_net_deprn_amount,
                  h_source_type_code,
                  h_pc;

                --Bug6503327
                -- Get the number of periods per year in the rate calendar
                if not fa_cache_pkg.fazcct(p_cal, p_log_level_rec => p_log_level_rec) then
                   fa_srvr_msg.add_message(calling_fn => 'fa_gainloss_upd_pkg.farboe',  p_log_level_rec => p_log_level_rec);
                   raise farboe_err;
                end if;

                p_pers_per_yr := fa_cache_pkg.fazcct_record.number_per_fiscal_year;

                if p_pers_per_yr = 365  then
                    if h_i = h_start_pdnum then
                        select fcp2.period_num + 1  - fcp1.period_num, fcp3.end_date + 1 -  fcp3.start_date
                        into   h_ret_pd_nums, h_tot_days_in_mon
                        from   fa_calendar_periods fcp1,
                                fa_calendar_periods fcp2,
                                fa_calendar_periods fcp3
                        where  fcp1.calendar_type = p_cal
                        and    bk.ret_prorate_date between fcp1.start_date and fcp1.end_date
                        and    fcp2.calendar_type = fcp1.calendar_type
                        and    fcp3.calendar_type = d_cal
                        and    fcp3.period_num =  h_i
                        and    fcp3.end_date between fcp2.start_date and fcp2.end_date
                        and    to_char(fcp3.start_date,'RRRR') = to_char(bk.ret_prorate_date,'RRRR');

                     end if;

                    -- Bug 9311291 : Need to make sure that fiscal year is also same
                    -- Bug 9411825 : Removed the join between cp.start_date and bk.ret_prorate_date
                    select cp.end_date + 1 -  cp.start_date
                    into   h_tot_days_in_mon
                    from fa_calendar_periods cp,
                         fa_fiscal_year fy
                    where  cp.calendar_type = d_cal
                    and cp.period_num =  h_i
                    and fy.fiscal_year_name = h_fiscal_year_name
                    and bk.ret_prorate_date between fy.start_date and fy.end_date
                    and cp.start_date between fy.start_date and fy.end_date;

                end if;

                if (DEPRN_ADJ%NOTFOUND) then
                   --bug fix 3558253 and 3518604 start
                   if ((h_ytd_deprn <> 0) and (h_pd_num <> 0) and
                       (h_pd_num >= h_i) and
                       (h_fiscal_year = h_current_fiscal_yr) and
                       (DEPRN_ADJ%ROWCOUNT = 0)) then

                      -- Fix for Bug #4601712: h_start_pdnum should be taken into account for assets added in the middle of the current fy
                      -- Fix for Bug #3846296.  Separate out bonus.
                      if (adj_type = 'BONUS EXPENSE') then

                         h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                             ((nvl(h_bonus_ytd_deprn,0) / (h_pd_num - h_start_pdnum + 1)) *
                               h_cost_frac);
                      elsif (adj_type = 'IMPAIR EXPENSE') then

                         h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                             ((nvl(h_ytd_impairment,0) / (h_pd_num - h_start_pdnum + 1)) * h_cost_frac);

                      else

                         -- bug6503327 begins
                         -- added the if condition
                         -- Added the below logic so that the daily prorate conv can be taken
                         -- into account during retirement
                         -- Also changed the logic of temp_deprn_tot

                            begin
                                select 'Y'
                                into  l_same_year
                                from fa_transaction_headers th,
                                fa_deprn_periods dp
                                where  th.asset_id =  h_asset_id
                                and    th.book_type_code = h_book
                                and    th.transaction_type_code = 'ADDITION'
                                and    dp.book_type_code = th.book_type_code
                                and    th.date_effective between  dp.period_open_date and dp.period_close_date
                                and    to_char(th.transaction_date_entered,'RRRR') = dp.fiscal_year;
                             exception
                                when others then
                                        l_same_year := 'N';
                           end;
                           if not fa_cache_pkg.fazccp(p_cal, fiscal_year_name,
                                                        bk.deprn_start_jdate,
                                                        deprn_start_pnum, deprn_start_fy, dummy_num, p_log_level_rec => p_log_level_rec) then
                                               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                                               raise farboe_err;
                           end if;
                           if not fa_cache_pkg.fazccp(d_cal, fiscal_year_name,
                                                        bk.deprn_start_jdate,
                                                        deprn_start_dp_num, deprn_start_fy, dummy_num, p_log_level_rec => p_log_level_rec) then
                                               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                                               raise farboe_err;
                           end if;
                           if p_log_level_rec.statement_level then
                                fa_debug_pkg.add('farboe','l_same_year',l_same_year, p_log_level_rec => p_log_level_rec);
                                fa_debug_pkg.add('farboe',' deprn_start_pnum',deprn_start_pnum, p_log_level_rec => p_log_level_rec);
                                fa_debug_pkg.add('farboe',' deprn_start_pnum',deprn_start_dp_num, p_log_level_rec => p_log_level_rec);
                           end if;
                           if l_same_year = 'Y' then
                                if p_pers_per_yr = 365  then

                                   select to_char(trunc(dp.calendar_period_open_date),'J')-
                                                       to_char(trunc(th.transaction_date_entered),'J')
                                   into  l_tot_days
                                   from fa_transaction_headers th,
                                   fa_deprn_periods dp
                                   where  th.asset_id =  h_asset_id
                                   and    th.book_type_code = h_book
                                   and    th.transaction_type_code = 'ADDITION'
                                   and    dp.book_type_code = th.book_type_code
                                   and    th.date_effective between  dp.period_open_date and dp.period_close_date
                                   and    to_char(th.transaction_date_entered,'RRRR') = dp.fiscal_year;

                                        if h_i = h_start_pdnum then
                                                h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                                                ((h_ytd_deprn / l_tot_days) * h_ret_pd_nums * h_cost_frac);
                                        else
                                                if dpr_evenly > 0 then
                                                        h_frac := (((1/p_pers_per_yr) * (p_pers_per_yr - deprn_start_pnum + 1))
                                                                   - ((1/ pds_per_year) * (pds_per_year - deprn_start_dp_num)))
                                                                         +((1/ pds_per_year)*(h_pd_num - deprn_start_dp_num));

                                                        h_ytd  := h_ytd_deprn/ h_frac;
                                                        if h_i <> deprn_start_dp_num then

                                                                h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                                                               ((h_ytd * (1/pds_per_year)) * h_cost_frac);
                                                         else
                                                                 h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                                                               ((h_ytd * (((1/p_pers_per_yr) * (p_pers_per_yr - deprn_start_pnum + 1))
                                                                  - ((1/ pds_per_year) * (pds_per_year - deprn_start_dp_num)))) * h_cost_frac);
                                                        end if;
                                                else
                                                        h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                                                        ((h_ytd_deprn / l_tot_days) * h_tot_days_in_mon * h_cost_frac);
                                                end if;
                                        end if;
                                else
                                       h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                                        ((h_ytd_deprn / (h_pd_num - deprn_start_pnum + 1)) * h_cost_frac);
                                end if;
                          else -- if not same year
                                 -- Bug#8616644: Prorating ytd_deprn accordingly in ret_prorate pc.
                                 if h_i = h_start_pdnum and p_pers_per_yr = 365 then
                                          h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                                             (((h_ytd_deprn / (h_pd_num * h_tot_days_in_mon))
                                             * h_ret_pd_nums) * h_cost_frac);
                                 else
                                          h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                                                ((h_ytd_deprn / h_pd_num) * h_cost_frac);
                                 end if;
                         end if; -- if l_same_year = 'Y'
                      end if;

                     if p_log_level_rec.statement_level then
                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'h_ytd_deprn (Fix for 3558253 and 3518604)',
                             value   => h_ytd_deprn);
                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'h_pd_num',
                             value   => h_pd_num, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'h_start_pdnum',
                             value   => h_start_pdnum, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'h_cost_frac',
                             value   => h_cost_frac, p_log_level_rec => p_log_level_rec);
                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'h_temp_deprn_tot',
                             value   => h_temp_deprn_tot, p_log_level_rec => p_log_level_rec);
                     end if;
                   end if;
                   --bug fix 3558253 and 3518604 end

                   exit;
		--Bug#8682782
                elsif (DEPRN_ADJ%FOUND) and p_pers_per_yr = 365 and h_i = h_start_pdnum then
                    h_deprn_amount := (h_deprn_amount * ( h_ret_pd_nums / h_tot_days_in_mon ));
                end if;

             else

                fetch MRC_DEPRN_ADJ into
                  h_dist_id,
                  h_ccid,
                  h_deprn_amount,
                  h_adj_amount,
                  h_annualized_adj,
                  h_currpd_amount,
                  h_net_deprn_amount,
                  h_source_type_code,
                  h_pc;

                if (MRC_DEPRN_ADJ%NOTFOUND) then
                   --bug fix 3558253 and 3518604 start
                   if ((h_ytd_deprn <> 0) and (h_pd_num <> 0) and
                       (h_pd_num >= h_i) and
                       (h_fiscal_year = h_current_fiscal_yr) and
                       (MRC_DEPRN_ADJ%ROWCOUNT = 0)) then

                      -- Fix for Bug #4601712: h_start_pdnum should be taken into account for assets added in the middle of the current fy
                      -- Fix for Bug #3846296.  Separate out bonus.
                      if (adj_type = 'BONUS EXPENSE') then

                         h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                             ((nvl(h_bonus_ytd_deprn,0) / (h_pd_num - h_start_pdnum + 1)) *
                               h_cost_frac);
                      elsif (adj_type = 'IMPAIR EXPENSE') then

                         h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                             ((nvl(h_ytd_impairment,0) / (h_pd_num - h_start_pdnum + 1)) * h_cost_frac);

                      else

                         h_temp_deprn_tot := nvl(h_temp_deprn_tot,0) +
                             ((h_ytd_deprn / (h_pd_num - h_start_pdnum + 1)) * h_cost_frac);
                      end if;
                   end if;
                   --bug fix 3558253 and 3518604 end

                   exit;
                end if;
             end if;

             if p_log_level_rec.statement_level then
                fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'deprn and adj',
                   value   => '', p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('farboe','deprn_adjFOUND',1, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('farboe','h_deprn_amount',h_deprn_amount, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('farboe','h_adj_amount',h_adj_amount, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('farboe','h_currpd_amount',h_currpd_amount, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add('farboe','h_net_deprn_amount',h_net_deprn_amount, p_log_level_rec => p_log_level_rec);
             end if;

             source_type_code := h_source_type_code;

             in_dpr_detail := 0;

             for m in 1..dpr_detail_counter loop

                if (dpr_detail.dist_id(m) = h_dist_id) then

                   in_dpr_detail := 1;
                   target_dpr_detail := m;
                   exit;

                end if;

             end loop;

             if in_dpr_detail > 0 then

/*  Commenting out. Do not add the deprn_amount if there is an adjustment
    at this stage. This does not work if there is more than 1 adjustment
    in the period being backed out. Fix for 807256 -  SNARAYAN
                dpr_detail.deprn_amount(target_dpr_detail) :=
                   dpr_detail.deprn_amount(target_dpr_detail) +
                   h_deprn_amount;
*/

                null;

             else
                if dpr_detail_counter = dpr_detail_size then
                   for m in (dpr_detail_size + 1) ..
                     (FA_RET_TYPES.FA_DPR_DETAIL_SIZE * expand_array) loop

                      dpr_detail.dist_id(m) := 0;
                      dpr_detail.ccid(m) := 0;
                      dpr_detail.deprn_amount(m) := 0;
                      dpr_detail.adj_amount(m) := 0;
                      dpr_detail.annualized_adj(m) := 0;

                   end loop; -- end of loop - for m

                   dpr_detail_size :=
                        fa_RET_TYPES.FA_DPR_DETAIL_SIZE * expand_array;
                   expand_array := expand_array + 1;
                end if;

                dpr_detail.dist_id(dpr_detail_counter) := h_dist_id;
                dpr_detail.ccid(dpr_detail_counter) := h_ccid;

/*  Commenting out. Do not copy the deprn_amount if there is an adjustment
    at this stage. This does not work if there is more than 1 adjustment
    in the period being backed out. Fix for 807256 -  SNARAYAN

                dpr_detail.deprn_amount(dpr_detail_counter) :=
                                                        h_deprn_amount;
*/
                dpr_detail.adj_amount(dpr_detail_counter) :=
                                                        h_adj_amount;
                dpr_detail.annualized_adj(dpr_detail_counter) :=
                                                        h_annualized_adj;

                target_dpr_detail := dpr_detail_counter;
                dpr_detail_counter := dpr_detail_counter + 1;

             end if;

             if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add('farboe','target_dpr_detail',
                                   target_dpr_detail, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add('farboe','dpr_detail_counter',
                                   dpr_detail_counter, p_log_level_rec => p_log_level_rec);
             end if;

             tot_backup_deprn := 0;

        /* check to see if any of the periods being backed out
           is period of addition */

                SELECT  count(*)
                INTO    h_curr_pd_add
                FROM
                        fa_deprn_periods dp,
                        fa_transaction_headers th
                WHERE   th.asset_id = h_asset_id
                AND     th.book_type_code = h_book
                AND     th.transaction_type_code || '' = 'ADDITION'
                AND     th.date_effective between dp.period_open_date
                                and nvl(dp.period_close_date, sysdate)
                AND     dp.book_type_code = th.book_type_code
                AND     dp.period_num = h_i
                AND     dp.fiscal_year = h_current_fiscal_yr;


        /* check to see if any of the periods being backed out
           is period of reinstatement */

            begin

                SELECT  count(*)
                INTO    h_curr_pd_reinst
                FROM
                        fa_deprn_periods dp,
                        fa_transaction_headers th
                WHERE   th.asset_id = h_asset_id
                AND     th.book_type_code = h_book
                AND     th.transaction_type_code || '' = 'REINSTATEMENT'
                AND     th.date_effective between dp.period_open_date
                                and nvl(dp.period_close_date, sysdate)
                AND     dp.book_type_code = th.book_type_code
                AND     dp.period_num = h_i
                AND     dp.fiscal_year = h_current_fiscal_yr;
            exception
               when others then h_curr_pd_reinst := 0;
            end;


            if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add('farboe','h_curr_pd_add',
                                   h_curr_pd_add, p_log_level_rec => p_log_level_rec);
            end if;

--bug fix 3558253 and 3518604 start

            h_backout_flag := 1;

            if(nvl(h_curr_pd_add,0) > 0 )then

              if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add('farboe','++ h_adj_exp_row 1',
                                  h_adj_exp_row, p_log_level_rec => p_log_level_rec);
              end if;

              BEGIN

                     if mrc_sob_type_code <> 'R' then

                        SELECT  sum(nvl(adjustment_amount,0))--bug fix 3905436
                        INTO    h_adj_exp_row
                        FROM
                                fa_adjustments adj,
                                fa_deprn_periods dp,
                                fa_transaction_headers th
                        WHERE
                                th.asset_id = h_asset_id
                        AND     th.book_type_code = h_book
                        AND     th.transaction_type_code || '' = 'ADDITION'
                        AND     adj.source_type_code || '' = 'DEPRECIATION'
                        AND     adj.ADJUSTMENT_type || '' = 'EXPENSE'
                        AND     adj.asset_id = h_asset_id
                        AND     adj.book_type_code = h_book
                        AND     adj.distribution_id = h_dist_id --bug fix 3905436
                        AND     adj.period_counter_created = dp.period_counter
                        AND     th.date_effective between dp.period_open_date
                                        and nvl(dp.period_close_date, sysdate)
                        AND     dp.book_type_code = th.book_type_code
                        AND     dp.period_num = h_i
                        AND     dp.fiscal_year = h_current_fiscal_yr;

                     else

                        SELECT  sum(nvl(adjustment_amount,0))--bug fix 3905436
                        INTO    h_adj_exp_row
                        FROM
                                fa_mc_adjustments adj,
                                fa_deprn_periods dp,
                                fa_transaction_headers th
                        WHERE
                                th.asset_id = h_asset_id
                        AND     th.book_type_code = h_book
                        AND     th.transaction_type_code || '' = 'ADDITION'
                        AND     adj.source_type_code || '' = 'DEPRECIATION'
                        AND     adj.ADJUSTMENT_type || '' = 'EXPENSE'
                        AND     adj.asset_id = h_asset_id
                        AND     adj.book_type_code = h_book
                        AND     adj.set_of_books_id = ret.set_of_books_id
                        AND     adj.distribution_id = h_dist_id --bug fix 3905436
                        AND     adj.period_counter_created = dp.period_counter
                        AND     th.date_effective between dp.period_open_date
                                        and nvl(dp.period_close_date, sysdate)
                        AND     dp.book_type_code = th.book_type_code
                        AND     dp.period_num = h_i
                        AND     dp.fiscal_year = h_current_fiscal_yr;

                     end if;

              EXCEPTION
                   when no_data_found then
                          h_adj_exp_row := -1;
              END;

              if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add('farboe','++ h_adj_exp_row 2',
                                    h_adj_exp_row, p_log_level_rec => p_log_level_rec);
              end if;

              if(nvl(h_adj_exp_row,0) > 0)then

                if mrc_sob_type_code <> 'R' then

                  BEGIN

                     SELECT  PRIOR_FY_EXPENSE
                     INTO    h_prior_fy_exp
                     FROM
                        fa_deprn_summary ds,
                        fa_deprn_periods dp,
                        fa_transaction_headers th
                     WHERE
                             th.asset_id = h_asset_id
                     AND     th.book_type_code = h_book
                     AND     th.transaction_type_code || '' = 'ADDITION'
                     AND     th.date_effective between dp.period_open_date
                                  and nvl(dp.period_close_date, sysdate)
                     AND     ds.asset_id = h_asset_id
                     AND     ds.book_type_code = h_book
                     AND     ds.period_counter = dp.period_counter
                     AND     dp.book_type_code = th.book_type_code
                     AND     dp.period_num = h_i
                     AND     dp.fiscal_year = h_current_fiscal_yr;

                   EXCEPTION
                         when no_data_found then
                              null;
                   END;

                else

                   BEGIN

                     SELECT  PRIOR_FY_EXPENSE
                     INTO    h_prior_fy_exp
                     FROM
                        fa_mc_deprn_summary ds,
                        fa_deprn_periods dp,
                        fa_transaction_headers th
                     WHERE
                             th.asset_id = h_asset_id
                     AND     th.book_type_code = h_book
                     AND     th.transaction_type_code || '' = 'ADDITION'
                     AND     th.date_effective between dp.period_open_date
                                  and nvl(dp.period_close_date, sysdate)
                     AND     ds.asset_id = h_asset_id
                     AND     ds.book_type_code = h_book
                     AND     ds.period_counter = dp.period_counter
                     AND     ds.set_of_books_id = ret.set_of_books_id
                     AND     dp.book_type_code = th.book_type_code
                     AND     dp.period_num = h_i
                     AND     dp.fiscal_year = h_current_fiscal_yr;

                   EXCEPTION
                         when no_data_found then
                              null;
                   END;

                end if;


                if(h_adj_exp_row = nvl(h_prior_fy_exp,0))then
                      h_backout_flag := 0;
                      tot_backup_deprn := 0;
                else
                      h_backout_flag := 1;
                end if;

              end if;

              if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add('farboe','h_prior_fy_exp',
                                   h_prior_fy_exp, p_log_level_rec => p_log_level_rec);
              end if;

            elsif (nvl(h_curr_pd_reinst,0) > 0 )then

              if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add('farboe','START - RET AFTER REINST',
                                    ' ', p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add('farboe','bk.ret_prorate_date',
                                    bk.ret_prorate_date, p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add('farboe','ret.th_id_in',
                                    ret.th_id_in, p_log_level_rec => p_log_level_rec);
              end if;

              begin

                  if mrc_sob_type_code <> 'R' then

                        SELECT  sum(adjustment_amount), max(th.transaction_header_id)
                        INTO    h_adj_exp_row, h_old_reinst_trx_id
                        FROM
                                fa_adjustments adj,
                                fa_deprn_periods dp,
                                fa_transaction_headers th
                        WHERE
                                th.asset_id = h_asset_id
                        AND     th.book_type_code = h_book
                        AND     th.transaction_type_code || '' = 'REINSTATEMENT'
                        AND     adj.source_type_code || '' = 'RETIREMENT'
                        AND     adj.ADJUSTMENT_type || '' = 'EXPENSE'
                        AND     adj.asset_id = h_asset_id
                        AND     adj.book_type_code = h_book
                        AND     adj.distribution_id = h_dist_id --bug fix 3905436
                        AND     adj.period_counter_created = dp.period_counter
                        AND     th.date_effective between dp.period_open_date
                                        and nvl(dp.period_close_date, sysdate)
                        AND     dp.book_type_code = th.book_type_code
                        AND     dp.period_num = h_i
                        AND     dp.fiscal_year = h_current_fiscal_yr;

                  else

                        SELECT  sum(adjustment_amount), max(th.transaction_header_id)
                        INTO    h_adj_exp_row, h_old_reinst_trx_id
                        FROM
                                fa_mc_adjustments adj,
                                fa_deprn_periods dp,
                                fa_transaction_headers th
                        WHERE
                                th.asset_id = h_asset_id
                        AND     th.book_type_code = h_book
                        AND     th.transaction_type_code || '' = 'REINSTATEMENT'
                        AND     adj.source_type_code || '' = 'RETIREMENT'
                        AND     adj.ADJUSTMENT_type || '' = 'EXPENSE'
                        AND     adj.asset_id = h_asset_id
                        AND     adj.book_type_code = h_book
                        AND     adj.distribution_id = h_dist_id --bug fix 3905436
                        AND     adj.period_counter_created = dp.period_counter
                        AND     adj.set_of_books_id = ret.set_of_books_id
                        AND     th.date_effective between dp.period_open_date
                                        and nvl(dp.period_close_date, sysdate)
                        AND     dp.book_type_code = th.book_type_code
                        AND     dp.period_num = h_i
                        AND     dp.fiscal_year = h_current_fiscal_yr;

                  end if;

              exception
                         when no_data_found then
                            h_adj_exp_row := -1;
              end;

              begin

                if mrc_sob_type_code <> 'R' then

                  select dp1.period_counter
                        ,dp2.period_counter
                  into   h_old_reinst_pc
                        ,h_old_ret_pc
                  from   fa_transaction_headers trx,
                         fa_deprn_periods dp1,
                         fa_retirements old_ret,
                         fa_deprn_periods dp2
                  where  trx.transaction_header_id = h_old_reinst_trx_id
                    and  dp1.book_type_code = trx.book_type_code
                    and  trx.transaction_date_entered between dp1.CALENDAR_PERIOD_OPEN_DATE
                                                          and dp1.CALENDAR_PERIOD_CLOSE_DATE
                    and  old_ret.transaction_header_id_out = trx.transaction_header_id
                    and  dp2.book_type_code = trx.book_type_code
                    and  old_ret.date_retired between dp2.CALENDAR_PERIOD_OPEN_DATE
                                                  and dp2.CALENDAR_PERIOD_CLOSE_DATE
                   ;

                  select dp.period_counter
                  into h_ret_prorate_pc
                  from fa_retirements new_ret
                      ,fa_conventions conv
                      ,fa_deprn_periods dp
                  where new_ret.transaction_header_id_in=ret.th_id_in
                    and conv.prorate_convention_code=new_ret.retirement_prorate_convention
                    and new_ret.date_retired between conv.start_date and conv.end_date
                    and dp.book_type_code = new_ret.book_type_code
                    and conv.prorate_date between dp.CALENDAR_PERIOD_OPEN_DATE
                                              and dp.CALENDAR_PERIOD_CLOSE_DATE
                  ;

                else

                  select dp1.period_counter
                        ,dp2.period_counter
                  into   h_old_reinst_pc
                        ,h_old_ret_pc
                  from   fa_transaction_headers trx,
                         fa_deprn_periods dp1,
                         fa_mc_retirements old_ret,
                         fa_deprn_periods dp2
                  where  trx.transaction_header_id = h_old_reinst_trx_id
                    and  dp1.book_type_code = trx.book_type_code
                    and  trx.transaction_date_entered between dp1.CALENDAR_PERIOD_OPEN_DATE
                                                          and dp1.CALENDAR_PERIOD_CLOSE_DATE
                    and  old_ret.transaction_header_id_out = trx.transaction_header_id
                    and  old_ret.set_of_books_id = ret.set_of_books_id
                    and  dp2.book_type_code = trx.book_type_code
                    and  old_ret.date_retired between dp2.CALENDAR_PERIOD_OPEN_DATE
                                                  and dp2.CALENDAR_PERIOD_CLOSE_DATE
                   ;

                  select dp.period_counter
                  into h_ret_prorate_pc
                  from fa_mc_retirements new_ret
                      ,fa_conventions conv
                      ,fa_deprn_periods dp
                  where new_ret.transaction_header_id_in=ret.th_id_in
                    and conv.prorate_convention_code=new_ret.retirement_prorate_convention
                    and new_ret.date_retired between conv.start_date and conv.end_date
                    and new_ret.set_of_books_id = ret.set_of_books_id
                    and dp.book_type_code = new_ret.book_type_code
                    and conv.prorate_date between dp.CALENDAR_PERIOD_OPEN_DATE
                                              and dp.CALENDAR_PERIOD_CLOSE_DATE
                  ;

                end if;

              exception
                   when no_data_found then null;
              end;


              -- backout amount = catchup for reinstatement(=h_adj_exp_row) * (num of periods to backout)/(num of periods for the catchup)
              h_no_of_per_to_exclude := h_cpd_ctr - h_ret_prorate_pc;

              if (p_log_level_rec.statement_level) then
                  fa_debug_pkg.add('farboe','h_old_reinst_pc',
                                   h_old_reinst_pc, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add('farboe','h_old_ret_pc',
                                   h_old_ret_pc, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add('farboe','h_ret_prorate_pc',
                                   h_ret_prorate_pc, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add('farboe','h_adj_exp_row',
                                   h_adj_exp_row, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add('farboe','h_no_of_per_to_exclude',
                                   h_no_of_per_to_exclude, p_log_level_rec => p_log_level_rec);
              end if;

              if h_no_of_per_to_exclude > 0 and (h_old_reinst_pc - h_old_ret_pc) > 0 then
                   backup_deprn := h_adj_exp_row * h_no_of_per_to_exclude / (h_old_reinst_pc - h_old_ret_pc);
              else
                   backup_deprn := 0;
              end if;

              if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add('farboe','backup_deprn',
                                    backup_deprn, p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add('farboe','END - RET AFTER REINST',
                                    ' ', p_log_level_rec => p_log_level_rec);
              end if;

        end if;

--bug fix 3558253 and 3518604 end

             if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add('farboe','before J in reverse',1, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add('farboe','h_start_pdnum',h_start_pdnum, p_log_level_rec => p_log_level_rec);
                 fa_debug_pkg.add('farboe','(i)',i);
             end if;

             if (h_adj_amount <> 0)and( h_backout_flag = 1) and nvl(h_curr_pd_reinst,0) = 0 then
                for j in reverse h_start_pdnum..(i) loop
                   backup_deprn := 0;

                   frac_of_fiscal_year := 0;

                   if dpr_evenly > 0 then
                      if (p_log_level_rec.statement_level) then
                          fa_debug_pkg.add('farboe','J in reverse',2, p_log_level_rec => p_log_level_rec);
                      end if;

                      frac_of_fiscal_year := 1 / pds_per_year;
                   else
                      if (p_log_level_rec.statement_level) then
                          fa_debug_pkg.add('farboe','J in reverse',3, p_log_level_rec => p_log_level_rec);
                          fa_debug_pkg.add('farboe','d_cal',d_cal, p_log_level_rec => p_log_level_rec);
                      end if;

                      if not fa_cache_pkg.fazcff (d_cal, book,
                                        current_fiscal_yr, period_fracs, p_log_level_rec => p_log_level_rec) then
                         fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                         return(FALSE);
                      end if;
                      frac_of_fiscal_year := period_fracs(j-1).frac;
                   end if;

--bug fix 3558253 and 3518604 start
                   if(nvl(h_adj_exp_row,0) <> 0)and (nvl(h_prior_fy_exp,0) <> 0)and
                     (nvl(frac_of_fiscal_year,0) <> 0)and (nvl(h_annualized_adj,0) <> 0)
                   then
                           h_temp_calc := (h_adj_exp_row - h_prior_fy_exp)/(frac_of_fiscal_year * (h_annualized_adj/h_cost_frac));

                           h_temp_calc := abs(trunc(h_temp_calc));
                     if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add('farboe','in calc of h_temp_calc','', p_log_level_rec => p_log_level_rec);
                     end if;
                   end if;

                   if (p_log_level_rec.statement_level) then
                     fa_debug_pkg.add('farboe','h_adj_exp_row', h_adj_exp_row, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add('farboe','h_prior_fy_exp', h_prior_fy_exp, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add('farboe','frac_of_fiscal_year', frac_of_fiscal_year, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add('farboe','h_annualized_adj', h_annualized_adj, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add('farboe','h_cost_frac', h_cost_frac, p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add('farboe','h_temp_calc', h_temp_calc, p_log_level_rec => p_log_level_rec);
                   end if;

                 if(h_temp_calc > 0)then
                   if(j <= h_temp_calc)then
                      backup_deprn := frac_of_fiscal_year * h_annualized_adj;
                      tot_backup_deprn := tot_backup_deprn + backup_deprn;
                    end if;
                 else
                      backup_deprn := frac_of_fiscal_year * h_annualized_adj;
                      tot_backup_deprn := tot_backup_deprn + backup_deprn;
                 end if;
--bug fix 3558253 and 3518604 end
                end loop; -- end of loop - for j

             end if;  -- end of - if h_adj_amount

          /* Take the lesser of the absolute values of the
           * tot_backup_deprn or the h_adj_amount
           * Remember that both values are negative in the compare.   */


           /* Perform this comparison only when annualized_adjustment
            * is not zero. Otherwise add adjustment_amount to tot_backup_deprn
            * Fix for 807256 -  SNARAYAN
            */

             if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add('farboe','h_curr_pd_add',
                                        h_curr_pd_add, p_log_level_rec => p_log_level_rec);
             end if;

             if (h_annualized_adj <> 0) then
                   if (abs(h_adj_amount) < abs(tot_backup_deprn)) then
                      tot_backup_deprn := h_adj_amount;
                   end if;

               /* Add the annualized_adj only when it is in a period
                * other than period of addition as the annualized amount
                * is already factored into deprn_amount in fa_deprn_detail
               */
                   if (h_curr_pd_add = 1) then
                      -- Fix for Bug #3941213.  Don't do this for prior
                      -- period transfer.
                      if (h_prior_pd_tfr = 0) then
                         dpr_detail.deprn_amount(target_dpr_detail) :=
                                dpr_detail.deprn_amount(target_dpr_detail) +
                                        tot_backup_deprn;
                       end if;
                   end if;

             elsif ( nvl(h_curr_pd_reinst,0) > 0 ) then

                   if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add('farboe','START - RET AFTER REINST', '2.1', p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add('farboe','dpr_detail.deprn_amount(target_dpr_detail)'
                                               , dpr_detail.deprn_amount(target_dpr_detail) );
                      fa_debug_pkg.add('farboe','h_adj_amount'
                                               , h_adj_amount , p_log_level_rec => p_log_level_rec);
                      fa_debug_pkg.add('farboe','backup_deprn'
                                               , backup_deprn , p_log_level_rec => p_log_level_rec);
                   end if;

                         dpr_detail.deprn_amount(target_dpr_detail) :=
                                        h_adj_amount + backup_deprn +
                                dpr_detail.deprn_amount(target_dpr_detail);

                   if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add('farboe','NEW dpr_detail.deprn_amount(target_dpr_detail)'
                                               , dpr_detail.deprn_amount(target_dpr_detail) );
                      fa_debug_pkg.add('farboe','END - RET AFTER REINST', '2.9', p_log_level_rec => p_log_level_rec);
                   end if;
             else
           /* else to add adjustment amount to total backup deprn when
              there is no annualized adjustment amount. Add adjustment
              amount only in period other than addition. Since if there
              was adjustment expense in period of addition then it would
              mean it was a retroactive-backdated addition and this would
              means annualized_adj will be or should have a value. In this
              case there is specific logic just above */

                   if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add('farboe','6.1', 6.1, p_log_level_rec => p_log_level_rec);
                   end if;

                   if (h_curr_pd_add = 0) then
                      if (p_log_level_rec.statement_level) then
                         fa_debug_pkg.add('farboe','6.2', 6.2, p_log_level_rec => p_log_level_rec);
                         fa_debug_pkg.add('farboe','h_adj_amount',
                                                h_adj_amount, p_log_level_rec => p_log_level_rec);
                         fa_debug_pkg.add('farboe','target_dpr_detail',
                                                target_dpr_detail, p_log_level_rec => p_log_level_rec);
                      end if;

                      -- Fix for Bug #3941213.  Don't do this for prior
                      -- period transfer.
                      if (h_prior_pd_tfr = 0) then
                         dpr_detail.deprn_amount(target_dpr_detail) :=
                                        h_adj_amount +
                                dpr_detail.deprn_amount(target_dpr_detail);
                      end if;
                      if (p_log_level_rec.statement_level) then
                         fa_debug_pkg.add('farboe','6.2.1', 6.21, p_log_level_rec => p_log_level_rec);
                      end if;
                   end if;
                if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add('farboe','6.3', 6.3, p_log_level_rec => p_log_level_rec);
                end if;
             end if;


       /* Based on the number of adjustments and retirement expense rows
        * add to the total backup deprn. The following was required as
        * fix for 807256. May not be the most elegant but  it works
        * without significant redesign of farboe. Always adding
        * h_deprn_amount which was the difference between deprn_amount
        * in fa_deprn_detail and adjustment_amount in fa_adjustments
        * does not work for all the cases. Instead the following
        * conditional logic adds the amounts correctly. SNARAYAN
       */

              if p_log_level_rec.statement_level then
                 fa_debug_pkg.add('farboe','7',7, p_log_level_rec => p_log_level_rec);
              end if;

             if ((h_adj_count > 0) and (h_ret_count = 0)) then
           /* When there are expense rows other than retirement expense
              add the current period deprn amount once to the total
              being backed out for each distinct distribution */
                 if (prev_dist_id <> h_dist_id) then
                     dpr_detail.deprn_amount(target_dpr_detail) :=
                                h_currpd_amount +
                                 dpr_detail.deprn_amount(target_dpr_detail);
                 end if;
             elsif ((h_adj_count = 0) and (h_ret_count = 0)) then
           /* When there are no expense rows or retirment expense rows
              add the current period deprn amount for each distribution
              fetched to the total being backed out */
                    dpr_detail.deprn_amount(target_dpr_detail) :=
                                h_deprn_amount +
                                dpr_detail.deprn_amount(target_dpr_detail);

             elsif ((h_adj_count = 0) and (h_ret_count > 0) and
                        (h_source_type_code in ('DEPRECIATION', 'RETIREMENT'))) then --bug fix 4995325
                 if (prev_dist_id <> h_dist_id) then
                     dpr_detail.deprn_amount(target_dpr_detail) :=
                                h_currpd_amount +
                                 dpr_detail.deprn_amount(target_dpr_detail);
                 end if;
             elsif ((h_adj_count > 0) and (h_ret_count > 0)) then
                 if (prev_dist_id <> h_dist_id) then
                     dpr_detail.deprn_amount(target_dpr_detail) :=
                                h_currpd_amount +
                                 dpr_detail.deprn_amount(target_dpr_detail);
                 end if;
             end if;
             prev_dist_id := h_dist_id;
             if p_log_level_rec.statement_level then
                fa_debug_pkg.add('farboe','9',9, p_log_level_rec => p_log_level_rec);
             end if;

          end loop; -- end of - while deprn_adj

          if mrc_sob_type_code <> 'R' then
                 close DEPRN_ADJ;
          else
                 close MRC_DEPRN_ADJ;
          end if;

          -- if h_start_pdnum <> h_end_pdnum -1  and h_i = h_start_pdnum + 1 then
          if pds_catchup <> 0  and h_i = h_start_pdnum + 1 then

             h_temp_startpd_deprn := 0;
             for k in 1 .. dpr_detail_counter loop
                h_temp_startpd_deprn := h_temp_startpd_deprn +
                                        dpr_detail.deprn_amount(k);
             end loop; -- end of - for k
          end if;
          if h_i = h_start_pdnum then
             h_start_pd_pc := h_pc;
          end if;

          h_i := i;

       end loop; -- end of - for i in reverse

       if adj_type = 'EXPENSE' then

          adj_row.adjustment_type := 'EXPENSE';
          adj_row.debit_credit_flag := 'DR';

       elsif adj_type = 'BONUS EXPENSE' then

          select nvl(cb.bonus_deprn_expense_acct,'0')
          into h_bonus_deprn_exp_acct
          from fa_additions_b ad,
               fa_category_books cb
          where ad.asset_id = h_asset_id
          and   cb.category_id = ad.asset_category_id
          and   cb.book_type_code = h_book;

          bonus_deprn_exp_acct := h_bonus_deprn_exp_acct;
          adj_row.account := bonus_deprn_exp_acct;
          adj_row.account_type := 'BONUS_DEPRN_EXPENSE_ACCT';
          adj_row.adjustment_type := 'BONUS EXPENSE';
          adj_row.debit_credit_flag := 'DR';

       elsif adj_type = 'IMPAIR EXPENSE' then

          select nvl(cb.impair_expense_acct,'0')
          into h_impair_exp_acct
          from fa_additions_b ad,
               fa_category_books cb
          where ad.asset_id = h_asset_id
          and   cb.category_id = ad.asset_category_id
          and   cb.book_type_code = h_book;

          impair_exp_acct := h_impair_exp_acct;
          adj_row.account := impair_exp_acct;
          adj_row.account_type := 'IMPAIR_EXPENSE_ACCT';
          adj_row.adjustment_type := 'IMPAIR EXPENSE';
          adj_row.debit_credit_flag := 'DR';

       elsif adj_type = 'REVAL EXPENSE' then

          adj_row.adjustment_type := 'REVAL EXPENSE';
          adj_row.debit_credit_flag := 'DR';

       else

          adj_row.adjustment_type := 'REVAL AMORT';
          adj_row.debit_credit_flag := 'DR';

       end if;

    /* BUG# 1400554
       populating the account seg for expense with the value
       in category books
           -- bridgway 09/14/00

       adj_row.account[0] = '\0';
    */

       select  facb.deprn_expense_acct
        into   h_deprn_exp_acct
        from   fa_additions_b    faadd,
               fa_category_books facb,
               fa_book_controls bc
       where   faadd.asset_id = h_asset_id
         and   facb.category_id = faadd.asset_category_id
         and   facb.book_type_code = h_book
         and   bc.book_type_code = facb.book_type_code;

       adj_row.account := h_deprn_exp_acct;

       adj_row.transaction_header_id := th_id_in;
       adj_row.source_type_code := 'RETIREMENT';
       adj_row.book_type_code := book;
       adj_row.period_counter_created := cpd_ctr;
       adj_row.asset_id := asset_id;
       adj_row.period_counter_adjusted := cpd_ctr;
       adj_row.last_update_date := today;

--       adj_row.account_type := 'DEPRN_EXPENSE_ACCT';

--bug fix 4492828 in case of bonus we need to use bonus account as set above
       if (adj_type not in ('BONUS EXPENSE', 'IMPAIR EXPENSE')) then
           adj_row.account_type := 'DEPRN_EXPENSE_ACCT';
       end if;

       adj_row.current_units := current_units;
       adj_row.selection_thid := 0;
       adj_row.flush_adj_flag := TRUE;
       adj_row.annualized_adjustment := 0;
       adj_row.asset_invoice_id := 0;
       adj_row.leveling_flag := TRUE;
       adj_row.gen_ccid_flag := TRUE;
       adj_row.code_combination_id := 0;

       h_tot_deprn := 0;
       h_start_pd_deprn := 0;

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','dpr_detail_counter',dpr_detail_counter, p_log_level_rec => p_log_level_rec);
       end if;

       for m in 1 .. dpr_detail_counter loop
          h_tot_deprn := h_tot_deprn + dpr_detail.deprn_amount(m);
       end loop; -- end of - for m

       h_start_pd_deprn := h_tot_deprn - h_temp_startpd_deprn;

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','h_tot_deprn',h_tot_deprn, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','h_temp_startpd_deprn',
                                     h_temp_startpd_deprn, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','h_start_pd_deprn',h_start_pd_deprn, p_log_level_rec => p_log_level_rec);
       end if;


      /* Bug#4605961 */
      begin
       SELECT  pcal.period_num
       INTO    h_start_pd_endpp
       FROM    fa_calendar_periods pcal,
               fa_deprn_periods dp
       WHERE   calendar_type = p_cal
       AND     dp.book_type_code = h_book
       AND     dp.fiscal_year = h_current_fiscal_yr
       AND     dp.period_num = h_start_pdnum
       AND     dp.calendar_period_close_date
                        between start_date and end_date;
      exception
        when no_data_found then
          h_start_pd_endpp := h_start_pdnum;
      end;


       adj_row.adjustment_amount := h_tot_deprn;

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','h_start_pd_endpp',h_start_pd_endpp, p_log_level_rec => p_log_level_rec);
       end if;

       if mrc_sob_type_code <> 'R' then

          SELECT decode(fy1.fiscal_year, fy2.fiscal_year,1,0),
                    decode(BC.DEPR_FIRST_YEAR_RET_FLAG, 'YES', 1, 0),
                    decode(ctype.depr_when_acquired_flag,'YES',1,0),
                    decode(mt.rate_source_rule,
                                'CALCULATED', 1,
                                'TABLE', 2,
                                'FLAT', 3)
          INTO h_same_fy, h_depr_first_year_ret,
               h_dwacq, h_rate_source_rule
          FROM FA_FISCAL_YEAR fy1,
               FA_FISCAL_YEAR fy2,
               FA_BOOKS bk,
               FA_RETIREMENTS rt,
               FA_CONVENTION_TYPES ctype,
               FA_METHODS mt,
               FA_BOOK_CONTROLS bc
          WHERE   rt.date_retired between
                  fy1.start_date and fy1.end_date
          AND   bk.deprn_start_date between
                     fy2.start_date and fy2.end_date
          AND   rt.asset_id = h_asset_id
          AND   bk.asset_id = h_asset_id
          AND   bk.book_type_code = bc.book_type_code
          AND   bc.book_type_code = h_book
          AND   rt.retirement_id = h_retirement_id
          AND   bk.retirement_id = rt.retirement_id
        AND   bk.transaction_header_id_out is not null
        AND   bk.deprn_method_code = mt.method_code
        AND   nvl(bk.life_in_months,1) = nvl(mt.life_in_months,1)
        AND   bk.prorate_convention_code = ctype.prorate_convention_code
        AND   fy1.fiscal_year_name = bc.fiscal_year_name
        AND   fy2.fiscal_year_name = bc.fiscal_year_name;

      else

         select decode(fy1.fiscal_year, fy2.fiscal_year,1,0),
                    decode(BC.DEPR_FIRST_YEAR_RET_FLAG, 'YES', 1, 0),
                    decode(ctype.depr_when_acquired_flag,'YES',1,0),
                    decode(mt.rate_source_rule,
                                'CALCULATED', 1,
                                'TABLE', 2,
                                'FLAT', 3)
        INTO h_same_fy, h_depr_first_year_ret,
             h_dwacq, h_rate_source_rule
        FROM FA_FISCAL_YEAR fy1,
           FA_FISCAL_YEAR fy2,
           FA_MC_BOOKS bk,
           FA_MC_RETIREMENTS rt,
           FA_CONVENTION_TYPES ctype,
           FA_METHODS mt,
           FA_BOOK_CONTROLS bc
        WHERE   rt.date_retired between
                  fy1.start_date and fy1.end_date
        AND   bk.deprn_start_date between
                     fy2.start_date and fy2.end_date
        AND   bk.set_of_books_id = ret.set_of_books_id
        AND   rt.set_of_books_id = ret.set_of_books_id
        AND   rt.asset_id = h_asset_id
        AND   bk.asset_id = h_asset_id
        AND   bk.book_type_code = bc.book_type_code
        AND   bc.book_type_code = h_book
        AND   rt.retirement_id = h_retirement_id
        AND   bk.retirement_id = rt.retirement_id
        AND   bk.transaction_header_id_out is not null
        AND   bk.deprn_method_code = mt.method_code
        AND   nvl(bk.life_in_months,1) = nvl(mt.life_in_months,1)
        AND   bk.prorate_convention_code = ctype.prorate_convention_code
        AND   fy1.fiscal_year_name = bc.fiscal_year_name
        AND   fy2.fiscal_year_name = bc.fiscal_year_name;

      end if;

    /* If depreciate_lastyr is TRUE then we calculate the fraction of
       expense to backout based on prorate periods. Otherwise we backout
       the entire amount for current fiscal year and it is not necessary
       to calculate the fraction. If depreciate_lastyr in the method is
       TRUE but asset if retired is retired in first year and
       DEPR_FIRST_YEAR_RET_FLAG in book controls is NO then we need to
       back out all the deprn taken so far and there is no need to calculate
       fraction of depreciation to backout.
    */

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe(2)','h_same_fy',h_same_fy);
          fa_debug_pkg.add('farboe(2)','h_depr_first_year_ret',h_depr_first_year_ret);
       end if;

       temp_start_pp := 0;

       -- Get the number of periods per year in the rate calendar
       if not fa_cache_pkg.fazcct(p_cal, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => 'fa_gainloss_ret_pkg.fagfpc',  p_log_level_rec => p_log_level_rec);
          raise farboe_err;
       end if;

       p_pers_per_yr := fa_cache_pkg.fazcct_record.number_per_fiscal_year;

       if p_log_level_rec.statement_level then
           fa_debug_pkg.add('farboe(1.4)','p_pers_per_yr',p_pers_per_yr);
           fa_debug_pkg.add('farboe(1.4)','depreciate_lastyr',depreciate_lastyr);
           fa_debug_pkg.add('farboe(1.4)','h_same_fy',h_same_fy);
           fa_debug_pkg.add('farboe(1.4)','h_depr_first_year_ret',h_depr_first_year_ret);
           fa_debug_pkg.add('farboe(1.4)','================','');
           fa_debug_pkg.add('farboe(1.4)','p_pers_per_yr',p_pers_per_yr);
           fa_debug_pkg.add('farboe(1.4)','h_end_pdnum',h_end_pdnum);
           fa_debug_pkg.add('farboe(1.4)','++h_start_pdnum',h_start_pdnum);
           fa_debug_pkg.add('farboe(1.4)','++bk.pc_fully_reserved',bk.pc_fully_reserved);
           fa_debug_pkg.add('farboe(1.4)','++h_start_pd_pc',h_start_pd_pc);
       end if;

     if p_pers_per_yr <> 365 then
       if (depreciate_lastyr and not

          /*  FIX for BUG#2787098:
             This logic seems to be trasformed wrongly from pro*C code.
             (h_same_fy = 1  and  (not h_depr_first_year_ret = 0))) then
          */
         (h_same_fy = 1  and  (not (h_depr_first_year_ret = 1)))) then
         if (h_same_fy = 1) then

           --  Get the Fiscal Year Name from FA_BOOK_CONTROLS cache
            if not fa_cache_pkg.fazcbc(book, p_log_level_rec => p_log_level_rec) then
             raise farboe_err;

            end if;

          fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;

          -- Get the prorate period, and the corresponding fiscal year
          if not fa_cache_pkg.fazccp(p_cal, fy_name, dpr.prorate_jdate,
                             pp_begin, y_begin, dummy_num, p_log_level_rec => p_log_level_rec) then
             raise farboe_err;

          end if;

          /*  FIX for BUG#2787098:
            Changed dpr.prorate_jdate to dpr.deprn_start_jdate in call fazccp
            to make it in sinc with the pro*c code
          */
          -- Get the depreciation start prorate period
          if not fa_cache_pkg.fazccp(p_cal, fy_name, dpr.deprn_start_jdate,
                             dpp_begin, dpy_begin, dummy_num, p_log_level_rec => p_log_level_rec) then
             raise farboe_err;

          end if;

          /*  FIX for BUG#2787098:
            Changed condition of h_dwacq to make it in sinc with the pro*c code
          */
          if ((start_pp <  pp_begin) and (h_rate_source_rule = 1)) then
              temp_start_pp := pp_begin;
           elsif ((start_pp <  pp_begin) and (h_rate_source_rule <> 1)
                    and (not (h_dwacq = 0))) then
              temp_start_pp :=  pp_begin;
           elsif ((start_pp < pp_begin) and (h_rate_source_rule <> 1)
                    and (h_dwacq = 1)) then
              temp_start_pp :=  dpp_begin;
           else temp_start_pp := start_pp;
           end if;
         else
           temp_start_pp := start_pp;
         end if;

         temp_pds :=  -1 * pds_catchup;
         /*  FIX for BUG#2787098:
             Changed the following to make it in sinc with the pro*c code
             Old code: temp_frac := (end_pp - temp_start_pp) /temp_pds;
         */

         --Bug 5086360 In period of addition end_pp = temp_start_pp
         if (end_pp = temp_start_pp ) then
            temp_frac := 0;
         else
            temp_frac := temp_pds/(end_pp - temp_start_pp);
         end if;

         h_tot_deprn := h_tot_deprn * temp_frac;


         --------------------- Bug 5148828 : NEW APPROACH for Bug#5074257
         -- We can remove the logic above after some more verifications.



         -- Bug 5443855
         begin

            if mrc_sob_type_code <> 'R' then

              select period_counter + 1
              into h_asset_addition_pc
              from fa_deprn_summary
              where asset_id = h_asset_id
              and book_type_code = h_book
              and deprn_source_code = 'BOOKS';

	      -- bug#8496694
	      select decode(dp1.fiscal_year,dp2.fiscal_year,1,0)
	      into l_same_fy
	      from fa_deprn_periods dp1,
	      fa_deprn_periods dp2
	      where dp1.book_type_code = h_book
	      and dp2.book_type_code = dp1.book_type_code
	      and dp1.period_counter = h_asset_addition_pc
	      and dp2.period_counter = h_start_pd_pc;

            else

              select period_counter + 1
              into h_asset_addition_pc
              from fa_mc_deprn_summary
              where asset_id = h_asset_id
              and book_type_code = h_book
              and set_of_books_id = ret.set_of_books_id
              and deprn_source_code = 'BOOKS';

	      -- bug#8496694
	      select decode(dp1.fiscal_year,dp2.fiscal_year,1,0)
	      into l_same_fy
	      from fa_mc_deprn_periods dp1,
	      fa_mc_deprn_periods dp2
	      where dp1.book_type_code = h_book
	      and dp1.set_of_books_id = ret.set_of_books_id
	      and dp2.set_of_books_id = dp1.set_of_books_id
	      and dp2.book_type_code = dp1.book_type_code
	      and dp1.period_counter = h_asset_addition_pc
	      and dp2.period_counter = h_start_pd_pc;

            end if;

            exception
               when no_data_found then null;
         end;

         if p_log_level_rec.statement_level then
           fa_debug_pkg.add('farboe','++ FOR CATCHUP: h_Brow_deprn_reserve', h_Brow_deprn_reserve, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add('farboe','++ FOR CATCHUP: h_asset_addition_pc', h_asset_addition_pc, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add('farboe','++ FOR CATCHUP: h_start_pd_pc (ret prorated pc)', h_start_pd_pc);
         end if;

         -- h_start_pd_pc : the period counter in which the prorated retired_date falls
         -- h_asset_addition_pc : the period counter in which the asset was added (i.e. period of addition)
         -- 7212162
         -- bug#8496694:Added condition to check if prorated ret_pc and poa in same fiscal year
         if h_Brow_deprn_reserve = 0 or (( h_start_pd_pc > nvl(h_asset_addition_pc,0)) and l_same_fy = 1 ) then

           -- Bug# 5018194
           if not fa_cache_pkg.fazccp(p_cal, fiscal_year_name,
                                  bk.deprn_start_jdate,
                                  deprn_start_pnum, deprn_start_fy, dummy_num, p_log_level_rec => p_log_level_rec) then
               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
               raise farboe_err;
           end if;

           if p_log_level_rec.statement_level then
             fa_debug_pkg.add('farboe','++ CATCHUP: ret.th_id_in', ret.th_id_in, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','++ CATCHUP: deprn_start_pnum', deprn_start_pnum, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','++ CATCHUP: h_cost_frac', h_cost_frac, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','++ CATCHUP: h_Brow_deprn_reserve', h_Brow_deprn_reserve, p_log_level_rec => p_log_level_rec);
           end if;

           -- Bug 5738004
           dpr.calc_catchup := TRUE;

           if (not FA_GAINLOSS_DPR_PKG.CALC_CATCHUP(
                              ret                  => ret,
                              BK                   => bk,
                              DPR                  => dpr,
                              calc_catchup         => TRUE, -- (start_pd < cpdnum),
                              x_deprn_exp          => l_deprn_exp,
                              x_bonus_deprn_exp    => l_bonus_deprn_exp,
                              x_impairment_exp     => l_impairment_exp,
                              x_asset_fin_rec_new  => l_asset_fin_rec_new,
                              p_log_level_rec      => p_log_level_rec)) then

                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);

            end if;



           -- Bug 5362790
           -- Bug 5652883 (Removed '=' from if clause)
           -- if deprn_start_pnum >= start_pp and h_same_fy=1  then
           if deprn_start_pnum > start_pp and h_same_fy=1  then
             h_tot_deprn := l_deprn_exp;
           else
--              h_tot_deprn := l_deprn_exp * abs(pds_catchup) / (end_pp - start_pp);

          -- Fix for Bug #5844937/5851102.  To prevent divisor by zero error,
          -- set the h_tot_deprn to 0 when it should have calculated to 0.
          if (l_deprn_exp = 0) or (pds_catchup = 0) or (end_pp = start_pp) then

             h_tot_deprn := 0;
          else
             --Bug#8978794:Made changes when ret_prorate_pc < fully_rsvd_pc
             if bk.fully_reserved then
	        begin
		   select pcal.period_num
                   into    h_fully_rsv_pd
                   from    fa_calendar_periods pcal,
                   fa_deprn_periods dp
                   where   calendar_type = p_cal
                   and     dp.book_type_code = h_book
                   and     dp.fiscal_year = h_current_fiscal_yr
                   and     dp.period_counter = bk.pc_fully_reserved
                   and     dp.calendar_period_close_date
                   between start_date and end_date;

		exception
		   when no_data_found then null;
                end;

	        if p_log_level_rec.statement_level then
                   fa_debug_pkg.add('farboe','++ CATCHUP: h_fully_rsv_pd ', h_fully_rsv_pd, p_log_level_rec => p_log_level_rec);
                end if;
	     end if; --bk.fully_reserved
             --Bug#9466566: To avoid divide by zero error.
             if not ( h_fully_rsv_pd = -1 ) and not ( end_pp = h_fully_rsv_pd + 1 ) then
                h_tot_deprn := l_deprn_exp * abs(pds_catchup) / ((end_pp - start_pp) * ((end_pp - h_fully_rsv_pd) - 1));
             else
                h_tot_deprn := l_deprn_exp * abs(pds_catchup) / (end_pp - start_pp);
             end if;
          end if;

           end if;


           if p_log_level_rec.statement_level then
            fa_debug_pkg.add('farboe','++ CATCHUP: h_same_fy', h_same_fy, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ CATCHUP: l_deprn_exp', l_deprn_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ CATCHUP: pds_catchup', pds_catchup, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ CATCHUP: start_pp', start_pp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ CATCHUP: deprn_start_pnum', deprn_start_pnum, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ CATCHUP: end_pp', end_pp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ CATCHUP: h_tot_deprn', h_tot_deprn, p_log_level_rec => p_log_level_rec);
           end if;

         end if;
       ---------------------


         if p_log_level_rec.statement_level then
           fa_debug_pkg.add('farboe(1.5)','temp_start_pp',temp_start_pp);
           fa_debug_pkg.add('farboe(1.5)','end_pp',end_pp);
           fa_debug_pkg.add('farboe(1.5)','pds_catchup',pds_catchup);
           fa_debug_pkg.add('farboe(1.5)','temp_pds',temp_pds);
           fa_debug_pkg.add('farboe(1.5)','temp_frac',temp_frac);
           fa_debug_pkg.add('farboe(1.5)','h_tot_deprn',h_tot_deprn);
         end if;

       end if;

    -- Bug# 5018194: elsif p_pers_per_yr = 365 and h_start_pdnum <> h_end_pdnum - 1 then  -- p_pds_per year is 365
    elsif p_pers_per_yr = 365 and pds_catchup <> 0
          and nvl(bk.pc_fully_reserved,-1) <> h_start_pd_pc then  -- p_pds_per year is 365

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','IN 365',365, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','++ p_cal',p_cal, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','++ fiscal_year_name',fiscal_year_name, p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('farboe','++ bk.deprn_start_jdate',bk.deprn_start_jdate, p_log_level_rec => p_log_level_rec);
       end if;

       -- Bug fix 5660467(Added if condition to call funtion FA_GAINLOSS_DPR_PKG.CALC_CATCHUP
        -- only when asset was added without reserve)
       if h_Brow_deprn_reserve = 0 then
          -- Bug# 5018194
          if not fa_cache_pkg.fazccp(p_cal, fiscal_year_name,
                                     bk.deprn_start_jdate,
                                    deprn_start_pnum, deprn_start_fy, dummy_num, p_log_level_rec => p_log_level_rec) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                raise farboe_err;
          end if;

         if p_log_level_rec.statement_level then
            fa_debug_pkg.add('farboe','++ deprn_start_fy', deprn_start_fy, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ deprn_start_pnum', deprn_start_pnum, p_log_level_rec => p_log_level_rec);
          end if;

          h_ret_pjdate := to_char(bk.ret_prorate_date, 'J');

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add('farboe','h_ret_pjdate',h_ret_pjdate, p_log_level_rec => p_log_level_rec);
          end if;

          -- Get the depreciation start prorate period
          if not fa_cache_pkg.fazccp(p_cal, fiscal_year_name, h_ret_pjdate,
                            h_ret_pp, dummy_num2, dummy_num, p_log_level_rec => p_log_level_rec) then
               raise farboe_err;
          end if;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add('farboe','h_ret_pp',h_ret_pp, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','start_pp',start_pp, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','h_start_pd_endpp',h_start_pd_endpp, p_log_level_rec => p_log_level_rec);
          end if;

          /* Bug#4347020 */
          h_amt_to_retain :=
                ((h_start_pd_deprn - nvl( -1 * h_adj_exp_row,0))
                          * ((h_ret_pp - start_pp) /
                            ((h_start_pd_endpp - start_pp) + 1)));

          h_amt_to_retain := h_amt_to_retain + (-1 * h_adj_exp_row);


          if not FA_UTILS_PKG.faxrnd(h_start_pd_deprn, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             raise farboe_err;
          end if;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add('farboe','h_tot_deprn - Before', h_tot_deprn, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','h_amt_to_retain - Before', h_amt_to_retain, p_log_level_rec => p_log_level_rec);
          end if;

          h_tot_deprn := h_tot_deprn - h_amt_to_retain;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add('farboe','h_start_pd_deprn',h_start_pd_deprn, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('farboe','OLD: h_tot_deprn',h_tot_deprn, p_log_level_rec => p_log_level_rec);
          end if;

          --------------------- NEW APPROACH for Bug#5074257
          -- We can remove the logic above after some more verifications.

          if p_log_level_rec.statement_level then
               fa_debug_pkg.add('farboe','++ 365 CATCHUP: ret.th_id_in', ret.th_id_in, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('farboe','++ 365 CATCHUP: deprn_start_pnum', deprn_start_pnum, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add('farboe','++ 365 CATCHUP: deprn_start_fy', deprn_start_fy, p_log_level_rec => p_log_level_rec);
          end if;

          if (not FA_GAINLOSS_DPR_PKG.CALC_CATCHUP(
                                 ret                  => ret,
                                 BK                   => bk,
                                 DPR                  => dpr,
                                 calc_catchup         => TRUE, -- (start_pd < cpdnum),
                                 x_deprn_exp          => l_deprn_exp,
                                 x_bonus_deprn_exp    => l_bonus_deprn_exp,
                                 x_impairment_exp     => l_impairment_exp,
                                 x_asset_fin_rec_new  => l_asset_fin_rec_new,
                                 p_log_level_rec      => p_log_level_rec)) then

                       fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                       return(FALSE);

           end if;


          -- Bug 5362790
          -- Bug 5652883 (Removed '=' from if clause)
          -- if deprn_start_pnum >= start_pp and h_same_fy=1  then
           if deprn_start_pnum > start_pp and h_same_fy=1  then
              h_tot_deprn := l_deprn_exp;
           else
--              h_tot_deprn := l_deprn_exp * abs(pds_catchup) / (end_pp - start_pp);

          -- Fix for Bug #5844937/5851102/5870503.  To prevent divisor by
          -- zero error, set the h_tot_deprn to 0 when it should have
          -- calculated to 0.
          if (l_deprn_exp = 0) or (pds_catchup = 0) or (end_pp = start_pp) then

            h_tot_deprn := 0;
          else

            h_tot_deprn := l_deprn_exp * abs(pds_catchup) / (end_pp - start_pp);
          end if;

           end if;
        end if;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add('farboe','++ 365 CATCHUP: h_same_fy', h_same_fy, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ 365 CATCHUP: l_deprn_exp', l_deprn_exp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ 365 CATCHUP: pds_catchup', pds_catchup, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ 365 CATCHUP: start_pp', start_pp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ 365 CATCHUP: deprn_start_pnum', deprn_start_pnum, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ 365 CATCHUP: end_pp', end_pp, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add('farboe','++ 365 CATCHUP: h_tot_deprn', h_tot_deprn, p_log_level_rec => p_log_level_rec);
        end if;

       ---------------------


    -- Bug# 5018194: elsif p_pers_per_yr = 365 and h_start_pdnum = h_end_pdnum - 1 and
    --    bk.pc_fully_reserved = h_start_pd_pc then
    elsif p_pers_per_yr = 365 and h_start_pdnum = h_end_pdnum - 1 and
          nvl(bk.pc_fully_reserved,-1) = h_start_pd_pc then

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','365 prorate and pcfr',h_start_pd_deprn, p_log_level_rec => p_log_level_rec);
       end if;
       h_dpr_temp := dpr;
       h_dpr_temp.rsv_known_flag := TRUE;
       h_dpr_temp.deprn_rsv := 0;
       h_dpr_temp.reval_rsv := 0;
       h_dpr_temp.prior_fy_exp := 0;
       h_dpr_temp.ytd_deprn := 0;
       h_dpr_temp.bonus_deprn_rsv := 0;
       h_dpr_temp.bonus_ytd_deprn := 0;
       h_dpr_temp.impairment_rsv := 0;
       h_dpr_temp.ytd_impairment := 0;
       h_dpr_temp.prior_fy_bonus_exp := 0;
       h_dpr_temp.jdate_retired :=  0;
       h_dpr_temp.ret_prorate_jdate := to_char(bk.ret_prorate_date,'J');

       if not FA_GAINLOSS_DPR_PKG.fagcdp(h_dpr_temp, deprn_amt,
                                bonus_deprn_amt,
                                impairment_amt,
                                reval_deprn_amt,
                                reval_amort, bk.deprn_start_date,
                                bk.d_cal, bk.p_cal, h_start_pdnum,
                                h_start_pdnum,
                                bk.prorate_fy, bk.dsd_fy, bk.prorate_jdate,
                                bk.deprn_start_jdate, p_log_level_rec => p_log_level_rec) then

                fa_srvr_msg.add_message(
                  calling_fn => l_calling_fn,
                  name       => 'FA_RET_GENERIC_ERROR',
                  token1     => 'MODULE',
                  value1     => 'FAGCDP',
                  token2     => 'INFO',
                  value2     => 'depreciation number',
                  token3     => 'ASSET',
                  value3     => ret.asset_number , p_log_level_rec => p_log_level_rec);

                return(FALSE);

       end if;

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','after fagcdp deprn_amt',deprn_amt, p_log_level_rec => p_log_level_rec);
       end if;
-- bug fix 5716178
       if(deprn_amt <> 0)then
          h_temp_end_pp := (h_tot_deprn * ((h_start_pd_endpp - start_pp) + 1)) /
                            deprn_amt;
          h_temp_end_pp := -1 * h_temp_end_pp;
       else
          h_temp_end_pp := 0;
       end if;
       if not FA_UTILS_PKG.faxceil(h_temp_end_pp,
                                   ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
         raise farboe_err;
       end if;

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','after faxceil',h_temp_end_pp, p_log_level_rec => p_log_level_rec);
       end if;

       h_ret_pjdate := to_char(bk.ret_prorate_date, 'J');
       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','h_ret_pjdate',h_ret_pjdate, p_log_level_rec => p_log_level_rec);
       end if;

       -- Get the depreciation start prorate period
       if not fa_cache_pkg.fazccp(p_cal, fiscal_year_name, h_ret_pjdate,
                         h_ret_pp, dummy_num2, dummy_num, p_log_level_rec => p_log_level_rec) then
             raise farboe_err;
       end if;

       if ( (h_ret_pp - start_pp < h_temp_end_pp) and (h_temp_end_pp <> 0)) then
          h_amt_to_retain := h_tot_deprn * ((h_ret_pp - start_pp) /
                                          h_temp_end_pp);
       else h_amt_to_retain := h_tot_deprn;
       end if;

       if not FA_UTILS_PKG.faxrnd(h_amt_to_retain, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          raise farboe_err;
       end if;

       h_tot_deprn := h_tot_deprn - h_amt_to_retain;

    end if; -- 365

       adj_row.adjustment_amount := nvl(h_tot_deprn,0) - nvl(h_temp_deprn_tot,0); --bug fix 3558253 and 3518604 start

       if p_log_level_rec.statement_level then
          fa_debug_pkg.add('farboe','h_tot_deprn final',h_tot_deprn, p_log_level_rec => p_log_level_rec);
       end if;

--bugfix 4380845
         -- Call faxrnd
          if not FA_UTILS_PKG.faxrnd(adj_row.adjustment_amount,book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
              fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
              RAISE farboe_err;
           end if;

       -- if bonus expense amount is zero, skip the following and return
       if (adj_row.adjustment_type = 'BONUS EXPENSE' and
                        adj_row.adjustment_amount = 0 ) then
           return TRUE;
       end if;

       -- if impair expense amount is zero, skip the following and return
       if (adj_row.adjustment_type = 'IMPAIR EXPENSE' and
                        adj_row.adjustment_amount = 0 ) then
           return TRUE;
       end if;

       -- Fix for Bug#2676794
       if (adj_row.adjustment_type = 'REVAL EXPENSE' and
                (adj_row.adjustment_amount = 0 or adj_row.adjustment_amount is null)) then
           return TRUE;
       end if;
       if (adj_row.adjustment_type = 'REVAL AMORT' and
                (adj_row.adjustment_amount = 0 or adj_row.adjustment_amount is null)) then
           return TRUE;
       end if;


       if (units_retired is null or units_retired <= 0) then
                                                -- partial cost retirement

          adj_row.selection_retid := 0;
          adj_row.units_retired := 0;
          adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
          adj_row.mrc_sob_type_code := mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if (bk.book_class) then
             if NOT faginfo(
                            RET, BK, cpd_ctr,today, -1
                           ,calling_module => l_calling_fn
                           ,candidate_mode => 'RETIRE'
                           ,set_adj_row => TRUE
                           ,unit_ret_in_corp => l_unit_ret_in_corp
                           ,ret_id_in_corp => l_ret_id_in_corp
                           ,th_id_out_in_corp => h_id_out
                           ,balance_tfr_in_tax => l_balance_tfr_in_tax
                           ,adj_row => adj_row
                           ,p_log_level_rec => p_log_level_rec
                                       ) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);
             end if;
          end if;


          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return(FALSE);

          end if;

       else  -- partial unit retirement

          adj_row.selection_retid := retirement_id;
          adj_row.units_retired := units_retired;
          adj_row.selection_mode := FA_STD_TYPES.FA_AJ_RETIRE;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add
               (fname   => l_calling_fn,
                element => 'dist and deprn',
                value   => '', p_log_level_rec => p_log_level_rec);
          end if;

          adj_row.mrc_sob_type_code := mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return(FALSE);

          end if;

       end if;

       /* Bug 6666666 : Neutralizing entries for SORP */
       if FA_CACHE_PKG.fazcbc_record.sorp_enabled_flag = 'Y'
            and adj_row.adjustment_type = 'EXPENSE' then
            if not FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                    p_amount                => adj_row.adjustment_amount,
                    p_reversal              => 'N',
                    p_adj                   => adj_row,
                    p_created_by            => NULL,
                    p_creation_date         => NULL,
                    p_last_update_date      => X_last_update_date,
                    p_last_updated_by       => X_last_updated_by,
                    p_last_update_login     => X_last_update_login,
                    p_who_mode              => 'UPDATE',
                    p_log_level_rec => p_log_level_rec) then
                       fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                       return(FALSE);
            end if;
       end if;
       /* End of Bug 6666666 */

       return(TRUE);

    EXCEPTION

       when others then

            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    END FARBOE;

/*==========================================================================*
| NAME          fagpdp                                                      |
|                                                                           |
| FUNCTION                                                                  |
|                                                                           |
|       This function figures out how much depreciation expense needs to be |
| allocated to each cost center (distribution). It inserts the amount into  |
| the FA_ADJUSTMENTS table.                                                 |
|       If the number of periods to be catchup is negative or the           |
| DEPRECIATE_LAST_YEAR_FLAG is set to 'NO', we need to back out depreciation|
| When the flag is set to NO, we need to back out the whole depreciation    |
| taken so far this year.                                                   |
|                                                                           |
|                                                                           |
| HISTORY       1/12/89         R Rumanang      Created                     |
|               6/23/89         R Rumanang      Standarized                 |
|               8/24/89         R Rumanang      Insert to FA_ADJUSTMENTS    |
|               04/15/91        M Chan          Rewritten for MPL 9         |
|               01/02/96        S Behura        Rewritten into PL/SQL       |
*===========================================================================*/

FUNCTION fagpdp(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                dpr in out nocopy FA_STD_TYPES.dpr_struct,
                today in date, pds_catchup number,
                cpd_ctr number, cpdnum number,
                cost_frac in number, deprn_amt in out nocopy number,
                bonus_deprn_amt in out nocopy number,
                impairment_amt in out nocopy number,
                impairment_reserve in out nocopy number,
                reval_deprn_amt in out nocopy number, reval_amort in out number,
                reval_reserve in out nocopy number, user_id number,
                p_log_level_rec in FA_API_TYPES.log_level_rec_type) Return BOOLEAN IS

    fagpdp_err          exception;
    dummy               number;
    fy_name             varchar2(30);
    deprn_start_pnum    number;
    deprn_start_fy      number;
    -- adj_row             FA_STD_TYPES.fa_adj_row_struct;
    adj_row             FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

    h_work_pdnum        number;
    h_stop_pdnum        number;
    h_ret_p_date        date;
    h_d_cal             varchar2(16);
    h_asset_id          number(15);
    h_th_id_in          number(15);
    h_book              varchar2(30);
    h_cpd_ctr           number(15);
    h_deprn_amt         number;
    h_bonus_deprn_amt   number;
    h_impairment_amt    number;
    h_reval_deprn_amt   number;
    h_reval_amort       number;
    h_deprn_exp_acct    varchar2(30);
    h_bonus_deprn_exp_acct varchar2(30);
    h_impair_exp_acct   varchar2(30);

    h_dpis_pr_jdt       number;
        /* new variables for retirements to handle different
           prorate calendars  */

    h_cpp_jstartdate    number;


    h_cpp_jenddate      number;
    h_startpp           number;
    h_endpp             number;
    h_current_fiscal_yr integer;
    h_p_cal             varchar2(30);
    h_fy_name           varchar2(30);
    l_first_fiscal_year integer;

    h_id_out              number;
    l_balance_tfr_in_tax  number;
    l_unit_ret_in_corp    boolean;
    l_ret_id_in_corp    number;


    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;
    l_decision_flag     BOOLEAN; -- Bug# 6920756
    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UPD_PKG.fagpdp';

    BEGIN <<FAGPDP>>

      if p_log_level_rec.statement_level then
         fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 1', '', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, 'pds_catchup=', pds_catchup, p_log_level_rec => p_log_level_rec);
      end if;

       h_book := ret.book;
       h_asset_id := ret.asset_id;
       h_th_id_in := ret.th_id_in;
       h_cpd_ctr := cpd_ctr;
       h_ret_p_date := bk.ret_prorate_date;
       h_d_cal := bk.d_cal;
       h_p_cal := bk.p_cal;
       h_current_fiscal_yr := bk.cpd_fiscal_year;
       h_startpp := 0;
       h_endpp := 0;

       -- Bug#4867806: if (pds_catchup = 0) and (bk.depreciate_lastyr) then
       if (pds_catchup = 0 and bk.depr_first_year_ret = 1) and (bk.depreciate_lastyr) then
          return(TRUE);
       end if;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 3', '', p_log_level_rec => p_log_level_rec);
       end if;

       begin
             select fy.fiscal_year
             into   l_first_fiscal_year
             from   fa_fiscal_year fy,
                    fa_book_controls bc,
                    fa_books bks
             where  bc.book_type_code = ret.book
             and    bc.fiscal_year_name = fy.fiscal_year_name
             and    bks.book_type_code = ret.book
             and    bks.asset_id = ret.asset_id
             and    bks.transaction_header_id_out is null
             and    least(bks.date_placed_in_service,bks.prorate_date) between
                    fy.start_date and fy.end_date;
       exception
          when others then
             -- We're going to assume that if there are errors, the asset is
             -- too old for the calendar, so we'll just set the first year to 0
             l_first_fiscal_year := 0;
       end;


    /* when depreciate_lastyr is FALSE, then we need to back out the whole
       depreaciation taken that year.  Period Num should be the greater
       of the first period this fiscal year or the first 'DEPRN' row.
    */
       -- Bug#4867806: if (pds_catchup <= 0) or (not bk.depreciate_lastyr) then
       if (pds_catchup <= 0) or
          (not bk.depreciate_lastyr)  or
          ( (bk.depr_first_year_ret = 0) and (h_current_fiscal_yr = l_first_fiscal_year) ) then

          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 3', '', p_log_level_rec => p_log_level_rec); end if;
          h_stop_pdnum := cpdnum;

          /* Determine the period number to start marching forward */

          if not fa_cache_pkg.fazcbc(ret.book, p_log_level_rec => p_log_level_rec) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             raise fagpdp_err;
          end if;

          fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;

          if not fa_cache_pkg.fazccp(bk.d_cal, fy_name,
                                     bk.deprn_start_jdate,
                                     deprn_start_pnum, deprn_start_fy, dummy, p_log_level_rec => p_log_level_rec) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             raise fagpdp_err;
          end if;

          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 3.1', '', p_log_level_rec => p_log_level_rec); end if;

          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add('fagpdp','bk.depreciate_lastyr',bk.depreciate_lastyr, p_log_level_rec => p_log_level_rec);
             fa_debug_pkg.add('fagpdp','bk.depr_first_year_ret',bk.depr_first_year_ret, p_log_level_rec => p_log_level_rec);
          end if;

          -- Bug#4867806: if not bk.depreciate_lastyr then
          -- Bug#8665405: Checking if it is in first fiscal year
          if (not bk.depreciate_lastyr) or ((bk.depr_first_year_ret = 0) and (h_current_fiscal_yr = l_first_fiscal_year)) then

             if p_log_level_rec.statement_level then
                  fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 4', '', p_log_level_rec => p_log_level_rec);
             end if;

             if (deprn_start_fy * bk.pers_per_yr + deprn_start_pnum) >=
                (bk.cpd_fiscal_year * bk.pers_per_yr + 1) then

                h_work_pdnum := deprn_start_pnum;

               if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add('fagpdp(1.1)','h_work_pdnum',h_work_pdnum);
               end if;

             else
               h_work_pdnum := 1;

               if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add('fagpdp(1.2)','h_work_pdnum',h_work_pdnum);
               end if;

             end if;

             if p_log_level_rec.statement_level then
                 fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 4.1', '', p_log_level_rec => p_log_level_rec);
             end if;

          else
             /* get the depreciation period in which the retirement
               prorate date falls into */
             if p_log_level_rec.statement_level then
                fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 5', '', p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'h_d_cal', h_d_cal, p_log_level_rec => p_log_level_rec);
                fa_debug_pkg.add(l_calling_fn, 'h_ret_p_date', h_ret_p_date, p_log_level_rec => p_log_level_rec);
             end if;

             begin
                SELECT   cp.period_num
                  INTO   h_work_pdnum
                  FROM   fa_calendar_periods cp
                 WHERE   h_ret_p_date
                         between cp.start_date and cp.end_date
                   AND   cp.calendar_type = h_d_cal;
                EXCEPTION
                   when no_data_found then
                      raise fagpdp_err;
             end; -- end of - select

             if p_log_level_rec.statement_level then
                 fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 5.1.1', '', p_log_level_rec => p_log_level_rec);
             end if;

             if (deprn_start_fy * bk.pers_per_yr + deprn_start_pnum) >=
                (bk.cpd_fiscal_year * bk.pers_per_yr + h_work_pdnum) then

                h_work_pdnum := deprn_start_pnum;

             end if;

             if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add('fagpdp(1.3)','h_work_pdnum',h_work_pdnum);
             end if;

          end if;

          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 3.2', '', p_log_level_rec => p_log_level_rec); end if;

            /* get the first prorate prorate period in h_work_pdnum
               and the last prorate period in h_stop_pdnum to obtain
               the total number of prorate periods in the periods that
               we are backing out. In farboe we will use prorate
               period catchup / total prorate periods to backout the
               correct fraction of expense */

/*
  BUG# 780910: commentting this out so that the start date of the
               is obtained from the calendars table rather than
               from deprn_periods.  In cases where the implementation
               was done in the middle of the year, the prorate period
               may not have been opened (i.e. half-year)  --bridgway 08/23/00

            EXEC SQL
                SELECT  to_number (to_char (dp.calendar_period_open_date, 'J'))
                INTO    :h_cpp_jstartdate
                FROM    fa_deprn_periods dp
                WHERE   dp.book_type_code = :h_book
                AND     dp.fiscal_year = :h_current_fiscal_yr
                AND     dp.period_num = :h_work_pdnum;
*/

                SELECT  to_number (to_char (dcp.start_date, 'J'))
                INTO    h_cpp_jstartdate
                FROM    fa_calendar_periods dcp,
                        fa_fiscal_year fy,
                        fa_book_controls bc
                WHERE   bc.book_type_code = h_book
                AND     bc.fiscal_year_name = fy.fiscal_year_name
                AND     dcp.calendar_type   = h_d_cal
                AND     fy.fiscal_year      = h_current_fiscal_yr
                AND     dcp.period_num      = h_work_pdnum
                AND     dcp.start_date
                             between fy.start_date and fy.end_date;


                /* Bug fix 5652883 In case retrement prorate date lies in the
                same period (as per deprn calendar) as of DPIS prorate date,
                consider greatest of DPIS prorate date and calendar period
                start date of retirement prorate date for calculating start_pp,
                otherwise consider calendar period start date of retirement
                prorate date as was happening earlier */

                BEGIN
                    SELECT to_number (to_char (bk.prorate_date, 'J'))
                    INTO   h_dpis_pr_jdt
                    FROM   fa_books bk,
                           fa_calendar_periods dcp
                    WHERE  bk.book_type_code = ret.book
                    AND    transaction_header_id_out is null
                    AND    asset_id = ret.asset_id
                    AND    dcp.calendar_type   = h_d_cal
                    AND    bk.prorate_date
                           BETWEEN dcp.start_date AND dcp.end_date
                    AND   h_ret_p_date
                           BETWEEN dcp.start_date AND dcp.end_date;
                EXCEPTION
                    WHEN no_data_found then
                        h_dpis_pr_jdt := null;
                END;

                h_cpp_jstartdate := greatest(h_cpp_jstartdate, nvl(h_dpis_pr_jdt, h_cpp_jstartdate));

                -- Bug fix 5652883 ends here


                SELECT  period_num
                INTO    h_startpp
                FROM    fa_calendar_periods
                WHERE   calendar_type = h_p_cal
                AND     to_date (h_cpp_jstartdate,'J')
                        between start_date and end_date;

                SELECT  to_number (to_char (dp.calendar_period_open_date, 'J'))
                INTO    h_cpp_jenddate
                FROM    fa_deprn_periods dp
                WHERE   dp.book_type_code = h_book
                AND     dp.fiscal_year = h_current_fiscal_yr
                AND     dp.period_num = h_stop_pdnum;

                SELECT  period_num
                INTO    h_endpp
                FROM    fa_calendar_periods
                WHERE   calendar_type = h_p_cal
                AND     to_date (h_cpp_jenddate,'J')
                        between start_date and end_date;


        /* The amount to back-off is caculated as follows:
           (cost_retired/Cost for the period we're backing out) *
           [deprn_amount - (adjustment_amount - counter *
                            adjustment per period)]
           Counter is the difference between the period we're backing out and
           the prorate-retirement period. However, if the Absolute value of the
           counter * adj per period is greater than the adjustment amount,
           then use deprn_amount only.
           If the adjustment records were put up by Retirement program, then
           don't use the "counter" part (the adjustment_per_period is 0)
        */

          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'calling farboe', '', p_log_level_rec => p_log_level_rec); end if;

          if (p_log_level_rec.statement_level) then
                 fa_debug_pkg.add('fagpdp(2)','before calling FARBOE','');
          end if;

          if not farboe(ret.asset_id, ret.book, bk.cpd_fiscal_year,
                        cost_frac, h_work_pdnum, h_stop_pdnum, 'EXPENSE',
                        bk.pers_per_yr, ret.dpr_evenly, bk.fiscal_year_name,
                        ret.units_retired, ret.th_id_in, cpd_ctr, today,
                        bk.cur_units,ret.retirement_id, bk.d_cal, dpr,
                        bk.p_cal, pds_catchup, bk.depreciate_lastyr,
                        h_startpp, h_endpp,
                        ret.mrc_sob_type_code,
                        ret,bk,
                        p_log_level_rec) then

             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             raise fagpdp_err;

          end if;

          /* BUG# 1646713
           making bonus to farboe for bonus expense conditional on whether
           a bonus rule has been linked to the asset. Note that once a bonus
           rule has been assigned, it can't be removed, it could only assigned
           to a 0% rule which would back out expense.

              -- bridgway   02/27/01
           */
          if (nvl(bk.bonus_rule,'NONE') <> 'NONE') then

             if not farboe(ret.asset_id, ret.book, bk.cpd_fiscal_year,
                           cost_frac, h_work_pdnum, h_stop_pdnum,
                           'BONUS EXPENSE', bk.pers_per_yr,
                           ret.dpr_evenly, bk.fiscal_year_name,
                           ret.units_retired, ret.th_id_in, cpd_ctr,
                           today, bk.cur_units, ret.retirement_id,
                           bk.d_cal, dpr, bk.p_cal, pds_catchup,
                           bk.depreciate_lastyr,h_startpp, h_endpp,
                           ret.mrc_sob_type_code,
                           ret,bk,
                           p_log_level_rec) then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                raise fagpdp_err;

             end if;

          end if;

          if (impairment_reserve <> 0) then

             if not farboe(ret.asset_id, ret.book, bk.cpd_fiscal_year,
                           cost_frac, h_work_pdnum, h_stop_pdnum,
                           ' EXPENSE', bk.pers_per_yr,
                           ret.dpr_evenly, bk.fiscal_year_name,
                           ret.units_retired, ret.th_id_in, cpd_ctr,
                           today, bk.cur_units, ret.retirement_id,
                           bk.d_cal, dpr, bk.p_cal, pds_catchup,
                           bk.depreciate_lastyr,h_startpp, h_endpp,
                           ret.mrc_sob_type_code,
                           ret,bk,
                           p_log_level_rec) then

                 -- Error in farboe for reval expense
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                raise fagpdp_err;

             end if;
          end if;

          if (bk.current_cost > bk.unrevalued_cost
             or reval_reserve <> 0) then
             if not farboe(ret.asset_id, ret.book, bk.cpd_fiscal_year,
                           cost_frac, h_work_pdnum, h_stop_pdnum,
                           'REVAL EXPENSE', bk.pers_per_yr,
                           ret.dpr_evenly, bk.fiscal_year_name,
                           ret.units_retired, ret.th_id_in, cpd_ctr,
                           today, bk.cur_units, ret.retirement_id,
                           bk.d_cal, dpr, bk.p_cal, pds_catchup,
                           bk.depreciate_lastyr,h_startpp, h_endpp,
                           ret.mrc_sob_type_code,
                           ret,bk,
                           p_log_level_rec) then

                 -- Error in farboe for reval expense
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                raise fagpdp_err;

             end if;

             if not farboe(ret.asset_id, ret.book, bk.cpd_fiscal_year,
                           cost_frac, h_work_pdnum, h_stop_pdnum,
                           'REVAL AMORT', bk.pers_per_yr, ret.dpr_evenly,
                           bk.fiscal_year_name, ret.units_retired,
                           ret.th_id_in, cpd_ctr, today, bk.cur_units,
                           ret.retirement_id, bk.d_cal, dpr,
                           bk.p_cal, pds_catchup, bk.depreciate_lastyr,
                           h_startpp, h_endpp,
                           ret.mrc_sob_type_code,
                           ret,bk,
                           p_log_level_rec) then
                -- Error in farboe for reval amort
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                raise fagpdp_err;

             end if;

          end if; -- end of - if bk.current_cost

       else  -- This must be pds_catchup > 0

          if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 2', '', p_log_level_rec => p_log_level_rec); end if;

          -- Bug#6920756 Using l_decision_flag to judge as asset as fully reserved/ fully extended.
          -- Bug 8211842 : Check if asset has started extended depreciation
          if bk.extended_flag and bk.start_extended then
             l_decision_flag := bk.fully_extended;
          else
             l_decision_flag := bk.fully_reserved;
          end if;

          if not l_decision_flag then -- Bug#6920756
               if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 2.1', '', p_log_level_rec => p_log_level_rec); end if;
            /* BUG# 1400554
               populating the account seg for expense with the value
               in category books
                   -- bridgway 09/14/00

               adj_row.account[0] = '\0';
            */

               select  facb.deprn_expense_acct
               into    h_deprn_exp_acct
               from    fa_additions_b    faadd,
                       fa_category_books facb,
                       fa_book_controls bc
               where   faadd.asset_id = h_asset_id
               and     facb.category_id = faadd.asset_category_id
               and     facb.book_type_code = h_book
               and     bc.book_type_code = facb.book_type_code;

             if p_log_level_rec.statement_level then
                 fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 3', '', p_log_level_rec => p_log_level_rec);
             end if;

             adj_row.account := h_deprn_exp_acct;

             adj_row.transaction_header_id := ret.th_id_in;
             adj_row.asset_invoice_id := 0;
             adj_row.source_type_code := 'RETIREMENT';
             adj_row.book_type_code := ret.book;
             adj_row.period_counter_created := cpd_ctr;
             adj_row.asset_id := ret.asset_id;
             adj_row.period_counter_adjusted := cpd_ctr;
             adj_row.last_update_date := today;
             adj_row.account_type := 'DEPRN_EXPENSE_ACCT';
             adj_row.current_units := bk.cur_units;
             adj_row.selection_thid := 0;
             adj_row.flush_adj_flag := TRUE;
             adj_row.gen_ccid_flag := TRUE;
             adj_row.annualized_adjustment := 0;
             adj_row.code_combination_id := 0;
             adj_row.distribution_id := 0;
             adj_row.leveling_flag := TRUE;

              --
              -- bug3627497: Added following to prevent
              -- non tracked entry for member assets
              --
              if (bk.group_asset_id is not null) and
                 (nvl(bk.member_rollup_flag, 'N') = 'N') then
                adj_row.track_member_flag := 'Y';
              else
                adj_row.track_member_flag := null;
              end if;

             if (ret.units_retired is NULL or ret.units_retired <= 0) then

                if p_log_level_rec.statement_level then
                     fa_debug_pkg.add
                        (l_calling_fn,
                         'in FAGPDP 4', '', p_log_level_rec => p_log_level_rec);
                     fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => 'Insert cost into fa_adj',
                         value   => '', p_log_level_rec => p_log_level_rec);
                end if;

                adj_row.debit_credit_flag := 'DR';
                adj_row.adjustment_type := 'EXPENSE';
                adj_row.adjustment_amount := deprn_amt;
                adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                adj_row.selection_retid := 0;
                adj_row.units_retired := 0;
                adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                adj_row.set_of_books_id := ret.set_of_books_id;


                if (bk.book_class) then
                   if NOT faginfo(
                            RET, BK, cpd_ctr,today, user_id
                           ,calling_module => l_calling_fn
                           ,candidate_mode => 'RETIRE'
                           ,set_adj_row => TRUE
                           ,unit_ret_in_corp => l_unit_ret_in_corp
                           ,ret_id_in_corp => l_ret_id_in_corp
                           ,th_id_out_in_corp => h_id_out
                           ,balance_tfr_in_tax => l_balance_tfr_in_tax
                           ,adj_row => adj_row
                           ,p_log_level_rec => p_log_level_rec) then
                     fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                     return(FALSE);
                   end if;
                end if;


                -- insert expense into fa_adjustments
                if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then
                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

                end if; -- end of - if not FA_INS_ADJUST_PKG.faxinaj

                /* Bug 6666666 : Neutralizing entries for SORP */
                if FA_CACHE_PKG.fazcbc_record.sorp_enabled_flag = 'Y' then
                    if not FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                            p_amount                => deprn_amt,
                            p_reversal              => 'N',
                            p_adj                   => adj_row,
                            p_created_by            => NULL,
                            p_creation_date         => NULL,
                            p_last_update_date      => X_last_update_date,
                            p_last_updated_by       => X_last_updated_by,
                            p_last_update_login     => X_last_update_login,
                            p_who_mode              => 'UPDATE',
                            p_log_level_rec         => p_log_level_rec) then
                            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                            return(FALSE);
                    end if;
                end if;
                /* End of Bug 6666666 */

                if bonus_deprn_amt <> 0 then
                   select nvl(cb.bonus_deprn_expense_acct,'0')
                   into h_bonus_deprn_exp_acct
                   from fa_additions_b ad,
                        fa_category_books cb
                   where ad.asset_id = h_asset_id
                   and   cb.category_id = ad.asset_category_id
                   and   cb.book_type_code = h_book;

                   adj_row.account := h_bonus_deprn_exp_acct;
                   adj_row.account_type := 'BONUS_DEPRN_EXPENSE_ACCT';
                   adj_row.debit_credit_flag := 'DR';
                   adj_row.adjustment_type := 'BONUS EXPENSE';
                   adj_row.adjustment_amount := bonus_deprn_amt;
                   adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                   adj_row.selection_retid := 0;
                   adj_row.units_retired := 0;
                   adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                   adj_row.set_of_books_id := ret.set_of_books_id;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(FALSE);

                   end if; -- end of if not FA_INS_ADJUST_PKG.faxinaj

                end if;

                if impairment_amt <> 0 then
                   select nvl(cb.impair_expense_acct,'0')
                   into h_impair_exp_acct
                   from fa_additions_b ad,
                        fa_category_books cb
                   where ad.asset_id = h_asset_id
                   and   cb.category_id = ad.asset_category_id
                   and   cb.book_type_code = h_book;

                   adj_row.account := h_impair_exp_acct;
                   adj_row.account_type := 'IMPAIR_EXPENSE_ACCT';
                   adj_row.debit_credit_flag := 'DR';
                   adj_row.adjustment_type := 'IMPAIR EXPENSE';
                   adj_row.adjustment_amount := impairment_amt;
                   adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                   adj_row.selection_retid := 0;
                   adj_row.units_retired := 0;
                   adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                   adj_row.set_of_books_id := ret.set_of_books_id;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(FALSE);

                   end if; -- end of if not FA_INS_ADJUST_PKG.faxinaj

                end if;

                --  BUG# 1400554
                --      resetting the account segment to value prior to
                --      the bonus rule logic.  i.e. = cb.deprn_exp_acct
                --      adj_row.account[0] = '\0';

                adj_row.account := h_deprn_exp_acct;
                adj_row.account_type := 'DEPRN_EXPENSE_ACCT';

                if reval_deprn_amt > 0 then

                   adj_row.debit_credit_flag := 'DR';
                   adj_row.adjustment_type := 'REVAL EXPENSE';
                   adj_row.adjustment_amount := reval_deprn_amt;

                -- This is now obsolete.  We do not calculate reval expense
                -- seperately from deprn expense.  All expense is calculated
                -- by the deprn engine.  I am leaving logic to calculate this
                -- in case of future use, but we should not insert the
                -- adjustment rows.

                end if;

                if reval_amort > 0  then

                   adj_row.debit_credit_flag := 'DR';
                   adj_row.adjustment_type := 'REVAL AMORT';
                   adj_row.adjustment_amount := reval_amort;
                   adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                   adj_row.set_of_books_id := ret.set_of_books_id;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(FALSE);

                   end if;

                end if; -- end of - if reval_amort

             else

                adj_row.debit_credit_flag := 'DR';
                adj_row.adjustment_type := 'EXPENSE';
                adj_row.adjustment_amount := deprn_amt;
                adj_row.selection_mode := FA_STD_TYPES.FA_AJ_RETIRE;
                adj_row.selection_retid := ret.retirement_id;
                adj_row.units_retired := ret.units_retired;
                adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                adj_row.set_of_books_id := ret.set_of_books_id;

                if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(FALSE);

                end if;

                /* Bug 6666666 : Neutralizing entries for SORP */
                if FA_CACHE_PKG.fazcbc_record.sorp_enabled_flag = 'Y' then
                    if not FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                            p_amount                => deprn_amt,
                            p_reversal              => 'N',
                            p_adj                   => adj_row,
                            p_created_by            => NULL,
                            p_creation_date         => NULL,
                            p_last_update_date      => X_last_update_date,
                            p_last_updated_by       => X_last_updated_by,
                            p_last_update_login     => X_last_update_login,
                            p_who_mode              => 'UPDATE',
                            p_log_level_rec => p_log_level_rec) then
                              fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                              return(FALSE);
                    end if;
                end if;
                /* End of Bug 6666666 */

                if bonus_deprn_amt <> 0 then

                   select nvl(cb.bonus_deprn_expense_acct,'0')
                   into h_bonus_deprn_exp_acct
                   from fa_additions_b ad,
                        fa_category_books cb
                   where ad.asset_id = h_asset_id
                   and   cb.category_id = ad.asset_category_id
                   and   cb.book_type_code = h_book;

                   adj_row.account := h_bonus_deprn_exp_acct;
                   adj_row.account_type := 'BONUS_DEPRN_EXPENSE_ACCT';
                   adj_row.debit_credit_flag := 'DR';
                   adj_row.adjustment_type := 'BONUS EXPENSE';
                   adj_row.adjustment_amount := bonus_deprn_amt;
                   adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                   adj_row.selection_retid := 0;
                   adj_row.units_retired := 0;
                   adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                   adj_row.set_of_books_id := ret.set_of_books_id;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(FALSE);

                   end if; -- end of  if not FA_INS_ADJUST_PKG.faxinaj

                end if;

                if impairment_amt <> 0 then

                   select nvl(cb.impair_expense_acct,'0')
                   into h_impair_exp_acct
                   from fa_additions_b ad,
                        fa_category_books cb
                   where ad.asset_id = h_asset_id
                   and   cb.category_id = ad.asset_category_id
                   and   cb.book_type_code = h_book;

                   adj_row.account := h_impair_exp_acct;
                   adj_row.account_type := 'IMPAIR_EXPENSE_ACCT';
                   adj_row.debit_credit_flag := 'DR';
                   adj_row.adjustment_type := 'IMPAIR EXPENSE';
                   adj_row.adjustment_amount := impairment_amt;
                   adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                   adj_row.selection_retid := 0;
                   adj_row.units_retired := 0;
                   adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                   adj_row.set_of_books_id := ret.set_of_books_id;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(FALSE);

                   end if; -- end of  if not FA_INS_ADJUST_PKG.faxinaj

                end if;

                --  BUG# 1400554
                --      resetting the account segment to value prior to
                --      the bonus rule logic.  i.e. = cb.deprn_exp_acct
                --      adj_row.account[0] = '\0';

                adj_row.account := h_deprn_exp_acct;
                adj_row.account_type := 'DEPRN_EXPENSE_ACCT';

                if reval_deprn_amt > 0 then

                   adj_row.debit_credit_flag := 'DR';
                   adj_row.adjustment_type := 'REVAL EXPENSE';
                   adj_row.adjustment_amount := reval_deprn_amt;
                   adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                   adj_row.set_of_books_id := ret.set_of_books_id;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(FALSE);

                   end if;

                end if; -- end of - if reval_deprn_amt

                if reval_amort > 0 then

                   adj_row.debit_credit_flag := 'DR';
                   adj_row.adjustment_type := 'REVAL AMORT';
                   adj_row.adjustment_amount := reval_amort;
                   adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                   adj_row.set_of_books_id := ret.set_of_books_id;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(FALSE);

                   end if;

                end if; -- end of - if reval_amort

             end if; -- end of - if (ret.units_retired

          end if; -- end of - if not bk.fully_reserved

       end if; -- end of - if (pds_catchup = 0)

       if p_log_level_rec.statement_level then
           fa_debug_pkg.add(l_calling_fn, 'in FAGPDP 3', '', p_log_level_rec => p_log_level_rec);
       end if;

       h_deprn_amt := 0;
       h_reval_deprn_amt := 0;
       h_reval_amort := 0;
       h_bonus_deprn_amt := 0;
       h_impairment_amt := 0;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'total deprn expense',
               value   => '', p_log_level_rec => p_log_level_rec);
       end if;

       if (ret.mrc_sob_type_code <> 'R') then
         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_deprn_amt
            FROM   FA_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'EXPENSE'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            GROUP BY faadj.transaction_header_id;

          /* Test for a no rows found condition;
          * return zeroes in this case.
          * Set h_found_period_counter to zero also.
          */
            EXCEPTION
               when no_data_found then
                  h_deprn_amt := 0;
         end;

       else

         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_deprn_amt
            FROM   FA_MC_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'EXPENSE'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            AND    faadj.set_of_books_id = ret.set_of_books_id
            GROUP BY faadj.transaction_header_id;

          /* Test for a no rows found condition;
          * return zeroes in this case.
          * Set h_found_period_counter to zero also.
          */
            EXCEPTION
               when no_data_found then
                  h_deprn_amt := 0;
         end;

       end if;

       deprn_amt := h_deprn_amt;

       if (ret.mrc_sob_type_code <> 'R') then
         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_bonus_deprn_amt
            FROM   FA_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'BONUS EXPENSE'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            GROUP BY faadj.transaction_header_id;

          /* Test for a no rows found condition;
          * return zeroes in this case.
          * Set h_found_period_counter to zero also.
          */
            EXCEPTION
               when no_data_found then
                  h_bonus_deprn_amt := 0;
         end;

         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_impairment_amt
            FROM   FA_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'IMPAIR EXPENSE'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            GROUP BY faadj.transaction_header_id;

          /* Test for a no rows found condition;
          * return zeroes in this case.
          * Set h_found_period_counter to zero also.
          */
            EXCEPTION
               when no_data_found then
                  h_impairment_amt := 0;
         end;

       else
         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_bonus_deprn_amt
            FROM   FA_MC_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'BONUS EXPENSE'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            AND    faadj.set_of_books_id = ret.set_of_books_id
            GROUP BY faadj.transaction_header_id;
          /* Test for a no rows found condition;
          * return zeroes in this case.
          * Set h_found_period_counter to zero also.
          */
            EXCEPTION
               when no_data_found then
                  h_bonus_deprn_amt := 0;
         end;

         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_impairment_amt
            FROM   FA_MC_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'IMPAIR EXPENSE'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            AND    faadj.set_of_books_id = ret.set_of_books_id
            GROUP BY faadj.transaction_header_id;
          /* Test for a no rows found condition;
          * return zeroes in this case.
          * Set h_found_period_counter to zero also.
          */
            EXCEPTION
               when no_data_found then
                  h_impairment_amt := 0;
         end;

       end if;

       bonus_deprn_amt := h_bonus_deprn_amt;
       impairment_amt := h_impairment_amt;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'total reval deprn expense',
               value   => '', p_log_level_rec => p_log_level_rec);
       end if;

       if (ret.mrc_sob_type_code <> 'R') then
         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_reval_deprn_amt
            FROM   FA_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'REVAL EXPENSE'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            GROUP BY faadj.transaction_header_id;

         EXCEPTION
            when no_data_found then
               h_reval_deprn_amt := 0;
         end;
       else
         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_reval_deprn_amt
            FROM   FA_MC_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'REVAL EXPENSE'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            AND    faadj.set_of_books_id = ret.set_of_books_id
            GROUP BY faadj.transaction_header_id;

         EXCEPTION
            when no_data_found then
               h_reval_deprn_amt := 0;
         end;
       end if;

       reval_deprn_amt := h_reval_deprn_amt;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'total reval amort',
               value   => '', p_log_level_rec => p_log_level_rec);
       end if;

       if (ret.mrc_sob_type_code <> 'R') then
         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_reval_amort
            FROM   FA_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'REVAL AMORT'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            GROUP BY faadj.transaction_header_id;

         EXCEPTION
            when no_data_found then
               h_reval_amort := 0;
         end;
       else
         begin
            SELECT SUM(faadj.adjustment_amount)
            INTO   h_reval_amort
            FROM   FA_MC_ADJUSTMENTS faadj
            WHERE
                   faadj.transaction_header_id = h_th_id_in
            AND    faadj.source_type_code = 'RETIREMENT'
            AND    faadj.adjustment_type = 'REVAL AMORT'
            AND    faadj.book_type_Code = h_book
            AND    faadj.asset_id = h_asset_id
            AND    faadj.period_counter_created = h_cpd_ctr
            AND    faadj.set_of_books_id = ret.set_of_books_id
            GROUP BY faadj.transaction_header_id;

         EXCEPTION
            when no_data_found then
               h_reval_amort := 0;
         end;
       end if;

       reval_amort := h_reval_amort;

       return(TRUE);


    EXCEPTION

          when others then

            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    END FAGPDP;


/*===========================================================================*
| NAME        fagprv                                                         |
|                                                                            |
| FUNCTION    Calculate reserve retired and insert it into FA_ADJUSTMENTS.   |
|             It returns the  current depreciation reserve before adjusted.  |
|                                                                            |
| HISTORY     08/30/89    R Rumanang      Created                            |
|             11/21/89    R Rumanang      Put distribution_id in adjustments |
|             05/03/91    M Chan          Rewrote for MPL 9                  |
|             01/03/96    S Behura        Rewrote using PL/SQL               |
|                                                                            |
*============================================================================*/

FUNCTION fagprv(ret in out nocopy fa_ret_types.ret_struct,
                bk in out nocopy fa_ret_types.book_struct,
                cpd_ctr number, cost_frac in number,
                today in date, user_id number,
                deprn_amt in out nocopy number, reval_deprn_amt in out number,
                reval_amort in out nocopy number, deprn_reserve in out number,
                reval_reserve in out nocopy number,
                bonus_deprn_amt in out nocopy number,
                bonus_deprn_reserve in out nocopy number,
                impairment_amt in out nocopy number,
                impairment_reserve in out nocopy number,
                p_log_level_rec in FA_API_TYPES.log_level_rec_type) Return BOOLEAN IS

    CURSOR c_get_unit is
      select units
      from   fa_asset_history
      where  asset_id = bk.group_asset_id
      and    transaction_header_id_out is null;

    CURSOR c_get_cost is
      select cost
      from   fa_books
      where  asset_id = bk.group_asset_id
      and    book_type_code = ret.book
      and    date_ineffective is null;

    /* New Fix for Bug# 2791196
       Cleared_reserves cursor will only return
       the RETIREMENT RESERVE DR rows in fa_adjustments for the distributions
       that are active and that are not the newly created rows
       by the partial unit retirement.
       The adj_amount for each of the rows will be updated
       with that of the corresponding row. */


    fagprv_err          exception;

    tot_deprn_reserve   number;
    tot_reval_reserve   number;
    tot_bonus_deprn_reserve number;
    tot_impairment_reserve  number;
    deprn_rsv_acct      varchar2(30);
    reval_rsv_acct      varchar2(30);
    bonus_deprn_rsv_acct varchar2(30);
    impairment_rsv_acct  varchar2(30);
    -- adj_row             FA_STD_TYPES.fa_adj_row_struct;
    adj_row             FA_ADJUST_TYPE_PKG.fa_adj_row_struct;

    h_retire_reval_flag number;
    h_asset_id          number(15);
    h_book              varchar2(30);
    h_ret_id            number(15);
    h_id_out            number(15);
    h_deprn_rsv_acct    varchar2(30);
    h_reval_rsv_acct    varchar2(30);
    h_bonus_deprn_rsv_acct varchar2(30);
    h_impairment_rsv_acct  varchar2(30);
    h_cur_units         number;

    -- Fix for Bug 3441030
    l_prev_deprn_reserve number;
    l_prev_adj_rec_cost  number;
    l_new_adj_rec_cost   number;
    l_final_rsv          number;
    l_fully_rsvd_flag    boolean := FALSE;

    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UPD_PKG.fagprv';

    l_rsv_retired       number := null;
    l_temp_num          number;
    l_temp_char         varchar2(30);
    l_temp_bool         boolean;
    l_g_cost            number;
    l_g_rsv             number;
    l_g_bonus_rsv       number;
    l_g_impair_rsv      number;
    l_asset_hdr_rec   FA_API_TYPES.asset_hdr_rec_type;
    l_asset_cat_rec   FA_API_TYPES.asset_cat_rec_type;

    l_id number;

    l_balance_tfr_in_tax  number;
    l_unit_ret_in_corp    boolean;
    l_ret_id_in_corp    number;


    l_dummy number;
    h_sum_of_part_active_units number;

    BEGIN <<FAGPRV>>

       if p_log_level_rec.statement_level then

          begin
            select retirement_id
            into l_id
            from fa_retirements
            where asset_id=ret.asset_id
              and book_type_code=ret.book;
          exception  when others then null;
              l_id := 0;
          end;

          fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'l_id in fagprv(1)',
               value   => l_id);

          fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'ret.retirement_id in fagprv(1)',
               value   => ret.retirement_id);
       end if;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'cost frac in fagprv',
               value   => to_char(cost_frac)||':'||to_char(ret.reserve_retired));
       end if;

       l_rsv_retired := ret.reserve_retired;

       tot_deprn_reserve := 0;
       tot_bonus_deprn_reserve := 0;
       tot_impairment_reserve := 0;
       tot_reval_reserve := 0;
       h_cur_units := 0;
       h_asset_id := ret.asset_id;
       h_book := ret.book;
       h_ret_id := ret.retirement_id;


       -- Fix for Bug 3441030
       l_prev_deprn_reserve := deprn_reserve;
       select adjusted_recoverable_cost
       into l_prev_adj_rec_cost
       from fa_books
       where transaction_header_id_out = ret.th_id_in;

       if (l_prev_deprn_reserve = l_prev_adj_rec_cost) then
          l_fully_rsvd_flag := TRUE;
          select adjusted_recoverable_cost
          into l_new_adj_rec_cost
          from fa_books
          where transaction_header_id_in = ret.th_id_in;
          l_final_rsv := l_new_adj_rec_cost;
       end if;

       deprn_reserve := deprn_reserve * cost_frac;
       -- fix for 1972854 - cost_frac is set to zero when cost is zero
       -- which causes reval_reserve go zero, thus do the following
       -- multiplication only for non-zero cost_frac
       if cost_frac <> 0 then
          reval_reserve := reval_reserve * cost_frac;

          /* Bug#4459585 rounding issue */
          if not FA_UTILS_PKG.faxrnd(reval_reserve, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            raise fagprv_err;
          end if;

       end if;

       bonus_deprn_reserve := bonus_deprn_reserve * cost_frac;
       impairment_reserve := impairment_reserve * cost_frac;

       /* Bug#4459585 rounding issue */
       if not FA_UTILS_PKG.faxrnd(bonus_deprn_reserve, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          raise fagprv_err;
       end if;

       if not FA_UTILS_PKG.faxrnd(impairment_reserve, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          raise fagprv_err;
       end if;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'deprn_reserve in fagprv',
               value   => to_char(deprn_reserve));
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'deprn_amt in fagprv',
               value   => to_char(deprn_amt));
       end if;

       tot_deprn_reserve := deprn_reserve + deprn_amt;
       tot_reval_reserve := reval_reserve - reval_amort;
       tot_bonus_deprn_reserve := bonus_deprn_reserve + bonus_deprn_amt;
       tot_impairment_reserve := impairment_reserve + impairment_amt;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'bonus_deprn_reserve in fagprv',
               value   => to_char(bonus_deprn_reserve));
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'bonus_deprn_amt in fagprv',
               value   => to_char(bonus_deprn_amt));
       end if;

       -- Fix for Bug 3441030
       if (l_fully_rsvd_flag and deprn_amt = 0)  then
          tot_deprn_reserve := l_prev_deprn_reserve - l_final_rsv;
       end if;

    /*
     * Round tot_deprn_reserve according to functional currency
     */
       if not FA_UTILS_PKG.faxrnd(tot_deprn_reserve, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          raise fagprv_err;
       end if;

       if not FA_UTILS_PKG.faxrnd(tot_bonus_deprn_reserve, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          raise fagprv_err;
       end if;

       if not FA_UTILS_PKG.faxrnd(tot_impairment_reserve, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          raise fagprv_err;
       end if;

    /*
     * Round tot_reval_reserve according to functional currency
     */

       if not FA_UTILS_PKG.faxrnd(tot_reval_reserve, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          raise fagprv_err;
       end if;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'acct segment in fagprv',
               value   => '', p_log_level_rec => p_log_level_rec);
       end if;

       h_retire_reval_flag := 0;

       begin
          select  facb.deprn_reserve_acct,
                  facb.reval_reserve_acct,
                  facb.bonus_deprn_reserve_acct,
                  facb.impair_reserve_acct,
                  decode(bc.retire_reval_reserve_flag,'NO',0,
                         decode(facb.reval_reserve_acct,null,0,1))
          into    h_deprn_rsv_acct,
                  h_reval_rsv_acct,
                  h_bonus_deprn_rsv_acct,
                  h_impairment_rsv_acct,
                  h_retire_reval_flag
          from    fa_additions_b    faadd,
                  fa_category_books facb,
                  fa_book_controls bc
          where   faadd.asset_id = h_asset_id
          and     facb.category_id = faadd.asset_category_id
          and     facb.book_type_code = h_book
          and     bc.book_type_code = facb.book_type_code;
          EXCEPTION
             when no_data_found then
                raise fagprv_err;
       end;

       deprn_rsv_acct := h_deprn_rsv_acct;
       reval_rsv_acct := h_reval_rsv_acct;
       bonus_deprn_rsv_acct := h_bonus_deprn_rsv_acct;
       impairment_rsv_acct := h_impairment_rsv_acct;
       adj_row.transaction_header_id := ret.th_id_in;
       adj_row.source_type_code := 'RETIREMENT';
       adj_row.book_type_code := ret.book;
       adj_row.period_counter_created := cpd_ctr;
       adj_row.asset_id := ret.asset_id;
       adj_row.period_counter_adjusted := cpd_ctr;
       adj_row.last_update_date := today;
       adj_row.current_units := bk.cur_units;
       adj_row.gen_ccid_flag := TRUE;
       adj_row.flush_adj_flag := TRUE;
       adj_row.annualized_adjustment := 0;
       adj_row.code_combination_id := 0;
       adj_row.distribution_id := 0;
       adj_row.selection_retid := 0;
       adj_row.units_retired := 0;
       adj_row.asset_invoice_id := 0;
       adj_row.leveling_flag := TRUE;

       if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'deprn_allocation_code in fagprv',
               value   => '', p_log_level_rec => p_log_level_rec);
       end if;

       begin
          select   decode(RETIRE_REVAL_RESERVE_FLAG,'NO',0,1)
          into     h_retire_reval_flag
          from     fa_book_controls bc
          where    bc.book_type_code = h_book;

          EXCEPTION
             when no_data_found then
                raise fagprv_err;
       end;

       --8244128 Changed the check from Allocate to member rollup flag
       --8546627 Added condition for Stand Alone assets
       --8631612 Modified the check for member_rollup_flag to tracking method
       if (ret.units_retired is null or ret.units_retired <= 0) and
          (((bk.group_asset_id is not null) and (bk.tracking_method is not null)) or bk.group_asset_id is null)  then

          adj_row.account := deprn_rsv_acct;
          adj_row.account_type := 'DEPRN_RESERVE_ACCT';
          adj_row.adjustment_type := 'RESERVE';
          adj_row.adjustment_amount := tot_deprn_reserve;
          adj_row.selection_thid := 0;
          adj_row.debit_credit_flag := 'DR';

          if (bk.current_cost = ret.cost_retired) then
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_CLEAR;
          else
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
             -- Bug 5149832
             if (bk.book_class) then
                if NOT faginfo(
                            RET, BK, cpd_ctr,today, user_id
                           ,calling_module => l_calling_fn
                           ,candidate_mode => 'CLEAR_PARTIAL'
                           ,set_adj_row => TRUE
                           ,unit_ret_in_corp => l_unit_ret_in_corp
                           ,ret_id_in_corp => l_ret_id_in_corp
                           ,th_id_out_in_corp => h_id_out
                           ,balance_tfr_in_tax => l_balance_tfr_in_tax
                           ,adj_row => adj_row
                           ,p_log_level_rec => p_log_level_rec ) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  return(FALSE);
                end if;
             end if;

          end if;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add(l_calling_fn, '++ bk.book_class (TRUE=TAX)', bk.book_class);
             fa_debug_pkg.add(l_calling_fn, '++ adj_row.selection_thid', adj_row.selection_thid, p_log_level_rec => p_log_level_rec);
          end if;

          adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if (bk.group_asset_id is not null) and
             (nvl(bk.member_rollup_flag, 'N') = 'N') then
             adj_row.track_member_flag := 'Y';
          else
             adj_row.track_member_flag := null;
          end if;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Before faxinaj for RESERVE',
               value   => '', p_log_level_rec => p_log_level_rec);

            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'account',
               value   => adj_row.account, p_log_level_rec => p_log_level_rec);

          end if;

          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return(FALSE);

          end if;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'After faxinaj for RESERVE',
               value   => '', p_log_level_rec => p_log_level_rec);
          end if;

          if (tot_bonus_deprn_reserve <> 0 ) then

             adj_row.account := bonus_deprn_rsv_acct;
             adj_row.account_type := 'BONUS_DEPRN_RESERVE_ACCT';
             adj_row.adjustment_type := 'BONUS RESERVE';
             adj_row.adjustment_amount := tot_bonus_deprn_reserve;
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             if (bk.group_asset_id is not null) and
                (nvl(bk.member_rollup_flag, 'N') = 'N') then
                adj_row.track_member_flag := 'Y';
             else
                adj_row.track_member_flag := null;
             end if;

             if adj_row.adjustment_amount <> 0 then

                if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

                end if;

             end if;

          end if; -- end of tot_bonus_deprn_reserve <> 0


          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'After faxinaj for BONUS RESERVE',
               value   => '', p_log_level_rec => p_log_level_rec);
          end if;

          if (tot_impairment_reserve <> 0 ) then

             adj_row.account := impairment_rsv_acct;
             adj_row.account_type := 'IMPAIR_RESERVE_ACCT';
             adj_row.adjustment_type := 'IMPAIR RESERVE';
             adj_row.adjustment_amount := tot_impairment_reserve;
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             if (bk.group_asset_id is not null) and
                (nvl(bk.member_rollup_flag, 'N') = 'N') then
                adj_row.track_member_flag := 'Y';
             else
                adj_row.track_member_flag := null;
             end if;

             if adj_row.adjustment_amount <> 0 then

                if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

                end if;

             end if;

          end if; -- end of tot_impairment_reserve <> 0


          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'After faxinaj for IMPAIR RESERVE',
               value   => '', p_log_level_rec => p_log_level_rec);
          end if;

          if (bk.current_cost > bk.unrevalued_cost OR reval_reserve <> 0) and
                                (h_retire_reval_flag = 1) then

             adj_row.selection_mode := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE_REVAL;
             -- adj_row.selection_mode := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;
             adj_row.account := reval_rsv_acct;
             adj_row.account_type := 'REVAL_RESERVE_ACCT';
             adj_row.adjustment_type := 'REVAL RESERVE';
             adj_row.adjustment_amount := tot_reval_reserve;
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             if (bk.group_asset_id is not null) and
                (nvl(bk.member_rollup_flag, 'N') = 'N') then
                adj_row.track_member_flag := 'Y';
             else
                adj_row.track_member_flag := null;
             end if;

             if adj_row.adjustment_amount <> 0 then
                if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

                end if;
             end if;

          end if; -- end of - if (bk.current_cost

         -- Bug3766289: Old condition didn't process tracked member asset
--       elsif (bk.group_asset_id is null) then
       elsif (not((bk.group_asset_id is not null) and
                  (nvl(bk.tracking_method, 'ALLOCATE') = 'ALLOCATE'))) then

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'h_asset_id in fagprv(2)',
               value   => h_asset_id);
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'h_book in fagprv(2)',
               value   => h_book);
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'h_ret_id in fagprv(2)',
               value   => h_ret_id);

            begin
              select   distinct nvl(transaction_header_id_out,0)
              into     l_id
              from     fa_distribution_history
              where    asset_id = h_asset_id
              and      book_type_code = h_book
              and      retirement_id = h_ret_id;

            exception  when others then null;
              l_id := 0;
             end;

            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'l_id from dh in fagprv(2)',
               value   => l_id);

          end if;

          begin
             select   distinct nvl(transaction_header_id_out,0)
             into     h_id_out
             from     fa_distribution_history
             where    asset_id = h_asset_id
             and      book_type_code = h_book
             and      retirement_id = h_ret_id;

             EXCEPTION
                when no_data_found then
                   raise fagprv_err;
          end;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'transaction_header_id_out in fagprv',
               value   => h_id_out, p_log_level_rec => p_log_level_rec);
          end if;

          -- Bug# 5170275
          h_sum_of_part_active_units := 0;

          begin

            select sum(nvl(units_assigned,0))
            into h_sum_of_part_active_units
            from fa_distribution_history
            where asset_id = h_asset_id
              and transaction_header_id_in = h_id_out
              and date_ineffective is null;

          exception
            when no_data_found then
               h_sum_of_part_active_units := 0;
          end;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => '++ h_sum_of_part_active_units in fagprv',
               value   => h_sum_of_part_active_units, p_log_level_rec => p_log_level_rec);
          end if;

          adj_row.account := deprn_rsv_acct;
          adj_row.account_type := 'DEPRN_RESERVE_ACCT';
          adj_row.adjustment_type := 'RESERVE';
          adj_row.adjustment_amount := 0;
          adj_row.selection_thid := h_id_out;
          adj_row.debit_credit_flag := 'DR';

          /* Fix for Bug#4617352: We have decided to create adj lines only for affected rows
             to avoid rounding issues with remaining rows in partial unit intercompany retirement.
          */
          adj_row.selection_mode := FA_STD_TYPES.FA_AJ_CLEAR_PARTIAL;

          adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
          adj_row.set_of_books_id := ret.set_of_books_id;

          if (bk.group_asset_id is not null) and
             (nvl(bk.member_rollup_flag, 'N') = 'N') then
             adj_row.track_member_flag := 'Y';
          else
             adj_row.track_member_flag := null;
          end if;

          if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

          end if;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'transaction_header_id_out in fagprv',
               value   => h_id_out, p_log_level_rec => p_log_level_rec);
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'tot_deprn_reserve in fagprv',
               value   => tot_deprn_reserve, p_log_level_rec => p_log_level_rec);
          end if;


          adj_row.adjustment_amount := adj_row.amount_inserted -
                                       tot_deprn_reserve;


          if not FA_UTILS_PKG.faxrnd(adj_row.adjustment_amount, h_book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             raise fagprv_err;
          end if;


          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'cleared amount in fagprv(2)',
               value   => adj_row.amount_inserted);
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'cost_frac in fagprv(2)',
               value   => cost_frac);
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 're-allocated amount in fagprv(2)',
               value   => adj_row.adjustment_amount);
          end if;

/*
             select     nvl(units,0)
             into       h_cur_units
             from       fa_asset_history
             where      asset_id = h_asset_id
             and        date_ineffective is null;
*/


          h_cur_units := 0;

          begin

            select 1
              into l_dummy
            from fa_distribution_history
            where asset_id = h_asset_id
              and date_ineffective is null
              and transaction_header_id_in = h_id_out
              and rownum = 1;


          /* Fix for Bug#4617352 */
            select sum(nvl(units_assigned,0))
            into h_cur_units
            from fa_distribution_history
            where asset_id = h_asset_id
              and date_ineffective is null
              and transaction_header_id_in = h_id_out;

          exception
              when no_data_found then
                h_cur_units := 0;
          end;

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => '++ h_cur_units in fagprv(2.5)',
               value   => h_cur_units);
          end if;

          if (h_cur_units <> 0) then

            adj_row.current_units := h_cur_units;
            --adj_row.selection_thid := 0;
            adj_row.selection_thid := h_id_out;
            adj_row.debit_credit_flag := 'CR';
            -- Bug 5170275:  adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE_PARTIAL;
            if h_sum_of_part_active_units > 0 then
              adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE_PARTIAL;
            else
              adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
            end if;
            adj_row.leveling_flag := FALSE;
            adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
            adj_row.set_of_books_id := ret.set_of_books_id;

            if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

            end if;


            if (tot_bonus_deprn_reserve <> 0) then

             adj_row.current_units := bk.cur_units;
             adj_row.account := bonus_deprn_rsv_acct;
             adj_row.account_type := 'BONUS_DEPRN_RESERVE_ACCT';
             adj_row.adjustment_type := 'BONUS RESERVE';
             adj_row.adjustment_amount := 0;
             adj_row.amount_inserted := 0;
             adj_row.selection_thid := h_id_out;
             adj_row.debit_credit_flag := 'DR';
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_CLEAR;
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             if p_log_level_rec.statement_level then
                fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'Insert fa_adjustments in fagprv2,accnt_type',
                   value   => adj_row.account_type, p_log_level_rec => p_log_level_rec);
             end if;

             if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

             end if;

             adj_row.adjustment_amount := adj_row.amount_inserted -
                                       tot_bonus_deprn_reserve;

             adj_row.current_units := h_cur_units;
             adj_row.selection_thid := 0;
             adj_row.debit_credit_flag := 'CR';
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);
             end if;

            end if;

            if (tot_impairment_reserve <> 0) then

             adj_row.current_units := bk.cur_units;
             adj_row.account := impairment_rsv_acct;
             adj_row.account_type := 'IMPAIR_RESERVE_ACCT';
             adj_row.adjustment_type := 'IMPAIR RESERVE';
             adj_row.adjustment_amount := 0;
             adj_row.amount_inserted := 0;
             adj_row.selection_thid := h_id_out;
             adj_row.debit_credit_flag := 'DR';
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_CLEAR;
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             if p_log_level_rec.statement_level then
                fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'Insert fa_adjustments in fagprv2,accnt_type',
                   value   => adj_row.account_type, p_log_level_rec => p_log_level_rec);
             end if;

             if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

             end if;

             adj_row.adjustment_amount := adj_row.amount_inserted -
                                       tot_impairment_reserve;

             adj_row.current_units := h_cur_units;
             adj_row.selection_thid := 0;
             adj_row.debit_credit_flag := 'CR';
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);
             end if;

            end if;

          end if; -- if h_cur_units <> 0

          if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Before faxinaj for REVAL RESERVE',
               value   => '', p_log_level_rec => p_log_level_rec);
          end if;

          if (bk.current_cost > bk.unrevalued_cost OR reval_reserve <> 0 ) and
                                (h_retire_reval_flag = 1) then

             adj_row.current_units := bk.cur_units;
             adj_row.account := reval_rsv_acct;
             adj_row.account_type := 'REVAL_RESERVE_ACCT';
             adj_row.adjustment_type := 'REVAL RESERVE';
             adj_row.adjustment_amount := 0;
             adj_row.selection_thid := h_id_out;
             adj_row.debit_credit_flag := 'DR';
             /* Bug#7646218 - partial unit retirement Need to insert row in fa_adj for distribution id transferred out only.*/
             adj_row.selection_mode := FA_STD_TYPES.FA_AJ_CLEAR_PARTIAL;
             adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
             adj_row.set_of_books_id := ret.set_of_books_id;

             if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);
             end if;

             adj_row.adjustment_amount := adj_row.amount_inserted -
                                          tot_reval_reserve;

             -- Bug # 5170275
             if (h_cur_units <> 0) then
               adj_row.current_units := h_cur_units;
               adj_row.selection_thid := 0;
               adj_row.debit_credit_flag := 'CR';
               adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
               adj_row.set_of_books_id := ret.set_of_books_id;

               adj_row.selection_mode := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE_REVAL;
               -- adj_row.selection_mode := FA_ADJUST_TYPE_PKG.FA_AJ_ACTIVE;

               if adj_row.adjustment_amount <> 0 then
                  if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login,
                                       p_log_level_rec => p_log_level_rec)) then

                     fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                     return(FALSE);
                  end if;
               end if;
             end if; -- h_cur_units

          end if; -- end of - if (bk.current_cost
       end if; -- end of - if (ret.units_retired

       ret.rsv_retired := tot_deprn_reserve;
       ret.reval_rsv_retired := tot_reval_reserve;
       ret.bonus_rsv_retired := tot_bonus_deprn_reserve;
       ret.impair_rsv_retired := tot_impairment_reserve;

       if p_log_level_rec.statement_level then
             fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'Value of reval_rsv_retired is ',
                   value   => to_char(tot_reval_reserve));
       end if;

       if p_log_level_rec.statement_level then
             fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'Value of rsv_retired is ',
                   value   => to_char(tot_deprn_reserve));
       end if;

       if p_log_level_rec.statement_level then
             fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'Return true from EFA_RUPD.fagprv ',
                   value   => to_char(tot_deprn_reserve));
       end if;

       -- +++++ Process Create Reserve Retired entry for Group +++++ --
       if (bk.group_asset_id is not null) and
          (nvl(bk.member_rollup_flag, 'N') = 'N') then

          if (l_rsv_retired is not null) then
             ret.reserve_retired := l_rsv_retired;
          end if;

          fa_query_balances_pkg.query_balances(
                      X_asset_id => bk.group_asset_id,
                      X_book => ret.book,
                      X_period_ctr => 0,
                      X_dist_id => 0,
                      X_run_mode => 'STANDARD',
                      X_cost => l_temp_num,
                      X_deprn_rsv => l_g_rsv,
                      X_reval_rsv => l_temp_num,
                      X_ytd_deprn => l_temp_num,
                      X_ytd_reval_exp => l_temp_num,
                      X_reval_deprn_exp => l_temp_num,
                      X_deprn_exp => l_temp_num,
                      X_reval_amo => l_temp_num,
                      X_prod => l_temp_num,
                      X_ytd_prod => l_temp_num,
                      X_ltd_prod => l_temp_num,
                      X_adj_cost => l_temp_num,
                      X_reval_amo_basis => l_temp_num,
                      X_bonus_rate => l_temp_num,
                      X_deprn_source_code => l_temp_char,
                      X_adjusted_flag => l_temp_bool,
                      X_transaction_header_id => -1,
                      X_bonus_deprn_rsv => l_g_bonus_rsv,
                      X_bonus_ytd_deprn => l_temp_num,
                      X_bonus_deprn_amount => l_temp_num,
                      X_impairment_rsv => l_g_impair_rsv,
                      X_ytd_impairment => l_temp_num,
                      X_impairment_amount => l_temp_num,
                      X_capital_adjustment => l_temp_num,
                      X_general_fund => l_temp_num,
                      X_mrc_sob_type_code => ret.mrc_sob_type_code,
                      X_set_of_books_id => ret.set_of_books_id,
                      p_log_level_rec => p_log_level_rec);

          if (nvl(l_rsv_retired, 0) <> 0) or
             (nvl(l_g_rsv, 0) <> 0) or
             (nvl(l_g_bonus_rsv, 0) <> 0) or
             (nvl(l_g_impair_rsv, 0) <> 0) then

             adj_row.asset_id := bk.group_asset_id;

             OPEN c_get_unit;
             FETCH c_get_unit INTO adj_row.current_units;
             CLOSE c_get_unit;

             l_asset_hdr_rec.asset_id := bk.group_asset_id;
             l_asset_hdr_rec.book_type_code := ret.book;
             l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

             if not FA_UTIL_PVT.get_asset_cat_rec (
                      p_asset_hdr_rec         => l_asset_hdr_rec,
                      px_asset_cat_rec        => l_asset_cat_rec,
                      p_date_effective        => null,
                      p_log_level_rec         => p_log_level_rec) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);
             end if;

             if not fa_cache_pkg.fazccb(
                      X_book   => ret.book,
                      X_cat_id => l_asset_cat_rec.category_id,
                      p_log_level_rec => p_log_level_rec) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);
             end if;

             OPEN c_get_cost;
             FETCH c_get_cost INTO l_g_cost;
             CLOSE c_get_cost;

             if (nvl(l_g_rsv, 0) <> 0) then
                if (nvl(bk.member_rollup_flag, 'N') <> 'Y') and
                   (l_rsv_retired is null) and
                   (nvl(l_g_cost,0) <> 0) then -- Bug 7504243

                   adj_row.adjustment_amount := (ret.cost_retired / l_g_cost) * l_g_rsv;

                   if not FA_UTILS_PKG.faxrnd(adj_row.adjustment_amount, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      raise fagprv_err;
                   end if;


                else
                   adj_row.adjustment_amount := nvl(l_rsv_retired, ret.rsv_retired);
                   adj_row.adjustment_amount := nvl(adj_row.adjustment_amount,0); -- Bug 7504243
                end if;

                --Bug7394159: Populate fa_ret_types.ret_struct with reserve(/rsv)_retired
                ret.rsv_retired := adj_row.adjustment_amount;
                ret.reserve_retired := adj_row.adjustment_amount;

                adj_row.account := fa_cache_pkg.fazccb_record.deprn_reserve_acct;
                adj_row.account_type := 'DEPRN_RESERVE_ACCT';
                adj_row.adjustment_type := 'RESERVE';
                adj_row.selection_thid := 0;
                adj_row.debit_credit_flag := 'DR';
                adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                adj_row.set_of_books_id := ret.set_of_books_id;
                adj_row.track_member_flag := null;

                if p_log_level_rec.statement_level then
                  fa_debug_pkg.add(fname   => l_calling_fn,
                                   element => 'Before faxinaj for Group RESERVE',
                                   value   => adj_row.adjustment_amount, p_log_level_rec => p_log_level_rec);
                end if;

                if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                             X_last_update_date,
                                             X_last_updated_by,
                                             X_last_update_login,
                                             p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

                end if;
             end if; -- (nvl(l_g_rsv, 0) <> 0)

             if (nvl(l_g_bonus_rsv, 0) <> 0) then
                if (nvl(bk.member_rollup_flag, 'N') <> 'Y') and
                   (l_rsv_retired is null) and (nvl(l_g_impair_rsv,0) = 0) and
                   (nvl(l_g_cost,0) <> 0) then -- Bug 7504243

                   adj_row.adjustment_amount := (ret.cost_retired / l_g_cost) * l_g_bonus_rsv;

                   if not FA_UTILS_PKG.faxrnd(adj_row.adjustment_amount, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      raise fagprv_err;
                   end if;

                elsif (l_rsv_retired is not null) or
                      (nvl(l_g_impair_rsv, 0) <> 0) and
                      (nvl(l_g_rsv,0) <> 0) then -- Bug 7504243
                   adj_row.adjustment_amount := (l_rsv_retired/l_g_rsv) * l_g_bonus_rsv;

                   if not FA_UTILS_PKG.faxrnd(adj_row.adjustment_amount, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      raise fagprv_err;
                   end if;

                else
                   adj_row.adjustment_amount := ret.bonus_rsv_retired;
                end if;

                adj_row.account := fa_cache_pkg.fazccb_record.bonus_deprn_expense_acct;
                adj_row.account_type := 'BONUS_DEPRN_RESERVE_ACCT';
                adj_row.adjustment_type := 'BONUS RESERVE';
                adj_row.selection_thid := 0;
                adj_row.debit_credit_flag := 'DR';
                adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                adj_row.set_of_books_id := ret.set_of_books_id;
                adj_row.track_member_flag := null;

                if p_log_level_rec.statement_level then
                  fa_debug_pkg.add(fname   => l_calling_fn,
                                   element => 'Before faxinaj for Group BONUS RESERVE',
                                   value   => adj_row.adjustment_amount, p_log_level_rec => p_log_level_rec);
                end if;

                if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                             X_last_update_date,
                                             X_last_updated_by,
                                             X_last_update_login,
                                             p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

                end if;
             end if; -- (nvl(l_g_bonus_rsv, 0) <> 0)

             if (nvl(l_g_impair_rsv, 0) <> 0) then
                if (nvl(bk.member_rollup_flag, 'N') <> 'Y') and
                   (l_rsv_retired is null) and (nvl(l_g_bonus_rsv,0) = 0) and
                   (nvl(l_g_cost,0) <> 0) then -- Bug 7504243

                   adj_row.adjustment_amount := (ret.cost_retired / l_g_cost) * l_g_bonus_rsv;

                   if not FA_UTILS_PKG.faxrnd(adj_row.adjustment_amount, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      raise fagprv_err;
                   end if;

                elsif (l_rsv_retired is not null) or
                      (nvl(l_g_bonus_rsv, 0) <> 0) and
                      (nvl(l_g_rsv,0) <> 0) then -- Bug 7504243
                   adj_row.adjustment_amount := (l_rsv_retired/l_g_rsv) * l_g_impair_rsv;

                   if not FA_UTILS_PKG.faxrnd(adj_row.adjustment_amount, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      raise fagprv_err;
                   end if;

                else
                   adj_row.adjustment_amount := ret.impair_rsv_retired;
                end if;

                adj_row.account := fa_cache_pkg.fazccb_record.impair_expense_acct;
                adj_row.account_type := 'IMPAIR_RESERVE_ACCT';
                adj_row.adjustment_type := 'IMPAIR RESERVE';
                adj_row.selection_thid := 0;
                adj_row.debit_credit_flag := 'DR';
                adj_row.selection_mode := FA_STD_TYPES.FA_AJ_ACTIVE;
                adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
                adj_row.set_of_books_id := ret.set_of_books_id;
                adj_row.track_member_flag := null;

                if p_log_level_rec.statement_level then
                  fa_debug_pkg.add(fname   => l_calling_fn,
                                   element => 'Before faxinaj for Group IMPAIR RESERVE',
                                   value   => adj_row.adjustment_amount, p_log_level_rec => p_log_level_rec);
                end if;

                if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                             X_last_update_date,
                                             X_last_updated_by,
                                             X_last_update_login,
                                             p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(FALSE);

                end if;
             end if; -- (nvl(l_g_impair_rsv, 0) <> 0)

          end if;

       end if; -- (bk.group_asset_id is not null)

       return(TRUE);

    EXCEPTION

       when others then

            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    END FAGPRV;

END FA_GAINLOSS_UPD_PKG;    -- End of Package EFA_RUPD

/
