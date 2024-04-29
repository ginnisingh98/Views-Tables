--------------------------------------------------------
--  DDL for Package OKC_RDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_RDS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSRDSS.pls 120.0 2005/05/25 22:47:10 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE rds_rec_type IS RECORD (
    rgr_rgd_code                   OKC_RULE_DEF_SOURCES.RGR_RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
    rgr_rdf_code                   OKC_RULE_DEF_SOURCES.RGR_RDF_CODE%TYPE := OKC_API.G_MISS_CHAR,
    buy_or_sell                    OKC_RULE_DEF_SOURCES.BUY_OR_SELL%TYPE := OKC_API.G_MISS_CHAR,
    access_level                   OKC_RULE_DEF_SOURCES.ACCESS_LEVEL%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKC_RULE_DEF_SOURCES.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_RULE_DEF_SOURCES.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    jtot_object_code               OKC_RULE_DEF_SOURCES.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object_id_number               NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_RULE_DEF_SOURCES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_RULE_DEF_SOURCES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_rds_rec                          rds_rec_type;
  TYPE rds_tbl_type IS TABLE OF rds_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE rdsv_rec_type IS RECORD (
    row_id                         ROWID,
    jtot_object_code               OKC_RULE_DEF_SOURCES_V.JTOT_OBJECT_CODE%TYPE := OKC_API.G_MISS_CHAR,
    rgr_rgd_code                   OKC_RULE_DEF_SOURCES_V.RGR_RGD_CODE%TYPE := OKC_API.G_MISS_CHAR,
    rgr_rdf_code                   OKC_RULE_DEF_SOURCES_V.RGR_RDF_CODE%TYPE := OKC_API.G_MISS_CHAR,
    buy_or_sell                    OKC_RULE_DEF_SOURCES_V.BUY_OR_SELL%TYPE := OKC_API.G_MISS_CHAR,
    access_level                   OKC_RULE_DEF_SOURCES_V.ACCESS_LEVEL%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKC_RULE_DEF_SOURCES_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKC_RULE_DEF_SOURCES_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    object_id_number               NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_RULE_DEF_SOURCES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_RULE_DEF_SOURCES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_rdsv_rec                         rdsv_rec_type;
  TYPE rdsv_tbl_type IS TABLE OF rdsv_rec_type
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
  G_INVALID_VALUE               CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_RDS_PVT';
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
    p_rdsv_rec                     IN rdsv_rec_type,
    x_rdsv_rec                     OUT NOCOPY rdsv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type,
    x_rdsv_tbl                     OUT NOCOPY rdsv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type,
    x_rdsv_rec                     OUT NOCOPY rdsv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type,
    x_rdsv_tbl                     OUT NOCOPY rdsv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec                     IN rdsv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl                     IN rdsv_tbl_type);

END OKC_RDS_PVT;

 

/
