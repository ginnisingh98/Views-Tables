--------------------------------------------------------
--  DDL for Package OKL_PERD_STATUS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PERD_STATUS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEPSMS.pls 120.1 2005/07/11 14:19:33 asawanka noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_perd_status_pvt.period_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_DATE_TABLE
    , a23 JTF_DATE_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t okl_perd_status_pvt.period_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_DATE_TABLE
    , a23 out nocopy JTF_DATE_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure search_period_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_DATE_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_NUMBER_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_DATE_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a22 out nocopy JTF_DATE_TABLE
    , p6_a23 out nocopy JTF_DATE_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure update_period_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_DATE_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_VARCHAR2_TABLE_200
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_200
    , p5_a20 JTF_VARCHAR2_TABLE_200
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_DATE_TABLE
    , p5_a23 JTF_DATE_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_VARCHAR2_TABLE_100
  );
  procedure update_perd_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  DATE := fnd_api.g_miss_date
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  DATE := fnd_api.g_miss_date
    , p5_a23  DATE := fnd_api.g_miss_date
    , p5_a24  NUMBER := 0-1962.0724
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
  );
end okl_perd_status_pvt_w;

 

/
