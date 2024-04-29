--------------------------------------------------------
--  DDL for Package Body INV_INVSRFRT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVSRFRT_XMLP_PKG" AS
/* $Header: INVSRFRTB.pls 120.1 2007/12/25 10:51:34 dwkrishn noship $ */
  function beforereport return boolean is
  begin
    null;
    return true;
  end beforereport;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'SRWEXIT failed')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

END INV_INVSRFRT_XMLP_PKG;


/
