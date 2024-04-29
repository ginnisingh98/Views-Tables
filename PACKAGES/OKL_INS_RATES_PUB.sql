--------------------------------------------------------
--  DDL for Package OKL_INS_RATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INS_RATES_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPINRS.pls 115.3 2002/02/05 12:06:28 pkm ship        $ */


subtype inrv_rec_type is okl_inr_pvt.inrv_rec_type;
 subtype inrv_tbl_type is okl_inr_pvt.inrv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_INS_RATES_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  'OKL';
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_tbl                     IN  inrv_tbl_type
    ,x_inrv_tbl                     OUT  NOCOPY inrv_tbl_type);

 PROCEDURE insert_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_rec                     IN  inrv_rec_type
    ,x_inrv_rec                     OUT  NOCOPY inrv_rec_type);

 PROCEDURE lock_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_tbl                     IN  inrv_tbl_type);

 PROCEDURE lock_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_rec                     IN  inrv_rec_type);

 PROCEDURE update_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_tbl                     IN  inrv_tbl_type
    ,x_inrv_tbl                     OUT  NOCOPY inrv_tbl_type);

 PROCEDURE update_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_rec                     IN  inrv_rec_type
    ,x_inrv_rec                     OUT  NOCOPY inrv_rec_type);

 PROCEDURE delete_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_tbl                     IN  inrv_tbl_type);

 PROCEDURE delete_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_rec                     IN  inrv_rec_type);

  PROCEDURE validate_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_tbl                     IN  inrv_tbl_type);

 PROCEDURE validate_ins_rates(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_inrv_rec                     IN  inrv_rec_type);

END okl_ins_rates_pub;

 

/
