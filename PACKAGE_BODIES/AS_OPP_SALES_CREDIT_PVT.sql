--------------------------------------------------------
--  DDL for Package Body AS_OPP_SALES_CREDIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_SALES_CREDIT_PVT" as
/* $Header: asxvlscb.pls 120.6 2005/12/27 21:26:54 subabu ship $ */
-- Start of Comments
-- Package name     : AS_OPP_SALES_CREDIT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_OPP_SALES_CREDIT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvlscb.pls';


FUNCTION get_prob_bucket(p_win_probability IN NUMBER) RETURN NUMBER IS

l_retVal NUMBER;
l_win_probability NUMBER;

BEGIN
    l_retVal := 0;

    l_win_probability := nvl(p_win_probability, -1);

    IF 0 <= l_win_probability AND l_win_probability < 40 THEN
        l_retVal := 1;
    ELSIF 40 <= l_win_probability AND l_win_probability < 60 THEN
        l_retVal := 2;
    ELSIF 60 <= l_win_probability AND l_win_probability < 80 THEN
        l_retVal := 3;
    ELSIF 80 <= l_win_probability THEN
        l_retVal := 4;
    END IF;

    RETURN l_retVal;
END get_prob_bucket;


FUNCTION Apply_Forecast_Defaults(
    p_old_win_probability           IN NUMBER,
    p_old_win_loss_indicator        IN VARCHAR2,
    p_old_forecast_rollup_flag      IN VARCHAR2,
    p_old_sales_credit_amount       IN NUMBER,
    p_win_probability               IN NUMBER,
    p_win_loss_indicator            IN VARCHAR2,
    p_forecast_rollup_flag          IN VARCHAR2,
    p_sales_credit_amount           IN NUMBER,
    p_Trigger_Mode                  IN VARCHAR2,
    x_opp_worst_forecast_amount     IN OUT NOCOPY NUMBER,
    x_opp_forecast_amount           IN OUT NOCOPY NUMBER,
    x_opp_best_forecast_amount      IN OUT NOCOPY NUMBER
)
RETURN BOOLEAN
IS
    l_old_win_probability           NUMBER;
    l_old_win_loss_indicator        VARCHAR2(8);
    l_old_forecast_rollup_flag      VARCHAR2(8);
    l_old_sales_credit_amount       NUMBER;
    l_win_probability               NUMBER;
    l_win_loss_indicator            VARCHAR2(8);
    l_forecast_rollup_flag          VARCHAR2(8);
    l_sales_credit_amount           NUMBER;
    l_Trigger_Mode                  VARCHAR2(32);

    l_apply_frcst_def               BOOLEAN;
    l_old_prob_bucket               NUMBER;
    l_prob_bucket                   NUMBER;
    l_opp_worst_forecast_amount     NUMBER;
    l_opp_forecast_amount           NUMBER;
    l_opp_best_forecast_amount      NUMBER;
    l_defaulting_type               VARCHAR2(64);
BEGIN
    l_old_win_probability := nvl(p_old_win_probability, 0);
    l_old_win_loss_indicator := nvl(p_old_win_loss_indicator, 'N');
    l_old_forecast_rollup_flag := nvl(p_old_forecast_rollup_flag, 'N');
    l_old_sales_credit_amount := nvl(p_old_sales_credit_amount, 0);
    l_win_probability := nvl(p_win_probability, 0);
    l_win_loss_indicator := nvl(p_win_loss_indicator, 'N');
    l_forecast_rollup_flag := nvl(p_forecast_rollup_flag, 'N');
    l_sales_credit_amount := nvl(p_sales_credit_amount, 0);
    l_Trigger_Mode := nvl(p_Trigger_Mode, 'NONE');

    l_apply_frcst_def := FALSE;
    l_defaulting_type :=
        nvl(FND_PROFILE.Value('ASN_FRCST_DEFAULTING_TYPE'), 'z');

    IF nvl(l_forecast_rollup_flag, 'N') = 'Y' THEN
        l_prob_bucket := get_prob_bucket(l_win_probability);
        IF l_Trigger_Mode = 'ON-UPDATE' THEN
            l_old_prob_bucket := get_prob_bucket(l_old_win_probability);

            IF l_old_win_probability <> l_win_probability AND
               l_win_loss_indicator <> 'W' AND
               ( l_defaulting_type <> 'W'
                  OR l_old_prob_bucket <> l_prob_bucket)
            THEN
                l_apply_frcst_def := TRUE;
            ELSIF l_old_win_loss_indicator <> l_win_loss_indicator AND
                  (l_old_win_loss_indicator = 'W' OR
                   l_win_loss_indicator = 'W') THEN
                l_apply_frcst_def := TRUE;
            ELSIF l_old_forecast_rollup_flag = 'N' THEN
                l_apply_frcst_def := TRUE;
            ELSIF l_old_sales_credit_amount <> l_sales_credit_amount THEN
                l_apply_frcst_def := TRUE;
            END IF;
        ELSIF l_Trigger_Mode = 'ON-INSERT' THEN
            l_apply_frcst_def := TRUE;
        END IF;

        IF l_apply_frcst_def THEN
            IF l_win_loss_indicator = 'W' THEN
                l_opp_worst_forecast_amount := l_sales_credit_amount;
                l_opp_forecast_amount := l_sales_credit_amount;
                l_opp_best_forecast_amount := l_sales_credit_amount;
            ELSIF l_defaulting_type = 'W' THEN
                IF l_prob_bucket = 1 THEN
                    l_opp_worst_forecast_amount := 0;
                    l_opp_forecast_amount := 0;
                    l_opp_best_forecast_amount := 0;
                ELSIF l_prob_bucket = 2 THEN
                    l_opp_worst_forecast_amount := 0;
                    l_opp_forecast_amount := 0;
                    l_opp_best_forecast_amount := l_sales_credit_amount;
                ELSIF l_prob_bucket = 3 THEN
                    l_opp_worst_forecast_amount := 0;
                    l_opp_forecast_amount := l_sales_credit_amount;
                    l_opp_best_forecast_amount := l_sales_credit_amount;
                ELSE
                    l_opp_worst_forecast_amount := l_sales_credit_amount;
                    l_opp_forecast_amount := l_sales_credit_amount;
                    l_opp_best_forecast_amount := l_sales_credit_amount;
                END IF;
            ELSE
                l_opp_worst_forecast_amount := 0;
                l_opp_forecast_amount :=
                    l_sales_credit_amount*l_win_probability/100;
                l_opp_best_forecast_amount := l_sales_credit_amount;
            END IF;
            x_opp_worst_forecast_amount := l_opp_worst_forecast_amount;
            x_opp_forecast_amount := l_opp_forecast_amount;
            x_opp_best_forecast_amount := l_opp_best_forecast_amount;
        END IF; -- Of l_apply_frcst_def
    END IF; -- of nvl(l_forecast_rollup_flag, 'z') = 'Y' ...
    RETURN l_apply_frcst_def;
END Apply_Forecast_Defaults;


