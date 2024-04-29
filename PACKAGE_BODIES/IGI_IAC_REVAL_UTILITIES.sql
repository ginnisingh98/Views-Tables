--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_UTILITIES" AS
-- $Header: igiiarub.pls 120.20.12000000.1 2007/08/01 16:18:16 npandya ship $

--===========================FND_LOG.START=====================================
g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);
--===========================FND_LOG.END=====================================
l_rec igi_iac_revaluation_rates%rowtype;
-- create this for quicker access via sql navigator

-- FND log .. Stubbed the following procedures since they should not be used .. Begin

function debug return boolean is
begin
  return false;
end;

function sqlplus_mode return boolean is
begin
  return false;
end;

function  logfile_mode         return boolean
is begin
      return true;
end;

function  set_logfile_mode_on  return boolean
is begin
   return true;
end;

function  set_logfile_mode_off return boolean is
begin
  return true;
end;

procedure log ( p_calling_code in varchar2, p_mesg in varchar2 ) is
begin
  null;
end;

-- FND log .. Stubbing of procedures .. End

function latest_adjustment       ( fp_asset_id             IN number
                                 , fp_book_type_code       in varchar2
                                 )
return number is
   l_transaction_id    number;
   l_mass_reference_id number;
   l_adjustment_id     number;
   l_prev_adjustment_id number;
   l_transaction_type_code varchar2(40);
   l_adjustment_status     varchar2(40);
   l_path_name VARCHAR2(150);
begin
   l_transaction_id    := 0;
   l_mass_reference_id := -1;
   l_adjustment_id     := -1;
   l_prev_adjustment_id := -1;
   l_path_name := g_path||'latest_adjustment';

   if not IGI_IAC_COMMON_UTILS.Get_Latest_Transaction
                          ( X_book_type_code        => fp_book_type_code
                          , X_asset_id              => fp_asset_id
                          , X_Transaction_Type_Code => l_transaction_type_code
                          , X_Transaction_Id        => l_transaction_id
                          , X_Mass_Reference_ID     => l_mass_reference_id
                          , X_Adjustment_Id         => l_adjustment_id
                          , X_Adjustment_Status     => l_adjustment_status
                          , X_prev_adjustment_id => l_prev_adjustment_id
                          )
   then
      null;
   end if;

   return l_prev_adjustment_id;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
   return -1;
end;

function  last_period_counter
                            ( p_asset_id  number ,
                              p_book_type_code  varchar2 ,
                              p_dpis_period_counter number  ,
                              p_last_period_counter out NOCOPY number  )
return boolean as
    l_calendar_type              varchar2(40) ;
    l_number_per_fiscal_year     number(4) ;
    l_life_in_months             number ;
    l_path_name VARCHAR2(150) ;
begin
    l_path_name := g_path||'last_period_counter';
    select ct.calendar_type , ct.number_per_fiscal_year , bk.life_in_months
    into   l_calendar_type , l_number_per_fiscal_year , l_life_in_months
    from   fa_calendar_types ct , fa_book_controls bc , fa_books bk
    where  ct.calendar_type    =  bc.deprn_calendar
    and    bk.book_type_code = p_book_type_code
    and    bk.date_ineffective is null
    and    bk.asset_id       = p_asset_id
    and    bc.date_ineffective is null
    and    bc.book_type_code = p_book_type_code ;

    p_last_period_counter := p_dpis_period_counter + (( l_life_in_months/12 ) * l_number_per_fiscal_year ) - 1 ;

    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+last period counter '|| p_last_period_counter );

    return true ;

exception
    when others then
  	igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
        return false ;
end;

function Populate_Depreciation   ( fp_asset_id             IN number
                                 , fp_book_type_code       IN varchar2
                                 , fp_period_counter       IN number
                                 , fp_hist_info            IN OUT NOCOPY IGI_IAC_TYPES.fa_hist_asset_info
                                 )
return  boolean is

    /* Bug 2763328 sekhar */
        CURSOR c_get_deprn_calendar (p_book_type_code fa_books.book_type_code%type) IS
        SELECT deprn_calendar
        FROM fa_book_controls
        WHERE book_type_code like p_book_type_code;

    /* Bug 2763328 sekhar */
        CURSOR c_get_periods_in_year(p_calendar_type fa_calendar_types.calendar_type%TYPE) IS
        SELECT number_per_fiscal_year
        FROM fa_calendar_types
        WHERE calendar_type = p_calendar_type;

   l_dpis_prd_rec  IGI_IAC_TYPES.prd_rec;
   l_curr_prd_rec  IGI_IAC_TYPES.prd_rec;
   l_num_of_periods_elapsed number;
   l_num_of_periods_in_pyr  number;
   l_num_of_periods_in_cyr  number;
   l_last_period_counter    number;
   l_num_of_periods_total   number;
   fp_hist_info_old IGI_IAC_TYPES.fa_hist_asset_info;
   l_deprn_calendar    fa_calendar_types.calendar_type%TYPE;
   l_periods_in_year   fa_calendar_types.number_per_fiscal_year%TYPE;
   l_path_name VARCHAR2(150);

