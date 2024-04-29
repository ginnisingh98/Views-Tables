--------------------------------------------------------
--  DDL for Package Body PA_BUDGETARY_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGETARY_CONTROLS_PKG" AS
-- $Header: PAXBCCRB.pls 120.2 2006/04/18 05:22:08 cmishra noship $
PROCEDURE insert_rows
			(x_project_id 			IN	PA_PROJECTS_ALL.PROJECT_ID%type
			,x_budget_type_code 		IN	PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type
			,x_funds_control_level_code 	IN	PA_BUDGETARY_CONTROLS.FUNDS_CONTROL_LEVEL_CODE%type
			,x_top_task_id                  IN	PA_TASKS.TASK_ID%type
 			,x_task_id                      IN	PA_TASKS.TASK_ID%type
 			,x_parent_member_id             IN	PA_RESOURCE_LIST_MEMBERS.PARENT_MEMBER_ID%type
 			,x_resource_list_member_id      IN	PA_RESOURCE_LIST_MEMBERS.resource_list_member_id%type
                        ,x_return_status                OUT NOCOPY 	VARCHAR2
                        ,x_msg_count                    OUT NOCOPY 	NUMBER
                        ,x_msg_data                     OUT NOCOPY 	VARCHAR2  ) IS

 l_return_status                VARCHAR2(10);
 l_msg_count                    NUMBER(15);
 l_msg_data                     VARCHAR2(2000);

-- Bug 5162775 : This procedure is made autonomous.
 PRAGMA AUTONOMOUS_TRANSACTION;

--===================================================================================
-- Inserts Records into PA_BUDGETARY_CONTROLS
-- Called from other routines in this package for the following ...
-- records inserted for Project, Tasks, Resource Groups and Resources
--===================================================================================

begin

l_return_status := FND_API.G_RET_STS_SUCCESS;



  insert into PA_BUDGETARY_CONTROLS  ( BUDGETARY_CONTROLS_ID
                                       ,PROJECT_ID
                                       ,FUNDS_CONTROL_LEVEL_CODE
                                       ,LAST_UPDATE_DATE
                                       ,LAST_UPDATED_BY
                                       ,CREATED_BY
                                       ,CREATION_DATE
                                       ,LAST_UPDATE_LOGIN
                                       ,TOP_TASK_ID
				       ,TASK_ID
                                       ,PARENT_MEMBER_ID
                                       ,RESOURCE_LIST_MEMBER_ID
				       ,BUDGET_TYPE_CODE
				     )
			values	     (
					PA_BUDGETARY_CONTROLS_s.nextval
                                        ,x_project_id
                                        ,x_funds_control_level_code
                                        ,SYSDATE
                                        ,FND_GLOBAL.USER_ID
                                        ,FND_GLOBAL.USER_ID
                                        ,SYSDATE
                                        ,FND_GLOBAL.LOGIN_ID
                                        ,x_top_task_id
					,x_task_id
                                        ,x_parent_member_id
                                        ,x_resource_list_member_id
					,x_budget_type_code
				      );


--Output Parameters are set before passing the values back

  x_msg_count     := l_msg_count    ;
  x_msg_data      := l_msg_data     ;
  x_return_status := l_return_status;

  COMMIT;



EXCEPTION
  WHEN OTHERS THEN
      x_msg_count     := 1;
      x_msg_data      := SUBSTR(SQLERRM, 1, 240);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGETARY_CONTROLS_PKG'
                               , p_procedure_name   => 'insert_rows');

END;

------------------------------------------------------------------------------------
 /* Bug 5162775 : The procedure del_bc_rec_for_reset_auto is created to delete BC records
                  during budgetary control reset. */

  PROCEDURE del_bc_rec_for_reset_auto
                          (p_project_id             IN	NUMBER
			   ,p_budget_type_code 	    IN	PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type )
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

  delete from pa_budgetary_controls
  where  project_id = p_project_id
  and    budget_type_code = p_budget_type_code;

   COMMIT;
  EXCEPTION
   WHEN OTHERS THEN
            FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGETARY_CONTROLS_PKG'
                                     , p_procedure_name   => 'del_bc_rec_for_reset_auto');
  END del_bc_rec_for_reset_auto;

-----------------------------------------------------------------------------------
 /* Bug 5162775 : The procedure del_bc_rec_for_task_auto is created to delete
                  all the dangling records from budgetary controls. */

  PROCEDURE del_bc_rec_for_task_auto
                          (p_project_id             IN	NUMBER
			   ,p_budget_type_code 	    IN	PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type
			   ,p_entry_level_code      IN	PA_BUDGET_ENTRY_METHODS.ENTRY_LEVEL_CODE%type)
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

   DELETE from pa_budgetary_controls bc
	WHERE EXISTS
	( SELECT  pt2.task_id
	    FROM  pa_tasks pt2
	    WHERE bc.task_id=pt2.parent_task_id
	      AND ((p_entry_level_code = 'L') OR
		   (p_entry_level_code = 'M' AND exists (select 1 from pa_tasks pt1
							 where bc.task_id = pt1.task_id
							and pt1.parent_task_id IS NOT NULL))))
	 AND bc.project_id = p_project_id
	 AND bc.budget_type_code = p_budget_type_code;

   COMMIT;
  EXCEPTION
   WHEN OTHERS THEN
            FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGETARY_CONTROLS_PKG'
                                     , p_procedure_name   => 'del_bc_rec_for_task_auto');
  END del_bc_rec_for_task_auto;

