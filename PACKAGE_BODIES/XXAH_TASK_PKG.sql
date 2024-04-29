--------------------------------------------------------
--  DDL for Package Body XXAH_TASK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_TASK_PKG" AS

  gn_org_id                NUMBER        := FND_PROFILE.value('ORG_ID');
  gn_user_id               NUMBER        := FND_GLOBAL.user_id;
  gn_conc_request_id       NUMBER(15)    := FND_GLOBAL.conc_request_id;
  gc_appl_short_name       VARCHAR2(25)  := 'PA';
  gn_responsibility_id     NUMBER        := FND_GLOBAL.resp_id;
  gn_resp_appl_id          NUMBER        := fnd_global.RESP_APPL_ID;
  gc_application_shortname fnd_application.application_short_name%TYPE := FND_GLOBAL.application_short_name;
  gc_err_pos               VARCHAR2(1000);
  gc_debug_flag            VARCHAR2(1)   := 'Y';
  gn_application_id        NUMBER        := 275; -- PA

  ln_msg_count             NUMBER;

  ex_amg_init_error        EXCEPTION;

  gc_valid_rec_status      VARCHAR2(1)   := 'V';
  gc_success_rec_status    VARCHAR2(1)   := 'S';
  gc_error_rec_status      VARCHAR2(1)   := 'E';
  gc_warn_rec_status      VARCHAR2(1)    := 'W';
  gc_complete_rec_status   VARCHAR2(1)   := 'C';
  gc_new_rec_status        VARCHAR2(1)   := 'N';


PROCEDURE debug_print(
   p_print_flag  IN  VARCHAR2
  ,p_debug_mesg  IN  VARCHAR2
)
IS
BEGIN
  IF p_print_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_mesg);
  END IF;
END debug_print;



PROCEDURE assign_managers(
    p_project_id pa_projects_all.project_id%TYPE
  , p_user_id                   fnd_user.user_id%TYPE
  , p_responsibility_id         fnd_responsibility.responsibility_id%TYPE
  , p_application_short_name    fnd_application.application_short_name%TYPE
)
IS
  -- 30/05/08 P Timmermans  Added some code for determining reason of failing
  -- 13/06/08 P Timmermans  Always show additional information for determining
  --                        reason of failing
  -- 16/06/08 P Timmermans  Don't select tasks which are to be deleted
  -- 20/08/08 P Timmermans  Included savepoint

  ln_task_tbl_idx            NUMBER;
  ln_pa_task_id              NUMBER;

  ln_errcode                 NUMBER;
  ln_msg_index               NUMBER                  := -1;
  ln_msg_index_out           NUMBER;
  ln_msg_count               NUMBER;
  lc_msg_data                VARCHAR2(2000);
  lc_return_status           VARCHAR2(1);
  lc_return_msg              VARCHAR2(500);
  ln_return_msg              NUMBER;
  lc_errmsg                  VARCHAR2(4000);
  lc_data                    VARCHAR2(500)           := NULL;

  ln_person_id               per_all_people_f.person_id%TYPE;
  ln_person_name             per_all_people_f.full_name%TYPE; -- 30/05/08

  ln_out_pa_task_id          NUMBER;
  lc_out_pm_task_reference   pa_tasks.pm_task_reference%TYPE;         --VARCHAR2;


  -- 2007/May/30, rlascae: update for attribute1 IS NULL with person_id NULL

  CURSOR lcu_tasks IS
  SELECT
    tsk.task_id
  , tsk.attribute1
  , tsk.task_number -- 30/05/08
  FROM  pa_tasks tsk
  WHERE 1=1
  -- AND   attribute1 IS NOT NULL
  AND   tsk.project_id = p_project_id
  -- 16/06/08 task not to be deleted
  AND NOT EXISTS
  ( SELECT 'X'
    FROM   pa_struct_tasks_amg_v pst
    WHERE  pst.project_id = tsk.project_id
    AND    pst.task_id    = tsk.task_id
    AND    pst.task_unpub_ver_status_code = 'TO_BE_DELETED'
  )
  ;

  -- 2007/May/30, rlascae: if more then 1 person with the same role, pick up the first, alphabetically

  CURSOR lcu_project_parties(p_role pa_tasks.attribute1%TYPE)IS
  SELECT
  --  ppp.resource_id  resource_id
  --, pprt.meaning     project_role
  --, pprt.description project_role_desc
  --, ppa.project_id   project_id
  --, ppa.segment1     project_number
      pe.person_id     person_id
    , pe.full_name -- 30/05/08
  FROM   PA_PROJECT_PARTIES        PPP,
         PA_PROJECTS_ALL           PPA,
         PA_PROJECT_ROLE_TYPES     PPRT,
         PER_ALL_PEOPLE_F          PE,
         PA_PROJECT_ASSIGNMENTS    PA,
         PER_ALL_ASSIGNMENTS_F     PRD,
         PER_JOBS                  PJ,
         HR_ALL_ORGANIZATION_UNITS HAOU,
         FND_USER                  U
  WHERE    PPP.RESOURCE_TYPE_ID = 101
           AND PPP.PROJECT_ID = PPA.PROJECT_ID
           AND PPP.PROJECT_ROLE_ID = PPRT.PROJECT_ROLE_ID
           AND PPP.RESOURCE_SOURCE_ID = PE.PERSON_ID
           AND TRUNC(SYSDATE) BETWEEN TRUNC(PE.EFFECTIVE_START_DATE) AND
               TRUNC(PE.EFFECTIVE_END_DATE)
           AND PPP.PROJECT_PARTY_ID = PA.PROJECT_PARTY_ID(+)
           AND PRD.ASSIGNMENT_TYPE IN ('C', 'B', 'E')
           AND PPP.RESOURCE_SOURCE_ID = PRD.PERSON_ID
           AND PRD.PRIMARY_FLAG = 'Y'
           AND TRUNC(SYSDATE) BETWEEN TRUNC(PRD.EFFECTIVE_START_DATE) AND
               TRUNC(PRD.EFFECTIVE_END_DATE)
           AND PRD.ORGANIZATION_ID = HAOU.ORGANIZATION_ID
           AND NVL(PRD.JOB_ID, -99) = PJ.JOB_ID(+)
           AND U.EMPLOYEE_ID(+) = PPP.RESOURCE_SOURCE_ID
           AND ppa.project_id = p_project_id
           AND pprt.description = p_role
  ORDER BY pe.last_name
  ;

  ln_api_version_number              NUMBER          := 1.0;

  ln_application_id           fnd_application.application_id%TYPE;
  ln_responsibility_id        fnd_responsibility.responsibility_id%TYPE;

  -- not used
  -- lc_responsibility_name      CONSTANT fnd_responsibility_tl.responsibility_name%TYPE:= 'Project Manager';
  lc_user_name                fnd_user.user_name%TYPE;
  ln_user_id                  fnd_user.user_id%TYPE;

  l_skip                      VARCHAR2(1) := 'N';

