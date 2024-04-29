--------------------------------------------------------
--  DDL for Package RCV_ACCOUNTHOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_ACCOUNTHOOK_PUB" AUTHID CURRENT_USER AS
/* $Header: RCVPAHKS.pls 115.0 2003/09/11 22:47:07 nnayak noship $ */

-- Start of comments
--	API name 	: Get_Account
--	Type		: Public
--	Function	: This function can be used to override the Retroactive
--			  price adjustment account.
--	Pre-reqs	:
--	Parameters	:
--	IN		:	p_api_version           IN NUMBER	Required
--				p_init_msg_list		IN VARCHAR2 	Optional
--					Default = FND_API.G_FALSE
--				p_commit	    	IN VARCHAR2	Optional
--					Default = FND_API.G_FALSE
--				p_validation_level	IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--			 	p_rcv_transaction_id	IN NUMBER
--				p_accounting_line_type  IN VARCHAR2
--
--	OUT		:	x_return_status		OUT	VARCHAR2(1)
--				x_msg_count		OUT	NUMBER
--				x_msg_data		OUT	VARCHAR2(2000)
--				x_distribution_acct_id	OUT	NUMBER
--	Version	:
--			  Initial version 	1.0
--
--	Notes		: This API can currently be used only to override the
--			  Retroactive Price Adjustment Account. The parameter
--			  p_rcv_transaction_id will contain the transaction_id
--			  for the transaction being adjusted. Currently, the only
--			  accounting line type supported is the 'Retroprice
--			  Adjustment'. If the returned value in x_distribution_acct_id
--			  is -1, the organization retroactive price adjustment account
--			  will be used. Otherwise the returned account will be used.
--
-- End of comments
-------------------------------------------------------------------------------
PROCEDURE Get_Account(
	        p_api_version          	IN		NUMBER,
                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,
		p_rcv_transaction_id	IN		NUMBER,
		p_accounting_line_type	IN		VARCHAR2,
		x_distribution_acct_id	OUT NOCOPY	NUMBER
);

END RCV_AccountHook_PUB;

 

/
