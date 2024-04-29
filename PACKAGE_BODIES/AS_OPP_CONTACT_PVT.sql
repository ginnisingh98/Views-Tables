--------------------------------------------------------
--  DDL for Package Body AS_OPP_CONTACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_CONTACT_PVT" as
/* $Header: asxvlcnb.pls 120.4 2006/08/10 11:29:18 mohali noship $ */
-- Start of Comments
-- Package name     : AS_OPP_CONTACT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_OPP_CONTACT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvop3b.pls';

-- Hint: Primary key needs to be returned.
PROCEDURE Create_opp_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   VARCHAR2    := FND_API.G_FALSE,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Contact_Tbl                IN   AS_OPPORTUNITY_PUB.Contact_Tbl_Type  :=
                                        AS_OPPORTUNITY_PUB.G_MISS_Contact_Tbl,
    X_contact_out_tbl            OUT NOCOPY  AS_OPPORTUNITY_PUB.contact_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Create_opp_contacts';
l_api_version_number        CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_CONTACT_Rec               AS_OPPORTUNITY_PUB.CONTACT_Rec_Type;
l_LEAD_CONTACT_ID           NUMBER;
l_line_count                CONSTANT NUMBER := P_CONTACT_Tbl.count;
l_update_access_flag         VARCHAR2(1);
l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Create_opp_contacts';

    Cursor  C_Get_Primary_Contact ( c_LEAD_ID NUMBER ) IS
       SELECT   lead_contact_id
       FROM     as_lead_contacts
       WHERE    lead_id = c_LEAD_ID
        --and	enabled_flag = 'Y' fix for 5285071
        and	primary_contact_flag = 'Y';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_CONTACTS_PVT;

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

      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      /*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_opp_contacts_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Contact_Rec      =>  P_Contact_Rec,
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

      IF(P_Check_Access_Flag = 'Y') THEN
    AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
                p_api_version_number    => 2.0
                ,p_init_msg_list        => p_init_msg_list
                ,p_salesforce_id    => p_identity_salesforce_id
                ,p_admin_group_id   => p_admin_group_id
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data
                ,x_sales_member_rec     => l_identity_sales_member_rec);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            IF l_debug THEN
               AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: Get_CurrentUser fail');
        END IF;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Call Get_Access_Profiles to get access_profile_rec
        AS_OPPORTUNITY_PUB.Get_Access_Profiles(
            p_profile_tbl         => p_profile_tbl,
            x_access_profile_rec  => l_access_profile_rec);

        AS_ACCESS_PUB.has_updateOpportunityAccess
         (   p_api_version_number   => 2.0
        ,p_init_msg_list        => p_init_msg_list
        ,p_validation_level     => p_validation_level
        ,p_access_profile_rec   => l_access_profile_rec
        ,p_admin_flag           => p_admin_flag
        ,p_admin_group_id   => p_admin_group_id
        ,p_person_id        => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id   => p_contact_tbl(1).LEAD_ID
        ,p_check_access_flag    => p_check_access_flag
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => p_partner_cont_party_id
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_update_access_flag   => l_update_access_flag );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'has_updateOpportunityAccess fail');
        END IF;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_update_access_flag <> 'Y') THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
            FND_MESSAGE.Set_Token('INFO', 'CUSTOMER_ID,OPPORTUNITY_ID,SALESFORCE_ID', FALSE);
            FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    END IF;
      END IF;

      FOR l_curr_row IN 1..l_line_count LOOP
         X_Contact_out_tbl(l_curr_row).return_status:=FND_API.G_RET_STS_SUCCESS;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_CONTACT', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_Contact_rec := P_Contact_Tbl(l_curr_row);

         -- Bug 3571569
         -- Initialize flag to 'N' if null
         IF(l_Contact_rec.PRIMARY_CONTACT_FLAG is NULL OR
            l_Contact_rec.PRIMARY_CONTACT_FLAG = FND_API.G_MISS_CHAR )
         THEN
            l_Contact_rec.PRIMARY_CONTACT_FLAG := 'N';
         END IF;

         -- Debug message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'Private API: Validate_opp_contact');
         END IF;

         -- Invoke validation procedures
         Validate_opp_contact(
                 p_init_msg_list    => FND_API.G_FALSE,
                 p_validation_level => p_validation_level,
                 p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
                 P_Contact_Rec  =>  l_Contact_Rec,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);


         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             -- Debug message
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: Validate_opp_Contact fail');
         END IF;
             RAISE FND_API.G_EXC_ERROR;
         END IF;


         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling create table handler');
         END IF;
	 -- the following condition and updation added for Bug#4641320
        IF l_Contact_rec.PRIMARY_CONTACT_FLAG = 'Y'
        THEN
            OPEN C_Get_Primary_Contact(l_Contact_rec.LEAD_ID);
            FETCH C_Get_Primary_Contact into l_lead_contact_id;

            IF C_Get_Primary_Contact%FOUND THEN
                UPDATE AS_LEAD_CONTACTS
                SET primary_contact_flag = 'N'
                WHERE lead_contact_id = l_lead_contact_id;
            END IF;
            CLOSE C_Get_Primary_Contact;
        END IF;

         l_LEAD_CONTACT_ID :=  l_Contact_rec.LEAD_CONTACT_ID;

         -- Invoke table handler(AS_LEAD_CONTACTS_PKG.Insert_Row)
         AS_LEAD_CONTACTS_PKG.Insert_Row(
             px_LEAD_CONTACT_ID  => l_LEAD_CONTACT_ID,
             p_LEAD_ID  => l_Contact_rec.LEAD_ID,
             p_CONTACT_ID  => l_Contact_rec.CONTACT_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => SYSDATE,
             p_CREATED_BY  => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => l_Contact_rec.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID  => l_Contact_rec.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID  => l_Contact_rec.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE  => l_Contact_rec.PROGRAM_UPDATE_DATE,
             p_ENABLED_FLAG  => l_Contact_rec.ENABLED_FLAG,
             p_CUSTOMER_ID  => l_Contact_rec.CUSTOMER_ID,
             p_ADDRESS_ID  => l_Contact_rec.ADDRESS_ID,
             p_RANK  => l_Contact_rec.RANK,
             p_PHONE_ID  => l_Contact_rec.PHONE_ID,
             p_ATTRIBUTE_CATEGORY  => l_Contact_rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => l_Contact_rec.ATTRIBUTE1,
             p_ATTRIBUTE2  => l_Contact_rec.ATTRIBUTE2,
             p_ATTRIBUTE3  => l_Contact_rec.ATTRIBUTE3,
             p_ATTRIBUTE4  => l_Contact_rec.ATTRIBUTE4,
             p_ATTRIBUTE5  => l_Contact_rec.ATTRIBUTE5,
             p_ATTRIBUTE6  => l_Contact_rec.ATTRIBUTE6,
             p_ATTRIBUTE7  => l_Contact_rec.ATTRIBUTE7,
             p_ATTRIBUTE8  => l_Contact_rec.ATTRIBUTE8,
             p_ATTRIBUTE9  => l_Contact_rec.ATTRIBUTE9,
             p_ATTRIBUTE10  => l_Contact_rec.ATTRIBUTE10,
             p_ATTRIBUTE11  => l_Contact_rec.ATTRIBUTE11,
             p_ATTRIBUTE12  => l_Contact_rec.ATTRIBUTE12,
             p_ATTRIBUTE13  => l_Contact_rec.ATTRIBUTE13,
             p_ATTRIBUTE14  => l_Contact_rec.ATTRIBUTE14,
             p_ATTRIBUTE15  => l_Contact_rec.ATTRIBUTE15,
             p_ORG_ID  => l_Contact_rec.ORG_ID,
             p_PRIMARY_CONTACT_FLAG  => l_Contact_rec.PRIMARY_CONTACT_FLAG,
             p_ROLE  => l_Contact_rec.ROLE,
             p_CONTACT_PARTY_ID  => l_Contact_rec.CONTACT_PARTY_ID);

         X_Contact_out_tbl(l_curr_row).LEAD_CONTACT_ID := l_LEAD_CONTACT_ID;
         X_Contact_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

    IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Private API: Created lead_contact_id = ' || l_LEAD_CONTACT_ID);
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
          AS_CALLOUT_PKG.Create_opp_contacts_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Contact_Rec      =>  P_Contact_Rec,
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
End Create_opp_contacts;


-- Hint: Add corresponding update detail table procedures if it's master-detail
-- relationship.
PROCEDURE Update_opp_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Contact_Tbl                IN   AS_OPPORTUNITY_PUB.Contact_Tbl_Type,
    X_contact_out_tbl            OUT NOCOPY  AS_OPPORTUNITY_PUB.contact_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
Cursor C_Get_opp_contact(c_LEAD_CONTACT_ID Number) IS
    Select LAST_UPDATE_DATE
    From  AS_LEAD_CONTACTS
    WHERE LEAD_CONTACT_ID = c_LEAD_CONTACT_ID
    For Update NOWAIT;
l_api_name                    CONSTANT VARCHAR2(30) := 'Update_opp_contacts';
l_api_version_number          CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
--l_ref_Contact_rec             AS_OPPORTUNITY_PUB.Contact_Rec_Type;
l_rowid                       ROWID;
l_Contact_Rec                 AS_OPPORTUNITY_PUB.Contact_Rec_Type;
l_line_count                  CONSTANT NUMBER := P_Contact_Tbl.count;
l_last_update_date      DATE;
l_update_access_flag         VARCHAR2(1);
l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Update_opp_contacts';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OPP_CONTACTS_PVT;

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
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_opp_contacts_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Contact_Rec      =>  P_Contact_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
      */

      IF(P_Check_Access_Flag = 'Y') THEN
    AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
                p_api_version_number    => 2.0
                ,p_init_msg_list        => p_init_msg_list
                ,p_salesforce_id    => p_identity_salesforce_id
                ,p_admin_group_id   => p_admin_group_id
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data
                ,x_sales_member_rec     => l_identity_sales_member_rec);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            IF l_debug THEN
               AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: Get_CurrentUser fail');
            END IF;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Call Get_Access_Profiles to get access_profile_rec
        AS_OPPORTUNITY_PUB.Get_Access_Profiles(
            p_profile_tbl         => p_profile_tbl,
            x_access_profile_rec  => l_access_profile_rec);

        AS_ACCESS_PUB.has_updateOpportunityAccess
         (   p_api_version_number   => 2.0
        ,p_init_msg_list        => p_init_msg_list
        ,p_validation_level     => p_validation_level
        ,p_access_profile_rec   => l_access_profile_rec
        ,p_admin_flag           => p_admin_flag
        ,p_admin_group_id   => p_admin_group_id
        ,p_person_id        => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id   => p_contact_tbl(1).LEAD_ID
        ,p_check_access_flag    => p_check_access_flag
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => p_partner_cont_party_id
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_update_access_flag   => l_update_access_flag );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'has_updateOpportunityAccess fail');
            END IF;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_update_access_flag <> 'Y') THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
            FND_MESSAGE.Set_Token('INFO', 'CUSTOMER_ID,OPPORTUNITY_ID,SALESFORCE_ID', FALSE);
            FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    END IF;
      END IF;


      FOR l_curr_row IN 1..l_line_count LOOP
         X_Contact_out_tbl(l_curr_row).return_status:=FND_API.G_RET_STS_SUCCESS;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_CONTACT', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_Contact_rec := P_Contact_Tbl(l_curr_row);

         -- Bug 3571569
         -- Initialize flag to 'N' if null
         IF(l_Contact_rec.PRIMARY_CONTACT_FLAG is NULL OR
            l_Contact_rec.PRIMARY_CONTACT_FLAG = FND_API.G_MISS_CHAR )
         THEN
            l_Contact_rec.PRIMARY_CONTACT_FLAG := 'N';
         END IF;

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: - Open Cursor to Select');

         END IF;

         Open C_Get_opp_contact( l_Contact_rec.LEAD_CONTACT_ID);

         Fetch C_Get_opp_contact into l_last_update_date;

         If ( C_Get_opp_contact%NOTFOUND) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
                 FND_MESSAGE.Set_Token ('INFO', 'opp_contact', FALSE);
                 FND_MSG_PUB.Add;
             END IF;
             raise FND_API.G_EXC_ERROR;
         END IF;

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: - Close Cursor');
         END IF;

         Close     C_Get_opp_contact;

         If (l_Contact_rec.last_update_date is NULL or
             l_Contact_rec.last_update_date = FND_API.G_MISS_Date ) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
                 FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
                 FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
         End if;
         -- Check Whether record has been changed by someone else
         If (l_Contact_rec.last_update_date <> l_last_update_date) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
                 FND_MESSAGE.Set_Token('INFO', 'opp_contact', FALSE);
                 FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
         End if;

         -- Debug message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Private API: Validate_opp_contact');

         END IF;
         -- Invoke validation procedures
         Validate_opp_contact(
                 p_init_msg_list    => FND_API.G_FALSE,
                 p_validation_level => p_validation_level,
                 p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
                 P_Contact_Rec  =>  l_Contact_Rec,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             -- Debug message
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API: Validate_opp_Contact fail');
             END IF;
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                       'Private API: Calling update table handler');

         END IF;
         -- Invoke table handler(AS_LEAD_CONTACTS_PKG.Update_Row)
         AS_LEAD_CONTACTS_PKG.Update_Row(
             p_LEAD_CONTACT_ID  => l_Contact_rec.LEAD_CONTACT_ID,
             p_LEAD_ID  => l_Contact_rec.LEAD_ID,
             p_CONTACT_ID  => l_Contact_rec.CONTACT_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => SYSDATE,
             p_CREATED_BY  => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => l_Contact_rec.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID  => l_Contact_rec.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID  => l_Contact_rec.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE  => l_Contact_rec.PROGRAM_UPDATE_DATE,
             p_ENABLED_FLAG  => l_Contact_rec.ENABLED_FLAG,
             p_CUSTOMER_ID  => l_Contact_rec.CUSTOMER_ID,
             p_ADDRESS_ID  => l_Contact_rec.ADDRESS_ID,
             p_RANK  => l_Contact_rec.RANK,
             p_PHONE_ID  => l_Contact_rec.PHONE_ID,
             p_ATTRIBUTE_CATEGORY  => l_Contact_rec.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => l_Contact_rec.ATTRIBUTE1,
             p_ATTRIBUTE2  => l_Contact_rec.ATTRIBUTE2,
             p_ATTRIBUTE3  => l_Contact_rec.ATTRIBUTE3,
             p_ATTRIBUTE4  => l_Contact_rec.ATTRIBUTE4,
             p_ATTRIBUTE5  => l_Contact_rec.ATTRIBUTE5,
             p_ATTRIBUTE6  => l_Contact_rec.ATTRIBUTE6,
             p_ATTRIBUTE7  => l_Contact_rec.ATTRIBUTE7,
             p_ATTRIBUTE8  => l_Contact_rec.ATTRIBUTE8,
             p_ATTRIBUTE9  => l_Contact_rec.ATTRIBUTE9,
             p_ATTRIBUTE10  => l_Contact_rec.ATTRIBUTE10,
             p_ATTRIBUTE11  => l_Contact_rec.ATTRIBUTE11,
             p_ATTRIBUTE12  => l_Contact_rec.ATTRIBUTE12,
             p_ATTRIBUTE13  => l_Contact_rec.ATTRIBUTE13,
             p_ATTRIBUTE14  => l_Contact_rec.ATTRIBUTE14,
             p_ATTRIBUTE15  => l_Contact_rec.ATTRIBUTE15,
             p_ORG_ID  => l_Contact_rec.ORG_ID,
             p_PRIMARY_CONTACT_FLAG  => l_Contact_rec.PRIMARY_CONTACT_FLAG,
             p_ROLE  => l_Contact_rec.ROLE,
             p_CONTACT_PARTY_ID  => l_Contact_rec.CONTACT_PARTY_ID);

         X_Contact_out_tbl(l_curr_row).LEAD_CONTACT_ID :=
                                              l_Contact_rec.LEAD_CONTACT_ID;
         X_Contact_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Private API: Updated lead_contact_id = ' ||l_Contact_rec.LEAD_CONTACT_ID );
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
          AS_CALLOUT_PKG.Update_opp_contacts_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Contact_Rec      =>  P_Contact_Rec,
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
End Update_opp_contacts;


