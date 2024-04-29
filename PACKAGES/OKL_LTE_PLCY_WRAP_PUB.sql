--------------------------------------------------------
--  DDL for Package OKL_LTE_PLCY_WRAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LTE_PLCY_WRAP_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPLPWS.pls 120.3 2008/02/29 10:51:29 nikshah ship $ */



 SUBTYPE lpov_rec_type IS Okl_Lpo_Pvt.lpov_rec_type;
 SUBTYPE lpov_tbl_type IS Okl_Lpo_Pvt.lpov_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_LTE_PLCY_WRAP_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE create_late_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_lpov_tbl                     IN  lpov_tbl_type
    ,x_lpov_tbl                     OUT  NOCOPY lpov_tbl_type);

 PROCEDURE create_late_policies(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_lpov_rec                     IN  lpov_rec_type
    ,x_lpov_rec                     OUT  NOCOPY lpov_rec_type);


END OKL_LTE_PLCY_WRAP_PUB;

/
