--------------------------------------------------------
--  DDL for Package OKL_ECO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ECO_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSECOS.pls 120.2 2006/12/07 06:10:35 ssdeshpa noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_eco_rec IS RECORD (
    object_class_id       number,
    object_version_number number,
    crit_cat_def_id       number,
    object_class_code     okl_fe_crit_cat_objects.object_class_code%TYPE,
    is_applicable         varchar2(3),
    created_by            number,
    creation_date         okl_fe_crit_cat_objects.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_crit_cat_objects.last_update_date%TYPE,
    last_update_login     number
  );

  TYPE okl_eco_tbl IS TABLE OF okl_eco_rec INDEX BY BINARY_INTEGER;

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

  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_ECO_PVT';
  g_app_name                   CONSTANT varchar2(3) := okl_api.g_app_name;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE change_version;

  PROCEDURE api_copy;

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eco_rec        IN             okl_eco_rec
                      ,x_eco_rec           OUT NOCOPY  okl_eco_rec);

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eco_tbl        IN             okl_eco_tbl
                      ,x_eco_tbl           OUT NOCOPY  okl_eco_tbl);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eco_rec        IN             okl_eco_rec
                      ,x_eco_rec           OUT NOCOPY  okl_eco_rec);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eco_tbl        IN             okl_eco_tbl
                      ,x_eco_tbl           OUT NOCOPY  okl_eco_tbl);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eco_rec        IN             okl_eco_rec);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eco_tbl        IN             okl_eco_tbl);

  PROCEDURE LOAD_SEED_ROW(p_object_class_id       IN VARCHAR2,
	                  p_object_version_number IN VARCHAR2,
	                  p_crit_cat_def_id       IN VARCHAR2,
	                  p_object_class_code     IN VARCHAR2,
                          p_owner                 IN VARCHAR2,
                          p_last_update_date      IN VARCHAR2);

END okl_eco_pvt;

/
