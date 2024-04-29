--------------------------------------------------------
--  DDL for Package OKL_ECL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ECL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSECLS.pls 120.1 2005/10/30 04:59:18 appldev noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_ecl_rec IS RECORD (
    criteria_id           number,
    object_version_number number,
    criteria_set_id       number,
    crit_cat_def_id       number,
    effective_from_date   okl_fe_criteria.effective_from_date%TYPE,
    effective_to_date     okl_fe_criteria.effective_to_date%TYPE,
    match_criteria_code   okl_fe_criteria.match_criteria_code%TYPE,
    is_new_flag           varchar2(1),
    created_by            number,
    creation_date         okl_fe_criteria.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_criteria.last_update_date%TYPE,
    last_update_login     number
  );

  TYPE okl_ecl_tbl IS TABLE OF okl_ecl_rec INDEX BY BINARY_INTEGER;

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

  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_ECL_PVT';
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
                      ,p_ecl_rec        IN             okl_ecl_rec
                      ,x_ecl_rec           OUT NOCOPY  okl_ecl_rec);

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecl_tbl        IN             okl_ecl_tbl
                      ,x_ecl_tbl           OUT NOCOPY  okl_ecl_tbl);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecl_rec        IN             okl_ecl_rec
                      ,x_ecl_rec           OUT NOCOPY  okl_ecl_rec);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecl_tbl        IN             okl_ecl_tbl
                      ,x_ecl_tbl           OUT NOCOPY  okl_ecl_tbl);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecl_rec        IN             okl_ecl_rec);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecl_tbl        IN             okl_ecl_tbl);

END okl_ecl_pvt;

 

/
