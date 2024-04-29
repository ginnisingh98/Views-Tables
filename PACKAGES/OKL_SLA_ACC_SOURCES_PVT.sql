--------------------------------------------------------
--  DDL for Package OKL_SLA_ACC_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SLA_ACC_SOURCES_PVT" AUTHID CURRENT_USER AS
/*$Header: OKLRSLAS.pls 120.16 2007/12/27 14:26:32 zrehman noship $*/

  ------------------------------------------------------------------------------
  -- Global Variables
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT VARCHAR2(200) := 'OKL_SLA_ACC_SOURCES_PVT ';
  G_APP_NAME                   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLERRM';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLCODE';
  G_COMMIT_AFTER_RECORDS       CONSTANT NUMBER := 500;
  G_COMMIT_COUNT               NUMBER := 0;
  G_REQUIRED_VALUE	           CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN	           CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_INVALID_VALUE		       CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;

  -- Constants declared for the source tables
  G_TRX_CONTRACTS              CONSTANT VARCHAR2(30) := 'OKL_TRX_CONTRACTS';
  G_TXL_CONTRACTS              CONSTANT VARCHAR2(30) := 'OKL_TXL_CNTRCT_LNS';
  G_TRX_ASSETS                 CONSTANT VARCHAR2(30) := 'OKL_TRX_ASSETS';
  G_TXL_ASSETS                 CONSTANT VARCHAR2(30) := 'OKL_TXL_ASSETS_B';
  G_TXD_ASSETS                 CONSTANT VARCHAR2(30) := 'OKL_TXD_ASSETS_B';
  G_TRX_AR_INVOICES_B          CONSTANT VARCHAR2(30) := 'OKL_TRX_AR_INVOICES_B';
  G_TRX_AR_ADJSTS_B            CONSTANT VARCHAR2(30) := 'OKL_TRX_AR_ADJSTS_B';
  G_TXD_AR_LN_DTLS_B           CONSTANT VARCHAR2(30) := 'OKL_TXD_AR_LN_DTLS_B';
  G_TXL_ADJSTS_LNS_B           CONSTANT VARCHAR2(30) := 'OKL_TXL_ADJSTS_LNS_B';
  G_TRX_AP_INVOICES_B          CONSTANT VARCHAR2(30) := 'OKL_TRX_AP_INVOICES_B';
  G_TXL_AP_INV_LNS_B           CONSTANT VARCHAR2(30) := 'OKL_TXL_AP_INV_LNS_B';
  G_FA_DEPRN_SUMMARY           CONSTANT VARCHAR2(30) := 'FA_DEPRN_SUMMARY';
  G_AR_CASH_RECEIPTS           CONSTANT VARCHAR2(30) := 'AR_CASH_RECEIPTS';
  -- Constants declared for the Event classes
  G_BOOKING                    CONSTANT VARCHAR2(50) := 'BOOKING';
  G_REBOOK                     CONSTANT VARCHAR2(50) := 'REBOOK';
  G_RE_LEASE                   CONSTANT VARCHAR2(50) := 'RE_LEASE';
  G_GLP                        CONSTANT VARCHAR2(50) := 'GENERAL_LOSS_PROVISION';
  G_SLP                        CONSTANT VARCHAR2(50) := 'SPECIFIC_LOSS_PROVISION';
  G_TERMINATION                CONSTANT VARCHAR2(50) := 'TERMINATION';
  G_EVERGREEN                  CONSTANT VARCHAR2(50) := 'EVERGREEN';
  G_ACCRUAL                    CONSTANT VARCHAR2(50) := 'ACCRUAL';
  G_RECEIPT_APPLICATION        CONSTANT VARCHAR2(50) := 'RECEIPT_APPLICATION';
  G_PRINCIPAL_ADJUSTMENT       CONSTANT VARCHAR2(50) := 'PRINCIPAL_ADJUSTMENT';
  G_ASSET_DISPOSITION          CONSTANT VARCHAR2(50) := 'ASSET_DISPOSITION';
  G_SPLIT_ASSET                CONSTANT VARCHAR2(50) := 'SPLIT_ASSET';
  G_MISCELLANEOUS              CONSTANT VARCHAR2(50) := 'MISCELLANEOUS';
  G_UPFRONT_TAX                CONSTANT VARCHAR2(50) := 'UPFRONT_TAX';
  -- Constants declared for the Lease or Investor Type
  G_LEASE                      CONSTANT VARCHAR2(50) := 'LEASE';
  G_INVESTOR                   CONSTANT VARCHAR2(50) := 'INVESTOR';
  -- Constants for the Profile Name Declarations
  G_OKL_DEPRN_WORKERS          CONSTANT VARCHAR2(30) := 'OKL_DEPRN_WORKERS';
  G_LIMIT_SIZE                 CONSTANT NUMBER       := 10000;
  -- Global Constants for the Error Message Names
  G_OKL_DEPRN_WORKER_ERROR     CONSTANT VARCHAR2(30) := 'OKL_DEPRN_WORKER_ERROR';
  G_OBJECT_TYPE_DEP_KHR        CONSTANT VARCHAR2(30) := 'DEPRECIATION_CONTRACT';
  ------------------------------------------------------------------------------
  -- Record Type
  ------------------------------------------------------------------------------
  TYPE account_dist_rec_type IS RECORD (
         id                    okl_trns_acc_dstrs.id%TYPE
        ,template_id           okl_trns_acc_dstrs.template_id%TYPE
  );
  TYPE account_dist_tbl_type IS TABLE OF account_dist_rec_type
    INDEX BY BINARY_INTEGER;

  -- Start : PRASJAIN : Bug# 6268782
  SUBTYPE tel_tbl_tbl_type IS okl_tel_pvt.tel_tbl_tbl_type;
  SUBTYPE fxl_tbl_tbl_type IS okl_fxl_pvt.fxl_tbl_tbl_type;

  TYPE led_lang_rec_type IS RECORD(
         language           VARCHAR2(12)
        ,contract_status    VARCHAR2(90)
        ,inv_agrmnt_status  VARCHAR2(90)
  );

  TYPE led_lang_tbl_type IS TABLE OF led_lang_rec_type
    INDEX BY BINARY_INTEGER;
  -- End : PRASJAIN : Bug# 6268782

  -- Subtyping the record structures
  SUBTYPE tehv_rec_type IS okl_teh_pvt.tehv_rec_type;
  SUBTYPE tehv_tbl_type IS okl_teh_pvt.tehv_tbl_type;

  SUBTYPE telv_rec_type IS okl_tel_pvt.telv_rec_type;
  SUBTYPE telv_tbl_type IS okl_tel_pvt.telv_tbl_type;

  SUBTYPE fxhv_rec_type IS okl_fxh_pvt.fxhv_rec_type;
  SUBTYPE fxhv_tbl_type IS okl_fxh_pvt.fxhv_tbl_type;

  SUBTYPE fxlv_rec_type IS okl_fxl_pvt.fxlv_rec_type;
  SUBTYPE fxlv_tbl_type IS okl_fxl_pvt.fxlv_tbl_type;

  SUBTYPE asev_rec_type IS okl_acct_sources_pvt.asev_rec_type;
  SUBTYPE asev_tbl_type IS okl_acct_sources_pvt.asev_tbl_type;

  SUBTYPE rxhv_rec_type IS okl_rxh_pvt.rxhv_rec_type;
  SUBTYPE rxhv_tbl_type IS okl_rxh_pvt.rxhv_tbl_type;

  SUBTYPE rxlv_rec_type IS okl_rxl_pvt.rxlv_rec_type;
  SUBTYPE rxlv_tbl_type IS okl_rxl_pvt.rxlv_tbl_type;

  SUBTYPE pxhv_rec_type IS okl_pxh_pvt.pxhv_rec_type;
  SUBTYPE pxhv_tbl_type IS okl_pxh_pvt.pxhv_tbl_type;

  SUBTYPE pxlv_rec_type IS okl_pxl_pvt.pxlv_rec_type;
  SUBTYPE pxlv_tbl_type IS okl_pxl_pvt.pxlv_tbl_type;

  -- Start : PRASJAIN : Bug# 6268782
  SUBTYPE teh_rec_type  IS okl_teh_pvt.teh_rec_type;
  SUBTYPE tehl_tbl_type IS okl_teh_pvt.tehl_tbl_type;

  SUBTYPE tel_rec_type  IS okl_tel_pvt.tel_rec_type;
  SUBTYPE tel_tbl_type  IS okl_tel_pvt.tel_tbl_type;
  SUBTYPE tell_tbl_type IS okl_tel_pvt.tell_tbl_type;

  SUBTYPE fxh_rec_type  IS okl_fxh_pvt.fxh_rec_type;
  SUBTYPE fxhl_tbl_type IS okl_fxh_pvt.fxhl_tbl_type;

  SUBTYPE fxl_rec_type  IS okl_fxl_pvt.fxl_rec_type;
  SUBTYPE fxll_tbl_type IS okl_fxl_pvt.fxll_tbl_type;

  SUBTYPE rxh_rec_type  IS okl_rxh_pvt.rxh_rec_type;
  SUBTYPE rxhl_tbl_type IS okl_rxh_pvt.rxhl_tbl_type;

  SUBTYPE rxl_rec_type  IS okl_rxl_pvt.rxl_rec_type;
  SUBTYPE rxll_tbl_type IS okl_rxl_pvt.rxll_tbl_type;

  SUBTYPE pxh_rec_type  IS okl_pxh_pvt.pxh_rec_type;
  SUBTYPE pxhl_tbl_type IS okl_pxh_pvt.pxhl_tbl_type;

  SUBTYPE pxl_rec_type  IS okl_pxl_pvt.pxl_rec_type;
  SUBTYPE pxll_tbl_type IS okl_pxl_pvt.pxll_tbl_type;
  -- End : PRASJAIN : Bug# 6268782

  -------------------------------------------------------------------------------
  -- Generic record structure to hold khr header sources for FA/AR/AP transaction
  -------------------------------------------------------------------------------
  TYPE khr_source_rec_type IS RECORD (
       khr_id                                     NUMBER
      ,contract_number                            VARCHAR2(120)
      ,contract_status                            VARCHAR2(90)
      ,contract_currency_code                     VARCHAR2(80)
      ,contract_effective_from                    DATE
      ,customer_name                              VARCHAR2(360)
      ,customer_account_number                    VARCHAR2(30)
      ,product_name                                VARCHAR2(150)
      ,book_classification_code                    VARCHAR2(30)
      ,tax_owner_code                              VARCHAR2(150)
      ,rev_rec_method_code                        VARCHAR2(150)
      ,int_calc_method_code                       VARCHAR2(150)
      ,vendor_program_number                      VARCHAR2(120)
      ,po_order_number                            VARCHAR2(150)
      ,converted_number                           VARCHAR2(30)
      ,converted_account_flag                     VARCHAR2(3)
      ,assignable_flag                            VARCHAR2(3)
      ,accrual_override_flag                      VARCHAR2(3)
      ,rent_ia_contract_number                    VARCHAR2(120)
      ,rent_ia_product_name                       VARCHAR2(150)
      ,rent_ia_accounting_code                    VARCHAR2(450)
      ,res_ia_contract_number                     VARCHAR2(120)
      ,res_ia_product_name                        VARCHAR2(150)
      ,res_ia_accounting_code                     VARCHAR2(450)
      ,khr_attribute_category                     VARCHAR2(90)
      ,khr_attribute1                             VARCHAR2(450)
      ,khr_attribute2                             VARCHAR2(450)
      ,khr_attribute3                             VARCHAR2(450)
      ,khr_attribute4                             VARCHAR2(450)
      ,khr_attribute5                             VARCHAR2(450)
      ,khr_attribute6                             VARCHAR2(450)
      ,khr_attribute7                             VARCHAR2(450)
      ,khr_attribute8                             VARCHAR2(450)
      ,khr_attribute9                             VARCHAR2(450)
      ,khr_attribute10                            VARCHAR2(450)
      ,khr_attribute11                            VARCHAR2(450)
      ,khr_attribute12                            VARCHAR2(450)
      ,khr_attribute13                            VARCHAR2(450)
      ,khr_attribute14                            VARCHAR2(450)
      ,khr_attribute15                            VARCHAR2(450)
      ,cust_attribute_category                    VARCHAR2(90)
      ,cust_attribute1                            VARCHAR2(450)
      ,cust_attribute2                            VARCHAR2(450)
      ,cust_attribute3                            VARCHAR2(450)
      ,cust_attribute4                            VARCHAR2(450)
      ,cust_attribute5                            VARCHAR2(450)
      ,cust_attribute6                            VARCHAR2(450)
      ,cust_attribute7                            VARCHAR2(450)
      ,cust_attribute8                            VARCHAR2(450)
      ,cust_attribute9                            VARCHAR2(450)
      ,cust_attribute10                           VARCHAR2(450)
      ,cust_attribute11                           VARCHAR2(450)
      ,cust_attribute12                           VARCHAR2(450)
      ,cust_attribute13                           VARCHAR2(450)
      ,cust_attribute14                           VARCHAR2(450)
      ,cust_attribute15                           VARCHAR2(450)
      ,contract_status_code                       VARCHAR2(90)
      ,scs_code                                   VARCHAR2(30)
      ,inv_agrmnt_number                          VARCHAR2(120)
      ,inv_agrmnt_effective_from                  DATE
      ,inv_agrmnt_product_name                    VARCHAR2(150)
      ,inv_agrmnt_currency_code                   VARCHAR2(80)
      ,inv_agrmnt_synd_code                       VARCHAR2(30)
      ,inv_agrmnt_pool_number                     VARCHAR2(120)
      ,inv_agrmnt_status_code                     VARCHAR2(30)
      ,inv_agrmnt_status                          VARCHAR2(90)
-- added by zrehman Bug#6707320 for Party Merge impact on Accounting sources tables
      ,customer_id                                NUMBER
      ,cust_account_id                            NUMBER
  );
  -----------------------------------------------------------------------------------
  -- Generic record structure to hold khr / kle line sources for FA/AR/AP transaction
  -----------------------------------------------------------------------------------
  TYPE kle_source_rec_type IS RECORD (
      khr_id                                      NUMBER
     ,kle_id                                      NUMBER
     ,contract_line_number                        VARCHAR2(150)
     ,asset_number                                VARCHAR2(150)
     ,asset_vendor_name                           VARCHAR2(240)
     ,installed_site_id                           VARCHAR2(100)
     ,fixed_asset_location_name                   VARCHAR2(250)
     ,line_type_code                              VARCHAR2(30)
     ,line_attribute_category                     VARCHAR2(90)
     ,line_attribute1                             VARCHAR2(450)
     ,line_attribute2                             VARCHAR2(450)
     ,line_attribute3                             VARCHAR2(450)
     ,line_attribute4                             VARCHAR2(450)
     ,line_attribute5                             VARCHAR2(450)
     ,line_attribute6                             VARCHAR2(450)
     ,line_attribute7                             VARCHAR2(450)
     ,line_attribute8                             VARCHAR2(450)
     ,line_attribute9                             VARCHAR2(450)
     ,line_attribute10                            VARCHAR2(450)
     ,line_attribute11                            VARCHAR2(450)
     ,line_attribute12                            VARCHAR2(450)
     ,line_attribute13                            VARCHAR2(450)
     ,line_attribute14                            VARCHAR2(450)
     ,line_attribute15                            VARCHAR2(450)
-- added by zrehman for Bug#6707320 Party Merge impact on Accounting sources tables
     ,asset_vendor_id                             NUMBER
  );
  -- PL/SQL TYPE Declarations
  TYPE deprn_asset_rec_type IS RECORD (
     kle_id     NUMBER,  -- Id of Line Style FREE_FORM1
     asset_id   NUMBER   -- Id of Line Style FIXED_ASSET
  );

  TYPE deprn_asset_tbl_type  IS TABLE OF deprn_asset_rec_type
   INDEX BY BINARY_INTEGER;

  -- Type Declarations
  TYPE worker_load_rec IS RECORD (
          worker_number    NUMBER
	       ,worker_load      NUMBER
	       ,used             BOOLEAN
  );
  TYPE worker_load_tab IS TABLE OF worker_load_rec
    INDEX BY BINARY_INTEGER;
  ---------------------------------------------------------------------------
   -- Procedures AND Functions
   ---------------------------------------------------------------------------
  PROCEDURE populate_tcn_sources(
    p_api_version                IN             NUMBER
   ,p_init_msg_list              IN             VARCHAR2
   ,px_trans_hdr_rec             IN OUT NOCOPY  tehv_rec_type
   ,p_acc_sources_rec            IN             asev_rec_type
   ,x_return_status              OUT    NOCOPY  VARCHAR2
   ,x_msg_count                  OUT    NOCOPY  NUMBER
   ,x_msg_data                   OUT    NOCOPY  VARCHAR2
  );
  -- API Accepting a Single Record
  -- This API will be called by the Accounting Engine Old Signatures
  PROCEDURE populate_tcl_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,px_trans_line_rec           IN OUT NOCOPY  telv_rec_type
   ,p_acc_sources_rec           IN             asev_rec_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

  -- This API captures the Sources at the Extension Line Level
  --  and uses the Bulk Insert feature to store them.
  -- This API will be called by Populate Sources API which is called by
  -- the new Accounting Engine Signature.
  PROCEDURE populate_tcl_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_trans_hdr_rec             IN             tehv_rec_type
   ,p_acc_sources_tbl           IN             asev_tbl_type
   ,p_trans_line_tbl            IN             telv_tbl_type  -- Added by PRASJAIN Bug#6134235
   ,x_trans_line_tbl            OUT    NOCOPY  telv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

  ---------------------------------------------------------------------------
  -- Start of comments
  -- API name    : populate_sources
  -- Pre-reqs    : None
  -- Function    : Use this API to populate sources at the Transaction Header
  --                level and at the Transaction Line level too.
  -- Parameters  :
  -- IN          : p_trans_hdr_rec.source_id  IN NUMBER  Required
  --                  Pass Transaction Header id.
  --               p_trans_hdr_rec.source_table IN VARCHAR2 Required
  --                 Pass the table name of the Transaction Header.
  --                 Eg. OKL_TRX_CONTRACTS, OKL_TRX_ASSETS
  --               p_trans_line_tbl  trans_line_tbl_type Required.
  --                 p_trans_line_tbl(i).source_id IN NUMBER Required
  --                   Pass the Transaction Line id
  --                 p_trans_line_tbl(i).source_table VARCHAR2(30) Required
  --                   Pass the table name of the Transaction Table.
  --                   Eg. OKL_TXL_CNTRCT_LNS, OKL_TXL_ASSET_LINES ..
  -- Version     : 1.0
  -- History     : Ravindranath Gooty created
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_trans_hdr_rec             IN             tehv_rec_type
   ,p_trans_line_tbl            IN             telv_tbl_type
   ,p_acc_sources_tbl           IN             asev_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL FA Transactions
  --      Parameters      :
  --      IN              :
  --                        fxhv_rec_type.source_id            IN NUMBER    Required
  --                        fxhv_rec_type.source_table         IN VARCHAR2  Required
  --                        fxhv_rec_type.khr_id               IN NUMBER    Required
  --                        fxhv_rec_type.try_id               IN NUMBER    Required
  --                        fxlv_rec_type.source_id            IN NUMBER    Required
  --                        fxlv_rec_type.source_table         IN VARCHAR2  Required
  --                        fxlv_rec_type.kle_id               IN NUMBER    Required
  --                        fxlv_rec_type.asset_id             IN NUMBER    Required
  --                        fxlv_rec_type.fa_transaction_id    IN NUMBER    Required
  --                        fxlv_rec_type.asset_book_type_name IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_fxhv_rec                  IN             fxhv_rec_type
   ,p_fxlv_rec                  IN             fxlv_rec_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_ar_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AR Transactions
  --      Parameters      :
  --      IN              : rxhv_rec_type.source_id            IN NUMBER    Required
  --                        rxhv_rec_type.source_table         IN VARCHAR2  Required

  --                        rxhv_rec_type.khr_id               IN NUMBER    Required
  --                        rxhv_rec_type.try_id               IN NUMBER    Required
  --                        rxlv_rec_type.kle_id               IN NUMBER    Not Mandatory
  --                        rxlv_rec_type.sty_id               IN NUMBER    Required
  --                        rxlv_rec_type.source_id            IN NUMBER    Required
  --                        rxlv_rec_type.source_table         IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_ar_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_rxhv_rec              IN        rxhv_rec_type
   ,p_rxlv_rec              IN        rxlv_rec_type
   ,p_acc_sources_rec       IN        asev_rec_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_ap_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              : pxhv_rec_type.source_id            IN NUMBER    Required
  --                        pxhv_rec_type.source_table         IN VARCHAR2  Required

  --                        pxhv_rec_type.khr_id               IN NUMBER    Required
  --                        pxhv_rec_type.try_id               IN NUMBER    Required
  --                        pxlv_rec_type.kle_id               IN NUMBER    Not Mandatory
  --                        pxlv_rec_type.sty_id               IN NUMBER    Required
  --                        pxlv_rec_type.source_id            IN NUMBER    Required
  --                        pxlv_rec_type.source_table         IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_ap_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_pxhv_rec              IN        pxhv_rec_type
   ,p_pxlv_rec              IN        pxlv_rec_type
   ,p_acc_sources_rec       IN        asev_rec_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AR Transactions
  --      Parameters      :
  --      IN              :
  --                        rxhv_rec_type.source_id            IN NUMBER    Required
  --                        rxhv_rec_type.source_table         IN VARCHAR2  Required
  --                        rxlv_tbl_type.source_id            IN NUMBER    Required
  --                        rxlv_tbl_type.source_table         IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_rxhv_rec              IN        rxhv_rec_type
   ,p_rxlv_tbl              IN        rxlv_tbl_type
   ,p_acc_sources_tbl       IN        asev_tbl_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              :
  --                        pxhv_rec_type.source_id            IN NUMBER    Required
  --                        pxhv_rec_type.source_table         IN VARCHAR2  Required
  --      History         : Prashant Jain created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version           IN        NUMBER
   ,p_init_msg_list         IN        VARCHAR2
   ,p_pxhv_rec              IN        pxhv_rec_type
   ,p_pxlv_tbl              IN        pxlv_tbl_type
   ,p_acc_sources_tbl       IN        asev_tbl_type
   ,x_return_status         OUT       NOCOPY  VARCHAR2
   ,x_msg_count             OUT       NOCOPY  NUMBER
   ,x_msg_data              OUT       NOCOPY  VARCHAR2
  );

  PROCEDURE delete_trx_extension(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_trans_hdr_rec             IN             tehv_rec_type
   ,x_trans_line_tbl            OUT    NOCOPY  telv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : delete_fa_extension
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL FA Transactions
  --      Parameters      :
  --      IN              :  p_fxhv_rec.source_id      Mandatory
  --                         p_fxhv_rec.source_Table   Mandatory
  --
  --      History         : Ravindranath Gooty created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE delete_fa_extension(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_fxhv_rec                  IN             fxhv_rec_type
   ,x_fxlv_tbl                  OUT    NOCOPY  fxlv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : delete_ar_extension
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AR Transactions
  --      Parameters      :
  --      IN              :  p_rxhv_rec.source_id      Mandatory
  --                         p_rxhv_rec.source_Table   Mandatory
  --
  --      History         : Ravindranath Gooty created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE delete_ar_extension(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_rxhv_rec                  IN             rxhv_rec_type
   ,x_rxlv_tbl                  OUT    NOCOPY  rxlv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : delete_ap_extension
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              :  p_pxhv_rec.source_id      Mandatory
  --                         p_pxhv_rec.source_Table   Mandatory
  --
  --      History         : Ravindranath Gooty created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE delete_ap_extension(
    p_api_version               IN              NUMBER
   ,p_init_msg_list             IN              VARCHAR2
   ,p_pxhv_rec                  IN              pxhv_rec_type
   ,x_pxlv_tbl                  OUT    NOCOPY   pxlv_tbl_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );
  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL FA Depreciation Transactions
  --      Parameters      :
  --      IN              :
  --      History         : Ravindranath Gooty Created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_khr_id                    IN             NUMBER
   ,p_deprn_asset_tbl           IN             deprn_asset_tbl_type
   ,p_deprn_run_id              IN             NUMBER
   ,p_book_type_code            IN             VARCHAR2
   ,p_period_counter            IN             NUMBER
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_deprn_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              :  Asset Book Type Code      Mandatory
  --                         Period Counter            Mandatory
  --                         Worker ID                 Mandatory
  --                         Max. Deprn. Run ID        Mandatory
  --
  --      History         : Ravindranath Gooty created
  --      Version         : 1.0
  --      Description: API called by the Parallel worker for the
  --                   OKL: FA Capture Sources for Depreciation Transaction
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_deprn_sources(
    errbuf                    OUT      NOCOPY  VARCHAR2
   ,retcode                   OUT      NOCOPY  NUMBER
   ,p_book_type_code          IN               VARCHAR2
   ,p_period_counter          IN               VARCHAR2
   ,p_worker_id               IN               VARCHAR2
   ,p_max_deprn_run_id        IN               VARCHAR2
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_deprn_sources_conc
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL AP Transactions
  --      Parameters      :
  --      IN              :  Asset Book Type Code      Mandatory
  --                         Period Counter            Mandatory
  --      History         : Ravindranath Gooty created
  --      Version         : 1.0
  --      Description: API called by the Master Program of the conc. job
  --                   OKL: FA Capture Sources for Depreciation Transaction
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_deprn_sources_conc(
    errbuf                    OUT      NOCOPY  VARCHAR2
   ,retcode                   OUT      NOCOPY  NUMBER
   ,p_book_type_code          IN               VARCHAR2
   ,p_period_counter          IN               NUMBER
  );

  ------------------------------------------------------------------------------
  -- Start of comments
  --      API name        : populate_sources
  --      Pre-reqs        : None
  --      Function        : populate sources for OKL Receipt Transactions
  --      Parameters      :
  --      IN              :
  --      History         : Ravindranath Gooty Created
  --      Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE populate_sources(
    p_api_version               IN             NUMBER
   ,p_init_msg_list             IN             VARCHAR2
   ,p_rxh_rec                   IN             rxh_rec_type
   ,x_return_status             OUT    NOCOPY  VARCHAR2
   ,x_msg_count                 OUT    NOCOPY  NUMBER
   ,x_msg_data                  OUT    NOCOPY  VARCHAR2
  );

END okl_sla_acc_sources_pvt;

/
