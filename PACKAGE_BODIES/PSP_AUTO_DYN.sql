--------------------------------------------------------
--  DDL for Package Body PSP_AUTO_DYN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_AUTO_DYN" AS
--$Header: PSPAUDYB.pls 120.5 2006/07/24 13:43:58 tbalacha ship $

--------------------------------------------------------------------
--------	PROCEDURE CREATE_DYN_DATA		------------
--------------------------------------------------------------------
-- This procedure is used to create new dynamic sql statement,
-- param_value_set statement and the bind_var and validation_type


PROCEDURE create_dyn_data(p_parameter_class	IN 	VARCHAR2,
			  p_parameter		IN	VARCHAR2,
			  p_appl_column_name	IN	VARCHAR2,
			  p_dff_col_name	IN	VARCHAR2,
			  p_dff_context_code    IN      VARCHAR2,
			  p_flex_val_set_id	IN	NUMBER,
			  p_dyn_sql_stmt	OUT NOCOPY	VARCHAR2,
			  p_bind_var		OUT NOCOPY	VARCHAR2,
			  p_validation_type 	OUT NOCOPY	VARCHAR2,
			  p_param_value_set	OUT NOCOPY	VARCHAR2) IS
sob_id  number(15) :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
BEGIN

      	------------------------------------------------
     	--- Parameter Class  -> Assignment
      	------------------------------------------------

      	IF 	p_parameter_class = 'Assignment'
      	THEN
      		p_dyn_sql_stmt := 'SELECT '||p_parameter||' FROM PER_ALL_ASSIGNMENTS_F WHERE ASSIGNMENT_ID = :VAR1 AND :EFFDATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE';
       		p_bind_var:= 'l_assignment_id' ;
       		p_validation_type := 'T';
		p_param_value_set:='SELECT DISTINCT '||p_parameter||' FROM PER_ASSIGNMENTS_F ORDER BY 1';

 	------------------------------------------------
      	--- Parameter Class  ->  Person
      	------------------------------------------------

    	ELSIF 	p_parameter_class = 'Person'
        THEN
        	p_dyn_sql_stmt := 'SELECT '||p_parameter|| ' FROM PER_ALL_PEOPLE_F WHERE PERSON_ID = :VAR1 AND :EFFDATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE';
        	p_bind_var:= 'l_person_id' ;
	        p_validation_type := 'T';
	 	p_param_value_set:='SELECT DISTINCT '|| p_parameter||' FROM PER_PEOPLE_F ORDER BY 1';

	------------------------------------------------
      	--- Parameter Class  -> Elements
      	------------------------------------------------

    	ELSIF p_parameter_class = 'Elements'
      	THEN
	        p_dyn_sql_stmt := 'SELECT '||p_parameter||' FROM PAY_ELEMENT_TYPES_F WHERE ELEMENT_TYPE_ID=:VAR1 AND :EFFDATE BETWEEN EFFECTIVE_START_DATE AND NVL(EFFECTIVE_END_DATE,:EFFDATE)';
       		p_bind_var:= 'l_element_type_id' ;
        	p_validation_type := 'T';
        	p_param_value_set := 'SELECT DISTINCT '||p_parameter||' FROM PAY_ELEMENT_TYPES_F ORDER BY 1' ;

	------------------------------------------------
      	--- Parameter Class  -> Projects
      	------------------------------------------------
     	ELSIF p_parameter_class = 'Projects'
      	then
        	p_dyn_sql_stmt := 'SELECT '||p_parameter||' FROM PA_PROJECTS_ALL WHERE PROJECT_ID = :VAR1' ;
        	p_bind_var:= 'l_project_id' ;
        	p_validation_type := 'T';
        	p_param_value_set := 'SELECT DISTINCT '||p_parameter||' FROM PA_PROJECTS  ORDER BY 1';

	------------------------------------------------
      	--- Parameter Class  -> Tasks
      	------------------------------------------------

      	ELSIF p_parameter_class = 'Tasks'
      	THEN
        	p_dyn_sql_stmt := 'SELECT '||p_parameter||' FROM PA_TASKS WHERE TASK_ID = :VAR1' ;
        	p_bind_var:= 'l_task_id' ;
	        p_validation_type := 'T';
        	p_param_value_set := 'SELECT DISTINCT '||p_parameter||' FROM PA_TASKS ORDER BY 1';

	------------------------------------------------
      	--- Parameter Class  -> Awards
      	------------------------------------------------

      	ELSIF p_parameter_class = 'Awards'
      	THEN
        	p_dyn_sql_stmt := 'SELECT '||p_parameter||' FROM GMS_AWARDS_ALL  WHERE AWARD_ID = :VAR1' ;
        	p_bind_var:= 'l_award_id' ;
        	p_validation_type := 'T';
        	p_param_value_set := 'SELECT DISTINCT '||p_parameter||' FROM GMS_AWARDS ORDER BY 1';

      	------------------------------------------------
      	--- Parameter Class  -> Expenditure Type
      	------------------------------------------------
      	ELSIF p_parameter_class = 'Expenditure Type'
      	THEN
        	p_dyn_sql_stmt := 'NULL';
        	p_bind_var:= null;
        	p_validation_type := 'T';
        	p_param_value_set := 'SELECT EXPENDITURE_TYPE FROM PA_EXPENDITURE_TYPES_EXPEND_V WHERE SYSTEM_LINKAGE_FUNCTION IN (''ST'') ORDER BY EXPENDITURE_TYPE';
	------------------------------------------------
      	--- Parameter Class  -> Position Flexfield
      	------------------------------------------------

