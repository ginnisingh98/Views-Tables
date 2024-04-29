--------------------------------------------------------
--  DDL for Package OKL_RELEASE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RELEASE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: OKLEREKS.pls 120.4 2005/10/30 04:06:45 appldev noship $ */
  procedure create_release_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_release_reason_code  VARCHAR2
    , p_release_description  VARCHAR2
    , p_trx_date  date
    , p_source_trx_id  NUMBER
    , p_source_trx_type  VARCHAR2
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
    , x_release_chr_id out nocopy  NUMBER
  );
end okl_release_pvt_w;

 

/
