--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_ENGINE" AS
-- $Header: igiiareb.pls 120.10.12010000.2 2010/06/24 12:35:41 schakkin ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiareb.IGI_IAC_REVAL_ENGINE.';

--===========================FND_LOG.END=======================================

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

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

procedure do_round ( p_info in out NOCOPY IGI_IAC_TYPES.iac_reval_output_asset ) is
     p_info_old IGI_IAC_TYPES.iac_reval_output_asset;
     l_path varchar2(150) := g_path||'do_round';
begin
     p_info_old := p_info;

     do_round( p_info.adjusted_cost   , p_info.book_type_code  )     ;
     do_round( p_info.operating_acct  , p_info.book_type_code  )     ;
     do_round( p_info.deprn_amount    , p_info.book_type_code  )     ;
     do_round( p_info.backlog_deprn_reserve , p_info.book_type_code  )     ;
     do_round( p_info.deprn_reserve    , p_info.book_type_code )     ;
     do_round( p_info.general_fund     , p_info.book_type_code )     ;
     do_round( p_info.reval_reserve    , p_info.book_type_code  )     ;
     do_round( p_info.net_book_value   , p_info.book_type_code )  ;

exception when others then
  p_info := p_info_old;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  Raise;
end;

procedure display ( p_info in IGI_IAC_TYPES.iac_reval_output_asset ) IS
     l_path varchar2(150) := g_path||'display';
begin
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'++++++++++++++++++++++++++++++++++++++++++++++++');
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Adjusted cost '||p_info.adjusted_cost);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Operating Acc '||p_info.operating_acct);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Deprn amount  '||p_info.deprn_amount );
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Backlog       '||p_info.backlog_deprn_reserve);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Deprn Reserve '||p_info.deprn_reserve);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    General Fund  '||p_info.general_fund);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    Reval Reserve '||p_info.reval_reserve );
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    NBV           '||p_info.net_book_value );
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    current rate  '||p_info.current_reval_factor);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'    cumulve rate  '||p_info.cumulative_reval_factor);
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'++++++++++++++++++++++++++++++++++++++++++++++++');
end;

Function  Calculations  ( p_iac_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
                        , p_second_set in boolean
                        )
RETURN BOOLEAN IS
      p_iac_reval_params_old IGI_IAC_TYPES.iac_reval_params;
      l_reval_prev IGI_IAC_TYPES.iac_reval_output_asset;
      l_reval_curr IGI_IAC_TYPES.iac_reval_output_asset;
      l_reval_mvmt IGI_IAC_TYPES.iac_reval_output_asset;
      l_curr_rate  number  := 0;
      l_prev_rate  number  := 0;
      l_tran_rate  number  := 0;
      l_py_factor  number  := 0;
      l_salvage_value_correction number :=0;
      l_salvage_value_correction_ytd number :=0;
      l_path varchar2(150) := g_path||'Calculations';
