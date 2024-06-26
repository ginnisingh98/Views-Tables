--------------------------------------------------------
--  DDL for Package OKL_ETV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ETV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSETVS.pls 120.1 2005/08/25 10:34:04 viselvar noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_etv_rec IS RECORD (
    end_of_term_value_id  NUMBER,
    object_version_number NUMBER,
    eot_term              NUMBER,
    eot_value             NUMBER,
    end_of_term_ver_id    NUMBER,
    attribute_category    okl_fe_eo_term_values.attribute_category%TYPE,
    attribute1            okl_fe_eo_term_values.attribute1%TYPE,
    attribute2            okl_fe_eo_term_values.attribute2%TYPE,
    attribute3            okl_fe_eo_term_values.attribute3%TYPE,
    attribute4            okl_fe_eo_term_values.attribute4%TYPE,
    attribute5            okl_fe_eo_term_values.attribute5%TYPE,
    attribute6            okl_fe_eo_term_values.attribute6%TYPE,
    attribute7            okl_fe_eo_term_values.attribute7%TYPE,
    attribute8            okl_fe_eo_term_values.attribute8%TYPE,
    attribute9            okl_fe_eo_term_values.attribute9%TYPE,
    attribute10           okl_fe_eo_term_values.attribute10%TYPE,
    attribute11           okl_fe_eo_term_values.attribute11%TYPE,
    attribute12           okl_fe_eo_term_values.attribute12%TYPE,
    attribute13           okl_fe_eo_term_values.attribute13%TYPE,
    attribute14           okl_fe_eo_term_values.attribute14%TYPE,
    attribute15           okl_fe_eo_term_values.attribute15%TYPE,
    created_by            NUMBER,
    creation_date         okl_fe_eo_term_values.creation_date%TYPE,
    last_updated_by       NUMBER,
    last_update_date      okl_fe_eo_term_values.last_update_date%TYPE,
    last_update_login     NUMBER
  );

  TYPE okl_etv_tbl IS TABLE OF okl_etv_rec INDEX BY BINARY_INTEGER;

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

  g_pkg_name                   CONSTANT VARCHAR2(200) := 'OKL_ETV_PVT';
  g_app_name                   CONSTANT VARCHAR2(3)   := okl_api.g_app_name;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE change_version;

  PROCEDURE api_copy;

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_etv_rec       IN            okl_etv_rec
                      ,x_etv_rec          OUT NOCOPY okl_etv_rec);

  PROCEDURE insert_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_etv_tbl       IN            okl_etv_tbl
                      ,x_etv_tbl          OUT NOCOPY okl_etv_tbl);

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_etv_rec       IN            okl_etv_rec
                      ,x_etv_rec          OUT NOCOPY okl_etv_rec);

  PROCEDURE update_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_etv_tbl       IN            okl_etv_tbl
                      ,x_etv_tbl          OUT NOCOPY okl_etv_tbl);

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_etv_rec       IN            okl_etv_rec);

  PROCEDURE delete_row(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okc_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_etv_tbl       IN            okl_etv_tbl);

END okl_etv_pvt;

 

/
