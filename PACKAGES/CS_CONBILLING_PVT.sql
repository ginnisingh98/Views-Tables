--------------------------------------------------------
--  DDL for Package CS_CONBILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CONBILLING_PVT" AUTHID CURRENT_USER AS
/* $Header: csctarfs.pls 115.1 99/07/16 08:48:22 porting ship $ */

  -- Start of comments
  -- API name            : Update Billing API
  -- Type                : Public
  -- Pre-reqs            : None.
  -- Function            : This API to write invoice details to
  -- 			       cs_contracts_billing
  -- Parameters          :
  -- IN                  :
  --                         	p_api_version             NUMBER     Required
  --                         	p_contract_id             NUMBER
  --						p_cp_service_trx_id 	 NUMBER
  --						p_contract_id 		  	 NUMBER
  --						p_trx_type_id   	  	 NUMBER
  --						p_trx_number 	 	      NUMBER
  --						p_trx_date 		      DATE
  --				          p_trx_amount 		      NUMBER
  --			               p_trx_pre_tax_amount	 NUMBER
  --                         	p_cp_service_id           NUMBER
  --			        		p_obj_version_number 	 NUMBER
  -- 			          p_init_msg_list           VARCHAR2
  --                         	p_commit                  VARCHAR2
  -- OUT                 :
  --                         x_return_status            VARCHAR2
  --                         x_msg_count                NUMBER
  --                         x_msg_data                 VARCHAR2
  --End of comments
/*************************************************************************/

--GLOBAL VARIABLES:

G_PKG_NAME        CONSTANT   VARCHAR2(200)  := 'UPDATE_BILLING_PUB';
G_APP_NAME        CONSTANT   VARCHAR2(3)    := 'CS';



PROCEDURE Update_Billing(
			p_api_version  		IN   NUMBER,
			p_init_msg_list 		IN 	VARCHAR2 := FND_API.G_FALSE,
			p_commit 				IN 	VARCHAR2 := FND_API.G_FALSE,
			p_cp_service_trx_id 	IN 	NUMBER,
			p_contract_id 			IN 	NUMBER,
			p_trx_type_id 			IN 	NUMBER,
			p_trx_number 			IN 	NUMBER,
			p_trx_date 			IN 	DATE,
			p_tot_trx_amount 		IN 	NUMBER,
		     p_trx_pre_tax_amount 	IN 	NUMBER,
			p_contract_billing_id 	IN 	NUMBER,
			p_obj_version_number     IN   NUMBER,
			x_return_status 		OUT 	VARCHAR2,
			x_msg_count 			OUT 	NUMBER,
			x_msg_data 			OUT 	NUMBER);


END CS_CONBILLING_PVT;

 

/
