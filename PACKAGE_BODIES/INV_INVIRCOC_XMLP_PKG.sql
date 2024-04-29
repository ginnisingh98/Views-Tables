--------------------------------------------------------
--  DDL for Package Body INV_INVIRCOC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRCOC_XMLP_PKG" AS
/* $Header: INVIRCOCB.pls 120.2 2008/01/08 06:29:32 dwkrishn noship $ */
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
    IF (P_COMMODITY_CODE_FROM IS NOT NULL) THEN
      P_WHERE := P_WHERE || 'and commodity_code >= ' || '''' || P_COMMODITY_CODE_FROM || '''';
    END IF;
    IF (P_COMMODITY_CODE_FROM IS NOT NULL AND P_COMMODITY_CODE_TO IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And commodity_code <=' || '''' || P_COMMODITY_CODE_TO || '''';
    END IF;
    IF (P_COMMODITY_CODE_FROM IS NULL AND P_COMMODITY_CODE_TO IS NOT NULL) THEN
      P_WHERE := P_WHERE || 'and commodity_code <=' || '''' || P_COMMODITY_CODE_TO || '''';
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;
END INV_INVIRCOC_XMLP_PKG;


/