--For Bug 2640340 : Replaced the Global Variable with Parameter Variablei.e :GLOBAL.G_PER_BUSINESS_GROUP_ID with :PARAMETER.P_PER_BUSINESS_GROUP_ID
--for the variable -> p_param_value_set

      	ELSIF p_parameter_class = 'Position Flexfield'
      	THEN

        	p_dyn_sql_stmt := 'SELECT PPD.'|| p_appl_column_name||' FROM PER_ALL_ASSIGNMENTS_F PA, PER_POSITION_DEFINITIONS PPD, HR_ALL_POSITIONS_F HAP
 WHERE PA.ASSIGNMENT_ID = :VAR1 AND :EFFDATE BETWEEN PA.EFFECTIVE_START_DATE AND PA.EFFECTIVE_END_DATE AND PA.POSITION_ID = HAP.POSITION_ID
 AND :EFFDATE BETWEEN HAP.EFFECTIVE_START_DATE AND NVL(HAP.EFFECTIVE_END_DATE,:EFFDATE) AND HAP.POSITION_DEFINITION_ID = PPD.POSITION_DEFINITION_ID' ;
	       	p_bind_var:= 'l_assignment_id' ;
	        p_validation_type := 'T';
	        p_param_value_set :=  'SELECT DISTINCT PPD.'||p_appl_column_name||' FROM PER_POSITION_DEFINITIONS PPD, HR_ALL_POSITIONS_F HAP
 WHERE HAP.POSITION_DEFINITION_ID = PPD.POSITION_DEFINITION_ID
 AND HAP.BUSINESS_GROUP_ID= to_number(:PARAMETER.P_PER_BUSINESS_GROUP_ID)';

	------------------------------------------------
      	--- Parameter Class  -> Job Flexfield
      	------------------------------------------------

--For Bug 2640340 : Replaced the Global Variable with Parameter Variablei.e :GLOBAL.G_PER_BUSINESS_GROUP_ID with :PARAMETER.P_PER_BUSINESS_GROUP_ID
--for the variable -> p_param_value_set

      	ELSIF p_parameter_class = 'Job Flexfield'
      	THEN
        	p_dyn_sql_stmt := 'SELECT PJD.'||p_appl_column_name||' FROM PER_ALL_ASSIGNMENTS_F PA, PER_JOB_DEFINITIONS PJD, PER_JOBS PJ
 WHERE PA.ASSIGNMENT_ID = :VAR1 AND :EFFDATE BETWEEN PA.EFFECTIVE_START_DATE AND NVL(PA.EFFECTIVE_END_DATE,:EFFDATE)
 AND PA.JOB_ID = PJ.JOB_ID AND PJ.JOB_DEFINITION_ID = PJD.JOB_DEFINITION_ID' ;
        	p_bind_var:= 'l_assignment_id' ;
        	p_validation_type := 'T';
        	p_param_value_set :=  'SELECT DISTINCT PJD.'||p_appl_column_name||' FROM PER_JOB_DEFINITIONS PJD,PER_JOBS PJ WHERE PJ.JOB_DEFINITION_ID = PJD.JOB_DEFINITION_ID AND PJ.BUSINESS_GROUP_ID=to_number(:PARAMETER.P_PER_BUSINESS_GROUP_ID)' ;

	------------------------------------------------
      	--- Parameter Class  -> Grade Flexfield
      	------------------------------------------------

