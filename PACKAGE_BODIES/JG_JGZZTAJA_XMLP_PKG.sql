--------------------------------------------------------
--  DDL for Package Body JG_JGZZTAJA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_JGZZTAJA_XMLP_PKG" AS
/* $Header: JGZZTAJAB.pls 120.2 2007/12/25 16:03:16 npannamp noship $ */
function BeforeReport return boolean is
BEGIN


  SELECT 	count(*)
  INTO		CP_ROWS_SELECTED
  FROM 		jg_zz_ta_rule_sets		rs,
 		fnd_lookups			l,
		jg_zz_ta_cc_ranges		cc,
		jg_zz_ta_account_ranges		acc,
		jg_zz_ta_rule_lines		rl
  WHERE		rl.account_range_id 		= acc.account_range_id
  AND		acc.cc_range_id			= cc.cc_range_id
  AND		cc.rule_set_id			= rs.rule_set_id
  AND 		rs.account_type			= l.lookup_code(+)
  AND		NVL(l.lookup_type,'ACCOUNT_TYPE')	= 'ACCOUNT_TYPE'
  AND		rs.rule_set_id			= NVL(P_RULE_SET_ID,rs.rule_set_id);


  SELECT sob.name
  INTO C_SET_OF_BOOKS_NAME
  FROM GL_SETS_OF_BOOKS sob
  WHERE sob.set_of_books_id = P_SET_OF_BOOKS_ID;

  IF (P_DEBUG_MODE= 'Y') THEN
    -- SRW.BREAK;
    null;
  END IF;
  return (TRUE);
end;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_THE_END_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_THE_END;
  END C_THE_END_P;

  FUNCTION C_SET_OF_BOOKS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SET_OF_BOOKS_NAME;
  END C_SET_OF_BOOKS_NAME_P;

  FUNCTION CP_DATE_FORMAT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DATE_FORMAT;
  END CP_DATE_FORMAT_P;

  FUNCTION CP_ROWS_SELECTED_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ROWS_SELECTED;
  END CP_ROWS_SELECTED_P;

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.SET_NAME(:APPLICATION, :NAME); end;');
    STPROC.BIND_I(APPLICATION);
    STPROC.BIND_I(NAME);
    STPROC.EXECUTE;*/null;
  END SET_NAME;

  PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN BOOLEAN) IS
  BEGIN
  /*  STPROC.INIT('declare TRANSLATE BOOLEAN; begin TRANSLATE := sys.diutil.int_to_bool(:TRANSLATE); FND_MESSAGE.SET_TOKEN(:TOKEN, :VALUE, TRANSLATE); end;');
    STPROC.BIND_I(TRANSLATE);
    STPROC.BIND_I(TOKEN);
    STPROC.BIND_I(VALUE);
    STPROC.EXECUTE;*/null;
  END SET_TOKEN;

  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.RETRIEVE(:MSGOUT); end;');
    STPROC.BIND_O(MSGOUT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,MSGOUT);*/null;
  END RETRIEVE;

  PROCEDURE CLEAR IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.CLEAR; end;');
    STPROC.EXECUTE;*/null;
  END CLEAR;

  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
 /*   STPROC.INIT('begin :X0 := FND_MESSAGE.GET_STRING(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END GET_STRING;

  FUNCTION GET RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := FND_MESSAGE.GET; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET;

  FUNCTION GET_ENCODED RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := FND_MESSAGE.GET_ENCODED; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_ENCODED;

  PROCEDURE PARSE_ENCODED(ENCODED_MESSAGE IN VARCHAR2
                         ,APP_SHORT_NAME OUT NOCOPY VARCHAR2
                         ,MESSAGE_NAME OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.PARSE_ENCODED(:ENCODED_MESSAGE, :APP_SHORT_NAME, :MESSAGE_NAME); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.BIND_O(APP_SHORT_NAME);
    STPROC.BIND_O(MESSAGE_NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,APP_SHORT_NAME);
    STPROC.RETRIEVE(3
                   ,MESSAGE_NAME);*/null;
  END PARSE_ENCODED;

  PROCEDURE SET_ENCODED(ENCODED_MESSAGE IN VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.SET_ENCODED(:ENCODED_MESSAGE); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.EXECUTE;*/null;
  END SET_ENCODED;

  PROCEDURE RAISE_ERROR IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.RAISE_ERROR; end;');
    STPROC.EXECUTE;*/null;
  END RAISE_ERROR;

  PROCEDURE DEBUG(LINE IN VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin CEP_STANDARD.DEBUG(:LINE); end;');
    STPROC.BIND_I(LINE);
    STPROC.EXECUTE;*/null;
  END DEBUG;

  PROCEDURE ENABLE_DEBUG IS
  BEGIN
   /* STPROC.INIT('begin CEP_STANDARD.ENABLE_DEBUG; end;');
    STPROC.EXECUTE;*/null;
  END ENABLE_DEBUG;

  PROCEDURE DISABLE_DEBUG IS
  BEGIN
  /*  STPROC.INIT('begin CEP_STANDARD.DISABLE_DEBUG; end;');
    STPROC.EXECUTE;*/null;
  END DISABLE_DEBUG;

  FUNCTION GET_WINDOW_SESSION_TITLE RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := CEP_STANDARD.GET_WINDOW_SESSION_TITLE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_WINDOW_SESSION_TITLE;

  FUNCTION GET_EFFECTIVE_DATE(P_BANK_ACCOUNT_ID IN NUMBER
                             ,P_TRX_CODE IN VARCHAR2
                             ,P_RECEIPT_DATE IN DATE) RETURN DATE IS
    X0 DATE;
  BEGIN
  /*  STPROC.INIT('begin :X0 := CEP_STANDARD.GET_EFFECTIVE_DATE(:P_BANK_ACCOUNT_ID, :P_TRX_CODE, :P_RECEIPT_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BANK_ACCOUNT_ID);
    STPROC.BIND_I(P_TRX_CODE);
    STPROC.BIND_I(P_RECEIPT_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_EFFECTIVE_DATE;

END JG_JGZZTAJA_XMLP_PKG;



/