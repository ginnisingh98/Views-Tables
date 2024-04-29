--------------------------------------------------------
--  DDL for Package Body PA_RP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RP_UTIL" AS
/* $Header: PARPUTILB.pls 120.7 2007/02/26 16:44:31 pschandr noship $ */
g_debug_mode VARCHAR2(1) := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');
g_proc NUMBER :=5;

PROCEDURE Assign_Job(p_main_request_id NUMBER
, p_worker_request_id NUMBER
, p_previous_succeed VARCHAR
, x_job_assigned OUT NOCOPY VARCHAR2
, x_bursting_values OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Assign_Job: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;


	UPDATE pa_rp_job_assignments
	SET status_flag = p_previous_succeed
	WHERE status_flag = 'P'
	AND main_request_id = p_main_request_id
	AND worker_request_id = p_worker_request_id;

	x_bursting_values := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
	x_bursting_values.extend(3);

	UPDATE pa_rp_job_assignments
	SET status_flag ='P', worker_request_id = p_worker_request_id
    WHERE status_flag = 'C' AND ROWNUM=1 AND main_request_id = p_main_request_id
    RETURN bursting_value_1, bursting_value_2, bursting_value_3
	INTO x_bursting_values(1), x_bursting_values(2), x_bursting_values(3);

	IF (SQL%rowcount <> 0) THEN
	   x_job_assigned := 'Y';
	ELSE
		x_job_assigned := 'N';
	END IF;

    COMMIT;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Assign_Job: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PA',p_msg_name=> 'PA_RP_GENERIC_MSG',p_msg_type=>Pa_Rp_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PA_RP_UTIL.Assign_Job');
	RAISE;
END Assign_Job;

PROCEDURE Is_DT_Trimmed (p_rp_id NUMBER
, p_app_short_name VARCHAR2
, x_is_dt_trimmed OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
l_count NUMBER;
BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Is_DT_Trimmed: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	x_is_dt_trimmed := 'N';

	SELECT COUNT(*)
		INTO l_count
	FROM
		 PA_RP_Definitions_B rp, PA_RP_Template_Lists templates, XDO_LOBS xdo
	WHERE rp.rp_Id = p_rp_id
		AND rp.rp_Id = templates.rp_Id
		AND templates.template_code = xdo.LOB_CODE
		AND xdo.application_short_name = p_app_short_name
		AND xdo.LOB_TYPE = 'TEMPLATE'
		AND (rp.dt_process_date is null or rp.dt_process_date < xdo.last_update_date OR templates.dt_process_flag='N')
		AND ROWNUM = 1;

	IF l_count = 0 THEN
		SELECT COUNT(*)
			INTO l_count
		FROM
			 PA_RP_Definitions_B rp, PA_RP_TYPES_b TYPES, XDO_LOBS xdo
		WHERE rp.rp_Id = p_rp_id
			AND rp.rp_type_Id = types.rp_type_Id
			AND types.seeded_dt_code = xdo.LOB_CODE
			AND xdo.application_short_name = p_app_short_name
			AND xdo.LOB_TYPE = 'DATA_TEMPLATE'
			AND rp.dt_process_date < xdo.last_update_date
			AND ROWNUM = 1;

		IF l_count = 0 THEN
		   x_is_dt_trimmed := 'Y';
		END IF;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Is_DT_Trimmed: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PA',p_msg_name=> 'PA_RP_GENERIC_MSG',p_msg_type=>Pa_Rp_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PA_RP_UTIL.Assign_Job');
	RAISE;
END Is_DT_Trimmed;

PROCEDURE Save_Trimmed_DT (p_rp_id NUMBER
, x_trimmed_dt OUT NOCOPY BLOB
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS

BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Is_DT_Trimmed: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	UPDATE PA_RP_DEFINITIONS_B
	SET dt_process_date = SYSDATE
	WHERE rp_id = p_rp_id;

	SELECT RP_FILE_DATA
	INTO x_trimmed_dt
	FROM PA_RP_LOBS lobs
	WHERE lobs.rp_id = p_rp_id
	AND lobs.lob_type = 'DT'
	FOR UPDATE;

	UPDATE pa_rp_template_lists
	SET DT_Process_flag = 'Y'
	WHERE rp_id = p_rp_id;
/*
	SELECT trimmed_dt
	INTO x_trimmed_dt
	FROM PA_RP_DEFINITIONS_B
	WHERE rp_id = p_rp_id
	FOR UPDATE;
	*/
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Is_DT_Trimmed: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PA',p_msg_name=> 'PA_RP_GENERIC_MSG',p_msg_type=>Pa_Rp_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PA_RP_UTIL.Assign_Job');
	ROLLBACK;
	RAISE;
END Save_Trimmed_DT;


