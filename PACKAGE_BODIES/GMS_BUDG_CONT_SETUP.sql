--------------------------------------------------------
--  DDL for Package Body GMS_BUDG_CONT_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BUDG_CONT_SETUP" AS
-- $Header: gmsbudcb.pls 120.3 2006/04/25 04:44:49 cmishra noship $

-- Bug 5162777: To check whether to print debug messages in log file or not
L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

procedure insert_rec(x_project_id			NUMBER
                     ,x_funds_control_code	VARCHAR2
                     ,x_award_id			NUMBER
                     ,x_task_id				NUMBER
                     ,x_parent_member_id		NUMBER
                     ,x_resource_list_member_id		NUMBER)  IS

-- Bug 5162777 : This procedure is made autonomous.
 PRAGMA AUTONOMOUS_TRANSACTION;

Begin
  insert into gms_budgetary_controls  (	BUDGETARY_CONTROLS_ID
 					,PROJECT_ID
					,FUNDS_CONTROL_LEVEL_CODE
					,AWARD_ID
					,LAST_UPDATE_DATE
					,LAST_UPDATED_BY
					,CREATED_BY
					,CREATION_DATE
					,LAST_UPDATE_LOGIN
					,TASK_ID
					,PARENT_MEMBER_ID
					,RESOURCE_LIST_MEMBER_ID
				      )
                              values  ( gms_budgetary_controls_s.nextval
                                        ,x_project_id
                                        ,x_funds_control_code
					,x_award_id
					,SYSDATE
					,FND_GLOBAL.USER_ID
					,FND_GLOBAL.USER_ID
					,SYSDATE
					,FND_GLOBAL.LOGIN_ID
					,x_task_id
					,x_parent_member_id
					,x_resource_list_member_id
				      );

COMMIT;
End;

-------------------------------------------------------------------------------
/* Bug 5162777 : The procedure del_bc_rec_for_reset_auto is created to delete BC records in autonomous mode
                  during budgetary control reset. */

  PROCEDURE del_bc_rec_for_reset_auto
                          (p_project_id             IN	NUMBER
			   ,p_award_id              IN	NUMBER )
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

   delete from gms_budgetary_controls
   where  project_id = p_project_id
   and    award_id = p_award_id;

   COMMIT;
  END del_bc_rec_for_reset_auto;

-------------------------------------------------------------------------
/* Bug 5162777 : The procedure del_bc_rec_for_task_auto is created to delete
                  all the dangling records from budgetary controls. */

  PROCEDURE del_bc_rec_for_task_auto
                          (p_project_id             IN	NUMBER
			   ,p_award_id 	            IN	NUMBER
			   ,p_entry_level_code      IN	PA_BUDGET_ENTRY_METHODS.ENTRY_LEVEL_CODE%type)
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

  DELETE from gms_budgetary_controls bc
	WHERE EXISTS
	( SELECT  pt2.task_id
	    FROM  pa_tasks pt2
	    WHERE bc.task_id=pt2.parent_task_id
	      AND ((p_entry_level_code = 'L') OR
		   (p_entry_level_code = 'M' AND exists (select 1 from pa_tasks pt1
							 where bc.task_id = pt1.task_id
							and pt1.parent_task_id IS NOT NULL))))
	 AND bc.project_id = p_project_id
	 AND bc.award_id = p_award_id;

   COMMIT;
  END del_bc_rec_for_task_auto;

-----------------------------------------------------------------------------------

procedure create_records (x_project_id  		NUMBER
			  ,x_award_id			NUMBER
			  ,x_entry_level_code 		VARCHAR2
                          ,x_resource_list_Id		NUMBER
			  ,x_group_resource_type_id	NUMBER
			  ,p_calling_mode     IN        VARCHAR2 DEFAULT 'BASELINE'
			  ,RETCODE 			OUT NOCOPY NUMBER
			  ,ERRBUF  			OUT NOCOPY VARCHAR2) IS
  x_funds_control_code_awd 	varchar2(30);
  x_funds_control_code_tsk 	varchar2(30);
  x_funds_control_code_resgrp 	varchar2(30);
  x_funds_control_code_res 	varchar2(30);

