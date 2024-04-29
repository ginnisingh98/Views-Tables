--------------------------------------------------------
--  DDL for Package Body AS_DECISION_FACTOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_DECISION_FACTOR_PVT" as
/* $Header: asxvdfcb.pls 120.1 2005/06/14 01:34:18 appldev  $ */
-- Start of Comments
-- Package name     : AS_DECISION_FACTOR_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_DECISION_FACTOR_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvdfcb.pls';


-- Hint: Primary key needs to be returned.

PROCEDURE Create_decision_factors(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id          IN   NUMBER,
    P_Identity_Salesforce_Id  IN   NUMBER      := NULL,

    P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_decision_factor_Tbl          IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type :=
                                     AS_OPPORTUNITY_PUB.G_MISS_decision_factor_Tbl,
    X_decision_factor_out_tbl      OUT NOCOPY  as_opportunity_pub.decision_factor_out_tbl_type,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    )

IS
CURSOR G_lead_id(p_lead_line_id NUMBER) IS
	SELECT lead_id
	FROM	as_lead_lines_all
	WHERE lead_line_id = p_lead_line_id;

l_api_name                CONSTANT VARCHAR2(30) := 'Create_decision_factor';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full        VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_access_flag               VARCHAR2(1);
--P_Decision_Factor_Rec AS_OPPORTUNITY_PUB.Decision_Factor_Rec_Type;
l_decision_factor_rec AS_OPPORTUNITY_PUB.Decision_Factor_Rec_Type;
l_decision_factor_tbl AS_OPPORTUNITY_PUB.Decision_Factor_Tbl_Type;
l_count               CONSTANT NUMBER := P_decision_factor_tbl.count;
l_access_profile_rec	     AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_update_access_flag       VARCHAR2(1);
l_lead_id                  NUMBER;
l_curr_row                 NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Create_decision_factors';

