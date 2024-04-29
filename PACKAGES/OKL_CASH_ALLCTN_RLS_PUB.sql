--------------------------------------------------------
--  DDL for Package OKL_CASH_ALLCTN_RLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_ALLCTN_RLS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCATS.pls 115.6 2002/02/05 12:04:41 pkm ship       $ */

 SUBTYPE catv_rec_type IS Okl_Cat_Pvt.catv_rec_type;
 SUBTYPE catv_tbl_type IS Okl_Cat_Pvt.catv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CASH_ALLCTN_RLS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_tbl                     IN  catv_tbl_type
    ,x_catv_tbl                     OUT  NOCOPY catv_tbl_type);

 PROCEDURE insert_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_rec                     IN  catv_rec_type
    ,x_catv_rec                     OUT  NOCOPY catv_rec_type);

 PROCEDURE lock_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_tbl                     IN  catv_tbl_type);

 PROCEDURE lock_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_rec                     IN  catv_rec_type);

 PROCEDURE update_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_tbl                     IN  catv_tbl_type
    ,x_catv_tbl                     OUT  NOCOPY catv_tbl_type);

 PROCEDURE update_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_rec                     IN  catv_rec_type
    ,x_catv_rec                     OUT  NOCOPY catv_rec_type);

 PROCEDURE delete_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_tbl                     IN  catv_tbl_type);

 PROCEDURE delete_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_rec                     IN  catv_rec_type);

  PROCEDURE validate_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_tbl                     IN  catv_tbl_type);

 PROCEDURE validate_cash_allctn_rls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_catv_rec                     IN  catv_rec_type);

END Okl_Cash_Allctn_Rls_Pub;

 

/
