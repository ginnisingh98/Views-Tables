--------------------------------------------------------
--  DDL for Package Body PA_RBS_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_MAPPING" AS
/* $Header: PARBSMPB.pls 120.24.12010000.6 2010/02/11 06:31:00 dbudhwar ship $ */

-------------------------------------------------
--global variables
-------------------------------------------------
g_user_id NUMBER := fnd_global.user_id;
g_login_id NUMBER := fnd_global.login_id;
g_debug_mode  VARCHAR2(10) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
g_module_name    VARCHAR2(100) := 'PA_RBS_MAPPING';

-- added for bug#3995697
g_rule_id NUMBER := NULL;
g_max_level NUMBER := NULL;
g_res_type_cols PA_PLSQL_DATATYPES.Char30TabTyp ;
g_res_type_cols_flag VARCHAR2 (1) := NULL;
g_rbs_element_id NUMBER := NULL;
g_rule_type	VARCHAR2 (1) := NULL;

---------------------------------------------------------------------------------
-- g_denorm_refresh is used to conditionally populate RBS denorm tables only when
-- a new RBS element is created
--------------------------------------------------------------------------------
g_denorm_refresh VARCHAR2(1) := 'N';
-----------------------------------

FUNCTION 	auto_allocate_unique
		(
		p_lock_name VARCHAR2
		) RETURN VARCHAR2
IS
		PRAGMA autonomous_transaction;
		lockhndl varchar2(128);
BEGIN
		dbms_lock.allocate_unique(p_lock_name,lockhndl,864000);
		commit;
		RETURN lockhndl;
END;

--------------------------------------------------
--Gets the sorted rules from pa_rbs_mapping_rules
--given rbs structure version and resource class
--------------------------------------------------
FUNCTION	get_sorted_rules
		(
		p_struct_version_id	NUMBER,
		p_res_class_id		NUMBER  --1,2,3,4
		) RETURN SYSTEM.pa_num_tbl_type
IS
		l_sorted_rules		SYSTEM.pa_num_tbl_type;
                l_precedence            PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'get_sorted_rules'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside get_sorted_rules . - p_struct_version_id : ' ||p_struct_version_id || '  - p_res_class_id: ' || p_res_class_id ;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;
               SELECT decode(p_res_class_id,1,PERSON_RC_PRECEDENCE,
                                             2,EQUIPMENT_RC_PRECEDENCE,
                                             3,MATERIAL_RC_PRECEDENCE,
                                             4,FIN_ELEM_RC_PRECEDENCE),
                        rule_id
                BULK COLLECT INTO
                        l_precedence,
                        l_sorted_rules
                FROM pa_rbs_mapping_rules
                WHERE element_version_id = p_struct_version_id
                ORDER BY
		max_level desc ,
		1 ,
		decode(level15,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level15,3,3),p_res_class_id)), --bug#3940722
		decode(level14,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level14,3,3),p_res_class_id)),
		decode(level13,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level13,3,3),p_res_class_id)),
		decode(level12,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level12,3,3),p_res_class_id)),
		decode(level11,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level11,3,3),p_res_class_id)),
		decode(level10,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level10,3,3),p_res_class_id)),
		decode(level9,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level9,3,3),p_res_class_id)),
		decode(level8,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level8,3,3),p_res_class_id)),
		decode(level7,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level7,3,3),p_res_class_id)),
		decode(level6,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level6,3,3),p_res_class_id)),
		decode(level5,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level5,3,3),p_res_class_id)),
		decode(level4,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level4,3,3),p_res_class_id)),
		decode(level3,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level3,3,3),p_res_class_id)),
		decode(level2,null,1,PA_RBS_PREC_PUB.calc_rule_precedence(substr(level2,3,3),p_res_class_id)),
		decode(substr(level15,1,1),'I',2,'R',1,0) desc, --bug#3908041
		decode(substr(level14,1,1),'I',2,'R',1,0) desc,
		decode(substr(level13,1,1),'I',2,'R',1,0) desc,
		decode(substr(level12,1,1),'I',2,'R',1,0) desc,
		decode(substr(level11,1,1),'I',2,'R',1,0) desc,
		decode(substr(level10,1,1),'I',2,'R',1,0) desc,
		decode(substr(level9,1,1),'I',2,'R',1,0) desc,
		decode(substr(level8,1,1),'I',2,'R',1,0) desc,
		decode(substr(level7,1,1),'I',2,'R',1,0) desc,
		decode(substr(level6,1,1),'I',2,'R',1,0) desc,
		decode(substr(level5,1,1),'I',2,'R',1,0) desc,
		decode(substr(level4,1,1),'I',2,'R',1,0) desc,
		decode(substr(level3,1,1),'I',2,'R',1,0) desc,
		decode(substr(level2,1,1),'I',2,'R',1,0) desc;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting get_sorted_rules' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;
		RETURN l_sorted_rules ;
END ;


----------------------------------------
--Get the resource type id column name
--for the resource type token
----------------------------------------
FUNCTION	get_resource_type_cols
		(
		p_resource_type_token	VARCHAR2
		) RETURN VARCHAR2
IS
BEGIN

		IF    p_resource_type_token = 'BML' THEN
		RETURN  'bom_labor_id';
		ELSIF p_resource_type_token = 'BME' THEN
		RETURN  'bom_equipment_id';
		ELSIF p_resource_type_token = 'PER' THEN
		RETURN  'person_id';
		ELSIF p_resource_type_token = 'EVT' THEN
		RETURN  'event_type_id';
		ELSIF p_resource_type_token = 'EXC' THEN
		RETURN  'expenditure_category_id';
		ELSIF p_resource_type_token = 'EXT' THEN
		RETURN  'expenditure_type_id';
		ELSIF p_resource_type_token = 'ITC' THEN
		RETURN  'item_category_id';
		ELSIF p_resource_type_token = 'ITM' THEN
		RETURN  'inventory_item_id';
		ELSIF p_resource_type_token = 'JOB' THEN
		RETURN  'job_id';
		ELSIF p_resource_type_token = 'ORG' THEN
		RETURN  'organization_id';
		ELSIF p_resource_type_token = 'PTP' THEN
		RETURN  'person_type_id';
		ELSIF p_resource_type_token = 'NLR' THEN
		RETURN  'non_labor_resource_id';
		ELSIF p_resource_type_token = 'RES' THEN
		RETURN  'resource_class_id';
		ELSIF p_resource_type_token = 'RVC' THEN
		RETURN  'revenue_category_id';
		ELSIF p_resource_type_token = 'ROL' THEN
		RETURN  'role_id';
		ELSIF p_resource_type_token = 'SUP' THEN
		RETURN  'supplier_id';

	--	added for custom nodes
	--	bug#3810558 changed CUS1 to CU1 etc

		ELSIF p_resource_type_token = 'CU1' THEN
		RETURN  'USER_DEFINED_CUSTOM1_ID';
		ELSIF p_resource_type_token = 'CU2' THEN
		RETURN  'USER_DEFINED_CUSTOM2_ID';
		ELSIF p_resource_type_token = 'CU3' THEN
		RETURN  'USER_DEFINED_CUSTOM3_ID';
		ELSIF p_resource_type_token = 'CU4' THEN
		RETURN  'USER_DEFINED_CUSTOM4_ID';
		ELSIF p_resource_type_token = 'CU5' THEN
		RETURN  'USER_DEFINED_CUSTOM5_ID';

		END IF;


END ;

----------------------------------------
--Get the resource type id for
--the resource type token
----------------------------------------
FUNCTION	get_res_type_id
		(
		p_resource_type_token	VARCHAR2
		) RETURN NUMBER
IS
BEGIN

		IF    p_resource_type_token = 'bom_labor_id' THEN
		RETURN  1;
		ELSIF p_resource_type_token = 'bom_equipment_id' THEN
		RETURN  2;
		ELSIF p_resource_type_token = 'person_id' THEN
		RETURN  3;
		ELSIF p_resource_type_token = 'event_type_id' THEN
		RETURN  4;
		ELSIF p_resource_type_token = 'expenditure_category_id' THEN
		RETURN  5;
		ELSIF p_resource_type_token = 'expenditure_type_id' THEN
		RETURN  6;
		ELSIF p_resource_type_token = 'item_category_id' THEN
		RETURN  7;
		ELSIF p_resource_type_token = 'inventory_item_id' THEN
		RETURN  8;
		ELSIF p_resource_type_token = 'job_id' THEN
		RETURN  9;
		ELSIF p_resource_type_token = 'organization_id' THEN
		RETURN  10;
		ELSIF p_resource_type_token = 'person_type_id' THEN
		RETURN  11;
		ELSIF p_resource_type_token = 'non_labor_resource_id' THEN
		RETURN  12;
		ELSIF p_resource_type_token = 'resource_class_id' THEN
		RETURN  13;
		ELSIF p_resource_type_token = 'revenue_category_id' THEN
		RETURN  14;
		ELSIF p_resource_type_token = 'role_id' THEN
		RETURN  15;
		ELSIF p_resource_type_token = 'supplier_id' THEN
		RETURN  16;

	--	added for custom nodes
		ELSIF p_resource_type_token = 'USER_DEFINED_CUSTOM1_ID' THEN
		RETURN  18;
		ELSIF p_resource_type_token = 'USER_DEFINED_CUSTOM2_ID' THEN
		RETURN  18;
		ELSIF p_resource_type_token = 'USER_DEFINED_CUSTOM3_ID' THEN
		RETURN  18;
		ELSIF p_resource_type_token = 'USER_DEFINED_CUSTOM4_ID' THEN
		RETURN  18;
		ELSIF p_resource_type_token = 'USER_DEFINED_CUSTOM5_ID' THEN
		RETURN  18;

		END IF;


END ;

-------------------------------------------------------------------
-- Get the Level from the pa_rbs_mapping_rules for the Rule Id
-------------------------------------------------------------------

--modified function below for bug#4478902

FUNCTION	get_level
		(
		p_rule_id		NUMBER,
		p_level			NUMBER
		)
		RETURN VARCHAR2
IS

		l_value		VARCHAR2(30);


BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'get_level'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside get_level : - p_rule_id: ' || p_rule_id || ' - p_level :' || p_level ;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		CASE p_level
		      WHEN 1 THEN
			Select Level1 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 2 THEN
			Select Level2 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 3 THEN
			Select Level3 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 4 THEN
			Select Level4 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 5 THEN
			Select Level5 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 6 THEN
			Select Level6 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 7 THEN
			Select Level7 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 8 THEN
			Select Level8 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 9 THEN
			Select Level9 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 10 THEN
			Select Level10 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 11 THEN
			Select Level11 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 12 THEN
			Select Level12 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 13 THEN
			Select Level13 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 14 THEN
			Select Level14 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      WHEN 15 THEN
			Select Level15 into l_value from pa_rbs_mapping_rules where rule_id=p_rule_id;
		      ELSE
			l_value:=NULL;
		 END CASE;


		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting get_level - l_level :' || l_value ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;
		RETURN l_value;
END;

------------------------------------------------------
--map the transactions
------------------------------------------------------

PROCEDURE	delete_tmp_tables
		(
		p_max_level			IN NUMBER
		)
IS

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'Delete Tmp Tables'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside Delete Tmp Tables - p_max_level : '|| p_max_level;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		FOR l IN 3..p_max_level+3 LOOP
			CASE l
			      WHEN 1 THEN
				DELETE pa_rbs_map_tmp1;
			      WHEN 2 THEN
				DELETE pa_rbs_map_tmp2;
			      WHEN 3 THEN
				DELETE pa_rbs_map_tmp3;
			      WHEN 4 THEN
				DELETE pa_rbs_map_tmp4;
			      WHEN 5 THEN
				DELETE pa_rbs_map_tmp5;
			      WHEN 6 THEN
				DELETE pa_rbs_map_tmp6;
			      WHEN 7 THEN
				DELETE pa_rbs_map_tmp7;
			      WHEN 8 THEN
				DELETE pa_rbs_map_tmp8;
			      WHEN 9 THEN
				DELETE pa_rbs_map_tmp9;
			      WHEN 10 THEN
				DELETE pa_rbs_map_tmp10;
			      WHEN 11 THEN
				DELETE pa_rbs_map_tmp11;
			      WHEN 12 THEN
				DELETE pa_rbs_map_tmp12;
			      WHEN 13 THEN
				DELETE pa_rbs_map_tmp13;
			      ELSE
				NULL;
			 END CASE;
                     END LOOP;



		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting Delete Tmp Tables' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;
END;

---------------------------------------------
-- Get the list of resource type columns for
-- a rule
---------------------------------------------
FUNCTION	get_res_type_cols
		(
		p_rule_id	NUMBER
		)
		RETURN PA_PLSQL_DATATYPES.Char30TabTyp
IS

--bug#3995697	l_max_level	NUMBER;
		l_token		VARCHAR2(30);
		l_res_type_cols PA_PLSQL_DATATYPES.Char30TabTyp;
		j		NUMBER;

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'get_res_type_cols'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside get_res_type_cols';
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;


		j := 1;
		FOR i IN 2..g_max_level LOOP
			l_token:= get_level(p_rule_id,i);
			--EXECUTE IMMEDIATE 'SELECT LEVEL' || i || ' FROM pa_rbs_mapping_rules WHERE rule_id = ' || p_rule_id INTO l_token ;
			--commented if and endif for custom nodes
			--IF substr(l_token,1,1) =  'R' OR substr(l_token,1,1) =  'I' THEN   -- condition should be false for custom based node
			l_res_type_cols(j) := get_resource_type_cols(substr(l_token,3,3));	--bug#3759977
			j := j+1;
			--END IF;

		END LOOP;
		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting get_res_type_cols' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;
		RETURN l_res_type_cols ;
END ;

---------------------------------------------
-- Get the list of resource type columns along
-- with values for nodes of a rule which
-- contain value
---------------------------------------------

--modified function below for bug#3759977

FUNCTION	get_res_type_cols_inst
		(
		p_rule_id	NUMBER,
		p_level		NUMBER
		) RETURN PA_PLSQL_DATATYPES.Char60TabTyp
IS
		l_token		VARCHAR2(30);
		l_res_type_cols	PA_PLSQL_DATATYPES.Char60TabTyp;
		j		NUMBER;

		l_prev_token	VARCHAR2(30);

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'get_res_type_cols_inst'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside get_res_type_cols_inst';
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		j := 1 ;
		l_prev_token := 'NULL' ;
		FOR i IN REVERSE 2..p_level LOOP
			l_token:= get_level(p_rule_id,i);

			--EXECUTE IMMEDIATE 'SELECT LEVEL' || i || ' FROM pa_rbs_mapping_rules WHERE rule_id = ' || p_rule_id INTO l_token ;
			IF substr(l_token,0,1) = 'I' AND substr(l_token,3,3) <> l_prev_token THEN
			l_res_type_cols(j) := ' TMP.' || get_resource_type_cols(substr(l_token,3,3));
			l_res_type_cols(j) := l_res_type_cols(j) || ' = ' || substr(l_token,7);
			j := j+1 ;
			l_prev_token := substr(l_token,3,3) ;
			END IF;
		END LOOP;


		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting get_res_type_cols_inst' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		RETURN l_res_type_cols ;
END;

---------------------------------------------
-- function added for same resource type
-- below function would return the col name
-- as it is for rule based nodes and value followed
-- col name for instance based nodes. the sql clause
-- would like below in case of operation type NONE
--(job is rule, org is instance) .
-- l_sql_clause := job_id, 243 organization_id
-- in case of operation type EQUAL
-- l_sql_clause := RBS.job_id = TMP.job_id and
-- RBS.organization_id = 243
---------------------------------------------
FUNCTION	get_sql_clause_unmap
		(
		p_rule_id	NUMBER,
		p_level		NUMBER,
		p_operation_type	VARCHAR2
		) RETURN VARCHAR2
