--------------------------------------------------------
--  DDL for Package JTF_TASK_INST_TEMPLATES_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_INST_TEMPLATES_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfpttws.pls 120.3 2006/04/26 04:36 knayyar ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_task_inst_templates_pub.task_details_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t jtf_task_inst_templates_pub.task_details_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_task_inst_templates_pub.task_contact_points_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t jtf_task_inst_templates_pub.task_contact_points_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy jtf_task_inst_templates_pub.task_template_info_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_4000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_VARCHAR2_TABLE_200
    , a38 JTF_VARCHAR2_TABLE_200
    , a39 JTF_VARCHAR2_TABLE_200
    , a40 JTF_VARCHAR2_TABLE_200
    , a41 JTF_VARCHAR2_TABLE_200
    , a42 JTF_VARCHAR2_TABLE_200
    , a43 JTF_VARCHAR2_TABLE_200
    , a44 JTF_VARCHAR2_TABLE_200
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p6(t jtf_task_inst_templates_pub.task_template_info_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_4000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_100
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_VARCHAR2_TABLE_200
    , a38 out nocopy JTF_VARCHAR2_TABLE_200
    , a39 out nocopy JTF_VARCHAR2_TABLE_200
    , a40 out nocopy JTF_VARCHAR2_TABLE_200
    , a41 out nocopy JTF_VARCHAR2_TABLE_200
    , a42 out nocopy JTF_VARCHAR2_TABLE_200
    , a43 out nocopy JTF_VARCHAR2_TABLE_200
    , a44 out nocopy JTF_VARCHAR2_TABLE_200
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_task_from_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  NUMBER
    , p3_a3  NUMBER
    , p3_a4  VARCHAR2
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  DATE
    , p3_a10  DATE
    , p3_a11  DATE
    , p3_a12  DATE
    , p3_a13  DATE
    , p3_a14  DATE
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  VARCHAR2
    , p3_a21  NUMBER
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  NUMBER
    , p3_a31  NUMBER
    , p3_a32  VARCHAR2
    , p3_a33  VARCHAR2
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  VARCHAR2
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  VARCHAR2
    , p3_a47  VARCHAR2
    , p3_a48  VARCHAR2
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  NUMBER
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_VARCHAR2_TABLE_100
    , p4_a2 JTF_VARCHAR2_TABLE_4000
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_VARCHAR2_TABLE_100
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_DATE_TABLE
    , p4_a9 JTF_DATE_TABLE
    , p4_a10 JTF_DATE_TABLE
    , p4_a11 JTF_DATE_TABLE
    , p4_a12 JTF_DATE_TABLE
    , p4_a13 JTF_DATE_TABLE
    , p4_a14 JTF_VARCHAR2_TABLE_100
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_VARCHAR2_TABLE_100
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_VARCHAR2_TABLE_100
    , p4_a20 JTF_VARCHAR2_TABLE_100
    , p4_a21 JTF_VARCHAR2_TABLE_100
    , p4_a22 JTF_VARCHAR2_TABLE_100
    , p4_a23 JTF_VARCHAR2_TABLE_100
    , p4_a24 JTF_VARCHAR2_TABLE_100
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_VARCHAR2_TABLE_100
    , p4_a27 JTF_VARCHAR2_TABLE_100
    , p4_a28 JTF_VARCHAR2_TABLE_100
    , p4_a29 JTF_VARCHAR2_TABLE_100
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_VARCHAR2_TABLE_200
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_VARCHAR2_TABLE_200
    , p4_a42 JTF_VARCHAR2_TABLE_200
    , p4_a43 JTF_VARCHAR2_TABLE_200
    , p4_a44 JTF_VARCHAR2_TABLE_200
    , p4_a45 JTF_VARCHAR2_TABLE_100
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_NUMBER_TABLE
  );
end jtf_task_inst_templates_pub_w;

 

/
