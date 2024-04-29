--------------------------------------------------------
--  DDL for Package LNS_FINANCIALS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FINANCIALS_W" AUTHID CURRENT_USER as
  /* $Header: LNS_FINANCIALJ_S.pls 120.7.12010000.5 2010/03/19 08:35:45 gparuchu ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_financials.rate_schedule_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t lns_financials.rate_schedule_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy lns_financials.amortization_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_2000
    , a29 JTF_VARCHAR2_TABLE_2000
    , a30 JTF_VARCHAR2_TABLE_2000
    , a31 JTF_VARCHAR2_TABLE_2000
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p3(t lns_financials.amortization_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure rosetta_table_copy_in_p6(t out nocopy lns_financials.payoff_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p6(t lns_financials.payoff_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy lns_financials.payoff_tbl2, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p8(t lns_financials.payoff_tbl2, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy lns_financials.loan_activity_tbl, a0 JTF_DATE_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p10(t lns_financials.loan_activity_tbl, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p12(t out nocopy lns_financials.payment_schedule_tbl, a0 JTF_DATE_TABLE
    , a1 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p12(t lns_financials.payment_schedule_tbl, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    );

  procedure rosetta_table_copy_in_p13(t out nocopy lns_financials.date_tbl, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p13(t lns_financials.date_tbl, a0 out nocopy JTF_DATE_TABLE);

  procedure rosetta_table_copy_in_p14(t out nocopy lns_financials.amount_tbl, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p14(t lns_financials.amount_tbl, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p15(t out nocopy lns_financials.vchar_tbl, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p15(t lns_financials.vchar_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p17(t out nocopy lns_financials.fees_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p17(t lns_financials.fees_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure shiftloandates(p_loan_id  NUMBER
    , p_new_start_date  DATE
    , p_phase  VARCHAR2
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  NUMBER
    , p3_a2 out nocopy  VARCHAR2
    , p3_a3 out nocopy  NUMBER
    , p3_a4 out nocopy  VARCHAR2
    , p3_a5 out nocopy  VARCHAR2
    , p3_a6 out nocopy  VARCHAR2
    , p3_a7 out nocopy  DATE
    , p3_a8 out nocopy  DATE
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  NUMBER
    , p3_a11 out nocopy  NUMBER
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  NUMBER
    , p3_a14 out nocopy  NUMBER
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  NUMBER
    , p3_a17 out nocopy  NUMBER
    , p3_a18 out nocopy  NUMBER
    , p3_a19 out nocopy  DATE
    , p3_a20 out nocopy  NUMBER
    , p3_a21 out nocopy  NUMBER
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  NUMBER
    , p3_a26 out nocopy  NUMBER
    , p3_a27 out nocopy  NUMBER
    , p3_a28 out nocopy  NUMBER
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  NUMBER
    , p3_a32 out nocopy  VARCHAR2
    , p3_a33 out nocopy  VARCHAR2
    , p3_a34 out nocopy  DATE
    , p3_a35 out nocopy  VARCHAR2
    , p3_a36 out nocopy  DATE
    , p3_a37 out nocopy  VARCHAR2
    , p3_a38 out nocopy  NUMBER
    , p3_a39 out nocopy  NUMBER
    , p3_a40 out nocopy  VARCHAR2
    , p3_a41 out nocopy  VARCHAR2
    , p3_a42 out nocopy  DATE
    , p3_a43 out nocopy  DATE
    , p3_a44 out nocopy  DATE
    , p3_a45 out nocopy  VARCHAR2
    , p3_a46 out nocopy  VARCHAR2
    , p3_a47 out nocopy  NUMBER
    , p3_a48 out nocopy  NUMBER
    , p3_a49 out nocopy  VARCHAR2
    , p3_a50 out nocopy  VARCHAR2
    , p3_a51 out nocopy  NUMBER
    , p3_a52 out nocopy  DATE
    , p3_a53 out nocopy  NUMBER
    , p3_a54 out nocopy  NUMBER
    , p3_a55 out nocopy  NUMBER
    , p3_a56 out nocopy  NUMBER
    , p3_a57 out nocopy  NUMBER
    , p3_a58 out nocopy  VARCHAR2
    , p3_a59 out nocopy  NUMBER
    , p3_a60 out nocopy  DATE
    , p3_a61 out nocopy  NUMBER
    , p3_a62 out nocopy  NUMBER
    , p3_a63 out nocopy  NUMBER
    , p3_a64 out nocopy  NUMBER
    , p3_a65 out nocopy  NUMBER
    , p3_a66 out nocopy  VARCHAR2
    , p3_a67 out nocopy  VARCHAR2
    , p3_a68 out nocopy  VARCHAR2
    , p3_a69 out nocopy  VARCHAR2
    , p3_a70 out nocopy  NUMBER
    , p3_a71 out nocopy  NUMBER
    , p3_a72 out nocopy  NUMBER
    , p3_a73 out nocopy  NUMBER
    , p3_a74 out nocopy  DATE
    , p3_a75 out nocopy  DATE
    , p3_a76 out nocopy  VARCHAR2
    , p3_a77 out nocopy  VARCHAR2
    , p3_a78 out nocopy  VARCHAR2
    , p3_a79 out nocopy  VARCHAR2
    , p3_a80 out nocopy  DATE
    , p3_a81 out nocopy  VARCHAR2
    , p3_a82 out nocopy  NUMBER
    , p3_a83 out nocopy  NUMBER
    , p3_a84 out nocopy  VARCHAR2
    , p3_a85 out nocopy  NUMBER
    , p3_a86 out nocopy  NUMBER
    , p3_a87 out nocopy  NUMBER
    , p3_a88 out nocopy  NUMBER
    , p3_a89 out nocopy  NUMBER
    , p3_a90 out nocopy  VARCHAR2
    , x_dates_shifted_flag out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validatepayoff(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p_payoff_date  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure calculatepayoff(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_payoff_date  DATE
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_NUMBER_TABLE
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  function getweightedrate(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_DATE_TABLE
    , p3_a2 JTF_DATE_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_VARCHAR2_TABLE_100
    , p3_a8 JTF_VARCHAR2_TABLE_100
    , p3_a9 JTF_VARCHAR2_TABLE_100
  ) return number;
  procedure amortizeeploan(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_DATE_TABLE
    , p1_a2 JTF_DATE_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p_based_on_terms  VARCHAR2
    , p_installment_number  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_DATE_TABLE
    , p4_a2 out nocopy JTF_DATE_TABLE
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_NUMBER_TABLE
    , p4_a13 out nocopy JTF_NUMBER_TABLE
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_NUMBER_TABLE
    , p4_a16 out nocopy JTF_NUMBER_TABLE
    , p4_a17 out nocopy JTF_NUMBER_TABLE
    , p4_a18 out nocopy JTF_NUMBER_TABLE
    , p4_a19 out nocopy JTF_NUMBER_TABLE
    , p4_a20 out nocopy JTF_NUMBER_TABLE
    , p4_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 out nocopy JTF_NUMBER_TABLE
    , p4_a25 out nocopy JTF_NUMBER_TABLE
    , p4_a26 out nocopy JTF_NUMBER_TABLE
    , p4_a27 out nocopy JTF_NUMBER_TABLE
    , p4_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a32 out nocopy JTF_NUMBER_TABLE
    , p4_a33 out nocopy JTF_VARCHAR2_TABLE_200
  );
  procedure amortizeloan(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_DATE_TABLE
    , p1_a2 JTF_DATE_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_VARCHAR2_TABLE_100
    , p1_a9 JTF_VARCHAR2_TABLE_100
    , p_based_on_terms  VARCHAR2
    , p_installment_number  NUMBER
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_DATE_TABLE
    , p4_a2 out nocopy JTF_DATE_TABLE
    , p4_a3 out nocopy JTF_DATE_TABLE
    , p4_a4 out nocopy JTF_NUMBER_TABLE
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_NUMBER_TABLE
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_NUMBER_TABLE
    , p4_a9 out nocopy JTF_NUMBER_TABLE
    , p4_a10 out nocopy JTF_NUMBER_TABLE
    , p4_a11 out nocopy JTF_NUMBER_TABLE
    , p4_a12 out nocopy JTF_NUMBER_TABLE
    , p4_a13 out nocopy JTF_NUMBER_TABLE
    , p4_a14 out nocopy JTF_NUMBER_TABLE
    , p4_a15 out nocopy JTF_NUMBER_TABLE
    , p4_a16 out nocopy JTF_NUMBER_TABLE
    , p4_a17 out nocopy JTF_NUMBER_TABLE
    , p4_a18 out nocopy JTF_NUMBER_TABLE
    , p4_a19 out nocopy JTF_NUMBER_TABLE
    , p4_a20 out nocopy JTF_NUMBER_TABLE
    , p4_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a24 out nocopy JTF_NUMBER_TABLE
    , p4_a25 out nocopy JTF_NUMBER_TABLE
    , p4_a26 out nocopy JTF_NUMBER_TABLE
    , p4_a27 out nocopy JTF_NUMBER_TABLE
    , p4_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p4_a32 out nocopy JTF_NUMBER_TABLE
    , p4_a33 out nocopy JTF_VARCHAR2_TABLE_200
  );
  procedure amortizeloan(p_loan_id  NUMBER
    , p_based_on_terms  VARCHAR2
    , p_installment_number  NUMBER
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_DATE_TABLE
    , p3_a2 out nocopy JTF_DATE_TABLE
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_NUMBER_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p3_a26 out nocopy JTF_NUMBER_TABLE
    , p3_a27 out nocopy JTF_NUMBER_TABLE
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a32 out nocopy JTF_NUMBER_TABLE
    , p3_a33 out nocopy JTF_VARCHAR2_TABLE_200
  );
  procedure loanprojection(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p0_a5  VARCHAR2
    , p0_a6  VARCHAR2
    , p0_a7  DATE
    , p0_a8  DATE
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  NUMBER
    , p0_a17  NUMBER
    , p0_a18  NUMBER
    , p0_a19  DATE
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  NUMBER
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  DATE
    , p0_a35  VARCHAR2
    , p0_a36  DATE
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  DATE
    , p0_a43  DATE
    , p0_a44  DATE
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  NUMBER
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  NUMBER
    , p0_a52  DATE
    , p0_a53  NUMBER
    , p0_a54  NUMBER
    , p0_a55  NUMBER
    , p0_a56  NUMBER
    , p0_a57  NUMBER
    , p0_a58  VARCHAR2
    , p0_a59  NUMBER
    , p0_a60  DATE
    , p0_a61  NUMBER
    , p0_a62  NUMBER
    , p0_a63  NUMBER
    , p0_a64  NUMBER
    , p0_a65  NUMBER
    , p0_a66  VARCHAR2
    , p0_a67  VARCHAR2
    , p0_a68  VARCHAR2
    , p0_a69  VARCHAR2
    , p0_a70  NUMBER
    , p0_a71  NUMBER
    , p0_a72  NUMBER
    , p0_a73  NUMBER
    , p0_a74  DATE
    , p0_a75  DATE
    , p0_a76  VARCHAR2
    , p0_a77  VARCHAR2
    , p0_a78  VARCHAR2
    , p0_a79  VARCHAR2
    , p0_a80  DATE
    , p0_a81  VARCHAR2
    , p0_a82  NUMBER
    , p0_a83  NUMBER
    , p0_a84  VARCHAR2
    , p0_a85  NUMBER
    , p0_a86  NUMBER
    , p0_a87  NUMBER
    , p0_a88  NUMBER
    , p0_a89  NUMBER
    , p0_a90  VARCHAR2
    , p_based_on_terms  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_DATE_TABLE
    , p2_a2 JTF_DATE_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_VARCHAR2_TABLE_100
    , p2_a8 JTF_VARCHAR2_TABLE_100
    , p2_a9 JTF_VARCHAR2_TABLE_100
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_DATE_TABLE
    , p3_a2 out nocopy JTF_DATE_TABLE
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_NUMBER_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p3_a26 out nocopy JTF_NUMBER_TABLE
    , p3_a27 out nocopy JTF_NUMBER_TABLE
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a32 out nocopy JTF_NUMBER_TABLE
    , p3_a33 out nocopy JTF_VARCHAR2_TABLE_200
  );
  procedure runopenprojection(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_based_on_terms  VARCHAR2
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_DATE_TABLE
    , p3_a2 out nocopy JTF_DATE_TABLE
    , p3_a3 out nocopy JTF_DATE_TABLE
    , p3_a4 out nocopy JTF_NUMBER_TABLE
    , p3_a5 out nocopy JTF_NUMBER_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_NUMBER_TABLE
    , p3_a10 out nocopy JTF_NUMBER_TABLE
    , p3_a11 out nocopy JTF_NUMBER_TABLE
    , p3_a12 out nocopy JTF_NUMBER_TABLE
    , p3_a13 out nocopy JTF_NUMBER_TABLE
    , p3_a14 out nocopy JTF_NUMBER_TABLE
    , p3_a15 out nocopy JTF_NUMBER_TABLE
    , p3_a16 out nocopy JTF_NUMBER_TABLE
    , p3_a17 out nocopy JTF_NUMBER_TABLE
    , p3_a18 out nocopy JTF_NUMBER_TABLE
    , p3_a19 out nocopy JTF_NUMBER_TABLE
    , p3_a20 out nocopy JTF_NUMBER_TABLE
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a24 out nocopy JTF_NUMBER_TABLE
    , p3_a25 out nocopy JTF_NUMBER_TABLE
    , p3_a26 out nocopy JTF_NUMBER_TABLE
    , p3_a27 out nocopy JTF_NUMBER_TABLE
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a32 out nocopy JTF_NUMBER_TABLE
    , p3_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure runamortization(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_based_on_terms  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_DATE_TABLE
    , p5_a2 out nocopy JTF_DATE_TABLE
    , p5_a3 out nocopy JTF_DATE_TABLE
    , p5_a4 out nocopy JTF_NUMBER_TABLE
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_NUMBER_TABLE
    , p5_a7 out nocopy JTF_NUMBER_TABLE
    , p5_a8 out nocopy JTF_NUMBER_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_NUMBER_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_NUMBER_TABLE
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a15 out nocopy JTF_NUMBER_TABLE
    , p5_a16 out nocopy JTF_NUMBER_TABLE
    , p5_a17 out nocopy JTF_NUMBER_TABLE
    , p5_a18 out nocopy JTF_NUMBER_TABLE
    , p5_a19 out nocopy JTF_NUMBER_TABLE
    , p5_a20 out nocopy JTF_NUMBER_TABLE
    , p5_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a24 out nocopy JTF_NUMBER_TABLE
    , p5_a25 out nocopy JTF_NUMBER_TABLE
    , p5_a26 out nocopy JTF_NUMBER_TABLE
    , p5_a27 out nocopy JTF_NUMBER_TABLE
    , p5_a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , p5_a32 out nocopy JTF_NUMBER_TABLE
    , p5_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure getinstallment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  DATE
    , p5_a2 out nocopy  DATE
    , p5_a3 out nocopy  DATE
    , p5_a4 out nocopy  NUMBER
    , p5_a5 out nocopy  NUMBER
    , p5_a6 out nocopy  NUMBER
    , p5_a7 out nocopy  NUMBER
    , p5_a8 out nocopy  NUMBER
    , p5_a9 out nocopy  NUMBER
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  NUMBER
    , p5_a12 out nocopy  NUMBER
    , p5_a13 out nocopy  NUMBER
    , p5_a14 out nocopy  NUMBER
    , p5_a15 out nocopy  NUMBER
    , p5_a16 out nocopy  NUMBER
    , p5_a17 out nocopy  NUMBER
    , p5_a18 out nocopy  NUMBER
    , p5_a19 out nocopy  NUMBER
    , p5_a20 out nocopy  NUMBER
    , p5_a21 out nocopy  VARCHAR2
    , p5_a22 out nocopy  VARCHAR2
    , p5_a23 out nocopy  VARCHAR2
    , p5_a24 out nocopy  NUMBER
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  NUMBER
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  VARCHAR2
    , p5_a31 out nocopy  VARCHAR2
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure getopeninstallment(p_init_msg_list  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  DATE
    , p3_a2 out nocopy  DATE
    , p3_a3 out nocopy  DATE
    , p3_a4 out nocopy  NUMBER
    , p3_a5 out nocopy  NUMBER
    , p3_a6 out nocopy  NUMBER
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  NUMBER
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  NUMBER
    , p3_a11 out nocopy  NUMBER
    , p3_a12 out nocopy  NUMBER
    , p3_a13 out nocopy  NUMBER
    , p3_a14 out nocopy  NUMBER
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  NUMBER
    , p3_a17 out nocopy  NUMBER
    , p3_a18 out nocopy  NUMBER
    , p3_a19 out nocopy  NUMBER
    , p3_a20 out nocopy  NUMBER
    , p3_a21 out nocopy  VARCHAR2
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  VARCHAR2
    , p3_a24 out nocopy  NUMBER
    , p3_a25 out nocopy  NUMBER
    , p3_a26 out nocopy  NUMBER
    , p3_a27 out nocopy  NUMBER
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  NUMBER
    , p3_a33 out nocopy  VARCHAR2
    , p4_a0 out nocopy JTF_NUMBER_TABLE
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a2 out nocopy JTF_NUMBER_TABLE
    , p4_a3 out nocopy JTF_NUMBER_TABLE
    , p4_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a5 out nocopy JTF_NUMBER_TABLE
    , p4_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a7 out nocopy JTF_NUMBER_TABLE
    , p4_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure preprocessinstallment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  DATE
    , p5_a2 out nocopy  DATE
    , p5_a3 out nocopy  DATE
    , p5_a4 out nocopy  NUMBER
    , p5_a5 out nocopy  NUMBER
    , p5_a6 out nocopy  NUMBER
    , p5_a7 out nocopy  NUMBER
    , p5_a8 out nocopy  NUMBER
    , p5_a9 out nocopy  NUMBER
    , p5_a10 out nocopy  NUMBER
    , p5_a11 out nocopy  NUMBER
    , p5_a12 out nocopy  NUMBER
    , p5_a13 out nocopy  NUMBER
    , p5_a14 out nocopy  NUMBER
    , p5_a15 out nocopy  NUMBER
    , p5_a16 out nocopy  NUMBER
    , p5_a17 out nocopy  NUMBER
    , p5_a18 out nocopy  NUMBER
    , p5_a19 out nocopy  NUMBER
    , p5_a20 out nocopy  NUMBER
    , p5_a21 out nocopy  VARCHAR2
    , p5_a22 out nocopy  VARCHAR2
    , p5_a23 out nocopy  VARCHAR2
    , p5_a24 out nocopy  NUMBER
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  NUMBER
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  VARCHAR2
    , p5_a30 out nocopy  VARCHAR2
    , p5_a31 out nocopy  VARCHAR2
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure preprocessopeninstallment(p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_loan_id  NUMBER
    , p_installment_number  NUMBER
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  DATE
    , p4_a2 out nocopy  DATE
    , p4_a3 out nocopy  DATE
    , p4_a4 out nocopy  NUMBER
    , p4_a5 out nocopy  NUMBER
    , p4_a6 out nocopy  NUMBER
    , p4_a7 out nocopy  NUMBER
    , p4_a8 out nocopy  NUMBER
    , p4_a9 out nocopy  NUMBER
    , p4_a10 out nocopy  NUMBER
    , p4_a11 out nocopy  NUMBER
    , p4_a12 out nocopy  NUMBER
    , p4_a13 out nocopy  NUMBER
    , p4_a14 out nocopy  NUMBER
    , p4_a15 out nocopy  NUMBER
    , p4_a16 out nocopy  NUMBER
    , p4_a17 out nocopy  NUMBER
    , p4_a18 out nocopy  NUMBER
    , p4_a19 out nocopy  NUMBER
    , p4_a20 out nocopy  NUMBER
    , p4_a21 out nocopy  VARCHAR2
    , p4_a22 out nocopy  VARCHAR2
    , p4_a23 out nocopy  VARCHAR2
    , p4_a24 out nocopy  NUMBER
    , p4_a25 out nocopy  NUMBER
    , p4_a26 out nocopy  NUMBER
    , p4_a27 out nocopy  NUMBER
    , p4_a28 out nocopy  VARCHAR2
    , p4_a29 out nocopy  VARCHAR2
    , p4_a30 out nocopy  VARCHAR2
    , p4_a31 out nocopy  VARCHAR2
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  function calculateeppayment(p_loan_amount  NUMBER
    , p_num_intervals  NUMBER
    , p_ending_balance  NUMBER
    , p_pay_in_arrears  number
  ) return number;
  function calculatepayment(p_loan_amount  NUMBER
    , p_periodic_rate  NUMBER
    , p_num_intervals  NUMBER
    , p_ending_balance  NUMBER
    , p_pay_in_arrears  number
  ) return number;
end lns_financials_w;

/
