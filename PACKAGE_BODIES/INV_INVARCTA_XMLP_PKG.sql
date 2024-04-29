--------------------------------------------------------
--  DDL for Package Body INV_INVARCTA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVARCTA_XMLP_PKG" AS
/* $Header: INVARCTAB.pls 120.1 2008/02/21 11:14:06 dwkrishn noship $ */
  FUNCTION S_OTHER_COUNTSFORMULA(S_TOTAL_COUNTS IN NUMBER
                                ,S_COUNTS_COMPLETED IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (S_TOTAL_COUNTS - S_COUNTS_COMPLETED);
  END S_OTHER_COUNTSFORMULA;

  FUNCTION S_GROSS_ADJFORMULA(S_POS_ADJ IN NUMBER
                             ,S_NEG_ADJ IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(S_POS_ADJ)*/NULL;
    /*SRW.REFERENCE(S_NEG_ADJ)*/NULL;
    RETURN (S_POS_ADJ + ABS(S_NEG_ADJ));
  END S_GROSS_ADJFORMULA;

  FUNCTION S_NET_ADJFORMULA(S_POS_ADJ IN NUMBER
                           ,S_NEG_ADJ IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(S_POS_ADJ)*/NULL;
    /*SRW.REFERENCE(S_NEG_ADJ)*/NULL;
    RETURN (S_POS_ADJ - ABS(S_NEG_ADJ));
  END S_NET_ADJFORMULA;

  FUNCTION S_GROSS_ACCURACYFORMULA(S_GROSS_ADJ IN NUMBER
                                  ,S_INVENTORY_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(S_GROSS_ADJ)*/NULL;
      /*SRW.REFERENCE(S_INVENTORY_VALUE)*/NULL;
      IF ((S_GROSS_ADJ = 0) AND (S_INVENTORY_VALUE = 0)) THEN
        RETURN (100);
      ELSE
        IF (S_INVENTORY_VALUE = 0) THEN
          RETURN (0.00);
        ELSE
          IF (ABS(S_GROSS_ADJ) > ABS(S_INVENTORY_VALUE)) THEN
            RETURN (0.00);
          ELSE
            RETURN (100 - ((ABS(S_GROSS_ADJ) / ABS(S_INVENTORY_VALUE)) * 100));
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END S_GROSS_ACCURACYFORMULA;

  FUNCTION S_NET_ACCURACYFORMULA(S_NET_ADJ IN NUMBER
                                ,S_INVENTORY_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(S_NET_ADJ)*/NULL;
      /*SRW.REFERENCE(S_INVENTORY_VALUE)*/NULL;
    END;
    BEGIN
      IF ((S_INVENTORY_VALUE = 0) AND (S_NET_ADJ = 0)) THEN
        RETURN (100.00);
      ELSE
        IF (S_INVENTORY_VALUE = 0) THEN
          RETURN (0.00);
        ELSE
          IF (ABS(S_NET_ADJ) > ABS(S_INVENTORY_VALUE)) THEN
            RETURN (0.00);
          ELSE
            RETURN (ROUND(100 - ((ABS(S_NET_ADJ) / ABS(S_INVENTORY_VALUE)) * 100)
                        ,2));
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END S_NET_ACCURACYFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      LP_TO_DATE := to_char(P_TO_DATE, 'DD-MON-YYYY');
      LP_FROM_DATE := to_char(P_FROM_DATE, 'DD-MON-YYYY');

	select first_value(cur.precision) over() into pstd_precision
	from org_organization_definitions org,
	gl_sets_of_books  gsob,
	fnd_currencies   cur
	where org.organization_id = p_org_id
	and  org.set_of_books_id = gsob.set_of_books_id
	and cur.currency_code = gsob.currency_code;

      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Before Report: Init')*/NULL;
    END;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := P_ORG_ID;
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
                   ,'Before Report: LocatorFlex')*/NULL;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Before Report: ItemFlex')*/NULL;
    END;
    DECLARE
      M_RETURN_STATUS VARCHAR2(1);
      M_MSG_COUNT NUMBER;
      M_MSG_DATA VARCHAR2(2000);
    BEGIN
      IF (WMS_INSTALL.CHECK_INSTALL(X_RETURN_STATUS => M_RETURN_STATUS
                               ,X_MSG_COUNT => M_MSG_COUNT
                               ,X_MSG_DATA => M_MSG_DATA
                               ,P_ORGANIZATION_ID => P_ORG_ID)) THEN
        P_WMS_INSTALLED := 'TRUE';
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_FCURRENCYCODEFORMULA(C_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      TEMP_C VARCHAR2(20);
    BEGIN
      TEMP_C := '(' || C_CURRENCY_CODE || ')';
      RETURN (TEMP_C);
    END;
    RETURN NULL;
  END C_FCURRENCYCODEFORMULA;

  FUNCTION ADJUSTMENT_AMOUNTFORMULA(ENTRY_STATUS_CODE IN NUMBER
                                   ,COUNT_TYPE_CODE IN NUMBER
                                   ,ADJUSTMENT_QUANTITY_CURRENT IN NUMBER
                                   ,CONV_RATE_CURRENT IN NUMBER
                                   ,ITEM_UNIT_COST IN NUMBER
                                   ,S_STD_PRECISION IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF ((ENTRY_STATUS_CODE = 5 OR P_APPROVED = 2) AND (COUNT_TYPE_CODE <> 4)) THEN
        RETURN (ROUND(ADJUSTMENT_QUANTITY_CURRENT * CONV_RATE_CURRENT * ITEM_UNIT_COST
                    ,S_STD_PRECISION));
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END ADJUSTMENT_AMOUNTFORMULA;

  FUNCTION POS_ADJFORMULA(ADJUSTMENT_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF ADJUSTMENT_AMOUNT > 0 THEN
        RETURN (ADJUSTMENT_AMOUNT);
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END POS_ADJFORMULA;

  FUNCTION NEG_ADJFORMULA(ADJUSTMENT_AMOUNT IN NUMBER
                         ,NEG_ADJUSTMENT_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF ADJUSTMENT_AMOUNT < 0 THEN
        RETURN (ABS(ADJUSTMENT_AMOUNT) + NVL(NEG_ADJUSTMENT_AMOUNT
                  ,0));
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END NEG_ADJFORMULA;

  FUNCTION SF_NETACCURACYFORMULA(SR_NETADJ IN NUMBER
                                ,SR_INVENTORYVALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(SR_NETADJ)*/NULL;
      /*SRW.REFERENCE(SR_INVENTORYVALUE)*/NULL;
    END;
    BEGIN
      IF ((SR_INVENTORYVALUE = 0) AND (SR_NETADJ = 0)) THEN
        RETURN (100.00);
      ELSE
        IF (SR_INVENTORYVALUE = 0) THEN
          RETURN (0.00);
        ELSE
          IF (ABS(SR_NETADJ) > ABS(SR_INVENTORYVALUE)) THEN
            RETURN (0.00);
          ELSE
            RETURN (ROUND(100 - ((ABS(SR_NETADJ) / ABS(SR_INVENTORYVALUE)) * 100)
                        ,2));
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END SF_NETACCURACYFORMULA;

  FUNCTION SF_GROSSACCURACYFORMULA(SR_GROSSADJ IN NUMBER
                                  ,SR_INVENTORYVALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(SR_GROSSADJ)*/NULL;
      /*SRW.REFERENCE(SR_INVENTORYVALUE)*/NULL;
      IF ((SR_GROSSADJ = 0) AND (SR_INVENTORYVALUE = 0)) THEN
        RETURN (100);
      ELSE
        IF (SR_INVENTORYVALUE = 0) THEN
          RETURN (0.00);
        ELSE
          IF (ABS(SR_GROSSADJ) > ABS(SR_INVENTORYVALUE)) THEN
            RETURN (0.00);
          ELSE
            RETURN (100 - ((ABS(SR_GROSSADJ) / ABS(SR_INVENTORYVALUE)) * 100));
          END IF;
        END IF;
      END IF;
    END;
    RETURN NULL;
  END SF_GROSSACCURACYFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_APPROVEDFIELDFORMULA(ENTRY_STATUS_CODE IN NUMBER
                                 ,COMPLETED_FLAG IN VARCHAR2
                                 ,NON_COMPLETED_FLAG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF ENTRY_STATUS_CODE = 5 THEN
        RETURN (COMPLETED_FLAG);
      ELSE
        RETURN (NON_COMPLETED_FLAG);
      END IF;
    END;
    RETURN NULL;
  END C_APPROVEDFIELDFORMULA;

  FUNCTION ADJUSTMENT_AMOUNT_PRIORFORMULA(ENTRY_STATUS_CODE IN NUMBER
                                         ,COUNT_TYPE_CODE IN NUMBER
                                         ,ADJUSTMENT_QUANTITY_PRIOR IN NUMBER
                                         ,CONV_RATE_PRIOR IN NUMBER
                                         ,ITEM_UNIT_COST IN NUMBER
                                         ,S_STD_PRECISION IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF ((ENTRY_STATUS_CODE = 5 OR P_APPROVED = 2) AND (COUNT_TYPE_CODE <> 4)) THEN
        RETURN (ROUND(ADJUSTMENT_QUANTITY_PRIOR * CONV_RATE_PRIOR * ITEM_UNIT_COST
                    ,S_STD_PRECISION));
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END ADJUSTMENT_AMOUNT_PRIORFORMULA;

  FUNCTION ADJUSTMENT_AMOUNT_FIRSTFORMULA(ENTRY_STATUS_CODE IN NUMBER
                                         ,COUNT_TYPE_CODE IN NUMBER
                                         ,ADJUSTMENT_QUANTITY_FIRST IN NUMBER
                                         ,CONV_RATE_FIRST IN NUMBER
                                         ,ITEM_UNIT_COST IN NUMBER
                                         ,S_STD_PRECISION IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF ((ENTRY_STATUS_CODE = 5 OR P_APPROVED = 2) AND (COUNT_TYPE_CODE <> 4)) THEN
        RETURN (ROUND(ADJUSTMENT_QUANTITY_FIRST * CONV_RATE_FIRST * ITEM_UNIT_COST
                    ,S_STD_PRECISION));
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END ADJUSTMENT_AMOUNT_FIRSTFORMULA;

  FUNCTION CONV_RATE_CURRENTFORMULA(COUNT_UOM_CURRENT IN VARCHAR2
                                   ,INVENTORY_ITEM_ID1 IN NUMBER
                                   ,UOM IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      CUR_RATE NUMBER;
    BEGIN
      IF (COUNT_UOM_CURRENT IS NULL) THEN
        RETURN (1);
      ELSE
        SELECT
          CONVERSION_RATE
        INTO CUR_RATE
        FROM
          MTL_UOM_CONVERSIONS_VIEW
        WHERE INVENTORY_ITEM_ID = INVENTORY_ITEM_ID1
          AND ORGANIZATION_ID = TO_NUMBER(P_ORG_ID)
          AND PRIMARY_UOM_CODE = UOM
          AND UOM_CODE = COUNT_UOM_CURRENT;
        RETURN (CUR_RATE);
      END IF;
    END;
    RETURN NULL;
  END CONV_RATE_CURRENTFORMULA;

  FUNCTION CONV_RATE_PRIORFORMULA(COUNT_UOM_PRIOR IN VARCHAR2
                                 ,INVENTORY_ITEM_ID1 IN NUMBER
                                 ,UOM IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      PRIOR_RATE NUMBER;
    BEGIN
      IF (COUNT_UOM_PRIOR IS NULL) THEN
        RETURN (1);
      ELSE
        SELECT
          CONVERSION_RATE
        INTO PRIOR_RATE
        FROM
          MTL_UOM_CONVERSIONS_VIEW
        WHERE INVENTORY_ITEM_ID = INVENTORY_ITEM_ID1
          AND ORGANIZATION_ID = TO_NUMBER(P_ORG_ID)
          AND PRIMARY_UOM_CODE = UOM
          AND UOM_CODE = COUNT_UOM_PRIOR;
        RETURN (PRIOR_RATE);
      END IF;
    END;
    RETURN NULL;
  END CONV_RATE_PRIORFORMULA;

  FUNCTION CONV_RATE_FIRSTFORMULA(COUNT_UOM_FIRST IN VARCHAR2
                                 ,INVENTORY_ITEM_ID1 IN NUMBER
                                 ,UOM IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      FIRST_RATE NUMBER;
    BEGIN
      IF (COUNT_UOM_FIRST IS NULL) THEN
        RETURN (1);
      ELSE
        SELECT
          CONVERSION_RATE
        INTO FIRST_RATE
        FROM
          MTL_UOM_CONVERSIONS_VIEW
        WHERE INVENTORY_ITEM_ID = INVENTORY_ITEM_ID1
          AND ORGANIZATION_ID = TO_NUMBER(P_ORG_ID)
          AND PRIMARY_UOM_CODE = UOM
          AND UOM_CODE = COUNT_UOM_FIRST;
        RETURN (FIRST_RATE);
      END IF;
    END;
    RETURN NULL;
  END CONV_RATE_FIRSTFORMULA;

  FUNCTION ITEM_INV_VALUE_CURRENTFORMULA(ENTRY_STATUS_CODE IN NUMBER
                                        ,COUNT_TYPE_CODE IN NUMBER
                                        ,SYSTEM_QUANTITY_CURRENT IN NUMBER
                                        ,CONV_RATE_CURRENT IN NUMBER
                                        ,ITEM_UNIT_COST IN NUMBER
                                        ,S_STD_PRECISION IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    BEGIN
      IF (ENTRY_STATUS_CODE = 5) AND (COUNT_TYPE_CODE <> 4) THEN
        RETURN (ROUND(NVL(SYSTEM_QUANTITY_CURRENT
                        ,0) * CONV_RATE_CURRENT * NVL(ITEM_UNIT_COST
                        ,0)
                    ,S_STD_PRECISION));
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END ITEM_INV_VALUE_CURRENTFORMULA;

  FUNCTION P_LOCATOR_FLEXVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_LOCATOR_FLEXVALIDTRIGGER;

  FUNCTION CF_OUTERMOST_LPNFORMULA(OUTERMOST_LPN_ID IN NUMBER) RETURN CHAR IS
    X_OUTERMOST_LPN VARCHAR2(30) := NULL;
  BEGIN
    IF (P_WMS_INSTALLED = 'TRUE') THEN
      IF (OUTERMOST_LPN_ID IS NOT NULL) THEN
        BEGIN
          SELECT
            LICENSE_PLATE_NUMBER
          INTO X_OUTERMOST_LPN
          FROM
            WMS_LICENSE_PLATE_NUMBERS
          WHERE LPN_ID = OUTERMOST_LPN_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            X_OUTERMOST_LPN := 'ERROR';
        END;
      END IF;
    END IF;
    RETURN (X_OUTERMOST_LPN);
  END CF_OUTERMOST_LPNFORMULA;

  FUNCTION CF_PARENT_LPNFORMULA(PARENT_LPN_ID IN NUMBER) RETURN CHAR IS
    X_PARENT_LPN VARCHAR2(30) := NULL;
  BEGIN
    IF (P_WMS_INSTALLED = 'TRUE') THEN
      IF (PARENT_LPN_ID IS NOT NULL) THEN
        BEGIN
          SELECT
            LICENSE_PLATE_NUMBER
          INTO X_PARENT_LPN
          FROM
            WMS_LICENSE_PLATE_NUMBERS
          WHERE LPN_ID = PARENT_LPN_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            X_PARENT_LPN := 'ERROR';
        END;
      END IF;
    END IF;
    RETURN (X_PARENT_LPN);
  END CF_PARENT_LPNFORMULA;

  FUNCTION CF_COST_GROUPFORMULA(COST_GROUP_ID IN NUMBER) RETURN CHAR IS
    M_COST_GROUP VARCHAR2(10) := NULL;
  BEGIN
    IF ((P_WMS_INSTALLED = 'TRUE') AND (COST_GROUP_ID IS NOT NULL)) THEN
      BEGIN
        SELECT
          COST_GROUP
        INTO M_COST_GROUP
        FROM
          CST_COST_GROUPS
        WHERE COST_GROUP_ID = COST_GROUP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          M_COST_GROUP := 'ERROR';
      END;
    END IF;
    RETURN (M_COST_GROUP);
  END CF_COST_GROUPFORMULA;

END INV_INVARCTA_XMLP_PKG;


/
