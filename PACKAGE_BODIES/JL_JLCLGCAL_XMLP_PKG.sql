--------------------------------------------------------
--  DDL for Package Body JL_JLCLGCAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLCLGCAL_XMLP_PKG" AS
/* $Header: JLCLGCALB.pls 120.1 2007/12/25 16:43:00 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_DOC_NUMFORMULA(SOURCE IN VARCHAR2
                           ,REFERENCE_6 IN VARCHAR2
                           ,REFERENCE_4 IN VARCHAR2
                           ,REFERENCE_5 IN VARCHAR2
                           ,REFERENCE_8 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      DOC VARCHAR2(240);
    BEGIN
      IF SOURCE = 'Payables' THEN
        IF REFERENCE_6 = 'AP Payments' THEN
          DOC := REFERENCE_4;
        ELSE
          DOC := REFERENCE_5;
        END IF;
      ELSIF SOURCE = 'Receivables' THEN
        IF REFERENCE_8 in ('TRADE','MISC') THEN
          DOC := REFERENCE_4;
        ELSE
          DOC := REFERENCE_5;
        END IF;
      END IF;
      RETURN (DOC);
    END;
    RETURN NULL;
  END C_DOC_NUMFORMULA;

  FUNCTION C_DOCUMENTFORMULA(SOURCE_ID IN VARCHAR2
                            ,REFERENCE_10 IN VARCHAR2
                            ,REFERENCE_9 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      TRANS_TYPE VARCHAR2(240);
      TRANS_MEANING VARCHAR2(240);
      TRANS_SOURCE VARCHAR2(25);
    BEGIN
      SELECT
        NVL(USER_JE_SOURCE_NAME
           ,'**********')
      INTO TRANS_SOURCE
      FROM
        GL_JE_SOURCES_TL
      WHERE JE_SOURCE_NAME = SOURCE_ID
        AND LANGUAGE = 'US';
      IF TRANS_SOURCE = 'Payables' THEN
        TRANS_TYPE := NVL(REFERENCE_10
                         ,'EXPENSE');
      ELSIF TRANS_SOURCE = 'Receivables' THEN
        TRANS_TYPE := REFERENCE_9;
      END IF;
      SELECT
        DESCRIPTION
      INTO TRANS_MEANING
      FROM
        GL_LOOKUPS
      WHERE LOOKUP_TYPE = 'SUBLDGR_DRILLDOWN_TRANS_TYPE'
        AND LOOKUP_CODE = TRANS_TYPE;
      RETURN (TRANS_MEANING);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        TRANS_MEANING := NULL;
        RETURN (TRANS_MEANING);
    END;
    RETURN NULL;
  END C_DOCUMENTFORMULA;

  FUNCTION START_EFFECTIVE_PERIOD_NUMFORM RETURN NUMBER IS
  BEGIN
    DECLARE
      EFF_PERIOD_NUM NUMBER;
      ERRBUF VARCHAR2(132);
      ERRBUF2 VARCHAR2(132);
    BEGIN
      SELECT
        EFFECTIVE_PERIOD_NUM
      INTO EFF_PERIOD_NUM
      FROM
        GL_PERIOD_STATUSES
      WHERE APPLICATION_ID = 101
        AND SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
        AND UPPER(PERIOD_NAME) = UPPER(P_START_PERIOD);
      RETURN (EFF_PERIOD_NUM);
    END;
    RETURN NULL;
  END START_EFFECTIVE_PERIOD_NUMFORM;

  FUNCTION END_EFFECTIVE_PERIOD_NUMFORMUL RETURN NUMBER IS
  BEGIN
    DECLARE
      EFF_PERIOD_NUM NUMBER;
      ERRBUF VARCHAR2(132);
      ERRBUF2 VARCHAR2(132);
    BEGIN
      SELECT
        EFFECTIVE_PERIOD_NUM
      INTO EFF_PERIOD_NUM
      FROM
        GL_PERIOD_STATUSES
      WHERE APPLICATION_ID = 101
        AND SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
        AND UPPER(PERIOD_NAME) = UPPER(P_END_PERIOD);
      RETURN (EFF_PERIOD_NUM);
    END;
    RETURN NULL;
  END END_EFFECTIVE_PERIOD_NUMFORMUL;

  FUNCTION CF_1FORMULA(BEGIN_BAL_DR IN NUMBER
                      ,BEGIN_BAL_CR IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(BEGIN_BAL_DR
              ,0) - NVL(BEGIN_BAL_CR
              ,0));
  END CF_1FORMULA;

  FUNCTION C_END_BALFORMULA(END_BAL_DR IN NUMBER
                           ,END_BAL_CR IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(END_BAL_DR
              ,0) - NVL(END_BAL_CR
              ,0));
  END C_END_BALFORMULA;

  FUNCTION GET_DYNAMIC_WHERE RETURN BOOLEAN IS
    L_MODEL_ID NUMBER := P_MODEL_ID;
    L_DELIMITER VARCHAR2(10) := DELIMITER;
    L_ACCT_LOW VARCHAR2(2000);
    L_ACCT_HIGH VARCHAR2(2000);
    L_DYNAMIC_WHERE1 VARCHAR2(2000);
    L_DYNAMIC_WHERE2 VARCHAR2(10000);
    CURSOR C_RANGES(P_MODEL_ID IN NUMBER) IS
      SELECT
        SEGMENT1_LOW || L_DELIMITER || SEGMENT2_LOW || L_DELIMITER || SEGMENT3_LOW || L_DELIMITER ||
	SEGMENT4_LOW || L_DELIMITER || SEGMENT5_LOW || L_DELIMITER || SEGMENT6_LOW || L_DELIMITER ||
	SEGMENT7_LOW || L_DELIMITER || SEGMENT8_LOW || L_DELIMITER || SEGMENT9_LOW || L_DELIMITER ||
	SEGMENT10_LOW || L_DELIMITER || SEGMENT11_LOW || L_DELIMITER || SEGMENT12_LOW || L_DELIMITER ||
	SEGMENT13_LOW || L_DELIMITER || SEGMENT14_LOW || L_DELIMITER || SEGMENT15_LOW || L_DELIMITER ||
	SEGMENT16_LOW || L_DELIMITER || SEGMENT17_LOW || L_DELIMITER || SEGMENT18_LOW || L_DELIMITER ||
	SEGMENT19_LOW || L_DELIMITER || SEGMENT20_LOW || L_DELIMITER || SEGMENT21_LOW || L_DELIMITER ||
	SEGMENT22_LOW || L_DELIMITER || SEGMENT23_LOW || L_DELIMITER || SEGMENT24_LOW || L_DELIMITER ||
	SEGMENT25_LOW || L_DELIMITER || SEGMENT26_LOW || L_DELIMITER || SEGMENT27_LOW || L_DELIMITER ||
	SEGMENT28_LOW || L_DELIMITER || SEGMENT29_LOW || L_DELIMITER || SEGMENT30_LOW ACCOUNT_LOW,
        SEGMENT1_HIGH || L_DELIMITER || SEGMENT2_HIGH || L_DELIMITER || SEGMENT3_HIGH || L_DELIMITER ||
	SEGMENT4_HIGH || L_DELIMITER || SEGMENT5_HIGH || L_DELIMITER || SEGMENT6_HIGH || L_DELIMITER ||
	SEGMENT7_HIGH || L_DELIMITER || SEGMENT8_HIGH || L_DELIMITER || SEGMENT9_HIGH || L_DELIMITER ||
	SEGMENT10_HIGH || L_DELIMITER || SEGMENT11_HIGH || L_DELIMITER || SEGMENT12_HIGH || L_DELIMITER ||
	SEGMENT13_HIGH || L_DELIMITER || SEGMENT14_HIGH || L_DELIMITER || SEGMENT15_HIGH || L_DELIMITER ||
	SEGMENT16_HIGH || L_DELIMITER || SEGMENT17_HIGH || L_DELIMITER || SEGMENT18_HIGH || L_DELIMITER ||
	SEGMENT19_HIGH || L_DELIMITER || SEGMENT20_HIGH || L_DELIMITER || SEGMENT21_HIGH || L_DELIMITER ||
	SEGMENT22_HIGH || L_DELIMITER || SEGMENT23_HIGH || L_DELIMITER || SEGMENT24_HIGH || L_DELIMITER ||
	SEGMENT25_HIGH || L_DELIMITER || SEGMENT26_HIGH || L_DELIMITER || SEGMENT27_HIGH || L_DELIMITER ||
	SEGMENT28_HIGH || L_DELIMITER || SEGMENT29_HIGH || L_DELIMITER || SEGMENT30_HIGH ACCOUNT_HIGH
      FROM
        JL_ZZ_GL_AXI_MODEL_RANGES AMR
      WHERE AMR.MODEL_ID = P_MODEL_ID;
  BEGIN
    OPEN C_RANGES(L_MODEL_ID);
    LOOP
      FETCH C_RANGES
       INTO L_ACCT_LOW,L_ACCT_HIGH;
      EXIT WHEN C_RANGES%NOTFOUND;
      L_DYNAMIC_WHERE1 := JL_ZZ_GL_SEGS_PKG.GET_BETWEEN(STRUCT_NUM
                                                       ,'cc'
                                                       ,L_ACCT_LOW
                                                       ,L_ACCT_HIGH
                                                       ,'ALL');
      L_DYNAMIC_WHERE1 := '(' || L_DYNAMIC_WHERE1 || ')';
      L_DYNAMIC_WHERE2 := L_DYNAMIC_WHERE2 || L_DYNAMIC_WHERE1 || ' OR ';
    END LOOP;
    CLOSE C_RANGES;
    L_DYNAMIC_WHERE2 := RTRIM(L_DYNAMIC_WHERE2
                             ,' OR ');
    P_DYNAMIC_WHERE := 'AND (' || L_DYNAMIC_WHERE2 || ')';
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_DYNAMIC_WHERE;

  FUNCTION STRUCT_NUM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN STRUCT_NUM;
  END STRUCT_NUM_P;

  FUNCTION C_ACCOUNT_START_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ACCOUNT_START;
  END C_ACCOUNT_START_P;

  FUNCTION C_ACCOUNT_END_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ACCOUNT_END;
  END C_ACCOUNT_END_P;

  FUNCTION WHERE_FLEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_FLEX;
  END WHERE_FLEX_P;

  FUNCTION C_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ACCT;
  END C_ACCT_P;

  FUNCTION SET_OF_BOOKS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SET_OF_BOOKS_NAME;
  END SET_OF_BOOKS_NAME_P;

  FUNCTION CP_COMP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COMP_NAME;
  END CP_COMP_NAME_P;

  FUNCTION CP_COMP_ADDRESS1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COMP_ADDRESS1;
  END CP_COMP_ADDRESS1_P;

  FUNCTION CP_COMP_TAXPAYER_ID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COMP_TAXPAYER_ID;
  END CP_COMP_TAXPAYER_ID_P;

  FUNCTION CP_COMP_ESTAB_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COMP_ESTAB_TYPE;
  END CP_COMP_ESTAB_TYPE_P;

  FUNCTION CP_COMP_ADDRESS2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COMP_ADDRESS2;
  END CP_COMP_ADDRESS2_P;

  FUNCTION DELIMITER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DELIMITER;
  END DELIMITER_P;

  FUNCTION CP_DATE4_FORMAT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DATE4_FORMAT;
  END CP_DATE4_FORMAT_P;

  FUNCTION CP_MODEL_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_MODEL_NAME;
  END CP_MODEL_NAME_P;

function BeforeReport return boolean is
begin

/*--**
srw.user_exit('FND SRWINIT');
srw.user_exit('FND GETPROFILE NAME="LANGUAGE"
               FIELD=":SET_OF_BOOKS_NAME"');
gl_message.set_language(:SET_OF_BOOKS_NAME);
*/--**
/* Get the legder info*/

