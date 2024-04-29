--------------------------------------------------------
--  DDL for Package OKL_SYSTEM_PARAMS_ALL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SYSTEM_PARAMS_ALL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPSYPS.pls 120.3 2006/08/10 05:27:33 akrangan noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  SUBTYPE sypv_rec_type IS OKL_SYP_PVT.sypv_rec_type;
  SUBTYPE sypv_tbl_type IS OKL_SYP_PVT.sypv_tbl_type;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SYSTEM_PARAMS_ALL_PUB';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_APP_NAME_1                   CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_RET_STS_UNEXP_ERROR          CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR                CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_SUCCESS              CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_ITEM_INV_ORG_ID              CONSTANT VARCHAR2(50)  := 'ITEM_INV_ORG_ID';
  G_RPT_PROD_BOOK_TYPE_CODE	     CONSTANT VARCHAR2(50)  := 'RPT_PROD_BOOK_TYPE_CODE';
  G_ASST_ADD_BOOK_TYPE_CODE	     CONSTANT VARCHAR2(50)  := 'ASST_ADD_BOOK_TYPE_CODE';
  G_CCARD_REMITTANCE_ID		     CONSTANT VARCHAR2(50)  := 'CCARD_REMITTANCE_ID';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;
  G_EXCEPTION_ERROR             EXCEPTION;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE insert_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type);
  PROCEDURE insert_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type);
  PROCEDURE lock_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type);
  PROCEDURE lock_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type);
  PROCEDURE update_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type);
  PROCEDURE update_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type);
  PROCEDURE delete_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type);
  PROCEDURE delete_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type);
  PROCEDURE validate_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type);
  PROCEDURE validate_system_parameters(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type);
  FUNCTION get_system_param_value (
   p_param_name IN VARCHAR2,
   p_org_id IN NUMBER DEFAULT NULL
  )
  RETURN VARCHAR2;
END OKL_SYSTEM_PARAMS_ALL_PUB;

/
