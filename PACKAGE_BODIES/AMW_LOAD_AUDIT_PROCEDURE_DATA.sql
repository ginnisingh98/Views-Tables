--------------------------------------------------------
--  DDL for Package Body AMW_LOAD_AUDIT_PROCEDURE_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_LOAD_AUDIT_PROCEDURE_DATA" AS
/* $Header: amwaprb.pls 120.6 2006/09/21 16:44:19 srbalasu noship $ */


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_LOAD_AUDIT_PROCEDURE_DATA';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwaprb.pls';

   G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
   G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
   v_error_msg VARCHAR2(2000);
   v_err_msg VARCHAR2(2000);
   v_error_found boolean;

AMW_DEBUG_HIGH_ON boolean   := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMW_DEBUG_LOW_ON boolean    := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMW_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

/* To Update Audit Procedure Results */
PROCEDURE update_apr(
      errbuf       OUT NOCOPY      VARCHAR2
     ,retcode      OUT NOCOPY      VARCHAR2
     ,p_batch_id   IN              NUMBER
     ,p_user_id    IN              NUMBER
   )
IS

-- Audit Procedure Id
CURSOR c_apid IS
SELECT ap_name,audit_project_id,organization_id,task_id from amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id);

-- Audit Procedure Rev Id
CURSOR c_aprevid IS
SELECT audit_procedure_id,audit_project_id,organization_id,task_id,control_id from amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id);

--Project Id
CURSOR c_projid IS
SELECT audit_project_name,audit_project_startdate from amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id);

--Ctrl Id
CURSOR c_ctrlid IS
SELECT control_name,control_description,audit_project_id,task_id,audit_procedure_id,organization_id from amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
      and control_name is not null;

--Task Id
CURSOR c_taskid IS
SELECT task_name,audit_project_id from amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id);


--Org Id
CURSOR c_orgid IS
SELECT organization_name,audit_project_id,task_id from amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id);


--Step Id
CURSOR c_stepid IS
SELECT step_name,step_number,audit_procedure_id,audit_procedure_rev_id from amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
      and step_name is not null;

-- Audit Procedure work description details

CURSOR c_ap_details IS
SELECT ap_status,ap_work_description,ap_executedby_name,
ap_executed_on,audit_procedure_id,audit_procedure_rev_id,
audit_project_id,task_id,organization_id,ap_interface_id
FROM amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id);

-- Audit Steps description details

CURSOR c_step_details IS
SELECT step_status,step_work_description,step_executedby_name,
step_executed_on,ap_interface_id,audit_procedure_id,
audit_procedure_rev_id,audit_project_id,task_id,organization_id,step_id
FROM amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
      and step_id <> 0;

-- Effectiveness details

CURSOR c_effec_details IS
SELECT design_effectiveness,op_effectiveness,control_opinion,
ctrl_overall_summary,ctrl_overall_description,
ctrl_design_summary,ctrl_design_description,
ctrl_operating_summary,ctrl_operating_description,
audit_procedure_id,audit_procedure_rev_id,
audit_project_id,task_id,organization_id,ap_interface_id,control_id
FROM amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
      and control_id <> 0;

-- Attachment details

CURSOR c_steps_attach IS
SELECT step_id, audit_procedure_rev_id, task_id,audit_project_id,organization_id,
steps_attachment_url
FROM amw_audit_procedure_interface
WHERE created_by = DECODE (p_user_id, NULL, created_by, p_user_id)
      AND batch_id = DECODE (p_batch_id, NULL, batch_id, p_batch_id)
      and step_id <> 0;

-- Variables to store the ids

v_audit_procedure_id number;
v_audit_procedure_rev_id number;
v_task_id number;
v_org_id number;
v_ctrl_id number;
v_step_id number;
v_audit_project_id number;
v_ap_cnt number;
v_step_cnt number;
v_opinions_cnt number;
v_party_id number;
v_opinion_id number;
v_opinions_upd_id number;
v_overall number;
v_design number;
v_operating number;
v_opinion_object_id number;
v_emp_id number;
v_steps_attach_cnt number;
   lx_return_status                VARCHAR2(30);
   lx_msg_count                    NUMBER;
   lx_msg_data                     VARCHAR2(2000);
   LX_MEDIA_ID NUMBER;
   LX_DOCUMENT_ID NUMBER;
   LX_ATTACHED_DOCUMENT_ID NUMBER;
   l_seq_num number;
   l_attachment_rec AMW_LOAD_AUDIT_PROCEDURE_DATA.fnd_attachment_rec_type;
   x_return_status                VARCHAR2(30);
   x_msg_count                    NUMBER;
   x_msg_data                     VARCHAR2(2000);

-- For Opinions Log Table

v_opinion_log_id number;
v_opinions_logid number;
v_opinions_set_logid number;

v_design_detail_logid number;
v_operating_detail_logid number;
v_overall_detail_logid number;

BEGIN

-- To handle exceptions
BEGIN
-- Adding to the log file
     fnd_file.put_line (fnd_file.LOG, 'resp id: '||fnd_global.RESP_ID);
     fnd_file.put_line (fnd_file.LOG, 'resp appl id: '||fnd_global.RESP_APPL_ID);
     fnd_file.put_line (fnd_file.LOG, 'Entered the Procedure');

