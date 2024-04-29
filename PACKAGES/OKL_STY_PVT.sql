--------------------------------------------------------
--  DDL for Package OKL_STY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSTYS.pls 120.4 2008/01/29 17:08:54 gkadarka noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sty_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    version                        OKL_STRM_TYPE_B.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    code	                       OKL_STRM_TYPE_B.CODE%TYPE := OKC_API.G_MISS_CHAR,
--  customization_level            OKL_STRM_TYPE_B.CUSTOMIZATION_LEVEL%TYPE := OKC_API.G_MISS_CHAR,
    customization_level            OKL_STRM_TYPE_B.CUSTOMIZATION_LEVEL%TYPE := 'S', -- Modified by RGOOTY for ER 3935682
--  stream_type_scope              OKL_STRM_TYPE_B.STREAM_TYPE_SCOPE%TYPE := OKC_API.G_MISS_CHAR,
    stream_type_scope              OKL_STRM_TYPE_B.STREAM_TYPE_SCOPE%TYPE := 'BOTH',
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    accrual_yn                     OKL_STRM_TYPE_B.ACCRUAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    taxable_default_yn             OKL_STRM_TYPE_B.TAXABLE_DEFAULT_YN%TYPE := OKC_API.G_MISS_CHAR,
--  stream_type_class              OKL_STRM_TYPE_B.STREAM_TYPE_CLASS%TYPE := OKC_API.G_MISS_CHAR,
    stream_type_class              OKL_STRM_TYPE_B.STREAM_TYPE_CLASS%TYPE := 'GENERAL', -- Modified by RGOOTY for ER 3935682
    stream_type_subclass              OKL_STRM_TYPE_B.STREAM_TYPE_SUBCLASS%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_STRM_TYPE_B.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKL_STRM_TYPE_B.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    billable_yn			           OKL_STRM_TYPE_B.BILLABLE_YN%TYPE := OKC_API.G_MISS_CHAR,
    capitalize_yn			       OKL_STRM_TYPE_B.CAPITALIZE_YN%TYPE := OKC_API.G_MISS_CHAR,
--    periodic_yn			           OKL_STRM_TYPE_B.PERIODIC_YN%TYPE := OKC_API.G_MISS_CHAR,
    periodic_yn			           OKL_STRM_TYPE_B.PERIODIC_YN%TYPE := NULL,  -- Modified by RGOOTY for ER 3935682
--  fundable_yn			           OKL_STRM_TYPE_B.FUNDABLE_YN%TYPE := OKC_API.G_MISS_CHAR,
    fundable_yn			           OKL_STRM_TYPE_B.FUNDABLE_YN%TYPE := NULL,  -- Modified by RGOOTY for ER 3935682
    -- mvasudev , 05/13/2002
--  allocation_factor			    OKL_STRM_TYPE_B.ALLOCATION_FACTOR%TYPE := OKC_API.G_MISS_CHAR,
    allocation_factor			    OKL_STRM_TYPE_B.ALLOCATION_FACTOR%TYPE := NULL, -- Modified by RGOOTY for ER 3935682
    --
    attribute_category			   OKL_STRM_TYPE_B.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1					   OKL_STRM_TYPE_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute2					   OKL_STRM_TYPE_B.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3					   OKL_STRM_TYPE_B.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4					   OKL_STRM_TYPE_B.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5					   OKL_STRM_TYPE_B.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6					   OKL_STRM_TYPE_B.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7					   OKL_STRM_TYPE_B.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8					   OKL_STRM_TYPE_B.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9					   OKL_STRM_TYPE_B.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10					   OKL_STRM_TYPE_B.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11					   OKL_STRM_TYPE_B.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12					   OKL_STRM_TYPE_B.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13					   OKL_STRM_TYPE_B.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14					   OKL_STRM_TYPE_B.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15					   OKL_STRM_TYPE_B.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_STRM_TYPE_B.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_STRM_TYPE_B.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
