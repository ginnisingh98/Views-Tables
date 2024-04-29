--------------------------------------------------------
--  DDL for Package QA_QLTCHWUR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_QLTCHWUR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: QLTCHWURS.pls 120.0 2007/12/24 10:34:04 krreddy noship $ */
  P_ORGANIZATION_ID NUMBER;

  P_CHARACTERISTIC VARCHAR2(30);

  LP_CHARACTERISTIC VARCHAR2(30);

  P_CHARACTERISTIC_LIMITER VARCHAR2(250):=' ';

  P_ORG_DELIMITER VARCHAR2(250);

  P_CHAR_ENABLED VARCHAR2(32767);

  P_CHAR_ENABLED_DELIMITER VARCHAR2(250):=' ';

  P_PLAN_CHAR_ENABLED VARCHAR2(32767);

  P_PLAN_ENABLED_DELIMITER VARCHAR2(250):=' ';

  P_CHAR_ENABLED_MEANING VARCHAR2(80);

  LP_CHAR_ENABLED_MEANING VARCHAR2(80);

  P_PLAN_ENABLED_MEANING VARCHAR2(80);

  LP_PLAN_ENABLED_MEANING VARCHAR2(80);

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_DEF_VALUE_NUMBERFORMULA(DATATYPE1 IN NUMBER
                                    ,DEFAULT_VALUE1 IN VARCHAR2) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END QA_QLTCHWUR_XMLP_PKG;


/
