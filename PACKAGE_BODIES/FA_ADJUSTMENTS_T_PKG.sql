--------------------------------------------------------
--  DDL for Package Body FA_ADJUSTMENTS_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ADJUSTMENTS_T_PKG" AS
/* $Header: fapadjtb.pls 120.1.12010000.8 2010/04/29 12:21:22 deemitta ship $ */

procedure prepare(w_clause in varchar2, p_batch_id in number, action_flag in varchar2) is

type refcrs is ref cursor;
type chartbltyp is table of varchar2(255);
type numtbltyp  is table of number;
type datetbltyp is table of date;

l_asset_number                       chartbltyp;
l_asset_type                         chartbltyp;
l_attribute_category_code            chartbltyp;
l_bonus_rule                         chartbltyp;
l_book_type_code                     chartbltyp;
l_ceiling_name                       chartbltyp;
l_depreciate_flag                    chartbltyp;
l_deprn_limit_type                   chartbltyp;
l_deprn_method_code                  chartbltyp;
l_description                        chartbltyp;
l_extended_deprn_flag                chartbltyp;
l_period_name                        chartbltyp;
l_prorate_convention_code            chartbltyp;
l_short_fiscal_year_flag             chartbltyp;
l_transaction_name                   chartbltyp;
l_adjusted_rate                      numtbltyp;
l_allowed_deprn_limit                numtbltyp;
l_allowed_deprn_limit_amount         numtbltyp;
l_basic_rate                         numtbltyp;
l_cost                               numtbltyp;
l_deprn_reserve                      numtbltyp;
l_extended_depreciation_period       numtbltyp;
l_fully_rsvd_revals_counter          numtbltyp;
l_group_asset_id                     numtbltyp;
l_itc_amount_id                      numtbltyp;
l_life_in_months                     numtbltyp;
l_original_cost                      numtbltyp;
l_period_counter_fully_rsv           numtbltyp;
l_production_capacity                numtbltyp;
l_reval_amortization_basis           numtbltyp;
l_reval_ceiling                      numtbltyp;
l_reval_reserve                      numtbltyp;
l_salvage_value                      numtbltyp;
l_unrevalued_cost                    numtbltyp;
l_ytd_deprn                          numtbltyp;
l_ytd_reval_deprn_expense            numtbltyp;
l_batch_id                           numtbltyp;
l_amortization_start_date            datetbltyp;
l_conversion_date                    datetbltyp;
l_date_placed_in_service             datetbltyp;
l_original_deprn_start_date          datetbltyp;
rc_extended_deprn                    refcrs;
l_query                              varchar2(5000);
l_calling_fn                         varchar2(50) := 'FA_ADJUSTMENTS_T_PKG.submit';
v_err_code                           number;
v_err_msg                            varchar2(255);

l_batch_size                         number;
l_pctr                               number;
l_name                               varchar2(15);
l_count                              number := 0;
l_imp_reserve                        numtbltyp;  --phase5

cursor c_books is
select asset_number anum
     , book_type_code book
     , allowed_deprn_limit_amount limit_amt
  from fa_adjustments_t
 where extended_deprn_flag = 'Y'
   and batch_id = p_batch_id
 order by asset_number;

cursor all_books is
select asset_id aid
     , fat.asset_number anum
     , book_type_code book
  from fa_adjustments_t fat
     , fa_additions_b fab
 where batch_id = p_batch_id
   and fat.asset_number = fab.asset_number
 order by book_type_code;


cursor set_period_name is
select fadp.period_name name
     , fat.asset_number num
     , fat.book_type_code book
  from fa_deprn_periods fadp
     , fa_adjustments_t fat
 where fadp.period_counter = fat.period_counter_fully_reserved
   and fadp.book_type_code = fat.book_type_code
   and fat.batch_id = p_batch_id;

begin

l_batch_size  := nvl(fa_cache_pkg.fa_batch_size, 200);