declare
  coaid     NUMBER;
  ledname   VARCHAR2(30);
  functcurr VARCHAR2(15);
  errbuf    VARCHAR2(132);
  errbuf2   VARCHAR2(132);
begin
  gl_info.gl_get_ledger_info(P_SET_OF_BOOKS_ID,
                             coaid,
                             ledname,
                             functcurr,
                             errbuf);

  if (errbuf is not null) then

    /* Error in PL/SQL routine
       gl_get_bud_enc_name -
     */

    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_ledger_info'
               );
    /* srw.message('00', errbuf2);

    srw.message('00', errbuf);
    raise srw.program_abort; */
    RAISE_APPLICATION_ERROR(-20101,null);
  end if;
--  :SET_OF_BOOKS_NAME := ledname;
end;

  --
  --  Retrieve Company information
  --

  -- P_COMPANY_ID := JG_ZZ_COMPANY_INFO.GET_LOCATION_ID ;
  -- Taking LE as parameter
   P_Company_ID := P_Legal_Entity_ID;

 Begin

   SELECT name comp_name,
          registration_number,
          activity_code,
          ltrim(address_line_1 ||' '|| address_line_2),
          ltrim(address_line_3 ||' '|| town_or_city)
   INTO   CP_COMP_NAME,
          CP_COMP_TAXPAYER_ID,
          CP_COMP_ESTAB_TYPE,
          CP_COMP_ADDRESS1,
          CP_COMP_ADDRESS2
   FROM   XLE_FIRSTPARTY_INFORMATION_V
   WHERE  Legal_entity_id = P_COMPANY_ID
     AND  LEGISLATIVE_CAT_CODE = 'INCOME_TAX';

 Exception
   WHEN NO_DATA_FOUND THEN
     NULL ;
   WHEN OTHERS THEN
     /* srw.message('2', 'Failed to retrieve Company information.'); */ null;

 End ;
 BEGIN
   SELECT concatenated_segment_delimiter
   INTO   delimiter
   FROM   fnd_id_flex_structures
   WHERE  application_id = 101
   AND    id_flex_code = 'GL#'
   AND    id_flex_num  = P_CHART_OF_ACCTS_ID
   AND    ROWNUM < 2;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     NULL ;
   WHEN OTHERS THEN
     /* srw.message('3', 'Failed to retrieve delemiter.'); */ null;
 END;

  --
  --  Get Dateformat
  --
  /* srw.reference(:CP_DATE4_FORMAT);
  srw.user_exit('FND DATE4FORMAT
                 RESULT=":CP_DATE4_FORMAT"'); */
 --
 -- get Model Name
 --
 BEGIN
   SELECT name
   INTO   CP_MODEL_NAME
   FROM   jl_zz_gl_axi_models
   WHERE  model_id = P_MODEL_ID
   AND    set_of_books_id = P_SET_OF_BOOKS_ID;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     NULL ;
   WHEN OTHERS THEN
     /*srw.message('4', 'Failed to retrieve model name.');*/
     NULL;
 END;

