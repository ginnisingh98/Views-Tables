--------------------------------------------------------
--  DDL for Package OKL_EXECUTE_FORMULA_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_EXECUTE_FORMULA_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUFMLS.pls 120.1 2005/07/12 07:06:37 asawanka noship $ */
  procedure execute(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_formula_name  VARCHAR2
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_200
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , x_value out nocopy  NUMBER
  );
  procedure execute(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_formula_name  VARCHAR2
    , p_contract_id  NUMBER
    , p_line_id  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_200
    , p8_a1 JTF_VARCHAR2_TABLE_300
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_800
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , x_value out nocopy  NUMBER
  );
end okl_execute_formula_pub_w;

 

/