IS
		l_token		VARCHAR2(30);
		l_res_type_cols	PA_PLSQL_DATATYPES.Char60TabTyp;

		l_res_type_cols2	PA_PLSQL_DATATYPES.Char240TabTyp;
		j		NUMBER;

		l_prev_token	VARCHAR2(30);
		l_sql_clause	VARCHAR2 (1000);

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'get_sql_clause_unmap'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside get_sql_clause_unmap - p_operation_type :'|| p_operation_type;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		j := 1 ;
		l_prev_token := 'NULL' ;
		FOR i IN REVERSE 2..p_level LOOP
			l_token:= get_level(p_rule_id,i);
			--EXECUTE IMMEDIATE 'SELECT LEVEL' || i || ' FROM pa_rbs_mapping_rules WHERE rule_id = ' || p_rule_id INTO l_token ;
			IF substr(l_token,0,1) <> 'I' THEN
				l_res_type_cols(j) := get_resource_type_cols(substr(l_token,3,3));
				l_res_type_cols2(j) := 'RBS.' || get_resource_type_cols(substr(l_token,3,3)) || ' (+) = TMP.' || get_resource_type_cols(substr(l_token,3,3));
				j := j+1 ;
			ELSIF substr(l_token,0,1) = 'I' AND substr(l_token,3,3) <> l_prev_token THEN
				l_res_type_cols(j) := substr(l_token,7) || '  ' || get_resource_type_cols(substr(l_token,3,3));
				l_res_type_cols2(j) := 'RBS.' || get_resource_type_cols(substr(l_token,3,3)) || ' (+) =  ' || substr(l_token,7) ;
				j := j+1 ;
				l_prev_token := substr(l_token,3,3) ;
			END IF;
		END LOOP;

		l_sql_clause := ' ';
		IF p_operation_type = 'NONE' THEN
			FOR i IN 1..l_res_type_cols.COUNT LOOP
				IF i=1 THEN
					l_sql_clause := l_sql_clause || l_res_type_cols(i) ;
				ELSE
					l_sql_clause := l_sql_clause || ',' || l_res_type_cols(i);
				END IF;
			END LOOP;
		END IF;

		IF p_operation_type = 'EQUAL' THEN
			FOR i IN 1..l_res_type_cols2.COUNT LOOP
				IF i=1 THEN
					l_sql_clause := l_sql_clause || l_res_type_cols2(i) ;
				ELSE
					l_sql_clause := l_sql_clause || ' AND ' || l_res_type_cols2(i);
				END IF;
			END LOOP;
		END IF;

		IF p_level = 1 AND p_operation_type = 'EQUAL'  THEN
			l_sql_clause := ' 1 = 1 ' ;
		END IF;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting get_sql_clause_unmap - l_sql_clause : ' || l_sql_clause;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		RETURN l_sql_clause ;
END;


---------------------------------------------
-- function added for same resource type
-- below function would return only rule based col name
---------------------------------------------
FUNCTION	get_sql_clause_rule
		(
		p_rule_id	NUMBER,
		p_level		NUMBER,
		p_operation_type	VARCHAR2
		) RETURN VARCHAR2
IS
		l_token		VARCHAR2(30);
		l_res_type_cols	PA_PLSQL_DATATYPES.Char60TabTyp;
		j		NUMBER;

		l_sql_clause	VARCHAR2 (1000);

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'get_sql_clause_rule'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside get_sql_clause_rule - p_operation_type :'|| p_operation_type;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		j := 1 ;
		FOR i IN REVERSE 2..p_level LOOP
			l_token:= get_level(p_rule_id,i);

			--EXECUTE IMMEDIATE 'SELECT LEVEL' || i || ' FROM pa_rbs_mapping_rules WHERE rule_id = ' || p_rule_id INTO l_token ;
			IF substr(l_token,0,1) <> 'I' THEN
				l_res_type_cols(j) := get_resource_type_cols(substr(l_token,3,3));
				j := j+1 ;
			END IF;
		END LOOP;

		l_sql_clause := '';
		IF p_operation_type = 'EQUAL2' THEN
			FOR i IN 1..l_res_type_cols.COUNT LOOP
				IF i=1 THEN
					l_sql_clause := l_sql_clause || 'TMP.' || l_res_type_cols(i) || ' = TMP1.' || l_res_type_cols(i) || '(+)' ;
				ELSE
					l_sql_clause := l_sql_clause || ' AND TMP.' || l_res_type_cols(i) || ' = TMP1.' || l_res_type_cols(i) || '(+)' ;
				END IF;
			END LOOP;
		END IF;

		IF l_sql_clause IS NULL THEN
			l_sql_clause := ' 1=1 ';
		END IF;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting get_sql_clause_rule- l_sql_clause : ' || l_sql_clause;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		RETURN l_sql_clause ;
END;

-------------------------------------------------------------------
--Generate the SQL clause
--Operation types allowed - NONE,TMP,EQUAL(RBS=TMP),EQUAL2(TMP=TMP1),
--RES_SOURCE (it would return resource source column name),
--RES_TYP_ID (it would return resource type id )
-------------------------------------------------------------------

--modified function below for bug#3759977

FUNCTION	get_sql_clause
		(
		p_rule_id	NUMBER,
		p_level		NUMBER,
		p_operation_type	VARCHAR2
		) RETURN VARCHAR2
IS
		l_res_type_cols PA_PLSQL_DATATYPES.Char30TabTyp;
		l_sql_clause	VARCHAR2 (500);

		l_curr_res_col	VARCHAR2 (240);
		l_prev_res_col	VARCHAR2 (240);

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'get_sql_clause'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside get_sql_clause - p_operation_type:'|| p_operation_type;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		-- implement caching, bug#3995697
		IF p_rule_id = g_rule_id AND g_res_type_cols_flag IS NOT NULL THEN
			l_res_type_cols := g_res_type_cols ;
		ELSE
			l_res_type_cols := get_res_type_cols(p_rule_id);

			g_rule_id := p_rule_id;
			g_res_type_cols := l_res_type_cols;
			g_res_type_cols_flag  := 'Y' ;
		END IF ;

		l_sql_clause := ' ';
		IF p_level > 1 THEN
		IF p_operation_type = 'NONE' THEN
			FOR i IN 1..(p_level-1) LOOP
				IF i=1 THEN
					l_sql_clause := l_sql_clause || l_res_type_cols(i) ;
					l_prev_res_col := l_res_type_cols(i);
				ELSE
					l_curr_res_col := l_res_type_cols(i) ;
					IF l_curr_res_col <> l_prev_res_col THEN
						l_sql_clause := l_sql_clause || ',' || l_res_type_cols(i);
					END IF;
					l_prev_res_col := l_res_type_cols(i) ;
				END IF;
			END LOOP;
		ELSIF  p_operation_type = 'TMP' THEN
			FOR i IN 1..(p_level-1) LOOP
				IF i=1 THEN
					l_sql_clause := l_sql_clause || 'TMP.' || l_res_type_cols(i) ;
					l_prev_res_col := l_res_type_cols(i);
				ELSE
					l_curr_res_col := l_res_type_cols(i) ;
					IF l_curr_res_col <> l_prev_res_col THEN
						l_sql_clause := l_sql_clause || ',' || 'TMP.' || l_res_type_cols(i);
					END IF;
					l_prev_res_col := l_res_type_cols(i) ;
				END IF;
			END LOOP;
		ELSIF  p_operation_type = 'EQUAL' THEN
			FOR i IN 1..(p_level-1) LOOP
				IF i=1 THEN
					l_sql_clause := l_sql_clause || 'TMP.' || l_res_type_cols(i) || ' = RBS.' || l_res_type_cols(i) || '(+)' ;
					l_prev_res_col := l_res_type_cols(i);
				ELSE
					l_curr_res_col := l_res_type_cols(i) ;
					IF l_curr_res_col <> l_prev_res_col THEN
						l_sql_clause := l_sql_clause || ' AND TMP.' || l_res_type_cols(i) || ' = RBS.' || l_res_type_cols(i) || '(+) ' ;
					END IF;
					l_prev_res_col := l_res_type_cols(i) ;
				END IF;
			END LOOP;
		ELSIF  p_operation_type = 'EQUAL2' THEN
			FOR i IN 1..(p_level-1) LOOP
				IF i=1 THEN
					l_sql_clause := l_sql_clause || 'TMP.' || l_res_type_cols(i) || ' = TMP1.' || l_res_type_cols(i) || '(+)' ;
					l_prev_res_col := l_res_type_cols(i);
				ELSE
					l_curr_res_col := l_res_type_cols(i) ;
					IF l_curr_res_col <> l_prev_res_col THEN
						l_sql_clause := l_sql_clause || ' AND TMP.' || l_res_type_cols(i) || ' = TMP1.' || l_res_type_cols(i) || '(+) ' ;
					END IF;
					l_prev_res_col := l_res_type_cols(i) ;
				END IF;
			END LOOP;
		ELSIF  p_operation_type = 'NOTNULL' THEN
			FOR i IN 1..(p_level-1) LOOP
				IF i=1 THEN
					l_sql_clause := l_sql_clause || 'TMP.' || l_res_type_cols(i) || ' IS NOT NULL' ;
					l_prev_res_col := l_res_type_cols(i);
				ELSE
					l_curr_res_col := l_res_type_cols(i) ;
					IF l_curr_res_col <> l_prev_res_col THEN
						l_sql_clause := l_sql_clause || ' AND TMP.' || l_res_type_cols(i) || ' IS NOT NULL' ;
					END IF;
					l_prev_res_col := l_res_type_cols(i) ;
				END IF;
			END LOOP;
		ELSIF  p_operation_type = 'RES_SOURCE' THEN
				l_sql_clause := 'TMP.' || l_res_type_cols(p_level-1);
		ELSIF  p_operation_type = 'RES_TYP_ID' THEN
				l_sql_clause := get_res_type_id(l_res_type_cols(p_level-1));
		END IF;
		END IF;

		IF p_level = 1 AND ( p_operation_type = 'EQUAL' OR p_operation_type = 'EQUAL2') THEN
			l_sql_clause := ' 1 = 1 ' ;
		END IF;
		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting get_sql_clause - l_sql_clause' || l_sql_clause;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;
		RETURN l_sql_clause;
END;



-------------------------------------------------------------------
-- Generate the SQL clause for Instance for nodes of a rule which
-- contain value
-------------------------------------------------------------------

--modified function below for bug#3759977

FUNCTION	get_sql_clause_inst
		(
		p_struct_version_id	NUMBER,
		p_rule_id		NUMBER,
		p_level			NUMBER
		)
		RETURN VARCHAR2
IS

		l_res_type_cols	PA_PLSQL_DATATYPES.Char60TabTyp;
		l_sql_clause	VARCHAR2 (500);
		l_value		NUMBER;
		l_sql_stmt	VARCHAR2 (500);
		l_rbs_element_id	NUMBER;

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'get_sql_clause_inst'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside get_sql_clause_inst- p_struct_version_id :'|| p_struct_version_id || ' p_level: ' || p_level;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		l_res_type_cols := get_res_type_cols_inst(p_rule_id, p_level);
		l_sql_clause := '';

		FOR i IN 1..l_res_type_cols.COUNT LOOP
			/*
			select rbs_element_id
			into l_rbs_element_id
			from pa_rbs_mapping_rules
			where rule_id = p_rule_id ;

			--bug#3642329
			l_sql_stmt := ' SELECT ' || l_res_type_cols(i) ||
					' FROM pa_rbs_elements ' ||
					' WHERE rbs_version_id = ' || p_struct_version_id ||
					' AND user_created_flag = ' || '''Y''' ||
					' AND rbs_element_id = ' || l_rbs_element_id ;

			EXECUTE IMMEDIATE l_sql_stmt INTO l_value ;

			*/

			IF i = l_res_type_cols.COUNT THEN
				l_sql_clause := l_sql_clause || l_res_type_cols(i) ;
			ELSE
				l_sql_clause := l_sql_clause || l_res_type_cols(i) || ' AND ' ;
			END IF;
		END LOOP;


		IF p_level = 1 or l_sql_clause is null THEN  --bug#3749017
			l_sql_clause := ' 1 = 1 ' ;
		END IF;
		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting get_sql_clause_inst  - l_sql_clause' || l_sql_clause;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;
		RETURN l_sql_clause;
END;



----------------------------------------
--Get the RBS element id for the rule
----------------------------------------

--added function for bug#3974663

FUNCTION	get_rbs_element_id
		(
		p_rule_id		NUMBER,
		p_level			NUMBER
		)
		RETURN NUMBER
IS
--bug#3995697	l_rbs_element_id	NUMBER;
		l_parent_element_id	NUMBER;
BEGIN

		SELECT rbs_element_id
		INTO l_parent_element_id
		FROM pa_rbs_elements
		WHERE rbs_level = p_level
		CONNECT BY rbs_element_id = PRIOR parent_element_id
		START WITH rbs_element_id = g_rbs_element_id ;

		RETURN l_parent_element_id;

END ;


------------------------------------------------------
--map the transactions
------------------------------------------------------

PROCEDURE	mapped_header
		(
		p_rule_id		IN NUMBER,
		p_struct_version_id	IN NUMBER,
		p_level			IN NUMBER,
		p_res_class_id		IN NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_msg_count		OUT NOCOPY NUMBER,
		x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_SQL_statement		VARCHAR2 (2000);
		l_INSERT_clause		VARCHAR2 (500);
		l_SELECT_clause		VARCHAR2 (500);
		l_FROM_clause		VARCHAR2 (500);
		l_WHERE_clause		VARCHAR2 (1000);
--bug#3995697	l_rule_type		VARCHAR2 (1);

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'mapped_header'
					     ,p_debug_mode => g_debug_mode );
  		  pa_debug.g_err_stage:= 'Inside mapped_header- p_struct_version_id :'|| p_struct_version_id || ' p_level: ' || p_level || ' p_res_class_id:'||p_res_class_id||'  p_rule_id:'||p_rule_id;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;


		x_return_status := 0;

		--delete pa_rbs_map_tmp3;
		l_INSERT_clause := 'INSERT INTO pa_rbs_map_tmp3('
				|| 'txn_accum_header_id,'
				|| 'struct_version_id,'
				|| 'element_version_id,'
				|| 'parent_element_version_id,'
				|| 'resource_type_id,'
				|| 'resource_source_id,'
				|| get_sql_clause(p_rule_id,p_level,'NONE')
				|| ')' ;

		l_SELECT_clause := 'SELECT '
				|| 'TMP.txn_accum_header_id,'
				|| ':p_struct_version_id,'
				|| 'RBS.rbs_element_id,'
				|| 'RBS.parent_element_id,'
				|| get_sql_clause(p_rule_id,p_level,'RES_TYP_ID') || ' ,'
				|| get_sql_clause(p_rule_id,p_level,'RES_SOURCE') || ' ,'
				|| get_sql_clause(p_rule_id,p_level,'TMP') ;

		l_FROM_clause  := 'FROM pa_rbs_map_tmp2 TMP,'
				|| 'pa_rbs_elements RBS ' ;



		IF g_rule_type = 'N'  THEN

		l_WHERE_clause := ' WHERE '  ||
				get_sql_clause(p_rule_id,p_level,'EQUAL') || ' AND '  ||
				get_sql_clause_inst(p_struct_version_id, p_rule_id,p_level) || ' AND '  ||  -- added for instance based only
				get_sql_clause(p_rule_id,p_level,'NOTNULL')|| ' AND '  ||
				' RBS.rbs_version_id(+) = TMP.struct_version_id  AND ' ||
				' RBS.user_created_flag (+)= ' || '''' || 'N' || '''' || ' AND ' ||
				' RBS.rbs_level(+) = :p_level AND ' ||
				' TMP.resource_class_id = :p_res_class_id AND ' ||
				' TMP.txn_accum_header_id NOT IN ' ||
				' (SELECT txn_accum_header_id ' ||
				' FROM  pa_rbs_txn_accum_map ' ||
				' WHERE struct_version_id = :p_struct_version_id)' ;

		ELSE

		l_WHERE_clause :=  ' WHERE '  ||
				get_sql_clause(p_rule_id,p_level,'EQUAL') || ' AND '  ||
				get_sql_clause(p_rule_id,p_level,'NOTNULL')|| ' AND '  ||
				' RBS.rbs_version_id (+)= TMP.struct_version_id  AND ' ||
				' RBS.user_created_flag (+)= ' || '''' || 'N' || '''' || ' AND ' ||
				' RBS.rbs_level(+) = :p_level AND ' ||
				' TMP.resource_class_id = :p_res_class_id AND ' ||
				' TMP.txn_accum_header_id NOT IN ' ||
				' (SELECT txn_accum_header_id ' ||
				' FROM  pa_rbs_txn_accum_map ' ||
				' WHERE struct_version_id = :p_struct_version_id)' ;

		END IF;

		l_SQL_statement := l_INSERT_clause || ' ' ||
				l_SELECT_clause || ' ' ||
				l_FROM_clause || ' ' ||
				l_WHERE_clause  ;


		EXECUTE IMMEDIATE l_SQL_statement USING p_struct_version_id, p_level, p_res_class_id,p_struct_version_id;


		IF SQL%ROWCOUNT = 0 THEN
			x_return_status := 1;
		END IF;


		IF g_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'Exiting mapped_header- Inserts in pa_rbs_map_tmp :'||SQL%ROWCOUNT ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;
