--------------------------------------------------------
--  DDL for Package Body PSP_CREATE_EFF_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_CREATE_EFF_REPORTS" AS
/* $Header: PSPERCRB.pls 120.21 2006/08/04 11:28:55 dpaudel noship $*/


PROCEDURE effort_asg_action_code (p_pactid IN NUMBER,
                                  stperson IN NUMBER,
                                  endperson IN NUMBER,
                                  p_chunk_num IN NUMBER) IS

l_object_id PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
l_object_type varchar2(3)  :='PER';
 l_cnt number;
 l_asgactid  number;


CURSOR c_person_actions(p_pactid number, stperson NUMBER, endperson NUMBER)  is
SELECT person_id from psp_selected_persons_t where
person_id between stperson and endperson and request_id in
(select request_id from pay_payroll_actions where payroll_action_id= p_pactid);

begin

 --fnd_file.put_line(fnd_file.log,'ST===='||stperson||'--END='||endperson);


   open c_person_actions(p_pactid, stperson, endperson);

   fetch c_person_actions BULK COLLECT into person_array.person_id;

  CLOSE c_person_actions;


 FOR i in 1..person_array.person_id.count

  LOOP

 select pay_assignment_actions_s.nextval into l_asgactid from dual;

 hr_nonrun_asact.insact( l_asgactid ,
                  pactid =>       p_pactid,
                  chunk =>      p_chunk_num,
                  object_id =>      person_array.person_id(i),
                  object_type =>      l_object_type,
                  p_transient_action =>      TRUE);
 END LOOP;


 select count(object_id) into l_cnt from pay_temp_object_actions where
payroll_action_id = p_pactid;

--  insert into psp_debug values(null, l_cnt);

end;



PROCEDURE PSPREP_INIT(p_payroll_action_id IN NUMBER) IS

param_string PAY_PAYROLL_ACTIONS.LEGISLATIVE_PARAMETERS%TYPE;


BEGIN


   /*  get the required parameters  */


  SELECT request_id, legislative_parameters  into g_psp_request_id, param_string from pay_payroll_actions where payroll_action_id = p_payroll_action_id;

    g_psp_template_id := psp_template_selection.get_parameter_value('TEMPLATE_ID', param_string);

    g_psp_effort_start:= trunc(fnd_date.canonical_to_date(psp_template_selection.get_parameter_value('START_DATE', param_string)));
    g_psp_effort_end:= trunc(fnd_date.canonical_to_date(psp_template_selection.get_parameter_value('END_DATE', param_string)));



-- fnd_file.put_line(fnd_file.log, 'start date i s '||g_psp_effort_start);
-- fnd_file.put_line(fnd_file.log, 'end date  is '||g_psp_effort_end);


   /*   insert record in psp_report_templates_h   */



END;



PROCEDURE  effort_archive(payroll_action_id IN NUMBER,
                           chunk_number in NUMBER) IS
errBuf varchar2(240);
retcode varchar2(1);

  begin


   --hr_utility.trace_on('Y','ORACLE');

--fnd_file.put_line(fnd_file.log,'  inside archiver' );
--fnd_file.put_line(fnd_file.log,'  chunk is '||chunk_number );
    create_effort_reports(errBuf, retcode, payroll_action_id, g_psp_request_id, chunk_number);

  end;


PROCEDURE  CREATE_EFFORT_REPORTS(
errBuf     OUT NOCOPY VARCHAR2,
 		    retCode 	    	OUT NOCOPY VARCHAR2,
                    p_pactid              IN NUMBER,
                    p_request_id        IN NUMBER,
                    p_chunk_num         IN     NUMBER
		 )   AS

BEGIN




       populate_eff_tables(errBuf ,
 		    retCode 	  ,
                    p_pactid,
                    p_request_id  ,
                    p_chunk_num
		 );



/*

p_eff_report_details_api.update_eff_report_details(p_validate , p_request_id )


*/


end;

  PROCEDURE  POPULATE_EFF_TABLES(errBuf          	OUT NOCOPY VARCHAR2,
 		    retCode 	    	OUT NOCOPY VARCHAR2,
                    p_pactid            IN NUMBER,
                    p_request_id        IN NUMBER,
                    p_chunk_num         IN     NUMBER,
                    p_supercede_mode    IN VARCHAR2    --- supercede

		 )
  AS

    l_template_id    NUMBER;
    i    NUMBER;

    CURSOR  get_summarization_criteria(p_request_id IN NUMBER) is Select criteria_lookup_code, criteria_value1
    from psp_report_template_details_h where request_id = p_request_id and
    criteria_lookup_type='PSP_SUMMARIZATION_CRITERIA' order by
    to_number(criteria_value1);


    p_effort_Start     DATE;
    p_effort_end       DATE;

  l_loop_count                   INTEGER :=0;
  l_msg_count  NUMBER;
  l_msg_data   VARCHAR2(2000);
  min_effort_report_id         number;
  l_sqlerrm  varchar2(240);
  p_validate BOOLEAN :=FALSE;
  p_warning BOOLEAN;

  l_grp_string     varchar2(4000);
  l_asg_ci_string varchar2(4000);
  l_select_string varchar2(4000);
  l_start_person      number;
  l_end_person number;
  l_element_set_id  number;
  l_return_status  varchar2(30);

  no_records_found EXCEPTION;
l_retry_request_id number;

  IN_USE_EXCEPTION		EXCEPTION;
  PRAGMA EXCEPTION_INIT (IN_USE_EXCEPTION, -54);

   effort_det_lines_rec   eff_det_lines_type;
 l_sbd_string varchar2(120);
l_sed_string varchar2(120);


 l_request_id number;

  l_profile_sob_id number;
  l_profile_bg_id number;
   l_bg_currency_code varchar2(3);
 l_gl_flag varchar2(1);
l_err_mesg varchar2(2000);
/*

  det_person_id varchar2(240) := 'effort_det_lines_rec.person_id' ;
det_assignment_id  varchar2(240) := 'effort_det_lines_rec.assignment_id' ;
det_project_id varchar2(240) :=  'effort_det_lineS_rec.project_id';

*/

cursor get_all_person(p_request_id in number)  is
 select distinct person_id from psp_selected_persons_t where request_id = p_request_id and person_id between
 l_start_person and l_end_person;

-- for supercede
cursor get_supercede_persons is
select DISTINCT person_id		-- Introduced DISTINCT for bug fix 4429787/4506505
from psp_supercede_persons_gt
where person_id > 0;

--	Introduced for bug fix 4182358
CURSOR	conc_program_name_cur IS
SELECT	fcp.concurrent_program_name
FROM	fnd_concurrent_programs fcp,
	fnd_concurrent_requests fcr
WHERE	fcp.concurrent_program_id = fcr.concurrent_program_id
AND	fcr.request_id = l_request_id;

l_program_name	fnd_concurrent_programs.concurrent_program_name%TYPE;
--	End of bug fix 4182358

Cursor HUNDRED_PCENT_EFF_CSR (p_request_id varchar2) is
SELECT HUNDRED_PCENT_EFF_AT_PER_ASG, selection_match_level
FROM psp_report_templates_h
WHERE request_id = p_request_id;

l_HUNDRED_PCENT_EFF_AT_PER_ASG varchar2(1);
l_proj_segment varchar2(30);
l_tsk_segment varchar2(30);
l_awd_sgement varchar2(30);
l_exp_org_segment varchar2(30);
l_exp_type_segment varchar2(30);
l_use_gl_ptaoe_mapping varchar2(1);
l_selection_match_level varchar2(10);

l_gt_count integer;
BEGIN

---select count(*) into l_gt_count from psp_supercede_persons_gt ;
---hr_utility.trace(' COUNT of supercede persons_gt ='|| l_gt_Count);

 l_profile_sob_id :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
 l_profile_bg_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
  l_bg_currency_code := psp_general.get_currency_code(l_profile_bg_id);


--OPEN HUNDRED_PCENT_EFF_CSR(p_request_id);		Commented for UVA bug fix 4537063
--fetch HUNDRED_PCENT_EFF_CSR into l_HUNDRED_PCENT_EFF_AT_PER_ASG, l_selection_match_level; Commented for UVA bug fix 4537063
--close HUNDRED_PCENT_EFF_CSR;				Commented for UVA bug fix 4537063

  if p_supercede_mode is null then  --- supercede


      Select nvl(max(request_id),p_request_id)  into l_request_id from psp_report_templates_h prth where request_id < p_request_id
      and payroll_action_id  = p_pactid;


    select min(object_id), max(object_id) into l_start_person, l_end_person from pay_temp_object_actions
    where  payroll_action_id =p_pactid  and chunk_number = p_chunk_num;
/*
-- Commented for bug fix 5050802
 populate_error_table( l_request_id, l_start_person, l_end_person,  min_effort_report_id, l_retry_request_id, 'PRE-POPULATE',
   l_selection_match_level);
*/
   else


      l_request_id :=p_request_id;

 end if;

--	Moved the following cursor here as p_rquest_id will not have CER request id during Retry Runs.
OPEN HUNDRED_PCENT_EFF_CSR(l_request_id);
fetch HUNDRED_PCENT_EFF_CSR into l_HUNDRED_PCENT_EFF_AT_PER_ASG, l_selection_match_level;
close HUNDRED_PCENT_EFF_CSR;