begin
   l_path_name := g_path||'populate_depreciation';
   fp_hist_info_old := fp_hist_info;

   if not IGI_IAC_COMMON_UTILS.get_period_info_for_date
           ( p_book_type_code => fp_book_type_code
           , p_date           => fp_hist_info.date_placed_in_service
           , p_prd_rec        => l_dpis_prd_rec
           )
   then
     return false;
   end if;

   if not IGI_IAC_COMMON_UTILS.get_period_info_for_counter
           ( p_book_type_code => fp_book_type_code
           , p_period_counter => fp_period_counter
           , p_prd_rec        => l_curr_prd_rec
           )
   then
     return false;
   end if;

   /* check if the asset has been fully reserved before its life */
   /* if asset is not yet fully reserved, then forecast the expiry period counter */

   if  fp_hist_info.period_counter_fully_reserved is null
   then
       if not last_period_counter     ( p_asset_id  => fp_asset_id,
                                  p_book_type_code => fp_book_type_code ,
                                  p_dpis_period_counter => l_dpis_prd_rec.period_counter ,
                                  p_last_period_counter => l_last_period_counter
                                  )
       then
          return false;
       end if;
   else
         /* Bug 2763328 sekhar
        Revalution creating wrong account enntries for fully reserevd assets
        The fully resreved counter period in FA is not equal to actual fully reserved counter
        this period counter will be the period counter on the period action performed rarther than actual period counter
        modified code to get the actual fully reserved counter rarther than using the FA fully resereved period counter */

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '     Fully reserved asset');
   	    OPEN c_get_deprn_calendar(fp_book_type_code);
	    FETCH c_get_deprn_calendar INTO l_deprn_calendar;
	    CLOSE c_get_deprn_calendar;

	    OPEN c_get_periods_in_year(l_deprn_calendar);
	    FETCH c_get_periods_in_year INTO l_periods_in_year;
	    CLOSE c_get_periods_in_year;

                l_last_period_counter := (l_dpis_prd_rec.period_counter + ceil((fp_hist_info.life_in_months*l_periods_in_year)/12) - 1);
  		igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '     Last Period counter :'||to_char(l_last_period_counter));
              -- removed the following code
               --l_last_period_counter := fp_hist_info.period_counter_fully_reserved ;
           /* Bug 2763328 sekhar*/
   end if;

   /* set the local variables for ytd calculation */

   l_num_of_periods_total     := l_last_period_counter - l_dpis_prd_rec.period_counter + 1;
   l_num_of_periods_elapsed   := l_curr_prd_rec.period_counter - l_dpis_prd_rec.period_counter + 1;
   l_num_of_periods_in_cyr    := l_curr_prd_rec.period_num;

   if l_curr_prd_rec.fiscal_year = l_dpis_prd_rec.fiscal_year then
       l_num_of_periods_in_cyr := l_curr_prd_rec.period_num -
                                  l_dpis_prd_rec.period_num + 1;
   end if;
   /* here we assume that if the asset is fully reserved     */

   if l_last_period_counter < l_curr_prd_rec.period_counter then
       declare
        l_prd_rec IGI_IAC_TYPES.prd_rec;
       begin
            if not IGI_IAC_COMMON_UTILS.get_period_info_for_counter
               ( p_book_type_code => fp_book_type_code
               , p_period_counter => l_last_period_counter
               , p_prd_rec        => l_prd_rec
               )
            then
               return false;
            end if;

            if l_prd_rec.fiscal_year = l_curr_prd_rec.fiscal_year then
               l_num_of_periods_in_cyr    := l_prd_rec.period_num;
               l_num_of_periods_elapsed   := l_prd_rec.period_counter
                                             - l_dpis_prd_rec.period_counter + 1;
            elsif l_prd_rec.fiscal_year < l_curr_prd_rec.fiscal_year then
               l_num_of_periods_in_cyr    := 0;
               l_num_of_periods_elapsed   := l_prd_rec.period_counter
                                             - l_dpis_prd_rec.period_counter + 1;
            else
  	       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'fiscal year of the period fully reserved is incorrect');
            end if;
      exception
	when others then
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
		null;
      end;
   end if;

   l_num_of_periods_in_pyr    := l_num_of_periods_elapsed - l_num_of_periods_in_cyr;

   fp_hist_info.deprn_periods_elapsed      := l_num_of_periods_elapsed;
   fp_hist_info.deprn_periods_current_year := l_num_of_periods_in_cyr;
   fp_hist_info.deprn_periods_prior_year   := l_num_of_periods_in_pyr;

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+periods elapsed '|| l_num_of_periods_elapsed );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+periods cy      '|| l_num_of_periods_in_cyr );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+periods py      '|| l_num_of_periods_in_pyr );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+period ctr last '|| l_last_period_counter );

  /* YTD deprn = num of periods in cy/num of periods elapsed * Acc Deprn */

   fp_hist_info.ytd_deprn := (  fp_hist_info.deprn_periods_current_year
                            /  fp_hist_info.deprn_periods_elapsed ) *
                            fp_hist_info.deprn_reserve;

  /* PYS acc deprn = no of periods in py/number of periods elapsed * acc deprn */

   fp_hist_info.pys_deprn_reserve := (  fp_hist_info.deprn_periods_prior_year
                            /  fp_hist_info.deprn_periods_elapsed ) *
                            fp_hist_info.deprn_reserve;
   --
   -- this should work for assets after catchup
   --
   fp_hist_info.deprn_amount := fp_hist_info.deprn_reserve/fp_hist_info.deprn_periods_elapsed;

   return true;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
   fp_hist_info := fp_hist_info_old;
   return false;
end;


function split_rates             ( fp_asset_id            IN number
                                 , fp_book_type_code      IN varchar2
                                 , fp_revaluation_id      IN number
                                 , fp_period_counter      IN number
                                 , fp_current_factor      IN number
                                 , fp_reval_type          IN varchar2
                                 , fp_first_time_flag     IN boolean
                                 , fp_mixed_scenario             OUT NOCOPY BOOLEAN
                                 , fp_reval_prev_rate_info       IN  IGI_IAC_TYPES.iac_reval_rate_params
                                 , fp_reval_curr_rate_info_first OUT NOCOPY IGI_IAC_TYPES.iac_reval_rate_params
                                 , fp_reval_curr_rate_info_next  OUT NOCOPY IGI_IAC_TYPES.iac_reval_rate_params
                                 )
return   boolean is
   l_reval_type igi_iac_reval_asset_rules.revaluation_type%type;
   l_current_rate          number;
   l_cumulative_rate       number;
   fp_reval_curr_first_old IGI_IAC_TYPES.iac_reval_rate_params;
   fp_reval_curr_next_old  IGI_IAC_TYPES.iac_reval_rate_params;
   l_path_name VARCHAR2(150);