-- Hint: Primary key needs to be returned.
PROCEDURE Create_sales_credits(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER     := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    p_partner_cont_party_id      IN  NUMBER  := FND_API.G_MISS_NUM,
    P_SALES_CREDIT_tbl           IN    AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_Type
					:= AS_OPPORTUNITY_PUB.G_MISS_SALES_CREDIT_tbl,
    X_SALES_CREDIT_out_tbl       OUT NOCOPY  AS_OPPORTUNITY_PUB.sales_credit_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

CURSOR lead_customer( p_lead_id NUMBER) IS
	select customer_id, address_id
	from   as_leads
	where lead_id = p_lead_id;

CURSOR C_Person_Id(p_resource_id NUMBER) IS
     	SELECT source_id
	FROM JTF_RS_RESOURCE_EXTNS
	WHERE resource_id = p_resource_id
	AND category = 'EMPLOYEE';

CURSOR C_Partner_Id(p_resource_id NUMBER) IS
     	SELECT source_id, address_id
	FROM JTF_RS_RESOURCE_EXTNS
	WHERE resource_id = p_resource_id
	AND (category = 'PARTNER'
	OR category = 'PARTY');

-- solin, for bug 1554330
CURSOR c_get_opp_freeze_flag(c_LEAD_ID NUMBER) IS
    SELECT FREEZE_FLAG
    FROM AS_LEADS
    WHERE LEAD_ID = c_LEAD_ID;
/*
Modified for bug# 4168544.
Change the select clause so that it returns  team_leader_flag,last_update_date,access_id
instead of 'X'.
*/
cursor get_dup_sales_team(c_customer_id NUMBER,c_address_id NUMBER,c_lead_id NUMBER,c_salesforce_id NUMBER, c_sales_group_id NUMBER  ) is
    select team_leader_flag,last_update_date,access_id
    from as_accesses
    where customer_id = c_customer_id
          --and nvl(address_id, -99) = nvl(c_address_id, -99)
	  and nvl(lead_id, -99) = nvl(c_lead_id, -99)
	  and salesforce_id = c_salesforce_id
	  and nvl(sales_group_id, -99) = nvl(c_sales_group_id, -99);

-- Jean add here. Use to get sales group id
-- for partner contact resource type
CURSOR c_group_id(c_SALESFORCE_ID NUMBER) IS
--    SELECT decode(count(*), 1, to_char(max(c.group_id)), decode(fnd_profile.value_specific('ASF_DEFAULT_GROUP_ROLE', max(a.user_id)),'XXXXX',null,fnd_profile.value_specific('ASF_DEFAULT_GROUP_ROLE',max(a.user_id))))
--    SELECT decode(count(*), 1, to_char(max(c.group_id)))
--    SELECT to_char(max(c.group_id))
--    FROM jtf_rs_resource_extns a, fnd_user b, jtf_rs_group_members c
--    WHERE a.user_id = b.user_id
--    AND a.resource_id = c.resource_id
--    AND a.resource_id = c_SALESFORCE_ID;
--   fix the bug 2549218
     SELECT to_char(max(c.group_id))
     FROM jtf_rs_resource_extns a, fnd_user b, jtf_rs_group_members c, JTF_RS_ROLE_RELATIONS d , JTF_RS_ROLES_B e
    WHERE a.user_id = b.user_id
    AND a.resource_id = c.resource_id
    AND e.ROLE_TYPE_CODE in ('SALES','TELESALES','FIELDSALES','PRM')
    AND c.GROUP_MEMBER_ID = d.ROLE_RESOURCE_ID
    AND d.ROLE_RESOURCE_TYPE = 'RS_GROUP_MEMBER' AND d.ROLE_ID = e.ROLE_ID
    AND a.resource_id = c_SALESFORCE_ID;



l_api_name                	CONSTANT VARCHAR2(30) := 'Create_sales_credits';
l_api_version_number      	CONSTANT NUMBER   := 2.0;
l_return_status_full        	VARCHAR2(1);
l_identity_sales_member_rec 	AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_sales_credit_rec        	AS_OPPORTUNITY_PUB.SALES_CREDIT_rec_Type;
l_sales_credit_id         	NUMBER;
l_sales_credit_count        	CONSTANT NUMBER := P_Sales_Credit_Tbl.count;
l_update_access_flag	     	VARCHAR2(1);
l_access_profile_rec	     	AS_ACCESS_PUB.Access_Profile_Rec_Type;

l_Sales_Team_Rec          	AS_ACCESS_PUB.Sales_Team_Rec_Type
                              	:= AS_ACCESS_PUB.G_MISS_SALES_TEAM_REC;



l_access_id			NUMBER;
l_customer_id			NUMBER;
l_address_id			NUMBER;
l_freeze_flag                 VARCHAR2(1) := 'N'; -- solin, for bug 1554330
l_allow_flag                  VARCHAR2(1);        -- solin, for bug 1554330
l_group_id_str                VARCHAR2(50);
l_val                         VARCHAR2(1);
l_temp_bool             BOOLEAN;
l_win_probability       NUMBER;
l_win_loss_indicator    as_statuses_b.win_loss_indicator%Type;
l_forecast_rollup_flag  as_statuses_b.forecast_rollup_flag%Type;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_upd_access_id			NUMBER;
l_upd_team_flag			VARCHAR2(1);
l_upd_date			DATE;
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Create_sales_credits';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SALES_CREDITS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API1 ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      /*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure
      -- is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_sales_credit_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_SALES_CREDIT_Rec      =>  P_SALES_CREDIT_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
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
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(P_Check_Access_Flag = 'Y') THEN
    	  AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              	p_api_version_number 	=> 2.0
             	,p_init_msg_list      	=> p_init_msg_list
             	,p_salesforce_id 	=> p_identity_salesforce_id
             	,p_admin_group_id 	=> p_admin_group_id
             	,x_return_status 	=> x_return_status
             	,x_msg_count 		=> x_msg_count
             	,x_msg_data 		=> x_msg_data
             	,x_sales_member_rec 	=> l_identity_sales_member_rec);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API2 Get_CurrentUser fail');
       	     END IF;
       	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;


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
		,p_opportunity_id	=> p_sales_credit_tbl(1).LEAD_ID
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id => p_identity_salesforce_id
		,p_partner_cont_party_id  => p_partner_cont_party_id
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag );

      	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'has_updateOpportunityAccess fail');
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

      -- solin, for bug 1554330
      OPEN c_get_opp_freeze_flag(p_sales_credit_tbl(1).LEAD_ID);
      FETCH c_get_opp_freeze_flag INTO l_freeze_flag;
      CLOSE c_get_opp_freeze_flag;

      IF l_freeze_flag = 'Y'
      THEN
          l_allow_flag := NVL(FND_PROFILE.VALUE('AS_ALLOW_UPDATE_FROZEN_OPP'),'Y');
          IF l_allow_flag <> 'Y' THEN
              AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_OPP_FROZEN');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      -- end 1554330

      FOR I in 1 .. l_sales_credit_count LOOP
      -- Invoke table handler(AS_SALES_CREDITS_PKG.Insert_Row)

          X_SALES_CREDIT_out_tbl(I).return_status := FND_API.G_RET_STS_SUCCESS;
          l_SALES_CREDIT_ID := p_SALES_CREDIT_Tbl(I).SALES_CREDIT_ID;

          -- Progress Message
          --
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
          THEN
              --FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
              --FND_MESSAGE.Set_Token ('ROW', 'AS_OPP_SALES_CREDIT', TRUE);
              --FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(I), FALSE);
              --FND_MSG_PUB.Add;
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Processing AS_OPP_SALES_CREDIT row number '||to_char(I));
             END IF;
          END IF;

          l_sales_credit_rec := p_SALES_CREDIT_tbl(I);

          -- Debug message
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API3 Validate_sales_credit');
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			l_sales_credit_rec.partner_customer_id);
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			l_sales_credit_rec.person_id);
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			l_sales_credit_rec.salesforce_id);
	  END IF;

	  IF nvl(l_sales_credit_rec.partner_customer_id, fnd_api.g_miss_num) = fnd_api.g_miss_num  and
      	     nvl(l_sales_credit_rec.person_id,           fnd_api.g_miss_num) = fnd_api.g_miss_num
  	  THEN
	     	open C_Person_Id(l_sales_credit_rec.salesforce_id);
	  	fetch C_Person_Id into l_sales_credit_rec.person_id;
	  	close C_Person_Id;
	  	IF  nvl(l_sales_credit_rec.person_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
	  	THEN
	      	    open C_Partner_Id(l_sales_credit_rec.salesforce_id);
	      	    fetch C_Partner_Id into l_sales_credit_rec.partner_customer_id,
				            l_sales_credit_rec.partner_address_id;
	      	    close C_Partner_Id;
	  	END IF;
  	  END IF;
         IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Before sales group');
	 END IF;

          -- Get partner contact's sales group id
         IF  nvl(l_sales_credit_rec.person_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
          AND  nvl(l_sales_credit_rec.salesgroup_id, fnd_api.g_miss_num) = fnd_api.g_miss_num

  	  THEN
              open C_Group_Id(l_sales_credit_rec.salesforce_id);
	      fetch C_Group_Id into l_group_id_str;
	      close C_Group_Id;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			l_group_id_str);
	  END IF;


          IF  l_group_id_str IS NOT NULL
          THEN
	     IF instr(l_group_id_str, '(') > 0
	      THEN
              l_sales_credit_rec.salesgroup_id := to_number(substr(l_group_id_str, 1, instr(l_group_id_str, '(') - 1));
              ELSE
              l_sales_credit_rec.salesgroup_id := to_number(l_group_id_str);
              END IF;

	  END IF;

          -- Invoke validation procedures
          Validate_sales_credit(
                  p_init_msg_list    => FND_API.G_FALSE,
              	  p_validation_level => p_validation_level,
              	  p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
              	  P_SALES_CREDIT_Rec  =>  l_SALES_CREDIT_Rec,
              	  x_return_status    => x_return_status,
              	  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Private API4 Validate_sales_credit fail');
	  END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;


          -- Debug Message
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API5 Calling create table handler');
	  END IF;

          Select lead.win_probability, status.win_loss_indicator,
                 status.forecast_rollup_flag
          Into   l_win_probability, l_win_loss_indicator,
                 l_forecast_rollup_flag
          From as_leads_all lead, as_statuses_vl status
          Where lead_id = l_sales_credit_rec.LEAD_ID
          And lead.status = status.status_code(+);

          l_temp_bool := Apply_Forecast_Defaults(l_win_probability,
              l_win_loss_indicator, 'N', -11, l_win_probability,
              l_win_loss_indicator, l_forecast_rollup_flag,
              l_sales_credit_rec.CREDIT_AMOUNT, 'ON-INSERT',
              l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT,
              l_sales_credit_rec.OPP_FORECAST_AMOUNT,
              l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT);
          -- Begin Added for ASNB
            IF (l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG IS NULL  or
	        l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG = FND_API.G_MISS_CHAR) AND
	        nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y'  AND
		nvl(fnd_profile.value('AS_FORECAST_CREDIT_TYPE_ID'), 'N') = l_sales_credit_rec.CREDIT_TYPE_ID
	    THEN
  	       l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG := 'Y';
	    END IF;
          -- End Added for ASNB
          AS_SALES_CREDITS_PKG.Insert_Row(
          	px_SALES_CREDIT_ID  => l_SALES_CREDIT_ID,
          	p_LAST_UPDATE_DATE  => SYSDATE,
          	p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          	p_CREATION_DATE  => SYSDATE,
          	p_CREATED_BY  => FND_GLOBAL.USER_ID,
          	p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          	p_REQUEST_ID  => l_sales_credit_rec.REQUEST_ID,
          	p_PROGRAM_APPLICATION_ID  => l_sales_credit_rec.PROGRAM_APPLICATION_ID,
          	p_PROGRAM_ID  => l_sales_credit_rec.PROGRAM_ID,
          	p_PROGRAM_UPDATE_DATE  => l_sales_credit_rec.PROGRAM_UPDATE_DATE,
          	p_LEAD_ID  => l_sales_credit_rec.LEAD_ID,
          	p_LEAD_LINE_ID  => l_sales_credit_rec.LEAD_LINE_ID,
          	p_SALESFORCE_ID  => l_sales_credit_rec.SALESFORCE_ID,
          	p_PERSON_ID  => l_sales_credit_rec.PERSON_ID,
          	p_SALESGROUP_ID  => l_sales_credit_rec.SALESGROUP_ID,
          	p_PARTNER_CUSTOMER_ID  => l_sales_credit_rec.PARTNER_CUSTOMER_ID,
          	p_PARTNER_ADDRESS_ID  => l_sales_credit_rec.PARTNER_ADDRESS_ID,
          	p_REVENUE_AMOUNT  => l_sales_credit_rec.REVENUE_AMOUNT,
          	p_REVENUE_PERCENT  => l_sales_credit_rec.REVENUE_PERCENT,
          	p_QUOTA_CREDIT_AMOUNT  => l_sales_credit_rec.QUOTA_CREDIT_AMOUNT,
          	p_QUOTA_CREDIT_PERCENT  => l_sales_credit_rec.QUOTA_CREDIT_PERCENT,
          	p_ATTRIBUTE_CATEGORY  => l_sales_credit_rec.ATTRIBUTE_CATEGORY,
          	p_ATTRIBUTE1  => l_sales_credit_rec.ATTRIBUTE1,
          	p_ATTRIBUTE2  => l_sales_credit_rec.ATTRIBUTE2,
          	p_ATTRIBUTE3  => l_sales_credit_rec.ATTRIBUTE3,
          	p_ATTRIBUTE4  => l_sales_credit_rec.ATTRIBUTE4,
          	p_ATTRIBUTE5  => l_sales_credit_rec.ATTRIBUTE5,
          	p_ATTRIBUTE6  => l_sales_credit_rec.ATTRIBUTE6,
          	p_ATTRIBUTE7  => l_sales_credit_rec.ATTRIBUTE7,
          	p_ATTRIBUTE8  => l_sales_credit_rec.ATTRIBUTE8,
          	p_ATTRIBUTE9  => l_sales_credit_rec.ATTRIBUTE9,
          	p_ATTRIBUTE10  => l_sales_credit_rec.ATTRIBUTE10,
          	p_ATTRIBUTE11  => l_sales_credit_rec.ATTRIBUTE11,
          	p_ATTRIBUTE12  => l_sales_credit_rec.ATTRIBUTE12,
          	p_ATTRIBUTE13  => l_sales_credit_rec.ATTRIBUTE13,
          	p_ATTRIBUTE14  => l_sales_credit_rec.ATTRIBUTE14,
          	p_ATTRIBUTE15  => l_sales_credit_rec.ATTRIBUTE15,
          	p_MANAGER_REVIEW_FLAG  => l_sales_credit_rec.MANAGER_REVIEW_FLAG,
          	p_MANAGER_REVIEW_DATE  => l_sales_credit_rec.MANAGER_REVIEW_DATE,
          	p_ORIGINAL_SALES_CREDIT_ID  => l_sales_credit_rec.ORIGINAL_SALES_CREDIT_ID,
          	-- p_CREDIT_TYPE  => l_sales_credit_rec.CREDIT_TYPE,
          	p_CREDIT_PERCENT  => l_sales_credit_rec.CREDIT_PERCENT,
          	p_CREDIT_AMOUNT  => l_sales_credit_rec.CREDIT_AMOUNT,
      		-- p_SECURITY_GROUP_ID  => l_sales_credit_rec.SECURITY_GROUP_ID,
          	p_CREDIT_TYPE_ID  => l_sales_credit_rec.CREDIT_TYPE_ID,
            p_OPP_WORST_FORECAST_AMOUNT => l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT,
            p_OPP_FORECAST_AMOUNT => l_sales_credit_rec.OPP_FORECAST_AMOUNT,
            p_OPP_BEST_FORECAST_AMOUNT => l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT,
	    P_DEFAULTED_FROM_OWNER_FLAG =>l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG -- -- Added for ASNB
            );

      	  -- Hint: Primary key should be returned.
          -- x_SALES_CREDIT_ID := px_SALES_CREDIT_ID;

          X_SALES_CREDIT_out_tbl(I).SALES_CREDIT_ID := l_SALES_CREDIT_ID;
          X_SALES_CREDIT_out_tbl(I).return_status := x_return_status;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
	  ELSE
	      IF l_debug THEN
	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API6 Created sales credit: ' ||l_SALES_CREDIT_ID );
	      END IF;

          END IF;



	  -- Add access for the salesforce who is assigned the sales credit

	  OPEN lead_customer(l_sales_credit_rec.LEAD_ID);
 	  FETCH lead_customer INTO l_customer_id, l_address_id;
	  CLOSE lead_customer;

          OPEN get_dup_sales_team(l_customer_id,l_address_id ,l_sales_credit_rec.LEAD_ID , l_sales_credit_rec.SALESFORCE_ID, l_sales_credit_rec.SALESGROUP_ID   );
          FETCH get_dup_sales_team into l_upd_team_flag,l_upd_date,l_upd_access_id;
      	      l_Sales_Team_Rec.team_leader_flag      := FND_API.G_MISS_CHAR;
      	      l_Sales_Team_Rec.lead_id               := l_sales_credit_rec.LEAD_ID;
      	      l_Sales_Team_Rec.customer_id           := l_Customer_Id;
      	      l_Sales_Team_Rec.address_id            := l_Address_Id;
      	      l_Sales_Team_Rec.salesforce_id         := l_sales_credit_rec.SALESFORCE_ID;
      	      l_sales_team_rec.sales_group_id 	 := l_sales_credit_rec.SALESGROUP_ID;
	      l_sales_team_rec.person_id 	 	 := l_sales_credit_rec.PERSON_ID;
              l_sales_team_rec.partner_customer_id   := l_sales_credit_rec.PARTNER_CUSTOMER_ID;
              l_sales_team_rec.partner_address_id    := l_sales_credit_rec.PARTNER_ADDRESS_ID;
          IF get_dup_sales_team%NOTFOUND THEN
          -- Jean 5/11, for bug 1610145
	  -- the following condition added for ASNB
	  IF   nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y'  then
	       l_Sales_Team_Rec.team_leader_flag      := 'Y';
	  ELSE
             IF(l_sales_credit_rec.CREDIT_TYPE_ID = FND_PROFILE.VALUE('AS_FORECAST_CREDIT_TYPE_ID') AND (l_sales_team_rec.partner_customer_id IS NULL OR l_sales_team_rec.partner_customer_id = FND_API.G_MISS_NUM))
     	     THEN
      	        l_Sales_Team_Rec.team_leader_flag      := 'Y';
              ELSE
	         l_Sales_Team_Rec.team_leader_flag      := 'N';
   	      END IF;
	  END IF;
	  -- end bug 1610145

      	  l_Sales_Team_Rec.reassign_flag         := 'N';
      	  l_Sales_Team_Rec.freeze_flag           :=
                         		nvl(FND_PROFILE.Value('AS_DEFAULT_FREEZE_FLAG'), 'Y');

      	  -- Debug Message
      	  IF l_debug THEN
      	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Create_SalesTeam');
	  END IF;

      	  AS_ACCESS_PUB.Create_SalesTeam (
         	p_api_version_number         => 2.0
        	,p_init_msg_list              => FND_API.G_FALSE
        	,p_commit                     => FND_API.G_FALSE
        	,p_validation_level           => p_Validation_Level
        	,p_access_profile_rec         => l_access_profile_rec
        	,p_check_access_flag          => P_Check_Access_flag
        	,p_admin_flag                 => P_Admin_Flag
        	,p_admin_group_id             => P_Admin_Group_Id
        	,p_identity_salesforce_id     => P_Identity_Salesforce_Id
        	,p_sales_team_rec             => l_Sales_Team_Rec
        	,X_Return_Status              => x_Return_Status
        	,X_Msg_Count                  => X_Msg_Count
        	,X_Msg_Data                   => X_Msg_Data
        	,x_access_id                  => l_Access_Id
      	  );

      	  -- Debug Message
      	  IF l_debug THEN
      	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Create_SalesTeam: l_access_id = ' || l_access_id);
	  END IF;

      	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	      IF l_debug THEN
      	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Create_SalesTeam fail');
	      END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          -- The following else part added for ASNB
	  /*
		Modified for bug# 4168544.
		If the sales creditor exists in the sales team then update the
		full access flag ie team_leader_flag to 'Y' if not already set.
	  */
	  ELSE -- get_dup_sales_team found
	    IF  nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y' AND
                 nvl(l_upd_team_flag,'N')  <> 'Y'
	    THEN
	       l_Sales_Team_Rec.last_update_date := l_upd_date;
	       l_Sales_Team_Rec.access_id := l_upd_access_id;
	       l_Sales_Team_Rec.team_leader_flag := 'Y';
	        AS_ACCESS_PUB.Update_SalesTeam (
                p_api_version_number         => 2.0
                ,p_init_msg_list              => FND_API.G_FALSE
                ,p_commit                     => FND_API.G_FALSE
                ,p_validation_level           => p_Validation_Level
                ,p_access_profile_rec         => l_access_profile_rec
                ,p_check_access_flag          =>  P_Check_Access_flag
                ,p_admin_flag                 => P_Admin_Flag
                ,p_admin_group_id             => P_Admin_Group_Id
                ,p_identity_salesforce_id     => P_Identity_Salesforce_Id
                ,p_sales_team_rec             => l_Sales_Team_Rec
                ,X_Return_Status              => x_Return_Status
                ,X_Msg_Count                  => X_Msg_Count
                ,X_Msg_Data                   => X_Msg_Data
                ,x_access_id                  => l_Access_Id );

		  -- Debug Message
		  IF l_debug THEN
		  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				   'update_SalesTeam: l_access_id = ' || l_access_id);
		  END IF;

		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		      IF l_debug THEN
		      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				   'update_SalesTeam fail');
		      END IF;
		      RAISE FND_API.G_EXC_ERROR;
		  END IF;
	    END IF;
          END IF;
          CLOSE get_dup_sales_team;
      End LOOP;

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
			'Private API7 ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      /*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout
      -- procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_sales_credit_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_SALES_CREDIT_Rec      =>  P_SALES_CREDIT_Rec,
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
End Create_sales_credits;


