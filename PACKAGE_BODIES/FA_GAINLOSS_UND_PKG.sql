--------------------------------------------------------
--  DDL for Package Body FA_GAINLOSS_UND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_GAINLOSS_UND_PKG" AS
/* $Header: fagundb.pls 120.44.12010000.12 2010/01/25 03:09:29 glchen ship $*/

g_release                  number  := fa_cache_pkg.fazarel_release;


/* Added types and variables at global level for bug 7396397*/

  cursor c_g_adj is
  SELECT  fadh.distribution_id,
          fadh.code_combination_id,
          fadh.location_id,
          fadh.assigned_to,
          'N' retire_rec_found,
          0 cost,
          0 DEPRN_RSV,
          0 REVAL_RSV,
          0 BONUS_DEPRN_RSV,
          0 IMPAIRMENT_RSV,
          0 new_units,
          fadh.code_combination_id adj_ccid
  FROM  fa_distribution_history fadh
  where 1=0;

  cursor c_g_ret is
  SELECT  fadh.distribution_id,
          faadj.transaction_header_id,
          fadh.code_combination_id,
          fadh.location_id,
          fadh.assigned_to,
          faadj.adjustment_type,
          faadj.debit_credit_flag,
          faadj.adjustment_amount,
          'N' adj_rec_found,
          faadj.code_combination_id adj_ccid
  FROM  fa_adjustments faadj, fa_distribution_history fadh
  WHERE 1=0;

  cursor c_g_cost_ret IS
  SELECT faadj.adjustment_type,
         faadj.adjustment_amount,
         faadj.debit_credit_flag,
         faadj.debit_credit_flag rev_debit_credit_flag,
         faadj.code_combination_id adj_ccid
  from   fa_adjustments faadj
  where  1=0;

  type tbl_adj is table of c_g_adj%rowtype index by pls_integer;
  type tbl_ret is table of c_g_ret%rowtype index by pls_integer;
  type tbl_cost_ret is table of c_g_cost_ret%rowtype index by binary_integer;

  g_tbl_adj_cost tbl_adj;
  g_tbl_adj_rsv  tbl_adj;

  type typ_adj_rec is RECORD
  (asset_id fa_books.asset_id%type,
   dist_id fa_adjustments.distribution_id%type,
   ccid    fa_adjustments.code_combination_id%type,
   adj_type fa_adjustments.adjustment_type%type,
   dr_cr fa_adjustments.debit_credit_flag%type,
   cost  fa_adjustments.adjustment_amount%type);
  type tbl_final_adj is table of typ_adj_rec index by binary_integer;

  function process_adj_table(p_mode IN VARCHAR2,
                             RET IN fa_ret_types.ret_struct,
                             BK  IN fa_ret_types.book_struct,
                             p_tbl_adj IN OUT NOCOPY tbl_adj,
                             p_tbl_ret IN OUT NOCOPY tbl_ret,
                             p_tbl_cost_ret IN OUT NOCOPY tbl_cost_ret,
                             p_tbl_adj_final IN OUT NOCOPY tbl_final_adj, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean;
  /* End of variables at global level for bug 7396397*/

/*===========================================================================
| NAME      fagiar
|
| FUNCTION  Adjust the GAIN/LOSS and ITC accounts by the same amount we took
|           back then.
|
| History   Jacob John          1/29/97         Created
|
|
|
|==========================================================================*/

Function FAGIAR(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        cpd_ctr IN number,
        user_id IN number,
        today IN date
, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean  IS

    adj_row  fa_adjust_type_pkg.fa_adj_row_struct;
    dr_cr   varchar2(3);
    adj_type varchar2(16);

    h_wip_asset         integer;
    h_ret_id            number;
    h_user_id           number;
    h_today             date;
    h_th_id_out         number;
    h_dr_cr             varchar2(3);
    h_adj_type          varchar2(16);
    h_dist_id           number;
    h_ccid              number;
    h_misc_cost         number;
    h_asset_id          number;
    h_track_member_flag varchar2(1);  --Bug8244128

    x number;

    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;

    l_group_thid        number(15);

    CURSOR c_get_group_thid IS
      SELECT transaction_header_id
      FROM   fa_transaction_headers
      WHERE  member_transaction_header_id = ret.th_id_in
      AND    asset_id = bk.group_asset_id
      AND    book_type_code = ret.book;

    CURSOR MISC_COST (p_group_thid     number,
                      p_group_asset_id number,
                      p_wip_asset      number,
                      p_ret_id         number) IS
    SELECT
        faadj.asset_id,
        faadj.distribution_id,
        faadj.code_combination_id,
        faadj.adjustment_type,
        DECODE(faadj.debit_credit_flag, 'CR', 'DR', 'CR'),
        faadj.adjustment_amount,
        faadj.track_member_flag   --Bug8244128
    FROM
        fa_adjustments faadj, fa_retirements faret, fa_deprn_periods dp
    WHERE faadj.transaction_header_id = faret.transaction_header_id_in
    AND   faadj.asset_id = faret.asset_id
    AND   faadj.book_type_Code = faret.book_type_code
    AND   faadj.source_type_code = decode(p_wip_asset, 1, 'CIP RETIREMENT',
                                          'RETIREMENT')
    AND   faadj.adjustment_type in ('PROCEEDS', 'REMOVALCOST',
                                    'NBV RETIRED', 'REVAL RSV RET',
                                    'PROCEEDS CLR',
                                    'REMOVALCOST CLR',
                                    'CAPITAL ADJ',
                                    'GENERAL FUND')   -- Added for Bug 6666666
    AND   faret.retirement_id = p_ret_id
    AND   dp.book_type_code = faret.book_type_code
    AND   faret.date_effective between dp.period_open_date and
                                       nvl(dp.period_close_date, sysdate)
    AND   faadj.period_counter_created = dp.period_counter
    UNION
    SELECT
        faadj.asset_id,
        faadj.distribution_id,
        faadj.code_combination_id,
        faadj.adjustment_type,
        DECODE(faadj.debit_credit_flag, 'CR', 'DR', 'CR'),
        faadj.adjustment_amount,
        faadj.track_member_flag   --Bug8244128
    FROM
        fa_adjustments faadj, fa_retirements faret, fa_deprn_periods dp
    WHERE faadj.transaction_header_id = p_group_thid
    AND   faadj.asset_id = p_group_asset_id
    AND   faadj.book_type_Code = faret.book_type_code
    AND   faadj.source_type_code = decode(p_wip_asset, 1, 'CIP RETIREMENT',
                                          'RETIREMENT')
    AND   faadj.adjustment_type in ('PROCEEDS', 'REMOVALCOST',
                                    'NBV RETIRED', 'REVAL RSV RET',
                                    'PROCEEDS CLR',
                                    'REMOVALCOST CLR',
                                    'CAPITAL ADJ',
                                    'GENERAL FUND')  -- Added for Bug 6666666
    AND   faret.retirement_id = p_ret_id
    AND   dp.book_type_code = faret.book_type_code
    AND   faret.date_effective between dp.period_open_date and
                                       nvl(dp.period_close_date, sysdate)
    AND   faadj.period_counter_created = dp.period_counter;

    CURSOR MRC_MISC_COST (p_group_thid     number,
                          p_group_asset_id number,
                          p_wip_asset      number,
                          p_ret_id         number) IS
    SELECT
        faadj.asset_id,
        faadj.distribution_id,
        faadj.code_combination_id,
        faadj.adjustment_type,
        DECODE(faadj.debit_credit_flag, 'CR', 'DR', 'CR'),
        faadj.adjustment_amount,
        faadj.track_member_flag   --Bug8244128
    FROM
        fa_mc_adjustments faadj,
        fa_mc_retirements faret,
        fa_deprn_periods     dp
    WHERE faadj.transaction_header_id = faret.transaction_header_id_in
    AND   faadj.asset_id = faret.asset_id
    AND   faadj.set_of_books_id = ret.set_of_books_id
    AND   faadj.book_type_Code = faret.book_type_code
    AND   faadj.source_type_code = decode(p_wip_asset, 1, 'CIP RETIREMENT',
                                          'RETIREMENT')
    AND   faadj.adjustment_type in ('PROCEEDS', 'REMOVALCOST',
                                    'NBV RETIRED', 'REVAL RSV RET',
                                    'PROCEEDS CLR',
                                    'REMOVALCOST CLR',
                                    'CAPITAL ADJ',
                                    'GENERAL FUND')  -- Added for Bug 6666666
    AND   faret.retirement_id = p_ret_id
    AND   faret.set_of_books_id = ret.set_of_books_id
    AND   dp.book_type_code = faret.book_type_code
    AND   faret.date_effective between dp.period_open_date and
                                       nvl(dp.period_close_date, sysdate)
    AND   faadj.period_counter_created = dp.period_counter
    UNION
    SELECT
        faadj.asset_id,
        faadj.distribution_id,
        faadj.code_combination_id,
        faadj.adjustment_type,
        DECODE(faadj.debit_credit_flag, 'CR', 'DR', 'CR'),
        faadj.adjustment_amount,
        faadj.track_member_flag   --Bug8244128
    FROM
        fa_mc_adjustments faadj,
        fa_mc_retirements faret,
        fa_deprn_periods     dp
    WHERE faadj.transaction_header_id = p_group_thid
    AND   faadj.asset_id = p_group_asset_id
    AND   faadj.book_type_Code = faret.book_type_code
    AND   faadj.set_of_books_id = ret.set_of_books_id
    AND   faadj.source_type_code = decode(p_wip_asset, 1, 'CIP RETIREMENT',
                                          'RETIREMENT')
    AND   faadj.adjustment_type in ('PROCEEDS', 'REMOVALCOST',
                                    'NBV RETIRED', 'REVAL RSV RET',
                                    'PROCEEDS CLR',
                                    'REMOVALCOST CLR',
                                    'CAPITAL ADJ',
                                    'GENERAL FUND')  -- Added for Bug 6666666
    AND   faret.retirement_id = p_ret_id
    AND   faret.set_of_books_id = ret.set_of_books_id
    AND   dp.book_type_code = faret.book_type_code
    AND   faret.date_effective between dp.period_open_date and
                                       nvl(dp.period_close_date, sysdate)
    AND   faadj.period_counter_created = dp.period_counter;

    FAGIAR_ERROR Exception;

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagiar';

    BEGIN <<FAGIAR>>

    h_misc_cost := 0;
    h_ret_id := ret.retirement_id;
    h_today := today;
    h_user_id := user_id;
    h_wip_asset := ret.wip_asset;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Updating fa_retirements',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if (ret.mrc_sob_type_code <> 'R') then
        UPDATE FA_RETIREMENTS
        SET status = 'DELETED',
            last_update_date = today,
            last_updated_by = user_id
        WHERE retirement_id = ret.retirement_id;
    else
        UPDATE FA_MC_RETIREMENTS
        SET status = 'DELETED',
            last_update_date = today,
            last_updated_by = user_id
        WHERE retirement_id = ret.retirement_id
          AND set_of_books_id = ret.set_of_books_id;
    end if;

    -- Get thid_out from fa_rets
    -- this can never be different for primary and reporting book
    select  transaction_header_id_out
    into    h_th_id_out
    from    fa_retirements
    where   retirement_id = h_ret_id;

    if ret.wip_asset > 0 then
        adj_row.source_type_code := 'CIP RETIREMENT';
    else
        adj_row.source_type_code := 'RETIREMENT';
    end if;

    adj_row.transaction_header_id := h_th_id_out;
    adj_row.asset_invoice_id :=  0;
    adj_row.book_type_code := ret.book;
    adj_row.period_counter_created := cpd_ctr;
    adj_row.period_counter_adjusted := cpd_ctr;
    adj_row.last_update_date := today;
    adj_row.account := NULL;
    adj_row.account_type := NULL;
    adj_row.current_units := bk.cur_units;
    adj_row.selection_mode := fa_std_types.FA_AJ_SINGLE;
    adj_row.selection_thid := 0;
    adj_row.selection_retid := 0;
    adj_row.flush_adj_flag := TRUE;
    adj_row.gen_ccid_flag := FALSE;
    adj_row.annualized_adjustment := 0;
    adj_row.units_retired := 0;
    adj_row.leveling_flag := TRUE;

    if (bk.group_asset_id is not null) then
      OPEN c_get_group_thid;
      FETCH c_get_group_thid INTO l_group_thid;
      CLOSE c_get_group_thid;
    end if;

    -- Get misc cost info

    if (ret.mrc_sob_type_code <> 'R') then
        OPEN MISC_COST
              (l_group_thid,
               bk.group_asset_id,
               h_wip_asset,
               h_ret_id);
    else
        OPEN MRC_MISC_COST
              (l_group_thid,
               bk.group_asset_id,
               h_wip_asset,
               h_ret_id);
    end if;

    LOOP
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'adj_row.adjustment_amount ###',
             value   => 'start of loop', p_log_level_rec => p_log_level_rec);
       -- Get misc cost info

            if (ret.mrc_sob_type_code <> 'R') then
                FETCH MISC_COST INTO
                   h_asset_id,
                   h_dist_id,
                   h_ccid,
                   h_adj_type,
                   h_dr_cr,
                   h_misc_cost,
                   h_track_member_flag;  --Bug8244128
                EXIT WHEN MISC_COST%NOTFOUND OR MISC_COST%NOTFOUND IS NULL;
            else
                FETCH MRC_MISC_COST INTO
                   h_asset_id,
                   h_dist_id,
                   h_ccid,
                   h_adj_type,
                   h_dr_cr,
                   h_misc_cost,
                   h_track_member_flag;  --Bug8244128
                EXIT WHEN MRC_MISC_COST%NOTFOUND OR MRC_MISC_COST%NOTFOUND IS NULL;
            end if;

            adj_row.asset_id := h_asset_id;
            adj_row.code_combination_id := h_ccid;
            adj_row.adjustment_amount := h_misc_cost;
            adj_row.distribution_id :=  h_dist_id;
            adj_row.debit_credit_flag := h_dr_cr;
            adj_row.adjustment_type := h_adj_type;
            adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
            adj_row.set_of_books_id := ret.set_of_books_id;
            adj_row.track_member_flag := h_track_member_flag; --Bug8244128

         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'adj_row.adjustment_amount ###',
             value   => adj_row.adjustment_amount, p_log_level_rec => p_log_level_rec);

            if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

               fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

               return(false);
            end if;
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'adj_row.adjustment_amount ###',
             value   => 'end of loop', p_log_level_rec => p_log_level_rec);
       END LOOP;
           fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'adj_row.adjustment_amount ###',
             value   => 'end of call', p_log_level_rec => p_log_level_rec);
    if (ret.mrc_sob_type_code <> 'R') then
        CLOSE MISC_COST;
    else
        CLOSE MRC_MISC_COST;
    end if;

    return(true);

  EXCEPTION

         when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

 END;

/*====================================================================
*   NAME     fagtax
*
*   FUNCTION
*    For partial unit retirement reinstatements in the corp book,
*    we need to insert adjustment rows in associated tax books to
*    move balances to distributions which will be created as a
*    result of the reinstatement.
*
| History   Jacob John          1/29/97         Created
*======================================================================*/


Function FAGTAX(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        today IN date
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

    adj_row     fa_adjust_type_pkg.fa_adj_row_struct;
    dpr_row     fa_std_types.fa_deprn_row_struct;
    dpr_dtl     fa_std_types.dpr_dtl_row_struct;

    h_book              varchar2(30);
    h_retirement_id     number;
    h_cpd_num           Number;
    h_trans_header_id_in  Number;
    h_trans_header_id_out Number;
    h_category_id       Number;
    h_asset_id          number;

    --variables added for fix to bug 688397
    h_period_ctr        number;
    h_cost              number;
    h_ytd               number;
    h_deprn_reserve     number;
    h_reval_reserve     number;
    h_ind_rr            number;
    h_ytd_reval_dep_exp number;
    h_ind_yrde          number;
    h_is_prior_period   number;
--added the following 2 variables for bug no.3831503
    h_mrc_sob_type_code varchar2(1);
    h_set_of_books_id   number(15);

    fagtax_error        Exception;
    h_success           boolean := TRUE;

    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;

--modifying the cursors for bug no. 3831503 and using a single cursor for both mrc and primary book
CURSOR TAX_BOOKS_DR IS
    SELECT
        'P',bc.set_of_books_id,
        bc.book_type_code,
        retire.transaction_header_id_out,
        retire.transaction_header_id_in,
        bk.group_asset_id
    FROM  fa_book_controls bc, fa_retirements retire, fa_books bk
    WHERE
          retire.retirement_id = RET.retirement_id
    AND   retire.units is not null
    AND   bc.distribution_source_book = retire.book_type_code
    AND   bc.book_class = 'TAX'
    AND   bc.date_ineffective is null
    AND   bk.book_type_code = bc.book_type_code
    AND   bk.asset_id = RET.asset_id
    AND   bk.date_ineffective is null
    UNION ALL
    SELECT
       'R',fmcbc.set_of_books_id,
       fmcbc.book_type_code,
       retire.transaction_header_id_out,
       retire.transaction_header_id_in,
       bk.group_asset_id
    FROM  fa_mc_book_controls fmcbc,fa_book_controls fbc, fa_retirements retire, fa_mc_books bk
    WHERE
          retire.retirement_id = RET.retirement_id
    AND   retire.units is not null
    AND   fbc.distribution_source_book = retire.book_type_code
    AND   fbc.book_type_code=fmcbc.book_type_code
    AND   fmcbc.enabled_flag = 'Y'
    AND   fbc.set_of_books_id=fmcbc.primary_set_of_books_id
    AND   fbc.book_class = 'TAX'
    AND   fbc.date_ineffective is null
    AND   bk.book_type_code = fmcbc.book_type_code
    AND   bk.asset_id = RET.asset_id
    AND   bk.date_ineffective is null
    ORDER BY 3,1;

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagtax';

    h_group_asset_id    NUMBER(15);
    l_status            BOOLEAN;
    l_asset_hdr_rec     FA_API_TYPES.asset_hdr_rec_type;
    l_asset_cat_rec     FA_API_TYPES.asset_cat_rec_type;
    l_temp_amount       number;

    l_trans_rec         FA_API_TYPES.trans_rec_type;
    l_asset_type_rec    FA_API_TYPES.asset_type_rec_type;
    l_period_rec        FA_API_TYPES.period_rec_type;

   BEGIN <<FAGTAX>>

    -- We need to move the cost, reserve and reval reserve to the
    --   new distribution_id's for all of the tax books.

    h_asset_id := ret.asset_id;
    h_retirement_id := ret.retirement_id;

    adj_row.asset_invoice_id :=  0;

    --bug 6129798
    if RET.wip_asset > 0 then
        adj_row.source_type_code := 'CIP RETIREMENT';
    else
        adj_row.source_type_code := 'RETIREMENT';
    end if;

    adj_row.asset_id := RET.asset_id;
    adj_row.last_update_date := today;
    adj_row.current_units := bk.cur_units;
    adj_row.selection_retid := 0;
    adj_row.flush_adj_flag := TRUE;
    adj_row.annualized_adjustment := 0;
    adj_row.units_retired := 0;
    adj_row.leveling_flag := TRUE;

    if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 1',
                         value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add
         (fname   => l_calling_fn,
          element => 'Get category from fa_asset_history',
          value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => 'asset_id',
                         value   => RET.asset_id, p_log_level_rec => p_log_level_rec);
    end if;

    SELECT category_id
    INTO h_category_id
    FROM fa_asset_history
    WHERE asset_id = RET.asset_id
    AND date_ineffective is null;

    if (p_log_level_rec.statement_level) then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 2',
                         value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    OPEN TAX_BOOKS_DR;

    LOOP

        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Fetch Tax Books_DR',
             value   => '', p_log_level_rec => p_log_level_rec);
        end if;

        FETCH TAX_BOOKS_DR INTO
                h_mrc_sob_type_code,
                h_set_of_books_id,
                h_book,
                h_trans_header_id_out,
                h_trans_header_id_in,
                h_group_asset_id;
        EXIT WHEN TAX_BOOKS_DR%NOTFOUND OR TAX_BOOKS_DR%NOTFOUND IS NULL;

        /* Fix for Bug#2821938 */
        if not fa_cache_pkg.fazcbc (x_book => h_book, p_log_level_rec => p_log_level_rec) then
           RAISE fagtax_error;
        end if;


        --   fix for bug 688397: check if asset is added in a prior period
        --   in the tax book. If it is a current period period add call
        --   fadpdtl to update 'B' row with new distribution and not create
        --   fa_adjustments rows. Insert into fa_adjustments only if asset is
        --   not a current period add in tax book.  snarayan Jul 4 1998

       -- count will be 0 if it is a current period add

       SELECT     count(*)
       INTO
                       h_is_prior_period
       FROM
                        FA_TRANSACTION_HEADERS TH,
                        FA_BOOK_CONTROLS BC,
                        FA_DEPRN_PERIODS DP,
                        FA_DEPRN_PERIODS DP_NOW
       WHERE
                        TH.ASSET_ID = h_asset_id AND
