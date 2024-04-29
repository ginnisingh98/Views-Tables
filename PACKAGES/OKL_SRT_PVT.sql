--------------------------------------------------------
--  DDL for Package OKL_SRT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SRT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSRTS.pls 120.1 2005/11/29 14:29:26 viselvar noship $ */
  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------
  TYPE okl_srtv_rec IS RECORD (
    std_rate_tmpl_id      NUMBER,
    template_name         okl_fe_std_rt_tmp_v.template_name%TYPE,
    template_desc         okl_fe_std_rt_tmp_v.template_desc%TYPE,
    object_version_number NUMBER,
    org_id                NUMBER,
    currency_code         okl_fe_std_rt_tmp_v.currency_code%TYPE,
    rate_card_yn          okl_fe_std_rt_tmp_v.rate_card_yn%TYPE,
    pricing_engine_code   okl_fe_std_rt_tmp_v.pricing_engine_code%TYPE,
    orig_std_rate_tmpl_id NUMBER,
    rate_type_code        okl_fe_std_rt_tmp_v.rate_type_code%TYPE,
    frequency_code        okl_fe_std_rt_tmp_v.frequency_code%TYPE,
    index_id              NUMBER,
    default_yn            okl_fe_std_rt_tmp_v.default_yn%TYPE,
    sts_code              okl_fe_std_rt_tmp_v.sts_code%TYPE,
    effective_from_date   okl_fe_std_rt_tmp_v.effective_from_date%TYPE,
    effective_to_date     okl_fe_std_rt_tmp_v.effective_to_date%TYPE,
    srt_rate              NUMBER,
    attribute_category    okl_fe_std_rt_tmp_v.attribute_category%TYPE,
    attribute1            okl_fe_std_rt_tmp_v.attribute1%TYPE,
    attribute2            okl_fe_std_rt_tmp_v.attribute2%TYPE,
    attribute3            okl_fe_std_rt_tmp_v.attribute3%TYPE,
    attribute4            okl_fe_std_rt_tmp_v.attribute4%TYPE,
    attribute5            okl_fe_std_rt_tmp_v.attribute5%TYPE,
    attribute6            okl_fe_std_rt_tmp_v.attribute6%TYPE,
    attribute7            okl_fe_std_rt_tmp_v.attribute7%TYPE,
    attribute8            okl_fe_std_rt_tmp_v.attribute8%TYPE,
    attribute9            okl_fe_std_rt_tmp_v.attribute9%TYPE,
    attribute10           okl_fe_std_rt_tmp_v.attribute10%TYPE,
    attribute11           okl_fe_std_rt_tmp_v.attribute11%TYPE,
    attribute12           okl_fe_std_rt_tmp_v.attribute12%TYPE,
    attribute13           okl_fe_std_rt_tmp_v.attribute13%TYPE,
    attribute14           okl_fe_std_rt_tmp_v.attribute14%TYPE,
    attribute15           okl_fe_std_rt_tmp_v.attribute15%TYPE,
    created_by            NUMBER,
    creation_date         okl_fe_std_rt_tmp_v.creation_date%TYPE,
    last_updated_by       NUMBER,
    last_update_date      okl_fe_std_rt_tmp_v.last_update_date%TYPE,
    last_update_login     NUMBER
  );

  TYPE okl_srtv_tbl IS TABLE OF okl_srtv_rec INDEX BY BINARY_INTEGER;
  TYPE okl_srtb_rec IS RECORD (
    std_rate_tmpl_id      NUMBER,
    template_name         okl_fe_std_rt_tmp_all_b.template_name%TYPE,
    object_version_number NUMBER,
    org_id                NUMBER,
    currency_code         okl_fe_std_rt_tmp_all_b.currency_code%TYPE,
    rate_card_yn          okl_fe_std_rt_tmp_all_b.rate_card_yn%TYPE,
    pricing_engine_code   okl_fe_std_rt_tmp_all_b.pricing_engine_code%TYPE,
    orig_std_rate_tmpl_id NUMBER,
    rate_type_code        okl_fe_std_rt_tmp_all_b.rate_type_code%TYPE,
    frequency_code        okl_fe_std_rt_tmp_all_b.frequency_code%TYPE,
    index_id              NUMBER,
    default_yn            okl_fe_std_rt_tmp_v.default_yn%TYPE,
    sts_code              okl_fe_std_rt_tmp_all_b.sts_code%TYPE,
    effective_from_date   okl_fe_std_rt_tmp_all_b.effective_from_date%TYPE,
    effective_to_date     okl_fe_std_rt_tmp_all_b.effective_to_date%TYPE,
    srt_rate              NUMBER,
    attribute_category    okl_fe_std_rt_tmp_all_b.attribute_category%TYPE,
    attribute1            okl_fe_std_rt_tmp_all_b.attribute1%TYPE,
    attribute2            okl_fe_std_rt_tmp_all_b.attribute2%TYPE,
    attribute3            okl_fe_std_rt_tmp_all_b.attribute3%TYPE,
    attribute4            okl_fe_std_rt_tmp_all_b.attribute4%TYPE,
    attribute5            okl_fe_std_rt_tmp_all_b.attribute5%TYPE,
    attribute6            okl_fe_std_rt_tmp_all_b.attribute6%TYPE,
    attribute7            okl_fe_std_rt_tmp_all_b.attribute7%TYPE,
    attribute8            okl_fe_std_rt_tmp_all_b.attribute8%TYPE,
    attribute9            okl_fe_std_rt_tmp_all_b.attribute9%TYPE,
    attribute10           okl_fe_std_rt_tmp_all_b.attribute10%TYPE,
    attribute11           okl_fe_std_rt_tmp_all_b.attribute11%TYPE,
    attribute12           okl_fe_std_rt_tmp_all_b.attribute12%TYPE,
    attribute13           okl_fe_std_rt_tmp_all_b.attribute13%TYPE,
    attribute14           okl_fe_std_rt_tmp_all_b.attribute14%TYPE,
    attribute15           okl_fe_std_rt_tmp_all_b.attribute15%TYPE,
    created_by            NUMBER,
    creation_date         okl_fe_std_rt_tmp_all_b.creation_date%TYPE,
    last_updated_by       NUMBER,
    last_update_date      okl_fe_std_rt_tmp_all_b.last_update_date%TYPE,
    last_update_login     NUMBER
  );

  TYPE okl_srtb_tbl IS TABLE OF okl_srtb_rec INDEX BY BINARY_INTEGER;
  TYPE okl_srttl_rec IS RECORD (
    std_rate_tmpl_id  NUMBER,
    template_desc     okl_fe_std_rt_tmp_all_tl.template_desc%TYPE,
    language          okl_fe_std_rt_tmp_all_tl.language%TYPE,
    source_lang       okl_fe_std_rt_tmp_all_tl.source_lang%TYPE,
    sfwt_flag         okl_fe_std_rt_tmp_all_tl.sfwt_flag%TYPE,
    created_by        NUMBER,
    creation_date     okl_fe_std_rt_tmp_all_tl.creation_date%TYPE,
    last_updated_by   NUMBER,
    last_update_date  okl_fe_std_rt_tmp_all_tl.last_update_date%TYPE,
    last_update_login NUMBER
  );

  TYPE okl_srttl_tbl IS TABLE OF okl_srttl_rec INDEX BY BINARY_INTEGER;

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
  g_pkg_name                   CONSTANT VARCHAR2(200) := 'OKL_SRT_PVT';
  g_app_name                   CONSTANT VARCHAR2(3)   := okl_api.g_app_name;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE change_version;

  PROCEDURE api_copy;

  PROCEDURE add_language;

  PROCEDURE insert_row(p_api_version                 IN          NUMBER
                      ,p_init_msg_list               IN          VARCHAR2 DEFAULT okl_api.g_false
                      ,x_return_status               OUT NOCOPY  VARCHAR2
                      ,x_msg_count                   OUT NOCOPY  NUMBER
                      ,x_msg_data                    OUT NOCOPY  VARCHAR2
                      ,p_srtv_rec                    IN          okl_srtv_rec
                      ,x_srtv_rec                    OUT NOCOPY  okl_srtv_rec);

  PROCEDURE insert_row(p_api_version                 IN          NUMBER
                      ,p_init_msg_list               IN          VARCHAR2 DEFAULT okl_api.g_false
                      ,x_return_status               OUT NOCOPY  VARCHAR2
                      ,x_msg_count                   OUT NOCOPY  NUMBER
                      ,x_msg_data                    OUT NOCOPY  VARCHAR2
                      ,p_srtv_tbl                    IN          okl_srtv_tbl
                      ,x_srtv_tbl                    OUT NOCOPY  okl_srtv_tbl);

  PROCEDURE update_row(p_api_version                 IN          NUMBER
                      ,p_init_msg_list               IN          VARCHAR2 DEFAULT okl_api.g_false
                      ,x_return_status               OUT NOCOPY  VARCHAR2
                      ,x_msg_count                   OUT NOCOPY  NUMBER
                      ,x_msg_data                    OUT NOCOPY  VARCHAR2
                      ,p_srtv_rec                    IN          okl_srtv_rec
                      ,x_srtv_rec                    OUT NOCOPY  okl_srtv_rec);

  PROCEDURE update_row(p_api_version                 IN          NUMBER
                      ,p_init_msg_list               IN          VARCHAR2 DEFAULT okl_api.g_false
                      ,x_return_status               OUT NOCOPY  VARCHAR2
                      ,x_msg_count                   OUT NOCOPY  NUMBER
                      ,x_msg_data                    OUT NOCOPY  VARCHAR2
                      ,p_srtv_tbl                    IN          okl_srtv_tbl
                      ,x_srtv_tbl                    OUT NOCOPY  okl_srtv_tbl);

  PROCEDURE delete_row(p_api_version                 IN          NUMBER
                      ,p_init_msg_list               IN          VARCHAR2 DEFAULT okl_api.g_false
                      ,x_return_status               OUT NOCOPY  VARCHAR2
                      ,x_msg_count                   OUT NOCOPY  NUMBER
                      ,x_msg_data                    OUT NOCOPY  VARCHAR2
                      ,p_srtv_rec                    IN          okl_srtv_rec);

  PROCEDURE delete_row(p_api_version                 IN          NUMBER
                      ,p_init_msg_list               IN          VARCHAR2 DEFAULT okl_api.g_false
                      ,x_return_status               OUT NOCOPY  VARCHAR2
                      ,x_msg_count                   OUT NOCOPY  NUMBER
                      ,x_msg_data                    OUT NOCOPY  VARCHAR2
                      ,p_srtv_tbl                    IN          okl_srtv_tbl);

END okl_srt_pvt;

 

/
