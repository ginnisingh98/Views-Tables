--------------------------------------------------------
--  DDL for Package Body HR_WPM_NTF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WPM_NTF_UTIL" AS
/* $Header: hrwpmntf.pkb 120.3.12010000.13 2010/03/03 04:40:08 rvagvala ship $*/


   FUNCTION send_notification (
      action_type          VARCHAR2,
      score_card_id        per_personal_scorecards.scorecard_id%TYPE,
      to_or_from_mgr_ntf   VARCHAR2,
      reason               VARCHAR2
   )
      RETURN NUMBER
   IS
      -- to be clarified for orig_system
      CURSOR get_role (person_id per_all_people_f.person_id%TYPE)
      IS
         SELECT wf.NAME role_name
           FROM wf_roles wf
          WHERE wf.orig_system = 'PER' AND wf.orig_system_id = person_id;

      CURSOR get_global_name (p_person_id per_all_people_f.person_id%TYPE)
      IS
         SELECT NVL (GLOBAL_NAME, first_name || ', ' || last_name)
           FROM per_all_people_f
          WHERE person_id = p_person_id
            AND TRUNC (SYSDATE) BETWEEN effective_start_date AND effective_end_date;

      CURSOR get_scorecard_info (p_scorecard_id per_personal_scorecards.scorecard_id%TYPE)
      IS
         SELECT *
           FROM per_personal_scorecards
          WHERE scorecard_id = p_scorecard_id;

      CURSOR get_sc_manager_person_id (p_sc_id NUMBER)
      IS
         SELECT paf.supervisor_id
           FROM per_all_assignments_f paf, per_personal_scorecards sc
          WHERE sc.scorecard_id = p_sc_id
            AND sc.assignment_id = paf.assignment_id
            AND TRUNC (SYSDATE) BETWEEN paf.effective_start_date AND paf.effective_end_date
            AND paf.assignment_type IN ('E', 'C');

      CURSOR get_sc_person_id (p_scorecard_id per_personal_scorecards.scorecard_id%TYPE)
      IS
         SELECT person_id
           FROM per_personal_scorecards
          WHERE scorecard_id = p_scorecard_id;

      CURSOR get_sc_plan_info (p_sc_id per_perf_mgmt_plans.plan_id%TYPE)
      IS
         SELECT hierarchy_type_code
           FROM per_personal_scorecards sc, per_perf_mgmt_plans PLAN
          WHERE sc.scorecard_id = p_sc_id AND sc.plan_id = PLAN.plan_id;

      CURSOR get_pos_manager_id (p_sc_id per_personal_scorecards.scorecard_id%TYPE)
      IS
         SELECT sup.person_id
           FROM per_personal_scorecards sc,
                per_all_assignments_f wrk,
                per_pos_structure_elements ppse,
                per_all_assignments_f sup,
                per_perf_mgmt_plans plans
          WHERE sc.scorecard_id = p_sc_id
            AND plans.plan_id = sc.plan_id
            AND sc.assignment_id = wrk.assignment_id
            AND TRUNC (SYSDATE) BETWEEN wrk.effective_start_date AND wrk.effective_end_date
            AND wrk.position_id = ppse.subordinate_position_id
            AND ppse.pos_structure_version_id = plans.pos_structure_version_id
            AND ppse.business_group_id = sup.business_group_id
            AND ppse.parent_position_id = sup.position_id
            AND TRUNC (SYSDATE) BETWEEN sup.effective_start_date AND sup.effective_end_date
	    AND ( ( plans.assignment_types_code IN ('E', 'C')
                    AND sup.assignment_type = plans.assignment_types_code
                   )
                 OR ( plans.assignment_types_code = 'EC' AND sup.assignment_type IN ('E', 'C')
                   ) )
            AND EXISTS (
                   SELECT 'x'
                     FROM per_person_type_usages_f ptu, per_person_types ppt
                    WHERE ptu.person_id = sup.person_id
                      AND TRUNC (SYSDATE) BETWEEN ptu.effective_start_date AND ptu.effective_end_date
                      AND ptu.person_type_id = ppt.person_type_id
                      AND ppt.system_person_type IN ('EMP', 'CWK', 'EMP_APL', 'CWK_APL'));

      ln_notification_id           NUMBER;
      from_role                    wf_local_roles.NAME%TYPE                       DEFAULT NULL;
      to_role                      wf_local_roles.NAME%TYPE                       DEFAULT NULL;
      from_name                    per_all_people_f.GLOBAL_NAME%TYPE;
      to_name                      per_all_people_f.GLOBAL_NAME%TYPE;
      from_role_not_exists         EXCEPTION;
      to_role_not_exists           EXCEPTION;
      l_sc_info                    per_personal_scorecards%ROWTYPE;
      no_score_card_with_this_id   EXCEPTION;
      lv_subject                   VARCHAR2 (200)                                 DEFAULT NULL;
      tlnt_mgmt_rel_apps_fn        VARCHAR2 (200)                                 DEFAULT NULL;
      mgr_person_id                per_all_people_f.person_id%TYPE                DEFAULT NULL;
      sc_person_id                 per_personal_scorecards.person_id%TYPE         DEFAULT NULL;
      from_person_id               per_all_people_f.person_id%TYPE                DEFAULT NULL;
      to_person_id                 per_all_people_f.person_id%TYPE                DEFAULT NULL;
      mesg_name                    VARCHAR2 (100)                                 DEFAULT NULL;
      l_hier_code                  per_perf_mgmt_plans.hierarchy_type_code%TYPE;
   BEGIN

      /* In case Employee to Manager we need to get the Manager's Person Id */
      OPEN get_sc_plan_info (score_card_id);

      FETCH get_sc_plan_info
       INTO l_hier_code;

      CLOSE get_sc_plan_info;

      IF (l_hier_code = 'ORG')
      THEN
         l_hier_code                := 'SUP';
      END IF;

      -- normally this procedure is invoked only when there is supervisor and employee
      -- in case of top employee this is not called.
      IF (l_hier_code = 'SUP' OR l_hier_code = 'SUP_ASG')
      THEN
         OPEN get_sc_manager_person_id (score_card_id);

         FETCH get_sc_manager_person_id
          INTO mgr_person_id;

         CLOSE get_sc_manager_person_id;
      ELSIF (l_hier_code = 'POS')
      THEN
         OPEN get_pos_manager_id (score_card_id);

         FETCH get_pos_manager_id
          INTO mgr_person_id;

         CLOSE get_pos_manager_id;
      END IF;

      OPEN get_sc_person_id (score_card_id);

      FETCH get_sc_person_id
       INTO sc_person_id;

      CLOSE get_sc_person_id;

      IF (to_or_from_mgr_ntf = 'MGR_TO_EMP')
      THEN
         from_person_id             := mgr_person_id;
         to_person_id               := sc_person_id;
      ELSIF (to_or_from_mgr_ntf = 'EMP_TO_MGR')
      THEN
         from_person_id             := sc_person_id;
         to_person_id               := mgr_person_id;
      END IF;

      OPEN get_role (from_person_id);

      FETCH get_role
       INTO from_role;

      CLOSE get_role;

      OPEN get_global_name (from_person_id);

      FETCH get_global_name
       INTO from_name;

      CLOSE get_global_name;

      IF (from_role IS NULL)
      THEN
         RAISE from_role_not_exists;
      END IF;

      OPEN get_role (to_person_id);

      FETCH get_role
       INTO to_role;

      CLOSE get_role;

      OPEN get_global_name (to_person_id);

      FETCH get_global_name
       INTO to_name;

      CLOSE get_global_name;

      IF (to_role IS NULL)
      THEN
         RAISE to_role_not_exists;
      END IF;

      OPEN get_scorecard_info (score_card_id);

      FETCH get_scorecard_info
       INTO l_sc_info;

      CLOSE get_scorecard_info;

      IF (l_sc_info.scorecard_name IS NULL)
      THEN
         RAISE no_score_card_with_this_id;
      END IF;

