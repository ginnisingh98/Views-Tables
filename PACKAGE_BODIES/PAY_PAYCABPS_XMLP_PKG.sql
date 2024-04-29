--------------------------------------------------------
--  DDL for Package Body PAY_PAYCABPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYCABPS_XMLP_PKG" AS
/* $Header: PAYCABPSB.pls 120.0 2007/12/28 06:42:50 srikrish noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_START_DATE VARCHAR2(11);
    L_END_DATE VARCHAR2(11);
    L_END_DATE2 DATE;
    L_TRACE VARCHAR2(30) := '';
    L_LOCATION_CODE VARCHAR2(60);
    L_PROVINCE_NAME VARCHAR2(25);
    L_GRE_NAME VARCHAR2(240);
    LN_ATT_FLAG NUMBER;
    LC_SEEDBAL_STATUS VARCHAR2(10) := 'N';
    LC_SUPPEARN_STATUS VARCHAR2(10) := 'N';
    LD_REF_MON_ST_DATE DATE;
    LD_REF_MON_END_DATE DATE;
    CURSOR CSR_GET_TRACE_PARAM IS
      SELECT
        UPPER(PARAMETER_VALUE)
      FROM
        PAY_ACTION_PARAMETERS
      WHERE PARAMETER_NAME = 'TRACE';
    CURSOR CSR_GET_GRE_NAME(CP_GRE IN NUMBER) IS
      SELECT
        NAME
      FROM
        HR_ALL_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = CP_GRE;
    CURSOR CSR_GET_ATTRIBUTE_DEF IS
      SELECT
        1
      FROM
        PAY_BAL_ATTRIBUTE_DEFINITIONS
      WHERE ATTRIBUTE_NAME in ( 'PAY_CA_BPS_SEEDED_BALANCES' , 'PAY_CA_BPS_SUPP_EARNINGS' )
        AND LEGISLATION_CODE = 'CA';
  BEGIN
   -- HR_STANDARD.EVENT('BEFORE REPORT');


    C_BUSINESS_GROUP_NAME := GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    OPEN CSR_GET_TRACE_PARAM;
    FETCH CSR_GET_TRACE_PARAM
     INTO
       L_TRACE;
    CLOSE CSR_GET_TRACE_PARAM;


    IF L_TRACE = 'Y' THEN
      EXECUTE IMMEDIATE
        'ALTER session SET SQL_TRACE TRUE';
    END IF;
    IF P_REFERENCE_MONTH IS NULL THEN
      RAISE_APPLICATION_ERROR(-20101
                             ,NULL);
    ELSE
      SELECT
        TO_CHAR(TRUNC(FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                                       ,1
                                                       ,10))
                     ,'MM')
               ,'DD/MM'),
        TO_CHAR(LAST_DAY(FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                                          ,1
                                                          ,10)))
               ,'DD/MM'),
        LAST_DAY(FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                                  ,1
                                                  ,10))),
        FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                         ,1
                                         ,10)),
        LAST_DAY(FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                                  ,1
                                                  ,10)))
      INTO
        L_START_DATE
        ,L_END_DATE
        ,L_END_DATE2
        ,LD_REF_MON_ST_DATE
        ,LD_REF_MON_END_DATE
      FROM
        DUAL;
      C_START_DATE := L_START_DATE;
      C_END_DATE := L_END_DATE;
      P_END_DATE := L_END_DATE2;
    END IF;
    IF P_PROVINCE IS NOT NULL THEN
      SELECT
        PROVINCE_NAME
      INTO
        L_PROVINCE_NAME
      FROM
        PAY_CA_PROVINCES_V
      WHERE PROVINCE_ABBREV = P_PROVINCE;
      C_PROVINCE_NAME := L_PROVINCE_NAME;
    END IF;
    IF P_LOCATION IS NOT NULL THEN
      SELECT
        LOCATION_CODE
      INTO
        L_LOCATION_CODE
      FROM
        HR_LOCATIONS
      WHERE LOCATION_ID = P_LOCATION;
      C_LOCATION_CODE := L_LOCATION_CODE;
    END IF;
    IF P_GRE IS NOT NULL THEN
      OPEN CSR_GET_GRE_NAME(P_GRE);
      FETCH CSR_GET_GRE_NAME
       INTO
         L_GRE_NAME;
      CLOSE CSR_GET_GRE_NAME;
      C_GRE_NAME := L_GRE_NAME;
    END IF;
    OPEN CSR_GET_ATTRIBUTE_DEF;
    FETCH CSR_GET_ATTRIBUTE_DEF
     INTO
       LN_ATT_FLAG;
    CLOSE CSR_GET_ATTRIBUTE_DEF;
    IF LN_ATT_FLAG = 1 THEN
      LC_SEEDBAL_STATUS := PAY_CA_PAYROLL_UTILS.CHECK_BALANCE_STATUS(LD_REF_MON_ST_DATE
                                                                    ,P_BUSINESS_GROUP_ID
                                                                    ,'PAY_CA_BPS_SEEDED_BALANCES');
      LC_SUPPEARN_STATUS := PAY_CA_PAYROLL_UTILS.CHECK_BALANCE_STATUS(LD_REF_MON_ST_DATE
                                                                     ,P_BUSINESS_GROUP_ID
                                                                     ,'PAY_CA_BPS_SUPP_EARNINGS');
    ELSE
      NULL;
    END IF;
    IF LC_SEEDBAL_STATUS = 'Y' THEN
      CP_SEED_BAL_FLAG := 'Y';
    ELSE
      CP_SEED_BAL_FLAG := 'N';
    END IF;
    IF LC_SUPPEARN_STATUS = 'Y' THEN
      CP_SUPP_EARN_FLAG := 'Y';
      CP_SUPP_EARN_VIEW := 'PAY_CA_RB_SUPP_EARNINGS_V';
    ELSE
      CP_SUPP_EARN_FLAG := 'N';
      CP_SUPP_EARN_VIEW := 'PAY_CA_SUPP_EARNINGS_V';
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    L_START_DATE VARCHAR2(11);
    L_END_DATE VARCHAR2(11);
    CURSOR C_GRE_TYPE(CP_GRE IN NUMBER) IS
      SELECT
        ORG_INFORMATION5
      FROM
        HR_ORGANIZATION_INFORMATION
      WHERE ORGANIZATION_ID = CP_GRE
        AND ORG_INFORMATION_CONTEXT = 'Canada Employer Identification';
    L_GRE_TYPE VARCHAR2(10);
  BEGIN
    P_REFERENCE_MONTH := TO_CHAR(FND_DATE.CANONICAL_TO_DATE(P_CANONICAL_REFERENCE_MONTH)
                                ,'MON-YYYY');
    IF P_GRE IS NOT NULL THEN
      BEGIN
        OPEN C_GRE_TYPE(P_GRE);
        FETCH C_GRE_TYPE
         INTO
           L_GRE_TYPE;
        CLOSE C_GRE_TYPE;
        IF L_GRE_TYPE = 'T4/RL1' THEN
          LP_GRE := 'AND hsck.segment1= TO_CHAR(:P_GRE)
                                           AND to_char(ou.organization_id) = hsck.segment1';
        ELSIF L_GRE_TYPE = 'T4A/RL1' THEN
          LP_GRE := 'AND hsck.segment11= TO_CHAR(:P_GRE)
                                           AND to_char(ou.organization_id) = hsck.segment11';
        ELSIF L_GRE_TYPE = 'T4A/RL2' THEN
          LP_GRE := 'AND hsck.segment12= TO_CHAR(:P_GRE)
                                           AND to_char(ou.organization_id) = hsck.segment12';
        END IF;
      END;
    END IF;
    IF P_GRE IS NULL THEN
      LP_GRE := 'AND ((to_char(ou.organization_id) = hsck.segment1)
                                   OR (to_char(ou.organization_id) = hsck.segment11)
                                   OR  (to_char(ou.organization_id) = hsck.segment12))';
    END IF;
    IF P_PROVINCE_OR_LOCATION IS NOT NULL THEN
      BEGIN
        IF (P_PROVINCE_OR_LOCATION = 'PROVINCE') AND (P_PROVINCE IS NOT NULL) THEN
          LP_PROVINCE_OR_LOCATION := 'and hl.region_1=:P_PROVINCE';
        ELSIF (P_PROVINCE_OR_LOCATION = 'LOCATION') AND (P_LOCATION IS NOT NULL) THEN
          LP_PROVINCE_OR_LOCATION := 'and hl.location_id=:P_LOCATION';
        END IF;
      END;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION L_ALL_EMP_AVG_HRSFORMULA(REGULAR_HRS_WORKED IN NUMBER
                                   ,CF_EMP_COUNT IN NUMBER
                                   ,END_DATE IN DATE
                                   ,START_DATE IN DATE) RETURN NUMBER IS
    L_AVG_HRS_WORKED NUMBER(10,2);
    L_DAYS NUMBER;
    L_WEEKS NUMBER(10,2);
  BEGIN
    IF (REGULAR_HRS_WORKED > 0) AND (CF_EMP_COUNT > 0) THEN
      L_DAYS := (END_DATE - START_DATE) + 1;
      L_WEEKS := ROUND((L_DAYS / 7)
                      ,2);
      L_AVG_HRS_WORKED := ROUND(((REGULAR_HRS_WORKED / L_WEEKS) / CF_EMP_COUNT)
                               ,2);
    END IF;
    RETURN (L_AVG_HRS_WORKED);
  END L_ALL_EMP_AVG_HRSFORMULA;

  FUNCTION CF_FEEDFORMULA(PROV_OR_LOC IN VARCHAR2
                         ,GRE_NAME IN VARCHAR2) RETURN CHAR IS
    L_LOCATION_CODE VARCHAR2(20);
  BEGIN
    IF P_PROVINCE_OR_LOCATION = 'PROVINCE' THEN
      CP_PROVINCE := PROV_OR_LOC;
      CP_LOCATION := NULL;
    ELSIF P_PROVINCE_OR_LOCATION = 'LOCATION' THEN
      CP_LOCATION := PROV_OR_LOC;
      CP_PROVINCE := NULL;
      SELECT
        LOCATION_CODE
      INTO
        L_LOCATION_CODE
      FROM
        HR_LOCATIONS
      WHERE LOCATION_ID = TO_NUMBER(PROV_OR_LOC);
      CP_LOCATION_CODE := L_LOCATION_CODE;
    ELSIF P_PROVINCE_OR_LOCATION IS NULL THEN
      CP_PROVINCE := PROV_OR_LOC;
      CP_LOCATION := NULL;
    END IF;
    CP_GRE_NAME := GRE_NAME;
    RETURN (' ');
  END CF_FEEDFORMULA;

  FUNCTION G_PAYMENTSGROUPFILTER(HOURLY_PAID_AMT IN NUMBER
                                ,SALARIED_PAID_AMT IN NUMBER
                                ,OTHER_PAID_AMT IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF ((HOURLY_PAID_AMT = 0) AND (SALARIED_PAID_AMT = 0) AND (OTHER_PAID_AMT = 0)) THEN
      RETURN (FALSE);
    ELSE
      RETURN (TRUE);
    END IF;
  END G_PAYMENTSGROUPFILTER;

  FUNCTION CF_EMP_COUNTFORMULA(PP_PAY_BASIS IN VARCHAR2
                              ,GRE IN NUMBER
                              ,PP_PAYROLL_NAME IN VARCHAR2) RETURN NUMBER IS
    L_COUNT NUMBER;
  BEGIN
    IF PP_PAY_BASIS = 'OTHER' THEN
      SELECT
        nvl(count(*),
            0)
      INTO
        L_COUNT
      FROM
        (   SELECT
            PPF.PERSON_ID,
            PP.PAYROLL_NAME,
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'HOURLY'
                  ,'ANNUAL'
                  ,'SALARIED'
                  ,'MONTHLY'
                  ,'SALARIED'
                  ,'PERIOD'
                  ,'SALARIED'
                  ,'OTHER') PAY_BASIS,
            PAY_CA_BALANCE_PKG.CALL_CA_BALANCE_GET_VALUE('Regular Earnings'
                                                        ,'PTD'
                                                        ,MAX(PAA.ASSIGNMENT_ACTION_ID)
                                                        ,PAA.ASSIGNMENT_ID
                                                        ,NULL
                                                        ,PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('REPORT_LEVEL')
                                                        ,PAA.TAX_UNIT_ID
                                                        ,PPA.BUSINESS_GROUP_ID
                                                        ,NVL(PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('JURISDICTION_CODE')
                                                           ,NULL)) REGULAR_GROSS
          FROM
            HR_LOCATIONS_ALL HL,
            PER_ALL_PEOPLE_F PPF,
            PER_PAY_BASES PPB,
            PER_ALL_ASSIGNMENTS_F PAF,
            PAY_PAYROLLS_F PP,
            PAY_ASSIGNMENT_ACTIONS PAA,
            PAY_PAYROLL_ACTIONS PPA,
            PER_TIME_PERIODS PTP
          WHERE PTP.TIME_PERIOD_ID in (
            SELECT
              MAX(PTP2.TIME_PERIOD_ID)
            FROM
              PER_TIME_PERIODS PTP2,
              PAY_ALL_PAYROLLS_F PPF2
            WHERE TO_CHAR(PTP2.END_DATE
                   ,'YYYY/MM') = TO_CHAR(FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                                     ,1
                                                     ,10))
                   ,'YYYY/MM')
              AND PPF2.PAYROLL_ID = PTP2.PAYROLL_ID
              AND PPF2.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
            GROUP BY
              PPF2.PAYROLL_ID,
              PTP2.PERIOD_TYPE )
            AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
            AND PPA.EFFECTIVE_DATE between PTP.START_DATE
            AND PTP.END_DATE
            AND PPA.ACTION_TYPE in ( 'R' , 'Q' )
            AND PPA.ACTION_STATUS = 'C'
            AND PTP.PAYROLL_ID = PPA.PAYROLL_ID
            AND PPA.BUSINESS_GROUP_ID + 0 = NVL(P_BUSINESS_GROUP_ID
             ,PPA.BUSINESS_GROUP_ID)
            AND EXISTS (
            SELECT
              'X'
            FROM
              PAY_PAYROLL_ACTIONS PPA2,
              PAY_RUN_TYPES_F PRT
            WHERE PPA2.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
              AND NVL(PPA2.RUN_TYPE_ID
               ,-1) = PRT.RUN_TYPE_ID
              AND SUBSTR(PRT.SHORTNAME
                  ,1
                  ,1) in ( 'R' , 'T' ) )
            AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
            AND PAA.ACTION_STATUS = 'C'
            AND PPA.PAYROLL_ID = PP.PAYROLL_ID
            AND PPA.EFFECTIVE_DATE between PP.EFFECTIVE_START_DATE
            AND PP.EFFECTIVE_END_DATE
            AND PAA.TAX_UNIT_ID = NVL(GRE
             ,PAA.TAX_UNIT_ID)
            AND PAA.ASSIGNMENT_ID = PAF.ASSIGNMENT_ID
            AND PPA.EFFECTIVE_DATE between PAF.EFFECTIVE_START_DATE
            AND PAF.EFFECTIVE_END_DATE
            AND PAF.PAY_BASIS_ID = ppb.pay_basis_id (+)
            AND PAF.LOCATION_ID = HL.LOCATION_ID
            AND PAF.PERSON_ID = PPF.PERSON_ID
            AND PPA.EFFECTIVE_DATE between PPF.EFFECTIVE_START_DATE
            AND PPF.EFFECTIVE_END_DATE
            AND HL.REGION_1 = NVL(CP_PROVINCE
             ,HL.REGION_1)
            AND PAF.LOCATION_ID = NVL(TO_NUMBER(CP_LOCATION)
             ,PAF.LOCATION_ID)
          GROUP BY
            PPF.PERSON_ID,
            PP.PAYROLL_NAME,
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'HOURLY'
                  ,'ANNUAL'
                  ,'SALARIED'
                  ,'MONTHLY'
                  ,'SALARIED'
                  ,'PERIOD'
                  ,'SALARIED'
                  ,'OTHER'),
            PAA.ASSIGNMENT_ID,
            PAA.TAX_UNIT_ID,
            PPA.BUSINESS_GROUP_ID ) BAL_TAB
      WHERE BAL_TAB.PAYROLL_NAME = PP_PAYROLL_NAME
        AND BAL_TAB.PAY_BASIS = PP_PAY_BASIS
        AND BAL_TAB.REGULAR_GROSS > 0;
    ELSE
      SELECT
        nvl(count(*),
            0)
      INTO
        L_COUNT
      FROM
        (   SELECT
            PPF.PERSON_ID,
            PP.PAYROLL_NAME,
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'HOURLY'
                  ,'ANNUAL'
                  ,'SALARIED'
                  ,'MONTHLY'
                  ,'SALARIED'
                  ,'PERIOD'
                  ,'SALARIED'
                  ,'OTHER') PAY_BASIS,
            PAY_CA_BALANCE_PKG.CALL_CA_BALANCE_GET_VALUE('Regular Earnings'
                                                        ,'PTD'
                                                        ,MAX(PAA.ASSIGNMENT_ACTION_ID)
                                                        ,PAA.ASSIGNMENT_ID
                                                        ,NULL
                                                        ,PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('REPORT_LEVEL')
                                                        ,PAA.TAX_UNIT_ID
                                                        ,PPA.BUSINESS_GROUP_ID
                                                        ,NVL(PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('JURISDICTION_CODE')
                                                           ,NULL)) REGULAR_GROSS
          FROM
            HR_LOCATIONS_ALL HL,
            PER_ALL_PEOPLE_F PPF,
            PER_PAY_BASES PPB,
            PER_ALL_ASSIGNMENTS_F PAF,
            PAY_PAYROLLS_F PP,
            PAY_ASSIGNMENT_ACTIONS PAA,
            PAY_PAYROLL_ACTIONS PPA,
            PER_TIME_PERIODS PTP
          WHERE PTP.TIME_PERIOD_ID in (
            SELECT
              MAX(PTP2.TIME_PERIOD_ID)
            FROM
              PER_TIME_PERIODS PTP2,
              PAY_ALL_PAYROLLS_F PPF2
            WHERE TO_CHAR(PTP2.END_DATE
                   ,'YYYY/MM') = TO_CHAR(FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                                     ,1
                                                     ,10))
                   ,'YYYY/MM')
              AND PPF2.PAYROLL_ID = PTP2.PAYROLL_ID
              AND PPF2.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
            GROUP BY
              PPF2.PAYROLL_ID,
              PTP2.PERIOD_TYPE )
            AND PPA.TIME_PERIOD_ID = PTP.TIME_PERIOD_ID
            AND PPA.EFFECTIVE_DATE between PTP.START_DATE
            AND PTP.END_DATE
            AND PPA.ACTION_TYPE in ( 'R' , 'Q' )
            AND PPA.ACTION_STATUS = 'C'
            AND PTP.PAYROLL_ID = PPA.PAYROLL_ID
            AND PPA.BUSINESS_GROUP_ID + 0 = NVL(P_BUSINESS_GROUP_ID
             ,PPA.BUSINESS_GROUP_ID)
            AND EXISTS (
            SELECT
              'X'
            FROM
              PAY_PAYROLL_ACTIONS PPA2,
              PAY_RUN_TYPES_F PRT
            WHERE PPA2.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
              AND NVL(PPA2.RUN_TYPE_ID
               ,-1) = PRT.RUN_TYPE_ID
              AND SUBSTR(PRT.SHORTNAME
                  ,1
                  ,1) in ( 'R' , 'T' ) )
            AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
            AND PAA.ACTION_STATUS = 'C'
            AND PPA.PAYROLL_ID = PP.PAYROLL_ID
            AND PPA.EFFECTIVE_DATE between PP.EFFECTIVE_START_DATE
            AND PP.EFFECTIVE_END_DATE
            AND PAA.TAX_UNIT_ID = NVL(GRE
             ,PAA.TAX_UNIT_ID)
            AND PAA.ASSIGNMENT_ID = PAF.ASSIGNMENT_ID
            AND PPA.EFFECTIVE_DATE between PAF.EFFECTIVE_START_DATE
            AND PAF.EFFECTIVE_END_DATE
            AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
            AND PAF.LOCATION_ID = HL.LOCATION_ID
            AND PAF.PERSON_ID = PPF.PERSON_ID
            AND PPA.EFFECTIVE_DATE between PPF.EFFECTIVE_START_DATE
            AND PPF.EFFECTIVE_END_DATE
            AND HL.REGION_1 = NVL(CP_PROVINCE
             ,HL.REGION_1)
            AND PAF.LOCATION_ID = NVL(TO_NUMBER(CP_LOCATION)
             ,PAF.LOCATION_ID)
          GROUP BY
            PPF.PERSON_ID,
            PP.PAYROLL_NAME,
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'HOURLY'
                  ,'ANNUAL'
                  ,'SALARIED'
                  ,'MONTHLY'
                  ,'SALARIED'
                  ,'PERIOD'
                  ,'SALARIED'
                  ,'OTHER'),
            PAA.ASSIGNMENT_ID,
            PAA.TAX_UNIT_ID,
            PPA.BUSINESS_GROUP_ID ) BAL_TAB
      WHERE BAL_TAB.PAYROLL_NAME = PP_PAYROLL_NAME
        AND BAL_TAB.PAY_BASIS = PP_PAY_BASIS
        AND BAL_TAB.REGULAR_GROSS > 0;
    END IF;
    RETURN L_COUNT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (0);
  END CF_EMP_COUNTFORMULA;

  FUNCTION CF_PARTTIME_EMP_COUNTFORMULA(PP_PAY_BASIS IN VARCHAR2
                                       ,GRE IN NUMBER
                                       ,PP_PAYROLL_NAME IN VARCHAR2) RETURN NUMBER IS
    L_PARTTIME_COUNT NUMBER;
  BEGIN
    IF PP_PAY_BASIS = 'OTHER' THEN
      SELECT
        nvl(count(*),
            0)
      INTO
        L_PARTTIME_COUNT
      FROM
        (   SELECT
            PPF.PERSON_ID,
            PP.PAYROLL_NAME,
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'HOURLY'
                  ,'ANNUAL'
                  ,'SALARIED'
                  ,'MONTHLY'
                  ,'SALARIED'
                  ,'PERIOD'
                  ,'SALARIED'
                  ,'OTHER') PAY_BASIS,
            PTP.PERIOD_TYPE,
            PAY_CA_BALANCE_PKG.CALL_CA_BALANCE_GET_VALUE(DECODE(PPB.PAY_BASIS
                                                               ,'HOURLY'
                                                               ,'Regular and Overtime Hours'
                                                               ,'ANNUAL'
                                                               ,'Regular Salary Hours'
                                                               ,'MONTHLY'
                                                               ,'Regular Salary Hours'
                                                               ,'PERIOD'
                                                               ,'Regular Salary Hours')
                                                        ,'PTD'
                                                        ,MAX(PAA.ASSIGNMENT_ACTION_ID)
                                                        ,PAA.ASSIGNMENT_ID
                                                        ,NULL
                                                        ,PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('REPORT_LEVEL')
                                                        ,PAA.TAX_UNIT_ID
                                                        ,PPA.BUSINESS_GROUP_ID
                                                        ,NVL(PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('JURISDICTION_CODE')
                                                           ,NULL)) REGULAR_HOURS,
            PAY_CA_BALANCE_PKG.CALL_CA_BALANCE_GET_VALUE('Regular Earnings'
                                                        ,'PTD'
                                                        ,MAX(PAA.ASSIGNMENT_ACTION_ID)
                                                        ,PAA.ASSIGNMENT_ID
                                                        ,NULL
                                                        ,PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('REPORT_LEVEL')
                                                        ,PAA.TAX_UNIT_ID
                                                        ,PPA.BUSINESS_GROUP_ID
                                                        ,NVL(PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('JURISDICTION_CODE')
                                                           ,NULL)) REGULAR_GROSS,
            ROUND(((PTP.END_DATE - PTP.START_DATE + 1) / 7)
                 ,2) WEEKS
          FROM
            HR_LOCATIONS_ALL HL,
            PER_ALL_PEOPLE_F PPF,
            PER_PAY_BASES PPB,
            PER_ALL_ASSIGNMENTS_F PAF,
            PAY_PAYROLLS_F PP,
            PAY_ASSIGNMENT_ACTIONS PAA,
            PAY_PAYROLL_ACTIONS PPA,
            PER_TIME_PERIODS PTP
          WHERE PTP.TIME_PERIOD_ID in (
            SELECT
              MAX(PTP2.TIME_PERIOD_ID)
            FROM
              PER_TIME_PERIODS PTP2,
              PAY_ALL_PAYROLLS_F PPF2
            WHERE TO_CHAR(PTP2.END_DATE
                   ,'YYYY/MM') = TO_CHAR(FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                                     ,1
                                                     ,10))
                   ,'YYYY/MM')
              AND PPF2.PAYROLL_ID = PTP2.PAYROLL_ID
              AND PPF2.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
            GROUP BY
              PPF2.PAYROLL_ID,
              PTP2.PERIOD_TYPE )
            AND PPA.EFFECTIVE_DATE between PTP.START_DATE
            AND PTP.END_DATE
            AND PPA.ACTION_TYPE in ( 'R' , 'Q' )
            AND PPA.ACTION_STATUS = 'C'
            AND PTP.PAYROLL_ID = PPA.PAYROLL_ID
            AND PPA.BUSINESS_GROUP_ID + 0 = NVL(P_BUSINESS_GROUP_ID
             ,PPA.BUSINESS_GROUP_ID)
            AND EXISTS (
            SELECT
              'X'
            FROM
              PAY_PAYROLL_ACTIONS PPA2,
              PAY_RUN_TYPES_F PRT
            WHERE PPA2.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
              AND NVL(PPA2.RUN_TYPE_ID
               ,-1) = PRT.RUN_TYPE_ID
              AND SUBSTR(PRT.SHORTNAME
                  ,1
                  ,1) in ( 'R' , 'T' ) )
            AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
            AND PAA.ACTION_STATUS = 'C'
            AND PPA.PAYROLL_ID = PP.PAYROLL_ID
            AND PPA.EFFECTIVE_DATE between PP.EFFECTIVE_START_DATE
            AND PP.EFFECTIVE_END_DATE
            AND PAA.TAX_UNIT_ID = NVL(GRE
             ,PAA.TAX_UNIT_ID)
            AND PAA.ASSIGNMENT_ID = PAF.ASSIGNMENT_ID
            AND PPA.EFFECTIVE_DATE between PAF.EFFECTIVE_START_DATE
            AND PAF.EFFECTIVE_END_DATE
            AND PAF.PAY_BASIS_ID = ppb.pay_basis_id (+)
            AND PAF.LOCATION_ID = HL.LOCATION_ID
            AND PAF.PERSON_ID = PPF.PERSON_ID
            AND PPA.EFFECTIVE_DATE between PPF.EFFECTIVE_START_DATE
            AND PPF.EFFECTIVE_END_DATE
            AND PAF.LOCATION_ID = NVL(TO_NUMBER(CP_LOCATION)
             ,PAF.LOCATION_ID)
            AND HL.REGION_1 = NVL(CP_PROVINCE
             ,HL.REGION_1)
          GROUP BY
            PPF.PERSON_ID,
            PP.PAYROLL_NAME,
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'HOURLY'
                  ,'ANNUAL'
                  ,'SALARIED'
                  ,'MONTHLY'
                  ,'SALARIED'
                  ,'PERIOD'
                  ,'SALARIED'
                  ,'OTHER'),
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'Regular and Overtime Hours'
                  ,'ANNUAL'
                  ,'Regular Salary Hours'
                  ,'MONTHLY'
                  ,'Regular Salary Hours'
                  ,'PERIOD'
                  ,'Regular Salary Hours'),
            PAA.ASSIGNMENT_ID,
            PTP.PERIOD_TYPE,
            PTP.END_DATE,
            PTP.START_DATE,
            PAA.TAX_UNIT_ID,
            PPA.BUSINESS_GROUP_ID ) BAL_TAB
      WHERE BAL_TAB.PAYROLL_NAME = PP_PAYROLL_NAME
        AND BAL_TAB.PAY_BASIS = PP_PAY_BASIS
        AND BAL_TAB.REGULAR_GROSS > 0
        AND ( BAL_TAB.REGULAR_HOURS / BAL_TAB.WEEKS ) < 30;
    ELSE
      SELECT
        nvl(count(*),
            0)
      INTO
        L_PARTTIME_COUNT
      FROM
        (   SELECT
            PPF.PERSON_ID,
            PP.PAYROLL_NAME,
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'HOURLY'
                  ,'ANNUAL'
                  ,'SALARIED'
                  ,'MONTHLY'
                  ,'SALARIED'
                  ,'PERIOD'
                  ,'SALARIED'
                  ,'OTHER') PAY_BASIS,
            PTP.PERIOD_TYPE,
            PAY_CA_BALANCE_PKG.CALL_CA_BALANCE_GET_VALUE(DECODE(PPB.PAY_BASIS
                                                               ,'HOURLY'
                                                               ,'Regular and Overtime Hours'
                                                               ,'ANNUAL'
                                                               ,'Regular Salary Hours'
                                                               ,'MONTHLY'
                                                               ,'Regular Salary Hours'
                                                               ,'PERIOD'
                                                               ,'Regular Salary Hours')
                                                        ,'PTD'
                                                        ,MAX(PAA.ASSIGNMENT_ACTION_ID)
                                                        ,PAA.ASSIGNMENT_ID
                                                        ,NULL
                                                        ,PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('REPORT_LEVEL')
                                                        ,PAA.TAX_UNIT_ID
                                                        ,PPA.BUSINESS_GROUP_ID
                                                        ,NVL(PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('JURISDICTION_CODE')
                                                           ,NULL)) REGULAR_HOURS,
            PAY_CA_BALANCE_PKG.CALL_CA_BALANCE_GET_VALUE('Regular Earnings'
                                                        ,'PTD'
                                                        ,MAX(PAA.ASSIGNMENT_ACTION_ID)
                                                        ,PAA.ASSIGNMENT_ID
                                                        ,NULL
                                                        ,PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('REPORT_LEVEL')
                                                        ,PAA.TAX_UNIT_ID
                                                        ,PPA.BUSINESS_GROUP_ID
                                                        ,NVL(PAY_CA_BALANCE_VIEW_PKG.GET_SESSION_VAR('JURISDICTION_CODE')
                                                           ,NULL)) REGULAR_GROSS,
            ROUND(((PTP.END_DATE - PTP.START_DATE + 1) / 7)
                 ,2) WEEKS
          FROM
            HR_LOCATIONS_ALL HL,
            PER_ALL_PEOPLE_F PPF,
            PER_PAY_BASES PPB,
            PER_ALL_ASSIGNMENTS_F PAF,
            PAY_PAYROLLS_F PP,
            PAY_ASSIGNMENT_ACTIONS PAA,
            PAY_PAYROLL_ACTIONS PPA,
            PER_TIME_PERIODS PTP
          WHERE PTP.TIME_PERIOD_ID in (
            SELECT
              MAX(PTP2.TIME_PERIOD_ID)
            FROM
              PER_TIME_PERIODS PTP2,
              PAY_ALL_PAYROLLS_F PPF2
            WHERE TO_CHAR(PTP2.END_DATE
                   ,'YYYY/MM') = TO_CHAR(FND_DATE.CANONICAL_TO_DATE(SUBSTR(P_CANONICAL_REFERENCE_MONTH
                                                     ,1
                                                     ,10))
                   ,'YYYY/MM')
              AND PPF2.PAYROLL_ID = PTP2.PAYROLL_ID
              AND PPF2.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
            GROUP BY
              PPF2.PAYROLL_ID,
              PTP2.PERIOD_TYPE )
            AND PPA.EFFECTIVE_DATE between PTP.START_DATE
            AND PTP.END_DATE
            AND PPA.ACTION_TYPE in ( 'R' , 'Q' )
            AND PPA.ACTION_STATUS = 'C'
            AND PTP.PAYROLL_ID = PPA.PAYROLL_ID
            AND PPA.BUSINESS_GROUP_ID + 0 = NVL(P_BUSINESS_GROUP_ID
             ,PPA.BUSINESS_GROUP_ID)
            AND EXISTS (
            SELECT
              'X'
            FROM
              PAY_PAYROLL_ACTIONS PPA2,
              PAY_RUN_TYPES_F PRT
            WHERE PPA2.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
              AND NVL(PPA2.RUN_TYPE_ID
               ,-1) = PRT.RUN_TYPE_ID
              AND SUBSTR(PRT.SHORTNAME
                  ,1
                  ,1) in ( 'R' , 'T' ) )
            AND PPA.PAYROLL_ACTION_ID = PAA.PAYROLL_ACTION_ID
            AND PAA.ACTION_STATUS = 'C'
            AND PPA.PAYROLL_ID = PP.PAYROLL_ID
            AND PPA.EFFECTIVE_DATE between PP.EFFECTIVE_START_DATE
            AND PP.EFFECTIVE_END_DATE
            AND PAA.TAX_UNIT_ID = NVL(GRE
             ,PAA.TAX_UNIT_ID)
            AND PAA.ASSIGNMENT_ID = PAF.ASSIGNMENT_ID
            AND PPA.EFFECTIVE_DATE between PAF.EFFECTIVE_START_DATE
            AND PAF.EFFECTIVE_END_DATE
            AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
            AND PAF.LOCATION_ID = HL.LOCATION_ID
            AND PAF.PERSON_ID = PPF.PERSON_ID
            AND PPA.EFFECTIVE_DATE between PPF.EFFECTIVE_START_DATE
            AND PPF.EFFECTIVE_END_DATE
            AND PAF.LOCATION_ID = NVL(TO_NUMBER(CP_LOCATION)
             ,PAF.LOCATION_ID)
            AND HL.REGION_1 = NVL(CP_PROVINCE
             ,HL.REGION_1)
          GROUP BY
            PPF.PERSON_ID,
            PP.PAYROLL_NAME,
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'HOURLY'
                  ,'ANNUAL'
                  ,'SALARIED'
                  ,'MONTHLY'
                  ,'SALARIED'
                  ,'PERIOD'
                  ,'SALARIED'
                  ,'OTHER'),
            DECODE(PPB.PAY_BASIS
                  ,'HOURLY'
                  ,'Regular and Overtime Hours'
                  ,'ANNUAL'
                  ,'Regular Salary Hours'
                  ,'MONTHLY'
                  ,'Regular Salary Hours'
                  ,'PERIOD'
                  ,'Regular Salary Hours'),
            PAA.ASSIGNMENT_ID,
            PTP.PERIOD_TYPE,
            PTP.END_DATE,
            PTP.START_DATE,
            PAA.TAX_UNIT_ID,
            PPA.BUSINESS_GROUP_ID ) BAL_TAB
      WHERE BAL_TAB.PAYROLL_NAME = PP_PAYROLL_NAME
        AND BAL_TAB.PAY_BASIS = PP_PAY_BASIS
        AND BAL_TAB.REGULAR_GROSS > 0
        AND ( BAL_TAB.REGULAR_HOURS / BAL_TAB.WEEKS ) < 30;
    END IF;
    RETURN L_PARTTIME_COUNT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN (0);
  END CF_PARTTIME_EMP_COUNTFORMULA;

  FUNCTION CF_TOTAL_HOURSFORMULA(OVERTIME_HOURS IN NUMBER
                                ,REGULAR_HRS_WORKED IN NUMBER) RETURN NUMBER IS
    L_TOTAL_HOURS NUMBER;
  BEGIN
    L_TOTAL_HOURS := OVERTIME_HOURS + REGULAR_HRS_WORKED;
    RETURN L_TOTAL_HOURS;
  END CF_TOTAL_HOURSFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_PROVINCE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PROVINCE;
  END CP_PROVINCE_P;

  FUNCTION CP_LOCATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LOCATION;
  END CP_LOCATION_P;

  FUNCTION CP_LOCATION_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LOCATION_CODE;
  END CP_LOCATION_CODE_P;

  FUNCTION CP_GRE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_GRE_NAME;
  END CP_GRE_NAME_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_SUBTITLE;
  END C_REPORT_SUBTITLE_P;

  FUNCTION C_START_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_START_DATE;
  END C_START_DATE_P;

  FUNCTION C_END_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_END_DATE;
  END C_END_DATE_P;

  FUNCTION C_PROVINCE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PROVINCE_NAME;
  END C_PROVINCE_NAME_P;

  FUNCTION C_LOCATION_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_LOCATION_CODE;
  END C_LOCATION_CODE_P;

  FUNCTION C_GRE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_GRE_NAME;
  END C_GRE_NAME_P;

  FUNCTION CP_SEED_BAL_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SEED_BAL_FLAG;
  END CP_SEED_BAL_FLAG_P;

  FUNCTION CP_SUPP_EARN_FLAG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SUPP_EARN_FLAG;
  END CP_SUPP_EARN_FLAG_P;

  FUNCTION CP_SUPP_EARN_VIEW_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SUPP_EARN_VIEW;
  END CP_SUPP_EARN_VIEW_P;

 /* FUNCTION GET_BUDGET(P_BUDGET_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN

    X0 := HR_REPORTS.GET_BUDGET(P_BUDGET_ID);

   STPROC.INIT('begin :X0 := HR_REPORTS.GET_BUDGET(:P_BUDGET_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUDGET_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_BUDGET; */

 /* FUNCTION GET_BUDGET_VERSION(P_BUDGET_ID IN NUMBER
                             ,P_BUDGET_VERSION_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN

  X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);

   STPROC.INIT('begin :X0 := HR_REPORTS.GET_BUDGET_VERSION(:P_BUDGET_ID, :P_BUDGET_VERSION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUDGET_ID);
    STPROC.BIND_I(P_BUDGET_VERSION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_BUDGET_VERSION; */

  /*PROCEDURE GET_ORGANIZATION(P_ORGANIZATION_ID IN NUMBER
                            ,P_ORG_NAME OUT NOCOPY CHAR
                            ,P_ORG_TYPE OUT NOCOPY CHAR) IS
  BEGIN


    STPROC.INIT('begin HR_REPORTS.GET_ORGANIZATION(:P_ORGANIZATION_ID, :P_ORG_NAME, :P_ORG_TYPE); end;');
    STPROC.BIND_I(P_ORGANIZATION_ID);
    STPROC.BIND_O(P_ORG_NAME);
    STPROC.BIND_O(P_ORG_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_ORG_NAME);
    STPROC.RETRIEVE(3
                   ,P_ORG_TYPE);
  END GET_ORGANIZATION;  */

