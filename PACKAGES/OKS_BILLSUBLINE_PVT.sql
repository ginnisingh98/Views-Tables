--------------------------------------------------------
--  DDL for Package OKS_BILLSUBLINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILLSUBLINE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRBSLS.pls 120.0 2005/05/25 17:50:23 appldev noship $ */

  SUBTYPE bslv_rec_type IS OKS_BSL_PVT.bslv_rec_type;
  SUBTYPE bslv_tbl_type IS OKS_BSL_PVT.bslv_tbl_type;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BILLSUBLINE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE insert_bill_SubLine_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
   p_bslv_rec      IN bslv_rec_type,
 x_bslv_rec      OUT NOCOPY bslv_rec_type);

  PROCEDURE lock_bill_SubLine_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec      IN bslv_rec_type);

  PROCEDURE update_bill_SubLine_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec      IN bslv_rec_type,
 x_bslv_rec      OUT NOCOPY bslv_rec_type);

  PROCEDURE delete_bill_SubLine_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bslv_rec      IN bslv_rec_type);

  PROCEDURE validate_bill_SubLine_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
   p_bslv_rec      IN bslv_rec_type);

END OKS_BILLSubLINE_PVT;

 

/
