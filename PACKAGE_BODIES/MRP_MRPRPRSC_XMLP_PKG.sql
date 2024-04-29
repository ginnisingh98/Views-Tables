--------------------------------------------------------
--  DDL for Package Body MRP_MRPRPRSC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_MRPRPRSC_XMLP_PKG" AS
/* $Header: MRPRPRSCB.pls 120.4 2008/01/02 13:31:56 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
DATE_FORMAT_1 varchar2(30):='DD'||'-MON-'||'YYYY';
	DATE_FORMAT_2 varchar2(30):='DD'||'-MON-'||'YY';
  BEGIN
    DECLARE
      CURRENCY_DESC VARCHAR2(80);
      PRECISION NUMBER;
      CANCEL_TEXT VARCHAR2(80);
      CAT_STRUCT_NUM NUMBER;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      QTY_PRECISION:=mrp_common_xmlp_pkg.get_precision(P_QTY_PRECISION);
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG = 'Y') THEN
        EXECUTE IMMEDIATE
          'ALTER SESSION SET SQL_TRACE TRUE';
      END IF;
      SELECT
        MEANING
      INTO CANCEL_TEXT
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_TYPE = 'MRP_CANCEL'
        AND LOOKUP_CODE = 1;
      P_CANCEL_TEXT := CANCEL_TEXT;
      P_CUTOFF_DATE_YY := TO_CHAR(P_CUTOFF_DATE
                                 ,'YYYY/MM/DD');
      SELECT
        NAME,
        PRECISION
      INTO CURRENCY_DESC,PRECISION
      FROM
        FND_CURRENCIES_VL
      WHERE CURRENCY_CODE = P_CURRENCY_CODE;
      P_CURRENCY_DESC := CURRENCY_DESC;
      P_PRECISION := PRECISION;
      IF ((P_SORT = 2) OR (P_LOW_CAT IS NOT NULL) OR (P_HIGH_CAT IS NOT NULL)) THEN
        SELECT
          STRUCTURE_ID
        INTO CAT_STRUCT_NUM
        FROM
          MTL_DEFAULT_SETS_VIEW
        WHERE FUNCTIONAL_AREA_ID = 3;
        P_CAT_STRUCT_NUM := CAT_STRUCT_NUM;
      END IF;
      IF (P_ORDER_TYPE = 3 OR P_ORDER_TYPE = 10) THEN
        P_WIP_START := 'wip1.start_date';
      END IF;
      IF ((P_LOW_ITEM IS NOT NULL) OR (P_HIGH_ITEM IS NOT NULL)) THEN
        NULL;
      END IF;
      IF ((P_LOW_CAT IS NOT NULL) OR (P_HIGH_CAT IS NOT NULL)) THEN
        NULL;
      END IF;
      IF (P_SORT = 1) THEN
        NULL;
      END IF;
      IF (P_SORT = 2) THEN
        NULL;
      END IF;
    END;
P_CUTOFF_DATE_1:=to_char(P_CUTOFF_DATE,DATE_FORMAT_1);
	P_CUTOFF_DATE_2:=to_char(P_CUTOFF_DATE,DATE_FORMAT_2);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_CATEGORY_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CATEGORY_FROM VARCHAR2(80);
    BEGIN
      IF (((P_LOW_CAT IS NOT NULL) OR (P_HIGH_CAT IS NOT NULL)) OR (P_SORT = 2)) THEN
        CATEGORY_FROM := ',mtl_categories cat';
      ELSE
        CATEGORY_FROM := ' ';
      END IF;
      RETURN (CATEGORY_FROM);
    END;
    RETURN NULL;
  END C_CATEGORY_FROMFORMULA;

  FUNCTION C_BUYER_RANGEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      BUYER_RANGE VARCHAR2(80);
    BEGIN
      IF (P_BUYER IS NOT NULL) THEN
        BUYER_RANGE := 'AND req.buyer_id = ' || P_BUYER;
      ELSE
        BUYER_RANGE := ' ';
      END IF;
      RETURN (BUYER_RANGE);
    END;
    RETURN NULL;
  END C_BUYER_RANGEFORMULA;

  FUNCTION C_CATEGORY_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CATEGORY_WHERE VARCHAR2(200);
    BEGIN
      IF ((P_LOW_CAT IS NOT NULL) OR (P_HIGH_CAT IS NOT NULL) OR (P_SORT = 2)) THEN
        CATEGORY_WHERE := 'AND ic.category_id = cat.category_id(+)' || 'AND cat.structure_id = ' || P_CAT_STRUCTURE;
      ELSE
        CATEGORY_WHERE := ' ';
      END IF;
      RETURN (CATEGORY_WHERE);
    END;
    RETURN NULL;
  END C_CATEGORY_WHEREFORMULA;

  FUNCTION C_PLANNER_RANGEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      PLANNER_RANGE VARCHAR2(80);
    BEGIN
      IF (P_PLANNER IS NOT NULL) THEN
        PLANNER_RANGE := 'AND req.planner_code = ''' || P_PLANNER || '''';
      ELSE
        PLANNER_RANGE := ' ';
      END IF;
      RETURN (PLANNER_RANGE);
    END;
    RETURN NULL;
  END C_PLANNER_RANGEFORMULA;

  FUNCTION C_ABC_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ABC_FROM VARCHAR2(80);
    BEGIN
      IF (P_ABC_ASSGN IS NOT NULL) OR ((P_ABC_CLASS IS NOT NULL) OR (P_SORT = 7)) THEN
        ABC_FROM := ', mtl_abc_assignments abc' || ',mtl_abc_classes abc_cls';
      ELSE
        ABC_FROM := ' ';
      END IF;
      RETURN (ABC_FROM);
    END;
    RETURN NULL;
  END C_ABC_FROMFORMULA;

  FUNCTION C_ABC_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ABC_WHERE VARCHAR2(200);
    BEGIN
      IF (P_ABC_ASSGN IS NOT NULL) THEN
        ABC_WHERE := 'AND abc.inventory_item_id(+) = req.inventory_item_id ' || 'AND abc.assignment_group_id = ' || P_ABC_ASSGN || ' AND abc.abc_class_id = abc_cls.abc_class_id';
      ELSIF ((P_ABC_CLASS IS NOT NULL) OR (P_SORT = 7)) THEN
        ABC_WHERE := 'AND abc.inventory_item_id(+) = req.inventory_item_id ' || 'AND abc_cls.abc_class_id(+) = abc.abc_class_id';
      ELSE
        ABC_WHERE := ' ';
      END IF;
      RETURN (ABC_WHERE);
    END;
    RETURN NULL;
  END C_ABC_WHEREFORMULA;

  FUNCTION C_ORDER_BYFORMULA(P_ORDER_BY1 varchar2,P_ORDER_BY2 varchar2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_BY VARCHAR2(80);
    BEGIN
      IF (P_SORT = 1) THEN
        ORDER_BY := P_ORDER_BY1 || ',';
      ELSIF (P_SORT = 2) THEN
        ORDER_BY := P_ORDER_BY2 || ',';
      ELSIF (P_SORT = 3 AND P_ORDER_TYPE = 3) THEN
        ORDER_BY := ' wip1.wip_entity_name, ';
      ELSIF (P_SORT = 3 AND P_ORDER_TYPE <> 3) THEN
        ORDER_BY := ' po1.po_number, ';
      ELSIF (P_SORT = 4) THEN
        ORDER_BY := ' vendors.vendor_name, ';
      ELSIF (P_SORT = 5 AND P_ORDER_TYPE = 3) THEN
        ORDER_BY := ' req.planner_code, wip1.wip_entity_name, ';
      ELSIF (P_SORT = 5 AND P_ORDER_TYPE <> 3) THEN
        ORDER_BY := ' req.planner_code, po1.po_number, ';
      ELSIF (P_SORT = 6) THEN
        ORDER_BY := ' req.buyer_name, ';
      ELSIF (P_SORT = 7) THEN
        ORDER_BY := ' abc.abc_class_id, ';
      ELSIF (P_SORT = 8) THEN
        ORDER_BY := ' parm.organization_code, ';
      ELSE
        ORDER_BY := ' ';
      END IF;
      RETURN (ORDER_BY);
    END;
    RETURN NULL;
  END C_ORDER_BYFORMULA;

  FUNCTION C_CUTOFF_COLUMNFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CUTOFF VARCHAR2(400);
    BEGIN
      IF (P_CUTOFF_TYPE = 1) THEN
        CUTOFF := ' AND (rec.new_order_placement_date <= to_date(
                                       ''' || P_CUTOFF_DATE_YY || ''',''YYYY/MM/DD'')
                                  OR   rec.old_order_placement_date <= to_date(
                                       ''' || P_CUTOFF_DATE_YY || ''',''YYYY/MM/DD'')) ';
      ELSIF (P_CUTOFF_TYPE = 2) THEN
        CUTOFF := ' AND (rec.new_schedule_date <= to_date(
                                       ''' || P_CUTOFF_DATE_YY || ''',''YYYY/MM/DD'')
                                  OR   rec.old_schedule_date <= to_date(
                                       ''' || P_CUTOFF_DATE_YY || ''', ''YYYY/MM/DD'')) ';
      ELSIF (P_CUTOFF_TYPE = 3) THEN
        CUTOFF := ' AND (rec.new_dock_date <= to_date(
                                       ''' || P_CUTOFF_DATE_YY || ''',''YYYY/MM/DD'')
                                  OR   rec.old_dock_date <= to_date(
                                       ''' || P_CUTOFF_DATE_YY || ''',''YYYY/MM/DD'')) ';
      ELSE
        CUTOFF := ' AND (rec.new_wip_start_date <= to_date(
                                       ''' || P_CUTOFF_DATE_YY || ''',''YYYY/MM/DD'')) ';
      END IF;
      RETURN (CUTOFF);
    END;
    RETURN NULL;
  END C_CUTOFF_COLUMNFORMULA;

  FUNCTION C_SORT_COLUMNFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SORT_COLUMN VARCHAR2(80);
    BEGIN
      IF (P_SORT = 5 AND P_ORDER_TYPE = 3) THEN
        SORT_COLUMN := ', wip1.wip_entity_name ';
      ELSIF (P_SORT = 7) THEN
        SORT_COLUMN := ', TO_CHAR(abc.abc_class_id) ';
      ELSE
        SORT_COLUMN := ' ';
      END IF;
      RETURN (SORT_COLUMN);
    END;
    RETURN NULL;
  END C_SORT_COLUMNFORMULA;

  FUNCTION C_ABC_RANGEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ABC_RANGE VARCHAR2(80);
    BEGIN
      IF (P_ABC_CLASS IS NOT NULL) THEN
        ABC_RANGE := 'AND abc.abc_class_id = ' || P_ABC_CLASS;
      ELSE
        ABC_RANGE := ' ';
      END IF;
      RETURN (ABC_RANGE);
    END;
    RETURN NULL;
  END C_ABC_RANGEFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_DAYS_RANGEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      DAYS VARCHAR2(256);
      IN_DAYS VARCHAR2(4);
      OUT_DAYS VARCHAR2(4);
    BEGIN
      IN_DAYS := TO_CHAR(P_IN_DAYS * -1);
      OUT_DAYS := TO_CHAR(P_OUT_DAYS);
      IF ((P_IN_DAYS IS NOT NULL) AND (P_OUT_DAYS IS NOT NULL)) THEN
        DAYS := ' AND (rec.reschedule_days NOT BETWEEN ' || IN_DAYS || ' and ' || OUT_DAYS || ' OR rec.disposition_status_type = 2) ';
      ELSE
        DAYS := ' ';
      END IF;
      RETURN (DAYS);
    END;
    RETURN NULL;
  END C_DAYS_RANGEFORMULA;

  FUNCTION C_WIP_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      WIP VARCHAR2(80);
    BEGIN
      IF (P_ORDER_TYPE = 3 OR P_ORDER_TYPE = 10) THEN
        WIP := ', mrp_item_wip_entities wip1 ';
      ELSE
        WIP := ' ';
      END IF;
      RETURN (WIP);
    END;
    RETURN NULL;
  END C_WIP_FROMFORMULA;

  FUNCTION C_WIP_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      WIP VARCHAR2(256);
    BEGIN
      IF (P_ORDER_TYPE = 3 OR P_ORDER_TYPE = 10) THEN
        WIP := ' AND wip1.wip_entity_id(+) = rec.disposition_id' || ' AND wip1.organization_id(+) = rec.organization_id' || ' AND wip1.compile_designator(+) = rec.compile_designator' || ' AND wip1.inventory_item_id(+) = rec.inventory_item_id ';
      ELSE
        WIP := ' ';
      END IF;
      RETURN (WIP);
    END;
    RETURN NULL;
  END C_WIP_WHEREFORMULA;

  FUNCTION C_P_SORTFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SORT VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO SORT
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_CODE = P_SORT
        AND LOOKUP_TYPE = 'MRP_RESCHEDULE_SORT';
      RETURN (SORT);
    END;
    RETURN NULL;
  END C_P_SORTFORMULA;

  FUNCTION C_P_ORDER_TYPEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_TYPE VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO ORDER_TYPE
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_CODE = P_ORDER_TYPE
        AND LOOKUP_TYPE = 'MRP_RESCHEDULE_SELECT';
      RETURN (ORDER_TYPE);
    END;
    RETURN NULL;
  END C_P_ORDER_TYPEFORMULA;

  FUNCTION C_P_BUYERFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      BUYER VARCHAR2(50);
    BEGIN
      IF (P_BUYER IS NOT NULL) THEN
        SELECT
          FULL_NAME
        INTO BUYER
        FROM
          MTL_EMPLOYEES_VIEW
        WHERE EMPLOYEE_ID = P_BUYER
          AND ORGANIZATION_ID = P_ORG_ID;
      END IF;
      RETURN (BUYER);
    END;
    RETURN NULL;
  END C_P_BUYERFORMULA;

  FUNCTION C_P_CAT_SETFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CAT_SET VARCHAR2(30);
    BEGIN
      SELECT
        CATEGORY_SET_NAME
      INTO CAT_SET
      FROM
        MTL_CATEGORY_SETS
      WHERE CATEGORY_SET_ID = P_CAT_SET;
      RETURN (CAT_SET);
    END;
    RETURN NULL;
  END C_P_CAT_SETFORMULA;

  FUNCTION C_P_ABC_ASSIGNFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ABC_ASSGN VARCHAR2(42);
    BEGIN
      SELECT
        ASSIGNMENT_GROUP_NAME
      INTO ABC_ASSGN
      FROM
        MTL_ABC_ASSIGNMENT_GROUPS
      WHERE ASSIGNMENT_GROUP_ID = P_ABC_ASSGN
        AND ORGANIZATION_ID = P_ORG_ID;
      RETURN (ABC_ASSGN);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    RETURN NULL;
  END C_P_ABC_ASSIGNFORMULA;

  FUNCTION C_P_CUTOFF_TYPEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CUTOFF_TYPE VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO CUTOFF_TYPE
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_CODE = P_CUTOFF_TYPE
        AND LOOKUP_TYPE = 'MRP_PL_ORDER_CUTOFF_TYPE';
      RETURN (CUTOFF_TYPE);
    END;
    RETURN NULL;
  END C_P_CUTOFF_TYPEFORMULA;

  FUNCTION C_PO_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      PO VARCHAR2(80);
    BEGIN
      IF (P_ORDER_TYPE = 1 OR P_ORDER_TYPE = 2 OR P_ORDER_TYPE = 10) THEN
        PO := ', mrp_item_purchase_orders po1 ';
      ELSE
        PO := ' ';
      END IF;
      RETURN (PO);
    END;
    RETURN NULL;
  END C_PO_FROMFORMULA;

  FUNCTION C_PO_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      PO VARCHAR2(256);
    BEGIN
      IF (P_ORDER_TYPE = 1 OR P_ORDER_TYPE = 2) THEN
        PO := ' AND po1.FIRM_PLANNED_STATUS_TYPE <> 1' || ' AND po1.transaction_id(+) = rec.disposition_id' || ' AND po1.order_type(+) = ''' || P_ORDER_TYPE || '''';
      ELSIF (P_ORDER_TYPE = 10) THEN
        PO := ' AND po1.transaction_id(+) = rec.disposition_id';
      ELSE
        PO := ' ';
      END IF;
      RETURN (PO);
    END;
    RETURN NULL;
  END C_PO_WHEREFORMULA;

  FUNCTION C_PO_ORDER_NUMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_NUM VARCHAR2(100);
    BEGIN
      IF (P_ORDER_TYPE = 1 OR P_ORDER_TYPE = 10) THEN
        ORDER_NUM := 'po1.po_number';
      ELSE
        ORDER_NUM := NULL;
      END IF;
      RETURN (ORDER_NUM);
    END;
    RETURN NULL;
  END C_PO_ORDER_NUMFORMULA;

  FUNCTION C_REQ_ORDER_NUMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_NUM VARCHAR2(100);
    BEGIN
      IF (P_ORDER_TYPE = 2 OR P_ORDER_TYPE = 10) THEN
        ORDER_NUM := 'po1.po_number';
      ELSE
        ORDER_NUM := NULL;
      END IF;
      RETURN (ORDER_NUM);
    END;
    RETURN NULL;
  END C_REQ_ORDER_NUMFORMULA;

  FUNCTION C_WIP_ORDER_NUMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_NUM VARCHAR2(100);
    BEGIN
      IF (P_ORDER_TYPE = 3 OR P_ORDER_TYPE = 10) THEN
        ORDER_NUM := 'wip1.wip_entity_name';
      ELSE
        ORDER_NUM := NULL;
      END IF;
      RETURN (ORDER_NUM);
    END;
    RETURN NULL;
  END C_WIP_ORDER_NUMFORMULA;

  FUNCTION C_P_ABC_CLASSFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ABC_CLASS VARCHAR2(40);
    BEGIN
      IF (P_ABC_CLASS IS NOT NULL) THEN
        SELECT
          ABC_CLASS_NAME
        INTO ABC_CLASS
        FROM
          MTL_ABC_CLASSES
        WHERE ABC_CLASS_ID = P_ABC_CLASS
          AND ORGANIZATION_ID = P_ORG_ID;
      END IF;
      RETURN (ABC_CLASS);
    END;
    RETURN NULL;
  END C_P_ABC_CLASSFORMULA;

  FUNCTION C_P_USE_MULTIORG_PLANFORMULA RETURN NUMBER IS
  BEGIN
    DECLARE
      ORG_SELECTION NUMBER;
      USE_MULTIORG_PLAN NUMBER;
    BEGIN
      IF (P_REPORT_MULTIORG = 2) THEN
        SELECT
          ORGANIZATION_SELECTION
        INTO ORG_SELECTION
        FROM
          MRP_PLANS
        WHERE ORGANIZATION_ID = P_ORG_ID
          AND COMPILE_DESIGNATOR = P_PLAN_NAME;
      ELSE
        SELECT
          ORGANIZATION_SELECTION
        INTO ORG_SELECTION
        FROM
          MRP_PLAN_ORGANIZATIONS_V
        WHERE PLANNED_ORGANIZATION = P_ORG_ID
          AND COMPILE_DESIGNATOR = P_PLAN_NAME;
      END IF;
      IF ((ORG_SELECTION = 2) OR (ORG_SELECTION = 3)) THEN
        USE_MULTIORG_PLAN := 1;
      ELSE
        USE_MULTIORG_PLAN := 2;
      END IF;
      RETURN (USE_MULTIORG_PLAN);
    END;
    RETURN NULL;
  END C_P_USE_MULTIORG_PLANFORMULA;

  FUNCTION C_P_REPORT_MULTIORGFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      REPORT_MULTIORG_TEXT VARCHAR2(80) := 'Current Organization';
    BEGIN
      IF P_REPORT_MULTIORG = 2 THEN
        SELECT
          MEANING
        INTO REPORT_MULTIORG_TEXT
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_CODE = P_REPORT_MULTIORG
          AND LOOKUP_TYPE = 'MRP_REPORT_MULTIORG';
      END IF;
      RETURN (REPORT_MULTIORG_TEXT);
    END;
    RETURN NULL;
  END C_P_REPORT_MULTIORGFORMULA;

END MRP_MRPRPRSC_XMLP_PKG;



/