l_query := 'select asset_number,
                   asset_type,
                   attribute_category_code,
                   bonus_rule,
                   book_type_code,
                   ceiling_name,
                   depreciate_flag,
                   deprn_limit_type,
                   deprn_method_code,
                   description,
                   extended_deprn_flag,
                   period_name,
                   prorate_convention_code,
                   short_fiscal_year_flag,
                   transaction_name,
                   adjusted_rate,
                   allowed_deprn_limit,
                   allowed_deprn_limit_amount,
                   basic_rate,
                   cost,
                   deprn_reserve,
                   extended_depreciation_period,
                   fully_rsvd_revals_counter,
                   group_asset_id,
                   itc_amount_id,
                   life_in_months,
                   original_cost,
                   period_counter_fully_reserved,
                   production_capacity,
                   reval_amortization_basis,
                   reval_ceiling,
                   reval_reserve,
                   salvage_value,
                   unrevalued_cost,
                   ytd_deprn,
                   ytd_reval_deprn_expense,
                   amortization_start_date,
                   conversion_date,
                   date_placed_in_service,
                   original_deprn_start_date,
		   impairment_reserve,
                   '||p_batch_id||'
            from   fa_extended_deprn_v
            where '|| w_clause ||' ';


   open rc_extended_deprn for l_query;
   loop

        fetch rc_extended_deprn bulk collect into
              l_asset_number,
              l_asset_type,
              l_attribute_category_code,
              l_bonus_rule,
              l_book_type_code,
              l_ceiling_name,
              l_depreciate_flag,
              l_deprn_limit_type,
              l_deprn_method_code,
              l_description,
              l_extended_deprn_flag,
              l_period_name,
              l_prorate_convention_code,
              l_short_fiscal_year_flag,
              l_transaction_name,
              l_adjusted_rate,
              l_allowed_deprn_limit,
              l_allowed_deprn_limit_amount,
              l_basic_rate,
              l_cost,
              l_deprn_reserve,
              l_extended_depreciation_period,
              l_fully_rsvd_revals_counter,
              l_group_asset_id,
              l_itc_amount_id,
              l_life_in_months,
              l_original_cost,
              l_period_counter_fully_rsv,
              l_production_capacity,
              l_reval_amortization_basis,
              l_reval_ceiling,
              l_reval_reserve,
              l_salvage_value,
              l_unrevalued_cost,
              l_ytd_deprn,
              l_ytd_reval_deprn_expense,
              l_amortization_start_date,
              l_conversion_date,
              l_date_placed_in_service,
              l_original_deprn_start_date,
	      l_imp_reserve,
              l_batch_id LIMIT l_batch_size;

     --#bug 7608247 Moved this check to exit above insert statement.
     --Removed for bug 7632858
     --exit when rc_extended_deprn%notfound;

     --if rc_extended_deprn%rowcount > 0   then
     /* Added for 7632858 */
     if l_asset_number.count > 0   then

           forall j in l_asset_number.first..l_asset_number.last
              insert into fa_adjustments_t
              (
               asset_number,
               asset_type,
               attribute_category_code,
               bonus_rule,
               book_type_code,
               ceiling_name,
               depreciate_flag,
               deprn_limit_type,
               deprn_method_code,
               description,
               extended_deprn_flag,
               period_name,
               prorate_convention_code,
               short_fiscal_year_flag,
               transaction_name,
               adjusted_rate,
               allowed_deprn_limit,
               allowed_deprn_limit_amount,
               basic_rate,
               cost,
               deprn_reserve,
               extended_depreciation_period,
               fully_rsvd_revals_counter,
               group_asset_id,
               itc_amount_id,
               life_in_months,
               original_cost,
               period_counter_fully_reserved,
               production_capacity,
               reval_amortization_basis,
               reval_ceiling,
               reval_reserve,
               salvage_value,
               unrevalued_cost,
               ytd_deprn,
               ytd_reval_deprn_expense,
               amortization_start_date,
               conversion_date,
               date_placed_in_service,
               original_deprn_start_date,
	       impairment_reserve,
               batch_id,
               request_id
               )
               values
               (
               l_asset_number(j),
               l_asset_type(j),
               l_attribute_category_code(j),
               l_bonus_rule(j),
               l_book_type_code(j),
               l_ceiling_name(j),
               l_depreciate_flag(j),
               l_deprn_limit_type(j),
               l_deprn_method_code(j),
               l_description(j),
               l_extended_deprn_flag(j),
               l_period_name(j),
               l_prorate_convention_code(j),
               l_short_fiscal_year_flag(j),
               l_transaction_name(j),
               l_adjusted_rate(j),
               l_allowed_deprn_limit(j),
               l_allowed_deprn_limit_amount(j),
               l_basic_rate(j),
               l_cost(j),
               l_deprn_reserve(j),
               l_extended_depreciation_period(j),
               l_fully_rsvd_revals_counter(j),
               l_group_asset_id(j),
               l_itc_amount_id(j),
               l_life_in_months(j),
               l_original_cost(j),
               l_period_counter_fully_rsv(j),
               l_production_capacity(j),
               l_reval_amortization_basis(j),
               l_reval_ceiling(j),
               l_reval_reserve(j),
               l_salvage_value(j),
               l_unrevalued_cost(j),
               l_ytd_deprn(j),
               l_ytd_reval_deprn_expense(j),
               l_amortization_start_date(j),
               l_conversion_date(j),
               l_date_placed_in_service(j),
               l_original_deprn_start_date(j),
	       l_imp_reserve(j),
               l_batch_id(j),
               -1*l_batch_id(j));

        end if;

   commit work;

--Added for bug 7632858