begin
   l_path_name := g_path||'split_rates';
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'begin split_rates');
   if fp_first_time_flag then /* only one movement possible */
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+first time flag set');
   end if;
   fp_reval_curr_rate_info_first  := fp_reval_prev_rate_info ;
   fp_reval_curr_rate_info_next   := fp_reval_prev_rate_info ;

   select fp_current_factor, fp_Reval_type
   into   l_current_rate    , l_reval_type
   from   sys.dual
   ;
   /* initialize the new rate record */

   fp_reval_curr_rate_info_first.revaluation_id := fp_revaluation_id;
   fp_reval_curr_rate_info_first.period_counter := fp_period_counter;
   fp_reval_curr_rate_info_first.reval_type     := l_reval_type;
   fp_reval_curr_rate_info_next                 := fp_reval_curr_rate_info_first;

   l_cumulative_rate  := fp_reval_prev_rate_info.cumulative_reval_factor;
   l_cumulative_rate  := l_current_rate * l_cumulative_rate;

   if l_cumulative_rate > 1 and fp_reval_prev_rate_info.cumulative_reval_factor < 1 then
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Upwards Mixed case scenario');
      -- prev till cummulative rate =1 as first set.
      -- cumm rate till current        as second set.
      fp_reval_curr_rate_info_first.current_reval_factor :=
                            (1/fp_reval_prev_rate_info.cumulative_reval_factor );
      fp_reval_curr_rate_info_first.cumulative_reval_factor := 1;
      fp_reval_curr_rate_info_next.current_reval_factor     := l_cumulative_rate;
      fp_reval_curr_rate_info_next.cumulative_reval_factor  := l_cumulative_rate;
      fp_reval_curr_rate_info_next.latest_record            := 'Y';
      fp_mixed_scenario       := true;
   elsif l_cumulative_rate < 1 and fp_reval_prev_rate_info.cumulative_reval_factor > 1 then
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Downwards Mixed case scenario');
       fp_reval_curr_rate_info_first.current_reval_factor :=
                            (1/fp_reval_prev_rate_info.cumulative_reval_factor );
      fp_reval_curr_rate_info_first.cumulative_reval_factor := 1;
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Second set rate '|| l_cumulative_rate );
      fp_reval_curr_rate_info_next.current_reval_factor     := l_cumulative_rate;
      fp_reval_curr_rate_info_next.cumulative_reval_factor  := l_cumulative_rate;
      fp_reval_curr_rate_info_next.latest_record            := 'Y';
      fp_mixed_scenario       := true;
   elsif l_cumulative_rate = 1 and fp_reval_prev_rate_info.cumulative_reval_factor = 1 then
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Static revaluation');
      fp_reval_curr_rate_info_first.current_reval_factor    := 1;
      fp_reval_curr_rate_info_first.cumulative_reval_factor := 1;
      fp_reval_curr_rate_info_first.latest_record            := 'Y';
      fp_mixed_scenario       := false;
   elsif l_cumulative_rate > 1 and fp_reval_prev_rate_info.cumulative_reval_factor >= 1 then
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Upwards revaluation');
      fp_reval_curr_rate_info_first.current_reval_factor    := l_cumulative_rate/
                                     fp_reval_prev_rate_info.cumulative_reval_factor ;
      fp_reval_curr_rate_info_first.cumulative_reval_factor := l_cumulative_rate;
      fp_reval_curr_rate_info_first.latest_record            := 'Y';
      fp_mixed_scenario       := false;
   elsif l_cumulative_rate = 1 and fp_reval_prev_rate_info.cumulative_reval_factor > 1 then
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Upwards revaluation');
      fp_reval_curr_rate_info_first.current_reval_factor    := l_cumulative_rate/
                                     fp_reval_prev_rate_info.cumulative_reval_factor ;
      fp_reval_curr_rate_info_first.cumulative_reval_factor := l_cumulative_rate;
      fp_reval_curr_rate_info_first.latest_record            := 'Y';
      fp_mixed_scenario       := false;
  elsif l_cumulative_rate < 1 and fp_reval_prev_rate_info.cumulative_reval_factor <= 1 then
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Downwards revaluation');
      fp_reval_curr_rate_info_first.current_reval_factor    := l_cumulative_rate/
                                     fp_reval_prev_rate_info.cumulative_reval_factor ;
      fp_reval_curr_rate_info_first.cumulative_reval_factor := l_cumulative_rate;
      fp_reval_curr_rate_info_first.latest_record            := 'Y';
      fp_mixed_scenario       := false;
  elsif l_cumulative_rate = 1 and fp_reval_prev_rate_info.cumulative_reval_factor < 1 then
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Downwards revaluation');
      fp_reval_curr_rate_info_first.current_reval_factor    := l_cumulative_rate/
                                     fp_reval_prev_rate_info.cumulative_reval_factor ;
      fp_reval_curr_rate_info_first.cumulative_reval_factor := l_cumulative_rate;
      fp_reval_curr_rate_info_first.latest_record            := 'Y';
      fp_mixed_scenario       := false;
   end if;

      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'end split rates');
   return true;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
   fp_reval_curr_rate_info_first := fp_reval_curr_first_old;
   fp_reval_curr_rate_info_next  := fp_reval_curr_next_old;
   fp_mixed_scenario := FALSE;
   return false;
end;

procedure display_prorate_dists ( fp_prorate_dists igi_iac_types.prorate_dists ) is
   l_path_name VARCHAR2(150);
begin
   l_path_name := g_path||'display_prorate_dists';
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '----------------------------------------------------');
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'distribution id       '|| fp_prorate_dists.distribution_id );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'ytd prorate factor    '|| fp_prorate_dists.ytd_prorate_factor );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'normal prorate factor '|| fp_prorate_dists.normal_prorate_factor );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'latest period counter '|| fp_prorate_dists.latest_period_counter );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'units assigned        '|| fp_prorate_dists.units_assigned );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'units active          '|| fp_prorate_dists.units_active );
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '----------------------------------------------------');
end;

function prorate_dists ( fp_asset_id                in number
                       , fp_book_type_code          in varchar2
                       , fp_current_period_counter  in number
                       , fp_prorate_dists_tab      out NOCOPY igi_iac_types.prorate_dists_tab
                       , fp_prorate_dists_idx      out NOCOPY binary_integer
                       )
return boolean is

  l_prorate_dists_idx binary_integer ;
  l_prorate_dists_tab igi_iac_types.prorate_dists_tab;
  l_path_name VARCHAR2(150);

  cursor c_deprn_asset is
    select fds.asset_id,  fds.book_type_code, fds.period_counter + 1, abs(fds.ytd_deprn) ytd_deprn, fdp.fiscal_year
         , fadd.current_units total_units
    from   fa_deprn_summary fds, fa_deprn_periods fdp
           , fa_additions fadd
    where  fds.book_type_code = fp_book_type_code
    and    fdp.book_type_code = fds.book_type_code
    and    fdp.period_counter = fds.period_counter
  --  and    fds.period_counter <= fp_current_period_counter
    and    fds.asset_id       = fp_asset_id
    and    fadd.asset_id      = fp_asset_id
    and    fds.period_counter in ( select max(period_counter)
                                   from   fa_deprn_summary
                                   where book_type_code = fds.book_type_code
                                     and asset_id       = fds.asset_id
                                  )
   ;

   cursor c_deprn_dists (cp_book_type_code in varchar2
                        , cp_asset_id      in number
                        , cp_fiscal_year   in number
                        , cp_ytd_deprn     in number
                        , cp_total_units   in number
                        ) is
     /** we need this for reclass **/
    select fdh.asset_id,
           fdh.distribution_id,
           fdp.period_counter latest_period_counter,
           0  ytd_deprn,
           fdp.period_num,
           fdp.fiscal_year,
           fdh.units_assigned,
           nvl(fdh.units_assigned,0) + nvl(fdh.transaction_units,0) units_active,
           'ACTIVE' status,
           (fdh.units_assigned/fadd.current_units) ytd_prorate_factor,
           (fdh.units_assigned/fadd.current_units) normal_prorate_factor
    from   fa_deprn_periods fdp
        ,  fa_distribution_history fdh
        ,  fa_additions fadd
        ,  fa_transaction_headers fth
    where  fth.book_type_code = cp_book_type_code
    and    fdp.book_type_code = fth.book_type_code
    and    fdh.asset_id       = fth.asset_id
    and    fdh.transaction_header_id_out IS NULL
    and    fth.asset_id       = cp_asset_id
    and    fadd.asset_id      = fth.asset_id
    and    fth.transaction_type_code = 'RECLASS'
    and    fdp.period_counter in ( select distinct period_counter_created
                                  from   fa_adjustments
                                  where  book_type_code = fth.book_type_code
                                  and    asseT_id       = fth.asset_id
                                  and    distribution_id = fdh.distribution_id
                                  and    transaction_header_id = fth.transaction_header_id
                                 )
    and   not exists ( select  distribution_id
                     from   fa_deprn_detail
                     where  asset_id = fth.asset_id
                     and    book_type_code = fth.book_type_code
                     and    distribution_id = fdh.distribution_id
                   )
    union /** we need this for catchup **/
    select fdd.asset_id,
           fdd.distribution_id,
           fdd.period_counter latest_period_counter,
           fdd.ytd_deprn,
           fdp.period_num,
           fdp.fiscal_year,
           fdh.units_assigned,
           nvl(fdh.units_assigned,0) + nvl(fdh.transaction_units,0) units_active,
           'ACTIVE' status,
           (fdh.units_assigned/cp_total_units) ytd_prorate_factor,
           (fdh.units_assigned/cp_total_units) normal_prorate_factor
    from   fa_deprn_detail fdd
        ,  fa_deprn_periods fdp
        ,  fa_distribution_history fdh
    where  fdd.book_type_code = cp_book_type_code
    and    fdp.book_type_code = fdd.book_type_code
    and    fdp.period_counter = fdd.period_counter
    and    fdp.fiscal_year    = cp_fiscal_year
    and    fdh.book_type_code = fdd.book_type_code
    and    fdh.asset_id       = fdd.asset_id
    and    fdd.asset_id       = cp_asset_id
    and    fdh.distribution_id = fdd.distribution_id
    and    fdh.transaction_header_id_out is null
    and    cp_total_units     <> 0 -- avoid divide by zero issues
    and    ( fdd.asset_id, fdd.distribution_id, fdd.period_counter )
    in ( select asset_id, distribution_id, max(period_counter)
         from   fa_deprn_detail
         where book_type_code = fdd.book_type_code
           and asset_id       = fdd.asset_id
         group by asset_id, distribution_id
    );
