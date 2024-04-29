--------------------------------------------------------
--  DDL for Package OKL_INS_ASSETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_ASSETS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPINAS.pls 115.2 2002/03/16 20:00:31 pkm ship        $ */



 subtype INAv_rec_type is okl_INA_pvt.INAv_rec_type;
 subtype INAv_tbl_type is okl_INA_pvt.INAv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_INS_ASSETS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  'OKL';
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_tbl                     IN  INAv_tbl_type
    ,x_INAv_tbl                     OUT  NOCOPY INAv_tbl_type);

 PROCEDURE insert_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_rec                     IN  INAv_rec_type
    ,x_INAv_rec                     OUT  NOCOPY INAv_rec_type);

 PROCEDURE lock_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_tbl                     IN  INAv_tbl_type);

 PROCEDURE lock_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_rec                     IN  INAv_rec_type);

 PROCEDURE update_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_tbl                     IN  INAv_tbl_type
    ,x_INAv_tbl                     OUT  NOCOPY INAv_tbl_type);

 PROCEDURE update_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_rec                     IN  INAv_rec_type
    ,x_INAv_rec                     OUT  NOCOPY INAv_rec_type);

 PROCEDURE delete_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_tbl                     IN  INAv_tbl_type);

 PROCEDURE delete_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_rec                     IN  INAv_rec_type);

  PROCEDURE validate_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_tbl                     IN  INAv_tbl_type);

 PROCEDURE validate_INS_ASSETS(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_INAv_rec                     IN  INAv_rec_type);

END okl_ins_assets_pub;


 

/
