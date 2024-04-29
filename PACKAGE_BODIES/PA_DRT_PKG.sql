--------------------------------------------------------
--  DDL for Package Body PA_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DRT_PKG" AS
/* $Header: PADRTPB.pls 120.0.12010000.25 2018/07/17 12:41:55 kukonda noship $ */

g_package  varchar2(33) := 'PA_DRT_DRC.';
P_PA_DEBUG_MODE  VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


  PROCEDURE pa_hr_drc
    (p_person_id     IN number
	,result_tbl      OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE)
	IS

  l_dummy                   varchar2(20);
  --result_tbl 			    PER_DRT_PKG.RESULT_TBL_TYPE;

  BEGIN

    IF P_PA_DEBUG_MODE = 'Y' THEN
	  PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', '10 - Entering pa_hr_drc',1);
    END IF;

	IF P_PA_DEBUG_MODE = 'Y' THEN
	  PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'p_person_id: '||p_person_id, 1);
    END IF;

    /*PROJ-01) Person shouldn't be active team member in any project */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pa_project_parties ppp, pa_projects_all ppa, pa_project_statuses pps
               WHERE ppp.resource_source_id = p_person_id
			     AND ppp.project_id = ppa.project_id
				 AND ppa.project_status_code = pps.project_status_code
				 AND pps.status_type = 'PROJECT'
				 AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND (TRUNC(sysdate) < ppp.start_date_active OR TRUNC(sysdate) BETWEEN ppp.start_date_active
                                        AND NVL(ppp.end_date_active, sysdate)));

	EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_KEY_MEMBER_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_KEY_MEMBER_ERROR', 1);
            END IF;

    END;

    /*PROJ-02) Person shouldn't be part of any active PJR staffed assignments */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
	           SELECT NULL FROM pa_project_assignments asgn, pa_resources_denorm res--, pa_projects_all pa
                WHERE res.person_id = p_person_id
                  AND asgn.resource_id = res.resource_id
                  AND res.schedulable_flag  = 'Y'
                  AND asgn.assignment_type IN ('STAFFED_ASSIGNMENT', 'STAFFED_ADMIN_ASSIGNMENT')
