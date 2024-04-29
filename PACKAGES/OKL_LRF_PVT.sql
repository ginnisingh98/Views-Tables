--------------------------------------------------------
--  DDL for Package OKL_LRF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LRF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLRFS.pls 120.3 2005/07/05 12:34:50 asawanka noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE CONSTANTS
  -----------------------------------------------------------------------------

  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_LRF_PVT';
  g_app_name                   CONSTANT varchar2(3) := okl_api.g_app_name;
  g_api_version                CONSTANT number := 1;
  g_false                      CONSTANT varchar2(1) := fnd_api.g_false;
  g_true                       CONSTANT varchar2(1) := fnd_api.g_true;
  g_db_error                   CONSTANT varchar2(12) := 'OKL_DB_ERROR';
  g_prog_name_token            CONSTANT varchar2(9) := 'PROG_NAME';
  g_sqlcode_token              CONSTANT varchar2(7) := 'SQLCODE';
  g_sqlerrm_token              CONSTANT varchar2(7) := 'SQLERRM';
  g_ret_sts_success            CONSTANT varchar2(1) := fnd_api.g_ret_sts_success;
  g_ret_sts_unexp_error        CONSTANT varchar2(1) := fnd_api.g_ret_sts_unexp_error;
  g_ret_sts_error              CONSTANT varchar2(1) := fnd_api.g_ret_sts_error;
  g_miss_char                  CONSTANT varchar2(1) := fnd_api.g_miss_char;
  g_miss_num                   CONSTANT number := fnd_api.g_miss_num;
  g_miss_date                  CONSTANT date := fnd_api.g_miss_date;
  g_fnd_app                    CONSTANT varchar2(200) := okl_api.g_fnd_app;
  g_form_unable_to_reserve_rec CONSTANT varchar2(200) := okl_api.g_form_unable_to_reserve_rec;
  g_form_record_deleted        CONSTANT varchar2(200) := okl_api.g_form_record_deleted;
  g_form_record_changed        CONSTANT varchar2(200) := okl_api.g_form_record_changed;
  g_record_logically_deleted   CONSTANT varchar2(200) := okl_api.g_record_logically_deleted;
  g_required_value             CONSTANT varchar2(200) := okl_api.g_required_value;
  g_invalid_value              CONSTANT varchar2(200) := okl_api.g_invalid_value;
  g_col_name_token             CONSTANT varchar2(200) := okl_api.g_col_name_token;
  g_parent_table_token         CONSTANT varchar2(200) := okl_api.g_parent_table_token;
  g_child_table_token          CONSTANT varchar2(200) := okl_api.g_child_table_token;
  g_unexpected_error           CONSTANT varchar2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';

  ---------------------------------------------------------------------------
  -- DATA STRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_LS_RT_FCTR_ENTS_V Record Spec

  TYPE lrfv_rec_type IS RECORD (
    id                     number,
    object_version_number  number,
    lrt_id                 number,
    term_in_months         number,
    residual_value_percent number,
    interest_rate          number,
    lease_rate_factor      number,
    created_by             number,
    creation_date          okl_ls_rt_fctr_ents_v.creation_date%TYPE,
    last_updated_by        number,
    last_update_date       okl_ls_rt_fctr_ents_v.last_update_date%TYPE,
    last_update_login      number,
    attribute_category     okl_ls_rt_fctr_ents_v.attribute_category%TYPE,
    attribute1             okl_ls_rt_fctr_ents_v.attribute1%TYPE,
    attribute2             okl_ls_rt_fctr_ents_v.attribute2%TYPE,
    attribute3             okl_ls_rt_fctr_ents_v.attribute3%TYPE,
    attribute4             okl_ls_rt_fctr_ents_v.attribute4%TYPE,
    attribute5             okl_ls_rt_fctr_ents_v.attribute5%TYPE,
    attribute6             okl_ls_rt_fctr_ents_v.attribute6%TYPE,
    attribute7             okl_ls_rt_fctr_ents_v.attribute7%TYPE,
    attribute8             okl_ls_rt_fctr_ents_v.attribute8%TYPE,
    attribute9             okl_ls_rt_fctr_ents_v.attribute9%TYPE,
    attribute10            okl_ls_rt_fctr_ents_v.attribute10%TYPE,
    attribute11            okl_ls_rt_fctr_ents_v.attribute11%TYPE,
    attribute12            okl_ls_rt_fctr_ents_v.attribute12%TYPE,
    attribute13            okl_ls_rt_fctr_ents_v.attribute13%TYPE,
    attribute14            okl_ls_rt_fctr_ents_v.attribute14%TYPE,
    attribute15            okl_ls_rt_fctr_ents_v.attribute15%TYPE,
    is_new_flag            varchar2(3),
    rate_set_version_id    number
  );
  g_miss_lrfv_rec lrfv_rec_type;

  TYPE lrfv_tbl_type IS TABLE OF lrfv_rec_type INDEX BY BINARY_INTEGER;

  -- OKL_LS_RT_FCTR_ENTS Record Spec

  TYPE lrf_rec_type IS RECORD (
    id                     number,
    object_version_number  number,
    lrt_id                 number,
    term_in_months         number,
    residual_value_percent number,
    interest_rate          number,
    lease_rate_factor      number,
    created_by             number,
    creation_date          okl_ls_rt_fctr_ents.creation_date%TYPE,
    last_updated_by        number,
    last_update_date       okl_ls_rt_fctr_ents.last_update_date%TYPE,
    last_update_login      number,
    attribute_category     okl_ls_rt_fctr_ents.attribute_category%TYPE,
    attribute1             okl_ls_rt_fctr_ents.attribute1%TYPE,
    attribute2             okl_ls_rt_fctr_ents.attribute2%TYPE,
    attribute3             okl_ls_rt_fctr_ents.attribute3%TYPE,
    attribute4             okl_ls_rt_fctr_ents.attribute4%TYPE,
    attribute5             okl_ls_rt_fctr_ents.attribute5%TYPE,
    attribute6             okl_ls_rt_fctr_ents.attribute6%TYPE,
    attribute7             okl_ls_rt_fctr_ents.attribute7%TYPE,
    attribute8             okl_ls_rt_fctr_ents.attribute8%TYPE,
    attribute9             okl_ls_rt_fctr_ents.attribute9%TYPE,
    attribute10            okl_ls_rt_fctr_ents.attribute10%TYPE,
    attribute11            okl_ls_rt_fctr_ents.attribute11%TYPE,
    attribute12            okl_ls_rt_fctr_ents.attribute12%TYPE,
    attribute13            okl_ls_rt_fctr_ents.attribute13%TYPE,
    attribute14            okl_ls_rt_fctr_ents.attribute14%TYPE,
    attribute15            okl_ls_rt_fctr_ents.attribute15%TYPE,
    is_new_flag            varchar2(3),
    rate_set_version_id    number
  );
  g_miss_lrf_rec lrf_rec_type;

  TYPE lrf_tbl_type IS TABLE OF lrf_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_rec       IN             lrfv_rec_type
                      ,x_lrfv_rec          OUT NOCOPY  lrfv_rec_type);

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_tbl       IN             lrfv_tbl_type
                      ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type);

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrfv_rec       IN             lrfv_rec_type);

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrfv_tbl       IN             lrfv_tbl_type);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_rec       IN             lrfv_rec_type
                      ,x_lrfv_rec          OUT NOCOPY  lrfv_rec_type);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_tbl       IN             lrfv_tbl_type
                      ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_rec       IN             lrfv_rec_type);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrfv_tbl       IN             lrfv_tbl_type);

  PROCEDURE validate_row(p_api_version    IN             number
                        ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                        ,x_return_status     OUT NOCOPY  varchar2
                        ,x_msg_count         OUT NOCOPY  number
                        ,x_msg_data          OUT NOCOPY  varchar2
                        ,p_lrfv_rec       IN             lrfv_rec_type);

  PROCEDURE validate_row(p_api_version    IN             number
                        ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                        ,x_return_status     OUT NOCOPY  varchar2
                        ,x_msg_count         OUT NOCOPY  number
                        ,x_msg_data          OUT NOCOPY  varchar2
                        ,p_lrfv_tbl       IN             lrfv_tbl_type);

END okl_lrf_pvt;

 

/
