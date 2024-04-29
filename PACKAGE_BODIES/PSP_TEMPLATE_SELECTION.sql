--------------------------------------------------------
--  DDL for Package Body PSP_TEMPLATE_SELECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_TEMPLATE_SELECTION" AS
/* $Header: PSPTPLSLB.pls 120.19.12010000.3 2009/03/11 08:58:10 sabvenug ship $*/



PROCEDURE insert_into_template_history(p_payroll_action_id  IN NUMBER, p_request_id OUT NOCOPY NUMBER ) IS
PRAGMA	AUTONOMOUS_TRANSACTION;

param_string PAY_PAYROLL_ACTIONS.LEGISLATIVE_PARAMETERS%TYPE;

l_psp_template_id  number;
l_psp_effort_start  date;
l_psp_effort_end date;
l_psp_sort_option1    varchar(150);
l_psp_sort_option2    varchar2(150);
l_psp_sort_option3    varchar2(150);
l_psp_sort_option4    varchar2(150);
l_psp_order_by1       varchar2(150);
l_psp_order_by2       varchar2(150);
l_psp_order_by3       varchar2(150);
l_psp_order_by4       varchar2(150);
l_psp_report_layout   varchar2(150);

l_sqlerrm varchar2(240);
l_return_status varchar2(1);

BEGIN


  SELECT request_id, legislative_parameters  into p_request_id, param_string  from pay_payroll_actions where payroll_action_id = p_payroll_action_id;

    l_psp_template_id := get_parameter_value('TEMPLATE_ID', param_string);


    --fnd_file.put_line(fnd_file.log,'TEMPLATE_ID ===='||l_psp_template_id);
   --fnd_file.put_line(fnd_file.log,'Return String '||get_parameter_value('START_DATE', param_string));


    l_psp_effort_start:= trunc(fnd_date.canonical_to_date(get_parameter_value('START_DATE', param_string)));
    --fnd_file.put_line(fnd_file.log,'start_date ===='||l_psp_effort_start);

    l_psp_effort_end:= trunc(fnd_date.canonical_to_date(get_parameter_value('END_DATE', param_string)));
    --fnd_file.put_line(fnd_file.log,'end date ===='||l_psp_effort_end);

    l_psp_report_layout := get_parameter_value('REPORT_LAYOUT', param_string);
    l_psp_sort_option1 :=  get_parameter_value('FIRST_SORT', param_string);
    l_psp_order_by1    := get_parameter_value('FIRST_ORDER' , param_string);
    l_psp_sort_option2 := get_parameter_value('SECOND_SORT', param_string);
    l_psp_order_by2    := get_parameter_value('SECOND_ORDER' , param_string);
    l_psp_sort_option3 := get_parameter_value('THIRD_SORT', param_string);
    l_psp_order_by3    := get_parameter_value('THIRD_ORDER' , param_string);
    l_psp_sort_option4 := get_parameter_value('FOURTH_SORT', param_string);
    l_psp_order_by4    := get_parameter_value('FOURTH_ORDER' , param_string);


   -- fnd_file.put_line(fnd_file.log,'sort option 1 ===='||l_psp_sort_option1);
    -- fnd_file.put_line(fnd_file.log,'ORDER BY  ===='||l_psp_order_by1);
   -- fnd_file.put_line(fnd_file.log,' sort option 2  ===='||l_psp_sort_option2);
   -- fnd_file.put_line(fnd_file.log,'order_by_2 ===='||l_psp_order_by2);
    -- fnd_file.put_line(fnd_file.log,'layout ===='||l_psp_report_layout);


   /*   insert record in psp_report_templates_h   */

    insert into psp_report_templates_h(request_id, template_id, template_name,
   business_group_id, set_of_books_id, report_type, period_frequency_id,
   report_template_code, display_all_emp_distrib_flag,
   manual_entry_override_flag,  approval_type, custom_approval_code,
  sup_levels, preview_effort_report_flag, notification_reminder_in_days, parameter_name_1, parameter_name_2, parameter_name_3, parameter_name_4, parameter_name_5,
  parameter_name_6, parameter_name_7, parameter_name_8, parameter_name_9, parameter_name_10,
  parameter_name_11, parameter_name_12, parameter_name_13, parameter_name_14, parameter_name_15,
  parameter_name_16, parameter_name_17, parameter_name_18, parameter_name_19,
  parameter_name_20,parameter_value_1, parameter_value_2, parameter_value_3, parameter_value_4,
  parameter_value_5, parameter_value_6, parameter_value_7, parameter_value_8,
  parameter_value_9, parameter_value_10, parameter_value_11,
  parameter_value_12, parameter_value_13, parameter_value_14, parameter_value_15,
  parameter_value_16, parameter_value_17, parameter_value_18, parameter_value_19, parameter_value_20, submission_date,
  initiator_person_id, initiator_file_id, initiator_accept_flag,
  final_recipients_file_id, sprcd_tolerance_amt, sprcd_tolerance_percent, description, legislation_code,
  payroll_action_id,  last_update_date, last_updated_by, last_update_login,
  created_by, creation_date,hundred_pcent_eff_at_per_asg,selection_match_level) (  select p_request_id, template_id, template_name,
  business_group_id, set_of_books_id , report_type, period_frequency_id,
 report_template_code, display_all_emp_distrib_flag,
  manual_entry_override_flag, approval_type,
  custom_approval_code, sup_levels, preview_effort_report_flag, notification_reminder_in_days,
  'TEMPLATE_ID', 'EFFORT_START', 'EFFORT_END',
  'REPORT_LAYOUT', 'SORT_OPTION1','ORDER_BY1', 'SORT_OPTION2', 'ORDER_BY' , 'SORT_OPTION3', 'ORDER_BY3', 'SORT_OPTION4',
  'ORDER_BY4', NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, l_psp_template_id, l_psp_effort_start, l_psp_effort_end,  l_psp_report_layout, l_psp_sort_option1, l_psp_order_by1,
   l_psp_sort_option2, l_psp_order_by2, l_psp_sort_option3, l_psp_order_by3, l_psp_sort_option4, l_psp_order_by4, NULL, NULL, NULL
,  NULL, NULL, NULL, NULL, NULL, sysdate, fnd_global.employee_id, NULL,
   NULL, NULL, sprcd_tolerance_amt, sprcd_tolerance_percent, description, legislation_code,
  p_payroll_action_id,  last_update_date, last_updated_by, last_update_login, created_by, creation_date, hundred_pcent_eff_at_per_asg,selection_match_level from psp_report_templates where template_id = l_psp_template_id);


   insert into psp_report_template_details_h (request_id, template_detail_id, criteria_lookup_type,
   criteria_lookup_code, include_exclude_flag, criteria_value1, criteria_value2, criteria_value3,
   last_update_date, last_updated_by, last_update_login, created_by, creation_date) (select
   p_request_id, template_detail_id,
   criteria_lookup_type, criteria_lookup_code, include_exclude_flag,
   criteria_value1, criteria_value2, criteria_value3 , last_update_date,
   last_updated_by, last_update_login, created_by, creation_date from
   psp_report_template_details where template_id = l_psp_template_id);

	COMMIT;

    EXCEPTION WHEN OTHERS THEN

       l_sqlerrm := 'Error inserting into psp_report_templates_history '|| substr(sqlerrm,1,180);

/* Removed payroll_action_id to make it independent of payroll_action_id */
--      psp_general.add_report_error(p_request_id, 'E',null, l_sqlerrm, p_payroll_action_id, l_return_status);
             psp_general.add_report_error
				(p_request_id		=>	p_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_error_message		=>	l_sqlerrm,
--				p_payroll_action_id	=>	pactid,
				p_return_status		=>	l_return_status);

     fnd_file.put_line(fnd_file.log, 'Insert into Template History failed '||sqlerrm);
     raise fnd_api.g_exc_unexpected_error;

END;



PROCEDURE range_code(pactid IN NUMBER, sqlstr out nocopy varchar2)  IS

errBuf varchar2(240);

retCode varchar(1);

l_request_id  number;

l_cnt number:=0;

l_msg_str varchar2(240);
 l_migration_status BOOLEAN;

    l_proj_segment varchar2(30);
    l_tsk_segment varchar2(30);
    l_awd_sgement varchar2(30);
    l_exp_org_segment varchar2(30);
    l_exp_type_segment varchar2(30);
    l_profile_bg_id Number;
    l_return_status  varchar2(30);


BEGIN

    --fnd_file.put_line(fnd_file.log,'Before  Insert in template history ');
   --hr_utility.trace_on('Y','ORACLE');


      insert_into_template_history(pactid, l_request_id );
      l_profile_bg_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
      IF PSP_GENERAL.GET_CONFIGURATION_OPTION_VALUE(l_profile_bg_id,'PSP_USE_GL_PTAOE_MAPPING') = 'Y' THEN

        PSP_GENERAL.GET_GL_PTAOE_MAPPING(p_business_group_id => l_profile_bg_id,
                      p_proj_segment => l_proj_segment,
                      p_tsk_segment => l_tsk_segment,
                      p_awd_sgement => l_awd_sgement,
                      p_exp_org_segment=> l_exp_org_segment,
                      p_exp_type_segment => l_exp_type_segment);
        IF (l_proj_segment is null) OR   (l_tsk_segment is null) OR (l_awd_sgement is null) OR
            (l_exp_org_segment is null) OR (l_exp_type_segment is null) THEN

             fnd_message.set_name('PSP', 'PSP_GL_PTAOE_NOT_MAPPED');
             l_msg_str:=substr(fnd_message.get, 1,240);
/* Removed payroll_action_id to make it independent of payroll_action_id */
	     psp_general.add_report_error
				(p_request_id		=>	l_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_error_message		=>	l_msg_str,
--				p_payroll_action_id	=>	pactid,
				p_return_status		=>	l_return_status);
	      raise fnd_api.g_exc_unexpected_error;
	END IF;
      END IF;


      l_migration_status:= psp_general.is_effort_report_migrated;

    IF l_migration_status then

     --fnd_file.put_line(fnd_file.log,'==== After Insert in template history ');

     get_final_selection_list(errBuf, retCode, l_request_id, TRUE);

     --fnd_file.put_line(fnd_file.log,'==== After getting sleection list  ');

   SELECT nvl(count( person_id),0) into l_cnt from psp_selected_persons_t where
    request_id = l_request_id;

       --fnd_file.put_line(fnd_file.log,'==== count is '|| l_cnt);

     IF l_cnt=0 then

     fnd_message.set_name('PSP', 'PSP_EFF_NO_EMP_FOUND');
      l_msg_str:= substr(fnd_message.get ,1,240);

/* Removed payroll_action_id to make it independent of payroll_action_id */
	INSERT INTO  psp_report_errors
		(error_sequence_id,		request_id,		message_level,
		source_id,			error_message,		retry_request_id,
		pdf_request_id,			source_name,		parent_source_id,
		parent_source_name)
	VALUES	(psp_report_errors_s.NEXTVAL,	l_request_id,		'W',
		NULL,				l_msg_str,		NULL,
		NULL,				NULL,			NULL,
		NULL);


   ELSE

--  delete duplicates
   delete from psp_Selected_persons_t outer where request_id = l_request_id and
	(person_id,  nvl( assignment_id, -999) ) in (select
person_id,  nvl( assignment_id, -999) from psp_Selected_persons_t inner where inner.person_id=outer.person_id and inner.request_id =outer.request_id and inner.rowid > outer.rowid);

   END IF;


    -- fnd_file.put_line(fnd_file.log,'==== cnt sleection '||l_cnt);

     sqlstr := 'select distinct person_id from psp_selected_persons_t pspt,
      pay_payroll_actions pact
      where pact.payroll_action_id = :payroll_action_id and
       pspt.request_id= pact.request_id ORDER BY pspt.person_id';


  ELSE

     fnd_message.set_name('PSP', 'PSP_COMP_EFF_MIG');

     l_msg_str:=substr(fnd_message.get, 1,240);
/* Removed payroll_action_id to make it independent of payroll_action_id */
	INSERT INTO  psp_report_errors
		(error_sequence_id,		request_id,		message_level,
		source_id,			error_message,		retry_request_id,
		pdf_request_id,			source_name,		parent_source_id,
		parent_source_name)
	VALUES	(psp_report_errors_s.NEXTVAL,	l_request_id,		'E',
		NULL,				l_msg_str,		NULL,
		NULL,				NULL,			NULL,
		NULL);


     fnd_message.set_name('PSP', 'PSP_COMP_EFF_MIG');
      fnd_msg_pub.add;

      raise fnd_api.g_exc_unexpected_error;

  END IF;


 --  hr_utility.trace_off;

 EXCEPTION WHEN OTHERS THEN

     psp_message_s.print_error(p_mode=>FND_FILE.log,

                                      p_print_header=>FND_API.G_TRUE);

     sqlstr:= NULL;
     commit;
     raise fnd_api.g_exc_unexpected_error;
  END;



PROCEDURE GET_FINAL_SELECTION_LIST(errBuf  OUT NOCOPY VARCHAR2,
    retCode 	    	OUT NOCOPY VARCHAR2,
    p_request_id  	IN	NUMBER,
    p_person_asg_flag  	IN  	BOOLEAN
		 )
  AS

PRAGMA	AUTONOMOUS_TRANSACTION;

 /* logic needs to be added for case when

  user has not selected any selection criteria


*/

   CURSOR get_template_selection
   IS
   SELECT  template_id, parameter_value_2, parameter_value_3, business_group_id, set_of_books_id, selection_match_level
    from psp_report_templates_h
    where request_id = p_request_id;

    l_template_id    NUMBER;
    l_count  NUMBER;
      i    NUMBER;
    l_effort_start DATE;
    l_effort_end DATE;
    l_business_group_id  NUMBER;
    l_set_of_books_id NUMBER;
	l_template_selection	varchar2(3);
 ---l_count_x integer;
 BEGIN


     OPEN get_template_selection;

     FETCH get_template_selection into l_template_id, l_effort_start, l_effort_end, l_business_group_id, l_set_of_books_id, l_template_selection;

     CLOSE get_template_selection;


	IF (l_template_selection = 'EMP') THEN
     get_lowest_cardinality(p_request_id , l_effort_start, l_effort_end, l_business_group_id, l_set_of_books_id);
       ---fnd_file.put_line(fnd_file.log,' after get lowest cardinality   ');


      hr_utility.trace( 'get_template_selection-> After get_lowest_cardinality'   );

     prepare_initial_person_list(p_request_id , l_effort_start, l_effort_end, l_business_group_id, l_set_of_books_id);
     ---select count(*) into l_count_x from psp_selected_persons_t where request_id
     ---= p_request_id;
       ---fnd_file.put_line(fnd_file.log,' after initial person list  ');

		FND_STATS.GATHER_TABLE_STATS(ownname=>'PSP', tabname=>'PSP_SELECTED_PERSONS_T');

      hr_utility.trace( 'get_template_selection-> After prepare_initial_person_list ' );
    If g_lookup_code <> 'ALL' then

     prune_initial_person_list(p_request_id , l_effort_start, l_effort_end, l_business_group_id, l_set_of_books_id);
       --fnd_file.put_line(fnd_file.log,' after prune  person list  ');
      hr_utility.trace( 'get_template_selection-> After prune initial_person_list ' );
    END IF;


     apply_exclusion_criteria(p_request_id , l_effort_start, l_effort_end, l_business_group_id, l_set_of_books_id);
       --fnd_file.put_line(fnd_file.log,' after apply excl criteria   ');
      hr_utility.trace( 'get_template_selection-> After apply exclusion criteria ' );

	END IF;

	IF (l_template_selection = 'ASG') THEN
		get_asg_lowest_cardinality	(p_request_id		=>	p_request_id,
						p_effort_start		=>	l_effort_start,
						p_effort_end		=>	l_effort_end,
						p_business_group_id	=>	l_business_group_id,
						p_set_of_books_id	=>	l_set_of_books_id);
		hr_utility.trace('get_template_selection-> After get_asg_lowest_cardinality');

		prepare_initial_asg_list	(p_request_id		=>	p_request_id,
						p_effort_start		=>	l_effort_start,
						p_effort_end		=>	l_effort_end,
						p_business_group_id	=>	l_business_group_id,
						p_set_of_books_id	=>	l_set_of_books_id);
		hr_utility.trace('get_template_selection-> After prepare_initial_asg_list');

		FND_STATS.GATHER_TABLE_STATS(ownname=>'PSP', tabname=>'PSP_SELECTED_PERSONS_T');

		IF g_lookup_code <> 'ALL' THEN
			prune_initial_asg_list	(p_request_id		=>	p_request_id,
						p_effort_start		=>	l_effort_start,
						p_effort_end		=>	l_effort_end,
						p_business_group_id	=>	l_business_group_id,
						p_set_of_books_id	=>	l_set_of_books_id);
			hr_utility.trace('get_template_selection-> After prune initial_asg_list');
		END IF;

		apply_asg_exclusion_criteria	(p_request_id		=>	p_request_id,
						p_effort_start		=>	l_effort_start,
						p_effort_end		=>	l_effort_end,
						p_business_group_id	=>	l_business_group_id,
						p_set_of_books_id	=>	l_set_of_books_id);
		hr_utility.trace('get_template_selection-> After apply asg exclusion criteria');
	END IF;

     apply_ff_formula_exclusion(p_request_id, l_effort_start, l_effort_end);
      -- fnd_file.put_line(fnd_file.log,' after ff exclusion    ');
      hr_utility.trace( 'get_template_selection-> After apply_ff_formula_exclusion  ' );


     --fnd_file.put_line(fnd_file.log,' before count   ');

      select nvl(count(person_id),0) into l_count  from psp_Selected_persons_t where request_id=p_request_id;
     --fnd_file.put_line(fnd_file.log,' after  count   ' || l_count);
      hr_utility.trace( 'get_template_selection-> After getting count=  '||l_count );

	COMMIT;

        If l_count > 0 then


     FND_STATS.GATHER_TABLE_STATS(ownname=>'PSP', tabname=>'PSP_SELECTED_PERSONS_T');
     -- fnd_file.put_line(fnd_file.log,' after gather stats ');

        end if;
    EXCEPTION
     WHEN OTHERS THEN
      BEGIN
     fnd_file.put_line(fnd_file.log,' after gather error  '||sqlerrm);
      hr_utility.trace( 'get_template_selection->'||sqlerrm );

      END;


 END;


 PROCEDURE get_lowest_cardinality(p_request_id IN NUMBER, p_effort_start IN
DATE, p_effort_end IN DATE, p_business_group_id IN NUMBER, p_set_of_books_id IN NUMBER) IS

i number;

l_criteria_value1  varchar2(30);

l_criteria_value2 varchar2(60);  --- Bug 8257434

l_criteria_value3 varchar2(30);

l_dyn_criteria  varchar2(30);

l_atleast_one_criteria varchar2(1);


l_sql_string varchar2(1000);

CURSOR get_lowest_cardinality_csr is select lookup_code  from
   psp_selection_cardinality_gt  where total_count > 0 ORDER BY total_count asc;


CURSOR get_zero_cardinality_csr is select lookup_code from
     psp_selection_cardinality_gt where total_count=0;


CURSOR get_selection_cardinality_csr(p_request_id IN NUMBER)
   IS
   Select  distinct (criteria_lookup_code) from
    psp_report_template_details_h where request_id = p_request_id and
    include_exclude_flag='I' and criteria_lookup_type='PSP_SELECTION_CRITERIA';


/* The below cursors would only be used only when no statis selection criteria have been chosen */

CURSOR PPG_CURSOR IS
      select criteria_value1, criteria_value2 from
      psp_report_template_details_h  where  request_id = p_request_id and
      include_exclude_flag='I' and
      criteria_lookup_type= 'PSP_SELECTION_CRITERIA' and criteria_lookup_code='PPG';


