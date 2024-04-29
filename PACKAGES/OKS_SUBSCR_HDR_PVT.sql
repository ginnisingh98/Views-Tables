--------------------------------------------------------
--  DDL for Package OKS_SUBSCR_HDR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SUBSCR_HDR_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBHRS.pls 120.3 2006/09/11 22:37:16 jakuruvi noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
/**mchoudha**/
/*

OKS_SUBSCR_HEADER_V: columns not added in the excel sheet
*/
/**mchoudha**/


  -- OKS_SUBSCR_HEADER_V Record Spec
  TYPE schv_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,name                           OKS_SUBSCR_HEADER_V.NAME%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKS_SUBSCR_HEADER_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,instance_id                    NUMBER := OKC_API.G_MISS_NUM
    ,sfwt_flag                      OKS_SUBSCR_HEADER_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,subscription_type              OKS_SUBSCR_HEADER_V.SUBSCRIPTION_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,item_type                      OKS_SUBSCR_HEADER_V.ITEM_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,media_type                     OKS_SUBSCR_HEADER_V.MEDIA_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,status                         OKS_SUBSCR_HEADER_V.STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,frequency                      OKS_SUBSCR_HEADER_V.FREQUENCY%TYPE := OKC_API.G_MISS_CHAR
    ,fulfillment_channel            OKS_SUBSCR_HEADER_V.FULFILLMENT_CHANNEL%TYPE := OKC_API.G_MISS_CHAR
    ,offset                         NUMBER := OKC_API.G_MISS_NUM
    ,comments                       OKS_SUBSCR_HEADER_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR
    ,upg_orig_system_ref            OKS_SUBSCR_HEADER_V.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR
    ,upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_SUBSCR_HEADER_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_SUBSCR_HEADER_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
);
  G_MISS_schv_rec                         schv_rec_type;
  TYPE schv_tbl_type IS TABLE OF schv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_SUBSCR_HEADER_B Record Spec
  TYPE sbh_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,cle_id                         NUMBER := OKC_API.G_MISS_NUM
    ,dnz_chr_id                     NUMBER := OKC_API.G_MISS_NUM
    ,instance_id                    NUMBER := OKC_API.G_MISS_NUM
    ,subscription_type              OKS_SUBSCR_HEADER_B.SUBSCRIPTION_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,item_type                      OKS_SUBSCR_HEADER_B.ITEM_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,media_type                     OKS_SUBSCR_HEADER_B.MEDIA_TYPE%TYPE := OKC_API.G_MISS_CHAR
    ,status                         OKS_SUBSCR_HEADER_B.STATUS%TYPE := OKC_API.G_MISS_CHAR
    ,frequency                      OKS_SUBSCR_HEADER_B.FREQUENCY%TYPE := OKC_API.G_MISS_CHAR
    ,fulfillment_channel            OKS_SUBSCR_HEADER_B.FULFILLMENT_CHANNEL%TYPE := OKC_API.G_MISS_CHAR
    ,offset                         NUMBER := OKC_API.G_MISS_NUM
    ,upg_orig_system_ref            OKS_SUBSCR_HEADER_B.UPG_ORIG_SYSTEM_REF%TYPE := OKC_API.G_MISS_CHAR
    ,upg_orig_system_ref_id         NUMBER := OKC_API.G_MISS_NUM
    ,object_version_number          NUMBER := OKC_API.G_MISS_NUM
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_SUBSCR_HEADER_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_SUBSCR_HEADER_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM
-- R12 Data Model Changes 4485150 Start
    ,orig_system_id1                NUMBER := OKC_API.G_MISS_NUM
    ,orig_system_reference1         OKS_SUBSCR_HEADER_B.ORIG_SYSTEM_REFERENCE1%TYPE  := OKC_API.G_MISS_CHAR
    ,orig_system_source_code        OKS_SUBSCR_HEADER_B.ORIG_SYSTEM_SOURCE_CODE%TYPE := OKC_API.G_MISS_CHAR
-- R12 Data Model Changes 4485150 End
);
  G_MISS_sbh_rec                          sbh_rec_type;
  TYPE sbh_tbl_type IS TABLE OF sbh_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKS_SUBSCR_HEADER_TL Record Spec
  TYPE oks_subscr_header_tl_rec_type IS RECORD (
     id                             NUMBER := OKC_API.G_MISS_NUM
    ,name                           OKS_SUBSCR_HEADER_TL.NAME%TYPE := OKC_API.G_MISS_CHAR
    ,description                    OKS_SUBSCR_HEADER_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
    ,language                       OKS_SUBSCR_HEADER_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR
    ,source_lang                    OKS_SUBSCR_HEADER_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR
    ,sfwt_flag                      OKS_SUBSCR_HEADER_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR
    ,comments                       OKS_SUBSCR_HEADER_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKC_API.G_MISS_NUM
    ,creation_date                  OKS_SUBSCR_HEADER_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKC_API.G_MISS_NUM
    ,last_update_date               OKS_SUBSCR_HEADER_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOksSubscrHeaderTlRec               oks_subscr_header_tl_rec_type;
  TYPE oks_subscr_header_tl_tbl_type IS TABLE OF oks_subscr_header_tl_rec_type
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
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKS_SUBSCR_HDR_PVT';
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
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type,
    x_schv_rec                     OUT NOCOPY schv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    x_schv_tbl                     OUT NOCOPY schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    x_schv_tbl                     OUT NOCOPY schv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type,
    x_schv_rec                     OUT NOCOPY schv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    x_schv_tbl                     OUT NOCOPY schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    x_schv_tbl                     OUT NOCOPY schv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type);
END OKS_SUBSCR_HDR_PVT;

 

/