-- To fetch the party id
	select aecv.party_id into v_party_id
	from AMW_EMPLOYEES_CURRENT_V aecv, FND_USER fu
	where aecv.EMPLOYEE_ID = fu.EMPLOYEE_ID
	and fu.user_id = G_USER_ID;

--To Update the initial values
update amw_audit_procedure_interface set control_id = 0,task_id = 0,organization_id = 0,
audit_project_id = 0,audit_procedure_id = 0,audit_procedure_rev_id = 0,step_id = 0
where created_by = p_user_id and batch_id = p_batch_id;
-- To insert Audit Procedure Interface Id
	update  amw_audit_procedure_interface set AP_INTERFACE_ID= amw_audit_procedure_int_s.nextval where AP_INTERFACE_ID = 0
	and batch_id = p_batch_id;
	commit;

-- To fetch Audit Project Id
fnd_file.put_line (fnd_file.LOG, 'To fetch audit procedure');
FOR projid_rec IN c_projid LOOP
    	 v_audit_project_id := null;

    	  select audit_project_id into v_audit_project_id from amw_audit_projects_v
    	  where substr(to_char(start_date),1,11) = substr(to_char(projid_rec.audit_project_startdate),1,11) and project_name = projid_rec.audit_project_name
    	  and template_flag = 'N';

    	 update amw_audit_procedure_interface set audit_project_id = v_audit_project_id
    	 where audit_project_name = projid_rec.audit_project_name and batch_id = p_batch_id;

    	 commit;
    END LOOP;

-- To fetch Task Id
fnd_file.put_line (fnd_file.LOG, 'To fetch task id');
FOR taskid_rec IN c_taskid LOOP
    	 v_task_id := null;

	 if taskid_rec.task_name = '-1' then
	 	v_task_id := -1;

	 else
    	 	select task_id into v_task_id from amw_audit_tasks_v where task_name = taskid_rec.task_name
	    	and audit_project_id = taskid_rec.audit_project_id;
	 end if;

    	 update amw_audit_procedure_interface set task_id = v_task_id
    	 where task_name = taskid_rec.task_name
    	 and audit_project_id = taskid_rec.audit_project_id and batch_id = p_batch_id;

    	 commit;
    END LOOP;


-- To fetch Org Id
  fnd_file.put_line (fnd_file.LOG, 'To fetch org id');
  FOR orgid_rec IN c_orgid LOOP
    	 v_org_id := null;

	select organization_id into v_org_id from amw_audit_units_v
	where name = orgid_rec.organization_name and  organization_id in (select pk2 from amw_ap_associations
	where pk1 = orgid_rec.audit_project_id and object_type = 'PROJECT' and pk4 = orgid_rec.task_id);

    	 update amw_audit_procedure_interface set organization_id = v_org_id
    	 where organization_name = orgid_rec.organization_name and batch_id = p_batch_id
    	 and audit_project_id = orgid_rec.audit_project_id and task_id = orgid_rec.task_id;

    	 commit;
    END LOOP;

-- To fetch the audit procedure id
     fnd_file.put_line (fnd_file.LOG, 'To fetch AP ID');
    FOR apid_rec IN c_apid LOOP
    	 v_audit_procedure_id := null;

	select audit_procedure_id into v_audit_procedure_id from amw_audit_procedures_vl where curr_approved_flag = 'Y'
	and name = apid_rec.ap_name and audit_procedure_id in (select audit_procedure_id from amw_ap_associations
	where object_type = 'PROJECT' and pk4 = apid_rec.task_id and pk1 = apid_rec.audit_project_id and pk2 = apid_rec.organization_id);

    	update amw_audit_procedure_interface set audit_procedure_id = v_audit_procedure_id
    	where ap_name = apid_rec.ap_name and batch_id = p_batch_id
    	and task_id = apid_rec.task_id and audit_project_id = apid_rec.audit_project_id
    	and organization_id = apid_rec.organization_id;

    	 commit;
    END LOOP;

-- To fetch Ctrl Id
     fnd_file.put_line (fnd_file.LOG, 'To fetch Ctrl Id');
FOR ctrlid_rec IN c_ctrlid LOOP
    	 v_ctrl_id := null;

    	 select control_id into v_ctrl_id from amw_controls_b acb, amw_controls_tl act
	 where act.language(+)= userenv('LANG') and act.name = ctrlid_rec.control_name and act.description = ctrlid_rec.control_description
	 and act.control_rev_id = acb.control_rev_id and acb.curr_approved_flag = 'Y' and acb.control_id in (select pk3 from amw_ap_associations
	 where object_type = 'PROJECT' and pk1 = ctrlid_rec.audit_project_id and pk2 = ctrlid_rec.organization_id and
	 pk4 = ctrlid_rec.task_id and audit_procedure_id = ctrlid_rec.audit_procedure_id);


   	 update amw_audit_procedure_interface set control_id = v_ctrl_id
    	 where control_name = ctrlid_rec.control_name and control_description = ctrlid_rec.control_description
    	 and batch_id = p_batch_id and audit_project_id = ctrlid_rec.audit_project_id
    	 and task_id = ctrlid_rec.task_id and organization_id = ctrlid_rec.organization_id;

    	 commit;
    END LOOP;

-- To fetch audit_procedure_rev_id
     fnd_file.put_line (fnd_file.LOG, 'To fetch rev id');
