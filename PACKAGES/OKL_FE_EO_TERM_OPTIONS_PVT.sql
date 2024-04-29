--------------------------------------------------------
--  DDL for Package OKL_FE_EO_TERM_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FE_EO_TERM_OPTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLREOTS.pls 120.1 2005/08/25 10:34:50 viselvar noship $ */

  -- record structure for the Purchase Options Header

  SUBTYPE okl_ethv_rec IS okl_eth_pvt.okl_ethv_rec;

  SUBTYPE okl_ethv_tbl IS okl_eth_pvt.okl_ethv_tbl;

  -- record structure for the Purchase Options Version Details

  SUBTYPE okl_eve_rec IS okl_eve_pvt.okl_eve_rec;

  SUBTYPE okl_eve_tbl IS okl_eve_pvt.okl_eve_tbl;

  -- record structure for the Purchase Option Values

  SUBTYPE okl_etv_rec IS okl_etv_pvt.okl_etv_rec;

  SUBTYPE okl_etv_tbl IS okl_etv_pvt.okl_etv_tbl;

  -- record structure for the Purchase Option Lines

  SUBTYPE okl_eto_rec IS okl_eto_pvt.okl_eto_rec;

  SUBTYPE okl_eto_tbl IS okl_eto_pvt.okl_eto_tbl;

  TYPE invalid_object_rec IS RECORD (
    obj_id      NUMBER,
    obj_name    VARCHAR2(240),
    obj_version VARCHAR2(24),
    obj_type    VARCHAR2(20)
  );

  TYPE invalid_object_tbl IS TABLE OF invalid_object_rec
    INDEX BY BINARY_INTEGER;

  SUBTYPE okl_lrs_id_tbl IS okl_lease_rate_Sets_pvt.okl_number_table;  -- Global variables
  g_pkg_name           CONSTANT VARCHAR2(200) := 'OKL_FE_EO_TERM_OPTIONS_PVT';
  g_app_name           CONSTANT VARCHAR2(3)   := okl_api.g_app_name;
  g_unexpected_error   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token      CONSTANT VARCHAR2(200) := 'SQLERRM';
  g_sqlcode_token      CONSTANT VARCHAR2(200) := 'SQLCODE';

  ------------------------------------------------------------------------------
  --Global Exception
  ------------------------------------------------------------------------------

  g_exception_halt_validation EXCEPTION;

  PROCEDURE get_item_lines(p_api_version    IN            NUMBER
                          ,p_init_msg_list  IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status     OUT NOCOPY VARCHAR2
                          ,x_msg_count         OUT NOCOPY NUMBER
                          ,x_msg_data          OUT NOCOPY VARCHAR2
                          ,p_end_of_term_id IN            NUMBER
                          ,p_version        IN            VARCHAR2
                          ,x_eto_tbl           OUT NOCOPY okl_eto_tbl);

  -- Get the values of the Purchase Options

  PROCEDURE get_eo_term_values(p_api_version    IN            NUMBER
                              ,p_init_msg_list  IN            VARCHAR2    DEFAULT okl_api.g_false
                              ,x_return_status     OUT NOCOPY VARCHAR2
                              ,x_msg_count         OUT NOCOPY NUMBER
                              ,x_msg_data          OUT NOCOPY VARCHAR2
                              ,p_end_of_term_id IN            NUMBER
                              ,p_version        IN            VARCHAR2
                              ,x_etv_tbl           OUT NOCOPY okl_etv_tbl);

  -- Get the Purchase Option Header, Version, values and Values

  PROCEDURE get_end_of_term_option(p_api_version   IN            NUMBER
                                  ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                                  ,x_return_status    OUT NOCOPY VARCHAR2
                                  ,x_msg_count        OUT NOCOPY NUMBER
                                  ,x_msg_data         OUT NOCOPY VARCHAR2
                                  ,p_eot_id        IN            NUMBER
                                  ,p_version       IN            VARCHAR2
                                  ,x_ethv_rec         OUT NOCOPY okl_ethv_rec
                                  ,x_eve_rec          OUT NOCOPY okl_eve_rec
                                  ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                                  ,x_etv_tbl          OUT NOCOPY okl_etv_tbl);

  PROCEDURE insert_end_of_term_option(p_api_version   IN            NUMBER
                                     ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                                     ,x_return_status    OUT NOCOPY VARCHAR2
                                     ,x_msg_count        OUT NOCOPY NUMBER
                                     ,x_msg_data         OUT NOCOPY VARCHAR2
                                     ,p_ethv_rec      IN            okl_ethv_rec
                                     ,p_eve_rec       IN            okl_eve_rec
                                     ,p_eto_tbl       IN            okl_eto_tbl
                                     ,p_etv_tbl       IN            okl_etv_tbl
                                     ,x_ethv_rec         OUT NOCOPY okl_ethv_rec
                                     ,x_eve_rec          OUT NOCOPY okl_eve_rec
                                     ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                                     ,x_etv_tbl          OUT NOCOPY okl_etv_tbl);

  PROCEDURE update_end_of_term_option(p_api_version   IN            NUMBER
                                     ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                                     ,x_return_status    OUT NOCOPY VARCHAR2
                                     ,x_msg_count        OUT NOCOPY NUMBER
                                     ,x_msg_data         OUT NOCOPY VARCHAR2
                                     ,p_eve_rec       IN            okl_eve_rec
                                     ,p_eto_tbl       IN            okl_eto_tbl
                                     ,p_etv_tbl       IN            okl_etv_tbl
                                     ,x_eve_rec          OUT NOCOPY okl_eve_rec
                                     ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                                     ,x_etv_tbl          OUT NOCOPY okl_etv_tbl);

  PROCEDURE create_version(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_eve_rec       IN            okl_eve_rec
                          ,p_eto_tbl       IN            okl_eto_tbl
                          ,p_etv_tbl       IN            okl_etv_tbl
                          ,x_eve_rec          OUT NOCOPY okl_eve_rec
                          ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                          ,x_etv_tbl          OUT NOCOPY okl_etv_tbl);

  PROCEDURE validate_end_of_term_option(p_api_version   IN            NUMBER
                                       ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                                       ,x_return_status    OUT NOCOPY VARCHAR2
                                       ,x_msg_count        OUT NOCOPY NUMBER
                                       ,x_msg_data         OUT NOCOPY VARCHAR2
                                       ,p_end_of_ver_id IN            NUMBER);

  PROCEDURE handle_approval(p_api_version        IN            NUMBER
                           ,p_init_msg_list      IN            VARCHAR2 DEFAULT okl_api.g_false
                           ,x_return_status         OUT NOCOPY VARCHAR2
                           ,x_msg_count             OUT NOCOPY NUMBER
                           ,x_msg_data              OUT NOCOPY VARCHAR2
                           ,p_end_of_term_ver_id IN            NUMBER);

  -- to find the list of all the invalid object refernces

  PROCEDURE invalid_objects(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2           DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_version_id    IN            NUMBER
                           ,x_obj_tbl          OUT NOCOPY invalid_object_tbl);

  -- to calculate the start date of the new version

  PROCEDURE calculate_start_date(p_api_version   IN            NUMBER
                                ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                                ,x_return_status    OUT NOCOPY VARCHAR2
                                ,x_msg_count        OUT NOCOPY NUMBER
                                ,x_msg_data         OUT NOCOPY VARCHAR2
                                ,p_eve_rec       IN            okl_eve_rec
                                ,x_cal_eff_from     OUT NOCOPY DATE);

  PROCEDURE submit_end_of_term(p_api_version        IN            NUMBER
                              ,p_init_msg_list      IN            VARCHAR2 DEFAULT okl_api.g_false
                              ,x_return_status         OUT NOCOPY VARCHAR2
                              ,x_msg_count             OUT NOCOPY NUMBER
                              ,x_msg_data              OUT NOCOPY VARCHAR2
                              ,p_end_of_term_ver_id IN            NUMBER);

END okl_fe_eo_term_options_pvt;

 

/
