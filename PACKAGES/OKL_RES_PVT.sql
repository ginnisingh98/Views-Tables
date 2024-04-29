--------------------------------------------------------
--  DDL for Package OKL_RES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RES_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLSRESS.pls 120.0 2005/07/08 14:26:23 smadhava noship $ */
--------------------------------------------------------------------------------
--GLOBAL DATASTRUCTURES
--------------------------------------------------------------------------------
TYPE okl_res_rec IS RECORD (
	RESI_CAT_OBJECT_ID		NUMBER ,
	OBJECT_VERSION_NUMBER	NUMBER ,
	RESI_CATEGORY_SET_ID	NUMBER ,
	CREATED_BY				NUMBER ,
	CREATION_DATE			OKL_FE_RESI_CAT_OBJECTS.CREATION_DATE%TYPE ,
	LAST_UPDATED_BY			NUMBER ,
	LAST_UPDATE_DATE		OKL_FE_RESI_CAT_OBJECTS.LAST_UPDATE_DATE%TYPE ,
	LAST_UPDATE_LOGIN		NUMBER ,
	INVENTORY_ITEM_ID		NUMBER ,
	ORGANIZATION_ID			NUMBER ,
	CATEGORY_ID				NUMBER ,
	CATEGORY_SET_ID			NUMBER );

TYPE okl_res_tbl IS TABLE OF okl_res_rec
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
--------------------------------------------------------------------------------
G_FND_APP			CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE	 		CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
G_API_VERSION          CONSTANT NUMBER        := 1;
G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
--------------------------------------------------------------------------------
-- GLOBAL VARIABLES
--------------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_RES_PVT';
G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

--------------------------------------------------------------------------------
-- Procedures and Functions
--------------------------------------------------------------------------------
PROCEDURE change_version;
PROCEDURE api_copy;

PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_rec			 IN okl_res_rec,
	 x_res_rec			 OUT NOCOPY okl_res_rec);
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_tbl			 IN okl_res_tbl,
	 x_res_tbl			 OUT NOCOPY okl_res_tbl);
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_rec			 IN okl_res_rec,
	 x_res_rec			 OUT NOCOPY okl_res_rec);
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_tbl			 IN okl_res_tbl,
	 x_res_tbl			 OUT NOCOPY okl_res_tbl);
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_rec			 IN okl_res_rec);
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_tbl			 IN okl_res_tbl);
END OKL_RES_PVT;

 

/