--	Moved the following call here as l_selection_match_level was not available before opening the cursor
if p_supercede_mode is null then
   populate_error_table( l_request_id, l_start_person, l_end_person,  min_effort_report_id, l_retry_request_id, 'PRE-POPULATE',
     l_selection_match_level);
end if;


/*
	OPEN conc_program_name_cur;
	FETCH conc_program_name_cur INTO l_program_name;
	CLOSE conc_program_name_cur;

	IF (l_program_name = 'PSPRTEF') THEN
		l_retry_request_id :=g_psp_request_id;
	END IF;


 else
   l_request_id := p_request_id;
 end if;

*/



-- fnd_file.put_line(fnd_file.log, 'g_psp_request_id  is '||g_psp_request_id);
--  fnd_file.put_line(fnd_file.log, 'l_request__id  '||l_request_id);
--  fnd_file.put_line(fnd_file.log, ' before starting l_retry_request__id  '||l_retry_request_id);

     IF g_psp_request_id = l_request_id then
        l_retry_request_id := NULL;
     ELSE
       l_retry_request_id :=g_psp_request_id;
     END IF;



  -- fnd_file.put_line(fnd_file.log, 'request i dis '|| p_request_id);
 --  fnd_file.put_line(fnd_file.log, ' retry request i dis ' || l_retry_request_id);



           hr_utility.trace('psp_create_eff_reports--> request_id, retry_request_id, st_person, end_person = '|| p_request_id||' '||l_retry_request_id ||' '|| l_start_person||' '|| l_end_person);


 -- fnd_file.put_line(fnd_file.log,' retry_Request_id  = '||l_retry_request_id );
    select parameter_value_2, parameter_value_3 into p_effort_start, p_effort_end from
    psp_report_templates_h where request_id = l_request_id;

     select criteria_value1 into l_element_set_id from psp_report_template_details_h where
     criteria_lookup_code='EST' and request_id = l_request_id;


/*
	   and   action_status<> 'C';

*/

 --fnd_file.put_line(fnd_file.log,' chunk num = *** '||p_chunk_num||'start_end= '||l_Start_person ||'  '||l_end_person );
   ----  Warning: any change in this string will impact superceding,
   -----  change here needs to sync up with query for superceding.
    g_exec_string := '
      SELECT
     person_id , ASSIGNMENT_ID,
     PROJECT_ID, TASK_ID,
     AWARD_ID, EXPENDITURE_ORGANIZATION_ID, EXPENDITURE_TYPE,
     SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5,
     SEGMENT6, SEGMENT7, SEGMENT8, SEGMENT9, SEGMENT10,
     SEGMENT11, SEGMENT12, SEGMENT13, SEGMENT14, SEGMENT15,
     SEGMENT16, SEGMENT17, SEGMENT18, SEGMENT19, SEGMENT20,
     SEGMENT21, SEGMENT22, SEGMENT23, SEGMENT24, SEGMENT25,
     SEGMENT26, SEGMENT27, SEGMENT28, SEGMENT29, SEGMENT30,
     SUM(distribution_amount) distribution_amount, MAX(distribution_date1) , max(distribution_date2)

 bulk collect into
 :det_person_id, :det_assignment_id, :det_project_id, :det_task_id , :det_award_id,
:det_exp_org_id,
:det_exp_type,
:det_segment1, :det_segment2, :det_segment3, :det_segment4, :det_segment5, :det_segment6,
:det_segment7, :det_segment8, :det_segment9,
 :det_segment10, :det_segment11, :det_segment12,
 :det_segment13, :det_segment14, :det_segment15,
 :det_segment16, :det_segment17, :det_segment18,
 :det_segment19, :det_segment20, :det_segment21,
 :det_segment22 , :det_segment23, :det_segment24,
 :det_segment25, :det_segment26, :det_segment27,
 :det_segment28, :det_segment29, :det_segment30  ,
 :det_dist_amount, :det_sch_st_date,
:det_sch_end_date
      from (
       SELECT
      psl.person_id person_id, null ASSIGNMENT_ID,
      null PROJECT_ID, null TASK_ID,
      null AWARD_ID, null EXPENDITURE_ORGANIZATION_ID, null EXPENDITURE_TYPE, null SEGMENT1, null SEGMENT2, null SEGMENT3, null SEGMENT4,
      null SEGMENT5, null SEGMENT6, null SEGMENT7, null SEGMENT8, null SEGMENT9,
      null SEGMENT10, null SEGMENT11, null SEGMENT12, null SEGMENT13, null SEGMENT14,
      Null SEGMENT15, null SEGMENT16, null SEGMENT17, null SEGMENT18, null SEGMENT19, null SEGMENT20,
      Null SEGMENT21, null SEGMENT22, null SEGMENT23, null SEGMENT24, null SEGMENT25, null SEGMENT26, null SEGMENT27, null SEGMENT28, null SEGMENT29, null SEGMENT30,
/*
   sum(decode(psl.dr_cr_flag,'||''''||'D'||''''||',nvl(pdnh.distribution_amount,nvl(ppg.distribution_amount, pal.distribution_amount)), nvl(-pdnh.distribution_amount, nvl(-ppg.distribution_amount,
  -pal.distribution_amount)))) distribution_amount,
*/
   decode(psl.dr_cr_flag,'||''''||'D'||''''||',nvl(pdnh.distribution_amount,nvl(ppg.distribution_amount, pal.distribution_amount)), nvl(-pdnh.distribution_amount, nvl(-ppg.distribution_amount,
  -pal.distribution_amount))) distribution_amount,
	null distribution_date1, null distribution_date2
   FROM
          psp_distribution_lines_history  pdnh,
          psp_summary_lines               psl,
          psp_Selected_persons_t pspt,
          psp_pre_gen_dist_lines_history ppg,
          psp_adjustment_lineS_history pal,
          psp_payroll_sub_lines ppsl,
          psp_payroll_lines ppl
	  WHERE psl.person_id = pspt.person_id
     and pspt.request_id = :l_request_id
     and  pspt.person_id between :l_start_person and :l_end_person
     and psl.summary_line_id = pdnh.summary_line_id(+)
     and pdnh.payroll_sub_line_id= ppsl.payroll_sub_line_id(+) and
      ppsl.payroll_line_id = ppl.payroll_line_id(+)
     and psl.summary_line_id = ppg.summary_line_id(+)
     and psl.summary_line_id = pal.summary_line_id(+)
     AND psl.status_code = '||''''||'A'||''''||'
   AND
   (  EXISTS
      (select 1 from psp_element_set_members_v pesr where  pesr.element_set_id = :l_element_set_id and
          pesr.element_type_id = ppl.element_type_id )
       OR EXISTS
          (select 1 from psp_element_set_members_v pesr where pesr.element_set_id =
           :l_element_set_id  and pesr.element_type_id = pal.element_type_id)
        OR EXISTS
          (select 1 from psp_element_set_members_v pesr where pesr.element_set_id =
           :l_element_set_id  and pesr.element_type_id = ppg.element_type_id )
       ) AND
      /* pspt.person_id  not in (select person_id from psp_eff_reports pea where
      pea.end_date >= :effort_start and pea.start_date <= :effort_end and
       status_code in ('||''''||'N'||''''||','||''''||'A'||''''||')) AND */
 ((psl.source_type in ('||''''||'N'||''''||' , '|| ''''|| 'O' ||'''' ||' ) and
      psl.summary_line_id = pdnh.summary_line_id
   and pdnh.distribution_date between :effort_start and :effort_end
   AND    pdnh.reversal_entry_flag is NULL
   AND    pdnh.adjustment_batch_name is null
)
   OR  (psl.source_type=' ||''''|| 'P'||'''' || '
   AND    ppg.status_code ='||''''||'A' || ''''||'
       and ppg.distribution_date between :effort_start  and :effort_end
   AND    ppg.reversal_entry_flag is NULL
   AND    ppg.summary_line_id  = psl.summary_line_id
   AND    ppg.adjustment_batch_name is null
 )
   OR (psl.source_type='||'''' || 'A' || ''''||'
          and pal.distribution_date between :effort_start and :effort_end
   AND    pal.status_code = ' || ''''|| 'A' || ''''|| '
   AND    NVL(pal.original_line_flag, ' || ''''|| 'N' || ''''|| ') = '||''''|| 'N' || ''''
   || ' AND    pal.reversal_entry_flag is NULL
    AND pal.summary_line_id = psl.summary_line_id
   AND   pal.adjustment_batch_name is null
))
/* Added for hospital effort report Change*/
UNION ALL
SELECT
      psl.person_id person_id, null ASSIGNMENT_ID,
      null PROJECT_ID, null TASK_ID,
      null AWARD_ID, null EXPENDITURE_ORGANIZATION_ID, null EXPENDITURE_TYPE,
      null SEGMENT1, null SEGMENT2, null SEGMENT3, null SEGMENT4, null SEGMENT5,
      null SEGMENT6, null SEGMENT7, null SEGMENT8, null SEGMENT9, null SEGMENT10,
      null SEGMENT11, null SEGMENT12, null SEGMENT13, null SEGMENT14, Null SEGMENT15,
      null SEGMENT16, null SEGMENT17, null SEGMENT18, null SEGMENT19, null SEGMENT20,
      Null SEGMENT21, null SEGMENT22, null SEGMENT23, null SEGMENT24, null SEGMENT25,
      null SEGMENT26, null SEGMENT27, null SEGMENT28, null SEGMENT29, null SEGMENT30,
      psl.distribution_amount distribution_amount, null , null
FROM  psp_external_effort_lines psl,
      psp_Selected_persons_t pspt
      WHERE psl.person_id = pspt.person_id
and pspt.request_id = :l_request_id
AND   pspt.person_id between :l_start_person and :l_end_person
/*
AND   EXISTS (select 1
              from psp_element_set_members_v pesr
              where  pesr.element_set_id = :l_element_set_id
              and pesr.element_type_id = psl.element_type_id)
*/
AND   psl.distribution_date between :effort_start and :effort_end
)
group by
person_id , ASSIGNMENT_ID,
     PROJECT_ID, TASK_ID,
     AWARD_ID, EXPENDITURE_ORGANIZATION_ID, EXPENDITURE_TYPE,
     SEGMENT1, SEGMENT2, SEGMENT3, SEGMENT4, SEGMENT5,
     SEGMENT6, SEGMENT7, SEGMENT8, SEGMENT9, SEGMENT10,
     SEGMENT11, SEGMENT12, SEGMENT13, SEGMENT14, SEGMENT15,
     SEGMENT16, SEGMENT17, SEGMENT18, SEGMENT19, SEGMENT20,
     SEGMENT21, SEGMENT22, SEGMENT23, SEGMENT24, SEGMENT25,
     SEGMENT26, SEGMENT27, SEGMENT28, SEGMENT29, SEGMENT30