PROCEDURE Add_Message (p_app_short_name VARCHAR2
                , p_msg_name VARCHAR2
                , p_msg_type VARCHAR2
				, p_token1 VARCHAR2 DEFAULT NULL
				, p_token1_value VARCHAR2 DEFAULT NULL
				, p_token2 VARCHAR2 DEFAULT NULL
				, p_token2_value VARCHAR2 DEFAULT NULL
				, p_token3 VARCHAR2 DEFAULT NULL
				, p_token3_value VARCHAR2 DEFAULT NULL
				, p_token4 VARCHAR2 DEFAULT NULL
				, p_token4_value VARCHAR2 DEFAULT NULL
				, p_token5 VARCHAR2 DEFAULT NULL
				, p_token5_value VARCHAR2 DEFAULT NULL
				)
IS
BEGIN
    Fnd_Message.set_name(p_app_short_name, p_msg_name);
--	Fnd_Msg_Pub.ADD;
	IF p_token1 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token1, p_token1_value);
	END IF;

	IF p_token2 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token2, p_token2_value);
	END IF;

	IF p_token3 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token3, p_token3_value);
	END IF;

	IF p_token4 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token4, p_token4_value);
	END IF;

	IF p_token5 IS NOT NULL THEN
	   Fnd_Message.set_token(p_token5, p_token5_value);
	END IF;
    Fnd_Msg_Pub.add_detail(p_message_type=>p_msg_type);
EXCEPTION
WHEN OTHERS THEN
	Fnd_Message.set_name('PA','PA_RP_GENERIC_MSG');
	Fnd_Message.set_token('PROC_NAME','PA_RP_UTILS.Add_Message');
END Add_Message;


PROCEDURE Start_Workers (p_request_id NUMBER
,p_rp_id NUMBER
, x_worker_request_ids OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
, x_return_status IN OUT NOCOPY VARCHAR
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
l_worker_number NUMBER;
l_i NUMBER;
BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Start_Workers: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;


	l_worker_number := TO_NUMBER(FND_PROFILE.VALUE('PA_RP_WORKER_QUANTITY')); -- this should be read from profile option

	x_worker_request_ids := SYSTEM.PA_NUM_TBL_TYPE();
	x_worker_request_ids.extend(l_worker_number);

	FOR l_i IN 1..l_worker_number LOOP
		x_worker_request_ids(l_i):=Fnd_Request.submit_request(application => 'PA'
										, program =>'PARPWORKER'
										, argument1 =>  p_request_id
										, argument2 =>  p_rp_id);
	END LOOP;


	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Start_Workers: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PA',p_msg_name=> 'PA_RP_GENERIC_MSG',p_msg_type=>Pa_Rp_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PA_RP_UTIL.Start_Workers');
	RAISE;
END Start_Workers;


PROCEDURE Check_Workers (p_main_request_id NUMBER
, p_worker_request_ids SYSTEM.PA_NUM_TBL_TYPE
, x_conc_prog_status OUT NOCOPY NUMBER -- 0 normal 1 warning 2 error
, x_return_status IN OUT NOCOPY VARCHAR
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)IS
l_finish VARCHAR(1);
l_i NUMBER;
l_phase VARCHAR(80);
l_status VARCHAR(80);
l_dev_phase VARCHAR(80);
l_dev_status VARCHAR(80);
l_message VARCHAR(2000);
l_request_check BOOLEAN;
l_request_id NUMBER;
BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Check_Workers: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;
/* When the main program call this procedure, it should already done with its own processing
 work, which means there is no job left to be done, so the job assignment table should
 only contain finished job and job under processing*/

-- error> warning > normal; waiting> normal; complete and pending status only need to check once.
-- initialize x_conc_prog_stauts = success,
-- for every worker request id check the status of the worker conc prog
-- check whether all jobs under this request in P status
-- (still under processing by looking at the table) -- l_finish = Y/N
-- 	if the worker is running or the worker is inactive but job is not done, then wait
-- when the waiting is complete, decide what the conc prog status should be

	x_conc_prog_status := 0;

	 FOR l_i IN 1..p_worker_request_ids.LAST LOOP

	 	l_request_id :=   p_worker_request_ids(l_i);
	  	l_dev_phase := 'RUNNING';

