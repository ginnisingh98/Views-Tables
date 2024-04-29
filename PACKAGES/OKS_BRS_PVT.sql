--------------------------------------------------------
--  DDL for Package OKS_BRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BRS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBRSS.pls 120.0 2005/05/25 18:11:16 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_BILLRATE_SCHEDULES_V Record Spec
  TYPE OksBillrateSchedulesVRecType IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,bt_cle_id                      NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,start_hour                     NUMBER := OKC_API.G_MISS_NUM
    ,start_minute                   NUMBER := OKC_API.G_MISS_NUM
    ,end_hour                       NUMBER := OKC_API.G_MISS_NUM
    ,end_minute                     NUMBER := OKC_API.G_MISS_NUM
    ,monday_flag                    OKS_BILLRATE_SCHEDULES_V.MONDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,tuesday_flag                   OKS_BILLRATE_SCHEDULES_V.TUESDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,wednesday_flag                 OKS_BILLRATE_SCHEDULES_V.WEDNESDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,thursday_flag                  OKS_BILLRATE_SCHEDULES_V.THURSDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,friday_flag                    OKS_BILLRATE_SCHEDULES_V.FRIDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,saturday_flag                  OKS_BILLRATE_SCHEDULES_V.SATURDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,sunday_flag                    OKS_BILLRATE_SCHEDULES_V.SUNDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,object1_id1                    OKS_BILLRATE_SCHEDULES_V.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,object1_id2                    OKS_BILLRATE_SCHEDULES_V.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,jtot_object1_code              OKS_BILLRATE_SCHEDULES_V.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,bill_rate_code                 OKS_BILLRATE_SCHEDULES_V.BILL_RATE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,uom                            OKS_BILLRATE_SCHEDULES_V.UOM%TYPE := OKC_API.G_MISS_CHAR
    ,flat_rate                      NUMBER := OKC_API.G_MISS_NUM
    ,holiday_yn                     OKS_BILLRATE_SCHEDULES_V.HOLIDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,percent_over_list_price        NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_BILLRATE_SCHEDULES_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_BILLRATE_SCHEDULES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_BILLRATE_SCHEDULES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,security_group_id              NUMBER := OKC_API.G_MISS_NUM);
  GMissOksBillrateSchedulesVRec           OksBillrateSchedulesVRecType;
  TYPE OksBillrateSchedulesVTblType IS TABLE OF OksBillrateSchedulesVRecType
        INDEX BY BINARY_INTEGER;
  -- OKS_BILLRATE_SCHEDULES Record Spec
  TYPE OksBillrateSchedulesRecType IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,bt_cle_id                      NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,start_hour                     NUMBER := OKC_API.G_MISS_NUM
    ,start_minute                   NUMBER := OKC_API.G_MISS_NUM
    ,end_hour                       NUMBER := OKC_API.G_MISS_NUM
    ,end_minute                     NUMBER := OKC_API.G_MISS_NUM
    ,monday_flag                    OKS_BILLRATE_SCHEDULES.MONDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,tuesday_flag                   OKS_BILLRATE_SCHEDULES.TUESDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,wednesday_flag                 OKS_BILLRATE_SCHEDULES.WEDNESDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,thursday_flag                  OKS_BILLRATE_SCHEDULES.THURSDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,friday_flag                    OKS_BILLRATE_SCHEDULES.FRIDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,saturday_flag                  OKS_BILLRATE_SCHEDULES.SATURDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,sunday_flag                    OKS_BILLRATE_SCHEDULES.SUNDAY_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,object1_id1                    OKS_BILLRATE_SCHEDULES.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR
    ,object1_id2                    OKS_BILLRATE_SCHEDULES.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR
    ,jtot_object1_code              OKS_BILLRATE_SCHEDULES.JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,bill_rate_code                 OKS_BILLRATE_SCHEDULES.BILL_RATE_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,flat_rate                      NUMBER := OKC_API.G_MISS_NUM
    ,uom                            OKS_BILLRATE_SCHEDULES.UOM%TYPE := OKC_API.G_MISS_CHAR
    ,holiday_yn                     OKS_BILLRATE_SCHEDULES.HOLIDAY_YN%TYPE := OKC_API.G_MISS_CHAR
    ,percent_over_list_price        NUMBER := OKC_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKS_BILLRATE_SCHEDULES.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_BILLRATE_SCHEDULES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_BILLRATE_SCHEDULES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM);
  GMissOksBillrateSchedulesRec            OksBillrateSchedulesRecType;
  TYPE OksBillrateSchedulesTblType IS TABLE OF OksBillrateSchedulesRecType
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_BRS_PVT';
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
    p_oks_billrate_schedules_v_rec IN OksBillrateSchedulesVRecType,
    x_oks_billrate_schedules_v_rec OUT NOCOPY OksBillrateSchedulesVRecType);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType,
    x_oks_billrate_schedules_v_tbl OUT NOCOPY OksBillrateSchedulesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType,
    x_oks_billrate_schedules_v_tbl OUT NOCOPY OksBillrateSchedulesVTblType);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_rec IN OksBillrateSchedulesVRecType);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_rec IN OksBillrateSchedulesVRecType,
    x_oks_billrate_schedules_v_rec OUT NOCOPY OksBillrateSchedulesVRecType);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType,
    x_oks_billrate_schedules_v_tbl OUT NOCOPY OksBillrateSchedulesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType,
    x_oks_billrate_schedules_v_tbl OUT NOCOPY OksBillrateSchedulesVTblType);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_rec IN OksBillrateSchedulesVRecType);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_rec IN OksBillrateSchedulesVRecType);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_billrate_schedules_v_tbl IN OksBillrateSchedulesVTblType);


FUNCTION Create_Version(
             p_id         IN NUMBER,
             p_major_version  IN NUMBER) RETURN VARCHAR2;

FUNCTION restore_version(
             p_id               IN NUMBER,
             p_major_version    IN NUMBER) RETURN VARCHAR2;




END OKS_BRS_PVT;

 

/