PROCEDURE Delete_opp_contacts(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_identity_salesforce_id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Contact_Tbl                IN   AS_OPPORTUNITY_PUB.Contact_Tbl_Type,
    X_contact_out_tbl            OUT NOCOPY  AS_OPPORTUNITY_PUB.contact_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_opp_contacts';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_Contact_Rec                 AS_OPPORTUNITY_PUB.Contact_Rec_Type;
l_line_count                  CONSTANT NUMBER := P_Contact_Tbl.count;
l_update_access_flag         VARCHAR2(1);
l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Delete_opp_contacts';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_OPP_CONTACTS_PVT;

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
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_opp_contacts_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Contact_Rec      =>  P_Contact_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
      */

      IF(P_Check_Access_Flag = 'Y') THEN
    AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
                p_api_version_number    => 2.0
                ,p_init_msg_list        => p_init_msg_list
                ,p_salesforce_id    => p_identity_salesforce_id
                ,p_admin_group_id   => p_admin_group_id
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data
                ,x_sales_member_rec     => l_identity_sales_member_rec);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               IF l_debug THEN
               AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: Get_CurrentUser fail');
           END IF;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


        -- Call Get_Access_Profiles to get access_profile_rec
        AS_OPPORTUNITY_PUB.Get_Access_Profiles(
            p_profile_tbl         => p_profile_tbl,
            x_access_profile_rec  => l_access_profile_rec);

        AS_ACCESS_PUB.has_updateOpportunityAccess
         (   p_api_version_number   => 2.0
        ,p_init_msg_list        => p_init_msg_list
        ,p_validation_level     => p_validation_level
        ,p_access_profile_rec   => l_access_profile_rec
        ,p_admin_flag           => p_admin_flag
        ,p_admin_group_id   => p_admin_group_id
        ,p_person_id        => l_identity_sales_member_rec.employee_person_id
        ,p_opportunity_id   => p_contact_tbl(1).LEAD_ID
        ,p_check_access_flag    => p_check_access_flag
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => p_partner_cont_party_id
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_update_access_flag   => l_update_access_flag );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'has_updateOpportunityAccess fail');
        END IF;
            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_update_access_flag <> 'Y') THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AS', 'API_NO_UPDATE_PRIVILEGE');
            FND_MESSAGE.Set_Token('INFO', 'CUSTOMER_ID,OPPORTUNITY_ID,SALESFORCE_ID', FALSE);
            FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    END IF;
      END IF;


      FOR l_curr_row IN 1..l_line_count LOOP
         X_Contact_out_tbl(l_curr_row).return_status:=FND_API.G_RET_STS_SUCCESS;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_CONTACT', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_Contact_rec := P_Contact_Tbl(l_curr_row);


         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Private API: Calling delete table handler');

         END IF;
         -- Invoke table handler(AS_LEAD_CONTACTS_PKG.Delete_Row)
         AS_LEAD_CONTACTS_PKG.Delete_Row(
             p_LEAD_CONTACT_ID  => l_Contact_rec.LEAD_CONTACT_ID);

         X_Contact_out_tbl(l_curr_row).LEAD_CONTACT_ID :=
                                              l_Contact_rec.LEAD_CONTACT_ID;
         X_Contact_out_tbl(l_curr_row).return_status := x_return_status;

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
          AS_CALLOUT_PKG.Delete_opp_contacts_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Contact_Rec      =>  P_Contact_Rec,
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
End Delete_opp_contacts;