CURSOR GLA_CURSOR IS
      select criteria_value1 , criteria_value2, criteria_value3 from
      psp_report_template_details_h where request_id = p_request_id and
      include_exclude_flag='I' and
      criteria_lookup_type ='PSP_SELECTION_CRITERIA' and criteria_lookup_code ='GLA';


  BEGIN

     OPEN get_selection_cardinality_csr(p_request_id);
     FETCH get_selection_cardinality_csr BULK COLLECT into template_rec.array_sel_criteria;

     CLOSE get_selection_cardinality_csr;


   FOR i in 1.. template_rec.array_sel_criteria.count


     LOOP

       IF template_rec.array_sel_criteria(i) = 'PTY'  THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count)  (
            select  'PTY', count(distinct ppf.person_id)  from per_people_f ppf, per_assignments_f paf where
            person_type_id in (select TO_NUMBER(criteria_value1) from psp_report_template_details_h prtd where
            prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code ='PTY'
                  and include_exclude_flag='I'
            and request_id = p_request_id )
            AND	paf.person_id = ppf.person_id
	    AND	paf.assignment_type = 'E'
	    AND	paf.effective_start_date <= p_effort_end
	    AND	paf.effective_end_date >= p_effort_start
	    and
            ppf.effective_start_date <= p_effort_end and
            ppf.effective_end_date >= p_effort_start)  ;


      ELSIF template_rec.array_sel_criteria(i) ='EMP' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count)  (
            select  'EMP', count(distinct ppf.person_id)  from per_all_people_f ppf, per_assignments_f paf  where
             ppf.person_id in (select TO_NUMBER(criteria_value1) from psp_report_template_details_h prtd where
            prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='EMP' and
                   include_exclude_flag='I'
           and  request_id = p_request_id )
            AND	paf.person_id = ppf.person_id
            AND	paf.assignment_type = 'E'
            AND	paf.effective_start_date <= p_effort_end
            AND	paf.effective_end_date >= p_effort_start
	    and
            ppf.effective_start_date <= p_effort_end and
            ppf.effective_end_date >= p_effort_start)  ;

      ELSIF template_rec.array_sel_criteria(i) ='SUP' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count) (
            select 'SUP', count(distinct person_id) from per_all_assignments_f paf where
            supervisor_id in (select TO_NUMBER(criteria_value1) from psp_report_template_details_h prtd where
            criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='SUP'
            and request_id = p_request_id
                  and include_exclude_flag='I'
            )
	    AND paf.assignment_type = 'E'
	    and
            effective_start_date <= p_effort_end and
            effective_end_date >= p_effort_start) ;

      ELSIF template_rec.array_sel_criteria(i) ='AWD' THEN

      --- replaced non-performant insert with this for 4429787
 insert into psp_selection_cardinality_gt(lookup_code, total_count)(
SELECT  'AWD', COUNT(DISTINCT psl.person_id)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      per_time_periods ptp
WHERE
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='AWD' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
  psl.award_id = TO_NUMBER(prtd.criteria_value1) AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF template_rec.array_sel_criteria(i)='ATY' THEN
      --- replaced non-performant insert with this for 4429787


INSERT INTO psp_selection_cardinality_gt(lookup_code, total_count)(
SELECT  'ATY', COUNT(DISTINCT psl.person_id)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      gms_awards_all gaa,
      per_time_periods ptp
WHERE psl.award_id = gaa.award_id AND
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='ATY' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id = p_request_id AND
  gaa.type=prtd.criteria_value1 AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF template_rec.array_sel_criteria(i)='PRT' THEN
      --- replaced non-performant insert with this for 4429787
             INSERT INTO psp_selection_cardinality_gt(lookup_code, total_count)(
SELECT  'PRT', COUNT(DISTINCT psl.person_id)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      pa_projects_all ppa ,
      per_time_periods ptp
WHERE psl.project_id = ppa.project_id AND
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='PRT' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
  ppa.project_type=prtd.criteria_value1 AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF template_rec.array_sel_criteria(i)='PRJ' THEN
      --- replaced non-performant insert with this for 4429787
             insert into psp_selection_cardinality_gt(lookup_code, total_count)(
SELECT  'PRJ', COUNT(DISTINCT psl.person_id)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      per_time_periods ptp
WHERE
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='PRJ' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
 psl.project_id = TO_NUMBER(prtd.criteria_value1) AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF template_rec.array_sel_criteria(i)='PAY' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count)(
            select 'PAY', count(distinct person_id) from per_assignments_f paf where
            payroll_id in (select TO_NUMBER(criteria_value1) from psp_report_template_details_h prtd where
            criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='PAY'
                  and include_exclude_flag='I' and request_id = p_request_id
            )
	    AND paf.assignment_type = 'E'
	    and
            effective_start_date <= p_effort_end and
            effective_end_date >= p_effort_start) ;

      ELSIF template_rec.array_sel_criteria(i)='LOC' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count)(
            select 'LOC', count(distinct person_id) from per_assignments_f paf where
            location_id in (select TO_NUMBER(criteria_value1) from psp_report_template_details_h prtd where
            criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='LOC'
                  and include_exclude_flag='I' and request_id = p_request_id
            )
	    AND paf.assignment_type = 'E'
	    and
            effective_start_date <= p_effort_end and
            effective_end_date >= p_effort_start) ;

      ELSIF template_rec.array_sel_criteria(i)='ORG' THEN

             insert into psp_selection_cardinality_gt(lookup_code, total_count)(
             select 'ORG', count(distinct person_id) from per_assignments_f paf where
             organization_id in (select TO_NUMBER(criteria_value1) from  psp_report_template_details_h prtd
             where
             criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='ORG'
                  and include_exclude_flag='I' and request_id = p_request_id
             )
             AND paf.assignment_type = 'E'
	     and effective_start_date  <= p_effort_end and
             effective_end_date >= p_effort_start);

      ELSIF template_rec.array_sel_criteria(i)='JOB' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count)(
            select 'JOB', count(distinct person_id) from per_assignments_f paf where
            job_id in (select TO_NUMBER(criteria_value1) from psp_report_template_details_h prtd where
            criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='JOB'
                  and include_exclude_flag='I' and request_id=p_request_id
            )
	    AND paf.assignment_type = 'E'
	    and
            effective_start_date <= p_effort_end and
            effective_end_date >= p_effort_start) ;

      ELSIF template_rec.array_sel_criteria(i)='POS' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count) (
            select 'POS', count(distinct person_id) from per_assignments_f paf where
            position_id in (select TO_NUMBER(criteria_value1) from psp_report_template_details_h prtd where
            criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='POS'
                  and include_exclude_flag='I' and request_id = p_request_id
            )
	    AND paf.assignment_type = 'E'
	    and
            effective_start_date <= p_effort_end and
            effective_end_date >= p_effort_start) ;

      ELSIF template_rec.array_sel_criteria(i)='ASS' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count) (
            select 'ASS', count(distinct person_id) from per_assignments_f paf where
            assignment_status_type_id in (select TO_NUMBER(criteria_value1) from psp_report_template_details_h
            prtd where
            criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='ASS'
                  and include_exclude_flag='I' and request_id = p_request_id
            )
	    AND paf.assignment_type = 'E'
	    and
            effective_start_date <= p_effort_end and
            effective_end_date >= p_effort_start) ;

      ELSIF template_rec.array_sel_criteria(i)='CST' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count) (
            select 'CST', count(distinct paf.person_id) from per_assignments_f paf
            , pay_payrolls_f ppf  where
            ppf.payroll_id = paf.payroll_id and
            ppf.consolidation_set_id in
            (select TO_NUMBER(criteria_value1) from psp_report_template_details_h
            prtd where
            criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='CST'
                  and include_exclude_flag='I'  and request_id = p_request_id
            )
	    AND paf.assignment_type = 'E'
	    and
            ppf.effective_start_date <=  p_effort_end
            and ppf.effective_end_date >= p_effort_start
            and  paf.effective_start_date <= p_effort_end and
            paf.effective_end_date >= p_effort_start);


      ELSIF template_rec.array_sel_criteria(i) = 'AST' THEN

            insert into psp_selection_cardinality_gt(lookup_code, total_count) (
           select 'AST', count(distinct paf.person_id) from per_all_assignments_f paf, hr_assignment_sets has ,
           hr_assignment_Set_amendments hasa
            where
            has.assignment_set_id in  (
            select TO_NUMBER(criteria_value1) from psp_report_template_details_h
            prtd where
            criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='AST'
                  and include_exclude_flag='I' and request_id =p_request_id
            )
           and
           ( (   paf.payroll_id = has.payroll_id and
            paf.effective_start_date <= p_effort_end and
            paf.effective_end_date >= p_effort_start
            AND paf.assignment_type = 'E'
	    and has.assignment_set_id = hasa.assignment_Set_id
            )
            OR
            (
            paf.assignment_id = hasa.assignment_id and
             paf.effective_start_date <= p_effort_end and
            paf.effective_end_date >= p_effort_start
            AND paf.assignment_type = 'E'
	    and hasa.assignment_Set_id=has.assignment_Set_id and include_or_exclude ='I') )
            and not exists (select assignment_id from hr_assignment_Set_amendments hasa where
            hasa.assignment_id = paf.assignment_id and hasa.include_or_exclude ='E'
            AND paf.assignment_type = 'E'
	    and  paf.effective_start_date <= p_effort_end and
            paf.effective_end_date >= p_effort_start
            ));





      ELSIF template_rec.array_sel_criteria(i)='PPG' THEN

       l_dyn_criteria:='PPG';
    -- fnd_file.put_line(fnd_file.log,  ' dyn_criteria is ' ||l_dyn_criteria);

      ELSIF template_rec.array_sel_criteria(i)='GLA' THEN

       l_dyn_criteria:='GLA';
    -- fnd_file.put_line(fnd_file.log,  ' dyn_criteria is ' ||l_dyn_criteria);

     END IF;

     END LOOP;



  /* Next find the selection criteria with lowest cardinality. Use it to prepare the initial list */

     OPEN get_lowest_cardinality_csr;
     FETCH get_lowest_cardinality_csr into g_lookup_code;
     CLOSE get_lowest_cardinality_csr;

     IF g_lookup_code is not null then
       l_atleast_one_criteria:='Y';

    -- fnd_file.put_line(fnd_file.log,  ' g_lookup_code  is '||g_lookup_code);

      hr_utility.trace( 'g_lookup_code -> '||g_lookup_code );

    ELSE

     OPEN get_zero_cardinality_csr;
     FETCH get_zero_cardinality_csr into g_lookup_code;
     CLOSE get_zero_cardinality_csr;

       -- fnd_file.put_line(fnd_file.log,  ' g_lookup_code  is '||g_lookup_code);

         hr_utility.trace( ' Inside zero cardinality => g_lookup_code=  '||g_lookup_code );

          IF g_lookup_code is not null then
             l_atleast_one_criteria:='Y';

          END IF;

      /* To handle the case where one or more of the selection criterai have 0 cardinality */

     END IF;

/*
     EXCEPTION WHEN no_data_found then

*/

        IF g_lookup_code is NULL then

         BEGIN

         /* when no static selection criteria have been chosen, then invoke the dynamic selection criteria
         */


   -- fnd_file.put_line(fnd_file.log,  ' g_lookup_code  is null ');
         hr_utility.trace( ' Inside zero cardinality => g_lookup_code is null');

 IF l_dyn_criteria  ='PPG' then
              l_atleast_one_criteria:='Y';


                OPEN ppg_cursor;

              FETCH PPG_CURSOR into l_criteria_value1, l_criteria_value2;
                -- fnd_file.put_line(fnd_file.log, 'after fetch of ppg cursor ');
              IF l_criteria_value1 is not null then


                l_sql_string := l_criteria_value1 ||' = '||''''|| l_criteria_value2 ||''''  ;

             --   g_exec_string:= l_sql_string;

          LOOP

                 FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
          --     fnd_file.put_line(fnd_file.log, 'after second fetch of ppg cursor ');
                 EXIT WHEN PPG_CURSOR%NOTFOUND;

 /*
                 select l_sql_string
                 || '  OR ' || l_criteria_value1 || ' =  ' || ''''|| l_criteria_value2 ||''''
                 into g_exec_string from psp_report_template_details_h ;

*/

                    g_exec_string:= l_sql_string|| ' OR '||l_criteria_value1 ||' = '||'''' || l_criteria_value2|| '''';

                    l_sql_string:=g_exec_string;

           END LOOP;
                 close ppg_cursor;

               --   l_sql_string:= g_exec_string;

                  IF l_sql_string is not null then
                         g_exec_string := 'insert into psp_selection_cardinality_gt(lookup_code, total_count)
                         (select '||  '''' || 'PPG' || ''''||' , count(person_id)
                          from per_assignments_f paf,
                          pay_people_groups ppg
                          where  paf.people_group_id= ppg.people_group_id
                          AND	paf.assignment_type = ''' || 'E' || '''
			  and paf.effective_end_date >= :p_effort_Start and
                            paf.effective_start_date <= :p_effort_end
                          and
                          ppg.people_group_id
                          in (select people_group_id from pay_people_groups
                          where ' || l_sql_string
                          || ' ))
                           ';

                         hr_utility.trace( ' g_exec_string = '||g_exec_string );

                        -- fnd_file.put_line(fnd_file.log , ' g_exec_string 1 is '||g_exec_string);

                          execute immediate g_exec_string using IN p_effort_Start, p_effort_end;
                           g_lookup_code := 'PPG';
                   END IF;
                END IF;


         ELSIF  l_dyn_criteria ='GLA' then

           l_atleast_one_criteria:='Y';

           OPEN gla_cursor;

           FETCH GLA_CURSOR into l_criteria_value1, l_criteria_value2, l_criteria_value3;

           IF l_criteria_value1 is not null then

             l_sql_string := l_criteria_value1 ||' between '|| '''' || l_criteria_value2 || '''' ||
            ' and ' || ''''||l_criteria_value3||'''' ;

         --   g_exec_string := l_sql_string;


             LOOP

             FETCH GLA_CURSOR INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
             EXIT WHEN GLA_CURSOR%NOTFOUND;

              g_exec_string:= l_sql_string
             || '  OR ' || l_criteria_value1 || ' between ' || ''''|| l_criteria_value2 || '''' ||
              ' and ' || ''''|| l_criteria_value3 || ''''  ;
               l_sql_string:=g_exec_string;

             END LOOP;
             close gla_cursor;

         --   l_sql_string:= g_exec_string;

      -- fnd_file.put_line(fnd_file.log,' before isnerting g_exec_string in GL criteria ');
            if l_sql_string is not null then
            g_exec_string := 'insert into psp_selection_cardinality_gt(lookup_code, total_count)
            ( select '|| '''' || 'GLA' || ''''|| ' , count( distinct psl.person_id)
            from psp_summary_lines psl, psp_distribution_lines_history pdnh, psp_pre_gen_dist_lines_history ppg,
            psp_adjustment_lines_history palh
             , gl_code_combinations gcc
            where
            psl.business_group_id = '|| p_business_group_id || ' and
            psl.set_of_books_id =' || p_set_of_books_id || ' and
             gcc.code_combination_id= psl.gl_code_combination_id
and
            psl.summary_line_id = pdnh.summary_line_id(+) and
            psl.summary_line_id = ppg.summary_line_id(+) and
            psl.summary_line_id = palh.summary_line_id(+) and
            psl.status_code='||''''||'A'||''''||' and
  ((psl.source_type in ('||''''||'N'||''''||' ,'|| ''''|| 'O'||''''||') and
     pdnh.distribution_date between :p_effort_start and :p_effort_end
     and pdnh.summary_line_id = psl.summary_line_id
  and pdnh.reversal_entry_flag is null
 and pdnh.adjustment_batch_name is null
)  OR
  ( psl.source_type='||''''||'P'||''''||' and
ppg.distribution_date between :p_effort_start   and :p_effort_end  and
 ppg.summary_line_id = psl.summary_line_id and
ppg.adjustment_batch_name is null and
ppg.reversal_entry_flag is null)
    OR (psl.source_type='||''''||'A'||''''||' and
   palh.summary_line_id = psl.summary_line_id and
   palh.reversal_entry_flag is null and
   palh.adjustment_batch_name is null and
   NVL(palh.original_line_flag, ' || ''''|| 'N' || ''''|| ') = '||''''|| 'N' || ''''
 || '  and  palh.distribution_date between  :p_effort_start and :p_effort_end )) and
             gcc.code_combination_id= psl.gl_code_combination_id and
            gcc.code_combination_id in (select code_combination_id from gl_code_combinations
            where ' || l_sql_string
            || ' )) ';


      -- fnd_file.put_line(fnd_file.log,' g_exec_string '||g_exec_string);

         hr_utility.trace( ' g_exec_string =   '||g_exec_string );
           execute immediate g_exec_string using IN p_effort_start, p_effort_end, p_effort_start, p_effort_end ,p_effort_start, p_effort_end;
           g_lookup_code :='GLA';

       END IF;
       END IF;


           END IF;

         END;

       END IF;

        IF NVL(l_atleast_one_criteria, 'N')='N' then

           g_lookup_code:='ALL' ;

        END IF;

     EXCEPTION WHEN OTHERS THEN
     fnd_file.put_line(fnd_file.log,  ' EXCEPTION '||sqlerrm);


    END;

    PROCEDURE prepare_initial_person_list(p_request_id IN NUMBER, p_effort_start
IN DATE, p_effort_end IN DATE, p_business_group_id IN NUMBER, p_Set_of_books_id IN NUMBER) IS
PRAGMA	AUTONOMOUS_TRANSACTION;
CURSOR PPG_CURSOR IS
      select criteria_value1, criteria_value2 from
      psp_report_template_details_h  where  request_id = p_request_id and
      criteria_lookup_type= 'PSP_SELECTION_CRITERIA' and criteria_lookup_code='PPG' and
      include_exclude_flag='I';


CURSOR GLA_CURSOR IS
      select criteria_value1 , criteria_value2, criteria_value3 from
      psp_report_template_details_h where request_id = p_request_id and
      criteria_lookup_type ='PSP_SELECTION_CRITERIA' and criteria_lookup_code ='GLA' and
       include_exclude_flag='I';

i number;
l_criteria_value1 varchar2(30);
l_criteria_value2 varchar2(60);  -- Bug 8257434
l_criteria_value3  varchar2(30);

l_sql_string varchar2(1000);

l_cnt number;

     BEGIN
     IF g_lookup_code = 'PTY'  then

		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id, paf.person_id, paf.assignment_id
		FROM	per_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	person_type_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='PTY'
						AND	request_id = p_request_id
						AND	include_exclude_flag='I')
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

      ELSIF g_lookup_code ='EMP' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	ppf.person_id IN	(SELECT TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='EMP'
						AND	include_exclude_flag='I'
						AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

      ELSIF g_lookup_code ='SUP' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	supervisor_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='SUP'
						AND	include_exclude_flag='I'
						AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));


      ELSIF g_lookup_code='AWD' then

--- replaced original query for performance issues -- 4429787
             insert into psp_selected_persons_t(request_id, person_id, assignment_id)(
             select distinct p_request_id, psl.person_id  , paf.assignment_id
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      per_time_periods ptp,
      per_assignments_f paf
WHERE
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='AWD' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
psl.award_id = TO_NUMBER(prtd.criteria_value1) AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
  paf.person_id = psl.person_id AND
  paf.assignment_type = 'E' AND
  paf.effective_start_date <= p_effort_end AND
  paf.effective_end_date >= p_effort_start AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL
      AND NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF g_lookup_code ='ATY' then

      --- replaced non-performant insert with this for 4429787
INSERT INTO psp_selected_persons_t(request_id , person_id, assignment_id)(
SELECT  DISTINCT  p_request_id, psl.person_id, paf.assignment_id
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      gms_awards_all gaa ,
      per_time_periods ptp,
      per_assignments_f paf
WHERE psl.award_id = gaa.award_id AND
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='ATY' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
  gaa.type=prtd.criteria_value1 AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
  paf.person_id = psl.person_id AND
  paf.assignment_type = 'E' AND
  paf.effective_start_date <= p_effort_end AND
  paf.effective_end_date >= p_effort_start AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF g_lookup_code ='PRT' then
      --- replaced non-performant insert with this for 4429787

             INSERT INTO psp_selected_persons_t(request_id , person_id, assignment_id)(
SELECT  DISTINCT  p_request_id, psl.person_id, paf.assignment_id
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      pa_projects_all ppa ,
      per_time_periods ptp,
      per_assignments_f paf
WHERE psl.project_id = ppa.project_id AND
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='PRT' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
  ppa.project_type=prtd.criteria_value1 AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
  paf.person_id = psl.person_id AND
  paf.assignment_type = 'E' AND
  paf.effective_start_date <= p_effort_end AND
  paf.effective_end_date >= p_effort_start AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));

-- select count(person_id) into l_cnt  from psp_selected_persons_t where request_id = p_request_id;

     -- fnd_file.put_line(fnd_file.log,'after insert into psp_selected_persons_t '||l_cnt);



      ELSIF g_lookup_code ='PRJ' then
--- replaced original query for performance issues -- 4429787
             insert into psp_selected_persons_t(request_id, person_id, assignment_id)(
             select distinct p_request_id, psl.person_id, paf.assignment_id
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      per_time_periods ptp,
      per_assignments_f paf
WHERE
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='PRJ' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
  psl.business_group_id = p_business_group_id AND
psl.project_id = TO_NUMBER(prtd.criteria_value1) AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
  paf.person_id = psl.person_id AND
  paf.assignment_type = 'E' AND
  paf.effective_start_date <= p_effort_end AND
  paf.effective_end_date >= p_effort_start AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF g_lookup_code ='PAY' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	payroll_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='PAY'
					AND	include_exclude_flag='I'
					AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

      ELSIF g_lookup_code ='LOC' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	location_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='LOC'
					AND	include_exclude_flag='I'
					AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

      ELSIF g_lookup_code ='ORG' then

		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	organization_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='ORG'
						AND	request_id = p_request_id
						AND	include_exclude_flag='I')
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

      ELSIF g_lookup_code='CST' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	pay_payrolls_f pp,
			per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	pp.payroll_id = paf.payroll_id
		AND	pp.consolidation_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='CST'
							AND	include_exclude_flag='I'
							AND request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	pp.effective_start_date <= p_effort_end
		AND	pp.effective_end_date >= p_effort_start
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

      ELSIF g_lookup_code = 'AST' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id, paf.person_id, paf.assignment_id
		FROM	per_all_assignments_f paf,
			hr_assignment_sets has,
			hr_assignment_set_amendments hasa,
			per_all_people_f ppf,
			per_assignment_status_types past
		WHERE	has.assignment_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='AST'
							AND	include_exclude_flag='I'
							AND request_id =p_request_id)
		AND	(	(paf.payroll_id = has.payroll_id
				AND	paf.assignment_type = 'E'
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND	has.assignment_set_id = hasa.assignment_set_id)
			OR	(paf.assignment_id = hasa.assignment_id
				AND	paf.assignment_type = 'E'
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND	hasa.assignment_set_id=has.assignment_set_id AND include_or_exclude ='I'))
		AND	NOT EXISTS	(SELECT	assignment_id
					FROM	hr_assignment_set_amendments hasa
					WHERE	hasa.assignment_id = paf.assignment_id AND hasa.include_or_exclude ='E'
					AND	paf.assignment_type = 'E'
					AND	paf.effective_start_date <= p_effort_end
					AND	paf.effective_end_date >= p_effort_start)
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));


      ELSIF g_lookup_code ='JOB' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	job_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='JOB'
					AND	include_exclude_flag='I'
					AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

      ELSIF g_lookup_code ='POS' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	position_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='POS'
					AND	request_id = p_request_id
					AND	include_exclude_flag='I')
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

      ELSIF g_lookup_code ='ASS' then

      		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	paf.assignment_status_type_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='ASS'
							AND	request_id = p_request_id
							AND	include_exclude_flag='I')
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	ppf.business_group_id = p_business_group_id
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));


      ELSIF g_lookup_code='PPG'    then


              open ppg_cursor;
              FETCH PPG_CURSOR into l_criteria_value1, l_criteria_value2;
              IF l_criteria_value1 is not null then


                l_sql_string := l_criteria_value1 ||' = '||''''|| l_criteria_value2 ||''''  ;

             --   g_exec_string:= l_sql_string;

              LOOP

                 FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
                 EXIT WHEN PPG_CURSOR%NOTFOUND;

/*
                 select l_sql_string
                 || '  OR ' || l_criteria_value1 || ' =  ' || ''''|| l_criteria_value2 ||''''
                 into g_exec_string from psp_report_template_details_h ;

*/
                  g_exec_string:=  l_sql_string || ' OR '||l_criteria_value1 ||' = ' || ''''||l_criteria_value2 || '''';

                  l_sql_string:= g_exec_string;

             END LOOP;
                 close ppg_cursor;


                  if l_sql_string is not null then
                         g_exec_string := 'insert into psp_selected_persons_t
                         (request_id, person_id, assignment_id)
                         (select :request_id  , paf.person_id, paf.assignment_id
                          from per_assignments_f paf,
                          pay_people_groups ppg,
			  per_all_people_f ppf,
			  per_assignment_status_types past
                          where  paf.people_group_id= ppg.people_group_id
			  AND	paf.person_id = ppf.person_id
			  AND	paf.assignment_status_type_id =   past.assignment_status_type_id
                          AND	paf.assignment_type = ''' || 'E' || '''
			  AND   paf.effective_end_date >= :p_effort_Start
			  AND	paf.effective_start_date <= :p_effort_end
			  AND	ppf.effective_end_date >= :p_effort_start
			  AND	ppf.effective_start_date <= :p_effort_end
                          AND	ppg.people_group_id IN (SELECT people_group_id FROM pay_people_groups
							WHERE ' || l_sql_string|| ' )
			AND (		past.per_system_status <> '''|| 'TERM_ASSIGN' ||'''
				OR	EXISTS ( select null
					FROM	psp_pre_gen_dist_lines_history
					WHERE	distribution_date between :p_effort_start and :p_effort_end
					AND	assignment_id = paf.assignment_id
	 				AND     reversal_entry_flag IS NULL
					AND	rownum=1 )
				OR      EXISTS (SELECT null
					FROM   psp_distribution_lines_history pdlh
					, psp_summary_lines psl
					WHERE	pdlh.summary_line_id = psl.summary_line_id
					AND	distribution_date between :p_effort_start and :p_effort_end
					AND	psl.person_id = paf.person_id
					AND	psl.assignment_id =  paf.assignment_id
	 				AND     reversal_entry_flag IS NULL
					AND	rownum=1)))';

                         -- fnd_file.put_line(fnd_file.log, 'g_exec_string2 = '||g_exec_string);

                          execute immediate g_exec_string  using IN p_request_id, p_effort_start, p_effort_end,
			  p_effort_start, p_effort_end, p_effort_start, p_effort_end, p_effort_start, p_effort_end;
                  end if;
                end if;


         ELSIF  g_lookup_code ='GLA' then

           OPEN gla_cursor;

           FETCH GLA_CURSOR into l_criteria_value1, l_criteria_value2, l_criteria_value3;

           IF l_criteria_value1 is not null then

             l_sql_string := l_criteria_value1 ||' between '|| '''' || l_criteria_value2 ||''''||
            ' and ' || ''''|| l_criteria_value3 || '''' ;
         --   g_exec_string := l_sql_string;


             LOOP

             FETCH GLA_CURSOR INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
             EXIT WHEN GLA_CURSOR%NOTFOUND;

              g_exec_string:= l_sql_string
             || '  OR ' || l_criteria_value1 || ' between ' || ''''|| l_criteria_value2 || '''' ||
              ' and ' || ''''|| l_criteria_value3 || ''''  ;

              l_sql_string:=g_exec_string;


             END LOOP;
             close gla_cursor;

