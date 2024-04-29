--------------------------------------------------------
--  DDL for Package OKL_SECURITIZATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SECURITIZATION_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSZSS.pls 120.3 2005/11/17 01:37:31 fmiao noship $ */
 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKL_SECURTIZATION_PVT';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  Okl_Api.G_APP_NAME;

  G_RET_STS_SUCCESS		  CONSTANT VARCHAR2(1) 	:= Okl_Api.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		  CONSTANT VARCHAR2(1) 	:= Okl_Api.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		        CONSTANT VARCHAR2(1) 	:= Okl_Api.G_RET_STS_ERROR;
  G_EXCEPTION_ERROR		  EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR  EXCEPTION;

  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(30) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(30) := 'OKL_SQLERRM';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(30) := 'OKL_SQLCODE';

  G_STS_CODE_ACTIVE             CONSTANT VARCHAR2(10) := 'ACTIVE';
  G_STS_CODE_BOOKED             CONSTANT VARCHAR2(10) := 'BOOKED';
  G_PROCESS_AUTO_BACK_BACK      CONSTANT VARCHAR2(30) := 'AUTO_BACK_BACK';
  G_PROCESS_NOT_ALLOWED         CONSTANT VARCHAR2(30) := 'NOT_ALLOWED';
  G_PRIORITY_1                   CONSTANT NUMBER := 1;
  G_PRIORITY_2                   CONSTANT NUMBER := 2;
  G_PROCESS_RULE_CODE           CONSTANT VARCHAR2(30) := 'LASEPR';

 -- mvasudev
  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	CONSTANT VARCHAR(4) := '_PVT';
  G_TRX_TYPE_REMOVAL CONSTANT VARCHAR2(6) := 'REMOVE';
  G_TRX_REASON_BUYBACK CONSTANT VARCHAR2(8) := 'BUY_BACK';

-- cklee 08/11/03
  G_GREATER_THAN             CONSTANT VARCHAR2(2) := '>';
  G_LESS_THAN                CONSTANT VARCHAR2(2) := '<';
  G_EQUAL_TO                 CONSTANT VARCHAR2(2) := '=';
  G_LESS_THAN_EQUAL_TO       CONSTANT VARCHAR2(2) := '<=';
  G_GREATER_THAN_EQUAL_TO    CONSTANT VARCHAR2(2) := '>=';



 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
  TYPE inv_agmt_chr_id_rec_type IS RECORD (
     khr_id         OKC_K_HEADERS_B.ID%TYPE            := Okc_Api.G_MISS_NUM
    ,process_code   OKC_RULES_B.RULE_INFORMATION1%TYPE := Okc_Api.G_MISS_CHAR
    );

  TYPE inv_agmt_chr_id_tbl_type IS TABLE OF inv_agmt_chr_id_rec_type
        INDEX BY BINARY_INTEGER;

  -- mvasudev, for buyback apis
  SUBTYPE pocv_rec_type IS Okl_Poc_Pvt.pocv_rec_type;
  SUBTYPE pocv_tbl_type IS Okl_Poc_Pvt.pocv_tbl_type;
  SUBTYPE poxv_rec_type IS Okl_Pox_Pvt.poxv_rec_type;
  SUBTYPE poxv_tbl_type IS Okl_Pox_Pvt.poxv_tbl_type;

  -- mvasudev, for modify_poc apis
  SUBTYPE cle_tbl_type IS Okl_Split_Asset_Pvt.cle_tbl_type;


  G_TRX_TYPE_REPLACE CONSTANT VARCHAR2(10) := 'REPLACE';

  G_TRX_REASON_CONTRACT_REBOOK   CONSTANT VARCHAR2(20) := 'CONTRACT_REBOOK';
  G_TRX_REASON_ASSET_SPLIT       CONSTANT VARCHAR2(20) := 'ASSET_SPLIT';
  G_TRX_REASON_EARLY_TERMINATION CONSTANT VARCHAR2(20) := 'EARLY_TERMINATION';
  G_TRX_REASON_ASSET_TERMINATION CONSTANT VARCHAR2(20) := 'ASSET_TERMINATION';
  G_TRX_REASON_ASSET_DISPOSAL    CONSTANT VARCHAR2(20) := 'ASSET_DISPOSAL';
  G_TRX_REASON_PURCHASE          CONSTANT VARCHAR2(20) := 'PURCHASE';
  G_TRX_REASON_REPURCHASE        CONSTANT VARCHAR2(20) := 'REPURCHASE';
  G_TRX_REASON_SCRAP             CONSTANT VARCHAR2(20) := 'SCRAP';
  G_TRX_REASON_REMARKET          CONSTANT VARCHAR2(20) := 'REMARKET';
  G_TRX_REASON_AGR_TERMINATION   CONSTANT VARCHAR2(25) := 'AGREEMENT_TERMINATION';

 ----------------------------------------------------------------------------
 -- Global Exception
 ----------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

 ----------------------------------------------------------------------------
 -- Procedures and Functions
 ------------------------------------------------------------------------------
