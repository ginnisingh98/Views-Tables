--------------------------------------------------------
--  DDL for Package OKL_ECC_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ECC_VALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRECVS.pls 120.1 2005/09/23 07:18:18 asawanka noship $ */

  ------------------------------------------------------------------------------
  -- data structures  declaration
  ------------------------------------------------------------------------------
  SUBTYPE okl_ech_rec IS okl_ech_pvt.okl_ech_rec;

  SUBTYPE okl_ecl_rec IS okl_ecl_pvt.okl_ecl_rec;

  SUBTYPE okl_ecv_rec IS okl_ecv_pvt.okl_ecv_rec;

  SUBTYPE okl_ecl_tbl IS okl_ecl_pvt.okl_ecl_tbl;

  SUBTYPE okl_ecv_tbl IS okl_ecv_pvt.okl_ecv_tbl;

  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  g_pkg_name         CONSTANT varchar2(200) := 'OKL_ECC_VALUES_PVT';
  g_api_type         CONSTANT varchar2(4) := '_PVT';
  g_app_name         CONSTANT varchar2(3) := okl_api.g_app_name;
  g_unexpected_error CONSTANT varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token    CONSTANT varchar2(200) := 'SQLERRM';
  g_sqlcode_token    CONSTANT varchar2(200) := 'SQLCODE';

  ------------------------------------------------------------------------------
  --Global Exception
  ------------------------------------------------------------------------------

  g_exception_halt_validation EXCEPTION;

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE remove_ec_line(p_api_version    IN             number
                          ,p_init_msg_list  IN             varchar2    DEFAULT okl_api.g_false
                          ,x_return_status     OUT NOCOPY  varchar2
                          ,x_msg_count         OUT NOCOPY  number
                          ,x_msg_data          OUT NOCOPY  varchar2
                          ,p_ecl_rec        IN             okl_ecl_rec);

  PROCEDURE handle_eligibility_criteria(p_api_version      IN             number
                                       ,p_init_msg_list    IN             varchar2    DEFAULT okl_api.g_false
                                       ,x_return_status       OUT NOCOPY  varchar2
                                       ,x_msg_count           OUT NOCOPY  number
                                       ,x_msg_data            OUT NOCOPY  varchar2
                                       ,p_ech_rec          IN             okl_ech_rec
                                       ,x_ech_rec             OUT NOCOPY  okl_ech_rec
                                       ,p_ecl_tbl          IN             okl_ecl_tbl
                                       ,x_ecl_tbl             OUT NOCOPY  okl_ecl_tbl
                                       ,p_ecv_tbl          IN             okl_ecv_tbl
                                       ,x_ecv_tbl             OUT NOCOPY  okl_ecv_tbl
                                       ,p_source_eff_from  IN             date
                                       ,p_source_eff_to    IN             date);

  PROCEDURE get_eligibility_criteria(p_api_version    IN             number
                                    ,p_init_msg_list  IN             varchar2    DEFAULT fnd_api.g_false
                                    ,x_return_status     OUT NOCOPY  varchar2
                                    ,x_msg_count         OUT NOCOPY  number
                                    ,x_msg_data          OUT NOCOPY  varchar2
                                    ,p_source_id      IN             number
                                    ,p_source_type    IN             varchar2
                                    ,p_eff_from       IN             date
                                    ,p_eff_to         IN             date
                                    ,x_ech_rec           OUT NOCOPY  okl_ech_rec
                                    ,x_ecl_tbl           OUT NOCOPY  okl_ecl_tbl
                                    ,x_ecv_tbl           OUT NOCOPY  okl_ecv_tbl);

  PROCEDURE get_eligibility_criteria(p_api_version    IN             number
                                    ,p_init_msg_list  IN             varchar2    DEFAULT fnd_api.g_false
                                    ,x_return_status     OUT NOCOPY  varchar2
                                    ,x_msg_count         OUT NOCOPY  number
                                    ,x_msg_data          OUT NOCOPY  varchar2
                                    ,p_source_id      IN             number
                                    ,p_source_type    IN             varchar2
                                    ,x_ech_rec           OUT NOCOPY  okl_ech_rec
                                    ,x_ecl_tbl           OUT NOCOPY  okl_ecl_tbl
                                    ,x_ecv_tbl           OUT NOCOPY  okl_ecv_tbl);

  PROCEDURE delete_eligibility_criteria(p_api_version    IN             number
                                       ,p_init_msg_list  IN             varchar2 DEFAULT fnd_api.g_false
                                       ,x_return_status     OUT NOCOPY  varchar2
                                       ,x_msg_count         OUT NOCOPY  number
                                       ,x_msg_data          OUT NOCOPY  varchar2
                                       ,p_source_id      IN             number
                                       ,p_source_type    IN             varchar2);

  PROCEDURE end_date_eligibility_criteria(p_api_version    IN             number
                                         ,p_init_msg_list  IN             varchar2 DEFAULT fnd_api.g_false
                                         ,x_return_status     OUT NOCOPY  varchar2
                                         ,x_msg_count         OUT NOCOPY  number
                                         ,x_msg_data          OUT NOCOPY  varchar2
                                         ,p_source_id      IN             number
                                         ,p_source_type    IN             varchar2
                                         ,p_end_date       IN             date);

END okl_ecc_values_pvt;

 

/