--                        TH.TRANSACTION_TYPE_CODE = 'ADDITION' AND  --bug 6129798
                        TH.TRANSACTION_TYPE_CODE in ('ADDITION', 'CIP ADDITION') AND --bug 6129798
                        TH.BOOK_TYPE_CODE = BC.BOOK_TYPE_CODE AND
                        BC.BOOK_TYPE_CODE = h_book AND
                        TH.DATE_EFFECTIVE BETWEEN
                                DP.PERIOD_OPEN_DATE AND
                                        NVL(DP.PERIOD_CLOSE_DATE, SYSDATE)
       AND
                        DP.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE AND
                        DP.PERIOD_COUNTER < DP_NOW.PERIOD_COUNTER AND
                        DP_NOW.BOOK_TYPE_CODE = TH.BOOK_TYPE_CODE AND
                        DP_NOW.PERIOD_CLOSE_DATE IS NULL;


        if (h_is_prior_period = 0 and
            G_release = 11) then --bug 6129798
           -- current period add in tax book
           -- modified the last parameter passed for bug no. 3831503
           l_status := FA_INS_DETAIL_PKG.FAXINDD(
                                 X_book_type_code     => h_book,
                                 X_asset_id           => h_asset_id,
                                 X_set_of_books_id    => ret.set_of_books_id,
                                 X_mrc_sob_type_code  => h_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);

           if not (l_status) then
              raise fagtax_error;
           end if;

           if (h_group_asset_id is not null) then

              l_status := FA_INS_DETAIL_PKG.FAXINDD(
                                    X_book_type_code     => h_book,
                                    X_asset_id           => h_group_asset_id,
                                    X_set_of_books_id    => ret.set_of_books_id,
                                    X_mrc_sob_type_code  => h_mrc_sob_type_code, p_log_level_rec => p_log_level_rec);

              if not (l_status) then
                 raise fagtax_error;
              end if;

           end if; -- (h_group_asset_id is not null)

        else -- added in prior period,insert into fa_adjustments

           -- SLA UPTAKE
           -- assign an event for the transaction
           if (h_mrc_sob_type_code = 'P') then

              if (NOT fa_trx_approval_pkg.faxcat
                 (X_book              => h_book,
                  X_asset_id          => ret.asset_id,
                  X_trx_type          => 'REINSTATEMENT',
                  X_trx_date          => greatest(l_period_rec.calendar_period_open_date,
                                                  least(sysdate,l_period_rec.calendar_period_close_date)),
                  X_init_message_flag => 'NO',
                  p_log_level_rec => p_log_level_rec)) then
                 raise fagtax_error;
              end if;

              if not FA_UTIL_PVT.get_period_rec
                     (p_book       => h_book,
                      x_period_rec => l_period_rec,
                      p_log_level_rec => p_log_level_rec) then
                 raise fagtax_error;
              end if;

              l_asset_hdr_rec.asset_id       := ret.asset_id;
              l_asset_hdr_rec.book_type_code := h_book;
              l_asset_hdr_rec.set_of_books_id := ret.set_of_books_id;
              l_trans_rec.transaction_type_code  := 'TRANSFER';
              l_trans_rec.transaction_header_id  := h_trans_header_id_out;
              l_trans_rec.calling_interface      := 'FARET';
              l_trans_rec.mass_reference_id      := FND_GLOBAL.CONC_REQUEST_ID;
              l_trans_rec.transaction_date_entered :=
                greatest(l_period_rec.calendar_period_open_date,
                         least(sysdate,l_period_rec.calendar_period_close_date));
              l_trans_rec.transaction_date_entered :=
                to_date(to_char(l_trans_rec.transaction_date_entered,'DD/MM/YYYY'),'DD/MM/YYYY');
              -- populate the asset type for the asset
              if not FA_UTIL_PVT.get_asset_type_rec(l_asset_hdr_rec,
                                                l_asset_type_rec, null,
p_log_level_rec) then
                 raise fagtax_error;
              end if;

              if not FA_XLA_EVENTS_PVT.create_transaction_event
              (p_asset_hdr_rec          => l_asset_hdr_rec,
               p_asset_type_rec         => l_asset_type_rec,
               px_trans_rec             => l_trans_rec,
               p_event_status           => NULL,
               p_calling_fn             => l_calling_fn,
               p_log_level_rec => p_log_level_rec
              ) then
                raise fagtax_error;
              end if;

           end if;


            SELECT period_counter
            into h_cpd_num
            from
            fa_deprn_periods
            where book_type_code = h_book
            and period_close_date is null;

                -- We need to move the cost, reserve and reval reserve to the
                -- new distribution_id's for all of the tax books.

            adj_row.transaction_header_id := h_trans_header_id_out;
            adj_row.period_counter_created := h_cpd_num;
            adj_row.period_counter_adjusted := h_cpd_num;
            adj_row.selection_thid := h_trans_header_id_out;
            adj_row.distribution_id :=  0;
            adj_row.gen_ccid_flag := TRUE;
            adj_row.code_combination_id := 0;

            adj_row.book_type_code := h_book;
            adj_row.mrc_sob_type_code := h_mrc_sob_type_code; /* Moved in earlar part of code to avoid duplicat code */
            adj_row.set_of_books_id := ret.set_of_books_id;

            -- Get the various Accts from FA_CATEGORY_BOOKS

            if not fa_cache_pkg.fazccb (h_book, h_category_id, p_log_level_rec => p_log_level_rec) then
                RAISE fagtax_error;
            end if;


            if RET.wip_asset > 0 then
               if not fa_cache_pkg.fazccb (h_book, h_category_id, p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  RAISE fagtax_error;
               end if;
            end if;


            if bk.group_asset_id is null or
               bk.tracking_method = 'CALCULATE' then
--            if (nvl(bk.tracking_method, 'CALCULATE') <> 'ALLOCATE') then
               -- +++++ Clear out the reserve from the old dist_id's +++++
               adj_row.adjustment_type := 'RESERVE';
               adj_row.debit_credit_flag := 'DR';
               adj_row.account_type := 'DEPRN_RESERVE_ACCT';
               adj_row.account :=
                        fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
               adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR;
               adj_row.adjustment_amount := 0;
               adj_row.source_dest_code  := 'SOURCE';

               if (bk.group_asset_id is not null) and
                  (nvl(bk.member_rollup_flag, 'N') = 'N') then
                  adj_row.track_member_flag := 'Y';
               else
                  adj_row.track_member_flag := NULL;
               end if;

               if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(false);

                end if;

               -- +++++ Credit reserve in new dist_id's  +++++
               adj_row.debit_credit_flag  := 'CR';
               adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;
               adj_row.adjustment_amount := adj_row.amount_inserted;
               l_temp_amount := adj_row.amount_inserted;
               adj_row.source_dest_code  := 'DEST';

               if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  return(false);
               end if;

            end if; -- (nvl(bk.tracking_method, 'CALCULATE') <> 'ALLOCATE')

            if (bk.group_asset_id is not null) and
               (nvl(bk.member_rollup_flag, 'N') = 'N') then
               -- +++++ Clear out the reserve from the old dist_id's +++++
               adj_row.adjustment_type := 'RESERVE';
               adj_row.debit_credit_flag := 'DR';
               adj_row.account_type := 'DEPRN_RESERVE_ACCT';
               adj_row.asset_id := bk.group_asset_id;

               l_asset_hdr_rec.asset_id := bk.group_asset_id;
               l_asset_hdr_rec.book_type_code := ret.book;
               l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

               if not FA_UTIL_PVT.get_asset_cat_rec (
                          p_asset_hdr_rec  => l_asset_hdr_rec,
                          px_asset_cat_rec => l_asset_cat_rec,
                          p_date_effective => null, p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  return(FALSE);
               end if;

               if not fa_cache_pkg.fazccb(
                          X_book   => ret.book,
                          X_cat_id => l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  return(FALSE);
               end if;

               adj_row.account :=
                        fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;
               adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR;
               adj_row.adjustment_amount := 0;
               adj_row.track_member_flag := NULL;
               adj_row.source_dest_code  := 'SOURCE';

               if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login, p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                   return(false);

                end if;

               -- +++++ Credit reserve in new dist_id's  +++++
               adj_row.debit_credit_flag  := 'CR';
               adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;

               if (bk.tracking_method = 'CALCULATE') then
                  adj_row.adjustment_amount := l_temp_amount;
               else
                  adj_row.adjustment_amount := adj_row.amount_inserted;
               end if;

               adj_row.source_dest_code  := 'DEST';

               if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  return(false);
               end if;

               adj_row.asset_id := ret.asset_id;

               if not fa_cache_pkg.fazccb (h_book, h_category_id, p_log_level_rec => p_log_level_rec) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  RAISE fagtax_error;
               end if;

            end if; -- (bk.group_asset_id is not null)

            if bk.group_asset_id is null or
               bk.tracking_method = 'CALCULATE' then
--            if (nvl(bk.tracking_method, 'CALCULATE') <> 'ALLOCATE') then
               -- Find reval reserve to determine whether we need
               -- to move that to the new distributions
               dpr_row.asset_id := RET.asset_id;
               dpr_row.book     := h_book;
               dpr_row.period_ctr := 0;
               dpr_row.dist_id := 0;
               dpr_row.mrc_sob_type_code := ret.mrc_sob_type_code;
               dpr_row.set_of_books_id := ret.set_of_books_id;

               FA_QUERY_BALANCES_PKG.query_balances_int (
                     X_DPR_ROW => dpr_row,
                     X_RUN_MODE => 'STANDARD',
                     X_DEBUG => FALSE,
                     X_SUCCESS => H_SUCCESS,
                     X_CALLING_FN => l_calling_fn,
                     X_TRANSACTION_HEADER_ID => -1,
                     p_log_level_rec => p_log_level_rec);

               if not h_success then
                  raise fagtax_error;
               end if;

               if dpr_row.bonus_deprn_rsv <> 0 then

                   --Clear out the bonus reserve from the old dist_id's

                   adj_row.adjustment_type := 'BONUS RESERVE';
                   adj_row.debit_credit_flag := 'DR';
                   adj_row.account_type := 'BONUS_DEPRN_RESERVE_ACCT';
                   adj_row.account :=
                           fa_cache_pkg.fazccb_record.BONUS_DEPRN_RESERVE_ACCT;
                   adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR;
                   adj_row.adjustment_amount := 0;
                   adj_row.source_dest_code  := 'SOURCE';

                   if (bk.group_asset_id is not null)  and
                      (nvl(bk.member_rollup_flag, 'N') = 'N') then
                      adj_row.track_member_flag := 'Y';
                   else
                      adj_row.track_member_flag := NULL;
                   end if;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                          X_last_update_date,
                                          X_last_updated_by,
                                          X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(false);
                   end if;

                   -- Credit bonus reserve to new dist_id's

                   adj_row.debit_credit_flag := 'CR';
                   adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;
                   adj_row.adjustment_amount := adj_row.amount_inserted;
                   adj_row.source_dest_code  := 'DEST';

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                          X_last_update_date,
                                          X_last_updated_by,
                                          X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(False);
                   end if;

               end if;

               if dpr_row.impairment_rsv <> 0 then

                   --Clear out the impairment reserve from the old dist_id's

                   adj_row.adjustment_type := 'IMPAIR RESERVE';
                   adj_row.debit_credit_flag := 'DR';
                   adj_row.account_type := 'IMPAIR_RESERVE_ACCT';
                   adj_row.account :=
                           fa_cache_pkg.fazccb_record.IMPAIR_RESERVE_ACCT;
                   adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR;
                   adj_row.adjustment_amount := 0;
                   adj_row.source_dest_code  := 'SOURCE';

                   if (bk.group_asset_id is not null)  and
                      (nvl(bk.member_rollup_flag, 'N') = 'N') then
                      adj_row.track_member_flag := 'Y';
                   else
                      adj_row.track_member_flag := NULL;
                   end if;

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                          X_last_update_date,
                                          X_last_updated_by,
                                          X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(false);
                   end if;

                   -- Credit impairment reserve to new dist_id's

                   adj_row.debit_credit_flag := 'CR';
                   adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;
                   adj_row.adjustment_amount := adj_row.amount_inserted;
                   adj_row.source_dest_code  := 'DEST';

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                          X_last_update_date,
                                          X_last_updated_by,
                                          X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(False);
                   end if;
               end if;

               if dpr_row.reval_rsv <> 0 then

                   --Clear out the reval reserve from the old dist_id's

                   adj_row.adjustment_type := 'REVAL RESERVE';
                   adj_row.debit_credit_flag := 'DR';
                   adj_row.account_type := 'REVAL_RESERVE_ACCT';
                   adj_row.account :=
                           fa_cache_pkg.fazccb_record.REVAL_RESERVE_ACCT;
                   adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR;
                   adj_row.adjustment_amount := 0;
                   adj_row.source_dest_code  := 'SOURCE';

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                          X_last_update_date,
                                          X_last_updated_by,
                                          X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(false);
                   end if;


                   -- Credit reval reserve to new dist_id's

                   adj_row.debit_credit_flag := 'CR';
                   adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;
                   adj_row.adjustment_amount := adj_row.amount_inserted;
                   adj_row.source_dest_code  := 'DEST';

                   if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                          X_last_update_date,
                                          X_last_updated_by,
                                          X_last_update_login, p_log_level_rec => p_log_level_rec)) then
                      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                      return(False);
                   end if;


               end if;
           end if; -- (nvl(bk.tracking_method, 'CALCULATE') <> 'ALLOCATE')

           if (bk.group_asset_id is not null) and
              (nvl(bk.member_rollup_flag, 'N') = 'N') then

              dpr_row.asset_id := bk.group_asset_id;
              dpr_row.book     := h_book;
              dpr_row.period_ctr := 0;
              dpr_row.dist_id := 0;
              dpr_row.mrc_sob_type_code := ret.mrc_sob_type_code;
              dpr_row.set_of_books_id := ret.set_of_books_id;

              FA_QUERY_BALANCES_PKG.query_balances_int (
                            X_DPR_ROW               => dpr_row,
                            X_RUN_MODE              => 'STANDARD',
                            X_DEBUG                 => FALSE,
                            X_SUCCESS               => H_SUCCESS,
                            X_CALLING_FN            => l_calling_fn,
                            X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

              if not h_success then
                 raise fagtax_error;
              end if;

              if dpr_row.bonus_deprn_rsv <> 0 then

                 --Clear out the bonus reserve from the old dist_id's

                 adj_row.asset_id := bk.group_asset_id;
                 adj_row.adjustment_type := 'BONUS RESERVE';
                 adj_row.debit_credit_flag := 'DR';
                 adj_row.account_type := 'BONUS_DEPRN_RESERVE_ACCT';
                 adj_row.track_member_flag := NULL;

                 l_asset_hdr_rec.asset_id := bk.group_asset_id;
                 l_asset_hdr_rec.book_type_code := ret.book;
                 l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

                 if not FA_UTIL_PVT.get_asset_cat_rec (
                          p_asset_hdr_rec  => l_asset_hdr_rec,
                          px_asset_cat_rec => l_asset_cat_rec,
                          p_date_effective => null, p_log_level_rec => p_log_level_rec) then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);
                 end if;

                 if not fa_cache_pkg.fazccb(
                          X_book   => ret.book,
                          X_cat_id => l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);
                 end if;

                 adj_row.account :=
                         fa_cache_pkg.fazccb_record.BONUS_DEPRN_RESERVE_ACCT;
                 adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR;
                 adj_row.adjustment_amount := 0;
                 adj_row.source_dest_code  := 'SOURCE';

                 if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                        X_last_update_date,
                                        X_last_updated_by,
                                        X_last_update_login
                                        , p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

                   return(false);
                 end if;

                 -- Credit bonus reserve to new dist_id's

                 adj_row.debit_credit_flag := 'CR';
                 adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;
                 adj_row.adjustment_amount := adj_row.amount_inserted;
                 adj_row.source_dest_code  := 'DEST';

                 if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                        X_last_update_date,
                                        X_last_updated_by,
                                        X_last_update_login
                                        , p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

                   return(False);

                 end if;

                 adj_row.asset_id := ret.asset_id;

                 if not fa_cache_pkg.fazccb (h_book, h_category_id, p_log_level_rec => p_log_level_rec) then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    RAISE fagtax_error;
                 end if;

              end if; -- dpr_row.bonus_deprn_rsv <> 0

              if dpr_row.impairment_rsv <> 0 then

                 --Clear out the impairment reserve from the old dist_id's

                 adj_row.asset_id := bk.group_asset_id;
                 adj_row.adjustment_type := 'IMPAIR RESERVE';
                 adj_row.debit_credit_flag := 'DR';
                 adj_row.account_type := 'IMPAIR_RESERVE_ACCT';
                 adj_row.track_member_flag := NULL;

                 l_asset_hdr_rec.asset_id := bk.group_asset_id;
                 l_asset_hdr_rec.book_type_code := ret.book;
                 l_asset_hdr_rec.set_of_books_id := fa_cache_pkg.fazcbc_record.set_of_books_id;

                 if not FA_UTIL_PVT.get_asset_cat_rec (
                          p_asset_hdr_rec  => l_asset_hdr_rec,
                          px_asset_cat_rec => l_asset_cat_rec,
                          p_date_effective => null, p_log_level_rec => p_log_level_rec) then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);
                 end if;

                 if not fa_cache_pkg.fazccb(
                          X_book   => ret.book,
                          X_cat_id => l_asset_cat_rec.category_id, p_log_level_rec => p_log_level_rec) then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);
                 end if;

                 adj_row.account :=
                         fa_cache_pkg.fazccb_record.IMPAIR_RESERVE_ACCT;
                 adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR;
                 adj_row.adjustment_amount := 0;
                 adj_row.source_dest_code  := 'SOURCE';

                 if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                        X_last_update_date,
                                        X_last_updated_by,
                                        X_last_update_login
                                        , p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

                   return(false);
                 end if;

                 -- Credit impairment reserve to new dist_id's

                 adj_row.debit_credit_flag := 'CR';
                 adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;
                 adj_row.adjustment_amount := adj_row.amount_inserted;
                 adj_row.source_dest_code  := 'DEST';

                 if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                        X_last_update_date,
                                        X_last_updated_by,
                                        X_last_update_login
                                        , p_log_level_rec => p_log_level_rec)) then

                   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

                   return(False);

                 end if;

                 adj_row.asset_id := ret.asset_id;

                 if not fa_cache_pkg.fazccb (h_book, h_category_id, p_log_level_rec => p_log_level_rec) then
                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    RAISE fagtax_error;
                 end if;

              end if;

           end if; -- (bk.group_asset_id is null)

            --  Clear out the cost from the old dist_id's

            adj_row.adjustment_type := 'COST';
            adj_row.debit_credit_flag := 'CR';
            adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR;
            adj_row.adjustment_amount := 0;
            adj_row.source_dest_code  := 'SOURCE';

            if (RET.wip_asset is null or ret.wip_asset <= 0)  then
                adj_row.account_type :=  'ASSET_COST_ACCT';
                adj_row.account :=
                        fa_cache_pkg.fazccb_record.ASSET_COST_ACCT;
            else
                adj_row.account_type :=  'CIP_COST_ACCT';
                adj_row.account :=
                        fa_cache_pkg.fazccb_record.CIP_COST_ACCT;
            end if;


            if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

                return(false);

            end if;

            -- Credit cost in new dist_id's

            adj_row.debit_credit_flag := 'DR';
            adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE;
            adj_row.adjustment_amount := adj_row.amount_inserted;
            adj_row.source_dest_code  := 'DEST';

            if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);

                return(False);

            end if;

        end if;  -- if prior period

    END LOOP;      -- out_tax_books_dr

    CLOSE TAX_BOOKS_DR;

    return(true);


EXCEPTION

    when fagtax_error then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;


END;

/*=============================================================
| NAME        fagiat
|
| FUNCTION    Updating the tables affected by the previous retirement. We
|             reactivate the book and distribution history. Notice that
|             for cost retirement, the distribution_history table was NOT
|             affected, thus we don't need to do anything.
|
| History   Jacob John          1/29/97         Created
|==============================================================*/


