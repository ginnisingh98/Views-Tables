--------------------------------------------------------
--  DDL for Package OKC_K_ARTICLES_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ARTICLES_GRP_W" AUTHID CURRENT_USER as
  /* $Header: OKCWVCATS.pls 120.0.12010000.1 2013/11/29 13:09:57 serukull noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy okc_k_articles_grp.id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t okc_k_articles_grp.id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure delete_articles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_super_user_yn  VARCHAR2
    , p_amendment_description  VARCHAR2
    , p_print_text_yn  VARCHAR2
    , p_id_tbl JTF_NUMBER_TABLE
    , p_object_version_number JTF_NUMBER_TABLE
    , p_mandatory_clause_delete  VARCHAR2
    , p_lock_terms_yn  VARCHAR2
  );
end okc_k_articles_grp_w;

/