--                  AND asgn.start_date BETWEEN res.resource_effective_start_date AND res.resource_effective_end_date
				  AND (TRUNC(sysdate) < asgn.start_date OR TRUNC(sysdate) BETWEEN asgn.start_date
                                        AND NVL(asgn.end_date, sysdate))
                  AND asgn.apprvl_status_code <> 'ASGMT_APPRVL_CANCELED');

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_PJR_ASGMNTS_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_PJR_ASGMNTS_ERROR', 1);
            END IF;
    END;


    /*PROJ-03) Person shouldn't be part of any Work plan or financial plan assignements */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS(
		         SELECT NULL
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_project_statuses pps, pa_projects_all pa
				  WHERE pa.project_id = bv.project_id
				    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND pa.project_id = ra.project_id
				    AND bv.budget_version_id = ra.budget_version_id
					AND (trunc(sysdate) < ra.planning_start_date or (trunc(sysdate) between ra.planning_start_date and ra.planning_end_date))
					AND (bv.budget_type_code IS NULL AND bv.fin_plan_type_id > 10)
					AND ((bv.budget_status_code = 'B' AND bv.current_flag = 'Y') or (bv.budget_status_code = 'W'))
					AND ra.person_id = p_person_id
				 UNION
		         SELECT NULL
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_resource_list_members rlm,
				        pa_project_statuses pps, pa_projects_all pa
				  WHERE pa.project_id = bv.project_id
				    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND pa.project_id = ra.project_id
				    AND bv.budget_version_id = ra.budget_version_id
					AND bv.budget_type_code is NOT NULL
					AND ((bv.budget_status_code = 'B' AND bv.current_flag = 'Y') or (bv.budget_status_code = 'W'))
                    AND exists (select 1 from pa_budget_lines bl where bl.resource_assignment_id = ra.resource_assignment_id
                          and ( (trunc(sysdate) < start_date) OR (trunc(sysdate) between start_date and end_date) ))
					AND bv.resource_list_id = rlm.resource_list_id
                    AND rlm.resource_list_member_id = ra.resource_list_member_id
					AND rlm.person_id = p_person_id
                 UNION
		         SELECT /*+ index(bv PA_BUDGET_VERSIONS_U1) */ NULL                                 -- Latest Publised workplan
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_tasks t, pa_proj_elements ele,
				        pa_project_statuses ps, pa_project_statuses pps, pa_projects_all pa
				  WHERE pa.project_id = t.project_id
				    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND ps.status_type = 'TASK'
				    AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED')
                    AND ele.proj_element_id = t.task_id
                    AND ele.status_code = ps.project_status_code
                    AND pa.project_id = bv.project_id
                    AND pa.project_id = ra.project_id
                    AND t.task_id = ra.task_id
				    AND bv.budget_version_id = ra.budget_version_id
					AND bv.fin_plan_type_id = 10
					AND bv.project_structure_version_id = PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(bv.project_id)
					AND ra.person_id = p_person_id
				  UNION
		         SELECT /*+ index(bv PA_BUDGET_VERSIONS_U1) */ NULL                                 -- Current Working workplan
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_tasks t, pa_proj_elements ele,
				        pa_project_statuses ps, pa_project_statuses pps, pa_projects_all pa
				  WHERE pa.project_id = t.project_id
				    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND ps.status_type = 'TASK'
				    AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED')
                    AND ele.proj_element_id = t.task_id
                    AND ele.status_code = ps.project_status_code
                    AND pa.project_id = bv.project_id
                    AND pa.project_id = ra.project_id
                    AND t.task_id = ra.task_id
				    AND bv.budget_version_id = ra.budget_version_id
					AND bv.fin_plan_type_id = 10
					AND bv.project_structure_version_id = PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(bv.project_id)
--					AND bv.current_flag = 'Y'
					AND ra.person_id = p_person_id
				  UNION
		         SELECT NULL                                 -- For 12.2.3 fix where task details are not sync
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_proj_elements ele,
                        pa_project_statuses ps, pa_project_statuses pps, pa_projects_all pa
                  WHERE pa.project_id = ele.project_id
                    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND ps.status_type = 'TASK'
                    AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED')
                    AND ele.status_code = ps.project_status_code
                    AND pa.project_id = bv.project_id
                    AND pa.project_id = ra.project_id
                    AND ele.proj_element_id = ra.task_id
                    AND bv.budget_version_id = ra.budget_version_id
                    AND bv.fin_plan_type_id = 10
                    AND (bv.project_structure_version_id = PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(bv.project_id)
                         OR bv.project_structure_version_id = PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(bv.project_id))
                    AND ra.person_id = p_person_id);


    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_RES_ASGNMNTS_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_RES_ASGNMNTS_ERROR', 1);
            END IF;
    END;

    /*PROJ-04) Person shouldn't be an active resource list member in any PRL */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
		       SELECT NULL FROM pa_resource_list_members rlm, pa_resource_lists_all_bg prl
		        WHERE prl.resource_list_id = rlm.resource_list_id
				  AND prl.control_flag = 'Y'
				  AND rlm.person_id = p_person_id
		          AND rlm.enabled_flag = 'Y'
			   UNION
               SELECT NULL
                 FROM pa_resource_list_members rlm, pa_resource_lists_all_bg prl
                WHERE prl.resource_list_id = rlm.resource_list_id
                  AND prl.control_flag  = 'N'
                  AND rlm.person_id = p_person_id
                  AND rlm.enabled_flag = 'Y'
                  AND rlm.object_type <> 'PROJECT'
               UNION
               SELECT NULL
                FROM pa_resource_list_members rlm, pa_resource_lists_all_bg prl, pa_projects_all pa,
                     pa_project_statuses ps, pa_resource_assignments ra
               WHERE prl.resource_list_id = rlm.resource_list_id
                 AND prl.control_flag = 'N'
                 AND rlm.person_id  = p_person_id
                 AND rlm.object_type = 'PROJECT'
                 AND rlm.enabled_flag = 'Y'
                 AND pa.project_status_code = ps.project_status_code
                 AND ps.status_type = 'PROJECT'
                 AND ps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND pa.project_id = ra.project_id
                 AND ra.resource_list_member_id  = rlm.resource_list_member_id);

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_RLM_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_RLM_ERROR', 1);
            END IF;

    END;

    /*PROJ-05) Person shouldn't be part of any RBS */
	BEGIN
	     SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
		      SELECT NULL
			    FROM PA_RBS_ELEMENTS
			   WHERE person_id = p_person_id
                 AND user_created_flag = 'Y'   -- Instance based RBS
                 AND rbs_version_id IN (SELECT rbs_version_id FROM pa_rbs_versions_b
                                         WHERE ((status_code = 'FROZEN' AND current_reporting_flag = 'Y')
                                                 OR status_code = 'WORKING')));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_RBS_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_RBS_ERROR', 1);
            END IF;
    END;

 	 /*PROJ-07) Person shouldn't be part of any unimported line in the transaction interface tables*/
	BEGIN
         SELECT NULL
	       INTO l_dummy
          FROM sys.dual
		 WHERE NOT EXISTS (SELECT NULL from PA_TRANSACTION_INTERFACE_ALL TXN
                            WHERE (TXN.PERSON_ID = p_person_id
                                    OR TXN.EMPLOYEE_NUMBER = PA_UTILS3.GetEmpNum(p_person_id, TXN.expenditure_item_date))
                            AND TXN.TRANSACTION_STATUS_CODE in ('P','R'));

    EXCEPTION
	when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_INT_HR_TXN_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_INT_HR_TXN_ERROR', 1);
            END IF;

    END;

     /*PROJ-08) Person shouldn't be part of any task that has an end date lesser than sysdate	*/
	 /*PROJ-08) Person shouldn't be part of any task that has an end date lesser than sysdate And Task status is not "Completed" */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pa_tasks t, pa_proj_elements ele, pa_project_statuses ps,
				     pa_project_statuses pps, pa_projects_all pa
               WHERE pa.project_id = t.project_id
                 AND pa.project_status_code = pps.project_status_code
                 AND pps.status_type = 'PROJECT'
                 AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
			     AND t.task_manager_person_id = p_person_id
			     AND t.task_id = ele.proj_element_id
			     --AND TRUNC(sysdate) > NVL(t.completion_date, sysdate)
				 AND ele.status_code = ps.project_status_code
				 AND ps.status_type = 'TASK'
				 AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED')
		      UNION
              SELECT NULL
                FROM pa_tasks t, pa_proj_elements ele, pa_proj_element_versions pevs,
                     pa_proj_elem_ver_schedule ppevs, pa_project_statuses ps,
                     pa_project_statuses pps, pa_projects_all pa
               WHERE pa.project_id = t.project_id
                 AND pa.project_status_code = pps.project_status_code
                 AND pps.status_type = 'PROJECT'
                 AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND t.task_manager_person_id = p_person_id
				 AND pa.project_id = ele.project_id
				 AND pa.project_id = pevs.project_id
                 AND t.task_id = ele.proj_element_id
                 AND t.task_id = pevs.proj_element_id
                 AND ele.status_code = ps.project_status_code
                 AND ppevs.element_version_id = pevs.element_version_id
                 AND ((trunc(sysdate) < nvl(PPEVS.SCHEDULED_START_DATE,sysdate))
				      OR (trunc(sysdate) between nvl(PPEVS.SCHEDULED_START_DATE,sysdate) and nvl(PPEVS.SCHEDULED_FINISH_DATE,sysdate)))
                 AND ps.status_type = 'TASK'
                 AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED')
		      UNION
              SELECT NULL
			    FROM pa_proj_elements ele, pa_project_statuses ps, pa_project_statuses pps, pa_projects_all pa
               WHERE pa.project_id = ele.project_id
                 AND pa.project_status_code = pps.project_status_code
                 AND pps.status_type = 'PROJECT'
                 AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND ele.manager_person_id = p_person_id
                 AND ele.status_code = ps.project_status_code
                 AND ps.status_type = 'TASK'
                 AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED'));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TASK_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_TASK_ERROR', 1);
            END IF;
    END;


     /*PROJ-09) Person shouldn't have any open actions assigned from Issues (control Items)	*/
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (SELECT NULL
                              FROM PA_PROJECTS_ALL PPA
                                  ,PA_PROJECT_STATUSES PPS
                                  ,PA_CONTROL_ITEMS PCI
                                  ,PA_CI_ACTIONS PAC
                                  ,HZ_PARTIES HP
                                  ,PA_CI_TYPES_B PCTB
                             WHERE PAC.ASSIGNED_TO = HP.PARTY_ID
                               AND HP.PERSON_IDENTIFIER = to_char(p_person_id)
                               AND PPA.PROJECT_STATUS_CODE = PPS.PROJECT_STATUS_CODE
       			               AND PPS.STATUS_TYPE = 'PROJECT'
                               AND PPS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                               AND PAC.STATUS_CODE = 'CI_ACTION_OPEN'
                               AND PCI.CI_ID = PAC.CI_ID
                               AND PCTB.CI_TYPE_CLASS_CODE = 'ISSUE'
                               AND PCTB.CI_TYPE_ID = PCI.CI_TYPE_ID
                               AND PPA.PROJECT_ID = PCI.PROJECT_ID
                               AND PCI.STATUS_CODE IN (SELECT PROJECT_STATUS_CODE
                                                         FROM PA_PROJECT_STATUSES
                                                        WHERE STATUS_TYPE = 'CONTROL_ITEM'
                                                          AND PROJECT_SYSTEM_STATUS_CODE IN ('CI_REJECTED', 'CI_APPROVED', 'CI_WORKING', 'CI_DRAFT', 'CI_SUBMITTED')));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PA_DRT_HR_ISSUE_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_ISSUE_ERROR', 1);
            END IF;

	END;


 	 /*PROJ-26) HR Person shouldn't be part of any open control items like Issues, Change orders and Change requests */
	 /* Clarfy what is means tobe part of. HOw are they associated? Update msg ? */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM PA_CONTROL_ITEMS PCI
                    ,PA_PROJECTS_ALL PPA
                    ,PA_PROJECT_STATUSES PPS
                    ,PA_CI_TYPES_B PCTB
                    ,HZ_PARTIES HZP
					,PA_PROJECT_STATUSES PS
               WHERE PPS.STATUS_TYPE   = 'CONTROL_ITEM'
               AND PCI.STATUS_CODE   = PPS.PROJECT_STATUS_CODE
               AND PCI.CI_TYPE_ID    = PCTB.CI_TYPE_ID
               AND PCTB.CI_TYPE_CLASS_CODE in ('ISSUE', 'CHANGE_ORDER', 'CHANGE_REQUEST')
               AND HZP.PARTY_ID = PCI.OWNER_ID
               AND HZP.PERSON_IDENTIFIER = to_char(p_person_id)
			   AND PPA.PROJECT_ID = PCI.PROJECT_ID
               AND PPA.PROJECT_STATUS_CODE = PS.PROJECT_STATUS_CODE
			   AND PS.STATUS_TYPE = 'PROJECT'
               AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
               AND PCI.STATUS_CODE IN (SELECT PROJECT_STATUS_CODE
                                         FROM PA_PROJECT_STATUSES
                                        WHERE STATUS_TYPE = 'CONTROL_ITEM'
                                          AND PROJECT_SYSTEM_STATUS_CODE IN ('CI_REJECTED', 'CI_APPROVED', 'CI_WORKING', 'CI_DRAFT', 'CI_SUBMITTED')));
    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PA_DRT_HR_CHANGE_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_CHANGE_ERROR', 1);
            END IF;

	END;


     /*PROJ-16) HR Person shouldn't be a part of unreleased pre-approved batches */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pa_expenditures_all e
            WHERE  EXPENDITURE_STATUS_CODE IN ('WORKING','SUBMITTED')
				 AND e.incurred_by_person_id = p_person_id);


    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TXN_HR_BATCH_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_TXN_HR_BATCH_ERROR', 1);
            END IF;

    END;

     /*PROJ-17) HR Person shouldn't be a part of uncosted transactions */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pa_expenditure_items_all exp, pa_expenditures_all e
               WHERE exp.expenditure_id = e.expenditure_id
				 AND e.incurred_by_person_id = p_person_id
				 AND exp.cost_distributed_flag = 'N');
    EXCEPTION
	when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_UNCOST_TXN_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_UNCOST_TXN_ERROR', 1);
            END IF;
	END;

	 /* PROJ-18) HR Person shouldn't be a part of unaccounted transactions */
    	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (select NULL from pa_expenditure_items_all ei, pa_expenditures_all e, pa_cost_distribution_lines_all cdl
                             where ei.EXPENDITURE_ID = e.EXPENDITURE_ID
                               and e.incurred_by_person_id = p_person_id
                               and cdl.EXPENDITURE_ITEM_ID = ei.EXPENDITURE_ITEM_ID
                               and cdl.TRANSFER_STATUS_CODE not in ('A','V','G','B'));

    EXCEPTION
	when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_UNACC_TXN_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_UNACC_TXN_ERROR', 1);
            END IF;
	END;

     /*PROJ-10) HR Person or Person Supplier shouldn't be a part of any billable transactions which are not billed yet or bill on hold */
	 /* PA_PROJ_UNBILLED_EXPEND_VIEW is a view that displays billable expenditure items that are unbilled.  You can review the unbilled
        expenditure items for your projects using this view. */

	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pa_expenditure_items_all exp, pa_expenditures_all e
               WHERE exp.expenditure_id = e.expenditure_id
			     AND exp.cost_distributed_flag = 'Y'
				 AND e.incurred_by_person_id = p_person_id                               -- HR person validation
                 AND (exp.billable_flag = 'Y' or exp.bill_hold_flag = 'Y')
				 AND exp.event_num is null
				 AND (exp.revenue_distributed_flag = 'N' or EXISTS (SELECT 1 FROM pa_cust_rev_dist_lines_all crdl
                             WHERE exp.expenditure_item_id = crdl.expenditure_item_id
                               AND crdl.draft_invoice_num is NULL)));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_BILL_TXN_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_BILL_TXN_ERROR', 1);
            END IF;
    END;

    /*PROJ-06) Person shouldn't be part of any Uninterfaced draft invoice line */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
	          SELECT NULL
			    FROM pa_draft_invoices_all dinv
				   , pa_cust_rev_dist_lines_all crdl
               WHERE dinv.transfer_status_code in ('P', 'T')
			     AND dinv.project_id = crdl.project_id
                 AND crdl.expenditure_item_id IN (SELECT exp.expenditure_item_id
                                                    FROM pa_expenditure_items_all exp,
                                                         pa_expenditures_all e
                                                   WHERE exp.expenditure_id    = e.expenditure_id
                                                     AND e.incurred_by_person_id = p_person_id
                                                     AND exp.cost_distributed_flag = 'Y'));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_DINV_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_DINV_ERROR', 1);
            END IF;

    END;

	 /* PROJ-29) Person should not be a credit receiver */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
               SELECT NULL
                 FROM PA_CREDIT_RECEIVERS c,
                      gms_awards_all a
                WHERE c.project_id = a.award_project_id
                  AND a.status <> 'CLOSED'
                  AND (c.end_date_active is null or c.end_date_active >= sysdate)
                  AND c.person_id = p_person_id);


    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_CRRECV_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_CRRECV_ERROR', 1);
            END IF;

	END;

	 /* PROJ-29-01) Person should not be a project credit receiver */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
               SELECT NULL
                 FROM PA_CREDIT_RECEIVERS pc,
                      pa_projects_all pa, pa_project_statuses ps
                WHERE pc.project_id = pa.project_id
                  AND pa.pm_product_code <> 'GMS'
                  AND pa.project_status_code = ps.project_status_code
                  AND ps.status_type = 'PROJECT'
                  AND ps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                  AND (pc.end_date_active is null or pc.end_date_active >= sysdate)
                  AND pc.person_id = p_person_id);

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_PROJ_CRRECV_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_PROJ_CRRECV_ERROR', 1);
            END IF;

	END;


	 /* PROJ-32) Person shouldn't be an active deliverable owner of an active task of an active project */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
               SELECT NULL
                 FROM PA_DELIVERABLES_V DEL,
				      PA_PROJECT_STATUSES DS,
					  PA_PROJECTS_ALL PPA,
					  PA_PROJECT_STATUSES PS
                WHERE DS.STATUS_TYPE = 'DELIVERABLE'
                  AND DEL.DELIVERABLE_SYSTEM_STATUS_CODE = DS.PROJECT_SYSTEM_STATUS_CODE
				  AND ((DS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('DLVR_CANCELLED', 'DLVR_COMPLETED')
                         AND DEL.completion_date IS NULL or (TRUNC(sysdate) < DEL.completion_date))
                    OR (DS.PROJECT_SYSTEM_STATUS_CODE IN ('DLVR_ON_HOLD') AND TRUNC(sysdate) > DEL.completion_date))
                  --AND (DEL.completion_date IS NULL or (TRUNC(sysdate) < DEL.completion_date))
                  AND PPA.PROJECT_ID = DEL.PROJECT_ID
                  AND PS.STATUS_TYPE = 'PROJECT'
                  AND PPA.PROJECT_STATUS_CODE = PS.PROJECT_STATUS_CODE
                  AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                  AND DEL.MANAGER_PERSON_ID = p_person_id);
    EXCEPTION
    WHEN NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_DEL_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_DEL_ERROR', 1);
            END IF;

    END;

	 /* PROJ-33) Person shouldn't be an active deliverable action owner of an active task of an active project */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
               SELECT NULL
                 FROM PA_DLVR_ACTIONS_V DEL,
				      PA_PROJECT_STATUSES DS,
					  PA_PROJECTS_ALL PPA,
					  PA_PROJECT_STATUSES PS
                WHERE DS.STATUS_TYPE = 'DELIVERABLE'
				  AND DEL.OBJECT_TYPE = 'PA_ACTIONS'
                  AND DEL.ACTION_STATUS_CODE = DS.PROJECT_SYSTEM_STATUS_CODE
                  AND DS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('DLVR_CANCELLED', 'DLVR_COMPLETED')
                  AND (DEL.actual_finish_date IS NULL or (TRUNC(sysdate) < DEL.actual_finish_date))
                  AND PPA.PROJECT_ID = DEL.PROJECT_ID
                  AND PS.STATUS_TYPE = 'PROJECT'
                  AND PPA.PROJECT_STATUS_CODE = PS.PROJECT_STATUS_CODE
                  AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                  AND DEL.MANAGER_PERSON_ID = p_person_id);
     EXCEPTION
     WHEN NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PA_DRT_HR_DACT_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_DACT_ERROR', 1);
            END IF;

    END;


	 /* PROJ-36) Person Shouldn't be an active Staffing Owner */
    BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
		  WHERE NOT EXISTS (
              SELECT NULL
               FROM pa_project_parties pp
                   ,per_all_people_f res
              WHERE pp.project_role_id = 8
                AND TRUNC(sysdate) between TRUNC(pp.start_date_active) and TRUNC(nvl(pp.end_date_active, sysdate))
                AND pp.resource_source_id = res.person_id
				AND res.person_id = p_person_id
		  UNION
		  SELECT NULL
               FROM pa_project_assignments asg, pa_projects_all ppa, pa_project_statuses pps, pa_project_statuses ps
              WHERE ppa.project_status_code = pps.project_status_code
                AND pps.status_type = 'PROJECT'
                AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED','PARTIALLY_PURGED')
                AND asg.project_id = ppa.project_id
                AND asg.staffing_owner_person_id = p_person_id
                AND (TRUNC(sysdate) < asg.start_date OR TRUNC(sysdate) BETWEEN asg.start_date AND NVL(asg.end_date, sysdate))
                AND asg.status_code = ps.project_status_code
                AND ps.status_type in ('OPEN_ASGMT', 'STAFFED_ASGMT')
                AND ps.project_system_status_code NOT IN ('OPEN_ASGMT_FILLED', 'OPEN_ASGMT_CANCEL', 'STAFFED_ASGMT_CANCEL'));

     EXCEPTION
     WHEN NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'W'
 			  ,msgcode => 'PA_DRT_HR_RESOWN_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_RESOWN_ERROR', 1);
            END IF;

	END;

	 /* PROJ-37) Person shouldn't be an active agreemnt adminstrator on an active project.*/
	BEGIN

         SELECT NULL
           INTO l_dummy
           FROM sys.dual
		  WHERE NOT EXISTS (
              SELECT NULL
 	            FROM pa_agreements_all
			   WHERE OWNED_BY_PERSON_ID = p_person_id
			     AND trunc(sysdate) <= nvl(EXPIRATION_DATE, trunc(sysdate)));

     EXCEPTION
     WHEN NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'HR'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_HR_AGRADM_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'msgcode: '||'PA_DRT_HR_AGRADM_ERROR', 1);
            END IF;

	END;

    IF P_PA_DEBUG_MODE = 'Y' THEN
	   PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_drc', 'Leaving ', 1);
    END IF;


  END pa_hr_drc;


  PROCEDURE pa_tca_drc
    (p_person_id     IN number
	,result_tbl OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE)
   IS

  l_dummy                   varchar2(20);
  --result_tbl 			    PER_DRT_PKG.RESULT_TBL_TYPE;

  BEGIN

    /*PROJ-21) Person Supplier shouldn't be part of any Work plan or financial plan assignments */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS(
		         SELECT NULL
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_project_statuses pps, pa_projects_all pa
				  WHERE pa.project_id = bv.project_id
				    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND pa.project_id = ra.project_id
				    AND bv.budget_version_id = ra.budget_version_id
					AND (bv.budget_type_code IS NULL AND bv.fin_plan_type_id > 10)
                    AND (trunc(sysdate) < ra.planning_start_date or (trunc(sysdate) between ra.planning_start_date and ra.planning_end_date))
					AND ((bv.budget_status_code = 'B' AND bv.current_flag = 'Y') or (bv.budget_status_code = 'W'))
					AND ra.person_id is NULL
					AND ra.supplier_id in (select vendor_id from po_vendors where party_id = p_person_id)
				 UNION
		         SELECT NULL
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_resource_list_members rlm,
				        pa_project_statuses pps, pa_projects_all pa
				  WHERE pa.project_id = bv.project_id
				    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND pa.project_id = ra.project_id
				    AND bv.budget_version_id = ra.budget_version_id
					AND bv.budget_type_code is NOT NULL
                    AND exists (select 1 from pa_budget_lines bl where bl.resource_assignment_id = ra.resource_assignment_id
                          and ( (trunc(sysdate) < start_date) OR (trunc(sysdate) between start_date and end_date) ))
					AND ((bv.budget_status_code = 'B' AND bv.current_flag = 'Y') or (bv.budget_status_code = 'W'))
					AND bv.resource_list_id = rlm.resource_list_id
                    AND rlm.resource_list_member_id = ra.resource_list_member_id
					AND rlm.person_id is NULL
					AND rlm.vendor_id in (select vendor_id from po_vendors where party_id = p_person_id)
				 UNION
                 SELECT /*+ index(bv PA_BUDGET_VERSIONS_U1) */ NULL                                 -- Latest Publised workplan
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_tasks t, pa_proj_elements ele,
				        pa_project_statuses ps, pa_project_statuses pps, pa_projects_all pa
				  WHERE pa.project_id = t.project_id
				    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND ps.status_type = 'TASK'
				    AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED')
                    AND ele.proj_element_id = t.task_id
                    AND ele.status_code = ps.project_status_code
                    AND pa.project_id = bv.project_id
                    AND pa.project_id = ra.project_id
                    AND t.task_id = ra.task_id
				    AND bv.budget_version_id = ra.budget_version_id
					AND bv.fin_plan_type_id = 10
					AND bv.project_structure_version_id = PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(bv.project_id)
					AND ra.supplier_id in (select /*+ unnest cardinality(1) */ vendor_id from po_vendors where party_id = p_person_id)
				  UNION
		         SELECT /*+ index(bv PA_BUDGET_VERSIONS_U1) */ NULL                                 -- Current Working workplan
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_tasks t, pa_proj_elements ele,
				        pa_project_statuses ps, pa_project_statuses pps, pa_projects_all pa
				  WHERE pa.project_id = t.project_id
				    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND ps.status_type = 'TASK'
				    AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED')
                    AND ele.proj_element_id = t.task_id
                    AND ele.status_code = ps.project_status_code
                    AND pa.project_id = bv.project_id
                    AND pa.project_id = ra.project_id
                    AND t.task_id = ra.task_id
				    AND bv.budget_version_id = ra.budget_version_id
					AND bv.fin_plan_type_id = 10
					AND bv.project_structure_version_id = PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(bv.project_id)
					AND ra.person_id is NULL
					AND ra.supplier_id in (select /*+ unnest cardinality(1) */ vendor_id from po_vendors where party_id = p_person_id)
				  UNION
		         SELECT NULL                                 -- For 12.2.3 fix where task details are not sync
                   FROM pa_budget_versions bv, pa_resource_assignments ra, pa_proj_elements ele,
                        pa_project_statuses ps, pa_project_statuses pps, pa_projects_all pa
                  WHERE pa.project_id = ele.project_id
                    AND pa.project_status_code = pps.project_status_code
                    AND pps.status_type = 'PROJECT'
                    AND pps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                    AND ps.status_type = 'TASK'
                    AND ps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED')
                    AND ele.status_code = ps.project_status_code
                    AND pa.project_id = bv.project_id
                    AND pa.project_id = ra.project_id
                    AND ele.proj_element_id = ra.task_id
                    AND bv.budget_version_id = ra.budget_version_id
                    AND bv.fin_plan_type_id = 10
                    AND (bv.project_structure_version_id = PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION(bv.project_id)
                         OR bv.project_structure_version_id = PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(bv.project_id))
					AND ra.person_id is NULL
					AND ra.supplier_id in (select vendor_id from po_vendors where party_id = p_person_id));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_ASGNMNTS_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_ASGNMNTS_ERROR', 1);
            END IF;
    END;

    /*PROJ-22) Person shouldn't be an active resource list member in any PRL */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
		       SELECT NULL FROM pa_resource_list_members rlm, pa_resource_lists_all_bg prl
			     WHERE prl.resource_list_id = rlm.resource_list_id
				   AND prl.control_flag = 'Y'
				   AND rlm.vendor_id in (select vendor_id from po_vendors where party_id = p_person_id)
				   AND rlm.enabled_flag = 'Y'
				   AND rlm.person_id is NULL
				   AND rlm.resource_id = -99
			   UNION
               SELECT NULL
                 FROM pa_resource_list_members rlm, pa_resource_lists_all_bg prl
                WHERE prl.resource_list_id = rlm.resource_list_id
                  AND prl.control_flag  = 'N'
 			      AND rlm.vendor_id in (select vendor_id from po_vendors where party_id = p_person_id)
				  AND rlm.enabled_flag = 'Y'
				  AND rlm.person_id is NULL
				  AND rlm.resource_id = -99
                  AND rlm.object_type <> 'PROJECT'
               UNION
               SELECT NULL
                FROM pa_resource_list_members rlm, pa_resource_lists_all_bg prl, pa_projects_all pa,
                     pa_project_statuses ps, pa_resource_assignments ra
               WHERE prl.resource_list_id = rlm.resource_list_id
                 AND prl.control_flag = 'N'
			     AND rlm.vendor_id in (select vendor_id from po_vendors where party_id = p_person_id)
				 AND rlm.enabled_flag = 'Y'
				 AND rlm.person_id is NULL
				 AND rlm.resource_id = -99
                 AND rlm.object_type = 'PROJECT'
                 AND pa.project_status_code = ps.project_status_code
                 AND ps.status_type = 'PROJECT'
                 AND ps.project_system_status_code NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND pa.project_id = ra.project_id
                 AND ra.resource_list_member_id  = rlm.resource_list_member_id);

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_RLM_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_RLM_ERROR', 1);
            END IF;

    END;

    /*PROJ-20) Person Supplier shouldn't be part of any RBS */
	BEGIN
	     SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
		      SELECT NULL
			    FROM PA_RBS_ELEMENTS
			   WHERE person_id IS NULL
			     AND supplier_id in (select vendor_id from po_vendors where party_id = p_person_id)
                 AND user_created_flag = 'Y'   -- Instance based RBS
                 AND rbs_version_id IN (SELECT rbs_version_id FROM pa_rbs_versions_b
                                         WHERE ((status_code = 'FROZEN' AND current_reporting_flag = 'Y')
                                                 OR status_code = 'WORKING')));
    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_RBS_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_RBS_ERROR', 1);
            END IF;
    END;


 	 /*PROJ-23) Person Supplier shouldn't be part of any unimported line in the transaction interface tables */
	BEGIN
         SELECT NULL
	       INTO l_dummy
          FROM sys.dual
		 WHERE NOT EXISTS (SELECT NULL from PA_TRANSACTION_INTERFACE_ALL TXN
                            WHERE ((TXN.VENDOR_ID in (select vendor_id from po_vendors where party_id = p_person_id))
                                  OR (TXN.VENDOR_NUMBER in (select segment1 from po_vendors where party_id = p_person_id)))
                            AND TRANSACTION_STATUS_CODE in ('P','R'));


    EXCEPTION
	when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_INT_TCA_TXN_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_INT_TCA_TXN_ERROR', 1);
            END IF;

    END;


	 /*PROJ-15) TCA Person shouldn't be part of any open control items like Issues, Change orders and Change requests */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
		      SELECT NULL
                FROM PA_CONTROL_ITEMS PCI,
                     HZ_PARTIES HZP,
                     HZ_CUST_ACCOUNTS CUST_ACCT,
                     PA_AGREEMENTS_ALL AGR,
                     PA_BUDGET_VERSIONS BV,
                     PA_CI_TYPES_B PCTB,
                     PA_PROJECT_STATUSES PS,
                     PA_PROJECTS_ALL PA
               WHERE PCI.PROJECT_ID = PA.PROJECT_ID
                 AND PS.STATUS_TYPE = 'PROJECT'
                 AND PS.PROJECT_STATUS_CODE = PA.PROJECT_STATUS_CODE
                 AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND PCI.CI_TYPE_ID    = PCTB.CI_TYPE_ID
                 AND PCTB.CI_TYPE_CLASS_CODE in ('ISSUE', 'CHANGE_ORDER', 'CHANGE_REQUEST')
                 AND PA.PROJECT_ID = BV.PROJECT_ID
                 AND PCI.CI_ID = BV.CI_ID
                 AND BV.AGREEMENT_ID = AGR.AGREEMENT_ID
                 AND HZP.PARTY_ID = p_person_id
                 AND HZP.PARTY_ID = CUST_ACCT.PARTY_ID
                 AND CUST_ACCT.CUST_ACCOUNT_ID = AGR.CUSTOMER_ID
                 AND PCI.STATUS_CODE IN (SELECT PROJECT_STATUS_CODE
                                         FROM PA_PROJECT_STATUSES
                                        WHERE STATUS_TYPE = 'CONTROL_ITEM'
                                          AND PROJECT_SYSTEM_STATUS_CODE IN ('CI_REJECTED', 'CI_APPROVED', 'CI_WORKING', 'CI_DRAFT', 'CI_SUBMITTED')));


    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'W'
 			  ,msgcode => 'PA_DRT_TCA_CHANGE_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_CHANGE_ERROR', 1);
            END IF;

	END;

 	 /*PROJ-25) Person Supplier shouldn't be part of any open control items like Issues, Change orders and Change requests */
	 /* Is this dup of prior row? i.e PROJ-15) ? */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM PA_CONTROL_ITEMS PCI
                    ,PA_PROJECTS_ALL PPA
                    ,PA_PROJECT_STATUSES PPS
                    ,PA_CI_TYPES_B PCTB
                    ,pa_ci_supplier_details sp
                    ,po_vendors po
                    ,PA_PROJECT_STATUSES PS
               WHERE PPS.STATUS_TYPE   = 'CONTROL_ITEM'
               AND PCI.STATUS_CODE   = PPS.PROJECT_STATUS_CODE
               AND PCI.CI_TYPE_ID    = PCTB.CI_TYPE_ID
               AND PCTB.CI_TYPE_CLASS_CODE in ('ISSUE', 'CHANGE_ORDER', 'CHANGE_REQUEST')
               AND PPA.PROJECT_ID = PCI.PROJECT_ID
               AND PPA.PROJECT_STATUS_CODE = PS.PROJECT_STATUS_CODE
               AND PS.STATUS_TYPE = 'PROJECT'
               AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
               AND sp.ci_id = pci.ci_id
               AND sp.vendor_id = po.vendor_id
               AND po.party_id = p_person_id
               AND PCI.STATUS_CODE IN (SELECT PROJECT_STATUS_CODE
                                         FROM PA_PROJECT_STATUSES
                                        WHERE STATUS_TYPE = 'CONTROL_ITEM'
                                          AND PROJECT_SYSTEM_STATUS_CODE IN ('CI_REJECTED', 'CI_APPROVED', 'CI_WORKING', 'CI_DRAFT', 'CI_SUBMITTED')));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'W'
 			  ,msgcode => 'PA_DRT_VEND_CHANGE_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_VEND_CHANGE_ERROR', 1);
            END IF;

	END;


     /*PROJ-27) Person Supplier shouldn't be a part of unreleased pre-approved batches */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
			  SELECT NULL
                FROM pa_expenditures_all e
             WHERE  EXPENDITURE_STATUS_CODE IN ('WORKING','SUBMITTED')
				 AND e.incurred_by_person_id IS NULL
				 AND e.vendor_id in (select vendor_id from po_vendors where party_id = p_person_id));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TXN_TCA_BATCH_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TXN_TCA_BATCH_ERROR', 1);
            END IF;

    END;


	 /* PROJ-19) Person Supplier shouldn't be a part of unaccounted transactions */
    BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (select NULL from pa_expenditure_items_all ei, pa_cost_distribution_lines_all cdl
         where ei.vendor_id in (select vendor_id from po_vendors where party_id = p_person_id)
         and cdl.EXPENDITURE_ITEM_ID = ei.EXPENDITURE_ITEM_ID
         and cdl.TRANSFER_STATUS_CODE not in ('A','V','G','B'));

    EXCEPTION
	when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_UNACC_TXN_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_UNACC_TXN_ERROR', 1);
            END IF;

    END;


     /*PROJ-24) Person Supplier shouldn't be a part of any billable transactions which are not billed yet or bill on hold */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM pa_expenditure_items_all exp, pa_expenditures_all e
               WHERE exp.expenditure_id = e.expenditure_id
			     AND exp.cost_distributed_flag = 'Y'
				 AND e.incurred_by_person_id IS NULL
				 AND e.vendor_id in (select vendor_id from po_vendors where party_id = p_person_id)
				 AND (exp.billable_flag = 'Y' or exp.bill_hold_flag = 'Y')
				 AND exp.event_num is null
				 AND (exp.revenue_distributed_flag = 'N' or EXISTS (SELECT 1 FROM pa_cust_rev_dist_lines_all crdl
                             WHERE exp.expenditure_item_id = crdl.expenditure_item_id
                               AND crdl.draft_invoice_num is NULL)));

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_BILL_TXN_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_BILL_TXN_ERROR', 1);
            END IF;
    END;

	/*PROJ-11) TCA Person shouldn't be a Customer contact to any active project */
	BEGIN
	     SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
              SELECT NULL
                FROM PA_PROJECT_CONTACTS PC ,
                     hz_cust_account_roles acct_role ,
                     hz_relationships rel ,
                     hz_org_contacts org_cont ,
                     hz_parties party,
					 PA_PROJECTS_ALL PA,
					 PA_PROJECT_STATUSES PS
               WHERE party.PARTY_ID = p_person_id
			     AND acct_role.cust_account_id      = PC.BILL_SHIP_CUSTOMER_ID
                 AND acct_role.cust_account_role_id = PC.CONTACT_ID
                 AND acct_role.party_id             = rel.party_id
                 AND acct_role.role_type            = 'CONTACT'
                 AND rel.relationship_id            = org_cont.party_relationship_id
                 AND party.party_id                 = rel.subject_id
                 AND rel.subject_type       = 'PERSON'
                 AND rel.object_table_name  = 'HZ_PARTIES'
                 AND rel.subject_table_name = 'HZ_PARTIES'
				 AND PS.STATUS_TYPE = 'PROJECT'
				 AND PS.PROJECT_STATUS_CODE = PA.PROJECT_STATUS_CODE
				 AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND PA.PROJECT_ID = PC.PROJECT_ID);
    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_PROJ_CUST_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_PROJ_CUST_ERROR', 1);
            END IF;

	END;

	 /*PROJ-28) TCA Person shouldn't be a customer to any active project */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM PA_PROJECT_CUSTOMERS PPC,
                     PA_PROJECTS_ALL PPA,
					 PA_PROJECT_STATUSES PS,
                     HZ_PARTIES PARTY,
                     HZ_CUST_ACCOUNTS CUST_ACCT
               WHERE PPC.CUSTOMER_ID = CUST_ACCT.CUST_ACCOUNT_ID
                 AND PPC.PROJECT_ID = PPA.PROJECT_ID
                 AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
				 AND PS.STATUS_TYPE = 'PROJECT'
				 AND PS.PROJECT_STATUS_CODE = PPA.PROJECT_STATUS_CODE
				 AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
				 AND CUST_ACCT.PARTY_ID = p_person_id);

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_PROJ_CONT_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_PROJ_CONT_ERROR', 1);
            END IF;
    END;


	 /*PROJ-12) TCA Person shouldn't be part of any invoice which is not interfaced to AR yet */
	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
              SELECT NULL
                FROM PA_PROJECT_CUSTOMERS PPC,
                     PA_PROJECTS_ALL PPA,
                     PA_PROJECT_STATUSES PS,
                     HZ_PARTIES PARTY,
                     HZ_CUST_ACCOUNTS CUST_ACCT,
                     PA_DRAFT_INVOICES_ALL DI
               WHERE PPC.CUSTOMER_ID = CUST_ACCT.CUST_ACCOUNT_ID
                 AND PPC.PROJECT_ID = PPA.PROJECT_ID
                 AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
				 AND PS.STATUS_TYPE = 'PROJECT'
				 AND PS.PROJECT_STATUS_CODE = PPA.PROJECT_STATUS_CODE
				 AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND DI.PROJECT_ID = PPA.PROJECT_ID
                 AND DI.TRANSFER_STATUS_CODE in ('P', 'T')
				 AND DI.CUSTOMER_ID = PPC.CUSTOMER_ID
				 AND CUST_ACCT.PARTY_ID = p_person_id);

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_DINV_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_DINV_ERROR', 1);
            END IF;

    END;

	 /*PROJ-13) TCA Person shouldn't be part of any agreements that are part of active projects */
	BEGIN
         SELECT NULL
           INTO l_dummy
           FROM sys.dual
          WHERE NOT EXISTS (
              SELECT NULL
                FROM PA_AGREEMENTS_ALL AGR,
                     PA_PROJECT_STATUSES PS,
                     PA_PROJECTS_ALL PPA,
                     HZ_PARTIES PARTY,
                     HZ_CUST_ACCOUNTS CUST_ACCT,
					 PA_PROJECT_FUNDINGS PF
               WHERE AGR.CUSTOMER_ID = CUST_ACCT.CUST_ACCOUNT_ID
                 AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
                 AND PPA.PROJECT_STATUS_CODE = PS.PROJECT_STATUS_CODE
				 AND PS.STATUS_TYPE = 'PROJECT'
                 AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND PF.AGREEMENT_ID = AGR.AGREEMENT_ID
                 AND PF.PROJECT_ID = PPA.PROJECT_ID
	             AND CUST_ACCT.PARTY_ID = p_person_id);

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_AGRMT_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_AGRMT_ERROR', 1);
            END IF;

	END;


	 /*PROJ-14) TCA Person shouldn't be part of any revenue which is not interfaced to SLA */

	BEGIN
         SELECT NULL
		   INTO l_dummy
		   FROM sys.dual
		  WHERE NOT EXISTS (
              SELECT NULL
                FROM PA_AGREEMENTS_ALL AGR,
                     PA_PROJECT_STATUSES PS,
                     PA_PROJECTS_ALL PPA,
                     HZ_PARTIES PARTY,
                     HZ_CUST_ACCOUNTS CUST_ACCT,
                     PA_DRAFT_REVENUES_ALL drev,
					 PA_PROJECT_FUNDINGS PF
               WHERE AGR.CUSTOMER_ID = CUST_ACCT.CUST_ACCOUNT_ID
                 AND CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
                 AND PPA.PROJECT_STATUS_CODE = PS.PROJECT_STATUS_CODE
                AND PS.STATUS_TYPE = 'PROJECT'
                 AND PS.PROJECT_SYSTEM_STATUS_CODE NOT IN ('CLOSED', 'PURGED', 'PARTIALLY_PURGED')
                 AND PF.AGREEMENT_ID = AGR.AGREEMENT_ID
                 AND PF.PROJECT_ID = PPA.PROJECT_ID
                 AND drev.PROJECT_ID = PF.PROJECT_ID
                 AND (drev.event_id is NULL
                      or EXISTS (SELECT 1
					               FROM XLA_EVENTS XLA
					              WHERE drev.event_id = xla.event_id
                                    AND XLA.EVENT_STATUS_CODE <> 'P'
                                    AND XLA.PROCESS_STATUS_CODE <> 'P'))
                 AND CUST_ACCT.PARTY_ID = p_person_id);

    EXCEPTION
    when NO_DATA_FOUND then

        per_drt_pkg.add_to_results(person_id => p_person_id
  			  ,entity_type => 'TCA'
 			  ,status => 'E'
 			  ,msgcode => 'PA_DRT_TCA_DREV_ERROR'
 			  ,msgaplid => 275
 			  ,result_tbl => result_tbl);

         	IF P_PA_DEBUG_MODE = 'Y' THEN
	           PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'msgcode: '||'PA_DRT_TCA_DREV_ERROR', 1);
            END IF;

	END;


    IF P_PA_DEBUG_MODE = 'Y' THEN
	   PA_DEBUG.WRITE('PA_DRT_PKG.pa_tca_drc', 'Leaving ', 1);
    END IF;

