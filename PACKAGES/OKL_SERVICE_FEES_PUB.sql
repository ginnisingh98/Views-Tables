--------------------------------------------------------
--  DDL for Package OKL_SERVICE_FEES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SERVICE_FEES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSVFS.pls 115.2 2002/07/18 18:39:28 rvaduri noship $ */



 subtype SVFv_rec_type is okl_SVF_pvt.SVFv_rec_type;
 subtype SVFv_tbl_type is okl_SVF_pvt.SVFv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_SERVICE_FEES_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_tbl                     IN  SVFv_tbl_type
    ,x_SVFv_tbl                     OUT  NOCOPY SVFv_tbl_type);

 PROCEDURE insert_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_rec                     IN  SVFv_rec_type
    ,x_SVFv_rec                     OUT  NOCOPY SVFv_rec_type);

 PROCEDURE lock_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_tbl                     IN  SVFv_tbl_type);

 PROCEDURE lock_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_rec                     IN  SVFv_rec_type);

 PROCEDURE update_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_tbl                     IN  SVFv_tbl_type
    ,x_SVFv_tbl                     OUT  NOCOPY SVFv_tbl_type);

 PROCEDURE update_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_rec                     IN  SVFv_rec_type
    ,x_SVFv_rec                     OUT  NOCOPY SVFv_rec_type);

 PROCEDURE delete_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_tbl                     IN  SVFv_tbl_type);

 PROCEDURE delete_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_rec                     IN  SVFv_rec_type);

  PROCEDURE validate_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_tbl                     IN  SVFv_tbl_type);

 PROCEDURE validate_SERVICE_FEES(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_SVFv_rec                     IN  SVFv_rec_type);

END okl_service_fees_pub;


 

/
