--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_INIT_STRUCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_INIT_STRUCT" AS
-- $Header: igiiarsb.pls 120.10.12000000.1 2007/08/01 16:17:59 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);

--===========================FND_LOG.END=======================================

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

g_who_user_id           number;
g_who_login_id          number;
g_who_date              date;

/*
procedure log ( p_mesg in varchar2 ) is
begin
 IGI_IAC_REVAL_UTILITIES.log ( p_calling_code => 'INIT_STRUCT'
                             , p_mesg => p_mesg );
end;
*/
function initialize ( fp_reval_control        in   out NOCOPY  IGI_IAC_TYPES.iac_reval_control_type )
return boolean is
  l_Reval_control  IGI_IAC_TYPES.iac_reval_control_type;
  l_path varchar2(100);
begin
  l_path := g_path||'initialize1';
   l_reval_control.revaluation_mode := 'P';  --Preview
   l_reval_control.transaction_type_code := 'REVALUATION';
   l_reval_control.transaction_sub_type := 'OCCASSIONAL';
   l_reval_control.adjustment_status := 'PREVIEW';
   fp_Reval_control := l_reval_control;
   return true;
exception when others then
   fp_Reval_control := l_reval_control;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function initialize ( fp_reval_asset_params   in   out NOCOPY  IGI_IAC_TYPES.iac_reval_asset_params )
return boolean is
   l_Reval_asset_params IGI_IAC_TYPES.iac_reval_asset_params;
   l_path varchar2(100);
begin
   l_path := g_path||'initialize2';
   fp_reval_asset_params := l_reval_asset_params;
   return true;
exception when others then
   fp_reval_asset_params := l_reval_asset_params;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function initialize ( fp_reval_input_asset        in   out NOCOPY  IGI_IAC_TYPES.iac_Reval_input_asset )
return boolean is
     fp_reval_input_asset_old  IGI_IAC_TYPES.iac_Reval_input_asset;
     l_path varchar2(100);
begin
     l_path  := g_path||'initialize3';
    fp_reval_input_asset_old := fp_reval_input_asset;

    fp_reval_input_asset.asset_id              := 0;
    fp_reval_input_asset.book_type_code        := null;
    fp_reval_input_asset.period_counter        := 0;
    fp_reval_input_asset.net_book_value        := 0;
    fp_reval_input_asset.adjusted_cost         := 0;
    fp_reval_input_asset.operating_acct        := 0;
    fp_reval_input_asset.reval_reserve         := 0;
    fp_reval_input_asset.deprn_amount          := 0;
    fp_reval_input_asset.deprn_reserve         := 0;
    fp_reval_input_asset.backlog_deprn_reserve := 0;
    fp_reval_input_asset.general_fund          := 0;
    fp_reval_input_asset.last_reval_date       := null;
    fp_reval_input_asset.current_reval_factor   := 0;
    fp_reval_input_asset.cumulative_reval_factor  := 0;
    fp_reval_input_asset.created_by           := 0;
    fp_reval_input_asset.creation_date        := null;
    fp_reval_input_asset.last_update_login    := 0;
    fp_reval_input_asset.last_update_date     := null;
    fp_reval_input_asset.last_updated_by      := 0;
    return true;
exception when others then
   fp_reval_input_asset := fp_reval_input_asset_old;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function initialize ( fp_reval_asset_rules        in   out NOCOPY  IGI_IAC_TYPES.iac_Reval_asset_rules )
return boolean is
  fp_reval_asset_rules_old  IGI_IAC_TYPES.iac_Reval_asset_rules;
  l_path varchar2(100);
begin
  l_path := g_path||'initialize4';
 fp_reval_asset_rules_old := fp_reval_asset_rules;

 fp_reval_asset_rules.revaluation_id             := 0;
 fp_reval_asset_rules.book_type_code            := null;
 fp_reval_asset_rules.category_id               := 0;
 fp_reval_asset_rules.asset_id                  := 0;
 fp_reval_asset_rules.revaluation_factor        := 0;
 fp_reval_asset_rules.revaluation_type          := null;
 fp_reval_asset_rules.new_cost                  := 0;
 fp_reval_asset_rules.current_cost              := 0;
 fp_reval_asset_rules.selected_for_reval_flag   := null;
 fp_reval_asset_rules.selected_for_calc_flag    := null;
 fp_reval_asset_rules.created_by                := 0;
 fp_reval_asset_rules.creation_date             := null;
 fp_reval_asset_rules.last_update_login         := 0;
 fp_reval_asset_rules.last_update_date          := null;
 fp_reval_asset_rules.last_updated_by           := 0;
 fp_reval_asset_rules.allow_prof_update         := null;
   return true;
