--------------------------------------------------------
--  DDL for Package OKL_FORMULAEVALUATE_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FORMULAEVALUATE_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUEVAS.pls 120.1 2005/07/12 07:06:03 asawanka noship $ */
  procedure eva_getparametervalues(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_fma_id  NUMBER
    , p_contract_id  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p_line_id  NUMBER
  );
  procedure eva_getfunctionvalue(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_fma_id  NUMBER
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_200
    , p8_a2 JTF_NUMBER_TABLE
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_800
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_NUMBER_TABLE
  );
end okl_formulaevaluate_pub_w;

 

/