END;

--------------------------------------------------------
--insert unmapped transactions into the temporary table
--------------------------------------------------------

PROCEDURE	unmapped_header
		(
		p_rule_id		IN NUMBER,
		p_struct_version_id	IN NUMBER,
		p_counter		IN NUMBER,
		p_level			IN NUMBER
		--x_return_status	OUT NOCOPY VARCHAR2,
		--x_msg_count		OUT NOCOPY NUMBER,
		--x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_SQL_statement		VARCHAR2 (2000);
		l_INSERT_clause		VARCHAR2 (500);
		l_SELECT_clause		VARCHAR2 (500);
		l_FROM_clause		VARCHAR2 (500);
		l_WHERE_clause		VARCHAR2 (500);
		l_tmp			NUMBER ;
--bug#3995697	l_rule_type		VARCHAR2 (1);

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'unmapped_header'
					     ,p_debug_mode => g_debug_mode );
  		  pa_debug.g_err_stage:= 'Inside unmapped_header- p_struct_version_id :'|| p_struct_version_id || ' p_level: ' || p_level || ' p_counter:'||p_counter;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		l_tmp := 3 + p_counter ;

		--EXECUTE IMMEDIATE 'DELETE pa_rbs_map_tmp' || l_tmp;

		l_INSERT_clause := 'INSERT INTO pa_rbs_map_tmp' || l_tmp || ' ('
				|| 'struct_version_id, '
				|| 'parent_element_version_id,'
				|| 'resource_type_id,'
				|| 'resource_source_id,'
				|| 'sequence,'
				|| get_sql_clause(p_rule_id,p_level,'NONE')
				|| ')' ;

		l_SELECT_clause := 'SELECT '
				|| ':p_struct_version_id,'
				|| 'RBS.rbs_element_id,'
				|| get_sql_clause(p_rule_id,p_level,'RES_TYP_ID') || ' ,'
				|| get_sql_clause(p_rule_id,p_level,'RES_SOURCE') || ' ,'
				|| 'pa_rbs_elements_s.nextval,'
				|| get_sql_clause(p_rule_id,p_level,'TMP') ;
		l_tmp := 2 + p_counter ;

		l_FROM_clause  := ' FROM ( SELECT DISTINCT struct_version_id, '
				|| get_sql_clause_unmap(p_rule_id,p_level ,'NONE')  --bug#3749017
				|| ' FROM pa_rbs_map_tmp' || l_tmp
				|| ' WHERE parent_element_version_id IS NULL '
				|| ' ) TMP,'
				|| 'pa_rbs_elements RBS ' ;


		IF g_rule_type = 'Y'  THEN

		l_tmp := p_level - 1;
		l_WHERE_clause := ' WHERE ' ||
				get_sql_clause(p_rule_id,p_level-1,'EQUAL') ||
				' AND RBS.rbs_version_id(+) =  TMP.struct_version_id ' ||
				' AND RBS.user_created_flag (+)= ' || '''' || 'N' || ''''  ||
				' AND RBS.rbs_level(+) = :l_tmp';

		ELSE

		l_tmp := p_level - 1;
		l_WHERE_clause := ' WHERE ' ||
				get_sql_clause_unmap(p_rule_id,p_level-1,'EQUAL') ||    --bug#3749017
				--' AND ' ||						--bug#3749017
				--get_sql_clause_inst(p_struct_version_id, p_rule_id,p_level-1) || /* added for instance based only*/
				' AND RBS.rbs_version_id(+) = TMP.struct_version_id '  ||
				' AND RBS.user_created_flag (+)= ' || '''' || 'N' || ''''  ||
				' AND RBS.rbs_level(+) = :l_tmp';

		END IF;

		l_SQL_statement := l_INSERT_clause || ' ' ||
				l_SELECT_clause || ' ' ||
				l_FROM_clause || ' ' ||
				l_WHERE_clause || ';' ;

		EXECUTE IMMEDIATE 'BEGIN ' ||l_SQL_statement || ' END;' USING p_struct_version_id, l_tmp;


		IF g_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'Exiting unmapped_header- Inserts in pa_rbs_map_tmp :'||SQL%ROWCOUNT ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;


END;

------------------------------------------------------
--last step in inserting unmapped transactions
--into the temporary table
------------------------------------------------------

PROCEDURE	unmapped_header_laststep
		(
		p_rule_id		IN NUMBER,
		p_struct_version_id	IN NUMBER,
		p_level			IN NUMBER -- ,
		--x_return_status	OUT NOCOPY VARCHAR2,
		--x_msg_count		OUT NOCOPY NUMBER,
		--x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_SQL_statement		VARCHAR2 (2000);
		l_INSERT_clause		VARCHAR2 (500);
		l_SELECT_clause		VARCHAR2 (500);
		l_FROM_clause		VARCHAR2 (500);
		l_WHERE_clause		VARCHAR2 (500);
		l_temp			NUMBER;
BEGIN

		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'unmapped_header_laststep'
					     ,p_debug_mode => g_debug_mode );
    		  pa_debug.g_err_stage:= 'Inside unmapped_header_laststep- p_struct_version_id :'|| p_struct_version_id || ' p_level: ' || p_level || ' p_rule_id:'||p_rule_id;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		l_temp :=  3+p_level ;
		--EXECUTE IMMEDIATE 'DELETE pa_rbs_map_tmp' || l_temp;

		l_INSERT_clause := 'INSERT INTO pa_rbs_map_tmp' || l_temp
				|| ' ('
				|| ' struct_version_id, '
				|| 'sequence, '
				|| 'resource_type_id,'
				|| 'resource_source_id '
				|| ')' ;

		l_SELECT_clause := 'SELECT '
				|| ':p_struct_version_id,'
				|| ' pa_rbs_elements_s.nextval , '
				|| ' -1 , '
				|| ':p_struct_version_id';

		l_temp :=  2+p_level ;
		l_FROM_clause  := ' FROM ( SELECT distinct struct_version_id '
				|| ' FROM pa_rbs_map_tmp' || l_temp
				|| ' WHERE parent_element_version_id IS NULL '
				|| ' ) ' ;

		l_SQL_statement := l_INSERT_clause || ' ' ||
				l_SELECT_clause || ' ' ||
				l_FROM_clause || ' ;'  ;


		EXECUTE IMMEDIATE 'BEGIN ' ||l_SQL_statement || ' END;' USING p_struct_version_id;


		IF g_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'Exiting unmapped_header_laststep- Inserts in pa_rbs_map_tmp :'||SQL%ROWCOUNT ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;



END;

------------------------------------------------------
--create top rbs element inserting into pa_rbs_elements
------------------------------------------------------