--		Pa_Debug.log_message(p_message => 'Checking worker status for request:'|| l_request_id);
	    WHILE (l_dev_phase = 'RUNNING') OR ((l_finish = 'N') AND (l_dev_phase = 'INACTIVE') AND (l_dev_status <>'DISABLED')) LOOP
   		  l_request_check:= Fnd_Concurrent.get_request_status(request_id => l_request_id
  				,phase => l_phase
  				,status => l_status
  				,dev_phase => l_dev_phase
  				,dev_status => l_dev_status
				,message => l_message);

		   SELECT DECODE(COUNT(*),0,'Y','N')
		   INTO l_finish
		   FROM pa_rp_job_assignments
		   WHERE main_request_id = p_main_request_id
		   AND worker_request_id = l_request_id
		   AND status_flag = 'P';

		   IF (l_dev_phase = 'RUNNING') OR ((l_finish = 'N') AND (l_dev_phase = 'INACTIVE') AND (l_dev_status <>'DISABLED')) THEN
		       Pa_Debug.log_message(p_message => 'Waiting for request:'|| l_request_id);
			   DBMS_LOCK.SLEEP(1);
		   END IF;
	    END LOOP;


		  IF (l_dev_phase = 'PENDING') OR (l_dev_phase = 'INACTIVE' AND l_finish='Y') THEN
		  	 l_request_check := Fnd_Concurrent.CANCEL_REQUEST(l_request_id,l_message);
		  END IF;

		  IF x_conc_prog_status <2 THEN
		  	 IF (l_dev_phase = 'COMPLETE') THEN
			 	IF (l_finish = 'N') OR (l_dev_status = 'ERROR') THEN
				   x_conc_prog_status :=2;
				ELSIF (l_dev_status = 'WARNING') AND (x_conc_prog_status <1) THEN
				   x_conc_prog_status :=1;
				END IF;
			 ELSIF (l_dev_phase = 'INACTVE') AND (l_dev_status='DISABLED') AND (l_finish = 'N') THEN
				x_conc_prog_status :=2;
			 END IF;
		  END IF;
	END LOOP;

	/* Move the job assignment record into history table */
	INSERT INTO pa_rp_job_assignments_history
	(ASSIGNMENT_ID, MAIN_REQUEST_ID, WORKER_REQUEST_ID, STATUS_FLAG, RP_ID, BURSTING_VALUE_1, BURSTING_VALUE_2, BURSTING_VALUE_3, CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY, LAST_UPDATE_LOGIN)
	SELECT ASSIGNMENT_ID, MAIN_REQUEST_ID, WORKER_REQUEST_ID, STATUS_FLAG, RP_ID, BURSTING_VALUE_1, BURSTING_VALUE_2, BURSTING_VALUE_3, CREATION_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATED_BY, LAST_UPDATE_LOGIN FROM pa_rp_job_assignments
	WHERE main_request_id = p_main_request_id;

	DELETE FROM pa_rp_job_assignments
	WHERE main_request_id = p_main_request_id;

	IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Check_Workers: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PA',p_msg_name=> 'PA_RP_GENERIC_MSG',p_msg_type=>Pa_Rp_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PA_RP_UTIL.Check_Workers');
	RAISE;
END Check_Workers;


/*
PROCEDURE Save_RP_Definition(p_rp_definition pa_rp_definition_all) IS
l_rp_id NUMBER;
l_dist_list_id NUMBER;
l_dist_list_items pa_rp_dist_list_items_tbl;
l_dist_list_item_id NUMBER;
BEGIN
	 l_rp_id := p_rp_definition.rp_id;
	 l_dist_list_id := p_rp_definition.dist_list_id;
	 l_dist_list_items := p_rp_definition.dist_list_items;
	 IF l_rp_id IS NULL THEN

	 	 --Insert RP_DEFINITION_First
		 l_rp_id := TO_NUMBER(SYSDATE,'j');
	     Pa_Distribution_Lists_Pkg.INSERT_ROW
	            (
	                P_LIST_ID => l_dist_list_id,
	                P_NAME => 'Reportin pack distribution list',
	                P_DESCRIPTION => l_rp_id,
	                P_RECORD_VERSION_NUMBER => NULL,
	                P_CREATED_BY =>	Fnd_Global.user_id,
	                P_CREATION_DATE => SYSDATE,
	                P_LAST_UPDATED_BY => Fnd_Global.user_id,
	                P_LAST_UPDATE_DATE => SYSDATE,
	                P_LAST_UPDATE_LOGIN => Fnd_Global.user_id
	            );


	     Pa_Object_Dist_Lists_Pkg.INSERT_ROW
	            (
	                P_LIST_ID => l_dist_list_id,
	                P_OBJECT_TYPE => 'PA_RP_LIST',
	                P_OBJECT_ID => l_rp_id,
	                P_RECORD_VERSION_NUMBER => NULL,
	                P_CREATED_BY =>	Fnd_Global.user_id,
	                P_CREATION_DATE => SYSDATE,
	                P_LAST_UPDATED_BY => Fnd_Global.user_id,
	                P_LAST_UPDATE_DATE => SYSDATE,
	                P_LAST_UPDATE_LOGIN => Fnd_Global.user_id
	            );
	 END IF;

     IF l_dist_list_items IS NOT NULL THEN

      FOR i IN l_dist_list_items.FIRST..l_dist_list_items.LAST
        LOOP

          IF l_dist_list_items(i).list_item_id IS NOT NULL THEN


              Pa_Dist_List_Items_Pkg.Update_Row
                (
                    P_LIST_ITEM_ID   => l_dist_list_items(i).list_item_id,
                    P_LIST_ID        => l_dist_list_id,
                    P_RECIPIENT_TYPE => l_dist_list_items(i).recipient_type,
                    P_RECIPIENT_ID   => l_dist_list_items(i).recipient_id,
                    P_ACCESS_LEVEL   => NULL,
                    P_MENU_ID        => NULL,
                    P_EMAIL          => l_dist_list_items(i).email_exists,
                    P_RECORD_VERSION_NUMBER => NULL,
                    P_LAST_UPDATED_BY   => Fnd_Global.user_id,
                    P_LAST_UPDATE_DATE  => SYSDATE,
                    P_LAST_UPDATE_LOGIN => Fnd_Global.user_id
                );

          ELSE

             -- call insert , set listItemId
                --DBMS_OUTPUT.put_line('... before insert in Pa_Dist_List_Items_Update_Row...insert row..');

                Pa_Dist_List_Items_Pkg.INSERT_ROW
                 (
				    P_LIST_ITEM_ID	=> l_dist_list_item_id,
                    P_LIST_ID        => l_dist_list_id,
                    P_RECIPIENT_TYPE => l_dist_list_items(i).recipient_type,
                    P_RECIPIENT_ID   => l_dist_list_items(i).recipient_id,
                    P_ACCESS_LEVEL   => NULL,
                    P_MENU_ID        => NULL,
                    P_EMAIL          => l_dist_list_items(i).email_exists,
                    P_RECORD_VERSION_NUMBER => NULL,
                    P_LAST_UPDATED_BY   => Fnd_Global.user_id,
                    P_LAST_UPDATE_DATE  => SYSDATE,
                    P_LAST_UPDATE_LOGIN => Fnd_Global.user_id,
                    P_CREATED_BY =>	Fnd_Global.user_id,
                    P_CREATION_DATE => SYSDATE
                 );


          END IF;

       END LOOP;

     END IF;

END;
*/