-- Item-level validation procedures
PROCEDURE Validate_LEAD_CONTACT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_CONTACT_ID            IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS


CURSOR  C_Lead_Contact_Id_Exists (c_Lead_Contact_Id NUMBER) IS
        SELECT 'X'
        FROM  as_lead_contacts
        WHERE lead_contact_id = c_Lead_Contact_Id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_LEAD_CONTACT_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Calling from Create API
      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          IF (p_LEAD_CONTACT_ID is NOT NULL) and (p_LEAD_CONTACT_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_Lead_Contact_Id_Exists (p_Lead_Contact_Id);
              FETCH C_Lead_Contact_Id_Exists into l_val;
              IF C_Lead_Contact_Id_Exists%FOUND THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                               'Private API: LEAD_CONTACT_ID exist');
                  END IF;

                  AS_UTILITY_PVT.Set_Message(
		  	      	p_module        => l_module,
		  	      	p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		  	      	p_msg_name      => 'AS_INVALID_ID',
		  	      	p_token1        => 'FIELD_ID',
              	  		p_token1_value  =>  'LEAD_CONTACT_ID');

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Lead_Contact_Id_Exists;
          END IF;

      -- Calling from Update API
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_LEAD_CONTACT_ID is NULL) or (p_LEAD_CONTACT_ID = FND_API.G_MISS_NUM)
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                          'Private API: Violate NOT NULL constraint(LEAD_CONTACT_ID)');
              END IF;

	      AS_UTILITY_PVT.Set_Message(
		  	      	p_module        => l_module,
		  	      	p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		  	      	p_msg_name      => 'AS_INVALID_ID',
		  	      	p_token1        => 'FIELD_ID',
              	  		p_token1_value  =>  'LEAD_CONTACT_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_Lead_Contact_Id_Exists (p_Lead_Contact_Id);
              FETCH C_Lead_Contact_Id_Exists into l_val;
              IF C_Lead_Contact_Id_Exists%NOTFOUND
              THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                         'Private API: LEAD_CONTACT_ID is not valid');
                  END IF;

		  AS_UTILITY_PVT.Set_Message(
		  	      	p_module        => l_module,
		  	      	p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		  	      	p_msg_name      => 'AS_INVALID_ID',
		  	      	p_token1        => 'FIELD_ID',
              	  		p_token1_value  =>  'LEAD_CONTACT_ID');

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Lead_Contact_Id_Exists;
          END IF;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_CONTACT_ID;


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
CURSOR  C_Lead_Id_Exists (c_Lead_Id NUMBER) IS
        SELECT 'X'
        FROM  as_leads
        WHERE lead_id = c_Lead_Id
    AND   nvl(DELETED_FLAG, 'N') <> 'Y';

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_LEAD_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF (p_LEAD_ID is NULL) or (p_LEAD_ID = FND_API.G_MISS_NUM)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                      'Private API: Violate NOT NULL constraint(LEAD_ID)');
          END IF;

	  AS_UTILITY_PVT.Set_Message(
	  	      		 p_module        => l_module,
	  	      		 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	  	      		 p_msg_name      => 'AS_INVALID_ID',
	  	      		 p_token1        => 'FIELD_ID',
              	  		 p_token1_value  =>  'LEAD_ID');

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          OPEN  C_Lead_Id_Exists (p_Lead_Id);
          FETCH C_Lead_Id_Exists into l_val;
          IF C_Lead_Id_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API: LEAD_ID is not valid');
              END IF;

	      AS_UTILITY_PVT.Set_Message(
	      		  	 p_module        => l_module,
	      		  	 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      		  	 p_msg_name      => 'AS_INVALID_ID',
	      		  	 p_token1        => 'FIELD_ID',
              	  		 p_token1_value  =>  'LEAD_ID');

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


