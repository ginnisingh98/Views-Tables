--------------------------------------------------------
--  DDL for Package Body POS_SUPP_GENERATE_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPP_GENERATE_RPT_PKG" AS
   /* $Header: POSSPRPTB.pls 120.0.12010000.2 2010/02/08 14:20:22 ntungare noship $ */
    -- Start of comments
    -- API name   : Generate Report API
    -- Author  : BHUVANA VAMSI
    -- Purpose : Generate report for selected supplier based on XML Payload
    --  Version    : Initial version   1.0
    -- End of comments

----------------------------------------------------
    FUNCTION rem_first_comma(in_string IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        IF (TRIM(in_string) IS NOT NULL) THEN
            RETURN substr(in_string, 2, length(in_string));
        ELSE
            RETURN in_string;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
          RETURN '';
    END;
-------------------------------------------------------------

    PROCEDURE list_to_csv_varchar(x_array   IN pos_tbl_number,
                                  x_result1 OUT NOCOPY VARCHAR2,
                                  x_result2 OUT NOCOPY VARCHAR2,
                                  x_result3 OUT NOCOPY VARCHAR2) IS
        -- For longcomments enhancement, Bug 2234299
        -- changed 'value' type from qa_results.character1%TYPE to varchar2(2000)
        -- rponnusa Thu Mar 14 21:27:04 PST 2002
        separator CONSTANT VARCHAR2(1) := ',';
        l_list_count INTEGER;
    BEGIN
        -- Loop until a single ',' is found or x_result is exhausted.
        l_list_count := x_array.count;
        IF l_list_count > 2900 THEN
            FOR i IN 1 .. 2900 LOOP
                x_result1 := x_result1 || separator || x_array(i);
            END LOOP;
            x_result1 := rem_first_comma(x_result1);
            IF l_list_count < 5800 THEN
                FOR i IN 2901 .. l_list_count LOOP
                    x_result2 := x_result2 || separator || x_array(i);
                END LOOP;
                x_result2 := rem_first_comma(x_result2);
            ELSE
                FOR i IN 2901 .. 5800 LOOP
                    x_result2 := x_result2 || separator || x_array(i);
                END LOOP;
                FOR i IN 5801 .. l_list_count LOOP
                    x_result3 := x_result3 || separator || x_array(i);
                END LOOP;
                x_result2 := rem_first_comma(x_result2);
                x_result3 := rem_first_comma(x_result3);
            END IF;
        ELSE
            FOR i IN x_array.first .. x_array.last LOOP
                x_result1 := x_result1 || separator || x_array(i);
            END LOOP;
            x_result1 := rem_first_comma(x_result1);
        END IF;
    END list_to_csv_varchar;
---------------------------------------------

    PROCEDURE parse_list(x_result IN VARCHAR2,
                         x_array  IN OUT NOCOPY pos_tbl_number) IS
        -- For longcomments enhancement, Bug 2234299
        -- changed 'value' type from qa_results.character1%TYPE to varchar2(2000)
        -- rponnusa Thu Mar 14 21:27:04 PST 2002
        l_value VARCHAR2(2000);
        c       VARCHAR2(10);
        separator CONSTANT VARCHAR2(1) := ',';
        arr_index     INTEGER;
        p             INTEGER;
        n             INTEGER;
        l_array_count INTEGER := 0;
    BEGIN
        -- Loop until a single ',' is found or x_result is exhausted.
        BEGIN
            l_array_count := x_array.count;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        IF l_array_count > 1 THEN
            arr_index := l_array_count;
        ELSE
            arr_index := 1;
        END IF;
        p := 1;
        n := length(x_result);
        WHILE p <= n LOOP
            c := substr(x_result, p, 1);
            p := p + 1;
            IF (c = separator) THEN
                x_array(arr_index) := l_value;
                arr_index := arr_index + 1;
                l_value := '';
                x_array.extend(1);
            ELSE
                l_value := l_value || c;
            END IF;

        END LOOP;
        x_array(arr_index) := l_value;

    END parse_list;
----------------------------------------
-- Main Procedure which is being called from the Generate Report AM Method
  PROCEDURE generate_report_event(    p_api_version          IN INTEGER,
                                      p_init_msg_list        IN VARCHAR2,
                                      p_party_id             IN pos_tbl_number,
                                      x_report_id            OUT NOCOPY NUMBER,
                                      x_actions_request_id   OUT NOCOPY NUMBER,
                                      x_return_status        OUT NOCOPY VARCHAR2,
                                      x_msg_count            OUT NOCOPY NUMBER,
                                      x_msg_data             OUT NOCOPY VARCHAR2) IS

        l_party_id_cs_1      VARCHAR(32767) := '';
        l_party_id_cs_2      VARCHAR(32767) := '';
        l_party_id_cs_3      VARCHAR(32767) := '';
        actions_request_id   NUMBER := 0;

    BEGIN
        x_report_id := get_curr_supp_xml_rpt_id;
        list_to_csv_varchar(p_party_id,
                            l_party_id_cs_1,
                            l_party_id_cs_2,
                            l_party_id_cs_3);

      populate_bo_and_save_concur(l_party_id_cs_1,
                                  l_party_id_cs_2,
                                  l_party_id_cs_3,
                                  x_report_id);

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END generate_report_event;
---------------------------------------------

   PROCEDURE populate_bo_and_save_concur(p_party_id_cs_1           IN VARCHAR2 DEFAULT '',
                                         p_party_id_cs_2           IN VARCHAR2 DEFAULT '',
                                         p_party_id_cs_3           IN VARCHAR2 DEFAULT '',
                                         p_report_id_in            IN VARCHAR2 DEFAULT '') IS

        x_return_status            VARCHAR2(100);
        x_msg_data                 VARCHAR2(100);
        x_msg_count                NUMBER;
        l_report_id                NUMBER := NULL;
        p_party_id                 pos_tbl_number := pos_tbl_number();

   BEGIN

        p_party_id.extend(1);

        IF p_report_id_in IS NULL THEN
            l_report_id := get_curr_supp_xml_rpt_id;
        ELSE
            l_report_id := p_report_id_in;
        END IF;

        IF TRIM(p_party_id_cs_1) IS NULL THEN
            RETURN;
        END IF;
        parse_list(p_party_id_cs_1, p_party_id);

        IF TRIM(p_party_id_cs_2) IS NOT NULL THEN
            parse_list(p_party_id_cs_2, p_party_id);
        END IF;
        IF TRIM(p_party_id_cs_3) IS NOT NULL THEN
            parse_list(p_party_id_cs_3, p_party_id);
        END IF;

       -- Procedure to Generate the BO and insert in the table
        get_bo_and_insert(p_party_id,
                          l_report_id
                         );

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
---------------------------------------------------
-- Function to generate the report ID
    FUNCTION get_curr_supp_xml_rpt_id RETURN NUMBER IS
    BEGIN
          SELECT pos_supp_gen_xml_rpt_s.nextval
          INTO   g_curr_supp_xml_rpt_id
          FROM   dual;
        RETURN g_curr_supp_xml_rpt_id;
    EXCEPTION
        WHEN OTHERS THEN
          RETURN - 1;
    END;
------------------------------------------------
-- Procedure to get the XML content for each party Id and insert in the table
    PROCEDURE get_bo_and_insert(p_party_id  IN pos_tbl_number,
                                p_report_id IN NUMBER ) IS
        l_user_id           NUMBER := fnd_global.user_id;
        l_last_update_login NUMBER := fnd_global.login_id;
        l_pos_supplier_bo   pos_supplier_bo;
        x_return_status     VARCHAR2(1000);
        x_msg_count         NUMBER:=0;
        x_msg_data          VARCHAR2(1000);

    BEGIN

        FOR i IN p_party_id.first .. p_party_id.last LOOP

            -- Procedure to get the XML content based on Party ID
            pos_supplier_bo_pkg.pos_get_supplier_bo(NULL,
                                                    NULL,
                                                    p_party_id(i),
                                                    NULL,
                                                    NULL,
                                                    l_pos_supplier_bo,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data);

            INSERT INTO POS_SUPP_GENERATE_XML_RPT
                (report_id,
                 party_id,
                 xmlcontent,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 last_update_login)
            VALUES
                (p_report_id,
                 p_party_id(i),
                 xmltype(l_pos_supplier_bo),
                 l_user_id,
                 SYSDATE,
                 l_user_id,
                 SYSDATE,
                 l_last_update_login);
            COMMIT;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
           RAISE;
    END get_bo_and_insert;
 ------------------------------------------
  Function BEFORE_REPORT_TRIGGER (P_REPORT_ID in number,P_PUBLICATION_ID in varchar2) return Boolean is
   begin
    if (p_report_id <> 0) then
      FromClause:='POS_SUPP_GENERATE_XML_RPT';
      WhereClause:='x.report_id='||P_REPORT_ID;
    else
    if (p_publication_id<> 'NA') then
      FromClause:='pos_supp_pub_history';
      WhereClause:='x.publication_event_id in ('||P_PUBLICATION_ID||')';
      end if;
    end if;
    return true;
   end;

END pos_supp_generate_rpt_pkg;

/
