--------------------------------------------------------
--  DDL for Package Body PA_PAPERACR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAPERACR_XMLP_PKG" AS
/* $Header: PAPERACRB.pls 120.1 2008/01/03 11:09:13 krreddy noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    X_RETURN_STATUS VARCHAR2(1);
    L_COUNT NUMBER;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    PA_ACTION_SETS_PUB.PERFORM_ACTION_SETS(P_ACTION_SET_TYPE_CODE
                                          ,P_PROJECT_NUMBER_FROM
                                          ,P_PROJECT_NUMBER_TO
                                          ,P_DEBUG_MODE
                                          ,X_RETURN_STATUS);
    IF P_DEBUG_MODE = 'Y' THEN
      FND_FILE.PUT_LINE(1
                       ,'after perform_action_sets call');
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

END PA_PAPERACR_XMLP_PKG;


/