PROCEDURE Validate_CONTACT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID        IN   NUMBER,
    P_CONTACT_ID                 IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_CONTACT_ID_Exists(c_contact_id NUMBER) IS
    SELECT 'X'
    FROM    AS_PARTY_ORG_CONTACTS_V
    WHERE   contact_id = c_contact_id
    AND customer_id = P_CUSTOMER_ID;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_CONTACT_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_CONTACT_ID is NOT NULL) and
         (p_CONTACT_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_CONTACT_ID_Exists (p_CONTACT_ID);
          FETCH C_CONTACT_ID_Exists into l_val;
          IF C_CONTACT_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: CONTACT_ID is invalid');
              END IF;

              AS_UTILITY_PVT.Set_Message(
	      	      		  	 p_module        => l_module,
	      	      		  	 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      	      		  	 p_msg_name      => 'AS_INVALID_ID',
	      	      		  	 p_token1        => 'FIELD_ID',
              	  		 	 p_token1_value  =>  'CONTACT_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_CONTACT_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CONTACT_ID;


PROCEDURE Validate_ENABLED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ENABLED_FLAG               IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_ENABLED_FLAG';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_ENABLED_FLAG is NULL OR
         p_ENABLED_FLAG = FND_API.G_MISS_CHAR )
      THEN
        --The following code commented by SUBABU for Bug#3537692(ASN)
      /*IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                      'Private API: Violate NOT NULL constraint(ENABLED_FLAG)');
          END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;*/
      NULL;
      ELSE
          IF (UPPER(p_ENABLED_FLAG) <> 'Y') and
             (UPPER(p_ENABLED_FLAG) <> 'N')
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                               'Private API: ENABLED_FLAG is invalid');

              END IF;

              AS_UTILITY_PVT.Set_Message(
	      	      	      		 p_module        => l_module,
                                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      	      	      		 p_msg_name      => 'AS_INVALID_ID',
	      	      	      		 p_token1        => 'FIELD_ID',
              	  		 	 p_token1_value  =>  'ENABLED_FLAG');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ENABLED_FLAG;


