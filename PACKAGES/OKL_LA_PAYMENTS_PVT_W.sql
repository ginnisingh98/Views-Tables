--------------------------------------------------------
--  DDL for Package OKL_LA_PAYMENTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_PAYMENTS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEPYTS.pls 115.6 2003/11/15 01:28:58 ashariff noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy okl_la_payments_pvt.pym_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t okl_la_payments_pvt.pym_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p4(t out nocopy okl_la_payments_pvt.pym_del_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p4(t okl_la_payments_pvt.pym_del_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure process_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_service_fee_id  NUMBER
    , p_asset_id  NUMBER
    , p_payment_id  NUMBER
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_VARCHAR2_TABLE_500
    , p10_a2 JTF_VARCHAR2_TABLE_500
    , p10_a3 JTF_VARCHAR2_TABLE_500
    , p10_a4 JTF_VARCHAR2_TABLE_500
    , p10_a5 JTF_VARCHAR2_TABLE_500
    , p10_a6 JTF_VARCHAR2_TABLE_100
    , p_update_type  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a12 out nocopy JTF_NUMBER_TABLE
    , p12_a13 out nocopy JTF_NUMBER_TABLE
    , p12_a14 out nocopy JTF_NUMBER_TABLE
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a34 out nocopy JTF_NUMBER_TABLE
    , p12_a35 out nocopy JTF_DATE_TABLE
    , p12_a36 out nocopy JTF_NUMBER_TABLE
    , p12_a37 out nocopy JTF_DATE_TABLE
    , p12_a38 out nocopy JTF_NUMBER_TABLE
    , p12_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a59 out nocopy JTF_NUMBER_TABLE
    , p9_a0  VARCHAR2 := fnd_api.g_miss_char
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a5  VARCHAR2 := fnd_api.g_miss_char
  );
  procedure process_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_service_fee_id  NUMBER
    , p_asset_id  NUMBER
    , p_payment_id  NUMBER
    , p_update_type  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_DATE_TABLE
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_DATE_TABLE
    , p10_a38 out nocopy JTF_NUMBER_TABLE
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_NUMBER_TABLE
  );
  procedure delete_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
  );
end okl_la_payments_pvt_w;

 

/
