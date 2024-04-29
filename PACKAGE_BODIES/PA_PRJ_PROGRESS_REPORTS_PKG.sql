--------------------------------------------------------
--  DDL for Package Body PA_PRJ_PROGRESS_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PRJ_PROGRESS_REPORTS_PKG" AS
/* $Header: PAPJXPRB.pls 120.1 2005/08/19 16:41:25 mwasowic noship $ */
/*  APIs for Project exchange progress table */
  Function is_valid_progress_code(p_progress_code IN varchar2)
  return BOOLEAN
  is
     dummy  number;
  Begin
    select 1 into dummy
    from dual
    where exists (select 1
                  from pa_lookups
	          where lookup_type = 'PA_XC_PROGRESS_STATUS'
                  and lookup_code = p_progress_code);
    return TRUE;
  Exception
    when no_data_found then
     return FALSE;
  End is_valid_progress_code;

/* Public  API               */
/** Commented for progress update
  PROCEDURE update_progress_report(
       P_USER_ID                   IN NUMBER
      ,P_COMMIT_FLAG               IN VARCHAR2 default 'N'
      ,P_DEBUG_MODE                IN VARCHAR2 default 'N'
      ,P_PROJECT_ID_OLD            NUMBER := null
      ,P_TASK_ID_OLD               NUMBER := null
      ,P_PROGRESS_STATUS_CODE_OLD  VARCHAR2 := null
      ,P_SHORT_DESCRIPTION_OLD     VARCHAR2 := null
      ,P_PROGRESS_ASOF_DATE_OLD    VARCHAR2 := null
      ,P_LONG_DESCRIPTION_OLD      VARCHAR2 := null
      ,P_ISSUES_OLD                VARCHAR2 := null
      ,P_ESTIMATED_START_DATE_OLD   VARCHAR2 := null
      ,P_ESTIMATED_END_DATE_OLD     VARCHAR2 := null
      ,P_ACTUAL_START_DATE_OLD      VARCHAR2 := null
      ,P_ACTUAL_END_DATE_OLD        VARCHAR2 := null
      ,P_PERCENT_COMPLETE_OLD       NUMBER := null
      ,P_ESTIMATE_TO_COMPLETE_OLD   NUMBER := null
      ,P_UNIT_TYPE_OLD              VARCHAR2 := null
      ,p_wf_status_code_old         VARCHAR2 := null
      ,p_wf_item_type_old           VARCHAR2 := null
      ,p_wf_item_key_old            NUMBER := NULL
      ,p_wf_process_old             VARCHAR2 := null
      ,P_PROJECT_ID_NEW              NUMBER := null
      ,P_TASK_ID_NEW                 NUMBER := null
      ,P_PROGRESS_STATUS_CODE_NEW    VARCHAR2 := null
      ,P_SHORT_DESCRIPTION_NEW       VARCHAR2 := null
      ,P_PROGRESS_ASOF_DATE_NEW      VARCHAR2 := null
      ,P_LONG_DESCRIPTION_NEW        VARCHAR2 := null
      ,P_ISSUES_NEW                  VARCHAR2 := null
      ,P_ESTIMATED_START_DATE_NEW     VARCHAR2 := null
      ,P_ESTIMATED_END_DATE_NEW       VARCHAR2 := null
      ,P_ACTUAL_START_DATE_NEW        VARCHAR2 := null
      ,P_ACTUAL_END_DATE_NEW          VARCHAR2 := null
      ,P_PERCENT_COMPLETE_NEW         NUMBER := null
      ,P_ESTIMATE_TO_COMPLETE_NEW     NUMBER := null
      ,P_UNIT_TYPE_NEW                VARCHAR2 := null
      ,p_wf_status_code_new             VARCHAR2 := null
      ,p_wf_item_type_new               VARCHAR2 := null
      ,p_wf_item_key_new                NUMBER := null
      ,p_wf_process_new                VARCHAR2 := null
      ,p_create_item_key_flag    VARCHAR2 := 'N'
      ,x_item_key             OUT number
      ,X_RETURN_STATUS        OUT VARCHAR2
      ,X_MSG_COUNT            IN OUT NUMBER
      ,X_MSG_DATA             IN OUT pa_vc_1000_2000
                                   )
  IS
       CURSOR C IS
        SELECT *
        FROM   PA_PROJ_PROGRESS_REPORTS
        WHERE  project_id = P_project_id_old
        AND    task_id = p_task_id_old
        FOR UPDATE of progress_status_code NOWAIT;
   Recinfo C%ROWTYPE;
   SAVEPOINT_TAG     	    varchar2(60);
   l_short_description_old  PA_PROJ_PROGRESS_REPORTS.short_description%TYPE;
   l_progress_asof_date_old date;
--   l_progress_asof_date_new date;
   l_long_description_old   PA_PROJ_PROGRESS_REPORTS.long_description%TYPE;
   l_issues_old  	    PA_PROJ_PROGRESS_REPORTS.issues%TYPE;
   l_estimated_start_date_old   date;
   l_estimated_end_date_old     date;
   l_actual_start_date_old      date;
   l_actual_end_date_old        date;
   l_percent_complete_old       PA_PROJ_PROGRESS_REPORTS.percent_complete%TYPE;
   l_estimate_to_complete_old   PA_PROJ_PROGRESS_REPORTS.estimate_to_complete%TYPE;
   l_unit_type_old              PA_PROJ_PROGRESS_REPORTS.unit_type%TYPE;
   l_wf_status_code_old             PA_PROJ_PROGRESS_REPORTS.wf_status_code%TYPE;
   --l_wf_item_type_old             PA_PROJ_PROGRESS_REPORTS.wf_item_type%TYPE;
   --l_wf_item_key_old             PA_PROJ_PROGRESS_REPORTS.wf_item_key%TYPE;
   --l_wf_process_old              PA_PROJ_PROGRESS_REPORTS.wf_process%TYPE;

   l_wf_item_key_new number;

  BEGIN

     --debug_msg ('In update_progress_report');

     l_wf_item_key_new :=  p_wf_item_key_new;

     IF p_create_item_key_flag = 'Y' THEN
    	 SELECT pa_workflow_itemkey_s.nextval
	         INTO l_wf_item_key_new
	          from dual;
         x_item_key := l_wf_item_key_new;
     ELSE
         l_wf_item_key_new :=  p_wf_item_key_new;
     END IF;

     --debug_msg ('In update_progress_report 2');


  --debug_msg ('******** In Progress Update Public API  **********');
    x_return_status := 'S';
  --Validate the parameters - Project ID
  If (   P_PROJECT_ID_OLD is null
      OR P_PROJECT_ID_NEW is null
      OR P_PROJECT_ID_OLD <> P_PROJECT_ID_NEW) then
      FND_MESSAGE.Set_Name('PA', 'PA_XC_INVALID_PROJECT_ID');
      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
      x_msg_data(x_msg_count) := FND_MESSAGE.get;
      x_return_status := 'E';
  end if;

 --Validate the parameters - Task ID
  If (   P_TASK_ID_OLD is null
      OR P_TASK_ID_NEW is null
      OR P_TASK_ID_OLD <> P_TASK_ID_NEW) then
      FND_MESSAGE.Set_Name('PA', 'PA_XC_INVALID_TASK_ID');
      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
      x_msg_data(x_msg_count) := FND_MESSAGE.get;
      x_return_status := 'E';
  end if;

  --Validate Date values are in canonical format
  if(p_debug_mode = 'Y') then
     pa_debug.debug('Validating Date Format');
  end if;
  Begin
    if(P_PROGRESS_ASOF_DATE_OLD is not null) then
      l_progress_asof_date_old := fnd_date.canonical_to_date(P_PROGRESS_ASOF_DATE_OLD);
    end if;
    if(P_ESTIMATED_START_DATE_OLD is not null) then
      l_estimated_start_date_old := fnd_date.canonical_to_date(P_ESTIMATED_START_DATE_OLD);
    end if;
    if(P_ESTIMATED_END_DATE_OLD is not null) then
      l_estimated_end_date_old := fnd_date.canonical_to_date(P_ESTIMATED_END_DATE_OLD);
    end if;
    if(P_ACTUAL_START_DATE_OLD is not null) then
      l_actual_start_date_old := fnd_date.canonical_to_date(P_ACTUAL_START_DATE_OLD);
    end if;
    if(P_ACTUAL_END_DATE_OLD is not null) then
      l_actual_end_date_old := fnd_date.canonical_to_date(P_ACTUAL_END_DATE_OLD);
    end if;
  Exception
    when others then
      FND_MESSAGE.Set_Name('PA', 'PA_SU_INVALID_DATES');
      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
      x_msg_data(x_msg_count) := FND_MESSAGE.get;
      x_return_status := 'E';
  End ;
  --Validating New progress code
  if(p_debug_mode = 'Y') then
     pa_debug.debug('Validating Progress Code');
  end if;
  if(NOT is_valid_progress_code(P_PROGRESS_STATUS_CODE_NEW)) then
     FND_MESSAGE.set_name('PA','PA_XC_INVALID_PROGRESS_CODE');
     x_msg_count := x_msg_count + 1;
     x_msg_data.extend(1);
     x_msg_data(x_msg_count) := FND_MESSAGE.get;
     x_return_status := 'E';
  end if;
--debug_msg ('Progress : Validating Estimated Start Date');
  --Validate Estimated Start and End Date
  if(p_debug_mode = 'Y') then
     pa_debug.debug('Validating Estimated Start and End Date');
  end if;
  if ( P_ESTIMATED_START_DATE_NEW is not null
       AND P_ESTIMATED_END_DATE_NEW is not null
       AND trunc(fnd_date.canonical_to_date(P_ESTIMATED_START_DATE_NEW)) > trunc(fnd_date.canonical_to_date(P_ESTIMATED_END_DATE_NEW))) then
     FND_MESSAGE.set_name('PA','PA_XC_ET_STARTDATE_GT_ENDDATE');
     x_msg_count := x_msg_count + 1;
     x_msg_data.extend(1);
     x_msg_data(x_msg_count) := FND_MESSAGE.get;
     x_return_status := 'E';
  end if;

  --Validate Actual Start and End Date
  if(p_debug_mode = 'Y') then
     pa_debug.debug('Validating Actual Start and End Date');
  end if;
  if(P_ACTUAL_START_DATE_NEW is not null
     AND P_ACTUAL_END_DATE_NEW is not null
     AND trunc(fnd_date.canonical_to_date(P_ACTUAL_START_DATE_NEW)) > trunc(fnd_date.canonical_to_date(P_ACTUAL_END_DATE_NEW)) ) then
     FND_MESSAGE.set_name('PA','PA_XC_AC_STARTDATE_GT_ENDDATE');
     x_msg_count := x_msg_count + 1;
     x_msg_data.extend(1);
     x_msg_data(x_msg_count) := FND_MESSAGE.get;
     x_return_status := 'E';
  end if;

  --Validate Percent Comolete
  if(p_debug_mode = 'Y') then
     pa_debug.debug('Validating Percent Complete');
  end if;
  if(nvl(P_PERCENT_COMPLETE_NEW,0) < 0 OR nvl(P_PERCENT_COMPLETE_NEW,0) > 100) then
     FND_MESSAGE.set_name('PA','PA_XC_INVALID_PERCENT_COMPLETE');
     x_msg_count := x_msg_count + 1;
     x_msg_data.extend(1);
     x_msg_data(x_msg_count) := FND_MESSAGE.get;
     x_return_status := 'E';
  end if;
  if (P_ACTUAL_START_DATE_NEW is not null
      AND nvl(P_PERCENT_COMPLETE_NEW,0) > 0
      AND trunc(fnd_date.canonical_to_date(P_ACTUAL_START_DATE_NEW)) > trunc(fnd_date.canonical_to_date(P_PROGRESS_ASOF_DATE_NEW))) then
     FND_MESSAGE.set_name('PA','PA_XC_HAVE_NOT_STARTED');
     x_msg_count := x_msg_count + 1;
     x_msg_data.extend(1);
     x_msg_data(x_msg_count) := FND_MESSAGE.get;
     x_return_status := 'E';
  end if;
  if (P_ACTUAL_END_DATE_NEW  is not null
      AND nvl(P_PERCENT_COMPLETE_NEW,0) = 100
      AND trunc(fnd_date.canonical_to_date(P_ACTUAL_END_DATE_NEW)) > trunc(fnd_date.canonical_to_date(P_PROGRESS_ASOF_DATE_NEW))) then
     FND_MESSAGE.set_name('PA','PA_XC_HAVE_NOT_COMPLETED');
     x_msg_count := x_msg_count + 1;
     x_msg_data.extend(1);
     x_msg_data(x_msg_count) := FND_MESSAGE.get;
     x_return_status := 'E';
  end if;
  if (P_ACTUAL_END_DATE_NEW is not null
      AND nvl(P_PERCENT_COMPLETE_NEW,0) < 100
      AND trunc(fnd_date.canonical_to_date(P_ACTUAL_END_DATE_NEW)) <= trunc(fnd_date.canonical_to_date(P_PROGRESS_ASOF_DATE_NEW))) then
     FND_MESSAGE.set_name('PA','PA_XC_HAVE_ALREADY_COMPLETED');
     x_msg_count := x_msg_count + 1;
     x_msg_data.extend(1);
     x_msg_data(x_msg_count) := FND_MESSAGE.get;
     x_return_status := 'E';
  end if;


  --Return the control if there is an error else continue
  if(x_return_status <> 'S') then
    return;
  end if;

  --debug_msg ('In update_progress_report 3');

-- dbms_output.put_line('NO ERROR');
--debug_msg ('Progress : Comparing old and new values');
  If( P_PROJECT_ID_OLD = P_PROJECT_ID_NEW
  AND P_TASK_ID_OLD = P_TASK_ID_NEW
  AND (   P_PROGRESS_STATUS_CODE_OLD <> P_PROGRESS_STATUS_CODE_NEW
   OR nvl(P_SHORT_DESCRIPTION_OLD,'#!#') <> nvl(P_SHORT_DESCRIPTION_NEW,'#!#')
   OR nvl(P_PROGRESS_ASOF_DATE_OLD,'#!#') <> nvl(P_PROGRESS_ASOF_DATE_NEW,'#!#')
   OR nvl(P_LONG_DESCRIPTION_OLD,'#!#') <> nvl(P_LONG_DESCRIPTION_NEW,'#!#')
   OR nvl(P_ISSUES_OLD,'#!#') <> nvl(P_ISSUES_NEW,'#!#')
   OR nvl(P_ESTIMATED_START_DATE_OLD,'#!#') <> nvl(P_ESTIMATED_START_DATE_NEW,'#!#')
   OR nvl(P_ESTIMATED_END_DATE_OLD,'#!#') <> nvl(P_ESTIMATED_END_DATE_NEW,'#!#')
   OR nvl(P_ACTUAL_START_DATE_OLD,'#!#') <> nvl(P_ACTUAL_START_DATE_NEW,'#!#')
   OR nvl(P_ACTUAL_END_DATE_OLD,'#!#') <> nvl(P_ACTUAL_END_DATE_NEW,'#!#')
   OR nvl(P_PERCENT_COMPLETE_OLD,0) <> nvl(P_PERCENT_COMPLETE_NEW,0)
   OR nvl(P_ESTIMATE_TO_COMPLETE_OLD,0) <> nvl(P_ESTIMATE_TO_COMPLETE_NEW,0)
   OR nvl(P_UNIT_TYPE_OLD,'#!#') <> nvl(P_UNIT_TYPE_NEW,'#!#')
   OR nvl(P_wf_status_code_old,'#!#') <> nvl(P_wf_status_code_NEW,'#!#')
   OR nvl(P_wf_item_type_old,'#!#') <> nvl(P_wf_item_type_NEW,'#!#')
   OR nvl(P_wf_item_key_old,0) <> nvl(P_wf_item_key_NEW,0)
   OR nvl(P_wf_process_old,'#!#') <> nvl(P_wf_process_NEW,'#!#')
    )
    ) then
--debug_msg ('Progress : Change exists in the record');

-- Issue a save point for the project , task
      SAVEPOINT_TAG := 'PAXC_'||to_char(p_project_id_old)||to_char(p_task_id_old);
        SAVEPOINT SAVEPOINT_TAG;
        if(p_debug_mode = 'Y') then
    pa_debug.debug('Obtaining Lock for Project:'||to_char(p_project_id_old)||'Task:'||to_char(p_task_id_old));
        end if;
        --Obtain the lock
         OPEN C;
         FETCH C INTO Recinfo;
         if (C%NOTFOUND) then
           CLOSE C;
           FND_MESSAGE.Set_Name('PA', 'PA_XC_NO_DATA_FOUND');
           x_msg_count := x_msg_count + 1;
           x_msg_data.extend(1);
           x_msg_data(x_msg_count) := FND_MESSAGE.get;
           x_return_status := 'E';
--           dbms_output.put_line('NODATAFOUND Rollback');
           ROLLBACK TO SAVEPOINT SAVEPOINT_TAG;
           if(p_debug_mode = 'Y') then
 pa_debug.debug('Unable to Lock record for Project:'||to_char(p_project_id_old)||'Task:'||to_char(p_task_id_old));
           end if;
           return;
         end if;
         CLOSE C;
        --Compare values with DB
	if(p_debug_mode = 'Y') then
          pa_debug.debug('Comparing old values with database');
        end if;
       --Compare the old and new values and if both are null assign the Data base value
       -- to old value and then compare with the Data base for changed records.
--debug_msg ('Progress : Setting the local variables if null');
       if(p_short_description_old is null AND p_short_description_new is null) then
          l_short_description_old := Recinfo.short_description;
       else
          l_short_description_old := p_short_description_old;
       end if;
       if(p_long_description_old is null AND p_long_description_new is null) then
          l_long_description_old := Recinfo.long_description;
       else
          l_long_description_old := p_long_description_old;
       end if;
       if(p_issues_old is null AND p_issues_new is null) then
          l_issues_old := Recinfo.issues;
       else
          l_issues_old :=p_issues_old;
       end if;
       if(p_progress_asof_date_old is null AND p_progress_asof_date_new is null) then
          l_progress_asof_date_old := Recinfo.progress_asof_date;
       end if;
--debug_msg ('Progress : Setting the local variables for dates');

       if(p_estimated_start_date_old is null AND p_estimated_start_date_new is null) then
          l_estimated_start_date_old := Recinfo.estimated_start_date;
        end if;
       if(p_estimated_end_date_old is null AND p_estimated_end_date_new is null) then
          l_estimated_end_date_old := Recinfo.estimated_end_date;
       end if;
       if(p_actual_start_date_old is null AND p_actual_start_date_new is null) then
          l_actual_start_date_old := Recinfo.actual_start_date;
       end if;
       if(p_actual_end_date_old is null AND p_actual_end_date_new is null) then
          l_actual_end_date_old := Recinfo.actual_end_date;
       end if;
--debug_msg ('Progress : After Setting the local variables for dates');
       if(p_percent_complete_old is null AND p_percent_complete_new is null) then
          l_percent_complete_old := Recinfo.percent_complete;
       else
          l_percent_complete_old :=  p_percent_complete_old;
       end if;

       if(p_estimate_to_complete_old is null AND p_estimate_to_complete_new is null) then
          l_estimate_to_complete_old := Recinfo.estimate_to_complete;
       else
          l_estimate_to_complete_old := p_estimate_to_complete_old;
       end if;

       if(p_unit_type_old is null AND p_unit_type_new is null) then
           l_unit_type_old := Recinfo.unit_type;
       else
           l_unit_type_old := p_unit_type_old;
       end if;

       if(p_wf_status_code_old is null AND p_wf_status_code_new is null) then
           l_wf_status_code_old := Recinfo.wf_status_code;
       else
           l_wf_status_code_old := p_wf_status_code_old;
       end if;
       ****/

       /*
       if(p_wf_item_type_old is null AND p_wf_item_type_new is null) then
           l_wf_item_type_old := Recinfo.wf_item_type;
       else
           l_wf_item_type_old := p_wf_item_type_old;
       end if;


       if(p_wf_item_key_old is null AND p_wf_item_key_new is null) then
           l_wf_item_key_old := Recinfo.wf_item_key;
       else
           l_wf_item_key_old := p_wf_item_key_old;
       end if;


       if(p_wf_process_old is null AND p_wf_process_new is null) then
           l_wf_process_old := Recinfo.wf_process;
       else
           l_wf_process_old := p_wf_process_old;
       end if;
       */

	 --debug_msg ('In update_progress_report 4');

     /*** Commented
	 if (  (Recinfo.PROJECT_id = p_project_Id_old)
           AND (Recinfo.task_id = p_task_id_old)
           AND (Recinfo.progress_status_code = p_progress_status_code_old)
           AND (   (Recinfo.short_description =  l_short_description_old)
                OR (    (Recinfo.short_description IS NULL)
                    AND (l_short_description_old IS NULL)))
        AND (trunc(Recinfo.progress_asof_date) = trunc(l_progress_asof_date_old))
           AND (   (Recinfo.long_description =  l_long_description_old)
          	      OR (    (Recinfo.long_description IS NULL)
                    AND (l_long_description_old IS NULL)))
           AND (   (Recinfo.issues =  l_issues_old)
                OR (    (Recinfo.issues IS NULL)
                    AND (l_issues_old IS NULL)))
           AND (   (trunc(Recinfo.estimated_start_date) =  trunc(l_estimated_start_date_old))
                OR (    (Recinfo.estimated_start_date IS NULL)
                    AND (l_estimated_start_date_old IS NULL)) )
           AND (   (trunc(Recinfo.estimated_end_date) =  trunc(l_estimated_end_date_old))
                OR (    (Recinfo.estimated_end_date IS NULL)
                    AND (l_estimated_end_date_old IS NULL)) )
           AND (   (trunc(Recinfo.actual_start_date) =  trunc(l_actual_start_date_old))
                OR (    (Recinfo.actual_start_date IS NULL)
                    AND (l_actual_start_date_old IS NULL))  )
           AND (   (trunc(Recinfo.actual_end_date) =  trunc(l_actual_end_date_old))
                OR (    (Recinfo.actual_end_date IS NULL)
                    AND (l_actual_end_date_old IS NULL))  )
           AND (   (Recinfo.percent_complete =  l_percent_complete_old)
                OR (    (Recinfo.percent_complete IS NULL)
                    AND (l_percent_complete_old IS NULL)))
           AND (   (Recinfo.estimate_to_complete =  l_estimate_to_complete_old)
                OR (    (Recinfo.estimate_to_complete IS NULL)
			AND (l_estimate_to_complete_old IS NULL)))

	   AND (   (Recinfo.wf_status_code =  l_wf_status_code_old)
                OR (    (recinfo.wf_status_code IS NULL)
			AND ( l_wf_status_code_old IS NULL)))

	   --AND (   (Recinfo.wf_item_type =  l_wf_item_type_old)
           --     OR (    (Recinfo.wf_item_type IS NULL)
	--		AND (l_wf_item_type_old IS NULL)))
	   --AND (   (Recinfo.wf_item_key =  l_wf_item_key_old)
           --     OR (    (Recinfo.wf_item_key IS NULL)
	   --	AND (l_wf_item_key_old IS NULL)))
	   --AND (   (Recinfo.new_prog_status_code =  l_new_prog_status_code_old)
            --    OR (    (Recinfo.new_prog_status_code IS NULL)
		--	AND (l_new_prog_status_code_old IS NULL)))

	   --AND (   (Recinfo.unit_type =  l_unit_type_old)
           --     OR (    (Recinfo.unit_type IS NULL)
           --         AND (l_unit_type_old IS NULL)))
        ) then
       --Call the Update
       if(p_debug_mode = 'Y') then
        pa_debug.debug('Updating The record');
       end if;
       --Call the Update

       --debug_msg ('before update_row');

       PA_XC_PRJ_PROGRESS_REPORTS_PKG.Update_Row(
                         P_PROJECT_ID_NEW
                        ,P_TASK_ID_NEW
                        ,P_PROGRESS_STATUS_CODE_NEW
                        ,P_SHORT_DESCRIPTION_NEW
                        ,fnd_date.canonical_to_date(P_PROGRESS_ASOF_DATE_NEW)
                        ,P_LONG_DESCRIPTION_NEW
                        ,P_ISSUES_NEW
                        ,fnd_date.canonical_to_date(P_ESTIMATED_START_DATE_NEW)
                        ,fnd_date.canonical_to_date(P_ESTIMATED_END_DATE_NEW)
                        ,fnd_date.canonical_to_date(P_ACTUAL_START_DATE_NEW)
                        ,fnd_date.canonical_to_date(P_ACTUAL_END_DATE_NEW)
                        ,P_PERCENT_COMPLETE_NEW
			,P_ESTIMATE_TO_COMPLETE_NEW
			,p_unit_type_new
			,p_wf_status_code_new
			,p_wf_item_type_new
			,l_wf_item_key_new
			,p_wf_process_new
		        ,P_USER_ID
                        ,sysdate
                        ,P_USER_ID
	 );

       --debug_msg ('after update_row');
    ELSE

	    --debug_msg ('In update_progress_report 13');

      FND_MESSAGE.Set_Name('PA', 'PA_XC_RECORD_CHANGED');
      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
      x_msg_data(x_msg_count) := FND_MESSAGE.get;
      x_return_status := 'E';
--      dbms_output.put_line('record has been changed');
      ROLLBACK TO SAVEPOINT SAVEPOINT_TAG;
      if(p_debug_mode = 'Y') then
        pa_debug.debug('Record modified by another user');
      end if;
      return;
    end if;

    if(p_commit_flag = 'Y') THEN
       commit;
    end if;
   end if;
  EXCEPTION
     WHEN TIMEOUT_ON_RESOURCE then
      FND_MESSAGE.Set_Name('PA', 'PA_XC_ROW_ALREADY_LOCKED');
      --FND_MESSAGE.Set_token('ENTITY', 'PA_PROJ_PROGRESS_REPORTS');
      --FND_MESSAGE.Set_token('PROJECT',to_char(P_PROJECT_ID_OLD));
      --FND_MESSAGE.Set_token('TASK',to_char(P_TASK_ID_OLD));
      x_msg_count := x_msg_count + 1;
      x_msg_data.extend(1);
      x_msg_data(x_msg_count) := FND_MESSAGE.get;
      x_return_status := 'E';
--      dbms_output.put_line('timeout on resource');
     WHEN OTHERS then
      if(SQLCODE = -54) then
       FND_MESSAGE.Set_Name('PA', 'PA_XC_ROW_ALREADY_LOCKED');
      --FND_MESSAGE.Set_token('ENTITY', 'PA_PROJ_PROGRESS_REPORTS');
      --FND_MESSAGE.Set_token('PROJECT',to_char(P_PROJECT_ID_OLD));
      --FND_MESSAGE.Set_token('TASK',to_char(P_TASK_ID_OLD));

        x_msg_count := x_msg_count + 1;
        x_msg_data.extend(1);
        x_msg_data(x_msg_count) := FND_MESSAGE.get;
        x_return_status := 'E';
--        dbms_output.put_line('row already locked');
      else
        x_msg_count := x_msg_count + 1;
        x_msg_data.extend(1);
        x_msg_data(x_msg_count) := substr(SQLERRM,1,2000);
        x_return_status := 'U';
      end if;
  END update_progress_report;

/* Private APIs    */

  PROCEDURE Insert_Row(
            -- P_ROWID       IN OUT   VARCHAR2
             P_PROGRESS_REPORT_ID   IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,P_RECORD_VERSION_NUMBER NUMBER DEFAULT 1
	    ,P_PROJECT_ID           NUMBER
	    ,P_TASK_ID              NUMBER default 0
	    ,P_PROGRESS_STATUS_CODE VARCHAR2 default 'ON_TRACK'
	    ,P_SHORT_DESCRIPTION    VARCHAR2 default null
	    ,P_PROGRESS_ASOF_DATE   DATE default sysdate
	    ,P_LONG_DESCRIPTION     VARCHAR2 default null
	    ,P_ISSUES               VARCHAR2 default null
            ,P_ESTIMATED_START_DATE DATE default null
            ,P_ESTIMATED_END_DATE   DATE default null
            ,P_ACTUAL_START_DATE    DATE default null
            ,P_ACTUAL_END_DATE      DATE default null
            ,P_PERCENT_COMPLETE     NUMBER default null
            ,P_ESTIMATE_TO_COMPLETE NUMBER default null
            ,P_UNIT_TYPE            VARCHAR2 default null
            ,P_PLANNED_ACTIVITIES   VARCHAR2 DEFAULT NULL
            ,P_REPORT_STATUS        VARCHAR2 DEFAULT 'WIP'
            ,P_CREATED_BY           NUMBER default -1
	    ,P_CREATION_DATE        DATE default sysdate
	    ,P_LAST_UPDATED_BY      NUMBER default -1
	    ,P_LAST_UPDATE_DATE     DATE default sysdate
	    ,P_LAST_UPDATE_LOGIN    NUMBER default -1
            ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count              OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

                       )
  IS
   l_progress_report_id number;
   l_row_id varchar2(40);
   CURSOR C IS SELECT rowid FROM PA_PROJ_PROGRESS_REPORTS
                 WHERE progress_report_id = l_progress_report_id;
   BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Fetch the next sequence number for progres report
    SELECT PA_PROJ_PROGRESS_REPORTS_S.NEXTVAL
    INTO   l_progress_report_id
    FROM   dual;

       INSERT INTO PA_PROJ_PROGRESS_REPORTS(
                         PROGRESS_REPORT_ID
                        ,RECORD_VERSION_NUMBER
                        ,PROJECT_ID
                        ,TASK_ID
                        ,PROGRESS_STATUS_CODE
                        ,SHORT_DESCRIPTION
                        ,PROGRESS_ASOF_DATE
                        ,LONG_DESCRIPTION
                        ,ISSUES
                        ,ESTIMATED_START_DATE
                        ,ESTIMATED_END_DATE
                        ,ACTUAL_START_DATE
                        ,ACTUAL_END_DATE
                        ,PERCENT_COMPLETE
                        ,ESTIMATE_TO_COMPLETE
                        ,UNIT_TYPE
                        ,PLANNED_ACTIVITIES
                        ,REPORT_STATUS
                        ,CREATED_BY
                        ,CREATION_DATE
                        ,LAST_UPDATED_BY
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATE_LOGIN
             ) VALUES (
                         L_PROGRESS_REPORT_ID
                        ,P_RECORD_VERSION_NUMBER
                        ,P_PROJECT_ID
                        ,P_TASK_ID
                        ,P_PROGRESS_STATUS_CODE
                        ,P_SHORT_DESCRIPTION
                        ,trunc(P_PROGRESS_ASOF_DATE)
                        ,P_LONG_DESCRIPTION
                        ,P_ISSUES
                      ,trunc(P_ESTIMATED_START_DATE)
                      ,trunc(P_ESTIMATED_END_DATE)
                      ,trunc(P_ACTUAL_START_DATE)
                      ,trunc(P_ACTUAL_END_DATE)
                      ,P_PERCENT_COMPLETE
                      ,P_ESTIMATE_TO_COMPLETE
                      ,P_UNIT_TYPE
                      ,P_PLANNED_ACTIVITIES
                        ,P_REPORT_STATUS
                        ,P_CREATED_BY
                        ,P_CREATION_DATE
                        ,P_LAST_UPDATED_BY
                        ,P_LAST_UPDATE_DATE
                        ,P_LAST_UPDATE_LOGIN
             );
    OPEN C;
    FETCH C INTO l_Row_id;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
 EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

  END Insert_Row;

  PROCEDURE Update_Row(
                         P_PROGRESS_REPORT_ID   NUMBER
                        ,P_RECORD_VERSION_NUMBER NUMBER
		        ,P_PROJECT_ID           NUMBER
                        ,P_TASK_ID              NUMBER
                        ,P_PROGRESS_STATUS_CODE VARCHAR2
                        ,P_SHORT_DESCRIPTION    VARCHAR2
                        ,P_PROGRESS_ASOF_DATE   DATE
                        ,P_LONG_DESCRIPTION     VARCHAR2
                        ,P_ISSUES               VARCHAR2
		        ,P_ESTIMATED_START_DATE     DATE default trunc(to_date('01/01/1851','DD/MM/YYYY'))
                        ,P_ESTIMATED_END_DATE       DATE default trunc(to_date('01/01/1851','DD/MM/YYYY'))
                        ,P_ACTUAL_START_DATE        DATE default trunc(to_date('01/01/1851','DD/MM/YYYY'))
                        ,P_ACTUAL_END_DATE          DATE default trunc(to_date('01/011851','DD/MM/YYYY'))
                        ,P_PERCENT_COMPLETE         NUMBER default -9999
                        ,P_ESTIMATE_TO_COMPLETE     NUMBER default -9999
                        ,P_UNIT_TYPE                VARCHAR2 default '####'
                        ,P_PLANNED_ACTIVITIES   VARCHAR2 default '####'
                        ,P_REPORT_STATUS        VARCHAR2 default '####'
		        ,p_wf_status_code          VARCHAR2 default '####'
		        ,p_wf_item_type            VARCHAR2 default '####'
   		        ,p_wf_item_key             NUMBER  default -9999
		        ,p_wf_process            VARCHAR2 default '####'
                        ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_count              OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
                        ,x_msg_data               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )

  IS
    CURSOR new_wip is
      select * from
      pa_proj_progress_reports
      where progress_report_id = p_progress_report_id;
    c_rec new_wip%ROWTYPE;
    l_row_id varchar2(60);
    l_progress_report_id number := null;

  BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   UPDATE PA_PROJ_PROGRESS_REPORTS
   SET RECORD_VERSION_NUMBER = P_RECORD_VERSION_NUMBER + 1
      ,PROJECT_ID = P_PROJECT_ID
      ,TASK_ID = P_TASK_ID
      ,PROGRESS_STATUS_CODE = P_PROGRESS_STATUS_CODE
      ,SHORT_DESCRIPTION = P_SHORT_DESCRIPTION
      ,PROGRESS_ASOF_DATE = nvl(P_PROGRESS_ASOF_DATE,trunc(sysdate))
      ,LONG_DESCRIPTION = P_LONG_DESCRIPTION
      ,ISSUES = P_ISSUES
      ,ESTIMATED_START_DATE = decode( to_char(P_ESTIMATED_START_DATE,'DD/MM/YYYY'), '01/01/1851', trunc(ESTIMATED_START_DATE), trunc(P_ESTIMATED_START_DATE))
      ,ESTIMATED_END_DATE = decode( to_char(P_ESTIMATED_END_DATE,'DD/MM/YYYY'), '01/01/1851', trunc(ESTIMATED_END_DATE), trunc(P_ESTIMATED_END_DATE) )
      ,ACTUAL_START_DATE = decode( to_char(P_ACTUAL_START_DATE,'DD/MM/YYYY'), '01/01/1851', trunc(ACTUAL_START_DATE), trunc(P_ACTUAL_START_DATE) )
      ,ACTUAL_END_DATE = decode( to_char(P_ACTUAL_END_DATE,'DD/MM/YYYY'), '01/01/1851', trunc(ACTUAL_END_DATE), trunc(P_ACTUAL_END_DATE) )
      ,PERCENT_COMPLETE = decode( P_PERCENT_COMPLETE, -9999, PERCENT_COMPLETE, P_PERCENT_COMPLETE )
      ,ESTIMATE_TO_COMPLETE = decode( P_ESTIMATE_TO_COMPLETE, -9999, ESTIMATE_TO_COMPLETE, P_ESTIMATE_TO_COMPLETE )
      ,UNIT_TYPE = decode( P_UNIT_TYPE, '####', UNIT_TYPE, P_UNIT_TYPE )
      ,PLANNED_ACTIVITIES = decode(P_PLANNED_ACTIVITIES ,'####',PLANNED_ACTIVITIES,P_PLANNED_ACTIVITIES)
      ,REPORT_STATUS  = decode(P_REPORT_STATUS ,'####',REPORT_STATUS,P_REPORT_STATUS)
      --,wf_status_code = decode( p_wf_status_code, '####', wf_status_code, p_wf_status_code )
      --,wf_item_type = decode(p_wf_item_type, '####', wf_item_type, p_wf_item_type )
      --,wf_item_key = decode(p_wf_item_key, -9999, wf_item_key, p_wf_item_key)
      --,wf_process = decode(p_wf_process,'####', wf_process, p_wf_process)
      ,LAST_UPDATED_BY = -1
      ,LAST_UPDATE_DATE = sysdate
      ,LAST_UPDATE_LOGIN = -1
   WHERE PROGRESS_REPORT_ID = P_PROGRESS_REPORT_ID
   AND   NVL(P_RECORD_VERSION_NUMBER,RECORD_VERSION_NUMBER) = RECORD_VERSION_NUMBER;
   IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       --PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := 'PA_XC_RECORD_CHANGED';
       return;
   END IF;
   /**
   IF (P_REPORT_STATUS='PUBLISHED') then
     open new_wip;
     fetch new_wip into c_rec;
     close new_wip;
     Insert_row(
             --P_ROWID       => l_row_id
             P_PROGRESS_REPORT_ID   => l_progress_report_id
            ,P_PROJECT_ID           => c_rec.project_id
			,P_TASK_ID              => c_rec.TASK_ID
			,P_PROGRESS_STATUS_CODE => c_rec.PROGRESS_STATUS_CODE
			,P_SHORT_DESCRIPTION    => c_rec.SHORT_DESCRIPTION
			--,P_PROGRESS_ASOF_DATE   DATE default sysdate
			,P_LONG_DESCRIPTION     => c_rec.LONG_DESCRIPTION
			,P_ISSUES               => c_rec.ISSUES
            ,P_ESTIMATED_START_DATE => trunc(c_rec.ESTIMATED_START_DATE)
            ,P_ESTIMATED_END_DATE   => trunc(c_rec.ESTIMATED_END_DATE)
            ,P_ACTUAL_START_DATE    => trunc(c_rec.ACTUAL_START_DATE)
            ,P_ACTUAL_END_DATE      => trunc(c_rec.ACTUAL_END_DATE)
            ,P_PERCENT_COMPLETE     => c_rec.PERCENT_COMPLETE
            ,P_ESTIMATE_TO_COMPLETE => c_rec.ESTIMATE_TO_COMPLETE
            ,P_UNIT_TYPE            => c_rec.UNIT_TYPE
            ,P_PLANNED_ACTIVITIES   => c_rec.PLANNED_ACTIVITIES
            --,P_REPORT_STATUS        VARCHAR2 DEFAULT 'WIP'
            ,P_CREATED_BY           =>  -1
			,P_CREATION_DATE        => sysdate
			,P_LAST_UPDATED_BY     => -1
			,P_LAST_UPDATE_DATE     => sysdate
			,P_LAST_UPDATE_LOGIN    => -1
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data            => x_msg_data      );
   End if;
    **/
  --
  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
  END Update_row;


  PROCEDURE Delete_Row(  P_PROGRESS_REPORT_ID           NUMBER
                        ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                        ,x_msg_count                   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                        ,x_msg_data                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
  is
   BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    DELETE FROM PA_PROJ_PROGRESS_REPORTS
    WHERE progress_report_id = p_progress_report_id;
    IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA', p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
  END Delete_Row;

PROCEDURE Copy_lastpublished_report(
            -- P_PROGRESS_REPORT_ID   IN OUT NUMBER
		     P_PROJECT_ID           NUMBER )
			--,P_TASK_ID              NUMBER default 0
            --,P_CREATED_BY           NUMBER default -1
			--,P_CREATION_DATE        DATE default sysdate
			--,P_LAST_UPDATED_BY      NUMBER default -1
			--,P_LAST_UPDATE_DATE     DATE default sysdate
			--,P_LAST_UPDATE_LOGIN    NUMBER default -1
            --,x_return_status   OUT  VARCHAR2
            --,x_msg_count       OUT  NUMBER
            --,x_msg_data        OUT  VARCHAR2  )
 IS
    CURSOR new_wip is
      select * from
      pa_proj_progress_reports
      where progress_report_id = (select max(progress_report_id)
                                from pa_proj_progress_reports
                                where project_id = p_project_id
                                and report_status = 'PUBLISHED');
    c_rec new_wip%ROWTYPE;
    l_row_id varchar2(60);
    l_progress_report_id number := null;
    l_return_status varchar2(10);
    l_msg_count number := 0;
    l_msg_data  varchar2(200);
 BEGIN
     --debug_msu('In copy progress Report'||to_char(p_project_id));
     open new_wip;
     fetch new_wip into c_rec;
     if(new_wip%NOTFOUND) then
       --debug_msu('No data found to copy progress Report');
       close new_wip;
       return;
     end if;
     close new_wip;
     --debug_msu(' copying New progress Report');
     Insert_row(
             --P_ROWID       => l_row_id
             P_PROGRESS_REPORT_ID   => l_progress_report_id
            ,P_PROJECT_ID           => c_rec.project_id
			,P_TASK_ID              => c_rec.TASK_ID
			,P_PROGRESS_STATUS_CODE => c_rec.PROGRESS_STATUS_CODE
			,P_SHORT_DESCRIPTION    => c_rec.SHORT_DESCRIPTION
			,P_PROGRESS_ASOF_DATE   => sysdate
			,P_LONG_DESCRIPTION     => c_rec.LONG_DESCRIPTION
			,P_ISSUES               => c_rec.ISSUES
            ,P_ESTIMATED_START_DATE => trunc(c_rec.ESTIMATED_START_DATE)
            ,P_ESTIMATED_END_DATE   => trunc(c_rec.ESTIMATED_END_DATE)
            ,P_ACTUAL_START_DATE    => trunc(c_rec.ACTUAL_START_DATE)
            ,P_ACTUAL_END_DATE      => trunc(c_rec.ACTUAL_END_DATE)
            ,P_PERCENT_COMPLETE     => c_rec.PERCENT_COMPLETE
            ,P_ESTIMATE_TO_COMPLETE => c_rec.ESTIMATE_TO_COMPLETE
            ,P_UNIT_TYPE            => c_rec.UNIT_TYPE
            ,P_PLANNED_ACTIVITIES   => c_rec.PLANNED_ACTIVITIES
            ,P_REPORT_STATUS        => 'WIP'
            ,P_CREATED_BY           =>  -1
			,P_CREATION_DATE        => sysdate
			,P_LAST_UPDATED_BY      => -1
			,P_LAST_UPDATE_DATE     => sysdate
			,P_LAST_UPDATE_LOGIN    => -1
            ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data            =>  l_msg_data      );
            commit;
     --dbms_output.put_line('In package End of Copy last published report');
     --debug_msu('In package End of Copy last published report');
 END Copy_lastpublished_report;
END PA_PRJ_PROGRESS_REPORTS_PKG;

/
