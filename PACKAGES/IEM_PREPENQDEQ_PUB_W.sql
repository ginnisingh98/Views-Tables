--------------------------------------------------------
--  DDL for Package IEM_PREPENQDEQ_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_PREPENQDEQ_PUB_W" AUTHID CURRENT_USER as
  /* $Header: IEMVPEQS.pls 115.2 2000/03/04 11:11:23 pkm ship      $ */
  procedure proc_enqueue(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_msg_id  NUMBER
    , p_msg_size  NUMBER
    , p_sender_name  VARCHAR2
    , p_user_name  VARCHAR2
    , p_domain_name  VARCHAR2
    , p_priority  VARCHAR2
    , p_msg_status  VARCHAR2
    , p_subject VARCHAR2
    , p_sent_date  date
    , p_customer_id  NUMBER
    , p_product_id  NUMBER
    , p_classification  VARCHAR2
    , p_score_percent  NUMBER
    , p_info_id  NUMBER
    , p_key1  VARCHAR2
    , p_val1  VARCHAR2
    , p_key2  VARCHAR2
    , p_val2  VARCHAR2
    , p_key3  VARCHAR2
    , p_val3  VARCHAR2
    , p_key4  VARCHAR2
    , p_val4  VARCHAR2
    , p_key5  VARCHAR2
    , p_val5  VARCHAR2
    , p_key6  VARCHAR2
    , p_val6  VARCHAR2
    , p_key7  VARCHAR2
    , p_val7  VARCHAR2
    , p_key8  VARCHAR2
    , p_val8  VARCHAR2
    , p_key9  VARCHAR2
    , p_val9  VARCHAR2
    , p_key10  VARCHAR2
    , p_val10  VARCHAR2
    , x_msg_count out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_data out  VARCHAR2
  );
end iem_prepenqdeq_pub_w;

 

/
