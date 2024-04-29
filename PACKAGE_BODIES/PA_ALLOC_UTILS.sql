--------------------------------------------------------
--  DDL for Package Body PA_ALLOC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ALLOC_UTILS" AS
/* $Header: PAXALUTB.pls 120.1.12010000.3 2009/11/30 12:30:37 rrambati ship $ */

------------------------------------------------------------------------
---  is_resource_in_rules
-----This function returns 'Y' if a resource list member is used in allocations
------------------------------------------------------------------------
FUNCTION Is_resource_in_rules(p_resource_list_member_id IN NUMBER)
                                           RETURN VARCHAR2
IS

CURSOR  C_resource_list_member IS
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
                FROM  PA_ALLOC_RESOURCES  RE
                WHERE  RE.RESOURCE_LIST_MEMBER_ID=P_resource_list_member_id
               )
      OR EXISTS
               (SELECT 'Y'
               FROM   PA_ALLOC_RUN_SOURCE_DET SRC
               WHERE SRC.RESOURCE_LIST_MEMBER_ID=P_resource_list_member_id
               )
       OR EXISTS
               (SELECT 'Y'
               FROM   PA_ALLOC_RUN_BASIS_DET BASIS
               WHERE BASIS.RESOURCE_LIST_MEMBER_ID=P_resource_list_member_id
               );
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);

BEGIN
  v_ret_code := 'N';

  OPEN  C_resource_list_member ;
  FETCH  C_resource_list_member INTO v_dummy;
  IF  C_resource_list_member%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE  C_resource_list_member;
  RETURN v_ret_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_resource_in_rules ;

------------------------------------------------------------------------
---  is_resource_list_in_rules
---- This function returns 'Y' if a resouce list is used in allocations
------------------------------------------------------------------------
FUNCTION  is_resource_list_in_rules(p_resource_list_id IN NUMBER)
                                                 RETURN varchar2 IS
CURSOR  C_resource_list IS
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  PA_ALLOC_RULES_ALL PAL /* Bug 4185336 Changed PA_ALLOC_RULES to PA_ALLOC_RULES_ALL */
               WHERE  PAL.BASIS_RESOURCE_LIST_ID=P_resource_list_id
                OR    PAL.ALLOC_RESOURCE_LIST_ID=P_resource_list_id
               )
      OR EXISTS
               (SELECT 'Y'
               FROM  PA_ALLOC_RUNS_ALL PAR
               WHERE  PAR.BASIS_RESOURCE_LIST_ID=P_resource_list_id
                OR    PAR.ALLOC_RESOURCE_LIST_ID=P_resource_list_id
               );
v_ret_code varchar2(1) ;
v_dummy  varchar2(1);

BEGIN
  v_ret_code := 'N';

  OPEN  C_resource_list ;
  FETCH  C_resource_list INTO v_dummy;
  IF  C_resource_list%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE  C_resource_list;
  RETURN v_ret_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_resource_list_in_rules ;


------------------------------------------------------------------------
---  is_project_in_allocations
---- This function returns 'Y' if a project is used in allocations
------------------------------------------------------------------------
FUNCTION Is_project_in_allocations(p_project_id IN NUMBER)
                                           RETURN VARCHAR2
IS

CURSOR C_project_in_allocations is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  PA_ALLOC_TXN_DETAILS TXN
               WHERE TXN.project_id=p_project_id)
      OR EXISTS
               (SELECT 'Y'
               FROM  PA_ALLOC_RULES_ALL  RULES
               WHERE RULES.offset_project_id=p_project_id)
      OR EXISTS
               (SELECT 'Y'
               FROM  PA_ALLOC_SOURCE_LINES SRCL
               WHERE SRCL.project_id=p_project_id)
      OR EXISTS
              ( SELECT 'Y'
               FROM  PA_ALLOC_TARGET_LINES TGTL
               WHERE TGTL.project_id=p_project_id)
      OR EXISTS
               (SELECT 'Y'
               FROM   PA_ALLOC_RUN_SOURCES  RSRC
               WHERE  RSRC.project_id=p_project_id)
      OR EXISTS
               (SELECT 'Y'
               FROM PA_ALLOC_RUN_TARGETS RTGT
               WHERE  RTGT.project_id=p_project_id);

