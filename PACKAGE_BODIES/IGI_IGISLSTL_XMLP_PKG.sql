--------------------------------------------------------
--  DDL for Package Body IGI_IGISLSTL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IGISLSTL_XMLP_PKG" AS
/* $Header: IGISLSTLB.pls 120.0.12010000.1 2008/07/29 08:59:48 appldev ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    P_SECURITY_GROUP_T := nvl(P_SECURITY_GROUP,'%');
    P_TABLE_NAME_T := nvl(P_TABLE_NAME,'%');
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_1FORMULA(SLS_SECURITY_GROUP IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    CP_GRP_NAME := SLS_SECURITY_GROUP;
    RETURN (1);
  END CF_1FORMULA;

  FUNCTION CP_GRP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_GRP_NAME;
  END CP_GRP_NAME_P;

END IGI_IGISLSTL_XMLP_PKG;

/