-----------------------------------------------------------------------------------


PROCEDURE create_bc_levels
			(x_project_id             IN	PA_PROJECTS_ALL.PROJECT_ID%type
			,x_budget_type_code       IN	PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type
			,x_entry_level_code       IN	PA_BUDGET_ENTRY_METHODS.ENTRY_LEVEL_CODE%type
			,x_resource_list_id       IN	PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_ID%type
			,x_group_resource_type_id IN	PA_RESOURCE_LISTS_ALL_BG.GROUP_RESOURCE_TYPE_ID%type
			,x_calling_mode	          IN	VARCHAR2
                        ,x_return_status          OUT NOCOPY   VARCHAR2
                        ,x_msg_count              OUT NOCOPY   NUMBER
                        ,x_msg_data               OUT NOCOPY   VARCHAR2 ) is

 v_funds_control_level_project 	PA_BUDGETARY_CONTROLS.FUNDS_CONTROL_LEVEL_CODE%type;
 v_funds_control_level_task 	PA_BUDGETARY_CONTROLS.FUNDS_CONTROL_LEVEL_CODE%type;
 v_funds_control_level_res_grp 	PA_BUDGETARY_CONTROLS.FUNDS_CONTROL_LEVEL_CODE%type;
 v_funds_control_level_res 	PA_BUDGETARY_CONTROLS.FUNDS_CONTROL_LEVEL_CODE%type;

 l_return_status                VARCHAR2(10);
 l_msg_count                    NUMBER(15);
 l_msg_data                     VARCHAR2(2000);

 l_debug_mode    		varchar2(1) := 'N';
 l_top_task_id                  NUMBER(15);

