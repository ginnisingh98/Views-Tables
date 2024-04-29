--------------------------------------------------------
--  DDL for Package OKS_ACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSACTYS.pls 120.1 2005/07/15 09:17:14 parkumar noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_ACTION_TIME_TYPES_V Record Spec
  TYPE OksActionTimeTypesVRecType IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,action_type_code               OKS_ACTION_TIME_TYPES_V.ACTION_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_ACTION_TIME_TYPES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_ACTION_TIME_TYPES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_ACTION_TIME_TYPES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
-- R12 Data Model Changes 4485150 Start
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_ACTION_TIME_TYPES_V.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_ACTION_TIME_TYPES_V.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
);
  GMissOksActionTimeTypesVRec             OksActionTimeTypesVRecType;
  TYPE OksActionTimeTypesVTblType IS TABLE OF OksActionTimeTypesVRecType
        INDEX BY BINARY_INTEGER;
  -- OKS_ACTION_TIME_TYPES Record Spec
  TYPE oks_action_time_types_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,action_type_code               OKS_ACTION_TIME_TYPES.ACTION_TYPE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_ACTION_TIME_TYPES.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_ACTION_TIME_TYPES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_ACTION_TIME_TYPES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
-- R12 Data Model Changes 4485150 Start
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_ACTION_TIME_TYPES_V.ORIG_SYSTEM_REFERENCE1%TYPE := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_ACTION_TIME_TYPES_V.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
);
  GMissOksActionTimeTypesRec              oks_action_time_types_rec_type;
  TYPE oks_action_time_types_tbl_type IS TABLE OF oks_action_time_types_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_ACT_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType,
    x_oks_action_time_types_v_rec  OUT NOCOPY OksActionTimeTypesVRecType);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    x_oks_action_time_types_v_tbl  OUT NOCOPY OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    x_oks_action_time_types_v_tbl  OUT NOCOPY OksActionTimeTypesVTblType);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType,
    x_oks_action_time_types_v_rec  OUT NOCOPY OksActionTimeTypesVRecType);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    x_oks_action_time_types_v_tbl  OUT NOCOPY OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    x_oks_action_time_types_v_tbl  OUT NOCOPY OksActionTimeTypesVTblType);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType);

	FUNCTION Create_Version(
                            p_id         IN NUMBER,
                            p_major_version  IN NUMBER
                            )RETURN VARCHAR2 ;
	FUNCTION restore_version(
   				          	p_id               IN NUMBER,
             				p_major_version    IN NUMBER) RETURN VARCHAR2;



END OKS_ACT_PVT;

 

/