exception when others then
   fp_reval_asset_rules := fp_reval_asset_rules_old;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function initialize ( fp_asset_info        in   out NOCOPY  IGI_IAC_TYPES.fa_hist_asset_info )
return boolean is
 l_asset_info IGI_IAC_TYPES.fa_hist_asset_info;
 l_path varchar2(100);
begin
 l_path := g_path||'initialize5';
   fp_Asset_info := l_asset_info;
   return true;
exception when others then
   fp_Asset_info := l_asset_info;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function initialize ( fp_Reval_Rates         in   out NOCOPY  IGI_IAC_TYPES.iac_reval_rate_params )
return boolean is
    fp_Reval_Rates_old IGI_IAC_TYPES.iac_reval_rate_params;
    l_path varchar2(100);
begin
    l_path := g_path||'initialize6';
    fp_Reval_Rates_old := fp_Reval_Rates;

    fp_Reval_Rates.asset_id                  := 0;
    fp_Reval_Rates.book_type_code            := null;
    fp_Reval_Rates.revaluation_id            := 0;
    fp_Reval_Rates.period_counter            := 0;
    fp_Reval_Rates.reval_type                := null;
    fp_Reval_Rates.current_reval_factor      := 0;
    fp_Reval_Rates.cumulative_reval_factor   := 0;
    fp_Reval_Rates.processed_flag            := null;
    fp_Reval_Rates.latest_record             := null;
    fp_Reval_Rates.created_by                := 0;
    fp_Reval_Rates.creation_date             := null;
    fp_Reval_Rates.last_update_login         := 0;
    fp_Reval_Rates.last_update_date          := null;
    fp_Reval_Rates.last_updated_by           := 0;
    fp_Reval_Rates.adjustment_id             := 0;
   return true;
exception when others then
   fp_Reval_Rates := fp_Reval_Rates_old;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function initialize ( fp_Reval_exceptions         in   out NOCOPY  IGI_IAC_TYPES.iac_reval_exception_line )
return boolean is
   l_line IGI_IAC_TYPES.iac_reval_exception_line ;
   l_path varchar2(100);
begin
   l_path := g_path||'initialize7';
   fp_reval_Exceptions := l_line;
   return true;
exception when others then
   fp_reval_Exceptions := l_line;
   return false;
end;


function initialize ( fp_reval_params         in   out NOCOPY  IGI_IAC_TYPES.iac_reval_params )
return boolean is
   fp_reval_params_old IGI_IAC_TYPES.iac_reval_params;
   l_path varchar2(100);
begin
   l_path := g_path||'initialize8';

   fp_reval_params_old := fp_reval_params;

   if not initialize ( fp_reval_params.reval_control ) then
      return false;
   end if;

  if not initialize ( fp_reval_params.reval_asset_params ) then
      return false;
   end if;
  if not initialize ( fp_reval_params.reval_input_Asset ) then
      return false;
   end if;

   if not initialize ( fp_reval_params.reval_output_asset ) then
      return false;
   end if;
  if not initialize ( fp_reval_params.reval_output_asset_mvmt ) then
      return false;
   end if;
  if not initialize ( fp_reval_params.reval_prev_rate_info ) then
      return false;
   end if;
   if not initialize ( fp_reval_params.reval_curr_rate_info_first ) then
      return false;
   end if;
  if not initialize ( fp_reval_params.reval_curr_rate_info_next ) then
      return false;
   end if;
  if not initialize ( fp_reval_params.reval_asset_exceptions ) then
      return false;
   end if;
   if not initialize ( fp_reval_params.fa_asset_info ) then
      return false;
   end if;
  if not initialize ( fp_reval_params.reval_asset_rules ) then
      return false;
   end if;

   return true;
exception when others then
   fp_reval_params := fp_reval_params_old;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function init_struct_for_srs    ( fp_asset_id                  in      number
                                 , fp_book_type_code           in      varchar2
                                 , fp_revaluation_id           in      number
                                 , fp_revaluation_mode         in      varchar2
                                 , fp_period_counter           in      number
                                 , fp_control                  in      IGI_IAC_TYPES.iac_reval_control_type
                                 , fp_reval_params             out NOCOPY  IGI_IAC_TYPES.iac_reval_params
                                 )
return  boolean is
     l_revaluation_date date;
     l_reval_params IGI_IAC_TYPES.iac_reval_params;
     l_output_dists IGI_IAC_TYPES.iac_reval_output_dists;
     l_idx          BINARY_INTEGER;
     fp_reval_params_old IGI_IAC_TYPES.iac_reval_params;
     l_path varchar2(100);
begin
     l_idx  := 1;
     l_path := g_path||'init_struct_for_srs';

   if not  initialize ( fp_reval_params         => l_Reval_params )
   then
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Error initializing structure');
      return false;
   end if;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Begin init_struct_for_srs');

