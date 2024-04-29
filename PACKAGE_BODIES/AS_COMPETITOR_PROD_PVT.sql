--------------------------------------------------------
--  DDL for Package Body AS_COMPETITOR_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_COMPETITOR_PROD_PVT" as
/* $Header: asxvcpdb.pls 120.1 2005/06/14 01:34:01 appldev  $ */
-- Start of Comments
-- Package name     : AS_COMPETITOR_PROD_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_COMPETITOR_PROD_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvcpdb.pls';

-- Local procedure for competitor products

FUNCTION Opp_Won( p_LEAD_ID	IN  NUMBER) RETURN BOOLEAN
IS

CURSOR c_WIN_LOSS_INDICATOR(c_LEAD_ID NUMBER) IS
	select st.WIN_LOSS_INDICATOR
	from as_statuses_b st,
	     as_leads_all ld
	where st.STATUS_CODE = ld.STATUS
	and   ld.LEAD_ID = c_LEAD_ID;

l_indicator  varchar2(1);

BEGIN
      open c_WIN_LOSS_INDICATOR( p_LEAD_ID);
      fetch c_WIN_LOSS_INDICATOR into l_indicator;
      close c_WIN_LOSS_INDICATOR;

      IF ( nvl(l_indicator, 'L') = 'W') THEN
         return TRUE;
      ELSE
         return FALSE;
      END IF;

EXCEPTION
      WHEN OTHERS THEN
    	return FALSE;

END Opp_Won;


FUNCTION check_dup(p_Competitor_Prod_rec IN  AS_OPPORTUNITY_PUB.Competitor_Prod_Rec_Type
					  := AS_OPPORTUNITY_PUB.G_MISS_Competitor_Prod_Rec)
RETURN BOOLEAN IS

CURSOR dup_exist IS
	select 'Y'
	from as_lead_comp_products
	where lead_line_id = p_Competitor_Prod_rec.lead_line_id
	and   competitor_product_id = p_Competitor_Prod_rec.competitor_product_id;

l_dup_exist  varchar2(1);
BEGIN
    open dup_exist;
    fetch dup_exist into l_dup_exist;
    close dup_exist;

    IF ( nvl(l_dup_exist, 'N') = 'Y' ) THEN
	return TRUE;
    ELSE
      	return FALSE;
    END IF;

EXCEPTION
      WHEN OTHERS THEN
    	return FALSE;

END check_dup;






