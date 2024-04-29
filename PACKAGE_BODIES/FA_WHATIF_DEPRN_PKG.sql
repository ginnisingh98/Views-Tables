--------------------------------------------------------
--  DDL for Package Body FA_WHATIF_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_WHATIF_DEPRN_PKG" as
/* $Header: FAWDPRB.pls 120.21.12010000.4 2009/10/06 10:31:12 anujain ship $ */

function whatif_deprn_asset (
        X_asset_id      in number,
        X_mode          in varchar2,
        X_book          in varchar2,
        X_start_per     in varchar2,
        X_num_pers      in number,
        X_dpis          in date default null,
        X_prorate_date  in date default null,
        X_prorate_conv  in varchar2 default null,
        X_deprn_start_date  in date default null,
        X_ceiling_name  in varchar2 default null,
        X_bonus_rule    in varchar2 default null,
        X_method_code   in varchar2 default null,
        X_cost          in number default null,
        X_old_cost      in number default null,
        X_adj_cost      in number default null,
        X_rec_cost      in number default null,
        X_raf           in number default null,
        X_adj_rate      in number default null,
        X_reval_amo_basis  in number default null,
        X_capacity      in number default null,
        X_adj_capacity  in number default null,
        X_life          in number default null,
        X_adj_rec_cost  in number default null,
        X_salvage_value in number default null,
        X_salvage_pct   in number default null,
        X_category_id   in number default null,
        X_deprn_rnd_flag  in varchar2 default null,
        X_calendar_type in varchar2 default null,
        X_prior_fy_exp  in number default null,
        X_deprn_rsv     in number default null,
        X_reval_rsv     in number default null,
        X_ytd_deprn     in number default null,
        X_ltd_prod      in number default null,
        x_return_status  out nocopy number)
return boolean is

--      Implementation overview:
--      If mode <> HYPOTHETICAL, then asset exists in system and we should
--      select its current state.  Load this state directly into a
--      dpr_in structure.  We will use this structure as a repository
--      for this information throughout this function.
--      If mode = HYPOTHETICAL, then the "current state" had to be passed
--      into this function.  Load dpr_in with these parameters.
--
--      Then, if mode = EXPENSED or AMORTIZED, load a fin_info structure.
--      This is done as follows: for each parameter, check if it's not null
--      and differs from the current state.  If so, load fin_info with
--      that parameter, otherwise just copy the corresponding dpr_in element.
--      Then call the adjustment module.  Copy the adjustment module's
--      output into dpr_in, then run query_balances, then run the engine.
--
--      If mode = NORMAL,HYPOTHETICAL, then go directly to running
--      query-balances and calling the engine.
--
--      Copy engine's output into global array G_deprn.  (To be committed
--      to interface table later.)


  ret boolean;
  dpr_in  fa_std_types.dpr_struct;
  dpr_out fa_std_types.dpr_out_struct;
  dpr_arr fa_std_types.dpr_arr_type;

  dpr_row fa_std_types.fa_deprn_row_struct;

  fin_info fa_std_types.fin_info_struct;

  h_dpr_date    date;
  h_calendar_type varchar2(30);
  h_fy_name     varchar2(30);
  h_prorate_fy  number;
  h_cur_per_num number;
  h_num_per_fy  number;
  h_cur_fy      number;

  h_prorate_conv varchar2(10);

  h_count       number;
  h_start_per_num   number;
  h_start_per_fy    number;

  h_start_index     number;
  h_end_index       number;
  h_delta_index     number;  -- Added by Satish Byreddy for Bug# 7128175

  h_chrono_start_per  number;
  h_chrono_cur_per    number;

  h_current_time        date;
  h_current_cost        number;

  h_new_adj_cost        number;
  h_adj_deprn_exp       number;
  h_adj_prev_deprn_exp  number;
  h_adj_bonus_deprn_exp number;
  h_adj_prev_bonus_deprn_exp number;
  h_new_raf             number;
  h_new_formula_factor  number := 1;
  h_new_salvage_value   number;
  h_new_adj_capacity    number;
  h_new_reval_amo_basis number;
  h_deprn_exp           number;
  h_bonus_deprn_exp     number;
  h_deprn_rsv           number; -- df

  mesg_count number;
  mesg1 varchar2(280);
  mesg2 varchar2(280);
  mesg3 varchar2(280);
  mesg4 varchar2(280);
  mesg5 varchar2(280);
  mesg6 varchar2(280);
  mesg7 varchar2(280);
  mesg8 varchar2(280);
  mesg9 varchar2(280);
  mesg10 varchar2(280);
  mesg_more  boolean;


  h_mesg_name  varchar2(30);
  h_mesg_str   varchar2(2000);

  h_arc_change_flag   boolean;
  h_allowed_deprn_limit     number;
  h_allowed_deprn_limit_amt number;
  h_adjusted_rec_cost       number;
  h_use_deprn_limits_flag   varchar2(3);

  h_deprn_basis_rule     varchar2(5);

  h_itc_amount_id       number;
  h_itc_basis           number;
  h_ceiling_type        varchar2(50);

  l_cp_start_date       date;
  l_adjustment_required_status varchar2(10);

  --
  -- Get all possible period information that the group asset needs
  --
  l_st_period_counter  NUMBER(15);
  l_ed_period_counter  NUMBER(15);

  CURSOR c_get_period_rec IS
    select cp.period_name period_name
         , cp.period_num period_num
         , fy.fiscal_year fiscal_year
    from   fa_fiscal_year fy
         , fa_calendar_periods cp
    where  fy.fiscal_year_name = fa_cache_pkg.fazcbc_record.fiscal_year_name
    and    cp.calendar_type = fa_cache_pkg.fazcbc_record.deprn_calendar
    and    cp.start_date between fy.start_date and fy.end_date
    and    l_st_period_counter <= fy.fiscal_year * fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
    and l_ed_period_counter >= fy.fiscal_year * fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR + cp.PERIOD_NUM
    order by fiscal_year, period_num;

  cache_err             exception;
  h_deprn_run           varchar2(1);
  h_fmode               NUMBER;   -- Added for Bug# 7234390
begin

   --fa_rx_conc_mesg_pkg.log('Hello World');

   ret := TRUE;
   h_arc_change_flag := FALSE;

   h_adj_deprn_exp := 0;
   h_adj_bonus_deprn_exp := 0;
