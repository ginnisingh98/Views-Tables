--------------------------------------------------------
--  DDL for Package Body PA_UBR_UER_SUMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_UBR_UER_SUMM_PKG" AS
/* $Header: PABLUBRB.pls 120.1 2005/08/05 03:06:48 lveerubh noship $ */

----------------------------------------------------------------
--Procedure Transfer_ar_ap_invoices is a  wrapper to convert the
--data types for input parameters
----------------------------------------------------------------
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

Procedure Create_Ubr_Uer_Summary_Balance(
                     p_from_project_number in varchar2,
                     p_to_project_number   in varchar2,
                     p_gl_period_name      in varchar2 ,
                     p_request_id          in number  ) IS
CURSOR org_cv IS
select all1.org_id
from pa_implementations_all all1
where all1.set_of_books_id = ( select s1.set_of_books_id
                          from pa_implementations s1);

begin

   G_p_from_project_number :=  p_from_project_number ;
   G_p_to_project_number := p_to_project_number;
   G_p_gl_period_name := p_gl_period_name ;
   G_p_request_id := p_request_id    ;


  FOR org_rec in org_cv LOOP

      IF g1_debug_mode  = 'Y' THEN
      	pa_debug.write_file('Create_Ubr_Uer_Summary_Balance: ' || 'START org id '||to_char(org_rec.org_id));
      END IF;

      if ( Initialize( org_rec.org_id ) ) then

--      pa_debug.write_file('--------------BEFORE DR---------------------- ');
      process_draft_revenues;

--      pa_debug.write_file('--------------BEFORE DI---------------------- ');
      process_draft_invoices;

--      pa_debug.write_file('--------------AFTER DR - DI---------------------- ');

      end if;
  END LOOP;

commit;
end Create_Ubr_Uer_Summary_Balance;

function Initialize ( p_org_id  in number ) return boolean is
begin

-- pa_debug.write_file('BEFORE SELECT 1 ');

   G_org_id  := p_org_id;

   SELECT
        gl1.end_date,
        sob1.chart_of_accounts_id,
        imp1.set_of_books_id
   INTO
        G_p_gl_end_date ,
        G_coa_id ,
        G_sob
   FROM gl_period_statuses  gl1,
        pa_implementations_all imp1,
        gl_sets_of_books   sob1
   WHERE
       imp1.org_id  = p_org_id
   AND imp1.set_of_books_id = gl1.set_of_books_id
   AND gl1.application_id = 101
   and imp1.set_of_books_id = sob1.set_of_books_id
   and gl1.adjustment_period_flag = 'N'
   AND ( ( G_p_gl_period_name is not null
           and G_p_gl_period_name = gl1.period_name )
       OR( G_p_gl_period_name is null
           and trunc(sysdate) between gl1.start_date and gl1.end_date ));

-- pa_debug.write_file('AFTER SELECT 1 ');
-- Get the segment number.

    IF (NOT fnd_flex_apis.get_qualifier_segnum(
                appl_id                 => 101,
                key_flex_code           => 'GL#',
                structure_number        => G_coa_id,
                flex_qual_name          => 'FA_COST_CTR',
                segment_number          => G_cost_seg_num)) THEN
      app_exception.raise_exception;
    END IF;
    IF (NOT fnd_flex_apis.get_qualifier_segnum(
                appl_id                 => 101,
                key_flex_code           => 'GL#',
                structure_number        => G_coa_id,
                flex_qual_name          => 'GL_ACCOUNT',
                segment_number          => G_acct_seg_num)) THEN
      app_exception.raise_exception;
    END IF;

/*
  pa_debug.write_file(' cost_num '||G_cost_seg_num);
  pa_debug.write_file(' acct_num '||G_acct_seg_num);
*/

-- Get the segment name.

      IF (NOT fnd_flex_apis.get_segment_info(
                x_application_id        => 101,
                x_id_flex_code          => 'GL#',
                x_id_flex_num           => G_coa_id,
                x_seg_num               => G_cost_seg_num,
                x_appcol_name           => G_cost_appcol_name,
                x_seg_name              => G_cost_seg_name,
                x_prompt                => G_cost_prompt,
                x_value_set_name        => G_cost_value_set_name)) THEN
        app_exception.raise_exception;
      END IF;
      IF (NOT fnd_flex_apis.get_segment_info(
                x_application_id        => 101,
                x_id_flex_code          => 'GL#',
                x_id_flex_num           => G_coa_id,
                x_seg_num               => G_acct_seg_num,
                x_appcol_name           => G_acct_appcol_name,
                x_seg_name              => G_acct_seg_name,
                x_prompt                => G_acct_prompt,
                x_value_set_name        => G_acct_value_set_name)) THEN
        app_exception.raise_exception;
      END IF;

/*
   pa_debug.write_file(' G_cost_appcol_name '||G_cost_appcol_name);
   pa_debug.write_file(' G_cost_seg_name '||G_cost_seg_name);
   pa_debug.write_file(' G_cost_prompt '||G_cost_prompt);
   pa_debug.write_file(' G_cost_value_set_name '||G_cost_value_set_name);

   pa_debug.write_file(' G_acct_appcol_name '||G_acct_appcol_name);
   pa_debug.write_file(' G_acct_seg_name '||G_acct_seg_name);
   pa_debug.write_file(' G_acct_prompt '||G_acct_prompt);
   pa_debug.write_file(' G_acct_value_set_name '||G_acct_value_set_name);
*/
   return true;

exception
  when others then
   return false;
end;

procedure process_draft_revenues  is

   l_project_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_draft_rev_num_arr   PA_PLSQL_DATATYPES.NumTabTyp;

   l_ubr_acct_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_ubr_cost_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_uer_acct_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_uer_cost_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_gl_period_st_dt_arr PA_PLSQL_DATATYPES.DateTabTyp;
   l_gl_period_name_arr  PA_PLSQL_DATATYPES.Char80TabTyp;
   l_ubr_amount_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_uer_amount_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_ins_upd_flag_arr    PA_PLSQL_DATATYPES.Char1TabTyp;

   l_sum_summary_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_sum_cost_seg_arr        PA_PLSQL_DATATYPES.Char30TabTyp;
   l_sum_acct_seg_arr        PA_PLSQL_DATATYPES.Char30TabTyp;
   l_sum_project_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_sum_gl_st_dt_arr        PA_PLSQL_DATATYPES.DateTabTyp;
   l_sum_proc_flag_arr       PA_PLSQL_DATATYPES.Char1TabTyp;
   l_sum_ubr_arr   PA_PLSQL_DATATYPES.NumTabTyp;
   l_sum_uer_arr   PA_PLSQL_DATATYPES.NumTabTyp;

   l_zer_project_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_zer_gl_st_dt_arr        PA_PLSQL_DATATYPES.DateTabTyp;
   l_zer_flag_arr            PA_PLSQL_DATATYPES.Char1TabTyp;

   l_row_count           number  := 0 ;
   l_total_count         number  := 0 ;
   l_prev_total_count    number  := 0 ;

   l_temp                number:= 1000;
 CURSOR sum_cv IS
     select
         ubr_uer_summary_id,
         project_id,
         cost_center_segment,
         Account_segment,
         gl_period_start_date,
         process_flag,
         delta_ubr,
         delta_uer
     from pa_ubr_uer_summ_acct
     where  request_id = G_p_request_id
     and    process_flag in ('I','U');

  CURSOR zero_cv IS
    select sel1.project_id,
           sel1.gl_period_start_date,
        decode( sum( decode(UBR_UER_CODE,
                      'UBR',UBR_BAL_PREV_PERIOD_DR+UNBILLED_RECEIVABLE_DR,
                      'UER',UER_BAL_PREV_PERIOD_CR + UNEARNED_REVENUE_CR,
                      (UBR_BAL_PREV_PERIOD_DR+UNBILLED_RECEIVABLE_DR) -
                      (UER_BAL_PREV_PERIOD_CR + UNEARNED_REVENUE_CR) )),
                   0, decode(zero_balance_flag,'N','Y','X'),
                      decode(zero_balance_flag,'Y','N','X')) zero_bal_flag
    from  pa_ubr_uer_summ_acct sel1
    where sel1.project_id in
           ( select distinct temp1.project_id
             from pa_draft_rev_inv_temp temp1 )
    group by
          sel1.project_id,
          sel1.gl_period_start_date ,
          sel1.zero_balance_flag
    having
         decode( sum( decode(UBR_UER_CODE,
               'UBR',UBR_BAL_PREV_PERIOD_DR+UNBILLED_RECEIVABLE_DR,
               'UER',UER_BAL_PREV_PERIOD_CR + UNEARNED_REVENUE_CR,
               (UBR_BAL_PREV_PERIOD_DR+UNBILLED_RECEIVABLE_DR) -
               (UER_BAL_PREV_PERIOD_CR + UNEARNED_REVENUE_CR) )),
             0, decode(zero_balance_flag,'N','Y','X'),
             decode(zero_balance_flag,'Y','N','X')) <> 'X' ;

