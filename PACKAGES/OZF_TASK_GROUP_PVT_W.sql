--------------------------------------------------------
--  DDL for Package OZF_TASK_GROUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_TASK_GROUP_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwttgs.pls 115.0 2003/06/26 05:13:01 mchang noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ozf_task_group_pvt.task_group_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p1(t ozf_task_group_pvt.task_group_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure rosetta_table_copy_in_p5(t out nocopy ozf_task_group_pvt.ozf_sort_data, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t ozf_task_group_pvt.ozf_sort_data, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_task_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  DATE
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , x_task_template_group_id out nocopy  NUMBER
  );
  procedure update_task_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  DATE
    , p7_a8  VARCHAR2
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
  );
  procedure get_task_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_task_template_group_id  NUMBER
    , p_template_group_name  VARCHAR2
    , p_source_object_type_code  VARCHAR2
    , p_start_date_active  date
    , p_end_date_active  date
    , p11_a0 JTF_VARCHAR2_TABLE_100
    , p11_a1 JTF_VARCHAR2_TABLE_100
    , p12_a0  NUMBER
    , p12_a1  NUMBER
    , p12_a2  VARCHAR2
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p14_a0 out nocopy JTF_NUMBER_TABLE
    , p14_a1 out nocopy JTF_DATE_TABLE
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_DATE_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_DATE_TABLE
    , p14_a7 out nocopy JTF_DATE_TABLE
    , p14_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a9 out nocopy JTF_NUMBER_TABLE
    , p14_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p14_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p14_a28 out nocopy JTF_VARCHAR2_TABLE_4000
  );
  procedure validate_task_group(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  DATE
    , p6_a7  DATE
    , p6_a8  VARCHAR2
    , p6_a9  NUMBER
    , p6_a10  VARCHAR2
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  VARCHAR2
    , p6_a19  VARCHAR2
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  VARCHAR2
    , p6_a23  VARCHAR2
    , p6_a24  VARCHAR2
    , p6_a25  VARCHAR2
    , p6_a26  VARCHAR2
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
  );
  procedure check_task_group_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  DATE
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  DATE
    , p2_a7  DATE
    , p2_a8  VARCHAR2
    , p2_a9  NUMBER
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
  );
  procedure check_task_group_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  DATE
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  DATE
    , p1_a7  DATE
    , p1_a8  VARCHAR2
    , p1_a9  NUMBER
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  );
  procedure init_task_group_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  DATE
    , p0_a7 out nocopy  DATE
    , p0_a8 out nocopy  VARCHAR2
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  VARCHAR2
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  VARCHAR2
    , p0_a19 out nocopy  VARCHAR2
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  VARCHAR2
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  VARCHAR2
    , p0_a25 out nocopy  VARCHAR2
    , p0_a26 out nocopy  VARCHAR2
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
  );
  procedure complete_task_group_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  DATE
    , p0_a8  VARCHAR2
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  DATE
    , p1_a7 out nocopy  DATE
    , p1_a8 out nocopy  VARCHAR2
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  VARCHAR2
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  VARCHAR2
    , p1_a19 out nocopy  VARCHAR2
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  VARCHAR2
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  VARCHAR2
    , p1_a25 out nocopy  VARCHAR2
    , p1_a26 out nocopy  VARCHAR2
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
  );
end ozf_task_group_pvt_w;

 

/