--tk_util.debug('Begin: '||X_mode);
      select sysdate into h_current_time from dual;

      if X_mode <> 'HYPOTHETICAL' then

            -- FOR ALL MODES EXCEPT HYPOTHETICAL, THE ASSET EXISTS IN THE
            -- DATABASE, SO SELECT ITS BOOK INFO.
            -- SELECTING INTO DPR_IN, WHICH WE'LL USE AS A REPOSITORY
            -- FOR THESE VALUES THROUGHOUT THIS FUNCTION.

            h_mesg_name := 'FA_WHATIF_ASSET_BOOKS';

            -- bug32118506
            if (FARX_C_WD.mrc_sob_type in ('P','N')) then -- Enhancement Bug 3037321

               SELECT decode (mt.rate_source_rule,
                                    'CALCULATED', bk.prorate_date,
                                    'FORMULA',    bk.prorate_date,
                                    'TABLE',      bk.deprn_start_date,
                                    'FLAT',       decode (mt.deprn_basis_rule,
                                                            'COST',  bk.prorate_date,
                                                             'NBV',  bk.deprn_start_date),
                                    'PROD',       bk.date_placed_in_service),
                      to_number (to_char (bk.prorate_date, 'J')),
                      to_number (to_char (bk.date_placed_in_service, 'J')),
                      to_number (to_char (bk.deprn_start_date, 'J')),
                      decode(mt.rate_source_rule, 'FLAT', bk.life_in_months,
                                                          nvl(bk.life_in_months, 0)),
                      bk.recoverable_cost,
                      bk.adjusted_cost,
                      bk.cost,
                      nvl(bk.reval_amortization_basis, 0),
                      bk.rate_adjustment_factor,
                      nvl(bk.adjusted_rate, 0),
                      bk.ceiling_name,
                      bk.bonus_rule,
                      nvl (bk.production_capacity, 0),
                      nvl (bk.adjusted_capacity, 0),
                      mt.method_code,
                      ad.asset_number,
                      nvl (bk.adjusted_recoverable_cost, bk.recoverable_cost),
                      bk.salvage_value,
                      bk.period_counter_life_complete,
                      bk.adjustment_required_status,
                      bk.annual_deprn_rounding_flag,
                      bk.itc_amount_id,
                      bk.itc_basis,
                      ceilt.ceiling_type,
                      nvl(bk.formula_factor, 1),
                      nvl(bk.short_fiscal_year_flag, 'NO'),
                      bk.conversion_date,
                      bk.original_deprn_start_date,
                      bk.prorate_date
                    , ad.asset_type
               INTO   h_dpr_date,
                      dpr_in.prorate_jdate,
                      dpr_in.jdate_in_service,
                      dpr_in.deprn_start_jdate,
                      dpr_in.life,
                      dpr_in.rec_cost,
                      dpr_in.adj_cost,
                      h_current_cost,
                      dpr_in.reval_amo_basis,
                      dpr_in.rate_adj_factor,
                      dpr_in.adj_rate,
                      dpr_in.ceil_name,
                      dpr_in.bonus_rule,
                      dpr_in.capacity,
                      dpr_in.adj_capacity,
                      dpr_in.method_code,
                      dpr_in.asset_num,
                      dpr_in.adj_rec_cost,
                      dpr_in.salvage_value,
                      dpr_in.pc_life_end,
                      l_adjustment_required_status,
                      dpr_in.deprn_rounding_flag,
                      h_itc_amount_id,
                      h_itc_basis,
                      h_ceiling_Type,
                      dpr_in.formula_factor,
                      dpr_in.short_fiscal_year_flag,
                      dpr_in.conversion_date,
                      dpr_in.orig_deprn_start_date,
                      dpr_in.prorate_date
                    , dpr_in.asset_type
               FROM   fa_ceiling_types ceilt,
                      fa_methods mt,
                      fa_category_books cb,
                      fa_books bk,
                      fa_additions_b ad
               WHERE  cb.book_type_code = X_book
               AND    ad.asset_category_id = cb.category_id
               AND    ceilt.ceiling_name(+) = bk.ceiling_name
               AND    mt.method_code = bk.deprn_method_code
               AND    bk.book_type_code = X_book
               AND    bk.asset_id = X_asset_id
               AND    bk.transaction_header_id_out is null
               AND    nvl (mt.life_in_months, -9999) = nvl (bk.life_in_months, -9999)
               AND    ad.asset_id = bk.asset_id;

            else

               SELECT decode (mt.rate_source_rule,
                                    'CALCULATED', bk.prorate_date,
                                    'FORMULA',    bk.prorate_date,
                                    'TABLE',      bk.deprn_start_date,
                                    'FLAT',       decode (mt.deprn_basis_rule,
                                                            'COST',  bk.prorate_date,
                                                             'NBV',  bk.deprn_start_date),
                                    'PROD',       bk.date_placed_in_service),
                      to_number (to_char (bk.prorate_date, 'J')),
                      to_number (to_char (bk.date_placed_in_service, 'J')),
                      to_number (to_char (bk.deprn_start_date, 'J')),
                      decode(mt.rate_source_rule, 'FLAT', bk.life_in_months,
                                                          nvl(bk.life_in_months, 0)),
                      bk.recoverable_cost,
                      bk.adjusted_cost,
                      bk.cost,
                      nvl(bk.reval_amortization_basis, 0),
                      bk.rate_adjustment_factor,
                      nvl(bk.adjusted_rate, 0),
                      bk.ceiling_name,
                      bk.bonus_rule,
                      nvl (bk.production_capacity, 0),
                      nvl (bk.adjusted_capacity, 0),
                      mt.method_code,
                      ad.asset_number,
                      nvl (bk.adjusted_recoverable_cost, bk.recoverable_cost),
                      bk.salvage_value,
                      bk.period_counter_life_complete,
                      bk.adjustment_required_status,
                      bk.annual_deprn_rounding_flag,
                      bk.itc_amount_id,
                      bk.itc_basis,
                      ceilt.ceiling_type,
                      nvl(bk.formula_factor, 1),
                      nvl(bk.short_fiscal_year_flag, 'NO'),
                      bk.conversion_date,
                      bk.original_deprn_start_date,
                      bk.prorate_date
                    , ad.asset_type
               INTO   h_dpr_date,
                      dpr_in.prorate_jdate,
                      dpr_in.jdate_in_service,
                      dpr_in.deprn_start_jdate,
                      dpr_in.life,
                      dpr_in.rec_cost,
                      dpr_in.adj_cost,
                      h_current_cost,
                      dpr_in.reval_amo_basis,
                      dpr_in.rate_adj_factor,
                      dpr_in.adj_rate,
                      dpr_in.ceil_name,
                      dpr_in.bonus_rule,
                      dpr_in.capacity,
                      dpr_in.adj_capacity,
                      dpr_in.method_code,
                      dpr_in.asset_num,
                      dpr_in.adj_rec_cost,
                      dpr_in.salvage_value,
                      dpr_in.pc_life_end,
                      l_adjustment_required_status,
                      dpr_in.deprn_rounding_flag,
                      h_itc_amount_id,
                      h_itc_basis,
                      h_ceiling_Type,
                      dpr_in.formula_factor,
                      dpr_in.short_fiscal_year_flag,
                      dpr_in.conversion_date,
                      dpr_in.orig_deprn_start_date,
                      dpr_in.prorate_date
                    , dpr_in.asset_type
               FROM   fa_ceiling_types ceilt,
                      fa_methods mt,
                      fa_category_books cb,
                      fa_mc_books bk,
                      fa_additions_b ad
               WHERE  cb.book_type_code = X_book
               AND    ad.asset_category_id = cb.category_id
               AND    ceilt.ceiling_name(+) = bk.ceiling_name
               AND    mt.method_code = bk.deprn_method_code
               AND    bk.book_type_code = X_book
               AND    bk.asset_id = X_asset_id
               AND    bk.transaction_header_id_out is null
               AND    bk.set_of_books_id = FARX_C_WD.sob_id
               AND    nvl (mt.life_in_months, -9999) = nvl (bk.life_in_months, -9999)
               AND    ad.asset_id = bk.asset_id;

            end if;

            dpr_in.formula_factor := 1;

      else  -- HYPOTHETICAL

         --fa_rx_conc_mesg_pkg.log('step 1');

         -- RUNNING IN HYPOTHETICAL MODE.  ASSET DOESN'T EXIST,
         -- SO ALL BOOKS INFO HAD TO BE PASSED INTO THIS FUNCTION.

         h_mesg_name := 'FA_AMT_BD_DPR_STRUCT';

         --fa_rx_conc_mesg_pkg.log('step 1.1');
         SELECT cbd.life_in_months,
             cbd.deprn_method,
             cbd.prorate_convention_code,
             cbd.adjusted_rate,
                cbd.bonus_rule,
             cbd.ceiling_name
         INTO   dpr_in.life,
                dpr_in.method_code,
                h_prorate_conv,
                dpr_in.adj_rate,
                dpr_in.bonus_rule,
                dpr_in.ceil_name
         FROM   FA_CATEGORY_BOOK_DEFAULTS cbd
         WHERE  cbd.book_type_code = X_book
         AND    cbd.category_id = X_category_id
         AND    X_dpis BETWEEN CBD.START_DPIS AND
                               NVL(CBD.END_DPIS,TO_DATE('31-12-4712','DD-MM-YYYY'));

         --fa_rx_conc_mesg_pkg.log('step 1.2');
         --fa_rx_conc_mesg_pkg.log(h_prorate_conv);

         if X_prorate_conv is not null then
            h_prorate_conv := X_prorate_conv;
         end if;

         -- Get prorate date
         SELECT to_number(to_char(conv.prorate_date,'J'))
         INTO   dpr_in.prorate_jdate
         FROM   fa_conventions conv
         WHERE  conv.prorate_convention_code = h_prorate_conv
         AND    X_dpis between conv.start_date and conv.end_date;

         --fa_rx_conc_mesg_pkg.log('step 1.3');
         if (X_prorate_date is not null) then
         dpr_in.prorate_jdate := to_number(to_char(X_prorate_date,'J'));
         end if;

         -- X_dpis can not be null
         dpr_in.jdate_in_service := to_number(to_char(X_dpis, 'J'));

         -- deprn start date
         dpr_in.deprn_start_jdate := dpr_in.prorate_jdate;

         if (X_life is not null) then
            dpr_in.life := X_life;
         end if;

         if (X_salvage_pct is not null) then
            dpr_in.salvage_value := X_cost * (X_salvage_pct / 100);
         end if;

         if (X_salvage_value is not null) then
            dpr_in.salvage_value := X_salvage_value;
         end if;

         dpr_in.salvage_value := nvl(dpr_in.salvage_value, 0);

         dpr_in.rec_cost := X_cost - nvl(dpr_in.salvage_value,0);
         dpr_in.adj_cost := dpr_in.rec_cost;

         --fa_rx_conc_mesg_pkg.log('step 1.4');
         if (X_rec_cost is not null) then
            dpr_in.rec_cost := X_rec_cost;
         end if;


         if (X_adj_cost is not null) then
            dpr_in.adj_cost := X_adj_cost;
         end if;


         --fa_rx_conc_mesg_pkg.log('step 1.5');

         dpr_in.reval_amo_basis := NULL;
         dpr_in.rate_adj_factor := 1;

         --fa_rx_conc_mesg_pkg.log('step 1.6');

         if (X_adj_rate is not null) then
            dpr_in.adj_rate := X_adj_rate;
            dpr_in.life := NULL;
         end if;

         if (X_ceiling_name is not null) then
            dpr_in.ceil_name := X_ceiling_name;
         end if;

         if (X_bonus_rule is not null) then
            dpr_in.bonus_rule := X_bonus_rule;
         end if;

         dpr_in.capacity := NULL;
         dpr_in.adj_capacity := NULL;

         --fa_rx_conc_mesg_pkg.log('step 1.7');
         if (X_method_code is not null) then
         dpr_in.method_code := X_method_code;
         end if;

         /* Added for bug 7582031 */
         if (X_deprn_rsv is not null) then
         dpr_in.deprn_rsv := X_deprn_rsv;
         end if;

         dpr_in.asset_num := to_char(X_asset_id);
         dpr_in.adj_rec_cost := dpr_in.rec_cost;

         dpr_in.formula_factor := 1;

         --fa_rx_conc_mesg_pkg.log('step 1.8');
         dpr_in.pc_life_end := NULL;
         dpr_in.deprn_rounding_flag := NULL;
         h_current_cost := X_cost;
      end if; --X_mode <> 'HYPOTHETICAL' then

       -- GET PERIOD_NUM AND FISCAL_YEAR FOR WHICH TO START DEPRN.
       -- ALWAYS START DEPRN IN CURRENT OPEN PERIOD.


       h_mesg_name := 'FA_DEPRN_CURRENT_PERIOD';

       --
       -- Bug3330163: Replacing with cache call.
       --
       if not fa_cache_pkg.fazcdp(x_book_type_code => X_book,
                                 x_period_counter => null,
                                 x_effective_date => null) then
          raise cache_err;
       end if;

       dpr_row.period_ctr := fa_cache_pkg.fazcdp_record.period_counter;
       dpr_in.p_cl_begin := fa_cache_pkg.fazcdp_record.period_num;
       dpr_in.y_begin := fa_cache_pkg.fazcdp_record.fiscal_year;
       h_deprn_run      := fa_cache_pkg.fazcdp_record.deprn_run;

       --fa_rx_conc_mesg_pkg.log('step 2111');

       if X_mode in ('EXPENSED','AMORTIZED') then

          -- IF WE'RE DOING ADJUSTMENT, NEED TO LOAD A FIN_INFO
          -- STRUCTURE AND CALL APPROPRIATE ADJUSTMENT MODULE.
          -- IF A FIN_INFO PARAMETER TO THIS FUNCTION IS NOT NULL,
          -- THEN ASSUME IT REPRESENTS A CHANGE FROM THE ASSET'S CURRENT
          -- STATE; LOAD IT INTO FIN_INFO.  IF A PARAM IS NULL, THEN
          -- LOAD CURRENT STATE INTO FIN_INFO.
          -- FOR EACH PARAM, MAKE SURE DPR_IN VALUE IS CORRECT.

          h_mesg_name := 'FA_AMT_GET_CATE_ID';

          select category_id, units, asset_type
          into fin_info.category_id, fin_info.units, fin_info.asset_type
          from fa_asset_history
          where asset_id = X_asset_id and date_ineffective is null;

          -- MOST FIN_INFO ELEMENTS ARE LOADED THIS WAY:
          -- IF INCOMING PARAMETER IS NOT NULL AND DIFFERENT FROM ASSET'S
          -- CURRENT STATE, COPY IT INTO FIN_INFO.  OTHERWISE, COPY FROM
          -- DPR_IN.

          h_mesg_name := 'FA_MASSCHG_LOAD_FININFO';

          fin_info.current_time := h_current_time;
          fin_info.asset_number := dpr_in.asset_num;
          fin_info.asset_id := X_asset_id;
          fin_info.old_cost := h_current_cost;
          fin_info.book := X_book;

          if (X_cost is not null) then
          fin_info.cost := X_cost;
          h_arc_change_flag := TRUE;
          else
             fin_info.cost := h_current_cost;
          end if;


          -- IF X_SALVAGE_VALUE IS NOT NULL, COPY IT TO FIN_INFO.
          -- IF X_SALVAGE_PCT IS NOT NULL, CALCULATE SALVAGE USING
          -- *CURRENT* COST.

          if (X_salvage_value is not null) then
             fin_info.salvage_value := X_salvage_value;
             dpr_in.salvage_value := X_salvage_value;
             h_arc_change_flag := TRUE;
          elsif (X_salvage_pct is not null) then
             fin_info.salvage_value :=
          nvl(X_cost,h_current_cost) * (X_salvage_pct / 100);
             dpr_in.salvage_value := fin_info.salvage_value;
             h_arc_change_flag := TRUE;
          else
             fin_info.salvage_value := dpr_in.salvage_value;
          end if;


          if (X_salvage_value is not null OR X_salvage_pct is not null) then
            fin_info.rec_cost := fin_info.cost - fin_info.salvage_value;
            dpr_in.rec_cost := fin_info.rec_cost;
          else
            if (X_rec_cost is not null) then
              fin_info.rec_cost := X_rec_cost;
              dpr_in.rec_cost := X_rec_cost;
            else fin_info.rec_cost := dpr_in.rec_cost;
            end if;
          end if;


          -- Method, Life, Rate require special treatment.  First check if
          -- method is life- or rate-based.  Then ensure we've only one of Life
          -- and Rate populated according to the method.

          if (X_method_code is not null) then
          fin_info.method_code := X_method_code;
          dpr_in.method_code := X_method_code;

             select count(*) into h_count from fa_methods
             where method_code = X_method_code
             and rate_source_rule in ('TABLE','CALCULATED','FORMULA')
             and rownum < 2;

             if h_count > 0 then   -- life-based

             if (X_life is not null) then
                fin_info.life := X_life;
                dpr_in.life := X_life;
             end if;

             fin_info.adj_rate := null;
             dpr_in.adj_rate := null;

             else    -- rate-based
             if (X_adj_rate is not null) then
                fin_info.adj_rate := X_adj_rate;
                dpr_in.adj_rate := X_adj_rate;
             end if;

             fin_info.life := null;
             dpr_in.life := null;

             end if;

          else    -- X_method_code not populated .. just propagate asset's current
             -- state to fin_info
             --fa_rx_conc_mesg_pkg.log('step 2');

             fin_info.method_code := dpr_in.method_code;
             fin_info.life := dpr_in.life;
             fin_info.adj_rate := dpr_in.adj_rate;

          end if; -- (X_method_code is not null)

          --fa_rx_conc_mesg_pkg.log('step 3');

          if (X_ceiling_name is not null) then
             fin_info.ceiling_name := X_ceiling_name;
             dpr_in.ceil_name := X_ceiling_name;
          else
             fin_info.ceiling_name := dpr_in.ceil_name;
          end if;

          if (X_bonus_rule is not null) then
             fin_info.bonus_rule := X_bonus_rule;
             dpr_in.bonus_rule := X_bonus_rule;
          else
             fin_info.bonus_rule := dpr_in.bonus_rule;
          end if;

          fin_info.transaction_id := 0;


          if (X_dpis is not null) then
             fin_info.date_placed_in_svc := X_dpis;
             dpr_in.jdate_in_service := to_number(to_char(X_dpis,'J'));
             h_arc_change_flag := TRUE;
          else
             fin_info.date_placed_in_svc := to_date(to_char(dpr_in.jdate_in_service),'J');
          end if;

          fin_info.jdate_in_svc :=
          to_number(to_char(fin_info.date_placed_in_svc,'J'));

          if (X_prorate_date is not null) then
             fin_info.prorate_date := X_prorate_date;
             dpr_in.prorate_jdate := to_number(to_char(X_prorate_date,'J'));
          else
             fin_info.prorate_date := to_date(to_char(dpr_in.prorate_jdate),'J');
          end if;

          if (X_prorate_conv is not null) then
             select prorate_date into fin_info.prorate_date
             from fa_conventions
             where prorate_convention_code = X_prorate_conv
             and fin_info.date_placed_in_svc between start_date and end_date;

             dpr_in.prorate_jdate := to_number(to_char(fin_info.prorate_date,'J'));
          end if;

          if (X_deprn_start_date is not null) then
             fin_info.deprn_start_date := X_deprn_start_date;
             dpr_in.deprn_start_jdate := to_number(to_char(X_deprn_start_date,'J'));
          else
             fin_info.deprn_start_date := to_date(to_char(dpr_in.deprn_start_jdate),'J');
          end if;

          fin_info.dep_flag := TRUE;

          if (X_raf is not null) then
             fin_info.rate_adj_factor := X_raf;
             dpr_in.rate_adj_factor := X_raf;
          else
             fin_info.rate_adj_factor := dpr_in.rate_adj_factor;
          end if;

          if (X_reval_amo_basis is not null) then
             fin_info.reval_amo_basis := X_reval_amo_basis;
             dpr_in.reval_amo_basis := X_reval_amo_basis;
          else
             fin_info.reval_amo_basis := dpr_in.reval_amo_basis;
          end if;

          if (X_capacity is not null) then
             fin_info.capacity := X_capacity;
             dpr_in.capacity := X_capacity;
          else
             fin_info.capacity := dpr_in.capacity;
          end if;

          fin_info.adj_capacity := fin_info.capacity;
          fin_info.period_ctr := dpr_row.period_ctr;
          fin_info.deprn_rounding_flag := 'ADJ';

          dpr_row.asset_id := X_asset_id;
          dpr_row.book := X_book;
          dpr_row.dist_id := 0;
          --dpr_row.mrc_sob_type_code := 'P';
          dpr_row.mrc_sob_type_code := FARX_C_WD.mrc_sob_type; -- Enhancement Bug 3037321
          dpr_row.set_of_books_id := FARX_C_WD.sob_id;

          --fa_rx_conc_mesg_pkg.log('step 4');

          if not fa_cache_pkg.fazcbc_clr(X_BOOK => X_BOOK) then
             return (FALSE);
          end if;

          if not fa_cache_pkg.fazcbc(X_BOOK => X_BOOK) then
             return (FALSE);
          end if;

          if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar) then
              return (FALSE);
          end if;

          -- CALL QUERY BALANCES.

          h_mesg_name := 'FA_WHATIF_ASSET_QUERY_BAL';

