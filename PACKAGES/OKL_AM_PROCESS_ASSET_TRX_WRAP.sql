--------------------------------------------------------
--  DDL for Package OKL_AM_PROCESS_ASSET_TRX_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_AM_PROCESS_ASSET_TRX_WRAP" AUTHID CURRENT_USER AS
/* $Header: OKLBAMAS.pls 115.2 2002/12/18 12:07:17 kjinger noship $ */


  ---------------------------------------------------------------------------
   --  GLOBAL CONSTANTS
  ---------------------------------------------------------------------------

   G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_AM_PROCESS_ASSET_TRX_WRAP';
   G_APP_NAME             CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
   G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
   G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLerrm';
   G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLcode';

-- main body of OKL_AM_PROCESS_ASSET_TRX_WRAP

   PROCEDURE process_transactions_wrap(	ERRBUF                  OUT NOCOPY 	VARCHAR2,
                                        RETCODE                 OUT NOCOPY     VARCHAR2 ,
                                        p_api_version           IN  	NUMBER,
           			                    p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                        p_contract_id           IN      NUMBER   DEFAULT NULL,
                                        p_asset_id              IN      NUMBER   DEFAULT NULL,
                                        p_kle_id                IN      VARCHAR2 DEFAULT NULL,
                                        p_salvage_writedown_yn  IN      VARCHAR2 DEFAULT 'N'

                                     )   ;





END; -- Package spec

 

/
