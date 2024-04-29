--------------------------------------------------------
--  DDL for Package OKL_TRX_ASSETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TRX_ASSETS_PVT" AUTHID CURRENT_USER as
/* $Header: OKLCTASS.pls 115.3 2002/02/05 11:50:21 pkm ship        $ */

  subtype tatv_rec_type is okl_tas_pvt.tas_rec_type;
  subtype tatv_tbl_type is okl_tas_pvt.tas_tbl_type;
  subtype tavv_rec_type is okl_tas_pvt.tasv_rec_type;
  subtype tavv_tbl_type is okl_tas_pvt.tasv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS , VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TRX_ASSEST_HEADER_PVT';
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
  PROCEDURE Create_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tavv_rec_type,
    x_tasv_rec                     OUT NOCOPY tavv_rec_type);

  PROCEDURE Create_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tavv_tbl_type,
    x_tasv_tbl                     OUT NOCOPY tavv_tbl_type);

  PROCEDURE lock_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tavv_rec_type);

  PROCEDURE lock_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tavv_tbl_type);

  PROCEDURE update_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tavv_rec_type,
    x_tasv_rec                     OUT NOCOPY tavv_rec_type);

  PROCEDURE update_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tavv_tbl_type,
    x_tasv_tbl                     OUT NOCOPY tavv_tbl_type);

  PROCEDURE delete_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tavv_rec_type);

  PROCEDURE delete_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tavv_tbl_type);

  PROCEDURE validate_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tavv_rec_type);

  PROCEDURE validate_trx_ass_h_def(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tavv_tbl_type);

END OKL_TRX_ASSETS_PVT;

 

/
