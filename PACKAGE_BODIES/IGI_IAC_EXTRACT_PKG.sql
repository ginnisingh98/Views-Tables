--------------------------------------------------------
--  DDL for Package Body IGI_IAC_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_EXTRACT_PKG" AS
/* $Header: igiacexb.pls 120.3.12010000.2 2009/03/04 11:58:45 vensubra ship $ */
--===========================FND_LOG.START=====================================

g_state_level NUMBER	  ;
g_proc_level  NUMBER	  ;
g_event_level NUMBER	  ;
g_excep_level NUMBER	  ;
g_error_level NUMBER	  ;
g_unexp_level NUMBER	  ;
g_path        VARCHAR2(1000) ;

--===========================FND_LOG.END=====================================

PROCEDURE extract
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2) IS

Begin
   extract_revaluations(p_application_id,p_accounting_mode);
   extract_transactions(p_application_id,p_accounting_mode);
   --extract_deprn(p_application_id,p_accounting_mode);
End extract;

PROCEDURE extract_revaluations
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2) IS

   l_procedure_name  varchar2(80) := 'extract_revaluations';
   l_path_name varchar2(2000);

   cursor all_events is
    select * from xla_events_gt
    where entity_code           = 'TRANSACTIONS'
    and  event_type_code       = 'INFLATION_REVALUATION';

   cursor fa_header (p_event_id number,
                      p_reval_id number,
                      p_book_type_code varchar2) is
    SELECT
          th.EVENT_ID                             ,
          bc.BOOK_TYPE_CODE                          ,
          bc.BOOK_TYPE_NAME                          ,
          bc.ORG_ID                                  ,
          th.revaluation_period                      ,
          decode(bc.GL_POSTING_ALLOWED_FLAG,'YES', 'Y', 'N') gl_transfer_flag,
          th.revaluation_date acc_date -- Bug 8297092
      FROM fa_book_controls              bc,
           igi_iac_revaluations         th
     WHERE th.book_type_code = bc.book_type_code
	   and th.book_type_code = p_book_type_code
       and th.event_id = p_event_id
       AND th.revaluation_id    = p_reval_id;

    cursor fa_igi_lines (p_event_id number,
                         p_book_type_code varchar2) is
   select
   adj.event_id,
   adj.book_type_code,
   th.category_id,
   adj.asset_id,
   adj.distribution_id,
   adj.set_of_books_id,
   adj.adjustment_id,
   amount_switch(adj.adjustment_type,adj.dr_cr_flag,adj.amount) amount,
   adj.dr_cr_flag,
   adj.adjustment_type,
   adj.transfer_to_gl_flag,
   adj.units_assigned,
   adj.period_counter,
   adj.adjustment_offset_type,
   adj.report_ccid,
   th.transaction_header_id,
   th.adjustment_id_out,
   th.transaction_type_code,
   th.transaction_sub_type,
   th.transaction_date_entered,
   th.mass_reference_id,
   th.adj_deprn_start_date,
   th.adjustment_status,
   th.revaluation_type_flag,
   lkp_adj.meaning adj_meaning,
   lkp_trn.meaning trn_meaning,
   decode(adj.adjustment_type,'BL RESERVE',code_combination_id,null) BL_RESERVE,
   decode(adj.adjustment_type,'OP EXPENSE',code_combination_id,null) OP_EXPENSE,
   decode(adj.adjustment_type,'GENERAL FUND',code_combination_id,null) GENERAL_FUND,
   decode(adj.adjustment_type,'REVAL RESERVE',code_combination_id,null) REVAL_RESERVE,
   decode(adj.adjustment_type,'REVAL RSV RET',code_combination_id,null) REVAL_RSV_RET,
   decode(adj.adjustment_type,'INTERCO AP',code_combination_id,null) INTERCO_AP,
   decode(adj.adjustment_type,'INTERCO AR',code_combination_id,null) INTERCO_AR,
   decode(adj.adjustment_type,'COST',code_combination_id,null) COST,
   decode(adj.adjustment_type,'RESERVE',code_combination_id,null) RESERVE,
   decode(adj.adjustment_type,'EXPENSE',code_combination_id,null) EXPENSE,
   decode(adj.adjustment_type,'NBV RETIRED',code_combination_id,null) NBV_RETIRED,
   sob.currency_code
   from igi_iac_adjustments adj, igi_iac_transaction_headers th,
   igi_lookups lkp_adj, igi_lookups lkp_trn, gl_sets_of_books sob
   where adj.adjustment_id = th.adjustment_id
   and adj.event_id = th.event_id
   and lkp_adj.lookup_type = 'IGI_IAC_ADJUSTMENT_TYPES'
   and lkp_trn.lookup_type = 'IGI_IAC_TRANSACTION_TYPES'
   and adj.adjustment_type = lkp_adj.lookup_code
   and th.transaction_type_code = lkp_trn.lookup_code
   and th.book_type_code = p_book_type_code
   and th.event_id = p_event_id
   and adj.set_of_books_id = sob.set_of_books_id
   and adj.transfer_to_gl_flag = 'Y';

   v_counter number := 0;

