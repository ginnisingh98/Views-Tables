--------------------------------------------------------
--  DDL for Package OKL_JTOT_CONTACT_EXTRACT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_JTOT_CONTACT_EXTRACT_PUB_W" AUTHID CURRENT_USER as
  /* $Header: OKLUJCXS.pls 120.1 2005/09/30 21:05:14 cklee noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_jtot_contact_extract_pub.party_tab_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t okl_jtot_contact_extract_pub.party_tab_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    );

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
end okl_jtot_contact_extract_pub_w;

 

/