END pa_tca_drc;


PROCEDURE pa_hr_pre
    (p_person_id     IN number)
IS

dummy varchar2(250);
fullName varchar2(250);
firstName varchar2(250);
lastName varchar2(250);
randStrName varchar2(250);


CURSOR inv_group_column_code(p_project_id NUMBER) IS
Select Pformat.start_position,
Pformat.end_position,
pgroup.column_code
From Pa_Projects_All Ppa,
Pa_Invoice_Format_Details Pformat,
Pa_Invoice_Group_Columns Pgroup
Where Ppa.Labor_Invoice_Format_Id = Pformat.Invoice_Format_Id
And Pformat.Invoice_Group_Column_Id = Pgroup.Invoice_Group_Column_Id
And Ppa.Project_Id = p_project_id
and pgroup.column_code in ('EMPLOYEE LAST NAME','EMPLOYEE FIRST NAME','EMPLOYEE FULL NAME');


CURSOR person_resource_name IS
SELECT first_name,last_name,full_name from per_all_people_f WHERE person_id = p_person_id and rownum < 2;

CURSOR rand_str_per_name IS
SELECT REPLACE(REPLACE(REPLACE(full_name, middle_names, dbms_random.string('A', nvl(length(middle_names),0))),
last_name, dbms_random.string('A', nvl(length(last_name),0))),
First_Name, Dbms_Random.String('A', nvl(Length(First_Name),0)))
From Per_All_People_F Where Person_Id = p_person_id and rownum < 2;


