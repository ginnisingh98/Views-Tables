--------------------------------------------------------
--  DDL for Package OKS_QUA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_QUA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSQUAS.pls 120.0 2005/05/27 15:27:07 appldev noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE qua_rec_type IS RECORD (
 QUALIFIER_ID                    NUMBER   := OKC_API.G_MISS_NUM,
 CREATION_DATE                   OKS_QUALIFIERS.creation_date%TYPE := OKC_API.G_MISS_DATE,
 CREATED_BY                      NUMBER    := OKC_API.G_MISS_NUM,
 LAST_UPDATE_DATE                OKS_QUALIFIERS.last_update_date%TYPE := OKC_API.G_MISS_DATE,
 LAST_UPDATED_BY                 NUMBER   := OKC_API.G_MISS_NUM,
 REQUEST_ID                      NUMBER   := OKC_API.G_MISS_NUM,
 PROGRAM_APPLICATION_ID          NUMBER   := OKC_API.G_MISS_NUM,
 PROGRAM_ID                      NUMBER   := OKC_API.G_MISS_NUM,
 PROGRAM_UPDATE_DATE             OKS_QUALIFIERS.program_update_date%TYPE := OKC_API.G_MISS_DATE,
 LAST_UPDATE_LOGIN               NUMBER   := OKC_API.G_MISS_NUM,
 QUALIFIER_GROUPING_NO           NUMBER   := OKC_API.G_MISS_NUM,
 QUALIFIER_CONTEXT               OKS_QUALIFIERS.QUALIFIER_CONTEXT%TYPE  := OKC_API.G_MISS_CHAR,
 QUALIFIER_ATTRIBUTE             OKS_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE  := OKC_API.G_MISS_CHAR,
 QUALIFIER_ATTR_VALUE            OKS_QUALIFIERS.QUALIFIER_ATTR_VALUE%TYPE  := OKC_API.G_MISS_CHAR,
 COMPARISON_OPERATOR_CODE        OKS_QUALIFIERS.comparison_operator_code%TYPE  := OKC_API.G_MISS_CHAR,
 EXCLUDER_FLAG                   OKS_QUALIFIERS.excluder_flag%TYPE  := OKC_API.G_MISS_CHAR,
 QUALIFIER_RULE_ID               NUMBER   := OKC_API.G_MISS_NUM,
 START_DATE_ACTIVE               OKS_QUALIFIERS.start_date_active%TYPE := OKC_API.G_MISS_DATE,
 END_DATE_ACTIVE                 OKS_QUALIFIERS.end_date_active%TYPE := OKC_API.G_MISS_DATE,
  CREATED_FROM_RULE_ID           NUMBER   := OKC_API.G_MISS_NUM,
 QUALIFIER_PRECEDENCE            NUMBER   := OKC_API.G_MISS_NUM,
 LIST_HEADER_ID                  NUMBER   := OKC_API.G_MISS_NUM,
 LIST_LINE_ID                    NUMBER   := OKC_API.G_MISS_NUM,
 QUALIFIER_DATATYPE              OKS_QUALIFIERS.QUALIFIER_DATATYPE%TYPE  := OKC_API.G_MISS_CHAR,
 QUALIFIER_ATTR_VALUE_TO         OKS_QUALIFIERS.QUALIFIER_attr_value_to%TYPE  := OKC_API.G_MISS_CHAR,
 CONTEXT                         OKS_QUALIFIERS.CONTEXT%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE1                      OKS_QUALIFIERS.ATTRIBUTE1%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE2                      OKS_QUALIFIERS.ATTRIBUTE2%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE3                      OKS_QUALIFIERS.ATTRIBUTE3%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE4                      OKS_QUALIFIERS.ATTRIBUTE4%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE5                      OKS_QUALIFIERS.ATTRIBUTE5%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE6                      OKS_QUALIFIERS.ATTRIBUTE6%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE7                      OKS_QUALIFIERS.ATTRIBUTE7%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE8                      OKS_QUALIFIERS.ATTRIBUTE8%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE9                      OKS_QUALIFIERS.ATTRIBUTE9%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE10                     OKS_QUALIFIERS.ATTRIBUTE10%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE11                     OKS_QUALIFIERS.ATTRIBUTE11%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE12                     OKS_QUALIFIERS.ATTRIBUTE12%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE13                     OKS_QUALIFIERS.ATTRIBUTE13%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE14                     OKS_QUALIFIERS.ATTRIBUTE14%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE15                     OKS_QUALIFIERS.ATTRIBUTE15%TYPE  := OKC_API.G_MISS_CHAR,
 ACTIVE_FLAG                     OKS_QUALIFIERS.active_flag%TYPE  := OKC_API.G_MISS_CHAR,
 LIST_TYPE_CODE                  OKS_QUALIFIERS.list_type_code%TYPE  := OKC_API.G_MISS_CHAR,
 QUAL_ATTR_VALUE_FROM_NUMBER     NUMBER   := OKC_API.G_MISS_NUM,
 QUAL_ATTR_VALUE_TO_NUMBER       NUMBER   := OKC_API.G_MISS_NUM
 );

  g_miss_qua_rec                          qua_rec_type;
  TYPE qua_tbl_type IS TABLE OF qua_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE quav_rec_type IS RECORD (
 QUALIFIER_ID                    NUMBER   := OKC_API.G_MISS_NUM,
 CREATION_DATE                   OKS_QUALIFIERS.creation_date%TYPE := OKC_API.G_MISS_DATE,
 CREATED_BY                      NUMBER    := OKC_API.G_MISS_NUM,
 LAST_UPDATE_DATE                OKS_QUALIFIERS.last_update_date%TYPE := OKC_API.G_MISS_DATE,
 LAST_UPDATED_BY                 NUMBER   := OKC_API.G_MISS_NUM,
 REQUEST_ID                      NUMBER   := OKC_API.G_MISS_NUM,
 PROGRAM_APPLICATION_ID          NUMBER   := OKC_API.G_MISS_NUM,
 PROGRAM_ID                      NUMBER   := OKC_API.G_MISS_NUM,
 PROGRAM_UPDATE_DATE             OKS_QUALIFIERS.program_update_date%TYPE := OKC_API.G_MISS_DATE,
 LAST_UPDATE_LOGIN               NUMBER   := OKC_API.G_MISS_NUM,
 QUALIFIER_GROUPING_NO           NUMBER   := OKC_API.G_MISS_NUM,
 QUALIFIER_CONTEXT               OKS_QUALIFIERS.QUALIFIER_CONTEXT%TYPE  := OKC_API.G_MISS_CHAR,
 QUALIFIER_ATTRIBUTE             OKS_QUALIFIERS.QUALIFIER_ATTRIBUTE%TYPE  := OKC_API.G_MISS_CHAR,
 QUALIFIER_ATTR_VALUE            OKS_QUALIFIERS.QUALIFIER_ATTR_VALUE%TYPE  := OKC_API.G_MISS_CHAR,
 COMPARISON_OPERATOR_CODE        OKS_QUALIFIERS.comparison_operator_code%TYPE  := OKC_API.G_MISS_CHAR,
 EXCLUDER_FLAG                   OKS_QUALIFIERS.excluder_flag%TYPE  := OKC_API.G_MISS_CHAR,
 QUALIFIER_RULE_ID               NUMBER   := OKC_API.G_MISS_NUM,
 START_DATE_ACTIVE               OKS_QUALIFIERS.start_date_active%TYPE := OKC_API.G_MISS_DATE,
 END_DATE_ACTIVE                 OKS_QUALIFIERS.end_date_active%TYPE := OKC_API.G_MISS_DATE,
  CREATED_FROM_RULE_ID           NUMBER   := OKC_API.G_MISS_NUM,
 QUALIFIER_PRECEDENCE            NUMBER   := OKC_API.G_MISS_NUM,
 LIST_HEADER_ID                  NUMBER   := OKC_API.G_MISS_NUM,
 LIST_LINE_ID                    NUMBER   := OKC_API.G_MISS_NUM,
 QUALIFIER_DATATYPE              OKS_QUALIFIERS.QUALIFIER_DATATYPE%TYPE  := OKC_API.G_MISS_CHAR,
 QUALIFIER_ATTR_VALUE_TO         OKS_QUALIFIERS.QUALIFIER_attr_value_to%TYPE  := OKC_API.G_MISS_CHAR,
 CONTEXT                         OKS_QUALIFIERS.CONTEXT%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE1                      OKS_QUALIFIERS.ATTRIBUTE1%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE2                      OKS_QUALIFIERS.ATTRIBUTE2%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE3                      OKS_QUALIFIERS.ATTRIBUTE3%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE4                      OKS_QUALIFIERS.ATTRIBUTE4%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE5                      OKS_QUALIFIERS.ATTRIBUTE5%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE6                      OKS_QUALIFIERS.ATTRIBUTE6%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE7                      OKS_QUALIFIERS.ATTRIBUTE7%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE8                      OKS_QUALIFIERS.ATTRIBUTE8%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE9                      OKS_QUALIFIERS.ATTRIBUTE9%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE10                     OKS_QUALIFIERS.ATTRIBUTE10%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE11                     OKS_QUALIFIERS.ATTRIBUTE11%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE12                     OKS_QUALIFIERS.ATTRIBUTE12%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE13                     OKS_QUALIFIERS.ATTRIBUTE13%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE14                     OKS_QUALIFIERS.ATTRIBUTE14%TYPE  := OKC_API.G_MISS_CHAR,
 ATTRIBUTE15                     OKS_QUALIFIERS.ATTRIBUTE15%TYPE  := OKC_API.G_MISS_CHAR,
 ACTIVE_FLAG                     OKS_QUALIFIERS.active_flag%TYPE  := OKC_API.G_MISS_CHAR,
 LIST_TYPE_CODE                  OKS_QUALIFIERS.list_type_code%TYPE  := OKC_API.G_MISS_CHAR,
 QUAL_ATTR_VALUE_FROM_NUMBER     NUMBER   := OKC_API.G_MISS_NUM,
 QUAL_ATTR_VALUE_TO_NUMBER       NUMBER   := OKC_API.G_MISS_NUM
 );
  g_miss_quav_rec                         quav_rec_type;
  TYPE quav_tbl_type IS TABLE OF quav_rec_type
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
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKS_QUALIFIERS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  ---------------------------------------------------------------------------
	   -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
   G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_QUA_PVT';
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
    p_quav_rec                     IN quav_rec_type,
    x_quav_rec                     OUT NOCOPY quav_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type,
    x_quav_tbl                     OUT NOCOPY quav_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type,
    x_quav_rec                     OUT NOCOPY quav_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type,
    x_quav_tbl                     OUT NOCOPY quav_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type);

END OKS_QUA_PVT;

 

/
