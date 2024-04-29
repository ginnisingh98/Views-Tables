--------------------------------------------------------
--  DDL for Package IEM_QUEUE_MANAGEMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_QUEUE_MANAGEMENT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: IEMPQUMS.pls 120.1 2006/02/13 14:32 chtang noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iem_queue_management_pvt.message_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_400
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p1(t iem_queue_management_pvt.message_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_400
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy iem_queue_management_pvt.temp_message_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_400
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t iem_queue_management_pvt.temp_message_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_400
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out nocopy iem_queue_management_pvt.resource_count_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_500
    );
  procedure rosetta_table_copy_out_p5(t iem_queue_management_pvt.resource_count_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    );

  procedure rosetta_table_copy_in_p7(t out nocopy iem_queue_management_pvt.resource_group_count_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t iem_queue_management_pvt.resource_group_count_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure search_messages_in_queue(p_api_version_number  NUMBER
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
    , p_group_id  NUMBER
    , p_sort_column  NUMBER
    , p_sort_state  VARCHAR2
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_NUMBER_TABLE
    , p14_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p14_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a5 out nocopy JTF_VARCHAR2_TABLE_400
    , p14_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p14_a7 out nocopy JTF_NUMBER_TABLE
    , p14_a8 out nocopy JTF_NUMBER_TABLE
    , p14_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a10 out nocopy JTF_DATE_TABLE
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
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure show_resource_group_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_sort_column  NUMBER
    , p_sort_state  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end iem_queue_management_pvt_w;

 

/
