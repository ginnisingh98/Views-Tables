--------------------------------------------------------
--  DDL for Package Body JL_JLCOGLAN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLCOGLAN_XMLP_PKG" AS
/* $Header: JLCOGLANB.pls 120.1 2007/12/25 16:48:11 dwkrishn noship $ */
  FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CUSTOM_INIT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_BALFORMULA(CS_DEBITS IN NUMBER
                        ,CS_CREDITS IN NUMBER
                        ,C_BAL_SUM IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      BAL NUMBER;
    BEGIN
      BAL := CS_DEBITS - CS_CREDITS + C_BAL_SUM;
      RETURN (BAL);
    END;
    RETURN NULL;
  END CF_BALFORMULA;

  FUNCTION CF_OBALFORMULA(CS_ODEBITS IN NUMBER
                         ,CS_OCREDITS IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      OBAL NUMBER;
    BEGIN
      OBAL := CS_ODEBITS - CS_OCREDITS;
      RETURN (OBAL);
    END;
    RETURN NULL;
  END CF_OBALFORMULA;

  FUNCTION C_CCIDFORMULA(NIT IN NUMBER
                        ,ACCOUNT IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      PN JL_CO_GL_BALANCES.PERIOD_NAME%TYPE;
      ACODE JL_CO_GL_BALANCES.ACCOUNT_CODE%TYPE;
      BBDR NUMBER;
      BBCR NUMBER;
      PNDR NUMBER;
      PNCR NUMBER;
      BEBAL NUMBER;
    BEGIN
      SELECT
        BAL.PERIOD_NAME,
        SUM(BAL.BEGIN_BALANCE_DR),
        SUM(BAL.BEGIN_BALANCE_CR),
        SUM(BAL.PERIOD_NET_DR),
        SUM(BAL.PERIOD_NET_CR),
        BAL.ACCOUNT_CODE
      INTO PN,BBDR,BBCR,PNDR,PNCR,ACODE
      FROM
        JL_CO_GL_BALANCES BAL
      WHERE BAL.NIT_ID = NIT
        AND BAL.ACCOUNT_CODE = ACCOUNT
        AND BAL.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
        AND ( BAL.PERIOD_YEAR * 100 + BAL.PERIOD_NUM ) = (
        SELECT
          MAX(B1.PERIOD_YEAR * 100 + B1.PERIOD_NUM)
        FROM
          JL_CO_GL_BALANCES B1,
          GL_CODE_COMBINATIONS GLCC
        WHERE BAL.SET_OF_BOOKS_ID = B1.SET_OF_BOOKS_ID
          AND BAL.ACCOUNT_CODE = B1.ACCOUNT_CODE
          AND B1.CODE_COMBINATION_ID = GLCC.CODE_COMBINATION_ID
          AND BAL.NIT_ID = B1.NIT_ID
          AND ( B1.PERIOD_YEAR * 100 + B1.PERIOD_NUM ) < ( NVL(C_PYEAR
           ,0) * 100 + NVL(C_PNUM
           ,0) )
          AND B1.PERIOD_YEAR BETWEEN DECODE(GLCC.ACCOUNT_TYPE
              ,'R'
              ,C_PYEAR
              ,'E'
              ,C_PYEAR
              ,C_PYEAR - 200)
          AND C_PYEAR )
      GROUP BY
        BAL.PERIOD_NAME,
        BAL.ACCOUNT_CODE;
      IF PN <> P_START_PERIOD THEN
        BEBAL := BBDR - BBCR + PNDR - PNCR;
        RETURN (BEBAL);
      ELSE
        BEBAL := BBDR - BBCR;
        RETURN (BEBAL);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEBAL := 0;
        RETURN (BEBAL);
    END;
    RETURN NULL;
  END C_CCIDFORMULA;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN IS
    NLS_NO_DATA_FOUND VARCHAR2(45);
    NLS_END_OF_REPORT VARCHAR2(45);
  BEGIN
    FND_MESSAGE.SET_NAME('JL'
                        ,'JL_ZZ_NO_DATA_FOUND');
    NLS_NO_DATA_FOUND := SUBSTR(FND_MESSAGE.GET
                               ,1
                               ,35);
    FND_MESSAGE.SET_NAME('JL'
                        ,'JL_ZZ_END_OF_REPORT');
    NLS_END_OF_REPORT := SUBSTR(FND_MESSAGE.GET
                               ,1
                               ,35);
    P_NO_DATA_FOUND := NLS_NO_DATA_FOUND;
    P_END_OF_REPORT := NLS_END_OF_REPORT;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_NLS_STRINGS;

  FUNCTION STRUCT_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN STRUCT_NUM;
  END STRUCT_NUM_P;

  FUNCTION SET_OF_BOOKS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SET_OF_BOOKS_NAME;
  END SET_OF_BOOKS_NAME_P;

  FUNCTION WHERE_FLEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_FLEX;
  END WHERE_FLEX_P;

  FUNCTION C_PNUM_P RETURN NUMBER IS
  BEGIN
    RETURN C_PNUM;
  END C_PNUM_P;

  FUNCTION C_PYEAR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PYEAR;
  END C_PYEAR_P;

  FUNCTION DISPLAY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DISPLAY;
  END DISPLAY_P;

  FUNCTION C_PNUM1_P RETURN NUMBER IS
  BEGIN
    RETURN C_PNUM1;
  END C_PNUM1_P;

  FUNCTION C_PYEAR1_P RETURN NUMBER IS
  BEGIN
    RETURN C_PYEAR1;
  END C_PYEAR1_P;

  FUNCTION C_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME;
  END C_COMPANY_NAME_P;

  FUNCTION C_NIT_ID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NIT_ID;
  END C_NIT_ID_P;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
	  declare
	  t_set_of_books_id      NUMBER;
	  t_chart_of_accounts_id NUMBER;
	  t_set_of_books_name    VARCHAR2(30);
	  t_func_curr            VARCHAR2(15);
	  t_period_name          VARCHAR2(15);
	  t_errorbuffer          VARCHAR2(132);
	  t_legal_entity_id      NUMBER;


  BEGIN

	  /*SRW.USER_EXIT('FND SRWINIT');*/
	  --
	  -- Here we fetch the chart_of_accounts_id for the
	  -- given set_of_books_id
	  --
	  t_set_of_books_id   := P_set_of_books_id;
	  gl_info.gl_get_ledger_info (t_set_of_books_id,
				    t_chart_of_accounts_id,
				    t_set_of_books_name,
				    t_func_curr,
				    t_errorbuffer);


	  if (t_errorbuffer is not NULL) then
	     /*SRW.MESSAGE(0,t_errorbuffer);
	     raise SRW.PROGRAM_ABORT;*/null;
	  else
	     STRUCT_NUM := to_char(t_chart_of_accounts_id);
	     SET_OF_BOOKS_NAME := t_set_of_books_name;
	     P_CURRENCY := t_func_curr;

	  end if;
	/* Get NLS strings  */
	  IF (get_nls_strings <> TRUE) THEN      -- Call report level PL/SQL function
	    NULL;
	  END IF;

	  /* Retrieving LOCATION_ID */
	  BEGIN
	    t_legal_entity_id := P_LEGAL_ENTITY_ID;
	   -- :C_LOCATION_ID := jg_zz_company_info.get_location_id;
	  EXCEPTION
	    when others then
	/*srw.message(02, 'Error while retreiving legal entity information');*/null;
	raise;
	--     app_exception.raise_exception(null,null,null);
	  END;


	  /* Retrieving Company Information Attributes */
	  begin
	    select name,
		   registration_number
	    into   C_COMPANY_NAME,
		   C_NIT_ID
	    from xle_firstparty_information_v
	    where legal_entity_id = t_legal_entity_id;
	  exception
	    when others then
	      /*srw.message(03, 'Failed to retrieve Company Information Attributes.');*/null;
	      raise;
	  end;

	-- Here we format all the necessary
	-- flexfield parts
	--
	/*SRW.USER_EXIT('FND FLEXSQL CODE="GL#"
		       OUTPUT=":WHERE_FLEX"
		       APPL_SHORT_NAME="SQLGL"
		       MODE="WHERE"
		       DISPLAY="ALL"
		       NUM=":STRUCT_NUM"
		       TABLEALIAS="CC"
		       OPERATOR="BETWEEN"
		       OPERAND1=":P_ACCOUNT_START"
		       OPERAND2=":P_ACCOUNT_END"');*/



  END;

  DECLARE
	   p_num  number;
	   p_year number;
  BEGIN
	   SELECT glp.period_num,glp.period_year into p_num,p_year from gl_periods glp,gl_sets_of_books gls
	   WHERE   glp.period_name = P_start_period
	   AND     glp.period_set_name = gls.period_set_name
	   AND     gls.set_of_books_id = P_set_of_books_id;

	   C_PNUM := p_num;
	   C_PYEAR := p_year;
	 exception
	  when NO_DATA_FOUND then
	  null;
	 end;
	 declare
	   p_num1  number;
	   p_year1 number;
	 begin
	   SELECT  glp.period_num,glp.period_year into p_num1,p_year1 from gl_periods glp,gl_sets_of_books gls
	   WHERE   glp.period_name = P_end_period
	   AND     glp.period_set_name = gls.period_set_name
	   AND     gls.set_of_books_id = P_set_of_books_id;

	   C_PNUM1 := p_num1;
	   C_PYEAR1 := p_year1;
	 exception
	  when NO_DATA_FOUND then
	  null;
  END;

	  return (TRUE);

END BEFOREREPORT;


END JL_JLCOGLAN_XMLP_PKG;



/
