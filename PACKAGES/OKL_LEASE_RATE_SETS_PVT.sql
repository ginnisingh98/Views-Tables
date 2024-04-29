--------------------------------------------------------
--  DDL for Package OKL_LEASE_RATE_SETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_RATE_SETS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLRSS.pls 120.1 2005/10/30 04:59:07 appldev noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC CONSTANTS
  -----------------------------------------------------------------------------

  g_pkg_name            CONSTANT varchar2(30) := 'okl_lease_rate_sets_pvt';
  g_api_type            CONSTANT varchar2(4) := '_PVT';

  -----------------------------------------------------------------------------
  -- APPLICATION GLOBAL CONSTANTS
  -----------------------------------------------------------------------------

  g_app_name            CONSTANT varchar2(3) := okl_api.g_app_name;
  g_api_version         CONSTANT number := 1;
  g_false               CONSTANT varchar2(1) := fnd_api.g_false;
  g_true                CONSTANT varchar2(1) := fnd_api.g_true;
  g_db_error            CONSTANT varchar2(12) := 'OKL_DB_ERROR';
  g_prog_name_token     CONSTANT varchar2(9) := 'PROG_NAME';
  g_sqlcode_token       CONSTANT varchar2(7) := 'SQLCODE';
  g_sqlerrm_token       CONSTANT varchar2(7) := 'SQLERRM';
  g_ret_sts_success     CONSTANT varchar2(1) := fnd_api.g_ret_sts_success;
  g_ret_sts_unexp_error CONSTANT varchar2(1) := fnd_api.g_ret_sts_unexp_error;
  g_ret_sts_error       CONSTANT varchar2(1) := fnd_api.g_ret_sts_error;
  g_miss_char           CONSTANT varchar2(1) := fnd_api.g_miss_char;

  ---------------------------------------------------------------------------
  -- DATA STRUCTURES
  ---------------------------------------------------------------------------

  SUBTYPE lrtv_rec_type IS okl_lrt_pvt.lrtv_rec_type;

  SUBTYPE lrtv_tbl_type IS okl_lrt_pvt.lrtv_tbl_type;

  SUBTYPE okl_lrvv_rec IS okl_lrv_pvt.okl_lrvv_rec;

  SUBTYPE lrfv_tbl_type IS okl_lrf_pvt.lrfv_tbl_type;

  SUBTYPE okl_lrlv_tbl IS okl_lrl_pvt.okl_lrlv_tbl;

  SUBTYPE okl_ech_rec IS okl_ech_pvt.okl_ech_rec;

  SUBTYPE okl_ecl_tbl IS okl_ecl_pvt.okl_ecl_tbl;

  SUBTYPE okl_ecv_tbl IS okl_ecv_pvt.okl_ecv_tbl;

  TYPE okl_number_table IS TABLE OF number INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------

  PROCEDURE create_lease_rate_set(p_api_version    IN             number
                                 ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                 ,x_return_status     OUT NOCOPY  varchar2
                                 ,x_msg_count         OUT NOCOPY  number
                                 ,x_msg_data          OUT NOCOPY  varchar2
                                 ,p_lrtv_rec       IN             lrtv_rec_type
                                 ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                 ,p_lrvv_rec       IN             okl_lrvv_rec
                                 ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE update_lease_rate_set(p_api_version    IN             number
                                 ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                 ,x_return_status     OUT NOCOPY  varchar2
                                 ,x_msg_count         OUT NOCOPY  number
                                 ,x_msg_data          OUT NOCOPY  varchar2
                                 ,p_lrtv_rec       IN             lrtv_rec_type
                                 ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                 ,p_lrvv_rec       IN             okl_lrvv_rec
                                 ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE version_lease_rate_set(p_api_version    IN             number
                                  ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                  ,x_return_status     OUT NOCOPY  varchar2
                                  ,x_msg_count         OUT NOCOPY  number
                                  ,x_msg_data          OUT NOCOPY  varchar2
                                  ,p_lrtv_rec       IN             lrtv_rec_type
                                  ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                  ,p_lrvv_rec       IN             okl_lrvv_rec
                                  ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  FUNCTION get_newversion_effective_from(p_lrv_id   number) RETURN date;

  PROCEDURE submit_lease_rate_set(p_api_version          IN             number
                                 ,p_init_msg_list        IN             varchar2                                          DEFAULT okl_api.g_false
                                 ,x_return_status           OUT NOCOPY  varchar2
                                 ,x_msg_count               OUT NOCOPY  number
                                 ,x_msg_data                OUT NOCOPY  varchar2
                                 ,p_rate_set_version_id  IN             okl_fe_rate_set_versions.rate_set_version_id%TYPE);

  PROCEDURE activate_lease_rate_set(p_api_version          IN             number
                                   ,p_init_msg_list        IN             varchar2                                          DEFAULT okl_api.g_false
                                   ,x_return_status           OUT NOCOPY  varchar2
                                   ,x_msg_count               OUT NOCOPY  number
                                   ,x_msg_data                OUT NOCOPY  varchar2
                                   ,p_rate_set_version_id  IN             okl_fe_rate_set_versions.rate_set_version_id%TYPE);

  PROCEDURE create_lrs_gen_lrf(p_api_version    IN             number
                              ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                              ,x_return_status     OUT NOCOPY  varchar2
                              ,x_msg_count         OUT NOCOPY  number
                              ,x_msg_data          OUT NOCOPY  varchar2
                              ,p_lrtv_rec       IN             lrtv_rec_type
                              ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                              ,p_lrvv_rec       IN             okl_lrvv_rec
                              ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE update_lrs_gen_lrf(p_api_version    IN             number
                              ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                              ,x_return_status     OUT NOCOPY  varchar2
                              ,x_msg_count         OUT NOCOPY  number
                              ,x_msg_data          OUT NOCOPY  varchar2
                              ,p_lrtv_rec       IN             lrtv_rec_type
                              ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                              ,p_lrvv_rec       IN             okl_lrvv_rec
                              ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE version_lrs_gen_lrf(p_api_version    IN             number
                               ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                               ,x_return_status     OUT NOCOPY  varchar2
                               ,x_msg_count         OUT NOCOPY  number
                               ,x_msg_data          OUT NOCOPY  varchar2
                               ,p_lrtv_rec       IN             lrtv_rec_type
                               ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                               ,p_lrvv_rec       IN             okl_lrvv_rec
                               ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE create_lrs_gen_lrf_submit(p_api_version    IN             number
                                     ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                     ,x_return_status     OUT NOCOPY  varchar2
                                     ,x_msg_count         OUT NOCOPY  number
                                     ,x_msg_data          OUT NOCOPY  varchar2
                                     ,p_lrtv_rec       IN             lrtv_rec_type
                                     ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                     ,p_lrvv_rec       IN             okl_lrvv_rec
                                     ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE update_lrs_gen_lrf_submit(p_api_version    IN             number
                                     ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                     ,x_return_status     OUT NOCOPY  varchar2
                                     ,x_msg_count         OUT NOCOPY  number
                                     ,x_msg_data          OUT NOCOPY  varchar2
                                     ,p_lrtv_rec       IN             lrtv_rec_type
                                     ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                     ,p_lrvv_rec       IN             okl_lrvv_rec
                                     ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE version_lrs_gen_lrf_submit(p_api_version    IN             number
                                      ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                      ,x_return_status     OUT NOCOPY  varchar2
                                      ,x_msg_count         OUT NOCOPY  number
                                      ,x_msg_data          OUT NOCOPY  varchar2
                                      ,p_lrtv_rec       IN             lrtv_rec_type
                                      ,x_lrtv_rec          OUT NOCOPY  lrtv_rec_type
                                      ,p_lrvv_rec       IN             okl_lrvv_rec
                                      ,x_lrvv_rec          OUT NOCOPY  okl_lrvv_rec);

  PROCEDURE validate_eot_version(p_api_version          IN             number
                                ,p_init_msg_list        IN             varchar2 DEFAULT okl_api.g_false
                                ,x_return_status           OUT NOCOPY  varchar2
                                ,x_msg_count               OUT NOCOPY  number
                                ,x_msg_data                OUT NOCOPY  varchar2
                                ,p_eot_id               IN             number
                                ,p_effective_from       IN             date
                                ,p_eot_ver_id           IN             number
                                ,p_rate_set_version_id  IN             number
                                ,x_eot_ver_id              OUT NOCOPY  number
                                ,x_version_number          OUT NOCOPY  varchar2);

  PROCEDURE enddate_lease_rate_set(p_api_version    IN             number
                                  ,p_init_msg_list  IN             varchar2         DEFAULT okl_api.g_false
                                  ,x_return_status     OUT NOCOPY  varchar2
                                  ,x_msg_count         OUT NOCOPY  number
                                  ,x_msg_data          OUT NOCOPY  varchar2
                                  ,p_lrv_id_tbl     IN             okl_number_table
                                  ,p_end_date       IN             date);

END okl_lease_rate_sets_pvt;

 

/
