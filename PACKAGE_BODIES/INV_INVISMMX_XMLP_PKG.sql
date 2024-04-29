--------------------------------------------------------
--  DDL for Package Body INV_INVISMMX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVISMMX_XMLP_PKG" AS
/* $Header: INVISMMXB.pls 120.2 2008/01/08 06:28:23 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    LINE_NUM NUMBER := 0;
    V_DUMMY VARCHAR2(20);
    L_RETURN_STATUS VARCHAR2(1);
    L_MSG_COUNT NUMBER;
    L_MSG_DATA VARCHAR2(2000);
    L_MSG VARCHAR2(2000);
    L_SUBINV_TBL INV_MMX_WRAPPER_PVT.SUBINVTABLETYPE;
  BEGIN
    LINE_NUM := 10;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    LINE_NUM := 20;
    DECLARE
      ERROR_MESSAGE VARCHAR2(80) := NULL;
    BEGIN
      LINE_NUM := 30;
      IF P_SUBINV IS NOT NULL THEN
        L_SUBINV_TBL(1) := P_SUBINV;
      END IF;
      IF P_LEVEL = 2 AND P_SUBINV IS NULL THEN
        BEGIN
          SELECT
            MEANING
          INTO ERROR_MESSAGE
          FROM
            MFG_LOOKUPS
          WHERE LOOKUP_TYPE = 'INV_MMX_RPT_MSGS'
            AND LOOKUP_CODE = 3;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        /*SRW.MESSAGE(1
                   ,ERROR_MESSAGE)*/NULL;
      END IF;
      LINE_NUM := 40;
      IF P_LEVEL = 2 THEN
        P_INCLUDE_NONNET := 1;
      END IF;
      LINE_NUM := 50;
    END;
    LINE_NUM := 60;
    LINE_NUM := 70;
    LINE_NUM := 80;
    SELECT
      EMPLOYEE_ID
    INTO P_EMPLOYEE_ID
    FROM
      FND_USER
    WHERE USER_ID = P_USER_ID;
    LINE_NUM := 90;
    SELECT
      sysdate
    INTO P_SYSDATE
    FROM
      SYS.DUAL;
    LINE_NUM := 110;
    P_DATE_TIME := TO_CHAR(P_SYSDATE
                          ,'DD-MON-YYYY HH24:MI');
    P_D_CUTOFF_1 := NVL(P_D_CUTOFF
                     ,P_SYSDATE);
    P_S_CUTOFF_1 := NVL(P_S_CUTOFF
                     ,P_SYSDATE);
    IF (P_D_CUTOFF_REL IS NOT NULL) THEN
      P_D_CUTOFF_REL_1 := NVL(P_D_CUTOFF_REL
                           ,0);
      P_D_CUTOFF_1 := NVL(P_D_CUTOFF_1
                       ,P_SYSDATE) + P_D_CUTOFF_REL_1;
    END IF;
    LINE_NUM := 120;
    IF (P_S_CUTOFF_REL IS NOT NULL) THEN
      P_S_CUTOFF_REL_1 := NVL(P_S_CUTOFF_REL
                           ,0);
      P_S_CUTOFF_1 := NVL(P_S_CUTOFF_1
                       ,P_SYSDATE) + P_S_CUTOFF_REL_1;
    END IF;
    LINE_NUM := 130;
    BEGIN
      SELECT
        SUBSTR(NAME
              ,1
              ,30)
      INTO P_ORG_NAME
      FROM
        HR_ALL_ORGANIZATION_UNITS_TL
      WHERE ORGANIZATION_ID = P_ORG_ID
        AND LANGUAGE = USERENV('LANG');
    END;
    LINE_NUM := 140;
    LINE_NUM := 150;
    IF P_CAT_SET_ID IS NOT NULL THEN
      SELECT
        STRUCTURE_ID
      INTO P_MCAT_STRUCT
      FROM
        MTL_CATEGORY_SETS
      WHERE CATEGORY_SET_ID = P_CAT_SET_ID;
    ELSE
      SELECT
        CSET.CATEGORY_SET_ID,
        CSET.STRUCTURE_ID
      INTO P_CAT_SET_ID,P_MCAT_STRUCT
      FROM
        MTL_CATEGORY_SETS CSET,
        MTL_DEFAULT_CATEGORY_SETS DEF
      WHERE DEF.CATEGORY_SET_ID = CSET.CATEGORY_SET_ID
        AND DEF.FUNCTIONAL_AREA_ID = 1;
    END IF;
    LINE_NUM := 160;
    SELECT
      ID_FLEX_NUM
    INTO P_MSTK_STRUCT
    FROM
      FND_ID_FLEX_STRUCTURES
    WHERE ID_FLEX_CODE = 'MSTK';
    SELECT
      MEANING
    INTO P_SORTER
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'MTL_MINMAX_RPT_SORT_BY'
      AND LOOKUP_CODE = DECODE(P_SORT
          ,1
          ,2
          ,P_SORT);
    LINE_NUM := 170;
    DECLARE
      V_P_RANGE_SQL VARCHAR2(1000);
    BEGIN
      IF P_ITEM_LO IS NOT NULL AND P_ITEM_HI IS NOT NULL THEN
        NULL;
      ELSIF P_ITEM_LO IS NOT NULL THEN
        NULL;
      ELSIF P_ITEM_HI IS NOT NULL THEN
        NULL;
      END IF;
      LINE_NUM := 180;
      IF P_RANGE_SQL IS NOT NULL THEN
        V_P_RANGE_SQL := P_RANGE_SQL;
        P_RANGE_SQL := NULL;
      END IF;
      IF P_CATG_LO IS NOT NULL AND P_CATG_HI IS NOT NULL THEN
        NULL;
      ELSIF P_CATG_LO IS NOT NULL THEN
        NULL;
      ELSIF P_CATG_HI IS NOT NULL THEN
        NULL;
      END IF;
      LINE_NUM := 190;
      IF P_RANGE_SQL IS NOT NULL THEN
        V_P_RANGE_SQL := V_P_RANGE_SQL || ' and ' || P_RANGE_SQL;
        P_RANGE_SQL := NULL;
      END IF;
      IF P_PLANNER_LO IS NOT NULL AND P_PLANNER_HI IS NOT NULL THEN
        P_RANGE_SQL := 'c.planner_code between ' || '''' || P_PLANNER_LO || '''' || ' and ' || '''' || P_PLANNER_HI || '''';
      ELSIF P_PLANNER_LO IS NOT NULL THEN
        P_RANGE_SQL := 'c.planner_code >= ' || '''' || P_PLANNER_LO || '''';
      ELSIF P_PLANNER_HI IS NOT NULL THEN
        P_RANGE_SQL := 'c.planner_code <= ' || '''' || P_PLANNER_HI || '''';
      END IF;
      IF P_RANGE_SQL IS NOT NULL THEN
        V_P_RANGE_SQL := V_P_RANGE_SQL || ' and ' || P_RANGE_SQL;
        P_RANGE_SQL := NULL;
      END IF;
      LINE_NUM := 200;
      IF P_LOT_CTL = 1 THEN
        P_RANGE_SQL := 'c.lot_control_code = 2';
      ELSIF P_LOT_CTL = 2 THEN
        P_RANGE_SQL := 'c.lot_control_code <> 2';
      END IF;
      IF P_RANGE_SQL IS NOT NULL THEN
        V_P_RANGE_SQL := V_P_RANGE_SQL || ' and ' || P_RANGE_SQL;
        P_RANGE_SQL := NULL;
      END IF;
      P_RANGE_SQL := V_P_RANGE_SQL;
    END;
    LINE_NUM := 215;
    LINE_NUM := 220;
    SELECT
      MEANING
    INTO P_SB_TEXT
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'MTL_MINMAX_RPT_SORT_BY'
      AND LOOKUP_CODE = P_SORT;
    SELECT
      MEANING
    INTO P_SELECTION_TEXT
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'MTL_MINMAX_RPT_SEL'
      AND LOOKUP_CODE = P_SELECTION;
    SELECT
      MEANING
    INTO P_LVL_TEXT
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'MTL_MINMAX_LEVEL'
      AND LOOKUP_CODE = P_LEVEL;
    SELECT
      MEANING
    INTO P_DISPLAY_MODE_TEXT
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'INV_SRS_MMX_REPORT_FORMAT'
      AND LOOKUP_CODE = P_DISPLAY_MODE;
    LINE_NUM := 230;
    IF P_HANDLE_REP_ITEM IS NULL THEN
      P_HANDLE_REP_ITEM := 3;
    END IF;
    SELECT
      MEANING
    INTO P_REPITM_TEXT
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'MTL_MINMAX_HANDLE_REP_ITEM'
      AND LOOKUP_CODE = P_HANDLE_REP_ITEM;
    IF P_DD_LOC_ID IS NOT NULL THEN
      SELECT
        LOCATION_CODE
      INTO P_DDL_TEXT
      FROM
        HR_LOCATIONS LOC
      WHERE LOC.LOCATION_ID = P_DD_LOC_ID;
    END IF;
    LINE_NUM := 240;
    SELECT
      CATEGORY_SET_NAME
    INTO P_CSET_TEXT
    FROM
      MTL_CATEGORY_SETS
    WHERE CATEGORY_SET_ID = P_CAT_SET_ID;
    SELECT
      MEANING
    INTO P_YES_TEXT
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'SYS_YES_NO'
      AND LOOKUP_CODE = 1;
    SELECT
      MEANING
    INTO P_NO_TEXT
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'SYS_YES_NO'
      AND LOOKUP_CODE = 2;
    LINE_NUM := 250;
    SELECT
      MEANING
    INTO P_LOTCTL_TEXT
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'MIN_MAX_REPORT_LOT_CONTROL'
      AND LOOKUP_CODE = NVL(P_LOT_CTL
       ,3);
    IF P_INCLUDE_NONNET = 1 THEN
      P_NONET_TEXT := P_YES_TEXT;
    ELSIF P_INCLUDE_NONNET = 2 THEN
      P_NONET_TEXT := P_NO_TEXT;
    ELSE
      P_INCLUDE_NONNET := 1;
      P_NONET_TEXT := P_YES_TEXT;
    END IF;
    LINE_NUM := 260;
    IF P_RESTOCK = 1 THEN
      P_RSTK_TEXT := P_YES_TEXT;
    ELSE
      P_RSTK_TEXT := P_NO_TEXT;
    END IF;
    IF P_NET_UNRSV = 1 THEN
      P_NET_UR_TEXT := P_YES_TEXT;
    ELSE
      P_NET_UR_TEXT := P_NO_TEXT;
    END IF;
    IF P_NET_RSV = 1 THEN
      P_NET_R_TEXT := P_YES_TEXT;
    ELSE
      P_NET_R_TEXT := P_NO_TEXT;
    END IF;
    IF P_NET_WIP = 1 THEN
      P_NET_W_TEXT := P_YES_TEXT;
    ELSE
      P_NET_W_TEXT := P_NO_TEXT;
      IF P_NET_WIP IS NULL THEN
        P_NET_WIP := 2;
      END IF;
    END IF;
    LINE_NUM := 270;
    IF P_INCLUDE_WIP = 1 THEN
      P_INC_W_TEXT := P_YES_TEXT;
    ELSE
      P_INC_W_TEXT := P_NO_TEXT;
      IF P_INCLUDE_WIP IS NULL THEN
        P_INCLUDE_WIP := 2;
      END IF;
    END IF;
    IF P_INCLUDE_PO = 1 THEN
      P_INC_PO_TEXT := P_YES_TEXT;
    ELSE
      P_INC_PO_TEXT := P_NO_TEXT;
    END IF;
    IF P_INCLUDE_MO = 1 THEN
      P_INC_MO_TEXT := P_YES_TEXT;
    ELSE
      P_INC_MO_TEXT := P_NO_TEXT;
    END IF;
    IF P_INCLUDE_IF = 1 THEN
      P_INC_IF_TEXT := P_YES_TEXT;
    ELSE
      P_INC_IF_TEXT := P_NO_TEXT;
    END IF;
    IF P_SHOW_DESC = 1 THEN
      P_SHOW_DESC_TEXT := P_YES_TEXT;
    ELSE
      P_SHOW_DESC_TEXT := P_NO_TEXT;
    END IF;
    P_MO_LINE_GROUPING := NVL(FND_PROFILE.VALUE('INV_REPL_MO_GROUPING')
                             ,1);
    LINE_NUM := 280;
    /*SRW.MESSAGE(69
               ,'Calling INV_MMX_WRAPPER_PVT.exec_min_max from Before Report Trigger')*/NULL;
    INV_MMX_WRAPPER_PVT.EXEC_MIN_MAX(X_RETURN_STATUS => L_RETURN_STATUS
                                    ,X_MSG_COUNT => L_MSG_COUNT
                                    ,X_MSG_DATA => L_MSG_DATA
                                    ,P_ITEM_SELECT => P_ITEM_SELECT
                                    ,P_HANDLE_REP_ITEM => P_HANDLE_REP_ITEM
                                    ,P_PUR_REVISION => P_PUR_REVISION
                                    ,P_CAT_SELECT => P_CAT_SELECT
                                    ,P_CAT_SET_ID => P_CAT_SET_ID
                                    ,P_MCAT_STRUCT => P_MCAT_STRUCT
                                    ,P_LEVEL => P_LEVEL
                                    ,P_RESTOCK => P_RESTOCK
                                    ,P_INCLUDE_NONNET => P_INCLUDE_NONNET
                                    ,P_INCLUDE_PO => P_INCLUDE_PO
                                    ,P_INCLUDE_MO => P_INCLUDE_MO
                                    ,P_INCLUDE_WIP => P_INCLUDE_WIP
                                    ,P_INCLUDE_IF => P_INCLUDE_IF
                                    ,P_NET_RSV => P_NET_RSV
                                    ,P_NET_UNRSV => P_NET_UNRSV
                                    ,P_NET_WIP => P_NET_WIP
                                    ,P_ORGANIZATION_ID => P_ORG_ID
                                    ,P_USER_ID => P_USER_ID
                                    ,P_EMPLOYEE_ID => P_EMPLOYEE_ID
                                    ,P_SUBINV_TBL => L_SUBINV_TBL
                                    ,P_DD_LOC_ID => P_DD_LOC_ID
                                    ,P_BUYER_HI => P_BUYER_HI
                                    ,P_BUYER_LO => P_BUYER_LO
                                    ,P_RANGE_BUYER => P_RANGE_BUYER
                                    ,P_RANGE_SQL => P_RANGE_SQL
                                    ,P_SORT => P_SORT
                                    ,P_SELECTION => P_SELECTION
                                    ,P_SYSDATE => P_SYSDATE
                                    ,P_S_CUTOFF => P_S_CUTOFF_1
                                    ,P_D_CUTOFF => P_D_CUTOFF_1
                                    ,P_GEN_REPORT => 'Y'
                                    ,P_MO_LINE_GROUPING => P_MO_LINE_GROUPING);
    IF L_RETURN_STATUS = 'W' THEN
      P_WARN := 'W';
      L_RETURN_STATUS := 'S';
      /*SRW.MESSAGE(100
                 ,'Warning')*/NULL;
    END IF;
    IF (L_RETURN_STATUS <> 'S') THEN
      IF L_MSG_COUNT > 0 THEN
        FOR i IN 1 .. L_MSG_COUNT LOOP
          L_MSG := FND_MSG_PUB.GET(I
                                  ,'F');
          /*SRW.MESSAGE(70
                     ,'INV_MMX_WRAPPER_PVT.exec_min_max returned error:' || L_MSG)*/NULL;
          FND_MSG_PUB.DELETE_MSG(I);
        END LOOP;
      ELSE
        /*SRW.MESSAGE(70
                   ,'INV_MMX_WRAPPER_PVT.exec_min_max returned an error: ' || L_MSG_DATA)*/NULL;
      END IF;
      RETURN (FALSE);
    END IF;
    RETURN (TRUE);
  EXCEPTION
   -- WHEN /*SRW.UNKNOWN_USER_EXIT*/OTHERS THEN
   --   /*SRW.MESSAGE(80
   --              ,'Unknown user exit (after line ' || LINE_NUM || ')')*/NULL;
   --   RETURN (FALSE);
   -- WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
   --   /*SRW.MESSAGE(85
   --              ,'User exit failed (after line ' || LINE_NUM || ')')*/NULL;
   --   RETURN (FALSE);
    WHEN OTHERS THEN
      /*SRW.MESSAGE(90
                 ,'Error - Before Report')*/NULL;
      /*SRW.MESSAGE(101
                 ,'Error after line ' || LINE_NUM || ':' || SQLCODE || ':' || SQLERRM)*/NULL;
      RETURN (FALSE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      JUNK NUMBER;
      V_DUMMY VARCHAR2(20);
      L_RET BOOLEAN;
    BEGIN
      DELETE FROM INV_MIN_MAX_TEMP;
      COMMIT;
      IF P_WARN = 'W' THEN
        L_RET := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING'
                                                     ,'Please see log file for Details');
      END IF;
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;
END INV_INVISMMX_XMLP_PKG;


/