--tk_util.debug('1 dpr_row.period_ctr: '||to_char(dpr_row.period_ctr));
          fa_query_balances_pkg.query_balances_int (
                      X_dpr_row => dpr_row,
                      X_run_mode => 'STANDARD',
                      X_debug => FALSE,
                      X_success => ret,
                      X_calling_fn => 'whatif_deprn_asset',
                      X_transaction_header_id => -1,
                      p_log_level_rec => null);

          if (ret = FALSE) then
             fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.fauexp');

             fa_srvr_msg.get_message(mesg_count,mesg1,mesg2,mesg3,mesg4,
                mesg5,mesg6,mesg7);

          fa_rx_conc_mesg_pkg.log(mesg1);
          fa_rx_conc_mesg_pkg.log(mesg2);
          fa_rx_conc_mesg_pkg.log(mesg3);
          fa_rx_conc_mesg_pkg.log(mesg4);
          fa_rx_conc_mesg_pkg.log(mesg5);
          fa_rx_conc_mesg_pkg.log(mesg6);
          fa_rx_conc_mesg_pkg.log(mesg7);


          x_return_status := 2;
             return (FALSE);
          end if;

          --fa_rx_conc_mesg_pkg.log('step 5');

          -- Recoverable cost requires special treatment if there's a ceiling and/or
          -- ITC amount.

          h_mesg_name := 'FA_FE_CANT_GEN_RECOV_COST';

          if (h_itc_amount_id is null AND h_ceiling_type = 'RECOVERABLE COST CEILING') then
             select least(fin_info.cost - fin_info.salvage_value,
                          nvl(ce.limit, fin_info.cost - fin_info.salvage_value))
             into   fin_info.rec_cost
             from   fa_ceilings ce
             where  ce.ceiling_name = fin_info.ceiling_name
             and    fin_info.date_placed_in_svc
                            between ce.start_date
                                and nvl(ce.end_date, fin_info.date_placed_in_svc);

          elsif (h_itc_amount_id is not null AND
                 h_ceiling_type = 'RECOVERABLE COST CEILING') then
             select least(fin_info.cost - fin_info.salvage_value -
                        h_itc_basis * ir.basis_reduction_rate,
                        nvl(ce.limit, fin_info.cost - fin_info.salvage_value -
                                      h_itc_basis * ir.basis_reduction_rate))
             into   fin_info.rec_cost
             from   fa_ceilings ce, fa_itc_rates ir
             where  ir.itc_amount_id = h_itc_amount_id
             and    ce.ceiling_name = fin_info.ceiling_name
             and    fin_info.date_placed_in_svc
                            between ce.start_date
                                and nvl(ce.end_date, fin_info.date_placed_in_svc);

          elsif (h_itc_amount_id is not null and
              nvl(h_ceiling_type,'X') <> 'RECOVERABLE COST CEILING') then
             select fin_info.cost - fin_info.salvage_value -
                                     h_itc_basis * ir.basis_reduction_rate
             into   fin_info.rec_cost
             from   fa_itc_rates ir
             where  ir.itc_amount_id = h_itc_amount_id;

          end if;

          --fa_rx_conc_mesg_pkg.log('step 6');

          h_mesg_name := 'FA_WHATIF_NO_METHOD';

          --
          -- Replace sql with cache call.
          --
          if (not fa_cache_pkg.fazccmt(fin_info.method_code,
                                       fin_info.life)) then
             raise cache_err;
          end if;

          h_deprn_basis_rule := fa_cache_pkg.fazccmt_record.deprn_basis_rule;

          fin_info.adj_cost := fin_info.rec_cost;

          -- ADJ_REC_COST DEPENDENT ON WHETHER WE'RE USING DEPRN_LIMITS
          h_mesg_name := 'FA_MAP_SV_DL_ERROR';

          --fa_rx_conc_mesg_pkg.log('step 7');

          SELECT CBD.USE_DEPRN_LIMITS_FLAG
               , CBD.ALLOWED_DEPRN_LIMIT
               , CBD.SPECIAL_DEPRN_LIMIT_AMOUNT
          INTO   h_use_deprn_limits_flag
               , h_allowed_deprn_limit
               , h_allowed_deprn_limit_amt
          FROM   FA_ADDITIONS_B FAD
               , FA_CATEGORY_BOOK_DEFAULTS CBD
          WHERE  FAD.ASSET_ID = fin_info.asset_id
          AND    CBD.CATEGORY_ID = FAD.ASSET_CATEGORY_ID
          AND    CBD.BOOK_TYPE_CODE = fin_info.book
          AND    fin_info.date_placed_in_svc
                             BETWEEN CBD.START_DPIS
                                 AND NVL(CBD.END_DPIS,TO_DATE('31-12-4712','DD-MM-YYYY'));

          if (h_use_deprn_limits_flag = 'YES') then
             if (h_allowed_deprn_limit is null) then
                if (fin_info.cost > 0) then
                   h_adjusted_rec_cost := fin_info.cost - h_allowed_deprn_limit_amt;
                elsif (fin_info.cost < 0) then
                   h_adjusted_rec_cost := fin_info.cost + h_allowed_deprn_limit_amt;
                else
                   h_adjusted_rec_cost := 0;
                end if;
             elsif (h_allowed_deprn_limit_amt is null) then
                h_adjusted_rec_cost := fin_info.cost * h_allowed_deprn_limit;
                fa_round_pkg.fa_floor(h_adjusted_rec_cost, fin_info.book);
             end if;
          else
             h_adjusted_rec_cost := fin_info.rec_cost;
          end if; -- (h_use_deprn_limits_flag = 'YES')

          dpr_in.adj_rec_cost := h_adjusted_rec_cost;
          fin_info.adj_rec_cost := h_adjusted_rec_cost;

          --fa_rx_conc_mesg_pkg.log('step 7');

          if fnd_profile.value('PRINT_DEBUG') = 'Y' then
             fa_rx_conc_mesg_pkg.log('FIN_INFO STRUCT:');
             fa_rx_conc_mesg_pkg.log('asset_id: ' || fin_info.asset_id);
             fa_rx_conc_mesg_pkg.log('category_id: ' || fin_info.category_id);
             fa_rx_conc_mesg_pkg.log('transaction_id: ' || fin_info.transaction_id);
             fa_rx_conc_mesg_pkg.log('jdate_in_svc: ' || fin_info.jdate_in_svc);
             fa_rx_conc_mesg_pkg.log('period_ctr: ' || fin_info.period_ctr);
             fa_rx_conc_mesg_pkg.log('book: ' || fin_info.book);
             fa_rx_conc_mesg_pkg.log('asset_number: ' || fin_info.asset_number);
             fa_rx_conc_mesg_pkg.log('asset_Type: ' || fin_info.asset_type);
             fa_rx_conc_mesg_pkg.log('date_placed_in_svc: ' ||
                                      to_char(fin_info.date_placed_in_svc,'DD-MM-YYYY'));
             fa_rx_conc_mesg_pkg.log('prorate_date: ' ||
                                      to_char(fin_info.prorate_date,'DD-MM-YYYY'));
             fa_rx_conc_mesg_pkg.log('deprn_start_date: ' ||
                                      to_char(fin_info.deprn_start_date,'DD-MM-YYYY'));
             fa_rx_conc_mesg_pkg.log('ceiling_name: ' || fin_info.ceiling_name);
             fa_rx_conc_mesg_pkg.log('bonus_rule: ' || fin_info.bonus_rule);
             fa_rx_conc_mesg_pkg.log('current_time: ' ||
                                     to_char(fin_info.current_time,'DD-MM-YYYY'));
             fa_rx_conc_mesg_pkg.log('method_code: ' || fin_info.method_code);
             fa_rx_conc_mesg_pkg.log('cost: ' || fin_info.cost);
             fa_rx_conc_mesg_pkg.log('old_cost: ' || fin_info.old_cost);
             fa_rx_conc_mesg_pkg.log('rec_cost: ' || fin_info.rec_cost);
             fa_rx_conc_mesg_pkg.log('adj_cost: ' || fin_info.adj_cost);
             fa_rx_conc_mesg_pkg.log('rate_adj_factor: ' || fin_info.rate_adj_Factor);
             fa_rx_conc_mesg_pkg.log('adj_rate: ' || fin_info.adj_Rate);
             fa_rx_conc_mesg_pkg.log('units: ' || fin_info.units);
             fa_rx_conc_mesg_pkg.log('reval_amo_basis: ' || fin_info.reval_amo_basis);
             fa_rx_conc_mesg_pkg.log('capacity: ' || fin_info.capacity);
             fa_rx_conc_mesg_pkg.log('adj_capacity: ' || fin_info.adj_capacity);
             fa_rx_conc_mesg_pkg.log('life: ' || fin_info.life);
             fa_rx_conc_mesg_pkg.log('adj_rec_cost: ' || fin_info.adj_rec_cost);
             fa_rx_conc_mesg_pkg.log('salvage_value: ' || fin_info.salvage_value);
             fa_rx_conc_mesg_pkg.log('deprn_rounding_flag: '||fin_info.deprn_rounding_flag);
          end if;

          -- Fix for Bug #1259562.  Default formula_factor to 1.
          if (fin_info.formula_factor is null) then
             fin_info.formula_factor := 1;
          end if;

          fin_info.running_mode:= fa_std_types.FA_DPR_PROJECT;


          if (X_mode = 'EXPENSED') then


         h_mesg_name := 'FA_WHATIF_ASSET_EXPENSE_ERR';
             -- bonus: should be ok for faxexp.
         /* Bug 8725642 intialized SOB id */
         fin_info.set_of_books_id := dpr_row.set_of_books_id;
         if not fa_exp_pkg.faxexp (fin_info,
                                       h_new_adj_cost, 0,
                                       h_current_time,
                                       0,
                                       0,
                                       FALSE,
                                       'P',  -- mrc sob type
                                       h_adj_deprn_exp,
                                       h_adj_bonus_deprn_exp,
                                       h_new_formula_factor,
                                       null) then

                fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.fauexp');

                fa_srvr_msg.get_message(mesg_count,mesg1,mesg2,mesg3,mesg4,
                                        mesg5,mesg6,mesg7);

                fa_rx_conc_mesg_pkg.log(mesg1);
                fa_rx_conc_mesg_pkg.log(mesg2);
                fa_rx_conc_mesg_pkg.log(mesg3);
                fa_rx_conc_mesg_pkg.log(mesg4);
                fa_rx_conc_mesg_pkg.log(mesg5);
                fa_rx_conc_mesg_pkg.log(mesg6);
                fa_rx_conc_mesg_pkg.log(mesg7);

                x_return_status := 2;
                return (FALSE);
         end if;

         dpr_in.adj_cost := h_new_adj_cost;


          else

             h_new_raf := dpr_in.rate_adj_factor;
             h_new_salvage_value := dpr_in.salvage_value;
             h_new_adj_capacity := dpr_in.adj_capacity;
             h_new_adj_cost := dpr_in.adj_cost;
             h_new_reval_amo_basis := dpr_in.reval_amo_basis;

          h_mesg_name := 'FA_WHATIF_ASSET_AMORTIZE_ERR';


             if fnd_profile.value('PRINT_DEBUG') = 'Y' then
            fa_rx_conc_mesg_pkg.log('old adj_cost: ' || to_char(dpr_in.adj_cost));
            fa_rx_conc_mesg_pkg.log('old raf: ' || to_char(dpr_in.rate_adj_factor));
             end if;

             if not fa_amort_pkg.faxama (fin_info,
                h_new_raf, h_new_adj_cost, h_new_adj_capacity,
                h_new_reval_amo_basis, h_new_salvage_value, h_new_formula_factor,0,
                FALSE, 'P',  FARX_C_WD.sob_id, h_deprn_exp,h_bonus_deprn_exp,h_current_time,0,0, null)  then
                fa_srvr_msg.add_message (calling_fn => 'fa_exp_pkg.fauama');

                fa_srvr_msg.get_message(mesg_count,mesg1,mesg2,mesg3,mesg4,
                                        mesg5,mesg6,mesg7);

                fa_rx_conc_mesg_pkg.log(mesg1);
                fa_rx_conc_mesg_pkg.log(mesg2);
                fa_rx_conc_mesg_pkg.log(mesg3);
                fa_rx_conc_mesg_pkg.log(mesg4);
                fa_rx_conc_mesg_pkg.log(mesg5);
                fa_rx_conc_mesg_pkg.log(mesg6);
                fa_rx_conc_mesg_pkg.log(mesg7);

                x_return_status := 2;
                return (FALSE);
             end if;

             dpr_in.salvage_value := h_new_salvage_value;
             dpr_in.rate_adj_factor := h_new_raf;
             dpr_in.adj_cost := h_new_adj_cost;
             dpr_in.adj_capacity := h_new_adj_capacity;
             dpr_in.reval_amo_basis := h_new_reval_amo_basis;

             if fnd_profile.value('PRINT_DEBUG') = 'Y' then
                fa_rx_conc_mesg_pkg.log('new adj_cost: ' || to_char(dpr_in.adj_cost));
                fa_rx_conc_mesg_pkg.log('new adj_rec_cost: '||to_char(dpr_in.adj_rec_cost));
                fa_rx_conc_mesg_pkg.log('new rec_cost: ' || to_char(dpr_in.rec_cost));
                fa_rx_conc_mesg_pkg.log('new salvage_val: '||to_char(dpr_in.salvage_value));
                fa_rx_conc_mesg_pkg.log('new raf: ' || to_char(dpr_in.rate_adj_factor));
             end if;
          end if; -- (X_mode = 'EXPENSED')
       end if; -- X_mode in ('EXPENSED','AMORTIZED')


       -- LOAD DPR_IN STRUCT... MAKE SURE TO ADD ADJUSTMENTS TO EXPENSE TO BALANCES HERE.

       --fa_rx_conc_mesg_pkg.log('step 811');

       -- HAVEN'T CALLED QUERY BALANCES FOR NORMAL MODE YET
       if (X_Mode not in ('EXPENSED','AMORTIZED')) then
          --fa_rx_conc_mesg_pkg.log('step 8');

          h_mesg_name := 'FA_WHATIF_ASSET_QUERY_BAL';

          dpr_row.asset_id := X_asset_id;
          dpr_row.book := X_book;
          dpr_row.dist_id := 0;
          --dpr_row.mrc_sob_type_code := 'P';
          dpr_row.mrc_sob_type_code := FARX_C_WD.mrc_sob_type; -- Enhancement Bug 3037321
          dpr_row.set_of_books_id := FARX_C_WD.sob_id;

          if not fa_cache_pkg.fazcbc_clr(X_BOOK => X_BOOK) then
             return (FALSE);
          end if;

          if not fa_cache_pkg.fazcbc(X_BOOK => X_BOOK) then
             return (FALSE);
          end if;
