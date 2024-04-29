--------------------------------------------------------
--  DDL for Package HXT_HXT951A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT951A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT951AS.pls 120.1 2008/03/26 09:41:10 amakrish noship $ */
  START_DATE DATE;

START_DATE1 varchar2(15);

  PERIOD_TYPE VARCHAR2(32767);

  END_DATE DATE;

END_DATE1 varchar2(15);

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION HIGH1FORMULA(TOT_HOURS IN NUMBER
                       ,HIGH IN NUMBER) RETURN NUMBER;

  FUNCTION LOW1FORMULA(TOT_HOURS IN NUMBER
                      ,LOW IN NUMBER) RETURN NUMBER;

  FUNCTION AVERAGE1FORMULA(TOT_HOURS IN NUMBER
                          ,AVERAGE IN NUMBER) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END HXT_HXT951A_XMLP_PKG;

/
