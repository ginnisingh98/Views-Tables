--------------------------------------------------------
--  DDL for Package OKL_TCN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TCN_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSTCNS.pls 120.10.12010000.4 2008/10/24 08:26:51 sosharma ship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  TYPE tcn_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    khr_id_new                     NUMBER := Okc_Api.G_MISS_NUM,
    pvn_id                         NUMBER := Okc_Api.G_MISS_NUM,
    pdt_id                         NUMBER := Okc_Api.G_MISS_NUM,
    rbr_code                       OKL_TRX_CONTRACTS.RBR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    rpy_code                       OKL_TRX_CONTRACTS.RPY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    rvn_code                       OKL_TRX_CONTRACTS.RVN_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    trn_code                       OKL_TRX_CONTRACTS.TRN_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    qte_id                         NUMBER := Okc_Api.G_MISS_NUM,
    aes_id                         NUMBER := Okc_Api.G_MISS_NUM,
    code_combination_id            NUMBER := Okc_Api.G_MISS_NUM,
    tcn_type                       OKL_TRX_CONTRACTS.TCN_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
    rjn_code                       OKL_TRX_CONTRACTS.RJN_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    party_rel_id1_old              NUMBER := Okc_Api.G_MISS_NUM,
    party_rel_id2_old              OKL_TRX_CONTRACTS.party_rel_id2_old%TYPE := Okc_Api.G_MISS_CHAR,
    party_rel_id1_new              NUMBER := Okc_Api.G_MISS_NUM,
    party_rel_id2_new              OKL_TRX_CONTRACTS.party_rel_id2_new%TYPE := Okc_Api.G_MISS_CHAR,
    complete_transfer_yn           OKL_TRX_CONTRACTS.complete_transfer_yn%TYPE := Okc_Api.G_MISS_CHAR,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_CONTRACTS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_CONTRACTS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    date_accrual                   OKL_TRX_CONTRACTS.DATE_ACCRUAL%TYPE := Okc_Api.G_MISS_DATE,
    accrual_status_yn              OKL_TRX_CONTRACTS.ACCRUAL_STATUS_YN%TYPE := Okc_Api.G_MISS_CHAR,
    update_status_yn               OKL_TRX_CONTRACTS.UPDATE_STATUS_YN%TYPE := Okc_Api.G_MISS_CHAR,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    khr_id                         NUMBER := Okc_Api.G_MISS_NUM,
    tax_deductible_local           OKL_TRX_CONTRACTS.TAX_DEDUCTIBLE_LOCAL%TYPE
                                     := Okc_Api.G_MISS_CHAR,
    tax_deductible_corporate       OKL_TRX_CONTRACTS.tax_deductible_corporate%TYPE
                                     := Okc_Api.G_MISS_CHAR,
    amount                         NUMBER := Okc_Api.G_MISS_NUM,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    currency_code                  OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    khr_id_old                     NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_TRX_CONTRACTS.PROGRAM_update_DATE%TYPE
                                     := Okc_Api.G_MISS_DATE,
    attribute_category             OKL_TRX_CONTRACTS.ATTRIBUTE_CATEGORY%TYPE := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_CONTRACTS.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_CONTRACTS.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_CONTRACTS.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_CONTRACTS.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_CONTRACTS.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_CONTRACTS.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_CONTRACTS.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_CONTRACTS.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_CONTRACTS.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_CONTRACTS.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_CONTRACTS.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_CONTRACTS.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_CONTRACTS.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_CONTRACTS.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_CONTRACTS.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    try_id			   NUMBER := Okc_Api.G_MISS_NUM,
    tsu_code			   OKL_TRX_CONTRACTS.TSU_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    set_of_books_id		   NUMBER := Okc_Api.G_MISS_NUM,
    description		           OKL_TRX_CONTRACTS.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    date_transaction_occurred      OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE
                                        := Okc_Api.G_MISS_DATE,
    trx_number                     OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_evergreen_yn               OKL_TRX_CONTRACTS.TMT_EVERGREEN_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_close_balances_yn          OKL_TRX_CONTRACTS.TMT_CLOSE_BALANCES_YN%TYPE
                                        := Okc_Api.G_MISS_CHAR,
    tmt_accounting_entries_yn      OKL_TRX_CONTRACTS.TMT_ACCOUNTING_ENTRIES_YN%TYPE
                                        := Okc_Api.G_MISS_CHAR,
    tmt_cancel_insurance_yn        OKL_TRX_CONTRACTS.TMT_CANCEL_INSURANCE_YN%TYPE
                                        := Okc_Api.G_MISS_CHAR,
    tmt_asset_disposition_yn       OKL_TRX_CONTRACTS.TMT_ASSET_DISPOSITION_YN%TYPE
                                        := Okc_Api.G_MISS_CHAR,
    tmt_amortization_yn       OKL_TRX_CONTRACTS.TMT_AMORTIZATION_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_asset_return_yn       OKL_TRX_CONTRACTS.TMT_ASSET_RETURN_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_contract_updated_yn   OKL_TRX_CONTRACTS.TMT_CONTRACT_UPDATED_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_recycle_yn            OKL_TRX_CONTRACTS.TMT_RECYCLE_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_validated_yn          OKL_TRX_CONTRACTS.TMT_VALIDATED_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_streams_updated_yn    OKL_TRX_CONTRACTS.TMT_STREAMS_UPDATED_YN%TYPE := Okc_Api.G_MISS_CHAR,
    accrual_activity	      OKL_TRX_CONTRACTS.accrual_activity%TYPE := okc_api.g_miss_char   ,