PROCEDURE	create_top_rbs_element
		(
		p_rule_id		IN NUMBER,
		p_struct_version_id	IN NUMBER,
		p_max_level			IN NUMBER --,
		--x_return_status	OUT NOCOPY VARCHAR2,
		--x_msg_count		OUT NOCOPY NUMBER,
		--x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_SQL_statement		VARCHAR2 (2000);
		l_INSERT_clause		VARCHAR2 (500);
		l_SELECT_clause		VARCHAR2 (500);
		l_FROM_clause		VARCHAR2 (500);
		l_WHERE_clause		VARCHAR2 (500);
		l_tmp			NUMBER;

		x_rbs_element_name_id	NUMBER;
		x_return_status		Varchar2(30);

BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'create_top_rbs_element'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside create_top_rbs_element';
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		PA_RBS_UTILS.Populate_RBS_Element_Name(p_struct_version_id,-1,x_rbs_element_name_id,x_return_status);

		l_INSERT_clause := 'INSERT INTO pa_rbs_elements ('
				|| 'rbs_version_id,'
				|| 'rbs_element_id,'
				|| 'resource_source_id,'
				|| 'rbs_level,'
				|| 'rbs_element_name_id,'
				|| 'outline_number,'
				|| 'order_number,'
				|| 'resource_type_id,'
				|| 'rule_flag,'
				|| 'element_identifier,'
				|| 'user_created_flag,'
				|| 'last_update_date,'
				|| 'LAST_UPDATED_BY,'
				|| 'CREATION_DATE,'
				|| 'CREATED_BY,'
				|| 'LAST_UPDATE_LOGIN,'
				|| 'RECORD_VERSION_NUMBER )' ;

		l_SELECT_clause := 'SELECT '
				|| ':p_struct_version_id,'
				|| 'sequence ' || ' ,'
				|| ':p_struct_version_id,'
				|| 1 || ' ,'
				|| ':x_rbs_element_name_id,'
				|| 1 || ' ,'
				|| 1 || ' ,'
				|| -1 || ' ,'
				|| '''' || 'N'|| '''' || ' ,'
				|| 1 || ' ,'
				|| '''' || 'N' || '''' ||' ,'
				|| '''' || sysdate || '''' ||  ' ,'
				|| ':g_user_id,'
				|| '''' || sysdate || '''' ||  ' ,'
				|| ':g_user_id,'
				|| ':g_login_id,'
				|| 1 ;

		l_tmp		:= 3+p_max_level ;
		l_FROM_clause  := ' FROM pa_rbs_map_tmp' || l_tmp ;
		l_SQL_statement := l_INSERT_clause || ' ' ||
				l_SELECT_clause || ' ' ||
				l_FROM_clause || ' ;' ;


	  	EXECUTE IMMEDIATE 'BEGIN ' ||l_SQL_statement || ' END;' USING p_struct_version_id, x_rbs_element_name_id, g_user_id, g_login_id ;


                g_denorm_refresh := 'Y';



		IF g_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'Exiting create_top_rbs_element- Inserts in pa_rbs_elements :'||SQL%ROWCOUNT ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;


END ;

------------------------------------------------------
--create rbs elements inserting into pa_rbs_elements
------------------------------------------------------

PROCEDURE	create_rbs_element
		(
		p_rule_id		IN NUMBER,
		p_struct_version_id	IN NUMBER,
		p_level			IN NUMBER,
		p_max_level		IN NUMBER --,
		--x_return_status	OUT NOCOPY VARCHAR2,
		--x_msg_count		OUT NOCOPY NUMBER,
		--x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_SQL_statement		VARCHAR2 (2000);
		l_INSERT_clause		VARCHAR2 (500);
		l_SELECT_clause		VARCHAR2 (500);
		l_FROM_clause		VARCHAR2 (500);
		l_WHERE_clause		VARCHAR2 (500);
		l_max_level		NUMBER;
		l_tmp1			NUMBER;
		l_tmp2			NUMBER;
	        l_rbs_element_id        NUMBER;

		x_resource_source_id	NUMBER := NULL;
		x_resource_type_id	NUMBER := NULL;
		x_rbs_element_name_id	NUMBER;
		x_return_status		Varchar2(30);
		x_msg_count		NUMBER;
		x_error_msg_data	Varchar2(500);
BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'create_rbs_element'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside create_rbs_element';
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		-- to get element_names start here
		delete pa_rbs_elem_in_temp;

		l_INSERT_clause := 'INSERT INTO pa_rbs_elem_in_temp ( '
				|| 'resource_type_id,'
				|| 'resource_source_id ) ' ;
		l_SELECT_clause := 'SELECT distinct '
				|| get_sql_clause(p_rule_id,p_level,'RES_TYP_ID') || ' ,'
				|| get_sql_clause(p_rule_id,p_level,'RES_SOURCE') ;

		l_tmp1 := 4+p_max_level-p_level;
		l_tmp2 := 5+p_max_level-p_level;

		l_FROM_clause  := ' FROM '
				|| 'pa_rbs_map_tmp' || l_tmp1 || ' TMP, '
				|| 'pa_rbs_map_tmp' || l_tmp2 || ' TMP1 '  ;

		l_WHERE_clause := ' WHERE '
				|| get_sql_clause(p_rule_id,p_level-1,'EQUAL2')
				|| ' AND TMP.struct_version_id = TMP1.struct_version_id (+)' ;


		l_SQL_statement := l_INSERT_clause || ' ' ||
				l_SELECT_clause || ' ' ||
				l_FROM_clause || ' ' ||
				l_WHERE_clause || ';' ;



		EXECUTE IMMEDIATE 'BEGIN ' ||l_SQL_statement || ' END;';

		PA_RBS_UTILS.Populate_RBS_Element_Name(x_resource_source_id,x_resource_type_id,x_rbs_element_name_id,x_return_status);


		l_INSERT_clause := 'INSERT INTO pa_rbs_elements ( '
				|| 'rbs_version_id,'
				|| 'rbs_element_id,'
				|| 'parent_element_id,'
				|| 'rbs_level,'
				|| get_sql_clause(p_rule_id,p_level,'NONE') || ' ,'
				|| 'rbs_element_name_id,'
				|| 'outline_number,'
				|| 'order_number,'
				|| 'resource_type_id,'
				|| 'resource_source_id,'
				|| 'rule_flag,'
				|| 'element_identifier,'
				|| 'user_created_flag,'
				|| 'last_update_date,'
				|| 'LAST_UPDATED_BY,'
				|| 'CREATION_DATE,'
				|| 'CREATED_BY,'
				|| 'LAST_UPDATE_LOGIN,'
				|| 'RECORD_VERSION_NUMBER )' ;

		l_SELECT_clause := 'SELECT '
				|| ':p_struct_version_id,'
				|| 'TMP.sequence , '
				|| ' nvl(TMP.parent_element_version_id ,TMP1.sequence ), '
				|| ':p_level,'
				|| get_sql_clause(p_rule_id,p_level,'TMP') || ' ,'
				|| 'name.rbs_element_name_id , '
				|| 'RBS.outline_number , '   --bug#3974663
				|| 'RBS.order_number , '     --bug#3974663
				|| get_sql_clause(p_rule_id,p_level,'RES_TYP_ID') || ' ,'
				|| get_sql_clause(p_rule_id,p_level,'RES_SOURCE') || ' ,'
				|| '''' || 'N' || '''' || ' ,'
				|| 1 || ' ,'
				|| '''' || 'N' || '''' ||' ,'
				|| '''' || sysdate || '''' ||  ' ,'
				|| ':g_user_id,'
				|| '''' || sysdate || '''' ||  ' ,'
				|| ':g_user_id,'
				|| ':g_login_id,'
				|| 1 ;

		l_tmp1 := 4+p_max_level-p_level;
		l_tmp2 := 5+p_max_level-p_level;
                l_rbs_element_id := get_rbs_element_id(p_rule_id,p_level);

		l_FROM_clause  := ' FROM '
				|| 'pa_rbs_map_tmp' || l_tmp1 || ' TMP, '
				|| 'pa_rbs_map_tmp' || l_tmp2 || ' TMP1, '
				|| 'pa_rbs_element_names_b name, '
				|| 'pa_rbs_elements RBS ' ;  --bug#3974663
		l_WHERE_clause := ' WHERE '
				|| get_sql_clause_rule(p_rule_id,p_level-1,'EQUAL2')  --bug#3759977
				|| ' AND TMP.resource_type_id = name.resource_type_id '
				|| ' AND TMP.resource_source_id = name.resource_source_id '
			        || ' AND TMP.struct_version_id = TMP1.struct_version_id (+)'
				|| ' AND RBS.rbs_element_id = :l_rbs_element_id'; --bug#3974663


		l_SQL_statement := l_INSERT_clause || ' ' ||
				l_SELECT_clause || ' ' ||
				l_FROM_clause || ' ' ||
				l_WHERE_clause || ';' ;


		EXECUTE IMMEDIATE 'BEGIN ' ||l_SQL_statement || ' END;' USING p_struct_version_id, p_level, g_user_id, g_login_id, l_rbs_element_id;

                g_denorm_refresh := 'Y';

		IF g_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'Exiting create_rbs_element- Inserts in pa_rbs_elements :'||SQL%ROWCOUNT ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;



END ;

------------------------------------------------------
--create mapping inserting into pa_rbs_txn_accum_map
------------------------------------------------------

PROCEDURE	populate_txn_map
		(
		p_rule_id		IN NUMBER,
		p_struct_version_id	IN NUMBER,
		p_max_level		IN NUMBER --,
		--x_return_status	OUT NOCOPY VARCHAR2,
		--x_msg_count		OUT NOCOPY NUMBER,
		--x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_SQL_statement1	VARCHAR2 (2000);
		l_SQL_statement2	VARCHAR2 (2000);
		l_SQL_statement		VARCHAR2 (2000);
		l_INSERT_clause		VARCHAR2 (500);
		l_SELECT_clause		VARCHAR2 (500);
		l_FROM_clause		VARCHAR2 (500);
		l_WHERE_clause		VARCHAR2 (1000); --bug#3888373 increased size from 500 to 1000
		l_max_level		NUMBER;
BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'populate_txn_map'
					     ,p_debug_mode => g_debug_mode );
      		  pa_debug.g_err_stage:= 'Inside populate_txn_map- p_struct_version_id :'|| p_struct_version_id || ' p_max_level: ' || p_max_level || ' p_rule_id:'||p_rule_id;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		l_INSERT_clause := 'INSERT INTO pa_rbs_txn_accum_map ('
				|| 'txn_accum_header_id,'
				|| 'element_id,'
				|| 'struct_version_id,'
				|| 'last_update_date,'
				|| 'LAST_UPDATED_BY,'
				|| 'CREATION_DATE,'
				|| 'CREATED_BY,'
				|| 'LAST_UPDATE_LOGIN'
				|| ' )' ;
		l_SELECT_clause := ' SELECT '
				|| 'TMP.txn_accum_header_id,'
				|| 'RBS.rbs_element_id,'
				|| ':p_struct_version_id,'
				|| '''' || sysdate || '''' ||  ' ,'
				|| ':g_user_id,'
				|| '''' || sysdate || '''' ||  ' ,'
				|| ':g_user_id,'
				|| ':g_login_id	';
		l_FROM_clause  := ' FROM '
				|| 'pa_rbs_map_tmp3 TMP, '
				|| 'pa_rbs_elements RBS' ;
		l_WHERE_clause := ' WHERE '
				|| get_sql_clause(p_rule_id,p_max_level,'EQUAL') || ' AND '
				|| 'TMP.element_version_id IS NULL '
				|| ' AND RBS.user_created_flag = ' || '''' || 'N' || ''''
				|| 'AND RBS.rbs_version_id = :p_struct_version_id '
				|| 'AND RBS.rbs_level = :p_max_level';

		l_SQL_statement1 := l_SELECT_clause || ' ' ||
				l_FROM_clause || ' ' ||
				l_WHERE_clause  ;

		l_SELECT_clause := ' SELECT '
				|| 'TMP.txn_accum_header_id,'
				|| 'TMP.element_version_id,'
				|| ':p_struct_version_id,'
				|| '''' || sysdate || '''' ||  ' ,'
				|| ':g_user_id,'
				|| '''' || sysdate || '''' ||  ' ,'
				|| ':g_user_id,'
				|| ':g_login_id';

		l_FROM_clause  := ' FROM pa_rbs_map_tmp3 TMP ' ;
		l_WHERE_clause := 'WHERE TMP.element_version_id IS NOT NULL ' ;

		l_SQL_statement2 := l_SELECT_clause || ' ' ||
				l_FROM_clause || ' ' ||
				l_WHERE_clause  ;

		l_SQL_statement := l_INSERT_clause || ' ' ||
				l_SQL_statement1 ||
				' UNION ALL ' ||
				l_SQL_statement2 || ';' ;

		EXECUTE IMMEDIATE 'BEGIN ' ||l_SQL_statement || ' END;'
                USING p_struct_version_id, g_user_id, g_login_id, p_max_level;



		IF g_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'Exiting populate_txn_map- Inserts in Txn_accum_map :'||SQL%ROWCOUNT ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

END ;

-- procedure added for custom nodes
PROCEDURE	populate_custom_columns
		(
		p_rule_id		IN NUMBER
		)
IS

--bug#3995697	l_max_level	NUMBER;
		l_token		VARCHAR2(30);
		l_res_type_cols PA_PLSQL_DATATYPES.Char30TabTyp;
		j		NUMBER;

--bug#3995697	l_rbs_element_id	NUMBER;
		l_sql_cols	VARCHAR2(200);
BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'populate_custom_columns'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside populate_custom_columns';
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		j := 1;
		FOR i IN 2..g_max_level LOOP

			l_token:= get_level(p_rule_id,i);

			--EXECUTE IMMEDIATE 'SELECT LEVEL' || i || ' FROM pa_rbs_mapping_rules WHERE rule_id = :p_rule_id' INTO l_token USING p_rule_id ;
			IF substr(l_token,1,1) =  'C' THEN
			l_res_type_cols(j) := get_resource_type_cols(substr(l_token,3));
			j := j+1;
			END IF;
		END LOOP;

		IF l_res_type_cols.count > 0 THEN
			FOR i in 1..l_res_type_cols.count LOOP
				IF i = l_res_type_cols.count THEN
					l_sql_cols := l_sql_cols || l_res_type_cols(i) ; --bug#3878303
				ELSE
					l_sql_cols := l_sql_cols || l_res_type_cols(i) || ' , ';
				END IF;
			END LOOP;

			EXECUTE IMMEDIATE 'UPDATE pa_rbs_map_tmp2 SET ( ' || l_sql_cols || ' ) =  ( SELECT ' || l_sql_cols || ' FROM PA_RBS_ELEMENTS where rbs_element_id = :g_rbs_element_id) '  USING g_rbs_element_id;

		END IF;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting populate_custom_columns - Columns Inserted :'|| l_sql_cols;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

END ;


PROCEDURE	process_top_rule
		(
		p_struct_version_id	IN NUMBER,
		p_res_class_id		IN NUMBER --,
		--x_return_status	OUT NOCOPY VARCHAR2,
		--x_msg_count		OUT NOCOPY NUMBER,
		--x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_SQL_statement		VARCHAR2 (2000);
		l_count			NUMBER;
		l_sequence		NUMBER;

		l_txn_header_id		PA_PLSQL_DATATYPES.Char30TabTyp;

		x_rbs_element_name_id	NUMBER;
		x_return_status		VARCHAR2(30);
BEGIN
		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'process_top_rule'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside process_top_rule';
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

                SELECT distinct txn_accum_header_id
                bulk collect into l_txn_header_id
                from pa_rbs_map_tmp2
                where resource_class_id = p_res_class_id
                and txn_accum_header_id  not in (SELECT txn_accum_header_id FROM
pa_rbs_txn_accum_map
                WHERE struct_version_id = p_struct_version_id ) ;


		IF SQL%ROWCOUNT>0 THEN
			select count(*) into l_count from pa_rbs_elements where
			rbs_level = 1 and
                        rbs_version_id = p_struct_version_id and
                        user_created_flag = 'N' ;


			IF l_count = 0 THEN

				SELECT pa_rbs_elements_s.nextval INTO l_sequence FROM dual ;
				PA_RBS_UTILS.Populate_RBS_Element_Name(p_struct_version_id, -1, x_rbs_element_name_id, x_return_status);

				INSERT INTO pa_rbs_elements (
						rbs_version_id,
						rbs_element_id,
						rbs_level,
						rbs_element_name_id,
						outline_number,
						order_number,
						resource_type_id,
						rule_flag,
						element_identifier,
						user_created_flag,
						last_update_date,
						LAST_UPDATED_BY,
						CREATION_DATE,
						CREATED_BY,
						LAST_UPDATE_LOGIN,
						RECORD_VERSION_NUMBER  )
						VALUES (
						p_struct_version_id   ,
						l_sequence  ,
						1 ,
						x_rbs_element_name_id ,
						1 ,
						1 ,
						-1,
						'N',
						1 ,
						'N' ,
						sysdate,
						g_user_id ,
						sysdate ,
						g_user_id ,
						g_login_id ,
						1 ) ;

                          g_denorm_refresh := 'Y';


			ELSIF l_count = 1 THEN

				select rbs_element_id into l_sequence from pa_rbs_elements where rbs_level = 1 and
				rbs_version_id = p_struct_version_id and
				user_created_flag = 'N' ;



			END IF;

			FORALL i IN 1..l_txn_header_id.count
			INSERT INTO pa_rbs_txn_accum_map (
					txn_accum_header_id,
					element_id,
					struct_version_id,
					last_update_date,
					LAST_UPDATED_BY,
					CREATION_DATE,
					CREATED_BY,
					LAST_UPDATE_LOGIN
					)
			VALUES		(l_txn_header_id(i),
					l_sequence,
					p_struct_version_id,
					sysdate,
					g_user_id ,
					sysdate ,
					g_user_id,
					g_login_id);
		END IF;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting process_top_rule' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;
END;

---------------------------------------------------
--procedure for creating mapping of transaction
--having resource type attributes
---------------------------------------------------
PROCEDURE	map_rbs_txn
		(
		p_rbs_struct_version_id	NUMBER ,
		x_return_status	OUT NOCOPY VARCHAR2,
		x_msg_count     OUT NOCOPY NUMBER,
		x_msg_data      OUT NOCOPY VARCHAR2
		)
IS
		l_res_class_id		SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
		l_sorted_rule_id	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
--bug#3995697	l_rule_type		VARCHAR2(1);
--bug#3995697	l_max_level		number;
		l_sql_stmt		VARCHAR2(500);
		l_leaf_type		VARCHAR2(30);

		l_return_status		VARCHAR2(15);
		l_msg_count		NUMBER ;
		l_msg_data		VARCHAR2(500);

                l_top_created           number;
                l_tmp                   number;

                no_rule_excp            exception;

		can_not_lock_rbs_version	exception; --added for bug#4101364
		lockhndl			varchar2(128); --added for bug#4101364
		l                               number; --added for bug#4101364

BEGIN

		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'map_rbs_txn'
					     ,p_debug_mode => g_debug_mode );
       		  pa_debug.g_err_stage:= 'Inside map_rbs_txn- p_rbs_struct_version_id :'|| p_rbs_struct_version_id;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;


	     /* added for bug#4101364 */
	       lockhndl := auto_allocate_unique('RBS_VERSION_'||p_rbs_struct_version_id);
	       l := dbms_lock.request(lockhndl, 6, 864000, TRUE) ;
	       IF l <>0 AND l <> 4 THEN  -- 4 has been added to make it compatible within same session
			raise can_not_lock_rbs_version;
	       END IF;

                l_top_created := 0;

		SELECT resource_class_id
		BULK COLLECT
		INTO l_res_class_id
		FROM pa_resource_classes_b;


		FOR j IN 1..l_res_class_id.COUNT LOOP


			l_sorted_rule_id := get_sorted_rules(p_rbs_struct_version_id,l_res_class_id(j));

                        -- if no rules are present then no processing should happen
                        IF l_sorted_rule_id.COUNT > 0 THEN

			FOR k IN 1..l_sorted_rule_id.COUNT-1 LOOP
				SELECT rule_flag, max_level, rbs_element_id
				INTO g_rule_type, g_max_level, g_rbs_element_id
				FROM pa_rbs_mapping_rules
				WHERE rule_id = l_sorted_rule_id(k);

				-- checking for wheteher leaf node of the rule is custom then processing for the rule would be ignored
				l_sql_stmt :=	'SELECT level' || g_max_level ||
						' FROM pa_rbs_mapping_rules ' ||
						' WHERE rule_id = :rule_id'  ;

				l_leaf_type:= get_level(l_sorted_rule_id(k),g_max_level);

				--EXECUTE IMMEDIATE l_sql_stmt INTO l_leaf_type USING l_sorted_rule_id(k) ;

				IF substr(l_leaf_type,1,1) <> 'C' THEN -- skip the rule which ends with custom node

					--added for custom nodes
					populate_custom_columns(l_sorted_rule_id(k));
					mapped_header(l_sorted_rule_id(k),p_rbs_struct_version_id, g_max_level,l_res_class_id(j),l_return_status,l_msg_count,l_msg_data);
					IF l_return_status = 1 THEN
						goto next_rule;
					END IF;
					FOR l IN 1..g_max_level-1 LOOP
						unmapped_header(l_sorted_rule_id(k), p_rbs_struct_version_id,l,g_max_level - l + 1);
					END LOOP;

					IF l_top_created = 0 THEN

					unmapped_header_laststep(l_sorted_rule_id(k), p_rbs_struct_version_id,g_max_level);
					create_top_rbs_element(l_sorted_rule_id(k), p_rbs_struct_version_id,g_max_level);
					l_top_created := 1;

					END IF;

					FOR l IN 2..g_max_level LOOP
						create_rbs_element(l_sorted_rule_id(k), p_rbs_struct_version_id,l,g_max_level);
					END LOOP;

					populate_txn_map(l_sorted_rule_id(k), p_rbs_struct_version_id,g_max_level);

				END IF;

                                -- delete from all temp tables
				delete_tmp_tables(g_max_level);

				/*	FOR l IN 0..g_max_level LOOP
					    l_tmp := 3+l;
                			    EXECUTE IMMEDIATE 'DELETE pa_rbs_map_tmp' || l_tmp;
                                        END LOOP; */

				<<next_rule>>
				null;

			END LOOP;  -- done with all the rules but one i.e. SELF rule

			-- process for SELF rule

			 process_top_rule(p_rbs_struct_version_id,l_res_class_id(j));

			ELSE --no rules are present
				x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
				x_msg_count	:= 1;
				x_msg_data      := 'Rules for RBS version is missing';
				raise no_rule_excp;
                        END IF;

		END LOOP;

    /* Added for Bug 9099240 Start */
    select max(rbs_element_id)
    into g_max_rbs_id2
    from pa_rbs_elements
    where rbs_version_id = p_rbs_struct_version_id;
    /* Added for Bug 9099240 End */

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting map_rbs_txn' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

EXCEPTION WHEN OTHERS THEN /* Added the exception block for bug #6377425 */

	 x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	 x_msg_count     := 1;
	 x_msg_data      := 'pa_rbs_mapping.map_rbs_actuals.' || NVL(l_msg_data, SQLERRM);

	 Fnd_Msg_Pub.add_exc_msg( p_pkg_name => 'PA_RBS_MAPPING'
				 ,p_procedure_name  => 'map_rbs_txn');

	 IF g_debug_mode = 'Y' THEN
	  Pa_Debug.g_err_stage:='Unexpected Error inside pa_rbs_mapping.map_rbs_actuals for Structure Version  ='||p_rbs_struct_version_id||'   '|| NVL(l_msg_data,SQLERRM) ;
	  Pa_Debug.WRITE(g_module_name, Pa_Debug.g_err_stage,5);
	  Pa_Debug.reset_curr_function;
	 END IF;

	 RAISE;

END;


---------------------------------------------------
--procedure for creating mapping of actual transactions
---------------------------------------------------
PROCEDURE	map_rbs_actuals
		(
		p_worker_id     IN NUMBER DEFAULT NULL,
		x_return_status	OUT NOCOPY VARCHAR2,
		x_msg_count     OUT NOCOPY NUMBER,
		x_msg_data      OUT NOCOPY VARCHAR2
		)
IS
		l_status	NUMBER := 0;
		l_rbs_struct_version_id	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

		l_revenue_category	PA_PLSQL_DATATYPES.Char30TabTyp;
		l_res_id		NUMBER;

		l_return_status		VARCHAR2(15);
		l_msg_count		NUMBER ;
		l_msg_data		VARCHAR2(500);

                l_worker_id             NUMBER;

		l_job_group_id  NUMBER ;  --added for bug#4027727

		l_process         VARCHAR2(30);
		l_extraction_type VARCHAR2(30);
		l_out			 number;

		--AECOM Change   START  bug 6739719

        l_rbs_assoc_flag    VARCHAR2(1) := 'Y' ;
        l_rbs_prg_flag      VARCHAR2(15) := 'Y' ;

        --AECOM Change   END

        l_rbs_max         number;  /* Added for Bug 9099240 */

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_process := Pji_Pjp_Sum_Main.g_process || TO_CHAR(p_worker_id);
  l_extraction_type := Pji_Process_Util.GET_PROCESS_PARAMETER(l_process, 'EXTRACTION_TYPE');
  Pji_Pjp_Fp_Curr_Wrap.print_time( ' l_process = ' || l_process );
  Pji_Pjp_Fp_Curr_Wrap.print_time( ' l_extraction_type = ' || l_extraction_type );

  IF g_debug_mode = 'Y' THEN
    PA_DEBUG.set_curr_function( p_function   => 'map_rbs_actuals'
				     ,p_debug_mode => g_debug_mode );
    pa_debug.g_err_stage:= 'Inside map_rbs_actuals : extrn type = ' || l_extraction_type ;
    pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
  END IF;

  DELETE pa_rbs_map_tmp1 ;

  --AECOM Change   START bug 6739719

BEGIN

   SELECT 'Y'
      INTO l_rbs_assoc_flag
   FROM dual
   WHERE
        EXISTS (
               SELECT   event_type
               FROM  pji_pa_proj_events_log
               WHERE event_type  = 'RBS_ASSOC' )
        OR EXISTS (
               SELECT   event_type
               FROM  pa_pji_proj_events_log
               WHERE event_type  = 'RBS_ASSOC' ) ;


 EXCEPTION

 WHEN NO_DATA_FOUND  THEN
   l_rbs_assoc_flag := 'N' ;
 WHEN OTHERS  THEN
    raise;

 END;


BEGIN

   SELECT 'Y'
      INTO l_rbs_prg_flag
   FROM dual
   WHERE
        EXISTS (
               SELECT   event_type
               FROM  pji_pa_proj_events_log
               WHERE event_type  = 'RBS_PRG' )
        OR EXISTS (
               SELECT   event_type
               FROM  pa_pji_proj_events_log
               WHERE event_type  = 'RBS_PRG' ) ;

 EXCEPTION

 WHEN NO_DATA_FOUND  THEN
   l_rbs_prg_flag := 'N' ;
 WHEN OTHERS  THEN
    raise;

 END;

--AECOM Change   END

	/* bug#3651414 added join with rbs version and rbs header tables
           bug#3826585 added lookup to FIN7 and txn accum for project and txn accum header*/

	INSERT INTO pa_rbs_map_tmp1
		(txn_accum_header_id,
		struct_version_id)
	SELECT  /*+ ORDERED */ DISTINCT det.txn_accum_header_id,	-- Bug#5578221 Performance Fix
		ASSIGN.rbs_version_id
	FROM   (SELECT DISTINCT
                  project_id,
                  txn_accum_header_id
                FROM
                  (
                    --SELECT /*+ ORDERED index(fin7 pji_fm_aggr_fin7_n1) */
                    SELECT /*+ ORDERED USE_NL(map, fin7) index(fin7 pji_fm_aggr_fin7_n1) */  --AECOM added ordered and use_nl bug 6739719
			      fin7.project_id,
			      txn_accum_header_id
                    FROM
			      pji_pjp_proj_batch_map map,		-- Bug#5223360 -  Peformance Fix
			      pji_fm_aggr_fin7 fin7
		    WHERE fin7.project_id = map.project_id
		     		AND map.worker_id = p_worker_id
				AND fin7.recvr_period_type='GL'
                    UNION ALL
                    --SELECT /*+ ORDERED index(accum pji_fp_txn_accum_n2)*/
                    SELECT /*+ ORDERED USE_NL(map, accum) index(accum pji_fp_txn_accum_n2)*/  --AECOM added ordered and use_nl  bug 6739719
			      accum.project_id,
			      txn_accum_header_id
                    FROM
			    pji_pjp_proj_batch_map map,		-- Bug#5223360 -  Peformance Fix
			    pji_fp_txn_accum accum
		     WHERE accum.project_id = map.project_id
			     AND map.worker_id = p_worker_id
                             AND accum.recvr_period_type='GL'
		    UNION ALL
                    --SELECT /*+ ORDERED index(accum1 pji_fp_txn_accum1_n1)*/
                    SELECT /*+ ORDERED USE_NL(map, accum1) index(accum1 pji_fp_txn_accum1_n1)*/   --AECOM added ordered and use_nl bug 6739719
			      accum1.project_id,
			      txn_accum_header_id
                    FROM
			    pji_pjp_proj_batch_map map,		-- Bug#5223360 -  Peformance Fix
			    pji_fp_txn_accum1 accum1
		     WHERE accum1.project_id = map.project_id
				 AND map.worker_id = p_worker_id
                    UNION ALL
                    SELECT /*+ORDERED*/DISTINCT
			      ra.project_id,
			      ra.txn_accum_header_id
                    FROM
		    	pji_pjp_proj_batch_map map,			-- Bug#5223360 -  Peformance Fix
                     	pji_pjp_wbs_header     wbs,
                      	pa_resource_assignments ra ,
				( SELECT   worker_id
				       , event_type
				       , attribute1
				FROM pji_pa_proj_events_log
				where event_type = 'RBS_ASSOC' /* added for bug 6610295 */
				UNION ALL
				SELECT   p_worker_id
				       , event_type
				       , attribute1
				FROM pa_pji_proj_events_log
				where event_type = 'RBS_ASSOC' /* added for bug 6610295 */
                      		)LOG
                    WHERE
                 l_rbs_assoc_flag = 'Y'  and   --AECOM Change  bug 6739719
			     map.worker_id = p_worker_id and
			     map.project_id = wbs.project_id and
			      LOG.event_type              = 'RBS_ASSOC'                   AND
			      TO_NUMBER(LOG.attribute1)   = wbs.project_id                AND
			      wbs.plan_version_id         = ra.budget_version_id          AND
			      wbs.project_id              = ra.project_id                 AND
			      wbs.wp_flag                 = 'N'                           AND
			      ra.txn_accum_header_id IS NOT NULL                          AND
			      LOG.worker_id               = p_worker_id
                    UNION ALL
                    SELECT /*+ ORDERED index(den PJI_XBS_DENORM_N1)*/ -- Bug#5578221 -  Peformance Fix
				DISTINCT
			      ra.project_id,
			      ra.txn_accum_header_id
                    FROM
			      pji_pjp_proj_batch_map map,
			      pji_pjp_wbs_header      hd2,  -- sub
			      pa_resource_assignments ra,
				       ( SELECT   worker_id
					       , event_type
					       , attribute1
					FROM pji_pa_proj_events_log
					where event_type = 'RBS_PRG' /* added for bug 6610295 */
					UNION ALL
					SELECT   p_worker_id
					       , event_type
					       , attribute1
					FROM pa_pji_proj_events_log
					where event_type = 'RBS_PRG' /* added for bug 6610295 */
				      )LOG,
		   	pji_xbs_denorm          den
                    WHERE
                  l_rbs_prg_flag = 'Y' and     --AECOM Change  bug 6739719
			      map.worker_id = p_worker_id and
			      map.project_id = hd2.project_id and
			      LOG.event_type              = 'RBS_PRG'                     AND
			      ra.txn_accum_header_id      IS NOT NULL                     AND
			      LOG.worker_id               = p_worker_id                   AND
			      den.struct_version_id       IS NULL                         AND
			      TO_NUMBER(LOG.attribute1)   = den.sup_project_id            AND
			      hd2.wbs_version_id          = den.sub_id                    AND
			      den.struct_type             = 'PRG'                         AND
			      hd2.wp_flag                 = 'N'                           AND
			      hd2.plan_version_id         = ra.budget_version_id          AND
			      hd2.project_id              = ra.project_id		            )
		  ) det,
		pa_rbs_prj_assignments ASSIGN,
		pa_rbs_versions_b rbsv,
		pa_rbs_headers_b rbsh
	WHERE
		det.project_id = ASSIGN.project_id AND
		det.txn_accum_header_id NOT IN
		(SELECT txn_accum_header_id FROM pa_rbs_txn_accum_map
		WHERE struct_version_id = ASSIGN.rbs_version_id ) AND
		ASSIGN.reporting_usage_flag = 'Y' AND
		ASSIGN.rbs_version_id = rbsv.rbs_version_id AND
		rbsv.current_reporting_flag = 'Y' AND
		rbsv.rbs_header_id = rbsh.rbs_header_id AND
		SYSDATE BETWEEN rbsh.effective_from_date AND
		NVL(rbsh.effective_to_date,SYSDATE);


  IF (l_extraction_type = 'RBS') THEN

	INSERT INTO pa_rbs_map_tmp1
	  ( txn_accum_header_id
	  , struct_version_id)
        SELECT DISTINCT
               ra.txn_accum_header_id
	     , rbv2.rbs_version_id
        FROM  pji_pa_proj_events_log    LOG
            , pa_rbs_prj_assignments    asg
            , pa_rbs_versions_b         rbv1
            , pa_rbs_versions_b         rbv2
            , pa_budget_versions        bv
            , pa_resource_assignments   ra
        WHERE
              LOG.event_type              = 'RBS_PUSH'                    AND
              LOG.worker_id               = p_worker_id                   AND
              asg.rbs_version_id          = TO_NUMBER(LOG.attribute2)     AND
              asg.rbs_version_id          = rbv1.rbs_version_id           AND
              rbv1.rbs_header_id          = rbv2.rbs_header_id            AND
              rbv2.current_reporting_flag = 'Y'                           AND
              asg.project_id              = bv.project_id                 AND
              bv.budget_version_id        = ra.budget_version_id          AND
              NVL(bv.wp_version_flag, 'N')= 'N'                           AND
              bv.budget_status_code       = 'B'                           AND
              ra.txn_accum_header_id IS NOT NULL                          AND
              ra.txn_accum_header_id NOT IN
                (
		  SELECT txn_accum_header_id
                  FROM pa_rbs_txn_accum_map
                  WHERE struct_version_id = rbv2.rbs_version_id
		);

    Pji_Pjp_Fp_Curr_Wrap.print_time( ' # rows inserted = ' || SQL%ROWCOUNT );

  END IF;


	SELECT distinct struct_version_id
	BULK COLLECT
	INTO l_rbs_struct_version_id
	FROM pa_rbs_map_tmp1 ;

	create_res_type_numeric_id('EMP',11,l_res_id,l_return_status,l_msg_data);
	create_res_type_numeric_id('CWK',11,l_res_id,l_return_status,l_msg_data);

        l_worker_id := pji_pjp_extraction_utils.get_worker_id;

	FOR i IN 1..l_rbs_struct_version_id.COUNT LOOP

  /* Added for Bug 9099240 Start */
    select max(rbs_element_id)
    into l_rbs_max
    from pa_rbs_elements
    where rbs_version_id = l_rbs_struct_version_id(i);

    g_max_rbs_id1 := l_rbs_max +1;
  /* Added for Bug 9099240 End */

        SAVEPOINT  map_rbs_txn;

	SELECT distinct head.revenue_category
	BULK COLLECT INTO l_revenue_category
	FROM pa_rbs_map_tmp1 tmp, pji_fp_txn_accum_header head
	WHERE tmp.struct_version_id = l_rbs_struct_version_id(i)
	AND tmp.txn_accum_header_id = head.txn_accum_header_id
	AND head.revenue_category IS NOT NULL
	AND head.revenue_category NOT IN
	(select resource_name from pa_rbs_element_map where
	resource_type_id = 14);

	FOR p IN 1..l_revenue_category.COUNT LOOP
		create_res_type_numeric_id(l_revenue_category(p), 14, l_res_id,l_return_status,l_msg_data);
	END LOOP;


		DELETE pa_rbs_map_tmp2 ;

		/* added for bug#4027727 */
		BEGIN

  		  SELECT job_group_id
              INTO l_job_group_id
              FROM pa_rbs_versions_b
              WHERE rbs_version_id = l_rbs_struct_version_id(i) ;

  		EXCEPTION
		WHEN NO_DATA_FOUND THEN
		NULL;
		END;

		INSERT INTO pa_rbs_map_tmp2
			(txn_accum_header_id,
			struct_version_id,    ---not needed to insert but doing
			supplier_id,            --- supplier
			role_id,		--- role
			revenue_category_id,    --- revenue category
			resource_class_id,      --- resource class
			non_labor_resource_id, --- project non-labor resource
			person_type_id,         --- person type
			organization_id,        --- organization
			job_id,                 --- job
			inventory_item_id,      --- inventory item
			item_category_id,       --- item category
			expenditure_type_id,    --- expenditure type
			expenditure_category_id,--- expenditure category
			event_type_id,          --- event type
			person_id,              --- named person
			bom_equipment_id,       --- BOM equipment
			bom_labor_id            --- BOM labor
			)
		SELECT  DISTINCT
			head.txn_accum_header_id,
			l_rbs_struct_version_id(i),
			decode(head.vendor_id,-1,null,head.vendor_id),              --- supplier
			decode(head.PROJECT_ROLE_ID,-1,null, head.project_role_id),	 --- role
			decode(head.revenue_category,'PJI$NULL',null,get_res_type_numeric_id(head.revenue_category,14)),    --- revenue category
			decode(head.resource_class_id,-1,null,head.resource_class_id),           --- resource class
			decode(head.non_labor_resource_id,-1,null,head.non_labor_resource_id),   --- non labor resource
			decode(head.person_type,'PJI$NULL',null,get_res_type_numeric_id(head.person_type,11)),         --- person type
			decode(head.expenditure_organization_id,-1,null,head.expenditure_organization_id),        --- organization
			decode(head.job_id,-1,null,l_job_group_id,null,head.job_id,PA_Cross_Business_Grp.IsMappedToJob(head.job_id, l_job_group_id)),                 --- job, bug#4027727
			decode(head.inventory_item_id,-1,null,head.inventory_item_id),      --- inventory item
			decode(head.item_category_id,-1,null,head.item_category_id),       --- item category
			decode(head.expenditure_type_id,-1,null,head.expenditure_type_id),    --- expenditure type
			decode(head.expenditure_category_id,-1,null,head.expenditure_category_id), --- expenditure category
			decode(head.event_type_id,-1,null,head.event_type_id),          --- event type
			decode(head.person_id,-1,null,head.person_id),            --- named person
			decode(head.bom_equipment_resource_id,-1,null,head.bom_equipment_resource_id),       --- BOM equipment
			decode(head.bom_labor_resource_id,-1,null,head.bom_labor_resource_id)            --- BOM labor
		FROM 	pa_rbs_map_tmp1 tmp,
			pji_fp_txn_accum_header head
		WHERE tmp.struct_version_id = l_rbs_struct_version_id(i) AND
			tmp.txn_accum_header_id = head.txn_accum_header_id;


                BEGIN

		map_rbs_txn(l_rbs_struct_version_id(i),l_return_status,l_msg_count,l_msg_data);


                IF g_denorm_refresh = 'Y' THEN
                --Bug: 3952330
                --Log event to populate RBS denorm again for this RBS version
                insert into pji_pa_proj_events_log (
                  EVENT_OBJECT,
                  EVENT_TYPE,
                  WORKER_ID
                )
                values (
                  l_rbs_struct_version_id(i),
                  'PJI_RBS_CHANGE',
                  l_worker_id
                );

                END IF;

                --Reset the variable as it is not used in Actuals processing
                g_denorm_refresh := 'N';


		EXCEPTION WHEN OTHERS THEN

		 x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := 'pa_rbs_mapping.map_rbs_actuals.' || NVL(l_msg_data, SQLERRM);

	         Fnd_Msg_Pub.add_exc_msg( p_pkg_name => 'PA_RBS_MAPPING'
                                         ,p_procedure_name  => 'map_rbs_txn');

	         IF g_debug_mode = 'Y' THEN
		  Pa_Debug.g_err_stage:='Unexpected Error inside pa_rbs_mapping.map_rbs_actuals for Structure Version  ='||l_rbs_struct_version_id(i)||'   '|| NVL(l_msg_data,SQLERRM) ;
	          Pa_Debug.WRITE(g_module_name, Pa_Debug.g_err_stage,5);
		  Pa_Debug.reset_curr_function;
                 END IF;

		ROLLBACK TO map_rbs_txn;
		RAISE;		-- Bug#5223360  - RBS mapping Errors will not get suppressed
		END;


	END LOOP;

	IF g_debug_mode = 'Y' THEN

	   select count(*) into l_out from PA_RBS_PLANS_OUT_TMP;
	   pa_debug.g_err_stage:= ' Number of rows in plans_out after map_rbs_txn ' ||l_out;
	   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);

	   pa_debug.g_err_stage:= 'Exiting map_rbs_actuals' ;
	   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
	   pa_debug.reset_curr_function;


	END IF;


EXCEPTION
WHEN OTHERS THEN
	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	x_msg_count	:= 1;
	x_msg_data      := 'pa_rbs_mapping.map_rbs_actuals.' || nvl(l_msg_data, SQLERRM);
	Fnd_Msg_Pub.add_exc_msg( p_pkg_name => 'PA_RBS_MAPPING'
				,p_procedure_name  => 'map_rbs_actuals');

	IF g_debug_mode = 'Y' THEN
	  pa_debug.g_err_stage:='Unexpected Error inside pa_rbs_mapping.map_rbs_actuals '|| nvl(l_msg_data, SQLERRM) ;
	  pa_debug.write(g_module_name, pa_debug.g_err_stage,5);
	  pa_debug.reset_curr_function;
	END IF;
	raise;
END;

PROCEDURE	map_rbs_plans
		(
		p_rbs_version_id	IN NUMBER DEFAULT NULL,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_msg_count		OUT NOCOPY NUMBER,
		x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_revenue_category	PA_PLSQL_DATATYPES.Char30TabTyp;
		l_person_type_code	PA_PLSQL_DATATYPES.Char30TabTyp;

		l_rbs_struct_version_id	PA_PLSQL_DATATYPES.NumTabTyp;

		l_res_id		NUMBER;
		l_return_status		VARCHAR2(30);
		l_msg_data		VARCHAR2(500);

		l_msg_count		NUMBER;

		l_job_group_id  NUMBER ;  --added for bug#4027727

		can_not_lock_header	exception; --added for bug#4102476, 4101364
		can_not_release_lock    exception;
		lockhndl		varchar2(128); --added for bug#4102476
		l			number; --added for bug#4101364
		l_release               number;
		l_out			 number;
		l_tmpcnt		 number;	-- Bug#5503706
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF g_debug_mode = 'Y' THEN
  PA_DEBUG.set_curr_function( p_function   => 'map_rbs_plans'
			     ,p_debug_mode => g_debug_mode );
  pa_debug.g_err_stage:= 'Inside map_rbs_plans : p_rbs_version_id = ' || p_rbs_version_id ;
  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

l_tmpcnt :=0;

IF p_rbs_version_id IS NOT NULL THEN

IF g_debug_mode = 'Y' THEN
  pa_debug.g_err_stage:= 'rbs version is provided';
  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

		--check whether headers are present in pji_fp_txn_accum_header or not, if not then create them in pji_fp_txn_accum_header
		--assuming that source_id is populated in pji_fp_txn_accum_header

		-- PJI_FP_TXN_ACCUM_HEADER will have -1 for NUMBER columns and PJI$NULL for varchar columns and hence nvl
		-- on PJI_FP_TXN_ACCUM_HEADER columns is not required

		SELECT distinct revenue_category_code
		BULK COLLECT INTO l_revenue_category
		FROM PA_RBS_PLANS_IN_TMP
		WHERE revenue_category_code NOT IN
		(select resource_name from pa_rbs_element_map where resource_type_id = 14)
                AND revenue_category_code IS NOT NULL; /*Added for bug 3575147*/

		FOR p IN 1..l_revenue_category.COUNT LOOP
			create_res_type_numeric_id(l_revenue_category(p), 14, l_res_id,l_return_status,l_msg_data);
		END LOOP;


		SELECT distinct person_type_code
		BULK COLLECT INTO l_person_type_code
		FROM PA_RBS_PLANS_IN_TMP
		WHERE person_type_code NOT IN
		(select resource_name from pa_rbs_element_map where resource_type_id = 11)
                AND person_type_code IS NOT NULL; /* Added for bug 3575147 */

		FOR p IN 1..l_person_type_code.COUNT LOOP
			create_res_type_numeric_id(l_person_type_code(p), 11, l_res_id,l_return_status,l_msg_data);
		END LOOP;


	     /* added for bug#4027727 */
		BEGIN
		SELECT job_group_id INTO l_job_group_id FROM pa_rbs_versions_b WHERE rbs_version_id = p_rbs_version_id ;
	     	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		NULL;
		END;


	     /* added for bug#4102476, 4101364 */
	       lockhndl := auto_allocate_unique('LOCK_PJI_FP_TXN_ACCUM_HEADER');
	       l := dbms_lock.request(lockhndl, 6, 864000, TRUE) ;
	       IF l <> 0 AND l <> 4 THEN -- 4 has been added to make it compatible within same session
			raise can_not_lock_header;
	       END IF;

              INSERT INTO PJI_FP_TXN_ACCUM_HEADER(
		txn_accum_header_id,
		vendor_id,
		project_role_id,
		revenue_category,
		resource_class_id,
		non_labor_resource_id,
		expenditure_organization_id,
		expenditure_org_id,
		work_type_id,
		exp_evt_type_id,
		event_type,
		event_type_classification,
		expenditure_type,
		expenditure_category,
		system_linkage_function,
		job_id,
		inventory_item_id,
		item_category_id,
		expenditure_type_id,
		expenditure_category_id,
		event_type_id,
		person_id,
		bom_equipment_resource_id,
		bom_labor_resource_id,
		person_type,
                named_role,
		last_update_date,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN )
              SELECT
		PJI_FP_TXN_ACCUM_HEADER_S.nextval ,
		decode(TAB1.supplier_id,null,-1,TAB1.supplier_id),
		decode(TAB1.role_id,null,-1,TAB1.role_id),
		decode(TAB1.revenue_category_code,null,'PJI$NULL',TAB1.revenue_category_code),
		decode(TAB1.resource_class_id,null,-1,TAB1.resource_class_id) ,
		decode(TAB1.non_labor_resource_id,null,-1,TAB1.non_labor_resource_id),
		decode(TAB1.organization_id,null,-1,TAB1.organization_id),
		-1,
		-1,
		-1,
		nvl(evt.event_type, 'PJI$NULL'),
		nvl(evt.event_type_classification, 'PJI$NULL'),
		nvl(et.expenditure_type,'PJI$NULL'),
		nvl(ec.expenditure_category,'PJI$NULL'),
		'PJI$NULL',
		decode(TAB1.job_id,null,-1,TAB1.job_id),
		decode(TAB1.inventory_item_id,null,-1,TAB1.inventory_item_id),
		decode(TAB1.item_category_id,null,-1,TAB1.item_category_id),
		decode(TAB1.expenditure_type_id,null,-1,TAB1.expenditure_type_id),
		decode(TAB1.expenditure_category_id,null,-1,TAB1.expenditure_category_id),
		decode(TAB1.event_type_id,null,-1,TAB1.event_type_id),
		decode(TAB1.person_id,null,-1,TAB1.person_id),
		decode(TAB1.bom_equipment_id,null,-1,TAB1.bom_equipment_id),
		decode(TAB1.bom_labor_id,null,-1,TAB1.bom_labor_id),
		decode(TAB1.person_type_code,null,'PJI$NULL',TAB1.person_type_code),
                'PJI$NULL',
		SYSDATE,
		g_user_id,
		SYSDATE,
		g_user_id,
		g_login_id
              FROM
		(SELECT
			distinct
			supplier_id,
			role_id,
			revenue_category_code,
			resource_class_id,
			non_labor_resource_id,
			organization_id,
			job_id,
			inventory_item_id,
			item_category_id,
			expenditure_type_id,
			expenditure_category_id,
			event_type_id,
			person_id,
			bom_equipment_id,
			bom_labor_id,
			person_type_code
		FROM PA_RBS_PLANS_IN_TMP
		WHERE rowid NOT IN
			(SELECT /*+ ordered */ tmp.rowid
			FROM PA_RBS_PLANS_IN_TMP tmp, PJI_FP_TXN_ACCUM_HEADER head
			WHERE
			head.vendor_id       	= nvl(tmp.supplier_id,-1) AND
			head.project_role_id        	= nvl(tmp.role_id,-1) AND
			head.revenue_category    	= nvl(tmp.revenue_category_code,'PJI$NULL') AND
			head.resource_class_id      	= nvl(tmp.resource_class_id,-1) AND
			head.non_labor_resource_id  	= nvl(tmp.non_labor_resource_id,-1) AND
			head.expenditure_organization_id= nvl(tmp.organization_id,-1) AND
			head.job_id                 	= nvl(tmp.job_id,-1) AND
			head.inventory_item_id	= nvl(tmp.inventory_item_id,-1) AND
			head.item_category_id       	= nvl(tmp.item_category_id,-1) AND
			head.expenditure_type_id    	= nvl(tmp.expenditure_type_id,-1) AND
			head.expenditure_category_id	= nvl(tmp.expenditure_category_id,-1) AND
			head.event_type_id          	= nvl(tmp.event_type_id,-1) AND
			head.person_id            	= nvl(tmp.person_id,-1) AND
			head.bom_equipment_resource_id = nvl(tmp.bom_equipment_id,-1) AND
			head.bom_labor_resource_id   = nvl(tmp.bom_labor_id,-1) AND
			head.person_type    		= nvl(tmp.person_type_code,'PJI$NULL')
			) )TAB1,
              pa_event_types evt,
              pa_expenditure_types et,
              pa_expenditure_categories ec
            WHERE
              tab1.event_type_id           = evt.event_type_id          (+) and
              tab1.expenditure_type_id     = et.expenditure_type_id     (+) and
              tab1.expenditure_category_id = ec.expenditure_category_id (+);

	      /*bug#4770784, to remove the locking issue changes start*/
 	              IF SQL%ROWCOUNT = 0 THEN
 	                l_release := dbms_lock.release(lockhndl) ;
 	                IF l_release <> 0 AND l <> 4 THEN -- 4 has been added to make it compatible within same session
 	                         raise can_not_release_lock;
 	                END IF;
 	              END IF;
 	 /*bug#4770784, end here */

IF g_debug_mode = 'Y' THEN
  pa_debug.g_err_stage:= 'accum headers are inserted';
  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

	DELETE PA_RBS_PLANS_OUT_TMP;
	INSERT INTO PA_RBS_PLANS_OUT_TMP
		(txn_accum_header_id,
		rbs_version_id,
		source_id,
		supplier_id,
		role_id,
		revenue_category_code,
		resource_class_id,
		non_labor_resource_id,
		organization_id,
		job_id,
		inventory_item_id,
		item_category_id,
		expenditure_type_id,
		expenditure_category_id,
		event_type_id,
		person_id,
		bom_equipment_id,
		bom_labor_id,
		person_type_code)
	SELECT /*+ ordered */
		head.txn_accum_header_id,
		p_rbs_version_id,
		tmp.source_id,
		tmp.supplier_id,
		tmp.role_id,
		tmp.revenue_category_code,
		tmp.resource_class_id,
		tmp.non_labor_resource_id,
		tmp.organization_id,
		tmp.job_id,
		tmp.inventory_item_id,
		tmp.item_category_id,
		tmp.expenditure_type_id,
		tmp.expenditure_category_id,
		tmp.event_type_id,
		tmp.person_id,
		tmp.bom_equipment_id,
		tmp.bom_labor_id,
		tmp.person_type_code
	FROM PA_RBS_PLANS_IN_TMP tmp, PJI_FP_TXN_ACCUM_HEADER head
	WHERE
		head.vendor_id		       	= nvl(tmp.supplier_id,-1) AND
		head.project_role_id        	= nvl(tmp.role_id,-1) AND
		head.revenue_category    	= nvl(tmp.revenue_category_code,'PJI$NULL') AND
		head.resource_class_id      	= nvl(tmp.resource_class_id,-1) AND
		head.non_labor_resource_id  	= nvl(tmp.non_labor_resource_id,-1) AND
		head.expenditure_organization_id= nvl(tmp.organization_id,-1) AND
		head.job_id                 	= nvl(tmp.job_id,-1) AND
		head.inventory_item_id		= nvl(tmp.inventory_item_id,-1) AND
		head.item_category_id       	= nvl(tmp.item_category_id,-1) AND
		head.expenditure_type_id    	= nvl(tmp.expenditure_type_id,-1) AND
		head.expenditure_category_id	= nvl(tmp.expenditure_category_id,-1) AND
		head.event_type_id          	= nvl(tmp.event_type_id,-1) AND
		head.person_id             	= nvl(tmp.person_id,-1) AND
		head.bom_equipment_resource_id  = nvl(tmp.bom_equipment_id,-1) AND
		head.bom_labor_resource_id	= nvl(tmp.bom_labor_id,-1) AND
		head.person_type	    	= nvl(tmp.person_type_code,'PJI$NULL') ;

	 --bug#4098679
	 UPDATE pa_rbs_plans_out_tmp dest
		  SET revenue_category_id =
	( SELECT
	     src.resource_id
	  FROM
	     pa_rbs_element_map src
	 WHERE
	 src.resource_name    = dest.revenue_category_code AND
	 src.resource_type_id = 14 )
	 WHERE
	   revenue_category_code is not null;

	 UPDATE pa_rbs_plans_out_tmp dest
	    SET person_type_id =
	    ( SELECT
		 src.resource_id
	      FROM
		pa_rbs_element_map src
	      WHERE
		src.resource_name    = dest.person_type_code AND
		src.resource_type_id = 11 )
	 WHERE
	   dest.person_type_code is not null;
/** Commented for bug 6662808
	UPDATE pa_rbs_plans_out_tmp dest
	   SET job_id =
		( decode(job_id, null, null, l_job_group_id, null, job_id,
			    PA_Cross_Business_Grp.IsMappedToJob(job_id, l_job_group_id)))
	WHERE
	  dest.job_id is not null;
**/

/** Added for bug 6662808 **/

	if l_job_group_id is not null then

	UPDATE pa_rbs_plans_out_tmp dest
	SET job_id= PA_Cross_Business_Grp.IsMappedToJob(job_id,l_job_group_id)
	WHERE dest.job_id is not null;

	end if;
/** AEnd of addition for bug 6662808 **/

	DELETE pa_rbs_map_tmp2 ;
	INSERT INTO pa_rbs_map_tmp2
		(txn_accum_header_id,
		struct_version_id,
		supplier_id,
		role_id,
		revenue_category_id,
		resource_class_id,
		non_labor_resource_id,
		organization_id,
		job_id,
		inventory_item_id,
		item_category_id,
		expenditure_type_id,
		expenditure_category_id,
		event_type_id,
		person_id,
		bom_equipment_id,
		bom_labor_id,
		person_type_id)
	SELECT
                distinct /* bug#3656352 */
		txn_accum_header_id,
		p_rbs_version_id,
		supplier_id,
		role_id,
		-- get_res_type_numeric_id(revenue_category_code,14),
		revenue_category_id,   --bug#4098679
		resource_class_id,
		non_labor_resource_id,
		organization_id,
		-- decode(job_id, null, null, l_job_group_id, null, job_id, PA_Cross_Business_Grp.IsMappedToJob(job_id, l_job_group_id)),  --bug#4027727
		job_id,    --bug#4098679
		inventory_item_id,
		item_category_id,
		expenditure_type_id,
		expenditure_category_id,
		event_type_id,
		person_id,
		bom_equipment_id,
		bom_labor_id,
		-- get_res_type_numeric_id(person_type_code,11)
		person_type_id   --bug#4098679
	   FROM PA_RBS_PLANS_OUT_TMP a
	   WHERE NOT EXISTS
		(SELECT 1
		 FROM pa_rbs_txn_accum_map b
		 WHERE b.struct_version_id = p_rbs_version_id and
		       b.txn_accum_header_id=a.txn_accum_header_id);



IF g_debug_mode = 'Y' THEN
  pa_debug.g_err_stage:= 'calling map_rbs_txn for rbs version = '||p_rbs_version_id;
  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

-- Bug#5503706  Start
select count(*) into l_tmpcnt from PA_RBS_MAP_TMP2;

IF g_debug_mode = 'Y' THEN
  pa_debug.g_err_stage:= 'The number of rows in pa_rbs_map_tmp2 table  = '||l_tmpcnt;
  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

if l_tmpcnt >0  then
	map_rbs_txn(p_rbs_version_id,l_return_status,l_msg_count,l_msg_data);
end if;

-- Bug#5503706  End

		--bug#4098679
		IF   NVL(PJI_UTILS.GET_PARAMETER('PJI_FPM_UPGRADE'), 'P') = 'C'
                     AND g_denorm_refresh = 'Y'
                THEN

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Calling Pji_Pjp_Sum_Denorm.POPULATE_RBS_DENORM' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		Pji_Pjp_Sum_Denorm.POPULATE_RBS_DENORM(
		  p_worker_id           => 1,
		  p_denorm_type        => 'RBS',
		  p_rbs_version_id      => p_rbs_version_id) ;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Calling Pji_Pjp_Sum_Rollup.set_online_context' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		 Pji_Pjp_Sum_Rollup.set_online_context (
		    p_event_id              =>  NULL,
		    p_project_id            =>  NULL,
		    p_plan_type_id          =>  NULL,
		    p_old_baselined_version => NULL,
 		    p_new_baselined_version => NULL,
 		    p_old_original_version  => NULL,
 		    p_new_original_version  => NULL,
 		    p_old_struct_version    => NULL,
 		    p_new_struct_version    => NULL,
		    p_rbs_version => p_rbs_version_id );

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Calling Pji_Pjp_Sum_Rollup.UPDATE_RBS_DENORM' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		Pji_Pjp_Sum_Rollup.UPDATE_RBS_DENORM;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Calling Pji_Pjp_Sum_Denorm.cleanup_rbs_denorm' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		Pji_Pjp_Sum_Denorm.cleanup_rbs_denorm(
		   p_worker_id           => 1,
		   p_extraction_type    => 'ONLINE'
		    );

                g_denorm_refresh := 'N';

		END IF;

	UPDATE PA_RBS_PLANS_OUT_TMP tmp
	SET tmp.rbs_element_id =
			(select map.element_id
			from pa_rbs_txn_accum_map map
			where map.txn_accum_header_id = tmp.txn_accum_header_id
			and map.struct_version_id = p_rbs_version_id);