-- Added by RGOOTY for ER 3935682: Start
    stream_type_purpose            OKL_STRM_TYPE_B.STREAM_TYPE_PURPOSE%TYPE := OKC_API.G_MISS_CHAR,
    contingency                    OKL_STRM_TYPE_B.CONTINGENCY%TYPE := OKC_API.G_MISS_CHAR,
    -- Added by RGOOTY for ER 3935682: End

    -- Added by SNANDIKO for Bug 6744584 Start
    contingency_id                    OKL_STRM_TYPE_B.CONTINGENCY_ID%TYPE := OKC_API.G_MISS_NUM );
    -- Added by SNANDIKO for Bug 6744584 End
  g_miss_sty_rec                          sty_rec_type;
  TYPE sty_tbl_type IS TABLE OF sty_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE okl_strm_type_tl_rec_type IS RECORD (

    id                             NUMBER := OKC_API.G_MISS_NUM,
    language                       OKL_STRM_TYPE_TL.LANGUAGE%TYPE := OKC_API.G_MISS_CHAR,
    source_lang                    OKL_STRM_TYPE_TL.SOURCE_LANG%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_STRM_TYPE_TL.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    name                           OKL_STRM_TYPE_TL.NAME%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_STRM_TYPE_TL.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_STRM_TYPE_TL.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_STRM_TYPE_TL.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
--  Added by RGOOTY for ER 3935682: Start
    short_description		   OKL_STRM_TYPE_TL.SHORT_DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
--  Added by RGOOTY for ER 3935682: End
    );
  g_miss_okl_strm_type_tl_rec             okl_strm_type_tl_rec_type;
  TYPE okl_strm_type_tl_tbl_type IS TABLE OF okl_strm_type_tl_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE styv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    name                           OKL_STRM_TYPE_V.NAME%TYPE := OKC_API.G_MISS_CHAR,
    version                        OKL_STRM_TYPE_V.VERSION%TYPE := OKC_API.G_MISS_CHAR,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    code	                       OKL_STRM_TYPE_V.CODE%TYPE := OKC_API.G_MISS_CHAR,
    sfwt_flag                      OKL_STRM_TYPE_V.SFWT_FLAG%TYPE := OKC_API.G_MISS_CHAR,
--    stream_type_scope              OKL_STRM_TYPE_V.STREAM_TYPE_SCOPE%TYPE := OKC_API.G_MISS_CHAR,
    stream_type_scope              OKL_STRM_TYPE_V.STREAM_TYPE_SCOPE%TYPE := 'BOTH', -- Modified by RGOOTY for ER 3935682
    description                    OKL_STRM_TYPE_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    start_date                     OKL_STRM_TYPE_V.START_DATE%TYPE := OKC_API.G_MISS_DATE,
    end_date                       OKL_STRM_TYPE_V.END_DATE%TYPE := OKC_API.G_MISS_DATE,
    billable_yn			           OKL_STRM_TYPE_V.BILLABLE_YN%TYPE := OKC_API.G_MISS_CHAR,
    taxable_default_yn             OKL_STRM_TYPE_V.TAXABLE_DEFAULT_YN%TYPE := OKC_API.G_MISS_CHAR,
--    customization_level            OKL_STRM_TYPE_V.CUSTOMIZATION_LEVEL%TYPE := OKC_API.G_MISS_CHAR,
    customization_level            OKL_STRM_TYPE_V.CUSTOMIZATION_LEVEL%TYPE := 'S', -- Modified by RGOOTY for ER 3935682
--    stream_type_class              OKL_STRM_TYPE_V.STREAM_TYPE_CLASS%TYPE := OKC_API.G_MISS_CHAR,
    stream_type_class              OKL_STRM_TYPE_V.STREAM_TYPE_CLASS%TYPE := 'GENERAL', -- Modified by RGOOTY for ER 3935682
    stream_type_subclass           OKL_STRM_TYPE_V.STREAM_TYPE_SUBCLASS%TYPE := OKC_API.G_MISS_CHAR,
    accrual_yn                     OKL_STRM_TYPE_V.ACCRUAL_YN%TYPE := OKC_API.G_MISS_CHAR,
    capitalize_yn			       OKL_STRM_TYPE_V.CAPITALIZE_YN%TYPE := OKC_API.G_MISS_CHAR,
--    periodic_yn			           OKL_STRM_TYPE_V.PERIODIC_YN%TYPE := OKC_API.G_MISS_CHAR,
    periodic_yn			           OKL_STRM_TYPE_V.PERIODIC_YN%TYPE := NULL, -- Modified by RGOOTY for ER 3935682
--    fundable_yn			           OKL_STRM_TYPE_V.FUNDABLE_YN%TYPE := OKC_API.G_MISS_CHAR,
    fundable_yn			           OKL_STRM_TYPE_V.FUNDABLE_YN%TYPE := NULL,	 -- Modified by RGOOTY for ER 3935682
    -- mvasudev , 05/13/2002
