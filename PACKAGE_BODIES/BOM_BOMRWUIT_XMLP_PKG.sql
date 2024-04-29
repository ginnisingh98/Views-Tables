--------------------------------------------------------
--  DDL for Package Body BOM_BOMRWUIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOMRWUIT_XMLP_PKG" AS
/* $Header: BOMRWUITB.pls 120.1 2008/01/07 07:12:06 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      T_ORG_CODE_LIST INV_ORGHIERARCHY_PVT.ORGID_TBL_TYPE;
      L_ORG_NAME VARCHAR2(60);
      N NUMBER := 0;
      L_ERR_MSG VARCHAR(80);
      L_ERR_CODE NUMBER;
      L_STR VARCHAR(2000);
      L_SORT_CODE VARCHAR(10) := '0001';
      L_SEQUENCE_ID NUMBER;
      L_BOM_OR_ENG NUMBER;
      L_ITEM_NUMBER VARCHAR(245);
      ITEM_ID_NULL EXCEPTION;
      TEMP_PROC_ERR EXCEPTION;
      IMPLOSION_ERR EXCEPTION;
      TABLE_NAME VARCHAR(20);
      temp_count number(3):= 0;
      temp_exp EXCEPTION;

    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      LP_ORG_ID := P_ORG_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF P_REPORT_OPTION = 1 AND P_ITEM_ID IS NULL THEN
        FND_MESSAGE.SET_NAME('null'
                            ,'MFG_REQUIRED_VALUE');
        FND_MESSAGE.SET_TOKEN('ENTITY'
                             ,'specific item');
        P_MSG_BUF := FND_MESSAGE.GET;
        /*SRW.MESSAGE('999'
                   ,P_MSG_BUF)*/NULL;
        RAISE ITEM_ID_NULL;
      END IF;
      P_QTY_PRECISION := FND_PROFILE.VALUE('REPORT_QUANTITY_PRECISION');
      TABLE_NAME := 'IMPLOSION_TEMP_S:';
      SELECT
        BOM_IMPLOSION_TEMP_S.NEXTVAL
      INTO L_SEQUENCE_ID
      FROM
        DUAL;
      P_SEQUENCE_ID := L_SEQUENCE_ID;
      IF P_ENG_BILL_FLAG = 'BOM' THEN
        L_BOM_OR_ENG := 1;
      ELSE
        L_BOM_OR_ENG := 2;
      END IF;
      TABLE_NAME := 'ITEM_FLEXFIELDS:';
      IF P_REPORT_OPTION = 1 THEN
        SELECT
          ITEM_NUMBER
        INTO L_ITEM_NUMBER
        FROM
          MTL_ITEM_FLEXFIELDS
        WHERE ITEM_ID = P_ITEM_ID
          AND ORGANIZATION_ID = LP_ORG_ID;
        P_SPECIFIC_ITEM := L_ITEM_NUMBER;
      END IF;
      TABLE_NAME := 'USER_EXIT_ITEM:';
      IF P_REPORT_OPTION = 2 THEN
        IF (P_ITEM_FROM IS NOT NULL) THEN
          IF (P_ITEM_TO IS NOT NULL) THEN
            NULL;
          ELSE
            NULL;
          END IF;
        ELSE
          IF (P_ITEM_TO IS NOT NULL) THEN
            NULL;
          END IF;
        END IF;
        TABLE_NAME := 'USER_EXIT_CAT:';
        IF (P_CAT_FROM IS NOT NULL) THEN
          IF (P_CAT_TO IS NOT NULL) THEN
            NULL;
          ELSE
            NULL;
          END IF;
        ELSE
          IF (P_CAT_TO IS NOT NULL) THEN
            NULL;
          END IF;
        END IF;
      END IF;
      IF P_DATE IS NULL THEN
        P_DATE := TO_CHAR(SYSDATE
                         ,'YYYY/MM/DD HH24:MI:SS');
      END IF;
      TABLE_NAME := 'IMPLOSION_TEMP:';
      IF P_ALL_ORGS = 1 THEN
        FOR C1 IN (SELECT
                     ORGANIZATION_ID
                   FROM
                     MTL_PARAMETERS MP
                   WHERE MASTER_ORGANIZATION_ID = (
                     SELECT
                       MASTER_ORGANIZATION_ID
                     FROM
                       MTL_PARAMETERS
                     WHERE ORGANIZATION_ID = LP_ORG_ID )
                     AND MP.ORGANIZATION_ID IN (
                     SELECT
                       ORGANIZATION_ID
                     FROM
                       ORG_ACCESS_VIEW
                     WHERE RESPONSIBILITY_ID = FND_PROFILE.VALUE('RESP_ID')
                       AND RESP_APPLICATION_ID = FND_PROFILE.VALUE('RESP_APPL_ID') )) LOOP
          N := N + 1;
          T_ORG_CODE_LIST(N) := C1.ORGANIZATION_ID;
        END LOOP;
      ELSIF P_ALL_ORGS = 2 THEN
        IF P_ORG_HIERARCHY IS NOT NULL THEN
          INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST(P_ORG_HIERARCHY
                                                 ,LP_ORG_ID
                                                 ,T_ORG_CODE_LIST);
        ELSIF P_ORG_HIERARCHY IS NULL THEN
          T_ORG_CODE_LIST(1) := LP_ORG_ID;
        END IF;
      END IF;
      FOR I IN T_ORG_CODE_LIST.FIRST .. T_ORG_CODE_LIST.LAST LOOP
        LP_ORG_ID := T_ORG_CODE_LIST(I);
        L_STR := 'INSERT INTO BOM_IMPLOSION_TEMP (
                                   SEQUENCE_ID,LOWEST_ITEM_ID,CURRENT_ITEM_ID,PARENT_ITEM_ID,
                                   CURRENT_LEVEL,SORT_CODE,CURRENT_ASSEMBLY_TYPE,
                                   LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,
                                   REQUEST_ID,ORGANIZATION_ID) ';
        IF P_REPORT_OPTION = 1 THEN
          INSERT INTO BOM_IMPLOSION_TEMP
            (SEQUENCE_ID
            ,LOWEST_ITEM_ID
            ,CURRENT_ITEM_ID
            ,PARENT_ITEM_ID
            ,CURRENT_LEVEL
            ,SORT_CODE
            ,CURRENT_ASSEMBLY_TYPE
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,REQUEST_ID
            ,ORGANIZATION_ID)
          VALUES   (L_SEQUENCE_ID
            ,P_ITEM_ID
            ,P_ITEM_ID
            ,P_ITEM_ID
            ,0
            ,L_SORT_CODE
            ,NULL
            ,SYSDATE
            ,1
            ,SYSDATE
            ,1
            ,P_CONC_REQUEST_ID
            ,LP_ORG_ID);
        ELSE
          L_STR := L_STR || 'SELECT /*+ ORDERED */ DISTINCT ' || TO_CHAR(L_SEQUENCE_ID) || ', MSI.INVENTORY_ITEM_ID,MSI.INVENTORY_ITEM_ID,MSI.INVENTORY_ITEM_ID
                                                 ,0, ' || L_SORT_CODE || ', ' || 'NULL' || ', SYSDATE, 1, SYSDATE, 1,' || TO_CHAR(P_CONC_REQUEST_ID) || ', ' || TO_CHAR(LP_ORG_ID) || '  FROM MTL_SYSTEM_ITEMS MSI,
                                                     MTL_ITEM_CATEGORIES MIC,
                                                     MTL_CATEGORIES MC
                                                 WHERE ' || P_ASS_BETWEEN || '
                                                 AND    MSI.BOM_ENABLED_FLAG = ''Y''
                                                 AND    MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID
                                                 AND    MSI.ORGANIZATION_ID = ' || TO_CHAR(LP_ORG_ID) || '
                                                 AND    MIC.ORGANIZATION_ID = ' || TO_CHAR(LP_ORG_ID) || '
                                                 AND    MIC.CATEGORY_SET_ID = ' || TO_CHAR(P_SET_ID) || '
                                                 AND    MIC.CATEGORY_ID = MC.CATEGORY_ID
                                                 AND    MC.STRUCTURE_ID =
                                                 ' || TO_CHAR(P_CATEGORY_STRUCTURE_ID) || '
                                                 AND    ' || P_CAT_BETWEEN;
          EXECUTE IMMEDIATE
            L_STR;
        END IF;
        IMPLOSION(L_SEQUENCE_ID
                 ,L_BOM_OR_ENG
                 ,LP_ORG_ID
                 ,P_IMPLEMENTED
                 ,P_DATE_OPTION
                 ,P_LEVEL
                 ,P_DATE
                 ,L_ERR_MSG
                 ,L_ERR_CODE);
        IF L_ERR_CODE <> 0 THEN
          RAISE IMPLOSION_ERR;
        END IF;
      END LOOP;
      LP_QTY_PRECISION:=get_precision(P_QTY_PRECISION);
      P_DATE_1:=P_DATE;
      RETURN (TRUE);
    EXCEPTION
      WHEN temp_exp THEN
        --RAISE_APPLICATION_ERROR(-20101,TABLE_NAME ||temp_count);
	null;
      WHEN ITEM_ID_NULL THEN
        /*SRW.MESSAGE('6','aborting...')*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,TABLE_NAME || SQLERRM);
      WHEN IMPLOSION_ERR THEN
        /*SRW.MESSAGE('4000'
                   ,L_ERR_MSG)*/NULL;RAISE_APPLICATION_ERROR(-20102,TABLE_NAME || SQLERRM);
        RETURN (FALSE);
      WHEN /*SRW.DO_SQL_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE('1000'
                   ,TABLE_NAME || SQLERRM)*/NULL;RAISE_APPLICATION_ERROR(-20103,TABLE_NAME || SQLERRM);
        RETURN (FALSE);

    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      ROLLBACK;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION GET_STATUS(REVISED_ITEM_SEQUENCE_ID IN NUMBER
                     ,IMPLEMENTED_FLAG IN NUMBER
                     ,NOTICE IN VARCHAR2) RETURN VARCHAR2 IS
    STATUS_NAME VARCHAR2(80);
  BEGIN
    IF REVISED_ITEM_SEQUENCE_ID IS NULL THEN
      IF (IMPLEMENTED_FLAG = 1 AND NOTICE IS NOT NULL) THEN
        SELECT
          ML.MEANING
        INTO STATUS_NAME
        FROM
          MFG_LOOKUPS ML
        WHERE ML.LOOKUP_CODE = 6
          AND ML.LOOKUP_TYPE = 'ECG_ECN_STATUS';
      END IF;
    ELSE
      SELECT
        ML.MEANING
      INTO STATUS_NAME
      FROM
        ENG_REVISED_ITEMS ERI,
        MFG_LOOKUPS ML
      WHERE ERI.REVISED_ITEM_SEQUENCE_ID = REVISED_ITEM_SEQUENCE_ID
        AND ML.LOOKUP_CODE = ERI.STATUS_TYPE
        AND ML.LOOKUP_TYPE = 'ECG_ECN_STATUS';
    END IF;
    RETURN (STATUS_NAME);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('');
  END GET_STATUS;

  FUNCTION GET_ORGCODE(ORGANIZATION_ID IN NUMBER) RETURN VARCHAR2 IS
    ORG_CODE VARCHAR2(3);
  BEGIN
    IF ORGANIZATION_ID IS NOT NULL THEN
      SELECT
        ORG.ORGANIZATION_CODE
      INTO ORG_CODE
      FROM
        ORG_ORGANIZATION_DEFINITIONS ORG
      WHERE ORG.ORGANIZATION_ID = GET_ORGCODE.ORGANIZATION_ID;
    ELSE
      RETURN ('');
    END IF;
    RETURN (ORG_CODE);
  END GET_ORGCODE;

  FUNCTION CF_ALL_ORGSFORMULA RETURN CHAR IS
  BEGIN
    IF P_ALL_ORGS = 1 THEN
      RETURN ('Yes');
    ELSE
      RETURN ('No');
    END IF;
  END CF_ALL_ORGSFORMULA;

  PROCEDURE IMPLODER_USEREXIT(SEQUENCE_ID IN NUMBER
                             ,ENG_MFG_FLAG IN NUMBER
                             ,ORG_ID IN NUMBER
                             ,IMPL_FLAG IN NUMBER
                             ,DISPLAY_OPTION IN NUMBER
                             ,LEVELS_TO_IMPLODE IN NUMBER
                             ,ITEM_ID IN NUMBER
                             ,IMPL_DATE IN VARCHAR2
                             ,ERR_MSG OUT NOCOPY VARCHAR2
                             ,ERR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin BOMPIMPL.IMPLODER_USEREXIT(:SEQUENCE_ID, :ENG_MFG_FLAG, :ORG_ID, :IMPL_FLAG, :DISPLAY_OPTION, :LEVELS_TO_IMPLODE, :ITEM_ID, :IMPL_DATE, :ERR_MSG, :ERR_CODE); end;');
    STPROC.BIND_I(SEQUENCE_ID);
    STPROC.BIND_I(ENG_MFG_FLAG);
    STPROC.BIND_I(ORG_ID);
    STPROC.BIND_I(IMPL_FLAG);
    STPROC.BIND_I(DISPLAY_OPTION);
    STPROC.BIND_I(LEVELS_TO_IMPLODE);
    STPROC.BIND_I(ITEM_ID);
    STPROC.BIND_I(IMPL_DATE);
    STPROC.BIND_O(ERR_MSG);
    STPROC.BIND_O(ERR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(9
                   ,ERR_MSG);
    STPROC.RETRIEVE(10
                   ,ERR_CODE);*/
    BOMPIMPL.IMPLODER_USEREXIT(SEQUENCE_ID, ENG_MFG_FLAG, ORG_ID, IMPL_FLAG, DISPLAY_OPTION, LEVELS_TO_IMPLODE, ITEM_ID, IMPL_DATE, ERR_MSG, ERR_CODE);
  END IMPLODER_USEREXIT;

  PROCEDURE IMPLOSION(SEQUENCE_ID IN NUMBER
                     ,ENG_MFG_FLAG IN NUMBER
                     ,ORG_ID IN NUMBER
                     ,IMPL_FLAG IN NUMBER
                     ,DISPLAY_OPTION IN NUMBER
                     ,LEVELS_TO_IMPLODE IN NUMBER
                     ,IMPL_DATE IN VARCHAR2
                     ,ERR_MSG OUT NOCOPY VARCHAR2
                     ,ERR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin BOMPIMPL.IMPLOSION(:SEQUENCE_ID, :ENG_MFG_FLAG, :ORG_ID, :IMPL_FLAG, :DISPLAY_OPTION, :LEVELS_TO_IMPLODE, :IMPL_DATE, :ERR_MSG, :ERR_CODE); end;');
    STPROC.BIND_I(SEQUENCE_ID);
    STPROC.BIND_I(ENG_MFG_FLAG);
    STPROC.BIND_I(ORG_ID);
    STPROC.BIND_I(IMPL_FLAG);
    STPROC.BIND_I(DISPLAY_OPTION);
    STPROC.BIND_I(LEVELS_TO_IMPLODE);
    STPROC.BIND_I(IMPL_DATE);
    STPROC.BIND_O(ERR_MSG);
    STPROC.BIND_O(ERR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(8
                   ,ERR_MSG);
    STPROC.RETRIEVE(9
                   ,ERR_CODE);*/


  BOMPIMPL.IMPLOSION(SEQUENCE_ID, ENG_MFG_FLAG, ORG_ID, IMPL_FLAG, DISPLAY_OPTION, LEVELS_TO_IMPLODE, IMPL_DATE, ERR_MSG, ERR_CODE);
END IMPLOSION;

  PROCEDURE SL_IMPLODER(SEQUENCE_ID IN NUMBER
                       ,ENG_MFG_FLAG IN NUMBER
                       ,ORG_ID IN NUMBER
                       ,IMPL_FLAG IN NUMBER
                       ,DISPLAY_OPTION IN NUMBER
                       ,IMPL_DATE IN VARCHAR2
                       ,ERR_MSG OUT NOCOPY VARCHAR2
                       ,ERROR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin BOMPIMPL.SL_IMPLODER(:SEQUENCE_ID, :ENG_MFG_FLAG, :ORG_ID, :IMPL_FLAG, :DISPLAY_OPTION, :IMPL_DATE, :ERR_MSG, :ERROR_CODE); end;');
    STPROC.BIND_I(SEQUENCE_ID);
    STPROC.BIND_I(ENG_MFG_FLAG);
    STPROC.BIND_I(ORG_ID);
    STPROC.BIND_I(IMPL_FLAG);
    STPROC.BIND_I(DISPLAY_OPTION);
    STPROC.BIND_I(IMPL_DATE);
    STPROC.BIND_O(ERR_MSG);
    STPROC.BIND_O(ERROR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(7
                   ,ERR_MSG);
    STPROC.RETRIEVE(8
                   ,ERROR_CODE);*/

    BOMPIMPL.SL_IMPLODER(SEQUENCE_ID, ENG_MFG_FLAG, ORG_ID, IMPL_FLAG, DISPLAY_OPTION, IMPL_DATE, ERR_MSG, ERROR_CODE);
  END SL_IMPLODER;

  PROCEDURE ML_IMPLODER(SEQUENCE_ID IN NUMBER
                       ,ENG_MFG_FLAG IN NUMBER
                       ,ORG_ID IN NUMBER
                       ,IMPL_FLAG IN NUMBER
                       ,A_LEVELS_TO_IMPLODE IN NUMBER
                       ,IMPL_DATE IN VARCHAR2
                       ,ERR_MSG OUT NOCOPY VARCHAR2
                       ,ERROR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
    /*STPROC.INIT('begin BOMPIMPL.ML_IMPLODER(:SEQUENCE_ID, :ENG_MFG_FLAG, :ORG_ID, :IMPL_FLAG, :A_LEVELS_TO_IMPLODE, :IMPL_DATE, :ERR_MSG, :ERROR_CODE); end;');
    STPROC.BIND_I(SEQUENCE_ID);
    STPROC.BIND_I(ENG_MFG_FLAG);
    STPROC.BIND_I(ORG_ID);
    STPROC.BIND_I(IMPL_FLAG);
    STPROC.BIND_I(A_LEVELS_TO_IMPLODE);
    STPROC.BIND_I(IMPL_DATE);
    STPROC.BIND_O(ERR_MSG);
    STPROC.BIND_O(ERROR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(7
                   ,ERR_MSG);
    STPROC.RETRIEVE(8
                   ,ERROR_CODE);*/
    BOMPIMPL.ML_IMPLODER(SEQUENCE_ID, ENG_MFG_FLAG, ORG_ID, IMPL_FLAG, A_LEVELS_TO_IMPLODE, IMPL_DATE, ERR_MSG, ERROR_CODE);
  END ML_IMPLODER;

function get_precision(qty_precision in number) return VARCHAR2 is
begin

if qty_precision = 0 then return('999G999G999G990');

elsif qty_precision = 1 then return('999G999G999G990D0');

elsif qty_precision = 3 then return('999G999G999G990D000');

elsif qty_precision = 4 then return('999G999G999G990D0000');

elsif qty_precision = 5 then return('999G999G999G990D00000');

elsif qty_precision = 6 then  return('999G999G999G990D000000');

else return('999G999G999G990D00');

end if;

end;

END BOM_BOMRWUIT_XMLP_PKG;


/
