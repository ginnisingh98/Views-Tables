--------------------------------------------------------
--  DDL for Package CSE_WFM_TRX_GRP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_WFM_TRX_GRP_PVT_W" AUTHID CURRENT_USER as
  /* $Header: CSEWBWWS.pls 120.1 2008/01/16 21:32:35 devijay ship $ */
  procedure wfm_transactions(p_api_version  NUMBER
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_transaction_type  VARCHAR2
    , p5_a0 in out nocopy JTF_NUMBER_TABLE
    , p5_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 in out nocopy JTF_NUMBER_TABLE
    , p5_a5 in out nocopy JTF_NUMBER_TABLE
    , p5_a6 in out nocopy JTF_NUMBER_TABLE
    , p5_a7 in out nocopy JTF_NUMBER_TABLE
    , p5_a8 in out nocopy JTF_NUMBER_TABLE
    , p5_a9 in out nocopy JTF_NUMBER_TABLE
    , p5_a10 in out nocopy JTF_NUMBER_TABLE
    , p5_a11 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a12 in out nocopy JTF_DATE_TABLE
    , p5_a13 in out nocopy JTF_NUMBER_TABLE
    , p5_a14 in out nocopy JTF_DATE_TABLE
    , p5_a15 in out nocopy JTF_NUMBER_TABLE
    , p5_a16 in out nocopy JTF_DATE_TABLE
    , p5_a17 in out nocopy JTF_NUMBER_TABLE
    , p5_a18 in out nocopy JTF_NUMBER_TABLE
    , p5_a19 in out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a20 in out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end cse_wfm_trx_grp_pvt_w;

/
