--------------------------------------------------------
--  DDL for Package Body FA_GAINLOSS_PRO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GAINLOSS_PRO_PKG" AS
/* $Header: fagprob.pls 120.3.12010000.3 2009/07/19 13:56:59 glchen ship $*/
/*=============================================================================
|  NAME         fagpsa                                                        |
|                                                                             |
|  FUNCTION     This function loads the control byte and performs all the     |
|               retirement and reinstatement calculations if needed.          |
|                                                                             |
|  HISTORY      1/12/89    M Chan       Created                               |
|                                                                             |
|               01/09/97   S Behura     Rewrote in PL/SQL                     |
|============================================================================*/

Function fagpsa (ret in out nocopy fa_ret_types.ret_struct, today in date,
                 cpd_name in varchar2, cpd_ctr in number,
                 user_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

    bk                  fa_ret_types.book_struct;
    dpr                 fa_STD_TYPES.dpr_struct;
    pds_per_year        number;
    p_pds_per_year      number;
    cpd_num             number;
    ret_pdnum           number;
    pro_mth             number;
    dsd_mth             number;
    pro_fy              number;
    dsd_fy              number;

    h_ret_status        varchar2(15);
    h_retirement_id     number(15);

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_PRO_PKG.fagpsa';

    BEGIN <<FAGPSA>>

-- dbms_output.put_line('in fagpsa 1');

       bk.raf := 0;
       bk.adj_rate := 0;
       bk.adjusted_cost := 0;
       bk.current_cost := 0;
       bk.recoverable_cost := 0;
       bk.salvage_value := 0;
       bk.itc_amount := 0;
       bk.reval_amort_basis := 0;
       bk.unrevalued_cost := 0;
       dpr.adj_cost := 0;
       dpr.rec_cost := 0;
       dpr.reval_amo_basis := 0;
       dpr.deprn_rsv := 0;
       dpr.reval_rsv := 0;
       dpr.adj_rate := 0;
       dpr.rate_adj_factor := 0;
       dpr.capacity := 0;
       dpr.ltd_prod := 0;
       dpr.adj_rec_cost := 0;

-- dbms_output.put_line('in fagpsa 2');

       if not FA_GAINLOSS_MIS_PKG.faggbi(bk, ret, p_log_level_rec => p_log_level_rec) then

          fa_srvr_msg.add_message(
             calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
             name       => 'FA_RET_GENERIC_ERROR',
             token1     => 'MODULE',
             value1     => 'FAGGBI',
             token2     => 'INFO',
             value2     => 'FA_BOOKS',
             token3     => 'ASSET',
             value3     => ret.asset_number ,  p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;

       -- Bug 7522956: Initialize method cache to be used
       -- later in faxama
       if (not fa_cache_pkg.fazccmt(
                  bk.method_code,
                  bk.lifemonths,
                  p_log_level_rec => p_log_level_rec)) then

          fa_srvr_msg.add_message(
             calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
             name       => 'FA_RET_GENERIC_ERROR',
             token1     => 'MODULE',
             value1     => 'FAZCCMT',
             token2     => 'PROCESS',
             value2     => 'CACHE',
             token3     => 'METHOD',
             value3     => bk.method_code,
             p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;
-- dbms_output.put_line('in fagpsa 3');

       if not FA_GAINLOSS_MIS_PKG.fagpdi(
                        ret.book, pds_per_year,
                        bk.d_cal, cpd_name,
                        cpd_num, bk.ret_prorate_date,
                        ret_pdnum, p_pds_per_year,
                        bk.fiscal_year_name, p_log_level_rec => p_log_level_rec) then

          fa_srvr_msg.add_message(
             calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
             name       => 'FA_RET_GENERIC_ERROR',
             token1     => 'MODULE',
             value1     => 'FAGPDI',
             token2     => 'INFO',
             value2     => 'Period',
             token3     => 'ASSET',
             value3     => ret.asset_number ,  p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;

-- dbms_output.put_line('in fagpsa 4');

       bk.pers_per_yr := pds_per_year;
       h_retirement_id := ret.retirement_id;
       h_ret_status := ret.status;

       if not FA_GAINLOSS_MIS_PKG.faggfy(bk.prorate_date, bk.p_cal,
                                        pro_mth, pro_fy,
                                        bk.fiscal_year_name, p_log_level_rec => p_log_level_rec) then

          fa_srvr_msg.add_message(
             calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
             name       => 'FA_RET_GENERIC_ERROR',
             token1     => 'MODULE',
             value1     => 'FAGGFY',
             token2     => 'INFO',
             value2     => 'Retirement Prorate Date',
             token3     => 'ASSET',
             value3     => ret.asset_number ,  p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;

       dpr.prorate_jdate := bk.prorate_jdate;
       dpr.deprn_start_jdate := bk.deprn_start_jdate;
       bk.prorate_mth := pro_mth;
       bk.prorate_fy := pro_fy;

       if not FA_GAINLOSS_MIS_PKG.faggfy(bk.deprn_start_date, bk.p_cal,
                                        dsd_mth, dsd_fy,
                                        bk.fiscal_year_name, p_log_level_rec => p_log_level_rec) then

          fa_srvr_msg.add_message(
             calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
             name       => 'FA_RET_GENERIC_ERROR',
             token1     => 'MODULE',
             value1     => 'FAGGFY',
             token2     => 'INFO',
             value2     => 'Deprn Prorate Date',
             token3     => 'ASSET',
             value3     => ret.asset_number ,  p_log_level_rec => p_log_level_rec);

          return(FALSE);

       end if;

       bk.dsd_mth := dsd_mth;
       bk.dsd_fy := dsd_fy;

       /* Partially fill in the deprn structure */

       dpr.asset_id := ret.asset_id;
       dpr.book := ret.book;
       dpr.adj_cost := bk.adjusted_cost;
       dpr.rec_cost := bk.recoverable_cost;
       dpr.adj_rate := bk.adj_rate;
       dpr.rate_adj_factor := bk.raf;
       dpr.reval_amo_basis := bk.reval_amort_basis;
       dpr.adj_capacity := bk.adj_capacity;
       dpr.capacity := bk.adj_capacity;
       dpr.ltd_prod := 0;

       dpr.adj_rec_cost := bk.adj_rec_cost;
       dpr.salvage_value := bk.salvage_value;
       dpr.old_adj_cost := bk.old_adj_cost;
       dpr.formula_factor := bk.formula_factor;
       dpr.set_of_books_id := ret.set_of_books_id;

       /* Copy FA_BOOKS.ANNUAL_DEPRN_ROUNDING_FLAG from bk_struct to deprn_struct */

       /* BUG# 2440378: Convert internal number code for rounding to string code.
          dpr.deprn_rounding_flag := bk.deprn_rounding_flag;
       */
       if (bk.deprn_rounding_flag is null
           or bk.deprn_rounding_flag=0) then
          dpr.deprn_rounding_flag := NULL;
       elsif bk.deprn_rounding_flag=1 then
          dpr.deprn_rounding_flag := 'ADD';
       elsif bk.deprn_rounding_flag=2 then
          dpr.deprn_rounding_flag := 'ADJ';
       elsif bk.deprn_rounding_flag=3 then
          dpr.deprn_rounding_flag := 'RET';
       elsif bk.deprn_rounding_flag=4 then
          dpr.deprn_rounding_flag := 'REV';
       elsif bk.deprn_rounding_flag=5 then
          dpr.deprn_rounding_flag := 'TFR';
       elsif bk.deprn_rounding_flag=6 then
          dpr.deprn_rounding_flag := 'RES';
       elsif bk.deprn_rounding_flag=7 then
          dpr.deprn_rounding_flag := 'OVE';
       else
          dpr.deprn_rounding_flag := NULL;
       end if;


       dpr.asset_num := ret.asset_number;
       dpr.calendar_type := bk.d_cal;
       dpr.ceil_name := bk.ceiling_name;
       dpr.bonus_rule := bk.bonus_rule;
       dpr.method_code := bk.method_code;
       dpr.jdate_in_service := bk.jdis;
       dpr.life := bk.lifemonths;
       dpr.y_begin := bk.cpd_fiscal_year;
       dpr.y_end := bk.cpd_fiscal_year;

       /* Adding the following for short tax years */
       dpr.short_fiscal_year_flag := bk.short_fiscal_year_flag;
       dpr.conversion_date := bk.conversion_date;
       dpr.prorate_date := bk.prorate_date;
       dpr.orig_deprn_start_date := bk.orig_deprn_start_date;

       if ret.status = 'PENDING' then

          if not FA_GAINLOSS_RET_PKG.fagret(ret, bk, dpr, today, cpd_ctr,
                                        cpd_num,
                                        ret_pdnum, user_id, p_log_level_rec => p_log_level_rec) then

             fa_srvr_msg.add_message(
               calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
               name       => 'FA_RET_PROCESS_ERROR',
               token1     => 'MODULE',
               value1     => 'FAGRET',
               token2     => 'PROCESS',
               value2     => 'retire',
               token3     => 'ASSET',
               value3     => ret.asset_number ,  p_log_level_rec => p_log_level_rec);

             return(FALSE);

          end if;

       else

          if not FA_GAINLOSS_UND_PKG.fagrin(ret, bk, dpr, today, cpd_ctr,
                                                        cpd_num,
                                                        user_id, p_log_level_rec => p_log_level_rec) then

             fa_srvr_msg.add_message(
               calling_fn => 'fa_gainloss_pro_pkg.fagpsa',
               name       => 'FA_RET_PROCESS_ERROR',
               token1     => 'MODULE',
               value1     => 'FAGRIN',
               token2     => 'PROCESS',
               value2     => 'reinstate',
               token3     => 'ASSET',
               value3     => ret.asset_number ,  p_log_level_rec => p_log_level_rec);

             return(FALSE);

          end if;

       end if;

       return(TRUE);

    END FAGPSA;


END FA_GAINLOSS_PRO_PKG;    -- End of Package EFA_RPRO

/
