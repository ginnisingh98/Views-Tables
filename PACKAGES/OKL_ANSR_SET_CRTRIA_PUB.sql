--------------------------------------------------------
--  DDL for Package OKL_ANSR_SET_CRTRIA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_ANSR_SET_CRTRIA_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPASRS.pls 115.3 2002/02/05 12:04:01 pkm ship       $ */



 subtype asrv_rec_type is okl_asr_pvt.asrv_rec_type;
 subtype asrv_tbl_type is okl_asr_pvt.asrv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_ANSR_SET_CRTRIA_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_tbl                     IN  asrv_tbl_type
    ,x_asrv_tbl                     OUT  NOCOPY asrv_tbl_type);

 PROCEDURE insert_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_rec                     IN  asrv_rec_type
    ,x_asrv_rec                     OUT  NOCOPY asrv_rec_type);

 PROCEDURE lock_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_tbl                     IN  asrv_tbl_type);

 PROCEDURE lock_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_rec                     IN  asrv_rec_type);

 PROCEDURE update_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_tbl                     IN  asrv_tbl_type
    ,x_asrv_tbl                     OUT  NOCOPY asrv_tbl_type);

 PROCEDURE update_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_rec                     IN  asrv_rec_type
    ,x_asrv_rec                     OUT  NOCOPY asrv_rec_type);

 PROCEDURE delete_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_tbl                     IN  asrv_tbl_type);

 PROCEDURE delete_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_rec                     IN  asrv_rec_type);

  PROCEDURE validate_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_tbl                     IN  asrv_tbl_type);

 PROCEDURE validate_ansr_set_crtria(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_asrv_rec                     IN  asrv_rec_type);

END okl_ansr_set_crtria_pub;


 

/