CURSOR draft_inv_items_text IS
SELECT project_id, draft_invoice_num, line_num, text
FROM pa_draft_invoice_items
WHERE (draft_invoice_num, project_id) IN
(SELECT crdl.draft_invoice_num, crdl.project_id
FROM pa_cust_rev_dist_lines_all crdl,
  pa_expenditure_items_all exp,
   pa_expenditures_all pea
WHERE crdl.project_id           = exp.project_id
AND crdl.expenditure_item_id = exp.expenditure_item_id
AND exp.expenditure_id      = pea.expenditure_id
AND exp.cost_distributed_flag = 'Y'
AND (exp.billable_flag = 'Y'  OR exp.bill_hold_flag = 'Y')
AND exp.event_num IS NULL
AND pea.incurred_by_person_id = p_person_id);

begin

IF P_PA_DEBUG_MODE = 'Y' THEN
   PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_pre', '10 - Entering pa_hr_pre',1);
END IF;

IF P_PA_DEBUG_MODE = 'Y' THEN
   PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_pre', 'p_person_id: '||p_person_id, 1);
END IF;

open person_resource_name;
fetch person_resource_name into firstName,lastName,fullName;
close person_resource_name;

open rand_str_per_name;
fetch rand_str_per_name into randStrName;
close rand_str_per_name;

