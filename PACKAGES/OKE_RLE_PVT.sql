--------------------------------------------------------
--  DDL for Package OKE_RLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_RLE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVRLES.pls 115.9 2002/11/20 20:42:45 who ship $*/
-- GLOBAL DATA STRUCTURES

TYPE rle_rec_type IS RECORD(
 ROW_ID				ROWID,
 K_HEADER_ID			NUMBER:= OKE_API.G_MISS_NUM,
 CHG_REQUEST_ID			NUMBER:= OKE_API.G_MISS_NUM,
 RELATED_ENTITY_ID		NUMBER:= OKE_API.G_MISS_NUM,
 RELATED_ENTITY_VERSION		NUMBER:= OKE_API.G_MISS_NUM,
 CREATION_DATE                  DATE:= OKE_API.G_MISS_DATE,
 CREATED_BY			NUMBER:= OKE_API.G_MISS_NUM,
 LAST_UPDATE_DATE               DATE:= OKE_API.G_MISS_DATE,
 LAST_UPDATED_BY		NUMBER:= OKE_API.G_MISS_NUM,
 LAST_UPDATE_LOGIN		NUMBER:= OKE_API.G_MISS_NUM
);

TYPE rle_tbl_type IS TABLE OF rle_rec_type
INDEX BY BINARY_INTEGER;

-- GLOBAL MESSAGE CONSTANTS

  G_FND_APP			CONSTANT VARCHAR2(200) := OKE_API.G_FND_APP;

  G_FORM_UNABLE_TO_RESERVE_REC 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_RECORD_DELETED;

  G_FORM_RECORD_CHANGED 	CONSTANT VARCHAR2(200) := OKE_API.G_FORM_RECORD_CHANGED;

  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKE_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKE_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKE_API.G_INVALID_VALUE;
  G_CHILD_RECORD_FOUND		CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_RECORD_FOUND;
  G_NO_PARENT_RECORD 		CONSTANT VARCHAR2(200) := OKE_API.G_NO_PARENT_RECORD;
  G_UNEXPECTED_ERROR 		CONSTANT VARCHAR2(200) := OKE_API.G_UNEXPECTED_ERROR;

  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_SQLERRM_TOKEN;
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := OKE_API.G_SQLCODE_TOKEN;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKE_RLE_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKE_API.G_APP_NAME;
  G_VIEW          		CONSTANT VARCHAR2(200) := 'OKE_K_RELATED_ENTITIES_V';

  G_EXCEPTION_HALT_VALIDATION exception;

-- Procedures and functions

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec                      IN rle_rec_type,
    x_rle_rec                      OUT NOCOPY rle_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_tbl                     IN rle_tbl_type,
    x_rle_tbl                     OUT NOCOPY rle_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec                     IN rle_rec_type,
    x_rle_rec                     OUT NOCOPY rle_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_tbl                     IN rle_tbl_type,
    x_rle_tbl                     OUT NOCOPY rle_tbl_type);


  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec                     IN rle_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_tbl                     IN rle_tbl_type);


  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec                     IN rle_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_tbl                     IN rle_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec                     IN rle_rec_type);


END OKE_RLE_PVT;


 

/
