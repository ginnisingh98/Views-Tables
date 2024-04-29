--------------------------------------------------------
--  DDL for Package OKC_TERMS_MULTIREC_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_MULTIREC_GRP_W" AUTHID CURRENT_USER as
  /* $Header: OKCWMULS.pls 120.2.12010000.2 2011/12/09 13:58:09 serukull ship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy okc_terms_multirec_grp.art_var_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p5(t okc_terms_multirec_grp.art_var_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p6(t out nocopy okc_terms_multirec_grp.kart_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p6(t okc_terms_multirec_grp.kart_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p7(t out nocopy okc_terms_multirec_grp.structure_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p7(t okc_terms_multirec_grp.structure_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p8(t out nocopy okc_terms_multirec_grp.article_id_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p8(t okc_terms_multirec_grp.article_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p9(t out nocopy okc_terms_multirec_grp.article_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p9(t okc_terms_multirec_grp.article_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p10(t out nocopy okc_terms_multirec_grp.organize_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p10(t okc_terms_multirec_grp.organize_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p11(t out nocopy okc_terms_multirec_grp.merge_review_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE, a2 JTF_NUMBER_TABLE
    );


  procedure create_article(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_mode  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p_ref_type  VARCHAR2
    , p_ref_id  NUMBER
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_VARCHAR2_TABLE_2000
    , p11_a4 JTF_VARCHAR2_TABLE_100
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure update_article_variable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_2000
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lock_terms_yn   IN VARCHAR2 := 'N'

  );
  procedure update_structure(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure sync_doc_with_expert(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_article_id_tbl JTF_NUMBER_TABLE
    , p_mode  VARCHAR2
    , x_articles_dropped out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lock_terms_yn   IN VARCHAR2 := 'N'
  );
  procedure refresh_articles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p_mode  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lock_terms_yn   IN VARCHAR2 := 'N'

  );
  procedure organize_layout(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p_ref_point  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_to_object_type  VARCHAR2
    , p_to_object_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );


  procedure merge_review_clauses(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end okc_terms_multirec_grp_w;

/