ELSE ---------------------- if rbs structure version id is not provided, header and source_id is populated

IF g_debug_mode = 'Y' THEN
  pa_debug.g_err_stage:= 'rbs version is not provided';
  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

	DELETE pa_rbs_map_tmp1 ;

	INSERT INTO pa_rbs_map_tmp1
		(txn_accum_header_id,
		struct_version_id)
	SELECT distinct tmp.txn_accum_header_id, prj_assign.rbs_version_id
	FROM PA_RBS_PLANS_IN_TMP tmp,
		PA_RESOURCE_ASSIGNMENTS res_assign,
		PA_RBS_PRJ_ASSIGNMENTS prj_assign
	WHERE tmp.source_id = res_assign.resource_assignment_id AND
		res_assign.project_id = prj_assign.project_id AND
		tmp.txn_accum_header_id not in
			(SELECT txn_accum_header_id
			FROM pa_rbs_txn_accum_map
			WHERE struct_version_id = prj_assign.rbs_version_id );

	SELECT distinct struct_version_id
	BULK COLLECT
	INTO l_rbs_struct_version_id
	FROM pa_rbs_map_tmp1;



	FOR i IN 1..l_rbs_struct_version_id.COUNT LOOP

		DELETE pa_rbs_map_tmp2 ;
		INSERT INTO pa_rbs_map_tmp2
			(txn_accum_header_id,
			struct_version_id,      ---not needed to insert but doing
			supplier_id,              --- supplier
			role_id,        --- role
			revenue_category_id,    --- revenue category
			resource_class_id,      --- resource class
			non_labor_resource_id, --- project non-labor resource
			person_type_id,         --- person type
			organization_id,        --- organization
			job_id,                 --- job
			inventory_item_id,      --- inventory item
			item_category_id,       --- item category
			expenditure_type_id,    --- expenditure type
			expenditure_category_id,--- expenditure category
			event_type_id,          --- event type
			person_id,              --- named person
			bom_equipment_id,       --- BOM equipment
			bom_labor_id           --- BOM labor
			)
		SELECT
			tmp.txn_accum_header_id,
			l_rbs_struct_version_id(i),
			tmp.supplier_id,              --- supplier
			tmp.role_id,                --- role
			get_res_type_numeric_id(tmp.revenue_category_code,14),    --- revenue category
			tmp.resource_class_id,           --- resource class
			tmp.non_labor_resource_id,   --- non labor resource
			get_res_type_numeric_id(tmp.person_type_code,11),     --- person_type
			tmp.organization_id,        --- organization
			tmp.job_id,                 --- job
			tmp.inventory_item_id,      --- inventory item
			tmp.item_category_id,       --- item category
			tmp.expenditure_type_id,    --- expenditure type
			tmp.expenditure_category_id, --- expenditure category
			tmp.event_type_id,          --- event type
			tmp.person_id,            --- named person
			tmp.bom_equipment_id,       --- BOM equipment
			tmp.bom_labor_id           --- BOM labor
		FROM pa_rbs_map_tmp1 tmp1, PA_RBS_PLANS_IN_TMP tmp
		WHERE tmp1.struct_version_id = l_rbs_struct_version_id(i) AND
		      tmp1.txn_accum_header_id = tmp.txn_accum_header_id AND
		      tmp.rowid = (select max(rowid) from PA_RBS_PLANS_IN_TMP where txn_accum_header_id = tmp.txn_accum_header_id);

		IF g_debug_mode = 'Y' THEN
		  pa_debug.g_err_stage:= 'calling map_rbs_txn for rbs version = '||l_rbs_struct_version_id(i) ;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		-- Bug#5503706  Start
			select count(*) into l_tmpcnt from PA_RBS_MAP_TMP2;

			IF g_debug_mode = 'Y' THEN
			  pa_debug.g_err_stage:= 'The number of rows in pa_rbs_map_tmp2 table  = '||l_tmpcnt;
			  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
			END IF;

			if l_tmpcnt >0  then
				map_rbs_txn(l_rbs_struct_version_id(i),l_return_status,l_msg_count,l_msg_data);
			end if;

		-- Bug#5503706  End

		--bug#4098679
		IF   NVL(PJI_UTILS.GET_PARAMETER('PJI_FPM_UPGRADE'), 'P') = 'C'
                     AND g_denorm_refresh = 'Y' THEN

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Calling Pji_Pjp_Sum_Denorm.POPULATE_RBS_DENORM' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		Pji_Pjp_Sum_Denorm.POPULATE_RBS_DENORM(
		  p_worker_id           => 1,
		  p_denorm_type        => 'RBS',
		  p_rbs_version_id      => p_rbs_version_id) ;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Calling Pji_Pjp_Sum_Rollup.set_online_context' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		 Pji_Pjp_Sum_Rollup.set_online_context (
		    p_event_id              =>  NULL,
		    p_project_id            =>  NULL,
		    p_plan_type_id          =>  NULL,
		    p_old_baselined_version => NULL,
 		    p_new_baselined_version => NULL,
 		    p_old_original_version  => NULL,
 		    p_new_original_version  => NULL,
 		    p_old_struct_version    => NULL,
 		    p_new_struct_version    => NULL,
		    p_rbs_version => p_rbs_version_id );

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Calling Pji_Pjp_Sum_Rollup.UPDATE_RBS_DENORM' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		Pji_Pjp_Sum_Rollup.UPDATE_RBS_DENORM;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Calling Pji_Pjp_Sum_Denorm.cleanup_rbs_denorm' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

		Pji_Pjp_Sum_Denorm.cleanup_rbs_denorm(
		   p_worker_id           => 1,
		   p_extraction_type    => 'ONLINE'
		    );

                g_denorm_refresh := 'N';

		END IF;

	END LOOP;