BEGIN
      p_iac_reval_params_old := p_iac_reval_params;

      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin calculations');
      if not p_second_set then
          l_curr_rate := p_iac_reval_params.reval_curr_rate_info_first.cumulative_reval_factor;
          l_prev_rate := p_iac_reval_params.reval_prev_rate_info.cumulative_reval_factor;

      else
          l_curr_rate := p_iac_reval_params.reval_curr_rate_info_next.cumulative_reval_factor;
          l_prev_rate := p_iac_reval_params.reval_prev_rate_info.cumulative_reval_factor;
      end if;
      l_tran_rate := l_curr_rate/ l_prev_rate;

      l_py_factor := p_iac_reval_params.fa_asset_info.deprn_periods_prior_year /
                     p_iac_reval_params.fa_asset_info.deprn_periods_elapsed
      ;
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+calculations : l_curr_rate '|| l_curr_rate);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+calculations : l_prev_rate '|| l_prev_rate);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+calculations : l_tran_rate '|| l_tran_rate);

      /* Apply the prev cumm rate to the fa info */
      l_reval_prev := p_iac_reval_params.reval_input_asset;
      l_reval_curr := p_iac_reval_params.reval_input_asset;

         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' + calculations : deprn Resreve '|| 						p_iac_reval_params.fa_asset_info.deprn_reserve);
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+ calculations : YTD  '|| 						p_iac_reval_params.fa_asset_info.Ytd_deprn);

      if (p_iac_reval_params.reval_control.first_time_flag) then
          l_reval_prev.adjusted_cost           := ( l_prev_rate *  p_iac_reval_params.fa_asset_info.cost )
                                                                - p_iac_reval_params.fa_asset_info.cost ;
          do_round(l_reval_prev.adjusted_cost,p_iac_reval_params.reval_asset_params.book_type_code);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_prev.adjusted_cost :'|| l_reval_prev.adjusted_cost);

          if l_curr_rate >= 1 and l_prev_rate >= 1 then
             l_reval_prev.operating_acct          := 0;
          else
             l_reval_prev.operating_acct := l_reval_prev.adjusted_cost ;
          end if;

          p_iac_reval_params.reval_asset_params.prev_ytd_deprn := ( l_prev_rate * p_iac_reval_params.fa_asset_info.ytd_deprn)
                                              - p_iac_reval_params.fa_asset_info.ytd_deprn;
		  do_round(p_iac_reval_params.reval_asset_params.prev_ytd_deprn,p_iac_reval_params.reval_asset_params.book_type_code);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_iac_reval_params.reval_asset_params.prev_ytd_deprn :'|| p_iac_reval_params.reval_asset_params.prev_ytd_deprn);

          l_reval_prev.backlog_deprn_reserve   := (l_prev_rate - 1) *
                                                     ( p_iac_reval_params.fa_asset_info.deprn_reserve -
                                                       p_iac_reval_params.fa_asset_info.ytd_deprn)

                                                   /*) -
                                                      ( p_iac_reval_params.fa_asset_info.deprn_reserve -
                                                       p_iac_reval_params.fa_asset_info.ytd_deprn)*/ ;
          do_round(l_reval_prev.backlog_deprn_reserve,p_iac_reval_params.reval_asset_params.book_type_code);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_prev.backlog_deprn_reserve :'
                                                                  || l_reval_prev.backlog_deprn_reserve);

          if l_reval_prev.adjusted_cost >= 0 then
              l_reval_prev.general_fund            := p_iac_reval_params.reval_asset_params.prev_ytd_deprn ;
              l_reval_prev.reval_reserve           := l_reval_prev.adjusted_cost - l_reval_prev.backlog_deprn_reserve
                                                       - l_reval_prev.general_fund ;
          else
             l_reval_prev.reval_reserve           := 0 ;
             l_reval_prev.general_fund            := 0 ;
          end if;

          l_reval_prev.deprn_reserve           := ( l_prev_rate * p_iac_reval_params.fa_asset_info.deprn_reserve)
                                                  - p_iac_reval_params.fa_asset_info.deprn_reserve
                                                  - l_reval_prev.backlog_deprn_reserve;
          do_round(l_reval_prev.deprn_reserve,p_iac_reval_params.reval_asset_params.book_type_code);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_prev.deprn_reserve :'
                                                                  || l_reval_prev.deprn_reserve);


         l_reval_prev.net_book_value          := l_reval_prev.adjusted_cost - l_reval_prev.deprn_reserve
                                              - l_reval_prev.backlog_deprn_reserve;
      else
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+calculations : not the first time');
          p_iac_reval_params.reval_asset_params.prev_ytd_deprn := ( l_prev_rate * p_iac_reval_params.fa_asset_info.ytd_deprn)
                                              - p_iac_reval_params.fa_asset_info.ytd_deprn;
          do_round(p_iac_reval_params.reval_asset_params.prev_ytd_deprn,p_iac_reval_params.reval_asset_params.book_type_code);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'p_iac_reval_params.reval_asset_params.prev_ytd_deprn :'
                                                                  || p_iac_reval_params.reval_asset_params.prev_ytd_deprn);
      end if;

      /* Display prev record */
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'++++++++++++++++++++++++++++++++++++++++++++++++');
      if p_second_set then
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+++++++++++ SECOND SET : START +++++++++++');
      else
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'++++++++++++ FIRST  SET : START +++++++++++');
      end if;
      Do_round( l_reval_prev );
      Display( l_reval_prev );
      /* Apply the curr cumm rate to the fa info */
      l_reval_curr.adjusted_cost           := ( l_curr_rate *  p_iac_reval_params.fa_asset_info.cost )
                                                            - p_iac_reval_params.fa_asset_info.cost;
      do_round(l_reval_curr.adjusted_cost,p_iac_reval_params.reval_asset_params.book_type_code);

     IF  p_iac_reval_params.fa_asset_info.period_counter_fully_reserved IS NOT NULL
        AND p_iac_reval_params.reval_asset_params.period_counter > p_iac_reval_params.fa_asset_info.last_period_counter THEN
      l_reval_curr.deprn_amount := 0;
      l_reval_prev.deprn_amount := 0;
     ELSE
      l_reval_curr.deprn_amount            := ( l_curr_rate * p_iac_reval_params.fa_asset_info.deprn_amount)
                                              - p_iac_reval_params.fa_asset_info.deprn_amount;
      do_round(l_reval_curr.deprn_amount ,p_iac_reval_params.reval_asset_params.book_type_code);
     END IF;

     if p_second_set then
          p_iac_reval_params.reval_asset_params.curr_ytd_deprn_next
                                               := ( l_curr_rate * p_iac_reval_params.fa_asset_info.ytd_deprn)
                                                  - p_iac_reval_params.fa_asset_info.ytd_deprn;
          do_round(p_iac_reval_params.reval_asset_params.curr_ytd_deprn_next
                  ,p_iac_reval_params.reval_asset_params.book_type_code);

          p_iac_reval_params.reval_asset_params.ytd_deprn_mvmt :=
                                                p_iac_reval_params.reval_asset_params.curr_ytd_deprn_next -
                                                p_iac_reval_params.reval_asset_params.prev_ytd_deprn ;
     else
          p_iac_reval_params.reval_asset_params.curr_ytd_deprn_first
                                               := ( l_curr_rate * p_iac_reval_params.fa_asset_info.ytd_deprn)
                                                  - p_iac_reval_params.fa_asset_info.ytd_deprn;
          do_round(p_iac_reval_params.reval_asset_params.curr_ytd_deprn_first
                  ,p_iac_reval_params.reval_asset_params.book_type_code);

          p_iac_reval_params.reval_asset_params.ytd_deprn_mvmt :=
                                                p_iac_reval_params.reval_asset_params.curr_ytd_deprn_first -
                                                p_iac_reval_params.reval_asset_params.prev_ytd_deprn ;
     end if;
