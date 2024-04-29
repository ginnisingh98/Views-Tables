--------------------------------------------------------
--  DDL for Package Body BOM_CSTRSCCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRSCCR_XMLP_PKG" AS
/* $Header: CSTRSCCRB.pls 120.0 2007/12/24 10:17:29 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_STMT_NUM NUMBER(15);
    O_ERROR_CODE NUMBER(15);
    O_ERROR_MSG VARCHAR2(2000);
    L_EXCLUDE_UNIMP_ECO NUMBER(15);
    L_EXCLUDE_ENG NUMBER(15);
    L_TIMESTAMP DATE;
    L_RERUN_FLAG NUMBER(15);
    L_STR_POS NUMBER(15);
    L_ORGANIZATION_ID NUMBER(15);
    CONC_STATUS BOOLEAN;
    L_USER_ID NUMBER(15) := -1;
    L_LOGIN_ID NUMBER(15) := -1;
    L_REQUEST_ID NUMBER(15) := -1;
    L_PROG_APPL_ID NUMBER(15) := -1;
    L_PROG_ID NUMBER(15) := -1;
    L_ROWS_UNEXPLODED NUMBER(15);
    L_NO_BOM_ORG VARCHAR2(4);
    L_NO_ALT_ORG VARCHAR2(4);
    L_SNAPSHOT_DESIGNATOR VARCHAR2(20);
    CURSOR NO_BOM_ORGS IS
      SELECT
        DISTINCT
        CSLLC.ORGANIZATION_ID
      FROM
        CST_SC_LOW_LEVEL_CODES CSLLC
      WHERE CSLLC.ROLLUP_ID = P_ROLLUP_ID
        AND not exists (
        SELECT
          'x'
        FROM
          BOM_PARAMETERS BP
        WHERE CSLLC.ORGANIZATION_ID = BP.ORGANIZATION_ID );
    CURSOR NO_ALT_ORGS(I_SNAPSHOT_DESIGNATOR IN VARCHAR2) IS
      SELECT
        DISTINCT
        CSLLC.ORGANIZATION_ID
      FROM
        CST_SC_LOW_LEVEL_CODES CSLLC
      WHERE CSLLC.ROLLUP_ID = P_ROLLUP_ID
        AND not exists (
        SELECT
          'Alternate designator exists'
        FROM
          BOM_ALTERNATE_DESIGNATORS BAD
        WHERE BAD.ORGANIZATION_ID = CSLLC.ORGANIZATION_ID
          AND BAD.ALTERNATE_DESIGNATOR_CODE = I_SNAPSHOT_DESIGNATOR );
    CURSOR LOOP_ROWS(I_ROLLUP_ID IN NUMBER) IS
      SELECT
        CSBE.ASSEMBLY_ITEM_ID,
        CSBE.ASSEMBLY_ORGANIZATION_ID,
        CSBE.COMPONENT_ITEM_ID,
        CSBE.COMPONENT_ORGANIZATION_ID
      FROM
        CST_SC_BOM_EXPLOSION CSBE
      WHERE CSBE.ROLLUP_ID = I_ROLLUP_ID
        AND CSBE.DELETED_FLAG <> 'Y';
  BEGIN
  LP_CATEGORY_SET_ID:=P_CATEGORY_SET_ID;
  LP_REPORT_LEVEL:=P_REPORT_LEVEL;
  LP_EXPLOSION_LEVEL:=P_EXPLOSION_LEVEL;
  LP_RANGE_TYPE:=P_RANGE_TYPE;
  LP_ASSIGNMENT_SET_ID:=P_ASSIGNMENT_SET_ID;
  LP_BUY_COST_TYPE_ID:=P_BUY_COST_TYPE_ID;
  LP_DESCRIPTION:=P_DESCRIPTION;
  LP_REVISION_DATE:=P_REVISION_DATE;
  QTY_PRECISION:=bom_common_xmlp_pkg.get_precision(P_qty_precision);
    IF (P_ALT_BOM_DESG IS NOT NULL) THEN
      SELECT
        DISPLAY_NAME
      INTO P_ALT_BOM_DESG_DSP
      FROM
        BOM_ALTERNATE_DESIGNATORS_VL
      WHERE ORGANIZATION_ID = NVL(P_ORGANIZATION_ID
         ,P_DEFAULT_ORG_ID)
        AND ALTERNATE_DESIGNATOR_CODE = P_ALT_BOM_DESG;
    END IF;
    IF (P_ALT_RTG_DESG IS NOT NULL) THEN
      SELECT
        DISPLAY_NAME
      INTO P_ALT_RTG_DESG_DSP
      FROM
        BOM_ALTERNATE_DESIGNATORS_VL
      WHERE ORGANIZATION_ID = NVL(P_ORGANIZATION_ID
         ,P_DEFAULT_ORG_ID)
        AND ALTERNATE_DESIGNATOR_CODE = P_ALT_RTG_DESG;
    END IF;
    L_STMT_NUM := 10;
    IF P_CONC_REQUEST_ID IS NOT NULL THEN
      SELECT
        NVL(MIN(REQUESTED_BY)
           ,-1),
        NVL(MIN(CONC_LOGIN_ID)
           ,-1),
        NVL(MIN(REQUEST_ID)
           ,-1),
        NVL(MIN(PROGRAM_APPLICATION_ID)
           ,-1),
        NVL(MIN(CONCURRENT_PROGRAM_ID)
           ,-1)
      INTO L_USER_ID,L_LOGIN_ID,L_REQUEST_ID,L_PROG_APPL_ID,L_PROG_ID
      FROM
        FND_CONCURRENT_REQUESTS
      WHERE REQUEST_ID = P_CONC_REQUEST_ID;
    END IF;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,'FND SRWINIT >X')*/NULL;
        RAISE;
    END;
    L_STMT_NUM := 20;
    L_STMT_NUM := 25;
    SELECT
      MIN(TO_CHAR(MCV.CATEGORY_ID))
    INTO P_CATEGORY_ID
    FROM
      MTL_CATEGORIES_KFV MCV,
      MTL_CATEGORY_SETS MCS
    WHERE SUBSTRB(MCV.CONCATENATED_SEGMENTS
           ,1
           ,2000) = P_CATEGORY_ID
      AND MCS.CATEGORY_SET_ID = LP_CATEGORY_SET_ID
      AND MCV.STRUCTURE_ID = MCS.STRUCTURE_ID;
    L_STMT_NUM := 26;
    SELECT
      NVL(FND_PROFILE.VALUE('CST_RU_PHANTOM_MATERIAL')
         ,1)
    INTO P_PHANTOM_MAT
    FROM
      DUAL;
    L_STMT_NUM := 30;
    IF P_ROLLUP_ID IS NOT NULL THEN
      L_RERUN_FLAG := 1;
      L_STMT_NUM := 40;
      SELECT
        ROLLUP_ID,
        DESCRIPTION,
        COST_TYPE_ID,
        BUY_COST_TYPE_ID,
        ORGANIZATION_ID,
        ASSIGNMENT_SET_ID,
        CONVERSION_TYPE,
        LP_REPORT_LEVEL,
        EXPLOSION_LEVEL,
        ROLLUP_OPTION_TYPE,
        1,
        RANGE_TYPE,
        TO_CHAR(REVISION_DATE
               ,'YYYY/MM/DD HH24:MI:SS'),
        INC_UNIMP_ECN_FLAG,
        ENG_BILL_FLAG,
        QTY_PRECISION,
        ITEM_ID,
        CATEGORY_SET_ID,
        TO_CHAR(CATEGORY_ID),
        ALT_BOM_DESG,
        ALT_RTG_DESG
      INTO P_ROLLUP_ID,LP_DESCRIPTION,P_COST_TYPE_ID,LP_BUY_COST_TYPE_ID,P_ORGANIZATION_ID
      ,LP_ASSIGNMENT_SET_ID,P_CONVERSION_TYPE,LP_REPORT_LEVEL,LP_EXPLOSION_LEVEL
      ,P_ROLLUP_OPTION_TYPE,P_REPORT_OPTION_TYPE,LP_RANGE_TYPE,LP_REVISION_DATE,P_INC_UNIMP_ECN_FLAG,P_ENG_BILL_FLAG,P_QTY_PRECISION,P_ITEM_ID,LP_CATEGORY_SET_ID,P_CATEGORY_ID,P_ALT_BOM_DESG,P_ALT_RTG_DESG
      FROM
        CST_SC_ROLLUP_HISTORY CSRH
      WHERE CSRH.ROLLUP_ID = P_ROLLUP_ID;
    ELSE
      L_RERUN_FLAG := 2;
      L_STMT_NUM := 50;
      SELECT
        CST_LISTS_S.NEXTVAL
      INTO P_ROLLUP_ID
      FROM
        DUAL;
      L_STMT_NUM := 60;
      IF (P_REPORT_OPTION_TYPE <> -1) THEN
        INSERT INTO CST_SC_ROLLUP_HISTORY
          (ROLLUP_ID
          ,DESCRIPTION
          ,COST_TYPE_ID
          ,BUY_COST_TYPE_ID
          ,ORGANIZATION_ID
          ,ASSIGNMENT_SET_ID
          ,CONVERSION_TYPE
          ,REPORT_LEVEL
          ,EXPLOSION_LEVEL
          ,ROLLUP_OPTION_TYPE
          ,REPORT_OPTION_TYPE
          ,RANGE_TYPE
          ,REVISION_DATE
          ,INC_UNIMP_ECN_FLAG
          ,ENG_BILL_FLAG
          ,QTY_PRECISION
          ,ITEM_ID
          ,CATEGORY_SET_ID
          ,CATEGORY_ID
          ,ALT_BOM_DESG
          ,ALT_RTG_DESG
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_LOGIN
          ,CREATION_DATE
          ,CREATED_BY
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE)
        VALUES   (P_ROLLUP_ID
          ,LP_DESCRIPTION
          ,P_COST_TYPE_ID
          ,LP_BUY_COST_TYPE_ID
          ,P_ORGANIZATION_ID
          ,LP_ASSIGNMENT_SET_ID
          ,P_CONVERSION_TYPE
          ,LP_REPORT_LEVEL
          ,LP_EXPLOSION_LEVEL
          ,P_ROLLUP_OPTION_TYPE
          ,P_REPORT_OPTION_TYPE
          ,LP_RANGE_TYPE
          ,TO_DATE(LP_REVISION_DATE
                 ,'YYYY/MM/DD HH24:MI:SS')
          ,P_INC_UNIMP_ECN_FLAG
          ,P_ENG_BILL_FLAG
          ,P_QTY_PRECISION
          ,P_ITEM_ID
          ,LP_CATEGORY_SET_ID
          ,TO_NUMBER(P_CATEGORY_ID)
          ,P_ALT_BOM_DESG
          ,P_ALT_RTG_DESG
          ,SYSDATE
          ,L_USER_ID
          ,L_LOGIN_ID
          ,SYSDATE
          ,L_USER_ID
          ,L_REQUEST_ID
          ,L_PROG_APPL_ID
          ,L_PROG_ID
          ,SYSDATE);
      END IF;
    END IF;
    IF (P_REPORT_OPTION_TYPE = -1 AND P_ITEM_FROM IS NULL AND P_ITEM_TO IS NULL AND (P_CATEGORY_FROM IS NOT NULL OR P_CATEGORY_TO IS NOT NULL)) THEN
      LP_RANGE_TYPE := 5;
    END IF;
    L_STMT_NUM := 62;
    SELECT
      DEFAULT_COST_TYPE_ID,
      ORGANIZATION_ID
    INTO P_DEFAULT_COST_TYPE_ID,L_ORGANIZATION_ID
    FROM
      CST_COST_TYPES
    WHERE COST_TYPE_ID = P_COST_TYPE_ID;
    IF (LP_ASSIGNMENT_SET_ID IS NOT NULL AND L_ORGANIZATION_ID IS NOT NULL) THEN
      /*SRW.MESSAGE(0
                 ,FND_MESSAGE.GET_STRING('BOM'
                                       ,'CST_SC_ASSIGN_SET_COST_TYPE'))*/NULL;
      CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR'
                                                         ,FND_MESSAGE.GET_STRING('BOM'
                                                                               ,'CST_SC_ASSIGN_SET_COST_TYPE'));
      RETURN FALSE;
    END IF;
    L_STMT_NUM := 63;
    IF LP_BUY_COST_TYPE_ID IS NULL THEN
      SELECT
        PRIMARY_COST_METHOD
      INTO LP_BUY_COST_TYPE_ID
      FROM
        MTL_PARAMETERS
      WHERE ORGANIZATION_ID = NVL(P_ORGANIZATION_ID
         ,P_DEFAULT_ORG_ID);
    END IF;
    L_STMT_NUM := 70;
    IF P_REPORT_OPTION_TYPE = 2 THEN
      /*SRW.SET_MAXROW('Q_ASSEMBLY'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_COMPONENTS'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_COSTS'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_SR_RCV'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_SR_SRC'
                    ,0)*/NULL;
      /*SRW.SET_MAXROW('Q_SUMMARY'
                    ,0)*/NULL;
      LP_REPORT_LEVEL := NULL;
    END IF;
    L_STMT_NUM := 80;
    IF LP_CATEGORY_SET_ID IS NULL THEN
      SELECT
        CATEGORY_SET_ID
      INTO LP_CATEGORY_SET_ID
      FROM
        MTL_DEFAULT_CATEGORY_SETS MDCS
      WHERE MDCS.FUNCTIONAL_AREA_ID = 5;
    END IF;
    L_STMT_NUM := 90;
    IF LP_REVISION_DATE IS NULL THEN
      SELECT
        TO_CHAR(SYSDATE
               ,'YYYY/MM/DD HH24:MI:ss')
      INTO LP_REVISION_DATE
      FROM
        DUAL;
    END IF;
    L_STMT_NUM := 100;
    SELECT
      CCT1.COST_TYPE,
      DECODE(LP_ASSIGNMENT_SET_ID
            ,NULL
            ,' '
            ,CCT2.COST_TYPE),
      GDCT.USER_CONVERSION_TYPE
    INTO P_COST_TYPE_NAME,P_BUY_COST_TYPE_NAME,P_CONVERSION_TYPE_NAME
    FROM
      CST_COST_TYPES CCT1,
      CST_COST_TYPES CCT2,
      GL_DAILY_CONVERSION_TYPES GDCT
    WHERE CCT1.COST_TYPE_ID = P_COST_TYPE_ID
      AND CCT2.COST_TYPE_ID = LP_BUY_COST_TYPE_ID
      AND GDCT.CONVERSION_TYPE = P_CONVERSION_TYPE;
    L_STMT_NUM := 110;
    IF LP_ASSIGNMENT_SET_ID IS NOT NULL THEN
      SELECT
        MAS.ASSIGNMENT_SET_NAME
      INTO P_ASSIGNMENT_SET_NAME
      FROM
        MRP_ASSIGNMENT_SETS MAS
      WHERE MAS.ASSIGNMENT_SET_ID = LP_ASSIGNMENT_SET_ID;
    END IF;
    L_STMT_NUM := 120;
    IF TO_NUMBER(P_CATEGORY_ID) IS NOT NULL THEN
      SELECT
        SUBSTRB(MCV.CONCATENATED_SEGMENTS
               ,1
               ,2000)
      INTO P_CATEGORY_NAME
      FROM
        MTL_CATEGORIES_KFV MCV
      WHERE CATEGORY_ID = TO_NUMBER(P_CATEGORY_ID);
      P_CATEGORY_FROM := P_CATEGORY_NAME;
      P_CATEGORY_TO := P_CATEGORY_NAME;
    END IF;
    IF P_ITEM_ID IS NOT NULL THEN
      L_STMT_NUM := 130;
      SELECT
        SUBSTRB(CONCATENATED_SEGMENTS
               ,1
               ,2000)
      INTO P_ITEM_NAME
      FROM
        MTL_SYSTEM_ITEMS_KFV MSIV
      WHERE MSIV.INVENTORY_ITEM_ID = P_ITEM_ID
        AND MSIV.ORGANIZATION_ID = NVL(P_ORGANIZATION_ID
         ,P_DEFAULT_ORG_ID);
    END IF;
    L_STMT_NUM := 140;
    IF LP_REPORT_LEVEL IS NOT NULL THEN
      LP_REPORT_LEVEL := LP_REPORT_LEVEL + 1;
    END IF;
    IF NVL(P_ROLLUP_OPTION_TYPE
       ,2) = 2 THEN
      LP_EXPLOSION_LEVEL := NULL;
    ELSIF LP_REPORT_LEVEL IS NOT NULL AND LP_REPORT_LEVEL > LP_EXPLOSION_LEVEL + 1 THEN
      LP_REPORT_LEVEL := LP_EXPLOSION_LEVEL + 1;
    END IF;
    L_STMT_NUM := 150;
    IF L_RERUN_FLAG = 1 THEN
      L_STMT_NUM := 160;
      CSTPSCEX.SNAPSHOT_SC_BOM_STRUCTURES(P_ROLLUP_ID
                                         ,P_COST_TYPE_ID
                                         ,LP_REPORT_LEVEL
                                         ,TO_DATE(LP_REVISION_DATE
                                                ,'YYYY/MM/DD HH24:MI:SS')
                                         ,L_USER_ID
                                         ,L_LOGIN_ID
                                         ,L_REQUEST_ID
                                         ,L_PROG_ID
                                         ,L_PROG_APPL_ID
                                         ,O_ERROR_CODE
                                         ,O_ERROR_MSG
                                         ,P_REPORT_TYPE_TYPE);
    ELSE
      /*SRW.MESSAGE(0
                 ,'rollup_id = ' || P_ROLLUP_ID)*/NULL;
      L_STMT_NUM := 170;
      IF (LP_RANGE_TYPE = 2 AND P_ITEM_ID IS NOT NULL) THEN
        L_STMT_NUM := 110;
        INSERT INTO CST_SC_LISTS
          (ROLLUP_ID
          ,INVENTORY_ITEM_ID
          ,ORGANIZATION_ID
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE)
          SELECT
            DISTINCT
            P_ROLLUP_ID,
            MSI.INVENTORY_ITEM_ID,
            MSI.ORGANIZATION_ID,
            sysdate,
            L_USER_ID,
            sysdate,
            L_USER_ID,
            L_LOGIN_ID,
            L_REQUEST_ID,
            L_PROG_APPL_ID,
            L_PROG_ID,
            sysdate
          FROM
            MTL_SYSTEM_ITEMS MSI,
            BOM_PARAMETERS BP,
            CST_ITEM_COSTS CIC,
            MTL_PARAMETERS MP
          WHERE MSI.ORGANIZATION_ID = NVL(P_ORGANIZATION_ID
             ,MSI.ORGANIZATION_ID)
            AND MSI.INVENTORY_ITEM_ID = P_ITEM_ID
            AND MSI.COSTING_ENABLED_FLAG = 'Y'
            AND MP.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            AND CIC.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            AND CIC.INVENTORY_ITEM_ID = P_ITEM_ID
            AND ( CIC.COST_TYPE_ID = P_COST_TYPE_ID
          OR ( CIC.COST_TYPE_ID = P_DEFAULT_COST_TYPE_ID
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC2
            WHERE CIC2.ORGANIZATION_ID = CIC.ORGANIZATION_ID
              AND CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC2.COST_TYPE_ID = P_COST_TYPE_ID ) )
          OR ( CIC.COST_TYPE_ID = MP.PRIMARY_COST_METHOD
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC3
            WHERE CIC3.ORGANIZATION_ID = CIC.ORGANIZATION_ID
              AND CIC3.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC3.COST_TYPE_ID IN ( P_COST_TYPE_ID , P_DEFAULT_COST_TYPE_ID ) ) ) )
            AND CIC.BASED_ON_ROLLUP_FLAG = 1
            AND BP.organization_id (+) = MSI.ORGANIZATION_ID
            AND nvl(MSI.INVENTORY_ITEM_STATUS_CODE,
              'NOT_' || BP.bom_delete_status_code (+)) <> BP.bom_delete_status_code (+);
      ELSIF (LP_RANGE_TYPE = 5) THEN
        L_STMT_NUM := 180;
        INSERT INTO CST_SC_LISTS
          (ROLLUP_ID
          ,INVENTORY_ITEM_ID
          ,ORGANIZATION_ID
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE)
          SELECT
            P_ROLLUP_ID,
            MIC.INVENTORY_ITEM_ID,
            MIC.ORGANIZATION_ID,
            sysdate,
            L_USER_ID,
            sysdate,
            L_USER_ID,
            L_LOGIN_ID,
            L_REQUEST_ID,
            L_PROG_APPL_ID,
            L_PROG_ID,
            sysdate
          FROM
            MTL_ITEM_CATEGORIES MIC,
            MTL_SYSTEM_ITEMS MSI,
            BOM_PARAMETERS BP,
            MTL_CATEGORIES_KFV MCV,
            CST_ITEM_COSTS CIC,
            MTL_PARAMETERS MP
          WHERE P_ORGANIZATION_ID is not null
            AND MIC.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND MIC.CATEGORY_SET_ID = LP_CATEGORY_SET_ID
            AND MIC.CATEGORY_ID = MCV.CATEGORY_ID
            AND MCV.CONCATENATED_SEGMENTS >= DECODE(P_CATEGORY_FROM
                ,NULL
                ,MCV.CONCATENATED_SEGMENTS
                ,P_CATEGORY_FROM)
            AND MCV.CONCATENATED_SEGMENTS <= DECODE(P_CATEGORY_TO
                ,NULL
                ,MCV.CONCATENATED_SEGMENTS
                ,P_CATEGORY_TO)
            AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
            AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
            AND MSI.COSTING_ENABLED_FLAG = 'Y'
            AND MP.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND CIC.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND CIC.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
            AND ( CIC.COST_TYPE_ID = P_COST_TYPE_ID
          OR ( CIC.COST_TYPE_ID = P_DEFAULT_COST_TYPE_ID
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC2
            WHERE CIC2.ORGANIZATION_ID = P_ORGANIZATION_ID
              AND CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC2.COST_TYPE_ID = P_COST_TYPE_ID ) )
          OR ( CIC.COST_TYPE_ID = MP.PRIMARY_COST_METHOD
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC3
            WHERE CIC3.ORGANIZATION_ID = P_ORGANIZATION_ID
              AND CIC3.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC3.COST_TYPE_ID IN ( P_COST_TYPE_ID , P_DEFAULT_COST_TYPE_ID ) ) ) )
            AND CIC.BASED_ON_ROLLUP_FLAG = 1
            AND BP.organization_id (+) = MSI.ORGANIZATION_ID
            AND nvl(MSI.INVENTORY_ITEM_STATUS_CODE,
              'NOT_' || BP.bom_delete_status_code (+)) <> BP.bom_delete_status_code (+)
          UNION
          SELECT
            P_ROLLUP_ID,
            MIC.INVENTORY_ITEM_ID,
            MIC.ORGANIZATION_ID,
            sysdate,
            L_USER_ID,
            sysdate,
            L_USER_ID,
            L_LOGIN_ID,
            L_REQUEST_ID,
            L_PROG_APPL_ID,
            L_PROG_ID,
            sysdate
          FROM
            MTL_ITEM_CATEGORIES MIC,
            MTL_SYSTEM_ITEMS MSI,
            BOM_PARAMETERS BP,
            MTL_CATEGORIES_KFV MCV,
            CST_ITEM_COSTS CIC,
            MTL_PARAMETERS MP
          WHERE P_ORGANIZATION_ID is null
            AND MIC.CATEGORY_SET_ID = LP_CATEGORY_SET_ID
            AND MIC.CATEGORY_ID = MCV.CATEGORY_ID
            AND MCV.CONCATENATED_SEGMENTS >= DECODE(P_CATEGORY_FROM
                ,NULL
                ,MCV.CONCATENATED_SEGMENTS
                ,P_CATEGORY_FROM)
            AND MCV.CONCATENATED_SEGMENTS <= DECODE(P_CATEGORY_TO
                ,NULL
                ,MCV.CONCATENATED_SEGMENTS
                ,P_CATEGORY_TO)
            AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
            AND MSI.ORGANIZATION_ID = MIC.ORGANIZATION_ID
            AND MSI.COSTING_ENABLED_FLAG = 'Y'
            AND MP.ORGANIZATION_ID = MIC.ORGANIZATION_ID
            AND CIC.ORGANIZATION_ID = MIC.ORGANIZATION_ID
            AND CIC.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
            AND ( CIC.COST_TYPE_ID = P_COST_TYPE_ID
          OR ( CIC.COST_TYPE_ID = P_DEFAULT_COST_TYPE_ID
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC2
            WHERE CIC2.ORGANIZATION_ID = CIC.ORGANIZATION_ID
              AND CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC2.COST_TYPE_ID = P_COST_TYPE_ID ) )
          OR ( CIC.COST_TYPE_ID = MP.PRIMARY_COST_METHOD
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC3
            WHERE CIC3.ORGANIZATION_ID = CIC.ORGANIZATION_ID
              AND CIC3.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC3.COST_TYPE_ID IN ( P_COST_TYPE_ID , P_DEFAULT_COST_TYPE_ID ) ) ) )
            AND CIC.BASED_ON_ROLLUP_FLAG = 1
            AND BP.organization_id (+) = MSI.ORGANIZATION_ID
            AND nvl(MSI.INVENTORY_ITEM_STATUS_CODE,
              'NOT_' || BP.bom_delete_status_code (+)) <> BP.bom_delete_status_code (+);
      ELSE
        L_STMT_NUM := 190;
        INSERT INTO CST_SC_LISTS
          (ROLLUP_ID
          ,INVENTORY_ITEM_ID
          ,ORGANIZATION_ID
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_LOGIN
          ,REQUEST_ID
          ,PROGRAM_APPLICATION_ID
          ,PROGRAM_ID
          ,PROGRAM_UPDATE_DATE)
          SELECT
            P_ROLLUP_ID,
            MSI.INVENTORY_ITEM_ID,
            MSI.ORGANIZATION_ID,
            sysdate,
            L_USER_ID,
            sysdate,
            L_USER_ID,
            L_LOGIN_ID,
            L_REQUEST_ID,
            L_PROG_APPL_ID,
            L_PROG_ID,
            sysdate
          FROM
            MTL_SYSTEM_ITEMS_KFV MSI,
            BOM_PARAMETERS BP,
            CST_ITEM_COSTS CIC,
            MTL_PARAMETERS MP
          WHERE P_ORGANIZATION_ID is not null
            AND MSI.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND MSI.CONCATENATED_SEGMENTS >= DECODE(P_ITEM_FROM
                ,NULL
                ,MSI.CONCATENATED_SEGMENTS
                ,P_ITEM_FROM)
            AND MSI.CONCATENATED_SEGMENTS <= DECODE(P_ITEM_TO
                ,NULL
                ,MSI.CONCATENATED_SEGMENTS
                ,P_ITEM_TO)
            AND MSI.COSTING_ENABLED_FLAG = 'Y'
            AND MP.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND CIC.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
            AND CIC.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            AND ( CIC.COST_TYPE_ID = P_COST_TYPE_ID
          OR ( CIC.COST_TYPE_ID = P_DEFAULT_COST_TYPE_ID
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC2
            WHERE CIC2.ORGANIZATION_ID = CIC.ORGANIZATION_ID
              AND CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC2.COST_TYPE_ID = P_COST_TYPE_ID ) )
          OR ( CIC.COST_TYPE_ID = MP.PRIMARY_COST_METHOD
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC3
            WHERE CIC3.ORGANIZATION_ID = CIC.ORGANIZATION_ID
              AND CIC3.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC3.COST_TYPE_ID IN ( P_COST_TYPE_ID , P_DEFAULT_COST_TYPE_ID ) ) ) )
            AND CIC.BASED_ON_ROLLUP_FLAG = 1
            AND NVL(CIC.ITEM_COST
             ,0) = DECODE(LP_RANGE_TYPE
                ,4
                ,0
                ,NVL(CIC.ITEM_COST
                   ,0))
            AND BP.organization_id (+) = MSI.ORGANIZATION_ID
            AND nvl(MSI.INVENTORY_ITEM_STATUS_CODE,
              'NOT_' || BP.bom_delete_status_code (+)) <> BP.bom_delete_status_code (+)
          UNION
          SELECT
            P_ROLLUP_ID,
            MSI.INVENTORY_ITEM_ID,
            MSI.ORGANIZATION_ID,
            sysdate,
            L_USER_ID,
            sysdate,
            L_USER_ID,
            L_LOGIN_ID,
            L_REQUEST_ID,
            L_PROG_APPL_ID,
            L_PROG_ID,
            sysdate
          FROM
            MTL_SYSTEM_ITEMS_KFV MSI,
            BOM_PARAMETERS BP,
            CST_ITEM_COSTS CIC,
            MTL_PARAMETERS MP
          WHERE P_ORGANIZATION_ID is null
            AND MSI.CONCATENATED_SEGMENTS >= DECODE(P_ITEM_FROM
                ,NULL
                ,MSI.CONCATENATED_SEGMENTS
                ,P_ITEM_FROM)
            AND MSI.CONCATENATED_SEGMENTS <= DECODE(P_ITEM_TO
                ,NULL
                ,MSI.CONCATENATED_SEGMENTS
                ,P_ITEM_TO)
            AND MSI.COSTING_ENABLED_FLAG = 'Y'
            AND MP.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            AND CIC.INVENTORY_ITEM_ID = MSI.INVENTORY_ITEM_ID
            AND CIC.ORGANIZATION_ID = MSI.ORGANIZATION_ID
            AND ( CIC.COST_TYPE_ID = P_COST_TYPE_ID
          OR ( CIC.COST_TYPE_ID = P_DEFAULT_COST_TYPE_ID
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC2
            WHERE CIC2.ORGANIZATION_ID = CIC.ORGANIZATION_ID
              AND CIC2.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC2.COST_TYPE_ID = P_COST_TYPE_ID ) )
          OR ( CIC.COST_TYPE_ID = MP.PRIMARY_COST_METHOD
            AND not exists (
            SELECT
              'X'
            FROM
              CST_ITEM_COSTS CIC3
            WHERE CIC3.ORGANIZATION_ID = CIC.ORGANIZATION_ID
              AND CIC3.INVENTORY_ITEM_ID = CIC.INVENTORY_ITEM_ID
              AND CIC3.COST_TYPE_ID IN ( P_COST_TYPE_ID , P_DEFAULT_COST_TYPE_ID ) ) ) )
            AND CIC.BASED_ON_ROLLUP_FLAG = 1
            AND NVL(CIC.ITEM_COST
             ,0) = DECODE(LP_RANGE_TYPE
                ,4
                ,0
                ,NVL(CIC.ITEM_COST
                   ,0))
            AND BP.organization_id (+) = MSI.ORGANIZATION_ID
            AND nvl(MSI.INVENTORY_ITEM_STATUS_CODE,
              'NOT_' || BP.bom_delete_status_code (+)) <> BP.bom_delete_status_code (+);
      END IF;
      L_STMT_NUM := 200;
      IF NVL(P_INC_UNIMP_ECN_FLAG
         ,2) = 1 THEN
        L_EXCLUDE_UNIMP_ECO := 2;
      ELSE
        L_EXCLUDE_UNIMP_ECO := 1;
      END IF;
      L_STMT_NUM := 210;
      IF NVL(P_ENG_BILL_FLAG
         ,2) = 1 THEN
        L_EXCLUDE_ENG := 2;
      ELSE
        L_EXCLUDE_ENG := 1;
      END IF;
      L_STMT_NUM := 210;
      IF (P_LOT_SIZE_OPTION IS NOT NULL) THEN
        SELECT
          MEANING
        INTO P_LOT_SIZE_OPTION_NAME
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_TYPE = 'CST_SC_LOT_OPTION'
          AND LOOKUP_CODE = P_LOT_SIZE_OPTION;
      END IF;
      L_STMT_NUM := 220;
      SELECT
        sysdate
      INTO L_TIMESTAMP
      FROM
        DUAL;
      /*SRW.MESSAGE(0
                 ,'Before CSTPSCEX.supply_chain_rollup ' || TO_CHAR(L_TIMESTAMP
                        ,'YYYY/MM/DD HH24:MI:SS'))*/NULL;
      L_STMT_NUM := 230;
      CSTPSCEX.SUPPLY_CHAIN_ROLLUP(P_ROLLUP_ID
                                  ,LP_EXPLOSION_LEVEL
                                  ,LP_REPORT_LEVEL
                                  ,LP_ASSIGNMENT_SET_ID
                                  ,P_CONVERSION_TYPE
                                  ,P_COST_TYPE_ID
                                  ,LP_BUY_COST_TYPE_ID
                                  ,TO_DATE(LP_REVISION_DATE
                                         ,'YYYY/MM/DD HH24:MI:SS')
                                  ,L_EXCLUDE_UNIMP_ECO
                                  ,L_EXCLUDE_ENG
                                  ,P_ALT_BOM_DESG
                                  ,P_ALT_RTG_DESG
                                  ,P_LOCK_FLAG
                                  ,L_USER_ID
                                  ,L_LOGIN_ID
                                  ,L_REQUEST_ID
                                  ,L_PROG_ID
                                  ,L_PROG_APPL_ID
                                  ,O_ERROR_CODE
                                  ,O_ERROR_MSG
                                  ,P_LOT_SIZE_OPTION
                                  ,P_LOT_SIZE_SETTING
                                  ,P_REPORT_OPTION_TYPE
                                  ,P_REPORT_TYPE_TYPE
                                  ,P_BUY_COST_DETAIL);
      L_STMT_NUM := 240;
      SELECT
        sysdate
      INTO L_TIMESTAMP
      FROM
        DUAL;
      /*SRW.MESSAGE(0
                 ,'After CSTPSCEX.supply_chain_rollup ' || TO_CHAR(L_TIMESTAMP
                        ,'YYYY/MM/DD HH24:MI:SS'))*/NULL;
      L_STMT_NUM := 250;
      SELECT
        count(*)
      INTO L_ROWS_UNEXPLODED
      FROM
        CST_SC_BOM_EXPLOSION CSBE
      WHERE CSBE.ROLLUP_ID = P_ROLLUP_ID
        AND CSBE.DELETED_FLAG <> 'Y';
      L_STMT_NUM := 260;
      IF L_ROWS_UNEXPLODED = 0 THEN
        /*SRW.MESSAGE(0
                   ,'No loop found')*/NULL;
      ELSE
        /*SRW.MESSAGE(0
                   ,'Loop found: ' || L_ROWS_UNEXPLODED || ' rows unexploded')*/NULL;
        FOR cur IN LOOP_ROWS(p_rollup_id) LOOP
          /*SRW.MESSAGE(0
                     ,'Assmbly Item ' || CUR.ASSEMBLY_ITEM_ID || ' Org ' || CUR.ASSEMBLY_ORGANIZATION_ID || ' Component Item ' || CUR.COMPONENT_ITEM_ID || ' Org ' || CUR.COMPONENT_ORGANIZATION_ID)*/NULL;
        END LOOP;
      END IF;
    END IF;
    L_STMT_NUM := 270;
    SELECT
      count(SOB.CURRENCY_CODE)
    INTO P_NUM_CURRENCIES
    FROM
      CST_SC_LOW_LEVEL_CODES CSLLC,
      HR_ORGANIZATION_INFORMATION HOI,
      GL_LEDGERS SOB
    WHERE CSLLC.ROLLUP_ID = P_ROLLUP_ID
      AND HOI.ORGANIZATION_ID = CSLLC.ORGANIZATION_ID
      AND HOI.ORG_INFORMATION_CONTEXT = 'Acounting Information'
      AND SOB.LEDGER_ID = HOI.ORG_INFORMATION1;
    L_STMT_NUM := 272;
    SELECT
      ALTERNATE_BOM_DESIGNATOR
    INTO L_SNAPSHOT_DESIGNATOR
    FROM
      CST_COST_TYPES
    WHERE COST_TYPE_ID = P_COST_TYPE_ID;
    IF L_SNAPSHOT_DESIGNATOR IS NOT NULL THEN
      FOR orgs IN NO_ALT_ORGS(l_snapshot_designator) LOOP
        SELECT
          ORGANIZATION_CODE
        INTO L_NO_ALT_ORG
        FROM
          MTL_PARAMETERS
        WHERE ORGANIZATION_ID = ORGS.ORGANIZATION_ID;
        /*SRW.MESSAGE(0
                   ,'Alternate ' || L_SNAPSHOT_DESIGNATOR || ' is not defined in organziation ' || L_NO_ALT_ORG)*/NULL;
      END LOOP;
    END IF;
    L_STMT_NUM := 275;
    FOR orgs IN NO_BOM_ORGS LOOP
      SELECT
        ORGANIZATION_CODE
      INTO L_NO_BOM_ORG
      FROM
        MTL_PARAMETERS
      WHERE ORGANIZATION_ID = ORGS.ORGANIZATION_ID;
      /*SRW.MESSAGE(0
                 ,'Org: ' || L_NO_BOM_ORG || '. ')*/NULL;
    END LOOP;
    IF O_ERROR_CODE = 8888 THEN
      /*SRW.MESSAGE(0
                 ,'Alternate Designaor can not be NULL for the specified Cost Type  ')*/NULL;
    END IF;
    L_STMT_NUM := 280;
    IF O_ERROR_CODE <> 0 THEN
      L_STR_POS := 0;
      WHILE L_STR_POS < LENGTHB(O_ERROR_MSG) LOOP

        /*SRW.MESSAGE(0
                   ,SUBSTRB(O_ERROR_MSG
                          ,L_STR_POS + 1
                          ,L_STR_POS + 180))*/NULL;
        L_STR_POS := L_STR_POS + 180;
      END LOOP;
      ROLLBACK;
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('2001'
                 ,L_STMT_NUM || ' ' || SUBSTRB(SQLERRM
                        ,1
                        ,180))*/NULL;
      ROLLBACK;
      RETURN (FALSE);
  END BEFOREREPORT;

  FUNCTION CF_S_DIFFERENCEFORMULA(S_FROZEN_VALUE IN NUMBER
                                 ,S_REPORT_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (S_FROZEN_VALUE - S_REPORT_VALUE);
  END CF_S_DIFFERENCEFORMULA;

  FUNCTION CF_S_PERCENTFORMULA(S_FROZEN_VALUE IN NUMBER
                              ,S_REPORT_VALUE IN NUMBER
                              ,CF_S_DIFFERENCE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (S_FROZEN_VALUE = 0 OR S_REPORT_VALUE = 0) THEN
      RETURN (0);
    ELSE
      IF CF_S_DIFFERENCE > 0.0 THEN
        RETURN (ROUND(100 * CF_S_DIFFERENCE / S_REPORT_VALUE
                    ,1));
      ELSE
        RETURN (ROUND(100 * CF_S_DIFFERENCE / S_FROZEN_VALUE
                    ,1));
      END IF;
    END IF;
  END CF_S_PERCENTFORMULA;

  FUNCTION CF_S_S_SRC_TOTALFORMULA(S_S_PERCENT IN NUMBER
                                  ,S_S_EFFECTIVE_ITEM_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(S_S_PERCENT
       ,0) = 0 THEN
      RETURN 0;
    END IF;
    RETURN NVL(S_S_EFFECTIVE_ITEM_COST
              ,0) / (S_S_PERCENT / 100);
  END CF_S_S_SRC_TOTALFORMULA;

  FUNCTION CF_S_R_USER_DEFINED_COSTFORMUL(S_R_ITEM_COST IN NUMBER
                                         ,CS_SUM_EFFECTIVE_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN NVL(S_R_ITEM_COST
              ,0) - NVL(CS_SUM_EFFECTIVE_COST
              ,0);
  END CF_S_R_USER_DEFINED_COSTFORMUL;

  FUNCTION CF_S_S_PERCENT_COSTFORMULA(S_R_ITEM_COST IN NUMBER
                                     ,S_S_EFFECTIVE_ITEM_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF S_R_ITEM_COST = 0 THEN
      RETURN 0;
    END IF;
    RETURN S_S_EFFECTIVE_ITEM_COST / S_R_ITEM_COST * 100;
  END CF_S_S_PERCENT_COSTFORMULA;

  FUNCTION CF_S_R_USER_DEFINED_PERCENTFOR(S_R_ITEM_COST IN NUMBER
                                         ,CF_S_R_USER_DEFINED_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF S_R_ITEM_COST = 0 THEN
      RETURN 0;
    END IF;
    RETURN CF_S_R_USER_DEFINED_COST / S_R_ITEM_COST * 100;
  END CF_S_R_USER_DEFINED_PERCENTFOR;

  FUNCTION CF_SUM_EXT_COSTFORMULA0009(CS_SUM_COMP_EXT_COST IN NUMBER
                                     ,CS_SUM_RES_EXT_COST IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN NVL(CS_SUM_COMP_EXT_COST
              ,0) + NVL(CS_SUM_RES_EXT_COST
              ,0);
  END CF_SUM_EXT_COSTFORMULA0009;

  FUNCTION CF_S_SUM_PERCENTFORMULA0011(CS_S_SUM_DIFFERENCE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF CS_S_SUM_DIFFERENCE = 0 THEN
      RETURN 0;
    END IF;
    RETURN 100;
  END CF_S_SUM_PERCENTFORMULA0011;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
    L_DEFAULT_MATL_OVHD NUMBER(15);
    L_ORGANIZATION_CODE VARCHAR2(3);
    CONC_STATUS BOOLEAN;
    RETURN_STATUS NUMBER := 1;
    CURSOR NO_DEF_OVHD_ORGS IS
      SELECT
        DISTINCT
        ORGANIZATION_ID
      FROM
        CST_SC_LOW_LEVEL_CODES
      WHERE ROLLUP_ID = P_ROLLUP_ID;
  BEGIN
    FOR organizations IN NO_DEF_OVHD_ORGS LOOP
      SELECT
        NVL(DEFAULT_MATL_OVHD_COST_ID
           ,0),
        ORGANIZATION_CODE
      INTO L_DEFAULT_MATL_OVHD,L_ORGANIZATION_CODE
      FROM
        MTL_PARAMETERS
      WHERE ORGANIZATION_ID = ORGANIZATIONS.ORGANIZATION_ID;
      IF (L_DEFAULT_MATL_OVHD = 0) THEN
        FND_MESSAGE.SET_NAME('BOM'
                            ,'CST_SC_DEF_MATL_OVHD_SUBELEM');
        FND_MESSAGE.SET_TOKEN('ORGANIZATION_CODE'
                             ,L_ORGANIZATION_CODE);
        /*SRW.MESSAGE(0
                   ,FND_MESSAGE.GET)*/NULL;
      END IF;
    END LOOP;
    IF (P_REPORT_OPTION_TYPE <> 3) THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

END BOM_CSTRSCCR_XMLP_PKG;



/
