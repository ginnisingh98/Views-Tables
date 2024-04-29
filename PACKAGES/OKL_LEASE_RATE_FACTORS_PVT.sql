--------------------------------------------------------
--  DDL for Package OKL_LEASE_RATE_FACTORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LEASE_RATE_FACTORS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLRFS.pls 120.1 2005/09/30 11:00:47 asawanka noship $ */

  -----------------------------------------------------------------------------
  -- PACKAGE SPECIFIC CONSTANTS
  -----------------------------------------------------------------------------

  g_pkg_name            CONSTANT varchar2(30) := 'okl_lease_rate_factors_pvt';
  g_api_type            CONSTANT varchar2(4) := '_PUB';

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

  SUBTYPE okl_lrvv_rec IS okl_lrv_pvt.okl_lrvv_rec;

  SUBTYPE lrfv_rec_type IS okl_lrf_pvt.lrfv_rec_type;

  SUBTYPE lrfv_tbl_type IS okl_lrf_pvt.lrfv_tbl_type;

  SUBTYPE okl_lrlv_tbl IS okl_lrl_pvt.okl_lrlv_tbl;

  SUBTYPE okl_lrlv_rec IS okl_lrl_pvt.okl_lrlv_rec;

  ---------------------------------------------------------------------------
  -- PROGRAM UNITS
  ---------------------------------------------------------------------------

  PROCEDURE handle_lrf_ents(p_api_version    IN             number
                           ,p_init_msg_list  IN             varchar2      DEFAULT fnd_api.g_false
                           ,x_return_status     OUT NOCOPY  varchar2
                           ,x_msg_count         OUT NOCOPY  number
                           ,x_msg_data          OUT NOCOPY  varchar2
                           ,p_lrfv_tbl       IN             lrfv_tbl_type
                           ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type
                           ,p_lrlv_tbl       IN             okl_lrlv_tbl
                           ,x_lrlv_tbl          OUT NOCOPY  okl_lrlv_tbl);

  PROCEDURE delete_lease_rate_factors(p_api_version    IN             number
                                     ,p_init_msg_list  IN             varchar2 DEFAULT fnd_api.g_false
                                     ,x_return_status     OUT NOCOPY  varchar2
                                     ,x_msg_count         OUT NOCOPY  number
                                     ,x_msg_data          OUT NOCOPY  varchar2
                                     ,p_lrv_id         IN             number);

  PROCEDURE remove_lrs_factor (p_api_version    IN             number
                              ,p_init_msg_list  IN             varchar2      DEFAULT fnd_api.g_false
                              ,x_return_status     OUT NOCOPY  varchar2
                              ,x_msg_count         OUT NOCOPY  number
                              ,x_msg_data          OUT NOCOPY  varchar2
                              ,p_lrfv_rec       IN             lrfv_rec_type);

  PROCEDURE remove_lrs_level(p_api_version    IN             number
                            ,p_init_msg_list  IN             varchar2     DEFAULT fnd_api.g_false
                            ,x_return_status     OUT NOCOPY  varchar2
                            ,x_msg_count         OUT NOCOPY  number
                            ,x_msg_data          OUT NOCOPY  varchar2
                            ,p_lrlv_rec       IN             okl_lrlv_rec);

  PROCEDURE handle_lease_rate_factors(p_api_version    IN             number
                                     ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                                     ,x_return_status     OUT NOCOPY  varchar2
                                     ,x_msg_count         OUT NOCOPY  number
                                     ,x_msg_data          OUT NOCOPY  varchar2
                                     ,p_lrtv_rec       IN             lrtv_rec_type
                                     ,p_lrvv_rec       IN             okl_lrvv_rec
                                     ,p_lrfv_tbl       IN             lrfv_tbl_type
                                     ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type
                                     ,p_lrlv_tbl       IN             okl_lrlv_tbl
                                     ,x_lrlv_tbl          OUT NOCOPY  okl_lrlv_tbl);

  PROCEDURE handle_lrf_submit(p_api_version    IN             number
                             ,p_init_msg_list  IN             varchar2      DEFAULT okl_api.g_false
                             ,x_return_status     OUT NOCOPY  varchar2
                             ,x_msg_count         OUT NOCOPY  number
                             ,x_msg_data          OUT NOCOPY  varchar2
                             ,p_lrtv_rec       IN             lrtv_rec_type
                             ,p_lrvv_rec       IN             okl_lrvv_rec
                             ,p_lrfv_tbl       IN             lrfv_tbl_type
                             ,x_lrfv_tbl          OUT NOCOPY  lrfv_tbl_type
                             ,p_lrlv_tbl       IN             okl_lrlv_tbl
                             ,x_lrlv_tbl          OUT NOCOPY  okl_lrlv_tbl);

FUNCTION get_rate_from_srt(p_srt_version_id  IN  number
                            ,p_lrs_eff_from    IN  date) RETURN number;

END okl_lease_rate_factors_pvt;

 

/