/* Backlog = movement in current revaluation * gross pyrs acc deprn
*/
     if l_py_factor <> 0 then
          declare
            l_blog number;
          begin

            l_blog  := ( p_iac_reval_params.fa_asset_info.deprn_reserve -
                                                       p_iac_reval_params.fa_asset_info.ytd_deprn) *
                        ( l_curr_rate - l_prev_rate );
            do_round(l_blog ,p_iac_reval_params.reval_asset_params.book_type_code);
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+current period backlog is '|| l_blog);
            l_reval_curr.backlog_deprn_reserve      :=  l_blog + l_reval_prev.backlog_deprn_reserve;
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+cumulative backlog is '|| 						l_reval_curr.backlog_deprn_reserve);
          end;
      else
          l_reval_curr.backlog_deprn_reserve := 0;
      end if;

      if l_curr_rate >= 1 and l_prev_rate >= 1 then
            l_reval_curr.general_fund            := l_reval_prev.general_fund +
                                      p_iac_reval_params.reval_asset_params.ytd_deprn_mvmt ;

            l_reval_curr.reval_reserve           := l_reval_curr.adjusted_cost - l_reval_curr.backlog_deprn_reserve
                                              - l_reval_curr.general_fund - l_reval_curr.operating_acct;
      else
          l_reval_curr.reval_reserve          := 0;
          l_reval_curr.operating_acct         := l_reval_curr.adjusted_cost - l_reval_curr.backlog_deprn_reserve
                                                - l_reval_curr.general_fund ;
      end if;

          l_reval_curr.deprn_reserve           := ( l_curr_rate * p_iac_reval_params.fa_asset_info.deprn_reserve)
                                              - p_iac_reval_params.fa_asset_info.deprn_reserve
											  - l_reval_curr.backlog_deprn_reserve;
          do_round(l_reval_curr.deprn_reserve ,p_iac_reval_params.reval_asset_params.book_type_code);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'l_reval_curr.deprn_reserve :'
                                                                  || l_reval_curr.deprn_reserve);

      l_reval_curr.net_book_value          := l_reval_curr.adjusted_cost - l_reval_curr.deprn_reserve
                                              - l_reval_curr.backlog_deprn_reserve;
      Do_round( p_info => l_reval_curr );
      /* put the differences in the asset mvmt table */
      -- note accounting entries are created from this mvmt table --
      if p_iac_reval_params.reval_control.first_time_flag then
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+first time flag is set.');
         l_reval_mvmt := l_reval_curr;
      else
          l_reval_mvmt.adjusted_cost           := l_reval_curr.adjusted_cost - l_reval_prev.adjusted_cost;
          l_reval_mvmt.operating_acct          := l_reval_curr.operating_acct - l_reval_prev.operating_acct;
          l_reval_mvmt.deprn_amount            := l_reval_curr.deprn_amount - l_reval_prev.deprn_amount;
          l_reval_mvmt.backlog_deprn_reserve   := l_reval_curr.backlog_deprn_reserve
                                                  - l_reval_prev.backlog_deprn_reserve;
          l_reval_mvmt.deprn_reserve           := l_reval_curr.deprn_reserve - l_reval_prev.deprn_reserve;
          l_reval_mvmt.general_fund            := l_reval_curr.general_fund - l_reval_prev.general_fund;
          l_reval_mvmt.reval_reserve           := l_reval_curr.reval_reserve - l_reval_prev.reval_reserve;
          l_reval_mvmt.net_book_value          := 0;
      end if;
      /* display results to the log file */
      Do_round ( p_info => l_reval_mvmt );
      if p_second_set then
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+++++++++++ SECOND SET :  REVAL MVMT ++++++++');
      else
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+++++++++++ FIRST  SET :  REVAL MVMT ++++++++');
      end if;

      Display ( p_info => l_reval_mvmt );
      if p_second_set then
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+++++++++++ SECOND SET :  REVAL END ++++++++');
      else
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+++++++++++ FIRST  SET :  REVAL END ++++++++');
      end if;
      Display ( p_info => l_reval_curr );
      if p_iac_reval_params.reval_control.first_time_flag then
         p_iac_reval_params.reval_input_asset    := l_reval_prev ;
      end if;
      p_iac_reval_params.reval_output_asset      := l_reval_curr  ;
      p_iac_reval_params.reval_output_asset.cumulative_reval_factor := l_curr_rate;
      p_iac_reval_params.reval_output_asset.current_reval_factor    := l_tran_rate;
      p_iac_reval_params.reval_output_asset_mvmt := l_reval_mvmt  ;
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end calculations');
      return TRUE;

