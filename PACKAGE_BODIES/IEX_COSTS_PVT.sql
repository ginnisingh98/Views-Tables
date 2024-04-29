--------------------------------------------------------
--  DDL for Package Body IEX_COSTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_COSTS_PVT" as
/* $Header: iexvcosb.pls 120.1 2006/05/30 21:13:45 scherkas noship $ */
-- Start of Comments
-- Package name     : IEX_COSTS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



G_PKG_NAME CONSTANT VARCHAR2(30):= 'IEX_COSTS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvcosb.pls';


-- Hint: Primary key needs to be returned.
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE Create_costs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_costs_Rec                  IN    costs_Rec_Type  := G_MISS_costs_REC,
    X_COST_ID                    OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_costs';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full      VARCHAR2(1);
v_rowid                   VARCHAR2(24);
v_cost_id                 iex_costs.cost_id%TYPE;
v_object_version_number   iex_costs.object_version_number%TYPE;
v_active_flag             iex_costs.active_flag%TYPE;
v_cost_item_approved      iex_costs.cost_item_approved%TYPE;

Cursor c2 is SELECT IEX_COSTS_S.nextval from dual;
 BEGIN
--       IF PG_DEBUG < 10  THEN
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          IEX_DEBUG_PUB.LogMessage ('********* start of Procedure =>IEX_COSTS_PVT.Create_Costs ******** ');
       END IF;
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_COSTS_PVT;

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
         IEX_DEBUG_PUB.LogMessage('Create_costs: ' || 'After Compatibility Check');
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
         IEX_DEBUG_PUB.LogMessage('Create_costs: ' || 'After Global user Check');
      END IF;

      --IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

         --object version Number
         v_object_version_number :=1;
	    --Active_flag
	     v_active_flag :='Y';

        -- set cost_item_approved to 'Y'
        IF ((p_costs_rec.cost_item_approved IS NULL) OR
             (p_costs_rec.cost_item_approved = FND_API.G_MISS_CHAR)) THEN
            v_cost_item_approved :='Y';
	  ELSE
	    v_cost_item_approved :=p_costs_rec.cost_item_approved;
	  End if;

         -- get cost_id
         OPEN C2;
             FETCH C2 INTO v_cost_id;
         CLOSE C2;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('Create_costs: ' || 'After cost_id Check and cost_id is => '||v_cost_id);
         END IF;

         --check for case_id and delinquency id. Either one of them should be passed.
          IF ((p_costs_rec.case_id IS NULL) OR (p_costs_rec.case_ID = FND_API.G_MISS_NUM))
             AND
             ((p_costs_rec.delinquency_id IS NULL) OR (p_costs_rec.delinquency_ID = FND_API.G_MISS_NUM))
          THEN
              fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
              fnd_message.set_token('API_NAME', l_api_name);
              fnd_message.set_token('MISSING_PARAM', 'case_id/delinquency_id');
              fnd_msg_pub.add;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_costs: ' || 'After CASE ID and DELINQUENCY_ID Check ');
           END IF;

           --check for cost_type_code
           IF (p_costs_rec.cost_type_code IS NULL) OR (p_costs_rec.cost_type_code = FND_API.G_MISS_CHAR) THEN
               fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('MISSING_PARAM', 'cost_type_code');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_costs: ' || 'After cost_type_code Check ');
           END IF;

           --check for cost_item type_code
           IF (p_costs_rec.cost_item_type_code IS NULL) OR (p_costs_rec.cost_item_type_code = FND_API.G_MISS_CHAR) THEN
               fnd_message.set_name('IEX', 'IEX_API_ALL_MISSING_PARAM');
               fnd_message.set_token('API_NAME', l_api_name);
               fnd_message.set_token('MISSING_PARAM', 'cost_item_type_code');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_ERROR;
           END IF;