v_ret_code varchar2(1) ;
v_dummy  varchar2(1);

BEGIN

  v_ret_code := 'N';

  OPEN  C_project_in_allocations;
  FETCH C_project_in_allocations INTO v_dummy;
  IF C_project_in_allocations%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_project_in_allocations;
  RETURN v_ret_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_project_in_allocations;



------------------------------------------------------------------------
---  is_task_in_allocations
---- This function returns 'Y' if a task is used in allocations
------------------------------------------------------------------------
FUNCTION Is_task_in_allocations(p_task_id IN NUMBER)
                                           RETURN VARCHAR2
IS
/***
CURSOR C_subtasks is
 select task_id
 from pa_tasks
 CONNECT BY PRIOR TASK_ID = PARENT_TASK_ID
 START WITH TASK_ID = p_task_id;
 ***/

CURSOR C_task_in_alloc_rule(x_task_id IN NUMBER) is
              SELECT 'Y'
               FROM  PA_ALLOC_RULES_ALL RULES
               WHERE RULES.offset_task_id=x_task_id;
/* Commented for bug 8929749
CURSOR C_task_in_alloc_src_line(x_task_id IN NUMBER) is
               SELECT 'Y'
               FROM  PA_ALLOC_SOURCE_LINES SRCL
               WHERE SRCL.task_id=x_task_id;
*/
CURSOR C_task_in_alloc_tgt_line(x_task_id IN NUMBER) is
               SELECT 'Y'
               FROM  PA_ALLOC_TARGET_LINES TGTL
               WHERE TGTL.task_id=x_task_id;
CURSOR C_task_in_alloc_txn(x_task_id IN NUMBER) is
               SELECT 'Y'
               FROM  PA_ALLOC_TXN_DETAILS TXN
               WHERE TXN.task_id=x_task_id;
/* Commented for bug 8929749
CURSOR C_task_in_alloc_run_src(x_task_id IN NUMBER) is
               SELECT 'Y'
               FROM   PA_ALLOC_RUN_SOURCES RSRC
               WHERE  RSRC.task_id=x_task_id;
*/
CURSOR C_task_in_alloc_run_tgt(x_task_id IN NUMBER) is
               SELECT 'Y'
               FROM PA_ALLOC_RUN_TARGETS RTGT
               WHERE  RTGT.task_id=x_task_id;

v_ret_code varchar2(1) := 'N';

BEGIN

 /**
  v_ret_code := 'N';
  For subtasks_rec in C_subtasks LOOP
    OPEN  C_task_in_allocations(p_task_id);
    FETCH C_task_in_allocations INTO v_dummy;
    IF C_task_in_allocations%FOUND THEN
      v_ret_code := 'Y' ;
      close  C_task_in_allocations;
      return  v_ret_code;
    END IF;
    CLOSE C_task_in_allocations;
  END LOOP;
  **/
  open C_task_in_alloc_rule(p_task_id);
  fetch C_task_in_alloc_rule into v_ret_code;
  close C_task_in_alloc_rule;
/* Commented for bug 8929749
  if (v_ret_code = 'N') then
    open C_task_in_alloc_src_line(p_task_id);
    fetch C_task_in_alloc_src_line into v_ret_code;
    close C_task_in_alloc_src_line;
  else
    RETURN v_ret_code;
  end if;
*/
  if (v_ret_code = 'N') then
    open C_task_in_alloc_tgt_line(p_task_id);
    fetch C_task_in_alloc_tgt_line into v_ret_code;
    close C_task_in_alloc_tgt_line;
  else
    RETURN v_ret_code;
  end if;

  if (v_ret_code = 'N') then
    open C_task_in_alloc_txn(p_task_id);
    fetch C_task_in_alloc_txn into v_ret_code;
    close C_task_in_alloc_txn;
  else
    RETURN v_ret_code;
  end if;
