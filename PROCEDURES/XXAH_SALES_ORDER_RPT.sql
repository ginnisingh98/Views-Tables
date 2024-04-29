--------------------------------------------------------
--  DDL for Procedure XXAH_SALES_ORDER_RPT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."XXAH_SALES_ORDER_RPT" (
   errbuf                OUT VARCHAR2,
   retcode               OUT NUMBER,
   START_ORDER_NO     IN     NUMBER,
   END_ORDER_NO       IN     NUMBER,
   Operating_Unit     IN     NUMBER,
   P_Creation_date    IN     VARCHAR2,
   P_Creation_date1   IN     VARCHAR2,
   P_Order_Type IN VARCHAR2)
AS
   i                          NUMBER := 1;
   j                          NUMBER := 1;
   p_to                       VARCHAR2 (100) := '';
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
   l_user                     NUMBER := 0;
BEGIN
   ld_date := SYSDATE;
   lv_domain := lv_smtp_server;

   --fnd_file.put_line (fnd_file.LOG, Creation_date || '  ' || Creation_date1);

   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

   l_user := fnd_global.user_id;

   --PS_ORDER_NO    := S_ORDER_NO;
   --PE_ORDER_NO    := E_ORDER_NO;
   fnd_file.put_line (fnd_file.LOG, l_user);

   --    fnd_file.put_line (fnd_file.LOG,PS_ORDER_NO||'   '||PE_ORDER_NO);
   BEGIN
      SELECT email_address
        INTO p_to
        FROM fnd_user
       WHERE user_id = l_user;
   EXCEPTION
      WHEN OTHERS
      THEN
         errbuf := 'InValid User';
         fnd_file.put_line (fnd_file.LOG, errbuf || SQLERRM);
   END;

   IF p_to IS NOT NULL
   THEN
      BEGIN
         v_clob :=
               'ORDER_NUMBER'
            || ','
            || 'SALES_AGREEMENT_NUMBER'
            || ','
            || 'CUSTOMER_NAME'
            || ','
            || 'CUSTOMER_NUMBER'
            || ','
            || 'ORDERED_DATE'
            || ','
            || 'SALES_ORDERED_ITEM'
            || ','
            || 'ORDER_LINE_NUM'
            || ','
            || 'LINE_NAME'
            || ','
            || 'LINE_DESCRIPTION'
            || ','
            || 'BLANKET_LINE_NUM'
            || ','
            || 'CHARTFIELD2'
            || ','
            || 'CHARTFIELD3'
            || ','
            || 'TAX_CODE'
            || ','
            || 'COST_CENTER'
            || ','
            || 'BILL_TYPE'
            || ','
            || 'UPLOAD_REFERENCE'
            || ','
            || 'SUPPLIER_DOC_NRS'
            || ','
            || 'VOLUME'
            || ','
            || 'PRICE'
            || ','
            || 'ORDERED_TOTAL_AMOUNT'
            || ','
            || 'INVOICED_TOTAL_AMOUNT'
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
            'Subject: Sales Order Upload Report' || UTL_TCP.crlf);
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
               || 'SaleOrderUploadReport'
               || TO_CHAR (ld_date, 'dd-mon-rrrr hh:mi')
               || '.csv'
               || '"'
               || UTL_TCP.crlf);
         END IF;

         UTL_SMTP.write_data (v_connection, UTL_TCP.crlf);

         FOR i
            IN (  SELECT DISTINCT
                         ooha.order_number "ORDER_NUMBER",
                         ooha.BLANKET_NUMBER "SALES_AGREEMENT_NUMBER",
                         '"' || rac.customer_name || '"' "CUSTOMER_NAME",
                         REGEXP_SUBSTR (hcas.ORIG_SYSTEM_REFERENCE, '[^#]+')
                            "CUSTOMER_NUMBER",
                         ooha.ORDERED_DATE "ORDERED_DATE",
                         oola.ORDERED_ITEM "SALES_ORDERED_ITEM",
                         oola.line_number "ORDER_LINE_NUM",
                         ott.NAME "LINE_NAME",
                         oht.NAME "ORDER_TYPE",
                         TRUNC (ooha.creation_date) creation_date,
                         '"' || oola.ATTRIBUTE2 || '"' "LINE_DESCRIPTION",
                         oola.blanket_line_number "BLANKET_LINE_NUM",
                         '"' || oola.attribute11 || '"' "CHARTFIELD2",
                         '"' || oola.attribute7 || '"' "CHARTFIELD3",
                         oola.tax_code "TAX_CODE",
                         oola.ATTRIBUTE3 "COST_CENTER",
                         oola.ATTRIBUTE5 "BILL_TYPE",
                         '"' || oola.ATTRIBUTE8 || '"' "UPLOAD_REFERENCE",
                         TO_CHAR (oola.attribute6) "SUPPLIER_DOC_NRS",
                         '"' || oola.attribute9 || '"' VOLUME,
                         '"' || oola.attribute10 || '"' PRICE,
                            '"'
                         || (oola.ordered_quantity * oola.unit_selling_price)
                         || '"'
                            "ORDERED_TOTAL_AMOUNT",
                            '"'
                         || (oola.INVOICED_QUANTITY * oola.unit_selling_price)
                         || '"'
                            "INVOICED_TOTAL_AMOUNT"
                    FROM ar_customers rac,
                         hz_cust_site_uses_all hsu,
                         hz_cust_acct_sites_all hcas,
                         hz_cust_accounts hca,
                         hz_parties hp,
                         oe_blanket_headers_all obha,
                         oe_order_headers_all ooha,
                         oe_order_lines_all oola,
                         oe_transaction_types_tl ott,
                         oe_transaction_types_tl oht
                   WHERE     1 = 1
                         AND hca.ACCOUNT_NUMBER = rac.customer_number
                         AND obha.ship_to_org_id = hsu.site_use_id
                         AND hsu.cust_acct_site_id = hcas.cust_acct_site_id
                         AND hcas.cust_account_id = hca.cust_account_id
                         AND hca.party_id = hp.party_id
                         AND hcas.status = 'A'
                         AND hca.cust_account_id(+) = ooha.sold_to_org_id
                         AND hcas.org_id = ooha.org_id
                         AND ooha.header_id = oola.header_id
                         AND obha.order_number = ooha.Blanket_number
                         AND oola.line_type_id = ott.transaction_type_id
                         AND ooha.order_type_id = oht.transaction_type_id
                         AND ooha.ORG_ID = Operating_Unit
                         AND ooha.order_type_id = nvl(P_Order_Type,ooha.order_type_id)
                         --AND trunc(ooha.creation_date) between fnd_date.canonical_to_date ( Creation_date) and fnd_date.canonical_to_date ( Creation_date1)
                         --AND ooha.order_number IN ('100331', '100334', '100335')
                         AND TRUNC (ooha.creation_date) BETWEEN TRUNC (
                                                                   NVL (
                                                                      TO_DATE (
                                                                         P_Creation_date,
                                                                         'RRRR/MM/DD HH24:MI:SS'),
                                                                      ooha.creation_date))
                                                            AND TRUNC (
                                                                   NVL (
                                                                      TO_DATE (
                                                                         P_Creation_date1,
                                                                         'RRRR/MM/DD HH24:MI:SS'),
                                                                      ooha.creation_date))
                         AND ooha.order_number BETWEEN TO_NUMBER (
                                                          START_ORDER_NO)
                                                   AND TO_NUMBER (END_ORDER_NO)
                ORDER BY ooha.order_number, oola.line_number)
         LOOP
            ln_counter := ln_counter + 1;

            IF ln_counter = 1
            THEN
               UTL_SMTP.write_data (v_connection, v_clob); --To avoid repeation of column heading in csv file
            END IF;

            BEGIN
               v_clob :=
                     '='
                  || i.ORDER_NUMBER
                  || ','
                  || i.SALES_AGREEMENT_NUMBER
                  || ','
                  || i.CUSTOMER_NAME
                  || ','
                  || i.CUSTOMER_NUMBER
                  || ','
                  || i.ORDERED_DATE
                  || ','
                  || i.SALES_ORDERED_ITEM
                  || ','
                  || i.ORDER_LINE_NUM
                  || ','
                  || i.LINE_NAME
                  || ','
                  || i.LINE_DESCRIPTION
                  || ','
                  || i.BLANKET_LINE_NUM
                  || ','
                  || i.CHARTFIELD2
                  || ','
                  || i.CHARTFIELD3
                  || ','
                  || i.TAX_CODE
                  || ','
                  || i.COST_CENTER
                  || ','
                  || i.BILL_TYPE
                  || ','
                  || i.UPLOAD_REFERENCE
                  || ','
                  || i.SUPPLIER_DOC_NRS
                  || ','
                  || i.VOLUME
                  || ','
                  || i.PRICE
                  || ','
                  || i.ORDERED_TOTAL_AMOUNT
                  || ','
                  || i.INVOICED_TOTAL_AMOUNT
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
   ELSE
      errbuf := 'Email Id not assigned';
      fnd_file.put_line (fnd_file.LOG, errbuf || SQLERRM);
   END IF;
END;

/