-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_sales_credits(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_profile_tbl              IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    p_partner_cont_party_id      IN  NUMBER  := FND_API.G_MISS_NUM,
    P_SALES_CREDIT_tbl           IN    AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_Type,
    X_SALES_CREDIT_out_tbl       OUT NOCOPY  AS_OPPORTUNITY_PUB.sales_credit_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

CURSOR C_Person_Id(p_resource_id NUMBER) IS
     	SELECT source_id
	FROM JTF_RS_RESOURCE_EXTNS
	WHERE resource_id = p_resource_id
	AND category = 'EMPLOYEE';

CURSOR C_Partner_Id(p_resource_id NUMBER) IS
     	SELECT source_id, address_id
	FROM JTF_RS_RESOURCE_EXTNS
	WHERE resource_id = p_resource_id
	AND category = 'PARTNER';

Cursor C_Get_sales_credit(c_SALES_CREDIT_ID Number) IS
    Select rowid,
           SALES_CREDIT_ID,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           LEAD_ID,
           LEAD_LINE_ID,
           SALESFORCE_ID,
           PERSON_ID,
           SALESGROUP_ID,
           PARTNER_CUSTOMER_ID,
           PARTNER_ADDRESS_ID,
           REVENUE_AMOUNT,
           REVENUE_PERCENT,
           QUOTA_CREDIT_AMOUNT,
           QUOTA_CREDIT_PERCENT,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           MANAGER_REVIEW_FLAG,
           MANAGER_REVIEW_DATE,
           ORIGINAL_SALES_CREDIT_ID,
           -- CREDIT_TYPE,
           CREDIT_PERCENT,
           CREDIT_AMOUNT,
	   -- SECURITY_GROUP_ID,
           CREDIT_TYPE_ID
    From  AS_SALES_CREDITS
    WHERE SALES_CREDIT_ID = c_SALES_CREDIT_ID
    -- Hint: Developer need to provide Where clause
    For Update NOWAIT;

-- solin, for bug 1554330
CURSOR c_get_opp_freeze_flag(c_LEAD_ID NUMBER) IS
    SELECT FREEZE_FLAG
    FROM AS_LEADS
    WHERE LEAD_ID = c_LEAD_ID;

CURSOR lead_customer( p_lead_id NUMBER) IS
	select customer_id, address_id
	from   as_leads
	where lead_id = p_lead_id;
/*
Modified for bug# 4168544.
Change the select clause so that it returns  team_leader_flag,last_update_date,access_id
instead of 'X'.
*/
cursor get_dup_sales_team(c_customer_id NUMBER,c_address_id NUMBER,c_lead_id NUMBER,c_salesforce_id NUMBER, c_sales_group_id NUMBER  ) is
    select team_leader_flag,last_update_date,access_id
    from as_accesses
    where customer_id = c_customer_id
          --and nvl(address_id, -99) = nvl(c_address_id, -99)
	  and nvl(lead_id, -99) = nvl(c_lead_id, -99)
	  and salesforce_id = c_salesforce_id
	  and nvl(sales_group_id, -99) = nvl(c_sales_group_id, -99);

cursor get_dup_sales_partner(c_customer_id NUMBER,c_address_id NUMBER,c_lead_id NUMBER,c_salesforce_id NUMBER, c_sales_group_id NUMBER  ) is
    select 'X'
    from as_accesses
    where customer_id = c_customer_id
          --and nvl(address_id, -99) = nvl(c_address_id, -99)
	  and nvl(lead_id, -99) = nvl(c_lead_id, -99)
	  and salesforce_id = c_salesforce_id;
	  --and nvl(sales_group_id, -99) = nvl(c_sales_group_id, -99);


l_api_name                	CONSTANT VARCHAR2(30) := 'Update_sales_credits';
l_api_version_number      	CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   	AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_ref_SALES_CREDIT_rec  	AS_OPPORTUNITY_PUB.SALES_CREDIT_Rec_Type;
l_tar_SALES_CREDIT_rec  	AS_OPPORTUNITY_PUB.SALES_CREDIT_Rec_Type;
l_SALES_CREDIT_rec      	AS_OPPORTUNITY_PUB.SALES_CREDIT_Rec_Type;
l_rowid  ROWID;
l_update_access_flag	     	VARCHAR2(1);
l_access_profile_rec	     	AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_freeze_flag                 VARCHAR2(1) := 'N'; -- solin, for bug 1554330
l_allow_flag                  VARCHAR2(1);        -- solin, for bug 1554330
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

l_Sales_Team_Rec          	AS_ACCESS_PUB.Sales_Team_Rec_Type
                              	:= AS_ACCESS_PUB.G_MISS_SALES_TEAM_REC;
l_access_id			NUMBER;
l_customer_id			NUMBER;
l_address_id			NUMBER;
l_val                         VARCHAR2(1);
l_temp_bool             BOOLEAN;
l_win_probability       NUMBER;
l_win_loss_indicator    as_statuses_b.win_loss_indicator%Type;
l_forecast_rollup_flag  as_statuses_b.forecast_rollup_flag%Type;

l_upd_access_id			NUMBER;
l_upd_team_flag			VARCHAR2(1);
l_upd_date			DATE;
l_forecast_credit_type_id   CONSTANT NUMBER := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
l_opp_worst_forecast_amount NUMBER;
l_opp_forecast_amount NUMBER;
l_opp_best_forecast_amount NUMBER;
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Update_sales_credits';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SALES_CREDITS_PVT;

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
			'Private API8 ' || l_api_name || ' start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      /*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout
      -- procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_sales_credit_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_SALES_CREDIT_Rec      =>  P_SALES_CREDIT_Rec,
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
      */

      IF(P_Check_Access_Flag = 'Y') THEN
    	  AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              	p_api_version_number 	=> 2.0
             	,p_init_msg_list      	=> p_init_msg_list
             	,p_salesforce_id 	=> p_identity_salesforce_id
             	,p_admin_group_id 	=> p_admin_group_id
             	,x_return_status 	=> x_return_status
             	,x_msg_count 		=> x_msg_count
             	,x_msg_data 		=> x_msg_data
             	,x_sales_member_rec 	=> l_identity_sales_member_rec);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API9 Get_CurrentUser fail');
       	     END IF;
       	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

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
		,p_opportunity_id	=> p_sales_credit_tbl(1).LEAD_ID
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id => p_identity_salesforce_id
		,p_partner_cont_party_id  => p_partner_cont_party_id
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag );

      	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'has_updateOpportunityAccess fail');
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

      -- solin, for bug 1554330
      OPEN c_get_opp_freeze_flag(p_sales_credit_tbl(1).LEAD_ID);
      FETCH c_get_opp_freeze_flag INTO l_freeze_flag;
      CLOSE c_get_opp_freeze_flag;

      IF l_freeze_flag = 'Y'
      THEN
          l_allow_flag := NVL(FND_PROFILE.VALUE('AS_ALLOW_UPDATE_FROZEN_OPP'),'Y');
          IF l_allow_flag <> 'Y' THEN
              AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_OPP_FROZEN');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      -- end 1554330

      FOR I in 1 .. P_SALES_CREDIT_tbl.count LOOP

          X_SALES_CREDIT_out_tbl(I).return_status := FND_API.G_RET_STS_SUCCESS;
          l_tar_SALES_CREDIT_rec := P_SALES_CREDIT_tbl(I);

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	     'Private API10processing sales_credit_id: ' || P_SALES_CREDIT_tbl(I).sales_credit_id );
	  END IF;


          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
          THEN
              --FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
              --FND_MESSAGE.Set_Token ('ROW', 'AS_OPP_SALES_CREDIT', TRUE);
              --FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(I), FALSE);
              --FND_MSG_PUB.Add;
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Processing AS_OPP_SALES_CREDIT row number '||to_char(I));
             END IF;
          END IF;

          l_sales_credit_rec := p_SALES_CREDIT_tbl(I);

          -- Debug Message
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Private API11- Open Cursor to Select');

          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private API1 SALES_CREDIT_ID = ' ||l_tar_SALES_CREDIT_rec.SALES_CREDIT_ID);
	  END IF;


          Open C_Get_sales_credit( l_tar_SALES_CREDIT_rec.SALES_CREDIT_ID);

          Fetch C_Get_sales_credit into
               l_rowid,
               l_ref_SALES_CREDIT_rec.SALES_CREDIT_ID,
               l_ref_SALES_CREDIT_rec.LAST_UPDATE_DATE,
               l_ref_SALES_CREDIT_rec.LAST_UPDATED_BY,
               l_ref_SALES_CREDIT_rec.CREATION_DATE,
               l_ref_SALES_CREDIT_rec.CREATED_BY,
               l_ref_SALES_CREDIT_rec.LAST_UPDATE_LOGIN,
               l_ref_SALES_CREDIT_rec.REQUEST_ID,
               l_ref_SALES_CREDIT_rec.PROGRAM_APPLICATION_ID,
               l_ref_SALES_CREDIT_rec.PROGRAM_ID,
               l_ref_SALES_CREDIT_rec.PROGRAM_UPDATE_DATE,
               l_ref_SALES_CREDIT_rec.LEAD_ID,
               l_ref_SALES_CREDIT_rec.LEAD_LINE_ID,
               l_ref_SALES_CREDIT_rec.SALESFORCE_ID,
               l_ref_SALES_CREDIT_rec.PERSON_ID,
               l_ref_SALES_CREDIT_rec.SALESGROUP_ID,
               l_ref_SALES_CREDIT_rec.PARTNER_CUSTOMER_ID,
               l_ref_SALES_CREDIT_rec.PARTNER_ADDRESS_ID,
               l_ref_SALES_CREDIT_rec.REVENUE_AMOUNT,
               l_ref_SALES_CREDIT_rec.REVENUE_PERCENT,
               l_ref_SALES_CREDIT_rec.QUOTA_CREDIT_AMOUNT,
               l_ref_SALES_CREDIT_rec.QUOTA_CREDIT_PERCENT,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE_CATEGORY,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE1,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE2,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE3,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE4,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE5,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE6,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE7,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE8,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE9,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE10,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE11,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE12,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE13,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE14,
               l_ref_SALES_CREDIT_rec.ATTRIBUTE15,
               l_ref_SALES_CREDIT_rec.MANAGER_REVIEW_FLAG,
               l_ref_SALES_CREDIT_rec.MANAGER_REVIEW_DATE,
               l_ref_SALES_CREDIT_rec.ORIGINAL_SALES_CREDIT_ID,
               -- l_ref_SALES_CREDIT_rec.CREDIT_TYPE,
               l_ref_SALES_CREDIT_rec.CREDIT_PERCENT,
               l_ref_SALES_CREDIT_rec.CREDIT_AMOUNT,
               -- l_ref_SALES_CREDIT_rec.SECURITY_GROUP_ID,
               l_ref_SALES_CREDIT_rec.CREDIT_TYPE_ID;

       If ( C_Get_sales_credit%NOTFOUND) Then

           IF l_debug THEN
           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private14PI: C_Get_sales_credit%NOTFOUND ');
	   END IF;

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'sales_credit', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF l_debug THEN
	       AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
       END IF;
       Close     C_Get_sales_credit;

      If (l_tar_SALES_CREDIT_rec.last_update_date is NULL or
          l_tar_SALES_CREDIT_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_SALES_CREDIT_rec.last_update_date <> l_ref_SALES_CREDIT_rec.last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'sales_credit', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Debug message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API15Validate_sales_credit');

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			l_sales_credit_rec.partner_customer_id);
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			l_sales_credit_rec.salesforce_id);
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			l_sales_credit_rec.person_id);
     END IF;


	  IF nvl(l_sales_credit_rec.partner_customer_id, fnd_api.g_miss_num) = fnd_api.g_miss_num  and
      	     nvl(l_sales_credit_rec.person_id,           fnd_api.g_miss_num) = fnd_api.g_miss_num
  	  THEN
	     	open C_Person_Id(l_sales_credit_rec.salesforce_id);
	  	fetch C_Person_Id into l_sales_credit_rec.person_id;
	  	close C_Person_Id;
	  	IF  nvl(l_sales_credit_rec.person_id, fnd_api.g_miss_num) = fnd_api.g_miss_num
	  	THEN
	      	    open C_Partner_Id(l_sales_credit_rec.salesforce_id);
	      	    fetch C_Partner_Id into l_sales_credit_rec.partner_customer_id,
				            l_sales_credit_rec.partner_address_id;
	      	    close C_Partner_Id;
	  	END IF;
  	  END IF;

      -- Invoke validation procedures
      Validate_sales_credit(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
              P_SALES_CREDIT_Rec  =>  l_SALES_CREDIT_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API: Validate_sales_credit fail');
	  END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private API: Calling update table handler');
      END IF;

      Select lead.win_probability, status.win_loss_indicator,
             status.forecast_rollup_flag
      Into   l_win_probability, l_win_loss_indicator,
             l_forecast_rollup_flag
      From as_leads_all lead, as_statuses_vl status
      Where lead_id = l_sales_credit_rec.LEAD_ID
      And lead.status = status.status_code(+);

	  IF l_sales_credit_rec.CREDIT_TYPE_ID = l_forecast_credit_type_id THEN
        -- No change in BFW values for quota creditssince this API is called in
        -- R12 Telesales to only change the credit owner and not anything else.
        l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT := NULL;
        l_sales_credit_rec.OPP_FORECAST_AMOUNT := NULL;
        l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT := NULL;
      ELSE
        l_opp_worst_forecast_amount := NULL;
        l_opp_forecast_amount := NULL;
        l_opp_best_forecast_amount := NULL;
        IF l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT <> FND_API.G_MISS_NUM THEN
            l_opp_worst_forecast_amount := l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT;
        END IF;
        IF l_sales_credit_rec.OPP_FORECAST_AMOUNT <> FND_API.G_MISS_NUM THEN
            l_opp_forecast_amount := l_sales_credit_rec.OPP_FORECAST_AMOUNT;
        END IF;
        IF l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT <> FND_API.G_MISS_NUM THEN
            l_opp_best_forecast_amount := l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT;
        END IF;

        IF l_opp_worst_forecast_amount IS NULL OR
           l_opp_forecast_amount IS NULL OR
           l_opp_best_forecast_amount IS NULL
        THEN
            l_temp_bool := Apply_Forecast_Defaults(l_win_probability,
                l_win_loss_indicator, l_forecast_rollup_flag, -11,
                l_win_probability,
                l_win_loss_indicator, l_forecast_rollup_flag,
                l_sales_credit_rec.CREDIT_AMOUNT, 'ON-UPDATE',
                l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT,
                l_sales_credit_rec.OPP_FORECAST_AMOUNT,
                l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT);

            -- Override manual values
            IF l_opp_worst_forecast_amount IS NOT NULL THEN
                l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT := l_opp_worst_forecast_amount;
            END IF;
            IF l_opp_forecast_amount IS NOT NULL THEN
                l_sales_credit_rec.OPP_FORECAST_AMOUNT := l_opp_forecast_amount;
            END IF;
            IF l_opp_best_forecast_amount IS NOT NULL THEN
                l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT := l_opp_best_forecast_amount;
            END IF;
        END IF;
      END IF;

      -- Begin Added for ASNB
      IF nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y'
         and (l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG IS NULL  or
              l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG = FND_API.G_MISS_CHAR)
      THEN
        IF nvl(fnd_profile.value('AS_FORECAST_CREDIT_TYPE_ID'), -1) = l_sales_credit_rec.CREDIT_TYPE_ID
        THEN
            l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG := 'Y';
        ELSE
            l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG := 'N';
        END IF;
      END IF;
      -- End Added for ASNB
      -- Invoke table handler(AS_SALES_CREDITS_PKG.Update_Row)
      AS_SALES_CREDITS_PKG.Update_Row(
          p_SALES_CREDIT_ID  => l_sales_credit_rec.SALES_CREDIT_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_CREATED_BY  => FND_API.G_MISS_NUM,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => l_sales_credit_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_sales_credit_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_sales_credit_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_sales_credit_rec.PROGRAM_UPDATE_DATE,
          p_LEAD_ID  => l_sales_credit_rec.LEAD_ID,
          p_LEAD_LINE_ID  => l_sales_credit_rec.LEAD_LINE_ID,
          p_SALESFORCE_ID  => l_sales_credit_rec.SALESFORCE_ID,
          p_PERSON_ID  => l_sales_credit_rec.PERSON_ID,
          p_SALESGROUP_ID  => l_sales_credit_rec.SALESGROUP_ID,
          p_PARTNER_CUSTOMER_ID  => l_sales_credit_rec.PARTNER_CUSTOMER_ID,
          p_PARTNER_ADDRESS_ID  => l_sales_credit_rec.PARTNER_ADDRESS_ID,
          p_REVENUE_AMOUNT  => l_sales_credit_rec.REVENUE_AMOUNT,
          p_REVENUE_PERCENT  => l_sales_credit_rec.REVENUE_PERCENT,
          p_QUOTA_CREDIT_AMOUNT  => l_sales_credit_rec.QUOTA_CREDIT_AMOUNT,
          p_QUOTA_CREDIT_PERCENT  => l_sales_credit_rec.QUOTA_CREDIT_PERCENT,
          p_ATTRIBUTE_CATEGORY  => l_sales_credit_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_sales_credit_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_sales_credit_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_sales_credit_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_sales_credit_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_sales_credit_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_sales_credit_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_sales_credit_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_sales_credit_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_sales_credit_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_sales_credit_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_sales_credit_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_sales_credit_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_sales_credit_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_sales_credit_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_sales_credit_rec.ATTRIBUTE15,
          p_MANAGER_REVIEW_FLAG  => l_sales_credit_rec.MANAGER_REVIEW_FLAG,
          p_MANAGER_REVIEW_DATE  => l_sales_credit_rec.MANAGER_REVIEW_DATE,
          p_ORIGINAL_SALES_CREDIT_ID  => l_sales_credit_rec.ORIGINAL_SALES_CREDIT_ID,
          -- p_CREDIT_TYPE  => l_sales_credit_rec.CREDIT_TYPE,
          p_CREDIT_PERCENT  => l_sales_credit_rec.CREDIT_PERCENT,
          p_CREDIT_AMOUNT  => l_sales_credit_rec.CREDIT_AMOUNT,
          -- p_SECURITY_GROUP_ID  => l_sales_credit_rec.SECURITY_GROUP_ID,
          p_CREDIT_TYPE_ID  => l_sales_credit_rec.CREDIT_TYPE_ID,
          p_OPP_WORST_FORECAST_AMOUNT => l_sales_credit_rec.OPP_WORST_FORECAST_AMOUNT,
          p_OPP_FORECAST_AMOUNT => l_sales_credit_rec.OPP_FORECAST_AMOUNT,
          p_OPP_BEST_FORECAST_AMOUNT => l_sales_credit_rec.OPP_BEST_FORECAST_AMOUNT,
	  P_DEFAULTED_FROM_OWNER_FLAG =>l_sales_credit_rec.DEFAULTED_FROM_OWNER_FLAG -- Added for ASNB
          );

        X_SALES_CREDIT_out_tbl(I).SALES_CREDIT_ID := l_sales_credit_rec.SALES_CREDIT_ID;
        X_SALES_CREDIT_out_tbl(I).return_status := x_return_status;

	IF l_debug THEN
	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private API17: Updated sales credit: ' ||l_sales_credit_rec.SALES_CREDIT_ID );
	END IF;

        if (l_sales_credit_rec.SALESGROUP_ID <> fnd_api.g_miss_num OR nvl(l_sales_credit_rec.PARTNER_CUSTOMER_ID, fnd_api.g_miss_num) <> fnd_api.g_miss_num)
        then
          -- Add access for the salesforce who is assigned the sales credit

	  OPEN lead_customer(l_sales_credit_rec.LEAD_ID);
 	  FETCH lead_customer INTO l_customer_id, l_address_id;
	  CLOSE lead_customer;

          IF nvl(l_sales_credit_rec.PARTNER_CUSTOMER_ID, fnd_api.g_miss_num) =fnd_api.g_miss_num
          THEN
          OPEN get_dup_sales_team(l_customer_id,l_address_id ,l_sales_credit_rec.LEAD_ID , l_sales_credit_rec.SALESFORCE_ID, l_sales_credit_rec.SALESGROUP_ID   );
          FETCH get_dup_sales_team into l_upd_team_flag,l_upd_date,l_upd_access_id;
      	      l_Sales_Team_Rec.team_leader_flag      := FND_API.G_MISS_CHAR;
      	      l_Sales_Team_Rec.lead_id               := l_sales_credit_rec.LEAD_ID;
      	      l_Sales_Team_Rec.customer_id           := l_Customer_Id;
      	      l_Sales_Team_Rec.address_id            := l_Address_Id;
      	      l_Sales_Team_Rec.salesforce_id         := l_sales_credit_rec.SALESFORCE_ID;
      	      l_sales_team_rec.sales_group_id 	 := l_sales_credit_rec.SALESGROUP_ID;
	      l_sales_team_rec.person_id 	 	 := l_sales_credit_rec.PERSON_ID;
              l_sales_team_rec.partner_customer_id   := l_sales_credit_rec.PARTNER_CUSTOMER_ID;
              l_sales_team_rec.partner_address_id    := l_sales_credit_rec.PARTNER_ADDRESS_ID;
          IF get_dup_sales_team%NOTFOUND THEN
          -- Jean 5/11, for bug 1610145

	  -- The followng condition added for ASNB
	  IF   nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y'  then
	       l_Sales_Team_Rec.team_leader_flag      := 'Y';
	  ELSE
             IF(l_sales_credit_rec.CREDIT_TYPE_ID = FND_PROFILE.VALUE('AS_FORECAST_CREDIT_TYPE_ID') AND (l_sales_team_rec.partner_customer_id IS NULL OR l_sales_team_rec.partner_customer_id = FND_API.G_MISS_NUM))
     	     THEN
      	        l_Sales_Team_Rec.team_leader_flag      := 'Y';
              ELSE
	         l_Sales_Team_Rec.team_leader_flag      := 'N';
   	      END IF;
	  END IF;
	  -- end bug 1610145

      	  l_Sales_Team_Rec.reassign_flag         := 'N';
      	  l_Sales_Team_Rec.freeze_flag           :=
                         		nvl(FND_PROFILE.Value('AS_DEFAULT_FREEZE_FLAG'), 'Y');

      	  -- Debug Message
      	  IF l_debug THEN
      	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Create_SalesTeam');
	  END IF;

      	  AS_ACCESS_PUB.Create_SalesTeam (
         	p_api_version_number         => 2.0
        	,p_init_msg_list              => FND_API.G_FALSE
        	,p_commit                     => FND_API.G_FALSE
        	,p_validation_level           => p_Validation_Level
        	,p_access_profile_rec         => l_access_profile_rec
        	,p_check_access_flag          => P_Check_Access_flag
        	,p_admin_flag                 => P_Admin_Flag
        	,p_admin_group_id             => P_Admin_Group_Id
        	,p_identity_salesforce_id     => P_Identity_Salesforce_Id
        	,p_sales_team_rec             => l_Sales_Team_Rec
        	,X_Return_Status              => x_Return_Status
        	,X_Msg_Count                  => X_Msg_Count
        	,X_Msg_Data                   => X_Msg_Data
        	,x_access_id                  => l_Access_Id
      	  );

      	  -- Debug Message
      	  IF l_debug THEN
      	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Create_SalesTeam: l_access_id = ' || l_access_id);
	  END IF;

      	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	      IF l_debug THEN
      	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Create_SalesTeam fail');
	      END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
	   -- The following else part added for ASNB
	  /*
		Modified for bug# 4168544.
		If the sales creditor exists in the sales team then update the
		full access flag ie team_leader_flag to 'Y' if not already set.
	  */
	  ELSE -- get_dup_sales_team found
	    IF  nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y' AND
                 nvl(l_upd_team_flag,'N')  <> 'Y'
	    THEN
	       l_Sales_Team_Rec.last_update_date := l_upd_date;
	       l_Sales_Team_Rec.access_id := l_upd_access_id;
	       l_Sales_Team_Rec.team_leader_flag := 'Y';
	        AS_ACCESS_PUB.Update_SalesTeam (
                p_api_version_number         => 2.0
                ,p_init_msg_list              => FND_API.G_FALSE
                ,p_commit                     => FND_API.G_FALSE
                ,p_validation_level           => p_Validation_Level
                ,p_access_profile_rec         => l_access_profile_rec
                ,p_check_access_flag          =>  P_Check_Access_flag
                ,p_admin_flag                 => P_Admin_Flag
                ,p_admin_group_id             => P_Admin_Group_Id
                ,p_identity_salesforce_id     => P_Identity_Salesforce_Id
                ,p_sales_team_rec             => l_Sales_Team_Rec
                ,X_Return_Status              => x_Return_Status
                ,X_Msg_Count                  => X_Msg_Count
                ,X_Msg_Data                   => X_Msg_Data
                ,x_access_id                  => l_Access_Id );

		  -- Debug Message
		  IF l_debug THEN
		  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				   'update_SalesTeam: l_access_id = ' || l_access_id);
		  END IF;

		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		      IF l_debug THEN
		      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				   'update_SalesTeam fail');
		      END IF;
		      RAISE FND_API.G_EXC_ERROR;
		  END IF;
	    END IF;
          END IF;
          CLOSE get_dup_sales_team;
          END IF;

          IF nvl(l_sales_credit_rec.PARTNER_CUSTOMER_ID, fnd_api.g_miss_num) <>fnd_api.g_miss_num
          THEN

          OPEN get_dup_sales_partner(l_customer_id,l_address_id ,l_sales_credit_rec.LEAD_ID , l_sales_credit_rec.SALESFORCE_ID, l_sales_credit_rec.SALESGROUP_ID   );
          FETCH get_dup_sales_partner into l_val;
          IF get_dup_sales_partner%NOTFOUND THEN
      	      l_Sales_Team_Rec.team_leader_flag      := FND_API.G_MISS_CHAR;
      	      l_Sales_Team_Rec.lead_id               := l_sales_credit_rec.LEAD_ID;
      	      l_Sales_Team_Rec.customer_id           := l_Customer_Id;
      	      l_Sales_Team_Rec.address_id            := l_Address_Id;
      	      l_Sales_Team_Rec.salesforce_id         := l_sales_credit_rec.SALESFORCE_ID;
      	      l_sales_team_rec.sales_group_id 	 := l_sales_credit_rec.SALESGROUP_ID;
	      l_sales_team_rec.person_id 	 	 := l_sales_credit_rec.PERSON_ID;
              l_sales_team_rec.partner_customer_id   := l_sales_credit_rec.PARTNER_CUSTOMER_ID;
              l_sales_team_rec.partner_address_id    := l_sales_credit_rec.PARTNER_ADDRESS_ID;
          -- Jean 5/11, for bug 1610145
          IF(l_sales_credit_rec.CREDIT_TYPE_ID = FND_PROFILE.VALUE('AS_FORECAST_CREDIT_TYPE_ID') AND (l_sales_team_rec.partner_customer_id IS NULL OR l_sales_team_rec.partner_customer_id = FND_API.G_MISS_NUM))
	  THEN
      	      l_Sales_Team_Rec.team_leader_flag      := 'Y';
          ELSE
	      l_Sales_Team_Rec.team_leader_flag      := 'N';
	  END IF;
	  -- end bug 1610145

      	  l_Sales_Team_Rec.reassign_flag         := 'N';
      	  l_Sales_Team_Rec.freeze_flag           :=
                         		nvl(FND_PROFILE.Value('AS_DEFAULT_FREEZE_FLAG'), 'Y');

      	  -- Debug Message
      	  IF l_debug THEN
      	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Create_SalesTeam');
	  END IF;

      	  AS_ACCESS_PUB.Create_SalesTeam (
         	p_api_version_number         => 2.0
        	,p_init_msg_list              => FND_API.G_FALSE
        	,p_commit                     => FND_API.G_FALSE
        	,p_validation_level           => p_Validation_Level
        	,p_access_profile_rec         => l_access_profile_rec
        	,p_check_access_flag          => P_Check_Access_flag
        	,p_admin_flag                 => P_Admin_Flag
        	,p_admin_group_id             => P_Admin_Group_Id
        	,p_identity_salesforce_id     => P_Identity_Salesforce_Id
        	,p_sales_team_rec             => l_Sales_Team_Rec
        	,X_Return_Status              => x_Return_Status
        	,X_Msg_Count                  => X_Msg_Count
        	,X_Msg_Data                   => X_Msg_Data
        	,x_access_id                  => l_Access_Id
      	  );

      	  -- Debug Message
      	  IF l_debug THEN
      	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Create_SalesTeam: l_access_id = ' || l_access_id);
	  END IF;

      	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	      IF l_debug THEN
      	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Create_SalesTeam fail');
	      END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          END IF;
          CLOSE get_dup_sales_partner;
          END IF;
       end if;

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
			'Private API: ' || l_api_name || 'end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      /*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout
      -- procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_sales_credit_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_SALES_CREDIT_Rec      =>  P_SALES_CREDIT_Rec,
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
End Update_sales_credits;


