--------------------------------------------------------
--  DDL for Package Body INV_INVSRLOC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVSRLOC_XMLP_PKG" AS
/* $Header: INVSRLOCB.pls 120.1 2007/12/25 10:54:18 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        QTY_PRECISION:=inv_common_xmlp_pkg.get_precision(P_QTY_PRECISION);
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Before Report: Init')*/NULL;
          RAISE;
      END;
      DECLARE
        P_ORG_ID_CHAR VARCHAR2(100) := (P_ORG_ID);
      BEGIN
        FND_PROFILE.PUT('MFG_ORGANIZATION_ID'
                       ,P_ORG_ID_CHAR);
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
          RAISE;
      END;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'SRWEXIT failed')*/NULL;
      END;
      RETURN (TRUE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;
END INV_INVSRLOC_XMLP_PKG;


/
