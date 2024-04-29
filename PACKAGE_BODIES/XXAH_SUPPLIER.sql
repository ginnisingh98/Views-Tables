--------------------------------------------------------
--  DDL for Package Body XXAH_SUPPLIER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SUPPLIER" 
AS
   /**************************************************************************
    * VERSION      : $Id: XXAH_SUPPLIER.pks  2015-05-21 09:28:10 vema.reddy@atos.net $
    * DESCRIPTION  : Contains functionality for the Supplier xml payload send to OFMW
    *
    * CHANGE HISTORY
    * ==============
    *
    * Date        Version        Authors           Change reference/Description
    * ----------  --------      -----------       ----------------------------------
    * 21-May-2015   1.0          Vema Reddy        Initial
    * 21-Aug-2018   1.1          Gowrishankar      Incomplete supplier xml issue at OFMW (for large volume of xml datas)
    *                                              changes done in SUPP_XML_INTERFACE procedure
    * 02-Dec-2019   1.2          Anish Hussain     Changes for Supplier approval Workflow
    * 26-Aug-2020   1.3          Anish Hussain     Changes for RFCC19-277. Supplier status should be considered for publishing
    *                                              only for supplier type Trade and for other supplier types publish should happen
    *                                              irrespective of the supplier type
    * 10-MAR-2021   2.0          Karthick B        OFMW to WebMethods Migration
    *************************************************************************/

   /**************************************************************************
   *
   * PROCEDURE
   *   order_booked
   *
   * DESCRIPTION
   *   Send XML Suplier Payload to OFMW with 500 milliseconds delay
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * errbuf            OUT            output buffer for error messages
   * retcode           OUT            return code for concurrent program
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
   FUNCTION PUBLISH_PAYLOAD (p_subscription_guid   IN            RAW,
                             p_event               IN OUT NOCOPY WF_EVENT_T)
      RETURN VARCHAR2
   AS
      l_count     NUMBER := 0;
      row_count   VARCHAR2 (30);


      TYPE t_record IS TABLE OF pos_supp_pub_history%ROWTYPE;

      l_table     t_record;

      --Modified the below cursor query for publishing only ACTIVE suppliers
      --As part of supplier approval workflow
      --Added for V 1.2
      /*Commented for V 1.3
      CURSOR c_load(b_event_key pos_supp_pub_history.publication_event_id%TYPE)
        IS
        SELECT psph.*
          FROM pos_supp_pub_history psph
              ,(SELECT  party_id,c_ext_attr1
                  FROM  pos_supp_prof_ext_b pspe
                       ,ego_attr_groups_v eagv
                 WHERE  1=1
                   AND  eagv.attr_group_id = pspe.attr_group_id
                   AND  eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS'
                   ) status
         WHERE 1=1
           AND publication_event_id = b_event_key
           AND status.party_id(+) = psph.party_id
           AND EXISTS (SELECT 1
                         FROM fnd_lookup_values
                        WHERE 1=1
                          AND lookup_type = 'XXAH_SUPPLIER_PUBLISH_STATUS'
                          AND lookup_code = NVL(status.c_ext_attr1,'ACTIVE')
                          AND enabled_flag = 'Y');
      End of commment for V 1.3*/
      /*Commented for V 1.2
      CURSOR c_load(b_event_key pos_supp_pub_history.publication_event_id%TYPE)
        IS
        SELECT *
          FROM pos_supp_pub_history
         WHERE publication_event_id = b_event_key;
         */
      ---Added the below cursor for V 1.3
      CURSOR c_load (
         b_event_key    pos_supp_pub_history.publication_event_id%TYPE)
      IS
         SELECT psph.*
           FROM pos_supp_pub_history psph,
                (SELECT party_id, c_ext_attr1
                   FROM pos_supp_prof_ext_b pspe, ego_attr_groups_v eagv
                  WHERE     1 = 1
                        AND eagv.attr_group_id = pspe.attr_group_id
                        AND eagv.attr_group_name = 'XXAH_SUPPLIER_STATUS')
                status
          WHERE     1 = 1
                AND publication_event_id = b_event_key
                AND status.party_id(+) = psph.party_id
                AND EXISTS
                       (SELECT 1
                          FROM fnd_lookup_values
                         WHERE     1 = 1
                               AND lookup_type =
                                      'XXAH_SUPPLIER_PUBLISH_STATUS'
                               AND lookup_code =
                                      NVL (status.c_ext_attr1, 'ACTIVE')
                               AND enabled_flag = 'Y')
                AND EXISTS
                       (SELECT 1
                          FROM pos_supp_prof_ext_b pspe,
                               ego_attr_groups_v eagv
                         WHERE     1 = 1
                               AND eagv.attr_group_id = pspe.attr_group_id
                               AND pspe.party_id = psph.party_id
                               AND UPPER (eagv.attr_group_name) =
                                      'XXAH_SUPPLIER_TYPE'
                               AND UPPER (c_ext_attr1) = 'TRADE')
         UNION ALL
         SELECT psph.*
           FROM pos_supp_pub_history psph
          WHERE     1 = 1
                AND publication_event_id = b_event_key
                AND NOT EXISTS
                       (SELECT 1
                          FROM pos_supp_prof_ext_b pspe,
                               ego_attr_groups_v eagv
                         WHERE     1 = 1
                               AND eagv.attr_group_id = pspe.attr_group_id
                               AND pspe.party_id = psph.party_id
                               AND UPPER (eagv.attr_group_name) =
                                      'XXAH_SUPPLIER_TYPE'
                               AND UPPER (c_ext_attr1) = 'TRADE');
   BEGIN
      OPEN c_load (p_event.event_key);

      LOOP
         -- l_table.DELETE;

         FETCH c_load BULK COLLECT INTO l_table LIMIT 10000;

         row_count := c_load%ROWCOUNT;


         FORALL i IN 1 .. l_table.COUNT
            MERGE INTO XXAH_SUPPLIER_PAYLOAD ab
                 USING (SELECT l_table (i).publication_event_id AS event_id,
                               l_table (i).party_id AS party_id,
                               l_table (i).xmlcontent AS xmlcontent
                          FROM DUAL) bc
                    ON (ab.party_id = bc.party_id)
            WHEN MATCHED
            THEN
               UPDATE SET
                  xmlcontent = l_table (i).xmlcontent,
                  last_update_date = CURRENT_TIMESTAMP
            WHEN NOT MATCHED
            THEN
               INSERT     (event_id, party_id, xmlcontent)
                   VALUES (bc.event_id, bc.PARTY_ID, bc.XMLCONTENT);


         EXIT WHEN c_load%NOTFOUND;
         COMMIT;
      END LOOP;

      FND_FILE.PUT_LINE (FND_FILE.LOG,
                         'No. Of records inserted ==>' || '' || row_count);

      CLOSE c_load;

      RETURN 'SUCCESS';
   END;

   PROCEDURE SUPP_XML_INTERFACE (errbuf OUT VARCHAR2, retcode OUT NUMBER)
   AS
      http_req          UTL_HTTP.req;
      http_resp         UTL_HTTP.resp;
      resp              XMLTYPE;
      soap_err          EXCEPTION;
      v_len             NUMBER;
      v_txt             VARCHAR2 (32767);
      soap_request      XMLTYPE;
      soap_respond      CLOB;
      http_request      UTL_HTTP.REQ;
      req               UTL_HTTP.req;
      e_invalid_data    EXCEPTION;
      e_no_data_found   EXCEPTION;
      c_lob             CLOB;
      url               VARCHAR2 (32767);
      buffer            VARCHAR2 (32767);
      amt               PLS_INTEGER := 32000;
      offset            PLS_INTEGER := 1;
      Envelope1         VARCHAR2 (1000);
      v_count           VARCHAR2 (30);
      Envelope2         VARCHAR2 (1000);
      Envelope3         VARCHAR2 (1000);
      error_txt         NUMBER;
      b_buffer          VARCHAR2 (32767);
      amount            INTEGER;
      counter           NUMBER (8) DEFAULT 0;



      CURSOR c_payload
      IS
         SELECT *
           FROM XXAH_SUPPLIER_PAYLOAD
          WHERE ROWNUM <= 50;
   BEGIN
      SELECT MESSAGE_TEXT
        INTO Envelope1
        FROM fnd_new_messages
       WHERE message_name = 'XXAH_XML_MESSAGE_PART1';

      SELECT MESSAGE_TEXT
        INTO Envelope2
        FROM fnd_new_messages
       WHERE message_name = 'XXAH_XML_MESSAGE_PART2';

      SELECT MESSAGE_TEXT
        INTO Envelope3
        FROM fnd_new_messages
       WHERE message_name = 'XXAH_XML_OFMW_URL';

      FOR supp_load IN c_payload
      LOOP
         FND_FILE.PUT_LINE (FND_FILE.LOG, 'Soap Request Started');


         BEGIN
            -- Define the SOAP requaest according the the definition of the web service being called

            url := Envelope3;


            req := UTL_HTTP.begin_request (url);



            BEGIN
               soap_request :=
                  xmltype (
                        Envelope1
                     || supp_load.xmlcontent.getClobVal ()
                     || Envelope2);
            EXCEPTION
               WHEN e_invalid_data
               THEN
                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                        'Issue on Main SOAP Request'
                     || ''
                     || SQLERRM
                     || ''
                     || SQLCODE);
                  RAISE;
            END;


            http_req := UTL_HTTP.begin_request (url, 'POST', 'HTTP/1.1');
            UTL_HTTP.set_header (http_req,
                                 'Content-Type',
                                 'text/xml; charset=UTF-8');
            UTL_HTTP.set_header (http_req,
                                 'Content-Length',
                                 LENGTH (soap_request.getClobval ()));

            UTL_HTTP.set_header (http_req, 'Download', '');
            c_lob := soap_request.getClobval ();
            UTL_HTTP.SET_HEADER (http_req, 'Transfer-Encoding', 'chunked');
            offset := 1;
            amt := 20000;

            b_buffer := NULL;

            -- obtain response in 32K blocks just in case it is greater than 32K
            LOOP
               --- below if condition modified for Supplier incomplete XMl issue
               -- IF LENGTH(c_lob)=0 OR LENGTH(c_lob) IS NULL
               IF offset >= LENGTH (c_lob)
               THEN
                  EXIT;
               END IF;

               --- below if condition commented for Supplier incomplete XMl issue
               /*  IF b_buffer IS NOT NULL THEN
                 c_lob:=REPLACE(c_lob,b_buffer);
                 END IF;*/

               b_buffer := DBMS_LOB.SUBSTR (c_lob, amt, offset);
               UTL_HTTP.write_text (http_req, b_buffer);

               offset := offset + amt; -- added for Supplier incomplete XMl issue
            END LOOP;

            soap_respond := NULL;
            http_resp := UTL_HTTP.get_response (http_req);
            UTL_HTTP.get_header_by_name (http_resp,
                                         'Content-Length',
                                         v_len,
                                         1);

            BEGIN
               -- Obtain the length of the response
               --for j in 1 .. 2 loop
               FOR i IN 1 .. CEIL (v_len / 32767)
               --obtain response in 32K blocks just in case it is greater than 32K
               LOOP
                  BEGIN
                     UTL_HTTP.read_text (
                        http_resp,
                        v_txt,
                        CASE
                           WHEN i < CEIL (v_len / 32767) THEN 32767
                           ELSE MOD (v_len, 32767)
                        END);


                     soap_respond := soap_respond || v_txt;   -- build up CLOB

                     error_txt := DBMS_LOB.INSTR (soap_respond, 'exception');


                     IF error_txt > 0
                     THEN
                        RAISE e_invalid_data;
                     END IF;
                  EXCEPTION
                     WHEN e_invalid_data
                     THEN
                        FND_FILE.PUT_LINE (
                           FND_FILE.LOG,
                           'Error on soap_respond ==>' || '' || soap_respond);
                        RAISE;
                  END;
               END LOOP;

               UTL_HTTP.end_response (http_resp);
            EXCEPTION
               WHEN OTHERS
               THEN
                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                        'Error on Read Text ==>'
                     || ' With Error  ==>'
                     || SQLCODE);
                  RAISE;
            END;

            resp := XMLType.createXML (soap_respond);

            BEGIN
               DELETE XXAH_SUPPLIER_PAYLOAD
                WHERE party_id = supp_load.party_id;

               COMMIT;
               v_count := c_payload%ROWCOUNT;
            EXCEPTION
               WHEN e_no_data_found
               THEN
                  FND_FILE.PUT_LINE (
                     FND_FILE.LOG,
                        'Issue on Deletion of recrods from XXAH_SUPPLIER_PAYLOAD  ==>'
                     || ' With Error'
                     || SQLERRM);
                  RAISE;
            END;

            counter := counter + SQL%ROWCOUNT;

            IF counter >= 100
            THEN
               counter := 0;
               COMMIT;
            END IF;



            -- Convert CLOB to XMLTYPE
            UTL_HTTP.end_request (req);
         EXCEPTION
            WHEN OTHERS
            THEN
               FND_FILE.PUT_LINE (
                  FND_FILE.LOG,
                     'Error on Final Soap Request ==> Party_Id ==>'
                  || ' '
                  || supp_load.party_id
                  || '  '
                  || '  With Error  ==>'
                  || SQLERRM);
               RAISE;
               COMMIT;
         END;

         DBMS_LOCK.sleep (0.5);

         FND_FILE.PUT_LINE (
            FND_FILE.LOG,
               'Processed Supplier Details ==>'
            || ''
            || 'Event Id ==>'
            || ' '
            || supp_load.event_id
            || '  '
            || 'Party_Id is ==>'
            || ' '
            || supp_load.party_id);
      END LOOP;                                                  --- Main Loop


      FND_FILE.PUT_LINE (
         FND_FILE.LOG,
         'No. Of records Processed and Deleted ==>' || '' || v_count);
     /*BEGIN
                        DELETE pos_supp_pub_history
WHERE publication_date > ADD_MONTHS(SYSDATE,2);
EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,
                        'Error on Deletion from pos_supp_pub_history ==>' ||
      '' ||SQLERRM);
END;*/
   END SUPP_XML_INTERFACE;
END XXAH_SUPPLIER;

/
