--------------------------------------------------------
--  DDL for Package OKL_PAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PAM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSPAMS.pls 120.2 2005/11/29 14:20:08 viselvar noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_pamv_rec IS RECORD (
    adj_mat_id            NUMBER,
    object_version_number NUMBER,
    org_id                NUMBER,
    currency_code         okl_fe_adj_mat_v.currency_code%TYPE,
    adj_mat_type_code     okl_fe_adj_mat_v.adj_mat_type_code%TYPE,
    orig_adj_mat_id       NUMBER,
    sts_code              okl_fe_adj_mat_v.sts_code%TYPE,
    effective_from_date   okl_fe_adj_mat_v.effective_from_date%TYPE,
    effective_to_date     okl_fe_adj_mat_v.effective_to_date%TYPE,
    attribute_category    okl_fe_adj_mat_v.attribute_category%TYPE,
    attribute1            okl_fe_adj_mat_v.attribute1%TYPE,
    attribute2            okl_fe_adj_mat_v.attribute2%TYPE,
    attribute3            okl_fe_adj_mat_v.attribute3%TYPE,
    attribute4            okl_fe_adj_mat_v.attribute4%TYPE,
    attribute5            okl_fe_adj_mat_v.attribute5%TYPE,
    attribute6            okl_fe_adj_mat_v.attribute6%TYPE,
    attribute7            okl_fe_adj_mat_v.attribute7%TYPE,
    attribute8            okl_fe_adj_mat_v.attribute8%TYPE,
    attribute9            okl_fe_adj_mat_v.attribute9%TYPE,
    attribute10           okl_fe_adj_mat_v.attribute10%TYPE,
    attribute11           okl_fe_adj_mat_v.attribute11%TYPE,
    attribute12           okl_fe_adj_mat_v.attribute12%TYPE,
    attribute13           okl_fe_adj_mat_v.attribute13%TYPE,
    attribute14           okl_fe_adj_mat_v.attribute14%TYPE,
    attribute15           okl_fe_adj_mat_v.attribute15%TYPE,
    created_by            NUMBER,
    creation_date         okl_fe_adj_mat_v.creation_date%TYPE,
    last_updated_by       NUMBER,
    last_update_date      okl_fe_adj_mat_v.last_update_date%TYPE,
    last_update_login     NUMBER,
    adj_mat_name          okl_fe_adj_mat_v.adj_mat_name%TYPE,
    adj_mat_desc          okl_fe_adj_mat_v.adj_mat_desc%TYPE
  );

  TYPE okl_pamv_tbl IS TABLE OF okl_pamv_rec INDEX BY BINARY_INTEGER;

  TYPE okl_pamb_rec IS RECORD (
    adj_mat_id            NUMBER,
    adj_mat_name          okl_fe_adj_mat_all_b.adj_mat_name%TYPE,
    object_version_number NUMBER,
    org_id                NUMBER,
    currency_code         okl_fe_adj_mat_all_b.currency_code%TYPE,
    adj_mat_type_code     okl_fe_adj_mat_all_b.adj_mat_type_code%TYPE,
    orig_adj_mat_id       NUMBER,
    sts_code              okl_fe_adj_mat_all_b.sts_code%TYPE,
    effective_from_date   okl_fe_adj_mat_all_b.effective_from_date%TYPE,
    effective_to_date     okl_fe_adj_mat_all_b.effective_to_date%TYPE,
    attribute_category    okl_fe_adj_mat_all_b.attribute_category%TYPE,
    attribute1            okl_fe_adj_mat_all_b.attribute1%TYPE,
    attribute2            okl_fe_adj_mat_all_b.attribute2%TYPE,
    attribute3            okl_fe_adj_mat_all_b.attribute3%TYPE,
    attribute4            okl_fe_adj_mat_all_b.attribute4%TYPE,
    attribute5            okl_fe_adj_mat_all_b.attribute5%TYPE,
    attribute6            okl_fe_adj_mat_all_b.attribute6%TYPE,
    attribute7            okl_fe_adj_mat_all_b.attribute7%TYPE,
    attribute8            okl_fe_adj_mat_all_b.attribute8%TYPE,
    attribute9            okl_fe_adj_mat_all_b.attribute9%TYPE,
    attribute10           okl_fe_adj_mat_all_b.attribute10%TYPE,
    attribute11           okl_fe_adj_mat_all_b.attribute11%TYPE,
    attribute12           okl_fe_adj_mat_all_b.attribute12%TYPE,
    attribute13           okl_fe_adj_mat_all_b.attribute13%TYPE,
    attribute14           okl_fe_adj_mat_all_b.attribute14%TYPE,
    attribute15           okl_fe_adj_mat_all_b.attribute15%TYPE,
    created_by            NUMBER,
    creation_date         okl_fe_adj_mat_all_b.creation_date%TYPE,
    last_updated_by       NUMBER,
    last_update_date      okl_fe_adj_mat_all_b.last_update_date%TYPE,
    last_update_login     NUMBER
  );

  TYPE okl_pamb_tbl IS TABLE OF okl_pamb_rec INDEX BY BINARY_INTEGER;

  TYPE okl_pamtl_rec IS RECORD (
    adj_mat_id        NUMBER,
    adj_mat_desc      okl_fe_adj_mat_all_tl.adj_mat_desc%TYPE,
    language          okl_fe_adj_mat_all_tl.language%TYPE,
    source_lang       okl_fe_adj_mat_all_tl.source_lang%TYPE,
    sfwt_flag         okl_fe_adj_mat_all_tl.sfwt_flag%TYPE,
    created_by        NUMBER,
    creation_date     okl_fe_adj_mat_all_tl.creation_date%TYPE,
    last_updated_by   NUMBER,
    last_update_date  okl_fe_adj_mat_all_tl.last_update_date%TYPE,
    last_update_login NUMBER
  );

  TYPE okl_pamtl_tbl IS TABLE OF okl_pamtl_rec INDEX BY BINARY_INTEGER;

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
  g_ret_sts_success            CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_success;
  g_ret_sts_unexp_error        CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_unexp_error;
  g_ret_sts_error              CONSTANT VARCHAR2(1)   := fnd_api.g_ret_sts_error;
  g_db_error                   CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  g_prog_name_token            CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  g_api_version                CONSTANT NUMBER        := 1;
  g_false                      CONSTANT VARCHAR2(1)   := fnd_api.g_false;
  g_true                       CONSTANT VARCHAR2(1)   := fnd_api.g_true;

  --------------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  --------------------------------------------------------------------------------

  g_pkg_name                   CONSTANT VARCHAR2(200) := 'OKL_PAM_PVT';
  g_app_name                   CONSTANT VARCHAR2(3)   := okl_api.g_app_name;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE change_version;

  PROCEDURE api_copy;

  PROCEDURE add_language;

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_rec      IN            okl_pamv_rec
                      ,x_pamv_rec         OUT NOCOPY okl_pamv_rec);

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_tbl      IN            okl_pamv_tbl
                      ,x_pamv_tbl         OUT NOCOPY okl_pamv_tbl);

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_rec      IN            okl_pamv_rec
                      ,x_pamv_rec         OUT NOCOPY okl_pamv_rec);

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_tbl      IN            okl_pamv_tbl
                      ,x_pamv_tbl         OUT NOCOPY okl_pamv_tbl);

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_rec      IN            okl_pamv_rec);

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_pamv_tbl      IN            okl_pamv_tbl);

END okl_pam_pvt;

 

/
