--------------------------------------------------------
--  DDL for Package Body PJI_PMV_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PMV_ENGINE" AS
/* $Header: PJIRX01B.pls 120.7.12010000.2 2008/08/08 10:41:56 arbandyo ship $ */

	g_SQL_Error_Msg	VARCHAR2(3200);
	p_PA_DEBUG_MODE	VARCHAR2(1)	:= NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');


	/*
	** Internal functions...
	*/

	/*
	** ----------------------------------------------------------
	** Function: Write2FWKLog
	** The function writes debug statements to a output table.
	** This procedure would be replaced with the actual one later.
	** ----------------------------------------------------------
	*/
	G_Module_Name	VARCHAR2(100) := 'Module Name not set.';
	G_No_Rolling_Weeks	NUMBER;
	Procedure Write2FWKLog(   p_Message	VARCHAR2
					, p_Module	VARCHAR2    DEFAULT NULL
					, p_Level	NUMBER	DEFAULT 1)
	IS
	BEGIN
		IF p_Module IS NOT NULL THEN
			G_Module_Name:=p_Module;
		END IF;
		PJI_UTILS.Write2SSWALOG(p_Message, p_Level, G_Module_Name);
		COMMIT;
	END Write2FWKLog;

	/*
	** ----------------------------------------------------------
	** Function: Convert_AS_OF_DATE
	** The function returns hierarchy version id defined in
	** in PJI_SYSTEM_SETTINGS
	** ----------------------------------------------------------
	*/

	Function Convert_AS_OF_DATE(p_As_Of_Date		NUMBER
						, p_Period_Type	VARCHAR2
						, p_Comparator	VARCHAR2)	RETURN NUMBER
	IS
	l_Calendar_Id	NUMBER;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_AS_OF_DATE...','Convert_AS_OF_DATE');
			Write2FWKLog('p_Comparator is '||p_Comparator||', p_Period_Type is '||p_Period_Type||' and value for AS_OF_DATE is '||p_As_Of_Date);
		END IF;

		IF p_Period_Type LIKE '%PA%' THEN
			l_Calendar_Id:=G_PA_Calendar_ID;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('PA calender is selected.');
			END IF;
		ELSIF p_Period_Type LIKE '%CAL%' THEN
			l_Calendar_Id:=G_GL_Calendar_ID;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('GL calender is selected.');
			END IF;
		END IF;

		IF l_Calendar_Id IS NULL THEN
			CASE p_Comparator
			WHEN 'SEQUENTIAL' THEN
				IF p_Period_Type LIKE '%YEAR%' THEN
					RETURN to_char(FII_TIME_API.ent_sd_lyr_end(to_date(p_As_Of_Date,'j')),'j');
				ELSIF p_Period_Type LIKE '%QTR%' THEN
					RETURN to_char(FII_TIME_API.ent_sd_pqtr_end(to_date(p_As_Of_Date,'j')),'j');
				ELSIF p_Period_Type LIKE '%PERIOD%' THEN
					RETURN to_char(FII_TIME_API.ent_sd_pper_end(to_date(p_As_Of_Date,'j')),'j');
				ELSIF p_Period_Type LIKE '%WEEK%' THEN
					RETURN to_char(FII_TIME_API.sd_pwk(to_date(p_As_Of_Date,'j')),'j');
				END IF;
			WHEN 'YEARLY' THEN
				IF p_Period_Type LIKE '%YEAR%' THEN
					RETURN to_char(FII_TIME_API.ent_sd_lyr_end(to_date(p_As_Of_Date,'j')),'j');
				ELSIF p_Period_Type LIKE '%QTR%' THEN
					RETURN to_char(FII_TIME_API.ent_sd_lysqtr_end(to_date(p_As_Of_Date,'j')),'j');
				ELSIF p_Period_Type LIKE '%PERIOD%' THEN
					RETURN to_char(FII_TIME_API.ent_sd_lysper_end(to_date(p_As_Of_Date,'j')),'j');
				ELSIF p_Period_Type LIKE '%WEEK%' THEN
					RETURN to_char(FII_TIME_API.sd_lyswk(to_date(p_As_Of_Date,'j')),'j');
				END IF;
			END CASE;
		ELSE
			CASE p_Comparator
			WHEN 'SEQUENTIAL' THEN
				IF p_Period_Type LIKE '%YEAR%' THEN
					RETURN to_char(FII_TIME_API.cal_sd_lyr_end(to_date(p_As_Of_Date,'j'), l_Calendar_ID),'j');
				ELSIF p_Period_Type LIKE '%QTR%' THEN
					RETURN to_char(FII_TIME_API.cal_sd_pqtr_end(to_date(p_As_Of_Date,'j'), l_Calendar_ID),'j');
				ELSIF p_Period_Type LIKE '%PERIOD%' THEN
					RETURN to_char(FII_TIME_API.cal_sd_pper_end(to_date(p_As_Of_Date,'j'), l_Calendar_ID),'j');
				END IF;
			WHEN 'YEARLY' THEN
				IF p_Period_Type LIKE '%YEAR%' THEN
					RETURN to_char(FII_TIME_API.cal_sd_lyr_end(to_date(p_As_Of_Date,'j'), l_Calendar_ID),'j');
				ELSIF p_Period_Type LIKE '%QTR%' THEN
					RETURN to_char(FII_TIME_API.cal_sd_lysqtr_end(to_date(p_As_Of_Date,'j'), l_Calendar_ID),'j');
				ELSIF p_Period_Type LIKE '%PERIOD%' THEN
					RETURN to_char(FII_TIME_API.cal_sd_lysper_end(to_date(p_As_Of_Date,'j'), l_Calendar_ID),'j');
				END IF;
			END CASE;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_AS_OF_DATE...');
		END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN NULL;
	WHEN OTHERS THEN
		g_SQL_Error_Msg:=SQLERRM();
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog(g_SQL_Error_Msg, 3);
		END IF;
		RAISE;
	END Convert_AS_OF_DATE;

	/*
	** ----------------------------------------------------------
	** Function: Get_Hierarchy_Version_ID
	** The function returns hierarchy version id defined in
	** in PJI_SYSTEM_SETTINGS
	** ----------------------------------------------------------
	*/
	Function Get_Hierarchy_Version_ID
	RETURN NUMBER IS
	l_Org_Structure_Version_ID	PJI_SYSTEM_SETTINGS.Org_Structure_Version_ID%TYPE;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Get_Hierarchy_Version_ID...','Get_Hierarchy_Version_ID');
		END IF;
		IF l_Org_Structure_Version_ID IS NULL THEN
			BEGIN
				SELECT NVL(org_structure_version_id, -1)
				INTO l_Org_Structure_Version_ID
				FROM PJI_SYSTEM_SETTINGS;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				RETURN -1;
			WHEN OTHERS THEN
				g_SQL_Error_Msg:=SQLERRM();
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog(g_SQL_Error_Msg, 3);
				END IF;
				RAISE;
			END;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Get_Hierarchy_Version_ID...');
		END IF;
		RETURN l_Org_Structure_Version_ID;
	END Get_Hierarchy_Version_ID;

	/*
	** ----------------------------------------------------------
	** Function: Decode_IDS
	** The function returns de-constructs the parameters passed
	** by pmv report.
	** ----------------------------------------------------------
	*/
	Function Decode_IDS(p_Buffer VARCHAR2) RETURN SYSTEM.pa_num_tbl_type
	AS
	l_Buffer VARCHAR2(150);
	i NUMBER:=1;
	j NUMBER:=0;
	k NUMBER:=1;
	l_Dim_List_Tab		SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Decode_IDS...','Decode_IDS');
		END IF;
		j:=INSTR(p_Buffer,',',i);
		WHILE (j<>0)
		LOOP
			l_Buffer:=SUBSTR(p_Buffer,i,j-i);
			l_Dim_List_Tab.EXTEND;
			l_Dim_List_Tab(k):=TO_NUMBER(l_Buffer);
			i:=j+1;
			j:=INSTR(p_Buffer,',',i);
			k:=k+1;
		END LOOP;
		l_Buffer:=SUBSTR(p_Buffer,i,length(p_Buffer)+1-i);
		IF l_Buffer IS NOT NULL THEN
			l_Dim_List_Tab.EXTEND;
			l_Dim_List_Tab(k):=TO_NUMBER(l_Buffer);
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Decode_IDS...');
		END IF;
		RETURN l_Dim_List_Tab;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Decode_IDS;

        /*
        ** ----------------------------------------------------------
        ** Function: Decode_VARS
        ** The function returns de-constructs the parameters passed
        ** by pmv report.Diff between Decode_IDS and Decode_VARS is
        ** in type num and varchar.
        ** ----------------------------------------------------------
        */

        Function Decode_VARS(p_Buffer VARCHAR2) RETURN SYSTEM.pa_varchar2_240_tbl_type
        AS
        l_Buffer VARCHAR2(150);
        i NUMBER:=1;
        j NUMBER:=0;
        k NUMBER:=1;
        l_Dim_List_Tab          SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
        BEGIN
                IF p_PA_DEBUG_MODE = 'Y' THEN
                        Write2FWKLog('Entering Decode_VARS...','Decode_VARS');
                END IF;
                j:=INSTR(p_Buffer,',',i);
                WHILE (j<>0)
                LOOP
                        l_Buffer:=SUBSTR(p_Buffer,i,j-i);
                        l_Dim_List_Tab.EXTEND;
                        l_Dim_List_Tab(k):= l_Buffer ;
                        i:=j+1;
                        j:=INSTR(p_Buffer,',',i);
                        k:=k+1;
                END LOOP;
                l_Buffer:=SUBSTR(p_Buffer,i,length(p_Buffer)+1-i);
                IF l_Buffer IS NOT NULL THEN
                        l_Dim_List_Tab.EXTEND;
                        l_Dim_List_Tab(k):= l_Buffer;
                END IF;
                IF p_PA_DEBUG_MODE = 'Y' THEN
                        Write2FWKLog('Exiting Decode_VARS...');
                END IF;
                RETURN l_Dim_List_Tab;
        EXCEPTION
                WHEN OTHERS THEN
                        g_SQL_Error_Msg:=SQLERRM();
                        IF p_PA_DEBUG_MODE = 'Y' THEN
                                Write2FWKLog(g_SQL_Error_Msg, 3);
                        END IF;
                        RAISE;
        END Decode_VARS;

	/*
	** Conversion API's Section.
	** =========================
	** To facilitate the CBO to use the star query transformation
	** and to develop simple and scalable code, it was decided
	** that we would create set of temporary tables which would
	** hold the subset of lookup values based on parameters
	** selected in PMV.
	** These Convert_* API's would be called from the table
	** functions.
	*/

	/*
	** ----------------------------------------------------------
	** Function: Convert_ViewBY
	** The function translates the value of view by passed by pmv
	** to short variations understood by all the other convert
	** API's.
	** Bug# 2589267: This fix is provided for addressing the
	** scalability issues with literal strings in the sql
	** statements.
	** ----------------------------------------------------------
	*/
	Function Convert_ViewBY(p_View_BY VARCHAR2) RETURN VARCHAR2
	AS
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_ViewBY...','Convert_ViewBY');
		END IF;

		IF p_View_BY LIKE 'TIME%' THEN
			RETURN 'TM';
		END IF;

		CASE p_View_BY
			WHEN 'ORGANIZATION+PJI_ORGANIZATIONS' THEN RETURN 'OG';
			WHEN 'ORGANIZATION+FII_OPERATING_UNITS' THEN RETURN 'OU';
			WHEN 'PROJECT WORK TYPE+PJI_UTIL_CATEGORIES' THEN RETURN 'UC';
			WHEN 'PROJECT WORK TYPE+PJI_WORK_TYPES' THEN RETURN 'WT';
			WHEN 'JOB+JOB' THEN RETURN 'JB';
			WHEN 'PROJECT JOB LEVEL+PJI_JOB_LEVELS' THEN RETURN 'JL';
			WHEN 'PROJECT CLASSIFICATION+CLASS_CODE' THEN RETURN 'CC';

                        WHEN 'PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES' THEN RETURN 'EC';
                        WHEN 'PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES' THEN RETURN 'ET' ;
                        WHEN 'PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES' THEN RETURN 'RC' ;
                        WHEN 'PROJECT REVENUE CATEGORY+PJI_EXP_EVT_TYPES' THEN RETURN 'RT' ;
			ELSE RETURN 'XX';
		END CASE;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_ViewBY...');
		END IF;
	END Convert_ViewBY;

	/*
	** ----------------------------------------------------------
	** Function: Convert_Currency_Code
	** The function translates the value of currency code passed
	** to currency type stored in the PJI fact tables.
	** Bug# 2589267: This fix is provided for addressing the
	** scalability issues with literal strings in the sql
	** statements.
	** ----------------------------------------------------------
	*/

		Function Convert_Currency_Code(p_Currency_Code VARCHAR2) RETURN VARCHAR2
	AS
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Currency_Code...','Convert_Currency_Code');
		END IF;
		IF p_Currency_Code = 'FII_GLOBAL1' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Global Currency Code is selected.');
			END IF;
			RETURN 'G';

		ELSIF p_Currency_Code = 'FII_GLOBAL2' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Second Global Currency Code is selected.');
			END IF;
			RETURN 'G2';
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Functional Currency Code is selected.');
			END IF;
			RETURN 'F';
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Currency_Code...');
		END IF;
	END Convert_Currency_Code;

	/*
	** ----------------------------------------------------------
	** Function: Convert_Currency_Record_Type
	** The function translates the value of currency type
    	** to currency record type.
	** ----------------------------------------------------------
	*/
	Function Convert_Currency_Record_Type(p_Currency_Type VARCHAR2) RETURN NUMBER
	AS
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Currency_Record_Type...','Convert_Currency_Record_Type');
		END IF;
		IF p_Currency_Type = 'G' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Global Currency Code is selected.');
			END IF;
			RETURN 1;

		ELSIF p_Currency_Type = 'G2' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Second Global Currency Code is selected.');
			END IF;
			RETURN 2;

		ELSIF p_Currency_Type = 'F' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Functional Currency Code is selected.');
			END IF;
			RETURN 4;

		ELSIF p_Currency_Type = 'P' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Project Currency Code is selected.');
			END IF;
			RETURN 8;

		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Global Currency Code will be used by default.');
			END IF;
			RETURN 1;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Currency_Record_Type...');
		END IF;
	END Convert_Currency_Record_Type;


	/*
	** ----------------------------------------------------------
	** Function: Convert_Classification
	** The function inserts all the valid class codes specified in
	** the pmv report into a session specific temporary table.
	** The function return 'Y' if the lower level fact (Class)
	** needs to be joined to.
	** Bug# 2491237: For ensuring that project types are always
	** secured by Operating Unit. It is mandatory that all programs
	** calling the convert api should first place a call to the
	** Convert_Operating_Unit API before calling this API.
	** ----------------------------------------------------------
	*/

	Function Convert_Classification(p_Classification_ID VARCHAR2 DEFAULT NULL
						, p_Class_Code_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2) RETURN VARCHAR2
	AS
	l_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_Parse_Status		VARCHAR2(1);
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Classification...','Convert_Classification');
		END IF;

		DELETE PJI_PMV_CLS_DIM_TMP;
		IF p_Classification_ID IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Classification IS NOT NULL...');
			END IF;
			l_Parse_Status:='Y';
			IF p_Class_Code_IDS IS NOT NULL THEN
				l_Dimension_List_Tab:=Decode_IDS(p_Class_Code_IDS);
			ELSIF p_Classification_ID IS NOT NULL THEN
				l_Dimension_List_Tab := NULL;
			END IF;
			IF l_Dimension_List_Tab IS NULL THEN
				IF p_Classification_ID = '$PROJECT_TYPE$ALL' THEN
					IF p_PA_DEBUG_MODE = 'Y' THEN
						Write2FWKLog('All Project Types are selected.');
					END IF;
					INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
					SELECT DISTINCT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
					FROM PJI_CLASS_CODES CLS
					, PA_PROJECT_TYPES_ALL PJT
					, PJI_PMV_ORG_DIM_TMP ORG
					WHERE PJT.ORG_ID = ORG.ID
					AND CLS.CLASS_CODE = PJT.PROJECT_TYPE
					AND CLS.RECORD_TYPE = 'T';
				ELSIF p_Classification_ID LIKE '$PROJECT_TYPE$%' THEN
					IF p_PA_DEBUG_MODE = 'Y' THEN
						Write2FWKLog('All '||p_Classification_ID||' Project Type is selected.');
					END IF;
					INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
					SELECT DISTINCT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
					FROM PJI_CLASS_CODES CLS
					, PA_PROJECT_TYPES_ALL PJT
					, PJI_PMV_ORG_DIM_TMP ORG
					WHERE PJT.ORG_ID = ORG.ID
					AND CLS.CLASS_CODE = PJT.PROJECT_TYPE
					AND CLS.CLASS_CATEGORY = p_Classification_ID;
				ELSE
					IF p_PA_DEBUG_MODE = 'Y' THEN
						Write2FWKLog('All class codes for '||p_Classification_ID||' Project type or Classification are selected.');
					END IF;
					INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
					SELECT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
					FROM PJI_CLASS_CODES CLS
					WHERE CLS.CLASS_CATEGORY = p_Classification_ID;
				END IF;
			ELSIF l_Dimension_List_Tab IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Selected list of Project type or Classification '||p_Classification_ID||' are selected.');
				END IF;
				IF p_Classification_ID = '$PROJECT_TYPE$ALL' THEN
					/*
					** Following portion of the code is commented
					** because of a bug in db (2596577).
					*/
					/*
					FORALL i IN 1..l_Dimension_List_Tab.Last
						INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
						SELECT DISTINCT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
						FROM PJI_CLASS_CODES CLS
						, PA_PROJECT_TYPES_ALL PJT
						, PJI_PMV_ORG_DIM_TMP ORG
						WHERE PJT.ORG_ID = ORG.ID
						AND CLS.CLASS_CODE = PJT.PROJECT_TYPE
						AND CLS.RECORD_TYPE = 'T'
						AND CLS.CLASS_ID = l_Dimension_List_Tab(i);
					*/
					FOR i IN 1..l_Dimension_List_Tab.Last LOOP
						INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
						SELECT DISTINCT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
						FROM PJI_CLASS_CODES CLS
						, PA_PROJECT_TYPES_ALL PJT
						, PJI_PMV_ORG_DIM_TMP ORG
						WHERE PJT.ORG_ID = ORG.ID
						AND CLS.CLASS_CODE = PJT.PROJECT_TYPE
						AND CLS.RECORD_TYPE = 'T'
						AND CLS.CLASS_ID = l_Dimension_List_Tab(i);
					END LOOP;
				ELSIF p_Classification_ID LIKE '$PROJECT_TYPE$%' THEN
					/*
					** Following portion of the code is commented
					** because of a bug in db (2596577).
					*/
					/*
					FORALL i IN 1..l_Dimension_List_Tab.Last
						INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
						SELECT DISTINCT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
						FROM PJI_CLASS_CODES CLS
						, PA_PROJECT_TYPES_ALL PJT
						, PJI_PMV_ORG_DIM_TMP ORG
						WHERE PJT.ORG_ID = ORG.ID
						AND CLS.CLASS_CODE = PJT.PROJECT_TYPE
						AND CLS.CLASS_ID = l_Dimension_List_Tab(i);
					*/
					FOR i IN 1..l_Dimension_List_Tab.Last LOOP
						INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
						SELECT DISTINCT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
						FROM PJI_CLASS_CODES CLS
						, PA_PROJECT_TYPES_ALL PJT
						, PJI_PMV_ORG_DIM_TMP ORG
						WHERE PJT.ORG_ID = ORG.ID
						AND CLS.CLASS_CODE = PJT.PROJECT_TYPE
						AND CLS.CLASS_ID = l_Dimension_List_Tab(i);
					END LOOP;
				ELSE
					/*
					** Following portion of the code is commented
					** because of a bug in db (2596577).
					*/
					/*
					FORALL i IN 1..l_Dimension_List_Tab.Last
						INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
						SELECT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
						FROM PJI_CLASS_CODES CLS
						WHERE CLS.CLASS_CATEGORY = p_Classification_ID
						AND CLS.CLASS_ID = l_Dimension_List_Tab(i);
					*/
					FOR i IN 1..l_Dimension_List_Tab.Last LOOP
						INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
						SELECT CLS.CLASS_ID, DECODE(p_View_BY,'CC',CLS.CLASS_CODE,'-1')
						FROM PJI_CLASS_CODES CLS
						WHERE CLS.CLASS_CATEGORY = p_Classification_ID
						AND CLS.CLASS_ID = l_Dimension_List_Tab(i);
					END LOOP;
				END IF;
			END IF;
		ELSIF p_View_BY = 'CC' AND p_Classification_ID IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('A class code was selected without corresponding category.');
			END IF;
			l_Parse_Status:='Y';
			INSERT INTO PJI_PMV_CLS_DIM_TMP (ID, NAME)
			SELECT -1, '-1'
			FROM SYS.DUAL;		-- REMOVE THIS COMMENT WHEN THE ISSUE WITH DUAL IS RESOLVED.
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('No need to go the class fact.');
			END IF;
			l_Parse_Status:='N';
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Classification...');
		END IF;
		RETURN l_Parse_Status;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Classification;


	/*
	** ----------------------------------------------------------
	** Function: Convert_Event_Revenue_Type
	** The function inserts all the valid expenditure/event types specified in
	** the pmv report into a session specific temporary table.
	** The function return 'Y' if the lower level fact (expenditure/event types)
	** needs to be joined to.
	** ----------------------------------------------------------
	*/
	Function Convert_Event_Revenue_Type(p_Revenue_Category VARCHAR2 DEFAULT NULL
                                                , p_Revenue_Type_IDS VARCHAR2 DEFAULT NULL
                                                , p_View_BY VARCHAR2) RETURN VARCHAR2
	AS
	l_RCate_Dimension_List_Tab 	SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
	l_RType_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_RC_Parsed_Flag		VARCHAR2(1);
	l_RT_Parsed_Flag		VARCHAR2(1):='N';
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Event_Revenue_Type...','Convert_Event_Revenue_Type');
		END IF;

		DELETE PJI_PMV_EC_RC_DIM_TMP where record_type = 'RC';
		DELETE PJI_PMV_ET_RT_DIM_TMP where record_type = 'RT';

		IF p_Revenue_Category IS NOT NULL THEN
			l_RCate_Dimension_List_Tab:=Decode_VARS(p_Revenue_Category);
                ELSE
			l_RCate_Dimension_List_Tab := NULL;
		END IF;


		IF p_Revenue_Type_IDS IS NOT NULL THEN
			l_RType_Dimension_List_Tab:=Decode_IDS(p_Revenue_Type_IDS);
              ELSE
			l_RType_Dimension_List_Tab := NULL;
		END IF;

		IF l_RCate_Dimension_List_Tab IS NULL AND p_View_BY = 'RC' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('View BY RC and RC is not specified.');
				Write2FWKLog('step6','step6');
			END IF;
			INSERT INTO PJI_PMV_EC_RC_DIM_TMP (ID, NAME,RECORD_TYPE)
			SELECT ID, VALUE,'RC'
			FROM pji_revenue_categories_v ;
			l_RC_Parsed_Flag:='Y';
		ELSIF l_RCate_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('RC is specified.');
			END IF;
			FOR i IN 1..l_RCate_Dimension_List_Tab.Last LOOP
				INSERT INTO PJI_PMV_EC_RC_DIM_TMP (ID, NAME,RECORD_TYPE)
				SELECT ID, DECODE(p_View_By, 'RC', VALUE, '-1'),'RC'
				FROM pji_revenue_categories_v
				WHERE ID = l_RCate_Dimension_List_Tab(i);
			END LOOP;
			l_RC_Parsed_Flag:='Y';
		END IF;


		IF l_RType_Dimension_List_Tab IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('RT is not specified.');
			END IF;
			IF l_RC_Parsed_Flag IS NULL AND p_View_BY = 'RT' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating RT rows, View BY RT and RC is not specified.');
				END IF;

				INSERT INTO PJI_PMV_ET_RT_DIM_TMP (ID, NAME,RECORD_TYPE)
				SELECT ID, VALUE,'RT'
				FROM pji_exp_evt_types_v ;
				l_RT_Parsed_Flag:='Y';
			ELSIF l_RC_Parsed_Flag IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating RT rows, RC is specified.');
				END IF;
				INSERT INTO PJI_PMV_ET_RT_DIM_TMP (ID, NAME,RECORD_TYPE)
				SELECT rtyp.id, DECODE(p_View_BY,'RC',usrx.name,'RT',rtyp.value,'-1'),'RT'
				FROM pji_exp_evt_types_v rtyp
				, PJI_PMV_EC_RC_DIM_TMP usrx
				WHERE rtyp.revenue_category_code = usrx.id
                                 and  usrx.record_type = 'RC';
				l_RT_Parsed_Flag:='Y';
			END IF;
		ELSIF l_RType_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('RT is specified.');
			END IF;
			IF l_RC_Parsed_Flag IS NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating RT rows, RC is not specified.');
				END IF;
				FOR i IN 1..l_RType_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_ET_RT_DIM_TMP (ID, NAME,RECORD_TYPE)
					SELECT id, DECODE(p_View_BY,'RT',value,'-1'),'RT'
					FROM pji_exp_evt_types_v
					WHERE
					id = l_RType_Dimension_List_Tab(i);
				END LOOP;
				l_RT_Parsed_Flag:='Y';
			ELSIF l_RC_Parsed_Flag IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating RT rows, RC is specified.');
				END IF;
				FOR i IN 1..l_RType_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_ET_RT_DIM_TMP (ID, NAME,RECORD_TYPE)
					SELECT rtyp.id, DECODE(p_View_BY,'RC',usrx.name,'RT',rtyp.value,'-1'),'RT'
					FROM pji_exp_evt_types_v rtyp
					, PJI_PMV_EC_RC_DIM_TMP usrx
					WHERE rtyp.id = l_RType_Dimension_List_Tab(i)
					AND rtyp.revenue_category_code = usrx.id
                                        AND usrx.record_type = 'RC';
				END LOOP;
				l_RT_Parsed_Flag:='Y';
			END IF;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Event_Revenue_Type...');
		END IF;
		RETURN l_RT_Parsed_Flag;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Event_Revenue_Type;

	Function Convert_Work_Type(p_Work_Type_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2) RETURN VARCHAR2
	AS
	l_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_Parse_Status		VARCHAR2(1);
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Work_Type...','Convert_Work_Type');
		END IF;

		DELETE PJI_PMV_WT_DIM_TMP;

 	  IF p_View_BY NOT IN ('WT') AND p_Work_Type_IDS IS NULL THEN
           l_Parse_Status := 'N';
          ELSE
           l_Parse_Status:='Y';

		IF p_Work_Type_IDS IS NOT NULL THEN
				l_Dimension_List_Tab:=Decode_IDS(p_Work_Type_IDS);
				FOR i IN 1..l_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_WT_DIM_TMP (ID, NAME)
					SELECT WT.ID, DECODE(p_View_BY,'WT',WT.VALUE,'-1')
					FROM PJI_WORK_TYPES_V WT
                                        WHERE  WT.ID = l_Dimension_List_Tab(i);
				END LOOP;
                ELSE
					INSERT INTO PJI_PMV_WT_DIM_TMP (ID, NAME)
					SELECT WT.ID, WT.VALUE
					FROM PJI_WORK_TYPES_V WT ;
                END IF;

	   END IF;
	   RETURN l_Parse_Status;
        EXCEPTION
                WHEN OTHERS THEN
                        g_SQL_Error_Msg:=SQLERRM();
                        IF p_PA_DEBUG_MODE = 'Y' THEN
                                Write2FWKLog(g_SQL_Error_Msg, 3);
                        END IF;
                        RAISE;

	END Convert_Work_Type;

	/*
        ** Function: Convert_Expenditure_Type
	** The function inserts all the valid expenditure types specified in
	** the pmv report into a session specific temporary table.
	** The function return 'Y' if the lower level fact (expenditure type)
	** needs to be joined to.
	** ----------------------------------------------------------
	*/
	Function Convert_Expenditure_Type(p_Expenditure_Category VARCHAR2 DEFAULT NULL
						, p_Expenditure_Type_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2) RETURN VARCHAR2
	AS
	l_ECate_Dimension_List_Tab 	SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
	l_EType_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_EC_Parsed_Flag		VARCHAR2(1);
	l_ET_Parsed_Flag		VARCHAR2(1):='N';
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Expenditure_Category...','Convert_Expenditure_Category');
		END IF;

		DELETE PJI_PMV_ET_RT_DIM_TMP where record_type = 'ET';
		DELETE PJI_PMV_EC_RC_DIM_TMP where record_type = 'EC';

		IF p_Expenditure_Category IS NOT NULL THEN
			l_ECate_Dimension_List_Tab:=Decode_VARS(p_Expenditure_Category);
              ELSE
			l_ECate_Dimension_List_Tab := NULL;
		END IF;


		IF p_Expenditure_Type_IDS IS NOT NULL THEN
			l_EType_Dimension_List_Tab:=Decode_IDS(p_Expenditure_Type_IDS);
              ELSE
			l_EType_Dimension_List_Tab := NULL;
		END IF;

		IF l_ECate_Dimension_List_Tab IS NULL AND p_View_BY = 'EC' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('View BY EC and EC is not specified.');
			END IF;
			INSERT INTO PJI_PMV_EC_RC_DIM_TMP (ID, NAME,RECORD_TYPE)
			SELECT EXPENDITURE_CATEGORY, EXPENDITURE_CATEGORY,'EC'
			FROM PA_EXPENDITURE_CATEGORIES ;
			l_EC_Parsed_Flag:='Y';
		ELSIF l_ECate_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('EC is specified.');
			END IF;
			FOR i IN 1..l_ECate_Dimension_List_Tab.Last LOOP
				INSERT INTO PJI_PMV_EC_RC_DIM_TMP (ID, NAME,RECORD_TYPE)
				SELECT EXPENDITURE_CATEGORY, DECODE(p_View_By, 'EC', EXPENDITURE_CATEGORY, '-1'),'EC'
				FROM PA_EXPENDITURE_CATEGORIES
				WHERE EXPENDITURE_CATEGORY_ID = to_number(l_ECate_Dimension_List_Tab(i));
				/* Changed the where clause to expenditure_category_id as l_ECate_Dimension_List_Tab
				stores expenditure_category_id in varchar form. Added for bug 6836176 */
			END LOOP;
			l_EC_Parsed_Flag:='Y';
		END IF;


		IF l_EType_Dimension_List_Tab IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('ET is not specified.');
			END IF;
			IF l_EC_Parsed_Flag IS NULL AND p_View_BY = 'ET' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating ET rows, View BY ET and EC is not specified.');
				END IF;

				INSERT INTO PJI_PMV_ET_RT_DIM_TMP (ID, NAME,RECORD_TYPE)
				SELECT EXPENDITURE_TYPE_ID, EXPENDITURE_TYPE,'ET'
				FROM PA_EXPENDITURE_TYPES ;
				l_ET_Parsed_Flag:='Y';
			ELSIF l_EC_Parsed_Flag IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating ET rows, EC is specified.');
				END IF;
				INSERT INTO PJI_PMV_ET_RT_DIM_TMP (ID, NAME,RECORD_TYPE)
				SELECT etyp.expenditure_type_id,