/* Commented for bug 8929749
  if (v_ret_code = 'N') then
    open C_task_in_alloc_run_src(p_task_id);
    fetch C_task_in_alloc_run_src into v_ret_code;
    close C_task_in_alloc_run_src;
  else
    RETURN v_ret_code;
  end if;
*/
  if (v_ret_code = 'N') then
    open C_task_in_alloc_run_tgt(p_task_id);
    fetch C_task_in_alloc_run_tgt into v_ret_code;
    close C_task_in_alloc_run_tgt;
  else
    RETURN v_ret_code;
  end if;

    RETURN v_ret_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_task_in_allocations;

------------------------------------------------------------------------
---  is_task_lowest_in_allocations
---  This function returns 'Y' if a task is used as target or offset, or if
---- a task is a non top level task and used as source in allocations
------------------------------------------------------------------------
-- All target tasks and offset tasks should be lowest level tasks, subtasks are not
--allowed to be created for them. For a given task, if it  exists in any target or
--offset related table,no subtask is allowed to be created for this task.
--Source tasks can be top level tasks or lowest level tasks.For a given task,
--if it exists in any source related table and it is not a top level task, no subtask is allowed
--to be created for this task.


FUNCTION Is_task_lowest_in_allocations(p_task_id IN NUMBER)
                                           RETURN VARCHAR2
IS

CURSOR  C_task_in_targets_offsets IS
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT '1'
               FROM  PA_ALLOC_TXN_DETAILS TXN
               WHERE TXN.task_id=p_task_id)
      OR EXISTS
              ( SELECT '1'
               FROM  PA_ALLOC_RULES_ALL RULES
               WHERE RULES.offset_task_id=p_task_id)
      OR EXISTS
               (SELECT '1'
               FROM  PA_ALLOC_TARGET_LINES TGTL
               WHERE TGTL.task_id=p_task_id)
      OR EXISTS
               (SELECT '1'
               FROM PA_ALLOC_RUN_TARGETS RTGT
               WHERE  RTGT.task_id=p_task_id);

CURSOR  C_task_in_sources IS
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT '1'
               FROM  PA_ALLOC_SOURCE_LINES SRCL
               WHERE SRCL.task_id=p_task_id)
       OR EXISTS
              ( SELECT '1'
               FROM  PA_ALLOC_RUN_SOURCES RSRC
               WHERE RSRC.task_id=p_task_id);

CURSOR C_top_task(p_tsk_id IN NUMBER) IS
 SELECT top_task_id
 FROM pa_tasks
 WHERE task_id=p_tsk_id;


v_ret_code varchar2(1) ;
v_dummy varchar2(1);
v_top_task_id number;


BEGIN

  v_ret_code := 'N';
  OPEN  C_top_task(p_task_id);
  FETCH C_top_task INTO v_top_task_id;
  CLOSE C_top_task;

  OPEN  C_task_in_targets_offsets;
  FETCH C_task_in_targets_offsets INTO v_dummy;
  IF C_task_in_targets_offsets%FOUND THEN
         v_ret_code := 'Y';
 END IF;

  /* Bug# 8834708
     This check is not required while creating a sub task for a task.
     Though we have data in alloc run sources, it does not cause any issue
     unless there is expenditure for the task being passed to this procedure.
     Since we are checking the existance of expenditure even before calling this
     API, it is fine to relax this validation and allow creating sub task though
     the task referred in the sources table.
  ELSE
    OPEN  C_task_in_sources;
    FETCH C_task_in_sources INTO v_dummy;
    IF C_task_in_sources%FOUND THEN
    IF (v_top_task_id <> p_task_id) THEN
           v_ret_code := 'Y';
       END IF;
    END IF;
    CLOSE C_task_in_sources;
  END IF; */
  CLOSE  C_task_in_targets_offsets;

  RETURN v_ret_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     RETURN v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