CURSOR dr_cv IS
          select dr.project_id, dr.draft_revenue_num,
               get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'ACCOUNT',
                      UNBILLED_CODE_COMBINATION_ID ) ubr_acct_seg,
               get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'COST_CENTER',
                      UNBILLED_CODE_COMBINATION_ID ) ubr_cost_seg,
               get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'ACCOUNT',
                      UNEARNED_CODE_COMBINATION_ID ) uer_acct_seg,
               get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'COST_CENTER',
                      UNEARNED_CODE_COMBINATION_ID ) uer_cost_seg,
               get_gl_start_date(
                       101,
                       G_sob,
                       get_gl_period_name(
                         101,
                         G_sob,
                         dr.gl_date))  gl_period_start_date,
               get_gl_period_name(
                       101,
                       G_sob,
                       dr.gl_date) gl_period_name ,
                dr.unbilled_receivable_dr  ubr_amount,
                dr.unearned_revenue_cr   uer_amount,
                'U'   ins_upd_flag
          from   pa_draft_revenues_all  dr, pa_projects_all  pa
          where  pa.org_id = G_org_id
            and  dr.project_id = pa.project_id
            and  dr.transfer_status_code = 'A'
            and  dr.gl_date <= G_p_gl_end_date
            and  dr.ubr_uer_process_flag = 'N'
            and  get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'ACCOUNT',
                      dr.unbilled_code_combination_id ) is not null
            and  get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'ACCOUNT',
                      dr.unearned_code_combination_id ) is not null
            and  (
                   ( ( G_p_from_project_number is not null
                     and G_p_to_project_number is not null )
                     and pa.segment1 between G_p_from_project_number
                             and   G_p_to_project_number)
                   OR
                   ( ( G_p_from_project_number is not null
                      and G_p_to_project_number is null )
                      and pa.segment1 >= G_p_from_project_number )
                   OR
                   ( ( G_p_from_project_number is null
                      and G_p_to_project_number is not null )
                      and pa.segment1 <= G_p_from_project_number )
                   OR
                   ( G_p_from_project_number is null
                      and G_p_to_project_number is null )
                  );
--           order by dr.project_id;

begin

--  pa_debug.write_file('*******START DR PROCESSING********');
  OPEN dr_cv;

--  pa_debug.write_file('After Open');

  LOOP
--   pa_debug.write_file('Before fetch of draft revenues ');
-- pa_debug.write_file('LEV2:*******Start of the Batch*********');

    l_project_id_arr.delete;
    l_draft_rev_num_arr.delete;
    l_ubr_acct_seg_arr.delete;
    l_ubr_cost_seg_arr.delete;
    l_uer_acct_seg_arr.delete;
    l_uer_cost_seg_arr.delete;
    l_gl_period_st_dt_arr.delete;
    l_gl_period_name_arr.delete;

     FETCH dr_cv BULK COLLECT INTO
                   l_project_id_arr,
                   l_draft_rev_num_arr,
                   l_ubr_acct_seg_arr,
                   l_ubr_cost_seg_arr,
                   l_uer_acct_seg_arr ,
                   l_uer_cost_seg_arr  ,
                   l_gl_period_st_dt_arr ,
                   l_gl_period_name_arr,
                   l_ubr_amount_arr,
                   l_uer_amount_arr,
                   l_ins_upd_flag_arr
           LIMIT G_fetch_size;

     l_total_count := dr_cv%rowcount;
     l_row_count :=  l_total_count - l_prev_total_count ;
     l_prev_total_count := l_total_count;

      IF g1_debug_mode  = 'Y' THEN
     pa_debug.write_file('Revenues : After fetch '||l_total_count);
      END IF;

   if ( l_total_count = l_temp ) then
      IF g1_debug_mode  = 'Y' THEN
    pa_debug.write_file('REVENUE: Fetched Rows : '||to_char(l_total_count));
      END IF;
    l_temp := l_temp + 10000;
   end if;

     if ( l_row_count = 0 ) then
        exit;
     end if;

--       pa_debug.write_file('LEV2:Before For Loop '||l_project_id_arr.count);

--     --pa_debug.write_file('Revenues : Before update of the statuses ');
/*
      FORALL j IN l_project_id_arr.FIRST..l_project_id_arr.LAST
               UPDATE pa_draft_revenues
               SET ubr_uer_process_flag = 'S',
                   request_id           = G_p_request_id
               WHERE project_id = l_project_id_arr(j)
               and   draft_revenue_num = l_draft_rev_num_arr(j);
*/

      FORALL j IN l_project_id_arr.FIRST..l_project_id_arr.LAST
      INSERT INTO pa_draft_rev_inv_temp
        (
             project_id ,
             draft_rev_inv_num,
             ubr_account_segment,
             ubr_cost_center_segment,
             uer_account_segment,
             uer_cost_center_segment,
             gl_period_start_date ,
             gl_period_name ,
             insert_update_flag ,
             unbilled_receivable_dr ,
             unearned_revenue_cr
         )
      VALUES
        (
             l_project_id_arr(j),
             l_draft_rev_num_arr(j),
             l_ubr_acct_seg_arr(j),
             l_ubr_cost_seg_arr(j),
             l_uer_acct_seg_arr(j),
             l_uer_cost_seg_arr(j),
             l_gl_period_st_dt_arr(j),
             l_gl_period_name_arr(j),
             l_ins_upd_flag_arr(j),
             l_ubr_amount_arr(j),
             l_uer_amount_arr(j)
          );

--     pa_debug.write_file('LEV2:UBR Processing ----------------------');
      process_ubr_uer_summary('DRAFT_REVENUES','UBR');
--     pa_debug.write_file('LEV2:UER Processing ----------------------');
      process_ubr_uer_summary('DRAFT_REVENUES','UER');


