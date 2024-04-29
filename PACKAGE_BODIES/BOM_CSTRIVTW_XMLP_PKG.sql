--------------------------------------------------------
--  DDL for Package Body BOM_CSTRIVTW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTRIVTW_XMLP_PKG" AS
/* $Header: CSTRIVTWB.pls 120.0 2007/12/24 10:04:39 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
   P_CONC_REQUEST_ID:= FND_GLOBAL.CONC_REQUEST_ID;
	LP_BATCH_ID:= P_BATCH_ID;
	  P_ORGANIZATION_ID1:= P_ORGANIZATION_ID;


     DECLARE
      L_PROCESS_ENABLED_FLAG MTL_PARAMETERS.PROCESS_ENABLED_FLAG%TYPE;
      L_ORGANIZATION_CODE MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
    BEGIN
       P_DESCRIPTION_v:=P_DESCRIPTION;
P_WORK_ORDER_ID_v:=P_WORK_ORDER_ID;
P_ITEM_TYPE_v:=P_ITEM_TYPE;
P_ITEM_ID_v:=P_ITEM_ID;
P_CATEGORY_SET_ID_v:=P_CATEGORY_SET_ID;
P_CATEGORY_ID_v:=P_CATEGORY_ID;
P_PROJECT_ID_v:=P_PROJECT_ID;
P_ADJUSTMENT_ACCOUNT_v:=P_ADJUSTMENT_ACCOUNT;
P_CUTOFF_DATE_v:=P_CUTOFF_DATE;
      SELECT
        NVL(PROCESS_ENABLED_FLAG
           ,'N'),
        ORGANIZATION_CODE
      INTO L_PROCESS_ENABLED_FLAG,L_ORGANIZATION_CODE
      FROM
        MTL_PARAMETERS
      WHERE ORGANIZATION_ID = P_ORGANIZATION_ID1;

      IF NVL(L_PROCESS_ENABLED_FLAG
         ,'N') = 'Y' THEN
        FND_MESSAGE.SET_NAME('CST'
                            ,'CST_PROCESS_ORG_ERROR');
        FND_MESSAGE.SET_TOKEN('ORGCODE'
                             ,L_ORGANIZATION_CODE);
        /*SRW.MESSAGE('2001'
                   ,'BOM_CSTRIVTW_XMLP_PKG' || FND_MESSAGE.GET || ')')*/NULL;

        RETURN (FALSE);

      END IF;
    END;
    DECLARE
      L_FCN_CURRENCY VARCHAR2(15);
    BEGIN

      SELECT
        SOB.CURRENCY_CODE
      INTO L_FCN_CURRENCY
      FROM
        GL_SETS_OF_BOOKS SOB,
        ORG_ORGANIZATION_DEFINITIONS OOD
      WHERE OOD.ORGANIZATION_ID = P_ORGANIZATION_ID1
        AND SOB.SET_OF_BOOKS_ID = OOD.SET_OF_BOOKS_ID;
      P_CURRENCY_CODE := L_FCN_CURRENCY;
      SELECT
        O.ORGANIZATION_NAME,
        O.ORGANIZATION_CODE,
        NVL(MINIMUM_ACCOUNTABLE_UNIT
           ,POWER(10
                ,NVL(-PRECISION
                   ,0)))
      INTO CP_ORG_NAME,CP_ORG_CODE,ROUND_UNIT
      FROM
        ORG_ORGANIZATION_DEFINITIONS O,
        FND_CURRENCIES FC
      WHERE FC.CURRENCY_CODE = P_CURRENCY_CODE
        AND O.ORGANIZATION_ID = P_ORGANIZATION_ID1;

    END;
    DECLARE
      L_BATCH_ID NUMBER;
      L_RETCODE NUMBER:=0;
      L_USER_ID NUMBER;
      L_LOGIN_ID NUMBER;
      L_PROG_APPL_ID NUMBER;
      L_PROG_ID NUMBER;
      L_ERRBUF VARCHAR2(240);
      PROC_ERROR EXCEPTION;
    BEGIN


      IF (P_CONC_REQUEST_ID IS NOT NULL) THEN

	SELECT
          NVL(REQUESTED_BY
             ,-1),
          NVL(CONC_LOGIN_ID
             ,-1),
          NVL(PROGRAM_APPLICATION_ID
             ,-1),
          NVL(CONCURRENT_PROGRAM_ID
             ,-1)
        INTO L_USER_ID,L_LOGIN_ID,L_PROG_APPL_ID,L_PROG_ID
	FROM
          FND_CONCURRENT_REQUESTS
        WHERE REQUEST_ID = P_CONC_REQUEST_ID
          AND ROWNUM = 1;

      END IF;



      IF (P_TRANSFER_IPV = 1) THEN
        L_BATCH_ID := CSTPPIPV.TRF_INVOICE_TO_WIP(ERRBUF => L_ERRBUF
                                                 ,RETCODE => L_RETCODE
                                                 ,P_ORGANIZATION_ID => P_ORGANIZATION_ID1
                                                 ,P_DESCRIPTION => P_DESCRIPTION
                                                 ,P_WORK_ORDER_ID => P_WORK_ORDER_ID
                                                 ,P_ITEM_TYPE => P_ITEM_TYPE
                                                 ,P_ITEM_OPTION => P_ITEM_OPTION
                                                 ,P_SPECIFIC_ITEM_ID => P_ITEM_ID
                                                 ,P_CATEGORY_SET_ID => P_CATEGORY_SET_ID
                                                 ,P_CATEGORY_ID => P_CATEGORY_ID
                                                 ,P_PROJECT_ID => P_PROJECT_ID
                                                 ,P_ADJ_ACCOUNT => P_ADJUSTMENT_ACCOUNT
                                                 ,P_CUTOFF_DATE => P_CUTOFF_DATE
                                                 ,P_TRANSACTION_PROCESS_MODE => P_TRANSACTION_PROCESS_MODE
                                                 ,P_REQUEST_ID => P_CONC_REQUEST_ID
                                                 ,P_USER_ID => L_USER_ID
                                                 ,P_LOGIN_ID => L_LOGIN_ID
                                                 ,P_PROG_APPL_ID => L_PROG_APPL_ID
                                                 ,P_PROG_ID => L_PROG_ID);



        IF L_RETCODE <> 0 THEN
          RAISE PROC_ERROR;
        END IF;
        --P_BATCH_ID := L_BATCH_ID;
        LP_BATCH_ID := L_BATCH_ID;
      END IF;

      IF (P_PRINT_REPORT = 2) THEN
        /*SRW.SET_MAXROW('Q_IPV'
                      ,0)*/NULL;
      ELSE
        NULL;
        IF (P_TRANSFER_IPV = 2) THEN
          SELECT
            DESCRIPTION,
            WIP_ENTITY_ID,
            ITEM_TYPE,
            SPECIFIC_ITEM_ID,
            CATEGORY_SET_ID,
            CATEGORY_ID,
            SPECIFIC_PROJECT_ID,
            ADJUSTMENT_ACCOUNT,
            TO_CHAR(CUTOFF_DATE
                   ,'YYYY/MM/DD HH24:MI:SS')
          /*INTO  P_DESCRIPTION,
          	P_WORK_ORDER_ID,
          	P_ITEM_TYPE,
          	P_ITEM_ID,
          	P_CATEGORY_SET_ID,
          	P_CATEGORY_ID,
          	P_PROJECT_ID,
          	P_ADJUSTMENT_ACCOUNT,
          	P_CUTOFF_DATE*/
          INTO  	P_DESCRIPTION_v,
	            	P_WORK_ORDER_ID_v,
	            	P_ITEM_TYPE_v,
	            	P_ITEM_ID_v,
	            	P_CATEGORY_SET_ID_v,
	            	P_CATEGORY_ID_v,
	            	P_PROJECT_ID_v,
	            	P_ADJUSTMENT_ACCOUNT_v,
          		P_CUTOFF_DATE_v
          FROM
            CST_AP_VARIANCE_BATCHES
          WHERE BATCH_ID = LP_BATCH_ID;
          IF (P_ITEM_ID_v IS NOT NULL) THEN
            P_ITEM_OPTION_v := 2;
          ELSE
            IF (P_CATEGORY_ID_v IS NOT NULL) THEN
              P_ITEM_OPTION_v := 5;
            ELSE
              P_ITEM_OPTION_v := 1;
            END IF;
          END IF;

        END IF;
        /*SRW.MESSAGE('999'
                   ,'Description: ' || P_DESCRIPTION)*/NULL;
        IF (P_WORK_ORDER_ID_V IS NOT NULL) THEN
          SELECT
            WIP_ENTITY_NAME
          INTO CP_WORK_ORDER
          FROM
            WIP_ENTITIES WE
          WHERE WIP_ENTITY_ID = P_WORK_ORDER_ID_v;

        END IF;
        /*SRW.MESSAGE('999'
                   ,'Specific Work Order: ' || CP_WORK_ORDER)*/NULL;

        IF (P_ITEM_TYPE_v IS NOT NULL) THEN
          SELECT
            MEANING
          INTO CP_ITEM_TYPE
          FROM
            MFG_LOOKUPS
          WHERE LOOKUP_TYPE = 'CST_IPV_WIP_ITEM_TYPE'
            AND LOOKUP_CODE = P_ITEM_TYPE_v;

        END IF;
        /*SRW.MESSAGE('999'
                   ,'IPV Item Type: ' || CP_ITEM_TYPE)*/NULL;
        IF (P_ITEM_OPTION_v IS NOT NULL) THEN
          SELECT
            MEANING
          INTO CP_ITEM_RANGE
          FROM
            MFG_LOOKUPS
          WHERE LOOKUP_TYPE = 'CST_ITEM_RANGE'
            AND LOOKUP_CODE = P_ITEM_OPTION_V;
        END IF;
        /*SRW.MESSAGE('999'
                   ,'Item Range: ' || CP_ITEM_TYPE)*/NULL;
        IF (P_ITEM_ID_v IS NOT NULL) THEN
          SELECT
            CONCATENATED_SEGMENTS
          INTO CP_ITEM
          FROM
            MTL_SYSTEM_ITEMS_KFV
          WHERE ORGANIZATION_ID = P_ORGANIZATION_ID1
            AND INVENTORY_ITEM_ID = P_ITEM_ID_v;
        END IF;
        /*SRW.MESSAGE('999'
                   ,'Specific Item: ' || CP_ITEM)*/NULL;
        IF (P_CATEGORY_SET_ID_v IS NOT NULL) THEN
          SELECT
            CATEGORY_SET_NAME
          INTO CP_CATEGORY_SET
          FROM
            MTL_CATEGORY_SETS
          WHERE CATEGORY_SET_ID = P_CATEGORY_SET_ID_v;
        END IF;
        /*SRW.MESSAGE('999'
                   ,'Category Set: ' || CP_CATEGORY_SET)*/NULL;
        IF (P_CATEGORY_ID_v IS NOT NULL) THEN
          SELECT
            CONCATENATED_SEGMENTS
          INTO CP_CATEGORY
          FROM
            MTL_CATEGORIES_KFV
          WHERE CATEGORY_ID = P_CATEGORY_ID_v;
        END IF;
        /*SRW.MESSAGE('999'
                   ,'Specific Category: ' || CP_CATEGORY)*/NULL;
        IF (P_PROJECT_ID_v IS NOT NULL) THEN
          SELECT
            NAME
          INTO CP_PROJECT
          FROM
            PA_PROJECTS_ALL
          WHERE PROJECT_ID = P_PROJECT_ID_v;
        END IF;
        /*SRW.MESSAGE('999'
                   ,'Specific Project: ' || CP_PROJECT)*/NULL;
        IF (P_ADJUSTMENT_ACCOUNT_v IS NOT NULL) THEN
          SELECT
            CONCATENATED_SEGMENTS
          INTO CP_ADJUSTMENT_ACCOUNT
          FROM
            GL_CODE_COMBINATIONS_KFV
          WHERE CODE_COMBINATION_ID = P_ADJUSTMENT_ACCOUNT_v;
        END IF;
        /*SRW.MESSAGE('999'
                   ,'Adjustment Account: ' || CP_ADJUSTMENT_ACCOUNT)*/NULL;
        /*SRW.MESSAGE('999'
                   ,'Cutoff Date: ' || P_CUTOFF_DATE)*/NULL;
      END IF;

    EXCEPTION
      WHEN PROC_ERROR THEN
        /*SRW.MESSAGE('999'
                   ,'Shop Floor Invoice Variance Transfer Failed : ' || L_ERRBUF)*/NULL;

        ROLLBACK;
        RETURN (FALSE);
      WHEN OTHERS THEN
        /*SRW.MESSAGE('998'
                   ,'Shop Floor Invoice Variance Report Initialization Failed : ' || SQLERRM)*/NULL;

        ROLLBACK;
        RETURN (FALSE);
    END;
    BEGIN
      IF P_VIEW_COST <> 1 THEN
        FND_MESSAGE.SET_NAME('null'
                            ,'null');
        /*SRW.USER_EXIT('FND MESSAGE_DISPLAY')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
    END;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in SRWINIT')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,'FND FLEXSQL(GL#) >X')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,'FND FLEXSQL(MSTK) >X')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_SHOPFLOOR NUMBER;
    BEGIN
      L_SHOPFLOOR := 0;
      SELECT
        NVL(ITEM_TYPE
           ,0)
      INTO L_SHOPFLOOR
      FROM
        CST_AP_VARIANCE_BATCHES
      WHERE BATCH_ID = LP_BATCH_ID
        AND ROWNUM = 1;
      IF (P_TRANSACTION_PROCESS_MODE = 2 AND L_SHOPFLOOR <> 0) THEN
        NULL;
        DELETE FROM CST_AP_VARIANCE_LINES CAVL
         WHERE BATCH_ID = LP_BATCH_ID;
        DELETE FROM CST_AP_VARIANCE_HEADERS CAVH
         WHERE BATCH_ID = LP_BATCH_ID;
        DELETE FROM CST_AP_VARIANCE_BATCHES CAVB
         WHERE BATCH_ID = LP_BATCH_ID;
      END IF;
    END;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION ITEM_PSEGFORMULA(ITEM_SEGMENT IN VARCHAR2
                           ,ITEM_NAME IN VARCHAR2
                           ,ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(ITEM_SEGMENT)*/NULL;
    /*SRW.REFERENCE(ITEM_NAME)*/NULL;
    RETURN (ITEM_PSEG);
  END ITEM_PSEGFORMULA;

  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CP_ORG_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ORG_NAME;
  END CP_ORG_NAME_P;

  FUNCTION CP_ORG_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ORG_CODE;
  END CP_ORG_CODE_P;

  FUNCTION CP_WORK_ORDER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_WORK_ORDER;
  END CP_WORK_ORDER_P;

  FUNCTION CP_ITEM_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ITEM_TYPE;
  END CP_ITEM_TYPE_P;

  FUNCTION CP_ITEM_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ITEM_RANGE;
  END CP_ITEM_RANGE_P;

  FUNCTION CP_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ITEM;
  END CP_ITEM_P;

  FUNCTION CP_CATEGORY_SET_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CATEGORY_SET;
  END CP_CATEGORY_SET_P;

  FUNCTION CP_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CATEGORY;
  END CP_CATEGORY_P;

  FUNCTION CP_PROJECT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PROJECT;
  END CP_PROJECT_P;

  FUNCTION CP_ADJUSTMENT_ACCOUNT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ADJUSTMENT_ACCOUNT;
  END CP_ADJUSTMENT_ACCOUNT_P;

END BOM_CSTRIVTW_XMLP_PKG;



/