FUNCTION FAGIAT(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        user_id IN  number,
        cpd_ctr in number,
        today   IN  date,
        p_asset_fin_rec_new FA_API_TYPES.asset_fin_rec_type
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is

        new_distid      NUMBER;
        upd_ctr         NUMBER;


        h_ret_id        number;
        h_asset_id      number;
        h_book          varchar2(30);
        h_today         date;

        h_temp_units    number;

        h_rethdrout     number;
        h_dist_hdrout   number;
        h_rdistid       number;
        h_tdistid       number;
        h_pdistid       number;
        h_new_distid    number;
        h_temp_distid   number;
        h_adj_distid    number;
        h_drflag        number;
        h_user_id       number;
        --fix for 1722165  changed to afnumber to handle fractional units
        h_units_retired number;
        h_units_assigned number;
        h_count         number;
        h_rowid         rowid;
        h_mrc_primary_book_flag number;

        -- Bug:5930979:Japan Tax Reform Project
        l_rate_in_use   number;

                fagiat_error    EXCEPTION;

        --Select active distribution_ids
        CURSOR TRET IS
            SELECT fadh.distribution_id
                FROM    fa_distribution_history fadh,
                        fa_book_controls bc
                WHERE   fadh.asset_id = h_asset_id
                AND     fadh.book_type_code = bc.distribution_source_book
                AND     bc.book_type_code = h_book
                AND     fadh.date_ineffective is null
                ORDER BY fadh.distribution_id;

        -- Select distribution_ids that were retired
        CURSOR PRET IS
            SELECT dh.distribution_id
                FROM fa_distribution_history dh,
                     fa_book_controls bc,
                     fa_retirements rt
                WHERE dh.asset_id = h_asset_id
                AND   dh.book_type_code = bc.distribution_source_book
                AND   bc.book_type_code = h_book
                AND   rt.asset_id = dh.asset_id
                AND   rt.book_type_code = h_book
                AND   dh.date_effective < rt.date_effective
                AND   dh.date_ineffective >= rt.date_effective;


        -- Bug 5149832, 5237765, 5251944
        CURSOR OLD_NEW_DIST IS
           SELECT dh_old.distribution_id,
                  dh_new.distribution_id
           FROM fa_distribution_history dh_old,
                fa_distribution_history dh_new,
                fa_book_controls bc,
                fa_transaction_headers th
           WHERE th.transaction_header_id = h_rethdrout
             and th.asset_id = h_asset_id
             and th.book_type_code = h_book
             and bc.book_type_code = th.book_type_code
   /* nvl condition is added by bug 6709967 */
             and dh_old.transaction_header_id_out = nvl(th.source_transaction_header_id,dh_old.transaction_header_id_out)
             and dh_old.book_type_code = bc.distribution_source_book
             and dh_old.asset_id = h_asset_id
             and
                (dh_old.units_assigned + dh_old.transaction_units = 0 -- FULL RET in dh_old DH row
                 OR
                 exists
                 (select 1 -- PARTIAL RET in dh_pret DH row
                  from fa_distribution_history dh_pret
                  where dh_pret.asset_id = dh_old.asset_id
                    and dh_pret.book_type_code = dh_old.book_type_code
                    and dh_pret.transaction_header_id_out = DH_OLD.transaction_header_id_in
                    and DH_OLD.transaction_units is NULL
                    and dh_pret.units_assigned + dh_pret.transaction_units = dh_old.units_assigned
                    and dh_pret.code_combination_id = dh_old.code_combination_id
                    and nvl(dh_pret.assigned_to,-99) = nvl(dh_old.assigned_to,-99)
                    and dh_pret.location_id = dh_old.location_id
                 )
					  --Added for 8741598
                 OR not exists
                 (select 1
					     from fa_distribution_history fdh1
                   where fdh1.asset_id = dh_old.asset_id
                     and fdh1.book_type_code = dh_old.book_type_code
                     and fdh1.transaction_header_id_in < DH_OLD.transaction_header_id_in)
					  --End of added for 8741598
                )
             -- and dh_new.transaction_header_id_in = dh_old.transaction_header_id_out
             -- and dh_new.location_id = dh_old.location_id
             -- and nvl(dh_new.assigned_to,-99) = nvl(dh_old.assigned_to,-99)
             -- and dh_new.code_combination_id = dh_old.code_combination_id;
             -- Bug:6238808
             and dh_new.asset_id = h_asset_id
             and dh_new.book_type_code = bc.distribution_source_book
             and dh_new.date_ineffective is null;

       CURSOR UPD_DIST IS
                SELECT dh.distribution_id
                FROM   fa_distribution_history dh
                WHERE  dh.book_type_code = h_book
                AND    dh.asset_id = h_asset_id
                AND    dh.transaction_header_id_out is null
                AND    exists
                (
                 SELECT 'x'
                 FROM   fa_distribution_history ret
                 WHERE  ret.book_type_code = h_book
                 AND    ret.asset_id = h_asset_id
                 AND    ret.retirement_id = h_ret_id
                 AND    ret.code_combination_id = dh.code_combination_id
                 AND    ret.location_id = dh.location_id
                 AND    nvl (ret.assigned_to, -99) = nvl (dh.assigned_to, -99)
                );

        CURSOR CRET IS
                SELECT dh.distribution_id,
                       dh.units_assigned
                FROM   fa_distribution_history dh
                WHERE  dh.book_type_code = h_book
                AND    dh.asset_id = h_asset_id
                AND    dh.transaction_header_id_out = h_rethdrout
                UNION
                SELECT r.distribution_id, 0 -  nvl (r.transaction_units, 0)
                FROM   fa_distribution_history r
                WHERE  r.book_type_code = h_book
                AND    r.asset_id = h_asset_id
                AND    r.retirement_id = h_ret_id
                AND    not exists
                (
                 SELECT 'x'
                 FROM   fa_distribution_history d
                 WHERE  d.book_type_code = h_book
                 AND    d.asset_id = h_asset_id
                 AND    d.transaction_header_id_out = h_rethdrout
                 AND    r.code_combination_id = d.code_combination_id
                 AND    r.location_id = d.location_id
                 AND    nvl (r.assigned_to, -99) = nvl (d.assigned_to, -99)
                );

        /* BUG 2775057 added joins for ccid, location, and employe
         * as this would result in the first distribution being used
         * for all updates in the case of multi-distributed assets
        */
        CURSOR CHG_DIST IS
                select d1.distribution_id
                from  fa_distribution_history d1,
                      fa_distribution_history d2
                where d2.book_type_code = h_book
                and   d2.asset_id = h_asset_id
                and   d1.book_type_code = d2.book_type_code
                and   d1.asset_id = d2.asset_id
                and   d1.transaction_header_id_in =
                             d2.transaction_header_id_out
                and   ((abs(d2.transaction_units) =
                                       d1.units_assigned) or
                        (d2.retirement_id = h_ret_id))
                and   d2.distribution_id = h_adj_distid
                and   d1.code_combination_id = d2.code_combination_id -- added for bug 2775057
                and   d1.location_id = d2.location_id -- added for bug 2775057
                and   nvl(d1.assigned_to, -99) = nvl(d2.assigned_to, -99); -- added for bug 2775057

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagiat';

    l_temp_dist_id1 number;

   BEGIN <<FAGIAT>>

    h_today := today;
    h_ret_id := ret.retirement_id;
    h_asset_id := ret.asset_id;
    h_user_id := user_id;
    h_book := ret.book;
    h_units_retired := ret.units_retired;
    h_temp_units := 0;

    /*
    -- CHECK to see if the following can be replaced with ret.mrc_sob_type_code
    -- select returns 0: if reporting book... 1: if primary book
    SELECT count(*)
             INTO   h_mrc_primary_book_flag
             FROM   gl_sets_of_books GL, fa_book_controls FA
             WHERE  gl.set_of_books_id = fa.set_of_books_id
             AND    fa.book_type_code = h_book
             AND    gl.mrc_sob_type_code <> 'R'
             AND    rownum <= 1;
    */

    SELECT
            transaction_header_id_out
    INTO    h_rethdrout
    FROM    fa_retirements
    WHERE   retirement_id = h_ret_id;

    if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Updating FA_BOOKS',
             value   => '', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, '++ h_ret_id in fagiat',h_ret_id, p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add(l_calling_fn, '++ h_rethdrout',h_rethdrout, p_log_level_rec => p_log_level_rec);
    ENd if;

/*  Replaced this with the following
    if (h_mrc_primary_book_flag = 1) then
        UPDATE FA_BOOKS
        SET date_ineffective = h_today, -- to_date(h_today,'DD/MM/YYYY hh24:mi:ss'),
            transaction_header_id_out = h_rethdrout,
            last_updated_by = h_user_id,
            last_update_date = h_today -- to_date(h_today, 'DD/MM/YYYY hh24:mi:ss')
        WHERE book_type_code = h_book
        AND asset_id = h_asset_id
        AND date_ineffective is null;
    end if;
*/
    if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Deactivate fa_books row',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'X_transaction_header_id_out',
             value   => h_rethdrout, p_log_level_rec => p_log_level_rec);
    end if;

    -- Bug:5930979:Japan Tax Reform Project (Start)
    if fa_cache_pkg.fazccmt_record.GUARANTEE_RATE_METHOD_FLAG = 'YES' then
       if ret.mrc_sob_type_code <> 'R' then
          select nvl(rate_in_use,0)
          into l_rate_in_use
          from fa_books
          where asset_id = ret.asset_id
          and book_type_code = ret.book
          and transaction_header_id_out is null;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add(l_calling_fn, 'rate_in_use (P) ', l_rate_in_use);
          end if;

       else -- for reporting
          -- MRC
          /*select nvl(rate_in_use,0)
          into l_rate_in_use
          from fa_mc_books
          where asset_id = ret.asset_id
          and book_type_code = ret.book
          and set_of_books_id = ret.set_of_books_id
          and transaction_header_id_out is null;*/

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add(l_calling_fn, 'rate_in_use (R) ', l_rate_in_use);
          end if;
       end if;
    end if;
    -- Bug:5930979:Japan Tax Reform Project (End)

        -- terminate the active row
    fa_books_pkg.deactivate_row
        (X_asset_id                  => h_asset_id,
         X_book_type_code            => h_book,
         X_transaction_header_id_out => h_rethdrout,
         X_date_ineffective          => h_today,
         X_mrc_sob_type_code         => ret.mrc_sob_type_code,
         X_set_of_books_id           => ret.set_of_books_id,
         X_Calling_Fn                => l_calling_fn
         , p_log_level_rec => p_log_level_rec);


    if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Create a new fa_books row',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    /* Fix for Bug# 2513013: When reinstated, a newly created row in fa_books
     *        had null in period_counter_life_complete since this was missing in the following insert.
     */

    if ret.mrc_sob_type_code <> 'R' then
        INSERT into fa_books
        (book_type_Code, asset_id, date_placed_in_service,
         transaction_header_id_in, date_effective, transaction_header_id_out,
         date_ineffective, deprn_start_date, deprn_method_code,
         life_in_months, rate_adjustment_factor, adjusted_cost, cost,
         original_cost, salvage_value, period_counter_fully_retired,
         period_counter_fully_reserved,period_counter_life_complete,
         prorate_convention_code, prorate_date, itc_amount_id,
         itc_amount, cost_change_flag,
         adjustment_required_status,capitalize_flag,
         retirement_id, retirement_pending_flag, depreciate_flag,
         last_update_date,
         last_updated_by, itc_basis, tax_request_id,
         period_counter_capitalized, basic_rate, adjusted_rate, bonus_rule,
         ceiling_name, recoverable_cost,
         reval_amortization_basis, reval_ceiling,
         production_capacity, fully_rsvd_revals_counter,
         idled_flag, unit_of_measure, unrevalued_cost, adjusted_capacity,
         short_fiscal_year_flag, conversion_date, original_deprn_start_date,
         remaining_life1, remaining_life2,
         old_adjusted_cost, formula_factor,
         annual_deprn_rounding_flag,
         percent_salvage_value, allowed_deprn_limit, allowed_deprn_limit_amount
         , group_asset_id
         , recapture_reserve_flag
         , salvage_type
         , deprn_limit_type
         , super_group_id
         , reduce_addition_flag
         , reduce_adjustment_flag
         , reduce_retirement_flag
         , ytd_proceeds
         , ltd_proceeds
         , reduction_rate
         , over_depreciate_option
         , limit_proceeds_flag
         , terminal_gain_loss
         , tracking_method
         , exclude_fully_rsv_flag
         , excess_allocation_option
         , depreciation_option
         , member_rollup_flag
         , allocate_to_fully_rsv_flag
         , allocate_to_fully_ret_flag
         , recognize_gain_loss
         , terminal_gain_loss_amount
         , cip_cost
         , ltd_cost_of_removal
         , eofy_reserve
         , prior_eofy_reserve
         , eop_adj_cost
         , eop_formula_factor
         , exclude_proceeds_from_basis
         , retirement_deprn_option
         , adjusted_recoverable_cost /* fix for bug 3149457 */
         , cash_generating_unit_id
         , extended_deprn_flag          -- Japan Tax Phase3
         , extended_depreciation_period -- Japan Tax Phase3
         , nbv_at_switch
         , prior_deprn_limit_type
         , prior_deprn_limit_amount
         , prior_deprn_limit
         , prior_deprn_method
         , prior_life_in_months
         , prior_basic_rate
         , prior_adjusted_rate
         )
        SELECT book_type_code
             , asset_id
             , date_placed_in_service
             , h_rethdrout
             , h_today
             , null
             , null, deprn_start_date, deprn_method_code
             , life_in_months, p_asset_fin_rec_new.rate_adjustment_factor
             , p_asset_fin_rec_new.adjusted_cost, p_asset_fin_rec_new.cost
             , original_cost
             , p_asset_fin_rec_new.salvage_value
             , null
             , decode(group_asset_id,null,period_counter_fully_reserved,null) --Bug 8425794
             , period_counter_life_complete
             , prorate_convention_code
             , prorate_date
             , itc_amount_id
             , itc_amount, cost_change_flag,
         adjustment_required_status, capitalize_flag,
         null, 'NO', depreciate_flag,
         h_today,
         h_user_id, itc_basis, null,
         period_counter_capitalized, basic_rate, adjusted_rate, bonus_rule,
         ceiling_name, p_asset_fin_rec_new.recoverable_cost,
         p_asset_fin_rec_new.reval_amortization_basis, reval_ceiling,--Bug#7478702
         production_capacity, fully_rsvd_revals_counter,
         idled_flag, unit_of_measure, p_asset_fin_rec_new.unrevalued_cost, adjusted_capacity,
         short_fiscal_year_flag, conversion_date, original_deprn_start_date,
         remaining_life1, remaining_life2,
         old_adjusted_cost, formula_factor,
         annual_deprn_rounding_flag,
         percent_salvage_value, allowed_deprn_limit, p_asset_fin_rec_new.allowed_deprn_limit_amount
         , group_asset_id
         , recapture_reserve_flag
         , salvage_type
         , deprn_limit_type
         , super_group_id
         , reduce_addition_flag
         , reduce_adjustment_flag
         , reduce_retirement_flag
         , ytd_proceeds
         , ltd_proceeds
         , reduction_rate
         , over_depreciate_option
         , limit_proceeds_flag
         , terminal_gain_loss
         , tracking_method
         , exclude_fully_rsv_flag
         , excess_allocation_option
         , depreciation_option
         , member_rollup_flag
         , allocate_to_fully_rsv_flag
         , allocate_to_fully_ret_flag
         , recognize_gain_loss
         , terminal_gain_loss_amount
         , cip_cost
         , ltd_cost_of_removal
         , p_asset_fin_rec_new.eofy_reserve  /* fix for bug 5260926 */
         , prior_eofy_reserve
         , eop_adj_cost
         , eop_formula_factor
         , exclude_proceeds_from_basis
         , retirement_deprn_option
         , p_asset_fin_rec_new.adjusted_recoverable_cost /* fix for bug 3149457 */
         , cash_generating_unit_id
         , extended_deprn_flag          -- Japan Tax Phase3
         , extended_depreciation_period -- Japan Tax Phase3
         , nbv_at_switch
         , prior_deprn_limit_type
         , prior_deprn_limit_amount
         , prior_deprn_limit
         , prior_deprn_method
         , prior_life_in_months
         , prior_basic_rate
         , prior_adjusted_rate
        FROM fa_books
        WHERE asset_id = ret.asset_id
        AND   book_type_code = ret.book
        AND   transaction_header_id_out = h_rethdrout;
    else  -- for reporting
        INSERT into fa_mc_books
        (book_type_Code, asset_id, date_placed_in_service,
         transaction_header_id_in, date_effective, transaction_header_id_out,
         date_ineffective, deprn_start_date, deprn_method_code,
         life_in_months, rate_adjustment_factor, adjusted_cost, cost,
         original_cost, salvage_value, period_counter_fully_retired,
         period_counter_fully_reserved,period_counter_life_complete,
         prorate_convention_code, prorate_date, itc_amount_id,
         itc_amount, cost_change_flag,
         adjustment_required_status,capitalize_flag,
         retirement_id, retirement_pending_flag, depreciate_flag,
         last_update_date,
         last_updated_by, itc_basis, tax_request_id,
         period_counter_capitalized, basic_rate, adjusted_rate, bonus_rule,
         ceiling_name, recoverable_cost,
         reval_amortization_basis, reval_ceiling,
         production_capacity, fully_rsvd_revals_counter,
         idled_flag, unit_of_measure, unrevalued_cost, adjusted_capacity,
         short_fiscal_year_flag, conversion_date, original_deprn_start_date,
         remaining_life1, remaining_life2,
         old_adjusted_cost, formula_factor,
         annual_deprn_rounding_flag,
         percent_salvage_value, allowed_deprn_limit, allowed_deprn_limit_amount
         , group_asset_id
         , recapture_reserve_flag
         , salvage_type
         , deprn_limit_type
         , super_group_id
         , reduce_addition_flag
         , reduce_adjustment_flag
         , reduce_retirement_flag
         , ytd_proceeds
         , ltd_proceeds
         , reduction_rate
         , over_depreciate_option
         , limit_proceeds_flag
         , terminal_gain_loss
         , tracking_method
         , exclude_fully_rsv_flag
         , excess_allocation_option
         , depreciation_option
         , member_rollup_flag
         , allocate_to_fully_rsv_flag
         , allocate_to_fully_ret_flag
         , recognize_gain_loss
         , terminal_gain_loss_amount
         , cip_cost
         , ltd_cost_of_removal
         , eofy_reserve
         , prior_eofy_reserve
         , eop_adj_cost
         , eop_formula_factor
         , exclude_proceeds_from_basis
         , retirement_deprn_option
         , adjusted_recoverable_cost /* fix for bug 3149457 */
         , cash_generating_unit_id
         , set_of_books_id
         )
        SELECT book_type_code, asset_id, date_placed_in_service,
         h_rethdrout, h_today, null,
         null, deprn_start_date, deprn_method_code,
         life_in_months, p_asset_fin_rec_new.rate_adjustment_factor
         , p_asset_fin_rec_new.adjusted_cost, p_asset_fin_rec_new.cost,
         original_cost,
         p_asset_fin_rec_new.salvage_value, null, decode(group_asset_id,null,period_counter_fully_reserved,null) --Bug 8425794
         ,period_counter_life_complete,
         prorate_convention_code, prorate_date, itc_amount_id,
         itc_amount, cost_change_flag,
         adjustment_required_status, capitalize_flag,
         null, 'NO', depreciate_flag,
         h_today,
         h_user_id, itc_basis, null,
         period_counter_capitalized, basic_rate, adjusted_rate, bonus_rule,
         ceiling_name, p_asset_fin_rec_new.recoverable_cost,
         p_asset_fin_rec_new.reval_amortization_basis, reval_ceiling,--Bug#7478702
         production_capacity, fully_rsvd_revals_counter,
         idled_flag, unit_of_measure, unrevalued_cost, adjusted_capacity,
         short_fiscal_year_flag, conversion_date, original_deprn_start_date,
         remaining_life1, remaining_life2,
         old_adjusted_cost, formula_factor,
         annual_deprn_rounding_flag,
         percent_salvage_value, allowed_deprn_limit, p_asset_fin_rec_new.allowed_deprn_limit_amount
         , group_asset_id
         , recapture_reserve_flag
         , salvage_type
         , deprn_limit_type
         , super_group_id
         , reduce_addition_flag
         , reduce_adjustment_flag
         , reduce_retirement_flag
         , ytd_proceeds
         , ltd_proceeds
         , reduction_rate
         , over_depreciate_option
         , limit_proceeds_flag
         , terminal_gain_loss
         , tracking_method
         , exclude_fully_rsv_flag
         , excess_allocation_option
         , depreciation_option
         , member_rollup_flag
         , allocate_to_fully_rsv_flag
         , allocate_to_fully_ret_flag
         , recognize_gain_loss
         , terminal_gain_loss_amount
         , cip_cost
         , ltd_cost_of_removal
         , p_asset_fin_rec_new.eofy_reserve  /* fix for bug 5260926 */
         , prior_eofy_reserve
         , eop_adj_cost
         , eop_formula_factor
         , exclude_proceeds_from_basis
         , retirement_deprn_option
         , p_asset_fin_rec_new.adjusted_recoverable_cost /* fix for bug 3149457 */
         , cash_generating_unit_id
         , set_of_books_id
        FROM fa_mc_books
        WHERE asset_id = ret.asset_id
        AND   book_type_code = ret.book
        AND   set_of_books_id = ret.set_of_books_id
        AND   transaction_header_id_out = h_rethdrout;
    end if;

    if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Fetch DH.TRANSACTION_HEADER_ID_OUT',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 3',
           value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    -- Bug:5930979:Japan Tax Reform Project (Start)
    if fa_cache_pkg.fazccmt_record.GUARANTEE_RATE_METHOD_FLAG = 'YES' then
       if ret.mrc_sob_type_code <> 'R' then
          update fa_books
          set rate_in_use = l_rate_in_use
          where asset_id = ret.asset_id
          and book_type_code = ret.Book
          and transaction_header_id_out is null;

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add(l_calling_fn, 'Updated rate_in_use (P) ', l_rate_in_use);
          end if;

       else -- For Reporting
          -- TO DO -- MRC
          /*update fa_mc_books
          set rate_in_use = l_rate_in_use
          where asset_id = ret.asset_id
          and book_type_code = ret.Book
          and set_of_books_id = ret.set_of_books_id
          and transaction_header_id_out is null;*/

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add(l_calling_fn, 'Updated rate_in_use (R) ', l_rate_in_use);
          end if;
       end if;
    end if;
    -- Bug:5930979:Japan Tax Reform Project (End)

        BEGIN
    SELECT distinct fadh.TRANSACTION_HEADER_ID_OUT,
                    DECODE(fadh.TRANSACTION_HEADER_ID_OUT, null, 0, 1)
        INTO h_dist_hdrout, h_drflag
        FROM FA_DISTRIBUTION_HISTORY fadh
        WHERE fadh.retirement_id = h_ret_id;
    EXCEPTION
        WHEN NO_DATA_FOUND then
          NULL;
    END;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 4',
           value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if (RET.units_retired is null or RET.units_retired <= 0)  then
                        -- must be cost retired

        /**** -- Replaced this with the following
        OPEN TRET;
        OPEN PRET;

        LOOP
            FETCH TRET INTO h_tdistid;
            exit when TRET%notfound or TRET%notfound IS NULL;
            FETCH PRET INTO h_pdistid;
            exit when PRET%notfound or PRET%notfound IS NULL;

            if ret.mrc_sob_type_code <> 'R' then
               UPDATE fa_adjustments aj
                  SET distribution_id = h_tdistid
                WHERE aj.asset_id = h_asset_id
                  AND   aj.book_type_code = h_book
                  AND   aj.distribution_id = h_pdistid
                  AND   aj.transaction_header_id = h_rethdrout;
            else
               UPDATE fa_mc_adjustments aj
                  SET distribution_id = h_tdistid
                WHERE aj.asset_id = h_asset_id
                  AND   aj.book_type_code = h_book
                  AND   aj.distribution_id = h_pdistid
                  AND   aj.set_of_books_id = ret.set_of_books_id
                  AND   aj.transaction_header_id = h_rethdrout;
            end if;


        END LOOP;
        CLOSE PRET;
        CLOSE TRET;
        ***/

        -- Bug 5149832
        OPEN OLD_NEW_DIST;

        LOOP

            FETCH OLD_NEW_DIST INTO
                    h_pdistid,
                    h_tdistid;
            EXIT WHEN OLD_NEW_DIST%NOTFOUND or OLD_NEW_DIST%NOTFOUND IS NULL;

            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add(l_calling_fn, '++ h_pdistid OLD DIST', h_pdistid, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add(l_calling_fn, '++ h_tdistid NEW DIST', h_tdistid, p_log_level_rec => p_log_level_rec);
            end if;

            if ret.mrc_sob_type_code <> 'R' then
               UPDATE fa_adjustments aj
                  SET distribution_id = h_tdistid
                WHERE aj.asset_id = h_asset_id
                  AND   aj.book_type_code = h_book
                  AND   aj.distribution_id = h_pdistid
                  AND   aj.transaction_header_id = h_rethdrout;
            else
               UPDATE fa_mc_adjustments aj
                  SET distribution_id = h_tdistid
                WHERE aj.asset_id = h_asset_id
                  AND   aj.book_type_code = h_book
                  AND   aj.distribution_id = h_pdistid
                  AND   aj.set_of_books_id = ret.set_of_books_id
                  AND   aj.transaction_header_id = h_rethdrout;
            end if;

        END LOOP;

        CLOSE OLD_NEW_DIST;

        return(TRUE);

    else -- RET.units_retired is null or RET.units_retired

        if (h_drflag = 1) then
           -- There is a Header out, must be partialunit retired

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Update FA_DISTRIBUTION_HISTORY',
               value   => '', p_log_level_rec => p_log_level_rec);
          end if;

          -- bugfix for 991646.
          -- When all units of a distribution line or lines in a multi-distributed
          -- asset that are
          -- retired are reinstated, no need to terminate any distribution rows
          -- as in the case
          -- for all other partial retirement case. Hence the following update of
          -- fa_distribution_history is bypassed and it moves on to create new
          -- distribution rows with original units before the retirement

          -- Fix for Bug #1256872.  Select the active distributions
          --   to be terminated. They will be the duplicates of the
          --   retired distributions we are now reinstating.

          if p_log_level_rec.statement_level then
             fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => '+++ Step 4',
               value   => '', p_log_level_rec => p_log_level_rec);
          end if;

          OPEN UPD_DIST;
          upd_ctr := 0;
          LOOP
                FETCH UPD_DIST INTO h_rdistid;
                if (UPD_DIST%NOTFOUND) then
                   if (upd_ctr > 0) then
                                exit;
                   end if;
                   -- Fix for Bug #1256872.  We aren't terminating already
                   -- terminated rows, so we may have no rows to update here.
                   -- Just need to check if we have a least one row to later add
                   --   for the new distribution.  Removing check to see if
                   --   abs(transaction_units) = units_assigned.

                   select count(*)
                   into h_count
                   from fa_distribution_history
                   where transaction_header_id_out = h_dist_hdrout
                   and book_type_code = h_book
                   and asset_id = h_asset_id
                   and retirement_id = h_ret_id;

                   if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 4.1',
                         value   => '', p_log_level_rec => p_log_level_rec);
                   end if;

                   if (h_count > 0) then
                    exit;
                   else
                       raise fagiat_error;
                   end if;
                else

                   if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 4.6',
                         value   => '', p_log_level_rec => p_log_level_rec);
                   end if;

                   -- UPDATING FA_DISTRIBUTION_HISTORY
                   -- if (h_mrc_primary_book_flag = 1) then
                   if (ret.mrc_sob_type_code <> 'R') then
                      UPDATE FA_DISTRIBUTION_HISTORY
                      SET date_ineffective =
                                h_today, -- to_date(h_today,'DD/MM/YYYY hh24:mi:ss'),
                                transaction_header_id_out = h_rethdrout,
                                last_update_date =
                                h_today, -- to_date(h_today,'DD/MM/YYYY hh24:mi:ss'),
                                last_updated_by = h_user_id
                      WHERE distribution_id = h_rdistid;
                   end if;
                   -- END UPDATING FA_DISTRIBUTION_HISTORY
                   upd_ctr := upd_ctr + 1;

                   if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 4.7',
                         value   => '', p_log_level_rec => p_log_level_rec);
                   end if;

                end if;
          END LOOP;
          CLOSE UPD_DIST;

          if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 5',
                         value   => '', p_log_level_rec => p_log_level_rec);
          end if;

          -- UPDATING FA_ASSET_HISTORY,
          --        INSERTING FA_ASSET_HISTORY,
          --        UPDATING FA_ADDITIONS
          -- if (h_mrc_primary_book_flag = 1) then
          if (ret.mrc_sob_type_code <> 'R') then

                if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 5.1',
                         value   => '', p_log_level_rec => p_log_level_rec);
                end if;

                -- select rowidtochar(rowid)
                select rowid
                     into    h_rowid
                     from    fa_asset_history
                     where   asset_id = RET.asset_id
                     and     date_ineffective is null;

                if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 5.1.5',
                         value   => '', p_log_level_rec => p_log_level_rec);
                end if;

                update fa_asset_history
                     set date_ineffective = today,
                         transaction_header_id_out = h_rethdrout
                where rowid = h_rowid;

                if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 5.2',
                         value   => '', p_log_level_rec => p_log_level_rec);
                end if;

                insert into fa_asset_history
                  (asset_id, category_id, units, asset_type,
                  date_effective, date_ineffective, last_update_date,
                  last_updated_by,transaction_header_id_in
                  )
                select asset_id, category_id, units + RET.units_retired,
                        asset_type, today,
                        null, today,
                        user_id, h_rethdrout
                from fa_asset_history
                where rowid = h_rowid;

                if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 5.3',
                         value   => '', p_log_level_rec => p_log_level_rec);
                end if;

                -- CHECK: Had to change the table name to fa_additions_B table.
                -- because updating fa_additions.current_units caused
                -- ORA-01779: cannot modify a column which maps to
                -- a non key-preserved table error

                update fa_additions_B
                   set current_units = current_units + h_units_retired
                where asset_id = RET.asset_id;

                if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 5.4',
                         value   => '', p_log_level_rec => p_log_level_rec);
                end if;

          end if;
          -- END UPDATING FA_ASSET_HISTORY,
          -- END INSERTING FA_ASSET_HISTORY,
          --  END UPDATING FA_ADDITIONS

          if p_log_level_rec.statement_level then
                      fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => '+++ Step 6',
                         value   => '', p_log_level_rec => p_log_level_rec);
          end if;


        else  -- Must be full retirement else for if There is a Header out

           if p_log_level_rec.statement_level then
             fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Update FA_DISTRIBUTION_HISTORY (FULL RETIREMENT)',
               value   => '');
           end if;

           -- UPDATING FA_DISTRIBUTION_HISTORY
           --if (h_mrc_primary_book_flag = 1) then
           if (ret.mrc_sob_type_code <> 'R') then
               UPDATE FA_DISTRIBUTION_HISTORY
                SET date_ineffective =
                    today,
                    transaction_header_id_out = h_rethdrout,
                    last_update_date =
                        today,
                    last_updated_by = h_user_id
                WHERE retirement_id = h_ret_id
                AND book_type_code = h_book
                AND asset_id = h_asset_id;
           end if;
        end if; -- if h_drflag = 1

        if p_log_level_rec.statement_level then
             fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Update FA_DISTRIBUTION_HISTORY (new)',
               value   => '');
        end if;

        -- Fix for Bug #1256872.  Select the active distributions
        --   were just terminated. They will be the duplicates of the
        --   retired distributions we are now reinstating.   If no active
        --   distributions were terminated, we will need to reinstate
        --   those units retired for the inactive distributions of the
        --   original retirement.  The second part of the UNION selects
        --   these distributions that no longer are active.

        OPEN CRET;
        LOOP
            FETCH CRET INTO h_rdistid, h_units_assigned;
            exit when CRET%notfound or CRET%notfound IS NULL;

            BEGIN
                Select FA_DISTRIBUTION_HISTORY_s.nextval
                into new_distid
                from dual;
            EXCEPTION
                when others then
                  return(false);
            END;

            h_new_distid := new_distid;

            --fix for 1722165 - changed to afnumber to handle fractional units
            -- h_units_retired = 0;
            h_units_retired := 0;

            -- Fix for Bug #1256872.  Find the units retired for this
            -- distribution
            -- if any existed. We need to make sure that we are not selecting
            -- the same distribution that we got the units_assigned from or
            -- we will be double-counting the number of units.

            BEGIN
                SELECT 0 - nvl (ret.transaction_units, 0)
                INTO h_units_retired
                FROM   fa_distribution_history ret
                WHERE  ret.book_type_code = h_book
                AND    ret.asset_id = h_asset_id
                AND    ret.retirement_id = h_ret_id
                AND    exists
                (
                 SELECT 'x'
                 FROM   fa_distribution_history dh
                 WHERE  dh.book_type_code = h_book
                 AND    dh.asset_id = h_asset_id
                 AND    dh.distribution_id = h_rdistid
                 AND    dh.distribution_id <> ret.distribution_id
                 AND    ret.code_combination_id = dh.code_combination_id
                 AND    ret.location_id = dh.location_id
                 AND    nvl (ret.assigned_to, -99) = nvl (dh.assigned_to, -99)
                );
            EXCEPTION
                WHEN NO_DATA_FOUND then
                    NULL;
            END;

            -- INSERTING FA_DISTRIBUTION_HISTORY
            --if (h_mrc_primary_book_flag = 1) then
            if (ret.mrc_sob_type_code <> 'R') then
                INSERT INTO FA_DISTRIBUTION_HISTORY
                        (distribution_id, book_type_code, asset_id,
                        units_assigned, date_effective, date_ineffective,
                         code_Combination_id,
                        location_id, assigned_to, transaction_header_id_in,
                        transaction_header_id_out, transaction_units,
                        retirement_id, last_update_date, last_updated_by)
                SELECT new_distid, book_type_code, asset_id,
                        nvl(h_units_assigned,0) + nvl(h_units_retired,0), today,
                        null, code_Combination_id,
                        location_id, assigned_to, h_rethdrout,
                        null, null, null, today,
                        user_id
                FROM FA_DISTRIBUTION_HISTORY
                WHERE distribution_id = h_rdistid;

            end if;

            -- Update FA_ADJUSTMENTS so that it contain the new distribution
            -- id instead of the old one. Reserve Ledger needs this new id

            -- Fix for Bug #1256872.The distributions we want to change are the
            -- distributions from original retirement and may not be those that
            -- were   just terminated

            -- if (h_mrc_primary_book_flag = 1) then
            if (ret.mrc_sob_type_code <> 'R') then

                    UPDATE FA_ADJUSTMENTS
                    SET DISTRIBUTION_ID = new_distid

                    WHERE TRANSACTION_HEADER_ID = h_rethdrout
                    AND DISTRIBUTION_ID =
                    (
                     SELECT DISTINCT r.distribution_id
                     FROM   fa_distribution_history r
                     WHERE  r.book_type_code = h_book
                     AND    r.asset_id = h_asset_id
                     AND    r.retirement_id = h_ret_id
                     AND    exists
                    (
                      SELECT 'x'
                      FROM   fa_distribution_history d
                      WHERE  d.book_type_code = h_book
                      AND    d.asset_id = h_asset_id
                      AND    d.distribution_id = h_rdistid
                      AND    r.code_combination_id = d.code_combination_id
                      AND    r.location_id = d.location_id
                      AND    nvl (r.assigned_to, -99) = nvl (d.assigned_to, -99)
                     )
                    );
            else
                -- CHECK: Fix for 1422427.For reporting book,we cannot use h_new_distid
                -- b/c we need to use the new distid already created by the
                -- primary book.

                /* BUG# 2775057 - added rdistid to the first subselect as well as
                * assets with multiple disitributions were causing ora-1722
                */

                DECLARE
                /* Bug 3116047 - Broke the single update statement and created
                   this cursor enclosing with the DECLARE/BEGIN/END.
                   As a result of the High Cost SQL exercise  msiddiqu */

                  /* Bug 4890085: Modified cursor C1 as it was not returning any rows.
                  The conditions "o.retirement_id = h_ret_id" and
                  "o.distribution_id = h_rdistid" were contradicting so splitted them. */

                  Cursor C1 is
                  SELECT DISTINCT n.distribution_id
                   FROM   fa_distribution_history n
                   WHERE  n.book_type_code = h_book
                   AND    n.asset_id = h_asset_id
                   AND    n.date_ineffective is null
                   AND    exists
                   (
                     SELECT 'x'
                     FROM   fa_distribution_history o
                     WHERE  o.book_type_code = h_book
                     AND    o.asset_id = h_asset_id
                     --AND    o.retirement_id = h_ret_id
                     AND    o.distribution_id = h_rdistid -- added for bug 2775057
                     AND    n.code_combination_id = o.code_combination_id
                     AND    n.location_id = o.location_id
                     AND    nvl (n.assigned_to, -99) = nvl (o.assigned_to, -99)
                   )
                   AND    exists
                   (
                     SELECT 'x'
                     FROM   fa_distribution_history o
                     WHERE  o.book_type_code = h_book
                     AND    o.asset_id = h_asset_id
                     AND    o.retirement_id = h_ret_id
                     --AND    o.distribution_id = h_rdistid -- added for bug 2775057
                     AND    n.code_combination_id = o.code_combination_id
                     AND    n.location_id = o.location_id
                     AND    nvl (n.assigned_to, -99) = nvl (o.assigned_to, -99)
                   );

                BEGIN

                  For C1_rec in C1 Loop

                  -- Fix for Bug #3678791.  Break previous update statement
                  -- into multiple smaller statements.
                  SELECT DISTINCT r.distribution_id
                  INTO   l_temp_dist_id1
                  FROM   fa_distribution_history r
                  WHERE  r.book_type_code = h_book
                  AND    r.asset_id = h_asset_id
                  AND    r.retirement_id = h_ret_id
                  AND    exists
                  (
                    SELECT 'x'
                    FROM   fa_distribution_history d
                    WHERE  d.book_type_code = h_book
                    AND    d.asset_id = h_asset_id
                    AND    d.distribution_id = h_rdistid
                    AND    r.code_combination_id = d.code_combination_id
                    AND    r.location_id = d.location_id
                    AND    nvl (r.assigned_to, -99) = nvl (d.assigned_to, -99)
                  );

                    -- CHECK: this was fa_adjustments table before which i think was wrong
                    UPDATE FA_MC_ADJUSTMENTS
                    SET DISTRIBUTION_ID = C1_rec.distribution_id
                    WHERE TRANSACTION_HEADER_ID = h_rethdrout
                    AND   book_type_code = h_book /* Added for bug 7659930*/
                    AND   DISTRIBUTION_ID = l_temp_dist_id1
                    AND   set_of_books_id = ret.set_of_books_id;

                   End Loop;
                 END;
            end if;

            /* Bug2447411 h_drflag has to be compared w/ 0 according to Pro*C */
            -- if (h_drflag = 1) then -- if fully retired
            if (h_drflag = 0) then -- if fully retired
               BEGIN
                  select d1.distribution_id
                  into h_adj_distid
                  from fa_distribution_history d1,
                       fa_distribution_history d2
                  where d2.book_type_code = h_book
                  and   d2.asset_id = h_asset_id
                  and   d1.book_type_code = d2.book_type_code
                  and   d1.asset_id = d2.asset_id
                  and   d1.transaction_header_id_in =
                                      d2.transaction_header_id_out
                  and   d1.code_combination_id = d2.code_combination_id
                  and   d1.location_id = d2.location_id
                  and   nvl(d1.assigned_to, -99) = nvl(d2.assigned_to, -99)
                  and   d2.distribution_id = h_rdistid;
               EXCEPTION
                  WHEN NO_DATA_FOUND then
                     NULL;
               END;

            else
                -- Fix for Bug #1256872.  Need to find active distribution if
                --   terminated distribution was transferred.
                h_adj_distid := h_rdistid;
                OPEN CHG_DIST;
                LOOP
                   FETCH CHG_DIST INTO h_temp_distid;
                   EXIT WHEN CHG_DIST%NOTFOUND;
                   h_adj_distid :=  h_temp_distid;
                END LOOP;
                CLOSE CHG_DIST;
            end if;


            -- Fix for Bug #1256872.  Also need to make sure that rows in
            --   fa_adjustments to balance the initial retirement come from
            --   the distribution that was just terminated and not the new
            --   distribution created from the initial retirement

            if (ret.mrc_sob_type_code <> 'R') then

                UPDATE FA_ADJUSTMENTS
                SET DISTRIBUTION_ID = h_adj_distid
                WHERE TRANSACTION_HEADER_ID = h_rethdrout
                AND   DISTRIBUTION_ID <> h_adj_distid
                AND   DISTRIBUTION_ID =
                (
                 SELECT DISTINCT r.distribution_id
                 FROM   fa_distribution_history r
                 WHERE  r.book_type_code = h_book
                 AND    r.asset_id = h_asset_id
                 AND    r.transaction_header_id_in =
                 (
                  SELECT DISTINCT transaction_header_id_out
                  FROM   fa_distribution_history
                  WHERE  book_type_code = h_book
                  AND    asset_id = h_asset_id
                  AND    retirement_id = h_ret_id
                 )
                 AND    exists
                 (
                   SELECT 'x'
                   FROM   fa_distribution_history d
                   WHERE  d.book_type_code = h_book
                   AND    d.asset_id = h_asset_id
                   AND    d.distribution_id = h_rdistid
                   AND    r.code_combination_id = d.code_combination_id
                   AND    r.location_id = d.location_id
                   AND    nvl (r.assigned_to, -99) = nvl (d.assigned_to, -99)
                 )
                )
                AND not exists
                (
                 SELECT 'x'
                 FROM   fa_distribution_history
                 WHERE  book_type_code = h_book
                 AND    asset_id = h_asset_id
                 AND    retirement_id = h_ret_id
                 AND    distribution_id = h_adj_distid
                );

            else

                UPDATE FA_MC_ADJUSTMENTS
                SET DISTRIBUTION_ID = h_adj_distid
                WHERE TRANSACTION_HEADER_ID = h_rethdrout
                AND   DISTRIBUTION_ID <> h_adj_distid
                AND   SET_OF_BOOKS_ID = ret.set_of_books_id
                AND   DISTRIBUTION_ID =
                (
                 SELECT DISTINCT r.distribution_id
                 FROM   fa_distribution_history r
                 WHERE  r.book_type_code = h_book
                 AND    r.asset_id = h_asset_id
                 AND    r.transaction_header_id_in =
                 (
                  SELECT DISTINCT transaction_header_id_out
                  FROM   fa_distribution_history
                  WHERE  book_type_code = h_book
                  AND    asset_id = h_asset_id
                  AND    retirement_id = h_ret_id
                 )
                 AND    exists
                 (
                   SELECT 'x'
                   FROM   fa_distribution_history d
                   WHERE  d.book_type_code = h_book
                   AND    d.asset_id = h_asset_id
                   AND    d.distribution_id = h_rdistid
                   AND    r.code_combination_id = d.code_combination_id
                   AND    r.location_id = d.location_id
                   AND    nvl (r.assigned_to, -99) = nvl (d.assigned_to, -99)
                 )
                )
                AND not exists
                (
                 SELECT 'x'
                 FROM   fa_distribution_history
                 WHERE  book_type_code = h_book
                 AND    asset_id = h_asset_id
                 AND    retirement_id = h_ret_id
                 AND    distribution_id = h_adj_distid
                );

            end if;

        END LOOP;   -- end of CRET LOOP
        CLOSE CRET;
    end if;
    return(true);

 EXCEPTION

    when fagiat_error then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

    when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;


 END;  -- fagiat

