--------------------------------------------------------
--  DDL for Package Body XTR_XTRUPREP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_XTRUPREP_XMLP_PKG" AS
/* $Header: XTRUPREPB.pls 120.1 2007/12/28 13:04:11 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_COUNT NUMBER;
      L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
      L_MESSAGE_NAME FND_NEW_MESSAGES.MESSAGE_NAME%TYPE;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      BEGIN
        SELECT
          CFREQ.PARTY_CODE,
          CFREQ.ACCOUNT_NO_FROM,
          CFREQ.ACCOUNT_NO_TO,
          CFREQ.DEAL_TYPE,
          CFREQ.DEAL_NUMBER_FROM,
          CFREQ.DEAL_NUMBER_TO,
          CFREQ.CREATION_DATE,
          CFREQ.STARTING_CFLOW_DATE,
          CFREQ.ENDING_CFLOW_DATE,
          CFREQ.INCLUDE_JOURNALIZED_FLAG
        INTO P_PARTY_CODE,P_OLD_ACCOUNT,P_NEW_ACCOUNT,P_DEAL_TYPE,P_STARTING_DEAL_NO,P_ENDING_DEAL_NO,P_EXECUTION_DATE,P_STARTING_DATE,P_ENDING_DATE,P_INCLUDE_JOURNALIZED
        FROM
          XTR_CFLOW_REQUEST_DETAILS CFREQ
        WHERE CFREQ.CASHFLOW_REQUEST_DETAILS_ID = P_CFLOW_REQUEST_DETAILS_ID;
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('XTR'
                              ,'XTR_2035');
          P_MESSAGE_TEXT_FOR_NO_RECORDS := FND_MESSAGE.GET;
          P_NO_RECORDS_UPDATED := 'Y';
      END;
      IF (P_NO_RECORDS_UPDATED = 'N') THEN
        BEGIN
          SELECT
            count(*)
          INTO L_COUNT
          FROM
            XTR_CFLOW_UPDATED_RECORDS
          WHERE CASHFLOW_REQUEST_DETAILS_ID = P_CFLOW_REQUEST_DETAILS_ID;
        EXCEPTION
          WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('XTR'
                                ,'XTR_2035');
            P_MESSAGE_TEXT_FOR_NO_RECORDS := FND_MESSAGE.GET;
            P_NO_RECORDS_UPDATED := 'Y';
        END;
        IF (L_COUNT = 0) THEN
          FND_MESSAGE.SET_NAME('XTR'
                              ,'XTR_2035');
          P_MESSAGE_TEXT_FOR_NO_RECORDS := FND_MESSAGE.GET;
          P_NO_RECORDS_UPDATED := 'Y';
        END IF;
      END IF;
      IF (P_NO_RECORDS_UPDATED = 'N') THEN
        BEGIN
          SELECT
            'Y'
          INTO P_NO_RECORDS_UPDATED
          FROM
            XTR_CFLOW_UPDATED_RECORDS
          WHERE CASHFLOW_REQUEST_DETAILS_ID = P_CFLOW_REQUEST_DETAILS_ID
            AND MESSAGE_NAME = 'XTR_CFLOW_ACCT_UNAUTHORIZED';
          IF (NVL(P_NO_RECORDS_UPDATED
             ,'N') = 'Y') THEN
            FND_MESSAGE.SET_NAME('XTR'
                                ,'XTR_CFLOW_ACCT_UNAUTHORIZED');
            FND_MESSAGE.SET_TOKEN('BANK_ACCOUNT_NUMBER'
                                 ,P_NEW_ACCOUNT);
            P_MESSAGE_TEXT_FOR_NO_RECORDS := FND_MESSAGE.GET;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            P_NO_RECORDS_UPDATED := 'N';
        END;
      END IF;
      IF (P_NO_RECORDS_UPDATED = 'N') THEN
        BEGIN
          SELECT
            'Y'
          INTO P_NO_RECORDS_UPDATED
          FROM
            XTR_CFLOW_UPDATED_RECORDS
          WHERE CASHFLOW_REQUEST_DETAILS_ID = P_CFLOW_REQUEST_DETAILS_ID
            AND MESSAGE_NAME = 'XTR_CFLOW_CURRENCY_MISMATCH';
          IF (NVL(P_NO_RECORDS_UPDATED
             ,'N') = 'Y') THEN
            FND_MESSAGE.SET_NAME('XTR'
                                ,'XTR_CFLOW_CURRENCY_MISMATCH');
            P_MESSAGE_TEXT_FOR_NO_RECORDS := FND_MESSAGE.GET;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            P_NO_RECORDS_UPDATED := 'N';
        END;
      END IF;
      IF (P_NO_RECORDS_UPDATED = 'N') THEN
        FND_MESSAGE.SET_NAME('XTR'
                            ,'XTR_CFLOW_UPDATED');
        FND_MESSAGE.SET_TOKEN('ACCOUNT_NUMBER'
                             ,P_NEW_ACCOUNT);
        P_MESSAGE_CODE_FOR_UPDATE := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME('XTR'
                            ,'XTR_CFLOW_NOT_UPDATED');
        FND_MESSAGE.SET_TOKEN('ACCOUNT_NUMBER'
                             ,P_NEW_ACCOUNT);
        P_MESSAGE_CODE_FOR_ERROR := FND_MESSAGE.GET;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

END XTR_XTRUPREP_XMLP_PKG;


/
