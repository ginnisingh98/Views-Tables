--------------------------------------------------------
--  DDL for Package OKL_QA_CHECK_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QA_CHECK_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLEQAKS.pls 120.0 2007/05/17 16:43:51 hariven noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_qa_check_pub.msg_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p1(t okl_qa_check_pub.msg_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    );

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
    , p_call_mode  VARCHAR2
  );
end okl_qa_check_pub_w;

/