/*psl.person_id  */
';

if p_supercede_mode is not null then
 ---fnd_file.put_line(fnd_file.log,' supercede mode is not null, changing the exec string  ');
   hr_utility.trace('    create_eff --> supercede mode is not null, changing the exec string  ');
  --- added for uva issues (assignment matching only)
  -- rows inserted thru supercede will have -ve request_id and will be rolled
   --- back immediately by summarize_transfer process (transient)

--Bug 5237611: Fixed terminated assignment Issue, added FF suport for assignment
/*
   if l_selection_match_level = 'EMP' then
     insert into psp_selected_persons_t (request_id, person_id)
     select  -1 * l_request_id, gt.person_id from psp_supercede_persons_gt gt
        where gt.person_id > 0 ;
   else
  */
     insert into psp_selected_persons_t (request_id, person_id, assignment_id)
     select  -1 * l_request_id, person_id, assignment_id
       from psp_Eff_reports er,
            psp_eff_report_details erd
      where er.effort_Report_id = erd.effort_Report_id
        and er.request_id = l_request_id
        and er.status_code in ('N','A')
        and er.person_id in (select person_id from psp_supercede_persons_gt where person_id > 0) ;
  g_exec_string := replace(g_exec_string, 'psl.person_id = pspt.person_id' ,
      'psl.person_id = pspt.person_id and psl.assignment_id = pspt.assignment_id ');
--   end if;
   g_exec_string := replace(g_exec_string, 'pspt.person_id between :l_start_person and :l_end_person' ,
                  ' nvl(:l_start_person,-9) = nvl(:l_start_person,-9) and
                    nvl(:l_end_person,-9) = nvl(:l_end_person,-9) ');
   g_exec_string := replace(g_exec_string, 'pea.end_date >= :effort_start and pea.start_date <= :effort_end and',null);
   g_exec_string := replace(g_exec_string, 'status_code in ('||''''||'N'||''''||','||''''||'A'||''''||')) AND',null);
   g_exec_string := replace(g_exec_string, 'pspt.person_id  not in (select person_id from psp_eff_reports pea where',null);
   g_exec_string := replace(g_exec_string, 'group by psl.person_id',
' and pspt.person_id in (select person_id from psp_Eff_reports where request_id ='|| p_request_id||'  and status_code in ( '||''''||'A'||''''||','||''''||'N'||''''||'))  group by psl.person_id');
  g_exec_string := replace(g_exec_string, 'and pspt.request_id = :l_request_id',
          ' and -1 * pspt.request_id = :l_request_id and pspt.skip_reason is null ');
else
  -- added for UVA issue.
  g_exec_string := replace(g_exec_string, 'and pspt.request_id = :l_request_id',
          ' and pspt.request_id = :l_request_id and pspt.skip_reason is null ');
-- if l_selection_match_level = 'ASG' then
  g_exec_string := replace(g_exec_string, 'psl.person_id = pspt.person_id' ,
      'psl.person_id = pspt.person_id and psl.assignment_id = pspt.assignment_id ');
--  end if;
end if;

     OPEN get_summarization_criteria(l_request_id);


      FETCH get_summarization_criteria  BULK collect into  eff_template_sum_rec.array_sum_criteria,
      eff_template_sum_rec.array_sum_order;

     CLOSE get_summarization_criteria;
-- Bug Fix 4244924:YALE ENHANCEMENTS
    IF PSP_GENERAL.GET_CONFIGURATION_OPTION_VALUE(l_profile_bg_id,'PSP_USE_GL_PTAOE_MAPPING') = 'Y' THEN
        PSP_GENERAL.GET_GL_PTAOE_MAPPING(p_business_group_id => l_profile_bg_id,
                      p_proj_segment => l_proj_segment,
                      p_tsk_segment => l_tsk_segment,
                      p_awd_sgement => l_awd_sgement,
                      p_exp_org_segment=> l_exp_org_segment,
                      p_exp_type_segment => l_exp_type_segment);
    END IF;


      FOR I IN 1..EFF_TEMPLATE_SUM_REC.ARRAY_SUM_CRITERIA.COUNT

        LOOP

        IF PSP_GENERAL.GET_CONFIGURATION_OPTION_VALUE(l_profile_bg_id,'PSP_USE_GL_PTAOE_MAPPING') = 'N' THEN
	   IF substr(eff_template_sum_rec.array_sum_criteria(i),1,7) = 'SEGMENT' then
                 g_exec_string:= replace(g_exec_string, 'null '||eff_template_sum_rec.array_sum_criteria(i)||',',
                 eff_template_sum_rec.array_sum_criteria(i) ||',');
                 l_select_string:= ' and psl.gl_code_combination_id = gcc.code_combination_id(+) ';
                 l_gl_flag:='Y';
--               g_exec_string:= replace(g_exec_string, ' psl.person_id = pspt.person_id', ' psl.person_id = pspt.person_id '||l_select_string);
                 l_grp_string:= l_grp_string || ',' ||'gcc.'|| eff_template_sum_rec.array_sum_criteria(i) ;

	   ELSIF eff_template_sum_rec.array_sum_criteria(i)= 'SSD' then
--                 l_sbd_string := 'min(nvl(pdnh.distribution_date, nvl(ppg.distribution_date, pal.distribution_date))) distribution_date1';
                 l_sbd_string := 'nvl(pdnh.distribution_date, nvl(ppg.distribution_date, pal.distribution_date)) distribution_date1';
	         g_exec_string:= replace(g_exec_string, 'null distribution_date1', l_sbd_string);
           ELSIF eff_template_sum_rec.array_sum_criteria(i)='SED' then
--                 l_sed_string:=' max(nvl(pdnh.distribution_date, nvl(ppg.distribution_date, pal.distribution_date ))) distribution_date2';
                 l_sed_string:=' nvl(pdnh.distribution_date, nvl(ppg.distribution_date, pal.distribution_date )) distribution_date2';
                 g_exec_string:= replace(g_exec_string, 'null distribution_date2', l_sed_string);
           ELSE
                 g_exec_string := replace(g_exec_string, 'null '||eff_template_sum_rec.array_sum_criteria(i)||',', 'psl.'||eff_template_sum_rec.array_sum_criteria(i)||',');
                 l_grp_string := l_grp_string || ', ' ||'psl.'||eff_template_sum_rec.array_sum_criteria(i);
           END IF;
	ELSE