--    pa_debug.write_file('LEV2:Summary Processing ----------------------');

    l_sum_summary_id_arr.delete;
    l_sum_project_id_arr.delete;
    l_sum_cost_seg_arr.delete;
    l_sum_acct_seg_arr.delete;
    l_sum_gl_st_dt_arr.delete;
    l_sum_proc_flag_arr.delete;
    l_sum_ubr_arr.delete;
    l_sum_uer_arr.delete;

     OPEN  sum_cv;

     FETCH sum_cv BULK COLLECT INTO
                   l_sum_summary_id_arr,
                   l_sum_project_id_arr,
                   l_sum_cost_seg_arr,
                   l_sum_acct_seg_arr,
                   l_sum_gl_st_dt_arr ,
                   l_sum_proc_flag_arr,
                   l_sum_ubr_arr,
                   l_sum_uer_arr;

     CLOSE sum_cv;

--    pa_debug.write_file('LEV2:After Fetch '||l_sum_project_id_arr.count);
     FORALL j IN l_sum_project_id_arr.FIRST..l_sum_project_id_arr.LAST
      UPDATE  pa_ubr_uer_summ_acct
      SET
        UBR_BAL_PREV_PERIOD_DR =
                          nvl(UBR_BAL_PREV_PERIOD_DR,0) + l_sum_ubr_arr(J),
        UER_BAL_PREV_PERIOD_CR =
                          nvl(UER_BAL_PREV_PERIOD_CR,0) + l_sum_uer_arr(J),
        request_id             = G_p_request_id
      WHERE project_id = l_sum_project_id_arr(J)
      AND   cost_center_segment = l_sum_cost_seg_arr(J)
      AND   Account_segment  = l_sum_acct_seg_arr(J)
      AND   gl_period_start_date > l_sum_gl_st_dt_arr(J);

--    pa_debug.write_file('LEV2:After updating the higher gl date rows ');
     FORALL j IN l_sum_project_id_arr.FIRST..l_sum_project_id_arr.LAST
     UPDATE pa_ubr_uer_summ_acct upd1
     SET ( upd1.UBR_BAL_PREV_PERIOD_DR, upd1.UER_BAL_PREV_PERIOD_CR ) =
        ( select nvl(sum(sel1.UNBILLED_RECEIVABLE_DR),0),
                 nvl(sum(sel1.UNEARNED_REVENUE_CR),0)
          from pa_ubr_uer_summ_acct sel1
          where sel1.project_id = upd1.project_id
          and   sel1.account_segment = upd1.account_segment
          and   sel1.cost_center_segment = upd1.cost_center_segment
          and   sel1.gl_period_start_date < upd1.gl_period_start_date )
     WHERE  ubr_uer_summary_id  = l_sum_summary_id_arr(J)
         AND   l_sum_proc_flag_arr(J) = 'I' ;

--    pa_debug.write_file('LEV2:After updating the previous balances ');

     FORALL j IN l_sum_project_id_arr.FIRST..l_sum_project_id_arr.LAST
     UPDATE pa_ubr_uer_summ_acct upd1
     SET process_flag = 'P',
         delta_ubr = 0,
         delta_uer = 0
     WHERE  project_id = l_sum_project_id_arr(J)
         AND   cost_center_segment = l_sum_cost_seg_arr(J)
         AND   Account_segment  = l_sum_acct_seg_arr(J)
         AND   gl_period_start_date = l_sum_gl_st_dt_arr(J);

--    pa_debug.write_file('LEV2:After Summary Processing ');

      FORALL j IN l_project_id_arr.FIRST..l_project_id_arr.LAST
               UPDATE pa_draft_revenues_all dr1
               SET ( dr1.request_id,dr1.ubr_uer_process_flag , dr1.ubr_summary_id ,dr1.uer_summary_id )
                 = ( select G_p_request_id,'Y',temp1.ubr_summary_id, temp1.uer_summary_id
                     from pa_draft_rev_inv_temp temp1
                     where temp1.project_id = dr1.project_id
                     and   temp1.draft_rev_inv_num = dr1.draft_revenue_num )
               WHERE dr1.project_id = l_project_id_arr(j)
               and   dr1.draft_revenue_num = l_draft_rev_num_arr(j);

--    pa_debug.write_file('LEV2:After Updating summary_id on pa_draft_revenue ');

--     Updating the zero_balance_flag.

--     pa_debug.write_file('LEV2:Zero Balance Processing ');
     OPEN  zero_cv;

      l_zer_project_id_arr.delete;
      l_zer_gl_st_dt_arr.delete;
      l_zer_flag_arr.delete;

     FETCH zero_cv BULK COLLECT INTO
                   l_zer_project_id_arr,
                   l_zer_gl_st_dt_arr ,
                   l_zer_flag_arr ;

--     pa_debug.write_file('LEV2:zero balance fetched '||to_char(l_zer_project_id_arr.count));
     CLOSE zero_cv;

      if ( l_zer_project_id_arr.count > 0 ) then
      FORALL j IN l_zer_project_id_arr.FIRST..l_zer_project_id_arr.LAST
               UPDATE pa_ubr_uer_summ_acct
               SET zero_balance_flag = l_zer_flag_arr(J)
               WHERE project_id = l_zer_project_id_arr(J)
               and   gl_period_start_date = l_zer_gl_st_dt_arr(J)
               and l_zer_flag_arr(J) <> 'X';
      end if;

      commit;
      if ( l_row_count < G_fetch_size ) then
        exit;
      end if;

   END LOOP;

   CLOSE dr_cv;

end process_draft_revenues;

procedure process_draft_invoices  is

   l_project_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_draft_inv_num_arr   PA_PLSQL_DATATYPES.NumTabTyp;

   l_ubr_acct_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_ubr_cost_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_uer_acct_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_uer_cost_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_gl_period_st_dt_arr PA_PLSQL_DATATYPES.DateTabTyp;
   l_gl_period_name_arr  PA_PLSQL_DATATYPES.Char80TabTyp;
   l_ubr_amount_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_uer_amount_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_ins_upd_flag_arr    PA_PLSQL_DATATYPES.Char1TabTyp;

   l_sum_summary_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_sum_cost_seg_arr        PA_PLSQL_DATATYPES.Char30TabTyp;
   l_sum_acct_seg_arr        PA_PLSQL_DATATYPES.Char30TabTyp;
   l_sum_project_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_sum_gl_st_dt_arr        PA_PLSQL_DATATYPES.DateTabTyp;
   l_sum_proc_flag_arr       PA_PLSQL_DATATYPES.Char1TabTyp;
   l_sum_ubr_arr   PA_PLSQL_DATATYPES.NumTabTyp;
   l_sum_uer_arr   PA_PLSQL_DATATYPES.NumTabTyp;

   l_zer_project_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_zer_gl_st_dt_arr        PA_PLSQL_DATATYPES.DateTabTyp;
   l_zer_flag_arr            PA_PLSQL_DATATYPES.Char1TabTyp;

   l_row_count           number  := 0 ;
   l_total_count         number  := 0 ;
   l_prev_total_count    number  := 0 ;

   l_temp                number:= 1000;


  CURSOR zero_cv IS
    select sel1.project_id,
           sel1.gl_period_start_date,
        decode( sum( decode(UBR_UER_CODE,
                      'UBR',UBR_BAL_PREV_PERIOD_DR+UNBILLED_RECEIVABLE_DR,
                      'UER',UER_BAL_PREV_PERIOD_CR + UNEARNED_REVENUE_CR,
                      (UBR_BAL_PREV_PERIOD_DR+UNBILLED_RECEIVABLE_DR) -
                      (UER_BAL_PREV_PERIOD_CR + UNEARNED_REVENUE_CR) )),
                   0, decode(zero_balance_flag,'N','Y','X'),
                      decode(zero_balance_flag,'Y','N','X')) zero_bal_flag
    from  pa_ubr_uer_summ_acct sel1
    where sel1.project_id in
           ( select distinct temp1.project_id
             from pa_draft_rev_inv_temp temp1 )
    group by
          sel1.project_id,
          sel1.gl_period_start_date ,
          sel1.zero_balance_flag
    having
         decode( sum( decode(UBR_UER_CODE,
               'UBR',UBR_BAL_PREV_PERIOD_DR+UNBILLED_RECEIVABLE_DR,
               'UER',UER_BAL_PREV_PERIOD_CR + UNEARNED_REVENUE_CR,
               (UBR_BAL_PREV_PERIOD_DR+UNBILLED_RECEIVABLE_DR) -
               (UER_BAL_PREV_PERIOD_CR + UNEARNED_REVENUE_CR) )),
             0, decode(zero_balance_flag,'N','Y','X'),
             decode(zero_balance_flag,'Y','N','X')) <> 'X' ;

 CURSOR sum_cv IS
     select
         ubr_uer_summary_id,
         project_id,
         cost_center_segment,
         Account_segment,
         gl_period_start_date,
         process_flag,
         delta_ubr,
         delta_uer
     from pa_ubr_uer_summ_acct
     where  request_id = G_p_request_id
     and    process_flag in ('I','U');

