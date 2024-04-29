--------------------------------------------------------
--  DDL for Package OKL_TRX_CSH_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRX_CSH_BATCH_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPBTCS.pls 120.2 2005/10/30 03:29:14 appldev noship $ */

 subtype btcv_rec_type is okl_btc_pvt.btcv_rec_type;
 subtype btcv_tbl_type is okl_btc_pvt.btcv_tbl_type;
 subtype okl_btch_dtls_tbl_type is okl_btch_cash_applic.okl_btch_dtls_tbl_type;
 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_TRX_CSH_BATCH_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------


 PROCEDURE insert_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_tbl                     IN  btcv_tbl_type
    ,x_btcv_tbl                     OUT  NOCOPY btcv_tbl_type);

 PROCEDURE insert_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_rec                     IN  btcv_rec_type
    ,x_btcv_rec                     OUT  NOCOPY btcv_rec_type);

 PROCEDURE lock_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_tbl                     IN  btcv_tbl_type);

 PROCEDURE lock_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_rec                     IN  btcv_rec_type);

 PROCEDURE update_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN   VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_tbl                     IN  btcv_tbl_type
    ,x_btcv_tbl                     OUT  NOCOPY btcv_tbl_type);

 PROCEDURE update_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_rec                     IN  btcv_rec_type
    ,x_btcv_rec                     OUT  NOCOPY btcv_rec_type);

 PROCEDURE delete_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_tbl                     IN  btcv_tbl_type);

 PROCEDURE delete_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_rec                     IN  btcv_rec_type);

  PROCEDURE validate_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_tbl                     IN  btcv_tbl_type);

 PROCEDURE validate_trx_csh_batch(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_btcv_rec                     IN  btcv_rec_type);

 PROCEDURE handle_batch_receipt(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_btcv_rec                     IN  btcv_rec_type
    ,x_btcv_rec                     OUT NOCOPY btcv_rec_type
    ,p_btch_lines_tbl               IN  okl_btch_dtls_tbl_type
    ,x_btch_lines_tbl               OUT NOCOPY okl_btch_dtls_tbl_type);

END okl_trx_csh_batch_pub;

 

/
