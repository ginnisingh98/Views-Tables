--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_PVT" as
/* $Header: iexvstrb.pls 120.1.12010000.3 2008/08/13 10:55:09 pnaveenk ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_STRATEGY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvstrb.pls';


-- Hint: Primary key needs to be returned.
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Create_strategy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_STRATEGY_Rec               IN    STRATEGY_Rec_Type,
    X_STRATEGY_ID                OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_strategy';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
v_strategy_id               iex_strategies.strategy_id%TYPE;
v_object_version_number     iex_strategies.object_version_number%TYPE;
v_rowid                    VARCHAR2(24);
v_strategy_level            iex_strategies.strategy_level%TYPE;


 Cursor c2 is SELECT IEX_STRATEGIES_S.nextval from dual;
 Cursor c3 is SELECT strategy_level from iex_strategy_templates_b
                where strategy_temp_id = p_STRATEGY_rec.STRATEGY_TEMPLATE_ID;
BEGIN

--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_STRATEGY_PVT.Create_STRATEGY ******** ');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_STRATEGY_PVT;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                           	               p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_strategy: ' || 'After Compatibility Check');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --
      -- API body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_strategy: ' || 'After Global user Check');
      END IF;

      --object version Number
      v_object_version_number :=1;
       -- get STRATEGY_id
       OPEN C2;
       FETCH C2 INTO v_STRATEGY_ID;
       CLOSE C2;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Create_strategy: ' || 'After STRATEGY ID Check and STRATEGY_id is => '||v_STRATEGY_id);
      END IF;

      /*
      -- get STRATEGY_level
       OPEN C3;
       FETCH C3 INTO v_STRATEGY_level;
       CLOSE C3;
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           IEX_DEBUG_PUB.LogMessage('Create_strategy: ' || 'After STRATEGY ID Check and STRATEGY_level is => '||v_STRATEGY_level);
        END IF;

	--delinquency Id check
        if (v_strategy_level = 3) then
          IF (p_STRATEGY_rec.delinquency_id IS NULL) THEN
  	        fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
		    fnd_message.set_token('API_NAME', l_api_name);
		    fnd_message.set_token('MISSING_PARAM', 'delinquency_id');
		    fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
	  END IF;
       end if;

       */
--		IF PG_DEBUG < 10  THEN
		IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
		   IEX_DEBUG_PUB.LogMessage ('Create_strategy: ' || 'After delinquency id check');
		END IF;

--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage('Create_strategy: ' || 'Before Calling iex_strategies_pkg.insert_row');
       END IF;

      -- Invoke table handler(IEX_STRATEGIES_PKG.Insert_Row)
      IEX_STRATEGIES_PKG.Insert_Row(
          x_rowid   =>v_rowid
         , x_STRATEGY_ID  => v_STRATEGY_id
         ,x_STATUS_CODE  => p_STRATEGY_rec.STATUS_CODE
         ,x_STRATEGY_TEMPLATE_ID  => p_STRATEGY_rec.STRATEGY_TEMPLATE_ID
         ,x_DELINQUENCY_ID  => p_STRATEGY_rec.DELINQUENCY_ID
         ,x_OBJECT_TYPE  => p_STRATEGY_rec.OBJECT_TYPE
         ,x_OBJECT_ID  => p_STRATEGY_rec.OBJECT_ID
         ,x_CUST_ACCOUNT_ID  => p_STRATEGY_rec.CUST_ACCOUNT_ID
         ,x_PARTY_ID  => p_STRATEGY_rec.PARTY_ID
         ,x_SCORE_VALUE  => p_STRATEGY_rec.SCORE_VALUE
         ,x_NEXT_WORK_ITEM_ID  => p_STRATEGY_rec.NEXT_WORK_ITEM_ID
         ,x_USER_WORK_ITEM_YN  => p_STRATEGY_rec.USER_WORK_ITEM_YN
         ,x_LAST_UPDATE_DATE  => SYSDATE
         ,x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,x_CREATION_DATE  => SYSDATE
         ,x_CREATED_BY  => FND_GLOBAL.USER_ID
         ,x_OBJECT_VERSION_NUMBER  => v_OBJECT_VERSION_NUMBER
         ,x_REQUEST_ID  => p_STRATEGY_rec.REQUEST_ID
         ,x_PROGRAM_APPLICATION_ID  => p_STRATEGY_rec.PROGRAM_APPLICATION_ID
         ,x_PROGRAM_ID  => p_STRATEGY_rec.PROGRAM_ID
         ,x_PROGRAM_UPDATE_DATE  => p_STRATEGY_rec.PROGRAM_UPDATE_DATE
         ,x_CHECKLIST_YN  => p_STRATEGY_rec.CHECKLIST_YN
         ,x_CHECKLIST_STRATEGY_ID  => p_STRATEGY_rec.CHECKLIST_STRATEGY_ID
         ,x_STRATEGY_LEVEL  => p_Strategy_Rec.Strategy_level
         ,x_JTF_OBJECT_TYPE  => p_STRATEGY_rec.JTF_OBJECT_TYPE
         ,x_JTF_OBJECT_id  => p_STRATEGY_rec.JTF_OBJECT_id
         ,x_CUSTOMER_SITE_USE_ID  => p_STRATEGY_rec.CUSTOMER_SITE_USE_ID
	 ,x_org_id => p_STRATEGY_rec.org_id --Bug# 6870773 Naveen
	    );


        x_STRATEGY_ID := v_STRATEGY_ID;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_STRATEGY_PVT.create_STRATEGY ******** ');
  END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_strategy;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_strategy(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_STRATEGY_Rec               IN    STRATEGY_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    XO_OBJECT_VERSION_NUMBER     OUT NOCOPY  NUMBER
    )

 IS