PROCEDURE Save_Params (p_main_request_id NUMBER
, p_rp_id NUMBER
, p_param_names SYSTEM.PA_VARCHAR2_240_TBL_TYPE
, p_param_values SYSTEM.PA_VARCHAR2_240_TBL_TYPE
, x_return_status IN OUT NOCOPY VARCHAR
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
l_i NUMBER;
BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Save_Params: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	FORALL l_i IN p_param_names.first..p_param_names.last
	INSERT INTO PA_RP_CONC_PARAMS(REQUEST_ID
		   						, RP_ID
								, PARAM_NAME
								, PARAM_VALUE
								 ,LAST_UPDATE_DATE
								, LAST_UPDATED_BY
								, CREATION_DATE
								, CREATED_BY
								, LAST_UPDATE_LOGIN)
							VALUES(p_main_request_id
								, p_rp_id
								, p_param_names(l_i)
								, p_param_values(l_i)
								, SYSDATE()
								, Fnd_Global.user_id
								, SYSDATE()
								, Fnd_Global.user_id
								, Fnd_Global.login_id);



	IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Save_Params: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PA',p_msg_name=> 'PA_RP_GENERIC_MSG',p_msg_type=>Pa_Rp_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PA_RP_UTIL.Save_Params');
	RAISE;
END Save_Params;


PROCEDURE Get_Email_Addresses (p_rp_id NUMBER
, p_project_id NUMBER
, x_email_addresses OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
l_email_list VARCHAR(4000);

CURSOR c_project_role_emails IS
  SELECT DISTINCT(p.email_address)
  FROM pa_object_dist_lists o,
  	   pa_dist_list_items i,
       pa_project_parties_v p,
       fnd_user u
  WHERE o.object_id = p_rp_id
  	AND o.list_id = i.list_id
    AND i.recipient_type = 'PROJECT_ROLE'
    AND p.project_role_id = i.recipient_id
    AND p.object_type = 'PA_PROJECTS'
    AND p.object_id = p_project_id
    AND u.user_name=p.user_name
    AND (TRUNC(SYSDATE) BETWEEN TRUNC(u.start_date) AND NVL(TRUNC(u.end_date),SYSDATE))
	AND (TRUNC(SYSDATE) BETWEEN TRUNC(p.start_date_active) AND NVL(TRUNC(p.end_date_active),SYSDATE));

BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Get_Email_Addresses: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;


	FOR l_email IN c_project_role_emails LOOP
		IF (trim(l_email.email_address) IS NOT NULL) THEN
		   l_email_list := l_email_list || l_email.email_address || ',';
		END IF;
	END LOOP;

	x_email_addresses := l_email_list;
	IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Get_Email_Addresses: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PA',p_msg_name=> 'PA_RP_GENERIC_MSG',p_msg_type=>Pa_Rp_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PA_RP_UTIL.Get_Email_Addresses');
	RAISE;
END Get_Email_Addresses;