-- dpr_in.y_begin = 2002
-- dpr_in.p_cl_begin   = 2
          fa_query_balances_pkg.query_balances_int (
                                      X_dpr_row => dpr_row,
                                      X_run_mode => 'STANDARD',
                                      X_Debug => FALSE,
                                      X_success => ret,
                                      X_calling_fn => 'whatif_deprn_asset',
                                      X_transaction_header_id => -1,
                                      p_log_level_rec => null);
       end if; -- (X_Mode not in ('EXPENSED','AMORTIZED'))

       --  Get adjustments to deprn expense already taken this period.
       -- fa_rx_conc_mesg_pkg.log('step 8');
       h_mesg_name := 'FA_REC_SQL_GET_ADJ';

       --
       -- SQL to get expenses from fa_adjustments have been removed becuase
       -- the result were not used after the fix for bug227327
       --

       h_mesg_name := 'FA_AMT_BD_DPR_STRUCT';

       /* Bug 7582031 no need to change values of following parameters in hypothetical mode
          because we do not call query balance in case of Hypothetical mode*/

       IF X_mode <> 'HYPOTHETICAL' then

          dpr_in.reval_rsv := dpr_row.reval_rsv;
          dpr_in.prior_fy_exp := dpr_row.prior_fy_exp;
          dpr_in.ytd_deprn := dpr_row.ytd_deprn + h_adj_deprn_exp + dpr_row.YTD_IMPAIRMENT; --Bug#7533704
          dpr_in.deprn_rsv := dpr_row.deprn_rsv + h_adj_deprn_exp + dpr_row.IMPAIRMENT_RSV; --Bug#7533704
          dpr_in.ltd_prod := dpr_row.ltd_prod;

       End IF;