/*
Cursor C_Get_strategy(STRATEGY_ID Number) IS
    Select rowid,
           STRATEGY_ID,
           STATUS_CODE,
           STRATEGY_TEMPLATE_ID,
           DELINQUENCY_ID,
           OBJECT_TYPE,
           OBJECT_ID,
           CUST_ACCOUNT_ID,
           PARTY_ID,
           SCORE_VALUE,
           NEXT_WORK_ITEM_ID,
           USER_WORK_ITEM_YN,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN,
           CREATION_DATE,
           CREATED_BY,
           OBJECT_VERSION_NUMBER,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE
    From  IEX_STRATEGIES
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_strategy';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_object_version_number iex_strategies.object_version_number%TYPE:=p_strategy_rec.object_version_number;

BEGIN
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage ('********* Start of Procedure =>IEX_STRATEGY_PVT.update_STRATEGY ******** ');
    END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_STRATEGY_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('Update_strategy: ' || 'Before Calling iex_strategy_pkg.lock_row');
      END IF;
     -- Invoke table handler(IEX_strategies_PKG.lock_Row)

      -- call locking table handler
      IEX_STRATEGIES_PKG.lock_row (
         p_strategy_rec.strategy_id,
         l_object_version_number
      );


      -- Invoke table handler(IEX_STRATEGIES_PKG.Update_Row)
      IEX_STRATEGIES_PKG.Update_Row(
          x_STRATEGY_ID  => p_STRATEGY_rec.STRATEGY_ID
         ,x_STATUS_CODE  => p_STRATEGY_rec.STATUS_CODE
         ,x_STRATEGY_TEMPLATE_ID  => p_STRATEGY_rec.STRATEGY_TEMPLATE_ID
         ,x_DELINQUENCY_ID  => p_STRATEGY_rec.DELINQUENCY_ID
         ,x_OBJECT_TYPE  => p_STRATEGY_rec.OBJECT_TYPE
         ,x_OBJECT_ID  => p_STRATEGY_rec.OBJECT_ID
         ,x_CUST_ACCOUNT_ID  => p_STRATEGY_rec.CUST_ACCOUNT_ID
         ,x_PARTY_ID  => p_STRATEGY_rec.PARTY_ID
         ,x_SCORE_VALUE  => p_STRATEGY_rec.SCORE_VALUE
         ,x_NEXT_WORK_ITEM_ID  => p_STRATEGY_rec.NEXT_WORK_ITEM_ID
         ,x_USER_WORK_ITEM_YN  => p_STRATEGY_rec.USER_WORK_ITEM_YN
         ,x_LAST_UPDATE_DATE  => SYSDATE
         ,x_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID
         ,x_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID
         ,x_OBJECT_VERSION_NUMBER  => l_OBJECT_VERSION_NUMBER +1
         ,x_REQUEST_ID  => p_STRATEGY_rec.REQUEST_ID
         ,x_PROGRAM_APPLICATION_ID  => p_STRATEGY_rec.PROGRAM_APPLICATION_ID
         ,x_PROGRAM_ID  => p_STRATEGY_rec.PROGRAM_ID
         ,x_PROGRAM_UPDATE_DATE  => p_STRATEGY_rec.PROGRAM_UPDATE_DATE
         ,x_CHECKLIST_YN  => p_STRATEGY_rec.CHECKLIST_YN
         ,x_CHECKLIST_STRATEGY_ID  => p_STRATEGY_rec.CHECKLIST_STRATEGY_ID
         ,x_STRATEGY_LEVEL  => p_STRATEGY_rec.STRATEGY_level
         ,x_JTF_OBJECT_TYPE  => p_STRATEGY_rec.JTF_OBJECT_TYPE
         ,x_JTF_OBJECT_id  => p_STRATEGY_rec.JTF_OBJECT_id
         ,x_CUSTOMER_SITE_USE_ID  => p_STRATEGY_rec.CUSTOMER_SITE_USE_ID
	  ,x_ORG_id => p_STRATEGY_rec.ORG_id --Bug# 6870773 Naveen
	    );

       --Return Version number
      xo_object_version_number := l_object_version_number + 1;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_strategy_PVT.Update_strategy ******** ');
      END IF;
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_strategy;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_strategy(
     P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_STRATEGY_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2   )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_strategy';
l_api_version_number      CONSTANT NUMBER   := 2.0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_STRATEGY_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;




      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Invoke table handler(IEX_STRATEGIES_PKG.Delete_Row)
      IEX_STRATEGIES_PKG.Delete_Row(p_STRATEGY_ID);

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_strategy;
End IEX_STRATEGY_PVT;

/
