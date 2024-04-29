--------------------------------------------------------
--  DDL for Package OKL_SIF_RET_STRMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIF_RET_STRMS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSRSS.pls 115.3 2003/05/12 23:39:48 bakuchib noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_SIF_RET_STRMS_PUB';

  SUBTYPE srsv_rec_type IS okl_srs_pvt.srsv_rec_type;
  SUBTYPE srsv_tbl_type IS okl_srs_pvt.srsv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN  srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);


--BAKUCHIB Bug#2807737 start
 PROCEDURE insert_sif_ret_strms_per(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN  srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);

 PROCEDURE mass_insert_sif_ret(p_srsv_tbl  IN  srsv_tbl_type);
--BAKUCHIB Bug#2807737 End

 PROCEDURE insert_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN  srsv_tbl_type,
    x_srsv_tbl                     OUT NOCOPY srsv_tbl_type);

  PROCEDURE lock_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type);

  PROCEDURE lock_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN  srsv_tbl_type);

  PROCEDURE update_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN  srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);

  PROCEDURE update_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN  srsv_tbl_type,
    x_srsv_tbl                     OUT NOCOPY srsv_tbl_type);

  PROCEDURE delete_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN  srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);

  PROCEDURE delete_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN  srsv_tbl_type,
    x_srsv_tbl                     OUT NOCOPY srsv_tbl_type);

  PROCEDURE validate_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN  srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);

  PROCEDURE validate_sif_ret_strms(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN  srsv_tbl_type,
    x_srsv_tbl                     OUT NOCOPY srsv_tbl_type);

END OKL_SIF_RET_STRMS_PUB;

 

/