-- Bug 2674960

STRUCT_NUM := P_CHART_OF_ACCTS_ID;

 --
 -- Dynamic where
 --
 if (get_dynamic_where <> TRUE) then
	RAISE_APPLICATION_ERROR(-20101,null);
 /*else
    srw.message('999',:p_dynamic_where);*/
 end if;

    --srw.break;

/*srw.reference(:STRUCT_NUM);
srw.user_exit('FND FLEXSQL
		CODE="GL#"
	      	NUM=":STRUCT_NUM"
              	APPL_SHORT_NAME="SQLGL"
              	OUTPUT=":P_FLEXDATA" TABLEALIAS="CC"
              	MODE="SELECT" DISPLAY="ALL"'); */
/*
srw.reference(:STRUCT_NUM);
srw.user_exit('FND FLEXSQL
	      CODE="GL#"
	      NUM=":STRUCT_NUM"
              APPL_SHORT_NAME="SQLGL"
              OUTPUT=":WHERE_FLEX" TABLEALIAS="CC"
              MODE="WHERE" DISPLAY="ALL"
              OPERATOR="BETWEEN"
              OPERAND1=":C_AC_LOW"
              OPERAND2=":C_AC_HIGH"');
*/
/*
srw.reference(:STRUCT_NUM);
srw.user_exit('FND FLEXSQL
	      CODE="GL#"
	      NUM=":STRUCT_NUM"
              APPL_SHORT_NAME="SQLGL"
              OUTPUT=":WHERE_FLEX" TABLEALIAS="CC"
              MODE="WHERE" DISPLAY="ALL"
              OPERATOR="BETWEEN"
              OPERAND1=":P_MIN_FLEX"
              OPERAND2=":P_MAX_FLEX"');
*/

