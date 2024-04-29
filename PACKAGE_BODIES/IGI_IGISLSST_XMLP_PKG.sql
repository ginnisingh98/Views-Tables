--------------------------------------------------------
--  DDL for Package Body IGI_IGISLSST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGISLSST_XMLP_PKG" AS
/* $Header: IGISLSSTB.pls 120.0.12010000.1 2008/07/29 08:59:45 appldev ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    P_OWNER_T := nvl(P_OWNER,'%');
    P_TABLE_NAME_T := nvl(P_TABLE_NAME,'%');
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    null;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_1FORMULA(OWNER IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    CP_OWNER := OWNER;
    RETURN (1);
  END CF_1FORMULA;

  FUNCTION CP_OWNER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_OWNER;
  END CP_OWNER_P;

FUNCTION F_DATE_ENABLED1FORMATTRIGGER(DATE_DISABLED2 IN DATE,DATE_ENABLED2 IN DATE,DATE_REMOVED2 IN DATE,DATE_DISABLED_AU IN DATE,DATE_ENABLED_AU IN DATE,DATE_REMOVED_AU IN DATE) RETURN VARCHAR2 IS
P_DATE     DATE := SYSDATE;

BEGIN

  IF  NVL(DATE_DISABLED2, P_DATE) =  NVL(DATE_DISABLED_AU, P_DATE)
  AND NVL(DATE_ENABLED2,P_DATE) = NVL(DATE_ENABLED_AU, P_DATE)
  AND NVL(DATE_REMOVED2, P_DATE) = NVL(DATE_REMOVED_AU, P_DATE)
  THEN
     RETURN ('N');
  ELSE
     RETURN ('Y');
  END IF;

END;


END IGI_IGISLSST_XMLP_PKG;

/