BEGIN
           -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API1: ' || l_api_name || 'start');
      END IF;



      -- Standard Start of API savepoint
      SAVEPOINT CREATE_DECISION_FACTOR_PVT;

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
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API2: ' || l_api_name || 'start');
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
              FND_MESSAGE.Set_Name('AS', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => NULL
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API3: Get_CurrentUser fail');
		  END IF;

       	      END IF;
       	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF;

      -- Debug message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API4: Validate_decision_factor');
      END IF;


     IF(P_Check_Access_Flag = 'Y') THEN

        -- get lead id
         OPEN G_lead_id(P_decision_factor_tbl(1).LEAD_LINE_ID);
         FETCH G_lead_id INTO l_lead_id;
         CLOSE G_lead_id;

        -- Call Get_Access_Profiles to get access_profile_rec
        AS_OPPORTUNITY_PUB.Get_Access_Profiles(
            p_profile_tbl         => p_profile_tbl,
            x_access_profile_rec  => l_access_profile_rec);

 	AS_ACCESS_PUB.has_updateOpportunityAccess
	     (   p_api_version_number 	=> 2.0
		,p_init_msg_list     	=> p_init_msg_list
		,p_validation_level  	=> p_validation_level
		,p_access_profile_rec   => l_access_profile_rec
		,p_admin_flag	     	=> p_admin_flag
		,p_admin_group_id 	=> p_admin_group_id
		,p_person_id		=> l_identity_sales_member_rec.employee_person_id
		,p_opportunity_id	=> l_lead_id
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id => p_identity_salesforce_id
		,p_partner_cont_party_id  => p_partner_cont_party_id
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag );

      	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API5: has_updateOpportunityAccess fail');
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
	ELSE
	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API6: has_updateOpportunityAccess succeed');
		END IF;

       	    END IF;
   	END IF;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

    FOR l_curr_row in 1 .. l_count LOOP
        l_decision_factor_rec := P_decision_factor_Tbl(l_curr_row);

      -- Invoke validation procedures
      Validate_decision_factor(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_Decision_Factor_Rec  =>  l_decision_factor_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API7: Calling create table handler');
      END IF;

      -- Invoke table handler(AS_LEAD_DECISION_FACTORS_PKG.Insert_Row)
     AS_LEAD_DECISION_FACTORS_PKG.Insert_Row(
          --px_SECURITY_GROUP_ID  => x_SECURITY_GROUP_ID,
          p_ATTRIBUTE15  => l_Decision_Factor_rec.ATTRIBUTE15,
          p_ATTRIBUTE14  => l_Decision_Factor_rec.ATTRIBUTE14,
          p_ATTRIBUTE13  => l_Decision_Factor_rec.ATTRIBUTE13,
          p_ATTRIBUTE12  => l_Decision_Factor_rec.ATTRIBUTE12,
          p_ATTRIBUTE11  => l_Decision_Factor_rec.ATTRIBUTE11,
          p_ATTRIBUTE10  => l_Decision_Factor_rec.ATTRIBUTE10,
          p_ATTRIBUTE9  => l_Decision_Factor_rec.ATTRIBUTE9,
          p_ATTRIBUTE8  => l_Decision_Factor_rec.ATTRIBUTE8,
          p_ATTRIBUTE7  => l_Decision_Factor_rec.ATTRIBUTE7,
          p_ATTRIBUTE6  => l_Decision_Factor_rec.ATTRIBUTE6,
          p_ATTRIBUTE5  => l_Decision_Factor_rec.ATTRIBUTE5,
          p_ATTRIBUTE4  => l_Decision_Factor_rec.ATTRIBUTE4,
          p_ATTRIBUTE3  => l_Decision_Factor_rec.ATTRIBUTE3,
          p_ATTRIBUTE2  => l_Decision_Factor_rec.ATTRIBUTE2,
          p_ATTRIBUTE1  => l_Decision_Factor_rec.ATTRIBUTE1,
          p_ATTRIBUTE_CATEGORY  => l_Decision_Factor_rec.ATTRIBUTE_CATEGORY,
          p_PROGRAM_UPDATE_DATE  => l_Decision_Factor_rec.PROGRAM_UPDATE_DATE,
          p_PROGRAM_ID  => l_Decision_Factor_rec.PROGRAM_ID,
          p_PROGRAM_APPLICATION_ID  => l_Decision_Factor_rec.PROGRAM_APPLICATION_ID,
          p_REQUEST_ID  => l_Decision_Factor_rec.REQUEST_ID,
          p_DECISION_RANK  => l_Decision_Factor_rec.DECISION_RANK,
          p_DECISION_PRIORITY_CODE  => l_Decision_Factor_rec.DECISION_PRIORITY_CODE,
          p_DECISION_FACTOR_CODE  => l_Decision_Factor_rec.DECISION_FACTOR_CODE,
          px_LEAD_DECISION_FACTOR_ID  => l_Decision_Factor_rec.LEAD_DECISION_FACTOR_ID,
          p_LEAD_LINE_ID  => l_Decision_Factor_rec.LEAD_LINE_ID,
          p_CREATE_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_CREATION_DATE  => SYSDATE);

      -- Hint: Primary key should be returned.
      -- x_SECURITY_GROUP_ID := px_SECURITY_GROUP_ID;

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
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API8: ' || l_api_name || 'end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION

          WHEN DUP_VAL_ON_INDEX THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
              	  --FND_MESSAGE.Set_Name('AS', 'API_DUP_DECIS_FACTOR_CODE');
              	  --FND_MSG_PUB.ADD;
                  AS_UTILITY_PVT.Set_Message(
           	      p_module        => l_module,
           	      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
           	      p_msg_name      => 'API_DUP_DECIS_FACTOR_CODE',
                      p_token1        => 'VALUE',
                      p_token1_value  =>  l_Decision_Factor_rec.DECISION_FACTOR_CODE);

              END IF;

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);



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
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_decision_factors;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.

PROCEDURE Update_decision_factors(
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
    P_decision_factor_Tbl          IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type,
    X_decision_factor_out_tbl      OUT NOCOPY  as_opportunity_pub.decision_factor_out_tbl_type,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
)

 IS
CURSOR G_lead_id(p_lead_line_id NUMBER) IS
	SELECT lead_id
	FROM	as_lead_lines_all
	WHERE lead_line_id = p_lead_line_id;

l_Decision_Factor_Rec AS_OPPORTUNITY_PUB.Decision_Factor_Rec_Type;
l_Decision_Factor_Tbl AS_OPPORTUNITY_PUB.Decision_Factor_Tbl_Type;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_decision_factor';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
--l_ref_Decision_Factor_rec  AS_decision_factor_PVT.Decision_Factor_Rec_Type;
--l_tar_Decision_Factor_rec  AS_decision_factor_PVT.Decision_Factor_Rec_Type := P_Decision_Factor_Rec;
l_rowid  ROWID;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);
l_count               CONSTANT NUMBER := P_decision_factor_tbl.count;
l_curr_row            NUMBER;
l_access_profile_rec	     AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_update_access_flag  VARCHAR2(1);
l_lead_id             NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Update_decision_factors';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_DECISION_FACTOR_PVT;

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
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API9: ' || l_api_name || 'start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => NULL
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  IF l_debug THEN
              	    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Private API10: Get_CurrentUser fail');
		  END IF;

       	      END IF;
       	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF;

            IF(P_Check_Access_Flag = 'Y') THEN
               -- get lead id
               OPEN G_lead_id(P_decision_factor_tbl(1).LEAD_LINE_ID);
               FETCH G_lead_id INTO l_lead_id;
               CLOSE G_lead_id;

            -- Call Get_Access_Profiles to get access_profile_rec
            AS_OPPORTUNITY_PUB.Get_Access_Profiles(
                p_profile_tbl         => p_profile_tbl,
                x_access_profile_rec  => l_access_profile_rec);

 	        AS_ACCESS_PUB.has_updateOpportunityAccess
	        (   p_api_version_number 	=> 2.0
		       ,p_init_msg_list     	=> p_init_msg_list
		       ,p_validation_level  	=> p_validation_level
		       ,p_access_profile_rec   => l_access_profile_rec
		       ,p_admin_flag	     	=> p_admin_flag
		       ,p_admin_group_id 	=> p_admin_group_id
		       ,p_person_id		=> l_identity_sales_member_rec.employee_person_id
		       ,p_opportunity_id	=> l_lead_id
		       ,p_check_access_flag    => p_check_access_flag
		       ,p_identity_salesforce_id => p_identity_salesforce_id
		       ,p_partner_cont_party_id  => p_partner_cont_party_id
		       ,x_return_status	=> x_return_status
		       ,x_msg_count		=> x_msg_count
		       ,x_msg_data		=> x_msg_data
		       ,x_update_access_flag	=> l_update_access_flag );

      	   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                   IF l_debug THEN
                   AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			       'Private API11: has_updateOpportunityAccess fail');
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
	       ELSE
	       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API12: has_updateOpportunityAccess succeed');
		END IF;

       	    END IF;
   	     END IF;
    END IF;



      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API13: Calling update table handler');
      END IF;


            -- Invoke validation procedures
    FOR l_curr_row in 1 .. l_count LOOP
        l_decision_factor_rec := P_decision_factor_Tbl(l_curr_row);

        Validate_decision_factor(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_Decision_Factor_Rec  =>  l_Decision_Factor_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;


        -- Invoke table handler(AS_LEAD_DECISION_FACTORS_PKG.Update_Row)
        AS_LEAD_DECISION_FACTORS_PKG.Update_Row(
          p_ATTRIBUTE15  => l_Decision_Factor_rec.ATTRIBUTE15,
          p_ATTRIBUTE14  => l_Decision_Factor_rec.ATTRIBUTE14,
          p_ATTRIBUTE13  => l_Decision_Factor_rec.ATTRIBUTE13,
          p_ATTRIBUTE12  => l_Decision_Factor_rec.ATTRIBUTE12,
          p_ATTRIBUTE11  => l_Decision_Factor_rec.ATTRIBUTE11,
          p_ATTRIBUTE10  => l_Decision_Factor_rec.ATTRIBUTE10,
          p_ATTRIBUTE9  => l_Decision_Factor_rec.ATTRIBUTE9,
          p_ATTRIBUTE8  => l_Decision_Factor_rec.ATTRIBUTE8,
          p_ATTRIBUTE7  => l_Decision_Factor_rec.ATTRIBUTE7,
          p_ATTRIBUTE6  => l_Decision_Factor_rec.ATTRIBUTE6,
          p_ATTRIBUTE5  => l_Decision_Factor_rec.ATTRIBUTE5,
          p_ATTRIBUTE4  => l_Decision_Factor_rec.ATTRIBUTE4,
          p_ATTRIBUTE3  => l_Decision_Factor_rec.ATTRIBUTE3,
          p_ATTRIBUTE2  => l_Decision_Factor_rec.ATTRIBUTE2,
          p_ATTRIBUTE1  => l_Decision_Factor_rec.ATTRIBUTE1,
          p_ATTRIBUTE_CATEGORY  => l_Decision_Factor_rec.ATTRIBUTE_CATEGORY,
          p_PROGRAM_UPDATE_DATE  => l_Decision_Factor_rec.PROGRAM_UPDATE_DATE,
          p_PROGRAM_ID  => l_Decision_Factor_rec.PROGRAM_ID,
          p_PROGRAM_APPLICATION_ID  => l_Decision_Factor_rec.PROGRAM_APPLICATION_ID,
          p_REQUEST_ID  => l_Decision_Factor_rec.REQUEST_ID,
          p_DECISION_RANK  => l_Decision_Factor_rec.DECISION_RANK,
          p_DECISION_PRIORITY_CODE  => l_Decision_Factor_rec.DECISION_PRIORITY_CODE,
          p_DECISION_FACTOR_CODE  => l_Decision_Factor_rec.DECISION_FACTOR_CODE,
          p_LEAD_DECISION_FACTOR_ID  => l_Decision_Factor_rec.LEAD_DECISION_FACTOR_ID,
          p_LEAD_LINE_ID  => l_Decision_Factor_rec.LEAD_LINE_ID,
          p_CREATE_BY  => l_Decision_Factor_rec.CREATE_BY,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_CREATION_DATE  => l_Decision_Factor_rec.CREATION_DATE);

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
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API14: ' || l_api_name || 'end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION

	     WHEN DUP_VAL_ON_INDEX THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
              	  --FND_MESSAGE.Set_Name('AS', 'API_DUP_DECIS_FACTOR_CODE');
              	  --FND_MSG_PUB.ADD;
                   AS_UTILITY_PVT.Set_Message(
           	      p_module        => l_module,
           	      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
           	      p_msg_name      => 'API_DUP_DECIS_FACTOR_CODE',
                      p_token1        => 'VALUE',
                      p_token1_value  =>  l_Decision_Factor_rec.DECISION_FACTOR_CODE);

              END IF;

              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


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
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_decision_factors;

-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.

PROCEDURE Delete_decision_factors(
    P_Api_Version_Number      IN   NUMBER,
    P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id          IN   NUMBER,
    P_identity_salesforce_id  IN   NUMBER      := NULL,
    P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
    P_decision_factor_Tbl          IN   As_Opportunity_Pub.Decision_Factor_Tbl_Type,
    X_decision_factor_out_tbl      OUT NOCOPY  as_opportunity_pub.decision_factor_out_tbl_type,
    X_Return_Status           OUT NOCOPY  VARCHAR2,
    X_Msg_Count               OUT NOCOPY  NUMBER,
    X_Msg_Data                OUT NOCOPY  VARCHAR2
    )
 IS
CURSOR G_lead_id(p_lead_line_id NUMBER) IS
	SELECT lead_id
	FROM	as_lead_lines_all
	WHERE lead_line_id = p_lead_line_id;
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_decision_factor';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_Decision_Factor_Rec AS_OPPORTUNITY_PUB.Decision_Factor_Rec_Type;
l_Decision_Factor_Tbl AS_OPPORTUNITY_PUB.Decision_Factor_Tbl_Type;
l_rowid  ROWID;
l_return_status_full        VARCHAR2(1);
l_access_flag               VARCHAR2(1);
l_count               CONSTANT NUMBER := P_decision_factor_tbl.count;
l_curr_row            NUMBER;
l_access_profile_rec	     AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_update_access_flag  VARCHAR2(1);
l_lead_id             NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Delete_decision_factors';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_DECISION_FACTOR_PVT;

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
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API15: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      IF p_validation_level = FND_API.G_VALID_LEVEL_FULL
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id => NULL
             ,p_admin_group_id => p_admin_group_id
             ,x_return_status => x_return_status
             ,x_msg_count => x_msg_count
             ,x_msg_data => x_msg_data
             ,x_sales_member_rec => l_identity_sales_member_rec);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API16: Get_CurrentUser fail');
		  END IF;

       	      END IF;
       	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END IF;

      IF(P_Check_Access_Flag = 'Y') THEN
               -- get lead id
               OPEN G_lead_id(P_decision_factor_tbl(1).LEAD_LINE_ID);
               FETCH G_lead_id INTO l_lead_id;
               CLOSE G_lead_id;

            -- Call Get_Access_Profiles to get access_profile_rec
            AS_OPPORTUNITY_PUB.Get_Access_Profiles(
                p_profile_tbl         => p_profile_tbl,
                x_access_profile_rec  => l_access_profile_rec);

 	        AS_ACCESS_PUB.has_updateOpportunityAccess
	        (   p_api_version_number 	=> 2.0
		       ,p_init_msg_list     	=> p_init_msg_list
		       ,p_validation_level  	=> p_validation_level
		       ,p_access_profile_rec   => l_access_profile_rec
		       ,p_admin_flag	     	=> p_admin_flag
		       ,p_admin_group_id 	=> p_admin_group_id
		       ,p_person_id		=> l_identity_sales_member_rec.employee_person_id
		       ,p_opportunity_id	=> l_lead_id
		       ,p_check_access_flag    => p_check_access_flag
		       ,p_identity_salesforce_id => p_identity_salesforce_id
		       ,p_partner_cont_party_id  => p_partner_cont_party_id
		       ,x_return_status	=> x_return_status
		       ,x_msg_count		=> x_msg_count
		       ,x_msg_data		=> x_msg_data
		       ,x_update_access_flag	=> l_update_access_flag );

      	   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                   IF l_debug THEN
                   AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			       'Private API17: has_updateOpportunityAccess fail');
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
	       ELSE
	       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API18: has_updateOpportunityAccess succeed');
		END IF;

       	    END IF;
   	     END IF;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API19: Calling delete table handler');
      END IF;


      FOR l_curr_row in 1 .. l_count LOOP
          l_decision_factor_rec := P_decision_factor_Tbl(l_curr_row);
          -- Invoke table handler(AS_LEAD_DECISION_FACTORS_PKG.Delete_Row)
          AS_LEAD_DECISION_FACTORS_PKG.Delete_Row(
             p_LEAD_DECISION_FACTOR_ID  => l_Decision_Factor_rec.LEAD_DECISION_FACTOR_ID);

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
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API20: ' || l_api_name || 'end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

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
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_decision_factors;

