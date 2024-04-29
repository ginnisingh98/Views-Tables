--------------------------------------------------------
--  DDL for Package Body PA_DDC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DDC_API" AS
/* $Header: PAXDDC0B.pls 120.2 2005/08/19 17:13:17 mwasowic ship $ */

FUNCTION Check_Alias (x_alias IN VARCHAR2
			, x_folder_code IN VARCHAR2) RETURN VARCHAR2 IS

	dummy NUMBER	:= 0;
BEGIN
	SELECT count(1)
	INTO	dummy
	FROM 	pa_status_column_setup
	WHERE	folder_code = x_folder_code
	AND	INSTR(column_name,x_alias) > 0;

	IF (dummy >= 1) THEN
		RETURN ('Y');
	ELSE
		RETURN ('N');
	END IF;

END Check_Alias;


PROCEDURE create_psi_generic_views
		(x_view_name	IN VARCHAR2
		 , x_err_stage	IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
		 , x_err_code	IN OUT NOCOPY NUMBER) --File.Sql.39 bug 4440895
IS

   ddl_stmt          	VARCHAR2(5000);
   key_fields_1       	VARCHAR2(3000);
   key_fields_2        	VARCHAR2(3000);
   stmt               	VARCHAR2(4000);
   from_clause        	VARCHAR2(1000);
   where_clause       	VARCHAR2(1000);

   cid 			INTEGER;


    CURSOR p1 IS
		SELECT format_code, column_name, currency_format_flag
		FROM pa_status_column_setup
		WHERE folder_code = 'P'
		order by folder_code, format_code, column_order;

    CURSOR t1 IS
		SELECT format_code, column_name, currency_format_flag
		FROM pa_status_column_setup
		WHERE folder_code = 'T'
		order by folder_code, format_code, column_order;

     CURSOR r1 IS
		SELECT format_code, column_name, currency_format_flag
		FROM pa_status_column_setup
		WHERE folder_code = 'R'
		order by folder_code, format_code, column_order;


BEGIN

	x_err_code	:= 0;

	IF (x_view_name = 'PA_STATUS_PROJ_GENERIC_V') THEN
		x_err_stage  :=  'Creating PA_STATUS_PROJ_GENERIC_V';
	ELSIF  (x_view_name= 'PA_STATUS_TASK_GENERIC_V') THEN
		x_err_stage  :=  'Creating PA_STATUS_TASK_GENERIC_V';
	ELSIF  (x_view_name= 'PA_STATUS_TASK_GENERIC_V') THEN
		x_err_stage  :=  'Creating PA_STATUS_TASK_GENERIC_V';
	ELSE
		x_err_stage  :=  'Invalid Argument:  '|| x_view_name;
	END IF;

--
-- Build SQL Strings by View
--

IF (x_view_name= 'PA_STATUS_PROJ_GENERIC_V') THEN

ddl_stmt := 'CREATE OR REPLACE FORCE VIEW   PA_STATUS_PROJ_GENERIC_V
(	PROJECT_ID
	, VIEW_LABOR_COSTS_ALLOWED
	, COST_BUDGET_TYPE_CODE
	, REV_BUDGET_TYPE_CODE
	, DUMMY1
	, DUMMY2
	, DUMMY3
	, DUMMY4
	, DUMMY5
	, DUMMY6
	, COLUMN1
	, COLUMN2
	, COLUMN3
	, COLUMN4
	, COLUMN5
	, COLUMN6
	, COLUMN7
	, COLUMN8
	, COLUMN9
	, COLUMN10
	, COLUMN11
	, COLUMN12
	, COLUMN13
	, COLUMN14
	, COLUMN15
	, COLUMN16
	, COLUMN17
	, COLUMN18
	, COLUMN19
	, COLUMN20
	, COLUMN21
	, COLUMN22
	, COLUMN23
	, COLUMN24
	, COLUMN25
	, COLUMN26
	, COLUMN27
	, COLUMN28
	, COLUMN29
	, COLUMN30
	, COLUMN31
	, COLUMN32
	, COLUMN33
)  as SELECT
	p.project_id
	, SUBSTR(pa_security.view_labor_costs(p.project_id),1,1)
	, c.budget_type_code
	, r.budget_type_code
	, 1
	, 2
	, 3
	, 4
	, 5
	, 6';


from_clause := 'pa_projects p,pa_project_accum_headers pah,pa_status_proj_bgt_rev_v r,pa_status_proj_bgt_cost_v c';

