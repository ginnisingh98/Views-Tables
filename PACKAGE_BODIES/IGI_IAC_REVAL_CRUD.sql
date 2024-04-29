--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_CRUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_CRUD" AS
-- $Header: igiiardb.pls 120.24.12010000.2 2010/06/24 12:18:08 schakkin ship $
l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

--===========================FND_LOG.START=====================================
g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);
--===========================FND_LOG.END=======================================

     cursor c_exists (cp_period_counter   in number
                , cp_asset_id        in number
                , cp_book_type_code  in varchar2
                ) is
     select cumulative_reval_factor, current_reval_factor
     from   igi_iac_asset_balances
     where  asset_id       = cp_asset_id
       and  book_type_code = cp_book_type_code
       and  period_counter = cp_period_counter
     ;
procedure do_commit is
begin
    if IGI_IAC_REVAL_UTILITIES.debug then
       rollback;
    else
        commit;
    end if;
end;

procedure do_round ( p_amount in out NOCOPY number, p_book_type_code in varchar2) is
      l_path varchar2(150) := g_path||'do_round(p_amount,p_book_type_code)';
      l_amount number     := p_amount;
      l_amount_old number := p_amount;
      --l_path varchar2(150) := g_path||'do_round';
    begin
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'--- Inside Round() ---');
       IF IGI_IAC_COMMON_UTILS.Iac_Round(X_Amount => l_amount, X_Book => p_book_type_code)
       THEN
          p_amount := l_amount;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is TRUE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       ELSE
          p_amount := round( l_amount, 2);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'IGI_IAC_COMMON_UTILS.Iac_Round is FALSE');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_amount = '||p_amount);
       END IF;
    exception when others then
      p_amount := l_amount_old;
      igi_iac_debug_pkg.debug_unexpected_msg(l_path);
      Raise;
end;

function create_exceptions
    ( fp_reval_exceptions    in out NOCOPY IGI_IAC_TYPES.iac_reval_exception_line
    , fp_revaluation_id      in     NUMBER
    )
return boolean is

   l_Category_id number;
   l_login_id    number ;
   l_user_id     number ;
   l_fp_reval_exceptions IGI_IAC_TYPES.iac_reval_exception_line;
   l_path varchar2(150) ;
begin
   l_login_id := fnd_global.login_id;
   l_user_id := fnd_global.user_id;
   l_path := g_path||'create_exceptions';

  -- for NOCOPY.
  l_fp_reval_exceptions := fp_reval_exceptions;

  delete from igi_iac_exceptions
  where asset_id       = fp_reval_exceptions.asset_id
  and   book_type_code = fp_reval_exceptions.book_type_code
  and   revaluation_id = fp_revaluation_id;

  select asset_category_id
  into   l_category_id
  from   fa_additions
  where  asset_id = fp_reval_exceptions.asset_id;

  insert into igi_iac_exceptions
      (
     revaluation_id ,
     asset_id        ,
     category_id     ,
     book_type_code ,
     exception_message  ,
     created_by       ,
     creation_date   ,
     last_update_login ,
     last_update_date   ,
     last_updated_by    )
  values
     (
       fp_revaluation_id
     , fp_reval_exceptions.asset_id
     , l_category_id
     , fp_reval_exceptions.book_type_code
     , fp_reval_exceptions.reason
     , l_user_id
     , sysdate
     , l_login_id
     , sysdate
     , l_user_id
     ) ;

  if sql%found then
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserted into exceptions');
  else
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'No records to insert');
  end if;

  return true;

EXCEPTION
  WHEN OTHERS THEN
  fp_reval_exceptions := l_fp_reval_exceptions;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return FALSE;
end;

function create_txn_headers
    ( fp_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
    , fp_second_set   in boolean  )
return boolean is

   l_rowid rowid;
   l_max_adjustment_id number;
   l_adjustment_id     igi_iac_transaction_headers.adjustment_id%TYPE;
   l_reval_type_flag   varchar2(1);
   l_fp_reval_params IGI_IAC_TYPES.iac_reval_params;
   l_path varchar2(150) ;
begin
   l_max_adjustment_id := -1;
   l_path := g_path||'create_txn_headers';

   -- for NOCOPY.
   l_fp_reval_params := fp_reval_params;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin create_txn_headers');
   /* create one transaction header id for each Reval engine pass */
   /* this should obsolete the previous one... */

    if   fp_reval_params.reval_control.revaluation_mode not in ( 'P','L')
     then
      return true;
    end if;

    if  fp_reval_params.reval_control.transaction_type_code in ( 'ADDITION','RECLASS') then
       l_reval_type_flag := 'C';
    else
       l_reval_type_flag := fp_reval_params.reval_asset_rules.revaluation_type;
    end if;

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+Getting the latest adjustment id');
    begin
        select adjustment_id
        into  l_max_adjustment_id
        from  igi_iac_transaction_headers
        where adjustment_id_out is null
        and   book_type_code = fp_reval_params.reval_asset_params.book_type_code
        and   asset_id       = fp_reval_params.reval_asset_params.asset_id
        ;
    exception when others then
       l_max_adjustment_id := -1;
    end;

   IGI_IAC_TRANS_HEADERS_PKG.insert_row (
        x_rowid                            => l_rowid   ,
        x_adjustment_id                    => l_adjustment_id,
        x_transaction_header_id            => NULL,
        x_adjustment_id_out                => null,
        x_transaction_type_code            => fp_reval_params.reval_control.transaction_type_code,
        x_transaction_date_entered         => sysdate,
        x_mass_refrence_id                 => fp_reval_params.reval_asset_params.revaluation_id,
        x_transaction_sub_type             => fp_reval_params.reval_control.transaction_sub_type,
        x_book_type_code                   => fp_reval_params.reval_asset_params.book_type_code,
        x_asset_id                         => fp_reval_params.reval_asset_params.asset_id,
        x_category_id                      => fp_reval_params.reval_asset_params.category_id,
        x_adj_deprn_start_date             => fp_reval_params.fa_asset_info.deprn_start_date,
        x_revaluation_type_flag            => l_reval_type_flag ,
        x_adjustment_status                => fp_reval_params.reval_control.adjustment_status,
        x_period_counter                   => fp_reval_params.reval_asset_params.period_counter,
        x_mode                             => 'R',
	x_event_id                         => Null
        );

   IF l_max_adjustment_id <> -1 then
      IGI_IAC_TRANS_HEADERS_PKG.update_row (
        x_prev_adjustment_id                =>  l_max_adjustment_id,
        x_adjustment_id                     => l_adjustment_id,
        x_mode                              => 'R'
        );
   END IF;

  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+adjustment id '|| l_adjustment_id);

  if fp_second_set then
     fp_reval_params.reval_asset_params.second_set_adjustment_id := l_adjustment_id;
  else
     fp_reval_params.reval_asset_params.first_set_adjustment_id  := l_adjustment_id;
  end if;

  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end create_txn_headers');

  return true;

exception when others then
   fp_reval_params := l_fp_reval_params;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end create_txn_headers');
   return false;
end;


procedure create_balance (pp_period_counter      in number
                         , pp_reval_output_asset in IGI_IAC_TYPES.iac_reval_output_asset
                         ) is

       l_exists boolean;
       l_rowid  varchar2(40);
       l_path varchar2(150);
begin
       l_exists := false;
       l_rowid  := null;
       l_path  := g_path||'create_balance';

     for l_ex in c_exists (cp_period_counter => pp_period_counter
                          , cp_asset_id      => pp_reval_output_asset.asset_id
                          , cp_book_type_code => pp_reval_output_asset.book_type_code
                          ) loop
        l_exists := true;
     end loop;
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+balance for period counter '|| pp_period_counter);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+ ASSET BALANCES');
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_asset_id                  =>'|| pp_reval_output_asset.asset_id);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_book_type_code            => '|| pp_reval_output_asset.book_type_code);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_period_counter            => '||pp_period_counter);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_net_book_value            => '||pp_reval_output_asset.net_book_value);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_adjusted_cost             => '||pp_reval_output_asset.adjusted_cost);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_operating_acct            =>'|| pp_reval_output_asset.operating_acct);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_reval_reserve             => '||pp_reval_output_asset.reval_reserve);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_deprn_amount              => '||pp_reval_output_asset.deprn_amount);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_deprn_reserve             => '||pp_reval_output_asset.deprn_reserve);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_backlog_deprn_reserve     => '||pp_reval_output_asset.backlog_deprn_reserve);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_general_fund              => '||pp_reval_output_asset.general_fund);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_last_reval_date           => '||pp_reval_output_asset.last_reval_date);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_current_reval_factor      => '||pp_reval_output_asset.current_reval_factor);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+       x_cumulative_reval_factor   => '||pp_reval_output_asset.cumulative_reval_factor);

     if l_exists then
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+balance record already exists, so update');
         IGI_IAC_ASSET_BALANCES_PKG.update_row (
            x_asset_id                  => pp_reval_output_asset.asset_id,
            x_book_type_code            => pp_reval_output_asset.book_type_code,
            x_period_counter            => pp_period_counter,
            x_net_book_value            => pp_reval_output_asset.net_book_value,
            x_adjusted_cost             => pp_reval_output_asset.adjusted_cost,
            x_operating_acct            => pp_reval_output_asset.operating_acct,
            x_reval_reserve             => pp_reval_output_asset.reval_reserve,
            x_deprn_amount              => pp_reval_output_asset.deprn_amount,
            x_deprn_reserve             => pp_reval_output_asset.deprn_reserve,
            x_backlog_deprn_reserve     => pp_reval_output_asset.backlog_deprn_reserve,
            x_general_fund              => pp_reval_output_asset.general_fund,
            x_last_reval_date           => pp_reval_output_asset.last_reval_date,
            x_current_reval_factor      => pp_reval_output_asset.current_reval_factor,
            x_cumulative_reval_factor   => pp_reval_output_asset.cumulative_reval_factor,
            x_mode                      => 'R'
            );
       else
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+balance record does not exist, so insert');
          IGI_IAC_ASSET_BALANCES_PKG.insert_row (
            x_rowid                     => l_rowid,
            x_asset_id                  => pp_reval_output_asset.asset_id,
            x_book_type_code            => pp_reval_output_asset.book_type_code,
            x_period_counter            => pp_period_counter,
            x_net_book_value            => pp_reval_output_asset.net_book_value,
            x_adjusted_cost             => pp_reval_output_asset.adjusted_cost,
            x_operating_acct            => pp_reval_output_asset.operating_acct,
            x_reval_reserve             => pp_reval_output_asset.reval_reserve,
            x_deprn_amount              => pp_reval_output_asset.deprn_amount,
            x_deprn_reserve             => pp_reval_output_asset.deprn_reserve,
            x_backlog_deprn_reserve     => pp_reval_output_asset.backlog_deprn_reserve,
            x_general_fund              => pp_reval_output_asset.general_fund,
            x_last_reval_date           => pp_reval_output_asset.last_reval_date,
            x_current_reval_factor      => pp_reval_output_asset.current_reval_factor,
            x_cumulative_reval_factor   => pp_reval_output_asset.cumulative_reval_factor,
            x_mode                      => 'R'
            );
       end if;
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+completed  entry of balances');
 end;

function copy_balances
    ( fp_asset_id in  number
    , fp_book_type_code in varchar2
    , fp_period_counter in number
    , fp_target_period_counter in number
     )
return boolean is
  cursor c_bal is
    select *
    from  igi_iac_asset_balances
    where  asset_id       = fp_Asset_id
     and   book_type_code = fp_book_type_code
     and   period_counter = fp_period_counter
     ;
   l_path varchar2(150);
begin
   l_path := g_path||'copy_balances';
  for l_bal in c_bal loop
       create_balance (pp_period_counter      => fp_target_period_counter
                      ,pp_reval_output_asset => l_bal
                      );

  end loop;
  return true;
end;

function create_asset_balances
    ( fp_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
    , fp_second_set   in boolean  )
return boolean is
  l_rowid rowid;
  l_processed boolean;

  l_prev_cumm_rate number;
  l_curr_cumm_rate number;
  l_period_counter number;
  l_fp_reval_params igi_iac_types.iac_reval_params;

  l_path varchar2(150);
begin

  l_processed := false;
  l_prev_cumm_rate := 1;
  l_curr_cumm_rate := 1;
  l_period_counter := fp_Reval_params.reval_output_asset.period_counter;
  l_path  := g_path||'create_asset_balances';

   -- for NOCOPY
   l_fp_reval_params := fp_reval_params;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin create_asset_balances');
   if   fp_reval_params.reval_control.revaluation_mode not in ('L','R') then
      return true;
   end if;

    create_balance (pp_period_counter      => l_period_counter
                   ,pp_reval_output_asset => fp_reval_params.reval_output_asset
                   );

   create_balance (pp_period_counter      => l_period_counter +1
                   ,pp_reval_output_asset => fp_reval_params.reval_output_asset
                   );

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end create_asset_balances');

   return true;

