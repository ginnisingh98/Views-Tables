--------------------------------------------------------
--  DDL for Package OKL_POPULATE_PRCENG_RST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_POPULATE_PRCENG_RST_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUPRSS.pls 120.1 2005/05/30 12:32:18 kthiruva noship $ */
  procedure rosetta_table_copy_in_p19(t out nocopy okl_populate_prceng_rst_pub.strm_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p19(t okl_populate_prceng_rst_pub.strm_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p21(t out nocopy okl_populate_prceng_rst_pub.strm_excp_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_1000
    );
  procedure rosetta_table_copy_out_p21(t okl_populate_prceng_rst_pub.strm_excp_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_1000
    );

  procedure populate_sif_ret_strms(x_return_status out nocopy  VARCHAR2
    , p_index_number  NUMBER
    , p2_a0 JTF_VARCHAR2_TABLE_200
    , p2_a1 JTF_VARCHAR2_TABLE_200
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p_sir_id  NUMBER
  );
  procedure populate_sif_ret_errors(x_return_status out nocopy  VARCHAR2
    , x_id out nocopy  NUMBER
    , p_sir_id  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_300
    , p3_a2 JTF_VARCHAR2_TABLE_1000
    , p_tag_attribute_name  VARCHAR2
    , p_tag_attribute_value  VARCHAR2
    , p_description  VARCHAR2
  );
end okl_populate_prceng_rst_pub_w;

 

/
