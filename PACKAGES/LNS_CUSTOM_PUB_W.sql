--------------------------------------------------------
--  DDL for Package LNS_CUSTOM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_CUSTOM_PUB_W" AUTHID CURRENT_USER as
  /* $Header: LNS_CUST_PUBJ_S.pls 120.0.12010000.4 2010/03/19 08:33:23 gparuchu ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_custom_pub.custom_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
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
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_2000
    , a50 JTF_VARCHAR2_TABLE_2000
    , a51 JTF_VARCHAR2_TABLE_2000
    , a52 JTF_VARCHAR2_TABLE_2000
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p1(t lns_custom_pub.custom_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
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
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_2000
    , a50 out nocopy JTF_VARCHAR2_TABLE_2000
    , a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure resetcustomschedule(p_loan_id  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_update_header  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure createcustomschedule(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_DATE_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_NUMBER_TABLE
    , p0_a15 JTF_NUMBER_TABLE
    , p0_a16 JTF_VARCHAR2_TABLE_100
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_NUMBER_TABLE
    , p0_a38 JTF_NUMBER_TABLE
    , p0_a39 JTF_NUMBER_TABLE
    , p0_a40 JTF_NUMBER_TABLE
    , p0_a41 JTF_NUMBER_TABLE
    , p0_a42 JTF_NUMBER_TABLE
    , p0_a43 JTF_NUMBER_TABLE
    , p0_a44 JTF_NUMBER_TABLE
    , p0_a45 JTF_VARCHAR2_TABLE_100
    , p0_a46 JTF_VARCHAR2_TABLE_100
    , p0_a47 JTF_VARCHAR2_TABLE_100
    , p0_a48 JTF_NUMBER_TABLE
    , p0_a49 JTF_VARCHAR2_TABLE_2000
    , p0_a50 JTF_VARCHAR2_TABLE_2000
    , p0_a51 JTF_VARCHAR2_TABLE_2000
    , p0_a52 JTF_VARCHAR2_TABLE_2000
    , p0_a53 JTF_NUMBER_TABLE
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p_loan_id  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_invalid_installment_num out nocopy  NUMBER
  );
  procedure updatecustomschedule(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_DATE_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_NUMBER_TABLE
    , p0_a15 JTF_NUMBER_TABLE
    , p0_a16 JTF_VARCHAR2_TABLE_100
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_NUMBER_TABLE
    , p0_a38 JTF_NUMBER_TABLE
    , p0_a39 JTF_NUMBER_TABLE
    , p0_a40 JTF_NUMBER_TABLE
    , p0_a41 JTF_NUMBER_TABLE
    , p0_a42 JTF_NUMBER_TABLE
    , p0_a43 JTF_NUMBER_TABLE
    , p0_a44 JTF_NUMBER_TABLE
    , p0_a45 JTF_VARCHAR2_TABLE_100
    , p0_a46 JTF_VARCHAR2_TABLE_100
    , p0_a47 JTF_VARCHAR2_TABLE_100
    , p0_a48 JTF_NUMBER_TABLE
    , p0_a49 JTF_VARCHAR2_TABLE_2000
    , p0_a50 JTF_VARCHAR2_TABLE_2000
    , p0_a51 JTF_VARCHAR2_TABLE_2000
    , p0_a52 JTF_VARCHAR2_TABLE_2000
    , p0_a53 JTF_NUMBER_TABLE
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p_loan_id  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_invalid_installment_num out nocopy  NUMBER
  );
  procedure createcustomsched(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , x_custom_sched_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure updatecustomsched(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validatecustomtable(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_DATE_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_NUMBER_TABLE
    , p0_a15 JTF_NUMBER_TABLE
    , p0_a16 JTF_VARCHAR2_TABLE_100
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_NUMBER_TABLE
    , p0_a38 JTF_NUMBER_TABLE
    , p0_a39 JTF_NUMBER_TABLE
    , p0_a40 JTF_NUMBER_TABLE
    , p0_a41 JTF_NUMBER_TABLE
    , p0_a42 JTF_NUMBER_TABLE
    , p0_a43 JTF_NUMBER_TABLE
    , p0_a44 JTF_NUMBER_TABLE
    , p0_a45 JTF_VARCHAR2_TABLE_100
    , p0_a46 JTF_VARCHAR2_TABLE_100
    , p0_a47 JTF_VARCHAR2_TABLE_100
    , p0_a48 JTF_NUMBER_TABLE
    , p0_a49 JTF_VARCHAR2_TABLE_2000
    , p0_a50 JTF_VARCHAR2_TABLE_2000
    , p0_a51 JTF_VARCHAR2_TABLE_2000
    , p0_a52 JTF_VARCHAR2_TABLE_2000
    , p0_a53 JTF_NUMBER_TABLE
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p_loan_id  NUMBER
    , p_create_flag  number
    , x_installment out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure validatecustomrow(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure recalccustomschedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_loan_id  NUMBER
    , p_amort_method  VARCHAR2
    , p_based_on_terms  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_DATE_TABLE
    , p7_a4 in out nocopy JTF_DATE_TABLE
    , p7_a5 in out nocopy JTF_DATE_TABLE
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_NUMBER_TABLE
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_NUMBER_TABLE
    , p7_a13 in out nocopy JTF_NUMBER_TABLE
    , p7_a14 in out nocopy JTF_NUMBER_TABLE
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a37 in out nocopy JTF_NUMBER_TABLE
    , p7_a38 in out nocopy JTF_NUMBER_TABLE
    , p7_a39 in out nocopy JTF_NUMBER_TABLE
    , p7_a40 in out nocopy JTF_NUMBER_TABLE
    , p7_a41 in out nocopy JTF_NUMBER_TABLE
    , p7_a42 in out nocopy JTF_NUMBER_TABLE
    , p7_a43 in out nocopy JTF_NUMBER_TABLE
    , p7_a44 in out nocopy JTF_NUMBER_TABLE
    , p7_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a47 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a48 in out nocopy JTF_NUMBER_TABLE
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a51 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a52 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a53 in out nocopy JTF_NUMBER_TABLE
    , p7_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure loadcustomschedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_loan_id  NUMBER
    , p_based_on_terms  VARCHAR2
    , x_amort_method out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_DATE_TABLE
    , p7_a4 out nocopy JTF_DATE_TABLE
    , p7_a5 out nocopy JTF_DATE_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_NUMBER_TABLE
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_NUMBER_TABLE
    , p7_a40 out nocopy JTF_NUMBER_TABLE
    , p7_a41 out nocopy JTF_NUMBER_TABLE
    , p7_a42 out nocopy JTF_NUMBER_TABLE
    , p7_a43 out nocopy JTF_NUMBER_TABLE
    , p7_a44 out nocopy JTF_NUMBER_TABLE
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a48 out nocopy JTF_NUMBER_TABLE
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a53 out nocopy JTF_NUMBER_TABLE
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure savecustomschedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_loan_id  NUMBER
    , p_amort_method  VARCHAR2
    , p_based_on_terms  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_DATE_TABLE
    , p7_a4 in out nocopy JTF_DATE_TABLE
    , p7_a5 in out nocopy JTF_DATE_TABLE
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_NUMBER_TABLE
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_NUMBER_TABLE
    , p7_a13 in out nocopy JTF_NUMBER_TABLE
    , p7_a14 in out nocopy JTF_NUMBER_TABLE
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a37 in out nocopy JTF_NUMBER_TABLE
    , p7_a38 in out nocopy JTF_NUMBER_TABLE
    , p7_a39 in out nocopy JTF_NUMBER_TABLE
    , p7_a40 in out nocopy JTF_NUMBER_TABLE
    , p7_a41 in out nocopy JTF_NUMBER_TABLE
    , p7_a42 in out nocopy JTF_NUMBER_TABLE
    , p7_a43 in out nocopy JTF_NUMBER_TABLE
    , p7_a44 in out nocopy JTF_NUMBER_TABLE
    , p7_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a47 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a48 in out nocopy JTF_NUMBER_TABLE
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a51 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a52 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a53 in out nocopy JTF_NUMBER_TABLE
    , p7_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure shiftcustomschedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_loan_id  NUMBER
    , p_old_due_date  DATE
    , p_new_due_date  DATE
    , p_amort_method  VARCHAR2
    , p_based_on_terms  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_DATE_TABLE
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_DATE_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_NUMBER_TABLE
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
    , p9_a10 in out nocopy JTF_NUMBER_TABLE
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_NUMBER_TABLE
    , p9_a13 in out nocopy JTF_NUMBER_TABLE
    , p9_a14 in out nocopy JTF_NUMBER_TABLE
    , p9_a15 in out nocopy JTF_NUMBER_TABLE
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 in out nocopy JTF_NUMBER_TABLE
    , p9_a38 in out nocopy JTF_NUMBER_TABLE
    , p9_a39 in out nocopy JTF_NUMBER_TABLE
    , p9_a40 in out nocopy JTF_NUMBER_TABLE
    , p9_a41 in out nocopy JTF_NUMBER_TABLE
    , p9_a42 in out nocopy JTF_NUMBER_TABLE
    , p9_a43 in out nocopy JTF_NUMBER_TABLE
    , p9_a44 in out nocopy JTF_NUMBER_TABLE
    , p9_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a46 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a47 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a48 in out nocopy JTF_NUMBER_TABLE
    , p9_a49 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a50 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a51 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a52 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a53 in out nocopy JTF_NUMBER_TABLE
    , p9_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure addmissinginstallment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  DATE
    , p4_a5  DATE
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  NUMBER
    , p4_a11  NUMBER
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , p4_a14  NUMBER
    , p4_a15  NUMBER
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  NUMBER
    , p4_a38  NUMBER
    , p4_a39  NUMBER
    , p4_a40  NUMBER
    , p4_a41  NUMBER
    , p4_a42  NUMBER
    , p4_a43  NUMBER
    , p4_a44  NUMBER
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  NUMBER
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p4_a53  NUMBER
    , p4_a54  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end lns_custom_pub_w;

/