-----------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : check_khr_securitized
-- Description     : Checks if a contract is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
PROCEDURE check_khr_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
-- cklee 08-08-2003 11.5.10
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
-- cklee 08-08-2003 11.5.10
   ,x_value                        OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id_tbl          OUT NOCOPY inv_agmt_chr_id_tbl_type
 );

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_khr_securitized
-- Description     : Checks if a contract is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : return: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
--                   OKL_API.G_RET_STS_ERROR, OKL_API.G_RET_STS_UNEXP_ERROR
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
/*
-- mvasudev, 10/03/2003, de-comissioned
 FUNCTION is_khr_securitized(
   p_khr_id                        IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
-- cklee 08-08-2003 11.5.10
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
-- cklee 08-08-2003 11.5.10
 ) RETURN VARCHAR;
 PRAGMA RESTRICT_REFERENCES (is_khr_securitized, TRUST);
*/

-----------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : check_kle_securitized
-- Description     : Checks if an Asset is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
 PROCEDURE check_kle_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_kle_id                       IN okc_k_lines_b.ID%TYPE
   ,p_effective_date               IN DATE
-- cklee 08-08-2003 11.5.10
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
-- cklee 08-08-2003 11.5.10
   ,x_value                        OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id_tbl          OUT NOCOPY inv_agmt_chr_id_tbl_type
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_kle_securitized
-- Description     : Checks if an Asset is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : return: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
--                   OKL_API.G_RET_STS_ERROR, OKL_API.G_RET_STS_UNEXP_ERROR
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
/*
-- mvasudev, 10/03/2003, de-comissioned
 FUNCTION is_kle_securitized(
   p_kle_id                       IN okc_k_lines_b.ID%TYPE
   ,p_effective_date               IN DATE
-- cklee 08-08-2003 11.5.10
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
-- cklee 08-08-2003 11.5.10
 ) RETURN VARCHAR;
 PRAGMA RESTRICT_REFERENCES (is_kle_securitized, TRUST);
 */

-----------------------------------------------------------------------
-- Start of comments
-- mvasudev, 10/03/2003
-- Procedure Name  : check_sty_securitized
-- Description     : Checks if a StreamType is securitized on the given date
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
 PROCEDURE check_sty_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
   ,p_effective_date_operator      IN VARCHAR2 DEFAULT G_GREATER_THAN_EQUAL_TO
   ,p_sty_id                       IN okl_strm_type_b.id%TYPE
   ,x_value                        OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id              OUT NOCOPY NUMBER
 );

------------------------------------------------------------------------- Start of comments
--
-- Procedure Name  : check_stm_securitized
-- Description     : Checks if any of the Streams Element under a streams header is securitized
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
 PROCEDURE check_stm_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_stm_id                       IN okl_streams.ID%TYPE
   ,p_effective_date               IN DATE
   ,x_value                        OUT NOCOPY VARCHAR2
 );
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_stm_securitized
-- Description     : Checks if any of the Streams Element under a streams header is securitized
-- Business Rules  :
-- Parameters      :
--                 : return: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
--                   OKL_API.G_RET_STS_ERROR, OKL_API.G_RET_STS_UNEXP_ERROR
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
/*
-- mvasudev, 10/03/2003, de-comissioned
 FUNCTION is_stm_securitized(
   p_stm_id                       IN okl_streams.ID%TYPE
   ,p_effective_date               IN DATE
 ) RETURN VARCHAR;
 PRAGMA RESTRICT_REFERENCES (is_stm_securitized, TRUST);
 */
------------------------------------------------------------------------- Start of comments
--
-- Procedure Name  : check_sel_securitized
-- Description     : Checks if a Stream Element is securitized
-- Business Rules  :
-- Parameters      :
--                 : x_value: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
-- Version         : 1.0
-- End of comments
-----------------------------------------------------------------------
 PROCEDURE check_sel_securitized(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_sel_id                       IN okl_strm_elements.ID%TYPE
   ,p_effective_date               IN DATE
   ,x_value                        OUT NOCOPY VARCHAR2
 );



