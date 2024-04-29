--------------------------------------------------------
--  DDL for Package IEM_AGENT_INBOX_MGMT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_AGENT_INBOX_MGMT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: IEMPAIMS.pls 120.1 2006/02/14 15:17 chtang noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iem_agent_inbox_mgmt_pvt.message_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_400
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_400
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p1(t iem_agent_inbox_mgmt_pvt.message_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_400
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_400
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy iem_agent_inbox_mgmt_pvt.temp_message_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_400
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_400
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t iem_agent_inbox_mgmt_pvt.temp_message_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_400
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_400
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p5(t out nocopy iem_agent_inbox_mgmt_pvt.resource_count_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_500
    );
  procedure rosetta_table_copy_out_p5(t iem_agent_inbox_mgmt_pvt.resource_count_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    );

  procedure search_messages_in_inbox(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_classification_id  NUMBER
    , p_subject  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_sender_name  VARCHAR2
    , p_sent_date_from  VARCHAR2
    , p_sent_date_to  VARCHAR2
    , p_sent_date_format  VARCHAR2
    , p_resource_name  VARCHAR2
    , p_resource_id  NUMBER
    , p_page_flag  NUMBER
    , p_sort_column  NUMBER
    , p_sort_state  VARCHAR2
    , p16_a0 out nocopy JTF_NUMBER_TABLE
    , p16_a1 out nocopy JTF_NUMBER_TABLE
    , p16_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p16_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p16_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a5 out nocopy JTF_VARCHAR2_TABLE_400
    , p16_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a7 out nocopy JTF_NUMBER_TABLE
    , p16_a8 out nocopy JTF_NUMBER_TABLE
    , p16_a9 out nocopy JTF_VARCHAR2_TABLE_400
    , p16_a10 out nocopy JTF_NUMBER_TABLE
    , p16_a11 out nocopy JTF_NUMBER_TABLE
    , p16_a12 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure show_agent_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_sort_column  NUMBER
    , p_sort_state  VARCHAR2
    , p_resource_role  NUMBER
    , p_resource_name  VARCHAR2
    , p_transferrer_id  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a2 out nocopy JTF_NUMBER_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end iem_agent_inbox_mgmt_pvt_w;

 

/