PROCEDURE Validate_CUSTOMER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID                IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
CURSOR  C_Customer_Id_Exists (c_Customer_Id NUMBER) IS
        SELECT 'X'
        FROM  AS_PARTY_CUSTOMERS_V
        WHERE customer_id = c_Customer_Id;

l_val   VARCHAR2(1);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_CUSTOMER_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF (p_CUSTOMER_ID is NULL) or (p_CUSTOMER_ID = FND_API.G_MISS_NUM)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                      'Private API: Violate NOT NULL constraint(CUSTOMER_ID)');
          END IF;

	  AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      	      	      	     p_module        => l_module,
	      	      	      	     p_msg_name      => 'AS_INVALID_ID',
	  	      	      	     p_token1        => 'FIELD_ID',
              	  		     p_token1_value  =>  'CUSTOMER_ID');

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          OPEN  C_Customer_Id_Exists (p_Customer_Id);
          FETCH C_Customer_Id_Exists into l_val;
          IF C_Customer_Id_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API: CUSTOMER_ID is not valid');
              END IF;

	      AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      	      	      	      	 p_module        => l_module,
	      	      	      	      	 p_msg_name      => 'AS_INVALID_ID',
	      	      	      	      	 p_token1        => 'FIELD_ID',
              	  		 	 p_token1_value  => 'CUSTOMER_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Customer_Id_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CUSTOMER_ID;


