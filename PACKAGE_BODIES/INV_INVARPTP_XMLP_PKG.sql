--------------------------------------------------------
--  DDL for Package Body INV_INVARPTP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVARPTP_XMLP_PKG" AS
/* $Header: INVARPTPB.pls 120.1 2008/02/21 11:03:51 dwkrishn noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Srwinit failed before report trigger')*/NULL;
        RAISE;
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
    SELECT
      ID_FLEX_NUM
    INTO P_ITEM_STRUCT
    FROM
      FND_ID_FLEX_STRUCTURES
    WHERE ID_FLEX_CODE = 'MSTK';
    SELECT
      ID_FLEX_NUM
    INTO P_LOC_STRUCT
    FROM
      FND_ID_FLEX_STRUCTURES
    WHERE ID_FLEX_CODE = 'MTLL';
    BEGIN
      /*SRW.REFERENCE(P_ITEM_STRUCT)*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(2
                   ,'Item Flex Select failed before report trigger')*/NULL;
        RAISE;
    END;
    BEGIN
      /*SRW.REFERENCE(P_LOC_STRUCT)*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(3
                   ,'Locator Flex Select failed before report trigger')*/NULL;
        RAISE;
    END;
    IF (P_RANGE = 2) THEN
      IF (P_TAG_LO IS NOT NULL) AND (P_TAG_HI IS NOT NULL) THEN
        P_RANGE_SQL := 'mpit.tag_number between' || '''' || P_TAG_LO || '''' || ' and ' || '''' || P_TAG_HI || '''';
      ELSIF (P_SORT_ID = 1) AND (P_TAG_LO IS NOT NULL) THEN
        P_RANGE_SQL := 'mpit.tag_number >= ' || '''' || P_TAG_LO || '''';
      ELSIF (P_SORT_ID = 1) AND (P_TAG_HI IS NOT NULL) THEN
        P_RANGE_SQL := 'mpit.tag_number <= ' || '''' || P_TAG_HI || '''';
      END IF;
      IF (P_LOC_LO IS NOT NULL) AND (P_LOC_HI IS NOT NULL) THEN
        BEGIN
          /*SRW.REFERENCE(P_LOC_STRUCT)*/NULL;
          /*SRW.USER_EXIT('FND FLEXSQL
                        		CODE = "MTLL"
                        		APPL_SHORT_NAME = "INV"
                        		OUTPUT = "P_RANGE_FLEX"
                        		MODE = "WHERE"
                        		NUM = ":P_LOC_STRUCT"
                        		TABLEALIAS = "MIL"
                        		OPERATOR = "BETWEEN"
                        		OPERAND1 = ":P_LOC_LO"
                        		OPERAND2 = ":P_LOC_HI"')*/NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(4
                       ,'Locator Flex Where failed before report trigger')*/NULL;
            RAISE;
        END;
      END IF;
      IF (P_LOC_LO IS NOT NULL) AND (P_LOC_HI IS NULL) THEN
        BEGIN
          /*SRW.REFERENCE(P_LOC_STRUCT)*/NULL;
          /*SRW.USER_EXIT('FND FLEXSQL
                        		CODE = "MTLL"
                        		APPL_SHORT_NAME = "INV"
                        		OUTPUT = "P_RANGE_FLEX"
                        		MODE = "WHERE"
                        		NUM = ":P_LOC_STRUCT"
                        		TABLEALIAS = "MIL"
                        		OPERATOR = ">="
                        		OPERAND1 = ":P_LOC_LO"')*/NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(5
                       ,'Locator Flex Where failed before report trigger')*/NULL;
            RAISE;
        END;
      END IF;
      IF (P_LOC_LO IS NULL) AND (P_LOC_HI IS NOT NULL) THEN
        BEGIN
          /*SRW.REFERENCE(P_LOC_STRUCT)*/NULL;
          /*SRW.USER_EXIT('FND FLEXSQL
                        		CODE = "MTLL"
                        		APPL_SHORT_NAME = "INV"
                        		OUTPUT = "P_RANGE_FLEX"
                        		MODE = "WHERE"
                        		NUM = ":P_LOC_STRUCT"
                        		TABLEALIAS = "MIL"
                        		OPERATOR = "<="
                        		OPERAND1 = ":P_LOC_HI"')*/NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(6
                       ,'Locator Flex Where failed before report trigger')*/NULL;
            RAISE;
        END;
      END IF;
      IF (P_ITEM_LO IS NOT NULL) AND (P_ITEM_HI IS NOT NULL) THEN
        BEGIN
          /*SRW.REFERENCE(P_ITEM_STRUCT)*/NULL;
          /*SRW.USER_EXIT('FND FLEXSQL
                        		CODE = "MSTK"
                        		NUM = ":P_ITEM_STRUCT"
                        		APPL_SHORT_NAME = "INV"
                        		OUTPUT = "P_RANGE_FLEX"
                        		MODE = "WHERE"
                        		TABLEALIAS = "MSI"
                        		OPERATOR = "BETWEEN"
                        		OPERAND1 = ":P_ITEM_LO"
                        		OPERAND2 = ":P_ITEM_HI"')*/NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(7
                       ,'Item Flex Where failed before report trigger')*/NULL;
            RAISE;
        END;
      END IF;
      IF (P_ITEM_LO IS NOT NULL) AND (P_ITEM_HI IS NULL) THEN
        BEGIN
          /*SRW.REFERENCE(P_ITEM_STRUCT)*/NULL;
          /*SRW.USER_EXIT('FND FLEXSQL
                        		CODE="MSTK"
                        		APPL_SHORT_NAME="INV"
                        		OUTPUT="P_RANGE_FLEX"
                        		MODE="WHERE"
                        		DISPLAY="ALL"
                        		NUM=":P_ITEM_STRUCT"
                        		TABLEALIAS="MSI"
                        		OPERATOR=">="
                        		OPERAND1=":P_ITEM_LO"')*/NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(8
                       ,'Item Flex Where failed before report trigger')*/NULL;
            RAISE;
        END;
      END IF;
      IF (P_ITEM_LO IS NULL) AND (P_ITEM_HI IS NOT NULL) THEN
        BEGIN
          /*SRW.REFERENCE(P_ITEM_STRUCT)*/NULL;
          /*SRW.USER_EXIT('FND FLEXSQL
                        		CODE = "MSTK"
                        		APPL_SHORT_NAME = "INV"
                        		OUTPUT = "P_RANGE_FLEX"
                        		MODE = "WHERE"
                        		NUM = ":P_ITEM_STRUCT"
                        		TABLEALIAS = "MSI"
                        		OPERATOR = "<="
                        		OPERAND1 = ":P_ITEM_HI"')*/NULL;
        EXCEPTION
          WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
            /*SRW.MESSAGE(9
                       ,'Item Flex Where failed before report trigger')*/NULL;
            RAISE;
        END;
      END IF;
    END IF;
    BEGIN
      /*SRW.REFERENCE(P_ITEM_STRUCT)*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(10
                   ,'Item Flex Order By failed before report trigger')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(11
                   ,'Locator Flex Order By failed before report trigger')*/NULL;
    END;
    IF P_SORT_ID = 1 THEN
      P_ORDER_BY := 'order by 4';
    ELSIF P_SORT_ID = 2 THEN
      P_ORDER_BY := 'order by 10, 11, 5, 8, 13, 14, 4';
    ELSIF P_SORT_ID = 3 THEN
      P_ORDER_BY := 'order by 10, 5, 8, 13, 14, 11, 4';
    ELSIF P_SORT_ID = 4 THEN
      P_ORDER_BY := 'order by 5, 10, 11';
    END IF;
    WMS_INSTALLED;
    RETURN (TRUE);
  END BEFOREREPORT;
  PROCEDURE WMS_INSTALLED IS
    X_RETURN_STATUS VARCHAR2(240) := NULL;
    X_MSG_COUNT NUMBER := NULL;
    X_MSG_DATA VARCHAR2(240) := NULL;
  BEGIN
    IF (WMS_INSTALL.CHECK_INSTALL(X_RETURN_STATUS
                             ,X_MSG_COUNT
                             ,X_MSG_DATA
                             ,P_ORG_ID)) THEN
      P_WMS_INSTALLED := 'TRUE';
    ELSE
      P_WMS_INSTALLED := 'FALSE';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(12
                 ,'WMS Installed failed before report trigger')*/NULL;
  END WMS_INSTALLED;
  FUNCTION CF_PARENT_LPNFORMULA(PARENT_LPN IN NUMBER) RETURN CHAR IS
    L_LPN VARCHAR2(30) := NULL;
  BEGIN
  --commetented as fix
  /*  L_LPN := GET_LPN(P_LPN_ID
                    ,PARENT_LPN);*/
    L_LPN := GET_LPN(PARENT_LPN);
    RETURN L_LPN;
  END CF_PARENT_LPNFORMULA;
  FUNCTION GET_LPN(P_LPN_ID IN NUMBER) RETURN VARCHAR2 IS
    L_LPN_NAME VARCHAR2(30) := NULL;
  BEGIN
    --IF (P_WMS_INSTALLED = 'TRUE' AND PARENT_LPN IS NOT NULL) THEN
    IF (P_WMS_INSTALLED = 'TRUE' AND P_LPN_ID IS NOT NULL) THEN
      SELECT
        LICENSE_PLATE_NUMBER
      INTO L_LPN_NAME
      FROM
        WMS_LICENSE_PLATE_NUMBERS
      WHERE LPN_ID = P_LPN_ID;
    ELSE
      L_LPN_NAME := NULL;
    END IF;
    RETURN L_LPN_NAME;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END GET_LPN;
  FUNCTION CF_OUTERMOST_LPNFORMULA(OUTERMOST_LPN IN NUMBER
                                  ,PARENT_LPN IN NUMBER) RETURN CHAR IS
    L_LPN VARCHAR2(30) := NULL;
  BEGIN
    /*L_LPN := GET_LPN(P_LPN_ID
                    ,PARENT_LPN);*/
             L_LPN := GET_LPN(PARENT_LPN);
    RETURN L_LPN;
  END CF_OUTERMOST_LPNFORMULA;
  FUNCTION CF_COST_GROUPFORMULA(COST_GROUP_ID_1 IN NUMBER) RETURN CHAR IS
    M_COST_GROUP VARCHAR2(10) := NULL;
  BEGIN
    IF ((P_WMS_INSTALLED = 'TRUE') AND (COST_GROUP_ID_1 IS NOT NULL)) THEN
      BEGIN
        SELECT
          COST_GROUP
        INTO M_COST_GROUP
        FROM
          CST_COST_GROUPS
        WHERE COST_GROUP_ID = COST_GROUP_ID_1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          M_COST_GROUP := 'ERROR';
      END;
    END IF;
    RETURN (M_COST_GROUP);
  END CF_COST_GROUPFORMULA;
END INV_INVARPTP_XMLP_PKG;


/
