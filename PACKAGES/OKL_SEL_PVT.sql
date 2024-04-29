--------------------------------------------------------
--  DDL for Package OKL_SEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSELS.pls 120.2 2005/06/24 03:12:09 hkpatel noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE sel_rec_type IS RECORD (
    id                             NUMBER,
    stm_id                         NUMBER,
    object_version_number          NUMBER,
    stream_element_date            OKL_STRM_ELEMENTS.STREAM_ELEMENT_DATE%TYPE,
    amount                         NUMBER,
    comments                       OKL_STRM_ELEMENTS.COMMENTS%TYPE,
    accrued_yn                     OKL_STRM_ELEMENTS.ACCRUED_YN%TYPE,
    program_id                     NUMBER,
    request_id                     NUMBER,
    program_application_id         NUMBER,
    program_update_date            OKL_STRM_ELEMENTS.PROGRAM_UPDATE_DATE%TYPE,
    se_line_number                 OKL_STRM_ELEMENTS.SE_LINE_NUMBER%TYPE,
    date_billed                    OKL_STRM_ELEMENTS.DATE_BILLED%TYPE,
    created_by                     NUMBER,
    creation_date                  OKL_STRM_ELEMENTS.CREATION_DATE%TYPE,
    last_updated_by                NUMBER,
    last_update_date               OKL_STRM_ELEMENTS.LAST_UPDATE_DATE%TYPE,
    last_update_login              NUMBER,
---- Changed by Kjinger
    sel_id                         NUMBER,
--- Changes End
--Added by Keerthi 15-Sep-2003
    source_id			   NUMBER,
    source_table 		   OKL_STRM_ELEMENTS.SOURCE_TABLE%TYPE,
    -- Added by rgooty: 4212626
    bill_adj_flag          OKL_STRM_ELEMENTS.BILL_ADJ_FLAG%TYPE,
    accrual_adj_flag       OKL_STRM_ELEMENTS.ACCRUAL_ADJ_FLAG%TYPE,
	-- Added by hkpatel for bug 4350255
	date_disbursed         OKL_STRM_ELEMENTS.DATE_DISBURSED%TYPE );
  g_miss_sel_rec                          sel_rec_type;
  TYPE sel_tbl_type IS TABLE OF sel_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE selv_rec_type IS RECORD (
    id                             NUMBER ,
    object_version_number          NUMBER ,
    stm_id                         NUMBER ,
    amount                         NUMBER ,
    comments                       OKL_STRM_ELEMENTS_V.COMMENTS%TYPE ,
    accrued_yn                     OKL_STRM_ELEMENTS_V.ACCRUED_YN%TYPE ,
    stream_element_date            OKL_STRM_ELEMENTS_V.STREAM_ELEMENT_DATE%TYPE ,
    program_id                     NUMBER ,
    request_id                     NUMBER ,
    program_application_id         NUMBER ,
    program_update_date            OKL_STRM_ELEMENTS_V.PROGRAM_UPDATE_DATE%TYPE ,
    se_line_number                 OKL_STRM_ELEMENTS_V.SE_LINE_NUMBER%TYPE ,
    date_billed                    OKL_STRM_ELEMENTS_V.DATE_BILLED%TYPE ,
    created_by                     NUMBER ,
    creation_date                  OKL_STRM_ELEMENTS_V.CREATION_DATE%TYPE ,
    last_updated_by                NUMBER ,
    last_update_date               OKL_STRM_ELEMENTS_V.LAST_UPDATE_DATE%TYPE ,
    last_update_login              NUMBER ,
    parent_index                   NUMBER ,
---- Changed by Kjinger
    sel_id                         NUMBER ,
---- Changes End
--Added by Keerthi 15-Sep-2003
    source_id			   NUMBER ,
    source_table 		   OKL_STRM_ELEMENTS.SOURCE_TABLE%TYPE,
    -- Added by rgooty: 4212626
    bill_adj_flag          OKL_STRM_ELEMENTS_V.BILL_ADJ_FLAG%TYPE,
    accrual_adj_flag       OKL_STRM_ELEMENTS_V.ACCRUAL_ADJ_FLAG%TYPE,
		-- Added by hkpatel for bug 4350255
	date_disbursed         OKL_STRM_ELEMENTS_V.DATE_DISBURSED%TYPE );


    g_miss_selv_rec                         selv_rec_type;
  TYPE selv_tbl_type IS TABLE OF selv_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := Okc_Api.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := Okc_Api.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := Okc_Api.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := Okc_Api.G_REQUIRED_VALUE;
  G_INVALID_VALUE			CONSTANT VARCHAR2(200) := Okc_Api.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := Okc_Api.G_CHILD_TABLE_TOKEN;
  -- START CHANGE : akjain -- 05/14/2001
    -- Adding MESSAGE CONSTANTs for 'Unique Key Validation','SQLCode', 'SQLErrM','Unexpected Error'
    G_SQLERRM_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
    G_SQLCODE_TOKEN             	CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
    G_UNEXPECTED_ERROR          	CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
	G_NO_PARENT_RECORD              CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_NO_PARENT_RECORD';
    G_UNQS			CONSTANT VARCHAR2(200) := 'OKL_UNIQUE_KEY_VALIDATION_FAILED';
  -- END CHANGE : akjain
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'Okl_Sel_Pvt';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;

  /* Hand written code start - akjain 05/10/2001 */
  ---------------------------------------------------------------------------
        -- GLOBAL EXCEPTIONS
      ---------------------------------------------------------------------------

      G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  /* hand written code end */


  ---------------------------------------------------------------------------
    -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type,
    x_selv_rec                     OUT NOCOPY selv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type,
    x_selv_tbl                     OUT NOCOPY selv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type,
    x_selv_rec                     OUT NOCOPY selv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type,
    x_selv_tbl                     OUT NOCOPY selv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_rec                     IN selv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_selv_tbl                     IN selv_tbl_type);

END Okl_Sel_Pvt;

 

/