/*
*  removing out the send notification of the generic message.
*  Bug 8730795 - schowdhu - 07-Aug-2009
*/
      IF (to_or_from_mgr_ntf = 'MGR_TO_EMP')
      THEN
         IF (action_type = 'ApproveFinish' OR action_type = 'Finish')
         THEN

            ln_notification_id         :=
               wf_notification.send (ROLE              => to_role,
                                     msg_type          => 'HRWPM',
                                     msg_name          => 'HR_WPM_MGR_TO_EMP_APPROVE',
                                     callback          => NULL,
                                     CONTEXT           => NULL,
                                     send_comment      => NULL,
                                     priority          => 50
                                    );
         wf_notification.setattrtext (ln_notification_id, 'MGR_NAME', from_name);
         wf_notification.setattrtext (ln_notification_id, 'SCORECARD_NAME',
                                      l_sc_info.scorecard_name);

         ELSIF action_type = 'Reject'
         THEN

            ln_notification_id         :=
               wf_notification.send (ROLE              => to_role,
                                     msg_type          => 'HRWPM',
                                     msg_name          => 'HR_WPM_MGR_TO_EMP_REJECT',
                                     callback          => NULL,
                                     CONTEXT           => NULL,
                                     send_comment      => NULL,
                                     priority          => 50
                                    );
         wf_notification.setattrtext (ln_notification_id, 'MGR_NAME', from_name);
         wf_notification.setattrtext (ln_notification_id, 'SCORECARD_NAME',
                                      l_sc_info.scorecard_name);

             -- 5570064 Changes Transfer from Java Layer Start
          ELSIF action_type = 'Transfer'
         THEN

            NULL;
             -- code to send the notification to be plugged here
             -- need to seed a new message in hrwpm.wft for single transfer .
             -- differing the notification changes till then
             -- the mass ntf message cannot be used here as it uses different attributes
