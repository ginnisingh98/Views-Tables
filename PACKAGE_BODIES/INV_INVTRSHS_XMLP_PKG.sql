--------------------------------------------------------
--  DDL for Package Body INV_INVTRSHS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVTRSHS_XMLP_PKG" AS
/* $Header: INVTRSHSB.pls 120.2 2008/01/08 06:43:24 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    X_RETURN_STATUS VARCHAR2(1);
    X_MSG_COUNT NUMBER;
    X_MSG_DATA VARCHAR2(2000);
    X_SEQ_NUM NUMBER;
    X_CHECK_RESULT VARCHAR2(1);
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:SRWINIT')*/NULL;
    END;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := TO_CHAR(P_ORG_ID);
    BEGIN
      /*SRW.USER_EXIT('FND PUTPROFILE NAME="' || 'MFG_ORGANIZATION_ID' || '" FIELD="' || P_ORG_ID_CHAR || '"')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, setting org profile ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MSTK')*/NULL;
    END;
    BEGIN
      IF P_ITEM_FROM IS NOT NULL OR P_ITEM_TO IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MSTK:WHERE')*/NULL;
    END;
    BEGIN
      IF P_GROUP_BY = 1 THEN
        NULL;
      ELSE
        P_CAT_FLEX := '''MC''';
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MCAT/sel')*/NULL;
    END;
    BEGIN
      IF P_CATEGORY_FROM IS NOT NULL OR P_CATEGORY_TO IS NOT NULL THEN
        NULL;
      ELSE
        NULL;
      END IF;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in before report trigger:MCAT/WHERE')*/NULL;
    END;
    INV_SHORTCHECKEXEC_PVT.EXECCHECK(P_API_VERSION => 1.0
                                    ,P_INIT_MSG_LIST => P_G_TRUE
                                    ,P_COMMIT => P_G_TRUE
                                    ,X_RETURN_STATUS => X_RETURN_STATUS
                                    ,X_MSG_COUNT => X_MSG_COUNT
                                    ,X_MSG_DATA => X_MSG_DATA
                                    ,P_SUM_DETAIL_FLAG => 1
                                    ,P_ORGANIZATION_ID => P_ORG_ID
                                    ,P_INVENTORY_ITEM_ID => NULL
                                    ,P_COMP_ATT_QTY_FLAG => 2
                                    ,P_PRIMARY_QUANTITY => 0
                                    ,X_SEQ_NUM => X_SEQ_NUM
                                    ,X_CHECK_RESULT => X_CHECK_RESULT);
    P_SEQ_NUM := X_SEQ_NUM;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
    --P_SEQ_NUM NUMBER := P_SEQ_NUM;
    P_SEQ_NUM_T NUMBER := P_SEQ_NUM;
    X_RETURN_STATUS VARCHAR2(1);
    X_MSG_COUNT NUMBER;
    X_MSG_DATA VARCHAR2(2000);
  BEGIN
    INV_SHORTCHECKEXEC_PVT.PURGETEMPTABLE(P_API_VERSION => 1.0
                                         ,P_INIT_MSG_LIST => P_G_TRUE
                                         ,P_COMMIT => P_G_TRUE
                                         ,X_RETURN_STATUS => X_RETURN_STATUS
                                         ,X_MSG_COUNT => X_MSG_COUNT
                                         ,X_MSG_DATA => X_MSG_DATA
                                         ,P_SEQ_NUM => P_SEQ_NUM_T);
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION C_FROM_CATFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_GROUP_BY = 1 OR P_CATEGORY_FROM IS NOT NULL OR P_CATEGORY_TO IS NOT NULL THEN
      RETURN (',mtl_item_categories MIC, mtl_categories MC');
    ELSE
      RETURN ('/* Do not select from category tables.*/');
    END IF;
    RETURN NULL;
  END C_FROM_CATFORMULA;
  FUNCTION C_CAT_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_GROUP_BY = 1 OR P_CATEGORY_FROM IS NOT NULL OR P_CATEGORY_TO IS NOT NULL THEN
      RETURN ('and MSI.inventory_item_id = MIC.inventory_item_id
                          and MIC.organization_id = MSI.organization_id
                    	     and MIC.category_set_id = ' || TO_CHAR(P_CATEGORY_SET) || '
                          and MIC.category_id = MC.category_id
                          and MIC.organization_id = ' || TO_CHAR(P_ORG_ID));
    ELSE
      NULL;
    END IF;
    RETURN '  ';
  END C_CAT_WHEREFORMULA;
  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2 IS
    V_ORDER VARCHAR2(200) := NULL;
  BEGIN
    IF P_GROUP_BY in (1,3) THEN
      V_ORDER := P_ORDER_ITEM;
    ELSE
      V_ORDER := '';
    END IF;
    RETURN ('ORDER BY 14 ASC,1 ASC,6 ASC,8 ASC,16 ASC,10 ASC ,' || P_ORDER_HDR || V_ORDER || P_ORDER_POS);
  END C_ORDER_BYFORMULA;
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION C_HDR_ITEM_PADFORMULA(C_HDR_ITEM_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_HDR_ITEM_PAD);
  END C_HDR_ITEM_PADFORMULA;
  FUNCTION C_GROUP_OPTION_NAMEFORMULA RETURN VARCHAR2 IS
    V_MEANING VARCHAR2(80);
  BEGIN
    SELECT
      ML.MEANING
    INTO V_MEANING
    FROM
      MFG_LOOKUPS ML
    WHERE ML.LOOKUP_TYPE = 'MTL_SHORT_SUM_PRINT_GROUP'
      AND ML.LOOKUP_CODE = P_GROUP_BY;
    RETURN (V_MEANING);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (P_GROUP_BY);
  END C_GROUP_OPTION_NAMEFORMULA;
  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      NAME VARCHAR2(30);
      SET_ID NUMBER;
    BEGIN
      IF P_CATEGORY_SET IS NULL THEN
        RETURN ('');
      ELSE
        SET_ID := P_CATEGORY_SET;
        SELECT
          MCS.CATEGORY_SET_NAME
        INTO NAME
        FROM
          MTL_CATEGORY_SETS MCS
        WHERE MCS.CATEGORY_SET_ID = SET_ID;
        RETURN (NAME);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No Data');
      WHEN OTHERS THEN
        RETURN ('Error');
    END;
    RETURN NULL;
  END C_CAT_SET_NAMEFORMULA;
  FUNCTION C_POS_ITEM_PADFORMULA(C_POS_ITEM_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_POS_ITEM_PAD);
  END C_POS_ITEM_PADFORMULA;
  FUNCTION C_CAT_PADFORMULA(C_CAT_PAD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_CAT_PAD);
  END C_CAT_PADFORMULA;
  FUNCTION C_ONHAND_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ONHAND_ONLY_YN = 1 THEN
      RETURN ('and 0 < (select NVL(SUM(DECODE(MSIN.availability_type, 1, 1, 0) * MIQV.quantity), 0)
                         	      from   mtl_secondary_inventories MSIN
                                         ,mtl_item_quantities_view MIQV
                         	      where  MSSV.organization_id = MIQV.organization_id
                         	      and    MSSV.inventory_item_id = MIQV.inventory_item_id
                         	      and    MIQV.organization_id = MSIN.organization_id
                         	      and    MIQV.subinventory_code = MSIN.secondary_inventory_name)');
    ELSE
      NULL;
    END IF;
    RETURN '  ';
  END C_ONHAND_WHEREFORMULA;
  FUNCTION C_ONHAND_ONLY_YNFORMULA RETURN VARCHAR2 IS
    V_MEANING VARCHAR2(80);
  BEGIN
    SELECT
      ML.MEANING
    INTO V_MEANING
    FROM
      MFG_LOOKUPS ML
    WHERE ML.LOOKUP_TYPE = 'SYS_YES_NO'
      AND ML.LOOKUP_CODE = P_ONHAND_ONLY_YN;
    RETURN (V_MEANING);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (P_ONHAND_ONLY_YN);
  END C_ONHAND_ONLY_YNFORMULA;
  FUNCTION C_NET_QTY_HDRFORMULA(C_INVENTORY_ITEM_ID_HDR IN NUMBER) RETURN NUMBER IS
    SUM_QTY NUMBER;
    C_INVENTORY_ITEM_ID NUMBER;
  BEGIN
    IF P_GROUP_BY = 2 THEN
      /*SRW.REFERENCE(C_INVENTORY_ITEM_ID_HDR)*/NULL;
      C_INVENTORY_ITEM_ID := C_INVENTORY_ITEM_ID_HDR;
      SELECT
        NVL(SUM(DECODE(MSI.AVAILABILITY_TYPE
                      ,1
                      ,1
                      ,0) * MIQV.QUANTITY)
           ,0)
      INTO SUM_QTY
      FROM
        MTL_ITEM_QUANTITIES_VIEW MIQV,
        MTL_SECONDARY_INVENTORIES MSI
      WHERE MIQV.INVENTORY_ITEM_ID = C_INVENTORY_ITEM_ID
        AND MIQV.ORGANIZATION_ID = P_ORG_ID
        AND MSI.ORGANIZATION_ID = P_ORG_ID
        AND MSI.SECONDARY_INVENTORY_NAME = MIQV.SUBINVENTORY_CODE;
      RETURN (SUM_QTY);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END C_NET_QTY_HDRFORMULA;
  FUNCTION C_NET_QTY_POSFORMULA(C_INVENTORY_ITEM_ID_POS IN NUMBER) RETURN NUMBER IS
    SUM_QTY NUMBER;
    C_INVENTORY_ITEM_ID NUMBER;
  BEGIN
    IF P_GROUP_BY <> 2 THEN
      /*SRW.REFERENCE(C_INVENTORY_ITEM_ID_POS)*/NULL;
      C_INVENTORY_ITEM_ID := C_INVENTORY_ITEM_ID_POS;
      SELECT
        NVL(SUM(DECODE(MSI.AVAILABILITY_TYPE
                      ,1
                      ,1
                      ,0) * MIQV.QUANTITY)
           ,0)
      INTO SUM_QTY
      FROM
        MTL_ITEM_QUANTITIES_VIEW MIQV,
        MTL_SECONDARY_INVENTORIES MSI
      WHERE MIQV.INVENTORY_ITEM_ID = C_INVENTORY_ITEM_ID
        AND MIQV.ORGANIZATION_ID = P_ORG_ID
        AND MSI.ORGANIZATION_ID = P_ORG_ID
        AND MSI.SECONDARY_INVENTORY_NAME = MIQV.SUBINVENTORY_CODE;
      RETURN (SUM_QTY);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END C_NET_QTY_POSFORMULA;
  FUNCTION C_NOTIFICATIONFORMULA(C_INVENTORY_ITEM_ID_HDR IN NUMBER
                                ,C_INVENTORY_ITEM_ID_POS IN NUMBER) RETURN NUMBER IS
    L_INVENTORY_ITEM_ID NUMBER;
  BEGIN
    IF P_GROUP_BY = 2 THEN
      L_INVENTORY_ITEM_ID := C_INVENTORY_ITEM_ID_HDR;
    ELSE
      L_INVENTORY_ITEM_ID := C_INVENTORY_ITEM_ID_POS;
    END IF;
    IF P_INVENTORY_ITEM_ID = 0 OR P_INVENTORY_ITEM_ID <> L_INVENTORY_ITEM_ID THEN
      IF P_SEND_NOTIFICATIONS_YN = 1 THEN
        SEND(P_INVENTORY_ITEM_ID => L_INVENTORY_ITEM_ID);
      END IF;
      P_INVENTORY_ITEM_ID := L_INVENTORY_ITEM_ID;
    END IF;
    RETURN 1;
  END C_NOTIFICATIONFORMULA;
  FUNCTION C_SEND_NOTIFICATIONS_YNFORMULA RETURN VARCHAR2 IS
    V_MEANING VARCHAR2(80);
  BEGIN
    SELECT
      ML.MEANING
    INTO V_MEANING
    FROM
      MFG_LOOKUPS ML
    WHERE ML.LOOKUP_TYPE = 'SYS_YES_NO'
      AND ML.LOOKUP_CODE = P_SEND_NOTIFICATIONS_YN;
    RETURN (V_MEANING);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (P_SEND_NOTIFICATIONS_YN);
  END C_SEND_NOTIFICATIONS_YNFORMULA;
  FUNCTION C_ITEMPLANNER_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_ITEM_PLANNER IS NOT NULL THEN
      RETURN ('AND mssv.item_planner_code = ' || '''' || P_ITEM_PLANNER || '''');
    ELSE
      NULL;
    END IF;
    RETURN '  ';
  END C_ITEMPLANNER_WHEREFORMULA;
  PROCEDURE SEND(P_INVENTORY_ITEM_ID IN NUMBER) IS
    X_RETURN_STATUS VARCHAR2(1);
    X_MSG_COUNT NUMBER;
    X_MSG_DATA VARCHAR2(2000);
    L_SEQ_NUM NUMBER;
    L_INVENTORY_ITEM_ID NUMBER;
    L_PREREQUISITES BOOLEAN;
    L_CHECK_RESULT VARCHAR2(1);
  BEGIN
    INV_SHORTCHECKEXEC_PVT.CHECKPREREQUISITES(P_API_VERSION => 1.0
                                             ,P_INIT_MSG_LIST => P_G_TRUE
                                             ,X_RETURN_STATUS => X_RETURN_STATUS
                                             ,X_MSG_COUNT => X_MSG_COUNT
                                             ,X_MSG_DATA => X_MSG_DATA
                                             ,P_SUM_DETAIL_FLAG => 1
                                             ,P_ORGANIZATION_ID => P_ORG_ID
                                             ,P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID
                                             ,P_TRANSACTION_TYPE_ID => NULL
                                             ,X_CHECK_RESULT => L_CHECK_RESULT);
    IF L_CHECK_RESULT = P_G_TRUE AND X_RETURN_STATUS = P_G_RET_STS_SUCCESS THEN
      L_PREREQUISITES := TRUE;
    ELSE
      L_PREREQUISITES := FALSE;
    END IF;
    IF L_PREREQUISITES THEN
      INV_SHORTCHECKEXEC_PVT.EXECCHECK(P_API_VERSION => 1.0
                                      ,P_INIT_MSG_LIST => P_G_TRUE
                                      ,P_COMMIT => P_G_TRUE
                                      ,X_RETURN_STATUS => X_RETURN_STATUS
                                      ,X_MSG_COUNT => X_MSG_COUNT
                                      ,X_MSG_DATA => X_MSG_DATA
                                      ,P_SUM_DETAIL_FLAG => 1
                                      ,P_ORGANIZATION_ID => P_ORG_ID
                                      ,P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID
                                      ,P_COMP_ATT_QTY_FLAG => 1
                                      ,P_PRIMARY_QUANTITY => 0
                                      ,X_SEQ_NUM => L_SEQ_NUM
                                      ,X_CHECK_RESULT => L_CHECK_RESULT);
      IF X_RETURN_STATUS <> P_G_RET_STS_SUCCESS THEN
        NULL;
      ELSE
        IF L_CHECK_RESULT = P_G_TRUE THEN
          INV_SHORTCHECKEXEC_PVT.SENDNOTIFICATIONS(P_API_VERSION => 1.0
                                                  ,P_INIT_MSG_LIST => P_G_TRUE
                                                  ,P_COMMIT => P_G_TRUE
                                                  ,X_RETURN_STATUS => X_RETURN_STATUS
                                                  ,X_MSG_COUNT => X_MSG_COUNT
                                                  ,X_MSG_DATA => X_MSG_DATA
                                                  ,P_ORGANIZATION_ID => P_ORG_ID
                                                  ,P_INVENTORY_ITEM_ID => P_INVENTORY_ITEM_ID
                                                  ,P_SEQ_NUM => L_SEQ_NUM
                                                  ,P_NOTIFICATION_TYPE => 'S');
        END IF;
      END IF;
      INV_SHORTCHECKEXEC_PVT.PURGETEMPTABLE(P_API_VERSION => 1.0
                                           ,P_INIT_MSG_LIST => P_G_TRUE
                                           ,P_COMMIT => P_G_TRUE
                                           ,X_RETURN_STATUS => X_RETURN_STATUS
                                           ,X_MSG_COUNT => X_MSG_COUNT
                                           ,X_MSG_DATA => X_MSG_DATA
                                           ,P_SEQ_NUM => L_SEQ_NUM);
    END IF;
  END SEND;
END INV_INVTRSHS_XMLP_PKG;


/