--           IF PG_DEBUG < 10  THEN
           IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
              IEX_DEBUG_PUB.LogMessage('Create_costs: ' || 'After cost_item_type_code Check ');
           END IF;


      -- Invoke table handler(IEX_COSTS_PKG.Insert_Row)
      IEX_COSTS_PKG.Insert_Row(
          x_rowid                     =>v_rowid,
          p_COST_ID                   => v_COST_ID,
          p_CASE_ID                   => p_costs_rec.CASE_ID,
          p_DELINQUENCY_ID            => p_costs_rec.DELINQUENCY_ID,
          p_COST_TYPE_CODE            => p_costs_rec.COST_TYPE_CODE,
          p_COST_ITEM_TYPE_CODE       => p_costs_rec.COST_ITEM_TYPE_CODE,
          p_COST_ITEM_TYPE_DESC       => p_costs_rec.COST_ITEM_TYPE_DESC,
          p_COST_ITEM_AMOUNT          => p_costs_rec.COST_ITEM_AMOUNT,
          p_COST_ITEM_CURRENCY_CODE   => p_costs_rec.COST_ITEM_CURRENCY_CODE,
          p_COST_ITEM_QTY             => p_costs_rec.COST_ITEM_QTY,
          p_COST_ITEM_DATE            => p_costs_rec.COST_ITEM_DATE,
          p_FUNCTIONAL_AMOUNT         => p_costs_rec.FUNCTIONAL_AMOUNT,
          p_EXCHANGE_TYPE             => p_costs_rec.EXCHANGE_TYPE,
          p_EXCHANGE_RATE             => p_costs_rec.EXCHANGE_RATE,
          p_EXCHANGE_DATE             => p_costs_rec.EXCHANGE_DATE,
          p_COST_ITEM_APPROVED        => v_COST_ITEM_APPROVED,
          p_ACTIVE_FLAG               => v_ACTIVE_FLAG,
          p_OBJECT_VERSION_NUMBER     => v_OBJECT_VERSION_NUMBER,
          p_CREATED_BY                => FND_GLOBAL.USER_ID,
          p_CREATION_DATE             => SYSDATE,
          p_LAST_UPDATED_BY           => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE          => SYSDATE,
          p_REQUEST_ID                => p_costs_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID    => p_costs_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID                => p_costs_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE       => p_costs_rec.PROGRAM_UPDATE_DATE,
          p_ATTRIBUTE_CATEGORY        => p_costs_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1                => p_costs_rec.ATTRIBUTE1,
          p_ATTRIBUTE2                => p_costs_rec.ATTRIBUTE2,
          p_ATTRIBUTE3                => p_costs_rec.ATTRIBUTE3,
          p_ATTRIBUTE4                => p_costs_rec.ATTRIBUTE4,
          p_ATTRIBUTE5                => p_costs_rec.ATTRIBUTE5,
          p_ATTRIBUTE6                => p_costs_rec.ATTRIBUTE6,
          p_ATTRIBUTE7                => p_costs_rec.ATTRIBUTE7,
          p_ATTRIBUTE8                => p_costs_rec.ATTRIBUTE8,
          p_ATTRIBUTE9                => p_costs_rec.ATTRIBUTE9,
          p_ATTRIBUTE10               => p_costs_rec.ATTRIBUTE10,
          p_ATTRIBUTE11               => p_costs_rec.ATTRIBUTE11,
          p_ATTRIBUTE12               => p_costs_rec.ATTRIBUTE12,
          p_ATTRIBUTE13               => p_costs_rec.ATTRIBUTE13,
          p_ATTRIBUTE14               => p_costs_rec.ATTRIBUTE14,
          p_ATTRIBUTE15               => p_costs_rec.ATTRIBUTE15,
          p_LAST_UPDATE_LOGIN         => p_costs_rec.LAST_UPDATE_LOGIN);


          x_COST_ID := v_COST_ID;

--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage('Create_costs: ' || 'After Calling IEX_COSTS_PKG.Insert_Row'
           ||' and cost id => ' ||v_cost_id);
          END IF;

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
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_COSTS_PVT.Create_costs ******** ');
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

End Create_costs;



