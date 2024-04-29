--------------------------------------------------------
--  DDL for Package OKL_SIF_PRICE_PARMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIF_PRICE_PARMS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSPPS.pls 115.1 2002/02/05 12:09:25 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SIF_PRICE_PARMS_PUB';

  SUBTYPE sppv_rec_type IS OKL_SPP_PVT.sppv_rec_type;
  SUBTYPE sppv_tbl_type IS OKL_SPP_PVT.sppv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN  sppv_rec_type,
    x_sppv_rec                     OUT NOCOPY sppv_rec_type);

  PROCEDURE insert_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN  sppv_tbl_type,
    x_sppv_tbl                     OUT NOCOPY sppv_tbl_type);

  PROCEDURE lock_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type);

  PROCEDURE lock_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN  sppv_tbl_type);

  PROCEDURE update_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN  sppv_rec_type,
    x_sppv_rec                     OUT NOCOPY sppv_rec_type);

  PROCEDURE update_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN  sppv_tbl_type,
    x_sppv_tbl                     OUT NOCOPY sppv_tbl_type);

  PROCEDURE delete_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN  sppv_rec_type,
    x_sppv_rec                     OUT NOCOPY sppv_rec_type);

  PROCEDURE delete_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN  sppv_tbl_type,
    x_sppv_tbl                     OUT NOCOPY sppv_tbl_type);

  PROCEDURE validate_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN  sppv_rec_type,
    x_sppv_rec                     OUT NOCOPY sppv_rec_type);

  PROCEDURE validate_sif_price_parms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN  sppv_tbl_type,
    x_sppv_tbl                     OUT NOCOPY sppv_tbl_type);

END OKL_SIF_PRICE_PARMS_PUB;

 

/