For aprevid_rec IN c_aprevid LOOP
 	 v_audit_procedure_rev_id := null;
	select distinct audit_procedure_rev_id into v_audit_procedure_rev_id  from amw_AP_associations
	where audit_procedure_id = aprevid_rec.audit_procedure_id and pk1 = aprevid_rec.audit_project_id
	and pk2 = aprevid_rec.organization_id and pk4 = aprevid_rec.task_id
	and object_type = 'PROJECT';

    	update amw_audit_procedure_interface set audit_procedure_rev_id = v_audit_procedure_rev_id
    	where audit_procedure_id = aprevid_rec.audit_procedure_id and batch_id = p_batch_id
    	and task_id = aprevid_rec.task_id and audit_project_id = aprevid_rec.audit_project_id
    	and organization_id = aprevid_rec.organization_id and control_id = aprevid_rec.control_id;

	commit;
	END LOOP;
-- To fetch step Id
      fnd_file.put_line (fnd_file.LOG, 'To fetch Step Id');
   FOR stepid_rec IN c_stepid LOOP
    	 v_step_id := null;
    	 select ap_step_id into v_step_id from amw_ap_steps_vl aasv, amw_audit_procedures_vl ap
         where aasv.name = stepid_rec.step_name and aasv.cseqnum = stepid_rec.step_number
    	 and aasv.audit_procedure_id = stepid_rec.audit_procedure_id
         and ap.audit_procedure_rev_id = stepid_rec.audit_procedure_rev_id
         and ap.audit_procedure_id = stepid_rec.audit_procedure_id
         and ap.audit_procedure_rev_num >= aasv.from_rev_num
         and ap.audit_procedure_rev_num < NVL(aasv.to_rev_num, ap.audit_procedure_rev_num + 1) ;


    	 update amw_audit_procedure_interface set step_id = v_step_id
    	 where step_name = stepid_rec.step_name and step_number = stepid_rec.step_number
    	 and audit_procedure_id = stepid_rec.audit_procedure_id and batch_id = p_batch_id;

    	 commit;
    END LOOP;

-- To fetch the party Id from User Id
fnd_file.put_line (fnd_file.LOG, 'User Id' || g_user_id);
select person_party_id into v_emp_id from fnd_user where user_id = g_user_id;
     fnd_file.put_line (fnd_file.LOG, 'Start Updating the details');

     fnd_file.put_line (fnd_file.LOG, 'Updating procedure status');