/*============================================================================
| NAME        fagict
|
| FUNCTION    debit the cost account by the same amount we took back then.
|
| History   Jacob John          1/29/97         Created
|
|===========================================================================*/


Function FAGICT(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        cpd_ctr IN NUMBER,
        today IN DATE,
        user_id IN NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

      dr_cr   varchar2(3);
      adj_row  fa_adjust_type_pkg.fa_adj_row_struct;

      h_retirement_id number;
      h_asset_id      number;
      h_user_id       number;
      h_today         date;
      h_th_id_out     NUMBER;
      h_dr_cr         varchar2(3);
      h_adj_type      varchar2(16);
      h_dist_id       NUMBER;
      h_ccid          NUMBER;
      h_cost          NUMBER;
      h_wip_asset     integer;
      h_ret_dist_id   number;
      h_trx_units     number;
      FAGICT_ERROR    EXCEPTION;


      /* Added following cursor for bug 7396397
      */
      cursor c_adj is
      SELECT  fadh.distribution_id,
              fadh.code_combination_id,
              fadh.location_id,
              nvl(fadh.assigned_to,-99) assigned_to,
              'N' retire_rec_found,
              0 cost,
              0 DEPRN_RSV,
              0 REVAL_RSV,
              0 BONUS_DEPRN_RSV,
              0 IMPAIRMENT_RSV,
              0 new_units,
              fadh.code_combination_id adj_ccid
      FROM  fa_distribution_history fadh
      WHERE fadh.asset_id = RET.asset_id
      AND   fadh.date_ineffective is null
      AND   fadh.transaction_units is null
      order by distribution_id;

      --Bug#8810791 - Modified to fetch adjustment type from fa_adjustments
      cursor c_ret is
      SELECT  min(fadh.distribution_id) distribution_id,
              faadj.transaction_header_id,
              fadh.code_combination_id,
              fadh.location_id,
              nvl(fadh.assigned_to,-99) assigned_to,
              faadj.adjustment_type,
              decode(sign(sum(decode(faadj.debit_credit_flag,'DR',faadj.adjustment_amount,
                          -1*faadj.adjustment_amount))),-1,'CR','DR') debit_credit_flag,
              abs(sum(decode(faadj.debit_credit_flag,'DR',faadj.adjustment_amount,-1*faadj.adjustment_amount)))
                 adjustment_amount,
              'N' adj_rec_found,
              faadj.code_combination_id adj_ccid
      FROM    fa_adjustments faadj, fa_distribution_history fadh
      where   fadh.asset_id = RET.asset_id
      AND     faadj.book_type_code = BK.dis_book
      AND     faadj.asset_id = RET.asset_id
      and     fadh.distribution_id = faadj.distribution_id
      and     faadj.transaction_header_id = ret.th_id_in
      AND     faadj.source_type_code = decode(RET.wip_asset, 1,
                                            'CIP RETIREMENT','RETIREMENT')
      AND   faadj.adjustment_type in ('COST', 'CIP COST')
      group   by
              faadj.transaction_header_id,
              fadh.code_combination_id,
              fadh.location_id,
              nvl(fadh.assigned_to,-99),
              faadj.adjustment_type,
              'N',
              faadj.code_combination_id
       order by 1,2;

    cursor c_cost_ret is
    select ret.adjustment_type,
           abs(adjustment_amount) adjustment_amount,
           decode(sign(adjustment_amount),1,'DR','CR') debit_credit_flag,
           decode(sign(adjustment_amount),1,'CR','DR') rev_debit_credit_flag,
           ret.adj_ccid
    from
      (
      select adjustment_type,
             sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount )) adjustment_amount,
             faadj.code_combination_id adj_ccid
      from   fa_adjustments faadj
      where faadj.asset_id = RET.asset_id
      and   faadj.transaction_header_id =  ret.th_id_in
      and   faadj.book_type_code = ret.book
      and   faadj.adjustment_type in ('COST', 'CIP COST')
      and   faadj.source_type_code = decode(RET.wip_asset, 1,
                                          'CIP RETIREMENT','RETIREMENT')
      group by adjustment_type, faadj.code_combination_id
      ) ret
      where ret.adjustment_amount <> 0;

      cursor c_ret_mrc IS
      SELECT  min(fadh.distribution_id) distribution_id,
              faadj.transaction_header_id,
              fadh.code_combination_id,
              fadh.location_id,
              nvl(fadh.assigned_to,-99) assigned_to,
              faadj.adjustment_type,
              decode(sign(sum(decode(faadj.debit_credit_flag,'DR',faadj.adjustment_amount,
                          -1*faadj.adjustment_amount))),-1,'CR','DR') debit_credit_flag,
              abs(sum(decode(faadj.debit_credit_flag,'DR',faadj.adjustment_amount,-1*faadj.adjustment_amount)))
                 adjustment_amount,
              'N' adj_rec_found,
              faadj.code_combination_id adj_ccid
      FROM    fa_mc_adjustments faadj, fa_distribution_history fadh
      where   fadh.asset_id = RET.asset_id
      AND     faadj.book_type_code = BK.dis_book
      AND     faadj.asset_id = RET.asset_id
      and     fadh.distribution_id = faadj.distribution_id
      and     faadj.transaction_header_id = ret.th_id_in
      and     faadj.set_of_books_id = ret.set_of_books_id
      AND     faadj.source_type_code = decode(RET.wip_asset, 1,
                                            'CIP RETIREMENT','RETIREMENT')
      AND   faadj.adjustment_type in ('COST', 'CIP COST')
      group   by
              faadj.transaction_header_id,
              fadh.code_combination_id,
              fadh.location_id,
              nvl(fadh.assigned_to,-99),
              faadj.adjustment_type,
              'N',
              faadj.code_combination_id
      order by 1,2;

      cursor c_cost_ret_mrc is
      select ret.adjustment_type,
             abs(adjustment_amount) adjustment_amount,
             decode(sign(adjustment_amount),1,'DR','CR') debit_credit_flag,
             decode(sign(adjustment_amount),1,'CR','DR') rev_debit_credit_flag,
             ret.adj_ccid
      from
        (
        select adjustment_type,
               sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount )) adjustment_amount,
        faadj.code_combination_id adj_ccid
        from  fa_mc_adjustments faadj
        where faadj.asset_id = RET.asset_id
        and   faadj.transaction_header_id =  ret.th_id_in
        and   faadj.book_type_code = ret.book
        and   faadj.set_of_books_id = ret.set_of_books_id
        and   faadj.adjustment_type in ('COST', 'CIP COST')
        and   faadj.source_type_code = decode(RET.wip_asset, 1,
                                            'CIP RETIREMENT','RETIREMENT')
        group by adjustment_type, faadj.code_combination_id
        ) ret
        where ret.adjustment_amount <> 0;


      --l_tbl_adj tbl_adj;
      l_tbl_ret tbl_ret;
      l_tbl_cost_ret tbl_cost_ret;
      l_tbl_adj_final tbl_final_adj;

    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;
    h_temp number;
    l_adj_type    VARCHAR2(15); --Bug#8810791

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagict';

  BEGIN <<FAGICT>>

    h_cost := 0;
    h_today := today;
    h_retirement_id := ret.retirement_id;
    h_asset_id := ret.asset_id;
    h_user_id := user_id;
    h_wip_asset := ret.wip_asset;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Get thid_out from fa_rets',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    select  transaction_header_id_out
    into    h_th_id_out
    from    fa_retirements
    where   retirement_id = h_retirement_id;

    /* Bug 843625 fix  */
    if RET.wip_asset > 0 then
        l_adj_type := 'CIP COST'; --Bug#8810791
        adj_row.source_type_code := 'CIP RETIREMENT';
    else
        l_adj_type := 'COST';
        adj_row.source_type_code := 'RETIREMENT';
    end if;

    adj_row.transaction_header_id := h_th_id_out;
    adj_row.asset_invoice_id :=  0;
    adj_row.book_type_code  :=  RET.book;
    adj_row.period_counter_created := cpd_ctr;
    adj_row.asset_id := RET.asset_id;
    adj_row.period_counter_adjusted := cpd_ctr;
    adj_row.last_update_date := today;
    adj_row.account := NULL;
    adj_row.account_type := NULL;
    adj_row.current_units := bk.cur_units;
    adj_row.selection_mode := fa_std_types.FA_AJ_SINGLE;
    adj_row.selection_thid := 0;
    adj_row.selection_retid := 0;
    adj_row.flush_adj_flag := TRUE;
    adj_row.gen_ccid_flag := FALSE;
    adj_row.annualized_adjustment := 0;
    adj_row.units_retired := 0;
    adj_row.leveling_flag := TRUE;

    if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Populate PL-SQL tables',
               value   => '', p_log_level_rec => p_log_level_rec);
    end if;
    /* Populate table only for unit retirements */
    if (nvl(ret.units_retired,0) > 0 ) then

      if (ret.mrc_sob_type_code <> 'R') then

        g_tbl_adj_cost.delete;
        open c_adj;
        fetch c_adj BULK COLLECT into g_tbl_adj_cost;
        close c_adj;

        open c_ret;
        fetch c_ret BULK COLLECT into l_tbl_ret;
        close c_ret;
      else

        open c_ret_mrc;
        fetch c_ret_mrc BULK COLLECT into l_tbl_ret;
        close c_ret_mrc;
      end if;

    else
      if (ret.mrc_sob_type_code <> 'R') then
        open c_cost_ret;
        fetch c_cost_ret BULK COLLECT into l_tbl_cost_ret;
        close c_cost_ret;
      else
        open c_cost_ret_mrc;
        fetch c_cost_ret_mrc BULK COLLECT into l_tbl_cost_ret;
        close c_cost_ret_mrc;
      end if;
    end if;

    if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Calling process_adj_table',
               value   => '', p_log_level_rec => p_log_level_rec);
    end if;
    --Bug#8810791 - Passed l_adj_type as p_mode.
    if not process_adj_table(p_mode => l_adj_type,RET => ret,BK => bk,
                             p_tbl_adj => g_tbl_adj_cost, p_tbl_ret => l_tbl_ret,
                             p_tbl_cost_ret => l_tbl_cost_ret,
                             p_tbl_adj_final => l_tbl_adj_final,
                             p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;
    end if ;

    if p_log_level_rec.statement_level then
            fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'process_adj_table done',
               value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    for l in 1..l_tbl_adj_final.count
    LOOP

          h_dist_id := l_tbl_adj_final(l).dist_id;
          h_ccid := l_tbl_adj_final(l).ccid;
          h_adj_type := l_tbl_adj_final(l).adj_type;
          h_dr_cr := l_tbl_adj_final(l).dr_cr;
          h_cost := l_tbl_adj_final(l).cost;

        adj_row.code_combination_id := h_ccid;
        adj_row.adjustment_amount  :=  h_cost;
        adj_row.distribution_id := h_dist_id;
        adj_row.debit_credit_flag :=  h_dr_cr;
        adj_row.adjustment_type := h_adj_type; -- Added. YYOON
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

    END LOOP;

    return(TRUE);

  EXCEPTION

     when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

 END; -- fagict

/*==========================================================================*
| NAME        fagiav                                                        |
|                                                                           |
| FUNCTION    Adjust the reserve that we took at retirement. That is, we    |
|             credit the debit amount we took back then.                    |
|
| History   Jacob John          1/29/97         Created
|                                                                           |
|===========================================================================*/

FUNCTION FAGIAV(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        cpd_ctr  IN number,
        today IN DATE,
        user_id  IN NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

        adj_row  fa_adjust_type_pkg.fa_adj_row_struct ;
        dpr_row  fa_std_types.fa_deprn_row_struct;

        h_retirement_id         number;
        h_asset_id              number;
        h_user_id               number;
        h_today                 date;
        h_th_id_out             NUMBER;
        h_dr_cr                 VARCHAR2(3);
        h_adj_type              VARCHAR2(16);
        h_book                  varchar2(30);
        h_dist_id               NUMBER;
        h_ccid                  NUMBER;
        h_old_ccid              number;
        h_new_ccid              number;
        h_old_dist_id           number;
        h_new_dist_id           number;
        h_reval_rsv             number;
        h_reserve               number;
        h_bonus_reserve         number;
        h_impairment_reserve    number;
        h_category_id           number;

        FAGIAV_ERROR            EXCEPTION;

        X_LAST_UPDATE_DATE date := sysdate;
        X_last_updated_by number := -1;
        X_last_update_login number := -1;
        h_success               boolean;
        h_temp                  number;
        l_group_thid        number(15);

        CURSOR c_get_group_thid IS
        SELECT transaction_header_id
        FROM   fa_transaction_headers
        WHERE  member_transaction_header_id = ret.th_id_in
        AND    asset_id = bk.group_asset_id
        AND    book_type_code = ret.book;


        CURSOR DEPRN IS
        SELECT     dh_old.distribution_id,
            dh_new.distribution_id,
            dh_old.code_combination_id,
            dh_new.code_combination_id
        FROM fa_distribution_history dh_old,
             fa_distribution_history dh_new
        WHERE
        dh_old.retirement_id = h_retirement_id and
        dh_old.book_type_code = RET.book and
        dh_old.units_assigned + dh_old.transaction_units <> 0
        AND
        dh_new.transaction_header_id_in=
            dh_old.transaction_header_id_out and
        dh_new.location_id = dh_old.location_id and
        nvl(dh_new.assigned_to,-99) = nvl(dh_old.assigned_to,-99) and
        dh_new.code_combination_id = dh_old.code_combination_id;


       /* Bug 7396397 starts */

        cursor c_adj is
        SELECT  fadh.distribution_id,
                fadh.code_combination_id,
                fadh.location_id,
                nvl(fadh.assigned_to,-99) assigned_to,
                'N' retire_rec_found,
                0 cost,
                0 DEPRN_RSV,
                0 REVAL_RSV,
                0 BONUS_DEPRN_RSV,
                0 IMPAIRMENT_RSV,
                0 new_units,
                fadh.code_combination_id adj_ccid
        FROM  fa_distribution_history fadh
        WHERE fadh.asset_id = RET.asset_id
        AND   fadh.date_ineffective is null
        AND   fadh.transaction_units is null
        order by distribution_id;

        cursor c_adj_mrc is
        SELECT  fadh.distribution_id,
                fadh.code_combination_id,
                fadh.location_id,
                nvl(fadh.assigned_to,-99) assigned_to,
                'N' retire_rec_found,
                0 cost,
                0 DEPRN_RSV,
                0 REVAL_RSV,
                0 BONUS_DEPRN_RSV,
                0 IMPAIRMENT_RSV,
                0 new_units,
                fadh.code_combination_id adj_ccid
        FROM  fa_distribution_history fadh
        WHERE fadh.asset_id = RET.asset_id
        AND fadh.TRANSACTION_HEADER_ID_OUT
          = (select rt.transaction_header_id_out
             from   fa_retirements rt
             where  rt.retirement_id = RET.retirement_id
            )
        order by distribution_id;

        cursor c_ret is
        SELECT  min(fadh.distribution_id) distribution_id,
                faadj.transaction_header_id,
                fadh.code_combination_id,
                fadh.location_id,
                nvl(fadh.assigned_to,-99) assigned_to,
                faadj.adjustment_type,
                decode(sign(sum(decode(faadj.debit_credit_flag,'DR',faadj.adjustment_amount,
                            -1*faadj.adjustment_amount))),-1,'CR','DR') debit_credit_flag,
                abs(sum(decode(faadj.debit_credit_flag,'DR',faadj.adjustment_amount,-1*faadj.adjustment_amount)))
                   adjustment_amount,
                'N' adj_rec_found,
                faadj.code_combination_id adj_ccid
        FROM    fa_adjustments faadj, fa_distribution_history fadh
        where   fadh.asset_id = RET.asset_id
        AND     faadj.book_type_code = BK.dis_book
        AND     faadj.asset_id = RET.asset_id
        and     fadh.distribution_id = faadj.distribution_id
        and     faadj.transaction_header_id = ret.th_id_in
        and     faadj.adjustment_type in ('RESERVE', 'BONUS RESERVE', 'REVAL RESERVE', 'IMPAIR RESERVE')
        group   by
                faadj.transaction_header_id,
                fadh.code_combination_id,
                fadh.location_id,
                nvl(fadh.assigned_to,-99),
                faadj.adjustment_type,
                'N',
                faadj.code_combination_id
        order by 1,2;


        cursor c_cost_ret is
        select cost_ret.adjustment_type,
               abs(cost_ret.adjustment_amount) adjustment_amount,
               decode(sign(cost_ret.adjustment_amount),1,'DR','CR') debit_credit_flag,
               decode(sign(cost_ret.adjustment_amount),1,'CR','DR') rev_debit_credit_flag,
               cost_ret.adj_ccid
        from
          (
          select adjustment_type,
                 sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount )) adjustment_amount,
                 faadj.code_combination_id adj_ccid
          from   fa_adjustments faadj
          where ( (faadj.transaction_header_id = ret.th_id_in AND faadj.asset_id = h_asset_id)
                )
          and   faadj.book_type_code = ret.book
          and   faadj.adjustment_type in ('RESERVE', 'BONUS RESERVE', 'REVAL RESERVE', 'IMPAIR RESERVE')
          group by adjustment_type, faadj.code_combination_id
          ) cost_ret
          where cost_ret.adjustment_amount <> 0;


        cursor c_cost_ret_grp is
        select cost_ret.adjustment_type,
               abs(cost_ret.adjustment_amount) adjustment_amount,
               decode(sign(cost_ret.adjustment_amount),1,'DR','CR') debit_credit_flag,
               decode(sign(cost_ret.adjustment_amount),1,'CR','DR') rev_debit_credit_flag,
               cost_ret.adj_ccid
        from
          (
          select adjustment_type,
                 sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount )) adjustment_amount,
                 faadj.code_combination_id adj_ccid
          from   fa_adjustments faadj
          where (
                  (faadj.transaction_header_id = l_group_thid AND faadj.asset_id = bk.group_asset_id)
                )
          and   faadj.book_type_code = ret.book
          and   faadj.adjustment_type in ('RESERVE', 'BONUS RESERVE', 'REVAL RESERVE', 'IMPAIR RESERVE')
          group by adjustment_type, faadj.code_combination_id
          ) cost_ret
          where cost_ret.adjustment_amount <> 0;

          cursor c_ret_mrc IS
          SELECT  min(fadh.distribution_id) distribution_id,
                  faadj.transaction_header_id,
                  fadh.code_combination_id,
                  fadh.location_id,
                  nvl(fadh.assigned_to,-99) assigned_to,
                  faadj.adjustment_type,
                  decode(sign(sum(decode(faadj.debit_credit_flag,'DR',faadj.adjustment_amount,
                              -1*faadj.adjustment_amount))),-1,'CR','DR') debit_credit_flag,
                  abs(sum(decode(faadj.debit_credit_flag,'DR',faadj.adjustment_amount,-1*faadj.adjustment_amount)))
                     adjustment_amount,
                  'N' adj_rec_found,
                  faadj.code_combination_id adj_ccid
          FROM    fa_mc_adjustments faadj, fa_distribution_history fadh
          where   fadh.asset_id = RET.asset_id
          AND     faadj.book_type_code = BK.dis_book
          AND     faadj.asset_id = RET.asset_id
          and     fadh.distribution_id = faadj.distribution_id
          and     faadj.transaction_header_id = ret.th_id_in
          and     faadj.set_of_books_id = ret.set_of_books_id
          and     faadj.adjustment_type in ('RESERVE', 'BONUS RESERVE', 'REVAL RESERVE', 'IMPAIR RESERVE')
          group   by
                  faadj.transaction_header_id,
                  fadh.code_combination_id,
                  fadh.location_id,
                  nvl(fadh.assigned_to,-99),
                  faadj.adjustment_type,
                  'N',
                  faadj.code_combination_id
          order by 1,2;

        cursor c_cost_ret_mrc is
        select cost_ret.adjustment_type,
               abs(cost_ret.adjustment_amount) adjustment_amount,
               decode(sign(cost_ret.adjustment_amount),1,'DR','CR') debit_credit_flag,
               decode(sign(cost_ret.adjustment_amount),1,'CR','DR') rev_debit_credit_flag,
               cost_ret.adj_ccid
        from
          (
          select adjustment_type,
                 sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount )) adjustment_amount,
                 faadj.code_combination_id adj_ccid
          from   fa_mc_adjustments faadj
          where ( (faadj.transaction_header_id = ret.th_id_in AND faadj.asset_id = h_asset_id)
                )
          and   faadj.book_type_code = ret.book
          and   faadj.set_of_books_id = ret.set_of_books_id
          and   faadj.adjustment_type in ('RESERVE', 'BONUS RESERVE', 'REVAL RESERVE', 'IMPAIR RESERVE')
          group by faadj.adjustment_type, faadj.code_combination_id
          ) cost_ret
          where cost_ret.adjustment_amount <> 0;

        cursor c_cost_ret_grp_mrc is
        select cost_ret.adjustment_type,
               abs(cost_ret.adjustment_amount) adjustment_amount,
               decode(sign(cost_ret.adjustment_amount),1,'DR','CR') debit_credit_flag,
               decode(sign(cost_ret.adjustment_amount),1,'CR','DR') rev_debit_credit_flag,
               cost_ret.adj_ccid
        from
          (
          select adjustment_type,
                 sum(decode(debit_credit_flag,'DR',adjustment_amount,-1*adjustment_amount )) adjustment_amount,
                 faadj.code_combination_id adj_ccid
          from   fa_mc_adjustments faadj
          where (
                  (faadj.transaction_header_id = l_group_thid AND faadj.asset_id = bk.group_asset_id)
                )
          and   faadj.book_type_code = ret.book
          and   faadj.set_of_books_id = ret.set_of_books_id
          and   faadj.adjustment_type in ('RESERVE', 'BONUS RESERVE', 'REVAL RESERVE', 'IMPAIR RESERVE')
          group by faadj.adjustment_type, faadj.code_combination_id
          ) cost_ret
          where cost_ret.adjustment_amount <> 0;

      l_tbl_adj tbl_adj;
      l_tbl_ret tbl_ret;
      l_tbl_cost_ret tbl_cost_ret;
      l_tbl_adj_final tbl_final_adj;

       /* Bug ends 7396397 */

  l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagiav';

  BEGIN <<FAGIAV>>

    h_reserve   := 0;
    h_today := today;
    h_retirement_id := ret.retirement_id;
    h_asset_id := ret.asset_id;
    h_user_id := user_id;
    h_book := ret.book;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Get thid_out from fa_rets',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    begin
       select  transaction_header_id_out
       into    h_th_id_out
       from    fa_retirements
       where   retirement_id = h_retirement_id;
       EXCEPTION
          when no_data_found then
             raise fagiav_error;
    end;

    adj_row.transaction_header_id := h_th_id_out;
    adj_row.asset_invoice_id :=  0;
    adj_row.source_type_code := 'RETIREMENT';
    adj_row.book_type_code :=  RET.book;
    adj_row.period_counter_created := cpd_ctr;
    adj_row.asset_id := RET.asset_id;
    adj_row.period_counter_adjusted := cpd_ctr;
    adj_row.last_update_date  := today;
    /* BUG# 2635084: bk.cur_units shouldn't be set to null
       becase it is being used by faxinaj for reinstatement.
     BK.cur_units  := NULL;
    */
    adj_row.current_units := NULL;
    adj_row.selection_mode := fa_std_types.FA_AJ_SINGLE;
    adj_row.selection_thid := 0;
    adj_row.selection_retid := 0;
    adj_row.flush_adj_flag := TRUE;
    adj_row.annualized_adjustment := 0;
    adj_row.units_retired := 0;
    adj_row.leveling_flag := TRUE;

    /*
     * Transfer reserve accumulated between time of retirement
     * and reinstatement.  Find pairs of distributions (before and
     * after the retirement), and move the amount of reserve that
     * will clear the distribution created by the retirement.  This
     * amount turns out to be the difference between the current
     * reserve and reserve adjustment amount created by the retirement.
     */

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Get category from fa_asset_history',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    SELECT category_id
    INTO h_category_id
    FROM fa_asset_history
    WHERE asset_id = RET.asset_id
    AND date_ineffective is null;

    adj_row.account := NULL;
    adj_row.account_type := NULL;
    adj_row.gen_ccid_flag := FALSE;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Get deprn_reserve info',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if (bk.group_asset_id is not null) then
      OPEN c_get_group_thid;
      FETCH c_get_group_thid INTO l_group_thid;
      CLOSE c_get_group_thid;
    end if;


    /*
    Checks if retirement is a partial unit retirement and
    asset is not a member of group. Except COST, all entries
    are inserted in fa_adjustments for a group when member asset
    is retired
    */
    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Populate PL-SQL tables',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if (nvl(ret.units_retired,0) > 0  ) then
      if (ret.mrc_sob_type_code <> 'R') then
        g_tbl_adj_rsv.delete;
        open c_adj;
        fetch c_adj BULK COLLECT into g_tbl_adj_rsv;
        close c_adj;

        open c_ret;
        fetch c_ret BULK COLLECT into l_tbl_ret;
        close c_ret;
      else
        open c_ret_mrc;
        fetch c_ret_mrc BULK COLLECT into l_tbl_ret;
        close c_ret_mrc;
      end if;

    else
      if (ret.mrc_sob_type_code <> 'R') then
        open c_cost_ret;
        fetch c_cost_ret BULK COLLECT into l_tbl_cost_ret;
        close c_cost_ret;
      else
        open c_cost_ret_mrc;
        fetch c_cost_ret_mrc BULK COLLECT into l_tbl_cost_ret;
        close c_cost_ret_mrc;
      end if; -- mrc
    end if; -- partial_unit retirement

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Before calling process_adj_table',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if not process_adj_table(p_mode=> 'RESERVE',RET => ret,BK => bk,
                             p_tbl_adj => g_tbl_adj_rsv, p_tbl_ret => l_tbl_ret,
                             p_tbl_cost_ret => l_tbl_cost_ret,
                             p_tbl_adj_final => l_tbl_adj_final,
                             p_log_level_rec => p_log_level_rec) then
      fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
      return false;
    end if ;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'After calling process_adj_table for non group',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    -- Now process for groups
    if (bk.group_asset_id is not null) then
      l_tbl_adj.delete;
      l_tbl_ret.delete;
      l_tbl_cost_ret.delete;
      if (ret.mrc_sob_type_code <> 'R') then
        open c_cost_ret_grp;
        fetch c_cost_ret_grp BULK COLLECT into l_tbl_cost_ret;
        close c_cost_ret_grp;
      else
        open c_cost_ret_grp_mrc;
        fetch c_cost_ret_grp_mrc BULK COLLECT into l_tbl_cost_ret;
        close c_cost_ret_grp_mrc;
      end if; -- mrc

      if not process_adj_table(p_mode=> 'GROUP',RET => ret,BK => bk,
                               p_tbl_adj => l_tbl_adj, p_tbl_ret => l_tbl_ret,
                               p_tbl_cost_ret => l_tbl_cost_ret,
                               p_tbl_adj_final => l_tbl_adj_final,
                               p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return false;
      end if ;

    end if;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'After calling process_adj_table for group',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    for l in 1..l_tbl_adj_final.count
    LOOP

      h_dist_id := l_tbl_adj_final(l).dist_id;
      h_ccid := l_tbl_adj_final(l).ccid;
      h_adj_type := l_tbl_adj_final(l).adj_type;
      h_dr_cr := l_tbl_adj_final(l).dr_cr;
      h_reserve := l_tbl_adj_final(l).cost;

      adj_row.asset_id := l_tbl_adj_final(l).asset_id;
      adj_row.code_combination_id :=  h_ccid;
      adj_row.adjustment_amount := h_reserve;
      adj_row.distribution_id  := h_dist_id;
      adj_row.debit_credit_flag := h_dr_cr;
      adj_row.adjustment_type  := h_adj_type;
      adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
      adj_row.set_of_books_id := ret.set_of_books_id;

      if (bk.group_asset_id is not null) and
         (bk.group_asset_id <> adj_row.asset_id)  and
         (nvl(bk.member_rollup_flag, 'N') = 'N') then
         adj_row.track_member_flag := 'Y';
      else
         adj_row.track_member_flag := null;
      end if;

      if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                                       X_last_update_date,
                                       X_last_updated_by,
                                       X_last_update_login
                                       , p_log_level_rec => p_log_level_rec)) then

           fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           return(FALSE);

      end if;

    END LOOP;


    return(TRUE);

  EXCEPTION

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return FALSE;

 END;  -- fagiav