/*  FUNCTION GET_JOB(P_JOB_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN
    X0 := HR_REPORTS.GET_JOB(P_JOB_ID);

    STPROC.INIT('begin :X0 := HR_REPORTS.GET_JOB(:P_JOB_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_JOB_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_JOB; */

/*  FUNCTION GET_POSITION(P_POSITION_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN

    X0 := HR_REPORTS.GET_POSITION(P_POSITION_ID);

    STPROC.INIT('begin :X0 := HR_REPORTS.GET_POSITION(:P_POSITION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_POSITION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_POSITION; */

/*  FUNCTION GET_GRADE(P_GRADE_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN
    X0 := HR_REPORTS.GET_GRADE(P_GRADE_ID);

      STPROC.INIT('begin :X0 := HR_REPORTS.GET_GRADE(:P_GRADE_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_GRADE_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_GRADE; */

/*  FUNCTION GET_STATUS(P_BUSINESS_GROUP_ID IN NUMBER
                     ,P_ASSIGNMENT_STATUS_TYPE_ID IN NUMBER
                     ,P_LEGISLATION_CODE IN CHAR) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN

    X0 := HR_REPORTS.GET_STATUS(P_BUSINESS_GROUP_ID, P_ASSIGNMENT_STATUS_TYPE_ID, P_LEGISLATION_CODE);

/   STPROC.INIT('begin :X0 := HR_REPORTS.GET_STATUS(:P_BUSINESS_GROUP_ID, :P_ASSIGNMENT_STATUS_TYPE_ID, :P_LEGISLATION_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.BIND_I(P_ASSIGNMENT_STATUS_TYPE_ID);
    STPROC.BIND_I(P_LEGISLATION_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_STATUS; */