/* update or populate the  reval_control record */
     l_reval_params.reval_control.revaluation_mode := fp_revaluation_mode;
    -- get the revaluation type!
    -- this needs to be optimized by adding parameter to do_revaluation_asset.
    begin
        select dd.*
        into   l_reval_params.reval_asset_rules
        from   igi_iac_reval_asset_rules dd
        where  dd.asset_id       = fp_asset_id
          and  dd.book_type_code = fp_book_type_code
          and  dd.revaluation_id = fp_revaluation_id
          ;
        select h.revaluation_date
        into   l_reval_params.reval_asset_params.revaluation_date
        from   igi_iac_revaluations      h
        where  h.revaluation_id = fp_revaluation_id
        ;
        l_reval_params.reval_asset_params.revaluation_rate
          := l_reval_params.reval_Asset_rules.revaluation_Factor;

        if l_reval_params.reval_asset_rules.revaluation_type = 'O' then
           l_reval_params.reval_control.transaction_sub_type := 'OCCASSIONAL';
        else
           l_reval_params.reval_control.transaction_sub_type := 'PROFESSIONAL';
        end if;

    exception when others then
       igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'+failed to get the asset rules');
       igi_iac_debug_pkg.debug_unexpected_msg(l_path);
       return false;
    end;
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+set the reval control based on reval mode');
     if l_reval_params.reval_control.revaluation_mode = 'P'
     then
         l_reval_params.reval_control.message_level           := 3;
         l_reval_params.reval_control.validate_business_rules := true;
         l_reval_params.reval_control.create_acctg_entries    := true;
         l_reval_params.reval_control.crud_allowed            := true;
         l_reval_params.reval_control.modify_balances         := false;
     elsif l_reval_params.reval_control.revaluation_mode in ( 'R','L') then
         l_reval_params.reval_control.validate_business_rules := false;
         l_reval_params.reval_control.message_level           := 3;
         l_reval_params.reval_control.create_acctg_entries    := false;
         l_reval_params.reval_control.crud_allowed            := true;
         l_reval_params.reval_control.modify_balances         := true;
     else
         l_reval_params.reval_control.validate_business_rules := false;
         l_reval_params.reval_control.message_level           := 0;
         l_reval_params.reval_control.create_acctg_entries    := false;
         l_reval_params.reval_control.crud_allowed            := false;
         l_reval_params.reval_control.modify_balances         := false;
     end if;
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+set the reval control other defaults');
     l_reval_params.reval_control.print_report                := false;
 /* populate the reval_asset_params record, category id would be calculated later in the code
    when fa information is retrieved.
  */
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+populate the reval_asset_params record');
     l_reval_params.reval_asset_params.asset_id            := fp_asset_id;
     l_reval_params.reval_asset_params.book_type_code      := fp_book_type_code;
     l_reval_params.reval_asset_params.revaluation_id      := fp_revaluation_id;
     l_reval_params.reval_asset_params.period_counter      := fp_period_counter;
     l_Reval_params.reval_asset_params.first_set_adjustment_id := 0;
     l_reval_params.reval_asset_params.second_set_adjustment_id := 0;
 /* populate the reval_input_asset  record */
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+populate the reval_input_asset record');
     declare
        l_max_period_counter number := 0;
     begin
        select nvl(max(period_counter),0)
        into   l_max_period_counter
        from   igi_iac_asset_balances
        where  asset_id   = fp_asset_id
        and    book_type_code = fp_book_type_code
        and    period_counter <= fp_period_counter
        ;
        if l_max_period_counter = 0 then

           l_reval_params.reval_control.first_time_flag             := true;
           l_reval_params.reval_input_asset.asset_id                := fp_asset_id;
           l_reval_params.reval_input_asset.book_type_code          := fp_book_type_code ;
           l_reval_params.reval_input_asset.period_counter          := fp_period_counter ;
           l_reval_params.reval_input_asset.net_book_value          := 0;
           l_reval_params.reval_input_asset.adjusted_cost           := 0;
           l_reval_params.reval_input_asset.operating_acct          := 0 ;
           l_reval_params.reval_input_asset.reval_reserve           := 0 ;
           l_reval_params.reval_input_asset.deprn_amount            := 0;
           l_reval_params.reval_input_asset.deprn_reserve           := 0 ;
           l_reval_params.reval_input_asset.backlog_deprn_reserve   := 0 ;
           l_reval_params.reval_input_asset.general_fund            := 0;
           l_reval_params.reval_input_asset.last_reval_date         := l_revaluation_date;
           l_reval_params.reval_input_asset.current_reval_factor    := 1 ;
           l_reval_params.reval_input_asset.cumulative_reval_factor := 1 ;
           l_reval_params.reval_input_asset.created_by              := g_who_user_id   ;
           l_reval_params.reval_input_asset.creation_date           := g_who_date  ;
           l_reval_params.reval_input_asset.last_update_login       := g_who_login_id ;
           l_reval_params.reval_input_asset.last_update_date        := g_who_date ;
           l_reval_params.reval_input_asset.last_updated_by         := g_who_user_id;
        else
           begin
               select *
               into   l_reval_params.reval_input_asset
               from   igi_iac_asset_balances
               where  asset_id   = fp_asset_id
               and    book_type_code = fp_book_type_code
               and    period_counter = l_max_period_counter
               ;
           exception when others then
               return false;
           end;
           l_reval_params.reval_control.first_time_flag := false;
        end if;

     exception when others then
        return false;
     end;
     if l_reval_params.reval_control.first_time_flag then
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+first time processing for this asset');
     end if;
 /* populate the reval_output_asset record */
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+populate the reval_output_asset record');
     l_reval_params.reval_output_asset := l_reval_params.reval_input_asset;
 /* populate the reval_output_asset_mvmt record */
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+populate the reval_output_asset_mvmt record');
     if not initialize ( l_reval_params.reval_output_asset_mvmt ) then
      return false;
     end if;

     l_reval_params.reval_output_asset_mvmt.asset_id          := fp_asset_id;
     l_reval_params.reval_output_asset_mvmt.book_type_code    := fp_book_type_code;
     l_reval_params.reval_output_asset_mvmt.period_counter    := fp_period_counter;
 /* populate the reval_prev_rate_info  record */
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+populate the reval_prev_rate_info record');
    declare
      l_dummy varchar2(1);
    begin
      select *
      into   l_reval_params.reval_prev_rate_info
      from   igi_iac_revaluation_rates
      where  asset_id       = fp_asset_id
        and  period_counter <= fp_period_counter
        and  book_type_code = fp_book_type_code
        and  reval_type     in ( 'O','P')
        and  nvl(latest_record,'X')  = 'Y'
        ;
    exception
        when no_data_found then
            l_reval_params.reval_prev_rate_info.asset_id            :=      fp_asset_id;
            l_reval_params.reval_prev_rate_info.book_type_code      :=      fp_book_type_code;
            l_reval_params.reval_prev_rate_info.revaluation_id      :=      fp_revaluation_id;
            l_reval_params.reval_prev_rate_info.period_counter      :=      fp_period_counter;
            l_reval_params.reval_prev_rate_info.reval_type          :=
                                        l_reval_params.reval_Asset_rules.revaluation_type;
            l_reval_params.reval_prev_rate_info.current_reval_factor :=      1;
            l_reval_params.reval_prev_rate_info.cumulative_reval_factor     :=      1;
            l_reval_params.reval_prev_rate_info.processed_flag      :=      'Y';
            l_reval_params.reval_prev_rate_info.latest_record       :=      'Y';
            l_reval_params.reval_prev_rate_info.created_by          :=      g_who_user_id;
            l_reval_params.reval_prev_rate_info.creation_date       :=      g_who_date;
            l_reval_params.reval_prev_rate_info.last_update_login   :=      g_who_login_id;
            l_reval_params.reval_prev_rate_info.last_update_date    :=      g_who_date;
            l_reval_params.reval_prev_rate_info.last_updated_by     :=      g_who_user_id;
        when too_many_rows then
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+more than 1 revaluation record found with latest record set. aborting.');
            return false;
        when others then
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'error getting information from revaluation rates table'||sqlerrm);
            return false;
    end;

 /*  fa information from fa_books and fa_deprn summary from the historic books! */
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+populate the fa_asset_info record');
     declare
        cursor c_fa_books is
           select  fb.cost
                , fb.adjusted_cost
                , fb.original_cost
                , fb.salvage_value
                , fb.life_in_months
                , fb.rate_adjustment_factor
                , fb.period_counter_fully_reserved
                , fb.adjusted_recoverable_cost
                , fb.recoverable_cost
                , fb.date_placed_in_service
                , fb.deprn_start_date
                , fb.depreciate_flag
                , fbc.last_period_counter
                , fbc.gl_posting_allowed_flag
                , fds.ytd_deprn
                , fds.deprn_reserve
                , fds.deprn_amount
                , fadd.asset_category_id
          from  fa_books fb
                , fa_book_controls fbc
                , fa_deprn_summary fds
                , fa_additions fadd
          where  fb.book_type_code = fbc.book_type_code
            and  fb.book_type_code = fp_book_type_code
            -- and  fbc.last_period_counter = fp_period_counter
            and  fadd.asset_id           = fp_asset_id
            and  fb.asset_id             = fp_asset_id
            and  fb.transaction_header_id_out is null
            and  fds.book_type_code      = fp_book_type_code
            and  fds.asset_id            = fp_asset_id
            and  fds.period_counter      = ( select max(period_counter)
                                             from   fa_deprn_summary
                                             where  asset_id = fp_asset_id
                                              and   book_type_code = fp_book_type_code
                                              and   period_counter <= fp_period_counter
                                            )
            -- this should fail with asset with deprn = no, need to verify this later on...
            ;
