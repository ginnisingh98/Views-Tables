--------------------------------------------------------
--  DDL for Package JTF_ASSIGN_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ASSIGN_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfampws.pls 120.2 2006/06/27 12:02:18 abraina ship $ */
  procedure rosetta_table_copy_in_p8(t out nocopy jtf_assign_pub.avail_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t jtf_assign_pub.avail_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p11(t out nocopy jtf_assign_pub.assignresources_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p11(t jtf_assign_pub.assignresources_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_300
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p24(t out nocopy jtf_assign_pub.prfeng_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p24(t jtf_assign_pub.prfeng_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p26(t out nocopy jtf_assign_pub.preferred_engineers_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p26(t jtf_assign_pub.preferred_engineers_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p28(t out nocopy jtf_assign_pub.escalations_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p28(t jtf_assign_pub.escalations_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p30(t out nocopy jtf_assign_pub.excluded_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p30(t jtf_assign_pub.excluded_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_assign_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_contracts_preferred_engineer  VARCHAR2
    , p_ib_preferred_engineer  VARCHAR2
    , p_contract_id  NUMBER
    , p_customer_product_id  NUMBER
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_web_availability_flag  VARCHAR2
    , p_category_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_inventory_org_id  NUMBER
    , p_problem_code  VARCHAR2
    , p_calling_doc_id  NUMBER
    , p_calling_doc_type  VARCHAR2
    , p_column_list  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p_filter_excluded_resource  VARCHAR2
    , p32_a0 out nocopy JTF_NUMBER_TABLE
    , p32_a1 out nocopy JTF_NUMBER_TABLE
    , p32_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a4 out nocopy JTF_DATE_TABLE
    , p32_a5 out nocopy JTF_DATE_TABLE
    , p32_a6 out nocopy JTF_NUMBER_TABLE
    , p32_a7 out nocopy JTF_NUMBER_TABLE
    , p32_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p32_a9 out nocopy JTF_NUMBER_TABLE
    , p32_a10 out nocopy JTF_NUMBER_TABLE
    , p32_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a15 out nocopy JTF_NUMBER_TABLE
    , p32_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a17 out nocopy JTF_NUMBER_TABLE
    , p32_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a19 out nocopy JTF_DATE_TABLE
    , p32_a20 out nocopy JTF_DATE_TABLE
    , p32_a21 out nocopy JTF_NUMBER_TABLE
    , p32_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p32_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a24 out nocopy JTF_NUMBER_TABLE
    , p32_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p32_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p26_a0  NUMBER := 0-1962.0724
    , p26_a1  NUMBER := 0-1962.0724
    , p26_a2  VARCHAR2 := fnd_api.g_miss_char
    , p26_a3  NUMBER := 0-1962.0724
    , p26_a4  VARCHAR2 := fnd_api.g_miss_char
    , p26_a5  VARCHAR2 := fnd_api.g_miss_char
    , p26_a6  VARCHAR2 := fnd_api.g_miss_char
    , p26_a7  VARCHAR2 := fnd_api.g_miss_char
    , p26_a8  VARCHAR2 := fnd_api.g_miss_char
    , p26_a9  VARCHAR2 := fnd_api.g_miss_char
    , p26_a10  VARCHAR2 := fnd_api.g_miss_char
    , p26_a11  NUMBER := 0-1962.0724
    , p26_a12  NUMBER := 0-1962.0724
    , p26_a13  NUMBER := 0-1962.0724
    , p26_a14  NUMBER := 0-1962.0724
    , p26_a15  VARCHAR2 := fnd_api.g_miss_char
    , p26_a16  NUMBER := 0-1962.0724
    , p26_a17  NUMBER := 0-1962.0724
    , p26_a18  NUMBER := 0-1962.0724
    , p26_a19  NUMBER := 0-1962.0724
    , p26_a20  VARCHAR2 := fnd_api.g_miss_char
    , p26_a21  NUMBER := 0-1962.0724
    , p26_a22  VARCHAR2 := fnd_api.g_miss_char
    , p26_a23  VARCHAR2 := fnd_api.g_miss_char
    , p26_a24  VARCHAR2 := fnd_api.g_miss_char
    , p26_a25  VARCHAR2 := fnd_api.g_miss_char
    , p26_a26  VARCHAR2 := fnd_api.g_miss_char
    , p26_a27  VARCHAR2 := fnd_api.g_miss_char
    , p26_a28  VARCHAR2 := fnd_api.g_miss_char
    , p26_a29  VARCHAR2 := fnd_api.g_miss_char
    , p26_a30  VARCHAR2 := fnd_api.g_miss_char
    , p26_a31  VARCHAR2 := fnd_api.g_miss_char
    , p26_a32  VARCHAR2 := fnd_api.g_miss_char
    , p26_a33  VARCHAR2 := fnd_api.g_miss_char
    , p26_a34  VARCHAR2 := fnd_api.g_miss_char
    , p26_a35  VARCHAR2 := fnd_api.g_miss_char
    , p26_a36  VARCHAR2 := fnd_api.g_miss_char
    , p26_a37  NUMBER := 0-1962.0724
    , p26_a38  NUMBER := 0-1962.0724
    , p26_a39  NUMBER := 0-1962.0724
    , p26_a40  NUMBER := 0-1962.0724
    , p26_a41  NUMBER := 0-1962.0724
    , p26_a42  NUMBER := 0-1962.0724
    , p26_a43  NUMBER := 0-1962.0724
    , p26_a44  NUMBER := 0-1962.0724
    , p26_a45  NUMBER := 0-1962.0724
    , p26_a46  NUMBER := 0-1962.0724
    , p26_a47  VARCHAR2 := fnd_api.g_miss_char
    , p26_a48  VARCHAR2 := fnd_api.g_miss_char
    , p26_a49  VARCHAR2 := fnd_api.g_miss_char
    , p26_a50  VARCHAR2 := fnd_api.g_miss_char
    , p26_a51  VARCHAR2 := fnd_api.g_miss_char
    , p26_a52  NUMBER := 0-1962.0724
    , p26_a53  NUMBER := 0-1962.0724
    , p27_a0  NUMBER := 0-1962.0724
    , p27_a1  NUMBER := 0-1962.0724
    , p27_a2  NUMBER := 0-1962.0724
    , p27_a3  VARCHAR2 := fnd_api.g_miss_char
    , p27_a4  NUMBER := 0-1962.0724
    , p27_a5  VARCHAR2 := fnd_api.g_miss_char
    , p27_a6  VARCHAR2 := fnd_api.g_miss_char
    , p27_a7  VARCHAR2 := fnd_api.g_miss_char
    , p27_a8  VARCHAR2 := fnd_api.g_miss_char
    , p27_a9  VARCHAR2 := fnd_api.g_miss_char
    , p27_a10  VARCHAR2 := fnd_api.g_miss_char
    , p27_a11  VARCHAR2 := fnd_api.g_miss_char
    , p27_a12  NUMBER := 0-1962.0724
    , p27_a13  NUMBER := 0-1962.0724
    , p27_a14  NUMBER := 0-1962.0724
    , p27_a15  NUMBER := 0-1962.0724
    , p27_a16  NUMBER := 0-1962.0724
    , p27_a17  NUMBER := 0-1962.0724
    , p27_a18  NUMBER := 0-1962.0724
    , p27_a19  VARCHAR2 := fnd_api.g_miss_char
    , p27_a20  NUMBER := 0-1962.0724
    , p27_a21  NUMBER := 0-1962.0724
    , p27_a22  NUMBER := 0-1962.0724
    , p27_a23  NUMBER := 0-1962.0724
    , p27_a24  VARCHAR2 := fnd_api.g_miss_char
    , p27_a25  NUMBER := 0-1962.0724
    , p27_a26  VARCHAR2 := fnd_api.g_miss_char
    , p27_a27  VARCHAR2 := fnd_api.g_miss_char
    , p27_a28  VARCHAR2 := fnd_api.g_miss_char
    , p27_a29  VARCHAR2 := fnd_api.g_miss_char
    , p27_a30  VARCHAR2 := fnd_api.g_miss_char
    , p27_a31  VARCHAR2 := fnd_api.g_miss_char
    , p27_a32  VARCHAR2 := fnd_api.g_miss_char
    , p27_a33  VARCHAR2 := fnd_api.g_miss_char
    , p27_a34  VARCHAR2 := fnd_api.g_miss_char
    , p27_a35  VARCHAR2 := fnd_api.g_miss_char
    , p27_a36  VARCHAR2 := fnd_api.g_miss_char
    , p27_a37  VARCHAR2 := fnd_api.g_miss_char
    , p27_a38  VARCHAR2 := fnd_api.g_miss_char
    , p27_a39  VARCHAR2 := fnd_api.g_miss_char
    , p27_a40  VARCHAR2 := fnd_api.g_miss_char
    , p27_a41  NUMBER := 0-1962.0724
    , p27_a42  NUMBER := 0-1962.0724
    , p27_a43  NUMBER := 0-1962.0724
    , p27_a44  NUMBER := 0-1962.0724
    , p27_a45  NUMBER := 0-1962.0724
    , p27_a46  NUMBER := 0-1962.0724
    , p27_a47  NUMBER := 0-1962.0724
    , p27_a48  NUMBER := 0-1962.0724
    , p27_a49  NUMBER := 0-1962.0724
    , p27_a50  NUMBER := 0-1962.0724
    , p27_a51  VARCHAR2 := fnd_api.g_miss_char
    , p27_a52  VARCHAR2 := fnd_api.g_miss_char
    , p27_a53  VARCHAR2 := fnd_api.g_miss_char
    , p27_a54  VARCHAR2 := fnd_api.g_miss_char
    , p27_a55  VARCHAR2 := fnd_api.g_miss_char
    , p27_a56  NUMBER := 0-1962.0724
    , p27_a57  NUMBER := 0-1962.0724
    , p28_a0  VARCHAR2 := fnd_api.g_miss_char
    , p28_a1  VARCHAR2 := fnd_api.g_miss_char
    , p28_a2  VARCHAR2 := fnd_api.g_miss_char
    , p28_a3  VARCHAR2 := fnd_api.g_miss_char
    , p28_a4  VARCHAR2 := fnd_api.g_miss_char
    , p28_a5  VARCHAR2 := fnd_api.g_miss_char
    , p28_a6  VARCHAR2 := fnd_api.g_miss_char
    , p28_a7  VARCHAR2 := fnd_api.g_miss_char
    , p28_a8  VARCHAR2 := fnd_api.g_miss_char
    , p28_a9  VARCHAR2 := fnd_api.g_miss_char
    , p28_a10  VARCHAR2 := fnd_api.g_miss_char
    , p28_a11  VARCHAR2 := fnd_api.g_miss_char
    , p28_a12  VARCHAR2 := fnd_api.g_miss_char
    , p28_a13  VARCHAR2 := fnd_api.g_miss_char
    , p28_a14  VARCHAR2 := fnd_api.g_miss_char
    , p28_a15  VARCHAR2 := fnd_api.g_miss_char
    , p28_a16  VARCHAR2 := fnd_api.g_miss_char
    , p28_a17  VARCHAR2 := fnd_api.g_miss_char
    , p28_a18  VARCHAR2 := fnd_api.g_miss_char
    , p28_a19  VARCHAR2 := fnd_api.g_miss_char
    , p28_a20  VARCHAR2 := fnd_api.g_miss_char
    , p28_a21  VARCHAR2 := fnd_api.g_miss_char
    , p28_a22  VARCHAR2 := fnd_api.g_miss_char
    , p28_a23  VARCHAR2 := fnd_api.g_miss_char
    , p28_a24  VARCHAR2 := fnd_api.g_miss_char
    , p28_a25  NUMBER := 0-1962.0724
    , p28_a26  NUMBER := 0-1962.0724
    , p28_a27  NUMBER := 0-1962.0724
    , p28_a28  NUMBER := 0-1962.0724
    , p28_a29  NUMBER := 0-1962.0724
    , p28_a30  NUMBER := 0-1962.0724
    , p28_a31  NUMBER := 0-1962.0724
    , p28_a32  NUMBER := 0-1962.0724
    , p28_a33  NUMBER := 0-1962.0724
    , p28_a34  NUMBER := 0-1962.0724
    , p28_a35  NUMBER := 0-1962.0724
    , p28_a36  NUMBER := 0-1962.0724
    , p28_a37  NUMBER := 0-1962.0724
    , p28_a38  NUMBER := 0-1962.0724
    , p28_a39  NUMBER := 0-1962.0724
    , p28_a40  NUMBER := 0-1962.0724
    , p28_a41  NUMBER := 0-1962.0724
    , p28_a42  NUMBER := 0-1962.0724
    , p28_a43  NUMBER := 0-1962.0724
    , p28_a44  NUMBER := 0-1962.0724
    , p28_a45  NUMBER := 0-1962.0724
    , p28_a46  NUMBER := 0-1962.0724
    , p28_a47  NUMBER := 0-1962.0724
    , p28_a48  NUMBER := 0-1962.0724
    , p28_a49  NUMBER := 0-1962.0724
    , p28_a50  VARCHAR2 := fnd_api.g_miss_char
    , p28_a51  VARCHAR2 := fnd_api.g_miss_char
    , p28_a52  VARCHAR2 := fnd_api.g_miss_char
    , p28_a53  VARCHAR2 := fnd_api.g_miss_char
    , p28_a54  VARCHAR2 := fnd_api.g_miss_char
    , p28_a55  VARCHAR2 := fnd_api.g_miss_char
    , p28_a56  VARCHAR2 := fnd_api.g_miss_char
    , p28_a57  VARCHAR2 := fnd_api.g_miss_char
    , p28_a58  VARCHAR2 := fnd_api.g_miss_char
    , p28_a59  VARCHAR2 := fnd_api.g_miss_char
    , p28_a60  VARCHAR2 := fnd_api.g_miss_char
    , p28_a61  VARCHAR2 := fnd_api.g_miss_char
    , p28_a62  VARCHAR2 := fnd_api.g_miss_char
    , p28_a63  VARCHAR2 := fnd_api.g_miss_char
    , p28_a64  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_assign_task_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_contracts_preferred_engineer  VARCHAR2
    , p_ib_preferred_engineer  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_web_availability_flag  VARCHAR2
    , p_task_id  NUMBER
    , p_column_list  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p_filter_excluded_resource  VARCHAR2
    , p20_a0 out nocopy JTF_NUMBER_TABLE
    , p20_a1 out nocopy JTF_NUMBER_TABLE
    , p20_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a4 out nocopy JTF_DATE_TABLE
    , p20_a5 out nocopy JTF_DATE_TABLE
    , p20_a6 out nocopy JTF_NUMBER_TABLE
    , p20_a7 out nocopy JTF_NUMBER_TABLE
    , p20_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a9 out nocopy JTF_NUMBER_TABLE
    , p20_a10 out nocopy JTF_NUMBER_TABLE
    , p20_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a15 out nocopy JTF_NUMBER_TABLE
    , p20_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a17 out nocopy JTF_NUMBER_TABLE
    , p20_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a19 out nocopy JTF_DATE_TABLE
    , p20_a20 out nocopy JTF_DATE_TABLE
    , p20_a21 out nocopy JTF_NUMBER_TABLE
    , p20_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p20_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a24 out nocopy JTF_NUMBER_TABLE
    , p20_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_assign_dr_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_contracts_preferred_engineer  VARCHAR2
    , p_ib_preferred_engineer  VARCHAR2
    , p_contract_id  NUMBER
    , p_customer_product_id  NUMBER
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_web_availability_flag  VARCHAR2
    , p_category_id  NUMBER
    , p_inventory_item_id  NUMBER
    , p_inventory_org_id  NUMBER
    , p_problem_code  VARCHAR2
    , p_dr_id  NUMBER
    , p_column_list  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p_filter_excluded_resource  VARCHAR2
    , p27_a0 out nocopy JTF_NUMBER_TABLE
    , p27_a1 out nocopy JTF_NUMBER_TABLE
    , p27_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a4 out nocopy JTF_DATE_TABLE
    , p27_a5 out nocopy JTF_DATE_TABLE
    , p27_a6 out nocopy JTF_NUMBER_TABLE
    , p27_a7 out nocopy JTF_NUMBER_TABLE
    , p27_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p27_a9 out nocopy JTF_NUMBER_TABLE
    , p27_a10 out nocopy JTF_NUMBER_TABLE
    , p27_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a15 out nocopy JTF_NUMBER_TABLE
    , p27_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a17 out nocopy JTF_NUMBER_TABLE
    , p27_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a19 out nocopy JTF_DATE_TABLE
    , p27_a20 out nocopy JTF_DATE_TABLE
    , p27_a21 out nocopy JTF_NUMBER_TABLE
    , p27_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p27_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a24 out nocopy JTF_NUMBER_TABLE
    , p27_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p27_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p23_a0  NUMBER := 0-1962.0724
    , p23_a1  NUMBER := 0-1962.0724
    , p23_a2  NUMBER := 0-1962.0724
    , p23_a3  VARCHAR2 := fnd_api.g_miss_char
    , p23_a4  NUMBER := 0-1962.0724
    , p23_a5  VARCHAR2 := fnd_api.g_miss_char
    , p23_a6  VARCHAR2 := fnd_api.g_miss_char
    , p23_a7  VARCHAR2 := fnd_api.g_miss_char
    , p23_a8  VARCHAR2 := fnd_api.g_miss_char
    , p23_a9  VARCHAR2 := fnd_api.g_miss_char
    , p23_a10  VARCHAR2 := fnd_api.g_miss_char
    , p23_a11  VARCHAR2 := fnd_api.g_miss_char
    , p23_a12  NUMBER := 0-1962.0724
    , p23_a13  NUMBER := 0-1962.0724
    , p23_a14  NUMBER := 0-1962.0724
    , p23_a15  NUMBER := 0-1962.0724
    , p23_a16  NUMBER := 0-1962.0724
    , p23_a17  NUMBER := 0-1962.0724
    , p23_a18  NUMBER := 0-1962.0724
    , p23_a19  VARCHAR2 := fnd_api.g_miss_char
    , p23_a20  NUMBER := 0-1962.0724
    , p23_a21  NUMBER := 0-1962.0724
    , p23_a22  NUMBER := 0-1962.0724
    , p23_a23  NUMBER := 0-1962.0724
    , p23_a24  VARCHAR2 := fnd_api.g_miss_char
    , p23_a25  NUMBER := 0-1962.0724
    , p23_a26  VARCHAR2 := fnd_api.g_miss_char
    , p23_a27  VARCHAR2 := fnd_api.g_miss_char
    , p23_a28  VARCHAR2 := fnd_api.g_miss_char
    , p23_a29  VARCHAR2 := fnd_api.g_miss_char
    , p23_a30  VARCHAR2 := fnd_api.g_miss_char
    , p23_a31  VARCHAR2 := fnd_api.g_miss_char
    , p23_a32  VARCHAR2 := fnd_api.g_miss_char
    , p23_a33  VARCHAR2 := fnd_api.g_miss_char
    , p23_a34  VARCHAR2 := fnd_api.g_miss_char
    , p23_a35  VARCHAR2 := fnd_api.g_miss_char
    , p23_a36  VARCHAR2 := fnd_api.g_miss_char
    , p23_a37  VARCHAR2 := fnd_api.g_miss_char
    , p23_a38  VARCHAR2 := fnd_api.g_miss_char
    , p23_a39  VARCHAR2 := fnd_api.g_miss_char
    , p23_a40  VARCHAR2 := fnd_api.g_miss_char
    , p23_a41  NUMBER := 0-1962.0724
    , p23_a42  NUMBER := 0-1962.0724
    , p23_a43  NUMBER := 0-1962.0724
    , p23_a44  NUMBER := 0-1962.0724
    , p23_a45  NUMBER := 0-1962.0724
    , p23_a46  NUMBER := 0-1962.0724
    , p23_a47  NUMBER := 0-1962.0724
    , p23_a48  NUMBER := 0-1962.0724
    , p23_a49  NUMBER := 0-1962.0724
    , p23_a50  NUMBER := 0-1962.0724
    , p23_a51  VARCHAR2 := fnd_api.g_miss_char
    , p23_a52  VARCHAR2 := fnd_api.g_miss_char
    , p23_a53  VARCHAR2 := fnd_api.g_miss_char
    , p23_a54  VARCHAR2 := fnd_api.g_miss_char
    , p23_a55  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_assign_oppr_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a4 out nocopy JTF_DATE_TABLE
    , p15_a5 out nocopy JTF_DATE_TABLE
    , p15_a6 out nocopy JTF_NUMBER_TABLE
    , p15_a7 out nocopy JTF_NUMBER_TABLE
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a9 out nocopy JTF_NUMBER_TABLE
    , p15_a10 out nocopy JTF_NUMBER_TABLE
    , p15_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a15 out nocopy JTF_NUMBER_TABLE
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a17 out nocopy JTF_NUMBER_TABLE
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a19 out nocopy JTF_DATE_TABLE
    , p15_a20 out nocopy JTF_DATE_TABLE
    , p15_a21 out nocopy JTF_NUMBER_TABLE
    , p15_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a24 out nocopy JTF_NUMBER_TABLE
    , p15_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
    , p12_a3  VARCHAR2 := fnd_api.g_miss_char
    , p12_a4  VARCHAR2 := fnd_api.g_miss_char
    , p12_a5  VARCHAR2 := fnd_api.g_miss_char
    , p12_a6  VARCHAR2 := fnd_api.g_miss_char
    , p12_a7  VARCHAR2 := fnd_api.g_miss_char
    , p12_a8  NUMBER := 0-1962.0724
    , p12_a9  NUMBER := 0-1962.0724
    , p12_a10  NUMBER := 0-1962.0724
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  NUMBER := 0-1962.0724
    , p12_a13  NUMBER := 0-1962.0724
    , p12_a14  NUMBER := 0-1962.0724
    , p12_a15  VARCHAR2 := fnd_api.g_miss_char
    , p12_a16  NUMBER := 0-1962.0724
    , p12_a17  VARCHAR2 := fnd_api.g_miss_char
    , p12_a18  NUMBER := 0-1962.0724
    , p12_a19  NUMBER := 0-1962.0724
    , p12_a20  VARCHAR2 := fnd_api.g_miss_char
    , p12_a21  NUMBER := 0-1962.0724
    , p12_a22  VARCHAR2 := fnd_api.g_miss_char
    , p12_a23  VARCHAR2 := fnd_api.g_miss_char
    , p12_a24  NUMBER := 0-1962.0724
    , p12_a25  VARCHAR2 := fnd_api.g_miss_char
    , p12_a26  DATE := fnd_api.g_miss_date
    , p12_a27  VARCHAR2 := fnd_api.g_miss_char
    , p12_a28  NUMBER := 0-1962.0724
    , p12_a29  NUMBER := 0-1962.0724
    , p12_a30  NUMBER := 0-1962.0724
    , p12_a31  NUMBER := 0-1962.0724
    , p12_a32  NUMBER := 0-1962.0724
    , p12_a33  NUMBER := 0-1962.0724
    , p12_a34  NUMBER := 0-1962.0724
    , p12_a35  VARCHAR2 := fnd_api.g_miss_char
    , p12_a36  VARCHAR2 := fnd_api.g_miss_char
    , p12_a37  VARCHAR2 := fnd_api.g_miss_char
    , p12_a38  VARCHAR2 := fnd_api.g_miss_char
    , p12_a39  VARCHAR2 := fnd_api.g_miss_char
    , p12_a40  VARCHAR2 := fnd_api.g_miss_char
    , p12_a41  VARCHAR2 := fnd_api.g_miss_char
    , p12_a42  VARCHAR2 := fnd_api.g_miss_char
    , p12_a43  VARCHAR2 := fnd_api.g_miss_char
    , p12_a44  VARCHAR2 := fnd_api.g_miss_char
    , p12_a45  VARCHAR2 := fnd_api.g_miss_char
    , p12_a46  VARCHAR2 := fnd_api.g_miss_char
    , p12_a47  VARCHAR2 := fnd_api.g_miss_char
    , p12_a48  VARCHAR2 := fnd_api.g_miss_char
    , p12_a49  VARCHAR2 := fnd_api.g_miss_char
    , p12_a50  NUMBER := 0-1962.0724
  );
  procedure get_assign_lead_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a4 out nocopy JTF_DATE_TABLE
    , p15_a5 out nocopy JTF_DATE_TABLE
    , p15_a6 out nocopy JTF_NUMBER_TABLE
    , p15_a7 out nocopy JTF_NUMBER_TABLE
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a9 out nocopy JTF_NUMBER_TABLE
    , p15_a10 out nocopy JTF_NUMBER_TABLE
    , p15_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a15 out nocopy JTF_NUMBER_TABLE
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a17 out nocopy JTF_NUMBER_TABLE
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a19 out nocopy JTF_DATE_TABLE
    , p15_a20 out nocopy JTF_DATE_TABLE
    , p15_a21 out nocopy JTF_NUMBER_TABLE
    , p15_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a24 out nocopy JTF_NUMBER_TABLE
    , p15_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0  NUMBER := 0-1962.0724
    , p12_a1  NUMBER := 0-1962.0724
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
    , p12_a3  VARCHAR2 := fnd_api.g_miss_char
    , p12_a4  VARCHAR2 := fnd_api.g_miss_char
    , p12_a5  VARCHAR2 := fnd_api.g_miss_char
    , p12_a6  VARCHAR2 := fnd_api.g_miss_char
    , p12_a7  VARCHAR2 := fnd_api.g_miss_char
    , p12_a8  NUMBER := 0-1962.0724
    , p12_a9  NUMBER := 0-1962.0724
    , p12_a10  NUMBER := 0-1962.0724
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  NUMBER := 0-1962.0724
    , p12_a13  NUMBER := 0-1962.0724
    , p12_a14  NUMBER := 0-1962.0724
    , p12_a15  VARCHAR2 := fnd_api.g_miss_char
    , p12_a16  NUMBER := 0-1962.0724
    , p12_a17  VARCHAR2 := fnd_api.g_miss_char
    , p12_a18  NUMBER := 0-1962.0724
    , p12_a19  NUMBER := 0-1962.0724
    , p12_a20  VARCHAR2 := fnd_api.g_miss_char
    , p12_a21  NUMBER := 0-1962.0724
    , p12_a22  VARCHAR2 := fnd_api.g_miss_char
    , p12_a23  NUMBER := 0-1962.0724
    , p12_a24  VARCHAR2 := fnd_api.g_miss_char
    , p12_a25  DATE := fnd_api.g_miss_date
    , p12_a26  NUMBER := 0-1962.0724
    , p12_a27  NUMBER := 0-1962.0724
    , p12_a28  NUMBER := 0-1962.0724
    , p12_a29  NUMBER := 0-1962.0724
    , p12_a30  NUMBER := 0-1962.0724
    , p12_a31  NUMBER := 0-1962.0724
    , p12_a32  VARCHAR2 := fnd_api.g_miss_char
    , p12_a33  VARCHAR2 := fnd_api.g_miss_char
    , p12_a34  VARCHAR2 := fnd_api.g_miss_char
    , p12_a35  VARCHAR2 := fnd_api.g_miss_char
    , p12_a36  VARCHAR2 := fnd_api.g_miss_char
    , p12_a37  VARCHAR2 := fnd_api.g_miss_char
    , p12_a38  VARCHAR2 := fnd_api.g_miss_char
    , p12_a39  VARCHAR2 := fnd_api.g_miss_char
    , p12_a40  VARCHAR2 := fnd_api.g_miss_char
    , p12_a41  VARCHAR2 := fnd_api.g_miss_char
    , p12_a42  VARCHAR2 := fnd_api.g_miss_char
    , p12_a43  VARCHAR2 := fnd_api.g_miss_char
    , p12_a44  VARCHAR2 := fnd_api.g_miss_char
    , p12_a45  VARCHAR2 := fnd_api.g_miss_char
    , p12_a46  VARCHAR2 := fnd_api.g_miss_char
    , p12_a47  NUMBER := 0-1962.0724
  );
  procedure get_assign_account_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p15_a0 out nocopy JTF_NUMBER_TABLE
    , p15_a1 out nocopy JTF_NUMBER_TABLE
    , p15_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a4 out nocopy JTF_DATE_TABLE
    , p15_a5 out nocopy JTF_DATE_TABLE
    , p15_a6 out nocopy JTF_NUMBER_TABLE
    , p15_a7 out nocopy JTF_NUMBER_TABLE
    , p15_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p15_a9 out nocopy JTF_NUMBER_TABLE
    , p15_a10 out nocopy JTF_NUMBER_TABLE
    , p15_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a15 out nocopy JTF_NUMBER_TABLE
    , p15_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a17 out nocopy JTF_NUMBER_TABLE
    , p15_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a19 out nocopy JTF_DATE_TABLE
    , p15_a20 out nocopy JTF_DATE_TABLE
    , p15_a21 out nocopy JTF_NUMBER_TABLE
    , p15_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p15_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a24 out nocopy JTF_NUMBER_TABLE
    , p15_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p15_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p12_a0  VARCHAR2 := fnd_api.g_miss_char
    , p12_a1  VARCHAR2 := fnd_api.g_miss_char
    , p12_a2  VARCHAR2 := fnd_api.g_miss_char
    , p12_a3  VARCHAR2 := fnd_api.g_miss_char
    , p12_a4  VARCHAR2 := fnd_api.g_miss_char
    , p12_a5  VARCHAR2 := fnd_api.g_miss_char
    , p12_a6  NUMBER := 0-1962.0724
    , p12_a7  NUMBER := 0-1962.0724
    , p12_a8  NUMBER := 0-1962.0724
    , p12_a9  NUMBER := 0-1962.0724
    , p12_a10  NUMBER := 0-1962.0724
    , p12_a11  NUMBER := 0-1962.0724
    , p12_a12  NUMBER := 0-1962.0724
    , p12_a13  VARCHAR2 := fnd_api.g_miss_char
    , p12_a14  NUMBER := 0-1962.0724
    , p12_a15  VARCHAR2 := fnd_api.g_miss_char
    , p12_a16  NUMBER := 0-1962.0724
    , p12_a17  NUMBER := 0-1962.0724
    , p12_a18  VARCHAR2 := fnd_api.g_miss_char
    , p12_a19  NUMBER := 0-1962.0724
    , p12_a20  VARCHAR2 := fnd_api.g_miss_char
    , p12_a21  VARCHAR2 := fnd_api.g_miss_char
    , p12_a22  VARCHAR2 := fnd_api.g_miss_char
    , p12_a23  VARCHAR2 := fnd_api.g_miss_char
    , p12_a24  VARCHAR2 := fnd_api.g_miss_char
    , p12_a25  VARCHAR2 := fnd_api.g_miss_char
    , p12_a26  VARCHAR2 := fnd_api.g_miss_char
    , p12_a27  VARCHAR2 := fnd_api.g_miss_char
    , p12_a28  VARCHAR2 := fnd_api.g_miss_char
    , p12_a29  VARCHAR2 := fnd_api.g_miss_char
    , p12_a30  VARCHAR2 := fnd_api.g_miss_char
    , p12_a31  VARCHAR2 := fnd_api.g_miss_char
    , p12_a32  VARCHAR2 := fnd_api.g_miss_char
    , p12_a33  VARCHAR2 := fnd_api.g_miss_char
    , p12_a34  VARCHAR2 := fnd_api.g_miss_char
    , p12_a35  VARCHAR2 := fnd_api.g_miss_char
    , p12_a36  NUMBER := 0-1962.0724
  );
  procedure get_assign_esc_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , p_no_of_resources  NUMBER
    , p_auto_select_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , p_territory_flag  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_web_availability_flag  VARCHAR2
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_VARCHAR2_TABLE_100
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p16_a0 out nocopy JTF_NUMBER_TABLE
    , p16_a1 out nocopy JTF_NUMBER_TABLE
    , p16_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a4 out nocopy JTF_DATE_TABLE
    , p16_a5 out nocopy JTF_DATE_TABLE
    , p16_a6 out nocopy JTF_NUMBER_TABLE
    , p16_a7 out nocopy JTF_NUMBER_TABLE
    , p16_a8 out nocopy JTF_VARCHAR2_TABLE_300
    , p16_a9 out nocopy JTF_NUMBER_TABLE
    , p16_a10 out nocopy JTF_NUMBER_TABLE
    , p16_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a15 out nocopy JTF_NUMBER_TABLE
    , p16_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a17 out nocopy JTF_NUMBER_TABLE
    , p16_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a19 out nocopy JTF_DATE_TABLE
    , p16_a20 out nocopy JTF_DATE_TABLE
    , p16_a21 out nocopy JTF_NUMBER_TABLE
    , p16_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p16_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a24 out nocopy JTF_NUMBER_TABLE
    , p16_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_excluded_resources(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_contract_id  NUMBER
    , p_customer_product_id  NUMBER
    , p_calling_doc_id  NUMBER
    , p_calling_doc_type  VARCHAR2
    , p_business_process_id  NUMBER
    , p_business_process_date  date
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  NUMBER := 0-1962.0724
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  NUMBER := 0-1962.0724
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  NUMBER := 0-1962.0724
    , p7_a53  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  VARCHAR2 := fnd_api.g_miss_char
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  VARCHAR2 := fnd_api.g_miss_char
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  VARCHAR2 := fnd_api.g_miss_char
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  VARCHAR2 := fnd_api.g_miss_char
    , p8_a12  NUMBER := 0-1962.0724
    , p8_a13  NUMBER := 0-1962.0724
    , p8_a14  NUMBER := 0-1962.0724
    , p8_a15  NUMBER := 0-1962.0724
    , p8_a16  NUMBER := 0-1962.0724
    , p8_a17  NUMBER := 0-1962.0724
    , p8_a18  NUMBER := 0-1962.0724
    , p8_a19  VARCHAR2 := fnd_api.g_miss_char
    , p8_a20  NUMBER := 0-1962.0724
    , p8_a21  NUMBER := 0-1962.0724
    , p8_a22  NUMBER := 0-1962.0724
    , p8_a23  NUMBER := 0-1962.0724
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  NUMBER := 0-1962.0724
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  VARCHAR2 := fnd_api.g_miss_char
    , p8_a37  VARCHAR2 := fnd_api.g_miss_char
    , p8_a38  VARCHAR2 := fnd_api.g_miss_char
    , p8_a39  VARCHAR2 := fnd_api.g_miss_char
    , p8_a40  VARCHAR2 := fnd_api.g_miss_char
    , p8_a41  NUMBER := 0-1962.0724
    , p8_a42  NUMBER := 0-1962.0724
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  NUMBER := 0-1962.0724
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  NUMBER := 0-1962.0724
    , p8_a48  NUMBER := 0-1962.0724
    , p8_a49  NUMBER := 0-1962.0724
    , p8_a50  NUMBER := 0-1962.0724
    , p8_a51  VARCHAR2 := fnd_api.g_miss_char
    , p8_a52  VARCHAR2 := fnd_api.g_miss_char
    , p8_a53  VARCHAR2 := fnd_api.g_miss_char
    , p8_a54  VARCHAR2 := fnd_api.g_miss_char
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  NUMBER := 0-1962.0724
    , p8_a57  NUMBER := 0-1962.0724
    , p9_a0  NUMBER := 0-1962.0724
    , p9_a1  NUMBER := 0-1962.0724
    , p9_a2  NUMBER := 0-1962.0724
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  NUMBER := 0-1962.0724
    , p9_a5  VARCHAR2 := fnd_api.g_miss_char
    , p9_a6  VARCHAR2 := fnd_api.g_miss_char
    , p9_a7  VARCHAR2 := fnd_api.g_miss_char
    , p9_a8  VARCHAR2 := fnd_api.g_miss_char
    , p9_a9  VARCHAR2 := fnd_api.g_miss_char
    , p9_a10  VARCHAR2 := fnd_api.g_miss_char
    , p9_a11  VARCHAR2 := fnd_api.g_miss_char
    , p9_a12  NUMBER := 0-1962.0724
    , p9_a13  NUMBER := 0-1962.0724
    , p9_a14  NUMBER := 0-1962.0724
    , p9_a15  NUMBER := 0-1962.0724
    , p9_a16  NUMBER := 0-1962.0724
    , p9_a17  NUMBER := 0-1962.0724
    , p9_a18  NUMBER := 0-1962.0724
    , p9_a19  VARCHAR2 := fnd_api.g_miss_char
    , p9_a20  NUMBER := 0-1962.0724
    , p9_a21  NUMBER := 0-1962.0724
    , p9_a22  NUMBER := 0-1962.0724
    , p9_a23  NUMBER := 0-1962.0724
    , p9_a24  VARCHAR2 := fnd_api.g_miss_char
    , p9_a25  NUMBER := 0-1962.0724
    , p9_a26  VARCHAR2 := fnd_api.g_miss_char
    , p9_a27  VARCHAR2 := fnd_api.g_miss_char
    , p9_a28  VARCHAR2 := fnd_api.g_miss_char
    , p9_a29  VARCHAR2 := fnd_api.g_miss_char
    , p9_a30  VARCHAR2 := fnd_api.g_miss_char
    , p9_a31  VARCHAR2 := fnd_api.g_miss_char
    , p9_a32  VARCHAR2 := fnd_api.g_miss_char
    , p9_a33  VARCHAR2 := fnd_api.g_miss_char
    , p9_a34  VARCHAR2 := fnd_api.g_miss_char
    , p9_a35  VARCHAR2 := fnd_api.g_miss_char
    , p9_a36  VARCHAR2 := fnd_api.g_miss_char
    , p9_a37  VARCHAR2 := fnd_api.g_miss_char
    , p9_a38  VARCHAR2 := fnd_api.g_miss_char
    , p9_a39  VARCHAR2 := fnd_api.g_miss_char
    , p9_a40  VARCHAR2 := fnd_api.g_miss_char
    , p9_a41  NUMBER := 0-1962.0724
    , p9_a42  NUMBER := 0-1962.0724
    , p9_a43  NUMBER := 0-1962.0724
    , p9_a44  NUMBER := 0-1962.0724
    , p9_a45  NUMBER := 0-1962.0724
    , p9_a46  NUMBER := 0-1962.0724
    , p9_a47  NUMBER := 0-1962.0724
    , p9_a48  NUMBER := 0-1962.0724
    , p9_a49  NUMBER := 0-1962.0724
    , p9_a50  NUMBER := 0-1962.0724
    , p9_a51  VARCHAR2 := fnd_api.g_miss_char
    , p9_a52  VARCHAR2 := fnd_api.g_miss_char
    , p9_a53  VARCHAR2 := fnd_api.g_miss_char
    , p9_a54  VARCHAR2 := fnd_api.g_miss_char
    , p9_a55  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure get_resource_availability(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_calendar_flag  VARCHAR2
    , p_effort_duration  NUMBER
    , p_effort_uom  VARCHAR2
    , p_breakdown  NUMBER
    , p_breakdown_uom  VARCHAR2
    , p_planned_start_date  date
    , p_planned_end_date  date
    , p_continuous_task  VARCHAR2
    , x_return_status in out nocopy  VARCHAR2
    , x_msg_count in out nocopy  NUMBER
    , x_msg_data in out nocopy  VARCHAR2
    , p14_a0 in out nocopy JTF_NUMBER_TABLE
    , p14_a1 in out nocopy JTF_NUMBER_TABLE
    , p14_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a4 in out nocopy JTF_DATE_TABLE
    , p14_a5 in out nocopy JTF_DATE_TABLE
    , p14_a6 in out nocopy JTF_NUMBER_TABLE
    , p14_a7 in out nocopy JTF_NUMBER_TABLE
    , p14_a8 in out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a9 in out nocopy JTF_NUMBER_TABLE
    , p14_a10 in out nocopy JTF_NUMBER_TABLE
    , p14_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a13 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a14 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a15 in out nocopy JTF_NUMBER_TABLE
    , p14_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a17 in out nocopy JTF_NUMBER_TABLE
    , p14_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a19 in out nocopy JTF_DATE_TABLE
    , p14_a20 in out nocopy JTF_DATE_TABLE
    , p14_a21 in out nocopy JTF_NUMBER_TABLE
    , p14_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a23 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a24 in out nocopy JTF_NUMBER_TABLE
    , p14_a25 in out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a26 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end jtf_assign_pub_w;

 

/
