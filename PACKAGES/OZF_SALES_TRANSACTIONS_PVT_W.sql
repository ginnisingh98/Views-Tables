--------------------------------------------------------
--  DDL for Package OZF_SALES_TRANSACTIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SALES_TRANSACTIONS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: ozfwstns.pls 115.2 2004/04/07 13:40:23 sangara noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ozf_sales_transactions_pvt.sales_trans_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_DATE_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_VARCHAR2_TABLE_100
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_VARCHAR2_TABLE_300
    , a42 JTF_VARCHAR2_TABLE_300
    , a43 JTF_VARCHAR2_TABLE_300
    , a44 JTF_VARCHAR2_TABLE_300
    , a45 JTF_VARCHAR2_TABLE_300
    , a46 JTF_VARCHAR2_TABLE_300
    , a47 JTF_VARCHAR2_TABLE_300
    , a48 JTF_VARCHAR2_TABLE_300
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_VARCHAR2_TABLE_300
    , a51 JTF_VARCHAR2_TABLE_300
    , a52 JTF_VARCHAR2_TABLE_300
    , a53 JTF_VARCHAR2_TABLE_300
    , a54 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t ozf_sales_transactions_pvt.sales_trans_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_DATE_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_VARCHAR2_TABLE_100
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_NUMBER_TABLE
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_NUMBER_TABLE
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_VARCHAR2_TABLE_300
    , a42 out nocopy JTF_VARCHAR2_TABLE_300
    , a43 out nocopy JTF_VARCHAR2_TABLE_300
    , a44 out nocopy JTF_VARCHAR2_TABLE_300
    , a45 out nocopy JTF_VARCHAR2_TABLE_300
    , a46 out nocopy JTF_VARCHAR2_TABLE_300
    , a47 out nocopy JTF_VARCHAR2_TABLE_300
    , a48 out nocopy JTF_VARCHAR2_TABLE_300
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_VARCHAR2_TABLE_300
    , a51 out nocopy JTF_VARCHAR2_TABLE_300
    , a52 out nocopy JTF_VARCHAR2_TABLE_300
    , a53 out nocopy JTF_VARCHAR2_TABLE_300
    , a54 out nocopy JTF_NUMBER_TABLE
    );

  procedure validate_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  VARCHAR2
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  DATE
    , p6_a11  NUMBER
    , p6_a12  VARCHAR2
    , p6_a13  NUMBER
    , p6_a14  NUMBER
    , p6_a15  NUMBER
    , p6_a16  NUMBER
    , p6_a17  NUMBER
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  DATE
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  NUMBER
    , p6_a25  VARCHAR2
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  VARCHAR2
    , p6_a29  NUMBER
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  VARCHAR2
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  VARCHAR2
    , p6_a51  VARCHAR2
    , p6_a52  VARCHAR2
    , p6_a53  VARCHAR2
    , p6_a54  NUMBER
  );
  procedure create_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  DATE
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  NUMBER
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  DATE
    , p4_a11  NUMBER
    , p4_a12  VARCHAR2
    , p4_a13  NUMBER
    , p4_a14  NUMBER
    , p4_a15  NUMBER
    , p4_a16  NUMBER
    , p4_a17  NUMBER
    , p4_a18  NUMBER
    , p4_a19  NUMBER
    , p4_a20  NUMBER
    , p4_a21  DATE
    , p4_a22  NUMBER
    , p4_a23  VARCHAR2
    , p4_a24  NUMBER
    , p4_a25  VARCHAR2
    , p4_a26  NUMBER
    , p4_a27  NUMBER
    , p4_a28  VARCHAR2
    , p4_a29  NUMBER
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  NUMBER
    , p4_a33  NUMBER
    , p4_a34  NUMBER
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  VARCHAR2
    , p4_a38  VARCHAR2
    , p4_a39  VARCHAR2
    , p4_a40  VARCHAR2
    , p4_a41  VARCHAR2
    , p4_a42  VARCHAR2
    , p4_a43  VARCHAR2
    , p4_a44  VARCHAR2
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  VARCHAR2
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p4_a53  VARCHAR2
    , p4_a54  NUMBER
    , x_sales_transaction_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  );
  procedure validate_inventory_level(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  DATE
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  NUMBER
    , p3_a7  VARCHAR2
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  DATE
    , p3_a11  NUMBER
    , p3_a12  NUMBER
    , p3_a13  VARCHAR2
    , p3_a14  VARCHAR2
    , p3_a15  VARCHAR2
    , p3_a16  DATE
    , p3_a17  VARCHAR2
    , p3_a18  NUMBER
    , p3_a19  NUMBER
    , p3_a20  VARCHAR2
    , p3_a21  VARCHAR2
    , p3_a22  VARCHAR2
    , p3_a23  VARCHAR2
    , p3_a24  VARCHAR2
    , p3_a25  VARCHAR2
    , p3_a26  VARCHAR2
    , p3_a27  NUMBER
    , p3_a28  VARCHAR2
    , p3_a29  VARCHAR2
    , p3_a30  VARCHAR2
    , p3_a31  VARCHAR2
    , p3_a32  NUMBER
    , p3_a33  NUMBER
    , p3_a34  VARCHAR2
    , p3_a35  VARCHAR2
    , p3_a36  VARCHAR2
    , p3_a37  VARCHAR2
    , p3_a38  VARCHAR2
    , p3_a39  VARCHAR2
    , p3_a40  VARCHAR2
    , p3_a41  NUMBER
    , p3_a42  VARCHAR2
    , p3_a43  VARCHAR2
    , p3_a44  VARCHAR2
    , p3_a45  VARCHAR2
    , p3_a46  NUMBER
    , p3_a47  NUMBER
    , p3_a48  NUMBER
    , p3_a49  NUMBER
    , p3_a50  VARCHAR2
    , p3_a51  VARCHAR2
    , p3_a52  VARCHAR2
    , p3_a53  VARCHAR2
    , p3_a54  VARCHAR2
    , p3_a55  VARCHAR2
    , p3_a56  VARCHAR2
    , p3_a57  VARCHAR2
    , p3_a58  NUMBER
    , p3_a59  VARCHAR2
    , p3_a60  VARCHAR2
    , p3_a61  VARCHAR2
    , p3_a62  VARCHAR2
    , p3_a63  NUMBER
    , p3_a64  NUMBER
    , p3_a65  NUMBER
    , p3_a66  NUMBER
    , p3_a67  VARCHAR2
    , p3_a68  VARCHAR2
    , p3_a69  VARCHAR2
    , p3_a70  VARCHAR2
    , p3_a71  VARCHAR2
    , p3_a72  VARCHAR2
    , p3_a73  VARCHAR2
    , p3_a74  VARCHAR2
    , p3_a75  NUMBER
    , p3_a76  VARCHAR2
    , p3_a77  VARCHAR2
    , p3_a78  VARCHAR2
    , p3_a79  VARCHAR2
    , p3_a80  NUMBER
    , p3_a81  NUMBER
    , p3_a82  VARCHAR2
    , p3_a83  NUMBER
    , p3_a84  VARCHAR2
    , p3_a85  VARCHAR2
    , p3_a86  VARCHAR2
    , p3_a87  VARCHAR2
    , p3_a88  VARCHAR2
    , p3_a89  VARCHAR2
    , p3_a90  VARCHAR2
    , p3_a91  NUMBER
    , p3_a92  VARCHAR2
    , p3_a93  VARCHAR2
    , p3_a94  VARCHAR2
    , p3_a95  VARCHAR2
    , p3_a96  VARCHAR2
    , p3_a97  NUMBER
    , p3_a98  VARCHAR2
    , p3_a99  VARCHAR2
    , p3_a100  VARCHAR2
    , p3_a101  NUMBER
    , p3_a102  VARCHAR2
    , p3_a103  NUMBER
    , p3_a104  VARCHAR2
    , p3_a105  NUMBER
    , p3_a106  VARCHAR2
    , p3_a107  NUMBER
    , p3_a108  VARCHAR2
    , p3_a109  VARCHAR2
    , p3_a110  VARCHAR2
    , p3_a111  VARCHAR2
    , p3_a112  NUMBER
    , p3_a113  NUMBER
    , p3_a114  VARCHAR2
    , p3_a115  VARCHAR2
    , p3_a116  VARCHAR2
    , p3_a117  NUMBER
    , p3_a118  NUMBER
    , p3_a119  VARCHAR2
    , p3_a120  VARCHAR2
    , p3_a121  VARCHAR2
    , p3_a122  VARCHAR2
    , p3_a123  VARCHAR2
    , p3_a124  NUMBER
    , p3_a125  NUMBER
    , p3_a126  VARCHAR2
    , p3_a127  VARCHAR2
    , p3_a128  NUMBER
    , p3_a129  VARCHAR2
    , p3_a130  DATE
    , p3_a131  VARCHAR2
    , p3_a132  VARCHAR2
    , p3_a133  VARCHAR2
    , p3_a134  VARCHAR2
    , p3_a135  DATE
    , p3_a136  VARCHAR2
    , p3_a137  DATE
    , p3_a138  DATE
    , p3_a139  NUMBER
    , p3_a140  NUMBER
    , p3_a141  NUMBER
    , p3_a142  NUMBER
    , p3_a143  NUMBER
    , p3_a144  NUMBER
    , p3_a145  VARCHAR2
    , p3_a146  NUMBER
    , p3_a147  NUMBER
    , p3_a148  VARCHAR2
    , p3_a149  NUMBER
    , p3_a150  NUMBER
    , p3_a151  NUMBER
    , p3_a152  VARCHAR2
    , p3_a153  NUMBER
    , p3_a154  NUMBER
    , p3_a155  NUMBER
    , p3_a156  NUMBER
    , p3_a157  VARCHAR2
    , p3_a158  DATE
    , p3_a159  VARCHAR2
    , p3_a160  NUMBER
    , p3_a161  VARCHAR2
    , p3_a162  VARCHAR2
    , p3_a163  VARCHAR2
    , p3_a164  VARCHAR2
    , p3_a165  VARCHAR2
    , p3_a166  VARCHAR2
    , p3_a167  VARCHAR2
    , p3_a168  VARCHAR2
    , p3_a169  VARCHAR2
    , p3_a170  VARCHAR2
    , p3_a171  VARCHAR2
    , p3_a172  VARCHAR2
    , p3_a173  VARCHAR2
    , p3_a174  VARCHAR2
    , p3_a175  VARCHAR2
    , p3_a176  VARCHAR2
    , p3_a177  VARCHAR2
    , p3_a178  VARCHAR2
    , p3_a179  VARCHAR2
    , p3_a180  VARCHAR2
    , p3_a181  VARCHAR2
    , p3_a182  VARCHAR2
    , p3_a183  NUMBER
    , p3_a184  VARCHAR2
    , p3_a185  NUMBER
    , p3_a186  NUMBER
    , p3_a187  VARCHAR2
    , p3_a188  VARCHAR2
    , p3_a189  VARCHAR2
    , p3_a190  VARCHAR2
    , p3_a191  NUMBER
    , p3_a192  VARCHAR2
    , p3_a193  VARCHAR2
    , p3_a194  VARCHAR2
    , p3_a195  VARCHAR2
    , p3_a196  VARCHAR2
    , p3_a197  VARCHAR2
    , p3_a198  VARCHAR2
    , p3_a199  VARCHAR2
    , p3_a200  VARCHAR2
    , p3_a201  VARCHAR2
    , p3_a202  VARCHAR2
    , p3_a203  VARCHAR2
    , p3_a204  VARCHAR2
    , p3_a205  VARCHAR2
    , p3_a206  VARCHAR2
    , p3_a207  VARCHAR2
    , p3_a208  VARCHAR2
    , p3_a209  VARCHAR2
    , p3_a210  VARCHAR2
    , p3_a211  VARCHAR2
    , p3_a212  VARCHAR2
    , p3_a213  VARCHAR2
    , p3_a214  VARCHAR2
    , p3_a215  VARCHAR2
    , p3_a216  VARCHAR2
    , p3_a217  VARCHAR2
    , p3_a218  VARCHAR2
    , p3_a219  VARCHAR2
    , p3_a220  VARCHAR2
    , p3_a221  VARCHAR2
    , p3_a222  VARCHAR2
    , p3_a223  VARCHAR2
    , p3_a224  VARCHAR2
    , p3_a225  NUMBER
    , x_valid out nocopy  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ozf_sales_transactions_pvt_w;

 

/
