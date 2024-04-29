--------------------------------------------------------
--  DDL for Package OKL_PROP_TAX_ADJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PROP_TAX_ADJ_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPEPRS.pls 120.2 2005/10/30 04:01:35 appldev noship $ */
   PROCEDURE create_adjustment_invoice(
	       p_api_version        IN NUMBER,
    	   p_init_msg_list      IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    	   x_return_status      OUT NOCOPY VARCHAR2,
    	   x_msg_count          OUT NOCOPY NUMBER,
    	   x_msg_data           OUT NOCOPY VARCHAR2,
      	   p_contract_number	IN  VARCHAR2 DEFAULT NULL,
           p_asset_number       IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE create_adjust_invoice_conc
  ( errbuf             OUT NOCOPY VARCHAR2
   ,retcode            OUT NOCOPY NUMBER
   ,p_contract_number  IN VARCHAR2
   ,p_asset_number     IN VARCHAR2
  );


END OKL_PROP_TAX_ADJ_PUB;

 

/