CURSOR di_cv IS
          select di.project_id, di.draft_invoice_num,
               get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'ACCOUNT',
                      UNBILLED_CODE_COMBINATION_ID ) ubr_acct_seg,
               get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'COST_CENTER',
                      UNBILLED_CODE_COMBINATION_ID ) ubr_cost_seg,
               get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'ACCOUNT',
                      UNEARNED_CODE_COMBINATION_ID ) uer_acct_seg,
               get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'COST_CENTER',
                      UNEARNED_CODE_COMBINATION_ID ) uer_cost_seg,
               get_gl_start_date(
                       101,
                       G_sob,
                       get_gl_period_name(
                         101,
                         G_sob,
                         di.gl_date))  gl_period_start_date,
               get_gl_period_name(
                       101,
                       G_sob,
                       di.gl_date) gl_period_name ,
                di.unbilled_receivable_dr  ubr_amount,
                di.unearned_revenue_cr   uer_amount,
                'U'   ins_upd_flag
          from   pa_draft_invoices_all  di, pa_projects_all  pa
          where  pa.org_id  = G_org_id
            and  di.project_id = pa.project_id
            and  di.transfer_status_code = 'A'
            and  di.gl_date <= G_p_gl_end_date
            and  get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'ACCOUNT',
                      di.unbilled_code_combination_id ) is not null
            and  get_seg_val(
                      G_acct_appcol_name,
                      G_cost_appcol_name,
                      'ACCOUNT',
                      di.unearned_code_combination_id ) is not null
            and  di.ubr_uer_process_flag = 'N'
            and (
                   ( ( G_p_from_project_number is not null
                     and G_p_to_project_number is not null )
                     and pa.segment1 between G_p_from_project_number
                             and   G_p_to_project_number)
                   OR
                   ( ( G_p_from_project_number is not null
                      and G_p_to_project_number is null )
                      and pa.segment1 >= G_p_from_project_number )
                   OR
                   ( ( G_p_from_project_number is null
                      and G_p_to_project_number is not null )
                      and pa.segment1 <= G_p_from_project_number )
                   OR
                   ( G_p_from_project_number is null
                      and G_p_to_project_number is null )
                  );
--           order by di.project_id;

begin

--  pa_debug.write_file('*******START DI PROCESSING********');
  OPEN di_cv;

--  pa_debug.write_file('After Open');

  LOOP
--     pa_debug.write_file('Before fetch of draft revenues ');
-- pa_debug.write_file('LEV2:*******Start of the Batch*********');

    l_project_id_arr.delete;
    l_draft_inv_num_arr.delete;
    l_ubr_acct_seg_arr.delete;
    l_ubr_cost_seg_arr.delete;
    l_uer_acct_seg_arr.delete;
    l_uer_cost_seg_arr.delete;
    l_gl_period_st_dt_arr.delete;
    l_gl_period_name_arr.delete;

     FETCH di_cv BULK COLLECT INTO
                   l_project_id_arr,
                   l_draft_inv_num_arr,
                   l_ubr_acct_seg_arr,
                   l_ubr_cost_seg_arr,
                   l_uer_acct_seg_arr ,
                   l_uer_cost_seg_arr  ,
                   l_gl_period_st_dt_arr ,
                   l_gl_period_name_arr,
                   l_ubr_amount_arr,
                   l_uer_amount_arr,
                   l_ins_upd_flag_arr
           LIMIT G_fetch_size;

     l_total_count := di_cv%rowcount;
     l_row_count :=  l_total_count - l_prev_total_count ;
     l_prev_total_count := l_total_count;

      IF g1_debug_mode  = 'Y' THEN
     pa_debug.write_file('Invoice  : After fetch '||l_total_count);
      END IF;

   if ( l_total_count = l_temp ) then
      IF g1_debug_mode  = 'Y' THEN
    pa_debug.write_file('INVOICE: Fetched Rows : '||to_char(l_total_count));
      END IF;
    l_temp := l_temp + 10000;
   end if;

     if ( l_row_count = 0 ) then
        exit;
     end if;

--       pa_debug.write_file('LEV2:Before For Loop '||l_project_id_arr.count);

--     --pa_debug.write_file('Revenues : Before update of the statuses ');

      FORALL j IN l_project_id_arr.FIRST..l_project_id_arr.LAST
      INSERT INTO pa_draft_rev_inv_temp
        (
             project_id ,
             draft_rev_inv_num,
             ubr_account_segment,
             ubr_cost_center_segment,
             uer_account_segment,
             uer_cost_center_segment,
             gl_period_start_date ,
             gl_period_name ,
             insert_update_flag ,
             unbilled_receivable_dr ,
             unearned_revenue_cr
         )
      VALUES
        (
             l_project_id_arr(j),
             l_draft_inv_num_arr(j),
             l_ubr_acct_seg_arr(j),
             l_ubr_cost_seg_arr(j),
             l_uer_acct_seg_arr(j),
             l_uer_cost_seg_arr(j),
             l_gl_period_st_dt_arr(j),
             l_gl_period_name_arr(j),
             l_ins_upd_flag_arr(j),
             l_ubr_amount_arr(j),
             l_uer_amount_arr(j)
          );

--     pa_debug.write_file('LEV2:UBR Processing ----------------------');
      process_ubr_uer_summary('DRAFT_REVENUES','UBR');
--     pa_debug.write_file('LEV2:UER Processing ----------------------');
      process_ubr_uer_summary('DRAFT_REVENUES','UER');


--    pa_debug.write_file('LEV2:Summary Processing ----------------------');

      l_sum_project_id_arr.delete;
      l_sum_cost_seg_arr.delete;
      l_sum_acct_seg_arr.delete;
      l_sum_gl_st_dt_arr.delete;
      l_sum_proc_flag_arr.delete;
      l_sum_ubr_arr.delete;
      l_sum_uer_arr.delete;

     OPEN  sum_cv;

     FETCH sum_cv BULK COLLECT INTO
                   l_sum_summary_id_arr,
                   l_sum_project_id_arr,
                   l_sum_cost_seg_arr,
                   l_sum_acct_seg_arr,
                   l_sum_gl_st_dt_arr ,
                   l_sum_proc_flag_arr,
                   l_sum_ubr_arr,
                   l_sum_uer_arr;

     CLOSE sum_cv;

