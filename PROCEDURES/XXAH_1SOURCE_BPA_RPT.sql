--------------------------------------------------------
--  DDL for Procedure XXAH_1SOURCE_BPA_RPT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_1SOURCE_BPA_RPT" (errbuf    OUT VARCHAR2,
                                                       retcode   OUT NUMBER)
AS
    i                          NUMBER := 1;
    j                          NUMBER := 1;
    p_to                       VARCHAR2 (100) := 'Vendor.Master.Data@aholddelhaize.com'; 
	--p_CC                       VARCHAR2 (100) := 'ginni.singh@ah.nl'; 
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
               'Interface_header_id'
            || ','
			|| 'creation_date'
            || ','
            || 'org_id'
            || ','
            || 'Currency_code'
            || ','
            || 'agent_name'
            || ','
            || 'vendor_name'
            || ','
            || 'vendor_site_id'
            || ','
            || 'vendor_contact_id'
            || ','
            || 'ACCEPTANCE_DUE_DATE'
            || ','
            || 'FREIGHT_CARRIER'
            || ','
            || 'FOB'
            || ','
            || 'ship_to_location'
            || ','
            || 'bill_to_location'
            || ','
            || 'payment_terms'
            || ','
            || 'freight_terms'
            || ','
            || 'comments'
            || ','
            || 'acceptance_required_flag'
            || ','
            || 'amount_agreed'
            || ','
            || 'amount_limit'
            || ','
            || 'min_release_amount'
            || ','
            || 'effective_date'
            || ','
            || 'expiration_date'
            || ','
            || 'supplierAcceptedDate'
            || ','
            || 'relatedVendorAllowanceNumber'
            || ','
            || 'foreignCurrency'
            || ','
            || 'ATTRIBUTE4'
            || ','
            || 'combinedBpaApprovalFlag'
            || ','
            || 'commitedLinearDepreciation'
            || ','
            || 'previousContract'
            || ','
            || 'sourcedBy'
            || ','
            || 'parentContract'
            || ','
            || 'termOfNotice'
            || ','
            || 'controller'
            || ','
            || 'amountInForeignCurrency'
            || ','
            || 'commitedValueFixed'
            || ','
            || 'payTermPercentage'
            || ','
            || 'payTermInDays'
            || ','
            || 'pay_on_code'
            || ','
            || 'interface_line_id'
            || ','
            || 'line_num'
            || ','
            || 'line_type'
            || ','
            || 'category'
            || ','
            || 'item_description'
            || ','
            || 'unit_of_measure'
            || ','
            || 'committed_amount'
            || ','
            || 'unit_price'
            || ','
            || 'organization_id'
            || ','
            || 'LineExpirationDate'
            || ','
            || 'flow_status'
            || ','
            || 'error_message'
            || ','
            || 'process_code'
            || ','
            || 'Interface_Error_message'
            || UTL_TCP.crlf;
        v_connection := UTL_SMTP.open_connection (lv_smtp_server); --To open the connection      UTL_SMTP.helo (v_connection, lv_domain);
        UTL_SMTP.helo (v_connection, lv_smtp_server);
        UTL_SMTP.mail (v_connection, lv_from);
        UTL_SMTP.rcpt (v_connection, p_to); -- To send mail to valid receipent
		--UTL_SMTP.rcpt (v_connection, p_CC); -- To send mail to valid receipent
        UTL_SMTP.open_data (v_connection);
        UTL_SMTP.write_data (v_connection,
                             'From: ' || lv_from || UTL_TCP.crlf);

        IF TRIM (p_to) IS NOT NULL
        THEN
            UTL_SMTP.write_data (v_connection,
                                 'To: ' || p_to || UTL_TCP.crlf);
        END IF;
		
		--IF TRIM (p_CC) IS NOT NULL
        --THEN
            --UTL_SMTP.write_data (v_connection,
                                 --'To: ' || p_CC || UTL_TCP.crlf);
        --END IF;

        UTL_SMTP.write_data (
            v_connection,
            'Subject: BPA interface error report-(1source to EBS)' || UTL_TCP.crlf);
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
                || 'XXAH_1SOURCE_BPA_RPT'
                || TO_CHAR (ld_date, 'dd-mon-rrrr hh:mi')
                || '.csv'
                || '"'
                || UTL_TCP.crlf);
        END IF;

        UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);

        FOR i
            IN (SELECT a.Interface_header_id,
         a.creation_date creation_date,
         a.org_id,
         a.Currency_code,
         '"' || a.agent_name || '"'          agent_name,
         '"' || a.vendor_name || '"'         vendor_name,
         a.vendor_site_id,
         a.vendor_contact_id,
         a.ACCEPTANCE_DUE_DATE,
         a.FREIGHT_CARRIER,
         a.FOB,
         a.ship_to_location,
         a.bill_to_location,
         a.payment_terms,
         a.freight_terms,
         '"' || a.comments || '"'            comments,
         a.acceptance_required_flag,
         a.amount_agreed,
         a.amount_limit,
         a.min_release_amount,
         a.effective_date,
         a.expiration_date,
         a.attribute1                        supplierAcceptedDate,
         a.ATTRIBUTE2                        relatedVendorAllowanceNumber,
         a.ATTRIBUTE3                        foreignCurrency,
         a.ATTRIBUTE4,
         a.ATTRIBUTE5                        combinedBpaApprovalFlag,
         '"' || a.ATTRIBUTE6 || '"'          commitedLinearDepreciation,
         a.ATTRIBUTE7                        previousContract,
         a.ATTRIBUTE8                        sourcedBy,
         a.ATTRIBUTE9                        parentContract,
         a.ATTRIBUTE10                       termOfNotice,
         '"' || a.ATTRIBUTE11 || '"'         controller,
         a.ATTRIBUTE12                       amountInForeignCurrency,
         a.ATTRIBUTE13                       commitedValueFixed,
         '"' || a.ATTRIBUTE14 || '"'         payTermPercentage,
         a.ATTRIBUTE15                       payTermInDays,
         a.pay_on_code,
         c.interface_line_id,
         c.line_num,
         c.line_type,
         c.category,
         '"' || c.item_description || '"'    item_description,
         c.unit_of_measure,
         c.committed_amount,
         c.unit_price,
         c.organization_id,
         c.EXPIRATION_DATE                   LineExpirationDate,
         a.flow_status,
         '"' || a.error_message || '"'       error_message,
         b.process_code,
            '"'
         || (SELECT LISTAGG (error_message, ',')
                        WITHIN GROUP (ORDER BY interface_header_id DESC)
               FROM po_interface_errors
              WHERE interface_header_id = b.interface_header_id)
         || '"'                              Interface_Error_message
    FROM XXAH_PO_HEADERS_INTERFACE a,
         PO_HEADERS_INTERFACE     b,
         xxah_PO_Lines_INTERFACE  c
   WHERE     a.po_header_id = b.interface_header_id(+)
         AND a.interface_header_id = c.interface_header_id
         AND (a.flow_status = 'Error' OR b.process_code <> 'ACCEPTED')
         AND a.creation_date >= SYSDATE - 1
ORDER BY a.interface_header_id)
        LOOP
            ln_counter := ln_counter + 1;

            IF ln_counter = 1
            THEN
                UTL_SMTP.write_data (v_connection, v_clob); --To avoid repeation of column heading in csv file
            END IF;

            BEGIN
                v_clob :=
                       '='
                    || i.Interface_header_id
					|| ','
                    || i.creation_date
                    || ','
                    || i.org_id
                    || ','
                    || i.Currency_code
                    || ','
                    || i.agent_name
                    || ','
                    || i.vendor_name
                    || ','
                    || i.vendor_site_id
                    || ','
                    || i.vendor_contact_id
                    || ','
                    || i.ACCEPTANCE_DUE_DATE
                    || ','
                    || i.FREIGHT_CARRIER
                    || ','
                    || i.FOB
                    || ','
                    || i.ship_to_location
                    || ','
                    || i.bill_to_location
                    || ','
                    || i.payment_terms
                    || ','
                    || i.freight_terms
                    || ','
                    || i.comments
                    || ','
                    || i.acceptance_required_flag
                    || ','
                    || i.amount_agreed
                    || ','
                    || i.amount_limit
                    || ','
                    || i.min_release_amount
                    || ','
                    || i.effective_date
                    || ','
                    || i.expiration_date
                    || ','
                    || i.supplierAcceptedDate
                    || ','
                    || i.relatedVendorAllowanceNumber
                    || ','
                    || i.foreignCurrency
                    || ','
                    || i.ATTRIBUTE4
                    || ','
                    || i.combinedBpaApprovalFlag
                    || ','
                    || i.commitedLinearDepreciation
                    || ','
                    || i.previousContract
                    || ','
                    || i.sourcedBy
                    || ','
                    || i.parentContract
                    || ','
                    || i.termOfNotice
                    || ','
                    || i.controller
                    || ','
                    || i.amountInForeignCurrency
                    || ','
                    || i.commitedValueFixed
                    || ','
                    || i.payTermPercentage
                    || ','
                    || i.payTermInDays
                    || ','
                    || i.pay_on_code
                    || ','
                    || i.interface_line_id
                    || ','
                    || i.line_num
                    || ','
                    || i.line_type
                    || ','
                    || i.category
                    || ','
                    || i.item_description
                    || ','
                    || i.unit_of_measure
                    || ','
                    || i.committed_amount
                    || ','
                    || i.unit_price
                    || ','
                    || i.organization_id
                    || ','
                    || i.LineExpirationDate
                    || ','
                    || i.flow_status
                    || ','
                    || i.error_message
                    || ','
                    || i.process_code
                    || ','
                    || i.Interface_Error_message
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
