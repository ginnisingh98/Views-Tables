--------------------------------------------------------
--  DDL for Package Body AR_ARBARL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARBARL_XMLP_PKG" AS
/* $Header: ARBARLB.pls 120.0 2007/12/27 11:08:11 abraghun noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    IF (P_COMMIT_AT_END = 'Y') THEN
    /*  EXECUTE IMMEDIATE
        'commit work';*/
	commit;
    ELSE
    /*  EXECUTE IMMEDIATE
        'rollback work';*/
	rollback;
    END IF;
    IF P_BAD_CCID_COUNT > 0 THEN
      IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING'
                                          ,ARP_STANDARD.FND_MESSAGE('ARBARL_WARN_BAD_CCID'))) THEN
        NULL;
      ELSE
        /*SRW.MESSAGE('2001'
                   ,'Unable to set warning for bad ccids')*/NULL;
      END IF;
    END IF;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('2000'
                 ,SQLERRM)*/NULL;
      RAISE;
  END AFTERREPORT;

  FUNCTION C_PP_AUTO_RULEFORMULA RETURN NUMBER IS
    LINES NUMBER;
    ERRMSG VARCHAR2(128);
    ERRBUF VARCHAR2(256);
    RETCODE VARCHAR2(256);
    BUFFER VARCHAR2(256);
    STATUS NUMBER;
PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF (P_RUN_AUTO_RULE = 'Y') THEN
      ARP_AUTO_RULE.REFRESH(ERRBUF
                           ,RETCODE);
      COMMIT;
      LINES := ARP_AUTO_RULE.CREATE_DISTRIBUTIONS(P_COMMIT_AT_END
                                                 ,P_DEBUG_FLAG
                                                 ,NULL
                                                 ,P_DEBUG_SKIP_ROUNDING
                                                 ,P_CONTINUE_ON_ERROR);
      IF (P_DEBUG_FLAG = 'Y') THEN
        LOOP
          DBMS_OUTPUT.GET_LINE(BUFFER,STATUS);
          IF (STATUS > 0) THEN
            EXIT;
          END IF;
          /*SRW.MESSAGE('100',BUFFER)*/NULL;
        END LOOP;
      END IF;
    ELSE
      LINES := 0;
      IF NVL(CONC_REQUEST_ID,0) > 0 THEN
        SELECT COUNT(*)
        INTO LINES
        FROM RA_CUST_TRX_LINE_GL_DIST
        WHERE REQUEST_ID = CONC_REQUEST_ID
          AND ACCOUNT_CLASS NOT IN ( 'UNEARN' , 'UNBILL' );

        P_CONC_REQUEST_ID := CONC_REQUEST_ID;
      END IF;
    END IF;
    RETURN (LINES);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('2000'
                 ,SQLERRM)*/NULL;
      RAISE;
  END C_PP_AUTO_RULEFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    CONC_REQUEST_ID:=P_CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    P_DEBUG_SKIP_ROUNDING := SUBSTR(UPPER(P_DEBUG_SKIP_ROUNDING)
                                   ,1
                                   ,1);
    IF P_DEBUG_SKIP_ROUNDING = 'Y' THEN
      /*SRW.MESSAGE('0'
                 ,'ROUNDING SUPPRESSED!')*/NULL;
      P_DEBUG_FLAG := 'Y';
    ELSE
      P_DEBUG_SKIP_ROUNDING := NULL;
    END IF;
    P_CONTINUE_ON_ERROR := SUBSTR(UPPER(P_CONTINUE_ON_ERROR)
                                 ,1
                                 ,1);
    IF P_CONTINUE_ON_ERROR <> 'Y' THEN
      P_CONTINUE_ON_ERROR := NULL;
    END IF;
    P_DEBUG_FLAG := SUBSTR(UPPER(P_DEBUG_FLAG)
                          ,1
                          ,1);
    P_RUN_AUTO_RULE := SUBSTR(UPPER(P_RUN_AUTO_RULE)
                             ,1
                             ,1);
    P_COMMIT_AT_END := SUBSTR(UPPER(P_COMMIT_AT_END)
                             ,1
                             ,1);
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CHECK_CONC_REQUEST_ID(ID IN NUMBER) RETURN BOOLEAN IS
    CURSOR SEL_REQUEST_ID(ID IN NUMBER) IS
      SELECT
        'x'
      FROM
        DUAL
      WHERE exists (
        SELECT
          'x'
        FROM
          RA_CUST_TRX_LINE_GL_DIST
        WHERE REQUEST_ID = ID );
    CHK VARCHAR2(30);
  BEGIN
    IF ID IS NULL THEN
      /*SRW.MESSAGE('100'
                 ,'Concurrent Request ID is mandatory')*/NULL;
      RETURN (FALSE);
    END IF;
    OPEN SEL_REQUEST_ID(ID);
    FETCH SEL_REQUEST_ID
     INTO CHK;
    IF SEL_REQUEST_ID%FOUND THEN
      /*SRW.MESSAGE('100'
                 ,'Concurrent Request ' || TO_CHAR(ID) || ' alread used in ra_cust_trx_line_gl_dist')*/NULL;
      CLOSE SEL_REQUEST_ID;
      RETURN (FALSE);
    END IF;
    CLOSE SEL_REQUEST_ID;
    RETURN (TRUE);
  END CHECK_CONC_REQUEST_ID;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
  P_CONTINUE_ON_ERROR_1:=P_CONTINUE_ON_ERROR;
  P_RUN_AUTO_RULE_1:=P_RUN_AUTO_RULE;
  P_COMMIT_AT_END_1:=P_COMMIT_AT_END;
  P_DEBUG_FLAG_1:=P_DEBUG_FLAG;
  P_DEBUG_SKIP_ROUNDING_1:=P_DEBUG_SKIP_ROUNDING;
    GET_FLEX_ACCOUNT;
    SETUP_WHO_DATA;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_BAD_CCID_FUNCTFORMULA RETURN NUMBER IS
  BEGIN
    P_BAD_CCID_COUNT := P_BAD_CCID_COUNT + 1;
    RETURN P_BAD_CCID_COUNT;
  END CF_BAD_CCID_FUNCTFORMULA;

  PROCEDURE GET_FLEX_ACCOUNT IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  BeforeReport_Procs.Get_Flex_Account.')*/NULL;
  END GET_FLEX_ACCOUNT;

  PROCEDURE SETUP_WHO_DATA IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  BeforeReport_Procs.Setup_Who_Data.')*/NULL;
    ARP_STANDARD.SET_APPLICATION_INFORMATION(P_APPLICATION_ID
                                            ,P_LANGUAGE_ID);
    ARP_STANDARD.SET_WHO_INFORMATION(P_USER_ID
                                    ,P_CONC_REQUEST_ID
                                    ,P_APPLICATION_ID
                                    ,P_PROGRAM_ID
                                    ,NULL);
  END SETUP_WHO_DATA;

END AR_ARBARL_XMLP_PKG;


/