/*  Bug 4551528 :
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
            FROM pa_budgetary_controls bc
            WHERE bc.project_id = x_project_id
                AND bc.budget_type_code = x_budget_type_code
                AND bc.task_id = pt1.task_id
           );

 cursor c_res_resgrp_no_bc IS
  SELECT br.resource_list_member_id,
         DECODE(x_group_resource_type_id,0,decode(nvl(br.parent_member_id,0),0,-1) --uncategorized
	                                ,NVL(br.PARENT_MEMBER_ID,0)) parent_member_id,
         DECODE(br.parent_member_id,
	          NULL,decode(x_group_resource_type_id,
		                0,decode(v_funds_control_level_res,'D',nvl(funds_control_level_code,'N'),v_funds_control_level_res),
				  decode(v_funds_control_level_res_grp,'D',nvl(funds_control_level_code,'N'),v_funds_control_level_res_grp)),
                  decode(v_funds_control_level_res,'D',nvl(funds_control_level_code,'N'),v_funds_control_level_res)
               )  funds_control_level
  FROM PA_RESOURCE_LIST_MEMBERS br
  WHERE br.ENABLED_FLAG = 'Y'
  AND  br.RESOURCE_LIST_ID = x_resource_list_id
  AND DECODE(br.RESOURCE_TYPE_CODE, 'UNCLASSIFIED', 'Y', DISPLAY_FLAG) = 'Y'
  and nvl(br.migration_code, 'M') = 'M'
  and not exists (select 1 from pa_budgetary_controls bc
 		   where bc.project_id = x_project_id
		     and   bc.budget_type_code = x_budget_type_code
		     and   bc.resource_list_member_id = br.resource_list_member_id);


 cursor c_res_resgrp_all IS
  SELECT br.resource_list_member_id,
         DECODE(x_group_resource_type_id,0,decode(nvl(br.parent_member_id,0),0,-1) --uncategorized
	                                ,NVL(br.PARENT_MEMBER_ID,0)) parent_member_id,
         DECODE(br.parent_member_id,
	          NULL,decode(x_group_resource_type_id,
		                0,decode(v_funds_control_level_res,'D',nvl(funds_control_level_code,'N'),v_funds_control_level_res),
				  decode(v_funds_control_level_res_grp,'D',nvl(funds_control_level_code,'N'),v_funds_control_level_res_grp)),
                  decode(v_funds_control_level_res,'D',nvl(funds_control_level_code,'N'),v_funds_control_level_res)
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
            FROM pa_budgetary_controls bc
            WHERE bc.project_id = x_project_id
                AND bc.budget_type_code = x_budget_type_code
                AND bc.task_id = pt1.task_id
           );

--===================================================================================
/*
Bug 4551528 :
Note : x_calling_mode is
       'BASELINE' during first time baselining,
       'R' during budgetary control reset
           or during rebaselining if the entry_level_code of the budget is changed,
       'REBASELINE' during all other scenarios.

Procedure Creates Budgetary Controls for
Project, Task, Resource Group and resources.

1. Derive the Default control levels from PA_BUDGETARY_CONTROL_OPTIONS.
2. Create Budgetary control for the Project only when x_calling_mode is 'BASELINE' or 'R'.
    2.1 if the Project Budget is linked to external budget, the control
        level should always be set to Absolute 'B'
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
      Call del_bc_rec_for_task_auto to delete all the dangling records from budgetary controls in autonomous mode.
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


BEGIN


PA_DEBUG.init_err_stack('PA_BUDGETARY_CONTROLS_PKG.CREATE_BC_LEVELS');

 l_return_status := FND_API.G_RET_STS_SUCCESS;

--PLSQL Message stack is initialized

 FND_MSG_PUB.initialize;


   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   l_debug_mode := NVL(l_debug_mode, 'N');

   pa_debug.set_process('PLSQL','LOG',l_debug_mode);


   PA_DEBUG.g_err_stage := 'PA_BC_Log: Create Budgetary Controls - start';

   PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);


-- write log messages into FND_LOG_MESSAGES for debugging purposes

   PA_DEBUG.write_log (x_module      => 'PA_BUDGETARY_CONTROLS_PKG.create_bc_levels start'
                      ,x_msg         => 'Creating Default Budgetary Control Levels'
                      ,x_log_level   => 5);


   PA_FCK_UTIL.debug_msg('PA_BC_Log: Create Budgetary Controls - start');




--Select Funds control level for the Project,Tasks, Resource groups and resources.


 select
	FUND_CONTROL_LEVEL_PROJECT,
	FUND_CONTROL_LEVEL_TASK,
	FUND_CONTROL_LEVEL_RES_GRP,
	FUND_CONTROL_LEVEL_RES
 into
	v_funds_control_level_project,
	v_funds_control_level_task,
	v_funds_control_level_res_grp,
	v_funds_control_level_res
 from
	pa_budgetary_control_options
 where
	project_id = x_project_id and budget_type_code = x_budget_type_code;

PA_FCK_UTIL.debug_msg('PA_BC_Log: Control levels derived for ' || x_project_id);

   PA_FCK_UTIL.debug_msg('PA_BC_Log: Derived Default Budgetary Control levels from PA_BUDGETARY_CONTROL_OPTIONS');

   PA_DEBUG.g_err_stage := 'PA_BC_Log: Derive default control levels';
   PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);


  If (x_calling_mode = 'BASELINE') or (x_calling_mode = 'R') then

-- Creates BC Record for the Project
-- ?? Do we check for the link to external budget here?
-- If the Project budget is linked to external budget, then
-- Funds control level for the project should be Absolute.

   PA_FCK_UTIL.debug_msg('PA_BC_Log: Call INSERT_ROWS -- Create BC for PROJECT ');

   PA_DEBUG.g_err_stage := 'PA_BC_Log:PA_BC_Log: Call INSERT_ROWS -- Create BC for PROJECT ';
   PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);


      insert_rows	(x_project_id
                	,x_budget_type_code
                	,v_funds_control_level_project
                	,null
                	,null
			,null
			,null
        		,l_return_status
        		,l_msg_count
        		,l_msg_data
			);


   PA_FCK_UTIL.debug_msg('PA_BC_Log: Created BC for PROJECT Level');

   PA_DEBUG.g_err_stage := 'PA_BC_Log: Created BC for PROJECT Level ';
   PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);

   end if;

   IF x_entry_level_code = 'P' then

       	  FOR rec_res_grps IN c_res_resgrp_no_bc  LOOP

		insert_rows( x_project_id
			    , x_budget_type_code
			    , rec_res_grps.funds_control_level
			    , 0
			    , 0
			    , rec_res_grps.parent_member_id
			    , rec_res_grps.resource_list_member_id
				,l_return_status
				,l_msg_count
				,l_msg_data
			  );

	    end loop;

 ELSE

  If (x_calling_mode = 'REBASELINE') then -- first add if any new resources added to existing tasks

   FOR rec_res_grps IN c_res_resgrp_no_bc   LOOP

     for task_rec in c_tasks_for_new_resource LOOP

      	      if (x_entry_level_code = 'T') or (x_entry_level_code = 'M') then
		 l_top_task_id := task_rec.task_id;
	      elsif x_entry_level_code = 'L' THEN
		 l_top_task_id :=task_rec.top_task_id;
	      END IF;

		insert_rows( x_project_id
			    , x_budget_type_code
			    , rec_res_grps.funds_control_level
			    , l_top_task_id
			    , task_rec.task_id
			    , rec_res_grps.parent_member_id
			    , rec_res_grps.resource_list_member_id
				,l_return_status
				,l_msg_count
				,l_msg_data
			  );

       end loop;
    end loop;

   end if;
      -- Bug 5162775 : Delete all the dangling records from budgetary controls in autonomous mode.
      del_bc_rec_for_task_auto (p_project_id => x_project_id,
                                p_budget_type_code => x_budget_type_code,
				p_entry_level_code => x_entry_level_code);

    -- This gets fired for both first time baseling and for any new tasks

   for task_rec in c_tasks_no_bc
   LOOP

      if (x_entry_level_code = 'T') or (x_entry_level_code = 'L') then
         l_top_task_id := NULL;
      elsif x_entry_level_code = 'M' THEN
         l_top_task_id := task_rec.task_id;
      END IF;

	      insert_rows(x_project_id
			,x_budget_type_code
			,v_funds_control_level_task
			,l_top_task_id
			,task_rec.task_id
			,null
			,null
			,l_return_status
			,l_msg_count
			,l_msg_data);


      -- resources

      	      if (x_entry_level_code = 'T') or (x_entry_level_code = 'M') then
		 l_top_task_id := task_rec.task_id;
	      elsif x_entry_level_code = 'L' THEN
		 l_top_task_id :=task_rec.top_task_id;
	      END IF;


	    FOR rec_res_grps IN c_res_resgrp_all
	    LOOP


		insert_rows( x_project_id
			    , x_budget_type_code
			    , rec_res_grps.funds_control_level
			    , l_top_task_id
			    , task_rec.task_id
			    , rec_res_grps.parent_member_id
			    , rec_res_grps.resource_list_member_id
				,l_return_status
				,l_msg_count
				,l_msg_data
			  );

	    end loop;


    END LOOP;
end if;

 --Output Parameters are set before passing the values back

  x_msg_count     := l_msg_count    ;
  x_msg_data      := l_msg_data     ;
  x_return_status := l_return_status;

 EXCEPTION
  WHEN OTHERS THEN
      x_msg_count     := 1;
      x_msg_data      := SUBSTR(SQLERRM, 1, 240);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGETARY_CONTROLS_PKG'
                               , p_procedure_name   => 'CREATE_BC_LEVELS');

end;  -- Procedure create_bc_levels

------------------------------------------------------------------------------------

PROCEDURE bud_ctrl_create
			(x_budget_version_id 	IN	PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%type
			,x_calling_mode		IN	VARCHAR2
                        ,x_return_status        OUT NOCOPY     VARCHAR2
                        ,x_msg_count            OUT NOCOPY     NUMBER
                        ,x_msg_data             OUT NOCOPY     VARCHAR2 ) is

 l_return_status        VARCHAR2(10);
 l_msg_count            NUMBER(15);
 l_msg_data             VARCHAR2(2000);
 l_debug_mode		VARCHAR2(1) := 'N';
 CREATE_BC_REC_ERROR	EXCEPTION;
 l_budctrl_exists       VARCHAR2(1) := 'N';
 l_calling_mode         VARCHAR2(30);

/* Bug 4551528 :
   CURSOR c_budctrl_exists checks if there exists any budgetary control records for the project and budget type code.
   cursor c_prev_entry_level_code is used to get the entry_level_code of the previous budget version. */

