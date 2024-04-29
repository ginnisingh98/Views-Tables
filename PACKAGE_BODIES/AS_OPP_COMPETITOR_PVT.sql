--------------------------------------------------------
--  DDL for Package Body AS_OPP_COMPETITOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_COMPETITOR_PVT" as
/* $Header: asxvcmpb.pls 120.1 2005/06/14 02:59:58 appldev  $ */
-- Start of Comments
-- Package name     : AS_OPP_COMPETITOR_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_OPP_COMPETITOR_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvop5b.pls';

-- Hint: Primary key needs to be returned.
PROCEDURE Create_competitors(
     P_Api_Version_Number      IN   NUMBER,
	P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
	P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
	p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
	P_Admin_Group_Id          IN   NUMBER,
	P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
	P_Competitor_Tbl          IN   AS_OPPORTUNITY_PUB.Competitor_Tbl_Type :=
						 AS_OPPORTUNITY_PUB.G_MISS_Competitor_Tbl,
	X_competitor_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.competitor_out_tbl_type,
	P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
	P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
	P_Identity_Salesforce_Id  IN   NUMBER      := NULL,
	P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
	X_Return_Status           OUT NOCOPY  VARCHAR2,
	X_Msg_Count               OUT NOCOPY  NUMBER,
	X_Msg_Data                OUT NOCOPY  VARCHAR2
)

 IS
    L_Api_Name                  CONSTANT VARCHAR2(30) := 'Create_Competitors';
    L_Api_Version_Number        CONSTANT NUMBER   := 2.0;
    L_Return_Status_Full        VARCHAR2(1);
    L_Identity_Sales_Member_Rec AS_SALES_MEMBER_PUB.Sales_Member_Rec_Type;
    L_Competitor_Rec            AS_OPPORTUNITY_PUB.Competitor_Rec_Type;
    L_LEAD_COMPETITOR_ID        NUMBER;
    L_LEAD_COMPETITOR           VARCHAR2(225);
    L_Line_Count                CONSTANT NUMBER := P_Competitor_Tbl.count;
    L_Access_Profile_Rec        AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
    L_Item_Property_Rec         AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
    L_Access_Flag               VARCHAR2(1);
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.cmppv.Create_competitors';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_COMPETITORS_PVT;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

