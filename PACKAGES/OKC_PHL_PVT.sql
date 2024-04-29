--------------------------------------------------------
--  DDL for Package OKC_PHL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PHL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSPHLS.pls 120.0 2005/05/26 09:57:26 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKC_PH_LINE_BREAKS_V Record Spec
  TYPE okc_ph_line_breaks_v_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,value_from                     NUMBER := OKC_API.G_MISS_NUM
    ,value_to                       NUMBER := OKC_API.G_MISS_NUM
    ,pricing_type                   OKC_PH_LINE_BREAKS_V.PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,value                          NUMBER := OKC_API.G_MISS_NUM
    ,start_date                     OKC_PH_LINE_BREAKS_V.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,end_date                       OKC_PH_LINE_BREAKS_V.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKC_PH_LINE_BREAKS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKC_PH_LINE_BREAKS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKC_PH_LINE_BREAKS_V.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,integrated_with_qp             OKC_PH_LINE_BREAKS_V.INTEGRATED_WITH_QP%TYPE := OKC_API.G_MISS_CHAR
    ,qp_reference_id                NUMBER := OKC_API.G_MISS_NUM
    ,ship_to_organization_id        NUMBER := OKC_API.G_MISS_NUM
    ,ship_to_location_id            NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcPhLineBreaksVRec                okc_ph_line_breaks_v_rec_type;
  TYPE okc_ph_line_breaks_v_tbl_type IS TABLE OF okc_ph_line_breaks_v_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKC_PH_LINE_BREAKS Record Spec
  TYPE okc_ph_line_breaks_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,value_from                     NUMBER := OKC_API.G_MISS_NUM
    ,value_to                       NUMBER := OKC_API.G_MISS_NUM
    ,pricing_type                   OKC_PH_LINE_BREAKS.PRICING_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,value                          NUMBER := OKC_API.G_MISS_NUM
    ,start_date                     OKC_PH_LINE_BREAKS.START_DATE%TYPE := OKC_API.G_MISS_DATE
    ,end_date                       OKC_PH_LINE_BREAKS.END_DATE%TYPE := OKC_API.G_MISS_DATE
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKC_PH_LINE_BREAKS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKC_PH_LINE_BREAKS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,program_application_id         NUMBER := OKC_API.G_MISS_NUM
    ,program_id                     NUMBER := OKC_API.G_MISS_NUM
    ,program_update_date            OKC_PH_LINE_BREAKS.PROGRAM_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,request_id                     NUMBER := OKC_API.G_MISS_NUM
    ,integrated_with_qp             OKC_PH_LINE_BREAKS.INTEGRATED_WITH_QP%TYPE := OKC_API.G_MISS_CHAR
    ,qp_reference_id                NUMBER := OKC_API.G_MISS_NUM
    ,ship_to_organization_id        NUMBER := OKC_API.G_MISS_NUM
    ,ship_to_location_id            NUMBER := OKC_API.G_MISS_NUM
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  G_MISS_okc_ph_line_breaks_rec           okc_ph_line_breaks_rec_type;
  TYPE okc_ph_line_breaks_tbl_type IS TABLE OF okc_ph_line_breaks_rec_type
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
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKC_PHL_PVT';
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
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type,
    x_okc_ph_line_breaks_v_rec     OUT NOCOPY okc_ph_line_breaks_v_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    x_okc_ph_line_breaks_v_tbl     OUT NOCOPY okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    x_okc_ph_line_breaks_v_tbl     OUT NOCOPY okc_ph_line_breaks_v_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type,
    x_okc_ph_line_breaks_v_rec     OUT NOCOPY okc_ph_line_breaks_v_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    x_okc_ph_line_breaks_v_tbl     OUT NOCOPY okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    x_okc_ph_line_breaks_v_tbl     OUT NOCOPY okc_ph_line_breaks_v_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type);


    FUNCTION create_version(
       p_chr_id                                    IN NUMBER,
       p_major_version                             IN NUMBER) RETURN VARCHAR2;

    FUNCTION restore_version(
       p_chr_id                                    IN NUMBER,
       p_major_version                             IN NUMBER) RETURN VARCHAR2;


END OKC_PHL_PVT;

 

/