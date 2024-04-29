--------------------------------------------------------
--  DDL for Package OKL_ECC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ECC_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPECUS.pls 120.1 2005/08/23 05:38:47 asawanka noship $ */

  ------------------------------------------------------------------------------
  -- data structures  declaration
  ------------------------------------------------------------------------------
  SUBTYPE okl_ec_rec_type IS okl_ec_evaluate_pvt.okl_ec_rec_type;

  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  g_pkg_name         CONSTANT varchar2(200) := 'OKL_ECC_PUB';
  g_app_name         CONSTANT varchar2(3) := okl_api.g_app_name;
  g_unexpected_error CONSTANT varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token    CONSTANT varchar2(200) := 'SQLERRM';
  g_sqlcode_token    CONSTANT varchar2(200) := 'SQLCODE';

  --------------------------------------------------------------------------------
  -- Procedures and Functions
  --------------------------------------------------------------------------------

  PROCEDURE evaluate_eligibility_criteria(
                                          p_api_version                  IN              number
                                         ,p_init_msg_list                IN              varchar2 DEFAULT okl_api.g_false
                                         ,x_return_status                     OUT nocopy varchar2
                                         ,x_msg_count                         OUT nocopy number
                                         ,x_msg_data                          OUT nocopy varchar2
                                         ,p_okl_ec_rec                   IN   OUT nocopy okl_ec_rec_type
                                         ,x_eligible                          OUT nocopy boolean
                                         );

  FUNCTION compare_eligibility_criteria(p_source_id1    IN  number
                                       ,p_source_type1  IN  varchar2
                                       ,p_source_id2    IN  number
                                       ,p_source_type2  IN  varchar2) RETURN boolean;

END okl_ecc_pub;

 

/
