--------------------------------------------------------
--  DDL for Package OKL_AM_PROCESS_ASSET_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_PROCESS_ASSET_TRX_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAMAS.pls 115.15 2002/08/14 00:54:19 sechawla noship $ */


  ---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_PROCESS_ASSET_TRX_PVT';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';


   G_TRANS_SUBTYPE	      CONSTANT FA_TRANSACTION_HEADERS.TRANSACTION_SUBTYPE%TYPE  := 'AMORTIZED';


   -- wrapper for executing OKL_AM_PROCESS_ASSET_TRX_PVT as a concurrent program
   PROCEDURE process_transactions_wrap(	ERRBUF                  OUT 	NOCOPY   VARCHAR2,
                                        RETCODE                 OUT     NOCOPY   VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                        p_contract_id           IN      NUMBER   DEFAULT NULL,
                                        p_asset_id              IN      NUMBER   DEFAULT NULL,
                                        p_kle_id                IN      VARCHAR2 DEFAULT NULL,
                                        p_salvage_writedown_yn  IN      VARCHAR2 DEFAULT 'N'

                                     )   ;


-- main body of OKL_AM_PROCESS_ASSET_TRX_PVT

   PROCEDURE process_transactions(	p_api_version           IN  	NUMBER,
           			            p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
           			            x_return_status         OUT 	NOCOPY VARCHAR2,
           			            x_msg_count             OUT 	NOCOPY NUMBER,
           			            x_msg_data              OUT 	NOCOPY VARCHAR2,
				                p_contract_id    	    IN 	    NUMBER DEFAULT NULL,
                                p_asset_id              IN      NUMBER DEFAULT NULL,
                                p_kle_id                IN      NUMBER DEFAULT NULL,
                                p_salvage_writedown_yn  IN      VARCHAR2 DEFAULT 'N',
                                x_total_count           OUT     NOCOPY NUMBER,
                                x_processed_count       OUT     NOCOPY NUMBER,
                                x_error_count           OUT     NOCOPY NUMBER  )   ;





END; -- Package spec

 

/
