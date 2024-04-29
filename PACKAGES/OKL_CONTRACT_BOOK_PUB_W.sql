--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_BOOK_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_BOOK_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUBKGS.pls 120.0 2008/02/14 09:33:15 veramach noship $ */
  procedure execute_qa_check_list(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_qcl_id  NUMBER
    , p_chr_id  NUMBER
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure validate_contract(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_qcl_id  NUMBER
    , p_chr_id  NUMBER
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_VARCHAR2_TABLE_2000
  );
end okl_contract_book_pub_w;

/
