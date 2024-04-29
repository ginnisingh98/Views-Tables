--------------------------------------------------------
--  DDL for Package OKS_CONTRACT_SLL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CONTRACT_SLL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPSLLS.pls 120.0 2005/05/25 17:59:18 appldev noship $ */
  subtype sllv_rec_type is oks_sll_pvt.sllv_rec_type;
  subtype sllv_tbl_type is oks_sll_pvt.sllv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKC_CONTRACT_SLL_PUB';
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(20)  := OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(20)  := OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(20)  := OKC_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_FALSE                CONSTANT VARCHAR2(10)  := OKC_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(10)  := OKC_API.G_TRUE;
  ---------------------------------------------------------------------------

  PROCEDURE create_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type,
    x_sllv_rec                     OUT NOCOPY sllv_rec_type,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE create_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE create_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE lock_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type);
  PROCEDURE lock_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type);
  PROCEDURE update_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type,
    x_sllv_rec                     OUT NOCOPY sllv_rec_type,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE update_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE update_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    x_sllv_tbl                     OUT NOCOPY sllv_tbl_type,
    p_validate_yn                  IN VARCHAR2);
  PROCEDURE delete_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type);
  PROCEDURE delete_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type);
  PROCEDURE validate_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_rec                     IN sllv_rec_type);
  PROCEDURE validate_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_sll(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sllv_tbl                     IN sllv_tbl_type);

  PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,
                           p_sllv_tbl   IN sllv_tbl_type);

END oks_contract_sll_pub;


 

/
