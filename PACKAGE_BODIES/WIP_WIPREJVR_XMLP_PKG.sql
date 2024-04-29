--------------------------------------------------------
--  DDL for Package Body WIP_WIPREJVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPREJVR_XMLP_PKG" AS
/* $Header: WIPREJVRB.pls 120.1 2008/01/31 12:36:51 npannamp noship $ */
  FUNCTION DISP_CURRENCYFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (REPORT_OPTION || ' (' || CURRENCY_CODE || ')');
  END DISP_CURRENCYFORMULA;

  FUNCTION ORG_NAME_HDRFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (ORG_NAME);
  END ORG_NAME_HDRFORMULA;

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
    BEGIN
    SELECT fifst.id_flex_num
into p_item_flex_num
FROM fnd_id_flex_structures fifst
WHERE fifst.application_id = 401
AND fifst.id_flex_code = 'MSTK'
AND fifst.enabled_flag = 'Y'
AND fifst.freeze_flex_definition_flag = 'Y'
and rownum<2;
    LPER_SCHD_CLS_DATE:=to_char(PER_SCHD_CLS_DATE,'DD-MON-YY');
    LPER_START_DATE:=to_char(PER_START_DATE,'DD-MON-YY');
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      SELECT
        OOD.ORGANIZATION_NAME,
        SOB.CURRENCY_CODE,
        FC.EXTENDED_PRECISION,
        FC.PRECISION,
        RPT_SORT_OPT.MEANING,
        RPT_RUN_OPT.MEANING,
        CLS_TYPE.MEANING
      INTO ORG_NAME,CURRENCY_CODE,EXT_PRECISION,PRECISION,REPORT_SORT,REPORT_OPTION,CLASS_TYPE_NAME
      FROM
        FND_CURRENCIES FC,
        GL_SETS_OF_BOOKS SOB,
        ORG_ORGANIZATION_DEFINITIONS OOD,
        MFG_LOOKUPS RPT_SORT_OPT,
        MFG_LOOKUPS RPT_RUN_OPT,
        MFG_LOOKUPS CLS_TYPE
      WHERE OOD.ORGANIZATION_ID = ORG_ID
        AND OOD.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
        AND SOB.CURRENCY_CODE = FC.CURRENCY_CODE
        AND FC.ENABLED_FLAG = 'Y'
        AND RPT_SORT_OPT.LOOKUP_TYPE = 'CST_WIP_REPORT_SORT'
        AND RPT_SORT_OPT.LOOKUP_CODE = REPORT_SORT_OPT
        AND CLS_TYPE.LOOKUP_TYPE = 'WIP_CLASS_TYPE'
        AND CLS_TYPE.LOOKUP_CODE = 4
        AND RPT_RUN_OPT.LOOKUP_TYPE = 'CST_BICR_DETAIL_OPTION'
        AND RPT_RUN_OPT.LOOKUP_CODE = REPORT_RUN_OPT;
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
        WHERE_JOB := 'wp.wip_entity_name <= ''' || JOB_TO || '''';
      ELSIF (JOB_FROM IS NOT NULL) AND (JOB_TO IS NULL) THEN
        WHERE_JOB := 'wp.wip_entity_name >= ''' || JOB_FROM || '''';
      ELSE
        WHERE_JOB := 'wp.wip_entity_name BETWEEN ''' || JOB_FROM || ''' AND ''' || JOB_TO || '''';
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
      IF REPORT_SORT_OPT = 1 THEN
        REPORT_SORT_BY_BEF := 'wp.wip_entity_name, ';
        REPORT_SORT_BY_AFT := '  ';
      ELSIF REPORT_SORT_OPT = 2 THEN
        REPORT_SORT_BY_BEF := '  ';
        REPORT_SORT_BY_AFT := ', wp.wip_entity_name';
      ELSIF REPORT_SORT_OPT = 3 THEN
        REPORT_SORT_BY_BEF := 'ml_class_type.meaning, ';
        REPORT_SORT_BY_AFT := ', wp.wip_entity_name';
      END IF;
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
    IF P_FROM_ITEM IS NOT NULL OR P_TO_ITEM IS NOT NULL THEN
      P_OUTER := ' ';
    END IF;
    IF SUBMITTED_BY = 'SRS' THEN
      P_SUBSELECT := 'and   (:SUBMITTED_BY = ''SRS''
                             and exists
                                 (select ''x''
                                  from wip_period_balances wpb
                                  where wpb.wip_entity_id = wp.wip_entity_id
                                  and   wpb.organization_id = wp.organization_id
                                  and   wpb.acct_period_id IN
                                       (select oap.acct_period_id
                                        from org_acct_periods oap
                                        where trunc(oap.period_start_date) >= :PER_START_DATE
                                        and   trunc(oap.schedule_close_date) <= :PER_SCHD_CLS_DATE
                     	 and oap.organization_id = wp.organization_id))

                            ) ';
    END IF;
    IF SUBMITTED_BY = 'PLS' THEN
      P_SUBSELECT := 'and      (:SUBMITTED_BY = ''PLS'' and
                             wp.wip_entity_id in
                                   (select wip_entity_id
                                    from wip_dj_close_temp
                                    where group_id = :GROUP_ID)
                            )
                         ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION ORG_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ORG_NAME;
  END ORG_NAME_P;

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

  FUNCTION REPORT_SORT_BY_AFT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_SORT_BY_AFT;
  END REPORT_SORT_BY_AFT_P;

  FUNCTION CLASS_TYPE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CLASS_TYPE_NAME;
  END CLASS_TYPE_NAME_P;

  FUNCTION WHERE_JOB_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_JOB;
  END WHERE_JOB_P;

  FUNCTION REPORT_SORT_BY_BEF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_SORT_BY_BEF;
  END REPORT_SORT_BY_BEF_P;

  FUNCTION WHERE_CLASS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_CLASS;
  END WHERE_CLASS_P;

  FUNCTION REPORT_SORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REPORT_SORT;
  END REPORT_SORT_P;

END WIP_WIPREJVR_XMLP_PKG;


/