END  is_task_lowest_in_allocations;



------------------------------------------------------------------------
--- Is_Budget_Type_In_allocations
---- This function returns 'Y' if a budget_type is used in allocations
------------------------------------------------------------------------
FUNCTION  Is_Budget_Type_In_allocations(p_budget_type_code IN varchar2)
                                                 RETURN varchar2
is
CURSOR C_budget_type_in_allocations is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  PA_ALLOC_RULES_ALL
               WHERE basis_budget_type_code=p_budget_type_code)
      OR EXISTS
               (SELECT 'Y'
               FROM  PA_ALLOC_RUNS_ALL
               WHERE basis_budget_type_code=p_budget_type_code);

v_ret_code varchar2(1) ;
v_dummy  varchar2(1);

BEGIN

  v_ret_code := 'N';

  OPEN  C_budget_type_in_allocations;
  FETCH C_budget_type_in_allocations INTO v_dummy;
  IF C_budget_type_in_allocations%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_budget_type_in_allocations;
  RETURN v_ret_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
end Is_Budget_Type_In_allocations;

/*
------------------------------------------------------------------------
--- Is_Bem_In_allocations
---- This function returns 'Y' if a budget entry method is used in allocations
------------------------------------------------------------------------
FUNCTION  Is_Bem_In_allocations(p_bem_code IN varchar2)
                                                 RETURN varchar2
is

 CURSOR C_Bem_in_allocations is
 SELECT '1'
 FROM dual
 WHERE EXISTS (SELECT 'Y'
               FROM  PA_ALLOC_RULES_ALL
               WHERE basis_budget_entry_method_code=p_bem_code)
      OR EXISTS
               (SELECT 'Y'
               FROM  PA_ALLOC_RUNS_ALL
               WHERE basis_budget_entry_method_code=p_bem_code);

v_ret_code varchar2(1) ;
v_dummy  varchar2(1);

BEGIN

  v_ret_code := 'N';

  open C_Bem_in_allocations;
  FETCH C_Bem_in_allocations into v_dummy;
  IF C_Bem_in_allocations%FOUND THEN
     v_ret_code := 'Y' ;
  END IF;
  CLOSE C_Bem_in_allocations;
  RETURN v_ret_code;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     v_ret_code := 'N' ;
     Return v_ret_code ;
  WHEN OTHERS THEN
  RAISE;
end Is_Bem_In_allocations;*/


/*
 API Name : Is_RBS_In_Rules
 API Desc : Return 'Y' if RBS is used in Allocations.
 API Created Date : 19-Mar-04
 API Created By : Vthakkar
*/
FUNCTION Is_RBS_In_Rules ( P_RBS_ID IN pa_rbs_headers_v.RBS_HEADER_ID%Type ) RETURN VARCHAR2
IS
	l_exists Varchar2(1) := 'N';
BEGIN
	/* Checking PA_ALLOC_RULES_ALL */
	Begin
		Select 'Y' into l_exists
		  from pa_alloc_rules_all /* Bug 4185336 Changed from pa_alloc_rules to pa_alloc_rules_all */
		 where
			  (
				(	ALLOC_RESOURCE_STRUCT_TYPE  = 'RBS'
					and
					Alloc_resource_list_id = P_RBS_ID
				)
				or
				(
					BASIS_RESOURCE_STRUCT_TYPE  = 'RBS'
					and
					BASIS_resource_list_id = P_RBS_ID
				)
			  )
		   and rownum = 1;
		   Return l_exists ;
	Exception
		When No_Data_Found Then
			l_exists := 'N';
	End;
	/* Checking PA_ALLOC_RUNS_ALL */
	Begin
		Select 'Y' into l_exists
		  from pa_alloc_runs_all  /* Bug 4185336 Changed from pa_alloc_rules to pa_alloc_rules_all */
		 where (
				(	ALLOC_RESOURCE_STRUCT_TYPE  = 'RBS'
					and
					Alloc_resource_list_id = P_RBS_ID
				)
				or
				(
					BASIS_RESOURCE_STRUCT_TYPE  = 'RBS'
					and
					BASIS_resource_list_id = P_RBS_ID
				)
			  )
		   and rownum = 1;
		   Return l_exists ;
	Exception
		When No_Data_Found Then
			l_exists := 'N';
	End;
	Return l_exists;