begin
  l_prorate_dists_idx := 0;
  l_path_name := g_path||'prorate_dists';

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'Begin prorate dists');
   for l_asset in c_deprn_asset loop
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+initialize variables');
       l_prorate_dists_idx := 0;
       l_prorate_dists_tab.delete;
       igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+Paramteres  variables ytd '|| l_asset.ytd_deprn );
       for l_dists in c_deprn_dists ( cp_asset_id       => l_asset.asset_id
                                    , cp_book_type_code => l_asset.book_type_code
                                    , cp_fiscal_year    => l_asset.fiscal_year
                                    , cp_ytd_deprn      => l_asset.ytd_deprn
                                    , cp_total_units    => l_asset.total_units
                                    )


       loop
  	  igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => '+Process variables');

          l_prorate_dists_idx := l_prorate_dists_idx + 1;
          l_prorate_dists_tab ( l_prorate_dists_idx ).distribution_id
                               := l_dists.distribution_id;
          l_prorate_dists_tab ( l_prorate_dists_idx ).ytd_prorate_factor
                               := l_dists.ytd_prorate_factor;
          l_prorate_dists_tab ( l_prorate_dists_idx ).normal_prorate_factor
                               := l_dists.normal_prorate_factor;
          l_prorate_dists_tab ( l_prorate_dists_idx ).units_assigned
                               := l_dists.units_assigned;
          l_prorate_dists_tab ( l_prorate_dists_idx ).units_active
                               := l_dists.units_active;
          l_prorate_dists_tab ( l_prorate_dists_idx ).latest_period_counter
                               := l_dists.latest_period_counter;
          if l_dists.normal_prorate_factor = 0  then
             l_prorate_dists_tab ( l_prorate_dists_idx ).active_flag :=  'N';
          else
               l_prorate_dists_tab ( l_prorate_dists_idx ).active_flag :=  null;
          end if;
          display_prorate_dists ( l_prorate_dists_tab ( l_prorate_dists_idx ) );
       end loop;
   end loop;
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => '+final processing');
   fp_prorate_dists_tab := l_prorate_dists_tab;
   fp_prorate_dists_idx := l_prorate_dists_idx;
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
	     p_full_path => l_path_name,
	     p_string => 'end prorate dists');
   return true;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
   return false;
end;

FUNCTION prorate_active_dists_YTD ( fp_asset_id                in number
                       , fp_book_type_code          in varchar2
                       , fp_current_period_counter  in number
                       , fp_prorate_dists_tab      out NOCOPY igi_iac_types.prorate_dists_tab
                       , fp_prorate_dists_idx      out NOCOPY binary_integer
                       ) RETURN BOOLEAN IS
    CURSOR c_active_dists IS
    SELECT fdh.distribution_id distribution_id,
            fdh.units_assigned units_assigned,
            nvl(fdh.units_assigned,0) + nvl(fdh.transaction_units,0) units_active,
            fdp.period_counter period_counter_created,
            fdp.fiscal_year fiscal_year
    FROM fa_distribution_history fdh,
         fa_deprn_periods fdp
    WHERE fdh.book_type_code = fp_book_type_code
    AND fdh.asset_id = fp_asset_id
    AND fdh.transaction_header_id_out IS NULL
    AND fdp.book_type_code = fp_book_type_code
    AND fdh.date_effective BETWEEN fdp.period_open_date AND nvl(fdp.period_close_date,sysdate);

    CURSOR c_get_dpis IS
    SELECT fb.date_placed_in_service,
            fb.period_counter_fully_reserved,
            fb.life_in_months,
            fb.depreciate_flag
    FROM fa_books fb
    WHERE fb.book_type_code = fp_book_type_code
    AND fb.asset_id = fp_asset_id
    AND fb.transaction_header_id_out IS NULL;

    CURSOR C_first_deprn_period IS
    SELECT min(fds.period_counter)
    FROM fa_deprn_summary fds
    WHERE fds.book_type_code = fp_book_type_code
    AND fds.asset_id = fp_asset_id
    AND fds.deprn_source_code = 'DEPRN';

    CURSOR c_get_periods_in_year IS
    SELECT ct.number_per_fiscal_year
    FROM fa_calendar_types ct, fa_book_controls bc
    WHERE ct.calendar_type = bc.deprn_calendar
    AND bc.book_type_code = fp_book_type_code;

  l_prorate_dists_idx binary_integer ;
  l_prorate_dists_tab igi_iac_types.prorate_dists_tab;
  l_path_name VARCHAR2(150);
  l_fully_reserved NUMBER;
  l_dpis    DATE;
  l_dpis_period igi_iac_types.prd_rec;
  l_current_period igi_iac_types.prd_rec;
  l_first_deprn_period  NUMBER;
  l_dist_first_period   NUMBER;
  l_dist_last_period    NUMBER;
  l_dist_active_periods NUMBER;
  l_fully_reserved_counter NUMBER;
  l_fully_reserved_period  igi_iac_types.prd_rec;
  l_periods_per_FY        fa_calendar_types.number_per_fiscal_year%TYPE;
  l_total_periods         NUMBER;
  l_last_period         igi_iac_types.prd_rec;
  l_asset_prorate_units NUMBER;
  l_life_in_months      NUMBER;
  l_depreciate_flag     VARCHAR2(3);

