--------------------------------------------------------
--  DDL for Package Body PSP_UPGRADE_EFF_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_UPGRADE_EFF_REPORTS" AS
/*$Header: PSPERUPB.pls 120.7 2006/09/28 21:29:18 vdharmap noship $*/

PROCEDURE MIGRATE_EFF_REPORTS(
                    errBuf              OUT NOCOPY VARCHAR2,
                    retCode             OUT NOCOPY VARCHAR2,
                    p_diagnostic_mode   IN  VARCHAR2,
                    p_ignore_appr       IN  VARCHAR2,
                    p_ignore_da         IN  VARCHAR2,
                    p_element_set_name  IN  VARCHAR2
) IS

        l_period_name                   VARCHAR2(80);
        l_deleted                       BOOLEAN := TRUE;
        l_appr_exists                   NUMBER :=0 ;
        l_pending_da                    NUMBER :=0 ;
        l_pending_summ_trans            Number :=0 ;
        l_configuration_value_id        NUMBER;
        l_object_version_number         NUMBER;
        cnt                             NUMBER := 0;
        l_person_id                     NUMBER :=0;
        l_element_set_id                NUMBER;
        l_element_Set_name              VARCHAR2(80);
        i                               NUMBER;
        l_rowid                          VARCHAR2(80);
        l_current_run NUMBER;
        l_err_phase NUMBER;
        l_curr_phase NUMBER;
        l_business_group_id NUMBER;
        l_element_set_suffix_number Number :=1 ;
        l_msg_buf VARCHAR(2000);
        l_migration_not_allowed Exception;
        l_element_set_alredy_exist Exception;
        l_er_already_migrated Exception;
        l_is_element_set_alredy_exist Number := 0;

	CURSOR effort_master_csr IS
	select outer.effort_report_id,  outer.person_id, ppf.full_name,
--     people.full_name approver_name,
    pert.begin_date, pert.End_date,  pbg.name
    from psp_effort_reports outer,
    psp_effort_report_templates pert ,
    per_all_people_f ppf,
--    wf_notifications wfis,
    per_business_groups pbg
--    ,
--    per_assignments_f assignment,
--    per_people_f  people
    where outer.status_code in ('N', 'A')
    and outer.template_id = pert.template_id
    and pert.report_type='N'
    and pbg.BUSINESS_GROUP_ID = pert.BUSINESS_GROUP_ID
/* Commented for bug 5048771
    and wfis.notification_id = (select max(wfas.notification_id)
                                from wf_item_activity_statuses wfas
                                where wfas.item_type='PSPEFFWF'
                                and wfas.item_key= outer.effort_report_id || outer.VERSION_NUM)
*/
    and outer.person_id =ppf.person_id
    and ppf.effective_start_date = ( SELECT MAX (ppf2.effective_start_date)
                                     FROM   per_all_people_f ppf2
                                     WHERE  ppf.person_id = ppf2.person_id
                                     AND    ppf2.effective_start_date <=pert.end_date
                                     AND    ppf2.effective_end_date >= pert.begin_date)
--    and pert.begin_date between ppf.effective_start_date and ppf.effective_End_date
--    AND assignment.person_id = ppf.person_id
--    AND assignment.supervisor_id = people.person_id (+)
--    AND    assignment.assignment_type ='E'
--    AND    trunc(SYSDATE) BETWEEN people.effective_start_date (+) AND people.effective_end_date(+)
--    AND    trunc(SYSDATE) BETWEEN assignment.effective_start_date AND assignment.effective_end_date
--    AND    assignment.primary_flag = 'Y'
;

    CURSOR element_set_alredy_exist_csr (p_element_set_name IN Varchar2) is
    SELECT 1 from pay_element_sets
    where ELEMENT_SET_NAME = p_element_set_name;

    CURSOR element_striped_by_bg_csr is
    SELECT DISTINCT business_group_id
    from psp_effort_report_elements;

    Cursor effort_element_csr(l_business_group_id IN NUMBER) is
    select distinct element_type_id
    from psp_effort_report_elements
    where use_in_effort_report='Y'
    and business_group_id =l_business_group_id;


    CURSOR pending_da_csr is
    select  effort_report_id, outer.person_id, ppf.full_name ,
