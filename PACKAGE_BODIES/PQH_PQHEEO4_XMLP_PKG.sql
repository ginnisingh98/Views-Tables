--------------------------------------------------------
--  DDL for Package Body PQH_PQHEEO4_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQHEEO4_XMLP_PKG" AS
/* $Header: PQHEEO4B.pls 120.1 2007/12/07 06:47:50 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_QUERY_TEXT VARCHAR2(2000);
  BEGIN
    --HR_STANDARD.EVENT('BEFORE REPORT');
    C_REPORT_TYPE := P_REPORT_YEAR || ' EEO-4 REPORT';
    DECLARE
      L_FR VARCHAR2(2000);
      L_FT VARCHAR2(2000);
      L_PR VARCHAR2(2000);
      L_PT VARCHAR2(2000);
      L_PROFILE_OPTION VARCHAR2(10);
      L_FUNCTION_CODE VARCHAR2(20);
      L_FUNCTION_NAME VARCHAR2(240);
      L_FUNCTION_COUNT NUMBER;
      L_DYNAMIC_WHERE VARCHAR2(4000) := ' ''XX'' ';
      L_REPORT_COMMAND VARCHAR2(500);
      L_REPORT_DATE DATE := TO_DATE(P_REPORT_DAY_MONTH || '-' || P_REPORT_YEAR
             ,'DD-MM-YYYY');
      L_FT_EMP_COUNT NUMBER;
      SOURCE_CURSOR INTEGER;
      ROWS_PROCESSED INTEGER;
      SELECT_CLAUSE VARCHAR2(2000) := 'count(peo.person_id) 				    cons_total_category_emps,
              count(decode(peo.per_information1,''1'',
                     decode(peo.sex,''M'',1,null),null)) no_cons_wmale_emps,
              count(decode(peo.per_information1,''2'',
                     decode(peo.sex,''M'',1,null),null)) no_cons_bmale_emps,
              count(decode(peo.per_information1,''3'',
                     decode(peo.sex,''M'',1,null),null)) no_cons_hmale_emps,
              count(decode(peo.per_information1,''4'',
                     decode(peo.sex,''M'',1,null),''5'',
                     decode(peo.sex,''M'',1,null),null)) no_cons_amale_emps,
              count(decode(peo.per_information1,''6'',
                     decode(peo.sex,''M'',1,null),''7'',
                     decode(peo.sex,''M'',1,null),null)) no_cons_imale_emps,
              count(decode(peo.per_information1,''1'',
                     decode(peo.sex,''F'',1,null),null)) no_cons_wfemale_emps,
              count(decode(peo.per_information1,''2'',
                     decode(peo.sex,''F'',1,null),null)) no_cons_bfemale_emps,
              count(decode(peo.per_information1,''3'',
                     decode(peo.sex,''F'',1,null),null)) no_cons_hfemale_emps,
              count(decode(peo.per_information1,''4'',
                     decode(peo.sex,''F'',1,null),''5'',
                     decode(peo.sex,''F'',1,null),null)) no_cons_afemale_emps,
              count(decode(peo.per_information1,''6'',
                     decode(peo.sex,''F'',1,null),''7'',
                     decode(peo.sex,''F'',1,null),null)) no_cons_ifemale_emps ';
      FROM_WHERE_CLAUSE VARCHAR2(10000) := '
      FROM   	per_all_people_f             	peo,
      	per_all_assignments_f        	ass,
              per_assignment_status_types     ast1,
      	per_pay_proposals		ppp,
      	per_jobs                      	job,
      	per_pay_bases			ppb,
      	hr_lookups			hl
      WHERE  	peo.person_id              	= ass.person_id
      AND	ass.pay_basis_id		= ppb.pay_basis_id
      AND	ass.assignment_id		= ppp.assignment_id
      AND	hl.lookup_code			= job.job_information1
      AND	job.job_information1		IS NOT NULL
      AND    	job.job_information_category   	= ''US''
      AND	hl.lookup_type			= ''US_EEO4_JOB_CATEGORIES''
      AND    	ass.job_id                     	= job.job_id
      AND     ass.primary_flag     		= ''Y''
      AND	ppp.change_date	= (SELECT  MAX(change_date)
      	FROM	per_pay_proposals  pro
      	WHERE	ppp.assignment_id	= pro.assignment_id
      	AND	pro.change_date		<= ''' || TO_CHAR(L_REPORT_DATE) || '''
              AND     pro.approved = ''Y'' )
      AND     ass.organization_id IN (
      	SELECT	organization_id
      	FROM	hr_all_organization_units
      	WHERE	business_group_id	= ' || TO_CHAR(P_BUSINESS_GROUP_ID) || '
      	AND	SYSDATE BETWEEN  date_from AND NVL(date_to,SYSDATE) )
      AND	ass.assignment_status_type_id 	= ast1.assignment_status_type_id
      AND     peo.current_employee_flag = ''Y''
      AND     ass.assignment_type = ''E''';
      L_FT_EFFECTIVE_DATES VARCHAR2(1000) := '
      AND 	''' || TO_CHAR(L_REPORT_DATE) || ''' BETWEEN peo.effective_start_date AND peo.effective_end_date
      AND	''' || TO_CHAR(L_REPORT_DATE) || ''' BETWEEN ass.effective_start_date AND ass.effective_end_date
      AND     ast1.per_system_status <> ''TERM_ASSIGN''';
      L_NH_EFFECTIVE_DATES VARCHAR2(1000) := 'AND (SELECT date_start
                                                   FROM   per_periods_of_service
                                                   WHERE  period_of_service_id = ass.period_of_service_id) BETWEEN ''' || TO_CHAR(ADD_MONTHS(L_REPORT_DATE
                        ,-12) + 1) || ''' AND ''' || TO_CHAR(L_REPORT_DATE) || ''' ';
      L_ROW_COUNT NUMBER := 0;
      L_FRC VARCHAR2(2000);
    BEGIN
      PQH_EMPLOYMENT_CATEGORY.FETCH_EMPL_CATEGORIES(P_BUSINESS_GROUP_ID
                                                   ,L_FR
                                                   ,L_FT
                                                   ,L_PR
                                                   ,L_PT);
      L_FRC := '(' || REPLACE(L_FR
                      ,','
                      ,''',''') || ')';
      SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;
      L_QUERY_TEXT := 'Select count(1) l_ft_emp_count' || FROM_WHERE_CLAUSE || L_FT_EFFECTIVE_DATES || 'AND  ass.employment_category in ' || L_FRC;
      DBMS_SQL.PARSE(SOURCE_CURSOR
                    ,L_QUERY_TEXT
                    ,2);
      DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR
                            ,1
                            ,L_FT_EMP_COUNT);
      ROWS_PROCESSED := DBMS_SQL.EXECUTE(SOURCE_CURSOR);
      IF DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0 THEN
        DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR
                             ,1
                             ,L_FT_EMP_COUNT);
      END IF;
      DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);
      SOURCE_CURSOR := DBMS_SQL.OPEN_CURSOR;
      L_QUERY_TEXT := 'Select job.job_information7  l_function_code,
                      				count(1) l_function_count ' || FROM_WHERE_CLAUSE || L_FT_EFFECTIVE_DATES || ' group by job.job_information7 ';
      DBMS_SQL.PARSE(SOURCE_CURSOR
                    ,L_QUERY_TEXT
                    ,2);
      DBMS_SQL.DEFINE_COLUMN_CHAR(SOURCE_CURSOR
                                 ,1
                                 ,L_FUNCTION_CODE
                                 ,10);
      DBMS_SQL.DEFINE_COLUMN(SOURCE_CURSOR
                            ,2
                            ,L_FUNCTION_COUNT);
      ROWS_PROCESSED := DBMS_SQL.EXECUTE(SOURCE_CURSOR);
      LOOP
        IF DBMS_SQL.FETCH_ROWS(SOURCE_CURSOR) > 0 THEN
          DBMS_SQL.COLUMN_VALUE_CHAR(SOURCE_CURSOR
                                    ,1
                                    ,L_FUNCTION_CODE);
          DBMS_SQL.COLUMN_VALUE(SOURCE_CURSOR
                               ,2
                               ,L_FUNCTION_COUNT);
          L_FUNCTION_CODE := RTRIM(L_FUNCTION_CODE);
          IF (L_FT_EMP_COUNT > P_BPT_FT_EMP_COUNT AND L_ROW_COUNT <= 14) OR (L_FT_EMP_COUNT < P_BPT_FT_EMP_COUNT AND L_FUNCTION_COUNT > P_BPT_EMP_COUNT_FUNC) THEN
            L_DYNAMIC_WHERE := L_DYNAMIC_WHERE || ',''' || L_FUNCTION_CODE || ''' ';
          END IF;
          IF (L_FT_EMP_COUNT > P_BPT_FT_EMP_COUNT AND L_ROW_COUNT > 14) OR (L_FT_EMP_COUNT < P_BPT_FT_EMP_COUNT) THEN
            IF FUNCTION_DESC IS NULL AND L_FUNCTION_CODE < 'XX' THEN
              FUNCTION_DESC := L_FUNCTION_CODE;
            ELSE
              FUNCTION_DESC := FUNCTION_DESC || ' ' || L_FUNCTION_CODE;
            END IF;
          END IF;
          L_ROW_COUNT := L_ROW_COUNT + 1;
        ELSE
          EXIT;
        END IF;
      END LOOP;
      DBMS_SQL.CLOSE_CURSOR(SOURCE_CURSOR);
      IF (L_FT_EMP_COUNT > P_BPT_FT_EMP_COUNT) THEN
        P_EEO4_QUERY := 'SELECT job.job_information7  Job_function_code,
										  PQH_PQHEEO4_XMLP_PKG.CP_1_P CP_1,
                                           PQH_PQHEEO4_XMLP_PKG.CF_TOTAL_TITLEFORMULA0005(DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					''FR'', ''1. FULL-TIME EMPLOYEES'',
                        					''2. OTHER THAN FULL-TIME EMPLOYEES'')) CF_TOTAL_TITLE,
                        				   PQH_PQHEEO4_XMLP_PKG.CF_SET_FUNCTION_DESCFORMULA(job.job_information7) CF_set_function_desc,
                        				   DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					''FR'', ''1. FULL-TIME EMPLOYEES'',
                        					''2. OTHER THAN FULL-TIME EMPLOYEES'') Employment_Category,
                        				   hl.lookup_code	job_category_code,
                        				   hl.meaning		Job_category_name,
                        				   pqh_salary_range_pkg.get_salary_range(
                        					pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					NVL(ppp.proposed_salary_n,0) * ppb.pay_annualization_factor) Salary_range, ' || SELECT_CLAUSE || FROM_WHERE_CLAUSE || L_FT_EFFECTIVE_DATES || '
                        			    AND  job.job_information7 IN (' || L_DYNAMIC_WHERE || ')
                        			    GROUP BY 	job.job_information7,
                        				   DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        						''FR'', ''1. FULL-TIME EMPLOYEES'',
                        						''2. OTHER THAN FULL-TIME EMPLOYEES''),
                        					hl.lookup_code	,
                        					hl.meaning	,
                        				   	pqh_salary_range_pkg.get_salary_range(
                        						pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        						NVL(ppp.proposed_salary_n,0) * ppb.pay_annualization_factor)
                        			    UNION
                        			    SELECT  job.job_information7,
                        			    PQH_PQHEEO4_XMLP_PKG.CP_1_P CP_1,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_TOTAL_TITLEFORMULA0005(''3. NEW HIRE DURING FISCAL YEAR - PERMANENT FULL TIME ONLY'') CF_TOTAL_TITLE,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_SET_FUNCTION_DESCFORMULA(job.job_information7) CF_set_function_desc,
                        				    ''3. NEW HIRE DURING FISCAL YEAR - PERMANENT FULL TIME ONLY'',
                        				    hl.lookup_code	job_category_code,
                        				    hl.meaning		Job_category_name,
                        				    '' '', ' || SELECT_CLAUSE || FROM_WHERE_CLAUSE || L_NH_EFFECTIVE_DATES || '
                        			    AND  ass.employment_category in  ' || L_FRC || '
                        			    AND  job.job_information7 IN (' || L_DYNAMIC_WHERE || ')
                        			    GROUP BY job.job_information7,
                        				     hl.lookup_code,
                        				     hl.meaning
                        			    UNION
                        			    SELECT ''XX'',
                        			    PQH_PQHEEO4_XMLP_PKG.CP_1_P CP_1,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_TOTAL_TITLEFORMULA0005(DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					''FR'', ''1. FULL-TIME EMPLOYEES'',
                        					''2. OTHER THAN FULL-TIME EMPLOYEES'')) CF_TOTAL_TITLE,
                        				PQH_PQHEEO4_XMLP_PKG.CF_SET_FUNCTION_DESCFORMULA(''XX'') CF_set_function_desc,
                        				   DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					''FR'', ''1. FULL-TIME EMPLOYEES'',
                        					''2. OTHER THAN FULL-TIME EMPLOYEES'') ,
                        				   hl.lookup_code	,
                        				   hl.meaning		,
                           				   pqh_salary_range_pkg.get_salary_range(
                        					pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					NVL(ppp.proposed_salary_n,0) * ppb.pay_annualization_factor),  ' || SELECT_CLAUSE || FROM_WHERE_CLAUSE || L_FT_EFFECTIVE_DATES || '
                        			    AND  job.job_information7  NOT IN (' || L_DYNAMIC_WHERE || ')
                        			    GROUP BY
                        				   DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        						''FR'', ''1. FULL-TIME EMPLOYEES'',
                        						''2. OTHER THAN FULL-TIME EMPLOYEES''),
                        					hl.lookup_code	,
                        					hl.meaning	,
                        				  	pqh_salary_range_pkg.get_salary_range(
                        						pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        						NVL(ppp.proposed_salary_n,0) * ppb.pay_annualization_factor)
                        			    UNION
                        			    SELECT  ''XX'',
                        			    PQH_PQHEEO4_XMLP_PKG.CP_1_P CP_1,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_TOTAL_TITLEFORMULA0005(''3. NEW HIRE DURING FISCAL YEAR - PERMANENT FULL TIME ONLY'') CF_TOTAL_TITLE,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_SET_FUNCTION_DESCFORMULA(''XX'') CF_set_function_desc,
                        				    ''3. NEW HIRE DURING FISCAL YEAR - PERMANENT FULL TIME ONLY'',
                        				    hl.lookup_code	job_category_code,
                        				    hl.meaning		Job_category_name,
                        				    '' '', ' || SELECT_CLAUSE || FROM_WHERE_CLAUSE || L_NH_EFFECTIVE_DATES || '
                        			    AND  ass.employment_category in  ' || L_FRC || '
                        			    AND  job.job_information7  NOT IN (' || L_DYNAMIC_WHERE || ')
                        			    GROUP BY
                        				     hl.lookup_code,
                        				     hl.meaning	';
      ELSE
        P_EEO4_QUERY := 'SELECT job.job_information7  Job_function_code,
						PQH_PQHEEO4_XMLP_PKG.CP_1_P CP_1,
						PQH_PQHEEO4_XMLP_PKG.CF_TOTAL_TITLEFORMULA0005(DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					''FR'', ''1. FULL-TIME EMPLOYEES'',
                        					''2. OTHER THAN FULL-TIME EMPLOYEES'')) CF_TOTAL_TITLE,
                        PQH_PQHEEO4_XMLP_PKG.CF_SET_FUNCTION_DESCFORMULA(job.job_information7) CF_set_function_desc,
                        				   DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					''FR'', ''1. FULL-TIME EMPLOYEES'',
                        					''2. OTHER THAN FULL-TIME EMPLOYEES'') Employment_Category,
                        				   hl.lookup_code	job_category_code,
                        				   hl.meaning		Job_category_name,
                        				   pqh_salary_range_pkg.get_salary_range(
                        					pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					NVL(ppp.proposed_salary_n,0) * ppb.pay_annualization_factor) Salary_range, ' || SELECT_CLAUSE || FROM_WHERE_CLAUSE || L_FT_EFFECTIVE_DATES || '
                        			    AND  job.job_information7 IN (' || L_DYNAMIC_WHERE || ')
                        			    GROUP BY 	job.job_information7,
                        				   DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        						''FR'', ''1. FULL-TIME EMPLOYEES'',
                        						''2. OTHER THAN FULL-TIME EMPLOYEES''),
                        					hl.lookup_code	,
                        					hl.meaning	,
                        				   	pqh_salary_range_pkg.get_salary_range(
                        						pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        						NVL(ppp.proposed_salary_n,0) * ppb.pay_annualization_factor)
                        			    UNION
                        			    SELECT  job.job_information7,
                        			    PQH_PQHEEO4_XMLP_PKG.CP_1_P CP_1,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_TOTAL_TITLEFORMULA0005(''3. NEW HIRE DURING FISCAL YEAR - PERMANENT FULL TIME ONLY'') CF_TOTAL_TITLE,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_SET_FUNCTION_DESCFORMULA(job.job_information7) CF_set_function_desc,
                        				    ''3. NEW HIRE DURING FISCAL YEAR - PERMANENT FULL TIME ONLY'',
                        				    hl.lookup_code	job_category_code,
                        				    hl.meaning		Job_category_name,
                        				    '' '', ' || SELECT_CLAUSE || FROM_WHERE_CLAUSE || L_NH_EFFECTIVE_DATES || '
                        			    AND  job.job_information7 IN (' || L_DYNAMIC_WHERE || ')
                        			    AND  ass.employment_category in  ' || L_FRC || '
                        			    GROUP BY job.job_information7,
                        				     hl.lookup_code,
                        				     hl.meaning
                        			   UNION
                        			   SELECT ''XX''  ,
                        			   PQH_PQHEEO4_XMLP_PKG.CP_1_P CP_1,
                        			   PQH_PQHEEO4_XMLP_PKG.CF_TOTAL_TITLEFORMULA0005(DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					''FR'', ''1. FULL-TIME EMPLOYEES'',
                        					''2. OTHER THAN FULL-TIME EMPLOYEES'')) CF_TOTAL_TITLE,
                       					PQH_PQHEEO4_XMLP_PKG.CF_SET_FUNCTION_DESCFORMULA(''XX'') CF_set_function_desc,
                        				   DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					''FR'', ''1. FULL-TIME EMPLOYEES'',
                        					''2. OTHER THAN FULL-TIME EMPLOYEES'') ,
                        				   hl.lookup_code	,
                        				   hl.meaning		,
                        				   pqh_salary_range_pkg.get_salary_range(
                        					pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        					NVL(ppp.proposed_salary_n,0) * ppb.pay_annualization_factor) , ' || SELECT_CLAUSE || FROM_WHERE_CLAUSE || L_FT_EFFECTIVE_DATES || '
                        			    GROUP BY
                        				   DECODE(pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        						''FR'', ''1. FULL-TIME EMPLOYEES'',
                        						''2. OTHER THAN FULL-TIME EMPLOYEES''),
                        					hl.lookup_code	,
                        					hl.meaning	,
                        				   	pqh_salary_range_pkg.get_salary_range(
                        						pqh_employment_category.identify_empl_category(ass.employment_category,' || L_FR || ',' || L_FT || ',' || L_PR || ',' || L_PT || '),
                        						NVL(ppp.proposed_salary_n,0) * ppb.pay_annualization_factor)
                        			    UNION
                        			    SELECT  ''XX'',
                        			    PQH_PQHEEO4_XMLP_PKG.CP_1_P CP_1,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_TOTAL_TITLEFORMULA0005(''3. NEW HIRE DURING FISCAL YEAR - PERMANENT FULL TIME ONLY'') CF_TOTAL_TITLE,
                        			    PQH_PQHEEO4_XMLP_PKG.CF_SET_FUNCTION_DESCFORMULA(''XX'') CF_set_function_desc,
                        				    ''3. NEW HIRE DURING FISCAL YEAR - PERMANENT FULL TIME ONLY'',
                        				    hl.lookup_code	job_category_code,
                        				    hl.meaning		Job_category_name,
                        				    '' '', ' || SELECT_CLAUSE || FROM_WHERE_CLAUSE || L_NH_EFFECTIVE_DATES || '
                        			    AND  ass.employment_category in  ' || L_FRC || '
                        			    GROUP BY
                        				     hl.lookup_code,
                        				     hl.meaning	';
      END IF;
    END;
    RETURN TRUE;
  END BEFOREREPORT;

  FUNCTION CF_TOTAL_TITLEFORMULA0005(EMPLOYMENT_CATEGORY IN VARCHAR2) RETURN CHAR IS
    L_TOTAL_TITLE VARCHAR2(200) := 'TOTAL OTHERS';
    L_EMP_CATEGORY VARCHAR2(1) := SUBSTR(EMPLOYMENT_CATEGORY
          ,4
          ,1);
  BEGIN
    IF L_EMP_CATEGORY = 'F' THEN
      L_TOTAL_TITLE := 'TOTAL FULL-TIME';
    ELSIF L_EMP_CATEGORY = 'O' THEN
      L_TOTAL_TITLE := 'TOTAL OTHER THAN F-T';
    ELSIF L_EMP_CATEGORY = 'N' THEN
      L_TOTAL_TITLE := 'TOTAL NEW HIRES';
    END IF;
    RETURN L_TOTAL_TITLE;
  END CF_TOTAL_TITLEFORMULA0005;

  FUNCTION CF_SET_FUNCTION_DESCFORMULA(JOB_FUNCTION_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR FUNC_DESC_CUR IS
      SELECT
        MEANING
      FROM
        HR_LOOKUPS
      WHERE LOOKUP_TYPE = 'US_EEO4_JOB_FUNCTIONS'
        AND LOOKUP_CODE = JOB_FUNCTION_CODE;
    L_FUNCTION_DESC VARCHAR2(240);
  BEGIN
    IF JOB_FUNCTION_CODE < 'XX' THEN
      OPEN FUNC_DESC_CUR;
      FETCH FUNC_DESC_CUR
       INTO
         L_FUNCTION_DESC;
      CLOSE FUNC_DESC_CUR;
      RETURN (JOB_FUNCTION_CODE || ' ' || L_FUNCTION_DESC);
    ELSE
      RETURN (FUNCTION_DESC);
    END IF;
  END CF_SET_FUNCTION_DESCFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_1;
  END CP_1_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_REPORT_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_TYPE;
  END C_REPORT_TYPE_P;

  FUNCTION C_ORGANIZATION_HIERARCHY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ORGANIZATION_HIERARCHY;
  END C_ORGANIZATION_HIERARCHY_P;

  FUNCTION C_EEO1_ORGANIZATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EEO1_ORGANIZATION;
  END C_EEO1_ORGANIZATION_P;

  FUNCTION C_END_OF_TIME_P RETURN DATE IS
  BEGIN
    RETURN C_END_OF_TIME;
  END C_END_OF_TIME_P;

END PQH_PQHEEO4_XMLP_PKG;

/
