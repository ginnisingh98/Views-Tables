--------------------------------------------------------
--  DDL for Package Body AML_TIMEFRAME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_TIMEFRAME_PVT" as
/* $Header: amlvtfrb.pls 115.8 2004/01/20 20:39:34 chchandr noship $ */
-- Start of Comments
-- Package name     : AML_TIMEFRAME_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AML_TIMEFRAME_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlvtfrb.pls';


-- Hint: Primary key needs to be returned.
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Create_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN    AML_TIMEFRAME_PUB.timeframe_Rec_Type  ,
    X_TIMEFRAME_ID     OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_timeframe';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_access_flag               VARCHAR2(1);
l_timeframe_rec 	    AML_TIMEFRAME_PUB.timeframe_REC_TYPE;
l_dummy CHAR(1);


CURSOR c1 IS
      SELECT 'X' FROM AML_SALES_LEAD_TIMEFRAMES
      WHERE decision_timeframe_code = p_timeframe_rec.decision_timeframe_code
      AND enabled_flag = 'Y';


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_TIMEFRAME_PVT;

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


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_timeframe_rec := p_timeframe_rec;

      --
      -- API body
      --


      -- if p_timeframe_rec.enabled_flag is 'Y' then check for duplicates.

      if (p_timeframe_rec.ENABLED_FLAG = 'Y') then

      OPEN c1;
         FETCH c1 INTO l_dummy;
         IF c1%FOUND THEN
             CLOSE c1;
             --dbms_output.put_line('duplicate found ');
             FND_MESSAGE.SET_NAME('AS', 'AS_DUPE_TIMEFRAME');
             -- Add message to API message list
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c1;

      END IF;




      -- Debug message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Pvt API: ' || l_timeframe_rec.DECISION_TIMEFRAME_CODE);
      END IF;



      Validate_DECN_TIMEFRAME_CODE(
	   p_init_msg_list          => FND_API.G_FALSE,
	   p_validation_mode        => AS_UTILITY_PVT.G_CREATE,
	   p_decision_timeframe_code => l_timeframe_rec.DECISION_TIMEFRAME_CODE,
	   x_return_status          => x_return_status,
	   x_msg_count              => x_msg_count,
	   x_msg_data               => x_msg_data);
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   raise FND_API.G_EXC_ERROR;
     END IF;



     -- Check the timeframe days
     Validate_TIMEFRAME_DAYS(
         P_Init_Msg_List       => FND_API.G_FALSE,
         P_Validation_mode     => AS_UTILITY_PVT.G_CREATE,
         p_timeframe_days => l_timeframe_rec.timeframe_days,
         X_Return_Status       => x_return_status,
         X_Msg_Count           => x_msg_count,
         X_Msg_Data            => x_msg_data
         );

     IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
     END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(AML_SALES_LEAD_TIMEFRAMES_PKG.Insert_Row)
      AML_SALES_LEAD_TIMEFRAMES_PKG.Insert_Row(
          px_TIMEFRAME_ID  => x_TIMEFRAME_ID
         ,p_DECISION_TIMEFRAME_CODE  => l_timeframe_rec.DECISION_TIMEFRAME_CODE
         ,p_TIMEFRAME_DAYS  => l_timeframe_rec.TIMEFRAME_DAYS
         ,p_CREATION_DATE   => sysdate --l_timeframe_rec.CREATION_DATE
	 ,p_CREATED_BY  => FND_GLOBAL.USER_ID --l_timeframe_rec.CREATED_BY
	 ,p_LAST_UPDATE_DATE  => sysdate --l_timeframe_rec.LAST_UPDATE_DATE
	 ,p_LAST_UPDATED_BY => FND_GLOBAL.USER_ID -- l_timeframe_rec.LAST_UPDATED_BY
  	 ,p_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID --l_timeframe_rec.LAST_UPDATE_LOGIN
  	 , p_ENABLED_FLAG  =>  NVL(l_timeframe_rec.ENABLED_FLAG, 'N')



         );
      -- Hint: Primary key should be returned.
      -- x_TIMEFRAME_ID := px_TIMEFRAME_ID;

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


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
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
End Create_timeframe;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN    AML_TIMEFRAME_PUB.timeframe_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
/*
Cursor C_Get_timeframe(TIMEFRAME_ID Number) IS
    Select rowid,
           TIMEFRAME_ID,
           DECISION_TIMEFRAME_CODE,
           TIMEFRAME_DAYS
    From  AML_SALES_LEAD_TIMEFRAMES
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;
*/
l_api_name                CONSTANT VARCHAR2(30) := 'Update_timeframe';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_timeframe_rec  AML_timeframe_PUB.timeframe_Rec_Type;
l_tar_timeframe_rec  AML_timeframe_PUB.timeframe_Rec_Type := P_timeframe_Rec;
l_rowid  ROWID;
l_dummy CHAR(1);


