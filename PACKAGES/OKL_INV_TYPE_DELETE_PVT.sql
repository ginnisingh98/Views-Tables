--------------------------------------------------------
--  DDL for Package OKL_INV_TYPE_DELETE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INV_TYPE_DELETE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRITDS.pls 115.1 2002/02/05 12:12:37 pkm ship       $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ity_del_rec_type IS RECORD (
    id                             NUMBER := Okl_Api.G_MISS_NUM,
    inf_id                         NUMBER := Okl_Api.G_MISS_NUM,
    name                           OKL_INVOICE_TYPES_V.NAME%TYPE := Okl_Api.G_MISS_CHAR,
    description                    OKL_INVOICE_TYPES_V.DESCRIPTION%TYPE := Okl_Api.G_MISS_CHAR,
    GROUP_ASSET_YN                 OKL_INVOICE_TYPES_V.GROUP_ASSET_YN%TYPE := Okl_Api.G_MISS_CHAR,
    GROUP_BY_CONTRACT_YN           OKL_INVOICE_TYPES_V.GROUP_BY_CONTRACT_YN%TYPE := Okl_Api.G_MISS_CHAR
	);

  TYPE ity_del_tbl_type IS TABLE OF ity_del_rec_type
        INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okl_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okl_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okl_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okl_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okl_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okl_Api.G_CHILD_TABLE_TOKEN;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD           CONSTANT   VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_NOT_SAME                CONSTANT   VARCHAR2(200) := 'OKL_CANNOT_BE_SAME';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'Okl_inv_type_delete_Pvt';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  G_VIEW   CONSTANT   VARCHAR2(30) := 'OKL_BPD_INV_TYPES_UV';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE delete_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_del_rec                  IN ity_del_rec_type);

  PROCEDURE delete_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_del_tbl                  IN ity_del_tbl_type);


END Okl_Inv_Type_Delete_Pvt;

 

/
