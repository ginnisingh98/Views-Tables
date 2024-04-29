--------------------------------------------------------
--  DDL for Package POS_SUPP_PUB_RAISE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SUPP_PUB_RAISE_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: POSSPPBES.pls 120.0.12010000.2 2010/02/08 14:17:58 ntungare noship $ */
    -- Author  : JAYASANKAR
    -- Created : 8/19/2009 2:42:12 PM
    -- Purpose : Supplier Publish Event
    g_curr_supp_publish_event_id NUMBER := 0;
    --PROCEDURE raise_publish_supplier_event;
    PROCEDURE create_supp_publish_event(p_api_version          IN INTEGER,
                                        p_init_msg_list        IN VARCHAR2,
                                        p_party_id             IN pos_tbl_number,
                                        p_published_by         IN INTEGER,
                                        p_publish_detail       IN VARCHAR,
                                        x_publication_event_id OUT NOCOPY NUMBER,
                                        x_actions_request_id   OUT NOCOPY NUMBER,
                                        x_return_status        OUT NOCOPY VARCHAR2,
                                        x_msg_count            OUT NOCOPY NUMBER,
                                        x_msg_data             OUT NOCOPY VARCHAR2);

    PROCEDURE create_supp_publish_event_hist (p_api_version       IN INTEGER,
                                        p_init_msg_list          IN VARCHAR2,
                                        p_publication_event_id   IN pos_tbl_number,
                                        x_return_status          OUT NOCOPY VARCHAR2,
                                        x_msg_count              OUT NOCOPY NUMBER,
                                        x_msg_data               OUT NOCOPY VARCHAR2);

    PROCEDURE create_supp_publish_resp(p_publication_event_id  IN NUMBER,
                                       p_party_id              IN NUMBER,
                                       p_target_system         IN VARCHAR2,
                                       p_pub_req_process_id    IN NUMBER,
                                       p_pub_req_process_stats IN VARCHAR2);

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
                                   x_msg_data                OUT NOCOPY VARCHAR2);
    FUNCTION get_curr_supp_pub_event_id RETURN NUMBER;
    FUNCTION raise_publish_supplier_event(p_publication_event_id NUMBER)
        RETURN NUMBER;
    PROCEDURE populate_bo_and_save_concur(x_errbuf                  OUT NOCOPY VARCHAR2,
                                          x_retcode                 OUT NOCOPY NUMBER,
                                          p_party_id_cs_1           IN VARCHAR2 DEFAULT '',
                                          p_party_id_cs_2           IN VARCHAR2 DEFAULT '',
                                          p_party_id_cs_3           IN VARCHAR2 DEFAULT '',
                                          p_published_by            IN VARCHAR2 DEFAULT '',
                                          p_publish_detail          IN VARCHAR2 DEFAULT '',
                                          p_publication_event_id_in IN VARCHAR2 DEFAULT '');
    PROCEDURE get_bo_and_insert(p_party_id             IN pos_tbl_number,
                                p_publication_event_id IN NUMBER,
                                p_published_by         IN NUMBER,
                                p_publish_detail       IN VARCHAR);

    FUNCTION test_event_subscription(p_subscription_guid IN RAW,
                                     p_event             IN OUT NOCOPY wf_event_t)
        RETURN VARCHAR2;

END pos_supp_pub_raise_event_pkg;

/