--            l_available boolean := false;
            l_dpis_period           fa_deprn_periods.period_counter%TYPE;
            l_current_period  fa_deprn_periods.period_counter%TYPE;
     begin

           for l_b in c_fa_books loop

                /*Salavge value correction*/
                If l_b.Salvage_value <> 0 THen
                -- resreve
                IF NOT igi_iac_salvage_pkg.correction(p_asset_id => fp_asset_id,
                                                      P_book_type_code =>fp_book_type_code,
                                                      P_value=>l_b.deprn_reserve,
                                                      P_cost=>l_b.cost,
                                                      P_salvage_value=>l_b.salvage_value,
                                                      P_calling_program=>'REVALUATION') THEN
	            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+Salvage Value Correction Failed : ');
                    return false;
                 END IF;
                 -- YTD
                IF NOT igi_iac_salvage_pkg.correction(p_asset_id => fp_asset_id,
                                                      P_book_type_code =>fp_book_type_code,
                                                      P_value=>l_b.ytd_deprn,
                                                      P_cost=>l_b.cost,
                                                      P_salvage_value=>l_b.salvage_value,
                                                      P_calling_program=>'REVALUATION') THEN

	          igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+Salvage Value Correction Failed : ');
                  return false;
                 END IF;
                 -- deprn amount
                 IF NOT igi_iac_salvage_pkg.correction(p_asset_id => fp_asset_id,
                                                      P_book_type_code =>fp_book_type_code,
                                                      P_value=>l_b.deprn_amount,
                                                      P_cost=>l_b.cost,
                                                      P_salvage_value=>l_b.salvage_value,
                                                      P_calling_program=>'REVALUATION') THEN

	            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+Salvage Value Correction Failed : ');
                    return false;
                 END IF ;
                END IF;
                /*salvage value correction*/



                l_reval_params.fa_asset_info.cost                          := l_b.cost;
                l_reval_params.fa_asset_info.adjusted_cost                 := l_b.adjusted_cost;
                l_reval_params.fa_asset_info.original_cost                 := l_b.original_cost;
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+original cost : '|| l_b.original_cost);
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+cost          : '|| l_b.cost);
                l_reval_params.fa_asset_info.salvage_value                 := l_b.salvage_value;
                l_reval_params.fa_asset_info.life_in_months                := l_b.life_in_months;
                l_reval_params.fa_asset_info.rate_adjustment_factor        := l_b.rate_adjustment_factor;
                l_reval_params.fa_asset_info.period_counter_fully_reserved := l_b.period_counter_fully_reserved;
                l_reval_params.fa_asset_info.adjusted_recoverable_cost     := l_b.adjusted_recoverable_cost;
                l_reval_params.fa_asset_info.recoverable_cost              := l_b.recoverable_cost;
                l_reval_params.fa_asset_info.date_placed_in_service        := l_b.date_placed_in_service;
                l_reval_params.fa_asset_info.deprn_start_date              := l_b.deprn_start_date;
                l_reval_params.fa_asset_info.last_period_counter           := l_b.last_period_counter;
                l_reval_params.fa_asset_info.gl_posting_allowed_flag       := l_b.gl_posting_allowed_flag;
                l_reval_params.fa_asset_info.ytd_deprn                     := l_b.ytd_deprn;
                l_reval_params.fa_asset_info.deprn_reserve                 := l_b.deprn_reserve;
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+deprn reserve : '|| l_b.deprn_reserve);
                l_reval_params.fa_asset_info.deprn_amount                  := l_b.deprn_amount;
                l_reval_params.fa_asset_info.depreciate_flag               := l_b.depreciate_flag;
                l_reval_params.reval_asset_params.category_id              := l_b.asset_category_id;

                l_current_period := fp_period_counter;
                IF NOT igi_iac_ytd_engine.Calculate_YTD
                                ( fp_book_type_code,
                                fp_asset_id,
                                l_reval_params.fa_asset_info,
                                l_dpis_period,
                                l_current_period,
                                l_reval_params.reval_control.calling_program) THEN
                    RETURN FALSE;
                END IF;

           end loop;

     exception when others then
          igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'+error in get period info from common utils'||sqlerrm);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'End init_struct_for_srs');
          return false;
     end;

     fp_reval_params := l_reval_params;
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+successful processing for init_struct_for_srs');
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'End init_struct_for_srs');

     return true;