PROCEDURE Validate_ADDRESS_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID        IN   NUMBER,
    P_ADDRESS_ID                 IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_ADDRESS_ID_Exists(c_address_id NUMBER) IS
    SELECT 'X'
    FROM    AS_PARTY_ADDRESSES_V
    WHERE   address_id = c_address_id
    AND customer_id = P_CUSTOMER_ID;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_ADDRESS_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_ADDRESS_ID is NOT NULL) and
         (p_ADDRESS_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_ADDRESS_ID_Exists (p_ADDRESS_ID);
          FETCH C_ADDRESS_ID_Exists into l_val;
          IF C_ADDRESS_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: ADDRESS_ID is invalid');
              END IF;

	      AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      				 p_module        => l_module,
	      				 p_msg_name      => 'AS_INVALID_ID',
	      				 p_token1        => 'FIELD_ID',
              	  		 	 p_token1_value  =>  'ADDRESS_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_ADDRESS_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ADDRESS_ID;


PROCEDURE Validate_RANK (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RANK                       IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR C_RANK_Exists (c_RANK VARCHAR2) IS
        SELECT  'X'
        FROM  as_lookups
        WHERE lookup_type = 'CONTACT_RANK_ON_OPPORTUNITY'
          and lookup_code = c_RANK
          and enabled_flag = 'Y';

l_val VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_RANK';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_RANK is NOT NULL) and
         (p_RANK <> FND_API.G_MISS_CHAR)
      THEN
          -- RANK should exist in as_lookups
          OPEN  C_RANK_Exists ( p_RANK);
          FETCH C_RANK_Exists into l_val;
          IF C_RANK_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                  'Private API: RANK is invalid');
              END IF;

	      AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      	      			 p_module        => l_module,
	      	      			 p_msg_name      => 'AS_INVALID_ID',
	      	      			 p_token1        => 'FIELD_ID',
              	  		 	 p_token1_value  =>  'RANK');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_RANK_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_RANK;