/*
      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_competitors_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Competitor_Rec      =>  P_Competitor_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/


      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +',
                                   'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL ) THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);
	 END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
          p_profile_tbl         => p_profile_tbl,
          x_access_profile_rec  => l_access_profile_rec);

	 -- Access checking
      IF ( p_check_access_flag = 'Y' )
	 THEN
          AS_ACCESS_PUB.Has_updateOpportunityAccess(
              p_api_version_number     => 2.0,
              p_init_msg_list          => p_init_msg_list,
              p_validation_level       => p_validation_level,
              p_access_profile_rec     => l_access_profile_rec,
              p_admin_flag             => p_admin_flag,
              p_admin_group_id         => p_admin_group_id,
              p_person_id              =>
                                l_identity_sales_member_rec.employee_person_id,
              p_opportunity_id         => l_Competitor_rec.LEAD_ID,
              p_check_access_flag      => 'Y',
              p_identity_salesforce_id => p_identity_salesforce_id,
              p_partner_cont_party_id  => NULL,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              x_update_access_flag       => l_access_flag);
      END IF;

	 IF l_access_flag <> 'Y' THEN
          AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
          'API_NO_UPDATE_PRIVILEGE');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      FOR l_curr_row IN 1..l_line_count LOOP
         X_competitor_out_tbl(l_curr_row).return_status :=
                                                   FND_API.G_RET_STS_SUCCESS ;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_COMPETITOR', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_competitor_rec := P_Competitor_Tbl(l_curr_row);

         IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL )
         THEN
            -- Debug message
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Private API: Validate_competitor');
	    END IF;


            -- Invoke validation procedures
            Validate_competitor(
                P_Init_Msg_List    => FND_API.G_FALSE,
                P_Validation_Level => p_validation_level,
                P_Validation_Mode  => AS_UTILITY_PVT.G_CREATE,
			 P_Competitor_Rec   => l_Competitor_Rec,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data
			 );
         END IF;

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling create table handler');

         END IF;

         l_LEAD_COMPETITOR_ID := l_Competitor_rec.LEAD_COMPETITOR_ID;

         -- Invoke table handler(AS_LEAD_COMPETITORS_PKG.Insert_Row)
         AS_LEAD_COMPETITORS_PKG.Insert_Row(
             px_LEAD_COMPETITOR_ID  => l_LEAD_COMPETITOR_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => SYSDATE,
             p_CREATED_BY  => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => l_Competitor_rec.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID =>l_Competitor_rec.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID  => l_Competitor_rec.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE  => l_Competitor_rec.PROGRAM_UPDATE_DATE,
             p_LEAD_ID  => l_Competitor_rec.LEAD_ID,
             p_COMPETITOR_CODE  => l_Competitor_rec.COMPETITOR_CODE,
             p_COMPETITOR  => l_Competitor_rec.COMPETITOR,
             p_PRODUCTS  => l_Competitor_rec.PRODUCTS,
             p_COMMENTS  => l_Competitor_rec.COMMENTS,
             p_ATTRIBUTE_CATEGORY  => l_Competitor_rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => l_Competitor_rec.ATTRIBUTE1,
             p_ATTRIBUTE2  => l_Competitor_rec.ATTRIBUTE2,
             p_ATTRIBUTE3  => l_Competitor_rec.ATTRIBUTE3,
             p_ATTRIBUTE4  => l_Competitor_rec.ATTRIBUTE4,
             p_ATTRIBUTE5  => l_Competitor_rec.ATTRIBUTE5,
             p_ATTRIBUTE6  => l_Competitor_rec.ATTRIBUTE6,
             p_ATTRIBUTE7  => l_Competitor_rec.ATTRIBUTE7,
             p_ATTRIBUTE8  => l_Competitor_rec.ATTRIBUTE8,
             p_ATTRIBUTE9  => l_Competitor_rec.ATTRIBUTE9,
             p_ATTRIBUTE10  => l_Competitor_rec.ATTRIBUTE10,
             p_ATTRIBUTE11  => l_Competitor_rec.ATTRIBUTE11,
             p_ATTRIBUTE12  => l_Competitor_rec.ATTRIBUTE12,
             p_ATTRIBUTE13  => l_Competitor_rec.ATTRIBUTE13,
             p_ATTRIBUTE14      => l_Competitor_rec.ATTRIBUTE14,
             p_ATTRIBUTE15      => l_Competitor_rec.ATTRIBUTE15,
             p_WIN_LOSS_STATUS  => l_Competitor_rec.WIN_LOSS_STATUS,
             p_COMPETITOR_RANK  => l_Competitor_rec.COMPETITOR_RANK,
	     p_RELATIONSHIP_PARTY_ID => l_Competitor_rec.RELATIONSHIP_PARTY_ID,
             p_COMPETITOR_ID    => l_Competitor_rec.COMPETITOR_ID);

         X_competitor_out_tbl(l_curr_row).LEAD_COMPETITOR_ID :=
                                                        l_LEAD_COMPETITOR_ID;
         X_competitor_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

      END LOOP;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_competitors_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Competitor_Rec      =>  P_Competitor_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_competitors;


PROCEDURE Update_competitors(
	P_Api_Version_Number      IN   NUMBER,
	P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
	P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
	p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
	P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
	P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
	P_Admin_Group_Id          IN   NUMBER,
	P_Identity_Salesforce_Id  IN   NUMBER,
	P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
	P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
	P_Competitor_Tbl          IN   AS_OPPORTUNITY_PUB.Competitor_Tbl_Type,
	X_competitor_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.competitor_out_tbl_type,
	X_Return_Status           OUT NOCOPY  VARCHAR2,
	X_Msg_Count               OUT NOCOPY  NUMBER,
	X_Msg_Data                OUT NOCOPY  VARCHAR2
)

 IS
    Cursor C_Get_competitor(c_LEAD_COMPETITOR_ID Number) IS
        Select LAST_UPDATE_DATE
        From  AS_LEAD_COMPETITORS
        WHERE LEAD_COMPETITOR_ID = c_LEAD_COMPETITOR_ID
        For Update NOWAIT;

    L_Api_Name                  CONSTANT VARCHAR2(30) := 'Update_competitors';
    L_Api_Version_Number        CONSTANT NUMBER   := 2.0;
    L_Identity_Sales_Member_Rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    L_Ref_Competitor_Rec        AS_OPPORTUNITY_PUB.Competitor_Rec_Type;
    L_Rowid                     ROWID;
    L_Competitor_Rec            AS_OPPORTUNITY_PUB.Competitor_Rec_Type;
    L_Line_Count                CONSTANT NUMBER := P_Competitor_Tbl.count;
    L_Access_Profile_Rec        AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
    L_Last_Update_Date          DATE;
    L_Access_Flag               VARCHAR2(1);
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.cmppv.Update_competitors';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_COMPETITORS_PVT;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
/*
      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_competitors_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Competitor_Rec      =>  P_Competitor_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/



      IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL )
	 THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
          p_profile_tbl         => p_profile_tbl,
          x_access_profile_rec  => l_access_profile_rec);

	 -- Access checking
      IF ( p_check_access_flag = 'Y' )
	 THEN
          AS_ACCESS_PUB.Has_updateOpportunityAccess(
              p_api_version_number     => 2.0,
              p_init_msg_list          => p_init_msg_list,
              p_validation_level       => p_validation_level,
              p_access_profile_rec     => l_access_profile_rec,
              p_admin_flag             => p_admin_flag,
              p_admin_group_id         => p_admin_group_id,
              p_person_id              =>
                                l_identity_sales_member_rec.employee_person_id,
              p_opportunity_id         => l_Competitor_rec.LEAD_ID,
              p_check_access_flag      => 'Y',
              p_identity_salesforce_id => p_identity_salesforce_id,
              p_partner_cont_party_id  => NULL,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              x_update_access_flag       => l_access_flag);
      END IF;

	 IF l_access_flag <> 'Y' THEN
          AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
          'API_NO_UPDATE_PRIVILEGE');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      FOR l_curr_row IN 1..l_line_count LOOP
         X_competitor_out_tbl(l_curr_row).return_status :=
                                                   FND_API.G_RET_STS_SUCCESS ;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_COMPETITOR', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_competitor_rec := P_Competitor_Tbl(l_curr_row);

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: - Open Cursor to Select');
	 END IF;


         Open C_Get_competitor( l_Competitor_rec.LEAD_COMPETITOR_ID);

         Fetch C_Get_competitor into l_last_update_date;

         If ( C_Get_competitor%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'competitor', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
         END IF;
         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: - Close Cursor');
	 END IF;

         Close     C_Get_competitor;

         If (l_Competitor_rec.last_update_date is NULL or
             l_Competitor_rec.last_update_date = FND_API.G_MISS_Date ) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
                 FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
                 FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
         End if;
         -- Check Whether record has been changed by someone else
         If (l_Competitor_rec.last_update_date <> l_last_update_date) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
                 FND_MESSAGE.Set_Token('INFO', 'competitor', FALSE);
                 FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
         End if;

         IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL )
         THEN
             -- Debug message
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'Private API: Validate_competitor');
	     END IF;


             -- Invoke validation procedures
             Validate_competitor(
                 p_init_msg_list    => FND_API.G_FALSE,
                 p_validation_level => p_validation_level,
                 p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
                 P_Competitor_Rec  =>  l_Competitor_Rec,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);
         END IF;

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling update table handler');
	 END IF;


         -- Invoke table handler(AS_LEAD_COMPETITORS_PKG.Update_Row)
         AS_LEAD_COMPETITORS_PKG.Update_Row(
             p_LEAD_COMPETITOR_ID  => l_Competitor_rec.LEAD_COMPETITOR_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => SYSDATE,
             p_CREATED_BY  => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => l_Competitor_rec.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID =>l_Competitor_rec.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID  => l_Competitor_rec.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE  => l_Competitor_rec.PROGRAM_UPDATE_DATE,
             p_LEAD_ID  => l_Competitor_rec.LEAD_ID,
             p_COMPETITOR_CODE  => l_Competitor_rec.COMPETITOR_CODE,
             p_COMPETITOR  => l_Competitor_rec.COMPETITOR,
             p_PRODUCTS  => l_Competitor_rec.PRODUCTS,
             p_COMMENTS  => l_Competitor_rec.COMMENTS,
             p_ATTRIBUTE_CATEGORY  => l_Competitor_rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => l_Competitor_rec.ATTRIBUTE1,
             p_ATTRIBUTE2  => l_Competitor_rec.ATTRIBUTE2,
             p_ATTRIBUTE3  => l_Competitor_rec.ATTRIBUTE3,
             p_ATTRIBUTE4  => l_Competitor_rec.ATTRIBUTE4,
             p_ATTRIBUTE5  => l_Competitor_rec.ATTRIBUTE5,
             p_ATTRIBUTE6  => l_Competitor_rec.ATTRIBUTE6,
             p_ATTRIBUTE7  => l_Competitor_rec.ATTRIBUTE7,
             p_ATTRIBUTE8  => l_Competitor_rec.ATTRIBUTE8,
             p_ATTRIBUTE9  => l_Competitor_rec.ATTRIBUTE9,
             p_ATTRIBUTE10  => l_Competitor_rec.ATTRIBUTE10,
             p_ATTRIBUTE11  => l_Competitor_rec.ATTRIBUTE11,
             p_ATTRIBUTE12  => l_Competitor_rec.ATTRIBUTE12,
             p_ATTRIBUTE13  => l_Competitor_rec.ATTRIBUTE13,
             p_ATTRIBUTE14  => l_Competitor_rec.ATTRIBUTE14,
             p_ATTRIBUTE15      => l_Competitor_rec.ATTRIBUTE15,
             p_WIN_LOSS_STATUS  => l_Competitor_rec.WIN_LOSS_STATUS,
             p_COMPETITOR_RANK  => l_Competitor_rec.COMPETITOR_RANK,
	     p_RELATIONSHIP_PARTY_ID => l_Competitor_rec.RELATIONSHIP_PARTY_ID,
             p_COMPETITOR_ID    => l_Competitor_rec.COMPETITOR_ID);

         X_competitor_out_tbl(l_curr_row).LEAD_COMPETITOR_ID :=
                                       l_Competitor_rec.LEAD_COMPETITOR_ID;
         X_competitor_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

      END LOOP;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_competitors_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Competitor_Rec      =>  P_Competitor_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_competitors;


-- Hint: Add corresponding delete detail table procedures if it's master-detail
--       relationship.
--       The Master delete procedure may not be needed depends on different
--       business requirements.
PROCEDURE Delete_competitors(
	P_Api_Version_Number      IN   NUMBER,
	P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
	P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
	p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
	P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
	P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
	P_Admin_Group_Id          IN   NUMBER,
	P_Identity_Salesforce_Id  IN   NUMBER,
	P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
	P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
	P_Competitor_Tbl          IN   AS_OPPORTUNITY_PUB.Competitor_Tbl_Type,
	X_competitor_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.competitor_out_tbl_type,
	X_Return_Status           OUT NOCOPY  VARCHAR2,
	X_Msg_Count               OUT NOCOPY  NUMBER,
	X_Msg_Data                OUT NOCOPY  VARCHAR2
	)

 IS

    L_Api_Name                  CONSTANT VARCHAR2(30) := 'Delete_competitors';
    L_Api_Version_Number        CONSTANT NUMBER   := 2.0;
    L_Identity_Sales_Member_Rec AS_SALES_MEMBER_PUB.Sales_Member_Rec_Type;
    L_Competitor_Rec            AS_OPPORTUNITY_PUB.Competitor_Rec_Type;
    L_Lead_Competitor_Id        NUMBER;
    L_Line_Count                CONSTANT NUMBER := P_Competitor_Tbl.count;
    L_Access_Profile_Rec        AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
    L_Access_Flag               VARCHAR2(1);
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.cmppv.Delete_competitors';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_COMPETITORS_PVT;

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
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_competitors_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Competitor_Rec      =>  P_Competitor_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

      IF ( p_validation_level = FND_API.G_VALID_LEVEL_FULL )
	 THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => p_identity_salesforce_id
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
          p_profile_tbl         => p_profile_tbl,
          x_access_profile_rec  => l_access_profile_rec);

	 -- Access checking
      IF ( p_check_access_flag = 'Y' )
	 THEN
          AS_ACCESS_PUB.Has_updateOpportunityAccess(
              p_api_version_number     => 2.0,
              p_init_msg_list          => p_init_msg_list,
              p_validation_level       => p_validation_level,
              p_access_profile_rec     => l_access_profile_rec,
              p_admin_flag             => p_admin_flag,
              p_admin_group_id         => p_admin_group_id,
              p_person_id              =>
                                l_identity_sales_member_rec.employee_person_id,
              p_opportunity_id         => l_Competitor_rec.LEAD_ID,
              p_check_access_flag      => 'Y',
              p_identity_salesforce_id => p_identity_salesforce_id,
              p_partner_cont_party_id  => NULL,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              x_update_access_flag       => l_access_flag);
      END IF;

	 IF l_access_flag <> 'Y' THEN
          AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
          'API_NO_UPDATE_PRIVILEGE');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      FOR l_curr_row IN 1..l_line_count LOOP
         X_competitor_out_tbl(l_curr_row).return_status :=
                                                   FND_API.G_RET_STS_SUCCESS ;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_COMPETITOR', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_competitor_rec := P_Competitor_Tbl(l_curr_row);

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling delete table handler');
	 END IF;


             -- Invoke table handler(AS_LEAD_COMPETITORS_PKG.Delete_Row)
             AS_LEAD_COMPETITORS_PKG.Delete_Row(
                 p_LEAD_COMPETITOR_ID  => l_Competitor_rec.LEAD_COMPETITOR_ID);

         X_competitor_out_tbl(l_curr_row).LEAD_COMPETITOR_ID :=
                                                        l_LEAD_COMPETITOR_ID;
         X_competitor_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

      END LOOP;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_competitors_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Competitor_Rec      =>  P_Competitor_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_competitors;


-- Item-level validation procedures
PROCEDURE Validate_LEAD_COMPETITOR_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_COMPETITOR_ID         IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Lead_Competitor_Id_Exists (c_Lead_Competitor_Id NUMBER) IS
	 SELECT 'X'
	 FROM as_lead_competitors
	 WHERE lead_competitor_id = c_Lead_Competitor_Id;

  l_val   VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.cmppv.Validate_LEAD_COMPETITOR_ID';

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

          IF (p_LEAD_COMPETITOR_ID is not NULL) and (p_LEAD_COMPETITOR_ID <> FND_API.G_MISS_NUM)
		THEN
		    OPEN C_Lead_Competitor_Id_Exists (p_Lead_Competitor_Id);
		    FETCH C_Lead_Competitor_Id_Exists into l_val;

		    IF C_Lead_Competitor_Id_Exists%FOUND THEN
			   AS_UTILITY_PVT.Set_Message(
			       p_module        => l_module,
			       p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			       p_msg_name      => 'API_DUPLICATE_LEAD_COMPETITOR_ID');

			   x_return_status := FND_API.G_RET_STS_ERROR;
		    END IF;

              CLOSE C_Lead_Competitor_Id_Exists;
		END IF;

      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN

          IF (p_LEAD_COMPETITOR_ID is NULL) or (p_LEAD_COMPETITOR_ID = FND_API.G_MISS_NUM)
		THEN
		    AS_UTILITY_PVT.Set_Message(
			   p_module        => l_module,
			   p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_COMPETITOR_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
		    OPEN  C_Lead_Competitor_Id_Exists (p_Lead_Competitor_Id);
		    FETCH C_Lead_Competitor_Id_Exists into l_val;

		    IF C_Lead_Competitor_Id_Exists%NOTFOUND
		    THEN
		        AS_UTILITY_PVT.Set_Message(
			       p_module        => l_module,
			       p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			       p_msg_name      => 'API_INVALID_LEAD_COMPETITOR_ID',
			       p_token1        => 'VALUE',
			       p_token1_value  => p_LEAD_COMPETITOR_ID );

                  x_return_status := FND_API.G_RET_STS_ERROR;
		    END IF;

		    CLOSE C_Lead_Competitor_Id_Exists;
		END IF;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_COMPETITOR_ID;



PROCEDURE Validate_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_ID                    IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Lead_Id_Exists (c_Lead_Id NUMBER) IS
	 SELECT 'X'
	 FROM as_leads_all
	 WHERE lead_id = c_Lead_Id;

  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.cmppv.Validate_LEAD_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_LEAD_ID is NULL)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, 'ERROR',
               'Private API: Violate NOT NULL constraint(LEAD_ID)');
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF (p_LEAD_ID is NULL) or (p_LEAD_ID = FND_API.G_MISS_NUM)
      THEN
		AS_UTILITY_PVT.Set_Message(
		    p_module        => l_module,
		    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		    p_msg_name      => 'API_MISSING_LEAD_ID');

		x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
		OPEN  C_Lead_Id_Exists (p_Lead_Id);
		FETCH C_Lead_Id_Exists into l_val;

		IF C_Lead_Id_Exists%NOTFOUND
		THEN
		    AS_UTILITY_PVT.Set_Message(
		        p_module        => l_module,
		        p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		        p_msg_name      => 'API_INVALID_LEAD_ID',
		        p_token1        => 'VALUE',
		        p_token1_value  => p_LEAD_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

		CLOSE C_Lead_Id_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_ID;



PROCEDURE Validate_COMPETITOR_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COMPETITOR_ID              IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

  CURSOR C_COMPETITOR_Id_Exists (c_cmp_Id NUMBER) IS
	 SELECT 'X'
	 FROM HZ_PARTIES
	 WHERE party_id = c_cmp_Id
	 AND STATUS in ('A', 'I');

  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.cmppv.Validate_COMPETITOR_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_COMPETITOR_ID is NULL)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, 'ERROR',
               'Private API: Violate NOT NULL constraint(COMPETITOR_ID)');
	  END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF (p_COMPETITOR_ID is NOT NULL) and (p_COMPETITOR_ID <> FND_API.G_MISS_NUM)
      THEN

	  OPEN  C_COMPETITOR_Id_Exists (p_COMPETITOR_Id);
	  FETCH C_COMPETITOR_Id_Exists into l_val;

	  IF C_COMPETITOR_Id_Exists%NOTFOUND
	  THEN

	       AS_UTILITY_PVT.Set_Message(
			   p_module        => l_module,
			   p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			   p_msg_name      => 'API_INVALID_COMP_ID',
			   p_token1        => 'VALUE',
			   p_token1_value  => p_COMPETITOR_ID );

          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COMPETITOR_ID;

-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use
--       cursor to get old values for all fields used in inter-field validation
--       and set all G_MISS_XXX fields to original value stored in database
--       table.
PROCEDURE Validate_Competitor_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Competitor_Rec             IN   AS_OPPORTUNITY_PUB.Competitor_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.cmppv.Validate_Competitor_rec';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'API_INVALID_RECORD');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Competitor_Rec;


PROCEDURE Validate_competitor(
	P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
	P_Validation_Level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
	P_Validation_mode            IN   VARCHAR2,
	P_Competitor_Rec             IN   AS_OPPORTUNITY_PUB.Competitor_Rec_Type,
	X_Return_Status              OUT NOCOPY  VARCHAR2,
	X_Msg_Count                  OUT NOCOPY  NUMBER,
	X_Msg_Data                   OUT NOCOPY  VARCHAR2
	)
IS

l_api_name   CONSTANT VARCHAR2(30) := 'Validate_competitor';
l_Item_Property_Rec   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.cmppv.Validate_competitor';
 BEGIN

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer
          --       should delete unnecessary validation procedures.

          Validate_LEAD_COMPETITOR_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_COMPETITOR_ID     => P_Competitor_Rec.LEAD_COMPETITOR_ID,
              x_item_property_rec      => l_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


          Validate_LEAD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_ID                => P_Competitor_Rec.LEAD_ID,
              x_item_property_rec      => l_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;


          Validate_COMPETITOR_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COMPETITOR_ID          => P_Competitor_Rec.COMPETITOR_ID,
              x_item_property_rec      => l_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

	 /*
      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_Competitor_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_Competitor_Rec         => P_Competitor_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;
	 */

	 /*
      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;
	 */

	 /*
      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;
	 */


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
							'Private API: ' || l_api_name || ' end');
      END IF;

END Validate_competitor;

End AS_OPP_COMPETITOR_PVT;

/