EXCEPTION
   WHEN OTHERS THEN
   fp_reval_params := l_fp_reval_params;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return FALSE;
end;


function get_prev_det_balances (fp_adjustment_id in number
                    , fp_distribution_id in number
                    , fp_asset_id        in number
                    , fp_book_type_code  in varchar2
                    , fp_period_counter  in number
                    , fp_transaction_sub_type in varchar2
                    , fp_det_balances out NOCOPY igi_iac_det_balances%ROWTYPE
                    )
return boolean is

    l_fp_det_balances igi_iac_det_balances%ROWTYPE;
    l_success boolean ;
    transaction_sub_type igi_iac_transaction_headers.TRANSACTION_SUB_TYPE%TYPE;
    period_counter number;

    cursor c_prev_bal (period_counter number) is
    select bal.*
    from  igi_iac_det_balances bal
    where bal.adjustment_id    = fp_adjustment_id
      and bal.distribution_id  = fp_distribution_id
      and bal.asset_id         = fp_asset_id
      and bal.period_counter  <= period_counter
      and bal.book_type_code   = fp_book_type_code
    ;

    cursor c_reval ( p_book_type_code varchar2, p_period_counter number, p_asset_id number) is
    SELECT 1
    FROM dual
    WHERE EXISTS(
    SELECT 1
    FROM igi_iac_transaction_headers th,   igi_iac_det_balances db
    WHERE th.transaction_sub_type = 'IMPLEMENTATION'
     AND th.adjustment_id = db.adjustment_id
     AND db.book_type_code = p_book_type_code
     AND db.period_counter = p_period_counter
     AND db.book_type_code = th.book_type_code
     AND db.asset_id = th.asset_id
     AND db.asset_id = p_asset_id)
	;

    l_reval_exists c_reval%rowtype;

    /*
    -- Need a function to check whether the distribution exists
    */

    l_path varchar2(150);

    function AlreadyExists ( p_distribution_id in number
                           , p_asset_id        in number
                           , p_book_type_code  in varchar2
                           )
    return boolean is
       cursor c_exists is
         select distinct 'x'
         from  igi_iac_det_Balances
         where  asset_id        = p_asset_id
           and  distribution_id = p_distribution_id
           and  book_type_code  = p_book_type_code
           ;
       l_status boolean;

       l_path varchar2(150);
    begin
       l_status := false;
       l_path := g_path||'AlreadyExists';

       for l_exists in c_exists loop
          l_status := true;
       end loop;
       return l_status;
    exception when others then
       igi_iac_debug_pkg.debug_unexpected_msg(l_path);
       return false;
    end;
begin
    l_success := false;
    l_path := g_path||'get_prev_det_balances';
   -- for NOCOPY.
   l_fp_det_balances := fp_det_balances;

   if (nvl(fp_adjustment_id,-1) = -1 )
            OR (NOT AlreadyExists
                           ( p_distribution_id => fp_distribution_id
                           , p_asset_id       =>  fp_asset_id
                           , p_book_type_code =>  fp_book_type_code
                           )
                )
   then
     fp_det_balances.asset_id                := fp_asset_id;
     fp_det_balances.book_type_code          := fp_book_type_code;
     fp_det_balances.period_counter          := fp_period_counter;
     fp_det_balances.adjustment_id           :=  nvl( fp_adjustment_id, -1);
     fp_det_balances.distribution_id         := fp_distribution_id;
     fp_det_balances.adjustment_cost         := 0;
     fp_det_balances.net_book_value          := 0;
     fp_det_balances.reval_reserve_cost      := 0;
     fp_det_balances.reval_reserve_backlog   := 0;
     fp_det_balances.reval_reserve_gen_fund  := 0;
     fp_det_balances.reval_reserve_net       := 0;
     fp_det_balances.operating_acct_cost     := 0;
     fp_det_balances.operating_acct_backlog  := 0;
     fp_det_balances.operating_acct_net      := 0;
     fp_det_balances.deprn_period            := 0;
     fp_det_balances.deprn_ytd               := 0;
     fp_det_balances.deprn_reserve           := 0;
     fp_det_balances.deprn_reserve_backlog   := 0;

     l_success := true;
  else
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+adjustment_id   .. ' ||fp_adjustment_id);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+distribution_id .. ' ||fp_distribution_id);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+period counter.... ' ||fp_period_counter);

     period_counter := fp_period_counter;

     select TRANSACTION_SUB_TYPE
     into transaction_sub_type
     from igi_iac_transaction_headers
     where ADJUSTMENT_ID = fp_adjustment_id;

     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Checking if the previous adjustment was Implementation');

     IF transaction_sub_type = 'IMPLEMENTATION'  THEN
         period_counter := period_counter + 1;
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Incrementing Period Counter to allow revaluation after Implementation');
     END IF;

     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Checking if Transaction ttype is Professional');

     IF fp_transaction_sub_type <> 'PROFESSIONAL' THEN
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Transaction type is not Professional');
         OPEN c_reval (fp_book_type_code, period_counter, fp_asset_id);
	 FETCH c_reval INTO l_reval_exists;
	 IF c_reval%FOUND THEN
	       CLOSE c_reval;
	       RETURN l_success;
	 END IF;
	 CLOSE c_reval;
     END IF;

     for l_prev in c_prev_bal (period_counter) loop
        fp_det_balances := l_prev;
        fp_det_balances.period_counter := fp_period_counter;
        l_success := true;
     end loop;
  end if;
  return l_success;

exception when others then
  fp_det_balances := l_fp_det_balances;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return false;
end;

procedure round_det_balances  ( fp_det_balances in out NOCOPY IGI_IAC_TYPES.iac_det_balances )
is
   l_book_type_code igi_iac_det_balances.book_type_code%TYPE;
   l_fp_det_balances igi_iac_types.iac_det_balances;
   l_path varchar2(150);

   procedure Do_Rounding ( pp_amount in out NOCOPY number ) is
   begin
      if not igi_iac_common_utils.iac_round ( x_amount => pp_amount
                                            , x_book   => l_book_type_Code
                                            )
      then
        pp_amount := round( pp_amount, 2);
      end if;
   exception when others then
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Rounding is wrong');
       pp_amount := round( pp_amount, 2);
   end;
begin
        l_book_type_code := fp_det_balances.book_type_code ;
        l_path := g_path||'round_det_balances';

        -- for NOCOPY.
        l_fp_det_balances := fp_det_balances;

        Do_rounding (fp_det_balances.adjustment_cost        );
        Do_rounding (fp_det_balances.net_book_value         );
        Do_rounding (fp_det_balances.reval_reserve_cost     );
        Do_rounding (fp_det_balances.reval_reserve_backlog  ) ;
        Do_rounding (fp_det_balances.reval_reserve_gen_fund );
        Do_rounding (fp_det_balances.reval_reserve_net      ) ;
        Do_rounding (fp_det_balances.operating_acct_cost    ) ;
        Do_rounding (fp_det_balances.operating_acct_backlog ) ;
        Do_rounding (fp_det_balances.operating_acct_net     ) ;
        Do_rounding (fp_det_balances.operating_acct_ytd     ) ;
        Do_rounding (fp_det_balances.deprn_period           );
        Do_rounding (fp_det_balances.deprn_ytd              ) ;
        Do_rounding (fp_det_balances.deprn_reserve          ) ;
        Do_rounding (fp_det_balances.deprn_reserve_backlog  ) ;
        Do_rounding (fp_det_balances.general_fund_per       ) ;
        Do_rounding (fp_det_balances.general_fund_acc       ) ;

EXCEPTION
   WHEN OTHERS THEN
    fp_det_balances := l_fp_det_balances;
    igi_iac_debug_pkg.debug_unexpected_msg(l_path);
    Raise;
end;

procedure round_fa_figures  ( fp_fa_hist  in out NOCOPY IGI_IAC_TYPES.fa_hist_asset_info
                            , fp_det_balances in IGI_IAC_TYPES.iac_det_balances )
is
   l_book_type_code igi_iac_det_balances.book_type_code%TYPE;
   l_fp_fa_hist igi_iac_types.fa_hist_asset_info;
   l_path varchar2(150);

   procedure Do_Rounding ( pp_amount in out NOCOPY number ) is
   l_path varchar2(150);
   begin
    l_path := g_path||'round_fa_figures.Do_Rounding';
      if not igi_iac_common_utils.iac_round ( x_amount => pp_amount
                                            , x_book   => l_book_type_Code
                                            )
      then
        pp_amount := round( pp_amount, 2);
      end if;
   exception when others then
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Rounding is wrong');
       pp_amount := round( pp_amount, 2);
   end;

begin
        l_book_type_code := fp_det_balances.book_type_code ;
        l_path := g_path||'round_fa_figures';

        -- for NOCOPY
        l_fp_fa_hist := fp_fa_hist;

        Do_rounding (fp_fa_hist.deprn_reserve       );
        Do_rounding (fp_fa_hist.ytd_deprn           );
        Do_rounding (fp_fa_hist.deprn_amount        );

EXCEPTION
   WHEN OTHERS THEN
    fp_fa_hist := l_fp_fa_hist;
    igi_iac_debug_pkg.debug_unexpected_msg(l_path);
    Raise;
end;

procedure verify_det_balances  ( fp_det_balances in out NOCOPY IGI_IAC_TYPES.iac_det_balances
                               , fp_prev_cum_factor  in  number
                               , fp_curr_cum_factor  in  number
                              ) is

 l_fp_det_balances igi_iac_types.iac_det_balances;
 l_path varchar2(150);
 procedure initialize ( pp_amount in out NOCOPY number ) is
   begin
        pp_amount := 0;
  end;

begin
    l_path := g_path||'verify_det_balances';
    -- for NOCOPY.
    l_fp_det_balances := fp_det_balances;

    if fp_prev_cum_factor >= 1  and fp_curr_cum_factor >= 1
    then
        fp_det_balances.operating_acct_cost     := 0;

        fp_det_balances.reval_reserve_net       := nvl(fp_det_balances.reval_reserve_cost,0)
                                                   -  nvl(fp_det_balances.reval_reserve_backlog,0)
                                                   -  nvl(fp_det_balances.reval_reserve_gen_fund,0) ;
    else
        fp_det_balances.reval_reserve_net       := 0;
        fp_det_balances.reval_reserve_cost      := 0;

        fp_det_balances.operating_acct_net      := nvl(fp_det_balances.operating_acct_cost,0)
                                                   - nvl(fp_det_balances.operating_acct_backlog,0) ;
    end if;

    fp_det_balances.net_book_value              := nvl(fp_det_balances.adjustment_cost ,0)
                                                   - nvl(fp_det_balances.deprn_reserve,0)
                                                   - nvl(fp_det_balances.deprn_reserve_backlog,0);
EXCEPTION
  WHEN OTHERS THEN
    fp_det_balances := l_fp_det_balances;
    igi_iac_debug_pkg.debug_unexpected_msg(l_path);
    Raise;
end;

procedure add_det_balances  ( fp_det_balances in out NOCOPY IGI_IAC_TYPES.iac_det_balances
                           , fp_det_delta    in     IGI_IAC_TYPES.iac_det_balances
                           )
 is
  l_fp_det_balances IGI_IAC_TYPES.iac_det_balances;
  l_path varchar2(150);
