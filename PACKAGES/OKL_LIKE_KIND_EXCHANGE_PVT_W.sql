--------------------------------------------------------
--  DDL for Package OKL_LIKE_KIND_EXCHANGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LIKE_KIND_EXCHANGE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLELKXS.pls 120.1 2005/07/11 14:18:30 asawanka noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy okl_like_kind_exchange_pvt.rep_asset_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t okl_like_kind_exchange_pvt.rep_asset_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p4(t out nocopy okl_like_kind_exchange_pvt.req_asset_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t okl_like_kind_exchange_pvt.req_asset_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_like_kind_exchange(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_corporate_book  VARCHAR2
    , p_tax_book  VARCHAR2
    , p_comments  VARCHAR2
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_2000
    , p9_a2 JTF_VARCHAR2_TABLE_2000
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_DATE_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_NUMBER_TABLE
    , p9_a10 JTF_NUMBER_TABLE
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  VARCHAR2 := fnd_api.g_miss_char
    , p8_a2  VARCHAR2 := fnd_api.g_miss_char
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  NUMBER := 0-1962.0724
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  NUMBER := 0-1962.0724
  );
end okl_like_kind_exchange_pvt_w;

 

/
