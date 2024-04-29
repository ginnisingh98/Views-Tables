--------------------------------------------------------
--  DDL for Package OKL_FE_STD_RATE_TMPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FE_STD_RATE_TMPL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSRTS.pls 120.0 2005/07/07 10:42:03 viselvar noship $ */

  -- record structures used in the package

  SUBTYPE okl_srtv_rec IS okl_fe_std_rate_tmpl_pvt.okl_srtv_rec;  -- standard rate template header record

  SUBTYPE okl_srv_rec IS okl_fe_std_rate_tmpl_pvt.okl_srv_rec;  -- standard rate template version record

  SUBTYPE okl_ech_rec IS okl_fe_std_rate_tmpl_pvt.okl_ech_rec;  -- Eligibility Criteria set record

  SUBTYPE okl_ecl_tbl IS okl_fe_std_rate_tmpl_pvt.okl_ecl_tbl;  -- Eligibility Criteria table

  SUBTYPE okl_ecv_tbl IS okl_fe_std_rate_tmpl_pvt.okl_ecv_tbl;  -- Eligibility Criterion values table

  SUBTYPE invalid_object_tbl IS okl_fe_std_rate_tmpl_pvt.invalid_object_tbl;

  ------------------------------------------------------------------------------
  -- Global Variables

  g_pkg_name           CONSTANT VARCHAR2(200) := 'OKL_FE_STD_RATE_TMP_PUB';
  g_app_name           CONSTANT VARCHAR2(3)   := okl_api.g_app_name;
  g_unexpected_error   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token      CONSTANT VARCHAR2(200) := 'SQLERRM';
  g_sqlcode_token      CONSTANT VARCHAR2(200) := 'SQLCODE';

  ------------------------------------------------------------------------------
  --Global Exception
  ------------------------------------------------------------------------------

  g_exception_halt_validation EXCEPTION;

  ------------------------------------------------------------------------------
  -- procedure to give the details of the Standard Rate Template
  --given the Standard Rate Template id and the version number

  PROCEDURE get_version(p_api_version    IN            NUMBER
                       ,p_init_msg_list  IN            VARCHAR2     DEFAULT okl_api.g_false
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                       ,x_msg_data          OUT NOCOPY VARCHAR2
                       ,p_srt_id         IN            NUMBER
                       ,p_version_number IN            NUMBER
                       ,x_srtv_rec          OUT NOCOPY okl_srtv_rec
                       ,x_srv_rec           OUT NOCOPY okl_srv_rec
                       ,x_ech_rec           OUT NOCOPY okl_ech_rec
                       ,x_ecl_tbl           OUT NOCOPY okl_ecl_tbl
                       ,x_ecv_tbl           OUT NOCOPY okl_ecv_tbl);

  -- procedure to give the details of the latest version of Standard Rate Template
  -- given the Standard Rate Template Id

  PROCEDURE get_version(p_api_version   IN            NUMBER
                       ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                       ,x_return_status    OUT NOCOPY VARCHAR2
                       ,x_msg_count        OUT NOCOPY NUMBER
                       ,x_msg_data         OUT NOCOPY VARCHAR2
                       ,p_srt_id        IN            NUMBER
                       ,x_srtv_rec         OUT NOCOPY okl_srtv_rec
                       ,x_srv_rec          OUT NOCOPY okl_srv_rec
                       ,x_ech_rec          OUT NOCOPY okl_ech_rec
                       ,x_ecl_tbl          OUT NOCOPY okl_ecl_tbl
                       ,x_ecv_tbl          OUT NOCOPY okl_ecv_tbl);

  -- procedure to create a new version of the Standard Rate Template

  PROCEDURE create_version(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_srv_rec       IN            okl_srv_rec
                          ,x_srv_rec          OUT NOCOPY okl_srv_rec);

  --procedure to create a Standard Rate Template with the associated Eligibility Criteria

  PROCEDURE insert_srt(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srtv_rec      IN            okl_srtv_rec
                      ,p_srv_rec       IN            okl_srv_rec
                      ,x_srtv_rec         OUT NOCOPY okl_srtv_rec
                      ,x_srv_rec          OUT NOCOPY okl_srv_rec);

  -- procedure to update a particular version of the Standard Rate Template

  PROCEDURE update_srt(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srv_rec       IN            okl_srv_rec
                      ,x_srv_rec          OUT NOCOPY okl_srv_rec);

  -- procedure to raise the workflow which submits the record and changes the status.

  PROCEDURE submit_srt(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_version_id    IN            NUMBER);

  -- procedure to handle when the process is going through the process of approval

  PROCEDURE handle_approval(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_version_id    IN            NUMBER);

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
                           ,p_srv_rec       IN            okl_srv_rec
                           ,x_cal_eff_from     OUT NOCOPY DATE);

  -- procedure to set the default Standard Rate Template

  PROCEDURE update_default(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_srt_id        IN            NUMBER);

END okl_fe_std_rate_tmpl_pub;

 

/