--For Bug 2640340 : Replaced the Global Variable with Parameter Variablei.e :GLOBAL.G_PER_BUSINESS_GROUP_ID with :PARAMETER.P_PER_BUSINESS_GROUP_ID
--for the variable -> p_param_value_set

      	ELSIF p_parameter_class = 'Grade Flexfield'
      	THEN
        	p_dyn_sql_stmt := 'SELECT PGD.'||p_appl_column_name||' FROM per_all_assignments_f PA, PER_GRADE_DEFINITIONS PGD, PER_GRADES PG
 WHERE PA.ASSIGNMENT_ID = :VAR1 AND :EFFDATE BETWEEN PA.EFFECTIVE_START_DATE AND NVL(PA.EFFECTIVE_END_DATE,:EFFDATE) AND PA.GRADE_ID = PG.GRADE_ID AND  PG.GRADE_DEFINITION_ID = PGD.GRADE_DEFINITION_ID' ;
	        p_bind_var:= 'l_assignment_id' ;
       		p_validation_type := 'T';
	        p_param_value_set :=  'SELECT DISTINCT PGD.'||p_appl_column_name||' FROM PER_GRADE_DEFINITIONS PGD,PER_GRADES PG WHERE PG.GRADE_DEFINITION_ID = PGD.GRADE_DEFINITION_ID
 AND PG.BUSINESS_GROUP_ID=to_number(:PARAMETER.P_PER_BUSINESS_GROUP_ID)' ;

	------------------------------------------------
      	--- Parameter Class  -> People Group Flexfield
      	------------------------------------------------

	ELSIF p_parameter_class = 'People Group Flexfield'
      	THEN
       		p_dyn_sql_stmt := 'SELECT PPG.'||p_appl_column_name||' FROM PER_ALL_ASSIGNMENTS_F PA,PAY_PEOPLE_GROUPS PPG WHERE PA.ASSIGNMENT_ID = :VAR1
 AND :EFFDATE BETWEEN PA.EFFECTIVE_START_DATE AND NVL(PA.EFFECTIVE_END_DATE,:EFFDATE) AND PA.PEOPLE_GROUP_ID = PPG.PEOPLE_GROUP_ID' ;
        p_bind_var:= 'l_assignment_id' ;
        p_validation_type := 'T';
        p_param_value_set :=  'SELECT DISTINCT PPG.'||p_appl_column_name||' FROM PAY_PEOPLE_GROUPS PPG' ;

 	------------------------------------------------
      	--- Parameter Class  -> Cost Allocation Flexfield
      	------------------------------------------------
