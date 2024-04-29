--------------------------------------------------------
--  DDL for Package IEM_SEARCHMESSAGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_SEARCHMESSAGE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: iemsearchs.pls 120.0 2005/06/02 13:44:47 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iem_searchmessage_pvt.message_rec_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t iem_searchmessage_pvt.message_rec_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure searchmessages(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_resource_id  NUMBER
    , p_email_queue  VARCHAR2
    , p_sent_date_from  VARCHAR2
    , p_sent_date_to  VARCHAR2
    , p_received_date_from  date
    , p_received_date_to  date
    , p_from_str  VARCHAR2
    , p_recepients  VARCHAR2
    , p_cc_flag  VARCHAR2
    , p_subject  VARCHAR2
    , p_message_body  VARCHAR2
    , p_customer_id  NUMBER
    , p_classification  VARCHAR2
    , p_resolved_agent  VARCHAR2
    , p_resolved_group  VARCHAR2
    , p19_a0 out nocopy JTF_NUMBER_TABLE
    , p19_a1 out nocopy JTF_NUMBER_TABLE
    , p19_a2 out nocopy JTF_VARCHAR2_TABLE_500
    , p19_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p19_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end iem_searchmessage_pvt_w;

 

/
