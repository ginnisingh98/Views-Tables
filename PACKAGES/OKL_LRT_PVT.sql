--------------------------------------------------------
--  DDL for Package OKL_LRT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LRT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLRTS.pls 120.5 2005/07/05 12:35:30 asawanka noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE CONSTANTS
  -----------------------------------------------------------------------------

  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_LRT_PVT';
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
  -- OKL_LS_RT_FCTR_SETS_V Record Spec

  TYPE lrtv_rec_type IS RECORD (
    id                    number,
    object_version_number number,
    sfwt_flag             okl_ls_rt_fctr_sets_v.sfwt_flag%TYPE,
    try_id                number,
    pdt_id                number,
    rate                  number,
    frq_code              okl_ls_rt_fctr_sets_v.frq_code%TYPE,
    arrears_yn            okl_ls_rt_fctr_sets_v.arrears_yn%TYPE,
    start_date            okl_ls_rt_fctr_sets_v.start_date%TYPE,
    end_date              okl_ls_rt_fctr_sets_v.end_date%TYPE,
    name                  okl_ls_rt_fctr_sets_v.name%TYPE,
    description           okl_ls_rt_fctr_sets_v.description%TYPE,
    created_by            number,
    creation_date         okl_ls_rt_fctr_sets_v.creation_date%TYPE,
    last_updated_by       number                                        := okl_api.g_miss_num,
    last_update_date      okl_ls_rt_fctr_sets_v.last_update_date%TYPE,
    last_update_login     number,
    attribute_category    okl_ls_rt_fctr_sets_v.attribute_category%TYPE,
    attribute1            okl_ls_rt_fctr_sets_v.attribute1%TYPE,
    attribute2            okl_ls_rt_fctr_sets_v.attribute2%TYPE,
    attribute3            okl_ls_rt_fctr_sets_v.attribute3%TYPE,
    attribute4            okl_ls_rt_fctr_sets_v.attribute4%TYPE,
    attribute5            okl_ls_rt_fctr_sets_v.attribute5%TYPE,
    attribute6            okl_ls_rt_fctr_sets_v.attribute6%TYPE,
    attribute7            okl_ls_rt_fctr_sets_v.attribute7%TYPE,
    attribute8            okl_ls_rt_fctr_sets_v.attribute8%TYPE,
    attribute9            okl_ls_rt_fctr_sets_v.attribute9%TYPE,
    attribute10           okl_ls_rt_fctr_sets_v.attribute10%TYPE,
    attribute11           okl_ls_rt_fctr_sets_v.attribute11%TYPE,
    attribute12           okl_ls_rt_fctr_sets_v.attribute12%TYPE,
    attribute13           okl_ls_rt_fctr_sets_v.attribute13%TYPE,
    attribute14           okl_ls_rt_fctr_sets_v.attribute14%TYPE,
    attribute15           okl_ls_rt_fctr_sets_v.attribute15%TYPE,
    sts_code              okl_ls_rt_fctr_sets_v.sts_code%TYPE,
    org_id                number,
    currency_code         okl_ls_rt_fctr_sets_v.currency_code%TYPE,
    lrs_type_code         okl_ls_rt_fctr_sets_v.lrs_type_code%TYPE,
    end_of_term_id        number,
    orig_rate_set_id      number
  );

  TYPE lrtv_tbl_type IS TABLE OF lrtv_rec_type INDEX BY BINARY_INTEGER;

  -- OKL_LS_RT_FCTR_SETS_B Record Spec

  TYPE lrt_rec_type IS RECORD (
    id                    number,
    object_version_number number,
    name                  okl_ls_rt_fctr_sets_b.name%TYPE,
    arrears_yn            okl_ls_rt_fctr_sets_b.arrears_yn%TYPE,
    start_date            okl_ls_rt_fctr_sets_b.start_date%TYPE,
    end_date              okl_ls_rt_fctr_sets_b.end_date%TYPE,
    pdt_id                number,
    rate                  number,
    try_id                number,
    frq_code              okl_ls_rt_fctr_sets_b.frq_code%TYPE,
    created_by            number,
    creation_date         okl_ls_rt_fctr_sets_b.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_ls_rt_fctr_sets_b.last_update_date%TYPE,
    last_update_login     number,
    attribute_category    okl_ls_rt_fctr_sets_b.attribute_category%TYPE,
    attribute1            okl_ls_rt_fctr_sets_b.attribute1%TYPE,
    attribute2            okl_ls_rt_fctr_sets_b.attribute2%TYPE,
    attribute3            okl_ls_rt_fctr_sets_b.attribute3%TYPE,
    attribute4            okl_ls_rt_fctr_sets_b.attribute4%TYPE,
    attribute5            okl_ls_rt_fctr_sets_b.attribute5%TYPE,
    attribute6            okl_ls_rt_fctr_sets_b.attribute6%TYPE,
    attribute7            okl_ls_rt_fctr_sets_b.attribute7%TYPE,
    attribute8            okl_ls_rt_fctr_sets_b.attribute8%TYPE,
    attribute9            okl_ls_rt_fctr_sets_b.attribute9%TYPE,
    attribute10           okl_ls_rt_fctr_sets_b.attribute10%TYPE,
    attribute11           okl_ls_rt_fctr_sets_b.attribute11%TYPE,
    attribute12           okl_ls_rt_fctr_sets_b.attribute12%TYPE,
    attribute13           okl_ls_rt_fctr_sets_b.attribute13%TYPE,
    attribute14           okl_ls_rt_fctr_sets_b.attribute14%TYPE,
    attribute15           okl_ls_rt_fctr_sets_b.attribute15%TYPE,
    sts_code              okl_ls_rt_fctr_sets_b.sts_code%TYPE,
    org_id                number,
    currency_code         okl_ls_rt_fctr_sets_b.currency_code%TYPE,
    lrs_type_code         okl_ls_rt_fctr_sets_b.lrs_type_code%TYPE,
    end_of_term_id        number,
    orig_rate_set_id      number
  );

  TYPE lrt_tbl_type IS TABLE OF lrt_rec_type INDEX BY BINARY_INTEGER;

  -- OKL_LS_RT_FCTR_SETS_TL Record Spec

  TYPE lrttl_rec_type IS RECORD (
    id                number,
    language          okl_ls_rt_fctr_sets_tl.language%TYPE,
    source_lang       okl_ls_rt_fctr_sets_tl.source_lang%TYPE,
    sfwt_flag         okl_ls_rt_fctr_sets_tl.sfwt_flag%TYPE,
    description       okl_ls_rt_fctr_sets_tl.description%TYPE,
    created_by        number,
    creation_date     okl_ls_rt_fctr_sets_tl.creation_date%TYPE,
    last_updated_by   number,
    last_update_date  okl_ls_rt_fctr_sets_tl.last_update_date%TYPE,
    last_update_login number
  );

  TYPE lrttl_tbl_type IS TABLE OF lrttl_rec_type INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------

  PROCEDURE add_language;

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_rec       IN             lrtv_rec_type
                      ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type);

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_tbl       IN             lrtv_tbl_type
                      ,x_lrtv_tbl          OUT NOCOPY  lrtv_tbl_type);

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrtv_rec       IN             lrtv_rec_type);

  PROCEDURE lock_row(p_api_version    IN             number
                    ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                    ,x_return_status     OUT NOCOPY  varchar2
                    ,x_msg_count         OUT NOCOPY  number
                    ,x_msg_data          OUT NOCOPY  varchar2
                    ,p_lrtv_tbl       IN             lrtv_tbl_type);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_rec       IN             lrtv_rec_type
                      ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_tbl       IN             lrtv_tbl_type
                      ,x_lrtv_tbl          OUT NOCOPY  lrtv_tbl_type);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_rec       IN             lrtv_rec_type);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrtv_tbl       IN             lrtv_tbl_type);

  PROCEDURE validate_row(p_api_version    IN             number
                        ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                        ,x_return_status     OUT NOCOPY  varchar2
                        ,x_msg_count         OUT NOCOPY  number
                        ,x_msg_data          OUT NOCOPY  varchar2
                        ,p_lrtv_rec       IN             lrtv_rec_type);

  PROCEDURE validate_row(p_api_version    IN             number
                        ,p_init_msg_list  IN             varchar2      DEFAULT okc_api.g_false
                        ,x_return_status     OUT NOCOPY  varchar2
                        ,x_msg_count         OUT NOCOPY  number
                        ,x_msg_data          OUT NOCOPY  varchar2
                        ,p_lrtv_tbl       IN             lrtv_tbl_type);

END okl_lrt_pvt;

 

/