--tk_util.debug('dpr_in.deprn_rsv: '||to_char(dpr_in.deprn_rsv));

       -- bonus: h_adj_bonus_deprn_exp is obtained from faxexp above.
       --        New parameter was added to faxexp due to the need.

       dpr_in.bonus_ytd_deprn := dpr_row.bonus_ytd_deprn + h_adj_bonus_deprn_exp;
       dpr_in.bonus_deprn_rsv := dpr_row.bonus_deprn_rsv + h_adj_bonus_deprn_exp;

       dpr_in.asset_id := X_asset_id;
       dpr_in.book := X_book;
       dpr_in.cost := NVL(X_cost,h_current_cost);   --- Added by Satish Byreddy as the Hypothitecal Wha-If Analysis is erroring out with ORA-00904: "ADJUSTED_COST": invalid identifier

       dpr_in.jdate_retired := 0;
       dpr_in.ret_prorate_jdate := 0;
       dpr_in.rsv_known_flag := TRUE;


       --fa_rx_conc_mesg_pkg.log('step 9');

       -- GET CALENDAR INFO: TYPE, FY_NAME, NUM_PER_FISCAL_YEAR

       h_mesg_name := 'FA_DEPRN_SQL_SNFY';

       --
       -- Modified to use cache
       --
       if not fa_cache_pkg.fazcct(fa_cache_pkg.fazcbc_record.deprn_calendar) then
          raise cache_err;
       end if;

       h_calendar_type := fa_cache_pkg.fazcbc_record.deprn_calendar;
       h_fy_name := fa_cache_pkg.fazcbc_record.fiscal_year_name;
       h_num_per_fy := fa_cache_pkg.fazcct_record.number_per_fiscal_year;

       dpr_in.calendar_type := h_calendar_type;


       -- FIGURE OUT THE LAST PERIOD_NUM/FISCAL_YEAR FOR WHICH TO DEPRECIATE,
       -- GIVEN X_START_PER AND X_NUM_PERS.  KEEP IN MIND THAT WE MUST START
       -- DEPRN IN CURRENT OPEN PERIOD, BUT X_START_PER MAY BE EARLIER OR LATER.


       h_mesg_name := 'FA_AMT_SEL_CALENDARS_1';

   --- Added as part of the Bug# 7234390. to cache the Deprn Details.
          if (not fa_cache_pkg.fazccmt(dpr_in.method_code,
                                       dpr_in.life)) then
             raise cache_err;
          end if;
 --- End of the addition BUG# 7234390

       select cp.period_num
            , fy.fiscal_year
            , cp.start_date
       into   h_start_per_num
            , h_start_per_fy
            , l_cp_start_date
       from fa_calendar_periods cp, fa_fiscal_year fy
       where cp.period_name = X_start_per
       and cp.calendar_type = h_calendar_type
       and cp.start_date >= fy.start_date
       and cp.end_date <= fy.end_date
       and fy.fiscal_year_name = h_fy_name;

       h_mesg_name := 'FA_WHATIF_START_END_PERIODS';

    if dpr_in.method_code = 'JP-STL-EXTND' THEN
      BEGIN
       /* bug 8991192
        SELECT cp.period_num
             , fy.fiscal_year
       into   dpr_in.p_cl_begin
            , dpr_in.y_begin
          FROM fa_calendar_periods cp
             , fa_fiscal_year fy
             , fa_book_controls fb
             , fa_books fk
         WHERE cp.calendar_type = fb.deprn_calendar
           AND fb.book_type_code = X_book
           AND cp.start_date >= fy.start_date
           AND cp.end_date <= fy.end_date
           AND fk.book_type_code = fb.book_type_code
           AND fk.asset_id = X_asset_id
           AND fk.date_ineffective IS NULL
           AND fy.fiscal_year_name = fb.fiscal_year_name
           AND (fy.fiscal_year * h_num_per_fy + cp.period_num) = fk.extended_depreciation_period;
         */
           Select cal.period_num , cal.fiscal_year
           into   dpr_in.p_cl_begin , dpr_in.y_begin
           From fa_books fk,
             (
               Select cp.period_num period_num,
                    fy.fiscal_year fiscal_year
                From  fa_fiscal_year fy
                  , fa_calendar_periods cp
                WHERE cp.calendar_type = h_calendar_type
                AND cp.start_date    >= fy.start_date
                AND cp.end_date      <= fy.end_date
                AND fy.fiscal_year_name = h_fy_name
              ) cal
           where fk.book_type_code = X_book
             AND fk.asset_id       = X_asset_id
             AND fk.date_ineffective IS NULL
             AND fk.extended_depreciation_period = cal.period_num + (cal.fiscal_year * h_num_per_fy);
        EXCEPTION
           WHEN OTHERS THEN
               dpr_in.p_cl_begin := fa_cache_pkg.fazcdp_record.period_num;
               dpr_in.y_begin := fa_cache_pkg.fazcdp_record.fiscal_year;
         END;

     end if;


      -- Added by Satish Byreddy for Bug# 7128175  . This will calculate the Depreciation from the First Period of Extended Depren
     --- The follwoing IF condition is used to identify the starting period.
      if   (dpr_in.y_begin* h_num_per_fy + dpr_in.p_cl_begin) <= (h_start_per_fy*h_num_per_fy + h_start_per_num) THEN
       dpr_in.y_end := h_start_per_fy +
        floor( (h_start_per_num + X_num_pers - 1) / h_num_per_fy);
       dpr_in.p_cl_end := mod( (h_start_per_num + X_num_pers - 1) , h_num_per_fy);
     elsif (dpr_in.y_begin* h_num_per_fy + dpr_in.p_cl_begin) > (h_start_per_fy*h_num_per_fy + h_start_per_num) THEN
       dpr_in.y_end := dpr_in.y_begin +
        floor( (dpr_in.p_cl_begin + X_num_pers - 1) / h_num_per_fy);
       dpr_in.p_cl_end := mod( (dpr_in.p_cl_begin + X_num_pers - 1) , h_num_per_fy);
     end if;

       --
       -- Set annual deprn rounding flag to RES to avoid subtraction method to
       -- to find expense for last period of fy because ytd is not correct if
       -- whatif doesn't start from current period.
       -- I THINK THIS IS NOT TRUE BECAUSE WHATIF RUNS FROM CURRENT PERIOD
       -- ANYWAY TO CALCULATE CORRECT EXPENSE IN FUTURE
       --if (not((dpr_in.y_begin = h_start_per_fy) and
       --        (dpr_in.p_cl_begin = h_start_per_num))) then
       --   dpr_in.deprn_rounding_flag := fa_std_types.FA_DPR_ROUND_RES;
       --end if;
       if (to_number(to_char(fa_cache_pkg.fazcdp_record.calendar_period_open_date, 'J')) >
           dpr_in.jdate_in_service) and
          (l_adjustment_required_status = 'ADD') then
          dpr_in.deprn_rounding_flag := fa_std_types.FA_DPR_ROUND_ADJ;
       end if;

  /*bug fix 3735661 Added this check to avoid calculation in last period*/
       if ( (X_mode ='HYPOTHETICAL')
             and
            (to_number(to_char(l_cp_start_date, 'J')) > dpr_in.jdate_in_service)
          ) then
              dpr_in.deprn_rounding_flag := fa_std_types.FA_DPR_ROUND_RES;
       end if;

       -- Call deprn engine.

       --fa_rx_conc_mesg_pkg.log('step 10');

       if X_mode in ('EXPENSED','AMORTIZED') then
          dpr_in.deprn_rounding_flag := 'ADJ';
       end if;



       if fnd_profile.value('PRINT_DEBUG') = 'Y' then

        fa_rx_conc_mesg_pkg.log('DPR_IN STRUCT:');
        fa_rx_conc_mesg_pkg.log('Contents of dpr_struct for asset_id  '||dpr_in.asset_id);
        fa_rx_conc_mesg_pkg.log('asset_num   '||dpr_in.asset_num);
        fa_rx_conc_mesg_pkg.log('book   '||dpr_in.book);
        fa_rx_conc_mesg_pkg.log('calendar_type   '||dpr_in.calendar_type);
        fa_rx_conc_mesg_pkg.log('ceil_name   '||dpr_in.ceil_name);
        fa_rx_conc_mesg_pkg.log('bonus_rule   '||dpr_in.bonus_rule);
        fa_rx_conc_mesg_pkg.log('method_code   '||dpr_in.method_code);
        fa_rx_conc_mesg_pkg.log('adj_cost   '||dpr_in.adj_cost);
        fa_rx_conc_mesg_pkg.log('rec_cost   '||dpr_in.rec_cost);
        fa_rx_conc_mesg_pkg.log('reval_amo_basis   '||dpr_in.reval_amo_basis);
        fa_rx_conc_mesg_pkg.log('deprn_rsv   '||dpr_in.deprn_rsv);
        fa_rx_conc_mesg_pkg.log('reval_rsv   '||dpr_in.reval_rsv);
   -- bonus
        fa_rx_conc_mesg_pkg.log('bonus_deprn_rsv ' || dpr_in.bonus_deprn_rsv);
        fa_rx_conc_mesg_pkg.log('adj_rate   '||dpr_in.adj_rate);
        fa_rx_conc_mesg_pkg.log('rate_adj_factor   '||dpr_in.rate_adj_factor);
        fa_rx_conc_mesg_pkg.log('capacity   '||dpr_in.capacity);
        fa_rx_conc_mesg_pkg.log('adj_capacity   '||dpr_in.adj_capacity);
        fa_rx_conc_mesg_pkg.log('ltd_prod   '||dpr_in.ltd_prod);
        fa_rx_conc_mesg_pkg.log('adj_rec_cost   '||dpr_in.adj_rec_cost);
        fa_rx_conc_mesg_pkg.log('salvage_value   '||dpr_in.salvage_value);
        fa_rx_conc_mesg_pkg.log('prior_fy_exp   '||dpr_in.prior_fy_exp);
        fa_rx_conc_mesg_pkg.log('ytd_deprn   '||dpr_in.ytd_deprn);
        fa_rx_conc_mesg_pkg.log('asset_id   '||dpr_in.asset_id);
        fa_rx_conc_mesg_pkg.log('jdate_in_service   '||dpr_in.jdate_in_service);
        fa_rx_conc_mesg_pkg.log('prorate_jdate   '||dpr_in.prorate_jdate);
        fa_rx_conc_mesg_pkg.log('deprn_start_jdate   '||dpr_in.deprn_start_jdate);
        fa_rx_conc_mesg_pkg.log('jdate_retired   '||dpr_in.jdate_retired);
        fa_rx_conc_mesg_pkg.log('ret_prorate_jdate   '||dpr_in.ret_prorate_jdate);
        fa_rx_conc_mesg_pkg.log('life   '||dpr_in.life);
        fa_rx_conc_mesg_pkg.log('prorate_year_pcal_begin   '||dpr_in.y_begin);
        fa_rx_conc_mesg_pkg.log('y_end   '||dpr_in.y_end);
        fa_rx_conc_mesg_pkg.log('p_cl_begin   '||dpr_in.p_cl_begin);
        fa_rx_conc_mesg_pkg.log('p_cl_end   '||dpr_in.p_cl_end);
        fa_rx_conc_mesg_pkg.log('pc_life_end   '||dpr_in.pc_life_end);

        if (dpr_in.rsv_known_flag) then
                fa_rx_conc_mesg_pkg.log('rsv_known_flag   '||'TRUE');
        else
                fa_rx_conc_mesg_pkg.log('rsv_known_flag   '||'FALSE');
           end if;

        fa_rx_conc_mesg_pkg.log('deprn_rounding_flag   '||dpr_in.deprn_rounding_flag);
       end if;

       -- override
       dpr_in.used_by_adjustment:= FALSE;
       dpr_in.deprn_override_flag := fa_std_types.FA_NO_OVERRIDE;

       h_mesg_name := 'FA_WHATIF_ASSET_DEPRN_ERR';
       -- bonus logic already in faxcde. dpr_arr extended with bonus_value.

       -- Polish code
       FA_POLISH_PVT.calling_mode := 'WHATIF';