/*======================================================================*
| NAME      faraje                                                        |
|                                                                         |
| FUNCTION  Adjust the deprn expense, reval expense, and reval_amort      |
|           we took at the time of the retirement.                        |
|                                                                         |
| History   Jacob John          1/29/97         Created
|=======================================================================*/

Function FARAJE(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        expense_amount IN NUMBER,
        adj_type IN VARCHAR2,
        cpd_ctr IN NUMBER,
        today   IN date,
        user_id IN NUMBER
 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

    adj_row     fa_adjust_type_pkg.fa_adj_row_struct ;

    h_expense_amount    number;
    h_asset_id          number;
    h_category_id       number;
    h_user_id           number;
    h_th_id_in          number;
    h_retirement_id     number;
    h_cur_units         number;
    h_dist_book         number;
    h_book              varchar2(30);
    h_today             date;
    h_adj_type          varchar2(15);
    h_cpd_ctr           number;
    h_th_id_out         NUMBER;
    h_dist_id           NUMBER;
    h_ccid              NUMBER;
    h_exp_adj_amount    NUMBER;
    h_cost_frac         Number;

    h_exp_adj_amount_sorp NUMBER; -- Bug 6666666


    FARAJE_ERROR        EXCEPTION;

    X_LAST_UPDATE_DATE date := sysdate;
    X_last_updated_by number := -1;
    X_last_update_login number := -1;

    CURSOR DIST_DEPRN1 is
        SELECT dh.distribution_id,
               dh.code_combination_id,
               (dh.units_assigned / ah.units)
                                  * expense_amount -
                                   nvl(adj.adjustment_amount, 0),
               (dh.units_assigned / ah.units)
                                  * expense_amount          --Bug 6666666
        FROM
                FA_DISTRIBUTION_HISTORY dh,
                FA_ASSET_HISTORY ah,
                FA_ADJUSTMENTS          adj
        WHERE dh.asset_id = RET.asset_id
        AND   dh.book_type_code = BK.dis_book
        AND   dh.date_ineffective is null
        AND   dh.distribution_id = adj.distribution_id(+)
        AND   ah.asset_id = RET.asset_id
        AND   ah.date_ineffective is null
        AND   adj.transaction_header_id(+) = RET.th_id_in
        AND   adj.source_type_code(+) = 'RETIREMENT'
        AND   adj.adjustment_type(+) = adj_type
        AND   adj.debit_credit_flag(+) = 'DR'
        AND   adj.asset_id(+) = RET.asset_id
        AND   adj.book_type_code(+) = RET.book
        union all
        SELECT dh.distribution_id,
               dh.code_combination_id,
               ((1/(1-h_cost_frac))-1) * nvl(adj.adjustment_amount, 0),
               0                                            -- Bug 6666666
        FROM FA_DISTRIBUTION_HISTORY dh
            ,FA_ASSET_HISTORY        ah
            ,FA_TRANSACTION_HEADERS  ret_th
            ,FA_ADJUSTMENTS          adj
            ,FA_TRANSACTION_HEADERS  exp_th
        WHERE dh.asset_id = RET.asset_id
        AND   dh.book_type_code = BK.dis_book
        AND   dh.date_ineffective is null
        AND   dh.distribution_id = adj.distribution_id
        AND   ah.asset_id = RET.asset_id
        AND   ah.date_ineffective is null
        AND   ret_th.transaction_header_id = RET.th_id_in
        AND   ret_th.asset_id = dh.asset_id
        AND   ret_th.book_type_code = RET.book
        AND   ret_th.transaction_type_code like '%RETIREMENT'
        AND   adj.transaction_header_id >= RET.th_id_in
        AND   adj.transaction_header_id <= h_th_id_out
        AND   adj.source_type_code = 'DEPRECIATION'
        AND   adj.adjustment_type = adj_type
        AND   adj.debit_credit_flag = 'DR'
        AND   adj.asset_id = RET.asset_id
        AND   adj.book_type_code = RET.book
        AND   exp_th.transaction_header_id = adj.transaction_header_id
        AND   exp_th.asset_id = adj.asset_id
        AND   exp_th.book_type_code = adj.book_type_code
        AND   exp_th.transaction_subtype = 'EXPENSED'
        ;

    CURSOR MRC_DIST_DEPRN1 is
        SELECT dh.distribution_id,
               dh.code_combination_id,
               (dh.units_assigned / ah.units)
                                  * expense_amount -
                                   nvl(adj.adjustment_amount, 0),
               (dh.units_assigned / ah.units)
                                  * expense_amount           -- Bug 6666666
        FROM
                FA_DISTRIBUTION_HISTORY dh,
                FA_ASSET_HISTORY ah,
                FA_MC_ADJUSTMENTS adj
        WHERE dh.asset_id = RET.asset_id
        AND   dh.book_type_code = BK.dis_book
        AND   dh.date_ineffective is null
        AND   dh.distribution_id = adj.distribution_id(+)
        AND   ah.asset_id = RET.asset_id
        AND   ah.date_ineffective is null
        AND   adj.transaction_header_id(+) = RET.th_id_in
        AND   adj.source_type_code(+) = 'RETIREMENT'
        AND   adj.adjustment_type(+) = adj_type
        AND   adj.debit_credit_flag(+) = 'DR'
        AND   adj.set_of_books_id(+) = ret.set_of_books_id --Bug#8761988
        AND   adj.asset_id(+) = RET.asset_id
        AND   adj.book_type_code(+) = RET.book
        union all
        SELECT dh.distribution_id,
               dh.code_combination_id,
               ((1/(1-h_cost_frac))-1) * nvl(adj.adjustment_amount, 0),
               0                                            -- Bug 6666666
        FROM
                FA_DISTRIBUTION_HISTORY dh,
                FA_ASSET_HISTORY ah,
                FA_MC_ADJUSTMENTS adj -- bug#5094783 fix
        WHERE dh.asset_id = RET.asset_id
        AND   dh.book_type_code = BK.dis_book
        AND   dh.date_ineffective is null
        AND   dh.distribution_id = adj.distribution_id(+)
        AND   ah.asset_id = RET.asset_id
        AND   ah.date_ineffective is null
        AND   adj.transaction_header_id(+) >= RET.th_id_in
        AND   adj.transaction_header_id(+) <= h_th_id_out
        AND   adj.source_type_code(+) = 'DEPRECIATION'
        AND   adj.adjustment_type(+) = adj_type
        AND   adj.debit_credit_flag(+) = 'DR'
        AND   adj.set_of_books_id(+) = RET.set_of_books_id
        AND   adj.asset_id(+) = RET.asset_id
        AND   adj.book_type_code(+) = RET.book;

        CURSOR DIST_DEPRN2 IS
            SELECT
                faadj.distribution_id,
                faadj.code_combination_id,
                - 1 * faadj.adjustment_amount
            FROM
                fa_distribution_history         fadh,
                fa_adjustments                  faadj
            WHERE fadh.asset_id(+) = RET.asset_id
            AND   fadh.book_type_code(+) = BK.dis_book
            AND   fadh.date_ineffective(+) is null
            AND   fadh.distribution_id(+) = faadj.distribution_id
            AND   fadh.distribution_id is null
            AND   faadj.transaction_header_id = RET.th_id_in
            AND   faadj.source_type_code = 'RETIREMENT'
            AND   faadj.adjustment_type = adj_type
            AND   faadj.debit_credit_flag = 'DR'
            AND   faadj.asset_id = RET.asset_id
            AND   faadj.book_type_code = RET.book;

        CURSOR MRC_DIST_DEPRN2 IS
            SELECT
                faadj.distribution_id,
                faadj.code_combination_id,
                - 1 * faadj.adjustment_amount
            FROM
                fa_distribution_history         fadh,
                fa_mc_adjustments               faadj
            WHERE fadh.asset_id(+) = RET.asset_id
            AND   fadh.book_type_code(+) = BK.dis_book
            AND   fadh.date_ineffective(+) is null
            AND   fadh.distribution_id(+) = faadj.distribution_id
            AND   fadh.distribution_id is null
            AND   faadj.transaction_header_id = RET.th_id_in
            AND   faadj.source_type_code = 'RETIREMENT'
            AND   faadj.adjustment_type = adj_type
            AND   faadj.debit_credit_flag = 'DR'
            AND   faadj.asset_id = RET.asset_id
            AND   faadj.set_of_books_id = RET.set_of_books_id
            AND   faadj.book_type_code = RET.book;


        CURSOR DIST_DEPRN3 IS
        SELECT
            fadh.distribution_id,
            fadh.code_combination_id,
            (ABS(fadh.transaction_units) / faret.units)
                                  * expense_amount -
                                  NVL(faadj.adjustment_amount, 0),
            (ABS(fadh.transaction_units) / faret.units)
                                  * expense_amount        -- Bug 6666666
        FROM  FA_RETIREMENTS faret, fa_distribution_history fadh,
              fa_adjustments faadj
        WHERE fadh.asset_id = RET.asset_id
        AND   fadh.book_type_code = BK.dis_book
        AND   fadh.retirement_id = RET.retirement_id
        AND   fadh.distribution_id = faadj.distribution_id(+)
        AND   faadj.transaction_header_id(+) = RET.th_id_in
        AND   faadj.source_type_code(+) = 'RETIREMENT'
        AND   faadj.adjustment_type(+) = adj_type
        AND   faadj.debit_credit_flag(+) = 'DR'
        AND   faadj.asset_id(+) = RET.asset_id
        AND   faadj.book_type_code(+) = RET.book
        AND   faret.retirement_id = RET.retirement_id;

        CURSOR MRC_DIST_DEPRN3 IS
        SELECT
            fadh.distribution_id,
            fadh.code_combination_id,
            (ABS(fadh.transaction_units) / faret.units)
                                  * expense_amount -
                                  NVL(faadj.adjustment_amount, 0),
            (ABS(fadh.transaction_units) / faret.units)
                                  * expense_amount      -- Bug 6666666
        FROM  FA_MC_RETIREMENTS faret, fa_distribution_history fadh,
              fa_mc_adjustments faadj
        WHERE fadh.asset_id = RET.asset_id
        AND   fadh.book_type_code = BK.dis_book
        AND   fadh.retirement_id = RET.retirement_id
        AND   fadh.distribution_id = faadj.distribution_id(+)
        AND   faadj.transaction_header_id(+) = RET.th_id_in
        AND   faadj.source_type_code(+) = 'RETIREMENT'
        AND   faadj.adjustment_type(+) = adj_type
        AND   faadj.debit_credit_flag(+) = 'DR'
        AND   faadj.asset_id(+) = RET.asset_id
        AND   faadj.book_type_code(+) = RET.book
        AND   faadj.set_of_books_id(+) = RET.set_of_books_id
        AND   faret.set_of_books_id = RET.set_of_books_id
        AND   faret.retirement_id = RET.retirement_id;

        CURSOR DIST_DEPRN4 IS
        SELECT
            faadj.distribution_id,
            faadj.code_combination_id,
            - 1 * faadj.adjustment_amount
            FROM
                FA_RETIREMENTS          faret,
                FA_DISTRIBUTION_HISTORY fadh,
                FA_ADJUSTMENTS          faadj
            WHERE fadh.asset_id(+) = RET.asset_id
            AND   fadh.book_type_code(+) = BK.dis_book
            AND   fadh.retirement_id(+) = RET.retirement_id
            AND   fadh.distribution_id(+) = faadj.distribution_id
            AND   fadh.distribution_id is null
            AND   faadj.transaction_header_id = faret.transaction_header_id_in
            AND   faadj.source_type_code = 'RETIREMENT'
            AND   faadj.adjustment_type = adj_type
            AND   faadj.debit_credit_flag = 'DR'
            AND   faadj.asset_id = RET.asset_id
            AND   faadj.book_type_code = RET.book
            AND   faret.retirement_id = RET.retirement_id;

        CURSOR MRC_DIST_DEPRN4 IS
        SELECT
            faadj.distribution_id,
            faadj.code_combination_id,
            - 1 * faadj.adjustment_amount
            FROM
                FA_MC_RETIREMENTS       faret,
                FA_DISTRIBUTION_HISTORY fadh,
                FA_MC_ADJUSTMENTS       faadj
            WHERE fadh.asset_id(+) = RET.asset_id
            AND   fadh.book_type_code(+) = BK.dis_book
            AND   fadh.retirement_id(+) = RET.retirement_id
            AND   fadh.distribution_id(+) = faadj.distribution_id
            AND   fadh.distribution_id is null
            AND   faadj.transaction_header_id = faret.transaction_header_id_in
            AND   faadj.source_type_code = 'RETIREMENT'
            AND   faadj.adjustment_type = adj_type
            AND   faadj.debit_credit_flag = 'DR'
            AND   faadj.set_of_books_id = RET.set_of_books_id
            AND   faadj.asset_id = RET.asset_id
            AND   faadj.book_type_code = RET.book
            AND   faret.set_of_books_id = RET.set_of_books_id
            AND   faret.retirement_id = RET.retirement_id;

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.faraje';

BEGIN <<FARAJE>>

    h_expense_amount := 0;
    h_exp_adj_amount := 0;
    h_expense_amount := expense_amount;
    h_asset_id  := ret.asset_id;
    h_user_id := user_id;
    h_retirement_id := ret.retirement_id;
    h_th_id_in  := ret.th_id_in;
    h_cur_units := bk.cur_units;
    h_cpd_ctr := cpd_ctr;
    h_today := today;
    h_book := ret.book;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Get thid_out from fa_rets',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    select  transaction_header_id_out
    into    h_th_id_out
    from    fa_retirements
    where   retirement_id = h_retirement_id;

    -- bug#5094783 fix added ((ret.cost_retired / bk.current_cost) =1 )
    if ( bk.current_cost is NULL or bk.current_cost <= 0 or ((ret.cost_retired / bk.current_cost) =1 )) then
        h_cost_frac := 0;
    else
        h_cost_frac :=  ret.cost_retired / bk.current_cost;
    end if;


    --The following statement will insert rows into FA_ADJUSTMENTS for
    --   each active current distribution. Notice, that we still need to insert
    --   records for which distribution-id is in FA_ADJUSTMENTS but not in
    --   active distributions (e.g: Transfer occured before retirement)

    adj_row.transaction_header_id := h_th_id_out;
    adj_row.asset_invoice_id :=  0;
    adj_row.source_type_code := 'RETIREMENT';
    adj_row.book_type_code := RET.book;
    adj_row.period_counter_created := cpd_ctr;
    adj_row.asset_id := RET.asset_id;
    adj_row.period_counter_adjusted := cpd_ctr;
    adj_row.last_update_date := today;
    adj_row.account := NULL;
    adj_row.account_type := NULL;
    adj_row.current_units := BK.cur_units;
    adj_row.selection_mode := fa_std_types.FA_AJ_SINGLE;
    adj_row.selection_thid := 0;
    adj_row.selection_retid := 0;
    adj_row.flush_adj_flag := TRUE;
    adj_row.gen_ccid_flag := FALSE;
    adj_row.annualized_adjustment := 0;
    adj_row.units_retired := 0;
    adj_row.leveling_flag := TRUE;

    -- HH
    -- BUG 3630399
    -- Need to call cache routines to avoid null segment as
    -- reported in above bug.  Cache was not called anywhere before
    -- assignment below.
    --

    -- This could be done using api types, but doing direct select since
    -- old structs are kept here.

    SELECT category_id
    INTO h_category_id
    FROM fa_asset_history
    WHERE asset_id = RET.asset_id
    AND date_ineffective is null;

    if not fa_cache_pkg.fazccb(
                   X_book   => RET.book,
                   X_cat_id => h_category_id, p_log_level_rec => p_log_level_rec) then
        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return(FALSE);
    end if;
    -- end HH.

    if adj_type = 'EXPENSE' then

        -- BUG# 2314015
        -- allowing for account generation of the expense account
        -- otherwise the account may not match what was charged in
        -- the retirements.  DEPRN1 and 3 cursors will call faxinaj
        -- with gen_ccid = true.  2 and 4 will call with false since
        -- they look for rows where the distribution doesn't exist.
        -- other struct members that change are account and account type
        --      bridgway
        --

        adj_row.account :=
                      fa_cache_pkg.fazccb_record.DEPRN_EXPENSE_ACCT;
        adj_row.account_type := 'DEPRN_EXPENSE_ACCT';
        adj_row.gen_ccid_flag := TRUE;

        adj_row.adjustment_type := 'EXPENSE';
        adj_row.debit_credit_flag := 'DR';

    elsif adj_type = 'BONUS EXPENSE' then

        adj_row.account:=
                      fa_cache_pkg.fazccb_record.BONUS_DEPRN_EXPENSE_ACCT;
        adj_row.account_type := 'BONUS_DEPRN_EXPENSE_ACCT';
        adj_row.adjustment_type := 'BONUS EXPENSE';
        adj_row.debit_credit_flag :=  'DR';
        adj_row.gen_ccid_flag := TRUE;

    elsif adj_type = 'IMPAIR EXPENSE' then

        adj_row.account:=
                      fa_cache_pkg.fazccb_record.IMPAIR_EXPENSE_ACCT;
        adj_row.account_type := 'IMPAIR_EXPENSE_ACCT';
        adj_row.adjustment_type := 'IMPAIR EXPENSE';
        adj_row.debit_credit_flag :=  'DR';
        adj_row.gen_ccid_flag := TRUE;

    elsif adj_type = 'REVAL EXPENSE' then

        adj_row.adjustment_type := 'REVAL EXPENSE';
        adj_row.debit_credit_flag := 'DR';

    else

        adj_row.adjustment_type := 'REVAL AMORT';
        adj_row.debit_credit_flag := 'DR';

    end if;


    if RET.units_retired is NULL or RET.units_retired <= 0 then

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Get dist and deprn 1 info',
             value   => '', p_log_level_rec => p_log_level_rec);
        end if;

        if (ret.mrc_sob_type_code <> 'R') then
            OPEN DIST_DEPRN1;
        else
            OPEN MRC_DIST_DEPRN1;
        end if;

        LOOP

           if p_log_level_rec.statement_level then
              fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Fetch dist and deprn 1 info',
               value   => '', p_log_level_rec => p_log_level_rec);
           end if;

           if (ret.mrc_sob_type_code <> 'R') then

              FETCH DIST_DEPRN1 INTO
                h_dist_id,
                h_ccid,
                h_exp_adj_amount,
                h_exp_adj_amount_sorp;   -- Bug 6666666
              EXIT when DIST_DEPRN1%NOTFOUND OR DIST_DEPRN1%NOTFOUND IS NULL;

           else

              FETCH MRC_DIST_DEPRN1 INTO
                h_dist_id,
                h_ccid,
                h_exp_adj_amount,
                h_exp_adj_amount_sorp;   -- Bug 6666666
              EXIT when MRC_DIST_DEPRN1%NOTFOUND OR MRC_DIST_DEPRN1%NOTFOUND IS NULL;

           end if;

           adj_row.code_combination_id := h_ccid;
           adj_row.adjustment_amount := h_exp_adj_amount;
           adj_row.distribution_id := h_dist_id;
           adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
           adj_row.set_of_books_id := ret.set_of_books_id;

           if not FA_UTILS_PKG.faxrnd(adj_row.adjustment_amount, ret.book, ret.set_of_books_id, p_log_level_rec => p_log_level_rec) then
             fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
             return(FALSE);
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


            /* Bug 6666666 : Added for SORP Compliance
               Only the expense amount calculated during reinstatement
               should be inserted for SORP. The previous value from the
               adjustment table must not be taken into account as it has
               been already reversed due to the code in FAGIAR.
            */
            if FA_CACHE_PKG.fazcbc_record.sorp_enabled_flag = 'Y'
                 and adj_row.adjustment_type = 'EXPENSE'
                 and h_exp_adj_amount_sorp <> 0 then
                 if not FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                        p_amount                => h_exp_adj_amount_sorp,
                        p_reversal              => 'N',
                        p_adj                   => adj_row,
                        p_created_by            => NULL,
                        p_creation_date         => NULL,
                        p_last_update_date      => X_last_update_date,
                        p_last_updated_by       => X_last_updated_by,
                        p_last_update_login     => X_last_update_login,
                        p_who_mode              => 'UPDATE'
                        , p_log_level_rec => p_log_level_rec) then
                        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                        return(FALSE);
                 end if;
            end if;


           END LOOP;

        if (ret.mrc_sob_type_code <> 'R') then
            CLOSE DIST_DEPRN1;
        else
            CLOSE MRC_DIST_DEPRN1;
        end if;

        -- Inserting to FA_ADJUSTMENTS which dist-id is NOT active distributions

        if p_log_level_rec.statement_level then
              fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Get dist and deprn 2 info',
               value   => '', p_log_level_rec => p_log_level_rec);
        end if;

        -- BUG# 2314015
        if (adj_type = 'EXPENSE') then
           adj_row.account := NULL;
           adj_row.account_type := NULL;
           adj_row.gen_ccid_flag := FALSE;
        end if;

        if (ret.mrc_sob_type_code <> 'R') then
            OPEN DIST_DEPRN2;
        else
            OPEN MRC_DIST_DEPRN2;
        end if;

        LOOP

            if p_log_level_rec.statement_level then
               fa_debug_pkg.add
               (fname   => l_calling_fn,
                element => 'Fetch dist and deprn 2 info',
                value   => '', p_log_level_rec => p_log_level_rec);
            end if;

            if (ret.mrc_sob_type_code <> 'R') then
              FETCH DIST_DEPRN2 INTO
                h_dist_id,
                h_ccid,
                h_exp_adj_amount;
              EXIT WHEN DIST_DEPRN2%NOTFOUND OR DIST_DEPRN2%NOTFOUND IS NULL;
            else
              FETCH MRC_DIST_DEPRN2 INTO
                h_dist_id,
                h_ccid,
                h_exp_adj_amount;
              EXIT WHEN MRC_DIST_DEPRN2%NOTFOUND OR MRC_DIST_DEPRN2%NOTFOUND IS NULL;
            end if;

            adj_row.code_combination_id := h_ccid;
            adj_row.adjustment_amount := h_exp_adj_amount;
            adj_row.distribution_id := h_dist_id;
            adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
            adj_row.set_of_books_id := ret.set_of_books_id;

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

        END LOOP ;

        if (ret.mrc_sob_type_code <> 'R') then
            CLOSE DIST_DEPRN2;
        else
            CLOSE MRC_DIST_DEPRN2;
        end if;

    return(TRUE);

  else
        if p_log_level_rec.statement_level then
             fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Get dist and deprn 3 info',
               value   => '', p_log_level_rec => p_log_level_rec);
        end if;

        if (ret.mrc_sob_type_code <> 'R') then
            OPEN DIST_DEPRN3;
        else
            OPEN MRC_DIST_DEPRN3;
        end if;
        LOOP

           if p_log_level_rec.statement_level then
             fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'Fetch dist and deprn 3 info',
               value   => '', p_log_level_rec => p_log_level_rec);
           end if;

           if (ret.mrc_sob_type_code <> 'R') then
              FETCH DIST_DEPRN3 INTO
                h_dist_id,
                h_ccid,
                h_exp_adj_amount,
                h_exp_adj_amount_sorp; -- Bug 6666666
              EXIT WHEN DIST_DEPRN3%NOTFOUND OR DIST_DEPRN3%NOTFOUND IS NULL;
           else
              FETCH MRC_DIST_DEPRN3 INTO
                h_dist_id,
                h_ccid,
                h_exp_adj_amount,
                h_exp_adj_amount_sorp;  -- Bug 6666666
              EXIT WHEN MRC_DIST_DEPRN3%NOTFOUND OR MRC_DIST_DEPRN3%NOTFOUND IS NULL;
           end if;

           adj_row.code_combination_id := h_ccid;
           adj_row.adjustment_amount := h_exp_adj_amount;
           adj_row.distribution_id := h_dist_id;
           adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
           adj_row.set_of_books_id := ret.set_of_books_id;

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

            /* Bug 6666666 : Added for SORP Compliance
               Only the expense amount calculated during reinstatement
               should be inserted for SORP. The previous value from the
               adjustment table must not be taken into account as it has
               been already reversed due to the code in FAGIAR.
            */
            if FA_CACHE_PKG.fazcbc_record.sorp_enabled_flag = 'Y'
                 and adj_row.adjustment_type = 'EXPENSE'
                 and h_exp_adj_amount_sorp <> 0 then
                 if not FA_SORP_UTIL_PVT.create_sorp_neutral_acct (
                        p_amount                => h_exp_adj_amount_sorp,
                        p_reversal              => 'N',
                        p_adj                   => adj_row,
                        p_created_by            => NULL,
                        p_creation_date         => NULL,
                        p_last_update_date      => X_last_update_date,
                        p_last_updated_by       => X_last_updated_by,
                        p_last_update_login     => X_last_update_login,
                        p_who_mode              => 'UPDATE'
                        , p_log_level_rec => p_log_level_rec) then
                        fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                        return(FALSE);
                 end if;
             end if;

        END LOOP;

        if (ret.mrc_sob_type_code <> 'R') then
            CLOSE DIST_DEPRN3;
        else
            CLOSE MRC_DIST_DEPRN3;
        end if;

        if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Get dist and deprn 4 info',
             value   => '', p_log_level_rec => p_log_level_rec);
        end if;

        -- BUG# 2314015
        if (adj_type = 'EXPENSE') then
           adj_row.account := NULL;
           adj_row.account_type := NULL;
           adj_row.gen_ccid_flag := FALSE;
        end if;

        if (ret.mrc_sob_type_code <> 'R') then
            OPEN DIST_DEPRN4;
        else
            OPEN MRC_DIST_DEPRN4;
        end if;

        LOOP

            if p_log_level_rec.statement_level then
               fa_debug_pkg.add
               (fname   => l_calling_fn,
                element => 'Fetch dist and deprn 4 info',
                value   => '', p_log_level_rec => p_log_level_rec);
            end if;

            if (ret.mrc_sob_type_code <> 'R') then
              FETCH DIST_DEPRN4 INTO
                h_dist_id,
                h_ccid,
                h_exp_adj_amount;
              EXIT WHEN DIST_DEPRN4%NOTFOUND OR DIST_DEPRN4%NOTFOUND IS NULL;
            else
              FETCH MRC_DIST_DEPRN4 INTO
                h_dist_id,
                h_ccid,
                h_exp_adj_amount;
              EXIT WHEN MRC_DIST_DEPRN4%NOTFOUND OR MRC_DIST_DEPRN4%NOTFOUND IS NULL;
            end if;

            adj_row.code_combination_id := h_ccid;
            adj_row.adjustment_amount := h_exp_adj_amount;
            adj_row.distribution_id := h_dist_id;
            adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
            adj_row.set_of_books_id := ret.set_of_books_id;

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

           END LOOP;

        if (ret.mrc_sob_type_code <> 'R') then
            CLOSE DIST_DEPRN4;
        else
            CLOSE MRC_DIST_DEPRN4;
        end if;

        return(TRUE);

    end if;

 EXCEPTION

   when others then
        fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        return FALSE;


 END;  -- faraje


