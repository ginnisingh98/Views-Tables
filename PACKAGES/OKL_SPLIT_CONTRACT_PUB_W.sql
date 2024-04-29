--------------------------------------------------------
--  DDL for Package OKL_SPLIT_CONTRACT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SPLIT_CONTRACT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUSKHS.pls 115.3 2004/01/24 00:57:42 rravikir noship $ */
  procedure create_split_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_old_contract_number  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_200
    , p6_a2 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_NUMBER_TABLE
  );
end okl_split_contract_pub_w;

 

/
