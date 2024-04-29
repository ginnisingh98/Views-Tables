--------------------------------------------------------
--  DDL for Package Body GMF_AR_GET_SALESREP_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_AR_GET_SALESREP_CODE" AS
/* $Header: gmfrepcb.pls 115.1 2002/11/11 00:40:48 rseshadr ship $ */
  CURSOR GET_SALESREP_CODE(STARTDATE    DATE,
                           ENDDATE      DATE,
                           SALESREPNAME VARCHAR2) IS
  SELECT SALESREP_ID
  FROM   RA_SALESREPS_ALL
  WHERE  NAME LIKE NVL(SALESREPNAME,'%')
  AND    CREATION_DATE
  BETWEEN NVL(STARTDATE,CREATION_DATE)
          AND
          NVL(ENDDATE,CREATION_DATE);

  PROCEDURE RA_GET_SALESREP_CODE(STARTDATE                   DATE,
                                 ENDDATE                     DATE,
                                 SALESREPNAME                VARCHAR2,
                                 SALESREPID    OUT    NOCOPY NUMBER,
                                 ROW_TO_FETCH  IN OUT NOCOPY NUMBER,
                                 STATUSCODE    OUT    NOCOPY NUMBER) IS
  BEGIN
    IF NOT GET_SALESREP_CODE%ISOPEN THEN
      OPEN GET_SALESREP_CODE(STARTDATE,ENDDATE,SALESREPNAME);
    END IF;

    FETCH GET_SALESREP_CODE INTO SALESREPID;

    IF GET_SALESREP_CODE%NOTFOUND OR ROW_TO_FETCH = 1 THEN
      CLOSE GET_SALESREP_CODE;
      IF GET_SALESREP_CODE%NOTFOUND THEN
        STATUSCODE := 100;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      STATUSCODE := SQLCODE;
  END;
END GMF_AR_GET_SALESREP_CODE;

/
