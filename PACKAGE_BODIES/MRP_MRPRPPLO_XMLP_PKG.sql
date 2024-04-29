--------------------------------------------------------
--  DDL for Package Body MRP_MRPRPPLO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_MRPRPPLO_XMLP_PKG" AS
/* $Header: MRPRPPLOB.pls 120.3 2008/01/02 13:06:58 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS

DATE_FORMAT varchar2(20):='DD'||'-MON-'||'YYYY';
  BEGIN
    DECLARE
      CURRENCY_DESC VARCHAR2(80);
      PRECISION NUMBER;
      CAT_STRUCT_NUM NUMBER;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    QTY_PRECISION:=mrp_common_xmlp_pkg.get_precision(P_QTY_PRECISION);
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG = 'Y') THEN
        EXECUTE IMMEDIATE
          'ALTER SESSION SET SQL_TRACE TRUE';
      END IF;
      P_CAT_STRUCT_NUM := P_CAT_STRUCT;
      IF (P_SORT = 1) THEN
        NULL;
      END IF;
      IF (P_SORT = 2) THEN
        NULL;
      END IF;
      IF ((P_LOW_ITEM IS NOT NULL) OR (P_HIGH_ITEM IS NOT NULL)) THEN
        NULL;
      END IF;
      IF ((P_LOW_CAT IS NOT NULL) OR (P_HIGH_CAT IS NOT NULL)) THEN
        NULL;
      END IF;
      SELECT
        NAME,
        PRECISION
      INTO CURRENCY_DESC,PRECISION
      FROM
        FND_CURRENCIES_VL
      WHERE CURRENCY_CODE = P_CURRENCY_CODE;
      P_CURRENCY_DESC := CURRENCY_DESC;
      P_PRECISION := PRECISION;
    END;
P_CUTOFF_DATE_1:=to_char(P_CUTOFF_DATE,DATE_FORMAT);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

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

  FUNCTION C_CATEGORY_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CATEGORY_FROM VARCHAR2(80);
    BEGIN
      IF ((P_LOW_CAT IS NOT NULL) OR (P_HIGH_CAT IS NOT NULL) OR (P_SORT = 2)) THEN
        CATEGORY_FROM := ',mtl_categories cat';
      ELSE
        CATEGORY_FROM := ' ';
      END IF;
      RETURN (CATEGORY_FROM);
    END;
    RETURN NULL;
  END C_CATEGORY_FROMFORMULA;

  FUNCTION C_SORT_COLUMNFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      SORT_COLUMN VARCHAR2(80);
    BEGIN
      IF (P_SORT = 3) THEN
        SORT_COLUMN := ',req.planner_code';
      ELSIF (P_SORT = 4) THEN
        SORT_COLUMN := ',req.buyer_name';
      ELSIF (P_SORT = 6) THEN
        SORT_COLUMN := ',abc.abc_class_id';
      ELSE
        SORT_COLUMN := ' ';
      END IF;
      RETURN (SORT_COLUMN);
    END;
    RETURN NULL;
  END C_SORT_COLUMNFORMULA;

  FUNCTION C_ABC_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ABC_WHERE VARCHAR2(200);
    BEGIN
      IF (P_ABC_ASSGN IS NOT NULL) THEN
        ABC_WHERE := 'AND abc.inventory_item_id(+) = req.inventory_item_id ' || 'AND abc.assignment_group_id = ' || P_ABC_ASSGN || ' AND abc.abc_class_id = abc_cls.abc_class_id';
      ELSIF ((P_ABC_CLASS IS NOT NULL) OR (P_SORT = 6)) THEN
        ABC_WHERE := 'AND abc.inventory_item_id(+) = req.inventory_item_id ' || 'AND abc_cls.abc_class_id(+) = abc.abc_class_id';
      ELSE
        ABC_WHERE := ' ';
      END IF;
      RETURN (ABC_WHERE);
    END;
    RETURN NULL;
  END C_ABC_WHEREFORMULA;

  FUNCTION C_CUTOFF_COLUMNFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CUTOFF_COLUMN VARCHAR2(80);
    BEGIN
      IF (P_CUTOFF_TYPE = 1) THEN
        CUTOFF_COLUMN := 'rec.new_order_placement_date';
      ELSIF (P_CUTOFF_TYPE = 2) THEN
        CUTOFF_COLUMN := 'rec.new_schedule_date';
      ELSIF (P_CUTOFF_TYPE = 3) THEN
        CUTOFF_COLUMN := 'rec.new_dock_date';
      ELSE
        CUTOFF_COLUMN := 'rec.new_wip_start_date';
      END IF;
      RETURN (CUTOFF_COLUMN);
    END;
    RETURN ('rec.new_schedule_date');
  END C_CUTOFF_COLUMNFORMULA;

  FUNCTION C_ABC_FROMFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ABC_FROM VARCHAR2(80);
    BEGIN
      IF (P_ABC_ASSGN IS NOT NULL) OR ((P_ABC_CLASS IS NOT NULL) OR (P_SORT = 6)) THEN
        ABC_FROM := ',mtl_abc_assignments abc' || ',mtl_abc_classes abc_cls';
      ELSE
        ABC_FROM := ' ';
      END IF;
      RETURN (ABC_FROM);
    END;
    RETURN NULL;
  END C_ABC_FROMFORMULA;

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

  FUNCTION C_CATEGORY_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      CATEGORY_WHERE VARCHAR2(250);
    BEGIN
      IF ((P_LOW_CAT IS NOT NULL) OR (P_HIGH_CAT IS NOT NULL) OR (P_SORT = 2)) THEN
        CATEGORY_WHERE := 'AND ic.category_id = cat.category_id(+) ' || 'AND cat.structure_id = ' || P_CAT_STRUCT;
      ELSE
        CATEGORY_WHERE := ' ';
      END IF;
      RETURN (CATEGORY_WHERE);
    END;
    RETURN NULL;
  END C_CATEGORY_WHEREFORMULA;

  FUNCTION C_ORDER_BYFORMULA(P_ITEM_ORDER_BY varchar2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_BY VARCHAR2(2000);
    BEGIN
      IF (P_SORT = 1) THEN
        ORDER_BY := ',rec.new_schedule_date,' || P_ITEM_ORDER_BY || ',rec.new_order_quantity' || ',rec.schedule_compression_days' || ',rec.transaction_id';
      ELSIF (P_SORT = 2) THEN
        ORDER_BY := ',rec.new_schedule_date,' || P_ITEM_ORDER_BY || ',rec.new_order_quantity' || ',rec.schedule_compression_days' || ',rec.transaction_id';
      ELSIF (P_SORT = 3) THEN
        ORDER_BY := 'req.planner_code' || ',rec.new_schedule_date,' || P_ITEM_ORDER_BY || ',rec.new_order_quantity' || ',rec.schedule_compression_days' || ',rec.transaction_id';
      ELSIF (P_SORT = 4) THEN
        ORDER_BY := 'req.buyer_name' || ',rec.new_schedule_date,' || P_ITEM_ORDER_BY || ',rec.new_order_quantity' || ',rec.schedule_compression_days' || ',rec.transaction_id';
      ELSIF (P_SORT = 6) THEN
        ORDER_BY := 'abc.abc_class_id' || ',rec.new_schedule_date,' || P_ITEM_ORDER_BY || ',rec.new_order_quantity' || ',rec.schedule_compression_days' || ',rec.transaction_id';
      ELSIF (P_SORT = 7) THEN
        ORDER_BY := 'par.organization_code' || ',rec.new_schedule_date,' || P_ITEM_ORDER_BY || ',rec.new_order_quantity' || ',rec.schedule_compression_days' || ',rec.transaction_id';
      ELSIF (P_SORT = 0) THEN
        ORDER_BY := 'rec.new_schedule_date,' || P_ITEM_ORDER_BY || ',rec.new_order_quantity' || ',rec.schedule_compression_days' || ',rec.transaction_id';
      ELSE
        ORDER_BY := ' ';
      END IF;
      RETURN (ORDER_BY);
    END;
    RETURN 'rec.new_schedule_date';
  END C_ORDER_BYFORMULA;

  FUNCTION C_P_ITEM_SELECTFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ITEM_SELECT VARCHAR2(80);
    BEGIN
      IF P_ITEM_SELECT IS NOT NULL THEN
        SELECT
          MEANING
        INTO ITEM_SELECT
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_CODE = P_ITEM_SELECT
          AND LOOKUP_TYPE = 'MTL_PLANNING_MAKE_BUY';
        RETURN (ITEM_SELECT);
      ELSE
        RETURN (NULL);
      END IF;
    END;
    RETURN NULL;
  END C_P_ITEM_SELECTFORMULA;

  FUNCTION C_P_INCLUDE_COSTFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      INCLUDE_COST VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO INCLUDE_COST
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_CODE = P_INCLUDE_COST
        AND LOOKUP_TYPE = 'SYS_YES_NO';
      RETURN (INCLUDE_COST);
    END;
    RETURN NULL;
  END C_P_INCLUDE_COSTFORMULA;

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
        AND LOOKUP_TYPE = 'MRP_PLANNED_ORDER_SORT';
      RETURN (SORT);
    END;
    RETURN NULL;
  END C_P_SORTFORMULA;

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

  FUNCTION C_P_ABC_ASSGNFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ABC_ASSGN VARCHAR2(40);
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
  END C_P_ABC_ASSGNFORMULA;

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

  FUNCTION C_P_MULTI_ORGFORMULA RETURN NUMBER IS
  BEGIN
    DECLARE
      VAR1 NUMBER;
      MULTI_ORG NUMBER;
      CURSOR C IS
        SELECT
          DISTINCT
          ORGANIZATION_SELECTION
        FROM
          MRP_PLAN_ORGANIZATIONS_V
        WHERE DECODE(P_ORG_TYPE
              ,1
              ,PLANNED_ORGANIZATION
              ,ORGANIZATION_ID) = P_ORG_ID
          AND COMPILE_DESIGNATOR = P_PLAN_NAME;
    BEGIN
      OPEN C;
      FETCH C
       INTO VAR1;
      IF (C%NOTFOUND) THEN
        MULTI_ORG := 2;
      END IF;
      IF ((VAR1 = 2) OR (VAR1 = 3)) THEN
        MULTI_ORG := 1;
      ELSE
        MULTI_ORG := 2;
      END IF;
      CLOSE C;
      RETURN (MULTI_ORG);
    END;
    RETURN NULL;
  END C_P_MULTI_ORGFORMULA;

  FUNCTION C_P_ORG_TYPEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORG_TYPE VARCHAR2(80);
    BEGIN
      ORG_TYPE := 'Current Organization';
      IF P_ORG_TYPE = 2 THEN
        SELECT
          MEANING
        INTO ORG_TYPE
        FROM
          MFG_LOOKUPS
        WHERE LOOKUP_CODE = P_ORG_TYPE
          AND LOOKUP_TYPE = 'MRP_REPORT_MULTIORG';
      END IF;
      RETURN (ORG_TYPE);
    END;
    RETURN NULL;
  END C_P_ORG_TYPEFORMULA;

 FUNCTION CP_order(P_ORDER_BY1 varchar2,P_ORDER_BY2 varchar2) RETURN VARCHAR2 IS
  BEGIN

    BEGIN
     IF (P_SORT = 1) THEN
       return(P_ORDER_BY1);
    END IF;
    IF (P_SORT = 2) THEN
       return(P_ORDER_BY2);
    END IF;
    END;
   RETURN NULL;
  END CP_order;

END MRP_MRPRPPLO_XMLP_PKG;


/
