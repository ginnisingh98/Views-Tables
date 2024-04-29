--------------------------------------------------------
--  DDL for Package OKL_ECC_DEF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ECC_DEF_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRECCS.pls 120.1 2005/10/30 04:58:55 appldev noship $ */

  SUBTYPE okl_eccv_rec IS okl_ecc_pvt.okl_eccv_rec;

  SUBTYPE okl_eco_rec IS okl_eco_pvt.okl_eco_rec;

  SUBTYPE okl_eco_tbl IS okl_eco_pvt.okl_eco_tbl;

  ------------------------------------------------------------------------------
  -- Global Variables

  g_pkg_name         CONSTANT varchar2(200) := 'OKL_ECC_DEF_PVT';
  g_app_name         CONSTANT varchar2(3) := okl_api.g_app_name;
  g_api_type         CONSTANT varchar2(4) := '_PVT';
  g_unexpected_error CONSTANT varchar2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token    CONSTANT varchar2(200) := 'SQLERRM';
  g_sqlcode_token    CONSTANT varchar2(200) := 'SQLCODE';

  ------------------------------------------------------------------------------
  --Global Exception
  ------------------------------------------------------------------------------

  g_exception_halt_validation EXCEPTION;

  ------------------------------------------------------------------------------

  PROCEDURE create_ecc(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec
                      ,x_eccv_rec          OUT NOCOPY  okl_eccv_rec
                      ,p_eco_tbl        IN             okl_eco_tbl
                      ,x_eco_tbl           OUT NOCOPY  okl_eco_tbl);

  PROCEDURE update_ecc(p_api_version    IN             number
                      ,p_init_msg_list  IN             varchar2     DEFAULT okl_api.g_false
                      ,x_return_status     OUT NOCOPY  varchar2
                      ,x_msg_count         OUT NOCOPY  number
                      ,x_msg_data          OUT NOCOPY  varchar2
                      ,p_eccv_rec       IN             okl_eccv_rec
                      ,x_eccv_rec          OUT NOCOPY  okl_eccv_rec
                      ,p_eco_tbl        IN             okl_eco_tbl
                      ,x_eco_tbl           OUT NOCOPY  okl_eco_tbl);

END okl_ecc_def_pvt;

 

/