begin
        l_path := g_path||'add_det_balances';
        -- for NOCOPY
        l_fp_det_balances :=  fp_det_balances;

        fp_det_balances.cumulative_reval_factor  := fp_det_delta.cumulative_reval_factor;
        fp_det_balances.current_reval_factor     := fp_det_delta.current_reval_factor;
        fp_det_balances.adjustment_id            := fp_Det_delta.adjustment_id;
        fp_det_balances.active_flag              := fp_det_delta.active_flag;

        fp_det_balances.adjustment_cost         := nvl(fp_det_balances.adjustment_cost,0)
                                                   + nvl(fp_det_delta.adjustment_cost,0) ;
        fp_det_balances.reval_reserve_cost      := nvl(fp_det_balances.reval_reserve_cost,0)
                                                   + nvl(fp_det_delta.reval_reserve_cost,0) ;
        fp_det_balances.reval_reserve_backlog   := nvl(fp_det_balances.reval_reserve_backlog,0)
                                                   + nvl(fp_det_delta.reval_reserve_backlog,0) ;
        fp_det_balances.reval_reserve_gen_fund  := nvl(fp_det_balances.reval_reserve_gen_fund,0)
                                                   + nvl(fp_det_delta.reval_reserve_gen_fund,0) ;
        fp_det_balances.reval_reserve_net       := nvl(fp_det_balances.reval_reserve_cost,0)
                                                   -  nvl(fp_det_balances.reval_reserve_backlog,0)
                                                   -  nvl(fp_det_balances.reval_reserve_gen_fund,0) ;
        fp_det_balances.operating_acct_cost     := nvl(fp_det_balances.operating_acct_cost,0)
                                                   +   nvl(fp_det_delta.operating_acct_cost,0) ;
        fp_det_balances.operating_acct_backlog  := nvl(fp_det_balances.operating_acct_backlog,0)
                                                   +   nvl(fp_det_delta.operating_acct_backlog,0) ;
        fp_det_balances.operating_acct_net      := fp_det_balances.operating_acct_cost
                                                   - fp_det_balances.operating_acct_backlog ;
        fp_det_balances.operating_acct_ytd      := nvl(fp_det_balances.operating_acct_ytd ,0)
                                                   + fp_det_balances.operating_acct_net;
        if fp_det_balances.period_counter  =  fp_det_delta.period_counter then
           fp_det_balances.general_fund_per        := nvl(fp_det_balances.general_fund_per ,0)
                                                   + nvl(fp_det_delta.general_fund_per,0) ;
        else
           fp_det_balances.general_fund_per        := nvl(fp_det_delta.general_fund_per,0) ;
        end if;

        fp_det_balances.deprn_period            := nvl(fp_det_delta.deprn_period,0) ;
        fp_det_balances.deprn_ytd               := nvl(fp_det_balances.deprn_ytd,0);/* YTD Proration*/
        fp_det_balances.deprn_reserve           := nvl(fp_det_balances.deprn_reserve,0)
                                                   +  nvl(fp_det_delta.deprn_reserve,0) ;
        fp_det_balances.deprn_reserve_backlog   := nvl(fp_det_balances.deprn_reserve_backlog ,0)
                                                   + nvl(fp_det_delta.deprn_reserve_backlog,0) ;

        fp_det_balances.general_fund_acc        := nvl(fp_det_balances.general_fund_acc  ,0)
                                                   + nvl(fp_det_delta.general_fund_acc,0) ;
EXCEPTION WHEN OTHERS THEN
   fp_det_balances := l_fp_det_balances;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   Raise;
end;

procedure remaining_det_balances  ( fp_det_balances in out NOCOPY IGI_IAC_TYPES.iac_det_balances
                                 , fp_det_delta     in     IGI_IAC_TYPES.iac_det_balances
                                 )
is
 l_fp_det_balances IGI_IAC_TYPES.iac_det_balances;
 l_path varchar2(150);
begin
        l_path := g_path||'remaining_det_balances';
        -- for NOCOPY.
        l_fp_det_balances := fp_det_balances;

        fp_det_balances.adjustment_cost         := nvl(fp_det_balances.adjustment_cost,0)
                                                   - nvl(fp_det_delta.adjustment_cost,0) ;
        fp_det_balances.reval_reserve_cost      := nvl(fp_det_balances.reval_reserve_cost,0)
                                                   - nvl(fp_det_delta.reval_reserve_cost,0) ;
        fp_det_balances.reval_reserve_backlog   := nvl(fp_det_balances.reval_reserve_backlog,0)
                                                   - nvl(fp_det_delta.reval_reserve_backlog,0) ;
        fp_det_balances.reval_reserve_gen_fund  := nvl(fp_det_balances.reval_reserve_gen_fund,0)
                                                   - nvl(fp_det_delta.reval_reserve_gen_fund,0) ;
        fp_det_balances.reval_reserve_net       := nvl(fp_det_balances.reval_reserve_cost,0)
                                                   -  nvl(fp_det_balances.reval_reserve_backlog,0)
                                                   -  nvl(fp_det_balances.reval_reserve_gen_fund,0) ;
        fp_det_balances.operating_acct_cost     := nvl(fp_det_balances.operating_acct_cost,0)
                                                   -   nvl(fp_det_delta.operating_acct_cost,0) ;
        fp_det_balances.operating_acct_backlog  := nvl(fp_det_balances.operating_acct_backlog,0)
                                                   -  nvl(fp_det_delta.operating_acct_backlog,0) ;
        fp_det_balances.operating_acct_net      := fp_det_balances.operating_acct_cost
                                                   - fp_det_balances.operating_acct_backlog ;
        fp_det_balances.operating_acct_ytd      := nvl(fp_det_balances.operating_acct_ytd ,0)
                                                   - fp_det_delta.operating_acct_ytd;
        fp_det_balances.deprn_period            := nvl(fp_det_balances.deprn_period,0)
                                                   - nvl(fp_det_delta.deprn_period,0) ;
        fp_det_balances.deprn_ytd               := nvl(fp_det_balances.deprn_ytd  ,0)
                                                   -  nvl(fp_det_delta.deprn_ytd,0) ;
        fp_det_balances.deprn_reserve           := nvl(fp_det_balances.deprn_reserve  ,0)
                                                   -  nvl(fp_det_delta.deprn_reserve,0) ;
        fp_det_balances.deprn_reserve_backlog   := nvl(fp_det_balances.deprn_reserve_backlog ,0)
                                                   - nvl(fp_det_delta.deprn_reserve_backlog,0) ;
        fp_det_balances.general_fund_per        := nvl(fp_det_balances.general_fund_per ,0)
                                                   - nvl(fp_det_delta.general_fund_per,0) ;
        fp_det_balances.general_fund_acc        := nvl(fp_det_balances.general_fund_acc  ,0)
                                                   - nvl(fp_det_delta.general_fund_acc,0) ;
EXCEPTION WHEN OTHERS THEN
   fp_det_balances := l_fp_det_balances;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   Raise;
end;

procedure display_det_balances ( fp_det_balances in out NOCOPY IGI_IAC_TYPES.iac_det_balances )
is
 l_path varchar2(150);
begin
        l_path := g_path||'display_det_balances';
        --return;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Adjustment Cost '||fp_det_balances.adjustment_cost);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'NBV             '||fp_det_balances.net_book_value);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Rsv  Cost '||fp_det_balances.reval_reserve_cost);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Rsv  Blog '||fp_det_balances.reval_reserve_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Rsv  Gfun '||fp_det_balances.reval_reserve_gen_fund);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Reval Rsv  Net  '||fp_det_balances.reval_reserve_net);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Oper  Acc  cost '||fp_det_balances.operating_acct_cost);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Oper  Acc  Blog '||fp_det_balances.operating_acct_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Oper  Acc  NEt  '||fp_det_balances.operating_acct_net);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Oper  Acc  YTD  '||fp_det_balances.operating_acct_ytd);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn period    '||fp_det_balances.deprn_period);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn YTD       '||fp_det_balances.deprn_ytd);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Rsv       '||fp_det_balances.deprn_reserve);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Deprn Rsv   Blog'||fp_det_balances.deprn_reserve_backlog);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Gen Fund period '||fp_det_balances.general_fund_per);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Gen Fund Acc    '||fp_det_balances.general_fund_acc);
        return;
end;


function create_det_balances_private ( fp_det_balances in IGI_IAC_TYPES.iac_det_balances )
return boolean is
  l_det_balances IGI_IAC_TYPES.iac_det_balances;
  l_rowid varchar2(300);
  l_path varchar2(150);
begin
    l_det_balances := fp_det_balances;
    l_path := g_path||'create_det_balances_private';

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+DET BALANCES');
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_adjustment_id            => '|| l_det_balances.adjustment_id);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_asset_id                 =>'|| l_det_balances.asset_id);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_distribution_id          => '||l_det_balances.distribution_id);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_book_type_code           => '||l_det_balances.book_type_code);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_period_counter           => '||l_det_balances.period_counter);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_adjustment_cost          => '||l_det_balances.adjustment_cost);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_net_book_value           => '||l_det_balances.net_book_value);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_reval_reserve_cost       => '||l_det_balances.reval_reserve_cost);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_reval_reserve_backlog    => '||l_det_balances.reval_reserve_backlog);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_reval_reserve_gen_fund   => '||l_det_balances.reval_reserve_gen_fund);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_reval_reserve_net        => '||l_det_balances.reval_reserve_net);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_operating_acct_cost      => '||l_det_balances.operating_acct_cost);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_operating_acct_backlog   => '||l_det_balances.operating_acct_backlog);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_operating_acct_net       => '||l_det_balances.operating_acct_net);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_operating_acct_ytd       => '||l_det_balances.operating_acct_ytd);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_deprn_period             => '||l_det_balances.deprn_period);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_deprn_ytd                => '||l_det_balances.deprn_ytd);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_deprn_reserve            => '||l_det_balances.deprn_reserve);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_deprn_reserve_backlog    => '||l_det_balances.deprn_reserve_backlog);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_general_fund_per         => '||l_det_balances.general_fund_per);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_general_fund_acc         => '||l_det_balances.general_fund_acc);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_last_reval_date          => '||l_det_balances.last_reval_date);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_current_reval_factor     => '||l_det_balances.current_reval_factor);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_cumulative_reval_factor  => '||l_det_balances.cumulative_reval_factor);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_active_flag              => '||l_det_balances.active_flag);



   IGI_IAC_DET_BALANCES_PKG.insert_row (
        x_rowid                    => l_rowid,
        x_adjustment_id            => l_det_balances.adjustment_id,
        x_asset_id                 => l_det_balances.asset_id,
        x_distribution_id          => l_det_balances.distribution_id,
        x_book_type_code           => l_det_balances.book_type_code,
        x_period_counter           => l_det_balances.period_counter,
        x_adjustment_cost          => l_det_balances.adjustment_cost,
        x_net_book_value           => l_det_balances.net_book_value,
        x_reval_reserve_cost       => l_det_balances.reval_reserve_cost,
        x_reval_reserve_backlog    => l_det_balances.reval_reserve_backlog,
        x_reval_reserve_gen_fund   => l_det_balances.reval_reserve_gen_fund,
        x_reval_reserve_net        => l_det_balances.reval_reserve_net,
        x_operating_acct_cost      => l_det_balances.operating_acct_cost,
        x_operating_acct_backlog   => l_det_balances.operating_acct_backlog,
        x_operating_acct_net       => l_det_balances.operating_acct_net,
        x_operating_acct_ytd       => 0,     -- l_det_balances.operating_acct_ytd,
        x_deprn_period             => l_det_balances.deprn_period,
        x_deprn_ytd                => l_det_balances.deprn_ytd,
        x_deprn_reserve            => l_det_balances.deprn_reserve,
        x_deprn_reserve_backlog    => l_det_balances.deprn_reserve_backlog,
        x_general_fund_per         => l_det_balances.general_fund_per,
        x_general_fund_acc         => l_det_balances.general_fund_acc,
        x_last_reval_date          => l_det_balances.last_reval_date,
        x_current_reval_factor     => l_det_balances.current_reval_factor,
        x_cumulative_reval_factor  => l_det_balances.cumulative_reval_factor,
        x_active_flag              => l_det_balances.active_flag,
        x_mode                     => 'R' );

        return true;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function create_fa_figures_private ( fp_det_balances in IGI_IAC_TYPES.iac_det_balances
                                   , fp_fa_balances  in IGI_IAC_TYPES.fa_hist_asset_info
                                    )
return boolean is
  l_det_balances IGI_IAC_TYPES.iac_det_balances;
  l_fa_balances  IGI_IAC_TYPES.fa_hist_asset_info;
  l_rowid varchar2(300);
  l_path varchar2(150);
begin
    l_det_balances := fp_det_balances;
    l_fa_balances  := fp_fa_balances;
    l_path := g_path||'create_fa_figures_private';

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+FA FIGURES');
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_adjustment_id            => '|| l_det_balances.adjustment_id);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_asset_id                 =>'|| l_det_balances.asset_id);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_distribution_id          => '||l_det_balances.distribution_id);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_book_type_code           => '||l_det_balances.book_type_code);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_period_counter           => '||l_det_balances.period_counter);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_deprn_period             => '||l_fa_balances.deprn_amount);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_deprn_reserve            => '||l_fa_balances.deprn_reserve);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_ytd_deprn                => '||l_fa_balances.ytd_deprn);
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'     x_active_flag              => '||l_det_balances.active_flag);

   IGI_IAC_FA_DEPRN_PKG.insert_row (
        x_rowid                    => l_rowid,
        x_adjustment_id            => l_det_balances.adjustment_id,
        x_asset_id                 => l_det_balances.asset_id,
        x_distribution_id          => l_det_balances.distribution_id,
        x_book_type_code           => l_det_balances.book_type_code,
        x_period_counter           => l_det_balances.period_counter,
        x_deprn_period             => l_fa_balances.deprn_amount,
        x_deprn_ytd                => l_fa_balances.ytd_deprn,
        x_deprn_reserve            => l_fa_balances.deprn_reserve,
        x_active_flag              => l_det_balances.active_flag,
        x_mode                     => 'R' );

        return true;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

