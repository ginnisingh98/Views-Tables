--------------------------------------------------------
--  DDL for Package OKL_SUBSIDY_POOL_AUTH_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUBSIDY_POOL_AUTH_TRX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSIUS.pls 120.1 2005/10/30 03:17:15 appldev noship $ */

  subtype sixv_rec_type is OKL_SIX_PVT.sixv_rec_type;
  subtype sixv_tbl_type is OKL_SIX_PVT.sixv_tbl_type;

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(30) := 'OKL_SUBSIDY_POOL_AUTH_TRX_PVT';
  G_APP_NAME                     CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_API_TYPE                     CONSTANT VARCHAR2(30)  := '_PVT';

  G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR			CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) := OKL_API.G_RET_STS_UNEXP_ERROR;

  G_EXCEPTION_ERROR		EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;

  -------------------------------------------------------------------------------
  -- PROCEDURE create_pool_trx_khr_book
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pool_trx_khr_book
  -- Description     : common procedure which creates pool transaction in the okl_trx_subsidy_pools table
  --                   api for authoring contracts
  -- Parameters      : IN p_chr_id: CONTRACT_ID
  --                   IN p_subsidy_id
  --                   IN p_subsidy_pool_id
  --                   IN p_trx_amount : amount on the subsidy (if override amt not present then calculated value)
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments

  PROCEDURE create_pool_trx_khr_book(p_api_version   IN NUMBER
                               ,p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ,p_chr_id        IN okc_k_headers_b.id%TYPE
                               ,p_asset_id      IN okc_k_lines_b.id%TYPE
                               ,p_subsidy_id    IN okl_subsidies_b.id%TYPE
                               ,p_subsidy_pool_id IN okl_subsidy_pools_b.id%TYPE
                               ,p_trx_amount    IN okl_k_lines.amount%TYPE
                               );

  -------------------------------------------------------------------------------
  -- PROCEDURE create_pool_trx_khr_reverse
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pool_trx_khr_reverse
  -- Description     : procedure which adds back the subsidy amount that has been earlier reduced
  --                   this adding back to pool balance is done upon contract reversal
  -- Parameters      : IN p_chr_id: CONTRACT_ID
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments
  PROCEDURE create_pool_trx_khr_reverse(p_api_version   IN NUMBER
                                       ,p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_msg_count     OUT NOCOPY NUMBER
                                       ,x_msg_data      OUT NOCOPY VARCHAR2
                                       ,p_chr_id        IN okc_k_headers_b.id%TYPE
                                       ,p_reversal_date IN DATE
                                       ,p_override_trx_reason IN okl_trx_subsidy_pools.trx_reason_code%TYPE DEFAULT NULL
                                       );

  -------------------------------------------------------------------------------
  -- PROCEDURE create_pool_trx_khr_rbk
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pool_trx_khr_rbk
  -- Description     : procedure which creates subsidy pool transaction based on the trx_type_code
  --                   for the case of contract rebook.
  -- Parameters      : IN p_rbk_chr_id: Contract Id of the Reebook Copy Contract
  --                   IN p_orig_chr_id: Contract Id of the Original Contract
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments
  PROCEDURE create_pool_trx_khr_rbk(p_api_version   IN NUMBER
                                   ,p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2
                                   ,p_rbk_chr_id    IN okc_k_headers_b.id%TYPE
                                   ,p_orig_chr_id   IN okc_k_headers_b.id%TYPE
                                   );

  -------------------------------------------------------------------------------
  -- PROCEDURE create_pool_trx_khr_split
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_pool_trx_khr_split
  -- Description     : procedure which creates subsidy pool transaction based on the trx_type_code
  --                   for the case of split contract
  -- Parameters      : IN p_new1_chr_id: Contract Id of first split contract
  --                   IN p_new2_chr_id: Contract Id of second split contract
  -- Version         : 1.0
  -- History         : 07-FEB-2005 SJALASUT created
  -- End of comments
  PROCEDURE create_pool_trx_khr_split(p_api_version   IN NUMBER
                                   ,p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                                   ,x_return_status OUT NOCOPY VARCHAR2
                                   ,x_msg_count     OUT NOCOPY NUMBER
                                   ,x_msg_data      OUT NOCOPY VARCHAR2
                                   ,p_new1_chr_id    IN okc_k_headers_b.id%TYPE
                                   ,p_new2_chr_id   IN okc_k_headers_b.id%TYPE
                                   );


END okl_subsidy_pool_auth_trx_pvt;

 

/
