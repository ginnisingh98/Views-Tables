--------------------------------------------------------
--  DDL for Package Body POS_SUPP_PUB_RAISE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPP_PUB_RAISE_EVENT_PKG" AS
/* $Header: POSSPPBEB.pls 120.0.12010000.4 2010/04/01 09:45:21 ntungare noship $ */
    -- Start of comments
    --  API name   : publish_supplier
    --  Type    : Public
    --  Version    : Initial version   1.0
    -- End of comments
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

    PROCEDURE list_to_csv_varchar(x_array   IN pos_tbl_number,
                                  x_result1 OUT NOCOPY VARCHAR2,
                                  x_result2 OUT NOCOPY VARCHAR2,
                                  x_result3 OUT NOCOPY VARCHAR2) IS

        -- For longcomments enhancement, Bug 2234299
        -- changed 'value' type from qa_results.character1%TYPE to varchar2(2000)
        -- rponnusa Thu Mar 14 21:27:04 PST 2002

        l_value VARCHAR2(2000);
        c       VARCHAR2(10);
        separator CONSTANT VARCHAR2(1) := ',';
        arr_index    INTEGER;
        p            INTEGER;
        n            INTEGER;
        l_list_count INTEGER;

    BEGIN
        --
        -- Loop until a single ',' is found or x_result is exhausted.
        --
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
        --
        -- Loop until a single ',' is found or x_result is exhausted.
        --
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

    /*#
    * Use this routine to raise supplier publish event
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_party_id  The party id
    * @param p_published_by The published by
    * @param p_publish_detail The publish details
    * @param x_publication_event_id The generated publication event id
    * @param x_actions_request_id The actions request id
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Supplier Publication Event
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */

    PROCEDURE create_supp_publish_event(p_api_version          IN INTEGER,
                                        p_init_msg_list        IN VARCHAR2,
                                        p_party_id             IN pos_tbl_number,
                                        p_published_by         IN INTEGER,
                                        p_publish_detail       IN VARCHAR,
                                        x_publication_event_id OUT NOCOPY NUMBER,
                                        x_actions_request_id   OUT NOCOPY NUMBER,
                                        x_return_status        OUT NOCOPY VARCHAR2,
                                        x_msg_count            OUT NOCOPY NUMBER,
                                        x_msg_data             OUT NOCOPY VARCHAR2) IS
        l_user_id           NUMBER := fnd_global.user_id;
        l_last_update_login NUMBER := fnd_global.login_id;
        l_vendor_id          NUMBER := 0;
        l_actions_request_id NUMBER;
        l_party_id_cs_1      VARCHAR(32767) := '';
        l_party_id_cs_2      VARCHAR(32767) := '';
        l_party_id_cs_3      VARCHAR(32767) := '';
        x_error_buff         VARCHAR(400);
        x_error_code         VARCHAR(2);
        actions_request_id   NUMBER := 0;

    BEGIN

        x_publication_event_id := get_curr_supp_pub_event_id;
        list_to_csv_varchar(p_party_id,
                            l_party_id_cs_1,
                            l_party_id_cs_2,
                            l_party_id_cs_3);


        actions_request_id   := fnd_request.submit_request('POS',
                                                           'POSSUPBO',
                                                           NULL,
                                                           NULL,
                                                           FALSE,
                                                           l_party_id_cs_1,
                                                           l_party_id_cs_2,
                                                           l_party_id_cs_3,
                                                           p_published_by,
                                                           p_publish_detail,
                                                           x_publication_event_id);
        x_actions_request_id := actions_request_id;


        COMMIT;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
    END create_supp_publish_event;