-- Hint: Primary key needs to be returned.
PROCEDURE Create_competitor_prods(
        P_Api_Version_Number      IN   NUMBER,
	P_Init_Msg_List           IN   VARCHAR2    := FND_API.G_FALSE,
	P_Commit                  IN   VARCHAR2    := FND_API.G_FALSE,
	p_validation_level        IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
	P_Admin_Group_Id          IN   NUMBER,
	P_profile_tbl             IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
	P_Competitor_Prod_Tbl          IN   AS_OPPORTUNITY_PUB.Competitor_Prod_Tbl_Type :=
						 AS_OPPORTUNITY_PUB.G_MISS_Competitor_Prod_Tbl,
	X_competitor_prod_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.competitor_prod_out_tbl_type,
	P_Check_Access_Flag       IN   VARCHAR2    := FND_API.G_FALSE,
	P_Admin_Flag              IN   VARCHAR2    := FND_API.G_FALSE,
	P_Identity_Salesforce_Id  IN   NUMBER      := NULL,
	P_Partner_Cont_Party_id   IN   NUMBER      := FND_API.G_MISS_NUM,
	X_Return_Status           OUT NOCOPY  VARCHAR2,
	X_Msg_Count               OUT NOCOPY  NUMBER,
	X_Msg_Data                OUT NOCOPY  VARCHAR2
)

 IS
    L_Api_Name                  CONSTANT VARCHAR2(30) := 'Create_Competitor_Prods';
    L_Api_Version_Number        CONSTANT NUMBER   := 2.0;
    L_Return_Status_Full        VARCHAR2(1);
    L_Identity_Sales_Member_Rec AS_SALES_MEMBER_PUB.Sales_Member_Rec_Type;
    L_Competitor_Prod_Rec            AS_OPPORTUNITY_PUB.Competitor_Prod_Rec_Type;
    L_LEAD_COMPETITOR_PROD_ID        NUMBER;
    L_LEAD_COMPETITOR_PROD           VARCHAR2(225);
    L_Line_Count                CONSTANT NUMBER := P_Competitor_Prod_Tbl.count;
    L_Access_Profile_Rec        AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
    L_Item_Property_Rec         AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
    L_Access_Flag               VARCHAR2(1);

    l_opp_won			BOOLEAN  := Opp_Won(P_Competitor_Prod_Tbl(1).LEAD_ID);
    l_loop_count		NUMBER   := 1;
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Create_competitor_prods';


 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_COMPETITOR_PRODS_PVT;

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
          AS_CALLOUT_PKG.Create_competitor_prods_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Competitor_Prod_Rec      =>  P_Competitor_Prod_Rec,
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
              p_opportunity_id         => P_Competitor_Prod_Tbl(1).LEAD_ID,
              p_check_access_flag      => 'Y',
              p_identity_salesforce_id => p_identity_salesforce_id,
              p_partner_cont_party_id  => NULL,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              x_update_access_flag       => l_access_flag);

      IF l_access_flag <> 'Y' THEN
          AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
          'API_NO_UPDATE_PRIVILEGE');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      END IF;

      FOR l_curr_row IN 1..l_line_count LOOP
         X_competitor_prod_out_tbl(l_curr_row).return_status :=
                                                   FND_API.G_RET_STS_SUCCESS ;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_COMP_PRODUCTS', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_competitor_prod_rec := P_Competitor_Prod_Tbl(l_curr_row);

	 -- Default win/loss status
	 IF (l_competitor_prod_rec.WIN_LOSS_STATUS IS NULL ) THEN
	     l_competitor_prod_rec.WIN_LOSS_STATUS :=
			fnd_profile.value('AS_DEFAULT_WIN_LOSS_STATUS');
	 END IF;

         -- Reset the win/loss status
         IF (l_opp_won) THEN
	     l_competitor_prod_rec.WIN_LOSS_STATUS := 'LOST';
         END IF;

         IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL )
         THEN
            -- Debug message
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Private API: Validate_competitor_prod');

            END IF;

            -- Invoke validation procedures
            Validate_competitor_prod(
                P_Init_Msg_List    => FND_API.G_FALSE,
                P_Validation_Level => p_validation_level,
                P_Validation_Mode  => AS_UTILITY_PVT.G_CREATE,
		P_Competitor_Prod_Rec   => l_Competitor_Prod_Rec,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data
			 );
         END IF;

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
/*
	 IF check_dup( p_Competitor_Prod_rec => l_Competitor_Prod_rec ) THEN
	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
              	  FND_MESSAGE.Set_Name('AS', 'API_DUP_COMPETITOR_PRODUCTS');
              	  FND_MSG_PUB.ADD;
             END IF;
	     RAISE FND_API.G_EXC_ERROR;
	 END IF;
*/
         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling create table handler');

         END IF;

         l_LEAD_COMPETITOR_PROD_ID := l_Competitor_Prod_rec.LEAD_COMPETITOR_PROD_ID;

      -- Invoke table handler(AS_LEAD_COMP_PRODUCTS_PKG.Insert_Row)
      AS_LEAD_COMP_PRODUCTS_PKG.Insert_Row(
          p_ATTRIBUTE15  => l_competitor_prod_rec.ATTRIBUTE15,
          p_ATTRIBUTE14  => l_competitor_prod_rec.ATTRIBUTE14,
          p_ATTRIBUTE13  => l_competitor_prod_rec.ATTRIBUTE13,
          p_ATTRIBUTE12  => l_competitor_prod_rec.ATTRIBUTE12,
          p_ATTRIBUTE11  => l_competitor_prod_rec.ATTRIBUTE11,
          p_ATTRIBUTE10  => l_competitor_prod_rec.ATTRIBUTE10,
          p_ATTRIBUTE9  => l_competitor_prod_rec.ATTRIBUTE9,
          p_ATTRIBUTE8  => l_competitor_prod_rec.ATTRIBUTE8,
          p_ATTRIBUTE7  => l_competitor_prod_rec.ATTRIBUTE7,
          p_ATTRIBUTE6  => l_competitor_prod_rec.ATTRIBUTE6,
          p_ATTRIBUTE4  => l_competitor_prod_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_competitor_prod_rec.ATTRIBUTE5,
          p_ATTRIBUTE2  => l_competitor_prod_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_competitor_prod_rec.ATTRIBUTE3,
          p_ATTRIBUTE1  => l_competitor_prod_rec.ATTRIBUTE1,
          p_ATTRIBUTE_CATEGORY  => l_competitor_prod_rec.ATTRIBUTE_CATEGORY,
          p_PROGRAM_ID  => l_competitor_prod_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_competitor_prod_rec.PROGRAM_UPDATE_DATE,
          p_PROGRAM_APPLICATION_ID  => l_competitor_prod_rec.PROGRAM_APPLICATION_ID,
          p_REQUEST_ID  => l_competitor_prod_rec.REQUEST_ID,
          p_WIN_LOSS_STATUS  => l_competitor_prod_rec.WIN_LOSS_STATUS,
          p_COMPETITOR_PRODUCT_ID  => l_competitor_prod_rec.COMPETITOR_PRODUCT_ID,
          p_LEAD_LINE_ID  => l_competitor_prod_rec.LEAD_LINE_ID,
          p_LEAD_ID  => l_competitor_prod_rec.LEAD_ID,
          px_LEAD_COMPETITOR_PROD_ID  => l_LEAD_COMPETITOR_PROD_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
	  p_CREATION_DATE  => SYSDATE);


         X_competitor_prod_out_tbl(l_curr_row).LEAD_COMPETITOR_PROD_ID :=
                                                        l_LEAD_COMPETITOR_PROD_ID;
         X_competitor_prod_out_tbl(l_curr_row).return_status := x_return_status;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;

	 -- rolloup the competitor to the opp header
	 IF l_loop_count = 1 THEN
	    UPDATE AS_LEADS_ALL
	    SET object_version_number =  nvl(object_version_number,0) + 1, CLOSE_COMPETITOR_ID =
		( select competitor_party_id
		  from ams_competitor_products_b
		  where competitor_product_id = l_competitor_prod_rec.COMPETITOR_PRODUCT_ID )
	    WHERE lead_id = l_competitor_prod_rec.LEAD_ID
	    AND   CLOSE_COMPETITOR_ID is null;
	 END IF;
	 l_loop_count := l_loop_count + 1;

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
          AS_CALLOUT_PKG.Create_competitor_prods_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Competitor_Prod_Prod_Rec      =>  P_Competitor_Prod_Prod_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION

	  WHEN DUP_VAL_ON_INDEX THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
              	  FND_MESSAGE.Set_Name('AS', 'API_DUP_COMPETITOR_PRODUCTS');
              	  FND_MSG_PUB.ADD;
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_competitor_prods;