--For Bug 2640340 : Replaced the Global Variable with Parameter Variablei.e :GLOBAL.G_PER_BUSINESS_GROUP_ID with :PARAMETER.P_PER_BUSINESS_GROUP_ID
--for the variable -> p_param_value_set

      	ELSIF p_parameter_class = 'Cost Allocation Flexfield'
      	THEN
        	p_dyn_sql_stmt := 'SELECT PCAK.'||p_appl_column_name||' FROM PER_ALL_ASSIGNMENTS_F PA,PAY_COST_ALLOCATION_KEYFLEX PCAK,PAY_ALL_PAYROLLS_F PP WHERE PA.ASSIGNMENT_ID = :VAR1
 AND :EFFDATE BETWEEN PA.EFFECTIVE_START_DATE AND PA.EFFECTIVE_END_DATE AND PA.PAYROLL_ID = PP.PAYROLL_ID AND PP.COST_ALLOCATION_KEYFLEX_ID = PCAK.COST_ALLOCATION_KEYFLEX_ID' ;
        	p_bind_var:= 'l_assignment_id' ;
        	p_validation_type := 'T';
        	p_param_value_set :=  'SELECT DISTINCT PCAK.'||p_appl_column_name||' FROM PAY_COST_ALLOCATION_KEYFLEX PCAK, PAY_COST_ALLOCATIONS_F PCAF
 where PCAK.COST_ALLOCATION_KEYFLEX_ID=PCAF.COST_ALLOCATION_KEYFLEX_ID AND PCAF.BUSINESS_GROUP_ID=TO_NUMBER(:PARAMETER.P_PER_BUSINESS_GROUP_ID)' ;
	------------------------------------------------
      	--- Parameter Class  -> Personal Analysis Flexfield
      	------------------------------------------------
      	ELSIF p_parameter_class = 'Personal Analysis Flexfield'
      	THEN
   -- Chaged the p_dyn_sql_stmt and p_param_value_set for bug 4391899
        	p_dyn_sql_stmt := 'SELECT PAC.'||p_appl_column_name||' FROM PER_PEOPLE_F PP,PER_PERSON_ANALYSES PPA,PER_ANALYSIS_CRITERIA PAC
 WHERE PP.PERSON_ID = :VAR1 AND PP.PERSON_ID = PPA.PERSON_ID AND PPA.ANALYSIS_CRITERIA_ID=PAC.ANALYSIS_CRITERIA_ID AND
 :EFFDATE BETWEEN PP.EFFECTIVE_START_DATE AND PP.EFFECTIVE_END_DATE AND
 PAC.ID_FLEX_NUM = (select id_flex_num from fnd_id_flex_structures where ID_FLEX_CODE  =''PEA'' AND id_flex_structure_code = '||''''||p_dff_context_code ||''''||' )' ;
        	p_bind_var:= 'l_person_id' ;
        	p_validation_type := 'T';
        	p_param_value_set :=  'SELECT DISTINCT PAC.'||p_appl_column_name||' FROM PER_ANALYSIS_CRITERIA PAC WHERE
 PAC.ID_FLEX_NUM = (SELECT ID_FLEX_NUM FROM FND_ID_FLEX_STRUCTURES WHERE ID_FLEX_CODE  =''PEA'' AND ID_FLEX_STRUCTURE_CODE = '||''''||p_dff_context_code ||''''||' )' ;
	------------------------------------------------
      	--- Parameter Class  -> Job DFF
      	------------------------------------------------
--For Bug 2640340 : Replaced the Global Variable with Parameter Variablei.e :GLOBAL.G_PER_BUSINESS_GROUP_ID with :PARAMETER.P_PER_BUSINESS_GROUP_ID
--for the variable -> p_param_value_set

      	ELSIF p_parameter_class = 'Job DFF'
      	THEN
        -- Chaged the p_dyn_sql_stmt and p_param_value_set for bug 4303976
        	p_dyn_sql_stmt := 'SELECT PJ.'||p_appl_column_name||' FROM PER_ASSIGNMENTS_F PA,PER_JOB_DEFINITIONS PJD,PER_JOBS PJ
 WHERE PA.ASSIGNMENT_ID = :VAR1 AND :EFFDATE BETWEEN PA.EFFECTIVE_START_DATE AND NVL(PA.EFFECTIVE_END_DATE,:EFFDATE)
 AND PA.JOB_ID = PJ.JOB_ID  AND  PJ.JOB_DEFINITION_ID = PJD.JOB_DEFINITION_ID AND ((  '||''''||
 p_dff_context_code ||''''||' = '||''''||'Global Data Elements'||''''||') or ( PJ.ATTRIBUTE_CATEGORY = '||''''||p_dff_context_code ||''''||')) ' ;

        	p_bind_var:= 'l_assignment_id' ;
        	p_validation_type := 'T';
        	p_param_value_set :=  'SELECT DISTINCT PJ.'||p_appl_column_name||' FROM PER_JOB_DEFINITIONS PJD, PER_JOBS PJ WHERE PJ.JOB_DEFINITION_ID = PJD.JOB_DEFINITION_ID
 AND PJ.BUSINESS_GROUP_ID=TO_NUMBER(:PARAMETER.P_PER_BUSINESS_GROUP_ID) AND ((  '||''''||p_dff_context_code ||''''||
' = '||''''||'Global Data Elements'||''''||') or ( PJ.ATTRIBUTE_CATEGORY = ' ||''''||p_dff_context_code ||''''|| '))
 AND PJ.'||p_appl_column_name || ' IS NOT NULL ' ;
	------------------------------------------------
      	--- Parameter Class  -> Position DFF
      	------------------------------------------------