PROCEDURE modify_sales_credits(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER       := NULL,
    P_profile_tbl              IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    p_partner_cont_party_id      IN  NUMBER  := FND_API.G_MISS_NUM,
    P_SALES_CREDIT_tbl           IN    AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_Type,
    X_SALES_CREDIT_out_tbl       OUT NOCOPY  AS_OPPORTUNITY_PUB.sales_credit_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS

CURSOR C_DELETED_SALES_CREDITS(	p_lead_line_id NUMBER,
				p_forecast_credit_type_id NUMBER )IS
	SELECT *
	FROM AS_SALES_CREDITS
	WHERE lead_line_id = p_lead_line_id
	AND	credit_type_id = p_forecast_credit_type_id;

-- solin, for bug 1554330
CURSOR c_get_opp_freeze_flag(c_LEAD_ID NUMBER) IS
    SELECT FREEZE_FLAG
    FROM AS_LEADS
    WHERE LEAD_ID = c_LEAD_ID;

l_api_name                	CONSTANT VARCHAR2(30) := 'modify_sales_credits';
l_api_version_number      	CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec   	AS_SALES_MEMBER_PUB.Sales_member_rec_Type;

l_SALES_CREDIT_rec      	AS_OPPORTUNITY_PUB.SALES_CREDIT_Rec_Type;
l_total_forecast_amount		NUMBER;
l_total_forecast_percent	NUMBER	:= 0;
l_forecast_credit_type_id	NUMBER := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');

l_update_access_flag	     	VARCHAR2(1);
l_access_profile_rec	     	AS_ACCESS_PUB.Access_Profile_Rec_Type;

l_index				NUMBER;
l_sales_credit_tbl		AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_Type;
r_sales_credit_tbl		AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_Type;
n_sales_credit_tbl              AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_Type;
u_sales_credit_tbl              AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_Type;
d_sales_credit_tbl              AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_Type;
l_lead_line_id			NUMBER := p_sales_credit_tbl(1).lead_line_id;
l_freeze_flag                 VARCHAR2(1) := 'N'; -- solin, for bug 1554330
l_allow_flag                  VARCHAR2(1);        -- solin, for bug 1554330
J				NUMBER;
NL                              NUMBER;
UL                              NUMBER;
DL                              NUMBER;
delete_flag                     BOOLEAN;
s_index                         NUMBER;
e_index                         NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.modify_sales_credits';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT MODIFY_SALES_CREDITS_PVT;

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
			'Private API 18: ' || l_api_name || ' start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      IF(P_Check_Access_Flag = 'Y') THEN
    	  AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              	p_api_version_number 	=> 2.0
             	,p_init_msg_list      	=> p_init_msg_list
             	,p_salesforce_id 	=> p_identity_salesforce_id
             	,p_admin_group_id 	=> p_admin_group_id
             	,x_return_status 	=> x_return_status
             	,x_msg_count 		=> x_msg_count
             	,x_msg_data 		=> x_msg_data
             	,x_sales_member_rec 	=> l_identity_sales_member_rec);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API 19: Get_CurrentUser fail');
       	     END IF;
       	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

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
		,p_opportunity_id	=> p_sales_credit_tbl(1).LEAD_ID
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id => p_identity_salesforce_id
		,p_partner_cont_party_id  => p_partner_cont_party_id
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag );

      	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'has_updateOpportunityAccess fail');
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

      -- Jean correct here
      -- solin, for bug 1554330
      s_index := p_sales_credit_tbl.FIRST;
      --OPEN c_get_opp_freeze_flag(p_sales_credit_tbl(1).LEAD_ID);
      OPEN c_get_opp_freeze_flag(p_sales_credit_tbl(s_index).LEAD_ID);
      FETCH c_get_opp_freeze_flag INTO l_freeze_flag;
      CLOSE c_get_opp_freeze_flag;
      -- end of Jean correct

      IF l_freeze_flag = 'Y'
      THEN
          l_allow_flag := NVL(FND_PROFILE.VALUE('AS_ALLOW_UPDATE_FROZEN_OPP'),'Y');
          IF l_allow_flag <> 'Y' THEN
              AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_OPP_FROZEN');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      -- end 1554330

      IF l_forecast_credit_type_id IS NULL THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'The profile AS_FORECAST_CREDIT_TYPE_ID is null');
       	  END IF;
       	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Jean Correct the fix for the bug 2422928
      -- Filter out empty rows, Bug 2422928
      --J := 1;
      --FOR I in 1 .. P_SALES_CREDIT_tbl.count LOOP
      --	 IF p_SALES_CREDIT_tbl.exists(I) THEN
      --	     r_SALES_CREDIT_tbl(J) := p_SALES_CREDIT_tbl(I);
      --	     J := J + 1;
      --	 END IF;
      --END LOOP;

      --l_lead_line_id := r_sales_credit_tbl(1).lead_line_id;

      -- Validate 100% Forecast credit percent
      --FOR I in 1 .. P_SALES_CREDIT_tbl.count LOOP
      --	  l_sales_credit_rec := r_SALES_CREDIT_tbl(I);
      J := 1;
      s_index := P_SALES_CREDIT_tbl.FIRST;
      e_index := P_SALES_CREDIT_tbl.LAST;
      FOR I in s_index .. e_index LOOP
          IF p_SALES_CREDIT_tbl.exists(I) THEN
              r_SALES_CREDIT_tbl(J) := p_SALES_CREDIT_tbl(I);
      	      J := J + 1;
          END IF;
      END LOOP;

      FOR I in 1 .. r_SALES_CREDIT_tbl.count LOOP
          l_sales_credit_rec := r_SALES_CREDIT_tbl(I);

          -- Invoke validation procedures
          Validate_sales_credit(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => FND_API.G_MISS_CHAR, --AS_UTILITY_PVT.G_CREATE,
              P_SALES_CREDIT_Rec  =>  l_SALES_CREDIT_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API 21: Validate_sales_credit fail');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;


	  IF l_sales_credit_rec.credit_type_id <> l_forecast_credit_type_id THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API: Credit_type is not forecast credit type');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
 	  ELSE
	      l_total_forecast_amount := l_total_forecast_amount + l_sales_credit_rec.credit_amount;
	      l_total_forecast_percent := l_total_forecast_percent + l_sales_credit_rec.credit_percent;
	  END IF;

      END LOOP;

      -- 100% Validation
      IF  nvl(l_total_forecast_percent, 0) <> 100 THEN
          IF l_debug THEN
	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  	'Private API 23: 100% Forecast Credit validation fail');
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	        'Private API 24: l_total_percent = '||l_total_forecast_percent );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_lead_line_id IS NULL OR  l_lead_line_id = FND_API.G_MISS_NUM THEN
          IF l_debug THEN
	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  	'Private API 25: lead_line_id is missing in the first sales credit record');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Fix for the bug 2902247
      l_index := 1;

      NL := 1;
      UL :=1;
      FOR I in 1 .. r_SALES_CREDIT_tbl.count LOOP
	 IF r_SALES_CREDIT_tbl(I).sales_credit_id IS NULL OR r_SALES_CREDIT_tbl(I).sales_credit_id = FND_API.G_MISS_NUM  THEN
	     n_SALES_CREDIT_tbl(NL) := r_SALES_CREDIT_tbl(I);
	     NL := NL + 1;
          ELSE
             u_SALES_CREDIT_tbl(UL) := r_SALES_CREDIT_tbl(I);
             UL := UL+1;
	  END IF;
      END LOOP;

      DL := 1;
      FOR scr in C_DELETED_SALES_CREDITS(l_lead_line_id,l_forecast_credit_type_id) LOOP
          delete_flag := True;
          FOR I in 1 .. u_SALES_CREDIT_tbl.count LOOP
             if(scr.sales_credit_id = u_SALES_CREDIT_tbl(I).sales_credit_id)
             then
                 delete_flag := False;

             end if;
          END LOOP;
          IF(delete_flag = true)
          THEN
      	     d_sales_credit_tbl(DL).sales_credit_id := scr.sales_credit_id;
      	     d_sales_credit_tbl(DL).lead_id := scr.lead_id;
      	     d_sales_credit_tbl(DL).lead_line_id := scr.lead_line_id;
      	     DL := DL + 1;
          END IF;
      END LOOP;

      IF (DL <> 1)
      THEN
          AS_OPP_sales_credit_PVT.Delete_sales_credits(
      	      P_Api_Version_Number         => 2.0,
      	      P_Init_Msg_List              => FND_API.G_FALSE,
      	      P_Commit                     => FND_API.G_FALSE,
      	      P_Validation_Level           => FND_API.G_VALID_LEVEL_NONE,
      	      P_Check_Access_Flag          => FND_API.G_FALSE,
      	      P_Admin_Flag                 => P_Admin_Flag,
      	      P_Admin_Group_Id             => P_Admin_Group_Id,
      	      P_Profile_Tbl                => P_Profile_tbl,
      	      P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
      	      P_Identity_Salesforce_Id     => p_identity_salesforce_id,
      	      P_Sales_Credit_Tbl	   => d_sales_credit_tbl,
      	      X_Sales_Credit_Out_Tbl       => x_sales_credit_out_tbl,
      	      X_Return_Status              => x_return_status,
      	      X_Msg_Count                  => x_msg_count,
      	      X_Msg_Data                   => x_msg_data);

          -- Check return status from the above procedure call
          IF x_return_status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      		    'Private API 26: Delete_Sales_credits fail');
              END IF;
          END IF;
     END IF;

     IF (NL <> 1)
     THEN
         AS_OPP_sales_credit_PVT.Create_sales_credits(
      	     P_Api_Version_Number         => 2.0,
      	     P_Init_Msg_List              => FND_API.G_FALSE,
       	     P_Commit                     => FND_API.G_FALSE,
      	     P_Validation_Level           => FND_API.G_VALID_LEVEL_NONE,
      	     P_Check_Access_Flag          => FND_API.G_FALSE,
      	     P_Admin_Flag                 => P_Admin_Flag ,
      	     P_Admin_Group_Id             => P_Admin_Group_Id,
      	     P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      	     P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
      	     P_Profile_Tbl                => P_Profile_tbl,
      	     P_Sales_Credit_Tbl	          => n_sales_credit_tbl,
      	     X_Sales_Credit_Out_Tbl       => x_sales_credit_out_tbl,
      	     X_Return_Status              => x_return_status,
      	     X_Msg_Count                  => x_msg_count,
      	     X_Msg_Data                   => x_msg_data);


         -- Check return status from the above procedure call
         IF x_return_status = FND_API.G_RET_STS_ERROR then
             raise FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      		   'Private API 27: Create_Sales_credits fail');
             END IF;
         END IF;
      END IF;

      IF (UL <>1)
      THEN
          AS_OPP_sales_credit_PVT.Update_sales_credits(
      	      P_Api_Version_Number         => 2.0,
      	      P_Init_Msg_List              => FND_API.G_FALSE,
       	      P_Commit                     => FND_API.G_FALSE,
      	      P_Validation_Level           => FND_API.G_VALID_LEVEL_NONE,
      	      P_Check_Access_Flag          => FND_API.G_FALSE,
      	      P_Admin_Flag                 => P_Admin_Flag ,
      	      P_Admin_Group_Id             => P_Admin_Group_Id,
      	      P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      	      P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
      	      P_Profile_Tbl                => P_Profile_tbl,
      	      P_Sales_Credit_Tbl	   => u_sales_credit_tbl,
      	      X_Sales_Credit_Out_Tbl       => x_sales_credit_out_tbl,
      	      X_Return_Status              => x_return_status,
      	      X_Msg_Count                  => x_msg_count,
      	      X_Msg_Data                   => x_msg_data);


           -- Check return status from the above procedure call
          IF x_return_status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      		   'Private API 28: Update_Sales_credits fail');
              END IF;
          END IF;
      END IF;

      --FOR scr in C_DELETED_SALES_CREDITS(l_lead_line_id,l_forecast_credit_type_id) LOOP
      --	  l_sales_credit_tbl(l_index).sales_credit_id := scr.sales_credit_id;
      --	  l_sales_credit_tbl(l_index).lead_id := scr.lead_id;
      --	  l_sales_credit_tbl(l_index).lead_line_id := scr.lead_line_id;
      --	  l_index := l_index + 1;
      --END LOOP;

      --AS_OPP_sales_credit_PVT.Delete_sales_credits(
      --	  P_Api_Version_Number         => 2.0,
      --	  P_Init_Msg_List              => FND_API.G_FALSE,
      --	  P_Commit                     => FND_API.G_FALSE,
      --	  P_Validation_Level           => FND_API.G_VALID_LEVEL_NONE,
      --	  P_Check_Access_Flag          => FND_API.G_FALSE,
      --	  P_Admin_Flag                 => P_Admin_Flag,
      --	  P_Admin_Group_Id             => P_Admin_Group_Id,
      --	  P_Profile_Tbl                => P_Profile_tbl,
      --	  P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
      --	  P_Identity_Salesforce_Id     => p_identity_salesforce_id,
      --	  P_Sales_Credit_Tbl	       => l_sales_credit_tbl,
      --	  X_Sales_Credit_Out_Tbl       => x_sales_credit_out_tbl,
      --	  X_Return_Status              => x_return_status,
      --	  X_Msg_Count                  => x_msg_count,
      --	  X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      --IF x_return_status = FND_API.G_RET_STS_ERROR then
      --    raise FND_API.G_EXC_ERROR;
      --elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      --    raise FND_API.G_EXC_UNEXPECTED_ERROR;
      --END IF;

      --IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --		'Private API 26: Delete_Sales_credits fail');
      --END IF;


      --AS_OPP_sales_credit_PVT.Create_sales_credits(
      --	  P_Api_Version_Number         => 2.0,
      --	  P_Init_Msg_List              => FND_API.G_FALSE,
      -- 	  P_Commit                     => FND_API.G_FALSE,
      --	  P_Validation_Level           => FND_API.G_VALID_LEVEL_NONE,
      --	  P_Check_Access_Flag          => FND_API.G_FALSE,
      --	  P_Admin_Flag                 => P_Admin_Flag ,
      --	  P_Admin_Group_Id             => P_Admin_Group_Id,
      --	  P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      --	  P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
      --	  P_Profile_Tbl                => P_Profile_tbl,
      --	  P_Sales_Credit_Tbl	       => r_sales_credit_tbl,
      --	  X_Sales_Credit_Out_Tbl       => x_sales_credit_out_tbl,
      --	  X_Return_Status              => x_return_status,
      --	  X_Msg_Count                  => x_msg_count,
      --	  X_Msg_Data                   => x_msg_data);


      -- Check return status from the above procedure call
      --IF x_return_status = FND_API.G_RET_STS_ERROR then
      --    raise FND_API.G_EXC_ERROR;
      --elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      --    raise FND_API.G_EXC_UNEXPECTED_ERROR;
      --END IF;

      --IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --		'Private API 27: Create_Sales_credits fail');
      --END IF;
      -- end of the fix for the bug 2902247


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
			'Private API 28: ' || l_api_name || 'end');
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
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