/*  FUNCTION GET_ABS_TYPE(P_ABS_ATT_TYPE_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN

    X0 := HR_REPORTS.GET_ABS_TYPE(P_ABS_ATT_TYPE_ID);
    STPROC.INIT('begin :X0 := HR_REPORTS.GET_ABS_TYPE(:P_ABS_ATT_TYPE_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_ABS_ATT_TYPE_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_ABS_TYPE; */

 /* PROCEDURE GET_TIME_PERIOD(P_TIME_PERIOD_ID IN NUMBER
                           ,P_PERIOD_NAME OUT NOCOPY CHAR
                           ,P_START_DATE OUT NOCOPY DATE
                           ,P_END_DATE OUT NOCOPY DATE) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GET_TIME_PERIOD(:P_TIME_PERIOD_ID, :P_PERIOD_NAME, :P_START_DATE, :P_END_DATE); end;');
    STPROC.BIND_I(P_TIME_PERIOD_ID);
    STPROC.BIND_O(P_PERIOD_NAME);
    STPROC.BIND_O(P_START_DATE);
    STPROC.BIND_O(P_END_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,P_PERIOD_NAME);
    STPROC.RETRIEVE(3
                   ,P_START_DATE);
    STPROC.RETRIEVE(4
                   ,P_END_DATE);
  END GET_TIME_PERIOD; */

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN
  X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
  /*
    STPROC.INIT('begin :X0 := HR_REPORTS.GET_BUSINESS_GROUP(:P_BUSINESS_GROUP_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BUSINESS_GROUP_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0); */
    RETURN X0;
  END GET_BUSINESS_GROUP;

  /*FUNCTION COUNT_ORG_SUBORDINATES(P_ORG_STRUCTURE_VERSION_ID IN NUMBER
                                 ,P_PARENT_ORGANIZATION_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    X0 := HR_REPORTS.COUNT_ORG_SUBORDINATES(P_ORG_STRUCTURE_VERSION_ID, P_PARENT_ORGANIZATION_ID);
    STPROC.INIT('begin :X0 := HR_REPORTS.COUNT_ORG_SUBORDINATES(:P_ORG_STRUCTURE_VERSION_ID, :P_PARENT_ORGANIZATION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_ORG_STRUCTURE_VERSION_ID);
    STPROC.BIND_I(P_PARENT_ORGANIZATION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END COUNT_ORG_SUBORDINATES; */

 /* FUNCTION COUNT_POS_SUBORDINATES(P_POS_STRUCTURE_VERSION_ID IN NUMBER
                                 ,P_PARENT_POSITION_ID IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    X0 := HR_REPORTS.COUNT_POS_SUBORDINATES(P_POS_STRUCTURE_VERSION_ID, P_PARENT_POSITION_ID);
    STPROC.INIT('begin :X0 := HR_REPORTS.COUNT_POS_SUBORDINATES(:P_POS_STRUCTURE_VERSION_ID, :P_PARENT_POSITION_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_POS_STRUCTURE_VERSION_ID);
    STPROC.BIND_I(P_PARENT_POSITION_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END COUNT_POS_SUBORDINATES; */

 /* PROCEDURE GET_ORGANIZATION_HIERARCHY(P_ORGANIZATION_STRUCTURE_ID IN NUMBER
                                      ,P_ORG_STRUCTURE_VERSION_ID IN NUMBER
                                      ,P_ORG_STRUCTURE_NAME OUT NOCOPY CHAR
                                      ,P_ORG_VERSION OUT NOCOPY NUMBER
                                      ,P_VERSION_START_DATE OUT NOCOPY DATE
                                      ,P_VERSION_END_DATE OUT NOCOPY DATE) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GET_ORGANIZATION_HIERARCHY(:P_ORGANIZATION_STRUCTURE_ID, :P_ORG_STRUCTURE_VERSION_ID, :P_ORG_STRUCTURE_NAME, :P_ORG_VERSION, :P_VERSION_START_DATE, :P_VERSION_END_DATE); end;');
    STPROC.BIND_I(P_ORGANIZATION_STRUCTURE_ID);
    STPROC.BIND_I(P_ORG_STRUCTURE_VERSION_ID);
    STPROC.BIND_O(P_ORG_STRUCTURE_NAME);
    STPROC.BIND_O(P_ORG_VERSION);
    STPROC.BIND_O(P_VERSION_START_DATE);
    STPROC.BIND_O(P_VERSION_END_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_ORG_STRUCTURE_NAME);
    STPROC.RETRIEVE(4
                   ,P_ORG_VERSION);
    STPROC.RETRIEVE(5
                   ,P_VERSION_START_DATE);
    STPROC.RETRIEVE(6
                   ,P_VERSION_END_DATE);
  END GET_ORGANIZATION_HIERARCHY; */

  /*PROCEDURE GET_POSITION_HIERARCHY(P_POSITION_STRUCTURE_ID IN NUMBER
                                  ,P_POS_STRUCTURE_VERSION_ID IN NUMBER
                                  ,P_POS_STRUCTURE_NAME OUT NOCOPY CHAR
                                  ,P_POS_VERSION OUT NOCOPY NUMBER
                                  ,P_VERSION_START_DATE OUT NOCOPY DATE
                                  ,P_VERSION_END_DATE OUT NOCOPY DATE) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GET_POSITION_HIERARCHY(:P_POSITION_STRUCTURE_ID, :P_POS_STRUCTURE_VERSION_ID, :P_POS_STRUCTURE_NAME, :P_POS_VERSION, :P_VERSION_START_DATE, :P_VERSION_END_DATE); end;');
    STPROC.BIND_I(P_POSITION_STRUCTURE_ID);
    STPROC.BIND_I(P_POS_STRUCTURE_VERSION_ID);
    STPROC.BIND_O(P_POS_STRUCTURE_NAME);
    STPROC.BIND_O(P_POS_VERSION);
    STPROC.BIND_O(P_VERSION_START_DATE);
    STPROC.BIND_O(P_VERSION_END_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_POS_STRUCTURE_NAME);
    STPROC.RETRIEVE(4
                   ,P_POS_VERSION);
    STPROC.RETRIEVE(5
                   ,P_VERSION_START_DATE);
    STPROC.RETRIEVE(6
                   ,P_VERSION_END_DATE);
  END GET_POSITION_HIERARCHY; */