--For Bug 2640340 : Replaced the Global Variable with Parameter Variablei.e :GLOBAL.G_PER_BUSINESS_GROUP_ID with :PARAMETER.P_PER_BUSINESS_GROUP_ID
--for the variable -> p_param_value_set

     	ELSIF p_parameter_class = 'Position DFF'
      	THEN
        -- Chaged the p_dyn_sql_stmt and p_param_value_set for bug 4303976
		p_dyn_sql_stmt := 'SELECT HAP.'||p_appl_column_name||' FROM per_all_assignments_f PA, PER_POSITION_DEFINITIONS PPD, HR_ALL_POSITIONS_F HAP
 WHERE PA.ASSIGNMENT_ID = :VAR1 AND :EFFDATE BETWEEN PA.EFFECTIVE_START_DATE AND NVL(PA.EFFECTIVE_END_DATE,:EFFDATE) AND PA.POSITION_ID = HAP.POSITION_ID
 AND :EFFDATE BETWEEN HAP.EFFECTIVE_START_DATE AND NVL(HAP.EFFECTIVE_END_DATE,:EFFDATE) AND HAP.POSITION_DEFINITION_ID = PPD.POSITION_DEFINITION_ID AND
 (( '||''''||p_dff_context_code ||''''||'= '||''''||'Global Data Elements'||''''||') or ( HAP.ATTRIBUTE_CATEGORY = '||''''||p_dff_context_code ||''''||'))';

        p_bind_var:= 'l_assignment_id' ;
        p_validation_type := 'T';
        p_param_value_set :=  'SELECT DISTINCT HAP.'||p_appl_column_name||' FROM PER_POSITION_DEFINITIONS PPD, HR_ALL_POSITIONS_F HAP
 WHERE HAP.POSITION_DEFINITION_ID = PPD.POSITION_DEFINITION_ID and HAP.BUSINESS_GROUP_ID=to_number(:PARAMETER.P_PER_BUSINESS_GROUP_ID)
 AND (( '||''''||p_dff_context_code ||''''||' = '||''''||'Global Data Elements'||''''||') or ( HAP.ATTRIBUTE_CATEGORY = '||''''||p_dff_context_code ||''''||'))
 AND HAP.'||p_appl_column_name|| ' IS NOT NULL ' ;

	------------------------------------------------
      	--- Parameter Class  -> Position Name DFF
      	------------------------------------------------

      ELSIF p_parameter_class = 'Position Name DFF'
     THEN
        p_dyn_sql_stmt := 'SELECT FFV.'||p_appl_column_name||' FROM PER_ALL_ASSIGNMENTS_F PA,PER_POSITION_DEFINITIONS PPD,
 HR_ALL_POSITIONS_F HAP, FND_FLEX_VALUES FFV WHERE PA.ASSIGNMENT_ID = :VAR1 AND :EFFDATE BETWEEN PA.EFFECTIVE_START_DATE AND NVL(PA.EFFECTIVE_END_DATE,:EFFDATE)
 AND PA.POSITION_ID = HAP.POSITION_ID AND :EFFDATE BETWEEN HAP.EFFECTIVE_START_DATE AND NVL(HAP.EFFECTIVE_END_DATE,:EFFDATE)
 AND HAP.POSITION_DEFINITION_ID = PPD.POSITION_DEFINITION_ID AND FFV.FLEX_VALUE_SET_ID ='||to_char(p_flex_val_set_id)||' and FFV.FLEX_VALUE = PPD.'||p_dff_col_name;


        p_bind_var:= 'l_assignment_id' ;
        p_validation_type := 'T';
        p_param_value_set :=  'SELECT DISTINCT '||p_appl_column_name||' FROM FND_FLEX_VALUES WHERE flex_value_set_id = '||to_char(p_flex_val_set_id) ;

        -- introduced the following code for bug 4588068
	------------------------------------------------
        --- Parameter Class  -> GL Accounting Flexfield
        ------------------------------------------------

      ELSIF p_parameter_class = 'GL Accounting  Flexfield'
      THEN
        p_dyn_sql_stmt :=  'SELECT DISTINCT GLC.'|| p_appl_column_name || ' FROM GL_CODE_COMBINATIONS GLC ,GL_SETS_OF_BOOKS GLB'
                   ||' WHERE GLC.CHART_OF_ACCOUNTS_ID = GLB.CHART_OF_ACCOUNTS_ID '
		   ||' AND GLB.SET_OF_BOOKS_ID = ' ||sob_Id
		   || ' AND GLC.CODE_COMBINATION_ID = :VAR1 '
		   || ' AND GLC.ENABLED_FLAG = ''Y''' ;
        p_bind_var:= 'l_glcc_id';

        p_validation_type := 'T';

	p_param_value_set :=   'SELECT DISTINCT GLC.'|| p_appl_column_name
	           || ' FROM GL_CODE_COMBINATIONS GLC ,GL_SETS_OF_BOOKS GLB'
		   ||' WHERE GLC.CHART_OF_ACCOUNTS_ID = GLB.CHART_OF_ACCOUNTS_ID '
		   ||' AND GLB.SET_OF_BOOKS_ID = ' || sob_Id ;

      -- End of code changes for bug 4588068
      END IF;