End modify_sales_credits;


-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.
PROCEDURE Delete_sales_credits(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_identity_salesforce_id     IN   NUMBER       := NULL,
    p_partner_cont_party_id      IN  NUMBER  := FND_API.G_MISS_NUM,
    P_SALES_CREDIT_tbl           IN AS_OPPORTUNITY_PUB.SALES_CREDIT_tbl_type,
    X_SALES_CREDIT_out_tbl       OUT NOCOPY  AS_OPPORTUNITY_PUB.sales_credit_out_tbl_type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
-- solin, for bug 1554330
CURSOR c_get_opp_freeze_flag(c_LEAD_ID NUMBER) IS
    SELECT FREEZE_FLAG
    FROM AS_LEADS
    WHERE LEAD_ID = c_LEAD_ID;

l_api_name                	CONSTANT VARCHAR2(30) := 'Delete_sales_credits';
l_api_version_number      	CONSTANT NUMBER   := 2.0;
l_identity_sales_member_rec  	AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_update_access_flag	     	VARCHAR2(1);
l_access_profile_rec	     	AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_freeze_flag                 VARCHAR2(1) := 'N'; -- solin, for bug 1554330
l_allow_flag                  VARCHAR2(1);        -- solin, for bug 1554330
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Delete_sales_credits';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SALES_CREDITS_PVT;

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
       				'Private API 29: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      /*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout
      -- procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_sales_credit_BD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_SALES_CREDIT_Rec      =>  P_SALES_CREDIT_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
      */


      IF(P_Check_Access_Flag = 'Y') THEN
    	AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              	p_api_version_number 	=> 2.0
             	,p_init_msg_list      	=> p_init_msg_list
             	,p_salesforce_id 	=> p_identity_salesforce_id
             	,p_admin_group_id 	=> p_admin_group_id
             	,x_return_status 	=> x_return_status
             	,x_msg_count 		=> x_msg_count
             	,x_msg_data 		=> x_msg_data
             	,x_sales_member_rec 	=> l_identity_sales_member_rec);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API 30: Get_CurrentUser fail');
       	     END IF;
       	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

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
		,p_opportunity_id	=> p_sales_credit_tbl(1).LEAD_ID
		,p_check_access_flag    => p_check_access_flag
		,p_identity_salesforce_id => p_identity_salesforce_id
		,p_partner_cont_party_id  => p_partner_cont_party_id
		,x_return_status	=> x_return_status
		,x_msg_count		=> x_msg_count
		,x_msg_data		=> x_msg_data
		,x_update_access_flag	=> l_update_access_flag );

      	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'has_updateOpportunityAccess fail');
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

      -- solin, for bug 1554330
      OPEN c_get_opp_freeze_flag(p_sales_credit_tbl(1).LEAD_ID);
      FETCH c_get_opp_freeze_flag INTO l_freeze_flag;
      CLOSE c_get_opp_freeze_flag;

      IF l_freeze_flag = 'Y'
      THEN
          l_allow_flag := NVL(FND_PROFILE.VALUE('AS_ALLOW_UPDATE_FROZEN_OPP'),'Y');
          IF l_allow_flag <> 'Y' THEN
              AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_OPP_FROZEN');
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      -- end 1554330

      -- Invoke table handler(AS_SALES_CREDITS_PKG.Delete_Row)
     FOR I in 1 .. P_SALES_CREDIT_tbl.count LOOP

       X_SALES_CREDIT_out_tbl(I).return_status := FND_API.G_RET_STS_SUCCESS;

       -- Progress Message
       --
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
          THEN
              --FND_MESSAGE.Set_Name ('AS', 'API_PROCESSING_ROW');
              --FND_MESSAGE.Set_Token ('ROW', 'AS_OPP_SALES_CREDIT', TRUE);
              --FND_MESSAGE.Set_Token ('RECORD_NUM', to_char(I), FALSE);
              --FND_MSG_PUB.Add;
             IF l_debug THEN
             AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Processing AS_OPP_SALES_CREDIT row number '||to_char(I));
             END IF;
          END IF;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'Private API 31: Calling delete table handler');
      END IF;

      AS_SALES_CREDITS_PKG.Delete_Row(
          p_SALES_CREDIT_ID  => p_SALES_CREDIT_tbl(I).SALES_CREDIT_ID);

      X_SALES_CREDIT_out_tbl(I).SALES_CREDIT_ID := p_SALES_CREDIT_tbl(I).SALES_CREDIT_ID;
      X_SALES_CREDIT_out_tbl(I).return_status := x_return_status;

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
				'Private API 32: ' || l_api_name || 'end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      -- Un-comment the following statements when AS_CALLOUT_PKG is ready.
      /*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout
      -- procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_sales_credit_AD(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_SALES_CREDIT_Rec      =>  P_SALES_CREDIT_Rec,
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
End Delete_sales_credits;


-- Item-level validation procedures
PROCEDURE Validate_SALES_CREDIT_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_CREDIT_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
CURSOR	C_Sales_Credit_Id_Exists (c_Sales_Credit_Id NUMBER) IS
      	SELECT 'X'
      	FROM  as_sales_credits
      	WHERE sales_credit_id = c_Sales_Credit_Id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_SALES_CREDIT_ID';


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
          IF (p_SALES_CREDIT_ID is NOT NULL) and (p_SALES_CREDIT_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_Sales_Credit_Id_Exists (p_Sales_Credit_Id);
              FETCH C_Sales_Credit_Id_Exists into l_val;
              IF C_Sales_Credit_Id_Exists%FOUND THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                               'Private API 33: SALES_CREDIT_ID exist');
		  END IF;

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Sales_Credit_Id_Exists;
          END IF;

      -- Calling from Update API
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_SALES_CREDIT_ID is NULL) or (p_SALES_CREDIT_ID = FND_API.G_MISS_NUM)
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                          'Private API 34: Violate NOT NULL constraint(SALES_CREDIT_ID)');
	      END IF;
              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_Sales_Credit_Id_Exists (p_Sales_Credit_Id);
              FETCH C_Sales_Credit_Id_Exists into l_val;
              IF C_Sales_Credit_Id_Exists%NOTFOUND
              THEN
                  IF l_debug THEN
                  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                         'Private API 35: SALES_CREDIT_ID is not valid');
		  END IF;

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Sales_Credit_Id_Exists;
          END IF;

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SALES_CREDIT_ID;


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
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_LEAD_ID';


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
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_LEAD_LINE_ID';

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


PROCEDURE Validate_SALESFORCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SALESFORCE_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_Salesforce_Id_Exists (c_Salesforce_Id NUMBER) IS
      	SELECT 'X'
      	FROM  as_salesforce_v
      	WHERE salesforce_id = c_Salesforce_Id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_SALESFORCE_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF (p_SALESFORCE_ID is NULL) or (p_SALESFORCE_ID = FND_API.G_MISS_NUM)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                      'Private API 40: Violate NOT NULL constraint(SALESFORCE_ID)');
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          OPEN  C_Salesforce_Id_Exists (p_Salesforce_Id);
          FETCH C_Salesforce_Id_Exists into l_val;
          IF C_Salesforce_Id_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API 41: SALESFORCE_ID is not valid');
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Salesforce_Id_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SALESFORCE_ID;


PROCEDURE Validate_PERSON_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PERSON_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_PERSON_ID_Exists(c_PERSON_ID NUMBER) IS
	SELECT 'X'
	FROM  	as_salesforce_v
	WHERE 	EMPLOYEE_PERSON_ID = c_PERSON_ID;

l_val	VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_PERSON_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PERSON_ID is NOT NULL) and
         (p_PERSON_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_PERSON_ID_Exists (p_PERSON_ID);
          FETCH C_PERSON_ID_Exists into l_val;
          IF C_PERSON_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API 42: PERSON_ID is invalid');
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_PERSON_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PERSON_ID;


PROCEDURE Validate_SALESGROUP_ID(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SALESGROUP_ID              IN   NUMBER,
    P_PERSON_ID                  IN NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_SALES_GROUP_ID_Exists(c_SALES_GROUP_ID NUMBER) IS
	SELECT 'X'
	FROM  	as_sales_groups_v
	WHERE 	SALES_GROUP_ID = c_SALES_GROUP_ID;

CURSOR 	C_PRTNR_SALES_GROUP_ID_Exists(c_SALES_GROUP_ID NUMBER) IS
	SELECT 'X'
	FROM  	JTF_RS_GROUPS_B a, JTF_RS_GROUP_USAGES b
	WHERE 	a.group_id = b.group_id
	AND     b.usage in ('SALES','PRM')
        AND     sysdate between nvl(a.start_date_active,sysdate) and
                nvl(a.end_date_active,sysdate)
	AND a.group_id = c_SALES_GROUP_ID;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*   IF (p_SALESGROUP_ID is NOT NULL) and (p_SALESGROUP_ID <>
FND_API.G_MISS_NUM)
      THEN
          IF (p_PERSON_ID is NOT NULL) and (p_PERSON_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_SALES_GROUP_ID_Exists (p_SALESGROUP_ID);
              FETCH C_SALES_GROUP_ID_Exists into l_val;
              IF C_SALES_GROUP_ID_Exists%NOTFOUND THEN
                 IF l_debug THEN
                 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'SALES_GROUP_ID1 is invalid');
                 END IF;

                 x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_SALES_GROUP_ID_Exists;
	   ELSE
	      OPEN  C_PRTNR_SALES_GROUP_ID_Exists (p_SALESGROUP_ID);
              FETCH C_PRTNR_SALES_GROUP_ID_Exists into l_val;
              IF C_PRTNR_SALES_GROUP_ID_Exists%NOTFOUND THEN
                 IF l_debug THEN
                 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'SALES_GROUP_ID2 is invalid');
                 END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_PRTNR_SALES_GROUP_ID_Exists;
	   END IF;
      END IF;

*/
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SALESGROUP_ID;