-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517

    tmt_split_asset_yn    OKL_TRX_CONTRACTS.tmt_split_asset_yn%TYPE := okc_api.g_miss_char   ,
    tmt_generic_flag1_yn  OKL_TRX_CONTRACTS.tmt_generic_flag1_yn%TYPE := okc_api.g_miss_char  ,
    tmt_generic_flag2_yn  OKL_TRX_CONTRACTS.tmt_generic_flag2_yn%TYPE := okc_api.g_miss_char ,
    tmt_generic_flag3_yn  OKL_TRX_CONTRACTS.tmt_generic_flag3_yn%TYPE := okc_api.g_miss_char ,

-- Added by HKPATEL 14-NOV-2002. Multi-Currency Changes

	currency_conversion_type     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE := okc_api.g_miss_char   ,
	currency_conversion_rate     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE := okc_api.g_miss_num   ,
	currency_conversion_date     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE := okc_api.g_miss_date ,

-- Added by Keerthi
     chr_id                 NUMBER := Okc_Api.G_MISS_NUM ,

-- Added by Keerthi
     source_trx_id          NUMBER := Okc_Api.G_MISS_NUM ,
     source_trx_type        OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE :=  okc_api.g_miss_char,

-- Added by kmotepal
     canceled_date          OKL_TRX_CONTRACTS.CANCELED_DATE%TYPE := okc_api.g_miss_date,
--Added by dpsingh for LE Uptake
     legal_entity_id                           NUMBER := Okl_Api.G_MISS_NUM,
--Added by dpsingh for SLA Uptake (Bug 5707866)
     accrual_reversal_date              OKL_TRX_CONTRACTS.ACCRUAL_REVERSAL_DATE%TYPE  := Okl_Api.G_MISS_DATE,