--    pa_debug.write_file('LEV2:After Fetch '||l_sum_project_id_arr.count);
     FORALL j IN l_sum_project_id_arr.FIRST..l_sum_project_id_arr.LAST
      UPDATE  pa_ubr_uer_summ_acct
      SET
        UBR_BAL_PREV_PERIOD_DR =
                          nvl(UBR_BAL_PREV_PERIOD_DR,0) + l_sum_ubr_arr(J),
        UER_BAL_PREV_PERIOD_CR =
                          nvl(UER_BAL_PREV_PERIOD_CR,0) + l_sum_uer_arr(J)
      WHERE project_id = l_sum_project_id_arr(J)
      AND   cost_center_segment = l_sum_cost_seg_arr(J)
      AND   Account_segment  = l_sum_acct_seg_arr(J)
      AND   gl_period_start_date > l_sum_gl_st_dt_arr(J);

--    pa_debug.write_file('LEV2:After updating the higher gl date rows ');
     FORALL j IN l_sum_project_id_arr.FIRST..l_sum_project_id_arr.LAST
     UPDATE pa_ubr_uer_summ_acct upd1
     SET ( upd1.UBR_BAL_PREV_PERIOD_DR, upd1.UER_BAL_PREV_PERIOD_CR ) =
        ( select nvl(sum(sel1.UNBILLED_RECEIVABLE_DR),0),nvl(sum(sel1.UNEARNED_REVENUE_CR),0)
          from pa_ubr_uer_summ_acct sel1
          where sel1.project_id = upd1.project_id
          and   sel1.account_segment = upd1.account_segment
          and   sel1.cost_center_segment = upd1.cost_center_segment
          and   sel1.gl_period_start_date < upd1.gl_period_start_date )
     WHERE  ubr_uer_summary_id  = l_sum_summary_id_arr(J)
         AND   l_sum_proc_flag_arr(J) = 'I' ;

--    pa_debug.write_file('LEV2:After updating the previous balances ');

     FORALL j IN l_sum_project_id_arr.FIRST..l_sum_project_id_arr.LAST
     UPDATE pa_ubr_uer_summ_acct upd1
     SET process_flag = 'P',
         delta_ubr = 0,
         delta_uer = 0
     WHERE  project_id = l_sum_project_id_arr(J)
         AND   cost_center_segment = l_sum_cost_seg_arr(J)
         AND   Account_segment  = l_sum_acct_seg_arr(J)
         AND   gl_period_start_date = l_sum_gl_st_dt_arr(J);


--    pa_debug.write_file('LEV2:After Summary Processing ');

      FORALL j IN l_project_id_arr.FIRST..l_project_id_arr.LAST
               UPDATE pa_draft_invoices_all di1
               SET ( di1.request_id,di1.ubr_uer_process_flag , di1.ubr_summary_id ,di1.uer_summary_id )
                 = ( select G_p_request_id,'Y',temp1.ubr_summary_id, temp1.uer_summary_id
                     from pa_draft_rev_inv_temp temp1
                     where temp1.project_id = di1.project_id
                     and   temp1.draft_rev_inv_num = di1.draft_invoice_num )
               WHERE di1.project_id = l_project_id_arr(j)
               and   di1.draft_invoice_num = l_draft_inv_num_arr(j);

--    pa_debug.write_file('LEV2:After Updating summary_id on pa_draft_invoices ');


--

--     pa_debug.write_file('LEV2:Zero Balance Processing ');
     OPEN  zero_cv;

      l_zer_project_id_arr.delete;
      l_zer_gl_st_dt_arr.delete;
      l_zer_flag_arr.delete;

     FETCH zero_cv BULK COLLECT INTO
                   l_zer_project_id_arr,
                   l_zer_gl_st_dt_arr ,
                   l_zer_flag_arr ;

--     pa_debug.write_file('LEV2:zero balance fetched '||to_char(l_zer_project_id_arr.count));
     CLOSE zero_cv;

      if ( l_zer_project_id_arr.count > 0 ) then
      FORALL j IN l_zer_project_id_arr.FIRST..l_zer_project_id_arr.LAST
               UPDATE pa_ubr_uer_summ_acct
               SET zero_balance_flag = l_zer_flag_arr(J)
               WHERE project_id = l_zer_project_id_arr(J)
               and   gl_period_start_date = l_zer_gl_st_dt_arr(J)
               and l_zer_flag_arr(J) <> 'X';
      end if;

      commit;
      if ( l_row_count < G_fetch_size ) then
        exit;
      end if;

   END LOOP;

   CLOSE di_cv;

end process_draft_invoices;

procedure process_ubr_uer_summary ( p_source in varchar2 , p_process_ubr_uer in varchar2 ) is


   l_project_id_arr      PA_PLSQL_DATATYPES.NumTabTyp;
   l_draft_rev_num_arr   PA_PLSQL_DATATYPES.NumTabTyp;

   l_acct_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_cost_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;

   l_gl_period_arr       PA_PLSQL_DATATYPES.Char30TabTyp;
   l_gl_period_start_date_arr       PA_PLSQL_DATATYPES.DateTabTyp;
   l_sum_project_id_arr  PA_PLSQL_DATATYPES.NumTabTyp;
   l_sum_amt_arr     PA_PLSQL_DATATYPES.NumTabTyp;

   l_upd_project_id_arr  PA_PLSQL_DATATYPES.NumTabTyp;
   l_upd_summary_id_arr  PA_PLSQL_DATATYPES.NumTabTyp;
   l_upd_acct_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_upd_cost_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_upd_gl_per_stdt_arr PA_PLSQL_DATATYPES.DateTabTyp;

   l_ins_summary_id_arr  PA_PLSQL_DATATYPES.NumTabTyp;
   l_ins_sum_project_id_arr  PA_PLSQL_DATATYPES.NumTabTyp;
   l_ins_acct_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_ins_cost_seg_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_ins_gl_period_arr   PA_PLSQL_DATATYPES.Char30TabTyp;
   l_ins_sum_amt_arr     PA_PLSQL_DATATYPES.NumTabTyp;
   l_ins_gl_per_stdt_arr PA_PLSQL_DATATYPES.DateTabTyp;
   l_ins_ins_upd_flag_arr PA_PLSQL_DATATYPES.Char1TabTyp;

   l_t_count             number;
   l_process_ubr_uer_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_upd_prev_process_ubr_uer_arr    PA_PLSQL_DATATYPES.Char30TabTyp;
   l_ins_process_ubr_uer_arr    PA_PLSQL_DATATYPES.Char30TabTyp;

   ins_j                 number;

CURSOR sum_cv IS
        select
                decode(p_process_ubr_uer,
                      'UBR',ubr_account_segment,
                      'UER',uer_account_segment,
                      '-1') acct_seg,
                decode(p_process_ubr_uer,
                      'UBR',ubr_cost_center_segment,
                      'UER',uer_cost_center_segment,
                      '-1') cost_seg,
                gl_period_name ,
                gl_period_start_date,
                p_process_ubr_uer,
               project_id,
               decode(p_process_ubr_uer,
                        'UBR',sum(unbilled_receivable_dr),
                        'UER',sum(unearned_revenue_cr),-1)
      from  pa_draft_rev_inv_temp
      group by
         decode(p_process_ubr_uer,
             'UBR',ubr_account_segment,
             'UER',uer_account_segment,
             '-1') ,
         decode(p_process_ubr_uer,
             'UBR',ubr_cost_center_segment,
             'UER',uer_cost_center_segment,
             '-1') ,
         gl_period_name ,
         gl_period_start_date,
         project_id;


begin

--   pa_debug.write_file('START OF PROCEDURE ');

      l_acct_seg_arr.delete;
      l_cost_seg_arr.delete;
      l_gl_period_arr.delete;
      l_sum_project_id_arr.delete;
      l_sum_amt_arr.delete;
      l_process_ubr_uer_arr.delete;


