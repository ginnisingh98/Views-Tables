--------------------------------------------------------
--  DDL for Package Body AR_RAXGLA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXGLA_XMLP_PKG" AS
/* $Header: RAXGLAB.pls 120.0 2007/12/27 14:19:24 abraghun noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_LD_SP VARCHAR2(1);
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RP_MESSAGE := NULL;
    IF TO_NUMBER(P_REPORTING_LEVEL) = 1000 THEN
      L_LD_SP := MO_UTILS.CHECK_LEDGER_IN_SP(TO_NUMBER(P_REPORTING_ENTITY_ID));
      IF L_LD_SP = 'N' THEN
        FND_MESSAGE.SET_NAME('FND'
                            ,'FND_MO_RPT_PARTIAL_LEDGER');
        RP_MESSAGE := FND_MESSAGE.GET;
      END IF;
    END IF;
    FND_MESSAGE.SET_NAME('AR'
                        ,'AR_REPORT_ACC_NOT_GEN');
    CP_ACC_MESSAGE := FND_MESSAGE.GET;
    DECLARE
      CUST_LOW VARCHAR2(200);
      CUST_HIGH VARCHAR2(200);
    BEGIN
      IF (P_CURRENCY_CODE IS NOT NULL) THEN
        P_WHERE_1 := '	AND trx.invoice_currency_code = ''' || P_CURRENCY_CODE || '''';
        P_SELECT_1 := ' sum(decode(sign(gl_dist.amount),
                                        				 1, round(gl_dist.amount, 2), NULL)) curr_credit_amount,
                              			 sum(decode(sign(gl_dist.amount),
                                         				-1, -round(gl_dist.amount, 2), NULL)) curr_debit_amount ';
      END IF;
      IF (P_GL_ACCOUNT_TYPE = 'TAX') THEN
        P_WHERE_GL_TYPE := 'and Account_class = ''TAX'' ';
      ELSIF (P_GL_ACCOUNT_TYPE = 'UNBILL') THEN
        P_WHERE_GL_TYPE := 'and Account_class = ''UNBILL'' ';
      ELSIF (P_GL_ACCOUNT_TYPE = 'UNEARN') THEN
        P_WHERE_GL_TYPE := 'and Account_class = ''UNEARN'' ';
      ELSIF (P_GL_ACCOUNT_TYPE = 'SUSPENSE') THEN
        P_WHERE_GL_TYPE := 'and Account_class = ''SUSPENSE'' ';
      ELSIF (P_GL_ACCOUNT_TYPE = 'FREIGHT') THEN
        P_WHERE_GL_TYPE := 'and Account_class = ''FREIGHT'' ';
      ELSIF (P_GL_ACCOUNT_TYPE = 'REV') THEN
        P_WHERE_GL_TYPE := 'and Account_class = ''REV'' ';
      ELSIF (P_GL_ACCOUNT_TYPE = 'REC') THEN
        P_WHERE_GL_TYPE := 'and Account_class = ''REC'' ';
      ELSIF (P_GL_ACCOUNT_TYPE = 'ROUND') THEN
        P_WHERE_GL_TYPE := 'and Account_class = ''ROUND'' ';
      ELSIF (P_GL_ACCOUNT_TYPE IS NULL) THEN
        P_WHERE_GL_TYPE := ' ';
      END IF;
      /*SRW.REFERENCE(P_COAID)*/NULL;
      IF P_COMPANY_START IS NOT NULL THEN
        LP_COMPANY_START := 'and ' || LP_COMPANY_START;
      END IF;
      IF P_COMPANY_END IS NOT NULL THEN
        LP_COMPANY_END := 'and ' || LP_COMPANY_END;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(80);
    BEGIN
      RP_COMPANY_NAME := COMPANY_NAME;
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      RP_REPORT_NAME := L_REPORT_NAME;
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RP_REPORT_NAME := 'Sales Journal By Customer';
        RETURN ('Sales Journal By GL Account');
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;

  FUNCTION REPORT_SUBTITLEFORMULA RETURN VARCHAR2 IS
  BEGIN
    RP_REPORT_SUBTITLE := 'GL Date ' || NVL(TO_CHAR(P_START_GL_DATE
                                     ,'DD-MON-YYYY')
                             ,'     ') || ' - ' || NVL(TO_CHAR(P_END_GL_DATE
                                     ,'DD-MON-YYYY')
                             ,'     ');
    RETURN NULL;
  END REPORT_SUBTITLEFORMULA;

  FUNCTION C_SUM_TEXTFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_GL_ACCOUNT_TYPE = 'ALL' THEN
      RETURN ('Subtotal by Invoice Currency : ');
    ELSE
      RETURN ('Totals : ');
    END IF;
    RETURN NULL;
  END C_SUM_TEXTFORMULA;

  FUNCTION FILTER_NULL RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END FILTER_NULL;

  FUNCTION SET_CURR_CODE_REVFORMULA(CURRENCY_CODE_REV IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(CURRENCY_CODE_REV)*/NULL;
      C_CURR_CODE_REV := CURRENCY_CODE_REV;
      RETURN (CURRENCY_CODE_REV);
    END;
    RETURN NULL;
  END SET_CURR_CODE_REVFORMULA;

  FUNCTION C_REPORT_BY_LINE_MEANINGFORMUL RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_MEANING VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO L_MEANING
      FROM
        AR_LOOKUPS
      WHERE LOOKUP_TYPE = 'YES/NO'
        AND LOOKUP_CODE = P_REPORT_BY_LINE;
      RP_REPORT_BY_LINE_MEANING := L_MEANING;
      RETURN (L_MEANING);
    END;
    RETURN NULL;
  END C_REPORT_BY_LINE_MEANINGFORMUL;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      XLA_MO_REPORTING_API.INITIALIZE(P_REPORTING_LEVEL
                                     ,P_REPORTING_ENTITY_ID
                                     ,'AUTO');
      P_REPORTING_ENTITY_NAME := SUBSTRB(XLA_MO_REPORTING_API.GET_REPORTING_ENTITY_NAME
                                        ,1
                                        ,200);
      P_REPORTING_LEVEL_NAME := SUBSTRB(XLA_MO_REPORTING_API.GET_REPORTING_LEVEL_NAME
                                       ,1
                                       ,30);
      P_ORG_WHERE_C := XLA_MO_REPORTING_API.GET_PREDICATE('C'
                                                         ,NULL);
      P_ORG_WHERE_TRX := XLA_MO_REPORTING_API.GET_PREDICATE('TRX'
                                                           ,NULL);
      P_ORG_WHERE_LINES := XLA_MO_REPORTING_API.GET_PREDICATE('LINES'
                                                             ,NULL);
      P_ORG_WHERE_LINK_LINE := XLA_MO_REPORTING_API.GET_PREDICATE('LINK_LINE'
                                                                 ,NULL);
      P_ORG_WHERE_GL_DIST := XLA_MO_REPORTING_API.GET_PREDICATE('GL_DIST'
                                                               ,NULL);
      P_ORG_WHERE_PARAM := XLA_MO_REPORTING_API.GET_PREDICATE('PARAM'
                                                             ,NULL);
      IF P_START_GL_DATE IS NOT NULL THEN
        LP_START_GL_DATE := ' and gl_dist.gl_date >=  :p_start_gl_date ';
      END IF;
      IF P_END_GL_DATE IS NOT NULL THEN
        LP_END_GL_DATE := ' and gl_dist.gl_date <= :p_end_gl_date ';
      END IF;
      IF P_TRX_DATE_HIGH IS NOT NULL THEN
        LP_TRX_DATE_HIGH := ' and trx.trx_date <= :p_trx_date_high ';
      END IF;
      IF P_TRX_DATE_LOW IS NOT NULL THEN
        LP_TRX_DATE_LOW := ' and trx.trx_date >= :p_trx_date_low ';
      END IF;
      IF (P_TRX_TYPE_LOW IS NOT NULL) THEN
        LP_TRX_TYPE_LOW := 'and arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'') >=  :p_trx_type_low ';
      END IF;
      IF (P_TRX_TYPE_HIGH IS NOT NULL) THEN
        LP_TRX_TYPE_HIGH := 'and arpt_sql_func_util.get_trx_type_details(trx.cust_trx_type_id,''NAME'') <= :p_trx_type_high ';
      END IF;
      IF (P_TRX_NUMBER_LOW IS NOT NULL) THEN
        LP_TRX_NUMBER_LOW := 'and trx.trx_number >= :p_trx_number_low ';
      END IF;
      IF (P_TRX_NUMBER_HIGH IS NOT NULL) THEN
        LP_TRX_NUMBER_HIGH := 'and trx.trx_number <= :p_trx_number_high ';
      END IF;
      IF (P_CUSTOMER_LOW IS NOT NULL) THEN
        LP_CUSTOMER_LOW := 'and party.party_name >=  :p_customer_low ';
      END IF;
      IF (P_CUSTOMER_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_HIGH := 'and party.party_name <=  :p_customer_high ';
      END IF;
      IF (P_CUSTOMER_NUMBER_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER_LOW := 'and c.account_number >= :p_customer_number_low ';
      END IF;
      IF (P_CUSTOMER_NUMBER_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER_HIGH := 'and c.account_number <= :p_customer_number_high ';
      END IF;
      IF (P_REPORT_BY_LINE = 'Y') THEN
        P_LINE_NUMBER := 'decode( gl_dist.account_class,
                                        ''REC''     , ''0'',
                                        ''FREIGHT'' , decode(lines.link_to_cust_trx_line_id,
                                                         ''''  , ''0'' ,
                                                              link_line.line_number),
                                                   nvl(link_line.line_number, lines.line_number)
                                       )';
        P_LINE_NUMBER_ORDER := 'decode( gl_dist.account_class,
                                              ''REC'',     -10,
                                              ''FREIGHT'' , decode(lines.link_to_cust_trx_line_id,
                                                                '''' , -10,
                                                                    link_line.line_number),
                                                         nvl(link_line.line_number, lines.line_number)
                                             )';
      ELSE
        P_LINE_NUMBER := 'null';
      END IF;
      IF (P_ZERO_ROUND = 'Y') THEN
        LP_ZERO_ROUND := ' and (gl_dist.account_class <> ''ROUND''  OR  ' || ' (gl_dist.account_class  = ''ROUND'' and gl_dist.acctd_amount <> 0)) ';
      ELSE
        LP_ZERO_ROUND := NULL;
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION LINE_NUMBER_DISPLAYFORMULA(LINE_NUMBER IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (LINE_NUMBER = '0') THEN
        RETURN ('All');
      ELSE
        RETURN (LINE_NUMBER);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN (LINE_NUMBER);
    END;
    RETURN NULL;
  END LINE_NUMBER_DISPLAYFORMULA;

  FUNCTION OUT_OF_BALANCEFORMULA(SUM_CURR_CR_AMT_SEG_REV IN NUMBER
                                ,SUM_CURR_DR_AMT_SEG_REV IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF (SUM_CURR_CR_AMT_SEG_REV <> SUM_CURR_DR_AMT_SEG_REV) THEN
      RETURN ('*');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END OUT_OF_BALANCEFORMULA;

  FUNCTION C_POSTING_STATUS_MEANINGFORMUL RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      STATUS_MEANING VARCHAR2(200);
    BEGIN
      STATUS_MEANING := '';
      SELECT
        MEANING
      INTO STATUS_MEANING
      FROM
        AR_LOOKUPS
      WHERE LOOKUP_TYPE = 'POSTING_STATUS'
        AND LOOKUP_CODE = NVL(P_POSTING_STATUS
         ,'ALL');
      RETURN (STATUS_MEANING);
    END;
    RETURN NULL;
  END C_POSTING_STATUS_MEANINGFORMUL;

  FUNCTION C_GL_ACCOUNT_TYPE_MEANINGFORMU RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ACCT_MEANING VARCHAR2(200);
    BEGIN
      ACCT_MEANING := '';
      IF (P_GL_ACCOUNT_TYPE IS NOT NULL) THEN
        SELECT
          MEANING
        INTO ACCT_MEANING
        FROM
          AR_LOOKUPS
        WHERE LOOKUP_TYPE = 'AUTOGL_TYPE'
          AND LOOKUP_CODE = P_GL_ACCOUNT_TYPE;
      END IF;
      RETURN (ACCT_MEANING);
    END;
    RETURN NULL;
  END C_GL_ACCOUNT_TYPE_MEANINGFORMU;

  FUNCTION C_ORDER_BY_MEANINGFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_MEANING VARCHAR2(200);
    BEGIN
      ORDER_MEANING := '';
      IF (P_SORT_BY IS NOT NULL) THEN
        SELECT
          MEANING
        INTO ORDER_MEANING
        FROM
          AR_LOOKUPS
        WHERE LOOKUP_TYPE = 'SORT_BY_RAXGLR'
          AND LOOKUP_CODE = P_SORT_BY;
      END IF;
      RETURN (ORDER_MEANING);
    END;
    RETURN NULL;
  END C_ORDER_BY_MEANINGFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION ACCT_BAL_APROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCT_BAL_APROMPT;
  END ACCT_BAL_APROMPT_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION RP_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_SUBTITLE;
  END RP_REPORT_SUBTITLE_P;

  FUNCTION GSUM_CURR_CR_AMT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN GSUM_CURR_CR_AMT;
  END GSUM_CURR_CR_AMT_P;

  FUNCTION GSUM_CURR_DR_AMT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN GSUM_CURR_DR_AMT;
  END GSUM_CURR_DR_AMT_P;

  FUNCTION C_CURR_CODE_REV_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CURR_CODE_REV;
  END C_CURR_CODE_REV_P;

  FUNCTION RP_REPORT_BY_LINE_MEANING_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_BY_LINE_MEANING;
  END RP_REPORT_BY_LINE_MEANING_P;

  FUNCTION C_DATA_FOUND_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATA_FOUND_FLAG;
  END C_DATA_FOUND_FLAG_P;

  FUNCTION RP_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_MESSAGE;
  END RP_MESSAGE_P;

  FUNCTION CP_ACC_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACC_MESSAGE;
  END CP_ACC_MESSAGE_P;

END AR_RAXGLA_XMLP_PKG;


/