--            l_sql_string:= g_exec_string;

            if l_sql_string is not null then
            g_exec_string := 'insert into psp_selected_persons_t(request_id, person_id, assignment_id)
            ( select  :p_request_id, psl.person_id, psl.assignment_id
            from psp_summary_lines psl, psp_distribution_lines_history pdnh,
            psp_adjustment_lines_history palh, psp_pre_gen_dist_lines_history ppg,
             gl_code_combinations gcc
            where
            psl.business_group_id = '|| p_business_group_id || ' and
            psl.set_of_books_id = ' || p_Set_of_books_id ||' and
            psl.summary_line_id = pdnh.summary_line_id(+) and
            psl.summary_line_id = ppg.summary_line_id(+) and
            psl.summary_line_id = palh.summary_line_id(+) and
            psl.status_code= '||''''||'A'||''''||' and
  ((psl.source_type in ('||''''||'N'||''''||' ,'|| ''''|| 'O'||''''||') and
     pdnh.distribution_date between  :p_effort_start  and :p_effort_end
 and pdnh.reversal_entry_flag is null
 and pdnh.summary_line_id = psl.summary_line_id
 and pdnh.adjustment_batch_name is null
)  OR
  ( psl.source_type='||''''||'P'||''''||' and
ppg.distribution_date between :p_effort_start  and :p_effort_end  and
ppg.summary_line_id = psl.summary_line_id and
ppg.adjustment_batch_name is null and
ppg.reversal_entry_flag is null)
    OR (psl.source_type='||''''||'A'||''''||' and
    palh.adjustment_batch_name is null and
    palh.summary_line_id =psl.summary_line_id and
     NVL(palh.original_line_flag, ' || ''''|| 'N' || ''''|| ') = '||''''|| 'N' || ''''
   || ' and palh.distribution_date between :p_effort_start  and :p_effort_end )) and
             gcc.code_combination_id= psl.gl_code_combination_id and
            gcc.code_combination_id in (select code_combination_id from gl_code_combinations
            where ' || l_sql_string
            || ' )) ';

    -- fnd_file.put_line(fnd_file.log, 'g_exec_string 2=  '||g_exec_string);

           execute immediate g_exec_string using iN p_request_id, p_effort_start, p_effort_end, p_effort_start, p_effort_end, p_effort_start, p_effort_end;


       END IF;
       END IF;

      ELSIf g_lookup_code='ALL' then


--Bug 8222520


                INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	ppf.person_id IN	(select person_id from per_people_f where
						business_group_id = p_business_group_id and
             					effective_start_date  <= p_effort_end and
             					effective_end_date >= p_effort_start)
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1));


 END IF;


	COMMIT;
    END;



   PROCEDURE prune_initial_person_list(p_request_id IN NUMBER , p_effort_start IN DATE, p_effort_end IN DATE,
      p_business_group_id IN NUMBER, p_Set_of_books_id IN NUMBER)
IS


CURSOR get_all_selection_criteria(p_request_id IN  NUMBER) is
   SELECT distinct criteria_lookup_code,
   include_exclude_flag from
   psp_report_template_details_h where request_id = p_request_id and
   criteria_lookup_type='PSP_SELECTION_CRITERIA' ORDER BY include_exclude_flag;


CURSOR PPG_CURSOR IS
      select criteria_value1, criteria_value2 from
      psp_report_template_details_h  where  request_id = p_request_id and
      criteria_lookup_type= 'PSP_SELECTION_CRITERIA' and criteria_lookup_code='PPG' and include_exclude_flag='I';


CURSOR GLA_CURSOR IS
      select criteria_value1 , criteria_value2, criteria_value3 from
      psp_report_template_details_h where request_id = p_request_id and
      criteria_lookup_type ='PSP_SELECTION_CRITERIA' and criteria_lookup_code ='GLA' and include_exclude_flag='I';


type t_varchar_30_type is TABLE Of VARCHAR2(30)  INDEX BY BINARY_INTEGER;
 type t_varchar_1_type is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;

l_criteria_value1 varchar2(30);

l_criteria_value2 varchar2(60); -- Bug 8257434


l_criteria_value3  varchar2(30);



l_sql_string varchar2(1000);


i number;

    BEGIN
     open get_all_selection_criteria(p_request_id);
     fetch get_all_selection_criteria BULK COLLECT into template_sel_criteria.array_sel_criteria,
       template_sel_criteria.array_inc_exc_flag;

     close get_all_selection_criteria;



    for i in 1..template_sel_criteria.array_sel_criteria.count

  LOOP

  IF template_sel_criteria.array_inc_exc_flag(i) = 'I'  THEN


       IF  template_sel_criteria.array_sel_criteria(i) <>  g_lookup_code then
       IF template_sel_criteria.array_sel_criteria(i) = 'PTY'  THEN

		DELETE FROM psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
                /* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	person_id NOT IN	(SELECT	NVL( person_id, 0)
                AND    NOT EXISTS (     SELECT 1
				FROM	per_people_f ppf,
					psp_report_template_details_h prtd,
					per_assignments_f paf,
					per_assignment_status_types past
				WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
				AND	criteria_lookup_code='PTY'
				AND	paf.person_id = ppf.person_id
				AND	paf.assignment_type = 'E'
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND	ppf.effective_start_date <= p_effort_end
				AND	ppf.effective_end_date >= p_effort_start
				AND	include_exclude_flag='I'
				AND	ppf.person_type_id  = TO_NUMBER(prtd.criteria_value1)
				AND	prtd.request_id = p_request_id
				AND     ppf.person_id = pspt.person_id
				AND	paf.assignment_status_type_id =   past.assignment_status_type_id
				AND (		past.per_system_status <> 'TERM_ASSIGN'
					OR	EXISTS ( select null
						FROM	psp_pre_gen_dist_lines_history
						WHERE	distribution_date between p_effort_start and p_effort_end
						AND	assignment_id = paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1 )
					OR      EXISTS (SELECT null
						FROM   psp_distribution_lines_history pdlh
						, psp_summary_lines psl
						WHERE	pdlh.summary_line_id = psl.summary_line_id
						AND	distribution_date between p_effort_start and p_effort_end
						AND	psl.person_id = paf.person_id
						AND	psl.assignment_id =  paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1)));

       ELSIF template_sel_criteria.array_sel_criteria(i) = 'EMP' THEN

       		DELETE FROM psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
                 /* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	person_id  NOT IN	(SELECT	NVL(person_id,0)
                 AND    NOT EXISTS (     SELECT 1
				FROM	per_all_people_f ppf,
					per_assignments_f paf,
					per_assignment_status_types past
				WHERE	ppf.person_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='EMP'
					AND	include_exclude_flag='I'
					AND	prtd.request_id = p_request_id)
					AND	paf.person_id = ppf.person_id
					AND	paf.assignment_type = 'E'
					AND	paf.effective_start_date <= p_effort_end
					AND	paf.effective_end_date >= p_effort_start
				AND	ppf.effective_start_date <= p_effort_end
				AND	ppf.effective_end_date >= p_effort_start
				AND     ppf.person_id = pspt.person_id
				AND	paf.assignment_status_type_id =   past.assignment_status_type_id
				AND (		past.per_system_status <> 'TERM_ASSIGN'
					OR	EXISTS ( select null
						FROM	psp_pre_gen_dist_lines_history
						WHERE	distribution_date between p_effort_start and p_effort_end
						AND	assignment_id = paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1 )
					OR      EXISTS (SELECT null
						FROM   psp_distribution_lines_history pdlh
						, psp_summary_lines psl
						WHERE	pdlh.summary_line_id = psl.summary_line_id
						AND	distribution_date between p_effort_start and p_effort_end
						AND	psl.person_id = paf.person_id
						AND	psl.assignment_id =  paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1)));


      ELSIF  template_sel_criteria.array_sel_criteria(i) ='SUP' THEN

		DELETE FROM	psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
                /* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
                AND    NOT EXISTS (     SELECT 1
					FROM	per_all_assignments_f paf,
						psp_report_template_details_h prtd,
						per_assignment_status_types past
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='SUP'
					AND	include_exclude_flag='I'
					AND	paf.supervisor_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id
					AND     paf.assignment_type = 'E'
					AND	paf.effective_start_date <= p_effort_end
					AND	effective_end_date >= p_effort_start
					AND     paf.person_id = pspt.person_id
					AND	paf.assignment_status_type_id =   past.assignment_status_type_id
					AND (		past.per_system_status <> 'TERM_ASSIGN'
						OR	EXISTS ( select null
							FROM	psp_pre_gen_dist_lines_history
							WHERE	distribution_date between p_effort_start and p_effort_end
							AND	assignment_id = paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1 )
						OR      EXISTS (SELECT null
							FROM   psp_distribution_lines_history pdlh
							, psp_summary_lines psl
							WHERE	pdlh.summary_line_id = psl.summary_line_id
							AND	distribution_date between p_effort_start and p_effort_end
							AND	psl.person_id = paf.person_id
							AND	psl.assignment_id =  paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1)));


      ELSIF  template_sel_criteria.array_sel_criteria(i) =  'AWD' THEN


--- replaced original query for performance issues -- 4429787
 delete from  psp_selected_persons_t where request_id = p_request_id AND person_id not in (
             select psl.person_id
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      per_time_periods ptp
WHERE
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='AWD' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
psl.award_id = TO_NUMBER(prtd.criteria_value1) AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL
      AND NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF  template_sel_criteria.array_sel_criteria(i)  =  'ATY' then


      --- replaced non-performant delete with this for 4429787
             DELETE FROM  psp_selected_persons_t WHERE request_id = p_request_id AND person_id NOT IN (
SELECT  NVL(psl.person_id,0)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      gms_awards_all gaa ,
      per_time_periods ptp
WHERE psl.award_id = gaa.award_id AND
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='ATY' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
  gaa.type=prtd.criteria_value1 AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
     NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF  template_sel_criteria.array_sel_criteria(i)  ='PRT' THEN

      --- replaced non-performant delete with this for 4429787
             DELETE FROM  psp_selected_persons_t WHERE request_id = p_request_id AND person_id NOT IN (
SELECT  NVL(psl.person_id,0)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      pa_projects_all ppa ,
      per_time_periods ptp
WHERE psl.project_id = ppa.project_id AND
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='PRT' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
  ppa.project_type=prtd.criteria_value1 AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
     NVL(palh.original_line_flag, 'N') ='N')));

      elsif  template_sel_criteria.array_sel_criteria(i)  ='PRJ' THEN

      --- replaced non-performant insert with this for 4429787
             delete from  psp_selected_persons_t where request_id = p_request_id AND person_id not in (
             select nvl( psl.person_id ,0)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      per_time_periods ptp
WHERE
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='PRJ' AND
  prtd.include_exclude_flag='I' AND
  prtd.request_id =p_request_id AND
psl.project_id = TO_NUMBER(prtd.criteria_value1) AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));

      elsif  template_sel_criteria.array_sel_criteria(i)  ='PAY' THEN

      		DELETE FROM	psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
		/* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
                AND    NOT EXISTS (     SELECT 1
					FROM	per_assignments_f paf,
						psp_report_template_details_h prtd,
						per_assignment_status_types past
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='PAY'
					AND	include_exclude_flag='I'
                                        AND     paf.assignment_type = 'E'
					AND	effective_start_date <= p_effort_end
					AND	effective_end_date >= p_effort_start
					AND	paf.payroll_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id
					AND     paf.person_id = pspt.person_id
					AND	paf.assignment_status_type_id =   past.assignment_status_type_id
					AND (		past.per_system_status <> 'TERM_ASSIGN'
						OR	EXISTS ( select null
							FROM	psp_pre_gen_dist_lines_history
							WHERE	distribution_date between p_effort_start and p_effort_end
							AND	assignment_id = paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1 )
						OR      EXISTS (SELECT null
							FROM   psp_distribution_lines_history pdlh
							, psp_summary_lines psl
							WHERE	pdlh.summary_line_id = psl.summary_line_id
							AND	distribution_date between p_effort_start and p_effort_end
							AND	psl.person_id = paf.person_id
							AND	psl.assignment_id =  paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1)));



      elsif  template_sel_criteria.array_sel_criteria(i) ='LOC' THEN

		DELETE FROM	psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
		/* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
                AND    NOT EXISTS (     SELECT 1
					FROM	per_assignments_f paf ,
						psp_report_template_details_h prtd,
						per_assignment_status_types past
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='LOC'
                                        AND     paf.assignment_type = 'E'
					AND	effective_start_date <= p_effort_end
					AND	effective_end_date >= p_effort_start
					AND	include_exclude_flag='I'
					AND	paf.location_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id
					AND     paf.person_id = pspt.person_id
					AND	paf.assignment_status_type_id =   past.assignment_status_type_id
					AND (		past.per_system_status <> 'TERM_ASSIGN'
						OR	EXISTS ( select null
							FROM	psp_pre_gen_dist_lines_history
							WHERE	distribution_date between p_effort_start and p_effort_end
							AND	assignment_id = paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1 )
						OR      EXISTS (SELECT null
							FROM   psp_distribution_lines_history pdlh
							, psp_summary_lines psl
							WHERE	pdlh.summary_line_id = psl.summary_line_id
							AND	distribution_date between p_effort_start and p_effort_end
							AND	psl.person_id = paf.person_id
							AND	psl.assignment_id =  paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1)));

      elsif  template_sel_criteria.array_sel_criteria(i) ='ORG' THEN

		DELETE FROM	psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
	--	AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
		AND    NOT EXISTS (     SELECT 1
					FROM	per_assignments_f paf ,
						psp_report_template_details_h prtd,
						per_assignment_status_types past
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='ORG'
					AND	include_exclude_flag='I'
                                        AND     paf.assignment_type = 'E'
					AND	effective_start_date <= p_effort_end
					AND	effective_end_date >= p_effort_start
					AND	paf.organization_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id
					AND     paf.person_id = pspt.person_id
					AND	paf.assignment_status_type_id =   past.assignment_status_type_id
					AND (		past.per_system_status <> 'TERM_ASSIGN'
						OR	EXISTS ( select null
							FROM	psp_pre_gen_dist_lines_history
							WHERE	distribution_date between p_effort_start and p_effort_end
							AND	assignment_id = paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1 )
						OR      EXISTS (SELECT null
							FROM   psp_distribution_lines_history pdlh
							, psp_summary_lines psl
							WHERE	pdlh.summary_line_id = psl.summary_line_id
							AND	distribution_date between p_effort_start and p_effort_end
							AND	psl.person_id = paf.person_id
							AND	psl.assignment_id =  paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1)));


      elsif template_sel_criteria.array_sel_criteria(i)='CST' THEN
      		DELETE FROM	psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
		/* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
		AND    NOT EXISTS (     SELECT 1
				FROM	per_assignments_f paf,
					pay_payrolls_f ppf,
					per_assignment_status_types past
				WHERE	ppf.payroll_id = paf.payroll_id
				AND	ppf.consolidation_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='CST'
					AND	include_exclude_flag='I'
					AND	request_id = p_request_id)
				AND     paf.assignment_type = 'E'
				AND	ppf.effective_start_date <= p_effort_end
				AND	ppf.effective_end_date >= p_effort_start
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND     paf.person_id = pspt.person_id
				AND	paf.assignment_status_type_id =   past.assignment_status_type_id
				AND (		past.per_system_status <> 'TERM_ASSIGN'
					OR	EXISTS ( select null
						FROM	psp_pre_gen_dist_lines_history
						WHERE	distribution_date between p_effort_start and p_effort_end
						AND	assignment_id = paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1 )
					OR      EXISTS (SELECT null
						FROM   psp_distribution_lines_history pdlh
						, psp_summary_lines psl
						WHERE	pdlh.summary_line_id = psl.summary_line_id
						AND	distribution_date between p_effort_start and p_effort_end
						AND	psl.person_id = paf.person_id
						AND	psl.assignment_id =  paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1)));


      elsif template_sel_criteria.array_sel_criteria(i) = 'AST' THEN

		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id NOT IN	(SELECT	NVL(paf.person_id,0)
		FROM	per_all_assignments_f paf,
			hr_assignment_sets has,
			hr_assignment_set_amendments hasa,
			per_assignment_status_types past
		WHERE	has.assignment_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
			FROM	psp_report_template_details_h prtd
			WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
			AND	criteria_lookup_code='AST'
			AND	include_exclude_flag='I'
			AND	request_id =p_request_id)
		AND	(	(paf.payroll_id = has.payroll_id
				AND     paf.assignment_type = 'E'
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND	has.assignment_set_id = hasa.assignment_set_id)
			OR	(paf.assignment_id = hasa.assignment_id
				AND     paf.assignment_type = 'E'
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND	hasa.assignment_set_id=has.assignment_set_id
				AND	include_or_exclude ='I'))
		AND	NOT EXISTS	(SELECT	assignment_id
			FROM	hr_assignment_set_amendments hasa
			WHERE	hasa.assignment_id = paf.assignment_id
			AND     paf.assignment_type = 'E'
			AND	hasa.include_or_exclude ='E'
			AND	paf.effective_start_date <= p_effort_end
			AND	paf.effective_end_date >= p_effort_start)
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
				, psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1)));


      elsif  template_sel_criteria.array_sel_criteria(i)  = 'JOB' THEN

      		DELETE FROM	psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
		/* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
		AND    NOT EXISTS (     SELECT 1
				FROM	per_assignments_f paf ,
					psp_report_template_details_h prtd,
					per_assignment_status_types past
				WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
				AND	criteria_lookup_code='JOB'
				AND	include_exclude_flag='I'
                                AND     paf.assignment_type = 'E'
				AND	effective_start_date <= p_effort_end
				AND	effective_end_date >= p_effort_start
				AND	paf.job_id = TO_NUMBER(prtd.criteria_value1)
				AND	prtd.request_id = p_request_id
				AND     paf.person_id = pspt.person_id
				AND	paf.assignment_status_type_id =   past.assignment_status_type_id
				AND (		past.per_system_status <> 'TERM_ASSIGN'
					OR	EXISTS ( select null
						FROM	psp_pre_gen_dist_lines_history
						WHERE	distribution_date between p_effort_start and p_effort_end
						AND	assignment_id = paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1 )
					OR      EXISTS (SELECT null
						FROM   psp_distribution_lines_history pdlh
						, psp_summary_lines psl
						WHERE	pdlh.summary_line_id = psl.summary_line_id
						AND	distribution_date between p_effort_start and p_effort_end
						AND	psl.person_id = paf.person_id
						AND	psl.assignment_id =  paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1)));

      elsif  template_sel_criteria.array_sel_criteria(i)  ='POS' THEN

		DELETE FROM	psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
		/* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
		AND    NOT EXISTS (     SELECT 1
				FROM	per_assignments_f paf ,
					psp_report_template_details_h prtd,
					per_assignment_status_types past
				WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
				AND	criteria_lookup_code='POS'
                                AND     paf.assignment_type = 'E'
						 and
                                                 effective_start_date <= p_effort_end and
                                                 effective_end_date >= p_effort_start
				AND	include_exclude_flag='I'
				AND	paf.position_id = TO_NUMBER(prtd.criteria_value1)
				AND	prtd.request_id = p_request_id
				AND     paf.person_id = pspt.person_id
				AND	paf.assignment_status_type_id =   past.assignment_status_type_id
				AND (		past.per_system_status <> 'TERM_ASSIGN'
					OR	EXISTS ( select null
						FROM	psp_pre_gen_dist_lines_history
						WHERE	distribution_date between p_effort_start and p_effort_end
						AND	assignment_id = paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1 )
					OR      EXISTS (SELECT null
						FROM   psp_distribution_lines_history pdlh
						, psp_summary_lines psl
						WHERE	pdlh.summary_line_id = psl.summary_line_id
						AND	distribution_date between p_effort_start and p_effort_end
						AND	psl.person_id = paf.person_id
						AND	psl.assignment_id =  paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1)));

      elsif  template_sel_criteria.array_sel_criteria(i)  ='ASS' THEN


		DELETE FROM	psp_selected_persons_t pspt
		WHERE	request_id = p_request_id
		/* Bug 5087294 : Performance fix replacing not in with not exists */
		-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
		AND    NOT EXISTS (     SELECT 1
				FROM	per_assignments_f paf ,
					psp_report_template_details_h prtd,
					per_assignment_status_types past
				WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
				AND	criteria_lookup_code='ASS'
				AND	include_exclude_flag='I'
				AND	paf.assignment_status_type_id = TO_NUMBER(prtd.criteria_value1)
				AND	prtd.request_id = p_request_id
				AND     paf.assignment_type = 'E'
				AND	effective_start_date <= p_effort_end
				AND	effective_end_date >= p_effort_start
				AND     paf.person_id = pspt.person_id
				AND	paf.assignment_status_type_id =   past.assignment_status_type_id
				AND (		past.per_system_status <> 'TERM_ASSIGN'
					OR	EXISTS ( select null
						FROM	psp_pre_gen_dist_lines_history
						WHERE	distribution_date between p_effort_start and p_effort_end
						AND	assignment_id = paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1 )
					OR      EXISTS (SELECT null
						FROM   psp_distribution_lines_history pdlh
						, psp_summary_lines psl
						WHERE	pdlh.summary_line_id = psl.summary_line_id
						AND	distribution_date between p_effort_start and p_effort_end
						AND	psl.person_id = paf.person_id
						AND	psl.assignment_id =  paf.assignment_id
		 				AND     reversal_entry_flag IS NULL
						AND	rownum=1)));

/*
      elsif template_rec.array_sel_criteria(i)='EST' then

*/

      elsif template_sel_criteria.array_sel_criteria(i)='PPG' THEN

      OPEN ppg_cursor;

      FETCH PPG_CURSOR into l_criteria_value1, l_criteria_value2;
      IF l_criteria_value1 is not null then


      l_sql_string := l_criteria_value1 ||' = '||''''|| l_criteria_value2 ||''''  ;

  --    g_exec_string:= l_sql_string;

    LOOP

     FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
     EXIT WHEN PPG_CURSOR%NOTFOUND;

/*
     select l_sql_string
 || '  OR ' || l_criteria_value1 || ' =  ' || ''''|| l_criteria_value2 ||''''
  into g_exec_string from psp_report_template_details_h ;


*/


     g_exec_string :=  l_sql_string || ' OR '|| l_criteria_value1 || ' = ' || '''' || l_criteria_value2||'''';


         l_sql_string:= g_exec_string;

   END LOOP;

        close ppg_cursor;


  if l_sql_string is not null then
      --- replaced non-performant delete stmnt for 4429787

 g_exec_string := 'delete from psp_selected_persons_t sel where request_id  = :request_id
     AND NOT EXISTS
  (SELECT 1 FROM per_assignments_f paf, pay_people_groups ppg, per_assignment_status_types past
           WHERE  paf.people_group_id= ppg.people_group_id
                          AND	paf.assignment_type = ''' || 'E' || '''
			  AND paf.effective_end_date >= :p_effort_Start AND
                            paf.effective_start_date <= :p_effort_end
            AND (' || l_sql_string || ')
            AND paf.person_id = sel.person_id
	    AND	paf.assignment_status_type_id =   past.assignment_status_type_id
	    AND (	past.per_system_status <> ''' || 'TERM_ASSIGN' || '''
			OR	EXISTS ( select null
					FROM	psp_pre_gen_dist_lines_history
					WHERE	distribution_date between :p_effort_start and :p_effort_end
					AND	assignment_id = paf.assignment_id
	 				AND     reversal_entry_flag IS NULL
					AND	rownum=1 )
				OR      EXISTS (SELECT null
					FROM   psp_distribution_lines_history pdlh
					, psp_summary_lines psl
					WHERE	pdlh.summary_line_id = psl.summary_line_id
					AND	distribution_date between :p_effort_start and :p_effort_end
					AND	psl.person_id = paf.person_id
					AND	psl.assignment_id =  paf.assignment_id
	 				AND     reversal_entry_flag IS NULL
					AND	rownum=1)))';


    --fnd_file.put_line(fnd_file.log , ' g_exec_string 3 is '||g_exec_string);

     EXECUTE IMMEDIATE g_exec_string USING IN  p_request_id, p_Effort_start, p_effort_end, p_Effort_start, p_effort_end, p_Effort_start, p_effort_end;
  end if;
  end if;

      elsif template_sel_criteria.array_sel_criteria(i)='GLA' then


      OPEN gla_cursor;

      FETCH GLA_CURSOR into l_criteria_value1, l_criteria_value2, l_criteria_value3;
      IF l_criteria_value1 is not null then

      l_sql_string := l_criteria_value1 ||' between '|| ''''|| l_criteria_value2 || ''''  || ' and ' || '''' || l_criteria_value3 || '''';
    --  g_exec_string := l_sql_string;


    LOOP

    FETCH GLA_CURSOR INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
     EXIT WHEN GLA_CURSOR%NOTFOUND;

              g_exec_string:= l_sql_string
             || '  OR ' || l_criteria_value1 || ' between ' || ''''|| l_criteria_value2 || '''' ||
              ' and ' || ''''|| l_criteria_value3 || ''''  ;
     l_sql_string:=g_exec_string;

   END LOOP;
         close gla_cursor;

      --   l_sql_string:= g_exec_string;

  if l_sql_string is not null then

       g_exec_string := 'delete from psp_selected_persons_t where person_id
       not in (select nvl(psl.person_id,0) from psp_summary_lines psl,
             psp_distribution_lines_history pdnh,
            psp_adjustment_lines_history palh, psp_pre_gen_dist_lines_history ppg,
          gl_code_combinations gcc
           where  gcc.code_combination_id= psl.gl_code_combination_id and
           psl.business_group_id = '|| p_business_group_id || ' and
           psl.set_of_books_id = ' || p_set_of_books_id || ' and
            psl.summary_line_id = pdnh.summary_line_id(+) and
            psl.summary_line_id = ppg.summary_line_id(+) and
            psl.summary_line_id = palh.summary_line_id(+) and
            psl.status_code='||''''||'A'||''''||' and
  ((psl.source_type in ('||''''||'N'||''''||' ,'|| ''''|| 'O'||''''||') and
     pdnh.distribution_date between :p_effort_start  and  :p_effort_end
 and pdnh.reversal_entry_flag is null
 and psl.summary_line_id = pdnh.summary_line_id
 and pdnh.adjustment_batch_name is null
)  OR
  ( psl.source_type='||''''||'P'||''''||' and
ppg.distribution_date between :p_effort_start  and :p_effort_end  and
ppg.adjustment_batch_name is null and
ppg.summary_line_id =psl.summary_line_id and
ppg.reversal_entry_flag is null)
    OR (psl.source_type='||''''||'A'||''''||' and
    palh.summary_line_id =psl.summary_line_id and
    palh.adjustment_batch_name is null and
     NVL(palh.original_line_flag, ' || ''''|| 'N' || ''''|| ') = '||''''|| 'N' || ''''
  || ' and palh.distribution_date between :p_effort_start  and :p_effort_end  )) and
             gcc.code_combination_id= psl.gl_code_combination_id and
            gcc.code_combination_id in (select code_combination_id from gl_code_combinations
            where ' || l_sql_string
       || ' )) and request_id  = :request_id';

    -- fnd_file.put_line(fnd_file.log , ' g_exec_string 3 is '||g_exec_string);

     execute immediate g_exec_string using IN p_effort_start, p_effort_end , p_effort_start, p_effort_end, p_effort_start, p_effort_end, p_request_id;

  end if;
  end if;


  end if;


 END IF;

  END IF;
 END LOOP;

    END;


 PROCEDURE APPLY_EXCLUSION_CRITERIA(P_REQUEST_ID IN NUMBER, P_EFFORT_START IN DATE , P_EFFORT_END IN DATE,  P_BUSINESS_GROUP_ID IN NUMBER, P_SET_OF_BOOKS_ID IN NUMBER)  IS

CURSOR PPG_CURSOR IS
      select criteria_value1, criteria_value2 from
      psp_report_template_details_h  where  request_id = p_request_id and
      criteria_lookup_type= 'PSP_SELECTION_CRITERIA' and criteria_lookup_code='PPG'
      and include_exclude_flag='E';


CURSOR GLA_CURSOR IS
      select criteria_value1 , criteria_value2, criteria_value3 from
      psp_report_template_details_h where request_id = p_request_id and
      criteria_lookup_type ='PSP_SELECTION_CRITERIA' and criteria_lookup_code ='GLA'
      and include_exclude_flag='E';


type t_varchar_30_type is TABLE Of VARCHAR2(30)  INDEX BY BINARY_INTEGER;
 type t_varchar_1_type is TABLE of VARCHAR2(1) INDEX BY BINARY_INTEGER;

l_criteria_value1 varchar2(30);

l_criteria_value2 varchar2(60);		-- Bug 8257434


l_criteria_value3  varchar2(30);

l_sql_string varchar2(1000);


i number;

    BEGIN
    for i in 1..template_sel_criteria.array_sel_criteria.count

  LOOP

  IF template_sel_criteria.array_inc_exc_flag(i) = 'E'  THEN


    --   IF  template_sel_criteria.array_sel_criteria(i) <>  g_lookup_code THEN

       IF template_sel_criteria.array_sel_criteria(i) = 'PTY'  THEN

		DELETE FROM psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN	(SELECT	ppf.person_id
					FROM	per_people_f ppf,
						psp_report_template_details_h prtd,
						per_assignments_f paf,
						per_assignment_status_types past
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='PTY'
				        AND	paf.person_id = ppf.person_id
				        AND	paf.assignment_type = 'E'
				        AND	paf.effective_start_date <= p_effort_end
				        AND	paf.effective_end_date >= p_effort_start
				        AND	ppf.effective_start_date <= p_effort_end
					AND	ppf.effective_end_date >= p_effort_start
					AND	include_exclude_flag='E'
					AND	ppf.person_type_id  = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id
					AND	paf.assignment_status_type_id =   past.assignment_status_type_id
					AND (		past.per_system_status <> 'TERM_ASSIGN'
						OR	EXISTS ( select null
							FROM	psp_pre_gen_dist_lines_history
							WHERE	distribution_date between p_effort_start and p_effort_end
							AND	assignment_id = paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1 )
						OR      EXISTS (SELECT null
							FROM   psp_distribution_lines_history pdlh
							, psp_summary_lines psl
							WHERE	pdlh.summary_line_id = psl.summary_line_id
							AND	distribution_date between p_effort_start and p_effort_end
							AND	psl.person_id = paf.person_id
							AND	psl.assignment_id =  paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1)));


       ELSIF template_sel_criteria.array_sel_criteria(i) = 'EMP' THEN

		DELETE FROM psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN	(SELECT	DISTINCT ppf.person_id
					FROM	per_all_people_f ppf,
						per_assignments_f paf,
						per_assignment_status_types past
					WHERE	ppf.person_id IN	(SELECT	TO_NUMBER(criteria_value1)
									FROM	psp_report_template_details_h prtd
									WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
									AND	criteria_lookup_code='EMP'
									AND	include_exclude_flag='E'
									AND	prtd.request_id = p_request_id)
					AND	paf.person_id = ppf.person_id
					AND	paf.assignment_type = 'E'
					AND	paf.effective_start_date <= p_effort_end
					AND	paf.effective_end_date >= p_effort_start
					AND	ppf.effective_start_date <= p_effort_end
					AND	ppf.effective_end_date >= p_effort_start
					AND	paf.assignment_status_type_id =   past.assignment_status_type_id
					AND (		past.per_system_status <> 'TERM_ASSIGN'
						OR	EXISTS ( select null
							FROM	psp_pre_gen_dist_lines_history
							WHERE	distribution_date between p_effort_start and p_effort_end
							AND	assignment_id = paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1 )
						OR      EXISTS (SELECT null
							FROM   psp_distribution_lines_history pdlh
							, psp_summary_lines psl
							WHERE	pdlh.summary_line_id = psl.summary_line_id
							AND	distribution_date between p_effort_start and p_effort_end
							AND	psl.person_id = paf.person_id
							AND	psl.assignment_id =  paf.assignment_id
			 				AND     reversal_entry_flag IS NULL
							AND	rownum=1)));


      ELSIF  template_sel_criteria.array_sel_criteria(i) ='SUP' THEN

		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id	 IN	(SELECT	NVL(person_id,0)
						FROM	per_all_assignments_f paf,
							psp_report_template_details_h prtd,
							per_assignment_status_types past
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='SUP'
						AND	include_exclude_flag='E'
						AND	paf.supervisor_id = TO_NUMBER(prtd.criteria_value1)
						AND	prtd.request_id = p_request_id
						AND     paf.assignment_type = 'E'
						AND	paf.effective_start_date <= p_effort_end
						AND	paf.effective_end_date >= p_effort_start
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
								, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));


      ELSIF  template_sel_criteria.array_sel_criteria(i) =  'AWD' THEN

--- replaced original query for performance issues -- 4429787
 delete from  psp_selected_persons_t where request_id = p_request_id AND person_id in (
             select psl.person_id
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      per_time_periods ptp
WHERE
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='AWD' AND
  prtd.include_exclude_flag='E' AND
  prtd.request_id =p_request_id AND
psl.award_id = TO_NUMBER(prtd.criteria_value1) AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL
      AND NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF  template_sel_criteria.array_sel_criteria(i)  =  'ATY' THEN

      --- replaced non-performant delete with this for 4429787
 DELETE FROM  psp_selected_persons_t WHERE request_id = p_request_id AND person_id IN (
SELECT  NVL(psl.person_id,0)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      gms_awards_all gaa ,
      per_time_periods ptp
WHERE psl.award_id = gaa.award_id AND
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='ATY' AND
  prtd.include_exclude_flag='E' AND
  prtd.request_id =p_request_id AND
  gaa.type=prtd.criteria_value1 AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
     NVL(palh.original_line_flag, 'N') ='N')));

      ELSIF  template_sel_criteria.array_sel_criteria(i)  ='PRT' THEN

      --- replaced non-performant delete with this for 4429787
             DELETE FROM  psp_selected_persons_t WHERE request_id = p_request_id AND person_id IN (
SELECT  NVL(psl.person_id,0)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      pa_projects_all ppa ,
      per_time_periods ptp
WHERE psl.project_id = ppa.project_id AND
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='PRT' AND
  prtd.include_exclude_flag='E' AND
  prtd.request_id =p_request_id AND
  ppa.project_type=prtd.criteria_value1 AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
     NVL(palh.original_line_flag, 'N') ='N')));

      elsif  template_sel_criteria.array_sel_criteria(i)  ='PRJ' THEN

      --- replaced non-performant insert with this for 4429787
             delete from  psp_selected_persons_t where request_id = p_request_id AND person_id in (
             select nvl( psl.person_id ,0)
 FROM psp_summary_lines psl,
      psp_report_template_details_h prtd ,
      per_time_periods ptp
WHERE
  prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA' AND
  prtd.criteria_lookup_code='PRJ' AND
  prtd.include_exclude_flag='E' AND
  prtd.request_id =p_request_id AND
psl.project_id = TO_NUMBER(prtd.criteria_value1) AND
  psl.business_group_id = p_business_group_id AND
  psl.set_of_books_id = p_set_of_books_id AND
  psl.status_code= 'A' AND
  ptp.time_period_id = psl.time_period_id AND
  (ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start) AND
( EXISTS (SELECT 1 FROM psp_distribution_lines_history pdnh
    WHERE pdnh.summary_line_id = psl.summary_line_id
      AND  pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND  pdnh.reversal_entry_flag IS   NULL
      AND  pdnh.adjustment_batch_name IS NULL )
 OR EXISTS
  (SELECT 1 FROM psp_pre_gen_dist_lines_history ppg
    WHERE ppg.summary_line_id = psl.summary_line_id
      AND ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND ppg.adjustment_batch_name IS   NULL AND
      ppg.reversal_entry_flag IS NULL)
OR EXISTS (SELECT 1 FROM psp_adjustment_lines_history palh
    WHERE palh.summary_line_id = psl.summary_line_id
      AND palh.distribution_date BETWEEN p_effort_start AND p_effort_end
      AND palh.adjustment_batch_name IS NULL
      AND palh.reversal_entry_flag IS NULL AND
NVL(palh.original_line_flag, 'N') ='N')));


      elsif  template_sel_criteria.array_sel_criteria(i)  ='PAY' THEN

      		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id	IN     (SELECT	person_id
						FROM	per_assignments_f paf,
							psp_report_template_details_h prtd,
							per_assignment_status_types past
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='PAY'
						AND	include_exclude_flag='E'
						AND     paf.assignment_type = 'E'
						AND	effective_start_date <= p_effort_end
						AND	effective_end_date >= p_effort_start
						AND	paf.payroll_id = TO_NUMBER(prtd.criteria_value1)
						AND	prtd.request_id = p_request_id
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
									, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));


      elsif  template_sel_criteria.array_sel_criteria(i) ='LOC' THEN

		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN		(SELECT	person_id
						FROM	per_assignments_f paf,
							psp_report_template_details_h prtd,
							per_assignment_status_types past
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='LOC'
						AND	include_exclude_flag='E'
						AND     paf.assignment_type = 'E'
						AND	effective_start_date <= p_effort_end
						AND	effective_end_date >= p_effort_start
						AND	paf.location_id = TO_NUMBER(prtd.criteria_value1)
						AND	prtd.request_id = p_request_id
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
									, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));


      elsif  template_sel_criteria.array_sel_criteria(i) ='ORG' THEN

      		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN		(SELECT	person_id
						FROM	per_assignments_f paf,
							psp_report_template_details_h prtd,
							per_assignment_status_types past
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='ORG'
						AND	include_exclude_flag='E'
			                        AND     paf.assignment_type = 'E'
						AND	effective_start_date <= p_effort_end
						AND	effective_end_date >= p_effort_start
						AND	paf.organization_id = TO_NUMBER(prtd.criteria_value1)
						AND	prtd.request_id = p_request_id
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
									, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));