/* Fix for bug# 1461358 */
where_clause := '''Y''' ||' in (select pa_security.allow_query(pah.project_id) from sys.dual)  AND p.project_id = pah.project_id AND pah.task_id = 0 AND pah.resource_list_id = 0
		AND pah.project_id = r.project_id AND pah.project_id = c.project_id';


	IF (PA_DDC_API.Check_Alias('A.','P') = 'Y') THEN

		from_clause := from_clause||',pa_project_accum_actuals a';

		where_clause := where_clause||' AND pah.project_accum_id = a.project_accum_id (+)';

	END IF;

	IF (PA_DDC_API.Check_Alias('M.','P') = 'Y') THEN

		from_clause := from_clause||',pa_project_accum_commitments m';

		where_clause := where_clause||' AND pah.project_accum_id = m.project_accum_id (+)';

	END IF;



	FOR p1rec IN p1 LOOP
		IF (p1rec.format_code = 'C') THEN

			IF (p1rec.column_name IS NULL) THEN
				stmt := stmt||',null';
			ELSE
				stmt := stmt||','||p1rec.column_name;
			END IF;
		ELSE

			IF (p1rec.column_name IS NULL) THEN
				stmt := stmt||',0';
			ELSE
			   IF (p1rec.currency_format_flag IS NULL) THEN
				stmt := stmt||','||p1rec.column_name;
			  ELSE
			      	stmt :=  stmt||',('||p1rec.column_name||')/(PA_STATUS.Get_factor)';
			  END IF;
			END IF;
		END IF;


	END LOOP;

ELSIF (x_view_name= 'PA_STATUS_TASK_GENERIC_V') THEN

ddl_stmt := 'CREATE OR REPLACE FORCE VIEW   PA_STATUS_TASK_GENERIC_V
(	PROJECT_ID
	, TASK_ID
	, PARENT_TASK_ID
	, WBS_LEVEL
	, COST_BUDGET_TYPE_CODE
	, REV_BUDGET_TYPE_CODE
        , CHILD_EXIST_FLAG
	, COLUMN1
	, COLUMN2
	, COLUMN3
	, COLUMN4
	, COLUMN5
	, COLUMN6
	, COLUMN7
	, COLUMN8
	, COLUMN9
	, COLUMN10
	, COLUMN11
	, COLUMN12
	, COLUMN13
	, COLUMN14
	, COLUMN15
	, COLUMN16
	, COLUMN17
	, COLUMN18
	, COLUMN19
	, COLUMN20
	, COLUMN21
	, COLUMN22
	, COLUMN23
	, COLUMN24
	, COLUMN25
	, COLUMN26
	, COLUMN27
	, COLUMN28
	, COLUMN29
	, COLUMN30
	, COLUMN31
	, COLUMN32
	, COLUMN33
)  as SELECT
	t.project_id
	, t.task_id
	, t.parent_task_id
	, t.wbs_level
	, c.budget_type_code
	, r.budget_type_code
        , decode(pa_task_utils.check_child_exists(t.task_id),1,''+'',0,'' '') ';



from_clause := 'pa_tasks t,pa_status_task_bgt_cost_high_v c,pa_status_task_bgt_rev_high_v r';


where_clause :='t.project_id = PA_STATUS.GetProjId AND t.task_id = c.task_id (+) AND t.task_id = r.task_id (+)';

	IF (PA_DDC_API.Check_Alias('A.','T') = 'Y') THEN

		from_clause := from_clause||', pa_status_task_act_v a';

		where_clause := where_clause||' AND t.task_id = a.task_id (+)';

	END IF;

	IF (PA_DDC_API.Check_Alias('M.','T') = 'Y') THEN

		from_clause := from_clause||', pa_status_task_cmt_v  m';

		where_clause := where_clause||' AND t.task_id = m.task_id (+)';

	END IF;

	FOR t1rec IN t1 LOOP

		IF (t1rec.format_code = 'C') THEN

			IF (t1rec.column_name IS NULL) THEN
				stmt := stmt||',null';
			ELSE
				stmt := stmt||','||t1rec.column_name;
			END IF;
		ELSE

			IF (t1rec.column_name IS NULL) THEN
				stmt := stmt||',0';
			ELSE
			  IF (t1rec.currency_format_flag IS NULL) THEN
				stmt := stmt||','||t1rec.column_name;
			  ELSE
			      	stmt :=  stmt||',('||t1rec.column_name||')/(PA_STATUS.Get_factor)';
			  END IF;
			END IF;
		END IF;

	END LOOP;


ELSE

