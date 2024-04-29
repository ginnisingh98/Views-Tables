--------------------------------------------------------
--  DDL for Package Body JA_JAINJVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINJVR_XMLP_PKG" AS
/* $Header: JAINJVRB.pls 120.1 2007/12/25 16:22:07 dwkrishn noship $ */
  FUNCTION CF_ACCOUNTFORMULA(CODE_COMBINATION_ID IN NUMBER) RETURN VARCHAR2 IS
    V_ACCOUNT VARCHAR(1000);
  BEGIN
    JAI_CMN_GL_PKG.GET_ACCOUNT_NUMBER(P_CHART_OF_ACCTS_ID
                                     ,CODE_COMBINATION_ID
                                     ,V_ACCOUNT);
    RETURN (V_ACCOUNT);
  END CF_ACCOUNTFORMULA;

  FUNCTION CF_SOB_NAMEFORMULA RETURN VARCHAR2 IS
    CURSOR FOR_SOB_NAME(SOB_ID IN NUMBER) IS
      SELECT
        NAME
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = SOB_ID;
    V_NAME VARCHAR2(100);
  BEGIN
    OPEN FOR_SOB_NAME(P_SOB_ID);
    FETCH FOR_SOB_NAME
     INTO V_NAME;
    CLOSE FOR_SOB_NAME;
    RETURN (V_NAME);
  END CF_SOB_NAMEFORMULA;

  FUNCTION CF_ACCTS_DESCFORMULA (CODE_COMBINATION_ID IN NUMBER) RETURN VARCHAR2 IS
    CURSOR GET_APP_COLUMN_NAME IS
      SELECT
        DISTINCT
        APPLICATION_COLUMN_NAME
      FROM
        FND_SEGMENT_ATTRIBUTE_VALUES
      WHERE APPLICATION_ID = 101
        AND ID_FLEX_CODE = 'GL#'
        AND ID_FLEX_NUM = P_CHART_OF_ACCTS_ID
        AND SEGMENT_ATTRIBUTE_TYPE = 'GL_ACCOUNT'
        AND ATTRIBUTE_VALUE = 'Y';
    CURSOR FLEX_VAL_SET_ID(V_COLUMN_NAME IN VARCHAR2) IS
      SELECT
        A.FLEX_VALUE_SET_ID
      FROM
        FND_ID_FLEX_SEGMENTS A
      WHERE A.APPLICATION_COLUMN_NAME = V_COLUMN_NAME
        AND A.APPLICATION_ID = 101
        AND A.ID_FLEX_CODE = 'GL#'
        AND A.ID_FLEX_NUM = P_CHART_OF_ACCTS_ID;
    V_COLUMN_NAME VARCHAR2(30);
    V_COLUMN_VALUE VARCHAR2(30);
    V_FLEX_ID NUMBER;
    V_DESCRIPTION VARCHAR2(100);
    CURSOR GET_DESCRIPTION IS
      SELECT
        SUBSTR(DESCRIPTION
              ,1
              ,50)
      FROM
        FND_FLEX_VALUES_VL
      WHERE FLEX_VALUE_SET_ID = V_FLEX_ID
        AND FLEX_VALUE = V_COLUMN_VALUE;
  BEGIN
    OPEN GET_APP_COLUMN_NAME;
    FETCH GET_APP_COLUMN_NAME
     INTO V_COLUMN_NAME;
    CLOSE GET_APP_COLUMN_NAME;
    IF V_COLUMN_NAME IS NULL THEN
      V_COLUMN_NAME := 'SEGMENT3';
    END IF;
    OPEN FLEX_VAL_SET_ID(V_COLUMN_NAME);
    FETCH FLEX_VAL_SET_ID
     INTO V_FLEX_ID;
    CLOSE FLEX_VAL_SET_ID;
    EXECUTE IMMEDIATE
      'select ' || V_COLUMN_NAME || ' from gl_code_combinations
      		where chart_of_accounts_id = :P_CHART_OF_ACCTS_ID AND code_combination_id = :code_combination_id'
	        INTO p_column_value
		USING P_CHART_OF_ACCTS_ID,CODE_COMBINATION_ID  ;
    V_COLUMN_VALUE := P_COLUMN_VALUE;
    OPEN GET_DESCRIPTION;
    FETCH GET_DESCRIPTION
     INTO V_DESCRIPTION;
    CLOSE GET_DESCRIPTION;
    RETURN (V_DESCRIPTION);
  END CF_ACCTS_DESCFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_PROGRAM_ID(P_REQUEST_ID IN NUMBER) IS
      SELECT
        CONCURRENT_PROGRAM_ID,
        NVL(ENABLE_TRACE
           ,'N')
      FROM
        FND_CONCURRENT_REQUESTS
      WHERE REQUEST_ID = P_REQUEST_ID;
    V_ENABLE_TRACE FND_CONCURRENT_PROGRAMS.ENABLE_TRACE%TYPE;
    V_PROGRAM_ID FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID%TYPE;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.MESSAGE(1275
               ,'Report Version is 120.3 Last modified date is 30/07/2005')*/NULL;
    BEGIN
      OPEN C_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH C_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE C_PROGRAM_ID;
      /*SRW.MESSAGE(1275
                 ,'v_program_id -> ' || V_PROGRAM_ID || ', v_enable_trace -> ' || V_ENABLE_TRACE || ', request_id -> ' || P_CONC_REQUEST_ID)*/NULL;
      IF V_ENABLE_TRACE = 'Y' THEN
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
      LP_COLUMN_VALUE:=P_COLUMN_VALUE;
      LP_FROM_DATE:=to_char(P_FROM_DATE,'DD-MON-YYYY');
      LP_TO_DATE:=to_char(P_TO_DATE,'DD-MON-YYYY');
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1275
                   ,'Error during enabling the trace. ErrCode -> ' || SQLCODE || ', ErrMesg -> ' || SQLERRM)*/NULL;
    END;
  END BEFOREREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    NL CONSTANT VARCHAR2(1) DEFAULT ' ';
  BEGIN
    IF P_JV_NO IS NOT NULL THEN
      P_SELECTED_JV_NO := 'AND  gjh.doc_sequence_value = :p_jv_no ' || ' ' || NL;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION M_2_GRPFRFORMATTRIGGER RETURN Number IS
	v_count NUMBER;
	begin
	/*
	|| code modified by aiyer for the bug 4523064
	|| Column set_of_books_id does not exist in table gl_je_headers leading to compilation error.
	|| This has been changed to ledger_id
	*/
	  SELECT count(*) INTO v_count
	FROM        gl_je_headers gjh,
		    gl_je_lines   gjl,
		    gl_code_combinations gcc,
		    gl_sets_of_books gsob
	WHERE gjh.je_header_id = gjl.je_header_id
	AND      gcc.code_combination_id = gjl.code_combination_id
	AND      gsob.set_of_books_id = gjh.ledger_id
	AND     gjh.je_source = NVL(p_source, gjh.je_source)
	AND     (gjh.doc_sequence_value = NVL(p_jv_no, gjh.doc_sequence_value) OR
	gjh.doc_sequence_value IS NULL)
	AND     gjh.ledger_id = p_sob_id
	AND     TRUNC(gjh.default_effective_date) BETWEEN
		  NVL(TRUNC(p_from_date),TRUNC(gjh.default_effective_date))
	      AND NVL(TRUNC(p_to_date),TRUNC(gjh.default_effective_date));
	return (v_count);

 END;
END JA_JAINJVR_XMLP_PKG;




/
