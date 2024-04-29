--------------------------------------------------------
--  DDL for Package OKC_RLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_RLD_PVT" AUTHID CURRENT_USER as
/* $Header: OKCSRLDS.pls 120.0 2005/05/26 09:41:36 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKC_RULE_DEFS_V Record Spec
  TYPE okc_rule_defs_v_rec_type IS RECORD (
     application_id                 NUMBER := OKC_API.G_MISS_NUM
    ,application_name               OKC_RULE_DEFS_V.APPLICATION_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,rule_code                      OKC_RULE_DEFS_V.RULE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,descriptive_flexfield_name     OKC_RULE_DEFS_V.DESCRIPTIVE_FLEXFIELD_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,meaning                        OKC_RULE_DEFS_V.MEANING%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKC_RULE_DEFS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKC_RULE_DEFS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKC_RULE_DEFS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKC_RULE_DEFS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_okc_rule_defs_v_rec              okc_rule_defs_v_rec_type;
  TYPE okc_rule_defs_v_tbl_type IS TABLE OF okc_rule_defs_v_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKC_RULE_DEFS_B Record Spec
  TYPE okc_rule_defs_b_rec_type IS RECORD (
     rule_code                      OKC_RULE_DEFS_B.RULE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,application_id                 NUMBER := OKC_API.G_MISS_NUM
    ,descriptive_flexfield_name     OKC_RULE_DEFS_B.DESCRIPTIVE_FLEXFIELD_NAME%TYPE := OKC_API.G_MISS_CHAR
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKC_RULE_DEFS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKC_RULE_DEFS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_okc_rule_defs_b_rec              okc_rule_defs_b_rec_type;
  TYPE okc_rule_defs_b_tbl_type IS TABLE OF okc_rule_defs_b_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKC_RULE_DEFS_TL Record Spec
  TYPE okc_rule_defs_tl_rec_type IS RECORD (
     rule_code                      OKC_RULE_DEFS_TL.RULE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,meaning                        OKC_RULE_DEFS_TL.MEANING%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKC_RULE_DEFS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,language                       OKC_RULE_DEFS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    OKC_RULE_DEFS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKC_RULE_DEFS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKC_RULE_DEFS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKC_RULE_DEFS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_okc_rule_defs_tl_rec             okc_rule_defs_tl_rec_type;
  TYPE okc_rule_defs_tl_tbl_type IS TABLE OF okc_rule_defs_tl_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKC_RLD_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type,
    x_okc_rule_defs_v_rec          OUT NOCOPY okc_rule_defs_v_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    x_okc_rule_defs_v_tbl          OUT NOCOPY okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    x_okc_rule_defs_v_tbl          OUT NOCOPY okc_rule_defs_v_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type,
    x_okc_rule_defs_v_rec          OUT NOCOPY okc_rule_defs_v_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    x_okc_rule_defs_v_tbl          OUT NOCOPY okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    x_okc_rule_defs_v_tbl          OUT NOCOPY okc_rule_defs_v_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_rec          IN okc_rule_defs_v_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_rule_defs_v_tbl          IN okc_rule_defs_v_tbl_type);

  function GET_appl_id (
    rule_code   IN VARCHAR2 DEFAULT NULL) return number;
  function GET_dff_name (
    rule_code   IN VARCHAR2 DEFAULT NULL) return varchar2;

END OKC_RLD_PVT;

 

/
