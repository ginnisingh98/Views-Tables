--------------------------------------------------------
--  DDL for Package OKL_AM_LEASE_LOAN_TRMNT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_LEASE_LOAN_TRMNT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLELLTS.pls 120.6.12010000.5 2008/11/18 10:32:31 sosharma ship $ */
  procedure rosetta_table_copy_in_p13(t out nocopy okl_am_lease_loan_trmnt_pvt.term_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_DATE_TABLE
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_2000
    , a9 JTF_VARCHAR2_TABLE_2000
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p13(t okl_am_lease_loan_trmnt_pvt.term_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_2000
    , a9 out nocopy JTF_VARCHAR2_TABLE_2000
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure lease_loan_termination(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  DATE := fnd_api.g_miss_date
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  DATE := fnd_api.g_miss_date
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  DATE := fnd_api.g_miss_date
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  DATE := fnd_api.g_miss_date
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  DATE := fnd_api.g_miss_date
  );
  procedure lease_loan_termination(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_200
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_DATE_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_2000
    , p5_a9 JTF_VARCHAR2_TABLE_2000
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_DATE_TABLE
    , p6_a15 JTF_VARCHAR2_TABLE_100
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_VARCHAR2_TABLE_200
    , p6_a19 JTF_VARCHAR2_TABLE_100
    , p6_a20 JTF_VARCHAR2_TABLE_500
    , p6_a21 JTF_VARCHAR2_TABLE_500
    , p6_a22 JTF_VARCHAR2_TABLE_500
    , p6_a23 JTF_VARCHAR2_TABLE_500
    , p6_a24 JTF_VARCHAR2_TABLE_500
    , p6_a25 JTF_VARCHAR2_TABLE_500
    , p6_a26 JTF_VARCHAR2_TABLE_500
    , p6_a27 JTF_VARCHAR2_TABLE_500
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_VARCHAR2_TABLE_100
    , p6_a37 JTF_NUMBER_TABLE
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_VARCHAR2_TABLE_100
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_NUMBER_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_NUMBER_TABLE
    , p6_a50 JTF_DATE_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_DATE_TABLE
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_VARCHAR2_TABLE_2000
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_100
    , p6_a62 JTF_VARCHAR2_TABLE_100
    , p6_a63 JTF_VARCHAR2_TABLE_100
    , p6_a64 JTF_VARCHAR2_TABLE_100
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_VARCHAR2_TABLE_100
    , p6_a68 JTF_VARCHAR2_TABLE_100
    , p6_a69 JTF_VARCHAR2_TABLE_100
    , p6_a70 JTF_VARCHAR2_TABLE_100
    , p6_a71 JTF_VARCHAR2_TABLE_100
    , p6_a72 JTF_VARCHAR2_TABLE_100
    , p6_a73 JTF_VARCHAR2_TABLE_100
    , p6_a74 JTF_VARCHAR2_TABLE_100
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_DATE_TABLE
    , p6_a79 JTF_NUMBER_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_VARCHAR2_TABLE_100
    , p6_a82 JTF_DATE_TABLE
    , p6_a83 JTF_NUMBER_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_VARCHAR2_TABLE_100
    , p6_a86 JTF_VARCHAR2_TABLE_200
    , p6_a87 JTF_VARCHAR2_TABLE_100
    , p6_a88 JTF_VARCHAR2_TABLE_200
    , p6_a89 JTF_VARCHAR2_TABLE_100
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_VARCHAR2_TABLE_100
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_DATE_TABLE
  );
  procedure process_discount_subsidy(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_call_origin  VARCHAR2
    , p_termination_date  date
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
  );
  function check_service_k_int_needed(p_partial_yn  VARCHAR2
    , p_asset_id  NUMBER
    , p_source  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  NUMBER := 0-1962.0724
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  NUMBER := 0-1962.0724
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  DATE := fnd_api.g_miss_date
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  NUMBER := 0-1962.0724
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  VARCHAR2 := fnd_api.g_miss_char
    , p1_a26  VARCHAR2 := fnd_api.g_miss_char
    , p1_a27  VARCHAR2 := fnd_api.g_miss_char
    , p1_a28  VARCHAR2 := fnd_api.g_miss_char
    , p1_a29  VARCHAR2 := fnd_api.g_miss_char
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
    , p1_a32  VARCHAR2 := fnd_api.g_miss_char
    , p1_a33  VARCHAR2 := fnd_api.g_miss_char
    , p1_a34  VARCHAR2 := fnd_api.g_miss_char
    , p1_a35  VARCHAR2 := fnd_api.g_miss_char
    , p1_a36  VARCHAR2 := fnd_api.g_miss_char
    , p1_a37  NUMBER := 0-1962.0724
    , p1_a38  VARCHAR2 := fnd_api.g_miss_char
    , p1_a39  NUMBER := 0-1962.0724
    , p1_a40  VARCHAR2 := fnd_api.g_miss_char
    , p1_a41  VARCHAR2 := fnd_api.g_miss_char
    , p1_a42  NUMBER := 0-1962.0724
    , p1_a43  NUMBER := 0-1962.0724
    , p1_a44  NUMBER := 0-1962.0724
    , p1_a45  NUMBER := 0-1962.0724
    , p1_a46  NUMBER := 0-1962.0724
    , p1_a47  NUMBER := 0-1962.0724
    , p1_a48  DATE := fnd_api.g_miss_date
    , p1_a49  NUMBER := 0-1962.0724
    , p1_a50  DATE := fnd_api.g_miss_date
    , p1_a51  NUMBER := 0-1962.0724
    , p1_a52  DATE := fnd_api.g_miss_date
    , p1_a53  NUMBER := 0-1962.0724
    , p1_a54  NUMBER := 0-1962.0724
    , p1_a55  VARCHAR2 := fnd_api.g_miss_char
    , p1_a56  NUMBER := 0-1962.0724
    , p1_a57  VARCHAR2 := fnd_api.g_miss_char
    , p1_a58  DATE := fnd_api.g_miss_date
    , p1_a59  VARCHAR2 := fnd_api.g_miss_char
    , p1_a60  VARCHAR2 := fnd_api.g_miss_char
    , p1_a61  VARCHAR2 := fnd_api.g_miss_char
    , p1_a62  VARCHAR2 := fnd_api.g_miss_char
    , p1_a63  VARCHAR2 := fnd_api.g_miss_char
    , p1_a64  VARCHAR2 := fnd_api.g_miss_char
    , p1_a65  VARCHAR2 := fnd_api.g_miss_char
    , p1_a66  VARCHAR2 := fnd_api.g_miss_char
    , p1_a67  VARCHAR2 := fnd_api.g_miss_char
    , p1_a68  VARCHAR2 := fnd_api.g_miss_char
    , p1_a69  VARCHAR2 := fnd_api.g_miss_char
    , p1_a70  VARCHAR2 := fnd_api.g_miss_char
    , p1_a71  VARCHAR2 := fnd_api.g_miss_char
    , p1_a72  VARCHAR2 := fnd_api.g_miss_char
    , p1_a73  VARCHAR2 := fnd_api.g_miss_char
    , p1_a74  VARCHAR2 := fnd_api.g_miss_char
    , p1_a75  VARCHAR2 := fnd_api.g_miss_char
    , p1_a76  VARCHAR2 := fnd_api.g_miss_char
    , p1_a77  NUMBER := 0-1962.0724
    , p1_a78  DATE := fnd_api.g_miss_date
    , p1_a79  NUMBER := 0-1962.0724
    , p1_a80  NUMBER := 0-1962.0724
    , p1_a81  VARCHAR2 := fnd_api.g_miss_char
    , p1_a82  DATE := fnd_api.g_miss_date
    , p1_a83  NUMBER := 0-1962.0724
    , p1_a84  DATE := fnd_api.g_miss_date
    , p1_a85  VARCHAR2 := fnd_api.g_miss_char
    , p1_a86  VARCHAR2 := fnd_api.g_miss_char
    , p1_a87  VARCHAR2 := fnd_api.g_miss_char
    , p1_a88  VARCHAR2 := fnd_api.g_miss_char
    , p1_a89  VARCHAR2 := fnd_api.g_miss_char
    , p1_a90  VARCHAR2 := fnd_api.g_miss_char
    , p1_a91  VARCHAR2 := fnd_api.g_miss_char
    , p1_a92  VARCHAR2 := fnd_api.g_miss_char
    , p1_a93  DATE := fnd_api.g_miss_date
  ) return varchar2;
  procedure service_k_integration(p_transaction_id  NUMBER
    , p_transaction_date  date
    , p_source  VARCHAR2
    , p_service_integration_needed  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
  );
  function check_billing_done(p_contract_id  NUMBER
    , p_contract_number  VARCHAR2
    , p_quote_number  NUMBER
    , p_trn_date  date
  ) return varchar2;
  procedure get_set_quote_dates(p_qte_id  NUMBER
    , p_trn_date  date
    , x_return_status out nocopy  VARCHAR2
  );
  procedure process_adjustments(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_call_origin  VARCHAR2
    , p_termination_date  date
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  DATE := fnd_api.g_miss_date
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  DATE := fnd_api.g_miss_date
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  DATE := fnd_api.g_miss_date
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  DATE := fnd_api.g_miss_date
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  DATE := fnd_api.g_miss_date
  );
  function check_int_calc_done(p_contract_id  NUMBER
    , p_contract_number  VARCHAR2
    , p_quote_number  NUMBER
    , p_source  VARCHAR2
    , p_trn_date  date
  ) return varchar2;
  procedure process_loan_refunds(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_call_origin  VARCHAR2
    , p_termination_date  date
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  VARCHAR2 := fnd_api.g_miss_char
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  VARCHAR2 := fnd_api.g_miss_char
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  NUMBER := 0-1962.0724
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  VARCHAR2 := fnd_api.g_miss_char
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  DATE := fnd_api.g_miss_date
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  VARCHAR2 := fnd_api.g_miss_char
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  VARCHAR2 := fnd_api.g_miss_char
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  VARCHAR2 := fnd_api.g_miss_char
    , p6_a37  NUMBER := 0-1962.0724
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  NUMBER := 0-1962.0724
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  NUMBER := 0-1962.0724
    , p6_a43  NUMBER := 0-1962.0724
    , p6_a44  NUMBER := 0-1962.0724
    , p6_a45  NUMBER := 0-1962.0724
    , p6_a46  NUMBER := 0-1962.0724
    , p6_a47  NUMBER := 0-1962.0724
    , p6_a48  DATE := fnd_api.g_miss_date
    , p6_a49  NUMBER := 0-1962.0724
    , p6_a50  DATE := fnd_api.g_miss_date
    , p6_a51  NUMBER := 0-1962.0724
    , p6_a52  DATE := fnd_api.g_miss_date
    , p6_a53  NUMBER := 0-1962.0724
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  VARCHAR2 := fnd_api.g_miss_char
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  VARCHAR2 := fnd_api.g_miss_char
    , p6_a58  DATE := fnd_api.g_miss_date
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  VARCHAR2 := fnd_api.g_miss_char
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  VARCHAR2 := fnd_api.g_miss_char
    , p6_a68  VARCHAR2 := fnd_api.g_miss_char
    , p6_a69  VARCHAR2 := fnd_api.g_miss_char
    , p6_a70  VARCHAR2 := fnd_api.g_miss_char
    , p6_a71  VARCHAR2 := fnd_api.g_miss_char
    , p6_a72  VARCHAR2 := fnd_api.g_miss_char
    , p6_a73  VARCHAR2 := fnd_api.g_miss_char
    , p6_a74  VARCHAR2 := fnd_api.g_miss_char
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  DATE := fnd_api.g_miss_date
    , p6_a79  NUMBER := 0-1962.0724
    , p6_a80  NUMBER := 0-1962.0724
    , p6_a81  VARCHAR2 := fnd_api.g_miss_char
    , p6_a82  DATE := fnd_api.g_miss_date
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  DATE := fnd_api.g_miss_date
    , p6_a85  VARCHAR2 := fnd_api.g_miss_char
    , p6_a86  VARCHAR2 := fnd_api.g_miss_char
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  VARCHAR2 := fnd_api.g_miss_char
    , p6_a89  VARCHAR2 := fnd_api.g_miss_char
    , p6_a90  VARCHAR2 := fnd_api.g_miss_char
    , p6_a91  VARCHAR2 := fnd_api.g_miss_char
    , p6_a92  VARCHAR2 := fnd_api.g_miss_char
    , p6_a93  DATE := fnd_api.g_miss_date
  );
end okl_am_lease_loan_trmnt_pvt_w;

/