END create_dyn_data; -- End of procedure


--------------------------------------------------------------------
--------	PROCEDURE TYPE_TABLE_FLEX_CODE		------------
--------------------------------------------------------------------
-- This procedure finds the Validation Type Code, table name and
-- the flex_code that are needed to create the dynamic sql statement.

PROCEDURE type_table_flex_code(	p_parameter_class 	IN  VARCHAR2,
				p_type			OUT NOCOPY VARCHAR2,
				p_table_name		OUT NOCOPY VARCHAR2,
				p_flex_code		OUT NOCOPY VARCHAR2) IS

BEGIN
	p_type       := NULL;
	p_table_name := NULL;
	p_flex_code  := NULL;


	IF p_parameter_class = 'Assignment' THEN
      		p_type := 'T' ;
     	 	p_table_name := 'PER_ALL_ASSIGNMENTS_F';
   	ELSIF p_parameter_class = 'Person'  THEN
       		p_type := 'T' ;
	       	p_table_name := 'PER_ALL_PEOPLE_F';
   	ELSIF p_parameter_class = 'Elements'  THEN
       		p_type := 'T' ;
       		p_table_name := 'PAY_ELEMENT_TYPES_F';
   	ELSIF p_parameter_class = 'Projects'   	THEN
        	p_type := 'T' ;
	        p_table_name:='PA_PROJECTS_ALL';
	ELSIF p_parameter_class = 'Tasks'   THEN
	 	p_type := 'T' ;
          	p_table_name:='PA_TASKS';
   	ELSIF p_parameter_class = 'Awards' THEN
	      	p_type := 'T' ;
       		p_table_name:='GMS_AWARDS_ALL';
  	ELSIF p_parameter_class = 'Cost Allocation Flexfield' THEN
      		p_flex_code := 'COST' ;
      		p_type := 'K' ;
   	ELSIF p_parameter_class = 'Grade Flexfield' THEN
      		p_flex_code := 'GRD' ;
      		p_type := 'K' ;
   	ELSIF p_parameter_class = 'Job Flexfield'  THEN
      		p_flex_code := 'JOB' ;
      		p_type := 'K' ;
  	ELSIF   p_parameter_class = 'Personal Analysis Flexfield' THEN
                p_flex_code := 'PEA' ; -- added for bug 4391899
      		p_type := 'K' ;
  	ELSIF p_parameter_class = 'Position Flexfield' THEN
      		p_flex_code := 'POS' ;
      		p_type := 'K' ;
  	ELSIF p_parameter_class = 'People Group Flexfield' THEN
      		p_flex_code := 'GRP' ;
     		 p_type := 'K' ;
   	ELSIF p_parameter_class = 'Job DFF'  THEN
      		p_table_name := 'PER_JOBS' ;
      		p_type := 'D' ;
   	ELSIF p_parameter_class = 'Position DFF' THEN
      		p_type := 'D' ;
      		p_table_name := 'PER_POSITIONS' ;
   	ELSIF p_parameter_class = 'Position Name DFF' THEN
      		p_type := 'V' ;
      		p_flex_code := 'POS' ;
        --  Added the following code for bug 4588068
        ELSIF p_parameter_class =  'GL Accounting  Flexfield' THEN
	        p_flex_code := 'GLX' ;
	        p_type := 'K' ;

   	END IF;