CURSOR c_budctrl_exists ( p_budget_version_id NUMBER) IS
SELECT 'Y'
  FROM DUAL
 WHERE EXISTS (SELECT 1
                 FROM pa_budgetary_controls bc,
		      PA_BUDGET_VERSIONS    pbv
                WHERE BUDGET_VERSION_ID = p_budget_version_id
                  and bc.project_id = pbv.project_id
                  and bc.budget_type_code = pbv.budget_type_code);

-- Cursor retrives values for Parameters to be passed while calling create_bc_levels;

 cursor c_bud_ctrl_params(p_budget_version_id number) is
	select 	 bv.project_id
		,bv.budget_type_code
		,bv.resource_list_id
		,rl.group_resource_type_id
	  	,bem.entry_level_code
	from 	 PA_BUDGET_VERSIONS bv
		,PA_BUDGET_ENTRY_METHODS bem
		,PA_RESOURCE_LISTS_ALL_BG rl
	where	 bv.budget_version_id = p_budget_version_id
	 and	 bv.budget_entry_method_code = bem.budget_entry_method_code
	 and	 bv.resource_list_id = rl.resource_list_id
         --FP M changes
         and     nvl(rl.migration_code, 'M') = 'M' ;

 bud_ctrl_params_rec c_bud_ctrl_params%ROWTYPE;

-- Bug 4551528 : This cursor is used to retrieve the entry_level_code for the previous version of the budget.
cursor c_prev_entry_level_code(p_budget_version_id number) is
select bem.entry_level_code
from pa_budget_versions bv,
     pa_budget_entry_methods bem
