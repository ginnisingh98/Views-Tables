--------------------------------------------------------
--  DDL for Package PV_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PRICE_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvpris.pls 120.1 2005/11/18 13:05:35 dgottlie noship $ */



PROCEDURE Price_Request(
            p_api_version_number         IN  NUMBER
           ,p_init_msg_list              IN  VARCHAR2           := FND_API.G_FALSE
           ,p_commit                     IN  VARCHAR2           := FND_API.G_FALSE
	   ,p_partner_account_id         IN  NUMBER
	   ,p_partner_party_id           IN  NUMBER
	   ,p_contact_party_id		 IN  NUMBER
           ,p_transaction_currency       IN  VARCHAR2
	   ,p_enrl_req_id                IN  JTF_NUMBER_TABLE
	   ,x_return_status		 OUT NOCOPY	VARCHAR2
  	   ,x_msg_count                  OUT NOCOPY  NUMBER
           ,x_msg_data                   OUT NOCOPY  VARCHAR2
   );


END PV_PRICE_PVT;

 

/
