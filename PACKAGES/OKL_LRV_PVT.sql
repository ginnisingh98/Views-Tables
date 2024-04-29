--------------------------------------------------------
--  DDL for Package OKL_LRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LRV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLRVS.pls 120.1 2005/09/30 11:01:15 asawanka noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_lrvv_rec IS RECORD (
    rate_set_version_id   number,
    object_version_number number,
    arrears_yn            okl_fe_rate_set_versions_v.arrears_yn%TYPE,
    effective_from_date   okl_fe_rate_set_versions_v.effective_from_date%TYPE,
    effective_to_date     okl_fe_rate_set_versions_v.effective_to_date%TYPE,
    rate_set_id           number,
    end_of_term_ver_id    number,
    std_rate_tmpl_ver_id  number,
    adj_mat_version_id    number,
    version_number        okl_fe_rate_set_versions_v.version_number%TYPE,
    lrs_rate              number,
    rate_tolerance        number,
    residual_tolerance    number,
    deferred_pmts         number,
    advance_pmts          number,
    sts_code              okl_fe_rate_set_versions_v.sts_code%TYPE,
    created_by            number,
    creation_date         okl_fe_rate_set_versions_v.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_rate_set_versions_v.last_update_date%TYPE,
    last_update_login     number,
    attribute_category    okl_fe_rate_set_versions_v.attribute_category%TYPE,
    attribute1            okl_fe_rate_set_versions_v.attribute1%TYPE,
    attribute2            okl_fe_rate_set_versions_v.attribute2%TYPE,
    attribute3            okl_fe_rate_set_versions_v.attribute3%TYPE,
    attribute4            okl_fe_rate_set_versions_v.attribute4%TYPE,
    attribute5            okl_fe_rate_set_versions_v.attribute5%TYPE,
    attribute6            okl_fe_rate_set_versions_v.attribute6%TYPE,
    attribute7            okl_fe_rate_set_versions_v.attribute7%TYPE,
    attribute8            okl_fe_rate_set_versions_v.attribute8%TYPE,
    attribute9            okl_fe_rate_set_versions_v.attribute9%TYPE,
    attribute10           okl_fe_rate_set_versions_v.attribute10%TYPE,
    attribute11           okl_fe_rate_set_versions_v.attribute11%TYPE,
    attribute12           okl_fe_rate_set_versions_v.attribute12%TYPE,
    attribute13           okl_fe_rate_set_versions_v.attribute13%TYPE,
    attribute14           okl_fe_rate_set_versions_v.attribute14%TYPE,
    attribute15           okl_fe_rate_set_versions_v.attribute15%TYPE,
    standard_rate         okl_fe_rate_set_versions_v.standard_rate%TYPE
  );

  TYPE okl_lrvv_tbl IS TABLE OF okl_lrvv_rec INDEX BY BINARY_INTEGER;

  TYPE okl_lrv_rec IS RECORD (
    rate_set_version_id   number,
    object_version_number number,
    arrears_yn            okl_fe_rate_set_versions.arrears_yn%TYPE,
    effective_from_date   okl_fe_rate_set_versions.effective_from_date%TYPE,
    effective_to_date     okl_fe_rate_set_versions.effective_to_date%TYPE,
    rate_set_id           number,
    end_of_term_ver_id    number,
    std_rate_tmpl_ver_id  number,
    adj_mat_version_id    number,
    version_number        okl_fe_rate_set_versions.version_number%TYPE,
    lrs_rate              number,
    rate_tolerance        number,
    residual_tolerance    number,
    deferred_pmts         number,
    advance_pmts          number,
    sts_code              okl_fe_rate_set_versions.sts_code%TYPE,
    created_by            number,
    creation_date         okl_fe_rate_set_versions.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_rate_set_versions.last_update_date%TYPE,
    last_update_login     number,
    attribute_category    okl_fe_rate_set_versions.attribute_category%TYPE,
    attribute1            okl_fe_rate_set_versions.attribute1%TYPE,
    attribute2            okl_fe_rate_set_versions.attribute2%TYPE,
    attribute3            okl_fe_rate_set_versions.attribute3%TYPE,
    attribute4            okl_fe_rate_set_versions.attribute4%TYPE,
    attribute5            okl_fe_rate_set_versions.attribute5%TYPE,
    attribute6            okl_fe_rate_set_versions.attribute6%TYPE,
    attribute7            okl_fe_rate_set_versions.attribute7%TYPE,
    attribute8            okl_fe_rate_set_versions.attribute8%TYPE,
    attribute9            okl_fe_rate_set_versions.attribute9%TYPE,
    attribute10           okl_fe_rate_set_versions.attribute10%TYPE,
    attribute11           okl_fe_rate_set_versions.attribute11%TYPE,
    attribute12           okl_fe_rate_set_versions.attribute12%TYPE,
    attribute13           okl_fe_rate_set_versions.attribute13%TYPE,
    attribute14           okl_fe_rate_set_versions.attribute14%TYPE,
    attribute15           okl_fe_rate_set_versions.attribute15%TYPE,
    standard_rate         okl_fe_rate_set_versions.standard_rate%TYPE
  );

  TYPE okl_lrv_tbl IS TABLE OF okl_lrv_rec INDEX BY BINARY_INTEGER;

  --------------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  --------------------------------------------------------------------------------

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

  --------------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  --------------------------------------------------------------------------------

  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_LRV_PVT';
  g_app_name                   CONSTANT varchar2(3) := okl_api.g_app_name;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE change_version;

  PROCEDURE api_copy;

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_rec       IN             okl_lrvv_rec
                      ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_tbl       IN             okl_lrvv_tbl
                      ,x_lrvv_tbl          OUT NOCOPY  okl_lrvv_tbl);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_rec       IN             okl_lrvv_rec
                      ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_tbl       IN             okl_lrvv_tbl
                      ,x_lrvv_tbl          OUT NOCOPY  okl_lrvv_tbl);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_rec       IN             okl_lrvv_rec);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrvv_tbl       IN             okl_lrvv_tbl);

END okl_lrv_pvt;

 

/
