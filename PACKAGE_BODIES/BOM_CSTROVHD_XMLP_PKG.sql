--------------------------------------------------------
--  DDL for Package Body BOM_CSTROVHD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CSTROVHD_XMLP_PKG" AS
/* $Header: CSTROVHDB.pls 120.0 2007/12/24 10:08:04 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      SELECT
        ORGANIZATION_NAME,
        CHART_OF_ACCOUNTS_ID
      INTO P_ORG_NAME,CHART_OF_ACCOUNTS_ID1
      FROM
        ORG_ORGANIZATION_DEFINITIONS
      WHERE ORGANIZATION_ID = BOM_CSTROVHD_XMLP_PKG.ORGANIZATION_ID;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('FND FLEXSQL
                                        CODE="GL#"
                                        NUM=":chart_of_accounts_id"
                                        OUTPUT=":P_FLEXDATA"
                                        APPL_SHORT_NAME="SQLGL"
                                        TABLEALIAS="GL"
                                        MODE="SELECT"
                                        DISPLAY="ALL"')*/NULL;
      /*SRW.MESSAGE(0
                 ,'BOM_CSTROVHD_XMLP_PKG <<     ' || TO_CHAR(SYSDATE
                        ,'Dy Mon DD HH24:MI:SS YYYY'))*/NULL;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(999
                   ,SQLERRM)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    /*SRW.MESSAGE(0
               ,'BOM_CSTROVHD_XMLP_PKG >>     ' || TO_CHAR(SYSDATE
                      ,'Dy Mon DD HH24:MI:SS YYYY'))*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
END BOM_CSTROVHD_XMLP_PKG;


/