exception when others then
  p_iac_reval_params := p_iac_reval_params_old;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return FALSE;
END;

Function  First_set_calculations  ( p_iac_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params )
RETURN BOOLEAN IS
    p_iac_reval_params_old IGI_IAC_TYPES.iac_reval_params;
    l_path varchar2(150) := g_path||'First_set_calculations';
BEGIN

  p_iac_reval_params_old := p_iac_reval_params;

  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin first set calculations');
  IF NOT Calculations ( p_iac_reval_params => p_iac_reval_params, p_second_set => false )
  THEN
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'error first set calculations');
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end  first set calculations');
    return false;
  END IF;
  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end  first set calculations');
  return TRUE;
exception when others then
  p_iac_reval_params := p_iac_reval_params_old;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return FALSE;
END;

Function  Next_set_calculations  ( p_iac_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params )
RETURN BOOLEAN IS
  p_iac_reval_params_old IGI_IAC_TYPES.iac_reval_params;
  l_path varchar2(150) := g_path||'Next_set_calculations';
BEGIN

  p_iac_reval_params_old := p_iac_reval_params;

  IF NOT Calculations ( p_iac_reval_params => p_iac_reval_params, p_second_set => true )
  THEN
    igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'error next set calculations');
    igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'end  next set calculations');
    return false;
  END IF;
  return TRUE;