BEGIN
   l_path_name := g_path || l_procedure_name;
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
         p_full_path => l_path_name,
         p_string => 'extract_revaluation....Welcome... ');

   for i in all_events loop
   --Extract Fa transaction header object
     for j in fa_header(i.event_id,i.source_id_int_1,i.valuation_method) loop
          INSERT INTO FA_XLA_EXT_HEADERS_B_GT (
          event_id                                ,
          BOOK_TYPE_CODE                          ,
          BOOK_DESCRIPTION                        ,
          ORG_ID                                  ,
          PERIOD_COUNTER                          ,
          TRANSFER_TO_GL_FLAG                     ,
          accounting_date                         )
          values (
          j.EVENT_ID                             ,
          j.BOOK_TYPE_CODE                          ,
          j.BOOK_TYPE_NAME                          ,
          j.ORG_ID                                  ,
          j.revaluation_period                      ,
          j.gl_transfer_flag,
          j.acc_date );
     end loop; --j

    --Extract Fa transaction lines object
    v_counter := 1;
    for k in fa_igi_lines (i.event_id,i.valuation_method) loop
      INSERT INTO FA_XLA_EXT_LINES_B_GT(
          EVENT_ID                             ,
          LINE_NUMBER                          ,
          DISTRIBUTION_TYPE_CODE               ,
          transaction_header_id                ,
          adjustment_line_id                   ,
          LEDGER_ID                            ,
          BOOK_TYPE_CODE                       ,
          ASSET_ID                             ,
          CAT_ID                               ,
          entered_amount                       ,
          currency_code)
      values (
          k.event_id,
          v_counter,
          'TRX',
          k.adjustment_id,
          v_counter,
          k.set_of_books_id,
          k.book_type_code,
          k.asset_id,
          k.category_id,
          k.amount,
          k.currency_code);

         --Extract IAC reference lines object
         insert into igi_iac_xla_lines_gt (
            IAC_EVENT_ID,
            IAC_LINE_NUMBER,
            IAC_BOOK_TYPE_CODE,
            IAC_CATEGORY_ID,
            IAC_ASSET_ID,
            IAC_DISTRIBUTION_ID,
            IAC_LEDGER_ID,
            IAC_ADJUSTMENT_ID,
            IAC_AMOUNT,
            IAC_DR_CR_FLAG,
            IAC_ADJUSTMENT_TYPE,
            IAC_TRANSFER_TO_GL_FLAG,
            IAC_UNITS_ASSIGNED,
            IAC_PERIOD_COUNTER,
            IAC_ADJUSTMENT_OFFSET_TYPE,
            IAC_REPORT_CCID,
            IAC_TRANSACTION_HEADER_ID,
            IAC_ADJUSTMENT_ID_OUT,
            IAC_TRANSACTION_TYPE_CODE,
            IAC_TRANSACTION_SUB_TYPE,
            IAC_TRANSACTION_DATE_ENTERED,
            IAC_MASS_REFERENCE_ID,
            IAC_ADJ_DEPRN_START_DATE,
            IAC_ADJUSTMENT_STATUS,
            IAC_REVALUATION_TYPE_FLAG,
            IAC_ADJUSTMENT_TYPE_MEANING,
            IAC_TRANSACTION_TYPE_MEANING,
            IAC_BACKLOG_DEPRN_RSV_CCID,
            IAC_OPERATING_EXPENSE_CCID,
            IAC_GENERAL_FUND_CCID,
            IAC_REVAL_RESERVE_CCID,
            IAC_REVAL_RESERVE_RET_CCID,
            IAC_INTERCO_AP_CCID,
            IAC_INTERCO_AR_CCID,
            IAC_ASSET_COST_CCID,
            IAC_DEPRN_RESERVE_CCID,
            IAC_DEPRN_EXPENSE_CCID,
            IAC_NBV_RETIRED_GAIN_CCID,
            IAC_CURRENCY_CODE)
            values (
            k.event_id,
            v_counter,
            k.book_type_code,
            k.category_id,
            k.asset_id,
            k.distribution_id,
            k.set_of_books_id,
            k.adjustment_id,
            k.amount,
            k.dr_cr_flag,
            k.adjustment_type,
            k.transfer_to_gl_flag,
            k.units_assigned,
            k.period_counter,
            k.adjustment_offset_type,
            k.report_ccid,
            k.transaction_header_id,
            k.adjustment_id_out,
            k.transaction_type_code,
            k.transaction_sub_type,
            k.transaction_date_entered,
            k.mass_reference_id,
            k.adj_deprn_start_date,
            k.adjustment_status,
            k.revaluation_type_flag,
            k.adj_meaning,
            k.trn_meaning,
            k.BL_RESERVE,
            k.OP_EXPENSE,
            k.GENERAL_FUND,
            k.REVAL_RESERVE,
            k.REVAL_RSV_RET,
            k.INTERCO_AP,
            k.INTERCO_AR,
            k.COST,
            k.RESERVE,
            k.EXPENSE,
            k.NBV_RETIRED,
            k.currency_code);
            v_counter := v_counter + 1;
       end loop; --k
  end loop; --i

   --Debug
   /*delete from igi_iac_xla_lines_gt_tmp;
   insert into igi_iac_xla_lines_gt_tmp
   select * from igi_iac_xla_lines_gt;

   delete from FA_XLA_EXT_HEADERS_B_GT_tmp;
   insert into FA_XLA_EXT_HEADERS_B_GT_tmp
   select * from FA_XLA_EXT_HEADERS_B_GT;

   delete from FA_XLA_EXT_LINES_B_GT_tmp;
   INSERT INTO FA_XLA_EXT_LINES_B_GT_tmp
   select * from FA_XLA_EXT_LINES_B_GT;*/
    --Debug


     igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
     p_full_path => l_path_name,
     p_string => 'extract_revaluations....Bye... ');