PROCEDURE Derive_Proj_Params (p_project_id NUMBER
, p_calendar_type VARCHAR2
, p_currency_type VARCHAR2
, p_cstbudget2_plan_type_id NUMBER
, p_revbudget2_plan_type_id NUMBER
, p_report_period VARCHAR2
, p_spec_period_name VARCHAR2
, x_wbs_version_id OUT NOCOPY NUMBER
, x_wbs_element_id OUT NOCOPY  NUMBER
, x_rbs_version_id OUT NOCOPY  NUMBER
, x_rbs_element_id OUT NOCOPY  NUMBER
, x_calendar_id                  OUT NOCOPY NUMBER
, x_report_date           OUT NOCOPY NUMBER
, x_period_name                 OUT NOCOPY VARCHAR2
, x_period_id                 OUT NOCOPY NUMBER
, x_actual_version_id            OUT NOCOPY NUMBER
, x_cstforecast_version_id       OUT NOCOPY NUMBER
, x_cstbudget_version_id         OUT NOCOPY NUMBER
, x_cstbudget2_version_id        OUT NOCOPY NUMBER
, x_revforecast_version_id       OUT NOCOPY NUMBER
, x_revbudget_version_id         OUT NOCOPY NUMBER
, x_revbudget2_version_id        OUT NOCOPY NUMBER
, x_orig_cstbudget_version_id    OUT NOCOPY NUMBER
, x_orig_cstbudget2_version_id   OUT NOCOPY NUMBER
, x_orig_revbudget_version_id    OUT NOCOPY NUMBER
, x_orig_revbudget2_version_id   OUT NOCOPY NUMBER
, x_prior_cstforecast_version_id OUT NOCOPY NUMBER
, x_prior_revforecast_version_id OUT NOCOPY NUMBER
, x_cstforecast_plan_type_id	 OUT NOCOPY NUMBER
, x_cstbudget_plan_type_id		 OUT NOCOPY NUMBER
, x_revforecast_plan_type_id	 OUT NOCOPY NUMBER
, x_revbudget_plan_type_id		 OUT NOCOPY NUMBER
, x_currency_record_type_id         OUT NOCOPY NUMBER
, x_Currency_Code                OUT NOCOPY VARCHAR2
, x_period_start_date                  OUT NOCOPY NUMBER
, x_period_end_date                    OUT NOCOPY NUMBER
, x_project_type				 OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2)
IS
l_temp_id NUMBER;
l_i NUMBER;
l_plan_version_ids SYSTEM.PA_NUM_TBL_TYPE;
BEGIN
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Derive_Proj_Params: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	SELECT
	MAX(DECODE(ppfo.approved_cost_plan_type_flag, 'Y', fin_plan_type_id, -99)) pApprCostBudgetPTId,
	MAX(DECODE(ppfo.approved_rev_plan_type_flag, 'Y', fin_plan_type_id, -99)) pApprRevBudgetPTId,
	MAX(DECODE(ppfo.primary_cost_forecast_flag, 'Y', fin_plan_type_id, -99)) pPrimCostFcstPTId,
	MAX(DECODE(ppfo.primary_rev_forecast_flag, 'Y', fin_plan_type_id, -99)) pPrimRevFcstPTId
	INTO
	x_cstbudget_plan_type_id,
	x_revbudget_plan_type_id,
	x_cstforecast_plan_type_id,
	x_revforecast_plan_type_id
	FROM pa_proj_fp_options ppfo
	WHERE 1=1
	AND ppfo.project_id = p_project_id
	AND ppfo.fin_plan_option_level_code = 'PLAN_TYPE'
	AND 'Y' IN (ppfo.approved_cost_plan_type_flag
	, ppfo.approved_cost_plan_type_flag
	, ppfo.primary_cost_forecast_flag
	, ppfo.primary_rev_forecast_flag);
