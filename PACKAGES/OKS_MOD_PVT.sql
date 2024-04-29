--------------------------------------------------------
--  DDL for Package OKS_MOD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_MOD_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRMODS.pls 120.0 2005/05/25 17:53:13 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_MSCHG_OPERATIONS_DTLS_V Record Spec
  TYPE OksMschgOperationsDtlsVRecType IS RECORD (
     id                             NUMBER  --:= OKC_API.G_MISS_NUM
    ,mrd_id                         NUMBER  --:= OKC_API.G_MISS_NUM
    ,oie_id                         NUMBER  --:= OKC_API.G_MISS_NUM
    ,ole_id                         NUMBER  --:= OKC_API.G_MISS_NUM
    ,mschg_type                     OKS_MSCHG_OPERATIONS_DTLS_V.MSCHG_TYPE%TYPE  --:= OKC_API.G_MISS_CHAR
    ,attribute_level                OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE_LEVEL%TYPE  -- := OKC_API.G_MISS_CHAR
    ,qa_check_yn                    OKS_MSCHG_OPERATIONS_DTLS_V.QA_CHECK_YN%TYPE  --:= OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER  --:= OKC_API.G_MISS_NUM
    ,created_by                     NUMBER  --:= OKC_API.G_MISS_NUM
    ,creation_date                  OKS_MSCHG_OPERATIONS_DTLS_V.CREATION_DATE%TYPE  --:= OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER  --:= OKC_API.G_MISS_NUM
    ,last_update_date               OKS_MSCHG_OPERATIONS_DTLS_V.LAST_UPDATE_DATE%TYPE  --:= OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER  --:= OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER  --:= OKC_API.G_MISS_NUM
    ,attribute1                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE1%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute2                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE2%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute3                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE3%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute4                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE4%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute5                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE5%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute6                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE6%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute7                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE7%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute8                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE8%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute9                     OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE9%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute10                    OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE10%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute11                    OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE11%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute12                    OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE12%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute13                    OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE13%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute14                    OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE14%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute15                    OKS_MSCHG_OPERATIONS_DTLS_V.ATTRIBUTE15%TYPE --:= OKC_API.G_MISS_CHAR
    );
  GMissOksmschgprtinsdtlsvrc              OksMschgOperationsDtlsVRecType;
  TYPE OksMschgOperationsDtlsVTblType IS TABLE OF OksMschgOperationsDtlsVRecType
        INDEX BY BINARY_INTEGER;
  -- OKS_MSCHG_OPERATIONS_DTLS Record Spec
  TYPE OksMschgOperationsDtlsRecType IS RECORD (
     id                             NUMBER --:= OKC_API.G_MISS_NUM
    ,mrd_id                         NUMBER --:= OKC_API.G_MISS_NUM
    ,oie_id                         NUMBER --:= OKC_API.G_MISS_NUM
    ,ole_id                         NUMBER --:= OKC_API.G_MISS_NUM
    ,mschg_type                     OKS_MSCHG_OPERATIONS_DTLS.MSCHG_TYPE%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute_level                OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE_LEVEL%TYPE --:= OKC_API.G_MISS_CHAR
    ,qa_check_yn                    OKS_MSCHG_OPERATIONS_DTLS.QA_CHECK_YN%TYPE --:= OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER --:= OKC_API.G_MISS_NUM
    ,created_by                     NUMBER --:= OKC_API.G_MISS_NUM
    ,creation_date                  OKS_MSCHG_OPERATIONS_DTLS.CREATION_DATE%TYPE --:= OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER --:= OKC_API.G_MISS_NUM
    ,last_update_date               OKS_MSCHG_OPERATIONS_DTLS.LAST_UPDATE_DATE%TYPE --:= OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER --:= OKC_API.G_MISS_NUM
    ,attribute1                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE1%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute2                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE2%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute3                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE3%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute4                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE4%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute5                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE5%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute6                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE6%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute7                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE7%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute8                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE8%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute9                     OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE9%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute10                    OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE10%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute11                    OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE11%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute12                    OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE12%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute13                    OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE13%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute14                    OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE14%TYPE --:= OKC_API.G_MISS_CHAR
    ,attribute15                    OKS_MSCHG_OPERATIONS_DTLS.ATTRIBUTE15%TYPE --:= OKC_API.G_MISS_CHAR
    );
  GMissOksMschgOperationsDtlsRec          OksMschgOperationsDtlsRecType;
  TYPE OksMschgOperationsDtlsTblType IS TABLE OF OksMschgOperationsDtlsRecType
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := '_OKS_MOD_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType,
    XOksMschgOperationsDtlsVRec    OUT NOCOPY OksMschgOperationsDtlsVRecType);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    XOksMschgOperationsDtlsVTbl    OUT NOCOPY OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    XOksMschgOperationsDtlsVTbl    OUT NOCOPY OksMschgOperationsDtlsVTblType);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType,
    XOksMschgOperationsDtlsVRec    OUT NOCOPY OksMschgOperationsDtlsVRecType);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    XOksMschgOperationsDtlsVTbl    OUT NOCOPY OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    XOksMschgOperationsDtlsVTbl    OUT NOCOPY OksMschgOperationsDtlsVTblType);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType);
END OKS_MOD_PVT;


 

/
