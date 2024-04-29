--------------------------------------------------------
--  DDL for Package CN_PLAN_ELEMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PLAN_ELEMENT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwpes.pls 120.2.12000000.2 2007/10/08 18:56:21 rnagired ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_plan_element_pvt.plan_element_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_1900
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_4000
    , a16 JTF_VARCHAR2_TABLE_4000
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_VARCHAR2_TABLE_100
    , a43 JTF_VARCHAR2_TABLE_100
    , a44 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t cn_plan_element_pvt.plan_element_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_1900
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_4000
    , a16 out nocopy JTF_VARCHAR2_TABLE_4000
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_VARCHAR2_TABLE_100
    , a42 out nocopy JTF_VARCHAR2_TABLE_100
    , a43 out nocopy JTF_VARCHAR2_TABLE_100
    , a44 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure is_valid_org(p_org_id  NUMBER
    , p_quota_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
  procedure create_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR
    , p4_a16 in out nocopy  VARCHAR
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  VARCHAR2
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  NUMBER
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  VARCHAR2
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR
    , p4_a16 in out nocopy  VARCHAR
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  VARCHAR2
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  NUMBER
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  VARCHAR2
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  VARCHAR2
    , p4_a2 in out nocopy  VARCHAR2
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  NUMBER
    , p4_a5 in out nocopy  NUMBER
    , p4_a6 in out nocopy  NUMBER
    , p4_a7 in out nocopy  VARCHAR2
    , p4_a8 in out nocopy  DATE
    , p4_a9 in out nocopy  DATE
    , p4_a10 in out nocopy  NUMBER
    , p4_a11 in out nocopy  NUMBER
    , p4_a12 in out nocopy  NUMBER
    , p4_a13 in out nocopy  NUMBER
    , p4_a14 in out nocopy  NUMBER
    , p4_a15 in out nocopy  VARCHAR
    , p4_a16 in out nocopy  VARCHAR
    , p4_a17 in out nocopy  VARCHAR2
    , p4_a18 in out nocopy  VARCHAR2
    , p4_a19 in out nocopy  VARCHAR2
    , p4_a20 in out nocopy  VARCHAR2
    , p4_a21 in out nocopy  VARCHAR2
    , p4_a22 in out nocopy  VARCHAR2
    , p4_a23 in out nocopy  VARCHAR2
    , p4_a24 in out nocopy  VARCHAR2
    , p4_a25 in out nocopy  VARCHAR2
    , p4_a26 in out nocopy  VARCHAR2
    , p4_a27 in out nocopy  VARCHAR2
    , p4_a28 in out nocopy  VARCHAR2
    , p4_a29 in out nocopy  VARCHAR2
    , p4_a30 in out nocopy  VARCHAR2
    , p4_a31 in out nocopy  VARCHAR2
    , p4_a32 in out nocopy  VARCHAR2
    , p4_a33 in out nocopy  VARCHAR2
    , p4_a34 in out nocopy  VARCHAR2
    , p4_a35 in out nocopy  VARCHAR2
    , p4_a36 in out nocopy  VARCHAR2
    , p4_a37 in out nocopy  VARCHAR2
    , p4_a38 in out nocopy  VARCHAR2
    , p4_a39 in out nocopy  NUMBER
    , p4_a40 in out nocopy  NUMBER
    , p4_a41 in out nocopy  VARCHAR2
    , p4_a42 in out nocopy  VARCHAR2
    , p4_a43 in out nocopy  VARCHAR2
    , p4_a44 in out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure duplicate_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_quota_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  VARCHAR2
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  NUMBER
    , p5_a5 out nocopy  NUMBER
    , p5_a6 out nocopy  NUMBER
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  DATE
    , p5_a9 out nocopy  DATE
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  NUMBER
    , p5_a12 out nocopy  NUMBER
    , p5_a13 out nocopy  NUMBER
    , p5_a14 out nocopy  NUMBER
    , p5_a15 out nocopy  VARCHAR
    , p5_a16 out nocopy  VARCHAR
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  VARCHAR2
    , p5_a19 out nocopy  VARCHAR2
    , p5_a20 out nocopy  VARCHAR2
    , p5_a21 out nocopy  VARCHAR2
    , p5_a22 out nocopy  VARCHAR2
    , p5_a23 out nocopy  VARCHAR2
    , p5_a24 out nocopy  VARCHAR2
    , p5_a25 out nocopy  VARCHAR2
    , p5_a26 out nocopy  VARCHAR2
    , p5_a27 out nocopy  VARCHAR2
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  VARCHAR2
    , p5_a31 out nocopy  VARCHAR2
    , p5_a32 out nocopy  VARCHAR2
    , p5_a33 out nocopy  VARCHAR2
    , p5_a34 out nocopy  VARCHAR2
    , p5_a35 out nocopy  VARCHAR2
    , p5_a36 out nocopy  VARCHAR2
    , p5_a37 out nocopy  VARCHAR2
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  NUMBER
    , p5_a40 out nocopy  NUMBER
    , p5_a41 out nocopy  VARCHAR2
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  VARCHAR2
    , p5_a44 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
  );
  procedure validate_plan_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_action  VARCHAR2
    , p5_a0 in out nocopy  NUMBER
    , p5_a1 in out nocopy  VARCHAR2
    , p5_a2 in out nocopy  VARCHAR2
    , p5_a3 in out nocopy  VARCHAR2
    , p5_a4 in out nocopy  NUMBER
    , p5_a5 in out nocopy  NUMBER
    , p5_a6 in out nocopy  NUMBER
    , p5_a7 in out nocopy  VARCHAR2
    , p5_a8 in out nocopy  DATE
    , p5_a9 in out nocopy  DATE
    , p5_a10 in out nocopy  NUMBER
    , p5_a11 in out nocopy  NUMBER
    , p5_a12 in out nocopy  NUMBER
    , p5_a13 in out nocopy  NUMBER
    , p5_a14 in out nocopy  NUMBER
    , p5_a15 in out nocopy  VARCHAR
    , p5_a16 in out nocopy  VARCHAR
    , p5_a17 in out nocopy  VARCHAR2
    , p5_a18 in out nocopy  VARCHAR2
    , p5_a19 in out nocopy  VARCHAR2
    , p5_a20 in out nocopy  VARCHAR2
    , p5_a21 in out nocopy  VARCHAR2
    , p5_a22 in out nocopy  VARCHAR2
    , p5_a23 in out nocopy  VARCHAR2
    , p5_a24 in out nocopy  VARCHAR2
    , p5_a25 in out nocopy  VARCHAR2
    , p5_a26 in out nocopy  VARCHAR2
    , p5_a27 in out nocopy  VARCHAR2
    , p5_a28 in out nocopy  VARCHAR2
    , p5_a29 in out nocopy  VARCHAR2
    , p5_a30 in out nocopy  VARCHAR2
    , p5_a31 in out nocopy  VARCHAR2
    , p5_a32 in out nocopy  VARCHAR2
    , p5_a33 in out nocopy  VARCHAR2
    , p5_a34 in out nocopy  VARCHAR2
    , p5_a35 in out nocopy  VARCHAR2
    , p5_a36 in out nocopy  VARCHAR2
    , p5_a37 in out nocopy  VARCHAR2
    , p5_a38 in out nocopy  VARCHAR2
    , p5_a39 in out nocopy  NUMBER
    , p5_a40 in out nocopy  NUMBER
    , p5_a41 in out nocopy  VARCHAR2
    , p5_a42 in out nocopy  VARCHAR2
    , p5_a43 in out nocopy  VARCHAR2
    , p5_a44 in out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  VARCHAR2
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  DATE
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  NUMBER
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  VARCHAR
    , p6_a16  VARCHAR
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
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  NUMBER
    , p6_a40  NUMBER
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cn_plan_element_pvt_w;

 

/
