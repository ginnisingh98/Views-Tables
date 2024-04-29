--------------------------------------------------------
--  DDL for Package Body PA_PROJ_STRUCTURE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_STRUCTURE_UTILS" as
/* $Header: PAXSTRUB.pls 120.5.12010000.2 2009/06/13 00:41:37 skkoppul ship $ */

-- Bug Fix 5611909. Creating global variables to cache the project id and budget version id.
-- These will be used in the program unit Get_All_Wbs_Rejns and these will be set by using
-- the set_budget_version_id_global procedure.
-- NOTE: PLEASE DO NOT MODIFY THESE ANYWHERE ELSE OR USING ANY OTHER MEANS.

--
procedure CHECK_LOOPED_PROJECT
(
	p_api_version				IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit						IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode				IN		VARCHAR2	:= 'N',
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER,
	x_return_status			OUT		NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count					OUT		NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data					OUT		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
  l_looped		VARCHAR2(1);
Begin
	pa_debug.set_err_stack('CHECK_LOOPED_PROJECT');

	--Block to check if this project is looped.
	Begin
	--check if it is looped
		select 'Y'
	 	into l_looped
		from
                -- bug 7573061 : skkoppul - changed table from pa_object_relationships to the below
		(
                  SELECT * FROM pa_object_relationships
                  WHERE relationship_type IN ('LW','LF')
		 )
		where
-- Bug 5589038		object_id_to1 =
                        object_id_to2 =
			(
				select
					project_id
				from
					pa_tasks t
				where
					t.task_id = p_task_id
			)
		start with object_id_from2 = p_project_id
-- Bug 5589038		connect by object_id_from2 = PRIOR object_id_to1;
                connect by object_id_from2 = PRIOR object_id_to2;
	EXCEPTION
		When NO_DATA_FOUND Then
			l_looped := 'N';
	End;


	IF (l_looped = 'N') Then
		--Block to check if the task is linking to its owning project
		BEGIN
			select 'Y'
			into l_looped
			from
				pa_tasks t2
			where
				t2.task_id = p_task_id and
				t2.project_id = p_project_id;
		EXCEPTION
			When NO_DATA_FOUND Then
				l_looped := 'N';
		END;
	end if;

	IF (l_looped = 'Y') THEN   --There is a loop
		x_return_status := FND_API.G_RET_STS_ERROR;
	elsif (l_looped = 'N') THEN
		x_return_status := FND_API.G_RET_STS_SUCCESS;
	else
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	end if;

	x_msg_count := 0;
	x_msg_data := null;

	pa_debug.reset_err_stack;
EXCEPTION
	When OTHERS Then
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		RAISE;
END CHECK_LOOPED_PROJECT;



procedure CHECK_MERGED_PROJECT
(
	p_api_version				IN		NUMBER		:= 1.0,
	p_init_msg_list 		IN		VARCHAR2	:= FND_API.G_TRUE,
	p_commit						IN		VARCHAR2	:= FND_API.G_FALSE,
	p_validate_only			IN		VARCHAR2	:= FND_API.G_TRUE,
	p_debug_mode				IN		VARCHAR2	:= 'N',
	p_task_id						IN		NUMBER,
	p_project_id				IN		NUMBER,
	x_return_status			OUT		NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count					OUT		NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data					OUT		NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
	l_linked_id	PA_OBJECT_RELATIONSHIPS.OBJECT_ID_FROM2%TYPE;
	l_exist     VARCHAR2(1);
	l_linked		VARCHAR2(1);

/* Commented for Bug5589038
  CURSOR get_same_project(l_task_id NUMBER, l_project_id VARCHAR2) IS
  select 'Y'
  from
    pa_object_relationships r,
    pa_tasks t
  where
    r.object_id_to1 = l_project_id and
    r.object_type_to = 'PA_PROJECTS' and
    r.relationship_type = 'H' and
    r.object_id_from2 = t.project_id and
    t.task_id = l_task_id; */
--    object_id_from1 = l_task_id and
--    object_type_from = 'PA_TASKS' and
--    relationship_type = 'H';

-- Modified the above cursor for Bug Bug5589038
  CURSOR get_same_project(l_task_id NUMBER, l_project_id VARCHAR2) IS
  select 'Y'
  from
    pa_object_relationships r,
    pa_tasks t
  where
    r.object_id_to2 = l_project_id and
    r.object_type_to = 'PA_STRUCTURES' and
    (r.relationship_type = 'LF' or r.relationship_type = 'LW')  and
    r.object_id_from2 = t.project_id and
    t.task_id = l_task_id;

	CURSOR get_merged_projects(l_task_id VARCHAR2, l_project_id VARCHAR2) IS
  (
	select
		object_id_from2
	from
        -- bug 7573061 : skkoppul - changed table from pa_object_relationships to the below
        (
           select * from pa_object_relationships
           where relationship_type in ('LW','LF')
        )

	start with
-- Bug5589038		object_id_to1 =
                 object_id_to2 =
		(
			select
				project_id
			from
				pa_tasks t
			where
				t.task_id = l_task_id
		)
--Bug5589038	connect by PRIOR object_id_from2 = object_id_to1
	connect by PRIOR object_id_from2 = object_id_to2
  union
  select
    project_id
  from
    pa_tasks
  where
    task_id = l_task_id
  )
	intersect
	select
		object_id_from2
	from
        -- bug 7573061 : skkoppul - changed table from pa_object_relationships to the below
        (
           select * from pa_object_relationships
           where relationship_type in ('LW','LF')
        )
-- Bug5589038	start with object_id_to1 = l_project_id
 	start with object_id_to2 = l_project_id
-- Bug5589038	connect by PRIOR object_id_from2 = object_id_to1;
	connect by PRIOR object_id_from2 = object_id_to2;

Begin
	pa_debug.set_err_stack('CHECK_MERGED_PROJECT');
	--Block to check if this project is linked.
  Begin
	  OPEN  get_same_project(p_task_id, to_char(p_project_id));
    FETCH get_same_project into l_exist;
    CLOSE get_same_project;
    IF (l_exist IS NULL) THEN
      -- This row does not exist; no duplicates.
			Begin
				--check if it is merged
				OPEN get_merged_projects(to_char(p_task_id), to_char(p_project_id));
				LOOP
					FETCH get_merged_projects INTO l_linked_id;
					EXIT WHEN get_merged_projects%FOUND;
					l_linked_id := null;
					EXIT WHEN get_merged_projects%NOTFOUND;
				END LOOP;
				CLOSE get_merged_projects;

				IF(l_linked_id IS NULL) THEN
					x_return_status := FND_API.G_RET_STS_SUCCESS;
				ELSE
					x_return_status := FND_API.G_RET_STS_ERROR;
				END IF;

			EXCEPTION
				When NO_DATA_FOUND Then
					l_linked := 'N';
			End;
		ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
	END;

	x_msg_count := 0;
	x_msg_data := null;
	pa_debug.reset_err_stack;
EXCEPTION
	When OTHERS Then
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		RAISE;
END CHECK_MERGED_PROJECT;


function CHECK_PROJECT_CONTRACT_EXISTS
(
	p_project_id	IN	NUMBER
)
return VARCHAR2
IS
	output		VARCHAR2(1);
	retval		VARCHAR2(1);
  msg_count NUMBER;
	msg_data	VARCHAR2(2000);
	ret_status VARCHAR2(10);
BEGIN
	pa_debug.set_err_stack('CHECK_PROJECT_CONTRACT_EXISTS');
	retval := FND_API.G_RET_STS_SUCCESS;

/*
  -- Old code
	output := OKE_UTILS.Project_Used(p_project_id);
*/

/*	OKE_PA_CHECKS_PUB.Project_Used(p_api_version => 1.0,
		p_commit => FND_API.G_TRUE,
		p_init_msg_list => FND_API.G_FALSE,
    x_msg_count => msg_count,
		x_msg_data => msg_data,
		x_return_status => ret_status,
		Project_ID => p_project_id,
		X_Result => output
		);  */     --Commented the call to OKE_PA_CHECKS_PUB.Project_Used
	IF (output = 'Y') THEN
		-- project is used, association exists, return error
		retval := FND_API.G_RET_STS_ERROR;
	ELSE
    -- no association exists, return success
		retval := FND_API.G_RET_STS_SUCCESS;
	END IF;


	pa_debug.reset_err_stack;
	return retval;
EXCEPTION
	When OTHERS Then
		return FND_API.G_RET_STS_UNEXP_ERROR;
END CHECK_PROJECT_CONTRACT_EXISTS;


function CHECK_TASK_CONTRACT_EXISTS
(
	p_task_id	IN	NUMBER
)
return VARCHAR2
IS
	output		VARCHAR2(1);
	retval		VARCHAR2(1);
  msg_count NUMBER;
	msg_data	VARCHAR2(2000);
	ret_status VARCHAR2(10);
BEGIN
	pa_debug.set_err_stack('CHECK_TASK_CONTRACT_EXISTS');
	retval := FND_API.G_RET_STS_SUCCESS;

/*
  -- Old code
	output := OKE_UTILS.Task_Used(p_task_id);
*/
/*	OKE_PA_CHECKS_PUB.Task_Used(p_api_version => 1.0,
		p_commit => FND_API.G_TRUE,
		p_init_msg_list => FND_API.G_FALSE,
    x_msg_count => msg_count,
		x_msg_data => msg_data,
		x_return_status => ret_status,
		Task_ID => p_task_id,
		x_Result => output
		);*/      --Commented the call to OKE_PA_CHECKS_PUB.Project_Used
	IF (output = 'Y') THEN
		-- project is used, association exists, return error
		retval := FND_API.G_RET_STS_ERROR;
	ELSE
    -- no association exists, return success
		retval := FND_API.G_RET_STS_SUCCESS;
	END IF;

	pa_debug.reset_err_stack;
	return retval;
EXCEPTION
	When OTHERS Then
		return FND_API.G_RET_STS_UNEXP_ERROR;
END CHECK_TASK_CONTRACT_EXISTS;
-- FP M: Project Execution Workflow Changes
FUNCTION IS_WF_ENABLED_FOR_STRUCTURE(
	p_project_id			IN		NUMBER
    ,p_structure_type		IN		VARCHAR2
)
RETURN VARCHAR2
IS
-- This cursor selects the enable_wf_flag
-- for the given structure and for given project.
CURSOR C IS
 SELECT ENABLE_WF_FLAG
   FROM PA_PROJ_ELEMENTS ppe,
        PA_PROJ_STRUCTURE_TYPES pps,
        PA_STRUCTURE_TYPES pst
  WHERE ppe.project_id = p_project_id
    AND ppe.object_type = 'PA_STRUCTURES'
    AND ppe.proj_element_id = pps.proj_element_id
    AND pps.structure_type_id = pst.structure_type_id
    AND pst.structure_type_class_code = p_structure_type ;

    l_dummy VARCHAR2(1) := 'N' ;
BEGIN
   OPEN C;
   FETCH C INTO l_dummy ;
   IF C%NOTFOUND THEN
     l_dummy := 'N';
   END IF ;
   CLOSE C;
   RETURN nvl(l_dummy,'N') ;
EXCEPTION
	WHEN OTHERS THEN
		return 'N';
END IS_WF_ENABLED_FOR_STRUCTURE ;

function Get_All_Wbs_Rejns(
p_project_id                   IN Number,
p_calling_mode                 IN Varchar2 Default 'PROJ_STR_VER',
p_proj_str_version_id          IN Number,
p_Task_str_version_id          IN Number   Default Null,
p_start_date                   IN Date     Default Null,
p_end_date                     IN Date     Default Null
)
return VARCHAR2
IS
  f1 varchar2(2000);
  f2 varchar2(2000);
  f3 varchar2(2000);
  f4 varchar2(2000);
  f5 varchar2(2000);
  f6 varchar2(2000);
  rs varchar2(2000);
  returnflag varchar2(2000);


  l_budget_version_id pa_budget_versions.budget_version_id%TYPE;

BEGIN

-- Bug Fix 5611909.
-- Caching the budget_version id and passing it to the PA_FIN_PLAN_UTILS2.Get_WbsBdgtLineRejns.
-- Get the budget_version_id from the db for the following conditions.
-- 1) This API is called for the first time. Both globals are NULL.
-- 2) This API is called for a different project id other than the global project id.

  IF
     (((PA_PROJ_STRUCTURE_UTILS.G_PROJECT_ID IS NULL) AND (PA_PROJ_STRUCTURE_UTILS.G_BUDGET_VERSION_ID IS NULL))
  OR
     (PA_PROJ_STRUCTURE_UTILS.G_PROJECT_ID <> p_project_ID)) THEN

     l_budget_version_id := Pa_Fp_wp_gen_amt_utils.get_wp_version_id
			(p_project_id       => p_project_id
                         ,p_plan_type_id    => null
                         ,p_proj_str_ver_id => p_proj_str_version_id);

     set_budget_version_id_global(p_project_id,l_budget_version_id);

   END IF;

  PA_FIN_PLAN_UTILS2.Get_WbsBdgtLineRejns
        (p_project_id => p_project_id,
         p_calling_mode => p_calling_mode,
         p_proj_str_version_id => p_proj_str_version_id,
         p_Task_str_version_id => p_Task_str_version_id,
         p_start_date => p_start_date,
         p_end_date => p_end_date,
         p_budget_version_id => PA_PROJ_STRUCTURE_UTILS.G_BUDGET_VERSION_ID,
         x_cost_rejn_flag => f1,
         x_burden_rejn_flag => f2,
         x_revenue_rejn_flag => f3,
         x_pc_conv_rejn_flag => f4,
         x_pfc_conv_rejn_flag => f5,
         x_projstrlvl_rejn_flag => f6,
         x_return_status => rs);
  returnflag := 'N';
  IF (p_calling_mode = 'PROJ_STR_VER') THEN
    IF (f6 = 'Y') THEN returnflag := 'Y'; END IF;
  ELSE
    IF (f1 = 'Y') THEN returnflag := 'Y'; END IF;
    IF (f2 = 'Y') THEN returnflag := 'Y'; END IF;
    IF (f3 = 'Y') THEN returnflag := 'Y'; END IF;
    IF (f4 = 'Y') THEN returnflag := 'Y'; END IF;
    IF (f5 = 'Y') THEN returnflag := 'Y'; END IF;
  END IF;
  RETURN (returnflag);
