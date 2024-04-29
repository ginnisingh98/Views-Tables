--------------------------------------------------------
--  DDL for Package Body PER_WPM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_WPM_DRT_PKG" AS
/* $Header: pewpmdrt.pkb 120.0.12010000.16 2018/07/17 12:18:15 mbhagwan noship $ */
/*
Data deleted from  below tables

	Performance
		per_objectives
		per_competence_elements
		per_assessments
		per_appraisals
		per_personal_scorecards
		HR_API_TRANSACTION_STEPS
		hr_api_transactions
		PER_QUALIFICATIONS
		PER_PERFORMANCE_RATINGS
		HR_API_TRANSACTION_VALUES

	Succession Planning
		per_succession_planning
		per_sp_successor_in_plan
		per_sp_successee_details

Validation on the following table for Performance
		per_appraisals
*/

  PROCEDURE add_to_results
    (person_id       IN     number
    ,entity_type	   IN			varchar2
    ,status 		     IN			varchar2
    ,msgcode		     IN			varchar2
    ,msgaplid		     IN			number
	  ,result_tbl    	 IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS
	n number(15);
  begin
   	n := result_tbl.count + 1;
    result_tbl(n).person_id := person_id;
    result_tbl(n).entity_type := entity_type;
    result_tbl(n).status := status;
    result_tbl(n).msgcode := msgcode;
    result_tbl(n).msgaplid := msgaplid;
  end add_to_results;

	PROCEDURE remove_notification(
	p_appraisal_id IN number
	)
	IS

		l_system_type varchar2(500);
		l_item_type varchar2(50);
		l_system_params varchar2(500);
		l_item_key varchar2(40);
		notif_id number;
		lv_result varchar2(30);


		Cursor appraisal_details
		IS
		select SYSTEM_TYPE,SYSTEM_PARAMS from
		per_appraisals
		where appraisal_id = p_appraisal_id ;


		cursor openNotifications
		is
		select NOTIFICATION_ID from wf_notifications
		where ITEM_KEY =l_item_key
		AND status = 'OPEN' ;


		BEGIN



		OPEN appraisal_details;
		Fetch appraisal_details into l_system_type,l_system_params;

		l_item_key := REGEXP_SUBSTR(REGEXP_SUBSTR(l_system_params, 'pItemKey\=([^;]+);?'), '[[:digit:]]+');
		l_item_type:= SUBSTR(REGEXP_SUBSTR(l_system_params, 'pItemType\=([^&]+)?'),11);

		hr_utility.trace ('l_item_key ' || l_item_key );
		hr_utility.trace ('l_system_type ' || l_system_type );
		hr_utility.trace ('l_item_type ' || l_item_type );

		       --hr_complete_appraisal_ss.complete_appr(l_item_type,l_item_key,lv_result);
					Open openNotifications;
					Fetch openNotifications into notif_id;
					--bug 27969878
					if openNotifications % found Then
						  wf_engine.abortprocess (l_item_type
						                         ,l_item_key
						                         ,NULL
						                         ,'eng_force');

					     wf_purge.items(l_item_type,l_item_key,sysdate,true,true,1);

					END IF;

					hr_utility.trace ('Notification is not found' );
					--UPDATE  per_appraisals
					--SET     appraisal_system_status = 'COMPLETED'
					--WHERE   appraisal_id = p_appraisal_id;

		hr_utility.trace ('Leaving remove_notification');
	END remove_notification;

	PROCEDURE remove_appraisals(
	V_PERSON_ID IN number
	)
	IS
		v_person_count number:=0;
		v_plan_id number;
		v_appraisal_id number;
		v_assessment_id number;
		v_scorecard_id number;
		v_assignment_id number;
		v_transaction_id number;
		v_supervisor_id number;
		v_appraisal_count number;
		v_transaction_step_id number;

		CURSOR c_person_count
		IS
			select count(*)
			from per_all_people_f
			where PERSON_ID = V_PERSON_ID;

		CURSOR c_get_appraisal_id
		IS
			select APPRAISAL_ID
			from per_appraisals
			where  appraisee_person_id = V_PERSON_ID;

		CURSOR c_get_assessment_id
		IS
			select assessment_id
			from per_assessments
			where APPRAISAL_ID=v_appraisal_id;


		CURSOR c_get_scorecard_id
		IS
			select SCORECARD_ID
			from per_personal_scorecards
			where
				PERSON_ID = V_PERSON_ID;

		CURSOR c_assignment_id
		IS
			select ASSIGNMENT_ID
		  from per_all_assignments_f
			where
				PERSON_ID = v_person_id;

		CURSOR c_transaction_id
		IS
			select TRANSACTION_ID
			from hr_api_transactions
			where
				ASSIGNMENT_ID = v_assignment_id;

		CURSOR c_supervisor_id
		IS
			select SUPERVISOR_ID
			from per_all_assignments_f
			where PERSON_ID = V_PERSON_ID and
			EFFECTIVE_START_DATE<sysdate and
			EFFECTIVE_END_DATE>sysdate;

		CURSOR c_appraisal_count
		IS
			select count(*)
			from per_appraisals
			where  APPRAISER_PERSON_ID=V_PERSON_ID;

		CURSOR c_get_trans_step_id
		IS
			select TRANSACTION_STEP_ID
			from HR_API_TRANSACTION_STEPS
			where TRANSACTION_ID=v_transaction_id;

		l_return_code varchar2(5);
    l_err_msg varchar2(25);

	BEGIN
		hr_utility.trace ('Entering remove_appraisals');
		OPEN c_person_count;
		FETCH  c_person_count into v_person_count;
		IF v_person_count > 0 THEN
			hr_utility.trace ('Starting removing  Person id =  ' || V_PERSON_ID );
			--removing appraisal data for standard and planned.
			OPEN c_get_appraisal_id;
			LOOP
					FETCH c_get_appraisal_id into v_appraisal_id;
					EXIT WHEN c_get_appraisal_id%NOTFOUND;
					hr_utility.trace ('Removing  Details for appraisal id =  ' || v_appraisal_id );
					IF v_appraisal_id IS NOT NULL
					THEN
						delete from per_objectives where APPRAISAL_ID=v_appraisal_id;
						hr_utility.trace ('All Objective Removed');

						OPEN c_get_assessment_id;
						LOOP
							FETCH c_get_assessment_id into v_assessment_id;
							EXIT WHEN c_get_assessment_id%NOTFOUND;
							hr_utility.trace ('Removing  Details for ASSESSMENT ID =  ' || v_assessment_id );
							delete from per_competence_elements where ASSESSMENT_ID=v_assessment_id;
						END LOOP;
						CLOSE c_get_assessment_id;
						hr_utility.trace ('All competence Removed');
						remove_notification( p_appraisal_id => v_appraisal_id);

						delete from per_assessments where APPRAISAL_ID=v_appraisal_id;
						hr_utility.trace ('Assessments Removed');

						delete from PER_PERFORMANCE_RATINGS where  APPRAISAL_ID=v_appraisal_id;
						hr_utility.trace ('PER_PERFORMANCE_RATINGS Removed');

						delete from per_appraisals where  APPRAISAL_ID=v_appraisal_id;
						hr_utility.trace ('Appraisals Removed');

					END IF;
					--Not removing scorecard here because some objective does not have apprisal which will be removed
			END LOOP;
			CLOSE c_get_appraisal_id;


			hr_utility.trace ('Removing Objectives by Scorecard');
			OPEN c_get_scorecard_id;
			LOOP
					FETCH c_get_scorecard_id into v_scorecard_id;
					EXIT WHEN c_get_scorecard_id%NOTFOUND;
					--deleting objective that does not have appraisal id.
					delete from per_objectives where SCORECARD_ID = v_scorecard_id;
					hr_utility.trace ('Objective deleted that has scorecard id='||v_scorecard_id);
					delete from per_personal_scorecards where SCORECARD_ID = v_scorecard_id;
					hr_utility.trace (' Scorecard id= '||v_scorecard_id||' deleted ');
			END LOOP;
			CLOSE c_get_scorecard_id;


			hr_utility.trace ('Removing Objective from Transection Table');

			OPEN c_assignment_id;
			LOOP
					FETCH c_assignment_id into v_assignment_id;
					EXIT WHEN c_assignment_id%NOTFOUND;
					OPEN c_transaction_id;
					LOOP
						hr_utility.trace('assignment id '||v_assignment_id);
						FETCH c_transaction_id into v_transaction_id;
						EXIT WHEN c_transaction_id%NOTFOUND;
							OPEN c_get_trans_step_id;
							LOOP
								FETCH c_get_trans_step_id into v_transaction_step_id;
								EXIT WHEN c_get_trans_step_id%NOTFOUND;
								hr_utility.trace('v_transaction_step_id   '||v_transaction_step_id);
								delete from HR_API_TRANSACTION_VALUES where TRANSACTION_STEP_ID=v_transaction_step_id;
							END LOOP;
							CLOSE c_get_trans_step_id;

						delete from HR_API_TRANSACTION_STEPS where TRANSACTION_ID = v_transaction_id;
					END LOOP;
					CLOSE c_transaction_id;
					delete from hr_api_transactions where ASSIGNMENT_ID=v_assignment_id;
			END LOOP;
			CLOSE c_assignment_id;

			hr_utility.trace ('Reinitializing Supervisor ID');
			OPEN c_appraisal_count;
				FETCH c_appraisal_count into v_appraisal_count;
				IF v_appraisal_count > 0
				THEN
					OPEN c_supervisor_id;
					FETCH c_supervisor_id into v_supervisor_id;

						UPDATE per_appraisals
						SET APPRAISER_PERSON_ID= v_supervisor_id
						WHERE APPRAISER_PERSON_ID=V_PERSON_ID;

						UPDATE per_appraisals
						SET MAIN_APPRAISER_ID= v_supervisor_id
						WHERE MAIN_APPRAISER_ID=V_PERSON_ID;

						UPDATE per_perf_mgmt_plans
						SET SUPERVISOR_ID= v_supervisor_id
						WHERE SUPERVISOR_ID=V_PERSON_ID;

						UPDATE per_participants
						SET PERSON_ID= v_supervisor_id
						WHERE PERSON_ID=V_PERSON_ID;

					CLOSE c_supervisor_id;
				END IF;
			CLOSE c_appraisal_count;

			hr_utility.trace ('Deleting Qualification for Person ID :'|| V_PERSON_ID);
			delete from PER_QUALIFICATIONS where PERSON_ID = V_PERSON_ID;

			--commented the below two lines 28355716
			--hr_utility.trace ('Deleting Performace rating for Person ID :'|| V_PERSON_ID);
			--delete from PER_PERFORMANCE_RATINGS where PERSON_ID = V_PERSON_ID;

		ELSE
				hr_utility.trace ('Person ID :'|| V_PERSON_ID ||' does not Exsist ');
		END IF;
		CLOSE c_person_count;
		l_err_msg := 'PER_WPM_REM_ERR';
			hr_utility.trace ('Leaving remove_appraisals');
		EXCEPTION
    WHEN others THEN
      hr_utility.trace ('Error in appraisal DRC');
      hr_utility.trace (sqlerrm);
      hr_utility.trace (dbms_utility.format_error_backtrace);
			l_err_msg := 'PER_WPM_REM_ERR';
	END remove_appraisals;


	PROCEDURE APPRAISALS_DRC(
			person_id number,
			p_result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type
			) IS
		v_main_appraisal_count number:=0;
		CURSOR c_main_appraisal_count
			IS
				select count(*)
				from per_appraisals
				where MAIN_APPRAISER_ID = person_id;
		l_return_code varchar2(5);
    l_err_msg varchar2(25);
	BEGIN
		hr_utility.trace ('Entering APPRAISALS_DRC');
		OPEN c_main_appraisal_count;
		FETCH c_main_appraisal_count into v_main_appraisal_count;
		CLOSE c_main_appraisal_count;

		IF v_main_appraisal_count > 0 THEN
			add_to_results (person_id      => person_id
                      ,entity_type    => 'HR'
                      ,status         => 'E'
                      ,msgcode        => 'PER_WPM_DRC_ERR'
                      ,msgaplid       => 800
                      ,result_tbl     => p_result_tbl);
		ELSE
			 add_to_results (person_id      => person_id
                      ,entity_type    => 'HR'
                      ,status         => 'S'
                      ,msgcode        => null
                      ,msgaplid       => null
                      ,result_tbl     => p_result_tbl);
		END IF;

		hr_utility.trace ('Leaving APPRAISALS_DRC');
		EXCEPTION
    WHEN others THEN
      hr_utility.trace ('Error in appraisal DRC');
      hr_utility.trace (sqlerrm);
      hr_utility.trace (dbms_utility.format_error_backtrace);

      add_to_results (person_id      => person_id
                      ,entity_type    => 'HR'
                      ,status         => 'E'
                      ,msgcode        => 'PER_WPM_DRC_ERR'
                      ,msgaplid       => 800
                      ,result_tbl     => p_result_tbl);

			hr_utility.trace ('Leaving APPRAISALS_DRC');
	END APPRAISALS_DRC;


	PROCEDURE remove_succ_plan(
	V_DEL_PERSON_ID IN number
	)
	IS
		TAB_NOT_FOUND      EXCEPTION;
		PRAGMA EXCEPTION_INIT(TAB_NOT_FOUND, -942);
	BEGIN
				hr_utility.trace ('Entering remove_succ_plan');

				BEGIN
					EXECUTE IMMEDIATE 'delete from per_succession_planning where PERSON_ID = :1' using V_DEL_PERSON_ID;
					EXECUTE IMMEDIATE 'delete from per_succession_planning where SUCCESSEE_PERSON_ID = :1' using V_DEL_PERSON_ID;
				EXCEPTION
					WHEN TAB_NOT_FOUND THEN
					null;
				END;

				BEGIN
					EXECUTE IMMEDIATE 'delete from per_sp_successor_in_plan where SUCCESSOR_ID = :1' using V_DEL_PERSON_ID;
					EXECUTE IMMEDIATE 'delete from per_sp_successor_in_plan where SUPERVISOR_ID = :1' using V_DEL_PERSON_ID;
				EXCEPTION
					WHEN TAB_NOT_FOUND THEN
					null;
				END;

				BEGIN
					EXECUTE IMMEDIATE 'delete from per_sp_successee_details where SUCCESSEE_ID = :1' using V_DEL_PERSON_ID;
				EXCEPTION
					WHEN TAB_NOT_FOUND THEN
					null;
				END;

				hr_utility.trace('All data has been purge for Person id:' || V_DEL_PERSON_ID );
			  hr_utility.trace ('Leaving remove_succ_plan');
		EXCEPTION
    WHEN others THEN
      hr_utility.trace ('Error in succession planing DRC');
      hr_utility.trace (sqlerrm);
      hr_utility.trace (dbms_utility.format_error_backtrace);

		 hr_utility.trace ('Leaving remove_succ_plan');
	END remove_succ_plan;

	PROCEDURE PER_WPM_HR_DRC(
		person_id number,
		p_result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type
		)	is
		begin
			APPRAISALS_DRC(person_id,p_result_tbl);
	END PER_WPM_HR_DRC;

	PROCEDURE PER_WPM_HR_POST(
		person_id number
		)	is
		begin
			remove_appraisals(person_id);
			remove_succ_plan(person_id);
		END PER_WPM_HR_POST;
END PER_WPM_DRT_PKG;

/
