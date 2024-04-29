--------------------------------------------------------
--  DDL for Package OKL_ECC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ECC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSECCS.pls 120.3 2006/12/07 06:10:03 ssdeshpa noship $ */

  --------------------------------------------------------------------------------
  --GLOBAL DATASTRUCTURES
  --------------------------------------------------------------------------------

  TYPE okl_eccv_rec IS RECORD (
    crit_cat_def_id       number,
    object_version_number number,
    ecc_ac_flag           okl_fe_crit_cat_def_v.ecc_ac_flag%TYPE,
    orig_crit_cat_def_id  number,
    crit_cat_name         okl_fe_crit_cat_def_v.crit_cat_name%TYPE,
    crit_cat_desc         okl_fe_crit_cat_def_v.crit_cat_desc%TYPE,
    sfwt_flag             okl_fe_crit_cat_def_v.sfwt_flag%TYPE,
    value_type_code       okl_fe_crit_cat_def_v.value_type_code%TYPE,
    data_type_code        okl_fe_crit_cat_def_v.data_type_code%TYPE,
    enabled_yn            okl_fe_crit_cat_def_v.enabled_yn%TYPE,
    seeded_yn             okl_fe_crit_cat_def_v.seeded_yn%TYPE,
    function_id           okl_fe_crit_cat_def_v.function_id%TYPE,
    source_yn             okl_fe_crit_cat_def_v.source_yn%TYPE,
    sql_statement         okl_fe_crit_cat_def_v.sql_statement%TYPE,
    created_by            number,
    creation_date         okl_fe_crit_cat_def_v.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_crit_cat_def_v.last_update_date%TYPE,
    last_update_login     number
  );

  TYPE okl_eccv_tbl IS TABLE OF okl_eccv_rec INDEX BY BINARY_INTEGER;

  TYPE okl_eccb_rec IS RECORD (
    crit_cat_def_id       number,
    object_version_number number,
    crit_cat_name         okl_fe_crit_cat_def_b.crit_cat_name%TYPE,
    ecc_ac_flag           okl_fe_crit_cat_def_b.ecc_ac_flag%TYPE,
    orig_crit_cat_def_id  number,
    value_type_code       okl_fe_crit_cat_def_b.value_type_code%TYPE,
    data_type_code        okl_fe_crit_cat_def_b.data_type_code%TYPE,
    enabled_yn            okl_fe_crit_cat_def_b.enabled_yn%TYPE,
    seeded_yn             okl_fe_crit_cat_def_b.seeded_yn%TYPE,
    function_id           okl_fe_crit_cat_def_b.function_id%TYPE,
    source_yn             okl_fe_crit_cat_def_b.source_yn%TYPE,
    sql_statement         okl_fe_crit_cat_def_b.sql_statement%TYPE,
    created_by            number,
    creation_date         okl_fe_crit_cat_def_b.creation_date%TYPE,
    last_updated_by       number,
    last_update_date      okl_fe_crit_cat_def_b.last_update_date%TYPE,
    last_update_login     number
  );

  TYPE okl_eccb_tbl IS TABLE OF okl_eccb_rec INDEX BY BINARY_INTEGER;

  TYPE okl_ecctl_rec IS RECORD (
    crit_cat_def_id   number,
    language          okl_fe_crit_cat_def_tl.language%TYPE,
    source_lang       okl_fe_crit_cat_def_tl.source_lang%TYPE,
    sfwt_flag         okl_fe_crit_cat_def_tl.sfwt_flag%TYPE,
    crit_cat_desc     okl_fe_crit_cat_def_tl.crit_cat_desc%TYPE,
    created_by        number,
    creation_date     okl_fe_crit_cat_def_tl.creation_date%TYPE,
    last_updated_by   number,
    last_update_date  okl_fe_crit_cat_def_tl.last_update_date%TYPE,
    last_update_login number
  );

  TYPE okl_ecctl_tbl IS TABLE OF okl_ecctl_rec INDEX BY BINARY_INTEGER;

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

  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_ECC_PVT';
  g_app_name                   CONSTANT varchar2(3) := okl_api.g_app_name;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE change_version;

  PROCEDURE api_copy;

  PROCEDURE add_language;

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec
                      ,x_eccv_rec          OUT NOCOPY  okl_eccv_rec);

  PROCEDURE insert_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_tbl       IN             okl_eccv_tbl
                      ,x_eccv_tbl          OUT NOCOPY  okl_eccv_tbl);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec
                      ,x_eccv_rec          OUT NOCOPY  okl_eccv_rec);

  PROCEDURE update_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_tbl       IN             okl_eccv_tbl
                      ,x_eccv_tbl          OUT NOCOPY  okl_eccv_tbl);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec);

  PROCEDURE delete_row(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_tbl       IN             okl_eccv_tbl);

  PROCEDURE LOAD_SEED_ROW(p_upload_mode           IN VARCHAR2,
                          p_crit_cat_def_id       IN VARCHAR2,
                	  p_object_version_number IN VARCHAR2,
                	  p_ecc_ac_flag           IN VARCHAR2,
                	  p_crit_cat_name         IN VARCHAR2,
                	  p_orig_crit_cat_def_id  IN VARCHAR2,
                	  p_value_type_code       IN VARCHAR2,
                	  p_data_type_code        IN VARCHAR2,
                	  p_enabled_yn            IN VARCHAR2,
                	  p_seeded_yn             IN VARCHAR2,
                	  p_function_id           IN VARCHAR2,
                	  p_source_yn             IN VARCHAR2,
                	  p_sql_statement         IN VARCHAR2,
                	  p_trans_crit_cat_desc   IN VARCHAR2,
                	  p_owner                 IN VARCHAR2,
                          p_last_update_date      IN VARCHAR2);

END okl_ecc_pvt;

/