exit when l_asset_number.count < l_batch_size;

 --exit when rc_extended_deprn%notfound;

 --#bug 7608247 Moved this check to exit above insert statement.

   end loop;

   close rc_extended_deprn;

   -- set the value of extended_deprn_period_name for assets with extended_deprn_flag = 'Y'
   if (action_flag = 'U')then -- taking cases when Y->N is done or Y->Y ro Y->U

         for i in c_books loop
               l_count := l_count + 1;

               select   cp.period_name  name
               into     l_name
               from     fa_book_controls bc
                      , fa_fiscal_year fy
                      , fa_calendar_types ct
                      , fa_calendar_periods cp
                      , fa_adjustments_t fat
               where    bc.book_type_code = i.book
               and      fat.batch_id = p_batch_id
               and      fat.asset_number = i.anum
               and      bc.deprn_calendar = ct.calendar_type
               and      cp.calendar_type = ct.calendar_type
               and      bc.fiscal_year_name = ct.fiscal_year_name
               and      fy.fiscal_year_name = ct.fiscal_year_name
               and      cp.period_num = 1
               and      cp.start_date >= to_date('01/04/2007', 'DD/MM/RRRR')
               and      fy.fiscal_year = (fat.extended_depreciation_period-1)/ct.number_per_fiscal_year
               and      cp.start_date = fy.start_date;

               update  fa_adjustments_t
                  set  extended_deprn_period_name = l_name
                    ,  extended_deprn_limit = i.limit_amt
                where  book_type_code = i.book
                  and  asset_number = i.anum
                  and  batch_id = p_batch_id;

               if( mod(l_count,l_batch_size) = 0 )then
                   commit work;
               end if;

         end loop;
   end if;

   -- set the period name of period when fully reserved
   l_count := 0;

   for i in set_period_name loop
      l_count := l_count + 1;

       update  fa_adjustments_t
            set  period_name = i.name
          where  book_type_code = i.book
            and asset_number = i.num
            and  batch_id = p_batch_id;

       if( mod(l_count,l_batch_size) = 0 )then
          commit work;
       end if;

   end loop;

l_count := 0;
   if (action_flag = 'Y')then
         -- default the value of extended_deprn_period_name to the first period in next fiscal year
         for i in all_books loop

            select  cp.period_name  name
                  , fy.fiscal_year*ct.number_per_fiscal_year + 1 pctr
              into  l_name
                  , l_pctr
              from  fa_books bks
                  , fa_book_controls bc
                  , fa_fiscal_year fy
                  , fa_calendar_types ct
                  , fa_calendar_periods cp
             where  bc.book_type_code = i.book
               and  bks.asset_id = i.aid
               and  bc.book_type_code = bks.book_type_code
               and  bc.deprn_calendar = ct.calendar_type
               and  cp.calendar_type = ct.calendar_type
               and  bc.fiscal_year_name = ct.fiscal_year_name
               and  fy.fiscal_year_name = ct.fiscal_year_name
               and  cp.period_num = 1
               and  cp.start_date >= to_date('01/04/2007', 'DD/MM/RRRR')
               and  fy.fiscal_year = decode(sign(2007 -
                                     decode(mod(bks.period_counter_fully_reserved,ct.number_per_fiscal_year)
                                     , 0 , (bks.period_counter_fully_reserved-1)/ct.number_per_fiscal_year
                                         ,  bks.period_counter_fully_reserved/ct.number_per_fiscal_year))
                         , 1, (select min(fiscal_year)
                              from fa_fiscal_year
                              where fiscal_year_name = ct.fiscal_year_name
                              and start_date >= to_date('01/04/2007', 'DD/MM/RRRR'))
/* Bug 7229538. The existing Hard coded year 2007 is removed.
   Because it is not guarantee that fiscal year always starts from 01-Apr-2007.
   In some cases the year might have started from 01-Jan-207.
   In that case if you hardcode to 2007 This query never returns any row for those assets
   which are already fully reserved before 01-Apr-2007. So changed to get the immediate fiscal year
   which is after 31-Mar-2007. If the year starts from 01-Apr-2007 then it returns 2007 otherwise it returns 2008*/
                         , ceil((bks.period_counter_fully_reserved)/ct.number_per_fiscal_year))
               and  cp.start_date = fy.start_date
               and  bks.period_counter_fully_reserved is not null
               and  bks.transaction_header_id_out is null;


            update fa_adjustments_t
               set extended_deprn_period_name = l_name
                 , extended_depreciation_period = l_pctr
                 , posting_status = 'POST'
                 , extended_deprn_flag = 'Y'
                 , extended_deprn_limit = 1
             where book_type_code = i.book
               and asset_number = i.anum
               and batch_id = p_batch_id;

             if( mod(l_count,l_batch_size) = 0 )then
                commit work;
             end if;

             l_count := l_count + 1;

         end loop;

   elsif (action_flag <> 'U') then -- flag U indicates no action to be taken, as Avail Extended Deprn was Undecided for Bulk operation
            update fa_adjustments_t
               set posting_status = 'POST'
                 , extended_deprn_flag = action_flag
             where batch_id = p_batch_id;

               commit work;

   end if;

 exception when others then
          v_err_code := sqlcode;
          v_err_msg  := sqlerrm(sqlcode);

end;

END FA_ADJUSTMENTS_T_PKG;

/