BEGIN

    l_path_name := g_path||'prorate_active_dists_YTD';
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Start of Processing');

    l_prorate_dists_idx := 0;
    l_prorate_dists_tab.delete;
    l_asset_prorate_units := 0;

    OPEN c_get_dpis;
    FETCH c_get_dpis INTO l_dpis, l_fully_reserved, l_life_in_months, l_depreciate_flag;
    CLOSE c_get_dpis;

    IF NOT igi_iac_common_utils.Get_Period_Info_for_Date( fp_book_type_code ,
                                     l_dpis ,
                                     l_dpis_period) THEN

        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,p_full_path => l_path_name,
                                        p_string => 'Error in fetching DPIS period information ');
        RETURN FALSE;
    END IF;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'DPIS Period:'||l_dpis_period.period_counter);

    IF NOT igi_iac_common_utils.Get_Period_Info_for_Counter( fp_book_type_code ,
                                     fp_current_period_counter ,
                                     l_current_period) THEN
        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,p_full_path => l_path_name,
                                        p_string => 'Error in fetching current period information ');
        RETURN FALSE;
    END IF;
    l_last_period := l_current_period;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Current Period:'||l_current_period.period_counter);

    IF l_fully_reserved IS NOT NULL THEN
        OPEN c_get_periods_in_year;
        FETCH c_get_periods_in_year INTO l_periods_per_FY;
        CLOSE c_get_periods_in_year;

        l_total_periods := ceil((l_life_in_months*l_periods_per_FY)/12);
        l_fully_reserved_counter := (l_dpis_period.period_counter + l_total_periods - 1);

        IF NOT igi_iac_common_utils.Get_Period_Info_for_Counter( fp_book_type_code ,
                                     l_fully_reserved_counter ,
                                     l_fully_reserved_period) THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,p_full_path => l_path_name,
                                        p_string => 'Error in fetching fully reserved period information ');

            RETURN FALSE;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Fully Reserved Period:'||l_fully_reserved_counter);

        l_last_period := l_fully_reserved_period;
    END IF;

    OPEN c_first_deprn_period;
    FETCH c_first_deprn_period INTO l_first_deprn_period;
    CLOSE c_first_deprn_period;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'First Deprn Period:'||l_first_deprn_period);

    FOR l_dist IN C_active_dists LOOP
        l_prorate_dists_idx := l_prorate_dists_idx + 1;

        l_prorate_dists_tab ( l_prorate_dists_idx ).distribution_id
                               := l_dist.distribution_id;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Distribution Id:'||l_dist.distribution_id);

        IF (l_last_period.fiscal_year < l_current_period.fiscal_year) OR (l_depreciate_flag='NO') THEN
            l_dist_active_periods := 0;
        ELSE
            IF l_dist.period_counter_created = nvl(l_first_deprn_period,l_dist.period_counter_created) THEN
                IF l_dpis_period.fiscal_year = l_last_period.fiscal_year THEN
                    l_dist_active_periods :=
                        (l_last_period.period_counter - l_dpis_period.period_counter + 1);
                ELSE
                    l_dist_active_periods := l_last_period.period_num;
                END IF;
            ELSE
                IF l_dist.fiscal_year = l_last_period.fiscal_year THEN
                    IF l_last_period.period_counter >= l_dist.period_counter_created THEN
                        l_dist_active_periods :=
                            l_last_period.period_counter - l_dist.period_counter_created + 1;
                    ELSE
                        l_dist_active_periods := 0;
                    END IF;
                ELSE
                    l_dist_active_periods := l_last_period.period_num;
                END IF;
            END IF;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Active Periods:'||l_dist_active_periods);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Units_assigned:'||l_dist.units_assigned);

        l_prorate_dists_tab ( l_prorate_dists_idx ).ytd_prorate_factor
                               := l_dist_active_periods * l_dist.units_assigned;
        l_asset_prorate_units := l_asset_prorate_units +
                    l_prorate_dists_tab ( l_prorate_dists_idx ).ytd_prorate_factor;
    END LOOP;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Asset total active units:'||l_asset_prorate_units);

    FOR i IN 1..l_prorate_dists_idx LOOP
        IF l_asset_prorate_units = 0 THEN
            l_prorate_dists_tab ( i ).ytd_prorate_factor := 0;
        ELSE
            l_prorate_dists_tab ( i ).ytd_prorate_factor
                := l_prorate_dists_tab(i).ytd_prorate_factor/l_asset_prorate_units;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Distribution Id:'||l_prorate_dists_tab(i).distribution_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Prorate Factor:'||l_prorate_dists_tab(i).ytd_prorate_factor);

    END LOOP;
    fp_prorate_dists_idx := l_prorate_dists_idx;
    fp_prorate_dists_tab := l_prorate_dists_tab;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
        RETURN FALSE;
END prorate_active_dists_YTD;

FUNCTION prorate_all_dists_YTD ( fp_asset_id                in number
                       , fp_book_type_code          in varchar2
                       , fp_current_period_counter  in number
                       , fp_prorate_dists_tab      out NOCOPY igi_iac_types.prorate_dists_tab
                       , fp_prorate_dists_idx      out NOCOPY binary_integer
                       ) RETURN BOOLEAN IS

    CURSOR c_all_dists (cp_fiscal_year number) IS
    SELECT fdh.distribution_id distribution_id,
            fdh.units_assigned units_assigned,
            nvl(fdh.units_assigned,0) + nvl(fdh.transaction_units,0) units_active,
            fdp.period_counter period_counter_created,
            Null period_counter_closed ,
            fdp.fiscal_year fiscal_year,'Y' Active_flag
    FROM fa_distribution_history fdh,
         fa_deprn_periods fdp
    WHERE fdh.book_type_code = fp_book_type_code
    AND fdh.asset_id = fp_asset_id
    AND fdh.transaction_header_id_out IS NULL
    AND fdp.book_type_code = fp_book_type_code
    AND fdh.date_effective BETWEEN fdp.period_open_date AND nvl(fdp.period_close_date,sysdate)
    UNION ALL
    SELECT fdh.distribution_id distribution_id,
            fdh.units_assigned units_assigned,
            nvl(fdh.units_assigned,0) + nvl(fdh.transaction_units,0) units_active,
            fdp2.period_counter period_counter_created,
            fdp3.period_counter period_counter_closed,
            fdp2.fiscal_year fiscal_year,'N' Active_flag
    FROM fa_distribution_history fdh,
         fa_deprn_periods fdp1,
         fa_deprn_periods fdp2,
         fa_deprn_periods fdp3
    WHERE fdh.book_type_code = fp_book_type_code
    AND fdh.asset_id = fp_asset_id
    AND fdh.transaction_header_id_out IS Not NULL
    AND fdp1.book_type_code = fdh.book_type_code
    AND fdp1.period_counter = (select min(period_counter)
                                from fa_deprn_periods fdep
                                where book_type_code = fp_book_type_code
                                 and fiscal_year=cp_fiscal_year)
    AND fdp2.book_type_code = fdh.book_type_code
    AND fdh.date_effective between fdp2.period_open_date and nvl(fdp2.period_close_date,fdh.date_effective)
    AND fdp3.book_type_code = fdh.book_type_code
    AND fdh.date_ineffective between fdp3.period_open_date and nvl(fdp3.period_close_date,fdh.date_ineffective);

    CURSOR c_get_dpis IS
    SELECT fb.date_placed_in_service,
            fb.period_counter_fully_reserved,
            fb.life_in_months,
            fb.depreciate_flag
    FROM fa_books fb
    WHERE fb.book_type_code = fp_book_type_code
    AND fb.asset_id = fp_asset_id
    AND fb.transaction_header_id_out IS NULL;

    CURSOR C_first_deprn_period IS
    SELECT min(fds.period_counter)
    FROM fa_deprn_summary fds
    WHERE fds.book_type_code = fp_book_type_code
    AND fds.asset_id = fp_asset_id
    AND fds.deprn_source_code = 'DEPRN';

    CURSOR c_get_periods_in_year IS
    SELECT ct.number_per_fiscal_year
    FROM fa_calendar_types ct, fa_book_controls bc
    WHERE ct.calendar_type = bc.deprn_calendar
    AND bc.book_type_code = fp_book_type_code;

    l_prorate_dists_idx binary_integer ;
    l_prorate_dists_tab igi_iac_types.prorate_dists_tab;
    l_path_name VARCHAR2(150);
    l_fully_reserved NUMBER;
    l_dpis    DATE;
    l_dpis_period igi_iac_types.prd_rec;
    l_current_period igi_iac_types.prd_rec;
    l_first_deprn_period  NUMBER;
    l_dist_first_period   NUMBER;
    l_dist_last_period    NUMBER;
    l_dist_active_periods NUMBER;
    l_fully_reserved_counter NUMBER;
    l_fully_reserved_period  igi_iac_types.prd_rec;
    l_periods_per_FY        fa_calendar_types.number_per_fiscal_year%TYPE;
    l_total_periods         NUMBER;
    l_last_period         igi_iac_types.prd_rec;
    l_asset_prorate_units NUMBER;
    l_life_in_months      NUMBER;
    l_depreciate_flag     VARCHAR2(3);
    l_last_dist_period    igi_iac_types.prd_rec;
    l_first_dist_period    igi_iac_types.prd_rec;

