--------------------------------------------------------
--  DDL for Package OKL_TXD_QTE_ANTCPT_BILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TXD_QTE_ANTCPT_BILL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPQABS.pls 120.1 2005/10/30 04:01:49 appldev noship $ */

 SUBTYPE qabv_rec_type IS okl_qab_pvt.qabv_rec_type;
 SUBTYPE qabv_tbl_type IS okl_qab_pvt.qabv_tbl_type;

 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_TXD_QTE_ANTCPT_BILL_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 PROCEDURE create_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type
    ,x_qabv_rec                     OUT  NOCOPY qabv_rec_type);

 PROCEDURE create_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type
    ,x_qabv_tbl                     OUT  NOCOPY qabv_tbl_type);

 PROCEDURE lock_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type);

 PROCEDURE lock_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type);

 PROCEDURE update_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type
    ,x_qabv_rec                     OUT  NOCOPY qabv_rec_type);

 PROCEDURE update_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type
    ,x_qabv_tbl                     OUT  NOCOPY qabv_tbl_type);

 PROCEDURE delete_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type);

 PROCEDURE delete_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type);

  PROCEDURE validate_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type);

 PROCEDURE validate_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type);


END OKL_TXD_QTE_ANTCPT_BILL_PUB;

 

/