/*
	Pji_Rep_Util.Derive_Default_Plan_Type_Ids(p_project_id
		, x_cstforecast_plan_type_id
		, x_cstbudget_plan_type_id
		, l_temp_id
		, x_revforecast_plan_type_id
		, x_revbudget_plan_type_id
		, l_temp_id
		, x_return_status, x_msg_count, x_msg_data);
*/
	x_actual_version_id  := -1;

	SELECT
	MAX(DECODE(pbv.current_flag, 'Y', DECODE(x_cstbudget_plan_type_id, pbv.fin_plan_type_id, DECODE(version_type,'REVENUE',-99,pbv.budget_version_id), -99), -99)) pApprCostBudgetCurrPVId,
	MAX(DECODE(pbv.current_original_flag, 'Y', DECODE(x_cstbudget_plan_type_id, pbv.fin_plan_type_id, DECODE(version_type,'REVENUE',-99,pbv.budget_version_id), -99), -99)) pApprCostBudgetOrigPVId,
	MAX(DECODE(pbv.current_flag, 'Y', DECODE(x_revbudget_plan_type_id	, pbv.fin_plan_type_id, DECODE(version_type,'COST',-99,pbv.budget_version_id), -99), -99)) pApprRevBudgetCurrPVId,
	MAX(DECODE(pbv.current_original_flag, 'Y', DECODE(x_revbudget_plan_type_id	, pbv.fin_plan_type_id, DECODE(version_type,'COST',-99,pbv.budget_version_id), -99), -99)) pApprRevBudgetOrigPVId,
	MAX(DECODE(pbv.current_flag, 'Y', DECODE(x_cstforecast_plan_type_id, pbv.fin_plan_type_id, DECODE(version_type,'REVENUE',-99,pbv.budget_version_id), -99), -99)) pPrimCostFcstCurrPVId,
	MAX(DECODE(pbv.current_flag, 'Y', DECODE(x_revforecast_plan_type_id, pbv.fin_plan_type_id, DECODE(version_type,'COST',-99,pbv.budget_version_id), -99), -99)) pPrimRevFcstCurrPVId,
	MAX(DECODE(pbv.current_flag, 'Y', DECODE(p_cstbudget2_plan_type_id, pbv.fin_plan_type_id, DECODE(version_type,'REVENUE',-99,pbv.budget_version_id), -99), -99)) pCostCurrPVId,
	MAX(DECODE(pbv.current_original_flag, 'Y', DECODE(p_cstbudget2_plan_type_id, pbv.fin_plan_type_id, DECODE(version_type,'REVENUE',-99,pbv.budget_version_id), -99), -99)) pCostOrigPVId,
	MAX(DECODE(pbv.current_flag, 'Y', DECODE(p_revbudget2_plan_type_id, pbv.fin_plan_type_id, DECODE(version_type,'COST',-99,pbv.budget_version_id), -99), -99)) pRevCurrPVId,
	MAX(DECODE(pbv.current_original_flag, 'Y', DECODE(p_revbudget2_plan_type_id, pbv.fin_plan_type_id, DECODE(version_type,'COST',-99,pbv.budget_version_id), -99), -99)) pRevOrigPVId
	INTO
	x_cstbudget_version_id,
	x_orig_cstbudget_version_id,
	x_revbudget_version_id,
	x_orig_revbudget_version_id,
	x_cstforecast_version_id,
	x_revforecast_version_id,
	x_cstbudget2_version_id,
	x_orig_cstbudget2_version_id,
	x_revbudget2_version_id,
	x_orig_revbudget2_version_id
	FROM pa_budget_versions pbv
	WHERE 1=1
	AND pbv.project_id = p_project_id
	AND pbv.fin_plan_type_id IN ( x_cstbudget_plan_type_id
	, x_revbudget_plan_type_id
	, x_cstforecast_plan_type_id
	, x_revforecast_plan_type_id
	, p_cstbudget2_plan_type_id
	, p_revbudget2_plan_type_id)
	AND 'Y' IN (pbv.current_flag, pbv.current_original_flag)
	AND pbv.version_type IS NOT NULL;

	x_prior_cstforecast_version_id := Pa_Planning_Element_Utils.get_prior_forecast_version_id(x_cstforecast_version_id,p_project_id);
	x_prior_revforecast_version_id := Pa_Planning_Element_Utils.get_prior_forecast_version_id(x_revforecast_version_id,p_project_id);

/*


    Pji_Rep_Util.Derive_Plan_Version_Ids(p_project_id
		, x_cstforecast_plan_type_id
		, x_cstbudget_plan_type_id
		, p_cstbudget2_plan_type_id
		, x_revforecast_plan_type_id
		, x_revbudget_plan_type_id
		, p_revbudget2_plan_type_id
		, x_cstforecast_version_id
		, x_cstbudget_version_id
		, x_cstbudget2_version_id
		, x_revforecast_version_id
		, x_revbudget_version_id
		, x_revbudget2_version_id
		, x_orig_cstbudget_version_id
		, x_orig_cstbudget2_version_id
		, x_orig_revbudget_version_id
		, x_orig_revbudget2_version_id
		, x_prior_cstforecast_version_id
		, x_prior_revforecast_version_id
		, x_return_status, x_msg_count, x_msg_data);

	l_plan_version_ids := SYSTEM.PA_NUM_TBL_TYPE(
       -1
      , x_cstforecast_version_id
      , x_cstbudget_version_id
      , x_cstbudget2_version_id
      , x_revforecast_version_id
      , x_revbudget_version_id
      , x_revbudget2_version_id
      , x_orig_cstbudget_version_id
      , x_orig_cstbudget2_version_id
      , x_orig_revbudget_version_id
      , x_orig_revbudget2_version_id
      , x_prior_cstforecast_version_id
      , x_prior_revforecast_version_id);
*/

	  x_wbs_element_id := Pa_Project_Structure_Utils.GET_FIN_STRUCTURE_ID(p_project_id);
	  x_wbs_version_id := Pa_Project_Structure_Utils.GET_FIN_STRUC_VER_ID(p_project_id);
