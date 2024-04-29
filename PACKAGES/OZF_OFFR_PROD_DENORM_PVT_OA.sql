--------------------------------------------------------
--  DDL for Package OZF_OFFR_PROD_DENORM_PVT_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFR_PROD_DENORM_PVT_OA" AUTHID CURRENT_USER as
  /* $Header: ozfaodms.pls 120.0 2005/08/31 09:43 gramanat noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ozf_offr_elig_prod_denorm_pvt.num_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t ozf_offr_elig_prod_denorm_pvt.num_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p1(t out nocopy ozf_offr_elig_prod_denorm_pvt.char_tbl_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p1(t ozf_offr_elig_prod_denorm_pvt.char_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure find_party_elig(p_offers_tbl JTF_NUMBER_TABLE
    , p_party_id  NUMBER
    , p_cust_acct_id  NUMBER
    , p_cust_site_id  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_offers_tbl out nocopy JTF_NUMBER_TABLE
  );
  procedure find_product_elig(p_products_tbl JTF_NUMBER_TABLE
    , p_party_id  NUMBER
    , p_cust_acct_id  NUMBER
    , p_cust_site_id  NUMBER
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_offers_tbl out nocopy JTF_NUMBER_TABLE
  );
end ozf_offr_prod_denorm_pvt_oa;

 

/
