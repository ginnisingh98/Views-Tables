--------------------------------------------------------
--  DDL for Package OKL_SUPP_INVOICE_DTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUPP_INVOICE_DTLS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLCSIDS.pls 115.0 2002/02/05 15:12:15 pkm ship        $ */

  subtype sid_rec_type is okl_sid_pvt.sid_rec_type;
  subtype sid_tbl_type is okl_sid_pvt.sid_tbl_type;
  subtype sidv_rec_type is okl_sid_pvt.sidv_rec_type;
  subtype sidv_tbl_type is okl_sid_pvt.sidv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS , VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SUPP_INVOICE_DTLS_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';

 ----------------------------------------------------------------------------------
  --Global Exception
 ----------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ----------------------------------------------------------------------------------
  --Public Procedures and Functions
 ----------------------------------------------------------------------------------
--  PROCEDURE add_language;
  PROCEDURE Create_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type,
    x_sidv_rec                     OUT NOCOPY sidv_rec_type);

  PROCEDURE Create_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type);

  PROCEDURE lock_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type);

  PROCEDURE lock_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type);

  PROCEDURE update_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type,
    x_sidv_rec                     OUT NOCOPY sidv_rec_type);

  PROCEDURE update_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type,
    x_sidv_tbl                     OUT NOCOPY sidv_tbl_type);

  PROCEDURE delete_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type);

  PROCEDURE delete_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type);

  PROCEDURE validate_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_rec                     IN sidv_rec_type);

  PROCEDURE validate_sup_inv_dtls(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sidv_tbl                     IN sidv_tbl_type);

END OKL_SUPP_INVOICE_DTLS_PVT;

 

/