-- Item-level validation procedures
PROCEDURE Validate_REQUEST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REQUEST_ID                IN   NUMBER,
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
          -- IF p_REQUEST_ID is not NULL and p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_REQUEST_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_REQUEST_ID;


PROCEDURE Validate_DECISION_RANK (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_RANK                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT NOCOPY     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
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
          -- IF p_DECISION_RANK is not NULL and p_DECISION_RANK <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DECISION_RANK <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DECISION_RANK;


PROCEDURE Validate_DECISION_PRIOR_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_PRIORITY_CODE                IN   VARCHAR2,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
CURSOR 	C_Decis_Prior_Code_Exists (c_Decision_Priority_Code VARCHAR2) IS
     SELECT 'X'
     FROM  AS_LOOKUPS
     WHERE LOOKUP_TYPE = 'DECISION_PRIORITY_TYPE'
     AND  LOOKUP_CODE = c_Decision_Priority_Code;
l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Validate_DECISION_PRIOR_CODE';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (P_DECISION_PRIORITY_CODE is NOT NULL) and (P_DECISION_PRIORITY_CODE <> FND_API.G_MISS_CHAR)
      THEN
          OPEN  C_Decis_Prior_Code_Exists (P_DECISION_PRIORITY_CODE);
          FETCH C_Decis_Prior_Code_Exists into l_val;
          IF C_Decis_Prior_Code_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Private API21: DECISION_PRIORITY_CODE is not valid:' ||P_DECISION_PRIORITY_CODE);
              END IF;


               AS_UTILITY_PVT.Set_Message(
                     p_module        => l_module,
                     p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name      => 'API_INVALID_DECISION_PRIORITY',
                     p_token1        => 'COLUMN',
                     p_token1_value  => 'DECISION_PRIORITY_CODE',
                     p_token2        => 'VALUE',
                     p_token2_value  =>  P_DECISION_PRIORITY_CODE );

               x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
           CLOSE C_Decis_Prior_Code_Exists;
      END IF;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DECISION_PRIOR_CODE;


PROCEDURE Validate_DECISION_FACTOR_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_FACTOR_CODE                IN   VARCHAR2,
    P_LEAD_LINE_ID               IN NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_Decis_Factor_Code_Exists (c_Decision_Factor_Code VARCHAR2) IS
     SELECT 'X'
     FROM  AS_LOOKUPS
     WHERE LOOKUP_TYPE = 'DECISION_FACTOR_TYPE'
     AND  LOOKUP_CODE = c_Decision_Factor_Code;
l_val   VARCHAR2(1);

CURSOR 	C_D_Decis_Factor_Code_Exists (c_Lead_Line_Id NUMBER) IS
     SELECT 'X'
     FROM  AS_LEAD_DECISION_FACTORS
     WHERE LEAD_LINE_ID = c_Lead_Line_Id;

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Validate_DECISION_FACTOR_CODE';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE) OR (p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN

     --     OPEN  C_D_Decis_Factor_Code_Exists (P_LEAD_LINE_ID);
     --     FETCH C_D_Decis_Factor_Code_Exists into l_val;
     --     IF C_D_Decis_Factor_Code_Exists%FOUND THEN
    --          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
     --                                      'Private API24: DECISION_FACTOR_CODE exist');

              --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                    --                      'Duplicate DECISION_FACTOR_CODE ');

	   --   AS_UTILITY_PVT.Set_Message(
           --   p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
           --   p_msg_name      => 'API_DUP_DECIS_FACTOR_CODE',
              --p_token1        => 'COLUMN',
              --p_token1_value  => '',
           --   p_token1        => 'VALUE',
           --   p_token1_value  =>  P_DECISION_FACTOR_CODE );

           --   x_return_status := FND_API.G_RET_STS_ERROR;
      --    END IF;
      --    CLOSE C_D_Decis_Factor_Code_Exists ;



          IF (P_DECISION_FACTOR_CODE is NULL) or (P_DECISION_FACTOR_CODE = FND_API.G_MISS_CHAR)
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Private API22: Violate NOT NULL constraint(DECISION_FACTOR_CODE)');
              END IF;


          AS_UTILITY_PVT.Set_Message(
              p_module        => l_module,
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'DECISION_FACTOR_CODE');

          x_return_status := FND_API.G_RET_STS_ERROR;
         ELSE
             OPEN  C_Decis_Factor_Code_Exists (P_DECISION_FACTOR_CODE);
             FETCH C_Decis_Factor_Code_Exists into l_val;
             IF C_Decis_Factor_Code_Exists%NOTFOUND
             THEN
                 IF l_debug THEN
                 AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'Private API23: DECISION_FACTOR_CODE is not valid:' ||
                                  P_DECISION_FACTOR_CODE);
                 END IF;


                 AS_UTILITY_PVT.Set_Message(
                     p_module        => l_module,
                     p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name      => 'API_INVALID_DECISION_FACTOR',
                     p_token1        => 'COLUMN',
                     p_token1_value  => 'DECISION_FACTOR_CODE',
                     p_token2        => 'VALUE',
                     p_token2_value  =>  P_DECISION_FACTOR_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Decis_Factor_Code_Exists;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DECISION_FACTOR_CODE;


PROCEDURE Validate_L_DECISION_FACTOR_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_DECISION_FACTOR_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_L_Decis_Factor_Id_Exists (c_Lead_Decision_Factor_Id NUMBER) IS
     SELECT 'X'
     FROM  AS_LEAD_DECISION_FACTORS
     WHERE LEAD_DECISION_FACTOR_ID = c_Lead_DECISION_FACTOR_ID;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Validate_L_DECISION_FACTOR_ID';

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
          IF (P_LEAD_DECISION_FACTOR_ID is NOT NULL) and (p_LEAD_DECISION_FACTOR_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_L_Decis_Factor_Id_Exists (P_LEAD_DECISION_FACTOR_ID);
              FETCH C_L_Decis_Factor_Id_Exists into l_val;
              IF C_L_Decis_Factor_Id_Exists%FOUND THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                               'Private API24: LEAD_LINE_ID exist');
                  END IF;

                  AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_DUP_DECIS_FACT_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'LEAD_DECISION_FACTOR_ID',
                  p_token2        => 'VALUE',
                  p_token2_value  =>  P_LEAD_DECISION_FACTOR_ID );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_L_Decis_Factor_Id_Exists;
          END IF;

      -- Calling from Update API
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (P_LEAD_DECISION_FACTOR_ID is NULL) or (P_LEAD_DECISION_FACTOR_ID = FND_API.G_MISS_NUM)
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'Private API25: Violate NOT NULL constraint(LEAD_DECISION_FACTOR_ID)');
	      END IF;

              AS_UTILITY_PVT.Set_Message(
              p_module        => l_module,
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'LEAD_DECISION_FACTOR_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_L_Decis_Factor_Id_Exists (P_Lead_DECISION_FACTOR_ID);
              FETCH C_L_Decis_Factor_Id_Exists into l_val;
              IF C_L_Decis_Factor_Id_Exists%NOTFOUND
              THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Private API26: LEAD_DECISION_FACTOR_ID is not valid');
		  END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_DECIS_FACT_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'LEAD_DECISION_FACTOR_ID',
                  p_token2        => 'VALUE',
                  p_token2_value  =>  P_LEAD_DECISION_FACTOR_ID );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_L_Decis_Factor_Id_Exists;
          END IF;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