PROCEDURE Update_competitor_prods(
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
	P_Competitor_Prod_Tbl          IN   AS_OPPORTUNITY_PUB.Competitor_Prod_Tbl_Type,
	X_competitor_prod_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.competitor_prod_out_tbl_type,
	X_Return_Status           OUT NOCOPY  VARCHAR2,
	X_Msg_Count               OUT NOCOPY  NUMBER,
	X_Msg_Data                OUT NOCOPY  VARCHAR2
)

 IS
    Cursor C_Get_competitor_prod(c_LEAD_COMPETITOR_PROD_ID Number) IS
        Select LAST_UPDATE_DATE
        From  AS_LEAD_COMP_PRODUCTS
        WHERE LEAD_COMPETITOR_PROD_ID = c_LEAD_COMPETITOR_PROD_ID
        For Update NOWAIT;

    L_Api_Name                  CONSTANT VARCHAR2(30) := 'Update_competitor_prods';
    L_Api_Version_Number        CONSTANT NUMBER   := 2.0;
    L_Identity_Sales_Member_Rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    L_Ref_Competitor_Prod_Rec        AS_OPPORTUNITY_PUB.Competitor_Prod_Rec_Type;
    L_Rowid                     ROWID;
    L_Competitor_Prod_Rec            AS_OPPORTUNITY_PUB.Competitor_Prod_Rec_Type;
    L_Line_Count                CONSTANT NUMBER := P_Competitor_Prod_Tbl.count;
    L_Access_Profile_Rec        AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
    L_Last_Update_Date          DATE;
    L_Access_Flag               VARCHAR2(1);

    l_opp_won			BOOLEAN  := Opp_Won(P_Competitor_Prod_Tbl(1).LEAD_ID);
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Update_competitor_prods';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_COMPETITOR_PRODS_PVT;

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
          AS_CALLOUT_PKG.Update_competitor_prods_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Competitor_Prod_Rec      =>  P_Competitor_Prod_Rec,
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
              p_opportunity_id         => P_Competitor_Prod_Tbl(1).LEAD_ID,
              p_check_access_flag      => 'Y',
              p_identity_salesforce_id => p_identity_salesforce_id,
              p_partner_cont_party_id  => NULL,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              x_update_access_flag       => l_access_flag);

      IF l_access_flag <> 'Y' THEN
          AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
          'API_NO_UPDATE_PRIVILEGE');
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      END IF;

      FOR l_curr_row IN 1..l_line_count LOOP
         X_competitor_prod_out_tbl(l_curr_row).return_status :=
                                                   FND_API.G_RET_STS_SUCCESS ;
         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_COMP_PRODUCTS', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_competitor_prod_rec := P_Competitor_Prod_Tbl(l_curr_row);

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: - Open Cursor to Select');

         END IF;

         Open C_Get_competitor_prod( l_Competitor_Prod_rec.LEAD_COMPETITOR_PROD_ID);

         Fetch C_Get_competitor_prod into l_last_update_date;

         If ( C_Get_competitor_prod%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'competitor_prod', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
         END IF;
         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'Private API: - Close Cursor');
         END IF;

         Close     C_Get_competitor_prod;

         If (l_Competitor_Prod_rec.last_update_date is NULL or
             l_Competitor_Prod_rec.last_update_date = FND_API.G_MISS_Date ) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
                 FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
                 FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
         End if;
         -- Check Whether record has been changed by someone else
         If (l_Competitor_Prod_rec.last_update_date <> l_last_update_date) Then
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                 FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
                 FND_MESSAGE.Set_Token('INFO', 'competitor_prod', FALSE);
                 FND_MSG_PUB.ADD;
             END IF;
             raise FND_API.G_EXC_ERROR;
         End if;

         -- Reset the win/loss status
         IF (l_opp_won) THEN
	     l_competitor_prod_rec.WIN_LOSS_STATUS := 'LOST';
         END IF;

         IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL )
         THEN
             -- Debug message
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'Private API: Validate_competitor_prod');
             END IF;

             -- Invoke validation procedures
             Validate_competitor_prod(
                 p_init_msg_list    => FND_API.G_FALSE,
                 p_validation_level => p_validation_level,
                 p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
                 P_Competitor_Prod_Rec  =>  l_Competitor_Prod_Rec,
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);
         END IF;

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;
/*
	 IF check_dup( p_Competitor_Prod_rec => l_Competitor_Prod_rec ) THEN
	     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
              	  FND_MESSAGE.Set_Name('AS', 'API_DUP_COMPETITOR_PRODUCTS');
              	  FND_MSG_PUB.ADD;
             END IF;
	     RAISE FND_API.G_EXC_ERROR;
	 END IF;
*/
         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling update table handler');
         END IF;


      -- Invoke table handler(AS_LEAD_COMP_PRODUCTS_PKG.Update_Row)
      AS_LEAD_COMP_PRODUCTS_PKG.Update_Row(
          p_ATTRIBUTE15  => l_competitor_prod_rec.ATTRIBUTE15,
          p_ATTRIBUTE14  => l_competitor_prod_rec.ATTRIBUTE14,
          p_ATTRIBUTE13  => l_competitor_prod_rec.ATTRIBUTE13,
          p_ATTRIBUTE12  => l_competitor_prod_rec.ATTRIBUTE12,
          p_ATTRIBUTE11  => l_competitor_prod_rec.ATTRIBUTE11,
          p_ATTRIBUTE10  => l_competitor_prod_rec.ATTRIBUTE10,
          p_ATTRIBUTE9  => l_competitor_prod_rec.ATTRIBUTE9,
          p_ATTRIBUTE8  => l_competitor_prod_rec.ATTRIBUTE8,
          p_ATTRIBUTE7  => l_competitor_prod_rec.ATTRIBUTE7,
          p_ATTRIBUTE6  => l_competitor_prod_rec.ATTRIBUTE6,
          p_ATTRIBUTE4  => l_competitor_prod_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_competitor_prod_rec.ATTRIBUTE5,
          p_ATTRIBUTE2  => l_competitor_prod_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_competitor_prod_rec.ATTRIBUTE3,
          p_ATTRIBUTE1  => l_competitor_prod_rec.ATTRIBUTE1,
          p_ATTRIBUTE_CATEGORY  => l_competitor_prod_rec.ATTRIBUTE_CATEGORY,
          p_PROGRAM_ID  => l_competitor_prod_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_competitor_prod_rec.PROGRAM_UPDATE_DATE,
          p_PROGRAM_APPLICATION_ID  => l_competitor_prod_rec.PROGRAM_APPLICATION_ID,
          p_REQUEST_ID  => l_competitor_prod_rec.REQUEST_ID,
          p_WIN_LOSS_STATUS  => l_competitor_prod_rec.WIN_LOSS_STATUS,
          p_COMPETITOR_PRODUCT_ID  => l_competitor_prod_rec.COMPETITOR_PRODUCT_ID,
          p_LEAD_LINE_ID  => l_competitor_prod_rec.LEAD_LINE_ID,
          p_LEAD_ID  => l_competitor_prod_rec.LEAD_ID,
          p_LEAD_COMPETITOR_PROD_ID  => l_competitor_prod_rec.LEAD_COMPETITOR_PROD_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_CREATED_BY     => FND_API.G_MISS_NUM,
          p_CREATION_DATE  => l_competitor_prod_rec.CREATION_DATE);

         X_competitor_prod_out_tbl(l_curr_row).LEAD_COMPETITOR_PROD_ID :=
                                       l_Competitor_Prod_rec.LEAD_COMPETITOR_PROD_ID;
         X_competitor_prod_out_tbl(l_curr_row).return_status := x_return_status;

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
          AS_CALLOUT_PKG.Update_competitor_prods_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Competitor_Prod_Prod_Rec      =>  P_Competitor_Prod_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/
      EXCEPTION

	  WHEN DUP_VAL_ON_INDEX THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
              	  FND_MESSAGE.Set_Name('AS', 'API_DUP_COMPETITOR_PRODUCTS');
              	  FND_MSG_PUB.ADD;
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_competitor_prods;


