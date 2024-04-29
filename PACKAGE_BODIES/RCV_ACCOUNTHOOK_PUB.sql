--------------------------------------------------------
--  DDL for Package Body RCV_ACCOUNTHOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_ACCOUNTHOOK_PUB" AS
/* $Header: RCVPAHKB.pls 115.0 2003/09/11 22:48:04 nnayak noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'RCV_AccountHook_PUB';

-- Start of comments
--      API name        : Get_Account
--      Type            : Public
--      Function        : This function can be used to override the Retroactive
--                        price adjustment account.
--      Pre-reqs        :
--      Parameters      :
--      IN              :       p_api_version           IN NUMBER       Required
--                              p_init_msg_list         IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_commit                IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level      IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_rcv_transaction_id    IN NUMBER
--                              p_accounting_line_type  IN VARCHAR2
--
--      OUT             :       x_return_status         OUT     VARCHAR2(1)
--                              x_msg_count             OUT     NUMBER
--                              x_msg_data              OUT     VARCHAR2(2000)
--                              x_distribution_acct_id  OUT     NUMBER
--      Version :
--                        Initial version       1.0
--
--      Notes           : This API can currently be used only to override the
--                        Retroactive Price Adjustment Account. The parameter
--                        p_rcv_transaction_id will contain the transaction_id
--                        for the transaction being adjusted. Currently, the only
--                        accounting line type supported is the 'Retroprice
--                        Adjustment'. If the returned value in x_distribution_acct_id
--                        is -1, the organization retroactive price adjustment account
--                        will be used. Otherwise the returned account will be used.
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
		x_distribution_acct_id	OUT NOCOPY 	NUMBER

)
IS
   l_api_name   CONSTANT VARCHAR2(30)   := 'Create_AccountingEvents';
   l_api_version        CONSTANT NUMBER         := 1.0;

   l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
   l_msg_count           NUMBER := 0;
   l_msg_data            VARCHAR2(8000) := '';

BEGIN
   -- Standard start of API savepoint
      SAVEPOINT Get_Account_PUB;


   -- Standard call to check for call compatibility
      IF NOT FND_API.Compatible_API_Call (
                        l_api_version,
                        p_api_version,
                        l_api_name,
                        G_PKG_NAME ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      x_distribution_acct_id := -1;

EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK TO Get_Account_PUB;
         x_return_status := fnd_api.g_ret_sts_unexp_error ;

END Get_Account;

END RCV_AccountHook_PUB;

/
