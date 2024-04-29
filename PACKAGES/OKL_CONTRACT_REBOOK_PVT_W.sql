--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_REBOOK_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_REBOOK_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLERBKS.pls 120.2 2005/12/06 23:41:05 rpillay noship $ */
  procedure create_txn_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_from_chr_id  NUMBER
    , p_rebook_reason_code  VARCHAR2
    , p_rebook_description  VARCHAR2
    , p_trx_date  date
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
    , x_rebook_chr_id out nocopy  NUMBER
  );
end okl_contract_rebook_pvt_w;

 

/