FUNCTION forward_inactive_det_balances(p_asset_id        igi_iac_det_balances.asset_id%TYPE,
                              p_book_type_code     igi_iac_det_balances.book_type_code%TYPE,
                              p_adjustment_id      igi_iac_det_balances.adjustment_id%TYPE,
                              p_period_counter     igi_iac_det_balances.period_counter%TYPE,
                              p_iac_inactive_dists_ytd IN OUT NOCOPY igi_iac_det_balances.deprn_ytd%TYPE,
                              p_fa_inactive_dists_ytd  IN OUT NOCOPY igi_iac_fa_deprn.deprn_ytd%TYPE)
RETURN BOOLEAN IS

    CURSOR c_get_prev_adjustment IS
    SELECT max(adjustment_id)
    FROM igi_iac_transaction_headers
    WHERE book_type_code = p_book_type_code
    AND asset_id = p_asset_id
    AND adjustment_id < p_adjustment_id
    AND adjustment_status NOT IN ('PREVIEW','OBSOLETE');

    -- cursor to retrieve the inactive distributions that will be rolled forward
    CURSOR c_get_iac_inactive_dists(cp_adjustment_id igi_iac_det_balances.adjustment_id%TYPE) IS
    SELECT iidb.adjustment_id,
          iidb.distribution_id,
          iidb.adjustment_cost,
          iidb.net_book_value,
          iidb.reval_reserve_cost,
          iidb.reval_reserve_backlog,
          iidb.reval_reserve_gen_fund,
          iidb.reval_reserve_net,
          iidb.operating_acct_cost,
          iidb.operating_acct_backlog,
          iidb.operating_acct_net,
          iidb.operating_acct_ytd,
          iidb.deprn_period,
          iidb.deprn_ytd,
          iidb.deprn_reserve,
          iidb.deprn_reserve_backlog,
          iidb.general_fund_per,
          iidb.general_fund_acc,
          iidb.active_flag,
          iidb.last_reval_date,
          iidb.current_reval_factor,
          iidb.cumulative_reval_factor
    FROM   igi_iac_det_balances iidb
    WHERE  iidb.adjustment_id = cp_adjustment_id
    AND    iidb.asset_id = p_asset_id
    AND    iidb.book_type_code = p_book_type_code
    AND    nvl(iidb.active_flag,'Y') = 'N';

    -- Cursor to fetch depreciation balances from
    -- igi_iac_fa_deprn for inactive distributions
    CURSOR c_get_fa_inactive_dists(cp_adjustment_id   igi_iac_fa_deprn.adjustment_id%TYPE)
    IS
    SELECT iifd.distribution_id,
            iifd.deprn_period,
            iifd.deprn_ytd,
            iifd.deprn_reserve,
            iifd.active_flag
    FROM   igi_iac_fa_deprn iifd
    WHERE  iifd.adjustment_id = cp_adjustment_id
    AND    iifd.book_type_code = p_book_type_code
    AND    iifd.asset_id = p_asset_id
    AND    nvl(iifd.active_flag,'Y') = 'N';

    -- local variables
    l_prev_adjustment_id           igi_iac_transaction_headers.adjustment_id%TYPE;
    l_rowid varchar2(40);
    l_path varchar2(150);
    l_iac_inactive_dists_ytd number;
    l_fa_inactive_dists_ytd number;
BEGIN
    l_path := g_path||'forward_inactive_det_balances';
    l_prev_adjustment_id := NULL;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+Start Processing inactive distributions');
    l_iac_inactive_dists_ytd := 0;
    l_fa_inactive_dists_ytd := 0;

    OPEN c_get_prev_adjustment;
    FETCH c_get_prev_adjustment INTO l_prev_adjustment_id;
    CLOSE c_get_prev_adjustment;

    IF l_prev_adjustment_id IS NULL THEN
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+No inactive distributions to carry forward');
        RETURN TRUE;
    END IF;

    FOR l_iac_inactive_dist IN c_get_iac_inactive_dists(l_prev_adjustment_id)  LOOP
    -- insert into igi_iac_det_balances with reinstatement adjustment_id
        l_rowid := NULL;
        IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                    x_rowid                    => l_rowid,
                    x_adjustment_id            => p_adjustment_id,
                    x_asset_id                 => p_asset_id,
                    x_book_type_code           => p_book_type_code,
                    x_distribution_id          => l_iac_inactive_dist.distribution_id,
                    x_period_counter           => p_period_counter,
                    x_adjustment_cost          => l_iac_inactive_dist.adjustment_cost,
                    x_net_book_value           => l_iac_inactive_dist.net_book_value,
                    x_reval_reserve_cost       => l_iac_inactive_dist.reval_reserve_cost,
                    x_reval_reserve_backlog    => l_iac_inactive_dist.reval_reserve_backlog,
                    x_reval_reserve_gen_fund   => l_iac_inactive_dist.reval_reserve_gen_fund,
                    x_reval_reserve_net        => l_iac_inactive_dist.reval_reserve_net,
                    x_operating_acct_cost      => l_iac_inactive_dist.operating_acct_cost,
                    x_operating_acct_backlog   => l_iac_inactive_dist.operating_acct_backlog,
                    x_operating_acct_net       => l_iac_inactive_dist.operating_acct_net,
                    x_operating_acct_ytd       => l_iac_inactive_dist.operating_acct_ytd,
                    x_deprn_period             => l_iac_inactive_dist.deprn_period,
                    x_deprn_ytd                => l_iac_inactive_dist.deprn_ytd,
                    x_deprn_reserve            => l_iac_inactive_dist.deprn_reserve,
                    x_deprn_reserve_backlog    => l_iac_inactive_dist.deprn_reserve_backlog,
                    x_general_fund_per         => l_iac_inactive_dist.general_fund_per,
                    x_general_fund_acc         => l_iac_inactive_dist.general_fund_acc,
                    x_last_reval_date          => l_iac_inactive_dist.last_reval_date,
                    x_current_reval_factor     => l_iac_inactive_dist.current_reval_factor,
                    x_cumulative_reval_factor  => l_iac_inactive_dist.cumulative_reval_factor,
                    x_active_flag              => l_iac_inactive_dist.active_flag,
                    x_mode                     => 'R' );
        l_iac_inactive_dists_ytd := l_iac_inactive_dists_ytd + l_iac_inactive_dist.deprn_ytd;
    END LOOP;

    FOR l_fa_inactive_dist IN c_get_fa_inactive_dists(l_prev_adjustment_id)  LOOP
        -- insert into igi_iac_fa_deprn with the new adjustment_id
        l_rowid := NULL;
        IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => p_book_type_code,
               x_asset_id             => p_asset_id,
               x_period_counter       => p_period_counter,
               x_adjustment_id        => p_adjustment_id,
               x_distribution_id      => l_fa_inactive_dist.distribution_id,
               x_deprn_period         => l_fa_inactive_dist.deprn_period,
               x_deprn_ytd            => l_fa_inactive_dist.deprn_ytd,
               x_deprn_reserve        => l_fa_inactive_dist.deprn_reserve,
               x_active_flag          => l_fa_inactive_dist.active_flag,
               x_mode                 => 'R' );
        l_fa_inactive_dists_ytd := l_fa_inactive_dists_ytd + l_fa_inactive_dist.deprn_ytd;
    END LOOP;

    p_iac_inactive_dists_ytd := l_iac_inactive_dists_ytd;
    p_fa_inactive_dists_ytd := l_fa_inactive_dists_ytd;

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+End Processing inactive distributions');
    return true;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
END forward_inactive_det_balances;

FUNCTION Create_Inactive_Det_Balances(p_asset_id        igi_iac_det_balances.asset_id%TYPE,
                              p_book_type_code     igi_iac_det_balances.book_type_code%TYPE,
                              p_adjustment_id      igi_iac_det_balances.adjustment_id%TYPE,
                              p_period_counter     igi_iac_det_balances.period_counter%TYPE,
                              p_asset_iac_ytd  IN OUT NOCOPY igi_iac_det_balances.deprn_ytd%TYPE,
                              p_asset_fa_ytd IN OUT NOCOPY igi_iac_fa_deprn.deprn_ytd%TYPE,
                              p_YTD_prorate_dists_tab igi_iac_types.prorate_dists_tab,
                              p_YTD_prorate_dists_idx binary_integer)
RETURN BOOLEAN IS

    l_rowid varchar2(40);
    l_path varchar2(150);
    l_YTD_prorate_dists_tab igi_iac_types.prorate_dists_tab;
    l_YTD_prorate_dists_idx binary_integer;
    idx_YTD            binary_integer;
    l_dist_iac_ytd     number;
    l_dist_fa_ytd      number;

BEGIN
    l_path := g_path||'create_inactive_det_balances';
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+Start Processing inactive distributions');
    l_YTD_prorate_dists_tab := p_YTD_prorate_dists_tab;

    idx_YTD := l_YTD_prorate_dists_tab.FIRST;
    WHILE idx_YTD <= l_YTD_prorate_dists_tab.LAST LOOP
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Distribution Id:'||l_YTD_prorate_dists_tab(idx_YTD).distribution_id);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Active_flag:'||l_YTD_prorate_dists_tab(idx_YTD).active_flag);

        IF l_YTD_prorate_dists_tab(idx_YTD).active_flag = 'N' THEN
            l_dist_iac_ytd := l_YTD_prorate_dists_tab(idx_YTD).ytd_prorate_factor * p_asset_iac_ytd;
            do_round(l_dist_iac_ytd,p_book_type_code);
            l_dist_fa_ytd := l_YTD_prorate_dists_tab(idx_YTD).ytd_prorate_factor * p_asset_fa_ytd;
			do_round(l_dist_fa_ytd,p_book_type_code);

            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserting into igi_iac_det_balances');
            l_rowid := NULL;
            IGI_IAC_DET_BALANCES_PKG.Insert_Row(
                    x_rowid                    => l_rowid,
                    x_adjustment_id            => p_adjustment_id,
                    x_asset_id                 => p_asset_id,
                    x_book_type_code           => p_book_type_code,
                    x_distribution_id          => l_YTD_prorate_dists_tab(idx_YTD).distribution_id,
                    x_period_counter           => p_period_counter,
                    x_adjustment_cost          => 0,
                    x_net_book_value           => 0,
                    x_reval_reserve_cost       => 0,
                    x_reval_reserve_backlog    => 0,
                    x_reval_reserve_gen_fund   => 0,
                    x_reval_reserve_net        => 0,
                    x_operating_acct_cost      => 0,
                    x_operating_acct_backlog   => 0,
                    x_operating_acct_net       => 0,
                    x_operating_acct_ytd       => 0,
                    x_deprn_period             => 0,
                    x_deprn_ytd                => l_dist_iac_ytd,
                    x_deprn_reserve            => 0,
                    x_deprn_reserve_backlog    => 0,
                    x_general_fund_per         => 0,
                    x_general_fund_acc         => 0,
                    x_last_reval_date          => null,
                    x_current_reval_factor     => 0,
                    x_cumulative_reval_factor  => 0,
                    x_active_flag              => 'N',
                    x_mode                     => 'R' );

            -- insert into igi_iac_fa_deprn with the new adjustment_id
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Inserting into igi_iac_fa_deprn');
            l_rowid := NULL;
            IGI_IAC_FA_DEPRN_PKG.Insert_Row(
               x_rowid                => l_rowid,
               x_book_type_code       => p_book_type_code,
               x_asset_id             => p_asset_id,
               x_period_counter       => p_period_counter,
               x_adjustment_id        => p_adjustment_id,
               x_distribution_id      => l_YTD_prorate_dists_tab(idx_YTD).distribution_id,
               x_deprn_period         => 0,
               x_deprn_ytd            => l_dist_fa_ytd,
               x_deprn_reserve        => 0,
               x_active_flag          => 'N',
               x_mode                 => 'R' );

        END IF;
        idx_ytd := l_YTD_prorate_dists_tab.Next(idx_ytd);
    END LOOP;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+End Processing inactive distributions');
    RETURN TRUE;

EXCEPTION WHEN others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
END Create_Inactive_Det_Balances;

function create_det_balances    ( fp_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
                                , fp_second_set   in boolean
                                 )
