--------------------------------------------------------
--  DDL for Package OKL_TRANSACTION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRANSACTION_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLETXNS.pls 120.1 2005/07/12 09:12:02 dkagrawa noship $ */
  procedure rosetta_table_copy_in_p11(t out nocopy okl_transaction_pvt.rev_tbl_type, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p11(t okl_transaction_pvt.rev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure create_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_new_chr_id  NUMBER
    , p_reason_code  VARCHAR2
    , p_description  VARCHAR2
    , p_trx_date  date
    , p_trx_type  VARCHAR2
    , p11_a0 out nocopy  NUMBER
    , p11_a1 out nocopy  NUMBER
    , p11_a2 out nocopy  VARCHAR2
    , p11_a3 out nocopy  VARCHAR2
    , p11_a4 out nocopy  VARCHAR2
    , p11_a5 out nocopy  VARCHAR2
    , p11_a6 out nocopy  NUMBER
    , p11_a7 out nocopy  NUMBER
    , p11_a8 out nocopy  NUMBER
    , p11_a9 out nocopy  NUMBER
    , p11_a10 out nocopy  NUMBER
    , p11_a11 out nocopy  NUMBER
    , p11_a12 out nocopy  VARCHAR2
    , p11_a13 out nocopy  VARCHAR2
    , p11_a14 out nocopy  DATE
    , p11_a15 out nocopy  VARCHAR2
    , p11_a16 out nocopy  VARCHAR2
    , p11_a17 out nocopy  NUMBER
    , p11_a18 out nocopy  VARCHAR2
    , p11_a19 out nocopy  VARCHAR2
    , p11_a20 out nocopy  VARCHAR2
    , p11_a21 out nocopy  VARCHAR2
    , p11_a22 out nocopy  VARCHAR2
    , p11_a23 out nocopy  VARCHAR2
    , p11_a24 out nocopy  VARCHAR2
    , p11_a25 out nocopy  VARCHAR2
    , p11_a26 out nocopy  VARCHAR2
    , p11_a27 out nocopy  VARCHAR2
    , p11_a28 out nocopy  VARCHAR2
    , p11_a29 out nocopy  VARCHAR2
    , p11_a30 out nocopy  VARCHAR2
    , p11_a31 out nocopy  VARCHAR2
    , p11_a32 out nocopy  VARCHAR2
    , p11_a33 out nocopy  VARCHAR2
    , p11_a34 out nocopy  VARCHAR2
    , p11_a35 out nocopy  VARCHAR2
    , p11_a36 out nocopy  VARCHAR2
    , p11_a37 out nocopy  NUMBER
    , p11_a38 out nocopy  VARCHAR2
    , p11_a39 out nocopy  NUMBER
    , p11_a40 out nocopy  VARCHAR2
    , p11_a41 out nocopy  VARCHAR2
    , p11_a42 out nocopy  NUMBER
    , p11_a43 out nocopy  NUMBER
    , p11_a44 out nocopy  NUMBER
    , p11_a45 out nocopy  NUMBER
    , p11_a46 out nocopy  NUMBER
    , p11_a47 out nocopy  NUMBER
    , p11_a48 out nocopy  DATE
    , p11_a49 out nocopy  NUMBER
    , p11_a50 out nocopy  DATE
    , p11_a51 out nocopy  NUMBER
    , p11_a52 out nocopy  DATE
    , p11_a53 out nocopy  NUMBER
    , p11_a54 out nocopy  NUMBER
    , p11_a55 out nocopy  VARCHAR2
    , p11_a56 out nocopy  NUMBER
    , p11_a57 out nocopy  VARCHAR2
    , p11_a58 out nocopy  DATE
    , p11_a59 out nocopy  VARCHAR2
    , p11_a60 out nocopy  VARCHAR2
    , p11_a61 out nocopy  VARCHAR2
    , p11_a62 out nocopy  VARCHAR2
    , p11_a63 out nocopy  VARCHAR2
    , p11_a64 out nocopy  VARCHAR2
    , p11_a65 out nocopy  VARCHAR2
    , p11_a66 out nocopy  VARCHAR2
    , p11_a67 out nocopy  VARCHAR2
    , p11_a68 out nocopy  VARCHAR2
    , p11_a69 out nocopy  VARCHAR2
    , p11_a70 out nocopy  VARCHAR2
    , p11_a71 out nocopy  VARCHAR2
    , p11_a72 out nocopy  VARCHAR2
    , p11_a73 out nocopy  VARCHAR2
    , p11_a74 out nocopy  VARCHAR2
    , p11_a75 out nocopy  VARCHAR2
    , p11_a76 out nocopy  VARCHAR2
    , p11_a77 out nocopy  NUMBER
    , p11_a78 out nocopy  DATE
    , p11_a79 out nocopy  NUMBER
    , p11_a80 out nocopy  NUMBER
    , p11_a81 out nocopy  VARCHAR2
    , p11_a82 out nocopy  DATE
  );
  procedure update_trx_status(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_status  VARCHAR2
    , p7_a0 out nocopy  NUMBER
    , p7_a1 out nocopy  NUMBER
    , p7_a2 out nocopy  VARCHAR2
    , p7_a3 out nocopy  VARCHAR2
    , p7_a4 out nocopy  VARCHAR2
    , p7_a5 out nocopy  VARCHAR2
    , p7_a6 out nocopy  NUMBER
    , p7_a7 out nocopy  NUMBER
    , p7_a8 out nocopy  NUMBER
    , p7_a9 out nocopy  NUMBER
    , p7_a10 out nocopy  NUMBER
    , p7_a11 out nocopy  NUMBER
    , p7_a12 out nocopy  VARCHAR2
    , p7_a13 out nocopy  VARCHAR2
    , p7_a14 out nocopy  DATE
    , p7_a15 out nocopy  VARCHAR2
    , p7_a16 out nocopy  VARCHAR2
    , p7_a17 out nocopy  NUMBER
    , p7_a18 out nocopy  VARCHAR2
    , p7_a19 out nocopy  VARCHAR2
    , p7_a20 out nocopy  VARCHAR2
    , p7_a21 out nocopy  VARCHAR2
    , p7_a22 out nocopy  VARCHAR2
    , p7_a23 out nocopy  VARCHAR2
    , p7_a24 out nocopy  VARCHAR2
    , p7_a25 out nocopy  VARCHAR2
    , p7_a26 out nocopy  VARCHAR2
    , p7_a27 out nocopy  VARCHAR2
    , p7_a28 out nocopy  VARCHAR2
    , p7_a29 out nocopy  VARCHAR2
    , p7_a30 out nocopy  VARCHAR2
    , p7_a31 out nocopy  VARCHAR2
    , p7_a32 out nocopy  VARCHAR2
    , p7_a33 out nocopy  VARCHAR2
    , p7_a34 out nocopy  VARCHAR2
    , p7_a35 out nocopy  VARCHAR2
    , p7_a36 out nocopy  VARCHAR2
    , p7_a37 out nocopy  NUMBER
    , p7_a38 out nocopy  VARCHAR2
    , p7_a39 out nocopy  NUMBER
    , p7_a40 out nocopy  VARCHAR2
    , p7_a41 out nocopy  VARCHAR2
    , p7_a42 out nocopy  NUMBER
    , p7_a43 out nocopy  NUMBER
    , p7_a44 out nocopy  NUMBER
    , p7_a45 out nocopy  NUMBER
    , p7_a46 out nocopy  NUMBER
    , p7_a47 out nocopy  NUMBER
    , p7_a48 out nocopy  DATE
    , p7_a49 out nocopy  NUMBER
    , p7_a50 out nocopy  DATE
    , p7_a51 out nocopy  NUMBER
    , p7_a52 out nocopy  DATE
    , p7_a53 out nocopy  NUMBER
    , p7_a54 out nocopy  NUMBER
    , p7_a55 out nocopy  VARCHAR2
    , p7_a56 out nocopy  NUMBER
    , p7_a57 out nocopy  VARCHAR2
    , p7_a58 out nocopy  DATE
    , p7_a59 out nocopy  VARCHAR2
    , p7_a60 out nocopy  VARCHAR2
    , p7_a61 out nocopy  VARCHAR2
    , p7_a62 out nocopy  VARCHAR2
    , p7_a63 out nocopy  VARCHAR2
    , p7_a64 out nocopy  VARCHAR2
    , p7_a65 out nocopy  VARCHAR2
    , p7_a66 out nocopy  VARCHAR2
    , p7_a67 out nocopy  VARCHAR2
    , p7_a68 out nocopy  VARCHAR2
    , p7_a69 out nocopy  VARCHAR2
    , p7_a70 out nocopy  VARCHAR2
    , p7_a71 out nocopy  VARCHAR2
    , p7_a72 out nocopy  VARCHAR2
    , p7_a73 out nocopy  VARCHAR2
    , p7_a74 out nocopy  VARCHAR2
    , p7_a75 out nocopy  VARCHAR2
    , p7_a76 out nocopy  VARCHAR2
    , p7_a77 out nocopy  NUMBER
    , p7_a78 out nocopy  DATE
    , p7_a79 out nocopy  NUMBER
    , p7_a80 out nocopy  NUMBER
    , p7_a81 out nocopy  VARCHAR2
    , p7_a82 out nocopy  DATE
  );
  procedure abandon_revisions(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p_contract_status  VARCHAR2
    , p_tsu_code  VARCHAR2
  );
  procedure check_contract_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_trx_date  date
  );
  procedure check_contract_securitized(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_cle_id  NUMBER
    , p_stream_type_class  VARCHAR2
    , p_trx_date  date
  );
  procedure create_service_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lease_id  NUMBER
    , p_service_id  NUMBER
    , p_description  VARCHAR2
    , p_trx_date  date
    , p_status  VARCHAR2
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  VARCHAR2
    , p10_a3 out nocopy  VARCHAR2
    , p10_a4 out nocopy  VARCHAR2
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  NUMBER
    , p10_a7 out nocopy  NUMBER
    , p10_a8 out nocopy  NUMBER
    , p10_a9 out nocopy  NUMBER
    , p10_a10 out nocopy  NUMBER
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  VARCHAR2
    , p10_a14 out nocopy  DATE
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  VARCHAR2
    , p10_a17 out nocopy  NUMBER
    , p10_a18 out nocopy  VARCHAR2
    , p10_a19 out nocopy  VARCHAR2
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  VARCHAR2
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  VARCHAR2
    , p10_a34 out nocopy  VARCHAR2
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  VARCHAR2
    , p10_a37 out nocopy  NUMBER
    , p10_a38 out nocopy  VARCHAR2
    , p10_a39 out nocopy  NUMBER
    , p10_a40 out nocopy  VARCHAR2
    , p10_a41 out nocopy  VARCHAR2
    , p10_a42 out nocopy  NUMBER
    , p10_a43 out nocopy  NUMBER
    , p10_a44 out nocopy  NUMBER
    , p10_a45 out nocopy  NUMBER
    , p10_a46 out nocopy  NUMBER
    , p10_a47 out nocopy  NUMBER
    , p10_a48 out nocopy  DATE
    , p10_a49 out nocopy  NUMBER
    , p10_a50 out nocopy  DATE
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  DATE
    , p10_a53 out nocopy  NUMBER
    , p10_a54 out nocopy  NUMBER
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  NUMBER
    , p10_a57 out nocopy  VARCHAR2
    , p10_a58 out nocopy  DATE
    , p10_a59 out nocopy  VARCHAR2
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p10_a66 out nocopy  VARCHAR2
    , p10_a67 out nocopy  VARCHAR2
    , p10_a68 out nocopy  VARCHAR2
    , p10_a69 out nocopy  VARCHAR2
    , p10_a70 out nocopy  VARCHAR2
    , p10_a71 out nocopy  VARCHAR2
    , p10_a72 out nocopy  VARCHAR2
    , p10_a73 out nocopy  VARCHAR2
    , p10_a74 out nocopy  VARCHAR2
    , p10_a75 out nocopy  VARCHAR2
    , p10_a76 out nocopy  VARCHAR2
    , p10_a77 out nocopy  NUMBER
    , p10_a78 out nocopy  DATE
    , p10_a79 out nocopy  NUMBER
    , p10_a80 out nocopy  NUMBER
    , p10_a81 out nocopy  VARCHAR2
    , p10_a82 out nocopy  DATE
  );
  procedure create_ppd_transaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_trx_date  date
    , p_trx_type  VARCHAR2
    , p_reason_code  VARCHAR2
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  VARCHAR2
    , p9_a4 out nocopy  VARCHAR2
    , p9_a5 out nocopy  VARCHAR2
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  NUMBER
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  NUMBER
    , p9_a10 out nocopy  NUMBER
    , p9_a11 out nocopy  NUMBER
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  DATE
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  NUMBER
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  VARCHAR2
    , p9_a26 out nocopy  VARCHAR2
    , p9_a27 out nocopy  VARCHAR2
    , p9_a28 out nocopy  VARCHAR2
    , p9_a29 out nocopy  VARCHAR2
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
    , p9_a32 out nocopy  VARCHAR2
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  VARCHAR2
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  VARCHAR2
    , p9_a37 out nocopy  NUMBER
    , p9_a38 out nocopy  VARCHAR2
    , p9_a39 out nocopy  NUMBER
    , p9_a40 out nocopy  VARCHAR2
    , p9_a41 out nocopy  VARCHAR2
    , p9_a42 out nocopy  NUMBER
    , p9_a43 out nocopy  NUMBER
    , p9_a44 out nocopy  NUMBER
    , p9_a45 out nocopy  NUMBER
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  NUMBER
    , p9_a48 out nocopy  DATE
    , p9_a49 out nocopy  NUMBER
    , p9_a50 out nocopy  DATE
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  DATE
    , p9_a53 out nocopy  NUMBER
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  VARCHAR2
    , p9_a56 out nocopy  NUMBER
    , p9_a57 out nocopy  VARCHAR2
    , p9_a58 out nocopy  DATE
    , p9_a59 out nocopy  VARCHAR2
    , p9_a60 out nocopy  VARCHAR2
    , p9_a61 out nocopy  VARCHAR2
    , p9_a62 out nocopy  VARCHAR2
    , p9_a63 out nocopy  VARCHAR2
    , p9_a64 out nocopy  VARCHAR2
    , p9_a65 out nocopy  VARCHAR2
    , p9_a66 out nocopy  VARCHAR2
    , p9_a67 out nocopy  VARCHAR2
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  VARCHAR2
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  VARCHAR2
    , p9_a77 out nocopy  NUMBER
    , p9_a78 out nocopy  DATE
    , p9_a79 out nocopy  NUMBER
    , p9_a80 out nocopy  NUMBER
    , p9_a81 out nocopy  VARCHAR2
    , p9_a82 out nocopy  DATE
  );
end okl_transaction_pvt_w;

 

/