where bv.budget_version_id = p_budget_version_id
and  bv. budget_entry_method_code = bem. budget_entry_method_code;

l_prev_entry_level_code pa_budget_entry_methods.entry_level_code%type;

--===================================================================================
/* Called from Budget Baselining / Tieback API
The Budget Version has BUDGET_STATUS_CODE = 'B' if Baseline process was successful

Bug 4551528 :
 If first time baselining then
     l_calling_mode := x_calling_mode;
 Else
  If the entry_level_code of the budget has changed then
    delete all the budgetary control records.
    l_calling_mode := 'R'
  Else
    l_calling_mode := 'REBASELINE'
  end if
End if
Then pa_budgetary_controls_pkg.create_bc_levels is called with the appropriate calling mode
*/

--====================================================================================

begin

 l_return_status := FND_API.G_RET_STS_SUCCESS;
 l_calling_mode  := x_calling_mode;

 -- Setting debug variables
 PA_DEBUG.init_err_stack('PA_BUDGETARY_CONTROLS_PKG.BUD_CTRL_CREATE');
 FND_MSG_PUB.initialize;   --PLSQL Message stack is initialized
 fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
 l_debug_mode := NVL(l_debug_mode, 'N');
 pa_debug.set_process('PLSQL','LOG',l_debug_mode);


 PA_DEBUG.g_err_stage := 'PA_BC_Log: Baseline Process calls Budg. control creation proc. - start';
 PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);
 -- write log messages into FND_LOG_MESSAGES for debugging purposes
 PA_DEBUG.write_log (x_module      => 'PA_BUDGETARY_CONTROLS_PKG.BUD_CTRL_CREATE start'
                     ,x_msg         => 'Creating Default Budgetary Control Levels'
                     ,x_log_level   => 5);
 PA_FCK_UTIL.debug_msg('PA_BC_Log: Call CREATE_BC_LEVELS procedure:- start');


 OPEN c_budctrl_exists(x_budget_version_id);
 FETCH c_budctrl_exists INTO l_budctrl_exists;
 CLOSE c_budctrl_exists;

 PA_FCK_UTIL.debug_msg('PA_BC_Log:Budgetary control record exists ? '||l_budctrl_exists);
 PA_FCK_UTIL.debug_msg('PA_BC_Log:Opening c_bud_ctrl_params cursor');

 open c_bud_ctrl_params(x_budget_version_id);
 fetch c_bud_ctrl_params into bud_ctrl_params_rec;

 IF (c_bud_ctrl_params%FOUND) THEN

         IF l_budctrl_exists <> 'Y' THEN -- First time baselining

 	    PA_FCK_UTIL.debug_msg('PA_BC_Log:Calling CREATE_BC_LEVELS during first time baselining');
	    PA_DEBUG.g_err_stage := 'PA_BC_Log Calling CREATE_BC_LEVELS during first time baselining';
	    PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);

	    l_calling_mode := x_calling_mode;

         ELSE -- rebaselining

            -- Bug 4551528 : Fetch the entry_level_code for the previous version of the budget.
            open c_prev_entry_level_code (PA_BUDGET_FUND_PKG.Get_previous_bvid(p_project_id => bud_ctrl_params_rec.project_id,
								  p_budget_type_code => bud_ctrl_params_rec.budget_type_code,
								  p_curr_budget_status_code => 'B'));
            fetch c_prev_entry_level_code into l_prev_entry_level_code;
            close c_prev_entry_level_code;

            -- If entry_level_code is changed then we nedd to refresh budgetary control
            IF nvl(l_prev_entry_level_code, bud_ctrl_params_rec.entry_level_code) <> bud_ctrl_params_rec.entry_level_code  THEN

    	        PA_DEBUG.g_err_stage := 'PA_BC_Log Calling CREATE_BC_LEVELS during re-baselining if the entry level code is changed';
		PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);
 		PA_FCK_UTIL.debug_msg('PA_BC_Log: Calling CREATE_BC_LEVELS during re-baselining if the entry level code is changed');

		-- Bug 5162775 : Call del_bc_rec_for_reset_auto to delete BC records in autonomous mode during BC reset.
		del_bc_rec_for_reset_auto (p_project_id => bud_ctrl_params_rec.project_id,
		                           p_budget_type_code => bud_ctrl_params_rec.budget_type_code);

  	        l_calling_mode := 'R'; --reset mode;

            ELSE

	        PA_DEBUG.g_err_stage := 'PA_BC_Log Calling CREATE_BC_LEVELS during re-baselining if the entry level code is not changed';
		PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);
 		PA_FCK_UTIL.debug_msg('PA_BC_Log: Calling CREATE_BC_LEVELS during re-baselining if the entry level code is not changed');

	        l_calling_mode := 'REBASELINE';

            END IF; -- If entry_level_code is changed then we need to refresh budgetary control

        END IF; --IF l_budctrl_exists <> 'Y' THEN

        pa_budgetary_controls_pkg.create_bc_levels
			(bud_ctrl_params_rec.project_id
			,bud_ctrl_params_rec.budget_type_code
			,bud_ctrl_params_rec.entry_level_code
			,bud_ctrl_params_rec.resource_list_id
			,bud_ctrl_params_rec.group_resource_type_id
			,l_calling_mode
			,l_return_status
			,l_msg_count
			,l_msg_data  );

 END IF; -- IF (c_bud_ctrl_params%FOUND) THEN

 PA_FCK_UTIL.debug_msg('PA_BC_Log:5');
 PA_DEBUG.g_err_stage := 'PA_BC_Log Executed BUD_CTRL_CREATE';
 PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);
 PA_FCK_UTIL.debug_msg('PA_BC_Log: Executed BUD_CTRL_CREATE');

 CLOSE c_bud_ctrl_params;

 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
  RAISE CREATE_BC_REC_ERROR;
 end if;

 --Output Parameters are set before passing the values back

  x_msg_count     := l_msg_count    ;
  x_msg_data      := l_msg_data     ;
  x_return_status := l_return_status;

 EXCEPTION
  WHEN CREATE_BC_REC_ERROR then
      PA_UTILS.add_message('PA', 'PA_BC_REC_FAIL');
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_BC_REC_FAIL';


  WHEN OTHERS THEN
      x_msg_count     := 1;
      x_msg_data      := SUBSTR(SQLERRM, 1, 240);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      PA_FCK_UTIL.debug_msg('PA_BC_Log:8' || SQLERRM);

      FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGETARY_CONTROLS_PKG'
                             , p_procedure_name   => 'BUD_CTRL_CREATE');