END IF;

IF g_debug_mode = 'Y' THEN
   pa_debug.g_err_stage:= 'Exiting map_rbs_plans ' ;
   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
   pa_debug.reset_curr_function;

   select count(*) into l_out from PA_RBS_PLANS_OUT_TMP;
   pa_debug.g_err_stage:= ' Number of rows in plans_out after map_rbs_txn ' ||l_out;
   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
   pa_debug.reset_curr_function;

END IF;

EXCEPTION
WHEN OTHERS THEN
	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	x_msg_count	:= 1;
	x_msg_data      := 'pa_rbs_mapping.map_rbs_plans.' || nvl(l_msg_data, SQLERRM) ;
	Fnd_Msg_Pub.add_exc_msg( p_pkg_name => 'PA_RBS_MAPPING'
				,p_procedure_name  => 'map_rbs_plans');

	IF g_debug_mode = 'Y' THEN
	  pa_debug.g_err_stage:='Unexpected Error inside pa_rbs_mapping.map_rbs_plans '|| nvl(l_msg_data, SQLERRM) ;
	  pa_debug.write(g_module_name, pa_debug.g_err_stage,5);
	  pa_debug.reset_curr_function;
	END IF;
	raise;
END;

PROCEDURE	create_res_type_numeric_id
		(
		p_resource_name		IN VARCHAR2,
		p_resource_type_id	IN NUMBER,
		x_resource_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_msg_data		OUT NOCOPY VARCHAR2
		)