-- Hint: Add corresponding delete detail table procedures if it's master-detail
--       relationship.
--       The Master delete procedure may not be needed depends on different
--       business requirements.
PROCEDURE Delete_competitor_prods(
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
	P_Competitor_Prod_Tbl          IN   AS_OPPORTUNITY_PUB.Competitor_Prod_Tbl_Type,
	X_competitor_prod_out_tbl      OUT NOCOPY  AS_OPPORTUNITY_PUB.competitor_prod_out_tbl_type,
	X_Return_Status           OUT NOCOPY  VARCHAR2,
	X_Msg_Count               OUT NOCOPY  NUMBER,
	X_Msg_Data                OUT NOCOPY  VARCHAR2
	)

 IS
    L_Api_Name                  CONSTANT VARCHAR2(30) := 'Delete_competitor_prods';
    L_Api_Version_Number        CONSTANT NUMBER   := 2.0;
    L_Identity_Sales_Member_Rec AS_SALES_MEMBER_PUB.Sales_Member_Rec_Type;
    L_Competitor_Prod_Rec            AS_OPPORTUNITY_PUB.Competitor_Prod_Rec_Type;
    L_Lead_Competitor_Prod_Id        NUMBER;
    L_Line_Count                CONSTANT NUMBER := P_Competitor_Prod_Tbl.count;
    L_Access_Profile_Rec        AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
    L_Access_Flag               VARCHAR2(1);
    l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Delete_competitor_prods';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_COMPETITOR_PRODS_PVT;

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
          AS_CALLOUT_PKG.Delete_competitor_prods_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Competitor_Prod_Rec      =>  P_Competitor_Prod_Rec,
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
              p_opportunity_id         => l_Competitor_Prod_rec.LEAD_ID,
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
         X_competitor_prod_out_tbl(l_curr_row).return_status :=
                                                   FND_API.G_RET_STS_SUCCESS ;

         -- Progress Message
         --
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
         THEN
             FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
             FND_MESSAGE.Set_Token ('ROW', 'AS_LEAD_COMP_PRODUCTS', TRUE);
             FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(l_curr_row), FALSE);
             FND_MSG_PUB.Add;
         END IF;

         l_competitor_prod_rec := P_Competitor_Prod_Tbl(l_curr_row);

         -- Debug Message
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling delete table handler');
	 END IF;


         -- Invoke table handler(AS_LEAD_COMP_PRODUCTS_PKG.Delete_Row)
         AS_LEAD_COMP_PRODUCTS_PKG.Delete_Row(
             p_LEAD_COMPETITOR_PROD_ID  => l_Competitor_Prod_rec.LEAD_COMPETITOR_PROD_ID);

         X_competitor_prod_out_tbl(l_curr_row).LEAD_COMPETITOR_PROD_ID :=
                                                        l_LEAD_COMPETITOR_PROD_ID;
         X_competitor_prod_out_tbl(l_curr_row).return_status := x_return_status;

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
          AS_CALLOUT_PKG.Delete_competitor_prods_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Competitor_Prod_Prod_Rec      =>  P_Competitor_Prod_Rec,
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
End Delete_competitor_prods;


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


