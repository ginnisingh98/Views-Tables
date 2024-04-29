--------------------------------------------------------
--  DDL for Package OKL_CASH_FLOW_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CASH_FLOW_OBJECTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCFOS.pls 115.0 2003/10/16 01:54:02 sechawla noship $ */



 SUBTYPE cfov_rec_type IS okl_cfo_pvt.cfov_rec_type;
 SUBTYPE cfov_tbl_type IS okl_cfo_pvt.cfov_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_CASH_FLOW_OBJECTS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


   PROCEDURE insert_cash_flow_object(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfov_rec                     IN  cfov_rec_type,
    x_cfov_rec                     OUT NOCOPY cfov_rec_type) ;


  PROCEDURE insert_cash_flow_object(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfov_tbl                     IN cfov_tbl_type,
    x_cfov_tbl                     OUT NOCOPY cfov_tbl_type);

  PROCEDURE lock_cash_flow_object(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfov_rec                     IN cfov_rec_type);


  PROCEDURE lock_cash_flow_object(
     p_api_version                  IN   NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cfov_tbl                     IN   cfov_tbl_type) ;

  PROCEDURE update_cash_flow_object(
     p_api_version                  IN   NUMBER
    ,p_init_msg_list                IN   VARCHAR2  DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cfov_rec                      IN   cfov_rec_type
    ,x_cfov_rec                      OUT  NOCOPY cfov_rec_type);


  PROCEDURE update_cash_flow_object(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfov_tbl                     IN  cfov_tbl_type,
    x_cfov_tbl                     OUT NOCOPY cfov_tbl_type);



  PROCEDURE delete_cash_flow_object(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfov_rec                     IN  cfov_rec_type);

  PROCEDURE delete_cash_flow_object(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfov_tbl                     IN  cfov_tbl_type);

  PROCEDURE validate_cash_flow_object(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfov_rec                     IN cfov_rec_type);


  PROCEDURE  validate_cash_flow_object(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cfov_tbl                     IN cfov_tbl_type) ;

END okl_cash_flow_objects_pub;

 

/