-- Added by DJANASWA for SLA project
     accounting_reversal_yn    OKL_TRX_CONTRACTS.ACCOUNTING_REVERSAL_YN%TYPE := Okc_Api.G_MISS_CHAR,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
     product_name     OKL_TRX_CONTRACTS.product_name%TYPE  := Okc_Api.G_MISS_CHAR,
     book_classification_code  OKL_TRX_CONTRACTS.BOOK_CLASSIFICATION_CODE%TYPE := Okc_Api.G_MISS_CHAR,
     tax_owner_code            OKL_TRX_CONTRACTS.TAX_OWNER_CODE%TYPE := Okc_Api.G_MISS_CHAR,
     tmt_status_code           OKL_TRX_CONTRACTS.TMT_STATUS_CODE%TYPE := Okc_Api.G_MISS_CHAR,
     representation_name       OKL_TRX_CONTRACTS.REPRESENTATION_NAME%TYPE := Okc_Api.G_MISS_CHAR,
     representation_code       OKL_TRX_CONTRACTS.REPRESENTATION_CODE%TYPE := Okc_Api.G_MISS_CHAR,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
     UPGRADE_STATUS_FLAG               OKL_TRX_CONTRACTS.UPGRADE_STATUS_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
     TRANSACTION_DATE	 OKL_TRX_CONTRACTS.TRANSACTION_DATE%TYPE	:= Okl_Api.G_MISS_DATE,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
     primary_rep_trx_id          OKL_TRX_CONTRACTS.primary_rep_trx_id%TYPE := Okc_Api.G_MISS_NUM,
     REPRESENTATION_TYPE          OKL_TRX_CONTRACTS.REPRESENTATION_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
 -- sosharma added column for Income accrual recon-report
     TRANSACTION_REVERSAL_DATE    OKL_TRX_CONTRACTS.TRANSACTION_REVERSAL_DATE%TYPE := Okl_Api.G_MISS_DATE
);


  g_miss_tcn_rec                          tcn_rec_type;
  TYPE tcn_tbl_type IS TABLE OF tcn_rec_type
        INDEX BY BINARY_INTEGER;
  TYPE tcnv_rec_type IS RECORD (
    id                             NUMBER := Okc_Api.G_MISS_NUM,
    object_version_number          NUMBER := Okc_Api.G_MISS_NUM,
    rbr_code                       OKL_TRX_CONTRACTS.RBR_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    rpy_code                       OKL_TRX_CONTRACTS.RPY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    rvn_code                       OKL_TRX_CONTRACTS.RVN_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    trn_code                       OKL_TRX_CONTRACTS.TRN_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    khr_id_new                     NUMBER := Okc_Api.G_MISS_NUM,
    pvn_id                         NUMBER := Okc_Api.G_MISS_NUM,
    pdt_id                         NUMBER := Okc_Api.G_MISS_NUM,
    qte_id                         NUMBER := Okc_Api.G_MISS_NUM,
    aes_id                         NUMBER := Okc_Api.G_MISS_NUM,
    code_combination_id            NUMBER := Okc_Api.G_MISS_NUM,
    tax_deductible_local           OKL_TRX_CONTRACTS.TAX_DEDUCTIBLE_LOCAL%TYPE
                                      := Okc_Api.G_MISS_CHAR,
    tax_deductible_corporate       OKL_TRX_CONTRACTS.tax_deductible_corporate%TYPE
                                      := Okc_Api.G_MISS_CHAR,
    date_accrual                   OKL_TRX_CONTRACTS.DATE_ACCRUAL%TYPE := Okc_Api.G_MISS_DATE,
    accrual_status_yn              OKL_TRX_CONTRACTS.ACCRUAL_STATUS_YN%TYPE
                                      := Okc_Api.G_MISS_CHAR,
    update_status_yn               OKL_TRX_CONTRACTS.UPDATE_STATUS_YN%TYPE := Okc_Api.G_MISS_CHAR,
    amount                         NUMBER := Okc_Api.G_MISS_NUM,
    currency_code                  OKL_TRX_CONTRACTS.CURRENCY_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    attribute_category             OKL_TRX_CONTRACTS.ATTRIBUTE_CATEGORY%TYPE
                                           := Okc_Api.G_MISS_CHAR,
    attribute1                     OKL_TRX_CONTRACTS.ATTRIBUTE1%TYPE := Okc_Api.G_MISS_CHAR,
    attribute2                     OKL_TRX_CONTRACTS.ATTRIBUTE2%TYPE := Okc_Api.G_MISS_CHAR,
    attribute3                     OKL_TRX_CONTRACTS.ATTRIBUTE3%TYPE := Okc_Api.G_MISS_CHAR,
    attribute4                     OKL_TRX_CONTRACTS.ATTRIBUTE4%TYPE := Okc_Api.G_MISS_CHAR,
    attribute5                     OKL_TRX_CONTRACTS.ATTRIBUTE5%TYPE := Okc_Api.G_MISS_CHAR,
    attribute6                     OKL_TRX_CONTRACTS.ATTRIBUTE6%TYPE := Okc_Api.G_MISS_CHAR,
    attribute7                     OKL_TRX_CONTRACTS.ATTRIBUTE7%TYPE := Okc_Api.G_MISS_CHAR,
    attribute8                     OKL_TRX_CONTRACTS.ATTRIBUTE8%TYPE := Okc_Api.G_MISS_CHAR,
    attribute9                     OKL_TRX_CONTRACTS.ATTRIBUTE9%TYPE := Okc_Api.G_MISS_CHAR,
    attribute10                    OKL_TRX_CONTRACTS.ATTRIBUTE10%TYPE := Okc_Api.G_MISS_CHAR,
    attribute11                    OKL_TRX_CONTRACTS.ATTRIBUTE11%TYPE := Okc_Api.G_MISS_CHAR,
    attribute12                    OKL_TRX_CONTRACTS.ATTRIBUTE12%TYPE := Okc_Api.G_MISS_CHAR,
    attribute13                    OKL_TRX_CONTRACTS.ATTRIBUTE13%TYPE := Okc_Api.G_MISS_CHAR,
    attribute14                    OKL_TRX_CONTRACTS.ATTRIBUTE14%TYPE := Okc_Api.G_MISS_CHAR,
    attribute15                    OKL_TRX_CONTRACTS.ATTRIBUTE15%TYPE := Okc_Api.G_MISS_CHAR,
    tcn_type                       OKL_TRX_CONTRACTS.TCN_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
    rjn_code                       OKL_TRX_CONTRACTS.RJN_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    party_rel_id1_old              NUMBER := Okc_Api.G_MISS_NUM,
    party_rel_id2_old              OKL_TRX_CONTRACTS.party_rel_id2_old%TYPE := Okc_Api.G_MISS_CHAR,
    party_rel_id1_new              NUMBER := Okc_Api.G_MISS_NUM,
    party_rel_id2_new              OKL_TRX_CONTRACTS.party_rel_id2_new%TYPE := Okc_Api.G_MISS_CHAR,
    complete_transfer_yn           OKL_TRX_CONTRACTS.complete_transfer_yn%TYPE := Okc_Api.G_MISS_CHAR,
    org_id                         NUMBER := Okc_Api.G_MISS_NUM,
    khr_id                         NUMBER := Okc_Api.G_MISS_NUM,
    request_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_application_id         NUMBER := Okc_Api.G_MISS_NUM,
    khr_id_old                     NUMBER := Okc_Api.G_MISS_NUM,
    program_id                     NUMBER := Okc_Api.G_MISS_NUM,
    program_update_date            OKL_TRX_CONTRACTS.PROGRAM_update_DATE%TYPE
                                                 := Okc_Api.G_MISS_DATE,
    created_by                     NUMBER := Okc_Api.G_MISS_NUM,
    creation_date                  OKL_TRX_CONTRACTS.CREATION_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_updated_by                NUMBER := Okc_Api.G_MISS_NUM,
    last_update_date               OKL_TRX_CONTRACTS.LAST_UPDATE_DATE%TYPE := Okc_Api.G_MISS_DATE,
    last_update_login              NUMBER := Okc_Api.G_MISS_NUM,
    try_id			   NUMBER := Okc_Api.G_MISS_NUM,
    tsu_code		           OKL_TRX_CONTRACTS.TSU_CODE%TYPE := Okc_Api.G_MISS_CHAR,
    set_of_books_id		   NUMBER := Okc_Api.G_MISS_NUM,
    description			   OKL_TRX_CONTRACTS.DESCRIPTION%TYPE := Okc_Api.G_MISS_CHAR,
    date_transaction_occurred	   OKL_TRX_CONTRACTS.DATE_TRANSACTION_OCCURRED%TYPE
                                      := Okc_Api.G_MISS_DATE,
    trx_number                     OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_evergreen_yn               OKL_TRX_CONTRACTS.TMT_EVERGREEN_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_close_balances_yn          OKL_TRX_CONTRACTS.TMT_CLOSE_BALANCES_YN%TYPE
                                      := Okc_Api.G_MISS_CHAR,
    tmt_accounting_entries_yn      OKL_TRX_CONTRACTS.TMT_ACCOUNTING_ENTRIES_YN%TYPE
                                           := Okc_Api.G_MISS_CHAR,
    tmt_cancel_insurance_yn        OKL_TRX_CONTRACTS.TMT_CANCEL_INSURANCE_YN%TYPE
                                           := Okc_Api.G_MISS_CHAR,
    tmt_asset_disposition_yn       OKL_TRX_CONTRACTS.TMT_ASSET_DISPOSITION_YN%TYPE
                                           := Okc_Api.G_MISS_CHAR,
    tmt_amortization_yn       OKL_TRX_CONTRACTS.TMT_AMORTIZATION_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_asset_return_yn       OKL_TRX_CONTRACTS.TMT_ASSET_RETURN_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_contract_updated_yn   OKL_TRX_CONTRACTS.TMT_CONTRACT_UPDATED_YN%TYPE
                                           := Okc_Api.G_MISS_CHAR,
    tmt_recycle_yn            OKL_TRX_CONTRACTS.TMT_RECYCLE_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_validated_yn          OKL_TRX_CONTRACTS.TMT_VALIDATED_YN%TYPE := Okc_Api.G_MISS_CHAR,
    tmt_streams_updated_yn    OKL_TRX_CONTRACTS.TMT_STREAMS_UPDATED_YN%TYPE
                                  := Okc_Api.G_MISS_CHAR,
    accrual_activity	      OKL_TRX_CONTRACTS.accrual_activity%TYPE := okc_api.g_miss_char,

-- Added by Santonyr 11-NOV-2002. Fixed bug 2660517

    tmt_split_asset_yn    OKL_TRX_CONTRACTS.tmt_split_asset_yn%TYPE := okc_api.g_miss_char   ,
    tmt_generic_flag1_yn  OKL_TRX_CONTRACTS.tmt_generic_flag1_yn%TYPE := okc_api.g_miss_char  ,
    tmt_generic_flag2_yn  OKL_TRX_CONTRACTS.tmt_generic_flag2_yn%TYPE := okc_api.g_miss_char ,
    tmt_generic_flag3_yn  OKL_TRX_CONTRACTS.tmt_generic_flag3_yn%TYPE := okc_api.g_miss_char ,

-- Added by HKPATEL 14-NOV-2002. Multi-Currency Changes

	currency_conversion_type     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_TYPE%TYPE := okc_api.g_miss_char   ,
	currency_conversion_rate     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_RATE%TYPE := okc_api.g_miss_num   ,
	currency_conversion_date     OKL_TRX_CONTRACTS.CURRENCY_CONVERSION_DATE%TYPE := okc_api.g_miss_date ,

-- Added by Keerthi

        chr_id                 NUMBER := Okc_Api.G_MISS_NUM ,

-- Added by Keerthi
     source_trx_id          NUMBER := Okc_Api.G_MISS_NUM ,
     source_trx_type        OKL_TRX_CONTRACTS.SOURCE_TRX_TYPE%TYPE :=  okc_api.g_miss_char,

-- Added by kmotepal
     canceled_date          OKL_TRX_CONTRACTS.CANCELED_DATE%TYPE := okc_api.g_miss_date,

  --Added by dpsingh for LE Uptake
     legal_entity_id                           NUMBER := Okl_Api.G_MISS_NUM,

     --Added by dpsingh for SLA Uptake (Bug 5707866)
     accrual_reversal_date              OKL_TRX_CONTRACTS.ACCRUAL_REVERSAL_DATE%TYPE := Okl_Api.G_MISS_DATE,

-- Added by DJANASWA for SLA project
     accounting_reversal_yn    OKL_TRX_CONTRACTS.ACCOUNTING_REVERSAL_YN%TYPE := Okc_Api.G_MISS_CHAR,
-- Added by zrehman for SLA project (Bug 5707866) 8-Feb-2007
     product_name     OKL_TRX_CONTRACTS.product_name%TYPE  := Okc_Api.G_MISS_CHAR,
     book_classification_code  OKL_TRX_CONTRACTS.BOOK_CLASSIFICATION_CODE%TYPE := Okc_Api.G_MISS_CHAR,
     tax_owner_code            OKL_TRX_CONTRACTS.TAX_OWNER_CODE%TYPE := Okc_Api.G_MISS_CHAR,
     tmt_status_code           OKL_TRX_CONTRACTS.TMT_STATUS_CODE%TYPE := Okc_Api.G_MISS_CHAR,
     representation_name       OKL_TRX_CONTRACTS.REPRESENTATION_NAME%TYPE := Okc_Api.G_MISS_CHAR,
     representation_code       OKL_TRX_CONTRACTS.REPRESENTATION_CODE%TYPE := Okc_Api.G_MISS_CHAR,
-- Added by nikshah for SLA project (Bug 5707866) 13-Apr-2007
     UPGRADE_STATUS_FLAG               OKL_TRX_CONTRACTS.UPGRADE_STATUS_FLAG%TYPE := Okc_Api.G_MISS_CHAR,
-- Added by dcshanmu for Transaction Date Stamping 02-Nov-2007
     TRANSACTION_DATE	 OKL_TRX_CONTRACTS.TRANSACTION_DATE%TYPE	:= Okl_Api.G_MISS_DATE,
-- Added by smereddy for Multi-GAAP project (Bug 7263041) 04-Aug-2007
     primary_rep_trx_id          OKL_TRX_CONTRACTS.primary_rep_trx_id%TYPE := Okc_Api.G_MISS_NUM,
     REPRESENTATION_TYPE          OKL_TRX_CONTRACTS.REPRESENTATION_TYPE%TYPE := Okc_Api.G_MISS_CHAR,
-- sosharma added column for Income accrual recon-report
     TRANSACTION_REVERSAL_DATE    OKL_TRX_CONTRACTS.TRANSACTION_REVERSAL_DATE%TYPE := Okl_Api.G_MISS_DATE
    );


  g_miss_tcnv_rec                         tcnv_rec_type;
  TYPE tcnv_tbl_type IS TABLE OF tcnv_rec_type
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
  G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'OKL_SQLcode';
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD          CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_NO_PARENT_RECORD';
  G_UPPERCASE_REQUIRED	CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_UNQS	CONSTANT VARCHAR2(200) := 'OKL_UNIQUE_KEY_VALIDATION_FAILED';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_TCN_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
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
    p_tcnv_rec                     IN tcnv_rec_type,
    x_tcnv_rec                     OUT NOCOPY tcnv_rec_type);

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type,
    x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type);

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type,
    x_tcnv_rec                     OUT NOCOPY tcnv_rec_type);

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type,
    x_tcnv_tbl                     OUT NOCOPY tcnv_tbl_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type);

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_rec                     IN tcnv_rec_type);

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tcnv_tbl                     IN tcnv_tbl_type);

END Okl_Tcn_Pvt;

/