PROCEDURE Validate_WIN_LOSS_STATUS (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_WIN_LOSS_STATUS                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

  CURSOR C_WIN_LOSS_STATUS_Exists (c_lookup_type VARCHAR2,
                                    c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = c_lookup_type
            and lookup_code = c_Lookup_Code;
  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Validate_WIN_LOSS_STATUS';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_WIN_LOSS_STATUS is NOT NULL) and
         (p_WIN_LOSS_STATUS <> FND_API.G_MISS_CHAR)
      THEN
          -- WIN_LOSS_STATUS should exist in as_lookups
          OPEN  C_WIN_LOSS_STATUS_Exists ('WIN_LOSS_STATUS',
                                           p_WIN_LOSS_STATUS);
          FETCH C_WIN_LOSS_STATUS_Exists into l_val;

          IF C_WIN_LOSS_STATUS_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --             'Private API: WIN_LOSS_STATUS is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_WIN_LOSS_STATUS',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_WIN_LOSS_STATUS );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_WIN_LOSS_STATUS_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_WIN_LOSS_STATUS;


PROCEDURE Validate_COMPETITOR_PRODUCT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_COMPETITOR_PRODUCT_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

/*
 CURSOR c_competitor_product_exists(c_COMPETITOR_PRODUCT_ID number) IS
	select 'X'
	from ams_competitor_products_b
	where competitor_product_id = c_COMPETITOR_PRODUCT_ID;
*/
  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Validate_COMPETITOR_PRODUCT_ID';

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      	IF (p_COMPETITOR_PRODUCT_ID is NULL) or
           (p_COMPETITOR_PRODUCT_ID = FND_API.G_MISS_NUM)
	THEN
	    AS_UTILITY_PVT.Set_Message(
			   p_module        => l_module,
			   p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  	   p_msg_name      => 'API_MISSING_COMPETITOR_PRODUCT_ID');

            x_return_status := FND_API.G_RET_STS_ERROR;
     	ELSE
	    NULL;
/*
            OPEN  c_competitor_product_exists(p_COMPETITOR_PRODUCT_ID);
            FETCH c_competitor_product_exists into l_val;
	    IF c_competitor_product_exists%NOTFOUND THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API: COMPETITOR_PRODUCT_ID is invalid');
                END IF;

                x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            CLOSE c_competitor_product_exists;
*/
        END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_COMPETITOR_PRODUCT_ID;


PROCEDURE Validate_LEAD_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_LINE_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_Lead_Line_Id_Exists (c_Lead_Line_Id NUMBER) IS
      	SELECT 'X'
      	FROM  as_lead_lines
      	WHERE lead_line_id = c_Lead_Line_Id;



l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Validate_LEAD_LINE_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF (p_LEAD_LINE_ID is NULL) or (p_LEAD_LINE_ID = FND_API.G_MISS_NUM)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                      'Private API 38: Violate NOT NULL constraint(LEAD_LINE_ID)');
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          OPEN  C_Lead_Line_Id_Exists (p_Lead_Line_Id);
          FETCH C_Lead_Line_Id_Exists into l_val;
          IF C_Lead_Line_Id_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API 39: LEAD_LINE_ID is not valid');
              END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Lead_Line_Id_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_LINE_ID;


