--------------------------------------------------------
--  DDL for Package GMF_GLR17USR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GLR17USR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: GLR17USRS.pls 120.0 2007/12/24 13:29:24 nchinnam noship $ */
  COMPANY VARCHAR2(40);
  FROM_ORGANIZATION VARCHAR2(4);
  LFROM_ORGANIZATION VARCHAR2(4);
  FROM_WHSE VARCHAR2(4);
  LFROM_WHSE VARCHAR2(4);
  TO_WHSE VARCHAR2(4);
  LTO_WHSE VARCHAR2(4);
  TO_ORGANIZATION VARCHAR2(4);
  LTO_ORGANIZATION VARCHAR2(4);
  FROM_ACCTG_UNIT VARCHAR2(240);
  LFROM_ACCTG_UNIT VARCHAR2(240);
  TO_ACCTG_UNIT VARCHAR2(240);
  LTO_ACCTG_UNIT VARCHAR2(240);
  SY_ALL VARCHAR2(3);
  NONBLOCKSQL VARCHAR2(5);
  P_CONC_REQUEST_ID NUMBER;
  ACCTG_UNITCP VARCHAR2(200):=' ';
  ORGN_CODECP VARCHAR2(200):=' ';
  WHSE_CODECP VARCHAR2(200):=' ';
  FUNCTION WHSE_CODECFFORMULA RETURN VARCHAR2;
  FUNCTION ACCTG_UNITCFFORMULA RETURN VARCHAR2;
  FUNCTION ORGN_CODECFFORMULA RETURN VARCHAR2;
  FUNCTION ORGN_CODECPFORMULA(ORGN_CODECF IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION ACCTG_UNITCPFORMULA(ACCTG_UNITCF IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION WHSE_CODECPFORMULA(WHSE_CODECF IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
  PROCEDURE GLR19USR_HEADER;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION ACCTG_UNITCP_P RETURN VARCHAR2;
  FUNCTION ORGN_CODECP_P RETURN VARCHAR2;
  FUNCTION WHSE_CODECP_P RETURN VARCHAR2;
END GMF_GLR17USR_XMLP_PKG;


/