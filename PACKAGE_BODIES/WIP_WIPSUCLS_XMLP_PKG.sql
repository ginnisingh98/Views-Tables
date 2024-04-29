--------------------------------------------------------
--  DDL for Package Body WIP_WIPSUCLS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPSUCLS_XMLP_PKG" AS
/* $Header: WIPSUCLSB.pls 120.0 2007/12/24 10:13:17 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('
                    FND FLEXSQL
                    CODE="GL#"
                    NUM=":P_STRUCT_NUM"
                    APPL_SHORT_NAME="SQLGL"
                    OUTPUT=":P_FLEXDATA"
                    MODE="SELECT"
                    DISPLAY="ALL"
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

END WIP_WIPSUCLS_XMLP_PKG;


/