/*  Bug 5132850 :
   cursor c_tasks_no_bc fetches all the tasks for which there exists no records in pa_budgetary_controls.
   cursor c_res_resgrp_no_bc fetches all the resources and resource groups for which there exists no records in pa_budgetary_controls.
   cursor c_res_resgrp_all fetches all the resources and resource groups for a particular resource_list_id.
   cursor c_tasks_for_new_resource fetches all the tasks for which there exists records in pa_budgetary_controls. */

cursor c_tasks_no_bc is
SELECT
    pt1.task_id,
    pt1.top_task_id
FROM pa_tasks pt1
WHERE pt1.project_id = x_project_id
    AND
    (   (x_entry_level_code IN ( 'T' ,'M') AND  pt1.parent_task_id is null )
        OR
        (x_entry_level_code IN ('L','M')
          AND NOT EXISTS
          ( SELECT
                pt2.task_id
            FROM pa_tasks pt2
            WHERE pt1.task_id=pt2.parent_task_id)
         )
    )
    AND not exists
          ( SELECT 1
            FROM gms_budgetary_controls bc
            WHERE bc.project_id = x_project_id
                AND bc.award_id = x_award_id
                AND bc.task_id = pt1.task_id
           );

 cursor c_res_resgrp_no_bc IS
  SELECT br.resource_list_member_id,
         DECODE(x_group_resource_type_id,0,decode(nvl(br.parent_member_id,0),0,-1) --uncategorized
	                                ,NVL(br.PARENT_MEMBER_ID,0)) parent_member_id,
         DECODE(br.parent_member_id,
	          NULL,decode(x_group_resource_type_id,
		                0,x_funds_control_code_res,
				  x_funds_control_code_resgrp),
                  x_funds_control_code_res
               )  funds_control_level
  FROM PA_RESOURCE_LIST_MEMBERS br
  WHERE br.ENABLED_FLAG = 'Y'
  AND  br.RESOURCE_LIST_ID = x_resource_list_id
  AND DECODE(br.RESOURCE_TYPE_CODE, 'UNCLASSIFIED', 'Y', DISPLAY_FLAG) = 'Y'
  and nvl(br.migration_code, 'M') = 'M'
  and not exists (select 1 from gms_budgetary_controls bc
 		   where   bc.project_id = x_project_id
		     and   bc.award_id = x_award_id
		     and   bc.resource_list_member_id = br.resource_list_member_id);

 cursor c_res_resgrp_all IS
  SELECT br.resource_list_member_id,
         DECODE(x_group_resource_type_id,0,decode(nvl(br.parent_member_id,0),0,-1) --uncategorized
	                                ,NVL(br.PARENT_MEMBER_ID,0)) parent_member_id,
         DECODE(br.parent_member_id,
	          NULL,decode(x_group_resource_type_id,
		                0,x_funds_control_code_res,
				  x_funds_control_code_resgrp),
                  x_funds_control_code_res
               )  funds_control_level
  FROM PA_RESOURCE_LIST_MEMBERS br
  WHERE br.ENABLED_FLAG = 'Y'
  AND  br.RESOURCE_LIST_ID = x_resource_list_id
  AND DECODE(br.RESOURCE_TYPE_CODE, 'UNCLASSIFIED', 'Y', DISPLAY_FLAG) = 'Y'
  and nvl(br.migration_code, 'M') = 'M';


cursor c_tasks_for_new_resource is
SELECT
    pt1.task_id,
    pt1.top_task_id
FROM pa_tasks pt1
WHERE pt1.project_id = x_project_id
    AND
    (   (x_entry_level_code IN ( 'T' ,'M') AND  pt1.parent_task_id is null )
        OR
        (x_entry_level_code IN ('L','M')
          AND NOT EXISTS
          ( SELECT
                pt2.task_id
            FROM pa_tasks pt2
            WHERE pt1.task_id=pt2.parent_task_id)
         )
    )
    AND exists
          ( SELECT 1
            FROM gms_budgetary_controls bc
            WHERE bc.project_id = x_project_id
                and   bc.award_id = x_award_id
                AND bc.task_id = pt1.task_id
           );

Begin

