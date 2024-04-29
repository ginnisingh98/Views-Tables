--------------------------------------------------------
--  DDL for Package OKL_XTD_SELL_INVS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_XTD_SELL_INVS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPESDS.pls 115.2 2002/02/05 12:05:27 pkm ship       $ */



 subtype esdv_rec_type is okl_esd_pvt.esdv_rec_type;
 subtype esdv_tbl_type is okl_esd_pvt.esdv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_XTD_SELL_INVS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_tbl                     IN  esdv_tbl_type
    ,x_esdv_tbl                     OUT  NOCOPY esdv_tbl_type);

 PROCEDURE insert_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_rec                     IN  esdv_rec_type
    ,x_esdv_rec                     OUT  NOCOPY esdv_rec_type);

 PROCEDURE lock_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_tbl                     IN  esdv_tbl_type);

 PROCEDURE lock_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_rec                     IN  esdv_rec_type);

 PROCEDURE update_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_tbl                     IN  esdv_tbl_type
    ,x_esdv_tbl                     OUT  NOCOPY esdv_tbl_type);

 PROCEDURE update_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_rec                     IN  esdv_rec_type
    ,x_esdv_rec                     OUT  NOCOPY esdv_rec_type);

 PROCEDURE delete_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_tbl                     IN  esdv_tbl_type);

 PROCEDURE delete_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_rec                     IN  esdv_rec_type);

  PROCEDURE validate_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_tbl                     IN  esdv_tbl_type);

 PROCEDURE validate_xtd_sell_invs(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_esdv_rec                     IN  esdv_rec_type);

END okl_xtd_sell_invs_pub;


 

/
