--------------------------------------------------------
--  DDL for Package Body IGI_CIS_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS_UPGRADE_PKG" AS
-- $Header: igipupgb.pls 120.0.12000000.2 2007/07/24 10:07:55 vensubra noship $

    Procedure MIGRATE_DATA(p_errbuff OUT NOCOPY VARCHAR2,p_retcode OUT NOCOPY NUMBER)
    is

        CURSOR C_UPDATE IS
            SELECT
                DISTINCT AATR.VENDOR_ID
            FROM
                AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
            WHERE
                --TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE, SYSDATE)) bug 5620412
                --AND TRUNC(NVL(END_DATE, SYSDATE)) bug 5620412
                --AND bug 5620412
		AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS4T', 'CIS4TF', 'CIS5', 'CIS5F', 'CIS6', 'CIS6F')
        AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);

        C_REC_INFO C_UPDATE%ROWTYPE;

        TEMP_NI_NUMBER          VARCHAR2 (30);
        TEMP_COUNT              NUMBER;
        TEMP_COUNT2             NUMBER;
        TEMP_UTR_NO             VARCHAR2 (10);
        TEMP_VENDOR_NAME        VARCHAR2 (240);
        TEMP_VENDOR_TYPE        VARCHAR2 (30);

    BEGIN

        For C_REC_INFO in C_UPDATE LOOP

            TEMP_NI_NUMBER := NULL;
            TEMP_UTR_NO := 0;
            TEMP_COUNT := 0;
            TEMP_COUNT2 := 0;
            TEMP_VENDOR_NAME := NULL;
            TEMP_VENDOR_TYPE := NULL;

            SELECT
                VENDOR_NAME,VENDOR_TYPE_LOOKUP_CODE
                INTO TEMP_VENDOR_NAME,TEMP_VENDOR_TYPE
            FROM
                AP_SUPPLIERS
            WHERE
                VENDOR_ID = C_REC_INFO.VENDOR_ID;

            FND_MESSAGE.SET_NAME('IGI','IGI_CIS2007_UPG_VENDOR_DET');
            FND_MESSAGE.SET_TOKEN('VENDOR_ID', C_REC_INFO.VENDOR_ID);
            FND_MESSAGE.SET_TOKEN('VENDOR_NAME', TEMP_VENDOR_NAME);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, FND_MESSAGE.GET);

            -- ===== UPDATING CIS ENABLED FLAG ====

            UPDATE AP_SUPPLIERS
                 SET CIS_ENABLED_FLAG = 'Y'
            WHERE
                VENDOR_ID = C_REC_INFO.VENDOR_ID;
            IF SQL%FOUND THEN
                WRITE_REPORT('IGI_CIS2007_UPG_CIS_FLAG');
            END IF;

            -- ===== UPDATING NATIONAL INSURANCE NUMBER ====
            BEGIN
                SELECT
                    COUNT(DISTINCT(ICCNN.NI_NUMBER)) INTO TEMP_COUNT
                FROM
                    AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
                WHERE
                    AATR.VENDOR_ID = C_REC_INFO.VENDOR_ID
                    AND AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS6', 'CIS6F')
                    -- AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE, SYSDATE))
                    -- AND TRUNC(NVL(END_DATE, SYSDATE))
                    -- Bug 5620412
                    AND ICCNN.NI_NUMBER IS NOT NULL
                    AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);
            EXCEPTION
                When NO_DATA_FOUND THEN
                    TEMP_COUNT:=0;
            END;

            IF TEMP_COUNT = 0 THEN
                WRITE_REPORT('IGI_CIS2007_UPG_NO_NINO');
            ELSIF TEMP_COUNT > 1 THEN
                -- If there are multiple certificates, then determine which
                -- certificate is active and use the NI Number from that certificate
                BEGIN
                    SELECT
                        COUNT(DISTINCT(ICCNN.NI_NUMBER)) INTO TEMP_COUNT2
                    FROM
                        AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
                    WHERE
                        AATR.VENDOR_ID = C_REC_INFO.VENDOR_ID
                        AND AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS6', 'CIS6F')
                        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(AATR.START_DATE, SYSDATE))
                        AND TRUNC(NVL(AATR.END_DATE, SYSDATE))
                        AND ICCNN.NI_NUMBER IS NOT NULL
                        AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);
                EXCEPTION
                    When NO_DATA_FOUND THEN
                        TEMP_COUNT2:=0;
                END;

                IF TEMP_COUNT2 = 0 THEN
                    WRITE_REPORT('IGI_CIS2007_UPG_NO_NINO');
                ELSIF TEMP_COUNT2 > 1 THEN
                    --There are multiple active certificates
                    WRITE_REPORT('IGI_CIS2007_UPG_MULTIPLE_NINO');
                ELSE
                    --Use the NI Number present in the Active Certificate
                    SELECT
                        DISTINCT (ICCNN.NI_NUMBER) INTO TEMP_NI_NUMBER
                    FROM
                        AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
                    WHERE
                        AATR.VENDOR_ID = C_REC_INFO.VENDOR_ID
                        AND AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS6', 'CIS6F')
                        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(AATR.START_DATE, SYSDATE))
                        AND TRUNC(NVL(AATR.END_DATE, SYSDATE))
                        AND ICCNN.NI_NUMBER IS NOT NULL
                        AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);

                    IF IGI_CIS_UPGRADE_PKG.IGI_CIS_VALIDATE_NI_NUMBER (TEMP_NI_NUMBER) THEN
                        UPDATE AP_SUPPLIERS
                            SET NATIONAL_INSURANCE_NUMBER = TEMP_NI_NUMBER
                        WHERE
                            VENDOR_ID = C_REC_INFO.VENDOR_ID;

                        IF SQL%FOUND THEN
                           WRITE_REPORT('IGI_CIS2007_UPG_NINO');
                        END IF;
                    ELSE
                        WRITE_REPORT('IGI_CIS2007_UPG_INVALID_NINO');
                    END IF;
                END IF;
            ELSE
                SELECT
                    DISTINCT (ICCNN.NI_NUMBER) INTO TEMP_NI_NUMBER
                FROM
                    AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
                WHERE
                    AATR.VENDOR_ID = C_REC_INFO.VENDOR_ID
                    AND AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS6', 'CIS6F')
                    -- AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE, SYSDATE))
                    -- AND TRUNC(NVL(END_DATE, SYSDATE))
                    -- Bug 5620412
                    AND ICCNN.NI_NUMBER IS NOT NULL
                    AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);

                IF IGI_CIS_UPGRADE_PKG.IGI_CIS_VALIDATE_NI_NUMBER (TEMP_NI_NUMBER) THEN
                    UPDATE AP_SUPPLIERS
                        SET NATIONAL_INSURANCE_NUMBER = TEMP_NI_NUMBER
                    WHERE
                        VENDOR_ID = C_REC_INFO.VENDOR_ID;

                    IF SQL%FOUND THEN
                       WRITE_REPORT('IGI_CIS2007_UPG_NINO');
                    END IF;
                ELSE
                    WRITE_REPORT('IGI_CIS2007_UPG_INVALID_NINO');
                END IF;
            END IF;

            -- ==== UPDATING UNIQUE TAX REFERENCE NUMBER ===

            TEMP_COUNT := 0;
            TEMP_COUNT2 := 0;

            BEGIN
                SELECT
                    COUNT(DISTINCT(SUBSTR (AATR.CERTIFICATE_NUMBER, 1,10))) INTO TEMP_COUNT
                FROM
                    AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
                WHERE
                    AATR.VENDOR_ID = C_REC_INFO.VENDOR_ID
                    AND AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS4T', 'CIS4TF', 'CIS5', 'CIS5F', 'CIS6', 'CIS6F')
                    --AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE, SYSDATE))  bug 5620412
                    --AND TRUNC(NVL(END_DATE, SYSDATE))  bug 5620412
                    AND AATR.CERTIFICATE_NUMBER IS NOT NULL
                    AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);
            EXCEPTION
                When NO_DATA_FOUND THEN
                    TEMP_COUNT:=0;
            END;

            IF TEMP_COUNT = 0 THEN
                WRITE_REPORT('IGI_CIS2007_UPG_NO_UTR');
            ELSIF TEMP_COUNT > 1 THEN
                -- If there are multiple certificates, then determine which
                -- certificate is active and use the UTR from that certificate
                BEGIN
                    SELECT
                        COUNT(DISTINCT(SUBSTR (AATR.CERTIFICATE_NUMBER, 1,10))) INTO TEMP_COUNT2
                    FROM
                        AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
                    WHERE
                        AATR.VENDOR_ID = C_REC_INFO.VENDOR_ID
                        AND AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS4T', 'CIS4TF', 'CIS5', 'CIS5F', 'CIS6', 'CIS6F')
                        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE, SYSDATE))
                        AND TRUNC(NVL(END_DATE, SYSDATE))
                        AND AATR.CERTIFICATE_NUMBER IS NOT NULL
                        AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);
                EXCEPTION
                    When NO_DATA_FOUND THEN
                        TEMP_COUNT2:=0;
                END;
                IF TEMP_COUNT2 = 0 THEN
                    WRITE_REPORT('IGI_CIS2007_UPG_NO_UTR');
                ELSIF TEMP_COUNT2 > 1 THEN
                    --There are multiple active certificates
                    WRITE_REPORT('IGI_CIS2007_UPG_MULTIPLE_UTR');
                ELSE
                    --Use the UTR present in the Active Certificate
                    SELECT
                        DISTINCT(SUBSTR (AATR.CERTIFICATE_NUMBER, 1,10)) INTO TEMP_UTR_NO
                    FROM
                        AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
                    WHERE
                        AATR.VENDOR_ID = C_REC_INFO.VENDOR_ID
                        AND AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS4T', 'CIS4TF', 'CIS5', 'CIS5F', 'CIS6', 'CIS6F')
                        AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(AATR.START_DATE, SYSDATE))
                        AND TRUNC(NVL(AATR.END_DATE, SYSDATE))
                        AND AATR.CERTIFICATE_NUMBER IS NOT NULL
                        AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);

                    IF IGI_CIS_VALIDATE_UTR (TEMP_UTR_NO) THEN

                        IF TEMP_VENDOR_TYPE = 'PARTNERSHIP' THEN
                            UPDATE AP_SUPPLIERS
                            SET PARTNERSHIP_UTR = TO_NUMBER (TEMP_UTR_NO)
                            WHERE VENDOR_ID = C_REC_INFO.VENDOR_ID;
                        ELSE
                            UPDATE AP_SUPPLIERS
                            SET UNIQUE_TAX_REFERENCE_NUM = TO_NUMBER(TEMP_UTR_NO)
                            WHERE VENDOR_ID = C_REC_INFO.VENDOR_ID;
                        END IF;
                        IF SQL%FOUND THEN
                           WRITE_REPORT('IGI_CIS2007_UPG_UTR');
                        END IF;

                    ELSE
                        WRITE_REPORT('IGI_CIS2007_UPG_INVALID_UTR');
                    END IF;
                END IF;
            ELSE
                SELECT
                    DISTINCT(SUBSTR (AATR.CERTIFICATE_NUMBER, 1,10)) INTO TEMP_UTR_NO
                FROM
                    AP_AWT_TAX_RATES AATR, IGI_CIS_CERT_NI_NUMBERS ICCNN
                WHERE
                    VENDOR_ID = C_REC_INFO.VENDOR_ID
                    AND AATR.CERTIFICATE_TYPE IN ('CIS4P', 'CIS4PF', 'CIS4T', 'CIS4TF', 'CIS5', 'CIS5F', 'CIS6', 'CIS6F')
                    -- AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(START_DATE, SYSDATE)) bug 5620412
                    -- AND TRUNC(NVL(END_DATE, SYSDATE)) bug 5620412
                    AND AATR.CERTIFICATE_NUMBER IS NOT NULL
                    AND AATR.TAX_RATE_ID = ICCNN.TAX_RATE_ID (+);

                IF IGI_CIS_VALIDATE_UTR (TEMP_UTR_NO) THEN

                    IF TEMP_VENDOR_TYPE = 'PARTNERSHIP' THEN
                        UPDATE AP_SUPPLIERS
                        SET PARTNERSHIP_UTR = TO_NUMBER (TEMP_UTR_NO)
                        WHERE VENDOR_ID = C_REC_INFO.VENDOR_ID;
                    ELSE
                        UPDATE AP_SUPPLIERS
                        SET UNIQUE_TAX_REFERENCE_NUM = TO_NUMBER(TEMP_UTR_NO)
                        WHERE VENDOR_ID = C_REC_INFO.VENDOR_ID;
                    END IF;
                    IF SQL%FOUND THEN
                       WRITE_REPORT('IGI_CIS2007_UPG_UTR');
                    END IF;

                ELSE
                    WRITE_REPORT('IGI_CIS2007_UPG_INVALID_UTR');
                END IF;

            END IF;
           FND_FILE.NEW_LINE (FND_FILE.OUTPUT,2);
        END LOOP;

        EXCEPTION
        WHEN OTHERS THEN
           P_RETCODE := 2;
           P_ERRBUFF := 'ERROR MESSAGE: ' || SQLERRM || ' ERROR CODE: ' || TO_CHAR(SQLCODE);

    End MIGRATE_DATA;


    Function IGI_CIS_VALIDATE_NI_NUMBER (P_NINO IN VARCHAR2)
        Return Boolean
    Is
    Begin

        -- =========== Validate the NI Number =================

        IF SUBSTR (P_NINO, 1,1) >= 'A' AND
            SUBSTR (P_NINO, 1,1) <= 'Z' AND
            SUBSTR (P_NINO, 1,1) NOT IN ('D','F','I','Q','U','V') AND
            SUBSTR (P_NINO, 2,1) >= 'A' AND
            SUBSTR (P_NINO, 2,1) <= 'Z' AND
            SUBSTR (P_NINO, 2,1) NOT IN ('D','F','I','O','Q','U','V') AND
            SUBSTR (P_NINO, 3,1) >= '0' AND
            SUBSTR (P_NINO, 3,1) <= '9' AND
            SUBSTR (P_NINO, 4,1) >= '0' AND
            SUBSTR (P_NINO, 4,1) <= '9' AND
            SUBSTR (P_NINO, 5,1) >= '0' AND
            SUBSTR (P_NINO, 5,1) <= '9' AND
            SUBSTR (P_NINO, 6,1) >= '0' AND
            SUBSTR (P_NINO, 6,1) <= '9' AND
            SUBSTR (P_NINO, 7,1) >= '0' AND
            SUBSTR (P_NINO, 7,1) <= '9' AND
            SUBSTR (P_NINO, 8,1) >= '0' AND
            SUBSTR (P_NINO, 8,1) <= '9'
        THEN
        IF LENGTH (P_NINO) = 8 THEN
             Return TRUE;
        ELSIF LENGTH (P_NINO) = 9 AND SUBSTR (P_NINO, 9,1) IN ('A','B','C','D') THEN
                Return TRUE;
            ELSE
                Return FALSE;
            End If;
        ELSE
            Return FALSE;
        END IF;
    END IGI_CIS_VALIDATE_NI_NUMBER;


    Function IGI_CIS_VALIDATE_UTR (P_UTR IN VARCHAR2)
        Return Boolean
    Is
        l_temp          Number;
    Begin

        -- =========== Validate the UTR Number =================

        FOR I in 1.. LENGTH (P_UTR)
        LOOP
            IF SUBSTR (P_UTR, I, 1) >= '0' AND SUBSTR (P_UTR, I, 1) <= '9' THEN
                NULL;
            ELSE
                Return FALSE;
                EXIT;
            END IF;
        END LOOP;

        l_temp := MOD (
                    TO_NUMBER (SUBSTR (P_UTR, 2,1)) * 6 +
                    TO_NUMBER (SUBSTR (P_UTR, 3,1)) * 7 +
                    TO_NUMBER (SUBSTR (P_UTR, 4,1)) * 8 +
                    TO_NUMBER (SUBSTR (P_UTR, 5,1)) * 9 +
                    TO_NUMBER (SUBSTR (P_UTR, 6,1)) * 10 +
                    TO_NUMBER (SUBSTR (P_UTR, 7,1)) * 5 +
                    TO_NUMBER (SUBSTR (P_UTR, 8,1)) * 4 +
                    TO_NUMBER (SUBSTR (P_UTR, 9,1)) * 3 +
                    TO_NUMBER (SUBSTR (P_UTR, 10,1)) * 2
                    , 11);

        l_temp := 11 - l_temp;

        IF l_temp > 9 THEN
            l_temp := l_temp - 9;
        END IF;

        IF l_temp = TO_NUMBER (SUBSTR (P_UTR, 1,1)) THEN
            Return TRUE;
        ELSE
            Return FALSE;
        END IF;

    END IGI_CIS_VALIDATE_UTR;

    PROCEDURE WRITE_REPORT(P_MSG_NAME IN VARCHAR2) IS
    BEGIN
        FND_MESSAGE.SET_NAME('IGI',P_MSG_NAME);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,FND_MESSAGE.GET);
    END WRITE_REPORT;

END IGI_CIS_UPGRADE_PKG;


/
