--------------------------------------------------------
--  DDL for Package Body JA_JAINABST_EXC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINABST_EXC_XMLP_PKG" AS
/* $Header: JAINABSTB.pls 120.1 2007/12/25 16:10:06 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_PROGRAM_ID(P_REQUEST_ID IN NUMBER) IS
      SELECT
        CONCURRENT_PROGRAM_ID,
        NVL(ENABLE_TRACE
           ,'N')
      FROM
        FND_CONCURRENT_REQUESTS
      WHERE REQUEST_ID = P_REQUEST_ID;
    V_ENABLE_TRACE FND_CONCURRENT_PROGRAMS.ENABLE_TRACE%TYPE;
    V_PROGRAM_ID FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID%TYPE;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    CP_TRN_FROM_DATE := TO_CHAR(P_TRN_FROM_DATE,'DD-MON-RRRR');
    CP_TRN_TO_DATE := TO_CHAR(P_TRN_TO_DATE,'DD-MON-RRRR');
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.MESSAGE(1275
               ,'Report Version is 120.2 Last modified date is 25/07/2005')*/NULL;
    BEGIN
      OPEN C_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH C_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE C_PROGRAM_ID;
      /*SRW.MESSAGE(1275
                 ,'v_program_id -> ' || V_PROGRAM_ID || ', v_enable_trace -> ' || V_ENABLE_TRACE || ', request_id -> ' || P_CONC_REQUEST_ID)*/NULL;
      IF V_ENABLE_TRACE = 'Y' THEN
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1275
                   ,'Error during enabling the trace. ErrCode -> ' || SQLCODE || ', ErrMesg -> ' || SQLERRM)*/NULL;
    END;
    FOR ORG_REC IN (SELECT
                      ORGANIZATION_NAME
                    FROM
                      ORG_ORGANIZATION_DEFINITIONS
                    WHERE ORGANIZATION_ID = nvl(P_ORGANIZATION_ID,207)) LOOP
      P_ORGANIZATION_NAME := ORG_REC.ORGANIZATION_NAME;
    END LOOP;
    FOR EC_REC IN (SELECT
                     EC_CODE,
                     EXCISE_DUTY_COMM,
                     EXCISE_DUTY_RANGE,
                     EXCISE_DUTY_DIVISION,
                     EXCISE_DUTY_CIRCLE
                   FROM
                     JAI_CMN_INVENTORY_ORGS
                   WHERE ORGANIZATION_ID = nvl(P_ORGANIZATION_ID,207)
                     AND LOCATION_ID = nvl(P_LOCATION_ID,207)) LOOP
      P_EC_CODE := (EC_REC.EC_CODE);
      P_COLLECT := (EC_REC.EXCISE_DUTY_COMM);
      P_RANGE := (EC_REC.EXCISE_DUTY_RANGE);
      P_DIVISION := (EC_REC.EXCISE_DUTY_DIVISION);
      P_CIRCLE := (EC_REC.EXCISE_DUTY_CIRCLE);
    END LOOP;
    FOR LOC_REC IN (SELECT
                      DESCRIPTION,
                      ADDRESS_LINE_1,
                      ADDRESS_LINE_2,
                      ADDRESS_LINE_3
                    FROM
                      HR_LOCATIONS
                    WHERE LOCATION_ID = nvl(P_LOCATION_ID,207)) LOOP
      P_DESCRIPTION := LOC_REC.DESCRIPTION;
      P_ADDRESS_LINE_1 := LOC_REC.ADDRESS_LINE_1;
      P_ADDRESS_LINE_2 := LOC_REC.ADDRESS_LINE_2;
      P_ADDRESS_LINE_3 := LOC_REC.ADDRESS_LINE_3;
    END LOOP;
    FOR SLNO_REC IN (SELECT
                       MIN(REGISTER_ID) LO
                     FROM
                       JAI_CMN_RG_COMP_DTLS
                     WHERE ORGANIZATION_ID = nvl(P_ORGANIZATION_ID,207)
                       AND LOCATION_ID = nvl(P_LOCATION_ID,207)
                       AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                        ,TRUNC(TRANSACTION_DATE))
                       AND NVL(TRUNC(P_TRN_TO_DATE)
                        ,TRUNC(TRANSACTION_DATE))
                       AND REGISTER_TYPE = P_REGISTER_TYPE) LOOP
      FOR VAL_REC IN (SELECT
                        BASIC_OPENING_BALANCE BASICOB,
                        ADDITIONAL_OPENING_BALANCE ADLOB,
                        OTHER_OPENING_BALANCE OTHOB
                      FROM
                        JAI_CMN_RG_COMP_DTLS
                      WHERE REGISTER_ID = SLNO_REC.LO) LOOP
        P_CENOB := NVL(VAL_REC.BASICOB
                      ,0);
        P_ADLOB := NVL(VAL_REC.ADLOB
                      ,0);
        P_SEDOB := NVL(VAL_REC.OTHOB
                      ,0);
      END LOOP;
    END LOOP;
    P_CENOB := ROUND(NVL(P_CENOB
                        ,0)
                    ,2);
    P_ADLOB := ROUND(NVL(P_ADLOB
                        ,0)
                    ,2);
    P_SEDOB := ROUND(NVL(P_SEDOB
                        ,0)
                    ,2);
    FOR CR_REC IN (SELECT
                     NVL(SUM(CR_BASIC_ED)
                        ,0) CENCT,
                     NVL(SUM(CR_OTHER_ED)
                        ,0) SEDCT,
                     NVL(SUM(CR_ADDITIONAL_ED)
                        ,0) ADLCT
                   FROM
                     JAI_CMN_RG_COMP_DTLS
                   WHERE ORGANIZATION_ID = nvl(P_ORGANIZATION_ID,207)
                     AND LOCATION_ID = nvl(P_LOCATION_ID,207)
                     AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND NVL(TRUNC(P_TRN_TO_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND REGISTER_TYPE = P_REGISTER_TYPE) LOOP
      P_CENCT := ROUND(NVL(CR_REC.CENCT
                          ,0)
                      ,2);
      P_SEDCT := ROUND(NVL(CR_REC.SEDCT
                          ,0)
                      ,2);
      P_ADLCT := ROUND(NVL(CR_REC.ADLCT
                          ,0)
                      ,2);
    END LOOP;
    FOR DR_REC IN (SELECT
                     NVL(SUM(DR_BASIC_ED)
                        ,0) CENCU,
                     NVL(SUM(DR_OTHER_ED)
                        ,0) SEDCU,
                     NVL(SUM(DR_ADDITIONAL_ED)
                        ,0) ADLCU
                   FROM
                     JAI_CMN_RG_COMP_DTLS
                   WHERE ORGANIZATION_ID = nvl(P_ORGANIZATION_ID,207)
                     AND LOCATION_ID = nvl(P_LOCATION_ID,207)
                     AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND NVL(TRUNC(P_TRN_TO_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND REGISTER_TYPE = P_REGISTER_TYPE) LOOP
      P_CENCU := ROUND(NVL(DR_REC.CENCU
                          ,0)
                      ,2);
      P_SEDCU := ROUND(NVL(DR_REC.SEDCU
                          ,0)
                      ,2);
      P_ADLCU := ROUND(NVL(DR_REC.ADLCU
                          ,0)
                      ,2);
    END LOOP;
    P_CENCB := NVL(P_CENOB
                  ,0) + NVL(P_CENCT
                  ,0) - NVL(P_CENCU
                  ,0);
    P_SEDCB := NVL(P_SEDOB
                  ,0) + NVL(P_SEDCT
                  ,0) - NVL(P_SEDCU
                  ,0);
    P_ADLCB := NVL(P_ADLOB
                  ,0) + NVL(P_ADLCT
                  ,0) - NVL(P_ADLCU
                  ,0);
    P_TOTOB := NVL(P_CENOB
                  ,0) + NVL(P_ADLOB
                  ,0) + NVL(P_SEDOB
                  ,0);
    P_TOTCT := NVL(P_CENCT
                  ,0) + NVL(P_SEDCT
                  ,0) + NVL(P_ADLCT
                  ,0);
    P_TOTCU := NVL(P_CENCU
                  ,0) + NVL(P_SEDCU
                  ,0) + NVL(P_ADLCU
                  ,0);
    P_TOTCB := NVL(P_CENCB
                  ,0) + NVL(P_SEDCB
                  ,0) + NVL(P_ADLCB
                  ,0);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END JA_JAINABST_EXC_XMLP_PKG;


/
