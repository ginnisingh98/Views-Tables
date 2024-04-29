--------------------------------------------------------
--  DDL for Package CN_TSR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TSR_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwtsrs.pls 115.6 2002/11/25 22:32:42 nkodkani ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_tsr_pvt.tsr_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cn_tsr_pvt.tsr_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_tsr_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mgr_id  NUMBER
    , p_comp_group_id  NUMBER
    , p_org_code  VARCHAR2
    , p_period_id  date
    , p_start_row  NUMBER
    , p_rows  NUMBER
    , p13_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a4 out nocopy JTF_NUMBER_TABLE
    , p13_a5 out nocopy JTF_NUMBER_TABLE
    , x_total_rows out nocopy  NUMBER
    , download  VARCHAR2
  );
end cn_tsr_pvt_w;

 

/
