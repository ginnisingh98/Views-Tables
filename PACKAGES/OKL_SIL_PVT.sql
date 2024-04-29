--------------------------------------------------------
--  DDL for Package OKL_SIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSILS.pls 120.4.12010000.3 2009/07/21 00:21:11 sechawla ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sil_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    state_depre_dmnshing_value_rt  NUMBER := OKC_API.G_MISS_NUM,
    book_depre_dmnshing_value_rt   NUMBER := OKC_API.G_MISS_NUM,
    residual_guarantee_method      OKL_SIF_LINES.RESIDUAL_GUARANTEE_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    residual_date                  OKL_SIF_LINES.RESIDUAL_DATE%TYPE := OKC_API.G_MISS_DATE,
    fed_depre_term                 NUMBER := OKC_API.G_MISS_NUM,
    fed_depre_dmnshing_value_rate  NUMBER := OKC_API.G_MISS_NUM,
    fed_depre_adr_conve            OKL_SIF_LINES.FED_DEPRE_ADR_CONVE%TYPE := OKC_API.G_MISS_CHAR,
    state_depre_basis_percent      NUMBER := OKC_API.G_MISS_NUM,
    state_depre_method             OKL_SIF_LINES.STATE_DEPRE_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    purchase_option                OKL_SIF_LINES.PURCHASE_OPTION%TYPE := OKC_API.G_MISS_CHAR,
    purchase_option_amount         NUMBER := OKC_API.G_MISS_NUM,
    asset_cost                     NUMBER := OKC_API.G_MISS_NUM,
    state_depre_term               NUMBER := OKC_API.G_MISS_NUM,
    state_depre_adr_convent        OKL_SIF_LINES.STATE_DEPRE_ADR_CONVENT%TYPE := OKC_API.G_MISS_CHAR,
    fed_depre_method               OKL_SIF_LINES.FED_DEPRE_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    residual_amount                NUMBER := OKC_API.G_MISS_NUM,
    fed_depre_salvage              OKL_SIF_LINES.FED_DEPRE_SALVAGE%TYPE,
    date_fed_depre                 OKL_SIF_LINES.DATE_FED_DEPRE%TYPE := OKC_API.G_MISS_DATE,
    book_salvage                   NUMBER := OKC_API.G_MISS_NUM,
    book_adr_convention            OKL_SIF_LINES.BOOK_ADR_CONVENTION%TYPE := OKC_API.G_MISS_CHAR,
    state_depre_salvage            NUMBER := OKC_API.G_MISS_NUM,
    fed_depre_basis_percent        NUMBER := OKC_API.G_MISS_NUM,
    book_basis_percent             NUMBER := OKC_API.G_MISS_NUM,
    date_delivery                  OKL_SIF_LINES.DATE_DELIVERY%TYPE := OKC_API.G_MISS_DATE,
    book_term                      NUMBER := OKC_API.G_MISS_NUM,
    residual_guarantee_amount      NUMBER := OKC_API.G_MISS_NUM,
    date_funding                   OKL_SIF_LINES.DATE_FUNDING%TYPE := OKC_API.G_MISS_DATE,
    date_book                      OKL_SIF_LINES.DATE_BOOK%TYPE := OKC_API.G_MISS_DATE,
    date_state_depre               OKL_SIF_LINES.DATE_STATE_DEPRE%TYPE := OKC_API.G_MISS_DATE,
    book_method                    OKL_SIF_LINES.BOOK_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute01   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    index_number                   NUMBER := OKC_API.G_MISS_NUM,
    stream_interface_attribute05   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_SIF_LINES.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_LINES.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    date_start                     OKL_SIF_LINES.DATE_START%TYPE := OKC_API.G_MISS_DATE,
    date_lending                   OKL_SIF_LINES.DATE_LENDING%TYPE := OKC_API.G_MISS_DATE,
    sif_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    sil_type                       OKL_SIF_LINES.SIL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_LINES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_LINES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    -- mvasudev, 05/13/2002
    residual_guarantee_type        OKL_SIF_LINES.RESIDUAL_GUARANTEE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    -- rgooty: Bug #4629365
    ,down_payment_amount           NUMBER := OKC_API.G_MISS_NUM
    ,capitalize_down_payment_yn    OKL_SIF_LINES.CAPITALIZE_DOWN_PAYMENT_YN%TYPE := OKC_API.G_MISS_CHAR
	,orig_contract_line_id                   NUMBER := OKC_API.G_MISS_NUM);
  g_miss_sil_rec                          sil_rec_type;
  TYPE sil_tbl_type IS TABLE OF sil_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE silv_rec_type IS RECORD (
    id                             NUMBER := OKC_API.G_MISS_NUM,
    state_depre_dmnshing_value_rt  NUMBER := OKC_API.G_MISS_NUM,
    book_depre_dmnshing_value_rt   NUMBER := OKC_API.G_MISS_NUM,
    residual_guarantee_method      OKL_SIF_LINES_V.RESIDUAL_GUARANTEE_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    residual_date                  OKL_SIF_LINES_V.RESIDUAL_DATE%TYPE := OKC_API.G_MISS_DATE,
    fed_depre_term                 NUMBER := OKC_API.G_MISS_NUM,
    fed_depre_dmnshing_value_rate  NUMBER := OKC_API.G_MISS_NUM,
    fed_depre_adr_conve            OKL_SIF_LINES_V.FED_DEPRE_ADR_CONVE%TYPE := OKC_API.G_MISS_CHAR,
    state_depre_basis_percent      NUMBER := OKC_API.G_MISS_NUM,
    state_depre_method             OKL_SIF_LINES_V.STATE_DEPRE_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    purchase_option                OKL_SIF_LINES_V.PURCHASE_OPTION%TYPE := OKC_API.G_MISS_CHAR,
    purchase_option_amount         NUMBER := OKC_API.G_MISS_NUM,
    asset_cost                     NUMBER := OKC_API.G_MISS_NUM,
    state_depre_term               NUMBER := OKC_API.G_MISS_NUM,
    state_depre_adr_convent        OKL_SIF_LINES_V.STATE_DEPRE_ADR_CONVENT%TYPE := OKC_API.G_MISS_CHAR,
    fed_depre_method               OKL_SIF_LINES_V.FED_DEPRE_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    residual_amount                NUMBER := OKC_API.G_MISS_NUM,
    fed_depre_salvage              OKL_SIF_LINES_V.FED_DEPRE_SALVAGE%TYPE,
    date_fed_depre                 OKL_SIF_LINES_V.DATE_FED_DEPRE%TYPE := OKC_API.G_MISS_DATE,
    book_salvage                   NUMBER := OKC_API.G_MISS_NUM,
    book_adr_convention            OKL_SIF_LINES_V.BOOK_ADR_CONVENTION%TYPE := OKC_API.G_MISS_CHAR,
    state_depre_salvage            NUMBER := OKC_API.G_MISS_NUM,
    fed_depre_basis_percent        NUMBER := OKC_API.G_MISS_NUM,
    book_basis_percent             NUMBER := OKC_API.G_MISS_NUM,
    date_delivery                  OKL_SIF_LINES_V.DATE_DELIVERY%TYPE := OKC_API.G_MISS_DATE,
    book_term                      NUMBER := OKC_API.G_MISS_NUM,
    residual_guarantee_amount      NUMBER := OKC_API.G_MISS_NUM,
    date_funding                   OKL_SIF_LINES_V.DATE_FUNDING%TYPE := OKC_API.G_MISS_DATE,
    date_book                      OKL_SIF_LINES_V.DATE_BOOK%TYPE := OKC_API.G_MISS_DATE,
    date_state_depre               OKL_SIF_LINES_V.DATE_STATE_DEPRE%TYPE := OKC_API.G_MISS_DATE,
    book_method                    OKL_SIF_LINES_V.BOOK_METHOD%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute01   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    index_number                   NUMBER := OKC_API.G_MISS_NUM,
    stream_interface_attribute05   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_SIF_LINES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_LINES_V.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    date_start                     OKL_SIF_LINES_V.DATE_START%TYPE := OKC_API.G_MISS_DATE,
    date_lending                   OKL_SIF_LINES_V.DATE_LENDING%TYPE := OKC_API.G_MISS_DATE,
    sif_id                         NUMBER := OKC_API.G_MISS_NUM,
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    sil_type                       OKL_SIF_LINES_V.SIL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER := OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_LINES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_LINES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    -- mvasudev, 05/13/2002
    residual_guarantee_type      OKL_SIF_LINES_V.RESIDUAL_GUARANTEE_TYPE%TYPE := OKC_API.G_MISS_CHAR
    -- rgooty: Bug #4629365
    ,down_payment_amount           NUMBER := OKC_API.G_MISS_NUM
    ,capitalize_down_payment_yn    OKL_SIF_LINES_V.CAPITALIZE_DOWN_PAYMENT_YN%TYPE := OKC_API.G_MISS_CHAR
	,orig_contract_line_id                   NUMBER := OKC_API.G_MISS_NUM
    );
    g_miss_silv_rec                         silv_rec_type;
  TYPE silv_tbl_type IS TABLE OF silv_rec_type
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

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SIL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_SIL_TYPE_LEASE		CONSTANT VARCHAR2(10)   :=  'SGA';
  G_SIL_TYPE_LOAN		CONSTANT VARCHAR2(10)   :=  'SGN';

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
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
    p_silv_rec                     IN silv_rec_type,
    x_silv_rec                     OUT NOCOPY silv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type,
    x_silv_tbl                     OUT NOCOPY silv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type,
    x_silv_rec                     OUT NOCOPY silv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type,
    x_silv_tbl                     OUT NOCOPY silv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_rec                     IN silv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_silv_tbl                     IN silv_tbl_type);

END OKL_SIL_PVT;

/