--tk_util.debug('call faxcde');


--- bug 4133347 to back out deprn amount if deprn been run without closing the period.

       if h_deprn_run = 'Y' then
        dpr_in.deprn_rsv := dpr_in.deprn_rsv - dpr_row.deprn_exp;
        dpr_in.ytd_deprn := dpr_in.ytd_deprn - dpr_row.deprn_exp;
       end if;


--- Added as part of the Bug# 7234390.Since the deprn amount is calculated wrongly with fmode parameter =fa_std_types.FA_DPR_PROJECT.
  --- Hence fmode parameter is passed as fa_std_types.FA_DPR_NORMAL for JP-STL-EXTND.

           h_fmode := fa_std_types.FA_DPR_PROJECT;
           IF dpr_in.method_code = 'JP-STL-EXTND' THEN
            BEGIN
             SELECT COUNT(1)
             INTO h_count
             from fa_deprn_summary
             where book_type_code = dpr_in.book
             and  asset_id = dpr_in.asset_id
             and  period_counter = fa_cache_pkg.fazcdp_record.period_counter - 1;
            exception
              when others then
               h_count := 0;
             end;

             if h_count > 0 then
                dpr_in.p_cl_begin := fa_cache_pkg.fazcdp_record.period_num;
                dpr_in.y_begin := fa_cache_pkg.fazcdp_record.fiscal_year;
             end if;
            h_fmode := fa_std_types.FA_DPR_NORMAL;
            dpr_in.deprn_rounding_flag := 'ADJ' ;                               -- Added as part of the bug 7290365.
           END IF;

           -- BUG # 7193797 :  the deprn amount is calculated wrongly with fmode parameter
           -- as fa_std_types.FA_DPR_PROJECT.
           -- Hence fmode parameter is passed as fa_std_types.FA_DPR_NORMAL for JP-250DB XX.
           if nvl(fa_cache_pkg.fazccmt_record.guarantee_rate_method_flag,'NO') = 'YES' then   --- for Method JP-250db XX
              h_fmode := fa_std_types.FA_DPR_NORMAL;
              dpr_in.deprn_rounding_flag := 'ADJ';                                -- Added as part of the bug 7290365. The Year end rounding was wrongly calculated.
           end if;
           --- BUG # 7193797: End of Addition
       /*Bug 8518086 intialized the Set of books ID to pass it in DPR_IN */
       dpr_in.set_of_books_id := FARX_C_WD.sob_id;
       ret := fa_cde_pkg.faxcde(dpr_in => dpr_in,
                                dpr_arr => dpr_arr,
                                dpr_out => dpr_out,
                                fmode => h_fmode,
                                p_log_level_rec => null) ; --fa_std_types.FA_DPR_PROJECT);

--- End of Addition as part of the Bug 7234390
--tk_util.debug('after faxcde');
       if (ret = FALSE) then
--tk_util.debug('faxcde returned false');
          fa_srvr_msg.get_message(mesg_count,mesg1,mesg2,mesg3,mesg4,
                mesg5,mesg6,mesg7);

          fa_rx_conc_mesg_pkg.log(mesg1);
          fa_rx_conc_mesg_pkg.log(mesg2);
          fa_rx_conc_mesg_pkg.log(mesg3);
          fa_rx_conc_mesg_pkg.log(mesg4);
          fa_rx_conc_mesg_pkg.log(mesg5);
          fa_rx_conc_mesg_pkg.log(mesg6);
          fa_rx_conc_mesg_pkg.log(mesg7);


          x_return_status := 2;
          return (FALSE);
       end if;

       -- FIGURE OUT WHICH PERIODS' RESULTS WE ARE INTERESTED IN SHOWING
       -- TO THE USER.  IF USER'S START PERIOD IS IN THE FUTURE, DON'T
       -- SHOW RESULTS FROM BEFORE START PERIOD.

       h_mesg_name := 'FA_WHATIF_ASSET_DEPRN_EXP_ERR';

       h_start_index := 0;
       h_end_index := X_num_pers - 1;
       h_delta_index := 0;

       h_chrono_cur_per := dpr_in.y_begin * h_num_per_fy + dpr_in.p_cl_begin;
       h_chrono_start_per := h_start_per_fy * h_num_per_fy + h_start_per_num;


       if h_chrono_start_per < h_chrono_cur_per then
          h_end_index := h_end_index + h_chrono_start_per - h_chrono_cur_per;
       elsif h_chrono_start_per > h_chrono_cur_per then
          h_end_index := h_end_index + h_chrono_start_per - h_chrono_cur_per;
          h_start_index := h_chrono_start_per - h_chrono_cur_per;
       end if;

       h_deprn_rsv := nvl(X_deprn_rsv,0);


-- fa_rx_conc_mesg_pkg.log('orig.fiscal_year: ' || dpr_arr(0).fiscal_year);
-- fa_rx_conc_mesg_pkg.log('new.fiscal_year: ' || h_start_per_fy);
-- fa_rx_conc_mesg_pkg.log('num per fy: ' || fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR);
-- fa_rx_conc_mesg_pkg.log('h_start_per_num: ' || h_start_per_num );

       l_st_period_counter := h_start_per_fy *
                           fa_cache_pkg.fazcct_record.NUMBER_PER_FISCAL_YEAR +
                                h_start_per_num;

--fa_rx_conc_mesg_pkg.log('l_st_period_counter: ' || l_st_period_counter);

-- dpr_arr(0).period_num is wrong as start period, it will only
--  cause current open period to be used.

      -- Added by Satish Byreddy for Bug# 7128175  . This will calculate the Depreciation from the First Period of Extended Depren
      if dpr_in.method_code = 'JP-STL-EXTND' THEN
      -- Below two lines have been commented as the What IF deprn by Satish Byreddy as part of Bug 7139130.
      -- h_start_index := 0;
      -- h_end_index := X_num_pers - 1;
      -- End of Commenting
       if h_chrono_start_per < h_chrono_cur_per then
        h_delta_index := h_chrono_cur_per - h_chrono_start_per ;
       end if;
      end if;

       l_ed_period_counter := l_st_period_counter + h_end_index;
--tk_util.debug('before fetching periods');
       if (nvl(tb_period_name.last, 0) = 0) then
          OPEN c_get_period_rec;
          FETCH c_get_period_rec BULK COLLECT INTO tb_period_name,
                                                   tb_period_num,
                                                   tb_fiscal_year;
          CLOSE c_get_period_rec;
       end if;

-- Added by Satish Byreddy for Bug# 7128175  . This will calculate the Depreciation from the First Period of Extended Depren

if dpr_in.method_code = 'JP-STL-EXTND' THEN
  if h_chrono_start_per < h_chrono_cur_per then   -- If condition Added by Satish Byreddy for Bug# 7135753   . This will calculate the Depreciation from the First Period of Extended Depren.
            for h_count in 0 .. (h_delta_index - 1) loop
               if (X_mode in ('NORMAL','HYPOTHETICAL')) then
                  --fa_rx_conc_mesg_pkg.log('step 11');

                  -- POPULATE DEPRECIATION COLUMN, SELECTING PERIOD_NAME IN
                  -- LIEU OF NUMBER/YEAR

                  G_deprn(h_count ).deprn := 0;
                  G_deprn(h_count ).fiscal_year :=
                                                      dpr_arr(h_count).fiscal_year;
                  h_deprn_rsv := h_deprn_rsv + 0; -- df
                  G_deprn(h_count).new_rsv := h_deprn_rsv; -- df
                  -- bonus
                  G_deprn(h_count).bonus_deprn := 0;

                  G_deprn(h_count ).period_name :=
                                        tb_period_name(h_count - h_start_index + 1);
                  G_deprn(h_count ).period_num :=
                                        tb_period_num(h_count - h_start_index + 1);
                  G_deprn(h_count ).new_deprn := G_deprn(h_count - h_start_index).deprn;
                  -- bonus
                  G_deprn(h_count).new_bonus_deprn := G_deprn(h_count - h_start_index).bonus_deprn;

              end if;
           end loop;
      end if;   -- end of If Condition
     end if;