END extract_revaluations;

PROCEDURE extract_transactions
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2) IS

   l_procedure_name  varchar2(80) := 'extract_transactions';
   l_path_name varchar2(2000);

    cursor all_events is
    select * from xla_events_gt
    where entity_code in ('TRANSACTIONS','DEPRECIATION')
    and event_type_code in ('ADDITIONS','ADJUSTMENTS','TRANSFERS',
                            'CATEGORY_RECLASS', 'RETIREMENTS','REINSTATEMENTS','DEPRECIATION');
   cursor fa_igi_lines (p_event_id number,p_book_type_code varchar2) is
   select
   adj.event_id,
   adj.book_type_code,
   th.category_id,
   adj.asset_id,
   adj.distribution_id,
   adj.set_of_books_id,
   adj.adjustment_id,
   amount_switch(adj.adjustment_type,adj.dr_cr_flag,adj.amount) amount,
   adj.dr_cr_flag,
   adj.adjustment_type,
   adj.transfer_to_gl_flag,
   adj.units_assigned,
   adj.period_counter,
   adj.adjustment_offset_type,
   adj.report_ccid,
   th.transaction_header_id,
   th.adjustment_id_out,
   th.transaction_type_code,
   th.transaction_sub_type,
   th.transaction_date_entered,
   th.mass_reference_id,
   th.adj_deprn_start_date,
   th.adjustment_status,
   th.revaluation_type_flag,
   lkp_adj.meaning adj_meaning,
   lkp_trn.meaning trn_meaning,
   decode(adj.adjustment_type,'BL RESERVE',code_combination_id,null) BL_RESERVE,
   decode(adj.adjustment_type,'OP EXPENSE',code_combination_id,null) OP_EXPENSE,
   decode(adj.adjustment_type,'GENERAL FUND',code_combination_id,null) GENERAL_FUND,
   decode(adj.adjustment_type,'REVAL RESERVE',code_combination_id,null) REVAL_RESERVE,
   decode(adj.adjustment_type,'REVAL RSV RET',code_combination_id,null) REVAL_RSV_RET,
   decode(adj.adjustment_type,'INTERCO AP',code_combination_id,null) INTERCO_AP,
   decode(adj.adjustment_type,'INTERCO AR',code_combination_id,null) INTERCO_AR,
   decode(adj.adjustment_type,'COST',code_combination_id,null) COST,
   decode(adj.adjustment_type,'RESERVE',code_combination_id,null) RESERVE,
   decode(adj.adjustment_type,'EXPENSE',code_combination_id,null) EXPENSE,
   decode(adj.adjustment_type,'NBV RETIRED',code_combination_id,null) NBV_RETIRED,
   sob.currency_code
   from igi_iac_adjustments adj, igi_iac_transaction_headers th,
   igi_lookups lkp_adj, igi_lookups lkp_trn, gl_sets_of_books sob
   where adj.adjustment_id = th.adjustment_id
   and adj.event_id = th.event_id
   and lkp_adj.lookup_type = 'IGI_IAC_ADJUSTMENT_TYPES'
   and lkp_trn.lookup_type = 'IGI_IAC_TRANSACTION_TYPES'
   and adj.adjustment_type = lkp_adj.lookup_code
   and th.transaction_type_code = lkp_trn.lookup_code
   and th.book_type_code = p_book_type_code
   and th.event_id = p_event_id
   and adj.set_of_books_id = sob.set_of_books_id
   and adj.transfer_to_gl_flag = 'Y';

   v_counter number;


