--------------------------------------------------------
--  DDL for Package OKL_VP_JTF_PARTY_NAME_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_VP_JTF_PARTY_NAME_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUCTSS.pls 115.7 2003/10/02 23:18:34 manumanu noship $ */
  procedure get_party(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  VARCHAR2
    , p_cle_id  VARCHAR2
    , p_role_code  VARCHAR2
    , p_intent  VARCHAR2
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_300
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_100
  );
end okl_vp_jtf_party_name_pub_w;

 

/