-- fa_rx_conc_mesg_pkg.log('before loop');
-- fa_rx_conc_mesg_pkg.log('start pc' || l_st_period_counter);
-- fa_rx_conc_mesg_pkg.log('end pc' || l_ed_period_counter);
-- fa_rx_conc_mesg_pkg.log('last: '||to_char(tb_period_name.last));
-- fa_rx_conc_mesg_pkg.log('X_mode: '||X_mode);
-- fa_rx_conc_mesg_pkg.log('h_adj_prev_deprn_exp: '||to_char(h_adj_prev_deprn_exp));

-- Added by Satish Byreddy for Bug# 7128175  . This will calculate the Depreciation from the First Period of Extended Depren


for h_count in (h_start_index + h_delta_index) .. h_end_index loop
       if (X_mode in ('NORMAL','HYPOTHETICAL')) then
          --fa_rx_conc_mesg_pkg.log('step 11');

          -- POPULATE DEPRECIATION COLUMN, SELECTING PERIOD_NAME IN
          -- LIEU OF NUMBER/YEAR
          -- BUG # 7193797Added the Begin , Exception in order to handle  the case when Number of periods is More than
          -- the remaining life of the asset ( JP-250DB XX),  NO_DATA_FOUND error is raised.
        BEGIN
          G_deprn(h_count - h_start_index).deprn := dpr_arr(h_count - h_delta_index).value;
          G_deprn(h_count - h_start_index).fiscal_year :=
                                              dpr_arr(h_count - h_delta_index).fiscal_year;
          h_deprn_rsv := h_deprn_rsv + dpr_arr(h_count - h_delta_index).value; -- df
          G_deprn(h_count - h_start_index).new_rsv := h_deprn_rsv; -- df
          -- bonus
          G_deprn(h_count - h_start_index).bonus_deprn := dpr_arr(h_count - h_delta_index).bonus_value;

          G_deprn(h_count - h_start_index).period_name := tb_period_name(h_count - h_start_index + 1);
          G_deprn(h_count - h_start_index).period_num :=  tb_period_num(h_count - h_start_index + 1);
          G_deprn(h_count - h_start_index).new_deprn := G_deprn(h_count - h_start_index ).deprn;
          -- bonus
          G_deprn(h_count - h_start_index).new_bonus_deprn :=  G_deprn(h_count - h_start_index).bonus_deprn;
        EXCEPTION                  ---- BUG # 7193797Added the exception when Number of periods is More than the remaining life of the asset ( JP-250DB XX),  NO_DATA_FOUND error is raised.
          WHEN NO_DATA_FOUND THEN
           G_deprn(h_count - h_start_index).deprn := 0;
           h_deprn_rsv := h_deprn_rsv + G_deprn(h_count - h_start_index).deprn; -- df
           G_deprn(h_count - h_start_index).new_rsv := h_deprn_rsv;
           G_deprn(h_count - h_start_index).bonus_deprn := 0;
           G_deprn(h_count - h_start_index).new_deprn := 0;
           G_deprn(h_count - h_start_index).new_bonus_deprn := 0;
           G_deprn(h_count - h_start_index).period_name := tb_period_name(h_count - h_start_index + 1);
           G_deprn(h_count - h_start_index).period_num :=  tb_period_num(h_count - h_start_index + 1);
           G_deprn(h_count - h_start_index).fiscal_year := tb_fiscal_year(h_count - h_start_index + 1);
        end;
 -- BUG # 7193797 -- End Of Addition

       else   -- WE DID ADJUSTMENT, SO POPULATE NEW_DEPRECIATION

          -- Commenting this code for bug fix 2273276
          -- Discussed this bug with Gary and Decided not to add the
          -- catchup to the New Depreciation*/


          -- Adding this for bug fix 2273276
          -- Here New Depreciation is calculated without adding the catchup
--tk_util.debug('h_count:h_start_index: '||to_char(h_count)||':'||to_char(h_start_index));
          G_deprn(h_count - h_start_index).new_deprn := dpr_arr(h_count).value;
          -- bonus
          G_deprn(h_count - h_start_index).new_bonus_deprn :=
                              dpr_arr(h_count).bonus_value;


       end if;

    end loop;

    -- clear dpr_arr tables

    dpr_arr.delete;

--    errbuf := '';
--tk_util.debug('end of whatif calc');
    return ret;

exception
   when cache_err then
--tk_util.debug('cache_err: '||sqlerrm);
      x_return_status := 2;

      if SQLCODE <> 0 then
         fa_Rx_conc_mesg_pkg.log(SQLERRM);
      end if;

      g_deprn.delete;
      fnd_message.set_name('OFA',h_mesg_name);
      if h_mesg_name like 'FA_WHATIF_ASSET%' then
         fnd_message.set_token('ASSET_ID',X_asset_id,FALSE);
      end if;
      h_mesg_str := fnd_message.get;
      fa_rx_conc_mesg_pkg.log(h_mesg_str);

      return FALSE;

   when others then
--tk_util.debug('others: '||sqlerrm);
      x_return_status := 2;

      if SQLCODE <> 0 then
         fa_Rx_conc_mesg_pkg.log(SQLERRM);
      end if;

      g_deprn.delete;
      fnd_message.set_name('OFA',h_mesg_name);
      if h_mesg_name like 'FA_WHATIF_ASSET%' then
         fnd_message.set_token('ASSET_ID',X_asset_id,FALSE);
      end if;
      h_mesg_str := fnd_message.get;
      fa_rx_conc_mesg_pkg.log(h_mesg_str);

      return FALSE;


end whatif_deprn_asset;



function whatif_insert_itf (
        X_asset_id      in number,
        X_book          in varchar2,
        X_request_id    in number,
        X_num_pers      in number,
        X_acct_struct   in number,
        X_key_struct    in number,
        X_cat_struct    in number,
        X_loc_struct    in number,
        X_precision     in number,
        X_user_id       in number,
        X_login_id      in number,
        X_last_asset    in boolean default false,
        x_return_status out nocopy number) return boolean is

h_dist_book             fa_book_controls.distribution_source_book%TYPE;
h_asset_number          varchar2(15);
h_description           varchar2(80);
h_tag_number            varchar2(15);
h_serial_number         varchar2(35);
h_total_units           number;
h_dist_units            number;
h_dist_deprn            number;
h_dist_new_deprn        number;
h_dist_new_rsv          number;

-- bonus
h_dist_bonus_deprn      number;
h_dist_new_bonus_deprn  number;

h_ccid                  number;
h_concat_acct           varchar2(500);
h_segs                  fa_rx_shared_pkg.Seg_Array;

h_category_id           number;
h_concat_cat            varchar2(500);

h_asset_key_id          number;
h_concat_key            varchar2(500);

h_location_id           number;
h_concat_loc            varchar2(500);

h_employee_number       varchar2(30);
h_employee_name         varchar2(240);

h_current_cost          number;
h_current_prorate_conv  varchar2(15);
h_current_method        varchar2(15);
h_current_life          number;
h_current_basic_rate    number;
h_current_adjusted_rate number;
h_current_salvage_value number;
h_current_bonus_rule    varchar2(30);
h_current_dpis          date;

h_dist_cost             number;
h_count                 number;

  h_mesg_name  varchar2(30);
  h_mesg_str   varchar2(2000);
  h_flex_error varchar2(5);
  h_ccid_error number;
  h_currency   varchar2(15);

ret                     boolean;

-- SELECTS DIST INFO FOR A GIVEN ASSET

  cursor dist_book is
  Select distribution_source_book
  From fa_book_controls
  Where book_type_code = X_book;


  cursor dist_lines is
   select dh.units_assigned, dh.code_combination_id, dh.location_id,
   emp.employee_number, emp.full_name
   from fa_distribution_history dh, per_all_people_f emp
   where emp.person_id (+) = dh.assigned_to
   and  trunc(sysdate) between emp.effective_start_date(+) and emp.effective_end_date(+)
   and dh.book_type_code = h_dist_book
   and dh.asset_id = X_asset_id
   and dh.date_ineffective is null;

  i BINARY_INTEGER;
  old_i BINARY_INTEGER;
  l_limit  BINARY_INTEGER := nvl(fa_cache_pkg.fa_batch_size, 500);

begin

ret := TRUE;

 -- SELECT ASSET-LEVEL INFO USER MAY BE INTERESTED IN

  h_mesg_name := 'FA_WHATIF_ASSET_INFO';

  select description, tag_number, serial_number, asset_number,
        asset_key_ccid, current_units, asset_category_id
  into h_description, h_tag_number, h_serial_number, h_asset_number,
        h_asset_key_id, h_total_units, h_category_id
  from fa_additions
  where asset_id = X_asset_id;

 -- SELECT CURRENT (BEFORE ADJUSTMENT) BOOK-LEVEL INFO

  h_mesg_name := 'FA_WHATIF_ASSET_DEPRN_INFO';
-- bug32118506
  if(FARX_C_WD.mrc_sob_type in ('P','N')) then -- Enhancement Bug 3037321

     select cost, prorate_convention_code, deprn_method_code,
        life_in_months, basic_rate, adjusted_rate, salvage_value, bonus_rule,
           date_placed_in_service
     into h_current_cost, h_current_prorate_conv, h_current_method,
        h_current_life, h_current_basic_rate, h_current_adjusted_rate,
        h_current_salvage_value, h_current_bonus_rule,
           h_current_dpis
     from fa_books
     where asset_id = X_asset_id
     and book_type_code = X_book
     and transaction_header_id_out is null;

  else

     select cost, prorate_convention_code, deprn_method_code,
           life_in_months, basic_rate, adjusted_rate, salvage_value, bonus_rule,
           date_placed_in_service
     into h_current_cost, h_current_prorate_conv, h_current_method,
           h_current_life, h_current_basic_rate, h_current_adjusted_rate,
           h_current_salvage_value, h_current_bonus_rule,
           h_current_dpis
     from fa_mc_books
     where asset_id = X_asset_id
     and book_type_code = X_book
     and transaction_header_id_out is null
     and set_of_books_id = FARX_C_WD.sob_id;

  end if;

