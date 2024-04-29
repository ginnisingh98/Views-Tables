--------------------------------------------------------
--  DDL for Package Body BOM_BOMRBOMS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BOMRBOMS_XMLP_PKG" AS
/* $Header: BOMRBOMSB.pls 120.5.12010000.4 2010/02/18 11:11:57 agoginen ship $ */
 FUNCTION BEFOREREPORT RETURN BOOLEAN IS
   ecode    NUMBER(38);
   emesg VARCHAR2(250);
  BEGIN
    DECLARE
      L_ORGANIZATION_NAME VARCHAR2(240);
      L_EXPLODE_OPTION VARCHAR2(80);
      L_RANGE_OPTION VARCHAR2(80);
      L_SPECIFIC_ITEM VARCHAR2(245);
      L_CATEGORY_SET VARCHAR2(30);
      L_YES VARCHAR2(80);
      L_NO VARCHAR2(80);
      L_ALT_OPTION VARCHAR2(80);
      L_ORDER_BY VARCHAR2(80);
      L_SEQ_ID NUMBER;
      L_STR VARCHAR2(32767);
      L_BOM_OR_ENG NUMBER;
      L_ERR_MSG VARCHAR2(80);
      L_ERR_CODE NUMBER;
      EXPLODER_ERROR EXCEPTION;
      LOOP_ERROR EXCEPTION;
      ITEM_ID_NULL EXCEPTION;
      TABLE_NAME VARCHAR2(20);
      T_ORG_CODE_LIST INV_ORGHIERARCHY_PVT.ORGID_TBL_TYPE;
      L_ORG_NAME VARCHAR2(60);
      FLAG BOOLEAN;
      N NUMBER := 0;
      L_ORG_ID NUMBER;
      CURSOR_NAME INTEGER;
      ROWS_PROCESSED INTEGER;
      P_ASS_BETWEEN VARCHAR2(1000);
      P_CAT_BETWEEN VARCHAR2(1000);
      -- Added for bug 9364923
       l_binds fnd_flex_xml_publisher_apis.bind_variables;
       x_numof_binds number;
    BEGIN
      TABLE_NAME := 'Begin_trigger';
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      LP_ORGANIZATION_ID := P_ORGANIZATION_ID;
      LP_REVISION_DATE := P_REVISION_DATE;


      LP_ALL_ORGS := P_ALL_ORGS;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      TABLE_NAME := 'Trace';
      TABLE_NAME := 'Check_specific';


      IF (P_RANGE_OPTION_TYPE = 1) AND (P_ITEM_ID IS NULL) THEN
        FND_MESSAGE.SET_NAME('null'
                            ,'MFG_REQUIRED_VALUE');
        FND_MESSAGE.SET_TOKEN('ENTITY'
                             ,'specific item');
        P_MSG_BUF := FND_MESSAGE.GET;
        /*SRW.MESSAGE('999'
                   ,P_MSG_BUF)*/NULL;
        RAISE ITEM_ID_NULL;
      END IF;


      TABLE_NAME := 'Supress_detail';

      IF P_PRINT_OPTION1_FLAG = 2 THEN
        /*SRW.SET_MAXROW('Q_ELEMENT'
                      ,0)*/NULL;
      END IF;

      TABLE_NAME := 'Ref_desg';


      IF P_PRINT_OPTION4_FLAG = 2 THEN
        /*SRW.SET_MAXROW('Q_REF_DESIG'
                      ,0)*/NULL;
      END IF;

      TABLE_NAME := 'Sub_comps';

      IF P_PRINT_OPTION5_FLAG = 2 THEN
        /*SRW.SET_MAXROW('Q_SUBS_COMPO'
                      ,0)*/NULL;
      END IF;

      TABLE_NAME := 'Org_define';


      SELECT
        O.ORGANIZATION_NAME
      INTO L_ORGANIZATION_NAME
      FROM
        ORG_ORGANIZATION_DEFINITIONS O
      WHERE O.ORGANIZATION_ID = LP_ORGANIZATION_ID;


      TABLE_NAME := 'Category_sets';

      IF P_CATEGORY_SET_ID > 0 THEN
        SELECT
          CATEGORY_SET_NAME
        INTO L_CATEGORY_SET
        FROM
          MTL_CATEGORY_SETS
        WHERE CATEGORY_SET_ID = P_CATEGORY_SET_ID;

        P_CATEGORY_SET := L_CATEGORY_SET;
      END IF;

      TABLE_NAME := 'Item_flexfields';

      IF P_ITEM_ID > 0 THEN
        SELECT
          ITEM_NUMBER
        INTO L_SPECIFIC_ITEM
        FROM
          MTL_ITEM_FLEXFIELDS
        WHERE ITEM_ID = P_ITEM_ID
          AND ORGANIZATION_ID = LP_ORGANIZATION_ID;

        P_SPECIFIC_ITEM := L_SPECIFIC_ITEM;
      END IF;

      TABLE_NAME := 'Lookups1';

      SELECT
        SUBSTR(L1.MEANING
              ,1
              ,40),
        SUBSTR(L2.MEANING
              ,1
              ,40),
        SUBSTR(L3.MEANING
              ,1
              ,40),
        SUBSTR(L4.MEANING
              ,1
              ,40)
      INTO L_EXPLODE_OPTION,L_ALT_OPTION,L_RANGE_OPTION,L_ORDER_BY
      FROM
        MFG_LOOKUPS L1,
        MFG_LOOKUPS L2,
        MFG_LOOKUPS L3,
        MFG_LOOKUPS L4
      WHERE L1.LOOKUP_TYPE = 'BOM_INQUIRY_DISPLAY_TYPE'
        AND L1.LOOKUP_CODE = P_EXPLODE_OPTION_TYPE
        AND L2.LOOKUP_TYPE = 'MCG_AUTOLOAD_OPTION'
        AND L2.LOOKUP_CODE = P_ALT_OPTION_TYPE
        AND L3.LOOKUP_TYPE = 'BOM_SELECTION_TYPE'
        AND L3.LOOKUP_CODE = P_RANGE_OPTION_TYPE
        AND L4.LOOKUP_TYPE = 'BOM_BILL_SORT_ORDER_TYPE'
        AND L4.LOOKUP_CODE = P_ORDER_BY_TYPE;

      TABLE_NAME := 'Lookups2';
      SELECT
        SUBSTR(L1.MEANING
              ,1
              ,4),
        SUBSTR(L2.MEANING
              ,1
              ,4)
      INTO L_YES,L_NO
      FROM
        MFG_LOOKUPS L1,
        MFG_LOOKUPS L2
      WHERE L1.LOOKUP_TYPE = 'SYS_YES_NO'
        AND L1.LOOKUP_CODE = 1
        AND L2.LOOKUP_TYPE = 'SYS_YES_NO'
        AND L2.LOOKUP_CODE = 2;

      P_YES := L_YES;
      P_NO := L_NO;

      TABLE_NAME := 'Print_option';

      IF (P_PRINT_OPTION1_FLAG = 1) THEN
        P_PRINT_OPTION1 := L_YES;
      ELSE
        P_PRINT_OPTION1 := L_NO;
      END IF;

      IF (P_PRINT_OPTION2_FLAG = 1) THEN
        P_PRINT_OPTION2 := L_YES;
      ELSE
        P_PRINT_OPTION2 := L_NO;
      END IF;

      IF P_PRINT_OPTION3_FLAG = 1 THEN
        P_PRINT_OPTION3 := L_YES;
      ELSE
        P_PRINT_OPTION3 := L_NO;
      END IF;

      IF P_PRINT_OPTION4_FLAG = 1 THEN
        P_PRINT_OPTION4 := L_YES;
      ELSE
        P_PRINT_OPTION4 := L_NO;
      END IF;

      IF P_PRINT_OPTION5_FLAG = 1 THEN
        P_PRINT_OPTION5 := L_YES;
      ELSE
        P_PRINT_OPTION5 := L_NO;
      END IF;

      IF P_PRINT_OPTION6_FLAG = 1 THEN
        P_PRINT_OPTION6 := L_YES;
      ELSE
        P_PRINT_OPTION6 := L_NO;
      END IF;

      IF P_FULL_DESCRIPTION = 1 THEN
        P_FULL_DESC_CHOICE := L_YES;
      ELSE
        P_FULL_DESC_CHOICE := L_NO;
      END IF;

      IF P_IMPL_FLAG = 1 THEN
        P_IMPL := L_YES;
      ELSE
        P_IMPL := L_NO;
      END IF;

      IF P_PLAN_FACTOR_FLAG = 1 THEN
        P_PLAN_FACTOR := L_YES;
      ELSE
        P_PLAN_FACTOR := L_NO;
      END IF;

      TABLE_NAME := 'Assign_values';

      P_ORGANIZATION_NAME := L_ORGANIZATION_NAME;
      P_EXPLODE_OPTION := L_EXPLODE_OPTION;
      P_RANGE_OPTION := L_RANGE_OPTION;
      P_ALT_OPTION := L_ALT_OPTION;
      P_ORDER_BY := L_ORDER_BY;

      IF P_BOM_OR_ENG = 'BOM' THEN
        L_BOM_OR_ENG := 1;
      ELSE
        L_BOM_OR_ENG := 2;
      END IF;

      TABLE_NAME := 'Org Hierarchy';

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
                     WHERE ORGANIZATION_ID = LP_ORGANIZATION_ID )
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
        LP_ALL_ORGS := 'Yes';

      ELSIF P_ALL_ORGS = 2 THEN
        IF P_ORG_HIERARCHY IS NOT NULL THEN
          INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST(P_ORG_HIERARCHY
                                                 ,LP_ORGANIZATION_ID
                                                 ,T_ORG_CODE_LIST);
        ELSIF P_ORG_HIERARCHY IS NULL THEN
          T_ORG_CODE_LIST(1) := LP_ORGANIZATION_ID;
        END IF;
        LP_ALL_ORGS := 'No';

      ELSE
        T_ORG_CODE_LIST(1) := LP_ORGANIZATION_ID;
      END IF;

      SELECT
        BOM_LISTS_S.NEXTVAL
      INTO P_SEQUENCE_ID1
      FROM
        DUAL;

      FOR I IN T_ORG_CODE_LIST.FIRST .. T_ORG_CODE_LIST.LAST LOOP
        INSERT INTO BOM_LISTS
          (ORGANIZATION_ID
          ,SEQUENCE_ID
          ,ALTERNATE_DESIGNATOR)
        VALUES   (T_ORG_CODE_LIST(I)
          ,P_SEQUENCE_ID1
          ,I);
      END LOOP;

      FOR I IN T_ORG_CODE_LIST.FIRST .. T_ORG_CODE_LIST.LAST LOOP
        LP_ORGANIZATION_ID := T_ORG_CODE_LIST(I);
        TABLE_NAME := 'Select_sequence';
        SELECT
          BOM_LISTS_S.NEXTVAL
        INTO L_SEQ_ID
        FROM
          DUAL;

        P_SEQUENCE_ID := L_SEQ_ID;
        TABLE_NAME := 'Locator_flex';
        TABLE_NAME := 'Item_flex';

        IF P_RANGE_OPTION_TYPE = 2 THEN
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
          TABLE_NAME := 'Category_flex';
          IF (P_CATEGORY_FROM IS NOT NULL) THEN
            IF (P_CATEGORY_TO IS NOT NULL) THEN
              NULL;
            ELSE
              NULL;
            END IF;
          ELSE
            IF (P_CATEGORY_TO IS NOT NULL) THEN
              NULL;
            END IF;
          END IF;
        END IF;

        TABLE_NAME := 'bom_lists';
        CURSOR_NAME := DBMS_SQL.OPEN_CURSOR;
