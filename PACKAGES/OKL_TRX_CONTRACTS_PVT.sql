--------------------------------------------------------
--  DDL for Package OKL_TRX_CONTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRX_CONTRACTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLCTCNS.pls 115.3 2002/02/05 11:50:24 pkm ship       $ */

  SUBTYPE tcnv_rec_type IS okl_tcn_pvt.tcnv_rec_type;
  SUBTYPE tcnv_tbl_type IS okl_tcn_pvt.tcnv_tbl_type;

  SUBTYPE tclv_rec_type IS okl_tcl_pvt.tclv_rec_type;
  SUBTYPE tclv_tbl_type IS okl_tcl_pvt.tclv_tbl_type;
  ------------------------------------------------------------------------------
  -- Global Variables
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_TRX_CONTRACTS_PVT';
  G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
  ------------------------------------------------------------------------------
   --Global Exception
  ------------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  ------------------------------------------------------------------------------

  --Object type procedure for insert
  PROCEDURE create_trx_contracts(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tcnv_rec                     IN  tcnv_rec_type
    ,p_tclv_tbl                     IN  tclv_tbl_type
    ,x_tcnv_rec                     OUT NOCOPY tcnv_rec_type
    ,x_tclv_tbl                     OUT NOCOPY tclv_tbl_type
     );

  --Object type procedure for update
  PROCEDURE update_trx_contracts(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tcnv_rec                     IN  tcnv_rec_type
    ,p_tclv_tbl                     IN  tclv_tbl_type
    ,x_tcnv_rec                     OUT NOCOPY tcnv_rec_type
    ,x_tclv_tbl                     OUT NOCOPY tclv_tbl_type
     );

  --Object type procedure for validate
  PROCEDURE validate_trx_contracts(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_tcnv_rec                     IN  tcnv_rec_type
    ,p_tclv_tbl                     IN  tclv_tbl_type
     );



  PROCEDURE create_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_tbl                     IN  tcnv_tbl_type,
     x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type);

  PROCEDURE create_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_rec                     IN  tcnv_rec_type,
     x_tcnv_rec                     OUT NOCOPY tcnv_rec_type);

  PROCEDURE lock_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_tbl                     IN  tcnv_tbl_type);

  PROCEDURE lock_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_rec                     IN  tcnv_rec_type);

  PROCEDURE update_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_tbl                     IN  tcnv_tbl_type,
     x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type);

  PROCEDURE update_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_rec                     IN  tcnv_rec_type,
     x_tcnv_rec                     OUT NOCOPY tcnv_rec_type);

  PROCEDURE delete_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_tbl                     IN  tcnv_tbl_type);

  PROCEDURE delete_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_rec                     IN tcnv_rec_type);

   PROCEDURE validate_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_tbl                     IN  tcnv_tbl_type);

  PROCEDURE validate_trx_contracts(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tcnv_rec                     IN  tcnv_rec_type);


  PROCEDURE create_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_tbl                     IN  tclv_tbl_type,
     x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);

  PROCEDURE create_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_rec                     IN  tclv_rec_type,
     x_tclv_rec                     OUT NOCOPY tclv_rec_type);

  PROCEDURE lock_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_tbl                     IN  tclv_tbl_type);

  PROCEDURE lock_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_rec                     IN  tclv_rec_type);

  PROCEDURE update_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_tbl                     IN  tclv_tbl_type,
     x_tclv_tbl                     OUT NOCOPY tclv_tbl_type);

  PROCEDURE update_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_rec                     IN  tclv_rec_type,
     x_tclv_rec                     OUT NOCOPY tclv_rec_type);

  PROCEDURE delete_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_tbl                     IN  tclv_tbl_type);

  PROCEDURE delete_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_rec                     IN  tclv_rec_type);

   PROCEDURE validate_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_tbl                     IN  tclv_tbl_type);

  PROCEDURE validate_trx_cntrct_lines(
     p_api_version                  IN  NUMBER,
     p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
     x_return_status                OUT NOCOPY VARCHAR2,
     x_msg_count                    OUT NOCOPY NUMBER,
     x_msg_data                     OUT NOCOPY VARCHAR2,
     p_tclv_rec                     IN  tclv_rec_type);

END OKL_TRX_CONTRACTS_PVT;

 

/
