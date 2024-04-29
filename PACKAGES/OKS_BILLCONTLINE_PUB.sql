--------------------------------------------------------
--  DDL for Package OKS_BILLCONTLINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILLCONTLINE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPBCLS.pls 120.0 2005/05/25 17:46:18 appldev noship $ */

  SUBTYPE bclv_rec_type IS OKS_BILLCONT_PVT.bclv_rec_type;
  SUBTYPE bclv_tbl_type IS OKS_BILLCONT_PVT.bclv_tbl_type;

 -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BILLCONTLINE_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_BCLV_REC				bclv_rec_type;
  ---------------------------------------------------------------------------

  -- GLOBAL_MESSAGE_CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP	               	 CONSTANT VARCHAR2(200) :=  OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED        CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED        CONSTANT VARCHAR2(200) :=  OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED   CONSTANT VARCHAR2(200) :=  OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) :=  OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN             CONSTANT VARCHAR2(200) :=  OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN         CONSTANT VARCHAR2(200) :=  OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN          CONSTANT VARCHAR2(200) :=  OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED         CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';
  ---------------------------------------------------------------------------

  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------


  PROCEDURE insert_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type,
    x_bclv_rec                     OUT NOCOPY bclv_rec_type);

  PROCEDURE insert_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type,
    x_bclv_tbl                     OUT NOCOPY bclv_tbl_type);

  PROCEDURE lock_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type);

  PROCEDURE lock_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type);

  PROCEDURE update_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type,
    x_bclv_rec                     OUT NOCOPY bclv_rec_type);

  PROCEDURE update_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type,
    x_bclv_tbl                     OUT NOCOPY bclv_tbl_type);

  PROCEDURE delete_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_rec                     IN bclv_rec_type);

  PROCEDURE delete_bill_cont_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bclv_tbl                     IN bclv_tbl_type);

  PROCEDURE validate_bill_cont_line(
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
    p_bclv_tbl                     IN bclv_tbl_type);

END OKS_BILLCONTLINE_PUB;

 

/