PROCEDURE Validate_PARTNER_CUSTOMER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTNER_CUSTOMER_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_PARTNER_CUSTOMER_ID_Exists(c_PARTNER_CUSTOMER_ID NUMBER) IS
	SELECT 'X'
	FROM  	as_salesforce_v
	WHERE 	PARTNER_CUSTOMER_ID = c_PARTNER_CUSTOMER_ID;

l_val	VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_PARTNER_CUSTOMER_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PARTNER_CUSTOMER_ID is NOT NULL) and
         (p_PARTNER_CUSTOMER_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_PARTNER_CUSTOMER_ID_Exists (p_PARTNER_CUSTOMER_ID);
          FETCH C_PARTNER_CUSTOMER_ID_Exists into l_val;
          IF C_PARTNER_CUSTOMER_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API 43: PARTNER_CUSTOMER_ID is invalid');
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_PARTNER_CUSTOMER_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARTNER_CUSTOMER_ID;


PROCEDURE Validate_PARTNER_ADDRESS_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTNER_ADDRESS_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_PARTNER_ADDRESS_ID_Exists(c_PARTNER_ADDRESS_ID NUMBER) IS
	SELECT 'X'
	FROM  	as_salesforce_v
	WHERE 	PARTNER_ADDRESS_ID = c_PARTNER_ADDRESS_ID;

l_val	VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_PARTNER_ADDRESS_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PARTNER_ADDRESS_ID is NOT NULL) and
         (p_PARTNER_ADDRESS_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_PARTNER_ADDRESS_ID_Exists (p_PARTNER_ADDRESS_ID);
          FETCH C_PARTNER_ADDRESS_ID_Exists into l_val;
          IF C_PARTNER_ADDRESS_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                     'Private API 44: PARTNER_ADDRESS_ID is invalid');
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_PARTNER_ADDRESS_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARTNER_ADDRESS_ID;