return boolean is

    cursor c_get_dist_deprn(cp_distribution_id number) is
    select (nvl(deprn_amount,0) - nvl(deprn_adjustment_amount,0)) deprn_amount,
            deprn_reserve
    from fa_deprn_detail
    where book_type_code = fp_reval_params.reval_asset_params.book_type_code
    and asset_id = fp_reval_params.reval_asset_params.asset_id
    and distribution_id = cp_distribution_id
    and period_counter = (select max(period_counter)
                            from fa_deprn_summary
                            where book_type_code = fp_reval_params.reval_asset_params.book_type_code
                            and asset_id = fp_reval_params.reval_asset_params.asset_id);

    cursor c_get_dist_ytd(cp_distribution_id fa_deprn_detail.distribution_id%TYPE) is
    select sum(nvl(fdd.deprn_amount,0)-nvl(fdd.deprn_adjustment_amount,0)) deprn_YTD
    from fa_deprn_detail fdd
    where fdd.book_type_code = fp_reval_params.reval_asset_params.book_type_code
    and fdd.asset_id = fp_reval_params.reval_asset_params.asset_id
    and fdd.distribution_id = cp_distribution_id
    and fdd.period_counter in (select period_counter from fa_deprn_periods
                                where book_type_code = fp_reval_params.reval_asset_params.book_type_code
                                and fiscal_year = (select decode(period_num,1,fiscal_year-1,fiscal_year)
                                                    from fa_deprn_periods
                                                    where period_close_date is NULL
                                                    and book_type_code = fp_reval_params.reval_asset_params.book_type_code))
    group by fdd.asset_id,fdd.distribution_id;

    cursor c_get_prev_fa_deprn(cp_adjustment_id igi_iac_fa_deprn.adjustment_id%TYPE,
                                cp_distribution_id igi_iac_fa_deprn.distribution_id%TYPE) is
    select iifd.deprn_period, iifd.deprn_ytd, iifd.deprn_reserve
    from igi_iac_fa_deprn iifd
    where iifd.asset_id = fp_reval_params.reval_asset_params.asset_id
    and iifd.book_type_code = fp_reval_params.reval_asset_params.book_type_code
    and iifd.adjustment_id = cp_adjustment_id
    and iifd.distribution_id = cp_distribution_id;

    l_rowid varchar2(40);
    l_adjustment_id igi_iac_transaction_headers.adjustment_id%TYPE;
    l_reval_factor_curr number;
    l_reval_factor_cumm number;
    l_prev_factor_cumm  number;
    l_prorate_dists_tab igi_iac_types.prorate_dists_tab;
    l_prorate_dists_idx binary_integer;

    l_processed    boolean;
    idx            binary_integer;
    l_prev_adj_id  number;

    l_operatg_blog     number;
    l_reserve_blog     number;
    l_deprn_blog       number;
    l_reserve_cost     number;
    l_operatg_ytd      number;
    l_operatg_ytd_bal  number;
    l_operatg_net      number;
    l_operatg_cost     number;
    l_deprn_ytd        number;
    l_old_deprn_ytd    number;
    l_old_gen_fund     number;

    l_db                IGI_IAC_TYPES.iac_det_balances;
    l_db_fa            IGI_IAC_TYPES.fa_hist_asset_info;

    l_prev_db           IGI_IAC_TYPES.iac_det_balances;
    l_remaining         IGI_IAC_TYPES.iac_det_balances;
    l_remaining_fa      IGI_IAC_TYPES.fa_hist_asset_info;
    l_total             IGI_IAC_TYPES.iac_det_balances;
    l_total_fa          IGI_IAC_TYPES.fa_hist_asset_info;

    /*
    Note : l_asset_level_calc is an important structure
    -- If this is catchup, it needs to use the reval output asset information.
    -- if this is reval, it needs to use the reval mvmt asset information
    -- if this is reclass, it needs to use reval output asset information.
    */
    l_asset_level_calc  IGI_IAC_TYPES.iac_reval_output_asset;
    l_factor            number;
    l_ytd_factor        number;

    l_fp_reval_params IGI_IAC_TYPES.iac_reval_params;

    /* YTD Revaluation proration */
    l_deprn_ytd_total	number;
    l_remaining_deprn_ytd	number;
    l_dist_deprn_ytd	number;
    l_iac_inactive_dists_ytd number;
    l_fa_inactive_dists_ytd number;
    l_YTD_prorate_dists_tab igi_iac_types.prorate_dists_tab;
    l_YTD_prorate_dists_idx binary_integer;
    idx_YTD            binary_integer;

    l_path varchar2(150);
