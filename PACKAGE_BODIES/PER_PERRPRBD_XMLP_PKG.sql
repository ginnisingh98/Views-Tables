--------------------------------------------------------
--  DDL for Package Body PER_PERRPRBD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPRBD_XMLP_PKG" AS
/* $Header: PERRPRBDB.pls 120.1 2007/12/06 11:32:03 amakrish noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      V_PERIOD_NAME VARCHAR2(60);
      V_PERIOD_START_DATE DATE;
      V_PERIOD_END_DATE DATE;
      V_UNIT VARCHAR2(30);
    BEGIN
      --HR_STANDARD.EVENT('BEFORE REPORT');
      BEGIN
        SELECT
          BUD.UNIT
        INTO V_UNIT
        FROM
          PER_BUDGETS BUD
        WHERE BUD.BUDGET_ID = P_BUDGET_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
      C_UNIT := V_UNIT;
      C_BUSINESS_GROUP_NAME := GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
      C_BUDGET_NAME := GET_BUDGET(P_BUDGET_ID);
      C_BUDGET_VERSION := GET_BUDGET_VERSION(P_BUDGET_ID
                                            ,P_BUDGET_VERSION_ID);
      GET_TIME_PERIOD(P_START_TIME_PERIOD_ID
                     ,V_PERIOD_NAME
                     ,V_PERIOD_START_DATE
                     ,V_PERIOD_END_DATE);
      C_START_PERIOD_NAME := V_PERIOD_NAME;
      GET_TIME_PERIOD(P_END_TIME_PERIOD_ID
                     ,V_PERIOD_NAME
                     ,V_PERIOD_START_DATE
                     ,V_PERIOD_END_DATE);
      C_END_PERIOD_NAME := V_PERIOD_NAME;
      C_REPORT_SUBTITLE := 'From ' || C_START_PERIOD_NAME || ' to ' || C_END_PERIOD_NAME;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_START_VALUEFORMULA(ORGANIZATION_ID IN NUMBER
                               ,JOB_ID IN NUMBER
                               ,POSITION_ID IN NUMBER
                               ,GRADE_ID IN NUMBER
                               ,START_DATE IN DATE
                               ,END_DATE IN DATE
                               ,BUDGET_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      V_START_VALUE NUMBER;
      V_END_VALUE NUMBER;
      V_AMOUNT NUMBER;
      V_PERCENTAGE VARCHAR2(10);
    BEGIN
      GET_ACTUALS(C_UNIT
                 ,P_BUSINESS_GROUP_ID
                 ,ORGANIZATION_ID
                 ,JOB_ID
                 ,POSITION_ID
                 ,GRADE_ID
                 ,START_DATE
                 ,END_DATE
                 ,BUDGET_VALUE
                 ,V_START_VALUE
                 ,V_END_VALUE
                 ,V_AMOUNT
                 ,V_PERCENTAGE);
      C_END_VALUE := V_END_VALUE;
      C_AMOUNT := V_AMOUNT;
      C_PERCENTAGE := V_PERCENTAGE;
      RETURN V_START_VALUE;
    END;
    RETURN NULL;
  END C_START_VALUEFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_END_VALUE_P RETURN NUMBER IS
  BEGIN
    RETURN C_END_VALUE;
  END C_END_VALUE_P;

  FUNCTION C_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_AMOUNT;
  END C_AMOUNT_P;

  FUNCTION C_PERCENTAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PERCENTAGE;
  END C_PERCENTAGE_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_SUBTITLE;
  END C_REPORT_SUBTITLE_P;

  FUNCTION C_BUDGET_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUDGET_NAME;
  END C_BUDGET_NAME_P;

  FUNCTION C_BUDGET_VERSION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUDGET_VERSION;
  END C_BUDGET_VERSION_P;

  FUNCTION C_START_PERIOD_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_START_PERIOD_NAME;
  END C_START_PERIOD_NAME_P;

  FUNCTION C_END_PERIOD_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_END_PERIOD_NAME;
  END C_END_PERIOD_NAME_P;

  FUNCTION C_UNIT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_UNIT;
  END C_UNIT_P;

  FUNCTION GET_BUDGET(P_BUDGET_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    	begin
  		X0 := HR_REPORTS.GET_BUDGET(P_BUDGET_ID);
  	end;
    RETURN X0;
  END GET_BUDGET;

  FUNCTION GET_BUDGET_VERSION(P_BUDGET_ID IN NUMBER
                             ,P_BUDGET_VERSION_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
	  begin
	  	X0 := HR_REPORTS.GET_BUDGET_VERSION(P_BUDGET_ID,P_BUDGET_VERSION_ID);
	  end;
    RETURN X0;
  END GET_BUDGET_VERSION;

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
      X0 VARCHAR2(2000);
    BEGIN
        begin
        	X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
        end;
    RETURN X0;
  END GET_BUSINESS_GROUP;

  PROCEDURE GET_TIME_PERIOD(P_TIME_PERIOD_ID IN NUMBER
                           ,P_PERIOD_NAME OUT NOCOPY VARCHAR2
                           ,P_START_DATE OUT NOCOPY DATE
                           ,P_END_DATE OUT NOCOPY DATE) IS
  BEGIN
	  begin
	  	HR_REPORTS.GET_TIME_PERIOD(P_TIME_PERIOD_ID, P_PERIOD_NAME,
                P_START_DATE, P_END_DATE);
          end;
  END GET_TIME_PERIOD;

    PROCEDURE GET_ACTUALS(P_UNIT IN VARCHAR2
                         ,P_BUS_GROUP_ID IN NUMBER
                         ,P_ORGANISATION_ID IN NUMBER
                         ,P_JOB_ID IN NUMBER
                         ,P_POSITION_ID IN NUMBER
                         ,P_GRADE_ID IN NUMBER
                         ,P_START_DATE IN DATE
                         ,P_END_DATE IN DATE
                         ,P_ACTUAL_VAL IN NUMBER
                         ,P_ACTUAL_START_VAL OUT NOCOPY NUMBER
                         ,P_ACTUAL_END_VAL OUT NOCOPY NUMBER
                         ,P_VARIANCE_AMOUNT OUT NOCOPY NUMBER
                         ,P_VARIANCE_PERCENT OUT NOCOPY VARCHAR2) IS
    BEGIN

    	begin
    		HRGETACT.GET_ACTUALS(P_UNIT, P_BUS_GROUP_ID,
                      P_ORGANISATION_ID, P_JOB_ID, P_POSITION_ID, P_GRADE_ID, P_START_DATE,
                  P_END_DATE, P_ACTUAL_VAL, P_ACTUAL_START_VAL, P_ACTUAL_END_VAL, P_VARIANCE_AMOUNT,
                  P_VARIANCE_PERCENT);
        end;
  END GET_ACTUALS;

END PER_PERRPRBD_XMLP_PKG;

/