BEGIN
  gc_err_pos:= '<100>';
  FND_MSG_PUB.initialize;

  ln_user_id:=           p_user_id;
  ln_responsibility_id:= p_responsibility_id;

  BEGIN

    SELECT application_id INTO ln_application_id
    FROM fnd_application
    WHERE application_short_name = p_application_short_name
    ;

  gc_err_pos:= '<101>';
  EXCEPTION WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100, 'Error at ' || gc_err_pos || ': ' || SQLERRM || '(application_short_name: ' || p_application_short_name || ')');
  END;

  -- 2007/May/30, rlascae: baselined here, see version 06 for original

  gc_err_pos:= '<102>';
  pa_interface_utils_pub.set_global_info (
                                           p_api_version_number => ln_api_version_number,
                                           p_responsibility_id  => ln_responsibility_id,
                                           p_user_id            => ln_user_id,
                                           p_resp_appl_id       => ln_application_id,
                                           p_msg_count          => ln_msg_count,
                                           p_msg_data           => lc_msg_data,
                                           p_return_status      => lc_return_status
                                          );

  IF lc_return_status != gc_success_rec_status THEN
    IF ln_msg_count > 0 THEN
      lc_errmsg := NULL;
      FOR ln_msg_index in 1..ln_msg_count LOOP
        pa_interface_utils_pub.get_messages
                  (
                     p_encoded      => 'F'
                    ,p_msg_count    => ln_msg_count
                    ,p_msg_index    => ln_msg_index
                    ,p_msg_data     => lc_msg_data
                    ,p_data         => lc_data
                    ,p_msg_index_out=> ln_msg_index_out
                  );
        lc_errmsg := lc_errmsg || ltrim(rtrim(lc_data));
      END LOOP;
    END IF;

    gc_err_pos:= '<103>';
    RAISE_APPLICATION_ERROR(-20100, 'Error at ' || gc_err_pos || ': ' || lc_errmsg
    || '(user_id: ' || to_char(gn_user_id)
    || ' responsibility_id ' || to_char(gn_responsibility_id)
    || ' resp_appl_id ' || to_char(gn_resp_appl_id)
    || ')'
    );
  END IF;

  gc_err_pos:= '<104>';
  FOR lr_tasks IN lcu_tasks   LOOP

    SAVEPOINT xx_tsk_mgr;

    l_skip := 'N';

    BEGIN
      -- 2007/May/30, rlascae: allow ln_person_id:= NULL
      -- ver08, set ln_person_id:= NULL before trying to retrieve it

      ln_person_id:= NULL;
      ln_person_name:=''; -- 30/05/08

      IF lr_tasks.attribute1 IS NULL THEN
        gc_err_pos:= '<105>';
        ln_person_id:= NULL;
      ELSE
        -- 2007/May/30, rlascae: baselined here, see ver06 for original
        -- allows to pick up one person if more then one exists with the same role
        -- also results in ln_person_id = NULL if none found for the role

        gc_err_pos:= '<106>';
        OPEN lcu_project_parties(lr_tasks.attribute1);
        FETCH lcu_project_parties INTO ln_person_id
                                     , ln_person_name -- 30/05/08
                                     ;
        CLOSE lcu_project_parties;

      END IF;

    EXCEPTION WHEN OTHERS THEN
      gc_err_pos:= '<107>';
      IF lcu_project_parties%ISOPEN THEN CLOSE lcu_project_parties; END IF;
      l_skip := 'Y';
      -- RAISE_APPLICATION_ERROR(-20100, 'Error at ' || gc_err_pos || ': ' || SQLERRM ||
      --                                 '(task_id ' || to_char(lr_tasks.task_id) || ')');
    END;

    -- 2007/May/30, rlascae: baselined, see ver06 for original
    gc_err_pos:= '<108>';

    IF l_skip = 'N' THEN
      pa_project_pub.update_task(
                               p_api_version_number        => 1, -- ln_api_version_number,
                               p_commit                    => fnd_api.g_false, -- 'N',
                               p_init_msg_list             => fnd_api.g_true, -- 'Y',
                               p_msg_count                 => ln_msg_count,
                               p_msg_data                  => lc_msg_data,
                               p_return_status             => lc_return_status,
                               p_out_pa_task_id            =>ln_out_pa_task_id,
                               p_out_pm_task_reference     =>lc_out_pm_task_reference,
                               p_update_task_structure     => 'N',
                               p_pa_project_id             => p_project_id,
                               p_pm_product_code           => 'AMW', -- !!! hardcoded, needs changing
                               p_pa_task_id                => lr_tasks.task_id,
                               p_task_manager_person_id    => ln_person_id
      );


      -- dbms_output.put_line('return status: ' || lc_return_status);
      -- dbms_output.put_line('task_id in: ' || lr_tasks.task_id);
      -- dbms_output.put_line('person_id: ' || ln_person_id);
      -- dbms_output.put_line('error message: ' || lc_msg_data);
      -- dbms_output.put_line('task id out: ' || to_char(ln_out_pa_task_id));
      -- dbms_output.put_line('task_reference out: ' || lc_out_pm_task_reference);

      IF lc_return_status != gc_success_rec_status THEN
        IF ln_msg_count > 0 THEN
          lc_errmsg := NULL;
          FOR ln_msg_index in 1..ln_msg_count LOOP
            pa_interface_utils_pub.get_messages
                  (
                     p_encoded      => 'F'
                    ,p_msg_count    => ln_msg_count
                    ,p_msg_index    => ln_msg_index
                    ,p_msg_data     => lc_msg_data
                    ,p_data         => lc_data
                    ,p_msg_index_out=> ln_msg_index_out
                  );
            lc_errmsg := lc_errmsg || ltrim(rtrim(lc_data));
          END LOOP;
        END IF;

        ROLLBACK TO SAVEPOINT xx_tsk_mgr;

        lc_errmsg:= lc_errmsg || ' (' || 'task_id ' || to_char(lr_tasks.task_id);
        -- 30/05/08 add additional information if no messages optained for debugging purpose
        -- 13/06/08 show this information always
        -- 13/06/08 IF ln_msg_count > 0
        -- 13/06/08 THEN
        -- 13/06/08   lc_errmsg:= lc_errmsg || ' )' ;
        -- 13/06/08 ELSE
        lc_errmsg:= lc_errmsg || ', task_number ' || lr_tasks.task_number
                              || ', role '        || lr_tasks.attribute1
                              || ', person '      || ln_person_name
                              || ', status = '    || lc_return_status
                              || ', assign_managers('||to_char(p_project_id)
                                                ||','||to_char(p_user_id)
                                                ||','||to_char(p_responsibility_id)
                                                ||','''||p_application_short_name||''') )';
        lc_errmsg:= ' DELIVER THIS INFORMATION TO ORACLE EXTENDED SERVICES ... '
                   ||lc_errmsg;
        -- 13/06/08 END IF;

        -- RAISE_APPLICATION_ERROR(-20100, 'Error at ' || gc_err_pos || ': ' || lc_errmsg);
      END IF;
    END IF;

    -- dbms_output.put_line('error message: ' || lc_errmsg);

  END LOOP;

  COMMIT;

--  RAISE_APPLICATION_ERROR(-20100, 'TEST FOUTMELDING... '||TO_CHAR(p_project_id)
--    ||', '||TO_CHAR(p_user_id)||', '||TO_CHAR(p_responsibility_id)||', '||p_application_short_name);

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20100, 'Error OTHERS at position '||gc_err_pos||' : ' || SQLCODE || ', ' || SQLERRM);

END assign_managers;

END xxah_task_pkg;

/
