--------------------------------------------------------
--  DDL for Package OKC_CRJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CRJ_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCSCRJS.pls 120.0 2005/05/26 09:55:15 appldev noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE crj_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    rty_code                       OKC_K_REL_OBJS.RTY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object1_id1                    OKC_K_REL_OBJS.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_K_REL_OBJS.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_id                NUMBER := OKC_API.G_MISS_NUM,
    jtot_object1_code              OKC_K_REL_OBJS.jtot_object1_code%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_REL_OBJS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_REL_OBJS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    attribute_category             OKC_K_REL_OBJS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_REL_OBJS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_REL_OBJS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_REL_OBJS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_REL_OBJS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_REL_OBJS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_REL_OBJS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_REL_OBJS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_REL_OBJS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_REL_OBJS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_REL_OBJS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_REL_OBJS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_REL_OBJS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_REL_OBJS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_REL_OBJS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_REL_OBJS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR);
  g_miss_crj_rec                          crj_rec_type;
  TYPE crj_tbl_type IS TABLE OF crj_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE crjv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    cle_id                         NUMBER := OKC_API.G_MISS_NUM,
    chr_id                         NUMBER := OKC_API.G_MISS_NUM,
    rty_code                       OKC_K_REL_OBJS.RTY_CODE%TYPE := OKC_API.G_MISS_CHAR,
    object1_id1                    OKC_K_REL_OBJS.OBJECT1_ID1%TYPE := OKC_API.G_MISS_CHAR,
    object1_id2                    OKC_K_REL_OBJS.OBJECT1_ID2%TYPE := OKC_API.G_MISS_CHAR,
    jtot_object1_id                NUMBER := OKC_API.G_MISS_NUM,
    jtot_object1_code              OKC_K_REL_OBJS.jtot_object1_code%TYPE := OKC_API.G_MISS_CHAR,
    attribute_category             OKC_K_REL_OBJS.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1                     OKC_K_REL_OBJS.ATTRIBUTE1%TYPE := OKC_API.G_MISS_CHAR,
    attribute2                     OKC_K_REL_OBJS.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3                     OKC_K_REL_OBJS.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4                     OKC_K_REL_OBJS.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5                     OKC_K_REL_OBJS.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6                     OKC_K_REL_OBJS.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7                     OKC_K_REL_OBJS.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8                     OKC_K_REL_OBJS.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9                     OKC_K_REL_OBJS.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10                    OKC_K_REL_OBJS.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11                    OKC_K_REL_OBJS.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12                    OKC_K_REL_OBJS.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13                    OKC_K_REL_OBJS.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14                    OKC_K_REL_OBJS.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15                    OKC_K_REL_OBJS.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKC_K_REL_OBJS.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKC_K_REL_OBJS.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM);
  g_miss_crjv_rec                         crjv_rec_type;
  TYPE crjv_tbl_type IS TABLE OF crjv_rec_type
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
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_CRJ_PVT';
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
    p_crjv_rec                     IN crjv_rec_type,
    x_crjv_rec                     OUT NOCOPY crjv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type,
    x_crjv_tbl                     OUT NOCOPY crjv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type,
    x_crjv_rec                     OUT NOCOPY crjv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type,
    x_crjv_tbl                     OUT NOCOPY crjv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_rec                     IN crjv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_crjv_tbl                     IN crjv_tbl_type);

  PROCEDURE quote_is_renewal
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	boolean
	);

  PROCEDURE order_is_renewal
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	boolean
	);

  PROCEDURE quote_is_subject
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	boolean
	);

  PROCEDURE order_is_subject
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	boolean
	);

  PROCEDURE quote_contract_is_ordered
	(
	p_api_version		IN		NUMBER
	,p_init_msg_list	IN		VARCHAR2	DEFAULT OKC_API.G_FALSE
	,x_return_status	OUT	NOCOPY	VARCHAR2
	,x_msg_count		OUT	NOCOPY	NUMBER
	,x_msg_data		OUT	NOCOPY	VARCHAR2
	,p_crjv_rec		IN		crjv_rec_type
	,x_true_false		out	nocopy	boolean
	);

  PROCEDURE GET_OBJ_FROM_JTFV
	(
	p_object_code		IN		VARCHAR2
	,p_id1			IN		NUMBER
	,p_id2			IN		VARCHAR2
	,x_true_false		out	nocopy	boolean
	);

  PROCEDURE valid_rec_unique
			(
			p_crjv_rec		IN		crjv_rec_type
			,p_api			IN		varchar2
			,x_return_status	OUT	NOCOPY	VARCHAR2
			);

  PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_crjv_tbl crjv_tbl_type);
END OKC_CRJ_PVT;

 

/
