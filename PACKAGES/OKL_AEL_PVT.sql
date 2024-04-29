--------------------------------------------------------
--  DDL for Package OKL_AEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AEL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSAELS.pls 120.2 2006/07/11 10:08:40 dkagrawa noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE ael_rec_type IS RECORD (
    AE_LINE_ID                     NUMBER := Okc_Api.G_MISS_NUM,
    code_combination_id            NUMBER := Okc_Api.G_MISS_NUM,
    AE_HEADER_ID                   NUMBER := Okc_Api.G_MISS_NUM,
    currency_conversion_type       OKL_AE_LINES.CURRENCY_CONVERSION_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    AE_LINE_NUMBER                 NUMBER := Okc_Api.G_MISS_NUM,
    AE_LINE_TYPE_CODE              OKL_AE_LINES.AE_LINE_TYPE_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    source_table                   OKL_AE_LINES.SOURCE_TABLE%TYPE := Okc_Api.G_MISS_CHAR,
    source_id                      NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    currency_code                      OKL_AE_LINES.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    currency_conversion_date       OKL_AE_LINES.CURRENCY_CONVERSION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    currency_conversion_rate       NUMBER := Okc_Api.G_MISS_NUM,
    ENTERED_DR                     NUMBER := Okc_Api.G_MISS_NUM,
    ENTERED_CR                     NUMBER := Okc_Api.G_MISS_NUM,
    ACCOUNTED_DR                   NUMBER := Okc_Api.G_MISS_NUM,
    ACCOUNTED_CR               NUMBER := Okc_Api.G_MISS_NUM,
    reference1                     OKL_AE_LINES.REFERENCE1%TYPE := Okc_Api.G_MISS_CHAR,
    reference2                     OKL_AE_LINES.REFERENCE2%TYPE := Okc_Api.G_MISS_CHAR,
    reference3                     OKL_AE_LINES.REFERENCE3%TYPE := Okc_Api.G_MISS_CHAR,
    reference4                     OKL_AE_LINES.REFERENCE4%TYPE := Okc_Api.G_MISS_CHAR,
    reference5                     OKL_AE_LINES.REFERENCE5%TYPE := Okc_Api.G_MISS_CHAR,
    reference6                     OKL_AE_LINES.REFERENCE6%TYPE := Okc_Api.G_MISS_CHAR,
    reference7                     OKL_AE_LINES.REFERENCE7%TYPE := Okc_Api.G_MISS_CHAR,
    reference8                     OKL_AE_LINES.REFERENCE8%TYPE := Okc_Api.G_MISS_CHAR,
    reference9                     OKL_AE_LINES.REFERENCE9%TYPE := Okc_Api.G_MISS_CHAR,
    reference10                    OKL_AE_LINES.REFERENCE10%TYPE := Okc_Api.G_MISS_CHAR,
    description                    OKL_AE_LINES.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    third_party_id                 NUMBER := Okc_Api.G_MISS_NUM,
    third_party_sub_id             NUMBER := Okc_Api.G_MISS_NUM,
    STAT_AMOUNT              NUMBER := Okc_Api.G_MISS_NUM,
    ussgl_transaction_code         OKL_AE_LINES.USSGL_TRANSACTION_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    subledger_doc_sequence_id      NUMBER := Okc_Api.G_MISS_NUM,
    accounting_error_code          OKL_AE_LINES.ACCOUNTING_ERROR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    gl_transfer_error_code         OKL_AE_LINES.GL_TRANSFER_ERROR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    GL_SL_LINK_ID                  NUMBER := Okc_Api.G_MISS_NUM,
    taxable_ENTERED_DR             NUMBER := Okc_Api.G_MISS_NUM,
    taxable_ENTERED_CR             NUMBER := Okc_Api.G_MISS_NUM,
    taxable_ACCOUNTED_DR           NUMBER := Okc_Api.G_MISS_NUM,
    taxable_ACCOUNTED_CR       NUMBER := Okc_Api.G_MISS_NUM,
    applied_from_trx_hdr_table     OKL_AE_LINES.APPLIED_FROM_TRX_HDR_TABLE%TYPE := Okc_Api.G_MISS_CHAR,
    applied_from_trx_hdr_id        NUMBER := Okc_Api.G_MISS_NUM,
    applied_to_trx_hdr_table       OKL_AE_LINES.APPLIED_TO_TRX_HDR_TABLE%TYPE := Okc_Api.G_MISS_CHAR,
    applied_to_trx_hdr_id          NUMBER := Okc_Api.G_MISS_NUM,
    tax_link_id                    NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_AE_LINES.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_AE_LINES.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_AE_LINES.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    ACCOUNT_OVERLAY_SOURCE_ID      NUMBER := Okc_Api.G_MISS_NUM,
    SUBLEDGER_DOC_SEQUENCE_VALUE   NUMBER := Okc_Api.G_MISS_NUM,
    TAX_CODE_ID                    NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_ael_rec                          ael_rec_type;
  TYPE ael_tbl_type IS TABLE OF ael_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE aelv_rec_type IS RECORD (
    AE_LINE_ID                     NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    AE_HEADER_ID                  NUMBER := Okc_Api.G_MISS_NUM,
    currency_conversion_type       OKL_AE_LINES.CURRENCY_CONVERSION_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
    code_combination_id            NUMBER := Okc_Api.G_MISS_NUM,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    AE_LINE_NUMBER                 NUMBER := Okc_Api.G_MISS_NUM,
    AE_LINE_TYPE_CODE              OKL_AE_LINES.AE_LINE_TYPE_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    currency_conversion_date       OKL_AE_LINES.CURRENCY_CONVERSION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    currency_conversion_rate       NUMBER := Okc_Api.G_MISS_NUM,
    ENTERED_DR                     NUMBER := Okc_Api.G_MISS_NUM,
    ENTERED_CR                     NUMBER := Okc_Api.G_MISS_NUM,
    ACCOUNTED_DR                   NUMBER := Okc_Api.G_MISS_NUM,
    ACCOUNTED_CR               NUMBER := Okc_Api.G_MISS_NUM,
    source_table                   OKL_AE_LINES.SOURCE_TABLE%TYPE := Okc_Api.G_MISS_CHAR,
    source_id                      NUMBER := Okc_Api.G_MISS_NUM,
    reference1                     OKL_AE_LINES.REFERENCE1%TYPE := Okc_Api.G_MISS_CHAR,
    reference2                     OKL_AE_LINES.REFERENCE2%TYPE := Okc_Api.G_MISS_CHAR,
    reference3                     OKL_AE_LINES.REFERENCE3%TYPE := Okc_Api.G_MISS_CHAR,
    reference4                     OKL_AE_LINES.REFERENCE4%TYPE := Okc_Api.G_MISS_CHAR,
    reference5                     OKL_AE_LINES.REFERENCE5%TYPE := Okc_Api.G_MISS_CHAR,
    reference6                     OKL_AE_LINES.REFERENCE6%TYPE := Okc_Api.G_MISS_CHAR,
    reference7                     OKL_AE_LINES.REFERENCE7%TYPE := Okc_Api.G_MISS_CHAR,
    reference8                     OKL_AE_LINES.REFERENCE8%TYPE := Okc_Api.G_MISS_CHAR,
    reference9                     OKL_AE_LINES.REFERENCE9%TYPE := Okc_Api.G_MISS_CHAR,
    reference10                    OKL_AE_LINES.REFERENCE10%TYPE := Okc_Api.G_MISS_CHAR,
    description                    OKL_AE_LINES.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    third_party_id                 NUMBER := Okc_Api.G_MISS_NUM,
    third_party_sub_id             NUMBER := Okc_Api.G_MISS_NUM,
    STAT_AMOUNT              NUMBER := Okc_Api.G_MISS_NUM,
    ussgl_transaction_code         OKL_AE_LINES.USSGL_TRANSACTION_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    subledger_doc_sequence_id      NUMBER := Okc_Api.G_MISS_NUM,
    accounting_error_code          OKL_AE_LINES.ACCOUNTING_ERROR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    gl_transfer_error_code         OKL_AE_LINES.GL_TRANSFER_ERROR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    GL_SL_LINK_ID                  NUMBER := Okc_Api.G_MISS_NUM,
    taxable_ENTERED_DR             NUMBER := Okc_Api.G_MISS_NUM,
    taxable_ENTERED_CR             NUMBER := Okc_Api.G_MISS_NUM,
    taxable_ACCOUNTED_DR           NUMBER := Okc_Api.G_MISS_NUM,
    taxable_ACCOUNTED_CR       NUMBER := Okc_Api.G_MISS_NUM,
    applied_from_trx_hdr_table     OKL_AE_LINES.APPLIED_FROM_TRX_HDR_TABLE%TYPE := Okc_Api.G_MISS_CHAR,
    applied_from_trx_hdr_id        NUMBER := Okc_Api.G_MISS_NUM,
    applied_to_trx_hdr_table       OKL_AE_LINES.APPLIED_TO_TRX_HDR_TABLE%TYPE := Okc_Api.G_MISS_CHAR,
    applied_to_trx_hdr_id          NUMBER := Okc_Api.G_MISS_NUM,
    tax_link_id                    NUMBER := Okc_Api.G_MISS_NUM,
    currency_code                      OKL_AE_LINES.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_AE_LINES.PROGRAM_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
	aeh_tbl_index                        NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_AE_LINES.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_AE_LINES.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    ACCOUNT_OVERLAY_SOURCE_ID      NUMBER := Okc_Api.G_MISS_NUM,
    SUBLEDGER_DOC_SEQUENCE_VALUE   NUMBER := Okc_Api.G_MISS_NUM,
    TAX_CODE_ID                    NUMBER := Okc_Api.G_MISS_NUM);
  g_miss_aelv_rec                         aelv_rec_type;
  TYPE aelv_tbl_type IS TABLE OF aelv_rec_type
        INDEX BY BINARY_INTEGER;
 --gboomina bug#4648697.changes for perf start
     --Added column arrarys for bulk insert
     TYPE ae_line_id_typ IS TABLE OF okl_ae_lines.ae_line_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE account_overlay_source_id_typ IS TABLE OF okl_ae_lines.account_overlay_source_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE subledger_doc_seq_value_typ IS TABLE OF okl_ae_lines.subledger_doc_sequence_value%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE tax_code_id_typ IS TABLE OF okl_ae_lines.tax_code_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE ae_line_number_typ IS TABLE OF okl_ae_lines.ae_line_number%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE code_combination_id_typ IS TABLE OF okl_ae_lines.code_combination_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE ae_header_id_typ IS TABLE OF okl_ae_lines.ae_header_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE currency_conversion_type_typ IS TABLE OF okl_ae_lines.currency_conversion_type%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE ae_line_type_code_typ IS TABLE OF okl_ae_lines.ae_line_type_code%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE source_table_typ IS TABLE OF okl_ae_lines.source_table%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE source_id_typ IS TABLE OF okl_ae_lines.source_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE object_version_number_typ IS TABLE OF okl_ae_lines.object_version_number%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE currency_code_typ IS TABLE OF okl_ae_lines.currency_code%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE currency_conversion_date_typ IS TABLE OF okl_ae_lines.currency_conversion_date%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE currency_conversion_rate_typ IS TABLE OF okl_ae_lines.currency_conversion_rate%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE entered_dr_typ IS TABLE OF okl_ae_lines.entered_dr%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE entered_cr_typ IS TABLE OF okl_ae_lines.entered_cr%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE accounted_dr_typ IS TABLE OF okl_ae_lines.accounted_dr%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE accounted_cr_typ IS TABLE OF okl_ae_lines.accounted_cr%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference1_typ IS TABLE OF okl_ae_lines.reference1%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference2_typ IS TABLE OF okl_ae_lines.reference2%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference3_typ IS TABLE OF okl_ae_lines.reference3%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference4_typ IS TABLE OF okl_ae_lines.reference4%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference5_typ IS TABLE OF okl_ae_lines.reference5%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference6_typ IS TABLE OF okl_ae_lines.reference6%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference7_typ IS TABLE OF okl_ae_lines.reference7%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference8_typ IS TABLE OF okl_ae_lines.reference8%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference9_typ IS TABLE OF okl_ae_lines.reference9%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE reference10_typ IS TABLE OF okl_ae_lines.reference10%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE description_typ IS TABLE OF okl_ae_lines.description%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE third_party_id_typ IS TABLE OF okl_ae_lines.third_party_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE third_party_sub_id_typ IS TABLE OF okl_ae_lines.third_party_sub_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE stat_amount_typ IS TABLE OF okl_ae_lines.stat_amount%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE ussgl_transaction_code_typ IS TABLE OF okl_ae_lines.ussgl_transaction_code%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE subledger_doc_sequence_id_typ IS TABLE OF okl_ae_lines.subledger_doc_sequence_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE accounting_error_code_typ IS TABLE OF okl_ae_lines.accounting_error_code%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE gl_transfer_error_code_typ IS TABLE OF okl_ae_lines.gl_transfer_error_code%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE gl_sl_link_id_typ IS TABLE OF okl_ae_lines.gl_sl_link_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE taxable_entered_dr_typ IS TABLE OF okl_ae_lines.taxable_entered_dr%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE taxable_entered_cr_typ IS TABLE OF okl_ae_lines.taxable_entered_cr%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE taxable_accounted_dr_typ IS TABLE OF okl_ae_lines.taxable_accounted_dr%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE taxable_accounted_cr_typ IS TABLE OF okl_ae_lines.taxable_accounted_cr%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE applied_from_trx_hdr_tab_typ IS TABLE OF okl_ae_lines.applied_from_trx_hdr_table%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE applied_from_trx_hdr_id_typ IS TABLE OF okl_ae_lines.applied_from_trx_hdr_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE applied_to_trx_hdr_table_typ IS TABLE OF okl_ae_lines.applied_to_trx_hdr_table%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE applied_to_trx_hdr_id_typ IS TABLE OF okl_ae_lines.applied_to_trx_hdr_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE tax_link_id_typ IS TABLE OF okl_ae_lines.tax_link_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE org_id_typ IS TABLE OF okl_ae_lines.org_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE program_id_typ IS TABLE OF okl_ae_lines.program_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE program_application_id_typ IS TABLE OF okl_ae_lines.program_application_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE program_update_date_typ IS TABLE OF okl_ae_lines.program_update_date%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE request_id_typ IS TABLE OF okl_ae_lines.request_id%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE created_by_typ IS TABLE OF okl_ae_lines.created_by%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE creation_date_typ IS TABLE OF okl_ae_lines.creation_date%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE last_updated_by_typ IS TABLE OF okl_ae_lines.last_updated_by%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE last_update_date_typ IS TABLE OF okl_ae_lines.last_update_date%TYPE
         INDEX BY BINARY_INTEGER;
     TYPE last_update_login_typ IS TABLE OF okl_ae_lines.last_update_login%TYPE
         INDEX BY BINARY_INTEGER;
     --gboomina bug#4648697.changes for perf end

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
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPERCASE_REQUIRED	CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_UNQS	CONSTANT VARCHAR2(200) := 'OKL_AEL_ELEMENT_NOT_UNIQUE';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AEL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;

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
    p_aelv_rec                     IN aelv_rec_type,
    x_aelv_rec                     OUT NOCOPY aelv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type,
    x_aelv_tbl                     OUT NOCOPY aelv_tbl_type);

  --gboomina bug#4648697.changes for perf start
     --added new procedure for bulk insert
     PROCEDURE insert_row_perf(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_aelv_tbl                     IN aelv_tbl_type,
       x_aelv_tbl                     OUT NOCOPY aelv_tbl_type);
     --gboomina bug#4648697.changes for perf end

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type,
    x_aelv_rec                     OUT NOCOPY aelv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type,
    x_aelv_tbl                     OUT NOCOPY aelv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_rec                     IN aelv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aelv_tbl                     IN aelv_tbl_type);

END Okl_Ael_Pvt;

/