--    people.full_name approver_name,
    pert.begin_date, pert.end_date , pal.adjustment_batch_name, pbg.name
    from psp_effort_reports outer,
    psp_effort_report_templates pert,
    per_all_people_f ppf,
     ----wf_notifications wfis,
    psp_adjustment_control_table pal,
    per_business_groups pbg
--    ,
--    per_assignments_f assignment,
--    per_people_f  people
    where outer.person_id =  pal.person_id
    and pert.end_date >= pal.distribution_start_date
    and pert.begin_date <= pal.distribution_end_date
    and pal.approver_id is null
    and outer.status_code in ('S')
    and outer.person_id =ppf.person_id
    and outer.template_id = pert.template_id
--    and pert.begin_date between  ppf.effective_Start_date and ppf.effective_end_date
     and ppf.effective_start_date = ( SELECT MAX (ppf2.effective_start_date)
                                     FROM   per_all_people_f ppf2
                                     WHERE  ppf.person_id = ppf2.person_id
                                     AND    ppf2.effective_start_date <=pert.end_date
                                     AND    ppf2.effective_end_date >= pert.begin_date)
      and pbg.BUSINESS_GROUP_ID = pert.BUSINESS_GROUP_ID
    ---and wfis.notification_id = (         --- removed this condn and added void check for 4665930
			----	SELECT	ias.notification_id
    and pal.void is null
/* Commented for bug 5048771
    and exists      (select 1
				FROM	wf_lookups l_at,
					wf_lookups l_as,
					wf_activities_vl a,
					wf_process_activities pa,
					wf_item_types_vl it,
					wf_items i,
					wf_item_activity_statuses ias
				WHERE	ias.item_type = 'PSPADJWF'
				AND	ias.item_key = pal.adjustment_batch_name
				AND	i.item_type = 'PSPADJWF'
				AND	i.item_key = pal.adjustment_batch_name
				AND	i.begin_date between a.begin_date AND nvl(a.end_date, i.begin_date)
				AND	i.item_type = it.name
				AND	ias.process_activity = pa.instance_id
				AND	pa.activity_name = a.name
				AND	pa.activity_item_type = a.item_type
				AND	l_at.lookup_type = 'WFENG_ACTIVITY_TYPE'
				AND	l_at.lookup_code = a.type
				AND	l_as.lookup_type = 'WFENG_STATUS'
				AND	l_as.lookup_code = ias.activity_status
				AND	a.name = 'NOT_APPROVAL_REQUIRED')
*/
--    AND assignment.person_id = ppf.person_id
--    AND assignment.supervisor_id = people.person_id (+)
--    AND    assignment.assignment_type ='E'
--    AND    trunc(SYSDATE) BETWEEN people.effective_start_date (+) AND people.effective_end_date(+)
--    AND    trunc(SYSDATE) BETWEEN assignment.effective_start_date AND assignment.effective_end_date
--    AND    assignment.primary_flag = 'Y'
;



    CURSOR pending_summ_trans_csr is
		  select  effort_report_id, outer.person_id, ppf.full_name ,
--          people.full_name approver_name,
          pert.begin_date, pert.end_date, pal.adjustment_batch_name, pbg.name
		  from psp_effort_reports outer,
		  psp_effort_report_templates pert,
		  per_all_people_f ppf,
		   ----wf_notifications wfis,
		  psp_adjustment_control_table pal,
		  psp_payroll_controls ppc,
          per_business_groups pbg
--          ,
--          per_assignments_f assignment,
--          per_people_f  people
		  where outer.person_id =  pal.person_id
		  and pert.end_date >= pal.distribution_start_date
		  and pert.begin_date <= pal.distribution_end_date
		  and pal.ADJUSTMENT_BATCH_NAME = ppc.BATCH_NAME
		  and ppc.SOURCE_TYPE = 'A'
		  and ppc.STATUS_CODE = 'N'
		  and outer.status_code = 'S'
		  and outer.person_id =ppf.person_id
		  and outer.template_id = pert.template_id
--		  and pert.begin_date between  ppf.effective_Start_date and ppf.effective_end_date
          and ppf.effective_start_date = ( SELECT MAX (ppf2.effective_start_date)
                                     FROM   per_all_people_f ppf2
                                     WHERE  ppf.person_id = ppf2.person_id
                                     AND    ppf2.effective_start_date <=pert.end_date
                                     AND    ppf2.effective_end_date >= pert.begin_date)
          and pbg.BUSINESS_GROUP_ID = pert.BUSINESS_GROUP_ID
		  -- and wfis.notification_id = (
				--		SELECT	ias.notification_id
                  and void is null                 ---added for 4665930
/* Commented for bug 5048771
                  and exists                   (select 1              --- 4665930
						FROM	wf_lookups l_at,
							wf_lookups l_as,
							wf_activities_vl a,
							wf_process_activities pa,
							wf_item_types_vl it,
							wf_items i,
							wf_item_activity_statuses ias
						WHERE	ias.item_type = 'PSPADJWF'
						AND	ias.item_key = pal.adjustment_batch_name
						AND	i.item_type = 'PSPADJWF'
						AND	i.item_key = pal.adjustment_batch_name
						AND	i.begin_date between a.begin_date AND nvl(a.end_date, i.begin_date)
						AND	i.item_type = it.name
						AND	ias.process_activity = pa.instance_id
						AND	pa.activity_name = a.name
						AND	pa.activity_item_type = a.item_type
						AND	l_at.lookup_type = 'WFENG_ACTIVITY_TYPE'
						AND	l_at.lookup_code = a.type
						AND	l_as.lookup_type = 'WFENG_STATUS'
						AND	l_as.lookup_code = ias.activity_status
						AND	a.name = 'NOT_APPROVAL_REQUIRED')
*/
--    AND assignment.person_id = ppf.person_id
--    AND assignment.supervisor_id = people.person_id (+)
--    AND    assignment.assignment_type ='E'
--    AND    trunc(SYSDATE) BETWEEN people.effective_start_date (+) AND people.effective_end_date(+)
--    AND    trunc(SYSDATE) BETWEEN assignment.effective_start_date AND assignment.effective_end_date
--    AND    assignment.primary_flag = 'Y'
;

BEGIN

  --hr_utility.trace_on(null,'ORACLE');
  hr_utility.trace('Run in Diagnostic Mode: ' || p_diagnostic_mode);
  hr_utility.trace('Proceed with Migration when Effort Reports are not Approved: ' || p_ignore_appr);
  hr_utility.trace('Proceed with Migration when Adjustment Batches are Pending: ' || p_ignore_da);
  hr_utility.trace('Element Set Name for Effort Report Elements: ' || p_element_set_name);

  fnd_msg_pub.initialize;

--  Check if the migration has already occurred. If not Proceed further else do nothing
  IF psp_general.IS_EFFORT_REPORT_MIGRATED THEN
    hr_utility.trace('Effort Report Already Migrated');
    raise l_er_already_migrated;
  ELSE
    IF p_ignore_appr= 'N' THEN
      hr_utility.trace('Checking for Pending Effort Report: START');

	  OPEN effort_master_csr;
      FETCH  effort_master_csr BULK COLLECT into eff_master_rec.effort_report_id, eff_master_rec.person_id,
      eff_master_rec.full_name, eff_master_rec.start_date, eff_master_rec.end_date,eff_master_rec.business_group_name;
      CLOSE effort_master_csr;

      l_appr_exists := eff_master_rec.effort_report_id.count;
      hr_utility.trace('Pending Effort reports count =' || l_appr_exists);

      FOR i in 1..l_appr_exists
      LOOP
        fnd_message.set_name('PSP', 'PSP_EFF_REP_PEND_STATUS');
        fnd_message.set_token('EMPNAME',eff_master_rec.full_name(i));
        fnd_message.set_token('BGNAME',eff_master_rec.business_group_name(i));
        fnd_message.set_token('STARTDATE',eff_master_rec.start_date(i));
        fnd_message.set_token('ENDDATE',eff_master_rec.end_date(i));
        l_msg_buf := Fnd_Message.Get ;
        fnd_file.put_line( FND_FILE.LOG, l_msg_buf);
      END LOOP;

      eff_master_rec.effort_report_id.delete;
      eff_master_rec.person_id.delete;
      eff_master_rec.full_name.delete;
      eff_master_rec.start_date.delete;
      eff_master_rec.end_date.delete;

	  hr_utility.trace('Checking for Pending Effort Report: END');
 /* check for Pending distribution adjustments   -> check for unapproved DA batches
   for whom effort reports with previous 'N'/'S' status exist. Dump that information  */
      IF p_ignore_da = 'N' THEN
        hr_utility.trace('Checking for Pending distribution adjustments: START');
        OPEN pending_da_csr;
	      FETCH PENDING_DA_CSR BULK COLLECT INTO  eff_master_rec.effort_report_id, eff_master_rec.person_id,
           eff_master_rec.full_name,
    	     eff_master_rec.start_date,
           eff_master_rec.end_date, eff_master_rec.da_batch,eff_master_rec.business_group_name;
        CLOSE pending_da_csr;

        l_pending_da := eff_master_rec.effort_report_id.count;
  	  hr_utility.trace('Pending distribution adjustments =' || l_pending_da );
        FOR i in 1..l_pending_da
        LOOP
          fnd_message.set_name('PSP', 'PSP_EFF_DA_PEND_STATUS');
          fnd_message.set_token('DABATCH',eff_master_rec.da_batch(i));
          fnd_message.set_token('BGNAME',eff_master_rec.business_group_name(i));
          fnd_message.set_token('EMPNAME',eff_master_rec.full_name(i));
          fnd_message.set_token('STARTDATE',eff_master_rec.start_date(i));
          fnd_message.set_token('ENDDATE',eff_master_rec.end_date(i));
          l_msg_buf := Fnd_Message.Get ;
          fnd_file.put_line (FND_FILE.LOG, l_msg_buf  );
        END LOOP;
        eff_master_rec.effort_report_id.delete;
        eff_master_rec.person_id.delete;
        eff_master_rec.full_name.delete;
        eff_master_rec.start_date.delete;
        eff_master_rec.end_date.delete;

  	  hr_utility.trace('Checking for Pending distribution adjustments: END');

  /* check for Pending Distribution Adjustment Batch that has not been summarized and transferred
	     Dump that information  */

        hr_utility.trace('Checking for distribution adjustments not S and T: START');

        OPEN pending_summ_trans_csr;
        FETCH pending_summ_trans_csr BULK COLLECT INTO  eff_master_rec.effort_report_id, eff_master_rec.person_id,
           eff_master_rec.full_name,
           eff_master_rec.start_date,
           eff_master_rec.end_date, eff_master_rec.da_batch,eff_master_rec.business_group_name;
        CLOSE pending_summ_trans_csr;

        l_pending_summ_trans := eff_master_rec.effort_report_id.count;
  	  hr_utility.trace('distribution adjustments not S and T ='|| l_pending_summ_trans);
        FOR i in 1..l_pending_summ_trans
        LOOP
          fnd_message.set_name('PSP', 'PSP_EFF_DA_NOT_SUMM_TRANS');
          fnd_message.set_token('DABATCH',eff_master_rec.da_batch(i));
          fnd_message.set_token('BGNAME',eff_master_rec.business_group_name(i));
          fnd_message.set_token('EMPNAME',eff_master_rec.full_name(i));
          fnd_message.set_token('STARTDATE',eff_master_rec.start_date(i));
          fnd_message.set_token('ENDDATE',eff_master_rec.end_date(i));
          l_msg_buf := Fnd_Message.Get ;
          fnd_file.put_line (FND_FILE.LOG, l_msg_buf );
        END LOOP;
      END IF;
      eff_master_rec.effort_report_id.delete;
      eff_master_rec.person_id.delete;
      eff_master_rec.full_name.delete;
	    eff_master_rec.start_date.delete;
      eff_master_rec.end_date.delete;
  	hr_utility.trace('Checking for distribution adjustments not S and T: END');
      END IF;


      IF  (p_diagnostic_mode='N') and ((l_pending_da <>0) or (l_appr_exists <> 0) or (l_pending_summ_trans <> 0)) then
          raise l_migration_not_allowed;
      END IF;
      IF  (p_diagnostic_mode='N') and (l_pending_da=0) and (l_appr_exists=0) and (l_pending_summ_trans = 0) then

  	hr_utility.trace('Migration:START');

      /*  Regular Mode, No pending Distribution Adjustments, No pending Effort Reports */

   -- fnd_file.put_line( FND_FILE.LOG, ' Before ES');

  	hr_utility.trace('Set the Element Set Name');
       IF p_element_Set_name is null then

          l_element_Set_name :='Effort Reporting Element Set';

       ELSE
         l_element_Set_name:=p_element_Set_name;

       END IF;



     OPEN element_striped_by_bg_csr;
     OPEN element_set_alredy_exist_csr(p_element_set_name);
          FETCH element_set_alredy_exist_csr into l_is_element_set_alredy_exist;
     CLOSE element_set_alredy_exist_csr;
     IF (l_is_element_set_alredy_exist = 1) and (p_element_set_name is not null) then
              raise l_element_set_alredy_exist;
     END IF;

  	hr_utility.trace(' Open element_striped_by_bg_csr');

    LOOP
     FETCH element_striped_by_bg_csr into l_business_group_id;
     EXIT when element_striped_by_bg_csr%NOTFOUND;

  --    <<loop_again>>
  --   OPEN element_set_alredy_exist_csr(l_element_set_name);
  --        FETCH element_set_alredy_exist_csr into l_is_element_set_alredy_exist;
  --   CLOSE element_set_alredy_exist_csr;

  --   IF (l_is_element_set_alredy_exist = 1) then
  --        l_element_Set_name := substr(l_element_Set_name,1,length(l_element_Set_name)-length(l_element_set_suffix_number-1)) || l_element_set_suffix_number ;
  --        l_element_set_suffix_number := l_element_set_suffix_number + 1;
  --        fnd_file.put_line (FND_FILE.LOG, 'Deep l_element_Set_name= '||l_element_Set_name );
  --        GOTO loop_again;
  --   END IF;

     OPEN effort_element_csr(l_business_group_id);
	       FETCH effort_element_csr BULK COLLECT into  eff_element_rec.element_type_id;
     CLOSE effort_element_csr;

  	hr_utility.trace(' Create Elements: pay_element_sets_pkg.insert_row');

     l_rowid := null;
     l_element_Set_id := null;
     pay_element_sets_pkg.insert_row(l_rowid, l_element_Set_id, l_business_group_id, null, l_element_set_name,'C', 'LD Eff Reports Migration Set', null, null);
     if l_element_set_suffix_number = 1 then
         l_element_Set_name := substr(l_element_Set_name,1,length(l_element_Set_name)) || l_element_set_suffix_number;
     ELSE
         l_element_Set_name := substr(l_element_Set_name,1,length(l_element_Set_name)-length(l_element_set_suffix_number-1)) || l_element_set_suffix_number ;
     END IF;
     l_element_set_suffix_number := l_element_set_suffix_number + 1;

   -- FND_FILE.PUT_LINE( FND_FILE.LOG, ' After ES insert ');

  --   FORALL i in 1..eff_element_rec.element_type_id.count

      For i in 1..eff_element_rec.element_type_id.count

      LOOP
  	hr_utility.trace(' Create Elements: pay_element_type_rules_pkg.insert_row');

  	l_rowid:=NULL;
         pay_element_type_rules_pkg.insert_row(l_rowid, eff_element_rec.element_type_id(i), l_element_Set_id, 'I',
      sysdate, fnd_global.user_id, fnd_global.user_id, fnd_global.user_id, sysdate);

	 END LOOP;
   -- fnd_file.put_line( FND_FILE.LOG, ' After members  insert ');
      psp_message_s.print_success;


    END LOOP;

    CLOSE element_striped_by_bg_csr;
  	hr_utility.trace(' Create Elements: END');


       /* Delete the obsolete menu items */

  --  fnd_file.put_line( FND_FILE.LOG, ' Before menu delete  ');

  	hr_utility.trace(' Delete Menus : START');
  	hr_utility.trace(' Delete Menu : Effort Report Period Summary');

          IF (fnd_function_security.menu_entry_exists('PSP_EFFORT_MENU', '', 'PSPERPRD')) THEN
                    l_err_phase:=1;
                  fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_EFFORT_MENU',
                      entry_sequence  =>      1,
                      prompt          =>      'Effort Report Period Summary',
                      function_name   =>      'PSPERPRD',
                      description     =>      '',
                      delete_flag     =>      'Y');


          END IF;
  	hr_utility.trace(' Delete Menu : Effort Report Creation');

          IF (fnd_function_security.menu_entry_exists('PSP_EFFORT_MENU', '', 'PSPERCRT')) THEN
                    l_err_phase:=2;
                  fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_EFFORT_MENU',
                      entry_sequence  =>      2,
                      prompt          =>      'Effort Report Creation',
                      function_name   =>      'PSPERCRT',
                      description     =>      '',
                      delete_flag     =>      'Y');
          END IF;


  	hr_utility.trace(' Delete Menu :Adhoc Effort Report Creation');
          IF (fnd_function_security.menu_entry_exists('PSP_EFFORT_MENU', '', 'PSPERADH')) THEN
                    l_err_phase:=3;
                  fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_EFFORT_MENU',
                      entry_sequence  =>      3,
                      prompt          =>      'Adhoc Effort Report Creation',
                      function_name   =>      'PSPERADH',
                      description     =>      '',
                      delete_flag     =>      'Y');
          END IF;


  	hr_utility.trace(' Delete Menu :Review Effort Report');
          IF (fnd_function_security.menu_entry_exists('PSP_EFFORT_MENU', '', 'PSPERRVW')) THEN
                  l_err_phase:=4;
                  fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_EFFORT_MENU',
                      entry_sequence  =>      4,
                      prompt          =>      'Review Effort Report',
                      function_name   =>      'PSPERRVW',
                      description     =>      '',
                      delete_flag     =>      'Y');
          END IF;

  	hr_utility.trace(' Delete Menu :Review Effort Report');
          IF (fnd_function_security.menu_entry_exists('PSP_WORKFLOW_MENU', '', 'PSPERRVW')) THEN
                  l_err_phase:=4;
                  fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_WORKFLOW_MENU',
                      entry_sequence  =>      3,
                      prompt          =>      'Review Effort Report',
                      function_name   =>      'PSPERRVW',
                      description     =>      '',
                      delete_flag     =>      'Y');
          END IF;

  	hr_utility.trace(' Delete Menu :Effort Report Aging');
          IF (fnd_function_security.menu_entry_exists('PSP_EFFORT_MENU', '', 'PSPERAGI')) THEN
                    l_err_phase:=5;
	                fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_EFFORT_MENU',
                      entry_sequence  =>      5,
                      prompt          =>      'Effort Report Aging',
                      function_name   =>      'PSPERAGI',
                      description     =>      '',
                      delete_flag     =>      'Y');
          END IF;

  	hr_utility.trace(' Delete Menu :Effort Report Messages');
          IF (fnd_function_security.menu_entry_exists('PSP_EFFORT_MENU', '', 'PSPERMES')) THEN
                    l_err_phase:=6;
                  fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_EFFORT_MENU',
                      entry_sequence  =>      6,
                      prompt          =>      'Effort Report Messages',
                      function_name   =>      'PSPERMES',
                      description     =>      '',
                      delete_flag     =>      'Y');
          END IF;

  	hr_utility.trace(' Delete Menu :Setup: Effort Report Element Types');
          IF (fnd_function_security.menu_entry_exists('PSP_OTHERS', '', 'PSPSUEFF')) THEN
                    l_err_phase:=7;
                  fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_OTHERS',
                      entry_sequence  =>      7,
                      prompt          =>      'Setup: Effort Report Element Types',
	                    function_name   =>      'PSPSUEFF',
                      description     =>      '',
                      delete_flag     =>      'Y');
          END IF;

      hr_utility.trace(' Delete Menu :Setup: Create Notification Users');
          IF (fnd_function_security.menu_entry_exists('PSP_OTHERS', '', 'PSPSUCU')) THEN
                    l_err_phase:=8;
                  fnd_function_security.menu_entry(
                      menu_name       =>      'PSP_OTHERS',
                      entry_sequence  =>      9,
                      prompt          =>      'Setup: Create Notification Users',
                      function_name   =>      'PSPSUCU',
                      description     =>      '',
                      delete_flag     =>      'Y');
          END IF;


       -- If all successful, insert row in psp_upgrade_115

  		select psp_upgrade_115_s.nextval
      		into l_current_run
  	   	from dual;
  	  hr_utility.trace(' Insert into psp_upgrade_115');

     INSERT into psp_upgrade_115(run_id, phase,object_name,date_time,status,error_message)
     VALUES (l_current_run,10000,'PSP_UPGRADE_115',sysdate,'R','Migrated Effort Reports') ;

    COMMIT;

    END IF;
    hr_utility.trace(' Migration Successful');
    hr_utility.trace_off;
  END IF;
	EXCEPTION
        WHEN l_er_already_migrated then
            ROLLBACK;
            fnd_message.set_name('PSP', 'PSP_ER_ALREADY_MIGRATED');
            l_msg_buf := Fnd_Message.Get ;
            fnd_file.put_line (FND_FILE.LOG, l_msg_buf );
			fnd_msg_pub.add;
            retCode :=0;
        WHEN l_element_set_alredy_exist then
            ROLLBACK;
            fnd_message.set_name('PSP', 'PSP_ER_DUPLICATE_ELEMENT_SET');
            fnd_message.set_token('ELEMENTSET',p_element_set_name);
            l_msg_buf := Fnd_Message.Get ;
            fnd_file.put_line (FND_FILE.LOG, l_msg_buf );
	    fnd_msg_pub.add;
            retCode :=2;
            hr_utility.trace_off;
        WHEN l_migration_not_allowed then
            ROLLBACK;
            fnd_message.set_name('PSP', 'PSP_ER_MIGRATION_NOT_ALLOWED');
            l_msg_buf := Fnd_Message.Get ;
            fnd_file.put_line (FND_FILE.LOG, l_msg_buf );
			fnd_msg_pub.add;
            retCode :=2;
            hr_utility.trace_off;
        WHEN OTHERS	THEN
			ROLLBACK;
			fnd_message.set_name('PSP','PSP_SQL_ERROR');
			fnd_message.set_token('SQLERROR',sqlerrm||l_err_phase);
			fnd_msg_pub.add;
                	psp_message_s.print_error(p_mode => FND_FILE.LOG,
                           			 p_print_header => FND_API.G_TRUE);
            retCode :=2;
            hr_utility.trace_off;
END migrate_eff_reports;
END psp_upgrade_eff_reports;

/