/*

      elsif template_rec.array_sel_criteria(i)='CST' then
*/

      elsif  template_sel_criteria.array_sel_criteria(i)  = 'JOB' THEN

		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN		(SELECT	person_id
						FROM	per_assignments_f paf,
							psp_report_template_details_h prtd,
							per_assignment_status_types past
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='JOB'
						AND	include_exclude_flag='E'
						AND     paf.assignment_type = 'E'
						AND	effective_start_date <= p_effort_end
						AND	effective_end_date >= p_effort_start
						AND	paf.job_id = TO_NUMBER(prtd.criteria_value1)
						AND	prtd.request_id = p_request_id
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
									, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));


      elsif  template_sel_criteria.array_sel_criteria(i)  ='POS' THEN

		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN		(SELECT	person_id
						FROM	per_assignments_f paf,
							psp_report_template_details_h prtd,
							per_assignment_status_types past
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='POS'
						AND	include_exclude_flag='E'
	                                        AND     paf.assignment_type = 'E'
						AND	effective_start_date <= p_effort_end
						AND	effective_end_date >= p_effort_start
						AND	paf.position_id = TO_NUMBER(prtd.criteria_value1)
						AND	prtd.request_id = p_request_id
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
									, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));

      elsif  template_sel_criteria.array_sel_criteria(i)  ='ASS' THEN

		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN		(SELECT	person_id
						FROM	per_assignments_f paf,
							psp_report_template_details_h prtd,
							per_assignment_status_types past
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='ASS'
						AND	include_exclude_flag='E'
						AND     paf.assignment_type = 'E'
						AND	paf.assignment_status_type_id = TO_NUMBER(prtd.criteria_value1)
						AND	prtd.request_id = p_request_id
						AND	effective_start_date <= p_effort_end
						AND	effective_end_date >= p_effort_start
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
									, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));


      elsif template_sel_criteria.array_sel_criteria(i)='CST' THEN

		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN		(SELECT	NVL(person_id,0)
						FROM	per_assignments_f paf,
							pay_payrolls_f ppf,
							per_assignment_status_types past
						WHERE	ppf.payroll_id = paf.payroll_id
						AND	ppf.consolidation_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='CST'
							AND	include_exclude_flag='E'
							AND	request_id = p_request_id)
						AND     paf.assignment_type = 'E'
						AND	ppf.effective_start_date <= p_effort_end
						AND	ppf.effective_end_date >= p_effort_start
						AND	paf.effective_start_date <= p_effort_end
						AND	paf.effective_end_date >= p_effort_start
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
									, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));


       elsif template_sel_criteria.array_sel_criteria(i) = 'AST' THEN


		DELETE FROM	psp_selected_persons_t
		WHERE	request_id = p_request_id
		AND	person_id IN		(SELECT	NVL(paf.person_id,0)
						FROM	per_all_assignments_f paf,
							hr_assignment_sets has,
							hr_assignment_set_amendments hasa,
							per_assignment_status_types past
						WHERE	has.assignment_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='AST'
							AND	include_exclude_flag='E'
							AND	request_id =p_request_id)
						AND	(	(paf.payroll_id = has.payroll_id
							AND     paf.assignment_type = 'E'
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start
							AND	has.assignment_set_id = hasa.assignment_set_id)
							OR	(paf.assignment_id = hasa.assignment_id
							AND     paf.assignment_type = 'E'
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start
							AND	hasa.assignment_set_id=has.assignment_set_id
							AND	include_or_exclude ='I'))
						AND	NOT EXISTS	(SELECT	assignment_id
							FROM	hr_assignment_set_amendments hasa
							WHERE	hasa.assignment_id = paf.assignment_id
							AND     paf.assignment_type = 'E'
							AND	hasa.include_or_exclude ='E'
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start)
						AND	paf.assignment_status_type_id =   past.assignment_status_type_id
						AND (		past.per_system_status <> 'TERM_ASSIGN'
							OR	EXISTS ( select null
								FROM	psp_pre_gen_dist_lines_history
								WHERE	distribution_date between p_effort_start and p_effort_end
								AND	assignment_id = paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1 )
							OR      EXISTS (SELECT null
								FROM   psp_distribution_lines_history pdlh
								, psp_summary_lines psl
								WHERE	pdlh.summary_line_id = psl.summary_line_id
								AND	distribution_date between p_effort_start and p_effort_end
								AND	psl.person_id = paf.person_id
								AND	psl.assignment_id =  paf.assignment_id
				 				AND     reversal_entry_flag IS NULL
								AND	rownum=1)));






      elsif template_sel_criteria.array_sel_criteria(i)='PPG' THEN

            OPEN ppg_cursor;

            FETCH PPG_CURSOR into l_criteria_value1, l_criteria_value2;
            IF l_criteria_value1 is not null then

            l_sql_string := l_criteria_value1 ||' =  '||''''|| l_criteria_value2 || '''' ;
            --g_exec_string := l_sql_string;


            LOOP

            FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
            EXIT WHEN PPG_CURSOR%NOTFOUND;

     g_exec_string :=  l_sql_string || ' OR '|| l_criteria_value1 || ' = ' || '''' || l_criteria_value2||'''';
