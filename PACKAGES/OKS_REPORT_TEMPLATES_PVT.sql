--------------------------------------------------------
--  DDL for Package OKS_REPORT_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_REPORT_TEMPLATES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRTMPS.pls 120.1.12000000.1 2007/01/16 22:12:34 appldev ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKS_REPORT_TEMPLATES_V Record Spec
  TYPE rtmpv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,report_id                      NUMBER := OKC_API.G_MISS_NUM
    ,template_set_id                NUMBER := OKC_API.G_MISS_NUM
    ,template_set_type              OKS_REPORT_TEMPLATES_V.TEMPLATE_SET_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,start_date                     OKS_REPORT_TEMPLATES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,end_date                       OKS_REPORT_TEMPLATES_V.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,report_duration                NUMBER := OKC_API.G_MISS_NUM
    ,report_period                  OKS_REPORT_TEMPLATES_V.REPORT_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,sts_code                       OKS_REPORT_TEMPLATES_V.STS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,process_code                   OKS_REPORT_TEMPLATES_V.process_code%TYPE := OKC_API.G_MISS_CHAR
    ,applies_to                     OKS_REPORT_TEMPLATES_V.applies_to%TYPE := OKC_API.G_MISS_CHAR
    ,attachment_name                OKS_REPORT_TEMPLATES_V.attachment_name%TYPE := OKC_API.G_MISS_CHAR
    ,message_template_id            NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_REPORT_TEMPLATES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_REPORT_TEMPLATES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_rtmpv_rec                        rtmpv_rec_type;
  TYPE rtmpv_tbl_type IS TABLE OF rtmpv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_REPORT_TEMPLATES Record Spec
  TYPE rtmp_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,report_id                      NUMBER := OKC_API.G_MISS_NUM
    ,template_set_id                NUMBER := OKC_API.G_MISS_NUM
    ,template_set_type              OKS_REPORT_TEMPLATES.TEMPLATE_SET_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,start_date                     OKS_REPORT_TEMPLATES.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,end_date                       OKS_REPORT_TEMPLATES.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,report_duration                NUMBER := OKC_API.G_MISS_NUM
    ,report_period                  OKS_REPORT_TEMPLATES.REPORT_PERIOD%TYPE := OKC_API.G_MISS_CHAR
    ,sts_code                       OKS_REPORT_TEMPLATES.STS_CODE%TYPE := OKC_API.G_MISS_CHAR
    ,process_code                   OKS_REPORT_TEMPLATES_V.process_code%TYPE := OKC_API.G_MISS_CHAR
    ,applies_to                     OKS_REPORT_TEMPLATES_V.applies_to%TYPE := OKC_API.G_MISS_CHAR
    ,attachment_name                OKS_REPORT_TEMPLATES_V.attachment_name%TYPE := OKC_API.G_MISS_CHAR
    ,message_template_id            NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_REPORT_TEMPLATES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_REPORT_TEMPLATES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_rtmp_rec                         rtmp_rec_type;
  TYPE rtmp_tbl_type IS TABLE OF rtmp_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_REPORT_TEMPLATES_PVT';
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
    p_rtmpv_rec                    IN rtmpv_rec_type,
    x_rtmpv_rec                    OUT NOCOPY rtmpv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type,
    x_rtmpv_rec                    OUT NOCOPY rtmpv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type);
END OKS_REPORT_TEMPLATES_PVT;

 

/
