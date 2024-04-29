--------------------------------------------------------
--  DDL for Package OKC_IGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_IGS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSIGSS.pls 120.0 2005/05/25 23:08:45 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  G_UPPERCASE_REQUIRED         CONSTANT   VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'SQLcode';
  G_RETURN_STATUS                         VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_EXCEPTION_HALT_VALIDATION  EXCEPTION;
  TYPE tve_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    spn_id                         NUMBER := OKC_API.G_MISS_NUM,
    tve_id_offset                  NUMBER := OKC_API.G_MISS_NUM,
    uom_code            OKC_TIMEVALUES.uom_code%TYPE := OKC_API.G_MISS_CHAR,
    cnh_id                         NUMBER := OKC_API.G_MISS_NUM,
    tve_id_generated_by            NUMBER := OKC_API.G_MISS_NUM,
    tve_id_started                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_ended                   NUMBER := OKC_API.G_MISS_NUM,
    tve_id_limited                 NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    tze_id                 NUMBER := OKC_API.G_MISS_NUM,
    tve_type                       OKC_TIMEVALUES.TVE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIMEVALUES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIMEVALUES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    duration                       NUMBER := OKC_API.G_MISS_NUM,
    operator                       OKC_TIMEVALUES.OPERATOR%TYPE := OKC_API.G_MISS_CHAR,
    before_after                   OKC_TIMEVALUES.BEFORE_AFTER%TYPE := OKC_API.G_MISS_CHAR,
    datetime                       OKC_TIMEVALUES.DATETIME%TYPE := OKC_API.G_MISS_DATE,
    month                          NUMBER := OKC_API.G_MISS_NUM,
    day                            NUMBER := OKC_API.G_MISS_NUM,
    hour                           NUMBER := OKC_API.G_MISS_NUM,
    minute                         NUMBER := OKC_API.G_MISS_NUM,
    second                         NUMBER := OKC_API.G_MISS_NUM,
    nth                         NUMBER := OKC_API.G_MISS_NUM,
    day_of_week                    OKC_TIMEVALUES.DAY_OF_WEEK%TYPE := OKC_API.G_MISS_CHAR,
    interval_yn                    OKC_TIMEVALUES.INTERVAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_TIMEVALUES.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
--Bug 3122962
    description                    OKC_TIMEVALUES.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIMEVALUES.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIMEVALUES.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_TIMEVALUES.NAME%TYPE := OKC_API.G_MISS_CHAR,

    attribute1                     OKC_TIMEVALUES.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIMEVALUES.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIMEVALUES.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIMEVALUES.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIMEVALUES.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIMEVALUES.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIMEVALUES.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIMEVALUES.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIMEVALUES.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIMEVALUES.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIMEVALUES.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIMEVALUES.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIMEVALUES.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIMEVALUES.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIMEVALUES.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_tve_rec                          tve_rec_type;
  TYPE tve_tbl_type IS TABLE OF tve_rec_type
        INDEX BY BINARY_INTEGER;
--Bug 3122962
/*
  TYPE okc_timevalues_tl_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKC_TIMEVALUES_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKC_TIMEVALUES_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKC_TIMEVALUES_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKC_TIMEVALUES_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIMEVALUES_TL.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIMEVALUES_TL.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKC_TIMEVALUES_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIMEVALUES_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIMEVALUES_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_okc_timevalues_tl_rec            okc_timevalues_tl_rec_type;
  TYPE okc_timevalues_tl_tbl_type IS TABLE OF okc_timevalues_tl_rec_type
        INDEX BY BINARY_INTEGER;
*/
  TYPE igsv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
--Bug 3122962
    sfwt_flag                      OKC_TIME_IG_STARTEND_V.SFWT_FLAG%TYPE := 'N',
    tve_id_started                 NUMBER := OKC_API.G_MISS_NUM,
    tve_id_ended                   NUMBER := OKC_API.G_MISS_NUM,
    tve_id_limited                 NUMBER := OKC_API.G_MISS_NUM,
    dnz_chr_id                 NUMBER := OKC_API.G_MISS_NUM,
    tze_id                 NUMBER := OKC_API.G_MISS_NUM,
    description                    OKC_TIME_IG_STARTEND_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    short_description              OKC_TIME_IG_STARTEND_V.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    comments                       OKC_TIME_IG_STARTEND_V.COMMENTS%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_TIME_IG_STARTEND_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_TIME_IG_STARTEND_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_TIME_IG_STARTEND_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_TIME_IG_STARTEND_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_TIME_IG_STARTEND_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_igsv_rec                         igsv_rec_type;
  TYPE igsv_tbl_type IS TABLE OF igsv_rec_type
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
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_IGS_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
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
    p_igsv_rec                     IN igsv_rec_type,
    x_igsv_rec                     OUT NOCOPY igsv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_tbl                     IN igsv_tbl_type,
    x_igsv_tbl                     OUT NOCOPY igsv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_rec                     IN igsv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_tbl                     IN igsv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_rec                     IN igsv_rec_type,
    x_igsv_rec                     OUT NOCOPY igsv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_tbl                     IN igsv_tbl_type,
    x_igsv_tbl                     OUT NOCOPY igsv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_rec                     IN igsv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_tbl                     IN igsv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_rec                     IN igsv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_igsv_tbl                     IN igsv_tbl_type);

END OKC_IGS_PVT;

 

/
