--------------------------------------------------------
--  DDL for Package Body PSP_PSPENEXR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSPENEXR_XMLP_PKG" AS
/* $Header: PSPENEXRB.pls 120.6 2007/10/29 07:22:52 amakrish noship $ */
  --FUNCTION BEFOREREPORT(ORIENTATION IN VARCHAR2) RETURN BOOLEAN IS
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR GL_APPLICATION_ID_CUR IS
      SELECT
        APPLICATION_ID
      FROM
        FND_APPLICATION
      WHERE APPLICATION_SHORT_NAME = 'SQLGL';
    CURSOR GMS_APPLICATION_ID_CUR IS
      SELECT
        APPLICATION_ID
      FROM
        FND_APPLICATION
      WHERE APPLICATION_SHORT_NAME = 'GMS';
  BEGIN
    --HR_STANDARD.EVENT('BEFORE REPORT');
    IF P_SORT_BY IS NULL THEN
      P_SORT_BY := 'O';
    END IF;
    P_ACTUAL_SELECT := 'UNION ALL
                       SELECT	pesl.person_id,
                       	pesl.assignment_id,
                       	pelh.enc_element_type_id,';
    IF P_SORT_BY = 'O' THEN
      P_ACTUAL_SELECT := P_ACTUAL_SELECT || ' paf.organization_id, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), NULL,';
      P_ACTUAL_SELECT := P_ACTUAL_SELECT || ' TO_NUMBER(NULL), pesl.gl_code_combination_id, pesl.project_id, pesl.task_id, pesl.award_id, pesl.expenditure_organization_id, pesl.expenditure_type, paf.organization_id,';
    ELSE
      P_ACTUAL_SELECT := P_ACTUAL_SELECT || ' TO_NUMBER(NULL), pesl.gl_code_combination_id, pesl.project_id, pesl.task_id, pesl.award_id, pesl.expenditure_organization_id, pesl.expenditure_type,';
      P_ACTUAL_SELECT := P_ACTUAL_SELECT || ' paf.organization_id, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), NULL, -999,';
    END IF;
    P_ACTUAL_SELECT := P_ACTUAL_SELECT || '	interface_status,
                       	MIN(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ''DD/MM/RRRR''), pesl.EFFECTIVE_DATE)) min_start_date,
                       	MAX(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ''DD/MM/RRRR''), pesl.EFFECTIVE_DATE)) max_end_date,
                       	1 row_num,
                               pesl.payroll_id,';
        IF P_SORT_BY = 'O' THEN
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'PSP_PSPENEXR_XMLP_PKG.CF_SORT_DESCRIPTION1FORMULA(paf.organization_id, TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), NULL) CF_sort_description1,';
        ELSE
                P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'PSP_PSPENEXR_XMLP_PKG.CF_SORT_DESCRIPTION1FORMULA(TO_NUMBER(NULL), pesl.gl_code_combination_id, pesl.project_id, pesl.task_id, pesl.award_id, pesl.expenditure_organization_id, ';
                P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'pesl.expenditure_type) CF_sort_description1,';
        END IF;
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'PSP_PSPENEXR_XMLP_PKG.CF_PERSON_NAMEFORMULA(pesl.person_id,MAX(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ''DD/MM/RRRR''), ';
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'pesl.EFFECTIVE_DATE)),MIN(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ''DD/MM/RRRR''), pesl.EFFECTIVE_DATE))) CF_person_name,';
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'PSP_PSPENEXR_XMLP_PKG.CF_ASSIGNMENT_NUMBERFORMULA(pesl.assignment_id,MAX(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ''DD/MM/RRRR''), ';
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'pesl.EFFECTIVE_DATE)),MIN(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE,pesl.gl_posting_override_date),''DD/MM/RRRR''),pesl.EFFECTIVE_DATE))) CF_assignment_number,';
        IF P_SORT_BY = 'O' THEN
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'PSP_PSPENEXR_XMLP_PKG.CF_ELEMENT_NAMEFORMULA(pelh.enc_element_type_id,MAX(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ''DD/MM/RRRR''), ';
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'pesl.EFFECTIVE_DATE)),MIN(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ''DD/MM/RRRR''), pesl.EFFECTIVE_DATE)),';
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'pesl.gl_code_combination_id, pesl.project_id, pesl.task_id, pesl.award_id, pesl.expenditure_organization_id,pesl.expenditure_type,TO_NUMBER(NULL)) CF_element_name,';
        ELSE
                P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'PSP_PSPENEXR_XMLP_PKG.CF_ELEMENT_NAMEFORMULA(pelh.enc_element_type_id,MAX(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ';
                P_ACTUAL_SELECT := P_ACTUAL_SELECT || '''DD/MM/RRRR''), pesl.EFFECTIVE_DATE)),MIN(NVL(TO_DATE(DECODE(pesl.gl_project_flag, ''P'', pesl.GMS_POSTING_OVERRIDE_DATE, pesl.gl_posting_override_date), ''DD/MM/RRRR''), ';
                P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'pesl.EFFECTIVE_DATE)),TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL), TO_NUMBER(NULL),NULL,paf.organization_id) CF_element_name,';
        END IF;
        P_ACTUAL_SELECT := P_ACTUAL_SELECT || 'PSP_PSPENEXR_XMLP_PKG.CF_PAYROLL_NAMEFORMULA(pesl.payroll_id) CF_payroll_name,';
        P_ACTUAL_SELECT := P_ACTUAL_SELECT ||'

                       PSP_PSPENEXR_XMLP_PKG.CP_SORT_DESCRIPTION2_P CP_sort_description2
                       FROM	psp_enc_summary_lines pesl,
                       	psp_enc_lines_history pelh,
                       	per_assignments_f paf
                       WHERE	pesl.payroll_action_id = ' || P_PAYROLL_ACTION_ID || '
                       AND	paf.assignment_id = pesl.assignment_id
                       AND	pelh.enc_summary_line_id = pesl.superceded_line_id
                       AND     pesl.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
                       --AND	pesl.status_code = ''R''
                       AND     interface_status IS NOT NULL
                       AND     superceded_line_id IS NOT NULL
                       AND     EXISTS	(SELECT	1
                       		FROM	psp_enc_summary_lines pesl2
                       		WHERE	pesl2.enc_summary_line_id = pesl.superceded_line_id
                       		AND	pesl2.status_code = ''A'')
                       GROUP BY	paf.organization_id,
                       	pesl.person_id,
                       	pesl.assignment_id,
                       	pelh.enc_element_type_id,
                       	pesl.gl_code_combination_id,
                       	pesl.project_id,
                       	pesl.task_id,
                       	pesl.award_id,
                       	pesl.expenditure_type,
                       	pesl.expenditure_organization_id,
                       	pesl.interface_status,
                               pesl.payroll_id';
    --ORIENTATION := 'LANDSCAPE';
    OPEN GL_APPLICATION_ID_CUR;
    FETCH GL_APPLICATION_ID_CUR
     INTO P_GL_APPLICATION_ID;
    CLOSE GL_APPLICATION_ID_CUR;
    OPEN GMS_APPLICATION_ID_CUR;
    FETCH GMS_APPLICATION_ID_CUR
     INTO P_GMS_APPLICATION_ID;
    CLOSE GMS_APPLICATION_ID_CUR;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_ELEMENT_NAMEFORMULA(ELEMENT_TYPE_ID IN NUMBER
                                 ,MAX_END_DATE IN DATE
                                 ,MIN_START_DATE IN DATE
                                 ,SORT_OPTION22 IN NUMBER
                                 ,SORT_OPTION23 IN NUMBER
                                 ,SORT_OPTION24 IN NUMBER
                                 ,SORT_OPTION25 IN NUMBER
                                 ,SORT_OPTION26 IN NUMBER
                                 ,SORT_OPTION27 IN VARCHAR2
                                 ,SORT_OPTION21 IN NUMBER) RETURN CHAR IS
    V_RETCODE NUMBER;
    L_CHART_OF_ACCTS VARCHAR2(20);
    CURSOR ELEMENT_NAME_CUR IS
      SELECT
        ELEMENT_NAME,
        1 ORDER_BY
      FROM
        PAY_ELEMENT_TYPES_F PETF
      WHERE PETF.ELEMENT_TYPE_ID = CF_ELEMENT_NAMEFORMULA.ELEMENT_TYPE_ID
        AND PETF.EFFECTIVE_START_DATE <= MAX_END_DATE
        AND PETF.EFFECTIVE_END_DATE >= MIN_START_DATE
        AND ROWNUM = 1
      UNION ALL
      SELECT
        ELEMENT_NAME,
        2 ORDER_BY
      FROM
        PAY_ELEMENT_TYPES_F PETF
      WHERE PETF.ELEMENT_TYPE_ID = CF_ELEMENT_NAMEFORMULA.ELEMENT_TYPE_ID
        AND PETF.EFFECTIVE_START_DATE = (
        SELECT
          MAX(PETF2.EFFECTIVE_START_DATE)
        FROM
          PAY_ELEMENT_TYPES_F PETF2
        WHERE PETF2.ELEMENT_TYPE_ID = CF_ELEMENT_NAMEFORMULA.ELEMENT_TYPE_ID )
      ORDER BY
        2;
    L_DUMMY NUMBER;
    L_ELEMENT_NAME PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
  BEGIN
    OPEN ELEMENT_NAME_CUR;
    FETCH ELEMENT_NAME_CUR
     INTO L_ELEMENT_NAME,L_DUMMY;
    CLOSE ELEMENT_NAME_CUR;
    IF (P_SORT_BY = 'O') THEN
      IF (SORT_OPTION22 IS NOT NULL) THEN
        V_RETCODE := PSP_GENERAL.FIND_CHART_OF_ACCTS(P_SET_OF_BOOKS_ID
                                                    ,L_CHART_OF_ACCTS);
        CP_SORT_DESCRIPTION2 := FND_FLEX_EXT.GET_SEGS(APPLICATION_SHORT_NAME => 'SQLGL'
                                                     ,KEY_FLEX_CODE => 'GL#'
                                                     ,STRUCTURE_NUMBER => TO_NUMBER(L_CHART_OF_ACCTS)
                                                     ,COMBINATION_ID => SORT_OPTION22);
      ELSE
        CP_SORT_DESCRIPTION2 := PSP_GENERAL.GET_PROJECT_NUMBER(SORT_OPTION23) || ' ' || PSP_GENERAL.GET_TASK_NUMBER(SORT_OPTION24) || ' ' || PSP_GENERAL.GET_AWARD_NUMBER(SORT_OPTION25)
                                || ' ' || PSP_GENERAL.GET_ORG_NAME(SORT_OPTION26) || ' ' || SORT_OPTION27;
      END IF;
    ELSE
      CP_SORT_DESCRIPTION2 := PSP_GENERAL.GET_ORG_NAME(SORT_OPTION21);
    END IF;
    RETURN L_ELEMENT_NAME;
  END CF_ELEMENT_NAMEFORMULA;

  FUNCTION CF_SORT_DESCRIPTION1FORMULA(SORT_OPTION11 IN NUMBER
                                      ,SORT_OPTION12 IN NUMBER
                                      ,SORT_OPTION13 IN NUMBER
                                      ,SORT_OPTION14 IN NUMBER
                                      ,SORT_OPTION15 IN NUMBER
                                      ,SORT_OPTION16 IN NUMBER
                                      ,SORT_OPTION17 IN VARCHAR2) RETURN CHAR IS
    V_RETCODE NUMBER;
    L_CHART_OF_ACCTS VARCHAR2(20);
  BEGIN
    IF (P_SORT_BY = 'O') THEN
      RETURN PSP_GENERAL.GET_ORG_NAME(SORT_OPTION11);
    ELSE
      IF (SORT_OPTION12 IS NOT NULL) THEN
        V_RETCODE := PSP_GENERAL.FIND_CHART_OF_ACCTS(P_SET_OF_BOOKS_ID
                                                    ,L_CHART_OF_ACCTS);
        RETURN FND_FLEX_EXT.GET_SEGS(APPLICATION_SHORT_NAME => 'SQLGL'
                                    ,KEY_FLEX_CODE => 'GL#'
                                    ,STRUCTURE_NUMBER => TO_NUMBER(L_CHART_OF_ACCTS)
                                    ,COMBINATION_ID => SORT_OPTION12);
      ELSE
        RETURN PSP_GENERAL.GET_PROJECT_NUMBER(SORT_OPTION13) || ' ' || PSP_GENERAL.GET_TASK_NUMBER(SORT_OPTION14) || ' ' || PSP_GENERAL.GET_AWARD_NUMBER(SORT_OPTION15) || ' ' || PSP_GENERAL.GET_ORG_NAME(SORT_OPTION16) || ' ' || SORT_OPTION17;
      END IF;
    END IF;
  END CF_SORT_DESCRIPTION1FORMULA;

  FUNCTION CF_SORT_BY_HEADERFORMULA RETURN CHAR IS
    CURSOR SORT_BY_HEADER_CUR IS
      SELECT
        MEANING || ':'
      FROM
        PSP_LOOKUPS PL
      WHERE PL.LOOKUP_TYPE = 'PSP_ENC_EXC_REP_SORT_OPTIONS'
        AND PL.LOOKUP_CODE = P_SORT_BY;
    CURSOR SORT_BY_DETAIL_CUR IS
      SELECT
        MEANING
      FROM
        PSP_LOOKUPS PL
      WHERE PL.LOOKUP_TYPE = 'PSP_ENC_EXC_REP_SORT_OPTIONS'
        AND PL.LOOKUP_CODE <> P_SORT_BY;
    L_SORT_BY_HEADER PSP_LOOKUPS.MEANING%TYPE;
  BEGIN
    OPEN SORT_BY_DETAIL_CUR;
    FETCH SORT_BY_DETAIL_CUR
     INTO CP_SORT_BY_DETAIL;
    CLOSE SORT_BY_DETAIL_CUR;
    OPEN SORT_BY_HEADER_CUR;
    FETCH SORT_BY_HEADER_CUR
     INTO L_SORT_BY_HEADER;
    CLOSE SORT_BY_HEADER_CUR;
    RETURN L_SORT_BY_HEADER;
  END CF_SORT_BY_HEADERFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_PAYROLL_NAMEFORMULA(PAYROLL_ID IN NUMBER) RETURN CHAR IS
    V_PAYROLL_NAME VARCHAR2(40);
  BEGIN
    SELECT
      PAYROLL_NAME
    INTO V_PAYROLL_NAME
    FROM
      PAY_PAYROLLS_F
    WHERE PAYROLL_ID = CF_PAYROLL_NAMEFORMULA.PAYROLL_ID
      AND ROWNUM = 1;
    RETURN (V_PAYROLL_NAME);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no_data_found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
    WHEN OTHERS THEN
      RETURN ('error');
  END CF_PAYROLL_NAMEFORMULA;

  FUNCTION CF_PERSON_NAMEFORMULA(PERSON_ID IN NUMBER
                                ,MAX_END_DATE IN DATE
                                ,MIN_START_DATE IN DATE) RETURN CHAR IS
    L_DUMMY NUMBER;
    L_PERSON_NAME PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
    L_EMPLOYEE_NUMBER PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE;
    CURSOR EMPLOYEE_CUR IS
      SELECT
        FULL_NAME,
        EMPLOYEE_NUMBER,
        1 ORDER_BY
      FROM
        PER_ALL_PEOPLE_F PAPF
      WHERE PAPF.PERSON_ID = CF_PERSON_NAMEFORMULA.PERSON_ID
        AND PAPF.EFFECTIVE_START_DATE <= MAX_END_DATE
        AND PAPF.EFFECTIVE_END_DATE >= MIN_START_DATE
        AND ROWNUM = 1
      UNION ALL
      SELECT
        FULL_NAME,
        EMPLOYEE_NUMBER,
        2 ORDER_BY
      FROM
        PER_ALL_PEOPLE_F PAPF
      WHERE PAPF.PERSON_ID = CF_PERSON_NAMEFORMULA.PERSON_ID
        AND PAPF.EFFECTIVE_START_DATE = (
        SELECT
          MAX(PAPF2.EFFECTIVE_START_DATE)
        FROM
          PER_ALL_PEOPLE_F PAPF2
        WHERE PAPF2.PERSON_ID = CF_PERSON_NAMEFORMULA.PERSON_ID )
      ORDER BY
        3;
  BEGIN
    OPEN EMPLOYEE_CUR;
    FETCH EMPLOYEE_CUR
     INTO L_PERSON_NAME,L_EMPLOYEE_NUMBER,L_DUMMY;
    CLOSE EMPLOYEE_CUR;
    RETURN L_PERSON_NAME;
  END CF_PERSON_NAMEFORMULA;

  FUNCTION CF_ASSIGNMENT_NUMBERFORMULA(ASSIGNMENT_ID IN NUMBER
                                      ,MAX_END_DATE IN DATE
                                      ,MIN_START_DATE IN DATE) RETURN CHAR IS
    CURSOR ASSIGNMENT_CUR IS
      SELECT
        ASSIGNMENT_NUMBER,
        1 ORDER_BY
      FROM
        PER_ALL_ASSIGNMENTS_F PAAF
      WHERE PAAF.ASSIGNMENT_ID = CF_ASSIGNMENT_NUMBERFORMULA.ASSIGNMENT_ID
        AND PAAF.EFFECTIVE_START_DATE <= MAX_END_DATE
        AND PAAF.EFFECTIVE_END_DATE >= MIN_START_DATE
        AND ROWNUM = 1
      UNION ALL
      SELECT
        ASSIGNMENT_NUMBER,
        2 ORDER_BY
      FROM
        PER_ALL_ASSIGNMENTS_F PAAF
      WHERE PAAF.ASSIGNMENT_ID = CF_ASSIGNMENT_NUMBERFORMULA.ASSIGNMENT_ID
        AND PAAF.EFFECTIVE_START_DATE = (
        SELECT
          MAX(PAAF2.EFFECTIVE_START_DATE)
        FROM
          PER_ALL_ASSIGNMENTS_F PAAF2
        WHERE PAAF2.ASSIGNMENT_ID = CF_ASSIGNMENT_NUMBERFORMULA.ASSIGNMENT_ID )
      ORDER BY
        2;
    L_ASSIGNMENT_NUMBER PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_NUMBER%TYPE;
    L_DUMMY NUMBER;
  BEGIN
    OPEN ASSIGNMENT_CUR;
    FETCH ASSIGNMENT_CUR
     INTO L_ASSIGNMENT_NUMBER,L_DUMMY;
    CLOSE ASSIGNMENT_CUR;
    RETURN L_ASSIGNMENT_NUMBER;
  END CF_ASSIGNMENT_NUMBERFORMULA;

  FUNCTION CP_SORT_DESCRIPTION2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SORT_DESCRIPTION2;
  END CP_SORT_DESCRIPTION2_P;

  FUNCTION CP_SORT_BY_DETAIL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SORT_BY_DETAIL;
  END CP_SORT_BY_DETAIL_P;

END PSP_PSPENEXR_XMLP_PKG;

/