PROCEDURE Validate_PHONE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CONTACT_ID         IN   NUMBER,
    P_CONTACT_PARTY_ID       IN   NUMBER,
    P_PHONE_ID                   IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR  C_PHONE_ID_Exists(c_phone_id NUMBER) IS
    SELECT 'X'
    FROM    AS_PARTY_PHONES_V
    WHERE   phone_id = c_phone_id
    AND     owner_table_name = 'HZ_PARTIES'
    AND owner_table_id = P_CONTACT_PARTY_ID;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_PHONE_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PHONE_ID is NOT NULL) and
         (p_PHONE_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_PHONE_ID_Exists (p_PHONE_ID);
          FETCH C_PHONE_ID_Exists into l_val;
          IF C_PHONE_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: PHONE_ID is invalid');
              END IF;

              AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      				 p_module        => l_module,
	      				 p_msg_name      => 'AS_INVALID_ID',
	      				 p_token1        => 'FIELD_ID',
              	  		 	 p_token1_value  =>  'PHONE_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_PHONE_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PHONE_ID;


PROCEDURE Validate_PRIMARY_CONTACT_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRIMARY_CONTACT_FLAG                IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_PRIMARY_CONTACT_FLAG';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_PRIMARY_CONTACT_FLAG is NULL OR
         p_PRIMARY_CONTACT_FLAG = FND_API.G_MISS_CHAR )
      THEN
      NULL;
      /* Not required item
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                      'Private API: Violate NOT NULL constraint(PRIMARY_CONTACT_FLAG)');
          x_return_status := FND_API.G_RET_STS_ERROR;
      */
      ELSE
          IF (UPPER(p_PRIMARY_CONTACT_FLAG) <> 'Y') and
             (UPPER(p_PRIMARY_CONTACT_FLAG) <> 'N')
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                               'Private API: PRIMARY_CONTACT_FLAG is invalid');

              END IF;

              AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      				 p_module        => l_module,
	      				 p_msg_name      => 'AS_INVALID_ID',
	      				 p_token1        => 'FIELD_ID',
              	  		 	 p_token1_value  =>  'PRIMARY_CONTACT_FLAG');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRIMARY_CONTACT_FLAG;


PROCEDURE Validate_CONTACT_PARTY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID                IN   NUMBER,
    p_LEAD_ID                    IN   NUMBER,  -- change for 5285071
    P_CONTACT_PARTY_ID           IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
CURSOR  C_CONTACT_PARTY_ID_Exists (c_CONTACT_PARTY_ID NUMBER) IS
        SELECT 'X'
        FROM  HZ_RELATIONSHIPS
        WHERE object_id = P_CUSTOMER_ID
    AND   party_id = c_CONTACT_PARTY_ID
        AND OBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND SUBJECT_TABLE_NAME = 'HZ_PARTIES'
    AND STATUS in ('A', 'I');

-- Cursor to check for duplicate contacts , bug 5285071
CURSOR C_Contact_party_id_dup( c_lead_id NUMBER, c_contact_party_id NUMBER) IS
        SELECT contact_party_id
        from as_lead_contacts
        where lead_id = c_lead_id
        and contact_party_id = c_contact_party_id;




