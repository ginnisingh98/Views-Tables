--------------------------------------------------------
--  DDL for Package Body FA_FASRVPVW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASRVPVW_XMLP_PKG" AS
/* $Header: FASRVPVWB.pls 120.0.12010000.1 2008/07/28 13:17:37 appldev ship $ */
  USER_EXIT_FAILURE EXCEPTION;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_MAX_ASSET_ID NUMBER;
    L_SUCCESS_COUNT NUMBER;
    L_FAILURE_COUNT NUMBER;
    L_RETURN_STATUS NUMBER;
    L_BOOK VARCHAR2(15);
    REVAL_ERR EXCEPTION;
    L_REQUEST_ID NUMBER;
    L_RESULT BOOLEAN;
    L_PHASE VARCHAR2(500) := NULL;
    L_STATUS VARCHAR2(500) := NULL;
    L_DEVPHASE VARCHAR2(500) := 'PENDING';
    L_DEVSTATUS VARCHAR2(500) := NULL;
    L_MESSAGE VARCHAR2(500) := NULL;
    DUMMY_DEFAULT BOOLEAN := FALSE;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    select  SUBSTR(ARGUMENT1,INSTR(ARGUMENT1,'=',1,1)+1) into P_MASS_REVAL_ID1
FROM FND_CONCURRENT_REQUESTS
WHERE REQUEST_ID =P_CONC_REQUEST_ID;
  RP_MASS_REVAL_ID := P_MASS_REVAL_ID1;
    SELECT
      BOOK_TYPE_CODE
    INTO L_BOOK
    FROM
      FA_MASS_REVALUATIONS
    WHERE MASS_REVAL_ID = P_MASS_REVAL_ID1;
    IF (NOT FA_CACHE_PKG.FAZCBC(L_BOOK)) THEN
      RAISE REVAL_ERR;
    END IF;
    FA_SRVR_MSG.INIT_SERVER_MESSAGE;
    FA_DEBUG_PKG.INITIALIZE;
    L_MAX_ASSET_ID := 0;
    L_REQUEST_ID := FND_REQUEST.SUBMIT_REQUEST('OFA'
                                              ,'FAVRVL'
                                              ,''
                                              ,''
                                              ,DUMMY_DEFAULT
                                              ,P_MASS_REVAL_ID1
                                              ,'PREVIEW'
                                              ,CHR(0)
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,''
                                              ,'');
    COMMIT;
    IF (L_REQUEST_ID = 0) THEN
      RAISE REVAL_ERR;
    END IF;
    FOR i IN 1 .. 10 LOOP
      L_RESULT := FND_CONCURRENT.WAIT_FOR_REQUEST(REQUEST_ID => L_REQUEST_ID
                                                 ,INTERVAL => 30
                                                 ,MAX_WAIT => 32000
                                                 ,PHASE => L_PHASE
                                                 ,STATUS => L_STATUS
                                                 ,DEV_PHASE => L_DEVPHASE
                                                 ,DEV_STATUS => L_DEVSTATUS
                                                 ,MESSAGE => L_MESSAGE);
      IF (NVL(L_DEVPHASE = 'COMPLETE' AND L_DEVSTATUS = 'NORMAL'
         ,FALSE)) THEN
        EXIT;
      ELSE
        IF (I = 10) THEN
          RAISE REVAL_ERR;
        END IF;
      END IF;
    END LOOP;
    P_CONC_REQUEST2_ID := L_REQUEST_ID;
    RETURN (TRUE);
  EXCEPTION
    WHEN REVAL_ERR THEN
      RETURN FALSE;
    WHEN OTHERS THEN
      RETURN FALSE;
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    UPDATE
      FA_MASS_REVALUATIONS
    SET
      STATUS = 'PREVIEWED'
    WHERE MASS_REVAL_ID = P_MASS_REVAL_ID1;
    DELETE FROM FA_MASS_REVAL_REP_ITF
     WHERE MASS_REVAL_ID = P_MASS_REVAL_ID1
       AND REQUEST_ID = P_CONC_REQUEST_ID;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION D_REVAL_PCTFORMULA(D_REVAL_PCT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      H_MSG_BUFFER VARCHAR2(2000);
    BEGIN
      RETURN (D_REVAL_PCT);
    EXCEPTION
      WHEN USER_EXIT_FAILURE THEN
        /*H_MSG_BUFFER := NVL(SRW.GETERR_RUN
                           ,'d_reval_pctformula');*/
			   H_MSG_BUFFER := 'd_reval_pctformula';
        RETURN (D_REVAL_PCT);
      WHEN OTHERS THEN
        RETURN (D_REVAL_PCT);
    END;
  END D_REVAL_PCTFORMULA;
  FUNCTION REPORT_NAMEFORMULA(COMPANY IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(240);
    BEGIN
      RP_COMPANY := COMPANY;
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
       l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
         RP_REPORT_NAME := L_REPORT_NAME;
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN OTHERS THEN
        RP_REPORT_NAME := 'Mass Revaluation Preview Report';
        RETURN ('Mass Revaluation Preview Report');
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;
  FUNCTION BOOKFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_CURRENCY_CODE VARCHAR2(15);
      L_DESCRIPTION VARCHAR2(80);
      L_BOOK_TYPE_CODE VARCHAR2(15);
      L_DEFAULT_RFRF VARCHAR2(80);
      TEMP_DEFAULT_RFRF VARCHAR2(3);
      L_DEFAULT_LEF NUMBER;
      L_DEFAULT_LEC NUMBER;
      L_DEFAULT_MFRR NUMBER;
    BEGIN
      SELECT
        MR.DESCRIPTION,
        MR.BOOK_TYPE_CODE,
        MR.DEFAULT_REVAL_FULLY_RSVD_FLAG,
        MR.DEFAULT_LIFE_EXTENSION_FACTOR,
        MR.DEFAULT_LIFE_EXTENSION_CEILING,
        MR.DEFAULT_MAX_FULLY_RSVD_REVALS,
        SOB.CURRENCY_CODE
      INTO L_DESCRIPTION,L_BOOK_TYPE_CODE,TEMP_DEFAULT_RFRF,L_DEFAULT_LEF,L_DEFAULT_LEC,L_DEFAULT_MFRR,L_CURRENCY_CODE
      FROM
        FA_MASS_REVALUATIONS MR,
        FA_BOOK_CONTROLS BC,
        GL_SETS_OF_BOOKS SOB
      WHERE MR.MASS_REVAL_ID = P_MASS_REVAL_ID1
        AND MR.BOOK_TYPE_CODE = BC.BOOK_TYPE_CODE
        AND BC.DATE_INEFFECTIVE is null
        AND SOB.SET_OF_BOOKS_ID = BC.SET_OF_BOOKS_ID;
      SELECT
        MEANING
      INTO L_DEFAULT_RFRF
      FROM
        FA_LOOKUPS
      WHERE LOOKUP_TYPE = 'YESNO'
        AND LOOKUP_CODE = NVL(TEMP_DEFAULT_RFRF
         ,'NO');
      CURRENCY_CODE := L_CURRENCY_CODE;
      REVAL_DESCRIPTION := L_DESCRIPTION;
      DEF_RFRF := L_DEFAULT_RFRF;
      DEF_LEF := L_DEFAULT_LEF;
      DEF_LEC := L_DEFAULT_LEC;
      DEF_MFRR := L_DEFAULT_MFRR;
      RETURN (L_BOOK_TYPE_CODE);
    END;
    RETURN NULL;
  END BOOKFORMULA;
  FUNCTION LIFE_INDFORMULA(LIFE_IND IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (LIFE_IND);
  END LIFE_INDFORMULA;
  FUNCTION D_ASS_REVAL_PCTFORMULA(REVAL_PCT IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      RETURN (REVAL_PCT);
    END;
    RETURN NULL;
  END D_ASS_REVAL_PCTFORMULA;
  FUNCTION D_ASS_FOUNDFORMULA(D_ASS_FOUND IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (D_ASS_FOUND);
  END D_ASS_FOUNDFORMULA;
  FUNCTION D_LIFEFORMULA(LIFE_IN_MONTHS IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF LIFE_IN_MONTHS IS NOT NULL THEN
      RETURN ((LPAD(TO_CHAR(TRUNC(LIFE_IN_MONTHS / 12
                               ,0)
                         ,'90')
                 ,3
                 ,' ') || '.' || SUBSTR(TO_CHAR(MOD(LIFE_IN_MONTHS
                               ,12)
                           ,'00')
                   ,2
                   ,2)));
    ELSE
      RETURN (NULL);
    END IF;
    RETURN NULL;
  END D_LIFEFORMULA;
  FUNCTION D_NEW_LIFEFORMULA(NEW_LIFE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF (NEW_LIFE <> 0) THEN
      RETURN ((LPAD(TO_CHAR(TRUNC(NEW_LIFE / 12
                               ,0)
                         ,'90')
                 ,3
                 ,' ') || '.' || SUBSTR(TO_CHAR(MOD(NEW_LIFE
                               ,12)
                           ,'00')
                   ,2
                   ,2)));
    ELSE
      RETURN (NULL);
    END IF;
    RETURN NULL;
  END D_NEW_LIFEFORMULA;
  FUNCTION D_LIFE_INDFORMULA(LIFE_IND IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF (LIFE_IND IS NULL) THEN
      RETURN (NULL);
    ELSE
      RETURN ('*');
    END IF;
    RETURN NULL;
  END D_LIFE_INDFORMULA;
  FUNCTION D_ASS_FRRFFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (D_ASS_FRRF);
  END D_ASS_FRRFFORMULA;
  FUNCTION D_ASS_MFRRFORMULA(D_ASS_MFRR IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF (D_ASS_MFRR = '0') THEN
      RETURN (NULL);
    ELSE
      RETURN (D_ASS_MFRR);
    END IF;
    RETURN NULL;
  END D_ASS_MFRRFORMULA;
  FUNCTION D_MFRRFORMULA(D_MFRR IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF (D_MFRR = '0') THEN
      RETURN (NULL);
    ELSE
      RETURN (D_MFRR);
    END IF;
    RETURN NULL;
  END D_MFRRFORMULA;
  FUNCTION D_FOUNDFORMULA(D_FOUND IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (D_FOUND);
  END D_FOUNDFORMULA;
  FUNCTION D_FRRFFORMULA(REVAL_FULLY_RSVD IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (REVAL_FULLY_RSVD);
  END D_FRRFFORMULA;
  FUNCTION D_LEFFORMULA(D_LEF IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (D_LEF);
  END D_LEFFORMULA;
  FUNCTION D_LECFORMULA(D_LEC IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (D_LEC);
  END D_LECFORMULA;
  FUNCTION D_ASS_FRRF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN D_ASS_FRRF;
  END D_ASS_FRRF_P;
  FUNCTION REVAL_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN REVAL_DESCRIPTION;
  END REVAL_DESCRIPTION_P;
  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURRENCY_CODE;
  END CURRENCY_CODE_P;
  FUNCTION DEF_RFRF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DEF_RFRF;
  END DEF_RFRF_P;
  FUNCTION DEF_LEC_P RETURN NUMBER IS
  BEGIN
    RETURN DEF_LEC;
  END DEF_LEC_P;
  FUNCTION DEF_MFRR_P RETURN NUMBER IS
  BEGIN
    RETURN DEF_MFRR;
  END DEF_MFRR_P;
  FUNCTION DEF_LEF_P RETURN NUMBER IS
  BEGIN
    RETURN DEF_LEF;
  END DEF_LEF_P;
  FUNCTION RP_COMPANY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY;
  END RP_COMPANY_P;
  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;
  FUNCTION RP_REPORT_EXEC_DATE_P RETURN DATE IS
  BEGIN
    RETURN RP_REPORT_EXEC_DATE;
  END RP_REPORT_EXEC_DATE_P;
  FUNCTION RP_MASS_REVAL_ID_P RETURN NUMBER IS
  BEGIN
    RETURN RP_MASS_REVAL_ID;
  END RP_MASS_REVAL_ID_P;
END FA_FASRVPVW_XMLP_PKG;


/
