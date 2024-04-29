--------------------------------------------------------
--  DDL for Package OKL_FE_EO_TERM_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FE_EO_TERM_OPTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPEOTS.pls 120.3 2008/02/29 10:52:16 asawanka ship $ */
/*#
 * End-of-Term Option API allows users to perform actions on
 * End-of-term Options in Lease Management.
 * @rep:scope public
 * @rep:product OKL
 * @rep:displayname End-of-Term Option API
 * @rep:category BUSINESS_ENTITY OKL_EOT
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  -- record structure for the End of Term Options Header

  SUBTYPE okl_ethv_rec IS okl_eth_pvt.okl_ethv_rec;

  SUBTYPE okl_ethv_tbl IS okl_eth_pvt.okl_ethv_tbl;

  -- record structure for the End of Term Options Version Details

  SUBTYPE okl_eve_rec IS okl_eve_pvt.okl_eve_rec;

  SUBTYPE okl_eve_tbl IS okl_eve_pvt.okl_eve_tbl;

  -- record structure for the End of Term Object Values

  SUBTYPE okl_etv_rec IS okl_etv_pvt.okl_etv_rec;

  SUBTYPE okl_etv_tbl IS okl_etv_pvt.okl_etv_tbl;

  -- record structure for the End of Term Option Objects

  SUBTYPE okl_eto_rec IS okl_eto_pvt.okl_eto_rec;

  SUBTYPE okl_eto_tbl IS okl_eto_pvt.okl_eto_tbl;

  SUBTYPE invalid_object_tbl IS okl_fe_eo_term_options_pvt.invalid_object_tbl;  -- Global variables
  g_pkg_name             CONSTANT VARCHAR2(200) := 'OKL_FE_EO_TERM_OPTIONS_PUB';
  g_app_name             CONSTANT VARCHAR2(3)   := okl_api.g_app_name;

  --G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';

  g_exc_name_error       CONSTANT VARCHAR2(50)  := 'OKL_API.G_RET_STS_ERROR';
  g_exc_name_unexp_error CONSTANT VARCHAR2(50)  := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  g_exc_name_others      CONSTANT VARCHAR2(6)   := 'OTHERS';
  g_sqlerrm_token        CONSTANT VARCHAR2(200) := 'SQLERRM';
  g_sqlcode_token        CONSTANT VARCHAR2(200) := 'SQLCODE';

  ------------------------------------------------------------------------------
  --Global Exception
  ------------------------------------------------------------------------------

  g_exception_halt_validation EXCEPTION;

  PROCEDURE get_item_lines(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_po_id         IN            NUMBER
                          ,p_po_version    IN            VARCHAR2
                          ,x_eto_tbl          OUT NOCOPY okl_eto_tbl);

  PROCEDURE get_eo_term_values(p_api_version   IN            NUMBER
                              ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                              ,x_return_status    OUT NOCOPY VARCHAR2
                              ,x_msg_count        OUT NOCOPY NUMBER
                              ,x_msg_data         OUT NOCOPY VARCHAR2
                              ,p_po_id         IN            NUMBER
                              ,p_po_version    IN            VARCHAR2
                              ,x_etv_tbl          OUT NOCOPY okl_etv_tbl);

  PROCEDURE get_end_of_term_option(p_api_version   IN            NUMBER
                                  ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                                  ,x_return_status    OUT NOCOPY VARCHAR2
                                  ,x_msg_count        OUT NOCOPY NUMBER
                                  ,x_msg_data         OUT NOCOPY VARCHAR2
                                  ,p_po_id         IN            NUMBER
                                  ,p_po_version    IN            VARCHAR2
                                  ,x_ethv_rec         OUT NOCOPY okl_ethv_rec
                                  ,x_eve_rec          OUT NOCOPY okl_eve_rec
                                  ,x_eto_tbl          OUT NOCOPY okl_eto_tbl
                                  ,x_etv_tbl          OUT NOCOPY okl_etv_tbl);

  /*#
  * Create End-of-Term Option.
  * @param p_api_version API version
  * @param p_init_msg_list  Initialize message stack
  * @param x_return_status Return status from the API
  * @param x_msg_count Message count if error messages are encountered
  * @param x_msg_data Error message data
  * @param p_ethv_rec End-of-Term Option header record
  * @param p_eve_rec  End-of-Term Option Version record
  * @param p_eto_tbl  End-of-Term Option Objects table
  * @param p_etv_tbl  End-of-Term Option Values table
  * @param x_ethv_rec End-of-Term Option header record
  * @param x_eve_rec  End-of-Term Option Version record
  * @param x_eto_tbl  End-of-Term Option Objects table
  * @param x_etv_tbl  End-of-Term Option Values table
  * @rep:displayname Create End-of-Term Option
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:category BUSINESS_ENTITY OKL_MARKETING_PROGRAM
  */
  PROCEDURE insert_end_of_term_option(p_api_version   IN  NUMBER
                                    ,p_init_msg_list  IN  VARCHAR2     DEFAULT okl_api.g_false
                                    ,x_return_status  OUT NOCOPY VARCHAR2
                                    ,x_msg_count      OUT NOCOPY NUMBER
                                    ,x_msg_data       OUT NOCOPY VARCHAR2
                                    ,p_ethv_rec       IN  okl_ethv_rec
                                    ,p_eve_rec        IN  okl_eve_rec
                                    ,p_eto_tbl        IN  okl_eto_tbl
                                    ,p_etv_tbl        IN  okl_etv_tbl
                                    ,x_ethv_rec       OUT NOCOPY okl_ethv_rec
                                    ,x_eve_rec        OUT NOCOPY okl_eve_rec
                                    ,x_eto_tbl        OUT NOCOPY okl_eto_tbl
                                    ,x_etv_tbl        OUT NOCOPY okl_etv_tbl);

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

  PROCEDURE calc_start_date(p_api_version   IN            NUMBER
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

END okl_fe_eo_term_options_pub;

/