END type_table_flex_code;

--------------------------------------------------------------------
--------	PROCEDURE GET_ FLEXFIELD_PARAMETERS	------------
--------------------------------------------------------------------
-- This procedure is used to find the appl_column_name, dff_col_name
-- validation_type and flex_val_set_id parameters

PROCEDURE get_flexfield_parameters( p_type 		IN VARCHAR2,
				    p_table_name 	IN VARCHAR2,
				    p_flex_code 	IN VARCHAR,
				    p_parameter 	IN VARCHAR2,
				    p_datatype 		IN VARCHAR2,
				    p_business_group_id IN NUMBER,
				    p_appl_column_name 	OUT NOCOPY VARCHAR2,
				    p_dff_col_name 	OUT NOCOPY VARCHAR2,
				    p_flex_val_set_id 	OUT NOCOPY NUMBER) IS

	v_format_Type  	    VARCHAR2(1);

BEGIN

	p_appl_column_name   	:= NULL;
	p_dff_col_name      	:= NULL;
	p_flex_val_set_id       := NULL;


  IF p_datatype = 'VARCHAR2' THEN
	v_format_type := 'C';
  ELSIF p_datatype = 'NUMBER' THEN
	v_format_type := 'N';
  ELSE  v_format_type := NULL;
  END IF;

  IF p_type = 'K'   THEN

  	IF p_flex_code= 'GRD' THEN


	  SELECT fifs1.application_column_name
	  INTO	p_appl_column_name
	  FROM fnd_id_flex_structures fifs, fnd_id_flex_segments fifs1, fnd_flex_value_sets fifs2
	  WHERE fifs.id_flex_code = 'GRD' and fifs.id_flex_num = (SELECT org_information4 FROM hr_organization_information
								WHERE organization_id = p_business_group_id
								AND org_information_context = 'Business Group Information')
	  AND fifs.application_id = fifs1.application_id and fifs.id_flex_code = fifs1.id_flex_code
	  and fifs.id_flex_num = fifs1.id_flex_num and fifs1.flex_value_set_id = fifs2.flex_value_set_id
	  and fifs1.enabled_flag='Y'
	  -- AND fifs1.segment_name = p_parameter
	  AND fifs1.application_column_name =  p_parameter
	  AND fifs2.format_type = v_format_type;


	ELSIF p_flex_code= 'GRP' THEN

	  SELECT fifs1.application_column_name
	  INTO p_appl_column_name
	  FROM fnd_id_flex_structures fifs, fnd_id_flex_segments fifs1, fnd_flex_value_sets fifs2
	  WHERE fifs.id_flex_code = 'GRP' and fifs.id_flex_num = (SELECT org_information5 FROM hr_organization_information
			WHERE organization_id = p_business_group_id and org_information_context = 'Business Group Information')
	  and fifs.application_id = fifs1.application_id
	  and fifs.id_flex_code = fifs1.id_flex_code
	  and fifs.id_flex_num = fifs1.id_flex_num
	  and fifs1.flex_value_set_id = fifs2.flex_value_set_id
	  and fifs1.enabled_flag='Y'
	  -- AND fifs1.segment_name = p_parameter
	  AND fifs1.application_column_name =  p_parameter
	  AND fifs2.format_type = v_format_type;


	ELSIF p_flex_code= 'JOB' THEN

	  SELECT fifs1.application_column_name
 	  INTO 	 p_appl_column_name
	  FROM 	 fnd_id_flex_structures fifs, fnd_id_flex_segments fifs1, fnd_flex_value_sets fifs2
	  WHERE  fifs.id_flex_code = 'JOB' and fifs.id_flex_num = (SELECT org_information6 FROM hr_organization_information
				WHERE organization_id = p_business_group_id and org_information_context = 'Business Group Information')
	  and 	 fifs.application_id = fifs1.application_id
	  and 	 fifs.id_flex_code = fifs1.id_flex_code
	  and 	 fifs.id_flex_num = fifs1.id_flex_num
	  and fifs1.flex_value_set_id = fifs2.flex_value_set_id
	  and fifs1.enabled_flag='Y'
	  -- AND fifs1.segment_name = p_parameter
	  AND fifs1.application_column_name =  p_parameter
	  AND fifs2.format_type = v_format_type;


	ELSIF p_flex_code= 'COST' then

	  SELECT fifs1.application_column_name
	  INTO p_appl_column_name
	  FROM fnd_id_flex_structures fifs, fnd_id_flex_segments fifs1, fnd_flex_value_sets fifs2
	  WHERE fifs.id_flex_code = 'COST' and fifs.id_flex_num = (SELECT org_information7 FROM hr_organization_information 		WHERE organization_id = p_business_group_id  and org_information_context = 'Business Group Information')
	  AND fifs.application_id = fifs1.application_id
	  AND fifs.id_flex_code = fifs1.id_flex_code
	  AND fifs.id_flex_num = fifs1.id_flex_num
	  AND fifs1.flex_value_set_id = fifs2.flex_value_set_id
	  AND fifs1.enabled_flag='Y'
	 -- AND fifs1.segment_name = p_parameter
	  AND fifs1.application_column_name =  p_parameter
	  AND fifs2.format_type = v_format_type;



      	ELSIF p_flex_code= 'POS' then

 	  SELECT fifs1.application_column_name
 	  INTO p_appl_column_name
	  FROM fnd_id_flex_structures fifs, fnd_id_flex_segments fifs1, fnd_flex_value_sets fifs2
	  WHERE fifs.id_flex_code = 'POS' and fifs.id_flex_num = (SELECT org_information8 FROM hr_organization_information
				WHERE organization_id = p_business_group_id and org_information_context = 'Business Group Information')
	  AND fifs.application_id = fifs1.application_id
	  AND fifs.id_flex_code = fifs1.id_flex_code
	  AND fifs.id_flex_num = fifs1.id_flex_num
	  AND fifs1.flex_value_set_id = fifs2.flex_value_set_id
	  AND fifs1.enabled_flag='Y'
	  -- AND fifs1.segment_name = p_parameter
	  AND fifs1.application_column_name =  p_parameter
	  AND fifs2.format_type = v_format_type;

      	END IF;

  ELSIF p_type = 'D' then

	SELECT 	application_column_name
	INTO 	p_appl_column_name
 	FROM 	fnd_descr_flex_column_usages WHERE descriptive_flexfield_name= p_table_name
	AND 	enabled_flag = 'Y'