/*
            select l_sql_string
            || '  OR '  || l_criteria_value1 ||  ' =  ' || ''''|| l_criteria_value2 || ''''
            into g_exec_string from psp_report_template_details_h ;

*/
            l_sql_string:= g_exec_string;

            END LOOP;


            IF l_sql_string is not null then

            g_exec_string := 'delete from psp_selected_persons_t where person_id
            in (select person_id from per_assignments_f paf,
            pay_people_groups ppg , per_assignment_status_types past
           where  paf.people_group_id= ppg.people_group_id
                          AND	paf.assignment_type = ''' || 'E' || '''
			  and paf.effective_end_date >= :p_effort_Start and
                            paf.effective_start_date <= :p_effort_end
           and
           ppg.people_group_id in (select people_group_id from pay_people_groups
           where ' || l_sql_string
           || ' )
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> ''' || 'TERM_ASSIGN' || '''
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between :p_effort_start and :p_effort_end
				AND	assignment_id = paf.assignment_id
 				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
				, psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between :p_effort_start and :p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1))
	) and request_id  = :request_id';


           --fnd_file.put_line(fnd_file.log, 'ppg  check is '||g_exec_string);

            execute immediate g_exec_string using in   p_effort_start, p_effort_end, p_effort_start, p_effort_end, p_effort_start, p_effort_end, p_request_id;

             END IF;

       END IF;

      ELSIF template_sel_criteria.array_sel_criteria(i)='GLA' THEN

          OPEN gla_cursor;

          FETCH GLA_CURSOR into l_criteria_value1, l_criteria_value2, l_criteria_value3;
          IF l_criteria_value1 is not null then

          l_sql_string := l_criteria_value1 ||' between '|| '''' || l_criteria_value2 || '''' || ' and ' || '''' || l_criteria_value3 || '''' ;


          LOOP

            FETCH GLA_CURSOR INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
            EXIT WHEN GLA_CURSOR%NOTFOUND;

              g_exec_string:= l_sql_string
             || '  OR ' || l_criteria_value1 || ' between ' || ''''|| l_criteria_value2 || '''' ||
              ' and ' || ''''|| l_criteria_value3 || ''''  ;

           l_sql_string:= g_exec_string;

           END LOOP;


          IF l_sql_string is not null then

       g_exec_string := 'delete from psp_selected_persons_t where person_id
        in (select nvl(psl.person_id,0) from psp_summary_lines psl,
             psp_distribution_lines_history pdnh,
            psp_adjustment_lines_history palh, psp_pre_gen_dist_lines_history ppg,
          gl_code_combinations gcc
           where  gcc.code_combination_id= psl.gl_code_combination_id and
           psl.business_group_id = '|| p_business_group_id || ' and
           psl.set_of_books_id = ' || p_set_of_books_id || ' and
            psl.summary_line_id = pdnh.summary_line_id(+) and
            psl.summary_line_id = ppg.summary_line_id(+) and
            psl.summary_line_id = palh.summary_line_id(+) and
            psl.status_code='||''''||'A'||''''||' and
  ((psl.source_type in ('||''''||'N'||''''||' ,'|| ''''|| 'O'||''''||') and
     pdnh.distribution_date between :p_effort_start  and  :p_effort_end
 and pdnh.reversal_entry_flag is null
and psl.summary_line_id =pdnh.summary_line_id
 and pdnh.adjustment_batch_name is null
)  OR
  ( psl.source_type= '||''''||'P'||''''||' and
ppg.distribution_date between :p_effort_start  and  :p_effort_end  and
ppg.adjustment_batch_name is null and
ppg.summary_line_id =psl.summary_line_id and
ppg.reversal_entry_flag is null)
    OR (psl.source_type= '||''''||'A'||''''||' and
   palh.summary_line_id =psl.summary_line_id and
   palh.adjustment_batch_name is null and
    NVL(palh.original_line_flag, ' || ''''|| 'N' || ''''|| ') = '||''''|| 'N' || ''''
  || ' and  palh.distribution_date between :p_effort_start  and  :p_effort_end )) and
             gcc.code_combination_id= psl.gl_code_combination_id and
            gcc.code_combination_id in (select code_combination_id from gl_code_combinations
            where ' || l_sql_string
       || ' )) and request_id  = :request_id';


     --fnd_file.put_line(fnd_file.log,'g_exec_string ===='||g_exec_string);

           EXECUTE IMMEDIATE g_exec_string using IN p_effort_start, p_effort_end, p_effort_start, p_effort_end, p_effort_start, p_effort_end, p_request_id;

          END IF;

       END IF;


      END IF;


  --  END IF;

    END IF;


  END LOOP;

END;


PROCEDURE APPLY_FF_FORMULA_EXCLUSION(p_request_id IN NUMBER, p_effort_start IN DATE, p_effort_end IN DATE) IS

   TYPE v_line_id	IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
   TYPE v_date_id	IS TABLE OF DATE INDEX BY BINARY_INTEGER;

   TYPE ls_criteria_rec is RECORD(
   l_person_id v_line_id,
   l_assignment_id v_line_id,
   l_request_id v_line_id ,
   l_start_date  v_date_id,
   l_end_date     v_date_id
   );

   r_ls_criteria_rec ls_criteria_rec;


   TYPE ff_rec is RECORD(
   l_formula_id v_line_id
    );

   r_ff_rec ff_rec;

l_input1  number;
l_input2 number ;
l_input3 number;
l_input4 number;
l_results varchar2(30) ;
l_inputs ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;
l_in_cnt  number;
l_out_cnt number;
i number;
j number;
k number;
tot_cnt number;
local_ctr number:=0;
 l_cnt number:=0;

 CURSOR select_everyone_csr is select person_id , assignment_id, p_request_id, p_effort_start, p_effort_end from psp_selected_persons_t where
 request_id =p_request_id;

CURSOR get_ff_for_template_csr is select criteria_value1 from psp_report_template_details_h where
request_id = p_request_id and criteria_lookup_type='PSP_SELECTION_CRITERIA' and criteria_lookup_code='FFE';

BEGIN

OPEN select_everyone_csr;

  Fetch select_everyone_csr BULK COLLECT into
  r_ls_criteria_rec.l_person_id , r_ls_criteria_rec.l_assignment_id, r_ls_criteria_rec.l_request_id, r_ls_criteria_rec.l_start_date, r_ls_criteria_rec.l_end_date;

CLOSE select_everyone_csr;


OPEN get_ff_for_template_csr;
 /*

 select nvl(count(1), 0)  into l_cnt from fnd_sessions where session_id = userenv('session_id');

 if l_cnt=0 then

    INSERT into fnd_sessions(session_id, effective_date) values (userenv('sessionid'), p_effort_start);
 end if;
*/



FETCH get_ff_for_template_csr BULK COLLECT into r_ff_rec.l_formula_id;

CLOSE get_ff_for_template_csr;

    FOR j in 1..r_ff_rec.l_formula_id.count

LOOP

       ff_exec.init_formula(r_ff_rec.l_formula_id(j), p_effort_start, l_inputs,l_outputs);
       tot_cnt := r_ls_criteria_rec.l_person_id.count;

   FOR k IN 1..tot_cnt LOOP

   FOR l_in_cnt in l_inputs.first..l_inputs.last loop

     IF (l_inputs(l_in_cnt).name ='PERSON_ID') THEN
            l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(r_ls_criteria_rec.l_person_id(k));
          hr_utility.trace('Input 1 :PERSON_ID=' ||l_inputs(l_in_cnt).value);


     ELSIF l_inputs(l_in_cnt).name='REQUEST_ID' THEN
            l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(r_ls_criteria_rec.l_request_id(k));

            hr_utility.trace( ' Input 2 :REQUEST_ID  =  '||l_inputs(l_in_cnt).value);

      ELSIF l_inputs(l_in_cnt).name='START_DATE' THEN
            l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(r_ls_criteria_rec.l_start_date(k));
            hr_utility.trace( ' Input 3 :START_DATE =  '||l_inputs(l_in_cnt).value);

      ELSIF l_inputs(l_in_cnt).name='END_DATE' THEN
            l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(r_ls_criteria_rec.l_end_date(k));
            hr_utility.trace( ' Input 4 :END_DATE= '||l_inputs(l_in_cnt).value);

      ELSIF l_inputs(l_in_cnt).name ='ASSIGNMENT_ID'  THEN
            l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(r_ls_criteria_rec.l_assignment_id(k));
            hr_utility.trace('Input 5 :ASSIGNMENT_ID=' ||l_inputs(l_in_cnt).value);

      /*
   Commented out the below change as input 1 is person_id and addl. input is not required

Added for bug 4195678 by tbalacha

      ELSIF  l_inputs(l_in_cnt).name='PERSON_ID'   THEN

           l_inputs(l_in_cnt).value := fnd_number.number_to_canonical(r_ls_criteria_rec.l_person_id(k));
      else
        l_inputs(l_in_cnt).value :=fnd_number.number_to_canonical(l_input2);

*/
     END IF;

 END LOOP;

  ff_exec.run_formula(l_inputs, l_outputs);

  FOR l_out_cnt in  l_outputs.first..l_outputs.last

     LOOP

       l_results:= l_outputs(l_out_cnt).value;


       IF  (l_results='FALSE' or l_results = 0 )THEN  -- introduced for bug  4195678
		DELETE FROM psp_selected_persons_t
	        WHERE  person_id = r_ls_criteria_rec.l_person_id(k)
		AND    assignment_id =  r_ls_criteria_rec.l_assignment_id(k);

        END IF;

    END LOOP;

END LOOP;

END LOOP;

END;

FUNCTION get_parameter_value( name in varchar2, parameter_list varchar2) return varchar2
IS


start_ptr NUMBER;
end_ptr NUMBER;
token_val pay_payroll_actions.legislative_parameters%type;
par_value pay_payroll_actions.legislative_parameters%type;

    BEGIN

         token_val := name||'=';
         start_ptr := instr(parameter_list, token_val) +length(token_val);

         end_ptr :=instr(parameter_list, ' ', start_ptr);

          IF end_ptr=0 then
             end_ptr:=length(parameter_list) +1;

          END IF;

          IF instr(parameter_list, token_val) = 0 then

             par_value:=NULL;
         ELSE

            par_value:=substr(parameter_list, start_ptr, end_ptr-start_ptr);


         end if;

      return par_value;
END get_parameter_value;

PROCEDURE get_asg_lowest_cardinality	(p_request_id		IN	NUMBER,
					p_effort_start		IN	DATE,
					p_effort_end		IN	DATE,
					p_business_group_id	IN	NUMBER,
					p_set_of_books_id	IN	NUMBER) IS
l_criteria_value1	VARCHAR2(30);
l_criteria_value2	VARCHAR2(60); -- Bug 8257434
l_criteria_value3	VARCHAR2(30);
l_dyn_criteria		VARCHAR2(30);
l_atleast_one_criteria	VARCHAR2(1);
l_sql_string		VARCHAR2(1000);

CURSOR get_lowest_cardinality_csr IS
SELECT	lookup_code  FROM
   psp_selection_cardinality_gt  WHERE	total_count > 0 ORDER BY total_count asc;


CURSOR	get_zero_cardinality_csr IS
SELECT	lookup_code
FROM	psp_selection_cardinality_gt
WHERE	total_count=0;


CURSOR	get_selection_cardinality_csr(p_request_id IN NUMBER) IS
SELECT	DISTINCT criteria_lookup_code
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	include_exclude_flag = 'I'
AND	criteria_lookup_type = 'PSP_SELECTION_CRITERIA';

/* The below cursors would only be used only when no statis selection criteria have been chosen */
CURSOR	ppg_cursor IS
SELECT	criteria_value1,
	criteria_value2
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	include_exclude_flag='I'
AND	criteria_lookup_type= 'PSP_SELECTION_CRITERIA'
AND	criteria_lookup_code='PPG';

CURSOR	gla_cursor IS
SELECT	criteria_value1,
	criteria_value2,
	criteria_value3
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	include_exclude_flag='I'
AND	criteria_lookup_type ='PSP_SELECTION_CRITERIA'
AND	criteria_lookup_code ='GLA';

BEGIN
	OPEN get_selection_cardinality_csr(p_request_id);
	FETCH get_selection_cardinality_csr BULK COLLECT into template_rec.array_sel_criteria;
	CLOSE get_selection_cardinality_csr;

	FOR i IN 1.. template_rec.array_sel_criteria.COUNT
	LOOP
		IF template_rec.array_sel_criteria(i) = 'PTY'  THEN
			INSERT INTO psp_selection_cardinality_gt(lookup_code, total_count)
			SELECT	'PTY', COUNT(DISTINCT assignment_id)
			FROM	per_people_f ppf,
				per_assignments_f paf
			WHERE	person_type_id IN	(SELECT	 TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code ='PTY'
							AND	include_exclude_flag='I'
							AND	request_id = p_request_id)
			AND	paf.person_id = ppf.person_id
			AND	paf.assignment_type = 'E'
			AND	ppf.effective_start_date <= p_effort_end
			AND	ppf.effective_end_date >= p_effort_start
			AND	paf.effective_start_date <= p_effort_end
			AND	paf.effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i) ='EMP' THEN
			INSERT INTO psp_selection_cardinality_gt (lookup_code, total_count)
			SELECT 'EMP', COUNT(DISTINCT paf.assignment_id)
			FROM	per_all_assignments_f paf
			WHERE	paf.person_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='EMP'
							AND	include_exclude_flag='I'
							AND	request_id = p_request_id)
			AND	paf.assignment_type = 'E'
			AND	paf.effective_start_date <= p_effort_end
			AND	paf.effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i) ='SUP' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'SUP',		COUNT(DISTINCT assignment_id)
			FROM	per_all_assignments_f paf
			WHERE	supervisor_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='SUP'
							AND	request_id = p_request_id
							AND	include_exclude_flag='I')
			AND     paf.assignment_type = 'E'
			AND	effective_start_date <= p_effort_end
			AND	effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i) ='AWD' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	 'AWD',		COUNT(DISTINCT psl.assignment_id)
			FROM	psp_summary_lines psl,
				psp_report_template_details_h prtd ,
				per_time_periods ptp
			WHERE
				prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
			AND	prtd.criteria_lookup_code='AWD'
			AND	prtd.include_exclude_flag='I'
			AND	prtd.request_id =p_request_id
                        and     psl.award_id = TO_NUMBER(prtd.criteria_value1)
			AND	psl.business_group_id = p_business_group_id
			AND	psl.set_of_books_id = p_set_of_books_id
			AND	psl.status_code= 'A'
			AND	ptp.time_period_id = psl.time_period_id
			AND	(ptp.start_date <= p_effort_end
			AND	ptp.end_date >= p_effort_start)
			AND	(EXISTS		(SELECT	1
						FROM	psp_distribution_lines_history pdnh
						WHERE	pdnh.summary_line_id = psl.summary_line_id
						AND	 pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	 pdnh.reversal_entry_flag IS NULL
						AND	 pdnh.adjustment_batch_name IS NULL )
				OR EXISTS	(SELECT	1
						FROM	psp_pre_gen_dist_lines_history ppg
						WHERE	ppg.summary_line_id = psl.summary_line_id
						AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	ppg.adjustment_batch_name IS   NULL
						AND	ppg.reversal_entry_flag IS NULL)
				OR EXISTS	(SELECT	1
						FROM	psp_adjustment_lines_history palh
						WHERE	palh.summary_line_id = psl.summary_line_id
						AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	palh.adjustment_batch_name IS NULL
						AND	palh.reversal_entry_flag IS NULL
						AND	NVL(palh.original_line_flag, 'N') ='N'));
		ELSIF template_rec.array_sel_criteria(i)='ATY' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	 'ATY',		COUNT(DISTINCT psl.assignment_id)
			FROM	psp_summary_lines psl,
				psp_report_template_details_h prtd ,
				gms_awards_all gaa,
				per_time_periods ptp
			WHERE	psl.award_id = gaa.award_id
			AND	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
			AND	prtd.criteria_lookup_code='ATY'
			AND	prtd.include_exclude_flag='I'
			AND	prtd.request_id = p_request_id
			AND	gaa.type=prtd.criteria_value1
			AND	psl.business_group_id = p_business_group_id
			AND	psl.set_of_books_id = p_set_of_books_id
			AND	psl.status_code= 'A'
			AND	ptp.time_period_id = psl.time_period_id
			AND	(ptp.start_date <= p_effort_end
			AND	ptp.end_date >= p_effort_start)
			AND	(EXISTS		(SELECT	1
						FROM	psp_distribution_lines_history pdnh
						WHERE	pdnh.summary_line_id = psl.summary_line_id
						AND	 pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	 pdnh.reversal_entry_flag IS   NULL
						AND	 pdnh.adjustment_batch_name IS NULL )
				OR EXISTS	(SELECT	1
						FROM	psp_pre_gen_dist_lines_history ppg
						WHERE	ppg.summary_line_id = psl.summary_line_id
						AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	ppg.adjustment_batch_name IS NULL
						AND	ppg.reversal_entry_flag IS NULL)
				OR EXISTS	(SELECT	1
						FROM	psp_adjustment_lines_history palh
						WHERE	palh.summary_line_id = psl.summary_line_id
						AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	palh.adjustment_batch_name IS NULL
						AND	palh.reversal_entry_flag IS NULL
						AND	NVL(palh.original_line_flag, 'N') ='N'));
		ELSIF template_rec.array_sel_criteria(i)='PRT' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'PRT',		COUNT(DISTINCT psl.assignment_id)
			FROM	psp_summary_lines psl,
				psp_report_template_details_h prtd ,
				pa_projects_all ppa ,
				per_time_periods ptp
			WHERE	psl.project_id = ppa.project_id
			AND	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
			AND	prtd.criteria_lookup_code='PRT'
			AND	prtd.include_exclude_flag='I'
			AND	prtd.request_id =p_request_id
			AND	ppa.project_type=prtd.criteria_value1
			AND	psl.business_group_id = p_business_group_id
			AND	psl.set_of_books_id = p_set_of_books_id
			AND	psl.status_code= 'A'
			AND	ptp.time_period_id = psl.time_period_id
			AND	(ptp.start_date <= p_effort_end
			AND	ptp.end_date >= p_effort_start)
			AND	(EXISTS		(SELECT	1
						FROM	psp_distribution_lines_history pdnh
						WHERE	pdnh.summary_line_id = psl.summary_line_id
						AND	 pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	 pdnh.reversal_entry_flag IS NULL
						AND	 pdnh.adjustment_batch_name IS NULL )
				OR EXISTS	(SELECT	1
						FROM	psp_pre_gen_dist_lines_history ppg
						WHERE	ppg.summary_line_id = psl.summary_line_id
						AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	ppg.adjustment_batch_name IS NULL AND
						ppg.reversal_entry_flag IS NULL)
				OR EXISTS	(SELECT	1
						FROM	psp_adjustment_lines_history palh
						WHERE	palh.summary_line_id = psl.summary_line_id
						AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	palh.adjustment_batch_name IS NULL
						AND	palh.reversal_entry_flag IS NULL AND
						NVL(palh.original_line_flag, 'N') ='N'));
		ELSIF template_rec.array_sel_criteria(i)='PRJ' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	 'PRJ',		COUNT(DISTINCT psl.assignment_id)
			FROM	psp_summary_lines psl,
				psp_report_template_details_h prtd ,
				per_time_periods ptp
			WHERE
				prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
			AND	prtd.criteria_lookup_code='PRJ'
			AND	prtd.include_exclude_flag='I'
			AND	prtd.request_id =p_request_id
                        and     psl.project_id = TO_NUMBER(prtd.criteria_value1)
			AND	psl.business_group_id = p_business_group_id
			AND	psl.set_of_books_id = p_set_of_books_id
			AND	psl.status_code= 'A'
			AND	ptp.time_period_id = psl.time_period_id
			AND	(ptp.start_date <= p_effort_end
			AND	ptp.end_date >= p_effort_start)
			AND	(EXISTS		(SELECT	1 FROM	psp_distribution_lines_history pdnh
						WHERE	pdnh.summary_line_id = psl.summary_line_id
						AND	 pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	 pdnh.reversal_entry_flag IS   NULL
						AND	 pdnh.adjustment_batch_name IS NULL )
				OR EXISTS	(SELECT	1 FROM	psp_pre_gen_dist_lines_history ppg
						WHERE	ppg.summary_line_id = psl.summary_line_id
						AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	ppg.adjustment_batch_name IS   NULL
						AND	ppg.reversal_entry_flag IS NULL)
				OR EXISTS	(SELECT	1 FROM	psp_adjustment_lines_history palh
						WHERE	palh.summary_line_id = psl.summary_line_id
						AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
						AND	palh.adjustment_batch_name IS NULL
						AND	palh.reversal_entry_flag IS NULL
						AND	NVL(palh.original_line_flag, 'N') ='N'));
		ELSIF template_rec.array_sel_criteria(i)='PAY' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'PAY',		COUNT(DISTINCT assignment_id)
			FROM	per_assignments_f paf
			WHERE	payroll_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='PAY'
						AND	include_exclude_flag='I' AND	request_id = p_request_id)
			AND     paf.assignment_type = 'E'
			AND	effective_start_date <= p_effort_end
			AND	effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i)='LOC' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'LOC',		COUNT(DISTINCT assignment_id)
			FROM	per_assignments_f paf
			WHERE	location_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='LOC'
						AND	include_exclude_flag='I'
						AND	request_id = p_request_id)
			AND     paf.assignment_type = 'E'
			AND	effective_start_date <= p_effort_end
			AND	effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i)='ORG' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'ORG',		COUNT(DISTINCT assignment_id)
			FROM	per_assignments_f paf
			WHERE	organization_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	 psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='ORG'
							AND	include_exclude_flag='I'
							AND	request_id = p_request_id)
			AND     paf.assignment_type = 'E'
			AND	effective_start_date  <= p_effort_end
			AND	effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i)='JOB' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'JOB',		COUNT(DISTINCT assignment_id)
			FROM	per_assignments_f paf
			WHERE	job_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='JOB'
						AND	include_exclude_flag='I'
						AND	request_id=p_request_id)
			AND     paf.assignment_type = 'E'
			AND	effective_start_date <= p_effort_end
			AND	effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i)='POS' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'POS',		COUNT(DISTINCT assignment_id)
			FROM	per_assignments_f paf
			WHERE	position_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='POS'
						AND	include_exclude_flag='I'
						AND	request_id = p_request_id)
			AND     paf.assignment_type = 'E'
			AND	effective_start_date <= p_effort_end
			AND	effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i)='ASS' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'ASS',		COUNT(DISTINCT assignment_id)
			FROM	per_assignments_f paf
			WHERE	assignment_status_type_id IN	(SELECT	TO_NUMBER(criteria_value1)
								FROM	psp_report_template_details_h prtd
								WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
								AND	criteria_lookup_code='ASS'
								AND	include_exclude_flag='I'
								AND	request_id = p_request_id)
			AND     paf.assignment_type = 'E'
			AND	effective_start_date <= p_effort_end
			AND	effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i)='CST' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'CST',		COUNT(DISTINCT paf.assignment_id)
			FROM	per_assignments_f paf,
				pay_payrolls_f ppf
			WHERE	ppf.payroll_id = paf.payroll_id
			AND	ppf.consolidation_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
								FROM	psp_report_template_details_h prtd
								WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
								AND	criteria_lookup_code='CST'
								AND	include_exclude_flag='I'
								AND	request_id = p_request_id)
			AND     paf.assignment_type = 'E'
			AND	ppf.effective_start_date <=  p_effort_end
			AND	ppf.effective_end_date >= p_effort_start
			AND	paf.effective_start_date <= p_effort_end
			AND	paf.effective_end_date >= p_effort_start;
		ELSIF template_rec.array_sel_criteria(i) = 'AST' THEN
			INSERT INTO psp_selection_cardinality_gt
				(lookup_code,	total_count)
			SELECT	'AST',		COUNT(DISTINCT paf.assignment_id)
			FROM	per_all_assignments_f paf,
				hr_assignment_sets has ,
				hr_assignment_set_amendments hasa
			WHERE	has.assignment_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
								FROM	psp_report_template_details_h prtd
								WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
								AND	criteria_lookup_code='AST'
								AND	include_exclude_flag='I'
								AND	request_id =p_request_id)
			AND	(	(paf.payroll_id = has.payroll_id
					AND     paf.assignment_type = 'E'
					AND	paf.effective_start_date <= p_effort_end
					AND	paf.effective_end_date >= p_effort_start
					AND	has.assignment_set_id = hasa.assignment_set_id)
				OR	(paf.assignment_id = hasa.assignment_id
					AND     paf.assignment_type = 'E'
					AND	paf.effective_start_date <= p_effort_end
					AND	paf.effective_end_date >= p_effort_start
					AND	hasa.assignment_set_id=has.assignment_set_id
					AND	include_or_exclude ='I'))
			AND	NOT EXISTS	(SELECT	assignment_id
						FROM	hr_assignment_set_amendments hasa
						WHERE	hasa.assignment_id = paf.assignment_id
						AND	hasa.include_or_exclude ='E'
						AND     paf.assignment_type = 'E'
						AND	paf.effective_start_date <= p_effort_end
						AND	paf.effective_end_date >= p_effort_start);
		ELSIF template_rec.array_sel_criteria(i)='PPG' THEN
			l_dyn_criteria:='PPG';
		ELSIF template_rec.array_sel_criteria(i)='GLA' THEN
			l_dyn_criteria:='GLA';
		END IF;
	END LOOP;

