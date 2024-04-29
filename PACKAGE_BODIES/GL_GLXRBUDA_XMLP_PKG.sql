--------------------------------------------------------
--  DDL for Package Body GL_GLXRBUDA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRBUDA_XMLP_PKG" AS
/* $Header: GLXRBUDAB.pls 120.0 2007/12/27 15:05:00 vijranga noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    OUT_PTD_YTD VARCHAR2(240);
    ERRBUF VARCHAR2(132);
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    BEGIN
      SELECT
        NAME,
        CHART_OF_ACCOUNTS_ID
      INTO ACCESS_SET_NAME,STRUCT_NUM
      FROM
        GL_ACCESS_SETS
      WHERE ACCESS_SET_ID = P_ACCESS_SET_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        ERRBUF := GL_MESSAGE.GET_MESSAGE('GL_PLL_INVALID_DATA_ACCESS_SET'
                                        ,'Y'
                                        ,'DASID'
                                        ,TO_CHAR(P_ACCESS_SET_ID));
        /*SRW.MESSAGE('00'
                   ,ERRBUF)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      WHEN OTHERS THEN
        ERRBUF := SQLERRM;
        /*SRW.MESSAGE('00'
                   ,ERRBUF)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    BEGIN
      SELECT
        NAME
      INTO LEDGER_NAME
      FROM
        GL_LEDGERS
      WHERE LEDGER_ID = P_LEDGER_ID;
      SELECT
        BUDGET_NAME
      INTO BUDGET_NAME
      FROM
        GL_BUDGET_VERSIONS
      WHERE BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;
    EXCEPTION
      WHEN OTHERS THEN
        ERRBUF := SQLERRM;
        /*SRW.MESSAGE('00'
                   ,ERRBUF)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    GL_GET_LOOKUP_VALUE('D'
                       ,P_PERIOD_TYPE
                       ,'PTD_YTD'
                       ,OUT_PTD_YTD
                       ,ERRBUF);
    IF (ERRBUF IS NOT NULL) THEN
      /*SRW.MESSAGE(0
                 ,ERRBUF)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    ELSE
      PTD_YTD_DSP := OUT_PTD_YTD;
    END IF;
    IF (P_PERIOD_TYPE = 'PTD') THEN
      PTD_YTD := '(glbd.period_net_dr - glbd.period_net_cr)';
    ELSIF (P_PERIOD_TYPE = 'YTD') THEN
      PTD_YTD := '(glbd.begin_balance_dr + glbd.period_net_dr - glbd.begin_balance_cr - glbd.period_net_cr)';
    ELSIF (P_PERIOD_TYPE = 'QTD') THEN
      PTD_YTD := '(glbd.period_net_dr + glbd.quarter_to_date_dr - glbd.period_net_cr - glbd.quarter_to_date_cr)';
    ELSE
      PTD_YTD := '(glbd.period_net_dr + glbd.project_to_date_dr - glbd.period_net_cr - glbd.project_to_date_cr)';
    END IF;
    /*SRW.REFERENCE(STRUCT_NUM)*/NULL;
    /*SRW.REFERENCE(STRUCT_NUM)*/NULL;
    /*SRW.REFERENCE(STRUCT_NUM)*/NULL;
    WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(P_ACCESS_SET_ID
                                                               ,'R'
                                                               ,'LEDGER_ID'
                                                               ,P_LEDGER_ID
                                                               ,NULL
                                                               ,'SEG_COLUMN'
                                                               ,NULL
                                                               ,'CS'
                                                               ,NULL);
    IF (WHERE_DAS IS NOT NULL) THEN
      WHERE_DAS := ' and ' || WHERE_DAS;
      ELSE
      WHERE_DAS := '  ';
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION LEDGER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN LEDGER_NAME;
  END LEDGER_NAME_P;

  FUNCTION BUDGET_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN BUDGET_NAME;
  END BUDGET_NAME_P;

  FUNCTION STRUCT_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN STRUCT_NUM;
  END STRUCT_NUM_P;

  FUNCTION FLEXDATA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FLEXDATA;
  END FLEXDATA_P;

  FUNCTION ACCOUNT_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCOUNT_SEG;
  END ACCOUNT_SEG_P;

  FUNCTION FLEX_ORDERBY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FLEX_ORDERBY;
  END FLEX_ORDERBY_P;

  FUNCTION PTD_YTD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN PTD_YTD;
  END PTD_YTD_P;

  FUNCTION PTD_YTD_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN PTD_YTD_DSP;
  END PTD_YTD_DSP_P;

  FUNCTION ACCESS_SET_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCESS_SET_NAME;
  END ACCESS_SET_NAME_P;

  FUNCTION WHERE_DAS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_DAS;
  END WHERE_DAS_P;

  PROCEDURE GL_GET_PERIOD_DATES(TLEDGER_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TSTART_DATE OUT NOCOPY DATE
                               ,TEND_DATE OUT NOCOPY DATE
                               ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin GL_INFO.GL_GET_PERIOD_DATES(:TLEDGER_ID, :TPERIOD_NAME, :TSTART_DATE, :TEND_DATE, :ERRBUF); end;');
    STPROC.BIND_I(TLEDGER_ID);
    STPROC.BIND_I(TPERIOD_NAME);
    STPROC.BIND_O(TSTART_DATE);
    STPROC.BIND_O(TEND_DATE);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,TSTART_DATE);
    STPROC.RETRIEVE(4
                   ,TEND_DATE);
    STPROC.RETRIEVE(5
                   ,ERRBUF);*/null;
  END GL_GET_PERIOD_DATES;

  PROCEDURE GL_GET_LEDGER_INFO(LEDID IN NUMBER
                              ,COAID OUT NOCOPY NUMBER
                              ,LEDNAME OUT NOCOPY VARCHAR2
                              ,FUNC_CURR OUT NOCOPY VARCHAR2
                              ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin GL_INFO.GL_GET_LEDGER_INFO(:LEDID, :COAID, :LEDNAME, :FUNC_CURR, :ERRBUF); end;');
    STPROC.BIND_I(LEDID);
    STPROC.BIND_O(COAID);
    STPROC.BIND_O(LEDNAME);
    STPROC.BIND_O(FUNC_CURR);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,COAID);
    STPROC.RETRIEVE(3
                   ,LEDNAME);
    STPROC.RETRIEVE(4
                   ,FUNC_CURR);
    STPROC.RETRIEVE(5
                   ,ERRBUF);*/null;
  END GL_GET_LEDGER_INFO;

  PROCEDURE GL_GET_BUD_OR_ENC_NAME(ACTUAL_TYPE IN VARCHAR2
                                  ,TYPE_ID IN NUMBER
                                  ,NAME OUT NOCOPY VARCHAR2
                                  ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin GL_INFO.GL_GET_BUD_OR_ENC_NAME(:ACTUAL_TYPE, :TYPE_ID, :NAME, :ERRBUF); end;');
    STPROC.BIND_I(ACTUAL_TYPE);
    STPROC.BIND_I(TYPE_ID);
    STPROC.BIND_O(NAME);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,NAME);
    STPROC.RETRIEVE(4
                   ,ERRBUF);*/null;
  END GL_GET_BUD_OR_ENC_NAME;

  PROCEDURE GL_GET_LOOKUP_VALUE(LMODE IN VARCHAR2
                               ,CODE IN VARCHAR2
                               ,TYPE IN VARCHAR2
                               ,VALUE OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin GL_INFO.GL_GET_LOOKUP_VALUE(:LMODE, :CODE, :TYPE, :VALUE, :ERRBUF); end;');
    STPROC.BIND_I(LMODE);
    STPROC.BIND_I(CODE);
    STPROC.BIND_I(TYPE);
    STPROC.BIND_O(VALUE);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,VALUE);
    STPROC.RETRIEVE(5
                   ,ERRBUF);*/

		   GL_INFO.GL_GET_LOOKUP_VALUE(LMODE,CODE,TYPE,VALUE,ERRBUF);
  END GL_GET_LOOKUP_VALUE;

  PROCEDURE GL_GET_FIRST_PERIOD(TLEDGER_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
 /*   STPROC.INIT('begin GL_INFO.GL_GET_FIRST_PERIOD(:TLEDGER_ID, :TPERIOD_NAME, :TFIRST_PERIOD, :ERRBUF); end;');
    STPROC.BIND_I(TLEDGER_ID);
    STPROC.BIND_I(TPERIOD_NAME);
    STPROC.BIND_O(TFIRST_PERIOD);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,TFIRST_PERIOD);
    STPROC.RETRIEVE(4
                   ,ERRBUF);*/null;
  END GL_GET_FIRST_PERIOD;

  PROCEDURE GL_GET_FIRST_PERIOD_OF_QUARTER(TLEDGER_ID IN NUMBER
                                          ,TPERIOD_NAME IN VARCHAR2
                                          ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                                          ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin GL_INFO.GL_GET_FIRST_PERIOD_OF_QUARTER(:TLEDGER_ID, :TPERIOD_NAME, :TFIRST_PERIOD, :ERRBUF); end;');
    STPROC.BIND_I(TLEDGER_ID);
    STPROC.BIND_I(TPERIOD_NAME);
    STPROC.BIND_O(TFIRST_PERIOD);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,TFIRST_PERIOD);
    STPROC.RETRIEVE(4
                   ,ERRBUF);*/null;
  END GL_GET_FIRST_PERIOD_OF_QUARTER;

  PROCEDURE GL_GET_CONSOLIDATION_INFO(CONS_ID IN NUMBER
                                     ,CONS_NAME OUT NOCOPY VARCHAR2
                                     ,METHOD OUT NOCOPY VARCHAR2
                                     ,CURR_CODE OUT NOCOPY VARCHAR2
                                     ,FROM_LEDID OUT NOCOPY NUMBER
                                     ,TO_LEDID OUT NOCOPY NUMBER
                                     ,DESCRIPTION OUT NOCOPY VARCHAR2
                                     ,START_DATE OUT NOCOPY DATE
                                     ,END_DATE OUT NOCOPY DATE
                                     ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin GL_INFO.GL_GET_CONSOLIDATION_INFO(:CONS_ID, :CONS_NAME, :METHOD, :CURR_CODE, :FROM_LEDID, :TO_LEDID, :DESCRIPTION, :START_DATE, :END_DATE, :ERRBUF); end;');
    STPROC.BIND_I(CONS_ID);
    STPROC.BIND_O(CONS_NAME);
    STPROC.BIND_O(METHOD);
    STPROC.BIND_O(CURR_CODE);
    STPROC.BIND_O(FROM_LEDID);
    STPROC.BIND_O(TO_LEDID);
    STPROC.BIND_O(DESCRIPTION);
    STPROC.BIND_O(START_DATE);
    STPROC.BIND_O(END_DATE);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,CONS_NAME);
    STPROC.RETRIEVE(3
                   ,METHOD);
    STPROC.RETRIEVE(4
                   ,CURR_CODE);
    STPROC.RETRIEVE(5
                   ,FROM_LEDID);
    STPROC.RETRIEVE(6
                   ,TO_LEDID);
    STPROC.RETRIEVE(7
                   ,DESCRIPTION);
    STPROC.RETRIEVE(8
                   ,START_DATE);
    STPROC.RETRIEVE(9
                   ,END_DATE);
    STPROC.RETRIEVE(10
                   ,ERRBUF);*/null;
  END GL_GET_CONSOLIDATION_INFO;

END GL_GLXRBUDA_XMLP_PKG;


/