PROCEDURE Validate_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS


CURSOR 	C_Lead_Id_Exists (c_Lead_Id NUMBER) IS
      	SELECT 'X'
      	FROM  as_leads
      	WHERE lead_id = c_Lead_Id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Validate_LEAD_ID';

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
                      'Private API 36: Violate NOT NULL constraint(LEAD_ID)');
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          OPEN  C_Lead_Id_Exists (p_Lead_Id);
          FETCH C_Lead_Id_Exists into l_val;
          IF C_Lead_Id_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API 37: LEAD_ID is not valid');
              END IF;

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


PROCEDURE Validate_L_COMPETITOR_PROD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_COMPETITOR_PROD_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Lead_CProd_Id_Exists (c_Lead_Competitor_Prod_Id NUMBER) IS
      SELECT 'X'
      FROM  as_lead_comp_products
      WHERE lead_competitor_prod_id = c_Lead_Competitor_Prod_Id;

  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Validate_L_COMPETITOR_PROD_ID';

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
          IF (p_LEAD_COMPETITOR_PROD_ID is NOT NULL) and (p_LEAD_COMPETITOR_PROD_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_Lead_CProd_Id_Exists (p_Lead_Competitor_Prod_Id);
              FETCH C_Lead_CProd_Id_Exists into l_val;

              IF C_Lead_CProd_Id_Exists%FOUND THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --                           'Private API: LEAD_COMPETITOR_PROD_ID exist');

                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_DUPLICATE_LEAD_CPROD_ID',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_LEAD_COMPETITOR_PROD_ID );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_Lead_CProd_Id_Exists;
          END IF;

      -- Calling from Update API
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_LEAD_COMPETITOR_PROD_ID is NULL) or (p_LEAD_COMPETITOR_PROD_ID = FND_API.G_MISS_NUM)
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --          'Private API: Violate NOT NULL constraint(LEAD_COMPETITOR_PROD_ID)');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_CPROD_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_Lead_CProd_Id_Exists (p_Lead_Competitor_Prod_Id);
              FETCH C_Lead_CProd_Id_Exists into l_val;

              IF C_Lead_CProd_Id_Exists%NOTFOUND
              THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --                     'Private API: LEAD_COMPETITOR_PROD_ID is not valid');

                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_LEAD_CPROD_ID',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_LEAD_COMPETITOR_PROD_ID );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_Lead_CProd_Id_Exists;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_L_COMPETITOR_PROD_ID;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all G_MISS_XXX fields to original value