--	Next find the selection criteria with lowest cardinality. Use it to prepare the initial list.

	OPEN get_lowest_cardinality_csr;
	FETCH get_lowest_cardinality_csr into g_lookup_code;
	CLOSE get_lowest_cardinality_csr;

	IF g_lookup_code is not null then
		l_atleast_one_criteria:='Y';
		hr_utility.trace( 'g_lookup_code -> '||g_lookup_code );
	ELSE
		OPEN get_zero_cardinality_csr;
		FETCH get_zero_cardinality_csr into g_lookup_code;
		CLOSE get_zero_cardinality_csr;

		hr_utility.trace( ' Inside zero cardinality => g_lookup_code=  '||g_lookup_code );

		IF g_lookup_code is not null then
			l_atleast_one_criteria:='Y';
		END IF;
	END IF;

	IF g_lookup_code IS NULL then
	BEGIN
--		When no static selection criteria have been chosen, then invoke the dynamic selection criteria
		hr_utility.trace( ' Inside zero cardinality => g_lookup_code IS NULL');

		IF l_dyn_criteria  ='PPG' then
			l_atleast_one_criteria:='Y';

			OPEN ppg_cursor;
			FETCH PPG_CURSOR into l_criteria_value1, l_criteria_value2;
			IF l_criteria_value1 is not null then
				l_sql_string := l_criteria_value1 ||' = '||''''|| l_criteria_value2 ||''''  ;
				LOOP
					FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
					EXIT WHEN PPG_CURSOR%NOTFOUND;

					g_exec_string:= l_sql_string|| ' OR '||l_criteria_value1 ||' = '||'''' ||
							l_criteria_value2|| '''';
					l_sql_string:=g_exec_string;
				END LOOP;
				CLOSE ppg_cursor;

				IF l_sql_string IS NOT NULL THEN
					g_exec_string := 'INSERT INTO psp_selection_cardinality_gt(lookup_code, total_count)
					SELECT	'||  '''' || 'PPG' || ''''||' , COUNT(person_id)
					FROM	per_assignments_f paf,
						pay_people_groups ppg
					WHERE	 paf.people_group_id= ppg.people_group_id
					AND	paf.assignment_type = ''' || 'E' || '''
					AND	paf.effective_end_date >= :p_effort_start
					AND	paf.effective_start_date <= :p_effort_end
					AND	ppg.people_group_id IN	(SELECT	people_group_id
									FROM	pay_people_groups
									WHERE	' || l_sql_string || ')';

					hr_utility.trace( ' g_exec_string = '||g_exec_string );

					EXECUTE IMMEDIATE g_exec_string USING IN p_effort_Start, p_effort_end;
					g_lookup_code := 'PPG';
				END IF;
			END IF;
		ELSIF  l_dyn_criteria ='GLA' then
			l_atleast_one_criteria:='Y';

			OPEN gla_cursor;
			FETCH GLA_CURSOR into l_criteria_value1, l_criteria_value2, l_criteria_value3;
			IF l_criteria_value1 is not null then
				l_sql_string := l_criteria_value1 ||' between '|| '''' || l_criteria_value2 || '''' ||
						' AND	' || ''''||l_criteria_value3||'''' ;
				LOOP
					FETCH GLA_CURSOR INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
					EXIT WHEN GLA_CURSOR%NOTFOUND;

					g_exec_string:= l_sql_string || '  OR ' || l_criteria_value1 || ' between ' ||
							''''|| l_criteria_value2 || '''' ||
							' AND	' || ''''|| l_criteria_value3 || ''''  ;
					l_sql_string:=g_exec_string;
				END LOOP;
				CLOSE gla_cursor;

				IF l_sql_string IS NOT NULL THEN
					g_exec_string := 'INSERT INTO psp_selection_cardinality_gt(lookup_code, total_count)
						SELECT	'|| '''' || 'GLA' || ''''|| ' , COUNT( DISTINCT psl.assignment_id)
						FROM	psp_summary_lines psl,
							psp_distribution_lines_history pdnh,
							psp_pre_gen_dist_lines_history ppg,
							psp_adjustment_lines_history palh,
							gl_code_combinations gcc
						WHERE	psl.business_group_id = '|| p_business_group_id || '
						AND	psl.set_of_books_id =' || p_set_of_books_id || '
						AND	gcc.code_combination_id= psl.gl_code_combination_id
						AND	psl.summary_line_id = pdnh.summary_line_id(+)
						AND	psl.summary_line_id = ppg.summary_line_id(+)
						AND	psl.summary_line_id = palh.summary_line_id(+)
						AND	psl.status_code='||''''||'A'||''''||'
						AND	(	(psl.source_type IN ('||''''||'N'||''''||' ,'|| ''''|| 'O'||''''||')
						AND		pdnh.distribution_date between :p_effort_start AND :p_effort_end
						AND		pdnh.summary_line_id = psl.summary_line_id
						AND		pdnh.reversal_entry_flag IS NULL
						AND		pdnh.adjustment_batch_name IS NULL)
							OR	(psl.source_type='||''''||'P'||''''||'
								AND	ppg.distribution_date BETWEEN :p_effort_start
									AND	:p_effort_end
								AND	ppg.summary_line_id = psl.summary_line_id
								AND	ppg.adjustment_batch_name IS NULL
								AND	ppg.reversal_entry_flag IS NULL)
							OR	(psl.source_type='||''''||'A'||''''||'
								AND	palh.summary_line_id = psl.summary_line_id
								AND	palh.reversal_entry_flag IS NULL
								AND	palh.adjustment_batch_name IS NULL
								AND	NVL(palh.original_line_flag, ' || ''''|| 'N' || ''''||
									') = '||''''|| 'N' || '''' || '
								AND	palh.distribution_date BETWEEN :p_effort_start
									AND :p_effort_end ))
						AND	gcc.code_combination_id= psl.gl_code_combination_id
						AND	gcc.code_combination_id IN (SELECT	code_combination_id
										FROM	gl_code_combinations
										WHERE	' || l_sql_string || ')';

					hr_utility.trace( ' g_exec_string =   '||g_exec_string );
					EXECUTE IMMEDIATE g_exec_string USING IN p_effort_start, p_effort_end,
						p_effort_start, p_effort_end ,p_effort_start, p_effort_end;
					g_lookup_code :='GLA';
				END IF;
			END IF;
		END IF;
	END;
	END IF;

	IF NVL(l_atleast_one_criteria, 'N')='N' then
		g_lookup_code:='ALL' ;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		fnd_file.put_line(fnd_file.log,  ' EXCEPTION '||sqlerrm);
END get_asg_lowest_cardinality;

PROCEDURE prepare_initial_asg_list	(p_request_id		IN	NUMBER,
					p_effort_start		IN	DATE,
					p_effort_end		IN	DATE,
					p_business_group_id	IN	NUMBER,
					p_set_of_books_id	IN	NUMBER) IS
PRAGMA	AUTONOMOUS_TRANSACTION;
CURSOR	PPG_CURSOR IS
SELECT	criteria_value1, criteria_value2
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	criteria_lookup_type= 'PSP_SELECTION_CRITERIA' AND	criteria_lookup_code='PPG'
AND	include_exclude_flag='I';


CURSOR	GLA_CURSOR IS
SELECT	criteria_value1 , criteria_value2, criteria_value3
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	criteria_lookup_type ='PSP_SELECTION_CRITERIA' AND	criteria_lookup_code ='GLA'
AND	include_exclude_flag='I';

l_criteria_value1	VARCHAR2(30);
l_criteria_value2	VARCHAR2(60);		-- Bug 8257434
l_criteria_value3	VARCHAR2(30);
l_sql_string		VARCHAR2(1000);

l_cnt			NUMBER;
BEGIN
	IF g_lookup_code = 'PTY' THEN

		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id, paf.person_id, paf.assignment_id
		FROM	per_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	person_type_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='PTY'
						AND	request_id = p_request_id
						AND	include_exclude_flag='I')
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));


	ELSIF g_lookup_code ='EMP' THEN
		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_people_f ppf,
			per_assignments_f paf,
			per_assignment_status_types past
		WHERE	ppf.person_id IN	(SELECT TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='EMP'
						AND	include_exclude_flag='I'
						AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.person_id = ppf.person_id
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));


	ELSIF g_lookup_code ='SUP' THEN
		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_all_assignments_f paf,
			per_assignment_status_types past
		WHERE	supervisor_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='SUP'
						AND	include_exclude_flag='I'
						AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code='AWD' THEN
		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id, psl.person_id, psl.assignment_id
		FROM	psp_summary_lines psl,
			psp_report_template_details_h prtd,
			per_time_periods ptp
		WHERE
		 	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
		AND	prtd.criteria_lookup_code='AWD'
		AND	prtd.include_exclude_flag='I'
		AND	prtd.request_id =p_request_id
                and psl.award_id = TO_NUMBER(prtd.criteria_value1)
		AND	psl.business_group_id = p_business_group_id
		AND	psl.set_of_books_id = p_set_of_books_id
		AND	psl.status_code= 'A'
		AND	ptp.time_period_id = psl.time_period_id
		AND	(ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start)
		AND	(	EXISTS	(SELECT	1
					FROM	psp_distribution_lines_history pdnh
					WHERE	pdnh.summary_line_id = psl.summary_line_id
					AND	pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	pdnh.reversal_entry_flag IS	NULL
					AND	pdnh.adjustment_batch_name IS NULL )
			OR	EXISTS	(SELECT	1
					FROM	psp_pre_gen_dist_lines_history ppg
					WHERE	ppg.summary_line_id = psl.summary_line_id
					AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	ppg.adjustment_batch_name IS	NULL
					AND	ppg.reversal_entry_flag IS NULL)
			OR	EXISTS	(SELECT	1
					FROM	psp_adjustment_lines_history palh
					WHERE	palh.summary_line_id = psl.summary_line_id
					AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	palh.adjustment_batch_name IS NULL
					AND	palh.reversal_entry_flag IS NULL
					AND	NVL(palh.original_line_flag, 'N') ='N'));
	ELSIF g_lookup_code ='ATY' THEN
		INSERT INTO psp_selected_persons_t (request_id , person_id, assignment_id)
		SELECT	DISTINCT p_request_id, psl.person_id, psl.assignment_id
		FROM	psp_summary_lines psl,
			psp_report_template_details_h prtd,
			gms_awards_all gaa,
			per_time_periods ptp
		WHERE	psl.award_id = gaa.award_id
		AND	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
		AND	prtd.criteria_lookup_code='ATY'
		AND	prtd.include_exclude_flag='I'
		AND	prtd.request_id =p_request_id
		AND	gaa.type=prtd.criteria_value1
		AND	psl.business_group_id = p_business_group_id
		AND	psl.set_of_books_id = p_set_of_books_id
		AND	psl.status_code= 'A'
		AND	ptp.time_period_id = psl.time_period_id
		AND	(ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start)
		AND	(	EXISTS	(SELECT	1
					FROM	psp_distribution_lines_history pdnh
					WHERE	pdnh.summary_line_id = psl.summary_line_id
					AND	pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	pdnh.reversal_entry_flag IS	NULL
					AND	pdnh.adjustment_batch_name IS NULL )
			OR	EXISTS	(SELECT	1
					FROM	psp_pre_gen_dist_lines_history ppg
					WHERE	ppg.summary_line_id = psl.summary_line_id
					AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	ppg.adjustment_batch_name IS	NULL
					AND	ppg.reversal_entry_flag IS NULL)
			OR	EXISTS	(SELECT	1
					FROM	psp_adjustment_lines_history palh
					WHERE	palh.summary_line_id = psl.summary_line_id
					AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	palh.adjustment_batch_name IS NULL
					AND	palh.reversal_entry_flag IS NULL
					AND	NVL(palh.original_line_flag, 'N') ='N'));

	ELSIF g_lookup_code ='PRT' THEN
		INSERT INTO psp_selected_persons_t (request_id , person_id, assignment_id)
		SELECT	DISTINCT p_request_id, psl.person_id, psl.assignment_id
		FROM	psp_summary_lines psl,
		psp_report_template_details_h prtd,
		pa_projects_all ppa,
		per_time_periods ptp
		WHERE	psl.project_id = ppa.project_id
		AND	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
		AND	prtd.criteria_lookup_code='PRT'
		AND	prtd.include_exclude_flag='I'
		AND	prtd.request_id =p_request_id
		AND	ppa.project_type=prtd.criteria_value1
		AND	psl.business_group_id = p_business_group_id
		AND	psl.set_of_books_id = p_set_of_books_id
		AND	psl.status_code= 'A'
		AND	ptp.time_period_id = psl.time_period_id
		AND	(ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start)
		AND	(	EXISTS	(SELECT	1
					FROM	psp_distribution_lines_history pdnh
					WHERE	pdnh.summary_line_id = psl.summary_line_id
					AND	pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	pdnh.reversal_entry_flag IS	NULL
					AND	pdnh.adjustment_batch_name IS NULL )
			OR	EXISTS	(SELECT	1
					FROM	psp_pre_gen_dist_lines_history ppg
					WHERE	ppg.summary_line_id = psl.summary_line_id
					AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	ppg.adjustment_batch_name IS	NULL
					AND	ppg.reversal_entry_flag IS NULL)
			OR	EXISTS	(SELECT	1
					FROM	psp_adjustment_lines_history palh
					WHERE	palh.summary_line_id = psl.summary_line_id
					AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	palh.adjustment_batch_name IS NULL
					AND	palh.reversal_entry_flag IS NULL
					AND	NVL(palh.original_line_flag, 'N') ='N'));
	ELSIF g_lookup_code ='PRJ' THEN
		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id, psl.person_id, psl.assignment_id
		FROM	psp_summary_lines psl,
			psp_report_template_details_h prtd,
			per_time_periods ptp
		WHERE
			prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
		AND	prtd.criteria_lookup_code='PRJ'
		AND	prtd.include_exclude_flag='I'
		AND	prtd.request_id =p_request_id
                and     psl.project_id = TO_NUMBER(prtd.criteria_value1)
		AND	psl.business_group_id = p_business_group_id
		AND	psl.set_of_books_id = p_set_of_books_id
		AND	psl.status_code= 'A'
		AND	ptp.time_period_id = psl.time_period_id
		AND	(ptp.start_date <= p_effort_end AND ptp.end_date >= p_effort_start)
		AND	(	EXISTS	(SELECT	1
					FROM	psp_distribution_lines_history pdnh
					WHERE	pdnh.summary_line_id = psl.summary_line_id
					AND	pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	pdnh.reversal_entry_flag IS	NULL
					AND	pdnh.adjustment_batch_name IS NULL )
			OR	EXISTS	(SELECT	1
					FROM	psp_pre_gen_dist_lines_history ppg
					WHERE	ppg.summary_line_id = psl.summary_line_id
					AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	ppg.adjustment_batch_name IS	NULL
					AND	ppg.reversal_entry_flag IS NULL)
			OR	EXISTS	(SELECT	1
					FROM	psp_adjustment_lines_history palh
					WHERE	palh.summary_line_id = psl.summary_line_id
					AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
					AND	palh.adjustment_batch_name IS NULL
					AND	palh.reversal_entry_flag IS NULL
					AND	NVL(palh.original_line_flag, 'N') ='N'));
	ELSIF g_lookup_code ='PAY' THEN

		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_assignments_f paf,
			per_assignment_status_types past
		WHERE	payroll_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='PAY'
					AND	include_exclude_flag='I'
					AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code ='LOC' THEN

		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_assignments_f paf,
			per_assignment_status_types past
		WHERE	location_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='LOC'
					AND	include_exclude_flag='I'
					AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code ='ORG' THEN
		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_assignments_f paf,
			per_assignment_status_types past
		WHERE	organization_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='ORG'
						AND	request_id = p_request_id
						AND	include_exclude_flag='I')
		AND	paf.assignment_type = 'E'
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code='CST' THEN
		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id, person_id, assignment_id
		FROM	per_assignments_f paf,
			pay_payrolls_f ppf,
			per_assignment_status_types past
		WHERE	ppf.payroll_id = paf.payroll_id
		AND	ppf.consolidation_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='CST'
							AND	include_exclude_flag='I'
							AND request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	ppf.effective_start_date <= p_effort_end
		AND	ppf.effective_end_date >= p_effort_start
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code = 'AST' THEN

		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id, person_id, paf.assignment_id
		FROM	per_all_assignments_f paf,
			hr_assignment_sets has,
			hr_assignment_set_amendments hasa,
			per_assignment_status_types past
		WHERE	has.assignment_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='AST'
							AND	include_exclude_flag='I'
							AND request_id =p_request_id)
		AND	(	(paf.payroll_id = has.payroll_id
				AND	paf.assignment_type = 'E'
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND	has.assignment_set_id = hasa.assignment_set_id)
			OR	(paf.assignment_id = hasa.assignment_id
				AND	paf.assignment_type = 'E'
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND	hasa.assignment_set_id=has.assignment_set_id AND include_or_exclude ='I'))
		AND	NOT EXISTS	(SELECT	assignment_id
					FROM	hr_assignment_set_amendments hasa
					WHERE	hasa.assignment_id = paf.assignment_id AND hasa.include_or_exclude ='E'
					AND	paf.assignment_type = 'E'
					AND	paf.effective_start_date <= p_effort_end
					AND	paf.effective_end_date >= p_effort_start)
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code ='JOB' THEN

		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_assignments_f paf,
			per_assignment_status_types past
		WHERE	job_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='JOB'
					AND	include_exclude_flag='I'
					AND	request_id = p_request_id)
		AND	paf.assignment_type = 'E'
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code ='POS' THEN
		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_assignments_f paf,
			per_assignment_status_types past
		WHERE	position_id IN	(SELECT	TO_NUMBER(criteria_value1)
					FROM	psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='POS'
					AND	request_id = p_request_id
					AND	include_exclude_flag='I')
		AND	paf.assignment_type = 'E'
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code ='ASS' THEN
		INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id,	paf.person_id,	paf.assignment_id
		FROM	per_assignments_f paf,
			per_assignment_status_types past
		WHERE	paf.assignment_status_type_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='ASS'
							AND	request_id = p_request_id
							AND	include_exclude_flag='I')
		AND	paf.assignment_type = 'E'
		AND	paf.effective_start_date <= p_effort_end
		AND	paf.effective_end_date >= p_effort_start
		AND	paf.assignment_status_type_id =   past.assignment_status_type_id
		AND (		past.per_system_status <> 'TERM_ASSIGN'
			OR	EXISTS ( select null
				FROM	psp_pre_gen_dist_lines_history
				WHERE	distribution_date between p_effort_start and p_effort_end
				AND	assignment_id = paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1 )
			OR      EXISTS (SELECT null
				FROM   psp_distribution_lines_history pdlh
			        , psp_summary_lines psl
				WHERE	pdlh.summary_line_id = psl.summary_line_id
				AND	distribution_date between p_effort_start and p_effort_end
				AND	psl.person_id = paf.person_id
				AND	psl.assignment_id =  paf.assignment_id
				AND     reversal_entry_flag IS NULL
				AND	rownum=1));

	ELSIF g_lookup_code='PPG' THEN
		open ppg_cursor;
		FETCH PPG_CURSOR into l_criteria_value1, l_criteria_value2;
		IF l_criteria_value1 IS NOT NULL THEN
			l_sql_string := l_criteria_value1 ||' = '||''''|| l_criteria_value2 ||'''' ;

			LOOP
				FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
				EXIT WHEN PPG_CURSOR%NOTFOUND;

				g_exec_string:= l_sql_string || ' OR '||l_criteria_value1 || ' = ' ||
						''''||l_criteria_value2 || '''';
				l_sql_string:= g_exec_string;

			END LOOP;
			CLOSE ppg_cursor;

			IF l_sql_string IS NOT NULL THEN
				g_exec_string := 'INSERT INTO psp_selected_persons_t (request_id, person_id, assignment_id)
					SELECT	:request_id , person_id, assignment_id
					FROM	per_assignments_f paf,
						pay_people_groups ppg,
						per_assignment_status_types past
					WHERE	paf.people_group_id= ppg.people_group_id
					AND	paf.assignment_type = ''' || 'E' || '''
					AND	paf.effective_end_date >= :p_effort_start
					AND	paf.effective_start_date <= :p_effort_end
					AND	ppg.people_group_id IN	(SELECT	people_group_id
									FROM	pay_people_groups
									WHERE	' || l_sql_string || ')
					AND	paf.assignment_status_type_id =   past.assignment_status_type_id
					AND (		past.per_system_status <> ''' ||'TERM_ASSIGN' || '''
						OR	EXISTS ( select null
							FROM	psp_pre_gen_dist_lines_history
							WHERE	distribution_date between :p_effort_start and :p_effort_end
							AND	assignment_id = paf.assignment_id
							AND     reversal_entry_flag IS NULL
							AND	rownum=1 )
						OR      EXISTS (SELECT null
							FROM   psp_distribution_lines_history pdlh
							, psp_summary_lines psl
							WHERE	pdlh.summary_line_id = psl.summary_line_id
							AND	distribution_date between :p_effort_start and :p_effort_end
							AND	psl.person_id = paf.person_id
							AND	psl.assignment_id =  paf.assignment_id
							AND     reversal_entry_flag IS NULL
							AND	rownum=1))';

				EXECUTE IMMEDIATE g_exec_string USING IN p_request_id, p_effort_start, p_effort_end,
				p_effort_start, p_effort_end, p_effort_start, p_effort_end;
			END IF;
		END IF;
	ELSIF g_lookup_code ='GLA' THEN
		OPEN gla_cursor;
		FETCH GLA_CURSOR into l_criteria_value1, l_criteria_value2, l_criteria_value3;

		IF l_criteria_value1 IS NOT NULL THEN
			l_sql_string := l_criteria_value1 ||' between '|| '''' || l_criteria_value2 ||''''||
					' AND ' || ''''|| l_criteria_value3 || '''' ;
			LOOP
				FETCH GLA_CURSOR INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
				EXIT WHEN GLA_CURSOR%NOTFOUND;

				g_exec_string:= l_sql_string || ' OR ' || l_criteria_value1 ||
						' BETWEEN ' || ''''|| l_criteria_value2 || '''' ||
						' AND ' || ''''|| l_criteria_value3 || '''' ;
				l_sql_string:=g_exec_string;
			END LOOP;
			CLOSE gla_cursor;

			IF l_sql_string IS NOT NULL THEN
				g_exec_string := 'INSERT INTO psp_selected_persons_t(request_id, person_id, assignment_id)
				SELECT	:p_request_id, psl.person_id, psl.assignment_id
				FROM	psp_summary_lines psl,
					psp_distribution_lines_history pdnh,
					psp_adjustment_lines_history palh,
					psp_pre_gen_dist_lines_history ppg,
					gl_code_combinations gcc
				WHERE	psl.business_group_id = '|| p_business_group_id || '
				AND	psl.set_of_books_id = ' || p_set_of_books_id ||'
				AND	psl.summary_line_id = pdnh.summary_line_id(+)
				AND	psl.summary_line_id = ppg.summary_line_id(+)
				AND	psl.summary_line_id = palh.summary_line_id(+)
				AND	psl.status_code= '||''''||'A'||''''||'
				AND	(	(psl.source_type IN ('||''''||'N'||''''||' ,'|| ''''|| 'O'||''''||')
						AND	pdnh.distribution_date between :p_effort_start AND :p_effort_end
						AND	pdnh.reversal_entry_flag IS NULL
						AND	pdnh.summary_line_id = psl.summary_line_id
						AND	pdnh.adjustment_batch_name IS NULL)
					OR	(psl.source_type='||''''||'P'||''''||'
						AND	ppg.distribution_date between :p_effort_start AND :p_effort_end
						AND	ppg.summary_line_id = psl.summary_line_id
						AND	ppg.adjustment_batch_name IS NULL
						AND	ppg.reversal_entry_flag IS NULL)
					OR	(psl.source_type='||''''||'A'||''''||'
						AND	palh.adjustment_batch_name IS NULL
						AND	palh.summary_line_id =psl.summary_line_id
						AND	NVL(palh.original_line_flag, ' || ''''|| 'N' || ''''|| ') = ' ||
							''''|| 'N' || '''' ||'
						AND palh.distribution_date between :p_effort_start AND :p_effort_end))
				AND	gcc.code_combination_id= psl.gl_code_combination_id
				AND	gcc.code_combination_id IN (SELECT	code_combination_id
									FROM	gl_code_combinations
									WHERE	' || l_sql_string || ')';
				EXECUTE IMMEDIATE g_exec_string USING IN p_request_id, p_effort_start,
					p_effort_end, p_effort_start, p_effort_end, p_effort_start, p_effort_end;
			END IF;
		END IF;
	ELSIF g_lookup_code='ALL' THEN
		INSERT INTO psp_selected_persons_t(request_id, person_id, assignment_id)
		SELECT	DISTINCT p_request_id, person_id, assignment_id
		FROM	per_assignments_f
		WHERE	assignment_type = 'E'
		AND	business_group_id = p_business_group_id
		AND	effective_start_date <= p_effort_end
		AND	effective_end_date >= p_effort_start;
	END IF;

	COMMIT;
