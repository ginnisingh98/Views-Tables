--------------------------------------------------------
--  DDL for Package IEX_OPEN_INT_HST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_OPEN_INT_HST_PUB" AUTHID CURRENT_USER AS
/* $Header: IEXPIOHS.pls 120.3 2004/12/16 15:49:30 jsanju ship $ */



 subtype iohv_rec_type is iex_ioh_pvt.iohv_rec_type;
 subtype iohv_tbl_type is iex_ioh_pvt.iohv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'IEX_OPEN_INT_HST_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_tbl                     IN  iohv_tbl_type
    ,x_iohv_tbl                     OUT  NOCOPY iohv_tbl_type);

 PROCEDURE insert_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_rec                     IN  iohv_rec_type
    ,x_iohv_rec                     OUT  NOCOPY iohv_rec_type);

 PROCEDURE lock_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_tbl                     IN  iohv_tbl_type);

 PROCEDURE lock_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_rec                     IN  iohv_rec_type);

 PROCEDURE update_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_tbl                     IN  iohv_tbl_type
    ,x_iohv_tbl                     OUT  NOCOPY iohv_tbl_type);

 PROCEDURE update_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_rec                     IN  iohv_rec_type
    ,x_iohv_rec                     OUT  NOCOPY iohv_rec_type);

 PROCEDURE delete_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_tbl                     IN  iohv_tbl_type);

 PROCEDURE delete_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_rec                     IN  iohv_rec_type);

  PROCEDURE validate_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_tbl                     IN  iohv_tbl_type);

 PROCEDURE validate_open_int_hst(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_iohv_rec                     IN  iohv_rec_type);

END iex_open_int_hst_pub;


 

/