DECODE(p_View_BY,'EC',usrx.name,'ET',etyp.expenditure_type,'-1'),'ET'
				FROM pa_expenditure_types etyp
				, PJI_PMV_EC_RC_DIM_TMP usrx
				WHERE etyp.expenditure_category = usrx.id
                                  and usrx.record_type = 'EC';
				l_ET_Parsed_Flag:='Y';
			END IF;
		ELSIF l_EType_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('ET is specified.');
			END IF;
			IF l_EC_Parsed_Flag IS NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating ET rows, EC is not specified.');
				END IF;
				FOR i IN 1..l_EType_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_ET_RT_DIM_TMP (ID, NAME,RECORD_TYPE)
					SELECT expenditure_type_id, DECODE(p_View_BY,'ET',expenditure_type,'-1'),'ET'
					FROM pa_expenditure_types
					WHERE
					expenditure_type_id = l_EType_Dimension_List_Tab(i);
				END LOOP;
				l_ET_Parsed_Flag:='Y';
			ELSIF l_EC_Parsed_Flag IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating ET rows, EC is specified.');
				END IF;
				FOR i IN 1..l_EType_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_ET_RT_DIM_TMP (ID, NAME,RECORD_TYPE)
					SELECT etyp.expenditure_type_id,

					DECODE(p_View_BY,'EC',usrx.name,'ET',etyp.expenditure_type,'-1'),'ET'
					FROM pa_expenditure_types etyp
					, PJI_PMV_EC_RC_DIM_TMP usrx
					WHERE etyp.expenditure_type_id = l_EType_Dimension_List_Tab(i)
					AND etyp.expenditure_category = usrx.id
                                        AND usrx.record_type = 'EC';
				END LOOP;
				l_ET_Parsed_Flag:='Y';
			END IF;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Expenditure_Type...');
		END IF;
		RETURN l_ET_Parsed_Flag;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Expenditure_Type;

	/*
	** ----------------------------------------------------------
	** Function: Convert_Util_Category
	** The function inserts all the valid work types specified in
	** the pmv report into a session specific temporary table.
	** The function return 'Y' if the lower level fact (work type)
	** needs to be joined to.
	** ----------------------------------------------------------
	*/
	Function Convert_Util_Category(p_Work_Type_IDS VARCHAR2 DEFAULT NULL
						, p_Util_Category_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2) RETURN VARCHAR2
	AS
	l_Util_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_WType_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_UC_Parsed_Flag		VARCHAR2(1);
	l_WT_Parsed_Flag		VARCHAR2(1):='N';
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Util_Category...','Convert_Util_Category');
		END IF;

		DELETE PJI_PMV_WT_DIM_TMP;
		DELETE PJI_PMV_UC_DIM_TMP;

		IF p_Util_Category_IDS IS NOT NULL THEN
			l_Util_Dimension_List_Tab:=Decode_IDS(p_Util_Category_IDS);
              ELSE
			l_Util_Dimension_List_Tab := NULL;
		END IF;


		IF p_Work_Type_IDS IS NOT NULL THEN
			l_WType_Dimension_List_Tab:=Decode_IDS(p_Work_Type_IDS);
              ELSE
			l_WType_Dimension_List_Tab := NULL;
		END IF;

		IF l_Util_Dimension_List_Tab IS NULL AND p_View_BY = 'UC' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('View BY UC and UC is not specified.');
			END IF;
			INSERT INTO PJI_PMV_UC_DIM_TMP (ID, NAME)
			SELECT util_category_id, name
			FROM pa_util_categories_tl
			WHERE
			LANGUAGE = USERENV('LANG');
			l_UC_Parsed_Flag:='Y';
		ELSIF l_Util_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('UC is specified.');
			END IF;
			/*
			** Following portion of the code is commented
			** because of a bug in db (2596577).
			*/
			/*
			FORALL i IN 1..l_Util_Dimension_List_Tab.Last
				INSERT INTO PJI_PMV_UC_DIM_TMP (ID, NAME)
				SELECT util_category_id, DECODE(p_View_By, 'UC', name , '-1')
				FROM pa_util_categories_tl
				WHERE
				LANGUAGE = USERENV('LANG')
				AND util_category_id = l_Util_Dimension_List_Tab(i);
			*/
			FOR i IN 1..l_Util_Dimension_List_Tab.Last LOOP
				INSERT INTO PJI_PMV_UC_DIM_TMP (ID, NAME)
				SELECT util_category_id, DECODE(p_View_By, 'UC', name , '-1')
				FROM pa_util_categories_tl
				WHERE
				LANGUAGE = USERENV('LANG')
				AND util_category_id = l_Util_Dimension_List_Tab(i);
			END LOOP;
			l_UC_Parsed_Flag:='Y';
		END IF;


		IF l_WType_Dimension_List_Tab IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('WT is not specified.');
			END IF;
			IF l_UC_Parsed_Flag IS NULL AND p_View_BY = 'WT' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating WT rows, View BY WT and UC is not specified.');
				END IF;
				INSERT INTO PJI_PMV_WT_DIM_TMP (ID, NAME)
				SELECT work_type_id, name
				FROM pa_work_types_tl
				WHERE
				LANGUAGE = USERENV('LANG');
				l_WT_Parsed_Flag:='Y';
			ELSIF l_UC_Parsed_Flag IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating WT rows, UC is specified.');
				END IF;
				INSERT INTO PJI_PMV_WT_DIM_TMP (ID, NAME)
				SELECT orig.work_type_id, DECODE(p_View_BY,'UC',usrx.name,'WT',orig_tl.name,'-1')
				FROM pa_work_types_tl orig_tl
				, pa_work_types_b orig
				, pji_pmv_uc_dim_tmp usrx
				WHERE
				LANGUAGE = USERENV('LANG')
				AND orig.work_type_id = orig_tl.work_type_id
				AND orig.org_util_category_id = usrx.id;
				l_WT_Parsed_Flag:='Y';
			END IF;
		ELSIF l_WType_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('WT is specified.');
			END IF;
			IF l_UC_Parsed_Flag IS NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating WT rows, UC is not specified.');
				END IF;
				/*
				** Following portion of the code is commented
				** because of a bug in db (2596577).
				*/
				/*
				FORALL i IN 1..l_WType_Dimension_List_Tab.Last
					INSERT INTO PJI_PMV_WT_DIM_TMP (ID, NAME)
					SELECT work_type_id, DECODE(p_View_BY,'WT',name,'-1')
					FROM pa_work_types_tl
					WHERE
					LANGUAGE = USERENV('LANG')
					AND work_type_id = l_WType_Dimension_List_Tab(i);
				*/
				FOR i IN 1..l_WType_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_WT_DIM_TMP (ID, NAME)
					SELECT work_type_id, DECODE(p_View_BY,'WT',name,'-1')
					FROM pa_work_types_tl
					WHERE
					LANGUAGE = USERENV('LANG')
					AND work_type_id = l_WType_Dimension_List_Tab(i);
				END LOOP;
				l_WT_Parsed_Flag:='Y';
			ELSIF l_UC_Parsed_Flag IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating WT rows, UC is specified.');
				END IF;
				/*
				** Following portion of the code is commented
				** because of a bug in db (2596577).
				*/
				/*
				FORALL i IN 1..l_WType_Dimension_List_Tab.Last
					INSERT INTO PJI_PMV_WT_DIM_TMP (ID, NAME)
					SELECT orig.work_type_id, DECODE(p_View_BY,'UC',usrx.name,'WT',orig_tl.name,'-1')
					FROM pa_work_types_tl orig_tl
					, pa_work_types_b orig
					, pji_pmv_uc_dim_tmp usrx
					WHERE
					LANGUAGE = USERENV('LANG')
					AND orig.work_type_id = l_WType_Dimension_List_Tab(i)
					AND orig.work_type_id = orig_tl.work_type_id
					AND orig.org_util_category_id = usrx.id;
				*/
				FOR i IN 1..l_WType_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_WT_DIM_TMP (ID, NAME)
					SELECT orig.work_type_id, DECODE(p_View_BY,'UC',usrx.name,'WT',orig_tl.name,'-1')
					FROM pa_work_types_tl orig_tl
					, pa_work_types_b orig
					, pji_pmv_uc_dim_tmp usrx
					WHERE
					LANGUAGE = USERENV('LANG')
					AND orig.work_type_id = l_WType_Dimension_List_Tab(i)
					AND orig.work_type_id = orig_tl.work_type_id
					AND orig.org_util_category_id = usrx.id;
				END LOOP;
				l_WT_Parsed_Flag:='Y';
			END IF;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Util_Category...');
		END IF;
		RETURN l_WT_Parsed_Flag;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Util_Category;

	/*
	** ----------------------------------------------------------
	** Function: Convert_Job_Level
	** The function inserts all the valid Job Levels specified in
	** the pmv report into a session specific temporary table.
	** The function return 'Y' if the lower level fact (job)
	** needs to be joined to.
	** ----------------------------------------------------------
	*/

	Function Convert_Job_Level(p_Job_IDS VARCHAR2 DEFAULT NULL
						, p_Job_Level_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2) RETURN VARCHAR2
	AS
	l_Job_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_JLevel_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	l_JL_Parsed_Flag		VARCHAR2(1);
	l_JB_Parsed_Flag		VARCHAR2(1):='N';
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Job_Level...','Convert_Job_Level');
		END IF;

		DELETE PJI_PMV_JB_DIM_TMP;
		DELETE PJI_PMV_JL_DIM_TMP;

		IF p_Job_Level_IDS IS NOT NULL THEN
			l_JLevel_Dimension_List_Tab:=Decode_IDS(p_Job_Level_IDS);
		ELSE
			l_JLevel_Dimension_List_Tab := NULL;
		END IF;

		IF p_Job_IDS IS NOT NULL THEN
			l_Job_Dimension_List_Tab:=Decode_IDS(p_Job_IDS);
              ELSE
			l_Job_Dimension_List_Tab := NULL;
		END IF;

		IF l_JLevel_Dimension_List_Tab IS NULL AND p_View_BY = 'JL' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('View BY JL and JL is not specified.');
			END IF;
			INSERT INTO PJI_PMV_JL_DIM_TMP (ID, NAME)
			SELECT ID, VALUE
			FROM PJI_JOB_LEVELS_V;
			l_JL_Parsed_Flag:='Y';
		ELSIF l_JLevel_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('JL is specified.');
			END IF;
			/*
			** Following portion of the code is commented
			** because of a bug in db (2596577).
			*/
			/*
			FORALL i IN 1..l_JLevel_Dimension_List_Tab.Last
				INSERT INTO PJI_PMV_JL_DIM_TMP (ID, NAME)
				SELECT ID,DECODE(p_View_By, 'JL', VALUE , '-1')
				FROM PJI_JOB_LEVELS_V
				WHERE ID = l_JLevel_Dimension_List_Tab(i);
			*/
			FOR i IN 1..l_JLevel_Dimension_List_Tab.Last LOOP
				INSERT INTO PJI_PMV_JL_DIM_TMP (ID, NAME)
				SELECT ID,DECODE(p_View_By, 'JL', VALUE , '-1')
				FROM PJI_JOB_LEVELS_V
				WHERE ID = l_JLevel_Dimension_List_Tab(i);
			END LOOP;
			l_JL_Parsed_Flag:='Y';
		END IF;


		IF l_Job_Dimension_List_Tab IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('View BY JB is not specified.');
			END IF;
			IF l_JL_Parsed_Flag IS NULL AND p_View_BY = 'JB' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating JB rows, View BY JB and JL is not specified.');
				END IF;
				INSERT INTO PJI_PMV_JB_DIM_TMP (ID, NAME)
				SELECT ID, VALUE
				FROM PJI_JOBS_V;
				l_JB_Parsed_Flag:='Y';
			ELSIF l_JL_Parsed_Flag IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating JB rows, JL is specified.');
				END IF;
				INSERT INTO PJI_PMV_JB_DIM_TMP (ID, NAME)
				SELECT ORIG.ID, DECODE(p_View_BY,'JL',USRX.NAME,'JB',ORIG.VALUE,'-1')
				FROM PJI_JOBS_V ORIG
				, PJI_PMV_JL_DIM_TMP USRX
				WHERE ORIG.JOB_LEVEL=USRX.ID;
				l_JB_Parsed_Flag:='Y';
			END IF;
		ELSIF l_Job_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('View BY JB is specified.');
			END IF;
			IF l_JL_Parsed_Flag IS NULL THEN
				Write2FWKLog('Creating JB rows, JL is not specified.');
				/*
				** Following portion of the code is commented
				** because of a bug in db (2596577).
				*/
				/*
				FORALL i IN 1..l_Job_Dimension_List_Tab.Last
					INSERT INTO PJI_PMV_JL_DIM_TMP (ID, NAME)
					SELECT ID, DECODE(p_View_BY,'JL',VALUE,'-1')
					FROM PJI_JOBS_V
					WHERE ID = l_Job_Dimension_List_Tab(i);
				*/
				FOR i IN 1..l_Job_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_JL_DIM_TMP (ID, NAME)
					SELECT ID, DECODE(p_View_BY,'JL',VALUE,'-1')
					FROM PJI_JOBS_V
					WHERE ID = l_Job_Dimension_List_Tab(i);
				END LOOP;
				l_JB_Parsed_Flag:='Y';
			ELSIF l_JL_Parsed_Flag IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Creating JB rows, JL is specified.');
				END IF;
				/*
				** Following portion of the code is commented
				** because of a bug in db (2596577).
				*/
				/*
				FORALL i IN 1..l_Job_Dimension_List_Tab.Last
					INSERT INTO PJI_PMV_JL_DIM_TMP (ID, NAME)
					SELECT ORIG.ID, DECODE(p_View_BY,'JL',USRX.NAME,'JB',ORIG.VALUE,'-1')
					FROM PJI_JOBS_V ORIG
					, PJI_PMV_JL_DIM_TMP USRX
					WHERE ORIG.ID=l_Job_Dimension_List_Tab(i)
					AND ORIG.JOB_LEVEL=USRX.ID;
				*/
				FOR i IN 1..l_Job_Dimension_List_Tab.Last LOOP
					INSERT INTO PJI_PMV_JL_DIM_TMP (ID, NAME)
					SELECT ORIG.ID, DECODE(p_View_BY,'JL',USRX.NAME,'JB',ORIG.VALUE,'-1')
					FROM PJI_JOBS_V ORIG
					, PJI_PMV_JL_DIM_TMP USRX
					WHERE ORIG.ID=l_Job_Dimension_List_Tab(i)
					AND ORIG.JOB_LEVEL=USRX.ID;
				END LOOP;
				l_JB_Parsed_Flag:='Y';
			END IF;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Job_Level...');
		END IF;

		RETURN l_JB_Parsed_Flag;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Job_Level;

    --Bug 4599990. This procedure will insert into PJI_PMV_ORGZ_DIM_TMP all the organizations in the PJI
    --reporting organization hierarchy that fall under the organization selected in the user assignment
    --of the person logged in. This is a private procedure and will be called by all the
    --convert_organization procedures in this package.
    PROCEDURE insert_user_assignment_orgz
    IS
    l_user_id            NUMBER;
    l_temp               NUMBER;
    BEGIN

        IF p_PA_DEBUG_MODE = 'Y' THEN
            Write2FWKLog('Entering insert_user_assignment_orgz...');
        END IF;
        l_user_id := fnd_global.user_id;
        INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
        SELECT sub_organization_id,
               org.name
        FROM   pji_org_denorm orgd,
               hr_all_organization_units_tl org,
               fnd_user fnd,
               per_all_assignments_f per
        WHERE org.language = USERENV('LANG')
        AND   fnd.user_id=l_user_id
        AND   fnd.employee_id=per.person_id
        AND   per.primary_flag='Y'
        AND   (SYSDATE BETWEEN per.effective_start_Date AND NVL(per.effective_end_date, SYSDATE + 1))
        AND   orgd.sub_organization_id = org.organization_id
        AND   orgd.organization_id = per.organization_id
        AND   orgd.sub_organization_level-orgd.organization_level=1;

        l_temp :=SQL%ROWCOUNT;

        IF p_PA_DEBUG_MODE = 'Y' THEN
            Write2FWKLog('Leaving insert_user_assignment_orgz . Inserted rows'||l_temp);
        END IF;

    END insert_user_assignment_orgz;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_Organization
	** The function inserts immediate sub organizations (the user
	** has access to below the selected organization) into a
	** session specific temporary table.
	** ----------------------------------------------------------
	*/

	Procedure Convert_Organization(p_Top_Organization_ID 	NUMBER
							, p_View_BY 		VARCHAR2
							, p_Top_Organization_Name OUT NOCOPY VARCHAR2)
	AS
	l_Organization_Name		  VARCHAR2(240);
	l_Security_Profile_ID	  NUMBER:=fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL');
	l_View_All_Org_Flag		  VARCHAR2(30);

    --Bug 4599990.
    l_top_organization_id     per_security_profiles.organization_id%TYPE;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Organization...','Convert_Organization (for Viewby reports)');
		END IF;

		DELETE PJI_PMV_ORGZ_DIM_TMP;


		IF p_View_BY = 'OG' THEN
			IF l_Security_Profile_ID IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Before checking if view_all_organizations_flag is set...');
				END IF;
				BEGIN
                    --Bug 4599990. Selected other relavant data from the per_security_profiles.
					SELECT view_all_organizations_flag,
                           organization_id
					INTO   l_View_All_Org_Flag,
                           l_top_organization_id
					FROM per_security_profiles
					WHERE security_profile_id = l_Security_Profile_ID;
					IF p_PA_DEBUG_MODE = 'Y' THEN
						Write2FWKLog('view_all_organizations_flag is set...');
					END IF;
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
					NULL;
				END;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After checking if view_all_organizations_flag is set...');
				END IF;
			END IF;
			IF l_View_All_Org_Flag = 'Y' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Before insert of immediate sub-org organizations (w/o security)...');
				END IF;
				INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
				SELECT sub_organization_id
				, org.name
				FROM pji_org_denorm orgd
				, hr_all_organization_units_tl org
				WHERE 1=1
				AND org.language = USERENV('LANG')
				AND orgd.sub_organization_id = org.organization_id
				AND orgd.sub_organization_level-orgd.organization_level=1
				AND orgd.organization_id = p_Top_Organization_ID;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After insert of immediate sub-org organizations (w/o security)...');
				END IF;
			ELSIF l_View_All_Org_Flag = 'N' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Before insert of immediate sub-org organizations...');
				END IF;
                --Bug 4599990. Insert  if the top org is entered for the security profile.
                IF l_top_organization_id IS NOT NULL THEN

                    INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
                    SELECT sub_organization_id
                    , org.name
                    FROM pji_org_denorm orgd
                    , per_organization_list sec
                    , hr_all_organization_units_tl org
                    WHERE 1=1
                    AND org.language = USERENV('LANG')
                    AND sec.security_profile_id = l_Security_Profile_ID
                    AND orgd.sub_organization_id = org.organization_id
                    AND orgd.sub_organization_id = sec.organization_id
                    AND orgd.organization_id = p_Top_Organization_ID
                    AND orgd.sub_organization_level-orgd.organization_level=1;

                --Bug 4599990. Insert the organizations in the hierarchy with the org selected in the
                --user assignment as top org.
                ELSE

                    insert_user_assignment_orgz;

                END IF;

				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After insert of immediate sub-org organizations...');
				END IF;
			END IF;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before selecting the organization name...');
		END IF;

		SELECT name
		INTO l_Organization_Name
		FROM hr_all_organization_units_tl
		WHERE organization_id = p_Top_Organization_ID
		AND language = USERENV('LANG');

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After selecting the organization name...');
		END IF;

		p_Top_Organization_Name:=l_Organization_Name;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before insert of current organization...');
		END IF;


        IF p_View_BY = 'OG' THEN
            INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
            VALUES (p_Top_Organization_ID, l_Organization_Name);
        ELSE
            INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
            VALUES (p_Top_Organization_ID, -1);
        END IF;


		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After insert of current organization...');
			Write2FWKLog('Exiting Convert_Organization...');
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Organization;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_Organization
	** The function inserts all the organizations (the user has
	** access to below the selected organization) into a session
	** specific temporary table.
	** ----------------------------------------------------------
	*/

	Procedure Convert_Organization(p_Top_Organization_ID 	NUMBER
						, p_View_BY 		VARCHAR2)
	AS
	l_Security_Profile_ID	  NUMBER:=fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL');
	l_View_All_Org_Flag		  VARCHAR2(30);
    --Bug 4599990.
    l_top_organization_id     per_security_profiles.organization_id%TYPE;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Organization...','Convert_Organization (for detail reports)');
		END IF;

		DELETE PJI_PMV_ORGZ_DIM_TMP;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before insert of rollup organization...');
		END IF;

		IF (p_View_BY = 'OG') THEN
			IF l_Security_Profile_ID IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Before checking if view_all_organizations_flag is set...');
				END IF;
				BEGIN
                    --Bug 4599990. Selected other relavant data from the per_security_profiles.
					SELECT view_all_organizations_flag,
                           organization_id
					INTO   l_View_All_Org_Flag,
                           l_top_organization_id
					FROM per_security_profiles
					WHERE security_profile_id = l_Security_Profile_ID;
					IF p_PA_DEBUG_MODE = 'Y' THEN
						Write2FWKLog('view_all_organizations_flag is set...');
					END IF;
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
					NULL;
				END;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After checking if view_all_organizations_flag is set...');
				END IF;
			END IF;

			IF l_View_All_Org_Flag = 'Y' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Before insert of all sub-org organizations (w/o security)...');
				END IF;
                INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
                SELECT subro_organization_id
                , name
                FROM hri_cs_orghro_v orgd
                , hr_all_organization_units_tl org
                , pji_system_settings pjist
                WHERE 1=1
                AND pjist.setting_id = 1
                AND orgd.org_hierarchy_version_id = pjist.org_structure_version_id
                AND orgd.sub_organization_id = org.organization_id
                AND org.language = USERENV('LANG')
                AND orgd.sup_organization_id = p_Top_Organization_ID
                AND orgd.sub_org_absolute_level-orgd.sup_org_absolute_level=1;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After insert of all sub-org organizations (w/o security)...');
				END IF;
			ELSIF l_View_All_Org_Flag = 'N' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Before insert of all sub-org organizations...');
				END IF;

                --Bug 4599990. Insert  if the top org is entered for the security profile.
                IF l_top_organization_id IS NOT NULL THEN

                    INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
                    SELECT subro_organization_id
                    , name
                    FROM hri_cs_orghro_v orgd
                    , hr_all_organization_units_tl org
                    , per_organization_list sec
                    , pji_system_settings pjist
                    WHERE 1=1
                    AND pjist.setting_id = 1
                    AND sec.security_profile_id = l_Security_Profile_ID
                    AND orgd.subro_organization_id = sec.organization_id
                    AND orgd.org_hierarchy_version_id = pjist.org_structure_version_id
                    AND orgd.sub_organization_id = org.organization_id
                    AND org.language = USERENV('LANG')
                    AND orgd.sup_organization_id = p_Top_Organization_ID
                    AND orgd.sub_org_absolute_level-orgd.sup_org_absolute_level=1;

                --Bug 4599990. Insert the organizations in the hierarchy with the org selected in the
                --user assignment as top org.
                ELSE

                    insert_user_assignment_orgz;

                END IF;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After insert of all sub-org organizations...');
				END IF;
			END IF;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After insert of rollup organization...');
				Write2FWKLog('Before insert of current organization...');
			END IF;


            INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
            SELECT organization_id, name
            FROM hr_all_organization_units_tl
            WHERE organization_id = p_Top_Organization_ID
            AND language = USERENV('LANG');

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After insert of current organization...');
			END IF;
		ELSE
			INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
			VALUES (p_Top_Organization_ID,'-1');
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After insert of rollup organization...');
			END IF;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Organization...');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Organization;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_Organization
	** The function inserts all the organizations (the user has
	** access to) below the selected organization into a session
	** specific temporary table. Provided for facilitating
      ** discoverer reporting.
	** ----------------------------------------------------------
	*/

	Procedure Convert_Organization(p_Top_Organization_ID	NUMBER DEFAULT NULL)
	AS
	l_Security_Profile_ID	  NUMBER:=fnd_profile.value('PJI_SECURITY_PROFILE_LEVEL');
	l_View_All_Org_Flag		  VARCHAR2(30);
	l_Top_Organization_ID	  NUMBER:=p_Top_Organization_ID;

    --Bug 4599990.
    l_sec_top_org_id          per_security_profiles.organization_id%TYPE;

	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Organization...','Convert_Organization (for discover reports)');
		END IF;

		DELETE PJI_PMV_ORGZ_DIM_TMP;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before insert of all sub organizations...');
		END IF;

		IF l_Top_Organization_ID IS NULL THEN
			BEGIN
				--Bug 5086074 , passing extra parameter to check code conditionally for discoverer implementation
				--PJI_PMV_DFLT_PARAMS_PVT.InitEnvironment;
				--l_Top_Organization_ID:=PJI_PMV_DFLT_PARAMS_PVT.Derive_Organization_ID;
				PJI_PMV_DFLT_PARAMS_PVT.InitEnvironment('ConvertOrg');
				l_Top_Organization_ID:=PJI_PMV_DFLT_PARAMS_PVT.Derive_Organization_ID('ConvertOrg');
			END;
		END IF;
		IF l_Security_Profile_ID IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Before checking if view_all_organizations_flag is set...');
			END IF;
			BEGIN
                --Bug 4599990.Selected other relavant data from the per_security_profiles.
                SELECT view_all_organizations_flag,
                       organization_id
                INTO   l_View_All_Org_Flag,
                       l_sec_top_org_id
                FROM per_security_profiles
                WHERE security_profile_id = l_Security_Profile_ID;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('view_all_organizations_flag is set...');
				END IF;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
				NULL;
			END;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After checking if view_all_organizations_flag is set...');
			END IF;
		END IF;

		IF l_View_All_Org_Flag = 'Y' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Before insert of all sub-org organizations (w/o security)...');
			END IF;
			INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
			SELECT  org.organization_id, org.name
			FROM pji_org_denorm denorm
			, hr_all_organization_units_tl org
			WHERE
			denorm.organization_id = l_Top_Organization_ID
			AND org.organization_id = denorm.sub_organization_id
			AND org.language = USERENV('LANG');

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After insert of all sub-org organizations (w/o security)...');
			END IF;
		ELSIF l_View_All_Org_Flag = 'N' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Before insert of all sub-org organizations...');
			END IF;

            --Bug 4599990. Insert  if the top org is entered for the security profile.
            IF l_sec_top_org_id IS NOT NULL  THEN

                INSERT INTO PJI_PMV_ORGZ_DIM_TMP (ID, NAME)
                SELECT  org.organization_id, org.name
                FROM pji_org_denorm denorm
                , hr_all_organization_units_tl org
                , per_organization_list seclist
                WHERE
                denorm.organization_id = l_Top_Organization_ID
                AND org.organization_id = denorm.sub_organization_id
                AND seclist.security_profile_id = l_Security_Profile_ID
                AND seclist.organization_id = denorm.sub_organization_id
                AND org.language = USERENV('LANG');

            --Bug 4599990. Insert the organizations in the hierarchy with the org selected in the
            --user assignment as top org.
            ELSE

                insert_user_assignment_orgz;

            END IF;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After insert of all sub-org organizations...');
			END IF;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After insert of sub organizations...');
			Write2FWKLog('Exiting Convert_Organization...');
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Organization;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_Operating_Unit
	** The function inserts all the operating units (the user has
	** access to) into a session specific temporary table.
	** Additionally this procedure also caches the calender_id's
	** for the selected operating unit. These caches values are
	** used the convert time apis further.
	** This makes it imperative that this api call should always
	** precede the call to the Convert_Time API's.
	** ----------------------------------------------------------
	*/

	Procedure Convert_Operating_Unit(p_Operating_Unit_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2)
	AS
	l_Security_Profile_ID	NUMBER:=fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL');
	l_View_All_Org_Flag		VARCHAR2(30);
	l_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Operating_Unit...','Convert_Operating_Unit');
		END IF;

		/*
		** Unconditionally reset the values of the global
		** variables because the Convert_Time API's use
		** these cached values to populate the table.
		*/
		G_GL_Calendar_ID:=NULL;
		G_PA_Calendar_ID:=NULL;

		DELETE PJI_PMV_ORG_DIM_TMP;

		IF p_Operating_Unit_IDS IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('OU is Specified.');
			END IF;
			l_Dimension_List_Tab:=Decode_IDS(p_Operating_Unit_IDS);
			IF l_Dimension_List_Tab.COUNT > 0 THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Caching calendar information.');
				END IF;
				SELECT gl_calendar_id
				, pa_calendar_id
				INTO
				G_GL_Calendar_ID
				, G_PA_Calendar_ID
				FROM PJI_ORG_EXTR_INFO
				WHERE org_id = l_Dimension_List_Tab(1);
			END IF;
		ELSE
			l_Dimension_List_Tab := NULL;
		END IF;


		IF l_Security_Profile_ID IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Before checking if view_all_organizations_flag is set...');
			END IF;
			BEGIN
				SELECT view_all_organizations_flag
				INTO l_View_All_Org_Flag
				FROM per_security_profiles
				WHERE security_profile_id = l_Security_Profile_ID;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('view_all_organizations_flag is set...');
				END IF;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
				NULL;
			END;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After checking if view_all_organizations_flag is set...');
			END IF;
		END IF;

		IF l_Dimension_List_Tab IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('OU Array is empty.');
			END IF;
			IF l_View_All_Org_Flag = 'Y' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Before insert of operating units (w/o security)...');
				END IF;
				INSERT INTO PJI_PMV_ORG_DIM_TMP (ID, NAME)
				SELECT paimp.org_id
				, decode(p_View_By,'OU',org.name,'-1')
				FROM pa_implementations_all paimp
				, hr_all_organization_units_tl org
				WHERE 1=1
				AND org.language = USERENV('LANG')
				AND paimp.org_id = org.organization_id;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After insert of operating units (w/o security)...');
				END IF;
			ELSIF l_View_All_Org_Flag = 'N' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Before insert of operating units...');
				END IF;
				INSERT INTO PJI_PMV_ORG_DIM_TMP (ID, NAME)
				SELECT paimp.org_id
				, decode(p_View_By,'OU',org.name,'-1')
				FROM pa_implementations_all paimp
				, hr_all_organization_units_tl org
				, per_organization_list sec
				WHERE 1=1
				AND org.language = USERENV('LANG')
		            AND sec.organization_id= paimp.org_id
		            AND sec.security_profile_id = l_Security_Profile_ID
				AND paimp.org_id = org.organization_id;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After insert of operating units...');
				END IF;
			END IF;
		ELSIF l_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('OU Array is not empty.');
			END IF;
			/*
			** Following portion of the code is commented
			** because of a bug in db (2596577).
			*/
			/*
			FORALL i IN 1..l_Dimension_List_Tab.Last
				INSERT INTO PJI_PMV_ORG_DIM_TMP (ID, NAME)
				SELECT organization_id, DECODE(p_View_BY,'OU',name,'-1')
				FROM hr_all_organization_units_tl
				WHERE
				organization_id=l_Dimension_List_Tab(i)
				AND language = USERENV('LANG');
			*/
			FOR i IN 1..l_Dimension_List_Tab.Last LOOP
				INSERT INTO PJI_PMV_ORG_DIM_TMP (ID, NAME)
				SELECT organization_id, DECODE(p_View_BY,'OU',name,'-1')
				FROM hr_all_organization_units_tl
				WHERE
				organization_id=l_Dimension_List_Tab(i)
				AND language = USERENV('LANG');
			END LOOP;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Operating_Unit...');
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Operating_Unit;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_Project
	** The function inserts all the projects the user has selected
	** as parameters in the pmv report to a session specific
	** temporary table.
	** ----------------------------------------------------------
	*/

	Procedure Convert_Project(p_Project_IDS VARCHAR2 DEFAULT NULL
						, p_View_BY VARCHAR2)
	AS
	l_Dimension_List_Tab 	SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Project...','Convert_Project');
		END IF;

		DELETE PJI_PMV_PRJ_DIM_TMP;

		IF p_Project_IDS IS NOT NULL THEN
			l_Dimension_List_Tab:=Decode_IDS(p_Project_IDS);
		ELSE
			l_Dimension_List_Tab := NULL;
		END IF;

		/*
		** Commented the below portion of code till
		** decision has been made to support the
		** projects in the context of class category
		** and class codes.
		*/
		/*
		IF l_Dimension_List_Tab IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating ALL PJs, PJ array is empty');
			END IF;
			INSERT INTO PJI_PMV_PRJ_DIM_TMP (ID, NAME)
			SELECT ID, DECODE(p_View_BY,'PJ',VALUE,'-1')
			FROM PJI_PROJECTS_V;
		*/
		IF l_Dimension_List_Tab IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating Selected PJs, PJ array is not empty');
			END IF;
			/*
			** Following portion of the code is commented
			** because of a bug in db (2596577).
			*/
			/*
			FORALL i IN 1..l_Dimension_List_Tab.Last
				INSERT INTO PJI_PMV_PRJ_DIM_TMP (ID, NAME)
				SELECT ID, DECODE(p_View_BY,'OU',VALUE,'-1')
				FROM PJI_PROJECTS_V
				WHERE
				ID=l_Dimension_List_Tab(i);
			*/
			FOR i IN 1..l_Dimension_List_Tab.Last LOOP
				INSERT INTO PJI_PMV_PRJ_DIM_TMP (ID, NAME)
				SELECT ID, DECODE(p_View_BY,'OU',VALUE,'-1')
				FROM PJI_PROJECTS_V
				WHERE
				ID=l_Dimension_List_Tab(i);
			END LOOP;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Project...');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Project;

	/*
	** Conversion TIME API's Section.
	** =========================
	** The time API's .. to write the comments here
	*/

	/*
	** Convert_Time API's for Non View BY TIME
	*/

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_NViewBY_AS_OF_DATE
	** The procedure creates time records based on an as of date
	** when the view by dimension is not time. The API caters
	** to additional logic based on following parameters:
	** Full Period Flag: If the flag is passed as 'Y', the API
	** creates additional time records for accomodating full
	** period amounts for reporting budget data.
	** Parse Prior: If the flag is passed as 'Y', the API stamps
	** prior_id in the time tables.
	** Calendar ID: Specifies the calendar id for fiscal time
	** periods.
	** Default Period Name: User defined constants to be inserted
	** into name column of the time temporary table.
	** Default Period ID: User defined constants to be inserted
	** into order_by_id column of the time temporary table.
	** ----------------------------------------------------------
	*/

	Procedure Convert_NViewBY_AS_OF_DATE(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL
							, p_Full_Period_Flag	VARCHAR2 DEFAULT NULL
							, p_Calendar_ID         NUMBER   DEFAULT NULL
							, p_Default_Period_Name VARCHAR2 DEFAULT NULL
							, p_Default_Period_ID   NUMBER   DEFAULT NULL)
	IS
	l_Period_Id			NUMBER;
	l_Week_ID			NUMBER;
	l_Qtr_Id			NUMBER;
	l_Year_Id			NUMBER;
	l_Prior_Period_Id		NUMBER;

	l_Default_Period_Name   VARCHAR2(30);
	l_Default_Period_ID     NUMBER;

	l_As_Of_Date		DATE:=TO_DATE(p_As_Of_Date,'j');
	l_Prior_As_Of_Date	DATE;

	l_Period_Type		VARCHAR2(150):=p_Period_Type;
	l_Level			NUMBER;
	l_IS_GL_Flag		VARCHAR2(1);

	l_Calendar_Id		NUMBER;
	l_Calendar_Type_Sum	VARCHAR2(1);
	l_Week_Start_Date		DATE;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_NViewBY_AS_OF_DATE...','Convert_NViewBY_AS_OF_DATE');
		END IF;

		IF p_Parse_Prior IS NOT NULL THEN
		BEGIN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Determining Prior Year...');
			END IF;
			-- Note: Please confirm this change with dima.
			l_Prior_As_Of_Date:=TO_DATE(Convert_AS_OF_DATE(p_As_Of_Date, p_Period_Type, 'YEARLY'),'j');
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Unable to determine Prior Year, hence defaulting it...');
			END IF;
		END;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Done with computing Prior Year...');
		END IF;

		IF p_Default_Period_Name IS NOT NULL THEN
			l_Default_Period_Name:=p_Default_Period_Name;
		ELSE
			l_Default_Period_Name:='-1';
		END IF;

		IF p_Default_Period_ID IS NOT NULL THEN
			l_Default_Period_ID:=p_Default_Period_ID;
		ELSE
			l_Default_Period_ID:=-1;
		END IF;

		IF l_Period_Type LIKE '%PA%' THEN
			IF p_Calendar_Id IS NULL THEN
				l_Calendar_Id:=G_PA_Calendar_ID;
			ELSE
				l_Calendar_Id:=p_Calendar_ID;
			END IF;
			l_IS_GL_Flag:='Y';
			l_Calendar_Type_Sum:='P';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('PA calender is selected.');
			END IF;
		ELSIF p_Period_Type LIKE '%CAL%' THEN
			IF p_Calendar_Id IS NULL THEN
				l_Calendar_Id:=G_GL_Calendar_ID;
			ELSE
				l_Calendar_Id:=p_Calendar_ID;
			END IF;
			l_IS_GL_Flag:='Y';
			l_Calendar_Type_Sum:='G';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('GL calender is selected.');
			END IF;
		ELSE
			l_Calendar_Id:=-1;
			l_Calendar_Type_Sum:='E';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Ent calender is selected.');
			END IF;
		END IF;

		IF p_Full_Period_Flag IS NOT NULL OR l_Period_Type = 'PJI_TIME_PA_PERIOD' THEN
			IF l_IS_GL_Flag IS NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Selecting from FII_TIME_DAY.');
				END IF;
				SELECT
				ent_period_id, week_id, week_start_date, ent_qtr_id, ent_year_id
				INTO
				l_Period_Id, l_Week_Id, l_Week_Start_Date, l_Qtr_Id, l_Year_Id
				FROM fii_time_day
				WHERE
				report_date = l_As_Of_Date;
			ELSE
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Selecting from FII_TIME_CAL_DAY_MV.');
				END IF;
				SELECT
				cal_period_id, cal_qtr_id, cal_year_id
				INTO
				l_Period_Id, l_Qtr_Id, l_Year_Id
				FROM fii_time_cal_day_mv
				WHERE
				report_date = l_As_Of_Date
				AND calendar_id = l_Calendar_Id;
			END IF;
		END IF;

		IF p_Period_Type = 'PJI_TIME_PA_PERIOD' AND p_Parse_Prior = 'Y' AND l_Prior_As_Of_Date IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Selecting Prior Period ID from FII_TIME_CAL_DAY_MV for PA Period Type.');
			END IF;

			SELECT cal_period_id
			INTO l_Prior_Period_Id
			FROM fii_time_cal_day_mv
			WHERE 1 = 1
			AND report_date = l_Prior_As_Of_Date
			AND calendar_id = l_Calendar_Id;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done selecting Prior Period ID from FII_TIME_CAL_DAY_MV for PA Period Type.');
			END IF;
		END IF;

		CASE p_Period_Type
			WHEN	'ITD' THEN l_Level:=1143;
			WHEN	'FII_TIME_ENT_YEAR' THEN l_Level:=119;
			WHEN	'FII_TIME_CAL_YEAR' THEN l_Level:=119;
			WHEN	'FII_TIME_ENT_QTR' THEN l_Level:=55;
			WHEN	'FII_TIME_CAL_QTR' THEN l_Level:=55;
			WHEN	'FII_TIME_ENT_PERIOD' THEN l_Level:=23;
			WHEN	'FII_TIME_CAL_PERIOD' THEN l_Level:=23;
			WHEN	'PJI_TIME_PA_PERIOD' THEN l_Level:=23;
			WHEN	'FII_TIME_WEEK' THEN l_Level:=11;
			WHEN	'FII_ROLLING_WEEK' THEN l_Level:=0;
			ELSE	NULL;
		END CASE;

		IF p_Period_Type <> 'PJI_TIME_PA_PERIOD' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating records for period types other than PA Period.');
			END IF;

			IF l_IS_GL_Flag IS NOT NULL THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT time_id, l_Default_Period_Name, l_Default_Period_ID, period_type_id, 1 , calendar_type
				FROM fii_time_cal_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,l_Level) = record_type_id
				AND calendar_id = l_Calendar_Id;
			ELSE
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT time_id, l_Default_Period_Name, l_Default_Period_ID, period_type_id, 1 , calendar_type
				FROM fii_time_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,l_Level) = record_type_id
				AND calendar_id = l_Calendar_Id;
			END IF;

			IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Generating prior id records for period types other than PA Period.');
				END IF;
				IF l_IS_GL_Flag IS NOT NULL THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT time_id, l_Default_Period_Name, l_Default_Period_ID, period_type_id, 1, calendar_type
					FROM fii_time_cal_rpt_struct
					WHERE report_date = l_Prior_As_Of_Date
					AND bitand(record_type_id,l_Level) = record_type_id
					AND calendar_id = l_Calendar_Id;
				ELSE
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT time_id, l_Default_Period_Name, l_Default_Period_ID, period_type_id, 1, calendar_type
					FROM fii_time_rpt_struct
					WHERE report_date = l_Prior_As_Of_Date
					AND bitand(record_type_id,l_Level) = record_type_id
					AND calendar_id = l_Calendar_Id;
				END IF;
			END IF;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done generating records for period types other than PA Period.');
			END IF;
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating records for PA Period period type.');
			END IF;

			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
			SELECT report_date_julian
			, l_Default_Period_Name, l_Default_Period_ID, 1, 1, 'P' FROM fii_time_cal_day_mv
			WHERE cal_period_id = l_Period_Id
			AND calendar_id = l_Calendar_Id
			AND report_date<=l_As_Of_Date;

			IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN

				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Generating prior id records for PA Period period type.');
				END IF;

				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT report_date_julian
				,l_Default_Period_Name, l_Default_Period_ID, 1, 1, 'P' FROM fii_time_cal_day_mv
				WHERE cal_period_id = l_Prior_Period_Id
				AND calendar_id = l_Calendar_Id
				AND report_date<=l_Prior_As_Of_Date;

			END IF;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done generating records for PA Period period type.');
			END IF;
		END IF;
		IF p_Full_Period_Flag IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Full Period Flag is set.');
			END IF;
			IF l_Level <> 0 THEN
				CASE l_Level
				WHEN 119 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					VALUES (l_Year_ID, l_Default_Period_Name, l_Default_Period_ID, 2, 128, l_Calendar_Type_Sum);
				WHEN 55 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					VALUES (l_Qtr_ID, l_Default_Period_Name, l_Default_Period_ID, 2, 64, l_Calendar_Type_Sum);
				WHEN 23 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					VALUES (l_Period_ID, l_Default_Period_Name, l_Default_Period_ID, 2, 32, l_Calendar_Type_Sum);
				WHEN 11 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					VALUES (l_Week_ID,l_Default_Period_Name, l_Default_Period_ID, 2, 16, 'E');
				END CASE;

				IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN
					CASE l_Level
					WHEN 119 THEN
						INSERT INTO PJI_PMV_TIME_DIM_TMP
						(PRIOR_ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
						VALUES (
						SUBSTR(LPAD(l_Year_ID,7,'0'),1,3)
						||TO_CHAR(SUBSTR(LPAD(l_Year_ID,7,'0'),4,4)-1)
						, l_Default_Period_Name, l_Default_Period_ID, 2, 128, l_Calendar_Type_Sum);
					WHEN 55 THEN
						INSERT INTO PJI_PMV_TIME_DIM_TMP
						(PRIOR_ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
						VALUES (
						SUBSTR(LPAD(l_Qtr_ID,8,'0'),1,3)
						||TO_CHAR(SUBSTR(LPAD(l_Qtr_ID,8,'0'),4,4)-1)
						||SUBSTR(LPAD(l_Qtr_ID,8,'0'),8)
						, l_Default_Period_Name, l_Default_Period_ID, 2, 64, l_Calendar_Type_Sum);
					WHEN 23 THEN
						INSERT INTO PJI_PMV_TIME_DIM_TMP
						(PRIOR_ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
						VALUES (
						SUBSTR(LPAD(l_Period_ID,10,'0'),1,3)
						||TO_CHAR(SUBSTR(LPAD(l_Period_ID,10,'0'),4,4)-1)
						||SUBSTR(LPAD(l_Period_ID,10,'0'),8)
						, l_Default_Period_Name, l_Default_Period_ID, 2, 32, l_Calendar_Type_Sum);
					WHEN 11 THEN
						INSERT INTO PJI_PMV_TIME_DIM_TMP
						(PRIOR_ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
						VALUES (
						SUBSTR(LPAD(l_Week_ID,11,'0'),1,3)
						||TO_CHAR(SUBSTR(LPAD(l_Week_ID,11,'0'),4,4)-1)
						||SUBSTR(LPAD(l_Week_ID,11,'0'),8)
						, l_Default_Period_Name, l_Default_Period_ID, 2, 16, 'E');
					END CASE;
				END IF;
			END IF;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Full Period entries created.');
			ENd IF;
			IF p_Period_Type = 'FII_ROLLING_WEEK' AND l_Level= 0 THEN
				IF G_No_Rolling_Weeks IS NULL THEN
					BEGIN
						SELECT rolling_weeks
						INTO G_No_Rolling_Weeks
						FROM pji_system_settings;
					EXCEPTION
						WHEN NO_DATA_FOUND THEN
							G_No_Rolling_Weeks:=5;
					END;
				END IF;
				l_Level:=11;
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT time_id, l_Default_Period_Name, l_Default_Period_ID, period_type_id, 1 , calendar_type
				FROM fii_time_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,l_Level) = record_type_id
				AND calendar_id = l_Calendar_Id;

				IF p_Full_Period_Flag IS NOT NULL THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					SELECT week_id, l_Default_Period_Name, l_Default_Period_ID, 2, 16, 'E' FROM fii_time_week WHERE
					week_id >= l_Week_ID
					AND end_date <= (l_Week_Start_Date)+(G_No_Rolling_Weeks*7);
				END IF;
			END IF;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_NViewBY_AS_OF_DATE...');
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			Write2FWKLog(g_SQL_Error_Msg, 3);
			RAISE;
	END Convert_NViewBY_AS_OF_DATE;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_NFViewBY_AS_OF_DATE
	** The procedure creates time records based on an as of date
	** when the view by dimension is not time. The API caters
	** to additional logic based on following parameters:
	** Full Period Flag: If the flag is passed as 'Y', the API
	** creates additional time records for accomodating full
	** period amounts for reporting budget data.
	** Parse Prior: If the flag is passed as 'Y', the API stamps
	** prior_id in the time tables.
	** Calendar ID: Specifies the calendar id for fiscal time
	** periods.
	** Default Period Name: User defined constants to be inserted
	** into name column of the time temporary table.
	** Default Period ID: User defined constants to be inserted
	** into order_by_id column of the time temporary table.
	** ----------------------------------------------------------
	*/

	Procedure Convert_NFViewBY_AS_OF_DATE(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL
							, p_Full_Period_Flag	VARCHAR2 DEFAULT NULL
							, p_Calendar_ID         NUMBER   DEFAULT NULL
							, p_Default_Period_Name	VARCHAR2 DEFAULT NULL
							, p_Default_Period_ID	NUMBER   DEFAULT NULL)
	IS
	l_Period_Id			NUMBER;
	l_Week_ID			NUMBER;
	l_Qtr_Id			NUMBER;
	l_Year_Id			NUMBER;
	l_Prior_Period_Id		NUMBER;

	l_Period_Start_Date	DATE;
	l_Qtr_Start_Date		DATE;
	l_Year_Start_Date		DATE;

	l_Period_End_Date		DATE;
	l_Qtr_End_Date		DATE;
	l_Year_End_Date		DATE;

	l_Prior_Period_Start_Date	DATE;
	l_Prior_Qtr_Start_Date		DATE;
	l_Prior_Year_Start_Date		DATE;

	l_Prior_Period_End_Date		DATE;
	l_Prior_Qtr_End_Date		DATE;
	l_Prior_Year_End_Date		DATE;

	l_Default_Period_Name	VARCHAR2(30);
	l_Default_Period_ID	NUMBER;


	l_As_Of_Date		DATE:=TO_DATE(p_As_Of_Date,'j');
	l_Prior_As_Of_Date	DATE;

	l_Period_Type		VARCHAR2(150):=p_Period_Type;
	l_Level			NUMBER;
	l_IS_GL_Flag		VARCHAR2(1);

	l_Calendar_Id		NUMBER;
	l_Calendar_Type_Sum	VARCHAR2(1);
	l_Calendar_Type_Day	VARCHAR2(1);
	l_Week_Start_Date		DATE;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_NViewBY_AS_OF_DATE...','Convert_NViewBY_AS_OF_DATE');
		END IF;

		IF p_Parse_Prior IS NOT NULL THEN
		BEGIN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Determining Prior Year...');
			END IF;
			-- Note: Please confirm this change with dima.
			l_Prior_As_Of_Date:=TO_DATE(Convert_AS_OF_DATE(p_As_Of_Date, p_Period_Type, 'YEARLY'),'j');
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Unable to determine Prior Year, hence defaulting it...');
			END IF;
		END;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Done with computing Prior Year...');
		END IF;

		IF p_Default_Period_Name IS NOT NULL THEN
			l_Default_Period_Name:=p_Default_Period_Name;
		ELSE
			l_Default_Period_Name:='-1';
		END IF;

		IF p_Default_Period_ID IS NOT NULL THEN
			l_Default_Period_ID:=p_Default_Period_ID;
		ELSE
			l_Default_Period_ID:=-1;
		END IF;

		IF l_Period_Type LIKE '%PA%' THEN
			IF p_Calendar_Id IS NULL THEN
				l_Calendar_Id:=G_PA_Calendar_ID;
			ELSE
				l_Calendar_Id:=p_Calendar_ID;
			END IF;
			l_IS_GL_Flag:='Y';
			l_Calendar_Type_Sum:='P';
			l_Calendar_Type_Day:='P';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('PA calender is selected.');
			END IF;
		ELSIF p_Period_Type LIKE '%CAL%' THEN
			IF p_Calendar_Id IS NULL THEN
				l_Calendar_Id:=G_GL_Calendar_ID;
			ELSE
				l_Calendar_Id:=p_Calendar_ID;
			END IF;
			l_IS_GL_Flag:='Y';
			l_Calendar_Type_Sum:='G';
			l_Calendar_Type_Day:='C';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('GL calender is selected.');
			END IF;
		ELSE
			l_Calendar_Id:=-1;
			l_Calendar_Type_Sum:='E';
			l_Calendar_Type_Day:='C';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Ent calender is selected.');
			END IF;
		END IF;

		IF l_IS_GL_Flag IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Selecting from FII_TIME_DAY.');
			END IF;

			SELECT period.start_date period_start_date
			,qtr.start_date qtr_start_date
			,year.start_date year_start_date
			,period.end_date period_end_date
			,qtr.end_date qtr_end_date
			,year.end_date year_end_date
			,day.ent_period_id period_id
			,day.week_id week_id
			,day.ent_qtr_id qtr_id
			,day.ent_year_id year_id
			INTO
			 l_Period_Start_Date
			,l_Qtr_Start_Date
			,l_Year_Start_Date
			,l_Period_End_Date
			,l_Qtr_End_Date
			,l_Year_End_Date
			,l_Period_Id
			,l_Week_ID
			,l_Qtr_Id
			,l_Year_Id
			FROM fii_time_day day
			, fii_time_ent_period period
			, fii_time_ent_qtr qtr
			, fii_time_ent_year year
			WHERE 1=1
			AND day.report_date = l_As_Of_Date
			AND period.ent_period_id = day.ent_period_id
			AND qtr.ent_qtr_id = day.ent_qtr_id
			AND year.ent_year_id = day.ent_year_id;
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Selecting from FII_TIME_CAL_DAY_MV.');
			END IF;
			SELECT period.start_date period_start_date
			,qtr.start_date qtr_start_date
			,year.start_date year_start_date
			,period.end_date period_end_date
			,qtr.end_date qtr_end_date
			,year.end_date year_end_date
			,day.cal_period_id period_id
			,day.cal_qtr_id qtr_id
			,day.cal_year_id year_id
			INTO
			 l_Period_Start_Date
			,l_Qtr_Start_Date
			,l_Year_Start_Date
			,l_Period_End_Date
			,l_Qtr_End_Date
			,l_Year_End_Date
			,l_Period_Id
			,l_Qtr_Id
			,l_Year_Id
			FROM fii_time_cal_day_mv day
			, fii_time_cal_period period
			, fii_time_cal_qtr qtr
			, fii_time_cal_year year
			WHERE 1=1
			AND day.report_date = l_As_Of_Date
			AND period.cal_period_id = day.cal_period_id
			AND qtr.cal_qtr_id = day.cal_qtr_id
			AND year.cal_year_id = day.cal_year_id
			AND day.calendar_id = l_Calendar_Id;
		END IF;

		IF p_Parse_Prior = 'Y' THEN
			IF l_IS_GL_Flag IS NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Selecting from FII_TIME_DAY.');
				END IF;

				SELECT period.start_date period_start_date
				,qtr.start_date qtr_start_date
				,year.start_date year_start_date
				,period.end_date period_end_date
				,qtr.end_date qtr_end_date
				,year.end_date year_end_date
				INTO
				 l_Prior_Period_Start_Date
				,l_Prior_Qtr_Start_Date
				,l_Prior_Year_Start_Date
				,l_Prior_Period_End_Date
				,l_Prior_Qtr_End_Date
				,l_Prior_Year_End_Date
				FROM fii_time_day day
				, fii_time_ent_period period
				, fii_time_ent_qtr qtr
				, fii_time_ent_year year
				WHERE 1=1
				AND day.report_date = l_Prior_As_Of_Date
				AND period.ent_period_id = day.ent_period_id
				AND qtr.ent_qtr_id = day.ent_qtr_id
				AND year.ent_year_id = day.ent_year_id;
			ELSE
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Selecting from FII_TIME_CAL_DAY_MV.');
				END IF;
				SELECT period.start_date period_start_date
				,qtr.start_date qtr_start_date
				,year.start_date year_start_date
				,period.end_date period_end_date
				,qtr.end_date qtr_end_date
				,year.end_date year_end_date
				INTO
				 l_Prior_Period_Start_Date
				,l_Prior_Qtr_Start_Date
				,l_Prior_Year_Start_Date
				,l_Prior_Period_End_Date
				,l_Prior_Qtr_End_Date
				,l_Prior_Year_End_Date
				FROM fii_time_cal_day_mv day
				, fii_time_cal_period period
				, fii_time_cal_qtr qtr
				, fii_time_cal_year year
				WHERE 1=1
				AND day.report_date = l_Prior_As_Of_Date
				AND period.cal_period_id = day.cal_period_id
				AND qtr.cal_qtr_id = day.cal_qtr_id
				AND year.cal_year_id = day.cal_year_id
				AND day.calendar_id = l_Calendar_Id;
			END IF;
		END IF;

		CASE p_Period_Type
			WHEN	'ITD' THEN l_Level:=1143;
			WHEN	'FII_TIME_ENT_YEAR' THEN l_Level:=119;
			WHEN	'FII_TIME_CAL_YEAR' THEN l_Level:=119;
			WHEN	'FII_TIME_ENT_QTR' THEN l_Level:=55;
			WHEN	'FII_TIME_CAL_QTR' THEN l_Level:=55;
			WHEN	'FII_TIME_ENT_PERIOD' THEN l_Level:=23;
			WHEN	'FII_TIME_CAL_PERIOD' THEN l_Level:=23;
			WHEN	'PJI_TIME_PA_PERIOD' THEN l_Level:=23;
			WHEN	'FII_TIME_WEEK' THEN l_Level:=11;
			ELSE	NULL;
		END CASE;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Generating records for period types other than PA Period.');
		END IF;

		IF l_IS_GL_Flag IS NOT NULL THEN
			IF (l_period_start_date <> l_as_of_date OR p_Period_Type LIKE '%PERIOD%') AND l_Level >= 11 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT report_date_julian, l_Default_Period_Name, l_Default_Period_ID, 1, 0, l_Calendar_Type_Day
				FROM fii_time_cal_day_mv
				WHERE
				report_date>=l_As_Of_Date
				AND calendar_id = l_calendar_id
				AND report_date<=l_period_end_date;
			END IF;

			IF (l_qtr_start_date <> l_as_of_date OR p_Period_Type LIKE '%QTR%') AND l_Level >= 55 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT cal_period_id, l_Default_Period_Name, l_Default_Period_ID, 32, 0, l_Calendar_Type_Sum
				FROM fii_time_cal_period
				WHERE
				start_date>=l_As_Of_Date
				AND calendar_id = l_calendar_id
				AND end_date<=l_qtr_end_date;
			END IF;

			IF (l_year_start_date <> l_as_of_date OR p_Period_Type LIKE '%YEAR%') AND l_Level >= 119 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT cal_qtr_id, l_Default_Period_Name, l_Default_Period_ID, 64, 0, l_Calendar_Type_Sum
				FROM fii_time_cal_qtr
				WHERE
				start_date>=l_As_Of_Date
				AND calendar_id = l_calendar_id
				AND end_date<=l_year_end_date;
			END IF;
			IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Generating prior id records for fiscal period types.');
				END IF;
				IF (l_prior_period_start_date <> l_prior_as_of_date OR p_Period_Type LIKE '%PERIOD%') AND l_Level >= 11 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT report_date_julian, l_Default_Period_Name, l_Default_Period_ID, 1, 0, l_Calendar_Type_Day
					FROM fii_time_cal_day_mv
					WHERE
					report_date>=l_prior_As_Of_Date
					AND calendar_id = l_calendar_id
					AND report_date<=l_prior_period_end_date;
				END IF;
					IF (l_prior_qtr_start_date <> l_prior_as_of_date OR p_Period_Type LIKE '%QTR%') AND l_Level >= 55 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT cal_period_id, l_Default_Period_Name, l_Default_Period_ID, 32, 0, l_Calendar_Type_Sum
					FROM fii_time_cal_period
					WHERE
					start_date>=l_prior_As_Of_Date
					AND calendar_id = l_calendar_id
					AND end_date<=l_prior_qtr_end_date;
				END IF;

				IF (l_prior_year_start_date <> l_prior_as_of_date OR p_Period_Type LIKE '%YEAR%') AND l_Level >= 119 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT cal_qtr_id, l_Default_Period_Name, l_Default_Period_ID, 64, 0, l_Calendar_Type_Sum
					FROM fii_time_cal_qtr
					WHERE
					start_date>=l_prior_As_Of_Date
					AND calendar_id = l_calendar_id
					AND end_date<=l_prior_year_end_date;
				END IF;
			END IF;
		ELSE
			IF (l_period_start_date <> l_as_of_date OR p_Period_Type LIKE '%PERIOD%') AND l_Level >= 11 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT report_date_julian, l_Default_Period_Name, l_Default_Period_ID, 1, 0, l_Calendar_Type_Day
				FROM fii_time_day
				WHERE
				report_date>=l_As_Of_Date
				AND report_date<=l_period_end_date;
			END IF;

			IF (l_qtr_start_date <> l_as_of_date OR p_Period_Type LIKE '%QTR%') AND l_Level >= 55 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT ent_period_id, l_Default_Period_Name, l_Default_Period_ID, 32, 0, l_Calendar_Type_Sum
				FROM fii_time_ent_period
				WHERE
				start_date>=l_As_Of_Date
				AND end_date<=l_qtr_end_date;
			END IF;

			IF (l_year_start_date <> l_as_of_date OR p_Period_Type LIKE '%YEAR%') AND l_Level >= 119 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT ent_qtr_id, l_Default_Period_Name, l_Default_Period_ID, 64, 0, l_Calendar_Type_Sum
				FROM fii_time_ent_qtr
				WHERE
				start_date>=l_As_Of_Date
				AND end_date<=l_year_end_date;
			END IF;
			IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Generating prior id records for enterprise period types.');
				END IF;
				IF (l_prior_period_start_date <> l_prior_as_of_date OR p_Period_Type LIKE '%PERIOD%') AND l_Level >= 11 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT report_date_julian, l_Default_Period_Name, l_Default_Period_ID, 1, 0, l_Calendar_Type_Day
					FROM fii_time_day
					WHERE
					report_date>=l_prior_As_Of_Date
					AND report_date<=l_Prior_period_end_date;
				END IF;

				IF (l_prior_qtr_start_date <> l_prior_as_of_date OR p_Period_Type LIKE '%QTR%') AND l_Level >= 55 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT ent_period_id, l_Default_Period_Name, l_Default_Period_ID, 32, 0, l_Calendar_Type_Sum
					FROM fii_time_ent_period
					WHERE
					start_date>=l_prior_As_Of_Date
					AND end_date<=l_prior_qtr_end_date;
				END IF;

				IF (l_Prior_year_start_date <> l_Prior_as_of_date OR p_Period_Type LIKE '%YEAR%') AND l_Level >= 119 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT ent_qtr_id, l_Default_Period_Name, l_Default_Period_ID, 64, 0, l_Calendar_Type_Sum
					FROM fii_time_ent_qtr
					WHERE
					start_date>=l_prior_As_Of_Date
					AND end_date<=l_prior_year_end_date;
				END IF;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Done generating records for for enterprise period types.');
				END IF;
			END IF;
		END IF;
		IF p_Full_Period_Flag IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Full Period Flag is set.');
			END IF;
			IF l_Level <> -1 THEN
				CASE l_Level
				WHEN 119 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					VALUES (l_Year_ID, l_Default_Period_Name, l_Default_Period_ID, 2, 128, l_Calendar_Type_Sum);
				WHEN 55 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					VALUES (l_Qtr_ID, l_Default_Period_Name, l_Default_Period_ID, 2, 64, l_Calendar_Type_Sum);
				WHEN 23 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					VALUES (l_Period_ID, l_Default_Period_Name, l_Default_Period_ID, 2, 32, l_Calendar_Type_Sum);
				WHEN 11 THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
					VALUES (l_Week_ID, l_Default_Period_Name, l_Default_Period_ID, 2, 16, 'E');
				END CASE;

				IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN
					CASE l_Level
					WHEN 119 THEN
						INSERT INTO PJI_PMV_TIME_DIM_TMP
						(PRIOR_ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
						VALUES (
						SUBSTR(LPAD(l_Year_ID,7,'0'),1,3)
						||TO_CHAR(SUBSTR(LPAD(l_Year_ID,7,'0'),4,4)-1)
						, l_Default_Period_Name, l_Default_Period_ID, 2, 128, l_Calendar_Type_Sum);
					WHEN 55 THEN
						INSERT INTO PJI_PMV_TIME_DIM_TMP
						(PRIOR_ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
						VALUES (
						SUBSTR(LPAD(l_Qtr_ID,8,'0'),1,3)
						||TO_CHAR(SUBSTR(LPAD(l_Qtr_ID,8,'0'),4,4)-1)
						||SUBSTR(LPAD(l_Qtr_ID,8,'0'),8)
						, l_Default_Period_Name, l_Default_Period_ID, 2, 64, l_Calendar_Type_Sum);
					WHEN 23 THEN
						INSERT INTO PJI_PMV_TIME_DIM_TMP
						(PRIOR_ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
						VALUES (
						SUBSTR(LPAD(l_Period_ID,10,'0'),1,3)
						||TO_CHAR(SUBSTR(LPAD(l_Period_ID,10,'0'),4,4)-1)
						||SUBSTR(LPAD(l_Period_ID,10,'0'),8)
						, l_Default_Period_Name, l_Default_Period_ID, 2, 32, l_Calendar_Type_Sum);
					WHEN 11 THEN
						INSERT INTO PJI_PMV_TIME_DIM_TMP
						(PRIOR_ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
						VALUES (
						SUBSTR(LPAD(l_Week_ID,11,'0'),1,3)
						||TO_CHAR(SUBSTR(LPAD(l_Week_ID,11,'0'),4,4)-1)
						||SUBSTR(LPAD(l_Week_ID,11,'0'),8)
						, l_Default_Period_Name, l_Default_Period_ID, 2, 16, 'E');
					END CASE;
				END IF;
			END IF;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Full Period entries created.');
			END IF;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_NFViewBY_AS_OF_DATE...');
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			Write2FWKLog(g_SQL_Error_Msg, 3);
			RAISE;
	END Convert_NFViewBY_AS_OF_DATE;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_DBI_NViewBY_AS_OF_DATE
	** The procedure creates time records for dbi reports based
	** on an as of date when the view by dimension is not time.
	** The API caters to additional logic based on following
	** parameters:
	** Full Period Flag: If the flag is passed as 'Y', the API
	** creates additional time records for accomodating full
	** period amounts for reporting budget data.
	** ----------------------------------------------------------
	*/
	Procedure Convert_DBI_NViewBY_AS_OF_DATE(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_Comparator	VARCHAR2
							, p_Full_Period_Flag	VARCHAR2 DEFAULT NULL)
	IS
	l_Period_Id			NUMBER;
	l_Week_ID			NUMBER;
	l_Qtr_Id			NUMBER;
	l_Year_Id			NUMBER;

	l_As_Of_Date		DATE:=TO_DATE(p_As_Of_Date,'j');

	l_Period_Type		VARCHAR2(150):=p_Period_Type;
	l_Level			NUMBER;
	l_IS_GL_Flag		VARCHAR2(1);


	l_Calendar_Id		NUMBER;
	l_Calendar_Type_Sum	VARCHAR2(1);
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_DBI_NViewBY_AS_OF_DATE...','Convert_DBI_NViewBY_AS_OF_DATE');
		END IF;

		IF l_Period_Type LIKE '%PA%' THEN
			l_Calendar_Id:=G_PA_Calendar_ID;
			l_IS_GL_Flag:='Y';
			l_Calendar_Type_Sum:='P';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('PA calender is selected.');
			END IF;
		ELSIF p_Period_Type LIKE '%CAL%' THEN
			l_Calendar_Id:=G_GL_Calendar_ID;
			l_IS_GL_Flag:='Y';
			l_Calendar_Type_Sum:='G';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('GL calender is selected.');
			END IF;
		ELSE
			l_Calendar_Id:=-1;
			l_Calendar_Type_Sum:='E';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Ent calender is selected.');
			END IF;
		END IF;

		IF p_Full_Period_Flag IS NOT NULL OR l_Period_Type = 'PJI_TIME_PA_PERIOD' THEN
			IF l_IS_GL_Flag IS NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Selecting from FII_TIME_DAY.');
				END IF;
				SELECT
				ent_period_id, week_id, ent_qtr_id, ent_year_id
				INTO
				l_Period_Id, l_Week_Id, l_Qtr_Id, l_Year_Id
				FROM fii_time_day
				WHERE
				report_date = l_As_Of_Date;
			ELSE
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Selecting from FII_TIME_CAL_DAY_MV.');
				END IF;
				SELECT
				cal_period_id, cal_qtr_id, cal_year_id
				INTO
				l_Period_Id, l_Qtr_Id, l_Year_Id
				FROM fii_time_cal_day_mv
				WHERE
				report_date = l_As_Of_Date
				AND calendar_id = l_Calendar_Id;
			END IF;
		END IF;

		CASE p_Period_Type
			WHEN	'FII_TIME_ENT_YEAR' THEN l_Level:=119;
			WHEN	'FII_TIME_CAL_YEAR' THEN l_Level:=119;
			WHEN	'FII_TIME_ENT_QTR' THEN l_Level:=55;
			WHEN	'FII_TIME_CAL_QTR' THEN l_Level:=55;
			WHEN	'FII_TIME_ENT_PERIOD' THEN l_Level:=23;
			WHEN	'FII_TIME_CAL_PERIOD' THEN l_Level:=23;
			WHEN	'PJI_TIME_PA_PERIOD' THEN l_Level:=23;
			WHEN	'FII_TIME_WEEK' THEN l_Level:=11;
			ELSE	NULL;
		END CASE;

		IF p_Period_Type <> 'PJI_TIME_PA_PERIOD' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating records for period types other than PA Period.');
			END IF;

			IF l_IS_GL_Flag IS NOT NULL THEN
				INSERT INTO PJI_PMV_TCMP_DIM_TMP
				(ID, NAME, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT time_id, '-1', period_type_id, 1 , calendar_type
				FROM fii_time_cal_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,l_Level) = record_type_id
				AND calendar_id = l_Calendar_Id;
			ELSE
				INSERT INTO PJI_PMV_TCMP_DIM_TMP
				(ID, NAME, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT time_id, '-1', period_type_id, 1 , calendar_type
				FROM fii_time_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,l_Level) = record_type_id
				AND calendar_id = l_Calendar_Id;
			END IF;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done generating records for period types other than PA Period.');
			END IF;
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating records for PA Period period type.');
			END IF;

			INSERT INTO PJI_PMV_TCMP_DIM_TMP
			(ID, NAME, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
			SELECT report_date_julian
			, '-1', 1, 1, 'P' FROM fii_time_cal_day_mv
			WHERE cal_period_id = l_Period_Id
			AND calendar_id = l_Calendar_Id
			AND report_date<=l_As_Of_Date;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done generating records for PA Period period type.');
			END IF;
		END IF;

		IF p_Full_Period_Flag IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Full Period Flag is set.');
			END IF;
			CASE l_Level
			WHEN 119 THEN
				INSERT INTO PJI_PMV_TCMP_DIM_TMP
				(ID, NAME, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
				VALUES (l_Year_ID, '-1', 2, 128, l_Calendar_Type_Sum);
			WHEN 55 THEN
				INSERT INTO PJI_PMV_TCMP_DIM_TMP
				(ID, NAME, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
				VALUES (l_Qtr_ID, '-1', 2, 64, l_Calendar_Type_Sum);
			WHEN 23 THEN
				INSERT INTO PJI_PMV_TCMP_DIM_TMP
				(ID, NAME, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
				VALUES (l_Period_ID, '-1', 2, 32, l_Calendar_Type_Sum);
			WHEN 11 THEN
				INSERT INTO PJI_PMV_TCMP_DIM_TMP
				(ID, NAME, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
				VALUES (l_Week_ID, '-1', 2, 16, 'E');
			END CASE;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Full Period entries created.');
			ENd IF;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_DBI_NViewBY_AS_OF_DATE...');
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_DBI_NViewBY_AS_OF_DATE;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_ITD_NViewBY_AS_OF_DATE
	** The procedure creates time records for ITD reports based
	** on an as of date when the view by dimension is not time.
	** The API caters to additional logic based on following
	** parameters:
	** Parse Prior: If the flag is passed as 'Y', the API stamps
	** prior_id in the time tables.
	** Comparator: For DBI reports this api is called again with
	** Comparator set as 'D' and a different as_of_date
	** (based on comparator choosen in the PMV report).
	** ----------------------------------------------------------
	*/
	Procedure Convert_ITD_NViewBY_AS_OF_DATE(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL
							, p_Comparator	VARCHAR2 DEFAULT 'I'
							, p_Calendar_ID	NUMBER DEFAULT NULL)
	IS
	l_Period_Id			NUMBER;
	l_Week_ID			NUMBER;
	l_Qtr_Id			NUMBER;
	l_Year_Id			NUMBER;
	l_Prior_Period_Id		NUMBER;

	l_As_Of_Date		DATE:=TO_DATE(p_As_Of_Date,'j');
	l_Prior_As_Of_Date	DATE;

	l_Period_Type		VARCHAR2(150):=p_Period_Type;
	l_Level			NUMBER;
	l_IS_GL_Flag		VARCHAR2(1);

	l_Calendar_Id		NUMBER;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_ITD_NViewBY_AS_OF_DATE...','Convert_ITD_NViewBY_AS_OF_DATE');
		END IF;

		IF p_Parse_Prior IS NOT NULL THEN
		BEGIN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Determining Prior Year...');
			END IF;
			-- Note: Please confirm this change with dima.
			l_Prior_As_Of_Date:=TO_DATE(Convert_AS_OF_DATE(p_As_Of_Date, p_Period_Type, 'YEARLY'),'j');
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Unable to determine Prior Year, hence defaulting it...');
			END IF;
		END;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Done with computing Prior Year...');
		END IF;

		IF l_Period_Type LIKE '%PA%' THEN
			l_Calendar_Id:=G_PA_Calendar_ID;
			l_IS_GL_Flag:='Y';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('PA calender is selected.');
			END IF;
		ELSIF p_Period_Type LIKE '%CAL%' THEN
			l_Calendar_Id:=G_GL_Calendar_ID;
			l_IS_GL_Flag:='Y';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('GL calender is selected.');
			END IF;
		ELSE
			l_Calendar_Id:=-1;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Ent calender is selected.');
			END IF;
		END IF;

		IF l_Period_Type = 'PJI_TIME_PA_PERIOD' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Selecting from FII_TIME_CAL_DAY_MV.');
			END IF;
			SELECT	cal_period_id
			INTO	l_Period_Id
			FROM fii_time_cal_day_mv
			WHERE
			report_date = l_As_Of_Date
			AND calendar_id = l_Calendar_Id;
		END IF;

		IF p_Period_Type = 'PJI_TIME_PA_PERIOD' AND p_Parse_Prior = 'Y' AND l_Prior_As_Of_Date IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Selecting Prior Period ID from FII_TIME_CAL_DAY_MV for PA Period Type.');
			END IF;

			SELECT cal_period_id
			INTO l_Prior_Period_Id
			FROM fii_time_cal_day_mv
			WHERE 1 = 1
			AND report_date = l_Prior_As_Of_Date
			AND calendar_id = l_Calendar_Id;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done selecting Prior Period ID from FII_TIME_CAL_DAY_MV for PA Period Type.');
			END IF;
		END IF;

		IF p_Period_Type <> 'PJI_TIME_PA_PERIOD' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating records for period types other than PA Period.');
			END IF;

			IF l_IS_GL_Flag IS NOT NULL THEN
				INSERT INTO PJI_PMV_ITD_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, COMPARATOR_TYPE, CALENDAR_TYPE)
				SELECT time_id, '-1' , '-1' , period_type_id, p_Comparator, calendar_type
				FROM fii_time_cal_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,1143) = record_type_id
				AND calendar_id = l_Calendar_Id;
			ELSE
				INSERT INTO PJI_PMV_ITD_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, COMPARATOR_TYPE, CALENDAR_TYPE)
				SELECT time_id, '-1' , '-1' , period_type_id, p_Comparator, calendar_type
				FROM fii_time_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,1143) = record_type_id
				AND calendar_id = l_Calendar_Id;
			END IF;

			IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Generating prior id records for period types other than PA Period.');
				END IF;
				IF l_IS_GL_Flag IS NOT NULL THEN
					INSERT INTO PJI_PMV_ITD_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, COMPARATOR_TYPE, CALENDAR_TYPE)
					SELECT time_id, '-1', '-1', period_type_id, p_Comparator, calendar_type
					FROM fii_time_cal_rpt_struct
					WHERE report_date = l_Prior_As_Of_Date
					AND bitand(record_type_id,1143) = record_type_id
					AND calendar_id = l_Calendar_Id;
				ELSE
					INSERT INTO PJI_PMV_ITD_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, COMPARATOR_TYPE, CALENDAR_TYPE)
					SELECT time_id, '-1', '-1', period_type_id, p_Comparator, calendar_type
					FROM fii_time_rpt_struct
					WHERE report_date = l_Prior_As_Of_Date
					AND bitand(record_type_id,1143) = record_type_id
					AND calendar_id = l_Calendar_Id;
				END IF;
			END IF;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done generating records for period types other than PA Period.');
			END IF;
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating records for PA Period period type.');
			END IF;

			INSERT INTO PJI_PMV_ITD_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, COMPARATOR_TYPE, CALENDAR_TYPE)
			SELECT report_date_julian
			, '-1', '-1', 1, p_Comparator, 'P' FROM fii_time_cal_day_mv
			WHERE cal_period_id = l_Period_Id
			AND calendar_id = l_Calendar_Id
			AND report_date<=l_As_Of_Date;

			INSERT INTO PJI_PMV_ITD_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, COMPARATOR_TYPE, CALENDAR_TYPE)
			SELECT time_id, '-1', '-1', period_type_id, p_Comparator, 'P'
			FROM fii_time_cal_rpt_struct
			WHERE report_date = l_As_Of_Date
			AND bitand(record_type_id,1143) = record_type_id
			AND calendar_id = l_Calendar_Id
			AND period_type_id > 16;

			IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN

				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Generating prior id records for PA Period period type.');
				END IF;

				INSERT INTO PJI_PMV_ITD_DIM_TMP
				(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, COMPARATOR_TYPE, CALENDAR_TYPE)
				SELECT report_date_julian
				, '-1', '-1', 1, p_Comparator, 'P' FROM fii_time_cal_day_mv
				WHERE cal_period_id = l_Prior_Period_Id
				AND calendar_id = l_Calendar_Id
				AND report_date<=l_Prior_As_Of_Date;

				INSERT INTO PJI_PMV_ITD_DIM_TMP
				(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, COMPARATOR_TYPE, CALENDAR_TYPE)
				SELECT time_id, '-1', '-1', period_type_id, p_Comparator, 'P'
				FROM fii_time_cal_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,1143) = record_type_id
				AND calendar_id = l_Calendar_Id
				AND period_type_id > 16;

			END IF;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done generating records for PA Period period type.');
			END IF;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_ITD_NViewBY_AS_OF_DATE...');
		END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			NULL;
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			Write2FWKLog(g_SQL_Error_Msg, 3);
			RAISE;
	END Convert_ITD_NViewBY_AS_OF_DATE;

	/*
	** Convert_Time API's for View BY TIME
	*/

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_ViewBY_AS_OF_DATE
	** The procedure creates time records for pmv reports when
	** time is selected as the viewby dimension.
	** The API caters to additional logic based on following
	** parameters:
	** Parse Prior: If the flag is passed as 'Y', the API stamps
	** prior_id in the time tables.
	** Report Type: If a value is passed then the time records are
	** bound by year(fiscal/enterprize).
	** ----------------------------------------------------------
	*/
	Procedure Convert_ViewBY_AS_OF_DATE(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_Report_Type	VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL
							, p_Full_Period_Flag VARCHAR2 DEFAULT NULL)
	AS
	l_Start_Time		DATE;
	l_End_Time			DATE;

	l_Week_ID			NUMBER;
	l_Week_Name		VARCHAR2(150);
	l_Week_Start_Date		DATE;
	l_Period_ID			NUMBER;
	l_Period_Name		VARCHAR2(150);
	l_Period_Start_Date 	DATE;
	l_Qtr_ID			NUMBER;
	l_Qtr_Name		VARCHAR2(150);
	l_Qtr_Start_Date 		DATE;
	l_Year_ID			NUMBER;
	l_Year_Name		VARCHAR2(150);
	l_Year_Start_Date 	DATE;

	l_Level			NUMBER;
	l_Def_View_BY		VARCHAR2(150);
	l_Def_View_BY_ID		NUMBER;
	l_Calendar_ID		NUMBER;
	l_Calendar_Type_Sum	VARCHAR2(1);


	l_IS_GL_Flag		VARCHAR2(1);

	l_Period_Type		VARCHAR2(150):=p_Period_Type;
	l_As_Of_Date		DATE := TO_DATE(p_As_Of_Date,'j');
	l_Prior_As_Of_Date	DATE;
	l_Prior_Period_Id		NUMBER;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_ViewBY_AS_OF_DATE...','Convert_ViewBY_AS_OF_DATE');
		END IF;

		IF p_Parse_Prior IS NOT NULL THEN
		BEGIN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Determining Prior Year...');
			END IF;
			-- Note: Please confirm this change with dima.
			l_Prior_As_Of_Date:=TO_DATE(Convert_AS_OF_DATE(p_As_Of_Date, l_Period_Type, 'YEARLY'),'j');
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Unable to determine Prior Year, hence defaulting it...');
			END IF;
		END;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Done with computing as of date for Prior Year...');
		END IF;

		IF l_Period_Type LIKE '%PA%' THEN
			l_Calendar_Id:=G_PA_Calendar_ID;
			l_IS_GL_Flag:='Y';
			l_Calendar_Type_Sum:='P';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('PA calender is selected.');
			END IF;
		ELSIF l_Period_Type LIKE '%CAL%' THEN
			l_Calendar_Id:=G_GL_Calendar_ID;
			l_IS_GL_Flag:='Y';
			l_Calendar_Type_Sum:='G';
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('GL calender is selected.');
			END IF;
		ELSE
			l_Calendar_Type_Sum:='E';
			l_Calendar_Id:=-1;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Ent calender is selected.');
			END IF;
		END IF;

		IF l_IS_GL_Flag IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Selecting from FII_TIME_DAY.');
			END IF;
			SELECT
				day.ent_period_id
				, prd.name
				, day.ent_period_start_date
				, day.week_id
				, wek.name
				, day.week_start_date
				, day.ent_qtr_id
				, qtr.name
				, day.ent_qtr_start_date
				, day.ent_year_id
				, yer.name
				, day.ent_year_start_date
			INTO
				l_Period_Id
				, l_Period_Name
				, l_Period_Start_Date
				, l_Week_Id
				, l_Week_Name
				, l_Week_Start_Date
				, l_Qtr_Id
				, l_Qtr_Name
				, l_Qtr_Start_Date
				, l_Year_Id
				, l_Year_Name
				, l_Year_Start_Date
			FROM fii_time_day day
				, fii_time_week wek
				, fii_time_ent_period prd
				, fii_time_ent_qtr qtr
				, fii_time_ent_year yer
			WHERE
				report_date = l_As_Of_Date
				AND wek.week_id = day.week_id
				AND prd.ent_period_id = day.ent_period_id
				AND qtr.ent_qtr_id = day.ent_qtr_id
				AND yer.ent_year_id = day.ent_year_id;
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Selecting from FII_TIME_CAL_DAY_MV.');
			END IF;
			SELECT
				day.cal_period_id
				, prd.name
				, day.cal_period_start_date
				, day.cal_qtr_id
				, qtr.name
				, day.cal_qtr_start_date
				, day.cal_year_id
				, yer.name
				, day.cal_year_start_date
			INTO
				l_Period_Id
				, l_Period_Name
				, l_Period_Start_Date
				, l_Qtr_Id
				, l_Qtr_Name
				, l_Qtr_Start_Date
				, l_Year_Id
				, l_Year_Name
				, l_Year_Start_Date
			FROM fii_time_cal_day_mv day
				, fii_time_cal_period prd
				, fii_time_cal_qtr qtr
				, fii_time_cal_year yer
			WHERE
				report_date = l_As_Of_Date
				AND day.calendar_id = l_Calendar_Id
				AND prd.cal_period_id = day.cal_period_id
				AND qtr.cal_qtr_id = day.cal_qtr_id
				AND yer.cal_year_id = day.cal_year_id;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Done selecting from FII_TIME_???.');
		END IF;

		IF p_Report_Type IS NOT NULL THEN
			l_End_Time:=l_Year_Start_Date-1;
		ELSIF l_Period_Type = 'FII_TIME_ENT_YEAR' OR l_Period_Type = 'FII_TIME_CAL_YEAR' THEN
			l_End_Time:=TO_DATE(Convert_AS_OF_DATE(Convert_AS_OF_DATE(p_As_Of_Date, l_Period_Type, 'YEARLY'), l_Period_Type, 'YEARLY'),'j');
			IF l_End_Time IS NULL THEN
				l_End_Time:=PJI_UTILS.GET_EXTRACTION_START_DATE;
			END IF;
		ELSIF l_Prior_As_Of_Date IS NOT NULL THEN
			l_End_Time:=l_Prior_As_Of_Date;
		ELSE
			l_End_Time:=TO_DATE(Convert_AS_OF_DATE(p_As_Of_Date, l_Period_Type, 'YEARLY'),'j');
			IF l_End_Time IS NULL THEN
				l_End_Time:=PJI_UTILS.GET_EXTRACTION_START_DATE;
			END IF;
		END IF;

		IF ( l_Period_Type = 'FII_TIME_WEEK' OR l_Period_Type = 'PJI_TIME_PA_PERIOD') AND l_End_Time < (l_As_Of_Date)-91 THEN
			l_End_Time:=(l_As_Of_Date)-91;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Determining the l_Level, l_Start_Time, l_Def_View_BY, l_Def_View_BY_ID.');
		END IF;

		CASE l_Period_Type
		WHEN	'FII_TIME_ENT_YEAR' THEN
			l_Level:=119;
			l_Start_Time:=l_Year_Start_Date;
			l_Def_View_BY:=l_Year_Name;
			l_Def_View_BY_ID:=l_Year_ID;
		WHEN	'FII_TIME_CAL_YEAR' THEN
			l_Level:=119;
			l_Start_Time:=l_Year_Start_Date;
			l_Def_View_BY:=l_Year_Name;
			l_Def_View_BY_ID:=l_Year_ID;
		WHEN	'FII_TIME_ENT_QTR' THEN
			l_Level:=55;
			l_Start_Time:=l_Qtr_Start_Date;
			l_Def_View_BY:=l_Qtr_Name;
			l_Def_View_BY_ID:=l_Qtr_ID;
		WHEN	'FII_TIME_CAL_QTR' THEN
			l_Level:=55;
			l_Start_Time:=l_Qtr_Start_Date;
			l_Def_View_BY:=l_Qtr_Name;
			l_Def_View_BY_ID:=l_Qtr_ID;
		WHEN	'FII_TIME_ENT_PERIOD' THEN
			l_Level:=23;
			l_Start_Time:=l_Period_Start_Date;
			l_Def_View_BY:=l_Period_Name;
			l_Def_View_BY_ID:=l_Period_ID;
		WHEN	'FII_TIME_CAL_PERIOD' THEN
			l_Level:=23;
			l_Start_Time:=l_Period_Start_Date;
			l_Def_View_BY:=l_Period_Name;
			l_Def_View_BY_ID:=l_Period_ID;
		WHEN	'PJI_TIME_PA_PERIOD' THEN
			l_Level:=23;
			l_Start_Time:=l_Period_Start_Date;
			l_Def_View_BY:=l_Period_Name;
			l_Def_View_BY_ID:=l_Period_ID;
		WHEN	'FII_TIME_WEEK' THEN l_Level:=11;
			l_Start_Time:=l_Week_Start_Date;
			l_Def_View_BY:=l_Week_Name;
			l_Def_View_BY_ID:=l_Week_ID;
		ELSE	NULL;
		END CASE;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('l_Level : '||l_Level);
			Write2FWKLog('l_Start_Time : '||l_Start_Time);
			Write2FWKLog('l_End_Time : '||l_End_Time);
			Write2FWKLog('l_Def_View_BY : '||l_Def_View_BY);
			Write2FWKLog('l_Def_View_BY_ID : '||l_Def_View_BY_ID);
		END IF;

		IF l_Period_Type <> 'PJI_TIME_PA_PERIOD' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating records for period types other than PA Period.');
			END IF;

			IF l_IS_GL_Flag IS NOT NULL THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT time_id, l_Def_View_BY, l_Def_View_BY_ID, period_type_id, 1 , calendar_type
				FROM fii_time_cal_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,l_Level) = record_type_id
				AND calendar_id = l_Calendar_Id;
			ELSE
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT time_id, l_Def_View_BY, l_Def_View_BY_ID, period_type_id, 1 , calendar_type
				FROM fii_time_rpt_struct
				WHERE report_date = l_As_Of_Date
				AND bitand(record_type_id,l_Level) = record_type_id
				AND calendar_id = l_Calendar_Id;
			END IF;

			IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Generating prior id records for period types other than PA Period.');
				END IF;
				IF l_IS_GL_Flag IS NOT NULL THEN
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT time_id, l_Def_View_BY, l_Def_View_BY_ID, period_type_id, 1, calendar_type
					FROM fii_time_cal_rpt_struct
					WHERE report_date = l_Prior_As_Of_Date
					AND bitand(record_type_id,l_Level) = record_type_id
					AND calendar_id = l_Calendar_Id;
				ELSE
					INSERT INTO PJI_PMV_TIME_DIM_TMP
					(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
					SELECT time_id, l_Def_View_BY, l_Def_View_BY_ID, period_type_id, 1, calendar_type
					FROM fii_time_rpt_struct
					WHERE report_date = l_Prior_As_Of_Date
					AND bitand(record_type_id,l_Level) = record_type_id
					AND calendar_id = l_Calendar_Id;
				END IF;
			END IF;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done generating records for period types other than PA Period.');
			END IF;
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating records for PA Period period type.');
			END IF;

			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
			SELECT report_date_julian
			, l_Def_View_BY, l_Def_View_BY_ID, 1, 1, 'P' FROM fii_time_cal_day_mv
			WHERE cal_period_id = l_Period_Id
			AND calendar_id = l_Calendar_Id
			AND report_date<=l_As_Of_Date;

			IF p_Parse_Prior IS NOT NULL  AND l_Prior_As_Of_Date IS NOT NULL THEN

				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Generating prior id records for PA Period period type.');
				END IF;

				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT report_date_julian
				, l_Def_View_BY, l_Def_View_BY_ID, 1, 1, 'P' FROM fii_time_cal_day_mv
				WHERE cal_period_id = l_Prior_Period_Id
				AND calendar_id = l_Calendar_Id
				AND report_date<=l_Prior_As_Of_Date;

			END IF;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done generating records for PA Period period type.');
			END IF;
		END IF;

		IF p_Full_Period_Flag IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Full Period Flag is set.');
			END IF;
			CASE l_Level
			WHEN 119 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
				VALUES (l_Def_View_BY_ID, l_Def_View_BY, l_Def_View_BY_ID, 2, 128, l_Calendar_Type_Sum);
			WHEN 55 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
				VALUES (l_Def_View_BY_ID, l_Def_View_BY, l_Def_View_BY_ID, 2, 64, l_Calendar_Type_Sum);
			WHEN 23 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
				VALUES (l_Def_View_BY_ID, l_Def_View_BY, l_Def_View_BY_ID, 2, 32, l_Calendar_Type_Sum);
			WHEN 11 THEN
				INSERT INTO PJI_PMV_TIME_DIM_TMP
				(ID, NAME, ORDER_BY_ID, AMOUNT_TYPE, PERIOD_TYPE, CALENDAR_TYPE)
				VALUES (l_Def_View_BY_ID, l_Def_View_BY, l_Def_View_BY_ID, 2, 16, 'E');
			END CASE;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Full Period entries created.');
			ENd IF;
		END IF;

		CASE l_Period_Type
		WHEN	'FII_TIME_ENT_YEAR' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating time records for enterprize year.');
			END IF;
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
			SELECT ent_year_id, name, ent_year_id, 128, 'E'
			FROM fii_time_ent_year
			WHERE start_date > l_End_Time
			AND start_date < l_Start_Time;
		WHEN	'FII_TIME_ENT_QTR' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating time records for enterprize quarter.');
			END IF;
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
			SELECT ent_qtr_id, name, ent_qtr_id, 64, 'E'
			FROM fii_time_ent_qtr
			WHERE start_date > l_End_Time
			AND start_date < l_Start_Time;
		WHEN	'FII_TIME_ENT_PERIOD' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating time records for enterprize period.');
			END IF;
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
			SELECT ent_period_id, name, ent_period_id, 32, 'E'
			FROM fii_time_ent_period
			WHERE start_date > l_End_Time
			AND start_date < l_Start_Time;
		WHEN	'FII_TIME_CAL_YEAR' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating time records for fiscal year.');
			END IF;
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
			SELECT cal_year_id, name, cal_year_id, 128, 'G'
			FROM fii_time_cal_year
			WHERE start_date > l_End_Time
			AND start_date < l_Start_Time
			AND calendar_id = l_Calendar_Id;
		WHEN	'FII_TIME_CAL_QTR' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating time records for fiscal quarter.');
			END IF;
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
			SELECT cal_qtr_id, name, cal_qtr_id, 64, 'G'
			FROM fii_time_cal_qtr
			WHERE start_date > l_End_Time
			AND start_date < l_Start_Time
			AND calendar_id = l_Calendar_Id;
		WHEN	'FII_TIME_CAL_PERIOD' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating time records for fiscal period.');
			END IF;
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
			SELECT cal_period_id, name, cal_period_id, 32, 'G'
			FROM fii_time_cal_period
			WHERE start_date > l_End_Time
			AND start_date < l_Start_Time
			AND calendar_id = l_Calendar_Id;
		WHEN	'PJI_TIME_PA_PERIOD' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating time records for pa period.');
			END IF;
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
			SELECT cal_period_id, name, cal_period_id, 32, 'P'
			FROM fii_time_cal_period
			WHERE start_date > l_End_Time
			AND start_date < l_Start_Time
			AND calendar_id = l_Calendar_Id;
		WHEN	'FII_TIME_WEEK' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Creating time records for enterprize week.');
			END IF;
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
			SELECT week_id, name, week_id, 16, 'E'
			FROM fii_time_week
			WHERE start_date > l_End_Time
			AND start_date < l_Start_Time;
		END CASE;

		IF p_Parse_Prior IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Parse Prior is set.');
			END IF;
			UPDATE PJI_PMV_TIME_DIM_TMP
			SET PRIOR_ID = (CASE period_type
						WHEN 128	THEN SUBSTR(LPAD(ID,7,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,7,'0'),4,4)-1)
						WHEN 64	THEN SUBSTR(LPAD(ID,8,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,8,'0'),4,4)-1)||SUBSTR(LPAD(ID,8,'0'),8)
						WHEN 32	THEN SUBSTR(LPAD(ID,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,10,'0'),4,4)-1)||SUBSTR(LPAD(ID,10,'0'),8)
						WHEN 16	THEN SUBSTR(LPAD(ID,11,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,11,'0'),4,4)-1)||SUBSTR(LPAD(ID,11,'0'),8)
						END)
			WHERE AMOUNT_TYPE = 2
			OR AMOUNT_TYPE IS NULL;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Prior ID is updated.');
			END IF;
		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_ViewBY_AS_OF_DATE...');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_ViewBY_AS_OF_DATE;

	Procedure Convert_ITD_ViewBY_AS_OF_DATE(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL)
	AS
	l_As_Of_Date		DATE;
	l_Level			NUMBER;
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_ITD_ViewBY_AS_OF_DATE...','Convert_ITD_ViewBY_AS_OF_DATE');
			Write2FWKLog('Determining the period beyond which ITD has to be generated.');
		END IF;

		CASE p_Period_Type
		WHEN	'FII_TIME_ENT_YEAR' THEN
			l_Level:=128;
			SELECT MIN(TIME.start_date)-1
 			INTO l_As_Of_Date
			FROM
			pji_pmv_time_dim_tmp TTMP,
			fii_time_ent_year TIME
			WHERE TTMP.period_type = l_Level
			AND TTMP.id = TIME.ent_year_id;
		WHEN	'FII_TIME_CAL_YEAR' THEN
			l_Level:=128;
			SELECT MIN(TIME.start_date)-1
 			INTO l_As_Of_Date
			FROM
			pji_pmv_time_dim_tmp TTMP,
			fii_time_cal_year TIME
			WHERE TTMP.period_type = l_Level
			AND TTMP.id = TIME.cal_year_id;
		WHEN	'FII_TIME_ENT_QTR' THEN
			l_Level:=64;
			SELECT MIN(TIME.start_date)-1
 			INTO l_As_Of_Date
			FROM
			pji_pmv_time_dim_tmp TTMP,
			fii_time_ent_qtr TIME
			WHERE TTMP.period_type = l_Level
			AND TTMP.id = TIME.ent_qtr_id;
		WHEN	'FII_TIME_CAL_QTR' THEN
			l_Level:=64;
			SELECT MIN(TIME.start_date)-1
 			INTO l_As_Of_Date
			FROM
			pji_pmv_time_dim_tmp TTMP,
			fii_time_cal_qtr TIME
			WHERE TTMP.period_type = l_Level
			AND TTMP.id = TIME.cal_qtr_id;
		WHEN	'FII_TIME_ENT_PERIOD' THEN
			l_Level:=32;
			SELECT MIN(TIME.start_date)-1
 			INTO l_As_Of_Date
			FROM
			pji_pmv_time_dim_tmp TTMP,
			fii_time_ent_period TIME
			WHERE TTMP.period_type = l_Level
			AND TTMP.id = TIME.ent_period_id;
		WHEN	'FII_TIME_CAL_PERIOD' THEN
			l_Level:=32;
			SELECT MIN(TIME.start_date)-1
 			INTO l_As_Of_Date
			FROM
			pji_pmv_time_dim_tmp TTMP,
			fii_time_cal_period TIME
			WHERE TTMP.period_type = l_Level
			AND TTMP.id = TIME.cal_period_id;
		WHEN	'PJI_TIME_PA_PERIOD' THEN
			l_Level:=32;
			SELECT MIN(TIME.start_date)-1
 			INTO l_As_Of_Date
			FROM
			pji_pmv_time_dim_tmp TTMP,
			fii_time_cal_period TIME
			WHERE TTMP.period_type = l_Level
			AND TTMP.id = TIME.cal_period_id;
		WHEN	'FII_TIME_WEEK' THEN
			l_Level:=16;
	            SELECT MIN(TIME.start_date)-1
 			INTO l_As_Of_Date
	            FROM
	            pji_pmv_time_dim_tmp TTMP,
	            fii_time_week TIME
	            WHERE TTMP.period_type = l_Level
	            AND TTMP.id = TIME.week_id;
		ELSE	NULL;
		END CASE;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Done determining the period beyond which ITD has to be generated.');
			Write2FWKLog('l_Level :'||l_Level);
			Write2FWKLog('l_As_Of_Date :'||l_As_Of_Date);
			Write2FWKLog('Before Calling Convert_ITD_NViewBY_AS_OF_DATE...');
		END IF;

		Convert_ITD_NViewBY_AS_OF_DATE(p_As_Of_Date=>TO_CHAR(l_As_Of_Date,'j')
						, p_Period_Type=>p_Period_Type
						, p_Parse_Prior=>p_Parse_Prior
						, p_Comparator=>NULL
						, p_Calendar_ID=>NULL);
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After Calling Convert_ITD_NViewBY_AS_OF_DATE...');
			Write2FWKLog('Exiting Convert_ITD_ViewBY_AS_OF_DATE...');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_ITD_ViewBY_AS_OF_DATE;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_Time
	** The procedure creates time records for non as_of_date
	** based reports. Currently, this api supports only
	** availability reports.
	** ----------------------------------------------------------
	*/
	Procedure Convert_Time(p_From_Time_ID 	NUMBER
				, p_To_Time_ID 		NUMBER
				, p_Period_Type 		VARCHAR2
				, p_View_BY 		VARCHAR2
				, p_Parse_Prior		VARCHAR2 DEFAULT NULL)
	AS
	l_Hierarchy_Version_ID	NUMBER:=Get_Hierarchy_Version_ID;
	l_Calendar_Id		NUMBER;
	l_Start_Date		DATE:=TO_DATE(p_From_Time_ID,'j');
	l_End_Date			DATE:=TO_DATE(p_To_Time_ID,'j');
	l_Period_Type 		VARCHAR2(150):=p_Period_Type;
	BEGIN
		Write2FWKLog('Entering Convert_Time...','Convert_Time');

		DELETE PJI_PMV_TIME_DIM_TMP;

		IF p_Period_Type LIKE '%PA%' THEN
			l_Calendar_Id:=G_PA_Calendar_ID;
			Write2FWKLog('PA calender is selected.');
		ELSIF p_Period_Type LIKE '%CAL%' THEN
			l_Calendar_Id:=G_GL_Calendar_ID;
			Write2FWKLog('GL calender is selected.');
		END IF;

		CASE p_Period_Type
		WHEN 'FII_TIME_ENT_YEAR' THEN
			Write2FWKLog('Creating time records for enterprize year.');
			INSERT INTO PJI_PMV_TIME_DIM_TMP (ID, PRIOR_ID, NAME, PERIOD_TYPE, ORDER_BY_ID, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT ENT_YEAR_ID, NULL, DECODE(p_View_BY,'TM',NAME,'-1'), 128, ENT_YEAR_ID, NULL, 'E'
				FROM FII_TIME_ENT_YEAR
				WHERE l_Start_Date <= end_date
				AND l_End_Date >=start_date;
		WHEN 'FII_TIME_ENT_QTR' THEN
			Write2FWKLog('Creating time records for enterprize quarter.');
			INSERT INTO PJI_PMV_TIME_DIM_TMP (ID, PRIOR_ID, NAME, PERIOD_TYPE, ORDER_BY_ID, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT ENT_QTR_ID, NULL, DECODE(p_View_BY,'TM',NAME,'-1'), 64, ENT_QTR_ID, NULL, 'E'
				FROM FII_TIME_ENT_QTR
				WHERE l_Start_Date <= end_date
				AND l_End_Date >=start_date;
		WHEN 'FII_TIME_ENT_PERIOD' THEN
			Write2FWKLog('Creating time records for enterprize period.');
			INSERT INTO PJI_PMV_TIME_DIM_TMP (ID, PRIOR_ID, NAME, PERIOD_TYPE, ORDER_BY_ID, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT ENT_PERIOD_ID, NULL, DECODE(p_View_BY,'TM',NAME,'-1'), 32, ENT_PERIOD_ID, NULL, 'E'
				FROM FII_TIME_ENT_PERIOD
				WHERE l_Start_Date <= end_date
				AND l_End_Date >=start_date;
		WHEN 'FII_TIME_CAL_YEAR' THEN
			Write2FWKLog('Creating time records for fiscal year.');
			INSERT INTO PJI_PMV_TIME_DIM_TMP (ID, PRIOR_ID, NAME, PERIOD_TYPE, ORDER_BY_ID, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT CAL_YEAR_ID, NULL, DECODE(p_View_BY,'TM',NAME,'-1'), 128, CAL_YEAR_ID, NULL, 'G'
				FROM FII_TIME_CAL_YEAR
				WHERE l_Start_Date <= end_date
				AND l_End_Date >=start_date
				AND calendar_id = l_Calendar_ID;
		WHEN 'FII_TIME_CAL_QTR' THEN
			Write2FWKLog('Creating time records for fiscal quarter.');
			INSERT INTO PJI_PMV_TIME_DIM_TMP (ID, PRIOR_ID, NAME, PERIOD_TYPE, ORDER_BY_ID, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT CAL_QTR_ID, NULL, DECODE(p_View_BY,'TM',NAME,'-1'), 64, CAL_QTR_ID, NULL, 'G'
				FROM FII_TIME_CAL_QTR
				WHERE l_Start_Date <= end_date
				AND l_End_Date >=start_date
				AND calendar_id = l_Calendar_ID;
		WHEN 'FII_TIME_CAL_PERIOD' THEN
			Write2FWKLog('Creating time records for fiscal period.');
			INSERT INTO PJI_PMV_TIME_DIM_TMP (ID, PRIOR_ID, NAME, PERIOD_TYPE, ORDER_BY_ID, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT CAL_PERIOD_ID, NULL, DECODE(p_View_BY,'TM',NAME,'-1'), 32, CAL_PERIOD_ID, NULL, 'G'
				FROM FII_TIME_CAL_PERIOD
				WHERE l_Start_Date <= end_date
				AND l_End_Date >=start_date
				AND calendar_id = l_Calendar_ID;
		WHEN 'PJI_TIME_PA_PERIOD' THEN
			Write2FWKLog('Creating time records for pa period.');
			INSERT INTO PJI_PMV_TIME_DIM_TMP (ID, PRIOR_ID, NAME, PERIOD_TYPE, ORDER_BY_ID, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT CAL_PERIOD_ID, NULL, DECODE(p_View_BY,'TM',NAME,'-1'), 32, CAL_PERIOD_ID, NULL, 'G'
				FROM FII_TIME_CAL_PERIOD
				WHERE l_Start_Date <= end_date
				AND l_End_Date >=start_date
				AND calendar_id = l_Calendar_ID;
		WHEN 'FII_TIME_WEEK' THEN
			Write2FWKLog('Creating time records for week.');
			INSERT INTO PJI_PMV_TIME_DIM_TMP (ID, PRIOR_ID, NAME, PERIOD_TYPE, ORDER_BY_ID, AMOUNT_TYPE, CALENDAR_TYPE)
				SELECT WEEK_ID, NULL, DECODE(p_View_BY,'TM',NAME,'-1'), 16, WEEK_ID, NULL, 'E'
				FROM FII_TIME_WEEK
				WHERE l_Start_Date <= end_date
				AND l_End_Date >=start_date;
		ELSE
			NULL;
		END CASE;

		Write2FWKLog('Done creating time records.');

		IF p_Parse_Prior IS NOT NULL THEN
			Write2FWKLog('Parse Prior is set.');
			UPDATE PJI_PMV_TIME_DIM_TMP
			SET PRIOR_ID = (CASE period_type
						WHEN 128	THEN SUBSTR(LPAD(ID,7,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,7,'0'),4,4)-1)
						WHEN 64	THEN SUBSTR(LPAD(ID,8,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,8,'0'),4,4)-1)||SUBSTR(LPAD(ID,8,'0'),8)
						WHEN 32	THEN SUBSTR(LPAD(ID,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,10,'0'),4,4)-1)||SUBSTR(LPAD(ID,10,'0'),8)
						WHEN 16	THEN SUBSTR(LPAD(ID,11,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,11,'0'),4,4)-1)||SUBSTR(LPAD(ID,11,'0'),8)
						END)
			WHERE period_type<>1;
			Write2FWKLog('Prior ID is updated.');
		END IF;
		Write2FWKLog('Exiting Convert_Time...');
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			Write2FWKLog(g_SQL_Error_Msg, 3);
			RAISE;
	END Convert_Time;

	/*
	** ----------------------------------------------------------
	** Procedure: Convert_Time
	** This API is a public api exposed to the pmv report
	** developers. The API determines the various time records
	** to be created and calls the appropriate time api's.
	** ----------------------------------------------------------
	*/
	Procedure Convert_Time(p_As_Of_Date	NUMBER
							, p_Period_Type	VARCHAR2
							, p_View_BY		VARCHAR2
							, p_Parse_Prior	VARCHAR2 DEFAULT NULL
							, p_Report_Type	VARCHAR2 DEFAULT NULL
							, p_Comparator	VARCHAR2 DEFAULT NULL
							, p_Parse_ITD	VARCHAR2 DEFAULT NULL
							, p_Full_Period_Flag	VARCHAR2 DEFAULT NULL)
	AS
	l_As_Of_Date	NUMBER;
	BEGIN

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Convert_Time...','Convert_Time');

			Write2FWKLog('Parameters passed by table function :');
			Write2FWKLog(' p_As_Of_Date: '||p_As_Of_Date);
			Write2FWKLog(' p_Period_Type: '||p_Period_Type);
			Write2FWKLog(' p_View_BY: '||p_View_BY);
			Write2FWKLog(' p_Parse_Prior: '||p_Parse_Prior);
			Write2FWKLog(' p_Report_Type: '||p_Report_Type);
			Write2FWKLog(' p_Comparator: '||p_Comparator);
			Write2FWKLog(' p_Parse_ITD: '||p_Parse_ITD);
			Write2FWKLog(' p_Full_Period_Flag: '||p_Full_Period_Flag);
			Write2FWKLog('Clearing time temporary tables...');
		END IF;

		DELETE PJI_PMV_TIME_DIM_TMP;

		IF p_Parse_ITD IS NOT NULL THEN
			DELETE PJI_PMV_ITD_DIM_TMP;
		END IF;
		IF p_Report_Type = 'DBI' THEN
			DELETE PJI_PMV_TCMP_DIM_TMP;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Done clearing time temporary tables...');
		END IF;

		IF p_As_Of_Date IS NOT NULL AND p_Report_Type = 'DBI' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Derive the as_of_date for DBI reports.');
			END IF;
			l_As_Of_Date:=Convert_AS_OF_DATE(p_As_Of_Date, p_Period_Type, p_Comparator);
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Derived the as_of_date: '||l_As_Of_Date||' for DBI reports.');
			END IF;
		END IF;

		IF p_View_BY = 'TM' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Calling Convert_ViewBY_AS_OF_DATE as Viewby dimension is time.');
			END IF;
			IF p_Report_Type = 'FISCAL' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('The time dimension values should be restricted by fiscal/enterprize year.');
				END IF;
				Convert_ViewBY_AS_OF_DATE(p_As_Of_Date, p_Period_Type, p_Report_Type, p_Parse_Prior, p_Full_Period_Flag);
			ELSE
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('The time dimension values should not be restricted by fiscal/enterprize year.');
				END IF;
				Convert_ViewBY_AS_OF_DATE(p_As_Of_Date, p_Period_Type, NULL, p_Parse_Prior, p_Full_Period_Flag);
			END IF;
		ELSE
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Calling Convert_NViewBY_AS_OF_DATE as time is not the current Viewby dimension.');
			END IF;
			Convert_NViewBY_AS_OF_DATE(p_As_Of_Date, p_Period_Type, p_Parse_Prior, p_Full_Period_Flag);
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Done calling Convert_?ViewBY_AS_OF_DATE.');
		END IF;

		IF p_Parse_ITD = 'Y' AND p_View_BY = 'TM' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Calling Convert_ITD_ViewBY_AS_OF_DATE.');
			END IF;
			Convert_ITD_ViewBY_AS_OF_DATE(p_As_Of_Date, p_Period_Type, p_Parse_Prior);
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done calling Convert_ITD_ViewBY_AS_OF_DATE.');
			END IF;
		ELSIF p_Parse_ITD = 'Y' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Calling Convert_ITD_NViewBY_AS_OF_DATE.');
			END IF;
			Convert_ITD_NViewBY_AS_OF_DATE(p_As_Of_Date, p_Period_Type, p_Parse_Prior,'I');
			IF p_Report_Type = 'DBI' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('Calling Convert_ITD_NViewBY_AS_OF_DATE with DBI as of date.');
				END IF;
				Convert_ITD_NViewBY_AS_OF_DATE(l_As_Of_Date, p_Period_Type, p_Parse_Prior,'D');
			END IF;
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done calling Convert_ITD_NViewBY_AS_OF_DATE.');
			END IF;
		END IF;


		IF p_Report_Type = 'DBI' THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Calling Convert_DBI_NViewBY_AS_OF_DATE.');
			END IF;
			Convert_DBI_NViewBY_AS_OF_DATE(l_As_Of_Date, p_Period_Type, p_Comparator, p_Full_Period_Flag);
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done calling Convert_DBI_NViewBY_AS_OF_DATE.');
			END IF;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Convert_Time...');
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Convert_Time;

	/*
	** Time API's specifically catering to resource team.
	*/


/* -----------------------------------------------------------
** Procedure: Convert_Expected_Time
** The procedure creates time records based on an as of date
** when the view by dimension is not time based on the period
** type (whether WTD, PTD, QTD, YTD, or ITD). This API
** distinguish the time records which contain the Actual
** or Scheduled Amount Type based on the last summarized date.
** It also caters to additional logic based on following:
** Parse Prior: If the flag is passed as 'Y', the API stamps
** prior_id in the time tables.
**
** History:
**    20-JUN-02  Adzilah Abd.   Created
** -----------------------------------------------------------*/

PROCEDURE Convert_Expected_Time(p_as_of_date    NUMBER
                               ,p_period_type   VARCHAR2
                               ,p_parse_prior   VARCHAR2 DEFAULT NULL)
  IS
     l_period_id               NUMBER;
     l_period_start_date       DATE;
     l_qtr_id                  NUMBER;
     l_qtr_start_date          DATE;
     l_year_id                 NUMBER;
     l_year_start_date         DATE;
     l_week_id                 NUMBER;
     l_week_start_date         DATE;

     l_period_id_tmp           NUMBER;
     l_period_start_date_tmp   DATE;
     l_qtr_id_tmp              NUMBER;
     l_qtr_start_date_tmp      DATE;
     l_year_id_tmp             NUMBER;
     l_year_start_date_tmp     DATE;
     l_week_id_tmp             NUMBER;
     l_week_start_date_tmp     DATE;

     l_period_id_s             NUMBER;
     l_period_start_date_s     DATE;
     l_qtr_id_s                NUMBER;
     l_qtr_start_date_s        DATE;
     l_year_id_s               NUMBER;
     l_year_start_date_s       DATE;
     l_week_id_s               NUMBER;
     l_week_start_date_s       DATE;

     l_level                   NUMBER;
     l_is_GL                   VARCHAR2(1);
     l_period_type             VARCHAR2(150)   := p_period_type;
     l_summ_date               DATE;
     l_prior_summ_date         DATE;
     l_as_of_date              DATE            := TO_DATE(p_as_of_date, 'J');
     l_prior_as_of_date        DATE;
     l_process                 VARCHAR2(1)     := 'N';
     l_amount_type             NUMBER;
     l_date                    DATE;
     l_prior_date              DATE;
     l_calendar_id             NUMBER;

     l_calendar_type_day       VARCHAR2(1);
     l_calendar_type_sum       VARCHAR2(1);

BEGIN

     Write2FWKLog('Entering Convert_Expected_Time...','Convert_Expected_Time');
	BEGIN
		Write2FWKLog('Determining Prior Year...');
		l_Prior_As_Of_Date:=FII_TIME_API.ent_sd_lyr_beg(l_As_Of_Date);
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		Write2FWKLog('Unable to determine Prior Year, hence defaulting it...');
		l_Prior_As_Of_Date:=PJI_UTILS.GET_EXTRACTION_START_DATE;
	END;
	Write2FWKLog('Done with Prior Year...');

     Write2FWKLog('Retrieving the last summarized date value');

     l_summ_date := trunc(to_date(PJI_UTILS.GET_PARAMETER('LAST_FM_EXTR_DATE'),'YYYY/MM/DD'));
     Write2FWKLog('The last summarized date is ' || to_char(l_summ_date, 'YYYY/MM/DD'));

     DELETE PJI_PMV_TIME_DIM_TMP;

     if(l_summ_date is null) then
         return;
     end if;

	BEGIN
		Write2FWKLog('Determining Prior Year...');
		l_prior_summ_date:=FII_TIME_API.ent_sd_lyr_beg(l_summ_date);
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		Write2FWKLog('Unable to determine Prior Year, hence defaulting it...');
		l_prior_summ_date:=PJI_UTILS.GET_EXTRACTION_START_DATE;
	END;

	Write2FWKLog('Done with Prior Year...');

     Write2FWKLog('The last PRIOR summarized date is ' || to_char(l_prior_summ_date, 'YYYY/MM/DD'));

     -- get the appropriate calendar id
     IF l_period_type LIKE '%PA%' THEN
        l_calendar_id        := G_PA_Calendar_ID;
        l_is_GL              := 'Y';
        l_calendar_type_day  := 'P';
        l_calendar_type_sum  := 'P';
        Write2FWKLog('PA calendar is selected.');

     ELSIF l_period_type LIKE '%CAL%' THEN
        l_calendar_id        := G_GL_Calendar_ID;
        l_is_GL              := 'Y';
        l_calendar_type_day  := 'C';
        l_calendar_type_sum  := 'G';
        Write2FWKLog('GL calendar is selected.');

     ELSE
        l_calendar_type_day  := 'C';
        l_calendar_type_sum  := 'E';
        Write2FWKLog('ENT calendar is selected.');
     END IF;

     Write2FWKLog('The calendar Id value = ' || l_calendar_id);

     -- get all the id, and start_date of the period, week,
     -- quarter, year for the as_of_date and the last
     -- summarized date

     IF l_is_GL IS NULL THEN
         Write2FWKLog('Selecting from FII_TIME_DAY for as_of_date and last_summ_date');

         SELECT ent_period_id, ent_period_start_date,
                ent_qtr_id, ent_qtr_start_date,
                ent_year_id, ent_year_start_date,
                week_id, week_start_date
         INTO l_period_id, l_period_start_date,
              l_qtr_id, l_qtr_start_date,
              l_year_id, l_year_start_date,
              l_week_id, l_week_start_date
         FROM fii_time_day
         WHERE report_date = l_as_of_date;

         SELECT ent_period_id, ent_period_start_date,
                ent_qtr_id, ent_qtr_start_date,
                ent_year_id, ent_year_start_date,
                week_id, week_start_date
         INTO l_period_id_s, l_period_start_date_s,
              l_qtr_id_s, l_qtr_start_date_s,
              l_year_id_s, l_year_start_date_s,
              l_week_id_s, l_week_start_date_s
         FROM fii_time_day
         WHERE report_date = l_summ_date;

     ELSE
         Write2FWKLog('Selecting from FII_TIME_CAL_DAY_MV for as_of_date and last_summ_date');

         SELECT cal_period_id, cal_period_start_date,
                cal_qtr_id, cal_qtr_start_date,
                cal_year_id, cal_year_start_date
         INTO l_period_id, l_period_start_date,
              l_qtr_id, l_qtr_start_date,
              l_year_id, l_year_start_date
         FROM fii_time_cal_day_mv
         WHERE report_date = l_as_of_date
           AND calendar_id = l_calendar_id;

         SELECT cal_period_id, cal_period_start_date,
                cal_qtr_id, cal_qtr_start_date,
                cal_year_id, cal_year_start_date
         INTO l_period_id_s, l_period_start_date_s,
              l_qtr_id_s, l_qtr_start_date_s,
              l_year_id_s, l_year_start_date_s
         FROM fii_time_cal_day_mv
         WHERE report_date = l_summ_date
           AND calendar_id = l_calendar_id;

     END IF;


     -- set the level depending on the period_type
     CASE p_period_type
        WHEN    'ITD'                  THEN  l_level:=128;
        WHEN    'FII_TIME_ENT_YEAR'    THEN  l_level:=64;
        WHEN    'FII_TIME_CAL_YEAR'    THEN  l_level:=64;
        WHEN    'FII_TIME_ENT_QTR'     THEN  l_level:=32;
        WHEN    'FII_TIME_CAL_QTR'     THEN  l_level:=32;
        WHEN    'FII_TIME_ENT_PERIOD'  THEN  l_level:=1;
        WHEN    'FII_TIME_CAL_PERIOD'  THEN  l_level:=1;
        WHEN    'PJI_TIME_PA_PERIOD'   THEN  l_level:=1;
        WHEN    'FII_TIME_WEEK'        THEN  l_level:=0;
        ELSE    NULL;
     END CASE;
     Write2FWKLog('The Period_Type level value = ' || l_level);


     ---------------------------------------------------------------
     -- This if statement determines whether the last summarized
     -- date is out of the time window of the as of date and
     -- the period type chosen.
     ---------------------------------------------------------------

     IF ((l_level=128) or
         (l_level=64 and l_year_id   = l_year_id_s) or
         (l_level=32 and l_qtr_id    = l_qtr_id_s)  or
         (l_level=1  and l_period_id = l_period_id_s) or
         (l_level=0  and l_week_id   = l_week_id_s)) and
              (l_summ_date < l_as_of_date) THEN

         -- The last summarized date is within the time window.
         -- Need further processing.
         -- Set the tmp variables to the values found of the
         -- last summarized date.
         Write2FWKLog('Last summarized date within time window, amount type is Actuals');

         l_process := 'Y';
         l_period_id_tmp          := l_period_id_s;
         l_period_start_date_tmp  := l_period_start_date_s;
         l_qtr_id_tmp             := l_qtr_id_s;
         l_qtr_start_date_tmp     := l_qtr_start_date_s;
         l_year_id_tmp            := l_year_id_s;
         l_year_start_date_tmp    := l_year_start_date_s;
         l_week_id_tmp            := l_week_id_s;
         l_week_start_date_tmp    := l_week_start_date_s;
         l_amount_type            := 0;
         l_date                   := l_summ_date;
         l_prior_date             := l_prior_summ_date;

     ELSE

         -- The last summarized date is out of the time window
         -- Set the tmp variables to the values found of the
         -- as_of_date.

         l_period_id_tmp          := l_period_id;
         l_period_start_date_tmp  := l_period_start_date;
         l_qtr_id_tmp             := l_qtr_id;
         l_qtr_start_date_tmp     := l_qtr_start_date;
         l_year_id_tmp            := l_year_id;
         l_year_start_date_tmp    := l_year_start_date;
         l_week_id_tmp            := l_week_id;
         l_week_start_date_tmp    := l_week_start_date;
         l_date                   := l_as_of_date;
         l_prior_date             := l_prior_as_of_date;

         IF (l_summ_date > l_as_of_date) THEN
             Write2FWKLog('Last summarized date out of time window, amount type is Actuals');
             l_amount_type := 0;      /* actuals */
         ELSE
             Write2FWKLog('Last summarized date out of time window, amount type is Scheduled');
             l_amount_type := 1;      /* scheduled */
         END IF;
     END IF;

     Write2FWKLog('The value of l_process variable = ' || l_process);


     /* Week Level (WTD) */
     -- if it is week to date, just get the days to the beginning
     -- of the week from the date
     -- Week is only applicable to Enterprise Week
     IF l_level = 0 THEN
          Write2FWKLog('Creating day slice for the given week.');
          INSERT INTO PJI_PMV_TIME_DIM_TMP
          (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
          SELECT report_date_julian, '-1', '-1', 1 , l_amount_type, l_calendar_type_day
          FROM fii_time_day, dual
          WHERE week_id       = l_week_id_tmp
            AND report_date  <= l_date;

          IF p_parse_prior IS NOT NULL THEN
               Write2FWKLog('Creating day slice for the prior year week.');
               INSERT INTO PJI_PMV_TIME_DIM_TMP
               (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
               SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
               FROM fii_time_day
               WHERE week_id = SUBSTR(LPAD(l_week_id_tmp,11,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_week_id_tmp,11,'0'),4,4)-1)||SUBSTR(LPAD(l_week_id_tmp,11,'0'),8)
	       AND report_date <= l_prior_date;
	  END IF;

     END IF;


     /* Period or Month Level (PTD) */
     -- get all the days that are less than the l_date (either
     -- the last summarized date or the as_of_date), with the
     -- same period_id
     IF l_level >= 1 THEN
          IF l_is_GL IS NULL THEN
                Write2FWKLog('Creating day slice for the given period - Enterprise Cal.');

                INSERT INTO PJI_PMV_TIME_DIM_TMP
                (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                SELECT report_date_julian, '-1', '-1', 1 , l_amount_type, l_calendar_type_day
                FROM fii_time_day, dual
                WHERE ent_period_id = l_period_id_tmp
                  AND report_date  <= l_date;

                IF p_parse_prior IS NOT NULL THEN
                    Write2FWKLog('Creating day slice for the prior year period - Enterprise Cal.');
                    INSERT INTO PJI_PMV_TIME_DIM_TMP
                    (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                    SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                    FROM fii_time_day
                    WHERE ent_period_id = SUBSTR(LPAD(l_period_id_tmp,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_period_id_tmp,10,'0'),4,4)-1)||SUBSTR(LPAD(l_period_id_tmp,10,'0'),8)
                      AND report_date  <= l_prior_date;
                END IF;

          ELSIF l_is_GL IS NOT NULL THEN
                Write2FWKLog('Creating day slice for the given period - Fiscal Cal.');

                INSERT INTO PJI_PMV_TIME_DIM_TMP
                (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                FROM fii_time_cal_day_mv, dual
                WHERE cal_period_id = l_period_id_tmp
                  AND calendar_id   = l_calendar_id
                  AND report_date  <= l_date;

                IF p_parse_prior IS NOT NULL THEN
                    Write2FWKLog('Creating day slice for the prior year period - Fiscal Cal.');
                    INSERT INTO PJI_PMV_TIME_DIM_TMP
                    (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                    SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                    FROM fii_time_cal_day_mv
                    WHERE cal_period_id = SUBSTR(LPAD(l_period_id_tmp,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_period_id_tmp,10,'0'),4,4)-1)||SUBSTR(LPAD(l_period_id_tmp,10,'0'),8)
                      AND calendar_id   = l_calendar_id
                      AND report_date  <= l_prior_date;
                END IF;

	  END IF;
     END IF;


     /* Quarter Level (QTD) */
     -- get all the months that are less than the period start date
     -- with the same quarter id
     IF l_level >= 32 THEN
          IF l_is_GL IS NULL THEN
                Write2FWKLog('Creating period slice for the given quarter - Enterprise Cal.');

                INSERT INTO PJI_PMV_TIME_DIM_TMP
                (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                SELECT ent_period_id, '-1', '-1', 32 , l_amount_type, l_calendar_type_sum
                FROM fii_time_ent_period, dual
                WHERE ent_qtr_id    = l_qtr_id_tmp
                  AND start_date    < l_period_start_date_tmp;

          ELSIF l_is_GL IS NOT NULL THEN
                Write2FWKLog('Creating period slice for the given quarter - Fiscal Cal.');

                INSERT INTO PJI_PMV_TIME_DIM_TMP
                (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                SELECT cal_period_id, '-1', '-1', 32 , l_amount_type, l_calendar_type_sum
                FROM fii_time_cal_period, dual
                WHERE cal_qtr_id    = l_qtr_id_tmp
                  AND calendar_id   = l_calendar_id
                  AND start_date    < l_period_start_date_tmp;
	  END IF;
     END IF;


     /* Year Level (YTD) */
     -- get all the quarters that are less than the quarter start date
     -- with the same year id
     IF l_level >= 64 THEN
          IF l_is_GL IS NULL THEN
                Write2FWKLog('Creating quarter slice for the given year - Enterprise Cal.');

                INSERT INTO PJI_PMV_TIME_DIM_TMP
                (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                SELECT ent_qtr_id, '-1', '-1', 64 , l_amount_type, l_calendar_type_sum
                FROM fii_time_ent_qtr, dual
                WHERE ent_year_id   = l_year_id_tmp
                  AND start_date    < l_qtr_start_date_tmp;

          ELSIF l_is_GL IS NOT NULL THEN
                Write2FWKLog('Creating quarter slice for the given year - Fiscal Cal.');

                INSERT INTO PJI_PMV_TIME_DIM_TMP
                (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                SELECT cal_qtr_id, '-1', '-1', 64 , l_amount_type, l_calendar_type_sum
                FROM fii_time_cal_qtr, dual
                WHERE cal_year_id   = l_year_id_tmp
                  AND calendar_id   = l_calendar_id
                  AND start_date    < l_qtr_start_date_tmp;
	  END IF;
     END IF;


     /* ITD Level */
     -- get all the years that are less than year start date
     -- of the last summarized date or the as_of_date (already set
     -- in the tmp variable from the earlier logic)
     IF l_level >= 128 THEN
          IF l_is_GL IS NULL THEN
                Write2FWKLog('Creating year slice for all previous years - Enterprise Cal.');

                INSERT INTO PJI_PMV_TIME_DIM_TMP
                (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                SELECT ent_year_id, '-1', '-1', 128 , l_amount_type, l_calendar_type_sum
                FROM fii_time_ent_year, dual
                WHERE start_date < l_year_start_date_tmp;

          ELSIF l_is_GL IS NOT NULL THEN
                Write2FWKLog('Creating year slice for all previous years - Fiscal Cal.');

                INSERT INTO PJI_PMV_TIME_DIM_TMP
                (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                SELECT cal_year_id, '-1', '-1', 128 , l_amount_type, l_calendar_type_sum
                FROM fii_time_cal_year, dual
                WHERE calendar_id  = l_calendar_id
                  AND start_date   < l_year_start_date_tmp;
	  END IF;
     END IF;


     --------------------------------------------------------------
     -- Will continue processing only for the following case:
     -- That the last summarized date is within the time window of
     -- the as_of_date and the period_type chosen
     --------------------------------------------------------------

     IF l_process = 'Y' THEN

         -- When l_process is Y, then the amount type will always be 1 (scheduled).
         -- This is when the summarized date is less than the as of date value.
         -- The following code will process the difference between summarized date
         -- and the as of date values.
         l_amount_type := 1;
         Write2FWKLog('Continue processing for the Scheduled Amount Type');
         Write2FWKLog('Process remaining time period differences between Last_Summ_Date and As_Of_Date');

         /* Week Level (WTD) */
         -- if it is week to date, just get the days from the summarized date
         -- to the as_of_date values
         -- Week is only applicable to Enterprise Week
         IF l_level = 0 THEN
              Write2FWKLog('Creating day slice for the given week between the two dates - scheduled');
              INSERT INTO PJI_PMV_TIME_DIM_TMP
              (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
              SELECT report_date_julian, '-1', '-1', 1 , l_amount_type, l_calendar_type_day
              FROM fii_time_day, dual
              WHERE week_id       = l_week_id
                AND report_date  >  l_summ_date
                AND report_date  <= l_as_of_date;

              IF p_parse_prior IS NOT NULL THEN
                  Write2FWKLog('Creating day slice for the prior year week between the two dates - scheduled');
                  INSERT INTO PJI_PMV_TIME_DIM_TMP
                  (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                  SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                  FROM fii_time_day
                  WHERE week_id    = SUBSTR(LPAD(l_week_id,11,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_week_id,11,'0'),4,4)-1)||SUBSTR(LPAD(l_week_id,11,'0'),8)
	          AND report_date >  l_prior_summ_date
                  AND report_date <= l_prior_as_of_date;
	      END IF;

         END IF;


         IF l_level >=1 THEN

             -- When the dates are in the same period/month, this code gets the
             -- time_id between those two dates.
             IF l_period_id = l_period_id_s THEN

                  IF l_is_GL IS NULL THEN
                       Write2FWKLog('Creating day slice for between the two dates - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT report_date_julian, '-1', '-1', 1 , l_amount_type, l_calendar_type_day
                       FROM fii_time_day, dual
                       WHERE ent_period_id = l_period_id
                         AND report_date   > l_summ_date
                         AND report_date  <= l_as_of_date;

                       IF p_parse_prior IS NOT NULL THEN
                          Write2FWKLog('Creating day slice for the prior year period between two_dates - Enterprise Cal - scheduled');
                          INSERT INTO PJI_PMV_TIME_DIM_TMP
                         (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                          SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                          FROM fii_time_day
                          WHERE ent_period_id = SUBSTR(LPAD(l_period_id,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_period_id,10,'0'),4,4)-1)||SUBSTR(LPAD(l_period_id,10,'0'),8)
                            AND report_date   >  l_prior_summ_date
                            AND report_date   <= l_prior_as_of_date;

                       END IF;

                  ELSIF l_is_GL IS NOT NULL THEN
                       Write2FWKLog('Creating day slice for between the two dates - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                       FROM fii_time_cal_day_mv, dual
                       WHERE cal_period_id = l_period_id
                         AND calendar_id   = l_calendar_id
                         AND report_date   > l_summ_date
                         AND report_date  <= l_as_of_date;

                       IF p_parse_prior IS NOT NULL THEN
                          Write2FWKLog('Creating day slice for the prior year period between the two dates - Fiscal Cal - scheduled.');
                          INSERT INTO PJI_PMV_TIME_DIM_TMP
                         (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                          SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                          FROM fii_time_cal_day_mv
                          WHERE cal_period_id = SUBSTR(LPAD(l_period_id,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_period_id,10,'0'),4,4)-1)||SUBSTR(LPAD(l_period_id,10,'0'),8)
                            AND calendar_id   = l_calendar_id
                            AND report_date  >  l_prior_summ_date
                            AND report_date  <= l_prior_as_of_date;
                       END IF;

	          END IF;

             ELSE
             -- When the dates are not in the same period/month, this code gets the
             -- time_id which is greater than the summarized date within its period_id
             -- AND the time_id which is less than the as_of_date within its period_id
             -- (will only get executed when the period_type > 1)

                  IF l_is_GL IS NULL THEN
                       Write2FWKLog('Creating day slice for the last_summ_date period - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT report_date_julian, '-1', '-1', 1 , l_amount_type, l_calendar_type_day
                       FROM fii_time_day, dual
                       WHERE ent_period_id = l_period_id_s
                         AND report_date   > l_summ_date;

                       IF p_parse_prior IS NOT NULL THEN
                          Write2FWKLog('Creating day slice for the prior year period of last_summ_date - Enterprise Cal - scheduled');
                          INSERT INTO PJI_PMV_TIME_DIM_TMP
                          (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                          SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                          FROM fii_time_day
                          WHERE ent_period_id = SUBSTR(LPAD(l_period_id_s,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_period_id_s,10,'0'),4,4)-1)||SUBSTR(LPAD(l_period_id_s,10,'0'),8)
                            AND report_date   > l_prior_summ_date;
                       END IF;


                       Write2FWKLog('Creating day slice for the as_of_date period - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT report_date_julian, '-1', '-1', 1 , l_amount_type, l_calendar_type_day
                       FROM fii_time_day, dual
                       WHERE ent_period_id = l_period_id
                         AND report_date  <= l_as_of_date;

                       IF p_parse_prior IS NOT NULL THEN
                          Write2FWKLog('Creating day slice for the prior year period of as_of_date - Enterprise Cal - scheduled');
                          INSERT INTO PJI_PMV_TIME_DIM_TMP
                          (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                          SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                          FROM fii_time_day
                          WHERE ent_period_id = SUBSTR(LPAD(l_period_id,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_period_id,10,'0'),4,4)-1)||SUBSTR(LPAD(l_period_id,10,'0'),8)
                            AND report_date  <= l_prior_as_of_date;
                       END IF;

                  ELSIF l_is_GL IS NOT NULL THEN
                       Write2FWKLog('Creating day slice for the last_summ_date period - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                       FROM fii_time_cal_day_mv, dual
                       WHERE cal_period_id = l_period_id_s
                         AND calendar_id   = l_calendar_id
                         AND report_date   > l_summ_date;

                       IF p_parse_prior IS NOT NULL THEN
                          Write2FWKLog('Creating day slice for the prior year period of last_summ_date - Fiscal Cal - scheduled');
                          INSERT INTO PJI_PMV_TIME_DIM_TMP
                          (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                          SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                          FROM fii_time_cal_day_mv
                          WHERE cal_period_id = SUBSTR(LPAD(l_period_id_s,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_period_id_s,10,'0'),4,4)-1)||SUBSTR(LPAD(l_period_id_s,10,'0'),8)
                            AND calendar_id   = l_calendar_id
                            AND report_date   > l_prior_summ_date;
                       END IF;

                       Write2FWKLog('Creating day slice for the as_of_date period - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                       FROM fii_time_cal_day_mv, dual
                       WHERE cal_period_id = l_period_id
                         AND calendar_id   = l_calendar_id
                         AND report_date  <= l_as_of_date;

                       IF p_parse_prior IS NOT NULL THEN
                          Write2FWKLog('Creating day slice for the prior year period of as_of_date - Fiscal Cal - scheduled');
                          INSERT INTO PJI_PMV_TIME_DIM_TMP
                          (PRIOR_ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                          SELECT report_date_julian, '-1', '-1', 1, l_amount_type, l_calendar_type_day
                          FROM fii_time_cal_day_mv
                          WHERE cal_period_id = SUBSTR(LPAD(l_period_id,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(l_period_id,10,'0'),4,4)-1)||SUBSTR(LPAD(l_period_id,10,'0'),8)
                            AND calendar_id   = l_calendar_id
                            AND report_date  <= l_prior_as_of_date;
                       END IF;

	          END IF;

             END IF;

         END IF;  /* level = 1 */



         IF l_level >= 32 THEN

             -- When the dates are in the same quarter, this code gets the
             -- time_id of the periods/months between those two dates's
             -- period start dates.
             IF l_qtr_id = l_qtr_id_s THEN

                  IF l_is_GL IS NULL THEN
                       Write2FWKLog('Creating period slice for between the two dates periods - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT ent_period_id, '-1', '-1', 32 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_ent_period, dual
                       WHERE ent_qtr_id    = l_qtr_id
                         AND start_date    < l_period_start_date
                         AND start_date    > l_period_start_date_s;

                  ELSIF l_is_GL IS NOT NULL THEN
                       Write2FWKLog('Creating period slice for between the two dates periods - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT cal_period_id, '-1', '-1', 32 , l_amount_type,  l_calendar_type_sum
                       FROM fii_time_cal_period, dual
                       WHERE cal_qtr_id    = l_qtr_id_s
                         AND calendar_id   = l_calendar_id
                         AND start_date    < l_period_start_date
                         AND start_date    > l_period_start_date_s;

	          END IF;

             ELSE
             -- When the dates are not in the same quarter, this code gets the time_id of
             -- the periods which is greater than the summarized date's period_start_date
             -- within its quarter_id AND the time_id which is less than the as_of_date's
             -- period_start_date within its quarter_id
             -- (will only get executed when the period_type > 32)

                  IF l_is_GL IS NULL THEN
                       Write2FWKLog('Creating period slice for the last_summ_date quarter - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT ent_period_id, '-1', '-1', 32 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_ent_period, dual
                       WHERE ent_qtr_id    = l_qtr_id_s
                         AND start_date    > l_period_start_date_s;

                       Write2FWKLog('Creating period slice for the as_of_date quarter - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT ent_period_id, '-1', '-1', 32 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_ent_period, dual
                       WHERE ent_qtr_id    = l_qtr_id
                         AND start_date    < l_period_start_date;

                  ELSIF l_is_GL IS NOT NULL THEN
                       Write2FWKLog('Creating period slice for the last_summ_date quarter - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT cal_period_id, '-1', '-1', 32 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_cal_period, dual
                       WHERE cal_qtr_id    = l_qtr_id_s
                         AND calendar_id   = l_calendar_id
                         AND start_date    > l_period_start_date_s;

                       Write2FWKLog('Creating period slice for the as_of_date quarter - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT cal_period_id, '-1', '-1', 32 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_cal_period, dual
                       WHERE cal_qtr_id    = l_qtr_id
                         AND calendar_id   = l_calendar_id
                         AND start_date    < l_period_start_date;

	          END IF;

             END IF;

         END IF; /* level = 32 */


         IF l_level >= 64 THEN

             -- When the dates are in the same year, this code gets the
             -- time_id of the quarters between those two dates's quarter
             -- start_dates.
             IF l_year_id = l_year_id_s THEN

                  IF l_is_GL IS NULL THEN
                       Write2FWKLog('Creating quarter slice for between the two dates quarters - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT ent_qtr_id, '-1', '-1', 64 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_ent_qtr, dual
                       WHERE ent_year_id   = l_year_id
                         AND start_date    < l_qtr_start_date
                         AND start_date    > l_qtr_start_date_s;

                  ELSIF l_is_GL IS NOT NULL THEN
                       Write2FWKLog('Creating quarter slice for between the two dates quarters - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT cal_qtr_id, '-1', '-1', 64 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_cal_qtr, dual
                       WHERE cal_year_id   = l_year_id
                         AND calendar_id   = l_calendar_id
                         AND start_date    < l_qtr_start_date
                         AND start_date    > l_qtr_start_date_s;

                  END IF;

             ELSE
             -- When the dates are not in the same year, this code gets the time_id of
             -- the quarters which is greater than the summarized date's quarter_start_date
             -- within its year_id AND the time_id which is less than the as_of_date's
             -- quarter_start_date within its year_id
             -- (will only get executed when the period_type > 64)

                  IF l_is_GL IS NULL THEN
                       Write2FWKLog('Creating quarter slice for the last_summ_date year - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT ent_qtr_id, '-1', '-1', 64 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_ent_qtr, dual
                       WHERE ent_year_id   = l_year_id_s
                         AND start_date    > l_qtr_start_date_s;

                       Write2FWKLog('Creating quarter slice for the as_of_date year - Enterprise Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT ent_qtr_id, '-1', '-1', 64 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_ent_qtr, dual
                       WHERE ent_year_id   = l_year_id
                         AND start_date    < l_qtr_start_date;


                  ELSIF l_is_GL IS NOT NULL THEN
                       Write2FWKLog('Creating quarter slice for the last_summ_date year - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT cal_qtr_id, '-1', '-1', 64 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_cal_qtr, dual
                       WHERE cal_year_id   = l_year_id_s
                         AND calendar_id   = l_calendar_id
                         AND start_date    > l_qtr_start_date_s;

                       Write2FWKLog('Creating quarter slice for the as_of_date year - Fiscal Cal - scheduled');

                       INSERT INTO PJI_PMV_TIME_DIM_TMP
                       (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                       SELECT cal_qtr_id, '-1', '-1', 64 , l_amount_type, l_calendar_type_sum
                       FROM fii_time_cal_qtr, dual
                       WHERE cal_year_id   = l_year_id
                         AND calendar_id   = l_calendar_id
                         AND start_date    < l_qtr_start_date;

                  END IF;

             END IF;

         END IF; /* level = 64 */


         IF l_level >= 128 THEN

             -- When the level is 128, this code gets the time_ids
             -- of the years between those two dates's year start_dates.

             IF l_is_GL IS NULL THEN
                   Write2FWKLog('Creating year slice for between the two dates years - Enterprise Cal - scheduled');

                   INSERT INTO PJI_PMV_TIME_DIM_TMP
                   (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                   SELECT ent_year_id, '-1', '-1', 128 , l_amount_type, l_calendar_type_sum
                   FROM fii_time_ent_year, dual
                   WHERE start_date < l_year_start_date
                     AND start_date > l_year_start_date_s;

             ELSIF l_is_GL IS NOT NULL THEN
                   Write2FWKLog('Creating year slice for between the two dates years - Fiscal Cal - scheduled');

                   INSERT INTO PJI_PMV_TIME_DIM_TMP
                   (ID, NAME, ORDER_BY_ID, PERIOD_TYPE, AMOUNT_TYPE, CALENDAR_TYPE)
                   SELECT cal_year_id, '-1', '-1', 128 , l_amount_type, l_calendar_type_sum
                   FROM fii_time_cal_year, dual
                   WHERE calendar_id  = l_calendar_id
                     AND start_date   < l_year_start_date
                     AND start_date   > l_year_start_date_s;
	     END IF;

         END IF; /* level = 128 */

     END IF; /* l_process */


     IF p_parse_prior IS NOT NULL THEN

          Write2FWKLog('Parse Prior is set.');
          UPDATE PJI_PMV_TIME_DIM_TMP
          SET PRIOR_ID =
             (CASE period_type
                WHEN 128 THEN SUBSTR(LPAD(ID,7,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,7,'0'),4,4)-1)
                WHEN 64  THEN SUBSTR(LPAD(ID,8,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,8,'0'),4,4)-1)||SUBSTR(LPAD(ID,8,'0'),8)
                WHEN 32  THEN SUBSTR(LPAD(ID,10,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,10,'0'),4,4)-1)||SUBSTR(LPAD(ID,10,'0'),8)
                WHEN 16  THEN SUBSTR(LPAD(ID,11,'0'),1,3)||TO_CHAR(SUBSTR(LPAD(ID,11,'0'),4,4)-1)||SUBSTR(LPAD(ID,11,'0'),8)
                END)
	  WHERE period_type<>1;

          Write2FWKLog('Prior ID is updated.');
     END IF;

     Write2FWKLog('Exiting Convert_Expected_Time...');

EXCEPTION
     WHEN OTHERS THEN
          g_SQL_Error_Msg:=SQLERRM();
          Write2FWKLog(g_SQL_Error_Msg, 3);
          RAISE;

END Convert_Expected_Time;


	/*
	** The following API is coded by jeff.
	*/
	Procedure Convert_Time_AVL_Trend(p_AS_OF_DATE NUMBER)
	AS
	l_week_id           NUMBER;
	l_Week_Name    VARCHAR(100);
	l_End_Date         DATE;
	BEGIN
		DELETE PJI_PMV_TIME_DIM_TMP;
		SELECT
			day.week_id
			, wek.name
			, wek.end_date
		INTO  l_Week_Id,
			l_Week_Name,
			l_End_Date
		FROM  fii_time_day day
			, fii_time_week wek
		WHERE
			report_date = to_date(p_as_of_date,'j') -- As Of Date
			AND wek.week_id = day.week_id;


		INSERT INTO PJI_PMV_TIME_DIM_TMP
		(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
		SELECT report_date_julian
		, l_Week_Name, l_Week_Id, 1, 'C' FROM fii_time_day
		WHERE week_id = l_Week_Id
		AND report_date>=to_date(p_as_of_date,'j');

		INSERT INTO PJI_PMV_TIME_DIM_TMP
		(ID, NAME, ORDER_BY_ID, PERIOD_TYPE, CALENDAR_TYPE)
		SELECT id, name, id, 16, 'C'
		FROM (
		SELECT week_id id,name name FROM fii_time_week
		WHERE end_date>l_End_Date
		ORDER BY 1 ASC)
		WHERE ROWNUM < 13;
	END Convert_Time_AVL_Trend;

	/*
	** ----------------------------------------------------------
	** Procedure: Init
	** This procedure caches the dimension and measure defination
	** for the given region. This procedure has to be called
	** before any other program units are called.
	** ----------------------------------------------------------
	*/
	Procedure Init (p_Region_Code IN VARCHAR2)
	IS
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Init...','Init');
		END IF;

		IF p_Region_code IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Before bulk collecting dimensions meta data for the specified report...');
			END IF;

			SELECT attribute_code attribute_code
			, attribute2 dimension_level
			, attribute3      base_column
			, attribute15     view_by_table
			BULK COLLECT INTO
			  G_dimension_codes_tab
			, G_dimension_level_tab
			, G_dim_base_column_tab
			, G_view_by_table_tab
			FROM
			AK_REGION_ITEMS
			WHERE region_code = p_Region_Code
			AND region_application_id = 1292
			AND attribute1 IS NOT NULL;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After bulk collecting dimensions meta data for the specified report...');
				Write2FWKLog('Before bulk collecting measure meta data for the specified report...');
			END IF;

			SELECT attribute_code attribute_code
			, attribute3      base_column
			, attribute4      attribute4
			, attribute9      aggregation
			BULK COLLECT INTO
			  G_attribute_code_tab
			, G_msr_base_column_tab
			, G_attribute4_tab
			, G_aggregation_tab
			FROM
			AK_REGION_ITEMS
			WHERE region_code = p_Region_Code
			AND region_application_id = 1292
			AND attribute9 IS NOT NULL
			ORDER BY display_sequence;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('After bulk collecting measure meta data for the specified report...');
			END IF;

		END IF;
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Exiting Init...');
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Init;

	/*
	** ----------------------------------------------------------
	** Function: Get_ViewBY_Base_Column
	** This Function traverses thru the cached copy of dimensions
	** and returns the view by columns name. The function also
	** caches the view by information into global variables.
	** Therefore, care has to be taken to not to reference these
	** global variables without calling this api.
	** ----------------------------------------------------------
	*/
/*
	Function Get_ViewBY_Base_Column(p_view_by IN VARCHAR2) RETURN VARCHAR2
	IS
	BEGIN
		Write2FWKLog('Entering Get_ViewBY_Base_Column...','Get_ViewBY_Base_Column');
		FOR i IN G_dimension_level_tab.first..G_dimension_level_tab.last LOOP
			IF (G_dimension_level_tab(i) = p_view_by) THEN
				G_ViewBY:=G_dimension_level_tab(i);
				G_ViewBY_Column_Name:=G_dim_base_column_tab(i);
				G_ViewBY_Table_Name:=G_view_by_table_tab(i);
				Write2FWKLog('G_ViewBY :'||G_ViewBY);
				Write2FWKLog('G_ViewBY_Column_Name :'||G_ViewBY_Column_Name);
				Write2FWKLog('G_ViewBY_Table_Name :'||G_ViewBY_Table_Name);
			END IF;
		END LOOP;
		RETURN G_ViewBY_Column_Name;
		Write2FWKLog('Exiting Get_ViewBY_Base_Column...');
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			Write2FWKLog(g_SQL_Error_Msg, 3);
			RAISE;
	END Get_ViewBY_Base_Column;
*/

	/* New Revision
	** ----------------------------------------------------------
	** Function: Get_ViewBY_Base_Column
	** This Function traverses thru the cached copy of dimensions
	** and returns the view by columns name. The function also
	** caches the view by information into global variables.
	** Therefore, care has to be taken to not to reference these
	** global variables without calling this api.
	** ----------------------------------------------------------
	*/

	Function Get_ViewBY_Base_Column(p_view_by IN VARCHAR2) RETURN VARCHAR2
	IS
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Get_ViewBY_Base_Column...'||p_view_by,'Get_ViewBY_Base_Column'||p_view_by);
		END IF;

		G_ViewBY := p_view_by;
		CASE p_view_by
		WHEN 'ORGANIZATION+PJI_ORGANIZATIONS' THEN
			G_ViewBY_Column_Name  := 'ORGANIZATION_ID';
			G_ViewBY_Table_Name  := 'PJI_ORGANIZATIONS_V';
		WHEN 'PROJECT CLASSIFICATION+CLASS_CODE' THEN
			G_ViewBY_Column_Name  := 'PROJECT_CLASS_ID';
			G_ViewBY_Table_Name := 'PJI_CLASS_CODES_V';
		WHEN 'PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES' THEN
			G_ViewBY_Column_Name  := 'EXPENDITURE_CATEGORY';
			G_ViewBY_Table_Name := 'PJI_EXP_CATEGORIES_V';
		WHEN 'PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES' THEN
			G_ViewBY_Column_Name  := 'EXPENDITURE_TYPE_ID';
			G_ViewBY_Table_Name := 'PJI_EXP_TYPES_V';
		WHEN 'PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES' THEN
			G_ViewBY_Column_Name  := 'REVENUE_CATEGORY';
			G_ViewBY_Table_Name := 'PJI_REVENUE_CATEGORIES_V';
		WHEN 'PROJECT REVENUE CATEGORY+PJI_EXP_EVT_TYPES' THEN
			G_ViewBY_Column_Name  := 'REVENUE_TYPE_ID';
			G_ViewBY_Table_Name := 'PJI_EXP_EVT_TYPES_V';
		WHEN 'PROJECT JOB LEVEL+PJI_JOB_LEVELS' THEN
			G_ViewBY_Column_Name := 'JOB_LEVEL_ID';
			G_ViewBY_Table_Name := 'PJI_JOB_LEVELS_V';
		WHEN 'PROJECT WORK TYPE+PJI_UTIL_CATEGORIES' THEN
			G_ViewBY_Column_Name := 'UTIL_CATEGORY_ID';
			G_ViewBY_Table_Name := 'PJI_UTIL_CATEGORIES_V';
		WHEN 'PROJECT WORK TYPE+PJI_WORK_TYPES' THEN
			G_ViewBY_Column_Name := 'WORK_TYPE_ID';
			G_ViewBY_Table_Name := 'PJI_WORK_TYPES_V';
		WHEN 'PROJECT+PJI_PROJECTS' THEN
			G_ViewBY_Column_Name := 'PROJECT_NAME';
			G_ViewBY_Table_Name := 'PJI_PROJECTS_V';
		WHEN 'TIME+FII_TIME_CAL_PERIOD' THEN
			G_ViewBY_Column_Name := 'TIME_ID';
			G_ViewBY_Table_Name := 'FII_TIME_CAL_PERIOD_V';
		WHEN 'TIME+FII_TIME_CAL_QTR' THEN
			G_ViewBY_Column_Name := 'TIME_ID';
			G_ViewBY_Table_Name := 'FII_TIME_CAL_QTR_V';
		WHEN 'TIME+FII_TIME_CAL_YEAR' THEN
			G_ViewBY_Column_Name := 'TIME_ID';
			G_ViewBY_Table_Name := 'FII_TIME_CAL_YEAR_V';
		WHEN 'TIME+FII_TIME_ENT_PERIOD' THEN
			G_ViewBY_Column_Name := 'TIME_ID';
			G_ViewBY_Table_Name := 'FII_TIME_ENT_PERIOD_V';
		WHEN 'TIME+FII_TIME_ENT_QTR' THEN
			G_ViewBY_Column_Name := 'TIME_ID';
			G_ViewBY_Table_Name := 'FII_TIME_ENT_QTR_V';
		WHEN 'TIME+FII_TIME_ENT_YEAR' THEN
			G_ViewBY_Column_Name := 'TIME_ID';
			G_ViewBY_Table_Name := 'FII_TIME_ENT_YEAR_V';
		WHEN 'TIME+FII_TIME_WEEK' THEN
			G_ViewBY_Column_Name := 'TIME_ID';
			G_ViewBY_Table_Name := 'FII_TIME_WEEK_V';
		WHEN 'TIME+PJI_TIME_PA_PERIOD' THEN
			G_ViewBY_Column_Name := 'TIME_ID';
			G_ViewBY_Table_Name := 'PJI_TIME_PA_PERIOD_V';
		END CASE;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('G_ViewBY :'||G_ViewBY);
			Write2FWKLog('G_ViewBY_Column_Name :'||G_ViewBY_Column_Name);
			Write2FWKLog('G_ViewBY_Table_Name :'||G_ViewBY_Table_Name);
			Write2FWKLog('Exiting Get_ViewBY_Base_Column...');
		END IF;

		RETURN G_ViewBY_Column_Name;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Get_ViewBY_Base_Column;


	/*
	** ----------------------------------------------------------
	** Function: Construct_SELECT_Clause
	** This Function constructs the select statement to be
	** returned to PMV. All unknown variables (at this point of
	** time) are replaced with patterns. These patterns are
	** later replaced with actual values in the Generate_SQL API.
	** ----------------------------------------------------------
	*/
	Function Construct_SELECT_Clause(p_View_BY IN VARCHAR2)
	RETURN VARCHAR2 IS
	l_Buffer	VARCHAR2(200);
	l_ViewBY_Indentifier	VARCHAR2(1);
	l_Select_List	VARCHAR2(3200):=' SELECT ';
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Construct_Select_Clause...','Construct_Select_Clause');
		END IF;

		IF p_View_BY IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Determining Viewby base column...');
			END IF;
			l_Buffer:=Get_ViewBY_Base_Column(p_View_BY);
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done determining Viewby base column. Value : '||l_Buffer);
			END IF;
		END IF;

		IF l_Buffer IS NOT NULL THEN
			l_ViewBY_Indentifier:='Y';
			l_Select_List:=l_Select_List||'FACT.'||l_Buffer||' "VIEWBY" ';
		ELSE
			l_Select_List:=l_Select_List||'1 "CONSTANT" ';
		END IF;

		FOR i IN G_attribute_code_tab.first..G_attribute_code_tab.last LOOP
			IF (G_attribute_code_tab(i) = 'VIEWBY' AND l_ViewBY_Indentifier IS NOT NULL ) THEN
				NULL;
			ELSE
				IF G_attribute_code_tab(i) LIKE 'PJI_REP_URL%' THEN
					l_Buffer:=', FACT.'||G_attribute_code_tab(i)||' ';
				ELSIF G_attribute_code_tab(i) LIKE 'PJI_REP_TOTAL%' THEN
					l_Buffer:=', FACT.'||G_attribute4_tab(i)||' "'||G_attribute_code_tab(i)||'"';
				ELSE
					l_Buffer:=', FACT.'||G_msr_base_column_tab(i)||' ';
				END IF;
				IF G_attribute_code_tab(i) NOT LIKE 'PJI_REP_TOTAL%' THEN
					l_Select_List:=l_Select_List||l_Buffer||' "'||G_attribute_code_tab(i)||'"';
				ELSE
					l_Select_List:=l_Select_List||l_Buffer;
				END IF;
			END IF;
		END LOOP;
		l_Select_List:=l_Select_List||' FROM TABLE(<<DEV_PL/SQL_EXTENSION>>(<<PL/SQL PARAMS>>)) FACT ';

		IF (p_View_BY NOT LIKE '%TIME%' OR l_ViewBY_Indentifier IS NULL) THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating the order by clause.');
			END IF;
			l_Select_List:=l_Select_List||' &ORDER_BY_CLAUSE ';
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('l_Select_List :'||l_Select_List);
			Write2FWKLog('Exiting Construct_Select_Clause...');
		END IF;

		RETURN l_Select_List;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Construct_Select_Clause;

	/* New Revision
	** ----------------------------------------------------------
	** Function: Construct_SELECT_Clause
	** This Function constructs the select statement to be
	** returned to PMV. All unknown variables (at this point of
	** time) are replaced with patterns. These patterns are
	** later replaced with actual values in the Generate_SQL API.
	** ----------------------------------------------------------
	*/
	Function Construct_SELECT_Clause(p_View_BY IN VARCHAR2, p_Select_List IN VARCHAR2)
	RETURN VARCHAR2 IS
	l_Buffer	VARCHAR2(200);
	l_ViewBY_Indentifier	VARCHAR2(1);
	l_Select_List	VARCHAR2(3200):=' SELECT ';
	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Entering Construct_Select_Clause...','Construct_Select_Clause');
		END IF;

		IF p_View_BY IS NOT NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Determining Viewby base column...');
			END IF;
			l_Buffer:=Get_ViewBY_Base_Column(p_View_BY);
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done determining Viewby base column. Value : '||l_Buffer);
			END IF;
		END IF;

		IF l_Buffer IS NOT NULL THEN
			l_ViewBY_Indentifier:='Y';
			l_Select_List:=l_Select_List||'FACT.'||l_Buffer||' "VIEWBY" ';
		ELSE
			l_Select_List:=l_Select_List||'1 "CONSTANT" ';
		END IF;

		l_Select_List:=l_Select_List||', '||p_Select_List;

		l_Select_List:=l_Select_List||' FROM TABLE(<<DEV_PL/SQL_EXTENSION>>(<<PL/SQL PARAMS>>)) FACT ';

		IF (p_View_BY NOT LIKE '%TIME%' OR l_ViewBY_Indentifier IS NULL) THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Generating the order by clause.');
			END IF;
			l_Select_List:=l_Select_List||' &ORDER_BY_CLAUSE ';
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('l_Select_List :'||l_Select_List);
			Write2FWKLog('Exiting Construct_Select_Clause...');
		END IF;

		RETURN l_Select_List;

	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Construct_Select_Clause;

	/*
	** ----------------------------------------------------------
	** Function: Generate_SQL
	** This Function generates the select statement based on the
	** parameters selected by the user.
	** ----------------------------------------------------------
	*/
	Procedure Generate_SQL(p_page_parameter_tbl	IN 	BIS_PMV_PAGE_PARAMETER_TBL
					, p_SQL_Statement		IN OUT NOCOPY VARCHAR2
					, p_PMV_Output		IN OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
					, p_Region_Code		IN 	VARCHAR2
					, p_PLSQL_Driver 		IN	VARCHAR2
					, p_PLSQL_Driver_Params 	IN	VARCHAR2
					)
	IS
	l_Sql_Statement		VARCHAR2(3200);
	l_PMV_Output		BIS_QUERY_ATTRIBUTES_TBL:=BIS_QUERY_ATTRIBUTES_TBL();
	l_PMV_Rec			BIS_QUERY_ATTRIBUTES;
	l_PMV_Rec_Ctr		NUMBER:=1;
	l_Exists_Flag		VARCHAR2(1):='N';
	l_Period_Type_Found	VARCHAR2(1);
	l_View_BY_Found		VARCHAR2(1);

	l_View_BY			VARCHAR2(150);
	l_Report_Name		VARCHAR2(150):=p_Region_Code;
	l_PLSQL_Driver		VARCHAR2(150):=p_PLSQL_Driver;
	l_PLSQL_Driver_Params	VARCHAR2(1000):=p_PLSQL_Driver_Params;

	l_Report_Parameters	VARCHAR2(3000);
	l_Substitute_Var		VARCHAR2(150);
	l_View_BY_Pattern		VARCHAR2(3);
	l_Parameter_Pattern	VARCHAR2(150);

	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			PJI_UTILS.RESET_SSWA_SESSION_CACHE;
			Write2FWKLog('Entering Generate_SQL...','Generate_SQL');
		END IF;

		l_PMV_Rec:=BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before Calling Init...','Generate_SQL');
		END IF;
		Init(l_Report_Name);
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After Calling Init...','Generate_SQL');
		END IF;

		FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
			IF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('User specified the view by for the report. ViewBY :'||p_page_parameter_tbl(i).parameter_value,'Generate_SQL');
				END IF;
				l_View_By := p_page_parameter_tbl(i).parameter_value;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_ViewBY :'||l_View_By,'Generate_SQL');
				END IF;
			END IF;
		END LOOP;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before calling Construct_SELECT_Clause.','Generate_SQL');
		END IF;
		l_Sql_Statement:=Construct_SELECT_Clause(l_View_BY);
		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After calling Construct_SELECT_Clause.','Generate_SQL');
		END IF;

		IF l_View_BY IS NOT NULL THEN
			l_PMV_Rec.attribute_name:=BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
			l_PMV_Rec.attribute_value:=l_View_BY;
			l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;

			l_PMV_Output.EXTEND();
			l_PMV_Output(l_PMV_Rec_Ctr):=l_PMV_Rec;

			l_PMV_Rec_Ctr:=l_PMV_Rec_Ctr+1;
		END IF;

		l_Sql_Statement:=REPLACE(l_Sql_Statement,'<<DEV_PL/SQL_EXTENSION>>',l_PLSQL_Driver);

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before parsing all the parameters.','Generate_SQL');
		END IF;
		FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

			l_Report_Parameters:=NULL;
			l_Substitute_Var:=NULL;
			l_Parameter_Pattern:=p_page_parameter_tbl(i).parameter_name;

			IF p_page_parameter_tbl(i).parameter_name LIKE 'TIME+%FROM' AND p_page_parameter_tbl(i).parameter_name NOT LIKE 'TIME+%PFROM' THEN
				l_Parameter_Pattern:='START_TIME';
				l_Substitute_Var:='PJI_START_TIME';
				l_Report_Parameters:=TO_CHAR(p_page_parameter_tbl(i).period_date,'j');
			ELSIF p_page_parameter_tbl(i).parameter_name LIKE 'TIME+%TO' AND p_page_parameter_tbl(i).parameter_name NOT LIKE 'TIME+%PTO' THEN
				l_Parameter_Pattern:='END_TIME';
				l_Substitute_Var:='PJI_END_TIME';
				l_Report_Parameters:=TO_CHAR(p_page_parameter_tbl(i).period_date,'j');
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
				l_Substitute_Var:='PJI_PERIOD_TYPE';
				l_Period_Type_Found:='Y';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME_COMPARISON_TYPE' THEN
				l_Substitute_Var:='PJI_TIME_COMPARISON_TYPE';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
				l_Substitute_Var:='PJI_VIEW_BY';
				l_Report_Parameters:=Convert_ViewBY(p_page_parameter_tbl(i).parameter_value);
				l_View_BY_Found:='Y';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
				l_Substitute_Var:='PJI_AS_OF_DATE';
				l_Report_Parameters:=TO_CHAR(TO_DATE(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY'),'j');
			ELSIF p_page_parameter_tbl(i).parameter_name = 'AVAILABILITY_DAYS+AVAILABILITY_DAYS' THEN
				l_Substitute_Var:='PJI_REP_DIM_32';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'AVAILABILITY_THRESHOLD+AVAILABILITY_THRESHOLD' THEN
				l_Substitute_Var:='PJI_REP_DIM_28';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'AVAILABILITY_TYPE+AVAILABILITY_TYPE' THEN
				l_Substitute_Var:='PJI_REP_DIM_29';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
				l_Substitute_Var:='PJI_REP_DIM_27';
				l_Report_Parameters:=Convert_Currency_Code(REPLACE(p_page_parameter_tbl(i).parameter_id,''''));
			ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
				l_Substitute_Var:='PJI_REP_DIM_01';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+PJI_ORGANIZATIONS' THEN
				l_Substitute_Var:='PJI_REP_DIM_02';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT CLASSIFICATION+CLASS_CATEGORY' THEN
				l_Substitute_Var:='PJI_REP_DIM_25';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT CLASSIFICATION+CLASS_CODE' THEN
				l_Substitute_Var:='PJI_REP_DIM_26';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT JOB LEVEL+PJI_JOB_LEVELS' THEN
				l_Substitute_Var:='PJI_REP_DIM_24';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT WORK TYPE+PJI_UTIL_CATEGORIES' THEN
				l_Substitute_Var:='PJI_REP_DIM_21';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT WORK TYPE+PJI_WORK_TYPES' THEN
				l_Substitute_Var:='PJI_REP_DIM_22';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT+PJI_PROJECTS' THEN
				l_Substitute_Var:='PJI_REP_DIM_31';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'REV_AT_RISK_FLAG+REV_AT_RISK_FLAG' THEN
				l_Substitute_Var:='PJI_REP_DIM_33';

                        ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES' THEN
                                l_Substitute_Var:='PJI_REP_DIM_34';
                        ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES' THEN
                                l_Substitute_Var:='PJI_REP_DIM_35';
                        ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES' THEN
                                l_Substitute_Var:='PJI_REP_DIM_36';
                        ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT REVENUE CATEGORY+PJI_EXP_EVT_TYPES' THEN
                                l_Substitute_Var:='PJI_REP_DIM_37';
			END IF;

			IF l_Report_Parameters IS NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_Report_Parameters is not set.','Generate_SQL');
				END IF;
				l_Report_Parameters:=REPLACE(p_page_parameter_tbl(i).parameter_id,'''');
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_Report_Parameters :'||l_Report_Parameters,'Generate_SQL');
				END IF;
			END IF;

			IF l_Report_Parameters IS NULL OR UPPER(p_page_parameter_tbl(i).parameter_value) = 'ALL' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_Report_Parameters is not set in the report or defaulted to all.','Generate_SQL');
				END IF;
				/*
				** Added the extra check to default currency when it is specified as 'All'
				*/
				IF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
					l_Report_Parameters:='G';
				ELSE
					l_Report_Parameters:=NULL;
				END IF;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_Report_Parameters :'||l_Report_Parameters,'Generate_SQL');
				END IF;
			END IF;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('l_Parameter_Name :'||p_page_parameter_tbl(i).parameter_name,'Generate_SQL');
				Write2FWKLog('l_Parameter_Pattern :'||l_Parameter_Pattern,'Generate_SQL');
				Write2FWKLog('l_Report_Parameters :'||l_Report_Parameters,'Generate_SQL');
				Write2FWKLog('l_Substitute_Var :'||l_Substitute_Var,'Generate_SQL');
				Write2FWKLog('Before replacing the driver params.','Generate_SQL');
				Write2FWKLog('l_PLSQL_Driver_Params :'||l_PLSQL_Driver_Params,'Generate_SQL');
			END IF;


			IF l_Substitute_Var LIKE 'PJI%' AND l_Substitute_Var IS NOT NULL THEN
				l_Exists_Flag:='N';

				FOR j in 1..l_PMV_Output.COUNT LOOP
					IF l_PMV_Output(j).attribute_name = ':'||l_Substitute_Var THEN
						l_Exists_Flag:='Y';
					END IF;
				END LOOP;

				IF l_Exists_Flag = 'N' THEN
					l_PMV_Rec.attribute_name:=':'||l_Substitute_Var;
					l_PMV_Rec.attribute_value:=l_Report_Parameters;
					l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;

					IF l_Substitute_Var = 'PJI_AS_OF_DATE' THEN
						l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
					ELSE
						l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
					END IF;

					l_PMV_Output.EXTEND();
					l_PMV_Output(l_PMV_Rec_Ctr):=l_PMV_Rec;
					l_PMV_Rec_Ctr:=l_PMV_Rec_Ctr+1;
				END IF;

				l_PLSQL_Driver_Params:=REPLACE(l_PLSQL_Driver_Params,'<<'||l_Parameter_Pattern||'>>',':'||l_Substitute_Var);
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After replacing the driver params.','Generate_SQL');
					Write2FWKLog('l_PLSQL_Driver_Params :'||l_PLSQL_Driver_Params,'Generate_SQL');
				END IF;
			END IF;
		END LOOP;

		IF l_View_By IS NULL AND l_View_BY_Found IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('No View BY is specified. Hence substituting the view by with a dummy value.','Generate_SQL');
			END IF;
			l_PMV_Rec.attribute_name:=':PJI_VIEW_BY';
			l_PMV_Rec.attribute_value:='XX';
			l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
			l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
			l_PMV_Output.EXTEND();
			l_PMV_Output(l_PMV_Rec_Ctr):=l_PMV_Rec;
			l_PMV_Rec_Ctr:=l_PMV_Rec_Ctr+1;
			l_PLSQL_Driver_Params:=REPLACE(l_PLSQL_Driver_Params,'<<VIEW_BY>>',':PJI_VIEW_BY');
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done with substituting the view by with a dummy value.','Generate_SQL');
			END IF;
		ELSIF l_View_By LIKE 'TIME+%TIME%' AND l_Period_Type_Found IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('No Period Type is specified (Availability Trend Option).','Generate_SQL');
				Write2FWKLog('Defaulting the period type to view by time dimension.','Generate_SQL');
			END IF;
			l_PMV_Rec.attribute_name:=':PJI_PERIOD_TYPE';
			l_PMV_Rec.attribute_value:=SUBSTR(l_View_By,INSTR(l_View_By,'+')+1);
			l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
			l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
			l_PMV_Output.EXTEND();
			l_PMV_Output(l_PMV_Rec_Ctr):=l_PMV_Rec;
			l_PMV_Rec_Ctr:=l_PMV_Rec_Ctr+1;
			l_PLSQL_Driver_Params:=REPLACE(l_PLSQL_Driver_Params,'<<PERIOD_TYPE>>',':PJI_PERIOD_TYPE');
		END IF;

		/*
		** The following portion of the code is commented.
		** Please uncomment it for debugging purposes only.
		*/

		IF p_PA_DEBUG_MODE = 'Y' THEN
			FOR i in 1..l_PMV_Output.LAST loop
				Write2FWKLog(l_PMV_Output(i).attribute_name||' - '||l_PMV_Output(i).attribute_value||' - '||l_PMV_Output(i).attribute_type||' - '||l_PMV_Output(i).attribute_data_type, 'Check');
			END LOOP;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After parsing all the parameters.','Generate_SQL');
			Write2FWKLog('Before replacing the dimension patterns with NULL values.','Generate_SQL');
		END IF;

		FOR i IN G_dimension_level_tab.first..G_dimension_level_tab.last LOOP
			l_PLSQL_Driver_Params:=REPLACE(l_PLSQL_Driver_Params,'<<'||G_dimension_level_tab(i)||'>>','NULL');
		END LOOP;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After replacing the dimension patterns with NULL values.','Generate_SQL');
			Write2FWKLog('Before replacing the <<PL/SQL PARAMS>> pattern with actual values.','Generate_SQL');
		END IF;
		l_Sql_Statement:=REPLACE(l_Sql_Statement,'<<PL/SQL PARAMS>>',l_PLSQL_Driver_Params);

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After replacing the <<PL/SQL PARAMS>> pattern with actual values.','Generate_SQL');
			Write2FWKLog('Finally, the SQL Statement :'||l_Sql_Statement,'Generate_SQL');
			Write2FWKLog('Exiting Generate_SQL...','Generate_SQL');
		END IF;

		p_Sql_Statement:=l_Sql_Statement;
		p_PMV_Output:=l_PMV_Output;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Generate_SQL;

	/* New Version of Generate_SQL
	** ----------------------------------------------------------
	** Function: Generate_SQL
	** This Function generates the select statement based on the
	** parameters selected by the user.
	** ----------------------------------------------------------
	*/
	Procedure Generate_SQL(p_page_parameter_tbl	IN 	BIS_PMV_PAGE_PARAMETER_TBL
					, p_Select_List		IN	VARCHAR2
					, p_SQL_Statement		IN OUT NOCOPY VARCHAR2
					, p_PMV_Output		IN OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
					, p_Region_Code		IN 	VARCHAR2
					, p_PLSQL_Driver 		IN	VARCHAR2
					, p_PLSQL_Driver_Params 	IN	VARCHAR2
					)
	IS
	l_Sql_Statement		VARCHAR2(3200);
	l_PMV_Output		BIS_QUERY_ATTRIBUTES_TBL:=BIS_QUERY_ATTRIBUTES_TBL();
	l_PMV_Rec			BIS_QUERY_ATTRIBUTES;
	l_PMV_Rec_Ctr		NUMBER:=1;
	l_Exists_Flag		VARCHAR2(1):='N';
	l_Period_Type_Found	VARCHAR2(1);
	l_View_BY_Found		VARCHAR2(1);

	l_View_BY			VARCHAR2(150);
	l_Report_Name		VARCHAR2(150):=p_Region_Code;
	l_PLSQL_Driver		VARCHAR2(150):=p_PLSQL_Driver;
	l_PLSQL_Driver_Params	VARCHAR2(1000):=p_PLSQL_Driver_Params;

	l_Report_Parameters	VARCHAR2(3000);
	l_Substitute_Var		VARCHAR2(150);
	l_View_BY_Pattern		VARCHAR2(3);
	l_Parameter_Pattern	VARCHAR2(150);

	l_Start_Char_Pos		NUMBER:=0;

	BEGIN
		IF p_PA_DEBUG_MODE = 'Y' THEN
			PJI_UTILS.RESET_SSWA_SESSION_CACHE;
			Write2FWKLog('Entering Generate_SQL...','Generate_SQL');
		END IF;

		l_PMV_Rec:=BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

		FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
			IF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('User specified the view by for the report. ViewBY :'||p_page_parameter_tbl(i).parameter_value,'Generate_SQL');
				END IF;
				l_View_By := p_page_parameter_tbl(i).parameter_value;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_ViewBY :'||l_View_By,'Generate_SQL');
				END IF;
			END IF;
		END LOOP;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before calling Construct_SELECT_Clause.','Generate_SQL');
		END IF;
		l_Sql_Statement:=Construct_SELECT_Clause(l_View_BY, p_Select_List);

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After calling Construct_SELECT_Clause.','Generate_SQL');
		END IF;

		IF l_View_BY IS NOT NULL THEN
			l_PMV_Rec.attribute_name:=BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
			l_PMV_Rec.attribute_value:=l_View_BY;
			l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;

			l_PMV_Output.EXTEND();
			l_PMV_Output(l_PMV_Rec_Ctr):=l_PMV_Rec;

			l_PMV_Rec_Ctr:=l_PMV_Rec_Ctr+1;
		END IF;

		l_Sql_Statement:=REPLACE(l_Sql_Statement,'<<DEV_PL/SQL_EXTENSION>>',l_PLSQL_Driver);

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('Before parsing all the parameters.','Generate_SQL');
		END IF;
		FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

			l_Report_Parameters:=NULL;
			l_Substitute_Var:=NULL;
			l_Parameter_Pattern:=p_page_parameter_tbl(i).parameter_name;

			IF p_page_parameter_tbl(i).parameter_name LIKE 'TIME+%FROM' AND p_page_parameter_tbl(i).parameter_name NOT LIKE 'TIME+%PFROM' THEN
				l_Parameter_Pattern:='START_TIME';
				l_Substitute_Var:='PJI_START_TIME';
				l_Report_Parameters:=TO_CHAR(p_page_parameter_tbl(i).period_date,'j');
			ELSIF p_page_parameter_tbl(i).parameter_name LIKE 'TIME+%TO' AND p_page_parameter_tbl(i).parameter_name NOT LIKE 'TIME+%PTO' THEN
				l_Parameter_Pattern:='END_TIME';
				l_Substitute_Var:='PJI_END_TIME';
				l_Report_Parameters:=TO_CHAR(p_page_parameter_tbl(i).period_date,'j');
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
				IF l_View_BY LIKE 'TIME+%TIME%' THEN
					/*
					** Reset the value of view by to period type
					** for trend reports (viewby time).
					*/
					l_PMV_Output(1).attribute_value := 'TIME+'||p_page_parameter_tbl(i).parameter_value;
				END IF;
				l_Substitute_Var:='PJI_PERIOD_TYPE';
				l_Period_Type_Found:='Y';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME_COMPARISON_TYPE' THEN
				l_Substitute_Var:='PJI_TIME_COMPARISON_TYPE';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
				l_Substitute_Var:='PJI_VIEW_BY';
				l_Report_Parameters:=Convert_ViewBY(p_page_parameter_tbl(i).parameter_value);
				l_View_BY_Found:='Y';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
				l_Substitute_Var:='PJI_AS_OF_DATE';
				l_Report_Parameters:=TO_CHAR(TO_DATE(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY'),'j');
			ELSIF p_page_parameter_tbl(i).parameter_name = 'AVAILABILITY_DAYS+AVAILABILITY_DAYS' THEN
				l_Substitute_Var:='PJI_REP_DIM_32';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'AVAILABILITY_THRESHOLD+AVAILABILITY_THRESHOLD' THEN
				l_Substitute_Var:='PJI_REP_DIM_28';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'AVAILABILITY_TYPE+AVAILABILITY_TYPE' THEN
				l_Substitute_Var:='PJI_REP_DIM_29';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
				l_Substitute_Var:='PJI_REP_DIM_27';
				l_Report_Parameters:=Convert_Currency_Code(REPLACE(p_page_parameter_tbl(i).parameter_id,''''));
			ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+FII_OPERATING_UNITS' THEN
				l_Substitute_Var:='PJI_REP_DIM_01';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+PJI_ORGANIZATIONS' THEN
				l_Substitute_Var:='PJI_REP_DIM_02';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT CLASSIFICATION+CLASS_CATEGORY' THEN
				l_Substitute_Var:='PJI_REP_DIM_25';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT CLASSIFICATION+CLASS_CODE' THEN
				l_Substitute_Var:='PJI_REP_DIM_26';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT JOB LEVEL+PJI_JOB_LEVELS' THEN
				l_Substitute_Var:='PJI_REP_DIM_24';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT WORK TYPE+PJI_UTIL_CATEGORIES' THEN
				l_Substitute_Var:='PJI_REP_DIM_21';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT WORK TYPE+PJI_WORK_TYPES' THEN
				l_Substitute_Var:='PJI_REP_DIM_22';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT+PJI_PROJECTS' THEN
				l_Substitute_Var:='PJI_REP_DIM_31';
			ELSIF p_page_parameter_tbl(i).parameter_name = 'REV_AT_RISK_FLAG+REV_AT_RISK_FLAG' THEN
				l_Substitute_Var:='PJI_REP_DIM_33';


                        ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT EXPENDITURE TYPE+PJI_EXP_CATEGORIES' THEN
                                l_Substitute_Var:='PJI_REP_DIM_34';
                        ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT EXPENDITURE TYPE+PJI_EXP_TYPES' THEN
                                l_Substitute_Var:='PJI_REP_DIM_35';
                        ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT REVENUE CATEGORY+PJI_REVENUE_CATEGORIES' THEN
                                l_Substitute_Var:='PJI_REP_DIM_36';
                        ELSIF p_page_parameter_tbl(i).parameter_name = 'PROJECT REVENUE CATEGORY+PJI_EXP_EVT_TYPES' THEN
                                l_Substitute_Var:='PJI_REP_DIM_37';
			END IF;

			IF l_Report_Parameters IS NULL THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_Report_Parameters is not set.','Generate_SQL');
				END IF;
				l_Report_Parameters:=REPLACE(p_page_parameter_tbl(i).parameter_id,'''');
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_Report_Parameters :'||l_Report_Parameters,'Generate_SQL');
				END IF;
			END IF;

			IF l_Report_Parameters IS NULL OR UPPER(p_page_parameter_tbl(i).parameter_value) = 'ALL' THEN
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_Report_Parameters is not set in the report or defaulted to all.','Generate_SQL');
				END IF;
				/*
				** Added the extra check to default currency when it is specified as 'All'
				*/
				IF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
					l_Report_Parameters:='G';
				ELSE
					l_Report_Parameters:=NULL;
				END IF;
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('l_Report_Parameters :'||l_Report_Parameters,'Generate_SQL');
				END IF;
			END IF;

			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('l_Parameter_Name :'||p_page_parameter_tbl(i).parameter_name,'Generate_SQL');
				Write2FWKLog('l_Parameter_Pattern :'||l_Parameter_Pattern,'Generate_SQL');
				Write2FWKLog('l_Report_Parameters :'||l_Report_Parameters,'Generate_SQL');
				Write2FWKLog('l_Substitute_Var :'||l_Substitute_Var,'Generate_SQL');
				Write2FWKLog('Before replacing the driver params.','Generate_SQL');
				Write2FWKLog('l_PLSQL_Driver_Params :'||l_PLSQL_Driver_Params,'Generate_SQL');
			END IF;

			IF l_Substitute_Var LIKE 'PJI%' AND l_Substitute_Var IS NOT NULL THEN
				l_Exists_Flag:='N';

				FOR j in 1..l_PMV_Output.COUNT LOOP
					IF l_PMV_Output(j).attribute_name = ':'||l_Substitute_Var THEN
						l_Exists_Flag:='Y';
					END IF;
				END LOOP;

				IF l_Exists_Flag = 'N' THEN
					l_PMV_Rec.attribute_name:=':'||l_Substitute_Var;
					l_PMV_Rec.attribute_value:=l_Report_Parameters;
					l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;

					IF l_Substitute_Var = 'PJI_AS_OF_DATE' THEN
						l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
					ELSE
						l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
					END IF;

					l_PMV_Output.EXTEND();
					l_PMV_Output(l_PMV_Rec_Ctr):=l_PMV_Rec;
					l_PMV_Rec_Ctr:=l_PMV_Rec_Ctr+1;
				END IF;

				l_PLSQL_Driver_Params:=REPLACE(l_PLSQL_Driver_Params,'<<'||l_Parameter_Pattern||'>>',':'||l_Substitute_Var);
				IF p_PA_DEBUG_MODE = 'Y' THEN
					Write2FWKLog('After replacing the driver params.','Generate_SQL');
					Write2FWKLog('l_PLSQL_Driver_Params :'||l_PLSQL_Driver_Params,'Generate_SQL');
				END IF;
			END IF;
		END LOOP;

		IF l_View_By IS NULL AND l_View_BY_Found IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('No View BY is specified. Hence substituting the view by with a dummy value.','Generate_SQL');
			END IF;
			l_PMV_Rec.attribute_name:=':PJI_VIEW_BY';
			l_PMV_Rec.attribute_value:='XX';
			l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
			l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
			l_PMV_Output.EXTEND();
			l_PMV_Output(l_PMV_Rec_Ctr):=l_PMV_Rec;
			l_PMV_Rec_Ctr:=l_PMV_Rec_Ctr+1;
			l_PLSQL_Driver_Params:=REPLACE(l_PLSQL_Driver_Params,'<<VIEW_BY>>',':PJI_VIEW_BY');
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('Done with substituting the view by with a dummy value.','Generate_SQL');
			END IF;
		ELSIF l_View_By LIKE 'TIME+%TIME%' AND l_Period_Type_Found IS NULL THEN
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog('No Period Type is specified (Availability Trend Option).','Generate_SQL');
				Write2FWKLog('Defaulting the period type to view by time dimension.','Generate_SQL');
			END IF;
			l_PMV_Rec.attribute_name:=':PJI_PERIOD_TYPE';
			l_PMV_Rec.attribute_value:=SUBSTR(l_View_By,INSTR(l_View_By,'+')+1);
			l_PMV_Rec.attribute_type:=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
			l_PMV_Rec.attribute_data_type:=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
			l_PMV_Output.EXTEND();
			l_PMV_Output(l_PMV_Rec_Ctr):=l_PMV_Rec;
			l_PMV_Rec_Ctr:=l_PMV_Rec_Ctr+1;
			l_PLSQL_Driver_Params:=REPLACE(l_PLSQL_Driver_Params,'<<PERIOD_TYPE>>',':PJI_PERIOD_TYPE');
		END IF;

		/*
		** The following portion of the code is commented.
		** Please uncomment it for debugging purposes only.
		*/

		IF p_PA_DEBUG_MODE = 'Y' THEN
			FOR i in 1..l_PMV_Output.LAST loop
				Write2FWKLog(l_PMV_Output(i).attribute_name||' - '||l_PMV_Output(i).attribute_value||' - '||l_PMV_Output(i).attribute_type||' - '||l_PMV_Output(i).attribute_data_type, 'Check');
			END LOOP;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After parsing all the parameters.','Generate_SQL');
			Write2FWKLog('Before replacing the dimension patterns with NULL values.','Generate_SQL');
		END IF;

		l_Start_Char_Pos := INSTR(l_PLSQL_Driver_Params,'<<');

		IF l_Start_Char_Pos>0 THEN
			WHILE l_Start_Char_Pos>0 LOOP
				l_PLSQL_Driver_Params:=REPLACE(l_PLSQL_Driver_Params,SUBSTR(l_PLSQL_Driver_Params,l_Start_Char_Pos,INSTR(l_PLSQL_Driver_Params,'>>')-l_Start_Char_Pos+2),'NULL');
				l_Start_Char_Pos := INSTR(l_PLSQL_Driver_Params,'<<');
			END LOOP;
		END IF;

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After replacing the dimension patterns with NULL values.','Generate_SQL');
			Write2FWKLog('Before replacing the <<PL/SQL PARAMS>> pattern with actual values.','Generate_SQL');
		END IF;

		l_Sql_Statement:=REPLACE(l_Sql_Statement,'<<PL/SQL PARAMS>>',l_PLSQL_Driver_Params);

		IF p_PA_DEBUG_MODE = 'Y' THEN
			Write2FWKLog('After replacing the <<PL/SQL PARAMS>> pattern with actual values.','Generate_SQL');
			Write2FWKLog('Finally, the SQL Statement :'||l_Sql_Statement,'Generate_SQL');
			Write2FWKLog('Exiting Generate_SQL...','Generate_SQL');
		END IF;

		p_Sql_Statement:=l_Sql_Statement;
		p_PMV_Output:=l_PMV_Output;
	EXCEPTION
		WHEN OTHERS THEN
			g_SQL_Error_Msg:=SQLERRM();
			IF p_PA_DEBUG_MODE = 'Y' THEN
				Write2FWKLog(g_SQL_Error_Msg, 3);
			END IF;
			RAISE;
	END Generate_SQL;

END PJI_PMV_ENGINE;

/
