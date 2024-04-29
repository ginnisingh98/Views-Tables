--------------------------------------------------------
--  DDL for Package OKL_CASH_APPLN_RULE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_APPLN_RULE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUCSLS.pls 120.2 2005/10/30 03:48:49 appldev noship $ */
  procedure maint_cash_appln_rule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_VARCHAR2_TABLE_200
    , p2_a3 JTF_VARCHAR2_TABLE_2000
    , p2_a4 JTF_DATE_TABLE
    , p2_a5 JTF_DATE_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_NUMBER_TABLE
    , p2_a8 JTF_NUMBER_TABLE
    , p2_a9 JTF_VARCHAR2_TABLE_100
    , p2_a10 JTF_VARCHAR2_TABLE_100
    , p2_a11 JTF_VARCHAR2_TABLE_100
    , p2_a12 JTF_VARCHAR2_TABLE_100
    , p2_a13 JTF_VARCHAR2_TABLE_100
    , p2_a14 JTF_VARCHAR2_TABLE_500
    , p2_a15 JTF_VARCHAR2_TABLE_500
    , p2_a16 JTF_VARCHAR2_TABLE_500
    , p2_a17 JTF_VARCHAR2_TABLE_500
    , p2_a18 JTF_VARCHAR2_TABLE_500
    , p2_a19 JTF_VARCHAR2_TABLE_500
    , p2_a20 JTF_VARCHAR2_TABLE_500
    , p2_a21 JTF_VARCHAR2_TABLE_500
    , p2_a22 JTF_VARCHAR2_TABLE_500
    , p2_a23 JTF_VARCHAR2_TABLE_500
    , p2_a24 JTF_VARCHAR2_TABLE_500
    , p2_a25 JTF_VARCHAR2_TABLE_500
    , p2_a26 JTF_VARCHAR2_TABLE_500
    , p2_a27 JTF_VARCHAR2_TABLE_500
    , p2_a28 JTF_VARCHAR2_TABLE_500
    , p2_a29 JTF_NUMBER_TABLE
    , p2_a30 JTF_NUMBER_TABLE
    , p2_a31 JTF_DATE_TABLE
    , p2_a32 JTF_NUMBER_TABLE
    , p2_a33 JTF_DATE_TABLE
    , p2_a34 JTF_NUMBER_TABLE
    , p2_a35 JTF_NUMBER_TABLE
    , p2_a36 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_NUMBER_TABLE
    , p3_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a4 out nocopy JTF_DATE_TABLE
    , p3_a5 out nocopy JTF_DATE_TABLE
    , p3_a6 out nocopy JTF_NUMBER_TABLE
    , p3_a7 out nocopy JTF_NUMBER_TABLE
    , p3_a8 out nocopy JTF_NUMBER_TABLE
    , p3_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a18 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p3_a29 out nocopy JTF_NUMBER_TABLE
    , p3_a30 out nocopy JTF_NUMBER_TABLE
    , p3_a31 out nocopy JTF_DATE_TABLE
    , p3_a32 out nocopy JTF_NUMBER_TABLE
    , p3_a33 out nocopy JTF_DATE_TABLE
    , p3_a34 out nocopy JTF_NUMBER_TABLE
    , p3_a35 out nocopy JTF_NUMBER_TABLE
    , p3_a36 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okl_cash_appln_rule_pub_w;

 

/