END;

------------------------------------------------------------------------------------


PROCEDURE budg_control_reset
			(x_project_id             IN	PA_PROJECTS_ALL.PROJECT_ID%type
			,x_budget_type_code       IN	PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type
			,x_entry_level_code       IN	PA_BUDGET_ENTRY_METHODS.ENTRY_LEVEL_CODE%type
			,x_resource_list_id       IN	PA_RESOURCE_LIST_MEMBERS.RESOURCE_LIST_ID%type
			,x_group_resource_type_id IN	PA_RESOURCE_LISTS_ALL_BG.GROUP_RESOURCE_TYPE_ID%type
			,x_calling_mode	          IN	VARCHAR2
                        ,x_return_status          OUT NOCOPY   VARCHAR2
                        ,x_msg_count              OUT NOCOPY   NUMBER
                        ,x_msg_data               OUT NOCOPY   VARCHAR2 ) is

 l_return_status        VARCHAR2(10);
 l_msg_count            NUMBER(15);
 l_msg_data             VARCHAR2(2000);
 l_debug_mode varchar2(1) := 'N';
 RESET_BC_ERROR		EXCEPTION;

begin

 PA_DEBUG.init_err_stack('PA_BUDGETARY_CONTROLS_PKG.BUDG_CTRL_RESET');

 l_return_status := FND_API.G_RET_STS_SUCCESS;

--PLSQL Message stack is initialized

 FND_MSG_PUB.initialize;


   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
   l_debug_mode := NVL(l_debug_mode, 'N');

   pa_debug.set_process('PLSQL','LOG',l_debug_mode);


   PA_DEBUG.g_err_stage := 'PA_BC_Log: Called from Form . Budg. control RESET proc. - start';
   PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);


-- write log messages into FND_LOG_MESSAGES for debugging purposes

   PA_DEBUG.write_log (x_module      => 'PA_BUDGETARY_CONTROLS_PKG.BUDG_CTRL_RESET start'
                      ,x_msg         => 'Reset  Budgetary Control Levels'
                      ,x_log_level   => 5);


   PA_FCK_UTIL.debug_msg('PA_BC_Log: Call CREATE_BC_LEVELS procedure:- start');


-- Deletes Budgetary Control records from PA_BUDGETARY_CONTROLS


   PA_DEBUG.g_err_stage := 'PA_BC_Log: Called from Form . Budg. control RESET proc. - start';
   PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);


        delete from pa_budgetary_controls
	where project_id = x_project_id
	and budget_type_code = x_budget_type_code;

   PA_FCK_UTIL.debug_msg('PA_BC_Log: delete budgetary Controls');

   PA_DEBUG.g_err_stage := 'PA_BC_Log: Deleted Budgetary Control Records: '||'PROJECT ID =  '||x_project_id;
   PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);

        pa_budgetary_controls_pkg.create_bc_levels
					(x_project_id
					,x_budget_type_code
				     	,x_entry_level_code
				        ,x_resource_list_id
				     	,x_group_resource_type_id
					,'R'
                        		,l_return_status
                        		,l_msg_count
                        		,l_msg_data  );

 if l_return_status =  FND_API.G_RET_STS_SUCCESS then
   PA_FCK_UTIL.debug_msg('PA_BC_Log: BC Levels recreated');
 -- Budgetary Control levels successfully created.  Commit can be issued