begin
    l_processed    := false;
    idx            := 1;
    l_operatg_blog     := 0;
    l_reserve_blog     := 0;
    l_deprn_blog       := 0;
    l_reserve_cost     := 0;
    l_operatg_ytd      := 0;
    l_operatg_ytd_bal  := 0;
    l_operatg_net      := 0;
    l_operatg_cost     := 0;
    l_deprn_ytd        := 0;
    l_old_deprn_ytd    := 0;
    l_old_gen_fund     := 0;
    l_deprn_ytd_total	:= 0;
    l_remaining_deprn_ytd	:= 0;
    l_dist_deprn_ytd	:= 0;
    l_iac_inactive_dists_ytd := 0;
    l_fa_inactive_dists_ytd := 0;
    l_path := g_path||'create_det_balances';
   -- for NOCOPY.
   l_fp_reval_params := fp_reval_params;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin create_det_balances');
   /* check if the reval mode is proper */
   if   fp_reval_params.reval_control.revaluation_mode not in ( 'P','L')
   then
      return true;
   end if;
   /* if this revaluation use the movement information, else use output information */
   if fp_reval_params.reval_control.transaction_type_code = 'REVALUATION' OR fp_second_set then
      l_asset_level_calc := fp_reval_params.reval_output_asset_mvmt;
      l_asset_level_calc.deprn_amount := fp_reval_params.reval_output_asset.deprn_amount;
   else
      l_asset_level_calc := fp_reval_params.reval_output_asset;
   end if;
   l_operatg_net     := l_asset_level_calc.operating_acct;

   if fp_second_set then
      l_adjustment_id     := fp_reval_params.reval_asset_params.second_set_adjustment_id ;
      l_reval_factor_curr := fp_reval_params.reval_curr_rate_info_next.current_reval_factor;
      l_reval_factor_cumm := fp_reval_params.reval_curr_rate_info_next.cumulative_reval_factor;
      l_operatg_ytd       := fp_reval_params.reval_asset_params.curr_ytd_opacc_next;
      l_deprn_ytd_total   := fp_reval_params.reval_asset_params.curr_ytd_deprn_next;/* YTD Proraion for det_balances*/
   else
      l_adjustment_id     := fp_reval_params.reval_asset_params.first_set_adjustment_id ;
      l_reval_factor_curr := fp_reval_params.reval_curr_rate_info_first.current_reval_factor;
      l_reval_factor_cumm := fp_reval_params.reval_curr_rate_info_first.cumulative_reval_factor;
      l_operatg_ytd       := fp_reval_params.reval_asset_params.curr_ytd_opacc_first;
      l_deprn_ytd_total   := fp_reval_params.reval_asset_params.curr_ytd_deprn_first; /* YTD Proraion det_balances*/
   end if;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+l_deprn_ytd : '||l_deprn_ytd);
  l_prev_factor_cumm  := fp_reval_params.reval_prev_rate_info.cumulative_reval_factor;
  l_deprn_ytd         := fp_reval_params.reval_asset_params.ytd_deprn_mvmt;/* YTD proration for accounting*/


  if l_adjustment_id = 0 then
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+adjustment id is not set');
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'end create_det_balances');
      return false;
   end if;
   /* make the call to the common utils to get the array of distributions */
   /* this would be overriden very soon by the correct distributions array program */
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+proration of active dists');
   IF NOT IGI_IAC_REVAL_UTILITIES.prorate_dists ( fp_asset_id              => fp_reval_params.reval_asset_params.asset_id
                       , fp_book_type_code         => fp_reval_params.reval_asset_params.book_type_code
                       , fp_current_period_counter => fp_reval_params.reval_asset_params.period_counter
                       , fp_prorate_dists_tab      => l_prorate_dists_tab
                       , fp_prorate_dists_idx      => l_prorate_dists_idx
                       )
   THEN
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+error IGI_IAC_REVAL_UTILITIES.prorate_dists');
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'end create_det_balances');
     return false;
   END IF;

    IF (fp_reval_params.reval_control.transaction_type_code = 'REVALUATION' AND
        fp_reval_params.reval_control.first_time_flag) THEN
        IF NOT IGI_IAC_REVAL_UTILITIES.prorate_all_dists_YTD ( fp_asset_id              => fp_reval_params.reval_asset_params.asset_id
                       , fp_book_type_code         => fp_reval_params.reval_asset_params.book_type_code
                       , fp_current_period_counter => fp_reval_params.reval_asset_params.period_counter
                       , fp_prorate_dists_tab      => l_YTD_prorate_dists_tab
                       , fp_prorate_dists_idx      => l_YTD_prorate_dists_idx
                       )
        THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+error IGI_IAC_REVAL_UTILITIES.prorate_all_dists_YTD');
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'end create_det_balances');
            return false;
        END IF;
    ELSE
        IF NOT IGI_IAC_REVAL_UTILITIES.prorate_active_dists_YTD ( fp_asset_id              => fp_reval_params.reval_asset_params.asset_id
                       , fp_book_type_code         => fp_reval_params.reval_asset_params.book_type_code
                       , fp_current_period_counter => fp_reval_params.reval_asset_params.period_counter
                       , fp_prorate_dists_tab      => l_YTD_prorate_dists_tab
                       , fp_prorate_dists_idx      => l_YTD_prorate_dists_idx
                       )
        THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+error IGI_IAC_REVAL_UTILITIES.prorate_active_dists_YTD');
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'end create_det_balances');
            return false;
        END IF;
    END IF;

   /*** Logic is as follows :
    *****************************
    a. get the movement info at the asset level.
    b. prorate the movement info across the distributions
    c. perform rounding and track the balance remaining.
    d. if not last distribution
          movement info := use the rounded info
       else
          movement info :=  remaining balance info
       end if;
       create accounting info using the movement info
    e. add the movement info to prev values to give current values.
    f. create det new balance entries
    *******************************
    ***/
    if not fp_second_set then
     begin
      select nvl(max(adjustment_id),-1)
      into   l_prev_adj_id
      from   igi_iac_transaction_headers
      where  asset_id = fp_reval_params.reval_asset_params.asset_id
      and    book_type_code = fp_reval_params.reval_asset_params.book_type_code
      and    adjustment_status in ( 'RUN','COMPLETE')
      and    adjustment_id < l_adjustment_id
      ;
      /*
          l_prev_adj_id := igi_iac_reval_utilities.latest_adjustment
                    ( fp_book_type_code => fp_reval_params.reval_asset_params.book_type_code
                    , fp_asset_id       => fp_reval_params.reval_asset_params.asset_id);
     */
      exception
         when others then
	    igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'+get latest_transaction api failed.');
	    igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,sqlerrm);
            l_prev_adj_id := -1;
      end;
    else
      l_prev_adj_id :=  fp_reval_params.reval_asset_params.first_set_adjustment_id;
    end if;

    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+get the previous adjustment id '|| l_prev_adj_id);

   /* get the total figures for the asset from det balances perspective */
   if l_reval_factor_cumm >= 1 and l_prev_factor_cumm >= 1 then
         l_operatg_cost := 0;
         l_operatg_net  := l_asset_level_calc.operating_acct;
         l_operatg_blog := l_operatg_cost - l_asset_level_calc.operating_acct;

         l_deprn_blog   := l_asset_level_calc.backlog_deprn_reserve;
         l_reserve_blog := l_asset_level_calc.backlog_deprn_reserve + l_asset_level_calc.operating_acct;
         l_reserve_cost := l_asset_level_calc.adjusted_cost;
   else

          l_operatg_net := l_asset_level_calc.operating_acct;
          l_operatg_blog := l_asset_level_calc.backlog_deprn_reserve + l_asset_level_calc.general_fund;
          l_operatg_cost  := l_operatg_net  + l_operatg_blog;
          l_deprn_blog   := l_asset_level_calc.backlog_deprn_reserve;
          l_reserve_cost := 0;
          l_reserve_blog := l_reserve_cost - l_asset_level_calc.general_fund;
    end if;
    l_total_fa                      :=  fp_reval_params.fa_asset_info;
    IF  fp_reval_params.fa_asset_info.period_counter_fully_reserved IS NOT NULL
        AND fp_reval_params.reval_asset_params.period_counter > fp_reval_params.fa_asset_info.last_period_counter THEN
        l_total_fa.deprn_amount := 0;
        l_total.deprn_period := 0;
    END IF;

    l_total.adjustment_id           :=  l_adjustment_id;
    l_total.asset_id                :=  fp_reval_params.reval_asset_params.asset_id;
    l_total.distribution_id         :=  -1;
    l_total.book_type_code          :=  fp_reval_params.reval_asset_params.book_type_code;
    l_total.period_counter          :=  fp_reval_params.reval_asset_params.period_counter;
    l_total.adjustment_cost         :=  l_asset_level_calc.adjusted_cost;
    l_total.reval_reserve_cost      :=  l_reserve_cost;
    l_total.reval_reserve_backlog   :=  l_reserve_blog;
    l_total.reval_reserve_gen_fund  :=  l_asset_level_calc.general_fund;
    l_total.reval_reserve_net       :=  l_asset_level_calc.reval_reserve;
    l_total.operating_acct_cost     :=  l_operatg_cost ;
    l_total.operating_acct_backlog  :=  l_operatg_blog;
    l_total.operating_acct_net      :=  l_operatg_net;
    l_total.operating_acct_ytd      :=  l_operatg_ytd;
    l_total.deprn_period            :=  l_asset_level_calc.deprn_amount;
    l_total.deprn_ytd               :=  l_deprn_ytd;/* YTD proration for accounting */

    l_total.deprn_reserve           :=  l_asset_level_calc.deprn_reserve;
    l_total.deprn_reserve_backlog   :=  l_deprn_blog;

    if l_reval_factor_cumm >= 1 and l_prev_factor_cumm >= 1 then
        l_total.general_fund_per        :=  l_asset_level_calc.deprn_amount;
    else
        l_total.general_fund_per        :=  0;
    end if;
    l_total.general_fund_acc        :=  l_asset_level_calc.general_fund;
    l_total.last_reval_date         :=  sysdate;
    l_total.current_reval_factor    :=  l_reval_factor_curr;
    l_total.cumulative_reval_factor :=  l_reval_factor_cumm;
    l_total.net_book_value          :=  l_total.adjustment_cost - l_total.deprn_reserve -
                                        l_total.deprn_reserve_backlog;
    l_total.active_flag             :=  NULL;

    -- round_det_balances  ( l_total ) ;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+l_total.deprn_ytd : '||l_total.deprn_ytd);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+FA deprn period : '|| l_total_fa.deprn_amount);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+FA deprn YTD :'||l_total_fa.ytd_deprn);
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Display unrounded figures for the asset');
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'-------------------------------------------------------------');
    display_det_balances  ( l_total );
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'-------------------------------------------------------------');

    IF NOT Forward_inactive_det_balances(fp_reval_params.reval_asset_params.asset_id,
                                         fp_reval_params.reval_asset_params.book_type_code,
                                         l_adjustment_id,
                                         fp_reval_params.reval_asset_params.period_counter,
                                         l_iac_inactive_dists_ytd,
                                         l_fa_inactive_dists_ytd) THEN
        igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+forward inactive detail balances Failed');
        return false;
    ELSE
        l_deprn_ytd_total := l_deprn_ytd_total - l_iac_inactive_dists_ytd; /* YTD for igi_iac_det_balances */
        l_total_fa.ytd_deprn := l_total_fa.ytd_deprn - l_fa_inactive_dists_ytd; /* YTD for igi_iac_fa_deprn */
    END IF;

    IF (fp_reval_params.reval_control.transaction_type_code = 'REVALUATION' AND
        fp_reval_params.reval_control.first_time_flag) THEN

        l_fa_inactive_dists_ytd := 0;
        IF NOT create_inactive_det_balances(fp_reval_params.reval_asset_params.asset_id,
                                         fp_reval_params.reval_asset_params.book_type_code,
                                         l_adjustment_id,
                                         fp_reval_params.reval_asset_params.period_counter,
                                         l_deprn_ytd_total,
                                         l_total_fa.ytd_deprn,
                                         l_YTD_prorate_dists_tab,
                                         l_YTD_prorate_dists_idx) THEN
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+create inactive detail balances Failed');
            return false;
        END IF;
    END IF;

    if not igi_iac_common_utils.iac_round ( x_amount => l_deprn_ytd_total
                                            , x_book   => fp_reval_params.reval_asset_params.book_type_code)  then
        return false;
    end if;

    l_remaining := l_total;
    l_remaining_fa := l_total_fa;
    l_remaining_deprn_ytd := l_deprn_ytd_total;/* YTD proration*/


   idx := l_prorate_dists_tab.FIRST;
   WHILE idx <= l_prorate_dists_tab.LAST LOOP
        l_factor := l_prorate_dists_tab ( idx ).normal_prorate_factor ;
        l_ytd_factor := 0 ;

        IF fp_reval_params.reval_control.transaction_type_code = 'RECLASS' THEN
            l_ytd_factor := l_factor;
        ELSE
            idx_YTD := l_YTD_prorate_dists_tab.FIRST;
            WHILE idx_YTD <= l_YTD_prorate_dists_tab.LAST LOOP
                IF l_prorate_dists_tab(idx).distribution_id = l_YTD_prorate_dists_tab(idx_YTD).distribution_id THEN
                    l_ytd_factor := l_YTD_prorate_dists_tab(idx_YTD).ytd_prorate_factor;
                    EXIT;
                END IF;
                idx_ytd := l_YTD_prorate_dists_tab.Next(idx_ytd);
            END LOOP;
        END IF;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+prorate distribution factor '|| l_factor);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+prorate YTD distribution factor '|| l_ytd_factor);
        l_processed := true;

       /* for each distribution, prorate the asset mvmt information  */
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+mvmt cost '|| fp_reval_params.reval_output_asset_mvmt.adjusted_cost);

          if l_reval_factor_cumm >= 1 and l_prev_factor_cumm >= 1 then
             l_reserve_blog := l_factor * l_total.reval_reserve_backlog;
             do_round(l_reserve_blog,fp_reval_params.reval_output_asset_mvmt.book_type_code);

             l_operatg_blog := l_factor * l_total.operating_acct_backlog;
             do_round(l_operatg_blog,fp_reval_params.reval_output_asset_mvmt.book_type_code);

             l_operatg_cost := 0;
             l_operatg_net  := l_operatg_cost - l_operatg_blog;
             l_reserve_cost := l_factor * l_total.adjustment_cost;
             do_round(l_reserve_cost,fp_reval_params.reval_output_asset_mvmt.book_type_code);

             l_deprn_blog   := l_factor * l_total.deprn_reserve_backlog;
             do_round(l_deprn_blog,fp_reval_params.reval_output_asset_mvmt.book_type_code);
          else
             l_operatg_blog := l_factor * l_total.operating_acct_backlog;
             do_round(l_operatg_blog,fp_reval_params.reval_output_asset_mvmt.book_type_code);

             l_reserve_blog := l_factor * l_total.reval_reserve_backlog;
             do_round(l_reserve_blog,fp_reval_params.reval_output_asset_mvmt.book_type_code);

             l_operatg_cost := l_factor * l_total.operating_acct_cost;
             do_round(l_operatg_cost,fp_reval_params.reval_output_asset_mvmt.book_type_code);

             l_operatg_net  := l_operatg_cost  - l_operatg_blog;
             l_reserve_cost := 0;
             l_deprn_blog   := l_factor * l_total.deprn_reserve_backlog;
             do_round(l_deprn_blog,fp_reval_params.reval_output_asset_mvmt.book_type_code);
          end if;
          l_db_fa := l_remaining_fa;

          begin
                select nvl(operating_acct_ytd,0)
                into   l_operatg_ytd_bal
                from   igi_iac_det_balances
                where  asset_id       = fp_reval_params.reval_asset_params.asset_id
                and    distribution_id = l_prorate_dists_tab( idx ).distribution_id
                and    book_type_code = fp_reval_params.reval_asset_params.book_type_code
                and    adjustment_id  = l_prev_adj_id
                and    l_prev_adj_id <> -1
                ;
          exception when others then
                   l_operatg_ytd_bal := 0;
          end;
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+ l_total.deprn_ytd : '||l_total.deprn_ytd);
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+ FA deprn period : '|| l_total_fa.deprn_amount);
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+ FA deprn YTD :'||l_total_fa.ytd_deprn);

        if idx <> l_prorate_dists_tab.LAST THEN

           if l_reval_factor_cumm >= 1 and l_prev_factor_cumm >= 1
           then
             null;
           else
            l_operatg_ytd_bal            :=  l_operatg_ytd_bal + l_operatg_net;
           end if;
            l_db.adjustment_id           :=  l_adjustment_id;
            l_db.asset_id                :=  fp_reval_params.reval_asset_params.asset_id;
            l_db.distribution_id         :=  l_prorate_dists_tab( idx ).distribution_id;
            l_db.book_type_code          :=  fp_reval_params.reval_asset_params.book_type_code;
            l_db.period_counter          :=  fp_reval_params.reval_asset_params.period_counter;
            l_db.adjustment_cost         :=  l_factor * l_total.adjustment_cost;
            do_round(l_db.adjustment_cost,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.net_book_value          :=  l_factor * l_total.net_book_value;
            do_round(l_db.net_book_value,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.reval_reserve_cost      :=  l_reserve_cost;
            l_db.reval_reserve_backlog   :=  l_reserve_blog;
            l_db.reval_reserve_gen_fund  :=  l_factor * l_total.reval_reserve_gen_fund;
            do_round(l_db.reval_reserve_gen_fund,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.reval_reserve_net       :=  l_factor * l_total.reval_reserve_net;
            do_round(l_db.reval_reserve_net,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.operating_acct_cost     :=  l_operatg_cost;
            l_db.operating_acct_backlog  :=  l_operatg_blog;
            l_db.operating_acct_net      :=  l_operatg_net;
            l_db.operating_acct_ytd      :=  l_operatg_ytd_bal;
            l_db.deprn_period            :=  l_factor * l_total.deprn_period;
            do_round(l_db.deprn_period,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.deprn_ytd               :=  l_factor * l_total.deprn_ytd; /* YTD for EXPENSE accounting */
            do_round(l_db.deprn_ytd,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.deprn_reserve           :=  l_factor * l_total.deprn_reserve;
            do_round(l_db.deprn_reserve,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.deprn_reserve_backlog   :=  l_deprn_blog;
            l_db.general_fund_per        :=  l_factor * l_total.general_fund_per;
            do_round(l_db.general_fund_per,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.general_fund_acc        :=  l_factor * l_total.general_fund_acc;
            do_round(l_db.general_fund_acc,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.last_reval_date         :=  fp_reval_params.reval_asset_params.revaluation_date;
            l_db.current_reval_factor    :=  l_reval_factor_curr;
            l_db.cumulative_reval_factor :=  l_reval_factor_cumm;
            l_db.active_flag             :=  l_prorate_dists_tab ( idx ).active_flag;

            l_dist_deprn_ytd := l_deprn_ytd_total * l_ytd_factor; /* YTD proration for igi_iac_det_balances */
            do_round(l_dist_deprn_ytd,fp_reval_params.reval_output_asset_mvmt.book_type_code);

             if not igi_iac_common_utils.iac_round ( x_amount => l_dist_deprn_ytd
                                            , x_book   => fp_reval_params.reval_asset_params.book_type_code )         then
                return false;
             end if;

            l_db_fa           := l_total_fa; /* initalize */

           l_db_fa.ytd_deprn := l_total_fa.ytd_deprn * l_ytd_factor; /* YTD for igi_iac_fa_deprn */
           do_round(l_db_fa.ytd_deprn,fp_reval_params.reval_output_asset_mvmt.book_type_code);
           l_db_fa.deprn_amount := l_total_fa.deprn_amount * l_factor;
           do_round(l_db_fa.deprn_amount,fp_reval_params.reval_output_asset_mvmt.book_type_code);
           l_db_fa.deprn_reserve := l_total_fa.deprn_reserve * l_factor;
           do_round(l_db_fa.deprn_reserve,fp_reval_params.reval_output_asset_mvmt.book_type_code);

           round_fa_figures  ( fp_fa_hist  => l_db_fa  , fp_det_balances => l_db );

           l_remaining_fa.ytd_deprn := l_remaining_fa.ytd_deprn - l_db_fa.ytd_deprn;
           l_remaining_fa.deprn_amount := l_remaining_fa.deprn_amount - l_db_fa.deprn_amount;
           l_remaining_fa.deprn_reserve := l_remaining_fa.deprn_reserve - l_db_fa.deprn_reserve;

            verify_det_balances  ( fp_det_balances => l_db
                        , fp_prev_cum_factor => l_prev_factor_cumm
                        , fp_curr_cum_factor => l_reval_factor_cumm
                        );
            remaining_det_balances ( fp_det_balances => l_remaining , fp_det_delta  => l_db );
            l_remaining_deprn_ytd := l_remaining_deprn_ytd - l_dist_deprn_ytd;/* YTD proration*/
            round_det_balances ( l_db ) ;
        else
            l_db.adjustment_id           :=  l_adjustment_id;
            l_db.asset_id                :=  fp_reval_params.reval_asset_params.asset_id;
            l_db.distribution_id         :=  l_prorate_dists_tab( idx ).distribution_id;
            l_db.book_type_code          :=  fp_reval_params.reval_asset_params.book_type_code;
            l_db.period_counter          :=  fp_reval_params.reval_asset_params.period_counter;
            l_db.adjustment_cost         :=  l_remaining.adjustment_cost;
            l_db.net_book_value          :=  l_remaining.net_book_value;
            l_db.reval_reserve_cost      :=  l_remaining.reval_reserve_cost;
            l_db.reval_reserve_backlog   :=  l_remaining.reval_reserve_backlog ;
            l_db.reval_reserve_gen_fund  :=  l_remaining.reval_reserve_gen_fund;
            l_db.reval_reserve_net       :=  l_remaining.reval_reserve_net;
            l_db.operating_acct_cost     :=  l_remaining.operating_acct_cost;
            l_db.operating_acct_backlog  :=  l_remaining.operating_acct_backlog;
            l_db.operating_acct_net      :=  l_remaining.operating_acct_net ;
            l_db.operating_acct_ytd      :=  l_remaining.operating_acct_ytd  ;
            l_db.deprn_period            :=  l_remaining.deprn_period;
            l_db.deprn_ytd               :=  l_factor * l_total.deprn_ytd; /* For EXPENSE accounting */
            do_round(l_db.deprn_ytd,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            l_db.deprn_reserve           :=  l_remaining.deprn_reserve;
            l_db.deprn_reserve_backlog   :=  l_remaining.deprn_reserve_backlog;
            l_db.general_fund_per        :=  l_remaining.general_fund_per;
            l_db.general_fund_acc        :=  l_remaining.general_fund_acc;
            l_db.last_reval_date         :=  fp_reval_params.reval_asset_params.revaluation_date;
            l_db.current_reval_factor    :=  l_reval_factor_curr;
            l_db.cumulative_reval_factor :=  l_reval_factor_cumm;
            l_db.active_flag             :=  l_prorate_dists_tab ( idx ).active_flag;

            l_dist_deprn_ytd := l_deprn_ytd_total * l_ytd_factor; /* YTD for igi_iac_det_balances */
            do_round(l_dist_deprn_ytd,fp_reval_params.reval_output_asset_mvmt.book_type_code);
            round_det_balances ( l_db ) ;

            verify_det_balances  ( fp_det_balances => l_db
                        , fp_prev_cum_factor => l_prev_factor_cumm
                        , fp_curr_cum_factor => l_reval_factor_cumm
                        );


           l_db_fa           := l_total_fa; /* initalize */

           l_db_fa.ytd_deprn := l_total_fa.ytd_deprn * l_ytd_factor; /* YTD for igi_iac_fa_deprn */
           do_round(l_db_fa.ytd_deprn,fp_reval_params.reval_output_asset_mvmt.book_type_code);
           l_db_fa.deprn_amount := l_remaining_fa.deprn_amount;
           l_db_fa.deprn_reserve := l_remaining_fa.deprn_reserve;

            if not igi_iac_common_utils.iac_round ( x_amount => l_dist_deprn_ytd
                                            , x_book   => fp_reval_params.reval_asset_params.book_type_code )         then
                return false;
            end if;

           round_fa_figures  ( fp_fa_hist  => l_db_fa  , fp_det_balances => l_db );
        end if;

        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Display figures for '|| l_prorate_dists_tab( idx ).distribution_id);
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'-------------------------------------------------------------');
        display_det_balances  ( l_db ) ;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'-------------------------------------------------------------');
        /* now create the accounting entries using the mvmt info */

        IF NOT IGI_IAC_REVAL_ACCOUNTING.create_iac_acctg
         ( fp_det_balances => l_db
          , fp_create_acctg_flag => fp_reval_params.reval_control.create_acctg_entries,
	  p_event_id => null
          )
        THEN
           return false;
        END IF;

	/* This code is not required for RECLASS now.
 	    if fp_reval_params.reval_control.transaction_type_code  IN ('RECLASS') then
                l_prev_adj_id :=-1;

             end  if;
           End of commenting for RECLASS code */

        /* now get the previous entry */
        if not get_prev_det_balances
                    ( fp_adjustment_id   => l_prev_adj_id
                    , fp_distribution_id => l_db.distribution_id
                    , fp_asset_id        => l_db.asset_id
                    , fp_book_type_code  => l_db.book_type_code
                    , fp_period_counter  => l_db.period_counter
                    , fp_transaction_sub_type => fp_reval_params.reval_control.transaction_sub_type
                    , fp_det_balances    => l_prev_db
                    )
         then
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+unable to get previous entry from det balances');
            return false;
         end if;


          /* grab the ytd value of the prev entry */
        l_old_deprn_ytd := nvl(l_prev_db.deprn_ytd,0);
        l_old_gen_fund  := nvl(l_prev_db.general_fund_acc,0);


        l_prev_db.deprn_ytd := l_dist_deprn_ytd; /* YTD proration*/
        /* now add the curr mvmt to the prev entry to give final figures */
        add_det_balances ( fp_det_balances => l_prev_db  , fp_det_delta => l_db );

       /* verify the net figures prior to inserting */
       verify_det_balances  ( fp_det_balances => l_prev_db
                        , fp_prev_cum_factor => l_prev_factor_cumm
                        , fp_curr_cum_factor => l_reval_factor_cumm
                        );

       /* ensure that the depreciation expense is calculated properly */
          if  nvl(l_prev_db.active_flag,'Y') = 'N' then
             l_prev_db.deprn_period := 0;
             l_prev_db.general_fund_per := 0;
             l_prev_db.general_fund_acc := 0;
          else
             if l_reval_factor_cumm = 1 then
               l_prev_db.deprn_period := 0;
             end if;
             l_prev_db.general_fund_per := l_prev_db.general_fund_acc - l_old_gen_fund;
          end if;
       /* now prev db is updated with the current movemnt, so create new record */
        if ( not create_det_balances_private ( fp_det_balances => l_prev_db ) )
        then
           igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'error in table handler for det balances');
           return false;
        end if;

            if  ( not create_fa_figures_private ( fp_det_balances => l_prev_db
                                            , fp_fa_balances  => l_db_fa
                                            ) )
            then
                igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'error in table handler for fa det balances');
                return false;
            end if;

        IF idx < l_prorate_dists_tab.LAST THEN
           idx := l_prorate_dists_tab.NEXT( idx );
        ELSE
            EXIT;
        END IF;

   END LOOP;

   if l_processed then
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+successful creation of the det balances records.');
   else
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'some/all distributions failed to be processed');
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+error creation of the det balances records.');
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'end create_det_balances');
      return false;
   end if;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end create_det_balances');
   return true;
exception when others then
   fp_reval_params := l_fp_reval_params;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function create_reval_rates
    ( fp_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
    , fp_second_set   in boolean  )
return boolean is
   l_reval_rates igi_iac_revaluation_rates%ROWTYPE;
   l_adjustment_id  igi_iac_revaluation_rates.adjustment_id%TYPE;
   l_fp_reval_params IGI_IAC_TYPES.iac_reval_params;
   l_path varchar2(150);
begin
   l_path := g_path||'create_reval_rates';
   -- for NOCOPY
   l_fp_reval_params := fp_reval_params;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin create reval rates');
   -- modified by sekhar
    if (fp_reval_params.reval_control.transaction_type_code NOT IN ('RECLASS','ADDITION')) then
     if   fp_reval_params.reval_control.revaluation_mode <> 'P' then
          return true;
    end if;
   end if;
   -- modified by sekhar

   if fp_second_set then
      l_reval_rates := fp_reval_params.reval_curr_rate_info_next;
      l_adjustment_id := fp_Reval_params.reval_asset_params.second_set_adjustment_id;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+using next set for create reval rates');
   else
       l_adjustment_id := fp_Reval_params.reval_asset_params.first_set_adjustment_id;
       l_reval_rates := fp_reval_params.reval_curr_rate_info_first;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+using first set for create reval rates');
   end if;

   if l_adjustment_id = 0 then
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+adjustments not generated yet.');
      return false;
   end if;
   /*
   -- change of logic.
   -- if the revaluation is still in preview, do not set latest record flag
   -- do this only in the run mode.
   */
   if (fp_reval_params.reval_control.transaction_type_code NOT IN ('RECLASS','ADDITION')) then
     if   fp_reval_params.reval_control.revaluation_mode = 'P' then
             l_reval_rates.processed_flag := 'Y';
             l_reval_rates.latest_record  := 'N';
    end if;
   end if;



   insert into igi_iac_revaluation_Rates
   (
    asset_id
    ,book_type_code
    ,revaluation_id
    ,period_counter
    ,reval_type
    ,current_reval_factor
    ,cumulative_reval_factor
    ,processed_flag
    ,adjustment_id
    ,latest_record
    ,created_by
    ,creation_date
    ,last_update_login
    ,last_update_date
    ,last_updated_by
   )
   values
   (
    l_reval_rates.asset_id
    ,l_reval_rates.book_type_code
    ,l_reval_rates.revaluation_id
    ,l_reval_rates.period_counter
    ,l_reval_rates.reval_type
    ,l_reval_rates.current_reval_factor
    ,l_reval_rates.cumulative_reval_factor
    ,l_reval_rates.processed_flag
    ,l_adjustment_id
    ,l_reval_rates.latest_record
    ,l_reval_rates.created_by
    ,l_reval_rates.creation_date
    ,l_reval_rates.last_update_login
    ,l_reval_rates.last_update_date
    ,l_reval_rates.last_updated_by
   );
   if sql%found then
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+inserted previous set reval rates');
   else
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+failed insert of reval rates');
   end if;

   return true;

exception when others then
   fp_reval_params := l_fp_reval_params;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return FALSE;
end;

function update_reval_rates ( fp_adjustment_id in number )
return boolean is
     cursor c_txns is
      select asset_id, book_type_code
      from  igi_iac_transaction_headers
      where adjustment_id = fp_adjustment_id
      ;
   l_path varchar2(150);
begin
   l_path := g_path||'update_reval_rates';
 for l_txns in c_txns loop

       update igi_iac_revaluation_rates
       set    latest_record  = 'N'
       where  asset_id       = l_txns.asset_id
         and  book_type_code = l_txns.book_type_code
         and  processed_flag = 'Y'
         and  adjustment_id  <> fp_adjustment_id
       ;
       if sql%found then
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+ updated previous set reval rates');
       else
          igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+ failed update of reval rates');
       end if;

       update igi_iac_revaluation_rates
       set    latest_record  = 'Y'
       where  asset_id       = l_txns.asset_id
         and  book_type_code = l_txns.book_type_code
         and  processed_flag = 'Y'
         and  adjustment_id  = fp_adjustment_id
       ;
       if sql%found then
          return true;
       else
          return false;
       end if;

   end loop;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function crud_iac_tables
     ( fp_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
    ,  fp_second_set   in boolean  )
return boolean is

    l_fp_reval_params IGI_IAC_TYPES.iac_reval_params;
    l_path varchar2(150);
begin
    l_path := g_path||'crud_iac_tables';
   -- for NOCOPY.
   l_fp_reval_params := fp_reval_params;

   if not fp_reval_params.reval_control.crud_allowed then
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+create, update or delete is not allowed.');
      return true;
   end if;

   if  nvl(fp_reval_params.reval_control.calling_program,'REVALUATION')
           in ('UPGRADE','IMPLEMENTATION')
   then
          if not igi_iac_reval_impl_crud.crud_iac_tables( fp_reval_params => fp_reval_params
                      ,   fp_second_set   => fp_second_set )
          then
             return false;
          end if;
          return true;
   end if;

   if not create_txn_headers
    ( fp_reval_params => fp_reval_params
    ,   fp_second_set => fp_second_set
     )
   then
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+create txn headers  Failed');
      return false;
   end if;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Create Det balances');
   begin
       if not create_det_balances
         ( fp_reval_params => fp_reval_params
        ,   fp_second_set => fp_second_set
         )
       then
         igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+create det balances');
          return false;
       end if;
   exception when others then
      igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,'error in det balances');
      igi_iac_debug_pkg.debug_other_string(g_unexp_level,l_path,sqlerrm);
      return false;
   end;
   if  fp_reval_params.reval_control.modify_balances then
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+updating asset balances');
       if not create_asset_balances
         ( fp_reval_params => fp_reval_params
        ,   fp_second_set => fp_second_set
         )
       then
          return false;
       end if;
   end if;

  /* last step of the process */


   if not create_reval_rates
    ( fp_reval_params => fp_reval_params
    ,   fp_second_set => fp_second_set
     )
   then
       igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+failed insert into reval rates');
      return false;
   end if;

   return true;

exception when others then
  fp_reval_params := l_fp_reval_params;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return false;
end;

function reval_status_to_previewed
     ( fp_reval_id     in out NOCOPY IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE )
return boolean is
 pragma autonomous_transaction;
begin
     update igi_iac_revaluations
     set    status = IGI_IAC_TYPES.gc_previewed_status
     where  revaluation_id = fp_reval_id
     ;
     if sql%found then
       do_commit;
       return true;
     else
       rollback;
       return false;
     end if;
end;

function reval_status_to_failed_pre
     ( fp_reval_id     in out NOCOPY IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE )
return boolean is
 pragma autonomous_transaction;
begin
     update igi_iac_revaluations
     set    status = IGI_IAC_TYPES.gc_failedpre_status
     where  revaluation_id = fp_reval_id
     ;
     if sql%found then
      do_commit;
       return true;
     else
       rollback;
       return false;
     end if;
end;

function reval_status_to_completed
     ( fp_reval_id     in out NOCOPY IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE,
       p_event_id      in number)
return boolean is
  pragma autonomous_transaction;
begin
     if p_event_id is not null then
         update igi_iac_revaluations
         set    status = IGI_IAC_TYPES.gc_completed_status,
         event_id = p_event_id
         where  revaluation_id = fp_reval_id
         and event_id is null;
     else
         update igi_iac_revaluations
         set    status = IGI_IAC_TYPES.gc_completed_status
         where  revaluation_id = fp_reval_id;
     end if;

     if sql%found then
      do_commit;
       return true;
     else
      rollback;
       return false;
     end if;
end;

function reval_status_to_failed_run
     ( fp_reval_id     in out NOCOPY IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE )
return boolean is
 pragma autonomous_transaction;
begin
     update igi_iac_revaluations
     set    status = IGI_IAC_TYPES.gc_failedrun_status
     where  revaluation_id = fp_reval_id
     ;
     if sql%found then
          do_commit;
       return true;
     else
      rollback;
       return false;
     end if;
end;

function allow_transfer_to_gl
     ( fp_reval_id       in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_book_type_code in  IGI_IAC_REVALUATIONS.BOOK_TYPE_CODE%TYPE
     , fp_asset_id       in  IGI_IAC_TRANSACTION_HEADERS.ASSET_ID%TYPE
     )
return boolean is
   cursor c_check is
     select 'x'
     from   igi_iac_reval_asset_rules
     where  revaluation_factor <> 1
     and    asset_id           = fp_asset_id
     and    book_type_code     = fp_book_type_code
     and    revaluation_id     = fp_reval_id
     ;
    l_can_update boolean;
    l_path varchar2(150);
begin
    l_path := g_path||'allow_transfer_to_gl';
    l_can_update := false;
     for l_check in c_check loop
        l_can_update := true;
     end loop;
     if l_can_update then
         update igi_iac_adjustments
         set    transfer_to_gl_flag  = 'Y'
         where  adjustment_id  in ( select adjustment_id
                                    from   igi_iac_transaction_headers
                                    where  mass_reference_id = fp_reval_id
                                    and    book_type_code    = fp_book_type_code
                                    and    asset_id          = fp_asset_id
                                   )
         and    asset_id            = fp_asset_id
         and    book_type_code      = fp_book_type_code
         and    transfer_to_gl_flag = 'N'
         ;
         if sql%found then
           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Updated Transfer_to_gl_flag');
         else
           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'No records found to update transfer_to_gl_flag');
         end if;
     end if;
     return true;
end;

--Added for SLA uptake. This function will update tables with event_id.
function stamp_sla_event
     ( fp_reval_id       in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_book_type_code in  IGI_IAC_REVALUATIONS.BOOK_TYPE_CODE%TYPE
     , fp_event_id       in  IGI_IAC_REVALUATIONS.EVENT_ID%TYPE
     )
return boolean is
   cursor c_check is
     select 'x'
     from   igi_iac_reval_asset_rules
     where  revaluation_factor <> 1
     and    book_type_code     = fp_book_type_code
     and    revaluation_id     = fp_reval_id;
    l_can_update boolean;
    l_path varchar2(150);
begin
    l_path := g_path||'stamp_sla_event';
    l_can_update := false;
     for l_check in c_check loop
        l_can_update := true;
     end loop;
     if l_can_update then
         update igi_iac_adjustments
         set    event_id  = fp_event_id
         where  adjustment_id  in ( select adjustment_id
                                    from   igi_iac_transaction_headers
                                    where  mass_reference_id = fp_reval_id
                                    and    book_type_code    = fp_book_type_code
                                   )
         and    book_type_code      = fp_book_type_code
         and    transfer_to_gl_flag = 'Y';

         if sql%found then
           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'stamped event_id in igi_iac_adjustments');
         else
           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'No records found to stamp event_id in igi_iac_adjustments');
         end if;

         update igi_iac_transaction_headers
         set event_id  = fp_event_id
         where  mass_reference_id = fp_reval_id
         and    book_type_code    = fp_book_type_code;

         if sql%found then
           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'stamped event_id in igi_iac_transaction_headers');
         else
           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'No records found to stamp event_id in igi_iac_transaction_headers');
         end if;
     end if;
     return true;
