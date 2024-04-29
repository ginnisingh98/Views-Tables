--------------------------------------------------------
--  DDL for Package OKL_LRF_GENERATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LRF_GENERATE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRFGS.pls 120.1 2005/10/30 04:59:09 appldev noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE CONSTANTS
  -----------------------------------------------------------------------------

  g_pkg_name                   CONSTANT varchar2(200) := 'OKL_LRF_GENERATE_PVT';
  g_api_type                   CONSTANT varchar2(4) := '_PVT';
  g_app_name                   CONSTANT varchar2(3) := okl_api.g_app_name;
  g_api_version                CONSTANT number := 1;
  g_false                      CONSTANT varchar2(1) := okl_api.g_false;
  g_true                       CONSTANT varchar2(1) := okl_api.g_true;
  g_db_error                   CONSTANT varchar2(12) := 'OKL_DB_ERROR';
  g_prog_name_token            CONSTANT varchar2(9) := 'PROG_NAME';
  g_sqlcode_token              CONSTANT varchar2(7) := 'SQLCODE';
  g_sqlerrm_token              CONSTANT varchar2(7) := 'SQLERRM';
  g_ret_sts_success            CONSTANT varchar2(1) := okl_api.g_ret_sts_success;
  g_ret_sts_unexp_error        CONSTANT varchar2(1) := okl_api.g_ret_sts_unexp_error;
  g_ret_sts_error              CONSTANT varchar2(1) := okl_api.g_ret_sts_error;
  g_miss_char                  CONSTANT varchar2(1) := okl_api.g_miss_char;
  g_miss_num                   CONSTANT number := okl_api.g_miss_num;
  g_miss_date                  CONSTANT date := okl_api.g_miss_date;
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
  g_cp_mode                             varchar2(1) := 'N';

  SUBTYPE lrfv_tbl_type IS okl_lrf_pvt.lrfv_tbl_type;

  SUBTYPE okl_lrlv_tbl IS okl_lrl_pvt.okl_lrlv_tbl;

  TYPE lease_rate_rec_type IS RECORD (
    term_in_months         number,
    residual_value_percent number(18,15),
    interest_rate          number(18,15),
    lease_rate_factor      number
  );

  TYPE lease_rate_tbl_type IS TABLE OF lease_rate_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE lrv_rec_type IS RECORD (
    arrears_yn          okl_fe_rate_set_versions.arrears_yn%TYPE,
    deferred_pmts       okl_fe_rate_set_versions.deferred_pmts%TYPE,
    advance_pmts        okl_fe_rate_set_versions.advance_pmts%TYPE,
    frequency_code      okl_ls_rt_fctr_sets_b.frq_code%TYPE,
    rate_set_version_id okl_fe_rate_set_versions.rate_set_version_id%TYPE,
    lease_rate_tbl      lease_rate_tbl_type,
    batch_number        number,
    status              varchar2(30)
  );

  PROCEDURE calculate_lrf(p_arrears            IN             number --=1=yes/0=no;
                         ,p_rate               IN             number  --in %
                         ,p_day_convention     IN             number  --30/360
                         ,p_deffered_payments  IN             number
                         ,p_advance_payments   IN             number
                         ,p_term               IN             number
                         ,p_value              IN             number  -- in %(residual value)
                         ,p_frequency          IN             number  -- monthly=1 quarterly=3 semi annual=6 annual=12
                         ,p_lrf                   OUT NOCOPY  number) ;

  PROCEDURE generate_lease_rate_factors(p_api_version          IN             number
                                       ,p_init_msg_list        IN             varchar2                                          DEFAULT fnd_api.g_false
                                       ,x_return_status           OUT NOCOPY  varchar2
                                       ,x_msg_count               OUT NOCOPY  number
                                       ,x_msg_data                OUT NOCOPY  varchar2
                                       ,p_rate_set_version_id                 okl_fe_rate_set_versions.rate_set_version_id%TYPE);

  PROCEDURE generate_lrf(errbuf                    OUT NOCOPY  varchar2
                        ,retcode                   OUT NOCOPY  varchar2
                        ,p_rate_set_version_id  IN             number
                        ,p_start_date           IN             varchar2
                        ,p_end_date             IN             varchar2);

END okl_lrf_generate_pvt;

 

/
