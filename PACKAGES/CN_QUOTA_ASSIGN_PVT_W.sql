--------------------------------------------------------
--  DDL for Package CN_QUOTA_ASSIGN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_ASSIGN_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwpnags.pls 120.4 2006/05/11 06:06 kjayapau noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_quota_assign_pvt.quota_assign_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_1900
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t cn_quota_assign_pvt.quota_assign_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_1900
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_quota_assign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_quota_assign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 in out nocopy  NUMBER
    , p4_a1 in out nocopy  NUMBER
    , p4_a2 in out nocopy  NUMBER
    , p4_a3 in out nocopy  VARCHAR2
    , p4_a4 in out nocopy  VARCHAR2
    , p4_a5 in out nocopy  DATE
    , p4_a6 in out nocopy  DATE
    , p4_a7 in out nocopy  NUMBER
    , p4_a8 in out nocopy  NUMBER
    , p4_a9 in out nocopy  NUMBER
    , p4_a10 in out nocopy  VARCHAR
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_quota_assign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  DATE
    , p4_a6  DATE
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  VARCHAR
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure get_quota_assign(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_comp_plan_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_NUMBER_TABLE
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_1900
    , p5_a5 out nocopy JTF_DATE_TABLE
    , p5_a6 out nocopy JTF_DATE_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cn_quota_assign_pvt_w;

 

/
