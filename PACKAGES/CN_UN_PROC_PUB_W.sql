--------------------------------------------------------
--  DDL for Package CN_UN_PROC_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_UN_PROC_PUB_W" AUTHID CURRENT_USER as
  /* $Header: cnwnpros.pls 115.7 2002/11/26 01:35:08 mblum ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_un_proc_pub.adj_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_VARCHAR2_TABLE_300
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
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
    , a54 JTF_VARCHAR2_TABLE_300
    , a55 JTF_VARCHAR2_TABLE_300
    , a56 JTF_VARCHAR2_TABLE_300
    , a57 JTF_VARCHAR2_TABLE_300
    , a58 JTF_VARCHAR2_TABLE_300
    , a59 JTF_VARCHAR2_TABLE_300
    , a60 JTF_VARCHAR2_TABLE_300
    , a61 JTF_VARCHAR2_TABLE_300
    , a62 JTF_VARCHAR2_TABLE_300
    , a63 JTF_VARCHAR2_TABLE_300
    , a64 JTF_VARCHAR2_TABLE_300
    , a65 JTF_VARCHAR2_TABLE_300
    , a66 JTF_VARCHAR2_TABLE_300
    , a67 JTF_VARCHAR2_TABLE_300
    , a68 JTF_VARCHAR2_TABLE_300
    , a69 JTF_VARCHAR2_TABLE_300
    , a70 JTF_VARCHAR2_TABLE_300
    , a71 JTF_VARCHAR2_TABLE_300
    , a72 JTF_VARCHAR2_TABLE_300
    , a73 JTF_VARCHAR2_TABLE_300
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_300
    , a76 JTF_VARCHAR2_TABLE_300
    , a77 JTF_VARCHAR2_TABLE_300
    , a78 JTF_VARCHAR2_TABLE_300
    , a79 JTF_VARCHAR2_TABLE_300
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_300
    , a96 JTF_VARCHAR2_TABLE_300
    , a97 JTF_VARCHAR2_TABLE_300
    , a98 JTF_VARCHAR2_TABLE_300
    , a99 JTF_VARCHAR2_TABLE_300
    , a100 JTF_VARCHAR2_TABLE_300
    , a101 JTF_VARCHAR2_TABLE_300
    , a102 JTF_VARCHAR2_TABLE_300
    , a103 JTF_VARCHAR2_TABLE_300
    , a104 JTF_VARCHAR2_TABLE_300
    , a105 JTF_VARCHAR2_TABLE_300
    , a106 JTF_VARCHAR2_TABLE_300
    , a107 JTF_VARCHAR2_TABLE_300
    , a108 JTF_VARCHAR2_TABLE_300
    , a109 JTF_VARCHAR2_TABLE_300
    , a110 JTF_VARCHAR2_TABLE_300
    , a111 JTF_VARCHAR2_TABLE_300
    , a112 JTF_VARCHAR2_TABLE_300
    , a113 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p1(t cn_un_proc_pub.adj_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_VARCHAR2_TABLE_300
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
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
    , a54 out nocopy JTF_VARCHAR2_TABLE_300
    , a55 out nocopy JTF_VARCHAR2_TABLE_300
    , a56 out nocopy JTF_VARCHAR2_TABLE_300
    , a57 out nocopy JTF_VARCHAR2_TABLE_300
    , a58 out nocopy JTF_VARCHAR2_TABLE_300
    , a59 out nocopy JTF_VARCHAR2_TABLE_300
    , a60 out nocopy JTF_VARCHAR2_TABLE_300
    , a61 out nocopy JTF_VARCHAR2_TABLE_300
    , a62 out nocopy JTF_VARCHAR2_TABLE_300
    , a63 out nocopy JTF_VARCHAR2_TABLE_300
    , a64 out nocopy JTF_VARCHAR2_TABLE_300
    , a65 out nocopy JTF_VARCHAR2_TABLE_300
    , a66 out nocopy JTF_VARCHAR2_TABLE_300
    , a67 out nocopy JTF_VARCHAR2_TABLE_300
    , a68 out nocopy JTF_VARCHAR2_TABLE_300
    , a69 out nocopy JTF_VARCHAR2_TABLE_300
    , a70 out nocopy JTF_VARCHAR2_TABLE_300
    , a71 out nocopy JTF_VARCHAR2_TABLE_300
    , a72 out nocopy JTF_VARCHAR2_TABLE_300
    , a73 out nocopy JTF_VARCHAR2_TABLE_300
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_VARCHAR2_TABLE_300
    , a76 out nocopy JTF_VARCHAR2_TABLE_300
    , a77 out nocopy JTF_VARCHAR2_TABLE_300
    , a78 out nocopy JTF_VARCHAR2_TABLE_300
    , a79 out nocopy JTF_VARCHAR2_TABLE_300
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_300
    , a83 out nocopy JTF_VARCHAR2_TABLE_300
    , a84 out nocopy JTF_VARCHAR2_TABLE_300
    , a85 out nocopy JTF_VARCHAR2_TABLE_300
    , a86 out nocopy JTF_VARCHAR2_TABLE_300
    , a87 out nocopy JTF_VARCHAR2_TABLE_300
    , a88 out nocopy JTF_VARCHAR2_TABLE_300
    , a89 out nocopy JTF_VARCHAR2_TABLE_300
    , a90 out nocopy JTF_VARCHAR2_TABLE_300
    , a91 out nocopy JTF_VARCHAR2_TABLE_300
    , a92 out nocopy JTF_VARCHAR2_TABLE_300
    , a93 out nocopy JTF_VARCHAR2_TABLE_300
    , a94 out nocopy JTF_VARCHAR2_TABLE_300
    , a95 out nocopy JTF_VARCHAR2_TABLE_300
    , a96 out nocopy JTF_VARCHAR2_TABLE_300
    , a97 out nocopy JTF_VARCHAR2_TABLE_300
    , a98 out nocopy JTF_VARCHAR2_TABLE_300
    , a99 out nocopy JTF_VARCHAR2_TABLE_300
    , a100 out nocopy JTF_VARCHAR2_TABLE_300
    , a101 out nocopy JTF_VARCHAR2_TABLE_300
    , a102 out nocopy JTF_VARCHAR2_TABLE_300
    , a103 out nocopy JTF_VARCHAR2_TABLE_300
    , a104 out nocopy JTF_VARCHAR2_TABLE_300
    , a105 out nocopy JTF_VARCHAR2_TABLE_300
    , a106 out nocopy JTF_VARCHAR2_TABLE_300
    , a107 out nocopy JTF_VARCHAR2_TABLE_300
    , a108 out nocopy JTF_VARCHAR2_TABLE_300
    , a109 out nocopy JTF_VARCHAR2_TABLE_300
    , a110 out nocopy JTF_VARCHAR2_TABLE_300
    , a111 out nocopy JTF_VARCHAR2_TABLE_300
    , a112 out nocopy JTF_VARCHAR2_TABLE_300
    , a113 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure get_adj(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_loading_status out nocopy  VARCHAR2
    , p_salesrep_id  NUMBER
    , p_pr_date_from  date
    , p_pr_date_to  date
    , p_invoice_num  VARCHAR2
    , p_order_num  NUMBER
    , p_adjust_status  VARCHAR2
    , p_adjust_date  date
    , p_trx_type  VARCHAR2
    , p_calc_status  VARCHAR2
    , p_load_status  VARCHAR2
    , p_date_pattern  date
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p20_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a1 out nocopy JTF_DATE_TABLE
    , p20_a2 out nocopy JTF_NUMBER_TABLE
    , p20_a3 out nocopy JTF_DATE_TABLE
    , p20_a4 out nocopy JTF_DATE_TABLE
    , p20_a5 out nocopy JTF_DATE_TABLE
    , p20_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p20_a11 out nocopy JTF_NUMBER_TABLE
    , p20_a12 out nocopy JTF_NUMBER_TABLE
    , p20_a13 out nocopy JTF_DATE_TABLE
    , p20_a14 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a15 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a16 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a17 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a18 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a19 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a20 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a22 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a23 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a24 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a25 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a27 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a29 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a30 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a31 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a32 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a33 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a34 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a35 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a36 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a38 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a39 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a40 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a41 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a42 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a43 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a44 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a45 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a46 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a47 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a48 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a49 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a50 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a51 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a52 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a53 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a54 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a55 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a56 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a57 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a58 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a59 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a60 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a61 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a62 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a63 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a64 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a65 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a66 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a67 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a68 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a69 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a70 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a71 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a72 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a73 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a74 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a75 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a76 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a77 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a78 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a79 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a80 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a81 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a82 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a83 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a84 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a85 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a86 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a87 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a88 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a89 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a90 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a91 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a92 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a93 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a94 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a95 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a96 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a97 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a98 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a99 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a100 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a101 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a102 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a103 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a104 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a105 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a106 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a107 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a108 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a109 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a110 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a111 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a112 out nocopy JTF_VARCHAR2_TABLE_300
    , p20_a113 out nocopy JTF_VARCHAR2_TABLE_300
    , x_adj_count out nocopy  NUMBER
    , x_total_sales_credit out nocopy  NUMBER
    , x_total_commission out nocopy  NUMBER
  );
end cn_un_proc_pub_w;

 

/