BEGIN
   l_path_name := g_path || l_procedure_name;
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
      p_full_path => l_path_name,
      p_string => 'extract_transactions....Welcome... ');
     --Extract IAC reference lines object
   for i in all_events loop

    select max(line_number) +1 into v_counter
    from FA_XLA_EXT_LINES_B_GT where
    event_id = i.event_id ;



    for k in fa_igi_lines (i.event_id,i.valuation_method) loop
      /*INSERT INTO FA_XLA_EXT_LINES_B_GT(
          EVENT_ID                             ,
          LINE_NUMBER                          ,
          DISTRIBUTION_TYPE_CODE               ,
          ledger_id,
          ASSET_ID                             ,
          deprn_run_id                         ,
          BOOK_TYPE_CODE                       ,
          distribution_id                      ,
          entered_amount                       ,
          currency_code
          )
      values (
          k.event_id,
          v_counter,
          'IAC',
          k.set_of_books_id,
          k.asset_id,
                   1,
          k.book_type_code,
          k.distribution_id,
          1,'USD');*/

           insert into fa_xla_ext_lines_b_gt (
           EVENT_ID                             ,
           LINE_NUMBER                          ,
           DISTRIBUTION_TYPE_CODE               ,
           LEDGER_ID                            ,
           CURRENCY_CODE                        ,
           ENTERED_AMOUNT                       ,
           BONUS_ENTERED_AMOUNT                 ,
           REVAL_ENTERED_AMOUNT                 ,
           GENERATED_CCID                       ,
           GENERATED_OFFSET_CCID                ,
           BONUS_GENERATED_CCID                 ,
           BONUS_GENERATED_OFFSET_CCID          ,
           REVAL_GENERATED_CCID                 ,
           REVAL_GENERATED_OFFSET_CCID          ,
           BOOK_TYPE_CODE                       ,
           ASSET_ID,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           DEPRN_RESERVE_ACCT,
           REVAL_AMORT_ACCT,
           REVAL_RESERVE_ACCT,
           DEPRN_RUN_ID,
           DISTRIBUTION_ID,
           EXPENSE_ACCOUNT_CCID,
           TRANSACTION_HEADER_ID,
	   ADJUSTMENT_LINE_ID)
    select EVENT_ID                             ,
           v_counter                    ,
           'IAC'               ,
           LEDGER_ID                            ,
           CURRENCY_CODE                        ,
           ENTERED_AMOUNT                       ,
           BONUS_ENTERED_AMOUNT                 ,
           REVAL_ENTERED_AMOUNT                 ,
           GENERATED_CCID                       ,
           GENERATED_OFFSET_CCID                ,
           BONUS_GENERATED_CCID                 ,
           BONUS_GENERATED_OFFSET_CCID          ,
           REVAL_GENERATED_CCID                 ,
           REVAL_GENERATED_OFFSET_CCID          ,
           BOOK_TYPE_CODE                       ,
           ASSET_ID,
           BONUS_DEPRN_EXPENSE_ACCT,
           BONUS_RESERVE_ACCT,
           DEPRN_RESERVE_ACCT,
           REVAL_AMORT_ACCT,
           REVAL_RESERVE_ACCT,
           DEPRN_RUN_ID,
           DISTRIBUTION_ID,
           EXPENSE_ACCOUNT_CCID,
           TRANSACTION_HEADER_ID,
	   ADJUSTMENT_LINE_ID
           from fa_xla_ext_lines_b_gt
           where event_id = i.event_id
           and rownum = 1;

     insert into igi_iac_xla_lines_gt (
     IAC_EVENT_ID,
   IAC_LINE_NUMBER,
   IAC_BOOK_TYPE_CODE,
   IAC_CATEGORY_ID,
   IAC_ASSET_ID,
   IAC_DISTRIBUTION_ID,
   IAC_LEDGER_ID,
   IAC_ADJUSTMENT_ID,
   IAC_AMOUNT,
   IAC_DR_CR_FLAG,
   IAC_ADJUSTMENT_TYPE,
   IAC_TRANSFER_TO_GL_FLAG,
   IAC_UNITS_ASSIGNED,
   IAC_PERIOD_COUNTER,
   IAC_ADJUSTMENT_OFFSET_TYPE,
   IAC_REPORT_CCID,
   IAC_TRANSACTION_HEADER_ID,
   IAC_ADJUSTMENT_ID_OUT,
   IAC_TRANSACTION_TYPE_CODE,
   IAC_TRANSACTION_SUB_TYPE,
   IAC_TRANSACTION_DATE_ENTERED,
   IAC_MASS_REFERENCE_ID,
   IAC_ADJ_DEPRN_START_DATE,
   IAC_ADJUSTMENT_STATUS,
   IAC_REVALUATION_TYPE_FLAG,
   IAC_ADJUSTMENT_TYPE_MEANING,
   IAC_TRANSACTION_TYPE_MEANING,
   IAC_BACKLOG_DEPRN_RSV_CCID,
   IAC_OPERATING_EXPENSE_CCID,
   IAC_GENERAL_FUND_CCID,
   IAC_REVAL_RESERVE_CCID,
   IAC_REVAL_RESERVE_RET_CCID,
   IAC_INTERCO_AP_CCID,
   IAC_INTERCO_AR_CCID,
   IAC_ASSET_COST_CCID,
   IAC_DEPRN_RESERVE_CCID,
   IAC_DEPRN_EXPENSE_CCID,
   IAC_NBV_RETIRED_GAIN_CCID,
   IAC_CURRENCY_CODE)
    values (
            k.event_id,
            v_counter,
            k.book_type_code,
            k.category_id,
            k.asset_id,
            k.distribution_id,
            k.set_of_books_id,
            k.adjustment_id,
            k.amount,
            k.dr_cr_flag,
            k.adjustment_type,
            k.transfer_to_gl_flag,
            k.units_assigned,
            k.period_counter,
            k.adjustment_offset_type,
            k.report_ccid,
            k.transaction_header_id,
            k.adjustment_id_out,
            k.transaction_type_code,
            k.transaction_sub_type,
            k.transaction_date_entered,
            k.mass_reference_id,
            k.adj_deprn_start_date,
            k.adjustment_status,
            k.revaluation_type_flag,
            k.adj_meaning,
            k.trn_meaning,
            k.BL_RESERVE,
            k.OP_EXPENSE,
            k.GENERAL_FUND,
            k.REVAL_RESERVE,
            k.REVAL_RSV_RET,
            k.INTERCO_AP,
            k.INTERCO_AR,
            k.COST,
            k.RESERVE,
            k.EXPENSE,
            k.NBV_RETIRED,
            k.currency_code);
            v_counter := v_counter + 1;
       end loop; --k
  end loop; --i


   --Debug
