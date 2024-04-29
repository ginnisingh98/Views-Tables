--------------------------------------------------------
--  DDL for Package Body FA_GAINLOSS_DPR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GAINLOSS_DPR_PKG" AS
/* $Header: fagdprb.pls 120.14.12010000.2 2009/07/19 13:53:59 glchen ship $*/

-- +++++ Global Varialbes +++++

FUNCTION fagcrsv(dpr            fa_STD_TYPES.dpr_struct,
                 d_cal          varchar2,
                 p_cal          varchar2,
                 x_last_period  out nocopy boolean, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

l_pds_in_last_yr          integer;
l_lst_pd_ctr              integer;
l_y_dp_begin              integer;
l_rate_pers_per_yr        integer;
l_pers_per_yr             number;
l_lst_fy                  integer;  -- last fiscal year
l_lst_per                 integer;  -- last period of life
l_prorate                 integer;
dummynum                  number;
l_count                   number;
l_fy_name                 varchar2(30); -- Bug 5179236
l_cur_pdctr               number;

fagcrsv_err  exception;

begin

    x_last_period := FALSE;
    l_cur_pdctr := fa_cache_pkg.fazcdp_record.period_counter;

    l_fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;
    if not fa_cache_pkg.fazccp (p_cal, l_fy_name,
                dpr.prorate_jdate, l_prorate, l_y_dp_begin, dummynum, p_log_level_rec => p_log_level_rec) then
        return (FALSE);
    end if;

    if not fa_cache_pkg.fazcct (d_cal, p_log_level_rec => p_log_level_rec) then
        return (FALSE);
    end if;
    l_pers_per_yr := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

    if not fa_cache_pkg.fazcct (p_cal, p_log_level_rec => p_log_level_rec) then
        return (FALSE);
    end if;
    l_rate_pers_per_yr := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

    l_lst_per :=  l_prorate - 2 +
      mod(floor(dpr.life * l_rate_pers_per_yr/12),l_rate_pers_per_yr) +1 ;

    l_lst_fy := (l_y_dp_begin + floor ((dpr.life - 1) / 12));

    if l_lst_per <  l_prorate then
       l_lst_fy := l_lst_fy + 1;
    end if;

    l_pds_in_last_yr :=
        ceil ( l_pers_per_yr * l_lst_per  / l_rate_pers_per_yr );
    l_lst_pd_ctr :=  l_lst_fy * l_pers_per_yr + l_pds_in_last_yr;

    if l_lst_pd_ctr = l_cur_pdctr then
       x_last_period := TRUE;
    end if;

    return TRUE;

exception
when fagcrsv_err then
     fa_srvr_msg.add_message(
               calling_fn => 'fa_gainloss_dpr_pkg.fagcrsv',  p_log_level_rec => p_log_level_rec);
      return(FALSE);
end;



/*============================================================================
| NAME          fagcdp                                                       |
|                                                                            |
| FUNCTION      Calculates depreciation needed given a range of period       |
|                                                                            |
| RETURN VALUES - deprn_rate_ptr    : Depreciation taken per period          |
|                                                                            |
| HISTORY       1/12/89         R Rumanang      Created                      |
|               6/23/89         R RUmanang      Standarized                  |
|               5/1/90          R Rumanang      Fill in dpr->calendar_type   |
|               04/12/91        M Chan          Modified for MPL 9           |
|               01/04/97        S Behura        Rewrote in PL/SQL            |
|               08/10/97        S Behura        Rewrote in PL/SQL (10.7)     |
|============================================================================*/

FUNCTION fagcdp (dpr in out nocopy fa_std_types.dpr_struct,
                deprn_amt in out nocopy number,
                bonus_deprn_amt in out nocopy number,
                impairment_amt in out nocopy number,
                reval_deprn_amt in out nocopy number,
                reval_amort in out nocopy number,
                deprn_start_date in out nocopy date, d_cal in out nocopy varchar2,
                p_cal in out nocopy varchar2, v_start number, v_end number,
                prorate_fy number, dsd_fy number, prorate_jdate number,
                deprn_start_jdate number,
                retirement_id number default null, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

fagcdp_err              exception;

dummy                   fa_std_types.dpr_arr_type;
dpr_out                 fa_std_types.dpr_out_struct;
l_last_period           boolean;

-- Added for bug 5954528
l_life_end_date         date;
l_pcal_life_end_date    date;
l_pcal_ret_end_date     date;
l_pers_per_yr           number;
-- End bug fix 5954528
--Bug5887343
l_transaction_header_id_in number;
l_transaction_header_id_out number;

Cursor c_get_trxn_id is
select  transaction_header_id_in,transaction_header_id_out
from    fa_retirements
where   book_type_code=dpr.book
and     asset_id=dpr.asset_id
and     retirement_id=retirement_id;

l_rate_change_flag varchar2(1);

Cursor c_rate_change_flag is
select 'Y'
from    fa_books fbks1,
        fa_books fbks2
where   fbks1.book_type_code = dpr.book
and     fbks1.asset_id = dpr.asset_id
and     fbks2.book_type_code = fbks1.book_type_code
and     fbks2.asset_id = fbks2.asset_id
and     fbks1.transaction_header_id_in between l_transaction_header_id_in and nvl(l_transaction_header_id_out,l_transaction_header_id_in)
and     fbks2.transaction_header_id_in between l_transaction_header_id_in and nvl(l_transaction_header_id_out,l_transaction_header_id_in)
and     fbks2.transaction_header_id_in = fbks1.transaction_header_id_out
-- Bug 6983060: For Jp-250DB methods rate_in_use should be used
-- and     fbks2.adjusted_rate <> fbks1.adjusted_rate ;
and     nvl(fbks2.adjusted_rate, nvl(fbks2.rate_in_use, -999)) <>
           nvl(fbks1.adjusted_rate, nvl(fbks1.rate_in_use, -999)) ;

l_adjusted_rate1 number;
l_adjusted_rate2 number;
l_deprn_method_code1 varchar2(48);
l_transaction_id1 number;
l_transaction_id2 number;
l_deprn_method_code2 varchar2(48);

-- Bug 6983060 :
l_life_in_months1 number;
l_life_in_months2 number;
Cursor c_rate_details is
select  fbks1.adjusted_rate,fbks1.transaction_header_id_in,fbks1.deprn_method_code,
        fbks2.adjusted_rate,fbks2.transaction_header_id_in,fbks2.deprn_method_code,
        fbks1.life_in_months, fbks2.life_in_months -- Bug 6983060: Fetch life also
from    fa_books fbks1,
        fa_books fbks2
where   fbks1.book_type_code=dpr.book
and     fbks1.asset_id=dpr.asset_id
and     fbks2.book_type_code =fbks1.book_type_code
and     fbks2.asset_id =fbks2.asset_id
and     fbks1.transaction_header_id_in between l_transaction_header_id_in and l_transaction_header_id_out
and     fbks2.transaction_header_id_in between l_transaction_header_id_in and l_transaction_header_id_out
and     fbks2.transaction_header_id_in = fbks1.transaction_header_id_out
-- Bug 6983060: For Jp-250DB methods rate_in_use should be used
-- and     fbks2.adjusted_rate <> fbks1.adjusted_rate;
and     nvl(fbks2.adjusted_rate, nvl(fbks2.rate_in_use, -999)) <>
           nvl(fbks1.adjusted_rate, nvl(fbks1.rate_in_use, -999)) ;



l_prd_num number;
l_count number;
l_end_prd_num number;

Cursor c_get_period_details(x_transaction_id number) is
select fdp.period_num
from    fa_transaction_headers fth,
        fa_deprn_periods fdp
where   fth.transaction_header_id= x_transaction_id
and     fdp.book_type_code = dpr.book
and     fth.transaction_date_entered
        between fdp.calendar_period_open_date and nvl(fdp.calendar_period_close_date,sysdate);
BEGIN <<FAGCDP>>

       dpr.deprn_start_jdate := deprn_start_jdate;

       if (prorate_fy <> dsd_fy) then
          dpr.deprn_start_jdate := prorate_jdate;
       end if;

       if v_start = 0 then -- If start is zero, calculate the whole deprn
             dpr.p_cl_begin := 1;
        /* It is O.K. to assign 1 to dpr->p_cl_begin, because the deprn
           engine is smart enough to skip over periods before the deprn
           start period */
       else
             dpr.p_cl_begin := v_start;
       end if;

       dpr.p_cl_end := v_end;
      --Bug5887343
       --Added the following code
       if not fa_cache_pkg.fazcct (d_cal, p_log_level_rec => p_log_level_rec) then
          return (FALSE);
       end if;

           IF retirement_id is null then
                if not FA_CDE_PKG.faxcde(dpr, dummy, dpr_out,
                fa_std_types.FA_DPR_NORMAL, p_log_level_rec => p_log_level_rec) then

                fa_srvr_msg.add_message(
                calling_fn => 'fa_gainloss_dpr_pkg.fagcdp',
                name       => 'FA_RET_DEPRN_ERROR',
                token1     => 'MODULE',
                value1     => 'FAXCDE',  p_log_level_rec => p_log_level_rec);

                raise fagcdp_err;

                end if;
                deprn_amt := dpr_out.deprn_exp;
                bonus_deprn_amt := dpr_out.bonus_deprn_exp;
                impairment_amt := dpr_out.impairment_exp;
                reval_deprn_amt := dpr_out.reval_exp;
                reval_amort := dpr_out.reval_amo;
           else
                   open c_get_trxn_id;
                   fetch c_get_trxn_id into l_transaction_header_id_in,l_transaction_header_id_out;
                        open c_rate_change_flag;
                        fetch c_rate_change_flag into l_rate_change_flag;
                        if c_rate_change_flag%NOTFOUND then
                                l_rate_change_flag := 'N';
                        end if;
                        close c_rate_change_flag;
                        if l_rate_change_flag = 'N' then
                                if not FA_CDE_PKG.faxcde(dpr, dummy, dpr_out,
                                                fa_std_types.FA_DPR_NORMAL, p_log_level_rec => p_log_level_rec) then

                                        fa_srvr_msg.add_message(
                                       calling_fn => 'fa_gainloss_dpr_pkg.fagcdp',
                                       name       => 'FA_RET_DEPRN_ERROR',
                                       token1     => 'MODULE',
                                       value1     => 'FAXCDE',  p_log_level_rec => p_log_level_rec);

                                     raise fagcdp_err;

                                end if;
                                deprn_amt := dpr_out.deprn_exp;
                                bonus_deprn_amt := dpr_out.bonus_deprn_exp;
                                impairment_amt := dpr_out.impairment_exp;
                                reval_deprn_amt := dpr_out.reval_exp;
                                reval_amort := dpr_out.reval_amo;
                        else
                                l_end_prd_num := dpr.p_cl_end;
                                open c_rate_details;
                                l_count := 1;
                                loop
                                        fetch c_rate_details
                                        into  l_adjusted_rate1,
                                              l_transaction_id1,
                                              l_deprn_method_code1,
                                              l_adjusted_rate2,
                                              l_transaction_id2,
                                              l_deprn_method_code2,
                                              l_life_in_months1, -- Bug 6983060
                                              l_life_in_months2; -- Bug 6983060
                                        exit when c_rate_details%NOTFOUND;
                                        open c_get_period_details(l_transaction_id2);
                                        fetch c_get_period_details into l_prd_num;
                                        if l_count > 1 then
                                                dpr.p_cl_begin := dpr.p_cl_end + 1;
                                                dpr.p_cl_end := l_prd_num - 1;

                                        else
                                                dpr.p_cl_end := l_prd_num - 1;
                                        end if;
                                        dpr.adj_rate := l_adjusted_rate1;
                                        dpr.method_code := l_deprn_method_code1;
                                        -- Bug 6983060 : Populate Life also for JP-250 DB method
                                        dpr.life := l_life_in_months1;

                                        if not FA_CDE_PKG.faxcde(dpr, dummy, dpr_out,
                                                        fa_std_types.FA_DPR_NORMAL, p_log_level_rec => p_log_level_rec) then

                                                fa_srvr_msg.add_message(
                                               calling_fn => 'fa_gainloss_dpr_pkg.fagcdp',
                                               name       => 'FA_RET_DEPRN_ERROR',
                                               token1     => 'MODULE',
                                               value1     => 'FAXCDE',  p_log_level_rec => p_log_level_rec);

                                             raise fagcdp_err;

                                        end if;
                                        deprn_amt := nvl(deprn_amt,0) + dpr_out.deprn_exp;
                                        bonus_deprn_amt := nvl(bonus_deprn_amt,0) + dpr_out.bonus_deprn_exp;
                                        impairment_amt := nvl(impairment_amt,0) + dpr_out.impairment_exp;
                                        reval_deprn_amt := nvl(reval_deprn_amt,0) + dpr_out.reval_exp;
                                        reval_amort := nvl(reval_amort,0) + dpr_out.reval_amo;

                                        close c_get_period_details;
                                        l_count := l_count +1;
                                end loop;
                                close c_rate_details;
                                dpr.p_cl_begin := dpr.p_cl_end + 1;
                                dpr.p_cl_end := l_end_prd_num;
                                dpr.adj_rate := l_adjusted_rate2;
                                dpr.method_code := l_deprn_method_code2;
                                -- Bug 6983060 : Populate Life also for JP-250 DB method
                                dpr.life := l_life_in_months2;

                                if not FA_CDE_PKG.faxcde(dpr, dummy, dpr_out,
                                                        fa_std_types.FA_DPR_NORMAL, p_log_level_rec => p_log_level_rec) then

                                               fa_srvr_msg.add_message(
                                               calling_fn => 'fa_gainloss_dpr_pkg.fagcdp',
                                               name       => 'FA_RET_DEPRN_ERROR',
                                               token1     => 'MODULE',
                                               value1     => 'FAXCDE',  p_log_level_rec => p_log_level_rec);

                                raise fagcdp_err;
                                end if;
                                deprn_amt := deprn_amt + dpr_out.deprn_exp;
                                bonus_deprn_amt := bonus_deprn_amt + dpr_out.bonus_deprn_exp;
                                impairment_amt := impairment_amt + dpr_out.impairment_exp;
                                reval_deprn_amt := reval_deprn_amt + dpr_out.reval_exp;
                                reval_amort := reval_amort + dpr_out.reval_amo;
                        end if;
                 close c_get_trxn_id;
              end if;
           --Bug5887343 ends

      if not fa_cache_pkg.fazccmt
            (X_method                => dpr.method_code,
             X_life                  => dpr.life
              , p_log_level_rec => p_log_level_rec) then
        raise fagcdp_err;
      end if;

      if (fa_cache_pkg.fazccmt_record.rate_source_rule  = 'CALCULATED') then
         if not fagcrsv(dpr   => dpr,
                      d_cal => d_cal,
                      p_cal => p_cal,
                      x_last_period  => l_last_period,
                      p_log_level_rec => p_log_level_rec) then
           raise fagcdp_err;
         end if;

         -- Bug fix 5954528 (Added code to determine whether retirement is performed in last period
          -- of asset's life as per prorate calendar or not and accordingly calculated deprn_amt for daily prorate calendar)
         if l_last_period then

            if not fa_cache_pkg.fazcct (p_cal, p_log_level_rec => p_log_level_rec) then
               return (FALSE);
            end if;

            l_pers_per_yr := fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR;

            fa_debug_pkg.add ('FAGDCP', 'l_pers_per_yr', l_pers_per_yr, p_log_level_rec => p_log_level_rec);

            if l_pers_per_yr <> 365 then
               deprn_amt := dpr.adj_rec_cost - dpr.deprn_rsv;
            else
               fa_debug_pkg.add ('FAGDCP', 'deprn_amt', deprn_amt, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add ('FAGDCP', 'dpr.prorate_date', dpr.prorate_date, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add ('FAGDCP', 'dpr.ret_prorate_jdate', dpr.ret_prorate_jdate, p_log_level_rec => p_log_level_rec);

               l_life_end_date := add_months(dpr.prorate_date,dpr.life);

               select end_date
               into l_pcal_life_end_date
               from fa_calendar_periods
               where calendar_type = p_cal
               and l_life_end_date between start_date and end_date;

               select end_date
               into l_pcal_ret_end_date
               from fa_calendar_periods
               where calendar_type = p_cal
               and to_date(dpr.ret_prorate_jdate,'j') between start_date and end_date;

               if (l_pcal_life_end_date <= l_pcal_ret_end_date) then
                  deprn_amt := dpr.adj_rec_cost - dpr.deprn_rsv;
               end if;  -- if (l_pcal_life_end_date <= l_pcal_ret_end_date) then

               fa_debug_pkg.add ('FAGDCP', 'l_life_end_date', l_life_end_date, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add ('FAGDCP', 'l_pcal_life_end_date', l_pcal_life_end_date, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add ('FAGDCP', 'l_pcal_ret_end_date', l_pcal_ret_end_date, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add ('FAGDCP', 'deprn_amt', deprn_amt, p_log_level_rec => p_log_level_rec);

            end if;  -- if p_pers_per_yr <> 365 then

         end if; -- if l_last_period then
         -- End of bug fix 5954528

      end if;

      fa_debug_pkg.add ('FAGDCP', 'final deprn_amt', deprn_amt, p_log_level_rec => p_log_level_rec);

      return(TRUE);

EXCEPTION

          when fagcdp_err then

             fa_srvr_msg.add_message(
               calling_fn => 'fa_gainloss_dpr_pkg.fagcdp',  p_log_level_rec => p_log_level_rec);

             return(FALSE);

END FAGCDP;

/*============================================================================
| NAME          CALC_CATCHUP                                                 |
|                                                                            |
| FUNCTION      Calculates depreciation needed given a range of period       |
|                                                                            |
|                                                                            |
|============================================================================*/
FUNCTION CALC_CATCHUP(
   ret                             FA_RET_TYPES.RET_STRUCT,
   BK                              FA_RET_TYPES.BOOK_STRUCT,
   DPR                             FA_STD_TYPES.DPR_STRUCT,
   calc_catchup                    BOOLEAN,
   x_deprn_exp          OUT NOCOPY NUMBER,
   x_bonus_deprn_exp    OUT NOCOPY NUMBER,
   x_impairment_exp     OUT NOCOPY NUMBER,
   x_asset_fin_rec_new  OUT NOCOPY FA_API_TYPES.asset_fin_rec_type
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_calling_fn        VARCHAR2(50) := 'FA_GAINLOSS_DPR_PKG.CALC_CATCHUP';


   CURSOR c_get_rein_thid IS
      select nvl(transaction_header_id_out, transaction_header_id_in) -- Bug# 5074257
      from   fa_retirements
      where  retirement_id = ret.retirement_id;

   CURSOR c_get_trans_rec(c_thid number) IS
      select transaction_type_code
           , transaction_date_entered
           , transaction_name
           , source_transaction_header_id
           , mass_reference_id
           , transaction_subtype
           , transaction_key
           , amortization_start_date
           , calling_interface
           , mass_transaction_id
           , fa_std_types.FA_NO_OVERRIDE
           , member_transaction_header_id
           , trx_reference_id
      from fa_transaction_headers
      where transaction_header_id = c_thid;

   CURSOR c_get_ret_amounts IS
      select outbk.salvage_value - inbk.salvage_value
           , nvl(outbk.allowed_deprn_limit_amount, 0) -
             nvl(inbk.allowed_deprn_limit_amount, 0),
             outbk.unrevalued_cost - inbk.unrevalued_cost
      from   fa_books inbk
           , fa_books outbk
      where  inbk.transaction_header_id_in = ret.th_id_in
      and    outbk.asset_id = ret.asset_id
      and    outbk.book_type_code = ret.book
      and    outbk.transaction_header_id_out = ret.th_id_in;

   CURSOR c_get_ret_amounts_mrc IS
      select outbk.salvage_value - inbk.salvage_value
           , nvl(outbk.allowed_deprn_limit_amount, 0) -
             nvl(inbk.allowed_deprn_limit_amount, 0),
             outbk.unrevalued_cost - inbk.unrevalued_cost
      from   fa_mc_books inbk
           , fa_mc_books outbk
      where  inbk.transaction_header_id_in = ret.th_id_in
      and    inbk.set_of_books_id = ret.set_of_books_id
      and    outbk.set_of_books_id = ret.set_of_books_id
      and    outbk.asset_id = ret.asset_id
      and    outbk.book_type_code = ret.book
      and    outbk.transaction_header_id_out = ret.th_id_in;

   CURSOR c_get_rsv_ret IS
      select sum(decode(debit_credit_flag, 'CR', -1, 1) * adjustment_amount)
      from   fa_adjustments
      where  asset_id = ret.asset_id
      and    book_type_code = ret.book
      and    source_type_code = 'RETIREMENT'
      and    adjustment_type = 'RESERVE'
      and    transaction_header_id = ret.th_id_in;

   CURSOR c_get_rsv_ret_mrc IS
      select sum(decode(debit_credit_flag, 'CR', -1, 1) * adjustment_amount)
      from   fa_mc_adjustments
      where  asset_id = ret.asset_id
      and    book_type_code = ret.book
      and    source_type_code = 'RETIREMENT'
      and    adjustment_type = 'RESERVE'
      and    set_of_books_id = ret.set_of_books_id
      and    transaction_header_id = ret.th_id_in;

   -- Bug 5381824 Cursor to get the prorated transaction
   -- date based on retirement prorate convention
   CURSOR c_get_retire_prorate (c_thid number,
                                c_trx_date date ) IS
     select con.prorate_date
     from fa_retirements ret,
          fa_conventions con
     where ret.transaction_header_id_in   = c_thid
     and   con.prorate_convention_code    = ret.RETIREMENT_PRORATE_CONVENTION
     and   c_trx_date between con.start_date and con.end_date ;

   CURSOR c_mc_get_retire_prorate (c_thid number,
                                c_trx_date date ) IS
     select con.prorate_date
     from fa_mc_retirements ret,
          fa_conventions       con
     where ret.transaction_header_id_in   = c_thid
     and   con.prorate_convention_code    = ret.RETIREMENT_PRORATE_CONVENTION
     and   set_of_books_id = ret.set_of_books_id
     and   c_trx_date between con.start_date and con.end_date ;

   -- Bug 5381824 end

   l_asset_hdr_rec       FA_API_TYPES.asset_hdr_rec_type;
   l_asset_desc_rec      FA_API_TYPES.asset_desc_rec_type;
   l_asset_cat_rec       FA_API_TYPES.asset_cat_rec_type;
   l_asset_type_rec      FA_API_TYPES.asset_type_rec_type;

   l_trans_rec           FA_API_TYPES.trans_rec_type;
   l_asset_fin_rec_old   FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_adj   FA_API_TYPES.asset_fin_rec_type;
   l_asset_deprn_rec     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_adj FA_API_TYPES.asset_deprn_rec_type;
   l_period_rec          FA_API_TYPES.period_rec_type;

   l_mrc_sob_type_code   VARCHAR2(1);

   l_salvage_value       NUMBER;
   l_deprn_limit_amount  NUMBER;
   l_reserve_retired     NUMBER := 0;

   l_running_mode        NUMBER := fa_std_types.FA_DPR_CATCHUP;

   calc_err              EXCEPTION;
BEGIN

   l_asset_hdr_rec.asset_id := ret.asset_id;
   l_asset_hdr_rec.book_type_code := ret.book;
   --l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;
   l_asset_hdr_rec.set_of_books_id := ret.set_of_books_id;
   l_mrc_sob_type_code := ret.mrc_sob_type_code;

   OPEN c_get_rein_thid;
   FETCH c_get_rein_thid INTO l_trans_rec.transaction_header_id;
   CLOSE c_get_rein_thid;

   OPEN c_get_trans_rec(l_trans_rec.transaction_header_id);
   FETCH c_get_trans_rec INTO l_trans_rec.transaction_type_code
                            , l_trans_rec.transaction_date_entered
                            , l_trans_rec.transaction_name
                            , l_trans_rec.source_transaction_header_id
                            , l_trans_rec.mass_reference_id
                            , l_trans_rec.transaction_subtype
                            , l_trans_rec.transaction_key
                            , l_trans_rec.amortization_start_date
                            , l_trans_rec.calling_interface
                            , l_trans_rec.mass_transaction_id
                            , l_trans_rec.deprn_override_flag
                            , l_trans_rec.member_transaction_header_id
                            , l_trans_rec.trx_reference_id;
   CLOSE c_get_trans_rec;

   if not FA_UTIL_PVT.get_asset_cat_rec (
                         p_asset_hdr_rec  => l_asset_hdr_rec,
                         px_asset_cat_rec => l_asset_cat_rec,
                         p_date_effective  => NULL, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not fa_util_pvt.get_asset_desc_rec (
                p_asset_hdr_rec         => l_asset_hdr_rec,
                px_asset_desc_rec       => l_asset_desc_rec, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTIL_PVT.get_asset_type_rec (
                p_asset_hdr_rec         => l_asset_hdr_rec,
                px_asset_type_rec       => l_asset_type_rec,
                p_date_effective        => null, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not fa_util_pvt.get_asset_fin_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_fin_rec        => l_asset_fin_rec_old,
                   p_mrc_sob_type_code     => l_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if (l_mrc_sob_type_code = 'R') then
      OPEN c_get_ret_amounts_mrc;
      FETCH c_get_ret_amounts_mrc
       INTO l_asset_fin_rec_adj.salvage_value,
            l_asset_fin_rec_adj.allowed_deprn_limit_amount,
            l_asset_fin_rec_adj.unrevalued_cost;
      CLOSE c_get_ret_amounts_mrc;
   else
      OPEN c_get_ret_amounts;
      FETCH c_get_ret_amounts
       INTO l_asset_fin_rec_adj.salvage_value,
            l_asset_fin_rec_adj.allowed_deprn_limit_amount,
            l_asset_fin_rec_adj.unrevalued_cost;
      CLOSE c_get_ret_amounts;
   end if;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '+ + ret.cost_retired', ret.cost_retired, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, '+ + l_asset_fin_rec_old.cost (1)', l_asset_fin_rec_old.cost);
       fa_debug_pkg.add(l_calling_fn, '+ + x_asset_fin_rec_new.cost (1)', x_asset_fin_rec_new.cost);
   end if;

   x_asset_fin_rec_new      := l_asset_fin_rec_old;
   l_asset_fin_rec_adj.cost := ret.cost_retired;
   x_asset_fin_rec_new.cost := x_asset_fin_rec_new.cost  + ret.cost_retired;
   x_asset_fin_rec_new.unrevalued_cost := x_asset_fin_rec_new.unrevalued_cost + l_asset_fin_rec_adj.unrevalued_cost;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '+ + x_asset_fin_rec_new.cost (2)', x_asset_fin_rec_new.cost);
   end if;

   -- BUG# 3371210
   -- replacing the original code here with calls to common calc apis

   if not fa_asset_calc_pvt.calc_salvage_value
            (p_trans_rec               => l_trans_rec,
             p_asset_hdr_rec           => l_asset_hdr_rec,
             p_asset_type_rec          => l_asset_type_rec,
             p_asset_fin_rec_old       => l_asset_fin_rec_old,
             p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
             px_asset_fin_rec_new      => x_asset_fin_rec_new,
             p_mrc_sob_type_code       => l_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   x_asset_fin_rec_new.recoverable_cost := x_asset_fin_rec_new.cost - x_asset_fin_rec_new.salvage_value;

   if not fa_asset_calc_pvt.calc_deprn_limit_adj_rec_cost
            (p_asset_hdr_rec           => l_asset_hdr_rec,
             p_asset_type_rec          => l_asset_type_rec,
             p_asset_fin_rec_old       => l_asset_fin_rec_old,
             p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
             px_asset_fin_rec_new      => x_asset_fin_rec_new,
             p_mrc_sob_type_code       => l_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not fa_util_pvt.get_asset_deprn_rec (
                   p_asset_hdr_rec         => l_asset_hdr_rec,
                   px_asset_deprn_rec      => l_asset_deprn_rec,
                   p_mrc_sob_type_code     => l_mrc_sob_type_code, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if not FA_UTIL_PVT.get_period_rec (
                   p_book           => l_asset_hdr_rec.book_type_code,
                   x_period_rec     => l_period_rec, p_log_level_rec => p_log_level_rec) then
      raise calc_err;
   end if;

   if (l_mrc_sob_type_code = 'R') then
      OPEN c_get_rsv_ret_mrc;
      FETCH c_get_rsv_ret_mrc INTO l_reserve_retired;
      CLOSE c_get_rsv_ret_mrc;
   else
      OPEN c_get_rsv_ret;
      FETCH c_get_rsv_ret INTO l_reserve_retired;
      CLOSE c_get_rsv_ret;
   end if;

   l_asset_deprn_rec_adj.deprn_reserve := l_reserve_retired;

   if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add(l_calling_fn, '+ + l_reserve_retired', l_reserve_retired, p_log_level_rec => p_log_level_rec);
       fa_debug_pkg.add(l_calling_fn, '+ + l_asset_deprn_rec_adj.deprn_reserve', l_asset_deprn_rec_adj.deprn_reserve, p_log_level_rec => p_log_level_rec);
   end if;


   -- Bug 5381824 Get the prorated transaction date
   -- based on retirement prorate convention.
   if (l_mrc_sob_type_code = 'R') then
      OPEN c_mc_get_retire_prorate(l_trans_rec.transaction_header_id, l_trans_rec.transaction_date_entered);
      FETCH c_mc_get_retire_prorate INTO l_trans_rec.transaction_date_entered;
      CLOSE c_mc_get_retire_prorate;
   else
      OPEN c_get_retire_prorate(l_trans_rec.transaction_header_id, l_trans_rec.transaction_date_entered);
      FETCH c_get_retire_prorate INTO l_trans_rec.transaction_date_entered;
      CLOSE c_get_retire_prorate;
   end if;


   -- Bug 5738004
   if dpr.calc_catchup then
     l_running_mode := fa_std_types.FA_DPR_CATCHUP;
   else
     l_running_mode := fa_std_types.FA_DPR_NORMAL;
   end if;

   -- BUG# 3371210
   -- replacing the original code here with calls to common calc apis

   if not FA_AMORT_PVT.faxama
                     (px_trans_rec          => l_trans_rec,
                      p_asset_hdr_rec       => l_asset_hdr_rec,
                      p_asset_desc_rec      => l_asset_desc_rec,
                      p_asset_cat_rec       => l_asset_cat_rec,
                      p_asset_type_rec      => l_asset_type_rec,
                      p_asset_fin_rec_old   => l_asset_fin_rec_old,
                      p_asset_fin_rec_adj   => l_asset_fin_rec_adj,
                      px_asset_fin_rec_new  => x_asset_fin_rec_new,
                      p_asset_deprn_rec     => l_asset_deprn_rec,
                      p_asset_deprn_rec_adj => l_asset_deprn_rec_adj,
                      p_period_rec          => l_period_rec,
                      p_mrc_sob_type_code   => l_mrc_sob_type_code,
                      p_running_mode        => l_running_mode,
                      p_used_by_revaluation => null,
                      x_deprn_exp           => x_deprn_exp,
                      x_bonus_deprn_exp     => x_bonus_deprn_exp,
                      x_impairment_exp      => x_impairment_exp
   , p_log_level_rec => p_log_level_rec) then
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add(l_calling_fn, 'End', 'Success', p_log_level_rec => p_log_level_rec);
      end if;

      raise calc_err;
   end if;



   return TRUE;

EXCEPTION
   when calc_err then
      fa_srvr_msg.add_message(calling_fn => 'fa_gainloss_dpr_pkg.CALC_CATCHUP',  p_log_level_rec => p_log_level_rec);
      return FALSE;

   when OTHERS then
      fa_srvr_msg.add_message(calling_fn => 'fa_gainloss_dpr_pkg.CALC_CATCHUP(OTHERS)',
                   p_log_level_rec => p_log_level_rec);
      return FALSE;

END CALC_CATCHUP;

END FA_GAINLOSS_DPR_PKG;    -- End of Package RDPR

/
