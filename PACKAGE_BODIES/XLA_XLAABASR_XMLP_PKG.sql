--------------------------------------------------------
--  DDL for Package Body XLA_XLAABASR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_XLAABASR_XMLP_PKG" AS
/* $Header: XLAABASRB.pls 120.0 2007/12/27 11:57:19 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C IS
      SELECT
        ENTITY_CODE,
        EVENT_CLASS_CODE
      FROM
        XLA_EVENT_CLASSES_FVL EC
      WHERE EC.APPLICATION_ID = P_APPLICATION_ID;
    L_EXTRACT_RET_CODE BOOLEAN;
    L_EVENT_CLASS_CODE VARCHAR2(30);
    L_ENTITY_CODE VARCHAR2(30);
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    XLA_UTILITY_PKG.ACTIVATE('SRS_DBP'
                            ,'XLAABASR');
    XLA_ENVIRONMENT_PKG.REFRESH;
    SET_REPORT_CONSTANTS;
    IF (NVL(P_REPORT_ONLY_MODE
       ,'N') <> 'Y') THEN
      IF (P_EVENT_CLASS_CODE IS NULL OR LENGTH(P_EVENT_CLASS_CODE) = 0) THEN
        OPEN C;
        LOOP
          FETCH C
           INTO L_ENTITY_CODE,L_EVENT_CLASS_CODE;
          EXIT WHEN C%NOTFOUND;
          XLA_UTILITY_PKG.TRACE('entity_code = ' || L_ENTITY_CODE
                               ,30);
          XLA_UTILITY_PKG.TRACE('event_class_code = ' || L_EVENT_CLASS_CODE
                               ,30);
          IF (XLA_EXTRACT_INTEGRITY_PKG.CHECK_EXTRACT_INTEGRITY(P_APPLICATION_ID => P_APPLICATION_ID
                                                           ,P_ENTITY_CODE => L_ENTITY_CODE
                                                           ,P_EVENT_CLASS_CODE => L_EVENT_CLASS_CODE
                                                           ,P_PROCESSING_MODE => P_PROCESSING_MODE) = FALSE) THEN
            CP_EXTRACT_RET_CODE := 1;
          END IF;
        END LOOP;
        CLOSE C;
      ELSE
        IF (XLA_EXTRACT_INTEGRITY_PKG.CHECK_EXTRACT_INTEGRITY(P_APPLICATION_ID => P_APPLICATION_ID
                                                         ,P_ENTITY_CODE => P_ENTITY_CODE
                                                         ,P_EVENT_CLASS_CODE => P_EVENT_CLASS_CODE
                                                         ,P_PROCESSING_MODE => P_PROCESSING_MODE) = FALSE) THEN
          CP_EXTRACT_RET_CODE := 1;
        END IF;
      END IF;
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      IF (C%ISOPEN) THEN
        CLOSE C;
      END IF;
      /*SRW.MESSAGE('0'
                 ,SQLERRM)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END BEFOREREPORT;

  PROCEDURE SET_REPORT_CONSTANTS IS
  BEGIN
    IF (P_REPORT_ONLY_MODE = 'N') THEN
      CP_QUERY := ' AND ERR.REQUEST_ID = ' || P_CONC_REQUEST_ID;
    ELSIF (P_REPORT_ONLY_MODE = 'Y') THEN
      CP_QUERY := ' AND ERR.EVENT_CLASS_CODE = ''' || P_EVENT_CLASS_CODE || '''
                                     AND ERR.ENTITY_CODE = ''' || P_ENTITY_CODE || '''
                                     AND ERR.PRODUCT_RULE_CODE IS NULL ';
    ELSE
      CP_QUERY := ' AND ERR.REQUEST_ID = -1';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('0'
                 ,SQLERRM)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END SET_REPORT_CONSTANTS;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
    L_TEMP BOOLEAN;
  BEGIN
    IF CP_EXTRACT_RET_CODE = 1 OR P_REPORT_ONLY_MODE = 'Y' THEN
      L_TEMP := FND_CONCURRENT.SET_COMPLETION_STATUS(STATUS => 'WARNING'
                                                    ,MESSAGE => NULL);
    ELSIF CP_EXTRACT_RET_CODE = 0 THEN
      NULL;
    ELSE
      L_TEMP := FND_CONCURRENT.SET_COMPLETION_STATUS(STATUS => 'ERROR'
                                                    ,MESSAGE => NULL);
    END IF;
    XLA_UTILITY_PKG.DEACTIVATE('XLAABASR');
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      XLA_UTILITY_PKG.DEACTIVATE('XLAABASR');
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END AFTERREPORT;

  FUNCTION CP_EXTRACT_RET_CODE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EXTRACT_RET_CODE;
  END CP_EXTRACT_RET_CODE_P;

  FUNCTION CP_QUERY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_QUERY;
  END CP_QUERY_P;

END XLA_XLAABASR_XMLP_PKG;

/