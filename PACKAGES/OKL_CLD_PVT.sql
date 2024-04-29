--------------------------------------------------------
--  DDL for Package OKL_CLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CLD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSCLDS.pls 120.6 2006/07/11 10:15:07 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_CHECKLIST_DETAILS_V Record Spec
  TYPE cldv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,ckl_id                         NUMBER := OKL_API.G_MISS_NUM
    ,todo_item_code                 OKL_CHECKLIST_DETAILS.TODO_ITEM_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_CHECKLIST_DETAILS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CHECKLIST_DETAILS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CHECKLIST_DETAILS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CHECKLIST_DETAILS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CHECKLIST_DETAILS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CHECKLIST_DETAILS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CHECKLIST_DETAILS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CHECKLIST_DETAILS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CHECKLIST_DETAILS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CHECKLIST_DETAILS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CHECKLIST_DETAILS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CHECKLIST_DETAILS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CHECKLIST_DETAILS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CHECKLIST_DETAILS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CHECKLIST_DETAILS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CHECKLIST_DETAILS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_CHECKLIST_DETAILS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CHECKLIST_DETAILS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CHECKLIST_DETAILS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
-- start: Apr 25, 2005 cklee: Modification for okl.h
    ,MANDATORY_FLAG                 OKL_CHECKLIST_DETAILS.MANDATORY_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,USER_COMPLETE_FLAG             OKL_CHECKLIST_DETAILS.USER_COMPLETE_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,ADMIN_NOTE                     OKL_CHECKLIST_DETAILS.ADMIN_NOTE%TYPE := OKL_API.G_MISS_CHAR
    ,USER_NOTE                      OKL_CHECKLIST_DETAILS.USER_NOTE%TYPE := OKL_API.G_MISS_CHAR
    ,DNZ_CHECKLIST_OBJ_ID           NUMBER := OKL_API.G_MISS_NUM
    ,FUNCTION_ID                    NUMBER := OKL_API.G_MISS_NUM
    ,FUNCTION_VALIDATE_RSTS         OKL_CHECKLIST_DETAILS.FUNCTION_VALIDATE_RSTS%TYPE := OKL_API.G_MISS_CHAR
    ,FUNCTION_VALIDATE_MSG          OKL_CHECKLIST_DETAILS.FUNCTION_VALIDATE_MSG%TYPE := OKL_API.G_MISS_CHAR
    ,INST_CHECKLIST_TYPE            OKL_CHECKLIST_DETAILS.INST_CHECKLIST_TYPE%TYPE := OKL_API.G_MISS_CHAR
-- end: Apr 25, 2005 cklee: Modification for okl.h
--Bug 4872271 PAGARG Appeal flag column is added to store the marking for Appeal
    ,APPEAL_FLAG                    OKL_CHECKLIST_DETAILS.APPEAL_FLAG%TYPE := OKL_API.G_MISS_CHAR
    );
  G_MISS_cldv_rec                         cldv_rec_type;
  TYPE cldv_tbl_type IS TABLE OF cldv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_CHECKLIST_DETAILS Record Spec
  TYPE cld_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,ckl_id                         NUMBER := OKL_API.G_MISS_NUM
    ,todo_item_code                 OKL_CHECKLIST_DETAILS.TODO_ITEM_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,attribute_category             OKL_CHECKLIST_DETAILS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_CHECKLIST_DETAILS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_CHECKLIST_DETAILS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_CHECKLIST_DETAILS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_CHECKLIST_DETAILS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_CHECKLIST_DETAILS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_CHECKLIST_DETAILS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_CHECKLIST_DETAILS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_CHECKLIST_DETAILS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_CHECKLIST_DETAILS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_CHECKLIST_DETAILS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_CHECKLIST_DETAILS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_CHECKLIST_DETAILS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_CHECKLIST_DETAILS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_CHECKLIST_DETAILS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_CHECKLIST_DETAILS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_CHECKLIST_DETAILS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_CHECKLIST_DETAILS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_CHECKLIST_DETAILS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
-- start: Apr 25, 2005 cklee: Modification for okl.h
    ,MANDATORY_FLAG                 OKL_CHECKLIST_DETAILS.MANDATORY_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,USER_COMPLETE_FLAG             OKL_CHECKLIST_DETAILS.USER_COMPLETE_FLAG%TYPE := OKL_API.G_MISS_CHAR
    ,ADMIN_NOTE                     OKL_CHECKLIST_DETAILS.ADMIN_NOTE%TYPE := OKL_API.G_MISS_CHAR
    ,USER_NOTE                      OKL_CHECKLIST_DETAILS.USER_NOTE%TYPE := OKL_API.G_MISS_CHAR
    ,DNZ_CHECKLIST_OBJ_ID           NUMBER := OKL_API.G_MISS_NUM
    ,FUNCTION_ID                    NUMBER := OKL_API.G_MISS_NUM
    ,FUNCTION_VALIDATE_RSTS         OKL_CHECKLIST_DETAILS.FUNCTION_VALIDATE_RSTS%TYPE := OKL_API.G_MISS_CHAR
    ,FUNCTION_VALIDATE_MSG          OKL_CHECKLIST_DETAILS.FUNCTION_VALIDATE_MSG%TYPE := OKL_API.G_MISS_CHAR
    ,INST_CHECKLIST_TYPE            OKL_CHECKLIST_DETAILS.INST_CHECKLIST_TYPE%TYPE := OKL_API.G_MISS_CHAR
-- end: Apr 25, 2005 cklee: Modification for okl.h
--Bug 4872271 PAGARG Appeal flag column is added to store the marking for Appeal
    ,APPEAL_FLAG                    OKL_CHECKLIST_DETAILS.APPEAL_FLAG%TYPE := OKL_API.G_MISS_CHAR
    );
  G_MISS_cld_rec                          cld_rec_type;
  TYPE cld_tbl_type IS TABLE OF cld_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_SERVICE_AVAILABILITY_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_CLD_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_rec                     IN cldv_rec_type,
    x_cldv_rec                     OUT NOCOPY cldv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type,
    x_cldv_tbl                     OUT NOCOPY cldv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type,
    x_cldv_tbl                     OUT NOCOPY cldv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_rec                     IN cldv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_rec                     IN cldv_rec_type,
    x_cldv_rec                     OUT NOCOPY cldv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type,
    x_cldv_tbl                     OUT NOCOPY cldv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type,
    x_cldv_tbl                     OUT NOCOPY cldv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_rec                     IN cldv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_rec                     IN cldv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cldv_tbl                     IN cldv_tbl_type);
END OKL_CLD_PVT;

/
