--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_IMPL_CRUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_IMPL_CRUD" AS
-- $Header: igiiarpb.pls 120.7.12000000.1 2007/08/01 16:17:42 npandya ship $


--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiarpb.IGI_IAC_REVAL_IMPL_CRUD.';

--===========================FND_LOG.END=======================================

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

     cursor c_exists ( cp_asset_id        in number
                , cp_book_type_code  in varchar2
                ) is
     select cumulative_reval_factor, current_reval_factor
     from   igi_iac_asset_balances
     where  asset_id       = cp_asset_id
       and  book_type_code = cp_book_type_code
     ;
    procedure do_commit is
    begin
        if IGI_IAC_REVAL_UTILITIES.debug then
           rollback;
        else
            commit;
        end if;
    end;

    function create_py_add_entry ( fp_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
        ,   fp_second_set   in boolean )
    return boolean is
       g_user_id    number := fnd_global.user_id;
       g_date       date   := sysdate;
       g_login_id   number := fnd_global.login_id;
       g_request_id number := -1;
       l_asset_number fa_additions.asset_number%TYPE;

       l_path varchar2(100) := g_path||'create_py_add_entry';
    begin

     for l_chk in c_exists
               ( cp_asset_id       =>  fp_reval_params.reval_asset_params.asset_id
                , cp_book_type_code  => fp_reval_params.reval_asset_params.book_type_code
                )
     loop
         return true;
     end loop;

     delete from igi_imp_iac_interface_py_add
     where  asset_id = fp_reval_params.reval_asset_params.asset_id
     and    book_type_code = fp_reval_params.reval_asset_params.book_type_code
     ;

     select asset_number
     into   l_asset_number
     from   fa_additions
     where   asset_id = fp_reval_params.reval_asset_params.asset_id
     ;

     insert into IGI_IMP_IAC_INTERFACE_PY_ADD (
            ASSET_ID
         , ASSET_NUMBER
         , BOOK_TYPE_CODE
         , CATEGORY_ID
         , PERIOD_COUNTER
         , NET_BOOK_VALUE
         , ADJUSTED_COST
         , OPERATING_ACCT
         , REVAL_RESERVE
         , DEPRN_AMOUNT
         , DEPRN_RESERVE
         , BACKLOG_DEPRN_RESERVE
         , GENERAL_FUND
         , LAST_REVAL_DATE
         , CURRENT_REVAL_FACTOR
         , CUMMULATIVE_REVAL_FACTOR
         , HIST_COST
         , HIST_DEPRN_EXPENSE
         , HIST_YTD
         , HIST_ACCUM_DEPRN
         , HIST_LIFE_IN_MONTHS
         , HIST_NBV
         , HIST_SALVAGE_VALUE
         , GENERAL_FUND_PERIODIC
         , OPERATING_ACCOUNT_YTD
         , CREATED_BY
         , CREATION_DATE
         , LAST_UPDATED_BY
         , LAST_UPDATE_DATE
         , LAST_UPDATE_LOGIN
         , REQUEST_ID
         , PROGRAM_APPLICATION_ID
         , PROGRAM_ID
         , PROGRAM_UPDATE_DATE
         )  values (
           fp_reval_params.reval_asset_params.asset_id
         , l_asset_number
         , fp_reval_params.reval_asset_params.book_type_code -- BOOK_TYPE_CODE
         , fp_reval_params.reval_asset_params.category_id
         ,  fp_reval_params.reval_asset_params.period_counter
         , fp_reval_params.reval_output_asset.net_book_value
         , fp_reval_params.reval_output_asset.adjusted_cost
         , fp_reval_params.reval_output_asset.operating_acct
         , fp_reval_params.reval_output_asset.reval_reserve
         , fp_reval_params.reval_output_asset.deprn_amount
         , fp_reval_params.reval_output_asset.deprn_reserve
         , fp_reval_params.reval_output_asset.backlog_deprn_reserve
         , fp_reval_params.reval_output_asset.general_fund
         , fp_reval_params.reval_asset_params.revaluation_date
         , fp_reval_params.reval_output_asset.current_reval_factor
         , fp_reval_params.reval_output_asset.cumulative_reval_factor
         , fp_reval_params.fa_asset_info.cost
         , fp_reval_params.fa_asset_info.deprn_amount
         , fp_reval_params.fa_asset_info.ytd_deprn
         , fp_reval_params.fa_asset_info.deprn_reserve
         , fp_reval_params.fa_asset_info.life_in_months
         , fp_reval_params.fa_asset_info.cost -
           fp_reval_params.fa_asset_info.deprn_reserve
         , fp_reval_params.fa_asset_info.salvage_value
         , fp_reval_params.reval_output_asset.GENERAL_FUND
         , fp_reval_params.reval_output_asset.operating_acct
         , g_user_id
         , g_date
         , g_user_id
         , g_date
         , g_login_id
         , g_request_id
         , 8400
         , 8400
         , g_date
         ) ;

         return true;

    exception when others then
      igi_iac_debug_pkg.debug_unexpected_msg(l_path);
      return false;
    end;

    function crud_iac_tables
         ( fp_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
        ,   fp_second_set   in boolean )
    return boolean is
    l_path varchar2(100) := g_path||'crud_iac_tables';
    begin

       if not fp_reval_params.reval_control.crud_allowed then
	  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+implementation : create, update or delete is not allowed.');
          return true;
       end if;

       if  not nvl(fp_reval_params.reval_control.calling_program,'REVALUATION')
           in ('UPGRADE','IMPLEMENTATION')
       then
	  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+implementation : create, update or delete is not allowed.');
          return true;
       end if;

       if not create_py_add_entry ( fp_reval_params => fp_reval_params
                                  ,   fp_second_set => fp_second_set
                                  )
       then
	  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+implementation : unable to create py add entry');
          return false;
       end if;

       return true;
    end;

END;

/