/*========================================================================*
| NAME      fagidn                                                        |
|                                                                         |
| FUNCTION  Adjust the depreciation we took at the time of the retirement.|
|           The formula is dpcldr - ADJ in FA_ADJUSTMENTS.                |
|                                                                         |
| History   Jacob John          1/29/97         Created
|=========================================================================*/

Function FAGIDN(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        deprn_amount IN number,
        bonus_deprn_amount IN number,
        impairment_amount IN number,
        reval_deprn_amt IN number,
        reval_amort_amt IN number,
        cpd_ctr IN NUMBER,
        today IN DATE,
        user_id IN NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS


    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagidn';

BEGIN <<FAGIDN>>

    if (not faraje(ret,
                  bk,
                  deprn_amount,
                  'EXPENSE',
                  cpd_ctr,
                  today,
                  user_id,
                  p_log_level_rec )) then

          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);

    end if;

    if (not faraje(ret,
                  bk,
                  bonus_deprn_amount,
                  'BONUS EXPENSE',
                  cpd_ctr,
                  today,
                  user_id,
                  p_log_level_rec )) then

          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);

    end if;

    if (not faraje(ret,
                  bk,
                  impairment_amount,
                  'IMPAIR EXPENSE',
                  cpd_ctr,
                  today,
                  user_id,
                  p_log_level_rec )) then

          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);

    end if;

    if (not faraje(ret,
                  bk,
                  reval_deprn_amt,
                  'REVAL EXPENSE',
                  cpd_ctr,
                  today,
                  user_id,
                  p_log_level_rec )) then

          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);

    end if;

    if (not faraje(ret,
                  bk,
                  reval_amort_amt,
                  'REVAL AMORT',
                  cpd_ctr,
                  today,
                  user_id ,
                  p_log_level_rec)) then

          fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
          return(FALSE);

    end if;

    return(TRUE);

  END;  -- fagidn


/*============================================================================
|    NAME    fagirv                                                          |
|                                                                            |
|FUNCTION    It determines the reserve when the time retirement happened.    |
|                                                                            |
|
| History   Jacob John          1/29/97         Created
|============================================================================*/

Function FAGIRV(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        startpd IN OUT NOCOPY number,
        rsv IN OUT NOCOPY number,
        bonus_rsv in out nocopy number,
        impairment_rsv in out nocopy number,
        reval_rsv IN OUT NOCOPY number, prior_fy_exp in out number,
        ytd_deprn in out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean  IS

        h_rpdnum                NUMBER;
        h_th_id                 number;
        h_asset_id              number;
        h_pd_counter            NUMBER;
        h_rpdname               VARCHAR2(16);
        h_date_effective        date;
        h_book                  varchar2(30);
        h_deprn_reserve         NUMBER;
        h_bonus_deprn_reserve   NUMBER;
        h_impairment_reserve    NUMBER;
        h_reval_reserve         NUMBER;
        h_prior_fy_expense      number;
        h_ytd_deprn             number;
        h_tot_deprn_adj         NUMBER;
        h_tot_bonus_deprn_adj   NUMBER;
        h_tot_impairment_adj    NUMBER;
        h_tot_reval_adj         NUMBER;
        FAGIRV_ERROR            EXCEPTION;

        l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagirv';

BEGIN <<FAGIRV>>

    h_deprn_reserve     := 0;
    h_bonus_deprn_reserve     := 0;
    h_impairment_reserve := 0;
    h_reval_reserve     := 0;
    -- Initialize h_prior_fy_expense
    h_prior_fy_expense  := 0;
    h_ytd_deprn := 0;
    h_tot_deprn_adj     := 0;
    h_tot_bonus_deprn_adj     := 0;
    h_tot_impairment_adj := 0;
    h_tot_reval_adj     := 0;
    h_asset_id := ret.asset_id;
    h_th_id := ret.th_id_in;
    h_book := ret.book;
    h_date_effective := ret.date_effective;

    /* EXEC SQL WHENEVER SQLERROR GOTO fagirv_error;
    EXEC SQL WHENEVER NOT FOUND GOTO fagirv_error;  */

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Retirement Periods',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    SELECT PERIOD_NUM , PERIOD_NAME, PERIOD_COUNTER
        INTO    h_rpdnum, h_rpdname, h_pd_counter
        FROM    FA_DEPRN_PERIODS fadp
        WHERE   RET.date_effective
                between fadp.period_open_date and
                    nvl(fadp.period_close_date,
                        RET.date_effective)
        AND     fadp.book_type_code = h_book;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'reserve (Before Retirement)',
             value   => '');
    end if;

/*** Retrieve FA_DEPRN_SUMMARY.PRIOR_FY_EXPENSE. ***/
/*** and Year-to-date depreciation.              ***/

    if (ret.mrc_sob_type_code <> 'R') then

       SELECT fads.deprn_reserve, fads.bonus_deprn_reserve, fads.reval_reserve,
              nvl(fads.prior_fy_expense, 0), nvl(fads.ytd_deprn, 0),
              nvl(fads.impairment_reserve, 0)
        INTO  h_deprn_reserve, h_bonus_deprn_reserve, h_reval_reserve,
              h_prior_fy_expense, h_ytd_deprn,
              h_impairment_reserve
        FROM fa_deprn_summary fads, fa_deprn_periods fadp
        WHERE fads.asset_id = h_asset_id
        AND   fads.book_type_Code = h_book
        AND   fads.period_counter = fadp.period_counter
        AND   fadp.period_counter =
            (select MAX(DP.PERIOD_COUNTER)
             FROM FA_DEPRN_PERIODS DP, FA_DEPRN_SUMMARY DS
             WHERE DP.BOOK_TYPE_CODE = h_book
             AND DP.PERIOD_COUNTER = DS.PERIOD_COUNTER
             AND DP.PERIOD_COUNTER < h_pd_counter
             AND DS.BOOK_TYPE_CODE = h_book
             AND DS.ASSET_ID = h_asset_id)
        AND  FADP.BOOK_TYPE_CODE = h_book;

    else

       SELECT fads.deprn_reserve, fads.bonus_deprn_reserve, fads.reval_reserve,
              nvl(fads.prior_fy_expense, 0), nvl(fads.ytd_deprn, 0),
              nvl(fads.impairment_reserve, 0)
        INTO  h_deprn_reserve, h_bonus_deprn_reserve, h_reval_reserve,
              h_prior_fy_expense, h_ytd_deprn,
              h_impairment_reserve
        FROM fa_mc_deprn_summary fads, fa_deprn_periods fadp
        WHERE fads.asset_id = h_asset_id
        AND   fads.book_type_Code = h_book
        AND   fads.period_counter = fadp.period_counter
        AND   fads.set_of_books_id = ret.set_of_books_id
        AND   fadp.period_counter =
            (select MAX(DP.PERIOD_COUNTER)
             FROM FA_DEPRN_PERIODS DP, FA_MC_DEPRN_SUMMARY DS
             WHERE DP.BOOK_TYPE_CODE = h_book
             AND DP.PERIOD_COUNTER = DS.PERIOD_COUNTER
             AND DP.PERIOD_COUNTER < h_pd_counter
             AND DS.set_of_books_id = ret.set_of_books_id
             AND DS.BOOK_TYPE_CODE = h_book
             AND DS.ASSET_ID = h_asset_id)
        AND  FADP.BOOK_TYPE_CODE = h_book;

    end if;

    prior_fy_exp := h_prior_fy_expense;
    ytd_deprn := h_ytd_deprn;

