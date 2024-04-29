--------------------------------------------------------
--  DDL for Package Body BOM_BOMRASSY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOMRASSY_XMLP_PKG" AS
/* $Header: BOMRASSYB.pls 120.0 2007/12/28 09:45:42 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    T_ORG_CODE_LIST INV_ORGHIERARCHY_PVT.ORGID_TBL_TYPE;
    L_ORG_NAME VARCHAR2(60);
    N NUMBER := 0;
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK" NUM=":P_STRUCT_ASSY"
                                   APPL_SHORT_NAME="INV" OUTPUT=":P_ASSEMBLY"
                                   MODE="SELECT" DISPLAY="ALL" TABLEALIAS="item1"')*/NULL;
      IF P_ITEM_FROM IS NOT NULL THEN
        IF P_ITEM_TO IS NOT NULL THEN
          NULL;
        ELSE
          NULL;
        END IF;
      ELSE
        IF P_ITEM_TO IS NOT NULL THEN
          NULL;
        END IF;
      END IF;
      IF P_CATG_FROM IS NOT NULL THEN
        IF P_CATG_TO IS NOT NULL THEN
          NULL;
        ELSE
          NULL;
        END IF;
      ELSE
        IF P_CATG_TO IS NOT NULL THEN
          NULL;
        END IF;
      END IF;
      IF P_ALL_ORGS = 1 THEN
        SELECT
          BOM_LISTS_S.NEXTVAL
        INTO P_SEQUENCE_ID
        FROM
          DUAL;
        FOR C1 IN (SELECT
                     ORGANIZATION_ID
                   FROM
                     MTL_PARAMETERS MP
                   WHERE MASTER_ORGANIZATION_ID = (
                     SELECT
                       MASTER_ORGANIZATION_ID
                     FROM
                       MTL_PARAMETERS
                     WHERE ORGANIZATION_ID = P_ORG_ID )
                     AND MP.ORGANIZATION_ID IN (
                     SELECT
                       ORGANIZATION_ID
                     FROM
                       ORG_ACCESS_VIEW
                     WHERE RESPONSIBILITY_ID = FND_PROFILE.VALUE('RESP_ID')
                       AND RESP_APPLICATION_ID = FND_PROFILE.VALUE('RESP_APPL_ID') )) LOOP
          N := N + 1;
          INSERT INTO BOM_LISTS
            (ORGANIZATION_ID
            ,SEQUENCE_ID
            ,ALTERNATE_DESIGNATOR)
          VALUES   (C1.ORGANIZATION_ID
            ,P_SEQUENCE_ID
            ,C1.ORGANIZATION_ID);
          T_ORG_CODE_LIST(N) := C1.ORGANIZATION_ID;
        END LOOP;
      ELSIF P_ALL_ORGS = 2 THEN
        IF P_ORG_HIERARCHY IS NOT NULL THEN
          INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST(P_ORG_HIERARCHY
                                                 ,P_ORG_ID
                                                 ,T_ORG_CODE_LIST);
          SELECT
            BOM_LISTS_S.NEXTVAL
          INTO P_SEQUENCE_ID
          FROM
            DUAL;
          FOR I IN T_ORG_CODE_LIST.FIRST .. T_ORG_CODE_LIST.LAST LOOP
            INSERT INTO BOM_LISTS
              (ORGANIZATION_ID
              ,SEQUENCE_ID
              ,ALTERNATE_DESIGNATOR)
            VALUES   (T_ORG_CODE_LIST(I)
              ,P_SEQUENCE_ID
              ,T_ORG_CODE_LIST(I));
          END LOOP;
        ELSIF P_ORG_HIERARCHY IS NULL THEN
          SELECT
            BOM_LISTS_S.NEXTVAL
          INTO P_SEQUENCE_ID
          FROM
            DUAL;
          INSERT INTO BOM_LISTS
            (ORGANIZATION_ID
            ,SEQUENCE_ID)
          VALUES   (P_ORG_ID
            ,P_SEQUENCE_ID);
        END IF;
      ELSE
        SELECT
          BOM_LISTS_S.NEXTVAL
        INTO P_SEQUENCE_ID
        FROM
          DUAL;
        INSERT INTO BOM_LISTS
          (ORGANIZATION_ID
          ,SEQUENCE_ID)
        VALUES   (P_ORG_ID
          ,P_SEQUENCE_ID);
      END IF;
      IF P_ALL_ORGS = 1 THEN
        P_ALL_ORGS := 'Yes';
      ELSE
        P_ALL_ORGS := 'No';
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE('2000'
                   ,SQLERRM)*/NULL;
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DELETE FROM BOM_LISTS
     WHERE SEQUENCE_ID = P_SEQUENCE_ID;
    COMMIT;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION GET_COMMON_ORG(COMMON_ORGANIZATION_ID IN NUMBER) RETURN VARCHAR2 IS
    COMMON_ORG VARCHAR2(3);
  BEGIN
    IF COMMON_ORGANIZATION_ID IS NULL THEN
      NULL;
    ELSE
      SELECT
        ORGANIZATION_CODE
      INTO COMMON_ORG
      FROM
        ORG_ORGANIZATION_DEFINITIONS
      WHERE ORGANIZATION_ID = COMMON_ORGANIZATION_ID;
    END IF;
    RETURN (COMMON_ORG);
  END GET_COMMON_ORG;

  FUNCTION ORG_CODEFORMULA(ORG_ID IN NUMBER) RETURN CHAR IS
    ORG_CODE VARCHAR2(3);
  BEGIN
    SELECT
      ORGANIZATION_CODE
    INTO ORG_CODE
    FROM
      ORG_ORGANIZATION_DEFINITIONS ORG
    WHERE ORG.ORGANIZATION_ID = ORG_ID;
    RETURN (ORG_CODE);
  END ORG_CODEFORMULA;

END BOM_BOMRASSY_XMLP_PKG;


/
