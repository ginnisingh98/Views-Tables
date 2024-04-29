--------------------------------------------------------
--  DDL for Package OKL_SYP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SYP_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSYPS.pls 120.21.12010000.3 2008/11/13 13:59:58 kkorrapo ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- OKL_SYSTEM_PARAMS_ALL_V Record Spec
  TYPE sypv_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,delink_yn                      OKL_SYSTEM_PARAMS.DELINK_YN%TYPE := OKL_API.G_MISS_CHAR
    -- SECHAWLA 28-SEP-04 3924244: Added the following new columns : begin
    ,REMK_SUBINVENTORY 				OKL_SYSTEM_PARAMS.REMK_SUBINVENTORY%TYPE := OKL_API.G_MISS_CHAR
	,REMK_ORGANIZATION_ID			OKL_SYSTEM_PARAMS.REMK_ORGANIZATION_ID%TYPE := OKL_API.G_MISS_NUM
	,REMK_PRICE_LIST_ID 			OKL_SYSTEM_PARAMS.REMK_PRICE_LIST_ID%TYPE := OKL_API.G_MISS_NUM
	,REMK_PROCESS_CODE             	OKL_SYSTEM_PARAMS.REMK_PROCESS_CODE%TYPE := OKL_API.G_MISS_CHAR
	,REMK_ITEM_TEMPLATE_ID			OKL_SYSTEM_PARAMS.REMK_ITEM_TEMPLATE_ID%TYPE := OKL_API.G_MISS_NUM
	,REMK_ITEM_INVOICED_CODE		OKL_SYSTEM_PARAMS.REMK_ITEM_INVOICED_CODE%TYPE := OKL_API.G_MISS_CHAR
	-- SECHAWLA 28-SEP-04 3924244: Added the following new columns : end
    -- PAGARG 24-JAN-05 4044659: Added the new column LEASE_INV_ORG_YN: begin
    ,LEASE_INV_ORG_YN 				OKL_SYSTEM_PARAMS.LEASE_INV_ORG_YN%TYPE := OKL_API.G_MISS_CHAR
    --SECHAWLA  28-MAR-05 4274575 : Added 3 new columns
    ,TAX_UPFRONT_YN                 OKL_SYSTEM_PARAMS.TAX_UPFRONT_YN%TYPE := OKL_API.G_MISS_CHAR
    ,TAX_INVOICE_YN                 OKL_SYSTEM_PARAMS.TAX_INVOICE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,TAX_SCHEDULE_YN                OKL_SYSTEM_PARAMS.TAX_SCHEDULE_YN%TYPE := OKL_API.G_MISS_CHAR
    -- SECHAWLA 07-Jul-05 4274575 : added 1 new column
    ,TAX_UPFRONT_STY_ID				OKL_SYSTEM_PARAMS.TAX_UPFRONT_STY_ID%TYPE := OKL_API.G_MISS_NUM
    -- PAGARG 24-JAN-05 4044659: Added the new column LEASE_INV_ORG_YN: end
     -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
    ,CATEGORY_SET_ID		    OKL_SYSTEM_PARAMS.CATEGORY_SET_ID%TYPE := OKL_API.G_MISS_NUM
     -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
     -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements : begin
    ,VALIDATION_SET_ID		    OKL_SYSTEM_PARAMS.VALIDATION_SET_ID%TYPE := OKL_API.G_MISS_NUM
   -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements : end
    ,CANCEL_QUOTES_YN               OKL_SYSTEM_PARAMS.CANCEL_QUOTES_YN%TYPE := OKL_API.G_MISS_CHAR --RMUNJULU 4556370
    ,CHK_ACCRUAL_PREVIOUS_MNTH_YN  OKL_SYSTEM_PARAMS.CHK_ACCRUAL_PREVIOUS_MNTH_YN%TYPE := OKL_API.G_MISS_CHAR --RMUNJULU 4769094
    -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
    ,TASK_TEMPLATE_GROUP_ID OKL_SYSTEM_PARAMS.TASK_TEMPLATE_GROUP_ID%type := OKL_API.G_MISS_NUM
    ,OWNER_TYPE_CODE OKL_SYSTEM_PARAMS.OWNER_TYPE_CODE%type := OKL_API.G_MISS_CHAR
    ,OWNER_ID OKL_SYSTEM_PARAMS.OWNER_ID%type := OKL_API.G_MISS_NUM
    -- gboomina Bug 5128517 - End
    -- dcshanmu begin MOAC change for moving three new profiles to System Options
    ,ITEM_INV_ORG_ID OKL_SYSTEM_PARAMS.ITEM_INV_ORG_ID%type :=
OKL_API.G_MISS_NUM
    , RPT_PROD_BOOK_TYPE_CODE OKL_SYSTEM_PARAMS.RPT_PROD_BOOK_TYPE_CODE%type :=