PROCEDURE Validate_CREDIT_TYPE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CREDIT_TYPE_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR 	C_Credit_Type_Id_Exists (c_Credit_Type_Id NUMBER) IS
      	SELECT 'X'
      	FROM  oe_sales_credit_types
      	WHERE sales_credit_type_id = c_Credit_Type_Id;

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_CREDIT_TYPE_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF (p_CREDIT_TYPE_ID is NULL) or (p_CREDIT_TYPE_ID = FND_API.G_MISS_NUM)
      THEN
          --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
          --            'Private API 45: Violate NOT NULL constraint(CREDIT_TYPE_ID)');

           AS_UTILITY_PVT.Set_Message(
              p_module        => l_module,
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'CREDIT_TYPE_ID');


          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          OPEN  C_Credit_Type_Id_Exists (p_Credit_Type_Id);
          FETCH C_Credit_Type_Id_Exists into l_val;
          IF C_Credit_Type_Id_Exists%NOTFOUND
          THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                 'Private API 46: CREDIT_TYPE_ID is not valid');
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Credit_Type_Id_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CREDIT_TYPE_ID;


-- Hint: inter-field level validation can be added here.
-- Hint: If p_validation_mode = AS_UTILITY_PVT.G_VALIDATE_UPDATE, we should use cursor
--       to get old values for all fields used in inter-field validation and set all
--       G_MISS_XXX fields to original value stored in database table.
PROCEDURE Validate_SALES_CREDIT_rec(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_CREDIT_Rec     IN    AS_OPPORTUNITY_PUB.SALES_CREDIT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

CURSOR C_Salesforce_Person_Exists (X_Salesforce_Id NUMBER,
             			X_Person_Id NUMBER ) IS
      SELECT 'X'
      FROM   jtf_rs_resource_extns res,
	     jtf_rs_role_relations rrel,
	     jtf_rs_roles_b role
      WHERE  sysdate between res.start_date_active  and nvl(res.end_date_active,sysdate)
      AND    sysdate between rrel.start_date_active and nvl(rrel.end_date_active,sysdate)
      AND    res.resource_id = rrel.role_resource_id
      AND    rrel.role_resource_type = 'RS_INDIVIDUAL'
      AND    rrel.role_id = role.role_id
      AND    role.role_type_code IN ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
      AND    role.admin_flag = 'N'
      AND    res.resource_id = X_Salesforce_Id
      AND    res.source_id = X_Person_Id
      AND    res.category ='EMPLOYEE';

CURSOR C_Salesforce_Partner_Exists (X_Salesforce_Id NUMBER,
             			X_Partner_Customer_Id NUMBER) IS
      	SELECT  'X'
      	FROM  as_salesforce_v
      	WHERE ((type = 'PARTNER' and partner_customer_id =  X_Partner_Customer_Id)
        or (type = 'PARTY' and partner_contact_id  = X_Partner_Customer_Id))
        AND salesforce_id = X_Salesforce_Id;

CURSOR C_Salesgroup_Exists (X_Sales_Group_Id NUMBER) IS
  	SELECT  'X'
      	FROM  as_sales_groups_v
      	WHERE sales_group_id = X_Sales_Group_Id;

l_val   	VARCHAR2(1);
l_api_name   	CONSTANT VARCHAR2(30) := 'Validate_sales_credit_rec';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_SALES_CREDIT_rec';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private API 47: ' || l_api_name || ' start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Validate member columns
      --
      -- Member must exist
      --
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'salesforce id' || p_sales_credit_rec.salesforce_id);

      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'person_id' || p_sales_credit_rec.person_id);
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'partner_customer_id' || p_sales_credit_rec.partner_customer_id);
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'partner_customer_id' || p_sales_credit_rec.salesgroup_id);
      END IF;


      IF p_sales_credit_rec.salesforce_id is NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'TRANS_SALESFORCE', TRUE);
              FND_MSG_PUB.ADD;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private API 48: SALESFORCE_ID is NULL');
	  END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;

      -- Employee and Partner cannot exist in the same record
      --
     -- ELSIF ( nvl(p_sales_credit_rec.partner_customer_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num  or
     --         nvl(p_sales_credit_rec.partner_address_id,  fnd_api.g_miss_num) <> fnd_api.g_miss_num ) and
     -- 	    ( nvl(p_sales_credit_rec.person_id,           fnd_api.g_miss_num) <> fnd_api.g_miss_num or
     --         nvl(p_sales_credit_rec.salesgroup_id,       fnd_api.g_miss_num) <> fnd_api.g_miss_num )
       ELSIF ( nvl(p_sales_credit_rec.partner_customer_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num) and
      	     (nvl(p_sales_credit_rec.person_id,           fnd_api.g_miss_num) <> fnd_api.g_miss_num)


      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_MEMBER_TOO_MANY_VALUES');
              FND_MSG_PUB.ADD;
          END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;

      -- Validate employee if one exists
      --
      ELSIF nvl(p_sales_credit_rec.person_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN

        -- First sales group must exist for employee sales credit record
        --
	-- Fix bug 855326 Remove the checking on salesgroup_id, Actually
	-- If an admin who is not in any group created an opp., sales group
	-- id in sales credit table would be NULL. So, remove this logic.
	--        IF p_sales_credit_rec.salesgroup_id is NULL
	--        THEN
	--              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	--              THEN
	--                  FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
	--                FND_MESSAGE.Set_Token('COLUMN', 'SALESGROUP_ID', FALSE);
	--                  FND_MSG_PUB.ADD;
	--              END IF;
	--
	--              l_return_status := FND_API.G_RET_STS_ERROR;
	--
	--        ELSE

          OPEN C_Salesforce_Person_Exists (p_sales_credit_rec.salesforce_id,
                 			p_sales_credit_rec.person_id );
          FETCH C_Salesforce_Person_Exists INTO l_val;
          IF C_Salesforce_Person_Exists%NOTFOUND
          THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                    FND_MESSAGE.Set_Token('COLUMN', 'SALESFORCE_ID, PERSON_ID', FALSE);
                      FND_MESSAGE.Set_Token('VALUE', p_sales_credit_rec.salesforce_id || ',' ||
                     p_sales_credit_rec.person_id, FALSE);
                      FND_MSG_PUB.ADD;
                  END IF;

                  x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Salesforce_Person_Exists;

      -- Validate that partner exists
      --
      ELSIF nvl(p_sales_credit_rec.partner_customer_id,fnd_api.g_miss_num) <> fnd_api.g_miss_num
      THEN
          OPEN C_Salesforce_Partner_Exists (p_sales_credit_rec.salesforce_id,
                  			    p_sales_credit_rec.partner_customer_id);
          FETCH C_Salesforce_Partner_Exists INTO l_val;
          IF C_Salesforce_Partner_Exists%NOTFOUND
          THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                  FND_MESSAGE.Set_Name('AS', 'API_INVALID_ID');
                  FND_MESSAGE.Set_Token('COLUMN', 'SALESFORCE_ID, PARTNER_CUSTOMER_ID,
					PARTNER_ADDRESS_ID', FALSE);
                  FND_MESSAGE.Set_Token('VALUE', p_sales_credit_rec.salesforce_id || ',' ||
                      		p_sales_credit_rec.partner_customer_id || ',' ||
                    		p_sales_credit_rec.partner_address_id , FALSE);
                  FND_MSG_PUB.ADD;
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Salesforce_Partner_Exists;
      ELSE
	  IF l_debug THEN
	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private API 49: Both PERSON_ID and PARTNER_CUSTOMER_ID are NULL');
	  END IF;

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private API 50: ' || l_api_name || ' end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SALES_CREDIT_Rec;

PROCEDURE Validate_sales_credit(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_CREDIT_Rec     IN    AS_OPPORTUNITY_PUB.SALES_CREDIT_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_sales_credit';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.Validate_sales_credit';

 BEGIN

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		'Private API 51: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM) THEN
          -- Hint: We provide validation procedure for every column. Developer should delete
          --       unnecessary validation procedures.

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API 52: Validate Items start');
	  END IF;
	  -- Begin Added for ASNB
          IF  nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N')   = 'Y'  AND
	      nvl(fnd_profile.value('AS_FORECAST_CREDIT_TYPE_ID'), 'N') <> P_SALES_CREDIT_Rec.CREDIT_TYPE_ID THEN
	        duplicate_sales_credit(
		      p_init_msg_list          => FND_API.G_FALSE,
		      p_validation_mode        => p_validation_mode,
	              P_SALES_CREDIT_Rec       => P_SALES_CREDIT_Rec,
		      x_return_status          => x_return_status,
		      x_msg_count              => x_msg_count,
		      x_msg_data               => x_msg_data);
		  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		      raise FND_API.G_EXC_ERROR;
		  END IF;

		  IF l_debug THEN
		  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
					   'Private API 53: Validated SALES_CREDIT_ID');
		  END IF;
         END IF;
        -- End Added for ASNB

          Validate_SALES_CREDIT_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SALES_CREDIT_ID   => P_SALES_CREDIT_Rec.SALES_CREDIT_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API 53: Validated SALES_CREDIT_ID');
	  END IF;


          Validate_LEAD_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_ID   => P_SALES_CREDIT_Rec.LEAD_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API 54: Validated LEAD_ID');
	  END IF;


          Validate_LEAD_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_LINE_ID   => P_SALES_CREDIT_Rec.LEAD_LINE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API 55: Validated LEAD_LINE_ID');

	  END IF;

          /* validated in record level
          Validate_SALESFORCE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SALESFORCE_ID   => P_SALES_CREDIT_Rec.SALESFORCE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PERSON_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PERSON_ID   => P_SALES_CREDIT_Rec.PERSON_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          */

          Validate_SALESGROUP_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SALESGROUP_ID   => P_SALES_CREDIT_Rec.SALESGROUP_ID,
              p_PERSON_ID       => P_SALES_CREDIT_Rec.PERSON_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API 56: Validated SALESGROUP_ID');
	  END IF;


          /* Validated in record level
          Validate_PARTNER_CUSTOMER_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARTNER_CUSTOMER_ID   => P_SALES_CREDIT_Rec.PARTNER_CUSTOMER_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARTNER_ADDRESS_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARTNER_ADDRESS_ID   => P_SALES_CREDIT_Rec.PARTNER_ADDRESS_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          */

          Validate_CREDIT_TYPE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CREDIT_TYPE_ID   => P_SALES_CREDIT_Rec.CREDIT_TYPE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API 57: Validated CREDIT_TYPE_ID ');

          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API 58: Validate Items end');
	  END IF;


      END IF;


      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD) THEN
          -- Hint: Inter-field level validation can be added here
          -- invoke record level validation procedures
          Validate_SALES_CREDIT_Rec(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_SALES_CREDIT_Rec     =>    P_SALES_CREDIT_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	      IF l_debug THEN
      	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			'Private API 59: SALES_CREDIT_Rec is invalid');
	      END IF;

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
			'Private API 60: ' || l_api_name || 'end');
      END IF;


END Validate_sales_credit;
-- The following procedure added for ASNB
PROCEDURE duplicate_sales_credit(
          P_Init_Msg_List   IN   VARCHAR2     := FND_API.G_FALSE,
          P_Validation_mode IN   VARCHAR2,
	  P_SALES_CREDIT_Rec IN    AS_OPPORTUNITY_PUB.SALES_CREDIT_Rec_Type,
	  X_Return_Status   OUT NOCOPY  VARCHAR2,
	  X_Msg_Count       OUT NOCOPY  NUMBER,
	  X_Msg_Data        OUT NOCOPY  VARCHAR2
	  ) is
CURSOR	C_dup_Sales_Credit_Exists  IS
      	SELECT 'X'
      	FROM  as_sales_credits
      	WHERE lead_id	=P_SALES_CREDIT_Rec.lead_id
	AND   lead_line_id = P_SALES_CREDIT_Rec.lead_line_id
	AND   salesforce_id = P_SALES_CREDIT_Rec.salesforce_id
	AND   person_id     =P_SALES_CREDIT_Rec.person_id
	AND   salesgroup_id =P_SALES_CREDIT_Rec.salesgroup_id
	AND   credit_type_id = P_SALES_CREDIT_Rec.credit_type_id
	AND   (P_SALES_CREDIT_Rec.sales_credit_id is null or P_SALES_CREDIT_Rec.sales_credit_id = fnd_api.g_miss_num
	OR sales_credit_id <> P_SALES_CREDIT_Rec.sales_credit_id);
l_val VARCHAR2(1);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lscpv.duplicate_sales_credit';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	      OPEN  C_dup_Sales_Credit_Exists;
              FETCH C_dup_Sales_Credit_Exists into l_val;
              IF C_dup_Sales_Credit_Exists%FOUND THEN
		   AS_UTILITY_PVT.Set_Message(
		      p_module        => l_module,
		      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		      p_msg_name      => 'AS_DUP_SALES_CREDITS');
		  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_dup_Sales_Credit_Exists;
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END duplicate_sales_credit;

End AS_OPP_SALES_CREDIT_PVT;

/