BEGIN

    l_path_name := g_path||'prorate_all_dists_YTD';
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Start of Processing');

    l_prorate_dists_idx := 0;
    l_prorate_dists_tab.delete;
    l_asset_prorate_units := 0;

    OPEN c_get_dpis;
    FETCH c_get_dpis INTO l_dpis, l_fully_reserved, l_life_in_months, l_depreciate_flag;
    CLOSE c_get_dpis;

    IF NOT igi_iac_common_utils.Get_Period_Info_for_Date( fp_book_type_code ,
                                     l_dpis ,
                                     l_dpis_period) THEN
        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,p_full_path => l_path_name,
                                        p_string => 'Error in fetching DPIS period information ');
        RETURN FALSE;
    END IF;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'DPIS Period:'||l_dpis_period.period_counter);

    IF NOT igi_iac_common_utils.Get_Period_Info_for_Counter( fp_book_type_code ,
                                     fp_current_period_counter ,
                                     l_current_period) THEN
        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,p_full_path => l_path_name,
                                        p_string => 'Error in fetching current period information ');
        RETURN FALSE;
    END IF;
    l_last_period := l_current_period;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Current Period:'||l_current_period.period_counter);

    IF l_fully_reserved IS NOT NULL THEN
        OPEN c_get_periods_in_year;
        FETCH c_get_periods_in_year INTO l_periods_per_FY;
        CLOSE c_get_periods_in_year;

        l_total_periods := ceil((l_life_in_months*l_periods_per_FY)/12);
        l_fully_reserved_counter := (l_dpis_period.period_counter + l_total_periods - 1);

	IF l_fully_reserved_counter > l_fully_reserved THEN
		l_fully_reserved_counter := l_fully_reserved;
	END IF;

        IF NOT igi_iac_common_utils.Get_Period_Info_for_Counter( fp_book_type_code ,
                                     l_fully_reserved_counter ,
                                     l_fully_reserved_period) THEN
            igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,p_full_path => l_path_name,
                                        p_string => 'Error in fetching fully reserved period information ');

            RETURN FALSE;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Fully Reserved Period:'||l_fully_reserved_counter);

        l_last_period := l_fully_reserved_period;
    END IF;

    OPEN c_first_deprn_period;
    FETCH c_first_deprn_period INTO l_first_deprn_period;
    CLOSE c_first_deprn_period;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'First Deprn Period:'||l_first_deprn_period);

    FOR l_dist IN C_all_dists(l_current_period.fiscal_year) LOOP

        l_last_dist_period:=l_last_period;
        l_first_dist_period:=l_dpis_period;
        l_prorate_dists_idx := l_prorate_dists_idx + 1;

        l_prorate_dists_tab ( l_prorate_dists_idx ).distribution_id
                               := l_dist.distribution_id;
        l_prorate_dists_tab(l_prorate_dists_idx).active_flag := l_dist.active_flag;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Distribution Id:'||l_dist.distribution_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Active Flag:'||l_dist.active_flag);

        IF l_dist.active_flag = 'N' THEN -- inactive
            IF l_last_dist_period.period_counter >= l_dist.period_counter_closed THEN --
                -- get info for the period counter closed.
                 IF NOT igi_iac_common_utils.Get_Period_Info_for_Counter( fp_book_type_code ,
                                     l_dist.period_counter_closed - 1 ,
                                     l_last_dist_period) THEN
                        igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,p_full_path => l_path_name,
                                        p_string => 'Error in fetching dist closed period information ');
                      RETURN FALSE;
                END IF;
                igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => ' Distribution closed Period:'||l_last_dist_period.period_counter);
            END IF;--
        END IF;-- inactive end

        IF (l_last_dist_period.fiscal_year < l_current_period.fiscal_year) OR (l_depreciate_flag='NO') THEN
            l_dist_active_periods := 0;
        ELSE
            IF l_dist.period_counter_created = nvl(l_first_deprn_period,l_dist.period_counter_created) THEN
                IF (l_dist.active_flag = 'N' AND l_dist.period_counter_created = l_dist.period_counter_closed) THEN
                    l_dist_active_periods := 0;
                ELSE
                    IF l_dpis_period.fiscal_year = l_last_dist_period.fiscal_year THEN
                        l_dist_active_periods :=
                            (l_last_dist_period.period_counter - l_dpis_period.period_counter + 1);
                    ELSE
                        l_dist_active_periods := l_last_dist_period.period_num;
                    END IF;
                END IF;
            ELSE
                IF l_dist.fiscal_year = l_last_dist_period.fiscal_year THEN
                    IF l_last_dist_period.period_counter >= l_dist.period_counter_created THEN
                        l_dist_active_periods :=
                            l_last_dist_period.period_counter - l_dist.period_counter_created + 1;
                    ELSE
                        l_dist_active_periods := 0;
                    END IF;
                ELSE
                    l_dist_active_periods := l_last_dist_period.period_num;
                END IF;
            END IF;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Active Periods:'||l_dist_active_periods);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Units_assigned:'||l_dist.units_assigned);

        l_prorate_dists_tab ( l_prorate_dists_idx ).ytd_prorate_factor
                               := l_dist_active_periods * l_dist.units_assigned;
        l_asset_prorate_units := l_asset_prorate_units +
                    l_prorate_dists_tab ( l_prorate_dists_idx ).ytd_prorate_factor;
    END LOOP;
    igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Asset total active units:'||l_asset_prorate_units);

    FOR i IN 1..l_prorate_dists_idx LOOP
        IF l_asset_prorate_units = 0 THEN
            l_prorate_dists_tab ( i ).ytd_prorate_factor := 0;
        ELSE
            l_prorate_dists_tab ( i ).ytd_prorate_factor
                := l_prorate_dists_tab(i).ytd_prorate_factor/l_asset_prorate_units;
        END IF;
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Distribution Id:'||l_prorate_dists_tab(i).distribution_id);
        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
                                        p_string => 'Prorate Factor:'||l_prorate_dists_tab(i).ytd_prorate_factor);

    END LOOP;
    fp_prorate_dists_idx := l_prorate_dists_idx;
    fp_prorate_dists_tab := l_prorate_dists_tab;
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
        RETURN FALSE;
END prorate_all_dists_YTD;

-- Bug 3434121
-- The following procedure is a replica of the procedure gl_formsinfo.get_coa_info
-- and is used to get the ordering segments for the category flexfield