--   pa_debug.write_file('Before summary fetch  ');

      OPEN sum_cv;

      FETCH sum_cv
             BULK COLLECT INTO
                    l_acct_seg_arr,
                    l_cost_seg_arr ,
                    l_gl_period_arr,
                    l_gl_period_start_date_arr,
                    l_process_ubr_uer_arr,
                    l_sum_project_id_arr,
                    l_sum_amt_arr ;

--     pa_debug.write_file('LEV2:after sumary fetch  '||sum_cv%rowcount);
      CLOSE sum_cv;


--     pa_debug.write_file('after close ');


   FORALL j IN l_sum_project_id_arr.FIRST..l_sum_project_id_arr.LAST
      UPDATE pa_ubr_uer_summ_acct
               SET
                   unbilled_receivable_dr =
                       decode(l_process_ubr_uer_arr(j),
                              'UBR',unbilled_receivable_dr + l_sum_amt_arr(j),
                              'UER',unbilled_receivable_dr ,
                               -1 ),
                   unearned_revenue_cr =
                       decode(l_process_ubr_uer_arr(j),
                              'UBR',unearned_revenue_cr ,
                              'UER',unearned_revenue_cr + l_sum_amt_arr(j),
                               -1 ),
                   delta_ubr =
                       decode(l_process_ubr_uer_arr(j),
                              'UBR',delta_ubr + l_sum_amt_arr(j),
                              'UER',delta_ubr ,
                               -1 ),
                   delta_uer =
                       decode(l_process_ubr_uer_arr(j),
                              'UBR',delta_uer ,
                              'UER',delta_uer + l_sum_amt_arr(j),
                               -1 ),
                   ubr_uer_code  =
                     decode(l_process_ubr_uer_arr(j),
                       'UBR', decode(nvl(ubr_uer_code,'-1'),
                               'UBR','UBR',
                               'UER','UBR_UER',
                               'UBR_UER','UBR_UER',
                               'UBR'),
                       'UER', decode(nvl(ubr_uer_code,'-1'),
                               'UER','UER',
                               'UBR','UBR_UER',
                               'UBR_UER','UBR_UER',
                               'UER'),
                       '-1' ) ,
                    process_flag  = decode(process_flag,'I','I','U'),
                    last_update_date  = sysdate ,
                    last_updated_by = -1 ,
                    request_id = G_p_request_id
               WHERE project_id = l_sum_project_id_arr(j)
               AND   Account_segment = l_acct_seg_arr(j)
               AND   cost_center_segment = l_cost_seg_arr(j)
               AND   gl_period_start_date  = l_gl_period_start_date_arr(j)
               RETURNING
                       project_id,
                       ubr_uer_summary_id,
                       Account_segment,
                       cost_center_segment,
                       gl_period_start_date
               BULK COLLECT INTO
                l_upd_project_id_arr  ,
                l_upd_summary_id_arr  ,
                l_upd_acct_seg_arr    ,
                l_upd_cost_seg_arr    ,
                l_upd_gl_per_stdt_arr ;

--       pa_debug.write_file('LEV2:Rows Updated  in summary table '||to_char(l_upd_project_id_arr.count));

       ins_j := 0;

       FOR i in l_sum_project_id_arr.FIRST..l_sum_project_id_arr.LAST LOOP

        l_t_count := SQL%BULK_ROWCOUNT(i);

        if ( l_t_count = 0 ) then

          ins_j := ins_j + 1;

          l_ins_acct_seg_arr(ins_j) := l_acct_seg_arr(i);
          l_ins_cost_seg_arr(ins_j) := l_cost_seg_arr(i);
          l_ins_gl_period_arr(ins_j)  := l_gl_period_arr(i);
          l_ins_sum_project_id_arr(ins_j)  := l_sum_project_id_arr(i);
          l_ins_sum_amt_arr(ins_j)  := l_sum_amt_arr(i);
          l_ins_process_ubr_uer_arr(ins_j) := l_process_ubr_uer_arr(i);
          l_ins_gl_per_stdt_arr(ins_j) := l_gl_period_start_date_arr(i);

          select pa_ubr_uer_summ_acct_s.nextval
          into   l_ins_summary_id_arr(ins_j)
          from dual;

          l_ins_ins_upd_flag_arr(ins_j) := 'I';

        end if;


       END LOOP;

          l_acct_seg_arr.delete;
          l_cost_seg_arr.delete;
          l_gl_period_arr.delete;
          l_sum_project_id_arr.delete;
          l_sum_amt_arr.delete;
          l_process_ubr_uer_arr.delete;

--       pa_debug.write_file('LEV2:Rows Inserted in summary table '||to_char(ins_j));


      if ( l_ins_sum_project_id_arr.count > 0 ) then
       FORALL j IN l_ins_sum_project_id_arr.FIRST..l_ins_sum_project_id_arr.LAST
          INSERT INTO pa_ubr_uer_summ_acct
                   (  ubr_uer_summary_id ,
                      Account_segment  ,
                      cost_center_segment  ,
                      project_id      ,
                      gl_period_name  ,
                      gl_period_start_date  ,
                      ubr_uer_code  ,
                      process_flag  ,
                      last_update_date  ,
                      last_updated_by   ,
                      creation_date    ,
                      created_by      ,
                      request_id     ,
                      zero_balance_flag ,
                      multi_cost_center_flag ,
                      ubr_bal_prev_period_dr ,
                      uer_bal_prev_period_cr ,
                      delta_ubr,
                      delta_uer ,
                      UNBILLED_RECEIVABLE_DR ,
                      UNEARNED_REVENUE_CR   )
           VALUES
                  ( l_ins_summary_id_arr(j),
                    l_ins_acct_seg_arr(j),
                    l_ins_cost_seg_arr(j),
                    l_ins_sum_project_id_arr(j),
                    l_ins_gl_period_arr(j),
                    l_ins_gl_per_stdt_arr(j),
                    l_ins_process_ubr_uer_arr(j) ,
                    'I',
                    sysdate,
                    -1,
                    sysdate,
                    -1,
                    G_p_request_id,
                    'N',
                    'N',
                    0 ,
                    0 ,
                    decode(l_ins_process_ubr_uer_arr(j),
                           'UBR',l_ins_sum_amt_arr(J),
                           'UER', 0, 0 ),
                    decode(l_ins_process_ubr_uer_arr(j),
                           'UER',l_ins_sum_amt_arr(J),
                           'UBR', 0, 0 ),
                    decode(l_ins_process_ubr_uer_arr(j),
                           'UBR',l_ins_sum_amt_arr(J),
                           'UER', 0, 0 ),
                    decode(l_ins_process_ubr_uer_arr(j),
                           'UER',l_ins_sum_amt_arr(J),
                           'UBR', 0, 0 )
                      );

--         pa_debug.write_file('LEV2:After insert into summary table ');
         end if;


      if ( l_upd_project_id_arr.count > 0 )  then

--   Update the summary_id
          if ( p_process_ubr_uer = 'UBR' ) then
           FORALL j IN l_upd_project_id_arr.FIRST..l_upd_project_id_arr.LAST
           UPDATE pa_draft_rev_inv_temp
           SET ubr_summary_id     = l_upd_summary_id_arr(J)
           where project_id = l_upd_project_id_arr(J)
           AND   ubr_cost_center_segment = l_upd_cost_seg_arr(J)
           AND   ubr_account_segment = l_upd_acct_seg_arr(J)
           AND   gl_period_start_date    = l_upd_gl_per_stdt_arr(J);
          else
           FORALL j IN l_upd_project_id_arr.FIRST..l_upd_project_id_arr.LAST
           UPDATE pa_draft_rev_inv_temp
           SET uer_summary_id     = l_upd_summary_id_arr(J)
           where project_id = l_upd_project_id_arr(J)
           AND   uer_cost_center_segment = l_upd_cost_seg_arr(J)
           AND   uer_account_segment = l_upd_acct_seg_arr(J)
           AND   gl_period_start_date    = l_upd_gl_per_stdt_arr(J);
          end if;
