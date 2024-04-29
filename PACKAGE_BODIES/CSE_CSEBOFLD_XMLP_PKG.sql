--------------------------------------------------------
--  DDL for Package Body CSE_CSEBOFLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_CSEBOFLD_XMLP_PKG" AS
/* $Header: CSEBOFLDB.pls 120.0 2007/12/24 12:54:58 nchinnam noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    L_STRING1 VARCHAR2(400);
    L_STRING2 VARCHAR2(200);
  BEGIN
    IF P_MOVE_ORDER IS NOT NULL THEN
      L_STRING1 := ' AND mtrh.request_number = :P_MOVE_ORDER';
    END IF;
    IF P_MEANING IS NOT NULL THEN
      L_STRING1 := L_STRING1 || ' AND mln.meaning = :P_MEANING';
    END IF;
    IF P_ORGANIZATION_NAME IS NOT NULL THEN
      L_STRING1 := L_STRING1 || ' AND hr2.name = :P_ORGANIZATION_NAME';
    END IF;
    IF P_FROM IS NOT NULL THEN
      L_STRING1 := L_STRING1 || ' AND mmt.transaction_date >= fnd_date.canonical_to_date(:P_FROM)
                                         and mmt.transaction_date <= nvl(fnd_date.canonical_to_date(:P_TO), mmt.transaction_date)';
    ELSE
      L_STRING1 := L_STRING1 || ' AND mmt.transaction_date <= nvl(fnd_date.canonical_to_date(:P_TO),mmt.transaction_date)';
    END IF;
    IF P_LOCATION_CODE IS NOT NULL THEN
      L_STRING1 := L_STRING1 || ' AND hrl.location_code = :P_LOCATION_CODE';
    END IF;
    L_WHERE_CLAUSE1 := L_STRING1;
    IF P_PROJECT_NUMBER IS NOT NULL THEN
      L_STRING2 := L_STRING2 || ' AND ppa.segment1 = :P_PROJECT_NUMBER';
    END IF;
    IF P_TASK_NUMBER IS NOT NULL THEN
      L_STRING2 := L_STRING2 || ' AND pt.task_number = :P_TASK_NUMBER';
    END IF;
    L_WHERE_CLAUSE2 := L_STRING2;
    if L_WHERE_CLAUSE2 is null then L_WHERE_CLAUSE2:= 'and 1=1'; end if;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;

  FUNCTION P_TOVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    IF P_FROM IS NOT NULL THEN
      IF NVL(FND_DATE.CANONICAL_TO_DATE(P_TO)
         ,SYSDATE) < FND_DATE.CANONICAL_TO_DATE(P_FROM) THEN
        RETURN (FALSE);
      ELSE
        RETURN (TRUE);
      END IF;
    ELSE
      RETURN (TRUE);
    END IF;
  END P_TOVALIDTRIGGER;

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

END CSE_CSEBOFLD_XMLP_PKG;




/