/*
            ln_notification_id         :=
               wf_notification.send (ROLE              => to_role,
                                     msg_type          => 'HRWPM',
                                     msg_name          => 'HR_WPM_SC_TRNSF_SUCC',
                                     callback          => NULL,
                                     CONTEXT           => NULL,
                                     send_comment      => NULL,
                                     priority          => 50
                                    );
         wf_notification.setattrtext (ln_notification_id, 'MGR_NAME', from_name);
         wf_notification.setattrtext (ln_notification_id, 'SCORECARD_NAME',
                                      l_sc_info.scorecard_name);

*/
        -- 5570064 Changes Transfer from Java Layer End

         ELSIF action_type = 'RequestAction'
         THEN

            ln_notification_id         :=
               wf_notification.send (ROLE              => to_role,
                                     msg_type          => 'HRWPM',
                                     msg_name          => 'HR_WPM_NTF_REQUEST_ACTION',
                                     callback          => NULL,
                                     CONTEXT           => NULL,
                                     send_comment      => NULL,
                                     priority          => 50
                                    );
         wf_notification.setattrtext (ln_notification_id, 'MGR_NAME', from_name);
         wf_notification.setattrtext (ln_notification_id, 'SCORECARD_NAME',
                                      l_sc_info.scorecard_name);
         END IF;

         tlnt_mgmt_rel_apps_fn      := 'HR_WPM_MGR_REL_APPS_SS';
      ELSIF (to_or_from_mgr_ntf = 'EMP_TO_MGR')
      THEN
         ln_notification_id         :=
            wf_notification.send (ROLE              => to_role,
                                  msg_type          => 'HRWPM',
                                  msg_name          => 'HR_WPM_EMP_TO_MGR_APR',
                                  callback          => NULL,
                                  CONTEXT           => NULL,
                                  send_comment      => NULL,
                                  priority          => 50
                                 );
         wf_notification.setattrtext (ln_notification_id, 'EMP_NAME', from_name);
         wf_notification.setattrtext (ln_notification_id, 'SCORECARD_NAME',
                                      l_sc_info.scorecard_name);
         tlnt_mgmt_rel_apps_fn      := 'HR_WPM_EMP_REL_APPS_SS';
      END IF;

      IF (action_type = 'Transfer' AND to_or_from_mgr_ntf = 'MGR_TO_EMP' )
      THEN
         NULL;
         -- need to seed a new message in hrwpm.wft for single transfer .
         -- differing the notification changes till then
         -- the mass ntf message cannot be used here as it uses different attributes
      ELSE

      wf_notification.setattrtext(ln_notification_id,'HR_WPM_SC_REASON', reason);

      wf_notification.setattrtext (ln_notification_id, '#FROM_ROLE', from_role);
      wf_notification.setattrtext (ln_notification_id, '#WFM_FROM', from_name);
      wf_notification.setattrtext (ln_notification_id, 'HR_WPM_SC_ID', score_card_id);
      wf_notification.setattrtext (ln_notification_id, 'WHICH_NTF', to_or_from_mgr_ntf);
      wf_notification.setattrtext (ln_notification_id, 'HR_FROM_WF', 'WF');
      wf_notification.setattrtext (ln_notification_id, 'HR_PLAN_ID', l_sc_info.plan_id);
      wf_notification.setattrtext (ln_notification_id, 'HR_ACTION_TYPE', to_or_from_mgr_ntf);

    END IF;

      -- Bug 7580480 Fix start
      BEGIN
         IF (to_or_from_mgr_ntf = 'EMP_TO_MGR')
         THEN
            UPDATE per_personal_scorecards
               SET status_code = 'APPROVAL'
             WHERE scorecard_id = score_card_id;

            COMMIT;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE;
      END;

      -- Bug Fix 7580480 End
      RETURN success;
   EXCEPTION
      WHEN from_role_not_exists
      THEN
         RETURN 2;                                                   -- No role exists for employee
      WHEN to_role_not_exists
      THEN
         RETURN 3;                                                    -- No role exists for manager
      WHEN no_score_card_with_this_id
      THEN
         RETURN 4;                                              -- No scorecard exists for employee
      WHEN OTHERS
      THEN
         RAISE;
   END;
END hr_wpm_ntf_util;                                                                 -- Package spec

/