--===================================================================================
/*
Bug 5132850 :
Note : x_calling_mode is
       'BASELINE' during first time baselining or during budgetary control reset
       'REBASELINE' during all other scenarios.

Procedure Creates Budgetary Controls for
Award, Task, Resource Group and resources.

1. Derive the Default control levels from gms_awards.
2. Create Budgetary control for the Award only when x_calling_mode is 'BASELINE'.
3. If entry_level_code = 'P' Project then
       Create budgetary control records for all resources or resource groups for which currently there exists no budgetary control records.
   Else (i.e the entry_level_code <> 'P')
      If calling mode is 'REBASELINE' then
        For all newly added resources or resource groups Loop
	   For all the tasks existing in Budgetary controls Loop
	     Create budgetary control records for the resource and the resource group levels.
           End Loop
        End Loop
      End if --- calling mode is 'REBASELINE'
      Delete all the dangling records from budgetary controls
       i.e if entry_level_code = 'L' , delete all the records where the task has some child tasks.
           if entry_level_code = 'M' , delete all the records whose task is neither the top nor the lowest task.
      For all newly added tasks Loop
          Create budgetary control records for the task level.
	  For all the resources and resource groups Loop
	    Create budgetary control records for the resource and resource group levels.
          End Loop
      End Loop
   End if


*/
--===================================================================================

    select fund_control_level_award
    , 	   fund_control_level_task
    ,      fund_control_level_res_grp
    ,      fund_control_level_res
    into   x_funds_control_code_awd
    ,      x_funds_control_code_tsk
    ,      x_funds_control_code_resgrp
    ,      x_funds_control_code_res
    from   gms_awards
    where  award_id = x_award_id;

    --creates default budgetary setup only for advisory or absolute controls
    --if x_funds_control_code_awd <> 'N' then
      --dbms_output.put_line('The last updated by is >>>>'||FND_GLOBAL.LOGIN_ID);

    If (p_calling_mode = 'BASELINE') then
      insert_rec(x_project_id, x_funds_control_code_awd, x_award_id, null, null, null);
    end if;

    IF x_entry_level_code = 'P' then

       	  FOR rec_res_grps IN c_res_resgrp_no_bc  LOOP

		insert_rec( x_project_id
			    , rec_res_grps.funds_control_level
			    , x_award_id
			    , 0
			    , rec_res_grps.parent_member_id
			    , rec_res_grps.resource_list_member_id
			  );

	    end loop;
    ELSE

	  If (p_calling_mode = 'REBASELINE') then -- first add if any new resources added to existing tasks

	   FOR rec_res_grps IN c_res_resgrp_no_bc   LOOP

	     for task_rec in c_tasks_for_new_resource LOOP

			insert_rec( x_project_id
				    , rec_res_grps.funds_control_level
				    , x_award_id
				    , task_rec.task_id
				    , rec_res_grps.parent_member_id
				    , rec_res_grps.resource_list_member_id
				  );

	       end loop;
	    end loop;

	   end if;

	      -- Bug 5162777 : Delete all the dangling records from budgetary controls in autonomous mode.

              del_bc_rec_for_task_auto (p_project_id => x_project_id,
	                                p_award_id => x_award_id,
					p_entry_level_code => x_entry_level_code);

	    -- This gets fired for both first time baseling and for any new tasks

	   for task_rec in c_tasks_no_bc
	   LOOP

		     insert_rec(x_project_id, x_funds_control_code_tsk
				 , x_award_id, task_rec.task_id, null, null);

	      -- resources


		    FOR rec_res_grps IN c_res_resgrp_all
		    LOOP

			insert_rec( x_project_id
				    , rec_res_grps.funds_control_level
				    , x_award_id
				    , task_rec.task_id
				    , rec_res_grps.parent_member_id
				    , rec_res_grps.resource_list_member_id
				  );

		    end loop;


	    END LOOP;
    end if;

  RETCODE := 0; -- R11i change
Exception
  when NO_DATA_FOUND then
--    RETCODE := 'E';
    RETCODE := 2; -- R11i change
    ERRBUF  := ('GMS_BUDG_CNTRL_REC_NOT_FOUND');
  when OTHERS then
--    RETCODE := 'U';
    RETCODE := 1; -- R11i change
    ERRBUF  := (SQLCODE||SQLERRM);
