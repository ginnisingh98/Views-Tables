--------------------------------------------------------
--  DDL for Package OKE_PARTY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_PARTY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVFPPS.pls 115.6 2002/08/14 01:45:05 alaw ship $*/
-- GLOBAL DATA STRUCTURES

TYPE party_rec_type IS RECORD(
 POOL_PARTY_ID			NUMBER:= OKE_API.G_MISS_NUM,
 FUNDING_POOL_ID		NUMBER:= OKE_API.G_MISS_NUM,
 PARTY_ID			NUMBER:= OKE_API.G_MISS_NUM,
 CURRENCY_CODE			OKE_POOL_PARTIES.CURRENCY_CODE%TYPE:=OKE_API.G_MISS_CHAR,
 CONVERSION_TYPE		OKE_POOL_PARTIES.CONVERSION_TYPE%TYPE:=OKE_API.G_MISS_CHAR,
 CONVERSION_DATE		DATE:= OKE_API.G_MISS_DATE,
 CONVERSION_RATE		NUMBER:= OKE_API.G_MISS_NUM,
 INITIAL_AMOUNT			NUMBER:= OKE_API.G_MISS_NUM,
 AMOUNT				NUMBER:= OKE_API.G_MISS_NUM,
 AVAILABLE_AMOUNT		NUMBER:= OKE_API.G_MISS_NUM,
 START_DATE_ACTIVE		DATE:= OKE_API.G_MISS_DATE,
 END_DATE_ACTIVE		DATE:= OKE_API.G_MISS_DATE,

 CREATION_DATE                  DATE:= OKE_API.G_MISS_DATE,
 CREATED_BY			NUMBER:= OKE_API.G_MISS_NUM,
 LAST_UPDATE_DATE               DATE:= OKE_API.G_MISS_DATE,
 LAST_UPDATED_BY		NUMBER:= OKE_API.G_MISS_NUM,
 LAST_UPDATE_LOGIN		NUMBER:= OKE_API.G_MISS_NUM,
 ATTRIBUTE_CATEGORY             OKE_POOL_PARTIES.ATTRIBUTE_CATEGORY%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE1                	OKE_POOL_PARTIES.ATTRIBUTE1%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE2                	OKE_POOL_PARTIES.ATTRIBUTE2%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE3                	OKE_POOL_PARTIES.ATTRIBUTE3%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE4                	OKE_POOL_PARTIES.ATTRIBUTE4%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE5                	OKE_POOL_PARTIES.ATTRIBUTE5%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE6                	OKE_POOL_PARTIES.ATTRIBUTE6%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE7                	OKE_POOL_PARTIES.ATTRIBUTE7%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE8                	OKE_POOL_PARTIES.ATTRIBUTE8%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE9                	OKE_POOL_PARTIES.ATTRIBUTE9%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE10                	OKE_POOL_PARTIES.ATTRIBUTE10%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE11                	OKE_POOL_PARTIES.ATTRIBUTE11%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE12                	OKE_POOL_PARTIES.ATTRIBUTE12%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE13                	OKE_POOL_PARTIES.ATTRIBUTE13%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE14                	OKE_POOL_PARTIES.ATTRIBUTE14%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE15                	OKE_POOL_PARTIES.ATTRIBUTE15%TYPE:=OKE_API.G_MISS_CHAR
);

TYPE party_tbl_type IS TABLE OF party_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKE_PARTY_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKE_API.G_APP_NAME;
  G_VIEW          		CONSTANT VARCHAR2(200) := 'OKE_POOL_PARTIES';

  G_EXCEPTION_HALT_VALIDATION exception;

-- Procedures and functions

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec                      IN party_rec_type,
    x_party_rec                      OUT NOCOPY party_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl                     IN party_tbl_type,
    x_party_tbl                     OUT NOCOPY party_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec                     IN party_rec_type,
    x_party_rec                     OUT NOCOPY party_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl                     IN party_tbl_type,
    x_party_tbl                     OUT NOCOPY party_tbl_type);



  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec                     IN party_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_tbl                     IN party_tbl_type);


  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_party_rec                     IN party_rec_type);


END OKE_PARTY_PVT;


 

/
