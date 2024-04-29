--------------------------------------------------------
--  DDL for Package AHL_VWP_TASKS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_VWP_TASKS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWTSKS.pls 120.2.12010000.3 2010/03/28 10:37:07 manesing ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_vwp_tasks_pvt.srch_task_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p1(t ahl_vwp_tasks_pvt.srch_task_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    );

  procedure get_task_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_task_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  DATE
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  VARCHAR2
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  DATE
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  VARCHAR2
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  NUMBER
    , p6_a61 out nocopy  NUMBER
    , p6_a62 out nocopy  VARCHAR2
    , p6_a63 out nocopy  NUMBER
    , p6_a64 out nocopy  VARCHAR2
    , p6_a65 out nocopy  VARCHAR2
    , p6_a66 out nocopy  DATE
    , p6_a67 out nocopy  DATE
    , p6_a68 out nocopy  VARCHAR2
    , p6_a69 out nocopy  VARCHAR2
    , p6_a70 out nocopy  VARCHAR2
    , p6_a71 out nocopy  NUMBER
    , p6_a72 out nocopy  VARCHAR2
    , p6_a73 out nocopy  NUMBER
    , p6_a74 out nocopy  VARCHAR2
    , p6_a75 out nocopy  VARCHAR2
    , p6_a76 out nocopy  DATE
    , p6_a77 out nocopy  DATE
    , p6_a78 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  NUMBER
    , p5_a23 in out nocopy  NUMBER
    , p5_a24 in out nocopy  NUMBER
    , p5_a25 in out nocopy  NUMBER
    , p5_a26 in out nocopy  NUMBER
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  NUMBER
    , p5_a34 in out nocopy  DATE
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  DATE
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  VARCHAR2
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  DATE
    , p5_a56 in out nocopy  DATE
    , p5_a57 in out nocopy  DATE
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  NUMBER
    , p5_a61 in out nocopy  NUMBER
    , p5_a62 in out nocopy  VARCHAR2
    , p5_a63 in out nocopy  NUMBER
    , p5_a64 in out nocopy  VARCHAR2
    , p5_a65 in out nocopy  VARCHAR2
    , p5_a66 in out nocopy  DATE
    , p5_a67 in out nocopy  DATE
    , p5_a68 in out nocopy  VARCHAR2
    , p5_a69 in out nocopy  VARCHAR2
    , p5_a70 in out nocopy  VARCHAR2
    , p5_a71 in out nocopy  NUMBER
    , p5_a72 in out nocopy  VARCHAR2
    , p5_a73 in out nocopy  NUMBER
    , p5_a74 in out nocopy  VARCHAR2
    , p5_a75 in out nocopy  VARCHAR2
    , p5_a76 in out nocopy  DATE
    , p5_a77 in out nocopy  DATE
    , p5_a78 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  NUMBER
    , p5_a2 in out nocopy  NUMBER
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  VARCHAR2
    , p5_a7 in out nocopy  NUMBER
    , p5_a8 in out nocopy  NUMBER
    , p5_a9 in out nocopy  NUMBER
    , p5_a10 in out nocopy  VARCHAR2
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  VARCHAR2
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR2
    , p5_a16 in out nocopy  NUMBER
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  NUMBER
    , p5_a19 in out nocopy  NUMBER
    , p5_a20 in out nocopy  NUMBER
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  NUMBER
    , p5_a23 in out nocopy  NUMBER
    , p5_a24 in out nocopy  NUMBER
    , p5_a25 in out nocopy  NUMBER
    , p5_a26 in out nocopy  NUMBER
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  NUMBER
    , p5_a34 in out nocopy  DATE
    , p5_a35 in out nocopy  NUMBER
    , p5_a36 in out nocopy  DATE
    , p5_a37 in out nocopy  NUMBER
    , p5_a38 in out nocopy  NUMBER
    , p5_a39 in out nocopy  VARCHAR2
    , p5_a40 in out nocopy  VARCHAR2
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  VARCHAR2
    , p5_a44 in out nocopy  VARCHAR2
    , p5_a45 in out nocopy  VARCHAR2
    , p5_a46 in out nocopy  VARCHAR2
    , p5_a47 in out nocopy  VARCHAR2
    , p5_a48 in out nocopy  VARCHAR2
    , p5_a49 in out nocopy  VARCHAR2
    , p5_a50 in out nocopy  VARCHAR2
    , p5_a51 in out nocopy  VARCHAR2
    , p5_a52 in out nocopy  VARCHAR2
    , p5_a53 in out nocopy  VARCHAR2
    , p5_a54 in out nocopy  VARCHAR2
    , p5_a55 in out nocopy  DATE
    , p5_a56 in out nocopy  DATE
    , p5_a57 in out nocopy  DATE
    , p5_a58 in out nocopy  VARCHAR2
    , p5_a59 in out nocopy  VARCHAR2
    , p5_a60 in out nocopy  NUMBER
    , p5_a61 in out nocopy  NUMBER
    , p5_a62 in out nocopy  VARCHAR2
    , p5_a63 in out nocopy  NUMBER
    , p5_a64 in out nocopy  VARCHAR2
    , p5_a65 in out nocopy  VARCHAR2
    , p5_a66 in out nocopy  DATE
    , p5_a67 in out nocopy  DATE
    , p5_a68 in out nocopy  VARCHAR2
    , p5_a69 in out nocopy  VARCHAR2
    , p5_a70 in out nocopy  VARCHAR2
    , p5_a71 in out nocopy  NUMBER
    , p5_a72 in out nocopy  VARCHAR2
    , p5_a73 in out nocopy  NUMBER
    , p5_a74 in out nocopy  VARCHAR2
    , p5_a75 in out nocopy  VARCHAR2
    , p5_a76 in out nocopy  DATE
    , p5_a77 in out nocopy  DATE
    , p5_a78 in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure search_task(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p_visit_id  NUMBER
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_DATE_TABLE
    , p6_a2 in out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure create_pup_tasks(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_NUMBER_TABLE
    , p5_a2 in out nocopy JTF_NUMBER_TABLE
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a11 in out nocopy JTF_NUMBER_TABLE
    , p5_a12 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_NUMBER_TABLE
    , p5_a15 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a16 in out nocopy JTF_NUMBER_TABLE
    , p5_a17 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a18 in out nocopy JTF_NUMBER_TABLE
    , p5_a19 in out nocopy JTF_NUMBER_TABLE
    , p5_a20 in out nocopy JTF_NUMBER_TABLE
    , p5_a21 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 in out nocopy JTF_NUMBER_TABLE
    , p5_a23 in out nocopy JTF_NUMBER_TABLE
    , p5_a24 in out nocopy JTF_NUMBER_TABLE
    , p5_a25 in out nocopy JTF_NUMBER_TABLE
    , p5_a26 in out nocopy JTF_NUMBER_TABLE
    , p5_a27 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a29 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a30 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a31 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a33 in out nocopy JTF_NUMBER_TABLE
    , p5_a34 in out nocopy JTF_DATE_TABLE
    , p5_a35 in out nocopy JTF_NUMBER_TABLE
    , p5_a36 in out nocopy JTF_DATE_TABLE
    , p5_a37 in out nocopy JTF_NUMBER_TABLE
    , p5_a38 in out nocopy JTF_NUMBER_TABLE
    , p5_a39 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a40 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a41 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a42 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a43 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a44 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a45 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a46 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a47 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a48 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a49 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a50 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a51 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a52 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a53 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a55 in out nocopy JTF_DATE_TABLE
    , p5_a56 in out nocopy JTF_DATE_TABLE
    , p5_a57 in out nocopy JTF_DATE_TABLE
    , p5_a58 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a59 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a60 in out nocopy JTF_NUMBER_TABLE
    , p5_a61 in out nocopy JTF_NUMBER_TABLE
    , p5_a62 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a63 in out nocopy JTF_NUMBER_TABLE
    , p5_a64 in out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a65 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a66 in out nocopy JTF_DATE_TABLE
    , p5_a67 in out nocopy JTF_DATE_TABLE
    , p5_a68 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a69 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a70 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a71 in out nocopy JTF_NUMBER_TABLE
    , p5_a72 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a73 in out nocopy JTF_NUMBER_TABLE
    , p5_a74 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a75 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a76 in out nocopy JTF_DATE_TABLE
    , p5_a77 in out nocopy JTF_DATE_TABLE
    , p5_a78 in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure associate_default_mrs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p8_a0  NUMBER
    , p8_a1  VARCHAR2
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  DATE
    , p8_a5  NUMBER
    , p8_a6  DATE
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  VARCHAR2
    , p8_a11  NUMBER
    , p8_a12  VARCHAR2
    , p8_a13  NUMBER
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  DATE
    , p8_a18  NUMBER
    , p8_a19  NUMBER
    , p8_a20  DATE
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  DATE
    , p8_a24  DATE
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , p8_a29  NUMBER
    , p8_a30  VARCHAR2
    , p8_a31  NUMBER
    , p8_a32  VARCHAR2
    , p8_a33  NUMBER
    , p8_a34  VARCHAR2
    , p8_a35  NUMBER
    , p8_a36  NUMBER
    , p8_a37  VARCHAR2
    , p8_a38  VARCHAR2
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  VARCHAR2
    , p8_a42  VARCHAR2
    , p8_a43  NUMBER
    , p8_a44  NUMBER
    , p8_a45  VARCHAR2
    , p8_a46  NUMBER
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  VARCHAR2
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  VARCHAR2
    , p8_a55  VARCHAR2
    , p8_a56  VARCHAR2
    , p8_a57  VARCHAR2
    , p8_a58  VARCHAR2
    , p8_a59  VARCHAR2
    , p8_a60  VARCHAR2
    , p8_a61  VARCHAR2
    , p8_a62  VARCHAR2
    , p8_a63  VARCHAR2
    , p8_a64  VARCHAR2
    , p8_a65  VARCHAR2
    , p8_a66  VARCHAR2
    , p8_a67  NUMBER
    , p8_a68  VARCHAR2
    , p8_a69  VARCHAR2
    , p8_a70  NUMBER
    , p8_a71  VARCHAR2
    , p8_a72  VARCHAR2
    , p8_a73  NUMBER
    , p8_a74  VARCHAR2
    , p8_a75  VARCHAR2
    , p8_a76  VARCHAR2
    , p8_a77  NUMBER
    , p8_a78  NUMBER
    , p8_a79  VARCHAR2
    , p8_a80  VARCHAR2
    , p8_a81  DATE
  );
end ahl_vwp_tasks_pvt_w;

/
