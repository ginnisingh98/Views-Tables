--------------------------------------------------------
--  DDL for Package OKS_BSL_DET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BSL_DET_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRBSDS.pls 120.0 2005/05/25 17:40:19 appldev noship $ */

  SUBTYPE bsdv_rec_type IS OKS_bsd_PVT.bsdv_rec_type;
  SUBTYPE bsdv_tbl_type IS OKS_bsd_PVT.bsdv_tbl_type;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BILLCONT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  PROCEDURE insert_bsl_det_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
   p_bsdv_rec      IN bsdv_rec_type,
 x_bsdv_rec      OUT NOCOPY bsdv_rec_type);

  PROCEDURE lock_bsl_det_Comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec      IN bsdv_rec_type);

  PROCEDURE update_bsl_det_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec      IN bsdv_rec_type,
 x_bsdv_rec      OUT NOCOPY bsdv_rec_type);

  PROCEDURE delete_bsl_det_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bsdv_rec      IN bsdv_rec_type);

  PROCEDURE validate_bsl_det_comp(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
   p_bsdv_rec      IN bsdv_rec_type);

END OKS_BSL_DET_PVT;

 

/
