--------------------------------------------------------
--  DDL for Package OKL_REVERSE_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_REVERSE_CONTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRRVKS.pls 120.6 2007/08/28 09:39:59 rviriyal noship $ */

G_FALSE		CONSTANT VARCHAR2(1) := OKL_API.G_FALSE;
G_TRUE		CONSTANT VARCHAR2(1) := OKL_API.G_TRUE;

G_PKG_NAME      CONSTANT VARCHAR2(200) := 'OKL_REVERSE_CONTRACT_PVT';
G_APP_NAME      CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

G_MISS_NUM	CONSTANT NUMBER := OKL_API.G_MISS_NUM;
G_MISS_CHAR	CONSTANT VARCHAR2(1) := OKL_API.G_MISS_CHAR;
G_MISS_DATE	CONSTANT DATE := OKL_API.G_MISS_DATE;

--------------------------------------------------------------------------------
-- ERRORS AND EXCEPTIONS
--------------------------------------------------------------------------------
G_BOOKED            		CONSTANT VARCHAR2(200) := 'BOOKED';
G_REVERSED            		CONSTANT VARCHAR2(200) := 'REVERSED';
G_CANCELED            		CONSTANT VARCHAR2(200) := 'CANCELED';
G_BOOKING            		CONSTANT VARCHAR2(200) := 'BOOKING';
G_UPFRONT_TAX                   CONSTANT VARCHAR2(200) := 'UPFRONT_TAX';
G_GENERATE_YIELDS            	CONSTANT VARCHAR2(200) := 'GENERATE_YIELDS';
G_INTERNAL_ASSET_CREATION       CONSTANT VARCHAR2(200) := 'INTERNAL_ASSET_CREATION';
G_FUNDING            		CONSTANT VARCHAR2(200) := 'FUNDING';
G_SOURCE_TABLE            	CONSTANT VARCHAR2(200) := 'SOURCE_TABLE';
G_OKL_TXL_CNTRCT_LNS            CONSTANT VARCHAR2(200) := 'OKL_TXL_CNTRCT_LNS';
G_OKL_TXL_ASSETS_B            	CONSTANT VARCHAR2(200) := 'OKL_TXL_ASSETS_B';
G_OKL_TXL_AP_INV_LNS_B          CONSTANT VARCHAR2(200) := 'OKL_TXL_AP_INV_LNS_B';
OKL_LLA_CONT_REV_BOOKED		CONSTANT VARCHAR2(200) := 'OKL_LLA_CONT_REV_BOOKED';
OKL_LLA_CONT_REV_TRX_TYPE         CONSTANT VARCHAR2(200) := 'OKL_LLA_CONT_REV_TRX_TYPE';
-- Manu 11-Aug-2004. Message for Rollover Fee line check.
OKL_LA_NO_REV_CONTRACT		CONSTANT VARCHAR2(200) := 'OKL_LA_NO_REV_CONTRACT';

-- cklee 04/01/2004
G_OKL_TXL_AR_INV_LNS_B          CONSTANT VARCHAR2(200) := 'OKL_TXL_AR_INV_LNS_B';


G_UNEXPECTED_ERROR                CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN                   CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
G_SQLCODE_TOKEN                   CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
--START: 12-07-05 cklee       changed message reference                   |
--G_INVALID_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
--G_REQUIRED_VALUE			CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
--G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
G_INVALID_VALUE			CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
G_REQUIRED_VALUE			CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := 'COL_NAME';
--END: 12-07-05 cklee       changed message reference                   |

G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR			CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

G_EXCEPTION_ERROR		EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

--rviriyal 28-08-2007 Start: Added Message for Bug# 6164603
OKL_LLA_AR_INV_LINE_EXIST   CONSTANT VARCHAR2(200) := 'OKL_LLA_AR_INV_LINE_EXIST';
--rviriyal 28-08-2007 End: Added Message for Bug# 6164603

  SUBTYPE tcnv_rec_type IS okl_tcn_pvt.tcnv_rec_type;
  subtype tapv_rec_type IS okl_tap_pvt.tapv_rec_type;
  subtype thpv_rec_type IS okl_tas_pvt.tasv_rec_type;

-- Procedure which reverses a contract

PROCEDURE Reverse_Contract (p_api_version         IN   NUMBER,
                            p_init_msg_list       IN   VARCHAR2,
                            x_return_status       OUT  NOCOPY VARCHAR2,
                            x_msg_count           OUT  NOCOPY NUMBER,
                            x_msg_data            OUT  NOCOPY VARCHAR2,
                            p_contract_id         IN   NUMBER,
                            p_transaction_date    IN   DATE );


END OKL_REVERSE_CONTRACT_PVT;

/