PROCEDURE get_coa_info   (x_chart_of_accounts_id    IN     NUMBER,
                          x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                          x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                          x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                          x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_ieaseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_left_prompt      IN OUT NOCOPY VARCHAR2) IS

    CURSOR seg_count IS
      SELECT segment_num, application_column_name
      FROM fnd_id_flex_segments
      WHERE application_id = 140
      AND   id_flex_code   = 'CAT#'
      AND   enabled_flag   = 'Y'
      AND   id_flex_num    = x_chart_of_accounts_id
      ORDER BY segment_num;

    dumdum BOOLEAN;
    x_seg_name VARCHAR2(30);
    x_value_set VARCHAR2(60);
    l_path_name VARCHAR2(150);
  BEGIN
    dumdum := FALSE;
    l_path_name := g_path||'get_coa_info';
    -- Identify the natural account and balancing segments
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                140, 'CAT#', x_chart_of_accounts_id,
                'GL_ACCOUNT', x_accseg_segment_num);
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                140, 'CAT#', x_chart_of_accounts_id,
                'GL_BALANCING', x_balseg_segment_num);
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                140, 'CAT#', x_chart_of_accounts_id,
                'GL_INTERCOMPANY', x_ieaseg_segment_num);

    -- Get the segment delimiter
    x_segment_delimiter := FND_FLEX_APIS.get_segment_delimiter(
                             140, 'CAT#', x_chart_of_accounts_id);

    -- Count 'em up and string 'em together
    x_enabled_segment_count := 0;
    FOR r IN seg_count LOOP
      -- How many enabled segs are there?
      x_enabled_segment_count := seg_count%ROWCOUNT;
      -- Record the order by string
      IF seg_count%ROWCOUNT = 1 THEN
        x_segment_order_by      := r.application_column_name;
      ELSE
        x_segment_order_by      := x_segment_order_by||
                                   ','||
                                   r.application_column_name;
      END IF;
      -- If this is either the accseg or balseg, get more info
      IF    r.segment_num = x_accseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              140, 'CAT#', x_chart_of_accounts_id,
              r.segment_num, x_accseg_app_col_name,
              x_seg_name, x_accseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      ELSIF r.segment_num = x_balseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              140, 'GL#', x_chart_of_accounts_id,
              r.segment_num, x_balseg_app_col_name,
              x_seg_name, x_balseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      ELSIF r.segment_num = x_ieaseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              140, 'CAT#', x_chart_of_accounts_id,
              r.segment_num, x_ieaseg_app_col_name,
              x_seg_name, x_ieaseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      END IF;
    END LOOP;

EXCEPTION
   WHEN OTHERS THEN
     igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
     app_exception.raise_exception;
