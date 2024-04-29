--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_SALES_REPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_SALES_REPS" AS
/* $Header: gmfrepnb.pls 115.1 2002/11/11 00:41:27 rseshadr ship $ */
  CURSOR CUR_AR_GET_SALES_REPS(ST_DATE DATE, EN_DATE DATE)
  IS
  SELECT  NAME,
          '',
          START_DATE_ACTIVE,
          END_DATE_ACTIVE
  FROM    RA_SALESREPS_ALL
  WHERE   CREATION_DATE
  BETWEEN NVL(ST_DATE, CREATION_DATE)
  AND     NVL(EN_DATE, CREATION_DATE);

  PROCEDURE PROC_AR_GET_SALES_REPS(
    	ST_DATE      IN OUT  NOCOPY DATE,
    	EN_DATE      IN OUT  NOCOPY DATE,
    	REP_NAME     OUT     NOCOPY VARCHAR2,
    	ENA_FLAG     OUT     NOCOPY VARCHAR2,
    	ST_DATE_EFF  OUT     NOCOPY DATE,
    	EN_DATE_EFF  OUT     NOCOPY DATE,
    	ROW_TO_FETCH IN OUT  NOCOPY NUMBER,
    	ERROR_STATUS OUT     NOCOPY NUMBER) IS
  BEGIN  /* BEGINNING OF PROCEDURE PROC_AR_GET_SALES_REPS */
    IF NOT CUR_AR_GET_SALES_REPS%ISOPEN THEN
      OPEN CUR_AR_GET_SALES_REPS(ST_DATE, EN_DATE);
    END IF;

    FETCH CUR_AR_GET_SALES_REPS
    INTO  REP_NAME, ENA_FLAG, ST_DATE_EFF, EN_DATE_EFF;

    IF CUR_AR_GET_SALES_REPS%NOTFOUND OR ROW_TO_FETCH = 1 THEN
      CLOSE CUR_AR_GET_SALES_REPS;
      IF CUR_AR_GET_SALES_REPS%NOTFOUND THEN
        ERROR_STATUS := 100;
      END IF;
      RETURN;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
     ERROR_STATUS := SQLCODE;
  END;  /* END OF PROCEDURE PROC_AR_GET_SALES_REPS */
END GMF_AR_GET_SALES_REPS;  /* END GMF_AR_GET_SALES_REPS */

/