END Validate_L_DECISION_FACTOR_ID;


PROCEDURE Validate_LEAD_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_LINE_ID                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_Lead_Line_Id_Exists (c_Lead_Line_Id NUMBER) IS
     SELECT 'X'
     FROM  AS_LEAD_LINES
     WHERE LEAD_LINE_ID = c_Lead_Line_Id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Validate_LEAD_LINE_ID';

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (P_LEAD_LINE_ID is NULL) or (P_LEAD_LINE_ID = FND_API.G_MISS_NUM)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Private API27: Violate NOT NULL constraint(LEAD_LINE_ID)');
          END IF;


          AS_UTILITY_PVT.Set_Message(
              p_module        => l_module,
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'LEAD_LINE_ID');

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          OPEN  C_Lead_Line_Id_Exists (P_LEAD_LINE_ID);
          FETCH C_Lead_Line_Id_Exists into l_val;
          IF C_Lead_Line_Id_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'Private API28: LEAD_LEAD_ID is not valid:' ||
                                  P_LEAD_LINE_ID);
	      END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_OPP_LEAD_LINE_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'LEAD_LINE_ID',
                  p_token2        => 'VALUE',
                  p_token2_value  =>  P_LEAD_LINE_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Lead_Line_Id_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END  Validate_LEAD_LINE_ID;