--    allocation_factor			    OKL_STRM_TYPE_V.ALLOCATION_FACTOR%TYPE := OKC_API.G_MISS_CHAR,
    allocation_factor			    OKL_STRM_TYPE_V.ALLOCATION_FACTOR%TYPE := NULL, -- Modified by RGOOTY for ER 3935682
    --
    attribute_category			   OKL_STRM_TYPE_V.ATTRIBUTE_CATEGORY%TYPE := OKC_API.G_MISS_CHAR,
    attribute1					   OKL_STRM_TYPE_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute2					   OKL_STRM_TYPE_V.ATTRIBUTE2%TYPE := OKC_API.G_MISS_CHAR,
    attribute3					   OKL_STRM_TYPE_V.ATTRIBUTE3%TYPE := OKC_API.G_MISS_CHAR,
    attribute4					   OKL_STRM_TYPE_V.ATTRIBUTE4%TYPE := OKC_API.G_MISS_CHAR,
    attribute5					   OKL_STRM_TYPE_V.ATTRIBUTE5%TYPE := OKC_API.G_MISS_CHAR,
    attribute6					   OKL_STRM_TYPE_V.ATTRIBUTE6%TYPE := OKC_API.G_MISS_CHAR,
    attribute7					   OKL_STRM_TYPE_V.ATTRIBUTE7%TYPE := OKC_API.G_MISS_CHAR,
    attribute8					   OKL_STRM_TYPE_V.ATTRIBUTE8%TYPE := OKC_API.G_MISS_CHAR,
    attribute9					   OKL_STRM_TYPE_V.ATTRIBUTE9%TYPE := OKC_API.G_MISS_CHAR,
    attribute10					   OKL_STRM_TYPE_V.ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    attribute11					   OKL_STRM_TYPE_V.ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    attribute12					   OKL_STRM_TYPE_V.ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    attribute13					   OKL_STRM_TYPE_V.ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    attribute14					   OKL_STRM_TYPE_V.ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    attribute15					   OKL_STRM_TYPE_V.ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_STRM_TYPE_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    last_update_date               OKL_STRM_TYPE_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
-- Added by RGOOTY for ER 3935682: Start
    stream_type_purpose		   OKL_STRM_TYPE_V.stream_type_purpose%TYPE := OKC_API.G_MISS_CHAR,
    contingency			   OKL_STRM_TYPE_V.contingency%TYPE   := OKC_API.G_MISS_CHAR,
    short_description		   OKL_STRM_TYPE_V.short_description%TYPE := OKC_API.G_MISS_CHAR,
-- Added by RGOOTY for ER 3935682: End

-- Added by SNANDIKO for Bug 6744584 Start
   contingency_id			   OKL_STRM_TYPE_V.contingency_id%TYPE   := OKC_API.G_MISS_NUM
    );
    -- Added by SNANDIKO for Bug 6744584 End
  g_miss_styv_rec                         styv_rec_type;
  TYPE styv_tbl_type IS TABLE OF styv_rec_type
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
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_OKL_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) :='OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
  G_OKL_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
  G_OKL_UNQS                        CONSTANT VARCHAR2(200) := 'OKL_STY_NOT_UNIQUE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_STY_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

 ---------------------------------------------------------------------------
    -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE add_language;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type,
    x_styv_rec                     OUT NOCOPY styv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type,
    x_styv_tbl                     OUT NOCOPY styv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type,
    x_styv_rec                     OUT NOCOPY styv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type,
    x_styv_tbl                     OUT NOCOPY styv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_rec                     IN styv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_styv_tbl                     IN styv_tbl_type);

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode 		   IN VARCHAR2,
    p_id                           IN VARCHAR2,
    p_version                      IN VARCHAR2,
    p_code                         IN VARCHAR2,
    p_customization_level          IN VARCHAR2,
    p_stream_type_scope            IN VARCHAR2,
    p_object_version_number        IN VARCHAR2,
    p_accrual_yn                   IN VARCHAR2,
    p_taxable_default_yn           IN VARCHAR2,
    p_stream_type_class            IN VARCHAR2,
    p_stream_type_subclass         IN VARCHAR2,
    p_start_date                   IN VARCHAR2,
    p_end_date                     IN VARCHAR2,
    p_billable_yn                  IN VARCHAR2,
    p_capitalize_yn                IN VARCHAR2,
    p_periodic_yn                  IN VARCHAR2,
    p_fundable_yn                  IN VARCHAR2,
    p_allocation_factor            IN VARCHAR2,
    p_attribute_category           IN VARCHAR2,
    p_attribute1                   IN VARCHAR2,
    p_attribute2                   IN VARCHAR2,
    p_attribute3                   IN VARCHAR2,
    p_attribute4                   IN VARCHAR2,
    p_attribute5                   IN VARCHAR2,
    p_attribute6                   IN VARCHAR2,
    p_attribute7                   IN VARCHAR2,
    p_attribute8                   IN VARCHAR2,
    p_attribute9                   IN VARCHAR2,
    p_attribute10                  IN VARCHAR2,
    p_attribute11                  IN VARCHAR2,
    p_attribute12                  IN VARCHAR2,
    p_attribute13                  IN VARCHAR2,
    p_attribute14                  IN VARCHAR2,
    p_attribute15                  IN VARCHAR2,
    p_stream_type_purpose          IN VARCHAR2,
    p_contingency                  IN VARCHAR2,
    p_name                         IN VARCHAR2,
    p_description                  IN VARCHAR2,
    p_owner                        IN VARCHAR2,
    p_last_update_date             IN VARCHAR2,
    -- Added by SNANDIKO for Bug 6744584 Start
    p_contingency_id               IN VARCHAR2
    -- Added by SNANDIKO for Bug 6744584 End
    );

END OKL_STY_PVT;

/