/*   delete from igi_iac_xla_lines_gt_tmp;
   insert into igi_iac_xla_lines_gt_tmp
   select * from igi_iac_xla_lines_gt;

   delete from FA_XLA_EXT_HEADERS_B_GT_tmp;
   insert into FA_XLA_EXT_HEADERS_B_GT_tmp
   select * from FA_XLA_EXT_HEADERS_B_GT;

   delete from FA_XLA_EXT_LINES_B_GT_tmp;
   INSERT INTO FA_XLA_EXT_LINES_B_GT_tmp
   select * from FA_XLA_EXT_LINES_B_GT;*/
    --Debug

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
   p_full_path => l_path_name,
   p_string => 'extract_transactions....Bye... ');

END extract_transactions;

PROCEDURE extract_deprn
   (p_application_id     IN number,
    p_accounting_mode    IN varchar2) IS

   l_procedure_name  varchar2(80) := 'extract_transactions';
   l_path_name varchar2(2000);

    cursor debug_ref_lines is
    select * from igi_iac_xla_lines_gt;

BEGIN
   l_path_name := g_path || l_procedure_name;
   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
      p_full_path => l_path_name,
      p_string => 'extract_transactions....Welcome... ');
     --Extract IAC reference lines object
   insert into igi_iac_xla_lines_gt (
   IAC_EVENT_ID,
   IAC_LINE_NUMBER,
   IAC_BOOK_TYPE_CODE,
   IAC_CATEGORY_ID,
   IAC_ASSET_ID,
   IAC_DISTRIBUTION_ID,
   IAC_LEDGER_ID,
   IAC_ADJUSTMENT_ID,
   IAC_AMOUNT,
   IAC_DR_CR_FLAG,
   IAC_ADJUSTMENT_TYPE,
   IAC_TRANSFER_TO_GL_FLAG,
   IAC_UNITS_ASSIGNED,
   IAC_PERIOD_COUNTER,
   IAC_ADJUSTMENT_OFFSET_TYPE,
   IAC_REPORT_CCID,
   IAC_TRANSACTION_HEADER_ID,
   IAC_ADJUSTMENT_ID_OUT,
   IAC_TRANSACTION_TYPE_CODE,
   IAC_TRANSACTION_SUB_TYPE,
   IAC_TRANSACTION_DATE_ENTERED,
   IAC_MASS_REFERENCE_ID,
   IAC_ADJ_DEPRN_START_DATE,
   IAC_ADJUSTMENT_STATUS,
   IAC_REVALUATION_TYPE_FLAG,
   IAC_ADJUSTMENT_TYPE_MEANING,
   IAC_TRANSACTION_TYPE_MEANING,
   IAC_BACKLOG_DEPRN_RSV_CCID,
   IAC_OPERATING_EXPENSE_CCID,
   IAC_GENERAL_FUND_CCID,
   IAC_REVAL_RESERVE_CCID,
   IAC_REVAL_RESERVE_RET_CCID,
   IAC_INTERCO_AP_CCID,
   IAC_INTERCO_AR_CCID,
   IAC_ASSET_COST_CCID,
   IAC_DEPRN_RESERVE_CCID,
   IAC_DEPRN_EXPENSE_CCID,
   IAC_NBV_RETIRED_GAIN_CCID,
   IAC_CURRENCY_CODE)
   select
   adj.event_id,
   rownum,
   -- adj.distribution_id,
   adj.book_type_code,
   th.category_id,
   adj.asset_id,
   adj.distribution_id,
   adj.set_of_books_id,
   adj.adjustment_id,
   amount_switch(adj.adjustment_type,adj.dr_cr_flag,adj.amount),
   adj.dr_cr_flag,
   adj.adjustment_type,
   adj.transfer_to_gl_flag,
   adj.units_assigned,
   adj.period_counter,
   adj.adjustment_offset_type,
   adj.report_ccid,
   th.transaction_header_id,
   th.adjustment_id_out,
   th.transaction_type_code,
   th.transaction_sub_type,
   th.transaction_date_entered,
   th.mass_reference_id,
   th.adj_deprn_start_date,
   th.adjustment_status,
   th.revaluation_type_flag,
   lkp_adj.meaning,
   lkp_trn.meaning,
   decode(adj.adjustment_type,'BL RESERVE',code_combination_id,null),
   decode(adj.adjustment_type,'OP EXPENSE',code_combination_id,null),
   decode(adj.adjustment_type,'GENERAL FUND',code_combination_id,null),
   decode(adj.adjustment_type,'REVAL RESERVE',code_combination_id,null),
   decode(adj.adjustment_type,'REVAL RSV RET',code_combination_id,null),
   decode(adj.adjustment_type,'INTERCO AP',code_combination_id,null),
   decode(adj.adjustment_type,'INTERCO AR',code_combination_id,null),
   decode(adj.adjustment_type,'COST',code_combination_id,null),
   decode(adj.adjustment_type,'RESERVE',code_combination_id,null),
   decode(adj.adjustment_type,'EXPENSE',code_combination_id,null),
   decode(adj.adjustment_type,'NBV RETIRED',code_combination_id,null),
   sob.currency_code
   from igi_iac_adjustments adj, igi_iac_transaction_headers th,
   igi_lookups lkp_adj, igi_lookups lkp_trn, xla_events_gt ctlgd,
   gl_sets_of_books sob
   where adj.adjustment_id = th.adjustment_id
   and adj.event_id = th.event_id
   and lkp_adj.lookup_type = 'IGI_IAC_ADJUSTMENT_TYPES'
   and lkp_trn.lookup_type = 'IGI_IAC_TRANSACTION_TYPES'
   and adj.adjustment_type = lkp_adj.lookup_code
   and th.transaction_type_code = lkp_trn.lookup_code
   and ctlgd.valuation_method      = th.book_type_code
   and ctlgd.event_id      = th.event_id
   and adj.set_of_books_id = sob.set_of_books_id
   and ctlgd.entity_code           ='DEPRECIATION'
   and ctlgd.event_type_code       ='DEPRECIATION'
   and adj.transfer_to_gl_flag = 'Y';

   --Debug
