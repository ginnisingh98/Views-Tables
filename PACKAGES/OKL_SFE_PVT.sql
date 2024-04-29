--------------------------------------------------------
--  DDL for Package OKL_SFE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SFE_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSFES.pls 120.5.12010000.3 2009/07/21 00:25:29 sechawla ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sfe_rec_type IS RECORD (
    id                             NUMBER:= OKC_API.G_MISS_NUM,
    sfe_type                       OKL_SIF_FEES.SFE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    date_start                     OKL_SIF_FEES.DATE_START%TYPE := OKC_API.G_MISS_DATE,
    date_paid                      OKL_SIF_FEES.DATE_PAID%TYPE := OKC_API.G_MISS_DATE,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    idc_accounting_flag            OKL_SIF_FEES.IDC_ACCOUNTING_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    income_or_expense              OKL_SIF_FEES.INCOME_OR_EXPENSE%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_SIF_FEES.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    fee_index_number               NUMBER := OKC_API.G_MISS_NUM,
    level_index_number             NUMBER := OKC_API.G_MISS_NUM,
    advance_or_arrears             OKL_SIF_FEES.ADVANCE_OR_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
    level_type                     OKL_SIF_FEES.LEVEL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    lock_level_step                OKL_SIF_FEES.LOCK_LEVEL_STEP%TYPE := OKC_API.G_MISS_CHAR,
    period                         OKL_SIF_FEES.PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    number_of_periods              NUMBER := OKC_API.G_MISS_NUM,
    level_line_number              NUMBER := OKC_API.G_MISS_NUM,
    sif_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    sil_id                         NUMBER:= OKC_API.G_MISS_NUM,
    rate			   NUMBER := OKC_API.G_MISS_NUM,
    -- 05/13/2002, mvasudev
    -- added for "Restructure" requirements
    query_level_yn                 OKL_SIF_FEES.QUERY_LEVEL_YN%TYPE := OKC_API.G_MISS_CHAR,
    structure                      OKL_SIF_FEES.STRUCTURE%TYPE := OKC_API.G_MISS_CHAR,
    days_in_period                 NUMBER := OKC_API.G_MISS_NUM,
    --
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    cash_effect_yn    		   OKL_SIF_FEES.cash_effect_yn%TYPE := OKC_API.G_MISS_CHAR,
    tax_effect_yn      		   OKL_SIF_FEES.tax_effect_yn%TYPE := OKC_API.G_MISS_CHAR,
    DAYS_IN_MONTH                  OKL_SIF_FEES.DAYS_IN_MONTH%TYPE                := OKC_API.G_MISS_CHAR,
    DAYS_IN_YEAR                   OKL_SIF_FEES.DAYS_IN_YEAR%TYPE                 := OKC_API.G_MISS_CHAR,
    BALANCE_TYPE_CODE              OKL_SIF_FEES.BALANCE_TYPE_CODE%TYPE                 := OKC_API.G_MISS_CHAR,
    stream_interface_attribute01   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute11   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute16   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE16%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute17   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE17%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute18   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE18%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute19   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE19%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute20   OKL_SIF_FEES.STREAM_INTERFACE_ATTRIBUTE20%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER:= OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_FEES.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_FEES.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    down_payment_amount            NUMBER := OKC_API.G_MISS_NUM,
	orig_contract_line_id					   NUMBER := OKC_API.G_MISS_NUM	);
  g_miss_sfe_rec                          sfe_rec_type;
  TYPE sfe_tbl_type IS TABLE OF sfe_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE sfev_rec_type IS RECORD (
    id                             NUMBER:= OKC_API.G_MISS_NUM,
    sfe_type                       OKL_SIF_FEES_V.SFE_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    date_start                     OKL_SIF_FEES_V.DATE_START%TYPE := OKC_API.G_MISS_DATE,
    date_paid                      OKL_SIF_FEES_V.DATE_PAID%TYPE := OKC_API.G_MISS_DATE,
    amount                         NUMBER := OKC_API.G_MISS_NUM,
    idc_accounting_flag            OKL_SIF_FEES_V.IDC_ACCOUNTING_FLAG%TYPE := OKC_API.G_MISS_CHAR,
    income_or_expense              OKL_SIF_FEES_V.INCOME_OR_EXPENSE%TYPE := OKC_API.G_MISS_CHAR,
    description                    OKL_SIF_FEES_V.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR,
    fee_index_number               NUMBER := OKC_API.G_MISS_NUM,
    level_index_number             NUMBER := OKC_API.G_MISS_NUM,
    advance_or_arrears             OKL_SIF_FEES_V.ADVANCE_OR_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
    level_type                     OKL_SIF_FEES_V.LEVEL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    lock_level_step                OKL_SIF_FEES_V.LOCK_LEVEL_STEP%TYPE := OKC_API.G_MISS_CHAR,
    period                         OKL_SIF_FEES_V.PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    number_of_periods              NUMBER := OKC_API.G_MISS_NUM,
    level_line_number              NUMBER := OKC_API.G_MISS_NUM,
    sif_id                         NUMBER := OKC_API.G_MISS_NUM,
    kle_id                         NUMBER := OKC_API.G_MISS_NUM,
    sil_id                         NUMBER:= OKC_API.G_MISS_NUM,
    rate			   NUMBER := OKC_API.G_MISS_NUM,
    -- 05/13/2002, mvasudev
    -- added for "Restructure" requirements
    query_level_yn                 OKL_SIF_FEES_V.QUERY_LEVEL_YN%TYPE := OKC_API.G_MISS_CHAR,
    structure                      OKL_SIF_FEES_V.STRUCTURE%TYPE := OKC_API.G_MISS_CHAR,
    days_in_period                 NUMBER := OKC_API.G_MISS_NUM,
    --
    object_version_number          NUMBER := OKC_API.G_MISS_NUM,
    cash_effect_yn    		   OKL_SIF_FEES_v.cash_effect_yn%TYPE := OKC_API.G_MISS_CHAR,
    tax_effect_yn      		   OKL_SIF_FEES_v.tax_effect_yn%TYPE := OKC_API.G_MISS_CHAR,
    days_in_month                  OKL_SIF_FEES.DAYS_IN_MONTH%TYPE                := OKC_API.G_MISS_CHAR,
    days_in_year                   OKL_SIF_FEES.DAYS_IN_YEAR%TYPE                 := OKC_API.G_MISS_CHAR,
    balance_type_code              OKL_SIF_FEES.BALANCE_TYPE_CODE%TYPE            := OKC_API.G_MISS_CHAR,
    stream_interface_attribute01   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE01%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute02   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE02%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute03   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE03%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute04   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE04%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute05   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE05%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute06   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE06%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute07   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE07%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute08   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE08%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute09   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE09%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute10   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE10%TYPE := OKC_API.G_MISS_CHAR,

    stream_interface_attribute11   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE11%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute12   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE12%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute13   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE13%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute14   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE14%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute15   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE15%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute16   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE16%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute17   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE17%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute18   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE18%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute19   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE19%TYPE := OKC_API.G_MISS_CHAR,
    stream_interface_attribute20   OKL_SIF_FEES_V.STREAM_INTERFACE_ATTRIBUTE20%TYPE := OKC_API.G_MISS_CHAR,
    created_by                     NUMBER:= OKC_API.G_MISS_NUM,
    last_updated_by                NUMBER := OKC_API.G_MISS_NUM,
    creation_date                  OKL_SIF_FEES_V.CREATION_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_date               OKL_SIF_FEES_V.LAST_UPDATE_DATE%TYPE := OKC_API.G_MISS_DATE,
    last_update_login              NUMBER := OKC_API.G_MISS_NUM,
    down_payment_amount            NUMBER := OKC_API.G_MISS_NUM,
	orig_contract_line_id                    NUMBER := OKC_API.G_MISS_NUM );
  g_miss_sfev_rec                         sfev_rec_type;
  TYPE sfev_tbl_type IS TABLE OF sfev_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_OKC_APP			CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;



  -- START CHANGE : akjain -- 09/05/2001
  -- Adding MESSAGE CONSTANTs
  G_OKL_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_OKL_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_OKL_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_OKL_UNQS					CONSTANT VARCHAR2(200) := 'OKL_SFE_NOT_UNIQUE';
  G_SFE_TYPE_ONE_OFF			CONSTANT VARCHAR2(200) := 'SFO';

  -- 04/23/2003 , mvasudev
  G_SFE_TYPE_PERIODIC_EXPENSE		CONSTANT VARCHAR2(200) := 'SFP';
  G_SFE_TYPE_RENT			CONSTANT VARCHAR2(200) := 'SFR';
  G_SFE_TYPE_LOAN			CONSTANT VARCHAR2(200) := 'SFN';
  G_SFE_TYPE_PERIODIC_INCOME		CONSTANT VARCHAR2(200) := 'SFI';
  -- end, mvasudev -- 04/23/2003
  -- start smahapat fee type soln
  G_SFE_TYPE_SECURITY_DEPOSIT		CONSTANT VARCHAR2(200) := 'SFD';

  -- start sgorantl for subsidies
  G_SFE_TYPE_SUBSIDY           		CONSTANT VARCHAR2(200) := 'SFB';

  -- start smahapat fee type soln

  -- Added Exception for Halt_validation
  --------------------------------------------------------------------------------
  -- ERRORS AND EXCEPTIONS
  --------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  -- END change : akjain


  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SFE_PVT';
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
    p_sfev_rec                     IN sfev_rec_type,
    x_sfev_rec                     OUT NOCOPY sfev_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type,
    x_sfev_tbl                     OUT NOCOPY sfev_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type,
    x_sfev_rec                     OUT NOCOPY sfev_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type,
    x_sfev_tbl                     OUT NOCOPY sfev_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_rec                     IN sfev_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sfev_tbl                     IN sfev_tbl_type);

END OKL_SFE_PVT;

/