ddl_stmt := 'CREATE OR REPLACE FORCE VIEW   PA_STATUS_RSRC_GENERIC_V
(	PROJECT_ID
	, RESOURCE_LIST_MEMBER_ID
	, PARENT_MEMBER_ID
	, MEMBER_LEVEL
	, SORT_ORDER
	, TASK_ID
	, RESOURCE_LIST_ID
	, RESOURCE_LIST_ASSIGNMENT_ID
	, PROJECT_LEVEL_FLAG
        , CHILD_EXIST_FLAG
	, COLUMN1
	, COLUMN2
	, COLUMN3
	, COLUMN4
	, COLUMN5
	, COLUMN6
	, COLUMN7
	, COLUMN8
	, COLUMN9
	, COLUMN10
	, COLUMN11
	, COLUMN12
	, COLUMN13
	, COLUMN14
	, COLUMN15
	, COLUMN16
	, COLUMN17
	, COLUMN18
	, COLUMN19
	, COLUMN20
	, COLUMN21
	, COLUMN22
	, COLUMN23
	, COLUMN24
	, COLUMN25
	, COLUMN26
	, COLUMN27
	, COLUMN28
	, COLUMN29
	, COLUMN30
	, COLUMN31
	, COLUMN32
	, COLUMN33
)  as SELECT
	pah.project_id
	, pah.resource_list_member_id
	, rlm1.parent_member_id
	, rlm1.member_level
	, rlm1.sort_order
	, pah.task_id
	, pah.resource_list_id
	, pah.resource_list_assignment_id
	, decode(pah.task_id, 0, ''Y'',''N'')
        , decode(pa_get_resource.child_resource_exists(pah.resource_list_member_id,
          pah.task_id,pah.project_id),''Y'',''+'',''N'','' '')';



from_clause := 'pa_status_proj_accum_headers_v pah,pa_resource_list_members rlm1';


where_clause :='pah.project_id = PA_STATUS.GetProjId AND pah.resource_list_id = PA_STATUS.GetRsrcListId AND pah.task_id = PA_STATUS.GetTaskId AND pah.resource_list_member_id = rlm1.resource_list_member_id';

	IF (PA_DDC_API.Check_Alias('RES.','R') = 'Y') THEN

		from_clause := from_clause||',pa_resources res';

		where_clause := where_clause||' AND rlm1.resource_id = res.resource_id';

	END IF;


	IF (PA_DDC_API.Check_Alias('A.','R') = 'Y') THEN

		from_clause := from_clause||',pa_status_rsrc_act_high_v	a';

		where_clause := where_clause||' AND pah.resource_list_member_id = a.resource_list_member_id (+)';

	END IF;


	IF (PA_DDC_API.Check_Alias('M.','R') = 'Y') THEN

		from_clause := from_clause||',pa_status_rsrc_cmt_high_v m';

		where_clause := where_clause||' AND pah.resource_list_member_id = m.resource_list_member_id (+)';

	END IF;


	IF (PA_DDC_API.Check_Alias('C.','R') = 'Y') THEN

		from_clause := from_clause||',pa_status_rsrc_bgt_cost_high_v c';

		where_clause := where_clause||' AND pah.resource_list_member_id = c.resource_list_member_id (+)';

	END IF;


	IF (PA_DDC_API.Check_Alias('R.','R') = 'Y') THEN

		from_clause := from_clause||',pa_status_rsrc_bgt_rev_high_v r';

		where_clause := where_clause||' AND pah.resource_list_member_id = r.resource_list_member_id (+)';

	END IF;


	FOR r1rec IN r1 LOOP

		IF (r1rec.format_code = 'C') THEN

			IF (r1rec.column_name IS NULL) THEN
				stmt := stmt||',null';
			ELSE
				stmt := stmt||','||r1rec.column_name;
			END IF;
		ELSE
			IF (r1rec.column_name IS NULL) THEN
				stmt := stmt||',0';
			ELSE
			  IF (r1rec.currency_format_flag IS NULL) THEN
				stmt := stmt||','||r1rec.column_name;
			  ELSE
			      	stmt :=  stmt||',('||r1rec.column_name||')/(PA_STATUS.Get_factor)';
			  END IF;
		              END IF;
		END IF;

	END LOOP;

END IF;


   ddl_stmt := ddl_stmt||stmt;
   ddl_stmt := ddl_stmt||' FROM '||from_clause;
   ddl_stmt := ddl_stmt||' WHERE '||where_clause;

cid := dbms_sql.open_cursor;

dbms_sql.parse(cid,ddl_stmt,dbms_sql.v7);

END create_psi_generic_views;


END PA_DDC_API;

/
