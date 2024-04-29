--------------------------------------------------------
--  DDL for Package OKL_LEASE_OPPORTUNITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_OPPORTUNITY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLELOPS.pls 120.5 2007/03/20 22:38:01 rravikir noship $ */
  procedure create_lease_opp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  DATE
    , p3_a21  DATE
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  DATE
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  DATE
    , p3_a37  DATE
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  NUMBER
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p_quick_quote_id  NUMBER
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  VARCHAR2
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  VARCHAR2
    , p5_a19 out nocopy  VARCHAR2
    , p5_a20 out nocopy  DATE
    , p5_a21 out nocopy  DATE
    , p5_a22 out nocopy  NUMBER
    , p5_a23 out nocopy  NUMBER
    , p5_a24 out nocopy  NUMBER
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  VARCHAR2
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  NUMBER
    , p5_a30 out nocopy  DATE
    , p5_a31 out nocopy  NUMBER
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  NUMBER
    , p5_a34 out nocopy  NUMBER
    , p5_a35 out nocopy  NUMBER
    , p5_a36 out nocopy  DATE
    , p5_a37 out nocopy  DATE
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  VARCHAR2
    , p5_a40 out nocopy  VARCHAR2
    , p5_a41 out nocopy  NUMBER
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  VARCHAR2
    , p5_a44 out nocopy  VARCHAR2
    , p5_a45 out nocopy  NUMBER
    , p5_a46 out nocopy  NUMBER
    , p5_a47 out nocopy  NUMBER
    , p5_a48 out nocopy  NUMBER
    , p5_a49 out nocopy  VARCHAR2
    , p5_a50 out nocopy  VARCHAR2
    , p5_a51 out nocopy  VARCHAR2
    , p5_a52 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_lease_opp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  DATE
    , p3_a21  DATE
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  DATE
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  DATE
    , p3_a37  DATE
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  NUMBER
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  NUMBER
    , p4_a2 out nocopy  VARCHAR2
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  VARCHAR2
    , p4_a7 out nocopy  VARCHAR2
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  VARCHAR2
    , p4_a10 out nocopy  VARCHAR2
    , p4_a11 out nocopy  VARCHAR2
    , p4_a12 out nocopy  VARCHAR2
    , p4_a13 out nocopy  VARCHAR2
    , p4_a14 out nocopy  VARCHAR2
    , p4_a15 out nocopy  VARCHAR2
    , p4_a16 out nocopy  VARCHAR2
    , p4_a17 out nocopy  VARCHAR2
    , p4_a18 out nocopy  VARCHAR2
    , p4_a19 out nocopy  VARCHAR2
    , p4_a20 out nocopy  DATE
    , p4_a21 out nocopy  DATE
    , p4_a22 out nocopy  NUMBER
    , p4_a23 out nocopy  NUMBER
    , p4_a24 out nocopy  NUMBER
    , p4_a25 out nocopy  NUMBER
    , p4_a26 out nocopy  NUMBER
    , p4_a27 out nocopy  VARCHAR2
    , p4_a28 out nocopy  VARCHAR2
    , p4_a29 out nocopy  NUMBER
    , p4_a30 out nocopy  DATE
    , p4_a31 out nocopy  NUMBER
    , p4_a32 out nocopy  NUMBER
    , p4_a33 out nocopy  NUMBER
    , p4_a34 out nocopy  NUMBER
    , p4_a35 out nocopy  NUMBER
    , p4_a36 out nocopy  DATE
    , p4_a37 out nocopy  DATE
    , p4_a38 out nocopy  VARCHAR2
    , p4_a39 out nocopy  VARCHAR2
    , p4_a40 out nocopy  VARCHAR2
    , p4_a41 out nocopy  NUMBER
    , p4_a42 out nocopy  VARCHAR2
    , p4_a43 out nocopy  VARCHAR2
    , p4_a44 out nocopy  VARCHAR2
    , p4_a45 out nocopy  NUMBER
    , p4_a46 out nocopy  NUMBER
    , p4_a47 out nocopy  NUMBER
    , p4_a48 out nocopy  NUMBER
    , p4_a49 out nocopy  VARCHAR2
    , p4_a50 out nocopy  VARCHAR2
    , p4_a51 out nocopy  VARCHAR2
    , p4_a52 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure defaults_for_lease_opp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  VARCHAR2
    , p3_a3  VARCHAR2
    , p3_a4  VARCHAR2
    , p3_a5  VARCHAR2
    , p3_a6  VARCHAR2
    , p3_a7  VARCHAR2
    , p3_a8  VARCHAR2
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p3_a12  VARCHAR2
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  VARCHAR2
    , p3_a17  VARCHAR2
    , p3_a18  VARCHAR2
    , p3_a19  VARCHAR2
    , p3_a20  DATE
    , p3_a21  DATE
    , p3_a22  NUMBER
    , p3_a23  NUMBER
    , p3_a24  NUMBER
    , p3_a25  NUMBER
    , p3_a26  NUMBER
    , p3_a27  VARCHAR2
    , p3_a28  VARCHAR2
    , p3_a29  NUMBER
    , p3_a30  DATE
    , p3_a31  NUMBER
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  NUMBER
    , p3_a35  NUMBER
    , p3_a36  DATE
    , p3_a37  DATE
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  NUMBER
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  NUMBER
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  VARCHAR2
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p_user_id  VARCHAR2
    , x_sales_rep_name out nocopy  VARCHAR2
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
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  DATE
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  DATE
    , p6_a31 out nocopy  NUMBER
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  DATE
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  NUMBER
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  NUMBER
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  NUMBER
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , x_dff_name out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure duplicate_lease_opp(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_control  VARCHAR2
    , p_source_leaseopp_id  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  DATE
    , p4_a21  DATE
    , p4_a22  NUMBER
    , p4_a23  NUMBER
    , p4_a24  NUMBER
    , p4_a25  NUMBER
    , p4_a26  NUMBER
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  NUMBER
    , p4_a30  DATE
    , p4_a31  NUMBER
    , p4_a32  NUMBER
    , p4_a33  NUMBER
    , p4_a34  NUMBER
    , p4_a35  NUMBER
    , p4_a36  DATE
    , p4_a37  DATE
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  NUMBER
    , p4_a42  VARCHAR2
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  NUMBER
    , p4_a46  NUMBER
    , p4_a47  NUMBER
    , p4_a48  NUMBER
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p5_a0 out nocopy  NUMBER
    , p5_a1 out nocopy  NUMBER
    , p5_a2 out nocopy  VARCHAR2
    , p5_a3 out nocopy  VARCHAR2
    , p5_a4 out nocopy  VARCHAR2
    , p5_a5 out nocopy  VARCHAR2
    , p5_a6 out nocopy  VARCHAR2
    , p5_a7 out nocopy  VARCHAR2
    , p5_a8 out nocopy  VARCHAR2
    , p5_a9 out nocopy  VARCHAR2
    , p5_a10 out nocopy  VARCHAR2
    , p5_a11 out nocopy  VARCHAR2
    , p5_a12 out nocopy  VARCHAR2
    , p5_a13 out nocopy  VARCHAR2
    , p5_a14 out nocopy  VARCHAR2
    , p5_a15 out nocopy  VARCHAR2
    , p5_a16 out nocopy  VARCHAR2
    , p5_a17 out nocopy  VARCHAR2
    , p5_a18 out nocopy  VARCHAR2
    , p5_a19 out nocopy  VARCHAR2
    , p5_a20 out nocopy  DATE
    , p5_a21 out nocopy  DATE
    , p5_a22 out nocopy  NUMBER
    , p5_a23 out nocopy  NUMBER
    , p5_a24 out nocopy  NUMBER
    , p5_a25 out nocopy  NUMBER
    , p5_a26 out nocopy  NUMBER
    , p5_a27 out nocopy  VARCHAR2
    , p5_a28 out nocopy  VARCHAR2
    , p5_a29 out nocopy  NUMBER
    , p5_a30 out nocopy  DATE
    , p5_a31 out nocopy  NUMBER
    , p5_a32 out nocopy  NUMBER
    , p5_a33 out nocopy  NUMBER
    , p5_a34 out nocopy  NUMBER
    , p5_a35 out nocopy  NUMBER
    , p5_a36 out nocopy  DATE
    , p5_a37 out nocopy  DATE
    , p5_a38 out nocopy  VARCHAR2
    , p5_a39 out nocopy  VARCHAR2
    , p5_a40 out nocopy  VARCHAR2
    , p5_a41 out nocopy  NUMBER
    , p5_a42 out nocopy  VARCHAR2
    , p5_a43 out nocopy  VARCHAR2
    , p5_a44 out nocopy  VARCHAR2
    , p5_a45 out nocopy  NUMBER
    , p5_a46 out nocopy  NUMBER
    , p5_a47 out nocopy  NUMBER
    , p5_a48 out nocopy  NUMBER
    , p5_a49 out nocopy  VARCHAR2
    , p5_a50 out nocopy  VARCHAR2
    , p5_a51 out nocopy  VARCHAR2
    , p5_a52 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_lease_opportunity_pvt_w;

/
