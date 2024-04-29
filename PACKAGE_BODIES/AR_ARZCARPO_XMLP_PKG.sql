--------------------------------------------------------
--  DDL for Package Body AR_ARZCARPO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARZCARPO_XMLP_PKG" AS
/* $Header: ARZCARPOB.pls 120.0 2007/12/27 14:13:47 abraghun noship $ */
  FUNCTION REPORT_NAMEFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_PROCESS_TYPE = 'RECEIPT' THEN
      RP_REPORT_NAME := 'Automatic Receipts Execution Report';
    ELSE
      RP_REPORT_NAME := 'Automatic Remittances Execution Report';
    END IF;
    RETURN (RP_REPORT_NAME);
  END REPORT_NAMEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
	 SELECT SUBSTR(ARGUMENT1,INSTR(ARGUMENT1,'=')+1,LENGTH(ARGUMENT1)),
	SUBSTR(ARGUMENT2,INSTR(ARGUMENT2,'=')+1,LENGTH(ARGUMENT2)),
	SUBSTR(ARGUMENT3,INSTR(ARGUMENT3,'=')+1,LENGTH(ARGUMENT3)),
	SUBSTR(ARGUMENT4,INSTR(ARGUMENT4,'=')+1,LENGTH(ARGUMENT4)),
	SUBSTR(ARGUMENT5,INSTR(ARGUMENT5,'=')+1,LENGTH(ARGUMENT5)),
	SUBSTR(ARGUMENT6,INSTR(ARGUMENT6,'=')+1,LENGTH(ARGUMENT6))
	INTO P_PROCESS_TYPE,P_BATCH_ID,P_CREATE_FLAG,P_APPROVE_FLAG,P_FORMAT_FLAG,P_REQUEST_ID_MAIN
	FROM FND_CONCURRENT_REQUESTS WHERE REQUEST_ID=P_CONC_REQUEST_ID;

      SELECT
        NAME
      INTO P_BATCH_NAME
      FROM
        AR_BATCHES
      WHERE BATCH_ID = P_BATCH_ID;
      IF P_CREATE_FLAG = 'Y' AND P_APPROVE_FLAG = 'N' AND P_FORMAT_FLAG = 'N' THEN
        P_CREATE_ONLY_FLAG := 'Y';
      ELSE
        P_CREATE_ONLY_FLAG := 'N';
      END IF;
      P_NO_DATA_FOUND := SUBSTR(ARP_STANDARD.FND_MESSAGE('AR_NO_DATA_FOUND'),1,13);
      RETURN (TRUE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_NO_DATA_FOUND := 'No Data Found';
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION SUB_TITLEFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_CREATE_FLAG = 'Y' THEN
        RP_SUB_TITLE := 'For Creation';
      END IF;
      IF P_APPROVE_FLAG = 'Y' THEN
        IF RP_SUB_TITLE IS NULL THEN
          RP_SUB_TITLE := 'For Approval';
        ELSE
          RP_SUB_TITLE := RP_SUB_TITLE || '/Approval';
        END IF;
      END IF;
      IF P_FORMAT_FLAG = 'Y' THEN
        IF RP_SUB_TITLE IS NULL THEN
          RP_SUB_TITLE := 'For Formatting';
        ELSE
          RP_SUB_TITLE := RP_SUB_TITLE || '/Formatting';
        END IF;
      END IF;
      RETURN (RP_SUB_TITLE);
    END;
    RETURN NULL;
  END SUB_TITLEFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_EXCEPTION_MEANINGFORMULA(C_EXCEPTION_CODE IN VARCHAR2
                                     ,CC_ERROR_CODE IN VARCHAR2
                                     ,CC_ERROR_FLAG IN VARCHAR2
                                     ,CC_ERROR_TEXT IN VARCHAR2
                                     ,C_ADDL_MESSAGE IN VARCHAR2) RETURN VARCHAR2 IS
    MSG_TEXT VARCHAR2(2000);
  BEGIN
    /*SRW.REFERENCE(C_EXCEPTION_CODE)*/NULL;
    /*SRW.REFERENCE(CC_ERROR_CODE)*/NULL;
    /*SRW.REFERENCE(CC_ERROR_FLAG)*/NULL;
    /*SRW.REFERENCE(CC_ERROR_TEXT)*/NULL;
    IF NVL(CC_ERROR_FLAG
       ,'N') = 'Y' AND CC_ERROR_CODE IS NOT NULL THEN
      MSG_TEXT := RTRIM(CC_ERROR_CODE);
      RETURN (MSG_TEXT || ' ' || CC_ERROR_TEXT);
    ELSIF C_EXCEPTION_CODE IS NOT NULL THEN
      MSG_TEXT := RTRIM(ARP_STANDARD.FND_MESSAGE(C_EXCEPTION_CODE));
      RETURN (MSG_TEXT || ' ' || C_ADDL_MESSAGE);
    ELSE
      RETURN ('');
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('');
  END C_EXCEPTION_MEANINGFORMULA;

  FUNCTION CF_1FORMULA(CC_DISPLAY_FLAG IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF (NVL(CC_DISPLAY_FLAG
       ,'N') = 'Y') THEN
      P_CC_ERROR_FLAG := '1';
      RETURN ('+');
    ELSE
      RETURN (' ');
    END IF;
  END CF_1FORMULA;

  FUNCTION DESNAMEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END DESNAMEVALIDTRIGGER;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;

END AR_ARZCARPO_XMLP_PKG;


/