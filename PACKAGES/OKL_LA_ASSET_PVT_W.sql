--------------------------------------------------------
--  DDL for Package OKL_LA_ASSET_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_ASSET_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLELAAS.pls 120.5.12010000.2 2010/04/29 16:34:23 rpillay ship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy okl_la_asset_pvt.fin_adj_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t okl_la_asset_pvt.fin_adj_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy okl_la_asset_pvt.las_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_300
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t okl_la_asset_pvt.las_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_300
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure generate_asset_summary(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_DATE_TABLE
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_DATE_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  DATE := fnd_api.g_miss_date
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR := fnd_api.g_miss_char
    , p5_a18  NUMBER := 0-1962.0724
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_contract_line(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_id  NUMBER
    , p_date_delivery_expected  date
    , p_date_funding_expected  date
    , p_org_id  NUMBER
    , p_organization_id  NUMBER
  );
  procedure update_fin_cap_cost(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
  );
  procedure iscontractactive(p_dnz_chr_id  NUMBER
    , p_deal_type  VARCHAR2
    , p_sts_code  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end okl_la_asset_pvt_w;

/