-- Bug Fix 4244924:YALE ENHANCEMENTS
            IF eff_template_sum_rec.array_sum_criteria(i)= 'GL:PROJECT_ID' then
                 g_exec_string:= replace(g_exec_string,  'null PROJECT_ID,', 'gcc.'|| l_proj_segment ||' PROJECT_ID,');
                 l_select_string:= ' and psl.gl_code_combination_id = gcc.code_combination_id(+) ';
                 l_gl_flag:='Y';
                 l_grp_string:= l_grp_string || ',' ||'gcc.'|| l_proj_segment ;
            ELSIF eff_template_sum_rec.array_sum_criteria(i)= 'GL:TASK_ID' then
                 g_exec_string:= replace(g_exec_string,  'null TASK_ID,', 'gcc.'|| l_tsk_segment ||' TASK_ID,');
                 l_select_string:= ' and psl.gl_code_combination_id = gcc.code_combination_id(+) ';
                 l_gl_flag:='Y';
                 l_grp_string:= l_grp_string || ',' ||'gcc.'|| l_tsk_segment ;
            ELSIF eff_template_sum_rec.array_sum_criteria(i)= 'GL:AWARD_ID' then
                 g_exec_string:= replace(g_exec_string,  'null AWARD_ID,', 'gcc.'|| l_awd_sgement ||' AWARD_ID,');
                 l_select_string:= ' and psl.gl_code_combination_id = gcc.code_combination_id(+) ';
                 l_gl_flag:='Y';
                 l_grp_string:= l_grp_string || ',' ||'gcc.'|| l_awd_sgement ;
            ELSIF eff_template_sum_rec.array_sum_criteria(i)= 'GL:EXPENDITURE_ORGANIZATION_ID' then
                 g_exec_string:= replace(g_exec_string,  'null EXPENDITURE_ORGANIZATION_ID,', 'gcc.'|| l_exp_org_segment ||' EXPENDITURE_ORGANIZATION_ID,');
                 l_select_string:= ' and psl.gl_code_combination_id = gcc.code_combination_id(+) ';
                 l_gl_flag:='Y';
                 l_grp_string:= l_grp_string || ',' ||'gcc.'|| l_exp_org_segment ;
            ELSIF eff_template_sum_rec.array_sum_criteria(i)= 'GL:EXPENDITURE_TYPE' then
                 g_exec_string:= replace(g_exec_string,  'null EXPENDITURE_TYPE,', 'gcc.'|| l_exp_type_segment ||' EXPENDITURE_TYPE,');
                 l_select_string:= ' and psl.gl_code_combination_id = gcc.code_combination_id(+) ';
                 l_gl_flag:='Y';
                 l_grp_string:= l_grp_string || ',' ||'gcc.'|| l_exp_type_segment ;
            ELSIF eff_template_sum_rec.array_sum_criteria(i)= 'SSD' then
--                 l_sbd_string := 'min(nvl(pdnh.distribution_date, nvl(ppg.distribution_date, pal.distribution_date))) distribution_date1';
                 l_sbd_string := 'nvl(pdnh.distribution_date, nvl(ppg.distribution_date, pal.distribution_date)) distribution_date1';
                 g_exec_string:= replace(g_exec_string, 'null distribution_date1', l_sbd_string);
            ELSIF eff_template_sum_rec.array_sum_criteria(i)='SED' then
--                 l_sed_string:=' max(nvl(pdnh.distribution_date, nvl(ppg.distribution_date, pal.distribution_date))) distribution_date2';
                 l_sed_string:=' nvl(pdnh.distribution_date, nvl(ppg.distribution_date, pal.distribution_date)) distribution_date2';
                 g_exec_string:= replace(g_exec_string, 'null distribution_date2', l_sed_string);
            ELSE
                 g_exec_string := replace(g_exec_string, 'null '||eff_template_sum_rec.array_sum_criteria(i)||',', 'psl.'||eff_template_sum_rec.array_sum_criteria(i)||',');
                 l_grp_string := l_grp_string || ', ' ||'psl.'||eff_template_sum_rec.array_sum_criteria(i);
            END IF;
	END IF;
        END LOOP;

     IF NVL(l_gl_flag, 'N') ='Y' then

            g_exec_string:= replace(g_exec_string, ' psl.person_id = pspt.person_id', ' psl.person_id = pspt.person_id '||l_select_string);

--        g_exec_string:=replace(g_exec_string,'ppl WHERE','ppl, gl_code_combinations gcc WHERE');
        g_exec_string:=replace(g_exec_string,'WHERE psl.person_id = pspt.person_id',', gl_code_combinations gcc WHERE psl.person_id = pspt.person_id');
       END IF;

--    g_exec_string :=  replace(g_exec_string, ' group by psl.person_id ' , ' group by person_id'||l_grp_string);


--fnd_file.put_line(fnd_file.log,' dyn sql = '||g_exec_string);
--fnd_file.put_line(fnd_file.log,' dyn sql = '||l_grp_string);

 --- hr_utility.trace(' dyn sql = '||g_exec_string);

/*
  det_string := '
    effort_det_lines_rec.person_id,
effort_det_lines_rec.assignment_id,
effort_det_lineS_rec.project_id, effort_det_lineS_rec.task_id ,
effort_Det_lines_rec.award_id,
effort_det_lines_rec.expenditure_organization_id,
*/


execute immediate ' begin ' ||g_exec_string ||';
     end; ' using
 OUT det_person_id,
OUT det_assignment_id ,
OUT det_project_id,
OUT det_task_id ,
OUT det_award_id,
OUT det_exp_org_id,
OUT det_expenditure_type,
OUT det_segment1,
OUT det_segment2,
OUT det_segment3,
OUT det_segment4,
OUT det_segment5,
OUT det_segment6,
OUT det_segment7,
OUT det_segment8,
OUT det_segment9,
OUT det_segment10,
OUT det_segment11,
OUT  det_segment12,
OUT det_segment13,
OUT  det_segment14,
OUT  det_segment15,
OUT  det_segment16,
OUT  det_segment17,
OUT  det_segment18,
OUT  det_segment19,
OUT det_segment20,
OUT det_segment21,
OUT  det_segment22 ,
OUT  det_segment23,
OUT det_segment24,
OUT  det_segment25,
OUT  det_segment26,
OUT  det_segment27,
OUT det_segment28,
OUT  det_segment29,
OUT  det_segment30  ,
OUT  det_distribution_amount,
OUT  det_schedule_start_date,
OUT  det_schedule_end_date,
IN l_request_id, l_start_person, l_end_person, l_element_set_id, p_effort_start, p_effort_end
;

--  fnd_file.put_line(fnd_file.log,' =====after dyn sql   '||i);

            hr_utility.trace('psp_create_eff_reports--> After dyn sql');




  SELECT NVL(max(effort_report_id),0) into min_effort_report_id from psp_eff_reports;
  if p_supercede_mode is null then
    OPEN get_all_person(l_request_id);
    FETCH get_all_person  bulk collect into person_rec.array_person_id;
    CLOSE get_all_person;
  else
    -- added following global var for Supercede process
    g_summarization_criteria := l_grp_string;
    OPEN get_supercede_persons;
    FETCH  get_supercede_persons  bulk collect into person_rec.array_person_id;
    CLOSE  get_supercede_persons;
            hr_utility.trace('   psp_create_eff_reports--> get_supercede_persons Count = '|| person_rec.array_person_id.count);
  end if;



            hr_utility.trace('psp_create_eff_reports--> After bulk fetch');
--   fnd_file.put_line(fnd_file.log,' after bulk fetch ');

 --  fnd_file.put_line(fnd_file.log, 'count is '||effort_det_lines_rec.person_id.count);


/*
   IF effort_det_lines_rec.person_id.count > 0 then

    l_loop_count := l_loop_count + effort_det_lines_rec.person_id.count;


*/

     -- fnd_file.put_line(fnd_file.log, 'count person is '||det_person_id.count);
    hr_utility.trace ('count person is '||det_person_id.count);

     IF det_person_id.count >0   then
     l_loop_count := l_loop_count + det_person_id.count;
--   fnd_file.put_line(fnd_file.log,' before inserting into psp_eff_reports ');

--  fnd_file.put_line(fnd_file.log,' =====inserting in  psp_eff_reports   ');

    FORALL i IN 1..person_rec.array_person_id.count
      insert into psp_eff_reports(
       effort_report_id,
      status_code,
      person_id,
      object_version_number,
      start_date,
      end_date,
      template_id,
      request_id,
      currency_code,
      last_update_date,
      last_updated_by,
      last_update_login,
      created_by,
      creation_date,
      business_group_id,
      set_of_books_id
        )
      values
         (
       psp_effort_reports_s.nextval,
       decode(p_supercede_mode , null, 'N', 'T'),
    person_rec.array_person_id(i),
         1,
       p_effort_Start,
       p_effort_end,
       decode(p_supercede_mode, null, g_psp_template_id, -999),
       l_request_id,
       l_bg_currency_code,
       sysdate,
       fnd_global.user_id ,
        fnd_global.user_id,
        fnd_global.user_id,
        sysdate,
         l_profile_bg_id,
         l_profile_sob_id) returning effort_report_id bulk collect into person_rec.array_effort_report_id;

 end if;

--   fnd_file.put_line(fnd_file.log , 'after insert into eff '||person_rec.array_effort_report_id.count);


           hr_utility.trace('psp_create_eff_reports--> After insert into eff '||person_rec.array_effort_report_id.count);
/*

*/




   -- fnd_file.put_line(fnd_file.log,' before inserting into psp_report_details ');

