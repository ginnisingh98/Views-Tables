--------------------------------------------------------
--  DDL for Package GMF_GLR20USR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GLR20USR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLR20USRS.pls 120.0 2007/12/24 13:30:31 nchinnam noship $ */
  P_FROM_SOURCE VARCHAR2(4);
  LP_FROM_SOURCE VARCHAR2(4);
  P_TO_SOURCE VARCHAR2(4);
  LP_TO_SOURCE VARCHAR2(4);
  P_FROM_EVENT VARCHAR2(4);
  LP_FROM_EVENT VARCHAR2(4);
  P_TO_EVENT VARCHAR2(4);
  LP_TO_EVENT VARCHAR2(4);
  P_FROM_SUB_EVENT VARCHAR2(4);
  LP_FROM_SUB_EVENT VARCHAR2(4);
  P_TO_SUB_EVENT VARCHAR2(4);
  LP_TO_SUB_EVENT VARCHAR2(4);
  P_FROM_ACCT_TTL VARCHAR2(4);
  LP_FROM_ACCT_TTL VARCHAR2(4);
  P_TO_ACCT_TTL VARCHAR2(4);
  LP_TO_ACCT_TTL VARCHAR2(4);
  P_CONC_REQUEST_ID NUMBER;
  SOURCECP VARCHAR2(200):=' ';
  EVENTCP VARCHAR2(200):=' ';
  SUBEVENTCP VARCHAR2(2000):=' ';
  ACCTTTLCP VARCHAR2(200):=' ';
  FUNCTION SOURCECFFORMULA RETURN VARCHAR2;
  FUNCTION EVENTCFFORMULA RETURN VARCHAR2;
  FUNCTION SUBEVENTCFFORMULA RETURN VARCHAR2;
  FUNCTION ACCTTTLCFFORMULA RETURN VARCHAR2;
  PROCEDURE GMF_GLR20USR_XMLP_PKG_HDR;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION SOURCECP_P RETURN VARCHAR2;
  FUNCTION EVENTCP_P RETURN VARCHAR2;
  FUNCTION SUBEVENTCP_P RETURN VARCHAR2;
  FUNCTION ACCTTTLCP_P RETURN VARCHAR2;
END GMF_GLR20USR_XMLP_PKG;


/