--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_ACCOUNTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_ACCOUNTING" AS
-- $Header: igiiarab.pls 120.10.12000000.2 2007/10/16 14:22:33 sharoy ship $


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

  procedure create_acctg_entry   ( p_dr_ccid         in number
                                 , p_cr_ccid         in number
                                 , p_amount          in number
                                 , p_dr_adjust_type  in varchar2
                                 , p_cr_adjust_type  in varchar2
                                 , p_set_of_books_id in number
                                 , p_det_balances   in igi_iac_det_balances%rowtype
                                 , p_transfer_to_gl_flag in varchar2
                                 , p_event_id            in number         --R12 uptake
                                 )
  is
       l_rowid varchar2(30);
       l_units_assigned number;
       l_dr_ccid              number;
       l_cr_ccid              number;
       l_cr_report_ccid       number;
       l_dr_report_ccid       number;
       l_amount               number;
       l_dr_adjust_type varchar2(50);
       l_cr_adjust_type varchar2(50);

       l_path varchar2(100);
  begin
       l_rowid  := null;
       l_dr_ccid := p_dr_ccid;
       l_cr_ccid := p_cr_ccid;
       l_cr_report_ccid := Null;
       l_dr_report_ccid := Null;
       l_amount := p_amount;
       l_dr_adjust_type  := p_dr_adjust_type;
       l_cr_adjust_type  := p_cr_adjust_type;
       l_path  := g_path||'create_acctg_entry';

       if p_amount = 0 then
	  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+amount is 0, accounting entries skipped');
          return;
       end if;

       select units_assigned
       into   l_units_assigned
       from   fa_distribution_history
       where  book_type_code  = p_det_balances.book_type_code
         and  asset_id        = p_det_balances.asset_id
         and  distribution_id = p_det_balances.distribution_id
       ;

       /* begin bug 2448787 */
         if p_amount  < 0 then
               l_dr_ccid        := p_cr_ccid;
               l_cr_ccid        := p_dr_ccid;
               l_amount         := abs(p_amount);
               l_dr_adjust_type := p_cr_adjust_type;
               l_cr_adjust_type := p_dr_adjust_type;
         else
               l_dr_ccid        := p_dr_ccid;
               l_cr_ccid        := p_cr_ccid;
               l_amount         := p_amount;
               l_dr_adjust_type := p_dr_adjust_type;
               l_cr_adjust_type := p_cr_adjust_type;
         end if;
         /* end bug 2448787 */

        If (l_dr_adjust_type='REVAL RESERVE' OR l_dr_adjust_type='OP EXPENSE') THEN
          l_cr_report_ccid	:= l_dr_ccid;
	  l_dr_report_ccid	:= Null;
	Elsif (l_cr_adjust_type='REVAL RESERVE' OR l_cr_adjust_type='OP EXPENSE') THEN
	  l_cr_report_ccid	:= Null;
	  l_dr_report_ccid	:= l_cr_ccid;
        Else
          l_cr_report_ccid	:= Null;
          l_dr_report_ccid	:= Null;
        End if;


        IGI_IAC_ADJUSTMENTS_PKG.insert_row (
            x_rowid                   => l_rowid,
            x_adjustment_id           => p_det_balances.adjustment_id,
            x_book_type_code          => p_det_balances.book_type_code,
            x_code_combination_id     => l_dr_ccid,
            x_set_of_books_id         => p_set_of_books_id,
            x_dr_cr_flag              => 'DR',
            x_amount                  => l_amount,
            x_adjustment_type         => l_dr_adjust_type,
            x_transfer_to_gl_flag     => p_transfer_to_gl_flag,
            x_units_assigned          => l_units_assigned,
            x_asset_id                => p_det_balances.asset_id,
            x_distribution_id         => p_det_balances.distribution_id,
            x_period_counter          => p_det_balances.period_counter,
            X_adjustment_offset_type  => l_cr_adjust_type,
            X_report_ccid             => l_cr_ccid,
            x_mode                    => 'R',
            x_event_id                => p_event_id
            ) ;

        IGI_IAC_ADJUSTMENTS_PKG.insert_row (
            x_rowid                   => l_rowid,
            x_adjustment_id           => p_det_balances.adjustment_id,
            x_book_type_code          => p_det_balances.book_type_code,
            x_code_combination_id     => l_cr_ccid,
            x_set_of_books_id         => p_set_of_books_id,
            x_dr_cr_flag              => 'CR',
            x_amount                  => l_amount,
            x_adjustment_type         => l_cr_adjust_type,
            x_transfer_to_gl_flag     => p_transfer_to_gl_flag,
            x_units_assigned          => l_units_assigned,
            x_asset_id                => p_det_balances.asset_id,
            x_distribution_id         => p_det_balances.distribution_id,
            x_period_counter          => p_det_balances.period_counter,
            X_adjustment_offset_type  => l_dr_adjust_type,
            X_report_ccid             => l_dr_ccid,
            x_mode                    => 'R',
            x_event_id                => p_event_id
            ) ;

  end;

  function create_iac_acctg
         ( fp_det_balances in IGI_IAC_DET_BALANCES%ROWTYPE
          , fp_create_acctg_flag in boolean
          , p_event_id           in number   --R12 uptake
          )
  return boolean is
      l_rowid rowid;
      l_sob_id number;
      l_coa_id number;
      l_currency varchar2(30);
      l_precision number;
      l_dr_ccid  gl_code_combinations.code_combination_id%type;
      l_cr_ccid  gl_code_combinations.code_combination_id%type;
      l_revl_rsv_ccid gl_code_combinations.code_combination_id%type;
      l_blog_rsv_ccid gl_code_combinations.code_combination_id%TYPE;
      l_op_exp_ccid   gl_code_combinations.code_combination_id%TYPE;
      l_gen_fund_ccid gl_code_combinations.code_combination_id%TYPE;
      l_asset_cost_ccid gl_code_combinations.code_combination_id%TYPE;
      l_deprn_rsv_ccid gl_code_combinations.code_combination_id%TYPE;
      l_deprn_exp_ccid gl_code_combinations.code_combination_id%TYPE;
      l_transfer_to_gl_flag varchar2(1);
      l_create_extra_entry varchar2(1);
      l_ignore_expense_entry varchar2(1);

      l_path varchar2(100);

      procedure check_ccid ( p_ccid_desc in varchar2) is
      l_path varchar2(100);
      begin
        l_path  := g_path||'creck_ccid';
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation for '||p_ccid_desc||' failed');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'error create_iac_acctg');
      end;
    begin
      l_create_extra_entry := 'N';
      l_ignore_expense_entry := 'N';

      l_path := g_path||'create_iac_acctg';

      declare
         cursor c_txn_type is
           select transaction_type_code
           from   igi_iac_transaction_headers
           where  adjustment_id = fp_det_balances.adjustment_id
           ;
       begin
          for l_type in c_txn_type loop
             if l_type.transaction_type_code in ( 'ADDITION','RECLASS') then
                l_transfer_to_gl_flag := 'Y';
                l_create_extra_entry := 'Y';
                if l_type.transaction_type_code = 'RECLASS'
                and  nvl(fp_det_balances.active_flag,'Y') = 'N'
                then
                   l_ignore_expense_entry := 'Y';
                else
                   l_ignore_expense_entry := 'N';
                end if;
             else
                l_create_extra_entry  := 'N';
                l_transfer_to_gl_flag := 'N';
                l_ignore_expense_entry := 'N';
             end if;
          end loop;
       exception when others then
          l_transfer_to_gl_flag := 'N';
       end;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin create_iac_acctg');
       if not fp_create_acctg_flag then
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation not allowed');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end create_iac_acctg');
          return true;
       end if;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation get gl information');
       if not IGI_IAC_COMMON_UTILS.GET_BOOK_GL_INFO
              ( X_BOOK_TYPE_CODE      => fp_det_balances.book_type_code
              , SET_OF_BOOKS_ID       => l_sob_id
              , CHART_OF_ACCOUNTS_ID  => l_coa_id
              , CURRENCY              => l_currency
              , PRECISION             => l_precision
              )
       then
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation unable to get gl info');
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end create_iac_acctg');
          return false;
       end if;
       --
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation get all accounts');
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+distribution id '|| fp_det_balances.distribution_id);
       IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    , X_account_type    => 'REVAL_RESERVE_ACCT'
                    , account_ccid      => l_revl_rsv_ccid
                    )
       THEN
          check_ccid ( 'reval reserve');
          return false;
       END IF;
      IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    , X_account_type    => 'BACKLOG_DEPRN_RSV_ACCT'
                    , account_ccid      => l_blog_rsv_ccid
                    )
       THEN
          check_ccid ( 'backlog deprn reserve');
          return false;
       END IF;
       IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    , X_account_type    => 'OPERATING_EXPENSE_ACCT'
                    , account_ccid      => l_op_exp_ccid
                    )
       THEN
          check_ccid ( 'operating account');
          return false;
       END IF;
        IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    , X_account_type    => 'GENERAL_FUND_ACCT'
                    , account_ccid      => l_gen_fund_ccid
                    )
       THEN
          check_ccid ( 'general fund account');
          return false;
       END IF;
        IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    , X_account_type    => 'ASSET_COST_ACCT'
                    , account_ccid      => l_asset_cost_ccid
                    )
       THEN
          check_ccid ( 'asset cost account');
          return false;
       END IF;
       IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    , X_account_type    => 'DEPRN_RESERVE_ACCT'
                    , account_ccid      => l_deprn_rsv_ccid
                   )
       THEN
          check_ccid ( 'deprn reserve account');
          return false;
       END IF;
       IF NOT IGI_IAC_COMMON_UTILS.get_account_ccid
                    ( X_book_type_code => fp_det_balances.book_type_code
                    , X_asset_id       => fp_det_balances.asset_id
                    , X_distribution_id => fp_det_balances.distribution_id
                    , X_account_type    => 'DEPRN_EXPENSE_ACCT'
                    , account_ccid      => l_deprn_exp_ccid
                    )
       THEN
          check_ccid ( 'deprn reserve account');
          return false;
       END IF;

       begin
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation cost vs reval reserve');
         create_acctg_entry (  p_dr_ccid   =>    l_asset_cost_ccid
                             , p_cr_ccid   =>    l_revl_rsv_ccid
                             , p_amount    =>    fp_det_balances.reval_reserve_cost
                             , p_dr_adjust_type  => 'COST'
                             , p_cr_adjust_type  => 'REVAL RESERVE'
                             , p_set_of_books_id => l_sob_id
                             , p_det_balances   => fp_det_balances
                             , p_transfer_to_gl_flag => l_transfer_to_gl_flag
                             , p_event_id            => p_event_id
                             );
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation reval reserve vs backlog reserve');
         create_acctg_entry (  p_dr_ccid   =>    l_revl_rsv_ccid
                             , p_cr_ccid   =>    l_blog_rsv_ccid
                             , p_amount    =>    fp_det_balances.reval_reserve_backlog
                             , p_dr_adjust_type  => 'REVAL RESERVE'
                             , p_cr_adjust_type  => 'BL RESERVE'
                             , p_set_of_books_id => l_sob_id
                             , p_det_balances   => fp_det_balances
                             , p_transfer_to_gl_flag => l_transfer_to_gl_flag
                             , p_event_id            => p_event_id
                             );
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation reval reserve vs gen fund');
         create_acctg_entry (  p_dr_ccid   =>    l_revl_rsv_ccid
                             , p_cr_ccid   =>    l_gen_fund_ccid
                             , p_amount    =>    fp_det_balances.reval_reserve_gen_fund
                             , p_dr_adjust_type  => 'REVAL RESERVE'
                             , p_cr_adjust_type  => 'GENERAL FUND'
                             , p_set_of_books_id => l_sob_id
                             , p_det_balances   => fp_det_balances
                             , p_transfer_to_gl_flag => l_transfer_to_gl_flag
                             , p_event_id            => p_event_id
                             );
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation op expense vs cost :neg figures');
         create_acctg_entry (  p_cr_ccid   =>    l_op_exp_ccid
                             , p_dr_ccid   =>    l_asset_cost_ccid
                             , p_amount    =>    fp_det_balances.operating_acct_cost
                             , p_cr_adjust_type  => 'OP EXPENSE'
                             , p_dr_adjust_type  => 'COST'
                             , p_set_of_books_id => l_sob_id
                             , p_det_balances   => fp_det_balances
                             , p_transfer_to_gl_flag => l_transfer_to_gl_flag
                             , p_event_id            => p_event_id
                             );
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation backlog vs op expense :neg figures');
         create_acctg_entry (  p_cr_ccid   =>    l_blog_rsv_ccid
                             , p_dr_ccid   =>    l_op_exp_ccid
                             , p_amount    =>    fp_det_balances.operating_acct_backlog
                             , p_cr_adjust_type  => 'BL RESERVE'
                             , p_dr_adjust_type  => 'OP EXPENSE'
                             , p_set_of_books_id => l_sob_id
                             , p_det_balances   => fp_det_balances
                             , p_transfer_to_gl_flag => l_transfer_to_gl_flag
                             , p_event_id            => p_event_id
                             );
         /* If reclass and old dist, supress the ytd deprn creation */
         if l_ignore_expense_entry = 'Y' then
            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end acctg creation');
            return true;
         end if;
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation deprn reserve vs deprn expense');
         create_acctg_entry (  p_cr_ccid   =>    l_deprn_rsv_ccid
                                 , p_dr_ccid   =>    l_deprn_exp_ccid
                                 , p_amount    =>    fp_det_balances.deprn_ytd
                                 , p_dr_adjust_type  => 'EXPENSE'
                                 , p_cr_adjust_type  => 'RESERVE'
                                 , p_set_of_books_id => l_sob_id
                                 , p_det_balances   => fp_det_balances
                                 , p_transfer_to_gl_flag => l_transfer_to_gl_flag
                                 , p_event_id            => p_event_id
                                 );
             if l_create_extra_entry = 'Y' then
                 igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+acctg creation (catchup) deprn reserve vs deprn expense');
                 create_acctg_entry (  p_cr_ccid   =>    l_deprn_rsv_ccid
                                     , p_dr_ccid   =>    l_deprn_exp_ccid
                                     , p_amount    =>    fp_det_balances.deprn_reserve - fp_det_balances.deprn_ytd
                                     , p_dr_adjust_type  => 'EXPENSE'
                                     , p_cr_adjust_type  => 'RESERVE'
                                     , p_set_of_books_id => l_sob_id
                                     , p_det_balances   => fp_det_balances
                                     , p_transfer_to_gl_flag => l_transfer_to_gl_flag
                                     , p_event_id            => p_event_id
                                     );
             end if;
       end;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end acctg creation');
       return true;
    end;
BEGIN
    --===========================FND_LOG.START=====================================
    g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
    g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path          := 'IGI.PLSQL.igiiarab.IGI_IAC_REVAL_ACCOUNTING.';
    --===========================FND_LOG.END=======================================

END;

/
