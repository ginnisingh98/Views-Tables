--------------------------------------------------------
--  DDL for Package Body IES_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_TRANSACTIONS_PKG" AS
   /* $Header: iestranb.pls 115.4 2003/06/17 23:06:40 prkotha noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ies_transactions_pkg';

/* private functions */

FUNCTION getTransactionStatus(p_transaction_id IN NUMBER) RETURN NUMBER IS
   l_status NUMBER;
       TYPE transaction_status_type   IS REF CURSOR;
 trx_status transaction_status_type ;
BEGIN
   OPEN trx_status FOR '
   SELECT status
     FROM ies_transactions
    WHERE transaction_id = :1' using  p_transaction_id;
    LOOP
       FETCH trx_status INTO l_status;
       EXIT WHEN trx_status%NOTFOUND;
    END LOOP;
    return l_status;
END;

/* end of private function */


PROCEDURE endSuspendedTransaction
(
   p_api_version                    IN     NUMBER,
   p_transaction_id                 IN     NUMBER,
   x_return_status                  OUT NOCOPY     VARCHAR2,
   x_msg_count                      OUT NOCOPY     NUMBER,
   x_msg_data                       OUT NOCOPY     VARCHAR2
) IS
  l_api_name      CONSTANT VARCHAR2(30)   := 'endSuspendedTransaction';
  l_api_version   CONSTANT NUMBER         := 1.0;
    l_status        NUMBER;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT   end_suspended_trx_sp;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FND_MSG_PUB.initialize;

  -- Initialize the API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    -- API body
    l_status := getTransactionStatus(p_transaction_id);
    if (l_status = 1) then
      EXECUTE IMMEDIATE 'UPDATE ies_transactions SET status = 0 '||
                    'WHERE transaction_id = :1' USING p_transaction_id;
    else
  	 FND_MESSAGE.SET_NAME('IES', 'IES_STATUS_UPDATE_ERROR');
	 FND_MSG_PUB.Add;

      RAISE FND_API.G_EXC_ERROR;
    end if;

  EXCEPTION
    WHEN OTHERS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
       THEN
          FND_MESSAGE.SET_NAME('IES', 'IES_END_SUSPENDED_TRX_ERROR');
          FND_MSG_PUB.Add;
       END IF;

    RAISE FND_API.G_EXC_ERROR;
  END;

  -- Signify Success
  IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
      FND_MESSAGE.SET_NAME('IES', 'IES_END_SUSPENDED_TRX_SUCCESS');
      FND_MSG_PUB.Add;
  END IF;

  -- End of API body

   COMMIT WORK;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
     (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO end_suspended_trx_sp;
  x_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get
     (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO end_suspended_trx_sp;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get
     (
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

WHEN OTHERS THEN
  ROLLBACK TO end_suspended_trx_sp;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  IF     FND_MSG_PUB.Check_Msg_Level
        (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     FND_MSG_PUB.Add_Exc_Msg
     (      p_pkg_name            => G_PKG_NAME,
            p_procedure_name      => l_api_name,
            p_error_text          => 'G_MSG_LVL_UNEXP_ERROR'
     );
  END IF;
  FND_MSG_PUB.Count_And_Get
    (
        p_count         =>      x_msg_count,
        p_data          =>      x_msg_data
    );

END endSuspendedTransaction;

END ies_transactions_pkg;

/
