--------------------------------------------------------
--  DDL for Package Body QA_QASEQAUD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_QASEQAUD_XMLP_PKG" AS
/* $Header: QASEQAUDB.pls 120.1 2007/12/24 10:24:41 krreddy noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
  P_CHAR_LIMITER:= ' ';
  P_AUDIT_DATE_LIMITER := ' ';
    IF P_CHAR_ID IS NOT NULL THEN
      P_CHAR_LIMITER := 'and qv.char_id = :p_char_id ';
    END IF;
    IF P_DATE_FROM IS NOT NULL AND P_DATE_TO IS NOT NULL THEN
      P_AUDIT_DATE_LIMITER := ' and qv.audit_date BETWEEN  :p_date_from AND :p_date_to ';
    ELSIF P_DATE_FROM IS NOT NULL THEN
      P_AUDIT_DATE_LIMITER := ' and  qv.audit_date > = :p_date_from ';
    ELSIF P_DATE_TO IS NOT NULL THEN
      P_AUDIT_DATE_LIMITER := ' and qv.audit_date < = :p_date_to ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION P_CHAR_NAMEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    IF P_CHAR_ID IS NOT NULL THEN
      SELECT
        NAME
      INTO P_CHAR_NAME
      FROM
        QA_CHARS
      WHERE CHAR_ID = P_CHAR_ID;
    END IF;
    RETURN (TRUE);
  END P_CHAR_NAMEVALIDTRIGGER;

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

END QA_QASEQAUD_XMLP_PKG;



/