end;
--Added for SLA uptake. This function will update tables with event_id.

function adjustment_status_to_run
     ( fp_reval_id     in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_asset_id     in  IGI_IAC_TRANSACTION_HEADERS.ASSET_ID%TYPE
     )
return boolean is
begin
     update igi_iac_transaction_headers
     set    adjustment_status = 'RUN'
     where  mass_Reference_id = fp_reval_id
     and    transaction_type_code = 'REVALUATION'
     and    asset_id       = fp_asset_id
     and    adjustment_status = 'PREVIEW'
     ;
     if sql%found then
       return true;
     else
       return false;
     end if;
end;

function adjustment_status_to_obsolete
     ( fp_reval_id     in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_asset_id     in  IGI_IAC_TRANSACTION_HEADERS.ASSET_ID%TYPE
     )
return boolean is
begin
     update igi_iac_transaction_headers
     set    adjustment_status = 'OBSOLETE'
     where  mass_Reference_id = fp_reval_id
     and    transaction_type_code = 'REVALUATION'
     and    asset_id       = fp_asset_id
     and    adjustment_status = 'PREVIEW'
     ;
     if sql%found then
       return true;
     else
       return false;
     end if;
end;

function update_balances
     ( fp_reval_id       in  IGI_IAC_REVALUATIONS.REVALUATION_ID%TYPE
     , fp_asset_id       in  IGI_IAC_TRANSACTION_HEADERS.ASSET_ID%TYPE
     , fp_period_counter in IGI_IAC_TRANSACTION_HEADERS.PERIOD_COUNTER%TYPE
     , fp_book_type_code in IGI_IAC_TRANSACTION_HEADERS.BOOK_TYPE_CODE%TYPE
     )