if (h_asset_key_id is not null) then



   h_mesg_name := 'FA_RX_CONCAT_SEGS';
   h_flex_error := 'KEY#';
   h_ccid_error := h_asset_key_id;

  fa_rx_shared_pkg.concat_asset_key (
        struct_id => X_key_struct,
        ccid => h_asset_key_id,
        concat_string => h_concat_key,
        segarray => h_segs);
end if;

   h_flex_error := 'CAT#';
   h_ccid_error := h_category_id;

  fa_rx_shared_pkg.concat_category (
        struct_id => X_cat_struct,
        ccid => h_category_id,
        concat_string => h_concat_cat,
        segarray => h_segs);



  h_mesg_name := 'FA_WHATIF_ASSET_DIST_INFO';


  --
  -- Replace using cache.
  --
  --Open dist_book;
  --fetch dist_book into h_dist_book;
  --close dist_book;

  h_dist_book := fa_cache_pkg.fazcbc_record.distribution_source_book;

--tk_util.debug('t_ind1: '||to_char(t_ind));
  old_i := t_ind;
  i := t_ind;

  open dist_lines;
  loop   -- for each distribution


    fetch dist_lines into
        h_dist_units,
        h_ccid,
        h_location_id,
        h_employee_number,
        h_employee_name;



    if (dist_lines%NOTFOUND) then exit;   end if;


  -- FOR EACH DIST, WE:
  -- 1. GET ACCT AND LOC FLEX.
  -- 2. ALLOCATE EXPENSE AND COST EVENLY.


   h_mesg_name := 'FA_RX_CONCAT_SEGS';
   h_flex_error := 'GL#';
   h_ccid_error := h_ccid;


    fa_rx_shared_pkg.concat_acct (
        struct_id => X_acct_struct,
        ccid => h_ccid,
        concat_string => h_concat_acct,
        segarray => h_segs);



      h_dist_cost := round(h_current_cost * h_dist_units / h_total_units,
                                X_precision);


   h_flex_error := 'LOC#';
   h_ccid_error := h_location_id;

     fa_rx_shared_pkg.concat_location (
        struct_id => X_loc_struct,
        ccid => h_location_id,
        concat_string => h_concat_loc,
        segarray => h_segs);

      -- Enhancement bug 3037321
      select currency_code
      into h_currency
      from gl_sets_of_books
      where set_of_books_id = FARX_C_WD.sob_id;

    h_count := 0;
    loop  -- for each period

      if h_count >= X_num_pers then
         exit;
      end if;

       i := i + 1;

      h_mesg_name := 'FA_WHATIF_ASSET_NEW_DEPRN';

      if (g_deprn(h_count).deprn is not null) then
        h_dist_deprn :=
          round(g_deprn(h_count).deprn *
                h_dist_units / h_total_units,
                X_precision);

      else h_dist_deprn := null;
      end if;


      if (g_deprn(h_count).new_deprn is not null) then
         h_dist_new_deprn := round(g_deprn(h_count).new_deprn
                                *h_dist_units / h_total_units, X_precision);

      else h_dist_new_deprn := null;
      end if;

      if (g_deprn(h_count).new_rsv is not null) then
         h_dist_new_rsv := round(g_deprn(h_count).new_rsv
                                *h_dist_units / h_total_units, X_precision);

      else h_dist_new_rsv := null;
      end if;

      -- bonus
      if (g_deprn(h_count).bonus_deprn is not null) then
        h_dist_bonus_deprn :=
          round(g_deprn(h_count).bonus_deprn *
                h_dist_units / h_total_units,
                X_precision);

      else h_dist_bonus_deprn := null;
      end if;

      if (g_deprn(h_count).new_bonus_deprn is not null) then
         h_dist_new_bonus_deprn := round(g_deprn(h_count).new_bonus_deprn
                                *h_dist_units / h_total_units, X_precision);

      else h_dist_new_bonus_deprn := null;
      end if;

      -- end bonus

      h_mesg_name := 'FA_SHARED_INSERT_FAIL';

      t_request_id(i)             := X_request_id;
      t_book_type_code(i)         := X_book;
      t_asset_id(i)               := X_asset_id;
      t_asset_number(i)           := h_asset_number;
      t_description(i)            := h_description;
      t_tag_number(i)             := h_tag_number;
      t_serial_number(i)          := h_serial_number;
      t_period_name(i)            := g_deprn(h_count).period_name;
      t_fiscal_year(i)            := g_deprn(h_count).fiscal_year;
      t_expense_acct(i)           := h_concat_acct;
      t_location(i)               := h_concat_loc;
      t_units(i)                  := h_dist_units;
      t_employee_name(i)          := h_employee_name;
      t_employee_number(i)        := h_employee_number;
      t_asset_key(i)              := h_concat_key;
      t_current_cost(i)           := h_dist_cost;
      t_current_prorate_conv(i)   := h_current_prorate_conv;
      t_current_method(i)         := h_current_method;
      t_current_life(i)           := h_current_life;
      t_current_basic_rate(i)     := h_current_basic_rate;
      t_current_adjusted_rate(i)  := h_current_adjusted_rate;
      t_current_salvage_value(i)  := h_current_salvage_value;
      t_depreciation(i)           := h_dist_deprn;
      t_new_depreciation(i)       := h_dist_new_deprn;
      t_created_by(i)             := X_user_id;
      t_creation_date(i)          := sysdate;
      t_last_update_date(i)       := sysdate;
      t_last_updated_by(i)        := X_user_id;
      t_last_update_login(i)      := X_login_id;
      t_date_placed_in_service(i) := h_current_dpis;
      t_category(i)               := h_concat_cat;
      t_accumulated_deprn(i)      := h_dist_new_rsv;
      t_bonus_depreciation(i)     := h_dist_bonus_deprn;
      t_new_bonus_depreciation(i) := h_dist_new_bonus_deprn;
      t_current_bonus_rule(i)     := h_current_bonus_rule;
      t_period_num(i)             := g_deprn(h_count).period_num;
      t_currency_code(i)          := h_currency;

      h_count := h_count + 1;

     h_mesg_name := 'FA_WHATIF_ASSET_DIST_INFO';

    end loop;
  end loop;

  close dist_lines;


--tk_util.debug('t_ind2: '||to_char(t_ind));
--tk_util.debug('i: '||to_char(i));


   t_ind := i;

  if (t_ind >= l_limit) or (X_last_asset) then
     FORALL j in t_request_id.FIRST..t_request_id.LAST
     INSERT INTO FA_WHATIF_ITF(
                   request_id
                 , book_type_code
                 , asset_id
                 , asset_number
                 , description
                 , tag_number
                 , serial_number
                 , period_name
                 , fiscal_year
                 , expense_acct
                 , location
                 , units
                 , employee_name
                 , employee_number
                 , asset_key
                 , current_cost
                 , current_prorate_conv
                 , current_method
                 , current_life
                 , current_basic_rate
                 , current_adjusted_rate
                 , current_salvage_value
                 , depreciation
                 , new_depreciation
                 , created_by
                 , creation_date
                 , last_update_date
                 , last_updated_by
                 , last_update_login
                 , date_placed_in_service
                 , category
                 , accumulated_deprn
                 , bonus_depreciation
                 , new_bonus_depreciation
                 , current_bonus_rule
                 , period_num
                 , currency_code)
          VALUES(  t_request_id(j)
                 , t_book_type_code(j)
                 , t_asset_id(j)
                 , t_asset_number(j)
                 , t_description(j)
                 , t_tag_number(j)
                 , t_serial_number(j)
                 , t_period_name(j)
                 , t_fiscal_year(j)
                 , t_expense_acct(j)
                 , t_location(j)
                 , t_units(j)
                 , t_employee_name(j)
                 , t_employee_number(j)
                 , t_asset_key(j)
                 , t_current_cost(j)
                 , t_current_prorate_conv(j)
                 , t_current_method(j)
                 , t_current_life(j)
                 , t_current_basic_rate(j)
                 , t_current_adjusted_rate(j)
                 , t_current_salvage_value(j)
                 , t_depreciation(j)
                 , t_new_depreciation(j)
                 , t_created_by(j)
                 , t_creation_date(j)
                 , t_last_update_date(j)
                 , t_last_updated_by(j)
                 , t_last_update_login(j)
                 , t_date_placed_in_service(j)
                 , t_category(j)
                 , t_accumulated_deprn(j)
                 , t_bonus_depreciation(j)
                 , t_new_bonus_depreciation(j)
                 , t_current_bonus_rule(j)
                 , t_period_num(j)
                 , t_currency_code(j));

     t_ind := 0;
     t_request_id.delete;
     t_book_type_code.delete;
     t_asset_id.delete;
     t_asset_number.delete;
     t_description.delete;
     t_tag_number.delete;
     t_serial_number.delete;
     t_period_name.delete;
     t_fiscal_year.delete;
     t_expense_acct.delete;
     t_location.delete;
     t_units.delete;
     t_employee_name.delete;
     t_employee_number.delete;
     t_asset_key.delete;
     t_current_cost.delete;
     t_current_prorate_conv.delete;
     t_current_method.delete;
     t_current_life.delete;
     t_current_basic_rate.delete;
     t_current_adjusted_rate.delete;
     t_current_salvage_value.delete;
     t_depreciation.delete;
     t_new_depreciation.delete;
     t_created_by.delete;
     t_creation_date.delete;
     t_last_update_date.delete;
     t_last_updated_by.delete;
     t_last_update_login.delete;
     t_date_placed_in_service.delete;
     t_category.delete;
     t_accumulated_deprn.delete;
     t_bonus_depreciation.delete;
     t_new_bonus_depreciation.delete;
     t_current_bonus_rule.delete;
     t_period_num.delete;
     t_currency_code.delete;

commit;
  end if;


--  errbuf := '';
  return ret;

exception

  when others then


     if SQLCODE <> 0 then
       fa_Rx_conc_mesg_pkg.log(SQLERRM);
     end if;

     if (dist_lines%ISOPEN) then
        close dist_lines;
     end if;

        g_deprn.delete;
        fnd_message.set_name('OFA',h_mesg_name);
        if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
          fnd_message.set_token('TABLE','FA_WHATIF_ITF',FALSE);
        end if;
        if h_mesg_name like 'FA_WHATIF_ASSET%' then
          fnd_message.set_token('ASSET_ID',X_asset_id,FALSE);
        end if;
        if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
          fnd_message.set_token('CCID',h_ccid_error,FALSE);
          fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
        end if;
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        x_return_status := 2;
        return FALSE;


end whatif_insert_itf;

END FA_WHATIF_DEPRN_PKG;

/