/*
	l_i := 1;
	WHILE l_i <= l_plan_version_ids.COUNT AND x_wbs_version_id IS NULL LOOP
		IF l_plan_version_ids(l_i) IS NOT NULL THEN
		    Pji_Rep_Util.Derive_Default_WBS_Parameters(p_project_id
		      , l_plan_version_ids(l_i)
		      , x_WBS_Version_ID, x_WBS_Element_Id
		      , x_return_status, x_msg_count, x_msg_data);
		END IF;
	  l_i := l_i+1;
	END LOOP;

*/
	IF x_wbs_version_id IS NULL THEN
	   x_wbs_version_id := -1;
	   x_wbs_element_id := -1;
	END IF;

	Pji_Rep_Util.Derive_Perf_RBS_Parameters(p_project_id
	 , l_temp_id
	 , 'N'
	 , x_RBS_Version_ID, x_RBS_Element_Id
	 , x_return_status, x_msg_count, x_msg_data);


	Pji_Rep_Util.Derive_Project_Type(p_project_id
	, x_project_type
	, x_return_status
	, x_msg_count
	, x_msg_data);


    Derive_Currency_Info(p_project_id, p_currency_type
      , x_currency_record_type_id, x_currency_code
      , x_return_status, x_msg_count, x_msg_data);

	Derive_Calendar_Info(p_project_id
	, p_report_period
	, p_calendar_type
	, p_spec_period_name
	, x_calendar_id
	, x_report_date
	, x_period_name
	, x_period_id
	, x_period_start_date
	, x_period_end_date
	, x_return_status
	, x_msg_count
	, x_msg_data
	);

	IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG( 'PA_RP_UTIL.Derive_Proj_Params: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	Add_Message(p_app_short_name=> 'PA',p_msg_name=> 'PA_RP_GENERIC_MSG',p_msg_type=>Pa_Rp_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'PA_RP_UTIL.Derive_Proj_Params');
	RAISE;
END Derive_Proj_Params;


PROCEDURE Derive_Currency_Info(
p_project_id NUMBER
, p_currency_type VARCHAR2
, x_currency_record_type OUT NOCOPY NUMBER
, x_currency_code OUT NOCOPY VARCHAR2
, x_return_status IN OUT NOCOPY  VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2) IS
l_proj_currency VARCHAR2(20);
l_projfunc_currency VARCHAR2(20);
BEGIN

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_currency_info: beginning', TRUE , g_proc);
	END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

	SELECT project_currency_code, projfunc_currency_code
	INTO l_proj_currency,l_projfunc_currency
	FROM pa_projects_all
	WHERE project_id = p_project_id;

	IF p_currency_type = 'PC' THEN
	   x_currency_record_type := 8;
	   x_currency_code := l_proj_currency;
	ELSE /* Default as project functional currency */
		 x_currency_record_type :=4;
		 x_currency_code := l_projfunc_currency;
	END IF;


	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'derive_currency_info: finishing', TRUE , g_proc);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_RP_Util.Derive_Currency_Info');
	RAISE;
END Derive_Currency_Info;