return boolean is

   l_bal_net_book_value        IGI_IAC_ASSET_BALANCES.NET_BOOK_VALUE%TYPE;
   l_bal_adjusted_cost         IGI_IAC_ASSET_BALANCES.adjusted_cost%TYPE;
   l_bal_operating_acct        IGI_IAC_ASSET_BALANCES.operating_acct%TYPE;
   l_bal_reval_reserve         IGI_IAC_ASSET_BALANCES.reval_reserve%TYPE;
   l_bal_deprn_reserve         IGI_IAC_ASSET_BALANCES.deprn_reserve%TYPE;
   l_bal_deprn_amount          IGI_IAC_ASSET_BALANCES.deprn_amount%TYPE;
   l_bal_backlog_deprn_reserve IGI_IAC_ASSET_BALANCES.backlog_deprn_reserve%TYPE;
   l_bal_general_fund          IGI_IAC_ASSET_BALANCES.general_fund%TYPE;
   l_cumm_reval_factor         IGI_IAC_ASSET_BALANCES.cumulative_reval_factor%TYPE;
   l_reval_factor              IGI_IAC_ASSET_BALANCES.current_reval_factor%TYPE;
   l_reval_date                date;
   l_output igi_iac_types.iac_reval_output_asset;

   cursor c_asset_bal is
     select
        nvl(net_book_value,0) net_book_value
        ,nvl(adjusted_cost,0) adjusted_cost
        ,nvl(operating_acct,0) operating_acct
        ,nvl(reval_reserve,0) reval_reserve
        ,nvl(deprn_amount,0) deprn_amount
        ,nvl(deprn_reserve,0) deprn_reserve
        ,nvl(backlog_deprn_reserve,0) backlog_deprn_reserve
        ,nvl(general_fund,0) general_fund
        ,last_reval_date
        ,current_reval_factor
        ,cumulative_reval_factor
     from  igi_iac_asset_balances
     where asset_id = fp_asset_id
     and   book_type_code = fp_book_type_code
     and   period_counter =  ( select max(period_counter)
                               from   igi_iac_asset_balances
                               where  asset_id = fp_asset_id
                               and   book_type_code = fp_book_type_code
                               and period_counter  <= fp_period_counter )
     ;

cursor c_asset_det  is
     select
        nvl(sum(net_book_value),0) net_book_value
        ,nvl(sum(adjustment_cost),0)       adjusted_cost
        ,nvl(sum(operating_acct_net),0)    operating_acct
        ,nvl(sum(reval_reserve_net),0)     reval_reserve
        ,nvl(sum(deprn_period),0)          deprn_amount
        ,nvl(sum(deprn_reserve),0)         deprn_reserve
        ,nvl(sum(deprn_reserve_backlog),0) backlog_deprn_reserve
        ,nvl(sum(nvl(reval_reserve_gen_fund,0)),0) general_fund
     from  igi_iac_det_balances
     where asset_id       = fp_asset_id
     and   book_type_code = fp_book_type_code
     and   period_counter =  fp_period_counter
     and   adjustment_id in ( select adjustment_id
                              from   igi_iac_transaction_headers
                              where  asset_id              = fp_asset_id
                              and    period_counter        = fp_period_counter
                              and    transaction_type_code = 'REVALUATION'
                              and    mass_reference_id     = fp_reval_id
                              and    adjustment_id_out is null
                              )
     ;

    cursor c_reval_info is
      select iar.revaluation_id, iar.revaluation_date
           , iirar.revaluation_factor
      from   igi_iac_revaluations iar
         ,   igi_iac_reval_asset_rules iirar
      where  iar.revaluation_id         = fp_reval_id
         and   iirar.revaluation_id       = fp_reval_id
          and   iirar.asset_id             = fp_asset_id
         and  iirar.book_type_code       = iar.book_type_code
     ;

    l_path varchar2(150);

begin
    l_path := g_path||'update_balances';
   -- 1. Get the old balance from igi_iac_asset_balances
   l_bal_net_book_value         := 0;
   l_bal_adjusted_cost          := 0;
   l_bal_operating_acct         := 0;
   l_bal_reval_reserve          := 0;
   l_bal_deprn_reserve          := 0;
   l_bal_deprn_amount           := 0;
   l_bal_backlog_deprn_reserve  := 0;
   l_bal_general_fund           := 0;
   l_cumm_reval_factor          := 1;

   for l_bal in c_asset_bal loop
       l_cumm_reval_factor          := l_bal.cumulative_reval_factor;
   end loop;

   -- 2. Get the sum from igi_iac_det_balances
   for l_det in c_asset_det loop
   -- 3. add (1) and (2) to get the final result.
       l_bal_net_book_value         := l_bal_net_book_value + l_det.net_book_value;
       l_bal_adjusted_cost          := l_bal_adjusted_cost  + l_det.adjusted_cost;
       l_bal_operating_acct         := l_bal_operating_acct + l_det.operating_acct;
       l_bal_reval_reserve          := l_bal_reval_reserve  + l_det.reval_reserve;
       l_bal_deprn_reserve          := l_bal_deprn_reserve  + l_det.deprn_reserve;
       l_bal_deprn_amount           := l_bal_deprn_amount   + l_det.deprn_amount;
       l_bal_backlog_deprn_reserve  := l_bal_backlog_deprn_reserve + l_det.backlog_deprn_reserve;
       l_bal_general_fund           := l_bal_general_fund  + l_det.general_fund;

   end loop;

   for l_info in c_reval_info loop
       l_reval_date := l_info.revaluation_date;
       l_reval_factor := l_info.revaluation_factor;
       l_cumm_reval_factor := l_cumm_reval_factor * l_info.revaluation_factor;
   end loop;


   begin
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin create_asset_balances');

         l_output.asset_id                  := fp_asset_id;
         l_output.book_type_code            := fp_book_type_code;
         l_output.period_counter            := fp_period_counter;
         l_output.net_book_value            := l_bal_net_book_value;
         l_output.adjusted_cost             := l_bal_adjusted_cost;
         l_output.operating_acct            := l_bal_operating_acct;
         l_output.reval_reserve             := l_bal_reval_reserve;
         l_output.deprn_amount              := l_bal_deprn_amount;
         l_output.deprn_reserve             := l_bal_deprn_reserve;
         l_output.backlog_deprn_reserve     := l_bal_backlog_deprn_reserve;
         l_output.general_fund              := l_bal_general_fund;
         l_output.last_reval_date           := l_reval_date;
         l_output.current_reval_factor      := l_reval_factor;
         l_output.cumulative_reval_factor   := l_cumm_reval_factor;

         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'insert/update first record');
         create_balance (pp_period_counter   => fp_period_counter
                         , pp_reval_output_asset => l_output
                         ) ;
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'insert/update second record');
         create_balance (pp_period_counter   => fp_period_counter+1
                         , pp_reval_output_asset => l_output
                         ) ;
   end;
   return true;

exception when others then
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
g_path        := 'IGI.PLSQL.igiiardb.IGI_IAC_REVAL_CRUD.';
--===========================FND_LOG.END=======================================
END;


/
