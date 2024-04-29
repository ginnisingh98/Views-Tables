--------------------------------------------------------
--  DDL for Package OKL_TXD_QTE_LN_DTLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TXD_QTE_LN_DTLS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPTQDS.pls 115.0 2002/12/03 18:50:31 bakuchib noship $ */

 subtype tqdv_rec_type is okl_tqd_pvt.tqdv_rec_type;
 subtype tqdv_tbl_type is okl_tqd_pvt.tqdv_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_TXD_QTE_LN_DTLS_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE create_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_tbl                     IN  tqdv_tbl_type
    ,x_tqdv_tbl                     OUT  NOCOPY tqdv_tbl_type);

 PROCEDURE create_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_rec                     IN  tqdv_rec_type
    ,x_tqdv_rec                     OUT  NOCOPY tqdv_rec_type);

 PROCEDURE lock_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_tbl                     IN  tqdv_tbl_type);

 PROCEDURE lock_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_rec                     IN  tqdv_rec_type);

 PROCEDURE update_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_tbl                     IN  tqdv_tbl_type
    ,x_tqdv_tbl                     OUT  NOCOPY tqdv_tbl_type);

 PROCEDURE update_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_rec                     IN  tqdv_rec_type
    ,x_tqdv_rec                     OUT  NOCOPY tqdv_rec_type);

 PROCEDURE delete_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_tbl                     IN  tqdv_tbl_type);

 PROCEDURE delete_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_rec                     IN  tqdv_rec_type);

  PROCEDURE validate_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_tbl                     IN  tqdv_tbl_type);

 PROCEDURE validate_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_rec                     IN  tqdv_rec_type);

END OKL_TXD_QTE_LN_DTLS_PUB;

 

/