--      pa_debug.write_file('LEV2:After update of summary_id for updated rows ');
      end if;

      if ( l_ins_sum_project_id_arr.count > 0 )  then

--   Update the insert_update_flag

      if ( p_process_ubr_uer = 'UBR' ) then
       FORALL j IN l_ins_sum_project_id_arr.FIRST..l_ins_sum_project_id_arr.LAST
       UPDATE pa_draft_rev_inv_temp
       SET insert_update_flag = l_ins_ins_upd_flag_arr(J),
           ubr_summary_id     = l_ins_summary_id_arr(J)
       where project_id = l_ins_sum_project_id_arr(J)
       AND   ubr_cost_center_segment = l_ins_cost_seg_arr(J)
       AND   ubr_account_segment = l_ins_acct_seg_arr(J)
       AND   gl_period_start_date    = l_ins_gl_per_stdt_arr(J);
      else
       FORALL j IN l_ins_sum_project_id_arr.FIRST..l_ins_sum_project_id_arr.LAST
       UPDATE pa_draft_rev_inv_temp
       SET insert_update_flag = l_ins_ins_upd_flag_arr(J),
           uer_summary_id     = l_ins_summary_id_arr(J)
       where project_id = l_ins_sum_project_id_arr(J)
       AND   uer_cost_center_segment = l_ins_cost_seg_arr(J)
       AND   uer_account_segment = l_ins_acct_seg_arr(J)
       AND   gl_period_start_date    = l_ins_gl_per_stdt_arr(J);
      end if;

--     pa_debug.write_file('LEV2:After update of summary_id for inserted rows ');

-- Update for Multi- Cost Center projects.

           FORALL j IN l_ins_sum_project_id_arr.FIRST..l_ins_sum_project_id_arr.LAST
           UPDATE pa_ubr_uer_summ_acct  sum1
           set multi_cost_center_flag = 'Y'
           where project_id = l_ins_sum_project_id_arr(J)
           and  gl_period_name = l_ins_gl_period_arr(J)
           and  multi_cost_center_flag = 'N'
           and EXISTS ( select 'x'
                       from pa_ubr_uer_summ_acct sum2
                       where sum2.project_id = sum1.project_id
                       and   sum2.gl_period_name = sum1.gl_period_name
                       and   sum2.cost_center_segment <> l_ins_cost_seg_arr(J) );

--     pa_debug.write_file('LEV2:After update of the multi cost center flag  ' );

      end if;


end process_ubr_uer_summary;


function  get_seg_val( p_acct_appcol_name varchar2,
                       p_cost_appcol_name varchar2,
                       p_seg_type         varchar2,
                            p_ccid             number )
return varchar2 is
begin

  if ( G_ccid <> nvl(p_ccid,-99) ) then

   select decode(p_acct_appcol_name,
                   'SEGMENT1',segment1,
                   'SEGMENT2',segment2,
                   'SEGMENT3',segment3,
                   'SEGMENT4',segment4,
                   'SEGMENT5',segment5,
                   'SEGMENT6',segment6,
                   'SEGMENT7',segment7,
                   'SEGMENT8',segment8,
                   'SEGMENT9',segment9,
                   'SEGMENT10',segment10,
                   'SEGMENT11',segment11,
                   'SEGMENT12',segment12,
                   'SEGMENT13',segment13,
                   'SEGMENT14',segment14,
                   'SEGMENT15',segment15,
                   'SEGMENT16',segment16,
                   'SEGMENT17',segment17,
                   'SEGMENT18',segment18,
                   'SEGMENT19',segment19,
                   'SEGMENT20',segment20,
                   'SEGMENT21',segment21,
                   'SEGMENT22',segment22,
                   'SEGMENT23',segment23,
                   NULL),
          decode(p_cost_appcol_name,
                   'SEGMENT1',segment1,
                   'SEGMENT2',segment2,
                   'SEGMENT3',segment3,
                   'SEGMENT4',segment4,
                   'SEGMENT5',segment5,
                   'SEGMENT6',segment6,
                   'SEGMENT7',segment7,
                   'SEGMENT8',segment8,
                   'SEGMENT9',segment9,
                   'SEGMENT10',segment10,
                   'SEGMENT11',segment11,
                   'SEGMENT12',segment12,
                   'SEGMENT13',segment13,
                   'SEGMENT14',segment14,
                   'SEGMENT15',segment15,
                   'SEGMENT16',segment16,
                   'SEGMENT17',segment17,
                   'SEGMENT18',segment18,
                   'SEGMENT19',segment19,
                   'SEGMENT20',segment20,
                   'SEGMENT21',segment21,
                   'SEGMENT22',segment22,
                   'SEGMENT23',segment23,
                   NULL),
         code_combination_id
     into
        G_acct_seg_val,
        G_cost_seg_val,
        G_ccid
     from gl_code_combinations
     where code_combination_id = p_ccid ;

  end if;

  if ( p_seg_type = 'ACCOUNT') then
     return  G_acct_seg_val;
  elsif (  p_seg_type = 'COST_CENTER') then
     return  G_cost_seg_val;
  end if;
exception
    when no_data_found then
      return NULL;
    when others then
      raise;
end get_seg_val;

function  get_gl_period_name( p_application_id number,
                              p_set_of_books_id number,
                              p_gl_date         date )
return varchar2 is
begin


     if ( ( G_gl_period_name is null     ) or
          ( p_gl_date <  G_gl_start_date ) or
          ( p_gl_date >  G_gl_end_date   )   ) then

         G_gl_period_name  := NULL;
         G_gl_start_date   := NULL;
         G_gl_end_date     := NULL;

         select period_name ,
                start_date ,
                end_date
         into
                G_gl_period_name,
                G_gl_start_date,
                G_gl_end_date
         from gl_period_statuses
         where p_gl_date between START_DATE and END_DATE
      and   adjustment_period_flag = 'N'
      and   application_id = p_application_id
      and   set_of_books_id = p_set_of_books_id;

     end if;

     return G_gl_period_name ;

end get_gl_period_name;

function  get_gl_period_name( p_org_id          number,
                              p_gl_date         date )
return varchar2 is
begin

     if ( ( G_org_id_v is null ) or ( G_org_id_v <> p_org_id ) ) then

      G_gl_period_name := null;

      select set_of_books_id
      into G_set_of_books_id
      from pa_implementations_all
      where nvl(org_id,-1) = nvl(p_org_id,-1);

     end if;

     if ( ( G_gl_period_name is null     ) or
          ( p_gl_date <  G_gl_start_date ) or
          ( p_gl_date >  G_gl_end_date   )   ) then

         G_gl_period_name  := NULL;
         G_gl_start_date   := NULL;
         G_gl_end_date     := NULL;

         select period_name ,
                start_date ,
                end_date
         into
                G_gl_period_name,
                G_gl_start_date,
                G_gl_end_date
         from gl_period_statuses
         where p_gl_date between START_DATE and END_DATE
      and   adjustment_period_flag = 'N'
      and   application_id = 101 /* GL */
      and   set_of_books_id = G_set_of_books_id;

     end if;

     return G_gl_period_name ;