-- To Update the audit procedure status
    FOR ap_details_rec IN c_ap_details LOOP
	v_ap_cnt := null;

	-- To fetch the audit_procedure_id and taksid and control id

  		if ap_details_rec.audit_procedure_rev_id is null then

			-- Adding Error msg to the interface table

			v_error_msg := 'Audit Procedure Rev id is null for'||
			ap_details_rec.ap_interface_id||' Batch Id '||p_batch_id;

			update_interface_with_error(v_error_msg,ap_details_rec.ap_interface_id);

			fnd_file.put_line (fnd_file.LOG, 'Audit Procedure Rev id is null for'||
			ap_details_rec.ap_interface_id||' Batch Id '||p_batch_id);
		else
			select count(*) into v_ap_cnt from amw_ap_executions
			where audit_procedure_rev_id = ap_details_rec.audit_procedure_rev_id
			and pk1 = ap_details_rec.audit_project_id and pk2 = ap_details_rec.organization_id
			and pk3 = ap_details_rec.task_id and execution_type = 'AP';

			if v_ap_cnt = 0 then
				insert into amw_ap_executions
					(execution_id,audit_procedure_rev_id,last_update_date,
					 last_updated_by,creation_date,created_by,
					 last_update_login,executed_on,executed_by,
					 status,work_desc,execution_type,pk1,pk2,pk3,object_version_number)
				values(amw_ap_executions_s.nextval,ap_details_rec.audit_procedure_rev_id,sysdate,
					g_user_id,sysdate,g_user_id,
					g_login_id,sysdate,v_emp_id,
					ap_details_rec.ap_status,ap_details_rec.ap_work_description,
					'AP',ap_details_rec.audit_project_id,ap_details_rec.organization_id,
					ap_details_rec.task_id,1);
				commit;
			else

				update amw_ap_executions set work_desc = ap_details_rec.ap_work_description,
				status = ap_details_rec.ap_status,executed_by = v_emp_id,
				executed_on = sysdate
				where audit_procedure_rev_id = ap_details_rec.audit_procedure_rev_id
				and pk1 = ap_details_rec.audit_project_id and pk2 = ap_details_rec.organization_id
				and pk3 = ap_details_rec.task_id and execution_type = 'AP';
				commit;
			end if;
			commit;
		end if;

	 	commit;

    END LOOP; -- end of FOR ap_status_rec IN c_ap_status LOOP


      fnd_file.put_line (fnd_file.LOG, 'Updating step status');
 -- To Update the audit Step status
     FOR step_details_rec IN c_step_details LOOP

     	v_step_cnt := null;
     	if step_details_rec.audit_procedure_rev_id is null then

		-- Adding Error msg to the interface table

		v_error_msg := 'Audit Procedure Rev id is null for'||
		step_details_rec.ap_interface_id||' Batch Id '||p_batch_id;

		update_interface_with_error(v_error_msg,step_details_rec.ap_interface_id);

		fnd_file.put_line (fnd_file.LOG, 'Audit Procedure Rev id is null for'||
		step_details_rec.ap_interface_id||' Batch Id '||p_batch_id);
	else

		if step_details_rec.step_id is null then

			-- Adding Error msg to the interface table

			v_error_msg := 'Step id is null for'||
			step_details_rec.ap_interface_id||' Batch Id '||p_batch_id;

			update_interface_with_error(v_error_msg,step_details_rec.ap_interface_id);

			fnd_file.put_line (fnd_file.LOG, 'Step  id is null for'||
			step_details_rec.ap_interface_id||' Batch Id '||p_batch_id);

		else
			select count(*) into v_step_cnt from amw_ap_executions
			where audit_procedure_rev_id = step_details_rec.audit_procedure_rev_id
			and pk1 = step_details_rec.audit_project_id and pk2 = step_details_rec.organization_id
			and pk3 = step_details_rec.task_id and execution_type = 'STEP'
			and ap_step_id = step_details_rec.step_id;

			if v_step_cnt = 0 then
				insert into amw_ap_executions
					(execution_id,audit_procedure_rev_id,ap_step_id,
					 last_update_date,last_updated_by,creation_date,created_by,
					 last_update_login,executed_on,executed_by,
					 status,work_desc,execution_type,pk1,pk2,pk3,object_version_number)
				values(amw_ap_executions_s.nextval,step_details_rec.audit_procedure_rev_id,step_details_rec.step_id,
					sysdate,g_user_id,sysdate,g_user_id,
					g_login_id,sysdate,v_emp_id,
					step_details_rec.step_status,step_details_rec.step_work_description,
					'STEP',step_details_rec.audit_project_id,step_details_rec.organization_id,
					step_details_rec.task_id,1);
				commit;
			else

				update amw_ap_executions set work_desc = step_details_rec.step_work_description,
				status = step_details_rec.step_status,executed_by = v_emp_id,
				executed_on = sysdate
				where audit_procedure_rev_id = step_details_rec.audit_procedure_rev_id
				and pk1 = step_details_rec.audit_project_id and pk2 = step_details_rec.organization_id
				and pk3 = step_details_rec.task_id and execution_type = 'STEP'
				and ap_step_id = step_details_rec.step_id;
				commit;
			end if;
			commit;
		end if;
	end if;

     END LOOP; -- end of FOR step_status_rec IN c_step_details LOOP

 -- To delete the existing Steps

 -- To update the steps attachments

 fnd_file.put_line (fnd_file.LOG, 'Updating step attachments');
 FOR step_attach_rec IN c_steps_attach LOOP

   if(step_attach_rec.steps_attachment_url IS NOT NULL) THEN

	   select count(*) into v_steps_attach_cnt from fnd_documents_tl where document_id in (
	   SELECT document_id FROM FND_ATTACHED_DOCUMENTS WHERE ENTITY_NAME='AMW_PROJECT_STEP'
	   AND PK1_VALUE = step_attach_rec.audit_project_id
           AND PK2_VALUE = step_attach_rec.organization_id
           AND PK3_VALUE = step_attach_rec.task_id AND PK4_VALUE = step_attach_rec.audit_procedure_rev_id
           AND PK5_VALUE = step_attach_rec.step_id) and file_name = step_attach_rec.steps_attachment_url
           and language(+)= userenv('LANG');
           if v_steps_attach_cnt = 0 then
	      BEGIN
		SELECT MAX(SEQ_NUM) INTO L_SEQ_NUM FROM FND_ATTACHED_DOCUMENTS WHERE ENTITY_NAME='AMW_PROJECT_STEP'
		AND PK1_VALUE = step_attach_rec.audit_project_id
		AND PK2_VALUE = step_attach_rec.organization_id
		AND PK3_VALUE = step_attach_rec.task_id AND PK4_VALUE = step_attach_rec.audit_procedure_rev_id
		AND PK5_VALUE = step_attach_rec.step_id;
		EXCEPTION
		     WHEN NO_DATA_FOUND THEN
			L_SEQ_NUM := 0;
		     WHEN OTHERS THEN
			 L_SEQ_NUM := 0;
	       END;

		  L_SEQ_NUM := L_SEQ_NUM+1;

		  l_attachment_rec.description := 'AUTO: ';
		  l_attachment_rec.file_name := step_attach_rec.steps_attachment_url;
		  l_attachment_rec.datatype_id := 5;
		  l_attachment_rec.seq_num := l_seq_num;
		  l_attachment_rec.entity_name := 'AMW_PROJECT_STEP';
		  l_attachment_rec.pk1_value := to_char(step_attach_rec.audit_project_id);
		  l_attachment_rec.pk2_value := to_char(step_attach_rec.organization_id);
		  l_attachment_rec.pk3_value := to_char(step_attach_rec.task_id);
		  l_attachment_rec.pk4_value := to_char(step_attach_rec.audit_procedure_rev_id);
		  l_attachment_rec.pk5_value := to_char(step_attach_rec.step_id);
		  l_attachment_rec.automatically_added_flag := 'N';
		  l_attachment_rec.category_id := 1;
		  l_attachment_rec.security_type := 4;
		  l_attachment_rec.publish_flag := 'Y';
		  l_attachment_rec.media_id := lx_media_id;

		  x_msg_data := null;
		  x_msg_count := 0;
		  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
		  AMW_LOAD_AUDIT_PROCEDURE_DATA.CREATE_FND_ATTACHMENT(
			 p_api_version_number         => 1,
			 p_init_msg_list              => FND_API.G_TRUE,
			 x_return_status              => X_RETURN_STATUS,
			 x_msg_count                  => X_MSG_COUNT,
			 x_msg_data                   => X_MSG_DATA,
			 p_Fnd_Attachment_rec         => l_attachment_rec,
			 x_document_id                => LX_DOCUMENT_ID,
			 x_attached_document_id       => LX_ATTACHED_DOCUMENT_ID
		      );
		commit;
	END IF;

  END IF;      --END OF IF ATTACHMENT URL IS NOT NULL

 END LOOP; -- end of Steps Attachments

 fnd_file.put_line (fnd_file.LOG, 'Getting the component Id');
 -- T0 Update the Control Effectiveness Details

	  select opinion_component_id into v_overall from amw_opinion_componts_b
	  where opinion_component_code = 'OVERALL' and object_opinion_type_id =
	  (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES where object_id =
	  (select object_id from fnd_objects where obj_name = 'AMW_ORG_AP_CONTROL'));

	  select opinion_component_id into v_design from amw_opinion_componts_b
	  where opinion_component_code = 'DESIGN' and object_opinion_type_id =
	  (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES where object_id =
	  (select object_id from fnd_objects where obj_name = 'AMW_ORG_AP_CONTROL'));

	  select opinion_component_id into v_operating from amw_opinion_componts_b
	  where opinion_component_code = 'OPERATING' and object_opinion_type_id =
	  (select object_opinion_type_id from AMW_OBJECT_OPINION_TYPES where object_id =
	  (select object_id from fnd_objects where obj_name = 'AMW_ORG_AP_CONTROL'));

	  select object_opinion_type_id into v_opinion_object_id from AMW_OBJECT_OPINION_TYPES
	  where opinion_type_id = (select opinion_type_id from AMW_OPINION_TYPES_b
	  where opinion_type_code = 'EVALUATION') and object_id = (select object_id from
	  fnd_objects where obj_name = 'AMW_ORG_AP_CONTROL');

         fnd_file.put_line (fnd_file.LOG, 'Updating Control evaluation details');
      FOR eff_details_rec IN c_effec_details LOOP

   	v_opinions_cnt := 0;

	if eff_details_rec.audit_procedure_id is null then
		-- Adding Error msg to the interface table

		v_error_msg := 'Audit Procedure id is null for'||
		eff_details_rec.ap_interface_id||' Batch Id '||p_batch_id;

		update_interface_with_error(v_error_msg,eff_details_rec.ap_interface_id);

		fnd_file.put_line (fnd_file.LOG, 'Association id is null for'||
		eff_details_rec.ap_interface_id||' Batch Id '||p_batch_id);

	else
	   	select count(*) into v_opinions_cnt from amw_opinions where
		pk1_value = eff_details_rec.control_id and pk2_value = eff_details_rec.audit_project_id and
		pk3_value = eff_details_rec.organization_id and pk4_value = eff_details_rec.audit_procedure_id and
		pk5_value = eff_details_rec.task_id;


		if v_opinions_cnt <> 0 then

			select opinion_id into v_opinions_upd_id from amw_opinions where
			pk1_value = eff_details_rec.control_id and pk2_value = eff_details_rec.audit_project_id and
			pk3_value = eff_details_rec.organization_id and pk4_value = eff_details_rec.audit_procedure_id and
			pk5_value = eff_details_rec.task_id;

			if eff_details_rec.control_opinion is not null then
				update amw_opinion_details set opinion_value_id =eff_details_rec.control_opinion,
				summary_txt = eff_details_rec.ctrl_overall_summary,
				description_txt = eff_details_rec.ctrl_overall_description
				where opinion_id = v_opinions_upd_id and opinion_component_id = v_overall;
				commit;
			end if;

			if eff_details_rec.design_effectiveness is not null then
				update amw_opinion_details set opinion_value_id =eff_details_rec.design_effectiveness,
				summary_txt = eff_details_rec.ctrl_design_summary,
				description_txt = eff_details_rec.ctrl_design_description
				where opinion_id = v_opinions_upd_id and opinion_component_id = v_design;
				commit;
			end if;

			if eff_details_rec.op_effectiveness is not null then
				update amw_opinion_details set opinion_value_id =eff_details_rec.op_effectiveness,
				summary_txt = eff_details_rec.ctrl_operating_summary,
				description_txt = eff_details_rec.ctrl_operating_description
				where opinion_id = v_opinions_upd_id and opinion_component_id = v_operating;
				commit;
			end if;
		else
			if eff_details_rec.control_opinion is null then
				eff_details_rec.ctrl_overall_summary := ' ';
				eff_details_rec.ctrl_overall_description := ' ';
			end if;

			if eff_details_rec.design_effectiveness is null then
				eff_details_rec.ctrl_design_summary := ' ';
				eff_details_rec.ctrl_design_description := ' ';
			end if;

			if eff_details_rec.op_effectiveness is null then
				eff_details_rec.ctrl_operating_summary := ' ';
				eff_details_rec.ctrl_operating_description := ' ';
			end if;

			v_opinion_id := null;

			if eff_details_rec.control_opinion is not null then


			select AMW_OPINIONS_S2.nextval into v_opinion_id from dual;

			-- Inserting into amw_opinions table

			INSERT into amw_opinions(opinion_set_id,opinion_id,object_opinion_type_id,pk1_value,pk2_value,
			pk3_value,pk4_value,pk5_value,party_id,authored_by,authored_date,last_update_date,last_updated_by,
			creation_date,created_by,last_update_login) values
			(AMW_OPINIONS_S1.nextval,v_opinion_id,v_opinion_object_id,eff_details_rec.control_id,eff_details_rec.audit_project_id,
			eff_details_rec.organization_id,eff_details_rec.audit_procedure_id,eff_details_rec.task_id,v_party_id,G_LOGIN_ID,sysdate,sysdate,G_USER_ID,
			sysdate,G_USER_ID,G_LOGIN_ID);

			commit;
			-- Inserting into amw_opinion_details table

			INSERT into amw_opinion_details(opinion_detail_id,opinion_id,opinion_component_id,opinion_value_id,
			last_update_date,last_updated_by,creation_date,created_by,last_update_login,object_version_number
			,summary_txt,description_txt) values
			(AMW_OPINION_DETAILS_S1.nextval,v_opinion_id,v_overall,eff_details_rec.control_opinion,
			sysdate,G_USER_ID,sysdate,G_USER_ID,G_LOGIN_ID,1,eff_details_rec.ctrl_overall_summary,eff_details_rec.ctrl_overall_description);

			commit;
			INSERT into amw_opinion_details(opinion_detail_id,opinion_id,opinion_component_id,opinion_value_id,
			last_update_date,last_updated_by,creation_date,created_by,last_update_login,object_version_number
			,summary_txt,description_txt) values
			(AMW_OPINION_DETAILS_S1.nextval,v_opinion_id,v_design,eff_details_rec.design_effectiveness,
			sysdate,G_USER_ID,sysdate,G_USER_ID,G_LOGIN_ID,1,eff_details_rec.ctrl_design_summary,eff_details_rec.ctrl_design_description);
			commit;

			INSERT into amw_opinion_details(opinion_detail_id,opinion_id,opinion_component_id,opinion_value_id,
			last_update_date,last_updated_by,creation_date,created_by,last_update_login,object_version_number
			,summary_txt,description_txt) values
			(AMW_OPINION_DETAILS_S1.nextval,v_opinion_id,v_operating,eff_details_rec.op_effectiveness,
			sysdate,G_USER_ID,sysdate,G_USER_ID,G_LOGIN_ID,1,eff_details_rec.ctrl_operating_summary,eff_details_rec.ctrl_operating_description);
			commit;

			end if;
		end if;

		commit;

		-- Inserting into Opinion Log Tables

		select AMW_OPINIONS_LOG_S.nextval into v_opinion_log_id from dual;


		select opinion_id into v_opinions_logid from amw_opinions where
		pk1_value = eff_details_rec.control_id and pk2_value = eff_details_rec.audit_project_id and
		pk3_value = eff_details_rec.organization_id and pk4_value = eff_details_rec.audit_procedure_id and
		pk5_value = eff_details_rec.task_id;

		select opinion_set_id into v_opinions_set_logid from amw_opinions where
		pk1_value = eff_details_rec.control_id and pk2_value = eff_details_rec.audit_project_id and
		pk3_value = eff_details_rec.organization_id and pk4_value = eff_details_rec.audit_procedure_id and
		pk5_value = eff_details_rec.task_id;


		select opinion_detail_id into v_overall_detail_logid from amw_opinion_details
		where opinion_id = v_opinions_logid and opinion_component_id = v_overall;

		select opinion_detail_id into v_design_detail_logid from amw_opinion_details
		where opinion_id = v_opinions_logid and opinion_component_id = v_design;

		select opinion_detail_id into v_operating_detail_logid from amw_opinion_details
		where opinion_id = v_opinions_logid and opinion_component_id = v_operating;


		if v_opinions_logid is not null then


			-- Inserting into amw_opinions_log table

			INSERT into amw_opinions_log(opinion_log_id,opinion_set_id,opinion_id,object_opinion_type_id,pk1_value,pk2_value,
			pk3_value,pk4_value,pk5_value,party_id,authored_by,authored_date,last_update_date,last_updated_by,
			creation_date,created_by,last_update_login) values
			(v_opinion_log_id,v_opinions_set_logid,v_opinions_logid,v_opinion_object_id,eff_details_rec.control_id,eff_details_rec.audit_project_id,
			eff_details_rec.organization_id,eff_details_rec.audit_procedure_id,eff_details_rec.task_id,v_party_id,G_LOGIN_ID,sysdate,sysdate,G_USER_ID,
			sysdate,G_USER_ID,G_LOGIN_ID);

			commit;


			if v_overall_detail_logid is not null then

				-- Inserting into amw_opinion_log_details table


				INSERT into amw_opinion_log_details(opinion_log_id,opinion_detail_id,opinion_id,opinion_component_id,opinion_value_id,
				last_update_date,last_updated_by,creation_date,created_by,last_update_login,object_version_number
				,summary_txt,description_txt,opinion_log_detail_id) values
				(v_opinion_log_id,v_overall_detail_logid,v_opinions_logid,v_overall,eff_details_rec.control_opinion,
				sysdate,G_USER_ID,sysdate,G_USER_ID,G_LOGIN_ID,1,eff_details_rec.ctrl_overall_summary,eff_details_rec.ctrl_overall_description
				,AMW_OPINION_LOG_DETAILS_S.nextval);

				commit;

				if v_design_detail_logid is not null then

					INSERT into amw_opinion_log_details(opinion_log_id,opinion_log_detail_id,opinion_detail_id,opinion_id,opinion_component_id,opinion_value_id,
					last_update_date,last_updated_by,creation_date,created_by,last_update_login,object_version_number
					,summary_txt,description_txt) values
					(v_opinion_log_id,AMW_OPINION_LOG_DETAILS_S.nextval,v_design_detail_logid,v_opinions_logid,v_design,eff_details_rec.design_effectiveness,
					sysdate,G_USER_ID,sysdate,G_USER_ID,G_LOGIN_ID,1,eff_details_rec.ctrl_design_summary,eff_details_rec.ctrl_design_description);
					commit;

				end if;

				if v_operating_detail_logid is not null then

					INSERT into amw_opinion_log_details(opinion_log_id,opinion_log_detail_id,opinion_detail_id,opinion_id,opinion_component_id,opinion_value_id,
					last_update_date,last_updated_by,creation_date,created_by,last_update_login,object_version_number
					,summary_txt,description_txt) values
					(v_opinion_log_id,AMW_OPINION_LOG_DETAILS_S.nextval,v_operating_detail_logid,v_opinions_logid,v_operating,eff_details_rec.op_effectiveness,
					sysdate,G_USER_ID,sysdate,G_USER_ID,G_LOGIN_ID,1,eff_details_rec.ctrl_operating_summary,eff_details_rec.ctrl_operating_description);
					commit;

				end if;
			end if;
		end if;
	end if;
     END LOOP; -- end of FOR eff_status_rec IN c_step_details LOOP
 commit;

 -- To delete data from interface table
 delete from amw_audit_procedure_interface where batch_id = p_batch_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
		    NULL;
        WHEN OTHERS THEN
                fnd_file.put_line (fnd_file.LOG,'Error in update '||SUBSTR (SQLERRM, 1, 200));
