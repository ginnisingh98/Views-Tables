--------------------------------------------------------
--  DDL for Package Body WIP_WIPPURGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPPURGE_XMLP_PKG" AS
/* $Header: WIPPURGEB.pls 120.2 2008/01/31 12:30:11 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    WSM_ORG NUMBER;
    CODE NUMBER;
    TEXT VARCHAR2(100);
    DATE_FORMAT VARCHAR2(20):='DD'||'-MON-'||'YYYY HH24:MI';
  BEGIN
    WSM_ORG := 0;
    WSM_ORG := WSMPUTIL.CHECK_WSM_ORG(P_ORGANIZATION_ID
                                     ,CODE
                                     ,TEXT);
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK"
                  APPL_SHORT_NAME="INV" OUTPUT="P_FLEXDATA"
                  MODE="SELECT" DISPLAY="ALL" TABLEALIAS="MSI" ')*/NULL;
    WIP_DISCRETE_WS_MOVE.INITTIMEZONE;
    P_CUTOFF_DATE_CLIENT := WIP_DISCRETE_WS_MOVE.SERVERTOCLIENTDATE(P_CUTOFF_DATE);
P_CUTOFF_DATE_DISP := to_char(P_CUTOFF_DATE_CLIENT,DATE_FORMAT);
 SELECT
      WIP_DATETIMES.LE_DATE_TO_SERVER(MAX(SCHEDULE_CLOSE_DATE)
                                     ,P_ORGANIZATION_ID)
    INTO P_MAX_DATE
    FROM
      ORG_ACCT_PERIODS
    WHERE PERIOD_CLOSE_DATE is not null
      AND OPEN_FLAG = 'N'
      AND ORGANIZATION_ID = TO_CHAR(P_ORGANIZATION_ID);
    IF (P_MAX_DATE IS NULL) OR (P_CUTOFF_DATE > P_MAX_DATE) THEN
      FND_MESSAGE.SET_NAME('WIP'
                          ,'WIP_BAD_CUTOFF_DATE');
      FND_MESSAGE.SET_TOKEN('ENTITY'
                           ,TO_CHAR(WIP_DISCRETE_WS_MOVE.SERVERTOCLIENTDATE(P_MAX_DATE)
                                  ,'DD-MON-RRRR HH24:MI:SS')
                           ,FALSE);
      P_ERROR_TEXT := SUBSTR(FND_MESSAGE.GET
                            ,1
                            ,500);
      /*SRW.MESSAGE(1
                 ,P_ERROR_TEXT)*/NULL;
      P_GROUP_ID_V := -1;
      P_ERR_NUM := NULL;
      P_ERROR_TEXT := ' The following exception occured during the purge program : APP-25002: ' || P_ERROR_TEXT;
    ELSE
      P_GROUP_ID_V := WIP_WICTPG.PURGE(P_PURGE_TYPE
                                    ,P_GROUP_ID
                                    ,P_ORGANIZATION_ID
                                    ,P_CUTOFF_DATE
                                    ,P_DAYS_BEFORE_CUTOFF
                                    ,P_FROM_JOB
                                    ,P_TO_JOB
                                    ,P_PRIMARY_ITEM_ID
                                    ,P_LINE_ID
                                    ,P_OPTION
                                    ,(P_CONF_FLAG = 1)
                                    ,(P_HEADER_FLAG = 1)
                                    ,(P_DETAIL_FLAG = 1)
                                    ,(P_MOVE_TXN_FLAG = 1)
                                    ,(P_COST_TRX_FLAG = 1)
                                    ,P_ERR_NUM
                                    ,P_ERROR_TEXT);
      IF (P_GROUP_ID_V = -1) THEN
        P_ERROR_TEXT := ' The following exception occured during the purge program : ' || TO_CHAR(P_ERR_NUM) || '  :-  ' || P_ERROR_TEXT || '.';
      END IF;
    END IF;
    RETURN TRUE;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DELETE FROM WIP_TEMP_REPORTS
     WHERE KEY1 = P_GROUP_ID_V;
    COMMIT;
    IF (P_GROUP_ID_V = -1) THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION G_JOB_LINE_TABGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    IF P_REPORT_OPTION <> 2 THEN
      RETURN FALSE;
    END IF;
    RETURN (TRUE);
  END G_JOB_LINE_TABGROUPFILTER;

  FUNCTION G_JOB_LINE_INFOGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    IF P_REPORT_OPTION = 2 THEN
      RETURN FALSE;
    END IF;
    RETURN (TRUE);
  END G_JOB_LINE_INFOGROUPFILTER;

  FUNCTION G_EXCEPTION_INFOGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    IF P_REPORT_OPTION = 2 THEN
      RETURN FALSE;
    END IF;
    RETURN (TRUE);
  END G_EXCEPTION_INFOGROUPFILTER;

  FUNCTION G_SUCCESS_INFOGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    IF P_REPORT_OPTION = 2 OR P_REPORT_OPTION = 3 THEN
      RETURN FALSE;
    END IF;
    RETURN (TRUE);
  END G_SUCCESS_INFOGROUPFILTER;

  FUNCTION PURGE(P_PURGE_TYPE IN NUMBER
                ,P_GROUP_ID IN NUMBER
                ,P_ORG_ID IN NUMBER
                ,P_CUTOFF_DATE IN DATE
                ,P_FROM_JOB IN VARCHAR2
                ,P_TO_JOB IN VARCHAR2
                ,P_PRIMARY_ITEM_ID IN NUMBER
                ,P_LINE_ID IN NUMBER
                ,P_OPTION IN NUMBER
                ,P_CONF_FLAG IN BOOLEAN
                ,P_HEADER_FLAG IN BOOLEAN
                ,P_DETAIL_FLAG IN BOOLEAN
                ,P_MOVE_TRX_FLAG IN BOOLEAN
                ,P_COST_TRX_FLAG IN BOOLEAN
                ,P_ERR_NUM IN OUT NOCOPY NUMBER
                ,P_ERROR_TEXT IN OUT NOCOPY VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
/*    STPROC.INIT('declare X0P_CONF_FLAG BOOLEAN; X0P_HEADER_FLAG BOOLEAN;
X0P_DETAIL_FLAG BOOLEAN; X0P_MOVE_TRX_FLAG BOOLEAN; X0P_COST_TRX_FLAG BOOLEAN;
begin X0P_CONF_FLAG := sys.diutil.int_to_bool(:P_CONF_FLAG); X0P_HEADER_FLAG := sys.diutil.int_to_bool(:P_HEADER_FLAG); X0P_DETAIL_FLAG := sys.diutil.int_to_bool(:P_DETAIL_FLAG); X0P_MOVE_TRX_FLAG := sys.diutil.int_to_bool(:P_MOVE_TRX_FLAG);
X0P_COST_TRX_FLAG := sys.diutil.int_to_bool(:P_COST_TRX_FLAG); :X0 := WICTPG.PURGE(:P_PURGE_TYPE, :P_GROUP_ID, :P_ORG_ID, :P_CUTOFF_DATE, :P_FROM_JOB, :P_TO_JOB, :P_PRIMARY_ITEM_ID,
:P_LINE_ID, :P_OPTION, X0P_CONF_FLAG, X0P_HEADER_FLAG, X0P_DETAIL_FLAG, X0P_MOVE_TRX_FLAG, X0P_COST_TRX_FLAG, :P_ERR_NUM, :P_ERROR_TEXT); end;');
    STPROC.BIND_I(P_CONF_FLAG);
    STPROC.BIND_I(P_HEADER_FLAG);
    STPROC.BIND_I(P_DETAIL_FLAG);
    STPROC.BIND_I(P_MOVE_TRX_FLAG);
    STPROC.BIND_I(P_COST_TRX_FLAG);
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_PURGE_TYPE);
    STPROC.BIND_I(P_GROUP_ID);
    STPROC.BIND_I(P_ORG_ID);
    STPROC.BIND_I(P_CUTOFF_DATE);
    STPROC.BIND_I(P_FROM_JOB);
    STPROC.BIND_I(P_TO_JOB);
    STPROC.BIND_I(P_PRIMARY_ITEM_ID);
    STPROC.BIND_I(P_LINE_ID);
    STPROC.BIND_I(P_OPTION);
    STPROC.BIND_IO(P_ERR_NUM);
    STPROC.BIND_IO(P_ERROR_TEXT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(6
                   ,X0);
    STPROC.RETRIEVE(16
                   ,P_ERR_NUM);
    STPROC.RETRIEVE(17
                   ,P_ERROR_TEXT);*/ NULL;
    RETURN X0;
  END PURGE;

END WIP_WIPPURGE_XMLP_PKG;



/