end get_gl_period_name;

function  get_gl_start_date( p_application_id number,
                              p_set_of_books_id number,
                              p_gl_period_name  varchar2 )
return date is
l_gl_start_date date;
begin


     if ( ( G_gl_period_name is null     ) or
          ( G_gl_period_name <> p_gl_period_name )
        ) then

         G_gl_start_date := NULL;
         G_gl_period_name := NULL;
         G_gl_end_date := NULL;

         select period_name ,
                start_date ,
                end_date
         into
                G_gl_period_name,
                G_gl_start_date,
                G_gl_end_date
         from gl_period_statuses
         where period_name = p_gl_period_name
      and   application_id = p_application_id
      and   set_of_books_id = p_set_of_books_id;

     end if;

     return G_gl_start_date;

end get_gl_start_date;

procedure get_gl_start_date( p_gl_period_name  IN varchar2 ,
                             p_gl_start_date   IN Date ,
                             x_gl_start_date_chr  OUT NOCOPY varchar2 )
is
l_gl_start_date varchar2(12);
begin

      if ( p_gl_start_date is NULL ) then
         select
                to_char(gl1.start_date,'DD-MON-RR')
         into
                l_gl_start_date
         from gl_period_statuses gl1 ,
              pa_implementations imp1
         where gl1.period_name = p_gl_period_name
      and   gl1.application_id = 101
      and   gl1.set_of_books_id = imp1.set_of_books_id;

      else
        select to_char(p_gl_start_date,'DD-MON-RR')  into l_gl_start_date
        from dual;
      end if;

      x_gl_start_date_chr := l_gl_start_date;
exception
    when no_data_found then
       x_gl_start_date_chr := NULL;
WHEN OTHERS THEN
	x_gl_start_date_chr := NULL;
end get_gl_start_date;

FUNCTION  get_inv_gl_header_id_line_num(
                              p_calling_place           IN VARCHAR2,
                              p_ar_invoice_number       IN NUMBER,
                              p_invoice_line_number     IN NUMBER,
                              p_ubr_code_combination_id IN NUMBER,
                              p_period_name             IN VARCHAR2 )
RETURN VARCHAR2 IS
BEGIN
      /* If the function is first time or there is change in previous value
         and current value then the select will fire else it will use the
         old values */

     IF ( ( G_p_invoice_num is null     )
               OR ( G_p_invoice_num <> p_ar_invoice_number )
         OR ( G_p_ubr_code_combination_id is null   )
               OR ( G_p_ubr_code_combination_id <> p_ubr_code_combination_id )
         OR (G_p_invoice_line_num is null    )
               OR ( G_p_invoice_line_num <> p_invoice_line_number )
         OR (G_p_period_name is null    )
               OR ( G_p_period_name <> p_period_name )
        ) THEN

         G_p_invoice_num             := p_ar_invoice_number;
         G_p_ubr_code_combination_id := p_ubr_code_combination_id;
         G_p_invoice_line_num        := p_invoice_line_number;
         G_p_period_name             := p_period_name;

         G_x_inv_gl_header_id        := NULL;
         G_x_inv_gl_line_num         := NULL;
         G_x_inv_gl_header_name      := NULL;
         G_x_inv_gl_batch_name       := NULL;

         SELECT je.je_header_id,
                je.je_line_num,
                jh.name ,
                jb.name
         INTO
                G_x_inv_gl_header_id,
                G_x_inv_gl_line_num,
                G_x_inv_gl_header_name,
                G_x_inv_gl_batch_name
         FROM gl_je_lines je,ra_customer_trx_lines_all rctla,
              ra_cust_trx_line_gl_dist_all rctlgda ,
              gl_je_headers  jh,
              gl_je_batches  jb
         WHERE je.reference_2             = TO_CHAR(rctlgda.customer_trx_id)
         AND je.reference_3               = TO_CHAR(rctlgda.cust_trx_line_gl_dist_id)
         AND je.code_combination_id       = rctlgda.code_combination_id
         AND je.period_name               = p_period_name
         AND rctlgda.customer_trx_line_id = rctla.customer_trx_line_id
         AND rctlgda.code_combination_id  = p_ubr_code_combination_id
         AND rctla.customer_trx_id        = p_ar_invoice_number
         AND rctla.interface_line_attribute6 = p_invoice_line_number
         AND je.je_header_id  = jh.je_header_id
         AND jh.je_batch_id = jb.je_batch_id(+);

     END IF;

     IF (p_calling_place = 'GL_HEADER_ID') THEN
        RETURN G_x_inv_gl_header_id;
     ELSIF (p_calling_place = 'GL_LINE_NUM') THEN
        RETURN G_x_inv_gl_line_num;
     ELSIF (p_calling_place = 'GL_HEADER_NAME') THEN
        RETURN G_x_inv_gl_header_name;
     ELSIF (p_calling_place = 'GL_BATCH_NAME') THEN
        RETURN G_x_inv_gl_batch_name;
     END IF;
EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;


END get_inv_gl_header_id_line_num;

FUNCTION  get_rev_gl_header_id_line_num(
                              p_calling_place           IN VARCHAR2,
                              p_batch_name              IN VARCHAR2,
                              p_system_ref_3            IN VARCHAR2,
                              p_code_combination_id     IN NUMBER,
                              p_period_name             IN VARCHAR2 )

RETURN VARCHAR2 IS
BEGIN
      /* If the function is first time or there is change in previous value
         and current value then the select will fire else it will use the
         old values */

     IF ( ( G_batch_name    is null     )
               OR ( G_batch_name    <> p_batch_name )
         OR ( G_code_combination_id is null   )
               OR ( G_code_combination_id <> p_code_combination_id )
         OR (G_system_ref_3  is null    )
               OR ( G_system_ref_3 <> p_system_ref_3 )
         OR (G_rev_period_name is null    )
               OR ( G_rev_period_name <> p_period_name )
        ) THEN

         G_batch_name          := p_batch_name;
         G_code_combination_id := p_code_combination_id;
         G_system_ref_3        := p_system_ref_3;
         G_rev_period_name     := p_period_name;

         G_x_rev_gl_header_id  := NULL;
         G_x_rev_gl_line_num  := NULL;
         G_x_rev_gl_header_name := NULL;
         G_x_rev_gl_batch_name  := NULL;

         SELECT je.je_header_id,
                je.je_line_num,
                jh.name,
                jb.name
         INTO
                G_x_rev_gl_header_id,
                G_x_rev_gl_line_num,
                G_x_rev_gl_header_name,
                G_x_rev_gl_batch_name
         FROM gl_je_lines je,
              gl_je_headers jh,
              gl_je_batches jb
         WHERE je.reference_1             = p_batch_name
         AND je.reference_3               = p_system_ref_3
         AND je.code_combination_id       = p_code_combination_id
         AND je.period_name               = p_period_name
         AND je.je_header_id = jh.je_header_id
         AND jh.je_batch_id  = jb.je_batch_id(+);

     END IF;

     IF (p_calling_place = 'GL_HEADER_ID') THEN
        RETURN G_x_rev_gl_header_id;
     ELSIF (p_calling_place = 'GL_LINE_NUM') THEN
        RETURN G_x_rev_gl_line_num;
     ELSIF (p_calling_place = 'GL_HEADER_NAME') THEN
        RETURN G_x_rev_gl_header_name;
     ELSIF (p_calling_place = 'GL_BATCH_NAME') THEN
        RETURN G_x_rev_gl_batch_name;
     END IF;
EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;


END get_rev_gl_header_id_line_num;

end PA_UBR_UER_SUMM_PKG;

/
