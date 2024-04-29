--------------------------------------------------------
--  DDL for Package OKL_LRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LRL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSLRLS.pls 120.1 2005/10/30 04:59:27 appldev noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_lrlv_rec IS RECORD (
    rate_set_level_id     number,
    object_version_number number,
    residual_percent      number,
    rate_set_id           number,
    rate_set_version_id   number,
    rate_set_factor_id    number,
    sequence_number       number,
    periods               number,
    lease_rate_factor     number,
    created_by            number,
    creation_date         okl_fe_rate_set_levels_v.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_rate_set_levels_v.last_update_date%TYPE,
    last_update_login     number,
    attribute_category    okl_fe_rate_set_levels_v.attribute_category%TYPE,
    attribute1            okl_fe_rate_set_levels_v.attribute1%TYPE,
    attribute2            okl_fe_rate_set_levels_v.attribute2%TYPE,
    attribute3            okl_fe_rate_set_levels_v.attribute3%TYPE,
    attribute4            okl_fe_rate_set_levels_v.attribute4%TYPE,
    attribute5            okl_fe_rate_set_levels_v.attribute5%TYPE,
    attribute6            okl_fe_rate_set_levels_v.attribute6%TYPE,
    attribute7            okl_fe_rate_set_levels_v.attribute7%TYPE,
    attribute8            okl_fe_rate_set_levels_v.attribute8%TYPE,
    attribute9            okl_fe_rate_set_levels_v.attribute9%TYPE,
    attribute10           okl_fe_rate_set_levels_v.attribute10%TYPE,
    attribute11           okl_fe_rate_set_levels_v.attribute11%TYPE,
    attribute12           okl_fe_rate_set_levels_v.attribute12%TYPE,
    attribute13           okl_fe_rate_set_levels_v.attribute13%TYPE,
    attribute14           okl_fe_rate_set_levels_v.attribute14%TYPE,
    attribute15           okl_fe_rate_set_levels_v.attribute15%TYPE
  );

  TYPE okl_lrlv_tbl IS TABLE OF okl_lrlv_rec INDEX BY BINARY_INTEGER;

  TYPE okl_lrl_rec IS RECORD (
    rate_set_level_id     number,
    object_version_number number,
    residual_percent      number,
    rate_set_id           number,
    rate_set_version_id   number,
    rate_set_factor_id    number,
    sequence_number       number,
    periods               number,
    lease_rate_factor     number,
    created_by            number,
    creation_date         okl_fe_rate_set_levels.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_rate_set_levels.last_update_date%TYPE,
    last_update_login     number,
    attribute_category    okl_fe_rate_set_levels.attribute_category%TYPE,
    attribute1            okl_fe_rate_set_levels.attribute1%TYPE,
    attribute2            okl_fe_rate_set_levels.attribute2%TYPE,
    attribute3            okl_fe_rate_set_levels.attribute3%TYPE,
    attribute4            okl_fe_rate_set_levels.attribute4%TYPE,
    attribute5            okl_fe_rate_set_levels.attribute5%TYPE,
    attribute6            okl_fe_rate_set_levels.attribute6%TYPE,
    attribute7            okl_fe_rate_set_levels.attribute7%TYPE,
    attribute8            okl_fe_rate_set_levels.attribute8%TYPE,
    attribute9            okl_fe_rate_set_levels.attribute9%TYPE,
    attribute10           okl_fe_rate_set_levels.attribute10%TYPE,
    attribute11           okl_fe_rate_set_levels.attribute11%TYPE,
    attribute12           okl_fe_rate_set_levels.attribute12%TYPE,
    attribute13           okl_fe_rate_set_levels.attribute13%TYPE,
    attribute14           okl_fe_rate_set_levels.attribute14%TYPE,
    attribute15           okl_fe_rate_set_levels.attribute15%TYPE
  );

  TYPE okl_lrl_tbl IS TABLE OF okl_lrl_rec INDEX BY BINARY_INTEGER;

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
  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_LRL_PVT';
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
                      ,p_lrlv_rec       IN             okl_lrlv_rec
                      ,x_lrlv_rec          OUT NOCOPY  okl_lrlv_rec);

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrlv_tbl       IN             okl_lrlv_tbl
                      ,x_lrlv_tbl          OUT NOCOPY  okl_lrlv_tbl);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrlv_rec       IN             okl_lrlv_rec
                      ,x_lrlv_rec          OUT NOCOPY  okl_lrlv_rec);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrlv_tbl       IN             okl_lrlv_tbl
                      ,x_lrlv_tbl          OUT NOCOPY  okl_lrlv_tbl);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrlv_rec       IN             okl_lrlv_rec);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_lrlv_tbl       IN             okl_lrlv_tbl);

END okl_lrl_pvt;

 

/
