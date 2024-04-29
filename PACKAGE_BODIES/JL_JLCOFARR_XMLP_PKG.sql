--------------------------------------------------------
--  DDL for Package Body JL_JLCOFARR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLCOFARR_XMLP_PKG" AS
/* $Header: JLCOFARRB.pls 120.1 2007/12/25 16:45:01 dwkrishn noship $ */
  PROCEDURE GET_BASE_CURR_DATA IS
    COMPANY_NAME FA_SYSTEM_CONTROLS.COMPANY_NAME%TYPE;
    CAT_FLEX NUMBER;
  BEGIN
    COMPANY_NAME := '';
    BEGIN
      SELECT
        COMPANY_NAME,
        CATEGORY_FLEX_STRUCTURE
      INTO COMPANY_NAME,CAT_FLEX
      FROM
        FA_SYSTEM_CONTROLS;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_ORA_ERR('JL_CO_FA_GENERAL_ERROR');
    END;
    C_COMPANY_NAME := COMPANY_NAME;
    CAT_FLEX_STRUCT := CAT_FLEX;
    BEGIN
      SELECT
        DISTINCT
        C.CURRENCY_CODE
      INTO CURRENCY_CODE
      FROM
        GL_SETS_OF_BOOKS C,
        FA_BOOK_CONTROLS B,
        FA_BOOKS A
      WHERE A.BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
        AND A.BOOK_TYPE_CODE = B.BOOK_TYPE_CODE
        AND B.SET_OF_BOOKS_ID = C.SET_OF_BOOKS_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_ERR('JL_AR_FA_CURR_DET_NOT_DEFINED');
      WHEN OTHERS THEN
        RAISE_ORA_ERR('JL_CO_FA_GENERAL_ERROR');
    END;
  END GET_BASE_CURR_DATA;

  PROCEDURE RAISE_ERR(MSGNAME IN VARCHAR2) IS
    ERRMSG VARCHAR2(1000);
  BEGIN
    FND_MESSAGE.SET_NAME('JL'
                        ,MSGNAME);
    ERRMSG := FND_MESSAGE.GET;
    /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                     ,MSGNAME)
               ,ERRMSG)*/NULL;
    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END RAISE_ERR;

  PROCEDURE RAISE_ORA_ERR(MSGNAME IN VARCHAR2) IS
    ERRMSG VARCHAR2(1000);
    ERRNUM NUMBER;
  BEGIN
    FND_MESSAGE.SET_NAME('JL'
                        ,MSGNAME);
    ERRMSG := FND_MESSAGE.GET;
    /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                     ,MSGNAME)
               ,ERRMSG)*/NULL;
    ERRNUM := SQLCODE;
    ERRMSG := SQLERRM;
    /*SRW.MESSAGE(ERRNUM
               ,ERRMSG)*/NULL;
    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END RAISE_ORA_ERR;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION F_NET_VALFORMULA(CURRENT_VALUATION IN NUMBER
                           ,PRIOR_VALUATION IN NUMBER) RETURN NUMBER IS
    NET_VAL NUMBER;
  BEGIN
    NET_VAL := CURRENT_VALUATION - PRIOR_VALUATION;
    RETURN (NET_VAL);
  END F_NET_VALFORMULA;

  FUNCTION F_APP_VALUATIONFORMULA(APPRAISAL_VALUE IN NUMBER
                                 ,CURRENT_VALUATION IN NUMBER) RETURN NUMBER IS
    APP_VAL NUMBER;
  BEGIN
    APP_VAL := APPRAISAL_VALUE - CURRENT_VALUATION;
    RETURN (APP_VAL);
  END F_APP_VALUATIONFORMULA;

  FUNCTION FORMULA2FORMULA(CS_APPRAISAL_VALUE IN NUMBER) RETURN NUMBER IS
    VALOR NUMBER;
  BEGIN
    VALOR := CS_APPRAISAL_VALUE;
    RETURN (VALOR);
  END FORMULA2FORMULA;

  FUNCTION C_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME;
  END C_COMPANY_NAME_P;

  FUNCTION C_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STATUS;
  END C_STATUS_P;

  FUNCTION C_APP_VALUATION_P RETURN NUMBER IS
  BEGIN
    RETURN C_APP_VALUATION;
  END C_APP_VALUATION_P;

  FUNCTION CP_NET_VALUE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_NET_VALUE;
  END CP_NET_VALUE_P;

  FUNCTION CAT_FLEX_STRUCT_P RETURN NUMBER IS
  BEGIN
    RETURN CAT_FLEX_STRUCT;
  END CAT_FLEX_STRUCT_P;

  FUNCTION C_ALL_SEGS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ALL_SEGS;
  END C_ALL_SEGS_P;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
	get_base_curr_data;
	/*SRW.USER_EXIT('FND SRWINIT');


	SRW.REFERENCE(:cat_flex_struct);
	SRW.USER_EXIT('FND FLEXSQL CODE="CAT#"
	    NUM=":cat_flex_struct"
	    APPL_SHORT_NAME="OFA"
	    TABLEALIAS="ct"
	    OUTPUT=":c_all_segs"
	    MODE="SELECT"
	    DISPLAY="ALL"');*/

	  return (TRUE);
  END;

END JL_JLCOFARR_XMLP_PKG;



/