END;
END update_apr;

--
-- procedure update_interface_with_error
--
--
   PROCEDURE update_interface_with_error (
      p_err_msg        IN   VARCHAR2
      ,p_interface_id   IN   NUMBER
   )
   IS
      l_interface_status   amw_audit_procedure_interface.interface_status%TYPE;
   BEGIN
      ROLLBACK; -- rollback any inserts done during the current loop process
      v_error_found := TRUE;

      BEGIN
         SELECT interface_status
           INTO l_interface_status
           FROM amw_audit_procedure_interface
          WHERE ap_interface_id = p_interface_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_err_msg :=
                   'interface_id: = '
                || p_interface_id
                || '  '
                || SUBSTR (SQLERRM, 1, 100);
            fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
      END;

      BEGIN
         UPDATE amw_audit_procedure_interface
            SET interface_status =
                       l_interface_status
                    || p_err_msg
               ,error_flag = 'Y'
          WHERE ap_interface_id = p_interface_id;

         fnd_file.put_line (fnd_file.LOG, SUBSTR (l_interface_status, 1, 200));
         COMMIT;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_err_msg :=
                   'Error during package processing  '
                || ' interface_id: = '
                || p_interface_id
                || SUBSTR (SQLERRM, 1, 100);
            fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
      END;

      COMMIT;
   END update_interface_with_error;