END prepare_initial_asg_list;

PROCEDURE prune_initial_asg_list	(p_request_id		IN	NUMBER,
					p_effort_start		IN	DATE,
					p_effort_end		IN	DATE,
					p_business_group_id	IN	NUMBER,
					p_set_of_books_id	IN	NUMBER) IS
CURSOR	get_all_selection_criteria(p_request_id IN NUMBER) IS
SELECT	distinct criteria_lookup_code,
	include_exclude_flag
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	criteria_lookup_type='PSP_SELECTION_CRITERIA'
ORDER BY include_exclude_flag;

CURSOR	PPG_CURSOR IS
SELECT	criteria_value1, criteria_value2
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	criteria_lookup_type= 'PSP_SELECTION_CRITERIA'
AND	criteria_lookup_code='PPG'
AND	include_exclude_flag='I';

CURSOR	GLA_CURSOR IS
SELECT	criteria_value1 , criteria_value2, criteria_value3
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	criteria_lookup_type ='PSP_SELECTION_CRITERIA'
AND	criteria_lookup_code ='GLA'
AND	include_exclude_flag='I';


TYPE t_varchar_30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_varchar_1_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

l_criteria_value1	VARCHAR2(30);
l_criteria_value2	VARCHAR2(60); -- Bug 8257434
l_criteria_value3	VARCHAR2(30);
l_sql_string		VARCHAR2(1000);
BEGIN
	OPEN get_all_selection_criteria(p_request_id);
	FETCH get_all_selection_criteria BULK COLLECT INTO template_sel_criteria.array_sel_criteria,
		template_sel_criteria.array_inc_exc_flag;
	CLOSE get_all_selection_criteria;

	FOR i IN 1..template_sel_criteria.array_sel_criteria.COUNT
	LOOP
		IF template_sel_criteria.array_inc_exc_flag(i) = 'I' THEN
			IF template_sel_criteria.array_sel_criteria(i) <> g_lookup_code THEN
				IF template_sel_criteria.array_sel_criteria(i) = 'PTY'  THEN
					DELETE FROM psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
                                        /* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	person_id NOT IN	(SELECT	NVL( person_id, 0)
                                        AND    NOT EXISTS (     SELECT 1
							FROM	per_people_f ppf,
								psp_report_template_details_h prtd,
								per_assignments_f paf
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='PTY'
							AND	paf.person_id = ppf.person_id
							AND	paf.assignment_type = 'E'
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start
							and
                                                        ppf.effective_start_date <= p_effort_end and
                                                        ppf.effective_end_date >= p_effort_start
							AND	include_exclude_flag='I'
							AND	ppf.person_type_id  = TO_NUMBER(prtd.criteria_value1)
							AND	prtd.request_id = p_request_id
							AND     ppf.person_id = pspt.person_id );
				ELSIF template_sel_criteria.array_sel_criteria(i) = 'EMP' THEN
					DELETE FROM psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
                                        /* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	person_id  NOT IN	(SELECT	NVL(person_id,0)
                                        AND    NOT EXISTS (     SELECT 1
							FROM	per_all_people_f ppf, per_assignments_f paf
							WHERE	ppf.person_id IN	(SELECT	TO_NUMBER(criteria_value1)
								FROM	psp_report_template_details_h prtd
								WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
								AND	criteria_lookup_code='EMP'
								AND	include_exclude_flag='I'
								AND	prtd.request_id = p_request_id)
								AND	paf.person_id = ppf.person_id
								AND	paf.assignment_type = 'E'
								AND	paf.effective_start_date <= p_effort_end
								AND	paf.effective_end_date >= p_effort_start
							AND	ppf.effective_start_date <= p_effort_end
							AND	ppf.effective_end_date >= p_effort_start
							AND     ppf.person_id = pspt.person_id );
				ELSIF template_sel_criteria.array_sel_criteria(i) ='SUP' THEN
					DELETE FROM	psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
                                        /* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
                                        AND    NOT EXISTS (             SELECT 1
									FROM	per_all_assignments_f paf,
										psp_report_template_details_h prtd
									WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
									AND	criteria_lookup_code='SUP'
									AND	include_exclude_flag='I'
									AND	paf.supervisor_id = TO_NUMBER(prtd.criteria_value1)
									AND	prtd.request_id = p_request_id
									AND     paf.assignment_type = 'E'
									AND	paf.effective_start_date <= p_effort_end
									AND	effective_end_date >= p_effort_start
									AND     paf.assignment_id = pspt.assignment_id );
				ELSIF template_sel_criteria.array_sel_criteria(i) = 'AWD' THEN
					DELETE FROM	psp_selected_persons_t
					WHERE	request_id = p_request_id
					AND	assignment_id NOT IN (SELECT	psl.assignment_id
						FROM	psp_summary_lines psl,
							psp_report_template_details_h prtd ,
							per_time_periods ptp
						WHERE
							prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	prtd.criteria_lookup_code='AWD'
						AND	prtd.include_exclude_flag='I'
						AND	prtd.request_id =p_request_id
                                                and     psl.award_id = TO_NUMBER(prtd.criteria_value1)
						AND	psl.business_group_id = p_business_group_id
						AND	psl.set_of_books_id = p_set_of_books_id
						AND	psl.status_code= 'A'
						AND	ptp.time_period_id = psl.time_period_id
						AND	(ptp.start_date <= p_effort_end
						AND	ptp.end_date >= p_effort_start)
						AND	(	EXISTS	(SELECT	1
									FROM	psp_distribution_lines_history pdnh
									WHERE	pdnh.summary_line_id = psl.summary_line_id
									AND	pdnh.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	pdnh.reversal_entry_flag IS NULL
									AND	pdnh.adjustment_batch_name IS NULL)
							OR	EXISTS	(SELECT	1
									FROM	psp_pre_gen_dist_lines_history ppg
									WHERE	ppg.summary_line_id = psl.summary_line_id
									AND	ppg.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	ppg.adjustment_batch_name IS NULL
									AND	ppg.reversal_entry_flag IS NULL)
							OR	EXISTS	(SELECT	1
									FROM	psp_adjustment_lines_history palh
									WHERE	palh.summary_line_id = psl.summary_line_id
									AND	palh.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	palh.adjustment_batch_name IS NULL
									AND	palh.reversal_entry_flag IS NULL
									AND	NVL(palh.original_line_flag, 'N') ='N')));
				ELSIF template_sel_criteria.array_sel_criteria(i) = 'ATY' THEN
					DELETE FROM	psp_selected_persons_t
					WHERE	request_id = p_request_id
					AND	assignment_id NOT IN	(SELECT	NVL(psl.assignment_id,0)
							FROM	psp_summary_lines psl,
								psp_report_template_details_h prtd,
								gms_awards_all gaa,
								per_time_periods ptp
							WHERE	psl.award_id = gaa.award_id
							AND	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	prtd.criteria_lookup_code='ATY'
							AND	prtd.include_exclude_flag='I'
							AND	prtd.request_id =p_request_id
							AND	gaa.type=prtd.criteria_value1
							AND	psl.business_group_id = p_business_group_id
							AND	psl.set_of_books_id = p_set_of_books_id
							AND	psl.status_code= 'A'
							AND	ptp.time_period_id = psl.time_period_id
							AND	(ptp.start_date <= p_effort_end
							AND	ptp.end_date >= p_effort_start)
							AND	(	EXISTS	(SELECT	1
									FROM	psp_distribution_lines_history pdnh
									WHERE	pdnh.summary_line_id = psl.summary_line_id
									AND	pdnh.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	pdnh.reversal_entry_flag IS NULL
									AND	pdnh.adjustment_batch_name IS NULL)
								OR	EXISTS	(SELECT	1
									FROM	psp_pre_gen_dist_lines_history ppg
									WHERE	ppg.summary_line_id = psl.summary_line_id
									AND	ppg.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	ppg.adjustment_batch_name IS NULL
									AND	ppg.reversal_entry_flag IS NULL)
								OR	EXISTS	(SELECT	1
									FROM	psp_adjustment_lines_history palh
									WHERE	palh.summary_line_id = psl.summary_line_id
									AND	palh.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	palh.adjustment_batch_name IS NULL
									AND	palh.reversal_entry_flag IS NULL
									AND	NVL(palh.original_line_flag, 'N') ='N')));
				ELSIF template_sel_criteria.array_sel_criteria(i) ='PRT' THEN
					DELETE FROM	psp_selected_persons_t
					WHERE	request_id = p_request_id
					AND	assignment_id NOT IN	(SELECT	NVL(psl.assignment_id,0)
							FROM	psp_summary_lines psl,
									psp_report_template_details_h prtd,
									pa_projects_all ppa,
									per_time_periods ptp
							WHERE	psl.project_id = ppa.project_id
							AND	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	prtd.criteria_lookup_code='PRT'
							AND	prtd.include_exclude_flag='I'
							AND	prtd.request_id =p_request_id
							AND	ppa.project_type=prtd.criteria_value1
							AND	psl.business_group_id = p_business_group_id
							AND	psl.set_of_books_id = p_set_of_books_id
							AND	psl.status_code= 'A'
							AND	ptp.time_period_id = psl.time_period_id
							AND	(ptp.start_date <= p_effort_end
								AND	ptp.end_date >= p_effort_start)
							AND	(	EXISTS (SELECT	1
									FROM	psp_distribution_lines_history pdnh
									WHERE	pdnh.summary_line_id = psl.summary_line_id
									AND	pdnh.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	pdnh.reversal_entry_flag IS NULL
									AND	pdnh.adjustment_batch_name IS NULL)
								OR	EXISTS	(SELECT	1
									FROM	psp_pre_gen_dist_lines_history ppg
									WHERE	ppg.summary_line_id = psl.summary_line_id
									AND	ppg.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	ppg.adjustment_batch_name IS NULL
									AND	ppg.reversal_entry_flag IS NULL)
								OR	EXISTS	(SELECT	1
									FROM	psp_adjustment_lines_history palh
									WHERE	palh.summary_line_id = psl.summary_line_id
									AND	palh.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	palh.adjustment_batch_name IS NULL
									AND	palh.reversal_entry_flag IS NULL
									AND	NVL(palh.original_line_flag, 'N') ='N')));
				ELSIF template_sel_criteria.array_sel_criteria(i) ='PRJ' THEN
					DELETE FROM	psp_selected_persons_t
					WHERE	request_id = p_request_id
					AND	assignment_id NOT IN	(SELECT	NVL(psl.assignment_id ,0)
							FROM	psp_summary_lines psl,
							psp_report_template_details_h prtd ,
							per_time_periods ptp
							WHERE
								prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	prtd.criteria_lookup_code='PRJ'
							AND	prtd.include_exclude_flag='I'
							AND	prtd.request_id =p_request_id
                                                        and     psl.project_id = TO_NUMBER(prtd.criteria_value1)
							AND	psl.business_group_id = p_business_group_id
							AND	psl.set_of_books_id = p_set_of_books_id
							AND	psl.status_code= 'A'
							AND	ptp.time_period_id = psl.time_period_id
							AND	(ptp.start_date <= p_effort_end
								AND	ptp.end_date >= p_effort_start)
							AND	(	EXISTS	(SELECT	1
									FROM	psp_distribution_lines_history pdnh
									WHERE	pdnh.summary_line_id = psl.summary_line_id
									AND	pdnh.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	pdnh.reversal_entry_flag IS NULL
									AND	pdnh.adjustment_batch_name IS NULL )
								OR	EXISTS	(SELECT	1
									FROM	psp_pre_gen_dist_lines_history ppg
									WHERE	ppg.summary_line_id = psl.summary_line_id
									AND	ppg.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	ppg.adjustment_batch_name IS NULL
									AND	ppg.reversal_entry_flag IS NULL)
								OR	EXISTS	(SELECT	1
									FROM	psp_adjustment_lines_history palh
									WHERE	palh.summary_line_id = psl.summary_line_id
									AND	palh.distribution_date BETWEEN p_effort_start
										AND p_effort_end
									AND	palh.adjustment_batch_name IS NULL
									AND	palh.reversal_entry_flag IS NULL
									AND	NVL(palh.original_line_flag, 'N') ='N')));
				ELSIF template_sel_criteria.array_sel_criteria(i) ='PAY' THEN
					DELETE FROM	psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
					/* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
                                        AND    NOT EXISTS (             SELECT 1
									FROM	per_assignments_f paf,
										psp_report_template_details_h prtd
									WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
									AND	criteria_lookup_code='PAY'
									AND	include_exclude_flag='I'
                                                                        AND     paf.assignment_type = 'E'
									 and
                                                                         effective_start_date <= p_effort_end and
                                                                         effective_end_date >= p_effort_start
									AND	paf.payroll_id = TO_NUMBER(prtd.criteria_value1)
									AND	prtd.request_id = p_request_id
									AND     paf.assignment_id = pspt.assignment_id );
				ELSIF template_sel_criteria.array_sel_criteria(i) ='LOC' THEN
					DELETE FROM	psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
					/* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
                                        AND    NOT EXISTS (             SELECT 1
									FROM	per_assignments_f paf ,
										psp_report_template_details_h prtd
									WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
									AND	criteria_lookup_code='LOC'
                                                                        AND     paf.assignment_type = 'E'
									 and
                                                                         effective_start_date <= p_effort_end and
                                                                         effective_end_date >= p_effort_start
									AND	include_exclude_flag='I'
									AND	paf.location_id = TO_NUMBER(prtd.criteria_value1)
									AND	prtd.request_id = p_request_id
									AND     paf.assignment_id = pspt.assignment_id);
				ELSIF template_sel_criteria.array_sel_criteria(i) ='ORG' THEN
					/* Bug 5087294 : Performance fix replacing not in with not exists */
					DELETE FROM	psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
				--	AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
					AND    NOT EXISTS (             SELECT 1
									FROM	per_assignments_f paf ,
										psp_report_template_details_h prtd
									WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
									AND	criteria_lookup_code='ORG'
									AND	include_exclude_flag='I'
                                                                        AND     paf.assignment_type = 'E'
									and effective_start_date <= p_effort_end and
                                                                         effective_end_date >= p_effort_start
									AND	paf.organization_id = TO_NUMBER(prtd.criteria_value1)
									AND	prtd.request_id = p_request_id
									AND     paf.assignment_id = pspt.assignment_id );

				ELSIF template_sel_criteria.array_sel_criteria(i)='CST' THEN
					DELETE FROM	psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
					/* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
					AND    NOT EXISTS (     SELECT 1
							FROM	per_assignments_f paf,
								pay_payrolls_f ppf
							WHERE	ppf.payroll_id = paf.payroll_id
							AND	ppf.consolidation_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
								FROM	psp_report_template_details_h prtd
								WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
								AND	criteria_lookup_code='CST'
								AND	include_exclude_flag='I'
								AND	request_id = p_request_id)
							AND     paf.assignment_type = 'E'
							AND	ppf.effective_start_date <= p_effort_end
							AND	ppf.effective_end_date >= p_effort_start
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start
							AND     paf.assignment_id = pspt.assignment_id );
				ELSIF template_sel_criteria.array_sel_criteria(i) = 'AST' THEN
					DELETE FROM	psp_selected_persons_t
					WHERE	request_id = p_request_id
					AND	assignment_id NOT IN	(SELECT	NVL(paf.assignment_id,0)
					FROM	per_all_assignments_f paf,
						hr_assignment_sets has,
						hr_assignment_set_amendments hasa
					WHERE	has.assignment_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
						FROM	psp_report_template_details_h prtd
						WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
						AND	criteria_lookup_code='AST'
						AND	include_exclude_flag='I'
						AND	request_id =p_request_id)
					AND	(	(paf.payroll_id = has.payroll_id
							AND     paf.assignment_type = 'E'
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start
							AND	has.assignment_set_id = hasa.assignment_set_id)
						OR	(paf.assignment_id = hasa.assignment_id
							AND     paf.assignment_type = 'E'
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start
							AND	hasa.assignment_set_id=has.assignment_set_id
							AND	include_or_exclude ='I'))
					AND	NOT EXISTS	(SELECT	assignment_id
						FROM	hr_assignment_set_amendments hasa
						WHERE	hasa.assignment_id = paf.assignment_id
						AND     paf.assignment_type = 'E'
						AND	hasa.include_or_exclude ='E'
						AND	paf.effective_start_date <= p_effort_end
						AND	paf.effective_end_date >= p_effort_start));
				ELSIF template_sel_criteria.array_sel_criteria(i) = 'JOB' THEN
					DELETE FROM	psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
					/* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
					AND    NOT EXISTS (     SELECT 1
							FROM	per_assignments_f paf ,
								psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='JOB'
							AND	include_exclude_flag='I'
                                                        AND     paf.assignment_type = 'E'
									 and
                                                                         effective_start_date <= p_effort_end and
                                                                         effective_end_date >= p_effort_start
							AND	paf.job_id = TO_NUMBER(prtd.criteria_value1)
							AND	prtd.request_id = p_request_id
							AND     paf.assignment_id = pspt.assignment_id);
				ELSIF template_sel_criteria.array_sel_criteria(i) ='POS' THEN
					DELETE FROM	psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
					/* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
					AND    NOT EXISTS (     SELECT 1
							FROM	per_assignments_f paf ,
								psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='POS'
                                                        AND     paf.assignment_type = 'E'
									 and
                                                                         effective_start_date <= p_effort_end and
                                                                         effective_end_date >= p_effort_start
							AND	include_exclude_flag='I'
							AND	paf.position_id = TO_NUMBER(prtd.criteria_value1)
							AND	prtd.request_id = p_request_id
							AND     paf.assignment_id = pspt.assignment_id);
				ELSIF template_sel_criteria.array_sel_criteria(i) ='ASS' THEN
					DELETE FROM	psp_selected_persons_t pspt
					WHERE	request_id = p_request_id
					/* Bug 5087294 : Performance fix replacing not in with not exists */
					-- AND	assignment_id NOT IN	(SELECT	NVL(assignment_id,0)
					AND    NOT EXISTS (     SELECT 1
							FROM	per_assignments_f paf ,
								psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='ASS'
							AND	include_exclude_flag='I'
							AND	paf.assignment_status_type_id = TO_NUMBER(prtd.criteria_value1)
							AND	prtd.request_id = p_request_id
							AND     paf.assignment_type = 'E'
							AND	effective_start_date <= p_effort_end
							AND	effective_end_date >= p_effort_start
							AND     paf.assignment_id = pspt.assignment_id);
				ELSIF template_sel_criteria.array_sel_criteria(i)='PPG' THEN
					OPEN ppg_cursor;
					FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
					IF l_criteria_value1 IS NOT NULL THEN
						l_sql_string := l_criteria_value1 ||' = '||''''|| l_criteria_value2 ||'''' ;

						LOOP
							FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
							EXIT WHEN PPG_CURSOR%NOTFOUND;

							g_exec_string := l_sql_string || ' OR '|| l_criteria_value1 ||
								' = ' || '''' || l_criteria_value2||'''';
							l_sql_string:= g_exec_string;
						END LOOP;
						CLOSE ppg_cursor;

						IF l_sql_string IS NOT NULL THEN
							g_exec_string := 'DELETE FROM	psp_selected_persons_t sel
								WHERE	request_id = :request_id
								AND	NOT EXISTS (SELECT	1
								FROM	per_assignments_f paf, pay_people_groups ppg
								WHERE	paf.people_group_id= ppg.people_group_id
								AND	paf.assignment_type = ''' || 'E' || '''
								AND	paf.effective_end_date >= :p_effort_Start
								AND	paf.effective_start_date <= :p_effort_end
								AND	(' || l_sql_string || ')
								AND	paf.assignment_id = sel.assignment_id )';

							EXECUTE IMMEDIATE g_exec_string USING IN p_request_id,
								p_Effort_start, p_effort_end;
						END IF;
					END IF;
				ELSIF template_sel_criteria.array_sel_criteria(i)='GLA' THEN
					OPEN gla_cursor;
					FETCH GLA_CURSOR INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
					IF l_criteria_value1 IS NOT NULL THEN
						l_sql_string := l_criteria_value1 ||' BETWEEN '|| ''''||
							l_criteria_value2 || '''' || ' AND	' || '''' ||
							l_criteria_value3 || '''';
						LOOP
							FETCH GLA_CURSOR INTO l_criteria_value1, l_criteria_value2,
								l_criteria_value3;
							EXIT WHEN GLA_CURSOR%NOTFOUND;

							g_exec_string:= l_sql_string || ' OR ' || l_criteria_value1 ||
								' BETWEEN ' || ''''|| l_criteria_value2 || '''' ||
								' AND	' || ''''|| l_criteria_value3 || '''' ;
							l_sql_string:=g_exec_string;
						END LOOP;
						CLOSE gla_cursor;

						IF l_sql_string IS NOT NULL THEN
							g_exec_string := 'DELETE FROM	psp_selected_persons_t
							WHERE	assignment_id NOT IN (SELECT	NVL(psl.assignment_id,0)
							FROM	psp_summary_lines psl, psp_distribution_lines_history pdnh,
								psp_adjustment_lines_history palh,
								psp_pre_gen_dist_lines_history ppg, gl_code_combinations gcc
							WHERE	gcc.code_combination_id= psl.gl_code_combination_id
							AND	psl.business_group_id = '|| p_business_group_id || '
							AND	psl.set_of_books_id = ' || p_set_of_books_id || '
							AND	psl.summary_line_id = pdnh.summary_line_id(+)
							AND	psl.summary_line_id = ppg.summary_line_id(+)
							AND	psl.summary_line_id = palh.summary_line_id(+)
							AND	psl.status_code='||''''||'A'||''''||'
							AND	(	(psl.source_type IN ('||''''||'N'||''''||' ,'|| ''''|| 'O'||''''||')
									AND	pdnh.distribution_date BETWEEN
										:p_effort_start AND :p_effort_end
									AND	pdnh.reversal_entry_flag IS NULL
									AND	psl.summary_line_id = pdnh.summary_line_id
									AND	pdnh.adjustment_batch_name IS NULL)
								OR	(psl.source_type='||''''||'P'||''''||'
									AND	ppg.distribution_date BETWEEN :p_effort_start AND :p_effort_end
									AND	ppg.adjustment_batch_name IS NULL
									AND	ppg.summary_line_id =psl.summary_line_id
									AND	ppg.reversal_entry_flag IS NULL)
								OR	(psl.source_type='||''''||'A'||''''||'
									AND	palh.summary_line_id =psl.summary_line_id
									AND	palh.adjustment_batch_name IS NULL
									AND	NVL(palh.original_line_flag, ' || ''''||
										'N' || ''''|| ') = '||''''|| 'N' || '''' || '
									AND	palh.distribution_date BETWEEN
										:p_effort_start AND :p_effort_end))
							AND	gcc.code_combination_id= psl.gl_code_combination_id
							AND	gcc.code_combination_id IN (SELECT	code_combination_id
								FROM	gl_code_combinations
								WHERE	' || l_sql_string || ' ))
								AND	request_id = :request_id';

							EXECUTE IMMEDIATE g_exec_string USING IN p_effort_start,
								p_effort_end , p_effort_start, p_effort_end,
								p_effort_start, p_effort_end, p_request_id;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END LOOP;
END prune_initial_asg_list;

PROCEDURE APPLY_ASG_EXCLUSION_CRITERIA	(p_request_id		IN	NUMBER,
					p_effort_start		IN	DATE,
					p_effort_end		IN	DATE,
					p_business_group_id	IN	NUMBER,
					p_set_of_books_id	IN	NUMBER) IS
CURSOR	PPG_CURSOR IS
SELECT	criteria_value1, criteria_value2
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	criteria_lookup_type= 'PSP_SELECTION_CRITERIA'
AND	criteria_lookup_code='PPG'
AND	include_exclude_flag='E';

CURSOR	GLA_CURSOR IS
SELECT	criteria_value1, criteria_value2, criteria_value3
FROM	psp_report_template_details_h
WHERE	request_id = p_request_id
AND	criteria_lookup_type ='PSP_SELECTION_CRITERIA'
AND	criteria_lookup_code ='GLA'
AND	include_exclude_flag='E';

TYPE t_varchar_30_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_varchar_1_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

l_criteria_value1 VARCHAR2(30);
l_criteria_value2 VARCHAR2(60);  -- Bug 8257434
l_criteria_value3 VARCHAR2(30);
l_sql_string VARCHAR2(1000);
BEGIN
	FOR i IN 1..template_sel_criteria.array_sel_criteria.COUNT
	LOOP
		IF template_sel_criteria.array_inc_exc_flag(i) = 'E' THEN
			IF template_sel_criteria.array_sel_criteria(i) = 'PTY' THEN
				DELETE FROM psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	person_id IN	(SELECT	ppf.person_id
							FROM	per_people_f ppf,
								psp_report_template_details_h prtd,
								per_assignments_f paf
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='PTY'
            AND	paf.person_id = ppf.person_id
            AND	paf.assignment_type = 'E'
            AND	paf.effective_start_date <= p_effort_end
            AND	paf.effective_end_date >= p_effort_start
	    and
            ppf.effective_start_date <= p_effort_end and
            ppf.effective_end_date >= p_effort_start
							AND	include_exclude_flag='E'
							AND	ppf.person_type_id  = TO_NUMBER(prtd.criteria_value1)
							AND	prtd.request_id = p_request_id);
			ELSIF template_sel_criteria.array_sel_criteria(i) = 'EMP' THEN
				DELETE FROM psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	person_id IN	(SELECT	DISTINCT ppf.person_id
						FROM	per_all_people_f ppf, per_assignments_f paf
						WHERE	ppf.person_id IN	(SELECT	TO_NUMBER(criteria_value1)
								FROM	psp_report_template_details_h prtd
								WHERE	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
								AND	criteria_lookup_code='EMP'
								AND	include_exclude_flag='E'
								AND	prtd.request_id = p_request_id)
				AND	paf.person_id = ppf.person_id
				AND	paf.assignment_type = 'E'
				AND	paf.effective_start_date <= p_effort_end
				AND	paf.effective_end_date >= p_effort_start
				AND	ppf.effective_start_date <= p_effort_end
				AND	ppf.effective_end_date >= p_effort_start);
			ELSIF template_sel_criteria.array_sel_criteria(i) ='SUP' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	NVL(assignment_id,0)
								FROM	per_all_assignments_f paf,
									psp_report_template_details_h prtd
								WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
								AND	criteria_lookup_code='SUP'
								AND	include_exclude_flag='E'
								AND	paf.supervisor_id = TO_NUMBER(prtd.criteria_value1)
								AND	prtd.request_id = p_request_id
								AND     paf.assignment_type = 'E'
								AND	paf.effective_start_date <= p_effort_end
								AND	paf.effective_end_date >= p_effort_start);
			ELSIF template_sel_criteria.array_sel_criteria(i) = 'AWD' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	psl.assignment_id
					FROM	psp_summary_lines psl,
						psp_report_template_details_h prtd,
						per_time_periods ptp
					WHERE
						prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	prtd.criteria_lookup_code='AWD'
					AND	prtd.include_exclude_flag='E'
					AND	prtd.request_id =p_request_id
                                        and     psl.award_id = TO_NUMBER(prtd.criteria_value1)
					AND	psl.business_group_id = p_business_group_id
					AND	psl.set_of_books_id = p_set_of_books_id
					AND	psl.status_code= 'A'
					AND	ptp.time_period_id = psl.time_period_id
					AND	(ptp.start_date <= p_effort_end
					AND	ptp.end_date >= p_effort_start)
					AND	(	EXISTS	(SELECT	1
							FROM	psp_distribution_lines_history pdnh
							WHERE	pdnh.summary_line_id = psl.summary_line_id
							AND	pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	pdnh.reversal_entry_flag IS NULL
							AND	pdnh.adjustment_batch_name IS NULL)
						OR	EXISTS	(SELECT	1
							FROM	psp_pre_gen_dist_lines_history ppg
							WHERE	ppg.summary_line_id = psl.summary_line_id
							AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	ppg.adjustment_batch_name IS NULL
							AND	ppg.reversal_entry_flag IS NULL)
						OR	EXISTS	(SELECT	1
							FROM	psp_adjustment_lines_history palh
							WHERE	palh.summary_line_id = psl.summary_line_id
							AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	palh.adjustment_batch_name IS NULL
							AND	palh.reversal_entry_flag IS NULL
							AND	NVL(palh.original_line_flag, 'N') ='N')));
			ELSIF template_sel_criteria.array_sel_criteria(i) = 'ATY' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	NVL(psl.assignment_id,0)
					FROM	psp_summary_lines psl,
						psp_report_template_details_h prtd,
						gms_awards_all gaa,
						per_time_periods ptp
					WHERE	psl.award_id = gaa.award_id
					AND	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	prtd.criteria_lookup_code='ATY'
					AND	prtd.include_exclude_flag='E'
					AND	prtd.request_id =p_request_id
					AND	gaa.type=prtd.criteria_value1
					AND	psl.business_group_id = p_business_group_id
					AND	psl.set_of_books_id = p_set_of_books_id
					AND	psl.status_code= 'A'
					AND	ptp.time_period_id = psl.time_period_id
					AND	(ptp.start_date <= p_effort_end
					AND	ptp.end_date >= p_effort_start)
					AND	(	EXISTS	(SELECT	1
							FROM	psp_distribution_lines_history pdnh
							WHERE	pdnh.summary_line_id = psl.summary_line_id
							AND	pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	pdnh.reversal_entry_flag IS NULL
							AND	pdnh.adjustment_batch_name IS NULL)
						OR	EXISTS	(SELECT	1
							FROM	psp_pre_gen_dist_lines_history ppg
							WHERE	ppg.summary_line_id = psl.summary_line_id
							AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	ppg.adjustment_batch_name IS NULL
							AND	ppg.reversal_entry_flag IS NULL)
						OR	EXISTS	(SELECT	1
							FROM	psp_adjustment_lines_history palh
							WHERE	palh.summary_line_id = psl.summary_line_id
							AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	palh.adjustment_batch_name IS NULL
							AND	palh.reversal_entry_flag IS NULL
							AND	NVL(palh.original_line_flag, 'N') ='N')));
			ELSIF template_sel_criteria.array_sel_criteria(i) ='PRT' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	NVL(psl.assignment_id,0)
					FROM	psp_summary_lines psl,
						psp_report_template_details_h prtd,
						pa_projects_all ppa,
						per_time_periods ptp
					WHERE	psl.project_id = ppa.project_id
					AND	prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	prtd.criteria_lookup_code='PRT'
					AND	prtd.include_exclude_flag='E'
					AND	prtd.request_id =p_request_id
					AND	ppa.project_type=prtd.criteria_value1
					AND	psl.business_group_id = p_business_group_id
					AND	psl.set_of_books_id = p_set_of_books_id
					AND	psl.status_code= 'A'
					AND	ptp.time_period_id = psl.time_period_id
					AND	(ptp.start_date <= p_effort_end
					AND	ptp.end_date >= p_effort_start)
					AND	(	EXISTS	(SELECT	1
							FROM	psp_distribution_lines_history pdnh
							WHERE	pdnh.summary_line_id = psl.summary_line_id
							AND	pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	pdnh.reversal_entry_flag IS NULL
							AND	pdnh.adjustment_batch_name IS NULL)
						OR	EXISTS	(SELECT	1
							FROM	psp_pre_gen_dist_lines_history ppg
							WHERE	ppg.summary_line_id = psl.summary_line_id
							AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	ppg.adjustment_batch_name IS NULL
							AND	ppg.reversal_entry_flag IS NULL)
						OR	EXISTS	(SELECT	1
							FROM	psp_adjustment_lines_history palh
							WHERE	palh.summary_line_id = psl.summary_line_id
							AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	palh.adjustment_batch_name IS NULL
							AND	palh.reversal_entry_flag IS NULL
							AND	NVL(palh.original_line_flag, 'N') ='N')));
			ELSIF template_sel_criteria.array_sel_criteria(i) ='PRJ' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	NVL(psl.assignment_id,0)
					FROM	psp_summary_lines psl,
						psp_report_template_details_h prtd,
						per_time_periods ptp
					WHERE
						prtd.criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	prtd.criteria_lookup_code='PRJ'
					AND	prtd.include_exclude_flag='E'
					AND	prtd.request_id =p_request_id
                                        and     psl.project_id = TO_NUMBER(prtd.criteria_value1)
					AND	psl.business_group_id = p_business_group_id
					AND	psl.set_of_books_id = p_set_of_books_id
					AND	psl.status_code= 'A'
					AND	ptp.time_period_id = psl.time_period_id
					AND	(ptp.start_date <= p_effort_end
					AND	ptp.end_date >= p_effort_start)
					AND	(	EXISTS	(SELECT	1
							FROM	psp_distribution_lines_history pdnh
							WHERE	pdnh.summary_line_id = psl.summary_line_id
							AND	pdnh.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	pdnh.reversal_entry_flag IS NULL
							AND	pdnh.adjustment_batch_name IS NULL)
						OR	EXISTS	(SELECT	1
							FROM	psp_pre_gen_dist_lines_history ppg
							WHERE	ppg.summary_line_id = psl.summary_line_id
							AND	ppg.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	ppg.adjustment_batch_name IS NULL
							AND	ppg.reversal_entry_flag IS NULL)
						OR	EXISTS	(SELECT	1
							FROM	psp_adjustment_lines_history palh
							WHERE	palh.summary_line_id = psl.summary_line_id
							AND	palh.distribution_date BETWEEN p_effort_start AND p_effort_end
							AND	palh.adjustment_batch_name IS NULL
							AND	palh.reversal_entry_flag IS NULL
							AND	NVL(palh.original_line_flag, 'N') ='N')));
			ELSIF template_sel_criteria.array_sel_criteria(i) ='PAY' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	assignment_id
					FROM	per_assignments_f paf,
						psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='PAY'
					AND	include_exclude_flag='E'
                                        AND     paf.assignment_type = 'E'
					and effective_start_date <= p_effort_end and
                                         effective_end_date >= p_effort_start
					AND	paf.payroll_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id);
			ELSIF template_sel_criteria.array_sel_criteria(i) ='LOC' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	assignment_id
					FROM	per_assignments_f paf,
						psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='LOC'
					AND	include_exclude_flag='E'
                                        AND     paf.assignment_type = 'E'
					and effective_start_date <= p_effort_end and
                                         effective_end_date >= p_effort_start
					AND	paf.location_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id);
			ELSIF template_sel_criteria.array_sel_criteria(i) ='ORG' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	assignment_id
					FROM	per_assignments_f paf,
						psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='ORG'
					AND	include_exclude_flag='E'
                                        AND     paf.assignment_type = 'E'
					and effective_start_date <= p_effort_end and
                                        effective_end_date >= p_effort_start
					AND	paf.organization_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id);
			ELSIF template_sel_criteria.array_sel_criteria(i) = 'JOB' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	assignment_id
					FROM	per_assignments_f paf,
						psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='JOB'
					AND	include_exclude_flag='E'
                                        AND     paf.assignment_type = 'E'
					and effective_start_date <= p_effort_end and
                                        effective_end_date >= p_effort_start
					AND	paf.job_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id);
			ELSIF template_sel_criteria.array_sel_criteria(i) ='POS' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	assignment_id
					FROM	per_assignments_f paf,
						psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='POS'
					AND	include_exclude_flag='E'
                                        AND     paf.assignment_type = 'E'
					and effective_start_date <= p_effort_end and
                                        effective_end_date >= p_effort_start
					AND	paf.position_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id);
			ELSIF template_sel_criteria.array_sel_criteria(i) ='ASS' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	assignment_id
					FROM	per_assignments_f paf,
						psp_report_template_details_h prtd
					WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
					AND	criteria_lookup_code='ASS'
					AND	include_exclude_flag='E'
					AND     paf.assignment_type = 'E'
					AND	paf.assignment_status_type_id = TO_NUMBER(prtd.criteria_value1)
					AND	prtd.request_id = p_request_id
					AND	effective_start_date <= p_effort_end
					AND	effective_end_date >= p_effort_start);
			ELSIF template_sel_criteria.array_sel_criteria(i)='CST' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	NVL(assignment_id,0)
					FROM	per_assignments_f paf,
						pay_payrolls_f ppf
					WHERE	ppf.payroll_id = paf.payroll_id
					AND	ppf.consolidation_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='CST'
							AND	include_exclude_flag='E'
							AND	request_id = p_request_id)
					AND     paf.assignment_type = 'E'
					AND	ppf.effective_start_date <= p_effort_end
					AND	ppf.effective_end_date >= p_effort_start
					AND	paf.effective_start_date <= p_effort_end
					AND	paf.effective_end_date >= p_effort_start);
			ELSIF template_sel_criteria.array_sel_criteria(i) = 'AST' THEN
				DELETE FROM	psp_selected_persons_t
				WHERE	request_id = p_request_id
				AND	assignment_id IN	(SELECT	NVL(paf.assignment_id,0)
					FROM	per_all_assignments_f paf, hr_assignment_sets has,
						hr_assignment_set_amendments hasa
					WHERE	has.assignment_set_id IN	(SELECT	TO_NUMBER(criteria_value1)
							FROM	psp_report_template_details_h prtd
							WHERE	criteria_lookup_type='PSP_SELECTION_CRITERIA'
							AND	criteria_lookup_code='AST'
							AND	include_exclude_flag='E'
							AND	request_id =p_request_id)
					AND	(	(paf.payroll_id = has.payroll_id
							AND     paf.assignment_type = 'E'
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start
							AND	has.assignment_set_id = hasa.assignment_set_id)
						OR	(paf.assignment_id = hasa.assignment_id
							AND     paf.assignment_type = 'E'
							AND	paf.effective_start_date <= p_effort_end
							AND	paf.effective_end_date >= p_effort_start
							AND	hasa.assignment_set_id=has.assignment_set_id
							AND	include_or_exclude ='I'))
					AND	NOT EXISTS	(SELECT	assignment_id
						FROM	hr_assignment_set_amendments hasa
						WHERE	hasa.assignment_id = paf.assignment_id
						AND     paf.assignment_type = 'E'
						AND	hasa.include_or_exclude ='E'
						AND	paf.effective_start_date <= p_effort_end
						AND	paf.effective_end_date >= p_effort_start));
			ELSIF template_sel_criteria.array_sel_criteria(i)='PPG' THEN
				OPEN ppg_cursor;
				FETCH PPG_CURSOR into l_criteria_value1, l_criteria_value2;
				IF l_criteria_value1 IS NOT NULL THEN
					l_sql_string := l_criteria_value1 ||' = '||''''|| l_criteria_value2 || '''' ;

					LOOP
						FETCH PPG_CURSOR INTO l_criteria_value1, l_criteria_value2;
						EXIT WHEN PPG_CURSOR%NOTFOUND;

						g_exec_string := l_sql_string || ' OR '|| l_criteria_value1 || ' = ' ||
								'''' || l_criteria_value2||'''';
						l_sql_string:= g_exec_string;
					END LOOP;
					CLOSE ppg_cursor;

					IF l_sql_string IS NOT NULL THEN
						g_exec_string := 'DELETE FROM	psp_selected_persons_t
							WHERE	assignment_id IN	(SELECT	assignment_id
								FROM	per_assignments_f paf,
									pay_people_groups ppg
								WHERE	paf.people_group_id= ppg.people_group_id
								AND	paf.assignment_type = ''' || 'E' || '''
								AND	paf.effective_end_date >= :p_effort_Start
								AND	paf.effective_start_date <= :p_effort_end
								AND	ppg.people_group_id IN	(SELECT	people_group_id
										FROM	pay_people_groups
										WHERE	' || l_sql_string || '))
							AND	request_id = :request_id';

						EXECUTE IMMEDIATE g_exec_string USING IN p_effort_start, p_effort_end,
								p_request_id;
					END IF;
				END IF;
			ELSIF template_sel_criteria.array_sel_criteria(i)='GLA' THEN
				OPEN gla_cursor;
				FETCH gla_cursor INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
				IF l_criteria_value1 IS NOT NULL THEN
					l_sql_string := l_criteria_value1 ||' BETWEEN '|| '''' || l_criteria_value2 ||
							'''' || ' AND ' || '''' || l_criteria_value3 || '''' ;
					LOOP
						FETCH gla_cursor INTO l_criteria_value1, l_criteria_value2, l_criteria_value3;
						EXIT WHEN gla_cursor%NOTFOUND;

						g_exec_string:= l_sql_string || ' OR ' || l_criteria_value1 ||
								' BETWEEN ' || ''''|| l_criteria_value2 || '''' ||
								' AND ' || ''''|| l_criteria_value3 || '''' ;
						l_sql_string:= g_exec_string;
					END LOOP;
				CLOSE gla_cursor;

					IF l_sql_string IS NOT NULL THEN
						g_exec_string := 'DELETE FROM	psp_selected_persons_t
							WHERE	assignment_id IN	(SELECT	NVL(psl.assignment_id,0)
								FROM	psp_summary_lines psl,
									psp_distribution_lines_history pdnh,
									psp_adjustment_lines_history palh,
									psp_pre_gen_dist_lines_history ppg,
									gl_code_combinations gcc
								WHERE	gcc.code_combination_id= psl.gl_code_combination_id
								AND	psl.business_group_id = '|| p_business_group_id || '
								AND	psl.set_of_books_id = ' || p_set_of_books_id || '
								AND	psl.summary_line_id = pdnh.summary_line_id(+)
								AND	psl.summary_line_id = ppg.summary_line_id(+)
								AND	psl.summary_line_id = palh.summary_line_id(+)
								AND	psl.status_code='||''''||'A'||''''||'
								AND	(	(psl.source_type IN ('||''''||'N'||''''||
											' ,'|| ''''|| 'O'||''''||')
										AND	pdnh.distribution_date BETWEEN
											:p_effort_start AND :p_effort_end
										AND	pdnh.reversal_entry_flag IS NULL
										AND	psl.summary_line_id =pdnh.summary_line_id
										AND	pdnh.adjustment_batch_name IS NULL)
									OR	(psl.source_type= '||''''||'P'||''''||'
										AND	ppg.distribution_date BETWEEN
											:p_effort_start AND :p_effort_end
										AND	ppg.adjustment_batch_name IS NULL
										AND	ppg.summary_line_id =psl.summary_line_id
										AND	ppg.reversal_entry_flag IS NULL)
									OR	(psl.source_type= '||''''||'A'||''''||'
										AND	palh.summary_line_id =psl.summary_line_id
										AND	palh.adjustment_batch_name IS NULL
										AND	NVL(palh.original_line_flag, ' ||
											''''|| 'N' || ''''|| ') = '||''''||
											'N' || '''' || '
										AND	palh.distribution_date BETWEEN
											:p_effort_start AND :p_effort_end))
								AND	gcc.code_combination_id= psl.gl_code_combination_id
								AND	gcc.code_combination_id IN	(SELECT	code_combination_id
										FROM	gl_code_combinations
										WHERE	' || l_sql_string || '))
							AND	request_id = :request_id';

						EXECUTE IMMEDIATE g_exec_string USING IN p_effort_start, p_effort_end,
							p_effort_start, p_effort_end, p_effort_start, p_effort_end, p_request_id;
					END IF;
				END IF;
			END IF;
		END IF;
	END LOOP;
END APPLY_ASG_EXCLUSION_CRITERIA;

END;

/