/*  FUNCTION GET_LOOKUP_MEANING(P_LOOKUP_TYPE IN CHAR
                             ,P_LOOKUP_CODE IN CHAR) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN
    X0 := HR_REPORTS.GET_LOOKUP_MEANING(P_LOOKUP_TYPE, P_LOOKUP_CODE);

    STPROC.INIT('begin :X0 := HR_REPORTS.GET_LOOKUP_MEANING(:P_LOOKUP_TYPE, :P_LOOKUP_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_LOOKUP_TYPE);
    STPROC.BIND_I(P_LOOKUP_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_LOOKUP_MEANING; */


 /* FUNCTION PERSON_MATCHING_SKILLS(P_PERSON_ID IN NUMBER
                                 ,P_JOB_POSITION_ID IN NUMBER
                                 ,P_JOB_POSITION_TYPE IN CHAR
                                 ,P_MATCHING_LEVEL IN CHAR
                                 ,P_NO_OF_ESSENTIAL IN NUMBER
                                 ,P_NO_OF_DESIRABLE IN NUMBER) RETURN BOOLEAN IS
    X0rv BOOLEAN;
    X0 BOOLEAN;

  BEGIN

   X0rv := HR_REPORTS.PERSON_MATCHING_SKILLS(P_PERSON_ID, P_JOB_POSITION_ID, P_JOB_POSITION_TYPE, P_MATCHING_LEVEL, P_NO_OF_ESSENTIAL, P_NO_OF_DESIRABLE);
   X0 := sys.diutil.bool_to_int(X0rv);

    STPROC.INIT('declare X0rv BOOLEAN; begin X0rv := HR_REPORTS.PERSON_MATCHING_SKILLS(:P_PERSON_ID, :P_JOB_POSITION_ID, :P_JOB_POSITION_TYPE, :P_MATCHING_LEVEL, :P_NO_OF_ESSENTIAL, :P_NO_OF_DESIRABLE); :X0 := sys.diutil.bool_to_int(X0rv); end;');
    STPROC.BIND_I(P_PERSON_ID);
    STPROC.BIND_I(P_JOB_POSITION_ID);
    STPROC.BIND_I(P_JOB_POSITION_TYPE);
    STPROC.BIND_I(P_MATCHING_LEVEL);
    STPROC.BIND_I(P_NO_OF_ESSENTIAL);
    STPROC.BIND_I(P_NO_OF_DESIRABLE);
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(7
                   ,X0);
    RETURN X0;
  END PERSON_MATCHING_SKILLS; */

