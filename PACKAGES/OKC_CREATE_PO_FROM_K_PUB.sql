--------------------------------------------------------
--  DDL for Package OKC_CREATE_PO_FROM_K_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_CREATE_PO_FROM_K_PUB" AUTHID CURRENT_USER AS
 /* $Header: OKCPKPOS.pls 120.0 2005/05/25 23:13:47 appldev noship $ */

-------------------------------------------------------------------------------
-- Procedure:       create_po_from_k
-- Version:         1.0
-- Purpose:         The first one is planned to be called by a Conc. Prog.
--                  and calls itself the second one
--                  Public face for the API to create PO out of Active/signed buy contracts


PROCEDURE create_po_from_k(ERRBUF                    OUT NOCOPY VARCHAR2
                           ,RETCODE                  OUT NOCOPY NUMBER
			   ,p_contract_id            IN  okc_k_headers_b.ID%TYPE
                           );

-- we might later want to modify this to return the po number of the craeted PO since we are going to call
-- PDOI from inside this
-- take out p_batch_id then as it will be generated from inside the code now.
  PROCEDURE create_po_from_k(p_api_version             IN  NUMBER             DEFAULT OKC_API.G_MISS_NUM
			    ,p_init_msg_list            IN  VARCHAR2           DEFAULT OKC_API.G_FALSE
                           ,p_commit                   IN  VARCHAR2           DEFAULT OKC_API.G_FALSE
			   ,p_contract_id              IN  okc_k_headers_b.ID%TYPE
                           ,x_return_status            OUT NOCOPY VARCHAR2
			               ,x_msg_count                OUT NOCOPY NUMBER
			               ,x_msg_data                 OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------------------
-- Procedure:       submit_req_for_po_creation
-- Version:         1.0
-- Purpose: This procedure is called from a condition when the
-- contract is signed to automate PO creation without running the
-- concurrent program
-------------------------------------------------------------------------------

  PROCEDURE submit_req_for_po_creation(
                          p_api_version     IN  NUMBER DEFAULT 1
			 ,p_contract_id     IN  NUMBER
                         ,p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_TRUE
                         ,x_return_status   OUT NOCOPY VARCHAR2
                         ,x_msg_count       OUT NOCOPY NUMBER
                         ,x_msg_data        OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------
-- Procedure:       notify_buyer
-- Version:         1.0
-- Purpose: notify the buyer of a purchase order creation
-------------------------------------------------------------------------------
      PROCEDURE notify_buyer(p_api_version                  IN NUMBER DEFAULT OKC_API.G_MISS_NUM
                      		,p_init_msg_list              IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                      		,p_commit                     IN VARCHAR2 DEFAULT OKC_API.G_FALSE
		      		,p_application_name           IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      		,p_message_subject            IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT OKC_API.G_MISS_CHAR
		      		,p_message_body 	            IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT OKC_API.G_MISS_CHAR
		      		,p_message_body_token1 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      		,p_message_body_token1_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      		,p_message_body_token2 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      		,p_message_body_token2_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
                              ,p_message_body_token3 		IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      		,p_message_body_token3_value 	IN VARCHAR2 DEFAULT OKC_API.G_MISS_CHAR
		      		,p_trace_mode      		IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                      		,p_chr_id     		      IN OKC_K_HEADERS_B.ID%TYPE DEFAULT NULL
                      		,x_k_buyer_name               OUT NOCOPY VARCHAR2
                      		,x_return_status   	 OUT NOCOPY VARCHAR2
                      		,x_msg_count                  OUT NOCOPY NUMBER
                      		,x_msg_data                   OUT NOCOPY VARCHAR2);


END OKC_CREATE_PO_FROM_K_PUB;

 

/