/*** Depreciation can handle subtraction method in only case of ***/
/*** normal additions and prior additions.                      ***/

    prior_fy_exp := 0;
    ytd_deprn := 0;

    h_tot_deprn_adj     := 0;
    h_tot_bonus_deprn_adj := 0;
    h_tot_impairment_adj := 0;
    h_tot_reval_adj     := 0;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'reserve (at Retirement)',
             value   => '');
    end if;

    /* WHENEVER NOT FOUND CONTINUE;  */

    if (ret.mrc_sob_type_code <> 'R') then
      BEGIN
      SELECT SUM(DECODE(faadj.adjustment_type, 'RESERVE',
                               DECODE(faadj.debit_credit_flag, 'DR',
                               -1 * faadj.adjustment_amount,
                               faadj.adjustment_amount),
                               faadj.adjustment_amount))
        INTO   h_tot_deprn_adj
        FROM   fa_adjustments faadj
        WHERE  faadj.asset_id = RET.asset_id
        AND    faadj.book_type_code = RET.book
        AND    faadj.source_type_code = 'RETIREMENT'
        AND    faadj.adjustment_type in ('RESERVE', 'EXPENSE', 'REVAL EXPENSE')
        AND    faadj.period_counter_created = h_pd_counter
        AND    faadj.transaction_header_id <> RET.th_id_in
        GROUP BY faadj.asset_id;
      EXCEPTION
        When others then
                null;
      END;
    else
      BEGIN
      SELECT SUM(DECODE(faadj.adjustment_type, 'RESERVE',
                               DECODE(faadj.debit_credit_flag, 'DR',
                               -1 * faadj.adjustment_amount,
                               faadj.adjustment_amount),
                               faadj.adjustment_amount))
        INTO   h_tot_deprn_adj
        FROM   fa_mc_adjustments faadj
        WHERE  faadj.asset_id = RET.asset_id
        AND    faadj.book_type_code = RET.book
        AND    faadj.source_type_code = 'RETIREMENT'
        AND    faadj.adjustment_type in ('RESERVE', 'EXPENSE', 'REVAL EXPENSE')
        AND    faadj.period_counter_created = h_pd_counter
        AND    faadj.set_of_books_id = ret.set_of_books_id
        AND    faadj.transaction_header_id <> RET.th_id_in
        GROUP BY faadj.asset_id;
      EXCEPTION
        When others then
                null;
      END;
    end if;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'bonus reserve (at Retirement)',
             value   => '');
    end if;

    if (ret.mrc_sob_type_code <> 'R') then
      BEGIN
      SELECT SUM(DECODE(faadj.adjustment_type, 'BONUS RESERVE',
                               DECODE(faadj.debit_credit_flag, 'DR',
                               -1 * faadj.adjustment_amount,
                               faadj.adjustment_amount),
                               faadj.adjustment_amount))
        INTO   h_tot_bonus_deprn_adj
        FROM   fa_adjustments faadj
        WHERE  faadj.asset_id = RET.asset_id
        AND    faadj.book_type_code = RET.book
        AND    faadj.source_type_code = 'RETIREMENT'
        AND    faadj.adjustment_type in ('BONUS RESERVE', 'BONUS EXPENSE')
        AND    faadj.period_counter_created = h_pd_counter
        AND    faadj.transaction_header_id <> RET.th_id_in
        GROUP BY faadj.asset_id;
      EXCEPTION
        When others then
                null;
      END;
    else
      BEGIN
      SELECT SUM(DECODE(faadj.adjustment_type, 'BONUS RESERVE',
                               DECODE(faadj.debit_credit_flag, 'DR',
                               -1 * faadj.adjustment_amount,
                               faadj.adjustment_amount),
                               faadj.adjustment_amount))
        INTO   h_tot_bonus_deprn_adj
        FROM   fa_mc_adjustments faadj
        WHERE  faadj.asset_id = RET.asset_id
        AND    faadj.book_type_code = RET.book
        AND    faadj.source_type_code = 'RETIREMENT'
        AND    faadj.adjustment_type in ('BONUS RESERVE', 'BONUS EXPENSE')
        AND    faadj.period_counter_created = h_pd_counter
        AND    faadj.set_of_books_id = ret.set_of_books_id
        AND    faadj.transaction_header_id <> RET.th_id_in
        GROUP BY faadj.asset_id;
      EXCEPTION
        When others then
                null;
      END;
    end if;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'impair reserve (at Retirement)',
             value   => '');
    end if;

    if (ret.mrc_sob_type_code <> 'R') then
      BEGIN
      SELECT SUM(DECODE(faadj.adjustment_type, 'IMPAIR RESERVE',
                               DECODE(faadj.debit_credit_flag, 'DR',
                               -1 * faadj.adjustment_amount,
                               faadj.adjustment_amount),
                               faadj.adjustment_amount))
        INTO   h_tot_impairment_adj
        FROM   fa_adjustments faadj
        WHERE  faadj.asset_id = RET.asset_id
        AND    faadj.book_type_code = RET.book
        AND    faadj.source_type_code = 'RETIREMENT'
        AND    faadj.adjustment_type in ('IMPAIR RESERVE', 'IMPAIR EXPENSE')
        AND    faadj.period_counter_created = h_pd_counter
        AND    faadj.transaction_header_id <> RET.th_id_in
        GROUP BY faadj.asset_id;
      EXCEPTION
        When others then
                null;
      END;
    else
      BEGIN
      SELECT SUM(DECODE(faadj.adjustment_type, 'IMPAIR RESERVE',
                               DECODE(faadj.debit_credit_flag, 'DR',
                               -1 * faadj.adjustment_amount,
                               faadj.adjustment_amount),
                               faadj.adjustment_amount))
        INTO   h_tot_impairment_adj
        FROM   fa_mc_adjustments faadj
        WHERE  faadj.asset_id = RET.asset_id
        AND    faadj.book_type_code = RET.book
        AND    faadj.source_type_code = 'RETIREMENT'
        AND    faadj.adjustment_type in ('IMPAIR RESERVE', 'IMPAIR EXPENSE')
        AND    faadj.period_counter_created = h_pd_counter
        AND    faadj.set_of_books_id = ret.set_of_books_id
        AND    faadj.transaction_header_id <> RET.th_id_in
        GROUP BY faadj.asset_id;
      EXCEPTION
        When others then
                null;
      END;
    end if;

    if p_log_level_rec.statement_level then
          fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'reval reserve (at Retirement)',
             value   => '');
    end if;

    if (ret.mrc_sob_type_code <> 'R') then
      BEGIN
      SELECT SUM(DECODE(faadj.adjustment_type, 'REVAL RESERVE',
                               DECODE(faadj.debit_credit_flag, 'DR',
                               -1 * faadj.adjustment_amount,
                               faadj.adjustment_amount),
                               -1 * faadj.adjustment_amount))
        INTO   h_tot_reval_adj
        FROM   fa_adjustments faadj
        WHERE  faadj.asset_id = RET.asset_id
        AND    faadj.book_type_code = RET.book
        AND    faadj.source_type_code = 'RETIREMENT'
        AND    faadj.adjustment_type in ('REVAL RESERVE', 'REVAL AMORT')
        AND    faadj.period_counter_created = h_pd_counter
        AND    faadj.transaction_header_id <> RET.th_id_in
        GROUP BY faadj.asset_id;
      EXCEPTION
        When others then
                null;
      END;
    else
      BEGIN
      SELECT SUM(DECODE(faadj.adjustment_type, 'REVAL RESERVE',
                               DECODE(faadj.debit_credit_flag, 'DR',
                               -1 * faadj.adjustment_amount,
                               faadj.adjustment_amount),
                               -1 * faadj.adjustment_amount))
        INTO   h_tot_reval_adj
        FROM   fa_mc_adjustments faadj
        WHERE  faadj.asset_id = RET.asset_id
        AND    faadj.book_type_code = RET.book
        AND    faadj.source_type_code = 'RETIREMENT'
        AND    faadj.adjustment_type in ('REVAL RESERVE', 'REVAL AMORT')
        AND    faadj.period_counter_created = h_pd_counter
        AND    faadj.set_of_books_id = ret.set_of_books_id
        AND    faadj.transaction_header_id <> RET.th_id_in
        GROUP BY faadj.asset_id;
      EXCEPTION
        When others then
                null;
      END;
    end if;

    startpd :=  h_rpdnum;
    rsv := h_deprn_reserve + h_tot_deprn_adj;
    bonus_rsv := h_bonus_deprn_reserve + h_tot_bonus_deprn_adj;
    impairment_rsv := h_impairment_reserve + h_tot_impairment_adj;
    reval_rsv := h_reval_reserve + h_tot_reval_adj;

    return(TRUE);

  Exception

   when others then
            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;

 END;  -- fagirv

/*============================================================================
| NAME        fagict_adj
|
| FUNCTION    debit the cost account by the adjustments amount occured between
|             retirement and reinstatement.
|
| History     SKCHAWLA          04/18/06         Created
|                               added for the bug 4898842
|===========================================================================*/


Function FAGICT_ADJ(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        cpd_ctr IN NUMBER,
        today IN DATE,
        user_id IN NUMBER,
        p_asset_fin_rec_new FA_API_TYPES.asset_fin_rec_type
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS


    h_adj_type          varchar2(16);
    h_source_type_code  varchar2(16);
    h_dist_id           number;
    h_ccid              number;
    h_misc_cost         number;
    h_asset_id          number;
    h_th_id_out         number;
    X_LAST_UPDATE_DATE  date := sysdate;
    X_last_updated_by   number := -1;
    X_last_update_login number := -1;
    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagict_adj';
    h_th_id             number;
    h_dr_cr             varchar2(3);
    h_units_assign      number;
    h_bk_cost           number;
    H_ADJ_AMT          NUMBER;

    process_term_dist   number := 0;
    adj_row  fa_adjust_type_pkg.fa_adj_row_struct;
    fagict_adj_error     EXCEPTION;

    CURSOR TERM_DIST IS
       SELECT distribution_id
       FROM   fa_distribution_history
       WHERE  book_type_code = ret.book
         and  asset_id = ret.asset_id
         and  transaction_header_id_out = h_th_id_out;

BEGIN
    h_th_id_out := -1;

    adj_row.selection_thid := h_th_id_out ;

    if(ret.mrc_sob_type_code <> 'R')then
        select transaction_header_id_out
        into h_th_id_out
        from fa_retirements
        where retirement_id = ret.retirement_id;
    else
        select transaction_header_id_out
        into h_th_id_out
        from fa_mc_retirements
        where retirement_id = ret.retirement_id
          and set_of_books_id = ret.set_of_books_id;
    END IF;


    adj_row.selection_thid := h_th_id_out ;
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'h_th_id_out ###------',
             value   =>h_th_id_out, p_log_level_rec => p_log_level_rec);

    if(h_th_id_out is null) or (h_th_id_out < 0)then
       return TRUE;
    end if;


    adj_row.gen_ccid_flag := TRUE;
    adj_row.book_type_code  :=  RET.book;

    adj_row.asset_id := RET.asset_id;

    adj_row.period_counter_adjusted := cpd_ctr;
    adj_row.period_counter_created := cpd_ctr;
    adj_row.last_update_date := today;
    adj_row.adjustment_amount := 0;
    adj_row.account := NULL;
    adj_row.account_type := NULL;

    adj_row.selection_thid := 0;

    adj_row.distribution_id :=  0;
    adj_row.gen_ccid_flag := TRUE;
    adj_row.code_combination_id := 0;
    adj_row.current_units := bk.cur_units;

    adj_row.transaction_header_id := h_th_id_out;
    adj_row.selection_thid := h_th_id_out ;

         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'books units------',
             value   =>bk.cur_units, p_log_level_rec => p_log_level_rec);
  OPEN TERM_DIST;
  LOOP
     FETCH TERM_DIST
     INTO h_dist_id;
     EXIT WHEN TERM_DIST%NOTFOUND OR TERM_DIST%NOTFOUND IS NULL;
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'books units------11111',
             value   =>bk.cur_units, p_log_level_rec => p_log_level_rec);
     if(ret.mrc_sob_type_code <> 'R')then
        SELECT SUM(DECODE(DEBIT_CREDIT_FLAG,'DR',ADJUSTMENT_AMOUNT,-1*ADJUSTMENT_AMOUNT)),
            max(CODE_COMBINATION_ID),
            max(ADJUSTMENT_TYPE),
            max(SOURCE_TYPE_CODE),
            max(TRANSACTION_HEADER_ID)
        INTO H_MISC_COST,
          h_ccid,
          h_adj_type,
          h_source_type_code,
          h_th_id
        FROM FA_ADJUSTMENTS
        WHERE ASSET_ID = RET.ASSET_id
        and book_type_code = ret.book
        and distribution_id = h_dist_id
        AND adjustment_type in ('COST', 'CIP COST')
        group by distribution_id;
     else
        SELECT SUM(DECODE(DEBIT_CREDIT_FLAG,'DR',ADJUSTMENT_AMOUNT,-1*ADJUSTMENT_AMOUNT)),
            max(CODE_COMBINATION_ID),
            max(ADJUSTMENT_TYPE),
            max(SOURCE_TYPE_CODE),
            max(TRANSACTION_HEADER_ID)
        INTO H_MISC_COST,
          h_ccid,
          h_adj_type,
          h_source_type_code,
          h_th_id
        FROM fa_mc_adjustments
        WHERE ASSET_ID = RET.ASSET_id
        and book_type_code = ret.book
        and distribution_id = h_dist_id
        and set_of_books_id = ret.set_of_books_id
        AND adjustment_type in ('COST', 'CIP COST')
        group by distribution_id;
     END IF;
     process_term_dist := process_term_dist + 1;

     adj_row.code_combination_id := h_ccid;
     adj_row.distribution_id :=  h_dist_id;
     adj_row.debit_credit_flag := 'CR';
     adj_row.adjustment_type := h_adj_type;
     adj_row.source_type_code := 'RETIREMENT';

     if(RET.wip_asset > 0)then
       adj_row.account_type := 'CIP_COST_ACCT';
       adj_row.account := fa_cache_pkg.fazccb_record.CIP_COST_ACCT;

     else
       adj_row.account_type := 'ASSET_COST_ACCT';
       adj_row.account := fa_cache_pkg.fazccb_record.ASSET_COST_ACCT;
     end if;

     adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR_PARTIAL;
     adj_row.adjustment_amount := 0;
     adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
     adj_row.set_of_books_id := ret.set_of_books_id;
     if p_log_level_rec.statement_level then
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'before clear',
             value   => '', p_log_level_rec => p_log_level_rec);
     END if;
     if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                               X_last_update_date,
                               X_last_updated_by,
                               X_last_update_login, p_log_level_rec => p_log_level_rec)) then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return(false);

     end if;
     if p_log_level_rec.statement_level then
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'after clear',
             value   => '', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'TERM h_dist_id ++$$$$$++',
             value   => h_dist_id);
     END if;

     adj_row.debit_credit_flag := 'DR';
     adj_row.adjustment_type := h_adj_type;
     adj_row.source_type_code := 'RETIREMENT';

     if(RET.wip_asset > 0)then
       adj_row.account_type := 'CIP_COST_ACCT';
       adj_row.account := fa_cache_pkg.fazccb_record.CIP_COST_ACCT;

     else

       adj_row.account_type := 'ASSET_COST_ACCT';
       adj_row.account := fa_cache_pkg.fazccb_record.ASSET_COST_ACCT;
     end if;

     adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE_PARTIAL;

     adj_row.adjustment_amount := adj_row.amount_inserted;

     adj_row.mrc_sob_type_code := ret.mrc_sob_type_code;
     adj_row.set_of_books_id := ret.set_of_books_id;
     if p_log_level_rec.statement_level then
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'before clear',
             value   => '', p_log_level_rec => p_log_level_rec);
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'h_misc_cost ++$$$$$++1',
             value   => h_misc_cost);
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'bk.current_cost ++$$$$$++1',
             value   => bk.current_cost);
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'h_dist_id ++$$$$$++1',
             value   => h_dist_id);
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'h_units_assign ++$$$$$++1',
             value   => h_units_assign);
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'bk.cur_units ++$$$$$++1',
             value   => bk.cur_units);
         fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'adj_row.adjustment_amount ###1',
             value   => adj_row.adjustment_amount, p_log_level_rec => p_log_level_rec);
     END if;
     if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                               X_last_update_date,
                               X_last_updated_by,
                               X_last_update_login, p_log_level_rec => p_log_level_rec)) then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return(false);
     END if;
     adj_row.adjustment_type := 'RESERVE';
     adj_row.debit_credit_flag := 'DR';
     adj_row.account_type := 'DEPRN_RESERVE_ACCT';
     adj_row.account :=  fa_cache_pkg.fazccb_record.DEPRN_RESERVE_ACCT;

     adj_row.selection_mode := fa_std_types.FA_AJ_CLEAR_PARTIAL;

     adj_row.adjustment_amount := 0;

     if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                               X_last_update_date,
                               X_last_updated_by,
                               X_last_update_login, p_log_level_rec => p_log_level_rec)) then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return(false);

     end if;
     adj_row.debit_credit_flag := 'CR';
     adj_row.adjustment_amount := adj_row.amount_inserted;
     adj_row.selection_mode := fa_std_types.FA_AJ_ACTIVE_PARTIAL;
     if (NOT FA_INS_ADJUST_PKG.faxinaj(adj_row,
                               X_last_update_date,
                               X_last_updated_by,
                               X_last_update_login, p_log_level_rec => p_log_level_rec)) then

            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return(false);

     end if;
  END LOOP;
  CLOSE TERM_DIST;

  return TRUE;
