--------------------------------------------------------
--  DDL for Package Body PAY_PYAURECP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYAURECP_XMLP_PKG" AS
/* $Header: PYAURECPB.pls 120.0.12010000.2 2009/07/09 07:08:35 skshin ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_YEAR(C_FIN_YR IN VARCHAR2) IS
      SELECT
        TO_DATE('01-07-' || SUBSTR(C_FIN_YR
                      ,1
                      ,4)
               ,'DD-MM-YYYY') FINANCIAL_YEAR_START,
        TO_DATE('30-06-' || SUBSTR(C_FIN_YR
                      ,6
                      ,4)
               ,'DD-MM-YYYY') FINANCIAL_YEAR_END,
        TO_DATE('01-04-' || SUBSTR(C_FIN_YR
                      ,1
                      ,4)
               ,'DD-MM-YYYY') FBT_YEAR_START,
        TO_DATE('30-06-' || SUBSTR(C_FIN_YR
                      ,1
                      ,4)
               ,'DD-MM-YYYY') FBT_YEAR_END
      FROM
        DUAL;
    CURSOR C_REG_EMP(C_ORG_ID IN HR_AU_LEG_EMP_V.ORGANIZATION_ID%TYPE) IS
      SELECT
        NAME
      FROM
        HR_AU_LEG_EMP_V
      WHERE ORGANIZATION_ID = C_ORG_ID;
    CURSOR C_PAYROLL_INFO(C_PAYROLL_ID IN NUMBER) IS
      SELECT
        PPF.PAYROLL_NAME
      FROM
        PAY_PAYROLLS_F PPF
      WHERE PPF.PAYROLL_ID = C_PAYROLL_ID
        AND PPF.EFFECTIVE_START_DATE = (
        SELECT
          MAX(PPF1.EFFECTIVE_START_DATE)
        FROM
          PAY_PAYROLLS_F PPF1
        WHERE PPF1.PAYROLL_ID = PPF.PAYROLL_ID );
    CURSOR C_HL_MEANING(C_HL_CODE IN HR_LOOKUPS.LOOKUP_CODE%TYPE) IS
      SELECT
        HL.MEANING
      FROM
        HR_LOOKUPS HL
      WHERE HL.LOOKUP_TYPE = 'AU_PS_EMPLOYEE_TYPE'
        AND HL.ENABLED_FLAG = 'Y'
        AND HL.LOOKUP_CODE = C_HL_CODE;
    CURSOR C_ASSIGNMENT_INFO(C_ASSIGNMENT_ID IN NUMBER) IS
      SELECT
        PAA.ASSIGNMENT_NUMBER
      FROM
        PER_ASSIGNMENTS_F PAA
      WHERE PAA.ASSIGNMENT_ID = C_ASSIGNMENT_ID
        AND PAA.EFFECTIVE_START_DATE = (
        SELECT
          MAX(PAA1.EFFECTIVE_START_DATE)
        FROM
          PER_ASSIGNMENTS_F PAA1
        WHERE PAA1.ASSIGNMENT_ID = PAA.ASSIGNMENT_ID
          AND PAA1.EFFECTIVE_START_DATE <= CP_FIN_YR_END
          AND PAA1.EFFECTIVE_END_DATE >= CP_FIN_YR_START );
    CURSOR C_GET_GLOBAL(C_NAME IN VARCHAR2,C_YEAR_END IN DATE) IS
      SELECT
        GLOBAL_VALUE
      FROM
        FF_GLOBALS_F
      WHERE GLOBAL_NAME = C_NAME
        AND LEGISLATION_CODE = 'AU'
        AND C_YEAR_END BETWEEN EFFECTIVE_START_DATE
        AND EFFECTIVE_END_DATE;
    CURSOR C_ASG_COUNT IS
      SELECT
        COUNT(ASSIGNMENT_ACTION_ID)
      FROM
        PAY_ASSIGNMENT_ACTIONS
      WHERE PAYROLL_ACTION_ID = LP_PAYROLL_ACTION_ID;
    X NUMBER;
    L_TEXT LONG;
    LN NUMBER;
  BEGIN
  select
    SUBSTR(argument1,INSTR(argument1,'=',1)+1,LENGTH(argument1)),
    SUBSTR(argument2,INSTR(argument2,'=',1)+1,LENGTH(argument2)),
    SUBSTR(argument3,INSTR(argument3,'=',1)+1,LENGTH(argument3)),
    SUBSTR(argument4,INSTR(argument4,'=',1)+1,LENGTH(argument4)),
    SUBSTR(argument5,INSTR(argument5,'=',1)+1,LENGTH(argument5)),
    SUBSTR(argument6,INSTR(argument6,'=',1)+1,LENGTH(argument6)),
    SUBSTR(argument7,INSTR(argument7,'=',1)+1,LENGTH(argument7)),
    SUBSTR(argument8,INSTR(argument8,'=',1)+1,LENGTH(argument8))
  into

  LP_PAYROLL_ACTION_ID,
  LP_ASSIGNMENT_ID,
  LP_BUSINESS_GROUP_ID,
  LP_EMPLOYEE_TYPE,
  LP_FINANCIAL_YEAR,
  LP_LST_YR_TERM,
  LP_PAYROLL_ID,
  LP_REGISTERED_EMPLOYER

    from FND_CONCURRENT_REQUESTS
where request_id= FND_GLOBAL.conc_request_id;
  P_ASSIGNMENT_ID:=LP_ASSIGNMENT_ID;

    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X := PAY_AU_RECON_SUMMARY.POPULATE_BAL_IDS('Y'
                                              ,LP_BUSINESS_GROUP_ID
                                              ,LP_LST_YR_TERM);
   -- WHERECLAUSE := NULL;
    WHERECLAUSE := ' ';
    IF (LP_REGISTERED_EMPLOYER IS NOT NULL) THEN
      IF (LP_PAYROLL_ID IS NOT NULL) THEN
        CP_DIMENSION := '_ASG_LE_YTD';
        IF (LP_ASSIGNMENT_ID IS NOT NULL) THEN
          WHERECLAUSE := 'and pa1.assignment_id=' || LP_ASSIGNMENT_ID;
        ELSE
          WHERECLAUSE := 'and pa1.payroll_id=' || LP_PAYROLL_ID;
        END IF;
      ELSE
        CP_DIMENSION := '_LE_YTD';
      END IF;
    END IF;

    CP_TOTAL_STANDARD := 0;
    CP_TOTAL_CURRENT_EMPLOYEES := 0;
    CP_TOTAL_TERMINATED_EMPLOYEES := 0;
    CP_TOTAL_GROSS := 0;
    CP_TOTAL_ALLOWANCES := 0;
    CP_TOTAL_RFB := 0;
    CP_TOTAL_CDEP := 0;
    CP_TOTAL_LUMPSUM_A_PAY := 0;
    CP_TOTAL_LUMPSUM_B_PAY := 0;
    CP_TOTAL_LUMPSUM_D_PAY := 0;
    CP_TOTAL_LUMPSUM_E_PAY := 0;
    CP_TOTAL_UNION_FEES := 0;
    CP_TOTAL_TID := 0;
    CP_TOTAL_OTHER_INCOME := 0;
    CP_TOTAL_ETP := 0;
    CP_TOTAL_PRE_JUL_83 := 0;
    CP_TOTAL_JUN_83_UNT := 0;
    CP_TOTAL_JUN_83_TAX := 0;
    CP_TOTAL_JUN_94_INV := 0;
    CP_TOTAL_GROSS_ETP := 0;
    CP_TOTAL_ETP_TID := 0;
    CP_TOTAL_ASSESSABLE_INCOME := 0;
    CP_TOTAL_WORKPLACE := 0;
    CP_MAN_TOTAL_STANDARD := 0;
    CP_MAN_TOTAL_CURR_EMPLOYEES := 0;
    CP_MAN_TOTAL_TERM_EMPLOYEES := 0;
    CP_MAN_TOTAL_GROSS := 0;
    CP_MAN_TOTAL_ALLOWANCES := 0;
    CP_MAN_TOTAL_RFB := 0;
    CP_MAN_TOTAL_CDEP := 0;
    CP_MAN_TOTAL_LUMPSUM_A_PAY := 0;
    CP_MAN_TOTAL_LUMPSUM_B_PAY := 0;
    CP_MAN_TOTAL_LUMPSUM_D_PAY := 0;
    CP_MAN_TOTAL_LUMPSUM_E_PAY := 0;
    CP_MAN_TOTAL_UNION_FEES := 0;
    CP_MAN_TOTAL_TID := 0;
    CP_MAN_TOTAL_OTHER_INCOME := 0;
    CP_MAN_TOTAL_ETP := 0;
    CP_MAN_TOTAL_PRE_JUL_83 := 0;
    CP_MAN_TOTAL_JUN_83_UNT := 0;
    CP_MAN_TOTAL_JUN_83_TAX := 0;
    CP_MAN_TOTAL_JUN_94_INV := 0;
    CP_MAN_TOTAL_GROSS_ETP := 0;
    CP_MAN_TOTAL_ETP_TID := 0;
    CP_MAN_TOTAL_ASSESSABLE_INCOME := 0;
    CP_MAN_TOTAL_WORKPLACE := 0;
    OPEN C_YEAR(LP_FINANCIAL_YEAR);
    FETCH C_YEAR
     INTO
       CP_FIN_YR_START
       ,CP_FIN_YR_END
       ,CP_FBT_YR_START
       ,CP_FBT_YR_END;
    CLOSE C_YEAR;
    CP_FINANCIAL_YEAR := LP_FINANCIAL_YEAR;
    IF (LP_LST_YR_TERM = 'Y') THEN
      CP_LST_YR_START := ADD_MONTHS(CP_FIN_YR_START
                                   ,-12);
    ELSE
      CP_LST_YR_START := TO_DATE('01/01/1900'
                                ,'DD/MM/YYYY');
    END IF;
    OPEN C_REG_EMP(LP_REGISTERED_EMPLOYER);
    FETCH C_REG_EMP
     INTO
       CP_REG_EMP;
    CLOSE C_REG_EMP;
    OPEN C_HL_MEANING(LP_EMPLOYEE_TYPE);
    FETCH C_HL_MEANING
     INTO
       CP_EMP_TYPE;
    CLOSE C_HL_MEANING;
    IF LP_PAYROLL_ID IS NOT NULL THEN
      OPEN C_PAYROLL_INFO(LP_PAYROLL_ID);
      FETCH C_PAYROLL_INFO
       INTO
         CP_PAYROLL_NAME;
      CLOSE C_PAYROLL_INFO;
    END IF;
    IF LP_ASSIGNMENT_ID IS NOT NULL THEN
      OPEN C_ASSIGNMENT_INFO(LP_ASSIGNMENT_ID);
      FETCH C_ASSIGNMENT_INFO
       INTO
         CP_ASSIGNMENT_NUMBER;
      CLOSE C_ASSIGNMENT_INFO;
    END IF;
    IF LP_EMPLOYEE_TYPE = 'C' THEN
      LP_EMPLOYEE_TYPE := 'Y';
    END IF;
    IF LP_EMPLOYEE_TYPE = 'T' THEN
      LP_EMPLOYEE_TYPE := 'N';
    END IF;
    IF LP_EMPLOYEE_TYPE = 'B' THEN
      LP_EMPLOYEE_TYPE := '%';
    END IF;
    IF LP_LST_YR_TERM = 'Y' THEN
      CP_LST_YR_TERM := 'Yes';
    ELSE
      IF LP_LST_YR_TERM = 'N' THEN
        CP_LST_YR_TERM := 'No';
      END IF;
    END IF;
    OPEN C_GET_GLOBAL('FBT_RATE',ADD_MONTHS(CP_FIN_YR_END
              ,-3));
    FETCH C_GET_GLOBAL
     INTO
       CP_FBT_GLOBAL;
    CLOSE C_GET_GLOBAL;
    OPEN C_GET_GLOBAL('MEDICARE_LEVY',ADD_MONTHS(CP_FIN_YR_END
              ,-3));
    FETCH C_GET_GLOBAL
     INTO
       CP_ML_GLOBAL;
    CLOSE C_GET_GLOBAL;
    OPEN C_ASG_COUNT;
    FETCH C_ASG_COUNT
     INTO
       CP_ASSGT_TOTAL;
    CLOSE C_ASG_COUNT;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_CALC_TOTALSFORMULA(ASSIGNMENT_ID IN NUMBER
                                ,TAX_UNIT_ID IN NUMBER
                                ,EMP_TYPE IN VARCHAR2
                                ,TERM_DATE IN DATE
                                ,DATE_EARNED IN DATE
                                ,ASSIGNMENT_ACTION_ID IN NUMBER) RETURN NUMBER IS
    L_OUTPUT_TAB PAY_AU_RECON_SUMMARY.BAL_TAB;
    L_TERM_OUTPUT_TAB PAY_AU_RECON_SUMMARY.BAL_TAB;
    L_DISPLAY_FLAG VARCHAR2(5);
    L_FBT_VALUE NUMBER;
    X NUMBER;
    L_MANUAL_PS_YEAR VARCHAR2(80);
    CURSOR C_PAYMENT_SUMMARY_DETAILS(C_ASSIGNMENT_ID IN NUMBER,C_FIN_DATE IN DATE,C_TAX_UNIT_ID IN PAY_ASSIGNMENT_ACTIONS.TAX_UNIT_ID%TYPE) IS
      SELECT
        HR.MEANING FIN_YEAR
      FROM
        PER_ASSIGNMENT_EXTRA_INFO PAE,
        HR_LOOKUPS HR
      WHERE PAE.AEI_INFORMATION_CATEGORY = 'HR_PS_ISSUE_DATE_AU'
        AND PAE.INFORMATION_TYPE = 'HR_PS_ISSUE_DATE_AU'
        AND PAE.ASSIGNMENT_ID = C_ASSIGNMENT_ID
        AND PAE.AEI_INFORMATION1 = TO_CHAR(C_FIN_DATE
             ,'YY')
        AND NVL(AEI_INFORMATION2
         ,C_TAX_UNIT_ID) = DECODE(AEI_INFORMATION2
            ,'-999'
            ,AEI_INFORMATION2
            ,C_TAX_UNIT_ID)
        AND PAE.AEI_INFORMATION1 = HR.LOOKUP_CODE
        AND HR.LOOKUP_TYPE = 'AU_PS_FINANCIAL_YEAR';
  BEGIN
    OPEN C_PAYMENT_SUMMARY_DETAILS(ASSIGNMENT_ID,CP_FIN_YR_START,TAX_UNIT_ID);
    FETCH C_PAYMENT_SUMMARY_DETAILS
     INTO
       L_MANUAL_PS_YEAR;
    IF C_PAYMENT_SUMMARY_DETAILS%FOUND THEN
      MANUAL_PS_ISSUED := 'Y';
    ELSE
      MANUAL_PS_ISSUED := 'N';
    END IF;
    CLOSE C_PAYMENT_SUMMARY_DETAILS;
    IF EMP_TYPE = 'T' THEN
      IF ((LP_LST_YR_TERM = 'Y' AND TERM_DATE > CP_FBT_YR_START) OR (LP_LST_YR_TERM = 'N' AND TERM_DATE > CP_LST_YR_START)) AND TERM_DATE < CP_FIN_YR_START AND DATE_EARNED < CP_FIN_YR_START THEN
        CP_TOTAL_STANDARD := CP_TOTAL_STANDARD + 1;
        CP_TOTAL_TERMINATED_EMPLOYEES := CP_TOTAL_TERMINATED_EMPLOYEES + 1;
        L_FBT_VALUE := PAY_AU_RECON_SUMMARY.GET_TOTAL_FBT(CP_FIN_YR_START
                                                         ,ASSIGNMENT_ID
                                                         ,TAX_UNIT_ID
                                                         ,CP_FBT_GLOBAL
                                                         ,CP_ML_GLOBAL
                                                         ,'PRV_TERM');
        CP_TOTAL_RFB := CP_TOTAL_RFB + L_FBT_VALUE;
        X := PAY_AU_RECON_SUMMARY.POPULATE_EXCLUSION_TABLE(ASSIGNMENT_ID
                                                          ,CP_FINANCIAL_YEAR
                                                          ,CP_FIN_YR_END
                                                          ,TAX_UNIT_ID);
        IF MANUAL_PS_ISSUED = 'Y' THEN
          CP_MAN_TOTAL_STANDARD := CP_MAN_TOTAL_STANDARD + 1;
          CP_MAN_TOTAL_TERM_EMPLOYEES := CP_MAN_TOTAL_TERM_EMPLOYEES + 1;
          CP_MAN_TOTAL_RFB := CP_MAN_TOTAL_RFB + L_FBT_VALUE;
        END IF;
        RETURN (1);
      END IF;
    END IF;
    IF (LP_EMPLOYEE_TYPE = '%' AND CP_DIMENSION < '_ASG_LE_YTD') THEN
      L_DISPLAY_FLAG := 'YES';
      IF (EMP_TYPE = 'T') THEN
        IF (TERM_DATE < CP_FIN_YR_START) THEN
          PAY_AU_RECON_SUMMARY.GET_VALUE_BBR(CP_FIN_YR_START
                                            ,CP_FIN_YR_END
                                            ,ASSIGNMENT_ID
                                            ,CP_FBT_GLOBAL
                                            ,CP_ML_GLOBAL
                                            ,ASSIGNMENT_ACTION_ID
                                            ,TAX_UNIT_ID
                                            ,TERM_DATE
                                            ,L_DISPLAY_FLAG
                                            ,L_OUTPUT_TAB);

        ELSE
          L_DISPLAY_FLAG := 'YES';
        END IF;

      END IF;
      IF L_DISPLAY_FLAG = 'YES' THEN
        CP_TOTAL_STANDARD := CP_TOTAL_STANDARD + 1;
        PAY_AU_RECON_SUMMARY.GET_ASSGT_CURR_TERM_VALUES_BBR(P_YEAR_START => CP_FIN_YR_START
                                                           ,P_YEAR_END => CP_FIN_YR_END
                                                           ,P_ASSIGNMENT_ID => ASSIGNMENT_ID
                                                           ,P_FBT_RATE => CP_FBT_GLOBAL
                                                           ,P_ML_RATE => CP_ML_GLOBAL
                                                           ,P_ASSIGNMENT_ACTION_ID => ASSIGNMENT_ACTION_ID
                                                           ,P_TAX_UNIT_ID => TAX_UNIT_ID
                                                           ,P_EMP_TYPE => EMP_TYPE
                                                           ,P_TERM_OUTPUT_TAB => L_TERM_OUTPUT_TAB);

        /* bug 7571001 - Allowance is removed */
        CP_TOTAL_RFB := CP_TOTAL_RFB + L_TERM_OUTPUT_TAB(1).BALANCE_VALUE;
        CP_TOTAL_LUMPSUM_E_PAY := CP_TOTAL_LUMPSUM_E_PAY + L_TERM_OUTPUT_TAB(2).BALANCE_VALUE;
        IF EMP_TYPE = 'C' THEN
          CP_TOTAL_CURRENT_EMPLOYEES := CP_TOTAL_CURRENT_EMPLOYEES + 1;
        END IF;
        IF EMP_TYPE = 'T' THEN
          CP_TOTAL_TERMINATED_EMPLOYEES := CP_TOTAL_TERMINATED_EMPLOYEES + 1;
          IF (L_TERM_OUTPUT_TAB(7).BALANCE_VALUE > 0) THEN
            CP_TOTAL_ETP := CP_TOTAL_ETP + 1;
            CP_TOTAL_PRE_JUL_83 := CP_TOTAL_PRE_JUL_83 + L_TERM_OUTPUT_TAB(3).BALANCE_VALUE;
            CP_TOTAL_JUN_83_UNT := CP_TOTAL_JUN_83_UNT + L_TERM_OUTPUT_TAB(4).BALANCE_VALUE;
            CP_TOTAL_JUN_94_INV := CP_TOTAL_JUN_94_INV + L_TERM_OUTPUT_TAB(5).BALANCE_VALUE;
            CP_TOTAL_GROSS_ETP := CP_TOTAL_GROSS_ETP + L_TERM_OUTPUT_TAB(6).BALANCE_VALUE;
            CP_TOTAL_ETP_TID := CP_TOTAL_ETP_TID + L_TERM_OUTPUT_TAB(7).BALANCE_VALUE;
            CP_TOTAL_ASSESSABLE_INCOME := CP_TOTAL_ASSESSABLE_INCOME + L_TERM_OUTPUT_TAB(8).BALANCE_VALUE;
          END IF;
        END IF;
        X := PAY_AU_RECON_SUMMARY.POPULATE_EXCLUSION_TABLE(ASSIGNMENT_ID
                                                          ,CP_FINANCIAL_YEAR
                                                          ,CP_FIN_YR_END
                                                          ,TAX_UNIT_ID);
      END IF;
    ELSE
      PAY_AU_RECON_SUMMARY.GET_VALUE_BBR(CP_FIN_YR_START
                                        ,CP_FIN_YR_END
                                        ,ASSIGNMENT_ID
                                        ,CP_FBT_GLOBAL
                                        ,CP_ML_GLOBAL
                                        ,ASSIGNMENT_ACTION_ID
                                        ,TAX_UNIT_ID
                                        ,TERM_DATE
                                        ,L_DISPLAY_FLAG
                                        ,L_OUTPUT_TAB);

      IF L_DISPLAY_FLAG = 'YES' THEN
        CP_TOTAL_STANDARD := CP_TOTAL_STANDARD + 1;
        IF EMP_TYPE = 'C' THEN
          CP_TOTAL_CURRENT_EMPLOYEES := CP_TOTAL_CURRENT_EMPLOYEES + 1;
        END IF;
        IF EMP_TYPE = 'T' THEN
          CP_TOTAL_TERMINATED_EMPLOYEES := CP_TOTAL_TERMINATED_EMPLOYEES + 1;
        END IF;
        CP_TOTAL_GROSS := CP_TOTAL_GROSS + L_OUTPUT_TAB(11).BALANCE_VALUE;
        CP_TOTAL_ALLOWANCES := CP_TOTAL_ALLOWANCES + L_OUTPUT_TAB(1).BALANCE_VALUE;
        CP_TOTAL_RFB := CP_TOTAL_RFB + L_OUTPUT_TAB(2).BALANCE_VALUE;
        CP_TOTAL_CDEP := CP_TOTAL_CDEP + L_OUTPUT_TAB(3).BALANCE_VALUE;
        CP_TOTAL_LUMPSUM_A_PAY := CP_TOTAL_LUMPSUM_A_PAY + L_OUTPUT_TAB(4).BALANCE_VALUE;
        CP_TOTAL_LUMPSUM_B_PAY := CP_TOTAL_LUMPSUM_B_PAY + L_OUTPUT_TAB(5).BALANCE_VALUE;
        CP_TOTAL_LUMPSUM_D_PAY := CP_TOTAL_LUMPSUM_D_PAY + L_OUTPUT_TAB(6).BALANCE_VALUE;
        CP_TOTAL_LUMPSUM_E_PAY := CP_TOTAL_LUMPSUM_E_PAY + L_OUTPUT_TAB(7).BALANCE_VALUE;
        CP_TOTAL_UNION_FEES := CP_TOTAL_UNION_FEES + L_OUTPUT_TAB(8).BALANCE_VALUE;
        CP_TOTAL_TID := CP_TOTAL_TID + L_OUTPUT_TAB(9).BALANCE_VALUE;
        CP_TOTAL_OTHER_INCOME := CP_TOTAL_OTHER_INCOME + L_OUTPUT_TAB(10).BALANCE_VALUE;
        CP_TOTAL_WORKPLACE := CP_TOTAL_WORKPLACE + L_OUTPUT_TAB(18).BALANCE_VALUE;
        IF (EMP_TYPE = 'T' AND L_OUTPUT_TAB(15).BALANCE_VALUE > 0) THEN
          CP_TOTAL_ETP := CP_TOTAL_ETP + 1;
          CP_TOTAL_PRE_JUL_83 := CP_TOTAL_PRE_JUL_83 + L_OUTPUT_TAB(12).BALANCE_VALUE;
          CP_TOTAL_JUN_83_UNT := CP_TOTAL_JUN_83_UNT + L_OUTPUT_TAB(13).BALANCE_VALUE;
          CP_TOTAL_JUN_94_INV := CP_TOTAL_JUN_94_INV + L_OUTPUT_TAB(14).BALANCE_VALUE;
          CP_TOTAL_GROSS_ETP := CP_TOTAL_GROSS_ETP + L_OUTPUT_TAB(15).BALANCE_VALUE;
          CP_TOTAL_ETP_TID := CP_TOTAL_ETP_TID + L_OUTPUT_TAB(16).BALANCE_VALUE;
          CP_TOTAL_ASSESSABLE_INCOME := CP_TOTAL_ASSESSABLE_INCOME + L_OUTPUT_TAB(17).BALANCE_VALUE;
        END IF;
        X := PAY_AU_RECON_SUMMARY.POPULATE_EXCLUSION_TABLE(ASSIGNMENT_ID
                                                          ,CP_FINANCIAL_YEAR
                                                          ,CP_FIN_YR_END
                                                          ,TAX_UNIT_ID);
      END IF;
    END IF;
    IF MANUAL_PS_ISSUED = 'Y' THEN
      IF (LP_EMPLOYEE_TYPE = '%' AND CP_DIMENSION < '_ASG_LE_YTD') THEN
        PAY_AU_RECON_SUMMARY.GET_VALUE_BBR(CP_FIN_YR_START
                                          ,CP_FIN_YR_END
                                          ,ASSIGNMENT_ID
                                          ,CP_FBT_GLOBAL
                                          ,CP_ML_GLOBAL
                                          ,ASSIGNMENT_ACTION_ID
                                          ,TAX_UNIT_ID
                                          ,TERM_DATE
                                          ,L_DISPLAY_FLAG
                                          ,L_OUTPUT_TAB);

      END IF;
      IF L_DISPLAY_FLAG = 'YES' THEN
        CP_MAN_TOTAL_STANDARD := CP_MAN_TOTAL_STANDARD + 1;
        IF EMP_TYPE = 'C' THEN
          CP_MAN_TOTAL_CURR_EMPLOYEES := CP_MAN_TOTAL_CURR_EMPLOYEES + 1;
        END IF;
        IF EMP_TYPE = 'T' THEN
          CP_MAN_TOTAL_TERM_EMPLOYEES := CP_MAN_TOTAL_TERM_EMPLOYEES + 1;
        END IF;
        CP_MAN_TOTAL_GROSS := CP_MAN_TOTAL_GROSS + L_OUTPUT_TAB(11).BALANCE_VALUE;
        CP_MAN_TOTAL_ALLOWANCES := CP_MAN_TOTAL_ALLOWANCES + L_OUTPUT_TAB(1).BALANCE_VALUE;
        CP_MAN_TOTAL_RFB := CP_MAN_TOTAL_RFB + L_OUTPUT_TAB(2).BALANCE_VALUE;
        CP_MAN_TOTAL_CDEP := CP_MAN_TOTAL_CDEP + L_OUTPUT_TAB(3).BALANCE_VALUE;
        CP_MAN_TOTAL_LUMPSUM_A_PAY := CP_MAN_TOTAL_LUMPSUM_A_PAY + L_OUTPUT_TAB(4).BALANCE_VALUE;
        CP_MAN_TOTAL_LUMPSUM_B_PAY := CP_MAN_TOTAL_LUMPSUM_B_PAY + L_OUTPUT_TAB(5).BALANCE_VALUE;
        CP_MAN_TOTAL_LUMPSUM_D_PAY := CP_MAN_TOTAL_LUMPSUM_D_PAY + L_OUTPUT_TAB(6).BALANCE_VALUE;
        CP_MAN_TOTAL_LUMPSUM_E_PAY := CP_MAN_TOTAL_LUMPSUM_E_PAY + L_OUTPUT_TAB(7).BALANCE_VALUE;
        CP_MAN_TOTAL_UNION_FEES := CP_MAN_TOTAL_UNION_FEES + L_OUTPUT_TAB(8).BALANCE_VALUE;
        CP_MAN_TOTAL_TID := CP_MAN_TOTAL_TID + L_OUTPUT_TAB(9).BALANCE_VALUE;
        CP_MAN_TOTAL_OTHER_INCOME := CP_MAN_TOTAL_OTHER_INCOME + L_OUTPUT_TAB(10).BALANCE_VALUE;
        CP_MAN_TOTAL_WORKPLACE := CP_MAN_TOTAL_WORKPLACE + L_OUTPUT_TAB(18).BALANCE_VALUE;
        IF (EMP_TYPE = 'T' AND L_OUTPUT_TAB(15).BALANCE_VALUE > 0) THEN
          CP_MAN_TOTAL_ETP := CP_MAN_TOTAL_ETP + 1;
          CP_MAN_TOTAL_PRE_JUL_83 := CP_MAN_TOTAL_PRE_JUL_83 + L_OUTPUT_TAB(12).BALANCE_VALUE;
          CP_MAN_TOTAL_JUN_83_UNT := CP_MAN_TOTAL_JUN_83_UNT + L_OUTPUT_TAB(13).BALANCE_VALUE;
          CP_MAN_TOTAL_JUN_94_INV := CP_MAN_TOTAL_JUN_94_INV + L_OUTPUT_TAB(14).BALANCE_VALUE;
          CP_MAN_TOTAL_GROSS_ETP := CP_MAN_TOTAL_GROSS_ETP + L_OUTPUT_TAB(15).BALANCE_VALUE;
          CP_MAN_TOTAL_ETP_TID := CP_MAN_TOTAL_ETP_TID + L_OUTPUT_TAB(16).BALANCE_VALUE;
          CP_MAN_TOTAL_ASSESSABLE_INCOME := CP_MAN_TOTAL_ASSESSABLE_INCOME + L_OUTPUT_TAB(17).BALANCE_VALUE;
        END IF;
      END IF;
    END IF;
    RETURN (1);
  END CF_CALC_TOTALSFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DELETE FROM PAY_ASSIGNMENT_ACTIONS
     WHERE PAYROLL_ACTION_ID = LP_PAYROLL_ACTION_ID;
    DELETE FROM PAY_PAYROLL_ACTIONS
     WHERE PAYROLL_ACTION_ID = LP_PAYROLL_ACTION_ID;
    COMMIT;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_CALC_GROUP_TOTALSFORMULA RETURN NUMBER IS
    CURSOR CSR_MAX_ASSGT_ACTION IS
      SELECT
        TO_NUMBER(SUBSTR(MAX(LPAD(PAA.ACTION_SEQUENCE
                                 ,15
                                 ,'0') || PAA.ASSIGNMENT_ACTION_ID)
                        ,16)) ASSIGNMENT_ACTION_ID
      FROM
        PAY_ASSIGNMENT_ACTIONS PAA,
        PAY_PAYROLL_ACTIONS PPA
      WHERE PAA.TAX_UNIT_ID = LP_REGISTERED_EMPLOYER
        AND PAA.PAYROLL_ACTION_ID = PPA.PAYROLL_ACTION_ID
        AND PPA.PAYROLL_ID = NVL(LP_PAYROLL_ID
         ,PPA.PAYROLL_ID)
        AND PAA.ASSIGNMENT_ID = NVL(LP_ASSIGNMENT_ID
         ,PAA.ASSIGNMENT_ID)
        AND PPA.EFFECTIVE_DATE BETWEEN CP_FIN_YR_START
        AND CP_FIN_YR_END
        AND PAA.ACTION_STATUS = 'C'
        AND PPA.ACTION_STATUS = 'C'
        AND PPA.ACTION_TYPE in ( 'R' , 'Q' , 'I' , 'V' , 'B' );
    L_ASSIGNMENT_ACTION_ID PAY_ASSIGNMENT_ACTIONS.ASSIGNMENT_ACTION_ID%TYPE;
    L_GROUP_OUTPUT_TAB PAY_AU_RECON_SUMMARY.BAL_TAB;
    L_GROUP_ASSGT_OUTPUT_TAB PAY_AU_RECON_SUMMARY.BAL_TAB;
  BEGIN
    L_GROUP_OUTPUT_TAB.DELETE;
    CP_ASSGT_COUNTER := CP_ASSGT_COUNTER + 1;
    IF (CP_ASSGT_COUNTER = CP_ASSGT_TOTAL AND LP_EMPLOYEE_TYPE = '%' AND CP_DIMENSION < '_ASG_LE_YTD') THEN
      OPEN CSR_MAX_ASSGT_ACTION;
      FETCH CSR_MAX_ASSGT_ACTION
       INTO
         L_ASSIGNMENT_ACTION_ID;
      CLOSE CSR_MAX_ASSGT_ACTION;
      PAY_AU_RECON_SUMMARY.POPULATE_GROUP_DEF_BAL_IDS(P_DIMENSION_NAME => CP_DIMENSION
                                                                                             ,p_business_group_id => LP_BUSINESS_GROUP_ID);  -- added for bug 7571001
      PAY_AU_RECON_SUMMARY.GET_GROUP_VALUES_BBR(p_year_start           => CP_FIN_YR_START  -- added for bug 7571001
                                               , p_year_end             => CP_FIN_YR_END    -- added for bug 7571001
                                               ,P_ASSIGNMENT_ACTION_ID => L_ASSIGNMENT_ACTION_ID
                                               ,P_DATE_EARNED => CP_FIN_YR_END
                                               ,P_TAX_UNIT_ID => LP_REGISTERED_EMPLOYER
                                               ,P_GROUP_OUTPUT_TAB => L_GROUP_OUTPUT_TAB);
      CP_TOTAL_LUMPSUM_A_PAY := L_GROUP_OUTPUT_TAB(1).BALANCE_VALUE;
      CP_TOTAL_LUMPSUM_B_PAY := L_GROUP_OUTPUT_TAB(2).BALANCE_VALUE;
      CP_TOTAL_LUMPSUM_D_PAY := L_GROUP_OUTPUT_TAB(3).BALANCE_VALUE;
      CP_TOTAL_UNION_FEES := L_GROUP_OUTPUT_TAB(4).BALANCE_VALUE;
      CP_TOTAL_TID := L_GROUP_OUTPUT_TAB(5).BALANCE_VALUE;
      CP_TOTAL_CDEP := L_GROUP_OUTPUT_TAB(8).BALANCE_VALUE;
      CP_TOTAL_OTHER_INCOME := L_GROUP_OUTPUT_TAB(9).BALANCE_VALUE;
      CP_TOTAL_WORKPLACE := L_GROUP_OUTPUT_TAB(10).BALANCE_VALUE;
      CP_TOTAL_ALLOWANCES    := L_GROUP_OUTPUT_TAB(11).BALANCE_VALUE;  -- bug 7571001
      CP_TOTAL_GROSS := (L_GROUP_OUTPUT_TAB(6).BALANCE_VALUE + L_GROUP_OUTPUT_TAB(7).BALANCE_VALUE) + CP_TOTAL_WORKPLACE - (GREATEST(CP_TOTAL_ALLOWANCES
                                ,0) + CP_TOTAL_CDEP + CP_TOTAL_OTHER_INCOME + CP_TOTAL_LUMPSUM_E_PAY);
    END IF;
    IF (CP_ASSGT_COUNTER = CP_ASSGT_TOTAL) THEN
      CP_TOTAL_STANDARD := CP_TOTAL_STANDARD - CP_MAN_TOTAL_STANDARD;
      CP_TOTAL_CURRENT_EMPLOYEES := CP_TOTAL_CURRENT_EMPLOYEES - CP_MAN_TOTAL_CURR_EMPLOYEES;
      CP_TOTAL_TERMINATED_EMPLOYEES := CP_TOTAL_TERMINATED_EMPLOYEES - CP_MAN_TOTAL_TERM_EMPLOYEES;
      CP_TOTAL_GROSS := CP_TOTAL_GROSS - CP_MAN_TOTAL_GROSS;
      CP_TOTAL_ALLOWANCES := CP_TOTAL_ALLOWANCES - CP_MAN_TOTAL_ALLOWANCES;
      CP_TOTAL_RFB := CP_TOTAL_RFB - CP_MAN_TOTAL_RFB;
      CP_TOTAL_CDEP := CP_TOTAL_CDEP - CP_MAN_TOTAL_CDEP;
      CP_TOTAL_LUMPSUM_A_PAY := CP_TOTAL_LUMPSUM_A_PAY - CP_MAN_TOTAL_LUMPSUM_A_PAY;
      CP_TOTAL_LUMPSUM_B_PAY := CP_TOTAL_LUMPSUM_B_PAY - CP_MAN_TOTAL_LUMPSUM_B_PAY;
      CP_TOTAL_LUMPSUM_D_PAY := CP_TOTAL_LUMPSUM_D_PAY - CP_MAN_TOTAL_LUMPSUM_D_PAY;
      CP_TOTAL_LUMPSUM_E_PAY := CP_TOTAL_LUMPSUM_E_PAY - CP_MAN_TOTAL_LUMPSUM_E_PAY;
      CP_TOTAL_UNION_FEES := CP_TOTAL_UNION_FEES - CP_MAN_TOTAL_UNION_FEES;
      CP_TOTAL_TID := CP_TOTAL_TID - CP_MAN_TOTAL_TID;
      CP_TOTAL_OTHER_INCOME := CP_TOTAL_OTHER_INCOME - CP_MAN_TOTAL_OTHER_INCOME;
      CP_TOTAL_ETP := CP_TOTAL_ETP - CP_MAN_TOTAL_ETP;
      CP_TOTAL_PRE_JUL_83 := CP_TOTAL_PRE_JUL_83 - CP_MAN_TOTAL_PRE_JUL_83;
      CP_TOTAL_JUN_83_UNT := CP_TOTAL_JUN_83_UNT - CP_MAN_TOTAL_JUN_83_UNT;
      CP_TOTAL_JUN_83_TAX := CP_TOTAL_JUN_83_TAX - CP_MAN_TOTAL_JUN_83_TAX;
      CP_TOTAL_JUN_94_INV := CP_TOTAL_JUN_94_INV - CP_MAN_TOTAL_JUN_94_INV;
      CP_TOTAL_GROSS_ETP := CP_TOTAL_GROSS_ETP - CP_MAN_TOTAL_GROSS_ETP;
      CP_TOTAL_ETP_TID := CP_TOTAL_ETP_TID - CP_MAN_TOTAL_ETP_TID;
      CP_TOTAL_ASSESSABLE_INCOME := CP_TOTAL_ASSESSABLE_INCOME - CP_MAN_TOTAL_ASSESSABLE_INCOME;
      CP_TOTAL_WORKPLACE := CP_TOTAL_WORKPLACE - CP_MAN_TOTAL_WORKPLACE;
    END IF;
    RETURN (1);
  END CF_CALC_GROUP_TOTALSFORMULA;

  FUNCTION MANUAL_PS_ISSUED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN MANUAL_PS_ISSUED;
  END MANUAL_PS_ISSUED_P;

  FUNCTION CP_FIN_YR_START_P RETURN DATE IS
  BEGIN
    RETURN CP_FIN_YR_START;
  END CP_FIN_YR_START_P;

  FUNCTION CP_FIN_YR_END_P RETURN DATE IS
  BEGIN
    RETURN CP_FIN_YR_END;
  END CP_FIN_YR_END_P;

  FUNCTION CP_FBT_YR_START_P RETURN DATE IS
  BEGIN
    RETURN CP_FBT_YR_START;
  END CP_FBT_YR_START_P;

  FUNCTION CP_FBT_YR_END_P RETURN DATE IS
  BEGIN
    RETURN CP_FBT_YR_END;
  END CP_FBT_YR_END_P;

  FUNCTION CP_TOTAL_STANDARD_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_STANDARD;
  END CP_TOTAL_STANDARD_P;

  FUNCTION CP_TOTAL_ETP_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_ETP;
  END CP_TOTAL_ETP_P;

  FUNCTION CP_TOTAL_CURRENT_EMPLOYEES_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_CURRENT_EMPLOYEES;
  END CP_TOTAL_CURRENT_EMPLOYEES_P;

  --FUNCTION CP_TOTAL_TERMINATED_EMPLOYEES RETURN NUMBER IS
  FUNCTION CP_TOTAL_TERMINATED_EMPLOY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_TERMINATED_EMPLOYEES;
  END CP_TOTAL_TERMINATED_EMPLOY_P;

  FUNCTION CP_TOTAL_GROSS_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_GROSS;
  END CP_TOTAL_GROSS_P;

  FUNCTION CP_TOTAL_RFB_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_RFB;
  END CP_TOTAL_RFB_P;

  FUNCTION CP_TOTAL_LUMPSUM_A_PAY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_LUMPSUM_A_PAY;
  END CP_TOTAL_LUMPSUM_A_PAY_P;

  FUNCTION CP_TOTAL_LUMPSUM_B_PAY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_LUMPSUM_B_PAY;
  END CP_TOTAL_LUMPSUM_B_PAY_P;

  FUNCTION CP_TOTAL_LUMPSUM_D_PAY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_LUMPSUM_D_PAY;
  END CP_TOTAL_LUMPSUM_D_PAY_P;

  FUNCTION CP_TOTAL_LUMPSUM_E_PAY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_LUMPSUM_E_PAY;
  END CP_TOTAL_LUMPSUM_E_PAY_P;

  FUNCTION CP_TOTAL_UNION_FEES_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_UNION_FEES;
  END CP_TOTAL_UNION_FEES_P;

  FUNCTION CP_TOTAL_TID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_TID;
  END CP_TOTAL_TID_P;

  FUNCTION CP_TOTAL_OTHER_INCOME_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_OTHER_INCOME;
  END CP_TOTAL_OTHER_INCOME_P;

  FUNCTION CP_TOTAL_PRE_JUL_83_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_PRE_JUL_83;
  END CP_TOTAL_PRE_JUL_83_P;

  FUNCTION CP_TOTAL_JUN_83_UNT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_JUN_83_UNT;
  END CP_TOTAL_JUN_83_UNT_P;

  FUNCTION CP_TOTAL_JUN_83_TAX_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_JUN_83_TAX;
  END CP_TOTAL_JUN_83_TAX_P;

  FUNCTION CP_TOTAL_JUN_94_INV_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_JUN_94_INV;
  END CP_TOTAL_JUN_94_INV_P;

  FUNCTION CP_TOTAL_GROSS_ETP_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_GROSS_ETP;
  END CP_TOTAL_GROSS_ETP_P;

  FUNCTION CP_TOTAL_ETP_TID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_ETP_TID;
  END CP_TOTAL_ETP_TID_P;

  FUNCTION CP_TOTAL_ASSESSABLE_INCOME_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_ASSESSABLE_INCOME;
  END CP_TOTAL_ASSESSABLE_INCOME_P;

  FUNCTION CP_TOTAL_ALLOWANCES_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_ALLOWANCES;
  END CP_TOTAL_ALLOWANCES_P;

  FUNCTION CP_TOTAL_CDEP_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_CDEP;
  END CP_TOTAL_CDEP_P;

  FUNCTION CP_FINANCIAL_YEAR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FINANCIAL_YEAR;
  END CP_FINANCIAL_YEAR_P;

  FUNCTION CP_REG_EMP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REG_EMP;
  END CP_REG_EMP_P;

  FUNCTION CP_PAYROLL_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PAYROLL_NAME;
  END CP_PAYROLL_NAME_P;

  FUNCTION CP_EMP_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_EMP_TYPE;
  END CP_EMP_TYPE_P;

  FUNCTION CP_ASSIGNMENT_NUMBER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ASSIGNMENT_NUMBER;
  END CP_ASSIGNMENT_NUMBER_P;

  FUNCTION CP_FBT_GLOBAL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FBT_GLOBAL;
  END CP_FBT_GLOBAL_P;

  FUNCTION CP_ML_GLOBAL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ML_GLOBAL;
  END CP_ML_GLOBAL_P;

  FUNCTION CP_DIMENSION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DIMENSION;
  END CP_DIMENSION_P;

  FUNCTION CP_ASSGT_COUNTER_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ASSGT_COUNTER;
  END CP_ASSGT_COUNTER_P;

  FUNCTION CP_ASSGT_TOTAL_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ASSGT_TOTAL;
  END CP_ASSGT_TOTAL_P;

  FUNCTION CP_LST_YR_START_P RETURN DATE IS
  BEGIN
    RETURN CP_LST_YR_START;
  END CP_LST_YR_START_P;

  FUNCTION CP_LST_YR_TERM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LST_YR_TERM;
  END CP_LST_YR_TERM_P;

  FUNCTION CP_TOTAL_WORKPLACE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOTAL_WORKPLACE;
  END CP_TOTAL_WORKPLACE_P;

  FUNCTION CP_MAN_TOTAL_STANDARD_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_STANDARD;
  END CP_MAN_TOTAL_STANDARD_P;

  FUNCTION CP_MAN_TOTAL_ETP_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_ETP;
  END CP_MAN_TOTAL_ETP_P;

  FUNCTION CP_MAN_TOTAL_CURR_EMPLOYEES_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_CURR_EMPLOYEES;
  END CP_MAN_TOTAL_CURR_EMPLOYEES_P;

  FUNCTION CP_MAN_TOTAL_TERM_EMPLOYEES_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_TERM_EMPLOYEES;
  END CP_MAN_TOTAL_TERM_EMPLOYEES_P;

  FUNCTION CP_MAN_TOTAL_GROSS_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_GROSS;
  END CP_MAN_TOTAL_GROSS_P;

  FUNCTION CP_MAN_TOTAL_RFB_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_RFB;
  END CP_MAN_TOTAL_RFB_P;

  FUNCTION CP_MAN_TOTAL_LUMPSUM_A_PAY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_LUMPSUM_A_PAY;
  END CP_MAN_TOTAL_LUMPSUM_A_PAY_P;

  FUNCTION CP_MAN_TOTAL_LUMPSUM_B_PAY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_LUMPSUM_B_PAY;
  END CP_MAN_TOTAL_LUMPSUM_B_PAY_P;

  FUNCTION CP_MAN_TOTAL_LUMPSUM_D_PAY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_LUMPSUM_D_PAY;
  END CP_MAN_TOTAL_LUMPSUM_D_PAY_P;

  FUNCTION CP_MAN_TOTAL_LUMPSUM_E_PAY_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_LUMPSUM_E_PAY;
  END CP_MAN_TOTAL_LUMPSUM_E_PAY_P;

  FUNCTION CP_MAN_TOTAL_UNION_FEES_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_UNION_FEES;
  END CP_MAN_TOTAL_UNION_FEES_P;

  FUNCTION CP_MAN_TOTAL_TID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_TID;
  END CP_MAN_TOTAL_TID_P;

  FUNCTION CP_MAN_TOTAL_OTHER_INCOME_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_OTHER_INCOME;
  END CP_MAN_TOTAL_OTHER_INCOME_P;

  FUNCTION CP_MAN_TOTAL_PRE_JUL_83_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_PRE_JUL_83;
  END CP_MAN_TOTAL_PRE_JUL_83_P;

  FUNCTION CP_MAN_TOTAL_JUN_83_UNT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_JUN_83_UNT;
  END CP_MAN_TOTAL_JUN_83_UNT_P;

  FUNCTION CP_MAN_TOTAL_JUN_83_TAX_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_JUN_83_TAX;
  END CP_MAN_TOTAL_JUN_83_TAX_P;

  FUNCTION CP_MAN_TOTAL_JUN_94_INV_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_JUN_94_INV;
  END CP_MAN_TOTAL_JUN_94_INV_P;

  FUNCTION CP_MAN_TOTAL_GROSS_ETP_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_GROSS_ETP;
  END CP_MAN_TOTAL_GROSS_ETP_P;

  FUNCTION CP_MAN_TOTAL_ETP_TID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_ETP_TID;
  END CP_MAN_TOTAL_ETP_TID_P;

  FUNCTION CP_MAN_TOTAL_ASSESSABLE_INCOM RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_ASSESSABLE_INCOME;
  END CP_MAN_TOTAL_ASSESSABLE_INCOM;

  FUNCTION CP_MAN_TOTAL_ALLOWANCES_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_ALLOWANCES;
  END CP_MAN_TOTAL_ALLOWANCES_P;

  FUNCTION CP_MAN_TOTAL_CDEP_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_CDEP;
  END CP_MAN_TOTAL_CDEP_P;

  FUNCTION CP_MAN_TOTAL_WORKPLACE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_MAN_TOTAL_WORKPLACE;
  END CP_MAN_TOTAL_WORKPLACE_P;

END PAY_PYAURECP_XMLP_PKG;

/