/*  FUNCTION GET_PAYROLL_NAME(P_SESSION_DATE IN DATE
                           ,P_PAYROLL_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN
    STPROC.INIT('begin :X0 := HR_REPORTS.GET_PAYROLL_NAME(:P_SESSION_DATE, :P_PAYROLL_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_SESSION_DATE);
    STPROC.BIND_I(P_PAYROLL_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_PAYROLL_NAME; */

/*  FUNCTION GET_ELEMENT_NAME(P_SESSION_DATE IN DATE
                           ,P_ELEMENT_TYPE_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN
    STPROC.INIT('begin :X0 := HR_REPORTS.GET_ELEMENT_NAME(:P_SESSION_DATE, :P_ELEMENT_TYPE_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_SESSION_DATE);
    STPROC.BIND_I(P_ELEMENT_TYPE_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_ELEMENT_NAME;

  PROCEDURE GEN_PARTIAL_MATCHING_LEXICAL(P_CONCATENATED_SEGMENTS IN CHAR
                                        ,P_ID_FLEX_NUM IN NUMBER
                                        ,P_MATCHING_LEXICAL IN OUT NOCOPY CHAR) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GEN_PARTIAL_MATCHING_LEXICAL(:P_CONCATENATED_SEGMENTS, :P_ID_FLEX_NUM, :P_MATCHING_LEXICAL); end;');
    STPROC.BIND_I(P_CONCATENATED_SEGMENTS);
    STPROC.BIND_I(P_ID_FLEX_NUM);
    STPROC.BIND_IO(P_MATCHING_LEXICAL);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_MATCHING_LEXICAL);
  END GEN_PARTIAL_MATCHING_LEXICAL;

  PROCEDURE GET_ATTRIBUTES(P_CONCATENATED_SEGMENTS IN CHAR
                          ,P_NAME IN CHAR
                          ,P_SEGMENTS_USED OUT NOCOPY NUMBER
                          ,P_VALUE1 OUT NOCOPY CHAR
                          ,P_VALUE2 OUT NOCOPY CHAR
                          ,P_VALUE3 OUT NOCOPY CHAR
                          ,P_VALUE4 OUT NOCOPY CHAR
                          ,P_VALUE5 OUT NOCOPY CHAR
                          ,P_VALUE6 OUT NOCOPY CHAR
                          ,P_VALUE7 OUT NOCOPY CHAR
                          ,P_VALUE8 OUT NOCOPY CHAR
                          ,P_VALUE9 OUT NOCOPY CHAR
                          ,P_VALUE10 OUT NOCOPY CHAR
                          ,P_VALUE11 OUT NOCOPY CHAR
                          ,P_VALUE12 OUT NOCOPY CHAR
                          ,P_VALUE13 OUT NOCOPY CHAR
                          ,P_VALUE14 OUT NOCOPY CHAR
                          ,P_VALUE15 OUT NOCOPY CHAR
                          ,P_VALUE16 OUT NOCOPY CHAR
                          ,P_VALUE17 OUT NOCOPY CHAR
                          ,P_VALUE18 OUT NOCOPY CHAR
                          ,P_VALUE19 OUT NOCOPY CHAR
                          ,P_VALUE20 OUT NOCOPY CHAR
                          ,P_VALUE21 OUT NOCOPY CHAR
                          ,P_VALUE22 OUT NOCOPY CHAR
                          ,P_VALUE23 OUT NOCOPY CHAR
                          ,P_VALUE24 OUT NOCOPY CHAR
                          ,P_VALUE25 OUT NOCOPY CHAR
                          ,P_VALUE26 OUT NOCOPY CHAR
                          ,P_VALUE27 OUT NOCOPY CHAR
                          ,P_VALUE28 OUT NOCOPY CHAR
                          ,P_VALUE29 OUT NOCOPY CHAR
                          ,P_VALUE30 OUT NOCOPY CHAR) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GET_ATTRIBUTES(:P_CONCATENATED_SEGMENTS, :P_NAME, :P_SEGMENTS_USED,
    :P_VALUE1, :P_VALUE2, :P_VALUE3, :P_VALUE4, :P_VALUE5, :P_VALUE6, :P_VALUE7, :P_VALUE8, :P_VALUE9,
    :P_VALUE10, :P_VALUE11, :P_VALUE12, :P_VALUE13, :P_VALUE14, :P_VALUE15, :P_VALUE16, :P_VALUE17,
    :P_VALUE18, :P_VALUE19, :P_VALUE20, :P_VALUE21, :P_VALUE22, :P_VALUE23, :P_VALUE24, :P_VALUE25,
    :P_VALUE26, :P_VALUE27, :P_VALUE28, :P_VALUE29, :P_VALUE30); end;');
    STPROC.BIND_I(P_CONCATENATED_SEGMENTS);
    STPROC.BIND_I(P_NAME);
    STPROC.BIND_O(P_SEGMENTS_USED);
    STPROC.BIND_O(P_VALUE1);
    STPROC.BIND_O(P_VALUE2);
    STPROC.BIND_O(P_VALUE3);
    STPROC.BIND_O(P_VALUE4);
    STPROC.BIND_O(P_VALUE5);
    STPROC.BIND_O(P_VALUE6);
    STPROC.BIND_O(P_VALUE7);
    STPROC.BIND_O(P_VALUE8);
    STPROC.BIND_O(P_VALUE9);
    STPROC.BIND_O(P_VALUE10);
    STPROC.BIND_O(P_VALUE11);
    STPROC.BIND_O(P_VALUE12);
    STPROC.BIND_O(P_VALUE13);
    STPROC.BIND_O(P_VALUE14);
    STPROC.BIND_O(P_VALUE15);
    STPROC.BIND_O(P_VALUE16);
    STPROC.BIND_O(P_VALUE17);
    STPROC.BIND_O(P_VALUE18);
    STPROC.BIND_O(P_VALUE19);
    STPROC.BIND_O(P_VALUE20);
    STPROC.BIND_O(P_VALUE21);
    STPROC.BIND_O(P_VALUE22);
    STPROC.BIND_O(P_VALUE23);
    STPROC.BIND_O(P_VALUE24);
    STPROC.BIND_O(P_VALUE25);
    STPROC.BIND_O(P_VALUE26);
    STPROC.BIND_O(P_VALUE27);
    STPROC.BIND_O(P_VALUE28);
    STPROC.BIND_O(P_VALUE29);
    STPROC.BIND_O(P_VALUE30);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_SEGMENTS_USED);
    STPROC.RETRIEVE(4
                   ,P_VALUE1);
    STPROC.RETRIEVE(5
                   ,P_VALUE2);
    STPROC.RETRIEVE(6
                   ,P_VALUE3);
    STPROC.RETRIEVE(7
                   ,P_VALUE4);
    STPROC.RETRIEVE(8
                   ,P_VALUE5);
    STPROC.RETRIEVE(9
                   ,P_VALUE6);
    STPROC.RETRIEVE(10
                   ,P_VALUE7);
    STPROC.RETRIEVE(11
                   ,P_VALUE8);
    STPROC.RETRIEVE(12
                   ,P_VALUE9);
    STPROC.RETRIEVE(13
                   ,P_VALUE10);
    STPROC.RETRIEVE(14
                   ,P_VALUE11);
    STPROC.RETRIEVE(15
                   ,P_VALUE12);
    STPROC.RETRIEVE(16
                   ,P_VALUE13);
    STPROC.RETRIEVE(17
                   ,P_VALUE14);
    STPROC.RETRIEVE(18
                   ,P_VALUE15);
    STPROC.RETRIEVE(19
                   ,P_VALUE16);
    STPROC.RETRIEVE(20
                   ,P_VALUE17);
    STPROC.RETRIEVE(21
                   ,P_VALUE18);
    STPROC.RETRIEVE(22
                   ,P_VALUE19);
    STPROC.RETRIEVE(23
                   ,P_VALUE20);
    STPROC.RETRIEVE(24
                   ,P_VALUE21);
    STPROC.RETRIEVE(25
                   ,P_VALUE22);
    STPROC.RETRIEVE(26
                   ,P_VALUE23);
    STPROC.RETRIEVE(27
                   ,P_VALUE24);
    STPROC.RETRIEVE(28
                   ,P_VALUE25);
    STPROC.RETRIEVE(29
                   ,P_VALUE26);
    STPROC.RETRIEVE(30
                   ,P_VALUE27);
    STPROC.RETRIEVE(31
                   ,P_VALUE28);
    STPROC.RETRIEVE(32
                   ,P_VALUE29);
    STPROC.RETRIEVE(33
                   ,P_VALUE30);
  END GET_ATTRIBUTES;

  PROCEDURE GET_SEGMENTS(P_CONCATENATED_SEGMENTS IN CHAR
                        ,P_ID_FLEX_NUM IN NUMBER
                        ,P_SEGMENTS_USED OUT NOCOPY NUMBER
                        ,P_VALUE1 OUT NOCOPY CHAR
                        ,P_VALUE2 OUT NOCOPY CHAR
                        ,P_VALUE3 OUT NOCOPY CHAR
                        ,P_VALUE4 OUT NOCOPY CHAR
                        ,P_VALUE5 OUT NOCOPY CHAR
                        ,P_VALUE6 OUT NOCOPY CHAR
                        ,P_VALUE7 OUT NOCOPY CHAR
                        ,P_VALUE8 OUT NOCOPY CHAR
                        ,P_VALUE9 OUT NOCOPY CHAR
                        ,P_VALUE10 OUT NOCOPY CHAR
                        ,P_VALUE11 OUT NOCOPY CHAR
                        ,P_VALUE12 OUT NOCOPY CHAR
                        ,P_VALUE13 OUT NOCOPY CHAR
                        ,P_VALUE14 OUT NOCOPY CHAR
                        ,P_VALUE15 OUT NOCOPY CHAR
                        ,P_VALUE16 OUT NOCOPY CHAR
                        ,P_VALUE17 OUT NOCOPY CHAR
                        ,P_VALUE18 OUT NOCOPY CHAR
                        ,P_VALUE19 OUT NOCOPY CHAR
                        ,P_VALUE20 OUT NOCOPY CHAR
                        ,P_VALUE21 OUT NOCOPY CHAR
                        ,P_VALUE22 OUT NOCOPY CHAR
                        ,P_VALUE23 OUT NOCOPY CHAR
                        ,P_VALUE24 OUT NOCOPY CHAR
                        ,P_VALUE25 OUT NOCOPY CHAR
                        ,P_VALUE26 OUT NOCOPY CHAR
                        ,P_VALUE27 OUT NOCOPY CHAR
                        ,P_VALUE28 OUT NOCOPY CHAR
                        ,P_VALUE29 OUT NOCOPY CHAR
                        ,P_VALUE30 OUT NOCOPY CHAR) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GET_SEGMENTS(:P_CONCATENATED_SEGMENTS, :P_ID_FLEX_NUM, :P_SEGMENTS_USED,
    :P_VALUE1, :P_VALUE2, :P_VALUE3, :P_VALUE4, :P_VALUE5, :P_VALUE6, :P_VALUE7, :P_VALUE8, :P_VALUE9,
    :P_VALUE10, :P_VALUE11, :P_VALUE12, :P_VALUE13, :P_VALUE14, :P_VALUE15, :P_VALUE16, :P_VALUE17,
    :P_VALUE18, :P_VALUE19, :P_VALUE20, :P_VALUE21, :P_VALUE22, :P_VALUE23, :P_VALUE24, :P_VALUE25,
    :P_VALUE26, :P_VALUE27, :P_VALUE28, :P_VALUE29, :P_VALUE30); end;');
    STPROC.BIND_I(P_CONCATENATED_SEGMENTS);
    STPROC.BIND_I(P_ID_FLEX_NUM);
    STPROC.BIND_O(P_SEGMENTS_USED);
    STPROC.BIND_O(P_VALUE1);
    STPROC.BIND_O(P_VALUE2);
    STPROC.BIND_O(P_VALUE3);
    STPROC.BIND_O(P_VALUE4);
    STPROC.BIND_O(P_VALUE5);
    STPROC.BIND_O(P_VALUE6);
    STPROC.BIND_O(P_VALUE7);
    STPROC.BIND_O(P_VALUE8);
    STPROC.BIND_O(P_VALUE9);
    STPROC.BIND_O(P_VALUE10);
    STPROC.BIND_O(P_VALUE11);
    STPROC.BIND_O(P_VALUE12);
    STPROC.BIND_O(P_VALUE13);
    STPROC.BIND_O(P_VALUE14);
    STPROC.BIND_O(P_VALUE15);
    STPROC.BIND_O(P_VALUE16);
    STPROC.BIND_O(P_VALUE17);
    STPROC.BIND_O(P_VALUE18);
    STPROC.BIND_O(P_VALUE19);
    STPROC.BIND_O(P_VALUE20);
    STPROC.BIND_O(P_VALUE21);
    STPROC.BIND_O(P_VALUE22);
    STPROC.BIND_O(P_VALUE23);
    STPROC.BIND_O(P_VALUE24);
    STPROC.BIND_O(P_VALUE25);
    STPROC.BIND_O(P_VALUE26);
    STPROC.BIND_O(P_VALUE27);
    STPROC.BIND_O(P_VALUE28);
    STPROC.BIND_O(P_VALUE29);
    STPROC.BIND_O(P_VALUE30);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,P_SEGMENTS_USED);
    STPROC.RETRIEVE(4
                   ,P_VALUE1);
    STPROC.RETRIEVE(5
                   ,P_VALUE2);
    STPROC.RETRIEVE(6
                   ,P_VALUE3);
    STPROC.RETRIEVE(7
                   ,P_VALUE4);
    STPROC.RETRIEVE(8
                   ,P_VALUE5);
    STPROC.RETRIEVE(9
                   ,P_VALUE6);
    STPROC.RETRIEVE(10
                   ,P_VALUE7);
    STPROC.RETRIEVE(11
                   ,P_VALUE8);
    STPROC.RETRIEVE(12
                   ,P_VALUE9);
    STPROC.RETRIEVE(13
                   ,P_VALUE10);
    STPROC.RETRIEVE(14
                   ,P_VALUE11);
    STPROC.RETRIEVE(15
                   ,P_VALUE12);
    STPROC.RETRIEVE(16
                   ,P_VALUE13);
    STPROC.RETRIEVE(17
                   ,P_VALUE14);
    STPROC.RETRIEVE(18
                   ,P_VALUE15);
    STPROC.RETRIEVE(19
                   ,P_VALUE16);
    STPROC.RETRIEVE(20
                   ,P_VALUE17);
    STPROC.RETRIEVE(21
                   ,P_VALUE18);
    STPROC.RETRIEVE(22
                   ,P_VALUE19);
    STPROC.RETRIEVE(23
                   ,P_VALUE20);
    STPROC.RETRIEVE(24
                   ,P_VALUE21);
    STPROC.RETRIEVE(25
                   ,P_VALUE22);
    STPROC.RETRIEVE(26
                   ,P_VALUE23);
    STPROC.RETRIEVE(27
                   ,P_VALUE24);
    STPROC.RETRIEVE(28
                   ,P_VALUE25);
    STPROC.RETRIEVE(29
                   ,P_VALUE26);
    STPROC.RETRIEVE(30
                   ,P_VALUE27);
    STPROC.RETRIEVE(31
                   ,P_VALUE28);
    STPROC.RETRIEVE(32
                   ,P_VALUE29);
    STPROC.RETRIEVE(33
                   ,P_VALUE30);
  END GET_SEGMENTS;

  PROCEDURE GET_DESC_FLEX(P_APPL_SHORT_NAME IN CHAR
                         ,P_DESC_FLEX_NAME IN CHAR
                         ,P_TABLE_ALIAS IN CHAR
                         ,P_TITLE OUT NOCOPY CHAR
                         ,P_LABEL_EXPR OUT NOCOPY CHAR
                         ,P_COLUMN_EXPR OUT NOCOPY CHAR) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GET_DESC_FLEX(:P_APPL_SHORT_NAME, :P_DESC_FLEX_NAME, :P_TABLE_ALIAS, :P_TITLE, :P_LABEL_EXPR, :P_COLUMN_EXPR); end;');
    STPROC.BIND_I(P_APPL_SHORT_NAME);
    STPROC.BIND_I(P_DESC_FLEX_NAME);
    STPROC.BIND_I(P_TABLE_ALIAS);
    STPROC.BIND_O(P_TITLE);
    STPROC.BIND_O(P_LABEL_EXPR);
    STPROC.BIND_O(P_COLUMN_EXPR);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,P_TITLE);
    STPROC.RETRIEVE(5
                   ,P_LABEL_EXPR);
    STPROC.RETRIEVE(6
                   ,P_COLUMN_EXPR);
  END GET_DESC_FLEX;

  PROCEDURE GET_DESC_FLEX_CONTEXT(P_APPL_SHORT_NAME IN CHAR
                                 ,P_DESC_FLEX_NAME IN CHAR
                                 ,P_TABLE_ALIAS IN CHAR
                                 ,P_TITLE OUT NOCOPY CHAR
                                 ,P_LABEL_EXPR OUT NOCOPY CHAR
                                 ,P_COLUMN_EXPR OUT NOCOPY CHAR) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GET_DESC_FLEX_CONTEXT(:P_APPL_SHORT_NAME, :P_DESC_FLEX_NAME, :P_TABLE_ALIAS, :P_TITLE, :P_LABEL_EXPR, :P_COLUMN_EXPR); end;');
    STPROC.BIND_I(P_APPL_SHORT_NAME);
    STPROC.BIND_I(P_DESC_FLEX_NAME);
    STPROC.BIND_I(P_TABLE_ALIAS);
    STPROC.BIND_O(P_TITLE);
    STPROC.BIND_O(P_LABEL_EXPR);
    STPROC.BIND_O(P_COLUMN_EXPR);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,P_TITLE);
    STPROC.RETRIEVE(5
                   ,P_LABEL_EXPR);
    STPROC.RETRIEVE(6
                   ,P_COLUMN_EXPR);
  END GET_DESC_FLEX_CONTEXT;

  PROCEDURE GET_DVLPR_DESC_FLEX(P_APPL_SHORT_NAME IN CHAR
                               ,P_DESC_FLEX_NAME IN CHAR
                               ,P_DESC_FLEX_CONTEXT IN CHAR
                               ,P_TABLE_ALIAS IN CHAR
                               ,P_TITLE OUT NOCOPY CHAR
                               ,P_LABEL_EXPR OUT NOCOPY CHAR
                               ,P_COLUMN_EXPR OUT NOCOPY CHAR) IS
  BEGIN
    STPROC.INIT('begin HR_REPORTS.GET_DVLPR_DESC_FLEX(:P_APPL_SHORT_NAME, :P_DESC_FLEX_NAME, :P_DESC_FLEX_CONTEXT, :P_TABLE_ALIAS, :P_TITLE, :P_LABEL_EXPR, :P_COLUMN_EXPR); end;');
    STPROC.BIND_I(P_APPL_SHORT_NAME);
    STPROC.BIND_I(P_DESC_FLEX_NAME);
    STPROC.BIND_I(P_DESC_FLEX_CONTEXT);
    STPROC.BIND_I(P_TABLE_ALIAS);
    STPROC.BIND_O(P_TITLE);
    STPROC.BIND_O(P_LABEL_EXPR);
    STPROC.BIND_O(P_COLUMN_EXPR);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(5
                   ,P_TITLE);
    STPROC.RETRIEVE(6
                   ,P_LABEL_EXPR);
    STPROC.RETRIEVE(7
                   ,P_COLUMN_EXPR);
  END GET_DVLPR_DESC_FLEX;

  FUNCTION GET_PERSON_NAME(P_SESSION_DATE IN DATE
                          ,P_PERSON_ID IN NUMBER) RETURN CHAR IS
    X0 CHAR(2000);
  BEGIN
    STPROC.INIT('begin :X0 := HR_REPORTS.GET_PERSON_NAME(:P_SESSION_DATE, :P_PERSON_ID); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_SESSION_DATE);
    STPROC.BIND_I(P_PERSON_ID);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_PERSON_NAME; */

END PAY_PAYCABPS_XMLP_PKG;

/