l_dup NUMBER;
l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_CONTACT_PARTY_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_CONTACT_PARTY_ID is NULL) OR (p_CONTACT_PARTY_ID = FND_API.G_MISS_NUM)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                      'Private API: Violate NOT NULL CONTACT_PARTY_ID');
          END IF;

	  AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	  	      		     p_module        => l_module,
	  	      		     p_msg_name      => 'AS_INVALID_ID',
	  	      		     p_token1        => 'FIELD_ID',
              	  		     p_token1_value  =>  'CONTACT_PARTY_ID');

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF (p_CONTACT_PARTY_ID is not NULL) and (p_CONTACT_PARTY_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_CONTACT_PARTY_ID_Exists (p_CONTACT_PARTY_ID);
          FETCH C_CONTACT_PARTY_ID_Exists into l_val;
          IF C_CONTACT_PARTY_ID_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API: CONTACT_PARTY_ID is not valid');
              END IF;

	      AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      	  	      		 p_module        => l_module,
	      	  	      		 p_msg_name      => 'AS_INVALID_ID',
	      	  	      		 p_token1        => 'FIELD_ID',
              	  		         p_token1_value  =>  'CONTACT_PARTY_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_CONTACT_PARTY_ID_Exists;

        -- mohali changes for bug 5285071
         OPEN C_contact_party_id_dup(p_lead_id, p_contact_party_id);
            FETCH C_contact_party_id_dup into l_dup;
              IF C_contact_party_id_dup%FOUND and P_Validation_mode = AS_UTILITY_PVT.G_CREATE THEN
                 IF l_debug THEN
                    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API: CONTACT_PARTY_ID is Duplicate');
                 END IF;

	         AS_UTILITY_PVT.Set_Message(p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	      	  	      		 p_module        => l_module,
	      	  	      		 p_msg_name      => 'API_POSSIBLE_DUP_CONTACT',
	      	  	      		 p_token1        => 'CONTACT_ID',
              	  		         p_token1_value  =>  p_CONTACT_PARTY_ID,
                                         p_token2        => 'CONTACT_NAME',
              	  		         p_token2_value  =>  '');

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
            CLOSE C_contact_party_id_dup;
         -- end of changes for 5285071

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CONTACT_PARTY_ID;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use
--       cursor to get old values for all fields used in inter-field validation
--       and set all G_MISS_XXX fields to original value stored in database
--       table.
PROCEDURE Validate_Contact_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Contact_Rec     IN    AS_OPPORTUNITY_PUB.Contact_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_Contact_rec';
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
                                   'Private API: Validated Record');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Contact_Rec;

PROCEDURE Validate_opp_contact(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Contact_Rec                IN   AS_OPPORTUNITY_PUB.Contact_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Validate_opp_contact';
X_Item_Property_Rec     AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcnpv.Validate_opp_contact';
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
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validate items start');

          END IF;

          Validate_LEAD_CONTACT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_CONTACT_ID        => P_Contact_Rec.LEAD_CONTACT_ID,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated LEAD_CONTACT_ID ');

          END IF;

          Validate_LEAD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_ID                => P_Contact_Rec.LEAD_ID,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated LEAD_ID ');

          END IF;

          Validate_CUSTOMER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CUSTOMER_ID            => P_Contact_Rec.CUSTOMER_ID,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated CUSTOMER_ID ');
          END IF;


          Validate_ADDRESS_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CUSTOMER_ID            => P_Contact_Rec.CUSTOMER_ID,
              p_ADDRESS_ID             => P_Contact_Rec.ADDRESS_ID,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated ADDRESS_ID ');
          END IF;

          Validate_CONTACT_PARTY_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          p_CUSTOMER_ID        => P_Contact_Rec.CUSTOMER_ID,
	      p_LEAD_ID           =>    P_Contact_Rec.Lead_ID,
              p_CONTACT_PARTY_ID       => P_Contact_Rec.CONTACT_PARTY_ID,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated CONTACT_PARTY_ID');

          END IF;

          Validate_CONTACT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          p_CUSTOMER_ID        => P_Contact_Rec.CUSTOMER_ID,
              p_CONTACT_ID             => P_Contact_Rec.CONTACT_ID,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated CONTACT_ID ');

          END IF;

          Validate_PHONE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CONTACT_ID             => P_Contact_Rec.CONTACT_ID,
              p_CONTACT_PARTY_ID       => P_Contact_Rec.CONTACT_PARTY_ID,
              p_PHONE_ID               => P_Contact_Rec.PHONE_ID,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated PHONE_ID ');

          END IF;

          Validate_RANK(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_RANK                   => P_Contact_Rec.RANK_CODE,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated RANK ');

          END IF;

          Validate_ENABLED_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ENABLED_FLAG           => P_Contact_Rec.ENABLED_FLAG,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated ENABLED_FLAG ');

          END IF;

          Validate_PRIMARY_CONTACT_FLAG(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PRIMARY_CONTACT_FLAG   => P_Contact_Rec.PRIMARY_CONTACT_FLAG,
              x_item_property_rec      => x_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validated PRIMARY_CONTACT_FLAG ');

          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: Validate items end');
      END IF;

      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_Contact_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_Contact_Rec     =>    P_Contact_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_RECORD) THEN
          -- invoke inter-record level validation procedures
          NULL;
      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_INTER_ENTITY) THEN
          -- invoke inter-entity level validation procedures
          NULL;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' end');
      END IF;
END Validate_opp_contact;


End AS_OPP_CONTACT_PVT;

/