--  fnd_file.put_line(fnd_file.log,' =====inserting in  psp_eff_report_details   ');

           hr_utility.trace('psp_create_eff_reports--> before inserting into details ');

 FORALL i in 1..det_person_id.count
  insert into psp_eff_report_details(
 effort_report_detail_id,
 effort_report_id,
object_version_number,
assignment_id,
GL_SEGMENT1,
GL_SEGMENT2,
GL_SEGMENT3,
GL_SEGMENT4,
GL_SEGMENT5,
GL_SEGMENT6,
GL_SEGMENT7,
GL_SEGMENT8,
GL_SEGMENT9,
GL_SEGMENT10,
GL_SEGMENT11,
GL_SEGMENT12,
GL_SEGMENT13,
GL_SEGMENT14,
GL_SEGMENT15,
GL_SEGMENT16,
GL_SEGMENT17,
GL_SEGMENT18,
GL_SEGMENT19,
GL_SEGMENT20,
GL_SEGMENT21,
GL_SEGMENT22,
GL_SEGMENT23,
GL_SEGMENT24,
GL_SEGMENT25,
GL_SEGMENT26,
GL_SEGMENT27,
GL_SEGMENT28,
GL_SEGMENT29,
GL_SEGMENT30,
project_id,
expenditure_organization_id,
expenditure_type,
task_id,
award_id,
actual_salary_amt,
payroll_percent,
schedule_start_date,
schedule_end_date,
last_update_date,
last_updated_by,
last_update_login,
created_by,
creation_date)
values
(
psp_eff_report_details_s.nextval,
1,
1,
          det_assignment_id(i),
          det_segment1(i),
          det_segment2(i),
          det_segment3(i),
          det_segment4(i),
          det_segment5(i),
          det_segment6(i),
          det_segment7(i),
          det_segment8(i),
          det_segment9(i),
          det_segment10(i),
          det_segment11(i),
          det_segment12(i),
          det_segment13(i),
          det_segment14(i),
          det_segment15(i),
          det_segment16(i),
          det_segment17(i),
          det_segment18(i),
          det_segment19(i),
          det_segment20(i),
          det_segment21(i),
          det_segment22(i),
          det_segment23(i),
          det_segment24(i),
          det_segment25(i),
          det_segment26(i),
          det_segment27(i),
          det_segment28(i),
          det_segment29(i),
          det_segment30(i),
          det_project_id(i),
          det_exp_org_id(i) ,
          det_expenditure_type(i),
          det_task_id(i),
          det_award_id(i),
          det_distribution_amount(i),
           0,
          det_schedule_start_date(i),
          det_schedule_end_date(i),
          sysdate,
          fnd_global.user_id,
          fnd_global.user_id,
          fnd_global.user_id,
          sysdate
) returning  to_number(det_person_id(i)), effort_report_detail_id bulk collect into effort_det_lines_rec.person_id, effort_det_lines_rec.effort_report_detail_id;


 -- fnd_file.put_line(fnd_file.log,'==== after det  '|| effort_det_lines_rec.effort_report_detail_id.count);




  -- fnd_file.put_line(fnd_file.log,' after deatils ');

--  fnd_file.put_line(fnd_file.log,' ===== IF p_supercede_mode is not null THEN ');

IF p_supercede_mode is not null THEN
           hr_utility.trace('     psp_create_eff_reports--> updating erd count ='|| effort_det_lines_rec.effort_report_detail_id.count ||' min_effort_Report_id = '||min_effort_report_id );

 FORALL i in 1..effort_det_lines_rec.effort_report_detail_id.count
 update psp_eff_report_details set effort_report_id =
(select effort_report_id from psp_eff_reports  where
person_id =effort_Det_lines_rec.person_id(i) and status_code = 'T'
and request_id = l_request_id )  where
effort_report_detail_id= effort_det_lines_rec.effort_report_detail_id(i) ;

ELSE

 FORALL i in 1..effort_det_lines_rec.effort_report_detail_id.count
 update psp_eff_report_details set effort_report_id =
(select effort_report_id from psp_eff_reports  where
person_id =effort_Det_lines_rec.person_id(i) and effort_report_id > min_effort_report_id )  where
effort_report_detail_id= effort_det_lines_rec.effort_report_detail_id(i) ;

END IF;



     -- fnd_file.put_line(fnd_file.log,' after update of effort report details ');

           hr_utility.trace('psp_create_eff_reports--> After update of psp_eff_report_detail ');

effort_Det_lines_rec.effort_report_detail_id.delete;
effort_det_lines_rec.person_id.delete;



 /* delete the det_details arrays   */

det_person_id.delete;
det_assignment_id.delete;
det_project_id.delete;
det_task_id.delete;
det_award_id.delete;
det_exp_org_id.delete;
det_expenditure_type.delete;
det_segment1.delete;
det_segment2.delete;
det_segment3.delete;
det_segment4.delete;
det_segment5.delete;
det_segment6.delete;
det_segment7.delete;
det_segment8.delete;
det_segment9.delete;
det_segment10.delete;
det_segment11.delete;
det_segment12.delete;
det_segment13.delete;
det_segment14.delete;
det_segment15.delete;
det_segment16.delete;
det_segment17.delete;
det_segment18.delete;
det_segment19.delete;
det_segment20.delete;
det_segment21.delete;
det_segment22.delete;
det_segment23.delete;
det_segment24.delete;
det_segment25.delete;
det_segment26.delete;
det_segment27.delete;
det_segment28.delete;
det_segment29.delete;
det_segment30.delete;
det_distribution_amount.delete;
det_schedule_start_date.delete;
det_schedule_end_date.delete;

-- OHSU Changes


--  fnd_file.put_line(fnd_file.log,' ===== IF l_HUNDRED_PCENT_EFF_AT_PER_ASG');

IF l_HUNDRED_PCENT_EFF_AT_PER_ASG = 'A' then

	select sum(actual_salary_amt), effort_report_id, assignment_id bulk collect
	into person_rec.sum_tot, person_rec.array_effort_report_id, person_rec.array_assignment_id
	from psp_eff_report_details where
	effort_report_id > min_effort_report_id  group by effort_report_id, assignment_id;

	hr_utility.trace('psp_create_eff_reports--> After getting sum');

	FORALL i in 1..person_rec.array_assignment_id.count
	      update psp_Eff_report_details set  payroll_percent =  decode(person_rec.sum_tot(i),0,0,round( ((actual_salary_amt * 100) / person_rec.sum_tot(i)),2))
	      where  effort_report_id = person_rec.array_effort_report_id(i)
		and assignment_id = person_rec.array_assignment_id(i);


	person_rec.array_effort_report_id.delete;
	person_rec.sum_tot.delete;
	person_rec.array_assignment_id.delete;


	select sum(payroll_percent), effort_report_id, assignment_id bulk collect
		 into person_rec.payroll_percent_tot, person_rec.array_effort_report_id, person_rec.array_assignment_id
		 from psp_eff_report_details where  effort_report_id > min_effort_report_id group by effort_report_id , assignment_id;


	hr_utility.trace('psp_create_eff_reports--> After  sum payroll percent');

	FORALL i in 1..person_rec.array_assignment_id.count
		  update psp_eff_report_details set payroll_percent = payroll_percent + (100.00 - person_rec.payroll_percent_tot(i))
		  where effort_report_detail_id in (
						    select max(effort_report_detail_id)
						    from psp_eff_report_details
						    where effort_report_id = person_rec.array_effort_report_id(i)
						    and person_rec.payroll_percent_tot(i)<>0 and
						    assignment_id =  person_rec.array_assignment_id(i)
						    ) ;
ELSE

	 select sum(actual_salary_amt), effort_report_id  bulk collect into person_rec.sum_tot, person_rec.array_effort_report_id
	 from psp_eff_report_details where
	 effort_report_id > min_effort_report_id  group by effort_report_id ;

	hr_utility.trace('psp_create_eff_reports--> After getting sum');

   ---  fnd_file.put_line(fnd_file.log,' after getting sum ');

	FORALL i in 1..person_rec.array_effort_report_id.count
	-- update psp_Eff_report_details set payroll_percent = round(actual_salary_amt/person_rec.sum_tot(i),2)*100  where  effort_report_id =
	-- person_rec.array_effort_report_id(i);
	-- check for zero sum , flag error if so
	 update psp_Eff_report_details set payroll_percent =  decode(person_rec.sum_tot(i),0,0,round( ((actual_salary_amt * 100) / person_rec.sum_tot(i)),2))  where  effort_report_id =
	 person_rec.array_effort_report_id(i);

	person_rec.array_effort_report_id.delete;
	person_rec.sum_tot.delete;


	select sum(payroll_percent), effort_report_id
        bulk collect into person_rec.payroll_percent_tot, person_rec.array_effort_report_id
        from psp_eff_report_details where  effort_report_id > min_effort_report_id group by effort_report_id ;


	FORALL i in 1..person_rec.array_effort_report_id.count
        update psp_eff_report_details set payroll_percent = payroll_percent + (100.00 - person_rec.payroll_percent_tot(i))  where
        effort_report_detail_id in (select max(effort_report_detail_id) from psp_eff_report_details where
        effort_report_id = person_rec.array_effort_report_id(i) and person_rec.payroll_percent_tot(i)<>0) ;
END IF;

--  fnd_file.put_line(fnd_file.log,' after getting sum ');


/*
 should be person or assignment depending on whether assignment is used as a summarization criteria
 */


-- OHSU Changes
/*

*/


 /* to update the last line in the case it exceeds 100 */


    -- fnd_file.put_line(fnd_file.log,' after details update ');



-- OHSU Changes
/*

*/

/*



*/

  /* Add the difference if any to the last detail  line for each effort report_id  */


