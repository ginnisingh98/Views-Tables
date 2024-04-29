--------------------------------------------------------
--  DDL for Package IEM_EMAILACCOUNT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMAILACCOUNT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: IEMVEMAS.pls 120.3.12010000.2 2009/08/27 06:12:28 shramana ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy iem_emailaccount_pub.emacnt_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t iem_emailaccount_pub.emacnt_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p4(t out nocopy iem_emailaccount_pub.msg_header_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p4(t iem_emailaccount_pub.msg_header_table, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p6(t out nocopy iem_emailaccount_pub.account_info_table, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t iem_emailaccount_pub.account_info_table, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy iem_emailaccount_pub.acntdetails_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t iem_emailaccount_pub.acntdetails_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy iem_emailaccount_pub.agntacntdetails_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p10(t iem_emailaccount_pub.agntacntdetails_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p12(t out nocopy iem_emailaccount_pub.agentacnt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_300
    , a7 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p12(t iem_emailaccount_pub.agentacnt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_300
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure get_emailaccount_list(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a3 out nocopy JTF_NUMBER_TABLE
  );
  procedure getemailheaders(p_agentname  VARCHAR2
    , p_top_n  INTEGER
    , p_top_option  INTEGER
    , p_folder_path  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure listagentaccounts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure listagentcpaccounts(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure listagentaccountdetails(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_roleid  NUMBER
    , p_resource_id  NUMBER
    , p_search_criteria  VARCHAR2
    , p_display_size  NUMBER
    , p_page_count  NUMBER
    , p_sort_by  VARCHAR2
    , p_sort_order  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_search_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a4 out nocopy JTF_VARCHAR2_TABLE_300
  );
  procedure listaccountdetails(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_300
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
  );
end iem_emailaccount_pub_w;

/