End;

-- Bug 5162777 : Created the procedure bud_ctrl_create
PROCEDURE bud_ctrl_create
		        (p_project_id		  IN	NUMBER
			,p_award_id		  IN	NUMBER
			,p_prev_entry_level_code  IN    pa_budget_entry_methods.entry_level_code%type
			,p_entry_level_code       IN    pa_budget_entry_methods.entry_level_code%type
			,p_resource_list_id       IN    NUMBER
			,p_group_resource_type_id IN    NUMBER
                        ,x_err_code               OUT NOCOPY    NUMBER
                        ,x_err_stage              OUT NOCOPY    VARCHAR2) is


l_budctrl_exists       VARCHAR2(1) := 'N';
l_calling_mode         VARCHAR2(30) := 'BASELINE';

/* Bug 5162777  :
   CURSOR c_budctrl_exists checks if there exists any budgetary control records for the project and award. */

	CURSOR c_budctrl_exists IS
	SELECT 'Y'
	  FROM DUAL
	 WHERE EXISTS (SELECT 1
			 FROM gms_budgetary_controls bc
			 where bc.project_id = p_project_id
			  and bc.award_id = p_award_id);

BEGIN

--====================================================================================
/*
Bug 5162777 :
 If first time baselining then
     l_calling_mode := 'BASELINE';
 Else
  If the entry_level_code of the budget has changed then
    Call del_bc_rec_for_reset_auto to delete all the budgetary control records.
    l_calling_mode := 'BASELINE'
  Else
    l_calling_mode := 'REBASELINE'
  end if
End if
Then gms_budg_cont_setup.create_records is called with the appropriate calling mode
*/

--====================================================================================



		IF L_DEBUG = 'Y' THEN
			gms_error_pkg.gms_debug('GMS_BUDG_CONT_SETUP.bud_ctrl_create - Setting up default budgetary_control', 'C');
		END IF;

		 OPEN c_budctrl_exists;
		 FETCH c_budctrl_exists INTO l_budctrl_exists;
		 CLOSE c_budctrl_exists;


                       IF l_budctrl_exists <> 'Y' THEN -- First time baselining

		       	   IF L_DEBUG = 'Y' THEN
			    gms_error_pkg.gms_debug('GMS_BUDG_CONT_SETUP.bud_ctrl_create - First time baselining', 'C');
			   END IF;

                       ELSE -- rebaselining

			    IF nvl(p_prev_entry_level_code, p_entry_level_code) <> p_entry_level_code then
				   IF L_DEBUG = 'Y' THEN
				    gms_error_pkg.gms_debug('GMS_BUDG_CONT_SETUP.bud_ctrl_create - Re-baselining if the entry level code is changed', 'C');
				   END IF;

				   -- Bug 5162777 : Call del_bc_rec_for_reset_auto to delete BC records in autonomous mode during BC reset.
				   del_bc_rec_for_reset_auto (p_project_id => p_project_id,
				                              p_award_id => p_award_id);

                             ELSE
			           IF L_DEBUG = 'Y' THEN
				    gms_error_pkg.gms_debug('GMS_BUDG_CONT_SETUP.bud_ctrl_create - Re-baselining if the entry level code is not changed', 'C');
				   END IF;
			           l_calling_mode := 'REBASELINE';

                             end if; -- If entry_level_code is changed then we need to refresh budgetary control
                       end if; --IF l_budctrl_exists <> 'Y'

			gms_error_pkg.gms_debug('GMS_BUDG_CONT_SETUP.bud_ctrl_create - Calling gms_budg_cont_setup.create_records', 'C');
			gms_budg_cont_setup.create_records(x_project_id => p_project_id
						   	  ,x_award_id => p_award_id
					     	   	  ,x_entry_level_code => p_entry_level_code
				        	   	  ,x_resource_list_id => p_resource_list_id
				     	   		  ,x_group_resource_type_id => p_group_resource_type_id
					     	   	  ,retcode => x_err_code
					     	   	  ,errbuf => x_err_stage
							  ,p_calling_mode => l_calling_mode);

END bud_ctrl_create;

END GMS_BUDG_CONT_SETUP;

/
