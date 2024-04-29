--------------------------------------------------------
--  DDL for Package OKL_ETH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ETH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSETHS.pls 120.2 2005/11/29 14:21:30 viselvar noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_ethv_rec IS RECORD (
    end_of_term_id        NUMBER,
    object_version_number NUMBER,
    end_of_term_name      okl_fe_eo_terms_v.end_of_term_name%TYPE,
    end_of_term_desc      okl_fe_eo_terms_v.end_of_term_desc%TYPE,
    org_id                NUMBER,
    currency_code         okl_fe_eo_terms_v.currency_code%TYPE,
    eot_type_code         okl_fe_eo_terms_v.eot_type_code%TYPE,
    product_id            NUMBER,
    category_type_code    okl_fe_eo_terms_v.category_type_code%TYPE,
    orig_end_of_term_id   NUMBER,
    sts_code              okl_fe_eo_terms_v.sts_code%TYPE,
    effective_from_date   okl_fe_eo_terms_v.effective_from_date%TYPE,
    effective_to_date     okl_fe_eo_terms_v.effective_to_date%TYPE,
    attribute_category    okl_fe_eo_terms_v.attribute_category%TYPE,
    attribute1            okl_fe_eo_terms_v.attribute1%TYPE,
    attribute2            okl_fe_eo_terms_v.attribute2%TYPE,
    attribute3            okl_fe_eo_terms_v.attribute3%TYPE,
    attribute4            okl_fe_eo_terms_v.attribute4%TYPE,
    attribute5            okl_fe_eo_terms_v.attribute5%TYPE,
    attribute6            okl_fe_eo_terms_v.attribute6%TYPE,
    attribute7            okl_fe_eo_terms_v.attribute7%TYPE,
    attribute8            okl_fe_eo_terms_v.attribute8%TYPE,
    attribute9            okl_fe_eo_terms_v.attribute9%TYPE,
    attribute10           okl_fe_eo_terms_v.attribute10%TYPE,
    attribute11           okl_fe_eo_terms_v.attribute11%TYPE,
    attribute12           okl_fe_eo_terms_v.attribute12%TYPE,
    attribute13           okl_fe_eo_terms_v.attribute13%TYPE,
    attribute14           okl_fe_eo_terms_v.attribute14%TYPE,
    attribute15           okl_fe_eo_terms_v.attribute15%TYPE,
    created_by            NUMBER,
    creation_date         okl_fe_eo_terms_v.creation_date%TYPE,
    last_updated_by       NUMBER,
    last_update_date      okl_fe_eo_terms_v.last_update_date%TYPE,
    last_update_login     NUMBER
  );

  TYPE okl_ethv_tbl IS TABLE OF okl_ethv_rec INDEX BY BINARY_INTEGER;

  TYPE okl_ethb_rec IS RECORD (
    end_of_term_id        NUMBER,
    object_version_number NUMBER,
    end_of_term_name      okl_fe_eo_terms_all_b.end_of_term_name%TYPE,
    org_id                NUMBER,
    currency_code         okl_fe_eo_terms_all_b.currency_code%TYPE,
    eot_type_code         okl_fe_eo_terms_all_b.eot_type_code%TYPE,
    product_id            NUMBER,
    category_type_code    okl_fe_eo_terms_all_b.category_type_code%TYPE,
    orig_end_of_term_id   NUMBER,
    sts_code              okl_fe_eo_terms_all_b.sts_code%TYPE,
    effective_from_date   okl_fe_eo_terms_all_b.effective_from_date%TYPE,
    effective_to_date     okl_fe_eo_terms_all_b.effective_to_date%TYPE,
    attribute_category    okl_fe_eo_terms_all_b.attribute_category%TYPE,
    attribute1            okl_fe_eo_terms_all_b.attribute1%TYPE,
    attribute2            okl_fe_eo_terms_all_b.attribute2%TYPE,
    attribute3            okl_fe_eo_terms_all_b.attribute3%TYPE,
    attribute4            okl_fe_eo_terms_all_b.attribute4%TYPE,
    attribute5            okl_fe_eo_terms_all_b.attribute5%TYPE,
    attribute6            okl_fe_eo_terms_all_b.attribute6%TYPE,
    attribute7            okl_fe_eo_terms_all_b.attribute7%TYPE,
    attribute8            okl_fe_eo_terms_all_b.attribute8%TYPE,
    attribute9            okl_fe_eo_terms_all_b.attribute9%TYPE,
    attribute10           okl_fe_eo_terms_all_b.attribute10%TYPE,
    attribute11           okl_fe_eo_terms_all_b.attribute11%TYPE,
    attribute12           okl_fe_eo_terms_all_b.attribute12%TYPE,
    attribute13           okl_fe_eo_terms_all_b.attribute13%TYPE,
    attribute14           okl_fe_eo_terms_all_b.attribute14%TYPE,
    attribute15           okl_fe_eo_terms_all_b.attribute15%TYPE,
    created_by            NUMBER,
    creation_date         okl_fe_eo_terms_all_b.creation_date%TYPE,
    last_updated_by       NUMBER,
    last_update_date      okl_fe_eo_terms_all_b.last_update_date%TYPE,
    last_update_login     NUMBER
  );

  TYPE okl_ethb_tbl IS TABLE OF okl_ethb_rec INDEX BY BINARY_INTEGER;

  TYPE okl_ethtl_rec IS RECORD (
    end_of_term_id    NUMBER,
    end_of_term_desc  okl_fe_eo_terms_all_tl.end_of_term_desc%TYPE,
    language          okl_fe_eo_terms_all_tl.language%TYPE,
    source_lang       okl_fe_eo_terms_all_tl.source_lang%TYPE,
    sfwt_flag         okl_fe_eo_terms_all_tl.sfwt_flag%TYPE,
    created_by        NUMBER,
    creation_date     okl_fe_eo_terms_all_tl.creation_date%TYPE,
    last_updated_by   NUMBER,
    last_update_date  okl_fe_eo_terms_all_tl.last_update_date%TYPE,
    last_update_login NUMBER
  );

  TYPE okl_ethtl_tbl IS TABLE OF okl_ethtl_rec INDEX BY BINARY_INTEGER;

  --------------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  --------------------------------------------------------------------------------

  g_fnd_app                    CONSTANT VARCHAR2(200) := okl_api.g_fnd_app;
  g_form_unable_to_reserve_rec CONSTANT VARCHAR2(200) := okl_api.g_form_unable_to_reserve_rec;
  g_form_record_deleted        CONSTANT VARCHAR2(200) := okl_api.g_form_record_deleted;
  g_form_record_changed        CONSTANT VARCHAR2(200) := okl_api.g_form_record_changed;
  g_record_logically_deleted   CONSTANT VARCHAR2(200) := okl_api.g_record_logically_deleted;
  g_required_value             CONSTANT VARCHAR2(200) := okl_api.g_required_value;
  g_invalid_value              CONSTANT VARCHAR2(200) := okl_api.g_invalid_value;
  g_col_name_token             CONSTANT VARCHAR2(200) := okl_api.g_col_name_token;
  g_parent_table_token         CONSTANT VARCHAR2(200) := okl_api.g_parent_table_token;
  g_child_table_token          CONSTANT VARCHAR2(200) := okl_api.g_child_table_token;

  --------------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  --------------------------------------------------------------------------------

  g_pkg_name                   CONSTANT VARCHAR2(200) := 'OKL_POS_PVT';
  g_app_name                   CONSTANT VARCHAR2(3)   := okl_api.g_app_name;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE change_version;

  PROCEDURE api_copy;

  PROCEDURE add_language;

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_rec      IN            okl_ethv_rec
                      ,x_ethv_rec         OUT NOCOPY okl_ethv_rec);

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_tbl      IN            okl_ethv_tbl
                      ,x_ethv_tbl         OUT NOCOPY okl_ethv_tbl);

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_rec      IN            okl_ethv_rec
                      ,x_ethv_rec         OUT NOCOPY okl_ethv_rec);

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_tbl      IN            okl_ethv_tbl
                      ,x_ethv_tbl         OUT NOCOPY okl_ethv_tbl);

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_rec      IN            okl_ethv_rec);

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_ethv_tbl      IN            okl_ethv_tbl);

END okl_eth_pvt;

 

/