CURSOR c1 IS
      SELECT 'X' FROM AML_SALES_LEAD_TIMEFRAMES
      WHERE decision_timeframe_code = p_timeframe_rec.decision_timeframe_code
      and timeframe_id <> p_timeframe_rec.timeframe_id
      AND enabled_flag = 'Y';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_TIMEFRAME_PVT;

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


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Private API: - Open Cursor to Select');
      END IF;


      If (l_tar_timeframe_rec.last_update_date is NULL or
          l_tar_timeframe_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_timeframe_rec.last_update_date <> l_ref_timeframe_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'timeframe', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Private API: Validate_timeframe');
      END IF;

      -- Invoke validation procedures



      --  Validate decision timeframe code.


      -- Validate timeframe days

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Private API: Validate_timeframe');

            END IF;



            Validate_DECN_TIMEFRAME_CODE(
      	   p_init_msg_list          => FND_API.G_FALSE,
      	   p_validation_mode        => AS_UTILITY_PVT.G_UPDATE,
      	   p_decision_timeframe_code => l_tar_timeframe_rec.DECISION_TIMEFRAME_CODE,
      	   x_return_status          => x_return_status,
      	   x_msg_count              => x_msg_count,
      	   x_msg_data               => x_msg_data);
             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	   raise FND_API.G_EXC_ERROR;
           END IF;



           -- Check the timeframe days
           Validate_TIMEFRAME_DAYS(
               P_Init_Msg_List       => FND_API.G_FALSE,
               P_Validation_mode     => AS_UTILITY_PVT.G_UPDATE,
               p_timeframe_days => l_tar_timeframe_rec.timeframe_days,
               X_Return_Status       => x_return_status,
               X_Msg_Count           => x_msg_count,
               X_Msg_Data            => x_msg_data
               );

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;



      if (p_timeframe_rec.ENABLED_FLAG = 'Y') then

      OPEN c1;
         FETCH c1 INTO l_dummy;
         IF c1%FOUND THEN
             CLOSE c1;
             --dbms_output.put_line('duplicate found ');
             FND_MESSAGE.SET_NAME('AS', 'AS_DUPE_TIMEFRAME');
             -- Add message to API message list
             FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c1;

      END IF;




      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(AML_SALES_LEAD_TIMEFRAMES_PKG.Update_Row)
      AML_SALES_LEAD_TIMEFRAMES_PKG.Update_Row(
          p_TIMEFRAME_ID  => p_timeframe_rec.TIMEFRAME_ID
         ,p_DECISION_TIMEFRAME_CODE  => p_timeframe_rec.DECISION_TIMEFRAME_CODE
         ,p_TIMEFRAME_DAYS  => p_timeframe_rec.TIMEFRAME_DAYS
         ,p_CREATION_DATE => p_timeframe_rec.CREATION_DATE
         ,p_CREATED_BY => p_timeframe_rec.CREATED_BY
         ,p_LAST_UPDATE_DATE   => sysdate
	 ,p_LAST_UPDATED_BY    => FND_GLOBAL.user_id
	 ,p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID --FND_GLOBAL.user_id
	 , p_ENABLED_FLAG	=>  NVL(p_timeframe_rec.ENABLED_FLAG, 'N')


         );
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
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
End Update_timeframe;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_timeframe(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2   := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2   := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_Profile_Tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_timeframe_Rec     IN AML_TIMEFRAME_PUB.timeframe_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_timeframe';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_TIMEFRAME_PVT;

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


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Do not allow deletion of seeded timeframes. Disabling them is fine

      if (p_timeframe_rec.TIMEFRAME_ID < 10000) then
                   FND_MESSAGE.SET_NAME('AS', 'AS_SEEDED_TIMEFRAME_NO_DELETE');
                   -- Add message to API message list
                   FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;

      end if;

      -- Do not allow deletion of enabled timeframes. Disabling them is fine

      if (p_timeframe_rec.ENABLED_FLAG = 'Y') then
                   FND_MESSAGE.SET_NAME('AS', 'AS_ENABLED_TIMEFRAME_NO_DELETE');
                   -- Add message to API message list
                   FND_MSG_PUB.Add;
             RAISE FND_API.G_EXC_ERROR;

      end if;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(AML_SALES_LEAD_TIMEFRAMES_PKG.Delete_Row)
      AML_SALES_LEAD_TIMEFRAMES_PKG.Delete_Row(
          p_TIMEFRAME_ID  => p_timeframe_rec.TIMEFRAME_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'end');
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
End Delete_timeframe;


-- Item-level validation procedures
PROCEDURE Validate_TIMEFRAME_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TIMEFRAME_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_TIMEFRAME_ID is not NULL and p_TIMEFRAME_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_TIMEFRAME_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TIMEFRAME_ID;



PROCEDURE Validate_DECN_TIMEFRAME_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_TIMEFRAME_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Lookup_Exists (X_Lookup_Code VARCHAR2, X_Lookup_Type VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = X_Lookup_Type
            and lookup_code = X_Lookup_Code
            -- ffang 012501
            and enabled_flag = 'Y';

    l_val  VARCHAR2(1);
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


	IF (p_decision_timeframe_code is NOT NULL
	    AND p_decision_timeframe_code <> FND_API.G_MISS_CHAR) THEN
	  OPEN C_Lookup_Exists ( p_decision_timeframe_code, 'DECISION_TIMEFRAME');
	  FETCH C_Lookup_Exists into l_val;

	  IF C_Lookup_Exists%NOTFOUND
	  THEN
	     AS_UTILITY_PVT.Set_Message(
		 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		 p_msg_name      => 'API_INVALID_ID',
		 p_token1        => 'COLUMN',
		 p_token1_value  => 'DECISION TIMEFRAME_CODE',
		 p_token2        => 'VALUE',
		 p_token2_value  =>  p_DECISION_TIMEFRAME_CODE );

	     x_return_status := FND_API.G_RET_STS_ERROR;
	  END IF;
	  CLOSE C_Lookup_Exists;
	END IF;




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DECN_TIMEFRAME_CODE;


PROCEDURE Validate_TIMEFRAME_DAYS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TIMEFRAME_DAYS                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_timeframe_days is NOT NULL
      	    AND p_timeframe_days < 0 ) THEN

      	     AS_UTILITY_PVT.Set_Message(
      		 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
      		 p_msg_name      => 'API_INVALID_ID',
      		 p_token1        => 'COLUMN',
      		 p_token1_value  => 'TIMEFRAME_DAYS',
      		 p_token2        => 'VALUE',
      		 p_token2_value  =>  p_TIMEFRAME_DAYS );

      	     x_return_status := FND_API.G_RET_STS_ERROR;
      	  END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_TIMEFRAME_DAYS;




End AML_TIMEFRAME_PVT;

/
