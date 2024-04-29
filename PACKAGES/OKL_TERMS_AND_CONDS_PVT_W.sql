--------------------------------------------------------
--  DDL for Package OKL_TERMS_AND_CONDS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TERMS_AND_CONDS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLUSZTS.pls 120.1 2005/07/20 10:11:30 dkagrawa noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_terms_and_conds_pvt.trm_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t okl_terms_and_conds_pvt.trm_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_terms_conditions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_type  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
  );
end okl_terms_and_conds_pvt_w;

 

/