--	AND 	end_user_column_name = p_parameter ;
        And     application_column_name = p_parameter;

  ELSIF p_type = 'V' THEN
      	IF p_flex_code= 'POS' THEN

	  SELECT fdfcu.application_column_name, fifs1.application_column_name, fifs1.flex_value_set_id
	  INTO 	 p_appl_column_name,p_dff_col_name, p_flex_val_set_id
	  FROM 	 fnd_id_flex_structures fifs, fnd_id_flex_segments fifs1, fnd_flex_value_sets ffvs,
                 fnd_descr_flex_column_usages fdfcu
	  WHERE fifs.id_flex_code = p_flex_code
	  and 	fifs.id_flex_num = (SELECT org_information8 FROM hr_organization_information
	  			WHERE organization_id = p_business_group_id and org_information_context = 'Business Group Information')
	  and 	fifs.application_id = fifs1.application_id and fifs.id_flex_code = fifs1.id_flex_code
	  and 	fifs.id_flex_num = fifs1.id_flex_num
	  and 	fifs1.enabled_flag = 'Y'
	  and 	fifs1.flex_value_set_id = ffvs.flex_value_set_id
	  and 	ffvs.flex_value_set_name = fdfcu.descriptive_flex_context_code
	  and 	fdfcu.descriptive_flexfield_name = 'FND_FLEX_VALUES'
--	  AND 	fdfcu.end_user_column_name = p_parameter
          AND   fdfcu.application_column_name = p_parameter
	  AND 	ffvs.format_type = v_format_type;


      END IF;
  END IF;
-- added exception for bug 4391899
EXCEPTION

WHEN no_data_found THEN
null;



END get_flexfield_parameters;


--------------------------------------------------------------------
END psp_auto_dyn; -- End of package

/
