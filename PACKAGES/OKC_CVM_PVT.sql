--------------------------------------------------------
--  DDL for Package OKC_CVM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CVM_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCVMS.pls 120.1 2006/05/24 23:05:31 tweichen noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
    -- Global transaction id
    g_trans_id   VARCHAR2(100) := 'XXX';

  TYPE okc_k_vers_numbers_h_rec_type IS RECORD (
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    major_version                  NUMBER := OKC_API.G_MISS_NUM,
    minor_version                  NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_VERS_NUMBERS_H.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_VERS_NUMBERS_H.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  GMissOkcKVersNumbersHRec                okc_k_vers_numbers_h_rec_type;
  TYPE okc_k_vers_numbers_h_tbl_type IS TABLE OF okc_k_vers_numbers_h_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE cvm_rec_type IS RECORD (
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    major_version                  NUMBER := OKC_API.G_MISS_NUM,
    minor_version                  NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_VERS_NUMBERS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_VERS_NUMBERS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_cvm_rec                          cvm_rec_type;
  TYPE cvm_tbl_type IS TABLE OF cvm_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE cvmv_rec_type IS RECORD (
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    major_version                  NUMBER := OKC_API.G_MISS_NUM,
    minor_version                  NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_VERS_NUMBERS_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_VERS_NUMBERS_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_cvmv_rec                         cvmv_rec_type;
  TYPE cvmv_tbl_type IS TABLE OF cvmv_rec_type
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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CVM_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_tbl                     IN cvmv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type);

  PROCEDURE create_contract_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type);


  PROCEDURE update_contract_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type);

  PROCEDURE version_contract_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type);

  PROCEDURE delete_contract_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type);

  PROCEDURE clear_g_transaction_id; --added for bug 3658108


  /*
    Bug 5218723, added this procedure to defer minor version update
    in procedure update_contract_version.

    If this procedure is called with param p_defer = 'T',
    then subsequent calls to update_contract_version() will do nothing.

    Calling modules should then call with  param p_defer = 'F', before
    calling update_contract_version() to update contract minor version

    This is to resolve record locking issues in Bug 5218723. The default
    value of param p_defer is equal to  'F', so that existing modules
    are not impacted.

    Param
        p_defer   : sets the update mode, valid values are 'T' and 'F'
  */
  PROCEDURE defer_minor_version_update(p_defer IN VARCHAR2 DEFAULT FND_API.G_FALSE);

  /*  Utility function for updating minor version of a contract */

  FUNCTION Update_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2;

END OKC_CVM_PVT;

 

/