FOR rec IN draft_inv_items_text LOOP

FOR rec1 IN inv_group_column_code(rec.project_id) LOOP

 IF rec1.column_code = 'EMPLOYEE FULL NAME' THEN
   IF INSTR(rec.text, fullName) > 0 then

     SELECT substrb(rec.text,1,rec1.start_position-1)||
     Replace(Substrb(rec.text, rec1.start_position, rec1.end_position), fullName, randStrName)||
     substrb(rec.text,rec1.start_position+rec1.end_position) INTO dummy from dual;


      UPDATE PA_DRAFT_INVOICE_ITEMS
      SET TEXT = dummy
      where project_id = rec.project_id
      and draft_invoice_num = rec.draft_invoice_num
      and line_num = rec.line_num;
    END IF;

  ELSIF rec1.column_code = 'EMPLOYEE FIRST NAME' THEN

    IF INSTR(rec.text, firstName) > 0 then
      SELECT substrb(rec.text,1,rec1.start_position-1)||
      Replace(Substrb(rec.text, rec1.start_position, rec1.end_position), firstName,
      Dbms_Random.String('A', nvl(Length(firstName),0)))||
      substrb(rec.text,rec1.start_position+rec1.end_position) INTO dummy from dual;


      UPDATE PA_DRAFT_INVOICE_ITEMS
      SET TEXT = dummy
      where project_id = rec.project_id
      and draft_invoice_num = rec.draft_invoice_num
      and line_num = rec.line_num;
    END IF;

  ELSIF rec1.column_code = 'EMPLOYEE LAST NAME' THEN

  IF INSTR(rec.text, lastName) > 0 then

      SELECT substrb(rec.text,1,rec1.start_position-1)||
      Replace(Substrb(rec.text, rec1.start_position, rec1.end_position), lastName, Dbms_Random.String('A', nvl(Length(lastName),0)))||
      substrb(rec.text,rec1.start_position+rec1.end_position) INTO dummy from dual;


      UPDATE PA_DRAFT_INVOICE_ITEMS
      SET TEXT = dummy
      where project_id = rec.project_id
      and draft_invoice_num = rec.draft_invoice_num
      and line_num = rec.line_num;
  END IF;

  END IF;

END LOOP;

END LOOP;

IF P_PA_DEBUG_MODE = 'Y' THEN
	   PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_pre', 'Leaving ', 1);
END IF;

EXCEPTION
    WHEN OTHERS THEN
    IF P_PA_DEBUG_MODE = 'Y' THEN
	  PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_pre', 'ErrorMsg: '||SQLERRM, 1);
    END IF;
    RAISE;

END pa_hr_pre;



PROCEDURE pa_hr_post
    (p_person_id     IN number)
IS

BEGIN

IF P_PA_DEBUG_MODE = 'Y' THEN
   PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_post', '10 - Entering pa_hr_post',1);
END IF;

IF P_PA_DEBUG_MODE = 'Y' THEN
   PA_DEBUG.WRITE('PA_DRT_PKG.pa_hr_post', 'p_person_id: '||p_person_id, 1);
END IF;

END pa_hr_post;

END PA_DRT_PKG;

/
