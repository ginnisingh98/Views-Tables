--------------------------------------------------------
--  DDL for Package Body JA_JAINEXCLIABILITY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINEXCLIABILITY_XMLP_PKG" AS
/* $Header: JAINEXCLIABILITYB.pls 120.1 2007/12/25 16:18:32 dwkrishn noship $ */
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
    /*SRW.MESSAGE(1275
               ,'Report Version is 120.2 Last modified date is 25/07/2005')*/NULL;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
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
                    WHERE ORGANIZATION_ID = P_ORGANIZATION_ID) LOOP
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
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                     AND LOCATION_ID = P_LOCATION_ID) LOOP
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
                    WHERE LOCATION_ID = P_LOCATION_ID) LOOP
      P_DESCRIPTION := LOC_REC.DESCRIPTION;
      P_ADDRESS_LINE_1 := LOC_REC.ADDRESS_LINE_1;
      P_ADDRESS_LINE_2 := LOC_REC.ADDRESS_LINE_2;
      P_ADDRESS_LINE_3 := LOC_REC.ADDRESS_LINE_3;
    END LOOP;
    FOR SLNO_REC IN (SELECT
                       MIN(REGISTER_ID) LO
                     FROM
                       JAI_CMN_RG_COMP_DTLS
                     WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                       AND LOCATION_ID = P_LOCATION_ID
                       AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                        ,TRUNC(TRANSACTION_DATE))
                       AND NVL(TRUNC(P_TRN_TO_DATE)
                        ,TRUNC(TRANSACTION_DATE))
                       AND REGISTER_TYPE = 'A') LOOP
      FOR VAL_REC IN (SELECT
                        BASIC_OPENING_BALANCE BASICOB,
                        ADDITIONAL_OPENING_BALANCE ADLOB,
                        OTHER_OPENING_BALANCE OTHOB
                      FROM
                        JAI_CMN_RG_COMP_DTLS
                      WHERE REGISTER_ID = SLNO_REC.LO) LOOP
        P_CENOBRG23A := NVL(VAL_REC.BASICOB
                           ,0);
        P_ADLOBRG23A := NVL(VAL_REC.ADLOB
                           ,0);
        P_SEDOBRG23A := NVL(VAL_REC.OTHOB
                           ,0);
      END LOOP;
    END LOOP;
    P_CENOBRG23A := ROUND(NVL(P_CENOBRG23A
                             ,0)
                         ,2);
    P_ADLOBRG23A := ROUND(NVL(P_ADLOBRG23A
                             ,0)
                         ,2);
    P_SEDOBRG23A := ROUND(NVL(P_SEDOBRG23A
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
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                     AND LOCATION_ID = P_LOCATION_ID
                     AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND NVL(TRUNC(P_TRN_TO_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND REGISTER_TYPE = 'A') LOOP
      P_CENCTRG23A := ROUND(NVL(CR_REC.CENCT
                               ,0)
                           ,2);
      P_SEDCTRG23A := ROUND(NVL(CR_REC.SEDCT
                               ,0)
                           ,2);
      P_ADLCTRG23A := ROUND(NVL(CR_REC.ADLCT
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
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                     AND LOCATION_ID = P_LOCATION_ID
                     AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND NVL(TRUNC(P_TRN_TO_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND REGISTER_TYPE = 'A') LOOP
      P_CENCURG23A := ROUND(NVL(DR_REC.CENCU
                               ,0)
                           ,2);
      P_SEDCURG23A := ROUND(NVL(DR_REC.SEDCU
                               ,0)
                           ,2);
      P_ADLCURG23A := ROUND(NVL(DR_REC.ADLCU
                               ,0)
                           ,2);
    END LOOP;
    P_CENCBRG23A := NVL(P_CENOBRG23A
                       ,0) + NVL(P_CENCTRG23A
                       ,0) - NVL(P_CENCURG23A
                       ,0);
    P_SEDCBRG23A := NVL(P_SEDOBRG23A
                       ,0) + NVL(P_SEDCTRG23A
                       ,0) - NVL(P_SEDCURG23A
                       ,0);
    P_ADLCBRG23A := NVL(P_ADLOBRG23A
                       ,0) + NVL(P_ADLCTRG23A
                       ,0) - NVL(P_ADLCURG23A
                       ,0);
    FOR SLNO_REC IN (SELECT
                       MIN(REGISTER_ID) LO
                     FROM
                       JAI_CMN_RG_COMP_DTLS
                     WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                       AND LOCATION_ID = P_LOCATION_ID
                       AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                        ,TRUNC(TRANSACTION_DATE))
                       AND NVL(TRUNC(P_TRN_TO_DATE)
                        ,TRUNC(TRANSACTION_DATE))
                       AND REGISTER_TYPE = 'C') LOOP
      FOR VAL_REC IN (SELECT
                        BASIC_OPENING_BALANCE BASICOB,
                        ADDITIONAL_OPENING_BALANCE ADLOB,
                        OTHER_OPENING_BALANCE OTHOB
                      FROM
                        JAI_CMN_RG_COMP_DTLS
                      WHERE REGISTER_ID = SLNO_REC.LO) LOOP
        P_CENOBRG23C := NVL(VAL_REC.BASICOB
                           ,0);
        P_ADLOBRG23C := NVL(VAL_REC.ADLOB
                           ,0);
        P_SEDOBRG23C := NVL(VAL_REC.OTHOB
                           ,0);
      END LOOP;
    END LOOP;
    P_CENOBRG23C := ROUND(NVL(P_CENOBRG23C
                             ,0)
                         ,2);
    P_ADLOBRG23C := ROUND(NVL(P_ADLOBRG23C
                             ,0)
                         ,2);
    P_SEDOBRG23C := ROUND(NVL(P_SEDOBRG23C
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
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                     AND LOCATION_ID = P_LOCATION_ID
                     AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND NVL(TRUNC(P_TRN_TO_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND REGISTER_TYPE = 'C') LOOP
      P_CENCTRG23C := ROUND(NVL(CR_REC.CENCT
                               ,0)
                           ,2);
      P_SEDCTRG23C := ROUND(NVL(CR_REC.SEDCT
                               ,0)
                           ,2);
      P_ADLCTRG23C := ROUND(NVL(CR_REC.ADLCT
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
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                     AND LOCATION_ID = P_LOCATION_ID
                     AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND NVL(TRUNC(P_TRN_TO_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND REGISTER_TYPE = 'C') LOOP
      P_CENCURG23C := ROUND(NVL(DR_REC.CENCU
                               ,0)
                           ,2);
      P_SEDCURG23C := ROUND(NVL(DR_REC.SEDCU
                               ,0)
                           ,2);
      P_ADLCURG23C := ROUND(NVL(DR_REC.ADLCU
                               ,0)
                           ,2);
    END LOOP;
    P_CENCBRG23C := NVL(P_CENOBRG23C
                       ,0) + NVL(P_CENCTRG23C
                       ,0) - NVL(P_CENCURG23C
                       ,0);
    P_SEDCBRG23C := NVL(P_SEDOBRG23C
                       ,0) + NVL(P_SEDCTRG23C
                       ,0) - NVL(P_SEDCURG23C
                       ,0);
    P_ADLCBRG23C := NVL(P_ADLOBRG23C
                       ,0) + NVL(P_ADLCTRG23C
                       ,0) - NVL(P_ADLCURG23C
                       ,0);
    FOR SLNO_REC IN (SELECT
                       MIN(REGISTER_ID) LO
                     FROM
                       JAI_CMN_RG_PLA_CMP_DTLS
                     WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                       AND LOCATION_ID = P_LOCATION_ID
                       AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                        ,TRUNC(TRANSACTION_DATE))
                       AND NVL(TRUNC(P_TRN_TO_DATE)
                        ,TRUNC(TRANSACTION_DATE))) LOOP
      FOR VAL_REC IN (SELECT
                        BASIC_OPENING_BALANCE BASICOB,
                        ADDITIONAL_OPENING_BALANCE ADLOB,
                        OTHER_OPENING_BALANCE OTHOB
                      FROM
                        JAI_CMN_RG_PLA_CMP_DTLS
                      WHERE REGISTER_ID = SLNO_REC.LO) LOOP
        P_CENOBPLA := NVL(VAL_REC.BASICOB
                         ,0);
        P_ADLOBPLA := NVL(VAL_REC.ADLOB
                         ,0);
        P_SEDOBPLA := NVL(VAL_REC.OTHOB
                         ,0);
      END LOOP;
    END LOOP;
    P_CENOBPLA := ROUND(NVL(P_CENOBPLA
                           ,0)
                       ,2);
    P_ADLOBPLA := ROUND(NVL(P_ADLOBPLA
                           ,0)
                       ,2);
    P_SEDOBPLA := ROUND(NVL(P_SEDOBPLA
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
                     JAI_CMN_RG_PLA_CMP_DTLS
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                     AND LOCATION_ID = P_LOCATION_ID
                     AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND NVL(TRUNC(P_TRN_TO_DATE)
                      ,TRUNC(TRANSACTION_DATE))) LOOP
      P_CENCTPLA := ROUND(NVL(CR_REC.CENCT
                             ,0)
                         ,2);
      P_SEDCTPLA := ROUND(NVL(CR_REC.SEDCT
                             ,0)
                         ,2);
      P_ADLCTPLA := ROUND(NVL(CR_REC.ADLCT
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
                     JAI_CMN_RG_PLA_CMP_DTLS
                   WHERE ORGANIZATION_ID = P_ORGANIZATION_ID
                     AND LOCATION_ID = P_LOCATION_ID
                     AND TRUNC(TRANSACTION_DATE) BETWEEN NVL(TRUNC(P_TRN_FROM_DATE)
                      ,TRUNC(TRANSACTION_DATE))
                     AND NVL(TRUNC(P_TRN_TO_DATE)
                      ,TRUNC(TRANSACTION_DATE))) LOOP
      P_CENCUPLA := ROUND(NVL(DR_REC.CENCU
                             ,0)
                         ,2);
      P_SEDCUPLA := ROUND(NVL(DR_REC.SEDCU
                             ,0)
                         ,2);
      P_ADLCUPLA := ROUND(NVL(DR_REC.ADLCU
                             ,0)
                         ,2);
    END LOOP;
    P_CENCBPLA := NVL(P_CENOBPLA
                     ,0) + NVL(P_CENCTPLA
                     ,0) - NVL(P_CENCUPLA
                     ,0);
    P_SEDCBPLA := NVL(P_SEDOBPLA
                     ,0) + NVL(P_SEDCTPLA
                     ,0) - NVL(P_SEDCUPLA
                     ,0);
    P_ADLCBPLA := NVL(P_ADLOBPLA
                     ,0) + NVL(P_ADLCTPLA
                     ,0) - NVL(P_ADLCUPLA
                     ,0);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END JA_JAINEXCLIABILITY_XMLP_PKG;


/