END Get_All_Wbs_Rejns;


--bug 4290593
function CHECK_STR_TEMP_TAB_POPULATED(p_project_id NUMBER) RETURN VARCHAR2 IS
   CURSOR cur_str_tmp
   IS
     SELECT 'x' FROM pa_structures_tasks_tmp
     WHERE parent_project_id=p_project_id
     and rownum < 2;

   l_dummy   VARCHAR2(1);
BEGIN
   OPEN cur_str_tmp;
   FETCH cur_str_tmp INTO l_dummy;
   IF cur_str_tmp%FOUND
   THEN
      CLOSE cur_str_tmp;
      RETURN 'Y';
   ELSE
      CLOSE cur_str_tmp;
      RETURN 'N';
   END IF;
END CHECK_STR_TEMP_TAB_POPULATED;

function CHECK_PJI_TEMP_TAB_POPULATED(p_project_id NUMBER) RETURN VARCHAR2 IS
   CURSOR cur_pji_tmp
   IS
     SELECT 'x' FROM pji_fm_xbs_accum_tmp1
     WHERE project_id=p_project_id
     and rownum < 2;

   l_dummy   VARCHAR2(1);
BEGIN
   OPEN cur_pji_tmp;
   FETCH cur_pji_tmp INTO l_dummy;
   IF cur_pji_tmp%FOUND
   THEN
      CLOSE cur_pji_tmp;
      RETURN 'Y';
   ELSE
      CLOSE cur_pji_tmp;
      RETURN 'N';
   END IF;
END CHECK_PJI_TEMP_TAB_POPULATED;
--end bug 4290593

-- Bug Fix 5611909. Creating global variables to cache the project id and budget version id.
-- These will be used in the program unit Get_All_Wbs_Rejns and these will be set by using
-- the set_budget_version_id_global procedure.
-- NOTE: PLEASE DO NOT MODIFY THESE ANYWHERE ELSE OR USING ANY OTHER MEANS.

PROCEDURE  set_budget_version_id_global (p_project_id IN NUMBER,
                                         p_budget_version_id IN NUMBER) IS

BEGIN

--Begin: 6046307: commented out the following IF condition that 'RAISE  FND_API.G_EXC_ERROR' when 'p_project_id' or 'p_budget_version_id' are NULL
/*
  IF p_project_id IS NULL OR p_budget_version_id IS NULL THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
 */
 --End: 6046307

  PA_PROJ_STRUCTURE_UTILS.G_PROJECT_ID := p_project_id;
  PA_PROJ_STRUCTURE_UTILS.G_BUDGET_VERSION_ID := p_budget_version_id;

END;


END PA_PROJ_STRUCTURE_UTILS;


/