--       stored in database table.



PROCEDURE Validate_Competitor_Prod_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Competitor_Prod_Rec     IN    as_opportunity_pub.Competitor_Prod_Rec_Type,
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

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Competitor_Prod_Rec;

PROCEDURE Validate_competitor_prod(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Competitor_Prod_Rec     IN    as_opportunity_pub.Competitor_Prod_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_competitor_prod';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.cpdpv.Validate_competitor_prod';

 BEGIN

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API validate: REQUEST_ID');
	  END IF;

          Validate_REQUEST_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_REQUEST_ID   => P_Competitor_Prod_Rec.REQUEST_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API validate: WIN_LOSS_STATUS ');
	  END IF;

          Validate_WIN_LOSS_STATUS(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_WIN_LOSS_STATUS   => P_Competitor_Prod_Rec.WIN_LOSS_STATUS,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);


          Validate_COMPETITOR_PRODUCT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_COMPETITOR_PRODUCT_ID   => P_Competitor_Prod_Rec.COMPETITOR_PRODUCT_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API validate: LEAD_LINE_ID');
          END IF;

          Validate_LEAD_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_LINE_ID   => P_Competitor_Prod_Rec.LEAD_LINE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API validate: LEAD_ID');
          END IF;

          Validate_LEAD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_ID   => P_Competitor_Prod_Rec.LEAD_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API validate: L_COMPETITOR_PROD_ID');
	  END IF;


          Validate_L_COMPETITOR_PROD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_COMPETITOR_PROD_ID   => P_Competitor_Prod_Rec.LEAD_COMPETITOR_PROD_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

      END IF;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API validate: Competitor_Prod_Rec');
	  END IF;


          Validate_Competitor_Prod_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
          P_Competitor_Prod_Rec     =>    P_Competitor_Prod_Rec,
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
            'Private API: Validation end');
      END IF;


END Validate_competitor_prod;



End AS_COMPETITOR_PROD_PVT;

/