OKL_API.G_MISS_CHAR
    ,ASST_ADD_BOOK_TYPE_CODE OKL_SYSTEM_PARAMS.ASST_ADD_BOOK_TYPE_CODE%type :=
OKL_API.G_MISS_CHAR
    ,CCARD_REMITTANCE_ID OKL_SYSTEM_PARAMS.CCARD_REMITTANCE_ID%type := OKL_API.G_MISS_NUM
    -- dcshanmu end MOAC change for moving three new profiles to System Options

    -- DJANASWA Bug 6653304 begin
    ,CORPORATE_BOOK       OKL_SYSTEM_PARAMS.CORPORATE_BOOK%type := OKL_API.G_MISS_CHAR
    ,TAX_BOOK_1           OKL_SYSTEM_PARAMS.TAX_BOOK_1%type := OKL_API.G_MISS_CHAR
    ,TAX_BOOK_2           OKL_SYSTEM_PARAMS.TAX_BOOK_2%type := OKL_API.G_MISS_CHAR
    ,DEPRECIATE_YN        OKL_SYSTEM_PARAMS.DEPRECIATE_YN%type := OKL_API.G_MISS_CHAR
    ,FA_LOCATION_ID       OKL_SYSTEM_PARAMS.FA_LOCATION_ID%type := OKL_API.G_MISS_NUM
    ,FORMULA_ID           OKL_SYSTEM_PARAMS.FORMULA_ID%type := OKL_API.G_MISS_NUM
    ,ASSET_KEY_ID         OKL_SYSTEM_PARAMS.ASSET_KEY_ID%type := OKL_API.G_MISS_NUM
    -- DJANASWA Bug 6653304 end
		-- Bug 5568328
    ,part_trmnt_apply_round_diff    okl_system_params.part_trmnt_apply_round_diff%type := okl_api.g_miss_char
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_SYSTEM_PARAMS.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_SYSTEM_PARAMS.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SYSTEM_PARAMS.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SYSTEM_PARAMS.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SYSTEM_PARAMS.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SYSTEM_PARAMS.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SYSTEM_PARAMS.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SYSTEM_PARAMS.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SYSTEM_PARAMS.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SYSTEM_PARAMS.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SYSTEM_PARAMS.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SYSTEM_PARAMS.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SYSTEM_PARAMS.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SYSTEM_PARAMS.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SYSTEM_PARAMS.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SYSTEM_PARAMS.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SYSTEM_PARAMS.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SYSTEM_PARAMS.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SYSTEM_PARAMS.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    --Bug 7022258-Added new columns by kkorrapo
    ,lseapp_seq_prefix_txt          OKL_SYSTEM_PARAMS.LSEAPP_SEQ_PREFIX_TXT%TYPE := OKL_API.G_MISS_CHAR
    ,lseopp_seq_prefix_txt          OKL_SYSTEM_PARAMS.LSEOPP_SEQ_PREFIX_TXT%TYPE := OKL_API.G_MISS_CHAR
    ,qckqte_seq_prefix_txt          OKL_SYSTEM_PARAMS.QCKQTE_SEQ_PREFIX_TXT%TYPE := OKL_API.G_MISS_CHAR
    ,lseqte_seq_prefix_txt          OKL_SYSTEM_PARAMS.LSEQTE_SEQ_PREFIX_TXT%TYPE := OKL_API.G_MISS_CHAR
    --Bug 7022258-Addition end
    );
  G_Miss_sypv_rec                sypv_rec_type;
  TYPE sypv_tbl_type IS TABLE OF sypv_rec_type
        INDEX BY BINARY_INTEGER;
  -- OKL_SYSTEM_PARAMS_ALL Record Spec
  TYPE syp_rec_type IS RECORD (
     id                             NUMBER := OKL_API.G_MISS_NUM
    ,delink_yn                      OKL_SYSTEM_PARAMS_ALL.DELINK_YN%TYPE := OKL_API.G_MISS_CHAR
    -- SECHAWLA 28-SEP-04 3924244: Added the following new columns : begin
    ,REMK_SUBINVENTORY 				OKL_SYSTEM_PARAMS_ALL.REMK_SUBINVENTORY%TYPE := OKL_API.G_MISS_CHAR
	,REMK_ORGANIZATION_ID			OKL_SYSTEM_PARAMS_ALL.REMK_ORGANIZATION_ID%TYPE := OKL_API.G_MISS_NUM
	,REMK_PRICE_LIST_ID 			OKL_SYSTEM_PARAMS_ALL.REMK_PRICE_LIST_ID%TYPE := OKL_API.G_MISS_NUM
	,REMK_PROCESS_CODE         		OKL_SYSTEM_PARAMS_ALL.REMK_PROCESS_CODE%TYPE := OKL_API.G_MISS_CHAR
	,REMK_ITEM_TEMPLATE_ID			OKL_SYSTEM_PARAMS_ALL.REMK_ITEM_TEMPLATE_ID%TYPE := OKL_API.G_MISS_NUM
	,REMK_ITEM_INVOICED_CODE		OKL_SYSTEM_PARAMS_ALL.REMK_ITEM_INVOICED_CODE%TYPE := OKL_API.G_MISS_CHAR
	-- SECHAWLA 28-SEP-04 3924244: Added the following new columns : end
    -- PAGARG 24-JAN-05 4044659: Added the new column LEASE_INV_ORG_YN: begin
    ,LEASE_INV_ORG_YN 				OKL_SYSTEM_PARAMS.LEASE_INV_ORG_YN%TYPE := OKL_API.G_MISS_CHAR
    --28-MAR-05 SECHAWLA 4274575 : Added 3 new columns
    ,TAX_UPFRONT_YN                 OKL_SYSTEM_PARAMS.TAX_UPFRONT_YN%TYPE := OKL_API.G_MISS_CHAR
    ,TAX_INVOICE_YN                 OKL_SYSTEM_PARAMS.TAX_INVOICE_YN%TYPE := OKL_API.G_MISS_CHAR
    ,TAX_SCHEDULE_YN                OKL_SYSTEM_PARAMS.TAX_SCHEDULE_YN%TYPE := OKL_API.G_MISS_CHAR
    --07-Jul-05 SECHAWLA 4274575 : Added 1 new column
    ,TAX_UPFRONT_STY_ID				OKL_SYSTEM_PARAMS.TAX_UPFRONT_STY_ID%TYPE := OKL_API.G_MISS_NUM
    -- PAGARG 24-JAN-05 4044659: Added the new column LEASE_INV_ORG_YN: end
     -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : begin
    ,CATEGORY_SET_ID		    OKL_SYSTEM_PARAMS_ALL.CATEGORY_SET_ID%TYPE := OKL_API.G_MISS_NUM
     -- asawanka 24-MAY-05 : Added the new column CATEGORY_SET_ID for Pricing Enhancements : end
    -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
    ,VALIDATION_SET_ID		    OKL_SYSTEM_PARAMS.VALIDATION_SET_ID%TYPE := OKL_API.G_MISS_NUM
    -- ssdeshpa 2-SEP-05 : Added the new column VALIDATION_SET_ID for Sales Quote Enhancements :
    ,CANCEL_QUOTES_YN               OKL_SYSTEM_PARAMS_ALL.CANCEL_QUOTES_YN%TYPE := OKL_API.G_MISS_CHAR --RMUNJULU 4556370
    ,CHK_ACCRUAL_PREVIOUS_MNTH_YN  OKL_SYSTEM_PARAMS_ALL.CHK_ACCRUAL_PREVIOUS_MNTH_YN%TYPE := OKL_API.G_MISS_CHAR --RMUNJULU 4769094
    -- gboomina 10-Apr-2005 - Added New Columns for Bug 5128517 - start
    ,TASK_TEMPLATE_GROUP_ID OKL_SYSTEM_PARAMS.task_template_group_id%type := OKL_API.G_MISS_NUM
    ,OWNER_TYPE_CODE OKL_SYSTEM_PARAMS.OWNER_TYPE_CODE%type := OKL_API.G_MISS_CHAR
    ,OWNER_ID OKL_SYSTEM_PARAMS.owner_id%type := OKL_API.G_MISS_NUM
    -- gboomina Bug 5128517 - End

    -- DJANASWA Bug 6653304 begin
    ,CORPORATE_BOOK       OKL_SYSTEM_PARAMS_ALL.CORPORATE_BOOK%type := OKL_API.G_MISS_CHAR
    ,TAX_BOOK_1           OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_1%type := OKL_API.G_MISS_CHAR
    ,TAX_BOOK_2           OKL_SYSTEM_PARAMS_ALL.TAX_BOOK_2%type := OKL_API.G_MISS_CHAR
    ,DEPRECIATE_YN        OKL_SYSTEM_PARAMS_ALL.DEPRECIATE_YN%type := OKL_API.G_MISS_CHAR
    ,FA_LOCATION_ID       OKL_SYSTEM_PARAMS_ALL.FA_LOCATION_ID%type := OKL_API.G_MISS_NUM
    ,FORMULA_ID           OKL_SYSTEM_PARAMS_ALL.FORMULA_ID%type := OKL_API.G_MISS_NUM
    ,ASSET_KEY_ID         OKL_SYSTEM_PARAMS_ALL.ASSET_KEY_ID%type := OKL_API.G_MISS_NUM
    -- DJANASWA Bug 6653304 end
    -- Bug 5568328
    ,part_trmnt_apply_round_diff    okl_system_params.part_trmnt_apply_round_diff%type := okl_api.g_miss_char
    ,object_version_number          NUMBER := OKL_API.G_MISS_NUM
    ,org_id                         NUMBER := OKL_API.G_MISS_NUM
    ,request_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_application_id         NUMBER := OKL_API.G_MISS_NUM
    ,program_id                     NUMBER := OKL_API.G_MISS_NUM
    ,program_update_date            OKL_SYSTEM_PARAMS_ALL.PROGRAM_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,attribute_category             OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE_CATEGORY%TYPE := OKL_API.G_MISS_CHAR
    ,attribute1                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR
    ,attribute2                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR
    ,attribute3                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR
    ,attribute4                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR
    ,attribute5                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR
    ,attribute6                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE6%TYPE := OKL_API.G_MISS_CHAR
    ,attribute7                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE7%TYPE := OKL_API.G_MISS_CHAR
    ,attribute8                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE8%TYPE := OKL_API.G_MISS_CHAR
    ,attribute9                     OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE9%TYPE := OKL_API.G_MISS_CHAR
    ,attribute10                    OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE10%TYPE := OKL_API.G_MISS_CHAR
    ,attribute11                    OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE11%TYPE := OKL_API.G_MISS_CHAR
    ,attribute12                    OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE12%TYPE := OKL_API.G_MISS_CHAR
    ,attribute13                    OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE13%TYPE := OKL_API.G_MISS_CHAR
    ,attribute14                    OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE14%TYPE := OKL_API.G_MISS_CHAR
    ,attribute15                    OKL_SYSTEM_PARAMS_ALL.ATTRIBUTE15%TYPE := OKL_API.G_MISS_CHAR
    ,created_by                     NUMBER := OKL_API.G_MISS_NUM
    ,creation_date                  OKL_SYSTEM_PARAMS_ALL.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_updated_by                NUMBER := OKL_API.G_MISS_NUM
    ,last_update_date               OKL_SYSTEM_PARAMS_ALL.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE
    ,last_update_login              NUMBER := OKL_API.G_MISS_NUM
    --added by akrangan on 28/07/2006 since new columns were added to the table as part of moac changes
    ,item_inv_org_id                NUMBER := OKL_API.G_MISS_NUM
    ,rpt_prod_book_type_code	      OKL_SYSTEM_PARAMS_ALL.RPT_PROD_BOOK_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,asst_add_book_type_code	      OKL_SYSTEM_PARAMS_ALL.ASST_ADD_BOOK_TYPE_CODE%TYPE := OKL_API.G_MISS_CHAR
    ,ccard_remittance_id 	        OKL_SYSTEM_PARAMS_ALL.CCARD_REMITTANCE_ID%TYPE := OKL_API.G_MISS_NUM
     --Bug 7022258-Added new columns by kkorrapo
    ,lseapp_seq_prefix_txt          OKL_SYSTEM_PARAMS_ALL.LSEAPP_SEQ_PREFIX_TXT%TYPE := OKL_API.G_MISS_CHAR
    ,lseopp_seq_prefix_txt          OKL_SYSTEM_PARAMS_ALL.LSEOPP_SEQ_PREFIX_TXT%TYPE := OKL_API.G_MISS_CHAR
    ,qckqte_seq_prefix_txt          OKL_SYSTEM_PARAMS_ALL.QCKQTE_SEQ_PREFIX_TXT%TYPE := OKL_API.G_MISS_CHAR
    ,lseqte_seq_prefix_txt          OKL_SYSTEM_PARAMS_ALL.LSEQTE_SEQ_PREFIX_TXT%TYPE := OKL_API.G_MISS_CHAR
    --Bug 7022258-Addition end
    );
  G_MISS_syp_rec                          syp_rec_type;
  TYPE syp_tbl_type IS TABLE OF syp_rec_type
        INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                      CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC   CONSTANT VARCHAR2(200) := OKL_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED          CONSTANT VARCHAR2(200) := OKL_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED     CONSTANT VARCHAR2(200) := OKL_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE               CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN               CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN            CONSTANT VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'ERROR_CODE';
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
  -- SECHAWLA Added
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SYP_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_APP_NAME_1                   CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE qc;
  PROCEDURE change_version;
  PROCEDURE api_copy;
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type,
    x_sypv_rec                     OUT NOCOPY sypv_rec_type);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    x_sypv_tbl                     OUT NOCOPY sypv_tbl_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_rec                     IN sypv_rec_type);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE);
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sypv_tbl                     IN sypv_tbl_type);
END OKL_SYP_PVT;

/
