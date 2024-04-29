--------------------------------------------------------
--  DDL for Procedure XXAH_1SOURCE_AGREEMENT_RPT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_1SOURCE_AGREEMENT_RPT" (
    errbuf    OUT VARCHAR2,
    retcode   OUT NUMBER)
AS
    i                          NUMBER := 1;
    j                          NUMBER := 1;
    p_to                       VARCHAR2 (100) := 'edelman.bart@ah.nl';
    lv_smtp_server             VARCHAR2 (100) := 'vmebsdblpwe01.retail.ah.eu-int-aholddelhaize.com';
    lv_domain                  VARCHAR2 (100);
    lv_from                    VARCHAR2 (100) := 'EBSPROD@ah.nl';
    v_connection               UTL_SMTP.connection;
    c_mime_boundary   CONSTANT VARCHAR2 (256) := '--AAAAA000956--';
    v_clob                     CLOB;
    ln_len                     INTEGER;
    ln_index                   INTEGER;
    ln_count                   NUMBER;
    ln_code                    VARCHAR2 (10);
    ln_counter                 NUMBER := 0;
    lv_instance                VARCHAR2 (100);
    ln_cnt                     NUMBER;
    ld_date                    DATE;
BEGIN
    ld_date := SYSDATE;
    lv_domain := lv_smtp_server;

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

    BEGIN
        v_clob :=
               'AGREEMENT_NUMBER'
            || ';'
            || 'FULL_NAME'
            || ';'
            || 'SUPPLIER_NAME'
            || ';'
            || 'SUPPLIER_NUMBER'
            || ';'
            || 'STATUS_DESCRIPTION'
            || ';'
            || 'CATEGORY'
            || ';'
            || 'SUB_CATEGORY'
            || ';'
            || 'OPERATIN_UNIT_NAME'
            || ';'
            || 'AGREED_AMOUNT'
            || ';'
            || 'START_DATE'
            || ';'
            || 'END_DATE'
            || ';'
            || 'RESULT_TYPE'
            || ';'
            || 'LINE_OPCO'
            || ';'
            || 'YEAR'
            || ';'
            || 'AMOUNT'
            || ';'
            || 'PAYMENT_TERMS_DAYS'
            || ';'
            || 'PAYMENT_PERCENTAGE'
            || ';'
            || 'PEOPLESOFTNUMBER'
            || ';'
            || 'MOTHER_CONTRACT'
            || ';'
            || 'SUP_ACC_DATE'
			|| ';'
            || 'PO_CREATION_DATE'
			|| UTL_TCP.crlf;
        v_connection := UTL_SMTP.open_connection (lv_smtp_server); --To open the connection      UTL_SMTP.helo (v_connection, lv_domain);
        UTL_SMTP.helo (v_connection, lv_smtp_server);
        UTL_SMTP.mail (v_connection, lv_from);
        UTL_SMTP.rcpt (v_connection, p_to); -- To send mail to valid receipent
        UTL_SMTP.open_data (v_connection);
        UTL_SMTP.write_data (v_connection,
                             'From: ' || lv_from || UTL_TCP.crlf);

        IF TRIM (p_to) IS NOT NULL
        THEN
            UTL_SMTP.write_data (v_connection,
                                 'To: ' || p_to || UTL_TCP.crlf);
        END IF;

        UTL_SMTP.write_data (
            v_connection,
            'Subject: XXAH_1SOURCE_AGREEMENT_VW Report' || UTL_TCP.crlf);
        UTL_SMTP.write_data (v_connection,
                             'MIME-Version: 1.0' || UTL_TCP.crlf);
        UTL_SMTP.write_data (
            v_connection,
               'Content-Type: multipart/mixed; boundary="'
            || c_mime_boundary
            || '"'
            || UTL_TCP.crlf);
        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        UTL_SMTP.write_data (
            v_connection,
            'This is a multi-part message in MIME format.' || UTL_TCP.crlf);
        UTL_SMTP.write_data (v_connection,
                             '--' || c_mime_boundary || UTL_TCP.crlf);
        UTL_SMTP.write_data (v_connection,
                             'Content-Type: text/plain' || UTL_TCP.crlf);
        ln_cnt := 1;

        /*Condition to check for the creation of csv attachment*/
        IF (ln_cnt <> 0)
        THEN
            UTL_SMTP.write_data (
                v_connection,
                   'Content-Disposition: attachment; filename="'
                || 'XXAH_1SOURCE_AGREEMENT_VW'
                || TO_CHAR (ld_date, 'dd-mon-rrrr hh:mi')
                || '.csv'
                || '"'
                || UTL_TCP.crlf);
        END IF;

        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);

        FOR i
            IN (SELECT AGREEMENT_NUMBER,
                       FULL_NAME,
                       SUPPLIER_NAME,
                       SUPPLIER_NUMBER,
                       STATUS_DESCRIPTION,
                       CATEGORY,
                       SUB_CATEGORY,
                       OPERATIN_UNIT_NAME,
                       AGREED_AMOUNT,
                       START_DATE,
                       END_DATE,
                       RESULT_TYPE,
                       LINE_OPCO,
                       YEAR,
                       AMOUNT,
                       PAYMENT_TERMS_DAYS,
                       PAYMENT_PERCENTAGE,
                       '"' || PEOPLESOFTNUMBER || '"'     PEOPLESOFTNUMBER,
                       MOTHER_CONTRACT,
                       SUP_ACC_DATE,
					   PO_CREATION_DATE
                  FROM XXAH_1SOURCE_AGREEMENT_VW
                 WHERE TRUNC (TO_DATE (START_DATE, 'yyyy-mm-dd')) >=
                       '01-JAN-2020')
        LOOP
            ln_counter := ln_counter + 1;

            IF ln_counter = 1
            THEN
                UTL_SMTP.write_data (v_connection, v_clob); --To avoid repeation of column heading in csv file
            END IF;

            BEGIN
                v_clob :=
                       '='
                    || i.AGREEMENT_NUMBER
                    || ';'
                    || i.FULL_NAME
                    || ';'
                    || i.SUPPLIER_NAME
                    || ';'
                    || i.SUPPLIER_NUMBER
                    || ';'
                    || i.STATUS_DESCRIPTION
                    || ';'
                    || i.CATEGORY
                    || ';'
                    || i.SUB_CATEGORY
                    || ';'
                    || i.OPERATIN_UNIT_NAME
                    || ';'
                    || i.AGREED_AMOUNT
                    || ';'
                    || i.START_DATE
                    || ';'
                    || i.END_DATE
                    || ';'
                    || i.RESULT_TYPE
                    || ';'
                    || i.LINE_OPCO
                    || ';'
                    || i.YEAR
                    || ';'
                    || i.AMOUNT
                    || ';'
                    || i.PAYMENT_TERMS_DAYS
                    || ';'
                    || i.PAYMENT_PERCENTAGE
                    || ';'
                    || i.PEOPLESOFTNUMBER
                    || ';'
                    || i.MOTHER_CONTRACT
                    || ';'
                    || i.SUP_ACC_DATE
					|| ';'
                    || i.PO_CREATION_DATE
					|| UTL_TCP.crlf;
            EXCEPTION
                WHEN OTHERS
                THEN
                    fnd_file.put_line (fnd_file.LOG, SQLERRM);
            END;

            UTL_SMTP.write_data (v_connection, v_clob); --Writing data in csv attachment.
        END LOOP;

        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        UTL_SMTP.close_data (v_connection);
        UTL_SMTP.quit (v_connection);
        COMMIT;
    EXCEPTION
        WHEN OTHERS
        THEN
            fnd_file.put_line (fnd_file.LOG, SQLERRM);
    END;
END;

/
