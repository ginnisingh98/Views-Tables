--------------------------------------------------------
--  DDL for Package OKE_POOL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_POOL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKEVFPLS.pls 115.6 2002/08/14 01:45:03 alaw ship $*/
-- GLOBAL DATA STRUCTURES

TYPE pool_rec_type IS RECORD(

 FUNDING_POOL_ID		NUMBER:= OKE_API.G_MISS_NUM,
 NAME				OKE_FUNDING_POOLS.NAME%TYPE:=OKE_API.G_MISS_CHAR,
 DESCRIPTION			OKE_FUNDING_POOLS.DESCRIPTION%TYPE:=OKE_API.G_MISS_CHAR,
 CURRENCY_CODE			OKE_FUNDING_POOLS.CURRENCY_CODE%TYPE:=OKE_API.G_MISS_CHAR,
 CONTACT_PERSON_ID		NUMBER:= OKE_API.G_MISS_NUM,
 PROGRAM_ID			NUMBER:= OKE_API.G_MISS_NUM,
 CREATION_DATE                  DATE:= OKE_API.G_MISS_DATE,
 CREATED_BY			NUMBER:= OKE_API.G_MISS_NUM,
 LAST_UPDATE_DATE               DATE:= OKE_API.G_MISS_DATE,
 LAST_UPDATED_BY		NUMBER:= OKE_API.G_MISS_NUM,
 LAST_UPDATE_LOGIN		NUMBER:= OKE_API.G_MISS_NUM,
 ATTRIBUTE_CATEGORY             OKE_FUNDING_POOLS.ATTRIBUTE_CATEGORY%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE1                	OKE_FUNDING_POOLS.ATTRIBUTE1%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE2                	OKE_FUNDING_POOLS.ATTRIBUTE2%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE3                	OKE_FUNDING_POOLS.ATTRIBUTE3%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE4                	OKE_FUNDING_POOLS.ATTRIBUTE4%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE5                	OKE_FUNDING_POOLS.ATTRIBUTE5%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE6                	OKE_FUNDING_POOLS.ATTRIBUTE6%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE7                	OKE_FUNDING_POOLS.ATTRIBUTE7%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE8                	OKE_FUNDING_POOLS.ATTRIBUTE8%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE9                	OKE_FUNDING_POOLS.ATTRIBUTE9%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE10                	OKE_FUNDING_POOLS.ATTRIBUTE10%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE11                	OKE_FUNDING_POOLS.ATTRIBUTE11%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE12                	OKE_FUNDING_POOLS.ATTRIBUTE12%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE13                	OKE_FUNDING_POOLS.ATTRIBUTE13%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE14                	OKE_FUNDING_POOLS.ATTRIBUTE14%TYPE:=OKE_API.G_MISS_CHAR,
 ATTRIBUTE15                	OKE_FUNDING_POOLS.ATTRIBUTE15%TYPE:=OKE_API.G_MISS_CHAR
);

TYPE pool_tbl_type IS TABLE OF pool_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKE_POOL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKE_API.G_APP_NAME;
  G_VIEW          		CONSTANT VARCHAR2(200) := 'OKE_FUNDING_POOLS';

  G_EXCEPTION_HALT_VALIDATION exception;

-- Procedures and functions

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec                      IN pool_rec_type,
    x_pool_rec                      OUT NOCOPY pool_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl                     IN pool_tbl_type,
    x_pool_tbl                     OUT NOCOPY pool_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec                     IN pool_rec_type,
    x_pool_rec                     OUT NOCOPY pool_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl                     IN pool_tbl_type,
    x_pool_tbl                     OUT NOCOPY pool_tbl_type);


/* note: does not cascade into lines */

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec                     IN pool_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl                     IN pool_tbl_type);


  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec                     IN pool_rec_type);


END OKE_POOL_PVT;


 

/