PROCEDURE Validate_CREATE_BY (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CREATE_BY                IN   NUMBER,
    -- Hint: You may add 'X_Item_Property_Rec  OUT     AS_UTILITY_PVT.ITEM_PROPERTY_REC_TYPE' here if you'd like to pass back item property.
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Validate_CREATE_BY';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_CREATE_BY is NULL)
      THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, 'ERROR', 'Private decision_factor API: -Violate NOT NULL constraint(CREATE_BY)');
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_CREATE_BY is not NULL and p_CREATE_BY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_CREATE_BY <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CREATE_BY;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.
PROCEDURE Validate_Decision_Factor_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Decision_Factor_Rec     IN    AS_OPPORTUNITY_PUB.Decision_Factor_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Validate_Decision_Factor_rec';
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
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'API_INVALID_RECORD');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Decision_Factor_Rec;

PROCEDURE Validate_decision_factor(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Decision_Factor_Rec     IN    AS_OPPORTUNITY_PUB.Decision_Factor_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_decision_factor';
x_item_property_rec   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
--x_return_status       VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.dfpv.Validate_decision_factor';
BEGIN

      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API29: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN

          Validate_DECISION_PRIOR_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DECISION_PRIORITY_CODE   => P_Decision_Factor_Rec.DECISION_PRIORITY_CODE,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          	                         'Private API30: Validated DECISION_PRIOR_CODE');
	  END IF;



          Validate_DECISION_FACTOR_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DECISION_FACTOR_CODE   => P_Decision_Factor_Rec.DECISION_FACTOR_CODE,
	      p_LEAD_LINE_ID           => P_Decision_Factor_Rec.LEAD_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
           END IF;
           IF l_debug THEN
           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API31: Validated DECISION_FACTOR_CODE');
	  END IF;


          Validate_L_DECISION_FACTOR_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_DECISION_FACTOR_ID   => P_Decision_Factor_Rec.LEAD_DECISION_FACTOR_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API32: Validated LEAD_DECISION_FACTOR_ID');
	  END IF;



          Validate_LEAD_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_LINE_ID   => P_Decision_Factor_Rec.LEAD_LINE_ID,
              -- Hint: You may add x_item_property_rec as one of your OUT parameter if you'd like to pass back item property.
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API33: Validated LEAD_LINE_ID');
	  END IF;




     END IF;

      /*IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_Decision_Factor_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_Decision_Factor_Rec     =>    P_Decision_Factor_Rec,
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
      */

      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API34: ' || l_api_name || 'end');
      END IF;

END Validate_decision_factor;

End AS_DECISION_FACTOR_PVT;

/