END get_coa_info;

    FUNCTION Synchronize_Accounts(
        p_book_type_code    IN VARCHAR2,
        p_period_counter    IN NUMBER,
        p_calling_function  IN VARCHAR2
        ) return BOOLEAN IS

        CURSOR c_get_adjustments(c_adjustment_id number)  IS
        SELECT rowid,
            adjustment_id,
            book_type_code,
            code_combination_id,
            adjustment_type,
            asset_id,
            distribution_id,
            period_counter
        FROM igi_iac_adjustments
        WHERE book_type_code = p_book_type_code
        AND period_counter = p_period_counter
        AND adjustment_type IN ('COST','RESERVE','EXPENSE')
        AND adjustment_id = c_adjustment_id for update;

        CURSOR c_get_transaction IS
        SELECT adjustment_id,
                transaction_header_id,
                transaction_type_code
        FROM igi_iac_transaction_headers
        WHERE book_type_code = p_book_type_code
        AND period_counter = p_period_counter
        AND transaction_type_code in ('REVALUATION');

        CURSOR c_get_accounts (c_distribution_id NUMBER) IS
        SELECT  nvl(ASSET_COST_ACCOUNT_CCID, -1),
                nvl(DEPRN_EXPENSE_ACCOUNT_CCID, -1),
                nvl(DEPRN_RESERVE_ACCOUNT_CCID, -1),
                bc.accounting_flex_structure
        FROM    FA_DISTRIBUTION_ACCOUNTS da,
                    FA_BOOK_CONTROLS bc
        WHERE  bc.book_type_code = p_book_type_code
        AND      da.book_type_code = bc.book_type_code
        AND      da.distribution_id = c_distribution_id;

        CURSOR c_get_account_ccid ( c_asset_id NUMBER,
                                        c_distribution_id NUMBER,
                                        c_adjustment_source_type_code VARCHAR2,
                                        c_adjustment_type   VARCHAR2,
                                        c_transaction_header_id NUMBER) IS
        SELECT code_combination_id
        FROM fa_adjustments
        WHERE book_type_code = p_book_type_code
        AND  asset_id = c_asset_id
        AND distribution_id = c_distribution_id
        AND adjustment_type = c_adjustment_type;

        l_account_ccid NUMBER;
        l_adjustment_type VARCHAR2(50);
        l_rowid rowid;
        l_cost_ccid NUMBER;
        l_expense_ccid NUMBER;
        l_reserve_ccid NUMBER;
        l_flex_num NUMBER;
        l_category_id NUMBER;
        l_default_ccid NUMBER;
        l_account_seg_val VARCHAR2(25);
        l_account_type VARCHAR2(100);
        l_acct_ccid NUMBER;
        l_asset_cost_acct VARCHAR2(25);
	l_dep_exp_acct VARCHAR2(25);
	l_dep_res_acct VARCHAR2(25);
	l_asset_cost_account_ccid NUMBER;
	l_reserve_account_ccid NUMBER;
        l_validation_date date;
        l_result BOOLEAN;

        l_path		 VARCHAR2(100);

        -- bulk fecthes
        TYPE rowed_type_tbl_type   IS TABLE OF ROWID  INDEX BY BINARY_INTEGER;
        TYPE adj_id_tbl_type IS TABLE OF  IGI_IAC_ADJUSTMENTS. ADJUSTMENT_ID%TYPE
                  INDEX BY BINARY_INTEGER;
        TYPE book_type_tbl_type IS TABLE OF   IGI_IAC_ADJUSTMENTS.BOOK_TYPE_CODE%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE code_comb_tbl_type IS TABLE OF IGI_IAC_ADJUSTMENTS.CODE_COMBINATION_ID%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE adjustment_type_tbl_type IS TABLE OF  IGI_IAC_ADJUSTMENTS. ADJUSTMENT_TYPE%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE asset_id_tbl_type IS TABLE OF   IGI_IAC_ADJUSTMENTS.ASSET_ID%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE dist_id_tbl_type IS TABLE OF IGI_IAC_ADJUSTMENTS.DISTRIBUTION_ID%TYPE
              INDEX BY BINARY_INTEGER;
        TYPE period_counter_tbl_type IS TABLE OF IGI_IAC_ADJUSTMENTS.PERIOD_COUNTER%TYPE
              INDEX BY BINARY_INTEGER;

        l_row_id rowed_type_tbl_type;
        l_adj_id adj_id_tbl_type;
        l_book_code book_type_tbl_type;
        l_code_comb_id code_comb_tbl_type;
        l_adj_type adjustment_type_tbl_type;
        l_asset_id asset_id_tbl_type;
        l_dist_id dist_id_tbl_type;
        l_period_ctr period_counter_tbl_type;

        l_loop_count                 number;

    BEGIN
        l_path	:= g_path||'Synchronize_Accounts';
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Start of processing for synchronize accounts ');
        FOR l_get_transaction IN c_get_transaction LOOP

            OPEN c_get_adjustments(l_get_transaction.adjustment_id);
            FETCH c_get_adjustments   BULK COLLECT INTO
                l_row_id,
                l_adj_id,
                l_book_code,
                l_code_comb_id,
                l_adj_type,
                l_asset_id,
                l_dist_id,
                l_period_ctr;
            CLOSE c_get_adjustments;

            FOR l_loop_count IN 1.. l_adj_id.count
            LOOP

                l_rowid := l_row_id(l_loop_count);
                l_account_ccid := -1;

                -- fecth the required accounts form the fa_dsitribution accounts for the
                --expense,cost and reserve

                OPEN c_get_accounts(l_dist_id(l_loop_count));
                FETCH c_get_accounts INTO
                        l_cost_ccid,
                        l_expense_ccid,
                        l_reserve_ccid,
                        l_flex_num;
                IF (c_get_accounts%FOUND) THEN
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     Success in  get account ccid  from distribution  accounts ');
                    IF (l_adj_type(l_loop_count) = 'COST') THEN
                        l_account_ccid := l_cost_ccid;
                    ELSIF (l_adj_type(l_loop_count) = 'RESERVE') THEN
                        l_account_ccid := l_reserve_ccid;
                    ELSIF (l_adj_type(l_loop_count) = 'EXPENSE') THEN
                         l_account_ccid := l_expense_ccid;
                    END IF;
                END IF;
                CLOSE c_get_accounts;
                --- get the account from the fa_adjustmemts and fa_distribution_history if not found im
                -- fa_distribution_accounts.

                IF (l_account_ccid = -1)  THEN
                    igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'     Failed to get account ccid  from distribution  accounts  *****');
                    OPEN c_get_account_ccid(l_asset_id(l_loop_count),l_dist_id(l_loop_count),
                                                            l_get_transaction.transaction_type_code ,
                                                            l_adj_type(l_loop_count),
                                                            l_get_transaction.transaction_header_id);
                    FETCH c_get_account_ccid into l_account_ccid;
                    IF c_get_account_ccid%NOTFOUND THEN
                        igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'     Failed to get  COST/RESERVE ccid  in synchronize accounts *****');
                        l_account_ccid := -1;
                    END IF;
                    CLOSE  c_get_account_ccid;

                END IF;

                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'   asset_id' || l_asset_id(l_loop_count));
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'   distribution' ||  l_dist_id(l_loop_count));
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'   adjustment type ' ||l_adj_type(l_loop_count));
                -- get the account ccid for the adjustment
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'   account ccid ' || l_account_ccid);
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     fetched ccid '|| l_code_comb_id(l_loop_count));

                IF l_account_ccid = -1 THEN

                   -- IF the accounts are not found
		   -- generate them using FA workflow
		   -- get the category ID for the asset

		   SELECT a.category_id
		   INTO  l_category_id
		   FROM fa_asset_history a
                       ,fa_distribution_history d
                   WHERE d.distribution_id =   l_dist_id(l_loop_count)
                   AND a.asset_id = d.asset_id
                   AND d.date_effective >= a.date_effective
                   AND d.date_effective < nvl(a.date_ineffective,sysdate);

		   -- Get the default accounts and ccids for a distributions

		   SELECT asset_cost_acct, deprn_expense_acct, deprn_reserve_acct,
		          asset_cost_account_ccid, reserve_account_ccid
		   INTO l_asset_cost_acct, l_dep_exp_acct, l_dep_res_acct,
		        l_asset_cost_account_ccid ,l_reserve_account_ccid
 	  	   FROM fa_category_books
		   WHERE book_type_code = p_book_type_code
  		   AND category_id = l_category_id;

		   -- get the flex_num and default CCID

		   SELECT accounting_flex_structure, flexbuilder_defaults_ccid
		   into l_flex_num, l_default_ccid
    		   FROM fa_book_controls
                   WHERE book_type_code =  p_book_type_code ;

                   IF (l_adj_type(l_loop_count) = 'COST') THEN
                      -- get the COST
 		      l_account_type := 'ASSET_COST';
 		      l_account_seg_val := l_asset_cost_acct;
 		      l_acct_ccid := l_asset_cost_account_ccid;
                   ELSIF (l_adj_type(l_loop_count) ='RESERVE' ) THEN
                      --  get the reserve account
   		      l_account_type := 'DEPRN_RSV';
		      l_account_seg_val := l_dep_res_acct;
		      l_acct_ccid := l_reserve_account_ccid ;
                   ELSIF (l_adj_type(l_loop_count) ='EXPENSE' ) THEN
	  	      -- get the expense account
		      l_account_type :=	'DEPRN_EXP' ;
		      l_account_seg_val := l_dep_exp_acct;
		      l_acct_ccid := l_code_comb_id(l_loop_count);
                   END IF;

                   Select calendar_period_close_date
                   into l_validation_date
                   From fa_deprn_periods
                   where book_type_code = p_book_type_code
                   and period_counter = p_period_counter;

		   l_result := FAFLEX_PKG_WF.START_PROCESS(
                                X_flex_account_type => l_account_type,
                                X_book_type_code    => p_book_type_code,
                                X_flex_num          => l_flex_num,
                                X_dist_ccid         => l_code_comb_id(l_loop_count),
                                X_acct_segval       => l_account_seg_val,
                                X_default_ccid      => l_default_ccid,
                                X_account_ccid      => l_acct_ccid,
                                X_distribution_id   => l_dist_id(l_loop_count),
                                X_validation_date   => l_validation_date,
                                X_return_ccid       => l_account_ccid);
                END IF;


                IF l_account_ccid = -1 THEN
                   FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_ACCOUNT_NOT_FOUND');
                   FND_MESSAGE.SET_TOKEN('PROCESS','Revaluation',TRUE);
                   igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
                                    p_full_path => l_path,
                                    p_remove_from_stack => FALSE);
                   fnd_file.put_line(fnd_file.log, fnd_message.get);

                   return FALSE;
                END IF;


                IF l_account_ccid <>   (l_code_comb_id(l_loop_count))  THEN
                    -- Update the ccid for the adjustment
                    UPDATE igi_iac_adjustments
                    SET code_combination_id= l_account_ccid
                    WHERE rowid=l_rowid;

                    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'       Updated the adjusment with correct ccid' );
                END IF;

            END LOOP;
        END LOOP;
        return TRUE;

    EXCEPTION
        WHEN others THEN
        igi_iac_debug_pkg.debug_unexpected_msg(l_path);
        return FALSE;
    END Synchronize_Accounts;

BEGIN
--===========================FND_LOG.START=====================================
g_state_level :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level :=	FND_LOG.LEVEL_EVENT;
g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level :=	FND_LOG.LEVEL_ERROR;
g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        := 'IGI.PLSQL.igiiarub.igi_iac_reval_utilities.';
--===========================FND_LOG.END=====================================

END;


/