-- This routine is used to re raise the already published events
PROCEDURE create_supp_publish_event_hist (p_api_version       IN INTEGER,
                                        p_init_msg_list          IN VARCHAR2,
                                        p_publication_event_id   IN pos_tbl_number,
                                        x_return_status          OUT NOCOPY VARCHAR2,
                                        x_msg_count              OUT NOCOPY NUMBER,
                                        x_msg_data               OUT NOCOPY VARCHAR2) IS
      l_event_key           NUMBER := NULL;
      l_msg_data Varchar2(30000)   := null;
      l_msg_count NUMBER           :=0;
      l_user_id           NUMBER   := fnd_global.user_id;
      l_last_update_login NUMBER   := fnd_global.login_id;
    BEGIN

       FOR i IN p_publication_event_id.first .. p_publication_event_id.last LOOP
        -- Raising the Workflow event for already published events
      	l_event_key := raise_publish_supplier_event(p_publication_event_id(i));
        l_msg_data:=l_msg_data||p_publication_event_id(i)||',';
        l_msg_count:=l_msg_count+1;

        -- Update the Last login details etc., in pos_supp_pub_history table
        update pos_supp_pub_history set last_updated_by=l_user_id , last_update_date=sysdate,
        last_update_login=l_last_update_login  where publication_event_id=p_publication_event_id(i);
        commit;

       END LOOP;
       if (l_msg_count>0) then
        x_msg_data:=substr(l_msg_data,1,length(l_msg_data)-1);
       end if;
    EXCEPTION
        WHEN OTHERS THEN
            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
    END create_supp_publish_event_hist;

   ------------------------------------------
    /*#
    * Use this routine to Create Supplier Publication Event Response
    * @param p_publication_event_id The Publication event id
    * @param p_party_id  The party id
    * @param p_target_system The target spoke system id
    * @param p_pub_req_process_id The publication request process id
    * @param p_pub_req_process_stats The publication request process status
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Supplier Publication Event Response
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */

    PROCEDURE create_supp_publish_resp(p_publication_event_id  IN NUMBER,
                                       p_party_id              IN NUMBER,
                                       p_target_system         IN VARCHAR2,
                                       p_pub_req_process_id    IN NUMBER,
                                       p_pub_req_process_stats IN VARCHAR2) IS
        l_user_id           NUMBER := fnd_global.user_id;
        l_last_update_login NUMBER := fnd_global.login_id;


    BEGIN

        INSERT INTO pos_supp_pub_responses
            (publication_event_id,
             target_system,
             request_process_id,
             request_process_status,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
        VALUES
            (p_publication_event_id,
             p_target_system,
             p_pub_req_process_id,
             p_pub_req_process_stats,
             l_user_id,
             SYSDATE,
             l_user_id,
             SYSDATE,
             l_last_update_login);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END create_supp_publish_resp;

  --------------------------------------------
    /*#
    * Use this routine to Update Supplier Publication Event Response
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_commit The commit flag
    * @param p_validation_level The validation level
    * @param p_publication_event_id The Publication event id
    * @param p_party_id  The party id
    * @param p_target_system The target spoke system id
    * @param p_pub_resp_process_id The publication response process id
    * @param p_pub_resp_process_stats The publication response process status
    * @param p_target_system_resp_date The target system response date
    * @param p_error_message The error messages
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Update Supplier Publication Event Response
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE update_supp_pub_resp(p_api_version             IN NUMBER,
                                   p_init_msg_list           IN VARCHAR2,
                                   p_commit                  IN VARCHAR2,
                                   p_validation_level        IN NUMBER,
                                   p_publication_event_id    IN NUMBER,
                                   p_party_id                IN NUMBER,
                                   p_target_system           IN NUMBER,
                                   p_pub_resp_process_id     IN NUMBER,
                                   p_pub_resp_process_stats  IN VARCHAR2,
                                   p_target_system_resp_date IN DATE,
                                   p_error_message           IN VARCHAR2,
                                   x_return_status           OUT NOCOPY VARCHAR2,
                                   x_msg_count               OUT NOCOPY NUMBER,
                                   x_msg_data                OUT NOCOPY VARCHAR2) IS
        l_user_id           NUMBER := fnd_global.user_id;
        l_last_update_login NUMBER := fnd_global.login_id;
    BEGIN

        UPDATE pos_supp_pub_responses
        SET    response_process_id         = p_pub_resp_process_id,
               response_process_status     = p_pub_resp_process_id,
               target_system_response_date = p_target_system_resp_date,
               error_message               = p_error_message,
               last_updated_by             = l_user_id,
               last_update_date            = SYSDATE,
               last_update_login           = l_last_update_login
        WHERE  publication_event_id = p_publication_event_id
        AND    target_system = p_target_system
        AND    publication_event_id = p_publication_event_id
        AND    party_id = p_party_id;

    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
    END update_supp_pub_resp;
--------------------------------------
    FUNCTION raise_publish_supplier_event(p_publication_event_id NUMBER)
        RETURN NUMBER IS

        l_itemkey        NUMBER;
        l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
        l_event_name     VARCHAR2(50) := 'oracle.apps.pos.supplier.publish';
        l_message        VARCHAR2(50) := NULL;

        CURSOR c IS
            SELECT POS_SUPP_NOTIFY_WORKFLOW_S.nextval
            FROM   dual;

    BEGIN

        OPEN c;
        FETCH c
            INTO l_itemkey;
        CLOSE c;

        wf_event.addparametertolist(p_name          => 'PUBLICATION_EVENT_ID',
                                    p_value         => p_publication_event_id,
                                    p_parameterlist => l_parameter_list);

        wf_event.raise(
                p_event_name     => l_event_name,
                p_event_key      => l_itemkey,
                p_parameters     => l_parameter_list);

        l_parameter_list.DELETE;

        COMMIT;
        RETURN l_itemkey;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            fnd_file.put_line(fnd_file.log,'Exception:'||SQLCODE ||':'|| SQLERRM);
            ROLLBACK;
        WHEN fnd_api.g_exc_unexpected_error THEN
            fnd_file.put_line(fnd_file.log,'Exception:'||SQLCODE ||':'|| SQLERRM);
            ROLLBACK;
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,'Exception:'||SQLCODE ||':'|| SQLERRM);
            ROLLBACK;
    END raise_publish_supplier_event;

    PROCEDURE populate_bo_and_save_concur(x_errbuf                  OUT NOCOPY VARCHAR2,
                                          x_retcode                 OUT NOCOPY NUMBER,
                                          p_party_id_cs_1           IN VARCHAR2 DEFAULT '',
                                          p_party_id_cs_2           IN VARCHAR2 DEFAULT '',
                                          p_party_id_cs_3           IN VARCHAR2 DEFAULT '',
                                          p_published_by            IN VARCHAR2 DEFAULT '',
                                          p_publish_detail          IN VARCHAR2 DEFAULT '',
                                          p_publication_event_id_in IN VARCHAR2 DEFAULT '') IS
        l_pos_supplier_bo          pos_supplier_bo;
        x_return_status            VARCHAR2(100);
        x_msg_data                 VARCHAR2(100);
        x_msg_count                NUMBER;
        l_publication_event_id     NUMBER := NULL;
        p_publication_event_id_out NUMBER := NULL;
        p_party_id                 pos_tbl_number := pos_tbl_number();
        l_event_key                NUMBER := NULL;
    BEGIN
        SAVEPOINT populate_bo_and_save;

        p_party_id.extend(1);

        IF p_publication_event_id_in IS NULL THEN
            l_publication_event_id := get_curr_supp_pub_event_id;
        ELSE
            l_publication_event_id := p_publication_event_id_in;
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

        get_bo_and_insert(p_party_id,
                          l_publication_event_id,
                          p_published_by,
                          p_publish_detail);

        l_event_key := raise_publish_supplier_event(l_publication_event_id);
        x_retcode := 0;
        x_errbuf  := '';
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK TO populate_bo_and_save;
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
            fnd_file.put_line(fnd_file.log,'Exception:'||x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO populate_bo_and_save;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
            fnd_file.put_line(fnd_file.log,'Exception:'||x_msg_data);
        WHEN OTHERS THEN
            ROLLBACK TO populate_bo_and_save;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
            fnd_file.put_line(fnd_file.log,'Exception:'||x_msg_data);
    END;

    FUNCTION get_curr_supp_pub_event_id RETURN NUMBER IS

    BEGIN
        --checking for no zero value for current supplier publication event id, if not zero, then just return it, else find the next sequence and return
        --  IF g_curr_supp_publish_event_id = 0 THEN
        SELECT pos_supp_pub_event_s.nextval
        INTO   g_curr_supp_publish_event_id
        FROM   dual;
        --END IF;

        RETURN g_curr_supp_publish_event_id;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN - 1;
    END;

    PROCEDURE get_bo_and_insert(p_party_id             IN pos_tbl_number,
                                p_publication_event_id IN NUMBER,
                                p_published_by         IN NUMBER,
                                p_publish_detail       IN VARCHAR)

     IS
        l_user_id              NUMBER := fnd_global.user_id;
        l_last_update_login    NUMBER := fnd_global.login_id;
        l_request_id           NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        l_pos_supplier_bo      pos_supplier_bo;
        x_return_status        VARCHAR2(1000);
        x_msg_count            NUMBER := 0;
        x_msg_data             VARCHAR2(1000);
        l_xml_data             xmltype;
        l_xml_conversion_stats INTEGER := 0;
    BEGIN

        FOR i IN p_party_id.first .. p_party_id.last LOOP

           fnd_file.put_line(fnd_file.log,'Extracting the data for the Party Id:'||p_party_id(i));

           pos_supplier_bo_pkg.pos_get_supplier_bo(NULL,
                                                    NULL,
                                                    p_party_id(i),
                                                    NULL,
                                                    NULL,
                                                    l_pos_supplier_bo,
                                                    x_return_status,
                                                    x_msg_count,
                                                    x_msg_data);

            l_xml_conversion_stats := 0;
            BEGIN
                l_xml_data             := xmltype(l_pos_supplier_bo);
                l_xml_conversion_stats := 1;
            EXCEPTION
                WHEN OTHERS THEN
                     RAISE;

            END;
            IF l_xml_conversion_stats = 0 THEN
                GOTO exit1;
            END IF;

            fnd_file.put_line(fnd_file.log,'Inserting the XML Payload into pos_supp_pub_history table');
            INSERT INTO pos_supp_pub_history
                (publication_event_id,
                 party_id,
                 publication_date,
                 published_by,
                 publish_detail,
                 xmlcontent,
                 created_by,
                 creation_date,
                 last_updated_by,
                 last_update_date,
                 last_update_login,
                 request_id)
            VALUES
                (p_publication_event_id,
                 p_party_id(i),
                 SYSDATE, --                 p_publication_date,
                 p_published_by,
                 p_publish_detail,
                 l_xml_data,
                 l_user_id,
                 SYSDATE,
                 l_user_id,
                 SYSDATE,
                 l_last_update_login,
                 l_request_id);
            /*
            create_supp_publish_resp(p_publication_event_id,
                                     p_party_id(i),
                                     '',
                                     0,
                                     0);
                                     */
            <<exit1>>
            COMMIT;

        END LOOP;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
            fnd_file.put_line(fnd_file.log,'Exception:'||x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
            fnd_file.put_line(fnd_file.log,'Exception:'||x_msg_data);
        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
            fnd_file.put_line(fnd_file.log,'Exception:'||x_msg_data);
    END get_bo_and_insert;

    FUNCTION test_event_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)
        RETURN VARCHAR2 IS

    BEGIN
        --bu_debug_proc(1, '++ Publish Event raised ++ ');
        --bu_debug_proc(2, 'Event Name:' || p_event.geteventname());
        --bu_debug_proc(3, 'PUBLICATION_EVENT_ID:' || p_event.GetValueForParameter('PUBLICATION_EVENT_ID'));
        create_supp_publish_resp(p_event.GetValueForParameter('PUBLICATION_EVENT_ID'),
                                     '',
                                     'SIEBEL',
                                     0,
                                     'Y');
        RETURN 'SUCCESS';
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'FAILURE';
    END test_event_subscription;
 /*#
    * Use this routine to get party id list for given publication event id
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_publication_event_id The publication event id
    * @param x_party_id_cursor The list of party ids as cursor
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get Party Id list for a publication event id
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE get_partyids_per_event(p_api_version          IN NUMBER DEFAULT NULL,
                                     p_init_msg_list        IN VARCHAR2 DEFAULT NULL,
                                     p_publication_event_id IN NUMBER,
                                     x_party_id_cursor      OUT NOCOPY SYS_REFCURSOR,
                                     x_return_status        OUT NOCOPY VARCHAR2,
                                     x_msg_count            OUT NOCOPY NUMBER,
                                     x_msg_data             OUT NOCOPY VARCHAR2) IS
    BEGIN

        OPEN x_party_id_cursor FOR
            SELECT party_id
            FROM   pos_supp_pub_history
            WHERE  publication_event_id = p_publication_event_id;
    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
    END;

END pos_supp_pub_raise_event_pkg;

/
