--------------------------------------------------------
--  DDL for Package OKL_IRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_IRV_PVT" AUTHID CURRENT_USER AS
  /* $Header: OKLSIRVS.pls 120.1 2005/07/22 10:01:27 smadhava noship $ */
--------------------------------------------------------------------------------
--GLOBAL DATASTRUCTURES
--------------------------------------------------------------------------------
TYPE okl_irv_rec IS RECORD (
	ITEM_RESDL_VALUE_ID     NUMBER ,
	OBJECT_VERSION_NUMBER   NUMBER ,
	ITEM_RESIDUAL_ID        NUMBER ,
	ITEM_RESDL_VERSION_ID   NUMBER ,
	TERM_IN_MONTHS          NUMBER ,
	RESIDUAL_VALUE			NUMBER ,
	CREATED_BY				NUMBER ,
	CREATION_DATE			OKL_FE_ITEM_RESDL_VALUES.CREATION_DATE%TYPE ,
	LAST_UPDATED_BY			NUMBER ,
	LAST_UPDATE_DATE		OKL_FE_ITEM_RESDL_VALUES.LAST_UPDATE_DATE%TYPE ,
	LAST_UPDATE_LOGIN		NUMBER );

TYPE okl_irv_tbl IS TABLE OF okl_irv_rec
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
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_IRV_PVT';
G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

--------------------------------------------------------------------------------
-- Procedures and Functions
--------------------------------------------------------------------------------
PROCEDURE change_version;
PROCEDURE api_copy;

PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_rec			 IN okl_irv_rec,
	 x_irv_rec			 OUT NOCOPY okl_irv_rec);
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_tbl			 IN okl_irv_tbl,
	 x_irv_tbl			 OUT NOCOPY okl_irv_tbl);
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_rec			 IN okl_irv_rec,
	 x_irv_rec			 OUT NOCOPY okl_irv_rec);
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_tbl			 IN okl_irv_tbl,
	 x_irv_tbl			 OUT NOCOPY okl_irv_tbl);
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_rec			 IN okl_irv_rec);
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_tbl			 IN okl_irv_tbl);
END OKL_IRV_PVT;

 

/
