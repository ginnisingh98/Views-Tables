--------------------------------------------------------
--  DDL for Package Body CE_CEFPURGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CEFPURGE_XMLP_PKG" AS
/* $Header: CEFPURGEB.pls 120.1 2008/01/07 21:22:17 abraghun noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      IF (P_SQL_TRACE = 'Y') THEN
        EXECUTE IMMEDIATE
          'alter session set sql_trace=true';
      END IF;
      IF (P_FORECAST_HEADER_ID IS NOT NULL) THEN
        SELECT
          NAME
        INTO
          C_TEMP_NAME
        FROM
          CE_FORECAST_HEADERS
        WHERE FORECAST_HEADER_ID = P_FORECAST_HEADER_ID;
      END IF;
      IF (P_FORECAST_BY = 'D') THEN
        C_PURGE_OPTION := 'Purge Forecasts by Days';
      ELSIF (P_FORECAST_BY = 'A') THEN
        C_PURGE_OPTION := 'Purge Forecasts by GL Periods';
      ELSE
        C_PURGE_OPTION := 'Purge All';
      END IF;
      P_FORECAST_START_DATE_1 := to_char(TO_DATE(P_FORECAST_START_DATE
                                            ,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YY');
      P_FORECAST_END_DATE_1 := to_char(TO_DATE(P_FORECAST_END_DATE
                                          ,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YY');
      IF (P_FORECAST_BY in ('D','B')) THEN
        SELECT
          count(*)
        INTO
          C_COUNT
        FROM
          CE_FORECASTS
        WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
           ,FORECAST_HEADER_ID)
          AND START_DATE is not null
          AND TRUNC(START_DATE) >= NVL(P_FORECAST_START_DATE_1
           ,TRUNC(START_DATE))
          AND TRUNC(START_DATE) <= NVL(P_FORECAST_END_DATE_1
           ,TRUNC(START_DATE));
      END IF;
      IF (P_FORECAST_BY in ('A','B')) THEN
        SELECT
          count(*) + NVL(C_COUNT
             ,0)
        INTO
          C_COUNT
        FROM
          CE_FORECASTS CF
        WHERE CF.FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
           ,CF.FORECAST_HEADER_ID)
          AND START_PERIOD in (
          SELECT
            GLP.PERIOD_NAME
          FROM
            GL_PERIODS GLP
          WHERE GLP.PERIOD_SET_NAME = CF.PERIOD_SET_NAME
            AND TRUNC(GLP.START_DATE) >= NVL(P_FORECAST_START_DATE_1
             ,TRUNC(GLP.START_DATE))
            AND TRUNC(GLP.START_DATE) <= NVL(P_FORECAST_END_DATE_1
             ,TRUNC(GLP.START_DATE)) );
      END IF;
      IF (P_DISPLAY_DEBUG = 'Y') THEN
        NULL;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (P_FORECAST_BY in ('D','B')) THEN
        DELETE FROM CE_FORECAST_CELLS
         WHERE FORECAST_ID in (
           SELECT
             FORECAST_ID
           FROM
             CE_FORECASTS
           WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
              ,FORECAST_HEADER_ID)
             AND START_DATE is not null
             AND TRUNC(START_DATE) >= NVL(P_FORECAST_START_DATE_1
              ,TRUNC(START_DATE))
             AND TRUNC(START_DATE) <= NVL(P_FORECAST_END_DATE_1
              ,TRUNC(START_DATE)) );
        DELETE FROM CE_FORECAST_TRX_CELLS
         WHERE FORECAST_ID in (
           SELECT
             FORECAST_ID
           FROM
             CE_FORECASTS
           WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
              ,FORECAST_HEADER_ID)
             AND START_DATE is not null
             AND TRUNC(START_DATE) >= NVL(P_FORECAST_START_DATE_1
              ,TRUNC(START_DATE))
             AND TRUNC(START_DATE) <= NVL(P_FORECAST_END_DATE_1
              ,TRUNC(START_DATE)) );
        DELETE FROM CE_FORECAST_OPENING_BAL
         WHERE FORECAST_ID in (
           SELECT
             FORECAST_ID
           FROM
             CE_FORECASTS
           WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
              ,FORECAST_HEADER_ID)
             AND START_DATE is not null
             AND TRUNC(START_DATE) >= NVL(P_FORECAST_START_DATE_1
              ,TRUNC(START_DATE))
             AND TRUNC(START_DATE) <= NVL(P_FORECAST_END_DATE_1
              ,TRUNC(START_DATE)) );
        DELETE FROM CE_FORECAST_ERRORS
         WHERE FORECAST_ID in (
           SELECT
             FORECAST_ID
           FROM
             CE_FORECASTS
           WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
              ,FORECAST_HEADER_ID)
             AND START_DATE is not null
             AND TRUNC(START_DATE) >= NVL(P_FORECAST_START_DATE_1
              ,TRUNC(START_DATE))
             AND TRUNC(START_DATE) <= NVL(P_FORECAST_END_DATE_1
              ,TRUNC(START_DATE)) );
        DELETE FROM CE_FORECASTS
         WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
            ,FORECAST_HEADER_ID)
           AND START_DATE is not null
           AND TRUNC(START_DATE) >= NVL(P_FORECAST_START_DATE_1
            ,TRUNC(START_DATE))
           AND TRUNC(START_DATE) <= NVL(P_FORECAST_END_DATE_1
            ,TRUNC(START_DATE));
      END IF;
      IF (P_FORECAST_BY in ('A','B')) THEN
        DELETE FROM CE_FORECAST_CELLS
         WHERE FORECAST_ID in (
           SELECT
             FORECAST_ID
           FROM
             CE_FORECASTS CF
           WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
              ,FORECAST_HEADER_ID)
             AND START_PERIOD in (
             SELECT
               GLP.PERIOD_NAME
             FROM
               GL_PERIODS GLP
             WHERE GLP.PERIOD_SET_NAME = CF.PERIOD_SET_NAME
               AND TRUNC(GLP.START_DATE) >= NVL(P_FORECAST_START_DATE_1
                ,TRUNC(GLP.START_DATE))
               AND TRUNC(GLP.START_DATE) <= NVL(P_FORECAST_END_DATE_1
                ,TRUNC(GLP.START_DATE)) ) );
        DELETE FROM CE_FORECAST_TRX_CELLS
         WHERE FORECAST_ID in (
           SELECT
             FORECAST_ID
           FROM
             CE_FORECASTS CF
           WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
              ,FORECAST_HEADER_ID)
             AND START_PERIOD in (
             SELECT
               GLP.PERIOD_NAME
             FROM
               GL_PERIODS GLP
             WHERE GLP.PERIOD_SET_NAME = CF.PERIOD_SET_NAME
               AND TRUNC(GLP.START_DATE) >= NVL(P_FORECAST_START_DATE_1
                ,TRUNC(GLP.START_DATE))
               AND TRUNC(GLP.START_DATE) <= NVL(P_FORECAST_END_DATE_1
                ,TRUNC(GLP.START_DATE)) ) );
        DELETE FROM CE_FORECAST_OPENING_BAL
         WHERE FORECAST_ID in (
           SELECT
             FORECAST_ID
           FROM
             CE_FORECASTS CF
           WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
              ,FORECAST_HEADER_ID)
             AND START_PERIOD in (
             SELECT
               GLP.PERIOD_NAME
             FROM
               GL_PERIODS GLP
             WHERE GLP.PERIOD_SET_NAME = CF.PERIOD_SET_NAME
               AND TRUNC(GLP.START_DATE) >= NVL(P_FORECAST_START_DATE_1
                ,TRUNC(GLP.START_DATE))
               AND TRUNC(GLP.START_DATE) <= NVL(P_FORECAST_END_DATE_1
                ,TRUNC(GLP.START_DATE)) ) );
        DELETE FROM CE_FORECAST_ERRORS
         WHERE FORECAST_ID in (
           SELECT
             FORECAST_ID
           FROM
             CE_FORECASTS CF
           WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
              ,FORECAST_HEADER_ID)
             AND START_PERIOD in (
             SELECT
               GLP.PERIOD_NAME
             FROM
               GL_PERIODS GLP
             WHERE GLP.PERIOD_SET_NAME = CF.PERIOD_SET_NAME
               AND TRUNC(GLP.START_DATE) >= NVL(P_FORECAST_START_DATE_1
                ,TRUNC(GLP.START_DATE))
               AND TRUNC(GLP.START_DATE) <= NVL(P_FORECAST_END_DATE_1
                ,TRUNC(GLP.START_DATE)) ) );
        DELETE FROM CE_FORECASTS CF
         WHERE FORECAST_HEADER_ID = NVL(P_FORECAST_HEADER_ID
            ,FORECAST_HEADER_ID)
           AND START_PERIOD in (
           SELECT
             GLP.PERIOD_NAME
           FROM
             GL_PERIODS GLP
           WHERE GLP.PERIOD_SET_NAME = CF.PERIOD_SET_NAME
             AND TRUNC(GLP.START_DATE) >= NVL(P_FORECAST_START_DATE_1
              ,TRUNC(GLP.START_DATE))
             AND TRUNC(GLP.START_DATE) <= NVL(P_FORECAST_END_DATE_1
              ,TRUNC(GLP.START_DATE)) );
      END IF;
      COMMIT;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_COUNT;
  END C_COUNT_P;

  FUNCTION C_PURGE_OPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PURGE_OPTION;
  END C_PURGE_OPTION_P;

  FUNCTION C_TEMP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TEMP_NAME;
  END C_TEMP_NAME_P;

END CE_CEFPURGE_XMLP_PKG;


/
