--------------------------------------------------------
--  DDL for Package WIP_WIPTSMOV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WIPTSMOV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WIPTSMOVS.pls 120.2 2008/01/31 13:13:07 npannamp noship $ */
  P_ORGANIZATION_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER := 0;

  P_FLEXDATA VARCHAR2(850);

  P_SORT NUMBER;

  P_SHOW_DETAILS NUMBER;

  P_FROM_DATE DATE;

  P_FROM_DATE1 VARCHAR2(30);

  P_TO_DATE DATE;

  P_TO_DATE1 VARCHAR2(30);

  P_FROM_JOB VARCHAR2(40);

  P_TO_JOB VARCHAR2(40);

  P_FROM_LINE VARCHAR2(10);

  P_TO_LINE VARCHAR2(10);

QTY_PRECISION varchar2(40);

  P_FROM_REASON VARCHAR2(30);

  P_TO_REASON VARCHAR2(30);

  P_FLEXWHERE VARCHAR2(2400);

  P_TO_ASSEMBLY VARCHAR2(850);

  P_FROM_ASSEMBLY VARCHAR2(850);

  P_QTY_PRECISION NUMBER;

  P_DEBUG NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION LIMIT_DATES RETURN CHARACTER;

  FUNCTION LIMIT_JOBS RETURN CHARACTER;

  FUNCTION LIMIT_LINES RETURN CHARACTER;

  FUNCTION LIMIT_REASONS RETURN CHARACTER;

  FUNCTION C_LIMIT_DATESFORMULA RETURN VARCHAR2;

  FUNCTION C_LIMIT_REASONSFORMULA RETURN VARCHAR2;

  FUNCTION C_LIMIT_LINESFORMULA RETURN VARCHAR2;

  FUNCTION C_LIMIT_JOBSFORMULA RETURN VARCHAR2;

  FUNCTION C_LIMIT_ASSEMBLIESFORMULA RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_FLEX_SORTFORMULA(C_FLEX_SORT IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

END WIP_WIPTSMOV_XMLP_PKG;



/