END Is_RBS_In_Rules ;
/*
 API Name : Is_RBS_In_Rules

 API Desc : Return 'Y' if RBS Element is used in Allocations.
 API Created Date : 19-Mar-04
 API Created By : Vthakkar
*/
FUNCTION Is_RBS_Element_In_Rules ( P_RBS_ELEMENT_ID IN pa_rbs_elements.RBS_ELEMENT_ID%type ) RETURN
VARCHAR2

IS
	l_exists Varchar2(1) := 'N';
BEGIN
	Begin
		Select 'Y' into l_exists
		  From PA_ALLOC_RULES_ALL par, PA_ALLOC_RESOURCES pr
		 Where par.rule_id = pr.rule_id
		   and pr.RESOURCE_LIST_MEMBER_ID = P_RBS_ELEMENT_ID
		   and decode (pr.member_type , 'S' , par.ALLOC_RESOURCE_STRUCT_TYPE  ,
										'B' , par.BASIS_RESOURCE_STRUCT_TYPE
					  ) = 'RBS'
		   and rownum = 1;
		   Return l_exists ;
	Exception
		When No_Data_Found Then
			l_exists := 'N';

	End;
	Begin
		Select 'Y' into l_exists
		  From pa_alloc_runs_all par, PA_ALLOC_RUN_SOURCE_DET pars
		 Where par.run_id = pars.run_id
		   and par.rule_id = pars.rule_id
		   and RESOURCE_LIST_MEMBER_ID = P_RBS_ELEMENT_ID
		   and par.ALLOC_RESOURCE_STRUCT_TYPE  = 'RBS'
		   and rownum = 1;
		   Return l_exists ;
	Exception
		When No_Data_Found Then
			l_exists := 'N';
	End;
	Begin
		Select 'Y' into l_exists
		  From pa_alloc_runs_all par, PA_ALLOC_RUN_BASIS_DET pars
		 Where par.run_id = pars.run_id
		   and par.rule_id = pars.rule_id
		   and RESOURCE_LIST_MEMBER_ID = P_RBS_ELEMENT_ID
		   and par.BASIS_RESOURCE_STRUCT_TYPE  = 'RBS'
		   and rownum = 1;
		   Return l_exists ;

	Exception
		When No_Data_Found Then
			l_exists := 'N';
	End;
	Return l_exists ;
END Is_RBS_Element_In_Rules;
/*
 API Name : Resource_Name
 API Desc : This function will be return the name of the resource id depending upon the Allocation T
ype and

			If Resource ID is member of Resource List or RBS Structure.
 API Created Date : 19-Mar-04
 API Created By : Vthakkar
*/
Function Resource_Name (
						p_alloc_type    IN	 Varchar2 ,
						p_resource_id	IN   pa_rbs_elements.RBS_ELEMENT_ID%type   ,
						p_rule_id		IN   pa_alloc_rules.rule_id%type
					   ) Return Varchar2
IS
	l_source_res_struct_type	pa_alloc_rules_all.ALLOC_RESOURCE_STRUCT_TYPE%type;
	l_basis_res_struct_type		pa_alloc_rules_all.BASIS_RESOURCE_STRUCT_TYPE%type;

	x_name						varchar2(4000);