commit;
   PA_DEBUG.g_err_stage := 'PA_BC_Log:  Budgetary Control levels successfully created';
   PA_DEBUG.write_file('LOG',pa_debug.g_err_stage);
 else
   -- Budgetary Controls were not created. Roll back issued and exception be raised in the Form.
     PA_FCK_UTIL.debug_msg('PA_BC_Log: rollback');
  rollback;
 end if;


 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
  RAISE RESET_BC_ERROR;
 end if;

--Output Parameters are set before passing the values back

  x_msg_count     := l_msg_count    ;
  x_msg_data      := l_msg_data     ;
  x_return_status := l_return_status;

 EXCEPTION
  WHEN   RESET_BC_ERROR then
      PA_UTILS.add_message('PA', 'PA_BC_RESET_ERROR');
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      x_msg_count     := 1;
      x_msg_data      := 'PA_BC_RESET_ERROR';


  WHEN OTHERS THEN
      rollback;
      x_msg_count     := 1;
      x_msg_data      := SUBSTR(SQLERRM, 1, 240);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_BUDGETARY_CONTROLS_PKG'
                               , p_procedure_name   => 'BUD_CTRL_CREATE');

END;


-------------------------------------------------------------------------------------


FUNCTION budget_ctrl_exists
			(x_project_id 		IN PA_PROJECTS_ALL.PROJECT_ID%type
			,x_budget_type_code 	IN PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type
			)
            return varchar2 is


 l_fck_req_flag                 VARCHAR2(1);
 l_bdgt_intg_flag               pa_budgetary_control_options.external_budget_code%TYPE ;
 l_bdgt_ver_id                  pa_budget_versions.budget_version_id%TYPE ;
 l_encum_type_id                pa_budgetary_control_options.encumbrance_type_id%TYPE ;
 l_balance_type                 pa_budgetary_control_options.balance_type%TYPE;
 l_return_status                VARCHAR2(10);
 l_msg_count                    NUMBER(15);
 l_msg_data                     VARCHAR2(2000);
 v_bud_ctrl_exist               VARCHAR2(1);
 bc_rec_exists varchar2(1);
 invalid_args_passed		EXCEPTION;

--============================================================================
--Function is called from Budgets form -- before the Menu Item
--for BC form is activated.

--1. Check Budgetary Controls enabled for this project
--2. Check Budgetary control records exist for given project_id
--    and budget_type_code. At the time of invoking the Budgetary Controls
--    form, BC records should have been created by Baselining process.
--3.  The Function returns 'Y' if
--        a) Budgetary Control enabled for the Project and Budget Type AND
--        b) the Project budget has been successfully
--           initial-baselined and BC records created.
--    Function returns  'N' if
--        a) Budgetary Control is not enabled for the Project and Budget Type OR
--        b) the Project budget has never been baselined.

--============================================================================

begin

if ((x_project_id is null) or (x_budget_type_code is null)) then
 raise invalid_args_passed;
end if;

/*
 PA_BUDGET_FUND_PKG.get_budget_ctrl_options
            (p_project_id       => x_project_id
            ,p_budget_type_code => x_budget_type_code
            ,p_calling_mode     => 'BUDGET'
            ,x_fck_req_flag     => l_fck_req_flag
            ,x_bdgt_intg_flag   => l_bdgt_intg_flag
            ,x_bdgt_ver_id      => l_bdgt_ver_id
            ,x_encum_type_id    => l_encum_type_id
            ,x_balance_type     => l_balance_type
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data);
*/

 PA_BUDGET_FUND_PKG.get_budget_ctrl_options
            (x_project_id
            ,x_budget_type_code
            ,'BUDGET'
            ,l_fck_req_flag
            ,l_bdgt_intg_flag
            ,l_bdgt_ver_id
            ,l_encum_type_id
            ,l_balance_type
            ,l_return_status
            ,l_msg_count
            ,l_msg_data);


-- check whether budgetary Controls set up for this project
 if l_fck_req_flag = 'Y' then
-- Check whether BC records exist for this project and budget type

  select 'Y' into bc_rec_exists from SYS.DUAL
	where exists
               (select' Y'
   		from pa_budgetary_controls
    		where   project_id = x_project_id and
            	budget_type_code = x_budget_type_code and
		rownum=1);

/* select count(*) into bc_rec_count
    from pa_budgetary_controls
    where   project_id = x_project_id and
            budget_type_code = x_budget_type_code;
*/
    if bc_rec_exists = 'Y' then
     v_bud_ctrl_exist := 'Y';
    else
     v_bud_ctrl_exist := 'N';
    end if;
 else
   v_bud_ctrl_exist := 'N';
 end if;

 return v_bud_ctrl_exist;

 EXCEPTION


 WHEN INVALID_ARGS_PASSED then

        FND_MESSAGE.SET_NAME('PA','PA_BC_NULL_ARGS_PASSED');
        APP_EXCEPTION.RAISE_EXCEPTION;
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;

