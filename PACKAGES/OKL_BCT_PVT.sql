--------------------------------------------------------
--  DDL for Package OKL_BCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_BCT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSBCTS.pls 120.2 2007/05/11 22:46:45 asahoo ship $ */

--------------------------------------------------------------------------------
--GLOBAL DATASTRUCTURES
--------------------------------------------------------------------------------
TYPE okl_bct_rec IS RECORD (
    USER_ID                 NUMBER := OKL_API.G_MISS_NUM ,
    ORG_ID                  NUMBER := OKL_API.G_MISS_NUM ,
    BATCH_NUMBER            NUMBER := OKL_API.G_MISS_NUM ,
    PROCESSING_SRL_NUMBER   NUMBER := OKL_API.G_MISS_NUM ,
    KHR_ID                  NUMBER := OKL_API.G_MISS_NUM ,
    PROGRAM_NAME            OKL_BOOK_CONTROLLER_TRX.PROGRAM_NAME%TYPE := OKL_API.G_MISS_CHAR ,
    PROG_SHORT_NAME         OKL_BOOK_CONTROLLER_TRX.PROG_SHORT_NAME%TYPE := OKL_API.G_MISS_CHAR ,
    CONC_REQ_ID             NUMBER := OKL_API.G_MISS_NUM ,
    PROGRESS_STATUS         OKL_BOOK_CONTROLLER_TRX.PROGRESS_STATUS%TYPE := OKL_API.G_MISS_CHAR ,
    CREATED_BY              NUMBER := OKL_API.G_MISS_NUM ,
    CREATION_DATE           OKL_BOOK_CONTROLLER_TRX.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE ,
    LAST_UPDATED_BY         NUMBER := OKL_API.G_MISS_NUM ,
    LAST_UPDATE_DATE        OKL_BOOK_CONTROLLER_TRX.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE ,
    LAST_UPDATE_LOGIN       NUMBER := OKL_API.G_MISS_NUM ,
    ACTIVE_FLAG             OKL_BOOK_CONTROLLER_TRX.ACTIVE_FLAG%TYPE := OKL_API.G_MISS_CHAR );

TYPE okl_bct_tbl IS TABLE OF okl_bct_rec
INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
--------------------------------------------------------------------------------
G_FND_APP                     CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC  CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
G_FORM_RECORD_DELETED         CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
G_FORM_RECORD_CHANGED         CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
G_RECORD_LOGICALLY_DELETED    CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
G_PARENT_TABLE_TOKEN          CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
G_CHILD_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
--------------------------------------------------------------------------------
-- GLOBAL VARIABLES
--------------------------------------------------------------------------------
G_PKG_NAME          CONSTANT VARCHAR2(200) := 'OKL_BCT_PVT';
G_APP_NAME          CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

--------------------------------------------------------------------------------
-- Procedures and Functions
--------------------------------------------------------------------------------
PROCEDURE change_version;
PROCEDURE api_copy;

-----------------------------------------------------------------------------
-- PROCEDURE insert_row
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : insert_row
-- Description     : Procedure to insert record into okl_book_controller_trx
-- Business Rules  :
-- Parameters      : p_bct_rec,x_bct_rec
-- Version         : 1.0
-- History         : XX-XXX-XXXX TAPI Generator Created
-- End of comments
PROCEDURE insert_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_rec         IN okl_bct_rec,
     x_bct_rec         OUT NOCOPY okl_bct_rec);

-----------------------------------------------------------------------------
-- PROCEDURE insert_row
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : insert_row
-- Description     : Procedure to insert table of records into
--                   okl_book_controller_trx
-- Business Rules  :
-- Parameters      : p_bct_tbl,x_bct_tbl
-- Version         : 1.0
-- History         : XX-XXX-XXXX TAPI Generator Created
-- End of comments
PROCEDURE insert_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_tbl         IN okl_bct_tbl,
     x_bct_tbl         OUT NOCOPY okl_bct_tbl);

-----------------------------------------------------------------------------
-- PROCEDURE update_row
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : update_row
-- Description     : Procedure to update record in okl_book_controller_trx
-- Business Rules  :
-- Parameters      : p_bct_rec,x_bct_rec
-- Version         : 1.0
-- History         : XX-XXX-XXXX TAPI Generator Created
-- End of comments
PROCEDURE update_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_rec         IN okl_bct_rec,
     x_bct_rec         OUT NOCOPY okl_bct_rec);

-----------------------------------------------------------------------------
-- PROCEDURE update_row
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : update_row
-- Description     : Procedure to update table of records in
--                   okl_book_controller_trx
-- Business Rules  :
-- Parameters      : p_bct_tbl,x_bct_tbl
-- Version         : 1.0
-- History         : XX-XXX-XXXX TAPI Generator Created
-- End of comments
PROCEDURE update_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_tbl         IN okl_bct_tbl,
     x_bct_tbl         OUT NOCOPY okl_bct_tbl);

-----------------------------------------------------------------------------
-- PROCEDURE delete_row
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : delete_row
-- Description     : Procedure to delete record from okl_book_controller_trx
-- Business Rules  :
-- Parameters      : p_bct_rec
-- Version         : 1.0
-- History         : XX-XXX-XXXX TAPI Generator Created
-- End of comments
PROCEDURE delete_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_rec         IN okl_bct_rec);

-----------------------------------------------------------------------------
-- PROCEDURE delete_row
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : delete_row
-- Description     : Procedure to delete table of record from
--                   okl_book_controller_trx
-- Business Rules  :
-- Parameters      : p_bct_tbl
-- Version         : 1.0
-- History         : XX-XXX-XXXX TAPI Generator Created
-- End of comments
PROCEDURE delete_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_tbl         IN okl_bct_tbl);

END OKL_BCT_PVT;

/
