--------------------------------------------------------
--  DDL for Package OKL_CRTRN_USER_VALS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CRTRN_USER_VALS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCUVS.pls 115.2 2002/02/05 12:05:16 pkm ship       $ */



 subtype cuvv_rec_type is okl_cuv_pvt.cuvv_rec_type;
 subtype cuvv_tbl_type is okl_cuv_pvt.cuvv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CRTRN_USER_VALS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_tbl                     IN  cuvv_tbl_type
    ,x_cuvv_tbl                     OUT  NOCOPY cuvv_tbl_type);

 PROCEDURE insert_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_rec                     IN  cuvv_rec_type
    ,x_cuvv_rec                     OUT  NOCOPY cuvv_rec_type);

 PROCEDURE lock_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_tbl                     IN  cuvv_tbl_type);

 PROCEDURE lock_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_rec                     IN  cuvv_rec_type);

 PROCEDURE update_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_tbl                     IN  cuvv_tbl_type
    ,x_cuvv_tbl                     OUT  NOCOPY cuvv_tbl_type);

 PROCEDURE update_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_rec                     IN  cuvv_rec_type
    ,x_cuvv_rec                     OUT  NOCOPY cuvv_rec_type);

 PROCEDURE delete_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_tbl                     IN  cuvv_tbl_type);

 PROCEDURE delete_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_rec                     IN  cuvv_rec_type);

  PROCEDURE validate_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_tbl                     IN  cuvv_tbl_type);

 PROCEDURE validate_crtrn_user_vals(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cuvv_rec                     IN  cuvv_rec_type);

END okl_crtrn_user_vals_pub;


 

/
