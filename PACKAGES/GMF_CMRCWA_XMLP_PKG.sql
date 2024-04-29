--------------------------------------------------------
--  DDL for Package GMF_CMRCWA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_CMRCWA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CMRCWAS.pls 120.0 2007/12/24 13:27:33 nchinnam noship $ */
  SORT_BY VARCHAR2(40);
  FROM_COST_ORGN VARCHAR2(240);
  TO_COST_ORGN VARCHAR2(240);
  FROM_INV_ORGN VARCHAR2(240);
  TO_INV_ORGN VARCHAR2(240);
  SY_ALL VARCHAR2(3);
  NONBLOCKSQL VARCHAR2(5);
  P_FROM_COST_ORGN_ID NUMBER;
  P_TO_COST_ORGN_ID NUMBER;
  P_FROM_INV_ORGN_ID NUMBER;
  P_TO_INV_ORGN_ID NUMBER;
  P_CONC_REQUEST_ID NUMBER;
  --COST_ORGNCP VARCHAR2(500);
  COST_ORGNCP VARCHAR2(500):= 'and 1=1';
  --INV_ORGNCP VARCHAR2(500);
  INV_ORGNCP VARCHAR2(500):= 'and 1=1';
  FUNCTION G_COST_ORGANIZATIONGROUPFILTER RETURN BOOLEAN;
  FUNCTION G_INV_ORGANIZATIONGROUPFILTER RETURN BOOLEAN;
  FUNCTION COST_ORGNCPFORMULA(COST_ORGNCF IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION COST_ORGNCFFORMULA RETURN VARCHAR2;
  FUNCTION INV_ORGNCPFORMULA(INV_ORGNCF IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION INV_ORGNCFFORMULA RETURN VARCHAR2;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
  PROCEDURE GMF_CMRCWA_XMLP_PKG_HEADER;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION COST_ORGNCP_P RETURN VARCHAR2;
  FUNCTION INV_ORGNCP_P RETURN VARCHAR2;
END GMF_CMRCWA_XMLP_PKG;


/