BEGIN
	If p_resource_id Is Null Then
		Return Null;
	End If;
	Select ALLOC_RESOURCE_STRUCT_TYPE ,
		   BASIS_RESOURCE_STRUCT_TYPE
	  Into l_source_res_struct_type ,
	 	   l_basis_res_struct_type
      From pa_alloc_rules_all
	 Where Rule_ID = p_Rule_Id;
	If p_alloc_type In ('SOURCE' , 'S') Then
		If l_source_res_struct_type  = 'RL' Then
			select prlm.alias
			  Into X_name
		 	  from pa_resource_list_members prlm
		   	 where prlm.resource_list_member_id = p_resource_id;
		Elsif l_source_res_struct_type  = 'RBS' Then
			Select pa_alloc_utils.Get_Resource_Name_TL (RBS_ELEMENT_NAME_ID)
			  Into X_name
			  From pa_rbs_elements
		 	 Where rbs_element_id = p_resource_id
			   And rownum = 1;

		End If;
	ElsIf p_alloc_type In ('BASIS', 'B' ) Then
		If l_basis_res_struct_type  = 'RL' Then
			select prlm.alias
			  Into X_name
		 	  from pa_resource_list_members prlm
		   	 where prlm.resource_list_member_id = p_resource_id;
		Elsif l_basis_res_struct_type  = 'RBS' Then
			select pa_alloc_utils.Get_Resource_Name_TL (RBS_ELEMENT_NAME_ID)
			  Into X_name
			  from pa_rbs_elements
		 	 where rbs_element_id = p_resource_id
			   and rownum = 1;
		End If;
	End If;
	Return X_name;
END Resource_Name ;
/*
 API Name : ASSOCIATE_RBS_TO_ALLOC_RULE
 API Desc : This procedure will be update the new element id to the allocation rules's source resource list member's id
			and basis resource list member's id when new version of RBS is created
 API Created Date : 02-Apr-04
 API Created By : Vthakkar

 History :

	07-JAN-2005 VTHAKKAR Changed the API for bug 4107924

*/
Procedure ASSOCIATE_RBS_TO_ALLOC_RULE (
										p_rbs_header_id		IN NUMBER    ,
										p_rbs_version_id	IN NUMBER	 ,
										x_return_status     OUT NOCOPY VARCHAR2 ,
										x_error_code        OUT NOCOPY VARCHAR2
									  )
IS
	CURSOR LV_ALLOC_CUR IS SELECT * FROM PA_ALLOC_RULES_ALL
	                        WHERE alloc_resource_list_id = p_rbs_header_id
							   OR basis_resource_list_id = p_rbs_header_id;
BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	/* Changed the API for Bug 4107924 */
	FOR ALLOC_CUR IN LV_ALLOC_CUR
	LOOP

		/* Source Update */

		IF NVL(ALLOC_CUR.alloc_resource_struct_type,'RL') = 'RBS' and ALLOC_CUR.alloc_resource_list_id = p_rbs_header_id
		   and NVL(ALLOC_CUR.ALLOC_RBS_VERSION,0) < p_rbs_version_id Then

			Update pa_alloc_rules_all
			   Set alloc_rbs_version = p_rbs_version_id
			 Where RULE_ID = ALLOC_CUR.RULE_ID;

			Update pa_alloc_resources ARS
			   Set resource_list_member_id = (
											select new.rbs_element_id
											  from pa_rbs_elements new
												  ,pa_rbs_elements old
											 where new.element_identifier = old.element_identifier
											   and old.rbs_version_Id     = ALLOC_CUR.alloc_rbs_version
											   and new.rbs_version_Id     = p_rbs_version_id
											   and old.rbs_element_id     = ars.resource_list_member_id
											   and new.user_created_flag = 'N'
										  )
			 Where ARS.RULE_ID = ALLOC_CUR.RULE_ID
			   AND ARS.MEMBER_TYPE = 'S';


		END IF;

		/* Basis Update */

		IF NVL(ALLOC_CUR.basis_resource_struct_type,'RL') = 'RBS' and ALLOC_CUR.basis_resource_list_id = p_rbs_header_id
		   and NVL(ALLOC_CUR.BASIS_RBS_VERSION,0) < p_rbs_version_id Then

			Update pa_alloc_rules_all
			   Set basis_rbs_version = p_rbs_version_id
			 Where RULE_ID = ALLOC_CUR.RULE_ID;

			Update pa_alloc_resources ARS
			   Set resource_list_member_id = (
										select new.rbs_element_id
										  from pa_rbs_elements new
											  ,pa_rbs_elements old
					                     where new.element_identifier = old.element_identifier
									       and old.rbs_version_Id     = ALLOC_CUR.basis_rbs_version
										   and new.rbs_version_Id     = p_rbs_version_id
	                                       and old.rbs_element_id     = ars.resource_list_member_id
										   and new.user_created_flag = 'N'
									  )
			  Where ARS.RULE_ID = ALLOC_CUR.RULE_ID
			    AND ARS.MEMBER_TYPE = 'B';

		END IF;

	END LOOP;

	/* Commenting out the code for bug 4107924
	Update pa_alloc_resources ARS
	   Set resource_list_member_id = (
									 select new.rbs_element_id
		                               from pa_rbs_elements new
			                               ,pa_rbs_elements old
				                           ,pa_alloc_rules_all ar
					                  where ar.alloc_resource_list_id = p_rbs_header_id
						                and decode ( ars.member_type ,
														'S' , nvl(ar.alloc_resource_struct_type,'RL') ,
														'B' , nvl(ar.basis_resource_struct_type,'RL')
													) = 'RBS'
							            and ar.rule_id = ars.rule_id
									    and new.element_identifier = old.element_identifier
									    and old.rbs_version_Id     = ar.alloc_rbs_version
										and new.rbs_version_Id     = p_rbs_version_id
	                                    and old.rbs_element_id     = ars.resource_list_member_id
									  )
	  Where Exists (
					 select 1
					   From pa_alloc_rules_all arl
					  Where arl.Rule_Id = Ars.Rule_Id
						ANd decode ( ars.member_type ,
										'S' , nvl(arl.alloc_resource_struct_type,'RL') ,
										'B' , nvl(arl.basis_resource_struct_type,'RL')
								   ) = 'RBS'
				   );
	Update pa_alloc_rules_all
	   Set alloc_rbs_version = p_rbs_version_id
	 Where nvl(alloc_resource_struct_type,'RL') = 'RBS'
	   And alloc_resource_list_id = p_rbs_header_id;
	Update pa_alloc_rules_all
	   Set basis_rbs_version = p_rbs_version_id
	 Where nvl(basis_resource_struct_type,'RL') = 'RBS'
	   And basis_resource_list_id = p_rbs_header_id;

	 End of commeting code for bug 4107924

	*/

EXCEPTION
 WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := to_char(sqlcode);
END ASSOCIATE_RBS_TO_ALLOC_RULE;
/*
 API Name : RESOURCE_LIST_NAME
 API Desc : This function will return name of Resource List or Resource Breakdown Structure Header N
ame depending Upon

			Rule contains Resource List or Resource Structure.
 API Created Date : 06-Apr-04
 API Created By : Vthakkar
*/
Function RESOURCE_LIST_NAME (
							 p_resource_list_id In Number ,
							 p_resource_struct_type in Varchar2
						    ) Return Varchar2
Is
	X_Resource_List_Name Varchar2(4000);
Begin
		If Nvl(p_Resource_Struct_Type,'RL') = 'RL' Then
			Select Name

			  Into X_Resource_List_Name
 			  From pa_resource_lists_v
			 Where RESOURCE_LIST_ID = p_resource_list_id;
		Elsif Nvl(p_Resource_Struct_Type,'RL') = 'RBS' Then
			Select Name
			  Into X_Resource_List_Name
 			  From pa_rbs_headers_v
			 Where RBS_HEADER_ID = p_resource_list_id;
		End If;
		Return X_Resource_List_Name;
Exception
	When Others Then
		Return Null;
End;
/*
 API Name : GET_CONCATENATED_NAME
 API Desc : This function will return name of Resource List Member attached with parent member name
like e.g self.parent

 API Created Date : 03-May-04
 API Created By : Vthakkar
*/
Function GET_CONCATENATED_NAME (p_resource_id in Number , p_struct_type in Varchar2 ) Return

