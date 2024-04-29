--------------------------------------------------------
--  DDL for Package OKL_BLK_AST_UPD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BLK_AST_UPD_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEBAUS.pls 120.0 2007/05/25 13:16:57 asawanka noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_blk_ast_upd_pvt.okl_loc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p23(t okl_blk_ast_upd_pvt.okl_loc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    );

  procedure update_location(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  VARCHAR2 := fnd_api.g_miss_char
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  DATE := fnd_api.g_miss_date
  );
  procedure update_location(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_VARCHAR2_TABLE_100
    , p2_a7 JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_blk_ast_upd_pvt_w;

/
