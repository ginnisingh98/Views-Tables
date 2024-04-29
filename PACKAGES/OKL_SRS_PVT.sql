--------------------------------------------------------
--  DDL for Package OKL_SRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SRS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSRSS.pls 115.3 2003/05/12 23:39:33 bakuchib noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE srs_rec_type IS RECORD (
    id                             NUMBER  ,
    stream_type_name               OKL_SIF_RET_STRMS.STREAM_TYPE_NAME%TYPE ,
    index_number                   NUMBER  ,
    activity_type                  OKL_SIF_RET_STRMS.ACTIVITY_TYPE%TYPE ,
    sequence_number                NUMBER  ,
    sre_date                       OKL_SIF_RET_STRMS.SRE_DATE%TYPE ,
    amount                         NUMBER  ,
    sir_id                         NUMBER  ,
    stream_interface_attribute01   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE01%TYPE ,
    stream_interface_attribute02   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE02%TYPE ,
    stream_interface_attribute03   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE03%TYPE ,
    stream_interface_attribute04   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE04%TYPE ,
    stream_interface_attribute05   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE05%TYPE ,
    stream_interface_attribute06   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE06%TYPE ,
    stream_interface_attribute07   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE07%TYPE ,
    stream_interface_attribute08   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE08%TYPE ,
    stream_interface_attribute09   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE09%TYPE ,
    stream_interface_attribute10   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE10%TYPE ,
    stream_interface_attribute11   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE11%TYPE ,
    stream_interface_attribute12   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE12%TYPE ,
    stream_interface_attribute13   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE13%TYPE ,
    stream_interface_attribute14   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE14%TYPE ,
    stream_interface_attribute15   OKL_SIF_RET_STRMS.STREAM_INTERFACE_ATTRIBUTE15%TYPE ,
    object_version_number          NUMBER  ,
    created_by                     NUMBER  ,
    last_updated_by                NUMBER  ,
    creation_date                  OKL_SIF_RET_STRMS.CREATION_DATE%TYPE ,
    last_update_date               OKL_SIF_RET_STRMS.LAST_UPDATE_DATE%TYPE ,
    last_update_login              NUMBER  );
  g_miss_srs_rec                          srs_rec_type;
  TYPE srs_tbl_type IS TABLE OF srs_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE srsv_rec_type IS RECORD (
    id                             NUMBER  ,
    stream_type_name               OKL_SIF_RET_STRMS_V.STREAM_TYPE_NAME%TYPE ,
    index_number                   NUMBER  ,
    activity_type                  OKL_SIF_RET_STRMS_V.ACTIVITY_TYPE%TYPE ,
    sequence_number                 NUMBER  ,
    sre_date                       OKL_SIF_RET_STRMS_V.SRE_DATE%TYPE ,
    amount                         NUMBER  ,
    sir_id                         NUMBER  ,
    stream_interface_attribute01   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE01%TYPE ,
    stream_interface_attribute02   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE02%TYPE ,
    stream_interface_attribute03   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE03%TYPE ,
    stream_interface_attribute04   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE04%TYPE ,
    stream_interface_attribute05   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE05%TYPE ,
    stream_interface_attribute06   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE06%TYPE ,
    stream_interface_attribute07   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE07%TYPE ,
    stream_interface_attribute08   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE08%TYPE ,
    stream_interface_attribute09   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE09%TYPE ,
    stream_interface_attribute10   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE10%TYPE ,
    stream_interface_attribute11   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE11%TYPE ,
    stream_interface_attribute12   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE12%TYPE ,
    stream_interface_attribute13   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE13%TYPE ,
    stream_interface_attribute14   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE14%TYPE ,
    stream_interface_attribute15   OKL_SIF_RET_STRMS_V.STREAM_INTERFACE_ATTRIBUTE15%TYPE ,
    object_version_number          NUMBER  ,
    created_by                     NUMBER  ,
    last_updated_by                NUMBER  ,







    creation_date                  OKL_SIF_RET_STRMS_V.CREATION_DATE%TYPE ,
    last_update_date               OKL_SIF_RET_STRMS_V.LAST_UPDATE_DATE%TYPE ,
    last_update_login              NUMBER  );
  g_miss_srsv_rec                         srsv_rec_type;
  TYPE srsv_tbl_type IS TABLE OF srsv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_OKC_APP			CONSTANT VARCHAR2(200) := OKC_API.G_APP_NAME;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;


  -- START CHANGE : akjain -- 09/05/2001
  -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM','Unexpected Error'
  G_OKL_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) :='OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_OKL_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_OKL_UNQS                        CONSTANT VARCHAR2(200) := 'OKL_SRS_NOT_UNIQUE';
  -- Added Exception for Halt_validation
  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  -- END change : akjain




  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SRS_PVT ';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
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
    p_srsv_rec                     IN srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type,
    x_srsv_tbl                     OUT NOCOPY srsv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type,
    x_srsv_tbl                     OUT NOCOPY srsv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type);

--BAKUCHIB Bug#2807737 start
 PROCEDURE insert_row_upg(p_srsv_tbl srsv_tbl_type);

 PROCEDURE insert_row_per(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type);
--BAKUCHIB Bug#2807737 End

END OKL_SRS_PVT ;

 

/
