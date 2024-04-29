--------------------------------------------------------
--  DDL for Package OKL_SEC_CONCURRENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SEC_CONCURRENT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSZOS.pls 120.2 2006/02/07 00:04:28 fmiao noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- Record type which holds the account generator rule lines.
  G_FND_APP			        CONSTANT VARCHAR2(200) := OKL_API.G_FND_APP;
  G_UNEXPECTED_ERROR		CONSTANT VARCHAR2(30) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
  G_EXPECTED_ERROR		    CONSTANT VARCHAR2(28) := 'OKL_CONTRACTS_EXPECTED_ERROR';
  G_CONFIRM_PROCESS	    	CONSTANT VARCHAR2(19) := 'OKL_CONFIRM_PROCESS';
  G_PROCESS_START		    CONSTANT VARCHAR2(17) := 'OKL_PROCESS_START';
  G_PROCESS_END 		    CONSTANT VARCHAR2(15) := 'OKL_PROCESS_END';
  G_TOTAL_ROWS_PROCESSED	CONSTANT VARCHAR2(24) := 'OKL_TOTAL_ROWS_PROCESSED';

  G_SQLERRM_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLerrm';
  G_SQLCODE_TOKEN		CONSTANT VARCHAR2(200) := 'OKL_SQLcode';

 ----------------------------------------------------------------------------
 -- GLOBAL VARIABLES
 ----------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_SEC_CONCURRENT_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR		 CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
  G_EXCEPTION_ERROR		 EXCEPTION;
  G_EXCEPTION_UNEXPECTED_ERROR	 EXCEPTION;

  G_EXC_NAME_ERROR		CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_ERROR';
  G_EXC_NAME_UNEXP_ERROR	CONSTANT VARCHAR2(50) := 'OKL_API.G_RET_STS_UNEXP_ERROR';
  G_EXC_NAME_OTHERS	        CONSTANT VARCHAR2(6) := 'OTHERS';
  G_API_TYPE	                CONSTANT VARCHAR2(4) := '_PVT';

  G_BUYBACK_ERROR  CONSTANT VARCHAR2(20) := 'OKL_BUYBACK_ERROR';

  ----------------------------------------------------------------------------
  -- Global Exception
  ----------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  TYPE error_message_type IS TABLE OF VARCHAR2(2000)
  INDEX BY BINARY_INTEGER;

  ----------------------------------------------------------------------------
  -- Procedures and Functions
  ------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : BUYBACK_AGREEMENT
  -- Description     : This is a wrapper procedure for concurrent program to call private API
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------

  PROCEDURE BUYBACK_AGREEMENT(x_errbuf OUT  NOCOPY VARCHAR2
                             ,x_retcode OUT NOCOPY NUMBER
                             ,p_khr_id IN VARCHAR2);



-- fmiao bug: 4748514 start
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : activate_agreement_ui
-- Description     : Activate investor agreement
--                   This is a wrapper procedure for concurrent program call from jsp/UI
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------

 PROCEDURE activate_agreement_ui(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.g_false
   ,x_return_status                OUT nocopy VARCHAR2
   ,x_msg_count                    OUT nocopy NUMBER
   ,x_msg_data                     OUT nocopy VARCHAR2
   ,x_request_id                   OUT nocopy NUMBER
   -- agreement id --
   ,p_chr_id                       IN NUMBER);

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : activate_agreement
  -- Description     : This is a wrapper procedure to call the activate agreement API
  --                   to activate the agreement.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------

  PROCEDURE activate_agreement(x_errbuf OUT  NOCOPY VARCHAR2
                             ,x_retcode OUT NOCOPY NUMBER
                             ,p_chr_id IN VARCHAR2);
-- fmiao bug: 4748514 end

END OKL_SEC_CONCURRENT_PVT;

/
