--------------------------------------------------------
--  DDL for Package OKL_QUOTE_TO_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QUOTE_TO_CONTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLQCS.pls 120.1 2006/03/09 05:18:18 rravikir noship $ */

  SUBTYPE clev_fin_rec     IS okl_okc_migration_pvt.clev_rec_type;
  SUBTYPE ipyv_rec_type    IS Okl_Ipy_Pvt.ipyv_rec_type;

  TYPE link_asset_rec_type IS RECORD(fin_asset_id   NUMBER,
                                     amount         NUMBER,
                                     asset_number   VARCHAR2(15));
  TYPE link_asset_tbl_type IS TABLE OF link_asset_rec_type
  INDEX BY BINARY_INTEGER;
  TYPE quote_service_rec_type IS RECORD ( CHR_ID                  NUMBER,
                                          CLE_ID                  NUMBER,
                                          SERVICE_NAME_ID         NUMBER,
                                          SUPPLIER_ID             NUMBER,
                                          SUPPLIER_SITE_ID        NUMBER,
                                          START_DATE              DATE,
                                          PERIODS                 NUMBER,
                                          PERIODIC_AMOUNT         NUMBER,
                                          FREQUENCY_CODE_EXPENSE  VARCHAR2(30),
                                          PASSTHROUGH_PERCENTAGE  NUMBER,
                                          PASSTHROUGH_BASIS_CODE  VARCHAR2(30),
                                          PAYMENT_METHOD_CODE     VARCHAR2(30),
                                          PAYMENT_TERMS_CODE      VARCHAR2(30),
                                          PAYMENT_TYPE_ID         NUMBER,
                                          ARREARS_YN              VARCHAR2(1),
                                          FREQUENCY_CODE          VARCHAR2(30),
                                          PASSTHROUGH_STREAM_TYPE_ID NUMBER);
  TYPE payment_levels_rec_type IS RECORD (PAYMENT_LEVEL_ID        NUMBER,
                                          START_DATE              DATE,
                                          PERIODS                 NUMBER,
                                          AMOUNT                  NUMBER,
                                          STUB_DAYS               NUMBER,
                                          STUB_AMOUNT             NUMBER,
                                          RATE                    NUMBER,
                                          RATE_TYPE               VARCHAR2(30),
                                          PAYMENT_STRUCTURE       VARCHAR2(1),
                                          PAYMENT_TYPE_ID         NUMBER,
                                          FREQUENCY_CODE          VARCHAR2(1),
                                          ARREARS_YN              VARCHAR2(1));
  TYPE payment_levels_tbl_type IS TABLE OF payment_levels_rec_type
  INDEX BY BINARY_INTEGER;
  TYPE qte_cntrct_ast_rec_type IS RECORD (qte_asset_id            NUMBER,
                                          cntrct_asset_id         NUMBER);
  TYPE qte_cntrct_ast_tbl_type IS TABLE OF qte_cntrct_ast_rec_type
  INDEX BY BINARY_INTEGER;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                      CONSTANT VARCHAR2(200) := 'OKL_QUOTE_TO_CONTRACT_PVT';
  G_APP_NAME                      CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_API_TYPE                      CONSTANT VARCHAR2(30)  := '_PVT';
  G_REQUIRED_VALUE                CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN                CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_UNEXPECTED_ERROR		            CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN	                CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_RLE_CODE                      CONSTANT VARCHAR2(10)  := 'LESSEE';
  G_STS_CODE                      CONSTANT VARCHAR2(10)  := 'NEW';
  G_LEASE_VENDOR                  CONSTANT VARCHAR2(10)  := 'OKL_VENDOR';
  G_VENDOR_BILL_RGD_CODE          CONSTANT VARCHAR2(10)  := 'LAVENB';
  G_DB_ERROR                      CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN               CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_RET_STS_SUCCESS               CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR           CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR                 CONSTANT VARCHAR2(1)   := OKL_API.G_RET_STS_ERROR;

  PROCEDURE create_contract(
            p_api_version                  IN NUMBER,
           p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
           x_return_status                OUT NOCOPY VARCHAR2,
           x_msg_count                    OUT NOCOPY NUMBER,
           x_msg_data                     OUT NOCOPY VARCHAR2,
           p_contract_number              IN  VARCHAR2,
           p_parent_object_code           IN VARCHAR2,--LEASEAPP or LEASEOPP
           p_parent_object_id             IN  NUMBER,--LEASEAPP ID or LEASEOPP ID
           x_chr_id                       OUT NOCOPY NUMBER,
		   x_contract_number			  OUT NOCOPY VARCHAR2);
END OKL_QUOTE_TO_CONTRACT_PVT;

/
