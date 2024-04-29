--------------------------------------------------------
--  DDL for Package OKL_QPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QPY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSQPYS.pls 115.4 2002/07/09 20:29:56 rdraguil noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE qpy_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    qte_id                         NUMBER := OKC_API.G_MISS_NUM,
    cpl_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    date_sent                      OKL_QUOTE_PARTIES.DATE_SENT%TYPE := OKC_API.G_MISS_DATE,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_QUOTE_PARTIES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_QUOTE_PARTIES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    qpt_code                       OKL_QUOTE_PARTIES.QPT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    delay_days                     NUMBER := OKC_API.G_MISS_NUM,
    allocation_percentage          NUMBER := OKC_API.G_MISS_NUM,
    email_address                  OKL_QUOTE_PARTIES.EMAIL_ADDRESS%TYPE := OKC_API.G_MISS_CHAR,
    party_jtot_object1_code        OKL_QUOTE_PARTIES.PARTY_JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    party_object1_id1              OKL_QUOTE_PARTIES.PARTY_OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    party_object1_id2              OKL_QUOTE_PARTIES.PARTY_OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    contact_jtot_object1_code      OKL_QUOTE_PARTIES.CONTACT_JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    contact_object1_id1            OKL_QUOTE_PARTIES.CONTACT_OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    contact_object1_id2            OKL_QUOTE_PARTIES.CONTACT_OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_qpy_rec                          qpy_rec_type;
  TYPE qpy_tbl_type IS TABLE OF qpy_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE qpyv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    qte_id                         NUMBER := OKC_API.G_MISS_NUM,
    cpl_id                         NUMBER := OKC_API.G_MISS_NUM,
    date_sent                      OKL_QUOTE_PARTIES_V.DATE_SENT%TYPE := OKC_API.G_MISS_DATE,
    qpt_code                       OKL_QUOTE_PARTIES_V.QPT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    delay_days                     NUMBER := OKC_API.G_MISS_NUM,
    allocation_percentage          NUMBER := OKC_API.G_MISS_NUM,
    email_address                  OKL_QUOTE_PARTIES.EMAIL_ADDRESS%TYPE := OKC_API.G_MISS_CHAR,
    party_jtot_object1_code        OKL_QUOTE_PARTIES.PARTY_JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    party_object1_id1              OKL_QUOTE_PARTIES.PARTY_OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    party_object1_id2              OKL_QUOTE_PARTIES.PARTY_OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    contact_jtot_object1_code      OKL_QUOTE_PARTIES.CONTACT_JTOT_OBJECT1_CODE%TYPE := OKC_API.G_MISS_CHAR,
    contact_object1_id1            OKL_QUOTE_PARTIES.CONTACT_OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    contact_object1_id2            OKL_QUOTE_PARTIES.CONTACT_OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_QUOTE_PARTIES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_QUOTE_PARTIES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_qpyv_rec                         qpyv_rec_type;
  TYPE qpyv_tbl_type IS TABLE OF qpyv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_QPY_PVT';
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
    p_qpyv_rec                     IN qpyv_rec_type,
    x_qpyv_rec                     OUT NOCOPY qpyv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type,
    x_qpyv_tbl                     OUT NOCOPY qpyv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type,
    x_qpyv_rec                     OUT NOCOPY qpyv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type,
    x_qpyv_tbl                     OUT NOCOPY qpyv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type);

END OKL_QPY_PVT;

 

/