Varchar2 Is
	X_Resource_Name		Varchar2(10000);
	l_self_name			pa_resource_list_members.alias%type;
	l_parent_name		pa_resource_list_members.alias%type;
	l_element_name Varchar2(240);
    l_count        Number;
	Cursor C_Member_Name
	  Is Select slf.alias , prt.alias
	  from pa_resource_list_members slf , pa_resource_list_members prt
	 Where prt.resource_list_member_id (+) = slf.parent_member_id
	   and slf.resource_list_member_id     = p_resource_id;
   Cursor c_element_name
	   IS SELECT pa_alloc_utils.Get_Resource_Name_TL(ele.rbs_element_name_id) Resource_Name
	        FROM pa_rbs_elements ele
	     CONNECT BY PRIOR ele.parent_element_id = ele.rbs_element_id
		   START WITH ele.rbs_element_id = p_resource_id
		   ORDER BY ele.rbs_level DESC;
Begin
	If p_resource_id is Null Then
		Return Null;
	End If;
	If p_struct_type = 'RL' Then
		Open C_Member_Name;

		Fetch C_Member_Name into l_self_name , l_parent_name;
		If C_Member_Name%Found Then
			X_Resource_Name := l_self_name;
			If l_parent_name Is Not Null Then
				X_Resource_Name := X_Resource_Name  || '.' || l_parent_name;
			End If;
		End If;
		Close C_Member_Name;
	ElsIf p_struct_type = 'RBS' Then
		OPEN c_element_name;
		   LOOP
		       FETCH c_element_name INTO l_element_name;
			   EXIT WHEN c_element_name%NOTFOUND;
		       l_count := c_element_name%ROWCOUNT;
		       /*********************************************
			       * If Count is 1 just assing the l_element_name to the
			       * X_Resource_Name.
		       ***************************************************/
		       IF l_count = 1 THEN
				    X_Resource_Name := l_element_name;
		       ELSE
		       /*********************************************
			       * If Count > 1 just assing the l_element_name to the

			       * X_Resource_Name.
		       ***************************************************/
					X_Resource_Name := X_Resource_Name ||'.'|| l_element_name;
		       END IF;
		    END LOOP;
		CLOSE c_element_name;
	End If;
	Return X_Resource_Name;
Exception
	When Others Then
		Return Null;
End GET_CONCATENATED_NAME;
/*
 API Name : Get_Rbs_Version_Name
 API Desc : This function will return name of RBS Version Name provided rbs_version_id
 API Created Date : 11-May-2004
 API Created By : Vthakkar
*/
Function Get_Rbs_Version_Name (p_rbs_ver_id in Number) Return Varchar2
Is
	X_Rbs_Ver_Name pa_rbs_versions_v.NAME%TYPE;
Begin
	If p_rbs_ver_id Is Null Then

		Return Null;
	End If;
	Select Name
	  Into X_Rbs_Ver_Name
	  From pa_rbs_versions_v
	 Where Rbs_Version_Id = P_Rbs_Ver_Id;
	Return (X_Rbs_Ver_Name);
Exception
	When Others Then
		Return Null;
End Get_Rbs_Version_Name ;
/*
 API Name : Get_Resource_Name_TL
 API Desc : This function will return name of RBS Name translated in the respective language
 API Created Date : 13-May-2004
 API Created By : Vthakkar
*/
Function Get_Resource_Name_TL ( p_rbs_element_name_id in Number ) Return Varchar2
Is
	x_resource_name Varchar2(240);
Begin
	If p_rbs_element_name_id  Is Null Then
		Return Null;

	End If;
	Select resource_name
	  Into x_resource_name
	  From pa_rbs_element_names_tl
	 Where rbs_element_name_id = p_rbs_element_name_id
	   and language = USERENV('LANG'); /* Added for bug 3960634 */
	Return x_resource_name;
Exception
	When Others Then
  	   Return Null;
End Get_Resource_Name_TL;


END pa_alloc_utils ;

/