-- OHSU Changes
/*
  FORALL i in 1..person_rec.array_effort_report_id.count
          update psp_eff_report_details set payroll_percent = payroll_percent + (100.00 - person_rec.payroll_percent_tot(i))  where
          effort_report_detail_id in (select max(effort_report_detail_id) from psp_eff_report_details where
          effort_report_id = person_rec.array_effort_report_id(i) and person_rec.payroll_percent_tot(i)<>0) ;
*/


     delete from psp_eff_reports per where effort_report_id > min_effort_report_id and
     not exists (select 1 from psp_eff_report_details perd  where
     perd.effort_report_id = per.effort_report_id);

     -- fnd_file.put_line(fnd_file.log,' after delete of orphan record ');


/* added this call just to see how retry works

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


*/




if p_supercede_mode is not null then


    -- fnd_file.put_line(fnd_file.log,' before return ');
  retcode := 0;
  return;
end if;





 -- get cost share info

--   psp_eff_report_details_api.update_eff_report_details(l_request_id);

 --psp_eff_report_details_api.update_eff_report_details(p_validate , l_request_id, p_warning );
 /* for Bug fix 4089645 Added Person id check */
--  fnd_file.put_line(fnd_file.log,' ===== Populate_error_table');


Populate_error_table( l_request_id, l_start_person, l_end_person,  min_effort_report_id, l_retry_request_id, null, null);

 if person_rec.array_effort_report_id.count  >0 then

   person_rec.array_effort_report_id.delete;
   person_rec.payroll_percent_tot.delete;
/*
    IF PSP_GENERAL.GET_CONFIGURATION_OPTION_VALUE(l_profile_bg_id,'PSP_USE_GL_PTAOE_MAPPING') = 'Y' THEN
	psp_xmlgen.copy_ptaoe_from_gl_segments(l_start_person ,
                                             l_end_person  ,
                                             l_request_id,
                                             l_retry_request_id,
                                             l_profile_bg_id,
                                             l_return_status) ;
         hr_utility.trace('psp_create_eff_reports--> After xmlgen.copy_ptaoe_from_gl_segments');

       If (l_return_status =  fnd_api.g_ret_sts_error) or (l_return_status = fnd_api.g_ret_sts_unexp_error)  then
            psp_message_s.print_error(p_mode=>FND_FILE.log,
                                      p_print_header=>FND_API.G_TRUE);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END IF;
    END IF;
*/

    if p_warning = true then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

          hr_utility.trace('psp_create_eff_reports--> After costs share API');
--  fnd_file.put_line(fnd_file.log,' ===== psp_xmlgen.update_er_details');

     psp_xmlgen.update_er_details(l_start_person ,
                                             l_end_person  ,
                                             l_request_id,
                                             l_retry_request_id,
                                             l_return_status) ;

         hr_utility.trace('psp_create_eff_reports--> After xmlgen.update_er_details');
       If (l_return_status =  fnd_api.g_ret_sts_error) or (l_return_status = fnd_api.g_ret_sts_unexp_error)  then
            psp_message_s.print_error(p_mode=>FND_FILE.log,
                                      p_print_header=>FND_API.G_TRUE);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END IF;
--  fnd_file.put_line(fnd_file.log,' ===== psp_eff_report_details_api.update_eff_report_details');


     psp_xmlgen.update_grouping_category(l_start_person, l_end_person, l_request_id, l_return_status) ;

         hr_utility.trace('psp_create_eff_reports--> After xmlgen.update_grouping_category');
       If (l_return_status =  fnd_api.g_ret_sts_error) or (l_return_status = fnd_api.g_ret_sts_unexp_error)  then
            psp_message_s.print_error(p_mode=>FND_FILE.log,
                                      p_print_header=>FND_API.G_TRUE);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

--  fnd_file.put_line(fnd_file.log,' ===== psp_eff_report_details_api.update_eff_report_details');

    psp_eff_report_details_api.update_eff_report_details(p_validate , l_request_id,l_start_person, l_end_person, p_warning );

-- Check weather Project, Task, Award, Exp Org are valid or not

	VALIDATE_PTAOE(p_start_person		=>	l_start_person,
		                 p_end_person		=> l_end_person,
            			 p_request_id		=> l_request_id,
            			 p_retry_request_id	=> l_retry_request_id,
            			 p_return_status 	=> l_return_status) ;

--  fnd_file.put_line(fnd_file.log,' ===== after ptaoe validate');

       If (l_return_status =  fnd_api.g_ret_sts_unexp_error) or (l_return_status =  fnd_api.g_ret_sts_error)  then
--  fnd_file.put_line(fnd_file.log,' ===== after ptaoe validate in side error');

	    psp_message_s.print_error(p_mode=>FND_FILE.log,
                                      p_print_header=>FND_API.G_TRUE);
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

--  fnd_file.put_line(fnd_file.log,' ===== psp_er_ame.get_first_approvers');

             psp_er_ame.get_first_approvers(l_request_id  ,
                              l_start_person,
                              l_end_person ,
                              l_return_status,
                              l_retry_request_id );


          hr_utility.trace('psp_create_eff_reports--> After psp_er_ame.get_first_approvers');



       If (l_return_status =  fnd_api.g_ret_sts_unexp_error) or (l_return_status=fnd_api.g_ret_sts_error)  then
            psp_message_s.print_error(p_mode=>FND_FILE.log,
                                      p_print_header=>FND_API.G_TRUE);

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END IF;

--  fnd_file.put_line(fnd_file.log,' =====  psp_xmlgen.update_er_person_xml');

        psp_xmlgen.update_er_person_xml(l_start_person ,
                                               l_end_person  ,
                                               l_request_id,
                                               l_retry_request_id,
                                               l_return_status) ;

         hr_utility.trace('psp_create_eff_reports--> After xmlgen.update_er_person_xml');

       If (l_return_status =  fnd_api.g_ret_sts_error ) or (l_return_status = fnd_api.g_ret_sts_unexp_error) then
            psp_message_s.print_error(p_mode=>FND_FILE.log,
                                      p_print_header=>FND_API.G_TRUE);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       END IF;

    END IF;
      --   hr_utility.trace_off;

  EXCEPTION
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
       BEGIN
          --  hr_utility.trace('psp_create_eff_reports--> Exception '||sqlerrm);
          fnd_file.put_line(fnd_file.log,' Unhandled exception raised '||sqlerrm);
	  fnd_message.set_name('PSP','PSP_ER_CREATE_UNEXPECTED_ERROR');
	  l_err_mesg := substr(fnd_message.get,1,2000);
          l_sqlerrm := l_err_mesg || substr(sqlerrm,1,200);
          psp_general.add_report_error(l_request_id, 'E',null, l_retry_request_id, null, l_sqlerrm,l_return_status);

/*  Below lines  added for supercedence requirement
*/
      --   hr_utility.trace_off;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;


END;

PROCEDURE  populate_error_table(p_request_id IN NUMBER, p_start_person IN NUMBER, p_end_person IN NUMBER, p_min_effort_report_id IN NUMBER, p_retry_request_id IN NUMBER, p_mode in varchar2, p_match_level in varchar2)  IS

l_msg_str  varchar2(240);
--l_old_request_id  number(15);

--l_retry_request_id number(15);
  l_sqlerrm  varchar2(240);


  l_return_status varchar2(1);

  cursor get_skipped_asg is
  select distinct pspt.skip_reason, pspt.person_id, paf.assignment_number
    from psp_selected_persons_t pspt,
         per_all_assignments_f paf
   where pspt.request_id = p_request_id
     and pspt.person_id between p_start_person and p_end_person
     and pspt.assignment_id = paf.assignment_id
     and pspt.skip_reason is not null
     and paf.effective_start_date = (select max(paf2.effective_start_date)
                                       from per_all_assignments_f paf2
                                      where paf2.assignment_id = paf.assignment_id);

  skipped_asg_rec get_skipped_asg%rowtype;

  BEGIN

/*

  Find out if any persons  in person_array do not have new effort reports created.



1. If previous effort report exists for the person, then appropriate error message.

2. if a person in range_cursor is missing entry in psp_eff_rep_details and prev_eff_report does not exist then
   say no active distributions for this person.

3. pending distribution Adjustment for employee -- how to determine


4.  Errors returned by cost share api.

*/



/*

      Select max(request_id) into l_old_request_id from psp_report_templates_h prth where request_id < p_request_id and payroll_action_id  = p_pact_id;



   --  select request_id into l_retry_request_id  from pay_payroll_actions where payroll_action_id = p_pact_id;

     if g_psp_request_id =p_request_id then
        l_retry_request_id :=NULL;
     else
       l_retry_request_id:=g_psp_request_id;
     end if;


*/

--  fnd_file.put_line(fnd_file.log,'orig is '||p_request_id||'--RETRY '||l_retry_request_id);
if p_mode = 'PRE-POPULATE' then

     /*   A pending or Approved Effort Report already exists   */

if p_match_level = 'EMP' then
     fnd_message.set_name('PSP', 'PSP_EFF_ALREADY_EXISTS');
      l_msg_str:= substr(fnd_message.get ,1,240);

   update psp_selected_persons_t
      set skip_reason = 'ALREADY_EXISTS'
    where person_id between p_start_person and p_end_person
      and request_id = p_request_id
      and person_id in
     (select person_id from psp_eff_reports
       where status_code in ('N', 'A')
         and g_psp_effort_end  >= start_date
         and g_psp_effort_start <= end_date );


   insert into psp_report_errors
	(error_sequence_id,	request_id,	message_level,
	source_id,		error_message,	retry_request_id,	pdf_request_id,
	source_name,		parent_source_id,	parent_source_name)