/*
      PA_UTILS.add_message ( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_BC_NULL_ARGS_PASSED');
      APP_EXCEPTION.RAISE_EXCEPTION;
*/

  WHEN OTHERS THEN
  RETURN NULL;

end ;

------------------------------------------------------------------------------------

FUNCTION budg_control_enabled
            ( x_budget_version_id IN	PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%type)
            return varchar2 is

 l_project_id                   PA_PROJECTS_ALL.PROJECT_ID%type;
 l_budget_type_code             PA_BUDGET_TYPES.BUDGET_TYPE_CODE%type;
 l_return_status                VARCHAR2(10);
 l_msg_count                    NUMBER(15);
 l_msg_data                     VARCHAR2(2000);

 l_bdgt_ver_id                  pa_budget_versions.budget_version_id%TYPE ;
 l_encum_type_id                pa_budgetary_control_options.encumbrance_type_id%TYPE ;
 l_balance_type                 pa_budgetary_control_options.balance_type%TYPE;
 l_fck_req_flag                 VARCHAR2(1);
 l_bdgt_intg_flag               VARCHAR2(1);
 v_bc_enabled                   VARCHAR2(1);
 invalid_args_passed		EXCEPTION;

--============================================================================
--Called from Budgets Form
--Returns 'Y' if Budgetary Controls enabled for given PROJECT_ID and BUDGET_TYPE_CODE
-- Derive the PROJECT_ID and BUDGET_TYPE_CODE from PA_BUDGET_VERSIONS
-- if  Budgetary Controls enabled (Call to PA_BUDGET_FUND API) and BALANCE_TYPE in ('B','E')
--	return 'Y'
--  else
--	return 'N'
--
--============================================================================

begin
--Derive the PROJECT_ID and BUDGET_TYPE_CODE for the Budget version.


 if x_budget_version_id IS NULL then
  raise INVALID_ARGS_PASSED;
 end if;

select PROJECT_ID,BUDGET_TYPE_CODE
    into l_project_id, l_budget_type_code
    from PA_BUDGET_VERSIONS
    where   BUDGET_VERSION_ID = x_budget_version_id;



PA_BUDGET_FUND_PKG.get_budget_ctrl_options
            (p_project_id       => l_project_id
            ,p_budget_type_code => l_budget_type_code
            ,p_calling_mode     => 'BUDGET'
            ,x_fck_req_flag     => l_fck_req_flag
            ,x_bdgt_intg_flag   => l_bdgt_intg_flag
            ,x_bdgt_ver_id      => l_bdgt_ver_id
            ,x_encum_type_id    => l_encum_type_id
            ,x_balance_type     => l_balance_type
            ,x_return_status    => l_return_status
            ,x_msg_count        => l_msg_count
            ,x_msg_data         => l_msg_data);


--Bug 1969577: Removed l_balance_type check since for budgetary control
--             enabled, non integrated budget the balance_type will be null.

if l_fck_req_flag = 'Y'
   --and ((l_balance_type = 'E') OR ( l_balance_type = 'B'))
then
  v_bc_enabled := 'Y';
else
  v_bc_enabled := 'N';
end if;

return v_bc_enabled;

EXCEPTION

WHEN INVALID_ARGS_PASSED then

/*      PA_UTILS.add_message ( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_BC_NULL_ARGS_PASSED');
*/
        FND_MESSAGE.SET_NAME('PA','PA_BC_NULL_ARGS_PASSED');
        APP_EXCEPTION.RAISE_EXCEPTION;
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_ERROR;

 --     APP_EXCEPTION.RAISE_EXCEPTION;

 WHEN OTHERS THEN
 RETURN NULL;

end ; -- end of Function


FUNCTION get_budget_status
                        (p_budget_version_id            IN      PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%type)
            return varchar2 is

 v_budget_status_code PA_BUDGET_VERSIONS.BUDGET_STATUS_CODE%type;

 cursor c_budget_status is
   select budget_status_code from PA_BUDGET_VERSIONS where budget_version_id = p_budget_version_id;

 begin

 if (nvl(G_Budget_Version_ID,-9999) = p_budget_version_id ) then   /*4219400*/
    return G_Budget_Status_Code;				   /*4219400*/

 else 								   /*4219400*/

   if c_budget_status%ISOPEN then
      close c_budget_status;
   end if;

   open c_budget_status;
   fetch c_budget_status into v_budget_status_code;
   G_Budget_Version_ID  :=  p_budget_version_id;		   /*4219400*/
   G_Budget_Status_Code :=  v_budget_status_code;     		   /*4219400*/
   close c_budget_status;

 return v_budget_status_code;

 end if;							   /*4219400*/

END get_budget_status;


end PA_BUDGETARY_CONTROLS_PKG;    -- Package

/
