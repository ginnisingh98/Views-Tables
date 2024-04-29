--------------------------------------------------------
--  DDL for Package GMF_AR_GET_SALES_REPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_AR_GET_SALES_REPS" AUTHID CURRENT_USER AS
/* $Header: gmfrepns.pls 115.2 2002/11/11 00:41:38 rseshadr ship $ */
  PROCEDURE PROC_AR_GET_SALES_REPS(
    			ST_DATE      IN OUT  NOCOPY DATE,
    			EN_DATE      IN OUT  NOCOPY DATE,
    			REP_NAME     OUT     NOCOPY VARCHAR2,
    			ENA_FLAG     OUT     NOCOPY VARCHAR2,
    			ST_DATE_EFF  OUT     NOCOPY DATE,
    			EN_DATE_EFF  OUT     NOCOPY DATE,
    			ROW_TO_FETCH IN OUT  NOCOPY NUMBER,
    			ERROR_STATUS OUT     NOCOPY NUMBER);
END GMF_AR_GET_SALES_REPS;

 

/
