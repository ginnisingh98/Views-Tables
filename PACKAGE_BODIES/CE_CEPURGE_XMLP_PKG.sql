--------------------------------------------------------
--  DDL for Package Body CE_CEPURGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CEPURGE_XMLP_PKG" AS
/* $Header: CEPURGEB.pls 120.1 2008/01/07 21:22:03 abraghun noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      l_date_format VARCHAR2(10) := 'DD-MON-YY';
      L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
      L_BANK_BRANCH_ID NUMBER;
      COUNT_HEADERS NUMBER := 0;
      COUNT_LINES NUMBER := 0;
      COUNT_RECONS NUMBER := 0;
      COUNT_ERRORS NUMBER := 0;
      COUNT_INT_HEADERS NUMBER := 0;
      COUNT_INT_LINES NUMBER := 0;
      COUNT_INTRA_HEADERS NUMBER := 0;
      COUNT_INTRA_LINES NUMBER := 0;
      COUNT_INTRA_INT_HEADERS NUMBER := 0;
      COUNT_INTRA_INT_LINES NUMBER := 0;
      ERROR_FOUND BOOLEAN := FALSE;
      X_HEADER_ID NUMBER := 0;
      X_LINE_ID NUMBER := 0;
      PURGE_LINES NUMBER := 0;
      PURGE_HEADERS NUMBER := 0;
      PURGE_RECONS NUMBER := 0;
      PURGE_RECON_ERRORS NUMBER := 0;
      L_DEF_ORG_ID NUMBER;
      L_SP_ID NUMBER;
      CURSOR C_PURGE_HEADERS IS
        SELECT
          CSH.STATEMENT_HEADER_ID
        FROM
          CE_STATEMENT_HEADERS CSH
        WHERE CSH.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
           ,BANK_ACCOUNT_ID)
          AND CSH.BANK_ACCOUNT_ID IN (
          SELECT
            BANK_ACCOUNT_ID
          FROM
            CE_BANK_ACCTS_GT_V BA
          WHERE BA.BANK_BRANCH_ID = NVL(P_BANK_BRANCH
             ,BA.BANK_BRANCH_ID) )
          AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
           ,TRUNC(CSH.STATEMENT_DATE))
          AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
           ,TRUNC(CSH.STATEMENT_DATE))
          AND not exists (
          SELECT
            1
          FROM
            CE_STATEMENT_HEADERS SH,
            CE_STATEMENT_LINES SL,
            CE_STATEMENT_RECONCILS_ALL SR
          WHERE SH.STATEMENT_HEADER_ID = SL.STATEMENT_HEADER_ID
            AND SL.STATEMENT_LINE_ID = SR.STATEMENT_LINE_ID
            AND SH.STATEMENT_HEADER_ID = CSH.STATEMENT_HEADER_ID
            AND SH.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
             ,BANK_ACCOUNT_ID)
            AND SH.BANK_ACCOUNT_ID IN (
            SELECT
              BANK_ACCOUNT_ID
            FROM
              CE_BANK_ACCOUNTS BA
            WHERE BA.BANK_BRANCH_ID = NVL(P_BANK_BRANCH
               ,BA.BANK_BRANCH_ID) )
            AND TRUNC(SH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
             ,TRUNC(SH.STATEMENT_DATE))
            AND TRUNC(SH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
             ,TRUNC(SH.STATEMENT_DATE))
            AND SR.CURRENT_RECORD_FLAG = 'Y'
            AND SR.STATUS_FLAG = 'M'
            AND ( SR.ORG_ID is not null
          OR SR.LEGAL_ENTITY_ID is not null )
            AND not exists (
            SELECT
              1
            FROM
              CE_SECURITY_PROFILES_GT LBG
            WHERE LBG.ORGANIZATION_ID = SR.ORG_ID
            OR SR.LEGAL_ENTITY_ID = LBG.ORGANIZATION_ID ) );
      CURSOR C_PURGE_LINES IS
        SELECT
          CSL.STATEMENT_LINE_ID
        FROM
          CE_STATEMENT_LINES CSL
        WHERE CSL.STATEMENT_HEADER_ID = X_HEADER_ID;
      CURSOR C_PURGE_INTRA_HEADERS IS
        SELECT
          CSH.STATEMENT_HEADER_ID
        FROM
          CE_INTRA_STMT_HEADERS CSH
        WHERE CSH.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
           ,BANK_ACCOUNT_ID)
          AND CSH.BANK_ACCOUNT_ID IN (
          SELECT
            BANK_ACCOUNT_ID
          FROM
            CE_BANK_ACCTS_GT_V BA
          WHERE BA.BANK_BRANCH_ID = NVL(P_BANK_BRANCH
             ,BA.BANK_BRANCH_ID) )
          AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
           ,TRUNC(CSH.STATEMENT_DATE))
          AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
           ,TRUNC(CSH.STATEMENT_DATE));
      CURSOR C_PURGE_INTRA_LINES IS
        SELECT
          CSL.STATEMENT_LINE_ID
        FROM
          CE_INTRA_STMT_LINES CSL
        WHERE CSL.STATEMENT_HEADER_ID = X_HEADER_ID;
    BEGIN
      P_STATEMENT_DATE_TO1 := P_STATEMENT_DATE_TO;

      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
            --P_STATEMENT_DATE_FROM_1 :=  to_char(to_date(P_STATEMENT_DATE_FROM),'DD-MON-YY');
	    P_STATEMENT_DATE_FROM_1 :=  to_char(P_STATEMENT_DATE_FROM,l_date_format);
      INIT_SECURITY;

      IF (P_STATEMENT_DATE_TO1 IS NULL) THEN
        P_STATEMENT_DATE_TO1 := SYSDATE;
      END IF;

       --P_STATEMENT_DATE_TO_1 :=  to_char(to_date(P_STATEMENT_DATE_TO),'DD-MON-YY');
       P_STATEMENT_DATE_TO_1 :=  to_char(P_STATEMENT_DATE_TO1,l_date_format);
            IF (P_STATEMENT_TYPE IS NULL) THEN
        P_STATEMENT_TYPE := 'BOTH';
      END IF;
      IF (P_BANK_ACCOUNT IS NOT NULL) THEN
        SELECT
          BB.BANK_NAME,
          BB.BANK_BRANCH_NAME,
          BA.BANK_ACCOUNT_NAME,
          BA.BANK_ACCOUNT_NUM,
          BA.CURRENCY_CODE
        INTO
          C_BANK_NAME
          ,C_BANK_BRANCH_NAME
          ,C_BANK_ACCOUNT_NAME
          ,C_BANK_ACCOUNT_NUM
          ,C_CURRENCY_CODE
        FROM
          CE_BANK_BRANCHES_V BB,
          CE_BANK_ACCTS_GT_V BA
        WHERE BA.BANK_ACCOUNT_ID = P_BANK_ACCOUNT
          AND BB.BRANCH_PARTY_ID = BA.BANK_BRANCH_ID;
      ELSIF (P_BANK_BRANCH IS NOT NULL) THEN
        SELECT
          BB.BANK_NAME,
          BB.BANK_BRANCH_NAME
        INTO
          C_BANK_NAME
          ,C_BANK_BRANCH_NAME
        FROM
          CE_BANK_BRANCHES_V BB
        WHERE BB.BRANCH_PARTY_ID = P_BANK_BRANCH;
        C_BANK_ACCOUNT_NAME := C_ALL_TRANSLATION;
        C_BANK_ACCOUNT_NUM := C_ALL_TRANSLATION;
        C_CURRENCY_CODE := C_ALL_TRANSLATION;
      ELSE
        C_BANK_NAME := C_ALL_TRANSLATION;
        C_BANK_BRANCH_NAME := C_ALL_TRANSLATION;
        C_BANK_ACCOUNT_NAME := C_ALL_TRANSLATION;
        C_BANK_ACCOUNT_NUM := C_ALL_TRANSLATION;
        C_CURRENCY_CODE := C_ALL_TRANSLATION;
      END IF;
      BEGIN
        SELECT
          L.MEANING
        INTO
          C_ALL_TRANSLATION
        FROM
          GL_SETS_OF_BOOKS GL,
          CE_SYSTEM_PARAMETERS CB,
          CE_LOOKUPS L
        WHERE GL.SET_OF_BOOKS_ID = CB.SET_OF_BOOKS_ID
          AND L.LOOKUP_TYPE = 'LITERAL'
          AND L.LOOKUP_CODE = 'ALL'
          AND ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SET_NAME('CE'
                  ,'CE_PURGE_NO_SOB');
		  FND_MESSAGE.SET_NAME('CE', 'CE_PURGE_NO_SOB');
          ERROR_FOUND := TRUE;
      END;
      IF (P_BANK_ACCOUNT IS NOT NULL AND P_BANK_BRANCH IS NOT NULL) THEN
        SELECT
          BANK_BRANCH_ID
        INTO
          L_BANK_BRANCH_ID
        FROM
          CE_BANK_ACCTS_GT_V
        WHERE BANK_ACCOUNT_ID = P_BANK_ACCOUNT;
        IF (L_BANK_BRANCH_ID <> P_BANK_BRANCH) THEN
          SET_NAME('CE'
                  ,'CE_PURGE_BRANCH_ACCOUNT');
		  FND_MESSAGE.SET_NAME('CE', 'CE_PURGE_BRANCH_ACCOUNT');
          ERROR_FOUND := TRUE;
        END IF;
      END IF;
      IF (P_DEBUG_MODE = 'Y') THEN
        NULL;
      END IF;
      IF (NOT ERROR_FOUND) THEN
        IF (P_OPTION = 'BOTH' AND NVL(P_ACTION
           ,'DELETE') = 'DELETE') THEN
          IF (P_STATEMENT_TYPE in ('BOTH','PREVIOUS')) THEN
            IF (P_OBJECTS in ('BOTH','STATEMENT')) THEN
              SELECT
                COUNT(*)
              INTO
                COUNT_HEADERS
              FROM
                CE_ARCH_HEADERS;
              SELECT
                COUNT(*)
              INTO
                COUNT_LINES
              FROM
                CE_ARCH_LINES;
              SELECT
                COUNT(*)
              INTO
                COUNT_RECONS
              FROM
                CE_ARCH_RECONCILIATIONS;
              SELECT
                COUNT(*)
              INTO
                COUNT_ERRORS
              FROM
                CE_ARCH_RECON_ERRORS;
            END IF;
            IF (P_OBJECTS in ('BOTH','INTERFACE')) THEN
              SELECT
                COUNT(*)
              INTO
                COUNT_INT_HEADERS
              FROM
                CE_ARCH_INTERFACE_HEADERS
              WHERE NVL(INTRA_DAY_FLAG
                 ,'N') = 'N';
              SELECT
                COUNT(*)
              INTO
                COUNT_INT_LINES
              FROM
                CE_ARCH_INTERFACE_LINES
              WHERE BANK_ACCOUNT_NUM || '-' || STATEMENT_NUMBER IN (
                SELECT
                  BANK_ACCOUNT_NUM || '-' || STATEMENT_NUMBER
                FROM
                  CE_ARCH_INTERFACE_HEADERS
                WHERE NVL(INTRA_DAY_FLAG
                   ,'N') = 'N' );
            END IF;
          END IF;
          IF (P_STATEMENT_TYPE in ('BOTH','INTRADAY')) THEN
            IF (P_OBJECTS in ('BOTH','STATEMENT')) THEN
              SELECT
                COUNT(*)
              INTO
                COUNT_INTRA_HEADERS
              FROM
                CE_ARCH_INTRA_HEADERS;
              SELECT
                COUNT(*)
              INTO
                COUNT_INTRA_LINES
              FROM
                CE_ARCH_INTRA_LINES;
            END IF;
            IF (P_OBJECTS in ('BOTH','INTERFACE')) THEN
              SELECT
                COUNT(*)
              INTO
                COUNT_INTRA_INT_HEADERS
              FROM
                CE_ARCH_INTERFACE_HEADERS
              WHERE NVL(INTRA_DAY_FLAG
                 ,'N') = 'Y';
              SELECT
                COUNT(*)
              INTO
                COUNT_INTRA_INT_LINES
              FROM
                CE_ARCH_INTERFACE_LINES
              WHERE BANK_ACCOUNT_NUM || '-' || STATEMENT_NUMBER IN (
                SELECT
                  BANK_ACCOUNT_NUM || '-' || STATEMENT_NUMBER
                FROM
                  CE_ARCH_INTERFACE_HEADERS
                WHERE NVL(INTRA_DAY_FLAG
                   ,'N') = 'Y' );
            END IF;
          END IF;
          IF (COUNT_HEADERS > 0) THEN
            DELETE FROM CE_ARCH_HEADERS;
          END IF;
          IF (COUNT_LINES > 0) THEN
            DELETE FROM CE_ARCH_LINES;
          END IF;
          IF (COUNT_RECONS > 0) THEN
            DELETE FROM CE_ARCH_RECONCILIATIONS_ALL
             WHERE ORG_ID in (
               SELECT
                 ORG_ID
               FROM
                 CE_SECURITY_PROFILES_GT )
             OR LEGAL_ENTITY_ID in (
               SELECT
                 ORG_ID
               FROM
                 CE_SECURITY_PROFILES_GT )
             OR REFERENCE_TYPE in ( 'JE_LINE' , 'ROI_LINE' , 'STATEMENT' );
          END IF;
          IF (COUNT_ERRORS > 0) THEN
            DELETE FROM CE_ARCH_RECON_ERRORS;
          END IF;
          IF (COUNT_INT_LINES > 0) THEN
            DELETE FROM CE_ARCH_INTERFACE_LINES
             WHERE BANK_ACCOUNT_NUM || '-' || STATEMENT_NUMBER IN (
               SELECT
                 BANK_ACCOUNT_NUM || '-' || STATEMENT_NUMBER
               FROM
                 CE_ARCH_INTERFACE_HEADERS
               WHERE NVL(INTRA_DAY_FLAG
                  ,'N') = 'N' );
          END IF;
          IF (COUNT_INT_HEADERS > 0) THEN
            DELETE FROM CE_ARCH_INTERFACE_HEADERS
             WHERE NVL(INTRA_DAY_FLAG
                ,'N') = 'N';
          END IF;
          IF (COUNT_INTRA_HEADERS > 0) THEN
            DELETE FROM CE_ARCH_INTRA_HEADERS;
          END IF;
          IF (COUNT_INTRA_LINES > 0) THEN
            DELETE FROM CE_ARCH_INTRA_LINES;
          END IF;
          IF (COUNT_INTRA_INT_LINES > 0) THEN
            DELETE FROM CE_ARCH_INTERFACE_LINES
             WHERE BANK_ACCOUNT_NUM || '-' || STATEMENT_NUMBER IN (
               SELECT
                 BANK_ACCOUNT_NUM || '-' || STATEMENT_NUMBER
               FROM
                 CE_ARCH_INTERFACE_HEADERS
               WHERE NVL(INTRA_DAY_FLAG
                  ,'N') = 'Y' );
          END IF;
          IF (COUNT_INTRA_INT_HEADERS > 0) THEN
            DELETE FROM CE_ARCH_INTERFACE_HEADERS
             WHERE NVL(INTRA_DAY_FLAG
                ,'N') = 'Y';
          END IF;
        END IF;
      END IF;
      IF (NOT ERROR_FOUND) THEN
        IF (P_STATEMENT_TYPE in ('BOTH','PREVIOUS')) THEN
          IF (P_OBJECTS in ('BOTH','STATEMENT')) THEN
            IF (P_OPTION in ('BOTH')) THEN
              IF (P_BANK_ACCOUNT IS NOT NULL) THEN
                INSERT INTO CE_ARCH_HEADERS
                  (STATEMENT_COMPLETE_FLAG
                  ,DOC_SEQUENCE_ID
                  ,DOC_SEQUENCE_VALUE
                  ,STATEMENT_HEADER_ID
                  ,BANK_ACCOUNT_ID
                  ,STATEMENT_NUMBER
                  ,STATEMENT_DATE
                  ,AUTO_LOADED_FLAG
                  ,GL_DATE
                  ,CHECK_DIGITS
                  ,CONTROL_BEGIN_BALANCE
                  ,CONTROL_TOTAL_DR
                  ,CONTROL_TOTAL_CR
                  ,CONTROL_END_BALANCE
                  ,CASHFLOW_BALANCE
                  ,INT_CALC_BALANCE
                  ,ONE_DAY_FLOAT
                  ,TWO_DAY_FLOAT
                  ,CONTROL_DR_LINE_COUNT
                  ,CONTROL_CR_LINE_COUNT
                  ,CURRENCY_CODE
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15
                  ,LAST_UPDATE_LOGIN
                  ,CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE)
                  SELECT
                    STATEMENT_COMPLETE_FLAG,
                    DOC_SEQUENCE_ID,
                    DOC_SEQUENCE_VALUE,
                    STATEMENT_HEADER_ID,
                    BANK_ACCOUNT_ID,
                    STATEMENT_NUMBER,
                    STATEMENT_DATE,
                    AUTO_LOADED_FLAG,
                    GL_DATE,
                    CHECK_DIGITS,
                    CONTROL_BEGIN_BALANCE,
                    CONTROL_TOTAL_DR,
                    CONTROL_TOTAL_CR,
                    CONTROL_END_BALANCE,
                    CASHFLOW_BALANCE,
                    INT_CALC_BALANCE,
                    ONE_DAY_FLOAT,
                    TWO_DAY_FLOAT,
                    CONTROL_DR_LINE_COUNT,
                    CONTROL_CR_LINE_COUNT,
                    CURRENCY_CODE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    LAST_UPDATE_LOGIN,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                  FROM
                    CE_STATEMENT_HEADERS CSH
                  WHERE CSH.BANK_ACCOUNT_ID = P_BANK_ACCOUNT
                    AND CSH.STATEMENT_DATE >= NVL(P_STATEMENT_DATE_FROM
                     ,CSH.STATEMENT_DATE)
                    AND CSH.STATEMENT_DATE <= NVL(P_STATEMENT_DATE_TO1
                     ,CSH.STATEMENT_DATE)
                    AND not exists (
                    SELECT
                      1
                    FROM
                      CE_STATEMENT_HEADERS SH,
                      CE_STATEMENT_LINES SL,
                      CE_STATEMENT_RECONCILS_ALL SR
                    WHERE SH.STATEMENT_HEADER_ID = SL.STATEMENT_HEADER_ID
                      AND SL.STATEMENT_LINE_ID = SR.STATEMENT_LINE_ID
                      AND SH.STATEMENT_HEADER_ID = CSH.STATEMENT_HEADER_ID
                      AND SH.BANK_ACCOUNT_ID = P_BANK_ACCOUNT
                      AND SH.STATEMENT_DATE >= NVL(P_STATEMENT_DATE_FROM
                       ,SH.STATEMENT_DATE)
                      AND SH.STATEMENT_DATE <= NVL(P_STATEMENT_DATE_TO1
                       ,SH.STATEMENT_DATE)
                      AND SR.CURRENT_RECORD_FLAG = 'Y'
                      AND SR.STATUS_FLAG = 'M'
                      AND ( SR.ORG_ID is not null
                    OR SR.LEGAL_ENTITY_ID is not null )
                      AND not exists (
                      SELECT
                        1
                      FROM
                        CE_SECURITY_PROFILES_GT LBG
                      WHERE LBG.ORGANIZATION_ID = SR.ORG_ID
                      OR SR.LEGAL_ENTITY_ID = LBG.ORGANIZATION_ID ) );
                C_ARCHIVE_STAT_HEADERS := SQL%ROWCOUNT;
              ELSIF (P_BANK_BRANCH IS NOT NULL) THEN
                INSERT INTO CE_ARCH_HEADERS
                  (STATEMENT_COMPLETE_FLAG
                  ,DOC_SEQUENCE_ID
                  ,DOC_SEQUENCE_VALUE
                  ,STATEMENT_HEADER_ID
                  ,BANK_ACCOUNT_ID
                  ,STATEMENT_NUMBER
                  ,STATEMENT_DATE
                  ,AUTO_LOADED_FLAG
                  ,GL_DATE
                  ,CHECK_DIGITS
                  ,CONTROL_BEGIN_BALANCE
                  ,CONTROL_TOTAL_DR
                  ,CONTROL_TOTAL_CR
                  ,CONTROL_END_BALANCE
                  ,CASHFLOW_BALANCE
                  ,INT_CALC_BALANCE
                  ,ONE_DAY_FLOAT
                  ,TWO_DAY_FLOAT
                  ,CONTROL_DR_LINE_COUNT
                  ,CONTROL_CR_LINE_COUNT
                  ,CURRENCY_CODE
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15
                  ,LAST_UPDATE_LOGIN
                  ,CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE)
                  SELECT
                    STATEMENT_COMPLETE_FLAG,
                    DOC_SEQUENCE_ID,
                    DOC_SEQUENCE_VALUE,
                    STATEMENT_HEADER_ID,
                    BANK_ACCOUNT_ID,
                    STATEMENT_NUMBER,
                    STATEMENT_DATE,
                    AUTO_LOADED_FLAG,
                    GL_DATE,
                    CHECK_DIGITS,
                    CONTROL_BEGIN_BALANCE,
                    CONTROL_TOTAL_DR,
                    CONTROL_TOTAL_CR,
                    CONTROL_END_BALANCE,
                    CASHFLOW_BALANCE,
                    INT_CALC_BALANCE,
                    ONE_DAY_FLOAT,
                    TWO_DAY_FLOAT,
                    CONTROL_DR_LINE_COUNT,
                    CONTROL_CR_LINE_COUNT,
                    CURRENCY_CODE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    LAST_UPDATE_LOGIN,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                  FROM
                    CE_STATEMENT_HEADERS CSH
                  WHERE CSH.BANK_ACCOUNT_ID IN (
                    SELECT
                      ABA.BANK_ACCOUNT_ID
                    FROM
                      CE_BANK_ACCTS_GT_V ABA
                    WHERE ABA.BANK_BRANCH_ID = P_BANK_BRANCH )
                    AND CSH.STATEMENT_DATE >= NVL(P_STATEMENT_DATE_FROM
                     ,CSH.STATEMENT_DATE)
                    AND CSH.STATEMENT_DATE <= NVL(P_STATEMENT_DATE_TO1
                     ,CSH.STATEMENT_DATE)
                    AND not exists (
                    SELECT
                      1
                    FROM
                      CE_STATEMENT_HEADERS SH,
                      CE_STATEMENT_LINES SL,
                      CE_STATEMENT_RECONCILS_ALL SR
                    WHERE SH.STATEMENT_HEADER_ID = SL.STATEMENT_HEADER_ID
                      AND SL.STATEMENT_LINE_ID = SR.STATEMENT_LINE_ID
                      AND SH.STATEMENT_HEADER_ID = CSH.STATEMENT_HEADER_ID
                      AND SH.BANK_ACCOUNT_ID IN (
                      SELECT
                        ABA.BANK_ACCOUNT_ID
                      FROM
                        CE_BANK_ACCOUNTS ABA
                      WHERE ABA.BANK_BRANCH_ID = P_BANK_BRANCH )
                      AND SH.STATEMENT_DATE >= NVL(P_STATEMENT_DATE_FROM
                       ,SH.STATEMENT_DATE)
                      AND SH.STATEMENT_DATE <= NVL(P_STATEMENT_DATE_TO1
                       ,SH.STATEMENT_DATE)
                      AND SR.CURRENT_RECORD_FLAG = 'Y'
                      AND SR.STATUS_FLAG = 'M'
                      AND ( SR.ORG_ID is not null
                    OR SR.LEGAL_ENTITY_ID is not null )
                      AND not exists (
                      SELECT
                        1
                      FROM
                        CE_SECURITY_PROFILES_GT LBG
                      WHERE LBG.ORGANIZATION_ID = SR.ORG_ID
                      OR SR.LEGAL_ENTITY_ID = LBG.ORGANIZATION_ID ) );
                C_ARCHIVE_STAT_HEADERS := SQL%ROWCOUNT;
              ELSE
                INSERT INTO CE_ARCH_HEADERS
                  (STATEMENT_COMPLETE_FLAG
                  ,DOC_SEQUENCE_ID
                  ,DOC_SEQUENCE_VALUE
                  ,STATEMENT_HEADER_ID
                  ,BANK_ACCOUNT_ID
                  ,STATEMENT_NUMBER
                  ,STATEMENT_DATE
                  ,AUTO_LOADED_FLAG
                  ,GL_DATE
                  ,CHECK_DIGITS
                  ,CONTROL_BEGIN_BALANCE
                  ,CONTROL_TOTAL_DR
                  ,CONTROL_TOTAL_CR
                  ,CONTROL_END_BALANCE
                  ,CASHFLOW_BALANCE
                  ,INT_CALC_BALANCE
                  ,ONE_DAY_FLOAT
                  ,TWO_DAY_FLOAT
                  ,CONTROL_DR_LINE_COUNT
                  ,CONTROL_CR_LINE_COUNT
                  ,CURRENCY_CODE
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15
                  ,LAST_UPDATE_LOGIN
                  ,CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE)
                  SELECT
                    STATEMENT_COMPLETE_FLAG,
                    DOC_SEQUENCE_ID,
                    DOC_SEQUENCE_VALUE,
                    STATEMENT_HEADER_ID,
                    BANK_ACCOUNT_ID,
                    STATEMENT_NUMBER,
                    STATEMENT_DATE,
                    AUTO_LOADED_FLAG,
                    GL_DATE,
                    CHECK_DIGITS,
                    CONTROL_BEGIN_BALANCE,
                    CONTROL_TOTAL_DR,
                    CONTROL_TOTAL_CR,
                    CONTROL_END_BALANCE,
                    CASHFLOW_BALANCE,
                    INT_CALC_BALANCE,
                    ONE_DAY_FLOAT,
                    TWO_DAY_FLOAT,
                    CONTROL_DR_LINE_COUNT,
                    CONTROL_CR_LINE_COUNT,
                    CURRENCY_CODE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    LAST_UPDATE_LOGIN,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                  FROM
                    CE_STATEMENT_HEADERS CSH
                  WHERE CSH.STATEMENT_DATE >= NVL(P_STATEMENT_DATE_FROM
                     ,CSH.STATEMENT_DATE)
                    AND CSH.STATEMENT_DATE <= NVL(P_STATEMENT_DATE_TO1
                     ,CSH.STATEMENT_DATE)
                    AND not exists (
                    SELECT
                      1
                    FROM
                      CE_STATEMENT_HEADERS SH,
                      CE_STATEMENT_LINES SL,
                      CE_STATEMENT_RECONCILS_ALL SR
                    WHERE SH.STATEMENT_HEADER_ID = SL.STATEMENT_HEADER_ID
                      AND SL.STATEMENT_LINE_ID = SR.STATEMENT_LINE_ID
                      AND SH.STATEMENT_HEADER_ID = CSH.STATEMENT_HEADER_ID
                      AND SH.STATEMENT_DATE >= NVL(P_STATEMENT_DATE_FROM
                       ,SH.STATEMENT_DATE)
                      AND SH.STATEMENT_DATE <= NVL(P_STATEMENT_DATE_TO1
                       ,SH.STATEMENT_DATE)
                      AND SR.CURRENT_RECORD_FLAG = 'Y'
                      AND SR.STATUS_FLAG = 'M'
                      AND ( SR.ORG_ID is not null
                    OR SR.LEGAL_ENTITY_ID is not null )
                      AND not exists (
                      SELECT
                        1
                      FROM
                        CE_SECURITY_PROFILES_GT LBG
                      WHERE LBG.ORGANIZATION_ID = SR.ORG_ID
                      OR SR.LEGAL_ENTITY_ID = LBG.ORGANIZATION_ID ) );
                C_ARCHIVE_STAT_HEADERS := SQL%ROWCOUNT;
              END IF;
              INSERT INTO CE_ARCH_LINES
                (STATEMENT_LINE_ID
                ,STATEMENT_HEADER_ID
                ,LINE_NUMBER
                ,TRX_DATE
                ,TRX_TYPE
                ,AMOUNT
                ,CHARGES_AMOUNT
                ,STATUS
                ,TRX_CODE_ID
                ,EFFECTIVE_DATE
                ,BANK_TRX_NUMBER
                ,TRX_TEXT
                ,CUSTOMER_TEXT
                ,INVOICE_TEXT
                ,CURRENCY_CODE
                ,EXCHANGE_RATE_TYPE
                ,EXCHANGE_RATE
                ,EXCHANGE_RATE_DATE
                ,ORIGINAL_AMOUNT
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,LAST_UPDATE_LOGIN
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,RECONCILE_TO_STATEMENT_FLAG)
                SELECT
                  STATEMENT_LINE_ID,
                  STATEMENT_HEADER_ID,
                  LINE_NUMBER,
                  TRX_DATE,
                  TRX_TYPE,
                  AMOUNT,
                  CHARGES_AMOUNT,
                  STATUS,
                  TRX_CODE_ID,
                  EFFECTIVE_DATE,
                  BANK_TRX_NUMBER,
                  TRX_TEXT,
                  CUSTOMER_TEXT,
                  INVOICE_TEXT,
                  CURRENCY_CODE,
                  EXCHANGE_RATE_TYPE,
                  EXCHANGE_RATE,
                  EXCHANGE_RATE_DATE,
                  ORIGINAL_AMOUNT,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15,
                  LAST_UPDATE_LOGIN,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  RECONCILE_TO_STATEMENT_FLAG
                FROM
                  CE_STATEMENT_LINES
                WHERE STATEMENT_HEADER_ID IN (
                  SELECT
                    STATEMENT_HEADER_ID
                  FROM
                    CE_ARCH_HEADERS );
              C_ARCHIVE_STAT_LINES := SQL%ROWCOUNT;
              INSERT INTO CE_ARCH_RECONCILIATIONS_ALL
                (STATEMENT_LINE_ID
                ,REFERENCE_TYPE
                ,REFERENCE_ID
                ,JE_HEADER_ID
                ,ORG_ID
                ,LEGAL_ENTITY_ID
                ,REFERENCE_STATUS
                ,STATUS_FLAG
                ,ACTION_FLAG
                ,CURRENT_RECORD_FLAG
                ,AUTO_RECONCILED_FLAG
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,REQUEST_ID
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,AMOUNT)
                SELECT
                  STATEMENT_LINE_ID,
                  REFERENCE_TYPE,
                  REFERENCE_ID,
                  JE_HEADER_ID,
                  ORG_ID,
                  LEGAL_ENTITY_ID,
                  REFERENCE_STATUS,
                  STATUS_FLAG,
                  ACTION_FLAG,
                  CURRENT_RECORD_FLAG,
                  AUTO_RECONCILED_FLAG,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE,
                  AMOUNT
                FROM
                  CE_STATEMENT_RECON_GT_V
                WHERE STATEMENT_LINE_ID IN (
                  SELECT
                    STATEMENT_LINE_ID
                  FROM
                    CE_ARCH_LINES );
              C_ARCHIVE_STAT_REC := SQL%ROWCOUNT;
              INSERT INTO CE_ARCH_RECON_ERRORS
                (STATEMENT_LINE_ID
                ,MESSAGE_NAME
                ,CREATION_DATE
                ,CREATED_BY
                ,APPLICATION_SHORT_NAME
                ,STATEMENT_HEADER_ID)
                SELECT
                  STATEMENT_LINE_ID,
                  MESSAGE_NAME,
                  CREATION_DATE,
                  CREATED_BY,
                  APPLICATION_SHORT_NAME,
                  STATEMENT_HEADER_ID
                FROM
                  CE_RECONCILIATION_ERRORS
                WHERE STATEMENT_LINE_ID IN (
                  SELECT
                    STATEMENT_LINE_ID
                  FROM
                    CE_ARCH_LINES );
              C_ARCHIVE_STAT_ERRORS := SQL%ROWCOUNT;
            END IF;
            OPEN C_PURGE_HEADERS;
            FETCH C_PURGE_HEADERS
             INTO
               X_HEADER_ID;
            LOOP
              EXIT WHEN C_PURGE_HEADERS%NOTFOUND;
              DELETE FROM CE_STATEMENT_HEADERS
               WHERE STATEMENT_HEADER_ID = X_HEADER_ID;
              PURGE_HEADERS := PURGE_HEADERS + SQL%ROWCOUNT;
              OPEN C_PURGE_LINES;
              FETCH C_PURGE_LINES
               INTO
                 X_LINE_ID;
              LOOP
                EXIT WHEN C_PURGE_LINES%NOTFOUND;
                DELETE FROM CE_STATEMENT_LINES
                 WHERE STATEMENT_HEADER_ID = X_HEADER_ID;
                PURGE_LINES := PURGE_LINES + SQL%ROWCOUNT;
                DELETE FROM CE_STATEMENT_RECONCILS_ALL
                 WHERE STATEMENT_LINE_ID = X_LINE_ID
                   AND ( ORG_ID in (
                   SELECT
                     ORGANIZATION_ID
                   FROM
                     CE_SECURITY_PROFILES_GT )
                 OR LEGAL_ENTITY_ID in (
                   SELECT
                     ORGANIZATION_ID
                   FROM
                     CE_SECURITY_PROFILES_GT )
                 OR REFERENCE_TYPE in ( 'JE_LINE' , 'ROI_LINE' , 'STATEMENT' ) );
                PURGE_RECONS := PURGE_RECONS + SQL%ROWCOUNT;
                DELETE FROM CE_RECONCILIATION_ERRORS
                 WHERE STATEMENT_LINE_ID = X_LINE_ID;
                PURGE_RECON_ERRORS := PURGE_RECON_ERRORS + SQL%ROWCOUNT;
                FETCH C_PURGE_LINES
                 INTO
                   X_LINE_ID;
              END LOOP;
              CLOSE C_PURGE_LINES;
              FETCH C_PURGE_HEADERS
               INTO
                 X_HEADER_ID;
            END LOOP;
            CLOSE C_PURGE_HEADERS;
            C_PURGE_STAT_LINES := PURGE_LINES;
            C_PURGE_STAT_HEADERS := PURGE_HEADERS;
            C_PURGE_STAT_REC := PURGE_RECONS;
            C_PURGE_STAT_ERRORS := PURGE_RECON_ERRORS;
          END IF;
          IF (P_OBJECTS in ('BOTH','INTERFACE')) THEN
            IF (P_OPTION = 'BOTH') THEN
              INSERT INTO CE_ARCH_INTERFACE_HEADERS
                (STATEMENT_NUMBER
                ,BANK_ACCOUNT_NUM
                ,STATEMENT_DATE
                ,BANK_NAME
                ,BANK_BRANCH_NAME
                ,CHECK_DIGITS
                ,CONTROL_BEGIN_BALANCE
                ,CONTROL_TOTAL_DR
                ,CONTROL_TOTAL_CR
                ,CONTROL_END_BALANCE
                ,CASHFLOW_BALANCE
                ,INT_CALC_BALANCE
                ,ONE_DAY_FLOAT
                ,TWO_DAY_FLOAT
                ,CONTROL_DR_LINE_COUNT
                ,CONTROL_CR_LINE_COUNT
                ,CONTROL_LINE_COUNT
                ,RECORD_STATUS_FLAG
                ,CURRENCY_CODE
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE)
                SELECT
                  STATEMENT_NUMBER,
                  BANK_ACCOUNT_NUM,
                  STATEMENT_DATE,
                  BANK_NAME,
                  BANK_BRANCH_NAME,
                  CHECK_DIGITS,
                  CONTROL_BEGIN_BALANCE,
                  CONTROL_TOTAL_DR,
                  CONTROL_TOTAL_CR,
                  CONTROL_END_BALANCE,
                  CASHFLOW_BALANCE,
                  INT_CALC_BALANCE,
                  ONE_DAY_FLOAT,
                  TWO_DAY_FLOAT,
                  CONTROL_DR_LINE_COUNT,
                  CONTROL_CR_LINE_COUNT,
                  CONTROL_LINE_COUNT,
                  RECORD_STATUS_FLAG,
                  CURRENCY_CODE,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE
                FROM
                  CE_STATEMENT_HEADERS_INT CSH
                WHERE NVL(CSH.BANK_BRANCH_NAME
                   ,C_BANK_BRANCH_NAME) IN (
                  SELECT
                    BB.BANK_BRANCH_NAME
                  FROM
                    CE_BANK_BRANCHES_V BB,
                    CE_BANK_ACCTS_GT_V BA
                  WHERE BB.BRANCH_PARTY_ID = BA.BANK_BRANCH_ID
                    AND BA.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                     ,BA.BANK_ACCOUNT_ID)
                    AND BB.BRANCH_PARTY_ID = NVL(P_BANK_BRANCH
                     ,BB.BRANCH_PARTY_ID) )
                  AND CSH.BANK_ACCOUNT_NUM IN (
                  SELECT
                    BANK_ACCOUNT_NUM
                  FROM
                    CE_BANK_ACCTS_GT_V
                  WHERE BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                     ,BANK_ACCOUNT_ID)
                    AND BANK_BRANCH_ID = NVL(P_BANK_BRANCH
                     ,BANK_BRANCH_ID) )
                  AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                   ,TRUNC(CSH.STATEMENT_DATE))
                  AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                   ,TRUNC(CSH.STATEMENT_DATE))
                  AND CSH.RECORD_STATUS_FLAG in ( DECODE(P_HDR_INT_STATUS
                      ,'C'
                      ,'C'
                      ,'E'
                      ,'E'
                      ,'N'
                      ,'N'
                      ,'T'
                      ,'T'
                      ,'A'
                      ,RECORD_STATUS_FLAG
                      ,'T') )
                  AND NVL(CSH.INTRA_DAY_FLAG
                   ,'N') = 'N';
              C_ARCHIVE_INF_HEADERS := SQL%ROWCOUNT;
              INSERT INTO CE_ARCH_INTERFACE_LINES
                (EXCHANGE_RATE_DATE
                ,EXCHANGE_RATE
                ,BANK_TRX_NUMBER
                ,CUSTOMER_TEXT
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,ORIGINAL_AMOUNT
                ,BANK_ACCOUNT_NUM
                ,STATEMENT_NUMBER
                ,LINE_NUMBER
                ,TRX_DATE
                ,TRX_CODE
                ,EFFECTIVE_DATE
                ,TRX_TEXT
                ,INVOICE_TEXT
                ,AMOUNT
                ,CHARGES_AMOUNT
                ,CURRENCY_CODE
                ,USER_EXCHANGE_RATE_TYPE)
                SELECT
                  EXCHANGE_RATE_DATE,
                  EXCHANGE_RATE,
                  BANK_TRX_NUMBER,
                  CUSTOMER_TEXT,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15,
                  ORIGINAL_AMOUNT,
                  BANK_ACCOUNT_NUM,
                  STATEMENT_NUMBER,
                  LINE_NUMBER,
                  TRX_DATE,
                  TRX_CODE,
                  EFFECTIVE_DATE,
                  TRX_TEXT,
                  INVOICE_TEXT,
                  AMOUNT,
                  CHARGES_AMOUNT,
                  CURRENCY_CODE,
                  USER_EXCHANGE_RATE_TYPE
                FROM
                  CE_STATEMENT_LINES_INTERFACE CSL
                WHERE CSL.BANK_ACCOUNT_NUM IN (
                  SELECT
                    BANK_ACCOUNT_NUM
                  FROM
                    CE_ARCH_INTERFACE_HEADERS )
                  AND STATEMENT_NUMBER IN (
                  SELECT
                    STATEMENT_NUMBER
                  FROM
                    CE_ARCH_INTERFACE_HEADERS
                  WHERE CSL.BANK_ACCOUNT_NUM = BANK_ACCOUNT_NUM
                    AND NVL(INTRA_DAY_FLAG
                     ,'N') = 'N' );
              C_ARCHIVE_INF_LINES := SQL%ROWCOUNT;
            END IF;
            DELETE FROM CE_STATEMENT_LINES_INTERFACE CSL
             WHERE CSL.STATEMENT_NUMBER || '-' || CSL.BANK_ACCOUNT_NUM IN (
               SELECT
                 CSH.STATEMENT_NUMBER || '-' || CSH.BANK_ACCOUNT_NUM
               FROM
                 CE_STATEMENT_HEADERS_INT CSH
               WHERE NVL(CSH.BANK_BRANCH_NAME
                  ,C_BANK_BRANCH_NAME) IN (
                 SELECT
                   BB.BANK_BRANCH_NAME
                 FROM
                   CE_BANK_BRANCHES_V BB,
                   CE_BANK_ACCTS_GT_V BA
                 WHERE BB.BRANCH_PARTY_ID = BA.BANK_BRANCH_ID
                   AND BA.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                    ,BA.BANK_ACCOUNT_ID)
                   AND BB.BRANCH_PARTY_ID = NVL(P_BANK_BRANCH
                    ,BB.BRANCH_PARTY_ID) )
                 AND CSH.BANK_ACCOUNT_NUM IN (
                 SELECT
                   BANK_ACCOUNT_NUM
                 FROM
                   CE_BANK_ACCTS_GT_V
                 WHERE BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                    ,BANK_ACCOUNT_ID)
                   AND BANK_BRANCH_ID = NVL(P_BANK_BRANCH
                    ,BANK_BRANCH_ID) )
                 AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                  ,TRUNC(CSH.STATEMENT_DATE))
                 AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                  ,TRUNC(CSH.STATEMENT_DATE))
                 AND CSH.RECORD_STATUS_FLAG in ( DECODE(P_HDR_INT_STATUS
                     ,'C'
                     ,'C'
                     ,'E'
                     ,'E'
                     ,'N'
                     ,'N'
                     ,'T'
                     ,'T'
                     ,'A'
                     ,RECORD_STATUS_FLAG
                     ,'T') )
                 AND NVL(CSH.INTRA_DAY_FLAG
                  ,'N') = 'N' );
            C_PURGE_INF_LINES := SQL%ROWCOUNT;
            DELETE FROM CE_STATEMENT_HEADERS_INT CSH
             WHERE NVL(CSH.BANK_BRANCH_NAME
                ,C_BANK_BRANCH_NAME) IN (
               SELECT
                 BB.BANK_BRANCH_NAME
               FROM
                 CE_BANK_BRANCHES_V BB,
                 CE_BANK_ACCTS_GT_V BA
               WHERE BB.BRANCH_PARTY_ID = BA.BANK_BRANCH_ID
                 AND BA.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                  ,BA.BANK_ACCOUNT_ID)
                 AND BB.BRANCH_PARTY_ID = NVL(P_BANK_BRANCH
                  ,BB.BRANCH_PARTY_ID) )
               AND CSH.BANK_ACCOUNT_NUM IN (
               SELECT
                 BANK_ACCOUNT_NUM
               FROM
                 CE_BANK_ACCTS_GT_V
               WHERE BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                  ,BANK_ACCOUNT_ID)
                 AND BANK_BRANCH_ID = NVL(P_BANK_BRANCH
                  ,BANK_BRANCH_ID) )
               AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                ,TRUNC(CSH.STATEMENT_DATE))
               AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                ,TRUNC(CSH.STATEMENT_DATE))
               AND CSH.RECORD_STATUS_FLAG in ( DECODE(P_HDR_INT_STATUS
                   ,'C'
                   ,'C'
                   ,'E'
                   ,'E'
                   ,'N'
                   ,'N'
                   ,'T'
                   ,'T'
                   ,'A'
                   ,RECORD_STATUS_FLAG
                   ,'T') )
               AND NVL(CSH.INTRA_DAY_FLAG
                ,'N') = 'N';
            C_PURGE_INF_HEADERS := SQL%ROWCOUNT;
          END IF;
        END IF;
        IF (P_STATEMENT_TYPE in ('BOTH','INTRADAY')) THEN
          IF (P_OBJECTS in ('BOTH','STATEMENT')) THEN
            IF (P_OPTION in ('BOTH')) THEN
              IF (P_BANK_ACCOUNT IS NOT NULL) THEN
                INSERT INTO CE_ARCH_INTRA_HEADERS
                  (STATEMENT_COMPLETE_FLAG
                  ,DOC_SEQUENCE_ID
                  ,DOC_SEQUENCE_VALUE
                  ,STATEMENT_HEADER_ID
                  ,BANK_ACCOUNT_ID
                  ,STATEMENT_NUMBER
                  ,STATEMENT_DATE
                  ,AUTO_LOADED_FLAG
                  ,GL_DATE
                  ,CHECK_DIGITS
                  ,CONTROL_BEGIN_BALANCE
                  ,CONTROL_TOTAL_DR
                  ,CONTROL_TOTAL_CR
                  ,CONTROL_END_BALANCE
                  ,CASHFLOW_BALANCE
                  ,INT_CALC_BALANCE
                  ,ONE_DAY_FLOAT
                  ,TWO_DAY_FLOAT
                  ,CONTROL_DR_LINE_COUNT
                  ,CONTROL_CR_LINE_COUNT
                  ,CURRENCY_CODE
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15
                  ,LAST_UPDATE_LOGIN
                  ,CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE)
                  SELECT
                    STATEMENT_COMPLETE_FLAG,
                    DOC_SEQUENCE_ID,
                    DOC_SEQUENCE_VALUE,
                    STATEMENT_HEADER_ID,
                    BANK_ACCOUNT_ID,
                    STATEMENT_NUMBER,
                    STATEMENT_DATE,
                    AUTO_LOADED_FLAG,
                    GL_DATE,
                    CHECK_DIGITS,
                    CONTROL_BEGIN_BALANCE,
                    CONTROL_TOTAL_DR,
                    CONTROL_TOTAL_CR,
                    CONTROL_END_BALANCE,
                    CASHFLOW_BALANCE,
                    INT_CALC_BALANCE,
                    ONE_DAY_FLOAT,
                    TWO_DAY_FLOAT,
                    CONTROL_DR_LINE_COUNT,
                    CONTROL_CR_LINE_COUNT,
                    CURRENCY_CODE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    LAST_UPDATE_LOGIN,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                  FROM
                    CE_INTRA_STMT_HEADERS CSH
                  WHERE CSH.BANK_ACCOUNT_ID = P_BANK_ACCOUNT
                    AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                     ,TRUNC(CSH.STATEMENT_DATE))
                    AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                     ,TRUNC(CSH.STATEMENT_DATE));
                C_ARCHIVE_STAT_HEADERS2 := SQL%ROWCOUNT;
              ELSIF (P_BANK_BRANCH IS NOT NULL) THEN
                INSERT INTO CE_ARCH_INTRA_HEADERS
                  (STATEMENT_COMPLETE_FLAG
                  ,DOC_SEQUENCE_ID
                  ,DOC_SEQUENCE_VALUE
                  ,STATEMENT_HEADER_ID
                  ,BANK_ACCOUNT_ID
                  ,STATEMENT_NUMBER
                  ,STATEMENT_DATE
                  ,AUTO_LOADED_FLAG
                  ,GL_DATE
                  ,CHECK_DIGITS
                  ,CONTROL_BEGIN_BALANCE
                  ,CONTROL_TOTAL_DR
                  ,CONTROL_TOTAL_CR
                  ,CONTROL_END_BALANCE
                  ,CASHFLOW_BALANCE
                  ,INT_CALC_BALANCE
                  ,ONE_DAY_FLOAT
                  ,TWO_DAY_FLOAT
                  ,CONTROL_DR_LINE_COUNT
                  ,CONTROL_CR_LINE_COUNT
                  ,CURRENCY_CODE
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15
                  ,LAST_UPDATE_LOGIN
                  ,CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE)
                  SELECT
                    STATEMENT_COMPLETE_FLAG,
                    DOC_SEQUENCE_ID,
                    DOC_SEQUENCE_VALUE,
                    STATEMENT_HEADER_ID,
                    BANK_ACCOUNT_ID,
                    STATEMENT_NUMBER,
                    STATEMENT_DATE,
                    AUTO_LOADED_FLAG,
                    GL_DATE,
                    CHECK_DIGITS,
                    CONTROL_BEGIN_BALANCE,
                    CONTROL_TOTAL_DR,
                    CONTROL_TOTAL_CR,
                    CONTROL_END_BALANCE,
                    CASHFLOW_BALANCE,
                    INT_CALC_BALANCE,
                    ONE_DAY_FLOAT,
                    TWO_DAY_FLOAT,
                    CONTROL_DR_LINE_COUNT,
                    CONTROL_CR_LINE_COUNT,
                    CURRENCY_CODE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    LAST_UPDATE_LOGIN,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                  FROM
                    CE_INTRA_STMT_HEADERS CSH
                  WHERE CSH.BANK_ACCOUNT_ID IN (
                    SELECT
                      ABA.BANK_ACCOUNT_ID
                    FROM
                      CE_BANK_ACCOUNTS ABA
                    WHERE ABA.BANK_BRANCH_ID = P_BANK_BRANCH )
                    AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                     ,TRUNC(CSH.STATEMENT_DATE))
                    AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                     ,TRUNC(CSH.STATEMENT_DATE));
                C_ARCHIVE_STAT_HEADERS2 := SQL%ROWCOUNT;
              ELSE
                INSERT INTO CE_ARCH_INTRA_HEADERS
                  (STATEMENT_COMPLETE_FLAG
                  ,DOC_SEQUENCE_ID
                  ,DOC_SEQUENCE_VALUE
                  ,STATEMENT_HEADER_ID
                  ,BANK_ACCOUNT_ID
                  ,STATEMENT_NUMBER
                  ,STATEMENT_DATE
                  ,AUTO_LOADED_FLAG
                  ,GL_DATE
                  ,CHECK_DIGITS
                  ,CONTROL_BEGIN_BALANCE
                  ,CONTROL_TOTAL_DR
                  ,CONTROL_TOTAL_CR
                  ,CONTROL_END_BALANCE
                  ,CASHFLOW_BALANCE
                  ,INT_CALC_BALANCE
                  ,ONE_DAY_FLOAT
                  ,TWO_DAY_FLOAT
                  ,CONTROL_DR_LINE_COUNT
                  ,CONTROL_CR_LINE_COUNT
                  ,CURRENCY_CODE
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15
                  ,LAST_UPDATE_LOGIN
                  ,CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE)
                  SELECT
                    STATEMENT_COMPLETE_FLAG,
                    DOC_SEQUENCE_ID,
                    DOC_SEQUENCE_VALUE,
                    STATEMENT_HEADER_ID,
                    BANK_ACCOUNT_ID,
                    STATEMENT_NUMBER,
                    STATEMENT_DATE,
                    AUTO_LOADED_FLAG,
                    GL_DATE,
                    CHECK_DIGITS,
                    CONTROL_BEGIN_BALANCE,
                    CONTROL_TOTAL_DR,
                    CONTROL_TOTAL_CR,
                    CONTROL_END_BALANCE,
                    CASHFLOW_BALANCE,
                    INT_CALC_BALANCE,
                    ONE_DAY_FLOAT,
                    TWO_DAY_FLOAT,
                    CONTROL_DR_LINE_COUNT,
                    CONTROL_CR_LINE_COUNT,
                    CURRENCY_CODE,
                    ATTRIBUTE_CATEGORY,
                    ATTRIBUTE1,
                    ATTRIBUTE2,
                    ATTRIBUTE3,
                    ATTRIBUTE4,
                    ATTRIBUTE5,
                    ATTRIBUTE6,
                    ATTRIBUTE7,
                    ATTRIBUTE8,
                    ATTRIBUTE9,
                    ATTRIBUTE10,
                    ATTRIBUTE11,
                    ATTRIBUTE12,
                    ATTRIBUTE13,
                    ATTRIBUTE14,
                    ATTRIBUTE15,
                    LAST_UPDATE_LOGIN,
                    CREATED_BY,
                    CREATION_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_DATE
                  FROM
                    CE_INTRA_STMT_HEADERS CSH
                  WHERE TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                     ,TRUNC(CSH.STATEMENT_DATE))
                    AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                     ,TRUNC(CSH.STATEMENT_DATE));
                C_ARCHIVE_STAT_HEADERS2 := SQL%ROWCOUNT;
              END IF;
              INSERT INTO CE_ARCH_INTRA_LINES
                (STATEMENT_LINE_ID
                ,STATEMENT_HEADER_ID
                ,LINE_NUMBER
                ,TRX_DATE
                ,TRX_TYPE
                ,AMOUNT
                ,CHARGES_AMOUNT
                ,STATUS
                ,TRX_CODE_ID
                ,EFFECTIVE_DATE
                ,BANK_TRX_NUMBER
                ,TRX_TEXT
                ,CUSTOMER_TEXT
                ,INVOICE_TEXT
                ,CURRENCY_CODE
                ,EXCHANGE_RATE_TYPE
                ,EXCHANGE_RATE
                ,EXCHANGE_RATE_DATE
                ,ORIGINAL_AMOUNT
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,LAST_UPDATE_LOGIN
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,RECONCILE_TO_STATEMENT_FLAG)
                SELECT
                  STATEMENT_LINE_ID,
                  STATEMENT_HEADER_ID,
                  LINE_NUMBER,
                  TRX_DATE,
                  TRX_TYPE,
                  AMOUNT,
                  CHARGES_AMOUNT,
                  STATUS,
                  TRX_CODE_ID,
                  EFFECTIVE_DATE,
                  BANK_TRX_NUMBER,
                  TRX_TEXT,
                  CUSTOMER_TEXT,
                  INVOICE_TEXT,
                  CURRENCY_CODE,
                  EXCHANGE_RATE_TYPE,
                  EXCHANGE_RATE,
                  EXCHANGE_RATE_DATE,
                  ORIGINAL_AMOUNT,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15,
                  LAST_UPDATE_LOGIN,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  RECONCILE_TO_STATEMENT_FLAG
                FROM
                  CE_INTRA_STMT_LINES
                WHERE STATEMENT_HEADER_ID IN (
                  SELECT
                    STATEMENT_HEADER_ID
                  FROM
                    CE_ARCH_INTRA_HEADERS );
              C_ARCHIVE_STAT_LINES2 := SQL%ROWCOUNT;
            END IF;
            OPEN C_PURGE_INTRA_HEADERS;
            FETCH C_PURGE_INTRA_HEADERS
             INTO
               X_HEADER_ID;
            PURGE_HEADERS := 0;
            PURGE_LINES := 0;
            LOOP
              EXIT WHEN C_PURGE_INTRA_HEADERS%NOTFOUND;
              DELETE FROM CE_INTRA_STMT_HEADERS
               WHERE STATEMENT_HEADER_ID = X_HEADER_ID;
              PURGE_HEADERS := PURGE_HEADERS + SQL%ROWCOUNT;
              OPEN C_PURGE_INTRA_LINES;
              FETCH C_PURGE_INTRA_LINES
               INTO
                 X_LINE_ID;
              LOOP
                EXIT WHEN C_PURGE_INTRA_LINES%NOTFOUND;
                DELETE FROM CE_INTRA_STMT_LINES
                 WHERE STATEMENT_HEADER_ID = X_HEADER_ID;
                PURGE_LINES := PURGE_LINES + SQL%ROWCOUNT;
                FETCH C_PURGE_INTRA_LINES
                 INTO
                   X_LINE_ID;
              END LOOP;
              CLOSE C_PURGE_INTRA_LINES;
              FETCH C_PURGE_INTRA_HEADERS
               INTO
                 X_HEADER_ID;
            END LOOP;
            CLOSE C_PURGE_INTRA_HEADERS;
            C_PURGE_STAT_LINES2 := PURGE_LINES;
            C_PURGE_STAT_HEADERS2 := PURGE_HEADERS;
          END IF;
          IF (P_OBJECTS in ('BOTH','INTERFACE')) THEN
            IF (P_OPTION = 'BOTH') THEN
              INSERT INTO CE_ARCH_INTERFACE_HEADERS
                (STATEMENT_NUMBER
                ,BANK_ACCOUNT_NUM
                ,STATEMENT_DATE
                ,BANK_NAME
                ,BANK_BRANCH_NAME
                ,CHECK_DIGITS
                ,CONTROL_BEGIN_BALANCE
                ,CONTROL_TOTAL_DR
                ,CONTROL_TOTAL_CR
                ,CONTROL_END_BALANCE
                ,CASHFLOW_BALANCE
                ,INT_CALC_BALANCE
                ,ONE_DAY_FLOAT
                ,TWO_DAY_FLOAT
                ,CONTROL_DR_LINE_COUNT
                ,CONTROL_CR_LINE_COUNT
                ,CONTROL_LINE_COUNT
                ,RECORD_STATUS_FLAG
                ,CURRENCY_CODE
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,INTRA_DAY_FLAG)
                SELECT
                  STATEMENT_NUMBER,
                  BANK_ACCOUNT_NUM,
                  STATEMENT_DATE,
                  BANK_NAME,
                  BANK_BRANCH_NAME,
                  CHECK_DIGITS,
                  CONTROL_BEGIN_BALANCE,
                  CONTROL_TOTAL_DR,
                  CONTROL_TOTAL_CR,
                  CONTROL_END_BALANCE,
                  CASHFLOW_BALANCE,
                  INT_CALC_BALANCE,
                  ONE_DAY_FLOAT,
                  TWO_DAY_FLOAT,
                  CONTROL_DR_LINE_COUNT,
                  CONTROL_CR_LINE_COUNT,
                  CONTROL_LINE_COUNT,
                  RECORD_STATUS_FLAG,
                  CURRENCY_CODE,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  INTRA_DAY_FLAG
                FROM
                  CE_STATEMENT_HEADERS_INT CSH
                WHERE NVL(CSH.BANK_BRANCH_NAME
                   ,C_BANK_BRANCH_NAME) IN (
                  SELECT
                    BB.BANK_BRANCH_NAME
                  FROM
                    CE_BANK_BRANCHES_V BB,
                    CE_BANK_ACCTS_GT_V BA
                  WHERE BB.BRANCH_PARTY_ID = BA.BANK_BRANCH_ID
                    AND BA.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                     ,BA.BANK_ACCOUNT_ID)
                    AND BB.BRANCH_PARTY_ID = NVL(P_BANK_BRANCH
                     ,BB.BRANCH_PARTY_ID) )
                  AND CSH.BANK_ACCOUNT_NUM IN (
                  SELECT
                    BANK_ACCOUNT_NUM
                  FROM
                    CE_BANK_ACCTS_GT_V
                  WHERE BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                     ,BANK_ACCOUNT_ID)
                    AND BANK_BRANCH_ID = NVL(P_BANK_BRANCH
                     ,BANK_BRANCH_ID) )
                  AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                   ,TRUNC(CSH.STATEMENT_DATE))
                  AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                   ,TRUNC(CSH.STATEMENT_DATE))
                  AND CSH.RECORD_STATUS_FLAG in ( DECODE(P_HDR_INT_STATUS
                      ,'C'
                      ,'C'
                      ,'E'
                      ,'E'
                      ,'N'
                      ,'N'
                      ,'T'
                      ,'T'
                      ,'A'
                      ,RECORD_STATUS_FLAG
                      ,'T') )
                  AND CSH.INTRA_DAY_FLAG = 'Y';
              C_ARCHIVE_INF_HEADERS2 := SQL%ROWCOUNT;
              INSERT INTO CE_ARCH_INTERFACE_LINES
                (EXCHANGE_RATE_DATE
                ,EXCHANGE_RATE
                ,BANK_TRX_NUMBER
                ,CUSTOMER_TEXT
                ,CREATED_BY
                ,CREATION_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_DATE
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,ORIGINAL_AMOUNT
                ,BANK_ACCOUNT_NUM
                ,STATEMENT_NUMBER
                ,LINE_NUMBER
                ,TRX_DATE
                ,TRX_CODE
                ,EFFECTIVE_DATE
                ,TRX_TEXT
                ,INVOICE_TEXT
                ,AMOUNT
                ,CHARGES_AMOUNT
                ,CURRENCY_CODE
                ,USER_EXCHANGE_RATE_TYPE)
                SELECT
                  EXCHANGE_RATE_DATE,
                  EXCHANGE_RATE,
                  BANK_TRX_NUMBER,
                  CUSTOMER_TEXT,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  ATTRIBUTE_CATEGORY,
                  ATTRIBUTE1,
                  ATTRIBUTE2,
                  ATTRIBUTE3,
                  ATTRIBUTE4,
                  ATTRIBUTE5,
                  ATTRIBUTE6,
                  ATTRIBUTE7,
                  ATTRIBUTE8,
                  ATTRIBUTE9,
                  ATTRIBUTE10,
                  ATTRIBUTE11,
                  ATTRIBUTE12,
                  ATTRIBUTE13,
                  ATTRIBUTE14,
                  ATTRIBUTE15,
                  ORIGINAL_AMOUNT,
                  BANK_ACCOUNT_NUM,
                  STATEMENT_NUMBER,
                  LINE_NUMBER,
                  TRX_DATE,
                  TRX_CODE,
                  EFFECTIVE_DATE,
                  TRX_TEXT,
                  INVOICE_TEXT,
                  AMOUNT,
                  CHARGES_AMOUNT,
                  CURRENCY_CODE,
                  USER_EXCHANGE_RATE_TYPE
                FROM
                  CE_STATEMENT_LINES_INTERFACE CSL
                WHERE CSL.BANK_ACCOUNT_NUM IN (
                  SELECT
                    BANK_ACCOUNT_NUM
                  FROM
                    CE_ARCH_INTERFACE_HEADERS )
                  AND STATEMENT_NUMBER IN (
                  SELECT
                    STATEMENT_NUMBER
                  FROM
                    CE_ARCH_INTERFACE_HEADERS
                  WHERE CSL.BANK_ACCOUNT_NUM = BANK_ACCOUNT_NUM
                    AND INTRA_DAY_FLAG = 'Y' );
              C_ARCHIVE_INF_LINES2 := SQL%ROWCOUNT;
            END IF;
            DELETE FROM CE_STATEMENT_LINES_INTERFACE CSL
             WHERE CSL.STATEMENT_NUMBER || '-' || CSL.BANK_ACCOUNT_NUM IN (
               SELECT
                 CSH.STATEMENT_NUMBER || '-' || CSH.BANK_ACCOUNT_NUM
               FROM
                 CE_STATEMENT_HEADERS_INT CSH
               WHERE NVL(CSH.BANK_BRANCH_NAME
                  ,C_BANK_BRANCH_NAME) IN (
                 SELECT
                   BB.BANK_BRANCH_NAME
                 FROM
                   CE_BANK_BRANCHES_V BB,
                   CE_BANK_ACCTS_GT_V BA
                 WHERE BB.BRANCH_PARTY_ID = BA.BANK_BRANCH_ID
                   AND BA.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                    ,BA.BANK_ACCOUNT_ID)
                   AND BB.BRANCH_PARTY_ID = NVL(P_BANK_BRANCH
                    ,BB.BRANCH_PARTY_ID) )
                 AND CSH.BANK_ACCOUNT_NUM IN (
                 SELECT
                   BANK_ACCOUNT_NUM
                 FROM
                   CE_BANK_ACCTS_GT_V
                 WHERE BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                    ,BANK_ACCOUNT_ID)
                   AND BANK_BRANCH_ID = NVL(P_BANK_BRANCH
                    ,BANK_BRANCH_ID) )
                 AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                  ,TRUNC(CSH.STATEMENT_DATE))
                 AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                  ,TRUNC(CSH.STATEMENT_DATE))
                 AND CSH.RECORD_STATUS_FLAG in ( DECODE(P_HDR_INT_STATUS
                     ,'C'
                     ,'C'
                     ,'E'
                     ,'E'
                     ,'N'
                     ,'N'
                     ,'T'
                     ,'T'
                     ,'A'
                     ,RECORD_STATUS_FLAG
                     ,'T') )
                 AND CSH.INTRA_DAY_FLAG = 'Y' );
            C_PURGE_INF_LINES2 := SQL%ROWCOUNT;
            DELETE FROM CE_STATEMENT_HEADERS_INT CSH
             WHERE NVL(CSH.BANK_BRANCH_NAME
                ,C_BANK_BRANCH_NAME) IN (
               SELECT
                 BB.BANK_BRANCH_NAME
               FROM
                 CE_BANK_BRANCHES_V BB,
                 CE_BANK_ACCTS_GT_V BA
               WHERE BB.BRANCH_PARTY_ID = BA.BANK_BRANCH_ID
                 AND BA.BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                  ,BA.BANK_ACCOUNT_ID)
                 AND BB.BRANCH_PARTY_ID = NVL(P_BANK_BRANCH
                  ,BB.BRANCH_PARTY_ID) )
               AND CSH.BANK_ACCOUNT_NUM IN (
               SELECT
                 BANK_ACCOUNT_NUM
               FROM
                 CE_BANK_ACCTS_GT_V
               WHERE BANK_ACCOUNT_ID = NVL(P_BANK_ACCOUNT
                  ,BANK_ACCOUNT_ID)
                 AND BANK_BRANCH_ID = NVL(P_BANK_BRANCH
                  ,BANK_BRANCH_ID) )
               AND TRUNC(CSH.STATEMENT_DATE) >= NVL(P_STATEMENT_DATE_FROM
                ,TRUNC(CSH.STATEMENT_DATE))
               AND TRUNC(CSH.STATEMENT_DATE) <= NVL(P_STATEMENT_DATE_TO1
                ,TRUNC(CSH.STATEMENT_DATE))
               AND CSH.RECORD_STATUS_FLAG in ( DECODE(P_HDR_INT_STATUS
                   ,'C'
                   ,'C'
                   ,'E'
                   ,'E'
                   ,'N'
                   ,'N'
                   ,'T'
                   ,'T'
                   ,'A'
                   ,RECORD_STATUS_FLAG
                   ,'T') )
               AND CSH.INTRA_DAY_FLAG = 'Y';
            C_PURGE_INF_HEADERS2 := SQL%ROWCOUNT;
          END IF;
        END IF;
        COMMIT;
      ELSE
        L_MESSAGE := GET;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_DATEFORMATFORMULA(C_DATEFORMAT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (C_DATEFORMAT);
  END C_DATEFORMATFORMULA;

  FUNCTION C_ARCHIVE_INF_HEADERS_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_INF_HEADERS;
  END C_ARCHIVE_INF_HEADERS_P;

  FUNCTION C_ARCHIVE_INF_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_INF_LINES;
  END C_ARCHIVE_INF_LINES_P;

  FUNCTION C_ARCHIVE_STAT_HEADERS_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_STAT_HEADERS;
  END C_ARCHIVE_STAT_HEADERS_P;

  FUNCTION C_ARCHIVE_STAT_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_STAT_LINES;
  END C_ARCHIVE_STAT_LINES_P;

  FUNCTION C_ARCHIVE_STAT_REC_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_STAT_REC;
  END C_ARCHIVE_STAT_REC_P;

  FUNCTION C_ARCHIVE_STAT_ERRORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_STAT_ERRORS;
  END C_ARCHIVE_STAT_ERRORS_P;

  FUNCTION C_PURGE_INF_HEADERS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_INF_HEADERS;
  END C_PURGE_INF_HEADERS_P;

  FUNCTION C_PURGE_INF_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_INF_LINES;
  END C_PURGE_INF_LINES_P;

  FUNCTION C_PURGE_STAT_HEADERS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_STAT_HEADERS;
  END C_PURGE_STAT_HEADERS_P;

  FUNCTION C_PURGE_STAT_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_STAT_LINES;
  END C_PURGE_STAT_LINES_P;

  FUNCTION C_PURGE_STAT_REC_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_STAT_REC;
  END C_PURGE_STAT_REC_P;

  FUNCTION C_PURGE_STAT_ERRORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_STAT_ERRORS;
  END C_PURGE_STAT_ERRORS_P;

  FUNCTION C_BANK_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_NAME;
  END C_BANK_NAME_P;

  FUNCTION C_BANK_BRANCH_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_BRANCH_NAME;
  END C_BANK_BRANCH_NAME_P;

  FUNCTION C_BANK_ACCOUNT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_ACCOUNT_NAME;
  END C_BANK_ACCOUNT_NAME_P;

  FUNCTION C_BANK_ACCOUNT_NUM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_ACCOUNT_NUM;
  END C_BANK_ACCOUNT_NUM_P;

  FUNCTION C_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CURRENCY_CODE;
  END C_CURRENCY_CODE_P;

  FUNCTION C_SET_OF_BOOK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SET_OF_BOOK;
  END C_SET_OF_BOOK_P;

  FUNCTION C_ALL_TRANSLATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ALL_TRANSLATION;
  END C_ALL_TRANSLATION_P;

  FUNCTION C_ARCHIVE_INF_HEADERS2_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_INF_HEADERS2;
  END C_ARCHIVE_INF_HEADERS2_P;

  FUNCTION C_ARCHIVE_INF_LINES2_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_INF_LINES2;
  END C_ARCHIVE_INF_LINES2_P;

  FUNCTION C_ARCHIVE_STAT_HEADERS2_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_STAT_HEADERS2;
  END C_ARCHIVE_STAT_HEADERS2_P;

  FUNCTION C_ARCHIVE_STAT_LINES2_P RETURN NUMBER IS
  BEGIN
    RETURN C_ARCHIVE_STAT_LINES2;
  END C_ARCHIVE_STAT_LINES2_P;

  FUNCTION C_PURGE_INF_HEADERS2_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_INF_HEADERS2;
  END C_PURGE_INF_HEADERS2_P;

  FUNCTION C_PURGE_INF_LINES2_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_INF_LINES2;
  END C_PURGE_INF_LINES2_P;

  FUNCTION C_PURGE_STAT_HEADERS2_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_STAT_HEADERS2;
  END C_PURGE_STAT_HEADERS2_P;

  FUNCTION C_PURGE_STAT_LINES2_P RETURN NUMBER IS
  BEGIN
    RETURN C_PURGE_STAT_LINES2;
  END C_PURGE_STAT_LINES2_P;

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.SET_NAME(:APPLICATION, :NAME); end;');
    STPROC.BIND_I(APPLICATION);
    STPROC.BIND_I(NAME);
    STPROC.EXECUTE;*/
