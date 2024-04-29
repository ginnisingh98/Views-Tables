--------------------------------------------------------
--  DDL for Package OKL_AM_CONTRACT_PRTFL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_CONTRACT_PRTFL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPTFS.pls 115.2 2002/07/11 19:32:56 sechawla noship $ */

---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_CONTRACT_PRTFL_PUB';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';



  PROCEDURE create_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    p_contract_id                   IN  NUMBER);



  --  wrapper for executing update_cntrct_prtfl procedure as a concurrent program
  PROCEDURE batch_upd_cntrct_prtfl(
    ERRBUF                          OUT 	NOCOPY   VARCHAR2,
    RETCODE                         OUT     NOCOPY   VARCHAR2 ,
    p_api_version                   IN  	NUMBER,
    p_init_msg_list                 IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_contract_id                   IN      NUMBER   DEFAULT NULL )   ;

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

  PROCEDURE batch_exe_cntrct_prtfl(
    ERRBUF                          OUT 	NOCOPY   VARCHAR2,
    RETCODE                         OUT     NOCOPY   VARCHAR2 ,
    p_api_version                   IN  	NUMBER,
    p_init_msg_list                 IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE)   ;

  PROCEDURE execute_cntrct_prtfl(
    p_api_version                  	IN  NUMBER,
    p_init_msg_list                	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                	OUT NOCOPY VARCHAR2,
    x_msg_count                    	OUT NOCOPY NUMBER,
    x_msg_data                     	OUT NOCOPY VARCHAR2,
    x_total_count                   OUT NOCOPY NUMBER,
    x_processed_count               OUT NOCOPY NUMBER,
    x_error_count                   OUT NOCOPY  NUMBER);



END OKL_AM_CONTRACT_PRTFL_PUB;

 

/