/* Generate the selected ORDER BY */
/*--**
if (:P_ORDER_TYPE = 'A') then
  :ORDER_BY := :ORDERBY_ACCT || ', ' ||
	       :ORDERBY_ACCT2 || ', ' ||
               :ORDERBY_BAL || ', ' ||
	       :ORDERBY_BAL2 || ', ' ||
               :ORDERBY_ALL || ', ' ||
               'src.user_je_source_name, ' ||
               'cat.user_je_category_name, ' ||
               'jeb.name, jeh.name, jel.je_line_num';
elsif (:P_ORDER_TYPE = 'B') then
  :ORDER_BY := :ORDERBY_BAL || ', ' ||
	       :ORDERBY_BAL2 || ', ' ||
               :ORDERBY_ACCT || ', ' ||
	       :ORDERBY_ACCT2 || ', ' ||
               :ORDERBY_ALL || ', ' ||
               'src.user_je_source_name, ' ||
               'cat.user_je_category_name, ' ||
               'jeb.name, jeh.name, jel.je_line_num';
else
  :ORDER_BY := 'src.user_je_source_name, ' ||
               'cat.user_je_category_name, ' ||
               'jeb.name, jeh.name, ' ||
               :ORDERBY_BAL || ', ' ||
	       :ORDERBY_BAL2 || ', ' ||
               :ORDERBY_ACCT || ', ' ||
	       :ORDERBY_ACCT2 || ', ' ||
               :ORDERBY_ALL || ', ' ||
               'jel.je_line_num';
end if;

  return (TRUE);
end;
*/--**
  return (TRUE);
end;

END JL_JLCLGCAL_XMLP_PKG;




/
