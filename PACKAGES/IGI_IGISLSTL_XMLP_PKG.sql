--------------------------------------------------------
--  DDL for Package IGI_IGISLSTL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IGISLSTL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGISLSTLS.pls 120.0.12010000.1 2008/07/29 08:59:49 appldev ship $ */
  P_SECURITY_GROUP VARCHAR2(40);
  P_SECURITY_GROUP_T  VARCHAR2(40);

  P_TABLE_NAME VARCHAR2(40);
  P_TABLE_NAME_T VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  CP_GRP_NAME VARCHAR2(30);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_1FORMULA(SLS_SECURITY_GROUP IN VARCHAR2) RETURN NUMBER;

  FUNCTION CP_GRP_NAME_P RETURN VARCHAR2;

END IGI_IGISLSTL_XMLP_PKG;

/