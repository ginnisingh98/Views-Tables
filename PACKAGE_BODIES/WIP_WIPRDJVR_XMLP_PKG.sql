--------------------------------------------------------
--  DDL for Package Body WIP_WIPRDJVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPRDJVR_XMLP_PKG" AS
/* $Header: WIPRDJVRB.pls 120.1 2008/01/31 12:32:01 npannamp noship $ */
  FUNCTION DISP_CURRENCYFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (REPORT_OPTION || ' (' || CURRENCY_CODE || ')');
  END DISP_CURRENCYFORMULA;

  FUNCTION ORG_NAME_HDRFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (ORG_NAME);
  END ORG_NAME_HDRFORMULA;

  FUNCTION TOT_CST_INC_STD_CSTFORMULA(TOT_REQ_JOB_STD IN NUMBER
                                     ,TOT_RES_STD_COST IN NUMBER
                                     ,TOT_RES_OVR_STD_COST IN NUMBER
                                     ,TOT_MV_OVR_STD_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(TOT_REQ_JOB_STD)*/NULL;
    /*SRW.REFERENCE(TOT_RES_STD_COST)*/NULL;
    /*SRW.REFERENCE(TOT_RES_OVR_STD_COST)*/NULL;
    /*SRW.REFERENCE(TOT_MV_OVR_STD_COST)*/NULL;
    RETURN (NVL(TOT_REQ_JOB_STD
              ,0) + NVL(TOT_RES_STD_COST
              ,0) + NVL(TOT_RES_OVR_STD_COST
              ,0) + NVL(TOT_MV_OVR_STD_COST
              ,0));
  END TOT_CST_INC_STD_CSTFORMULA;

  FUNCTION TOT_CST_INC_APP_CSTFORMULA(TOT_ACT_ISS_STD IN NUMBER
                                     ,TOT_RES_APP_COST IN NUMBER
                                     ,TOT_RES_OVR_APP_COST IN NUMBER
                                     ,TOT_MV_OVR_APP_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(TOT_ACT_ISS_STD)*/NULL;
    /*SRW.REFERENCE(TOT_RES_APP_COST)*/NULL;
    /*SRW.REFERENCE(TOT_RES_OVR_APP_COST)*/NULL;
    /*SRW.REFERENCE(TOT_MV_OVR_APP_COST)*/NULL;
    RETURN (NVL(TOT_ACT_ISS_STD
              ,0) + NVL(TOT_RES_APP_COST
              ,0) + NVL(TOT_RES_OVR_APP_COST
              ,0) + NVL(TOT_MV_OVR_APP_COST
              ,0));
  END TOT_CST_INC_APP_CSTFORMULA;

  FUNCTION TOT_CST_INC_EFF_VARFORMULA(TOT_USG_VAR IN NUMBER
                                     ,TOT_EFF_VAR IN NUMBER
                                     ,TOT_RES_OVR_EFF_VAR IN NUMBER
                                     ,TOT_MV_OVR_EFF_VAR IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(TOT_USG_VAR)*/NULL;
    /*SRW.REFERENCE(TOT_EFF_VAR)*/NULL;
    /*SRW.REFERENCE(TOT_RES_OVR_EFF_VAR)*/NULL;
    /*SRW.REFERENCE(TOT_MV_OVR_EFF_VAR)*/NULL;
    RETURN (NVL(TOT_USG_VAR
              ,0) + NVL(TOT_EFF_VAR
              ,0) + NVL(TOT_RES_OVR_EFF_VAR
              ,0) + NVL(TOT_MV_OVR_EFF_VAR
              ,0));
  END TOT_CST_INC_EFF_VARFORMULA;

  FUNCTION TOT_JOB_BALANCE_CSTFORMULA(TOT_CST_INC_APP_CST IN NUMBER
                                     ,TOT_SCP_AND_COMP_CST IN NUMBER
                                     ,TOT_CLOSE_TRX_CST IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(TOT_CST_INC_APP_CST)*/NULL;
    /*SRW.REFERENCE(TOT_SCP_AND_COMP_CST)*/NULL;
    /*SRW.REFERENCE(TOT_CLOSE_TRX_CST)*/NULL;
    RETURN (NVL(TOT_CST_INC_APP_CST
              ,0) + NVL(TOT_SCP_AND_COMP_CST
              ,0) + NVL(TOT_CLOSE_TRX_CST
              ,0));
  END TOT_JOB_BALANCE_CSTFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      STD_ORG_COUNT NUMBER;
    BEGIN
      SELECT
        COUNT(*)
      INTO STD_ORG_COUNT
      FROM
        MTL_PARAMETERS
      WHERE ORGANIZATION_ID = ORG_ID
        AND PRIMARY_COST_METHOD = 1;
      IF STD_ORG_COUNT < 1 THEN
        SET_NAME('BOM'
                ,'CST_STD_ORG_REPORT_ONLY');
        /*SRW.MESSAGE(24201
                   ,GET)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;

      select id_flex_num_cl
      into item_id_flex_num
      from(
      SELECT fifst.id_flex_num id_flex_num_cl
      FROM fnd_id_flex_structures fifst
      WHERE fifst.application_id = 401
      AND fifst.id_flex_code = 'MSTK'
      AND fifst.enabled_flag = 'Y'
      AND fifst.freeze_flex_definition_flag = 'Y'
      ORDER BY fifst.id_flex_num)
      where rownum<2;

      SELECT
        OOD.ORGANIZATION_NAME,
        SOB.CURRENCY_CODE,
        FC.EXTENDED_PRECISION,
        FC.PRECISION,
        RPT_SORT_OPT.MEANING,
        RPT_RUN_OPT.MEANING,
        ML1.MEANING,
        ML2.MEANING
      INTO ORG_NAME,CURRENCY_CODE,EXT_PRECISION,PRECISION,REPORT_SORT,REPORT_OPTION,C_INCLUDE_BULK,C_INCLUDE_VENDOR
      FROM
        FND_CURRENCIES FC,
        GL_SETS_OF_BOOKS SOB,
        ORG_ORGANIZATION_DEFINITIONS OOD,
        MFG_LOOKUPS RPT_SORT_OPT,
        MFG_LOOKUPS RPT_RUN_OPT,
        MFG_LOOKUPS ML1,
        MFG_LOOKUPS ML2
      WHERE OOD.ORGANIZATION_ID = ORG_ID
        AND OOD.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
        AND SOB.CURRENCY_CODE = FC.CURRENCY_CODE
        AND FC.ENABLED_FLAG = 'Y'
        AND RPT_SORT_OPT.LOOKUP_TYPE = 'CST_WIP_REPORT_SORT'
        AND RPT_SORT_OPT.LOOKUP_CODE = REPORT_SORT_OPT
        AND RPT_RUN_OPT.LOOKUP_TYPE = 'CST_WIP_VALUE_REPORT_TYPE'
        AND RPT_RUN_OPT.LOOKUP_CODE = REPORT_RUN_OPT
        AND ML1.LOOKUP_CODE = NVL(P_INCLUDE_BULK
         ,2)
        AND ML1.LOOKUP_TYPE = 'SYS_YES_NO'
        AND ML2.LOOKUP_CODE = NVL(P_INCLUDE_VENDOR
         ,2)
        AND ML2.LOOKUP_TYPE = 'SYS_YES_NO';
      IF CLASS_TYPE IS NULL THEN
        CLASS_TYPE_NAME := '';
      ELSE
        SELECT
          CLS_TYPE.MEANING
        INTO CLASS_TYPE_NAME
        FROM
          MFG_LOOKUPS CLS_TYPE
        WHERE CLS_TYPE.LOOKUP_TYPE = 'WIP_CLASS_TYPE'
          AND CLS_TYPE.LOOKUP_CODE = CLASS_TYPE;
      END IF;
      IF STATUS_TYPE IS NULL THEN
        STATUS_TYPE_NAME := '';
      ELSE
        SELECT
          STS_TYPE.MEANING
        INTO STATUS_TYPE_NAME
        FROM
          MFG_LOOKUPS STS_TYPE
        WHERE STS_TYPE.LOOKUP_TYPE = 'WIP_JOB_STATUS'
          AND STS_TYPE.LOOKUP_CODE = STATUS_TYPE;
      END IF;
      IF (JOB_FROM IS NULL) AND (JOB_TO IS NULL) THEN
        WHERE_JOB := '1 = 1';
      ELSIF (JOB_FROM IS NULL) AND (JOB_TO IS NOT NULL) THEN
        WHERE_JOB := 'wp.wip_entity_name <= ''' || REPLACE(JOB_TO
                            ,''''
                            ,'''''') || '''';
      ELSIF (JOB_FROM IS NOT NULL) AND (JOB_TO IS NULL) THEN
        WHERE_JOB := 'wp.wip_entity_name >= ''' || REPLACE(JOB_FROM
                            ,''''
                            ,'''''') || '''';
      ELSE
        WHERE_JOB := 'wp.wip_entity_name BETWEEN ''' || REPLACE(JOB_FROM
                            ,''''
                            ,'''''') || ''' AND ''' || REPLACE(JOB_TO
                            ,''''
                            ,'''''') || '''';
      END IF;
      IF (CLASS_FROM IS NULL) AND (CLASS_TO IS NULL) THEN
        WHERE_CLASS := '1 = 1';
      ELSIF (CLASS_FROM IS NULL) AND (CLASS_TO IS NOT NULL) THEN
        WHERE_CLASS := 'wdj.class_code <= ''' || CLASS_TO || '''';
      ELSIF (CLASS_FROM IS NOT NULL) AND (CLASS_TO IS NULL) THEN
        WHERE_CLASS := 'wdj.class_code >= ''' || CLASS_FROM || '''';
      ELSE
        WHERE_CLASS := 'wdj.class_code BETWEEN ''' || CLASS_FROM || ''' AND ''' || CLASS_TO || '''';
      END IF;
      IF (P_PROJECT_ID IS NOT NULL) THEN
        P_PROJECT_WHERE := 'wdj.project_id = ' || P_PROJECT_ID;
        P_PROJ_WHERE := 'wt.project_id =' || P_PROJECT_ID;
      END IF;
      IF REPORT_SORT_OPT = 1 THEN
        REPORT_SORT_BY_BEF := 'wp.wip_entity_name, ';
        REPORT_SORT_BY_AFT := ' ';
      ELSIF REPORT_SORT_OPT = 2 THEN
        REPORT_SORT_BY_BEF := ' ';
        REPORT_SORT_BY_AFT := ', wp.wip_entity_name';
      ELSIF REPORT_SORT_OPT = 3 THEN
        REPORT_SORT_BY_BEF := 'ml_class_type.meaning, ';
        REPORT_SORT_BY_AFT := ', wp.wip_entity_name';
      END IF;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK" SET=":ORG_ID"
                            APPL_SHORT_NAME="INV" OUTPUT=":P_FLEXDATA_ITEM"
                            MODE="SELECT"  DISPLAY="ALL"
                            TABLEALIAS="MSI"')*/NULL;
      IF (P_FROM_ITEM IS NOT NULL) THEN
        IF (P_TO_ITEM IS NOT NULL) THEN
          NULL;
        ELSE
          NULL;
        END IF;
      ELSE
        IF (P_TO_ITEM IS NOT NULL) THEN
          NULL;
        ELSE
          P_WHERE_ITEM := '1 = 1';
        END IF;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_TO_ITEM IS NOT NULL OR P_FROM_ITEM IS NOT NULL THEN
      P_OUTER := ' ';
    END IF;
    IF SUBMITTED_BY = 'SRS' THEN
      P_SUBMISSION_TYPE := 'and wac.class_type = :class_type';
    ELSE
      P_SUBMISSION_TYPE := 'and wac.class_type IN (1, 3, 5, 6) and
                                   wp.wip_entity_id in
                                         (select wip_entity_id
                                          from wip_dj_close_temp
                                          where group_id = :GROUP_ID)';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_MAT_DISPFORMULA(WIP_SUPPLY_TYPE IN NUMBER
                            ,QTY_ISSUED IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (WIP_SUPPLY_TYPE <> 4 AND WIP_SUPPLY_TYPE <> 5) THEN
      RETURN (1);
    ELSE
      IF (WIP_SUPPLY_TYPE = 4) THEN
        IF (P_INCLUDE_BULK = 1) THEN
          RETURN (1);
        ELSE
          IF (QTY_ISSUED <> 0) THEN
            RETURN (1);
          ELSE
            RETURN (0);
          END IF;
        END IF;
      ELSIF (WIP_SUPPLY_TYPE = 5) THEN
        IF (P_INCLUDE_VENDOR = 1) THEN
          RETURN (1);
        ELSE
          IF (QTY_ISSUED <> 0) THEN
            RETURN (1);
          ELSE
            RETURN (0);
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  END C_MAT_DISPFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION REPORT_SORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_SORT;
  END REPORT_SORT_P;

  FUNCTION WHERE_CLASS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_CLASS;
  END WHERE_CLASS_P;

  FUNCTION REPORT_SORT_BY_AFT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_SORT_BY_AFT;
  END REPORT_SORT_BY_AFT_P;

  FUNCTION CLASS_TYPE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CLASS_TYPE_NAME;
  END CLASS_TYPE_NAME_P;

  FUNCTION REPORT_SORT_BY_BEF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_SORT_BY_BEF;
  END REPORT_SORT_BY_BEF_P;

  FUNCTION PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN PRECISION;
  END PRECISION_P;

  FUNCTION EXT_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN EXT_PRECISION;
  END EXT_PRECISION_P;

  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURRENCY_CODE;
  END CURRENCY_CODE_P;

  FUNCTION REPORT_OPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_OPTION;
  END REPORT_OPTION_P;

  FUNCTION STATUS_TYPE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN STATUS_TYPE_NAME;
  END STATUS_TYPE_NAME_P;

  FUNCTION ORG_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ORG_NAME;
  END ORG_NAME_P;

  FUNCTION C_INCLUDE_BULK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_INCLUDE_BULK;
  END C_INCLUDE_BULK_P;

  FUNCTION C_INCLUDE_VENDOR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_INCLUDE_VENDOR;
  END C_INCLUDE_VENDOR_P;

  FUNCTION WHERE_JOB_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_JOB;
  END WHERE_JOB_P;

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin FND_MESSAGE.SET_NAME(:APPLICATION, :NAME); end;');
    STPROC.BIND_I(APPLICATION);
    STPROC.BIND_I(NAME);
    STPROC.EXECUTE;*/ null;
  END SET_NAME;

  PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN BOOLEAN) IS
  BEGIN
/*    STPROC.INIT('declare TRANSLATE BOOLEAN; begin TRANSLATE := sys.diutil.int_to_bool(:TRANSLATE); FND_MESSAGE.SET_TOKEN(:TOKEN, :VALUE, TRANSLATE); end;');
    STPROC.BIND_I(TRANSLATE);
    STPROC.BIND_I(TOKEN);
    STPROC.BIND_I(VALUE);
    STPROC.EXECUTE;*/
    null;
  END SET_TOKEN;

  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin FND_MESSAGE.RETRIEVE(:MSGOUT); end;');
    STPROC.BIND_O(MSGOUT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,MSGOUT);*/ null;
  END RETRIEVE;

  PROCEDURE CLEAR IS
  BEGIN
    /*STPROC.INIT('begin FND_MESSAGE.CLEAR; end;');
    STPROC.EXECUTE;*/ null;
  END CLEAR;

  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_MESSAGE.GET_STRING(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/ null;
    RETURN X0;
  END GET_STRING;

  FUNCTION GET_NUMBER(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_MESSAGE.GET_NUMBER(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/ null;
    RETURN X0;
  END GET_NUMBER;

  FUNCTION GET RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_MESSAGE.GET; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/ null;
    RETURN X0;
  END GET;

  FUNCTION GET_ENCODED RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_MESSAGE.GET_ENCODED; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/ null;
    RETURN X0;
  END GET_ENCODED;

  PROCEDURE PARSE_ENCODED(ENCODED_MESSAGE IN VARCHAR2
                         ,APP_SHORT_NAME OUT NOCOPY VARCHAR2
                         ,MESSAGE_NAME OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin FND_MESSAGE.PARSE_ENCODED(:ENCODED_MESSAGE, :APP_SHORT_NAME, :MESSAGE_NAME); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.BIND_O(APP_SHORT_NAME);
    STPROC.BIND_O(MESSAGE_NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,APP_SHORT_NAME);
    STPROC.RETRIEVE(3
                   ,MESSAGE_NAME);*/ null;
  END PARSE_ENCODED;

  PROCEDURE SET_ENCODED(ENCODED_MESSAGE IN VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin FND_MESSAGE.SET_ENCODED(:ENCODED_MESSAGE); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.EXECUTE;*/ null;
  END SET_ENCODED;

  PROCEDURE RAISE_ERROR IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.RAISE_ERROR; end;');
    STPROC.EXECUTE;*/ null;
  END RAISE_ERROR;

END WIP_WIPRDJVR_XMLP_PKG;



/