exception when others then
  p_iac_reval_params := p_iac_reval_params_old;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return FALSE;
END;
/*
-- Get the rate information and then call Set_Calculations : FIRST  and  NEXT
*/

Function  Prepare_calculations (  p_iac_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params )
RETURN BOOLEAN IS
  p_iac_reval_params_old IGI_IAC_TYPES.iac_reval_params;
  l_path varchar2(150) := g_path||'Prepare_calculations';
BEGIN

  p_iac_reval_params_old := p_iac_reval_params;

   -- first split ratios (if revaluation is mixed!)
   IF NOT IGI_IAC_REVAL_UTILITIES.split_rates
          ( fp_asset_id                   => p_iac_reval_params.reval_asset_params.asset_id
          , fp_book_type_code             => p_iac_reval_params.reval_asset_params.book_type_code
          , fp_revaluation_id             => p_iac_reval_params.reval_asset_params.revaluation_id
          , fp_period_counter             => p_iac_reval_params.reval_asset_params.period_counter
          , fp_current_factor             => p_iac_reval_params.reval_asset_params.revaluation_rate
          , fp_reval_type                 => p_iac_reval_params.reval_asset_rules.revaluation_type
          , fp_first_time_flag            => p_iac_reval_params.reval_control.first_time_flag
          , fp_mixed_scenario             => p_iac_reval_params.reval_control.mixed_scenario
          , fp_reval_prev_rate_info       => p_iac_reval_params.reval_prev_rate_info
          , fp_reval_curr_rate_info_first => p_iac_reval_params.reval_curr_rate_info_first
          , fp_reval_curr_rate_info_next  => p_iac_reval_params.reval_curr_rate_info_next
          )
   THEN
       igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Unable to split rates!');
       return FALSE;
   END IF;

   return TRUE;
exception when others then
  p_iac_reval_params := p_iac_reval_params_old;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return FALSE;
END;

function swap ( fp_reval_params1 IN IGI_IAC_TYPES.iac_reval_params
              , fp_reval_params2 OUT NOCOPY IGI_IAC_TYPES.iac_reval_params
                  )
return boolean is
  fp_reval_params2_old IGI_IAC_TYPES.iac_reval_params;
  l_path varchar2(150) := g_path||'swap';
begin

  if  fp_reval_params1.reval_control.mixed_scenario then
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+intializing for the second set of calculations');
    fp_reval_params2                                                  := fp_reval_params1;
    fp_reval_params2.reval_control.first_time_flag                    := false;
    fp_reval_params2.reval_input_asset                                := fp_reval_params1.reval_output_asset;
    fp_reval_params2.reval_output_asset                               :=  fp_reval_params1.reval_output_asset;
    fp_reval_params2.reval_output_asset_mvmt.net_book_value           := 0;
    fp_reval_params2.reval_output_asset_mvmt.adjusted_cost            := 0;
    fp_reval_params2.reval_output_asset_mvmt.operating_acct           := 0;
    fp_reval_params2.reval_output_asset_mvmt.reval_reserve            := 0;
    fp_reval_params2.reval_output_asset_mvmt.deprn_amount             := 0;
    fp_reval_params2.reval_output_asset_mvmt.deprn_reserve            := 0;
    fp_reval_params2.reval_output_asset_mvmt.backlog_deprn_reserve    := 0;
    fp_reval_params2.reval_output_asset_mvmt.general_fund             := 0;
    fp_reval_params2.reval_output_asset_mvmt.current_reval_factor     := 1;
    fp_reval_params2.reval_output_asset_mvmt.cumulative_reval_factor  := 1;
    fp_reval_params2.reval_prev_rate_info                             :=  fp_reval_params1.reval_curr_rate_info_first;
    fp_reval_params2.reval_asset_params.prev_ytd_deprn := fp_reval_params1.reval_asset_params.prev_ytd_deprn ;
    fp_reval_params2.reval_asset_params.prev_ytd_opacc := fp_reval_params1.reval_asset_params.prev_ytd_opacc;
  end if;
  return true;
exception when others then
  fp_reval_params2 := fp_reval_params2_old;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return FALSE;
end;

END;



/
