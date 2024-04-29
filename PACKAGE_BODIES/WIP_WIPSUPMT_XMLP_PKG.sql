--------------------------------------------------------
--  DDL for Package Body WIP_WIPSUPMT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPSUPMT_XMLP_PKG" AS
/* $Header: WIPSUPMTB.pls 120.1 2008/01/31 12:46:49 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('
                     FND FLEXSQL CODE="MTLL"
                     APPL_SHORT_NAME="INV"
                     OUTPUT=":P_FLEXDATA"
                     MODE="SELECT"
                     DISPLAY="ALL"
                     TABLEALIAS="L"
                  ')*/NULL;
    RETURN TRUE;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

END WIP_WIPSUPMT_XMLP_PKG;


/