/***** Commented out to fix bug #6769853 ********
        P_ASS_BETWEEN := BOMRBOMS_NEW.P_ASS_BETWEEN;
        P_CAT_BETWEEN := BOMRBOMS_NEW.P_CAT_BETWEEN;
***** Commented out to fix bug #6769853 ********/
  -- P_ASS_BETWEEN := BOM_BOMRBOMS_XMLP_PKG.P_ASS_BETWEEN; Commented for bug 9364923
  P_CAT_BETWEEN := BOM_BOMRBOMS_XMLP_PKG.P_CAT_BETWEEN;

	L_STR := 'INSERT INTO BOM_LISTS (SEQUENCE_ID,ASSEMBLY_ITEM_ID,ALTERNATE_DESIGNATOR) ';
        TABLE_NAME := 'l_string';

        IF P_RANGE_OPTION_TYPE = 1 THEN
          FLAG := TRUE;
          L_STR := L_STR || 'SELECT DISTINCT ' || 'TO_CHAR(:b_l_seq_id)' || ',:b_P_ITEM_ID' || ',bbom.alternate_bom_designator
                   		FROM bom_bill_of_materials bbom
                            WHERE bbom.assembly_item_id = ' || ':b_P_ITEM_ID' || ' and bbom.organization_id =' || ':b_P_ORGANIZATION_ID';


        ELSE
          FLAG := FALSE;
	  x_numof_binds := 0;
	  /* Added for bug 9364923 */
	  IF (P_ITEM_FROM IS NOT NULL) THEN
	     IF (P_ITEM_TO IS NOT NULL) THEN
	        fnd_flex_xml_publisher_apis.kff_where
		('BTW',
		 'INV',
		 'MSTK',
		 P_ITEM_STRUCTURE_ID,
		 'MSI',
		 'ALL',
		 'BETWEEN',
		 P_ITEM_FROM,
		 P_ITEM_TO,
		 P_ASS_BETWEEN,
		 x_numof_binds,
		 l_binds
		);
	     ELSE
	        fnd_flex_xml_publisher_apis.kff_where
		('GTE',
		 'INV',
		 'MSTK',
		 P_ITEM_STRUCTURE_ID,
		 'MSI',
		 'ALL',
		 '>=',
		 P_ITEM_FROM,
		 '',
		 P_ASS_BETWEEN,
		 x_numof_binds,
		 l_binds
		);
	     END IF;
	  ELSE
	     IF (P_ITEM_TO IS NOT NULL) THEN
		fnd_flex_xml_publisher_apis.kff_where
		('LTE',
		 'INV',
		 'MSTK',
		 P_ITEM_STRUCTURE_ID,
		 'MSI',
		 'ALL',
		 '<=',
		 P_ITEM_TO,
		 '',
		 P_ASS_BETWEEN,
		 x_numof_binds,
		 l_binds
		);
	     ELSE
		P_ASS_BETWEEN := '1 = 1';
	     END IF;
	  END IF;

      /* End of changes for bug 9324623 */
          L_STR := L_STR || '  SELECT
                                   DISTINCT ' || ':b_l_seq_id' || ',
                                   msi.inventory_item_id,
                                   bbom.alternate_bom_designator
                            FROM   mtl_item_categories mic,
                                   mtl_system_items msi,
                                   mtl_categories mc,
                                   bom_bill_of_materials bbom
                            WHERE  ' || P_ASS_BETWEEN || '
                            AND    msi.inventory_item_id = mic.inventory_item_id
                            AND    msi.organization_id =
                                   ' || ':b_P_ORGANIZATION_ID' || '
                            AND    mic.organization_id =
                                   ' || ':b_P_ORGANIZATION_ID' || '
                            AND    mic.category_id = mc.category_id
                            AND    mic.category_set_id =
                                   ' || ':b_P_CATEGORY_SET_ID' || '
                            AND    mc.structure_id =
                                   ' || ':b_P_CATEGORY_STRUCTURE_ID' || '
                            AND    ' || P_CAT_BETWEEN || '
                            AND    msi.inventory_item_id = bbom.assembly_item_id
                            AND    msi.organization_id = bbom.organization_id
                     	 AND 	msi.bom_enabled_flag = ''Y''';
        END IF;

        L_STR := L_STR || '  AND    (  (' || 'TO_CHAR(:b_P_ALT_OPTION_TYPE)' || ' = 1)
                                  OR
                                    (' || 'TO_CHAR(:b_P_ALT_OPTION_TYPE)' || ' = 2
                                     AND bbom.alternate_bom_designator IS NULL)
                                  OR
                                    (' || 'TO_CHAR(:b_P_ALT_OPTION_TYPE)' || ' = 3
                                     AND NVL(bbom.alternate_bom_designator,''XXX'')=
                                        NVL(' || ':b_P_ALTERNATE_DESG' || ', ''XXX''))
                                 )';
        L_STR := L_STR || 'AND   (  (' || ':b_P_BOM_OR_ENG' || ' = ''BOM''
                                    AND bbom.assembly_type = 1)
                                 OR
                                   (' || ':b_P_BOM_OR_ENG' || ' = ''ENG'')
                 		)';


        DBMS_SQL.PARSE(CURSOR_NAME
                      ,L_STR
                      ,1);
        DBMS_SQL.BIND_VARIABLE(CURSOR_NAME
                              ,':b_l_seq_id'
                              ,L_SEQ_ID);
        DBMS_SQL.BIND_VARIABLE(CURSOR_NAME
                              ,':b_P_ALT_OPTION_TYPE'
                              ,P_ALT_OPTION_TYPE);
        DBMS_SQL.BIND_VARIABLE(CURSOR_NAME
                              ,':b_P_ALTERNATE_DESG'
                              ,P_ALTERNATE_DESG);
        DBMS_SQL.BIND_VARIABLE(CURSOR_NAME
                              ,':b_P_BOM_OR_ENG'
                              ,P_BOM_OR_ENG);
        DBMS_SQL.BIND_VARIABLE(CURSOR_NAME
                              ,':b_P_ORGANIZATION_ID'
                              ,LP_ORGANIZATION_ID);
        IF (FLAG = TRUE) THEN
          DBMS_SQL.BIND_VARIABLE(CURSOR_NAME
                                ,':b_P_ITEM_ID'
                                ,P_ITEM_ID);
        ELSIF (FLAG = FALSE) THEN
          DBMS_SQL.BIND_VARIABLE(CURSOR_NAME
                                ,':b_P_CATEGORY_SET_ID'
                                ,P_CATEGORY_SET_ID);
          DBMS_SQL.BIND_VARIABLE(CURSOR_NAME
                                ,':b_P_CATEGORY_STRUCTURE_ID'
                                ,P_CATEGORY_STRUCTURE_ID);

	  /* Added for bug 9364923 */
          FOR i IN 1..x_numof_binds LOOP
	    IF (l_binds(i).data_type='VARCHAR2') THEN
		DBMS_SQL.BIND_VARIABLE(CURSOR_NAME,l_binds(i).name,l_binds(i).varchar2_value);
	    ELSIF (l_binds(i).data_type='NUMBER') THEN
		DBMS_SQL.BIND_VARIABLE(CURSOR_NAME,l_binds(i).name,l_binds(i).canonical_value);
	    ELSIF (l_binds(i).data_type='DATE')  THEN
	      DBMS_SQL.BIND_VARIABLE(CURSOR_NAME,l_binds(i).name,l_binds(i).date_value);
	    END IF;
	  END LOOP ;
         /* End of changes for bug 9324623 */
        END IF;

        ROWS_PROCESSED := DBMS_SQL.EXECUTE(CURSOR_NAME);
        DBMS_SQL.CLOSE_CURSOR(CURSOR_NAME);
        TABLE_NAME := 'exploder';

        IF LP_REVISION_DATE IS NULL THEN
          LP_REVISION_DATE := TO_CHAR(SYSDATE
                                    ,'YYYY/MM/DD HH24:MI:SS');
        END IF;

        EXPLOSION_REPORT(ORG_ID => LP_ORGANIZATION_ID
                        ,ORDER_BY => P_ORDER_BY_TYPE
                        ,LIST_ID => L_SEQ_ID
                        ,GRP_ID => P_GROUP_ID
                        ,SESSION_ID => -1
                        ,LEVELS_TO_EXPLODE => P_EXPLOSION_LEVEL
                        ,BOM_OR_ENG => L_BOM_OR_ENG
                        ,IMPL_FLAG => P_IMPL_FLAG
                        ,EXPLODE_OPTION => P_EXPLODE_OPTION_TYPE
                        ,MODULE => 2
                        ,CST_TYPE_ID => -1
                        ,STD_COMP_FLAG => -1
                        ,EXPL_QTY => P_EXPLOSION_QUANTITY
                        ,REPORT_OPTION => -1
                        ,REQ_ID => P_CONC_REQUEST_ID
                        ,LOCK_FLAG => -1
                        ,ROLLUP_OPTION => -1
                        ,ALT_RTG_DESG => ''
                        ,ALT_DESG => P_ALTERNATE_DESG
                        ,REV_DATE => LP_REVISION_DATE
                        ,ERR_MSG => L_ERR_MSG
                        ,ERROR_CODE => L_ERR_CODE
                        ,CST_RLP_ID => 0
                        ,VERIFY_FLAG => P_VERIFY_FLAG
                        ,PLAN_FACTOR_FLAG => P_PLAN_FACTOR_FLAG
                        ,INCL_LT_FLAG => P_PRINT_OPTION3_FLAG);
      END LOOP;

      IF (P_VERIFY_FLAG = 1 AND L_ERR_CODE = 9999) THEN
        RETURN (TRUE);
      END IF;

      IF (P_VERIFY_FLAG = 2 AND L_ERR_CODE = 9999) THEN
        RAISE LOOP_ERROR;
      END IF;

      IF L_ERR_CODE <> 0 THEN
        IF L_ERR_CODE = 9998 THEN
          RAISE LOOP_ERROR;
        ELSE
          RAISE EXPLODER_ERROR;
        END IF;
      END IF;

      RETURN (TRUE);

    EXCEPTION
      WHEN EXPLODER_ERROR THEN
        /*SRW.MESSAGE('1000'
                   ,L_ERR_MSG)*/NULL;

        RETURN (FALSE);

      WHEN LOOP_ERROR THEN
        P_ERR_MSG := L_ERR_MSG;
        FND_MESSAGE.SET_NAME('null'
                            ,':P_ERR_MSG');
        P_MSG_BUF := FND_MESSAGE.GET;
        /*SRW.MESSAGE(L_ERR_CODE
                   ,P_MSG_BUF)*/NULL;

        RETURN (FALSE);

      WHEN ITEM_ID_NULL THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      WHEN OTHERS THEN
        /*SRW.MESSAGE('2000'
                   ,TABLE_NAME || SQLERRM)*/NULL;
        ecode := SQLCODE;
        emesg := SQLERRM;


        RETURN (FALSE);
    END;

    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      ROLLBACK;
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      DELETE FROM BOM_LISTS
       WHERE SEQUENCE_ID = P_SEQUENCE_ID1;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN (TRUE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION GET_REV(COMPO_ORG_ID IN NUMBER
                  ,COMPONENT_ITEM_ID IN NUMBER) RETURN VARCHAR2 IS
    REV VARCHAR2(3);
    ORG_ID NUMBER := COMPO_ORG_ID;
    ITEM_ID NUMBER := COMPONENT_ITEM_ID;
    NO_REVISION_FOUND EXCEPTION;
    PRAGMA EXCEPTION_INIT(NO_REVISION_FOUND,-20001);
  BEGIN
    IF (P_IMPL_FLAG = 1) THEN
      BOM_REVISIONS.GET_REVISION(TYPE => 'PART'
                                ,ECO_STATUS => 'ALL'
                                ,EXAMINE_TYPE => 'IMPL_ONLY'
                                ,ORG_ID => ORG_ID
                                ,ITEM_ID => ITEM_ID
                                ,REV_DATE => TO_DATE(LP_REVISION_DATE
                                       ,'YYYY/MM/DD HH24:MI:SS')
                                ,ITM_REV => REV);
    ELSE
      BOM_REVISIONS.GET_REVISION(TYPE => 'PART'
                                ,ECO_STATUS => 'ALL'
                                ,EXAMINE_TYPE => 'ALL'
                                ,ORG_ID => ORG_ID
                                ,ITEM_ID => ITEM_ID
                                ,REV_DATE => TO_DATE(LP_REVISION_DATE
                                       ,'YYYY/MM/DD HH24:MI:SS')
                                ,ITM_REV => REV);
    END IF;
    RETURN (REV);
  EXCEPTION
    WHEN NO_REVISION_FOUND THEN
      RETURN (' ');
  END GET_REV;

  FUNCTION GET_ELE_DESC(M_BOM_ITEM_TYPE IN NUMBER
                       ,D2_ELEMENT_NAME IN VARCHAR2
                       ,M_ITEM_CATALOG_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    L_DESC VARCHAR2(240);
    ORG_ID NUMBER := LP_ORGANIZATION_ID;
    L_ITEM_TYPE NUMBER := M_BOM_ITEM_TYPE;
    L_ELEMENT_NAME VARCHAR(30) := D2_ELEMENT_NAME;
    L_CATALOG_GROUP_ID NUMBER := M_ITEM_CATALOG_GROUP_ID;
  BEGIN
    IF L_ITEM_TYPE = 1 THEN
      SELECT
        DESCRIPTION
      INTO L_DESC
      FROM
        MTL_DESCRIPTIVE_ELEMENTS
      WHERE ITEM_CATALOG_GROUP_ID = L_CATALOG_GROUP_ID
        AND ELEMENT_NAME = L_ELEMENT_NAME;
    ELSIF L_ITEM_TYPE = 2 THEN
      SELECT
        MIN(DESCRIPTION)
      INTO L_DESC
      FROM
        MTL_DESCRIPTIVE_ELEMENTS
      WHERE ELEMENT_NAME = L_ELEMENT_NAME;
    END IF;
    RETURN (L_DESC);
  END GET_ELE_DESC;

  FUNCTION OPTIONAL_DISPFORMULA(OPTIONAL IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF OPTIONAL = 1 THEN
      RETURN (P_YES);
    ELSE
      RETURN (P_NO);
    END IF;
    RETURN NULL;
  END OPTIONAL_DISPFORMULA;

  FUNCTION MUTUALLY_DISPFORMULA(MUTUALLY_EXCLUSIVE_OPTION IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF MUTUALLY_EXCLUSIVE_OPTION = 1 THEN
      RETURN (P_YES);
    ELSE
      RETURN (P_NO);
    END IF;
    RETURN NULL;
  END MUTUALLY_DISPFORMULA;

  FUNCTION CHECK_ATP_DISPFORMULA(CHECK_ATP IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF CHECK_ATP = 1 THEN
      RETURN (P_YES);
    ELSE
      RETURN (P_NO);
    END IF;
    RETURN NULL;
  END CHECK_ATP_DISPFORMULA;

  FUNCTION REQUIRED_TO_SHIP_DISPFORMULA(REQUIRED_TO_SHIP IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF REQUIRED_TO_SHIP = 1 THEN
      RETURN (P_YES);
    ELSE
      RETURN (P_NO);
    END IF;
    RETURN NULL;
  END REQUIRED_TO_SHIP_DISPFORMULA;

  FUNCTION REQUIRED_FOR_REVENUE_DISPFORMU(REQUIRED_FOR_REVENUE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF REQUIRED_FOR_REVENUE = 1 THEN
      RETURN (P_YES);
    ELSE
      RETURN (P_NO);
    END IF;
    RETURN NULL;
  END REQUIRED_FOR_REVENUE_DISPFORMU;

  FUNCTION INCLUDE_ON_SHIP_DOCS_DISPFORMU(INCLUDE_ON_SHIP_DOCS IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF INCLUDE_ON_SHIP_DOCS = 1 THEN
      RETURN (P_YES);
    ELSE
      RETURN (P_NO);
    END IF;
    RETURN NULL;
  END INCLUDE_ON_SHIP_DOCS_DISPFORMU;

  FUNCTION ENG_BILL_DISPFORMULA(ENG_BILL IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF ENG_BILL = 1 THEN
      RETURN (P_NO);
    ELSE
      RETURN (P_YES);
    END IF;
    RETURN NULL;
  END ENG_BILL_DISPFORMULA;

  FUNCTION SUPPLY_TYPE_DISPFORMULA(WIP_SUPPLY_TYPE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF WIP_SUPPLY_TYPE IS NOT NULL THEN
      SELECT
        MEANING
      INTO DUMMY
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_TYPE = 'WIP_SUPPLY'
        AND LOOKUP_CODE = WIP_SUPPLY_TYPE;
      RETURN (DUMMY);
    ELSE
      RETURN (NULL);
    END IF;
    RETURN NULL;
  END SUPPLY_TYPE_DISPFORMULA;

  FUNCTION CF_REVISION_DESCFORMULA(COMPONENT_ITEM_ID IN NUMBER
                                  ,C_D3_REVISION IN VARCHAR2) RETURN CHAR IS
    REV_DESC VARCHAR2(240);
    ITEM_ID NUMBER := COMPONENT_ITEM_ID;
    ORG_ID NUMBER := LP_ORGANIZATION_ID;
    ACTIVE_REV VARCHAR2(3) := C_D3_REVISION;
  BEGIN
    SELECT
      REV.DESCRIPTION
    INTO REV_DESC
    FROM
      MTL_ITEM_REVISIONS REV
    WHERE REV.INVENTORY_ITEM_ID = ITEM_ID
      AND REV.ORGANIZATION_ID = ORG_ID
      AND REV.REVISION = ACTIVE_REV;
    RETURN (REV_DESC);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (' ');
  END CF_REVISION_DESCFORMULA;

  FUNCTION CF_ORG_NAMEFORMULA(M_ORG_ID IN NUMBER) RETURN CHAR IS
    ORG_NAME VARCHAR2(60);
  BEGIN
    SELECT
      ORGANIZATION_NAME
    INTO ORG_NAME
    FROM
      ORG_ORGANIZATION_DEFINITIONS ORG
    WHERE ORG.ORGANIZATION_ID = M_ORG_ID;
    RETURN (ORG_NAME);
  END CF_ORG_NAMEFORMULA;

  FUNCTION CF_ITEM_DESCFORMULA(M_ITEM_ID IN NUMBER
                              ,M_ORG_ID IN NUMBER) RETURN VARCHAR IS
    ITEM_DESC VARCHAR2(240);
    ITEM_ID NUMBER := M_ITEM_ID;
    ORG_ID NUMBER := M_ORG_ID;
  BEGIN
    SELECT
      DESCRIPTION
    INTO ITEM_DESC
    FROM
      MTL_SYSTEM_ITEMS_TL
    WHERE ORGANIZATION_ID = ORG_ID
      AND INVENTORY_ITEM_ID = ITEM_ID
      AND LANGUAGE = USERENV('LANG');
    RETURN (ITEM_DESC);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (' ');
  END CF_ITEM_DESCFORMULA;

  FUNCTION CF_COMP_DESCFORMULA(COMPONENT_ITEM_ID IN NUMBER
                              ,COMPO_ORG_ID IN NUMBER) RETURN VARCHAR IS
    ITEM_DESC VARCHAR2(240);
    ITEM_ID NUMBER := COMPONENT_ITEM_ID;
    ORG_ID NUMBER := COMPO_ORG_ID;
  BEGIN
    SELECT
      DESCRIPTION
    INTO ITEM_DESC
    FROM
      MTL_SYSTEM_ITEMS_TL
    WHERE ORGANIZATION_ID = ORG_ID
      AND INVENTORY_ITEM_ID = ITEM_ID
      AND LANGUAGE = USERENV('LANG');
    RETURN (ITEM_DESC);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (' ');
  END CF_COMP_DESCFORMULA;

  FUNCTION CF_SUBCOMP_DESCFORMULA(D32_ITEM_ID IN NUMBER
                                 ,D32_ORGANIZATION_ID IN NUMBER) RETURN CHAR IS
    ITEM_DESC VARCHAR2(240);
    ITEM_ID NUMBER := D32_ITEM_ID;
    ORG_ID NUMBER := D32_ORGANIZATION_ID;
  BEGIN
    SELECT
      DESCRIPTION
    INTO ITEM_DESC
    FROM
      MTL_SYSTEM_ITEMS_TL
    WHERE ORGANIZATION_ID = ORG_ID
      AND INVENTORY_ITEM_ID = ITEM_ID
      AND LANGUAGE = USERENV('LANG');
    RETURN (ITEM_DESC);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (' ');
  END CF_SUBCOMP_DESCFORMULA;

  PROCEDURE EXPLODER_USEREXIT(VERIFY_FLAG IN NUMBER
                             ,ORG_ID IN NUMBER
                             ,ORDER_BY IN NUMBER
                             ,GRP_ID IN NUMBER
                             ,SESSION_ID IN NUMBER
                             ,LEVELS_TO_EXPLODE IN NUMBER
                             ,BOM_OR_ENG IN NUMBER
                             ,IMPL_FLAG IN NUMBER
                             ,PLAN_FACTOR_FLAG IN NUMBER
                             ,EXPLODE_OPTION IN NUMBER
                             ,MODULE IN NUMBER
                             ,CST_TYPE_ID IN NUMBER
                             ,STD_COMP_FLAG IN NUMBER
                             ,EXPL_QTY IN NUMBER
                             ,ITEM_ID IN NUMBER
                             ,ALT_DESG IN VARCHAR2
                             ,COMP_CODE IN VARCHAR2
                             ,REV_DATE IN VARCHAR2
                             ,ERR_MSG OUT NOCOPY VARCHAR2
                             ,ERROR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
    /*BOMPEXPL.EXPLODER_USEREXIT(VERIFY_FLAG, ORG_ID, ORDER_BY, GRP_ID, SESSION_ID,
    LEVELS_TO_EXPLODE, BOM_OR_ENG, IMPL_FLAG, PLAN_FACTOR_FLAG, EXPLODE_OPTION, MODULE,
    CST_TYPE_ID, STD_COMP_FLAG, EXPL_QTY, ITEM_ID, ALT_DESG, COMP_CODE, REV_DATE, ERR_MSG, ERROR_CODE);*/
    null;
  END EXPLODER_USEREXIT;

  PROCEDURE EXPLOSION_REPORT(VERIFY_FLAG IN NUMBER
                            ,ORG_ID IN NUMBER
                            ,ORDER_BY IN NUMBER
                            ,LIST_ID IN NUMBER
                            ,GRP_ID IN NUMBER
                            ,SESSION_ID IN NUMBER
                            ,LEVELS_TO_EXPLODE IN NUMBER
                            ,BOM_OR_ENG IN NUMBER
                            ,IMPL_FLAG IN NUMBER
                            ,PLAN_FACTOR_FLAG IN NUMBER
                            ,INCL_LT_FLAG IN NUMBER
                            ,EXPLODE_OPTION IN NUMBER
                            ,MODULE IN NUMBER
                            ,CST_TYPE_ID IN NUMBER
                            ,STD_COMP_FLAG IN NUMBER
                            ,EXPL_QTY IN NUMBER
                            ,REPORT_OPTION IN NUMBER
                            ,REQ_ID IN NUMBER
                            ,CST_RLP_ID IN NUMBER
                            ,LOCK_FLAG IN NUMBER
                            ,ROLLUP_OPTION IN NUMBER
                            ,ALT_RTG_DESG IN VARCHAR2
                            ,ALT_DESG IN VARCHAR2
                            ,REV_DATE IN VARCHAR2
                            ,ERR_MSG OUT NOCOPY VARCHAR2
                            ,ERROR_CODE OUT NOCOPY NUMBER) IS
  BEGIN
    BOMPEXPL.EXPLOSION_REPORT(VERIFY_FLAG, ORG_ID, ORDER_BY, LIST_ID,
    GRP_ID, SESSION_ID, LEVELS_TO_EXPLODE, BOM_OR_ENG, IMPL_FLAG,
    PLAN_FACTOR_FLAG, INCL_LT_FLAG, EXPLODE_OPTION, MODULE, CST_TYPE_ID,
    STD_COMP_FLAG, EXPL_QTY, REPORT_OPTION, REQ_ID, CST_RLP_ID, LOCK_FLAG,
    ROLLUP_OPTION, ALT_RTG_DESG, ALT_DESG, REV_DATE, ERR_MSG, ERROR_CODE);
  END EXPLOSION_REPORT;

END BOM_BOMRBOMS_XMLP_PKG;

/
