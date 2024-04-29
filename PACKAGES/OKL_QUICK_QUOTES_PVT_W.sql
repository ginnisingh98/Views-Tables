--------------------------------------------------------
--  DDL for Package OKL_QUICK_QUOTES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QUICK_QUOTES_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEQQHS.pls 120.3 2006/02/10 07:40:59 asawanka noship $ */
  procedure rosetta_table_copy_in_p8(t out nocopy okl_quick_quotes_pvt.rent_payments_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p8(t okl_quick_quotes_pvt.rent_payments_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy okl_quick_quotes_pvt.fee_service_payments_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p10(t okl_quick_quotes_pvt.fee_service_payments_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p12(t out nocopy okl_quick_quotes_pvt.item_order_estimate_tbl, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p12(t okl_quick_quotes_pvt.item_order_estimate_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    );

  procedure create_quick_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_500
    , p7_a4 JTF_VARCHAR2_TABLE_500
    , p7_a5 JTF_VARCHAR2_TABLE_500
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_VARCHAR2_TABLE_100
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_VARCHAR2_TABLE_300
    , p7_a29 JTF_VARCHAR2_TABLE_2000
    , p7_a30 JTF_VARCHAR2_TABLE_2000
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_NUMBER_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure update_quick_qte(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_VARCHAR2_TABLE_100
    , p7_a3 JTF_VARCHAR2_TABLE_500
    , p7_a4 JTF_VARCHAR2_TABLE_500
    , p7_a5 JTF_VARCHAR2_TABLE_500
    , p7_a6 JTF_VARCHAR2_TABLE_500
    , p7_a7 JTF_VARCHAR2_TABLE_500
    , p7_a8 JTF_VARCHAR2_TABLE_500
    , p7_a9 JTF_VARCHAR2_TABLE_500
    , p7_a10 JTF_VARCHAR2_TABLE_500
    , p7_a11 JTF_VARCHAR2_TABLE_500
    , p7_a12 JTF_VARCHAR2_TABLE_500
    , p7_a13 JTF_VARCHAR2_TABLE_500
    , p7_a14 JTF_VARCHAR2_TABLE_500
    , p7_a15 JTF_VARCHAR2_TABLE_500
    , p7_a16 JTF_VARCHAR2_TABLE_500
    , p7_a17 JTF_VARCHAR2_TABLE_500
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_VARCHAR2_TABLE_100
    , p7_a20 JTF_VARCHAR2_TABLE_100
    , p7_a21 JTF_NUMBER_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_NUMBER_TABLE
    , p7_a25 JTF_NUMBER_TABLE
    , p7_a26 JTF_NUMBER_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_VARCHAR2_TABLE_300
    , p7_a29 JTF_VARCHAR2_TABLE_2000
    , p7_a30 JTF_VARCHAR2_TABLE_2000
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a21 out nocopy JTF_NUMBER_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_NUMBER_TABLE
    , p8_a25 out nocopy JTF_NUMBER_TABLE
    , p8_a26 out nocopy JTF_NUMBER_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p8_a30 out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure delete_qql(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
  );
  procedure delete_qql(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_2000
    , p5_a30 JTF_VARCHAR2_TABLE_2000
  );
  procedure handle_quick_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_500
    , p6_a4 JTF_VARCHAR2_TABLE_500
    , p6_a5 JTF_VARCHAR2_TABLE_500
    , p6_a6 JTF_VARCHAR2_TABLE_500
    , p6_a7 JTF_VARCHAR2_TABLE_500
    , p6_a8 JTF_VARCHAR2_TABLE_500
    , p6_a9 JTF_VARCHAR2_TABLE_500
    , p6_a10 JTF_VARCHAR2_TABLE_500
    , p6_a11 JTF_VARCHAR2_TABLE_500
    , p6_a12 JTF_VARCHAR2_TABLE_500
    , p6_a13 JTF_VARCHAR2_TABLE_500
    , p6_a14 JTF_VARCHAR2_TABLE_500
    , p6_a15 JTF_VARCHAR2_TABLE_500
    , p6_a16 JTF_VARCHAR2_TABLE_500
    , p6_a17 JTF_VARCHAR2_TABLE_500
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_NUMBER_TABLE
    , p6_a25 JTF_NUMBER_TABLE
    , p6_a26 JTF_NUMBER_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_VARCHAR2_TABLE_300
    , p6_a29 JTF_VARCHAR2_TABLE_2000
    , p6_a30 JTF_VARCHAR2_TABLE_2000
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
    , p7_a7  VARCHAR2
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_DATE_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_100
    , p8_a9 JTF_VARCHAR2_TABLE_100
    , p_commit  VARCHAR2
    , create_yn  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  NUMBER
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  NUMBER
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_NUMBER_TABLE
    , p12_a4 out nocopy JTF_NUMBER_TABLE
    , p12_a5 out nocopy JTF_DATE_TABLE
    , p13_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p13_a1 out nocopy JTF_NUMBER_TABLE
    , p13_a2 out nocopy JTF_NUMBER_TABLE
    , p13_a3 out nocopy JTF_DATE_TABLE
    , p14_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p14_a2 out nocopy JTF_NUMBER_TABLE
    , p14_a3 out nocopy JTF_NUMBER_TABLE
    , p14_a4 out nocopy JTF_NUMBER_TABLE
    , p14_a5 out nocopy JTF_NUMBER_TABLE
    , p14_a6 out nocopy JTF_NUMBER_TABLE
    , p14_a7 out nocopy JTF_DATE_TABLE
    , p15_a0 out nocopy  NUMBER
    , p15_a1 out nocopy  NUMBER
    , p15_a2 out nocopy  VARCHAR2
    , p15_a3 out nocopy  VARCHAR2
    , p15_a4 out nocopy  VARCHAR2
    , p15_a5 out nocopy  VARCHAR2
    , p15_a6 out nocopy  VARCHAR2
    , p15_a7 out nocopy  VARCHAR2
    , p15_a8 out nocopy  VARCHAR2
    , p15_a9 out nocopy  VARCHAR2
    , p15_a10 out nocopy  VARCHAR2
    , p15_a11 out nocopy  VARCHAR2
    , p15_a12 out nocopy  VARCHAR2
    , p15_a13 out nocopy  VARCHAR2
    , p15_a14 out nocopy  VARCHAR2
    , p15_a15 out nocopy  VARCHAR2
    , p15_a16 out nocopy  VARCHAR2
    , p15_a17 out nocopy  VARCHAR2
    , p15_a18 out nocopy  VARCHAR2
    , p15_a19 out nocopy  DATE
    , p15_a20 out nocopy  NUMBER
    , p15_a21 out nocopy  NUMBER
    , p15_a22 out nocopy  VARCHAR2
    , p15_a23 out nocopy  NUMBER
    , p15_a24 out nocopy  NUMBER
    , p15_a25 out nocopy  VARCHAR2
    , p15_a26 out nocopy  NUMBER
    , p15_a27 out nocopy  NUMBER
    , p15_a28 out nocopy  NUMBER
    , p15_a29 out nocopy  NUMBER
    , p15_a30 out nocopy  NUMBER
    , p15_a31 out nocopy  VARCHAR2
    , p15_a32 out nocopy  VARCHAR2
    , p15_a33 out nocopy  NUMBER
    , p15_a34 out nocopy  NUMBER
    , p15_a35 out nocopy  NUMBER
    , p15_a36 out nocopy  VARCHAR2
    , p15_a37 out nocopy  NUMBER
    , p15_a38 out nocopy  NUMBER
    , p15_a39 out nocopy  VARCHAR2
    , p15_a40 out nocopy  VARCHAR2
    , p15_a41 out nocopy  NUMBER
    , p15_a42 out nocopy  NUMBER
    , p15_a43 out nocopy  NUMBER
    , p15_a44 out nocopy  NUMBER
    , p15_a45 out nocopy  NUMBER
    , p15_a46 out nocopy  NUMBER
    , p15_a47 out nocopy  NUMBER
    , p15_a48 out nocopy  NUMBER
    , p15_a49 out nocopy  NUMBER
    , p15_a50 out nocopy  VARCHAR2
    , p15_a51 out nocopy  VARCHAR2
    , p15_a52 out nocopy  VARCHAR2
    , p15_a53 out nocopy  VARCHAR2
    , p16_a0 out nocopy JTF_NUMBER_TABLE
    , p16_a1 out nocopy JTF_NUMBER_TABLE
    , p16_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p16_a18 out nocopy JTF_NUMBER_TABLE
    , p16_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p16_a21 out nocopy JTF_NUMBER_TABLE
    , p16_a22 out nocopy JTF_NUMBER_TABLE
    , p16_a23 out nocopy JTF_NUMBER_TABLE
    , p16_a24 out nocopy JTF_NUMBER_TABLE
    , p16_a25 out nocopy JTF_NUMBER_TABLE
    , p16_a26 out nocopy JTF_NUMBER_TABLE
    , p16_a27 out nocopy JTF_NUMBER_TABLE
    , p16_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p16_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p16_a30 out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure cancel_quick_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  VARCHAR2
    , p5_a19  DATE
    , p5_a20  NUMBER
    , p5_a21  NUMBER
    , p5_a22  VARCHAR2
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  VARCHAR2
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  NUMBER
    , p5_a29  NUMBER
    , p5_a30  NUMBER
    , p5_a31  VARCHAR2
    , p5_a32  VARCHAR2
    , p5_a33  NUMBER
    , p5_a34  NUMBER
    , p5_a35  NUMBER
    , p5_a36  VARCHAR2
    , p5_a37  NUMBER
    , p5_a38  NUMBER
    , p5_a39  VARCHAR2
    , p5_a40  VARCHAR2
    , p5_a41  NUMBER
    , p5_a42  NUMBER
    , p5_a43  NUMBER
    , p5_a44  NUMBER
    , p5_a45  NUMBER
    , p5_a46  NUMBER
    , p5_a47  NUMBER
    , p5_a48  NUMBER
    , p5_a49  NUMBER
    , p5_a50  VARCHAR2
    , p5_a51  VARCHAR2
    , p5_a52  VARCHAR2
    , p5_a53  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p6_a38 out nocopy  NUMBER
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  NUMBER
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  NUMBER
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  NUMBER
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
  );
end okl_quick_quotes_pvt_w;

/