IS
		l_resource_name VARCHAR2(240) := p_resource_name; /* bug#3656974 changed 30 to 240 */
		l_count		NUMBER;
BEGIN

		x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'create_res_type_numeric_id'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside create_res_type_numeric_id';
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		IF l_resource_name = 'EMP_APL' THEN
			l_resource_name := 'EMP' ;
		END IF;

		SELECT count(*)
		INTO l_count
		FROM PA_RBS_ELEMENT_MAP
		WHERE resource_name = l_resource_name
		AND resource_type_id = p_resource_type_id ;

	IF l_count = 1 THEN
		SELECT resource_id
		INTO x_resource_id
		FROM PA_RBS_ELEMENT_MAP
		WHERE resource_name = l_resource_name
		AND resource_type_id = p_resource_type_id ;
	ELSIF l_count = 0 THEN
		SELECT PA_RBS_ELEMENT_MAP_S.nextval
		INTO x_resource_id
		FROM dual ;

		INSERT INTO PA_RBS_ELEMENT_MAP
		(
		RESOURCE_TYPE_ID,
		RESOURCE_NAME,
		RESOURCE_ID,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE)
		VALUES
		(
		p_resource_type_id,
		l_resource_name,
		x_resource_id,
		sysdate,
		g_user_id ,
		g_login_id ,
		g_user_id ,
		sysdate) ;
	END IF;

	IF g_debug_mode = 'Y' THEN
	   pa_debug.g_err_stage:= 'Exiting create_res_type_numeric_id' ;
	   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
	   pa_debug.reset_curr_function;
	END IF;

EXCEPTION
WHEN OTHERS THEN
	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	x_msg_data      := 'pa_rbs_mapping.create_res_type_numeric_id.' || SQLERRM;
	Fnd_Msg_Pub.add_exc_msg( p_pkg_name => 'PA_RBS_MAPPING'
				,p_procedure_name  => 'create_res_type_numeric_id');

	IF g_debug_mode = 'Y' THEN
	  pa_debug.g_err_stage:='Unexpected Error inside pa_rbs_mapping.create_res_type_numeric_id '||SQLERRM;
	  pa_debug.write(g_module_name, pa_debug.g_err_stage,5);
	  pa_debug.reset_curr_function;
	END IF;
	raise;
END;


FUNCTION	get_res_type_numeric_id
		(
		p_resource_name		IN VARCHAR2,
		p_resource_type_id	IN NUMBER
		) RETURN NUMBER
IS
		l_resource_id	NUMBER;
BEGIN
	IF p_resource_name IS NULL THEN
		RETURN NULL;
	ELSE
		SELECT resource_id
		INTO l_resource_id
		FROM PA_RBS_ELEMENT_MAP
		WHERE resource_name = p_resource_name
		AND resource_type_id = p_resource_type_id;

		RETURN l_resource_id;
	END IF;

END;

---------------------------------------------------
--insert rule into pa_rbs_mapping_rules
---------------------------------------------------

PROCEDURE	insert_rule
		(
		rbs_version_id	number,
		depth		number,
		level		PA_PLSQL_DATATYPES.Char30TabTyp,
		element_id	number,
		rule_flag varchar2,
		per_rc_pre	number,
		equip_rc_pre	number,
		mat_rc_pre	number,
		fin_rc_pre	number
		)
IS
		l_SQL_statement	varchar2(5000);
		col_sql_clause	varchar2(1000);
		val_sql_clause	varchar2(1000);
		l_rule_id	number;

		l_rule_flag	varchar2(15);