FND_MESSAGE.SET_NAME(APPLICATION, NAME);
  END SET_NAME;

  PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN number) IS
  BEGIN
  declare
TRANSLATE_1 BOOLEAN;
   /* STPROC.INIT('declare TRANSLATE BOOLEAN; begin TRANSLATE := sys.diutil.int_to_bool(:TRANSLATE); FND_MESSAGE.SET_TOKEN(:TOKEN, :VALUE, TRANSLATE); end;');
    STPROC.BIND_I(TRANSLATE);
    STPROC.BIND_I(TOKEN);
    STPROC.BIND_I(VALUE);
    STPROC.EXECUTE;*/
begin
TRANSLATE_1 := sys.diutil.int_to_bool(TRANSLATE);
end;
  END SET_TOKEN;

  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin FND_MESSAGE.RETRIEVE(:MSGOUT); end;');
    STPROC.BIND_O(MSGOUT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,MSGOUT);*/
FND_MESSAGE.RETRIEVE(MSGOUT);
  END RETRIEVE;

  PROCEDURE CLEAR IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.CLEAR; end;');
    STPROC.EXECUTE;*/
FND_MESSAGE.CLEAR;
  END CLEAR;

  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := FND_MESSAGE.GET_STRING(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
X0 := FND_MESSAGE.GET_STRING(APPIN, NAMEIN);
    RETURN X0;
  END GET_STRING;

  FUNCTION GET_NUMBER(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_MESSAGE.GET_NUMBER(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
X0 := FND_MESSAGE.GET_NUMBER(APPIN, NAMEIN);
    RETURN X0;
  END GET_NUMBER;

  FUNCTION GET RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := FND_MESSAGE.GET; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
X0 := FND_MESSAGE.GET;
    RETURN X0;
  END GET;

  FUNCTION GET_ENCODED RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_MESSAGE.GET_ENCODED; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
X0 := FND_MESSAGE.GET_ENCODED;
    RETURN X0;
  END GET_ENCODED;

  PROCEDURE PARSE_ENCODED(ENCODED_MESSAGE IN VARCHAR2
                         ,APP_SHORT_NAME OUT NOCOPY VARCHAR2
                         ,MESSAGE_NAME OUT NOCOPY VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.PARSE_ENCODED(:ENCODED_MESSAGE, :APP_SHORT_NAME, :MESSAGE_NAME); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.BIND_O(APP_SHORT_NAME);
    STPROC.BIND_O(MESSAGE_NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,APP_SHORT_NAME);
    STPROC.RETRIEVE(3
                   ,MESSAGE_NAME);*/
FND_MESSAGE.PARSE_ENCODED(ENCODED_MESSAGE, APP_SHORT_NAME, MESSAGE_NAME);
  END PARSE_ENCODED;

  PROCEDURE SET_ENCODED(ENCODED_MESSAGE IN VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.SET_ENCODED(:ENCODED_MESSAGE); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.EXECUTE;*/
FND_MESSAGE.SET_ENCODED(ENCODED_MESSAGE);
  END SET_ENCODED;

  PROCEDURE RAISE_ERROR IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.RAISE_ERROR; end;');
    STPROC.EXECUTE;*/
FND_MESSAGE.RAISE_ERROR;
  END RAISE_ERROR;

  PROCEDURE DEBUG(LINE IN VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin CEP_STANDARD.DEBUG(:LINE); end;');
    STPROC.BIND_I(LINE);
    STPROC.EXECUTE;*/
CEP_STANDARD.DEBUG(LINE);
  END DEBUG;

  PROCEDURE ENABLE_DEBUG IS
  BEGIN
   /* STPROC.INIT('begin CEP_STANDARD.ENABLE_DEBUG; end;');
    STPROC.EXECUTE;*/
CEP_STANDARD.ENABLE_DEBUG;

  END ENABLE_DEBUG;

  PROCEDURE DISABLE_DEBUG IS
  BEGIN
    /*STPROC.INIT('begin CEP_STANDARD.DISABLE_DEBUG; end;');
    STPROC.EXECUTE;*/
--CEP_STANDARD.DISABLE_DEBUG;
null;
  END DISABLE_DEBUG;

  FUNCTION GET_WINDOW_SESSION_TITLE(P_ORG_ID IN NUMBER := NULL
                                   ,P_LEGAL_ENTITY_ID IN NUMBER := NULL) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := CEP_STANDARD.GET_WINDOW_SESSION_TITLE(p_org_id, p_legal_entity_id ); end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
X0 := CEP_STANDARD.GET_WINDOW_SESSION_TITLE(p_org_id, p_legal_entity_id );
    RETURN X0;
  END GET_WINDOW_SESSION_TITLE;

  FUNCTION GET_EFFECTIVE_DATE(P_BANK_ACCOUNT_ID IN NUMBER
                             ,P_TRX_CODE IN VARCHAR2
                             ,P_RECEIPT_DATE IN DATE) RETURN DATE IS
    X0 DATE;
  BEGIN
   /* STPROC.INIT('begin :X0 := CEP_STANDARD.GET_EFFECTIVE_DATE(:P_BANK_ACCOUNT_ID, :P_TRX_CODE, :P_RECEIPT_DATE);end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BANK_ACCOUNT_ID);
    STPROC.BIND_I(P_TRX_CODE);
    STPROC.BIND_I(P_RECEIPT_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
X0 := CEP_STANDARD.GET_EFFECTIVE_DATE(P_BANK_ACCOUNT_ID, P_TRX_CODE, P_RECEIPT_DATE);
    RETURN X0;
  END GET_EFFECTIVE_DATE;

  PROCEDURE INIT_SECURITY IS
  BEGIN
   /* STPROC.INIT('begin cep_standard.init_security; end;');
    STPROC.EXECUTE;*/
cep_standard.init_security;
  END INIT_SECURITY;

END CE_CEPURGE_XMLP_PKG;

/
