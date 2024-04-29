--------------------------------------------------------
--  DDL for Package CN_PSUM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PSUM_PVT_W" AUTHID CURRENT_USER as
  /* $Header: cnwpsums.pls 115.5 2002/11/25 22:26:08 nkodkani ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_psum_pvt.psum_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_400
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cn_psum_pvt.psum_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_400
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_psum_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mgr_id  NUMBER
    , p_comp_group_id  NUMBER
    , p_mgr_dtl_flag  VARCHAR2
    , p_effective_date  date
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p11_a2 out nocopy JTF_NUMBER_TABLE
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a6 out nocopy JTF_NUMBER_TABLE
    , p11_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a8 out nocopy JTF_NUMBER_TABLE
    , p11_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a14 out nocopy JTF_DATE_TABLE
    , p11_a15 out nocopy JTF_DATE_TABLE
    , p11_a16 out nocopy JTF_NUMBER_TABLE
    , x_total_rows out nocopy  NUMBER
  );
  procedure get_mo_psum_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mgr_id  NUMBER
    , p_comp_group_id  NUMBER
    , p_mgr_dtl_flag  VARCHAR2
    , p_effective_date  date
    , p_is_multiorg  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_VARCHAR2_TABLE_400
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a8 out nocopy JTF_NUMBER_TABLE
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a14 out nocopy JTF_DATE_TABLE
    , p12_a15 out nocopy JTF_DATE_TABLE
    , p12_a16 out nocopy JTF_NUMBER_TABLE
    , x_total_rows out nocopy  NUMBER
  );
end cn_psum_pvt_w;

 

/
