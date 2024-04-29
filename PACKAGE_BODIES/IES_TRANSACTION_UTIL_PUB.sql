--------------------------------------------------------
--  DDL for Package Body IES_TRANSACTION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IES_TRANSACTION_UTIL_PUB" AS
   /* $Header: iestutlb.pls 115.0.1159.1 2003/05/23 22:12:47 prkotha noship $ */

/*-------------------------------------------------------------------------*
 |    PRIVATE CONSTANTS
 *-------------------------------------------------------------------------*/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IES_TRANSACTION_UTIL_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iestutlb.pls';


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

PROCEDURE update_status_to_completed
(
   p_api_version                    IN     NUMBER,
   p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
   p_commit                         IN     VARCHAR2        := FND_API.G_TRUE,
   p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
   p_transaction_id                 IN     NUMBER,
   x_return_status                  OUT NOCOPY     VARCHAR2,
   x_msg_count                      OUT NOCOPY     NUMBER,
   x_msg_data                       OUT NOCOPY     VARCHAR2
) IS
  l_api_name      CONSTANT VARCHAR2(30)   := 'update_status_to_completed';
  l_api_version   CONSTANT NUMBER         := 1.0;
  l_encoded       VARCHAR2(1)             := FND_API.G_FALSE;
  l_status        NUMBER;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT   update_status_to_completed_sp;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

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
  END;

  -- Signify Success
  IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
  THEN
      FND_MESSAGE.SET_NAME('IES', 'IES_STATUS_UPDATE_SUCCESS');
      FND_MSG_PUB.Add;
  END IF;

  -- End of API body

  -- Standard check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO update_status_to_completed_sp;
  x_return_status := FND_API.G_RET_STS_ERROR;

  FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO update_status_to_completed_sp;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  FND_MSG_PUB.Count_And_Get
     (   p_encoded       =>      l_encoded,
         p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
     );

WHEN OTHERS THEN
  ROLLBACK TO update_status_to_completed_sp;
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
    (   p_encoded       =>      l_encoded,
        p_count         =>      x_msg_count,
        p_data          =>      x_msg_data
    );

END update_status_to_completed;

END ies_transaction_util_pub;

/