(select psp_report_errors_s.nextval , p_request_id,
   'W', pspt.person_id  , l_msg_str , p_retry_request_id, null, NULL, NULL, null
   from psp_selected_persons_t pspt  where pspt.person_id between p_start_person and p_end_person and
  pspt.request_id = p_request_id and skip_reason is not null
  AND rowid = (select min(rowid) from psp_selected_persons_t inner
               where inner.request_id = pspt.request_id
               AND   inner.person_id = pspt.person_id ));

else

   update psp_selected_persons_t
      set skip_reason = 'ALREADY_EXISTS'
    where person_id between p_start_person and p_end_person
      and request_id = p_request_id
      and (person_id, assignment_id) in
     (select er.person_id, erd.assignment_id
        from psp_eff_reports er, psp_eff_report_details erd
       where er.status_code in ('N', 'A')
         and er.effort_Report_id = erd.effort_report_id
         and g_psp_effort_end  >= er.start_date
         and g_psp_effort_start <= er.end_date );

    --- existing ER without asg_id summarization.
   update psp_selected_persons_t
      set skip_reason = 'ALREADY_EXISTS'
    where person_id between p_start_person and p_end_person
      and request_id = p_request_id
      and person_id in
     (select er.person_id
        from psp_eff_reports er, psp_eff_report_details erd
       where er.status_code in ('N', 'A')
         and er.effort_Report_id = erd.effort_report_id
         and g_psp_effort_end  >= er.start_date
         and g_psp_effort_start <= er.end_date
         and erd.assignment_id is null);

    update psp_selected_persons_t
       set skip_reason = 'OTHER_ASG_SKIPPED'
    where person_id between p_start_person and p_end_person
      and request_id = p_request_id
      and skip_reason is null
      and person_id in
       (select person_id
          from psp_selected_persons_t
         where person_id between p_start_person and p_end_person
           and request_id = p_request_id
           and skip_reason = 'ALREADY_EXISTS' );

   open get_skipped_asg;
   loop

      fetch get_skipped_asg into skipped_asg_rec;
      if get_skipped_asg%notfound then
         close get_skipped_asg;
         exit;
      end if;

     if skipped_asg_rec.skip_reason = 'ALREADY_EXISTS' then
        fnd_message.set_name('PSP', 'PSP_ASG_EFF_ALREADY_EXISTS');
        fnd_message.set_token('ASG_NUMBER',skipped_asg_rec.assignment_number);
        l_msg_str:= substr(fnd_message.get ,1,240);
     else
        fnd_message.set_name('PSP', 'PSP_ASG_EFF_ALREADY_EXISTS2');
        fnd_message.set_token('ASG_NUMBER',skipped_asg_rec.assignment_number);
        l_msg_str:= substr(fnd_message.get ,1,240);
     end if;

      insert into psp_report_errors
	(error_sequence_id,	request_id,	message_level,
	source_id,		error_message,	retry_request_id,	pdf_request_id,
	source_name,		parent_source_id,	parent_source_name)
      (select psp_report_errors_s.nextval , p_request_id,
             'W', skipped_asg_rec.person_id  , l_msg_str , p_retry_request_id, null, NULL, NULL, null
      from dual);

   end loop;

end if;

else
    /*  No distributions Found  */



     fnd_message.set_name('PSP', 'PSP_EFF_NO_DISTRIB');
      l_msg_str:= substr(fnd_message.get ,1,240);

    insert into psp_report_errors
	(error_sequence_id,	request_id,	message_level,
	source_id,		error_message,	retry_request_id,	pdf_request_id,
	source_name,		parent_source_id,	parent_source_name)
    select psp_report_errors_s.nextval, p_request_id,'W',
     pspt.person_id, l_msg_str, p_retry_request_id , null, NULL, NULL, NULL
     from psp_selected_persons_t pspt where pspt.person_id between p_start_person
      and p_end_person  and
     pspt.request_id = p_request_id and
      pspt.person_id not in (select nvl(person_id,0) from psp_eff_reports where g_psp_effort_end >= start_date and
      g_psp_effort_start <= end_date and status_code  in ('N', 'A'))
       and pspt.person_id not in (select nvl(source_id,0) from psp_report_errors where request_id = g_psp_request_id);


     fnd_message.set_name('PSP', 'PSP_EFF_PENDING_DIST_ADJ');
      l_msg_str:= substr(fnd_message.get ,1,200);
    insert into psp_report_errors
	(error_sequence_id,	request_id,	message_level,
	source_id,		error_message,	retry_request_id,	pdf_request_id,
	source_name,		parent_source_id,	parent_source_name)
    select psp_report_errors_s.nextval, p_request_id,'W',
       pspt.person_id , l_msg_str, p_retry_request_id , null, NULL, NULL, NULL
    from psp_selected_persons_t pspt where pspt.person_id between p_start_person and p_end_person and
 pspt.request_id = p_request_id and
     exists (select nvl(person_id,0) from psp_adjustment_lines where effective_date between g_psp_effort_start
      and g_psp_effort_end ) and pspt.person_id not in (select source_id from psp_report_errors where request_id=p_request_id) and
      pspt.person_id not in (select nvl(person_id, 0) from psp_eff_reports where g_psp_effort_end>=start_date and
       g_psp_effort_start <= end_date);
end if;

   EXCEPTION

 WHEN NO_DATA_FOUND THEN NULL;

 WHEN OTHERS THEN

       l_sqlerrm := 'Error inserting in psp_report_errors '|| substr(sqlerrm,1,200);

       psp_general.add_report_error(p_request_id, 'E',null, p_retry_request_id, null, l_sqlerrm,l_return_status);



END;

PROCEDURE VALIDATE_PTAOE	(p_start_person		IN		NUMBER,
				p_end_person		IN		NUMBER,
               			p_request_id		IN		NUMBER,
               			p_retry_request_id	IN		NUMBER,
            			p_return_status		OUT	NOCOPY	VARCHAR2) IS
    l_profile_bg_id number;
    l_person_id Number ;
    l_project_id Number ;
    l_task_id Number ;
    l_award_id Number ;
    l_exp_org_id Number ;
    l_project_name VARCHAR2(30);
    l_task_name VARCHAR2(30);
    l_award_name VARCHAR2(30);
    l_exp_org_name VARCHAR2(240);
    l_expenditure_type VARCHAR2(30);
    l_return_status	CHAR(1);
    l_err_mesg varchar2(2000);
    l_error_type Number;

    Cursor check_ptaoe is
    select 1, per.person_id, perd.project_id, NVL(perd.project_name,'NOTFOUND'), perd.task_id, NVL(perd.task_name,'NOTFOUND'),
    perd.award_id, NVL(perd.AWARD_SHORT_NAME,'NOTFOUND'), EXPENDITURE_ORGANIZATION_ID ,NVL(perd.exp_org_name,'NOTFOUND'),
    perd.expenditure_type
    from psp_eff_reports per ,
    psp_eff_report_details perd
    where per.EFFORT_REPORT_ID = perd.EFFORT_REPORT_ID
    AND per.request_id = p_request_id
    AND person_id between p_start_person and p_end_person
    AND(( PROJECT_ID is not null AND PROJECT_NAME is NULL)
        OR ( TASK_ID is not null AND TASK_NAME is NULL)
        OR ( AWARD_ID is not null AND AWARD_SHORT_NAME is NULL)
        OR ( EXPENDITURE_ORGANIZATION_ID is not null AND EXP_ORG_NAME is NULL))
    UNION ALL
    select 2,  per.person_id, perd.project_id, perd.project_name, perd.task_id, perd.task_name,
    perd.award_id, perd.AWARD_SHORT_NAME, EXPENDITURE_ORGANIZATION_ID ,perd.exp_org_name,
    perd.expenditure_type
    from psp_eff_reports per ,
    psp_eff_report_details perd
    where per.EFFORT_REPORT_ID = perd.EFFORT_REPORT_ID
    and per.request_id = p_request_id
    AND person_id between p_start_person and p_end_person
    AND PROJECT_ID is NULL
    AND TASK_ID is NULL
    AND AWARD_ID is NULL
    AND EXPENDITURE_ORGANIZATION_ID is NULL
    AND EXPENDITURE_TYPE is NULL
    AND gl_sum_criteria_segment_name IS NULL;

CURSOR	layout_type_cur IS
SELECT	SUBSTR(report_template_code, 6, 3) layout_type
FROM	psp_report_templates_h prth
WHERE	prth.request_id = p_request_id;

l_layout_type		CHAR(3);
l_award_number		VARCHAR2(240);
l_project_number	VARCHAR2(25);
l_task_number		VARCHAR2(25);
l_check_project_number	NUMBER;

CURSOR	check_award_pi_cur IS
SELECT	DISTINCT per.person_id,
	perd.award_id,
	perd.award_number
FROM	psp_eff_reports per,
	psp_eff_report_details perd