PROCEDURE Create_Fnd_Attachment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY NUMBER,
    x_msg_data                   OUT NOCOPY VARCHAR2,

    p_Fnd_Attachment_rec         IN   fnd_attachment_rec_type,
    x_document_id                OUT NOCOPY NUMBER,
    x_attached_document_id       OUT NOCOPY NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Fnd_Attachment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full     VARCHAR2(1);
   l_document_ID            NUMBER;
   l_media_ID            NUMBER;
   l_attached_document_ID   NUMBER;
   l_dummy       NUMBER;
   l_seq_num     NUMBER := 10;
   l_row_id     VARCHAR2(255);
   l_Fnd_Attachment_rec fnd_attachment_rec_type;
   l_create_Attached_Doc boolean := true;

   CURSOR c_attached_doc_id IS
      SELECT FND_ATTACHED_DOCUMENTS_S.nextval
      FROM dual;

   CURSOR c_attached_doc_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM FND_ATTACHED_DOCUMENTS
      WHERE document_id = l_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Fnd_Attachment_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AMW_DEBUG_HIGH_ON) THEN
            AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMW_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AMW_DEBUG_HIGH_ON) THEN
            AMW_UTILITY_PVT.debug_message( 'Private API: Calling table handler fnd_documents_pkg.insert_row');
      END IF;

     l_media_id := p_Fnd_Attachment_rec.media_id;

      -- Invoke table handler
      fnd_documents_pkg.insert_row(
	 X_rowid => l_row_id,
	 X_document_id => x_document_id,
	 X_creation_date => sysdate,
	 X_created_by => FND_GLOBAL.USER_ID,
	 X_last_update_date => sysdate,
	 X_last_updated_by => FND_GLOBAL.USER_ID,
	 X_last_update_login => FND_GLOBAL.CONC_LOGIN_ID,
	 X_datatype_id => p_Fnd_Attachment_rec.datatype_id,
	 X_category_id => p_Fnd_Attachment_rec.category_id,
	 X_security_type => p_Fnd_Attachment_rec.security_type,
	 X_publish_flag => p_Fnd_Attachment_rec.publish_flag,
	 X_usage_type => p_Fnd_Attachment_rec.usage_type,
	 X_language => p_Fnd_Attachment_rec.language,
	 X_description =>p_Fnd_Attachment_rec.description,
	 X_file_name => p_Fnd_Attachment_rec.file_name,
	 X_media_id => l_media_id
	 );
      if (p_Fnd_Attachment_rec.datatype_id = 1) then

	 /* Verify if the media_id is not null */
	 if (p_Fnd_Attachment_rec.media_id is null) then
	     /* It means that a new text needs to be created, otherwise not */
	     /* Populate Short Text */
	     insert into
	     fnd_documents_short_text
	     (media_id,
	      short_text
	     )
	     values
	     (l_media_id,
	      p_Fnd_Attachment_rec.short_text
	     );
          else
	     /*
		Update fnd_documents_tl because FND_API inserts newly generated
		media_id into that table.
             */
	      update fnd_documents_tl
	      set media_id = p_Fnd_Attachment_rec.media_id
	      where document_id = x_document_id;

          end if;

      elsif (p_Fnd_Attachment_rec.datatype_id = 6) then /* File */
	 /* For File we have already generated a file id - the fnd_documents_pkg.insert_row
	    table handler has generated a fnd_lobs_s.nextval but that's not what shoule be the
	    reference to the FND_LOBS table - because the upload program has already generated a
	    sequence */
         /**
	 update fnd_documents_tl
	 set media_id = p_Fnd_Attachment_rec.media_id
	 where document_id = l_document_id;
	 **/
	 null;
      end if;

      if (p_Fnd_Attachment_rec.attachment_type is not null) then

	 if ((p_Fnd_Attachment_rec.attachment_type = 'WEB_TEXT') OR
	    (p_Fnd_Attachment_rec.attachment_type = 'WEB_IMAGE')) then

	    l_create_Attached_Doc := false;

         end if;

      end if;

      if (l_create_Attached_Doc) then

            /*
	      IF p_Fnd_Attachment_rec.attached_DOCUMENT_ID IS NULL THEN
            */
            LOOP
                l_dummy := NULL;
                OPEN c_attached_doc_id;
                FETCH c_attached_doc_id INTO l_attached_document_ID;
                CLOSE c_attached_doc_id;

                OPEN c_attached_doc_id_exists(l_attached_document_ID);
                FETCH c_attached_doc_id_exists INTO l_dummy;
                CLOSE c_attached_doc_id_exists;
                EXIT WHEN l_dummy IS NULL;
            END LOOP;

            l_Fnd_Attachment_rec.attached_document_id := l_attached_document_id;
            x_attached_document_id := l_attached_document_id;


	   /* Populate FND Attachments */
	   fnd_attached_documents_pkg.Insert_Row
	   (  x_rowid => l_row_id,
	      X_attached_document_id => l_attached_document_ID,
	      X_document_id => x_document_ID,
	      X_creation_date => sysdate,
	      X_created_by => FND_GLOBAL.USER_ID,
	      X_last_update_date => sysdate,
	      X_last_updated_by => FND_GLOBAL.USER_ID,
	      X_last_update_login => FND_GLOBAL.CONC_LOGIN_ID,
	      X_seq_num => l_seq_num,
	      X_entity_name => p_Fnd_Attachment_rec.entity_name,
	      x_column1 => null,
	      X_pk1_value => p_Fnd_Attachment_rec.pk1_value,
	      X_pk2_value => p_Fnd_Attachment_rec.pk2_value,
	      X_pk3_value => p_Fnd_Attachment_rec.pk3_value,
	      X_pk4_value => p_Fnd_Attachment_rec.pk4_value,
	      X_pk5_value => p_Fnd_Attachment_rec.pk5_value,
	      X_automatically_added_flag => p_Fnd_Attachment_rec.automatically_added_flag,
	      X_datatype_id => null,
	      X_category_id => null,
	      X_security_type => null,
	      X_publish_flag => null,
	      X_usage_type => p_Fnd_Attachment_rec.usage_type,
	      X_language => null,
	      X_media_id => l_media_id,
	      X_doc_attribute_Category => null,
	      X_doc_attribute1 => null,
	      X_doc_attribute2 => null,
	      X_doc_attribute3 => null,
	      X_doc_attribute4 => null,
	      X_doc_attribute5 => null,
	      X_doc_attribute6 => null,
	      X_doc_attribute7 => null,
	      X_doc_attribute8 => null,
	      X_doc_attribute9 => null,
	      X_doc_attribute10 => null,
	      X_doc_attribute11 => null,
	      X_doc_attribute12 => null,
	      X_doc_attribute13 => null,
	      X_doc_attribute14 => null,
	      X_doc_attribute15 => null
	   );
      end if;


      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AMW_DEBUG_HIGH_ON) THEN
            AMW_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION

   WHEN AMW_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     AMW_Utility_PVT.Error_Message(p_message_name => 'AMW_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Fnd_Attachment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
End Create_Fnd_Attachment;

END AMW_LOAD_AUDIT_PROCEDURE_DATA;


/
