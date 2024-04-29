--------------------------------------------------------
--  DDL for Procedure XXAH_1SOURCE_NEW_BPA_RPT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_1SOURCE_NEW_BPA_RPT" (
    errbuf    OUT VARCHAR2,
    retcode   OUT NUMBER)
AS
    i                          NUMBER := 1;
    j                          NUMBER := 1;
    p_to                       VARCHAR2 (100) :='Vendor.Master.Data@aholddelhaize.com'; --Koen.Munk@ah.nl;
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
               'po_header_id'
            || ','
            || 'OperatingUnit'
            || ','
			|| 'Supplier_Name'
            || ','
            || 'BPA_NUMBER'
            || ','
			|| 'Sourcing_Manager'
            || ','
			|| 'Category'
            || ','
            || 'creation_date'
            || ','
            || 'last_update_date'
            || ','
            || 'start_date'
            || ','
            || 'end_date'
            || UTL_TCP.crlf;
        --if i >= 1
        --then
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
        --END IF;
      

        UTL_SMTP.write_data (
            v_connection,
            'Subject: Created BPA -(1source to EBS)' || UTL_TCP.crlf);
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
                || 'XXAH_1SOURCE_NEW_BPA_RPT'
                || TO_CHAR (ld_date, 'dd-mon-rrrr hh:mi')
                || '.csv'
                || '"'
                || UTL_TCP.crlf);
        END IF;

        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);

        FOR i
            IN (  SELECT distinct(c.po_header_id),
                         DECODE (c.ORG_ID,
                                 '150', 'AH',
                                 '151', 'GnG',
                                 '152', 'Etos',
                                 '83', 'AES',
                                 '430', 'ACZ',
                                 c.org_id)    OperatingUnit,
						'"' || a.Vendor_Name || '"'          Supplier_Name,
						--a.Vendor_Name Supplier_Name,
                         c.segment1           BPA_NUMBER,
						 '"' || a.agent_name || '"'          Sourcing_Manager,
						 --a.attribute11 Sourcing_Manager,
						 e.Category,
                         c.creation_date,
                         c.last_update_date,
                         c.start_date,
                         c.end_date
                    FROM XXAH_PO_HEADERS_INTERFACE a,
                         PO_HEADERS_INTERFACE b,
                         po_headers_all           c,
						 xxah_PO_Lines_INTERFACE  d,
						 po_lines_interface e
                   WHERE     a.po_header_id = b.interface_header_id
                         AND b.po_header_id = c.po_header_id
						 AND b.PO_HEADER_ID = e.PO_HEADER_ID
                          AND a.flow_status = 'Success'
                         AND b.process_code = 'ACCEPTED'
                         --AND d.flow_status = 'Success'
                         AND e.process_code = 'ACCEPTED'
                         AND c.creation_date >= SYSDATE - 1
                ORDER BY c.po_header_id)
        LOOP
            ln_counter := ln_counter + 1;

            IF ln_counter = 1
            THEN
                UTL_SMTP.write_data (v_connection, v_clob); --To avoid repeation of column heading in csv file
            END IF;

            BEGIN
                v_clob :=
                       '='
                    || i.po_header_id
                    || ','
                    || i.OperatingUnit
                    || ','
					|| i.Supplier_Name
                    || ','
                    || i.BPA_NUMBER
					||','
					|| i.Sourcing_Manager
                    || ','
					|| i.Category
                    || ','
                    || i.creation_date
                    || ','
                    || i.last_update_date
                    || ','
                    || i.start_date
                    || ','
                    || i.end_date
                    || UTL_TCP.crlf;
            EXCEPTION
                WHEN OTHERS
                THEN
                    fnd_file.put_line (fnd_file.LOG, SQLERRM);
            END;

            UTL_SMTP.write_data (v_connection, v_clob); --Writing data in csv attachment.
        END LOOP;
        if ln_counter >= 1
        then
        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);
        UTL_SMTP.close_data (v_connection);
        UTL_SMTP.quit (v_connection);
        COMMIT;
        end if;
      
    EXCEPTION
        WHEN OTHERS
        THEN
            fnd_file.put_line (fnd_file.LOG, SQLERRM);
    END;
    
END;

/
