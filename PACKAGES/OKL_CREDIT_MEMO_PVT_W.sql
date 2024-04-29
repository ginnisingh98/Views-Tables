--------------------------------------------------------
--  DDL for Package OKL_CREDIT_MEMO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CREDIT_MEMO_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLECRMS.pls 120.4 2007/11/06 07:32:05 veramach noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_credit_memo_pvt.credit_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t okl_credit_memo_pvt.credit_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure insert_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_tld_id  NUMBER
    , p_credit_amount  NUMBER
    , p_credit_sty_id  NUMBER
    , p_credit_desc  VARCHAR2
    , p_credit_date  date
    , p_try_id  NUMBER
    , p_transaction_source  VARCHAR2
    , p_source_trx_number  VARCHAR2
    , x_tai_id out nocopy  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  VARCHAR2
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  DATE
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  NUMBER
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  NUMBER
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  NUMBER
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  NUMBER
    , p11_a21 out nocopy  NUMBER
    , p11_a22 out nocopy  NUMBER
    , p11_a23 out nocopy  DATE
    , p11_a24 out nocopy  NUMBER
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  VARCHAR2
    , p11_a27 out nocopy  NUMBER
    , p11_a28 out nocopy  NUMBER
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  VARCHAR2
    , p11_a31 out nocopy  VARCHAR2
    , p11_a32 out nocopy  VARCHAR2
    , p11_a33 out nocopy  VARCHAR2
    , p11_a34 out nocopy  VARCHAR2
    , p11_a35 out nocopy  VARCHAR2
    , p11_a36 out nocopy  VARCHAR2
    , p11_a37 out nocopy  VARCHAR2
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  VARCHAR2
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  VARCHAR2
    , p11_a44 out nocopy  VARCHAR2
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  DATE
    , p11_a47 out nocopy  NUMBER
    , p11_a48 out nocopy  NUMBER
    , p11_a49 out nocopy  NUMBER
    , p11_a50 out nocopy  DATE
    , p11_a51 out nocopy  NUMBER
    , p11_a52 out nocopy  NUMBER
    , p11_a53 out nocopy  DATE
    , p11_a54 out nocopy  NUMBER
    , p11_a55 out nocopy  DATE
    , p11_a56 out nocopy  NUMBER
    , p11_a57 out nocopy  NUMBER
    , p11_a58 out nocopy  VARCHAR2
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p11_a61 out nocopy  NUMBER
    , p11_a62 out nocopy  VARCHAR2
    , p11_a63 out nocopy  DATE
    , p11_a64 out nocopy  VARCHAR2
    , p11_a65 out nocopy  NUMBER
    , p11_a66 out nocopy  NUMBER
    , p11_a67 out nocopy  NUMBER
    , p11_a68 out nocopy  NUMBER
    , p11_a69 out nocopy  VARCHAR2
    , p11_a70 out nocopy  VARCHAR2
    , p11_a71 out nocopy  NUMBER
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure insert_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_VARCHAR2_TABLE_200
    , p2_a6 JTF_VARCHAR2_TABLE_2000
    , p2_a7 JTF_DATE_TABLE
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p_transaction_source  VARCHAR2
    , p_source_trx_number  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_NUMBER_TABLE
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_DATE_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_NUMBER_TABLE
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a15 out nocopy JTF_NUMBER_TABLE
    , p5_a16 out nocopy JTF_NUMBER_TABLE
    , p5_a17 out nocopy JTF_NUMBER_TABLE
    , p5_a18 out nocopy JTF_NUMBER_TABLE
    , p5_a19 out nocopy JTF_NUMBER_TABLE
    , p5_a20 out nocopy JTF_NUMBER_TABLE
    , p5_a21 out nocopy JTF_NUMBER_TABLE
    , p5_a22 out nocopy JTF_NUMBER_TABLE
    , p5_a23 out nocopy JTF_DATE_TABLE
    , p5_a24 out nocopy JTF_NUMBER_TABLE
    , p5_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a27 out nocopy JTF_NUMBER_TABLE
    , p5_a28 out nocopy JTF_NUMBER_TABLE
    , p5_a29 out nocopy JTF_NUMBER_TABLE
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a34 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a35 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a36 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a37 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a38 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p5_a46 out nocopy JTF_DATE_TABLE
    , p5_a47 out nocopy JTF_NUMBER_TABLE
    , p5_a48 out nocopy JTF_NUMBER_TABLE
    , p5_a49 out nocopy JTF_NUMBER_TABLE
    , p5_a50 out nocopy JTF_DATE_TABLE
    , p5_a51 out nocopy JTF_NUMBER_TABLE
    , p5_a52 out nocopy JTF_NUMBER_TABLE
    , p5_a53 out nocopy JTF_DATE_TABLE
    , p5_a54 out nocopy JTF_NUMBER_TABLE
    , p5_a55 out nocopy JTF_DATE_TABLE
    , p5_a56 out nocopy JTF_NUMBER_TABLE
    , p5_a57 out nocopy JTF_NUMBER_TABLE
    , p5_a58 out nocopy JTF_VARCHAR2_TABLE_200
    , p5_a59 out nocopy JTF_VARCHAR2_TABLE_400
    , p5_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a61 out nocopy JTF_NUMBER_TABLE
    , p5_a62 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a63 out nocopy JTF_DATE_TABLE
    , p5_a64 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a65 out nocopy JTF_NUMBER_TABLE
    , p5_a66 out nocopy JTF_NUMBER_TABLE
    , p5_a67 out nocopy JTF_NUMBER_TABLE
    , p5_a68 out nocopy JTF_NUMBER_TABLE
    , p5_a69 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a70 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a71 out nocopy JTF_NUMBER_TABLE
    , p5_a72 out nocopy JTF_VARCHAR2_TABLE_4000
    , p5_a73 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure insert_on_acc_cm_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_tld_id  NUMBER
    , p_credit_amount  NUMBER
    , p_credit_sty_id  NUMBER
    , p_credit_desc  VARCHAR2
    , p_credit_date  date
    , p_try_id  NUMBER
    , p_transaction_source  VARCHAR2
    , p_source_trx_number  VARCHAR2
    , x_tai_id out nocopy  NUMBER
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  VARCHAR2
    , p11_a5 out nocopy  NUMBER
    , p11_a6 out nocopy  DATE
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  NUMBER
    , p11_a13 out nocopy  NUMBER
    , p11_a14 out nocopy  VARCHAR2
    , p11_a15 out nocopy  NUMBER
    , p11_a16 out nocopy  NUMBER
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  NUMBER
    , p11_a19 out nocopy  NUMBER
    , p11_a20 out nocopy  NUMBER
    , p11_a21 out nocopy  NUMBER
    , p11_a22 out nocopy  NUMBER
    , p11_a23 out nocopy  DATE
    , p11_a24 out nocopy  NUMBER
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  VARCHAR2
    , p11_a27 out nocopy  NUMBER
    , p11_a28 out nocopy  NUMBER
    , p11_a29 out nocopy  NUMBER
    , p11_a30 out nocopy  VARCHAR2
    , p11_a31 out nocopy  VARCHAR2
    , p11_a32 out nocopy  VARCHAR2
    , p11_a33 out nocopy  VARCHAR2
    , p11_a34 out nocopy  VARCHAR2
    , p11_a35 out nocopy  VARCHAR2
    , p11_a36 out nocopy  VARCHAR2
    , p11_a37 out nocopy  VARCHAR2
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  VARCHAR2
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  VARCHAR2
    , p11_a43 out nocopy  VARCHAR2
    , p11_a44 out nocopy  VARCHAR2
    , p11_a45 out nocopy  VARCHAR2
    , p11_a46 out nocopy  DATE
    , p11_a47 out nocopy  NUMBER
    , p11_a48 out nocopy  NUMBER
    , p11_a49 out nocopy  NUMBER
    , p11_a50 out nocopy  DATE
    , p11_a51 out nocopy  NUMBER
    , p11_a52 out nocopy  NUMBER
    , p11_a53 out nocopy  DATE
    , p11_a54 out nocopy  NUMBER
    , p11_a55 out nocopy  DATE
    , p11_a56 out nocopy  NUMBER
    , p11_a57 out nocopy  NUMBER
    , p11_a58 out nocopy  VARCHAR2
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p11_a61 out nocopy  NUMBER
    , p11_a62 out nocopy  VARCHAR2
    , p11_a63 out nocopy  DATE
    , p11_a64 out nocopy  VARCHAR2
    , p11_a65 out nocopy  NUMBER
    , p11_a66 out nocopy  NUMBER
    , p11_a67 out nocopy  NUMBER
    , p11_a68 out nocopy  NUMBER
    , p11_a69 out nocopy  VARCHAR2
    , p11_a70 out nocopy  VARCHAR2
    , p11_a71 out nocopy  NUMBER
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_credit_memo_pvt_w;

/