BEGIN


		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'insert_rule'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside insert_rule';
		  pa_debug.g_err_stage:= 'Inside insert_rule- rbs_version_id :'|| rbs_version_id||' depth:'||depth;
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		col_sql_clause := '' ;
		for i in 1..depth loop
			if i=depth then
			col_sql_clause := col_sql_clause || ' level' || i  ;
			else
			col_sql_clause := col_sql_clause || ' level' || i || ' ,'  ;
			end if;
		end loop;





		val_sql_clause := '' ;
		for i in 1..depth loop
			if i=depth then
			val_sql_clause := val_sql_clause || '''' || level(i) || '''' ;
			else
			val_sql_clause := val_sql_clause || '''' || level(i) || '''' || ' ,'  ;
			end if;
		end loop;



		select PA_RBS_MAPPING_RULE_S.nextval
		into l_rule_id
		from dual;

		-- commented select below as its not required because rule_flag in pa_rbs_elements is not null column
		-- select decode(rule_flag,null,'null',''''||rule_flag||'''') into l_rule_flag from dual ;

                l_rule_flag := rule_flag; --l_rule_flag is redundant, we can remove and directly use rule_flag
		l_SQL_statement := 'INSERT INTO PA_RBS_MAPPING_RULES' ||
				' (ELEMENT_VERSION_ID, ' ||
				' RULE_ID, ' ||
				' RBS_ELEMENT_ID, ' ||
				' RULE_FLAG, ' ||
				col_sql_clause  || ' , ' ||
				' PERSON_RC_PRECEDENCE, ' ||
				' EQUIPMENT_RC_PRECEDENCE, ' ||
				' MATERIAL_RC_PRECEDENCE, ' ||
				' FIN_ELEM_RC_PRECEDENCE, ' ||
				' MAX_LEVEL, ' ||
				' LAST_UPDATE_DATE, ' ||
				' LAST_UPDATED_BY, ' ||
				' CREATION_DATE, ' ||
				' CREATED_BY, ' ||
				' LAST_UPDATE_LOGIN ) ' ||
				' VALUES ' ||
				 '( :rbs_version_id,' ||
				':l_rule_id,' ||
				':element_id,'  ||
				':l_rule_flag,'  ||
				val_sql_clause ||' ,' ||
				':per_rc_pre,' ||
				':equip_rc_pre,' ||
				':mat_rc_pre,' ||
				':fin_rc_pre,' ||
				':depth,'  ||
				'''' || sysdate || '''' || ' ,' ||
				':g_user_id,' ||
				'''' || sysdate || '''' || ' ,' ||
				':g_user_id,' ||
				':g_login_id ) ; ' ;




		EXECUTE IMMEDIATE 'BEGIN ' || l_SQL_statement || ' END;'
                USING rbs_version_id, l_rule_id, element_id, l_rule_flag, per_rc_pre,
                      equip_rc_pre, mat_rc_pre, fin_rc_pre, depth, g_user_id, g_login_id;



		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting insert_rule' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;


END;

------------------------------------------------------
--Gets the token names corresponding to all 17
--resource types
------------------------------------------------------

FUNCTION	get_res_token
		(
		p_res_type_code		VARCHAR2,
		p_elem_version_id	NUMBER
		) RETURN VARCHAR2
IS
		l_value NUMBER;
	--	added for custom nodes
		l_value1 NUMBER;
		l_value2 NUMBER;
		l_value3 NUMBER;
		l_value4 NUMBER;
		l_value5 NUMBER;

BEGIN

            	IF    p_res_type_code = 'BOM_LABOR' THEN
			select bom_labor_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:BML';
			elsif l_value > 0 then
			RETURN  'I:BML:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'BOM_EQUIPMENT' THEN
			select bom_equipment_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:BME';
			elsif l_value > 0 then
			RETURN  'I:BME:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'NAMED_PERSON' THEN
			select person_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:PER';
			elsif l_value > 0 then
			RETURN  'I:PER:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'EVENT_TYPE' THEN
			select event_type_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:EVT';
			elsif l_value > 0 then
			RETURN  'I:EVT:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'EXPENDITURE_CATEGORY' THEN
			select expenditure_category_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:EXC';
			elsif l_value > 0 then
			RETURN  'I:EXC:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'EXPENDITURE_TYPE' THEN
			select expenditure_type_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:EXT';
			elsif l_value > 0 then
			RETURN  'I:EXT:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'ITEM_CATEGORY' THEN
			select item_category_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:ITC';
			elsif l_value > 0 then
			RETURN  'I:ITC:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'INVENTORY_ITEM' THEN
			select inventory_item_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:ITM';
			elsif l_value > 0 then
			RETURN  'I:ITM:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'JOB' THEN
			select job_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:JOB';
			elsif l_value > 0 then
			RETURN  'I:JOB:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'ORGANIZATION' THEN
			select organization_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:ORG';
			elsif l_value > 0 then
			RETURN  'I:ORG:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'PERSON_TYPE' THEN
			select person_type_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:PTP';
			elsif l_value > 0 then
			RETURN  'I:PTP:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'NON_LABOR_RESOURCE' THEN
			select non_labor_resource_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:NLR';
			elsif l_value > 0 then
			RETURN  'I:NLR:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'RESOURCE_CLASS' THEN
			select resource_class_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:RES';
			elsif l_value > 0 then
			RETURN  'I:RES:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'REVENUE_CATEGORY' THEN
			select revenue_category_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:RVC';
			elsif l_value > 0 then
			RETURN  'I:RVC:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'ROLE' THEN
			select role_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:ROL';
			elsif l_value > 0 then
			RETURN  'I:ROL:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'SUPPLIER' THEN
			select supplier_id into l_value from pa_rbs_elements where rbs_element_id = p_elem_version_id ;
			if l_value = -1 then
			RETURN  'R:SUP';
			elsif l_value > 0 then
			RETURN  'I:SUP:'||l_value;	--bug#3759977
			end if;
		ELSIF p_res_type_code = 'USER_DEFINED' THEN
			select	USER_DEFINED_CUSTOM1_ID,
				USER_DEFINED_CUSTOM2_ID,
				USER_DEFINED_CUSTOM3_ID,
				USER_DEFINED_CUSTOM4_ID,
				USER_DEFINED_CUSTOM5_ID
			into	l_value1,
				l_value2,
				l_value3,
				l_value4,
				l_value5
			from pa_rbs_elements where rbs_element_id = p_elem_version_id;

		--	bug#3810558 changed CUS1 to CU1 etc

			If l_value5 is not null then
				RETURN  'C:CU5';
			elsif l_value4 is not null then
				RETURN  'C:CU4';
			elsif l_value3 is not null then
				RETURN  'C:CU3';
			elsif l_value2 is not null then
				RETURN  'C:CU2';
			elsif l_value1 is not null then
				RETURN  'C:CU1';
			end if;
		END IF;

END ;

------------------------------------------------------
--traverse RBS tree to get all the rules for RBS
------------------------------------------------------
PROCEDURE	traverse_tree
		(rbs_version_id	number,
		element_id	number,
		depth		number,
		level	 IN OUT NOCOPY /* file.sql.39 change */ PA_PLSQL_DATATYPES.Char30TabTyp,
		per_rc_pre IN OUT NOCOPY /* file.sql.39 change */ number,
		equip_rc_pre IN OUT NOCOPY /* file.sql.39 change */ number,
		mat_rc_pre IN OUT NOCOPY /* file.sql.39 change */ number,
		fin_rc_pre IN OUT NOCOPY /* file.sql.39 change */ number
		)
IS
		l_count		number;
		l_res_type_id	PA_PLSQL_DATATYPES.IdTabTyp;
		elem_version_id PA_PLSQL_DATATYPES.IdTabTyp;
		l_tmp		varchar2(30);
		rule_flag	PA_PLSQL_DATATYPES.Char1TabTyp;

		per_rc_pre_last		number;		--bug#3793418
		equip_rc_pre_last	number;		--bug#3793418
		mat_rc_pre_last		number;		--bug#3793418
		fin_rc_pre_last		number;		--bug#3793418

BEGIN

		/* commenting this because its recursive function call and set_curr_function was getting
		   called again and again without reset_curr_function to give rise to
		   ORA-06502: PL/SQL: numeric or value error

		IF g_debug_mode = 'Y' THEN
		  PA_DEBUG.set_curr_function( p_function   => 'traverse_tree'
					     ,p_debug_mode => g_debug_mode );
		  pa_debug.g_err_stage:= 'Inside traverse_tree';
		  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
		END IF;

		*/

		select element_version_id
			, resource_type_id
			, rule_flag
		bulk collect into elem_version_id
			, l_res_type_id
			, rule_flag
		from PA_RBS_MAP_TMP1
		where nvl(parent_element_version_id,-1) = nvl(element_id,-1) ;
		l_count := SQL%ROWCOUNT;

		if l_count = 0 then
		return ;
		end if;

		per_rc_pre_last		:= per_rc_pre;		--bug#3793418
		equip_rc_pre_last	:= equip_rc_pre;	--bug#3793418
		mat_rc_pre_last		:= mat_rc_pre;		--bug#3793418
		fin_rc_pre_last		:= fin_rc_pre;		--bug#3793418

		for i in 1..l_count loop
			select get_res_token(res_type_code,elem_version_id(i))
			into level(depth+1)
			from pa_res_types_b
			where res_type_id = l_res_type_id(i); --bug#3917401 replaced pa_res_types_vl by pa_res_types_b
			per_rc_pre :=	per_rc_pre_last + PA_RBS_PREC_PUB.calc_rc_precedence(l_res_type_id(i), 1);	--bug#3793418
			equip_rc_pre := equip_rc_pre_last + PA_RBS_PREC_PUB.calc_rc_precedence(l_res_type_id(i), 2);	--bug#3793418
			mat_rc_pre := mat_rc_pre_last + PA_RBS_PREC_PUB.calc_rc_precedence(l_res_type_id(i), 3);	--bug#3793418
			fin_rc_pre := fin_rc_pre_last + PA_RBS_PREC_PUB.calc_rc_precedence(l_res_type_id(i), 4);	--bug#3793418

			insert_rule(rbs_version_id,depth+1,level, elem_version_id(i), rule_flag(i),per_rc_pre,equip_rc_pre,mat_rc_pre,fin_rc_pre);

			traverse_tree(rbs_version_id, elem_version_id(i),depth+1,level,per_rc_pre,equip_rc_pre,mat_rc_pre,fin_rc_pre) ;

		end loop;

		IF g_debug_mode = 'Y' THEN
		   pa_debug.g_err_stage:= 'Exiting traverse_tree' ;
		   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
		   pa_debug.reset_curr_function;
		END IF;

END;

------------------------------------------------------
--create rules for a given RBS structure version
------------------------------------------------------

PROCEDURE	create_mapping_rules
		(
		p_rbs_version_id   IN  NUMBER,
		x_return_status  OUT NOCOPY VARCHAR2,
		x_msg_count      OUT NOCOPY NUMBER,
		x_msg_data       OUT NOCOPY VARCHAR2
		)
IS
		l_level PA_PLSQL_DATATYPES.Char30TabTyp;
		per_rc_pre	number;
		equip_rc_pre	number;
		mat_rc_pre	number;
		fin_rc_pre	number;

		p_elem_version_id	number;
		l_count			number;
		l_count_tmp1	number;		--Bug#5248414
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF g_debug_mode = 'Y' THEN
  PA_DEBUG.set_curr_function( p_function   => 'create_mapping_rules'
			     ,p_debug_mode => g_debug_mode );
  pa_debug.g_err_stage:= 'Inside create_mapping_rules- p_rbs_version_id :'|| p_rbs_version_id;
  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
END IF;

select count(1) into l_count from dual
where exists
(select 1
from pa_rbs_mapping_rules
where element_version_id = p_rbs_version_id);


IF l_count =0 THEN
		delete PA_RBS_MAP_TMP1;
		insert into PA_RBS_MAP_TMP1
		(
		STRUCT_VERSION_ID,
		ELEMENT_VERSION_ID,
		PARENT_ELEMENT_VERSION_ID,
		RESOURCE_CLASS_ID,
		BOM_LABOR_ID,
		BOM_EQUIPMENT_ID,
		PERSON_ID,
		EVENT_TYPE_ID,
		EXPENDITURE_CATEGORY_ID,
		EXPENDITURE_TYPE_ID,
		ITEM_CATEGORY_ID,
		INVENTORY_ITEM_ID,
		JOB_ID,
		ORGANIZATION_ID,
		PERSON_TYPE_ID,
		NON_LABOR_RESOURCE_ID,
		ROLE_ID,
		SUPPLIER_ID,
	--	added for custom nodes
		USER_DEFINED_CUSTOM1_ID,
		USER_DEFINED_CUSTOM2_ID,
		USER_DEFINED_CUSTOM3_ID,
		USER_DEFINED_CUSTOM4_ID,
		USER_DEFINED_CUSTOM5_ID,
		RULE_FLAG,
		RESOURCE_TYPE_ID
		)
		SELECT
		RBS_VERSION_ID,
		RBS_ELEMENT_ID,
		PARENT_ELEMENT_ID,
		RESOURCE_CLASS_ID,
		BOM_LABOR_ID,
		BOM_EQUIPMENT_ID,
		PERSON_ID,
		EVENT_TYPE_ID,
		EXPENDITURE_CATEGORY_ID,
		EXPENDITURE_TYPE_ID,
		ITEM_CATEGORY_ID,
		INVENTORY_ITEM_ID,
		JOB_ID,
		ORGANIZATION_ID,
		PERSON_TYPE_ID,
		NON_LABOR_RESOURCE_ID,
		ROLE_ID,
		SUPPLIER_ID,
	--	added for custom nodes
		USER_DEFINED_CUSTOM1_ID,
		USER_DEFINED_CUSTOM2_ID,
		USER_DEFINED_CUSTOM3_ID,
		USER_DEFINED_CUSTOM4_ID,
		USER_DEFINED_CUSTOM5_ID,
		RULE_FLAG,
		RESOURCE_TYPE_ID
		from PA_RBS_ELEMENTS
		where rbs_version_id = p_rbs_version_id and
		user_created_flag = 'Y';

		l_count_tmp1:=SQL%ROWCOUNT;		--Bug#5248414

			IF g_debug_mode = 'Y' THEN
			  PA_DEBUG.set_curr_function( p_function   => 'create_mapping_rules'
						     ,p_debug_mode => g_debug_mode );
			  pa_debug.g_err_stage:= 'Inside create_mapping_rules- Inserts in Tmp1 :'||l_count_tmp1 ;
			  pa_debug.write(g_module_name,pa_debug.g_err_stage,3) ;
			END IF;

		IF l_count_tmp1 > 0 THEN				--Bug#5248414

			l_level(1) := 'SELF' ;
			per_rc_pre	:= 0 ;
			equip_rc_pre	:= 0 ;
			mat_rc_pre	:= 0 ;
			fin_rc_pre	:= 0 ;

			select element_version_id
			into p_elem_version_id
			from PA_RBS_MAP_TMP1
			where parent_element_version_id is null;

			--insertion of SELF node
			insert_rule(p_rbs_version_id, 1 ,l_level, p_elem_version_id, 'N',0,0,0,0);

			traverse_tree(p_rbs_version_id, p_elem_version_id, 1, l_level,per_rc_pre,equip_rc_pre,mat_rc_pre,fin_rc_pre);

			delete PA_RBS_MAP_TMP1;

		END IF;

END IF;

IF g_debug_mode = 'Y' THEN
   pa_debug.g_err_stage:= 'Exiting create_mapping_rules' ;
   pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
   pa_debug.reset_curr_function;
END IF;

EXCEPTION
WHEN OTHERS THEN
	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	x_msg_count	:= 1;
	x_msg_data      := 'pa_rbs_mapping.create_mapping_rules.' || SQLERRM;
	Fnd_Msg_Pub.add_exc_msg( p_pkg_name => 'PA_RBS_MAPPING'
				,p_procedure_name  => 'create_mapping_rules');
	IF g_debug_mode = 'Y' THEN
	  pa_debug.g_err_stage:='Unexpected Error inside pa_rbs_mapping.create_mapping_rules '||SQLERRM;
	  pa_debug.write(g_module_name, pa_debug.g_err_stage,5);
	  pa_debug.reset_curr_function;

	END IF;
	raise;
END;



END; --end package pa_rbs_mapping

/