exception when others then
  fp_reval_params := fp_reval_params_old;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return false;
end;

/*
-- initialize if called for calculation from the form
*/

function init_struct_for_calc    ( fp_asset_id                 in      number
                                 , fp_book_type_code           in      varchar2
                                 , fp_revaluation_id           in      number
                                 , fp_revaluation_mode         in      varchar2
                                 , fp_period_counter           in      number
                                 , fp_control                  in      IGI_IAC_TYPES.iac_reval_control_type
                                 , fp_reval_params             out NOCOPY     IGI_IAC_TYPES.iac_reval_params
                                 )
return  boolean is
      l_revaluation_date date;
     l_reval_params IGI_IAC_TYPES.iac_reval_params;
     l_output_dists IGI_IAC_TYPES.iac_reval_output_dists;
     l_idx          BINARY_INTEGER;
     fp_reval_params_old IGI_IAC_TYPES.iac_reval_params;
     l_path varchar2(100);
begin
     l_idx := 1;
     l_path := g_path||'init_struct_for_calc';

   if not  initialize ( fp_reval_params         => l_Reval_params )
   then
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Error initializing structure');
      return false;
   end if;

   igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Error initializing structure');

/* update or populate the  reval_control record */
     l_reval_params.reval_control.revaluation_mode := fp_revaluation_mode;
    begin
        select dd.*
        into   l_reval_params.reval_asset_rules
        from   igi_iac_reval_asset_rules dd
        where  dd.asset_id       = fp_asset_id
          and  dd.book_type_code = fp_book_type_code
          and  dd.revaluation_id = fp_revaluation_id
          ;
        select h.revaluation_date
        into   l_reval_params.reval_asset_params.revaluation_date
        from   igi_iac_revaluations      h
        where  h.revaluation_id = fp_revaluation_id
        ;
        l_reval_params.reval_asset_params.revaluation_rate
          := l_reval_params.reval_Asset_rules.revaluation_Factor;

        if l_reval_params.reval_asset_rules.revaluation_type = 'O' then
           l_reval_params.reval_control.transaction_sub_type := 'OCCASSIONAL';
        else
           l_reval_params.reval_control.transaction_sub_type := 'PROFESSIONAL';
        end if;

    exception when others then
       igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'+failed to get the asset rules');
       return false;
    end;
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+set the reval control based on reval mode');
     l_reval_params.reval_control.message_level           := 3;
     l_reval_params.reval_control.validate_business_rules := false;
     l_reval_params.reval_control.create_acctg_entries    := false;
     l_reval_params.reval_control.crud_allowed            := false;
     l_reval_params.reval_control.modify_balances         := false;
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+set the reval control other defaults');
     l_reval_params.reval_control.print_report            := false;
 /* populate the reval_asset_params record, category id would be calculated later in the code
    when fa information is retrieved.
  */
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+populate the reval_asset_params record');
     l_reval_params.reval_asset_params.asset_id            := fp_asset_id;
     l_reval_params.reval_asset_params.book_type_code      := fp_book_type_code;
     l_reval_params.reval_asset_params.revaluation_id      := fp_revaluation_id;
     l_reval_params.reval_asset_params.period_counter      := fp_period_counter;
     l_Reval_params.reval_asset_params.first_set_adjustment_id := 0;
     l_reval_params.reval_asset_params.second_set_adjustment_id := 0;
 /* populate the reval_input_asset  record */
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+populate the reval_input_asset record');
     declare
        l_max_period_counter number := 0;
     begin
        select nvl(max(period_counter),0)
        into   l_max_period_counter
        from   igi_iac_asset_balances
        where  asset_id   = fp_asset_id
        and    book_type_code = fp_book_type_code
        and    period_counter <= fp_period_counter
        ;
        if l_max_period_counter = 0 then

           l_reval_params.reval_control.first_time_flag             := true;
           l_reval_params.reval_input_asset.asset_id                := fp_asset_id;
           l_reval_params.reval_input_asset.book_type_code          := fp_book_type_code ;
           l_reval_params.reval_input_asset.period_counter          := fp_period_counter ;
           l_reval_params.reval_input_asset.net_book_value          := 0;
           l_reval_params.reval_input_asset.adjusted_cost           := 0;
           l_reval_params.reval_input_asset.operating_acct          := 0 ;
           l_reval_params.reval_input_asset.reval_reserve           := 0 ;
           l_reval_params.reval_input_asset.deprn_amount            := 0;
           l_reval_params.reval_input_asset.deprn_reserve           := 0 ;
           l_reval_params.reval_input_asset.backlog_deprn_reserve   := 0 ;
           l_reval_params.reval_input_asset.general_fund            := 0;
           l_reval_params.reval_input_asset.last_reval_date         := l_revaluation_date;
           l_reval_params.reval_input_asset.current_reval_factor    := 1 ;
           l_reval_params.reval_input_asset.cumulative_reval_factor := 1 ;
           l_reval_params.reval_input_asset.created_by              := g_who_user_id   ;
           l_reval_params.reval_input_asset.creation_date           := g_who_date  ;
           l_reval_params.reval_input_asset.last_update_login       := g_who_login_id ;
           l_reval_params.reval_input_asset.last_update_date        := g_who_date ;
           l_reval_params.reval_input_asset.last_updated_by         := g_who_user_id;
        else
           begin
               select *
               into   l_reval_params.reval_input_asset
               from   igi_iac_asset_balances
               where  asset_id   = fp_asset_id
               and    book_type_code = fp_book_type_code
               and    period_counter = l_max_period_counter
               ;
           exception when others then
               return false;
           end;
           l_reval_params.reval_control.first_time_flag := false;
        end if;

     exception when others then
        return false;
     end;

 /* populate the reval_output_asset record */

     l_reval_params.reval_output_asset := l_reval_params.reval_input_asset;
 /* populate the reval_output_asset_mvmt record */
     if not initialize ( l_reval_params.reval_output_asset_mvmt ) then
        return false;
     end if;

     l_reval_params.reval_output_asset_mvmt.asset_id          := fp_asset_id;
     l_reval_params.reval_output_asset_mvmt.book_type_code    := fp_book_type_code;
     l_reval_params.reval_output_asset_mvmt.period_counter    := fp_period_counter;
 /* populate the reval_prev_rate_info  record */

    l_reval_params.reval_prev_rate_info.cumulative_reval_factor
               := l_reval_params.reval_input_asset.cumulative_reval_factor;


    l_reval_params.reval_prev_rate_info.current_reval_factor   :=
    l_reval_params.reval_prev_rate_info.cumulative_reval_factor;

    l_reval_params.reval_prev_rate_info.asset_id                    :=      fp_asset_id;
    l_reval_params.reval_prev_rate_info.book_type_code              :=      fp_book_type_code;
    l_reval_params.reval_prev_rate_info.revaluation_id              :=      fp_revaluation_id;
    l_reval_params.reval_prev_rate_info.period_counter              :=      fp_period_counter;
    l_reval_params.reval_prev_rate_info.reval_type                  :=
                                             l_reval_params.reval_Asset_rules.revaluation_type;
    l_reval_params.reval_prev_rate_info.processed_flag              :=      'Y';
    l_reval_params.reval_prev_rate_info.latest_record               :=      'Y';
    l_reval_params.reval_prev_rate_info.created_by                  :=      g_who_user_id;
    l_reval_params.reval_prev_rate_info.creation_date               :=      g_who_date;
    l_reval_params.reval_prev_rate_info.last_update_login           :=      g_who_login_id;
    l_reval_params.reval_prev_rate_info.last_update_date            :=      g_who_date;
    l_reval_params.reval_prev_rate_info.last_updated_by             :=      g_who_user_id;


 /*  fa information from fa_books and fa_deprn summary from the historic books! */
     declare
        cursor c_fa_books is
           select  fb.cost
                , fb.adjusted_cost
                , fb.original_cost
                , fb.salvage_value
                , fb.life_in_months
                , fb.rate_adjustment_factor
                , fb.period_counter_fully_reserved
                , fb.adjusted_recoverable_cost
                , fb.recoverable_cost
                , fb.date_placed_in_service
                , fb.deprn_start_date
                , fb.depreciate_flag
                , fbc.last_period_counter
                , fbc.gl_posting_allowed_flag
                , fds.ytd_deprn
                , fds.deprn_reserve
                , fds.deprn_amount
                , fadd.asset_category_id
          from  fa_books fb
                , fa_book_controls fbc
                , fa_deprn_summary fds
                , fa_additions fadd
          where  fb.book_type_code = fbc.book_type_code
            and  fb.book_type_code = fp_book_type_code
            and  fadd.asset_id           = fp_asset_id
            and  fb.asset_id             = fp_asset_id
            and  fb.transaction_header_id_out is null
            and  fds.book_type_code      = fp_book_type_code
            and  fds.asset_id            = fp_asset_id
            and  fds.period_counter      = ( select max(period_counter)
                                             from   fa_deprn_summary
                                             where  asset_id = fp_asset_id
                                              and   book_type_code = fp_book_type_code
                                              and   period_counter <= fp_period_counter
                                            )
            -- this should fail with asset with deprn = no, need to verify this later on...
            ;