PROCEDURE Derive_Calendar_Info(p_project_id NUMBER
, p_report_period VARCHAR2
, p_calendar_type VARCHAR2
, p_spec_period_name VARCHAR2
, x_calendar_id OUT NOCOPY NUMBER
, x_report_date OUT NOCOPY NUMBER
, x_period_name OUT NOCOPY VARCHAR2
, x_period_id OUT NOCOPY NUMBER
, x_start_date OUT NOCOPY NUMBER
, x_end_date OUT NOCOPY NUMBER
, x_return_status IN OUT NOCOPY VARCHAR2
, x_msg_count IN OUT NOCOPY NUMBER
, x_msg_data IN OUT NOCOPY VARCHAR2
)
IS
l_active_rep VARCHAR2(30);
l_report_date DATE;
l_start_date DATE;
l_end_date DATE;
l_gl_calendar_id NUMBER;
l_pa_calendar_id NUMBER;
l_application_id NUMBER;
BEGIN
	Pa_Debug.init_err_stack('PA_RP_UTIL.Derive_Report_Period');
	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_Report_Period: begining', TRUE , g_proc);
	END IF;

	IF p_calendar_type = 'E' THEN
	   x_calendar_id := -1;
	ELSE
	   SELECT info.gl_calendar_id, info.pa_calendar_id
	   INTO l_gl_calendar_id, l_pa_calendar_id
	   FROM pji_org_extr_info info, pa_projects_all proj
	   WHERE info.org_id = proj.org_id
	   AND proj.project_id = p_project_id;

	   IF p_calendar_type = 'G' THEN
	      x_calendar_id := l_gl_calendar_id;
		  l_application_id := 101;
	   ELSE
	   	  x_calendar_id := l_pa_calendar_id;
		  l_application_id := 275;
	   END IF;
	END IF;

	l_active_rep := p_report_period;
	IF p_report_period IS NULL THEN
	   l_active_rep := 'CURRENT';
	END IF;

	IF p_calendar_type = 'E' THEN
		IF l_active_rep IN ('CURRENT','PRIOR') THEN
		   SELECT start_date
		   INTO l_report_date
		   FROM pji_time_ent_period_v
		   WHERE TRUNC(SYSDATE) BETWEEN start_date AND end_date;
		END IF;

		IF l_active_rep = 'PRIOR' THEN
			  SELECT MAX(start_date)
			  INTO l_report_date
			  FROM pji_time_ent_period_v
			  WHERE end_date <l_report_date;
		END IF;

		SELECT name, ent_period_id, start_date, end_date
		INTO x_period_name, x_period_id, l_start_date, l_end_date
		FROM pji_time_ent_period_v
		WHERE l_report_date BETWEEN start_date AND end_date;

	ELSE
		IF l_active_rep ='FIRST_OPEN' THEN
			SELECT MIN(TIM.start_date) first_open
			INTO l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations paimp
			WHERE 1=1
			AND TIM.calendar_id = x_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
			AND glps.application_id = l_application_id
			AND glps.period_name = TIM.NAME
			AND closing_status = 'O';
		ELSIF l_active_rep = 'LAST_OPEN' THEN
			SELECT MAX(TIM.start_date) last_open
			INTO l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations paimp
			WHERE 1=1
			AND TIM.calendar_id = x_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
			AND glps.application_id = 275
			AND glps.period_name = TIM.NAME
			AND closing_status = 'O';
		ELSIF l_active_rep = 'LAST_CLOSED' THEN
			SELECT MAX(TIM.start_date) last_closed
			INTO  l_report_date
			FROM
			pji_time_cal_period_v TIM
			, gl_period_statuses glps
			, pa_implementations paimp
			WHERE 1=1
			AND TIM.calendar_id = x_calendar_id
			AND paimp.set_of_books_id = glps.set_of_books_id
			AND glps.application_id = l_application_id
			AND glps.period_name = TIM.NAME
			AND closing_status = 'C';
		ELSIF l_active_rep IN ('CURRENT','PRIOR') THEN
			SELECT start_date
			INTO l_report_date
			FROM pji_time_cal_period_v
			WHERE TRUNC(SYSDATE) BETWEEN start_date
			AND end_date
			AND calendar_id = x_calendar_id;
		END IF;

		IF l_active_rep = 'PRIOR' THEN
			SELECT MAX(start_date)
			INTO l_report_date
			FROM pji_time_cal_period_v
			WHERE end_date < l_report_date
			AND calendar_id = x_calendar_id;
		END IF;

		if l_active_rep = 'SPECIFIC' then
			SELECT name, cal_period_id, start_date, end_date, start_date
			INTO x_period_name, x_period_id, l_start_date, l_end_date, l_report_date
			FROM pji_time_cal_period_v
			WHERE name = p_spec_period_name
			AND calendar_id = x_calendar_id;
		else
			SELECT name, cal_period_id, start_date, end_date
			INTO x_period_name, x_period_id, l_start_date, l_end_date
			FROM pji_time_cal_period_v
			WHERE l_report_date BETWEEN start_date AND end_date
			AND calendar_id = x_calendar_id;
		end if;

	END IF;

	x_report_date := TO_CHAR(l_report_date,'j');
	x_start_date := TO_CHAR(l_start_date,'j');
	x_end_date := TO_CHAR(l_end_date, 'j');

	IF g_debug_mode = 'Y' THEN
	   Pji_Utils.WRITE2LOG( 'Derive_Report_Period: finishing', TRUE , g_proc);
	END IF;


EXCEPTION
	WHEN NO_DATA_FOUND THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_SYSTEM_ERROR', p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'TOKEN_NAME',p_token1_value=>'CURRENT PERIOD');
	x_report_date :=2;
	WHEN OTHERS THEN
	x_msg_count := x_msg_count + 1;
	x_return_status := Fnd_Api.G_RET_STS_ERROR;
	Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_GENERIC_MSG',p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,p_token1=>'PROC_NAME',p_token1_value=>'Pji_Rep_Util.Derive_Report_Period');
	RAISE;
END Derive_Calendar_Info;

FUNCTION Get_Percent_Complete
( p_project_id NUMBER
, p_wbs_version_id NUMBER
, p_wbs_element_id NUMBER
, p_report_date_julian NUMBER
, p_calendar_type VARCHAR2 DEFAULT 'E'
, p_calendar_id NUMBER DEFAULT -1
) RETURN NUMBER IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_percent_complete NUMBER;
l_return_status VARCHAR2(255);
l_msg_count NUMBER;
l_msg_data VARCHAR2(255);
BEGIN
	Pji_Rep_Util.Derive_Percent_Complete
	( p_project_id
	, p_wbs_version_id
	, p_wbs_element_id
	, 'Y'
	, p_report_date_julian
	, 'FINANCIAL'
	, p_calendar_type
	, p_calendar_id
	, 'N'
	, l_percent_complete
	, l_return_status
	, l_msg_count
	, l_msg_data
	);
	--This will ensure there is no error for calling a DML statement from SQL
	COMMIT;
	RETURN l_percent_complete/100;
END;


FUNCTION Get_Task_Proj_Number
( p_project_id NUMBER
, p_proj_elem_id NUMBER
) RETURN VARCHAR IS
l_number VARCHAR(80);
BEGIN

	SELECT
		MAX(DECODE(ppe.object_type, 'PA_TASKS', ppe.element_number, ppa.segment1)) task_number
	INTO
		l_number
	FROM pa_proj_elements ppe, pa_projects_all ppa
	WHERE ppe.project_id = p_project_id
	AND ppa.project_id = ppe.project_id
	AND ppe.proj_element_id = p_proj_elem_id;

	RETURN l_number;
END;

END Pa_Rp_Util;

/
