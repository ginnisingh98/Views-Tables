--------------------------------------------------------
--  DDL for Package OKL_RCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RCS_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLSRCSS.pls 120.2 2005/11/29 14:23:08 viselvar noship $ */
--------------------------------------------------------------------------------
--GLOBAL DATASTRUCTURES
--------------------------------------------------------------------------------
TYPE okl_rcsv_rec IS RECORD (
	RESI_CATEGORY_SET_ID	NUMBER ,
    ORIG_RESI_CAT_SET_ID    NUMBER ,
	OBJECT_VERSION_NUMBER	NUMBER,
	ORG_ID					NUMBER,
	SOURCE_CODE				OKL_FE_RESI_CAT_V.SOURCE_CODE%TYPE,
	STS_CODE				OKL_FE_RESI_CAT_V.STS_CODE%TYPE,
	RESI_CAT_NAME			OKL_FE_RESI_CAT_V.RESI_CAT_NAME%TYPE,
	RESI_CAT_DESC			OKL_FE_RESI_CAT_V.RESI_CAT_DESC%TYPE,
	SFWT_FLAG				OKL_FE_RESI_CAT_V.SFWT_FLAG%TYPE,
	CREATED_BY				NUMBER,
	CREATION_DATE			OKL_FE_RESI_CAT_V.CREATION_DATE%TYPE,
	LAST_UPDATED_BY			NUMBER ,
	LAST_UPDATE_DATE		OKL_FE_RESI_CAT_V.LAST_UPDATE_DATE%TYPE,
	LAST_UPDATE_LOGIN		NUMBER );

TYPE okl_rcsv_tbl IS TABLE OF okl_rcsv_rec
INDEX BY BINARY_INTEGER;
TYPE okl_rcsb_rec IS RECORD (
	RESI_CATEGORY_SET_ID	 NUMBER,
	RESI_CAT_NAME			 OKL_FE_RESI_CAT_ALL_B.RESI_CAT_NAME%TYPE,
	OBJECT_VERSION_NUMBER	 NUMBER,
    ORIG_RESI_CAT_SET_ID     NUMBER,
	ORG_ID					 NUMBER,
	SOURCE_CODE				 OKL_FE_RESI_CAT_ALL_B.SOURCE_CODE%TYPE,
	STS_CODE				 OKL_FE_RESI_CAT_ALL_B.STS_CODE%TYPE,
	CREATED_BY				 NUMBER ,
	CREATION_DATE			 OKL_FE_RESI_CAT_ALL_B.CREATION_DATE%TYPE ,
	LAST_UPDATED_BY			 NUMBER ,
	LAST_UPDATE_DATE		 OKL_FE_RESI_CAT_ALL_B.LAST_UPDATE_DATE%TYPE ,
	LAST_UPDATE_LOGIN		 NUMBER );

TYPE okl_rcsb_tbl IS TABLE OF okl_rcsb_rec
INDEX BY BINARY_INTEGER;
TYPE okl_rcstl_rec IS RECORD (
	RESI_CATEGORY_SET_ID					NUMBER := OKL_API.G_MISS_NUM ,
	LANGUAGE				OKL_FE_RESI_CAT_ALL_TL.LANGUAGE%TYPE := OKL_API.G_MISS_CHAR ,
	SOURCE_LANG				OKL_FE_RESI_CAT_ALL_TL.SOURCE_LANG%TYPE := OKL_API.G_MISS_CHAR ,
	SFWT_FLAG				OKL_FE_RESI_CAT_ALL_TL.SFWT_FLAG%TYPE := OKL_API.G_MISS_CHAR ,
	CREATED_BY				NUMBER := OKL_API.G_MISS_NUM ,
	CREATION_DATE				OKL_FE_RESI_CAT_ALL_TL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE ,
	LAST_UPDATED_BY				NUMBER := OKL_API.G_MISS_NUM ,
	LAST_UPDATE_DATE			OKL_FE_RESI_CAT_ALL_TL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE ,
	LAST_UPDATE_LOGIN			NUMBER := OKL_API.G_MISS_NUM ,
	RESI_CAT_DESC				OKL_FE_RESI_CAT_ALL_TL.RESI_CAT_DESC%TYPE := OKL_API.G_MISS_CHAR );

TYPE okl_rcstl_tbl IS TABLE OF okl_rcstl_rec
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
-- GLOBAL CONSTANTS
--------------------------------------------------------------------------------
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_RCS_PVT';
G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_CAT_ITEM          CONSTANT VARCHAR2(30)  :=  'ITEM';
G_CAT_ITEM_CAT      CONSTANT VARCHAR2(30)  :=  'ITEMCAT';
G_STS_ACTIVE        CONSTANT VARCHAR2(30)  :=  'ACTIVE';
G_STS_INACTIVE      CONSTANT VARCHAR2(30)  :=  'INACTIVE';

--------------------------------------------------------------------------------
-- Procedures and Functions
--------------------------------------------------------------------------------
PROCEDURE change_version;
PROCEDURE api_copy;

PROCEDURE add_language;

PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_rec			 IN okl_rcsv_rec,
	 x_rcsv_rec			 OUT NOCOPY okl_rcsv_rec);
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_tbl			 IN okl_rcsv_tbl,
	 x_rcsv_tbl			 OUT NOCOPY okl_rcsv_tbl);
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_rec			 IN okl_rcsv_rec,
	 x_rcsv_rec			 OUT NOCOPY okl_rcsv_rec);
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_tbl			 IN okl_rcsv_tbl,
	 x_rcsv_tbl			 OUT NOCOPY okl_rcsv_tbl);
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_rec			 IN okl_rcsv_rec);
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_tbl			 IN okl_rcsv_tbl);
END OKL_RCS_PVT;

 

/
