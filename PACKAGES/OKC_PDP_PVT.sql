--------------------------------------------------------
--  DDL for Package OKC_PDP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PDP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSPDPS.pls 120.0 2005/05/25 18:31:07 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE OkcProcessDefParmsTlRecType IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_PROCESS_DEF_PARMS_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_PROCESS_DEF_PARMS_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_PROCESS_DEF_PARMS_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_PROCESS_DEF_PARMS_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_PROCESS_DEF_PARMS_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_PROCESS_DEF_PARMS_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PROCESS_DEF_PARMS_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcProcessDefParmsTlRec            OkcProcessDefParmsTlRecType;
  TYPE OkcProcessDefParmsTlTblType IS TABLE OF OkcProcessDefParmsTlRecType
        INDEX BY BINARY_INTEGER;
  TYPE pdp_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    pdf_id                         NUMBER := OKC_API.G_MISS_NUM,
    name                           OKC_PROCESS_DEF_PARMS_B.NAME%TYPE := OKC_API.G_MISS_CHAR,
    data_type                      OKC_PROCESS_DEF_PARMS_B.DATA_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    required_yn                    OKC_PROCESS_DEF_PARMS_B.REQUIRED_YN%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_PROCESS_DEF_PARMS_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PROCESS_DEF_PARMS_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    default_value                  OKC_PROCESS_DEF_PARMS_B.DEFAULT_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    seeded_flag                    OKC_PROCESS_DEF_PARMS_B.SEEDED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object_code               OKC_PROCESS_DEF_PARMS_B.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    NAME_COLUMN                    OKC_PROCESS_DEF_PARMS_B.NAME_COLUMN%TYPE := OKC_API.G_MISS_CHAR,
    description_column             OKC_PROCESS_DEF_PARMS_B.DESCRIPTION_COLUMN%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_pdp_rec                          pdp_rec_type;
  TYPE pdp_tbl_type IS TABLE OF pdp_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE pdpv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    sfwt_flag                      OKC_PROCESS_DEF_PARAMETERS_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    pdf_id                         NUMBER := OKC_API.G_MISS_NUM,
    name                           OKC_PROCESS_DEF_PARAMETERS_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    user_name                      OKC_PROCESS_DEF_PARAMETERS_V.USER_NAME%TYPE := OKC_API.G_MISS_CHAR,
    data_type                      OKC_PROCESS_DEF_PARAMETERS_V.DATA_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    default_value                  OKC_PROCESS_DEF_PARAMETERS_V.DEFAULT_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    required_yn                    OKC_PROCESS_DEF_PARAMETERS_V.REQUIRED_YN%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_PROCESS_DEF_PARAMETERS_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    application_id                 NUMBER := OKC_API.G_MISS_NUM,
    seeded_flag                    OKC_PROCESS_DEF_PARAMETERS_V.SEEDED_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_PROCESS_DEF_PARAMETERS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_PROCESS_DEF_PARAMETERS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    jtot_object_code               OKC_PROCESS_DEF_PARAMETERS_V.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    NAME_COLUMN                    OKC_PROCESS_DEF_PARAMETERS_V.NAME_COLUMN%TYPE := OKC_API.G_MISS_CHAR,
    description_column             OKC_PROCESS_DEF_PARAMETERS_V.DESCRIPTION_COLUMN%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_pdpv_rec                         pdpv_rec_type;
  TYPE pdpv_tbl_type IS TABLE OF pdpv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPERCASE_REQUIRED';
  G_NO_PARENT_RECORD	CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_PDP_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_VIEW			CONSTANT VARCHAR2(200)   :=  'OKC_PROCESS_DEF_PARAMETERS_V';
  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION         EXCEPTION;

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
    p_pdpv_rec                     IN pdpv_rec_type,
    x_pdpv_rec                     OUT NOCOPY pdpv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type,
    x_pdpv_tbl                     OUT NOCOPY pdpv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type,
    x_pdpv_rec                     OUT NOCOPY pdpv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type,
    x_pdpv_tbl                     OUT NOCOPY pdpv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_rec                     IN pdpv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdpv_tbl                     IN pdpv_tbl_type);

END OKC_PDP_PVT;

 

/