----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : is_sel_securitized
-- Description     : Checks if a Stream Element is securitized
-- Business Rules  :
-- Parameters      :
--                 : return: OKL_API.G_TRUE: true, OKL_API.G_FALSE false,
--                   OKL_API.G_RET_STS_ERROR, OKL_API.G_RET_STS_UNEXP_ERROR
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
/*
-- mvasudev, 10/03/2003, de-comissioned
 FUNCTION is_sel_securitized(
   p_sel_id                   IN okl_strm_elements.ID%TYPE
   ,p_effective_date               IN DATE
 ) RETURN VARCHAR;
 PRAGMA RESTRICT_REFERENCES (is_sel_securitized, TRUST);
 */

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : buyback_asset
-- Description     : Automatically buy back stream elements based on passed in kle_id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE buyback_asset(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_kle_id                       IN okc_k_lines_b.ID%TYPE
   ,p_effective_date               IN DATE

 );

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : buyback_contract
 -- Description     : Automatically buy back stream elements based on passed in khr_id
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE buyback_contract(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
 );

-------------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : process_khr_investor_rules
-- Description     : checks the Buyback rule at the Investor Agreement and performs Buyback if required
-- Business Rules  :
-- Parameters      :
--                  x_process_code: AUTO_BUY_BACK, NOT_ALLOWED
--                  x_inv_agmt_chr_id_tbl: associated investor agreement id and process code
-- Version         : 1.0
-- End of comments
---------------------------------------------------------------------------------------------------------
 PROCEDURE process_khr_investor_rules(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_effective_date               IN DATE
   ,p_rgd_code                     IN  VARCHAR2
   ,p_rdf_code                     IN  VARCHAR2 DEFAULT NULL
   ,x_process_code                 OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id_tbl          OUT NOCOPY inv_agmt_chr_id_tbl_type
 );


-------------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : process_kle_investor_rules
-- Description     : checks the Buyback rule at the Investor Agreement and performs Buyback if required
-- Business Rules  :
-- Parameters      :
--                  x_process_code: AUTO_BUY_BACK, NOT_ALLOWED
--                  x_inv_agmt_chr_id_tbl: associated investor agreement id and process code
-- Version         : 1.0
-- End of comments
---------------------------------------------------------------------------------------------------------
 PROCEDURE process_kle_investor_rules(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_kle_id                       IN okc_k_lines_b.ID%TYPE
   ,p_effective_date               IN DATE
   ,p_rgd_code                     IN  VARCHAR2
   ,p_rdf_code                     IN  VARCHAR2 DEFAULT NULL
   ,x_process_code                 OUT NOCOPY VARCHAR2
   ,x_inv_agmt_chr_id_tbl          OUT NOCOPY inv_agmt_chr_id_tbl_type
 );

-------------------------------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : buyback_pool_contents
-- Description     : Performs Buyback on streams specified by the Stream_Type_SubClass
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
---------------------------------------------------------------------------------------------------------
  PROCEDURE buyback_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_pol_id                       IN okl_pools.ID%TYPE
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE
   ,p_effective_date               IN DATE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2);


 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : calculate_buyback_amount
 -- Description     : Calculate BuyBack amount for a given Lease Contract, Pool,
 --                   StreamType_Subclass
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE calculate_buyback_amount(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_pol_id                       IN okl_pools.ID%TYPE
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE
   ,x_buyback_amount               OUT NOCOPY NUMBER
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
 );

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : modify_pool_contents
 -- Description     : Gateway API for DownStream Lease Processes to Modify Pool
 --                   Contents upon some regular changes.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE modify_pool_contents(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,p_transaction_reason           IN  VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_kle_id                       IN OKC_K_LINES_B.ID%TYPE   DEFAULT NULL
   ,p_stream_type_subclass         IN okl_strm_type_b.stream_type_subclass%TYPE DEFAULT NULL
   ,p_transaction_date             IN DATE
   ,p_effective_date               IN DATE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
 );

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : modify_pool_contents
 -- Description     : Gateway API for DownStream Lease Processes to Modify Pool
 --                   Contents upon Asset Split.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE modify_pool_contents(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
   ,p_transaction_reason           IN  VARCHAR2
   ,p_khr_id                       IN okc_k_headers_b.ID%TYPE
   ,p_kle_id                       IN OKC_K_LINES_B.ID%TYPE
   ,p_split_kle_ids                IN cle_tbl_type
   ,p_transaction_date             IN DATE
   ,p_effective_date               IN DATE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
 );

 ----------------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : check_khr_ia_associated
 -- Description     : Utility API for Accounting and rest of okl to check whether
 --                   a contract is associated with investor agreement.
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 ----------------------------------------------------------------------------------
 PROCEDURE check_khr_ia_associated(
    p_api_version                  IN  NUMBER
   ,p_init_msg_list                IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_khr_id                       IN  NUMBER
   ,p_scs_code                     IN  okc_k_headers_b.scs_code%TYPE DEFAULT NULL
   ,p_trx_date                     IN  DATE
   ,x_fact_synd_code               OUT NOCOPY fnd_lookups.lookup_code%TYPE
   ,x_inv_acct_code                OUT NOCOPY okc_rules_b.RULE_INFORMATION1%TYPE
 );




END Okl_Securitization_Pvt;

 

/
