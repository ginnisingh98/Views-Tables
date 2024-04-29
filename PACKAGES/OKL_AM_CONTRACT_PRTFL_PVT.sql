--------------------------------------------------------
--  DDL for Package OKL_AM_CONTRACT_PRTFL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CONTRACT_PRTFL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPTFS.pls 115.3 2002/12/31 01:18:59 sechawla noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP				CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_AM_CONTRACT_PRTFL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
  G_EXCEPTION_INSURANCE_ERROR EXCEPTION;



  ---------------------------------------------------------------------------
  -- PROCEDURES
  ---------------------------------------------------------------------------


  PROCEDURE create_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_contract_id                   IN  NUMBER);



  -- wrapper for executing update_cntrct_prtfl procedure as a concurrent program
  PROCEDURE batch_upd_cntrct_prtfl(	    ERRBUF                  OUT 	NOCOPY   VARCHAR2,
                                        RETCODE                 OUT     NOCOPY   VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                        p_contract_id           IN      NUMBER   DEFAULT NULL
                                      )   ;

  PROCEDURE update_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_contract_id                   IN  NUMBER DEFAULT NULL,
    x_total_count                   OUT NOCOPY NUMBER,
    x_processed_count               OUT NOCOPY NUMBER,
    x_error_count                   OUT NOCOPY  NUMBER);

  -- wrapper for executing execute_cntrct_prtfl procedure as a concurrent program
  PROCEDURE batch_exe_cntrct_prtfl(	    ERRBUF                  OUT 	NOCOPY   VARCHAR2,
                                        RETCODE                 OUT     NOCOPY   VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE
                                      )   ;

  PROCEDURE execute_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    x_total_count                   OUT NOCOPY NUMBER,
    x_processed_count               OUT NOCOPY NUMBER,
    x_error_count                   OUT NOCOPY  NUMBER);


END OKL_AM_CONTRACT_PRTFL_PVT;

 

/
