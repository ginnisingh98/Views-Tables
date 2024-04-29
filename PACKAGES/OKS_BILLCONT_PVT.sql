--------------------------------------------------------
--  DDL for Package OKS_BILLCONT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILLCONT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRBCLS.pls 120.0 2005/05/25 18:14:04 appldev noship $ */

  SUBTYPE bclv_rec_type IS OKS_BCL_PVT.bclv_rec_type;
  SUBTYPE bclv_tbl_type IS OKS_BCL_PVT.bclv_tbl_type;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BILLCONT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE insert_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type,
    x_bclv_rec                     OUT NOCOPY bclv_rec_type);

  PROCEDURE lock_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type);

  PROCEDURE update_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type,
    x_bclv_rec                     OUT NOCOPY bclv_rec_type);

  PROCEDURE delete_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type);

  PROCEDURE validate_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type);

END OKS_BILLCONT_PVT;

 

/
