--------------------------------------------------------
--  DDL for Package OKL_SRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SRV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSRVS.pls 120.0 2005/07/07 10:45:49 viselvar noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_srv_rec IS RECORD (
    std_rate_tmpl_ver_id  NUMBER,
    object_version_number NUMBER,
    version_number        okl_fe_std_rt_tmp_vers.version_number%TYPE,
    std_rate_tmpl_id      NUMBER,
    effective_from_date   okl_fe_std_rt_tmp_vers.effective_from_date%TYPE,
    effective_to_date     okl_fe_std_rt_tmp_vers.effective_to_date%TYPE,
    sts_code              okl_fe_std_rt_tmp_vers.sts_code%TYPE,
    adj_mat_version_id    NUMBER,
    srt_rate              NUMBER,
    spread                NUMBER,
    day_convention_code   okl_fe_std_rt_tmp_vers.day_convention_code%TYPE,
    min_adj_rate          NUMBER,
    max_adj_rate          NUMBER,
    attribute_category    okl_fe_std_rt_tmp_vers.attribute_category%TYPE,
    attribute1            okl_fe_std_rt_tmp_vers.attribute1%TYPE,
    attribute2            okl_fe_std_rt_tmp_vers.attribute2%TYPE,
    attribute3            okl_fe_std_rt_tmp_vers.attribute3%TYPE,
    attribute4            okl_fe_std_rt_tmp_vers.attribute4%TYPE,
    attribute5            okl_fe_std_rt_tmp_vers.attribute5%TYPE,
    attribute6            okl_fe_std_rt_tmp_vers.attribute6%TYPE,
    attribute7            okl_fe_std_rt_tmp_vers.attribute7%TYPE,
    attribute8            okl_fe_std_rt_tmp_vers.attribute8%TYPE,
    attribute9            okl_fe_std_rt_tmp_vers.attribute9%TYPE,
    attribute10           okl_fe_std_rt_tmp_vers.attribute10%TYPE,
    attribute11           okl_fe_std_rt_tmp_vers.attribute11%TYPE,
    attribute12           okl_fe_std_rt_tmp_vers.attribute12%TYPE,
    attribute13           okl_fe_std_rt_tmp_vers.attribute13%TYPE,
    attribute14           okl_fe_std_rt_tmp_vers.attribute14%TYPE,
    attribute15           okl_fe_std_rt_tmp_vers.attribute15%TYPE,
    created_by            NUMBER,
    creation_date         okl_fe_std_rt_tmp_vers.creation_date%TYPE,
    last_updated_by       NUMBER,
    last_update_date      okl_fe_std_rt_tmp_vers.last_update_date%TYPE,
    last_update_login     NUMBER
  );

  TYPE okl_srv_tbl IS TABLE OF okl_srv_rec INDEX BY BINARY_INTEGER;

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

  g_pkg_name                   CONSTANT VARCHAR2(200) := 'OKL_SRV_PVT';
  g_app_name                   CONSTANT VARCHAR2(3)   := okl_api.g_app_name;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE change_version;

  PROCEDURE api_copy;

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srv_rec       IN            okl_srv_rec
                      ,x_srv_rec          OUT NOCOPY okl_srv_rec);

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srv_tbl       IN            okl_srv_tbl
                      ,x_srv_tbl          OUT NOCOPY okl_srv_tbl);

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srv_rec       IN            okl_srv_rec
                      ,x_srv_rec          OUT NOCOPY okl_srv_rec);

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srv_tbl       IN            okl_srv_tbl
                      ,x_srv_tbl          OUT NOCOPY okl_srv_tbl);

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srv_rec       IN            okl_srv_rec);

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srv_tbl       IN            okl_srv_tbl);

END okl_srv_pvt;

 

/
