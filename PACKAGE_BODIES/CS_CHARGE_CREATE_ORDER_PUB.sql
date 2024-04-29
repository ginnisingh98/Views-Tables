--------------------------------------------------------
--  DDL for Package Body CS_CHARGE_CREATE_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHARGE_CREATE_ORDER_PUB" as
/* $Header: csxpchob.pls 120.2 2005/09/29 07:09:45 pkesani noship $ */

/*********** Global  Variables  ********************************/
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CS_Charge_Create_Order_PUB' ;


--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Submit_Order
--   Type    :  Public
--   Purpose :  This API is for submitting an order and a wrapper on
--              CS_Charge_Create_Order_PVT.Submit_Order procedure.
--              It is intended for use by all applications; contrast to Private API.
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version           IN      NUMBER     Required
--       p_init_msg_list         IN      VARCHAR2   Optional
--       p_commit                IN      VARCHAR2   Optional
--       p_validation_level      IN      NUMBER     Optional
--       p_incident_id           IN      NUMBER     Required
--       p_party_id              IN      NUMBER     Required
--       p_account_id            IN      NUMBER     Optional  see bug#2447927, changed p_account_id to optional param.
--       p_book_order_flag       IN      VARCHAR2   Optional
--	     p_submit_source	     IN	     VARCHAR2   Optional
--       p_submit_from_system    IN      VARCHAR2   Optional
--   OUT:
--       x_return_status         OUT    NOCOPY     VARCHAR2
--       x_msg_count             OUT    NOCOPY     NUMBER
--       x_msg_data              OUT    NOCOPY     VARCHAR2
--   Version : Current version 1.0
--   End of Comments
--
PROCEDURE Submit_Order(
    p_api_version           IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2,
    p_commit                IN      VARCHAR2,
    p_validation_level      IN      NUMBER,
    p_incident_id           IN      NUMBER,
    p_party_id              IN      NUMBER,
    p_account_id            IN      NUMBER,
    p_book_order_flag       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_submit_source	        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_submit_from_system    IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
)
IS
    l_api_name       CONSTANT  VARCHAR2(30) := 'Submit_Order' ;
    l_api_name_full  CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
    l_log_module     CONSTANT VARCHAR2(255) := 'cs.plsql.' || l_api_name_full || '.';
    l_api_version    CONSTANT  NUMBER       := 1.0 ;

    l_return_status      VARCHAR2(1) ;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);


BEGIN
    --  Standard Start of API Savepoint
    SAVEPOINT   CS_Charge_Create_Order_PUB;

    --  Standard Call to check API compatibility
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'Start time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS')
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_incident_id:' || p_incident_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_party_id:' || p_party_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_account_id:' || p_account_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_book_order_flag:' || p_book_order_flag
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_submit_source:' || p_submit_source
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_submit_from_system:' || p_submit_from_system
    );

  END IF;

    --
    -- API body
    --
    -- Local Procedure


  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE || 'Before call to :'
    , 'CS_Charge_Create_Order_PVT.Submit_Order'
    );
  END IF;
    -- dbms_output.put_line('Calling Charges Pvt');

    CS_Charge_Create_Order_PVT.Submit_Order(
                p_api_version           =>  p_api_version,
                p_init_msg_list         =>  p_init_msg_list,
                p_commit                =>  p_commit,
                p_validation_level      =>  p_validation_level,
                p_incident_id           =>  p_incident_id,
                p_party_id              =>  p_party_id,
                p_account_id            =>  p_account_id,
                p_book_order_flag       =>  p_book_order_flag,
	            p_submit_source	    	=>  p_submit_source,
		        p_submit_from_system	=>  p_submit_from_system,
                x_return_status         =>  l_return_status,
                x_msg_count             =>  l_msg_count,
                x_msg_data              =>  l_msg_data
                );

   -- dbms_output.put_line('Completed Calling Charges Pvt');

    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE || 'STS error:'
	    , 'Calling CS_Charge_Create_Order_PVT.Submit_Order failed'
	    );
	  END IF;
	--FND_MESSAGE.Set_Name('CS','CS_CHG_PROCEDURE_FAILED');
        --FND_MESSAGE.Set_Token('PROCEDURE','CS_Charge_Create_Order_PVT.Submit_Order');
        --FND_MSG_PUB.Add;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_statement, L_LOG_MODULE || 'Unexpected error:'
	    , 'Calling CS_Charge_Create_Order_PVT.Submit_Order failed'
	    );
	  END IF;
	--FND_MESSAGE.Set_Name('CS','CS_CHG_PROCEDURE_FAILED');
        --FND_MESSAGE.Set_Token('PROCEDURE','CS_Charge_Create_Order_PVT.Submit_Order');
        --FND_MSG_PUB.Add;
        x_msg_count := l_msg_count;
        x_msg_data := l_msg_data;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_statement, L_LOG_MODULE || 'After call:'
    , 'CS_Charge_Create_Order_PVT.Submit_Order'
    );
  END IF;

    --
    -- End of API body
    --

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

   IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
   THEN
     FND_LOG.String
     ( FND_LOG.level_statement, L_LOG_MODULE || 'End time:'
     , TO_CHAR(SYSDATE, 'HH24:MI:SSSSS')
     );
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO CS_Charge_Create_Order_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO CS_Charge_Create_Order_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                );
        WHEN OTHERS THEN
            ROLLBACK TO CS_Charge_Create_Order_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg
                    (   G_PKG_NAME,
                        l_api_name
                    );
            END IF;
            FND_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count,
                    p_data      =>      x_msg_data
                );
    END Submit_Order;

End CS_Charge_Create_Order_PUB;

/