WHERE	per.request_id = p_request_id
AND	per.effort_report_id = perd.effort_report_id
AND	per.person_id BETWEEN p_start_person AND p_end_person
--AND	perd.award_id IS NOT NULL			Commented as part of UVA fix 4537063
AND	(perd.investigator_person_id IS NULL OR perd.investigator_name IS NULL);

CURSOR	check_pm_cur IS
SELECT	DISTINCT per.person_id,
	perd.project_id,
	perd.project_number
FROM	psp_eff_reports per,
	psp_eff_report_details perd
WHERE	per.request_id = p_request_id
AND	per.effort_report_id = perd.effort_report_id
AND	per.person_id BETWEEN p_start_person AND p_end_person
AND	perd.project_id IS NOT NULL
AND	(perd.investigator_person_id IS NULL OR perd.investigator_name IS NULL);

CURSOR	check_tm_cur IS
SELECT	DISTINCT per.person_id,
	perd.project_number,
	perd.task_id,
	perd.task_number
FROM	psp_eff_reports per,
	psp_eff_report_details perd
WHERE	per.request_id = p_request_id
AND	per.effort_report_id = perd.effort_report_id
AND	per.person_id BETWEEN p_start_person AND p_end_person
AND	perd.task_id IS NOT NULL
AND	(perd.investigator_person_id IS NULL OR perd.investigator_name IS NULL);

CURSOR	check_tm_cur1 IS
SELECT	DISTINCT per.person_id,
	ppa.segment1,
	perd.task_id,
	perd.task_number
FROM	psp_eff_reports per,
	psp_eff_report_details perd,
	pa_tasks pt,
	pa_projects_all ppa
WHERE	per.request_id = p_request_id
AND	per.effort_report_id = perd.effort_report_id
AND	pt.task_id = perd.task_id
AND	ppa.project_id = pt.project_id
AND	per.person_id BETWEEN p_start_person AND p_end_person
AND	perd.task_id IS NOT NULL
AND	(perd.investigator_person_id IS NULL OR perd.investigator_name IS NULL);

CURSOR	check_project_number_cur IS
SELECT	COUNT(1)
FROM	psp_eff_reports per,
	psp_eff_report_details perd
WHERE	per.request_id = p_request_id
AND	per.person_id BETWEEN p_start_person AND p_end_person
AND	perd.task_id IS NOT NULL
AND	perd.project_id IS NULL
AND	ROWNUM = 1;
BEGIN

	l_profile_bg_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
	p_return_status  := fnd_api.g_ret_sts_success;

	OPEN layout_type_cur;
	FETCH layout_type_cur INTO l_layout_type;
	CLOSE layout_type_cur;

	OPEN check_ptaoe;
	LOOP
		FETCH check_ptaoe into l_error_type, l_person_id,l_project_id, l_project_name,l_task_id, l_task_name,
			   l_award_id, l_award_name, l_exp_org_id, l_exp_org_name, l_expenditure_type ;
		EXIT WHEN check_ptaoe%NOTFOUND;
		l_err_mesg := NULL;

		IF l_error_type = 1 THEN

			IF l_project_name = 'NOTFOUND' THEN
				fnd_message.set_name('PSP','PSP_ER_INVALID_PROJECT');
				fnd_message.set_token('PROJECT_ID',l_project_id);
				l_err_mesg := l_err_mesg || fnd_message.get;
			END IF;

			IF l_task_name = 'NOTFOUND' THEN
				fnd_message.set_name('PSP','PSP_ER_INVALID_TASK');
				fnd_message.set_token('TASK_ID',l_task_id);
				l_err_mesg := l_err_mesg || fnd_message.get;
			END IF;

			IF l_award_name = 'NOTFOUND' THEN
				fnd_message.set_name('PSP','PSP_ER_INVALID_AWARD');
				fnd_message.set_token('AWARD_ID',l_award_id);
				l_err_mesg := l_err_mesg || fnd_message.get;
			END IF;

			IF l_exp_org_name = 'NOTFOUND' THEN
				fnd_message.set_name('PSP','PSP_ER_INVALID_EXP_ORG');
				fnd_message.set_token('EXP_ORG_ID',l_exp_org_id);
				l_err_mesg := l_err_mesg || fnd_message.get;
			END IF;

		ELSE

			fnd_message.set_name('PSP','PSP_ER_CI_NOT_FOUND');
			l_err_mesg := l_err_mesg || fnd_message.get;
		END IF;

		IF l_err_mesg IS NOT NULL THEN

			IF l_error_type = 1 THEN
				fnd_message.set_name('PSP','PSP_ER_CAN_NOT_DISPLAY_DATA');
				l_err_mesg := l_err_mesg || fnd_message.get;
			END IF;
			l_err_mesg := substr(l_err_mesg,1,2000);
			psp_general.add_report_error(   p_request_id		=>	p_request_id ,
							p_message_level		=>	'E',
							p_source_id		=>	l_person_id,
							p_retry_request_id	=>	p_retry_request_id,
							p_pdf_request_id	=>	NULL,
							p_error_message		=>	l_err_mesg,
							p_return_status		=>	l_return_status);
			p_return_status  := fnd_api.g_ret_sts_error;
		END IF;

	END LOOP;
	CLOSE check_ptaoe;

	IF (l_layout_type = 'PIV') THEN
		OPEN check_award_pi_cur;
		LOOP
			FETCH check_award_pi_cur INTO l_person_id, l_award_id, l_award_number;
			EXIT WHEN check_award_pi_cur%NOTFOUND;

			fnd_message.set_name('PSP', 'PSP_ER_INVALID_PI');
			fnd_message.set_token('AWARD_NUMBER', l_award_number);
			l_err_mesg := fnd_message.get;

			psp_general.add_report_error(   p_request_id	=>	p_request_id ,
							p_message_level	=>	'E',
							p_source_id	=>	l_person_id,
							p_retry_request_id	=>	p_retry_request_id,
							p_pdf_request_id	=>	NULL,
							p_error_message	=>	l_err_mesg,
							p_return_status	=>	l_return_status);
			p_return_status  := fnd_api.g_ret_sts_error;
		END LOOP;
		CLOSE check_award_pi_cur;

	ELSIF (l_layout_type = 'PMG') THEN
		OPEN check_pm_cur;
		LOOP
			FETCH check_pm_cur INTO l_person_id, l_project_id, l_project_number;
			EXIT WHEN check_pm_cur%NOTFOUND;

			fnd_message.set_name('PSP', 'PSP_ER_INVALID_PM');
			fnd_message.set_token('PROJECT_NUMBER', l_project_number);
			l_err_mesg := fnd_message.get;

			psp_general.add_report_error(   p_request_id	=>	p_request_id ,
							p_message_level	=>	'E',
							p_source_id	=>	l_person_id,
							p_retry_request_id	=>	p_retry_request_id,
							p_pdf_request_id	=>	NULL,
							p_error_message	=>	l_err_mesg,
							p_return_status	=>	l_return_status);
			p_return_status  := fnd_api.g_ret_sts_error;
		END LOOP;
		CLOSE check_pm_cur;

	ELSIF (l_layout_type = 'TMG') THEN
		OPEN check_project_number_cur;
		FETCH check_project_number_cur INTO l_check_project_number;
		CLOSE check_project_number_cur;

		IF (l_check_project_number = 0) THEN
			OPEN check_tm_cur;
			LOOP
				FETCH check_tm_cur INTO l_person_id, l_project_number, l_task_id, l_task_number;
				EXIT WHEN check_tm_cur%NOTFOUND;

				fnd_message.set_name('PSP', 'PSP_ER_INVALID_TM');
				fnd_message.set_token('PROJECT_NUMBER', l_project_number);
				fnd_message.set_token('TASK_NUMBER', l_task_number);
				l_err_mesg := fnd_message.get;

				psp_general.add_report_error(   p_request_id	=>	p_request_id ,
								p_message_level	=>	'E',
								p_source_id	=>	l_person_id,
								p_retry_request_id	=>	p_retry_request_id,
								p_pdf_request_id	=>	NULL,
								p_error_message	=>	l_err_mesg,
								p_return_status	=>	l_return_status);
				p_return_status  := fnd_api.g_ret_sts_error;
			END LOOP;
			CLOSE check_tm_cur;
		ELSE
			OPEN check_tm_cur1;
			LOOP
				FETCH check_tm_cur1 INTO l_person_id, l_project_number, l_task_id, l_task_number;
				EXIT WHEN check_tm_cur1%NOTFOUND;

				fnd_message.set_name('PSP', 'PSP_ER_INVALID_TM');
				fnd_message.set_token('PROJECT_NUMBER', l_project_number);
				fnd_message.set_token('TASK_NUMBER', l_task_number);
				l_err_mesg := fnd_message.get;

				psp_general.add_report_error(   p_request_id	=>	p_request_id ,
								p_message_level	=>	'E',
								p_source_id	=>	l_person_id,
								p_retry_request_id	=>	p_retry_request_id,
								p_pdf_request_id	=>	NULL,
								p_error_message	=>	l_err_mesg,
								p_return_status	=>	l_return_status);
				p_return_status  := fnd_api.g_ret_sts_error;
			END LOOP;
			CLOSE check_tm_cur1;
		END IF;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END VALIDATE_PTAOE;

END;

/