/*   delete from igi_iac_xla_lines_gt_tmp;
   insert into igi_iac_xla_lines_gt_tmp
   select * from igi_iac_xla_lines_gt;

   delete from FA_XLA_EXT_HEADERS_B_GT_tmp;
   insert into FA_XLA_EXT_HEADERS_B_GT_tmp
   select * from FA_XLA_EXT_HEADERS_B_GT;

   delete from FA_XLA_EXT_LINES_B_GT_tmp;
   INSERT INTO FA_XLA_EXT_LINES_B_GT_tmp
   select * from FA_XLA_EXT_LINES_B_GT;*/
    --Debug

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
   p_full_path => l_path_name,
   p_string => 'extract_transactions....Bye... ');

END extract_deprn;

function amount_switch(p_adj_type  varchar2,
                       p_side_flag varchar2,
                       p_amount    number)
return number is
begin
   if p_adj_type in ('COST','EXPENSE','INTERCO AR','OP EXPENSE') then
      if p_side_flag = 'DR' then
           return p_amount;
      else
           return p_amount * -1;
      end if;

   elsif p_adj_type in ('BL RESERVE','RESERVE','GENERAL FUND','INTERCO AP','NBV RETIRED','REVAL RESERVE','REVAL RSV RET') then
      if p_side_flag = 'CR' then
           return p_amount;
      else
           return p_amount * -1;
      end if;
   end if;
end;

BEGIN
--===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        :=    'igi.plsql.igi_iac_extract_pkg.';

--===========================FND_LOG.END=====================================

END igi_iac_extract_pkg;

/
