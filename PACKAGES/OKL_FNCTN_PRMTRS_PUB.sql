--------------------------------------------------------
--  DDL for Package OKL_FNCTN_PRMTRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FNCTN_PRMTRS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPFPRS.pls 115.6 2002/02/05 12:05:43 pkm ship       $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME                  CONSTANT VARCHAR2(30)  := 'OKL_FNCTN_PRMTRS_PUB';

  SUBTYPE fprv_rec_type IS okl_fpr_pvt.fprv_rec_type;
  SUBTYPE fprv_tbl_type IS okl_fpr_pvt.fprv_tbl_type;

  PROCEDURE add_language;

  PROCEDURE insert_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN  fprv_rec_type,
    x_fprv_rec                     OUT NOCOPY fprv_rec_type);

  PROCEDURE insert_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN  fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type);

  PROCEDURE lock_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type);

  PROCEDURE lock_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN  fprv_tbl_type);

  PROCEDURE update_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN  fprv_rec_type,
    x_fprv_rec                     OUT NOCOPY fprv_rec_type);

  PROCEDURE update_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN  fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type);

  PROCEDURE delete_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN  fprv_rec_type);

  PROCEDURE delete_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN  fprv_tbl_type);

  PROCEDURE validate_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN  fprv_rec_type);

  PROCEDURE validate_fnctn_prmtrs(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN  fprv_tbl_type);

END OKL_FNCTN_PRMTRS_PUB;

 

/