PROCEDURE Update_costs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_costs_Rec                  IN    costs_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    xo_object_version_number     OUT NOCOPY NUMBER
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_COSTS';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_object_version_number   IEX_COSTS.object_version_number%TYPE
                                              :=p_COSTS_rec.object_version_number;
 BEGIN
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* start of Procedure =>IEX_COSTS_PVT.update_COSTS ******** ');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_COSTS_PVT;

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
     -- Invoke table handler(IEX_COSTS_PKG.Update_Row)
      -- call locking table handler
      IEX_COSTS_PKG.lock_row (
         p_COSTS_rec.cost_id,
         l_object_version_number
      );

      -- Invoke table handler(IEX_COSTS_PKG.Update_Row)
      IEX_COSTS_PKG.Update_Row(
          p_COST_ID                   => p_costs_rec.COST_ID,
          p_CASE_ID                   => p_costs_rec.CASE_ID,
          p_DELINQUENCY_ID            => p_costs_rec.DELINQUENCY_ID,
          p_COST_TYPE_CODE            => p_costs_rec.COST_TYPE_CODE,
          p_COST_ITEM_TYPE_CODE       => p_costs_rec.COST_ITEM_TYPE_CODE,
          p_COST_ITEM_TYPE_DESC       => p_costs_rec.COST_ITEM_TYPE_DESC,
          p_COST_ITEM_AMOUNT          => p_costs_rec.COST_ITEM_AMOUNT,
          p_COST_ITEM_CURRENCY_CODE   => p_costs_rec.COST_ITEM_CURRENCY_CODE,
          p_COST_ITEM_QTY             => p_costs_rec.COST_ITEM_QTY,
          p_COST_ITEM_DATE            => p_costs_rec.COST_ITEM_DATE,
          p_FUNCTIONAL_AMOUNT         =>p_costs_rec.FUNCTIONAL_AMOUNT,
          p_EXCHANGE_TYPE             => p_costs_rec.EXCHANGE_TYPE,
          p_EXCHANGE_RATE             => p_costs_rec.EXCHANGE_RATE,
          p_EXCHANGE_DATE             => p_costs_rec.EXCHANGE_DATE,
          p_COST_ITEM_APPROVED        => p_costs_rec.COST_ITEM_APPROVED,
          p_ACTIVE_FLAG               => p_costs_rec.ACTIVE_FLAG,
          p_OBJECT_VERSION_NUMBER     => l_OBJECT_VERSION_NUMBER +1,
          p_LAST_UPDATED_BY           => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE          => SYSDATE,
          p_REQUEST_ID                => p_costs_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID    => p_costs_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID                => p_costs_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE       => p_costs_rec.PROGRAM_UPDATE_DATE,
          p_ATTRIBUTE_CATEGORY        => p_costs_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1                => p_costs_rec.ATTRIBUTE1,
          p_ATTRIBUTE2                => p_costs_rec.ATTRIBUTE2,
          p_ATTRIBUTE3                => p_costs_rec.ATTRIBUTE3,
          p_ATTRIBUTE4                => p_costs_rec.ATTRIBUTE4,
          p_ATTRIBUTE5                => p_costs_rec.ATTRIBUTE5,
          p_ATTRIBUTE6                => p_costs_rec.ATTRIBUTE6,
          p_ATTRIBUTE7                => p_costs_rec.ATTRIBUTE7,
          p_ATTRIBUTE8                => p_costs_rec.ATTRIBUTE8,
          p_ATTRIBUTE9                => p_costs_rec.ATTRIBUTE9,
          p_ATTRIBUTE10               => p_costs_rec.ATTRIBUTE10,
          p_ATTRIBUTE11               => p_costs_rec.ATTRIBUTE11,
          p_ATTRIBUTE12               => p_costs_rec.ATTRIBUTE12,
          p_ATTRIBUTE13               => p_costs_rec.ATTRIBUTE13,
          p_ATTRIBUTE14               => p_costs_rec.ATTRIBUTE14,
          p_ATTRIBUTE15               => p_costs_rec.ATTRIBUTE15,
          p_LAST_UPDATE_LOGIN         => p_costs_rec.LAST_UPDATE_LOGIN);

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
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('********* end of Procedure =>IEX_COSTS_PVT.update_costs ******** ');
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
End Update_costs;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_costs(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_cost_id                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_costs';
l_api_version_number      CONSTANT NUMBER   := 2.0;

 BEGIN
--     IF PG_DEBUG < 10  THEN
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage ('********* start of Procedure =>IEX_COSTS_PVT.delete_costs ******** ');
     END IF;
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_COSTS_PVT;

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

      -- Invoke table handler(IEX_costsS_PKG.Delete_Row)
      IEX_COSTS_PKG.Delete_Row(
          p_COST_ID  => p_COST_ID);
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
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage ('********* End of Procedure =>IEX_COSTS_PVT.delete_costs ******** ');
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
End Delete_costs;
End IEX_costs_PVT;

/
