--------------------------------------------------------
--  DDL for Package Body INV_INVIRSIQ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRSIQ_XMLP_PKG" AS
/* $Header: INVIRSIQB.pls 120.1 2007/12/25 10:32:03 dwkrishn noship $ */
  FUNCTION P_STRUCT_NUMVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_STRUCT_NUMVALIDTRIGGER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      qty_precision:=inv_common_xmlp_pkg.get_precision(P_qty_precision);
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(010
                   ,'Failed in before report trigger, srwinit. ')*/NULL;
        RAISE;
    END;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := (P_ORGANIZATION_ID);
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
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, item select. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(080
                   ,'Failed in before report trigger, item order by. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(110
                   ,'Failed in before report trigger, item where. ')*/NULL;
        RAISE;
    END;
    BEGIN
      NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(112
                   ,'Failed in before report trigger, locator select. ')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION WHERE_SUBINV RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      LO VARCHAR2(10);
      HI VARCHAR2(10);
    BEGIN
      LO := P_SUBINV_LO;
      HI := P_SUBINV_HI;
      IF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NULL THEN
        RETURN (' ');
      ELSE
        IF P_SUBINV_LO IS NOT NULL AND P_SUBINV_HI IS NULL THEN
          RETURN ('  AND si.secondary_inventory_name >= ''' || LO || ''' ');
        ELSE
          IF P_SUBINV_LO IS NULL AND P_SUBINV_HI IS NOT NULL THEN
            RETURN ('  AND si.secondary_inventory_name <=  ''' || HI || ''' ');
          ELSE
            RETURN ('  AND si.secondary_inventory_name between  ''' || LO || '''  and ''' || HI || ''' ');
          END IF;
        END IF;
      END IF;
    END;
    RETURN (' ');
  END WHERE_SUBINV;

  FUNCTION CF_ROUNDEDQTYFORMULA(C_SUM_ITEM_QTY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN ROUND(C_SUM_ITEM_QTY
                ,P_QTY_PRECISION);
  END CF_ROUNDEDQTYFORMULA;

END INV_INVIRSIQ_XMLP_PKG;


/
