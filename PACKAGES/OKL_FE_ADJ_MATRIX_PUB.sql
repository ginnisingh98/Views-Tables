--------------------------------------------------------
--  DDL for Package OKL_FE_ADJ_MATRIX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FE_ADJ_MATRIX_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPAMS.pls 120.0 2005/07/07 10:41:43 viselvar noship $ */

  -- record structures used in the package

  SUBTYPE okl_pamv_rec IS okl_fe_adj_matrix_pvt.okl_pamv_rec;  -- standard rate template header record

  SUBTYPE okl_pal_rec IS okl_fe_adj_matrix_pvt.okl_pal_rec;  -- standard rate template version record

  SUBTYPE okl_ech_rec IS okl_fe_adj_matrix_pvt.okl_ech_rec;  -- Eligibility Criteria set record

  SUBTYPE okl_ecl_tbl IS okl_fe_adj_matrix_pvt.okl_ecl_tbl;  -- Eligibility Criteria table

  SUBTYPE okl_ecv_tbl IS okl_fe_adj_matrix_pvt.okl_ecv_tbl;  -- Eligibility Criterion values table

  SUBTYPE invalid_object_tbl IS okl_fe_adj_matrix_pvt.invalid_object_tbl;

  ------------------------------------------------------------------------------
  -- Global Variables

  g_pkg_name           CONSTANT VARCHAR2(200) := 'OKL_FE_ADJ_MATRIX_PVT';
  g_app_name           CONSTANT VARCHAR2(3)   := okl_api.g_app_name;
  g_unexpected_error   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token      CONSTANT VARCHAR2(200) := 'SQLERRM';
  g_sqlcode_token      CONSTANT VARCHAR2(200) := 'SQLCODE';

  ------------------------------------------------------------------------------
  --Global Exception
  ------------------------------------------------------------------------------

  g_exception_halt_validation EXCEPTION;

  ------------------------------------------------------------------------------
  -- procedure to give the details of the adjustment matrix given the Adjustment
  -- matrix id and the version number

  PROCEDURE get_version(p_api_version    IN            NUMBER
                       ,p_init_msg_list  IN            VARCHAR2     DEFAULT okl_api.g_false
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                       ,x_msg_data          OUT NOCOPY VARCHAR2
                       ,p_adj_mat_id     IN            NUMBER
                       ,p_version_number IN            NUMBER
                       ,x_pamv_rec          OUT NOCOPY okl_pamv_rec
                       ,x_pal_rec           OUT NOCOPY okl_pal_rec
                       ,x_ech_rec           OUT NOCOPY okl_ech_rec
                       ,x_ecl_tbl           OUT NOCOPY okl_ecl_tbl
                       ,x_ecv_tbl           OUT NOCOPY okl_ecv_tbl);

  -- procedure to give the details of the latest version of adjustment matrix
  -- given the adjusment matrix id

  PROCEDURE get_version(p_api_version   IN            NUMBER
                       ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                       ,x_return_status    OUT NOCOPY VARCHAR2
                       ,x_msg_count        OUT NOCOPY NUMBER
                       ,x_msg_data         OUT NOCOPY VARCHAR2
                       ,p_adj_mat_id    IN            NUMBER
                       ,x_pamv_rec         OUT NOCOPY okl_pamv_rec
                       ,x_pal_rec          OUT NOCOPY okl_pal_rec
                       ,x_ech_rec          OUT NOCOPY okl_ech_rec
                       ,x_ecl_tbl          OUT NOCOPY okl_ecl_tbl
                       ,x_ecv_tbl          OUT NOCOPY okl_ecv_tbl);

  -- procedure to create a new version of the Pricing Adjustment Matrix

  PROCEDURE create_version(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_pal_rec       IN            okl_pal_rec
                          ,x_pal_rec          OUT NOCOPY okl_pal_rec);

  --procedure to create a Pricing Adjusment Matrix with the associated adjustment categories

  PROCEDURE insert_adj_mat(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_pamv_rec      IN            okl_pamv_rec
                          ,p_pal_rec       IN            okl_pal_rec
                          ,x_pamv_rec         OUT NOCOPY okl_pamv_rec
                          ,x_pal_rec          OUT NOCOPY okl_pal_rec);

  -- procedure to update a particular version of the Pricing Adjustment matrix

  PROCEDURE update_adj_mat(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_pal_rec       IN            okl_pal_rec
                          ,x_pal_rec          OUT NOCOPY okl_pal_rec);

  -- procedure to raise the workflow which submits the record and changes the status.

  PROCEDURE submit_adj_mat(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_version_id    IN            NUMBER);

  -- procedure to validate the pricing adjustment matrix

  PROCEDURE validate_adj_mat(p_api_version   IN            NUMBER
                            ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                            ,x_return_status    OUT NOCOPY VARCHAR2
                            ,x_msg_count        OUT NOCOPY NUMBER
                            ,x_msg_data         OUT NOCOPY VARCHAR2
                            ,p_pal_rec       IN            okl_pal_rec
                            ,p_ech_rec       IN            okl_ech_rec
                            ,p_ecl_tbl       IN            okl_ecl_tbl
                            ,p_ecv_tbl       IN            okl_ecv_tbl);

  -- procedure to handle when the process is going through the process of approval

  PROCEDURE handle_approval(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_version_id    IN            NUMBER);

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
                           ,p_pal_rec       IN            okl_pal_rec
                           ,x_cal_eff_from     OUT NOCOPY DATE);

END okl_fe_adj_matrix_pub;

 

/
