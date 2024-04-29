--------------------------------------------------------
--  DDL for Package OKE_TERM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_TERM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVTRMS.pls 115.7 2002/11/20 20:45:10 who ship $*/
-- GLOBAL DATA STRUCTURES

TYPE term_rec_type IS RECORD(

 K_HEADER_ID			NUMBER:= OKE_API.G_MISS_NUM,
 K_LINE_ID			NUMBER:= OKE_API.G_MISS_NUM,
 TERM_CODE                      OKE_K_TERMS.TERM_CODE%TYPE:=OKE_API.G_MISS_CHAR,
 TERM_VALUE_PK1			OKE_K_TERMS.TERM_VALUE_PK1%TYPE:=OKE_API.G_MISS_CHAR,
 TERM_VALUE_PK2			OKE_K_TERMS.TERM_VALUE_PK2%TYPE:=OKE_API.G_MISS_CHAR,
 CREATION_DATE                  DATE:= OKE_API.G_MISS_DATE,
 CREATED_BY			NUMBER:= OKE_API.G_MISS_NUM,
 LAST_UPDATE_DATE               DATE:= OKE_API.G_MISS_DATE,
 LAST_UPDATED_BY		NUMBER:= OKE_API.G_MISS_NUM,
 LAST_UPDATE_LOGIN		NUMBER:= OKE_API.G_MISS_NUM,
 ATTRIBUTE_CATEGORY             OKE_K_TERMS.ATTRIBUTE_CATEGORY%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE1                	OKE_K_TERMS.ATTRIBUTE1%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE2                	OKE_K_TERMS.ATTRIBUTE2%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE3                	OKE_K_TERMS.ATTRIBUTE3%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE4                	OKE_K_TERMS.ATTRIBUTE4%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE5                	OKE_K_TERMS.ATTRIBUTE5%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE6                	OKE_K_TERMS.ATTRIBUTE6%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE7                	OKE_K_TERMS.ATTRIBUTE7%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE8                	OKE_K_TERMS.ATTRIBUTE8%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE9                	OKE_K_TERMS.ATTRIBUTE9%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE10                	OKE_K_TERMS.ATTRIBUTE10%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE11                	OKE_K_TERMS.ATTRIBUTE11%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE12                	OKE_K_TERMS.ATTRIBUTE12%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE13                	OKE_K_TERMS.ATTRIBUTE13%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE14                	OKE_K_TERMS.ATTRIBUTE14%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE15                	OKE_K_TERMS.ATTRIBUTE15%TYPE:=OKE_API.G_MISS_CHAR

);

TYPE term_tbl_type IS TABLE OF term_rec_type
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

  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKE_TERM_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKE_API.G_APP_NAME;
  G_VIEW          		CONSTANT VARCHAR2(200) := 'OKE_K_TERMS_V';

G_EXCEPTION_HALT_VALIDATION exception;

-- Procedures and functions

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec                      IN term_rec_type,
    x_term_rec                      OUT NOCOPY term_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl                     IN term_tbl_type,
    x_term_tbl                     OUT NOCOPY term_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec                     IN term_rec_type,
    x_term_rec                     OUT NOCOPY term_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl                     IN term_tbl_type,
    x_term_tbl                     OUT NOCOPY term_tbl_type);


  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_id                       IN NUMBER,
    p_trm_cd			   OKE_K_TERMS.TERM_CODE%TYPE,
    p_trm_val_pk1		   OKE_K_TERMS.TERM_VALUE_PK1%TYPE,
    p_trm_val_pk2		   OKE_K_TERMS.TERM_VALUE_PK2%TYPE
);



/* note: does not cascade into lines */

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_trm_cd			   OKE_K_TERMS.TERM_CODE%TYPE,
    p_trm_val_pk1		   OKE_K_TERMS.TERM_VALUE_PK1%TYPE,
    p_trm_val_pk2		   OKE_K_TERMS.TERM_VALUE_PK2%TYPE
);


  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec                     IN term_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl                     IN term_tbl_type);


  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec                     IN term_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_tbl                     IN term_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_term_rec                     IN term_rec_type);


END OKE_TERM_PVT;


 

/
