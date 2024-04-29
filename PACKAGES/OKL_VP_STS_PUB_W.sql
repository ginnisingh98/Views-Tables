--------------------------------------------------------
--  DDL for Package OKL_VP_STS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_STS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUSSCS.pls 120.2 2005/08/04 03:07:50 manumanu noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_vp_sts_pub.vp_sts_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t okl_vp_sts_pub.vp_sts_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure get_listof_new_statuses(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_ste_code  VARCHAR2
    , p_sts_code  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
  );
end okl_vp_sts_pub_w;

 

/