EXCEPTION

    when fagict_adj_error then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;


    when others then

            fa_srvr_msg.add_sql_error(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
            return FALSE;


END;

/*=============================================================================
|  NAME         fagrin                                                        |
|                                                                             |
|  FUNCTION     This function is called when we reinstate a retirement.       |
|                                                                             |
|============================================================================*/

Function FAGRIN(
        RET IN OUT NOCOPY fa_ret_types.ret_struct,
        BK  IN OUT NOCOPY fa_ret_types.book_struct,
        DPR IN OUT NOCOPY fa_std_types.dpr_struct,
        today IN DATE,
        cpd_ctr IN NUMBER,
        cpdnum IN NUMBER,
        user_id IN NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean IS

    start_pd            Number;
    deprn_amt           Number;
    bonus_deprn_amt     number;
    impairment_amt      number;
    reval_deprn_amt     Number;
    reval_amort_amt     Number;
    deprn_reserve       Number;
    bonus_deprn_reserve number;
    impairment_reserve  number;
    reval_reserve       Number;
/*** Declare prior_fy_exp to get data from fagirv. ***/
    prior_fy_exp        number;
    ytd_deprn           number;

    cost_frac           Number;

    l_asset_fin_rec_new  FA_API_TYPES.asset_fin_rec_type;
    l_deprn_exp         NUMBER;
    l_bonus_deprn_exp   NUMBER;
    l_impairment_exp    NUMBER;
    l_decision_flag     BOOLEAN; -- Bug 6660490

    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.fagrin';
    --bug6853328
    l_reserve_ret number;
    l_dpr         FA_STD_TYPES.FA_DEPRN_ROW_STRUCT;
    l_status      BOOLEAN;
    l_exp_ret number;
    --Added for 8651843
    l_cur_grp_id NUMBER :=0 ;
    --End for 8651843
 BEGIN <<FAGRIN>>

    if p_log_level_rec.statement_level then
      fa_debug_pkg.add
         (fname   => l_calling_fn,
          element => '+++ FAGRIN: Step 1',
          value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    deprn_amt           := 0;
    bonus_deprn_amt     := 0;
    impairment_amt      := 0;
    reval_deprn_amt     := 0;
    reval_amort_amt     := 0;
    deprn_reserve       := 0;
    bonus_deprn_reserve := 0;
    impairment_reserve  := 0;
    reval_reserve       := 0;

--Added for 8651843
BEGIN
IF (ret.mrc_sob_type_code <> 'R') THEN
   SELECT group_asset_id
     INTO l_cur_grp_id
     FROM fa_books
    WHERE asset_id = ret.asset_id
      AND book_type_code = ret.book
      AND transaction_header_id_out IS NULL;
ELSE

   SELECT group_asset_id
     INTO l_cur_grp_id
     FROM fa_mc_books
    WHERE asset_id = ret.asset_id
      AND book_type_code = ret.book
         AND set_of_books_id = ret.set_of_books_id
      AND transaction_header_id_out IS NULL;
END IF;

EXCEPTION
WHEN OTHERS THEN
   l_cur_grp_id := NULL;
END;

IF p_log_level_rec.statement_level THEN
   fa_debug_pkg.add(l_calling_fn, 'in fagrin group asset id', l_cur_grp_id, p_log_level_rec => p_log_level_rec);
END IF;

IF l_cur_grp_id IS NOT NULL THEN
   bk.group_asset_id := l_cur_grp_id;
END IF;
--End of addition 8651843

/*** Initialize prior_fy_exp ***/
    prior_fy_exp := 0;
    ytd_deprn := 0;
    cost_frac           :=  0;

    if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagrin 1', '', p_log_level_rec => p_log_level_rec); end if;
-- bug 5008040
--    if ( bk.current_cost is NULL or bk.current_cost <= 0) then

    if ( bk.current_cost is NULL or bk.current_cost = 0) then
        cost_frac := 0;
    else
        cost_frac :=  ret.cost_retired / bk.current_cost;

        -- Fix for Bug 3172944. Do not round cost_frac
        -- Call faxrnd to round cost_frac in fagrin
        --if not FA_UTILS_PKG.faxrnd(cost_frac, ret.book, p_log_level_rec => p_log_level_rec) then
        --   fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
        --   return(FALSE);
        --end if;
    end if;

    if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagrin 2', '', p_log_level_rec => p_log_level_rec); end if;
/* bg344494 base 334428, re-added in the afmround function. Should have been
 * added in version 75.20 but seems to have disappered. Readding
 */

    /* If it's capitalize and also depreciate, then we know that when we did
       the retirement we calculate depreciation; Thus, we need to readjust it.
       Otherwise, we will skip it.
    */
    -- Bug 6660490 for extended assets bk.fully_extended needs
    -- to be used instead of bk.fully_reserved

    -- Bug 8211842 : Check if asset has started extended depreciation
    if bk.extended_flag and bk.start_extended then
       l_decision_flag := bk.fully_extended;
    else
       l_decision_flag := bk.fully_reserved;
    end if;

    if (bk.capitalize AND bk.depreciate AND
                (ret.wip_asset is null or ret.wip_asset <= 0)) then

        if ( NOT l_decision_flag) then

            if ( NOT fagirv(ret, start_pd, deprn_reserve,
                            bonus_deprn_reserve, impairment_reserve,
                            reval_reserve,
                            prior_fy_exp, ytd_deprn,
                            p_log_level_rec)) then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);
            end if;

            if p_log_level_rec.statement_level then
               fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'after fagirv:deprn_reserve',
                 value   => deprn_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'after fagirv:bonus_deprn_reserve',
                 value   => bonus_deprn_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'after fagirv:impairment_reserve',
                 value   => impairment_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'after fagirv:reval_reserve',
                 value   => reval_reserve, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'after fagirv:prior_fy_exp',
                 value   => prior_fy_exp, p_log_level_rec => p_log_level_rec);
               fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'after fagirv:ytd_deprn',
                 value   => ytd_deprn, p_log_level_rec => p_log_level_rec);
            end if;


            dpr.prior_fy_exp := prior_fy_exp;
            dpr.ytd_deprn := ytd_deprn;

            dpr.jdate_retired :=  0;

            /* 1012866. Ret_prorate_jdate cannot be zero. Julian date has to
            be > 0. I am getting the jdate from the books prorate date */

            --dpr.ret_prorate_jdate := 0;
            dpr.ret_prorate_jdate := to_char(bk.ret_prorate_date,'J');

            deprn_amt           := 0;
            bonus_deprn_amt     := 0;
            impairment_amt      := 0;
            reval_deprn_amt             := 0;
            reval_amort_amt             := 0;


            --
            -- Following deprn amount calculation is done only if this standalone
            -- asset or member asset which group has CALCULATE tracking method.

            if (start_pd < cpdnum) and
               (not((bk.group_asset_id is not null) and
                     nvl(bk.tracking_method, 'ALLOCATE') = 'ALLOCATE'))  then

                dpr.deprn_rsv :=  deprn_reserve;
                dpr.bonus_deprn_rsv := bonus_deprn_reserve;
                dpr.impairment_rsv := impairment_reserve;
                dpr.reval_rsv :=  reval_reserve;

                dpr.rsv_known_flag := TRUE;

                -- Bug:6349882
                dpr.transaction_type_code := 'REINSTATEMENT';

                if p_log_level_rec.statement_level then fa_debug_pkg.add(l_calling_fn, 'in fagrin 3', '', p_log_level_rec => p_log_level_rec); end if;


                --Bug5887343 Added retirement_id
                if (NOT FA_GAINLOSS_DPR_PKG.fagcdp(
                        dpr,
                        deprn_amt,
                        bonus_deprn_amt,
                        impairment_amt,
                        reval_deprn_amt,
                        reval_amort_amt,
                        bk.deprn_start_date,
                        bk.d_cal, bk.p_cal,
                        start_pd,
                        cpdnum - 1,
                        bk.prorate_fy,
                        bk.dsd_fy,
                        bk.prorate_jdate,
                        bk.deprn_start_jdate,
                        ret.retirement_id,
                        p_log_level_rec) )  then

                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);

                end if;

                --bug6853328 starts
                --Added the call to query balances to get the current reserve
                --without including the values from adjustments
                l_dpr.asset_id   := ret.asset_id;
                l_dpr.book       := ret.book;
                l_dpr.period_ctr := 0;
                l_dpr.dist_id    := 0;
                l_dpr.mrc_sob_type_code := ret.mrc_sob_type_code;
                l_dpr.set_of_books_id := ret.set_of_books_id;

                fa_query_balances_pkg.query_balances_int(
                X_DPR_ROW               => l_dpr,
                X_RUN_MODE              => 'STANDARD',
                X_DEBUG                 => FALSE,
                X_SUCCESS               => l_status,
                X_CALLING_FN            => 'FA_GAINLOSS_UND_PKG.fagrin',
                X_TRANSACTION_HEADER_ID => -1, p_log_level_rec => p_log_level_rec);

                if (NOT l_status) then
                return(FALSE);
                end if;

             IF (ret.mrc_sob_type_code <> 'R') THEN
                select sum(decode(debit_credit_flag, 'CR', -1, 1) * adjustment_amount)
                into   l_reserve_ret
                from   fa_adjustments
                where  asset_id = ret.asset_id
                and    book_type_code = ret.book
                and    source_type_code = 'RETIREMENT'
                and    adjustment_type = 'RESERVE'
                and    transaction_header_id = ret.th_id_in;
             ELSE
                select sum(decode(debit_credit_flag, 'CR', -1, 1) * adjustment_amount)
                into   l_reserve_ret
                from   fa_mc_adjustments
                where  asset_id = ret.asset_id
                and    book_type_code = ret.book
                and    source_type_code = 'RETIREMENT'
                and    adjustment_type = 'RESERVE'
                and    transaction_header_id = ret.th_id_in
                and    set_of_books_id = ret.set_of_books_id;
             END IF;

                -- Bug # 7184690,7199183 added below sql
             IF (ret.mrc_sob_type_code <> 'R') THEN
                select nvl(sum(decode(debit_credit_flag, 'DR', adjustment_amount, -adjustment_amount)), 0)
                into l_exp_ret
                from   fa_adjustments
                where  asset_id = ret.asset_id
                and    book_type_code = ret.book
                and    source_type_code = 'RETIREMENT'
                and    adjustment_type = 'EXPENSE'
                and    transaction_header_id = ret.th_id_in;
             ELSE
                select nvl(sum(decode(debit_credit_flag, 'DR', adjustment_amount, -adjustment_amount)), 0)
                into l_exp_ret
                from   fa_mc_adjustments
                where  asset_id = ret.asset_id
                and    book_type_code = ret.book
                and    source_type_code = 'RETIREMENT'
                and    adjustment_type = 'EXPENSE'
                and    transaction_header_id = ret.th_id_in
                and    set_of_books_id = ret.set_of_books_id;
             END IF;

                -- Bug # 7184690,7199183
                --Changed the deprn_amt calculation so that penny differences are removed
                fa_debug_pkg.add (l_calling_fn, '+++dpr.deprn_rsv (from fagcdp)', dpr.deprn_rsv);
                fa_debug_pkg.add (l_calling_fn, '+++l_reserve_ret (from fagcdp)', l_reserve_ret);
                fa_debug_pkg.add (l_calling_fn, '+++l_exp_ret (from fagcdp)', l_exp_ret);
                fa_debug_pkg.add (l_calling_fn, '+++deprn_amt (from fagcdp)', deprn_amt);
                fa_debug_pkg.add (l_calling_fn, '+++l_dpr.deprn_rsv (from fagcdp)', l_dpr.deprn_rsv);
                deprn_amt := (dpr.deprn_rsv -  l_reserve_ret + l_exp_ret + deprn_amt ) - l_dpr.deprn_rsv;

                 -- deprn_amt := cost_frac * deprn_amt ;
                 --bug6853328 ends

                bonus_deprn_amt := cost_frac * bonus_deprn_amt ;
                impairment_amt := cost_frac * impairment_amt;
                reval_deprn_amt := cost_frac * reval_deprn_amt;
                reval_amort_amt :=  cost_frac * reval_amort_amt;

                if p_log_level_rec.statement_level then
                  fa_debug_pkg.add (l_calling_fn, '++++++++++++++++++++++++++++++ BEGIN fagcpd', '...', p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add (l_calling_fn, '+++ start_pd', start_pd, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add (l_calling_fn, '+++ cpdnum', cpdnum, p_log_level_rec => p_log_level_rec);
                  fa_debug_pkg.add (l_calling_fn, '+++ deprn_amt (from fagcdp)', deprn_amt);
                  fa_debug_pkg.add (l_calling_fn, '+++ dpr.deprn_rsv (from fagcdp)', dpr.deprn_rsv);
                  fa_debug_pkg.add (l_calling_fn, '++++++++++++++++++++++++++++++ END fagcpd', '...', p_log_level_rec => p_log_level_rec);
                end if;

            else
               if p_log_level_rec.statement_level then
                  fa_debug_pkg.add
                         (fname   => l_calling_fn,
                          element => 'Skipping to call FA_GAINLOSS_DPR_PKG.fagcdp',
                          value   => bk.tracking_method, p_log_level_rec => p_log_level_rec);
               end if;
            end if;

        end if;

        if (not FA_GAINLOSS_DPR_PKG.CALC_CATCHUP(
                              ret                  => ret,
                              BK                   => bk,
                              DPR                  => dpr,
                              calc_catchup         => (start_pd < cpdnum),
                              x_deprn_exp          => l_deprn_exp,
                              x_bonus_deprn_exp    => l_bonus_deprn_exp,
                              x_impairment_exp     => l_impairment_exp,
                              x_asset_fin_rec_new  => l_asset_fin_rec_new,
                              p_log_level_rec      => p_log_level_rec)) then

                    fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                    return(FALSE);

        end if;

        /*
         * In order to use the catchup expense from CALC_CATCHUP
         * it requires to change cursor in faraje which we don't want to do for now
         *

        deprn_amt := cost_frac * nvl(l_deprn_exp, 0);
        bonus_deprn_amt := cost_frac * nvl(l_bonus_deprn_exp, 0);
        impairment_amt := cost_frac * nvl(l_impairment_exp, 0);
        */

        if p_log_level_rec.statement_level then
           fa_debug_pkg.add (l_calling_fn, '+++ Values from CALC_CATCHUP wil replace', 'amounts from faxcde', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ l_deprn_exp', l_deprn_exp, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ l_bonus_deprn_exp', l_bonus_deprn_exp, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ cost_frac', cost_frac, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ NEW deprn_amt', deprn_amt, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ NEW bonue_deprn_amt', bonus_deprn_amt, p_log_level_rec => p_log_level_rec);
        end if;
        /*
         *
         *
         */


        if ( NOT fagidn( ret,
                     bk,
                     deprn_amt,
                     bonus_deprn_amt,
                     impairment_amt,
                     reval_deprn_amt,
                     reval_amort_amt,
                     cpd_ctr,
                     today,
                     user_id,
                     p_log_level_rec) )  then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

        end if;

     else -- no call to calcualte catch
        dpr.prior_fy_exp := prior_fy_exp;
        dpr.ytd_deprn := ytd_deprn;
        dpr.jdate_retired :=  0;

        -- 1012866. Ret_prorate_jdate cannot be zero. Julian date has to
        -- be > 0. I am getting the jdate from the books prorate date
        dpr.ret_prorate_jdate := to_char(bk.ret_prorate_date,'J');

        deprn_amt           := 0;
        bonus_deprn_amt     := 0;
        impairment_amt      := 0;
        reval_deprn_amt             := 0;
        reval_amort_amt             := 0;


        --
        -- Following deprn amount calculation is done only if this standalone
        -- asset or member asset which group has CALCULATE tracking method.
-- Bug 7486861 Begin
        if (not((bk.group_asset_id is not null) and
                nvl(bk.tracking_method, 'ALLOCATE') = 'ALLOCATE'))  then
           dpr.calc_catchup := TRUE;
        else
           dpr.calc_catchup := FALSE;
        end if;

-- Bug 7486861 End
        --
        -- These depreciation amounts are not important since all we care is
        -- financial information
        --
        dpr.deprn_rsv :=  0;
        dpr.bonus_deprn_rsv := 0;
        dpr.impairment_rsv := 0;
        dpr.reval_rsv :=  0;
        dpr.rsv_known_flag := TRUE;

        if (not FA_GAINLOSS_DPR_PKG.CALC_CATCHUP(
                           ret                  => ret,
                           BK                   => bk,
                           DPR                  => dpr,
                           calc_catchup         => dpr.calc_catchup, -- Bug 7486861
                           x_deprn_exp          => l_deprn_exp,
                           x_bonus_deprn_exp    => l_bonus_deprn_exp,
                           x_impairment_exp     => l_impairment_exp,
                           x_asset_fin_rec_new  => l_asset_fin_rec_new, p_log_level_rec => p_log_level_rec)) then
            fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           return(FALSE);

        end if;

        if p_log_level_rec.statement_level then
           fa_debug_pkg.add (l_calling_fn, '+++ ELSE PART: Values from CALC_CATCHUP','...', p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ l_deprn_exp', l_deprn_exp, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ l_bonus_deprn_exp', l_bonus_deprn_exp, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ cost_frac', cost_frac, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ NEW deprn_amt', deprn_amt, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, '+++ NEW bonue_deprn_amt', bonus_deprn_amt, p_log_level_rec => p_log_level_rec);
        end if;

        deprn_amt := l_deprn_exp;
        bonus_deprn_amt := l_bonus_deprn_exp;
        impairment_amt := l_impairment_exp;
        reval_deprn_amt := 0;
        reval_amort_amt := 0;

        if p_log_level_rec.statement_level then
           fa_debug_pkg.add (l_calling_fn, 'l_asset_fin_rec_new.adjusted_cost (+ +)', l_asset_fin_rec_new.adjusted_cost);
           fa_debug_pkg.add (l_calling_fn, 'l_asset_fin_rec_new.rate_adjustment_factor',
                                            l_asset_fin_rec_new.rate_adjustment_factor, p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add (l_calling_fn, 'l_asset_fin_rec_new.formula_factor', l_asset_fin_rec_new.formula_factor, p_log_level_rec => p_log_level_rec);
        end if;

        if ( NOT fagidn( ret,
                     bk,
                     deprn_amt,
                     bonus_deprn_amt,
                     impairment_amt,
                     reval_deprn_amt,
                     reval_amort_amt,
                     cpd_ctr,
                     today,
                     user_id,
                     p_log_level_rec) )  then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

        end if;

     end if;

     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 5 ...',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;

     if ((ret.wip_asset is null) or (ret.wip_asset <= 0))  then

        if( NOT fagiav( ret,
                        bk,
                        cpd_ctr,
                        today,
                        user_id,
                        p_log_level_rec) ) then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

        end if;

     end if;

     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 6',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;

     if (NOT fagict(ret,
                     bk,
                     cpd_ctr,
                     today,
                     user_id,
                     p_log_level_rec)) then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

     end if;

     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 7',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;

     -- insert a new book row with adjusted_cost and cost = l_asset_fin_rec_new.adjusted_cost and cost respectively
     if (NOT fagiat(ret,
                    user_id,
                    cpd_ctr,
                    today,
                    l_asset_fin_rec_new,
                    p_log_level_rec )) then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

     end if;
     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 7 before fagict_adj',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;
 /*added for the bug 4898842 */

/* need more investigation
     if (NOT FAGICT_ADJ(
                        RET ,
                        BK  ,
                        cpd_ctr ,
                        today ,
                        user_id,
                        l_asset_fin_rec_new))then
                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

     end if;
*/
     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 7 after fagict_adj',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;


     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 8',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;

   -- modified the call to  fagtax such that it will be called only once for bug no.3831503
   if(ret.mrc_sob_type_code<>'R') then
     if (NOT fagtax(ret,
                       bk,
                       today,
                       p_log_level_rec))  then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

     end if;
   end if; --ret.mrc_sob_type_code<>'R'
     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 9',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;

     if (NOT fagiar(ret,
                        bk,
                        cpd_ctr,
                        user_id,
                        today,
                        p_log_level_rec )) then

                fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                return(FALSE);

     end if;

     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 10',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;

     if (bk.group_asset_id is not null) then
        -- +++++ Process Group Asse +++++
        if not FA_RETIREMENT_PVT.Do_Reinstatement_in_CGL(
                  p_ret               => ret,
                  p_bk                => bk,
                  p_dpr               => dpr,
                  p_mrc_sob_type_code => ret.mrc_sob_type_code,
                  p_calling_fn        => l_calling_fn, p_log_level_rec => p_log_level_rec) then
           fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
           return false;
        end if;
     end if; -- (bk.group_asset_id is not null)

     if p_log_level_rec.statement_level then
       fa_debug_pkg.add
          (fname   => l_calling_fn,
           element => '+++ Step 11',
           value   => '', p_log_level_rec => p_log_level_rec);
     end if;

     return(true);

END;  -- fagrin

/* Added for bug 7396397 */
  function process_adj_table(p_mode IN VARCHAR2, RET IN fa_ret_types.ret_struct,
                               BK  IN fa_ret_types.book_struct,
                               p_tbl_adj IN OUT NOCOPY tbl_adj,
                               p_tbl_ret IN OUT NOCOPY tbl_ret,
                               p_tbl_cost_ret IN OUT NOCOPY tbl_cost_ret,
                               p_tbl_adj_final IN OUT NOCOPY tbl_final_adj, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) return boolean is
    l_final_ind number := p_tbl_adj_final.count;
    l_calling_fn        varchar2(40) := 'FA_GAINLOSS_UND_PKG.pradjtbl';
    l_asset_id fa_books.asset_id%type;

    /* Cursor of all active distributions */
    cursor c_active_dist is
    select distribution_id,
           code_combination_id,
           units_assigned
    from   fa_distribution_history
    where  asset_id = l_asset_id
    and    date_ineffective is null
    order by distribution_id;

    type tbl_active_dist is table of c_active_dist%rowtype index by BINARY_INTEGER;
    l_tbl_active_dist tbl_active_dist;
    l_total_active_dist number :=0;

  Begin

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'Entered with mode',
             value   => p_mode, p_log_level_rec => p_log_level_rec);

       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'BK.dis_book',
             value   => BK.dis_book, p_log_level_rec => p_log_level_rec);

       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'ret.th_id_in',
             value   => ret.th_id_in, p_log_level_rec => p_log_level_rec);

       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'ret.th_id_in',
             value   => ret.th_id_in, p_log_level_rec => p_log_level_rec);

       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'p_tbl_adj.count',
             value   => p_tbl_adj.count, p_log_level_rec => p_log_level_rec);

       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'p_tbl_ret.count',
             value   => p_tbl_ret.count, p_log_level_rec => p_log_level_rec);

       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'p_tbl_cost_ret.count',
             value   => p_tbl_cost_ret.count, p_log_level_rec => p_log_level_rec);

       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'ret.units_retired',
             value   => ret.units_retired, p_log_level_rec => p_log_level_rec);

    end if;

    if (p_log_level_rec.statement_level) then
       fa_debug_pkg.add
            (fname   => l_calling_fn,
             element => 'entering retirement table loop',
             value   => '', p_log_level_rec => p_log_level_rec);
    end if;

    if ( (nvl(ret.units_retired,0) > 0 ) and (p_mode <> 'GROUP')) then
        for j in 1..p_tbl_adj.count
        loop
        declare
          bln_qry_bal boolean;
          l_dummy_dum number;
          l_dummy_char varchar2(4000);

        begin

          if (p_log_level_rec.statement_level) then
             fa_debug_pkg.add
                  (fname   => l_calling_fn,
                   element => 'Calling query balance for dist_id',
                   value   => p_tbl_adj(j).distribution_id);
          end if;


          FA_QUERY_BALANCES_PKG.QUERY_BALANCES
          (X_ASSET_ID => ret.asset_id,
           X_BOOK     => bk.dis_book,
           X_PERIOD_CTR  => 0,
           X_DIST_ID  => p_tbl_adj(j).distribution_id,
           X_RUN_MODE => 'STANDARD',
           X_COST     => p_tbl_adj(j).cost,
           X_DEPRN_RSV =>p_tbl_adj(j).DEPRN_RSV,
           X_REVAL_RSV => p_tbl_adj(j).REVAL_RSV,
           X_YTD_DEPRN  =>l_dummy_dum,
           X_YTD_REVAL_EXP =>l_dummy_dum,
           X_REVAL_DEPRN_EXP =>l_dummy_dum,
           X_DEPRN_EXP =>l_dummy_dum,
           X_REVAL_AMO =>l_dummy_dum,
           X_PROD  =>l_dummy_dum,
           X_YTD_PROD =>l_dummy_dum,
           X_LTD_PROD =>l_dummy_dum,
           X_ADJ_COST =>l_dummy_dum,
           X_REVAL_AMO_BASIS =>l_dummy_dum,
           X_BONUS_RATE =>l_dummy_dum,
           X_DEPRN_SOURCE_CODE =>l_dummy_char,
           X_ADJUSTED_FLAG  => bln_qry_bal,
           X_TRANSACTION_HEADER_ID => -1,
           X_BONUS_DEPRN_RSV => p_tbl_adj(j).BONUS_DEPRN_RSV,
           X_BONUS_YTD_DEPRN => l_dummy_dum,
           X_BONUS_DEPRN_AMOUNT =>l_dummy_dum,
           X_IMPAIRMENT_RSV => p_tbl_adj(j).IMPAIRMENT_RSV,
           X_YTD_IMPAIRMENT => l_dummy_dum,
           X_IMPAIRMENT_AMOUNT =>l_dummy_dum,
           X_capital_adjustment => l_dummy_dum,
           X_general_fund => l_dummy_dum,
           X_mrc_sob_type_code => ret.mrc_sob_type_code,
           X_set_of_books_id => ret.set_of_books_id,
           p_log_level_rec => p_log_level_rec);

          if (p_log_level_rec.statement_level) then
            fa_debug_pkg.add
            (fname   => l_calling_fn,
            element => 'Query balance called for dist_id',
            value   => p_tbl_adj(j).distribution_id);

            fa_debug_pkg.add
            (fname   => l_calling_fn,
            element => 'cost balance',
            value   => p_tbl_adj(j).cost);

            fa_debug_pkg.add
            (fname   => l_calling_fn,
            element => 'Reserve balance',
            value   => p_tbl_adj(j).DEPRN_RSV);

          end if;
          for i in 1..p_tbl_ret.count
          loop
            if (p_tbl_ret(i).code_combination_id = p_tbl_adj(j).code_combination_id
                and p_tbl_ret(i).location_id = p_tbl_adj(j).location_id
                and nvl(p_tbl_ret(i).assigned_to,-99) = nvl(p_tbl_adj(j).assigned_to,-99)
                ) then

                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => 'ret adjustment_amount',
                         value   => p_tbl_ret(i).adjustment_amount);

                   fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => 'found distribution in retirement table',
                         value   => p_tbl_ret(i).distribution_id);

                   fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => 'ret adjustment_type',
                         value   => p_tbl_ret(i).adjustment_type);

                end if;

                declare
                  bln_create_rec boolean;
                  l_old_cost fa_adjustments.adjustment_amount%type;
                  l_new_cost fa_adjustments.adjustment_amount%type;
                  l_dr_cr_bal VARCHAR2(2);
                  l_rev_dr_cr_bal VARCHAR2(2);
                begin
                  l_old_cost := 0;
                  l_new_cost := 0;
                  p_tbl_adj(j).retire_rec_found := 'Y';
                  if (p_tbl_ret(i).adjustment_type = 'COST') then
                    l_old_cost := p_tbl_adj(j).cost;
                    l_dr_cr_bal := 'DR';
                    l_rev_dr_cr_bal := 'CR';
                  elsif (p_tbl_ret(i).adjustment_type = 'RESERVE') then
                    l_old_cost := p_tbl_adj(j).DEPRN_RSV;
                    l_dr_cr_bal := 'CR';
                    l_rev_dr_cr_bal := 'DR';
                  elsif (p_tbl_ret(i).adjustment_type = 'BONUS RESERVE') then
                    l_old_cost := p_tbl_adj(j).BONUS_DEPRN_RSV;
                    l_dr_cr_bal := 'CR';
                    l_rev_dr_cr_bal := 'DR';
                  elsif (p_tbl_ret(i).adjustment_type = 'REVAL RESERVE') then
                    l_old_cost := p_tbl_adj(j).REVAL_RSV;
                    l_dr_cr_bal := 'CR';
                    l_rev_dr_cr_bal := 'DR';
                  elsif (p_tbl_ret(i).adjustment_type = 'IMPAIR RESERVE') then
                    l_old_cost := p_tbl_adj(j).IMPAIRMENT_RSV;
                    l_dr_cr_bal := 'CR';
                    l_rev_dr_cr_bal := 'DR';
                  end if;


                  if (l_old_cost <> 0) then

                    -- Add amount during retirement to adjustment amount
                    select nvl(l_old_cost,0)
                           +
                           decode(p_tbl_ret(i).debit_credit_flag,l_dr_cr_bal, -1*p_tbl_ret(i).adjustment_amount,
                                  p_tbl_ret(i).adjustment_amount)
                    into l_new_cost
                    from dual;
                    p_tbl_ret(i).adj_rec_found := 'Y';
                    l_final_ind := l_final_ind+1;
                    p_tbl_adj_final(l_final_ind).asset_id := ret.asset_id;
                    p_tbl_adj_final(l_final_ind).dist_id := p_tbl_adj(j).distribution_id;
                    p_tbl_adj_final(l_final_ind).ccid := p_tbl_ret(i).adj_ccid;
                    p_tbl_adj_final(l_final_ind).adj_type := p_tbl_ret(i).adjustment_type;
                    p_tbl_adj_final(l_final_ind).cost := l_old_cost;
                    p_tbl_adj_final(l_final_ind).dr_cr := l_rev_dr_cr_bal;

                    if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'contents of p_tbl_adj_final for old cost',
                             value   => '', p_log_level_rec => p_log_level_rec);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).dist_id',
                             value   => p_tbl_adj_final(l_final_ind).dist_id);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).ccid',
                             value   => p_tbl_adj_final(l_final_ind).ccid);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).adj_type',
                             value   => p_tbl_adj_final(l_final_ind).adj_type);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).cost',
                             value   => p_tbl_adj_final(l_final_ind).cost);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).dr_cr',
                             value   => p_tbl_adj_final(l_final_ind).dr_cr);
                    end if;

                  end if;

                  if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => 'Population of old cost into p_tbl_adj_final done',
                         value   => '', p_log_level_rec => p_log_level_rec);
                  end if;

                  if (l_new_cost <> 0) then
                    l_final_ind := l_final_ind+1;
                    p_tbl_adj_final(l_final_ind).asset_id := ret.asset_id;
                    p_tbl_adj_final(l_final_ind).dist_id := p_tbl_ret(i).distribution_id;
                    p_tbl_adj_final(l_final_ind).ccid := p_tbl_ret(i).adj_ccid;
                    p_tbl_adj_final(l_final_ind).adj_type := p_tbl_ret(i).adjustment_type;
                    p_tbl_adj_final(l_final_ind).cost := l_new_cost;
                    p_tbl_adj_final(l_final_ind).dr_cr := l_dr_cr_bal;

                    if (p_log_level_rec.statement_level) then
                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'contents of p_tbl_adj_final for new cost',
                             value   => '', p_log_level_rec => p_log_level_rec);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).dist_id',
                             value   => p_tbl_adj_final(l_final_ind).dist_id);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).ccid',
                             value   => p_tbl_adj_final(l_final_ind).ccid);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).adj_type',
                             value   => p_tbl_adj_final(l_final_ind).adj_type);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).cost',
                             value   => p_tbl_adj_final(l_final_ind).cost);

                       fa_debug_pkg.add
                            (fname   => l_calling_fn,
                             element => 'p_tbl_adj_final(l_final_ind).dr_cr',
                             value   => p_tbl_adj_final(l_final_ind).dr_cr);
                    end if; --p_log_level_rec.statement_level
                  end if;  -- l_new_cost <> 0

                  if (p_log_level_rec.statement_level) then
                    fa_debug_pkg.add
                        (fname   => l_calling_fn,
                         element => 'Population of New cost into p_tbl_adj_final done',
                         value   => '', p_log_level_rec => p_log_level_rec);
                  end if;

                end;
              end if;
            end loop; --p_tbl_ret.count
          Exception
            when others then
              fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
              if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add
                    (fname   => l_calling_fn,
                     element => 'Error occured',
                     value   => SQLERRM, p_log_level_rec => p_log_level_rec);
              end if;

              return false;
          end;
        end loop; -- p_tbl_adj.count

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'Adjustment table loop done',
                 value   => '', p_log_level_rec => p_log_level_rec);
        end if;

        -- Now insert records retirements not having any records in adjustment
        for k in 1..p_tbl_ret.count
        loop
          if (p_tbl_ret(k).adj_rec_found = 'N' and p_tbl_ret(k).adjustment_amount <> 0) then
            l_final_ind := l_final_ind+1;
            p_tbl_adj_final(l_final_ind).asset_id := ret.asset_id;
            p_tbl_adj_final(l_final_ind).dist_id := p_tbl_ret(k).distribution_id;
            p_tbl_adj_final(l_final_ind).ccid := p_tbl_ret(k).adj_ccid;
            p_tbl_adj_final(l_final_ind).adj_type := p_tbl_ret(k).adjustment_type;
            p_tbl_adj_final(l_final_ind).cost := p_tbl_ret(k).adjustment_amount;
            if (p_tbl_ret(k).debit_credit_flag = 'CR') then
              p_tbl_adj_final(l_final_ind).dr_cr := 'DR';
            else
              p_tbl_adj_final(l_final_ind).dr_cr := 'CR';
            end if;
          end if;
        end loop;
    end if;
    /* following will be used in case of cost retirement and for groups */
    if (nvl(ret.units_retired,0) = 0 or (p_mode = 'GROUP')
       ) then

        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add
                (fname   => l_calling_fn,
                 element => 'Entered partial cost retirement scenario',
                 value   => p_tbl_adj.count, p_log_level_rec => p_log_level_rec);
        end if;

      if p_mode = 'GROUP' then
        l_asset_id := bk.group_asset_id;
      else
        l_asset_id := ret.asset_id;
      end if;

      open c_active_dist;
      fetch c_active_dist bulk collect into l_tbl_active_dist;
      close c_active_dist;

      for l in 1..l_tbl_active_dist.count
      loop
        l_total_active_dist := l_total_active_dist+l_tbl_active_dist(l).units_assigned;
      end loop;

      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add
              (fname   => l_calling_fn,
               element => 'total_active_dist',
               value   => l_total_active_dist, p_log_level_rec => p_log_level_rec);
      end if;

      for i in 1..p_tbl_cost_ret.count
      loop
        declare
          l_adj_type_total fa_adjustments.adjustment_amount%type :=0 ;
        begin
          if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add
                    (fname   => l_calling_fn,
                     element => 'adjustment_type',
                     value   =>p_tbl_cost_ret(i).adjustment_type);

               fa_debug_pkg.add
                    (fname   => l_calling_fn,
                     element => 'adjustment_type',
                     value   =>p_tbl_cost_ret(i).adjustment_amount);

          end if;
          for j in 1..l_tbl_active_dist.count
          loop
            if (p_log_level_rec.statement_level) then
               fa_debug_pkg.add
                    (fname   => l_calling_fn,
                     element => 'distribution_id',
                     value   =>l_tbl_active_dist(j).distribution_id);

               fa_debug_pkg.add
                    (fname   => l_calling_fn,
                     element => 'units_assigned',
                     value   =>l_tbl_active_dist(j).units_assigned);

            end if;

              l_final_ind := l_final_ind+1;
              p_tbl_adj_final(l_final_ind).asset_id := l_asset_id;
              p_tbl_adj_final(l_final_ind).dist_id := l_tbl_active_dist(j).distribution_id;
              p_tbl_adj_final(l_final_ind).ccid := p_tbl_cost_ret(i).adj_ccid;
              p_tbl_adj_final(l_final_ind).adj_type := p_tbl_cost_ret(i).adjustment_type;
              p_tbl_adj_final(l_final_ind).dr_cr := p_tbl_cost_ret(i).rev_debit_credit_flag;

              if j < l_tbl_active_dist.count then
                p_tbl_adj_final(l_final_ind).cost := p_tbl_cost_ret(i).adjustment_amount*
                                (l_tbl_active_dist(j).units_assigned/l_total_active_dist);
                if not FA_UTILS_PKG.faxrnd(p_tbl_adj_final(l_final_ind).cost, ret.book, ret.set_of_books_id, p_log_level_rec) then
                  fa_srvr_msg.add_message(calling_fn => l_calling_fn, p_log_level_rec => p_log_level_rec);
                  return(FALSE);
                end if;
                l_adj_type_total := l_adj_type_total + p_tbl_adj_final(l_final_ind).cost;
              else
                p_tbl_adj_final(l_final_ind).cost := p_tbl_cost_ret(i).adjustment_amount - l_adj_type_total;
              end if;
          end loop;
        end;
      end loop;

    end if;
    return true;
end process_adj_table;


END FA_GAINLOSS_UND_PKG;    -- End of Package

/
