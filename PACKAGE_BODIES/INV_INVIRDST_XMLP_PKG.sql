--------------------------------------------------------
--  DDL for Package Body INV_INVIRDST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRDST_XMLP_PKG" AS
/* $Header: INVIRDSTB.pls 120.2 2008/01/08 06:38:06 dwkrishn noship $ */
  FUNCTION C_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_STATUS_HI IS NOT NULL AND P_STATUS_LO IS NOT NULL THEN
      RETURN ('and inventory_item_status_code between ''' || P_STATUS_LO || ''' and ''' || P_STATUS_HI || ''' ');
    ELSE
      IF P_STATUS_HI IS NULL AND P_STATUS_LO IS NOT NULL THEN
        RETURN ('and inventory_item_status_code >= ''' || P_STATUS_LO || ''' ');
      ELSE
        IF P_STATUS_LO IS NULL AND P_STATUS_HI IS NOT NULL THEN
          RETURN ('and inventory_item_status_code <= ''' || P_STATUS_HI || ''' ');
        ELSE
          return(' ');
        END IF;
      END IF;
    END IF;
    RETURN NULL;
  END C_WHEREFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END INV_INVIRDST_XMLP_PKG;


/
