--------------------------------------------------------
--  DDL for Package Body PA_PAXCCGLA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXCCGLA_XMLP_PKG" AS
/* $Header: PAXCCGLAB.pls 120.0 2008/01/02 11:23:22 krreddy noship $ */
  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COVER_PAGE_VALUES;

	function BeforeReport return boolean is
	begin

	Declare
	 init_failure exception;
	 ndf VARCHAR2(80);
	 tmp_usr_je_sname VARCHAR2(25);
	 tmp_gl_start  DATE;
	 tmp_gl_end    DATE;
	 tmp_period_set   VARCHAR2(15);
	BEGIN
	/*srw.user_exit('FND SRWINIT');*/null;

	  P_FROM_INTERFACE_DATE1 := TO_CHAR(P_FROM_INTERFACE_DATE,'DD-MON-YY');
	  P_TO_INTERFACE_DATE1 := TO_CHAR(P_TO_INTERFACE_DATE,'DD-MON-YY');
	  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
	  END IF;

	   select meaning into ndf from pa_lookups where
	    lookup_code = 'NO_DATA_FOUND' and
	    lookup_type = 'MESSAGE';
	  c_no_data_found := ndf;

	  SELECT user_je_source_name INTO tmp_usr_je_sname
	  FROM gl_je_sources WHERE
	  je_source_name = 'Project Accounting' ;
	  cp_usr_je_sname := tmp_usr_je_sname ;

	SELECT period_set_name INTO tmp_period_set
	FROM   gl_sets_of_books

	WHERE  set_of_books_id = p_ca_set_of_books_id ;

	IF p_from_periods IS NOT NULL THEN
	 	SELECT start_date INTO tmp_gl_start
		FROM   gl_periods
		WHERE  period_set_name = tmp_period_set
		AND    period_name = p_from_periods ;
	END IF;

	cp_gl_start := tmp_gl_start ;

	IF p_to_period IS NOT NULL THEN
	 	SELECT end_date INTO tmp_gl_end
		FROM   gl_periods
		WHERE  period_set_name = tmp_period_set
		AND    period_name = p_to_period ;
	END IF;
	cp_gl_start := tmp_gl_start ;
	cp_gl_end := tmp_gl_end ;

	IF (cp_gl_start is not null AND cp_gl_end is not null) THEN
	   l_where_clause := 'gl_date BETWEEN ''' || to_char( cp_gl_start,'DD-MON-YYYY') || '''  AND ''' || to_char( cp_gl_end , 'DD-MON-YYYY') || '''';
	ELSIF (cp_gl_start is null AND cp_gl_end is null) THEN
	   l_where_clause := '1=1';
	ELSIF (cp_gl_start is null AND cp_gl_end is not null) THEN
	   l_where_clause := 'gl_date <= '''||to_char(cp_gl_end,'DD-MON-YYYY')||'''';
	ELSE
	   l_where_clause := 'gl_date >= '''||to_char(cp_gl_start,'DD_MON-YYYY')||'''';
	END IF;

	 null;
	EXCEPTION
	  WHEN  NO_DATA_FOUND THEN
	   select meaning into ndf from pa_lookups where
	    lookup_code = 'NO_DATA_FOUND' and
	    lookup_type = 'MESSAGE';
	  c_no_data_found := ndf;
	   c_dummy_data := 1;
	  WHEN   OTHERS  THEN
	    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

	END;  return (TRUE);
	end;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
  BEGIN
    SELECT
      GL.NAME
    INTO
      L_NAME
    FROM
      GL_SETS_OF_BOOKS GL
    WHERE GL.SET_OF_BOOKS_ID = P_CA_SET_OF_BOOKS_ID;
    C_COMPANY_NAME_HEADER := L_NAME;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;

  FUNCTION CF_ACCT_CURRENCY_CODEFORMULA RETURN VARCHAR2 IS
    L_CURR_CODE VARCHAR2(30);
  BEGIN
    SELECT
      CURRENCY_CODE
    INTO
      L_CURR_CODE
    FROM
      GL_SETS_OF_BOOKS
    WHERE SET_OF_BOOKS_ID = P_CA_SET_OF_BOOKS_ID;
    RETURN (L_CURR_CODE);
  END CF_ACCT_CURRENCY_CODEFORMULA;

  FUNCTION CF_FROM_DATEFORMULA RETURN DATE IS
  BEGIN
    RETURN P_FROM_INTERFACE_DATE1;
  END CF_FROM_DATEFORMULA;

  FUNCTION CF_TO_DATEFORMULA RETURN DATE IS
  BEGIN
    RETURN P_TO_INTERFACE_DATE1;
  END CF_TO_DATEFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION ACCOUNT_IDFORMULA(CODE_COMBINATION_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN FND_FLEX_EXT.GET_SEGS('SQLGL'
                                ,'GL#'
                                ,P_COA_ID
                                ,CODE_COMBINATION_ID);
  END ACCOUNT_IDFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NO_DATA_FOUND;
  END C_NO_DATA_FOUND_P;

  FUNCTION C_DUMMY_DATA_P RETURN NUMBER IS
  BEGIN
    RETURN C_DUMMY_DATA;
  END C_DUMMY_DATA_P;

  FUNCTION CP_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_WHERE;
  END CP_WHERE_P;

  FUNCTION CP_GL_START_P RETURN DATE IS
  BEGIN
    RETURN CP_GL_START;
  END CP_GL_START_P;

  FUNCTION CP_GL_END_P RETURN DATE IS
  BEGIN
    RETURN CP_GL_END;
  END CP_GL_END_P;

  FUNCTION CP_USR_JE_SNAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_USR_JE_SNAME;
  END CP_USR_JE_SNAME_P;

END PA_PAXCCGLA_XMLP_PKG;


/