--            l_available boolean := false;
            l_dpis_period           fa_deprn_periods.period_counter%TYPE;
            l_current_period  fa_deprn_periods.period_counter%TYPE;

     begin
          for l_b in c_fa_books loop

              /*Salavge value correction*/
                -- resreve
                If l_b.Salvage_value <> 0 THen
                    IF NOT igi_iac_salvage_pkg.correction(p_asset_id => fp_asset_id,
                                                        P_book_type_code =>fp_book_type_code,
                                                      P_value=>l_b.deprn_reserve,
                                                      P_cost=>l_b.cost,
                                                      P_salvage_value=>l_b.salvage_value,
                                                      P_calling_program=>'REVALUATION') THEN
    			igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+Salvage Value Correction Failed : ');
                        Return false;
                    END IF;
                 -- YTD
                    IF NOT igi_iac_salvage_pkg.correction(p_asset_id => fp_asset_id,
                                                      P_book_type_code =>fp_book_type_code,
                                                      P_value=>l_b.ytd_deprn,
                                                      P_cost=>l_b.cost,
                                                      P_salvage_value=>l_b.salvage_value,
                                                      P_calling_program=>'REVALUATION') THEN

    			igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+Salvage Value Correction Failed : ');
                        Return false;
                     END IF;
                  -- deprn amount
                    IF NOT igi_iac_salvage_pkg.correction(p_asset_id => fp_asset_id,
                                                      P_book_type_code =>fp_book_type_code,
                                                      P_value=>l_b.deprn_amount,
                                                      P_cost=>l_b.cost,
                                                      P_salvage_value=>l_b.salvage_value,
                                                      P_calling_program=>'REVALUATION') THEN
    			igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+Salvage Value Correction Failed : ');
                        Return false;
                     END IF;
                  End If;
                /*salvage value correction*/

                l_reval_params.fa_asset_info.cost                          := l_b.cost;
                l_reval_params.fa_asset_info.adjusted_cost                 := l_b.adjusted_cost;
                l_reval_params.fa_asset_info.original_cost                 := l_b.original_cost;
                l_reval_params.fa_asset_info.salvage_value                 := l_b.salvage_value;
                l_reval_params.fa_asset_info.life_in_months                := l_b.life_in_months;
                l_reval_params.fa_asset_info.rate_adjustment_factor        := l_b.rate_adjustment_factor;
                l_reval_params.fa_asset_info.period_counter_fully_reserved := l_b.period_counter_fully_reserved;
                l_reval_params.fa_asset_info.adjusted_recoverable_cost     := l_b.adjusted_recoverable_cost;
                l_reval_params.fa_asset_info.recoverable_cost              := l_b.recoverable_cost;
                l_reval_params.fa_asset_info.date_placed_in_service        := l_b.date_placed_in_service;
                l_reval_params.fa_asset_info.deprn_start_date              := l_b.deprn_start_date;
                l_reval_params.fa_asset_info.last_period_counter           := l_b.last_period_counter;
                l_reval_params.fa_asset_info.gl_posting_allowed_flag       := l_b.gl_posting_allowed_flag;
                l_reval_params.fa_asset_info.ytd_deprn                     := l_b.ytd_deprn;
                l_reval_params.fa_asset_info.deprn_reserve                 := l_b.deprn_reserve;
                l_reval_params.fa_asset_info.deprn_amount                  := l_b.deprn_amount;
                l_reval_params.fa_asset_info.depreciate_flag               := l_b.depreciate_flag;
                l_reval_params.reval_asset_params.category_id              := l_b.asset_category_id;

                l_current_period := fp_period_counter;
                IF NOT igi_iac_ytd_engine.Calculate_YTD
                                ( fp_book_type_code,
                                fp_asset_id,
                                l_reval_params.fa_asset_info,
                                l_dpis_period,
                                l_current_period,
                                l_reval_params.reval_control.calling_program) THEN
                    RETURN FALSE;
                END IF;

           end loop;

     exception when others then
          igi_iac_debug_pkg.debug_unexpected_msg(l_path);
          return false;
     end;

     fp_reval_params := l_reval_params;

     return true;
exception when others then
 fp_reval_params := fp_reval_params_old;
 igi_iac_debug_pkg.debug_unexpected_msg(l_path);
 return false;
end;

BEGIN
    --===========================FND_LOG.START=====================================
    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        := 'IGI.PLSQL.igiiarsb.IGI_IAC_REVAL_INIT_STRUCT.';
    --===========================FND_LOG.END=======================================

    g_who_user_id   := fnd_global.user_id;
    g_who_login_id  := fnd_global.login_id;
    g_who_date      := sysdate;

END;


/
