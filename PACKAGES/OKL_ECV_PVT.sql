--------------------------------------------------------
--  DDL for Package OKL_ECV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ECV_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSECVS.pls 120.1 2005/10/30 04:59:25 appldev noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_ecv_rec IS RECORD (
    criterion_value_id    number,
    object_version_number number,
    criteria_id           number,
    data_type_code        varchar2(30),
    source_yn             varchar2(30),
    value_type_code       varchar2(30),
    operator_code         okl_fe_criterion_values.operator_code%TYPE,
    crit_cat_value1       okl_fe_criterion_values.crit_cat_value1%TYPE,
    crit_cat_value2       okl_fe_criterion_values.crit_cat_value2%TYPE,
    crit_cat_numval1      number,
    crit_cat_numval2      number,
    crit_cat_dateval1     date,
    crit_cat_dateval2     date,
    validate_record       varchar2(1),
    adjustment_factor     number,
    created_by            number,
    creation_date         okl_fe_criterion_values.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_criterion_values.last_update_date%TYPE,
    last_update_login     number,
    attribute_category    okl_fe_criterion_values.attribute_category%TYPE,
    attribute1            okl_fe_criterion_values.attribute1%TYPE,
    attribute2            okl_fe_criterion_values.attribute2%TYPE,
    attribute3            okl_fe_criterion_values.attribute3%TYPE,
    attribute4            okl_fe_criterion_values.attribute4%TYPE,
    attribute5            okl_fe_criterion_values.attribute5%TYPE,
    attribute6            okl_fe_criterion_values.attribute6%TYPE,
    attribute7            okl_fe_criterion_values.attribute7%TYPE,
    attribute8            okl_fe_criterion_values.attribute8%TYPE,
    attribute9            okl_fe_criterion_values.attribute9%TYPE,
    attribute10           okl_fe_criterion_values.attribute10%TYPE,
    attribute11           okl_fe_criterion_values.attribute11%TYPE,
    attribute12           okl_fe_criterion_values.attribute12%TYPE,
    attribute13           okl_fe_criterion_values.attribute13%TYPE,
    attribute14           okl_fe_criterion_values.attribute14%TYPE,
    attribute15           okl_fe_criterion_values.attribute15%TYPE
  );

  TYPE okl_ecv_tbl IS TABLE OF okl_ecv_rec INDEX BY BINARY_INTEGER;

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

  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_ECV_PVT';
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
                      ,p_ecv_rec        IN             okl_ecv_rec
                      ,x_ecv_rec           OUT NOCOPY  okl_ecv_rec);

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_tbl        IN             okl_ecv_tbl
                      ,x_ecv_tbl           OUT NOCOPY  okl_ecv_tbl);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_rec        IN             okl_ecv_rec
                      ,x_ecv_rec           OUT NOCOPY  okl_ecv_rec);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_tbl        IN             okl_ecv_tbl
                      ,x_ecv_tbl           OUT NOCOPY  okl_ecv_tbl);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_rec        IN             okl_ecv_rec);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_ecv_tbl        IN             okl_ecv_tbl);

  FUNCTION validate_record(p_ecv_rec  IN OUT NOCOPY okl_ecv_rec) RETURN varchar2;

END okl_ecv_pvt;

 

/
